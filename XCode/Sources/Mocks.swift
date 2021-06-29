import Foundation

// Primitive Mock
public enum RealDataDictionary {
    case int
    case uint
    case positiveInt
    case url
    case uuid
    case firstname
    case surname
    case city
    case street
    case month
    case year
    case country
    case province
    case email
    case mobilePhone
    case landlinePhone
    case loremIpsum
}

public extension String {
    static func mock(_ type: RealDataDictionary = .uuid) -> String {
        switch type {
            case .city: return ["Torino", "Milano", "Ivrea"].randomElement()!
            case .street: return ["Via Roma", "Via Giuseppe di Vittorio", "Via Jervis", "Piazza Bodoni", "Corso Trieste"].randomElement()!
            case .url: return "http://www.\(String.mock()).com"
            case .uuid: return UUID().uuidString
            case .int: return "\(Int.random(in: -10...10))"
            case .positiveInt: return "\(Int.random(in: 1...10))"
            case .uint: return "\(Int.random(in: 0...100))"
            case .month: return "\(Int.random(in: 1...12))"
            case .year: return "\(Int.random(in: 2000...2050))"
            case .firstname: return ["Don Lurio", "Gino", "Augusto", "Elisa", "Jole", "Amanda"].randomElement()!
            case .surname: return ["Rossi", "Esposito", "Ferrari", "Russo", "Bianco", "Fontana"].randomElement()!
            case .country: return ["IT", "GB", "FR", "USA", "DK", "SE"].randomElement()!
            case .province: return ["To", "Mi", "Na", "Fi", "Bo"].randomElement()!
            case .email: return ["rossi@mailx.com", "esposito@liberox.it", "ferrari@skymail.com", "mario.bianchi@mail.com", "russo.italo@mail.com"].randomElement()!
            case .mobilePhone: return ["3391212149", "340303328832", "3391349898", "3239039023"].randomElement()!
            case .landlinePhone: return ["0554641900", "0230302400", "0957181801", "0516400100", "0115066201"].randomElement()!
            case .loremIpsum: return "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        }
    }

    static func mock(from: [String]) -> String {
        return from.randomElement()!
    }
}

public extension Int {
    static func mock() -> Int {
        return Int.random(in: 0...100)
    }
}

public extension Bool {
    static func mock() -> Bool {
        return Bool.random()
    }
}

public extension URL {
    static func mock(string: String = String.mock(.url)) -> URL {
        return URL(string: string)!
    }
}

public extension Date {
    static func mock(_ date: Date = Date()) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date))!
    }

    static func mock(year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let dateComponents = DateComponents(calendar: calendar, year: year, month: month, day: day)
        return calendar.date(from: dateComponents)!
    }

    static func mockRandom() -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: Int.random(in: 1...1000), to: Date.mock())!
    }
}
