# Half Smoked

[Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3790084068)

A Project Zomboid (B42) mod. Smoke part of a cigar or cigarette, pocket it,
relight it later, or pass it to a friend.

Vanilla makes every smokable an all-or-nothing item (the `base:useall` tag).
This mod adds partial consumption:

- **Take a drag** / **Smoke half** / **Finish it** on any cigar or cigarette
- Remaining drags persist across saves
- A partially smoked item shows its remaining drags in its name
- Handing a half-smoked cigar to another player carries its state with it

## How it works

Remaining drags live in the item's `ModData`, which is why sharing needs no
networking code -- the state travels with the item.

Partial drags run a custom timed action that applies a fraction of the item's
mood effects. The **final** drag is delegated to vanilla
`ISInventoryPaneContextMenu.eatItem`, so nicotine withdrawal bookkeeping and
item removal stay the engine's job and fire exactly once per item.

## Install (local dev)

Copy or clone into `~/Zomboid/mods/HalfSmoked`, then enable it in the in-game
mod list.

## Tuning

Drags per item are in `42.20/media/lua/shared/HalfSmoked.lua`.
