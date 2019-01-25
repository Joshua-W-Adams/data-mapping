// Author: Joshua William Adams
// Rev History:
// No.: A     Desc.: Issued for review                          Date: 21/01/2019
// No.: 0     Desc.: Issued for use                             Date: 25/01/2019
//
// Description: Module for all filesystem related opertions in the application.

// Import external librarys
// file system operations
var fs = require('fs');
// csv to json parser
var parse = require('csv-parse');
// json to csv parser
const Json2csvParser = require('json2csv').Parser;

// read file from file system and parse to json array
function fileToJson (filePath, arr) {
  return new Promise(function(resolve, reject) {
    // parser needs to be defined here or it is 'locked' out if function is
    // called multiple times
    var parser = parse({delimiter: ',', columns: true, cast: true});
    // asynchronously read data from file and parse
    fs.createReadStream(filePath)
      .pipe(parser)
      .on('data', function (row) {
          // push data to array
          arr.push(row);
        })
      .on('error', function (err) {
        reject(err);
      })
      .on('end', function () {
        resolve(arr);
      });
  })
}

// read file from file system and parse to json array
function readJsonFile (filePath, tName, inputData) {
  return new Promise(function(resolve, reject) {
    // parser needs to be defined here or it is 'locked' out when function is
    // called multiple times
    fs.readFile(filePath, 'utf8', function (err, data) {
      if (err) {
        reject(err);
      } else {
        var json = JSON.parse(data);
        inputData[tName] = json;
        resolve();
      }
    })
  })
}

// read in all input files dictated in the config object
function getMappingInputFiles (config) {

  // define promise array to ensure all configuration files are read into memory
  // before conversion to new data format
  var promiseArray = [];
  var inputData = {
    oneToOneColumnMappings: [],
    oneToManyColumnMappings: [],
    oneToFewColumnMappings: [],
    tableFilters: [],
    tableList: [],
    output: config.output
  };

  // define promises of files to read in and where to save the parsed json data
  var p1 = fileToJson(config.oneToOneColumnMappings, inputData.oneToOneColumnMappings),
      p2 = fileToJson(config.oneToManyColumnMappings, inputData.oneToManyColumnMappings),
      p3 = fileToJson(config.oneToFewColumnMappings, inputData.oneToFewColumnMappings),
      p4 = fileToJson(config.tableFilters, inputData.tableFilters),
      p5 = fileToJson(config.tableList, inputData.tableList);

  // push promises to array
  promiseArray.push(p1);
  promiseArray.push(p2);
  promiseArray.push(p3);
  promiseArray.push(p4);
  promiseArray.push(p5);

  // append all lookup files to promise array
  for (var x = 0; x < config.lookups.length; x++) {
    var tblName = config.lookups[x].name
    // create object property for lookup data
    inputData[tblName] = [];
    // define promise for lookup
    var pX = fileToJson(config.lookups[x].filePath, inputData[tblName])
    promiseArray.push(pX);
  }

  // append all database table files to promise array
  for (var i = 0; i < config.tables.length; i++) {
    var tName = config.tables[i].name;
    // create object property for lookup data
    inputData[tName] = [];
    // define promise for lookup
    var pY = readJsonFile(config.tables[i].filePath, tName, inputData);
    promiseArray.push(pY);
  }

  // read in all required input files
  return Promise.all(promiseArray).then(function (res) {
    return inputData;
  }).catch(function (err) {
    throw err;
  })

}

function getKeys(obj) {

  var keys = [];

  for (var key in obj) {
    if (obj.hasOwnProperty(key)) {
      keys.push(key);
    }
  }

  return keys;

}

function jsonToCsv (arr) {

  const fields = getKeys(arr[0]);
  const opts = { fields };
  var csv;

  try {
    const parser = new Json2csvParser(opts);
    csv = parser.parse(arr);
  } catch (err) {
    throw err;
  }

  return csv;

}

function writeDataToFiles (configData, outputData) {

  var table,
      filePath,
      csv;

  // loop throug all tables to be output
  for (var key in outputData) {

    // filter out prototype properties
    if (outputData.hasOwnProperty(key)) {

      table = key,
      filePath = configData.output.dataFilepath + table + '.csv';

      // delete any existing files
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath, function (err) {
          if (err) throw err;
          console.log(filePath + ' was deleted');
        });
      }

      // convert data to csv format
      csv = jsonToCsv(outputData[table]);

      // write data to file
      fs.writeFile(filePath, csv, function (err) {
        if (err) throw err;
          console.log('The file has been saved!');
      });

    }

  }

}

// Return all objects to calling javascript
exports.getMappingInputFiles = getMappingInputFiles;
exports.writeDataToFiles = writeDataToFiles;
