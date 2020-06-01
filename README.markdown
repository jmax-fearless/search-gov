# USASearch Info

## Code Status

 [![Build Status](https://circleci.com/gh/GSA/search-gov.svg?style=svg)](https://circleci.com/gh/GSA/search-gov)
 [![Maintainability](https://api.codeclimate.com/v1/badges/fd0577360749c9b3d166/maintainability)](https://codeclimate.com/github/GSA/search-gov/maintainability)

## Dependencies

### Ruby

You will need the version of Ruby specified in `.ruby-version`. Verify that your path points to the correct version of Ruby:

    $ ruby -v

You should see output similar to the following:

    ruby 2.5.5p157 (2019-03-15 revision 67260) [x86_64-darwin18]
    
### Gems

For Rails 5, we use bundler; you should be able to get all the rest of the gems needed for this project like this:

    gem install bundler
    bundle install
    
### Services
The required services listed below can be configured and run using [Docker](https://www.docker.com/get-started).
You can run them all with `docker-compose up`. Alternatively, you can run them individually, i.e. `docker-compose up elasticsearch`. If you prefer to install and run the services without Docker, see the [wiki](https://github.com/GSA/search-gov/wiki/Local-Installation-and-Management-of-dependencies).

* [Elasticsearch](https://www.elastic.co/elasticsearch/) 6.8

We're using [Elasticsearch](http://www.elasticsearch.org/) 6.8 for fulltext search and query analytics.

To check settings and directory locations:

<!--TODO: UPDATE PORT--> 
<!--TODO: INSTALL ES 7?--> 

    $ curl "localhost:9200/_nodes/settings?pretty=true"
    
* [Kibana](https://www.elastic.co/kibana) - Kibana is not required, but can be very useful for debugging Elasticsearch. Confirm Kibana is available in your browser at http://localhost:5601.

* [MySQL](https://dev.mysql.com/doc/refman/5.6/en/) 5.6 - database
* [Redis](https://redis.io/) 5.0 - We're using the Redis key-value store for caching, queue workflow via Resque, and some analytics.

### Packages
The packages below are included in the custom Docker image used for building the search-gov app container.

* gcc - C++ compiler, required by the [cld3](https://github.com/akihikodaki/cld3-ruby) gem, which we use for language detection
* protobuf - Google's
[protocol buffers](https://developers.google.com/protocol-buffers/) package, also required by the cld gem


--------------------------------------------------
### Packages

The [cld3](https://github.com/akihikodaki/cld3-ruby) gem, which we use for language detection, depends on Google's
[protocol buffers](https://developers.google.com/protocol-buffers/) and
a C++ compiler:

    brew install gcc
    brew install protobuf


## Service credentials; how we protect secrets

The app does its best to avoid interacting with most remote services during the test phase through heavy use of the [VCR](https://github.com/vcr/vcr) gem.

You should be able to simply run this command:

```
cp config/secrets.yml.dev config/secrets.yml
```

To get a valid `secrets.yml` file that will work for running existing specs.

If you find that you need to run specs that interact with a remote service, you'll need to put valid credentials into your `secrets.yml` file.

Anything listed in the `secret_keys` entry of that file will automatically be masked by VCR in newly-recorded cassettes.

## Database


Create and setup your development and test databases. The database.yml file assumes you have a local database server up and running (MySQL 5.6.x), accessible from user 'root' with no password.

    $ docker-compose run --rm web bin/rails db:setup
    $ rake db:test:prepare


## Asset pipeline

A few tips when working with asset pipeline:

* Ensure that your asset directory is in the asset paths by running the following in the console:

        y Rails.application.assets.paths

* Find out which file is served for a given asset path by running the following in the console:

        Rails.application.assets['relative_path/to_asset.ext']

    

     
### Indexes

You can create the USASearch-related indexes like this:

    rake usasearch:elasticsearch:create_indexes

You can index all the records from ActiveRecord-backed indexes like this:

    rake usasearch:elasticsearch:index_all[FeaturedCollection+BoostedContent]

If you want it to run in parallel using Resque workers, call it like this:

    rake usasearch:elasticsearch:resque_index_all[FeaturedCollection+BoostedContent]

Note that indexing everything uses whatever index/mapping/setting is in place. If you need to change the Elasticsearch schema first, do this:

    rake usasearch:elasticsearch:recreate_index[FeaturedCollection]

If you are changing a schema and want to migrate the index without having it be unavailable, do this:

    rake usasearch:elasticsearch:migrate[FeaturedCollection]

Same thing, but using Resque to index in parallel:

    rake usasearch:elasticsearch:resque_migrate[FeaturedCollection]




## Imagemagick

We use Imagemagick to identify some image properties. It can also be installed with Homebrew on a Mac.

    $ brew install imagemagick

# Tests

We use poltergeist gem to test Javascript. This gem depends on PhantomJS.

Download and install PhantomJS:

<http://phantomjs.org/download.html>

It can also be installed with Homebrew on a Mac.

    $ brew tap homebrew/cask

    $ brew cask install phantomjs

If you see ```Error: The `brew link` step did not complete successfully``` when installing phantomjs, 

you may need to overwrite the symbolic link.
    
    $ brew link --overwrite phantomjs198

Make sure the unit tests, functional and integration tests run:

    rake

## Circle CI

We use [CircleCI](https://circleci.com/gh/GSA/usasearch) for continuous integration. Build artifacts, such as logs, are available in the 'Artifacts' tab of each CircleCI build.

# Code Coverage

We track test coverage of the codebase over time, to help identify areas where we could write better tests and to see when poorly tested code got introduced.

To show the coverage on the existing codebase, do this if you have not:

    rake

Then to view the report, open `coverage/index.html` in your favorite browser.

You can click around on the files that have < 100% coverage to see what lines weren't exercised.

Make sure you commit any changes to the coverage directory back to git.

# Running the app

Fire up a server and try it all out:

    rails server
or

    rails s

# Main areas of functionality

## Search

<http://127.0.0.1:3000>

You should be able to type in 'taxes' and get search results.

If you are interested in helath related data, you can also load MedLinePlus data
from the XML retrieved from the MedLine website (see doc/medline for more details).

    rake usasearch:medline:load

## Creating a new local admin account
[Login.gov](https://login.gov) is used for authentication.

To create a new local admin account we will need to:
1. Create an account on Login's sandbox environment.
2. Get the Login sandbox private key from a team member.
3. Add an admin user to your local app.

#### 1. Login sandbox
[Create an account](https://idp.int.identitysandbox.gov/sign_up/enter_email) on Login's sandbox environment. This will need to be a real, valid government email address that you can get emails at. Something like `your-real-name+search-local@gsa.gov`. You'll receive a validation email to set a password and secondary authentication method.

#### 2. Get the Login sandbox private key
Ask your team members for the current `config/logindotgov.pem` file. This private key will let your local app complete the handshake with the Login sandbox servers.

#### 3. Add a new admin user to your local app
Open the rails console, add a new user with the matching email.
```
u = User.where(email: 'your-real-name+search-local@gsa.gov').first_or_initialize
u.assign_attributes( contact_name: 'admin',
                     default_affiliate: Affiliate.find_by_name('usagov'),
                     is_affiliate: true,
                     organization_name: 'GSA',
                   )

u.approval_status = 'approved'
u.is_affiliate_admin = true
u.save!
```

You should now be able to login to your local instance of search.gov.

## Admin
Your user account should have admin priveleges set. Now go here and poke around.

<http://127.0.0.1:3000/admin>

## Asynchronous tasks
Several long-running tasks have been moved to the background for processing via Resque. Here is how to see this in
action on your local machine, assuming you have installed the Redis server.

1. Run the redis-server

    % redis-server

1. Launch the Sinatra app to see the queues and jobs

    % resque-web ./lib/setup_resque.rb

1. In your admin center, create a SAYT suggestion "delete me". Now create a SAYT filter on the word "delete":

    <http://localhost:3000/admin/>

1. Look in the Resque web queue to see the job enqueued.

1. Start a Resque worker to run the job:

    % QUEUE=* rake environment resque:work

At this point, you should see the queue empty in Resque web, and the suggestion "delete me" should be gone from the sayt_suggestions table.

### Queue names & priorities
Each Resque job runs in the context of a queue named 'primary' with priorities assigned at job creation time using the resque-priority Gem.
We have queues named :primary_low, :primary, and :primary_high. When creating a new
background job model, consider the priorities of the existing jobs to determine where your jobs should go. Things like fetching and indexing all
Odie documents will take days, and should run as low priority. But fetching and indexing a single URL uploaded by an affiliate should be high priority.
When in doubt, just use Resque.enqueue() instead of Resque.enqueue_with_priority() to put it on the normal priority queue.

### Scheduled jobs
We use the [resque-scheduler](https://github.com/resque/resque-scheduler) gem to schedule delayed jobs. Use [ActiveJob](http://api.rubyonrails.org/classes/ActiveJob/Core/ClassMethods.html)'s `:wait` or `:wait_until` options to enqueue delayed jobs, or schedule them in `config/resque_schedule.yml`.

Example:

1. Schedule a delayed job:

`MyJob.set(wait: 30.seconds).perform_later(args)`

2. Run the resque-scheduler rake task:

`rake resque:scheduler`

3. Check the 'Scheduled' tab in Resque web (see above) to see your job.

# Performance
We use New Relic to monitor our site performance, especially on search requests. If you are doing something around search, make
sure you aren't introducing anything to make it much slower. If you can, make it faster.

You can configure your local app to send metrics to New Relic.

1. Edit `config/secrets.yml` changing `enabled` to true and adding your name to `app_name` in the `newrelic` section

1. Edit `config/secrets.yml` and set `license_key` to your New Relic license key in the `newrelic_secrets` section

1. Run mongrel/thin

1. Run a few representative SERPs with news items, gov boxes, etc

1. Visit http://localhost:3000/newrelic

1. The database calls view was the most useful one for me. How many extra database calls did your feature introduce? Yes, they are fast, but at 10-50 searches per second, it adds up.

You can also turn on profiling and look into that (see https://newrelic.com/docs/general/profiling-ruby-applications).

### Additional developer resources
* [Local i14y setup](https://github.com/GSA/usasearch/blob/master/README_I14Y.markdown)