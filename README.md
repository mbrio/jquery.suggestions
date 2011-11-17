jquery.suggestions
==================

Requirements
------------
* The current version of jquery.suggestions was developed using [jQuery](http://jquery.com) 1.6.2.

Introduction
------------
jquery.suggestions is a library that enables AJAX autocomplete backed by a localStorage cache for text input fields.

Usage
-----
  jQuery.fn.suggestions(params)
  
Parameters
----------
* `@params` = The suggections parameters
  * `url` = The URL of the REST action, any reference to `:query` within the string will be replaced by the text within the input box.
    (default: '/autocomplete?q=:query')
  

Example
-------
  $("#search").suggestions({
    url: 'autocomplete.json?q=:query',
  });

REST API Results
----------------
When retrieving data from a REST API you must return a JSON formatted response from a GET request.

The JSON data must be formatted as follows:

  {
    "nodes": [
      { "name": "Alabama" },
      { "name": "Alaska" },
      { "name": "American Samoa" },
      { "name": "Arizona" },
      { "name": "Arkansas" }
    ]
  }
