//
//  ResponseModel.swift
//  Radius
//
//  Created by Admin on 29/06/23.
//

import Foundation

struct APIResponse: Codable {
    let facilities: [Facility]
    let exclusions: [[Exclusion]]
}
struct Facility: Codable {
    let facility_id: String
    let name: String
    let options: [FacilityOption]
}
struct FacilityOption: Codable {
    let name: String
    let icon: String
    let id: String
    var isSelected: Bool? = false
}
struct Exclusion: Codable {
    let facility_id: String
    let options_id: String
}
struct SelectedOption{
    var facility_id:String
    var option_id:String
    var belongToSection : Int
    var optionName:String?
}
