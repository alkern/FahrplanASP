%------------------MODELL-----------------------------------%


%Nur für Endhaltestellen!
% anab( Linie_Ab, Linie_An,
%       T_Ab,     T_An,
%       Zugtyp,
%       Tageszeit).


% periode(Tageszeit, Dauer).



%----------------CONSTRAINTS--------------------------------%

% Jede Ankunft an der Endhaltestelle entspricht einer Abfahrt an der Starthaltestelle und umgekehrt

:- anab(Linie, _,
        T_Ab, _,
        Zugtyp,
        Tageszeit),
   not anab(_, Linie,
	    _,   (T_Ab + Fahrzeit) \ Periode,
	    Zugtyp,
	    Tageszeit),
   periode(Tageszeit, Periode),
   fahrzeit(Linie, Fahrzeit).

:- not anab(Linie, _,
            (T_An - Fahrzeit) \ Periode, _,
            Zugtyp,
            Tageszeit),
   anab(_, Linie,
	_,  T_An,
	Zugtyp,
	Tageszeit),
   periode(Tageszeit, Periode),
   fahrzeit(Linie, Fahrzeit).

% Es durfen nicht mehr Fahrzeuge als vorhanden eingesetzt werden

:- #sum{ Fahrzeit + ((T_Ab - T_An) \ Periode)
           : fahrzeit(Linie_Ab, Fahrzeit), anab(Linie_Ab, Linie_An, T_Ab, T_An, Zugtyp, Tageszeit) 
       } > Periode * Fahrzeuganzahl,
   periode(Tageszeit, Periode),
   fahrzeugtyp(Zugtyp, Fahrzeuganzahl).
