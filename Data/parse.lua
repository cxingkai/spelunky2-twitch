local module = {}

math.randomseed(os.time())
math.random()
math.random()
math.random()

local A1, A2 = 727595, 798405  -- 5^17=D20*A1+A2
local D20, D40 = 1048576, 1099511627776  -- 2^20, 2^40
local X1, X2 = 0, 1
function rand(max)
    local U = X2*A2
    local V = (X1*A2 + X2*A1) % D20
    V = (V*D20 + U) % D40
    X1 = math.floor(V/D20)
    X2 = V - X1*D20
	local r = V/D40
    return math.floor(r*max) + 1
end


white = Color:white()
black = Color:black()
ltgray = Color:new(0.45, 0.45, 0.45, 1)
bgopaque = Color:new(1, 1, 1, 0.8)

italic = VANILLA_FONT_STYLE.ITALIC
bold = VANILLA_FONT_STYLE.BOLD

local enemies = {ENT_TYPE.MONS_SNAKE,
		ENT_TYPE.MONS_CAVEMAN, ENT_TYPE.MONS_SKELETON, ENT_TYPE.MONS_SCORPION, ENT_TYPE.MONS_HORNEDLIZARD,
		ENT_TYPE.MONS_MOLE, ENT_TYPE.MONS_MANTRAP, ENT_TYPE.MONS_TIKIMAN,
		ENT_TYPE.MONS_MONKEY, ENT_TYPE.MONS_MAGMAMAN, ENT_TYPE.MONS_ROBOT,
		ENT_TYPE.MONS_FIREBUG_UNCHAINED, ENT_TYPE.MONS_FIREBUG,
		ENT_TYPE.MONS_CROCMAN, ENT_TYPE.MONS_COBRA, ENT_TYPE.MONS_SORCERESS,
		ENT_TYPE.MONS_CATMUMMY, ENT_TYPE.MONS_NECROMANCER, ENT_TYPE.MONS_JIANGSHI, ENT_TYPE.MONS_FEMALE_JIANGSHI,
		ENT_TYPE.MONS_FISH, ENT_TYPE.MONS_OCTOPUS, ENT_TYPE.MONS_HERMITCRAB, ENT_TYPE.MONS_HERMITCRAB, ENT_TYPE.MONS_ALIEN,
		ENT_TYPE.MONS_YETI, ENT_TYPE.MONS_PROTOSHOPKEEPER, ENT_TYPE.MONS_SHOPKEEPERCLONE,
		ENT_TYPE.MONS_OLMITE_HELMET, ENT_TYPE.MONS_OLMITE_BODYARMORED, ENT_TYPE.MONS_OLMITE_NAKED,
		ENT_TYPE.MONS_AMMIT, ENT_TYPE.MONS_FROG, ENT_TYPE.MONS_FIREFROG,
		ENT_TYPE.MONS_JUMPDOG, ENT_TYPE.MONS_LEPRECHAUN, 
		ENT_TYPE.MONS_CAVEMAN_BOSS, ENT_TYPE.MONS_LAVAMANDER, ENT_TYPE.MONS_MUMMY, ENT_TYPE.MONS_ANUBIS,
		ENT_TYPE.MONS_YETIKING, ENT_TYPE.MONS_YETIQUEEN, ENT_TYPE.MONS_ALIENQUEEN,
		ENT_TYPE.MONS_LAMASSU, ENT_TYPE.MONS_QUEENBEE, ENT_TYPE.MONS_GIANTFLY, ENT_TYPE.MONS_CRABMAN,
		ENT_TYPE.MOUNT_MECH, 
		ENT_TYPE.MONS_BAT, ENT_TYPE.MONS_SPIDER, ENT_TYPE.MONS_VAMPIRE,
		ENT_TYPE.MONS_MOSQUITO, ENT_TYPE.MONS_BEE, ENT_TYPE.MONS_GRUB, ENT_TYPE.MONS_IMP, ENT_TYPE.MONS_UFO, ENT_TYPE.MONS_SCARAB}

local enemies_miniboss = {ENT_TYPE.MONS_CAVEMAN_BOSS, ENT_TYPE.MONS_ANUBIS,
		ENT_TYPE.MONS_YETIKING, ENT_TYPE.MONS_YETIQUEEN, ENT_TYPE.MONS_ALIENQUEEN,
		ENT_TYPE.MONS_VLAD, ENT_TYPE.MONS_ANUBIS2}

