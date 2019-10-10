## I. Import libraries
import pandas as pd
from sqlalchemy import create_engine
import psycopg2
import matplotlib.pyplot as plt

## II. Create engine object to be able to connect to the database
engine = create_engine('postgresql://postgres@localhost:5432/company')

## III. Extract data from the PostgreSQL tables
offices = pd.read_sql_table("offices", con=engine)
employees = pd.read_sql_table("employee", con=engine)
products = pd.read_sql_table("products", con=engine)
orders = pd.read_sql_table("orders", con=engine)
customers = pd.read_sql_table("customers", con=engine)


## IV. Create Measures/Fact table
orders=pd.merge(left=orders,right=products[['product_code','buy_price']],how='left',
                on='product_code')

orders=pd.merge(left=orders,right=customers[['customer_number','sales_rep_employee_number']],how='left',
                on='customer_number')

# Create new measure variables
orders['profit']=(orders['price_each']-orders['buy_price'])*(orders['quantity_ordered'])
orders['sales_amount']=orders['quantity_ordered']*orders['price_each']


#plt.hist(orders['profit'], 50, density=True, facecolor='g', alpha=0.75)
#plt.show()

#plt.hist(orders['sales_amount'], 50, density=True, facecolor='g', alpha=0.75)
#plt.show()

## Modify some dimension tables

# Merge employee and office table, since it makes more sense in the star schema
employees=pd.merge(left=employees,right=offices,how='left',
                on='office_code')

# Create order info table
order_info=orders[['order_number', 'order_date', 'required_date',
 'shipped_date', 'status', 'comments']]

# Create day/quarter variables for order info
order_info['day_of_the_week']=order_info['order_date'].dt.day_name()
order_info['quarter']=order_info['order_date'].dt.quarter

#print(employees.head())
#print(customers.head())
#print(order_info.head())
#print(orders.dtypes)

#plt.hist(order_info['quarter'], 50, density=True, facecolor='g', alpha=0.75)
#plt.show()

## V. Finalize tables
order_line_fact_table=orders[['order_number','product_code','profit','sales_amount',
                                'quantity_ordered','price_each','customer_number',
                                'sales_rep_employee_number']].drop_duplicates()


employees=employees[['employee_number','last_name','first_name','reports_to',
                    'job_title','office_code','city','state','country',
                                        'office_location']].drop_duplicates()

order_info=order_info.drop_duplicates()
products=products.drop_duplicates()
customers=customers.drop_duplicates()
print(order_line_fact_table.head())
print(order_info.head())


## VI. Load tables to the new PostgreSQL database
engine = create_engine('postgresql://postgres@localhost:5432/starschema_company')


products.to_sql('products', engine,index=False,if_exists='append')
customers.to_sql('customers', engine,index=False,if_exists='append')
employees.to_sql('employees', engine,index=False,if_exists='append')
order_info.to_sql('order_info', engine,index=False,if_exists='append')
order_line_fact_table.to_sql('order_line_fact_table', engine,index=False,if_exists='append')

print("DONE")
