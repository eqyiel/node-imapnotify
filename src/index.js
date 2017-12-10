// @flow

/*:: import type { Config } from './types'; */
const fs = require('fs');
const Notifier = require('./Notifier');
const createDebug = require('./createDebug');
const runOnSignal = require('./runOnSignal');
const executeOnNotify = require('./executeOnNotify');
const validateConfigurationObject = require('./validateConfigurationObject');
const getPasswordOrPasswordCommandOutput = require('./getPasswordOrPasswordCommandOutput');

const debug = createDebug('imapnotify');

function main(argv /*: { config: Config } */) /*: void */ {
  const config = JSON.parse(fs.readFileSync(argv.config));

  validateConfigurationObject(config);

  process.setMaxListeners(100);

  getPasswordOrPasswordCommandOutput(config).then(password => {
    const notifier = new Notifier(Object.assign({}, config, { password }));

    config.boxes.forEach(box => {
      debug('adding box %s', box);
      notifier.addBox(box, executeOnNotify(config));
    });

    process.on('SIGINT', () => {
      debug('Caught Ctrl-C, exiting...');
      notifier.stop(() => {
        debug('imapnotify stopped');
        runOnSignal('INT', config, () => process.exit(0));
      });
    });

    process.on('SIGTERM', () => {
      debug('Caught SIGTERM, exiting...');
      notifier.stop(() => {
        debug('imapnotify stopped');
        runOnSignal('TERM', config, () => process.exit(2));
      });
    });

    process.on('SIGHUP', () => {
      debug('Caught SIGHUP, restarting...');
      runOnSignal('HUP', config, () => notifier.restart());
    });

    notifier.start();

    debug('imapnotify started');
  });
}

module.exports = main;
