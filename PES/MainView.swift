//
//  MainView.swift
//  PES
//
//  Created by Michal Zelinka on 21/03/2021.
//

import SwiftUI

struct Region: PESElement, Identifiable {
	let id: PESRegion
	let name: String
	let index: Int
	let rValue: Float
	let _rating: PESRating
	let color: Color
	init(element: PESElement) {
		id = element.id
		name = PESRegionName[element.id]!
		index = element.index
		rValue = element.rValue
		_rating = element._rating
		color = Color(UIColor(rgb: PESRatingColor[_rating]!))
	}
}

struct RegionView: View {

	let element: Region
	var upToDate: Bool = true

	var body: some View {
		HStack(spacing: 0) {
			Spacer().frame(width: 24)
			VStack(spacing: 0) {
				HStack {
					Text("\(element.name)")
						.font(.custom("CircularPro-Medium", size: 24))
					Spacer()
					if element.id == .Czechia && !upToDate {
						Text("*")
							.font(.custom("CircularPro-Bold", size: 28))
					}
					ZStack {
						HStack {
							Text("\(element.index)")
								.font(.custom("CircularPro-Bold", size: 28))
								.frame(maxWidth: 100, alignment: .center)
								.foregroundColor(.white)
						}.frame(width: 72, alignment: .center)
					}.frame(width: 48, height: 48)
					.background(element.color).cornerRadius(24)
				}.frame(height: 63)
			}
			Spacer().frame(width: 24)
		}.frame(height: 64)
	}
}

struct MainView: View {

	@State var data: (Region, [Region])?

	func loadData() -> Void {

		PESManager.shared.checkDataUpdate { result in
			if case .success = result {
				refreshData()
			}
		}

		refreshData()
	}

	func refreshData() {
		data = convertData(PESManager.shared.data)
	}

	func convertData(_ data: PESData?) -> (Region, [Region])? {
		var elms = [Region]()
		if let data = PESManager.shared.data {
			let country = Region(element: data)
			for elm in data.data.values {
				elms.append(Region(element: elm))
			}
			return (country, elms.sorted {$0.id.rawValue < $1.id.rawValue })
		}
		return nil
	}

	var upToDateData: Bool { PESManager.shared.data?.isToday == true }

	var body: some View {

		ZStack(alignment: .top) {

			Rectangle().foregroundColor(.background)
				.edgesIgnoringSafeArea(.all)

			if let country = data?.0 {
				VStack(spacing: 0) {
					RegionView(element: country, upToDate: upToDateData)
					Divider().foregroundColor(.fill)
					Divider().foregroundColor(.fill)
					Divider().foregroundColor(.fill)
				}.background(Color.background).zIndex(1)
			}

			ScrollView {
				VStack(spacing: 0) {
					ForEach(data?.1 ?? [], id: \.id) { element in
						RegionView(element: element)
						Divider().foregroundColor(.fill)
					}
				}
			}.padding(.top, 64)


		}.onAppear {
			loadData()
		}
	}
}

struct MainView_Previews: PreviewProvider {
	static var previews: some View {
		MainView().preferredColorScheme(.dark)

	}
}

public extension Color {
	static let fill = Color(UIColor.systemFill)
	static let background = Color(UIColor(named: "NiceBackground")!)
}
