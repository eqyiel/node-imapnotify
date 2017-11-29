// @flow

/*:: import type { Config } from './types'; */

const eventMap = require('./eventMap');
const isEventMap = require('./isEventMap');

function validateConfigurationObject(config /*: Config */) /*: void */ {
  ['user', 'host'].forEach(element => {
    if (typeof config[element] !== 'string') {
      throw new Error(`configuration file: ${element} must be a string`);
    }
  });

  if (typeof config.port !== 'number' && typeof config.port !== 'string') {
    throw new Error(`configuration file: port must be a number or a string`);
  }

  ['onNotify', 'onNotifyPost'].forEach(element => {
    if (typeof config[element] !== 'string' && !isEventMap(config[element])) {
      throw new Error(
        `configuration file: ${element} must be a number or an event map`
      );
    }

    if (isEventMap(config[element])) {
      Object.keys(config[element]).forEach(key => {
        if (!Object.keys(eventMap).includes(key)) {
          throw new Error(
            `configuration file: ${element} has unknown key ${key}`
          );
        }
      });

      if (
        !Object.keys(eventMap).forEach((
          key // $FlowFixMe
        ) => Object.keys(config[element]).includes(key))
      ) {
        throw new Error(
          `configuration file: ${element} is an object but lacks commands for any of ${Object.keys(
            eventMap
          ).join(', ')}`
        );
      }
    }
  });

  if (config.password !== undefined && typeof config.password !== 'string') {
    throw new Error(
      `configuration file: if password is defined it must be a string`
    );
  }

  if (
    config.passwordCommand !== undefined &&
    typeof config.passwordCommand !== 'string'
  ) {
    throw new Error(
      `configuration file: if passwordCommand is defined it must be a string`
    );
  }

  if (config.password === undefined && config.passwordCommand === undefined) {
    throw new Error(
      `configuration file: must provide one of password or passwordCommand`
    );
  }

  if (config.tls !== undefined && config.tls !== 'boolean') {
    throw new Error(
      `configuration file: if tls is defined it must be a boolean`
    );
  }

  if (config.tlsOptions !== undefined && config.tlsOptions !== 'object') {
    throw new Error(
      `configuration file: if tlsOptions is defined it must be an object`
    );
  }
}

module.exports = validateConfigurationObject;
