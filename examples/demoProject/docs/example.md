# Example File

This is an example documentation file.

It exists to demonstrate how `.uPyDeployignore` works.

If your deploy script is working correctly, this file will **NOT** be uploaded to the microcontroller.

---

## Why?

Because this file is:

- Not required at runtime
- Meant only for developers
- Excluded via `.uPyDeployignore`

---

## What To Look For

When you run the deploy script:

- `main.py` → ✅ Deployed
- This file (`docs/example.md`) → ❌ NOT deployed properly

---

## Takeaway

Only include files in your deployment that are required for your application to run.

Use `.uPyDeployignore` to filter out everything else.