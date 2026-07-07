
-- Consulta 1: Inventario disponible por producto
-- Necesidad: como jefe de abastecimiento necesito conocer las
--            existencias actuales para planificar nuevas compras.

SELECT
    p.product_name,
    c.category_name,
    dc.center_name,
    i.stock
FROM eco_inventory i
JOIN eco_product p             ON p.product_id  = i.product_id
JOIN eco_category c            ON c.category_id = p.category_id
JOIN eco_distribution_center dc ON dc.center_id = i.center_id
ORDER BY p.product_name;

-- Consulta 2: Historial de pedidos por ciudad
-- Necesidad: como director comercial necesito conocer que ciudades
--            generan mayor volumen de pedidos.

SELECT
    ci.city_name,
    COUNT(o.order_id) AS total_orders
FROM eco_order o
JOIN eco_city ci ON ci.city_id = o.city_id
GROUP BY ci.city_name
ORDER BY total_orders DESC, ci.city_name;


-- Consulta 3: Total vendido por categoria
-- Necesidad: como gerente financiero necesito identificar que
--            categorias generan mayores ingresos.
-- ingreso de una linea = cantidad * precio unitario del producto

SELECT
    c.category_name,
    SUM(od.quantity * p.unit_price) AS total_sold
FROM eco_order_detail od
JOIN eco_product p  ON p.product_id  = od.product_id
JOIN eco_category c ON c.category_id = p.category_id
GROUP BY c.category_name
ORDER BY total_sold DESC;

-- Consulta 4: Productos con menor inventario
-- Necesidad: como coordinador logistico necesito conocer los productos
--            proximos a agotarse (mostramos los 5 mas bajos).

SELECT
    p.product_name,
    dc.center_name,
    i.stock
FROM eco_inventory i
JOIN eco_product p              ON p.product_id = i.product_id
JOIN eco_distribution_center dc ON dc.center_id = i.center_id
ORDER BY i.stock ASC
LIMIT 5;

-- Consulta 5: Clientes con mayor numero de pedidos
-- Necesidad: como director comercial necesito identificar los clientes
--            mas activos.

SELECT
    cl.client_name,
    COUNT(o.order_id) AS total_orders
FROM eco_client cl
JOIN eco_order o ON o.client_id = cl.client_id
GROUP BY cl.client_name
ORDER BY total_orders DESC, cl.client_name;

-- Consulta 6: Valor economico del inventario por centro de distribucion
-- Necesidad: como gerente general necesito conocer el valor del
--            inventario almacenado en cada centro logistico.
-- valor = stock * precio unitario del producto

SELECT
    dc.center_name,
    SUM(i.stock * p.unit_price) AS inventory_value
FROM eco_inventory i
JOIN eco_product p              ON p.product_id = i.product_id
JOIN eco_distribution_center dc ON dc.center_id = i.center_id
GROUP BY dc.center_name
ORDER BY inventory_value DESC;
