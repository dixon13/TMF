

#include "\x\tmf\addons\spectator\script_component.hpp"
if((_this select 2) isEqualType 0) then {_this set [2,false]};
params ["_unit","_oldUnit",["_forced",false,[false]]];
if(!isNil QGVAR(unit) && {player == GVAR(unit)}) exitWith {createDialog QGVAR(dialog);};


_isJip = didJIP;

// disable this to instantly switch to the spectator script.
waituntil {missionnamespace getvariable ["BIS_fnc_feedback_allowDeathScreen",true] || isNull (_oldUnit) || _isJip || _forced};


// Disable effects
if(!isnil "BIS_fnc_feedback_allowPP") then {
  // disable effects death effects
  BIS_fnc_feedback_allowPP = false;
};

if(_isJip) then {
	[] spawn {
		["tmf_spectator",false] call BIS_fnc_blackOut;
		uiSleep 3;
		["tmf_spectator"] call BIS_fnc_blackIn;
	};
};

// Create a Virtual Agent to act as our player to make sure we get to keep Draw3D
if(isNil QGVAR(unit) || (!isNil QGVAR(unit) && {!isNull GVAR(unit)}) ) then {
  _newGrp = createGroup sideLogic;
  _newUnit = _newGrp createUnit ["VirtualCurator_F", [0,0,5], [], 0, "FORM"];
  _newUnit allowDamage false;
  _newUnit hideObjectGlobal true;
  _newUnit enableSimulationGlobal false;
  _newUnit setpos [0,0,5];
  selectPlayer _newUnit;
  waituntil{player isEqualTo _newUnit};
  if(typeof _unit == "seagull") then { deleteVehicle _unit; };
  GVAR(unit) = _newUnit;
};

// If oldunit is null set a new starting target
if(isNull _oldUnit ) then {_oldUnit = allUnits select 0};

GVAR(entryside) = _oldUnit getVariable ["TMF_CreatedSide",side _oldUnit];

if(!isNil QGVAR(freecam) && {!isNull GVAR(freecam)}) exitWith {createDialog "tmf_spectator_dialog";};



GVAR(freecam) = "camera" camCreate [position _oldUnit select 0,position _oldUnit select 1,3];
GVAR(followcam) = "camera" camCreate [position _oldUnit select 0,position _oldUnit select 1,3];
GVAR(camera) = tmf_spectator_followcam;
GVAR(target) = _oldUnit;
#include "defines.hpp"

if(isNil QGVAR(objectives)) then {GVAR(objectives) = []};

// UI
GVAR(showUI) = true;
GVAR(controls) = [IDC_SPECTATOR_TMF_SPECTATOR_UNITLABEL,IDC_SPECTATOR_TMF_SPECTATOR_UNITLIST,IDC_SPECTATOR_TMF_SPECTATOR_VISION,IDC_SPECTATOR_TMF_SPECTATOR_FILTER,IDC_SPECTATOR_TMF_SPECTATOR_BUTTON,IDC_SPECTATOR_TMF_SPECTATOR_TAGS,IDC_SPECTATOR_TMF_SPECTATOR_VIEW,IDC_SPECTATOR_TMF_SPECTATOR_COMPASS,IDC_SPECTATOR_TMF_SPECTATOR_COMPASSLEFT,IDC_SPECTATOR_TMF_SPECTATOR_COMPASSRight,IDC_SPECTATOR_TMF_SPECTATOR_MUTE,IDC_SPECTATOR_TMF_SPECTATOR_MENUBACK];

GVAR(tracers) = true;
// MAP
GVAR(showMap) = false;





GVAR(grpTagScale) = profileNamespace getVariable [QGVAR(grpTagScale),1.0];
GVAR(unitTagScale) = profileNamespace getVariable [QGVAR(unitTagScale),1.0];



GVAR(camera) cameraEffect ["internal","back"];

// Set the location of the track point
_pos = getPosVisual GVAR(target);
_pos set [2,(_pos select 2)+1.3];


GVAR(followcam) camSetTarget _pos;
GVAR(followcam) camSetRelPos [2,2,3];
GVAR(relpos) = [2,2,3];


