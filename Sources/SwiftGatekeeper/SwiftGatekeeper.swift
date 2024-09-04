import Foundation

public class SwiftGatekeeper {
    enum AccessState {
        case allow
        case deny
    }

    class User: Identifiable, Hashable {
        let id: String
        let name: String

        init(id: String, name: String) {
            self.id = id
            self.name = name
        }

        static func == (lhs: User, rhs: User) -> Bool {
            return lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    class Resource {
        let id: UUID = UUID()
        let name: String
        var children: [Resource]
        weak var parent: Resource?

        var accessStates: [User.ID: AccessState] = [:]
        
        init(name: String, children: [Resource] = []) {
            self.name = name
            self.children = children
            for child in children {
                child.parent = self
            }
        }
    }

    func getResource(id: UUID) -> Resource? {
        return resources[id]
    }

    private var resources: [UUID: Resource] = [:]
    private var users: [String: User] = [:]

    func createResource(name: String, parentID: UUID?) -> UUID {
        let newResource = Resource(name: name)
        let newID = newResource.id
        
        if let parentID = parentID, let parent = resources[parentID] {
            newResource.parent = parent
            parent.children.append(newResource)
        }
        
        resources[newID] = newResource
        return newID
    }

    func createUser(id: String, name: String) -> User {
        let user = User(id: id, name: name)
        users[id] = user
        return user
    }

    func setAccess(resourceID: UUID, userID: String, state: AccessState) {
        guard let resource = resources[resourceID], let _ = users[userID] else {
            return
        }
        resource.accessStates[userID] = state
    }

    func checkAccess(resourceID: UUID, userID: String) -> Bool {
        guard let resource = resources[resourceID], let _ = users[userID] else {
            return false
        }

        var currentResource: Resource? = resource
        var explicitAllow = false

        while let res = currentResource {
            switch res.accessStates[userID] {
            case .allow:
                explicitAllow = true
            case .deny:
                return false
            case .none:
                // No explicit policy is set
                // Parent expliciy deny affects children only
                break
            }
            currentResource = res.parent
        }
        return explicitAllow
    }
}
