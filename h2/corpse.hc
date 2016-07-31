/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/h2/corpse.hc,v 1.2 2007-02-07 16:56:59 sezero Exp $
 */
 
void monster_imp_ice (void);
void monster_imp_fire (void);
void monster_archer (void);
void monster_skull_wizard (void);
void monster_scorpion_black (void);
void monster_scorpion_yellow (void);
void monster_spider_yellow_large (void);
void monster_spider_yellow_small (void);
void monster_spider_red_large (void);
void monster_spider_red_small (void);
void monster_golem_stone (void);
void monster_golem_iron (void);
void monster_golem_bronze (void);
void monster_mummy (void);
void monster_mummy_lord (void);
void monster_werejaguar (void);
void monster_mezzoman (void);
void monster_werepanther (void);
void monster_medusa(void);
void monster_fallen_angel (void);

		
 void wandering_monster_respawn()
 {
	vector newangle,spot1,spot2;
	float loop_cnt;
	
	//check if anything is in the path of spawning
	trace_fraction = 0;
	loop_cnt =0;
	spot2 = self.origin;
	while (trace_fraction < 1)
	{
		newangle = self.angles;

		makevectors (newangle);
		
		spot1 = spot2;
		spot2 = spot1 + (v_forward * 60);
		
		traceline (spot1, spot2 , FALSE, self);
				
		loop_cnt +=1;
		dprint("Searching!!\n");

		if (loop_cnt > 10)   // No endless loops
		{
			//if 10 checks happen and no spot is found, try again in 2 seconds
			self.nextthink = time + 2;
			dprint("Found nothing!!\n");
			return;
		}		
	}
	
	//spot is clear, use spot
	self.origin = spot1;
 
	if (self.classname == "monster_imp_ice")
	{
		self.think = monster_imp_ice;
	}
	else if (self.classname == "monster_imp_fire")
	{
		self.think = monster_imp_fire;
	}
	else if (self.classname == "monster_archer")
	{
		self.think = monster_archer;
	}
	else if (self.classname == "monster_archer_lord")
	{
		self.classname = "monster_archer";
		self.think = monster_archer;
	}
	else if (self.classname == "monster_skull_wizard")
	{
		self.think = monster_skull_wizard;
	}
	else if (self.classname == "monster_scorpion_black")
	{
		self.think = monster_scorpion_black;
	}
	else if (self.classname == "monster_scorpion_yellow")
	{
		self.think = monster_scorpion_yellow;
	}
	else if (self.classname == "monster_spider_yellow_large")
	{
		self.think = monster_spider_yellow_large;
	}
	else if (self.classname == "monster_spider_yellow_small")
	{
		self.think = monster_spider_yellow_small;
	}
	else if (self.classname == "monster_spider_red_large")
	{
		self.think = monster_spider_red_large;
	}
	else if (self.classname == "monster_spider_red_small")
	{
		self.think = monster_spider_red_small;
	}
	else if (self.classname == "monster_golem_stone")
	{
		self.think = monster_golem_stone;
	}
	else if (self.classname == "monster_golem_iron")
	{
		self.think = monster_golem_iron;
	}
	else if (self.classname == "monster_golem_bronze")
	{
		self.think = monster_golem_bronze;
	}
	else if (self.classname == "monster_mummy")
	{
		self.think = monster_mummy;
	}
	else if (self.classname == "monster_mummy_lord")
	{
		self.classname = "monster_mummy";
		self.think = monster_mummy;
	}
	else if (self.classname == "monster_werejaguar")
	{
		self.think = monster_werejaguar;
	}
	else if (self.classname == "monster_mezzoman")
	{
		self.think = monster_mezzoman;
	}
	else if (self.classname == "monster_werepanther")
	{
		self.think = monster_werepanther;
	}
	else if (self.classname == "monster_medusa")
	{
		self.think = monster_medusa;
	}
	else if (self.classname == "monster_fallen_angel")
	{
		self.think = monster_fallen_angel;
	}
	else if (self.classname == "monster_fallen_angel_lord")
	{
		self.classname = "monster_fallen_angel";
		self.think = monster_fallen_angel;
	}
	else //not a supported respawn
	{
		//Don't respawn bosses
		//Other monsters not supported: 
		//		monster_fallen_angel_lord, apocalypse riders, eidelon, etc.
		remove(self);
		return;
	}

	self.nextthink = time + 0.01;
	
	CreateRedCloud (self.origin + '0 0 40','0 0 0',HX_FRAME_TIME);
 }

