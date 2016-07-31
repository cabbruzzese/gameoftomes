/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/h2/monsters.hc,v 1.2 2007-02-07 16:57:07 sezero Exp $
 */
/* ALL MONSTERS SHOULD BE 1 0 0 IN COLOR */

// name =[framenum,	nexttime, nextthink] {code}
// expands to:
// name ()
// {
//		self.frame=framenum;
//		self.nextthink = time + nexttime;
//		self.think = nextthink
//		<code>
// };


/*
================
monster_use

Using a monster makes it angry at the current activator
================
*/
void() monster_use =
{
	if (self.enemy)
		return;
	if (self.health <= 0)
		return;
	if (activator.items & IT_INVISIBILITY)
		return;
	if (activator.flags & FL_NOTARGET)
		return;
	if (activator.classname != "player")
		return;
	
	if(self.classname=="monster_mezzoman"&&!visible(activator)&&!self.monster_awake)
	{
		self.enemy=activator;
		mezzo_choose_roll(activator);
		return;
	}
// delay reaction so if the monster is teleported, its sound is still
// heard
	else
	{
		self.enemy = activator;
		thinktime self : 0.1;
		self.think = FoundTarget;
	}
};

/*
================
monster_death_use

When a mosnter dies, it fires all of its targets with the current
enemy as activator.
================
*/
void() monster_death_use =
{
// fall to ground
	self.flags(-)FL_FLY;
	self.flags(-)FL_SWIM;

	if (!self.target)
		return;

	activator = self.enemy;
	SUB_UseTargets ();
};


//============================================================================

void() walkmonster_start_go =
{
	sdprint("Summon monster start GO", FALSE);
	
	if(!self.touch)
		self.touch=obj_push;

	if(!self.spawnflags&NO_DROP)
	{
		self.origin_z = self.origin_z + 1;	// raise off floor a bit
		droptofloor();
		if (!walkmove(0,0, FALSE))
		{
			if(self.flags2&FL_SUMMONED)
			{
				remove(self);
				return; /* THOMAS: return  was missing here */
			}
			else
			{
				dprint ("walkmonster in wall at: ");
				dprint (vtos(self.origin));
				dprint ("\n");
			}
		}
		if(self.model=="model/spider.mdl"||self.model=="model/scorpion.mdl")
			pitch_roll_for_slope('0 0 0');
	}

	if(!self.ideal_yaw)
	{
//		dprint("no preset ideal yaw\n");
		self.ideal_yaw = self.angles * '0 1 0';
	}
	
	if (!self.yaw_speed)
		self.yaw_speed = 20;

	if(self.view_ofs=='0 0 0')
		self.view_ofs = '0 0 25';

	if(self.proj_ofs=='0 0 0')
		self.proj_ofs = '0 0 25';

	if(!self.use)
		self.use = monster_use;

	if(!self.flags&FL_MONSTER)
		self.flags(+)FL_MONSTER;
	
	if(self.flags&FL_MONSTER&&self.classname=="player_sheep")
		self.flags(-)FL_MONSTER;

	if (self.target)
	{
		sdprint("Summon monster start GO - Has a target", FALSE);
			
		self.goalentity = self.pathentity = find(world, targetname, self.target);
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		if (!self.pathentity)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
// this used to be an objerror
/*		if(self.spawnflags&PLAY_DEAD&&self.th_possum!=SUB_Null)
		{
			self.think=self.th_possum;
			thinktime self : 0;
		}
		else
*/
		if (self.pathentity.classname == "path_corner")
			self.th_walk ();
		else
		{
			self.pausetime = 99999999;
			self.th_stand ();
		}
	}
	else
	{
		sdprint("Summon monster start GO - no target found. Standing", FALSE);
/*		if(self.spawnflags&PLAY_DEAD&&self.th_possum!=SUB_Null)
		{
			self.think=self.th_possum;
			thinktime self : 0;
		}
		else 
		{
*/
			self.pausetime = 99999999;
			self.th_stand ();
//		}
	}

// spread think times so they don't all happen at same time
	self.nextthink+=random(0.5);
};

