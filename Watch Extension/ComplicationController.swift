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
    
    let persistence = Persistence()
    
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
        handler(template(for: complication.family))
    }
    
    var version: String {
        guard let release = persistence.latestRelease,
            let number = release.version.number else {
            return "xx.x.x"
        }
        
        return "\(number)"
    }
    
    var simpleTinyBodyProvider: CLKSimpleTextProvider {
        guard let release = persistence.latestRelease else {
            return CLKSimpleTextProvider(text: "xx")
        }
        
        let releaseType = release.version.release
        switch releaseType {
        case .dp(let dpVersion):
            return CLKSimpleTextProvider(text: "Dev Pre \(dpVersion)", shortText: "DP \(dpVersion)")
        case .beta(let betaVersion):
            return CLKSimpleTextProvider(text: "Beta \(betaVersion)", shortText: "β\(betaVersion)")
        case .gmSeed(let seedVersion):
            return CLKSimpleTextProvider(text: "GM Seed \(seedVersion)", shortText: " GM \(seedVersion)")
        case .gm:
            return CLKSimpleTextProvider(text: "GM")
        }
    }
    
    var simpleAppNameProvider: CLKSimpleTextProvider {
        CLKSimpleTextProvider(text: "Xcode Releases", shortText: "Xcode")
    }
    
    var simpleSingleTextProvider: CLKSimpleTextProvider {
        CLKSimpleTextProvider(text: "Xcode: \(version) \(simpleTinyBodyProvider.text)", shortText: "\(version) \(simpleTinyBodyProvider.shortText ?? "xx")")
    }
    
    var simpleVersionTextProvider: CLKSimpleTextProvider {
        CLKSimpleTextProvider(text: "\(version) \(simpleTinyBodyProvider.text)", shortText: "\(version) \(simpleTinyBodyProvider.shortText ?? "xx")")
    }
    
    var simpleReleaseDateProvider: CLKSimpleTextProvider {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("M/d/yy")
        
        let defaultProvider: () -> CLKSimpleTextProvider = {
            #if DEBUG
            dateFormatter.setLocalizedDateFormatFromTemplate("M/d/yy, h:mm a")
            #else
            dateFormatter.setLocalizedDateFormatFromTemplate("M/d/yy")
            #endif
            let dateString = dateFormatter.string(from: Date())
            return CLKSimpleTextProvider(text: "Released: \(dateString)", shortText: "\(dateString)")
        }
        
        #if DEBUG
        // show the current time so its easier to know when this was updated
        return defaultProvider()
        #else
        guard let release = persistence.latestRelease,
            let date = release.date.components.date else {
            return defaultProvider()
        }
        let dateString = dateFormatter.string(from: date)
        return CLKSimpleTextProvider(text: "Released: \(dateString)", shortText: "\(dateString)")
        #endif
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


