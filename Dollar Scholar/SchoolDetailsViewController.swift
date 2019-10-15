//
//  SchoolDetailsViewController.swift
//  Dollar Scholar
//
//  Created by Ben Lewis on 10/15/19.
//  Copyright © 2019 Ben Lewis. All rights reserved.
//

import UIKit
import CoreData

class SchoolDetailsViewController: UIViewController {

    var summary: SchoolSummary!
    
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var earnings25Label: UILabel!
    
    @IBOutlet weak var earnings50Label: UILabel!
    
    @IBOutlet weak var earnings75Label: UILabel!
    
    @IBOutlet weak var tuitionInStateLabel: UILabel!
    
    @IBOutlet weak var tuitionOutOfStateLabel: UILabel!
    
    @IBOutlet weak var completionRate4yrLabel: UILabel!
    
    @IBOutlet weak var completionRate6yrLabel: UILabel!
    
    @IBOutlet weak var actLabel: UILabel!
    
    @IBOutlet weak var satLabel: UILabel!
    
    @IBOutlet weak var acceptanceRateLabel: UILabel!
    
    func loadSchoolDetails(id: Int32){
        loadingIndicator.startAnimating()
        let request: NSFetchRequest<SchoolDetails> = SchoolDetails.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        if let school = try? viewContext().fetch(request).first {
            loadingIndicator.stopAnimating()
            self.populateViews(school)
        } else {
            self.fetchSchool(Int(id))
        }
    }
    
    func fetchSchool(_ id: Int){
        DSClient.shared.getSchoolDetails(id){ result in
            switch result{
            case .error(let message):
                self.loadingIndicator.stopAnimating()
                self.showError(message)
            case .success(let response):
                self.saveSchoolDetails(response.results.first!)
            }
        }
    }
    
    func saveSchoolDetails(_ model: SchoolDetailsResponseModel) {
        let context = viewContext()
        print(model)
        let school = SchoolDetails(context: context)
        school.id = Int32(model.id)
        school.name = model.name
        school.costInState = Int32(model.tuitionInState)
        school.costOutOfState = Int32(model.tuitionOutOfState)
        if let completionRate = model.completionRate4yr {
            school.completionRate4yr = completionRate
        }
        if let completionRate = model.completionRate6yr {
            school.completionRate6yr = completionRate
        }
        if let actAvg = model.actAvg {
            school.actAvg = Int32(actAvg.rounded())
        }
        
        if let satAvg = model.satAvg {
            school.satAvg = Int32(satAvg.rounded())
        }
        if let rate = model.acceptanceRate {
            school.acceptanceRate = rate
        }
        if let earnings = model.earnings25 {
            school.earnings25thPercentile = Int32(earnings)
        }
        if let earnings = model.earnings75 {
            school.earnings75thPercentile = Int32(earnings)
        }
        school.earningsMedian = Int32(model.earnings50)
        context.insert(school)
        saveContext()
        loadingIndicator.stopAnimating()
        populateViews(school)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateInitialViews(summary)
        loadSchoolDetails(id: summary.id)
    }
    
    func populateInitialViews(_ summary: SchoolSummary) {
        nameLabel.text = summary.name
        locationLabel.text = "\(summary.city!), \(summary.state!)"
        earnings50Label.text = "$\(summary.med10yrEarnings)"
    }
    
    func populateViews(_ school: SchoolDetails) {
        if school.earnings25thPercentile > 0 {
            earnings25Label.text = "$\(school.earnings25thPercentile)"
        }
        if school.earnings75thPercentile > 0 {
            earnings75Label.text = "$\(school.earnings75thPercentile)"
        }
        tuitionInStateLabel.text = "$\(school.costInState)"
        tuitionOutOfStateLabel.text = "$\(school.costOutOfState)"
        if school.completionRate4yr > 0 {
            completionRate4yrLabel.text = formatPercent(school.completionRate4yr)
        }
        if school.completionRate6yr > 0 {
            completionRate6yrLabel.text = formatPercent(school.completionRate6yr)
        }
        if school.actAvg > 0 {
            actLabel.text = String(school.actAvg)
        }
        if school.satAvg > 0 {
            satLabel.text = String(school.satAvg)
        }
        if school.acceptanceRate > 0 {
            acceptanceRateLabel.text = self.formatPercent(school.acceptanceRate)
        }
    }
    
    func formatPercent(_ dec: Double) -> String {
        let percent = Int((dec * 100).rounded())
        return "\(percent)%"
    }
    
}
