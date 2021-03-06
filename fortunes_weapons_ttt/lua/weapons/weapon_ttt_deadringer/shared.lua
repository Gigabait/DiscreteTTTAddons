if SERVER then
   AddCSLuaFile( "shared.lua" )
   resource.AddFile( "sound/feign.wav")
end
   
SWEP.HoldType     = "slam"


if CLIENT then
   SWEP.PrintName     = "Dead Ringer"      
   SWEP.Author        = "Fortune"

   SWEP.Slot  = 7

   SWEP.EquipMenuData = {
      type = "Invis Watch",
      desc = "Allows the user to fake their own death\nUpon taking damage while the weapon is out\nyou drop a fake corpse and turn invis. Lasts 7 seconds.\n90 second recharge time.\nMade by Fortune."
   };

   SWEP.Icon = "vgui/ttt/discrete/deadringer"

    SWEP.DrawCrosshair   = false

end

SWEP.Base = "weapon_ttt_invisbase"

SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = true

SWEP.UseHands     = true

SWEP.ViewModel          = "models/weapons/c_slam.mdl"
SWEP.WorldModel         = "models/weapons/w_slam.mdl"
SWEP.ViewModelFOV   = 70
SWEP.Primary.DefaultClip = -1
SWEP.Primary.ClipSize = -1
SWEP.Primary.ClipMax  = -1

SWEP.data = {}
SWEP.data.canFlash = false 
SWEP.data.Material = "sprites/heatwave"
SWEP.data.cloakTime = 0
SWEP.data.unCloakTime = 0.7
SWEP.data.duration = 12
SWEP.data.chargeTime = 30
SWEP.data.damageReduction = 0.8
SWEP.data.speedBoost = 1.8
SWEP.data.cloakReduction = 0.4
SWEP.data.minimumCharge = 1


function SWEP:PrimaryAttack()
	return 
end 

local deathsounds = {
   Sound("player/death1.wav"),
   Sound("player/death2.wav"),
   Sound("player/death3.wav"),
   Sound("player/death4.wav"),
   Sound("player/death5.wav"),
   Sound("player/death6.wav"),
   Sound("vo/npc/male01/pain07.wav"),
   Sound("vo/npc/male01/pain08.wav"),
   Sound("vo/npc/male01/pain09.wav"),
   Sound("vo/npc/male01/pain04.wav"),
   Sound("vo/npc/Barney/ba_pain06.wav"),
   Sound("vo/npc/Barney/ba_pain07.wav"),
   Sound("vo/npc/Barney/ba_pain09.wav"),
   Sound("vo/npc/Barney/ba_ohshit03.wav"), --heh
   Sound("vo/npc/Barney/ba_no01.wav"),
   Sound("vo/npc/male01/no02.wav"),
   Sound("hostage/hpain/hpain1.wav"),
   Sound("hostage/hpain/hpain2.wav"),
   Sound("hostage/hpain/hpain3.wav"),
   Sound("hostage/hpain/hpain4.wav"),
   Sound("hostage/hpain/hpain5.wav"),
   Sound("hostage/hpain/hpain6.wav")
};
function SWEP:doFeign( atk, dmginfo )
	local dur = self.data.duration*( 1 - ( 1 - self:getCloak()) ) 
	self:setCloakStart( CurTime() ) 
	self:setCloakDuration( dur )
	self.Owner:feignDeath( true, atk, dmginfo, self.data )
	sound.Play(table.Random(deathsounds), self.Owner:GetShootPos(), 90, 100)
end 

function SWEP:disableInvis()
	local o = self.Owner
	if IsValid( o ) then 
		if o:isInvis() then 
         if SERVER then 
		    	o:feignDeath( false, nil, nil, self.data )
				net.Start( "DisableCloakViewModel" )
				net.Send( o )
			end 
			local start = self:getCloakStart()
			local dur = self:getCloakDuration()
			local c = math.Clamp( ( (start + dur - CurTime() )/self.data.duration  ) - self.data.cloakReduction, 0, 1 )
			self:setCloak( c )
			self:setCloakEnd( CurTime() )
			self:setCloakEndNum( self:getCloak() )
		end
	end 
end 
