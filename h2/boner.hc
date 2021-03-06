/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/h2/boner.hc,v 1.2 2007-02-07 16:56:56 sezero Exp $
 */

/*
==============================================================================

Q:\art\models\weapons\spllbook\spllbook.hc

==============================================================================
*/

// For building the model
$cd Q:\art\models\weapons\spllbook
$origin 0 0 0
$base BASE skin
$skin skin
$flags 0

//
$frame fire1        fire2        fire3        fire4        fire5        
$frame fire6        fire7        fire8        fire9        fire10       
$frame fire11       fire12       

//
$frame go2mag01     go2mag02     go2mag03     go2mag04     go2mag05     
$frame go2mag06     go2mag07     go2mag08     go2mag09     go2mag10     
$frame go2mag11     go2mag12     go2mag13

//
$frame go2shd01     go2shd02     
$frame go2shd03     go2shd04     go2shd05     go2shd06     go2shd07      
$frame go2shd08     go2shd09     go2shd10     go2shd11     go2shd12      
$frame go2shd13     go2shd14      

//
$frame idle1        idle2        idle3        idle4        idle5        
$frame idle6        idle7        idle8        idle9        idle10       
$frame idle11       idle12       idle13       idle14       idle15       
$frame idle16       idle17       idle18       idle19       idle20       
$frame idle21       idle22       

//
$frame mfire1       mfire2       mfire3       mfire4       mfire5       
$frame mfire6       mfire7       mfire8       

//
$frame midle01      midle02      midle03      midle04      midle05      
$frame midle06      midle07      midle08      midle09      midle10      
$frame midle11      midle12      midle13      midle14      midle15      
$frame midle16      midle17      midle18      midle19      midle20      
$frame midle21      midle22      

//
$frame mselect01    mselect02    mselect03    mselect04    mselect05    
$frame mselect06    mselect07    mselect08    mselect09    mselect10    
$frame mselect11    mselect12    mselect13    mselect14    mselect15    
$frame mselect16    mselect17    mselect18    mselect19    mselect20    

//
$frame select1      select2      select3      select4      select5      
$frame select6      select7      

float BONE_ATTACK_COST = 5;
float RAISE_DEAD_COST = 13;

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

void(vector org)smolder;
void(vector org, float damage) Ricochet =
{
//float r;
	particle4(org,3,random(368,384),PARTICLETYPE_GRAV,damage/2);
/*	r = random(100);
	if (r > 95)
		sound (targ,CHAN_AUTO,"weapons/ric1.wav",1,ATTN_NORM);
	else if (r > 91)
		sound (targ,CHAN_AUTO,"weapons/ric2.wav",1,ATTN_NORM);
	else if (r > 87)
		sound (targ,CHAN_AUTO,"weapons/ric3.wav",1,ATTN_NORM);
*/
};

entity  multi_ent;
float   multi_damage;

void() ClearMultDamg =
{
	multi_ent = world;
	multi_damage = 0;
};

void() ApplyMultDamg =
{
float kicker, inertia;
	if (!multi_ent)
		return;

entity loser,winner;
	winner=self;
    loser=multi_ent;
    kicker = multi_damage * 7 - vlen(winner.origin - loser.origin);
	if(kicker>0)
	{	
        if(loser.flags&FL_ONGROUND)
		{	
			loser.flags(-)FL_ONGROUND;
			loser.velocity_z = loser.velocity_z + 150;
		}
        if (loser.mass<=10)
			inertia = 1;
                  else inertia = loser.mass/10;
            if(loser==self)
                    loser.velocity = loser.velocity - (normalize(loser.v_angle) * (kicker / inertia));
            else loser.velocity = loser.velocity + (normalize(winner.v_angle) * (kicker / inertia));
        T_Damage (loser, winner, winner, multi_damage);
	}
};

