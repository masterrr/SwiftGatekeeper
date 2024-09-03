// The Swift Programming Language
// https://docs.swift.org/swift-book


import Foundation

public struct SwiftGatekeeper {
    class Resource {
        let id: UUID = UUID()
        let name: String
        let children: [Resource]
        var parent: Resource?
        
        init(name: String, children: [Resource]) {
            self.name = name
            self.children = children
            for child in children {
                child.parent = self
            }
        }
    }

    func assembleSampleResources() -> Resource {
        let child4 = Resource(name: "child4", children: [])
        let child5 = Resource(name: "child5", children: [])
        let child6 = Resource(name: "child6", children: [])

        let child1 = Resource(name: "child1", children: [child4])
        let child2 = Resource(name: "child2", children: [child5])
        let child3 = Resource(name: "child3", children: [child6])
        
        return Resource(name: "root", children: [child1, child2, child3])        
    }

    func printStructure(resource: Resource, indent: String = "") {
        print("\(indent)\(resource.name)")
        for child in resource.children {
            printStructure(resource: child, indent: "\(indent)\(resource.name) - ")
        }
    }

    func checkAccess(resource: Resource, userId: String) -> Bool {
        return true
    }

    func grantAccess(resource: Resource, userId: String) -> Void {
        // TODO: Implement
    }

    func revokeAccess(resource: Resource, userId: String) -> Void {
        // TODO: Implement
    }

    public func sampleTestInputCall() -> Void {
        printStructure(resource: assembleSampleResources())
    }
}