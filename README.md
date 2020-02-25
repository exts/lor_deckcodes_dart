Dart Port of the official [LoR DeckCodes Encoder](https://github.com/RiotGames/LoRDeckCodes).

Example:

```dart
var deck = DeckEncoder()
    ..getDeckFromCode("CEBAIAIAC4QSUMAHAECAIHZMGEZTIOABAIAQIDQYAEBQCAAHEAZA"))
; // outputs a: List<CardCodeAndCount>
````