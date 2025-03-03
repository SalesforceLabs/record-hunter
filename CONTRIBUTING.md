# Contributing Guidelines

Thank you for your interest in contributing to this project! Here are some guidelines to help you get started.

## Disclaimer

- Changes made to this repository do not guarantee immediate publication on AppExchange.

## Getting Started

### 1. Fork the repository

- Start by forking this repository to your GitHub account.

### 2. Clone your forked repository to your local machine

```
$ git clone <YOUR_FORKED_REPOSITORY_URL>
$ cd record-hunter/
```

### 3. Create a new branch for your feature or bug fix

```
$ git fetch origin main
$ git switch -c <YOUR_BRANCH_NAME> origin/main
$ git push -u origin HEAD
```

### 4. Create scratch org for development.eploy the app to your scratch org

- Make sure you have enabled Dev Hub feature on your packaging org.

```
$ sf org login web -a devhub-record-hunter -d

# Run `sf delete scratch org -o scratch-record-hunter` if already exists
$ sf create scratch org -v devhub-record-hunter -a scratch-record-hunter -d -f config/project-scratch-def.json  -w 30 -y 2

# Run `sf generate org password` if you need a password for the user

# Enable debug mode for the user
sf data update record --sobject User --where "Name='User User'" --values "UserPreferencesUserDebugModePref=true"
```

### 5. Deploy the project to your development org

```
$ sf set config org-metadata-rest-deploy=true
$ sf start deploy project -o scratch-record-hunter
$ sf open org -o scratch-record-hunter
```

- Make changes and commit them to your branch
- Push your changes to your forked repository
- Submit a pull request

## Code of Conduct

Please note that this project adheres to the Contributor Covenant [code of conduct](https://github.com/SalesforceLabs/record-hunter/blob/main/CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report any unacceptable behavior to the project maintainers.

## Issues and Pull Requests

- Before starting to work on an issue, please check if it has already been reported
- If you find an issue, please report it by creating a new issue with a clear and descriptive title and description
- If you would like to work on an issue, please comment on it to let others know
- Please create a new branch for each issue or pull request
- Before submitting a pull request, please make sure that your changes have been tested and do not break existing functionality
- Please use clear and descriptive commit messages and reference any relevant issues or pull requests

## Style Guidelines

- Please follow the style guidelines of the project
- Please use descriptive variable and function names
- Please comment your code when necessary

## License

By contributing to this project, you agree that your contributions will be licensed under the project's LICENSE file.
