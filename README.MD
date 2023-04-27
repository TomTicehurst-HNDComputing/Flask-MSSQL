# A Python Flask application for HND Computing Year 1 and Microsoft SQL Server

## **Disclaimer: This was created without the use of anaconda or any other virtual environment manager, so instructions on the running of this application will follow that of base python with no additives.**

## Running the application

#### Create a virtual environment in the current directory (This can be skipped if you wish to have dependencies installed globally)

- Command: `python -m venv pyenv`

<br>

#### Ensure that you enable the python virtual environment. This can be done from command prompt, bash, or powershell:

| Terminal name  | Command                         |
| -------------- | ------------------------------- |
| Command prompt | `pyenv\scripts\activate.bat`    |
| Powershell     | `pyenv/scripts/Activate.ps1`    |
| Bash           | `source pyenv/scripts/activate` |
| sh             | `. pyenv/scripts/activate`      |

#### Once activated you can install the required dependencies from the `requirements.txt` file

- Command: `pip install -r requirements.txt`

<br>

#### Rename the .env.example file and fill in the blanks

| Environment variable | Description                                        |
| -------------------- | -------------------------------------------------- |
| MSSQL_HOST           | The host of the database, most likely `localhost`  |
| MSSQL_USERNAME       | The username of the user you wish to log in with   |
| MSSQL_PASSWORD       | The password for your user                         |
| MSSQL_DATABASE       | The database you wish to connect to with your user |

<br>

#### Run the application using one of the scripts

| Terminal name  | Command               |
| -------------- | --------------------- |
| Command prompt | `scripts\run.bat`     |
| Powershell     | `sh ./scripts/run.sh` |
| Bash / sh      | `./scripts/run.sh`    |
