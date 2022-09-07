CREATE DATABASE AIR_CARGO;
USE AIR_CARGO;

DESCRIBE AIR_CARGO.routes;

/*Write a query to create route_details table using suitable data types for the fields, such as route_id, flight_num, origin_airport, destination_airport, aircraft_id, and distance_miles.
Implement the check constraint for the flight number and unique constraint for the route_id fields. Also, make sure that the distance miles field is greater than 0.*/
CREATE TABLE IF NOT EXISTS AIR_CARGO.routes_details (
route_id INT NOT NULL UNIQUE,
flight_num INT NOT NULL,
origin_airport VARCHAR (100) NOT NULL,
destination_airport VARCHAR (100) NOT NULL,
aircraft_id VARCHAR (100) NOT NULL,
distance_miles INT NOT NULL CHECK (distance_miles > 0),
CONSTRAINT flight_num CHECK (flight_num > 0)
);

/*Write a query to display all the passengers (customers) who have travelled in routes 01 to 25. Take data  from the passengers_on_flights table.*/
SELECT*FROM AIR_CARGO.passengers_on_flights
WHERE route_id BETWEEN '01' AND '25'; 

/*Write a query to identify the number of passengers and total revenue in business class from the ticket_details table*/ 
SELECT COUNT(no_of_tickets) AS total_passengers, SUM((no_of_tickets)*(Price_per_ticket)) AS business_class_revenue
FROM AIR_CARGO.ticket_details
WHERE class_id = 'Business';

/*Write a query to display the full name of the customer by extracting the first name and last name from the customer table.*/
SELECT CONCAT(first_name, ' ', last_name) AS full_name 
FROM AIR_CARGO.customer;

/*Write a query to extract the customers who have registered and booked a ticket. Use data from the customer and ticket_details tables.*/
SELECT DISTINCT(customer_id), first_name, last_name
FROM AIR_CARGO.customer
INNER JOIN ticket_details USING (customer_id);

/*Write a query to identify the customer’s first name and last name based on their customer ID and brand (Emirates) from the ticket_details table.*/
SELECT first_name, last_name
FROM AIR_CARGO.customer
INNER JOIN ticket_details USING (customer_id)
WHERE brand = 'Emirates';

/*Write a query to identify the customers who have travelled by Economy Plus class using Group By and Having clause on the passengers_on_flights table*/
SELECT customer_id, route_id, class_id
FROM AIR_CARGO.passengers_on_flights
GROUP BY customer_id, route_id, class_id
HAVING class_id = 'Economy Plus';

/*Write a query to identify whether the revenue has crossed 10000 using the IF clause on the ticket_details table.*/
SELECT IF(SUM(no_of_tickets*price_per_ticket) > 10000, "Yes", "No")
FROM AIR_CARGO.ticket_details;

/*Write a query to create and grant access to a new user to perform operations on a database.*/
CREATE USER testuser@localhost 
IDENTIFIED BY 'testuser';

GRANT EXECUTE ON AIR_CARGO. *
TO testuser@localhost;

/*Write a query to find the maximum ticket price for each class using window functions on the ticket_details table.*/
SELECT p_date, customer_id, aircraft_id, class_id, no_of_tickets, a_code, brand, MAX(Price_per_ticket) OVER (PARTITION BY brand) AS Max_Ticket_Class_Price
FROM AIR_CARGO.ticket_details;

/*Write a query to extract the passengers whose route ID is 4 by improving the speed and performance of the passengers_on_flights table.*/
SELECT*FROM AIR_CARGO.passengers_on_flights
WHERE route_id = '4';

CREATE INDEX route_id_4 ON passengers_on_flights(route_id);
SELECT*FROM AIR_CARGO.passengers_on_flights 
WHERE route_id = '4';

/* For the route ID 4, write a query to view the execution plan of the passengers_on_flights table.*/
SELECT*FROM AIR_CARGO.passengers_on_flights
WHERE route_id = '4';

/*Write a query to calculate the total price of all tickets booked by a customer across different aircraft IDs using rollup function.*/
SELECT customer_id, SUM(price_per_ticket) as total_price, count(aircraft_id)
FROM AIR_CARGO.ticket_details
GROUP BY customer_id WITH ROLLUP;

/*Write a query to create a view with only business class customers along with the brand of airlines.*/
CREATE VIEW business_class_view AS
SELECT customer_id, class_id, brand
FROM AIR_CARGO.ticket_details
WHERE class_id = 'Business'
ORDER BY brand;

