/*
AUTHOR: JOSHUA WILLIAM ADAMS
REV HISTORY:
NO.: A     DESC.: ISSUED FOR REVIEW                             DATE: 02/02/2018
NO.: 0     DESC.: ISSUED FOR USE.                               DATE: 24/04/2018

DESCRIPTION: SQL SCRIPT TO BUILD THE SOLIDINTEGRITY GENERIC DATABASE ON A MYSQL
             SERVER. CREATES ALL TABLES (DEFINES FIELDS, DATATYPES AND PKS/FKS),
						 ALL REVISION HISTORY TABLES, ALL TRIGGERS (CHANGE TRACKING AND DATA
						 INTEGRITY) AND LOADS ALL DATA INTO SYSTEM.

*/

-- CREATE DATABASE
DROP DATABASE IF EXISTS INTEGRITY_TEST;
CREATE DATABASE INTEGRITY_TEST;

-- SET CREATED DATABASE AS CONTEXT SO FULL NAMES DO NOT NEED TO BE USED
USE INTEGRITY_TEST;

-- ENSURE TRIGGERS ARE ENABLED ON SERVER
SET @disable_triggers = NULL;

/*
CREATE TABLES AND SET DATATYPES

NOTES:
	- LOOKUP TABLES TO BE ADDED FIRST SO FOREIGN KEY CONSTRAINTS CAN BE ASSIGNED
	CORRECTLY.
	- PRIMARY KEYS ARE INDEXED BY DEFAULT. NO OTHER INDEXES REQUIRED.
	- INDEX FIELDS TO INCREASE PERFORMANCE. REDUCES NUMBER OF ACCESSES (N) FROM N
	TO LOG2(N) I.E. AN EXPONENTIAL DECREASE. APPLYING THESE INDEXES TO PRIMARY KEY
	FIELDS ALSO REMOVES THE REQUIREMENT FOR THE SYSTEM TO SEARCH FOR DUPLICATES
	- INDEXES ONLY INCREASE THE DISK SPACE REQUIRED OF THE DATABASE.
	- ALL DATABASE SEARCHING SHOULD ALWAYS BE DONE ON AN INDEXED FIELD.
*/

CREATE TABLE ASSOCIATION
(	/*FIELD NAME*/   /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`    VARCHAR(30) NOT NULL,
	`LOOP_ID`        VARCHAR(30) NOT NULL,
	`ASSOCIATION`    VARCHAR(30),

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, LOOP_ID, ASSOCIATION)

) ENGINE=INNODB;

CREATE TABLE COLOUR_CODING
(	/*FIELD NAME*/   /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`    VARCHAR(30) NOT NULL,
	`DESCRIPTION`    VARCHAR(50) NOT NULL,
	`VALUE`          FLOAT,

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, DESCRIPTION)

) ENGINE=INNODB;

CREATE TABLE API_574_STRUCTURAL_THICKNESS
(	/*FIELD NAME*/                          /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                           VARCHAR(30) NOT NULL,
	`NOMINAL_DIAMETER`                      FLOAT NOT NULL,
	`MINIMUM_ALLOWABLE_WALL_THICKNESS_MM`   FLOAT,

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, NOMINAL_DIAMETER)

) ENGINE=INNODB;

CREATE TABLE POF
(	/*FIELD NAME*/                   /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                    VARCHAR(30) NOT NULL,
	`CML_TYPE`                       VARCHAR(160) NOT NULL,
	`POF_COLUMN`                     VARCHAR(50) NOT NULL,
	`VALUE_RANGE`                    VARCHAR(50) NOT NULL,
	`POF`                            TINYINT,
	`COLOUR_CODE`                    VARCHAR(10),
	`DROPDOWN_COLUMN_NAME`           VARCHAR(100),

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, CML_TYPE, POF_COLUMN, VALUE_RANGE)

) ENGINE=INNODB;

CREATE TABLE RISK_MAPPING
(	/*FIELD NAME*/                   /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                    VARCHAR(30) NOT NULL,
	`RISK_MATRIX`                    VARCHAR(5) NOT NULL,
	`RISK_SCORE`                     TINYINT NOT NULL,
	`CRITICALITY`                    VARCHAR(50) NOT NULL,
	`INSPECTION_INTERVAL`            FLOAT,

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, RISK_MATRIX, RISK_SCORE)

) ENGINE=INNODB;

CREATE TABLE CUI_MAPPING
(	/*FIELD NAME*/                   /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                    VARCHAR(30) NOT NULL,
	`DESCRIPTION`                    VARCHAR(120) NOT NULL,
	`FIELD_NAME`                     VARCHAR(50),
	`CUI_VALUE`                      TINYINT,

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, DESCRIPTION)

) ENGINE=INNODB;

CREATE TABLE STATUSES
(	/*FIELD NAME*/                 /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                  VARCHAR(30) NOT NULL,
	`STATUS`                       CHAR(1) NOT NULL,
	`DESCRIPTION`                  VARCHAR(50) NOT NULL,

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, STATUS)

) ENGINE=INNODB;

CREATE TABLE INSPECTION_STATUSES
(	/*FIELD NAME*/                    /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                     VARCHAR(30) NOT NULL,
	`INSPECTION_STATUS`               CHAR(1) NOT NULL,
	`DESCRIPTION`                     VARCHAR(50) NOT NULL,

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, INSPECTION_STATUS)

) ENGINE=INNODB;

CREATE TABLE ACTION_STATUSES
(	/*FIELD NAME*/                   /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                    VARCHAR(30) NOT NULL,
	`ACTION_STATUS`                  CHAR(2) NOT NULL,
	`DESCRIPTION`                    VARCHAR(50) NOT NULL,

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, ACTION_STATUS)

) ENGINE=INNODB;

CREATE TABLE DAMAGE_MECHANISM_ID_LIST
(	/*FIELD NAME*/                   /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                    VARCHAR(30) NOT NULL,
	`DAMAGE_MECHANISM_ID`            VARCHAR(50) NOT NULL,

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, DAMAGE_MECHANISM_ID)

) ENGINE=INNODB;

CREATE TABLE STRATEGY_ID_LIST
(	/*FIELD NAME*/                   /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                    VARCHAR(30) NOT NULL,
	`STRATEGY_ID`                    VARCHAR(50) NOT NULL,

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, STRATEGY_ID)

) ENGINE=INNODB;

CREATE TABLE TABLE_CONFIGURATION
(	/*FIELD NAME*/                              /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                               VARCHAR(30) NOT NULL,
  `TABLE_NAME`                                VARCHAR(50) NOT NULL,
	`COLUMN_NAME`                               VARCHAR(100) NOT NULL,
  `DESCRIPTION`                               TEXT,
  `ALIGNMENT`                                 ENUM('LEFT', 'MIDDLE', 'RIGHT') DEFAULT 'LEFT' NOT NULL,
  `WIDTH`                                     SMALLINT,
	`DATA_TYPE`                                 VARCHAR(50),
	`DATA_FORMAT`                               VARCHAR(20),
  `DROPDOWN_LIST`                             TEXT,
  `CALCULATED`                                BOOLEAN,
	`HYPERLINK_LOCATION`                        TEXT,
	`HYPERLINK_FILE_EXTENSION`                  VARCHAR(10),
	`GROUP`                                     VARCHAR(30),

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, TABLE_NAME, COLUMN_NAME)

) ENGINE=INNODB;

CREATE TABLE VIEWS
(	/*FIELD NAME*/                   /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                    VARCHAR(30) NOT NULL,
  `VIEW_NAME`                      VARCHAR(50) NOT NULL,

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, VIEW_NAME)

) ENGINE=INNODB;

CREATE TABLE VIEW_CONFIGURATION
(	/*FIELD NAME*/                   /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                    VARCHAR(30) NOT NULL,
  `VIEW_NAME`                      VARCHAR(50) NOT NULL,
  `TABLE_NAME`                     VARCHAR(100) NOT NULL,
	`COLUMN_NAME`                    VARCHAR(100) NOT NULL,
  `NEW_COLUMN_NAME`                VARCHAR(100) NOT NULL,
  `HIDDEN`                         ENUM('YES', 'NO') DEFAULT 'NO' NOT NULL,
	`WRAP_TEXT`                      ENUM('YES', 'NO') DEFAULT 'NO' NOT NULL,
  `DISPLAY_ORDER`                  TINYINT NOT NULL,
  `NESTED_HEADER`                  VARCHAR(100),

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, VIEW_NAME, TABLE_NAME, COLUMN_NAME),
	FOREIGN KEY (FACILITY_ID, TABLE_NAME, COLUMN_NAME) REFERENCES TABLE_CONFIGURATION(FACILITY_ID, TABLE_NAME, COLUMN_NAME),
	FOREIGN KEY (FACILITY_ID, VIEW_NAME) REFERENCES VIEWS(FACILITY_ID, VIEW_NAME) ON UPDATE CASCADE

  /*UNIQUE COLUMN DEFINITIONS*/
  -- UNIQUE (VIEW_NAME, TABLE_NAME, NEW_COLUMN_NAME)

) ENGINE=INNODB;

CREATE TABLE FORM_FIELDS
(	/*FIELD NAME*/                   /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                    VARCHAR(30) NOT NULL,
  `FORM_ID`                        VARCHAR(50) NOT NULL,
  `FIELD_ID`                       VARCHAR(100) NOT NULL,
	`NAME`                           VARCHAR(100) NOT NULL,
	`TYPE`                           VARCHAR(100) NOT NULL,
	`DESCRIPTION`                    VARCHAR(100),
  `VALUES_QUERY`                   TEXT,
	`DISPLAY_ORDER`                  SMALLINT NOT NULL,

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, FORM_ID, FIELD_ID)

) ENGINE=INNODB;

CREATE TABLE TEMPLATE_VARIABLES
(	/*FIELD NAME*/                   /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                    VARCHAR(30) NOT NULL,
  `TEMPLATE_ID`                    VARCHAR(50) NOT NULL,
  `VARIABLE_ID`                    VARCHAR(100) NOT NULL,
	`VARIABLE_TYPE`                  VARCHAR(50) NOT NULL,
	`TEMPLATE_TYPE`                  VARCHAR(100) NOT NULL,
  `VALUES_QUERY`                   TEXT NOT NULL,
	`TEMPLATE_INSERT_TABLE_NAME`     VARCHAR(100),
	`TEMPLATE_INSERT_TABLE_XY`       VARCHAR(10),
	`FILE_FOLDER`                    VARCHAR(10),

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, TEMPLATE_ID, VARIABLE_ID),
	FOREIGN KEY (FACILITY_ID, TEMPLATE_ID) REFERENCES FORM_FIELDS(FACILITY_ID, FORM_ID) ON UPDATE CASCADE

) ENGINE=INNODB;

CREATE TABLE DOCUMENT_INPUTS
(	/*FIELD NAME*/                   /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                    VARCHAR(30) NOT NULL,
  `DOCUMENT_ID`                    VARCHAR(50) NOT NULL,
  `REV_ID`                         VARCHAR(3) NOT NULL,
	`INPUT_ID`											 VARCHAR(100) NOT NULL,
	`TEMPLATE_ID`                    VARCHAR(50) NOT NULL,
  `VALUE`                          TEXT,

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, DOCUMENT_ID, REV_ID, INPUT_ID),
	FOREIGN KEY (FACILITY_ID, TEMPLATE_ID) REFERENCES FORM_FIELDS(FACILITY_ID, FORM_ID) ON UPDATE CASCADE

) ENGINE=INNODB;

