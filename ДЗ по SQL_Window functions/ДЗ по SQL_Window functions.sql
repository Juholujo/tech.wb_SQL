--------------------------------- 1 Часть -----------------------------------------------
--------------------------------- Запрос без оконных функций для нахождения сотрудников с максимальной и минимальной зарплатой-------------------------

SELECT s.first_name, s.last_name, s.salary, s.industry, l.name_lowest_sal,h.name_highest_sal
FROM salary AS s
JOIN (SELECT s_high.industry, MIN(s_high.first_name) AS name_highest_sal -- Присоединяем подзапрос с именем сотрудника с максимальной зарплатой в отделе
    FROM salary AS s_high -- Подзапрос для получения максимальной зарплаты в каждом отделе
    JOIN (SELECT industry, MAX(salary) AS max_salary
        FROM salary
        GROUP BY industry
    ) AS ms_high ON s_high.industry = ms_high.industry AND s_high.salary = ms_high.max_salary
    GROUP BY s_high.industry
) AS h ON s.industry = h.industry
JOIN (SELECT s_low.industry, MIN(s_low.first_name) AS name_lowest_sal -- Присоединяем подзапрос с именем сотрудника с минимальной зарплатой в отделе
    FROM salary AS s_low -- Подзапрос для получения минимальной зарплаты в каждом отделе
    JOIN (SELECT industry, MIN(salary) AS min_salary
        FROM salary
        GROUP BY industry
    ) AS ms_low ON s_low.industry = ms_low.industry AND s_low.salary = ms_low.min_salary
    GROUP BY s_low.industry
) AS l ON s.industry = l.industry
ORDER BY s.salary DESC, s.first_name;

--------------------------------- 1 Часть -----------------------------------------------
--------------------------------- Запрос с оконными функциями для нахождения сотрудников с максимальной и минимальной зарплатой- -----------------------
SELECT s.first_name, s.last_name, s.salary, s.industry,
    FIRST_VALUE(s.first_name) OVER (
        PARTITION BY s.industry                 -- Разделяем данные по отделам (industry)
        ORDER BY s.salary ASC, s.first_name ASC -- Сортируем по зарплате (по возрастанию) и по имени (по алфавиту)
    ) AS name_lowest_sal, -- Получаем имя сотрудника с минимальной зарплатой в отделе
    -- Получаем имя сотрудника с максимальной зарплатой в отделе
    LAST_VALUE(s.first_name) OVER (
        PARTITION BY s.industry                 -- Разделяем данные по отделам
        ORDER BY s.salary ASC, s.first_name DESC-- Сортируем по зарплате (по возрастанию) и по имени (в обратном алфавитном порядке)
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING -- Охватываем все строки в разделе
    ) AS name_highest_sal -- Получаем имя сотрудника с максимальной зарплатой в отделе
FROM salary s
ORDER BY s.salary DESC, s.first_name; -- Сортируем общий результат по зарплате (по убыванию), по имени (по возрастанию)

--------------------------------- 2 Часть -----------------------------------------------
--------------------------------- Пункт 1 -----------------------------------------------

--- Запрос возвращает номер магазина, город, адрес, общую сумму проданных товаров и общую выручку магазина за 2 января 2016 года
SELECT s.SHOPNUMBER, sh.CITY, sh.ADDRESS, SUM(s.QTY) AS SUM_QTY, SUM(s.QTY * g.PRICE) AS SUM_QTY_PRICE -- Сумма проданных товаров в штуках, сумма продаж в рублях
FROM SALES s
JOIN SHOPS sh ON s.SHOPNUMBER = sh.SHOPNUMBER
JOIN GOODS g ON s.ID_GOOD = g.ID_GOOD
WHERE TO_DATE(s.DATE, 'MM/DD/YYYY') = TO_DATE('01/02/2016', 'MM/DD/YYYY') -- Сравнение дат
GROUP BY s.SHOPNUMBER, sh.CITY, sh.ADDRESS
ORDER BY s.SHOPNUMBER;

--------------------------------- 2 Часть -----------------------------------------------
--------------------------------- Пункт 2 -----------------------------------------------

