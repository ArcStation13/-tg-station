//Charger
/mob/living/simple_animal/hostile/guardian/charger
	melee_damage_lower = 15
	melee_damage_upper = 15
	ranged = 1 //technically
	ranged_message = "charges"
	ranged_cooldown_time = 50
	speed = -1
	damage_coeff = list(BRUTE = 0.6, BURN = 0.6, TOX = 0.6, CLONE = 0.6, STAMINA = 0, OXY = 0.6)
	playstyle_string = "<span class='holoparasite'>As a <b>charger</b> type you do medium damage, have medium damage resistance, move very fast, and can charge at a location, damaging any target hit and forcing them to drop any items they are holding.</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the Hunter, an alien master of rapid assault.</span>"
	tech_fluff_string = "<span class='holoparasite'>Boot sequence complete. Charge modules loaded. Holoparasite swarm online.</span>"
	var/charging = 0
	var/obj/screen/alert/chargealert

/mob/living/simple_animal/hostile/guardian/charger/Life()
	..()
	if(ranged_cooldown <= world.time)
		if(!chargealert)
			chargealert = throw_alert("charge", /obj/screen/alert/cancharge)
	else
		clear_alert("charge")
		chargealert = null

/mob/living/simple_animal/hostile/guardian/charger/OpenFire(atom/A)
	if(!charging)
		visible_message("<span class='danger'><b>[src]</b> [ranged_message] at [A]!</span>")
		ranged_cooldown = world.time + ranged_cooldown_time
		clear_alert("charge")
		chargealert = null
		Shoot(A)

/mob/living/simple_animal/hostile/guardian/charger/Shoot(atom/targeted_atom)
	charging = 1
	throw_at(targeted_atom, range, 1, src, 0)
	charging = 0

/mob/living/simple_animal/hostile/guardian/charger/Move()
	if(charging)
		PoolOrNew(/obj/effect/overlay/temp/decoy, list(loc,src))
	. = ..()

/mob/living/simple_animal/hostile/guardian/charger/snapback()
	if(!charging)
		..()

/mob/living/simple_animal/hostile/guardian/charger/throw_impact(atom/A)
	if(!charging)
		return ..()

	else if(A)
		if(isliving(A) && A != summoner)
			var/mob/living/L = A
			var/blocked = 0
			if(hasmatchingsummoner(A)) //if the summoner matches don't hurt them
				blocked = 1
			if(ishuman(A))
				var/mob/living/carbon/human/H = A
				if(H.check_shields(90, "the [name]", src, attack_type = THROWN_PROJECTILE_ATTACK))
					blocked = 1
			if(!blocked)

				L.drop_r_hand()
				L.drop_l_hand()
				L.visible_message("<span class='danger'>[src] slams into [L]!</span>", "<span class='userdanger'>[src] slams into you!</span>")
				L.apply_damage(20, BRUTE)

		charging = 0

