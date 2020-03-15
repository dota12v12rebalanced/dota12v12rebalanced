-- Generated from template

if GameMode == nil then
	GameMode = class({});
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = GameMode();
	GameRules.AddonTemplate:InitGameMode();
end

GoldTuner = require("GoldTuner");
ExperienceTuner = require("ExperienceTuner");
PostGameStats = require("PostGameStats");
DisableHelp = require("DisableHelp");
Kick = require("Kick");

function GameMode:InitGameMode()

	-- Game Setup Phase
	GameRules:SetCustomGameSetupTimeout( 5 ); -- must be > 0 or host will be unable to pick hero; besides that, value does not seem to matter
	GameRules:EnableCustomGameSetupAutoLaunch( true );
	GameRules:SetCustomGameSetupAutoLaunchDelay( 15 + 1 );
	GameRules:LockCustomGameSetupTeamAssignment( false );

	-- Adjust team limits
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 12 );
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 12 );

	-- Hero Selection Phase 
	-- GameRules:SetHeroSelectionTime( 30 ); -- ignored when EnablePickRules is enabled
	GameRules:SetStrategyTime( 0 );
	GameRules:SetShowcaseTime( 0 );
	GameRules:SetHeroSelectPenaltyTime( 15 );
	GameRules:GetGameModeEntity():SetSelectionGoldPenaltyEnabled( true );
	GameRules:GetGameModeEntity():SetDraftingBanningTimeOverride( 15 ); -- 15 CHECK
	GameRules:GetGameModeEntity():SetDraftingHeroPickSelectTimeOverride( 30 );

	-- Pre Game Phase
	GameRules:SetPreGameTime( 90 ); -- 90 CHECK

	-- Game Rules
	GameRules:SetStartingGold( 800 );
	GameRules:GetGameModeEntity():SetRespawnTimeScale( 1.0 );
	
	-- GameRules:SetGoldTickTime( 0.5 ); -- no longer works
	-- GameRules:SetGoldPerTick( 2 );  -- no longer works
	GameRules:GetGameModeEntity():SetPauseEnabled( false );
	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled( true );

	-- Game Tuner (Filters and Thinkers)
	GoldTuner:Initialize( GameRules );
	ExperienceTuner:Initialize( GameRules );

	-- Anti-Troll
	DisableHelp:Initialize();
	Kick:Initialize();

	-- Game Thinkers
	GameRules:GetGameModeEntity():SetThink( "GameTimeThinker", GameMode, "GameTimeThinker", 1 );

	-- Game Events
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap( GameMode, 'OnGameRulesStateChange'), GameMode );

	-- Other
	-- GameRules:GetGameModeEntity():SetMaximumAttackSpeed( 9999 );
	-- GameRules:GetGameModeEntity():SetThink( "AfterDelay", GameMode, "AfterDelay", 30 ); -- CHECK

end

-- for testing
function GameMode:AfterDelay()
	-- GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS );
end


-- trigger every second of game time
function GameMode:GameTimeThinker()
	local gameState = GameRules:State_Get();
	local time = GameRules:GetDOTATime(false, false);
	if gameState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		GoldTuner:UpdateFactor( time );
		ExperienceTuner:UpdateFactor( time );
	elseif gameState >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

-- call when game state changes
function GameMode:OnGameRulesStateChange()
	local gameState = GameRules:State_Get();
	if gameState == DOTA_GAMERULES_STATE_POST_GAME then
		PostGameStats:SetNetTable();
	end 

end