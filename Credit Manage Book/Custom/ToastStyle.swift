//
//  ToastStyle.swift
//  Credit Manage Book
//

import SwiftUI

/// Look of a `ToastView`: title, color and icon.
enum ToastStyle {
    case success
    case error

    var title: String {
        switch self {
        case .success:
            "Success"
        case .error: 
            "Error"
        }
    }

    var color: Color {
        switch self {
        case .success:
            Color(red: 0.13, green: 0.62, blue: 0.38)
        case .error:
            Color(red: 0.86, green: 0.22, blue: 0.24)
        }
    }

    var icon: String {
        switch self {
        case .success:
            "checkmark.circle.fill"
        case .error:
            "exclamationmark.circle.fill"
        }
    }
}
