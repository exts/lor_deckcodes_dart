import 'dart:typed_data';
import 'package:base32/base32.dart';
import 'package:lor_deck_codes/card_code_count.dart';
import 'package:lor_deck_codes/varint_translator.dart';

class DeckEncoder {
  static const int CARD_CODE_LENGTH = 7;
  static const int MAX_KNOWN_VERSION = 2;

  Map<String, int> factionCodeToIntIdentifier = Map<String, int>();
  Map<int, String> intIdentifierToFactionCode = Map<int, String>();

  DeckEncoder() {
    factionCodeToIntIdentifier.addAll({
      'DE': 0,
      'FR': 1,
      'IO': 2,
      'NX': 3,
      'PZ': 4,
      'SI': 5,
      'BW': 6,
      'MT': 9,
    });

    intIdentifierToFactionCode.addAll({
      0: 'DE',
      1: 'FR',
      2: 'IO',
      3: 'NX',
      4: 'PZ',
      5: 'SI',
      6: 'BW',
      9: 'MT',
    });
  }

  List<CardCodeAndCount> getDeckFromCode(String code) {
    var result = List<CardCodeAndCount>();

    List<int> bytes;

    try {
      // original code strips padding, so we gotta add it back
      int padding = 8 - (code.length % 8);
      if (padding > 0 && padding != 8) {
        code += ('=' * padding);
      }

      bytes = base32.decode(code);
    } on Exception catch (e) {
      throw ArgumentError("Invalid deck code: ${e} '${code}'");
    }

    var byteList = bytes.toList();

    //grab format and version
    // int format = bytes[0] >> 4;
    int version = bytes[0] & 0xF;
    byteList.removeAt(0);

    if (version > MAX_KNOWN_VERSION) {
      throw ArgumentError(
          "The provided code requires a higher version of this library; please update.");
    }

    for (int i = 3; i > 0; i--) {
      var numbGroupOfs = VarintTranslator.popVarint(byteList);
      for (int j = 0; j < numbGroupOfs; j++) {
        var numOfsInThisGroup = VarintTranslator.popVarint(byteList);
        var sett = VarintTranslator.popVarint(byteList);
        var faction = VarintTranslator.popVarint(byteList);
        for (int k = 0; k < numOfsInThisGroup; k++) {
          int card = VarintTranslator.popVarint(byteList);

          String setString = sett.toString().padLeft(2, '0');
          String factionString = intIdentifierToFactionCode[faction];
          String cardString = card.toString().padLeft(3, '0');

          var newEntry =
              CardCodeAndCount("$setString$factionString$cardString", i);
          result.add(newEntry);
        }
      }
    }

    //the remainder of the deck code is comprised of entries for cards with counts >= 4
    //this will only happen in Limited and special game modes.
    //the encoding is simply [count] [cardcode]
    while (byteList.isNotEmpty) {
      int fourPlusCount = VarintTranslator.popVarint(byteList);
      int fourPlusSet = VarintTranslator.popVarint(byteList);
      int fourPlusFaction = VarintTranslator.popVarint(byteList);
      int fourPlusNumber = VarintTranslator.popVarint(byteList);

      String fourPlusSetString = fourPlusSet.toString().padLeft(2, '0');
      String fourPlusFactionString =
          intIdentifierToFactionCode[fourPlusFaction];
      String fourPlusNumberString = fourPlusNumber.toString().padLeft(3, '0');

      var newEntry = CardCodeAndCount(
          fourPlusSetString + fourPlusFactionString + fourPlusNumberString,
          fourPlusCount);
      result.add(newEntry);
    }

    return result;
  }

  String getCodeFromDeck(List<CardCodeAndCount> deck) {
    var encoded = base32.encode(Uint8List.fromList(getDeckCodeBytes(deck)));

    // remove padding
    encoded = encoded.replaceAll(RegExp(r"[=]*$"), "");

    return encoded;
  }

  List<int> getDeckCodeBytes(List<CardCodeAndCount> deck) {
    var result = List<int>();

    if (!validCardCodesAndCounts(deck)) {
      throw ArgumentError("The provided deck contains invalid card codes.");
    }

    result.add(18);

    var of3 = List<CardCodeAndCount>();
    var of2 = List<CardCodeAndCount>();
    var of1 = List<CardCodeAndCount>();
    var ofN = List<CardCodeAndCount>();

    for (var ccc in deck) {
      if (ccc.Count == 3) {
        of3.add(ccc);
      } else if (ccc.Count == 2) {
        of2.add(ccc);
      } else if (ccc.Count == 1) {
        of1.add(ccc);
      } else if (ccc.Count < 1) {
        throw ArgumentError(
            "Invalid count of ${ccc.Count} for card ${ccc.CardCode}");
      } else {
        ofN.add(ccc);
      }
    }

    //build the lists of set and faction combinations within the groups of similar card counts
    var groupedOf3s = getGroupedOfs(of3);
    var groupedOf2s = getGroupedOfs(of2);
    var groupedOf1s = getGroupedOfs(of1);

    //to ensure that the same decklist in any order produces the same code, do some sorting
    groupedOf3s = sortGroupOf(groupedOf3s);
    groupedOf2s = sortGroupOf(groupedOf2s);
    groupedOf1s = sortGroupOf(groupedOf1s);

    //Nofs (since rare) are simply sorted by the card code - there's no optimiziation based upon the card count
    ofN.sort((a, b) => b.CardCode.compareTo(a.CardCode));

    //Encode
    encodeGroupOf(result, groupedOf3s);
    encodeGroupOf(result, groupedOf2s);
    encodeGroupOf(result, groupedOf1s);

    //Cards with 4+ counts are handled differently: simply [count] [card code] for each
    encodeNOfs(result, ofN);

    return result.toList();
  }

