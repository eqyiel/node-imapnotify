// @flow

beforeAll(() => {
  const variables = ['IMAPNOTIFY_COMMAND', 'SENDMAIL_COMMAND'];

  variables.forEach(variable => {
    if (!process.env[variable]) {
      throw new Error(`${variable} missing from environment`);
    }
  });

  if (variables.some(variable => !process.env[variable])) {
    process.exit(1);
  }
});
