//
//  ComplicationController.swift
//  watchapp Extension
//
//  Created by Michal Zelinka on 17/11/2020.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Complication Configuration

	@available(watchOSApplicationExtension 7.0, *)
	func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "complication", displayName: "PESPES", supportedFamilies: CLKComplicationFamily.allCases)
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
		if let template = template(for: complication, sample: false) {
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

	func template(for complication: CLKComplication, sample: Bool) -> CLKComplicationTemplate? {

		let data = PESManager.shared.data

		// TODO: Proper selection
		let region = "JM"
		var index = data?.index ?? 0

		if sample {
			index = (25...85).randomElement()!
		}

		let rating = PESRatingForIndex(index)
		let colorValue = PESRatingColor[rating] ?? 0x000000
		let color = UIColor(rgb: colorValue)

		let no1Color = UIColor(rgb: PESRatingColor[.no1]!)
		let no2Color = UIColor(rgb: PESRatingColor[.no2]!)
		let no3Color = UIColor(rgb: PESRatingColor[.no3]!)
		let no4Color = UIColor(rgb: PESRatingColor[.no4]!)
		let no5Color = UIColor(rgb: PESRatingColor[.no5]!)

		let allColors = [
			no1Color, no1Color,
			no2Color, no2Color,
			no3Color, no3Color,
			no4Color, no4Color,
			no5Color, no5Color
		]
		let shift = 0.05
		let allLocations: [NSNumber] = [
			NSNumber(value: 0), NSNumber(value: 0.2-shift),
			NSNumber(value: 0.2+shift), NSNumber(value: 0.4-shift),
			NSNumber(value: 0.4+shift), NSNumber(value: 0.6-shift),
			NSNumber(value: 0.6+shift), NSNumber(value: 0.75-shift),
			NSNumber(value: 0.75+shift), NSNumber(value: 1)
		]

		switch complication.family {
			case .modularSmall:
				let t = CLKComplicationTemplateModularSmallStackText()
				t.line1TextProvider = CLKSimpleTextProvider(text: "\(rating.rawValue)")
				t.line2TextProvider = CLKSimpleTextProvider(text: "\(index)")
				t.tintColor = color
				return t
			case .modularLarge:
				let t = CLKComplicationTemplateModularLargeStandardBody()
				t.headerTextProvider = CLKSimpleTextProvider(text: "\(region)")
				t.headerTextProvider.tintColor = color
				t.body1TextProvider = CLKSimpleTextProvider(text: "Index: \(index)")
				t.body2TextProvider = CLKSimpleTextProvider(text: "Rating: \(rating.rawValue)")
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
				t.textProvider = CLKSimpleTextProvider(text: "\(index) · \(rating.rawValue)")
				t.textProvider.tintColor = color
				return t
			case .utilitarianLarge:
				let t = CLKComplicationTemplateUtilitarianLargeFlat()
				t.textProvider = CLKSimpleTextProvider(text: "Index \(index) · Rating \(rating.rawValue)")
				t.textProvider.tintColor = color
				return t
			case .circularSmall:
				let t = CLKComplicationTemplateCircularSmallStackText()
				t.line1TextProvider = CLKSimpleTextProvider(text: "\(rating.rawValue)")
				t.line2TextProvider = CLKSimpleTextProvider(text: "\(index)")
				t.tintColor = color
				return t
			case .extraLarge:
				let t = CLKComplicationTemplateExtraLargeStackText()
				t.line1TextProvider = CLKSimpleTextProvider(text: "IDX")
				t.line1TextProvider.tintColor = color
				t.line2TextProvider = CLKSimpleTextProvider(text: "\(index)")
				return t
			case .graphicCorner:
				let t = CLKComplicationTemplateGraphicCornerGaugeText()
				t.leadingTextProvider = CLKSimpleTextProvider(text: "\(rating.rawValue) ")
				t.trailingTextProvider = CLKSimpleTextProvider(text: " \(index)")
				t.outerTextProvider = CLKSimpleTextProvider(text: "\(index)")
				t.gaugeProvider = CLKSimpleGaugeProvider(style: .ring,
					gaugeColors: allColors, gaugeColorLocations: allLocations, fillFraction: Float(index)/100)
				return t
			case .graphicBezel:
				let t = CLKComplicationTemplateGraphicBezelCircularText()
				let s = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText()
				s.gaugeProvider = CLKSimpleGaugeProvider(style: .ring,
					gaugeColors: allColors, gaugeColorLocations: allLocations, fillFraction: Float(index)/100)
				s.centerTextProvider = CLKSimpleTextProvider(text: "\(index)")
				s.bottomTextProvider = CLKSimpleTextProvider(text: "IDX")
				s.bottomTextProvider.tintColor = color
				t.circularTemplate = s
				t.textProvider = CLKSimpleTextProvider(text: "Index \(index) · Rating \(rating.rawValue)")
				return t
			case .graphicCircular:
				let t = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText()
				t.centerTextProvider = CLKSimpleTextProvider(text: "\(index)")
				t.bottomTextProvider = CLKSimpleTextProvider(text: "IDX")
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
