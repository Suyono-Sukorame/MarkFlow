Export apk minim size

32bit
arrahmah@arrahmah-desktop:~/Projects/kksa_mobile_app$ flutter clean && flutter pub get.
arrahmah@arrahmah-desktop:~/Projects/kksa_mobile_app$ flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/debug-info.

64bit
arrahmah@arrahmah-desktop:~/Projects/kksa_mobile_app$ flutter clean && flutter build apk --release --target-platform android-arm64,android-arm --split-per-abi