void() walkmonster_start =
{
// delay drop to floor to make sure all doors have been spawned
// spread think times so they don't all happen at same time
	self.takedamage=DAMAGE_YES;
	self.flags2(+)FL_ALIVE;

	if(self.scale<=0)
		self.scale=1;

	self.nextthink+=random(0.5);
	self.think = walkmonster_start_go;
	total_monsters = total_monsters + 1;
};



/*
void() flymonster_start_go =
{
	self.takedamage = DAMAGE_YES;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;

	if(self.view_ofs=='0 0 0');
		self.view_ofs = '0 0 24';
	if(self.proj_ofs=='0 0 0');
		self.proj_ofs = '0 0 24';

	self.use = monster_use;

	self.flags(+)FL_FLY;
	self.flags(+)FL_MONSTER;

	if(!self.touch)
		self.touch=obj_push;

	if (!walkmove(0,0, FALSE))
	{
		dprint ("flymonster in wall at: ");
		dprint (vtos(self.origin));
		dprint ("\n");
	}

	if (self.target)
	{
		self.goalentity = self.pathentity = find(world, targetname, self.target);
		if (!self.pathentity)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
// this used to be an objerror
//		if(self.spawnflags&PLAY_DEAD&&self.th_possum!=SUB_Null)
//		{
//			self.think=self.th_possum;
//			thinktime self : 0;
//		}
//		else

		if (self.pathentity.classname == "path_corner")
			self.th_walk ();
		else
		{
			self.pausetime = 99999999;
			self.th_stand ();
		}
	}
	else
	{
//		if(self.spawnflags&PLAY_DEAD&&self.th_possum!=SUB_Null)
//		{
//			self.think=self.th_possum;
//			thinktime self : 0;
//		}
//		else 
//		{

			self.pausetime = 99999999;
			self.th_stand ();
//		}
	}
};

void() flymonster_start =
{
// spread think times so they don't all happen at same time
	self.takedamage=DAMAGE_YES;
	self.flags2(+)FL_ALIVE;
	self.nextthink+=random(0.5);
	self.think = flymonster_start_go;
	total_monsters = total_monsters + 1;
};

void() swimmonster_start_go =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}

	if(!self.touch)
		self.touch=obj_push;

	self.takedamage = DAMAGE_YES;
	total_monsters = total_monsters + 1;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;

	if(self.view_ofs=='0 0 0');
		self.view_ofs = '0 0 10';
	if(self.proj_ofs=='0 0 0');
		self.proj_ofs = '0 0 10';

	self.use = monster_use;
	
	self.flags(+)FL_SWIM;
	self.flags(+)FL_MONSTER;

	if (self.target)
	{
		self.goalentity = self.pathentity = find(world, targetname, self.target);
		if (!self.pathentity)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
// this used to be an objerror
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		self.th_walk ();
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}

// spread think times so they don't all happen at same time
	self.nextthink+=random(0.5);
};

void() swimmonster_start =
{
// spread think times so they don't all happen at same time
	self.takedamage=DAMAGE_YES;
	self.flags2(+)FL_ALIVE;
	self.nextthink+=random(0.5);
	self.think = swimmonster_start_go;
	total_monsters = total_monsters + 1;
};
*/

