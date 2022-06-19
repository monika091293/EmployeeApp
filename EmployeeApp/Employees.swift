

import Foundation
struct Employees : Codable {
    
    let id : Int?
    let name : String?
	let username : String?
    let email : String?
	let profile_image : String?
	let address : Address?
	let phone : String?
	let website : String?
	let company : Company?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case name = "name"
		case username = "username"
		case email = "email"
		case profile_image = "profile_image"
		case address = "address"
		case phone = "phone"
		case website = "website"
		case company = "company"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		username = try values.decodeIfPresent(String.self, forKey: .username)
		email = try values.decodeIfPresent(String.self, forKey: .email)
		profile_image = try values.decodeIfPresent(String.self, forKey: .profile_image)
		address = try values.decodeIfPresent(Address.self, forKey: .address)
		phone = try values.decodeIfPresent(String.self, forKey: .phone)
		website = try values.decodeIfPresent(String.self, forKey: .website)
		company = try values.decodeIfPresent(Company.self, forKey: .company)
	}

}
