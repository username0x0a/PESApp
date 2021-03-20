import SwiftUI
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let session = URLSession(configuration: .default)

session.dataTask(with: URL(string: "http://pes.misacek.net/pes.json")!) { (data, resp, err) in

	guard let data = data else { return }

	let pes = try! JSONDecoder().decode(PESData.self, from: data)

	print("Stats for date \(pes.date):")
	print()

	print("\(pes.name): index \(pes.index) (R = \(pes.rValue))")
	print()

	pes.data.forEach { (key, value) in
		print("\(value.name): index \(value.index) (R = \(value.rValue))")
	}

}.resume()
