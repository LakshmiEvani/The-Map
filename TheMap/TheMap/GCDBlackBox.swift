//
//  GCDBlackBox.swift
//  TheMap
//
//  Created by Souji on 7/17/16.
//  Copyright © 2016 Souji. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}