-- 1 Часть
-- Пункт 1
SELECT
    city,
    CASE
        WHEN age BETWEEN 0 AND 20 THEN 'young'
        WHEN age BETWEEN 21 AND 49 THEN 'adult'
        ELSE 'old'
    END AS age_category,
    COUNT(id) AS user_count
FROM
    users
GROUP BY
    city,
    age_category
ORDER BY
    user_count desc;

-- 1 Часть
-- Пункт 2
    SELECT
    category,
    ROUND(AVG(price), 2) AS avg_price
FROM
    products
WHERE
    name ILIKE '%hair%' OR name ILIKE '%home%'  -- Используем ILIKE для поиска без учета регистра
GROUP BY
    category;

-- 2 Часть
-- Пункт 1

SELECT
    seller_id,
    COUNT(DISTINCT category) AS total_categ,
    SUM(revenue) AS total_revenue,
    ROUND(AVG(rating), 2) AS avg_rating,
    CASE
        WHEN COUNT(DISTINCT category) > 1 AND SUM(revenue) > 50000 THEN 'rich'
        WHEN COUNT(DISTINCT category) > 1 AND SUM(revenue) <= 50000 THEN 'poor'
    END AS seller_type
FROM
    sellers
WHERE
    category != 'Bedding'  -- Исключаем категорию "Bedding"
GROUP BY
    seller_id
HAVING
    COUNT(DISTINCT category) > 1  -- Оставляем только тех, кто продает более одной категории товаров
ORDER BY
    seller_id ASC;
