import Foundation



public enum JSONCommentRemover {
    public static func createJson(from jsonString: String) throws -> JSON {
        if let data = jsonString.data(using: .utf8) {
            let decoder = JSONDecoder()
            return try decoder.decode(JSON.self, from: data)
        }
        return .null
    }
        
    public static func removeComments(from jsonString: String) -> String {
        var uncommentedString = ""
        let lines = jsonString.components(separatedBy: .newlines)
        var insideTripleBackticks = false
        var stack = [Character]()
        var appendCurrent = false
        for line in lines {
            appendCurrent = false
            for char in line {
                switch char {
                case "{", "[":
                    stack.append(char)
                case "}":
                    if stack.last == "{" {
                        stack.removeLast()
                    }
                case "]":
                    if stack.last == "[" {
                        stack.removeLast()
                    }
                    appendCurrent = true
                default:
                    break
                }
            }
            if line.contains("```") {
                insideTripleBackticks.toggle()
                continue
            }
            if appendCurrent {
               uncommentedString.append(line)
           } else if stack.isEmpty {
                // if let commentRange = line.range(of: "//") {
                //     let nonCommentPart = line[..<commentRange.lowerBound]
                //     // Only add the line if it contains non-whitespace characters before the comment.
                //     if nonCommentPart.trimmingCharacters(in: .whitespaces).isEmpty == false {
                //         uncommentedString.append(String(nonCommentPart))
                //     }
                // } else {
                //     uncommentedString.append(line)
                // }
            } else {
                uncommentedString.append(line)
            }
            if !uncommentedString.isEmpty {
                uncommentedString.append("\n") // Preserve line breaks.
            }
        }
        return uncommentedString
    }
    
    public enum JSONParseError: Error {
        case unmatchedOpeningSymbol(String)
    }
    public static func repairJSONString(_ jsonString: String) throws -> String {
          var stack = [String]()
          var isEscaping = false
        var result = JSONCommentRemover.removeComments(from: jsonString.trimmingCharacters(in: .whitespacesAndNewlines))
          
        let parsedJSON = Array(result)
          
          for char in parsedJSON {
              switch String(char) {
              case "\\":
                  isEscaping = !isEscaping
              case "{", "[" :
                  if isEscaping {
                      isEscaping = false
                  } else {
                      stack.append(String(char))
                  }
              case "}", "]":
                  isEscaping = false
                  guard let last = stack.last else {
                      return result
                  }
                  if String(char) == "}" && last == "{" {
                      stack.removeLast()
                  } else if String(char) == "]" && last == "[" {
                      stack.removeLast()
                  }
              case "\"":
                  if !isEscaping, let last = stack.last, last == "\"" {
                      stack.removeLast()
                  } else if !isEscaping {
                      stack.append("\"")
                  }
              default:
                  isEscaping = false
              }
          }
          
          for openingSymbol in stack.reversed() {
              switch openingSymbol {
              case "{":
                  result.append("}")
              case "[":
                  result.append("]")
              case "\"":
                  result.append("\"")
              default:
                  throw JSONParseError.unmatchedOpeningSymbol(openingSymbol)
              }
          }
          
          return result
      }


    public enum JSONRepairError: Error {
        case invalidJSONString
    }
    public  enum JSONContext: Equatable {
        case openObject_needsKey
        case openObject_needsKeyAndValue
        case openObject_needsValue
        case openArray
        case openArray_needsValue
        case openQuote
    }

    public static func repairJSON(_ str: String, debugging : Bool = false) throws -> String {
        var stack: [JSONContext] = []
        var jsonString = JSONCommentRemover.removeComments(from: str).trimmingCharacters(in: .whitespacesAndNewlines)
        
        var progressString = ""
        var lastStack = stack
        for char in str {
            progressString.append(char)
            lastStack = stack
            switch char {
            case "{":
                
                if let last = stack.last, case .openObject_needsValue = last {
                    stack.removeLast()
                    stack.append(.openObject_needsKey)
                    stack.append(.openObject_needsKeyAndValue)
                } else {
                    stack.append(.openObject_needsKeyAndValue)
                }
            case "[":
                if case .openObject_needsValue = stack.last {
                    stack.removeLast()
                    stack.append(.openObject_needsKey)
                }
                stack.append(.openArray)
            case ":":
                if case .openObject_needsKey = stack.last {
                    stack.removeLast()
                    stack.append(.openObject_needsValue)
                }
            case ",":
                if case .openObject_needsValue = stack.last {
                    stack.removeLast()
                    stack.append(.openObject_needsKeyAndValue)
    //                jsonString.append("\"\"")
                } else if case .openArray = stack.last {
                    stack.append(.openArray_needsValue)
                }
            case "\"":
                if let last = stack.last, case .openQuote = last {
                    stack.removeLast()
                } else if let last = stack.last, case .openObject_needsKey = last {
                    stack.removeLast()
                    stack.append(.openObject_needsValue)
                    stack.append(.openQuote)
                } else if let last = stack.last, case .openObject_needsKeyAndValue = last {
                    stack.removeLast()
                    stack.append(.openObject_needsValue)
                    stack.append(.openQuote)
                } else {
                    stack.append(.openQuote)
                }
            case "1", "2", "3", "4", "5", "6", "7", "8", "9", "0":
                if case .openObject_needsValue = stack.last {
                    stack.removeLast()
                    stack.append(.openObject_needsKey)
                    print(stack)
                }
            case "}":
                if case .openObject_needsValue = stack.last {
                    //jsonString.append(":\"\"}")
                    stack.removeLast()
                } else if case .openObject_needsKeyAndValue = stack.last {
                    stack.removeLast()
                    stack.append(.openObject_needsKey)
                } else if case .openObject_needsKey = stack.last {
                    stack.removeLast()
                    //throw JSONRepairError.invalidJSONString
                } else {
                    stack.removeLast()
                }
            case "]":
                if case .openArray_needsValue = stack.last {
    //                jsonString.append("\"\"")
                    stack.removeLast()
                }
                if case .openArray = stack.last {
                    stack.removeLast()
                }

            default:
                break
            }
            if lastStack != stack && debugging {
                print("Progress: " + progressString)
                print("Stack: \(stack)")
            }
        }
        if debugging {
            print("end encountered: \(stack)")
            print("Current: \(jsonString)")
        }
        
        if jsonString.last == "," {
            jsonString.removeLast()
        }
        if stack.isEmpty {
            while jsonString.last == "`" {
                jsonString.removeLast()
            }
        }
        
        // Additional step to close all open objects and arrays at the end of the string
        while let context = stack.last {
            if debugging {
                print("Current: \(jsonString)")
                print("attempting: \(context)")
            }
            switch context {
            case .openObject_needsKeyAndValue:
                jsonString.append("}")
                stack.removeLast()
            case .openObject_needsKey:
                jsonString.append("}")
                stack.removeLast()
            case .openObject_needsValue:
                if jsonString.last == ":" {
                    jsonString.append("\"\"}")
                } else {
                    jsonString.append(":\"\"}")
                }
                stack.removeLast()
            case .openArray:
                jsonString.append("]")
                stack.removeLast()
            case .openArray_needsValue:
                jsonString.append("\"\"")
                stack.removeLast()
            case .openQuote:
                jsonString.append("\"")
                stack.removeLast()
            }
        }
        
        return jsonString
    }

}
