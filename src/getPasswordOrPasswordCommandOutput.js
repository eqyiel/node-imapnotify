// @flow

/*:: import type { Config } from './types'; */
const run = require('./run');

function getPasswordOrPasswordCommandOutput(
  config /*: Config */
) /*: Promise<string> */ {
  return (() =>
    config.password
      ? Promise.resolve(config.password)
      : run(config.passwordCommand))().then(password => {
    if (password.length) {
      return Promise.resolve(password);
    }

    return Promise.reject(
      new Error(
        'password is an empty string or passwordCommand failed to produce any output'
      )
    );
  });
}

module.exports = getPasswordOrPasswordCommandOutput;
