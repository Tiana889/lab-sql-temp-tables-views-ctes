
-- Crear una vista para resumir la información de alquiler por cliente
CREATE VIEW customer_rental_summary AS
SELECT c.customer_id, 
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       c.email, 
       COUNT(r.rental_id) AS rental_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, customer_name, c.email;

-- Crear una tabla temporal para calcular el total pagado por cada cliente
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT crs.customer_id, 
       SUM(p.amount) AS total_paid
FROM customer_rental_summary crs
JOIN payment p ON crs.customer_id = p.customer_id
GROUP BY crs.customer_id;

-- Crear una CTE para unir la vista de resumen de alquileres con la tabla temporal de pagos
WITH customer_summary AS (
    SELECT crs.customer_name, 
           crs.email, 
           crs.rental_count, 
           cps.total_paid,
           (cps.total_paid / crs.rental_count) AS average_payment_per_rental
    FROM customer_rental_summary crs
    JOIN customer_payment_summary cps ON crs.customer_id = cps.customer_id
)

-- Generar la consulta final del reporte de resumen de clientes
SELECT customer_name, 
       email, 
       rental_count, 
       total_paid, 
       ROUND(average_payment_per_rental, 2) AS average_payment_per_rental
FROM customer_summary;