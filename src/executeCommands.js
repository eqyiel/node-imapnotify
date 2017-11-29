// @flow

const createDebug = require('./createDebug');
const run = require('./run');

const debug = createDebug('executeCommands');

function executeCommands(
  command /*: ?string */,
  postCommand /*: ?string */
) /*: Promise<void> */ {
  if (!command) {
    debug('Did not find command to execute');
    return Promise.reject(new Error('Did not find command to execute'));
  }

  debug(`Found command: ${command}`);

  return run(command).then(() => {
    if (postCommand) {
      debug(`Found postCommand: ${postCommand}`);
      return run(postCommand);
    }
    return Promise.resolve();
  });
}

module.exports = executeCommands;
