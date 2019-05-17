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

CREATE TABLE REMEDIATION_STATUSES
(	/*FIELD NAME*/                   /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                    VARCHAR(30) NOT NULL,
	`REMEDIATION_STATUS`             CHAR(2) NOT NULL,
	`DESCRIPTION`                    VARCHAR(50) NOT NULL,

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, REMEDIATION_STATUS)

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
	`HYPERLINK_LOCATION`                        VARCHAR(50),
	`HYPERLINK_FILE_EXTENSION`                  VARCHAR(10),

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, TABLE_NAME, COLUMN_NAME)

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
	FOREIGN KEY (FACILITY_ID, TABLE_NAME, COLUMN_NAME) REFERENCES TABLE_CONFIGURATION(FACILITY_ID, TABLE_NAME, COLUMN_NAME)

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

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, CML_TYPE),
	FOREIGN KEY (FACILITY_ID, VIEW_NAME) REFERENCES VIEW_CONFIGURATION(FACILITY_ID, VIEW_NAME),

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
	`CML_ID`                         SMALLINT,
	`CML_TYPE`                       VARCHAR(160),
	`AREA`                           VARCHAR(50),
	`RESPONSIBLE_SYSTEM`             VARCHAR(30),
	`SAFETY_CRITICAL`                ENUM('YES','NO'),
	`RESPONSIBLE`                    VARCHAR(50),

	/*PRIMARY AND FOREIGN KEY DEFINITIONS*/
	PRIMARY KEY (FACILITY_ID, ACTION_ID)

) ENGINE=INNODB;

CREATE TABLE LOOPS
(	/*FIELD NAME*/                                 /*DATA TYPE AND RESTRICTIONS*/
	`FACILITY_ID`                                  VARCHAR(30) NOT NULL,
	`LOOP_ID`																			 VARCHAR(30) NOT NULL,
	`LOOP_TYPE`																		 VARCHAR(100),
	`LOOP_DESCRIPTION`													   VARCHAR(100),
	`STATUS`																			 CHAR(1),
	`INSPECTION_STATUS`                            VARCHAR(10),
	`REMEDIATION_STATUS`                           VARCHAR(10),
	`MIN_REMAINING_LIFE`                           FLOAT,
	`MAX_ACR`                                      FLOAT,
	`END_OF_LIFE`                                  DATE,
	`COMPLIANCE`                                   ENUM('YES','NO') DEFAULT NULL,
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
	`REMEDIATION_STATUS`                           VARCHAR(10),
	`MIN_REMAINING_LIFE`                           FLOAT,
	`MAX_ACR`                                      FLOAT,
	`END_OF_LIFE`                                  DATE,
	`COMPLIANCE`                                   ENUM('YES','NO') DEFAULT NULL,
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
	`PID`                                          VARCHAR(50),
	`DRAWING_REF`                                  VARCHAR(50),
	`DESIGN_LIFE`                                  FLOAT,
	`COF_MODIFIER`                                 TINYINT,
	`CYCLIC_SERVICE`                               VARCHAR(20),
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
	`SERIAL_NO`                                    INT,
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
	`MIN_REMAINING_LIFE`              FLOAT,
	`MAX_ACR`                         FLOAT,
	`END_OF_LIFE`                     DATE,
	`COMPLIANCE`                      ENUM('YES','NO') DEFAULT NULL,
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
	`MIN_REMAINING_LIFE`                                        FLOAT,
	`MAX_ACR`                                                   FLOAT,
	`END_OF_LIFE`                                               DATE,
	`COMPLIANCE`                                                ENUM('YES','NO') DEFAULT NULL,
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
	`CML_ID`                                             SMALLINT NOT NULL,
	`DAMAGE_MECHANISM_ID`                                VARCHAR(50) NOT NULL,
	`STRATEGY_ID`                                        VARCHAR(50) NOT NULL,
	`CML_TYPE`                                           VARCHAR(160),
	`DESCRIPTION`                                        TEXT,
	`POF_COLUMN`                                         VARCHAR(50),
	`STATUS`                                             CHAR(1),
	`INSPECTION_STATUS`                                  VARCHAR(10),
	`REMEDIATION_STATUS`                                 VARCHAR(10),
	`SELECTED_REMAINING_LIFE_YRS`                        FLOAT,
	`SELECTED_END_OF_LIFE`                               DATE,
	`POF`                                                TINYINT,
	`COF`                                                TINYINT,
	`CRITICALITY`                                        VARCHAR(10),
	`SELECTED_INSPECTION_INTERVAL`                       FLOAT,
	`CML_COMMENTS`                                       TEXT,
	`RECOMMENDED_REMEDIATION_COMMENTS`                   TEXT,
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
	`ERROR_CODE`                                         VARCHAR(5),
	`COLOUR_CODE`                                        VARCHAR(10),
	`RESPONSIBLE_SYSTEM`                                 VARCHAR(30),

	-- SPECIFIC FIELDS FOR CORROSION LEVEL ASSESSMENTS
	`CORROSION_LEVEL`                                    VARCHAR(10),

	-- SPECIFIC FIELDS FOR COMPLIANCE ASSESSMENTS
	`COMPLIANCE`                                         ENUM('YES','NO') DEFAULT NULL,

	-- SPECIFIC FIELDS FOR SAMPLING ASSESSMENTS
	`SAMPLE_VALUE`                                       MEDIUMINT,

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
	FOREIGN KEY (FACILITY_ID, REMEDIATION_STATUS) REFERENCES REMEDIATION_STATUSES(FACILITY_ID, REMEDIATION_STATUS),

	-- KEY TO ALLOW CASCADING UPDATES INTO INSPECTION TABLE
	KEY (FACILITY_ID, LOOP_ID, EQUIPMENT_ID, DAMAGE_MECHANISM_ID, STRATEGY_ID, CML_ID)

) ENGINE=INNODB;