void(entity hit, float damage) AddMultDamg =
{
	if (!hit)
		return;
	
	if (hit != multi_ent)
	{
		ApplyMultDamg ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

void(float damage, vector dir) TraceHit =
{
	local   vector  vel, org;
	
	vel = (normalize(dir + v_factorrange('-1 -1 0','1 1 0')) + 2 * trace_plane_normal) * 200;
	org = trace_endpos - dir*4;

	if (trace_ent.takedamage)
	{
		SpawnPuff (org, vel*0.1, damage*0.25,trace_ent);
		AddMultDamg (trace_ent, damage);
	}
	else
		Ricochet(org,damage);
};

void(float shotcount, vector dir, vector spread) InstantDamage =
{
vector direction;
vector  src;
	
	makevectors(self.v_angle);

	src = self.origin + self.proj_ofs+'0 0 6'+v_forward*10;
	ClearMultDamg ();
	while (shotcount > 0)
	{
		direction = dir + random(-1,1)*spread_x*v_right;
		direction += random(-1,1)*spread_y*v_up;

		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceHit (4, direction);
		shotcount = shotcount - 1;
	}
	ApplyMultDamg ();
};

void bone_shard_touch ()
{
	if(other==self.owner)
		return;
string hitsound;

	if(other.takedamage)
	{
		hitsound="necro/bonenhit.wav";
		T_Damage(other, self,self.owner,self.dmg);
	}
	else
	{
		hitsound="necro/bonenwal.wav";
		//T_RadiusDamage(self,self.owner,self.dmg*2,self.owner);
	}
//FIXME: add sprite, particles, sound
	starteffect(CE_WHITE_SMOKE, self.origin,'0 0 0', HX_FRAME_TIME);
	sound(self,CHAN_WEAPON,hitsound,1,ATTN_NORM);
	particle4(self.origin,3,random(368,384),PARTICLETYPE_GRAV,self.dmg/2);

	endeffect(MSG_ALL,self.wrq_effect_id);

	remove(self);	
}

void bone_removeshrapnel (void)
{
	endeffect(MSG_ALL,self.wrq_effect_id);
	remove(self);	
}

void fire_bone_shrapnel ()
{
	vector shard_vel;
	float intmod;
	
	if (self.owner.classname == "player")
		intmod = self.owner.intelligence;
	else
		intmod = 12;
	
	newmis=spawn();
	newmis.owner=self.owner;
	newmis.movetype=MOVETYPE_BOUNCE;
	newmis.solid=SOLID_PHASE;
	newmis.effects (+) EF_NODRAW;
	newmis.touch=bone_shard_touch;
	newmis.dmg= intmod / 2;
	newmis.think=bone_removeshrapnel;
	thinktime newmis : 3;

	newmis.speed=777;
	trace_fraction=0;
	trace_ent=world;
	while(trace_fraction!=1&&!trace_ent.takedamage)
	{
		shard_vel=randomv('1 1 1','-1 -1 -1');
		traceline(self.origin,self.origin+shard_vel*36,TRUE,self);
	}
	newmis.velocity=shard_vel*newmis.speed;
	newmis.avelocity=randomv('777 777 777','-777 -777 -777');

	setmodel(newmis,"models/boneshrd.mdl");
	setsize(newmis,'0 0 0','0 0 0');
	setorigin(newmis,self.origin+shard_vel*8);

	newmis.wrq_effect_id = starteffect(CE_BONESHRAPNEL, newmis.origin, newmis.velocity,
		newmis.angles,newmis.avelocity);

}

void bone_shatter ()
{
	float shard_count;
	shard_count=20;
	while(shard_count)
	{
		fire_bone_shrapnel();
		shard_count-=1;
	}
}

void bone_power_touch ()
{
	sound(self,CHAN_WEAPON,"necro/bonephit.wav",1,ATTN_NORM);

	if(other.takedamage)
	{
		T_Damage(other, self,self.owner,self.dmg);
	}
	self.flags2(+)FL2_ADJUST_MON_DAM;

	self.solid=SOLID_NOT;
	bone_shatter();

	starteffect(CE_BONE_EXPLOSION, self.origin-self.movedir*6,'0 0 0', HX_FRAME_TIME);
	particle4(self.origin,50,random(368,384),PARTICLETYPE_GRAV,10);

	remove(self);	
}
/*
void power_trail()
{
	if(self.owner.classname!="player")
		dprint("ERROR: Bone powered owner not player!\n");
	if(self.touch==SUB_Null)
		dprint("ERROR: Bone powered touch is null!\n");

	particle4(self.origin,10,random(368,384),PARTICLETYPE_SLOWGRAV,3);
	thinktime self : 0.05;
}
*/

void bone_smoke_fade ()
{
	thinktime self : 0.05;
	self.abslight-=0.05;
	self.scale+=0.05;
	if(self.abslight==0.35)
		self.skin=1;
	else if(self.abslight==0.2)
		self.skin=2;
	else if(self.abslight<=0.1)
		remove(self);
}

void MakeBoneSmoke ()
{
entity smoke;
	smoke=spawn_temp();
	smoke.movetype=MOVETYPE_FLYMISSILE;
	smoke.velocity=randomv('0 0 20')+v_forward*20;
	smoke.drawflags(+)MLS_ABSLIGHT|DRF_TRANSLUCENT;
	smoke.abslight=0.5;
	smoke.angles=vectoangles(v_forward);
	smoke.avelocity_x=random(-600,600);
	smoke.scale=0.1;
	setmodel(smoke,"models/bonefx.mdl");
	setsize(smoke,'0 0 0','0 0 0');
	setorigin(smoke,self.origin);
	smoke.think=bone_smoke_fade;
	thinktime smoke : 0.05;
}

void bone_smoke ()
{
	self.cnt+=1;
	MakeBoneSmoke();
	if(self.cnt>3)
		self.nextthink=-1;
	else
		thinktime self : 0.01;
}

void bone_fire(float powered_up, vector ofs)
{
	float intmod, wismod;
	float tome;
	
	//SOUND
	vector org;
	makevectors(self.v_angle);
	newmis=spawn();
	newmis.owner=self;
	newmis.movetype=MOVETYPE_FLYMISSILE;
	newmis.solid=SOLID_BBOX;
	newmis.speed=1000;
	newmis.velocity=v_forward*newmis.speed;

	org=self.origin+self.proj_ofs+v_forward*8+v_right*(ofs_y+12)+v_up*ofs_z;
	setorigin(newmis,org);
	
	tome = self.artifact_active & ART_TOMEOFPOWER;
	intmod = self.intelligence;
	wismod = self.wisdom;

	if(powered_up)
	{
		self.punchangle_x=-2;
		sound(self,CHAN_WEAPON,"necro/bonefpow.wav",1,ATTN_NORM);
		self.attack_finished=time + 1;
		newmis.dmg=random(wismod, wismod * 3);
		
		if (tome)
			newmis.dmg = random(wismod * 2, wismod * 4);
		
		newmis.frags=TRUE;
		newmis.touch=bone_power_touch;
		newmis.avelocity=randomv('777 777 777','-777 -777 -777');
		setmodel(newmis,"models/bonelump.mdl");
		setsize(newmis,'0 0 0','0 0 0');
		
		self.greenmana-=BONE_ATTACK_COST;
	}
	else
	{
		newmis.speed+=random(500);
		newmis.dmg=7;
		newmis.touch=bone_shard_touch;
		newmis.effects (+) EF_NODRAW;
		setmodel(newmis,"models/boneshot.mdl");
		setsize(newmis,'0 0 0','0 0 0');
		newmis.velocity+=v_right*ofs_y*10+v_up*ofs_z*10;

		newmis.angles=vectoangles(newmis.velocity);

		newmis.wrq_effect_id = starteffect(CE_BONESHARD, newmis.origin, newmis.velocity,
			newmis.angles,newmis.avelocity);
	}
}

void  bone_normal()
{
vector dir;
//sound
	sound(self,CHAN_WEAPON,"necro/bonefnrm.wav",1,ATTN_NORM);
	self.effects(+)EF_MUZZLEFLASH;
	makevectors(self.v_angle);
	dir=normalize(v_forward);
	InstantDamage(4,dir,'0.1 0.1 0.1');
//	InstantDamage(12,dir,'0.1 0.1 0.1');
	self.greenmana-=1;
	self.attack_finished=time+0.3;
}

void bone_fire_once()
{
	vector ofs;
	ofs_z=random(-5,5);
	ofs_x=random(-5,5);
	ofs_y=random(-5,5);
	bone_fire(FALSE,ofs);
}

void monster_spider_yellow_large(void);
void monster_spider_red_large(void);
void monster_scorpion_yellow (void);
void monster_scorpion_black (void);
void monster_mummy(void);
void CorpseThink(void);

void raise_dead_think()
{
	float intmod;
	
	//get intelligence value and reset count
	intmod = self.cnt;
	newmis.cnt = 0;
	if (intmod > 40)
	{
		monster_mummy();
	}
	else if (intmod > 33)
	{
		monster_scorpion_black ();
	}
	else if (intmod > 27)
	{
		monster_spider_red_large();
	}
	else if (intmod > 21)
	{
		monster_scorpion_yellow();
	}
	else
	{
		monster_spider_yellow_large();
	}
	
	self.experience_value = 0; //no XP for summoned monsters
	self.th_die = chunk_death; //summoned monsters explode, don't respawn
}

void raise_dead(entity body, float intmod)
{
	vector newpos, newangles;
	entity newmis;
	
	newpos = body.origin;
	newangles = body.angles;
	
	//gib body
	body.think = chunk_death;	
	body.nextthink = 0.1;
	
	//ghost effect
	starteffect(CE_GHOST, body.origin,'0 0 30', 0.1);
	
	//spawn monster
	newmis = spawn ();
	newmis.origin = newpos;
	newmis.angles = newangles;
	
	newmis.flags2 (+) FL_SUMMONED;
	newmis.flags2(+)FL_ALIVE;
	newmis.lifetime = time + (intmod * 2);
	newmis.think = raise_dead_think;
	newmis.nextthink = time + 0.05;
	newmis.controller = self;
	newmis.preventrespawn = TRUE;// mark so summoned monster cannot respawn
	newmis.playercontrolled = TRUE;
	
	if(self.enemy!=world&&self.enemy.flags2&FL_ALIVE&&visible2ent(self.enemy,self))
	{
		newmis.enemy=newmis.goalentity=self.enemy;
	}
	else
	{
		newmis.enemy=newmis.goalentity=self; // follow player		
	}
	newmis.monster_awake=TRUE; //start awake
	newmis.team=self.team;
	
	//User count property to choose spawn type
	newmis.cnt = self.intelligence;
}

void bone_raise_dead()
{
	vector	source;
	vector	org;
	float intmod, wismod;
	float tome;
	
	tome = self.artifact_active&ART_TOMEOFPOWER;
	
	intmod = self.intelligence;
	wismod = self.wisdom;
	
	makevectors (self.v_angle);
	source = self.origin + self.proj_ofs;
	traceline (source, source + v_forward*650, FALSE, self);
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

	org = trace_endpos + (v_forward * 4);

	self.enemy = trace_ent;
	if (trace_ent.takedamage && trace_ent.think == CorpseThink)
	{
		raise_dead(trace_ent, intmod);
		
		self.greenmana -= RAISE_DEAD_COST;
	}
	else
	{
		// hit wall
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);

		CreateWhiteFlash(org);
	}
	
	self.attack_finished=time + 1;
}


/*======================
ACTION
select
deselect
ready loop
relax loop
fire once
fire loop
ready to relax(after short delay)
relax to ready(Fire delay?  or automatic if see someone?)
=======================*/


void()boneshard_ready;
void() Nec_Bon_Attack;

void raisedead_fire (void)
{
	self.wfs = advanceweaponframe($fire1,$fire12);
	
	self.th_weapon=raisedead_fire;
	self.last_attack=time;
	if(self.weaponframe==$fire3)
	{
		bone_raise_dead();
	}

	if (self.wfs == WF_LAST_FRAME)
		boneshard_ready();
}

void boneshard_fire (void)
{
	self.wfs = advanceweaponframe($fire1,$fire12);
	
	self.th_weapon=boneshard_fire;
	self.last_attack=time;
	if(self.weaponframe==$fire3)
	{
		if (self.greenmana >= BONE_ATTACK_COST)
		{
			bone_fire(TRUE,'0 0 0');			
		}
	}

	if (self.wfs == WF_LAST_FRAME)
		boneshard_ready();
}

void() Nec_Bon_Attack =
{
	float rightclick;
	
	rightclick = self.button1;
	
	if(rightclick && self.greenmana >= RAISE_DEAD_COST)
		raisedead_fire();
	else
		boneshard_fire();

	thinktime self : 0;
};

void boneshard_jellyfingers ()
{
	self.wfs = advanceweaponframe($idle1,$idle22);
	self.th_weapon=boneshard_jellyfingers;
	if(self.wfs==WF_CYCLE_WRAPPED)
		boneshard_ready();
}

void boneshard_ready (void)
{
	self.weaponframe=$idle1;
	if(random()<0.1&&random()<0.3&&random()<0.5)
		self.th_weapon=boneshard_jellyfingers;
	else
		self.th_weapon=boneshard_ready;
}

void boneshard_select (void)
{
	self.wfs = advanceweaponframe($select7,$select1);
	self.weaponmodel = "models/spllbook.mdl";
	self.th_weapon=boneshard_select;
	if(self.wfs==WF_CYCLE_WRAPPED)
	{
		self.attack_finished = time - 1;
		boneshard_ready();
	}
}

void boneshard_deselect (void)
{
	self.wfs = advanceweaponframe($select1,$select7);
	self.th_weapon=boneshard_deselect;
	if(self.wfs==WF_CYCLE_WRAPPED)
		W_SetCurrentAmmo();
}


void boneshard_select_from_mmis (void)
{
	self.wfs = advanceweaponframe($go2shd01,$go2shd14);
	self.weaponmodel = "models/spllbook.mdl";
	self.th_weapon=boneshard_select_from_mmis;
	if(self.wfs==WF_CYCLE_WRAPPED)
	{
		self.attack_finished = time - 1;
		boneshard_ready();
	}
}

