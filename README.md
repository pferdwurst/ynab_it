# YnabIt

DirectConnect-y for YNAB


YNAB (http://www.youneedabudget.com/) is great budgeting software.   However, by design it does not give you the convenience of automatically downloading and importing your financial data into the ledger.  Official position from YNAB:

   "We've found the direct connection to banks really pulls people away from their money (psychologically). We don't have any plans to add direct connect into the software--from a philosophical standpoint--as the further you are removed from your money, the easier it is to remove your money from you."  (http://bit.ly/19oKTWW)
   
   Unfortunately, not being able to automatically download my financial data makes the software a non-starter for me.  Maybe for others too.  I just am not that organized.
   
   

ynab_it uses Intuit's Customer Account Data API to aggregate financial institution accounts (banking, mortgage, credit cards, investments) transactions on disk and massages them into a format that YNAB can later ingest.  So yes, there's still the manual import step but, thankfully, the distance traversed is only a few sectors on your drive.


## Installation

Add this line to your application's Gemfile:

    gem 'ynab_it'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ynab_it

## Usage

TODO: Use often, use wisely.


