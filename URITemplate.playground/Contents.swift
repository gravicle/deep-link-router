/*:

 ### Goals
 
 * Extensible: Adding new `action`s should not involve modifying routing, like what would happen with a `switch`.
 * Statically checked: Matching should be statically verifiable
 * Namespaced: `Action.DoSomething`
 * Seperation of side-effects from initialization: Allows passing actions as data.
 
 */

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

import Foundation
import URITemplate

//MARK: - Infrastructure

struct Route {
    let template: URITemplate
    
    func params(from url: URL) -> [String : String] {
        return template.extract(url.absoluteString) ?? [:]
    }
    
    init(path: String) {
        template = URITemplate(template: "{scheme}://{.hostname}/\(path){?unhandledParams}")
    }
}

protocol Actionable {
    func perform()
}

protocol Routable {
    static var path: String { get }
    static var route: Route { get }
    init?(url: URL)
}

extension Routable {
    static var route: Route {
        return Route(path: path)
    }
}

typealias RoutableAction = Routable & Actionable

//MARK: - Actions

struct Action {
    
    private static var allRoutableActions: [RoutableAction.Type] {
        return [ShowAppointmentSummary.self, ShowDirections.self]
    }
    
    static func from(url: URL) -> Actionable? {
        guard
            url.host == "app-dev.circlemedical.com" ||
            url.host == "app.circlemedical.com"
        else { return nil }
        
        return allRoutableActions.flatMap({ $0.init(url: url) }).first
    }
    
}


// MARK: Show Appointment Summary

extension Action {
    
    struct ShowAppointmentSummary: Actionable {
        let id: String
        
        func perform() {
            print("Showing appt. summary \(id)")
        }
    }
    
}

extension Action.ShowAppointmentSummary: Routable {
    
    static var path: String { return "appointment/{id}/summary" }
    
    init?(url: URL) {
        let params = Action.ShowAppointmentSummary.route.params(from: url)
        guard let id = params["id"] else { return nil }
        self.id = id
    }
    
}

// MARK: Show Directions
// Example showing URL with query params

extension Action {
    
    struct ShowDirections: Actionable {
        struct Address {
            let street, city: String
            let zip: Int
        }
        
        let address: Address
        
        func perform() {
            print("Showing directios to \(address.street), \(address.city)")
        }
    }
    
}

extension Action.ShowDirections: Routable {
    
    static var path: String { return "directions?street={street}&city={city}&zip={zip}" }
    
    init?(url: URL) {
        let params = Action.ShowDirections.route.params(from: url)
        guard
            let street = params["street"],
            let city = params["city"],
            let zip = params["zip"].flatMap({ Int($0) })
        else { return nil }
        
        self.address = Address(street: street, city: city, zip: zip)
    }
    
}

// MARK: - Set Notifications Badge
// Example of a non-routable action that can be directly called
extension Action {
    
    struct SetNotificationsBadge {
        let count: UInt
    }
    
}

extension Action.SetNotificationsBadge: Actionable {
    
    func perform() {
        print(count == 0 ? "Removing the badge" : "\(count) new notifications")
    }
    
}

//MARK: - Call Sites

// Match to appoointment summary
let appt = URL(string: "https://app.circlemedical.com/appointment/a30f4f3a-c14a-461f-983f-c92a9a38b2ed/summary")!
if let action = Action.from(url: appt) {
    action.perform()
} else { print("URL cannot be handled") }

// Match to directions
let dir = URL(string: "https://app.circlemedical.com/directions?street=431%20Jessie%20St&city=San%20Francisco&zip=94103&country=USA")!
if let action = Action.from(url: dir) {
    action.perform()
} else { print("URL cannot be handled") }

//Set Badge
Action.SetNotificationsBadge(count: 2).perform()