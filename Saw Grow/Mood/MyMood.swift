//
//  MyMood.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 2/4/2567 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import DGCharts
import Localize_Swift

enum moodMode {
    case bar
    case graph
}

class MyMood: UIViewController, UITextFieldDelegate, ChartViewDelegate {
    
    var barJSON:JSON?
    var graphJSON:JSON?
    
    var selectedBar:String = ""
    var selectedGraph:String = ""
    
    var yValues: [ChartDataEntry] = []
    var circleValues: [ChartDataEntry] = []
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var myScrollView: UIScrollView!

    @IBOutlet weak var barField: UITextField!
    @IBOutlet weak var barBtn: UIButton!
    
    @IBOutlet weak var moodIcon1: UIButton!
    @IBOutlet weak var moodIcon2: UIButton!
    @IBOutlet weak var moodIcon3: UIButton!
    @IBOutlet weak var moodIcon4: UIButton!
    @IBOutlet weak var moodIcon5: UIButton!
    @IBOutlet weak var moodIcon6: UIButton!
    
    @IBOutlet weak var moodTitle1: UILabel!
    @IBOutlet weak var moodTitle2: UILabel!
    @IBOutlet weak var moodTitle3: UILabel!
    @IBOutlet weak var moodTitle4: UILabel!
    @IBOutlet weak var moodTitle5: UILabel!
    @IBOutlet weak var moodTitle6: UILabel!
    
    @IBOutlet weak var moodBarStack: UIStackView!
    @IBOutlet weak var moodBar1: UIView!
    @IBOutlet weak var moodBar2: UIView!
    @IBOutlet weak var moodBar3: UIView!
    @IBOutlet weak var moodBar4: UIView!
    @IBOutlet weak var moodBar5: UIView!
    @IBOutlet weak var moodBar6: UIView!
    
    @IBOutlet weak var moodBarWidth1: NSLayoutConstraint!
    @IBOutlet weak var moodBarWidth2: NSLayoutConstraint!
    @IBOutlet weak var moodBarWidth3: NSLayoutConstraint!
    @IBOutlet weak var moodBarWidth4: NSLayoutConstraint!
    @IBOutlet weak var moodBarWidth5: NSLayoutConstraint!
    @IBOutlet weak var moodBarWidth6: NSLayoutConstraint!
    
    @IBOutlet weak var graphField: UITextField!
    @IBOutlet weak var graphBtn: UIButton!
    
    @IBOutlet weak var myChartView: LineChartView!
    
    var barPicker: UIPickerView! = UIPickerView()
    var graphPicker: UIPickerView! = UIPickerView()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if setColor {
            self.navigationController?.setStatusBarColor()
            //headerView.setGradientBackground()
            
            setColor = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MOOD JOURNAL")
        
        myScrollView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 50, right: 0)
        
//        pickerSetup(picker: barPicker)
//        barField.inputView = barPicker
//
//        pickerSetup(picker: graphPicker)
//        graphField.inputView = graphPicker
        
        self.hideKeyboardWhenTappedAround()
        
        moodTitle1.layer.masksToBounds = true
        moodTitle2.layer.masksToBounds = true
        moodTitle3.layer.masksToBounds = true
        moodTitle4.layer.masksToBounds = true
        moodTitle5.layer.masksToBounds = true
        moodTitle6.layer.masksToBounds = true
        
        moodBarWidth1.constant = moodBarStack.frame.size.width*0.30
        moodBarWidth2.constant = moodBarStack.frame.size.width*0.20
        moodBarWidth3.constant = moodBarStack.frame.size.width*0.15
        moodBarWidth4.constant = moodBarStack.frame.size.width*0.20
        moodBarWidth5.constant = moodBarStack.frame.size.width*0.10
        moodBarWidth6.constant = moodBarStack.frame.size.width*0.05
        
        //myChartView.backgroundColor = .buttonRed
        myChartView.delegate = self
        myChartView.noDataText = "No Data"
        myChartView.noDataTextColor = .textDarkGray
        myChartView.rightAxis.enabled = false
        myChartView.legend.enabled = false
        myChartView.animate(xAxisDuration: 1)
        myChartView.isUserInteractionEnabled = false
        
