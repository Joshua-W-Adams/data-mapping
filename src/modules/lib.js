// Author: Joshua William Adams
// Rev History:
// No.: A     Desc.: Issued for review                          Date: 21/01/2019
// No.: 0     Desc.: Issued for use                             Date: 25/01/2019
//
// Description: Module for storing all miscellaneous functions

function getMaxRecord(arr, prop, n) {

    // clone before sorting, to preserve the original array
    var clone = arr.slice(0);

    // sort descending
    clone.sort(function(x, y) {
        if (x[prop] == y[prop]) return 0;
        else if (parseInt(x[prop]) < parseInt(y[prop])) return 1;
        else return -1;
    });

    // return the first or nth sorted item
    return clone.slice(0, n || 1);

}

// get mapping data for specific table to be output
function getTableMappingConfigurations (configData) {

  var tList = configData.tableList,
      mappingConfigurations = {},
      table,
      oneToOneArr,
      oneToManyArr,
      oneToFewArr,
      oneToManySpecificArr,
      pkArr,
      tableFiltersArr,
      maxRecordArr,
      oneToManyCount = 0;

  function filterCallback (i, n) {
    return i.Table===table;
  }

  function pkFilterCallback (i, n) {
    return i.Table===table && i.Column_Type==='PK';
  }

  function getPrimaryKeys () {

    var pk1 = configData.oneToOneColumnMappings.filter(pkFilterCallback),
        pk2 = configData.oneToFewColumnMappings.filter(pkFilterCallback);

    if (pk1.length > 0) {
      return pk1;
    } else {
      return pk2;
    }

  }

  // loop thrugh all tables and create mappings
  for (var t = 0; t < tList.length; t++) {

    // get table name of output table
    table = tList[t].Table;

    // get filtered lists of mappings specific to table
    oneToOneArr = configData.oneToOneColumnMappings.filter(filterCallback);
    oneToManyArr = configData.oneToManyColumnMappings.filter(filterCallback);
    oneToFewArr = configData.oneToFewColumnMappings.filter(filterCallback);
    tableFiltersArr = configData.tableFilters.filter(filterCallback);
    pkArr = getPrimaryKeys();

    // determine amount of times input record should be duplicated in one to
    // many mappings
    maxRecordArr = getMaxRecord(oneToManyArr, 'Record');
    if (maxRecordArr.length > 0) {
      oneToManyCount = maxRecordArr[0].Record;
    }

    // store mapping configurations for specific table
    mappingConfigurations[table] = {
      'oneToOneMappingList': oneToOneArr,
      'oneToManyMappingList': oneToManyArr,
      'oneToFewMappingList': oneToFewArr,
      'tableFiltersList': tableFiltersArr,
      'oneToManyCount': oneToManyCount,
      'primaryKeyList': pkArr
    }

    // store oneToManyMappings for specific record
    for (var x = 0; x < oneToManyCount; x++) {

      function oneToManySpecificCallback (i, n) {
        return parseInt(i.Record)===(x + 1)
      }

      oneToManySpecificArr = oneToManyArr.filter(oneToManySpecificCallback);
      mappingConfigurations[table]['oneToMany' + (x + 1)] = oneToManySpecificArr;

    }

  }

  return mappingConfigurations;

}

function addTablesAsProperties (arr) {

  var table,
      o = {};

  for (var t = 0; t < arr.length; t++) {
    // get table name of output table
    table = arr[t].Table;
    // create empty array to store mapped table data
    o[table] = [];
    // create an empty array to store table duplicates
    o[table + '_duplicates'] = [];
    // create an empty array to store table resolved duplicates
    o[table + '_duplicates_resolved'] = [];
  }

  return o;

}

function getOneToFewFilters (primaryKeyList, outputRow) {

  var filters = [],
      pkCol,
      pkValue;

  for (var x = 0; x < primaryKeyList.length; x++) {
    pkCol = primaryKeyList[x].Column;
    pkValue = outputRow[pkCol];
    filters = addFilter(filters, pkCol, pkValue);
  }

  return filters;

}


