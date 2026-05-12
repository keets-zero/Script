DISCLAIMER: USE AT YOUR OWN RISK

This script is provided "as is" without warranty of any kind.

Actions Performed:

Process Termination: This script will immediately close Google Chrome without saving work.

Registry Modification: This script modifies HKLM registry keys to enforce Google Chrome policies. Incorrect registry changes can cause system instability.

File Deletion: This script permanently deletes data in the Chrome User Data directory.

Liability: The author of this script is not responsible for any data loss, browser corruption, or system issues that may occur. Always back up your browser bookmarks and data before running automated cleanup tools.

# NanoNuke: Gemini Nano Removal & Lockdown Tool

## Overview
NanoNuke is a security hardening script designed to remove the 4GB on-device AI models (Gemini Nano) from Google Chrome and prevent them from being re-downloaded. It aligns with **OWASP A02:2025 - Security Misconfiguration** principles by enforcing an "Offline-first" policy at the OS level.

## What it Does
1. **The Kill Switch**: Instantly terminates all Google Chrome processes. This unlocks the model folders so they can be deleted without "Access Denied" errors.
2. **The Policy Shield**: Modifies the Windows Registry (`HKLM:\SOFTWARE\Policies\Google\Chrome`).
   - Sets `OptimizationGuideRemoteFetchingEnabled` to `0` (Disabled).
   - Sets `GenAiDefaultSettings` to `2` (Disabled).
   - This tells Chrome that an administrator has forbidden it from fetching AI models from Google's servers.
3. **The Folder Purge**: Targets and deletes the following directories identified in the User Data profile:
   - `optimization_guide_model_store` (The main 4GB model storage)
   - `OnDeviceHeadSuggestModel` (AI search suggestions)
   - `OptimizationHints` (AI-driven speed optimizations)
4. **The Placeholder Lock**: Creates empty, **Read-Only** files with the exact same names as the deleted folders. Because Windows prevents a folder and a file from sharing a name in the same location, Chrome cannot recreate the folders.
5. **Audit Logging**: Generates a `NanoNuke_Log.txt` in the script's directory, providing a timestamped record of every action taken for verification.

## How to Use
1. Right-click `NanoNuke.ps1`.
2. Select **Run with PowerShell** (ensure you have Administrator privileges).
3. Review the `NanoNuke_Log.txt` file once complete.

## Security Note
This script is intended for users following an **Offline-first** or high-privacy strategy. By disabling remote model fetching, you reduce background data usage and reclaim significant disk space.