# uPyDeploy

A simple, clean deployment tool for extensive MicroPython projects using mpremote.

---

## Features

* Detect available serial devices
* Optional manual port selection
* Full project deployment (not just single files)
* Safe wipe (keeps `boot.py` by default)
* Optional full wipe (`--full-wipe`)
* Automatic exclusion of unwanted files
* Post-deploy verification using `rsync`
* Automatic device reset

---

## Requirements

* `bash` (Linux/macOS)
* `mpremote`
* `rsync`

---

## Install Dependencies

### Ubuntu / Debian

Install `pipx` and `rsync`:

```bash
sudo apt update
sudo apt install -y pipx rsync
```

Ensure `pipx` is in your PATH:

```bash
pipx ensurepath
```

Then restart your terminal, or run:

```bash
source ~/.bashrc
```

Install `mpremote`:

```bash
pipx install mpremote
```

---

### Other Linux Distributions (Not Tested)

Install `pipx`:

```bash
python3 -m pip install --user pipx
python3 -m pipx ensurepath
```

Restart your terminal, then install `mpremote`:

```bash
pipx install mpremote
```

Install `rsync` using your distro’s package manager.

---

## Verify Installation

```bash
mpremote --help
rsync --version
```

If both commands run successfully, you are ready to use `uPyDeploy`.

---

## Installation

Clone the repo:

```bash
git clone https://github.com/RY3BRE4D/uPyDeploy.git
cd mpyDeploy
chmod +x deploy.sh
```

---

## Usage

Deploy a project (myProject as an example, or see Example Projects):

```bash
./deploy.sh ./myProject
```

```bash
./deploy.sh ./myProject
```

Full wipe (removes `boot.py`):

```bash
./deploy.sh ./myProject --full-wipe
```

Specify port manually:

```bash
./deploy.sh ./myProject --port /dev/ttyUSB0
```

Show help:

```bash
./deploy.sh --help
```

---

## Project Structure

The directory you pass becomes the root of the device.

Example:

```
myProject/
  main.py
  lib/
```

Will deploy as:

```
/main.py
/lib/
```

---

## Example Projects

### Demo Project Example

Deploy a multi-file project with nested directories:

```bash
./deploy.sh ./examples/demoProject
```

This example demonstrates deployment of:

* `main.py`
* `apps/`
* `lib/`
* `config/`

See `examples/demoProject/README.md` for details.

---

## Why This Exists

MicroPython deployment is often manual and error-prone.
This tool provides a repeatable, verifiable deployment workflow.

---

## Potentially Coming Soon

* `.uPyDeployignore` support
* Incremental sync mode
* Windows support
* CLI install (`upy-deploy`)
* Python rewrite for cross-platform support

---

## License

MIT
