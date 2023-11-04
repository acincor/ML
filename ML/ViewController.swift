//
//  ViewController.swift
//  ML
//
//  Created by mhc team on 2023/10/27.
//

import UIKit
import MineCaseMachineML
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    let resultLabel = UILabel()
    let textView = UITextView()
    let originalImageView = UIImageView(image: UIImage(named: "test-original"))
    let testImageView = UIImageView(image: UIImage(named: "test"))
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        textView.text = "Demo"
        textView.textColor = .black
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.centerX.equalTo(self.view.snp.centerX)
            make.top.equalTo(self.view.snp.top).offset(50)
        }
        view.addSubview(originalImageView)
        originalImageView.snp.makeConstraints { make in
            make.centerY.equalTo(self.view.snp.centerY).offset(-70)
            make.centerX.equalTo(self.view.snp.centerX)
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
        let originalLabel = UILabel()
        originalLabel.text = "原图"
        originalLabel.textColor = .link
        originalImageView.addSubview(originalLabel)
        originalLabel.snp.makeConstraints { make in
            make.center.equalTo(originalImageView.snp.center)
        }
        view.addSubview(testImageView)
        let testLabel = UILabel()
        testLabel.text = "测试图片"
        testLabel.textColor = .link
        testImageView.addSubview(testLabel)
        testLabel.snp.makeConstraints { make in
            make.center.equalTo(testImageView.snp.center)
        }
        testImageView.snp.makeConstraints { make in
            make.top.equalTo(originalImageView.snp.bottom)
            make.centerX.equalTo(self.view.snp.centerX)
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
        let model = MCMMModel(message: .nervous)
            model.layer!.same(UIImage(named: "test-original")!, UIImage(named: "test")!)
            let result = model.layer!.build()
            resultLabel.text = """
        结果:相似度\(result*100)%
        """
            resultLabel.lineBreakMode = .byWordWrapping
            view.addSubview(resultLabel)
            resultLabel.snp.makeConstraints { make in
                make.bottom.equalTo(testImageView.snp.bottom).offset(30)
                make.centerX.equalTo(self.view.snp.centerX)
            }
        // Do any additional setup after loading the view.
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info)
    }

}

