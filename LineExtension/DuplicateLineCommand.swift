import Foundation
import XcodeKit

class DuplicateLineCommand: NSObject, XCSourceEditorCommand {
	func perform(
		with invocation: XCSourceEditorCommandInvocation,
		completionHandler: @escaping (Error?) -> Void
	) {
		guard
			let textRange = invocation.buffer.selections.firstObject as? XCSourceTextRange,
			!invocation.buffer.lines.isEmpty
		else {
			completionHandler(CommandError.noSelection)
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

		let lineSelection = XCSourceTextRange()
		lineSelection.start = XCSourceTextPosition(
			line: textRange.start.line + targetRange.count,
			column: textRange.start.column
		)
		lineSelection.end = XCSourceTextPosition(
			line: textRange.end.line + targetRange.count,
			column: textRange.end.column
		)

		invocation.buffer.lines.insert(selectedLines, at: indexSet)
		invocation.buffer.selections.setArray([lineSelection])
				
		completionHandler(nil)
	}
}
