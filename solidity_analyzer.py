#!/usr/bin/env python3
import os
import subprocess
import json
from pathlib import Path
from glob import glob

# Traverse all .sol files across all model folders
BASE_DIR = "./contracts-evaluation"
REPORT_DIR = "./analysis_reports"
REPORT_FILE = Path(REPORT_DIR) / "full_analysis_report.json"
Path(REPORT_DIR).mkdir(exist_ok=True)

def run_solc_check(sol_file):
    try:
        result = subprocess.run(
            ["solc", "--ast-compact-json", "--optimize", sol_file],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        success = result.returncode == 0
        return {
            "file": sol_file,
            "success": success,
            "solc_output": result.stdout if success else result.stderr
        }
    except Exception as e:
        return {"file": sol_file, "success": False, "error": str(e)}

def run_slither_check(sol_file):
    try:
        result = subprocess.run(
            ["slither", sol_file, "--json", "-"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        success = result.returncode == 0
        output = result.stdout if result.stdout else result.stderr
        return {
            "file": sol_file,
            "success": success,
            "slither_output": json.loads(output) if output else {}
        }
    except Exception as e:
        return {"file": sol_file, "success": False, "error": str(e)}

def analyze_all_contracts():
    combined_results = {}
    for sol_path in Path(BASE_DIR).rglob("*.sol"):
        parts = sol_path.parts
        if len(parts) < 3:
            continue
        model = parts[1]
        contract = sol_path.stem

        print(f"Analyzing {model}/{contract}...")

        combined_results[f"{model}/{contract}"] = {
            "solc": run_solc_check(str(sol_path)),
            "slither": run_slither_check(str(sol_path))
        }

    with open(REPORT_FILE, "w") as f:
        json.dump(combined_results, f, indent=2)
    print(f"✅ Full report written to {REPORT_FILE}")

if __name__ == "__main__":
    analyze_all_contracts()
