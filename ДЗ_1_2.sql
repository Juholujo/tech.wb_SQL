SELECT
    category,
    ROUND(AVG(price), 2) AS avg_price
FROM
    products
WHERE
    name ILIKE '%hair%' OR name ILIKE '%home%'  -- Используем ILIKE для поиска без учета регистра
GROUP BY
    category;
