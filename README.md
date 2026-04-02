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
* Project-level `.uPyDeployignore` support
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
cd uPyDeploy
chmod +x deploy.sh
```

---

## Usage

Deploy a project (myProject for demonstration purposes, or see Example Project in examples):

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

```text
myProject/
  main.py
  lib/
```

Will deploy as:

```text
/main.py
/lib/
```

---

## Deployment Filtering (`.uPyDeployignore`)

By default, `uPyDeploy` excludes common development files such as:

```text
.git/
__pycache__/
*.pyc
venv/
```

You can define additional exclusions per project using a `.uPyDeployignore` file in your project root.

### Example

```text
myProject/
  main.py
  docs/
  README.md
  .uPyDeployignore
```

### `.uPyDeployignore`

```text
README.md
docs/
*.md
```

### Result

| File        | Deployed |
|-------------|----------|
| `main.py`   | ✅ Yes   |
| `docs/`     | ❌ No    |
| `README.md` | ❌ No    |

---

## How It Works

1. Project is copied into a temporary staging directory
2. Default exclusions are applied
3. `.uPyDeployignore` is applied (if present)
4. Device is wiped (optionally keeping `boot.py`)
5. Staged files are uploaded
6. Device is inspected and verified using `rsync`
7. Device is reset

---

## Example Projects

### Demo Project

```bash
./deploy.sh ./examples/demoProject
```

This example demonstrates:

* Multi-file deployment
* Nested directories
* `.uPyDeployignore` usage

See `examples/demoProject/README.md` for details.

---

## Why This Exists

MicroPython deployment is often manual and error-prone.  
This tool provides a repeatable, reliable deployment workflow with proper file filtering.

---

## Potentially Coming Soon

* Incremental sync mode
* CLI install (`upy-deploy`)
* Python rewrite for cross-platform support (Windows?)

---

## License

MIT
