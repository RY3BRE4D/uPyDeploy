# Project Demo

This example demonstrates deployment of a multi-file MicroPython project using `uPyDeploy`.

## Structure

- `main.py` → entry point
- `apps/demoApp.py` → application logic
- `lib/displayMessage.py` → helper module
- `config/settings.json` → deployed config file

## Usage

From the root of the `uPyDeploy` repo:

```bash
./deploy.sh ./examples/demoProject
