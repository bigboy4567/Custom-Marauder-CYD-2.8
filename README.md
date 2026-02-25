# Custom Marauder CYD 2.8

Fork personnalise de ESP32 Marauder pour CYD 2.8 (`MARAUDER_CYD_2USB`).

## Modifs principales

- Ecran d'accueil personnalise (logo + texte custom).
- Confirmation avant reboot depuis le menu.
- GPS/wardriving retire pour cette cible.
- Sensibilite tactile legerement reduite (filtre de pression XPT2046).

## Prerequis

- Arduino CLI installe
- Core ESP32 Arduino installe (3.3.4 recommande)
- Carte cible connectee en USB (ex: `COM3`)

Libs utilisees:

- `ArduinoJson`
- `NimBLE-Arduino`
- `ESP32Ping`
- `AsyncTCP`
- `ESP Async WebServer` (version locale dans `esp32_marauder/libraries/ESPAsyncWebServer`)

## Compilation

Depuis la racine du projet:

```powershell
& 'C:\Users\youtu\AppData\Local\Programs\Arduino IDE\resources\app\lib\backend\resources\arduino-cli.exe' compile `
  --fqbn 'esp32:esp32:d32:PartitionScheme=min_spiffs' `
  --warnings none `
  --library 'C:\Users\youtu\Documents\ESP32Marauder-nightly_8a91247\esp32_marauder\libraries\ESPAsyncWebServer' `
  --build-property 'compiler.cpp.extra_flags=-DMARAUDER_CYD_2USB -DUSER_SETUP_LOADED -include C:/Users/youtu/Documents/ESP32Marauder-nightly_8a91247/User_Setup_cyd_2usb.h' `
  esp32_marauder
```

## Upload

```powershell
& 'C:\Users\youtu\AppData\Local\Programs\Arduino IDE\resources\app\lib\backend\resources\arduino-cli.exe' compile `
  --upload -p COM3 `
  --fqbn 'esp32:esp32:d32:PartitionScheme=min_spiffs' `
  --warnings none `
  --library 'C:\Users\youtu\Documents\ESP32Marauder-nightly_8a91247\esp32_marauder\libraries\ESPAsyncWebServer' `
  --build-property 'compiler.cpp.extra_flags=-DMARAUDER_CYD_2USB -DUSER_SETUP_LOADED -include C:/Users/youtu/Documents/ESP32Marauder-nightly_8a91247/User_Setup_cyd_2usb.h' `
  esp32_marauder
```

## Git / Push

Le script `push_updates.bat` utilise `git add -A`.

Donc:

- un fichier supprime localement => sera commit en suppression
- apres `push`, le meme fichier sera supprime sur GitHub

## Avertissement

Utilisation uniquement sur du materiel et des reseaux autorises.
