--------------------------------- 1 Часть -----------------------------------------------
--------------------------------- Запрос без оконных функций с максимальной зарплатой -----------------------------------------------

SELECT s.first_name, s.last_name, s.salary, s.industry, hs.highest_sal_name AS name_highest_sal
FROM salary s
JOIN ( -- Подзапрос для получения максимальной зарплаты в каждом отделе
    SELECT industry, MAX(salary) AS max_salary
    FROM salary
    GROUP BY industry
) ms ON s.industry = ms.industry AND s.salary = ms.max_salary -- Соединение по отделу и максимальной зарплате
JOIN ( -- Подзапрос для получения имен сотрудников с максимальной зарплатой в каждом отделе
    SELECT industry, first_name AS highest_sal_name
    FROM salary
    WHERE (industry, salary) IN ( -- Выбор записей с максимальной зарплатой в каждом отделе
            SELECT industry, MAX(salary)
            FROM salary
            GROUP BY industry
        ) ) hs ON s.industry = hs.industry AND s.first_name = hs.highest_sal_name -- Соединение по отделу и имени сотрудника с максимальной зарплатой
ORDER BY s.salary DESC, s.first_name; -- Сортировка по зарплате в порядке убывания

--------------------------------- 1 Часть -----------------------------------------------
--------------------------------- Запрос с оконной функцией с максимальной зарплатой -----------------------------------------------

-- Выводим список всех сотрудников и имена сотрудников, получающими самую высокую зарплату в отделе
-- Используем оконную функцию FIRST_VALUE для определения имени сотрудника с максимальной зарплатой в отделе

SELECT s.first_name, s.last_name, s.salary, s.industry,
    -- Определяем имя сотрудника с максимальной зарплатой в отделе
    FIRST_VALUE(s.first_name) OVER (
        PARTITION BY s.industry           -- Разделяем данные по отделам
        ORDER BY s.salary DESC,           -- Сортируем по зарплате в порядке убывания
                 s.first_name ASC         -- При равной зарплате сортируем по имени
    ) AS name_highest_sal
FROM salary s
ORDER BY s.salary DESC, s.first_name;  -- Сортировка по зарплате в порядке убывания, сортировка по имени

--------------------------------- 1 Часть -----------------------------------------------
--------------------------------- Запрос без оконных функций с минимальной зарплатой -----------------------------------------------

-- Выводим список всех сотрудников и имена сотрудников, получающими самую низкую зарплату в отделе

-- Создаем CTE для получения минимальной зарплаты в каждом отделе
WITH min_salaries AS (
    SELECT industry, MIN(salary) AS min_salary   -- Находим минимальную зарплату в каждом отделе
    FROM salary
    GROUP BY industry
),
-- Создаем CTE для получения имен сотрудников с минимальной зарплатой в каждом отделе
min_salary_employees AS ( SELECT s.industry, MIN(s.first_name) AS lowest_sal_name  -- Если несколько сотрудников имеют минимальную зарплату, выбираем имя по алфавиту
    FROM salary s
    JOIN min_salaries ms ON s.industry = ms.industry AND s.salary = ms.min_salary  -- Соединяем по отделу и минимальной зарплате
    GROUP BY s.industry
)
SELECT s.first_name, s.last_name, s.salary, s.industry, mse.lowest_sal_name AS name_lowest_sal    -- Имя сотрудника с минимальной зарплатой в отделе
FROM salary s
-- Соединяем с таблицей сотрудников с минимальной зарплатой в отделе
JOIN min_salary_employees mse ON s.industry = mse.industry
ORDER BY s.salary ASC, s.first_name; -- Сортировка по зарплате в порядке возрастания, сортируем по имени

--------------------------------- 1 Часть -----------------------------------------------
--------------------------------- Запрос с оконной функцией с минимальной зарплатой -----------------------------------------------

-- Выводим список всех сотрудников и имена сотрудников, получающими самую низкую зарплату в отделе
-- Используем оконную функцию FIRST_VALUE для определения имени сотрудника с минимальной зарплатой в отделе

SELECT s.first_name, s.last_name, s.salary, s.industry,
    -- Определяем имя сотрудника с минимальной зарплатой в отделе
    FIRST_VALUE(s.first_name) OVER (
        PARTITION BY s.industry           -- Разделяем данные по отделам
        ORDER BY s.salary ASC,            -- Сортируем по зарплате в порядке возрастания
                 s.first_name ASC         -- Сортируем по имени
    ) AS name_lowest_sal
FROM salary s
ORDER BY s.salary ASC, s.first_name; -- Сортировка по зарплате в порядке возрастания,сортируем по имени



--- Часть 2
--- Пункт 1
SELECT
    sa.shopnumber,
    sh.city,
    sh.address,
    SUM(sa.qty) AS sum_qty,
    SUM(sa.qty * g.price) AS sum_qty_price
FROM
    sales sa
JOIN goods g ON sa.id_good = g.id_good
JOIN shops sh ON sa.shopnumber = sh.shopnumber
WHERE
    sa.date = TO_DATE('01/02/2016', 'MM/DD/YYYY')
GROUP BY
    sa.shopnumber, sh.city, sh.address;


