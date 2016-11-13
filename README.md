# Phunware
Interview Project

Welcome to the Phunware wiki!

Timeframe: Around 10-12 hours, due to implementing animations and re-researching how I did previous viewControllerAnimation transitions, as well as thinking through the process of how to implement them. Also, verifying user flows and acceptance criteria and finding bugs and fixing them. Also, may have overlooked the iOS 8 and above requirement, and was using stackViews as well as new CoreData api for iOS 10. XD

Assumptions Made: 1. Make a network request every time the user runs the application to refresh the data, if there is no internet connection use the existing persisted information. 2. Lots of assumptions made on wireframes. 3. Did the animations as best as I could given the timeframe: First animation was in the main screen the animation presents the view controller from the original place of the tapped item. Second animation fade out the detail screen. Third animation when the detail screen content is too long "Funeral of Qui-Gon Jinn", as you scroll a nav bar is suppose to present itself.

Requirements: 1: Consume JSON Feed and do not store locally: My solution to that was use NSURLSession to make a GET request as well as store the response into Core Data for persistence and setup the model.

2: Display the feed in the master/detail app, using the wireframe spec for design requirements: My solution according to the wireframe given was to use a UICollectionView, since the app had slight variations between iPhone/iPad.

3: Based off of the service response some fields may not exist: My solution was when parsing to account for the nil cases as well as let the model objects have optional values.

4: Application must be with or without network connection after the first time the data is loaded: Used Core Data for persistence from initial data request call

5: App should run on iPhones portrait(minimum) as well as all orientations iPad: Solution used code checks for device specification as well as the new trait collection size classes in storyboard to layout the collection view appropriately.

6: Should work on iOS 8.0 and above: Supporting all versions

Tools Used: Xcode, PaintCode for asset generation
