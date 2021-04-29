/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/h2/axe.hc,v 1.2 2007-02-07 16:56:55 sezero Exp $
 */

/*
==============================================================================

Q:\art\models\weapons\axe\final\axe.hc

==============================================================================
*/

// For building the model
$cd Q:\art\models\weapons\axe\final
$origin 10 -10 10
$base BASE skin
$skin skin
$flags 0

$frame AxeRoot1

$frame 1stAxe1      1stAxe2      1stAxe3      1stAxe4      1stAxe5
$frame 1stAxe6      1stAxe7      1stAxe8      
$frame 1stAxe11     1stAxe12     1stAxe14     
$frame 1stAxe15     1stAxe17     1stAxe18          
$frame 1stAxe21     1stAxe22     1stAxe23
$frame 1stAxe25     1stAxe27     


float AXE_DAMAGE			= 24;
float AXE_ADD_DAMAGE		= 6;
float AXE_THROW_COST		= 4;
float AXE_THROW_TOMECOST	= 3;

void() T_PhaseMissileTouch;

void axeblade_gone(void)
{
	sound (self, CHAN_VOICE, "misc/null.wav", 1, ATTN_NORM);
	sound (self, CHAN_WEAPON, "misc/null.wav", 1, ATTN_NORM);

	if (self.skin==0)
		CreateLittleWhiteFlash(self.origin);
	else
		CreateLittleBlueFlash(self.origin);

	remove(self.goalentity);
	remove(self);
}

void axeblade_run (void) [ ++ 0 .. 5]
{
//dvanceFrame(0,5);
	if (self.lifetime < time)
		axeblade_gone();
}


void axetail_run (void)
{
	if(!self.owner)
		remove(self);
	else
	{
		self.origin = self.owner.origin;
		self.velocity = self.owner.velocity;
		self.owner.angles = vectoangles(self.velocity);
		self.angles = self.owner.angles;
		self.origin = self.owner.origin;
	}
}


void launch_axtail (entity axeblade)
{
	local entity tail;

	tail = spawn ();
	tail.movetype = MOVETYPE_NOCLIP;
	tail.solid = SOLID_NOT;
	tail.classname = "ax_tail";
	setmodel (tail, "models/axtail.mdl");
	setsize (tail, '0 0 0', '0 0 0');		
	tail.drawflags (+)DRF_TRANSLUCENT;

	tail.owner = axeblade;
	tail.origin = tail.owner.origin;
	tail.velocity = tail.owner.velocity;
    tail.angles = tail.owner.angles;

	axeblade.goalentity = tail;

}


void launch_axe (vector dir_mod,vector angle_mod, float damg, float tome)
{
	entity missile;

	self.attack_finished = time + 0.4;

	missile = spawn ();

	CreateEntityNew(missile,ENT_AXE_BLADE,"models/axblade.mdl",SUB_Null);

	missile.owner = self;
	missile.classname = "ax_blade";
		
	// set missile speed	
	makevectors (self.v_angle + dir_mod);
	missile.velocity = normalize(v_forward);
	missile.velocity = missile.velocity * 900;
	
	missile.touch = T_PhaseMissileTouch;

	// Point it in the proper direction
    missile.angles = vectoangles(missile.velocity);
	missile.angles += angle_mod;

	// set missile duration
	missile.counter = 4;  // Can hurt two things before disappearing
	missile.cnt = 0;		// Counts number of times it has hit walls
	missile.lifetime = time + 2;  // Or lives for 2 seconds and then dies when it hits anything

	setorigin (missile, self.origin + self.proj_ofs  + v_forward*10 + v_right * 1);

//sound (missile, CHAN_VOICE, "paladin/axblade.wav", 1, ATTN_NORM);

	if (tome)
	{
		missile.frags=TRUE;
		missile.classname = "powerupaxeblade";
		missile.skin = 1;
		missile.drawflags = (self.drawflags & MLS_MASKOUT)| MLS_POWERMODE;
	}
	else
		missile.classname = "axeblade";
	
	missile.dmg = damg;

	missile.lifetime = time + 2;
	thinktime missile : HX_FRAME_TIME;
	missile.think = axeblade_run;

	launch_axtail(missile);

}

