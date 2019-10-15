//
//  SchoolDetailsResponse.swift
//  Dollar Scholar
//
//  Created by Ben Lewis on 10/15/19.
//  Copyright © 2019 Ben Lewis. All rights reserved.
//

import Foundation

struct SchoolDetailsResponse : Codable {
    let results: [SchoolDetailsResponseModel]
}

struct SchoolDetailsResponseModel : Codable {
    let id: Int
    let name: String
    let tuitionInState: Int
    let tuitionOutOfState: Int
    let completionRate4yr: Double?
    let completionRate6yr: Double?
    let actAvg: Double?
    let satAvg: Double?
    let acceptanceRate: Double?
    let earnings25: Int?
    let earnings50: Int
    let earnings75: Int?
    
    enum CodingKeys : String, CodingKey {
        case id
        case name = "school.name"
        case tuitionInState = "latest.cost.tuition.in_state"
        case tuitionOutOfState = "latest.cost.tuition.out_of_state"
        case completionRate4yr = "latest.completion.completion_rate_4yr_100nt"
        case completionRate6yr = "latest.completion.completion_rate_4yr_150nt"
        case actAvg = "latest.admissions.act_scores.midpoint.cumulative"
        case satAvg = "latest.admissions.sat_scores.average.overall"
        case acceptanceRate = "latest.admissions.admission_rate.overall"
        case earnings25 = "latest.earnings.10_yrs_after_entry.working_not_enrolled.earnings_percentile.25"
        case earnings50 = "latest.earnings.10_yrs_after_entry.median"
        case earnings75 = "latest.earnings.10_yrs_after_entry.working_not_enrolled.earnings_percentile.75"
    }
}
