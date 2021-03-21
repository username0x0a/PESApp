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

struct MainView: View {

	@State var data = [Region]()

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

	func convertData(_ data: PESData?) -> [Region] {
		var elms = [Region]()
		if let data = PESManager.shared.data {
			elms.append(Region(element: data))
			for elm in data.data.values {
				elms.append(Region(element: elm))
			}
		}
		return elms.sorted { $0.id.rawValue < $1.id.rawValue }
	}

	var body: some View {

		ScrollView {
			VStack(spacing: 0) {
				ForEach(data, id: \.id) { element in
					HStack(spacing: 0) {
						Spacer().frame(width: 24)
						VStack(spacing: 0) {
							HStack {
								Text("\(element.name)")
									.font(.custom("CircularPro-Medium", size: 24))
								Spacer()
								ZStack {
									Text("\(element.index)")
										.font(.custom("CircularPro-Bold", size: 28))
										.foregroundColor(.white)
								}.frame(width: 48, height: 48)
								.background(element.color).cornerRadius(24)
							}.frame(height: 63)
						}
						Spacer().frame(width: 24)
					}.frame(height: 64)
					Divider().foregroundColor(.black)
					if element.id == .Czechia {
						Divider().foregroundColor(.black)
						Divider().foregroundColor(.black)
						Divider().foregroundColor(.black)
					}
				}
			}
		}.onAppear {
			loadData()
		}
	}
}

struct MainView_Previews: PreviewProvider {
	static var previews: some View {
		MainView()
	}
}
