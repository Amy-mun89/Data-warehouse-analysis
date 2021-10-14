# Data-warehouse-analysis

## Dataset
the excel file have four sheets, which will be converted into each tables.

* fat_order: order database
* fct_rating : feedback of the order. Positive or negative
* dim_platform : platforms (androiad, ios, web)
* dim_payment: payment method(sofort,cash,paypal,creditcard)

## Questions
Q1) Among all customers who have at least 2 orders so far: What is the percentage of customers who used the same payment method for their second order, split by the first payment method?

* Output columns: payment_method (VARCHAR), pct_2order (FLOAT)

Q2) Excluding acquisitions, what was the ratio of customers placing another order within 45 daysafter an order they left a positive feedback for? Use 2019 order data only.

* Output columns: positive_feedback_45d_return (FLOAT)

Q3) How many customers in 2017 ordered using Android only for all their orders within the year?

* Output columns: customers (INTEGER)
