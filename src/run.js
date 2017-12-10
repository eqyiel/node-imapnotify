// @flow

const { exec } = require('child_process');
const createDebug = require('./createDebug');

const debug = createDebug('run');

function run(cmd /*: string */) /*: Promise<void> */ {
  debug(`Running ${cmd}`);
  return new Promise((resolve, reject) => {
    exec(cmd, (error, stdout, stderr) => {
      if (error) {
        debug(`Error running ${cmd}`);
        return reject(error);
      }

      if (stderr.length) {
        debug(`Error running ${cmd}: %s`, stderr);
        return reject(new Error(stderr));
      }

      return resolve(stdout);
    });
  });
}

module.exports = run;
