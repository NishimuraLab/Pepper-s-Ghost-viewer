//
//  OptionTVC.swift
//  GraduateProject
//
//  Created by Naoto Takahashi on 2016/11/25.
//  Copyright © 2016年 Naoto Takahashi. All rights reserved.
//

import Foundation

class OptionTVC : UITableViewController {
    
    @IBOutlet weak var thresholdSlider: UISlider!
    
    var type = UserDefaults.standard.integer(forKey: ALGORITHM)
    override func viewWillAppear(_ animated: Bool) {
        thresholdSlider.value = 0.5
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //閾値調整
        let rangeMin = AppUtil.THRESHOLD_MIN
        let rangeMax = AppUtil.THRESHOLD_MAX
        let threshold = ((rangeMax - rangeMin) * thresholdSlider.value) + rangeMin
        UserDefaults.standard.set(threshold, forKey: THRESHOLD)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type : AlgorithmType = indexPath.row == AlgorithmType.KNN.rawValue ? .KNN : .MOG2
        UserDefaults.standard.set(type.rawValue, forKey: ALGORITHM)
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
}
