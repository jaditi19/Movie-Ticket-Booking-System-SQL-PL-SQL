/*
------------------------------------------------------------
		MOVIE TICKET BOOKING SYSTEM 
------------------------------------------------------------
*/


--CREATE TABLES

--MOVIE TABLE
CREATE TABLE Movie(
    movie_id     NUMBER PRIMARY KEY,
    movie_name   VARCHAR2(50),
    genre        VARCHAR2(30),
    duration_min NUMBER
);

--SCREEN TABLE
CREATE TABLE Screen(
    screen_id     NUMBER PRIMARY KEY,
    movie_id      NUMBER,
    total_seats   NUMBER,
    booked_seats  NUMBER DEFAULT 0,
    show_time     VARCHAR2(20),
    FOREIGN KEY(movie_id) REFERENCES Movie(movie_id)
);

--BOOKING TABLE
CREATE TABLE Booking(
    booking_id    NUMBER PRIMARY KEY,
    customer_name VARCHAR2(50),
    movie_id      NUMBER,
    screen_id     NUMBER,
    seats_booked  NUMBER,
    booking_date  DATE DEFAULT SYSDATE,
    FOREIGN KEY(movie_id) REFERENCES Movie(movie_id),
    FOREIGN KEY(screen_id) REFERENCES Screen(screen_id)
);


--INSERT SAMPLE DATA

INSERT INTO Movie VALUES (1, 'KGF 2', 'Action', 168);
INSERT INTO Movie VALUES (2, 'Chhichhore', 'Drama', 143);
INSERT INTO Movie VALUES (3, 'Avengers Endgame', 'Superhero', 181);

INSERT INTO Screen VALUES (101, 1, 100, 20, '10:00 AM');
INSERT INTO Screen VALUES (102, 2, 80, 10, '01:00 PM');
INSERT INTO Screen VALUES (103, 3, 150, 50, '04:00 PM');

--FUNCTION: AVAILABLE SEATS

CREATE OR REPLACE FUNCTION fn_available_seats(p_screen_id NUMBER)
RETURN NUMBER
IS
    v_avail NUMBER;
BEGIN
    SELECT (total_seats - booked_seats)
    INTO v_avail
    FROM Screen
    WHERE screen_id = p_screen_id;

    RETURN v_avail;
END;
/


--PROCEDURE: BOOK TICKET

CREATE OR REPLACE PROCEDURE book_ticket(
    p_booking_id   NUMBER,
    p_customer     VARCHAR2,
    p_movie_id     NUMBER,
    p_screen_id    NUMBER,
    p_seats        NUMBER
)
IS
    v_available NUMBER;
BEGIN
    -- check available seats
    v_available := fn_available_seats(p_screen_id);

    IF p_seats > v_available THEN
        DBMS_OUTPUT.PUT_LINE('❌ Not enough seats available!');
        DBMS_OUTPUT.PUT_LINE('Available seats: ' || v_available);
        RETURN;
    END IF;

    -- insert booking
    INSERT INTO Booking(booking_id, customer_name, movie_id, screen_id, seats_booked)
    VALUES(p_booking_id, p_customer, p_movie_id, p_screen_id, p_seats);

    -- update screen booked seats
    UPDATE Screen
    SET booked_seats = booked_seats + p_seats
    WHERE screen_id = p_screen_id;

    DBMS_OUTPUT.PUT_LINE('✅ Booking Successful!');
    DBMS_OUTPUT.PUT_LINE('Customer: ' || p_customer);
    DBMS_OUTPUT.PUT_LINE('Seats Booked: ' || p_seats);
END;
/


--SHOW AVAILABLE SEATS (QUERY)

SELECT 
    screen_id,
    movie_id,
    show_time,
    total_seats,
    booked_seats,
    (total_seats - booked_seats) AS available_seats
FROM Screen;
/

--Ticket Booking Execution
EXEC book_ticket(1, 'Aditi', 1, 101, 5);
EXEC book_ticket(2, 'Rahul', 1, 101, 3);
EXEC book_ticket(3, 'Sneha', 2, 102, 2);
EXEC book_ticket(4, 'Amit', 3, 103, 4);


--SHOW BOOKING HISTORY (QUERY)

SELECT 
    b.booking_id,
    b.customer_name,
    m.movie_name,
    b.seats_booked,
    TO_CHAR(b.booking_date, 'DD-MON-YYYY HH24:MI') AS booking_time,
    s.show_time
FROM Booking b
JOIN Movie m ON b.movie_id = m.movie_id
JOIN Screen s ON b.screen_id = s.screen_id
ORDER BY b.booking_date DESC;
/