//Make monster larger and stronger
void ApplyLargeMonster(entity monst)
{
	entity oself;
	float sizescale;
	float oldheight, newheight;
	vector newmins, newmaxs, newoffs1, newoffs2;

	oself = self; //swap self for scope
	self = monst;
		
	sizescale = random(1.2, 1.8); 
	self.scale = self.scale * sizescale;
	
	newmins = self.mins * sizescale;
	newmaxs = self.maxs * sizescale;

	oldheight = fabs(self.mins_y) + self.maxs_y;
	newheight = fabs(newmins_y) + newmaxs_y;
	
	newoffs1 = self.view_ofs * sizescale;
	newoffs2 = self.proj_ofs * sizescale;
	
	/*
	dprintv("Mins: %s - ", self.mins);
	dprintv("%s | Maxs: ", newmins);
	dprintv("%s - ", self.maxs);
	dprintv("%s | View Ofs: ", newmaxs);
	dprintv("%s - ", self.view_ofs);
	dprintv("%s | Proj Ofs: ", newoffs1);
	dprintv("%s - ", self.proj_ofs);
	dprintv("%s \n", newoffs2);
	*/
	
	if (self.movetype == MOVETYPE_FLY)
		self.drawflags(+)SCALE_ORIGIN_CENTER;
	else
		self.drawflags(+)SCALE_ORIGIN_BOTTOM;
	
	self.scale=sizescale;
	setsize (monst, newmins, newmaxs);
	self.view_ofs = newoffs1;
	self.proj_ofs = newoffs2;
	
	self.speed *= sizescale;
	
	self.max_health *= sizescale;
	self.health *= sizescale;
	self.experience_value *= sizescale;
	
	//no less than henchman	
	if (self.monsterclass < CLASS_HENCHMAN)
		self.monsterclass = CLASS_HENCHMAN;
	
	self = oself; //restore scope
}

void ApplyLeaderMonster(entity monst)
{
	entity oself;
	
	oself = self;
	self = monst;
	
	self.health *= 1.5;
	self.effects(+)EF_TORCHLIGHT;
	
	if (self.movetype == MOVETYPE_FLY)
		self.drawflags(+)SCALE_ORIGIN_CENTER;
	else
		self.drawflags(+)SCALE_ORIGIN_BOTTOM;
	self.scale = 1.25;
	
	//spawn helpers
	cube_of_force(self);
	if (random(2) < 1)
	{
		cube_of_force(self);		
	}
	
	if (self.monsterclass < CLASS_LEADER)
		self.monsterclass = CLASS_LEADER;

	
	self = oself;
}

//make monster invisible and fast
void ApplySpectreMonster(entity monst)
{
	entity oself;
	
	oself = self;
	self = monst;
		
	self.drawflags(+)DRF_TRANSLUCENT|MLS_ABSLIGHT;
	self.speed *= 1.75;
	self.experience_value *= 1.5;
	
	self = oself; //restore scope
}

float BUFF_RANDMIN_MIN = 0;
float BUFF_RANDMIN_MAX = 30;
float BUFF_LARGE_THRESHHOLD = 83; //17% chance
float BUFF_LEADER_THRESHHOLD = 95;
float BUFF_SPECTRE_THRESHHOLD = 91;
void ApplyMonsterBuff(entity monst, float canBeLeader)
{
	float randmin, randmax, randval;
	randmax = 100;
	
	monst.bufftype = BUFFTYPE_NORMAL;
	
	//respawn monsters have higher chance of becoming special.
	//  by increasing the min, the total spread reduces leaving the special monsters intact;
	randmin = monst.killerlevel;
	
	//clamp value
	if (randmin < BUFF_RANDMIN_MIN)
		randmin = BUFF_RANDMIN_MIN;
	if (randmin > BUFF_RANDMIN_MAX)
		randmin = BUFF_RANDMIN_MAX;
	
	randval = random(randmin, randmax);
	if (randmin >= BUFF_LARGE_THRESHHOLD)
	{
		ApplyLargeMonster(monst);
		monst.bufftype (+) BUFFTYPE_LARGE;
	}
	
	//make second check. There is a small chance that a monster can be a large leader!
	randval = random(randmin, randmax);
	if (canBeLeader && randval >= BUFF_LEADER_THRESHHOLD)
	{
		ApplyLeaderMonster(monst);
		monst.bufftype (+) BUFFTYPE_LEADER;
		
		return; //cannot be a spectre leader, ditch here
	}
	
	randval = random(randmin, randmax);
	if (randval >= BUFF_SPECTRE_THRESHHOLD)
	{
		ApplySpectreMonster(monst);
		monst.bufftype (+) BUFFTYPE_SPECTRE;
	}
}
