# Proceso de Normalización — EcoMarket Riwi S.A.S.

Documento de análisis y normalización de la base de datos, desde el archivo Excel
original hasta el modelo en **Tercera Forma Normal (3FN)**.

---

## 1. Estado inicial

Toda la operación estaba en **un solo archivo de Excel** con una única hoja
(`Dataset_EcoMarketFresh`) de **20 filas** y **10 columnas**:

| ClientName | City | Product | Category | DistributionCenter | OrderID | OrderDate | Quantity | UnitPrice | Stock |
|------------|------|---------|----------|--------------------|---------|-----------|----------|-----------|-------|
| SuperMax | Bogotá | Apple Gala | Fruits | Center North | O1001 | 2026-05-01 | 10 | 2.5 | 100 |
| super max | Bogota | Gala Apple | Fruit | North Center | O1002 | 2026-05-02 | 5 | 2.5 | 95 |
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |

Es una tabla **plana y desnormalizada**: en una misma fila se mezcla información
de clientes, ciudades, productos, categorías, centros, pedidos e inventario.

---

## 2. Problemas encontrados

### 2.1 Redundancia
- Los datos del cliente, ciudad, producto, categoría y centro **se repiten** en
  cada fila donde aparecen.
- El precio unitario de un producto se repite en cada pedido de ese producto.

### 2.2 Inconsistencias (mismo dato escrito de varias formas)

| Entidad | Ejemplos en el Excel | Valor correcto |
|---------|----------------------|----------------|
| Cliente | `SuperMax`, `super max`, `SuperMax ` | SuperMax |
| Cliente | `FreshMart`, `Fresh Mart` | FreshMart |
| Ciudad | `Bogotá`, `Bogota` | Bogota |
| Ciudad | `Barranquilla`, `Barranquila` | Barranquilla |
| Ciudad | `Pereira`, `Pereria` | Pereira |
| Producto | `Apple Gala`, `Gala Apple` | Apple Gala |
| Producto | `Banana`, `Bananas` | Banana |
| Categoría | `Fruits`, `Fruit` | Fruits |
| Categoría | `Meat`, `Meats` | Meat |
| Centro | `Center North`, `North Center` | Center North |
| Centro | `Coast DC`, `Coastal DC` | Coast DC |

### 2.3 Riesgos de estas inconsistencias
- Un mismo cliente cuenta como varios → reportes poco confiables.
- No se sabe cuál es el inventario real de un producto.
- Es imposible garantizar integridad (nada evita seguir escribiendo mal los datos).

### 2.4 Observaciones clave del negocio
- **`SuperMax` compra en Bogotá y en Barranquilla.** Por lo tanto la **ciudad
  pertenece al pedido**, no al cliente.
- **`UnitPrice` es constante por producto** (Apple Gala = 2.5 en las dos filas)
  → es un atributo del **producto**.
- **`Stock` baja entre filas del mismo producto** (Apple 100 → 95). Representa la
  existencia en un centro; se toma la **lectura más reciente** como stock actual.
- Un centro sirve a varias ciudades (Coast DC atiende Barranquilla y Cartagena),
  por eso el centro **no** se ata a una sola ciudad.

---

## 3. Transformaciones (aplicación de las formas normales)

### 3.1 Primera Forma Normal (1FN)
> *Cada columna guarda un solo valor y existe una clave que identifica cada fila.*

- Se limpian los valores (se unifican mayúsculas, tildes, plurales y espacios).
- Todos los campos ya son atómicos (no hay listas dentro de una celda).
- Se identifica `OrderID` como identificador de cada pedido.

Resultado: una tabla limpia, sin duplicados de escritura y con clave por fila.

### 3.2 Segunda Forma Normal (2FN)
> *Cumple 1FN y todos los atributos dependen de la clave completa, no de una parte.*

Se separan las entidades que no dependen del pedido en sus propias tablas, para
que sus datos no se repitan:

- **Clientes** → `eco_client`
- **Ciudades** → `eco_city`
- **Categorías** → `eco_category`
- **Centros de distribución** → `eco_distribution_center`
- **Productos** → `eco_product`

El pedido (`eco_order`) queda solo con lo suyo (cliente, ciudad, centro, fecha) y
la cantidad de producto se mueve a **`eco_order_detail`** (detalle de pedido), lo
que además permite que un pedido tenga varios productos.

### 3.3 Tercera Forma Normal (3FN)
> *Cumple 2FN y ningún atributo depende de otro atributo no clave (sin dependencias transitivas).*

- El **precio** depende del producto, no del pedido → vive en `eco_product`.
- La **categoría** depende del producto → se referencia con `category_id` (FK).
- El **stock** depende del par producto + centro → se lleva a `eco_inventory`.
- La ciudad y el centro se referencian por su **ID** (FK), no por su nombre.

Ya no hay dependencias transitivas: cada atributo depende únicamente de la clave
de su tabla.

---

## 4. Modelo normalizado final (3FN)

8 tablas, todas con prefijo `eco_` y nombres en inglés:

| Tabla | Descripción | Filas |
|-------|-------------|-------|
| `eco_city` | Ciudades | 9 |
| `eco_category` | Categorías de producto | 6 |
| `eco_distribution_center` | Centros de distribución | 6 |
| `eco_client` | Clientes | 9 |
| `eco_product` | Productos (con precio y categoría) | 10 |
| `eco_order` | Pedidos (cliente, ciudad, centro, fecha) | 20 |
| `eco_order_detail` | Productos y cantidad de cada pedido | 20 |
| `eco_inventory` | Stock por producto y centro | 10 |

**Relaciones principales**
- `eco_product.category_id` → `eco_category`
- `eco_order.client_id` → `eco_client`, `city_id` → `eco_city`, `center_id` → `eco_distribution_center`
- `eco_order_detail.order_id` → `eco_order`, `product_id` → `eco_product`
- `eco_inventory.product_id` → `eco_product`, `center_id` → `eco_distribution_center`

El diagrama Entidad-Relación completo está en [`MER.png`](./MER.png).

---

## 5. Estrategia de validación del modelo

Para demostrar que el modelo en 3FN es viable, se cargaron **todos** los registros
del Excel ya normalizados mediante scripts SQL (`INSERT`). Con esto se comprueba
que:

- La estructura almacena información **consistente** (sin duplicados ni typos).
- Se mantiene la **integridad referencial** (todo pedido apunta a un cliente,
  ciudad, centro y producto que existen).
- Las restricciones (`UNIQUE`, `NOT NULL`, `CHECK`, `FOREIGN KEY`) **impiden**
  operaciones inválidas, como se evidencia en `03_dml.sql`.
