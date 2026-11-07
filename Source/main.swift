import AppKit
import SwiftUI

// Demo and UI tests use an isolated preference domain and never query an account.
let isDemo = CommandLine.arguments.contains("--demo")
let isUITest = CommandLine.arguments.contains("--test-drag-position") || CommandLine.arguments.contains("--test-window-lifecycle")
let isolatedDomain = "local.tokenmeter.test.\(ProcessInfo.processInfo.processIdentifier)"
let preferences = (isDemo || isUITest) ? UserDefaults(suiteName: isolatedDomain)! : .standard

final class MeterState: ObservableObject {
    @Published var short: Allowance?
    @Published var week: Allowance?
    @Published var updated: Date?
    @Published var problem: String?
    @Published var loading = false
    @Published var onTop = preferences.object(forKey:"onTop") as? Bool ?? true
    var changeLevel: (() -> Void)?
    var refreshAction: (() -> Void)?
    func setPosition(_ value: Bool) { onTop=value; preferences.set(value,forKey:"onTop"); changeLevel?() }
}

struct Ring: View {
    let value: Allowance?
    let label: String
    let stale: Bool
    var color: Color { stale ? .secondary : (value?.remaining ?? 100) == 0 ? .red : (value?.remaining ?? 100) <= 20 ? .orange : .accentColor }
    var body: some View {
        VStack(spacing:5) {
            ZStack {
                Circle().stroke(Color.primary.opacity(0.10),lineWidth:4)
                if let value { Circle().trim(from:0,to:CGFloat(value.remaining)/100).stroke(color,style:StrokeStyle(lineWidth:4,lineCap:.round)).rotationEffect(.degrees(-90)) }
                Text(value.map{"\($0.remaining)%"} ?? "—").font(.system(size:14,weight:.medium,design:.rounded)).monospacedDigit()
            }.frame(width:49,height:49)
            Text(label).font(.system(size:10)).foregroundStyle(.secondary)
        }.accessibilityElement(children:.ignore).accessibilityLabel("\(label): \(value.map{"\($0.remaining) percent remaining"} ?? "unavailable")\(stale ? ", last known reading" : "")")
    }
}
struct MeterView: View {
    @ObservedObject var state: MeterState
    let open: () -> Void
    var body: some View {
        Button(action:open) {
            VStack(spacing:9) {
                Text(state.problem != nil ? "Codex · Offline" : state.loading && state.updated == nil ? "Connecting…" : "Codex · Remaining").font(.system(size:10,weight:.medium)).foregroundStyle(.secondary)
                HStack(spacing:17) {Ring(value:state.short,label:"5 hour",stale:state.problem != nil);Ring(value:state.week,label:"Weekly",stale:state.problem != nil)}
            }.padding(13).frame(width:148,height:114).background(.regularMaterial,in:RoundedRectangle(cornerRadius:22)).overlay(RoundedRectangle(cornerRadius:22).stroke(.primary.opacity(0.08),lineWidth:0.5))
        }.buttonStyle(.plain).help("Token Meter settings and reset times")
    }
}
struct SettingsView: View {
    @ObservedObject var state: MeterState
    func countdown(_ a: Allowance?, _ now: Date) -> String {
        guard let reset=a?.reset else{return "Unavailable"}
        let interval=reset.timeIntervalSince(now)
        guard interval.isFinite, abs(interval) < 315_576_000 else { return "Unavailable" }
        let seconds=Int(interval)
        if seconds <= 0{return "Awaiting refresh"}
        let minutes=(seconds+59)/60
        return minutes>=1440 ? "In \(minutes/1440)d \((minutes%1440)/60)h" : minutes>=60 ? "In \(minutes/60)h \(minutes%60)m" : "In \(minutes)m"
    }
    var body: some View {
        VStack(alignment:.leading,spacing:13) {
            Text("Token Meter").font(.headline)
            TimelineView(.periodic(from:.now,by:60)) { context in
                VStack(spacing:8) {
                    HStack{Text("5-hour reset").foregroundStyle(.secondary);Spacer();Text(countdown(state.short,context.date))}
                    HStack{Text("Weekly reset").foregroundStyle(.secondary);Spacer();Text(countdown(state.week,context.date))}
                }.font(.system(size:12)).monospacedDigit()
            }
            if state.short?.remaining == 0 || state.week?.remaining == 0 { Text("Usage limit reached. Waiting for reset.").font(.caption).foregroundStyle(.red) }
            Divider()
            Text("Window position").font(.system(size:12,weight:.medium))
            Picker("Window position",selection:Binding(get:{state.onTop},set:{state.setPosition($0)})) {
                Text("Always on top").tag(true);Text("On desktop").tag(false)
            }.pickerStyle(.segmented).labelsHidden()
            Text(state.onTop ? "Meter and settings stay above other windows." : "Windows can cover both the meter and settings.").font(.system(size:11)).foregroundStyle(.secondary)
            Divider()
            if let problem=state.problem { Text(problem).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal:false,vertical:true) }
            HStack {
                if let updated=state.updated { Text("Updated \(updated.formatted(date:.omitted,time:.shortened))").font(.system(size:10)).foregroundStyle(.secondary) }
                Spacer()
                Button(state.loading ? "Refreshing…" : "Refresh") {state.refreshAction?()}.disabled(state.loading)
            }
            Text("Codex allowance · no AI calls\nAutomatic while ChatGPT or Codex is running.").font(.system(size:10)).foregroundStyle(.secondary)
        }.padding(18).frame(width:290).background(Color(nsColor: .windowBackgroundColor))
    }
}