CREATE TABLE CML_TYPES
(	/*FIELD NAME*/                   /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                    VARCHAR(30) NOT NULL,
	`CML_TYPE`                       VARCHAR(160) NOT NULL,
	`VIEW_NAME`                      VARCHAR(50) NOT NULL,
	`TYPE_GROUP`                     ENUM('THICKNESS', 'VISUAL') DEFAULT 'VISUAL' NOT NULL,
	`CALCULATE_ACTIONS`              ENUM('YES','NO') DEFAULT 'YES' NOT NULL,
	`ACTIONS_RL_LIMIT`               FLOAT,
	`ACTIONS_CRITICALITY_LIMIT`      FLOAT,

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, CML_TYPE),
	FOREIGN KEY (FACILITY_ID, VIEW_NAME) REFERENCES VIEWS(FACILITY_ID, VIEW_NAME) ON UPDATE CASCADE,

	-- KEYS REQUIRED FOR FOREIGN KEY DEFINITIONS WITH OTHER TABLES
	KEY (FACILITY_ID, CML_TYPE, TYPE_GROUP),
	KEY (FACILITY_ID, CML_TYPE, VIEW_NAME)

) ENGINE=INNODB;

CREATE TABLE ACTIONS
(	/*FIELD NAME*/                   /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                    VARCHAR(30) NOT NULL,
  `ACTION_ID`                      MEDIUMINT NOT NULL,
  `ACTION_STATUS`                  CHAR(3) NOT NULL,
	`ACTION_TYPE`                    VARCHAR(15),
	`ACTION_NAME`                    VARCHAR(50),
  `ACTION_DETAILS`                 TEXT,
  `WORK_ORDER_REF`                 VARCHAR(50),
  `WORK_ORDER_STATUS`              VARCHAR(50),
	`PRIORITY`                       VARCHAR(50),
	`LOOP_ID`                        VARCHAR(30),
	`EQUIPMENT_ID`                   VARCHAR(30),
	`DAMAGE_MECHANISM_ID`            VARCHAR(50),
	`STRATEGY_ID`                    VARCHAR(50),
	`CML_ID`                         VARCHAR(20),
	`CML_TYPE`                       VARCHAR(160),
	`AREA`                           VARCHAR(50),
	`RESPONSIBLE_SYSTEM`             VARCHAR(30),
	`SAFETY_CRITICAL`                ENUM('YES','NO'),
	`RESPONSIBLE`                    VARCHAR(50),

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, ACTION_ID),
	FOREIGN KEY (FACILITY_ID, ACTION_STATUS) REFERENCES ACTION_STATUSES(FACILITY_ID, ACTION_STATUS) ON UPDATE CASCADE

) ENGINE=INNODB;

CREATE TABLE LOOPS
(	/*FIELD NAME*/                                 /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                                  VARCHAR(30) NOT NULL,
	`LOOP_ID`																			 VARCHAR(30) NOT NULL,
	`LOOP_TYPE`																		 VARCHAR(100),
	`LOOP_DESCRIPTION`													   VARCHAR(100),
	`STATUS`																			 CHAR(1),
	`INSPECTION_STATUS`                            VARCHAR(10),
	`ACTION_STATUS`                                VARCHAR(10),
	`MIN_REMAINING_LIFE`                           FLOAT,
	`MAX_ACR`                                      FLOAT,
	`END_OF_LIFE`                                  DATE,
	`POF_MIN`                                      TINYINT,
	`CRITICALITY_MAX`                              VARCHAR(10),
	`STATUTORY_INSPECTION_EXTERNAL`                FLOAT,
	`STATUTORY_INSPECTION_INTERNAL`                FLOAT,
	`AREA`                                         VARCHAR(50),
	`COMMENTS`                                     TEXT,
	`COF_SAFETY`                                   TINYINT,
	`COF_HEALTH`                                   TINYINT,
	`COF_ENVIRONMENT`                              TINYINT,
	`COF_ASSETS`                                   TINYINT,
	`MAX_COF`                                      TINYINT,
	`COF_COMMENTS`                                 TEXT,
	`HAZARD_LEVEL`                                 CHAR(1),
	`ASSOC_PSVS`                                   VARCHAR(50),
	`ASSOC_LOOPS`                                  VARCHAR(50),
	`SAFETY_CRITICAL`                              ENUM('YES','NO') DEFAULT 'NO',
	`RBI_REPORT_NUMBER`                            VARCHAR(50),
	`RBI_WORKSHOP_DATE`                            DATE,
	`RBI_WORKSHOP_INTERVAL`                        FLOAT,
	`RBI_WORKSHOP_NEXT_DUE_DATE`                   DATE,
	`RBI_LAST_DONE_DATE`	                         DATE,
	`RBI_INTERVAL`	                               FLOAT,
	`RBI_LAST_DONE_DESCRIPTION`                    TEXT,
	`RBI_SUMMARY`                                  TEXT,
	`ERROR_CODE`                                   VARCHAR(5),
	`COLOUR_CODE`                                  VARCHAR(10),
	`RESPONSIBLE_SYSTEM`                           VARCHAR(30),
	`INSPECTION_STRATEGY`                          ENUM('HALF LIFE','RBI','STATUTORY') DEFAULT NULL,
	`RISK_MATRIX`                                  VARCHAR(5),

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, LOOP_ID),
	FOREIGN KEY (FACILITY_ID) REFERENCES SERVER.FACILITIES(FACILITY_ID) ON UPDATE CASCADE

) ENGINE=INNODB;

CREATE TABLE INTEGRITY_SUMMARY
(	/*FIELD NAME*/                   /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                    VARCHAR(30) NOT NULL,
	`LOOP_ID`                        VARCHAR(30) NOT NULL,
	`DATE`                           DATE,
	`BRIEF`                          TEXT,
	`NOTES`                          TEXT,

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, LOOP_ID, `DATE`),
	FOREIGN KEY (FACILITY_ID, LOOP_ID) REFERENCES LOOPS(FACILITY_ID, LOOP_ID) ON UPDATE CASCADE

) ENGINE=INNODB;

CREATE TABLE EQUIPMENT
(	/*FIELD NAME*/                                 /*DATA TYPE AND RESTRICTIONS*/
	-- GENERIC FIELDS
	`FACILITY_ID`                                  VARCHAR(30) NOT NULL,
	`EQUIPMENT_ID`                                 VARCHAR(30) NOT NULL,
	`LOOP_ID`                                      VARCHAR(30) NOT NULL,
	`EQUIP_DESCRIPTION`                            VARCHAR(100),
	`STATUS`                                       CHAR(1),
	`INSPECTION_STATUS`                            VARCHAR(10),
	`ACTION_STATUS`                                VARCHAR(10),
	`MIN_REMAINING_LIFE`                           FLOAT,
	`MAX_ACR`                                      FLOAT,
	`END_OF_LIFE`                                  DATE,
	`POF_MIN`                                      TINYINT,
	`CRITICALITY_MAX`                              VARCHAR(10),
	`AREA`                                         VARCHAR(50),
	`CONTENTS`                                     VARCHAR(30),
	`COMMENTS`                                     TEXT,
	`CORROSION_ALLOWANCE_MM`                       FLOAT,
	`CONSTRUCTION_CODE`                            VARCHAR(20),
	`DESIGN_PRESSURE_MPA`                          FLOAT,
	`DESIGN_TEMPERATURE_DEGC`                      FLOAT,
	`MAXIMUM_ALLOWABLE_OPERATING_PRESSURE_MPA`     FLOAT,
	`MAXIMUM_ALLOWABLE_OPERATING_TEMPERATURE_DEGC` FLOAT,
	`OPERATING_PRESSURE_MPA`                       FLOAT,
	`OPERATING_TEMP_DEGC`                          FLOAT,
	`JOINT_EFFICIENCY`                             FLOAT,
	`HAZARD_LEVEL`                                 CHAR(1),
	`INSTALLATION_YEAR`                            DATE,
	`INTERNAL_COATING`                             ENUM('YES','NO') DEFAULT NULL,
	`EXTERNAL_COATING`                             ENUM('YES','NO') DEFAULT NULL,
	`EXTERNAL_INSULATION`                          ENUM('YES','NO') DEFAULT NULL,
	`PID`                                          VARCHAR(100),
	`DRAWING_REF`                                  TEXT,
	`DESIGN_LIFE`                                  FLOAT,
	`COF_MODIFIER`                                 TINYINT,
	`CYCLIC_SERVICE`                               VARCHAR(20),
	`SHUTDOWN_REQUIREMENT`                         VARCHAR(30),
	`ERROR_CODE`                                   VARCHAR(5),
	`COLOUR_CODE`                                  VARCHAR(10),
	`RESPONSIBLE_SYSTEM`                           VARCHAR(30),

	-- PIPING SPECIFIC FIELDS
	`EQUIP_FROM`                                   VARCHAR(50),
	`EQUIP_TO`                                     VARCHAR(50),
	`MATERIAL_SPEC_PIPING`                         VARCHAR(20),
	`MATERIAL_STRENGTH_PIPING_MPA`                 FLOAT,

	-- VESSEL SPECIFIC FIELDS
	`MATERIAL_SPEC_SHELL`                          VARCHAR(20),
	`MATERIAL_STRENGTH_SHELL_MPA`                  FLOAT,
	`MATERIAL_SPEC_VESSEL_ENDS`                    VARCHAR(20),
	`MATERIAL_STRENGTH_VESSEL_ENDS_MPA`            FLOAT,
	`MATERIAL_SPEC_NOZZLES`                        VARCHAR(20),
	`MATERIAL_STRENGTH_NOZZLES_MPA`                FLOAT,
	`MATERIAL_SPEC_CONICAL_SECTION`                VARCHAR(20),
	`MATERIAL_STRENGTH_CONICAL_SECTION_MPA`        FLOAT,
	`CAPACITY_L`                                   FLOAT,
	`CONTENTS_CLASS`                               VARCHAR(10),
	`MANUFACTURER`                                 VARCHAR(50),
	`MANUFACTURE_DATE`                             DATE,
	`SERIAL_NO`                                    VARCHAR(20),
	`INTERNAL_ANODES`                              ENUM('YES','NO') DEFAULT NULL,

	-- TANK SPECIFIC FIELDS
	`TANK_DIAMETER_M`                              FLOAT,
	`TANK_HEIGHT_M`                                FLOAT,
	`TANK_DESIGN_LIQUID_LEVEL_M`                   FLOAT,
	`CONTENTS_SPECIFIC_GRAVITY`                    FLOAT,
	`MATERIAL_SPEC_ROOF`                           VARCHAR(20),
	`MATERIAL_STRENGTH_ROOF`                       FLOAT,
	`MATERIAL_SPEC_FLOOR`                          VARCHAR(20),
	`MATERIAL_STRENGTH_FLOOR`                      FLOAT,
	`ROOF_TYPE`                                    VARCHAR(50),
	`FLOOR_TYPE`                                   VARCHAR(50),
	`CORROSION_ALLOWANCE_FLOOR_MM`                 FLOAT,
	`CORROSION_ALLOWANCE_SHELL_MM`                 FLOAT,
	`CORROSION_ALLOWANCE_ROOF_MM`                  FLOAT,
	`NUMBER_OF_SHELL_COURSES`                      TINYINT,

	-- PSV SPECIFIC FIELDS
	`PSV_TYPE`                                     VARCHAR(50),
	`RELIEF_CASE`                                  ENUM('Thermal','Blocked Outlet','Fire','HP/LP Interface'),
	`PSV_STRATEGY`                                 VARCHAR(30),
	`STOCK_NUMBER`                                 VARCHAR(30),
	`MODEL`	                                       VARCHAR(30),
	`INLET_SIZE`                                   VARCHAR(20),
	`OUTLET_SIZE`                                  VARCHAR(20),
	`INLET_CONNECTION`                             VARCHAR(30),
	`OUTLET_CONNECTION`                            VARCHAR(30),
	`SET_PRESSURE_MPA`                             FLOAT,

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, EQUIPMENT_ID),
	FOREIGN KEY (FACILITY_ID, LOOP_ID) REFERENCES LOOPS(FACILITY_ID, LOOP_ID) ON UPDATE CASCADE

) ENGINE=INNODB;

