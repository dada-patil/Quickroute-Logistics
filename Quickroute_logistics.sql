-- QuickRoute Logistics: safe schema refresh and analysis
-- Re-runnable and non-destructive: no DROP, TRUNCATE, DELETE, or INSERT statements.
-- Existing rows and existing table definitions are left as-is.
-- If a table does not exist, it is created. CSV data is not reloaded by this script.

CREATE DATABASE IF NOT EXISTS quickroute_logistics
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE quickroute_logistics;
SET NAMES utf8mb4;

-- Sprint 2: create missing tables only, in foreign-key dependency order.
CREATE TABLE IF NOT EXISTS customers (
  customer_id VARCHAR(20) NOT NULL,
  customer_name VARCHAR(100) NOT NULL,
  city VARCHAR(50),
  delivery_zone_id VARCHAR(10),
  preferred_time_slot VARCHAR(30),
  customer_type VARCHAR(20) NOT NULL,
  account_since DATE,
  PRIMARY KEY (customer_id),
  KEY idx_customers_zone (delivery_zone_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS drivers (
  driver_id VARCHAR(10) NOT NULL,
  driver_name VARCHAR(100) NOT NULL,
  hire_date DATE,
  rating DECIMAL(3,2),
  employment_type VARCHAR(30),
  is_active CHAR(3),
  PRIMARY KEY (driver_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS vehicles (
  vehicle_id VARCHAR(10) NOT NULL,
  vehicle_type VARCHAR(20) NOT NULL,
  fuel_type VARCHAR(20),
  max_payload_kg DECIMAL(7,2),
  depot VARCHAR(10),
  last_service_date DATE,
  is_active CHAR(3),
  PRIMARY KEY (vehicle_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS orders (
  order_id VARCHAR(20) NOT NULL,
  customer_id VARCHAR(20) NOT NULL,
  order_date DATE NOT NULL,
  delivery_zone_id VARCHAR(10),
  package_weight_kg DECIMAL(5,2),
  service_type VARCHAR(20),
  priority VARCHAR(10),
  total_value DECIMAL(10,2),
  PRIMARY KEY (order_id),
  KEY idx_orders_customer (customer_id),
  KEY idx_orders_date (order_date),
  KEY idx_orders_zone (delivery_zone_id),
  CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS deliveries (
  delivery_id VARCHAR(20) NOT NULL,
  order_id VARCHAR(20) NOT NULL,
  driver_id VARCHAR(10),
  vehicle_id VARCHAR(10),
  assigned_date DATE,
  actual_delivery_date DATE,
  status VARCHAR(20) NOT NULL,
  delivery_attempt TINYINT UNSIGNED,
  distance_km DECIMAL(6,2),
  delivery_duration_min INT UNSIGNED,
  PRIMARY KEY (delivery_id),
  KEY idx_deliveries_order (order_id),
  KEY idx_deliveries_driver (driver_id),
  KEY idx_deliveries_vehicle (vehicle_id),
  KEY idx_deliveries_status (status),
  CONSTRAINT fk_deliveries_order FOREIGN KEY (order_id)
    REFERENCES orders(order_id),
  CONSTRAINT fk_deliveries_driver FOREIGN KEY (driver_id)
    REFERENCES drivers(driver_id),
  CONSTRAINT fk_deliveries_vehicle FOREIGN KEY (vehicle_id)
    REFERENCES vehicles(vehicle_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sprint 2 verification: compare row counts to the project documentation.
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'deliveries', COUNT(*) FROM deliveries
UNION ALL SELECT 'drivers', COUNT(*) FROM drivers
UNION ALL SELECT 'vehicles', COUNT(*) FROM vehicles;

-- Sprint 3: baseline exploration.
SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_orders FROM orders;
SELECT COUNT(*) AS total_deliveries FROM deliveries;
SELECT service_type, COUNT(*) AS order_count FROM orders GROUP BY service_type ORDER BY order_count DESC;
SELECT is_active, COUNT(*) AS driver_count FROM drivers GROUP BY is_active ORDER BY driver_count DESC;
SELECT vehicle_type, COUNT(*) AS vehicle_count FROM vehicles GROUP BY vehicle_type ORDER BY vehicle_count DESC;
SELECT SUM(total_value) AS total_order_value FROM orders;
SELECT AVG(package_weight_kg) AS avg_package_weight_kg FROM orders;

-- Sprint 4.1: delivery demand.
SELECT delivery_zone_id, COUNT(*) AS orders_count, SUM(total_value) AS order_value
FROM orders GROUP BY delivery_zone_id ORDER BY orders_count DESC;
SELECT service_type, COUNT(*) AS orders_count, SUM(total_value) AS order_value
FROM orders GROUP BY service_type ORDER BY orders_count DESC;
SELECT priority, COUNT(*) AS orders_count FROM orders GROUP BY priority ORDER BY orders_count DESC;
SELECT DATE_FORMAT(order_date, '%Y-%m') AS order_month, COUNT(*) AS orders_count, SUM(total_value) AS order_value
FROM orders GROUP BY order_month ORDER BY order_month;

-- Sprint 4.2: customer order behaviour.
SELECT c.customer_id, c.customer_name, c.customer_type, COUNT(o.order_id) AS orders_count,
       SUM(o.total_value) AS lifetime_order_value
FROM customers c LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_type
ORDER BY orders_count DESC, lifetime_order_value DESC;
SELECT c.customer_type, COUNT(DISTINCT c.customer_id) AS customers,
       COUNT(o.order_id) AS orders_count, SUM(o.total_value) AS order_value,
       AVG(o.total_value) AS avg_order_value
FROM customers c LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_type ORDER BY order_value DESC;
SELECT c.delivery_zone_id, COUNT(DISTINCT c.customer_id) AS customers,
       COUNT(o.order_id) AS orders_count
FROM customers c LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.delivery_zone_id ORDER BY orders_count DESC;
SELECT DATE_FORMAT(order_date, '%Y-%m') AS order_month, COUNT(*) AS orders_count,
       COUNT(DISTINCT customer_id) AS active_customers
FROM orders GROUP BY order_month ORDER BY order_month;

-- Sprint 4.3: delivery performance. Keep each status as its own category.
SELECT o.delivery_zone_id, d.status, COUNT(*) AS delivery_records,
       COUNT(DISTINCT d.order_id) AS distinct_orders,
       AVG(d.delivery_duration_min) AS avg_duration_min
FROM orders o JOIN deliveries d ON d.order_id = o.order_id
GROUP BY o.delivery_zone_id, d.status ORDER BY o.delivery_zone_id, delivery_records DESC;
SELECT status, COUNT(*) AS delivery_records,
       COUNT(DISTINCT order_id) AS distinct_orders,
       AVG(delivery_duration_min) AS avg_duration_min
FROM deliveries GROUP BY status ORDER BY delivery_records DESC;
SELECT DATE_FORMAT(COALESCE(actual_delivery_date, assigned_date), '%Y-%m') AS activity_month,
       status, COUNT(*) AS delivery_records,
       AVG(delivery_duration_min) AS avg_duration_min
FROM deliveries GROUP BY activity_month, status ORDER BY activity_month, status;
SELECT service_type, status, COUNT(*) AS delivery_records,
       AVG(distance_km) AS avg_distance_km, AVG(delivery_duration_min) AS avg_duration_min
FROM orders o JOIN deliveries d ON d.order_id = o.order_id
GROUP BY service_type, status ORDER BY service_type, delivery_records DESC;

-- Sprint 4.4: driver and vehicle utilization/performance.
SELECT dr.driver_id, dr.driver_name, dr.rating, COUNT(d.delivery_id) AS deliveries_handled,
       SUM(d.status = 'Delivered') AS delivered_records,
       AVG(d.delivery_duration_min) AS avg_duration_min
FROM drivers dr LEFT JOIN deliveries d ON d.driver_id = dr.driver_id
GROUP BY dr.driver_id, dr.driver_name, dr.rating
ORDER BY deliveries_handled DESC;
SELECT v.vehicle_type, COUNT(d.delivery_id) AS deliveries,
       COUNT(DISTINCT v.vehicle_id) AS vehicles_used,
       SUM(d.status = 'Delivered') AS delivered_records,
       AVG(d.delivery_duration_min) AS avg_duration_min
FROM vehicles v LEFT JOIN deliveries d ON d.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type ORDER BY deliveries DESC;
SELECT v.vehicle_id, v.vehicle_type, v.fuel_type, COUNT(d.delivery_id) AS deliveries,
       SUM(d.status = 'Delivered') AS delivered_records,
       AVG(d.delivery_duration_min) AS avg_duration_min
FROM vehicles v LEFT JOIN deliveries d ON d.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_id, v.vehicle_type, v.fuel_type ORDER BY deliveries DESC;

-- Sprint 4.5: repeat attempts and delivery problems.
SELECT order_id, COUNT(*) AS delivery_records, MAX(delivery_attempt) AS max_attempt_number,
       SUM(status = 'Delivered') AS delivered_records,
       GROUP_CONCAT(DISTINCT status ORDER BY status) AS statuses_seen
FROM deliveries GROUP BY order_id
HAVING COUNT(*) > 1 OR MAX(delivery_attempt) > 1
ORDER BY max_attempt_number DESC, delivery_records DESC;
SELECT status, delivery_attempt, COUNT(*) AS delivery_records,
       AVG(delivery_duration_min) AS avg_duration_min
FROM deliveries GROUP BY status, delivery_attempt ORDER BY delivery_attempt, status;
SELECT o.delivery_zone_id, COUNT(*) AS delivery_records,
       SUM(d.status = 'Failed') AS failed_records,
       SUM(d.delivery_attempt > 1) AS repeat_attempt_records,
       ROUND(100 * SUM(d.status = 'Failed') / NULLIF(COUNT(*),0), 2) AS failed_record_pct
FROM orders o JOIN deliveries d ON d.order_id = o.order_id
GROUP BY o.delivery_zone_id ORDER BY failed_record_pct DESC;
SELECT o.package_weight_kg, AVG(d.delivery_duration_min) AS avg_duration_min,
       COUNT(*) AS delivery_records
FROM orders o JOIN deliveries d ON d.order_id = o.order_id
GROUP BY o.package_weight_kg ORDER BY o.package_weight_kg;

-- Read-only data-quality checks.
SELECT COUNT(*) AS orders_without_customer FROM orders o
LEFT JOIN customers c ON c.customer_id = o.customer_id WHERE c.customer_id IS NULL;
SELECT COUNT(*) AS deliveries_without_order FROM deliveries d
LEFT JOIN orders o ON o.order_id = d.order_id WHERE o.order_id IS NULL;
SELECT status, COUNT(*) AS records FROM deliveries GROUP BY status ORDER BY status;
SELECT @@local_infile AS local_infile_enabled;
