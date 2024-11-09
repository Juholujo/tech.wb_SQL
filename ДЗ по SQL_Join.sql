--------------------------------- 1 Часть -----------------------------------------------
--------------------------------- Пункт 1 -----------------------------------------------

-- Запрос для нахождения клиента с самым долгим временем ожидания между заказом и доставкой
SELECT c.customer_id, c.name AS customer_name, EXTRACT(DAY FROM AGE(CAST(o.shipment_date AS DATE), CAST(o.order_date AS DATE))) AS waiting_days -- Вычисляем количество дней ожидания между датой заказа и датой доставки
FROM customers_new c
JOIN orders_new o ON c.customer_id = o.customer_id  -- Соединяем таблицы клиентов и заказов по customer_id
WHERE o.shipment_date IS NOT NULL -- Оставляем только заказы, которые были отправлены
ORDER BY waiting_days DESC -- Сортируем по времени ожидания в порядке убывания
LIMIT 1; -- Ограничиваем результат одним записом для получения клиента с максимальным временем ожидания

--------------------------------- 1 Часть -----------------------------------------------
--------------------------------- Пункт 2 -----------------------------------------------

-- Запрос для нахождения клиентов с наибольшим количеством заказов, среднего времени между заказом и доставкой, а также общей суммы их заказов
SELECT c.customer_id, c.name AS customer_name, COUNT(o.order_id) AS order_count, AVG(EXTRACT(DAY FROM AGE(CAST(o.shipment_date AS DATE), CAST(o.order_date AS DATE)))) AS avg_waiting_time, SUM(o.order_ammount) AS total_order_sum -- Считаем количество заказов каждого клиента, суммируем общую сумму всех заказов клиента
FROM customers_new c
JOIN orders_new o ON c.customer_id = o.customer_id  -- Объединяем таблицы клиентов и заказов по customer_id
WHERE o.shipment_date IS NOT NULL -- Оставляем только заказы, которые были отправлены
GROUP BY c.customer_id, c.name -- Группируем данные по идентификатору и имени клиента
ORDER BY total_order_sum DESC; -- Сортируем клиентов по общей сумме заказов в порядке убывания

--------------------------------- 1 Часть -----------------------------------------------
--------------------------------- Пункт 3 -----------------------------------------------

-- Запрос для нахождения клиентов, у которых были заказы с задержкой доставки более 5 дней или отмененные заказы
SELECT  c.customer_id, c.name AS customer_name,
    -- Считаем количество доставок с задержкой более 5 дней для каждого клиента
    COUNT(CASE WHEN (CAST(o.shipment_date AS DATE) - CAST(o.order_date AS DATE)) > 5 THEN 1 END) AS delayed_deliveries,
    -- Считаем количество отмененных заказов для каждого клиента
    COUNT(CASE WHEN o.order_status = 'Cancel' THEN 1 END) AS cancel_order,
    -- Суммируем общую сумму всех заказов клиента
    SUM(o.order_ammount) AS total_order_sum
FROM customers_new c
    JOIN orders_new o ON c.customer_id = o.customer_id  -- Соединяем таблицы клиентов и заказов по customer_id
GROUP BY
    c.customer_id, c.name  -- Группируем данные по идентификатору и имени клиента
HAVING
    -- Оставляем только клиентов, у которых есть хотя бы одна задержанная доставка или отмененный заказ
    COUNT(CASE WHEN (CAST(o.shipment_date AS DATE) - CAST(o.order_date AS DATE)) > 5 THEN 1 END) > 0
    OR COUNT(CASE WHEN o.order_status = 'Cancel' THEN 1 END) > 0
ORDER BY
    total_order_sum DESC;


--------------------------------- 2 Часть -----------------------------------------------
--------------------------------- Пункт 1 -----------------------------------------------

-- Запрос для вычисления общей суммы продаж для каждой категории продуктов
SELECT p.product_category, SUM(o.order_ammount) AS total_sales  -- Суммируем общую сумму заказов для каждой категории
FROM Orders o
JOIN Products p ON o.product_id = p.product_id  -- Объединяем таблицы Orders и Products по product_id
GROUP BY p.product_category;  -- Группируем результаты по категории продукта

--------------------------------- 2 Часть -----------------------------------------------
--------------------------------- Пункт 2 -----------------------------------------------

-- Запрос для определения категории продукта с наибольшей общей суммой продаж
SELECT p.product_category,
       SUM(o.order_ammount) AS total_sales
FROM Orders o
JOIN Products p ON o.product_id = p.product_id
GROUP BY p.product_category
ORDER BY total_sales DESC
LIMIT 1;  -- Выбираем категорию с максимальной суммой продаж


--------------------------------- 2 Часть -----------------------------------------------
--------------------------------- Пункт 3 -----------------------------------------------

-- Запрос для определения продукта с максимальной суммой продаж в каждой категории
SELECT p.product_category, p.product_name, product_sales.total_sales
FROM Products p
JOIN ( -- Подзапрос для вычисления общей суммы продаж для каждого продукта
    SELECT o.product_id,
           SUM(o.order_ammount) AS total_sales
    FROM Orders o
    GROUP BY o.product_id
) AS product_sales ON p.product_id = product_sales.product_id
WHERE (p.product_category, product_sales.total_sales) IN ( -- Подзапрос для определения максимальной суммы продаж в каждой категории
    SELECT p1.product_category,
           MAX(product_sales.total_sales) AS max_sales
    FROM Products p1
    JOIN ( -- Повторный подзапрос для сумм продаж каждого продукта
        SELECT o.product_id,
               SUM(o.order_ammount) AS total_sales
        FROM Orders o
        GROUP BY o.product_id
    ) AS product_sales ON p1.product_id = product_sales.product_id
    GROUP BY p1.product_category
);
