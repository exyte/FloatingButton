<img src="https://github.com/exyte/FloatingButton/blob/master/Assets/header.png">
<img align="right" src="https://raw.githubusercontent.com/exyte/FloatingButton/master/Assets/demo.gif" width="480" />

<p><h1 align="left">FloatingButton</h1></p>

<p><h4>Easily customizable floating button menu created with SwiftUI</h4></p>

___

<p> We are a development agency building
  <a href="https://clutch.co/profile/exyte#review-731233">phenomenal</a> apps.</p>

</br>

<a href="https://exyte.com/contacts"><img src="https://i.imgur.com/vGjsQPt.png" width="134" height="34"></a> <a href="https://twitter.com/exyteHQ"><img src="https://i.imgur.com/DngwSn1.png" width="165" height="34"></a>

</br></br>
[![Travis CI](https://travis-ci.org/exyte/FloatingButton.svg?branch=master)](https://travis-ci.org/exyte/FloatingButton)
[![Version](https://img.shields.io/cocoapods/v/FloatingButton.svg?style=flat)](http://cocoapods.org/pods/FloatingButton)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-0473B3.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/FloatingButton.svg?style=flat)](http://cocoapods.org/pods/FloatingButton)
[![Platform](https://img.shields.io/cocoapods/p/FloatingButton.svg?style=flat)](http://cocoapods.org/pods/FloatingButton)
[![Twitter](https://img.shields.io/badge/Twitter-@exyteHQ-blue.svg?style=flat)](http://twitter.com/exyteHQ)

# Usage

1. Create main button view and a number of submenu buttons — both should be cast to `AnyView` type.
2. Pass both to `FloatingButton` constructor:

   ```swift
   FloatingButton(mainButtonView: mainButton, buttons: buttons)
   ```
3. Chain `.straight()` or `.circle()` to specify desired menu type.
4. Chain whatever you like afterwards.

### Universal options
`spacing` - space between submenu buttons  
`initialScaling` - size multiplyer for submenu buttons when the menu is closed  
`initialOffset` - offset for submenu buttons when the menu is closed  
`initialOpacity` - opacity for submenu buttons when the menu is closed  
`animation` - custom SwiftUI animation like `Animation.easeInOut()` or `Animation.spring()`  
`delays` - delay for each submenu button's animation start

### Straight menu only options

`direction` - position of submenu buttons relative to main menu button  
`alignment` - alignment of submenu buttons relative to main menu button 

### Circle only options

`startAngle`  
`endAngle`  
`radius`

## Examples

To try out the FloatingButton examples:
1. Clone the repo `git clone git@github.com:exyte/FloatingButton.git`.
2. Open terminal and run `cd <FloatingButtonRepo>/Example`.
3. Run `pod install` to install all dependencies.
4. Run `xed .` to open project in the Xcode.
5. Try it!

## Installation

### CocoaPods

```ruby
pod 'FloatingButton'
```

### Carthage

```ogdl
github "Exyte/FloatingButton"
```

### Manually

Drop [FloatingButton.swift](https://github.com/exyte/FloatingButton/blob/master/Source/FloatingButton.swift) into your project.

## Requirements

* iOS 13+ / watchOS 13+ / tvOS 13+ / macOS 10.15+
* Xcode 11+
