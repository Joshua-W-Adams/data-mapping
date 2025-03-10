USE INTEGRITY_TEST;

LOAD DATA LOCAL INFILE "C:/repos/data-mapping/output/montara_fpso_topsides_data/map/LOOPS.CSV"
INTO TABLE LOOPS
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SHOW WARNINGS;

LOAD DATA LOCAL INFILE "C:/repos/data-mapping/output/montara_fpso_topsides_data/map/EQUIPMENT.CSV"
INTO TABLE EQUIPMENT
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SHOW WARNINGS;

LOAD DATA LOCAL INFILE "C:/repos/data-mapping/output/montara_fpso_topsides_data/map/DAMAGE_MECHANISM.CSV"
INTO TABLE DAMAGE_MECHANISM
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SHOW WARNINGS;

LOAD DATA LOCAL INFILE "C:/repos/data-mapping/output/montara_fpso_topsides_data/map/STRATEGY.CSV"
INTO TABLE STRATEGY
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SHOW WARNINGS;

LOAD DATA LOCAL INFILE "C:/repos/data-mapping/output/montara_fpso_topsides_data/map/CML.CSV"
INTO TABLE CML
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SHOW WARNINGS;

LOAD DATA LOCAL INFILE "C:/repos/data-mapping/output/montara_fpso_topsides_data/map/INSPECTION.CSV"
INTO TABLE INSPECTION
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SHOW WARNINGS;

LOAD DATA LOCAL INFILE "C:/repos/data-mapping/output/montara_fpso_topsides_data/map/GRID.CSV"
INTO TABLE GRID
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SHOW WARNINGS;
