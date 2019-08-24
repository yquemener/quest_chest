local quest_chests_storage = minetest.get_mod_storage()



minetest.register_node("quest_chest:chest", {
  description = "Quest Chest",
	tiles = {
		"default_chest_top.png",
		"default_chest_top.png",
		"default_chest_side.png",
		"default_chest_side.png",
		"default_chest_side.png",
    "quest_chest_lock.png"
	},
	paramtype2 = "facedir",
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2,},
	legacy_facedir_simple = true,
	sounds = default.node_sound_wood_defaults(),
  can_dig = function(pos,player)
    return minetest.check_player_privs(player:get_player_name(), "protection_bypass")
  end,
  on_destruct = function(pos)
    local meta = minetest.get_meta(pos)
    local chestid = meta:get_int("chestid")
    print("Destroying chest_"..chestid)
    local ids = minetest.deserialize(quest_chests_storage:get_string("ids"))
    for index, value in pairs(ids) do
      if value == chestid then
          table.remove(ids, index)
          break
      end
    end
    quest_chests_storage:set_string("ids", minetest.serialize(ids))
  end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
    local chestid = quest_chests_storage:get_int("next_id")
    meta:set_string("chestid", chestid)
    local ids = minetest.deserialize(quest_chests_storage:get_string("ids") or "{}")
    table.insert(ids, chestid)
    quest_chests_storage:set_string("ids", minetest.serialize(ids))
    quest_chests_storage:set_int("next_id", chestid+1)
		meta:set_string("formspec",
				"size[8,9]"..
				default.gui_bg ..
				default.gui_bg_img ..
				default.gui_slots ..
				"list[current_player;quest_chest:chest"..chestid..";0,0.3;8,4;]"..
				"list[current_player;main;0,4.85;8,1;]" ..
				"list[current_player;main;0,6.08;8,3;8]" ..
				"listring[current_player;quest_chest:chest"..chestid.."]" ..
				"listring[current_player;main]" ..
				default.get_hotbar_bg(0,4.85))
    local spos = pos.x .. "," .. pos.y .. "," .. pos.z
    meta:set_string("formspec_admin",
				"size[8,9]"..
				default.gui_bg ..
				default.gui_bg_img ..
				default.gui_slots ..
				"list[nodemeta:" .. spos .. ";main;0,0.3;8,4;]" ..
				"list[current_player;main;0,4.85;8,1;]" ..
				"list[current_player;main;0,6.08;8,3;8]" ..
				"listring[nodemeta:" .. spos .. ";main]" ..
				"listring[current_player;main]" ..
				default.get_hotbar_bg(0,4.85))
		local inv = meta:get_inventory()
		inv:set_size("main", 8*2)
	end,
  allow_metadata_inventory_put = function(pos, listname, index, stack, player)
    local playername = player:get_player_name()

    if minetest.check_player_privs(playername, "protection_bypass") then
      return stack:get_count()
    else
      return 0
    end
  end,

  on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
    local meta = minetest.get_meta(pos)
    local playername = clicker:get_player_name()

    if minetest.check_player_privs(playername, "protection_bypass") then
      minetest.show_formspec(clicker:get_player_name(),
          node.name, meta:get_string("formspec_admin"))
    else
      local inv = clicker:get_inventory()
      local chestname = "quest_chest:chest"..meta:get_int("chestid")
      if inv:get_size(chestname)==0 then
        inv:set_size(chestname, 8)
        inv:set_list(chestname, meta:get_inventory():get_list("main"))
      end
      minetest.show_formspec(clicker:get_player_name(),
          node.name, meta:get_string("formspec"))
    end

  end,

	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in quest chest at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to quest chest at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from quest chest at "..minetest.pos_to_string(pos))
	end,
})

minetest.register_on_joinplayer(function(player)
  --[[ local ids = minetest.deserialize(quest_chests_storage:get_string("ids"))
  local inv = player:get_inventory()
  print(dump(inv:get_size("quest_chest:chest333")))
  for i,chestid in ipairs(ids) do
    inv:set_size("quest_chest:chest"..chestid, 8)
  end ]]--

  minetest.register_on_player_inventory_action(
    function(player, action, inventory, inventory_info)
      local inv = player:get_inventory()
      if inventory_info.from_list and inventory_info.from_index then
        local stack = inv:get_stack(
            inventory_info.from_list,
            inventory_info.from_index
        )
      end
    end)
  minetest.register_allow_player_inventory_action(
    function(player, action, inventory, inventory_info)
      local inv = player:get_inventory()
      if inventory_info.from_list and inventory_info.from_index then
        local stack = inv:get_stack(
            inventory_info.from_list,
            inventory_info.from_index
        )
        if string.sub(inventory_info.to_list,1,11)=="quest_chest" then
          return 0
        else
          return stack:get_count()
        end
      end
      return
    end)
end)