        let leftAxis = myChartView.leftAxis
        leftAxis.enabled = false
//        leftAxis.drawLabelsEnabled = true
//        leftAxis.labelPosition = .outsideChart
//        leftAxis.labelFont = .Kanit_Medium(ofSize: 12)
//        leftAxis.labelTextColor = .textDarkGray
//        leftAxis.axisLineColor = .buttonDisable
        //leftAxis.gridColor = .buttonDisable
        //leftAxis.drawZeroLineEnabled = true
        //leftAxis.zeroLineColor = .buttonDisable
        //leftAxis.axisMinimum = 0

        
        let xAxis = myChartView.xAxis
        xAxis.enabled = true
        xAxis.drawLabelsEnabled = true
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .Kanit_Regular(ofSize: 10)
        xAxis.labelTextColor = .textDarkGray
        xAxis.setLabelCount(7, force: false)
        xAxis.axisLineColor = .clear
        xAxis.gridColor = .buttonDisable
        xAxis.drawAxisLineEnabled = false
        
        //String Axis
//        axisFormatDelegate = self
//        dayOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
//        caloriesBurn = [123.0, 751.0, 625.0, 234.0, 999.0, 888.0, 789.0]
//        setChart(dataEntryX: dayOfWeek, dataEntryY: caloriesBurn)
        
        let xAxisStr = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]
        
        //let xAxisStr = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
        
//        myChartView.xAxis.valueFormatter = DefaultAxisValueFormatter(block: {(index, _) in
//            return xAxisStr[Int(index)]
//        })
        
        let customFormater = CustomFormatter()
        customFormater.labels = xAxisStr
        myChartView.xAxis.valueFormatter = customFormater
        
        //myChartView.xAxis.setLabelCount(xAxisStr.count+1, force: true)
        myChartView.xAxis.setLabelCount(7, force: false)
        
        loadGraph()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        if firstTime {
//            monthYearField.becomeFirstResponder()
//            firstTime = false
//        }
    }
    
    func loadMood(monthYear:Date) {
        
    }
    
    func loadGraph() {
        //let graphArray = myJSON!["data_graph"]
        yValues = [
            ChartDataEntry(x: 1.0, y: 3),
            ChartDataEntry(x: 2.0, y: 4),
            ChartDataEntry(x: 3.0, y: 6),
            ChartDataEntry(x: 4.0, y: 2),
            ChartDataEntry(x: 5.0, y: 1),
            ChartDataEntry(x: 6.0, y: 4),
            ChartDataEntry(x: 7.0, y: 5),
            ChartDataEntry(x: 8.0, y: 3),
            ChartDataEntry(x: 9.0, y: 6),
            ChartDataEntry(x: 10.0, y: 4),
            ChartDataEntry(x: 11.0, y: 4),
            ChartDataEntry(x: 12.0, y: 2),
        ]
        
        yValues = [
            ChartDataEntry(x: 0.0, y: 3),
            ChartDataEntry(x: 1.0, y: 3),
            ChartDataEntry(x: 2.0, y: 4),
            ChartDataEntry(x: 3.0, y: 6),
            ChartDataEntry(x: 4.0, y: 2),
//            ChartDataEntry(x: 5.0, y: 1),
//            ChartDataEntry(x: 6.0, y: 4),
            ChartDataEntry(x: 7.0, y: 5),
            ChartDataEntry(x: 8.0, y: 3),
            ChartDataEntry(x: 9.0, y: 6),
            ChartDataEntry(x: 10.0, y: 4),
            ChartDataEntry(x: 11.0, y: 4),
//            ChartDataEntry(x: 12.0, y: 2),
//            ChartDataEntry(x: 13.0, y: 3),
            ChartDataEntry(x: 14.0, y: 4),
            ChartDataEntry(x: 15.0, y: 6),
            ChartDataEntry(x: 16.0, y: 2),
            ChartDataEntry(x: 17.0, y: 1),
            ChartDataEntry(x: 18.0, y: 4),
//            ChartDataEntry(x: 19.0, y: 5),
//            ChartDataEntry(x: 20.0, y: 3),
            ChartDataEntry(x: 21.0, y: 6),
            ChartDataEntry(x: 22.0, y: 4),
            ChartDataEntry(x: 23.0, y: 4),
            ChartDataEntry(x: 24.0, y: 2),
            ChartDataEntry(x: 25.0, y: 3),
//            ChartDataEntry(x: 26.0, y: 4),
//            ChartDataEntry(x: 27.0, y: 6),
            ChartDataEntry(x: 28.0, y: 2),
            ChartDataEntry(x: 29.0, y: 1),
            ChartDataEntry(x: 30.0, y: 4),
//            ChartDataEntry(x: 31.0, y: 3),
        ]
        
        setData()
    }
    
    func setData() {
        let line1 = LineChartDataSet(entries: yValues)
        //line1.mode = .cubicBezier
        line1.lineWidth = 2
        line1.colors = [NSUIColor.themeColor]
        line1.drawValuesEnabled = false
        //line1.valueTextColor = .white
        //line1.valueFont = .Roboto_Regular(ofSize: 12)
        line1.drawCirclesEnabled = true
        line1.circleRadius = 4
        line1.circleColors = [NSUIColor.themeColor]
        line1.drawCircleHoleEnabled = false
        
        line1.drawHorizontalHighlightIndicatorEnabled = false
        line1.drawVerticalHighlightIndicatorEnabled = false
        
        //var data = LineChartData(dataSet: line1)
        let data = LineChartData()
        data.append(line1)
        //myChartView.data = data
        
        for i in 0 ... 5 {
            let dotSize = 15
            let dotView = UIView(frame: CGRect(x: 0, y: 0, width: dotSize, height: dotSize))
            dotView.layer.cornerRadius = dotView.frame.height/2
            
            switch i {
            case 0:
                dotView.backgroundColor = moodBar6.backgroundColor
                
            case 1:
                dotView.backgroundColor = moodBar5.backgroundColor
                
            case 2:
                dotView.backgroundColor = moodBar4.backgroundColor
                
            case 3:
                dotView.backgroundColor = moodBar3.backgroundColor
                
            case 4:
                dotView.backgroundColor = moodBar2.backgroundColor
                
            case 5:
                dotView.backgroundColor = moodBar1.backgroundColor
                
            default:
                break
            }
            
            let dot1 = LineChartDataSet(entries: [ChartDataEntry(x: -2.0, y: Double(i+1), icon: dotView.asImage())])
            dot1.lineWidth = 0
            dot1.drawValuesEnabled = false
            dot1.drawCirclesEnabled = false
            dot1.drawCircleHoleEnabled = false
            data.append(dot1)
        }
        //var data = LineChartData(dataSets: [line1,dot1])
        
        myChartView.data = data
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == barField && barField.text == "" {
            selectPicker(barPicker, didSelectRow: 0)
        }
        else if textField == graphField && graphField.text == "" {
            selectPicker(graphPicker, didSelectRow: 0)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //loadMood(monthYear: Date())
    }
    
    func pickerSetup(picker:UIPickerView) {
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .white
        picker.setValue(UIColor.themeColor, forKeyPath: "textColor")
    }
    
    @IBAction func dropdownClick(_ sender: UIButton) {
        switch sender.tag {
        case 1://Bar
            barField.becomeFirstResponder()
            
        case 2://Graph
            graphField.becomeFirstResponder()
            
        default:
            break
        }
    }
    
    @IBAction func showReportClick(_ sender: UIButton) {
        let vc = UIStoryboard.moodStoryBoard.instantiateViewController(withIdentifier: "MoodReport") as! MoodReport
        self.navigationController!.pushViewController(vc, animated: true)
    }
}

