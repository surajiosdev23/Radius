import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var facilities: [Facility] = []
    var exclusions: [[Exclusion]] = []
    var selectedOptions: [SelectedOption] = [SelectedOption]()
    
    // Example usage
    var responseData: APIResponse? // Make APIResponse mutable
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Fetch data from the API
        fetchData{
        }
    }
    
    func fetchData(completionHandler: () -> Void) {
        guard let url = URL(string: "https://my-json-server.typicode.com/iranjith4/ad-assignment/db") else {
            print("Invalid API URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(APIResponse.self, from: data)
                self?.facilities = response.facilities
                self?.exclusions = response.exclusions
                
                DispatchQueue.main.async {
                    // Configure table view
                    self?.tableView.reloadData()
                }
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    @IBAction func clearSelection(_ sender: UIBarButtonItem) {
        selectedOptions.removeAll()
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return facilities.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return facilities[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        let facility = facilities[indexPath.section]
        let option = facility.options[indexPath.row]
        
        cell.textLabel?.text = option.name
        cell.imageView?.image = UIImage(named: option.icon)
        var isSelected = false
        
        for i in selectedOptions{
            if (i.facility_id == facility.facility_id && i.option_id == option.id ){
                isSelected = true
                break
            }
        }
        cell.accessoryType = isSelected ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let facility = facilities[section]
        return facility.name
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(facilities[indexPath.section].facility_id)
        print(facilities[indexPath.section].options[indexPath.row].id)
        let selectedFacilityId = facilities[indexPath.section].facility_id
        let selectedOptionId = facilities[indexPath.section].options[indexPath.row].id
        let selectedOptionName = facilities[indexPath.section].options[indexPath.row].name
        
        let userSelectedOption:SelectedOption = SelectedOption(facility_id: selectedFacilityId, option_id: selectedOptionId,belongToSection: indexPath.section,optionName: selectedOptionName)
        let facility = facilities[indexPath.section]
        let option = facility.options[indexPath.row]
        var isSelected = false
        var updateSelection = false
        var selectedIndex = 0
        for (i,useroption) in selectedOptions.enumerated(){
            if (useroption.facility_id == facility.facility_id && useroption.option_id == option.id){
                isSelected = true
                selectedIndex = i
                break
            }
            
            if (indexPath.section == useroption.belongToSection){
                selectedIndex = i
                updateSelection = true
                break
            }
        }
        
        if(isSelected){
            selectedOptions.remove(at: selectedIndex)
        }
        else if (updateSelection){
            let updateSelectionfor =  SelectedOption(facility_id: facility.facility_id, option_id: option.id, belongToSection: 0)
            let canUpdate = isSelectionValid(selectionFor: updateSelectionfor)
            if(canUpdate){
                selectedOptions[selectedIndex].facility_id = facility.facility_id
                selectedOptions[selectedIndex].option_id = option.id
            }
        }
        else{
            if(selectedOptions.isEmpty){
                selectedOptions.append(userSelectedOption)
            }
            else{
                let isValid = isSelectionValid(selectionFor: userSelectedOption)
                if(isValid){
                    selectedOptions.append(userSelectedOption)
                }
                else{
                    print("invalid selection")
                }
            }
        }
        tableView.reloadData()
    }
    
    func isSelectionValid(selectionFor:SelectedOption) -> Bool{
        selectedOptions.append(selectionFor)
        print(selectionFor)
        var isSelectionValid:Bool = true
        let optionCheckLen = exclusions[0].count
        
        outerloop : for (_,i) in exclusions.enumerated(){
            var checkExclusion :[Bool] = [Bool]()
            
            for _ in  0..<selectedOptions.count{
                checkExclusion.append(false)
            }
            for exclusionOption in i{
                for (userIndex,userOption) in selectedOptions.enumerated(){
                    if (exclusionOption.facility_id == userOption.facility_id && exclusionOption.options_id == userOption.option_id){
                        checkExclusion[userIndex] = true
                    }
                }
            }
            let trueCount = checkExclusion.filter { $0 == true }.count
            if(trueCount == optionCheckLen){
                isSelectionValid = false
                print("exclusion found ")
                let message = "You cannot select this combination."
                self.showAlert(message: message)
                break outerloop
            }
        }
        selectedOptions.removeLast()
        return isSelectionValid
    }
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Exclusion Violation", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
