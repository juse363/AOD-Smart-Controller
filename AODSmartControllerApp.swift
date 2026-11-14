import SwiftUI

@main
struct AODSmartControllerApp: App {
    @StateObject private var proximity = ProximityMonitor()
    @StateObject private var motion = MotionMonitor()
    @StateObject private var engine = AODDecisionEngine()
    @StateObject private var systemInspector = SystemCapabilityInspector()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(proximity)
                .environmentObject(motion)
                .environmentObject(engine)
                .environmentObject(systemInspector)
                .onAppear {
                    proximity.start()
                    motion.start()
                    engine.update(proximityCovered: proximity.isCovered, faceDown: motion.isFaceDown)
                }
                .onChange(of: proximity.isCovered) { _, value in
                    engine.update(proximityCovered: value)
                }
                .onChange(of: motion.isFaceDown) { _, value in
                    engine.update(faceDown: value)
                }
        }
    }
}