// Set FOV
GVAR(followcam) camSetFov 1.2;
GVAR(freecam) camSetFov 1.2;

// commit it
GVAR(freecam) camCommit 0;
GVAR(camera) camCommit 0;
// 0 follow cam, 1 freecam, 2 firstperson
GVAR(mode) = 0;


// Sides Button
GVAR(sides) = [blufor,civilian,opfor,independent];
GVAR(sides_button_state) = 0;
GVAR(sides_button_mode) = [ [blufor,civilian,opfor,independent],[blufor],[opfor],[independent],[civilian]];
GVAR(sides_button_strings) = ["SHOWING ALL SIDES","SHOWING BLUFOR","SHOWING OPFOR","SHOWING INDEPENDENT","SHOWING CIVILIAN"];


if(!getMissionConfigValue ["TMF_Spectator_AllSides",true]) then {
  GVAR(sides) = [tmf_spectator_entryside];
  GVAR(sides_button_mode) = [[tmf_spectator_entryside],[]];
  GVAR(sides_button_strings) = ["SHOWING YOUR SIDE","NONE"];
};

// Vision Button
GVAR(visionMode) = 0;
GVAR(visionMode_strings) = ["NORMAL","NIGHTVISION","WHITE HOT"];

GVAR(freecamAcceleration) = 0.1;

// Show Players only
GVAR(playersOnly) = false;
if(isMultiplayer) then {
    GVAR(playersOnly) = true;
};

// Mouse
GVAR(mButtons) = [false,false];
GVAR(mPos) = [0,0];
GVAR(lmPos) = [0,0];

// Follow Cam
GVAR(followcam_angle) = [0,0];
GVAR(followcam_zoom) = 0.3;
GVAR(followcam_fov) = 0.7;

// Freecam
GVAR(freecam_speedmod) = profileNamespace getVariable [QGVAR(freecam_speedmod),4];
GVAR(freecam_speedmod_max) = 10;
GVAR(freecam_speedmod_min) = 1;

GVAR(freecam_speed_timestamp) = 0;

GVAR(freecam_move) = [0,0,0];
GVAR(freecam_timestamp) = time;
GVAR(rounds) = [];


// WASD Q/E scroll
GVAR(movement_keys) = [false,false,false,false,false,false,0];

// Ctrl , alt , shift
GVAR(modifiers_keys) = [false,false,false];

// Tags
GVAR(tags) = true;
GVAR(showlines) = false;

GVAR(allunits) = [];
GVAR(groups) = [];
GVAR(vehicles) = [];
GVAR(clearGroups) = false;
GVAR(unitUpdate) = 0;
GVAR(killedUnits) = [];
// Set Modes
cameraEffectEnableHUD true;
showCinemaBorder false;
GVAR(mute_key) = -1;
GVAR(mute_modifers) = [false,false,false];

createDialog QGVAR(dialog);

//Add to the text channel.
GVAR(radioChannel) radioChannelAdd [player];
setCurrentChannel (GVAR(radioChannel)+5);
{
    _x enableChannel false;
} forEach [1,2,3,4,5];

if !([] call tmf_common_fnc_isAdmin) then {
    0 enableChannel false;
};

addMissionEventHandler ["EntityKilled",{
    params ["_killed","_killer"];
    if(!(side _killed in [blufor,opfor,independent,civilian]) || !(_killed isKindOf "CAManBase" || _killed isKindOf "AllVehicles") ) exitwith {};

    _kName = "";
    _dName = "";
    if(isPlayer _killed) then {_dName = name (_killed);};
    if(isPlayer _killer) then {_kName = name (_killer);};

    GVAR(killedUnits) pushback [_killed,time,_killer,side group _killed,side group _killer,_dName,_kName,currentWeapon _killer];
}];


GVAR(currentnotification) = "";
GVAR(notification) = [];










["tmf_spectator", "onEachFrame", {
	[] call FUNC(perFrameHandler);
}] call BIS_fnc_addStackedEventHandler;
[QGVAR(init), _this] call EFUNC(event,emit);
