This is a module providing a new type, `svcprop`.

It runs on Solaris 10 and 11, SmartOS, and OmniOS.

Sample usage:

```
svcprop { 'sendmail-local':
  fmri     => 'network/smtp:sendmail',
  property => 'config/local_only',
  type     => 'astring',
  value    => 'true',
}
 ```
The `type` property is optional, all others are mandatory.
