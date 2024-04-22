
--top_10_total_income

SELECT CONCAT(employees.first_name, ' ', employees.last_name) AS seller, --use CONCAT for connect first and last name
	COUNT(sales.sales_id) as operations, --use COUNT for quantify operations
	 FLOOR(SUM(sales.quantity * products.price)) AS income --use SUM for find income and FLOOR for round up to integers
FROM employees 
JOIN sales ON employees.employee_id = sales.sales_person_id 
JOIN products ON sales.product_id  = products.product_id
GROUP BY employees.first_name, employees.last_name --GROUP BY seller 
ORDER BY income DESC; --filtrate income by descending

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
    FROM sales 
    JOIN employees ON sales.sales_person_id = employees.employee_id 
    JOIN products ON sales.product_id = products.product_id
    GROUP BY seller, day_of_week
)
SELECT seller, 
    day_of_week, 
    FLOOR(income) AS income --round up to integers
FROM weekly_income --using cte
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

    --age_groups

SELECT 
    age_category,--refer to the column that will create in subquery
    COUNT(*) AS count --count the number of customers
FROM ( --make age groups in subquery for COUNT
    SELECT 
        CASE 
            WHEN age BETWEEN 16 AND 25 THEN '16-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            ELSE '40+'
        END AS age_category, --make age_category column
        age
    FROM customers
) AS age_groups
GROUP BY 
    age_category
ORDER BY --prioritize 
    CASE 
        WHEN age_category = '16-25' THEN 1
        WHEN age_category = '26-40' THEN 2
        ELSE 3
    END;

--customers_by_month

SELECT 
    TO_CHAR(sale_date, 'YYYY-MM') AS selling_month, --use TO_CHAR for extract year and month
    COUNT(DISTINCT customer_id) AS total_customers, --count customers
    SUM(FLOOR(quantity * price)) AS income --use SUM for find income and FLOOR for round up to integers
FROM sales
JOIN products ON sales.product_id = products.product_id
GROUP BY TO_CHAR(sale_date, 'YYYY-MM')
ORDER BY TO_CHAR(sale_date, 'YYYY-MM') ASC; --prioritize

--special_offer

SELECT 
    CONCAT(customers.first_name, ' ', customers.last_name) AS customer, --use CONCAT for connect first and last name
    first_purchase.sale_date, --use first_purchase from subquery
    CONCAT(employees.first_name, ' ', employees.last_name) AS seller --use CONCAT for connect first and last name
FROM customers
JOIN (--find 1st buy
	SELECT customer_id,
	MIN(sale_date) AS sale_date --use MIN for find first buy in sale_date
	from sales
	JOIN products ON sales.product_id = products.product_id
	WHERE products.price = 0 --mean buy was in promotional period
	GROUP BY customer_id) 
	AS first_purchase --merge customers with new subquery table
ON customers.customer_id = first_purchase.customer_id
JOIN sales 
ON first_purchase.customer_id = sales.customer_id 
AND first_purchase.sale_date = sales.sale_date --check the date of purchase to make sure there are no duplicates
JOIN employees 
ON employees.employee_id = sales.sales_person_id
GROUP BY customers.customer_id, first_purchase.sale_date, employees.first_name, employees.last_name
ORDER BY customers.customer_id;

--

