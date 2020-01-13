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
    
    var simpleTinyTitleProvider: CLKSimpleTextProvider {
        CLKSimpleTextProvider(text: "Xcode 11.3", shortText: "11.3")
    }
    
    var simpleTinyBodyProvider: CLKSimpleTextProvider {
        CLKSimpleTextProvider(text: "GM Seed 1", shortText: "GM 1")
    }
    
    var simpleAppNameProvider: CLKSimpleTextProvider {
        CLKSimpleTextProvider(text: "Xcode Releases", shortText: "Xcode")
    }
    
    var simpleSingleTextProvider: CLKSimpleTextProvider {
        CLKSimpleTextProvider(text: "Xcode: 11.3 GM Seed 1", shortText: "11.3 GM1")
    }
    
    var simpleReleaseDateProvider: CLKSimpleTextProvider {
        CLKSimpleTextProvider(text: "Released: 12/19/19", shortText: "12/19/19")
    }
    
    var logoImageProvider: CLKFullColorImageProvider {
        CLKFullColorImageProvider(fullColorImage: UIImage(named: "Xcode")!)
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
            let template = CLKComplicationTemplateGraphicCornerCircularImage()
            template.imageProvider = logoCircularImageProvider
            return template
        case .graphicRectangular:
            let template = CLKComplicationTemplateGraphicRectangularStandardBody()
            template.headerImageProvider = logoSmallImageProvider
            template.headerTextProvider = simpleAppNameProvider
            template.body1TextProvider = simpleSingleTextProvider
            template.body2TextProvider = simpleReleaseDateProvider
            return template
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerImageProvider = logoFlatImageProvider
            template.headerTextProvider = simpleAppNameProvider
            template.body1TextProvider = simpleSingleTextProvider
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
            template.textProvider = simpleTinyBodyProvider
            return template
        @unknown default:
            assertionFailure("WTH")
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = simpleSingleTextProvider
            return template
        }
    }
    
}


