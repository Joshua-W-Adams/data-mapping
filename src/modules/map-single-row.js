// Author: Joshua William Adams
// Rev History:
// No.: A     Desc.: Issued for review                          Date: 21/01/2019
// No.: 0     Desc.: Issued for use                             Date: 25/01/2019
//
// Description: Module for storing all functionality to map one input row to one
// output row.

var lib = require('./lib.js');

// Main function to output a row of input data to an specific table format
function mapOneInputRowToOneOutputRow (outputData, table, row, columnMappings
  , appendOneToManyMappings, oneToManyMappings, configData) {

  var outputRow = {},
      output = outputData[table],
      columnMapping,
      colName,
      cValue;

  // Loop through columns and perform operations
  for (var i = 0; i < columnMappings.length; i++) {

    columnMapping = columnMappings[i],
    colName = columnMapping.Column;

    // Get value for current column mapping in loop
    cValue = getOutputColumnValue(row, columnMapping, configData, outputData, table);

    // Update with specifics for multiple rows
    if (appendOneToManyMappings === true) {
      cValue = appendSpecificsForRow(cValue, colName, row, oneToManyMapping, configData, outputData, table);
    }

    // store mapped data in array
     outputRow[colName] = cValue

  }

  return outputRow;

}


function getOutputColumnValue (row, columnMapping, configData, outputData, table) {

  var cName = columnMapping.Column,
      cType = columnMapping.Type,
      mName = columnMapping.Mapped_Column,
      mValue = lib.handleInput(row[mName]),
      cValue;

  // Get value of column based on mappings
  if (cType === 'VALUE') {
    cValue = columnMapping.Value;
  } else if (cType === 'COLUMN') {
    cValue = mValue;
  } else if (cType === 'COLUMN_DATE') {
    cValue = formatAusDate(mValue);
  } else if (cType === 'IF_ELSE') {
    cValue = handleIfElse (columnMapping, mValue, row);
  } else if (cType === 'CONCAT') {
    cValue = handleConcat(columnMapping.Mapped_Concat, row);
  } else if (cType === 'LOOKUP') {
    cValue = handleLookup(columnMapping, row, configData);
  } else if (cType === 'ID') {
    cValue = handleId(row, columnMapping, outputData[table], 1, configData);
  } else if (cType === 'ID_CHILD') {
    cValue = handleId(row, columnMapping, outputData[columnMapping.Id_Table], 0
      , configData);
  } else {
    cValue = '\\N'
  }

  return cValue;

}

function appendSpecificsForRow (cValue, cName, row, appendColumns, configData, outputData, table) {

  var multiColName;

  // Loop through columns specific for multiple row mappings
  for (var n = 0; n < appendColumns.length; n++) {
     multiColName = appendColumns[n].Column;
     if (cName === multiColName) {
       return getOutputColumnValue(row, appendColumns[n], configData, outputData, table);
     }
  }

  return cValue;

}

function handleLookup(columnMapping, row, configData) {

  var lookupTbl = columnMapping.Mapped_Lookup_Table,
      lookupColumn = columnMapping.Mapped_Lookup_Column,
      lookupValue = lib.handleInput(row[lookupColumn]),
      lookupFallback = columnMapping.Mapped_Lookup_Fallback,
      lookupArray = configData[lookupTbl],
      filters = [{
        'column': 'LOOKUP_VALUE',
        'value': lookupValue
      }];

  // lookup values in json array that match filter criteria
  var data = lib.filterArray(lookupArray, filters);

  // return column value in first matched row to user
  if (data.length > 0) {
    return lib.handleInput(data[0]['LOOKUP_RESULT']);
  } else {
    return lookupFallback;
  }

}