function addFilter (arr, column, value) {

  if (column && value) {
    arr.push({
      'column': column,
      'value': value
    })
  }

  return arr;

}

// Generic function to filter a json array by a list of passed filter criteria
function filterArray (data, filters) {

  // filter array
  var arr = data.filter(

      // define filtering function
      function (row) {

        var column,
            value,
            check;

        // loop through all filters and check for pass fail
        for (var i = 0; i < filters.length; i++) {
          column = filters[i].column;
          value = filters[i].value;
          // confirm current row matches filter requirements
          check = row[column] == value;
          // condition not met, therefore exit loop
          if (check === false) {
            break;
          }
        }

        return check;

      }

  );

  return arr;

}

function combineJsonObjects (outputRow, duplicateRow) {

  for (var key in duplicateRow) {
    if (duplicateRow.hasOwnProperty(key)) {
      outputRow["db_" + key] = duplicateRow[key];
    }
  }

  return;
}

function handleDuplicates (outputRow, compareArr, duplicateUnresolved, duplicatesResolved) {

  var filters = [],
      value,
      duplicates = [];

  // create filter array for all items in outputRow
  for (key in outputRow) {
    if (outputRow.hasOwnProperty(key)) {
      // get value from row
      value = outputRow[key];
      // do not include current column in duplication check as we only care if the
      // columns that we are actually adding data too are the same as that in the database.
      if (value === '\\N') {
        value = null;
      }
      filters = addFilter(filters, key, value);
    }
  }

  // find any exact matching duplicates
  duplicates = filterArray(compareArr, filters);

  // duplicate found
  if (duplicates.length > 0) {
    // do nothing and skip value
    duplicatesResolved.push(outputRow);
  } else {
    // not found - add value to duplicates list for manual assessment
    combineJsonObjects(outputRow, compareArr[0]);
    duplicateUnresolved.push(outputRow);
  }

}

function includeRow (row, tableFilters) {

  var x,
      filterType,
      filterColumn,
      filterValue,
      columnValue,
      // Set default return value
      includeRow = true;

  if (tableFilters.length > 0) {

    // Loop through input row filters
    for (x = 0; x < tableFilters.length; x++) {

      // get filter conditions
      filterType = tableFilters[x].Filter_Type;
      filterColumn = tableFilters[x].Filter_Column;

      if (row[filterColumn]) {
        columnValue = handleInput(row[filterColumn]);
      }

      // get filter value if applicable
      filterValue = tableFilters[x].Filter_Value;

      // Handle all filter conditions
      if (filterType === 'EQUAL') {
          if (filterValue == columnValue) {
              includeRow = true;
          } else {
              includeRow = false;
          }
      } else if (filterType === 'NOT_EQUAL') {
        if (filterValue != columnValue) {
          includeRow = true;
        } else {
          includeRow = false;
        }
      } else if (filterType === 'NULL') {
        if (!columnValue || columnValue.trim() == '') {
          includeRow = true;
        } else {
          includeRow = false;
        }
      } else if (filterType === 'NOT_NULL') {
        if (columnValue && columnValue.trim() != '') {
          includeRow = true;
        } else {
          includeRow = false;
        }
      }

      // dont include row as not all filter conditions are met
      if (includeRow === false) {
        break;
      }

    }

  }

  return includeRow;

}

function handleInput (value) {

  if (typeof value ==='string') {
    if (value.trim() == '') {
      return '\\N';
    } else {
      return value.trim();
    }
  } else {
    if (value) {
      return value;
    } else if (value === 0) {
      return value
    } else {
      return '\\N';
    }
  }

}

// Return all objects to calling javascript
exports.getTableMappingConfigurations = getTableMappingConfigurations;
exports.addTablesAsProperties = addTablesAsProperties;
exports.getOneToFewFilters = getOneToFewFilters;
exports.handleDuplicates = handleDuplicates;
exports.addFilter = addFilter;
exports.filterArray = filterArray;
exports.includeRow = includeRow;
exports.handleInput = handleInput;
