// @flow

const childProcess = require('child_process');
const terminate = require('terminate');

class Notifier {
  constructor(configFilePath) {
    this.configFilePath = configFilePath;
    this.stdout = '';
    this.stderr = '';
  }

  start() {
    this.child = childProcess.spawn(process.env.IMAPNOTIFY_COMMAND, ['-c', this.configFilePath], {
      shell: true,
    });

    this.child.stdout.on('data',
      data => {
        console.log('command output: ' + data);
      }
    );

    this.child.stderr.on('data', data => {
      console.log('stderr: ' + data);
    });
  }

  flush() {
    return [this.stdout, this.stderr];
  }

  stop() {
    terminate(this.child.pid);
  }
}

module.exports = Notifier;
