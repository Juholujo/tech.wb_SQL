--- Часть 1
--- Пункт 1
SELECT
    c.customer_id,
    c.name AS customer_name,
    EXTRACT(DAY FROM AGE(CAST(o.shipment_date AS DATE), CAST(o.order_date AS DATE))) AS waiting_days
FROM
    customers_new c
JOIN
    orders_new o ON c.customer_id = o.customer_id
WHERE
    o.shipment_date IS NOT NULL
ORDER BY
    waiting_days DESC
LIMIT 1;

--- Часть 1
--- Пункт 2
SELECT
    c.customer_id,
    c.name AS customer_name,
    COUNT(o.order_id) AS order_count,
    AVG(EXTRACT(DAY FROM AGE(CAST(o.shipment_date AS DATE), CAST(o.order_date AS DATE)))) AS avg_waiting_time,
    SUM(o.order_ammount) AS total_order_sum
FROM
    customers_new c
JOIN
    orders_new o ON c.customer_id = o.customer_id
WHERE
    o.shipment_date IS NOT NULL
GROUP BY
    c.customer_id, c.name
ORDER BY
    total_order_sum DESC;

--- Часть 1
--- Пункт 3
SELECT
    c.customer_id,
    c.name AS customer_name,
    COUNT(CASE WHEN EXTRACT(DAY FROM AGE(CAST(o.shipment_date AS DATE), CAST(o.order_date AS DATE))) > 5 THEN 1 END) AS delayed_deliveries,
    COUNT(CASE WHEN o.order_status = 'canceled' THEN 1 END) AS canceled_orders,
    SUM(o.order_ammount) AS total_order_sum
FROM
    customers_new c
JOIN
    orders_new o ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id, c.name
HAVING
    COUNT(CASE WHEN EXTRACT(DAY FROM AGE(CAST(o.shipment_date AS DATE), CAST(o.order_date AS DATE))) > 5 THEN 1 END) > 0
    OR COUNT(CASE WHEN o.order_status = 'canceled' THEN 1 END) > 0
ORDER BY
    total_order_sum DESC;

--- Часть 2
--- Пункт 1
SELECT p.product_category,
       SUM(o.order_ammount) AS total_sales
FROM Orders o
JOIN Products p ON o.product_id = p.product_id
GROUP BY p.product_category;

--- Часть 2
--- Пункт 2

SELECT product_category
FROM (
    SELECT p.product_category,
           SUM(o.order_ammount) AS total_sales
    FROM Orders o
    JOIN Products p ON o.product_id = p.product_id
    GROUP BY p.product_category
) AS category_sales
WHERE total_sales = (
    SELECT MAX(total_sales)
    FROM (
        SELECT SUM(o.order_ammount) AS total_sales
        FROM Orders o
        JOIN Products p ON o.product_id = p.product_id
        GROUP BY p.product_category
    ) AS category_totals
);

--- Часть 2
--- Пункт 3
SELECT product_category, product_name, total_sales
FROM Products p
JOIN (
    SELECT o.product_id,
           SUM(o.order_ammount) AS total_sales
    FROM Orders o
    GROUP BY o.product_id
) AS product_sales ON p.product_id = product_sales.product_id
WHERE (p.product_category, total_sales) IN (
    SELECT p1.product_category,
           MAX(product_sales.total_sales) AS max_sales
    FROM Products p1
    JOIN (
        SELECT o.product_id,
               SUM(o.order_ammount) AS total_sales
        FROM Orders o
        GROUP BY o.product_id
    ) AS product_sales ON p1.product_id = product_sales.product_id
    GROUP BY p1.product_category
);
