import UIKit

class ViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var facilities: [Facility] = []
    var exclusions: [[Exclusion]] = []
    var selectedOptions: [SelectedOption] = [SelectedOption]()
    var facilitiesVM : FacilitiesViewModel?
    var responseData: APIResponse? // Make APIResponse mutable
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Fetch data from the API
        fetchData()
    }
    
    //MARK: SURAJ fetchData METHOD TO FETCH RESPONSE DATA
    func fetchData(){
        if isConnectedToNetwork(){
            self.activityIndicatorBegin()
            let url = ApiUrls.baseApi + ApiUrls.fetchFacilities
            facilitiesVM = FacilitiesViewModel()
            facilitiesVM?.getResponseData(url: url) { response in
                self.activityIndicatorEnd()
                switch response{
                case .success(let data):
                    print("success")
                    guard let data = data else {
                        return
                    }
                    self.facilities = data.facilities
                    self.exclusions = data.exclusions
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                case .failure(let err):
                    print("failure")
                    print("ERROR \(err)")
                    self.alert(title: "Alert", message: err.message ?? Constants.SOMETHING_WENT_WRONG)
                }
            }
        }else{
            self.alert(title: "Alert", message: Constants.INTERNET_CONNECTION_ALERT)
        }
    }
    
    //MARK: SURAJ TO CLEAR ALL FILTERS
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
        // Get the selected facility ID, option ID, and option name
        let selectedFacilityId = facilities[indexPath.section].facility_id
        let selectedOptionId = facilities[indexPath.section].options[indexPath.row].id
        let selectedOptionName = facilities[indexPath.section].options[indexPath.row].name
        
        // Create a SelectedOption object with the selected data
        let userSelectedOption: SelectedOption = SelectedOption(facility_id: selectedFacilityId, option_id: selectedOptionId, belongToSection: indexPath.section, optionName: selectedOptionName)
        
        // Get the facility and option based on the selected indexPath
        let facility = facilities[indexPath.section]
        let option = facility.options[indexPath.row]
        
        // Variables for tracking selection state and index
        var isSelected = false
        var updateSelection = false
        var selectedIndex = 0
        
        // Loop through the selectedOptions array to check if the option is already selected or if there is a selection update
        for (i, userOption) in selectedOptions.enumerated() {
            if (userOption.facility_id == facility.facility_id && userOption.option_id == option.id) {
                isSelected = true
                selectedIndex = i
                break
            }
            
            if (indexPath.section == userOption.belongToSection) {
                selectedIndex = i
                updateSelection = true
                break
            }
        }
        
        // Handle selection based on the selected state
        if (isSelected) {
            // If the option is already selected, remove it from the selectedOptions array
            selectedOptions.remove(at: selectedIndex)
        } else if (updateSelection) {
            // If there is an update to the selection, check if it is valid and update the selectedOptions array
            let updateSelectionFor = SelectedOption(facility_id: facility.facility_id, option_id: option.id, belongToSection: 0)
            let canUpdate = isSelectionValid(selectionFor: updateSelectionFor)
            if (canUpdate) {
                selectedOptions[selectedIndex].facility_id = facility.facility_id
                selectedOptions[selectedIndex].option_id = option.id
            }
        } else {
            // If it's a new selection, check if it is valid and add it to the selectedOptions array
            if (selectedOptions.isEmpty) {
                selectedOptions.append(userSelectedOption)
            } else {
                let isValid = isSelectionValid(selectionFor: userSelectedOption)
                if (isValid) {
                    selectedOptions.append(userSelectedOption)
                } else {
                    print("Invalid selection")
                }
            }
        }
        
        // Reload the tableView to reflect the updated selection
        tableView.reloadData()
    }
    
}
extension ViewController{
    //MARK: SURAJ LOGIC TO HANDLE SELECTION, IF EXCLUSION CONDITION IS MATCHED, ALERT IS SHOWN TO THE USER.
    func isSelectionValid(selectionFor: SelectedOption) -> Bool {
        // Append the selectionFor option to the selectedOptions array for validation
        selectedOptions.append(selectionFor)
        
        // Variable to track the validity of the selection
        var isSelectionValid: Bool = true
        
        // Determine the length of the exclusions array for checking
        let optionCheckLen = exclusions[0].count
        
        // Outer loop through the exclusions array
    outerloop: for (_, i) in exclusions.enumerated() {
        // Create a boolean array to track the exclusion checks for each selected option
        var checkExclusion: [Bool] = [Bool]()
        
        // Initialize the checkExclusion array with false values for each selected option
        for _ in 0..<selectedOptions.count {
            checkExclusion.append(false)
        }
        
        // Check each exclusionOption against the selectedOptions
        for exclusionOption in i {
            for (userIndex, userOption) in selectedOptions.enumerated() {
                if (exclusionOption.facility_id == userOption.facility_id && exclusionOption.options_id == userOption.option_id) {
                    // If an exclusionOption matches a selected option, mark it as true in checkExclusion array
                    checkExclusion[userIndex] = true
                }
            }
        }
        
        // Count the number of true values in the checkExclusion array
        let trueCount = checkExclusion.filter { $0 == true }.count
        
        // If the trueCount matches the optionCheckLen, it means an exclusion combination is violated
        if (trueCount == optionCheckLen) {
            isSelectionValid = false
            
            // Display an alert indicating the exclusion violation
            let message = "You cannot select this combination."
            self.alert(title: "Exclusion Violation", message: message)
            
            // Break out of the outer loop
            break outerloop
        }
    }
        
        // Remove the last added selectionFor option from the selectedOptions array
        selectedOptions.removeLast()
        
        // Return the validity of the selection
        return isSelectionValid
    }
    
}
