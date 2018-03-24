# WikiFetcher

The goal of this project is to present a simple use of interactions with Wikimedia API.

##Main functions
The app presents itself with a search bar where you can insert a title of a wikipedia page, once you tap on search button the app will download all the images in the selected page. 

##Design Pattern
The main pattern is classic MVC separating entities in 3 main groups:

###View Controllers
- The clas ***ViewController*** is responsible to coordinate the interaction beetwen the data provider and the view.
- The class ***ImageDetailViewController*** is responsible to present the detail of a downladed image.

###Data Providers
- The class ***WikiPageFetcher*** is the only data provider used to wrap the interaction with Wikimedia APIs.

###Entities Communications
- The class ***WikiPageFetcher*** uses another class to wrap any single API call, they communicate via Delegate object pattern.
- The class ***ViewController*** uses the WikiPageFetcher to obtain data, they communicate using the NSNotifications pattern.

###Multi Threading
Once the ***image*** API returns the info related to every image in a page, the download of every image is done in a separated thread allowing the interface thread to go and update in smooth way.

###Memory Handling
This project does not use ARC in order to show how memory is handled, every resource is allocated and deallocated when no more needed.

###Custom Views
The class ***ToastView*** offers a static method to notify messages to the user.


	