announcementText = ""

cb_explosion_id = -1
local spiderlunkyDuration = -1
local touristDuration = -1
local disableCameraAfterTourist = false

tier1Events = {
	-- 1
	{"EXPLOSION", "One minute of huge explosions!", function()
			local x, y, l = get_position(players[1].uid)

			-- enlarge the hitboxes of the explosion entities, which increases the destruction radius
			set_post_entity_spawn(function(ent)
				ent.hitboxx = 5.5
				ent.hitboxy = 5.5
			end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FX_POWEREDEXPLOSION)

			set_post_entity_spawn(function(ent)
				ent.hitboxx = 4.5
				ent.hitboxy = 4.5
			end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FX_EXPLOSION)

			if cb_explosion_id ~= -1 then
				clear_callback(cb_explosion_id)
			end

			cb_explosion_id = set_global_timeout(function()
				set_post_entity_spawn(function(ent)
					ent.hitboxx = 2.5
					ent.hitboxy = 2.5
				end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FX_POWEREDEXPLOSION)
	
				set_post_entity_spawn(function(ent)
					ent.hitboxx = 1.5
					ent.hitboxy = 1.5
				end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FX_EXPLOSION)

				cb_explosion_id = -1
			end, 60*60)
	end },
	-- 2
	{"PUNISHMENT", "Kali punishes you with a ball and chain!", function()
	
		attach_ball_and_chain(players[1].uid, 0, 0)
		
		generate_particles(PARTICLEEMITTER.ALTAR_SMOKE, players[1].uid)
		generate_particles(PARTICLEEMITTER.LARGEITEMDUST, players[1].uid)
	
	end},
	-- 3
	{"GHOST", "The ghost has been summoned!", function()
		
		local sound = get_sound(VANILLA_SOUND.PLAYER_PGHOST_SHAKE)
		if sound ~= nil then sound:play() end
		
		local x, y, l = get_position(players[1].uid)
		local direction = math.random(1,4)
		
		if direction == 1 then
			spawn(ENT_TYPE.MONS_GHOST, x+20, y, l, 0, 0)
		elseif direction == 2 then
			spawn(ENT_TYPE.MONS_GHOST, x-20, y, l, 0, 0)
		elseif direction == 3 then
			spawn(ENT_TYPE.MONS_GHOST, x, y+20, l, 0, 0)
		else
			spawn(ENT_TYPE.MONS_GHOST, x, y-20, l, 0, 0)
		end
		
	end},
	-- 4
	{"JELLY", "Free royal jelly!", function()
		
		local x, y, l = get_position(players[1].uid)
		
		spawn(ENT_TYPE.ITEM_PICKUP_ROYALJELLY, x, y, l, 0, 0)
		
	end},
	-- 5
	{"JETPACK", "Free jetpack!", function()
		local x, y, l = get_position(players[1].uid)
		
		spawn(ENT_TYPE.ITEM_JETPACK, x, y, l, 0, 0)
	end},
	-- 6
	{"JETPACK?", "Free jetpack... and bombs :)", function()
		
		local x, y, l = get_position(players[1].uid)
		
		spawn(ENT_TYPE.ITEM_JETPACK, x, y, l, 0, 0)
		spawn(ENT_TYPE.ITEM_BOMB, x-1, y, l, 0, 0)
		spawn(ENT_TYPE.ITEM_BOMB, x-0.5, y, l, 0, 0)
		spawn(ENT_TYPE.ITEM_BOMB, x, y, l, 0, 0)
		spawn(ENT_TYPE.ITEM_BOMB, x+0.5, y, l, 0, 0)
		spawn(ENT_TYPE.ITEM_BOMB, x+1, y, l, 0, 0)
	end},
	-- 7
	{"ANKH", "Ankh will be toggled on/off!", function()
		
		local sound = get_sound(VANILLA_SOUND.ITEMS_CLONE_GUN)
		if sound ~= nil then sound:play() end
				
		if not players[1]:has_powerup(ENT_TYPE.ITEM_POWERUP_ANKH) then
			players[1]:give_powerup(ENT_TYPE.ITEM_POWERUP_ANKH)
		else
			players[1]:remove_powerup(ENT_TYPE.ITEM_POWERUP_ANKH)
		end
	end},
	-- 8
	{"WITCH DOCTOR CONFERENCE", "All enemies have been turned into witch doctors!", function()
		local monster_ents = get_entities_by_type(enemies)

		for i, ent in ipairs(monster_ents) do
			local xx, yy, ll = get_position(ent)
			kill_entity(ent)
			local wd = spawn(ENT_TYPE.MONS_WITCHDOCTOR, xx, yy, ll, 0, 0)
			generate_particles(PARTICLEEMITTER.LARGEITEMDUST, wd)	
		end
	end},
	-- 9
	{"RAIN OF ARROWS", "Arrows will rain down for 30 seconds!", function()
		-- give one second before all hell breaks loose
		set_timeout(function()
			local arrowRainInstances = 10
		
			set_interval(function() 
				if arrowRainInstances == 0 then
					clear_callback()
				end

				local x, y, l = get_position(players[1].uid)
				spawn(ENT_TYPE.ITEM_WOODEN_ARROW, x, y+4, l, 0, -1)
				spawn(ENT_TYPE.ITEM_WOODEN_ARROW, x-0.5, y+3, l, 0, -1)
				spawn(ENT_TYPE.ITEM_WOODEN_ARROW, x+0.5, y+3, l, 0, -1)

				arrowRainInstances = arrowRainInstances - 1
			end, 3 * 60)
		end, 60)
	end},
	-- 10
	{"INDEPENDENCE DAY", "All enemies have been turned into UFOs!", function()
		local monster_ents = get_entities_by_type(enemies)

		for i, ent in ipairs(monster_ents) do
			local xx, yy, ll = get_position(ent)
			kill_entity(ent)
			local wd = spawn(ENT_TYPE.MONS_UFO, xx, yy, ll, 0, 0)
			generate_particles(PARTICLEEMITTER.LARGEITEMDUST, wd)	
		end
	end},
	-- 11
	{"THE BOYS", "You got yourself a gang!", function()
		local x, y, l = get_position(players[1].uid)
		spawn_companion(ENT_TYPE.CHAR_HIREDHAND, x+0.2, y, l)
		spawn_companion(ENT_TYPE.CHAR_HIREDHAND, x-0.2, y, l)
		spawn_companion(ENT_TYPE.CHAR_HIREDHAND, x+0.1, y, l)
		spawn_companion(ENT_TYPE.CHAR_HIREDHAND, x-0.1, y, l)
		
		local sound = get_sound(VANILLA_SOUND.SHARED_COFFIN_BREAK)
		if sound ~= nil then sound:play() end
		
		generate_particles(PARTICLEEMITTER.COFFINDOORPOOF_SPARKS, players[1].uid)
	end},
	-- 12
	{"ITS JOEVER", "The boys brought gifts!", function()
		local x, y, l = get_position(players[1].uid)
		local boy1 = spawn_companion(ENT_TYPE.CHAR_HIREDHAND, x+0.2, y, l)
		local boy2 = spawn_companion(ENT_TYPE.CHAR_HIREDHAND, x-0.2, y, l)
		local boy3 = spawn_companion(ENT_TYPE.CHAR_HIREDHAND, x+0.1, y, l)
		local boy4 = spawn_companion(ENT_TYPE.CHAR_HIREDHAND, x-0.1, y, l)
		
		local sound = get_sound(VANILLA_SOUND.SHARED_COFFIN_BREAK)
		if sound ~= nil then sound:play() end
		
		generate_particles(PARTICLEEMITTER.COFFINDOORPOOF_SPARKS, players[1].uid)

		spawn_entity_over(ENT_TYPE.ITEM_BOMB, boy1, 0, 0)
		spawn_entity_over(ENT_TYPE.ITEM_BOMB, boy2, 0, 0)
		spawn_entity_over(ENT_TYPE.ITEM_BOMB, boy3, 0, 0)
		spawn_entity_over(ENT_TYPE.ITEM_BOMB, boy4, 0, 0)
	end},
	-- 13
	{"SLAP", "You got slapped! Don't worry, this won't kill you!", function()
		players[1].health = math.max(players[1].health - 1, 1)
		players[1].stun_timer = 60
		players[1].velocityy = 0.1
		if test_flag(players[1].flags, 17) then
			players[1].velocityx = -0.15
		else
			players[1].velocityx = 0.15
		end

		if not entity_has_item_type(players[1].uid, ENT_TYPE.FX_BIRDIES) then
			spawn_entity_over(ENT_TYPE.FX_BIRDIES, players[1].uid, 0, 0.5)
		end

		local sound = get_sound(VANILLA_SOUND.SHARED_DAMAGED)
		if sound ~= nil then sound:play() end
		
	end},
	-- 14
	{"FOOD", "Free food!", function()
		local x, y, l = get_position(players[1].uid)
		
		spawn(ENT_TYPE.ITEM_PICKUP_COOKEDTURKEY, x, y, l, 0, 0)
	end},
	-- 15
	{"DARKNESS", "Level is now dark!", function()
		if state.illumination ~= nil then
			set_interval(function()
				
				state.illumination.brightness = math.max(state.illumination.brightness-0.008, 0.2)
				
				if players[1] then
					local pp = get_entity(players[1].uid)
					pp.emitted_light.brightness = math.max(pp.emitted_light.brightness, 1)
					pp.emitted_light.flags = set_flag(pp.emitted_light.flags, 25)
				end
				
			end, 1)
		end
		
		local x, y, l = get_position(players[1].uid)
		
		local sound = get_sound(VANILLA_SOUND.SHARED_DARK_LEVEL_START)
		if sound ~= nil then sound:play() end
	end},
	-- 16
	{"TEMPLE", "I hope you like temple levels!", function()
		
		local floors = get_entities_by(0, MASK.FLOOR | MASK.ACTIVEFLOOR, LAYER.FRONT)
		local floorsToChange = math.min(#floors, 30)

		while floorsToChange > 0 do
			local floor = floors[math.random(1, #floors)]

			if (get_entity_type(floor) ~= ENT_TYPE.FLOOR_BORDERTILE and
			get_entity_type(floor) ~= ENT_TYPE.FLOOR_BORDERTILE_METAL and
			get_entity_type(floor) ~= ENT_TYPE.FLOOR_BORDERTILE_OCTOPUS) then
				local x, y, l = get_position(floor)
				kill_entity(floor)
				spawn(ENT_TYPE.ACTIVEFLOOR_CRUSH_TRAP, x, y, l, 0, 0)
			end

			floorsToChange = floorsToChange - 1
		end	
	end},
	-- 17
	{"SUNKEN CITY", "Regenerating blocks galore!", function()
		
		local floors = get_entities_by(0, MASK.FLOOR | MASK.ACTIVEFLOOR, LAYER.FRONT)
		local floorsToChange = math.min(#floors, 50)

		while floorsToChange > 0 do
			local floor = floors[math.random(1, #floors)]

			if (get_entity_type(floor) ~= ENT_TYPE.FLOOR_BORDERTILE and
			get_entity_type(floor) ~= ENT_TYPE.FLOOR_BORDERTILE_METAL and
			get_entity_type(floor) ~= ENT_TYPE.FLOOR_BORDERTILE_OCTOPUS) then
				local x, y, l = get_position(floor)
				kill_entity(floor)
				spawn(ENT_TYPE.ACTIVEFLOOR_REGENERATINGBLOCK, x, y, l, 0, 0)
			end

			floorsToChange = floorsToChange - 1
		end	
	end},
	-- 18
	{"KING", "Triple crown!", function()
		
		local sound = get_sound(VANILLA_SOUND.ITEMS_CLONE_GUN)
		if sound ~= nil then sound:play() end
				
		if not players[1]:has_powerup(ENT_TYPE.ITEM_POWERUP_CROWN) then
			players[1]:give_powerup(ENT_TYPE.ITEM_POWERUP_CROWN)
		end

		if not players[1]:has_powerup(ENT_TYPE.ITEM_POWERUP_EGGPLANTCROWN) then
			players[1]:give_powerup(ENT_TYPE.ITEM_POWERUP_EGGPLANTCROWN)
		end

		if not players[1]:has_powerup(ENT_TYPE.ITEM_POWERUP_TRUECROWN) then
			players[1]:give_powerup(ENT_TYPE.ITEM_POWERUP_TRUECROWN)
		end
	end},
	-- 19
	{"FARTBOMB", "You fart out bombs for 30 seconds!", function()
		-- give one second before all hell breaks loose
		set_timeout(function()
			local bombInstances = 15
		
			set_interval(function() 
				if bombInstances == 0 then
					clear_callback()
				end

				local x, y, l = get_position(players[1].uid)
				if test_flag(players[1].flags, 17) then
					spawn(ENT_TYPE.ITEM_BOMB, x+0.1, y, l, 0.1, 0)
				else
					spawn(ENT_TYPE.ITEM_BOMB, x-0.1, y, l, -0.1, 0)
				end

				bombInstances = bombInstances - 1
			end, 2 * 60)
		end, 60)
	end},
	-- 20
	{"MINIBOSS", "Watch out! Miniboss incoming!", function()
		local x, y, l = get_position(players[1].uid)

		-- give one second before all hell breaks loose
		set_timeout(function()
			local miniboss = spawn(enemies_miniboss[math.random(1, #enemies_miniboss)], x, y, l, 0, 0)
			generate_particles(PARTICLEEMITTER.LARGEITEMDUST, miniboss)
		end, 60)
	end},
	-- 21
	{"EGGPLANT", "Eat your vegetables!", function()
		local sound = get_sound(VANILLA_SOUND.ITEMS_CLONE_GUN)
		if sound ~= nil then sound:play() end

		local x, y, l = get_position(players[1].uid)
		spawn(ENT_TYPE.ITEM_EGGPLANT, x, y, l, 0, 0)
	end},
	-- 22
	{"SQUID GAMES", "The cosmic jelly has been summoned!", function()
		local sound = get_sound(VANILLA_SOUND.SHARED_COSMIC_ORB_DESTROY)
		if sound ~= nil then sound:play() end
		
		local x, y, l = get_position(players[1].uid)
		local direction = math.random(1,4)
		
		if direction == 1 then
			spawn(ENT_TYPE.MONS_MEGAJELLYFISH, x+20, y, l, 0, 0)
		elseif direction == 2 then
			spawn(ENT_TYPE.MONS_MEGAJELLYFISH, x-20, y, l, 0, 0)
		elseif direction == 3 then
			spawn(ENT_TYPE.MONS_MEGAJELLYFISH, x, y+20, l, 0, 0)
		else
			spawn(ENT_TYPE.MONS_MEGAJELLYFISH, x, y-20, l, 0, 0)
		end
	end},
	-- 23
	{"LAVA", "Lava pool incoming!", function()
		local x, y, l = get_position(players[1].uid)
		local lava_left = 20
		
		-- give one second before all hell breaks loose
		set_timeout(function()
			set_interval(function()
				if lava_left > 0 then
					spawn_liquid(ENT_TYPE.LIQUID_LAVA, x, y)
					lava_left = lava_left-1
				else
					clear_callback()
				end
			end, 15)
		end, 60)
	end},
	-- 24
	{"WATER", "Who doesn't like water levels?", function()
		local x, y, l = get_position(players[1].uid)
		local water_left = 40
		
		-- give one second before all hell breaks loose
		set_timeout(function()
			set_interval(function()
				if water_left > 0 then
					spawn_liquid(ENT_TYPE.LIQUID_WATER, x, y)
					water_left = water_left-1
				else
					clear_callback()
				end
			end, 15)
		end, 60)
	end},
	-- 25
	{"ICE CREAM", "Bing Qilin!", function()
		local sound = get_sound(VANILLA_SOUND.ITEMS_CLONE_GUN)
		if sound ~= nil then sound:play() end

		local x, y, l = get_position(players[1].uid)
		spawn(ENT_TYPE.MOUNT_QILIN, x, y, l, 0, 0)
	end},
	-- 26
	{"SHIELD WALL", "The boys brought shields!", function()
		local x, y, l = get_position(players[1].uid)
		local boy1 = spawn_companion(ENT_TYPE.CHAR_HIREDHAND, x+0.2, y, l)
		local boy2 = spawn_companion(ENT_TYPE.CHAR_HIREDHAND, x-0.2, y, l)
		local boy3 = spawn_companion(ENT_TYPE.CHAR_HIREDHAND, x+0.1, y, l)
		local boy4 = spawn_companion(ENT_TYPE.CHAR_HIREDHAND, x-0.1, y, l)
		
		local sound = get_sound(VANILLA_SOUND.SHARED_COFFIN_BREAK)
		if sound ~= nil then sound:play() end
		
		generate_particles(PARTICLEEMITTER.COFFINDOORPOOF_SPARKS, players[1].uid)

		pick_up(boy1, spawn(ENT_TYPE.ITEM_METAL_SHIELD, 0, 0, l, 0, 0))
		pick_up(boy2, spawn(ENT_TYPE.ITEM_METAL_SHIELD, 0, 0, l, 0, 0))
		pick_up(boy3, spawn(ENT_TYPE.ITEM_METAL_SHIELD, 0, 0, l, 0, 0))
		pick_up(boy4, spawn(ENT_TYPE.ITEM_METAL_SHIELD, 0, 0, l, 0, 0))
	end},
	-- 27
	{"YANG", "Free turkey... and Yang!", function()
		local x, y, l = get_position(players[1].uid)

		-- wait one second before all hell breaks loose
		set_timeout(function() 
			spawn_roomowner(ENT_TYPE.MONS_YANG, x, y, l, ROOM_TEMPLATE.SHOP)
			spawn_on_floor(ENT_TYPE.ITEM_PICKUP_COOKEDTURKEY, x-1, y, l)
		end, 60)
	end},
	--28
	{"SPIDERLUNKY", "With great power comes great responsibilunky!", function()
		if spiderlunkyDuration == -1 then
			spiderlunkyDuration = 30 * 60
		else
			spiderlunkyDuration = spiderlunkyDuration + 30 * 60
			return
		end

		set_pre_entity_spawn(function(entity_type, x, y, layer, overlay, spawn_flags)
			if spiderlunkyDuration <= 0 then
				return
			end

			local facingleft = 1
			if test_flag(players[1].flags, ENT_FLAG.FACING_LEFT) then
				facingleft = -1
			else
				facingleft = 1
			end

			local x, y, l = get_position(players[1].uid)
			local uid = spawn_entity(ENT_TYPE.ITEM_WEBSHOT, x, y, l, 0, 0)
			local ent = get_entity(uid)
			ent.user_data = { whip = true }
			players[1]:pick_up(ent)
			local xVelocity = math.random(30, 50)
			local yVelocity = math.random(50, 80)/1000

			if (facingleft == 1) then
				spawn_entity(ENT_TYPE.ITEM_GIANTSPIDER_WEBSHOT, x-.5, y, l, xVelocity*facingleft, yVelocity)
			else
				spawn_entity(ENT_TYPE.ITEM_GIANTSPIDER_WEBSHOT, x+.5, y, l, xVelocity*facingleft, yVelocity)
			end
		end, SPAWN_TYPE.ANY, MASK.ITEM, ENT_TYPE.ITEM_WHIP)

		set_callback(function()
			if spiderlunkyDuration <= 0 then
				return
			end

			local player = get_player(1, false)
			if player then
				local held_ent = player:get_held_entity()
				if held_ent and held_ent.type.id == ENT_TYPE.ITEM_WEBSHOT and held_ent.user_data and held_ent.user_data.whip then
					player:drop(held_ent)
					held_ent:destroy()
				end
			end
			spiderlunkyDuration = spiderlunkyDuration - 1
		end, ON.GAMEFRAME)
	end},
	-- 29
	{"SHOPKEEP", "Malding shopkeeper coming for you!", function()
		local x, y, l = get_position(players[1].uid)

		-- wait one second before all hell breaks loose
		set_timeout(function()
			spawn(ENT_TYPE.MONS_SHOPKEEPERCLONE, x, y, l, 0, 0)
		end, 60)
	end},
	-- 30
	{"TOURIST", "Snap me some good pictures!", function()
		disableCameraAfterTourist = true
		if touristDuration == -1 then
			touristDuration = 30 * 60
		else
			touristDuration = touristDuration + 30 * 60
			return
		end
		
		set_callback(function()
			if disableCameraAfterTourist == false then
				return
			end

			if touristDuration <= 0 then
				-- destroy camera
				disableCameraAfterTourist = false
				local player = get_player(1, false)
				if player then 
					local held_ent = player:get_held_entity()
					if held_ent and held_ent.type.id == ENT_TYPE.ITEM_CAMERA then
						player:drop(held_ent)
						held_ent:destroy()
					end
				end
				return
			end

			touristDuration = touristDuration - 1

			local player = get_player(1, false)
			if player then
				local held_ent = player:get_held_entity()
				if held_ent then
					if held_ent.type.id == ENT_TYPE.ITEM_CAMERA then
						return
					end
					player:drop(held_ent)
				end

				local cameras = get_entities_by(ENT_TYPE.ITEM_CAMERA, 0, LAYER.BOTH)
				if #cameras > 0 then
					player:pick_up(get_entity(cameras[1])) 
				else
					local x, y, l = get_position(players[1].uid)
					player:pick_up(get_entity(spawn_entity(ENT_TYPE.ITEM_CAMERA, x, y, l, 0, 0)))
				end
			end
		end, ON.GAMEFRAME)
	end},
	-- 31
	{"TELEPORTATION", "Warning! Teleporting randomly in one second...", function()
		local x, y, l = get_position(players[1].uid)

		-- wait one second before all hell breaks loose
		set_timeout(function()
			local direction = math.random(1,4)
			local distance = math.random(2,8)
		
			if direction == 1 then
				move_entity(players[1].uid, x+distance, y, 0, 0)
			elseif direction == 2 then
				move_entity(players[1].uid, x-distance, y, 0, 0)
			elseif direction == 3 then
				move_entity(players[1].uid, x, y+distance, 0, 0)
			else
				move_entity(players[1].uid, x, y-distance, 0, 0)
			end

			local sound = get_sound(VANILLA_SOUND.SHARED_TELEPORT)
			if sound ~= nil then sound:play() end
		end, 60)
	end},
	-- 32
	{"CLOWDER", "Who doesn't like cats?", function()
		local x, y, l = get_position(players[1].uid)

		-- wait half a second before all hell breaks loose
		set_timeout(function()
			spawn(ENT_TYPE.MONS_CATMUMMY, x+1, y, l, 0, 0)
			spawn(ENT_TYPE.MONS_CATMUMMY, x-1, y, l, 0, 0)
			spawn(ENT_TYPE.MONS_CATMUMMY, x, y, l, 0, 0)
			spawn(ENT_TYPE.MONS_CATMUMMY, x, y+1, l, 0, 0)
		end, 30)
	end},
	-- 33
	{"WALL", "Crush blocks appearing in one second! Escape or get crushed!", function()
		-- this is extremely sadistic and probably needs some balancing
		-- wait a second before all hell breaks loose
		set_timeout(function()
			local x, y, l = get_position(players[1].uid)

			fx = math.floor(x)
			fy = math.floor(y)
	
			spawn(ENT_TYPE.ACTIVEFLOOR_CRUSH_TRAP, fx-2, fy, l, 0, 0)
			spawn(ENT_TYPE.ACTIVEFLOOR_CRUSH_TRAP, fx-2, fy+1, l, 0, 0)
			spawn(ENT_TYPE.ACTIVEFLOOR_CRUSH_TRAP, fx-2, fy+2, l, 0, 0)
			spawn(ENT_TYPE.ACTIVEFLOOR_CRUSH_TRAP, fx+2, fy, l, 0, 0)
			spawn(ENT_TYPE.ACTIVEFLOOR_CRUSH_TRAP, fx+2, fy+1, l, 0, 0)
			spawn(ENT_TYPE.ACTIVEFLOOR_CRUSH_TRAP, fx+2, fy+2, l, 0, 0)
		end, 60)
	end},
	-- 34
	{"RESOURCE", "Resources will be randomized!", function()
		local player = get_player(1, false)

		local healthBucketRand = rand(100)
		if healthBucketRand <= 50 then
			player.health = rand(20)
		elseif healthBucketRand <= 75 then
			player.health = rand(20) + 20
		elseif healthBucketRand <= 87 then
			player.health = rand(20) + 40
		elseif healthBucketRand <= 94 then
			player.health = rand(20) + 60
		else
			player.health = math.min(rand(20) + 80, 99)
		end

		local bombsBucketRand = rand(100)
		if bombsBucketRand <= 50 then
			player.inventory.bombs = rand(20) - 1
		elseif bombsBucketRand <= 75 then
			player.inventory.bombs = rand(20) + 19
		elseif bombsBucketRand <= 87 then
			player.inventory.bombs = rand(20) + 39
		elseif bombsBucketRand <= 94 then
			player.inventory.bombs = rand(20) + 59
		else
			player.inventory.bombs = rand(20) + 79
		end

		local ropesBucketRand = rand(100)
		if ropesBucketRand <= 50 then
			player.inventory.ropes = rand(20) - 1
		elseif ropesBucketRand <= 75 then
			player.inventory.ropes = rand(20) + 19
		elseif ropesBucketRand <= 87 then
			player.inventory.ropes = rand(20) + 39
		elseif ropesBucketRand <= 94 then
			player.inventory.ropes = rand(20) + 59
		else
			player.inventory.ropes = rand(20) + 79
		end
	end},
	-- 35
	{"MORSHU", "Lamp oil? Rope? Bombs? You want it? Come back when you're a little MMMM... richer!", function()
		local x, y, l = get_position(players[1].uid)

		local morshu = spawn_roomowner(ENT_TYPE.MONS_YANG, x, y, l, ROOM_TEMPLATE.SHOP)

		local box = spawn_on_floor(ENT_TYPE.ITEM_PICKUP_BOMBBOX, x-1, y, l)
		add_item_to_shop(box, morshu)
		local box_ent = get_entity(box)
		box_ent.price = 15000

		local ropes = spawn_on_floor(ENT_TYPE.ITEM_PICKUP_ROPEPILE, x-2, y, l)
		add_item_to_shop(ropes, morshu)
		local ropes_ent = get_entity(ropes)
		ropes_ent.price = 3750

		local lamp = spawn_on_floor(ENT_TYPE.ITEM_LAMP, x+1, y, l)
		add_item_to_shop(lamp, morshu)
		local lamp_ent = get_entity(lamp)
		-- lamp is not purchasable so we set an absurdly high price. well, oil prices are insane these days
		lamp_ent.price = 999999

		local present = spawn_on_floor(ENT_TYPE.ITEM_PRESENT, x-3, y, l)
		add_item_to_shop(present, morshu)
		local present_ent = get_entity(present)
		present_ent.price = 12000
	end}
	-- 30
	-- doesn't work sadge
	-- {"AMOGUS", "Someone is sus!", function()
	-- 	local x, y, l = get_position(players[1].uid)
	-- 	local boy1 = spawn_companion(ENT_TYPE.CHAR_HIREDHAND, x+0.2, y, l)
	-- 	local boy2 = spawn_companion(ENT_TYPE.CHAR_HIREDHAND, x-0.2, y, l)
	-- 	local boy3 = spawn_companion(ENT_TYPE.CHAR_HIREDHAND, x+0.1, y, l)
	-- 	local boy4 = spawn_companion(ENT_TYPE.CHAR_HIREDHAND, x-0.1, y, l)
	-- 	local boys = {boy1, boy2, boy3, boy4}
		
	-- 	local sound = get_sound(VANILLA_SOUND.SHARED_COFFIN_BREAK)
	-- 	if sound ~= nil then sound:play() end

	-- 	generate_particles(PARTICLEEMITTER.COFFINDOORPOOF_SPARKS, players[1].uid)

	-- 	local i = rand(4)
	-- 	local challenger = get_entity(boys[i])
	-- 	challenger.more_flags = set_flag(challenger.more_flags, 2)
	-- end}
}

function module.parse_chat(NAME, MSG)
	if MSG == "the magic button" then
		local player = get_player(1, false)
		if player then
			-- do nothing
		else
			-- probably in transition from stage 6 to 7, which can crash game, so don't allow events
			return
		end
		local event = tier1Events[rand(#tier1Events)]
		-- event = tier1Events[35]
		announcementText = NAME .. " has rolled " .. event[1] .. "! " .. event[2]
		event[3]()

		set_global_timeout(function()
			announcementText = ""
		end, 300)
	end
end

function ease_out_cubic(_x)
	
	return (1 - (1-_x ^ 3));
	
end

function fadeinout(_current, _min, _max, _falloff)
	
	local _diff_max = math.abs(_max - _current) / _falloff
	local _diff_min = math.abs(_min - _current) / _falloff
	
	return ease_out_cubic(1 - math.min(1, _diff_min, _diff_max))
	
end

set_callback(function(draw_ctx)

	function draw_ui_text(_text, _x, _y, _scale, _fontstyle, _color)
		
		draw_ctx:draw_text(_text, _x + 0.004, _y - 0.004, _scale, _scale, black, VANILLA_TEXT_ALIGNMENT.CENTER, _fontstyle)
		draw_ctx:draw_text(_text, _x + 0.0, _y + 0.0, _scale, _scale, _color, VANILLA_TEXT_ALIGNMENT.CENTER, _fontstyle)
	
	end

	if announcementText == "" then
		-- do nothing
	else
		local y_off = 0.0
		draw_ctx:draw_screen_texture(TEXTURE.DATA_TEXTURES_HUD_TEXT_0, 1, -1, -1, -0.6 + y_off, 1, -1.0 + y_off, bgopaque)
		draw_ui_text(announcementText, 0.0, -0.7 + y_off, 0.00089, bold, white)
	end
end, ON.RENDER_POST_HUD)

return module