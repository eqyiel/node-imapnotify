// @flow

/*:: import type { Config } from './types'; */
const Notifier = require('./Notifier');
const createDebug = require('./createDebug');
const runOnSignal = require('./runOnSignal');
const executeOnNotify = require('./executeOnNotify');
const validateConfigurationObject = require('./validateConfigurationObject');

const debug = createDebug('imapnotify');

function main(argv /*: { config: Config } */) /*: void */ {
  validateConfigurationObject(argv.config);

  process.setMaxListeners(100);

  const notifier = new Notifier(argv.config);

  argv.config.boxes.forEach(box => {
    notifier.addBox(box, executeOnNotify(argv.config));
  });

  process.on('SIGINT', () => {
    debug('Caught Ctrl-C, exiting...');
    notifier.stop(() => {
      debug('imapnotify stopped');
      runOnSignal('INT', argv.config).then(() => {
        process.exit(0);
      });
    });
  });

  process.on('SIGTERM', () => {
    debug('Caught SIGTERM, exiting...');
    notifier.stop(() => {
      debug('imapnotify stopped');
      runOnSignal('TERM', argv.config).then(() => {
        process.exit(2);
      });
    });
  });

  process.on('SIGHUP', () => {
    debug('Caught SIGHUP, restarting...');
    runOnSignal('HUP', argv.config).then(() => {
      notifier.restart();
    });
  });

  notifier.start();

  debug('imap-inotify started');
}

module.exports = main;
