const Imap = require('imap');
const createDebug = require('./createDebug');
const executeOnNotify = require('./executeOnNotify');

const debug = createDebug('Notifier');

class Notifier {
  constructor(config) {
    this.config = config;
    this.connections = {};
    this.errors = {};
  }

  addBox(box, cb /*: () => void */ = () => {}) {
    if (this.connections[box]) {
      delete this.connections[box];
    }

    const connection = this.createConnection();
    this.connections[box] = connection;

    connection.once('ready', () => {
      delete this.errors[box];
      debug('%O Connected to server', { box });
      debug('%O Selecting box', { box });

      const delimiter = connection.namespaces
        ? connection.namespaces.personal[0].delimiter
        : '/';

      connection.openBox(box.replace('/', delimiter), true, err => {
        if (err) throw err;
        function addConnectionListener(event, message) {
          connection.on(event, () => {
            debug('%s %O', { message }, { box });
            cb(box, event);
          });
        }
        addConnectionListener('mail', 'New Mail');
        addConnectionListener('expunge', 'Deleted Mail');
        addConnectionListener('update', 'Altered message metadata');
      });
    });

    connection.once('end', () => {
      debug('%O Connection ended', { box });
      connection.emit('shouldReconnect');
    });

    connection.once('error', error => {
      debug('%O Error registered', { box });
      debug('%O %O', { box }, error);
      if (!this.errors[box]) {
        debug('%O Restarting immediately', { box });
        this.errors[box] = { time: Date.now(), count: 1 };
        connection.emit('shouldReconnect');
      } else {
        const errCount = this.errors[box].count;

        if (this.errors[box].count >= 3) {
          throw Error('Max retry limit reached');
        }

        const restartTimeout = errCount * 3000;
        this.errors[box].count = this.errors[box].count + 1;
        debug(`%O Scheduling restart in ${restartTimeout}`, { box });
        setTimeout(() => {
          connection.emit('shouldReconnect');
        }, restartTimeout);
      }
    });

    connection.once('shouldReconnect', () => {
      debug('%O shouldReconnect event', { box });
      debug('%O Reading box', { box });
      this.addBox(box, executeOnNotify(this.config));
      this.startWatch(box);
    });
  }

  startWatch(box) {
    this.connections[box].connect();
  }

  stopWatch(box) {
    debug('%O Ending connection', { box });
    this.connections[box].end();
  }

  createConnection() {
    return new Imap({
      user: this.config.username,
      password: this.config.password,
      host: this.config.host,
      port: this.config.port,
      tls: this.config.tls || false,
      tlsOptions: this.config.tlsOptions,
    });
  }

  start() {
    Object.keys(this.connections).forEach(box => {
      this.startWatch(box);
    });
  }

  stop(cb /*: () => void */ = () => {}) {
    Object.keys(this.connections).forEach(box => {
      this.stopWatch(box);
    });

    setTimeout(() => {
      debug('Calling stop callback');
      cb();
    }, 500);
  }

  restart() {
    this.stop(() => {
      this.start();
    });
  }
}

module.exports = Notifier;
