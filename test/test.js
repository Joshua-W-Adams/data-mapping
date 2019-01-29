// Author: Joshua William Adams
// Rev History:
// No.: A     Desc.: Issued for review                          Date: 21/01/2019
// No.: 0     Desc.: Issued for use                             Date: 25/01/2019
//
// Description: Main test file. Specifies procedure to test the output data for
// any errors.

// import external libraries
var fs = require('fs');

// import modules
var dbConnection = require('./modules/db-ops.js');

function readFile (filePath) {
	return new Promise (function (resolve, reject) {
		// Synchronously read file
		fs.readFile(filePath, 'utf8', function(err, data) {
			if (err) {
				reject(err);
			} else {
				resolve(data);
			}
		});
	})
}

function outputLogFile (loadQueryRes, filePath) {
	return new Promise (function (resolve, reject) {
		fs.writeFile(filePath + 'log.txt', JSON.stringify(loadQueryRes, null, '\t'), function (err) {
			if (err) {
				reject(err);
			} else {
				resolve();
			}
		})
	})
}

function conductTest () {

	// read in mapping configuration object
	var config = JSON.parse(fs.readFileSync('..\\config\\config.json', 'utf8'));

	// create clone of database
	readFile(config.test.cloneFilePath).then(function (cloneQuery) {
		return dbConnection.executeSql(cloneQuery, 'root');
	// copy data to clone
	}).then(function () {
		return readFile(config.test.copyFilePath);
	}).then(function (copyQuery) {
		return dbConnection.executeSql(copyQuery, 'root');
	// load output data to cloned database
	}).then(function () {
		return readFile(config.test.loadFilePath);
	}).then(function (loadQuery) {
		return dbConnection.executeSql(loadQuery, 'root');
  }).then(function (loadQueryRes) {
		return outputLogFile(loadQueryRes, config.output.debugFilepath);
	}).then(function () {
		// Close the database connection and end the code
		dbConnection.connections['root'].end();
		dbConnection = null;
		console.log('Data load completed. See log file for details.');
	}).catch(function (err) {
		console.log('error detected during test procedure.')
		console.log(err);
	})

}

/*
	Execute main test functions
*/

conductTest();
