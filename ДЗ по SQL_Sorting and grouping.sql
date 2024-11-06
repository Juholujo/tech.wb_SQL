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