SELECT*FROM business_class_view;

/*Write a query to create a stored procedure to get the details of all passengers flying between a range of routes defined in run time. Also, return an error message if the table doesn't exist.*/
DELIMITER //
CREATE PROCEDURE routes_details
(IN route_id INT, 
OUT route_details VARCHAR (50))
BEGIN 
DECLARE route_id INT default 0; 
SELECT route_id INTO routes_details 
FROM AIR_CARGO.passengers_on_flights WHERE route_details = route_id; 
CASE routes_details 
WHEN route_id BETWEEN 1 AND 10 THEN SET route_details = 'route1to10';
WHEN route_id BETWEEN 10 AND 20 THEN SET route_details = 'route10to20';
WHEN route_id BETWEEN 20 AND 30 THEN SET route_details = 'route20to30';
WHEN route_id BETWEEN 30 AND 40 THEN SET route_details = 'route30to40';
WHEN route_id BETWEEN 40 AND 50 THEN SET route_details = 'route40to50';
END CASE;
END //

/*Write a query to create a stored procedure that extracts all the details from the routes table where the travelled distance is more than 2000 miles.*/
DELIMITER // 
CREATE PROCEDURE travelled_more_than_2000_miles()
BEGIN 
Select*FROM AIR_CARGO.routes_details
WHERE distance_miles > 2000;
END //

CALL travelled_more_than_2000_miles();

/*Write a query to create a stored procedure that groups the distance travelled by each flight into three categories. 
The categories are, short distance travel (SDT) for >=0 AND <= 2000 miles, intermediate distance travel (IDT) for >2000 AND <=6500, and long-distance travel (LDT) for >6500.*/
DELIMITER //
CREATE FUNCTION travelled_distance(distance_miles INT)
RETURNS VARCHAR(100) deterministic
BEGIN 
DECLARE travelled_distance VARCHAR (100);
IF distance_miles BETWEEN 0 AND 2000 THEN SET travelled_distance = 'Short Distance Travel (SDT)';
ELSEIF distance_miles BETWEEN 2000 AND 6500 THEN SET travelled_distance = 'Intermediate Distance Travel (IDT)';
ELSEIF distance_miles > 6500 THEN SET travelled_distance = 'Long-Distance Travel (LDT)';
END IF; 
RETURN (travelled_distance);
END //
DELIMITER //
SELECT route_id, flight_num, origin_airport, destination_airport, aircraft_id, travelled_distance (distance_miles) AS distance_miles
FROM AIR_CARGO.routes_details
ORDER BY distance_miles;

/*Write a query to extract ticket purchase date, customer ID, class ID and specify if the complimentary services are provided for the specific class 
using a stored function in stored procedure on the ticket_details table.
Condition: If the class is Business and Economy Plus, then complimentary services are given as Yes, else it is No.*/
DELIMITER //
CREATE FUNCTION complimentary_services (class_id VARCHAR (100)) 
RETURNS VARCHAR(100) deterministic 
BEGIN 
DECLARE complimentary_services VARCHAR(100); 
IF class_id = 'Business' THEN SET complimentary_services = 'Yes';
ELSEIF class_id = 'Economy Plus' THEN SET complimentary_services = 'Yes';  
ELSEIF class_id = 'Economy' THEN SET complimentary_services = 'No';
ELSEIF class_id = 'First Class' THEN SET complimentary_services = 'No';
END IF; 
RETURN (complimentary_services); 
END // 
DELIMITER // 
SELECT p_date, customer_id, class_id, complimentary_services(class_id) AS complimentary_services 
FROM AIR_CARGO.ticket_details;

/*Write a query to extract the first record of the customer whose last name ends with Scott using a cursor from the customer table.*/
DELIMITER //
CREATE PROCEDURE my_cursor ()
BEGIN
DECLARE a VARCHAR (100);
DECLARE b VARCHAR (100);
DECLARE my_cursor CURSOR FOR SELECT last_name, first_name FROM AIR_CARGO.customer 
WHERE last_name = 'Scott'; 
OPEN my_cursor; 
REPEAT FETCH my_cursor INTO a,b;
UNTIL b = 0 END REPEAT; 
SELECT a AS last_name, b AS first_name; 
CLOSE my_cursor; END;
// DELIMITER ;

CALL my_cursor();