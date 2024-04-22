
--top_10_total_income

SELECT CONCAT(employees.first_name, ' ', employees.last_name) AS seller, --use CONCAT for connect first and last name
	COUNT(sales.sales_id) as operations, --use COUNT for quantify operations
	 FLOOR(SUM(sales.quantity * products.price)) AS income --use SUM for find income and FLOOR for round up to integers
FROM employees 
JOIN sales ON employees.employee_id = sales.sales_person_id 
JOIN products ON sales.product_id  = products.product_id
GROUP BY    employees.first_name, employees.last_name --GROUP BY seller 
ORDER BY  income DESC; --filtrate income by descending

--lowest_average_income

WITH avg_income AS ( --create cte for real average income for all sellers
    SELECT FLOOR(AVG(sales.quantity * products.price)) AS avg_income --find total average income for all sellers and use FLOOR for round to integers
    FROM sales
    JOIN products ON sales.product_id = products.product_id 
),
personal_income AS ( --create cte for find income for every seller
    SELECT employees.employee_id, FLOOR(AVG(sales.quantity * products.price)) AS personal_income --find personal income
    FROM sales
    JOIN employees ON sales.sales_person_id = employees.employee_id
    JOIN products ON sales.product_id = products.product_id
    GROUP BY   employees.employee_id
)
SELECT CONCAT(employees.first_name, ' ', employees.last_name) AS seller, --use concat for connect first and last name
       personal_income AS average_income --name the column according to the task
	--avg_income.avg_income --use for check real average income for all sellers (just for me)
FROM employees 
JOIN personal_income ON employees.employee_id = personal_income.employee_id
JOIN avg_income  ON 1 = 1 --connect avg_income cte
WHERE personal_income < avg_income.avg_income
ORDER BY  average_income ASC;

--day_of_the_week_income

WITH weekly_income AS ( --create cte 
    SELECT 
        CONCAT(employees.first_name, ' ', employees.last_name) AS seller, --use CONCAT for connect first and last name
        CASE --retrieve the weekday number
            WHEN EXTRACT(DOW FROM sales.sale_date) = 1 THEN 'monday' --DOW instead of DAY because DOW use all months, also DAY use only first month 
            WHEN EXTRACT(DOW FROM sales.sale_date) = 2 THEN 'tuesday'
            WHEN EXTRACT(DOW FROM sales.sale_date) = 3 THEN 'wednesday'
            WHEN EXTRACT(DOW FROM sales.sale_date) = 4 THEN 'thursday'
            WHEN EXTRACT(DOW FROM sales.sale_date) = 5 THEN 'friday'
            WHEN EXTRACT(DOW FROM sales.sale_date) = 6 THEN 'saturday'
            WHEN EXTRACT(DOW FROM sales.sale_date) = 0 THEN 'sunday'
        END AS day_of_week,
        SUM(sales.quantity * products.price) AS income --find income sum
    FROM 
        sales 
    JOIN 
        employees ON sales.sales_person_id = employees.employee_id 
    JOIN 
        products ON sales.product_id = products.product_id
    GROUP BY 
        seller, day_of_week
)
SELECT 
    seller,
    day_of_week,
    FLOOR(income) AS income --round up to integers
FROM 
    weekly_income --using cte
ORDER BY 
    CASE --filtrate by day of the week
        WHEN day_of_week = 'monday' THEN 1
        WHEN day_of_week = 'tuesday' THEN 2
        WHEN day_of_week = 'wednesday' THEN 3
        WHEN day_of_week = 'thursday' THEN 4
        WHEN day_of_week = 'friday' THEN 5
        WHEN day_of_week = 'saturday' THEN 6
        WHEN day_of_week = 'sunday' THEN 7
    END,
    seller;
