//
//  DSClient.swift
//  Dollar Scholar
//
//  Created by Ben Lewis on 10/15/19.
//  Copyright © 2019 Ben Lewis. All rights reserved.
//

import Foundation

class DSClient {
    
    static let shared = DSClient()
    
    static let baseApi = "https://api.data.gov/ed/collegescorecard/v1/schools"
    
    func getRequest<T : Decodable>(_ url: String, _ completion: @escaping (DSResult<T>) -> Void) {
        let errorMessage = "An error occured"
        var result: DSResult<T>!
        let task = URLSession.shared.dataTask(with: URL(string: url)!){ data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                let responseBody = try? decoder.decode(T.self, from: data) as T
                if let body = responseBody {
                    result = DSResult.success(body)
                } else {
                    result = DSResult.error(errorMessage)
                }
            } else {
                result = DSResult.error(errorMessage)
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }
        task.resume()
    }
    
    func getSchoolSummaries(_ completion: @escaping (DSResult<SchoolSummaryResponse>) -> Void) {
        let fields = "fields=id,school.name,school.city,school.state,latest.earnings.10_yrs_after_entry.median"
        let reqs = "school.degrees_awarded.predominant=3&latest.student.size__range=1000.."
        let sortedBy = "sort=latest.earnings.10_yrs_after_entry.median:desc"
        let url = "\(DSClient.baseApi)?api_key=\(Secrets.apiKey.rawValue)&\(fields)&\(reqs)&\(sortedBy)&per_page=100"
        getRequest(url, completion)
    }
    
    func getSchoolDetails(_ id: Int, _ completion: @escaping (DSResult<SchoolDetailsResponse>) -> Void) {
        let fields = "id,school.name,latest.earnings.10_yrs_after_entry.working_not_enrolled.earnings_percentile.25,latest.earnings.10_yrs_after_entry.median,latest.earnings.10_yrs_after_entry.working_not_enrolled.earnings_percentile.75,latest.cost.tuition.out_of_state,latest.cost.tuition.in_state,latest.completion.completion_rate_4yr_100nt,latest.completion.completion_rate_4yr_150nt,latest.admissions.admission_rate.overall,latest.admissions.act_scores.midpoint.cumulative,latest.admissions.sat_scores.average.overall"
        let url = "\(DSClient.baseApi)?api_key=\(Secrets.apiKey.rawValue)&fields=\(fields)&id=\(id)"
        getRequest(url, completion)
    }
}
