import hashlib
import os
from pathlib import Path
import subprocess
import sys

from pywinauto import Application, timings

project = Path("roundtrip").resolve()
perl = r"C:\martha-perl\perl\bin\perl.exe"
source = project / "app.pl"

def click(caption):
    app = Application(backend="win32").start(f'"{perl}" "{source}"')
    frame = app.window(title="Martha round trip")
    try:
        frame.wait("visible", timeout=30)
        status = frame.child_window(title="Ready", class_name="Static").wrapper_object()
        button = frame.child_window(title=caption, class_name="Button").wrapper_object()
        button.click()
        timings.wait_until(10, 0.2, status.window_text, value="Button clicked")
        print(f"{perl} | {caption} | Ready -> {status.window_text()}", flush=True)
    finally:
        if frame.exists():
            frame.close()
        app.wait_for_process_exit(timeout=10)

original = hashlib.sha256(source.read_bytes()).hexdigest()
click("Click me")
subprocess.run([sys.executable, "qa/designer.py", "revise"], check=True, timeout=90)
assert hashlib.sha256(source.read_bytes()).hexdigest() == original
click("Try it again")
print("Handwritten app.pl SHA-256:", original)