// MARK: - Picker Datasource
extension MyMood: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == barPicker && barJSON != nil {
            return barJSON!.count
        }
        else if pickerView == graphPicker && graphJSON != nil {
            return graphJSON!.count
        }
        else{
            return 0
        }
    }
    
//    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
//        return 40
//    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = .Kanit_Regular(ofSize: 22)
            pickerLabel?.textAlignment = .center
        }
        
        if pickerView == barPicker && barJSON!.count > 0{
            pickerLabel?.text = barJSON![row]["xxx"].stringValue
        }
        else if pickerView == graphPicker && graphJSON!.count > 0{
            pickerLabel?.text = graphJSON![row]["xxx"].stringValue
        }
        else{
            pickerLabel?.text = ""
        }
        
        pickerLabel?.textColor = .textDarkGray
        
        return pickerLabel!
    }
}

// MARK: - Picker Delegate
extension MyMood: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("Select \(row)")
        selectPicker(pickerView, didSelectRow: row)
    }
    
    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
        if pickerView == barPicker {
            
            let cellArray = barJSON![row]
            selectedBar = cellArray["xxx"].stringValue
            
            //loadMood(monthYear: Date())
        }
        else if pickerView == graphPicker {
            
            let cellArray = graphJSON![row]
            selectedGraph = cellArray["xxx"].stringValue
            
            //loadMood(monthYear: Date())
        }
    }
}

extension MyMood {
    private class CustomFormatter: IndexAxisValueFormatter {
        
        var labels: [String] = []

        override func stringForValue(_ value: Double, axis: AxisBase?) -> String {

            let count = self.labels.count

            guard let axis = axis, count > 0 else {
                return ""
            }

            //print("Value = \(value)")
            
//            let factor = axis.axisMaximum / Double(count)
//            let index = Int((value / factor).rounded())
            
            let index = Int(value)
            //print("Index = \(index)")
            
//            if index == 0  {
//                return ""
//            }
//            else if index > 0  {
//                return self.labels[index-1]
//            }
//            
            if index >= 0 {//&& index < count {
                return self.labels[index]
            }

            return ""
        }
    }
}
