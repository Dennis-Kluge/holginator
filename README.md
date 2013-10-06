# Holginator
The Holginator merges and filters multiple Podcast feeds into a single one. This helps you to keep track of a single podcaster and his / her shows over multiple formats. 

## Installation
The Holginator consists of two parts: 
* A Sinatra based frontend which serves the feeds.
* A Rake task which composes and filters the feeds and saves them in the public directory.

Clone the repository create a Dyno on Heroku and add a cron job to execute the `holginator:create_feeds` Rake task. 

## Configuration
The configuration is handled in the `feeds.json` which declares all composed feeds. An example is shown below:   

    {
      "composed_feeds": [
        {
          "name": "holgi_blue_moon_lateline",
          "title": "Ein Feed aller Formate von und mit Holgi", 
          "description": "foobar",
          "image": "/path/to/image",
          "feeds": [
            {
              "url": "http://podcast.hr-online.de/lateline/podcast.xml",
              "filter": "(h|H)olger"
            }, 
            {
              "url": "http://www.fritz.de/podcasts/sendungen/Blue_Moon.feed.podcast.xml",
              "filter": "(h|H)olger"
            }
          ]
        }
      ]
    }

Each composed feed consists of: 

* a name: The (file)name of the final feed
* a title: The title of the feed
* a description: The discription of the feed
* an image: The image of the feed which can be seen in the player
* feeds: A list of all feeds consisting the url and a filter. The filter is a regular expression and applied to the title and description. When no filter is given all items are merged to the composed feed.

## Testing 
For testing purposes you can use the task `holginator:test_feed[feed_name]`. In this case the feed is composed and written to stdio.

## Contributions
Write an issue or fork the repository and send a pull request. 

## License
MIT 