CREATE TABLE DAMAGE_MECHANISM
(	/*FIELD NAME*/                   /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                     VARCHAR(30) NOT NULL,
	`LOOP_ID`                         VARCHAR(30) NOT NULL,
	`DAMAGE_MECHANISM_ID`             VARCHAR(50) NOT NULL,
	`STRATEGY_ID`                     TEXT,
	`DESCRIPTION`                     VARCHAR(50),
	`ACTION_STATUS`                   VARCHAR(10),
	`MIN_REMAINING_LIFE`              FLOAT,
	`MAX_ACR`                         FLOAT,
	`END_OF_LIFE`                     DATE,
	`POF_MIN`                         TINYINT,
	`CRITICALITY_MAX`                 VARCHAR(10),
	`CREDIBLE`                        ENUM('YES','NO') NOT NULL,
	`CREDIBLE_NOTES`                  TEXT,
	`STRATEGY_NOTES`                  TEXT,
	`ERROR_CODE`                      VARCHAR(5),
	`COLOUR_CODE`                     VARCHAR(10),
	`RESPONSIBLE_SYSTEM`              VARCHAR(30),

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, LOOP_ID, DAMAGE_MECHANISM_ID),
	FOREIGN KEY (FACILITY_ID, LOOP_ID) REFERENCES LOOPS(FACILITY_ID, LOOP_ID) ON UPDATE CASCADE,
	FOREIGN KEY (FACILITY_ID, DAMAGE_MECHANISM_ID) REFERENCES DAMAGE_MECHANISM_ID_LIST(FACILITY_ID, DAMAGE_MECHANISM_ID)

) ENGINE=INNODB;

CREATE TABLE STRATEGY
(	/*FIELD NAME*/                                              /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                                               VARCHAR(30) NOT NULL,
	`LOOP_ID`                                                   VARCHAR(30) NOT NULL,
	`STRATEGY_ID`                                               VARCHAR(50) NOT NULL,
	`DAMAGE_MECHANISM_ID`                                       TEXT,
	`DESCRIPTION`                                               VARCHAR(50),
	`STRATEGY_SUMMARY`                                          VARCHAR(50),
	`STATUS`                                                    CHAR(1),
	`ACTION_STATUS`                                             VARCHAR(10),
	`MIN_REMAINING_LIFE`                                        FLOAT,
	`MAX_ACR`                                                   FLOAT,
	`END_OF_LIFE`                                               DATE,
	`POF_MIN`                                                   TINYINT,
	`CRITICALITY_MAX`                                           VARCHAR(10),
	`MIN_INSPECTION_INTERVAL`                                   FLOAT,
	`MITIGATION_EFFECTIVENESS_FACTOR`                           FLOAT,
	`ADJUSTED_MIN_INSPECTION_INTERVAL`                          FLOAT,
	`COMMENTS_ADJUSTED_MIN_INSPECTION_INTERVAL`                 TEXT,
	`STATUTORY_INSPECTION_INTERVAL`                             FLOAT,
	`APPLIED_INSPECTION_INTERVAL`                               FLOAT,
	`APPLIED_INSPECTION_INTERVAL_COMMENTS`                      TEXT,
	`LAST_INSPECTION_DATE`                                      DATE,
	`NEXT_INSPECTION_DATE`                                      DATE,
	`LAST_INSPECTION_REPORT_NO`                                 VARCHAR(50),
	`ERROR_CODE`                                                VARCHAR(5),
	`COLOUR_CODE`                                               VARCHAR(10),
	`RESPONSIBLE_SYSTEM`                                        VARCHAR(30),

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, STRATEGY_ID, LOOP_ID),
	FOREIGN KEY (FACILITY_ID, LOOP_ID) REFERENCES LOOPS(FACILITY_ID, LOOP_ID) ON UPDATE CASCADE,
	FOREIGN KEY (FACILITY_ID, STRATEGY_ID) REFERENCES STRATEGY_ID_LIST(FACILITY_ID, STRATEGY_ID)

) ENGINE=INNODB;

CREATE TABLE CML
(	/*FIELD NAME*/                                       /*DATA TYPE AND RESTRICTIONS*/
	-- GENERIC FIELDS FOR ALL CML TABLES
	`FACILITY_ID`                                        VARCHAR(30) NOT NULL,
	`LOOP_ID`                                            VARCHAR(30) NOT NULL,
	`EQUIPMENT_ID`                                       VARCHAR(30) NOT NULL,
	`CML_ID`                                             VARCHAR(20) NOT NULL,
	`DAMAGE_MECHANISM_ID`                                VARCHAR(50) NOT NULL,
	`STRATEGY_ID`                                        VARCHAR(50) NOT NULL,
	`CML_TYPE`                                           VARCHAR(160),
	`DESCRIPTION`                                        TEXT,
	`POF_COLUMN`                                         VARCHAR(50),
	`STATUS`                                             CHAR(1),
	`INSPECTION_STATUS`                                  VARCHAR(10),
	`ACTION_STATUS`                                      VARCHAR(10),
	`SELECTED_REMAINING_LIFE_YRS`                        FLOAT,
	`SELECTED_END_OF_LIFE`                               DATE,
	`POF`                                                TINYINT,
	`COF`                                                TINYINT,
	`CRITICALITY`                                        VARCHAR(10),
	`SELECTED_INSPECTION_INTERVAL`                       FLOAT,
	`CML_COMMENTS`                                       TEXT,
	`LAST_INSPECTION_REPORT_NO`                          VARCHAR(50),
	`LAST_INSPECTION_DATE`                               DATE,
	`NEXT_INSPECTION_DATE`                               DATE,
	`PHOTO`                                              MEDIUMINT,
	`TEMPORARY_REPAIR_INSTALLED`                         ENUM('YES','NO'),
	`TEMPORARY_REPAIR_INSTALLED_COMMENTS`                TEXT,
	`TEMPORARY_REPAIR_DATE`                              DATE,
	`ESTIMATED_DURATION`                                 FLOAT,
	`EQUIPMENT_ACCESS_REQUIREMENTS`                      TEXT,
	`INSPECTION_CODE`                                    VARCHAR(50),
  `VIEW_NAME`                                          VARCHAR(50),
	`EXACT_MATCH`                                        VARCHAR(100),
	`CLOSEST_MATCH`                                      VARCHAR(100),
	`ERROR_CODE`                                         VARCHAR(5),
	`COLOUR_CODE`                                        VARCHAR(10),
	`RESPONSIBLE_SYSTEM`                                 VARCHAR(30),

	-- SPECIFIC FIELDS FOR WALL LOSS ASSESSMENTS
	`ND_MM`                                              FLOAT,
	`OD_MM`                                              FLOAT,
	`MD_MM`                                              FLOAT,
	`NWT_MM`                                             FLOAT,
	`MIN_RWT_MM`                                         FLOAT,
	`D_CONICAL_SECTION_MM`                               FLOAT,
	`ANGLE_OF_SLOPE`                                     FLOAT,
	`DEPTH_OF_LOSS_FROM_NWT_MM`                          FLOAT,
	`WALL_LOSS_PERCENTAGE`                               FLOAT,
	`ACTUAL_CALCULATED_CR_MM_YR`                         FLOAT,
	`MAX_CALCULATED_CR_MM_YR`                            FLOAT,
	`LOOP_MAXIMUM_CORROSION_RATE`                        FLOAT,
	`ACR_MM_YR`                                          FLOAT,
	`APPLIED_CORROSION_RATE_NOTES_AND_ENTERED_BY`        TEXT,
	`MAWT_BASED_ON_CA_MM`                                FLOAT,
	`MAWT_BASED_ON_DP_MM`                                FLOAT,
	`MAWT_BASED_ON_MAOP_MM`                              FLOAT,
	`MAWT_BASED_ON_STRUCT_MM`                            FLOAT,
	`MAWT_MANUAL`                                        FLOAT,
	`RL_BASED_ON_CA_YRS`                                 FLOAT,
	`RL_BASED_ON_DP_YRS`                                 FLOAT,
	`RL_BASED_ON_MAOP_YRS`                               FLOAT,
	`RL_BASED_ON_STRUCT_YRS`                             FLOAT,
	`RL_BASED_ON_MANUAL_YRS`                             FLOAT,
	`EOL_BASED_ON_CA`                                    DATE,
	`EOL_BASED_ON_DP`                                    DATE,
	`EOL_BASED_ON_MAOP`                                  DATE,
	`EOL_BASED_ON_STRUCT`                                DATE,
	`EOL_BASED_ON_MANUAL`                                DATE,
	`SELECTED_MAWT_CRITERIA`                             ENUM('CA','DP','MAOP','MANUAL') DEFAULT NULL,
	`LIMITING_MAWT_CRITERIA`                             ENUM('CA','DP','MAOP','STRUCT','MANUAL') DEFAULT NULL,
	`MAWT_SELECTED_MM`                                   FLOAT,
	`LR_LD`                                              FLOAT,
	`DEGRADATION_MECHANISM_IS_PREDICTABLE`               FLOAT,
	`RELIABLE_MONITORING_OF_ANY_RELEVANT_DETERIORATION`  FLOAT,
	`MULTIPLE_EFFECTIVE_INSPECTIONS_PERFORMED`           FLOAT,
	`CONFIDENCE_SCORE`                                   FLOAT,
	`CONFIDENCE_RATING`                                  VARCHAR(10),
	`INSPECTION_INTERVAL_FACTOR`                         FLOAT,
	`STRUCTURAL_CONCERN`                                 ENUM('YES','NO') DEFAULT NULL,
  `STRUCTURAL_CONCERN_VALID_TO`                        DATE,
	`STRUCTURAL_CONCERN_COMMENTS`                        TEXT,
	`TECHNICAL_DEVIATION_REQUIRED`                       ENUM('YES','NO') DEFAULT NULL,
	`UTM_ZONE`                                           VARCHAR(4),
	`UTM_EASTING`                                        DOUBLE,
	`UTM_NORTHING`                                       DOUBLE,
	`HALF_LIFE`                                          FLOAT,
	`RBI_INSPECTION_INTERVAL`                            FLOAT,
	`STATUTORY_INSPECTION_INTERVAL`                      FLOAT,
	`RISK_LOOKUP_INSPECTION_INTERVAL`                    FLOAT,

	-- SPECIFIC FIELDS FOR CUI ASSESSMENTS
	`CUI_VALUE`                                          TINYINT,

	-- SPECIFIC FIELDS FOR PSV ASSESSMENTS
	`PSV_CRITICALITY`                                    CHAR(4),
	`PSV_INLET`                                          VARCHAR(30),
	`PSV_OUTLET`                                         VARCHAR(30),

	-- SPECIFIC FIELDS FOR PIPELINE ASSESSMENTS
	`MAX_WALL_LOSS_PERCENTAGE`                           FLOAT,

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, EQUIPMENT_ID, CML_ID),
	FOREIGN KEY (FACILITY_ID, LOOP_ID, EQUIPMENT_ID) REFERENCES EQUIPMENT(FACILITY_ID, LOOP_ID, EQUIPMENT_ID) ON UPDATE CASCADE,
	FOREIGN KEY (FACILITY_ID, LOOP_ID, DAMAGE_MECHANISM_ID) REFERENCES DAMAGE_MECHANISM(FACILITY_ID, LOOP_ID, DAMAGE_MECHANISM_ID) ON UPDATE CASCADE,
	FOREIGN KEY (FACILITY_ID, LOOP_ID, STRATEGY_ID) REFERENCES STRATEGY(FACILITY_ID, LOOP_ID, STRATEGY_ID) ON UPDATE CASCADE,
	FOREIGN KEY (FACILITY_ID, CML_TYPE, VIEW_NAME) REFERENCES CML_TYPES(FACILITY_ID, CML_TYPE, VIEW_NAME),
	FOREIGN KEY (FACILITY_ID, CML_TYPE, POF_COLUMN) REFERENCES POF(FACILITY_ID, CML_TYPE, POF_COLUMN),
	FOREIGN KEY (FACILITY_ID, STATUS) REFERENCES STATUSES(FACILITY_ID, STATUS),

	-- KEY TO ALLOW CASCADING UPDATES INTO INSPECTION TABLE
	KEY (FACILITY_ID, LOOP_ID, EQUIPMENT_ID, DAMAGE_MECHANISM_ID, STRATEGY_ID, CML_ID)

) ENGINE=INNODB;

