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

% erstellung moeglicher abfahrten an starthaltestellen
{ anab(LINIE_AN, LINIE_AB, T_AN, T_AB, ZUGTYP, TAGESZEIT) : T_AN = 0 .. PERIODE-1, T_AB = 0..PERIODE-1 } ANZAHL_FAHRZEUGE
    :- fahrzeuganzahl(ZUGTYP, ANZAHL_FAHRZEUGE, TAGESZEIT),
       starthalt(LINIE_AN, HALT),
       endhalt(LINIE_AB, HALT),
       periode(TAGESZEIT, PERIODE).

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

%anab(hin_1, ruck_1, 0,0, typ_1, morgens).

% naechster zug der Linie faehrt an haltestelle in delta_t ab
abfahrt_nach(LINIE_AB, T_AB_PREV, DELTA_T, ZUGTYP_NEXT, TAGESZEIT)
  :- periode(TAGESZEIT, PERIODE),
     anab(_, LINIE_AB, _, T_AB_PREV, _, TAGESZEIT),
     anab(_, LINIE_AB, _, (T_AB_PREV + DELTA_T) \ PERIODE, ZUGTYP_NEXT, TAGESZEIT),
     DELTA_T = #min{ (T_AB_N - T_AB_PREV) \ PERIODE : anab(_, LINIE_AB, _, T_AB_N, _, TAGESZEIT) }.

% Je Zugtyp durfen nicht mehr Fahrzeuge als vorhanden eingesetzt werden
:- #sum{ Fahrzeit + ((T_Ab - T_An) \ Periode)
           : fahrzeit(Linie_Ab, Fahrzeit), anab(Linie_Ab, Linie_An, T_Ab, T_An, Zugtyp, Tageszeit) 
       } > Periode * Fahrzeuganzahl,
   periode(Tageszeit, Periode),
   fahrzeugtyp(Zugtyp, Fahrzeuganzahl).

% passagiere_nach_halt(linien_id, halt, anzahl_passagiere).
%   linien_id: Linie und Richtigung
%   halt: Haltestelle
%   anzahl_passagie: Anzahl der Passagiere nach der Abfahrt von Haltepunkt (zwischen den Haltepunkten) pro Stunde

passagiere_nach_halt(LINIEN_ID, HALT, TAGESZEIT, ANZAHL)
    :- starthalt(LINIEN_ID, HALT), einstiege(HALT, LINIEN_ID, TAGESZEIT, ANZAHL).

passagiere_nach_halt(LINIEN_ID, HALT, TAGESZEIT, ANZ_PREV + EINST - AUSST)
    :- einstiege(HALT, LINIEN_ID, TAGESZEIT, EINST),
       ausstiege(HALT, LINIEN_ID, TAGESZEIT, AUSST),
       passagiere_nach_halt(LINIEN_ID, HALT_PREV, TAGESZEIT, ANZ_PREV),
       elementarfahrzeit(HALT_PREV, HALT, LINIEN_ID, _).

% passagie_linienrichtung(linien_id, anzahl).
%   linien_id: Linie und Richtung
%   anzahl: Anzahl der Passiegiere pro Stunde, die auf dem Streckenabschnitt mit maximaler Auslastung zwischen zwei Haltepunkten transportiert werden mussen
passagiere_linienrichtung(LINIEN_ID, TAGESZEIT, ANZAHL)
    :- ANZAHL = #max { ANZ : passagiere_nach_halt(LINIEN_, HALT, TAGESZEIT, ANZ) }, passagiere_nach_halt(LINIEN_ID, _, TAGESZEIT, _).

% die naechste ankommende Bahn, muss grosz genug sein, um die Passagiere aufnehmen zu koennen, die sich in der zwischenzeit angesammelt haben
:- abfahrt_nach(LINIE_AB, T_AB_PREV, DELTA_T, ZUGTYP_NEXT, TAGESZEIT),
   fahrzeugtyp(ZUGTYP_NEXT, PLATZ),
   PLATZ < ANZAHL_PRO_STUNDE / 60 * DELTA_T,
   periode(TAGESZEIT, PERIODE),
   passagiere_linienrichtung(LINIEN_ID, TAGESZEIT, ANZAHL_PRO_STUNDE).
