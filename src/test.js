const fs = require('fs');
const os = require('os');

const logFileName = os.tmpdir() + "\\spelunky2TwitchLog.txt";

fs.appendFile(logFileName, "pigcow:the magic button" + "\r\n", function(err) {
    if (err) {
        throw err;
    }
    console.log('New Line added to log file');
});