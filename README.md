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
GET /rube@goldberg.io
[200] rube@goldberg.io
```

## Invalid requests
```
GET /not-an-email
[422] Invalid email address: 'not-an-email'
```

```
GET /
[400] No email provided
```
