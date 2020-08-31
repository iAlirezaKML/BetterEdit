import Foundation
import XcodeKit

class SelectLineCommand: NSObject, XCSourceEditorCommand {
	func perform(
		with invocation: XCSourceEditorCommandInvocation,
		completionHandler: @escaping (Error?) -> Void
	) {
		let buffer = invocation.buffer
		if let range = buffer.selections.lastObject as? XCSourceTextRange {
			range.start.column = 0
			range.end.line += 1
			range.end.column = 0
		}

		completionHandler(nil)
	}
}
