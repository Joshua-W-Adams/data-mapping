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
const cli = require('./modules/cli.js');

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

////////////////////////// Define task code ////////////////////////////////////

function executeSqlFile (sqlFile) {
  return new Promise(function (resolve, reject) {
    cli.mySqlCli(projectFolderName, sqlFile).then(function (res) {
      resolve(res);
    }).catch(function (err) {
      reject(err);
    })
  })
}

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
	var config = JSON.parse(fs.readFileSync('..\\config\\' + projectFolderName + '\\config.json', 'utf8'));

	// create clone of database
	executeSqlFile(__dirname + "\\" + config.test.cloneFilePath)
  .then(function () {
    // copy data to clone
		return executeSqlFile(__dirname + "\\" + config.test.copyFilePath);
	}).then(function () {
		return executeSqlFile(__dirname + "\\" + config.test.loadFilePath);
	// load output data to cloned database
  }).then(function (loadQueryRes) {
		return outputLogFile(loadQueryRes, config.output.debugFilepath);
	}).then(function () {
		console.log('Data load completed. See log file for details.');
	}).catch(function (err) {
		console.log('error detected during test procedure.')
		console.log(err);
	})

  return;

}

/*
	Execute main test functions
*/

conductTest();
