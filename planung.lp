%------------------Regeln-----------------------------------%
% anab( LINIE_AN, LINIE_AB, T_AN, T_AB, ZUGTYP, TAGESZEIT).
%    Ankunft und Abfahrt an Endhaltestelle von LINIE_AN == Starthaltestelle von LINIE_AB
%    LINIE_AN, LINIE_AB: LINIE in der die Strassenbahn ankommt, abfaehrt
%    T_AN, T_ab: Ankunfs- bzw. Abfahrtszeit
%    ZUGTYP
%    TAGESZEIT

% erstellung moeglicher abfahrten an starthaltestellen
{ anab(LINIE_AN, LINIE_AB, T_AN, T_AB, ZUGTYP, TAGESZEIT) : T_AN = 0 .. PERIODE-1, T_AB = 0..PERIODE-1 } ANZAHL_FAHRZEUGE
    :- fahrzeuganzahl(ZUGTYP, ANZAHL_FAHRZEUGE, TAGESZEIT),
       starthalt(LINIE_AN, HALT),
       endhalt(LINIE_AB, HALT),
       periode(TAGESZEIT, PERIODE).


% zeitunterschied zwischen zwei abfahrten einer linie
abfahrt_nach(LINIE_AB, T_AB_PREV, T_AB_NEXT, ZUGTYP_NEXT, TAGESZEIT)
  :- periode(TAGESZEIT, PERIODE),
     anab(_, LINIE_AB, _, T_AB_PREV, _, TAGESZEIT),
     anab(_, LINIE_AB, _, T_AB_NEXT, ZUGTYP_NEXT, TAGESZEIT),
     (T_AB_NEXT - T_AB_PREV) \ PERIODE = #min{ (T_AB_N - T_AB_PREV) \ PERIODE : anab(_, LINIE_AB, _, T_AB_N, _, TAGESZEIT) }.

% passagiere_nach_halt(linien_id, halt, anzahl_passagiere). Passagiere in der Bahn nach dem sie an einem Haltepunkt war
%   linien_id: LINIE und Richtigung
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
%   linien_id: linie und Richtung
%   anzahl: Anzahl der Passiegiere pro Stunde, die auf dem Streckenabschnitt mit maximaler Auslastung zwischen zwei Haltepunkten transportiert werden mussen
max_passagiere_linienrichtung(LINIEN_ID, TAGESZEIT, ANZAHL)
    :- ANZAHL = #max { ANZ : passagiere_nach_halt(LINIEN_, HALT, TAGESZEIT, ANZ) }, passagiere_nach_halt(LINIEN_ID, _, TAGESZEIT, _).

%----------------CONSTRAINTS--------------------------------%
% Jede Ankunft an der Endhaltestelle einer linie entspricht der vorigen Abfahrt an der Starthaltestelle dieser LINIE und umgekehrt
:- anab(LINIE, _, T_AB, _, ZUGTYP, TAGESZEIT),
   not anab(_, LINIE, _, (T_AB + FAHRZEIT) \ PERIODE, ZUGTYP, TAGESZEIT),
   periode(TAGESZEIT, PERIODE),
   fahrzeit(LINIE, FAHRZEIT).

:- not anab(LINIE, _, (T_AN - FAHRZEIT) \ PERIODE, _, ZUGTYP, TAGESZEIT),
   anab(_, LINIE, _,  T_AN, ZUGTYP, TAGESZEIT),
   periode(TAGESZEIT, PERIODE),
   fahrzeit(LINIE, FAHRZEIT).

% Je Zugtyp durfen nicht mehr Fahrzeuge als vorhanden eingesetzt werden
:- #sum{ FAHRZEIT + ((T_AB - T_AN) \ PERIODE)
           : fahrzeit(LINIE_AB, FAHRZEIT), anab(LINIE_AB, LINIE_AN, T_AB, T_AN, ZUGTYP, TAGESZEIT) 
       } > PERIODE * FAHRZEUGANZAHL,
   periode(TAGESZEIT, PERIODE),
   fahrzeugtyp(ZUGTYP, FAHRZEUGANZAHL).
   
% die naechste ankommende Bahn, muss gross genug sein, um die Passagiere aufnehmen zu koennen, die sich in der zwischenzeit angesammelt haben
:- abfahrt_nach(LINIE_AB, T_AB_PREV, T_AB_NEXT, ZUGTYP_NEXT, TAGESZEIT),
   fahrzeugtyp(ZUGTYP_NEXT, PLATZ),
   PLATZ < ANZAHL_PRO_STUNDE / 60 * ((T_AB_NEXT - T_AB_PREV) \ PERIODE),
   periode(TAGESZEIT, PERIODE),
   max_passagiere_linienrichtung(LINIEN_ID, TAGESZEIT, ANZAHL_PRO_STUNDE).