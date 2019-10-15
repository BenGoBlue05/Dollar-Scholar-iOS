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
                print(message)
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
        school.completionRate4yr = model.completionRate4yr
        school.completionRate6yr = model.completionRate6yr
        if let actAvg = model.actAvg {
            school.actAvg = Int32(actAvg.rounded())
        }
        if let satAvg = model.satAvg {
            school.satAvg = Int32(satAvg.rounded())
        }
        school.acceptanceRate = model.acceptanceRate
        school.earnings25thPercentile = Int32(model.earnings25)
        school.earningsMedian = Int32(model.earnings50)
        school.earnings75thPercentile = Int32(model.earnings75)
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
        earnings25Label.text = "$\(school.earnings25thPercentile)"
        earnings75Label.text = "$\(school.earnings75thPercentile)"
        tuitionInStateLabel.text = "$\(school.costInState)"
        tuitionOutOfStateLabel.text = "$\(school.costOutOfState)"
        completionRate4yrLabel.text = formatPercent(school.completionRate4yr)
        completionRate6yrLabel.text = formatPercent(school.completionRate6yr)
        actLabel.text = String(school.actAvg)
        satLabel.text = String(school.satAvg)
        acceptanceRateLabel.text = self.formatPercent(school.acceptanceRate)
    }
    
    func formatPercent(_ dec: Double) -> String {
        let percent = Int((dec * 100).rounded())
        return "\(percent)%"
    }
    
}
