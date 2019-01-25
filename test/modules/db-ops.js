// Author: Joshua William Adams
// Rev History:
// No.: A     Desc.: Issued for review                          Date: 21/01/2019
// No.: 0     Desc.: Issued for use                             Date: 25/01/2019
//
// Description: Module for all database operations performed by the test
// load procedure.

// import external libraries
var mysql = require('mysql'); 	// MySQL database drivers

// define connection object
var connection = {
  root: {}
};

function getDbConfig (username, password) {
	var db_config = {
		host : 'localhost',
		user : username,
		password : password,
		// Extract dates as strings to prevent MySQL library from automatically
		// converting them to date time format.
		dateStrings: true,
		ssl: {
					// Usually DO NOT DO THIS
					// set up your ca correctly to trust the connection...
					// However we dont care if the cerificate authority is trusted as the
					// connection is occuring over localhost
					rejectUnauthorized: false
				},
    // enables multiple statements to be executed on one query which enables the
    // load data dump to execute sucessfully
    multipleStatements: true
	}
	return db_config;
}

// Standard reusable function for connecting to a MySQL database
function connectToDatabase (username, password, connections) {
	connections[username] = mysql.createConnection(getDbConfig(username, password));
	// Refer to the following link for details on the below error handling
	// stackoverflow.com/questions/20210522/nodejs-mysql-error-connection-lost
	// -the-server-closed-the-connection
  connections[username].connect(function(err) {
		// The database server is either down
		// or restarting (takes a while sometimes).
		if(err) {
			console.log(Date() + ": error when connecting to db:", err);
			setTimeout(function () {
				// We introduce a delay before attempting to reconnect,
        // to avoid a hot loop, and to allow our node script to
      	// process asynchronous requests in the meantime.
        // If you're also serving http, display a 503 error.
				connectToDatabase(username, password, connections);
			}, 5000);
		}
	});
	// Error handler to prevent server crashing on any database issues
	// e.g. timeouts, etc.
	connections[username].on('error', function(err) {
    console.log(Date() + ': db error:', err);
		if(err.code === 'PROTOCOL_CONNECTION_LOST') { 					// Connection to the MySQL server is usually
      connectToDatabase(username, password, connections);  	// lost due to either server restart, or a
    } else {                                      					// connnection idle timeout (the wait_timeout
      throw err;                                  					// server variable configures this)
    }
  });
}

// Execute SQL on a database and then resolve results to calling function.
function executeSql (sql_string, user) {
	return new Promise(function(resolve, reject) {
  	// perform passed query on database
  	connection[user].query(sql_string, function(err, results, fields) {
  		if (err) {
  			console.log(Date() + ": error in query: " + err);
  			reject(err);
  			return; // The function execution ends here
  		}
  		resolve(results);
    });
  });
}

// create connections
connectToDatabase('root', '!@#1r2h3i4n5o6a7d8m9i10n', connection);

exports.connections = connection;
exports.executeSql = executeSql;
