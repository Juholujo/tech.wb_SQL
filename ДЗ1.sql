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
