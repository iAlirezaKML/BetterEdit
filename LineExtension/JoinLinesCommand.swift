import Foundation
import XcodeKit

class JoinLinesCommand: NSObject, XCSourceEditorCommand {
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

		if indexSet.count == 1 {
			guard
				let currentRow = indexSet.last,
				currentRow < invocation.buffer.lines.count - 1,
				let firstLine = invocation.buffer.lines[currentRow] as? String,
				let secondLine = invocation.buffer.lines[currentRow + 1] as? String
			else {
				completionHandler(nil)
				return
			}

			let newLine = firstLine.trimmedEnd + " " + secondLine.trimmedStart
			invocation.buffer.lines[currentRow] = newLine
			invocation.buffer.lines.removeObject(at: currentRow + 1)

			if textRange.start.column == textRange.end.column {
				let lineSelection = XCSourceTextRange()
				lineSelection.start = XCSourceTextPosition(line: textRange.start.line, column: firstLine.count)
				lineSelection.end = lineSelection.start
				invocation.buffer.selections.setArray([lineSelection])
			}
		} else if indexSet.count > 1 {
			guard let currentRow = indexSet.first else {
				completionHandler(nil)
				return
			}

			let selectedLines: [String] = (selectedLines as? [String])
				.flatMap { selectedLines -> [String] in
					selectedLines.enumerated().map { index, line in
						if index == 0 {
							return line.trimmedEnd
						} else if index == selectedLines.count - 1 {
							return line.trimmedStart
						} else {
							return line.trimmed
						}
					}
				} ?? []

			let newLine = selectedLines.joined(separator: " ")
			invocation.buffer.lines[currentRow] = newLine

			let indexSetToRemove = IndexSet(
				integersIn: Range(
					uncheckedBounds: (
						lower: textRange.start.line + 1,
						upper: min(textRange.end.line + 1, invocation.buffer.lines.count)
					)
				)
			)

			deleteLines(
				invocation: invocation,
				targetRange: targetRange,
				indexSet: indexSetToRemove
			)

			let lineSelection = XCSourceTextRange()
			lineSelection.start = XCSourceTextPosition(line: textRange.start.line, column: textRange.start.column)
			lineSelection.end = XCSourceTextPosition(line: textRange.start.line, column: newLine.count - 1)
			invocation.buffer.selections.setArray([lineSelection])
		}

		completionHandler(nil)
	}
}
