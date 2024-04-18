create database if not exists walmartsales;

create table if not exists sales(
	invoice_id varchar(30) not null primary key,
    branch varchar(5) not null,
    city varchar(30) not null,
    customer_type varchar(30) not null,
    gender varchar(30) not null,
    product_line varchar(30) not null,
    unit_price varchar(30) not null,
    quantity int not null,
    VAT float(6,4) not null,
    total decimal(12,4) not null,
    date DATETIME not null,
    time TIME not null,
    payment_method varchar(15) not null,
    cogs decimal(10,2) not null,
    gross_margin_pct FLOAT(11,9),
    gross_income decimal(12,4) not null,
    rating float(2,1)
);

-- ------------- Feature Engineering -- -------------------------
-- time_of_day--

select 
	time,
    ( case
		when `time` between "00:00:00" and "12:00:00" then "Morning"
        when `time` between "12:01:00" and "16:00:00" then "Afternoon"
        else "Evening"
        END)
        as time_of_date
from sales;

alter table sales add column time_of_day varchar(20);

update sales 
set time_of_day = ( case
		when `time` between "00:00:00" and "12:00:00" then "Morning"
        when `time` between "12:01:00" and "16:00:00" then "Afternoon"
        else "Evening"
        END
);

-- day_name--

select 
	date,
    dayname(date)
from sales;

alter table sales add column day_name varchar(30);

update sales
set day_name = dayname(date);

-- month_name--

select 
	date,
	monthname(date)
from sales;

alter table sales add column month_name varchar(30);

update sales
set month_name = monthname(date);

-- Generic Questions --

-- How many unique cities does the data have? --

select 
	distinct city
from sales;

-- In which city is each branch -- 

select 
	distinct city, branch
from sales;

-- How many unique product lines does the data have --

select
	distinct count(product_line), product_line
from sales
group by product_line;

-- What is the most common payment method? --

select 
	payment_method,
    count(payment_method) as cnt
from sales
group by payment_method
order by cnt desc;

-- What is the most selling product line? --

select
	product_line,
    count(product_line) as cnt
from sales
group by product_line
order by cnt desc;

-- What is the total revenue by month? --

select 
	month_name as month,
    sum(total) as total_revenue
from sales
group by month_name
order by total_revenue desc;

-- What month had the largest COGS --

select
	month_name as month,
    sum(cogs) as cogs
from sales
group by month_name
order by cogs desc;

-- What product line had the largest revenue --

select
	product_line,
    sum(total) as total_revenue
from sales
group by product_line
order by total_revenue desc;

-- What product line had the largest VAT? -- 

select
	product_line,
    avg(VAT) as avg_tax
from sales
group by product_line
order by avg_tax desc;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales --

select 
	product_line, 
    case 
		when avg(quantity) > 6 then "Good"
	else "bad"
	end as remark
from sales
group by product_line;

-- What is the most common product line by gender --

select
	gender,
    product_line,
    count(gender) as total_cnt
from sales
group by gender,product_line
order by total_cnt desc;

-- Which branch sold more products than average product sold --

select 
	branch,
    sum(quantity) as qty
from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales);

-- What is the average rating of each product line?

select
	product_line,
    round(avg(rating),2) as avg_rating
from sales
group by product_line
order by avg_rating desc;

-- Which time of the day do customers give most ratings?--

select
	time_of_day,
    avg(rating) as avg_rating
from sales
group by time_of_day
order by avg_rating;

-- -- Which time of the day do customers give most ratings per branch? --

select
	distinct branch,
	time_of_day,
    avg(rating) as avg_rating
from sales
group by time_of_day,branch
order by avg_rating;

-- Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;

-- Number of sales made in each time of the day per weekday 
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
-- Evenings experience most sales, the stores are 
-- filled during the evening hours

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue;

-- Which city has the largest tax/VAT percent?
SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax;




