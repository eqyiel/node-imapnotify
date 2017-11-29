// @flow

/*:: import type { Config } from './types'; */
const util = require('util');
const executeCommands = require('./executeCommands');
const isEventMap = require('./isEventMap');

function executeOnNotify(
  config /*: Config */
) /*: (box: string, event: string) => Promise<void> */ {
  return function notify(box, event) {
    const formattedBox = box.toLowerCase().replace('/', '-');
    const formattedCommand = util.format(
      isEventMap(config.onNotify)
        ? config.onNotify[event] || ''
        : config.onNotify,
      formattedBox
    );
    const formattedPostCommand = util.format(
      isEventMap(config.onNotifyPost)
        ? config.onNotifyPost[event] || ''
        : config.onNotifyPost,
      formattedBox
    );
    return executeCommands(formattedCommand, formattedPostCommand);
  };
}

module.exports = executeOnNotify;
