INSERT INTO eco_city (city_name) VALUES
    ('Bogota'),
    ('Medellin'),
    ('Cali'),
    ('Barranquilla'),
    ('Cartagena'),
    ('Bucaramanga'),
    ('Pereira'),
    ('Manizales'),
    ('Cucuta');

INSERT INTO eco_category (category_name) VALUES
    ('Fruits'),
    ('Dairy'),
    ('Meat'),
    ('Grains'),
    ('Oils'),
    ('Vegetables');

INSERT INTO eco_distribution_center (center_name) VALUES
    ('Center North'),
    ('Center West'),
    ('South Hub'),
    ('Coast DC'),
    ('East Hub'),
    ('Coffee DC');

INSERT INTO eco_client (client_name) VALUES
    ('SuperMax'),
    ('FreshMart'),
    ('MiniShop'),
    ('EcoStore'),
    ('MarketOne'),
    ('RetailCo'),
    ('FoodPlus'),
    ('GreenBuy'),
    ('QuickFood');

INSERT INTO eco_product (product_name, unit_price, category_id) VALUES
    ('Apple Gala',     2.50, 1),
    ('Banana',         1.20, 1),
    ('Whole Milk',     3.80, 2),
    ('Chicken Breast', 6.50, 3),
    ('Rice 1kg',       2.00, 4),
    ('Olive Oil',      8.90, 5),
    ('Eggs x12',       4.20, 2),
    ('Tomato',         1.80, 6),
    ('Lettuce',        1.10, 6),
    ('Pasta',          2.30, 4);

INSERT INTO eco_order (order_code, client_id, city_id, center_id, order_date) VALUES
    ('O1001', 1, 1, 1, '2026-05-01'),
    ('O1002', 1, 1, 1, '2026-05-02'),
    ('O1003', 2, 2, 2, '2026-05-02'),
    ('O1004', 2, 2, 2, '2026-05-03'),
    ('O1005', 3, 3, 3, '2026-05-04'),
    ('O1006', 3, 3, 3, '2026-05-05'),
    ('O1007', 1, 4, 4, '2026-05-06'),
    ('O1008', 1, 4, 4, '2026-05-07'),
    ('O1009', 4, 5, 4, '2026-05-08'),
    ('O1010', 4, 5, 4, '2026-05-09'),
    ('O1011', 5, 6, 5, '2026-05-10'),
    ('O1012', 5, 6, 5, '2026-05-11'),
    ('O1013', 6, 7, 6, '2026-05-12'),
    ('O1014', 6, 7, 6, '2026-05-13'),
    ('O1015', 7, 8, 6, '2026-05-14'),
    ('O1016', 7, 8, 6, '2026-05-15'),
    ('O1017', 8, 1, 1, '2026-05-16'),
    ('O1018', 8, 1, 1, '2026-05-17'),
    ('O1019', 9, 9, 5, '2026-05-18'),
    ('O1020', 9, 9, 5, '2026-05-19');

INSERT INTO eco_order_detail (order_id, product_id, quantity) VALUES
    (1,  1,  10),
    (2,  1,   5),
    (3,  2,  20),
    (4,  2,  15),
    (5,  3,  12),
    (6,  3,   8),
    (7,  4,  25),
    (8,  4,  10),
    (9,  5,  30),
    (10, 5,  18),
    (11, 6,   6),
    (12, 6,   4),
    (13, 7,  14),
    (14, 7,   9),
    (15, 8,  22),
    (16, 8,  16),
    (17, 9,  11),
    (18, 9,   7),
    (19, 10, 19),
    (20, 10, 13);

INSERT INTO eco_inventory (product_id, center_id, stock) VALUES
    (1,  1,  95),
    (2,  2, 165),
    (3,  3,  52),
    (4,  4,  60),
    (5,  4, 182),
    (6,  5,  36),
    (7,  6,  81),
    (8,  6, 104),
    (9,  1,  43),
    (10, 5, 127);