CREATE TABLE INSPECTION
(	/*FIELD NAME*/                                     /*DATA TYPE AND RESTRICTIONS*/
	-- GENERIC FIELDS
	`FACILITY_ID`                                      VARCHAR(30) NOT NULL,
	`LOOP_ID`                                          VARCHAR(30) NOT NULL,
	`EQUIPMENT_ID`                                     VARCHAR(30) NOT NULL,
	`CML_ID`                                           VARCHAR(20) NOT NULL,
	`INSPECTION_ID`                                    TINYINT NOT NULL,
	`STRATEGY_ID`                                      VARCHAR(50) NOT NULL,
	`DAMAGE_MECHANISM_ID`                              VARCHAR(50) NOT NULL,
	`INSPECTION_STATUS`                                CHAR(1),
	`ACTION_STATUS`                                    CHAR(1),
	`INSPECTION_DATE`                                  DATE,
	`INSPECTION_REPORT_NUMBER`                         VARCHAR(50),
	`CML_TYPE`                                         VARCHAR(160),
	`SCOPE_COMMENTS`                                   VARCHAR(25),
	`PRELIMINARY_RECOMMENDATIONS`                      ENUM('YES','NO') DEFAULT NULL,
	`INSPECTION_SCOPE`                                 VARCHAR(25),
	`WORK_ORDER`                                       VARCHAR(25),
	`INSPECTOR_NAME`                                   VARCHAR(100),
	`INPECTION_COMPANY`                                VARCHAR(15),
	`PHOTO`                                            MEDIUMINT NOT NULL,
	`INSPECTION_COMMENTS`                              TEXT,
	`EXACT_MATCH`                                      VARCHAR(100),
	`CLOSEST_MATCH`                                    VARCHAR(100),
	`ERROR_CODE`                                       VARCHAR(5),
	`COLOUR_CODE`                                      VARCHAR(10),
	`RESPONSIBLE_SYSTEM`                               VARCHAR(30),

	-- SPECIFIC FIELDS FOR INSPECTION_WALL_LOSS TABLE
	`NOMINAL_WALL_THICKNESS_MM`                        FLOAT,
	`MANUAL_MIN_RWT`                                   FLOAT,
	`MIN_REMAINING_WALL_THICKNESS_MM`                  FLOAT,
	`WALL_LOSS_MM`                                     FLOAT,
	`SERVICE_YEARS`                                    FLOAT,
	`CORROSION_RATE_SHORT_TERM_MM_YR`                  FLOAT,
	`CORROSION_RATE_LONG_TERM_MM_YR`                   FLOAT,

	-- SPECIFIC FIELDS FOR CUI INSPECTIONS
	`OPERATING_TEMPERATURE`                            VARCHAR(35),
	`COATING_CONDITION`                                VARCHAR(100),
	`INSULATION_CONDITION`                             VARCHAR(100),
	`INSULATION_TYPE`                                  VARCHAR(75),
	`HEAT_TRACING`                                     VARCHAR(45),
	`EXTERNAL_ENVIRONMENT`                             VARCHAR(120),
	`CUI_VALUE`                                        TINYINT,

	-- SPECIFIC FIELDS FOR PSV INSPECTIONS
	`PSV_ASSOC_EQUIP_HAZ_D_OR_E`                       ENUM('YES','NO'),
	`PSV_CAN_OVER_PRESSURE`														 ENUM('YES','NO'),
	`PSV_DESIGN_CASE`														       ENUM('Thermal','Blocked Outlet','Fire','HP/LP Interface'),
	`PSV_EQUIP_FAIL_REPORT_INCIDENT`									 ENUM('YES','NO'),
	`PSV_COF`                       									 CHAR(4),
	`PSV_FAIL_TO_DANGER`                       				 ENUM('YES','NO'),
	`PSV_NEW_APP_TYPE_SERVICE`                       	 ENUM('YES','NO'),
	`PSV_FAIL_NOT_TO_DANGER`                       		 ENUM('YES','NO'),
  `PSV_FAIL_LAST_THREE`                              ENUM('YES','NO'),
	`PSV_POF`                       									 CHAR(4),
	`PSV_MAY_FAIL_IF_INTERVAL_INCREASED`               ENUM('YES','NO'),
	`PSV_INTVL_CHANGE_ALLOW`                           VARCHAR(22),
  `APPLIED_PSV_INSPECTION_INTERVAL`                  FLOAT,
  `APPLIED_PSV_INSPECTION_INTERVAL_COMMENTS`         TEXT,

	-- SPECIFIC FIELDS FOR GRID INSPECTIONS
	`GRID_MIN_RWT`                                     FLOAT,
	`AVERAGE_WT`                                       FLOAT,
	`COUNT_10_PERCENT_LOSS`                            INT,
  `COUNT_20_PERCENT_LOSS`                            INT,
	`COUNT_30_PERCENT_LOSS`                            INT,
	`COUNT_40_PERCENT_LOSS`                            INT,
	`COUNT_50_PERCENT_LOSS`                            INT,
	`COUNT_60_PERCENT_LOSS`                            INT,
	`COUNT_70_PERCENT_LOSS`                            INT,
	`COUNT_80_PERCENT_LOSS`                            INT,
	`COUNT_90_PERCENT_LOSS`                            INT,
	`COUNT_100_PERCENT_LOSS`                           INT,

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, EQUIPMENT_ID, CML_ID, INSPECTION_ID),
	FOREIGN KEY (FACILITY_ID, LOOP_ID, EQUIPMENT_ID, DAMAGE_MECHANISM_ID, STRATEGY_ID, CML_ID) REFERENCES CML(FACILITY_ID, LOOP_ID, EQUIPMENT_ID, DAMAGE_MECHANISM_ID, STRATEGY_ID, CML_ID) ON UPDATE CASCADE,
	FOREIGN KEY (FACILITY_ID, INSPECTION_STATUS) REFERENCES INSPECTION_STATUSES(FACILITY_ID, INSPECTION_STATUS),

	-- KEY TO ALLOW FK AND CASCADING UPDATES INTO GRID TABLE
	KEY (FACILITY_ID, LOOP_ID, EQUIPMENT_ID, CML_ID, INSPECTION_ID)

) ENGINE=INNODB;

CREATE TABLE GRID
(	/*FIELD NAME*/                                     /*DATA TYPE AND RESTRICTIONS*/
	-- GENERIC FIELDS
	`FACILITY_ID`                                      VARCHAR(30) NOT NULL,
	`LOOP_ID`                                          VARCHAR(30) NOT NULL,
	`EQUIPMENT_ID`                                     VARCHAR(30) NOT NULL,
	`CML_ID`                                           VARCHAR(20) NOT NULL,
	`INSPECTION_ID`                                    TINYINT NOT NULL,
	-- DOUBLE REQUIRED FOR X AND Y TO ENSURE JOIN QUERIES ON EXACT NUMBERS
	-- WORK CORRECTLY
  `X`                                                DOUBLE NOT NULL,
	`Y`                                                DOUBLE NOT NULL,
  `RWT`                                              DOUBLE,
	`INTERNAL`                                         VARCHAR(50),
	`EXTERNAL`                                         VARCHAR(50),
	`FEATURE`                                          TEXT,
	`X_REF`                                            VARCHAR(50),
	`Y_REF`                                            VARCHAR(50),

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, EQUIPMENT_ID, CML_ID, INSPECTION_ID, X, Y),
	FOREIGN KEY (FACILITY_ID, LOOP_ID, EQUIPMENT_ID, CML_ID, INSPECTION_ID) REFERENCES INSPECTION(FACILITY_ID, LOOP_ID, EQUIPMENT_ID, CML_ID, INSPECTION_ID) ON UPDATE CASCADE

) ENGINE=INNODB;

