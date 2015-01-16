


import Cocoa
import SwiftyJSON

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

//-------------------//
// MARK:- SwiftyJSON
//-------------------//

let json = JSON(data: rawJSON!, options: .allZeros, error: nil)

var repos = [Repo]()
for (index: String, subJson: JSON) in json {
  if let id = subJson["id"].int {
    if let name = subJson["name"].string {
      if let url = subJson["url"].string {
        if let fork = subJson["fork"].bool {
          var homepage: NSURL? = .None
          if let homepage_raw = subJson["homepage"].string {
            homepage = NSURL(string: homepage_raw)
          }
          let url_url = NSURL(string: url)!
          repos += [Repo(id: id, name: name, desc: subJson["description"].string,
            url: url_url, homepage: homepage, fork: fork)]
        }
      }
    }
  }
}

println(repos.map { $0.description })

