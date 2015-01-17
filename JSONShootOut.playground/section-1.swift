

import Cocoa

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


//--------------------//
// MARK:- valueForKey
//--------------------//
var repos = [Repo]()

if let json : AnyObject = json {
  if let array = json as? NSArray {
    for jsonItem in array as [AnyObject] {
      if let id = jsonItem.valueForKey("id") as? Int {
        if let name = jsonItem.valueForKey("name") as? String {
          if let url_string = jsonItem.valueForKey("url") as? String {
            if let fork = jsonItem.valueForKey("fork") as? Bool {
              if let url = NSURL(string: url_string) {
                var description = jsonItem.valueForKey("description") as? String
                var homepage: NSURL? = .None
                if let homepage_string = jsonItem.valueForKey("homepage") as? String {
                  homepage = NSURL(string: homepage_string)
                }
                let repo = Repo(id: id, name: name, desc: description, url: url,
                                homepage: homepage, fork: fork)
                repos += [repo]
              }
            }
          }
        }
      }
    }
  }
}

println(repos)


//----------------------//
// MARK:- Optional Tree
//----------------------//
