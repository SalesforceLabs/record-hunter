# Record Hunter

[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

Record Hunter is a package that includes a Lightning component enabling easy search of any data stored on Salesforce.
This package is publicly available from Salesforce Labs on AppExchange, allowing anyone to install and use it for free in their self-managed Salesforce organization.
Moreover, this package is released as open-source software, providing the flexibility to make modifications to the source code as needed for your use.

## Features

- **Build Custom Search Screens:** Combine components using App Builder to freely construct search screens and make them accessible to users.
- **Flexible Configuration:** Specify search criteria and logic flexibly through the property Editor.
- **Automate Subsequent Tasks:** Launch Salesforce flows from search results to automate subsequent business processes.

## Installation

You can install the Record Hunter to your org by follwing ways;
- install Managed Package from [AppExchnage Page](https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000FR4jTUAT), or
- install manually with CLI

```sh
$ git clone https://github.com/SalesforceLabs/record-hunter.git
$ cd record-hunter
$ sf auth login web -a recordhunter-org -s
$ sf start deploy project
$ sf open org
```

## Contributing

Contributions are always welcome! Please read the [contribution guidelines](https://github.com/SalesforceLabs/record-hunter/blob/main/CONTRIBUTING.md) first.

## License

Distributed under the BSD3 Clause License. See [LICENSE](https://github.com/SalesforceLabs/record-hunter/blob/main/LICENSE) for more information.

## Contact

Please raise an issue on this project and DO NOT CONTACT SALESFORCE SUPPORT CHANNELS.

Project Link: https://github.com/SalesforceLabs/record-hunter
