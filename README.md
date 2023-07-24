# Follett Destiny API client library for Ruby

Client library for working with Follett Destiny API in Ruby

## Usage

```ruby
require 'follett_destiny'
client = FollettDestiny::Client.instance
pp client.sites
# [{"guid"=>"********-****-****-****-************",
#   "name"=>"Example School",
#   "librarySite"=>true,
#   "textbookSite"=>false,
#   "resourceSite"=>true,
#   "districtWarehouse"=>false,
#   "districtAdvancedBooking"=>false,
#   "siteType"=>{"id"=>1, "name"=>"Example Type", "priorityOrder"=>1},
#   "mediaSite"=>false,
#   "portalEnabled"=>false},
#   …
```

## Environment

- `FOLLETT_DESTINY_BASE_URI` *https://\<destiny_host>/api/v1/rest/context/\<context>*
- `FOLLETT_DESTINY_CLIENT_ID`
- `FOLLETT_DESTINY_CLIENT_SECRET`


## Reference Documentation

- [Destiny Open APIs Developers Guide](https://www.follettcommunity.com/s/article/Destiny-Open-APIs-Developers-Guide)
- [Destiny API - Authentication](openapi/resources-api.yaml)
- [Destiny API - Resources](openapi/resources-api.yaml)
- [Destiny API - Sites](openapi/resources-api.yaml)
