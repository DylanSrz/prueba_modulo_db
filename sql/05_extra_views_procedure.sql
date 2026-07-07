
-- Vista 1: eco_sales_by_category
-- Analisis comercial: ingresos totales y unidades vendidas por categoria.

CREATE OR REPLACE VIEW eco_sales_by_category AS
SELECT
    c.category_name,
    SUM(od.quantity)                AS units_sold,
    SUM(od.quantity * p.unit_price) AS total_revenue
FROM eco_order_detail od
JOIN eco_product p  ON p.product_id  = od.product_id
JOIN eco_category c ON c.category_id = p.category_id
GROUP BY c.category_name;


-- Vista 2: eco_top_clients
-- Analisis comercial: numero de pedidos y valor total comprado por cliente.

CREATE OR REPLACE VIEW eco_top_clients AS
SELECT
    cl.client_name,
    COUNT(DISTINCT o.order_id)      AS total_orders,
    SUM(od.quantity * p.unit_price) AS total_spent
FROM eco_client cl
JOIN eco_order o        ON o.client_id  = cl.client_id
JOIN eco_order_detail od ON od.order_id = o.order_id
JOIN eco_product p       ON p.product_id = od.product_id
GROUP BY cl.client_name;


-- ---------------------------------------------------------------------
-- Procedimiento almacenado (funcion): eco_get_clients
-- Se implementa como FUNCTION porque necesita DEVOLVER filas.
--   - eco_get_clients(NULL) -> devuelve todos los clientes.
--   - eco_get_clients(3)    -> devuelve solo el cliente con ID 3.
-- El truco esta en el WHERE: si el parametro es NULL, la primera
-- condicion es verdadera y trae todos; si trae un ID, filtra por ese ID.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eco_get_clients(p_client_id INT DEFAULT NULL)
RETURNS SETOF eco_client
LANGUAGE sql
AS $$
    SELECT *
    FROM eco_client
    WHERE p_client_id IS NULL
       OR client_id = p_client_id
    ORDER BY client_id;
$$;


-- ---------------------------------------------------------------------
-- Ejemplos de uso (ejecutar en DBeaver):
--   SELECT * FROM eco_sales_by_category ORDER BY total_revenue DESC;
--   SELECT * FROM eco_top_clients       ORDER BY total_spent   DESC;
--   SELECT * FROM eco_get_clients(NULL);   -- todos los clientes
--   SELECT * FROM eco_get_clients(1);      -- solo el cliente 1 (SuperMax)
-- ---------------------------------------------------------------------
