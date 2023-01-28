# uefi_fuzzer
EDK2/OVMF Fuzzer based on kAFL/Nyx/KVM

## Summary
This is a UEFI fuzzing demo using KAFL, Nyx, KVM, and OVMF/EDK2 to demonstrate their capability.
This project is a WIP and will be updated to act as a resource for UEFI fuzzing.

Our harness/target source can be found [here](https://github.com/oscardagrach/edk2)

## Requirements
- Intel Skylake or later for Intel PT support
- Patched Host Kernel - see https://github.com/nyx-fuzz/KVM-Nyx
- Recent Debian/Ubuntu (20.04 or bullseye and newer)
- Harnessed target (we will use my EDK2 fork https://github.com/oscardagrach/edk2)

```
sudo apt install python3-venv make git
```

## Getting Started
```
git clone https://github.com/oscardagrach/uefi_fuzzer.git
cd uefi_fuzzer; make deploy
./fuzz/run.sh fuzz
```

## Configuration
The file fuzz/kafl.yaml contains various configuration keys to enable or disable functionality in kAFL.

See [here](https://github.com/IntelLabs/kAFL/blob/master/docs/source/reference/fuzzer_configuration.md) for more information on configuration keys.

## Notes
TBD