%------------------Modell-----------------------------------%

% periode( TAGESZEIT, PERIODE).
%    Der Fahrplan soll fur jede TAGESZEIT immer periodisch erstellt werden.
%    Z.B. wiederholt sich der Fahrplan jede Stunde, dann ist PERIODE=60,
%    und An- und Abfahrtszeiten fur alle Stunden identisch.
%    Ebenso kann PERIODE=10, PERIODE=15, PERIODE=20 oder PERIODE=30
%    sinnvoll sein, um den Fahrgasten immer gleich gute Anschlusse anzubieten.


%------------------Regeln-----------------------------------%

% delta_mod_periode: Hilfsfunktion.
%      T1, T2: Zeitpunkte innerhalb der PERIODE
%      DELTA_T = (T2 - T1) mod PERIODE
delta_mod_periode( T2, T1, DELTA_T, TAGESZEIT)
    :- T1 = 0 .. PERIODE -1,
       T2 = 0 .. PERIODE -1,
       periode(TAGESZEIT, PERIODE),
       % ((T2 - T1) \ PERIODE) gibt  seltsamerweise negetave Ausgaben,
       % falls (T2 - T1) negativ. Wenn wir noch eine PERIODE dazurechnen,
       % dann wird der Wert positiv und bekommen mit abermaligen
       % modulo den korrekten Wert.
       (((T2 - T1) \ PERIODE) + PERIODE ) \ PERIODE = DELTA_T.

% anab( LINIE_AN, LINIE_AB, T_AN, T_AB, ZUGTYP, TAGESZEIT).
%    Ankunft und Abfahrt an Endhaltestelle von LINIE_AN == Starthaltestelle von LINIE_AB
%    LINIE_AN, LINIE_AB: LINIE in der die Strassenbahn ankommt, abfaehrt
%    T_AN, T_ab: Ankunfs- bzw. Abfahrtszeit
%    ZUGTYP
%    TAGESZEIT
#show anab/6.

% erstellung moeglicher abfahrten an starthaltestellen
{ anab(LINIE_AN, LINIE_AB, T_AN, T_AB, ZUGTYP, TAGESZEIT)
    : T_AN = 0 .. PERIODE-1,
      T_AB = 0 .. PERIODE-1,
      starthalt(LINIE_AN, HALT),
      endhalt(LINIE_AB, HALT)
} ANZAHL_FAHRZEUGE
    :- fahrzeuganzahl(ZUGTYP, ANZAHL_FAHRZEUGE, TAGESZEIT),
       periode(TAGESZEIT, PERIODE).


% zeitunterschied zwischen zwei abfahrten einer linie
abfahrt_nach(LINIEN_ID, T_AB_PREV, T_AB_NEXT, DELTA_T, ZUGTYP_NEXT, TAGESZEIT)
  :- anab(_, LINIEN_ID, _, T_AB_PREV, _, TAGESZEIT),
     anab(_, LINIEN_ID, _, T_AB_NEXT, ZUGTYP_NEXT, TAGESZEIT),
     periode(TAGESZEIT, PERIODE),
     (DELTA_T, T_AB_NEXT) =
        #min{ (PERIODE, T_AB_PREV) ;
	      (DELTA, T_AB_N)
	            : anab(_, LINIEN_ID, _, T_AB_N, _, TAGESZEIT),
	              delta_mod_periode(T_AB_N, T_AB_PREV, DELTA, TAGESZEIT),
	              T_AB_N != T_AB_PREV }.

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
    :- ANZAHL = #max { ANZ : passagiere_nach_halt(LINIEN_ID, HALT, TAGESZEIT, ANZ) },
       passagiere_nach_halt(LINIEN_ID, _, TAGESZEIT, ANZAHL).

%----------------CONSTRAINTS--------------------------------%
% Jede Ankunft an der Endhaltestelle einer linie entspricht der vorigen Abfahrt an der Starthaltestelle dieser LINIE und umgekehrt
:- anab(LINIE, _, T_AB, _, ZUGTYP, TAGESZEIT),
   not anab(_, LINIE, _, (((T_AB + FAHRZEIT) \ PERIODE) + PERIODE) \ PERIODE, ZUGTYP, TAGESZEIT),
   periode(TAGESZEIT, PERIODE),
   fahrzeit(LINIE, FAHRZEIT).

:- not anab(LINIE, _, (((T_AN - FAHRZEIT) \ PERIODE) + PERIODE) \ PERIODE, _, ZUGTYP, TAGESZEIT),
   anab(_, LINIE, _,  T_AN, ZUGTYP, TAGESZEIT),
   periode(TAGESZEIT, PERIODE),
   fahrzeit(LINIE, FAHRZEIT).

% Keine zeitgleichen Abfahrten
:- anab(LINIE_AB, _, T_AB, T_AN_1, _, TAGESZEIT),
   anab(LINIE_AB, _, T_AB, T_AN_2, _, TAGESZEIT),
   T_AN_1 != T_AN_2.
:- anab(LINIE_AB, _, T_AB, _, ZUGTYP_1, TAGESZEIT),
   anab(LINIE_AB, _, T_AB, _, ZUGTYP_2, TAGESZEIT),
   ZUGTYP_1 != ZUGTYP_2.

% Je Zugtyp durfen nicht mehr Fahrzeuge als vorhanden eingesetzt werden
:- #sum{ FAHRZEIT + DELTA_T, LINIE_AB, T_AB
           : fahrzeit(LINIE_AB, FAHRZEIT),
	     anab(LINIE_AB, LINIE_AN, T_AB, T_AN, ZUGTYP, TAGESZEIT),
	     delta_mod_periode(T_AB, T_AN, DELTA_T, TAGESZEIT)
       } > PERIODE * FAHRZEUGANZAHL,
   periode(TAGESZEIT, PERIODE),
   fahrzeugtyp(ZUGTYP, FAHRZEUGANZAHL).
   
% die naechste ankommende Bahn, muss gross genug sein, um die Passagiere aufnehmen zu koennen, die sich in der zwischenzeit angesammelt haben
:- abfahrt_nach(LINIEN_ID, _, _, DELTA_T, ZUGTYP_NEXT, TAGESZEIT),
   fahrzeugtyp(ZUGTYP_NEXT, PLATZ),
   PLATZ * 60 < ANZAHL_PRO_STUNDE * DELTA_T,
   periode(TAGESZEIT, PERIODE),
   max_passagiere_linienrichtung(LINIEN_ID, TAGESZEIT, ANZAHL_PRO_STUNDE).

% mind. 1 Bahn muss auf jeder Linie unterwegs sein
:- not anab(LINIEN_ID, _, _, _, _, TAGESZEIT),
   periode(TAGESZEIT, _),
   linie(LINIEN_ID).