/*
================
FireSlamMelee
================
*/
void FireSlamExplode(vector spot)
{
	float damg;
	float wismod;

	//FIXME: For some reason, the light casting effects in Hex2
	//are a lot more costly than they were in Quake...
	/*if(self.classname=="stickmine")
	{
		SprayFire();
		return;
	}*/
	
	wismod = self.wisdom;
	damg = random(wismod * 4, wismod * 8);

	T_RadiusDamage (self, self, damg, world);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, spot_x);
	WriteCoord (MSG_BROADCAST, spot_y);
	WriteCoord (MSG_BROADCAST, spot_z);

	starteffect(CE_LG_EXPLOSION, spot);
}

void FireSlamMelee (float damage_base,float damage_mod,float attack_radius)
{
	vector	source;
	vector	org;
	float damg, backstab;
	
	damg = random(damage_mod+damage_base,damage_base);

	makevectors (self.v_angle);
	source = self.origin+self.proj_ofs;
	traceline (source, source + v_forward*64, FALSE, self);

	if (trace_fraction == 1.0)
	{
		traceline (source, source + v_forward*64 - (v_up * 30), FALSE, self);  // 30 down
		if (trace_fraction == 1.0)
		{
			traceline (source, source + v_forward*64 + v_up * 30, FALSE, self);  // 30 up
			if (trace_fraction == 1.0)
				return;
		}
	}

	self.whiptime = -1;

	org = trace_endpos + (v_forward * 4);

	if (trace_ent.takedamage)
	{
		SpawnPuff (org, '0 0 0', damg,trace_ent);
		T_Damage (trace_ent, self, self, damg);
		if(!(trace_ent.flags2 & FL_ALIVE) && backstab)
		{
			dprint("Backstab from combat.hc");
			centerprint(self,"Critical Hit Backstab!\n");
			AwardExperience(self,trace_ent,10);
		}
	}
	else
	{	// hit wall
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}

	if (self.greenmana > 10)
	{
		self.greenmana -= 10;
		org = trace_endpos + (v_forward * -1);
		org += '0 0 10';
		FireSlamExplode(org);
	}
	else
	{
		if(trace_ent.thingtype==THINGTYPE_FLESH)
			sound (self, CHAN_WEAPON, "weapons/slash.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_WEAPON, "weapons/hitwall.wav", 1, ATTN_NORM);
	}
}

/*
================
axeblade_slam_fire
================
*/
void axeblade_slam_fire (void)
{
	float strmod, wismod;
	
	strmod = self.strength;
	wismod = self.wisdom;
	
	FireSlamMelee (strmod * 0.75, strmod * 2 ,64);
}

/*
================
axeblade_fire
================
*/
void(float rightclick, float tome) axeblade_fire =
{
	float damg;
	float strmod, wismod;
	
	strmod = self.strength;
	wismod = self.wisdom;
	
	if (rightclick)
	{
		damg = 20 + random(wismod, wismod * 3);
		if (tome && self.greenmana >= AXE_THROW_COST + AXE_THROW_TOMECOST)
		{
			sound (self, CHAN_WEAPON, "paladin/axgenpr.wav", 1, ATTN_NORM);

			launch_axe('0 0 0','0 0 0', damg, tome);	// Middle

			launch_axe('0 5 0','0 0 0', damg, tome);    // Side
			launch_axe('0 -5 0','0 0 0', damg, tome);   // Side

			self.greenmana -= AXE_THROW_COST + AXE_THROW_TOMECOST;
		}
		else if (self.greenmana >= AXE_THROW_COST)
		{
			sound (self, CHAN_WEAPON, "paladin/axgen.wav", 1, ATTN_NORM);

			launch_axe('0 0 0','0 0 300', damg, tome);
			self.greenmana -= AXE_THROW_COST;
		}
		
	}
	FireMelee (strmod * 0.75, strmod * 2 ,64); //keep average around str * 2 but give an upper critical hit
};

void axe_ready (void)
{
	self.th_weapon=axe_ready;
	self.weaponframe = $AxeRoot1;
}

void axe_select (void)
{
	self.wfs = advanceweaponframe($1stAxe18,$1stAxe3);
	if (self.weaponframe == $1stAxe14)
		sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1, ATTN_NORM);

	self.weaponmodel = "models/axe.mdl";
	self.th_weapon=axe_select;
	self.last_attack=time;

	if (self.wfs == WF_LAST_FRAME)
	{
		self.attack_finished = time - 1;
		axe_ready();
	}
}

