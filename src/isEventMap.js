// @flow

function isEventMap(eventMap /*: Object | string */) /*: %checks */ {
  return typeof eventMap === 'object';
}

module.exports = isEventMap;
