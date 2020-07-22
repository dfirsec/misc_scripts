Coming soon...

File Formats and Magic Signature:
```python
file_types = {
    '7z': b'37 7a bc af 27 1c',
    'asm': b'00 61 73 6d',
    'bin': b'53 50 30 31',
    'binary': b'4d 5a 90 00',
    'bmp': b'42 4d',
    'bz2': b'42 5a 68',
    'dat': b'50 4d 4f 43 43 4d 4f 43',
    'deb': b'21 3C 61 72 63 68 3E',
    'elf': b'7f 45 4c 46',
    'flash': b'43 57 53',
    'jfif': b'ff d8 ff e0 00 10 4a 46 49 46 00 01',
    'jpg': b'ff d8 ff db',
    'mp3': b'49 44 33',
    'mpeg': b'00 00 01 ba',
    'ogg': b'4f 67 67 53',
    'pcap': b'd4 c3 b2 a1',
    'pcapng': b'0a 0d 0d 0a',
    'pdf': b'25 50 44 46 2d',
    'png': b'89 50 4e 47 0d 0a 1a 0a',
    'rar': b'52 61 72 21 1a 07 01 00',
    'rtf': b'7b 5c 72 74 66 31',
    'sqlite': b'53 51 4c 69 74 65 20 66 6f 72 6d 61 74 20 33 00',
    'tarv1': b'75 73 74 61 72 00 30 30',
    'tarv2': b'75 73 74 61 72 20 20 00',
    'vmdk': b'4b 44 4d',
    'xar': b'78 61 72 21',
    'xml': b'3c 3f 78 6d 6c 20',
    'zip': b'50 4b 03 04',
}
```


Check for all file formats (from list)
```text
python check_magic.py d:\Downloads\Ultimate_Guide_Arduino_Sensors_Modules      

 PDF   d:\Downloads\Ultimate_Guide_Arduino\Ultimate_Guide_Arduino_Sensors_Modules.pdf
 ZIP   d:\Downloads\Ultimate_Guide_Arduino\1 - DHT11_DHT22\Code\DHT_library.zip
 JFIF  d:\Downloads\Ultimate_Guide_Arduino\1 - DHT11_DHT22\Schematics\Schematics.jpg
 PNG   d:\Downloads\Ultimate_Guide_Arduino\10 - Tilt\Schematics\Schematics.png
 PNG   d:\Downloads\Ultimate_Guide_Arduino\11 - Microphone Sound\Schematics\Schematics.png
 PNG   d:\Downloads\Ultimate_Guide_Arduino\12 - Reed Switch\Schematics\Magnetic_Reed_Switch.png
 ZIP   d:\Downloads\Ultimate_Guide_Arduino\13 - MRFC522 RFID\Code\RFID_Library.zip
 PNG   d:\Downloads\Ultimate_Guide_Arduino\13 - MRFC522 RFID\Schematics\RFID.png
 PNG   d:\Downloads\Ultimate_Guide_Arduino\14 - Relay\Schematics\Relay_Module.png
 ...
 ```
 Check by specified file format (from list)
 ```text
python check_magic.py d:\Downloads\Ultimate_Guide_Arduino_Sensors_Modules -s zip

d:\Downloads\Ultimate_Guide_Arduino_Sensors_Modules\1 - DHT11_DHT22\Code\DHT_library.zip
d:\Downloads\Ultimate_Guide_Arduino_Sensors_Modules\13 - MRFC522 RFID\Code\RFID_Library.zip
d:\Downloads\Ultimate_Guide_Arduino_Sensors_Modules\15 - nRF24L01\Code\RadioHead_Library.zip
d:\Downloads\Ultimate_Guide_Arduino_Sensors_Modules\16 - 433 MHZ Transmitter_Receiver\Code\RadioHead_Library.zip
d:\Downloads\Ultimate_Guide_Arduino_Sensors_Modules\18 - Dot Matrix\Code\LedControl.zip
...
```
