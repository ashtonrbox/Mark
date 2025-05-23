//
//  MarkApp.swift
//  Mark
//
//  Created by Ashton Box on 23/5/2025.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    
    let timetable: [Int: [String]] = [
        1: ["English", "VCD", "Maths", "Economics", "History", "Health"],
        2: ["Horizon", "History", "Maths", "Maths", "Health", "Religion"],
        3: ["English", "English", "VCD", "VCD", "Religion", "Economics"],
        4: ["Economics", "Economics", "History", "History", "English", "Maths"],
        5: ["Religion", "Religion", "Maths", "Economics", "VCD", "English"],
        6: ["Economics", "VCD", "English", "Religion", "History", "Maths"],
        7: ["History", "History", "Maths", "Maths", "Religion", "Health"],
        8: ["VCD", "VCD", "Religion", "Religion", "Economics", "Horizon"],
        9: ["Maths", "Health", "English", "English", "VCD", "History"],
        10: ["Religion", "History", "Economics", "Economics", "English", "VCD"]
    ]
    
    let timestamps: [Int: String] = [
        0: "8:45 - 9:35",
        1: "9:35 - 10:25",
        2: "10:50 - 11:40",
        3: "11:40 - 12:30",
        4: "1:20 - 2:10",
        5: "2:10 - 3:00"
    ]
    
    let pointers: [String: String] = [
        "VCD": "v",
        "Economics": "e",
        "History": "h",
        "Religion": "r",
        "English": "n",
        "Maths": "m",
        "Health": "a",
        "Horizon": "o",
    ]
    
    let calendar = Calendar.current
    
    let dayOne: Date = {
        let components = DateComponents(year: 2025, month: 5, day: 26)
        return Calendar.current.date(from: components)!
    }()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.prohibited)
        
        print(getCurrentDay())
        print(Date())

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(named: "Mark")
        }

        let menu = NSMenu()
        
        menu.addItem(NSMenuItem.separator())
        
        let today = getCurrentDay()
        if let todayClasses = timetable[today] {
            for (index, subject) in todayClasses.enumerated() {
                let time = timestamps[index] ?? "NIL"
                let classIcon = pointers[subject] ?? "NIL"
                let customView = createClassMenuItemView(subject: "\(subject)", time: time, iconName: classIcon)
                let menuItem = NSMenuItem()
                menuItem.view = customView
                menuItem.target = self
                menuItem.representedObject = "\(subject)"
                menu.addItem(menuItem)
                if (index == 1 || index == 3) {
                    menu.addItem(NSMenuItem.separator())
                }
            }
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Open Simon", action: #selector(openSimon), keyEquivalent: "s"))
        } else {
            menu.addItem(NSMenuItem(title: "No classes", action: nil, keyEquivalent: ""))
        }

        statusItem.menu = menu
    }
    
    func getCurrentDay() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: dayOne)
        
        let daysDifference = calendar.dateComponents([.day], from: start, to: today).day ?? 0
        
        var schoolDays = 0
        var current = start
        
        for _ in 0..<daysDifference {
            current = calendar.date(byAdding: .day, value: 1, to: current)!
            let weekday = calendar.component(.weekday, from: current)
            if weekday >= 2 && weekday <= 6 {
                schoolDays += 1
            }
        }
        
        let cycleDay = (schoolDays % 10) + 1
        return cycleDay
    }
    
    func createClassMenuItemView(subject: String, time: String, iconName: String) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 240, height: 35))
        view.setAccessibilityIdentifier(subject)

        let imageView = NSImageView()
        imageView.image = NSImage(named: iconName)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.symbolConfiguration = .init(pointSize: 14, weight: .regular)
        view.addSubview(imageView)

        let subjectLabel = NSTextField(labelWithString: subject)
        subjectLabel.translatesAutoresizingMaskIntoConstraints = false
        subjectLabel.font = NSFont(name: "Marlin Soft Basic", size: 15.5)
        view.addSubview(subjectLabel)

        let timeLabel = NSTextField(labelWithString: time)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = NSFont.systemFont(ofSize: 12)
        timeLabel.textColor = .secondaryLabelColor
        timeLabel.alignment = .right
        view.addSubview(timeLabel)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 18),
            imageView.heightAnchor.constraint(equalToConstant: 18),

            subjectLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            subjectLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 1),

            timeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            timeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: subjectLabel.trailingAnchor, constant: 8)
        ])
        
        let clickRecogniser = NSClickGestureRecognizer(target: self, action: #selector(handleCustomMenuClick(_:)))
        view.addGestureRecognizer(clickRecogniser)
        
        view.setAccessibilityIdentifier(subject)

        return view
    }

    @objc func handleCustomMenuClick(_ sender: NSClickGestureRecognizer) {
        guard let view = sender.view else { return }

        let subject = view.accessibilityIdentifier()
        let pointer = pointers[subject]
        
        let urlString = "https://teams.microsoft.com/v2/?sfelc=\(pointer ?? "none")"
        
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
            // NSApplication.shared.terminate(nil)
        }
    }
    
    @objc func openSimon() {
        if let url = URL(string: "https://simon.jpc.vic.edu.au/workdesk/") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}


@main
struct MarkApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {}
    }
}
