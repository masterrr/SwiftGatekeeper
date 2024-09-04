import XCTest
@testable import SwiftGatekeeper

final class SwiftGatekeeperTests: XCTestCase {
    var gatekeeper: SwiftGatekeeper!

    override func setUp() {
        gatekeeper = SwiftGatekeeper()
    }

    func testResourceCreation() {
        let rootID = gatekeeper.createResource(name: "root", parentID: nil)
        let childID = gatekeeper.createResource(name: "child", parentID: rootID)

        let rootAccess = gatekeeper.checkAccess(resourceID: rootID, userID: "user1")
        let childAccess = gatekeeper.checkAccess(resourceID: childID, userID: "user1")

        XCTAssertFalse(rootAccess, "Root access should be denied by default")
        XCTAssertFalse(childAccess, "Child access should be denied by default")
    }

    func testExplicitAllow() {
        let resourceID = gatekeeper.createResource(name: "resource", parentID: nil)
        let user = gatekeeper.createUser(id: "user1", name: "Alice")

        gatekeeper.setAccess(resourceID: resourceID, userID: user.id, state: .allow)
        let hasAccess = gatekeeper.checkAccess(resourceID: resourceID, userID: user.id)

        XCTAssertTrue(hasAccess, "User should have access after explicit allow")
    }

    func testExplicitDeny() {
        let resourceID = gatekeeper.createResource(name: "resource", parentID: nil)
        let user = gatekeeper.createUser(id: "user1", name: "Alice")

        gatekeeper.setAccess(resourceID: resourceID, userID: user.id, state: .deny)
        let hasAccess = gatekeeper.checkAccess(resourceID: resourceID, userID: user.id)

        XCTAssertFalse(hasAccess, "User should not have access after explicit deny")
    }

    func testInheritance() {
        let rootID = gatekeeper.createResource(name: "root", parentID: nil)
        let childID = gatekeeper.createResource(name: "child", parentID: rootID)
        let user = gatekeeper.createUser(id: "user1", name: "Alice")

        gatekeeper.setAccess(resourceID: rootID, userID: user.id, state: .allow)
        let childAccess = gatekeeper.checkAccess(resourceID: childID, userID: user.id)

        XCTAssertTrue(childAccess, "Child should inherit access from parent")
    }

    func testOverrideDeny() {
        let rootID = gatekeeper.createResource(name: "root", parentID: nil)
        let childID = gatekeeper.createResource(name: "child", parentID: rootID)
        let user = gatekeeper.createUser(id: "user1", name: "Alice")

        gatekeeper.setAccess(resourceID: rootID, userID: user.id, state: .deny)
        gatekeeper.setAccess(resourceID: childID, userID: user.id, state: .allow)

        let rootAccess = gatekeeper.checkAccess(resourceID: rootID, userID: user.id)
        let childAccess = gatekeeper.checkAccess(resourceID: childID, userID: user.id)

        XCTAssertFalse(rootAccess, "Root access should be denied")
        XCTAssertFalse(childAccess, "Child access should not be allowed either as root is denied")
    }

    func testParentDenyChildAllow() {
        let rootID = gatekeeper.createResource(name: "root", parentID: nil)
        let childID = gatekeeper.createResource(name: "child", parentID: rootID)
        let user = gatekeeper.createUser(id: "user1", name: "Alice")

        gatekeeper.setAccess(resourceID: rootID, userID: user.id, state: .deny)
        gatekeeper.setAccess(resourceID: childID, userID: user.id, state: .allow)

        let rootAccess = gatekeeper.checkAccess(resourceID: rootID, userID: user.id)
        let childAccess = gatekeeper.checkAccess(resourceID: childID, userID: user.id)

        XCTAssertFalse(rootAccess, "Root access should be denied")
        XCTAssertFalse(childAccess, "Child access should be denied due to parent deny, despite child allow")

        // Now change the root access to allow
        gatekeeper.setAccess(resourceID: rootID, userID: user.id, state: .allow)
        
        let newChildAccess = gatekeeper.checkAccess(resourceID: childID, userID: user.id)
        XCTAssertTrue(newChildAccess, "Child access should now be allowed after changing root to allow")
    }

