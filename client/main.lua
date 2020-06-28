ESX = nil
local IsAlreadyDrug = false
local DrugLevel = -1

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

AddEventHandler('esx_status:loaded', function(status)

  TriggerEvent('esx_status:registerStatus', 'drug', 0, '#9ec617', 
    function(status)
      if status.val > 0 then
        return true
      else
        return false
      end
    end, function(status)
      status.remove(1500)
    end)

	Citizen.CreateThread(function()
		while true do

			Wait(1000)

			TriggerEvent('esx_status:getStatus', 'drug', function(status)

		if status.val > 0 then
          local start = true

          if IsAlreadyDrug then
            start = false
          end

          local level = 0

          if status.val <= 999999 then
            level = 0
          else
            overdose()
          end

          if level ~= DrugLevel then
          end

          IsAlreadyDrug = true
          DrugLevel = level
		end

		if status.val == 0 then
          
          if IsAlreadyDrug then
            Normal()
          end

          IsAlreadyDrug = false
          DrugLevel     = -1
		end
			end)
		end
	end)
end)

--When effects ends go back to normal
function Normal()

  Citizen.CreateThread(function()
    local playerPed = GetPlayerPed(-1)
			
    ClearTimecycleModifier()
    ResetScenarioTypesEnabled()
    --ResetPedMovementClipset(playerPed, 0) <- it might cause the push of the vehicles
    SetPedIsDrug(playerPed, false)
    SetPedMotionBlur(playerPed, false)
  end)
end

--In case too much drugs dies of overdose set everything back
function overdose()

  Citizen.CreateThread(function()
    local playerPed = GetPlayerPed(-1)
	
    SetEntityHealth(playerPed, 0)
    ClearTimecycleModifier()
    ResetScenarioTypesEnabled()
    ResetPedMovementClipset(playerPed, 0)
    SetPedIsDrug(playerPed, false)
    SetPedMotionBlur(playerPed, false)
  end)
end

--Acid trip
local Cubes = {}

local LastPedInteraction = 0
local LastPedTurn
local PedSpawned
local EvilPed

DoAcid = function(time)
  local song = (time and time >= 200000 and 2 or 1)
  SendNUIMessage({type = "playMusic", song = song})

  InitCubes()

  local step = 0
  local timer = GetGameTimer() 
  local ped = GetPlayerPed(-1)
  local lastPos = GetEntityCoords(ped)

  while GetGameTimer() - timer < time do
    local plyPos = GetEntityCoords(GetPlayerPed(-1))
    local dist = GetVecDist(lastPos,plyPos)
    if dist > 1.0 then
      step = step + 1
      if step == 5 then
        step = 0
        local dir = (lastPos - plyPos)
        local vel = GetEntityVelocity(GetPlayerPed(-1))
        SetEntityCoordsNoOffset(GetPlayerPed(-1),plyPos.x + dir.x, plyPos.y + dir.y,plyPos.z)
        ForcePedMotionState(GetPlayerPed(-1), -1115154469, 1, 1, 0)
        SetEntityVelocity(GetPlayerPed(-1), vel.x,vel.y,vel.z)
      end
      lastPos = GetEntityCoords(GetPlayerPed(-1))
    end

    DrawToons()
    DrawCubes()

    if not PedSpawned then 
      PedSpawned = true
      Citizen.CreateThread(InitPed)
    end
    Wait(0)
  end

  ClearTimecycleModifier()
  ShakeGameplayCam('DRUNK_SHAKE', 0.0)  
  SetPedMotionBlur(GetPlayerPed(-1), false)

  SetEntityAsMissionEntity(EvilPed,true,true)
  DeleteEntity(EvilPed)

  SendNUIMessage({type = "stopMusic"})

  Cubes = {}

  LastPedInteraction = 0
  LastPedTurn = nil
  PedSpawned = nil
  EvilPed = nil
end

InitPed = function()
  local plyPed = GetPlayerPed(-1)
  local pos = GetEntityCoords(plyPed)

  local randomAlt     = math.random(0,359)
  local randomDist    = math.random(50,80)
  local spawnPos      = pos + PointOnSphere(0.0,randomAlt,randomDist)

  while World3dToScreen2d(spawnPos.x,spawnPos.y,spawnPos.z) and not IsPointOnRoad(spawnPos.x,spawnPos.y,spawnPos.z) do 
    randomAlt   = math.random(0,359)
    randomDist  = math.random(50,80)
    spawnPos    = GetEntityCoords(GetPlayerPed(-1)) + PointOnSphere(0.0,randomAlt,randomSphere)
    Citizen.Wait(0)
  end 

  EvilPed = ClonePed(plyPed, GetEntityHeading(plyPed), false, false)
  Wait(10)
  SetEntityCoordsNoOffset(EvilPed, spawnPos.x,spawnPos.y,spawnPos.z + 1.0)
  SetPedComponentVariation(EvilPed, 1, 60, 0, 0, 0)

  SetEntityInvincible(EvilPed,true)
  SetBlockingOfNonTemporaryEvents(EvilPed,true)

  TrackEnt()
