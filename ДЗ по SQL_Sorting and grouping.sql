--------------------------------- 1 Часть-----------------------------------------------
--------------------------------- Пункт 1-----------------------------------------------
-- Запрос для получения количества покупателей по городам и возрастным категориям
SELECT city,
    CASE -- Определяем возрастную категорию на основе возраста пользователя
        WHEN age BETWEEN 0 AND 20 THEN 'young' -- Если возраст от 0 до 20 лет, присваиваем категорию 'young'
        WHEN age BETWEEN 21 AND 49 THEN 'adult' -- Если возраст от 21 до 49 лет, присваиваем категорию 'adult'
        ELSE 'old' -- Если возраст 50 лет и старше, присваиваем категорию 'old'
    END AS age_category,
    COUNT(id) AS user_count -- Считаем количество пользователей в каждой категории
FROM users
GROUP BY city, age_category -- Группируем данные по городу и возрастной категории
ORDER BY user_count desc; -- Сортируем результаты по количеству пользователей в порядке убывания для определения наиболее крупных групп

-- 1 Часть
-- Пункт 2
SELECT category, ROUND(AVG(price), 2) AS avg_price
FROM products
WHERE
    name ILIKE '%hair%' OR name ILIKE '%home%'
GROUP BY category;

-- 2 Часть
-- Пункт 1
SELECT seller_id, COUNT(DISTINCT category) AS total_categ, AVG(rating) AS avg_rating, SUM(revenue) AS total_revenue,
    CASE
        WHEN SUM(revenue) > 50000 THEN 'rich'
        ELSE 'poor'
    END AS seller_type
FROM sellers
WHERE category != 'Bedding'
GROUP BY seller_id
HAVING COUNT(DISTINCT category) > 1
ORDER BY seller_id ASC;

-- 2 Часть
-- Пункт 2
SELECT seller_id,
       FLOOR((CURRENT_DATE - MIN(TO_DATE(date_reg, 'DD/MM/YYYY'))) / 30)::int AS month_from_registration,
       (SELECT MAX(delivery_days) - MIN(delivery_days)
        FROM sellers
        WHERE category != 'Bedding'
          AND seller_id IN (
              SELECT seller_id
              FROM sellers
              WHERE category != 'Bedding'
              GROUP BY seller_id
              HAVING COUNT(DISTINCT category) >= 1 AND SUM(revenue) <= 50000
          )
       ) AS max_delivery_difference
FROM sellers
WHERE category != 'Bedding'
GROUP BY seller_id
HAVING COUNT(DISTINCT category) >= 1 AND SUM(revenue) <= 50000
ORDER BY seller_id ASC;


-- 2 Часть
-- Пункт 3
SELECT seller_id, string_agg(DISTINCT category, ' - ' ORDER BY category) AS category_pair
FROM sellers
WHERE EXTRACT(YEAR FROM TO_DATE(date_reg, 'DD/MM/YYYY')) = 2022
GROUP BY seller_id
HAVING COUNT(DISTINCT category) = 2 AND SUM(revenue) > 75000
ORDER BY seller_id ASC;
