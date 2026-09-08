import SwiftUI
import AppKit
@main struct PersooDesign {
 @MainActor static func main() throws {
  let args=CommandLine.arguments
  if let i=args.firstIndex(of:"--render"),args.count>i+1 {
   let out=URL(fileURLWithPath:args[i+1],isDirectory:true)
   try FileManager.default.createDirectory(at:out,withIntermediateDirectories:true)
   for s in Screen.allCases {try render(PersooScreen(screen:s),out.appendingPathComponent(s.rawValue+".png"),3)}
   for s in [Screen.home,.savings,.fitness,.settings] {
    try render(PersooScreen(screen:s).environment(\.persoo,Palette(dark:true)),out.appendingPathComponent(s.rawValue+"-dark.png"),2)
    try render(PersooScreen(screen:s,width:375,height:812),out.appendingPathComponent(s.rawValue+"-compact.png"),2)
   }
   for s in [Screen.language,.name,.homeEmpty] {try render(PersooScreen(screen:s,turkish:true),out.appendingPathComponent(s.rawValue+"-tr.png"),2)}
   print("Rendered 30 SwiftUI UI plates")
  } else {
   let app=NSApplication.shared;app.setActivationPolicy(.regular)
   let window=NSWindow(contentRect:NSRect(x:0,y:0,width:680,height:920),styleMask:[.titled,.closable,.miniaturizable,.resizable],backing:.buffered,defer:false)
   window.title="Persoo — Design Prototype · Synthetic data"
   window.contentView=NSHostingView(rootView:DesignBrowser());window.center();window.makeKeyAndOrderFront(nil);app.activate(ignoringOtherApps:true);app.run()
  }
 }
 @MainActor static func render<V:View>(_ view:V,_ url:URL,_ scale:CGFloat)throws {
  let r=ImageRenderer(content:view);r.scale=scale
  guard let im=r.cgImage,let data=NSBitmapImageRep(cgImage:im).representation(using:.png,properties:[:]) else {throw NSError(domain:"PersooRender",code:1)}
  try data.write(to:url)
 }
}
struct DesignBrowser:View {
 @State private var selected:Screen = .homeEmpty
 @State private var dark=false
 var body:some View {
  HStack(spacing:30) {
   VStack(alignment:.leading,spacing:8) {
    Text("Persoo").font(.title.bold());Text("Design prototype").font(.caption).foregroundStyle(.secondary)
    ScrollView {VStack(alignment:.leading,spacing:3) {ForEach(Screen.allCases) {s in Button(s.title){selected=s}.buttonStyle(.plain).padding(.vertical,5).foregroundStyle(s==selected ? .green : .primary)}}}
    Toggle("Dark appearance",isOn:$dark)
   }.frame(width:170)
   PersooScreen(screen:selected,navigate:{selected=$0}).environment(\.persoo,Palette(dark:dark)).clipShape(RoundedRectangle(cornerRadius:34)).shadow(color:.black.opacity(0.1),radius:20)
  }.padding(25).background(Color(hex:0xE6E9E5))
 }
}
