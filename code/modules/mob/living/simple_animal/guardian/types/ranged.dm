//Ranged
/obj/item/projectile/guardian
	name = "crystal spray"
	icon_state = "guardian"
	damage = 5
	damage_type = BRUTE
	armour_penetration = 100

/mob/living/simple_animal/hostile/guardian/ranged
	a_intent = "help"
	friendly = "quietly assesses"
	melee_damage_lower = 10
	melee_damage_upper = 10
	damage_coeff = list(BRUTE = 0.9, BURN = 0.9, TOX = 0.9, CLONE = 0.9, STAMINA = 0, OXY = 0.9)
	projectiletype = /obj/item/projectile/guardian
	ranged_cooldown_time = 1 //fast!
	projectilesound = 'sound/effects/hit_on_shattered_glass.ogg'
	ranged = 1
	range = 13
	playstyle_string = "<span class='holoparasite'>As a <b>ranged</b> type, you have only light damage resistance, but are capable of spraying shards of crystal at incredibly high speed. You can also deploy surveillance snares to monitor enemy movement. Finally, you can switch to scout mode, in which you can't attack, but can move without limit.</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the Sentinel, an alien master of ranged combat.</span>"
	tech_fluff_string = "<span class='holoparasite'>Boot sequence complete. Ranged combat modules active. Holoparasite swarm online.</span>"
	see_invisible = SEE_INVISIBLE_LIVING
	see_in_dark = 8
	toggle_button_type = /obj/screen/guardian/ToggleMode
	var/list/snares = list()
	var/toggle = FALSE

/mob/living/simple_animal/hostile/guardian/ranged/ToggleMode()
	if(src.loc == summoner)
		if(toggle)
			ranged = 1
			melee_damage_lower = 10
			melee_damage_upper = 10
			environment_smash = initial(environment_smash)
			alpha = 255
			range = 13
			incorporeal_move = 0
			src << "<span class='danger'><B>You switch to combat mode.</span></B>"
			toggle = FALSE
		else
			ranged = 0
			melee_damage_lower = 0
			melee_damage_upper = 0
			environment_smash = 0
			alpha = 45
			range = 255
			incorporeal_move = 1
			src << "<span class='danger'><B>You switch to scout mode.</span></B>"
			toggle = TRUE
	else
		src << "<span class='danger'><B>You have to be recalled to toggle modes!</span></B>"

/mob/living/simple_animal/hostile/guardian/ranged/Shoot(atom/targeted_atom)
	. = ..()
	if(istype(., /obj/item/projectile))
		var/obj/item/projectile/P = .
		if(namedatum)
			P.color = namedatum.colour

/mob/living/simple_animal/hostile/guardian/ranged/ToggleLight()
	if(see_invisible == SEE_INVISIBLE_MINIMUM)
		src << "<span class='notice'>You deactivate your night vision.</span>"
		see_invisible = SEE_INVISIBLE_LIVING
	else
		src << "<span class='notice'>You activate your night vision.</span>"
		see_invisible = SEE_INVISIBLE_MINIMUM

/mob/living/simple_animal/hostile/guardian/ranged/verb/Snare()
	set name = "Set Surveillance Snare"
	set category = "Guardian"
	set desc = "Set an invisible snare that will alert you when living creatures walk over it. Max of 5"
	if(src.snares.len <6)
		var/turf/snare_loc = get_turf(src.loc)
		var/obj/item/effect/snare/S = new /obj/item/effect/snare(snare_loc)
		S.spawner = src
		S.name = "[get_area(snare_loc)] snare ([rand(1, 1000)])"
		src.snares |= S
		src << "<span class='danger'><B>Surveillance snare deployed!</span></B>"
	else
		src << "<span class='danger'><B>You have too many snares deployed. Remove some first.</span></B>"

/mob/living/simple_animal/hostile/guardian/ranged/verb/DisarmSnare()
	set name = "Remove Surveillance Snare"
	set category = "Guardian"
	set desc = "Disarm unwanted surveillance snares."
	var/picked_snare = input(src, "Pick which snare to remove", "Remove Snare") as null|anything in src.snares
	if(picked_snare)
		src.snares -= picked_snare
		qdel(picked_snare)
		src << "<span class='danger'><B>Snare disarmed.</span></B>"

/obj/item/effect/snare
	name = "snare"
	desc = "You shouldn't be seeing this!"
	var/mob/living/simple_animal/hostile/guardian/spawner
	invisibility = 101


/obj/item/effect/snare/Crossed(AM as mob|obj)
	if(isliving(AM) && spawner && spawner.summoner && AM != spawner && !spawner.hasmatchingsummoner(AM))
		spawner.summoner << "<span class='danger'><B>[AM] has crossed surveillance snare, [name].</span></B>"
		var/list/guardians = spawner.summoner.hasparasites()
		for(var/para in guardians)
			para << "<span class='danger'><B>[AM] has crossed surveillance snare, [name].</span></B>"