float WANDERING_MONSTER_TIME_MIN = 120; //2 minutes
float WANDERING_MONSTER_TIME_MAX = 666; //11 minutes

void MarkForRespawn (void)
{
	entity newmis;
	float timelimit;
	
	if (self.classname != "player" && !self.preventrespawn) //do not respawn players or summoned monsters
	{
		dprint ("Classname: ");
		dprint (self.classname);
		dprint (" Controller: ");
		dprint (self.controller.classname);
		dprint (" Owner: ");
		dprint (self.owner.classname);
		dprint ("\n");
		dprintv("Marked for respawn: %s\n",self.origin);

		timelimit = random(WANDERING_MONSTER_TIME_MIN, WANDERING_MONSTER_TIME_MAX);
		
		newmis = spawn ();
		newmis.origin = self.origin;
		
		newmis.flags2 (+) FL_SUMMONED;
		newmis.lifetime = time + 900;
		newmis.classname = self.classname;
	
		newmis.think = wandering_monster_respawn;
		newmis.nextthink = time + timelimit;
		
		//mark for respawn buff chance
		newmis.killerlevel = self.killerlevel;
	}
	remove(self);
}

void corpseblink (void)
{
	self.think = corpseblink;
	thinktime self : 0.1;
	self.scale -= 0.10;

	if (self.scale < 0.10)
	{
		MarkForRespawn();
	}
}

void init_corpseblink (void)
{
	CreateYRFlash(self.origin);

	self.drawflags (+) DRF_TRANSLUCENT | SCALE_TYPE_ZONLY | SCALE_ORIGIN_BOTTOM;

	corpseblink();
}

void() Spurt =
{
float bloodleak;

	makevectors(self.angles);
    bloodleak=rint(random(3,8));
    SpawnPuff (self.origin+v_forward*24+'0 0 -22', '0 0 -5'+ v_forward*random(20,40), bloodleak,self);
    sound (self, CHAN_AUTO, "misc/decomp.wav", 0.3, ATTN_NORM);
    if (self.lifetime < time||self.watertype==CONTENT_LAVA)
	    T_Damage(self,world,world,self.health);
	else
	{
	    self.think=Spurt;
		thinktime self : random(0.5,6.5);
	}
};

void () CorpseThink =
{
	self.think = CorpseThink;
	thinktime self : 3;

	if (self.watertype==CONTENT_LAVA)	// Corpse fell in lava
		T_Damage(self,self,self,self.health);
	else if (self.lifetime < time)			// Time is up, begone with you
		init_corpseblink();
};

/*
 * This uses entity.netname to hold the head file (for CorpseDie())
 * hack so that we don't have to set anything outside this function.
 */
void()MakeSolidCorpse =
{
vector newmaxs;
// Make a gibbable corpse, change the size so we can jump on it

//Won't be necc to pass headmdl once everything has it's .headmodel
//value set in spawn
    self.th_die = chunk_death;
	self.touch = obj_push;
    self.health = random(10,25);
	self.takedamage = DAMAGE_YES;
	self.solid = SOLID_PHASE;
	self.experience_value = 0;
	if(self.classname!="monster_hydra")
		self.movetype = MOVETYPE_STEP;//Don't get in the way	
	if(!self.mass)
		self.mass=1;

//To fix "player stuck" probem
	newmaxs=self.maxs;
	if(newmaxs_z>5)
		newmaxs_z=5;
	setsize (self, self.mins,newmaxs);

	if(self.flags&FL_ONGROUND)
		self.velocity='0 0 0';
    self.flags(-)FL_MONSTER;
	if (!self.preventrespawn)
		self.controller = self;
	self.onfire = FALSE;

	pitch_roll_for_slope('0 0 0');

    if ((self.decap)  && (self.classname == "player"))
    {	
		if (deathmatch||teamplay)
			self.lifetime = time + random(20,40); // decompose after 40 seconds
		else 
			self.lifetime = time + random(10,20); // decompose after 20 seconds

        self.owner=self;
        self.think=Spurt;
        thinktime self : random(1,4);
    }
    else 
	{
		self.lifetime = time + random(10,20); // disappear after 20 seconds
		self.think=CorpseThink;
		thinktime self : 0;
	}
};