/*
CREATE CHANGE HISTORY TABLES
*/
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'ASSOCIATION', 'FACILITY_ID, LOOP_ID, ASSOCIATION, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'COLOUR_CODING', 'FACILITY_ID, DESCRIPTION, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'API_574_STRUCTURAL_THICKNESS', 'FACILITY_ID, NOMINAL_DIAMETER, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'CML_TYPES', 'FACILITY_ID, CML_TYPE, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'POF', 'FACILITY_ID, CML_TYPE, POF_COLUMN, VALUE_RANGE, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'RISK_MAPPING', 'FACILITY_ID, RISK_MATRIX, RISK_SCORE, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'CUI_MAPPING', 'FACILITY_ID, DESCRIPTION, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'STATUSES', 'FACILITY_ID, STATUS, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'INSPECTION_STATUSES', 'FACILITY_ID, INSPECTION_STATUS, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'ACTION_STATUSES', 'FACILITY_ID, ACTION_STATUS, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'DAMAGE_MECHANISM_ID_LIST', 'FACILITY_ID, DAMAGE_MECHANISM_ID, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'STRATEGY_ID_LIST', 'FACILITY_ID, STRATEGY_ID, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'TABLE_CONFIGURATION', 'FACILITY_ID, TABLE_NAME, COLUMN_NAME, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'VIEWS', 'FACILITY_ID, VIEW_NAME, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'VIEW_CONFIGURATION', 'FACILITY_ID, VIEW_NAME, TABLE_NAME, COLUMN_NAME, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'FORM_FIELDS', 'FACILITY_ID, FORM_ID, FIELD_ID, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'TEMPLATE_VARIABLES', 'FACILITY_ID, TEMPLATE_ID, VARIABLE_ID, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'DOCUMENT_INPUTS', 'FACILITY_ID, DOCUMENT_ID, REV_ID, INPUT_ID, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'ACTIONS', 'FACILITY_ID, ACTION_ID, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'LOOPS', 'FACILITY_ID, LOOP_ID, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'INTEGRITY_SUMMARY', 'FACILITY_ID, LOOP_ID, DATE, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'EQUIPMENT', 'FACILITY_ID, EQUIPMENT_ID, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'DAMAGE_MECHANISM', 'FACILITY_ID, LOOP_ID, DAMAGE_MECHANISM_ID, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'STRATEGY', 'FACILITY_ID, STRATEGY_ID, LOOP_ID, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'CML', 'FACILITY_ID, EQUIPMENT_ID, CML_ID, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'INSPECTION', 'FACILITY_ID, EQUIPMENT_ID, CML_ID, INSPECTION_ID, REVISION', NULL, NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'GRID', 'FACILITY_ID, EQUIPMENT_ID, CML_ID, INSPECTION_ID, X, Y, REVISION', NULL, NULL);

/*
CREATE TRIGGERS

NOTES:
	- TRIGGER LOGIC IS AS FOLLOWS:
	    BEFORE TRIGGERS ARE FOR ENSURING DATA INTEGRITY.
	    AFTER TRIGGERS ARE FOR RECORDING CHANGE HISTORY.
	- PREPARE STATEMENT DOES NOT SUPPORT THE CREATE TRIGGER STATEMENT. THEREFORE
	  TRIGGERS MUST BE MADE MANUALLY
*/

-- DELIMITER CHANGE REQUIRED SO BEGIN / END STATEMENTS CAN BE DEFINED
DELIMITER $$

CREATE TRIGGER ASSOCIATION_REV_HISTORY_AI
AFTER INSERT ON ASSOCIATION
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO ASSOCIATION_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM ASSOCIATION_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND LOOP_ID = NEW.LOOP_ID AND ASSOCIATION = NEW.ASSOCIATION), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM ASSOCIATION AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.LOOP_ID = NEW.LOOP_ID AND D.ASSOCIATION = NEW.ASSOCIATION
													);
		END IF;
	END$$

CREATE TRIGGER ASSOCIATION_REV_HISTORY_AU
AFTER UPDATE ON ASSOCIATION
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO ASSOCIATION_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM ASSOCIATION_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND LOOP_ID = NEW.LOOP_ID AND ASSOCIATION = NEW.ASSOCIATION), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM ASSOCIATION AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.LOOP_ID = NEW.LOOP_ID AND D.ASSOCIATION = NEW.ASSOCIATION
													);
		END IF;
	END$$

CREATE TRIGGER ASSOCIATION_REV_HISTORY_BD
BEFORE DELETE ON ASSOCIATION
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO ASSOCIATION_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM ASSOCIATION_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND LOOP_ID = OLD.LOOP_ID AND ASSOCIATION = OLD.ASSOCIATION), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM ASSOCIATION AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.LOOP_ID = OLD.LOOP_ID AND D.ASSOCIATION = OLD.ASSOCIATION
													);
		END IF;
	END$$

CREATE TRIGGER COLOUR_CODING_REV_HISTORY_AI
AFTER INSERT ON COLOUR_CODING
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO COLOUR_CODING_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM COLOUR_CODING_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND DESCRIPTION = NEW.DESCRIPTION), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM COLOUR_CODING AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.DESCRIPTION = NEW.DESCRIPTION
													);
		END IF;
	END$$

CREATE TRIGGER COLOUR_CODING_REV_HISTORY_AU
AFTER UPDATE ON COLOUR_CODING
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO COLOUR_CODING_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM COLOUR_CODING_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND DESCRIPTION = NEW.DESCRIPTION), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM COLOUR_CODING AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.DESCRIPTION = NEW.DESCRIPTION
													);
		END IF;
	END$$

CREATE TRIGGER COLOUR_CODING_REV_HISTORY_BD
BEFORE DELETE ON COLOUR_CODING
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO COLOUR_CODING_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM COLOUR_CODING_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND DESCRIPTION = OLD.DESCRIPTION), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM COLOUR_CODING AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.DESCRIPTION = OLD.DESCRIPTION
													);
		END IF;
	END$$

CREATE TRIGGER API_574_STRUCTURAL_THICKNESS_REV_HISTORY_AI
AFTER INSERT ON API_574_STRUCTURAL_THICKNESS
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO API_574_STRUCTURAL_THICKNESS_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM API_574_STRUCTURAL_THICKNESS_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND NOMINAL_DIAMETER = NEW.NOMINAL_DIAMETER), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM API_574_STRUCTURAL_THICKNESS AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.NOMINAL_DIAMETER = NEW.NOMINAL_DIAMETER
													);
		END IF;
	END$$

CREATE TRIGGER API_574_STRUCTURAL_THICKNESS_REV_HISTORY_AU
AFTER UPDATE ON API_574_STRUCTURAL_THICKNESS
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO API_574_STRUCTURAL_THICKNESS_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM API_574_STRUCTURAL_THICKNESS_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND NOMINAL_DIAMETER = NEW.NOMINAL_DIAMETER), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM API_574_STRUCTURAL_THICKNESS AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.NOMINAL_DIAMETER = NEW.NOMINAL_DIAMETER
													);
		END IF;
	END$$

CREATE TRIGGER API_574_STRUCTURAL_THICKNESS_REV_HISTORY_BD
BEFORE DELETE ON API_574_STRUCTURAL_THICKNESS
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO API_574_STRUCTURAL_THICKNESS_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM API_574_STRUCTURAL_THICKNESS_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND NOMINAL_DIAMETER = OLD.NOMINAL_DIAMETER), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM API_574_STRUCTURAL_THICKNESS AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.NOMINAL_DIAMETER = OLD.NOMINAL_DIAMETER
													);
		END IF;
	END$$

CREATE TRIGGER CML_TYPES_REV_HISTORY_AI
AFTER INSERT ON CML_TYPES
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO CML_TYPES_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM CML_TYPES_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND CML_TYPE = NEW.CML_TYPE), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM CML_TYPES AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.CML_TYPE = NEW.CML_TYPE
													);
		END IF;
	END$$

CREATE TRIGGER CML_TYPES_REV_HISTORY_AU
AFTER UPDATE ON CML_TYPES
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO CML_TYPES_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM CML_TYPES_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND CML_TYPE = NEW.CML_TYPE), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM CML_TYPES AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.CML_TYPE = NEW.CML_TYPE
													);
		END IF;
	END$$

CREATE TRIGGER CML_TYPES_REV_HISTORY_BD
BEFORE DELETE ON CML_TYPES
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO CML_TYPES_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM CML_TYPES_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND CML_TYPE = OLD.CML_TYPE), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM CML_TYPES AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.CML_TYPE = OLD.CML_TYPE
													);
		END IF;
	END$$

CREATE TRIGGER POF_REV_HISTORY_AI
AFTER INSERT ON POF
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO POF_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM POF_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND CML_TYPE = NEW.CML_TYPE AND POF_COLUMN = NEW.POF_COLUMN AND VALUE_RANGE = NEW.VALUE_RANGE), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM POF AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.CML_TYPE = NEW.CML_TYPE AND D.POF_COLUMN = NEW.POF_COLUMN AND D.VALUE_RANGE = NEW.VALUE_RANGE
													);
		END IF;
	END$$

CREATE TRIGGER POF_REV_HISTORY_AU
AFTER UPDATE ON POF
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO POF_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM POF_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND CML_TYPE = NEW.CML_TYPE AND POF_COLUMN = NEW.POF_COLUMN AND VALUE_RANGE = NEW.VALUE_RANGE), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM POF AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.CML_TYPE = NEW.CML_TYPE AND D.POF_COLUMN = NEW.POF_COLUMN AND D.VALUE_RANGE = NEW.VALUE_RANGE
													);
		END IF;
	END$$

CREATE TRIGGER POF_REV_HISTORY_BD
BEFORE DELETE ON POF
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO POF_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM POF_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND CML_TYPE = OLD.CML_TYPE AND POF_COLUMN = OLD.POF_COLUMN AND VALUE_RANGE = OLD.VALUE_RANGE), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM POF AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.CML_TYPE = OLD.CML_TYPE AND D.POF_COLUMN = OLD.POF_COLUMN AND D.VALUE_RANGE = OLD.VALUE_RANGE
													);
		END IF;
	END$$

CREATE TRIGGER RISK_MAPPING_REV_HISTORY_AI
AFTER INSERT ON RISK_MAPPING
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO RISK_MAPPING_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM RISK_MAPPING_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND RISK_MATRIX = NEW.RISK_MATRIX AND RISK_SCORE = NEW.RISK_SCORE), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM RISK_MAPPING AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.RISK_MATRIX = NEW.RISK_MATRIX AND D.RISK_SCORE = NEW.RISK_SCORE
													);
		END IF;
	END$$

CREATE TRIGGER RISK_MAPPING_REV_HISTORY_AU
AFTER UPDATE ON RISK_MAPPING
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO RISK_MAPPING_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM RISK_MAPPING_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND RISK_MATRIX = NEW.RISK_MATRIX AND RISK_SCORE = NEW.RISK_SCORE), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM RISK_MAPPING AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.RISK_MATRIX = NEW.RISK_MATRIX AND D.RISK_SCORE = NEW.RISK_SCORE
													);
		END IF;
	END$$

CREATE TRIGGER RISK_MAPPING_REV_HISTORY_BD
BEFORE DELETE ON RISK_MAPPING
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO RISK_MAPPING_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM RISK_MAPPING_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND RISK_MATRIX = OLD.RISK_MATRIX AND RISK_SCORE = OLD.RISK_SCORE), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM RISK_MAPPING AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND RISK_MATRIX = OLD.RISK_MATRIX AND D.RISK_SCORE = OLD.RISK_SCORE
													);
		END IF;
	END$$

CREATE TRIGGER CUI_MAPPING_REV_HISTORY_AI
AFTER INSERT ON CUI_MAPPING
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO CUI_MAPPING_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM CUI_MAPPING_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND DESCRIPTION = NEW.DESCRIPTION), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM CUI_MAPPING AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.DESCRIPTION = NEW.DESCRIPTION
													);
		END IF;
	END$$

CREATE TRIGGER CUI_MAPPING_REV_HISTORY_AU
AFTER UPDATE ON CUI_MAPPING
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO CUI_MAPPING_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM CUI_MAPPING_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND DESCRIPTION = NEW.DESCRIPTION), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM CUI_MAPPING AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.DESCRIPTION = NEW.DESCRIPTION
													);
		END IF;
	END$$

CREATE TRIGGER CUI_MAPPING_REV_HISTORY_BD
BEFORE DELETE ON CUI_MAPPING
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO CUI_MAPPING_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM CUI_MAPPING_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND DESCRIPTION = OLD.DESCRIPTION), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM CUI_MAPPING AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.DESCRIPTION = OLD.DESCRIPTION
													);
		END IF;
	END$$

