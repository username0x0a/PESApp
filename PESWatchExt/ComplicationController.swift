//
//  ComplicationController.swift
//  PES
//
//  Created by Michal Zelinka on 17/11/2020.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {

	override init() {
		PESManager.shared.checkDataUpdate { result in
			guard case .success = result else { return }
			DispatchQueue.main.async {
				ComplicationController.reloadComplications()
			}
		}
	}

	// MARK: - Complication Configuration

	@available(watchOSApplicationExtension 7.0, *)
	func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
		let descriptors = [
			CLKComplicationDescriptor(identifier: "complication", displayName: "PES",
									  supportedFamilies: CLKComplicationFamily.allCases)
			// Multiple complication support can be added here with more descriptors
		]

		// Call the handler with the currently supported complication descriptors
		handler(descriptors)
	}

	@available(watchOSApplicationExtension 7.0, *)
	func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
		// Do any necessary work to support these newly shared complication descriptors
	}

	// MARK: - Timeline Configuration

	func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
		// Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
		handler(nil)
	}

	func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
		// Call the handler with your desired behavior when the device is locked
		handler(.showOnLockScreen)
	}

	// MARK: - Timeline Population

	func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
		var entry: CLKComplicationTimelineEntry?
		if let template = template(for: complication) {
			entry = CLKComplicationTimelineEntry(date: .init(), complicationTemplate: template)
		}
		handler(entry)
	}

	func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
		// Call the handler with the timeline entries after the given date
		handler(nil)
	}

	// MARK: - Sample Templates

	func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
		handler(template(for: complication, sample: true))
	}
}

extension ComplicationController {

	class func reloadComplications() {
		let server = CLKComplicationServer.sharedInstance()
		for complication in server.activeComplications ?? [] {
			server.reloadTimeline(for: complication)
		}
	}

}

extension ComplicationController {

	static let gaugeColors: [UIColor] = {
		let no1Color = UIColor(rgb: PESRatingColor[.no1]!)
		let no2Color = UIColor(rgb: PESRatingColor[.no2]!)
		let no3Color = UIColor(rgb: PESRatingColor[.no3]!)
		let no4Color = UIColor(rgb: PESRatingColor[.no4]!)
		let no5Color = UIColor(rgb: PESRatingColor[.no5]!)

		return [
			no1Color, no1Color,
			no2Color, no2Color,
			no3Color, no3Color,
			no4Color, no4Color,
			no5Color, no5Color
		]
	}()

	static let gaugeLocations: [NSNumber] = {
		let shift = 0.05
		return [
			NSNumber(value: 0), NSNumber(value: 0.2-shift),
			NSNumber(value: 0.2+shift), NSNumber(value: 0.4-shift),
			NSNumber(value: 0.4+shift), NSNumber(value: 0.6-shift),
			NSNumber(value: 0.6+shift), NSNumber(value: 0.75-shift),
			NSNumber(value: 0.75+shift), NSNumber(value: 1)
		]
	}()

	enum StringPattern: String {
		case index
		case level
	}

	func str(_ pattern: StringPattern) -> String {
		switch pattern {
			case .index: return NSLocalizedString("Index", comment: "String pattern")
			case .level: return NSLocalizedString("Level", comment: "String pattern")
		}
	}

