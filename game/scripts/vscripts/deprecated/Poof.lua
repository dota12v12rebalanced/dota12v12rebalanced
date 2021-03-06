local Poof = class({});
local Utilities = Utilities or require("Utilities");

local POOF_PARTICLE = "particles/units/heroes/hero_meepo/meepo_poof_end.vpcf";

function Poof:Precache( context )
	PrecacheResource( "particle", POOF_PARTICLE, context );
end

function Poof:Initialize()
    -- ListenToGameEvent( "npc_spawned", Dynamic_Wrap( Poof, "OnNPCSpawned" ), Poof );
    Utilities:RegisterGameEventListener( "npc_spawned", Poof.OnNPCSpawned, Poof );
end

-- forces poof to happen only once per player
-- needed for hidden Monkey King clones
local Seen = {};

function Poof:OnNPCSpawned( event )
    -- event.entindex
    local hScript = EntIndexToHScript(event.entindex);
    local playerId = hScript:GetPlayerOwnerID();

    -- do not care about non heroes
    if not hScript:IsRealHero() or Seen[playerId] then
        return;
    else
        Seen[playerId] = true;
    end

    local player = hScript:GetPlayerOwner();
    local particle = ParticleManager:CreateParticle( POOF_PARTICLE, PATTACH_ABSORIGIN, hScript);
    EmitSoundOn("Custom_Game.Hero.Spawned", hScript);
    ParticleManager:ReleaseParticleIndex(particle);
    hScript:SetThink(function ()
        ParticleManager:DestroyParticle(particle, true);
        StopSoundOn("Custom_Game.Hero.Spawned", hScript);
    end, "Destroy Poof Particle", 1);
end

return Poof;