CREATE TRIGGER STATUSES_REV_HISTORY_AI
AFTER INSERT ON STATUSES
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO STATUSES_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM STATUSES_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND STATUS = NEW.STATUS), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM STATUSES AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.STATUS = NEW.STATUS
													);
		END IF;
	END$$

CREATE TRIGGER STATUSES_REV_HISTORY_AU
AFTER UPDATE ON STATUSES
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO STATUSES_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM STATUSES_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND STATUS = NEW.STATUS), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM STATUSES AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.STATUS = NEW.STATUS
													);
		END IF;
	END$$

CREATE TRIGGER STATUSES_REV_HISTORY_BD
BEFORE DELETE ON STATUSES
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO STATUSES_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM STATUSES_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND STATUS = OLD.STATUS), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM STATUSES AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.STATUS = OLD.STATUS
													);
		END IF;
	END$$

CREATE TRIGGER INSPECTION_STATUSES_REV_HISTORY_AI
AFTER INSERT ON INSPECTION_STATUSES
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO INSPECTION_STATUSES_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM INSPECTION_STATUSES_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND INSPECTION_STATUS = NEW.INSPECTION_STATUS), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM INSPECTION_STATUSES AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.INSPECTION_STATUS = NEW.INSPECTION_STATUS
													);
		END IF;
	END$$

CREATE TRIGGER INSPECTION_STATUSES_REV_HISTORY_AU
AFTER UPDATE ON INSPECTION_STATUSES
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO INSPECTION_STATUSES_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM INSPECTION_STATUSES_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND INSPECTION_STATUS = NEW.INSPECTION_STATUS), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM INSPECTION_STATUSES AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.INSPECTION_STATUS = NEW.INSPECTION_STATUS
													);
		END IF;
	END$$

CREATE TRIGGER INSPECTION_STATUSES_REV_HISTORY_BD
BEFORE DELETE ON INSPECTION_STATUSES
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO INSPECTION_STATUSES_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM INSPECTION_STATUSES_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND INSPECTION_STATUS = OLD.INSPECTION_STATUS), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM INSPECTION_STATUSES AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.INSPECTION_STATUS = OLD.INSPECTION_STATUS
													);
		END IF;
	END$$

CREATE TRIGGER ACTION_STATUSES_REV_HISTORY_AI
AFTER INSERT ON ACTION_STATUSES
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO ACTION_STATUSES_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM ACTION_STATUSES_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND ACTION_STATUS = NEW.ACTION_STATUS), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM ACTION_STATUSES AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.ACTION_STATUS = NEW.ACTION_STATUS
													);
		END IF;
	END$$

CREATE TRIGGER ACTION_STATUSES_REV_HISTORY_AU
AFTER UPDATE ON ACTION_STATUSES
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO ACTION_STATUSES_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM ACTION_STATUSES_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND ACTION_STATUS = NEW.ACTION_STATUS), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM ACTION_STATUSES AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.ACTION_STATUS = NEW.ACTION_STATUS
													);
		END IF;
	END$$

CREATE TRIGGER ACTION_STATUSES_REV_HISTORY_BD
BEFORE DELETE ON ACTION_STATUSES
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO ACTION_STATUSES_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM ACTION_STATUSES_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND ACTION_STATUS = OLD.ACTION_STATUS), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM ACTION_STATUSES AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.ACTION_STATUS = OLD.ACTION_STATUS
													);
		END IF;
	END$$

CREATE TRIGGER DAMAGE_MECHANISM_ID_LIST_REV_HISTORY_AI
AFTER INSERT ON DAMAGE_MECHANISM_ID_LIST
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO DAMAGE_MECHANISM_ID_LIST_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM DAMAGE_MECHANISM_ID_LIST_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND DAMAGE_MECHANISM_ID = NEW.DAMAGE_MECHANISM_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM DAMAGE_MECHANISM_ID_LIST AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.DAMAGE_MECHANISM_ID = NEW.DAMAGE_MECHANISM_ID
													);
		END IF;
	END$$

CREATE TRIGGER DAMAGE_MECHANISM_ID_LIST_REV_HISTORY_AU
AFTER UPDATE ON DAMAGE_MECHANISM_ID_LIST
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO DAMAGE_MECHANISM_ID_LIST_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM DAMAGE_MECHANISM_ID_LIST_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND DAMAGE_MECHANISM_ID = NEW.DAMAGE_MECHANISM_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM DAMAGE_MECHANISM_ID_LIST AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND  D.DAMAGE_MECHANISM_ID = NEW.DAMAGE_MECHANISM_ID
													);
		END IF;
	END$$

CREATE TRIGGER DAMAGE_MECHANISM_ID_LIST_REV_HISTORY_BD
BEFORE DELETE ON DAMAGE_MECHANISM_ID_LIST
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO DAMAGE_MECHANISM_ID_LIST_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM DAMAGE_MECHANISM_ID_LIST_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND DAMAGE_MECHANISM_ID = OLD.DAMAGE_MECHANISM_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM DAMAGE_MECHANISM_ID_LIST AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.DAMAGE_MECHANISM_ID = OLD.DAMAGE_MECHANISM_ID
													);
		END IF;
	END$$

CREATE TRIGGER STRATEGY_ID_LIST_REV_HISTORY_AI
AFTER INSERT ON STRATEGY_ID_LIST
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO STRATEGY_ID_LIST_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM STRATEGY_ID_LIST_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND STRATEGY_ID = NEW.STRATEGY_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM STRATEGY_ID_LIST AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.STRATEGY_ID = NEW.STRATEGY_ID
													);
		END IF;
	END$$

CREATE TRIGGER STRATEGY_ID_LIST_REV_HISTORY_AU
AFTER UPDATE ON STRATEGY_ID_LIST
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO STRATEGY_ID_LIST_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM STRATEGY_ID_LIST_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND STRATEGY_ID = NEW.STRATEGY_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM STRATEGY_ID_LIST AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.STRATEGY_ID = NEW.STRATEGY_ID
													);
		END IF;
	END$$

CREATE TRIGGER STRATEGY_ID_LIST_REV_HISTORY_BD
BEFORE DELETE ON STRATEGY_ID_LIST
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO STRATEGY_ID_LIST_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM STRATEGY_ID_LIST_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND STRATEGY_ID = OLD.STRATEGY_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM STRATEGY_ID_LIST AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.STRATEGY_ID = OLD.STRATEGY_ID
													);
		END IF;
	END$$

CREATE TRIGGER TABLE_CONFIGURATION_REV_HISTORY_AI
AFTER INSERT ON TABLE_CONFIGURATION
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO TABLE_CONFIGURATION_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM TABLE_CONFIGURATION_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND TABLE_NAME = NEW.TABLE_NAME AND COLUMN_NAME = NEW.COLUMN_NAME), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM TABLE_CONFIGURATION AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.TABLE_NAME = NEW.TABLE_NAME AND D.COLUMN_NAME = NEW.COLUMN_NAME
													);
		END IF;
	END$$

CREATE TRIGGER TABLE_CONFIGURATION_REV_HISTORY_AU
AFTER UPDATE ON TABLE_CONFIGURATION
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO TABLE_CONFIGURATION_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM TABLE_CONFIGURATION_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND TABLE_NAME = NEW.TABLE_NAME AND COLUMN_NAME = NEW.COLUMN_NAME), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM TABLE_CONFIGURATION AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.TABLE_NAME = NEW.TABLE_NAME AND D.COLUMN_NAME = NEW.COLUMN_NAME
													);
		END IF;
	END$$

CREATE TRIGGER TABLE_CONFIGURATION_REV_HISTORY_BD
BEFORE DELETE ON TABLE_CONFIGURATION
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO TABLE_CONFIGURATION_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM TABLE_CONFIGURATION_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND TABLE_NAME = OLD.TABLE_NAME AND COLUMN_NAME = OLD.COLUMN_NAME), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM TABLE_CONFIGURATION AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.TABLE_NAME = OLD.TABLE_NAME AND D.COLUMN_NAME = OLD.COLUMN_NAME
													);
		END IF;
	END$$

CREATE TRIGGER VIEWS_REV_HISTORY_AI
AFTER INSERT ON VIEWS
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO VIEWS_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM VIEWS_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND VIEW_NAME = NEW.VIEW_NAME), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM VIEWS AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.VIEW_NAME = NEW.VIEW_NAME
													);
		END IF;
	END$$

CREATE TRIGGER VIEWS_REV_HISTORY_AU
AFTER UPDATE ON VIEWS
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO VIEWS_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM VIEWS_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND VIEW_NAME = NEW.VIEW_NAME), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM VIEWS AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.VIEW_NAME = NEW.VIEW_NAME
													);
		END IF;
	END$$

CREATE TRIGGER VIEWS_REV_HISTORY_BD
BEFORE DELETE ON VIEWS
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO VIEWS_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM VIEWS_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND VIEW_NAME = OLD.VIEW_NAME), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM VIEWS AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.VIEW_NAME = OLD.VIEW_NAME
													);
		END IF;
	END$$

CREATE TRIGGER VIEW_CONFIGURATION_REV_HISTORY_AI
AFTER INSERT ON VIEW_CONFIGURATION
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO VIEW_CONFIGURATION_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM VIEW_CONFIGURATION_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND VIEW_NAME = NEW.VIEW_NAME AND TABLE_NAME = NEW.TABLE_NAME AND COLUMN_NAME = NEW.COLUMN_NAME), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM VIEW_CONFIGURATION AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.VIEW_NAME = NEW.VIEW_NAME AND D.TABLE_NAME = NEW.TABLE_NAME AND D.COLUMN_NAME = NEW.COLUMN_NAME
													);
		END IF;
	END$$

CREATE TRIGGER VIEW_CONFIGURATION_REV_HISTORY_AU
AFTER UPDATE ON VIEW_CONFIGURATION
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO VIEW_CONFIGURATION_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM VIEW_CONFIGURATION_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND VIEW_NAME = NEW.VIEW_NAME AND TABLE_NAME = NEW.TABLE_NAME AND COLUMN_NAME = NEW.COLUMN_NAME), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM VIEW_CONFIGURATION AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.VIEW_NAME = NEW.VIEW_NAME AND D.TABLE_NAME = NEW.TABLE_NAME AND D.COLUMN_NAME = NEW.COLUMN_NAME
													);
		END IF;
	END$$

CREATE TRIGGER VIEW_CONFIGURATION_REV_HISTORY_BD
BEFORE DELETE ON VIEW_CONFIGURATION
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO VIEW_CONFIGURATION_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM VIEW_CONFIGURATION_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND VIEW_NAME = OLD.VIEW_NAME AND TABLE_NAME = OLD.TABLE_NAME AND COLUMN_NAME = OLD.COLUMN_NAME), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM VIEW_CONFIGURATION AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.VIEW_NAME = OLD.VIEW_NAME AND D.TABLE_NAME = OLD.TABLE_NAME AND D.COLUMN_NAME = OLD.COLUMN_NAME
													);
		END IF;
	END$$

