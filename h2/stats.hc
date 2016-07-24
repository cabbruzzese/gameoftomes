/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/h2/stats.hc,v 1.3 2007-02-07 16:57:10 sezero Exp $
 */

// ExperienceValues for each level indicate the minimum at which
// you can become that level.  The 11th entry indicates the amount
// of experience needed for each level past 10


/*float ExperienceValues[44] =
{
	// Paladin
	 945,			// Level 2
	2240,			// Level 3
	5250,			// Level 4
	10150,			// Level 5
	21000,			// Level 6
	39900,			// Level 7
	72800,			// Level 8
	120400,			// Level 9
	154000,			// Level 10
	210000,			// Level 11
	210000,			// Required amount for each level afterwards

	// Crusader
	911,			// Level 2
	2160,			// Level 3
	5062,			// Level 4
	9787,			// Level 5
	20250,			// Level 6
	38475,			// Level 7
	70200,			// Level 8
	116100,			// Level 9
	148500,			// Level 10
	202500,			// Level 11
	202500,			// Required amount for each level afterwards

	// Necromancer
	823,			// Level 2
	1952,			// Level 3
	4575,			// Level 4
	8845,			// Level 5
	18300,			// Level 6
	34770,			// Level 7
	63440,			// Level 8
	104920,			// Level 9
	134200,			// Level 10
	183000,			// Level 11
	183000,			// Required amount for each level afterwards

	// Assassin
	675,			// Level 2
	1600,			// Level 3
	3750,			// Level 4
	7250,			// Level 5
	15000,			// Level 6
	28500,			// Level 7
	52000,			// Level 8
	86000,			// Level 9
	110000,			// Level 10
	150000,			// Level 11
	150000			// Required amount for each level afterwards
};*/

//  min health, max health,
//  min health per level up to level 10,  min health per level up to level 10, 
//  health per level past level 10
float hitpoint_table[20] =
{
	70,		85,				// Paladin
	8,		13,      4,

	65,		75,				// Crusader
	5,		10,      3,

	65,		75,				// Necromancer
	5,		10,      3,

	65,		75,				// Assassin
	5,		10,      3

};

float mana_table[20] =
{
//    Startup    Per Level     Past
//  min    max    min  max      10th Level
	84,		94,		6,   9, 	 1,		// Paladin
	88,		98,		7,  10, 	 2, 	// Crusader
    96,	   106,	   10,  12, 	 4,     // Necromancer
	92,	   102,		9,  11, 	 3		// Assassin
};


float strength_table[8] =
{
	15,		18,		// Paladin
	12,		15,		// Crusader
	6,		10,		// Necromancer
	10,		13		// Assassin
};

float intelligence_table[8] =
{
	6,		10,		// Paladin
	10,		13,		// Crusader
	15,		18,		// Necromancer
	6,		10		// Assassin
};

float wisdom_table[8] =
{
	6,		10,		// Paladin
	15,		18,		// Crusader
	10,		13,		// Necromancer
	12,		15		// Assassin
};

float dexterity_table[8] =
{
	10,		13,		// Paladin
	6,		10,		// Crusader
	8,		12,		// Necromancer
	15,		18		// Assassin
};

/*
float CLASS_PALADIN					= 1;
float CLASS_CRUSADER				= 2;
float CLASS_NECROMANCER				= 3;
float CLASS_ASSASSIN				= 4;
*/

// Make sure we get a real distribution beteen
// min-max, otherwise, max will only get choosen when
// random() returns 1.0
float stats_compute(float min, float max)
{
	float value;

	value = (max-min+1)*random() + min;
	if (value > max) value = max;

	value = ceil(value);

	return value;
}

void stats_NewPlayer(entity e)
{
	float index;

	// Stats already set?
	if (e.strength) return;

	if (e.playerclass < CLASS_PALADIN || e.playerclass > CLASS_ASSASSIN)
	{
		sprint(e,"Invalid player class ");
		sprint(e,ftos(e.playerclass));
		sprint(e,"\n");
		return;
	}

	// Calc initial health
	index = (e.playerclass - 1) * 5;
	e.health = stats_compute(hitpoint_table[index], hitpoint_table[index+1]);
	e.max_health = e.health;

	// Calc initial mana
	index = (e.playerclass - 1) * 5;
	e.max_mana = stats_compute(mana_table[index], mana_table[index+1]);

	index = (e.playerclass - 1) * 2;
	e.strength = stats_compute(strength_table[index], strength_table[index+1]);
	e.intelligence = stats_compute(intelligence_table[index], intelligence_table[index+1]);
	e.wisdom = stats_compute(wisdom_table[index], wisdom_table[index+1]);
	e.dexterity = stats_compute(dexterity_table[index], dexterity_table[index+1]);

	e.level = 1;
	e.experience = 0;
}

