path = require("path")
fs = require("fs")

CSON = require "c50n"
JSCK = require("jsck").draft3

schema = require("./schema")
jsck = new JSCK schema

example =
  mappings:
    things:
      resource: "things"
      path: "/things"
      query:
        limit:
          type: "integer"

  resources:
    things:
      actions:
        list:
          method: "GET"
          query:
            sort:
              type: "string"
              enum: ["asc", "desc"]
          response_schema: "foo_list"

  schema:
    id: "urn:pb-app"
    thing:
      type: "object"
      properties:
        name:
          type: "string"
          required: true
    thing_list:
      type: "array"
      items: {$ref: "#thing"}

    
module.exports =

  validate: (api_file) ->
    api_file = path.resolve(api_file)
    try
      api = require(api_file)
      report = jsck.schema("urn:patchboard.api#").validate api
      if report.valid == true
        console.log "Valid API definition"
      else
        console.log "Invalid API.  Errors:", report.errors
        process.exit(1)
    catch error
      console.log "Problem reading API description:", error.message
      process.exit(1)

  generate: (type) ->
    if type == "json"
      api = example
      string = JSON.stringify(api, null, 2)
      fs.writeFileSync("api.json", string)
    else if type == "cson"
      api = example
      string = CSON.stringify(api)
      fs.writeFileSync("api.cson", string)
    else
      console.log "Unsupported type: #{type}"
