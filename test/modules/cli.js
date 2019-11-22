// Author: Joshua William Adams
// Rev History:
// No.: A     Desc.: Issued for review                          Date: 22/11/2019
// No.: 0     Desc.: Issued for use                             Date: 22/11/2019
//
// Description: Module for executing commands on the Command Line Interface (CLI).

////////////////////////// Import external libraries ///////////////////////////
const { exec } = require('child_process');
const fs = require('fs');

////////////////////////// Get User Inputs /////////////////////////////////////
const config = JSON.parse(fs.readFileSync('..\\config\\config.json', 'utf8'));

////////////////////////// Define Functions ////////////////////////////////////

function cliCommand (dir, command) {
  return new Promise(function (resolve, reject) {
    // exceute cli process
    exec(dir + command, function (err, stdout, stderr) {
      if (err) {
        // node couldn't execute the command
        console.log(err);
        reject(err);
      } else if (stderr) {
        // failure in command execution
        console.log(`stderr: ${stderr}`);
        reject(stderr);
      } else {
        // sucessfully executed return pass condition
        console.log(`stdout: ${stdout}`);
        resolve(stdout);
      }
      return ;
    });
  })
}

function mySqlCli (sql_file) {
  var dir = config.dbConnection.executablePath,
      cnfdir = "" + config.dbConnection.cnfPath + "";
      command = 'mysql --defaults-extra-file=' + cnfdir + 'config.cnf -vvv < "' + sql_file + '"'
  return cliCommand(dir, command);
}

exports.mySqlCli = mySqlCli;
