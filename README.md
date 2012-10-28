PagerDuty API Usage
===================

* PagerDuty API: http://developer.pagerduty.com/

## Description


This project contains example usage of the [PagerDuty API](http://developer.pagerduty.com/)


## Installation

    $ git clone git://github.com/PagerDuty/api-examples.git
    $ cd api-examples/shutupall
    $ bundle install

## Documentation


### shutupall
create a PagerDuty Maintenance Window with all PagerDuty Services in the account

    $ bundle exec ruby shutupall.rb duration_in_minutes subdomain email password

## License

See LICENSE file.