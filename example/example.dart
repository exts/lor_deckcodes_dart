import 'dart:convert';
import 'dart:io';
import 'package:lor_deck_codes/deck_encoder.dart';

void main() {
  var deckEncoder = DeckEncoder();
  var decoded = deckEncoder
      .getDeckFromCode("CEBQOBIEAYEQUDIOB4RQGAIEBAFDKAYFBJDKIAO7AEAACAIBAQMQ");
  for (var cards in decoded) {
    print("x${cards.Count} - ${cardCodeToString(cards.CardCode)}");
  }

  // outputs:
  // x3 - [Piltover & Zaun] Caitlyn - Strike: Plant 2 Flashbomb Traps randomly in the top 8 cards in the enemy deck.
  // x3 - [Piltover & Zaun] Sting Officer - Nexus Strike: Plant 2 Flashbomb Traps randomly in the top 8 cards of the enemy deck.
  // x3 - [Piltover & Zaun] Advanced Intel - Plant 2 Flashbomb Traps randomly in the top 8 cards of the enemy deck.
  // x3 - [Piltover & Zaun] Piltover Peacemaker - Deal 2 to a unit and plant 2 Flashbomb Traps randomly in the top 8 cards of the enemy deck.
  // x3 - [Piltover & Zaun] Corina, Mastermind - Play: Plant 5 Flashbomb Traps randomly or activate the effects of all traps in the top 5 cards of the enemy deck.
  // x3 - [Piltover & Zaun] Justice Rider - Whenever your opponent draws, plant 1 Flashbomb Trap randomly in the top 8 cards in the enemy deck. 
  // x3 - [Piltover & Zaun] Stinky Whump - Last Breath: Create a copy of me in the enemy deck with 2 Poison Puffcaps attached. 
  // x3 - [Piltover & Zaun, Bandle City] Teemo - Nexus Strike: Plant 5 Poison Puffcaps on random cards in the enemy deck.
  // x3 - [Piltover & Zaun] Mushroom Cloud - Plant 5 Poison Puffcaps on random cards in the enemy deck.
  // x3 - [Piltover & Zaun] Clump of Whumps - When I'm summoned, create a Mushroom Cloud in hand.
  // x3 - [Bandle City] Ava Achiever - When I'm summoned or Round End: Plant 3 Poison Puffcaps on random cards in the enemy deck.  Traps on enemy cards are doubled when activated.
  // x3 - [Bandle City] Poison Dart - Deal 1 to anything and plant 3 Poison Puffcaps on random cards in the enemy deck. 
  // x3 - [Bandle City] Entrapment - Pick 1 of 3 units or spells from the enemy deck and plant 3 Poison Puffcaps on all copies of it.
  // x1 - [Piltover & Zaun] Puffcap Peddler - When you play a spell, plant 3 Poison Puffcaps on random cards in the enemy deck.

  decoded = deckEncoder
      .getDeckFromCode("CEAQIAIDB4SSMNYDAIBAMLJ4AMBAGAYEBIDQCAYCAUGB4KBQGQBQCAQGCYAQEAYGAIAQGFRK");
  for (var cards in decoded) {
    print("x${cards.Count} - ${cardCodeToString(cards.CardCode)}");
  }

  // outputs (borrowed: https://lor.mobalytics.gg/decks/br0lsulbunq760h24740)
  // x3 - [Noxus] Precious Pet
  // x3 - [Noxus] Legion Grenadier - Last Breath: Deal 2 to the enemy Nexus.
  // x3 - [Noxus] Darius
  // x3 - [Noxus] House Spider - When I'm summoned, summon a Spiderling.
  // x2 - [Bilgewater] Make it Rain - Deal 1 to three different random enemies.
  // x2 - [Bilgewater] Crackshot Corsair - When allies attack, deal 1 to the enemy Nexus.
  // x2 - [Noxus] Noxian Fervor - Deal 3 to an ally unit to deal 3 to anything.
  // x2 - [Noxus] Imperial Demolitionist - Play: Deal 1 to an ally unit to deal 2 to the enemy Nexus.
  // x2 - [Noxus] Armored Tuskrider - I cannot be damaged by enemy units unless they have 5+ Power.
  // x2 - [Noxus] Decimate - Deal 4 to the enemy Nexus.
  // x2 - [Noxus] Crimson Aristocrat - Play: Deal 1 to an ally and grant it +2|+0.
  // x2 - [Noxus] Legion Rearguard
  // x2 - [Noxus] Crimson Disciple - When I survive damage, deal 2 to the enemy Nexus.
  // x2 - [Noxus] Legion Saboteur - Attack: Deal 1 to the enemy Nexus.
  // x2 - [Noxus] Crimson Curator - When I survive damage, create a random Crimson unit in your hand.
  // x2 - [Noxus] Blood for Blood - Deal 1 to an allied follower. If it survives, create a copy of it in hand.
  // x1 - [Bilgewater] Miss Fortune's Make it Rain - Deal 1 to three different random enemies. Shuffle a Miss Fortune into your deck.
  // x1 - [Noxus] Citybreaker - Round Start: Deal 1 to the enemy Nexus.
  // x1 - [Noxus] Noxian Guillotine - Kill a damaged unit.  You can cast this again this round.
  // x1 - [Noxus] Katarina - Play: Rally. Strike: Recall me.
}

List<dynamic> loadSetData(int setNumber) {
  var file = File("set$setNumber-en_us.json");
  var contents = file.readAsStringSync();
  if (contents.isNotEmpty) {
    return jsonDecode(contents);
  }
  return null;
}

String cardCodeToString(String dataCode) {
  var sets = [1, 2, 3, 4, 5];
  var cards = List<dynamic>();

  for(var currentSet in sets) {
    var data = loadSetData(currentSet);
    if(data.isEmpty) continue;
    cards.addAll(data);
  }

  if (cards.isEmpty) {
    throw FileSystemException("Set data couldn't be loaded");
  }

  for (var card in cards) {
    var code = card["cardCode"] ?? null;
    if (!code.toString().contains(dataCode)) continue;

    var region = card["regions"] ?? null;
    var name = card["name"] ?? null;
    var desc = (card["descriptionRaw"]) as String ?? null;
    desc = desc?.replaceAll("\r\n", " ");
    desc = desc?.replaceAll("\n", " ");

    return "[${region.join(", ")}] $name" + (desc.isNotEmpty ? " - $desc" : "");
  }

  throw ArgumentError("Card not found");
}

Map<String, dynamic> dataToMap(Map<String, dynamic> list) {
  return {
    "region": list["region"] ?? null,
  };
}
