//
//  ComplicationController.swift
//  Watch Extension
//
//  Created by Jeff Lett on 1/13/20.
//  Copyright © 2020 Jeff Lett. All rights reserved.
//

import ClockKit
import WatchKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    static func reloadAll() {
        let complicationServer = CLKComplicationServer.sharedInstance()
        for complication in complicationServer.activeComplications ?? [] {
            complicationServer.reloadTimeline(for: complication)
        }
    }
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template(for: complication.family)))
    }
    
    // MARK: - Timeline Configuration
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(template(for: complication.family))
    }
    
    var major: Int {
        Int.random(in: 0 ..< 100)
    }
    
    var minor: Int {
        Int.random(in: 0 ..< 10)
    }
    
    var version: String {
        "\(major).\(minor)"
    }
    
    var simpleTinyBodyProvider: CLKSimpleTextProvider {
        CLKSimpleTextProvider(text: "GM Seed 1", shortText: "GM 1")
    }
    
    var simpleAppNameProvider: CLKSimpleTextProvider {
        CLKSimpleTextProvider(text: "Xcode Releases", shortText: "Xcode")
    }
    
    var simpleSingleTextProvider: CLKSimpleTextProvider {
        CLKSimpleTextProvider(text: "Xcode: \(version) GM Seed 1", shortText: "\(version) GM1")
    }
    
    var simpleVersionTextProvider: CLKSimpleTextProvider {
        CLKSimpleTextProvider(text: "\(version) GM Seed 1", shortText: "\(version) GM1")
    }
    
    var simpleReleaseDateProvider: CLKSimpleTextProvider {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("M/d/yy, h:mm a")
        let dateString = dateFormatter.string(from: Date())
        return CLKSimpleTextProvider(text: "Released: \(dateString)", shortText: "\(dateString)")
    }
    
    var logoImageProvider: CLKFullColorImageProvider {
        CLKFullColorImageProvider(fullColorImage: UIImage(named: "Xcode-Square")!)
    }
    
    var logoMediumImageProvider: CLKFullColorImageProvider {
        CLKFullColorImageProvider(fullColorImage: UIImage(named: "Xcode-Medium")!)
    }
    
    var logoSmallImageProvider: CLKFullColorImageProvider {
        CLKFullColorImageProvider(fullColorImage: UIImage(named:"Xcode-Small")!)
    }
    
    var logoFlatImageProvider: CLKImageProvider {
        CLKImageProvider(onePieceImage: UIImage(named: "Xcode-Flat")!)
    }
    
    var logoCircularImageProvider: CLKFullColorImageProvider {
        CLKFullColorImageProvider(fullColorImage: UIImage(named: "Xcode-Circular")!)
    }
    
    func template(for family: CLKComplicationFamily) -> CLKComplicationTemplate {
        switch family {
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallSimpleImage()
            template.imageProvider = logoFlatImageProvider
            return template
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeSimpleImage()
            template.imageProvider = logoFlatImageProvider
            return template
        case .graphicBezel:
            let template = CLKComplicationTemplateGraphicBezelCircularText()
            template.textProvider = simpleSingleTextProvider
            template.circularTemplate = self.template(for: .graphicCircular) as! CLKComplicationTemplateGraphicCircular
            return template
        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularImage()
            template.imageProvider = logoCircularImageProvider
            return template
        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerTextImage()
            template.imageProvider = logoMediumImageProvider
            template.textProvider = simpleSingleTextProvider
            return template
        case .graphicRectangular:
            let template = CLKComplicationTemplateGraphicRectangularStandardBody()
            template.headerImageProvider = logoSmallImageProvider
            template.headerTextProvider = simpleAppNameProvider
            template.body1TextProvider = simpleVersionTextProvider
            template.body2TextProvider = simpleReleaseDateProvider
            return template
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerImageProvider = logoFlatImageProvider
            template.headerTextProvider = simpleAppNameProvider
            template.body1TextProvider = simpleVersionTextProvider
            template.body2TextProvider = simpleReleaseDateProvider
            return template
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallSimpleImage()
            template.imageProvider = logoFlatImageProvider
            return template
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.imageProvider = logoFlatImageProvider
            template.textProvider = simpleSingleTextProvider
            return template
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallSquare()
            template.imageProvider = logoFlatImageProvider
            return template
        case .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.imageProvider = logoFlatImageProvider
            template.textProvider = simpleSingleTextProvider
            return template
        @unknown default:
            assertionFailure("WTH")
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = simpleSingleTextProvider
            return template
        }
    }
    
}


