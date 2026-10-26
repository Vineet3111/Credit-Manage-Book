//
//  ProductUnit.swift
//  Credit Manage Book
//

import Foundation

enum ProductUnit: String, Codable, CaseIterable, Identifiable {
    case kg, ltr, pcs, box, bottle, packet

    var id: String { rawValue }
    
    func title() -> String {
        switch self {
        case .kg: return "Kg"
        case .ltr: return "Liter"
        case .pcs: return "Piece"
        case .box: return "Box"
        case .bottle: return "Bottle"
        case .packet: return "Packet"
        }
    }
}
