// @flow

const path = require('path');
const nodemailer = require('nodemailer');
const Notifier = require('./Notifier');

const transport = nodemailer.createTransport({
  sendmail: true,
  newline: 'unix',
  path: process.env.SENDMAIL_COMMAND,
  args: ['-f', 'sender@example.com'],
});

const sleep = ms => new Promise((resolve) => setTimeout(() => resolve(), ms));

describe('hi', () => {
  test('can start the guy', () => {
    expect.assertions(1);

    notifier = new Notifier(path.resolve(__dirname, './config-with-password.json'));

    notifier.start();

    return transport.sendMail({
      from: 'sender@example.com',
      to: 'recipient@example.com',
      subject: 'Message',
      text: 'I hope this message gets delivered!'
    }).then(sleep(20000))
      .then(() => {
        notifier.stop();
        const [stdout, stderr] = notifier.flush();

        return expect(stdout).toBe(undefined);
      });
  })
})
