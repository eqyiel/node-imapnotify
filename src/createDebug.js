// @flow

const debug = require('debug');
const { name } = require('../package.json');

function createDebug(
  namespace /*: string */
) /*: (...data: Array<any>) => void */ {
  return debug(`${name}:${namespace}`);
}

module.exports = createDebug;
