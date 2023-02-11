import "Turbine"
import "Turbine.Gameplay"
import "Turbine.UI"
import "Turbine.UI.Lotro"

Players = class(Turbine.Gameplay.Actor);
function Players:Constructor()
    Turbine.Gameplay.Actor.Constructor( self );
    
end