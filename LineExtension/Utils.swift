import Foundation
import XcodeKit

func deleteLines(
	invocation: XCSourceEditorCommandInvocation,
	targetRange: Range<Int>,
	indexSet: IndexSet
) {
	invocation.buffer.lines.removeObjects(at: indexSet)
	let lineSelection = XCSourceTextRange()
	lineSelection.start = XCSourceTextPosition(line: targetRange.lowerBound, column: 0)
	lineSelection.end = XCSourceTextPosition(line: targetRange.lowerBound, column: 0)
	invocation.buffer.selections.setArray([lineSelection])
}
