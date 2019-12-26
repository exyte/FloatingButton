//
//  HostingController.swift
//  Example
//
//  Created by Dmitry Shipinev on 26.12.2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI

class HostingController: UIHostingController<ContentView> {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
}
