// @flow

/*:: import type { Config } from './types'; */
const createDebug = require('./createDebug');
const executeCommands = require('./executeCommands');

const debug = createDebug('runOnSignal');

function runOnSignal(
  partialSignal /*: string */,
  config /*: Config */,
  callback /*: () => void */ = () => {}
) /*: void */ {
  const signal = `SIG${partialSignal}`;
  debug(`trying running on${signal} commands`);
  executeCommands(config[`on${signal}`], config[`on${signal}post`])
    .then(() => callback())
    .catch(() => {
      callback();
    });
}

module.exports = runOnSignal;
