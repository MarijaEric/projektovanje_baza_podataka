
DROP DATABASE IF EXISTS vezbe;

CREATE DATABASE vezbe;

USE vezbe;
CREATE TABLE test_ocena(
    ime VARCHAR(20),
    prezime VARCHAR(20),
    ocena INT
);

-- Korišćenje okidača za održavanje integriteta

DELIMITER | 
CREATE TRIGGER test_ocena_okidac
BEFORE INSERT ON test_ocena 
FOR EACH ROW 
BEGIN
    IF new.ocena < 5 or new.ocena>10 THEN
        SIGNAL sqlstate '45000' SET message_text = 'Ocena mora biti izmedju 5 i 10';
    END IF;
END
| 

DELIMITER ;


INSERT INTO test_ocena VALUES
    ('Pera', 'Peric', 12);

select * from test_ocena;



