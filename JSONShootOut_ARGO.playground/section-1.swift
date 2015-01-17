


import Cocoa
import Argo
import Runes

/* Import the JSON from a file */
let jsonURL = NSBundle.mainBundle().pathForResource("sams_repos", ofType: "json")
let rawJSON = NSData(contentsOfFile: jsonURL!)
let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(rawJSON!,
                                            options: .allZeros, error: nil)


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
// MARK:- ARGO
//-------------//

extension NSURL: JSONDecodable {
  public class func decode(j: JSONValue) -> NSURL? {
    switch j {
    case .JSONString(let s):
      return NSURL(string: s)
    default:
      return nil
    }
  }
}

extension Repo: JSONDecodable {
  static func create(id: Int)(name: String)(desc: String?)
                    (url: NSURL)(homepage: NSURL?)(fork: Bool) -> Repo {
    return Repo(id: id, name: name, desc: desc,
                url: url, homepage: homepage, fork: fork)
  }
  
  static func decode(j: JSONValue) -> Repo? {
    return Repo.create
      <^> j <|  "id"
      <*> j <|  "name"
      <*> j <|? "description"
      <*> j <|  "url"
      <*> j <|? "homepage"
      <*> j <|  "fork"
  }
}

var repos : [Repo?]? = .None

if let j: AnyObject = json {
  if let value = JSONValue.parse <^> j {
    switch value {
    case .JSONArray(let a):
      repos = a.map(Repo.decode)
    default:
      println("Not an array")
    }
  }
}

println(repos)


