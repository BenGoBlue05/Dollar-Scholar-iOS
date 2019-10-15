//
//  ViewController.swift
//  Dollar Scholar
//
//  Created by Ben Lewis on 10/15/19.
//  Copyright © 2019 Ben Lewis. All rights reserved.
//

import UIKit
import CoreData
class SchoolsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var fetchedResultsController: NSFetchedResultsController<SchoolSummary>!
    
    fileprivate func setUpFetchedResultsController() {
        let context = viewContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let request: NSFetchRequest<SchoolSummary> = SchoolSummary.fetchRequest()
        let sortby = NSSortDescriptor(key: "med10yrEarnings", ascending: false)
        request.sortDescriptors = [sortby]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "summaries")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFetchedResultsController()
        fetchSchoolSummaries()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "summaryTableViewCell") as! SummaryTableViewCell
        let info = fetchedResultsController.object(at: indexPath)
        cell.nameLabel.text = info.name
        cell.locationLabel.text = "\(info.city!), \(info.state!)"
        cell.earningsLabel.text = "$\(info.med10yrEarnings)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let schoolSummary = fetchedResultsController.object(at: indexPath)
        let vc = storyboard?.instantiateViewController(identifier: "schoolDetailsViewController") as! SchoolDetailsViewController
        vc.summary = schoolSummary
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchSchoolSummaries() {
        DSClient.shared.getSchoolSummaries { result in
            switch result {
            case .error(let message):
                print(message)
            case .success(let response):
                self.insertSchoolSummaries(response.results)
            }
        }
    }
    
    func insertSchoolSummaries(_ models: [SummaryResponseModel]) {
        let context = viewContext()
        models.forEach { model in
            let summary = SchoolSummary(context: context)
            summary.id = Int32(model.id)
            summary.city = model.city
            summary.state = model.state
            summary.name = model.name
            summary.med10yrEarnings = Int32(model.earnings)
            context.insert(summary)
        }
        saveContext()
    }
}

extension SchoolsViewController : NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError("Unknown change type")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        @unknown default:
            fatalError("Unknown change type")
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension UIViewController {
    func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func viewContext() -> NSManagedObjectContext {
        return  (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
}