CREATE TABLE INSPECTION
(	/*FIELD NAME*/                                     /*DATA TYPE AND RESTRICTIONS*/
	-- GENERIC FIELDS
	`FACILITY_ID`                                      VARCHAR(30) NOT NULL,
	`LOOP_ID`                                          VARCHAR(30) NOT NULL,
	`EQUIPMENT_ID`                                     VARCHAR(30) NOT NULL,
	`CML_ID`                                           SMALLINT NOT NULL,
	`INSPECTION_ID`                                    TINYINT NOT NULL,
	`STRATEGY_ID`                                      VARCHAR(50) NOT NULL,
	`DAMAGE_MECHANISM_ID`                              VARCHAR(50) NOT NULL,
	`INSPECTION_STATUS`                                CHAR(1),
	`REMEDIATION_STATUS`                               CHAR(1),
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
	`ERROR_CODE`                                       VARCHAR(5),
	`COLOUR_CODE`                                      VARCHAR(10),
	`RESPONSIBLE_SYSTEM`                               VARCHAR(30),

	-- SPECIFIC FIELDS FOR CORROSION LEVEL INSPECTIONS
	`CORROSION_LEVEL`                                  VARCHAR(10),

	-- SPECIFIC FIELDS FOR COMPLIANCE INSPECTIONS
	`COMPLIANCE`                                       ENUM('YES','NO'),

	-- SPECIFIC FIELDS FOR SAMPLING INSPECTIONS
	`SAMPLE_VALUE`                                     MEDIUMINT,

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
	FOREIGN KEY (FACILITY_ID, REMEDIATION_STATUS) REFERENCES REMEDIATION_STATUSES(FACILITY_ID, REMEDIATION_STATUS),

	-- KEY TO ALLOW FK AND CASCADING UPDATES INTO GRID TABLE
	KEY (FACILITY_ID, LOOP_ID, EQUIPMENT_ID, CML_ID, INSPECTION_ID)

) ENGINE=INNODB;

CREATE TABLE GRID
(	/*FIELD NAME*/                                     /*DATA TYPE AND RESTRICTIONS*/
	-- GENERIC FIELDS
	`FACILITY_ID`                                      VARCHAR(30) NOT NULL,
	`LOOP_ID`                                          VARCHAR(30) NOT NULL,
	`EQUIPMENT_ID`                                     VARCHAR(30) NOT NULL,
	`CML_ID`                                           SMALLINT NOT NULL,
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
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'ASSOCIATION', 'FACILITY_ID, LOOP_ID, ASSOCIATION, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'COLOUR_CODING', 'FACILITY_ID, DESCRIPTION, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'API_574_STRUCTURAL_THICKNESS', 'FACILITY_ID, NOMINAL_DIAMETER, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'CML_TYPES', 'FACILITY_ID, CML_TYPE, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'POF', 'FACILITY_ID, CML_TYPE, POF_COLUMN, VALUE_RANGE, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'RISK_MAPPING', 'FACILITY_ID, RISK_MATRIX, RISK_SCORE, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'CUI_MAPPING', 'FACILITY_ID, DESCRIPTION, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'STATUSES', 'FACILITY_ID, STATUS, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'INSPECTION_STATUSES', 'FACILITY_ID, INSPECTION_STATUS, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'REMEDIATION_STATUSES', 'FACILITY_ID, REMEDIATION_STATUS, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'DAMAGE_MECHANISM_ID_LIST', 'FACILITY_ID, DAMAGE_MECHANISM_ID, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'STRATEGY_ID_LIST', 'FACILITY_ID, STRATEGY_ID, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'TABLE_CONFIGURATION', 'FACILITY_ID, TABLE_NAME, COLUMN_NAME, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'VIEW_CONFIGURATION', 'FACILITY_ID, VIEW_NAME, TABLE_NAME, COLUMN_NAME, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'FORM_FIELDS', 'FACILITY_ID, FORM_ID, FIELD_ID, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'TEMPLATE_VARIABLES', 'FACILITY_ID, TEMPLATE_ID, VARIABLE_ID, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'DOCUMENT_INPUTS', 'FACILITY_ID, DOCUMENT_ID, REV_ID, INPUT_ID, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'ACTIONS', 'FACILITY_ID, ACTION_ID, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'LOOPS', 'FACILITY_ID, LOOP_ID, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'INTEGRITY_SUMMARY', 'FACILITY_ID, LOOP_ID, DATE, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'EQUIPMENT', 'FACILITY_ID, EQUIPMENT_ID, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'DAMAGE_MECHANISM', 'FACILITY_ID, LOOP_ID, DAMAGE_MECHANISM_ID, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'STRATEGY', 'FACILITY_ID, STRATEGY_ID, LOOP_ID, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'CML', 'FACILITY_ID, EQUIPMENT_ID, CML_ID, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'INSPECTION', 'FACILITY_ID, EQUIPMENT_ID, CML_ID, INSPECTION_ID, REVISION', NULL);
CALL SERVER.CREATE_REV_HISTORY_TABLE('INTEGRITY_TEST', 'GRID', 'FACILITY_ID, EQUIPMENT_ID, CML_ID, INSPECTION_ID, X, Y, REVISION', NULL);
