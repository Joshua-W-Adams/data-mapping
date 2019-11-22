# data-mapping
Generic program enabling mapping of one data format to another

## Instructions

1. Install project dependencies as follows

```
Node v10.15.3
```

2. Clone repository to your system using the following command or git desktop.

```
git clone https://github.com/YOUR-USERNAME/YOUR-REPOSITORY
```

3. Install project

```
npm install
```

4. Update configuration data files

    1. input.csv
      - define column structure
      - import all data to be mapped to new output tables
      - analyse data - review all columns to confirm no corrupt or illogical data

    2. tables.csv
      - list all tables to map input data to

    3. tableFilters.csv
      - add filters to input.csv data for each table to be output (e.g. only map input rows where col 1 = "some value" to table x)

    4. oneToOneColumnMappings.csv
      - list all tables to where every input row will be mapped to a **single** and **multiple** output row(s)
      - list every column for all tables
      - specify whether each column is a primary key (PK)
      - specify mapping rules for each column (e.g. output the value in a specific input column to a output column)

    5. oneToManyColumnMappings.csv
      - list all tables to where every input row will be mapped to **multiple** output rows
      - list every column that will have values that will **differ** from the 1:1 mapping file
      - re-list columns for each time you want to create a **duplicate** of the input row
      - specify whether each column is a primary key (PK)
      - specify mapping rules for each input row duplication

    6. oneToFewColumnMappings.csv
      - list all tables to where every input row will be mapped to **less than one** output row
      - list every column for all tables
      - specify whether each column is a primary key (PK)
      - specify mapping rules for each column

    7. Create lookup tables as defined in the mapping sheets
      - to be .csv format

    8. Create copies of the data in the database for each table to be output
      - code will perform an assessment to determine whether each output row already exists in the database
      - to be .json format

5. Update configuration .json file with the locations of all files listed above.

```
.\config\config.json
```

6. Execute mapping procedure

```
.\src\> node main.js
```

7. Check output files

8. Test load data to database

    1. Create test configuration files
      - schema.sql - creates copy of the database schema that output files are to be loaded to
      - copy-data.sql - copies all data from the database copy to the test database
      - load-data.sql - loads all created output tables to test database

    2. Update config.json file with the locations of all files above

    3. Update config.json file with the location of the database to connect to

    4. Ensure database has copy of latest data

    5. Start database

    5. Execute test load

    ```
    .\test\> node test.js
    ```

    6. Review outputs for load errors

9. Files ready to be loaded to database
