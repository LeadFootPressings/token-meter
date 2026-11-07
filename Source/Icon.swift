import AppKit
let destination=CommandLine.arguments[1]
try FileManager.default.createDirectory(atPath:destination,withIntermediateDirectories:true)
for size in [16,32,128,256,512] {
 for scale in [1,2] {
  let n=size*scale
  let bitmap=NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:n,pixelsHigh:n,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0)!
  NSGraphicsContext.saveGraphicsState();NSGraphicsContext.current=NSGraphicsContext(bitmapImageRep:bitmap)
  let c=CGFloat(n)
  NSColor(calibratedWhite:0.94,alpha:1).setFill();NSBezierPath(roundedRect:NSRect(x:c*0.06,y:c*0.06,width:c*0.88,height:c*0.88),xRadius:c*0.20,yRadius:c*0.20).fill()
  for x in [0.32,0.68] {
   let center=NSPoint(x:c*x,y:c*0.5)
   let track=NSBezierPath();track.appendArc(withCenter:center,radius:c*0.135,startAngle:0,endAngle:360);track.lineWidth=c*0.045
   NSColor(calibratedWhite:0.82,alpha:1).setStroke();track.stroke()
   let ring=NSBezierPath();ring.appendArc(withCenter:center,radius:c*0.135,startAngle:90,endAngle:x<0.5 ? -215 : -175,clockwise:true);ring.lineWidth=c*0.045;ring.lineCapStyle = .round;NSColor.systemBlue.setStroke();ring.stroke()
  }
  NSGraphicsContext.restoreGraphicsState()
  let suffix=scale==2 ? "@2x" : ""
  try bitmap.representation(using:.png,properties:[:])!.write(to:URL(fileURLWithPath:"\(destination)/icon_\(size)x\(size)\(suffix).png"))
 }
}
