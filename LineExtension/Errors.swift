import Foundation

enum CommandError: Error, LocalizedError, CustomNSError {
	case noSelection
	
	var localizedDescription: String {
		switch self {
		case .noSelection:
			return "Error: no text selected."
		}
	}
	
	var errorUserInfo: [String: Any] {
		return [NSLocalizedDescriptionKey: localizedDescription]
	}
}