-- Запрос возвращает дату, город и долю от суммарных продаж по дням и по городам категории 'Частота'
SELECT s.DATE AS DATE_, sh.CITY, SUM(s.QTY * g.PRICE) / SUM(SUM(s.QTY * g.PRICE)) OVER (PARTITION BY s.DATE) AS SUM_SALES_REL
FROM SALES s
JOIN GOODS g ON s.ID_GOOD = g.ID_GOOD
JOIN SHOPS sh ON s.SHOPNUMBER = sh.SHOPNUMBER
WHERE g.CATEGORY = 'ЧИСТОТА'
GROUP BY s.DATE, sh.CITY
ORDER BY DATE_, sh.CITY;

--------------------------------- 2 Часть -----------------------------------------------
--------------------------------- Пункт 3 -----------------------------------------------

--- Запрос возвращает список товаров, которые заняли первые три места по количеству проданных единиц в каждом магазине на каждую дату
WITH summed_sales AS ( SELECT sa.DATE AS DATE_, sa.SHOPNUMBER, sa.ID_GOOD, SUM(sa.QTY) AS total_qty -- Подзапрос для суммирования продаж по каждому товару в магазине на каждую дату
    FROM SALES sa
    GROUP BY
        sa.DATE, sa.SHOPNUMBER, sa.ID_GOOD
),
ranked_sales AS ( -- Подзапрос для ранжирования товаров по суммарным продажам в каждом магазине на каждую дату
    SELECT date_, shopnumber, id_good, total_qty,
        ROW_NUMBER() OVER (
            PARTITION BY date_, shopnumber -- Разделяем данные по каждой комбинации даты и магазина
            ORDER BY total_qty DESC -- Сортируем товары внутри каждой группы по убыванию количества продаж
        ) AS rn -- Присваиваем ранг каждому товару внутри группы
    FROM summed_sales -- Используем подзапрос summed_sales как источник данных
)
SELECT date_, shopnumber, id_good
FROM ranked_sales -- Используем подзапрос ranked_sales как источник данных
WHERE rn <= 3 -- Фильтруем только те товары, у которых ранг (rn) меньше или равен 3 (топ-3)
ORDER BY date_, shopnumber, rn; -- Сортируем результаты по дате, номеру магазина и рангу для удобства просмотра


--------------------------------- 2 Часть -----------------------------------------------
--------------------------------- Пункт 4 -----------------------------------------------

--- Запрос возвращает для каждого магазина в Санкт-Петербурге и каждой товарной категории сумму продаж в рублях за предыдущий день
WITH sales_data AS ( -- Подзапрос для агрегирования продаж по каждой категории в магазинах Санкт-Петербурга на каждую дату
    SELECT sa.date AS date_, sa.shopnumber, g.category, SUM(sa.qty * g.price) AS sales_amount
    FROM sales sa
    JOIN goods g ON sa.id_good = g.id_good    -- Присоединение таблицы товаров для получения категории и цены
    JOIN shops sh ON sa.shopnumber = sh.shopnumber  -- Присоединение таблицы магазинов для фильтрации по городу
    WHERE sh.city = 'СПб'                  -- Фильтрация данных только для магазинов Санкт-Петербурга
    GROUP BY sa.date, sa.shopnumber, g.category  -- Группировка по дате, номеру магазина и категории товара для агрегации
),
ranked_sales AS (
    SELECT date_, shopnumber, category, sales_amount, LAG(sales_amount) OVER ( -- Использование оконной функции LAG для получения суммы продаж за предыдущую дату
            PARTITION BY shopnumber, category  -- Разделение данных по номеру магазина и категории товара
            ORDER BY date_                  -- Сортировка по дате внутри каждой группы для корректного получения предыдущей суммы
        ) AS prev_sales                   -- Переименование результата в prev_sales
    FROM
        sales_data -- Использование подзапроса sales_data
)
SELECT date_, shopnumber, category, prev_sales
FROM ranked_sales  -- Использование подзапроса ranked_sales как источника данных
WHERE prev_sales IS NOT NULL; -- Фильтрация записей, где существует сумма продаж за предыдущую дату


--------------------------------- 3 Часть -----------------------------------------------

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
-- Пользователь 1 с Samsung Galaxy S21
(2023, 1, 1, 1, 1672531200, 'android', 'Galaxy_S21', 'к'),
(2023, 1, 1, 1, 1672531210, 'android', 'Galaxy_S21', 'ку'),
(2023, 1, 1, 1, 1672531220, 'android', 'Galaxy_S21', 'куп'),
(2023, 1, 1, 1, 1672531230, 'android', 'Galaxy_S21', 'купи'),
(2023, 1, 1, 1, 1672531240, 'android', 'Galaxy_S21', 'купит'),
(2023, 1, 1, 1, 1672531250, 'android', 'Galaxy_S21', 'купить'),
(2023, 1, 1, 1, 1672531400, 'android', 'Galaxy_S21', 'купить куртку'),
(2023, 1, 1, 1, 1672533600, 'android', 'Galaxy_S21', 'ноутбук'),

