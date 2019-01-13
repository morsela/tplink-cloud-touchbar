//
//  DevicesViewController.swift
//  tplink-cloud-touchbar
//
//  Created by Mor Sela on 1/12/19.
//  Copyright © 2019 Sela. All rights reserved.
//

import Cocoa

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBar.CustomizationIdentifier {
    static let touchBar = NSTouchBar.CustomizationIdentifier("com.sela.tplink-cloud-touchbar.touchBar")
}

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBarItem.Identifier {
    static let popover = NSTouchBarItem.Identifier("com.sela.tplink-cloud-touchbar.TouchBarItem.popover")
    static let devices = NSTouchBarItem.Identifier("com.sela.tplink-cloud-touchbar.TouchBarItem.fontStyle")
    static let popoverSlider = NSTouchBarItem.Identifier("com.sela.tplink-cloud-touchbar.popoverBar.slider")
}

@available(OSX 10.12.2, *)
class PopoverScrubber: NSScrubber {
    var presentingItem: NSPopoverTouchBarItem?
}

class DevicesViewController: NSViewController {
    private lazy var client = TPLinkClient()
    
    public var devices: [TPLinkDevice] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.scrubber?.reloadData()
            }
        }
    }
    
    private var scrubber: PopoverScrubber?
    
    private static let itemViewIdentifier = "TextIconItemViewIdentifier"

    override func loadView() {
        self.view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        client.login(user: "morsela@gmail.com", password: "liatmor1", termId: "") { [weak self] _ in
            self?.refreshDevices()
        }
    }
    
    func applicationWillBecomeActive() {
        refreshDevices()
    }
    
    private func refreshDevices() {
        client.listDevices() { [weak self] result in
            if case .success(let devices) = result {
                self?.client.refreshDevicesState(devices: devices) { _ in
                    self?.devices = devices.filter { $0.info.status == 1 }.sorted(by: { $0.info.alias < $1.info.alias })
                }
            }
        }
    }
    
    // MARK: - NSTouchBar
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .touchBar
        touchBar.defaultItemIdentifiers = [.devices, .popover, NSTouchBarItem.Identifier.otherItemsProxy]
        touchBar.customizationAllowedItemIdentifiers = [.devices, .popover]
        
        return touchBar
    }
}

extension DevicesViewController: NSTouchBarDelegate {
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItem.Identifier.devices:
            let popoverItem = NSPopoverTouchBarItem(identifier: identifier)
            popoverItem.collapsedRepresentationLabel = NSLocalizedString("Scrubber Popover", comment:"")
            popoverItem.customizationLabel = NSLocalizedString("Scrubber Popover", comment:"")
            
            let layout = NSScrubberFlowLayout()
            layout.itemSpacing = 1.0
            
            let scrubber = PopoverScrubber()
            scrubber.scrubberLayout = layout
            scrubber.register(IconTextItemView.self, forItemIdentifier: NSUserInterfaceItemIdentifier(DevicesViewController.itemViewIdentifier))
            scrubber.mode = .free
            scrubber.selectionBackgroundStyle = .roundedBackground
            scrubber.delegate = self
            scrubber.dataSource = self
            scrubber.presentingItem = popoverItem
            scrubber.autoresizingMask = [.width, .height]
            
            popoverItem.collapsedRepresentation = scrubber
            self.scrubber = scrubber
            
            let popoverTouchBar = DevicePopoverTouchBar(presentingItem: popoverItem)
            popoverTouchBar.actionDelegate = self
            popoverItem.popoverTouchBar = popoverTouchBar
            
            return popoverItem
        default:
            return nil
        }
    }
}

@available(OSX 10.12.2, *)
extension DevicesViewController: NSScrubberDataSource, NSScrubberDelegate {
    
    func numberOfItems(for scrubber: NSScrubber) -> Int {
        return devices.count
    }
    
    // Scrubber is asking for a custom view represention for a particuler item index.
    func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
        var returnItemView = NSScrubberItemView()
        if let itemView =
            scrubber.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: type(of: self).itemViewIdentifier),
                              owner: nil) as? IconTextItemView {
            itemView.imageView.image = devices[index].state.isOff() ? NSImage(named: NSImage.statusNoneName) : NSImage(named: NSImage.statusAvailableName)
            itemView.textField.stringValue = devices[index].info.alias
            itemView.textField.textColor = devices[index].state.isOff() ? NSColor.darkGray : NSColor.orange
            returnItemView = itemView
        }
        return returnItemView
    }
    
    func scrubber(_ scrubber: NSScrubber, didSelectItemAt index: Int) {
        scrubber.selectedIndex = -1
        
        if let popoverScrubber = scrubber as? PopoverScrubber,
            let popoverItem = popoverScrubber.presentingItem,
            let popoverTouchBar = popoverItem.popoverTouchBar as? DevicePopoverTouchBar {
            popoverTouchBar.device = devices[index]
            
            print("\(devices[index].info.alias) tapped")

            popoverItem.showPopover(nil)
        }
    }
}

extension DevicesViewController: NSScrubberFlowLayoutDelegate {
    public func scrubber(_ scrubber: NSScrubber, layout: NSScrubberFlowLayout, sizeForItemAt itemIndex: Int) -> NSSize {
        let size = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        
        // Specify a system font size of 0 to automatically use the appropriate size.
        let title = devices[itemIndex].info.alias
        let textRect = title.boundingRect(with: size, options: [.usesFontLeading, .usesLineFragmentOrigin],
                                          attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 0)])
        
        var width: CGFloat = 100.0
        let image = devices[itemIndex].state.isOff() ? NSImage(named: NSImage.statusNoneName) : NSImage(named: NSImage.statusAvailableName)
        if let image = image {
            width = textRect.size.width + image.size.width + 6 + 10 + 20
        }
        
        return NSSize(width: ceil(width), height: 30)
    }
}

extension DevicesViewController: DevicePopoverTouchBarDelegate {
    func actionHandler(device: TPLinkDevice) {
        device.toggle(completion: { [weak self] _ in
            self?.scrubber?.reloadData()
            self?.scrubber?.presentingItem?.dismissPopover(nil)
        })
    }
    
    func sliderValueChanged(device: inout BulbDevice, sliderValue: Int) {
        device.setBrightness(Int32(sliderValue))
    }
}

