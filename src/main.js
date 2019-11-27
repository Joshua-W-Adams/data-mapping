// Author: Joshua William Adams
// Rev History:
// No.: A     Desc.: Issued for review                          Date: 21/01/2019
// No.: 0     Desc.: Issued for use                             Date: 25/01/2019
//
// Description: Main application file. Specifies mapping configurations and main
// method.

// Import external librarys
var parse = require('csv-parse');
var fs = require('fs');

// Import application custom modules
// file system operations library
var fsOps = require('./modules/fs-ops.js');
// library of generic functions
var lib = require('./modules/lib.js')
// module to map one row of input data to one row of output data
var mapSingle = require('./modules/map-single-row.js')

// define global objects
var projectFolderName;

// process.argv is an array containing the command line arguments. The first
// element will be 'node', the second element will be the name of the project
// mapping folder. The next elements will be any additional command line arguments.
// not async function
process.argv.forEach(function (val, index, array) {

  // get project to map
  if (index === 2) {
    projectFolderName = val;
  }

});

// main method with high levele logic for mapping all data to a new format
function mapData (configData) {

  var parser = parse({delimiter: ',', columns: true, cast: true}),
      // list of tables to output each mapped row to
      tableList = configData.tableList;
      // object to store all mapped data so it can be output once at the end of
      // the function
      outputData = {},
      // store all mapping data specific to each output table
      mappingConfigurations = {},
      // counter to indicate how far application is through processing in the
      // command console.
      count = 0;

  // get mapping configuration data for each table to be created
  mappingConfigurations = lib.getTableMappingConfigurations(configData);

  // create object properties to store all output data in, creates 3 properties
  // per table, output data, duplicates detected and unresolved, duplicates
  // detected and resolved
  outputData = lib.addTablesAsProperties(tableList);

  // commence processing main input file to be mapped to new data formats,
  // data is extracted from csv file one chunk at a time, i.e as a constant flow
  // which enables asynchronous processing of data
  fs.createReadStream(config.inputFile)
    // send (pipe) each chunk of data into the parser function to convert the
    // chunk to a json object
    .pipe(parser)
    // async function to be executed on each row of data
    .on('data', function (row) {

      var table,
          include,
          oneToManyCount,
          oneToManySpecificArr,
          outputRow,
          filters = [],
          outputDataCheck,
          dbDataCheck;

      // Loop through each output table and output data
      for (var t = 0; t < tableList.length; t++) {

        table = tableList[t].Table;
        oneToManyCount = mappingConfigurations[table].oneToManyCount;

        // determine if current row should be skipped
        include = lib.includeRow(row, mappingConfigurations[table].tableFiltersList);

        // only excute mapping code if row should be output to current table
        if (include) {

          // determine output case for row
          // one to many mapping detected
          if (oneToManyCount > 0) {

            // loop through all rows to be produced
            for (var m = 0; m < oneToManyCount; m++) {
              // get one to many mapping list for specific record
              oneToManySpecificArr = mappingConfigurations[table]['oneToMany' + (m + 1)];
              // generate output row
              outputRow = mapSingle.mapOneInputRowToOneOutputRow(outputData, table
                , row, mappingConfigurations[table].oneToOneMappingList, true
                , oneToManySpecificArr, configData);
              // push row to storing array
              outputRowToTable(table, outputRow, outputData, configData, mappingConfigurations);
            }

          // one to few mapping case detected
          } else if (mappingConfigurations[table].oneToFewMappingList.length > 0) {

            // generate output row
            outputRow = mapSingle.mapOneInputRowToOneOutputRow(outputData, table
              , row, mappingConfigurations[table].oneToFewMappingList, false
              , null, configData);
            // push row to storing array
            outputRowToTable(table, outputRow, outputData, configData, mappingConfigurations);

          // one to single mapping detected
          } else {

            // generate output sheet
            outputRow = mapSingle.mapOneInputRowToOneOutputRow(outputData, table
              , row, mappingConfigurations[table].oneToOneMappingList, false
              , null, configData);
            // push row to array
            outputRowToTable(table, outputRow, outputData, configData, mappingConfigurations);

          }

        }

      }

      // log current status of mapping operation, i.e. input row number
      console.log(count++);

    }).on('end', function (err, data) {

      fsOps.createOutputFolders(configData);
      fsOps.writeDataToFiles(configData, outputData);
      console.log('processing finished');

    }).on('error', function (err) {
      // output error message and stop execution of code
      throw err.message;
    })

}

/**
 * outputRow - output a row of generated data. Data will be output to one of 3
 * files per table based on 3 conditions.
 * 1 - data already exsits in table file,
 * 2 - data already exists in database table,
 * 3 - otherwise.
 *
 * @return {type}  description
 */
function outputRowToTable (table, outputRow, outputData, configData, mappingConfigurations) {
  // commence check for output row already existing in output data
  // or master database
  // generate filter list for two duplicate check locations
  filters = lib.getOneToFewFilters(mappingConfigurations[table].primaryKeyList
    , outputRow);
  // determine if primary key already exists in output data array
  var outputDataCheck = lib.filterArray(outputData[table], filters);
  // case 1 - data already exists in output data
  if (outputDataCheck.length > 0) {
    // confirm if dulicate requires manual review or can be ignored
    // and push to appropriate array
    lib.handleDuplicates(outputRow, outputDataCheck, outputData[table + '_duplicates'], outputData[table + '_duplicates_resolved']);
  } else {
    // check for data existing in database already
    dbDataCheck = lib.filterArray(configData[table], filters);
    // case 2 - output row found in database data
    if (dbDataCheck.length > 0) {
      // confirm if dulicate requires manual review or can be ignored
      // and push to appropriate array
      lib.handleDuplicates(outputRow, dbDataCheck, outputData[table + '_duplicates'], outputData[table + '_duplicates_resolved']);
    // case 3 - data not found in output data or database
    } else {
      // push output row to array
      outputData[table].push(outputRow);
    }
  }
  return;
}


/*
  Execute main method
*/

// read in mapping configuration object
var config = JSON.parse(fs.readFileSync('..\\config\\' + projectFolderName + '\\config.json', 'utf8'));

// read in all data
fsOps.getMappingInputFiles(config).then(function (configData) {
  // call method to map data to new format(s)
  mapData(configData);
}).catch(function (err) {
  console.log('error in reading in all input configuration files.');
  console.log(err);
});