	func template(for complication: CLKComplication, sample: Bool = false) -> CLKComplicationTemplate? {

		let data = PESManager.shared.data
		var element: PESElement? = data

		if let region = PESManager.shared.regionSelection {
			element = data?.data[region] ?? data
		}

		let index = !sample ? element?.index ?? 0 : .random(in: 25...85)
		let rating = PESRatingForIndex(index)
		let color = UIColor(rgb: PESRatingColor[rating] ?? 0x000000)

		let allColors = Self.gaugeColors
		let allLocations = Self.gaugeLocations

		switch complication.family {

			case .modularSmall:
				let t = CLKComplicationTemplateModularSmallStackText()
				t.line1TextProvider = CLKSimpleTextProvider(text: "\(rating.rawValue)")
				t.line2TextProvider = CLKSimpleTextProvider(text: "\(index)")
				t.tintColor = color
				return t

			case .modularLarge:
				let t = CLKComplicationTemplateModularLargeStandardBody()
				t.headerTextProvider = CLKSimpleTextProvider(text: element?.name ?? "")
				t.headerTextProvider.tintColor = color
				t.body1TextProvider = CLKSimpleTextProvider(text: str(.index) + ": \(index)")
				t.body2TextProvider = CLKSimpleTextProvider(text: str(.level) + ": \(rating.rawValue)")
				return t

			case .utilitarianSmall:
				let t = CLKComplicationTemplateUtilitarianSmallRingText()
				t.fillFraction = Float(index)/100
				t.ringStyle = .open
				t.textProvider = CLKSimpleTextProvider(text: "\(index)")
				t.textProvider.tintColor = color
				t.tintColor = color
				return t

			case .utilitarianSmallFlat:
				let t = CLKComplicationTemplateUtilitarianSmallFlat()
				t.textProvider = CLKSimpleTextProvider(text: "PES \(rating.rawValue)")
				t.textProvider.tintColor = color
				return t

			case .utilitarianLarge:
				let t = CLKComplicationTemplateUtilitarianLargeFlat()
				t.textProvider = CLKSimpleTextProvider(text: "PES " + str(.level) + " \(rating.rawValue) · " + str(.index) + " \(index)")
				t.textProvider.tintColor = color
				return t

			case .circularSmall:
				let t = CLKComplicationTemplateCircularSmallStackText()
				t.line1TextProvider = CLKSimpleTextProvider(text: "\(rating.rawValue)")
				t.line1TextProvider.tintColor = color
				t.line2TextProvider = CLKSimpleTextProvider(text: "\(index)")
				return t

			case .extraLarge:
				let t = CLKComplicationTemplateExtraLargeStackText()
				t.line1TextProvider = CLKSimpleTextProvider(text: "PES")
				t.line1TextProvider.tintColor = color
				t.line2TextProvider = CLKSimpleTextProvider(text: "\(rating.rawValue) · \(index)")
				return t

			case .graphicCorner:
				let t = CLKComplicationTemplateGraphicCornerGaugeText()
				t.leadingTextProvider = CLKSimpleTextProvider(text: "\(rating.rawValue)")
				t.trailingTextProvider = CLKSimpleTextProvider(text: "\(index)")
				t.outerTextProvider = CLKSimpleTextProvider(text: "PES")
				t.gaugeProvider = CLKSimpleGaugeProvider(style: .ring,
					gaugeColors: allColors, gaugeColorLocations: allLocations, fillFraction: Float(index)/100)
				return t

			case .graphicBezel:
				let t = CLKComplicationTemplateGraphicBezelCircularText()
				let s = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText()
				s.gaugeProvider = CLKSimpleGaugeProvider(style: .ring,
					gaugeColors: allColors, gaugeColorLocations: allLocations, fillFraction: Float(index)/100)
				s.centerTextProvider = CLKSimpleTextProvider(text: "\(index)")
				s.bottomTextProvider = CLKSimpleTextProvider(text: "PES")
				s.bottomTextProvider.tintColor = color
				t.circularTemplate = s
				t.textProvider = CLKSimpleTextProvider(text: "PES " + str(.level) + " \(rating.rawValue) · " + str(.index) + " \(index)")
				return t

			case .graphicCircular:
				let t = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText()
				t.centerTextProvider = CLKSimpleTextProvider(text: "\(index)")
				t.bottomTextProvider = CLKSimpleTextProvider(text: "PES")
				t.bottomTextProvider.tintColor = color
				t.gaugeProvider = CLKSimpleGaugeProvider(style: .ring,
					gaugeColors: allColors, gaugeColorLocations: allLocations, fillFraction: Float(index)/100)
				return t

			case .graphicRectangular:
				break

			case .graphicExtraLarge:
				break

			@unknown default:
				break

		}

		return nil
	}

}