void axe_deselect (void)
{
	self.wfs = advanceweaponframe($1stAxe18,$1stAxe3);
	self.th_weapon=axe_deselect;
	self.oldweapon = IT_WEAPON3;

	if (self.wfs == WF_LAST_FRAME)
		W_SetCurrentAmmo();
}

/*
Free Action Slam Attack
*/
void axe_c ()
{
	if (self.weaponframe != $1stAxe15 || self.whiptime <= time)
	{
		self.wfs = advanceweaponframe($1stAxe1,$1stAxe25);
	}

	self.th_weapon = axe_c;

	// These frames are used during selection animation
	if ((self.weaponframe >= $1stAxe2) && (self.weaponframe <= $1stAxe4))
		self.weaponframe +=1;
	else if ((self.weaponframe >= $1stAxe6) && (self.weaponframe <= $1stAxe7))
		self.weaponframe +=1;

	if (self.weaponframe == $1stAxe14)
	{
		//slam attack
		sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1, ATTN_NORM);

		self.velocity_z+=-250;
		self.flags(-)FL_ONGROUND;
		self.angles_x = 67.5;
		CameraViewAngles(self,self);
		self.whiptime = time + 0.5;
	}

	if (self.weaponframe == $1stAxe15)
	{
		
		axeblade_slam_fire();
	}

	if (self.wfs == WF_LAST_FRAME)
		axe_ready();
	
	self.attack_finished = time + .05;
}

void axe_b ()
{
	float tome;
	

	self.wfs = advanceweaponframe($1stAxe1,$1stAxe25);
	self.th_weapon = axe_b;

	// These frames are used during selection animation
	if ((self.weaponframe >= $1stAxe2) && (self.weaponframe <= $1stAxe4))
		self.weaponframe +=1;
	else if ((self.weaponframe >= $1stAxe6) && (self.weaponframe <= $1stAxe7))
		self.weaponframe +=1;

	if (self.weaponframe == $1stAxe15)
	{
		sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1, ATTN_NORM);

		tome = self.artifact_active & ART_TOMEOFPOWER;
		
		axeblade_fire(TRUE, tome);			
	}

	if (self.wfs == WF_LAST_FRAME)
		axe_ready();
	
	if (tome)
  		self.attack_finished = time + .7; //normal frames for throw
	else
  		self.attack_finished = time + .35;
}

void axe_a ()
{
	float tome;
	
	self.wfs = advanceweaponframe($1stAxe1,$1stAxe25);
	self.th_weapon = axe_a;

	// These frames are used during selection animation
	if ((self.weaponframe >= $1stAxe2) && (self.weaponframe <= $1stAxe4))
		self.weaponframe +=1;
	else if ((self.weaponframe >= $1stAxe6) && (self.weaponframe <= $1stAxe7))
		self.weaponframe +=1;

	if (self.weaponframe == $1stAxe15)
	{
		sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1, ATTN_NORM);

		tome = self.artifact_active & ART_TOMEOFPOWER;
		
		axeblade_fire(FALSE, tome);			
	}

	if (self.wfs == WF_LAST_FRAME)
		axe_ready();
	
	//regular melee attacks are fast
	if (tome)
  		self.attack_finished = time + .3;
	else
  		self.attack_finished = time + .05;
}

void pal_axe_fire()
{
	float rightclick;
	
	rightclick = self.button1;
	
	if (IsFreeActionAttack(self) && rightclick)
		axe_c();
	else if (rightclick)
		axe_b();
	else
		axe_a();
}

