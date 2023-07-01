# Radius

Radius is an iOS app developed in Swift that allows users to select one option from each facility. The app fetches data from an API to display a list of facilities and their corresponding options, including the name and icon for each option.

## Features

- Displays a list of facilities along with their available options.
- Users can select one option from each facility.
- Provides a user-friendly interface for easy selection.

## Installation

1. Clone the repository to your local machine.
2. Open the project in Xcode.
3. Build and run the app on a simulator or a physical device.

## Requirements

- iOS 13.0 or later.

## Development

The app is developed using Swift and does not require any external libraries. The main logic resides in the `tableView(_:didSelectRowAt:)` method, which handles the selection of options and manages the selected options array.

## API

The app fetches data from an API to retrieve the list of facilities and options. The API provides the facility names, option names, and option icons for each facility. The app makes use of this data to populate the UI and allow users to select options.

## Contribution

Contributions are welcome! If you find any issues or have suggestions for improvement, please open an issue or submit a pull request.

