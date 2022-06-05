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
  printNl();

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
  printNl();

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
  
  decoded = deckEncoder
      .getDeckFromCode("CIBQEAQGAECQGBAAAIBQYBIGAYDAODY4EMBQCAIABEAQKAAUAMDAMCYQDYAA");
  for (var cards in decoded) {
    print("x${cards.Count} - ${cardCodeToString(cards.CardCode)}");
  }
  printNl();

  // outputs
  // x3 - [Bilgewater] Ye Been Warned - Give an enemy Vulnerable this round. If it dies this round, draw 1.
  // x3 - [Bilgewater] Hired Gun - When I'm summoned, grant the strongest enemy Vulnerable.
  // x3 - [Demacia] Golden Aegis - Give an ally Barrier this round. Rally.
  // x3 - [Demacia] Cataclysm - An ally starts a free attack Challenging an enemy.
  // x3 - [Demacia] Field Promotion - The next time you play a unit this round, grant it Scout. It's now an Elite.
  // x3 - [Bilgewater] Illaoi - Attack: Spawn 1, then I gain Power equal to your strongest Tentacle's Power this round.
  // x3 - [Bilgewater] Watchful Idol - Round Start: Deal 2 to me and Spawn 1.
  // x3 - [Bilgewater] Answered Prayer - Spawn 2, or spend 5 mana to Spawn 4 instead.
  // x3 - [Bilgewater] Tentacle Smash - Spawn 3, then your strongest Tentacle and an enemy strike each other.
  // x3 - [Bilgewater] The Sea's Voice - Attack: Spawn 1 and give your strongest Tentacle Overwhelm this round.
  // x2 - [Demacia] Brightsteel Protector - Play: Give an ally Barrier this round.
  // x2 - [Demacia] Shield of Durand - Grant an ally +0|+3. At the next Round Start, grant it +0|+2.
  // x2 - [Bilgewater] Nagakabouros - Round Start: Spawn 2. Then, if your strongest Tentacle has 12+ Power, create a Nagakabouros' Tantrum in hand.
  // x2 - [Bilgewater] Buhru Lookout - When I'm summoned, Spawn 3.
  // x2 - [Bilgewater] Eye of Nagakabouros - Spawn 2. Draw 2.
}

// bad practice, but this is just an example
var cards = getCards();

List<dynamic> getCards() {
  var sets = [1, 2, 3, 4, 5, 6];
  var cards = <dynamic>[];

  for(var currentSet in sets) {
    var data = loadSetData(currentSet);
    if(data.isEmpty) continue;
    cards.addAll(data);
  }

  if (cards.isEmpty) {
    throw FileSystemException("Set data couldn't be loaded");
  }

  return cards;
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
  for (var card in cards) {
    var code = card["cardCode"] ?? null;
    if(code == null) {
      continue;
    }
    if(code != dataCode) continue;
    
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

void printNl() {
  print("");
}