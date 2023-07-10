//
//  QRcodeGenerator.swift
//  w2e_smart_tv
//
//  Created by Asad Iqbal on 08/12/2022.
//

import Foundation
import UIKit
import CoreImage.CIFilterBuiltins
@available(tvOS 13.0, *)
class QRcodeGenerator {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    func generateQRCode(from string: String) -> UIImage? {
        filter.message = Data(string.utf8)
        let transform = CGAffineTransform(scaleX: 3, y: 3)

                if let output = filter.outputImage?.transformed(by: transform) {
                    return UIImage(ciImage: output)
                }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
}
