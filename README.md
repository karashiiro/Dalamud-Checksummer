# Dalamud-Checksummer
Compares the checksum of a provided zipped DLL with that of a fresh build from the plugin's repository.

Except that the checksums never match, because the folder that the application is built in affects the byte-output of the build.

## Usage
`Dalamud-Checksummer.ps1 .\latest.zip .\PluginInternalName.json`
