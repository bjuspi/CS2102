﻿CREATE OR REPLACE FUNCTION gst(val NUMERIC) 
RETURNS NUMERIC AS
'BEGIN
RETURN val * 1.07;
END;'
LANGUAGE PLPGSQL;

SELECT gst(1);

SELECT g.name, gst(g.price) 
FROM games g
WHERE gst(g.price) < 5;

CREATE OR REPLACE FUNCTION hello() 
RETURNS CHAR(5) AS $$
BEGIN
RETURN 'Hello World';
END; $$
LANGUAGE PLPGSQL;

SELECT hello();

SELECT hello() FROM games g;

DROP FUNCTION hello();

CREATE OR REPLACE FUNCTION hello() 
RETURNS BOOLEAN AS $$
BEGIN
RAISE NOTICE 'hello';
RETURN TRUE;
END; $$
LANGUAGE PLPGSQL;

SELECT hello() FROM games g;

CREATE TABLE gst (gst NUMERIC);

INSERT INTO gst VALUES (7);

CREATE OR REPLACE FUNCTION gst(val NUMERIC) 
RETURNS NUMERIC AS $$
DECLARE gst1 NUMERIC;
BEGIN
SELECT g.gst/100 INTO gst1 FROM gst g;
RETURN val * (1 + gst1);
END; $$
LANGUAGE PLPGSQL;

SELECT g.name, gst(g.price)
FROM games g;

SELECT g.name, round(gst(g.price), 2) 
FROM games g;

CREATE OR REPLACE FUNCTION gst(val NUMERIC) 
RETURNS NUMERIC AS $$
DECLARE gst1 NUMERIC;
BEGIN
SELECT g.gst/100 INTO gst1 FROM gst g;
IF val * (1 + gst1) > 5 THEN
RETURN val * 1 + gst1;
ELSE
RETURN 5;
END IF;
END; $$
LANGUAGE PLPGSQL;

SELECT g.name, round(gst(g.price), 2)
FROM games g;

CREATE OR REPLACE FUNCTION avg1(appname VARCHAR(32)) RETURNS NUMERIC AS $$
DECLARE mycursor SCROLL CURSOR (vname VARCHAR(32)) FOR SELECT g.price FROM games g WHERE g.name=vname;
price NUMERIC; avgprice NUMERIC; count NUMERIC;
BEGIN
OPEN mycursor(vname:=appname);
avgprice:=0; count:=0; price:=0;
LOOP
	FETCH mycursor INTO price;
	EXIT WHEN NOT FOUND;
	avgprice:=avgprice + price; 	count:=count+1;
END LOOP;
CLOSE mycursor;
IF count<1 THEN RETURN null; 
ELSE RETURN round(avgprice/count,2); END IF;
END; $$
LANGUAGE PLPGSQL; 

SELECT avg1('Aerified');

SELECT name, avg1(name) 
FROM games g; 

SELECT g.name, round(AVG(g.price),2)
FROM games g 
GROUP BY g.name 
ORDER BY g.name;


DROP FUNCTION hello() CASCADE;

CREATE OR REPLACE FUNCTION hello() 
RETURNS TRIGGER AS $$
BEGIN
RAISE NOTICE 'hello';
RETURN NULL;
END; $$
LANGUAGE PLPGSQL;

CREATE TRIGGER hello 
BEFORE INSERT OR UPDATE 
ON games 
FOR EACH STATEMENT
EXECUTE PROCEDURE hello();

INSERT INTO games VALUES ('A', '5.1', 100), ('B', '3.0', 101), ('C', '3.0', 102);

SELECT * FROM games WHERE name='A' OR name='B' OR name='C';

DROP FUNCTION hello() CASCADE;

CREATE OR REPLACE FUNCTION hello() 
RETURNS TRIGGER AS $$
BEGIN
RAISE NOTICE 'hello';
RETURN NULL;
END; $$ LANGUAGE PLPGSQL;

CREATE TRIGGER hello 
BEFORE INSERT OR UPDATE 
ON games 
FOR EACH ROW
WHEN (NEW.price > 100) 
EXECUTE PROCEDURE hello();

INSERT INTO games VALUES ('AA', '5.1', 100), ('BB', '3.0', 101), ('CC', '3.0', 102);

SELECT * FROM games WHERE name='AA' OR name='BB' OR name='CC';

DROP FUNCTION hello() CASCADE;

CREATE OR REPLACE FUNCTION hello() 
RETURNS TRIGGER AS $$
BEGIN
RAISE NOTICE 'hello';
RETURN NEW;
END; $$ LANGUAGE PLPGSQL;

CREATE TRIGGER hello 
BEFORE INSERT OR UPDATE 
ON games 
FOR EACH ROW
WHEN (NEW.price > 100) 
EXECUTE PROCEDURE hello();

INSERT INTO games VALUES ('AAA', '5.1', 100), ('BBB', '3.0', 101), ('CCC', '3.0', 102); 

SELECT * FROM games WHERE name='AAA' OR name='BBB' OR name='CCC';

CREATE TABLE glog (name VARCHAR(32) NOT NULL, version CHAR(3)NOT NULL, pricebefore NUMERIC, priceafter NUMERIC NOT NULL, date DATE NOT NULL);

CREATE OR REPLACE FUNCTION pricelog() 
RETURNS TRIGGER AS $$
DECLARE delta NUMERIC;
DECLARE pb NUMERIC;
DECLARE now DATE;
BEGIN
now := now();
IF TG_OP ='INSERT' OR TG_OP ='UPDATE'
THEN pb:=null; ELSE pb:=OLD.price; END IF;
INSERT INTO glog VALUES (NEW.name, NEW.version, pb, NEW.price, now);
RETURN NULL;
END; $$
LANGUAGE PLPGSQL;

CREATE TRIGGER pricelog
AFTER INSERT OR UPDATE 
ON games 
FOR EACH ROW
EXECUTE PROCEDURE pricelog();

INSERT INTO games VALUES ('AAAA', '5.1', 100), ('BBBB', '3.0', 101), ('CCCC', '3.0', 102);

SELECT * FROM games WHERE name='AAAA' OR name='BBBB' OR name='CCCC';

SELECT * FROM glog;

UPDATE games SET price = 110 WHERE name='AAAA';

SELECT * FROM games WHERE name='AAAA';

SELECT * FROM glog;

CREATE OR REPLACE FUNCTION hello() 
RETURNS TRIGGER AS $$
BEGIN
RAISE NOTICE 'hello';
RETURN NULL;
END; $$ LANGUAGE PLPGSQL;


INSERT INTO games VALUES ('AAAA', '5.1', 120);


SELECT * FROM games WHERE name='AAAA';

SELECT * FROM glog;


DROP FUNCTION hello() CASCADE;

INSERT INTO games VALUES ('AAAA', '5.1', 130);


CREATE TABLE test1 (
father NUMERIC primary key NOT DEFERRABLE, 
son NUMERIC REFERENCES test1(father)NOT DEFERRABLE);

CREATE TABLE test2 (
father NUMERIC primary key NOT DEFERRABLE, 
son NUMERIC REFERENCES test2(father)DEFERRABLE INITIALLY DEFERRED);

BEGIN;
INSERT INTO test1 VALUES (1,2);
INSERT INTO test1 VALUES (2,1);
END;

END;

SELECT * FROM test1;

BEGIN;
INSERT INTO test2 VALUES (1,2);
INSERT INTO test2 VALUES (2,1);
END;

SELECT * FROM test2;

