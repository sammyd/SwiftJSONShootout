


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


// This line represents the confusion surrounding functional programming
let repos: [Repo]? = (JSONValue.parse <^> json) >>- JSONValue.mapDecode

// Unwrap two levels of optionals in an array
repos!

