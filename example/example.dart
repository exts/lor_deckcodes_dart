import 'dart:convert';
import 'dart:io';
import 'package:lor_deck_codes/deck_encoder.dart';

void main() {
  var deckEncoder = DeckEncoder();
  var decoded = deckEncoder
      .getDeckFromCode("CEBAIAIAC4QSUMAHAECAIHZMGEZTIOABAIAQIDQYAEBQCAAHEAZA");
  for (var cards in decoded) {
    print("x${cards.Count} - ${cardCodeToString(cards.CardCode)}");
  }

  // outputs:
  // x3 - [Demacia] Mageseeker Investigator - Play: If you cast a spell this round, remove all text and keywords from an enemy follower.
  // x3 - [Demacia] Remembrance - Costs 1 less for each ally that died this round. Summon a random 5 cost follower from Demacia.
  // x3 - [Demacia] Lux's Prismatic Barrier - Give an ally Barrier this round. Shuffle a Lux into your deck.
  // x3 - [Demacia] Mageseeker Inciter - Play: Discard a spell to grant me Power equal to its cost.
  // x3 - [Piltover & Zaun] Trueshot Barrage - Deal 3 to an enemy, 2 to another, 1 to another.
  // x3 - [Piltover & Zaun] Statikk Shock - Deal 1 to two enemies. Draw 1.
  // x3 - [Piltover & Zaun] Chempunk Shredder - Play: Deal 1 to all enemy units.
  // x3 - [Piltover & Zaun] Progress Day! - Draw 3, then reduce their cost by 1.
  // x3 - [Piltover & Zaun] Funsmith - All of your spells and Skills deal 1 extra damage.
  // x3 - [Piltover & Zaun] Mystic Shot - Deal 2 to anything.
  // x3 - [Piltover & Zaun] Heimerdinger - When you cast a spell, create a Fleeting Turret in hand with equal cost. It costs 0 this round.
  // x2 - [Piltover & Zaun] Unlicensed Innovation - Summon an Illegal Contraption.
  // x2 - [Piltover & Zaun] Unstable Voltician - When I'm summoned, grant me +4|+0 and Quick Attack if you've cast a 6+ cost spell this game.
  // x1 - [Demacia] Judgment - A battling ally strikes all battling enemies.
  // x1 - [Demacia] Prismatic Barrier - Give an ally Barrier this round.
  // x1 - [Demacia] Purify - Remove all text and keywords from a follower.

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
  var sets = [1, 2];
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

    var region = card["region"] ?? null;
    var name = card["name"] ?? null;
    var desc = (card["descriptionRaw"]) as String ?? null;
    desc = desc?.replaceAll("\r\n", " ");
    desc = desc?.replaceAll("\n", " ");

    return "[$region] $name" + (desc.isNotEmpty ? " - $desc" : "");
  }

  throw ArgumentError("Card not found");
}

Map<String, dynamic> dataToMap(Map<String, dynamic> list) {
  return {
    "region": list["region"] ?? null,
  };
}
