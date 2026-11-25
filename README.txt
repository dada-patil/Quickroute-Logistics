SQL import copies

These CSVs are saved as plain ASCII so they avoid the MySQL Workbench ASCII decoding error shown in the screenshot. Column headers use lowercase snake_case. The source files were not changed.

To keep Workbench-compatible text, accented characters in names were transliterated (for example, Traore and Kone). Customers and drivers are the only files with affected values. For exact original spellings, use the original UTF-8 source files with a MySQL utf8mb4 import path.

Blank actual_delivery_date values are retained for deliveries that are not marked Delivered.
