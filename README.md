# Kaitai Struct files for Meshcore
These files allow for language-neutral encoding and decoding of the Meshcore protocols.

- `meshcore.ksy` - LoRa protocol, complete apart from ciphertext fields
- `companion.ksy` - companion serial protocol, for frames *from* the device, all push frames complete but not responses
- `companion_cmds.ksy` - companion serial protocol, for frames *to* the device complete

Not much of this has been tested so expect frequent changes. If you spot any problems, open an issue or PR.