// Jump ahead one level
void player_level_cheat()
{
	float index;

	index = (self.playerclass - 1) * (MAX_LEVELS+1);

	if (self.level > MAX_LEVELS)
		index += MAX_LEVELS - 1;
	else
		index += self.level - 1;

	self.experience = 0; //reset xp to 0 at every level gain

	PlayerAdvanceLevel(self.level+1);
}

void player_experience_cheat(void)
{
	AwardExperience(self,self,350);
}

float GetPlayerXPNeeded(float currentLevel)
{
	return currentLevel * 1000;
}

/*
================
PlayerAdvanceLevel

This routine is called (from the game C side) when a player is advanced a level
(self.level)
================
*/
float STAT_POOL_COUNT = 5;
void PlayerAdvanceLevel(float NewLevel)
{
	string s2;
	float OldLevel,Diff;
	float index,HealthInc,ManaInc;
	float statpool, statspread, statrandom;

	OldLevel = self.level;
	self.level = NewLevel;
	Diff = self.level - OldLevel;

	sprint(self,"You are now level ");
	s2 = ftos(self.level);
	sprint(self,s2);
	sprint(self,"!\n");

	if(!self.newclass)
	{
		if (self.playerclass == CLASS_PALADIN)
		{
		   sprint(self,"Paladin gained a level\n");
		}
		else if (self.playerclass == CLASS_CRUSADER)
		{
		   sprint(self,"Crusader gained a level\n");
		}
		else if (self.playerclass == CLASS_NECROMANCER)
		{
		   sprint(self,"Necromancer gained a level\n");
		}
		else if (self.playerclass == CLASS_ASSASSIN)
		{
		   sprint(self,"Assassin gained a level\n");
		}
	}

	//if not a player, exit
	if (self.playerclass < CLASS_PALADIN ||
		self.playerclass > CLASS_ASSASSIN)
		return;

	index = (self.playerclass - 1) * 5;

	// Have to do it this way in case they go up more than 1 level at a time
	while(Diff > 0)
	{
		OldLevel += 1;
		Diff -= 1;

		if (OldLevel <= MAX_LEVELS)
		{
			HealthInc = stats_compute(hitpoint_table[index+2],hitpoint_table[index+3]);
			ManaInc = stats_compute(mana_table[index+2],mana_table[index+3]);
		}
		else
		{
			HealthInc = hitpoint_table[index+4];
			ManaInc = mana_table[index+4];
		}
		self.max_health += HealthInc;

		if (self.max_health > 900)
			self.max_health = 900;

		//recharge mana
		self.max_mana += ManaInc;		
		self.greenmana = self.max_mana;
		self.bluemana = self.max_mana;
		
		//recharge health
		if (self.health < self.max_health)
		{
			self.health = self.max_health;			
		}
		
		//increase stats at random
		statpool = STAT_POOL_COUNT; //leveling twice as fast, means awarding stats half as fast
		while(statpool > 0)
		{
			//create a tower of existing stats
			statspread = self.strength + self.wisdom + self.intelligence + self.dexterity;
			statrandom = random(0, statspread - 1);
			
			//assign stat depending on where it lands in the tower
			if (statrandom < self.strength)
			{
				self.strength += 1;
			}
			else if (statrandom < self.strength + self.wisdom)
			{
				self.wisdom += 1;
			}
			else if (statrandom < self.strength + self.wisdom + self.intelligence)
			{
				self.intelligence += 1;
			}
			else
			{
				self.dexterity += 1;
			}
				
			statpool -= 1;
		}
	}

	if (self.level > 2)
		self.flags(+)FL_SPECIAL_ABILITY1;

	if (self.level >5)
		self.flags(+)FL_SPECIAL_ABILITY2;
}

float FindLevel(entity WhichPlayer)
{
	//float Chart;
	//float Amount,Position,Level;

	//not a player class
	if (WhichPlayer.playerclass < CLASS_PALADIN ||
		WhichPlayer.playerclass > CLASS_ASSASSIN)
		return WhichPlayer.level;

	/*
	Chart = (WhichPlayer.playerclass - 1) * (MAX_LEVELS+1);

	Level = 0;
	Position=0;
	while(Position < MAX_LEVELS && Level == 0)
	{
		if (WhichPlayer.experience < ExperienceValues[Chart+Position])
			Level = Position+1;

		Position += 1;
	}

	if (!Level)
	{
		Amount = WhichPlayer.experience - ExperienceValues[Chart + MAX_LEVELS - 1];
		Level = ceil(Amount / ExperienceValues[Chart + MAX_LEVELS]) + MAX_LEVELS;
	}*/
	
	return WhichPlayer.level;
}


