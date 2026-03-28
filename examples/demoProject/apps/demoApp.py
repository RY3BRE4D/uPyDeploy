import json
from lib.displayMessage import showMessage

def run():
    with open("config/settings.json", "r") as file:
        settings = json.load(file)

    projectName = settings.get("projectName", "Unknown Project")
    message = settings.get("message", "Hello From uPyDeploy")

    print("Starting Demo App...")
    print("------------------------------------------------------")
    print(f"Project Name: {projectName}\n")
    showMessage(message)
    print("------------------------------------------------------")

