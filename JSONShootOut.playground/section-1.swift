

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
                let description = jsonItem.valueForKey("description") as? String
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

repos


//----------------------//
// MARK:- Optional Tree
//----------------------//
var repos_ot = [Repo]()

if let repo_array = json as? NSArray {
  for repo_item in repo_array {
    if let repo_dict = repo_item as? NSDictionary {
      if let id = repo_dict["id"] as? Int {
        if let name = repo_dict["name"] as? String {
          if let url_string = repo_dict["url"] as? String {
            if let fork = repo_dict["fork"] as? Bool {
              if let url = NSURL(string: url_string) {
                let description = repo_dict["description"] as? String
                var homepage: NSURL? = .None
                if let homepage_string = repo_dict["homepage"] as? String {
                  homepage = NSURL(string: homepage_string)
                }
                let repo = Repo(id: id, name: name, desc: description, url: url,
                                homepage: homepage, fork: fork)
                repos_ot += [repo]
              }
            }
          }
        }
      }
    }
  }
}

repos_ot