void AwardExperience(entity ToEnt, entity FromEnt, float Amount)
{
	//float AfterLevel;
	float IsPlayer;
	entity SaveSelf;
	//float index,test40,test80,diff,index2,totalnext,wis_mod;
	float xpneeded;

	if (!Amount) return;

	if(ToEnt.deadflag>=DEAD_DYING)
		return;

	IsPlayer = (ToEnt.classname == "player");

	if (FromEnt != world && Amount == 0.0)
	{
		Amount = FromEnt.experience_value;
	}

	/*
	if (ToEnt.level <4)
		Amount *= .5;

	if (ToEnt.playerclass == CLASS_PALADIN)
		Amount *= 1.4;
	else if (ToEnt.playerclass == CLASS_CRUSADER)
		Amount *= 1.35;
	else if (ToEnt.playerclass == CLASS_NECROMANCER)
		Amount *= 1.22;

	wis_mod = ToEnt.wisdom - 11;
	Amount+=Amount*wis_mod/20;//from .75 to 1.35

	*/
	
	if (IsPlayer)
	{
		ToEnt.experience += Amount;
		xpneeded = GetPlayerXPNeeded(ToEnt.level);
		
		while (ToEnt.experience >= xpneeded)
		{
			SaveSelf = self;
			self = ToEnt;

			//Reduce experience by needed xp (resets every level at 0 XP to make level grinding easier to predict)
			self.experience -= xpneeded;
			
			PlayerAdvanceLevel(ToEnt.level + 1);

			self = SaveSelf;
		}
	}
}


/*
======================================
void stats_NewClass(entity e)
MG
Used when doing a quick changeclass
======================================
*/
void stats_NewClass(entity e)
{
entity oself;
float index,newlevel;

	if (e.playerclass < CLASS_PALADIN || e.playerclass > CLASS_ASSASSIN)
	{
		sprint(e,"Invalid player class ");
		sprint(e,ftos(e.playerclass));
		sprint(e,"\n");
		return;
	}

	// Calc initial health
	index = (e.playerclass - 1) * 5;
	e.health = stats_compute(hitpoint_table[index], hitpoint_table[index+1]);
	e.max_health = e.health;

	// Calc initial mana
	index = (e.playerclass - 1) * 5;
	e.max_mana = stats_compute(mana_table[index], mana_table[index+1]);

	index = (e.playerclass - 1) * 2;
	e.strength = stats_compute(strength_table[index], strength_table[index+1]);
	e.intelligence = stats_compute(intelligence_table[index], intelligence_table[index+1]);
	e.wisdom = stats_compute(wisdom_table[index], wisdom_table[index+1]);
	e.dexterity = stats_compute(dexterity_table[index], dexterity_table[index+1]);

	//Add level diff stuff
	newlevel = FindLevel(e);
	e.level=1;
	if(newlevel>1)
	{
		oself=self;
		self=e;
		PlayerAdvanceLevel(newlevel);
		self=oself;
	}
}

/*
======================================
drop_level
MG
Used in deathmatch where you don't
lose all exp, just enough to drop you
down one level.
======================================
*/
float STAT_PUNISH_MIN = 1;
void drop_level (entity loser,float number)
{
	float pos;
	float statspread, statrandom, statpool;
	
	if(loser.classname!="player")
		return;

	if(loser.level-number>1)
	{
		loser.level-=number;
		pos = (loser.playerclass - 1) * (MAX_LEVELS+1);
		loser.experience = 0;//ExperienceValues[pos+loser.level - 2];
	}
	else
	{
		loser.level=1;
		loser.experience=0;
	}
	
	//randomly punish stats
	statpool = STAT_POOL_COUNT;
	while(statpool > 0)
	{
		//create a tower of existing stats
		statspread = loser.strength + loser.wisdom + loser.intelligence + loser.dexterity;
		statrandom = random(0, statspread - 1);
		
		//assign stat depending on where it lands in the tower
		if (statrandom < loser.strength)
		{
			 //prevent 0's and negatives. This has a miniscule chance of making more than 3 level drops hit the min, and grant the player extra stats
			 // HOWEVER, this is intentional. If a player is stunted down to 1 of any stat, they are in a bad position and the advantage
			 // is completely negated. Assigning any more points to the stunted stat in future levels is about 1 in 60
			if (loser.strength > STAT_PUNISH_MIN)
				loser.strength -= 1;
		}
		else if (statrandom < loser.strength + loser.wisdom)
		{
			if (loser.strength > STAT_PUNISH_MIN)
				loser.strength -= 1;
		}
		else if (statrandom < loser.strength + loser.wisdom + loser.intelligence)
		{
			if (loser.strength > STAT_PUNISH_MIN)
				loser.strength -= 1;
		}
		else
		{
			if (loser.strength > STAT_PUNISH_MIN)
				loser.strength -= 1;
		}
			
		statpool -= 1;
	}

	if (loser.level <= 2)
		loser.flags(-)FL_SPECIAL_ABILITY1;

	if (loser.level <=5)
		loser.flags(-)FL_SPECIAL_ABILITY2;
}

