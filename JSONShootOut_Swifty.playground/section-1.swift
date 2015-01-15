


import Cocoa
import SwiftyJSON

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

//-------------------//
// MARK:- SwiftyJSON
//-------------------//

