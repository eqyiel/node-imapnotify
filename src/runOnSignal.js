// @flow

/*:: import type { Config } from './types'; */
const createDebug = require('./createDebug');
const executeCommands = require('./executeCommands');

const debug = createDebug('runOnSignal');

function runOnSignal(
  partialSignal /*: string */,
  config /*: Config */
) /*: Promise<void> */ {
  const signal = `SIG${partialSignal}`;
  debug(`trying running on${signal} commands`);
  return executeCommands(config[`on${signal}`], config[`on${signal}post`]);
}

module.exports = runOnSignal;