function handleId (row, columnMapping, outputData, incrementValue, configData) {

  var idColumn = columnMapping.Id_Column,
      idLookupFallbackTable = configData[columnMapping.Id_Lookup],
      filters = [];

  // define filters
  filters = lib.addFilter(filters, columnMapping.Id_Primary_Key_1_Column
    , row[columnMapping.Id_Primary_Key_1_Value]);
  filters = lib.addFilter(filters, columnMapping.Id_Primary_Key_2_Column
    , row[columnMapping.Id_Primary_Key_2_Value]);
  filters = lib.addFilter(filters, columnMapping.Id_Primary_Key_3_Column
    , row[columnMapping.Id_Primary_Key_3_Value]);

  // get data that matches filter criteria
  var data = lib.filterArray(outputData, filters);

  if (data.length > 0) {
    // sort array in decending order to get maximum value
    data = sortDescending(data, idColumn);
    // get id of top (max) row
    var maxId = lib.handleInput(data[0][idColumn]);
    // return id to user
    return parseInt(maxId) + incrementValue;
  } else {
    // no id found in currently output data. Lookup in fallback array
    var fallbackData = lib.filterArray(idLookupFallbackTable, filters);
    if (fallbackData.length > 0) {
      // sort array in decending order to get maximum value
      fallbackData = sortDescending(fallbackData, idColumn);
      var fbId = fallbackData[0][idColumn]
      return parseInt(fbId) + 1;
    } else {
      return 1;
    }
  }

}

function sortDescending (data, idColumn) {

  return data.sort(function(a, b) {
    return parseInt(b[idColumn]) - parseInt(a[idColumn]);
  });

}

function formatAusDate(date) {

  var parts = date.split("/"),
      month = parts[1],
      day = parts[0],
      year = parts[2];

  if (month.length < 2) month = '0' + month;
  if (day.length < 2) day = '0' + day;

  return [year, month, day].join('-') + '\\t';

}

function handleIfElseType (type, ifElseValue, row) {

  if (type === 'VALUE') {
    return ifElseValue;
  } else if (type === 'COLUMN') {
    return lib.handleInput(row[ifElseValue]);
  } else if (type === 'CONCAT') {
    return handleConcat(ifElseValue, row);
  } else if (type === 'DIVIDE') {
    return handleDivide(ifElseValue, row);
  } else {
    return '\\N';
  }

}

function handleDivide (ifElseValue, row) {

  var value = '',
      arr = ifElseValue.split(','),
      result;

  // loop through all values to be divided
  for (var n = 0; n < arr.length; n++) {
    // Handle Columns
    if (arr[n].substring(0,1) === '[') {
      var len = arr[n].length,
          col = arr[n].substring(1, len - 1);
      value = lib.handleInput(row[col]);
    // Handle Strings
    } else {
      value = arr[n];
    }
    // perform division calculation
    if (n === 0) {
      result = value
    } else {
      result = result / value;
    }
  }

  // handle case of insufficient data provided
  if (result === 0) {
    result = '\\N';
  }

  return result;

}

function handleConcat (concatValue, row) {

  var value = '',
      arr = concatValue.split(',');

  // loop through all values to be concatenated into a string
  for (var n = 0; n < arr.length; n++) {
    // Handle Columns
    if (arr[n].substring(0,1) === '[') {
      var len = arr[n].length,
          col = arr[n].substring(1, len - 1);
      value = compileString(value, lib.handleInput(row[col]));
    // Handle Strings
    } else {
      value = compileString(value, arr[n]);
    }
  }

  return value;

}

function compileString (baseStr, appendStr) {

  var append,
      appendFirst;

  if (appendStr === '\\N') {
    append = '';
    appendFirst = '';
  } else {
    append = ' - ' + appendStr;
    appendFirst = appendStr;
  }

  if (baseStr.length > 0) {
    return baseStr + append;
  } else {
    return appendFirst;
  }

}

function handleIfElse (columnMapping, columnValue, row) {

  var mCondition = columnMapping.Mapped_Condition,
      mConditionType = columnMapping.Mapped_Condition_Type,
      mIf = columnMapping.Mapped_If,
      mIfType = columnMapping.Mapped_If_Type,
      mElse = columnMapping.Mapped_Else,
      mElseType = columnMapping.Mapped_Else_Type;

  if (mConditionType === 'EQUAL') {
    if (columnValue === mCondition) {
      return handleIfElseType(mIfType, mIf, row);
    } else {
      return handleIfElseType(mElseType, mElse, row);
    }
  } else if (mConditionType === 'NOT NULL') {
    if (columnValue !== '\\N') {
      return handleIfElseType(mIfType, mIf, row);
    } else {
      return handleIfElseType(mElseType, mElse, row);
    }
  }
  
}


exports.mapOneInputRowToOneOutputRow = mapOneInputRowToOneOutputRow;