CREATE TRIGGER FORM_FIELDS_REV_HISTORY_AI
AFTER INSERT ON FORM_FIELDS
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO FORM_FIELDS_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM FORM_FIELDS_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND FORM_ID = NEW.FORM_ID AND FIELD_ID = NEW.FIELD_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM FORM_FIELDS AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.FORM_ID = NEW.FORM_ID AND D.FIELD_ID = NEW.FIELD_ID
													);
		END IF;
	END$$

CREATE TRIGGER FORM_FIELDS_REV_HISTORY_AU
AFTER UPDATE ON FORM_FIELDS
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO FORM_FIELDS_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM FORM_FIELDS_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND FORM_ID = NEW.FORM_ID AND FIELD_ID = NEW.FIELD_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM FORM_FIELDS AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.FORM_ID = NEW.FORM_ID AND D.FIELD_ID = NEW.FIELD_ID
													);
		END IF;
	END$$

CREATE TRIGGER FORM_FIELDS_REV_HISTORY_BD
BEFORE DELETE ON FORM_FIELDS
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO FORM_FIELDS_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM FORM_FIELDS_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND FORM_ID = OLD.FORM_ID AND FIELD_ID = OLD.FIELD_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM FORM_FIELDS AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.FORM_ID = OLD.FORM_ID AND D.FIELD_ID = OLD.FIELD_ID
													);
		END IF;
	END$$

CREATE TRIGGER TEMPLATE_VARIABLES_REV_HISTORY_AI
AFTER INSERT ON TEMPLATE_VARIABLES
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO TEMPLATE_VARIABLES_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM TEMPLATE_VARIABLES_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND TEMPLATE_ID = NEW.TEMPLATE_ID AND VARIABLE_ID = NEW.VARIABLE_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM TEMPLATE_VARIABLES AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.TEMPLATE_ID = NEW.TEMPLATE_ID AND D.VARIABLE_ID = NEW.VARIABLE_ID
													);
		END IF;
	END$$

CREATE TRIGGER TEMPLATE_VARIABLES_REV_HISTORY_AU
AFTER UPDATE ON TEMPLATE_VARIABLES
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO TEMPLATE_VARIABLES_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM TEMPLATE_VARIABLES_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND TEMPLATE_ID = NEW.TEMPLATE_ID AND VARIABLE_ID = NEW.VARIABLE_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM TEMPLATE_VARIABLES AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.TEMPLATE_ID = NEW.TEMPLATE_ID AND D.VARIABLE_ID = NEW.VARIABLE_ID
													);
		END IF;
	END$$

CREATE TRIGGER TEMPLATE_VARIABLES_REV_HISTORY_BD
BEFORE DELETE ON TEMPLATE_VARIABLES
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO TEMPLATE_VARIABLES_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM TEMPLATE_VARIABLES_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND TEMPLATE_ID = OLD.TEMPLATE_ID AND VARIABLE_ID = OLD.VARIABLE_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM TEMPLATE_VARIABLES AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.TEMPLATE_ID = OLD.TEMPLATE_ID AND D.VARIABLE_ID = OLD.VARIABLE_ID
													);
		END IF;
	END$$

CREATE TRIGGER DOCUMENT_INPUTS_REV_HISTORY_AI
AFTER INSERT ON DOCUMENT_INPUTS
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO DOCUMENT_INPUTS_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM DOCUMENT_INPUTS_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND DOCUMENT_ID = NEW.DOCUMENT_ID AND REV_ID = NEW.REV_ID AND INPUT_ID = NEW.INPUT_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM DOCUMENT_INPUTS AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.DOCUMENT_ID = NEW.DOCUMENT_ID AND D.REV_ID = NEW.REV_ID AND D.INPUT_ID = NEW.INPUT_ID
													);
		END IF;
	END$$

CREATE TRIGGER DOCUMENT_INPUTS_HISTORY_AU
AFTER UPDATE ON DOCUMENT_INPUTS
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO DOCUMENT_INPUTS_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM DOCUMENT_INPUTS_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND DOCUMENT_ID = NEW.DOCUMENT_ID AND REV_ID = NEW.REV_ID AND INPUT_ID = NEW.INPUT_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM DOCUMENT_INPUTS AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.DOCUMENT_ID = NEW.DOCUMENT_ID AND D.REV_ID = NEW.REV_ID AND D.INPUT_ID = NEW.INPUT_ID
													);
		END IF;
	END$$

CREATE TRIGGER DOCUMENT_INPUTS_REV_HISTORY_BD
BEFORE DELETE ON DOCUMENT_INPUTS
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO DOCUMENT_INPUTS_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM DOCUMENT_INPUTS_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND DOCUMENT_ID = OLD.DOCUMENT_ID AND REV_ID = OLD.REV_ID AND INPUT_ID = OLD.INPUT_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM DOCUMENT_INPUTS AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.DOCUMENT_ID = OLD.DOCUMENT_ID AND D.REV_ID = OLD.REV_ID AND D.INPUT_ID = OLD.INPUT_ID
													);
		END IF;
	END$$

CREATE TRIGGER ACTIONS_BI
BEFORE INSERT ON ACTIONS
FOR EACH ROW
	BEGIN
    SET NEW.ACTION_ID = (
       SELECT IFNULL(MAX(ACTION_ID), 0) + 1
       FROM ACTIONS
       WHERE FACILITY_ID = NEW.FACILITY_ID
    );
	END $$

CREATE TRIGGER ACTIONS_REV_HISTORY_AI
AFTER INSERT ON ACTIONS
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO ACTIONS_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM ACTIONS_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND ACTION_ID = NEW.ACTION_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM ACTIONS AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.ACTION_ID = NEW.ACTION_ID
													);
		END IF;
	END$$

CREATE TRIGGER ACTIONS_REV_HISTORY_AU
AFTER UPDATE ON ACTIONS
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO ACTIONS_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM ACTIONS_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND ACTION_ID = NEW.ACTION_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM ACTIONS AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.ACTION_ID = NEW.ACTION_ID
													);
		END IF;
	END$$

CREATE TRIGGER ACTIONS_REV_HISTORY_BD
BEFORE DELETE ON ACTIONS
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO ACTIONS_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM ACTIONS_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND ACTION_ID = OLD.ACTION_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM ACTIONS AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.ACTION_ID = OLD.ACTION_ID
													);
		END IF;
	END$$

CREATE TRIGGER LOOPS_REV_HISTORY_AI
AFTER INSERT ON LOOPS
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO LOOPS_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM LOOPS_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND LOOP_ID = NEW.LOOP_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM LOOPS AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.LOOP_ID = NEW.LOOP_ID
													);
		END IF;
	END$$

CREATE TRIGGER LOOPS_REV_HISTORY_AU
AFTER UPDATE ON LOOPS
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO LOOPS_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM LOOPS_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND LOOP_ID = NEW.LOOP_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM LOOPS AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.LOOP_ID = NEW.LOOP_ID
													);
		END IF;
	END$$

CREATE TRIGGER LOOPS_REV_HISTORY_BD
BEFORE DELETE ON LOOPS
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO LOOPS_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM LOOPS_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND LOOP_ID = OLD.LOOP_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM LOOPS AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.LOOP_ID = OLD.LOOP_ID
													);
		END IF;
	END$$

CREATE TRIGGER INTEGRITY_SUMMARY_REV_HISTORY_AI
AFTER INSERT ON INTEGRITY_SUMMARY
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO INTEGRITY_SUMMARY_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM INTEGRITY_SUMMARY_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND LOOP_ID = NEW.LOOP_ID AND `DATE` = NEW.DATE), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM INTEGRITY_SUMMARY AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.LOOP_ID = NEW.LOOP_ID AND D.DATE = NEW.DATE
													);
		END IF;
	END$$

CREATE TRIGGER INTEGRITY_SUMMARY_REV_HISTORY_AU
AFTER UPDATE ON INTEGRITY_SUMMARY
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO INTEGRITY_SUMMARY_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM INTEGRITY_SUMMARY_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND LOOP_ID = NEW.LOOP_ID AND `DATE` = NEW.DATE), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM INTEGRITY_SUMMARY AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.LOOP_ID = NEW.LOOP_ID AND D.DATE = NEW.DATE
													);
		END IF;
	END$$

CREATE TRIGGER INTEGRITY_SUMMARY_REV_HISTORY_BD
BEFORE DELETE ON INTEGRITY_SUMMARY
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO INTEGRITY_SUMMARY_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM INTEGRITY_SUMMARY_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND LOOP_ID = OLD.LOOP_ID AND `DATE` = OLD.DATE), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM INTEGRITY_SUMMARY AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.LOOP_ID = OLD.LOOP_ID AND D.DATE = OLD.DATE
													);
		END IF;
	END$$

CREATE TRIGGER EQUIPMENT_REV_HISTORY_AI
AFTER INSERT ON EQUIPMENT
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO EQUIPMENT_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM EQUIPMENT_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND EQUIPMENT_ID = NEW.EQUIPMENT_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM EQUIPMENT AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.EQUIPMENT_ID = NEW.EQUIPMENT_ID
													);
		END IF;
	END$$

CREATE TRIGGER EQUIPMENT_REV_HISTORY_AU
AFTER UPDATE ON EQUIPMENT
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO EQUIPMENT_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM EQUIPMENT_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND EQUIPMENT_ID = NEW.EQUIPMENT_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM EQUIPMENT AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.EQUIPMENT_ID = NEW.EQUIPMENT_ID
													);
		END IF;
	END$$

CREATE TRIGGER EQUIPMENT_REV_HISTORY_BD
BEFORE DELETE ON EQUIPMENT
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO EQUIPMENT_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM EQUIPMENT_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND EQUIPMENT_ID = OLD.EQUIPMENT_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM EQUIPMENT AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.EQUIPMENT_ID = OLD.EQUIPMENT_ID
													);
		END IF;
	END$$

CREATE TRIGGER DAMAGE_MECHANISM_REV_HISTORY_AI
AFTER INSERT ON DAMAGE_MECHANISM
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO DAMAGE_MECHANISM_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM DAMAGE_MECHANISM_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND LOOP_ID = NEW.LOOP_ID AND DAMAGE_MECHANISM_ID = NEW.DAMAGE_MECHANISM_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM DAMAGE_MECHANISM AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.LOOP_ID = NEW.LOOP_ID AND D.DAMAGE_MECHANISM_ID = NEW.DAMAGE_MECHANISM_ID
													);
		END IF;
	END$$

CREATE TRIGGER DAMAGE_MECHANISM_REV_HISTORY_AU
AFTER UPDATE ON DAMAGE_MECHANISM
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO DAMAGE_MECHANISM_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM DAMAGE_MECHANISM_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND LOOP_ID = NEW.LOOP_ID AND DAMAGE_MECHANISM_ID = NEW.DAMAGE_MECHANISM_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM DAMAGE_MECHANISM AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.LOOP_ID = NEW.LOOP_ID AND D.DAMAGE_MECHANISM_ID = NEW.DAMAGE_MECHANISM_ID
													);
		END IF;
	END$$

CREATE TRIGGER DAMAGE_MECHANISM_REV_HISTORY_BD
BEFORE DELETE ON DAMAGE_MECHANISM
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO DAMAGE_MECHANISM_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM DAMAGE_MECHANISM_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND LOOP_ID = OLD.LOOP_ID AND DAMAGE_MECHANISM_ID = OLD.DAMAGE_MECHANISM_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM DAMAGE_MECHANISM AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.LOOP_ID = OLD.LOOP_ID AND D.DAMAGE_MECHANISM_ID = OLD.DAMAGE_MECHANISM_ID
													);
		END IF;
	END$$

