import Foundation


struct GroupMember: Identifiable {
    let id = UUID()
    let name: String
    let groups: [String]
}


struct Group: Identifiable {
    let id = UUID()
    let name: String
    let members: [GroupMember]
}
