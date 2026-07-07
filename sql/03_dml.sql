
-- 1.1 Nuevo cliente
INSERT INTO eco_client (client_name) VALUES ('DailyFresh');

-- 1.2 Nuevo pedido para ese cliente (entregado en Bogota, despacha Center North)
INSERT INTO eco_order (order_code, client_id, city_id, center_id, order_date)
VALUES (
    'O1021',
    (SELECT client_id FROM eco_client                WHERE client_name = 'DailyFresh'),
    (SELECT city_id   FROM eco_city                  WHERE city_name   = 'Bogota'),
    (SELECT center_id FROM eco_distribution_center   WHERE center_name = 'Center North'),
    '2026-05-20'
);

-- 1.3 Detalle del pedido: 7 unidades de "Apple Gala"
INSERT INTO eco_order_detail (order_id, product_id, quantity)
VALUES (
    (SELECT order_id   FROM eco_order   WHERE order_code   = 'O1021'),
    (SELECT product_id FROM eco_product WHERE product_name = 'Apple Gala'),
    7
);

-- 2) ACTUALIZACION: modificar la informacion de un centro de distribucion.
-- "South Hub" a "South Hub - Cali".

UPDATE eco_distribution_center
SET center_name = 'South Hub - Cali'
WHERE center_name = 'South Hub';



-- 3) ELIMINACION: eliminar un producto que NO tenga pedidos asociados.
-- Primero creamos un producto de prueba sin pedidos y luego lo borramos.

-- 3.1 Producto de prueba (sin ventas ni inventario)
INSERT INTO eco_product (product_name, unit_price, category_id)
VALUES (
    'Test Product',
    1.00,
    (SELECT category_id FROM eco_category WHERE category_name = 'Fruits')
);

-- 3.2 Se puede borrar porque no aparece en ningun pedido
DELETE FROM eco_product WHERE product_name = 'Test Product';


-- 4) PRUEBA DE INTEGRIDAD.
-- Si intentamos borrar un producto que SI tiene pedidos, la clave
-- foranea de eco_order_detail lo impide.

-- DELETE FROM eco_product WHERE product_name = 'Apple Gala';
--   ERROR: update or delete on table "eco_product" violates foreign key
--          constraint "fk_detail_product" on table "eco_order_detail"

