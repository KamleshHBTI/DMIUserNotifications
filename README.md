# DMIUserNotifications
DMIUserNotifications makes it extremely easy to setup a local notification, while making it easy to repeat notifications, and encapsulating away the intricacies of the User Notifications Framework.

[User Notifications](https://developer.apple.com/reference/usernotifications)

This library makes it easy to setup a local notification and also includes easy configuration for repeating notifications using [ .None, .Minute, .Hourly, .Daily, .Monthly, .Yearly] .

It also includes all the new features, including inserting attachments and changing the launch image of a notification.

1. [Features](#features)
2. [Requirements](#requirements)
3. [Installation](#installation)
    - [CocoaPods](#cocoapods)
    - [Manually](#manually)

4. [Contribute](#contribute)

## Features

- [x] Easily Repeat Notifications
- [x] Location Based Notifications
- [x] Category Action buttons
- [x] Queue to enforce 64 notification limit

## Requirements

- iOS 10.0+
- Xcode 8.0+

## Installation

#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install `DLLocalNotifications` by adding it to your `Podfile`:

```ruby
platform :ios, '10.0'
use_frameworks!
source 'https://github.com/KamleshHBTI/DMIUserNotifications.git'
target 'MyApp' do
	pod 'DMIUserNotifications', '~>0.0.1'
end
```


Note: your iOS deployment target must be 10.0+

## Contribute

We would love for you to contribute to **DMIUserNotifications**, check the ``LICENSE`` file for more info.

## Meta

Kamlesh Kumar – (parthhbti@gmail.com)

Distributed under the MIT license. See ``LICENSE`` for more information
