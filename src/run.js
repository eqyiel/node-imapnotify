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
        debug(stderr);
        return reject(error);
      }

      debug(stdout);
      return resolve();
    });
  });
}

module.exports = run;
