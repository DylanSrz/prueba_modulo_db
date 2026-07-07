# EcoMarket Riwi — Relational Database

Performance test for **Module 4: Relational Databases** (Riwi).
It transforms a flat, inconsistent Excel file into a normalized (3NF) PostgreSQL
database for the fictional company **EcoMarket Riwi S.A.S.**, a fresh-food
distributor.

---

## Project description

EcoMarket managed its whole operation in a single Excel file, which caused
duplicated clients, products written in different ways, inconsistent categories,
repeated distribution centers and unreliable reports.

This project turns that Excel into a professional relational model:

- Detects redundancies and inconsistencies in the source data.
- Normalizes the data up to **Third Normal Form (3NF)**.
- Implements the database in PostgreSQL with full integrity constraints.
- Loads clean data and answers real business questions with SQL.

---

## Technologies

- **PostgreSQL 16** — database engine.
- **Docker / Docker Compose** — runs PostgreSQL and loads the database automatically.
- **DBeaver** — SQL client used to connect and run the scripts.
- **SQL** — DDL, DML and queries.

---

## Database engine

**PostgreSQL 16**. Database name: `bd_dylan_suarez_puerta_de_oro`.

All tables and columns are written **in English** and use the prefix **`eco_`**.

---

## Normalization process

The source Excel (`dataset.xlsx`) was a single flat sheet of 20 rows mixing
clients, cities, products, categories, centers, orders and inventory. Each entity
appeared written in several ways (e.g. `SuperMax` / `super max`, `Bogotá` /
`Bogota`, `Fruits` / `Fruit`).

The data was cleaned and split following the normal forms:

1. **1NF** — atomic values, cleaned text and a key per row (`OrderID`).
2. **2NF** — independent entities (clients, cities, categories, centers, products)
   moved to their own tables so their data is not repeated.
3. **3NF** — removed transitive dependencies: price and category belong to the
   product; stock belongs to the product + center; foreign keys reference IDs.

Two key decisions: the **city belongs to the order** (SuperMax orders from both
Bogotá and Barranquilla) and the **unit price belongs to the product** (it is
constant per product in the data).

Full step-by-step analysis (in Spanish): [`docs/normalizacion.md`](./docs/normalizacion.md).

---

## Database schema

8 tables, all prefixed with `eco_`:

| Table | Description |
|-------|-------------|
| `eco_city` | Cities |
| `eco_category` | Product categories |
| `eco_distribution_center` | Distribution centers |
| `eco_client` | Clients |
| `eco_product` | Products (unit price + category) |
| `eco_order` | Orders (client, city, center, date) |
| `eco_order_detail` | Products and quantity of each order |
| `eco_inventory` | Stock per product and center |

Constraints used: `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `NOT NULL` and `CHECK`.
Full DDL: [`sql/01_ddl.sql`](./sql/01_ddl.sql).

---

## Entity Relationship Diagram

The ER diagram is in [`docs/MER.png`](./docs/MER.png)  

---

## Database creation instructions

The easiest way is with Docker (it creates the database and loads everything on
the first start):

```bash
docker compose up -d
```

This runs every script in `sql/` in order (`01` → `05`).

Then connect with **DBeaver**:

| Setting | Value |
|---------|-------|
| Host | `localhost` |
| Port | `5434` |
| Database | `bd_dylan_suarez_puerta_de_oro` |
| User | `postgres` |
| Password | `postgres1234` |

To start over from scratch:

```bash
docker compose down -v && docker compose up -d
```

Prefer to run it manually? Create an empty PostgreSQL database and run the scripts
in DBeaver in this order: `01_ddl.sql`, `02_load_data.sql`, `03_dml.sql`,
`04_queries.sql`, `05_extra_views_procedure.sql`.

---

## Data loading instructions

Data is loaded with SQL `INSERT` scripts already cleaned and normalized:

- [`sql/02_load_data.sql`](./sql/02_load_data.sql) — inserts all rows.

With Docker this runs automatically. As an alternative, the `data/` folder has one
**CSV per table** (each including its own id column) to load with `COPY` or the
DBeaver Import Wizard. Load them in this order (parents before children) so the
foreign keys match:

```sql
\copy eco_city                FROM 'data/eco_city.csv'                WITH (FORMAT csv, HEADER true);
\copy eco_category            FROM 'data/eco_category.csv'            WITH (FORMAT csv, HEADER true);
\copy eco_distribution_center FROM 'data/eco_distribution_center.csv' WITH (FORMAT csv, HEADER true);
\copy eco_client              FROM 'data/eco_client.csv'              WITH (FORMAT csv, HEADER true);
\copy eco_product             FROM 'data/eco_product.csv'             WITH (FORMAT csv, HEADER true);
\copy eco_order               FROM 'data/eco_order.csv'               WITH (FORMAT csv, HEADER true);
\copy eco_order_detail        FROM 'data/eco_order_detail.csv'        WITH (FORMAT csv, HEADER true);
\copy eco_inventory           FROM 'data/eco_inventory.csv'           WITH (FORMAT csv, HEADER true);
```

Because the CSVs bring explicit ids, resync each table's id counter afterwards so a
future insert without an id does not collide:

```sql
SELECT setval(pg_get_serial_sequence('eco_city', 'city_id'),                      (SELECT max(city_id)         FROM eco_city));
SELECT setval(pg_get_serial_sequence('eco_category', 'category_id'),              (SELECT max(category_id)     FROM eco_category));
SELECT setval(pg_get_serial_sequence('eco_distribution_center', 'center_id'),     (SELECT max(center_id)       FROM eco_distribution_center));
SELECT setval(pg_get_serial_sequence('eco_client', 'client_id'),                  (SELECT max(client_id)       FROM eco_client));
SELECT setval(pg_get_serial_sequence('eco_product', 'product_id'),                (SELECT max(product_id)      FROM eco_product));
SELECT setval(pg_get_serial_sequence('eco_order', 'order_id'),                    (SELECT max(order_id)        FROM eco_order));
SELECT setval(pg_get_serial_sequence('eco_order_detail', 'order_detail_id'),      (SELECT max(order_detail_id) FROM eco_order_detail));
SELECT setval(pg_get_serial_sequence('eco_inventory', 'inventory_id'),            (SELECT max(inventory_id)    FROM eco_inventory));
```

---

## SQL query explanation

Business queries are in [`sql/04_queries.sql`](./sql/04_queries.sql):

| # | Query | Business need |
|---|-------|---------------|
| 1 | Inventory available per product | plan new purchases |
| 2 | Orders per city | find cities with the highest order volume |
| 3 | Total sold per category | identify categories with the most revenue |
| 4 | Products with lowest inventory | spot products about to run out |
| 5 | Clients with the most orders | identify the most active clients |
| 6 | Inventory value per center | know the stored value per center |

### Extra points (+20)

In [`sql/05_extra_views_procedure.sql`](./sql/05_extra_views_procedure.sql):

- **View `eco_sales_by_category`** — units sold and revenue per category.
- **View `eco_top_clients`** — number of orders and total spent per client.
- **Function `eco_get_clients(id)`** — returns one client if given an ID, or all
  clients if given `NULL`:

```sql
SELECT * FROM eco_get_clients(NULL);  -- all clients
SELECT * FROM eco_get_clients(1);     -- only client 1
```

---

## Developer information

- **Name:** Dylan Suárez
- **Clan:** Puerta de Oro (Riwi)
- **Email:** dylansrz96@gmail.com
- **GitHub:** [DylanSrz](https://github.com/DylanSrz)
