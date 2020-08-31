import Foundation
import XcodeKit

class SplitLineCommand: NSObject, XCSourceEditorCommand {
	func perform(
		with invocation: XCSourceEditorCommandInvocation,
		completionHandler: @escaping (Error?) -> Void
	) {
		guard
			let textRange = invocation.buffer.selections.firstObject as? XCSourceTextRange,
			!invocation.buffer.lines.isEmpty
		else {
			completionHandler(nil)
			return
		}

		let targetRange = Range(
			uncheckedBounds: (
				lower: textRange.start.line,
				upper: min(textRange.end.line + 1, invocation.buffer.lines.count)
			)
		)

		let indexSet = IndexSet(integersIn: targetRange)
		let selectedLines = invocation.buffer.lines.objects(at: indexSet)

		guard let _selectedLines = selectedLines as? [String] else {
			completionHandler(nil)
			return
		}

		var textArray = _selectedLines.flatMap {
			$0.components(separatedBy: ",")
		}

		let firstLine = _selectedLines[0]
		let firstLineText: String?

		if let range: Range<String.Index> = firstLine.range(of: ",") {
			firstLineText = String(firstLine[..<range.lowerBound]) + ","
		} else if let range: Range<String.Index> = firstLine.range(of: "\n") {
			firstLineText = String(firstLine[..<range.lowerBound])
		} else {
			firstLineText = nil
		}

		let leadingSpaces: String

		if let firstLineText = firstLineText?.trimmedEnd {
			textArray[0] = firstLineText

			if let index = firstLineText.lastIndex(of: "(") {
				let distance = firstLineText.distance(to: index)
				leadingSpaces = String.spaces(count: distance + 1)
			} else if let index = firstLineText.lastIndex(of: "[") {
				let distance = firstLineText.distance(to: index)
				leadingSpaces = String.spaces(count: distance + 1)
			} else {
				leadingSpaces = String.spaces(count: invocation.buffer.indentationWidth)
					+ firstLineText.leadingSpaces()
			}
		} else {
			leadingSpaces = ""
		}

		var remainingLines = [String]()

		for i in 1 ..< textArray.count {
			let text = textArray[i].trimmed

			if !text.isEmpty {
				remainingLines.append(leadingSpaces + text)
			}
		}

		let result = [
			textArray[0],
			remainingLines.joined(separator: ",\n"),
		].joined(separator: "\n")

		deleteLines(
			invocation: invocation,
			targetRange: targetRange,
			indexSet: indexSet
		)

		let insertTargetRange = Range(
			uncheckedBounds: (lower: textRange.start.line, upper: textRange.start.line + 1)
		)
		let insertIndexSet = IndexSet(integersIn: insertTargetRange)
		invocation.buffer.lines.insert([result], at: insertIndexSet)
		
		completionHandler(nil)
	}
}
