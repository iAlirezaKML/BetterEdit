import Foundation

extension String {
	var trimmedEnd: String {
		replacingOccurrences(
			of: "[ \t\n]+$",
			with: "",
			options: .regularExpression
		)
	}

	var trimmedStart: String {
		replacingOccurrences(
			of: "^[ \t]+",
			with: "",
			options: .regularExpression
		)
	}

	var trimmed: String {
		trimmingCharacters(in: .whitespacesAndNewlines)
	}

	static func spaces(count: Int) -> String {
		[String](repeating: " ", count: count).joined()
	}

	func leadingSpaces() -> String {
		var numberOfSpaces = 0
		for c in self {
			if c == " " {
				numberOfSpaces += 1
			} else {
				break
			}
		}
		return String.spaces(count: numberOfSpaces)
	}
}

extension Collection {
	func distance(to index: Index) -> Int {
		distance(from: startIndex, to: index)
	}
}

extension NSArray {
	var isEmpty: Bool {
		count <= 0
	}
}
