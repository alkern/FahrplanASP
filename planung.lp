%------------------Regeln-----------------------------------%


% anab( Linie_An, Linie_Ab,
%       T_An,     T_Ab,
%       Zugtyp,
%       Tageszeit).
%    Ankunft und Abfahrt an Endhaltestelle von Linie_An == Starthaltestelle von Linie_Ab
%    Linie_An, Linie_Ab: Linie in der die Strassenbahn ankommt, abfaehrt
%    T_An, T_ab: Ankunfs- bzw. Abfahrtszeit
%    Zugtyp
%    Tageszeit


% periode(Tageszeit, Dauer).



%----------------CONSTRAINTS--------------------------------%

% Jede Ankunft an der Endhaltestelle einer Linie entspricht der vorigen Abfahrt an der Starthaltestelle dieser Linie und umgekehrt

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

% Je Zugtyp durfen nicht mehr Fahrzeuge als vorhanden eingesetzt werden

:- #sum{ Fahrzeit + ((T_Ab - T_An) \ Periode)
           : fahrzeit(Linie_Ab, Fahrzeit), anab(Linie_Ab, Linie_An, T_Ab, T_An, Zugtyp, Tageszeit) 
       } > Periode * Fahrzeuganzahl,
   periode(Tageszeit, Periode),
   fahrzeugtyp(Zugtyp, Fahrzeuganzahl).