    func testNonExistentResourceAndUser() {
        let nonExistentResourceID = UUID()
        let nonExistentUserID = "nonexistent"

        let hasAccess = gatekeeper.checkAccess(resourceID: nonExistentResourceID, userID: nonExistentUserID)

        XCTAssertFalse(hasAccess, "Access should be denied for non-existent resource or user")
    }

      func testComplexStructureWithAccess() {
        // Create a complex resource structure
        let rootID = gatekeeper.createResource(name: "Company", parentID: nil)
        let hrID = gatekeeper.createResource(name: "HR", parentID: rootID)
        let financeID = gatekeeper.createResource(name: "Finance", parentID: rootID)
        let itID = gatekeeper.createResource(name: "IT", parentID: rootID)
        let employeeRecordsID = gatekeeper.createResource(name: "Employee Records", parentID: hrID)
        let salariesID = gatekeeper.createResource(name: "Salaries", parentID: financeID)
        let budgetID = gatekeeper.createResource(name: "Budget", parentID: financeID)
        let serversID = gatekeeper.createResource(name: "Servers", parentID: itID)

        // Create users
        let ceo = gatekeeper.createUser(id: "CEO", name: "Alice CEO")
        let hrManager = gatekeeper.createUser(id: "HRM", name: "Bob HRM")
        let financeManager = gatekeeper.createUser(id: "FM", name: "Charlie FM")
        let itManager = gatekeeper.createUser(id: "ITM", name: "David ITM")
        let employee = gatekeeper.createUser(id: "EMP", name: "Eve EMP")

        // Set access rules
        gatekeeper.setAccess(resourceID: rootID, userID: ceo.id, state: .deny)
        gatekeeper.setAccess(resourceID: financeID, userID: ceo.id, state: .deny)
        gatekeeper.setAccess(resourceID: rootID, userID: ceo.id, state: .allow)

        gatekeeper.setAccess(resourceID: hrID, userID: hrManager.id, state: .allow)
        gatekeeper.setAccess(resourceID: financeID, userID: financeManager.id, state: .allow)
        gatekeeper.setAccess(resourceID: itID, userID: itManager.id, state: .allow)
        gatekeeper.setAccess(resourceID: employeeRecordsID, userID: employee.id, state: .deny)
        gatekeeper.setAccess(resourceID: salariesID, userID: hrManager.id, state: .allow)
        gatekeeper.setAccess(resourceID: budgetID, userID: hrManager.id, state: .deny)
        gatekeeper.setAccess(resourceID: serversID, userID: financeManager.id, state: .deny)

        print("\nComplex Resource Structure with Access Information:")
        printResourceStructure(resourceID: rootID, indent: "")

        func printResourceStructure(resourceID: UUID, indent: String, onlyAllow: Bool = true) {
            guard let resource = gatekeeper.getResource(id: resourceID) else { return }
            
            print("\(indent)\(resource.name)")
            
            let users = [ceo, hrManager, financeManager, itManager, employee]
            for user in users {
                let hasAccess = gatekeeper.checkAccess(resourceID: resourceID, userID: user.id)
                if onlyAllow && !hasAccess {
                    continue
                }
                let accessString = hasAccess ? "Allow" : "Deny"
                let color = hasAccess ? "\u{001B}[32m" : "\u{001B}[31m"
                let reset = "\u{001B}[0m"
                print("\(indent)  - \(user.name): \(color)\(accessString)\(reset)")
            }
            
            for childID in resource.children.map({ $0.id }) {
                printResourceStructure(resourceID: childID, indent: indent + "    ", onlyAllow: onlyAllow)
            }
        }
      }
}