final class MeterPanel: NSPanel { override var canBecomeKey: Bool {true} }
// Accept the first physical click even when another application is active.
// Keep ordinary clicks while allowing a left-button drag from the entire box.
final class MeterClickButton: NSButton {
    private var pressPoint: NSPoint?
    private var pressOrigin = NSPoint.zero
    private var dragged = false
    var finishedDragging: (() -> Void)?
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    override var mouseDownCanMoveWindow: Bool { false }
    override func mouseDown(with event: NSEvent) {
        guard let window else { return }
        pressPoint = window.convertPoint(toScreen:event.locationInWindow)
        pressOrigin = window.frame.origin
        dragged = false
    }
    override func mouseDragged(with event: NSEvent) {
        guard let window, let start = pressPoint else { return }
        let point = window.convertPoint(toScreen:event.locationInWindow)
        let dx = point.x-start.x, dy = point.y-start.y
        if hypot(dx,dy) >= 3 { dragged = true }
        if dragged { window.setFrameOrigin(NSPoint(x:pressOrigin.x+dx,y:pressOrigin.y+dy)) }
    }
    override func mouseUp(with event: NSEvent) {
        guard pressPoint != nil else { return }
        pressPoint = nil
        if dragged { finishedDragging?() }
        else if bounds.contains(convert(event.locationInWindow,from:nil)) { sendAction(action,to:target) }
    }
}
final class AppDelegate: NSObject, NSApplicationDelegate {
    let state=MeterState()
    var panel: MeterPanel!
    var settingsPanel: MeterPanel!
    var status: NSStatusItem!
    var refreshTimer: Timer?
    var active=false
    var generation=0
    let positionDefaults = preferences
    let targetIDs:Set<String>=["com.openai.codex","com.openai.chat","com.openai.chatgpt","com.openai.ChatGPT"]
    func applicationDidFinishLaunching(_ notification:Notification) {
        NSApp.setActivationPolicy(.accessory)
        panel=MeterPanel(contentRect:NSRect(x:0,y:0,width:148,height:114),styleMask:[.borderless,.nonactivatingPanel],backing:.buffered,defer:false)
        panel.isOpaque=false;panel.backgroundColor = .clear;panel.hasShadow=true;panel.hidesOnDeactivate=false
        panel.isMovableByWindowBackground=false
        panel.collectionBehavior=[.canJoinAllSpaces,.stationary,.fullScreenAuxiliary]
        let container=NSView(frame:NSRect(x:0,y:0,width:148,height:114))
        let meterView=NSHostingView(rootView:MeterView(state:state,open:{}))
        meterView.frame=container.bounds
        meterView.autoresizingMask=[.width,.height]
        container.addSubview(meterView)
        let clickTarget=MeterClickButton(frame:container.bounds)
        clickTarget.title=""
        clickTarget.isTransparent=true
        clickTarget.isBordered=false
        clickTarget.autoresizingMask=[.width,.height]
        clickTarget.target=self
        clickTarget.action=#selector(toggleSettings)
        clickTarget.finishedDragging = {[weak self] in self?.savePosition()}
        clickTarget.setAccessibilityLabel("Codex usage — open Token Meter settings")
        container.addSubview(clickTarget)
        panel.contentView=container
        settingsPanel=MeterPanel(contentRect:NSRect(x:0,y:0,width:290,height:320),styleMask:[.titled,.closable,.nonactivatingPanel],backing:.buffered,defer:false)
        settingsPanel.title="Token Meter Settings"
        settingsPanel.isReleasedWhenClosed=false
        settingsPanel.hidesOnDeactivate=false
        settingsPanel.level = state.onTop ? .floating : .normal
        settingsPanel.collectionBehavior=[.canJoinAllSpaces,.fullScreenAuxiliary]
        settingsPanel.contentView=NSHostingView(rootView:SettingsView(state:state))
        state.changeLevel = {[weak self] in self?.positionSelectionChanged()}
        state.refreshAction = {[weak self] in self?.refresh()}
        applyLevel();position()
        status=NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
        status.button?.image=NSImage(systemSymbolName:"gauge.with.dots.needle.50percent",accessibilityDescription:"Token Meter")
        let menu=NSMenu()
        for (title,action) in [("Token Meter Settings",#selector(showSettings)),("Refresh Usage",#selector(manualRefresh)),("Reset Screen Position",#selector(resetPosition)),("Quit Token Meter",#selector(quit))] {
            let item=NSMenuItem(title:title,action:action,keyEquivalent:"");item.target=self;menu.addItem(item)
        }
        status.menu=menu
        status.isVisible=false
        let nc=NSWorkspace.shared.notificationCenter
        nc.addObserver(self,selector:#selector(appsChanged),name:NSWorkspace.didLaunchApplicationNotification,object:nil)
        nc.addObserver(self,selector:#selector(appsChanged),name:NSWorkspace.didTerminateApplicationNotification,object:nil)
        nc.addObserver(self,selector:#selector(keepBehindApps),name:NSWorkspace.didActivateApplicationNotification,object:nil)
        nc.addObserver(self,selector:#selector(woke),name:NSWorkspace.didWakeNotification,object:nil)
        nc.addObserver(self,selector:#selector(sleeping),name:NSWorkspace.willSleepNotification,object:nil)
        NotificationCenter.default.addObserver(self,selector:#selector(resetPosition),name:NSApplication.didChangeScreenParametersNotification,object:nil)
        if CommandLine.arguments.contains("--test-drag-position") {
            testDragPosition()
        } else if CommandLine.arguments.contains("--test-window-lifecycle") {
            testWindowLifecycle()
        } else if isDemo {
            state.onTop = true
            setMonitoringActive(true)
            panel.setFrameOrigin(NSPoint(x:120,y:480))
            showSettings()
            if let index = CommandLine.arguments.firstIndex(of:"--render-preview"), CommandLine.arguments.count > index+1 {
                let directory = CommandLine.arguments[index+1]
                DispatchQueue.main.asyncAfter(deadline:.now()+1) { self.renderPreview(directory) }
            }
        } else { appsChanged() }
    }
    func applicationWillTerminate(_ notification: Notification) {
        if isDemo || isUITest { preferences.removePersistentDomain(forName:isolatedDomain) }
    }
    func renderPreview(_ directory: String) {
        do {
            try FileManager.default.createDirectory(atPath:directory,withIntermediateDirectories:true)
            for (name, view) in [("meter", panel.contentView!), ("settings", settingsPanel.contentView!)] {
                view.layoutSubtreeIfNeeded()
                guard let bitmap = view.bitmapImageRepForCachingDisplay(in:view.bounds) else { throw NSError(domain:"Preview",code:1) }
                view.cacheDisplay(in:view.bounds,to:bitmap)
                guard let data = bitmap.representation(using:.png,properties:[:]) else { throw NSError(domain:"Preview",code:2) }
                try data.write(to:URL(fileURLWithPath:directory).appendingPathComponent(name+".png"))
            }
            print("PASS: native UI previews rendered with synthetic allowances")
            NSApp.terminate(nil)
        } catch { fputs("Preview rendering failed.\n",stderr); exit(1) }
    }
    func testDragPosition() {
        func check(_ condition: Bool, _ label: String) {
            guard condition else { fputs("FAIL: \(label)\n",stderr);exit(1) }
            print("PASS: \(label)")
        }
        defer { positionDefaults.removePersistentDomain(forName: isolatedDomain) }
        state.loading=true
        active=true
        let button=panel.contentView!.subviews.compactMap{$0 as? MeterClickButton}.first!
        func event(_ type:NSEvent.EventType,_ screenPoint:NSPoint) -> NSEvent {
            NSEvent.mouseEvent(with:type,location:panel.convertPoint(fromScreen:screenPoint),modifierFlags:[],timestamp:ProcessInfo.processInfo.systemUptime,windowNumber:panel.windowNumber,context:nil,eventNumber:0,clickCount:1,pressure:1)!
        }
        for top in [false,true] {
            state.onTop=top
            applyLevel()
            settingsPanel.orderOut(nil)
            defaultPosition()
            let origin=panel.frame.origin
            let start=NSPoint(x:origin.x+74,y:origin.y+57)
            button.mouseDown(with:event(.leftMouseDown,start))
            button.mouseUp(with:event(.leftMouseUp,start))
            check(settingsPanel.isVisible,"ordinary click still opens settings in mode \(top)")
            button.mouseDown(with:event(.leftMouseDown,start))
            button.mouseUp(with:event(.leftMouseUp,start))
            check(!settingsPanel.isVisible,"second click still closes settings")
            button.mouseDown(with:event(.leftMouseDown,start))
            button.mouseDragged(with:event(.leftMouseDragged,NSPoint(x:start.x-30,y:start.y-20)))
            let end=NSPoint(x:start.x-90,y:start.y-60)
            button.mouseDragged(with:event(.leftMouseDragged,end))
            button.mouseUp(with:event(.leftMouseUp,end))
            let moved=NSPoint(x:origin.x-90,y:origin.y-60)
            check(panel.frame.origin == moved,"successive drag events follow pointer without cumulative drift")
            check(!settingsPanel.isVisible,"drag does not open settings")
            let expected=top ? NSWindow.Level.floating.rawValue : NSWindow.Level.normal.rawValue-1
            check(panel.level.rawValue == expected,"drag preserves selected window level")
            defaultPosition()
            position()
            check(panel.frame.origin == moved,"saved origin restores through startup positioning")
        }
        positionDefaults.set(["x":1e9,"y":1e9],forKey:"meterOrigin")
        position()
        check(NSScreen.screens.contains(where:{$0.visibleFrame.intersects(panel.frame)}),"unavailable screen position falls back onscreen")
        resetPosition()
        let resetOrigin=panel.frame.origin
        panel.setFrameOrigin(NSPoint(x:0,y:0))
        position()
        check(panel.frame.origin == resetOrigin,"existing Reset Screen Position action also persists")
        print("PASS: drag and position regression tests complete; user preferences untouched")
        // Return through defer before terminating, to remove the isolated test domain.
        DispatchQueue.main.async { NSApp.terminate(nil) }
    }
    func testWindowLifecycle() {
        func check(_ condition: Bool, _ label: String) {
            guard condition else { fputs("FAIL: \(label)\n",stderr);exit(1) }
            print("PASS: \(label)")
        }
        // Suppress account reads while exercising the real host lifecycle path.
        state.loading=true
        for top in [false,true,false] {
            state.onTop=top
            applyLevel()
            setMonitoringActive(true)
            showSettings()
            let expected=top ? NSWindow.Level.floating.rawValue : NSWindow.Level.normal.rawValue-1
            check(panel.level.rawValue == expected && settingsPanel.level.rawValue == expected,"both windows use selected level")
            setMonitoringActive(false)
            check(!panel.isVisible && !settingsPanel.isVisible,"host quit hides both windows")
            setMonitoringActive(true)
            showSettings()
            check(panel.isVisible && settingsPanel.isVisible,"host reopen permits settings")
            check(panel.level.rawValue == expected && settingsPanel.level.rawValue == expected,"placement survives host reopen")
            check(panel.isFloatingPanel == top && settingsPanel.isFloatingPanel == top,"floating behavior matches mode")
            setMonitoringActive(false)
        }
        state.onTop=true
        setMonitoringActive(true)
        showSettings()
        state.onTop=false
        state.changeLevel?()
        check(!settingsPanel.isVisible && panel.isVisible,"selecting desktop collapses settings only")
        toggleSettings()
        check(settingsPanel.isVisible,"rings reopen settings in desktop mode")
        keepBehindApps()
        check(settingsPanel.isVisible,"reapplying placement does not dismiss reopened settings")
        setMonitoringActive(false)
        print("PASS: lifecycle regression tests complete; saved preferences untouched")
        exit(0)
    }
    func positionSelectionChanged() {
        applyLevel()
        if !state.onTop { settingsPanel.orderOut(nil) }
    }
    func applyLevel() {
        // A dedicated level below normal app windows, but far above Finder's
        // wallpaper/icons. Ordering at the normal level is not restart-stable.
        let level = state.onTop ? NSWindow.Level.floating : NSWindow.Level(rawValue: NSWindow.Level.normal.rawValue - 1)
        panel.isFloatingPanel = state.onTop
        settingsPanel.isFloatingPanel = state.onTop
        panel.level = level
        settingsPanel.level = level
    }
    @objc func keepBehindApps(){if active {applyLevel()}}
    func position() {
        if let saved=positionDefaults.dictionary(forKey:"meterOrigin"),
           let x=saved["x"] as? Double, let y=saved["y"] as? Double, x.isFinite, y.isFinite {
            let frame=NSRect(origin:NSPoint(x:x,y:y),size:panel.frame.size)
            // Keep the stored location exactly when the box remains accessible.
            if NSScreen.screens.contains(where:{$0.visibleFrame.intersection(frame).width >= 32 && $0.visibleFrame.intersection(frame).height >= 32}) {
                panel.setFrameOrigin(frame.origin)
                return
            }
        }
        defaultPosition()
    }
    func defaultPosition() {
        guard let screen=NSScreen.main ?? NSScreen.screens.first else{return}
        let rect=screen.visibleFrame
        panel.setFrameOrigin(NSPoint(x:rect.maxX-166,y:rect.maxY-128))
    }
    func savePosition() {
        positionDefaults.set(["x":Double(panel.frame.origin.x),"y":Double(panel.frame.origin.y)],forKey:"meterOrigin")
    }
    @objc func resetPosition(){defaultPosition();savePosition()}
    @objc func appsChanged() {
        guard !isDemo && !isUITest else { return }
        let running=NSWorkspace.shared.runningApplications.contains { app in targetIDs.contains(app.bundleIdentifier ?? "") && !app.isTerminated }
        setMonitoringActive(running)
    }
    func setMonitoringActive(_ running: Bool) {
        guard running != active else{return}
        active=running;generation+=1
        status.isVisible=running
        if running {
            applyLevel();panel.orderFrontRegardless();applyLevel();refresh()
            refreshTimer=Timer.scheduledTimer(withTimeInterval:180,repeats:true){[weak self] _ in self?.refresh()}
        } else {
            refreshTimer?.invalidate();refreshTimer=nil;settingsPanel.orderOut(nil);panel.orderOut(nil)
        }
    }
    @objc func sleeping(){refreshTimer?.invalidate();refreshTimer=nil}
    @objc func woke(){if active {refresh();refreshTimer=Timer.scheduledTimer(withTimeInterval:180,repeats:true){[weak self] _ in self?.refresh()}}}
    func refresh() {
        if isDemo {
            state.short = Allowance(remaining:72,reset:Date().addingTimeInterval(7200),minutes:300)
            state.week = Allowance(remaining:41,reset:Date().addingTimeInterval(259200),minutes:10080)
            state.updated = Date(); state.problem = nil; state.loading = false
            return
        }
        guard active && !state.loading else{return}
        state.loading=true
        let expected=generation
        DispatchQueue.global(qos:.utility).async { [weak self] in
            let result=UsageReader.read()
            DispatchQueue.main.async { [weak self] in
                guard let self else{return}
                self.state.loading=false
                guard self.active,expected == self.generation else {if self.active {self.refresh()};return}
                switch result {
                case .success(let s):self.state.short=s.short;self.state.week=s.week;self.state.updated=Date();self.state.problem=nil
                case .failure(let e):self.state.problem=e.localizedDescription
                }
            }
        }
    }
    @objc func toggleSettings(){if settingsPanel.isVisible {settingsPanel.orderOut(nil)} else {showSettings()}}
    @objc func showSettings(){
        guard active else{return}
        guard let screen=panel.screen ?? NSScreen.main else { return }
        let visible=screen.visibleFrame
        let fitting=settingsPanel.contentView!.fittingSize
        settingsPanel.setContentSize(NSSize(width:290,height:max(280,fitting.height)))
        let size=settingsPanel.frame.size
        let x=max(visible.minX+8,min(panel.frame.maxX-size.width,visible.maxX-size.width-8))
        let y=max(visible.minY+8,min(panel.frame.minY-size.height-8,visible.maxY-size.height-8))
        settingsPanel.setFrameOrigin(NSPoint(x:x,y:y))
        settingsPanel.makeKeyAndOrderFront(nil)
        applyLevel()
        settingsPanel.orderFrontRegardless()
    }
    @objc func manualRefresh(){refresh()}
    @objc func quit(){NSApp.terminate(nil)}
}

if CommandLine.arguments.contains("--self-test") {
    func check(_ pass:Bool,_ name:String){if !pass{fputs("FAIL: \(name)\n",stderr);exit(1)}}
    check(Allowance.parse(["usedPercent":12.0,"windowDurationMins":300])?.remaining == 88,"remaining conversion")
    check(Allowance.parse(["usedPercent":120.0,"windowDurationMins":300])?.remaining == 0,"clamp lower")
    check(Allowance.parse(["usedPercent":-2.0,"windowDurationMins":300])?.remaining == 100,"clamp upper")
    check(Allowance.parse(["windowDurationMins":300]) == nil,"missing data not zero")
    let s=Snapshot.parse(["rateLimitsByLimitId":["codex":["primary":["usedPercent":7.0,"windowDurationMins":10080],"secondary":["usedPercent":12.0,"windowDurationMins":300]]]])
    check(s?.short?.remaining == 88 && s?.week?.remaining == 93,"windows mapped by duration")
    check(Snapshot.parse(["rateLimits":["limitId":"other"]]) == nil,"wrong bucket rejected")
    print("PASS: six parsing and allowance checks");exit(0)
}
if CommandLine.arguments.contains("--check-connection") {
    switch UsageReader.read(){case .success:print("Connected: recognized Codex allowance windows available.");exit(0)
    case .failure(let e):fputs("\(e.localizedDescription)\n",stderr);exit(1)}
}
let app=NSApplication.shared
let delegate=AppDelegate()
app.delegate=delegate
app.run()
