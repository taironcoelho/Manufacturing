import UIKit

class DeckTableViewController: UITableViewController {

    // Var
    var sensors = [Sensor]()
    var currentOccurrence : Int = 0;
    var timer = Timer()
    
    // Outlet

    // UI
    func updateUI() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 5, target:self, selector: #selector(DeckTableViewController.timerRequest), userInfo: nil, repeats: true)
    }
    
    @objc func timerRequest() {
        requestCurrentSensorStatus()
    }
    
    func requestCurrentSensorStatus() {
        currentOccurrence += 1
        CheckController.shared.fetchSensorItems(occurrence: "\(currentOccurrence)")
        { (sensorItems) in
            if let sensorItems = sensorItems {
                self.sensors = sensorItems
                if !(self.isRessonance()){
                    print("ok")
                } else {
                    self.timer.invalidate()
                    print("Deu ruim")
                }
                self.updateUI()
            }
    
        }
        
        
    }
    
    func configure(cell: UITableViewCell, forItemAt indexPath:
        IndexPath) {
        let sensor = sensors[indexPath.row]
        cell.textLabel?.text = sensor.description
        cell.detailTextLabel?.text = String(format: "%.2f",
                                            sensor.vibration)
        
        cell.imageView?.image = sensor.insideLimitOscillation ? UIImage(named: "green") : UIImage(named: "red")
        
    }
    
    // View
    override func viewDidLoad() {
        super.viewDidLoad()
        //chama uma vez porque o timer vai ativar so depois de 10s
        requestCurrentSensorStatus()
        runTimer()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensors.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sensorReuse", for: indexPath)
        configure(cell: cell, forItemAt: indexPath)
        
        return cell
    }
    
    func isRessonance() -> Bool {

//        if sensors.count > 0 {
        
            let tolerance = 0.05
            let minValueVibration = sensors[0].vibration - tolerance
            let maxValueVibration = sensors[0].vibration + tolerance
            for currentSensor in sensors {
                if (minValueVibration > currentSensor.vibration || maxValueVibration < currentSensor.vibration) {
                    return false
                }
            }
            return true
//        }
//        return false
    }

}
