Chest whose content can only be taken from and that offers the same content to each player once. I wrote this because I made treasure hunting game. I wanted players to receive each a reward for finding the chest, not have a first-arrived-takes-all. 

Players are only able to take from it, not put things in, a bit similar to the way bones work.

To fill it, open it with a user who has the 'protection_bypass' privilege. This user will access the default inventory of the chest.

The way this works under the hood is that each chest has an inventory that is only shown to admins with 'protection_bypass'. All others are shown a an inventory page that is actually attached to their player and that is initialized with the content of the default inventory. 

Inspired by Megaf's more_chest wifi chest:
https://github.com/minetest-mods/more_chests

I'd love to remove the default dependency but that would require that issue to be fixed first
https://github.com/minetest/minetest/issues/7068