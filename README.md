lambeth_libraries
=================

A scraper for displaying the opening hours of libraries in Lambeth (a borough of London, UK)

TODO:
-----

* Make into a gem
* Create a webpage that periodically scrapes this data and displays it all on one page

Feedback
--------
This is my first real attempt at a number of things:

  * TDD from the beginning
  * A scraper directly in Nokogiri
  * A command line app
  
Any feedback on the following topics would be gratefully received:

  * Application layout
  * Method structure
  * Test suite 

Installation
-------------
 
Until I make this a gem, you'll need to do a couple of steps to install it. First off you'll need Ruby 1.9 or greater and Bundler

1. Clone the repo
2. Install the bundled gems:

        % bundle install
    
3. Add the bin directory to your path - e.g. add the following line into your .bashrc:

        export PATH="path/to/directory/lambeth_libraries/bin/:$PATH"
   
Usage
------

To display all the opening times for Lambeth's libraries:

    % lambeth_libraries
    
To display the opening times for a particular library:

    % lambeth_libraries Brixton

To display the opening times for a particular day:

    % lambeth_libraries Tuesday
    % lambeth_libraries Today
    % lambeth_libraries Tomorrow
    
To display the list of libraries:

    % lambeth_libraries list