CREATE TRIGGER STRATEGY_REV_HISTORY_AI
AFTER INSERT ON STRATEGY
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO STRATEGY_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM STRATEGY_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND STRATEGY_ID = NEW.STRATEGY_ID AND LOOP_ID = NEW.LOOP_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM STRATEGY AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.STRATEGY_ID = NEW.STRATEGY_ID AND D.LOOP_ID = NEW.LOOP_ID
													);
		END IF;
	END$$

CREATE TRIGGER STRATEGY_REV_HISTORY_AU
AFTER UPDATE ON STRATEGY
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO STRATEGY_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM STRATEGY_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND STRATEGY_ID = NEW.STRATEGY_ID AND LOOP_ID = NEW.LOOP_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM STRATEGY AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.STRATEGY_ID = NEW.STRATEGY_ID AND D.LOOP_ID = NEW.LOOP_ID
													);
		END IF;
	END$$

CREATE TRIGGER STRATEGY_REV_HISTORY_BD
BEFORE DELETE ON STRATEGY
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO STRATEGY_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM STRATEGY_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND STRATEGY_ID = OLD.STRATEGY_ID AND LOOP_ID = OLD.LOOP_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM STRATEGY AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.STRATEGY_ID = OLD.STRATEGY_ID AND D.LOOP_ID = OLD.LOOP_ID
													);
		END IF;
	END$$

CREATE TRIGGER CML_REV_HISTORY_AI
AFTER INSERT ON CML
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO CML_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM CML_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND EQUIPMENT_ID = NEW.EQUIPMENT_ID AND CML_ID = NEW.CML_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM CML AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.EQUIPMENT_ID = NEW.EQUIPMENT_ID AND D.CML_ID = NEW.CML_ID
													);
		END IF;
	END$$

CREATE TRIGGER CML_REV_HISTORY_AU
AFTER UPDATE ON CML
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO CML_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM CML_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND EQUIPMENT_ID = NEW.EQUIPMENT_ID AND CML_ID = NEW.CML_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM CML AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.EQUIPMENT_ID = NEW.EQUIPMENT_ID AND D.CML_ID = NEW.CML_ID
													);
		END IF;
	END$$

CREATE TRIGGER CML_REV_HISTORY_BD
BEFORE DELETE ON CML
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO CML_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM CML_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND EQUIPMENT_ID = OLD.EQUIPMENT_ID AND CML_ID = OLD.CML_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM CML AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.EQUIPMENT_ID = OLD.EQUIPMENT_ID AND D.CML_ID = OLD.CML_ID
													);
		END IF;
	END$$

CREATE TRIGGER INSPECTION_AUTO_INCREMENT_BI
BEFORE INSERT ON INSPECTION
FOR EACH ROW
	BEGIN
    SET NEW.PHOTO = (
       SELECT IFNULL(MAX(PHOTO), 0) + 1
       FROM INSPECTION
       WHERE FACILITY_ID = NEW.FACILITY_ID
    );
	END $$

CREATE TRIGGER INSPECTION_DATA_INTEGRITY_RULES_BI
BEFORE INSERT ON INSPECTION
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			IF 	(
				EXISTS 	(
								-- ENSURE INSPECTION RECORDS ARE ALWAYS ENTERED IN CHRONOLOGICAL ORDER. THIS VASTLY IMPROVES CALCULATION PERFORMACE ON WALL LOSS AND SERVICE YEARS
								SELECT 1
								FROM INSPECTION i
								WHERE 	(
										-- CONFIRM THERE ARE NO RECORDS BEFORE WITH A LATER DATE
										i.FACILITY_ID = NEW.FACILITY_ID AND
										i.EQUIPMENT_ID = NEW.EQUIPMENT_ID AND
										i.CML_ID = NEW.CML_ID AND
										i.INSPECTION_ID < NEW.INSPECTION_ID AND
										i.INSPECTION_DATE > NEW.INSPECTION_DATE
										)
									  OR
										(
										-- CONFIRM THERE ARE NO RECORDS AFTER WITH A EARLIER DATE
										i.FACILITY_ID = NEW.FACILITY_ID AND
										i.EQUIPMENT_ID = NEW.EQUIPMENT_ID AND
										i.CML_ID = NEW.CML_ID AND
										i.INSPECTION_ID > NEW.INSPECTION_ID AND
										i.INSPECTION_DATE < NEW.INSPECTION_DATE
										)
								)
				) THEN
					-- PRODUCE ERROR AND ABORT UPDATE
					SIGNAL SQLSTATE '45000'
					SET MESSAGE_TEXT = 'INSPECTIONS MUST BE INSERTED IN CHRONOLOGICAL ORDER.';
			END IF;
		END IF;
	END$$

CREATE TRIGGER INSPECTION_REV_HISTORY_AI
AFTER INSERT ON INSPECTION
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO INSPECTION_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM INSPECTION_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND INSPECTION_ID = NEW.INSPECTION_ID AND CML_ID = NEW.CML_ID AND EQUIPMENT_ID = NEW.EQUIPMENT_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM INSPECTION AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.INSPECTION_ID = NEW.INSPECTION_ID AND D.CML_ID = NEW.CML_ID AND D.EQUIPMENT_ID = NEW.EQUIPMENT_ID
													);
		END IF;
	END$$

CREATE TRIGGER INSPECTION_DATA_INTEGRITY_RULES_BU
BEFORE UPDATE ON INSPECTION
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			IF 	(
				EXISTS 	(
								-- ENSURE INSPECTION RECORDS ARE ALWAYS ENTERED IN CHRONOLOGICAL ORDER. THIS VASTLY IMPROVES CALCULATION PERFORMACE ON WALL LOSS AND SERVICE YEARS
								SELECT 1
								FROM INSPECTION i
								WHERE 	(
										-- CONFIRM THERE ARE NO RECORDS BEFORE WITH A LATER DATE
										i.FACILITY_ID = NEW.FACILITY_ID AND
										i.EQUIPMENT_ID = NEW.EQUIPMENT_ID AND
										i.CML_ID = NEW.CML_ID AND
										i.INSPECTION_ID < NEW.INSPECTION_ID AND
										i.INSPECTION_DATE > NEW.INSPECTION_DATE
										)
									  OR
										(
										-- CONFIRM THERE ARE NO RECORDS AFTER WITH A EARLIER DATE
										i.FACILITY_ID = NEW.FACILITY_ID AND
										i.EQUIPMENT_ID = NEW.EQUIPMENT_ID AND
										i.CML_ID = NEW.CML_ID AND
										i.INSPECTION_ID > NEW.INSPECTION_ID AND
										i.INSPECTION_DATE < NEW.INSPECTION_DATE
										)
								)
				) THEN
					-- PRODUCE ERROR AND ABORT UPDATE
					SIGNAL SQLSTATE '45000'
					SET MESSAGE_TEXT = 'INSPECTIONS MUST BE UPDATED IN CHRONOLOGICAL ORDER.';
			END IF;
		END IF;
	END$$

CREATE TRIGGER INSPECTION_REV_HISTORY_AU
AFTER UPDATE ON INSPECTION
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO INSPECTION_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM INSPECTION_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND INSPECTION_ID = NEW.INSPECTION_ID AND CML_ID = NEW.CML_ID AND EQUIPMENT_ID = NEW.EQUIPMENT_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM INSPECTION AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.INSPECTION_ID = NEW.INSPECTION_ID AND D.CML_ID = NEW.CML_ID AND D.EQUIPMENT_ID = NEW.EQUIPMENT_ID
													);
		END IF;
	END$$

CREATE TRIGGER INSPECTION_REV_HISTORY_BD
BEFORE DELETE ON INSPECTION
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO INSPECTION_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM INSPECTION_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND INSPECTION_ID = OLD.INSPECTION_ID AND CML_ID = OLD.CML_ID AND EQUIPMENT_ID = OLD.EQUIPMENT_ID), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM INSPECTION AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.INSPECTION_ID = OLD.INSPECTION_ID AND D.CML_ID = OLD.CML_ID AND D.EQUIPMENT_ID = OLD.EQUIPMENT_ID
													);
		END IF;
	END$$

CREATE TRIGGER GRID_REV_HISTORY_AI
AFTER INSERT ON GRID
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO GRID_REV_HISTORY 	(
													SELECT 'INSERT', IFNULL((SELECT MAX(REVISION) FROM GRID_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND EQUIPMENT_ID = NEW.EQUIPMENT_ID AND CML_ID = NEW.CML_ID AND INSPECTION_ID = NEW.INSPECTION_ID AND X = NEW.X AND Y = NEW.Y), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM GRID AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.EQUIPMENT_ID = NEW.EQUIPMENT_ID AND D.CML_ID = NEW.CML_ID AND D.INSPECTION_ID = NEW.INSPECTION_ID AND D.X = NEW.X AND D.Y = NEW.Y
													);
		END IF;
	END$$

CREATE TRIGGER GRID_REV_HISTORY_AU
AFTER UPDATE ON GRID
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO GRID_REV_HISTORY 	(
													SELECT 'UPDATE', IFNULL((SELECT MAX(REVISION) FROM GRID_REV_HISTORY WHERE FACILITY_ID = NEW.FACILITY_ID AND EQUIPMENT_ID = NEW.EQUIPMENT_ID AND CML_ID = NEW.CML_ID AND INSPECTION_ID = NEW.INSPECTION_ID AND X = NEW.X AND Y = NEW.Y), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM GRID AS D
													WHERE D.FACILITY_ID = NEW.FACILITY_ID AND D.EQUIPMENT_ID = NEW.EQUIPMENT_ID AND D.CML_ID = NEW.CML_ID AND D.INSPECTION_ID = NEW.INSPECTION_ID AND D.X = NEW.X AND D.Y = NEW.Y
													);
		END IF;
	END$$

CREATE TRIGGER GRID_REV_HISTORY_BD
BEFORE DELETE ON GRID
FOR EACH ROW
	BEGIN
		IF @DISABLE_TRIGGERS IS NULL THEN
			INSERT INTO GRID_REV_HISTORY 	(
													SELECT 'DELETE', IFNULL((SELECT MAX(REVISION) FROM GRID_REV_HISTORY WHERE FACILITY_ID = OLD.FACILITY_ID AND EQUIPMENT_ID = OLD.EQUIPMENT_ID AND CML_ID = OLD.CML_ID AND INSPECTION_ID = OLD.INSPECTION_ID AND X = OLD.X AND Y = OLD.Y), 0) + 1, NOW(), IFNULL(@CURRENT_SESSION_USER, USER()), D.*
													FROM GRID AS D
													WHERE D.FACILITY_ID = OLD.FACILITY_ID AND D.EQUIPMENT_ID = OLD.EQUIPMENT_ID AND D.CML_ID = OLD.CML_ID AND D.INSPECTION_ID = OLD.INSPECTION_ID AND D.X = OLD.X AND D.Y = OLD.Y
													);
		END IF;
	END$$

-- RETURN DELIMITER TO DEFAULT VALUE
DELIMITER ;
