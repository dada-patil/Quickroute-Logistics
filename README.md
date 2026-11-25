
# QuickRoute Logistics – SQL Data Analysis Project

## 1. Project Overview

QuickRoute Logistics is a MySQL-based logistics and delivery management data analysis project.

The project focuses on analyzing customer information, orders, delivery performance, driver efficiency, vehicle utilization, and delivery failures.

The main objective is to transform logistics data into meaningful business insights using SQL queries.

## 2. Project Objectives

- Analyze total customers, orders, and deliveries.
- Identify high-demand delivery zones.
- Understand customer ordering behaviour.
- Analyze monthly order trends.
- Evaluate delivery status and performance.
- Measure driver and vehicle utilization.
- Identify repeated delivery attempts.
- Analyze failed deliveries.
- Perform database and data-quality checks.

## 3. Technologies Used

| Technology | Purpose |
|---|---|
| MySQL | Database management |
| SQL | Data analysis and querying |
| MySQL Workbench | Query execution |
| CSV | Source data format, if supplied separately |

## 4. Database Information

**Database Name:** `quickroute_logistics`

The project contains five main tables:

### 1. Customers
Stores customer details.

- customer_id (Primary Key)
- customer_name
- city
- delivery_zone_id
- preferred_time_slot
- customer_type
- account_since

### 2. Orders
Stores customer order information.

- order_id (Primary Key)
- customer_id (Foreign Key)
- order_date
- delivery_zone_id
- package_weight_kg
- service_type
- priority
- total_value

### 3. Deliveries
Stores delivery and shipment information.

- delivery_id (Primary Key)
- order_id (Foreign Key)
- driver_id (Foreign Key)
- vehicle_id (Foreign Key)
- assigned_date
- actual_delivery_date
- status
- delivery_attempt
- distance_km
- delivery_duration_min

### 4. Drivers
Stores driver information.

- driver_id (Primary Key)
- driver_name
- hire_date
- rating
- employment_type
- is_active

### 5. Vehicles
Stores vehicle information.

- vehicle_id (Primary Key)
- vehicle_type
- fuel_type
- max_payload_kg
- depot
- last_service_date
- is_active

## 5. Database Relationships

- Customers → Orders: One customer can have multiple orders.
- Orders → Deliveries: One order can have multiple delivery records.
- Drivers → Deliveries: One driver can handle multiple deliveries.
- Vehicles → Deliveries: One vehicle can be used for multiple deliveries.

Foreign keys maintain relationships between the tables.

## 6. Project Workflow

The SQL script is organized into the following stages:

### Sprint 2 – Database and Table Creation

- Create the database.
- Create five tables.
- Define primary keys.
- Define foreign keys.
- Create indexes.
- Verify table row counts.

### Sprint 3 – Baseline Data Exploration

- Count total customers.
- Count total orders.
- Count total deliveries.
- Analyze service types.
- Analyze active drivers.
- Analyze vehicle types.
- Calculate total order value.
- Calculate average package weight.

### Sprint 4.1 – Delivery Demand Analysis

- Orders by delivery zone.
- Orders by service type.
- Orders by priority.
- Monthly order trends.
- Order value by delivery zone.

### Sprint 4.2 – Customer Behaviour Analysis

- Customer-wise order count.
- Customer lifetime order value.
- Customer type analysis.
- Customer distribution by delivery zone.
- Monthly active customers.

### Sprint 4.3 – Delivery Performance Analysis

- Delivery status analysis.
- Delivery performance by zone.
- Average delivery duration.
- Monthly delivery activity.
- Delivery performance by service type.

### Sprint 4.4 – Driver and Vehicle Analysis

- Total deliveries handled by each driver.
- Driver ratings.
- Delivered records by driver.
- Vehicle utilization.
- Performance by vehicle type.
- Average delivery duration by vehicle.

### Sprint 4.5 – Repeat Attempts and Delivery Problems

- Identify orders with multiple delivery records.
- Find maximum delivery attempts.
- Analyze failed deliveries.
- Calculate failed delivery percentage.
- Analyze delivery duration by attempt.
- Analyze package weight and delivery duration.

### Data Quality Checks

