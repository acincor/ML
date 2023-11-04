// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import CoreGraphics
import UIKit
//细胞到系统，主要是神经，所以接下来是机器学习
public class MCMMModel {
    
    public var systemOfType: MCMMSystem?
    public var layer: MCMMLayer?
    private func create(message: MCMMMessage) {
        systemOfType = MCMMSystem(message: message)
        print("create a model -- \(systemOfType!)")
    }
    @available(iOS 15.0, *)
    ///判断same可不可用
    public func build(_ image1: UIImage, _ image2: UIImage) -> Bool {
        layer?.same(image1, image2)
        return layer?.build() != nil
    }
    public init(message: MCMMMessage) {
        layer = MCMMLayer()//这时候才会构建layer
        self.create(message: message)
    }
    
}
public class MCMMLayer {
    
    public func mcmm_layer_getPointColor(withImage image: UIImage, point: CGPoint) -> (CGFloat,CGFloat,CGFloat,CGFloat) {
        
        guard CGRect(origin: CGPoint(x: 0, y: 0), size: image.size).contains(point) else {
            return (0,0,0,0)
        }
        
        let pointX = trunc(point.x);
        let pointY = trunc(point.y);
        
        let width = image.size.width;
        let height = image.size.height;
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        var pixelData: [UInt8] = [0, 0, 0, 0]
        
        pixelData.withUnsafeMutableBytes { pointer in
            if let context = CGContext(data: pointer.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue), let cgImage = image.cgImage {
                context.setBlendMode(.copy)
                context.translateBy(x: -pointX, y: pointY - height)
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        }
        
        let red = CGFloat(pixelData[0]) / CGFloat(255.0)
        let green = CGFloat(pixelData[1]) / CGFloat(255.0)
        let blue = CGFloat(pixelData[2]) / CGFloat(255.0)
        let alpha = CGFloat(pixelData[3]) / CGFloat(255.0)
        
        return(red,green,blue,alpha)
    }
    var colorPoints = [CGPoint]()
    var colorPoints2 = [CGPoint]()
    @available(iOS 15.0, *)
    public func same(_ originalImage: UIImage, _ testImage: UIImage) {
        if originalImage.size.width > 100 || originalImage.size.height > 100 || testImage.size.width > 100 || testImage.size.height > 100 {
            NSLog("Please keep originalImage and testImage's width or height in 0 ... 100 ")
            return
        }
        var w = 1.0
        var i = 1.0
        print("machine learning for originalImage...")
        print("|",terminator: "")
        while w < originalImage.size.width {
            i = 1.0
                var color = mcmm_layer_getPointColor(withImage: originalImage, point: CGPoint(x: w, y: i))
                let Y = 0.2990*color.0+0.5870*color.1+0.1140*color.2
                if Y <= 255 && Y > 0 {
                    colorPoints.append(CGPoint(x: w, y: i))
                }
            var rgb = (color.0,color.1,color.2)
                i += 1
                color = mcmm_layer_getPointColor(withImage: originalImage, point: CGPoint(x: w, y: i))
                while i < originalImage.size.height {
                    var color = mcmm_layer_getPointColor(withImage: originalImage, point: CGPoint(x: w, y: i))
                    if (color.0,color.1,color.2) != rgb {
                        let Y = 0.2990*color.0+0.5870*color.1+0.1140*color.2
                        if Y <= 255 && Y > 0 {
                            if (color.0,color.1,color.2) != rgb {
                                colorPoints.append(CGPoint(x: w, y: i))
                            }
                        }
                        rgb = (color.0,color.1,color.2)
                    }
                    i += 1
                }
            w += 1
            if Int(w / (originalImage.size.width) * 10) != Int((w-1) / (originalImage.size.width) * 10) {
                for _ in 0..<Int(w / (originalImage.size.width) * 10){
                    print("☞",terminator: "")
                }
            }
        }
        print("|")
        w = 1.0
        i = 1.0
        print("machine learning for testImage...")
        print("|",terminator: "")
        while w < testImage.size.width {
            i = 1.0
            var color = mcmm_layer_getPointColor(withImage: testImage, point: CGPoint(x: w, y: i))
            let Y = 0.2990*color.0+0.5870*color.1+0.1140*color.2
            if Y <= 255 && Y > 0 {
                colorPoints2.append(CGPoint(x: w, y: i))
            }
            var rgb = (color.0,color.1,color.2)
            i += 1
            color = mcmm_layer_getPointColor(withImage: testImage, point: CGPoint(x: w, y: i))
            while i < testImage.size.height {
                var color = mcmm_layer_getPointColor(withImage: testImage, point: CGPoint(x: w, y: i))
                if (color.0,color.1,color.2) != rgb {
                    let Y = 0.2990*color.0+0.5870*color.1+0.1140*color.2
                    if Y <= 255 && Y > 0 {
                        if (color.0,color.1,color.2) != rgb {
                            colorPoints2.append(CGPoint(x: w, y: i))
                        }
                    }
                    rgb = (color.0,color.1,color.2)
                }
                i += 1
            }
            w += 1
            if Int(w / (testImage.size.width) * 10) != Int((w-1) / (testImage.size.width) * 10) {
                for _ in 0..<Int(w / (testImage.size.width) * 10){
                    print("☞",terminator: "")
                }
            }
        }
        print("|")
    }
    public func build() -> CGFloat {
        var sum = [CGFloat]()
        for p1 in colorPoints {
            if colorPoints2.contains(p1) {
                sum.append(1)
            } else {
                sum.append(0)
            }
        }
        var average = CGFloat(sum.reduce(0, +)) / CGFloat(sum.count)
        return average
    }
    public init() {
        
    }
}
public class MCMMSystem {
    public init(message: MCMMMessage) {
        self.tissues.append(MCMMTissue(message: message))
    }
    public var tissues = [MCMMTissue]()
}
public class MCMMTissue {
    public init(message: MCMMMessage) {
        self.neurons.append(MCMMNeuron(message: message))
    }
    public var neurons = [MCMMNeuron]()
}
public class MCMMNeuron {
    public init(message: MCMMMessage) {
        self.cleus = MCMMNucleus(message: message)
    }
    public let cleus: MCMMNucleus
}
public class MCMMNucleus {
    public init(message: MCMMMessage) {
        self.dna = MCMMDNA(message: message)
    }
    public var id = UUID()
    public var dna: MCMMDNA
}
public enum MCMMMessage: String {
    case nervous = "nervous"
}
public class MCMMDNA {
    public init(message: MCMMMessage) {
        self.rna = MCMMRNA(message: message)
    }
    public let rna: MCMMRNA
}
public class MCMMRNA {
    public var message: MCMMMessage
    public init(message: MCMMMessage) {
        self.message = message
    }
}
