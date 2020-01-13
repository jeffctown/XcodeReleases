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
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(template(for: complication.family))
    }
    
    
    //beta #
    //gm seed #
    //gm
    //GM1
    //GM
    var simpleTextProvider: CLKSimpleTextProvider {
        CLKSimpleTextProvider(text: "Xcode: 11.3 GM Seed 1", shortText: "11.3 GM1")
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
    
      
    func template(for family: CLKComplicationFamily) -> CLKComplicationTemplate {
        switch family {
        case .circularSmall: //good
            let template = CLKComplicationTemplateCircularSmallStackText()
            template.line1TextProvider = simpleAppNameProvider
            template.line2TextProvider = simpleTextProvider
            return template
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeStackText()
            template.line1TextProvider = simpleAppNameProvider
            template.line2TextProvider = simpleTextProvider
            return template
        case .graphicBezel:
            let template = CLKComplicationTemplateGraphicBezelCircularText()
            template.textProvider = simpleSingleTextProvider
            template.circularTemplate = self.template(for: .graphicCircular) as! CLKComplicationTemplateGraphicCircular
            return template
        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularImage()
            template.imageProvider = logoImageProvider
            return template
        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerCircularImage()
            template.imageProvider = logoImageProvider
            return template
        case .graphicRectangular:
            let template = CLKComplicationTemplateGraphicRectangularStandardBody()
            template.headerTextProvider = simpleAppNameProvider
            template.body1TextProvider = simpleTextProvider
            template.body2TextProvider = simpleReleaseDateProvider
            return template
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = simpleAppNameProvider
            template.body1TextProvider = simpleTextProvider
            template.body2TextProvider = simpleReleaseDateProvider
            return template
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = simpleAppNameProvider
            template.line2TextProvider = simpleTextProvider
            return template
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = simpleSingleTextProvider
            return template
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallRingText()
            template.textProvider = simpleTextProvider
            return template
        case .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = simpleTextProvider
            return template
        default:
            fatalError("WTH")
        }
    }
    
}