  encodeNOfs(List<int> bytes, List<CardCodeAndCount> nOfs) {
    for (var ccc in nOfs) {
      bytes.addAll(VarintTranslator.getVarint(ccc.Count));

      var setNumber = getCardSet(ccc.CardCode);
      var cardNumber = getCardNumber(ccc.CardCode);
      var factionCode = getCardFaction(ccc.CardCode);

      var factionNumber = factionCodeToIntIdentifier[factionCode];

      bytes.addAll(VarintTranslator.getVarint(setNumber));
      bytes.addAll(VarintTranslator.getVarint(factionNumber));
      bytes.addAll(VarintTranslator.getVarint(cardNumber));
    }
  }

  //The sorting convention of this encoding scheme is
  //First by the number of set/faction combinations in each top-level list
  //Second by the alphanumeric order of the card codes within those lists.
  List<List<CardCodeAndCount>> sortGroupOf(
      List<List<CardCodeAndCount>> groupOf) {
    groupOf.sort((a, b) => a.length.compareTo(b.length));
    for (var i = 0; i < groupOf.length; i++) {
      groupOf[i].sort((a, b) => a.CardCode.compareTo(b.CardCode));
      groupOf[i] = groupOf[i].toList();
    }
    return groupOf;
  }

  int getCardSet(String code) {
    return int.parse(code.substring(0, 2));
  }

  String getCardFaction(String code) {
    return code.substring(2, 4);
  }

  int getCardNumber(String code) {
    return int.parse(code.substring(4, 7));
  }

  List<List<CardCodeAndCount>> getGroupedOfs(List<CardCodeAndCount> list) {
    List<List<CardCodeAndCount>> result = List<List<CardCodeAndCount>>();
    while (list.isNotEmpty) {
      List<CardCodeAndCount> currentSet = List<CardCodeAndCount>();

      //get info from first
      var firstCardCode = list[0].CardCode;

      int setNumber = getCardSet(firstCardCode);
      String factionCode = getCardFaction(firstCardCode);

      currentSet.add(list[0]);
      list.removeAt(0);

      for (var i = list.length - 1; i >= 0; i--) {
        String currentCardCode = list[i].CardCode;
        int currentSetNumber = getCardSet(currentCardCode);
        String currentFactionCode = getCardFaction(currentCardCode);

        if (currentSetNumber == setNumber &&
            currentFactionCode == factionCode) {
          currentSet.add(list[i]);
          list.removeAt(i);
        }
      }
      result.add(currentSet);
    }
    return result;
  }

  void encodeGroupOf(List<int> bytes, List<List<CardCodeAndCount>> groupOf) {
    bytes.addAll(VarintTranslator.getVarint(groupOf.length));
    for (var currentList in groupOf) {
      // how many cards in group?
      bytes.addAll(VarintTranslator.getVarint(currentList.length));

      // what is this group, as identified by a set and faction pair
      var currentCardCode = currentList[0].CardCode;
      var currentSetNumber = getCardSet(currentCardCode);
      var currentFactionCode = getCardFaction(currentCardCode);
      var currentFactionNumber = factionCodeToIntIdentifier[currentFactionCode];
      bytes.addAll(VarintTranslator.getVarint(currentSetNumber));
      bytes.addAll(VarintTranslator.getVarint(currentFactionNumber));

      // what are the cards, as identified by the third section of card code only now, within this group?
      for (var cd in currentList) {
        var code = cd.CardCode;
        var sequenceNumber = int.parse(code.substring(4, 7));
        bytes.addAll(VarintTranslator.getVarint(sequenceNumber));
      }
    }
  }

  bool validCardCodesAndCounts(List<CardCodeAndCount> deck) {
    for (var ccc in deck) {
      if (ccc.CardCode.length != CARD_CODE_LENGTH) {
        return false;
      }

      var parsed = ccc.CardCode.substring(0, 2);
      if (int.tryParse(parsed) == null) {
        return false;
      }

      var faction = ccc.CardCode.substring(2, 4);
      if (!factionCodeToIntIdentifier.containsKey(faction)) {
        return false;
      }

      if (int.tryParse(ccc.CardCode.substring(4, 7)) == null) {
        return false;
      }

      if (ccc.Count < 1) {
        return false;
      }
    }

    return true;
  }
}
