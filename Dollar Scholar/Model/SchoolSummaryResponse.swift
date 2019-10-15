//
//  SchoolSummaryResponse.swift
//  Dollar Scholar
//
//  Created by Ben Lewis on 10/15/19.
//  Copyright © 2019 Ben Lewis. All rights reserved.
//

import Foundation

struct SchoolSummaryResponse : Codable {
    let results: [SummaryResponseModel]
}

struct SummaryResponseModel : Codable {
    let id: Int
    let name: String
    let earnings: Int
    let city: String
    let state: String
    
    enum CodingKeys : String, CodingKey {
        case id
        case name = "school.name"
        case earnings = "latest.earnings.10_yrs_after_entry.median"
        case city = "school.city"
        case state = "school.state"
    }
}