end

TrackEnt = function()
  while true do
    local dist = GetVecDist(GetEntityCoords(GetPlayerPed(-1)), GetEntityCoords(EvilPed))
    if dist > 5.0 then
      TaskGoToEntity(EvilPed, GetPlayerPed(-1), -1, 4.0, 100.0, 1073741824, 0)
      Wait(1000)
    else       
      if not IsTaskMoveNetworkActive(EvilPed) then
        RequestAnimDict("anim@mp_point")
        while not HasAnimDictLoaded("anim@mp_point") do Wait(0); end
        TaskMoveNetworkByName(EvilPed, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
        SetPedCurrentWeaponVisible(EvilPed, 0, 1, 1, 1)
        SetPedConfigFlag(EvilPed, 36, 1)
      end

      if not LastPedTurn or (GetGameTimer() - LastPedTurn) > 1000 then
        LastPedTurn = GetGameTimer()
        TaskTurnPedToFaceEntity(EvilPed, GetPlayerPed(-1), -1)
      end

      SetTaskMoveNetworkSignalFloat (EvilPed, "Pitch",          0.4)
      SetTaskMoveNetworkSignalFloat (EvilPed, "Heading",        0.5)
      SetTaskMoveNetworkSignalBool  (EvilPed, "isBlocked",      false)
      SetTaskMoveNetworkSignalBool  (EvilPed, "isFirstPerson",  false)

      if IsPedRagdoll(EvilPed) then
        while IsPedRagdoll(EvilPed) do Wait(0); end
        ClearPedTasksImmediately(EvilPed)
        Wait(10)
      end
      Wait(0)
    end
  end
end

InitCubes = function()
  for i=1,25,1 do
    local r = math.random(5,255)
    local g = math.random(5,255)
    local b = math.random(5,255)
    local a = math.random(50,100)

    local x = math.random(1,180)
    local y = math.random(1,359)
    local z = math.random(15,35)

    Cubes[i] = {pos=PointOnSphere(x,y,z),points={x=x,y=y,z=z},col={r=r, g=g, b=b, a=a}}
  end  

  ShakeGameplayCam('DRUNK_SHAKE', 0.0) 
  SetTimecycleModifierStrength(0.0) 
  SetTimecycleModifier("BikerFilter")
  SetPedMotionBlur(GetPlayerPed(-1), true)

  local counter = 4000
  local tick = 0
  while tick < counter do
    tick = tick + 1
    local plyPos = GetEntityCoords(GetPlayerPed(-1))
    local adder = 0.1 * (tick/40)
    SetTimecycleModifierStrength(math.min(0.1 * (tick/(counter/40)),1.5))
    ShakeGameplayCam('DRUNK_SHAKE', math.min(0.1 * (tick/(counter/40)),1.5))  
    for k,v in pairs(Cubes) do
      local pos = plyPos + v.pos
      DrawBox(pos.x+adder,pos.y+adder,pos.z+adder,pos.x-adder,pos.y-adder,pos.z-adder, v.col.r,v.col.g,v.col.g,v.col.a)
      local points = {x=v.points.x+0.1,y=v.points.y+0.1,z=v.points.z}
      Cubes[k].points = points
      Cubes[k].pos = PointOnSphere(points.x,points.y,points.z)
    end
    Wait(0)
  end
end

DrawCubes = function()
  local position = GetEntityCoords(GetPlayerPed(-1))
  local adder = 10
  for k,v in pairs(Cubes) do
    local addX = 0.1
    local addY = 0.1

    if k%4 == 0 then
      addY = -0.1
    elseif k%3 == 0 then
      addX = -0.1
    elseif k%2 == 0 then
      addX = -0.1
      addY = -0.1
    end

    local pos = position + v.pos
    DrawBox(pos.x+adder,pos.y+adder,pos.z+adder,pos.x-adder,pos.y-adder,pos.z-adder, v.col.r,v.col.g,v.col.g,v.col.a)
    local points = {x=v.points.x+addX,y=v.points.y+addY,z=v.points.z}
    Cubes[k].points = points
    Cubes[k].pos = PointOnSphere(points.x,points.y,points.z)
  end
end

GetVecDist = function(v1,v2)
  if not v1 or not v2 or not v1.x or not v2.x then return 0; end
  return math.sqrt(  ( (v1.x or 0) - (v2.x or 0) )*(  (v1.x or 0) - (v2.x or 0) )+( (v1.y or 0) - (v2.y or 0) )*( (v1.y or 0) - (v2.y or 0) )+( (v1.z or 0) - (v2.z or 0) )*( (v1.z or 0) - (v2.z or 0) )  )
end

PointOnSphere = function(alt,azu,radius,orgX,orgY,orgZ)
  local toradians = 0.017453292384744
  alt,azu,radius,orgX,orgY,orgZ = ( tonumber(alt or 0) or 0 ) * toradians, ( tonumber(azu or 0) or 0 ) * toradians, tonumber(radius or 0) or 0, tonumber(orgX or 0) or 0, tonumber(orgY or 0) or 0, tonumber(orgZ or 0) or 0
  if      vector3
  then
      return
      vector3(
           orgX + radius * math.sin( azu ) * math.cos( alt ),
           orgY + radius * math.cos( azu ) * math.cos( alt ),
           orgZ + radius * math.sin( alt )
      )
  end
end

--Drugs Effects

--Weed
RegisterNetEvent('esx_lwrpdrugeffects:onWeed')
AddEventHandler('esx_lwrpdrugeffects:onWeed', function()
  local playerPed = GetPlayerPed(-1)
  ESX.ShowNotification('You feel euphoric and relaxed. You are in an altered state of mind and sense of time. You have difficulty concentrating, impaired short-term memory and body movement, and an increase in appetite.')
    RequestAnimSet("move_m@hipster@a") 
    while not HasAnimSetLoaded("move_m@hipster@a") do
      Citizen.Wait(0)
    end    

    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
    Citizen.Wait(3000)
    ClearPedTasksImmediately(playerPed)
    SetTimecycleModifier("spectator5")
    SetPedMotionBlur(playerPed, true)
    SetPedMovementClipset(playerPed, "move_m@hipster@a", true)
    SetPedIsDrug(playerPed, true)

    --Effects
    local player = PlayerId()
    SetRunSprintMultiplierForPlayer(player, 0.7)

    Wait(300000)

    SetRunSprintMultiplierForPlayer(player, 1.0)
end)

--Morphine or Poppy Resin
RegisterNetEvent('esx_lwrpdrugeffects:onMorphine')
AddEventHandler('esx_lwrpdrugeffects:onMorphine', function()
  local playerPed = GetPlayerPed(-1)
  local maxHealth = GetEntityMaxHealth(playerPed)
  ESX.ShowNotification('You feel that your pain is reduced. You feel a bit drowsy.')

    TaskStartScenarioInPlace(playerPed, "mp_player_inteat@burger", 0, 1)
    Citizen.Wait(3000)
    ClearPedTasksImmediately(playerPed)
    SetTimecycleModifier("spectator5")
    SetPedMotionBlur(playerPed, true)
    SetPedMovementClipset(playerPed, "move_m@drunk@slightlydrunk", true)
    SetPedIsDrug(playerPed, true)

    --Effects
    local player = PlayerId()
    local health = GetEntityHealth(playerPed)
    local newHealth = math.min(maxHealth , math.floor(health + maxHealth/6))
    local afterHealth = math.min(newHealth , math.floor(newHealth - newHealth/12))
    SetEntityHealth(playerPed, newHealth)
    SetRunSprintMultiplierForPlayer(player, 0.9)

    Wait(600000)

    SetRunSprintMultiplierForPlayer(player, 1.0)
    SetEntityHealth(playerPed, afterHealth)
    ESX.ShowNotification('Some of the pain has come back. You still feel drowsy.')
 end)

--Heroin
RegisterNetEvent('esx_lwrpdrugeffects:onHeroin')
AddEventHandler('esx_lwrpdrugeffects:onHeroin', function()
  local playerPed = GetPlayerPed(-1)
  local newHealth = GetEntityMaxHealth(playerPed)
  ESX.ShowNotification('You barely feel any pain. You feel very euphoric, alert and drowsy. You have impaired body movement.')
  
        RequestAnimSet("move_m@drunk@moderatedrunk") 
    while not HasAnimSetLoaded("move_m@drunk@moderatedrunk") do
      Citizen.Wait(0)
    end    

    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
    Citizen.Wait(3000)
    ClearPedTasksImmediately(playerPed)
    SetTimecycleModifier("spectator5")
    SetPedMotionBlur(playerPed, true)
    SetPedMovementClipset(playerPed, "move_m@drunk@moderatedrunk", true)
    SetPedIsDrug(playerPed, true)

    --Effects
    local player = PlayerId()
    local health = GetEntityHealth(playerPed)
    local afterHealth = math.min(newHealth, math.floor(newHealth - newHealth/6))
    SetEntityHealth(playerPed, newHealth)
    SetRunSprintMultiplierForPlayer(player, 0.8)

    Wait(520000)

    SetRunSprintMultiplierForPlayer(player, 1.0)
    SetEntityHealth(playerPed, afterHealth)
    ESX.ShowNotification('Some of the pain has come back. You still feel drowsy, the other effects have faded away.')

    Wait(1040000)

    ESX.ShowNotification('You no longer feel drowsy.')
 end)

--Meth
RegisterNetEvent('esx_lwrpdrugeffects:onMeth')
AddEventHandler('esx_lwrpdrugeffects:onMeth', function()
  local playerPed = GetPlayerPed(-1)
  local maxHealth = GetEntityMaxHealth(playerPed)
  ESX.ShowNotification('You veel very euphoric. You are sweating excessively, have increased movement and have a dry mouth. You are grinding your teeth.')

        RequestAnimSet("move_m@hurry_butch@a") 
    while not HasAnimSetLoaded("move_m@hurry_butch@a") do
      Citizen.Wait(0)
    end    

    TaskStartScenarioInPlace(playerPed, "mp_player_int_upperarse_pick", 0, 1)
    Citizen.Wait(3000)
    ClearPedTasksImmediately(playerPed)
    SetTimecycleModifier("spectator5")
    SetPedMotionBlur(playerPed, true)
    SetPedMovementClipset(playerPed, "move_m@hurry_butch@a", true)
    SetPedIsDrug(playerPed, true)

   --Effects
    local player = PlayerId()
    SetRunSprintMultiplierForPlayer(player, 1.2)

    Wait(520000)

    SetRunSprintMultiplierForPlayer(player, 0.8) 
    ESX.ShowNotification('You no longer feel euphoric. You feel tired, have a headache and irregular heartbeat.')
    
    Wait(1040000)

    SetRunSprintMultiplierForPlayer(player, 1.0)
    ESX.ShowNotification('The effects have faded away.')
end)

--Coca Leaf
RegisterNetEvent('esx_lwrpdrugeffects:onCocaleaf')
AddEventHandler('esx_lwrpdrugeffects:onCocaleaf', function()
  local playerPed = GetPlayerPed(-1)
  local maxHealth = GetEntityMaxHealth(playerPed)
  ESX.ShowNotification('You feel energised and a bit numb. You have increased cognition and are inspired.')

        RequestAnimSet("move_m@hurry_butch@a") 
    while not HasAnimSetLoaded("move_m@hurry_butch@a") do
      Citizen.Wait(0)
    end    

    TaskStartScenarioInPlace(playerPed, "mp_player_inteat@burger", 0, 1)
    Citizen.Wait(3000)
    ClearPedTasksImmediately(playerPed)
    SetTimecycleModifier("spectator5")
    SetPedMotionBlur(playerPed, true)
    SetPedMovementClipset(playerPed, "move_m@hurry_butch@a", true)
    SetPedIsDrug(playerPed, true)

    --Effects
    local player = PlayerId()
    SetRunSprintMultiplierForPlayer(player, 1.1)

    Wait(260000)

    SetRunSprintMultiplierForPlayer(player, 0.9)
    ESX.ShowNotification('You feel a bit tired.')

    Wait(520000)

    SetRunSprintMultiplierForPlayer(player, 1.0)
    ESX.ShowNotification('You no longer feel tired.')
end)

--Coke
RegisterNetEvent('esx_lwrpdrugeffects:onCoke')
AddEventHandler('esx_lwrpdrugeffects:onCoke', function()
  local playerPed = GetPlayerPed(-1)
  ESX.ShowNotification('You feel very energised, happy, inspired and are numb. You have increased cognitive skills and an increased heart rate.')
        RequestAnimSet("move_m@hurry_butch@a") 
    while not HasAnimSetLoaded("move_m@hurry_butch@a") do
      Citizen.Wait(0)
    end    

    TaskStartScenarioInPlace(playerPed, "snort_coke_a_male2", 0, 1)
    Citizen.Wait(3000)
    ClearPedTasksImmediately(playerPed)
    SetTimecycleModifier("spectator5")
    SetPedMotionBlur(playerPed, true)
    SetPedMovementClipset(playerPed, "move_m@hurry_butch@a", true)
    SetPedIsDrug(playerPed, true)

    --Effects
    local player = PlayerId()
    SetRunSprintMultiplierForPlayer(player, 1.3)
    a = True
    while( a == True)
    do
        player.restoreStamina(player)
        Wait(10000)
    end
    
    Wait(300000)

    a = False
    SetRunSprintMultiplierForPlayer(player, 0.7)
    ESX.ShowNotification('You are very tired. You are paranoid and anxious. You have increased heart rate and blood pressure.')

    Wait(600000)

    SetRunSprintMultiplierForPlayer(player, 1.0)
    ESX.ShowNotification('The effects have faded away.')
    
end)

--LSA
RegisterNetEvent('esx_lwrpdrugeffects:onLSA', function(...) DoAcid(60000); end)

--LSD
RegisterNetEvent('esx_lwrpdrugeffects:onLSD', function(...) DoAcid(300000); end)
