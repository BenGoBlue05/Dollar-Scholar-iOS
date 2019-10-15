//
//  DSResult.swift
//  Dollar Scholar
//
//  Created by Ben Lewis on 10/15/19.
//  Copyright © 2019 Ben Lewis. All rights reserved.
//

import Foundation

enum DSResult<T>{
    case success(T)
    case error(String)
}
