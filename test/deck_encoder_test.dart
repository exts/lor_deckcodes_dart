import 'dart:io';
import 'dart:typed_data';
import 'package:base32/base32.dart';
import 'package:lor_deck_codes/card_code_count.dart';
import 'package:lor_deck_codes/deck_encoder.dart';
import 'package:test/test.dart';

void main() {
  test("test the encoding of a set of hard coded decks in decklist.txt", () {
    var deckEncoder = DeckEncoder();

    var file = File("test/fixtures/deckcodes.txt");
    var lines = file.readAsLinesSync();

    var codes = <String>[];
    var decks = <List<CardCodeAndCount>>[];

    var newDeck = <CardCodeAndCount>[];
    var code = true;
    for(var line in lines) {
      if(line.isEmpty && !code) {
        if(newDeck.length > 0) {
          decks.add(newDeck);
        }
        newDeck = <CardCodeAndCount>[];
        code = true; continue;
      }

      if(code) {
        codes.add(line);
        code = false; continue;
      }

      List<String> parts = line.split(":");
      newDeck.add(CardCodeAndCount(parts[1], int.tryParse(parts[0])));
    }

    if(newDeck.length > 0) {
      decks.add(newDeck);
    }

    for(var i = 0; i < decks.length; i++) {
      var encoded = deckEncoder.getCodeFromDeck(decks[i]);
      var decoded = deckEncoder.getDeckFromCode(codes[i]);
      var recoded = deckEncoder.getCodeFromDeck(decoded);
      expect(encoded, recoded);
      expect(verifyRehydration(decks[i], decoded), true);
    }

  });

  test("order shouldn't matter", () {

    var decoder = DeckEncoder();

    var deck1 = <CardCodeAndCount>[];
    deck1.add(CardCodeAndCount("01DE002", 1));
    deck1.add(CardCodeAndCount("01DE003", 2));
    deck1.add(CardCodeAndCount("02DE003", 3));

    
    var deck2 = <CardCodeAndCount>[];
    deck2.add(CardCodeAndCount("01DE003", 2));
    deck2.add(CardCodeAndCount("02DE003", 3));
    deck2.add(CardCodeAndCount("01DE002", 1));

    var code1 = decoder.getCodeFromDeck(deck1);
    var code2 = decoder.getCodeFromDeck(deck2);

    expect(code1.contains(code2), true);

    var deck3 = <CardCodeAndCount>[];
    deck3.add(CardCodeAndCount("01DE002", 4));
    deck3.add(CardCodeAndCount("01DE003", 2));
    deck3.add(CardCodeAndCount("02DE003", 3));

    
    var deck4 = <CardCodeAndCount>[];
    deck4.add(CardCodeAndCount("01DE003", 2));
    deck4.add(CardCodeAndCount("02DE003", 3));
    deck4.add(CardCodeAndCount("01DE002", 4));

    var code3 = decoder.getCodeFromDeck(deck3);
    var code4 = decoder.getCodeFromDeck(deck4);

    expect(code3.contains(code4), true);
  });

  test("bildge water set test", () {
    var decoder = DeckEncoder();
    var deck = <CardCodeAndCount>[];
    deck.add(CardCodeAndCount("01DE002", 4));
    deck.add(CardCodeAndCount("02BW003", 2));
    deck.add(CardCodeAndCount("02BW010", 3));
    deck.add(CardCodeAndCount("01DE004", 5));

    var code = decoder.getCodeFromDeck(deck);
    var decoded = decoder.getDeckFromCode(code);
    expect(verifyRehydration(deck, decoded), true);
  });

  test("mt targon set test", () {
    var decoder = DeckEncoder();
    var deck = <CardCodeAndCount>[];
    deck.add(CardCodeAndCount("01DE002", 4));
    deck.add(CardCodeAndCount("03MT003", 2));
    deck.add(CardCodeAndCount("03MT010", 3));
    deck.add(CardCodeAndCount("02BW004", 5));

    var code = decoder.getCodeFromDeck(deck);
    var decoded = decoder.getDeckFromCode(code);
    expect(verifyRehydration(deck, decoded), true);
  });


  test("ru runeterra set test", () {
    var decoder = DeckEncoder();
    var deck = <CardCodeAndCount>[];
    deck.add(CardCodeAndCount("01DE002", 4));
    deck.add(CardCodeAndCount("03MT003", 2));
    deck.add(CardCodeAndCount("03MT010", 3));
    deck.add(CardCodeAndCount("02BW004", 5));

    var code = decoder.getCodeFromDeck(deck);
    var decoded = decoder.getDeckFromCode(code);
    expect(verifyRehydration(deck, decoded), true);
  });

  test("Bad Version test", () {
    var decoder = DeckEncoder();
    var deck = <CardCodeAndCount>[];
    deck.add(CardCodeAndCount("01DE002", 4));
    deck.add(CardCodeAndCount("01DE003", 2));
    deck.add(CardCodeAndCount("02DE003", 3));
    deck.add(CardCodeAndCount("01DE004", 5));

    var bytesFromDeck = base32.decode(decoder.getCodeFromDeck(deck));
    var result = <int>[];
    result.add(88); // invalid version
    var bytesFromDeckWithNewVersion = result + bytesFromDeck.getRange(1, bytesFromDeck.length).toList();

    var badVersionDeckCode = base32.encode(Uint8List.fromList(bytesFromDeckWithNewVersion));
    expect(
      () => decoder.getDeckFromCode(badVersionDeckCode), 
      throwsA(allOf(isArgumentError, predicate((e) => e.message == 'The provided code requires a higher version of this library; please update.')))
    );
  });
}

bool verifyRehydration(List<CardCodeAndCount> d, List<CardCodeAndCount> rehydratedList) {
  if(d.length != rehydratedList.length) {
    return false;
  }
  for(var cd in rehydratedList) {
    var found = false;
    for(var cc in d) {
      if(cc.CardCode == cd.CardCode && cc.Count == cd.Count) {
        found = true;
        break;
      }
    }
    if(!found) {
      return false;
    }
  }
  return true;
}