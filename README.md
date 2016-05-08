# MovieInfoApp
a simple movie information app

![Alt Text](https://github.com/jmade/jmade.github.io/blob/master/movieinfo.png?raw=true)

## Overview

This is a app using web APIs to get information about movies & tv shows from the [Open Movie Database](http://omdbapi.com).
After reading over some of the AFNetworking I started to understand how to use web APIs. 

*I donated to get the movie cover API Key, you'll need to do that in order to get it to work on your end, otherwise use an alternate image cover source.*

## Movie Info View

![Alt Text](https://github.com/jmade/jmade.github.io/blob/master/movietv.gif?raw=true)

The Info Page is a header view 1/3 of the size of the Device Screen that scrolls over the entire cover like a magnifying glass as you sroll down the tableview full of information stocked by the web request.


## Movie Cover Animation

![Alt Text](https://github.com/jmade/jmade.github.io/blob/master/moviecover.gif?raw=true)

After working with some recent 3D projects and using `CAReplicator` I wanted to create a view that was interactive using the users scrolling and also revealed the entire movie cover at once, kinda like how safari shows a full screen image in the list of tabs for visual refrence.

## Search

![Alt Text](https://github.com/jmade/jmade.github.io/blob/master/moviesearching2.gif?raw=true)

You can search and find quite alot of results. Overall as this was my first attempt at writing an application that uses web request to data and then manipulating that data, this was a fantastic API and learning tool. 

I implemented a pretty basic cache system, a dictionary that keeps the results and then saves that in the `NSUserDefaults`. 

