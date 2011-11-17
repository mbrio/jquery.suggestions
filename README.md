jquery.suggestions
==================

Requirements
------------
* The current version of jquery.suggestions was developed using [jQuery](http://jquery.com) 1.6.2.
* A JS [localStorage polyfill](https://gist.github.com/350433)

Introduction
------------
jquery.suggestions is a library that enables AJAX autocomplete backed by a localStorage cache for text input fields.

Usage
-----
  jQuery.fn.suggestions(params)
  
Parameters
----------
* `@params` = The suggections parameters
  * `url` = The URL of the REST action, any reference to `:query` within the string will be replaced by the text within the input box. (default: '/autocomplete?q=:query')
  * `timeout` = Waiting period before asking for a suggestion. (default: 500)
  * `listClass` = The CSS class that is applied to the `<ol>` element. (default: 's-l')
  * `listItemClass` = The CSS class that is applied to the `<li>` elements. (default: 's-li')
  * `listItemEmptyClass` = The CSS class that is applied to the `<li>` elements when no suggestion has been made yet. (default: 's-lie')
  * `listItemAnchorClass` = The CSS class that is applied to the `<a>` elements. (default: 's-lia')
  * `listItemSelectedClass` = The CSS class that is applied to the `<li>` elements that are selected. (default: 's-lis')
  * `listItemNoResultsClass` = The CSS class that is applied to the `<li>` elements when there are no suggestions. (default: 's-linr')
  * `listItemLoadingClass` = The CSS class that is applied to the `<li>` elements when the AJAX call is loading. (default: 's-lil')
  * `listItemErrorClass` = The CSS class that is applied to the `<li>` elements when an AJAX or JSON parsing error occurs. (default: 's-lil')
  * `listZIndex` = The z-index of the `<ol>` element. (default: 500)
  * `defaultHTML` = The default HTML to use when no suggestion has been made yet. (default: 'Start typing for suggestions')
  * `defaultLoadingHTML` = The HTML to display when loading during an AJAX call. (default: 'Loading...')
  * `defaultErrorHTML` = The HTML to display when an AJAX or JSON parsing error occurs. (default: 'Error...')
  * `defaultNoResultsHTML` = The HTML to display when there are no suggestions. (default: 'There are no suggestions')
  * `suggesting` = The callback that is executed when the application begins the suggestion process.
  * `callback` = The callback that is executed when suggestions are displayed
  * `ajaxError` = The callback that is executed when an AJAX error occurs.
  * `parseError` = The callback that is executed when a JSON parsing error occurs.
  

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
