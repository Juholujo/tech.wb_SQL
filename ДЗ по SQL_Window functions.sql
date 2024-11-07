--- Часть 1
--- Запрос без Window fuction c MAX salary
SELECT
    s.first_name,
    s.last_name,
    s.salary,
    s.industry,
    hs.highest_sal_name AS name_highest_sal
FROM
    salary s
JOIN (
    SELECT
        industry,
        MAX(salary) AS max_salary
    FROM
        salary
    GROUP BY
        industry
) ms ON s.industry = ms.industry
LEFT JOIN (
    SELECT
        industry,
        MAX(first_name) AS highest_sal_name
    FROM
        salary
    WHERE
        (industry, salary) IN (
            SELECT
                industry,
                MAX(salary)
            FROM
                salary
            GROUP BY
                industry
        )
    GROUP BY
        industry
) hs ON s.industry = hs.industry
order by salary desc, first_name ;

--- Запрос c Window fuction c MAX salary
SELECT
    s.first_name,
    s.last_name,
    s.salary,
    s.industry,
    FIRST_VALUE(s.first_name) OVER (
        PARTITION BY s.industry
        ORDER BY s.salary DESC, s.first_name ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS name_highest_sal
FROM
    salary s
order by salary desc, first_name ;

--- Запрос без Window fuction c MIN salary
SELECT
    s.first_name,
    s.last_name,
    s.salary,
    s.industry,
    ls.lowest_sal_name AS name_lowest_sal
FROM
    salary s
JOIN (
    SELECT
        industry,
        MIN(salary) AS min_salary
    FROM
        salary
    GROUP BY
        industry
) ms ON s.industry = ms.industry
JOIN (
    SELECT
        industry,
        MIN(first_name) AS lowest_sal_name
    FROM
        salary
    WHERE
        (industry, salary) IN (
            SELECT
                industry,
                MIN(salary)
            FROM
                salary
            GROUP BY
                industry
        )
    GROUP BY
        industry
) ls ON s.industry = ls.industry
order by salary, first_name ;

--- Запрос с Window fuction c MIN salary
SELECT
    s.first_name,
    s.last_name,
    s.salary,
    s.industry,
    FIRST_VALUE(s.first_name) OVER (
        PARTITION BY s.industry
        ORDER BY s.salary ASC, s.first_name ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS name_lowest_sal
FROM
    salary s
order by salary asc, first_name ;
