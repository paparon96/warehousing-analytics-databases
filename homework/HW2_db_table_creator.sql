--- Create database
DROP DATABASE starschema_company;
CREATE DATABASE starschema_company ;
\c starschema_company;

CREATE TABLE order_info (
  order_number INTEGER PRIMARY KEY,
  order_date DATE,
  required_date DATE,
  shipped_date DATE,
  status VARCHAR,
  comments VARCHAR
  ---day_of_the_week VARCHAR,
  ---quarter INTEGER
);

CREATE TABLE dates (
  date_key INTEGER PRIMARY KEY,
  order_date DATE,
  day_of_the_week VARCHAR,
  quarter INTEGER
);

CREATE TABLE employees (
employee_number INTEGER PRIMARY KEY,
last_name VARCHAR NOT NULL,
first_name VARCHAR NOT NULL,
reports_to FLOAT,
job_title VARCHAR,
office_code INTEGER,
city VARCHAR,
state VARCHAR,
country VARCHAR,
office_location VARCHAR
);

CREATE TABLE products (
product_code VARCHAR PRIMARY KEY,
product_name VARCHAR,
product_line VARCHAR,
product_scale VARCHAR,
product_vendor VARCHAR,
product_description VARCHAR,
quantity_in_stock INTEGER,
buy_price FLOAT,
_m_s_r_p FLOAT,
html_description VARCHAR
);

CREATE TABLE customers (
customer_number INTEGER PRIMARY KEY,
customer_name VARCHAR,
contact_last_name VARCHAR,
contact_first_name VARCHAR,
city VARCHAR,
state VARCHAR,
country VARCHAR,
sales_rep_employee_number INTEGER,
credit_limit FLOAT,
customer_location VARCHAR
);

CREATE TABLE order_line_fact_table (
order_number INTEGER REFERENCES order_info(order_number),
product_code VARCHAR REFERENCES products(product_code),
PRIMARY KEY (order_number, product_code),
profit FLOAT,
sales_amount FLOAT,
quantity_ordered INTEGER,
price_each FLOAT,
customer_number INTEGER REFERENCES customers(customer_number),
sales_rep_employee_number INTEGER REFERENCES employees(employee_number),
date_key INTEGER REFERENCES dates(date_key)
);
