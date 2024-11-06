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
    AVG(rating) AS avg_rating,
    SUM(revenue) AS total_revenue,
    CASE
        WHEN SUM(revenue) > 50000 THEN 'rich'
        ELSE 'poor'
    END AS seller_type
FROM
    sellers
WHERE
    category != 'Bedding'
GROUP BY
    seller_id
HAVING
    COUNT(DISTINCT category) > 1
ORDER BY
    seller_id ASC;

-- 2 Часть
-- Пункт 2
SELECT
    seller_id,
    FLOOR((CURRENT_DATE - TO_DATE(MIN(date_reg), 'DD/MM/YYYY')) / 30)::int AS month_from_registration,
    (SELECT MAX(delivery_days) - MIN(delivery_days)
     FROM sellers
     WHERE category != 'Bedding'
       AND seller_id IN (
           SELECT seller_id
           FROM sellers
           WHERE category != 'Bedding'
           GROUP BY seller_id
           HAVING COUNT(DISTINCT category) > 1 AND SUM(revenue) <= 50000
       )
    ) AS max_delivery_difference
FROM
    sellers
WHERE
    category != 'Bedding'
GROUP BY
    seller_id
HAVING
    COUNT(DISTINCT category) > 1
    AND SUM(revenue) <= 50000
ORDER BY
    seller_id ASC;
