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
SUPPORTED_TYPES = 'email url tel'.split ' '

isValid = (value='', type)->
  return Promise.resolve false unless type in SUPPORTED_TYPES

  # Open a new page in Chrome
  await initBrowser()
  page = await BROWSER.newPage()

  # Set the HTML content, with the text in an email input
  await page.setContent "<html><input type='#{type}' value='#{value}'></html>"

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

TYPE_PATTERN = SUPPORTED_TYPES.join '|'
VALUE_PATTERN = '[\\w\\d\\s+%\\|\\/\\[\\]:.@\\-_]+'

app.get "/:type(#{TYPE_PATTERN})/:value(#{VALUE_PATTERN})", (req, res)->
  { type, value } = req.params

  # Test the validity of the email address
  valid = await isValid value, type

  # If invalid, throw an HTTP 422 with a friendly error message
  unless valid
    return res.status(422).send "🚫 Invalid #{type}: '#{value}'"

  # If we're still here, the email must be valid!
  # return the email address with an HTTP 200 status code
  res.send "✅ Valid #{type}: '#{value}'"

app.get '*', (req,res)->
  res.status(400).send "🚫 Requests should be in the form '/type/value' where type is one of: #{SUPPORTED_TYPES.join ', '}"

#
# Either start a local server, or hook up to GCF
#
if process.env.NODE_ENV is 'production'
  exports.handler = app
else
  app.listen process.env.PORT or 2222
