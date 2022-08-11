# Don't @ me
### An insane way to test the validity of an email address

Inspired by Dann in TorontoJS, who suggested using an HTML email input to test if an email address was valid or not.

I decided it would be funnier to do this in headless chrome
...behind an HTTP API
...deployed as a serverless FaaS

## Run locally
```
npm i
npm run dev
```

## Valid request
```
GET /email/rube@goldberg.io
[200] ✅ Valid email: 'rube@goldberg.io'

GET /url/http://lol.com
[200] ✅ Valid url: 'http://lol.com'

GET /url/scheme:path
[200] ✅ Valid url: 'scheme:path'

GET /tel/1 800 5-FLOWER
[200] ✅ Valid tel: '1 800 5-FLOWER'
```

## Invalid requests
```
GET /email/not-an-email
[422] 🚫 Invalid email: 'not-an-email'

GET /url/http://lol.com
[422] 🚫 Invalid url: 'neat-o'
```

```
GET /
[400] 🚫 Requests should be in the form `/type/value` where type is one of: email, url, tel
```