--- Часть 2
--- Пункт 2
WITH total_sales_per_date AS (
    SELECT
        sa.date,
        SUM(sa.qty * g.price) AS total_sales
    FROM
        sales sa
    JOIN goods g ON sa.id_good = g.id_good
    WHERE
        g.category = 'ЧИСТОТА'
    GROUP BY
        sa.date
),
city_sales AS (
    SELECT
        sa.date,
        sh.city,
        SUM(sa.qty * g.price) AS city_sales
    FROM
        sales sa
    JOIN goods g ON sa.id_good = g.id_good
    JOIN shops sh ON sa.shopnumber = sh.shopnumber
    WHERE
        g.category = 'ЧИСТОТА'
    GROUP BY
        sa.date, sh.city
)
SELECT
    cs.date AS date_,
    cs.city,
    CASE
        WHEN ts.total_sales = 0 THEN 0
        ELSE cs.city_sales / ts.total_sales
    END AS sum_sales_rel
FROM
    city_sales cs
JOIN total_sales_per_date ts ON cs.date = ts.date;

--- Часть 2
--- Пункт 3

WITH summed_sales AS (
    SELECT
        sa.date AS date_,
        sa.shopnumber,
        sa.id_good,
        SUM(sa.qty) AS total_qty
    FROM
        sales sa
    GROUP BY
        sa.date, sa.shopnumber, sa.id_good
),
ranked_sales AS (
    SELECT
        date_,
        shopnumber,
        id_good,
        total_qty,
        ROW_NUMBER() OVER (
            PARTITION BY date_, shopnumber
            ORDER BY total_qty DESC
        ) AS rank
    FROM
        summed_sales
)
SELECT
    date_,
    shopnumber,
    id_good
FROM
    ranked_sales
WHERE
    rank <= 3;

--- Часть 2
--- Пункт 4

WITH sales_data AS (
    SELECT
        sa.date AS date_,
        sa.shopnumber,
        g.category,
        SUM(sa.qty * g.price) AS sales_amount
    FROM
        sales sa
    JOIN goods g ON sa.id_good = g.id_good
    JOIN shops sh ON sa.shopnumber = sh.shopnumber
    WHERE
        sh.city = 'СПб'
    GROUP BY
        sa.date, sa.shopnumber, g.category
),
ranked_sales AS (
    SELECT
        date_,
        shopnumber,
        category,
        sales_amount,
        LAG(sales_amount) OVER (
            PARTITION BY shopnumber, category ORDER BY date_
        ) AS prev_sales
    FROM
        sales_data
)
SELECT
    date_,
    shopnumber,
    category,
    prev_sales
FROM
    ranked_sales
WHERE
    prev_sales IS NOT NULL;

--- Часть 3
CREATE TABLE query (
    searchid SERIAL PRIMARY KEY,
    year INT,
    month INT,
    day INT,
    userid INT,
    ts BIGINT,
    devicetype VARCHAR(50),
    deviceid VARCHAR(50),
    query TEXT
);


INSERT INTO query (year, month, day, userid, ts, devicetype, deviceid, query)
VALUES
(2023, 1, 1, 1, 1672531200, 'android', 'device_1', 'к'),
(2023, 1, 1, 1, 1672531210, 'android', 'device_1', 'ку'),
(2023, 1, 1, 1, 1672531220, 'android', 'device_1', 'куп'),
(2023, 1, 1, 1, 1672531230, 'android', 'device_1', 'купи'),
(2023, 1, 1, 1, 1672531240, 'android', 'device_1', 'купит'),
(2023, 1, 1, 1, 1672531250, 'android', 'device_1', 'купить'),
(2023, 1, 1, 1, 1672531400, 'android', 'device_1', 'купить куртку'),
(2023, 1, 1, 1, 1672533600, 'android', 'device_1', 'ноутбук'),
(2023, 1, 1, 2, 1672531300, 'android', 'device_2', 'тел'),
(2023, 1, 1, 2, 1672531365, 'android', 'device_2', 'телефон'),
(2023, 1, 1, 2, 1672531900, 'android', 'device_2', 'тел'),
(2023, 1, 1, 3, 1672531500, 'ios', 'device_3', 'планшет'),
(2023, 1, 1, 3, 1672531520, 'ios', 'device_3', 'планшеты apple'),
(2023, 1, 2, 1, 1672617600, 'android', 'device_1', 'телевизор'),
(2023, 1, 2, 2, 1672617700, 'android', 'device_2', 'фотоаппарат');


WITH query_with_next AS (
    SELECT
        q.*,
        LEAD(q.ts) OVER (PARTITION BY q.userid, q.deviceid ORDER BY q.ts) AS next_ts,
        LEAD(q.query) OVER (PARTITION BY q.userid, q.deviceid ORDER BY q.ts) AS next_query
    FROM
        query q
),
is_final_calculated AS (
    SELECT
        *,
        CASE

            WHEN next_ts IS NULL THEN 1

            WHEN (next_ts - ts) > 180 THEN 1

            WHEN (next_ts - ts) > 60 AND LENGTH(next_query) < LENGTH(query) THEN 2
            ELSE 0
        END AS is_final_value
    FROM
        query_with_next
)
SELECT
    year,
    month,
    day,
    userid,
    ts,
    devicetype,
    deviceid,
    query,
    next_query,
    is_final_value AS is_final
FROM
    is_final_calculated
WHERE

    date_trunc('day', to_timestamp(ts)) = '2023-01-01'::date
    AND devicetype = 'android'
    AND is_final_value IN (1, 2)
ORDER BY
    userid, deviceid, ts;
