#
# Browser Init
#
Puppeteer = require 'puppeteer'

BROWSER = null
do initBrowser = ->
  # Launch Puppeteer, an API wrapper around headless chrome
  BROWSER ?= await Puppeteer.launch headless: true, args: [
    '--no-sandbox'
    '--disable-setuid-sandbox'
    '--disable-dev-shm-usage'
    '--no-first-run'
    '--no-zygote'
    '--headless'
    '--disable-gpu'
  ]
  # if the browser disconnects, try to re-initialize it for the next request
  BROWSER.on 'disconnect', ->
    BROWSER = null
    browser()

#
# The validation
#
isValid = (email='')->
  # Open a new page in Chrome
  await initBrowser()
  page = await BROWSER.newPage()

  # Set the HTML content, with the text in an email input
  await page.setContent "<html><input type='email' value='#{email}'></html>"

  # We can ask the DOM is an element matches a CSS selctor. A valid
  # email input would match a ':valid' CSS pseudo selector - evaluated in Chrome's console
  valid = await page.evaluate "document.querySelector('input').matches(':valid')"

  # Clean up by closing the page
  await page.close()

  # return the validity
  valid


#
# The webserver
#
app  = do require 'express'

app.get '/:email?', (req, res)->
  email = req.params.email

  # Ensure we were provided a non-empty string
  unless email
    return res.status(400).send 'No email provided'

  # Test the validity of the email address
  valid = await isValid email

  # If invalid, throw an HTTP 422 with a friendly error message
  unless valid
    return res.status(422).send "Invalid email address: '#{email}'"

  # If we're still here, the email must be valid!
  # return the email address with an HTTP 200 status code
  res.send email


#
# Either start a local server, or hook up to GCF
#
if process.env.NODE_ENV is 'production'
  exports.handler = app
else
  app.listen process.env.PORT or 2222
