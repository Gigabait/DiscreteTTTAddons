AddCSLuaFile()

if SERVER then
   resource.AddFile("materials/vgui/ttt/icon_g3sg1.vmt")
end

SWEP.HoldType           = "ar2"

if CLIENT then
   SWEP.PrintName          = "Silenced Sniper"
   SWEP.Slot               = 6
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Silenced Rifle for Traitors only."
   };

   SWEP.Icon = "vgui/ttt/icon_g3sg1"

   SWEP.crossWidth      = 1
   SWEP.crossHeight     = 6
   SWEP.crossGapMax     = 30

end

SWEP.Base               = "weapon_tttbase"
SWEP.Spawnable = true

SWEP.Kind = WEAPON_EQUIP

SWEP.Primary.Delay          = 1
SWEP.Primary.Recoil         = 7
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "357"
SWEP.Primary.Damage = 30
SWEP.Primary.Cone               = 0.0001
SWEP.Primary.ConeMax            = 0.0009
SWEP.Primary.ConeScaleTime      = 0.1
SWEP.Primary.ConeScaleDownTime  = 0.4
SWEP.Primary.ConeDelay          = 0.1
SWEP.Primary.ClipSize = 8
SWEP.Primary.ClipMax = 24 -- keep mirrored to ammo
SWEP.Primary.DefaultClip = 24
SWEP.HeadshotMultiplier = 5
SWEP.IsSilent = true

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR} -- only traitors can buy

SWEP.AmmoEnt = "item_ammo_357_ttt"

SWEP.AutoSpawnable      = false

SWEP.UseHands			= true
SWEP.ViewModelFlip		= true
SWEP.ViewModelFOV		= 54
SWEP.ViewModel = "models/weapons/v_snip_g3sg1.mdl"
SWEP.WorldModel = "models/weapons/w_snip_g3sg1.mdl"
SWEP.Primary.Sound = Sound ("Weapon_M4A1.Silenced")

SWEP.Secondary.Sound = Sound("Default.Zoom")

SWEP.IronSightsPos      = Vector( 5, -15, -2 )
SWEP.IronSightsAng      = Vector( 2.6, 1.37, 3.5 )

SWEP.reloadTime         = 3

function SWEP:SetZoom(state)
   if CLIENT then
      return
   elseif IsValid(self.Owner) and self.Owner:IsPlayer() then
      if state then
         self.Owner:SetFOV(20, 0.3)
      else
         self.Owner:SetFOV(0, 0.2)
      end
   end
end

function SWEP:PrimaryAttack( worldsnd )
   self.BaseClass.PrimaryAttack( self.Weapon, worldsnd )
   self:SetNextSecondaryFire( CurTime() + 0.1 )
end

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
   if not self.IronSightsPos then return end
   if self:GetNextSecondaryFire() > CurTime() then return end

   local bIronsights = not self:GetIronsights()

   self:SetIronsights( bIronsights )

   if SERVER then
      self:SetZoom(bIronsights)
   else
      self:EmitSound(self.Secondary.Sound)
   end

   self:SetNextSecondaryFire( CurTime() + 0.3)
end

function SWEP:PreDrop()
   self:SetZoom(false)
   return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
    if self:canReload() then
        self.BaseClass.Reload( self )
        self:SetZoom(false)
    end
end

function SWEP:Holster()
   self:SetZoom(false)
   return self.BaseClass.Holster( self )
end

if CLIENT then
   local scope = surface.GetTextureID("sprites/scope")
   function SWEP:DrawHUD()
      if self:GetIronsights() then
         surface.SetDrawColor( 0, 0, 0, 255 )

         local scrW = ScrW()
         local scrH = ScrH()

         local x = scrW / 2.0
         local y = scrH / 2.0
         local scope_size = scrH

         -- crosshair
         local gap = 80
         local length = scope_size
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )

         gap = 0
         length = 50
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )


         -- cover edges
         local sh = scope_size / 2
         local w = (x - sh) + 2
         surface.DrawRect(0, 0, w, scope_size)
         surface.DrawRect(x + sh - 2, 0, w, scope_size)

         -- cover gaps on top and bottom of screen
         surface.DrawLine( 0, 0, scrW, 0 )
         surface.DrawLine( 0, scrH - 1, scrW, scrH - 1 )

         surface.SetDrawColor(255, 0, 0, 255)
         surface.DrawLine(x, y, x + 1, y + 1)

         -- scope
         surface.SetTexture(scope)
         surface.SetDrawColor(255, 255, 255, 255)

         surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)
      else
         return self.BaseClass.DrawHUD(self)
      end
   end

   function SWEP:AdjustMouseSensitivity()
      return (self:GetIronsights() and 0.2) or nil
   end
end