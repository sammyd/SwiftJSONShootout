


import Cocoa
import Swiftz

/* Import the JSON from a file */
let jsonURL = NSBundle.mainBundle().pathForResource("sams_repos", ofType: "json")
let rawJSON = NSData(contentsOfFile: jsonURL!)


//-------------//
// MARK:- Model
//-------------//

struct Repo {
  let id: Int
  let name: String
  let desc: String?
  let url: NSURL
  let homepage: NSURL?
  let fork: Bool
}

extension Repo: Printable {
  var description : String {
    return "\(name) (\(id)) {\(desc) :: \(homepage)}"
  }
}


//-------------//
// MARK:- Swiftz
//-------------//

extension Repo: JSONDecode {
  typealias J = Repo
  
  static func create(id: Int)(name: String)(desc: String?)
    (url: NSURL)(homepage: NSURL?)(fork: Bool) -> Repo {
      return Repo(id: id, name: name, desc: desc,
        url: url, homepage: homepage, fork: fork)
  }
  
  static func fromJSON(x: JSONValue) -> Repo? {
    var id: Int?
    var name: String?
    var desc: String?
    var url: NSURL?
    var homepage: NSURL?
    var fork: Bool?
    switch x {
      case let .JSONObject(d):
        id = d["id"]   >>- JInt.fromJSON
        name = d["name"]    >>- JString.fromJSON
        desc = d["description"] >>- JString.fromJSON
        url = d["url"]  >>- JString.fromJSON
        homepage = d["homepage"] >>- JString.fromJSON
        fork = d["fork"] >>- JBool.fromJSON
        return (Repo.create <^> id <*> name <*> desc <*> url <*> homepage <*> fork)
      default:
        return .None
    }
  }
}