The project also includes checks for:

- Orders without matching customers.
- Deliveries without matching orders.
- Delivery status distribution.
- MySQL local file loading configuration.

## 7. SQL Concepts Used

The project uses the following SQL concepts:

- CREATE DATABASE
- CREATE TABLE
- PRIMARY KEY
- FOREIGN KEY
- CREATE INDEX
- SELECT
- COUNT()
- SUM()
- AVG()
- MAX()
- MIN()
- GROUP BY
- ORDER BY
- HAVING
- INNER JOIN
- LEFT JOIN
- DISTINCT
- CASE-style conditional aggregation
- DATE_FORMAT()
- COALESCE()
- NULLIF()
- GROUP_CONCAT()
- Subqueries and aggregate analysis

## 8. Example SQL Queries

### Total Customers

```sql
SELECT COUNT(*) AS total_customers
FROM customers;
```

### Total Orders by Service Type

```sql
SELECT
    service_type,
    COUNT(*) AS order_count
FROM orders
GROUP BY service_type
ORDER BY order_count DESC;
```

### Customer Lifetime Order Value

```sql
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS orders_count,
    SUM(o.total_value) AS lifetime_order_value
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY lifetime_order_value DESC;
```

### Delivery Status Analysis

```sql
SELECT
    status,
    COUNT(*) AS delivery_records,
    AVG(delivery_duration_min) AS avg_duration
FROM deliveries
GROUP BY status;
```

### Driver Performance

```sql
SELECT
    dr.driver_name,
    COUNT(d.delivery_id) AS deliveries_handled,
    AVG(d.delivery_duration_min) AS avg_duration
FROM drivers dr
LEFT JOIN deliveries d
    ON dr.driver_id = d.driver_id
GROUP BY dr.driver_id, dr.driver_name;
```

### Failed Delivery Percentage by Zone

```sql
SELECT
    o.delivery_zone_id,
    COUNT(*) AS delivery_records,
    SUM(d.status = 'Failed') AS failed_records,
    ROUND(
        100 * SUM(d.status = 'Failed')
        / NULLIF(COUNT(*), 0), 2
    ) AS failed_record_pct
FROM orders o
JOIN deliveries d
    ON o.order_id = d.order_id
GROUP BY o.delivery_zone_id
ORDER BY failed_record_pct DESC;
```

## 9. Business Benefits

This project can help logistics companies:

- Identify high-demand delivery zones.
- Understand customer ordering patterns.
- Monitor delivery performance.
- Evaluate driver productivity.
- Improve vehicle utilization.
- Identify repeated delivery attempts.
- Monitor failed delivery percentages.
- Support data-driven business decisions.

## 10. How to Run the Project

1. Install MySQL Server and MySQL Workbench.
2. Open MySQL Workbench.
3. Connect to your MySQL server.
4. Open `quickroute_safe_refresh.sql`.
5. Execute the complete SQL script.
6. Check the database using:

```sql
SHOW DATABASES;
USE quickroute_logistics;
SHOW TABLES;
```

7. Execute the analysis queries.
8. Review the returned results.

**Important:** The supplied SQL script creates missing tables and performs read-only analysis. It does not insert or reload CSV data. Existing table definitions and records are not overwritten.

If the database is empty, load the original project CSV datasets before running the analysis.

## 11. Expected Project Outcomes

The SQL analysis is designed to produce insights about:

- Customer ordering behaviour.
- Delivery demand.
- Monthly business activity.
- Delivery performance.
- Driver and vehicle utilization.
- Failed deliveries.
- Repeated delivery attempts.
- Data quality.

Actual numerical findings should be added after executing the queries against the populated database.

## 12. Conclusion

QuickRoute Logistics demonstrates how MySQL and SQL can be used to manage relational data and analyze logistics operations.

By applying joins, aggregate functions, filtering, grouping, and conditional analysis, the project helps convert raw logistics records into useful business information.

It provides practical experience in database management, SQL querying, and business-oriented data analysis.

---

**Project Name:** QuickRoute Logistics – SQL Data Analysis Project  
**Database:** MySQL  
**Project Type:** SQL / Data Analytics
