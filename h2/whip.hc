float PULL_TOTAL = 700;
float PULL_RESISTGRAVITY = 80;
float WHIP_LENGTH = 350;

void whip_pull_solid (vector dir, vector endpos)
{
	vector upvec;
	float totalpull;
	
	upvec = '0 1 0';
	totalpull = PULL_TOTAL;
	
	//pull player
	self.velocity+=dir * totalpull;
	self.velocity+=upvec * PULL_RESISTGRAVITY;//get off ground
	self.flags(-)FL_ONGROUND;
}

void whip_pull (vector dir, entity targetent)
{
	vector upvec;
	float totalmass, pullstr1, pullstr2;
	float stationary;
		
	//break up total pull into equal parts
	totalmass = targetent.mass + self.mass;
	pullstr1 = (self.mass / totalmass) * PULL_TOTAL;
	pullstr2 = (targetent.mass / totalmass) * PULL_TOTAL;

	if (targetent.mass > 1000 || !targetent.flags2&FL_ALIVE)
	{
		pullstr1 = PULL_TOTAL;
		stationary = TRUE;
	}
	
	upvec = '0 0 1';
	
	//pull player
	self.velocity+=dir * pullstr1;
	self.velocity+=upvec * PULL_RESISTGRAVITY;//get off ground
	self.flags(-)FL_ONGROUND;

	if (!stationary)
	{
		//pull target
		targetent.velocity+=(dir * -1) * pullstr2;
		targetent.velocity+=upvec * PULL_RESISTGRAVITY;//get off ground
		targetent.flags(-)FL_ONGROUND;
	}
}

void whip_fire ()
{
	vector	source, dir;
	float wdistance;
	
	//whip limit
	if (self.whiptime > time)
	{
		return;
	}
	
	self.whiptime = time + 0.8;
	
	wdistance = WHIP_LENGTH;
	
	makevectors (self.v_angle);
	source = self.origin + self.proj_ofs;
	source += normalize(v_right) * -8;
	source += normalize(v_up) * -4; //get left hand location offset
	dir = normalize(v_forward);
	traceline (source, source + dir * wdistance, FALSE, self);

	self.enemy = trace_ent;
	
	if (trace_ent.takedamage) //can be hurt
	{
		whip_pull(dir, trace_ent);		
	}
	else if (trace_fraction < 1.0 && pointcontents(trace_endpos) != CONTENT_SKY) //walls (but not sky)
	{
		whip_pull_solid(dir, trace_endpos);
	}

	// Draw chain
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_STREAM_CHAIN);
	WriteEntity (MSG_BROADCAST, self);
	WriteByte (MSG_BROADCAST, 1+STREAM_ATTACHED);
	WriteByte (MSG_BROADCAST, 6);
	WriteCoord (MSG_BROADCAST, source_x);
	WriteCoord (MSG_BROADCAST, source_y);
	WriteCoord (MSG_BROADCAST, source_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);
}