-- Пользователь 2 с Google Pixel 6
(2023, 1, 1, 2, 1672531300, 'android', 'Pixel_6', 'тел'),
(2023, 1, 1, 2, 1672531365, 'android', 'Pixel_6', 'телефон'),
(2023, 1, 1, 2, 1672531900, 'android', 'Pixel_6', 'тел'),

-- Пользователь 3 с OnePlus 9 Pro
(2023, 1, 1, 3, 1672531500, 'android', 'OnePlus_9Pro', 'планшет'),
(2023, 1, 1, 3, 1672531520, 'android', 'OnePlus_9Pro', 'планшеты samsung'),

-- Пользователь 4 с Xiaomi Mi 11
(2023, 1, 1, 4, 1672531600, 'android', 'Xiaomi_Mi11', 'смартфон'),
(2023, 1, 1, 4, 1672531620, 'android', 'Xiaomi_Mi11', 'смартфоны apple'),

-- Пользователь 5 с Samsung Galaxy Note 20
(2023, 1, 1, 5, 1672531700, 'android', 'Galaxy_Note20', 'фотокамера'),
(2023, 1, 1, 5, 1672531720, 'android', 'Galaxy_Note20', 'фотоаппараты sony'),

-- Пользователь 6 с Google Pixel 5a
(2023, 1, 1, 6, 1672531800, 'android', 'Pixel_5a', 'гаджеты'),
(2023, 1, 1, 6, 1672531820, 'android', 'Pixel_5a', 'гаджеты для дома'),

-- Дополнительные запросы на следующий день
(2023, 1, 2, 1, 1672617600, 'android', 'Galaxy_S21', 'телевизор'),
(2023, 1, 2, 2, 1672617700, 'android', 'Pixel_6', 'фотоаппарат'),
(2023, 1, 2, 3, 1672617800, 'android', 'OnePlus_9Pro', 'наушники'),
(2023, 1, 2, 4, 1672617900, 'android', 'Xiaomi_Mi11', 'колонки'),
(2023, 1, 2, 5, 1672618000, 'android', 'Galaxy_Note20', 'смарт-часы'),
(2023, 1, 2, 6, 1672618100, 'android', 'Pixel_5a', 'гарнитура');


-- Подзапрос для добавления информации о следующем запросе пользователя с тем же устройством
WITH query_with_next AS (
    SELECT
        q.*,  -- Выбираем все поля из таблицы query
        LEAD(q.ts) OVER (
            PARTITION BY q.userid, q.deviceid  -- Разделяем данные по пользователю и устройству
            ORDER BY q.ts                        -- Сортируем по времени запроса
        ) AS next_ts,                             -- Получаем временную метку следующего запроса
        LEAD(q.query) OVER (
            PARTITION BY q.userid, q.deviceid
            ORDER BY q.ts
        ) AS next_query                          -- Получаем текст следующего запроса
    FROM
        query q
),
-- Подзапрос для расчёта значения is_final на основе условий
is_final_calculated AS (
    SELECT
        *,
        CASE
            WHEN next_ts IS NULL THEN 1  -- Если нет следующего запроса, это финальный запрос
            WHEN (next_ts - ts) > 180 THEN 1  -- Если прошло более 3 минут до следующего запроса
            WHEN (next_ts - ts) > 60 AND LENGTH(next_query) < LENGTH(query) THEN 2  -- Если прошло более 1 минуты и следующий запрос короче
            ELSE 0  -- Во всех остальных случаях
        END AS is_final_value
    FROM
        query_with_next
)
-- Основной запрос для выбора необходимых данных
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
    -- Фильтруем по определённому дню
    year = 2023 AND month = 1 AND day = 1
    -- Фильтруем по типу устройства 'android'
    AND devicetype = 'android'
    -- Выбираем только те записи, где is_final равен 1 или 2
    AND is_final_value IN (1, 2)
ORDER BY
    userid, deviceid, ts;
