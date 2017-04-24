# snatch
Downloads all files from URLs defined in a text file into a pre-defined directory, with the option of executing a SHA-256 checksum.
***
# Instructions
1. Create a file called "source.txt" with URLs to each file on a separate line
2. Edit snatch.sh and verify the configuration under "User Configuration"
3. Execute the script
***
# User Configuration Options
1. Snatch_Source: path to a text file with each link to download on a separate line.
2. Snatch_Destination: path to a folder where Snatch should download your files to (no trailing slash)
3. Snatch_DerivePath: whether or not to use a structured path for destination files. If set to false, this will place all files directly in the root of the destination folder. If set to true, it will derive the path from the actual URL like so:

Snatch_Destination/Site URL/Path to File

4. Snatch_EnableLog: Whether or not to log output to file
5. Snatch_TimestampLog: Whether or not to name logs with timestamp (essentially rotates the log with each run)
6. Snatch_LogDirectory: Folder where logs should be written to
7. Snatch_CalculateSHA256: Calculate the SHA-256 checksum of each file after all are completed. This can potentially slow down the process greatly depending on the file sizes you are downloading.
8. Snatch_ForceRoot: Ensure the script is running as root, can be disabled for the paranoid.

WARNING: If you choose to disable this, the script will forcibly terminate for trivial things like being unable to create folders or ACLs being incorrect.
***
