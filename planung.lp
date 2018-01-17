%------------------Modell-----------------------------------%

% periode( TAGESZEIT, PERIODE).
%    Der Fahrplan soll fur jede TAGESZEIT immer periodisch erstellt werden.
%    Z.B. wiederholt sich der Fahrplan jede Stunde, dann ist PERIODE=60,
%    und An- und Abfahrtszeiten fur alle Stunden identisch.
%    Ebenso kann PERIODE=10, PERIODE=15, PERIODE=20 oder PERIODE=30
%    sinnvoll sein, um den Fahrgasten immer gleich gute Anschlusse anzubieten.

%------------------Regeln-----------------------------------%

       % ((T2 - T1) \ PERIODE) gibt  seltsamerweise negetave Ausgaben,
       % falls (T2 - T1) negativ. Wenn wir noch eine PERIODE dazurechnen,
       % dann wird der Wert positiv und bekommen mit abermaligen
       % modulo den korrekten Wert.
       %(((T2 - T1) \ PERIODE) + PERIODE ) \ PERIODE = DELTA_T.

% anab( LINIE_AN, LINIE_AB, T_AN, T_AB, ZUGTYP, TAGESZEIT).
%    Ankunft und Abfahrt an Endhaltestelle von LINIE_AN == Starthaltestelle von LINIE_AB
%    LINIE_AN, LINIE_AB: LINIE in der die Strassenbahn ankommt, abfaehrt
%    T_AN, T_ab: Ankunfs- bzw. Abfahrtszeit
%    ZUGTYP
%    TAGESZEIT

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
abfahrt_nach(LINIE, T_AB_PREV, T_AB_NEXT, DELTA_T, ZUGTYP_NEXT, TAGESZEIT)
  :- abfahrt_differenz(LINIE, T_AB_PREV, T_AB_NEXT, DELTA_T, TAGESZEIT),
     anab(_, LINIE, _, T_AB_NEXT, ZUGTYP_NEXT, TAGESZEIT),
     DELTA_T =
        #min{ DELTA : abfahrt_differenz(LINIE, T_AB_PREV, T_AB_N, DELTA, TAGESZEIT)}.

abfahrt_differenz(LINIE, T_AB1, T_AB2, ((PER + 1 + T_AB2 - T_AB2) \ PER) -1, TAGESZEIT)
  :- abfahrt_starthalt(LINIE, T_AB1, TAGESZEIT),
     abfahrt_starthalt(LINIE, T_AB2, TAGESZEIT),
     periode(TAGESZEIT, PER).

% passagiere_nach_halt(linien_id, halt, anzahl_passagiere). Passagiere in der Bahn nach dem sie an einem Haltepunkt war
%   linien_id: LINIE und Richtigung
%   halt: Haltestelle
%   anzahl_passagie: Anzahl der Passagiere nach der Abfahrt von Haltepunkt (zwischen den Haltepunkten) pro Stunde
passagiere_nach_halt(LINIE, HALT, TAGESZEIT, ANZAHL)
    :- starthalt(LINIE, HALT), einstiege(HALT, LINIE, TAGESZEIT, ANZAHL).

passagiere_nach_halt(LINIE, HALT, TAGESZEIT, ANZ_PREV + EINST - AUSST)
    :- einstiege(HALT, LINIE, TAGESZEIT, EINST),
       ausstiege(HALT, LINIE, TAGESZEIT, AUSST),
       passagiere_nach_halt(LINIE, HALT_PREV, TAGESZEIT, ANZ_PREV),
       elementarfahrzeit(HALT_PREV, HALT, LINIE, _).

% passagie_linienrichtung(linien_id, anzahl).
%   linien_id: linie und Richtung
%   anzahl: Anzahl der Passiegiere pro Stunde, die auf dem Streckenabschnitt mit maximaler Auslastung zwischen zwei Haltepunkten transportiert werden mussen
max_passagiere_linienrichtung(LINIE, TAGESZEIT, ANZAHL)
    :- ANZAHL = #max { ANZ : passagiere_nach_halt(LINIE, HALT, TAGESZEIT, ANZ) },
       passagiere_nach_halt(LINIE, _, TAGESZEIT, ANZAHL).

% Abfahrt an der Starthaltestelle
abfahrt_starthalt(LINIE, T_AB, TAGESZEIT)
  :- anab( _, LINIE, _, T_AB, _, TAGESZEIT).

% Abfahrt an beliebieger Station
abfahrt(LINIE, HALT, T_AB, TAGESZEIT)
  :- abfahrt_starthalt(LINIE, T_AB, TAGESZEIT),
     starthalt(LINIE, HALT).

ankunft(LINIE, HALT_N, (((T_AB + FAHRZEIT)\PER)+PER)\PER, TAGESZEIT)
  :- abfahrt(LINIE, HALT_P, T_AB, TAGESZEIT),
     elementarfahrzeit(HALT_P, HALT_N, LINIE, FAHRZEIT),
     periode(TAGESZEIT, PER).

abfahrt(LINIE, HALT, T, TAGESZEIT)
  :- ankunft(LINIE, HALT, T, TAGESZEIT),
     not endhalt(LINIE, HALT).


%----------------CONSTRAINTS--------------------------------%
% Jede Ankunft an der Endhaltestelle einer linie entspricht der
% vorigen Abfahrt an der Starthaltestelle dieser LINIE und umgekehrt
:- anab(_, LINIE, _, T_AB, ZUGTYP, TAGESZEIT),
   not anab(LINIE, _, (((T_AB + FAHRZEIT)\PER)+PER)\PER, _, ZUGTYP, TAGESZEIT),
   periode(TAGESZEIT, PER),
   fahrzeit(LINIE, FAHRZEIT).

:- not anab(_, LINIE, _, (((T_AN - FAHRZEIT)\PER)+PER)\PER, ZUGTYP, TAGESZEIT),
   anab(LINIE, _,  T_AN, _, ZUGTYP, TAGESZEIT),
   periode(TAGESZEIT, PER),
   fahrzeit(LINIE, FAHRZEIT).

% Keine zeitgleichen Abfahrten
:- anab(_, LINIE_AB, T_AN_1, T_AB, _, TAGESZEIT),
   anab(_, LINIE_AB, T_AN_2, T_AB, _, TAGESZEIT),
   T_AN_1 != T_AN_2.
:- anab(_, LINIE_AB, _, T_AB, ZUGTYP_1, TAGESZEIT),
   anab(_, LINIE_AB, _, T_AB, ZUGTYP_2, TAGESZEIT),
   ZUGTYP_1 != ZUGTYP_2.

% Je Zugtyp durfen nicht mehr Fahrzeuge als vorhanden eingesetzt werden
% Je Periode werden
%   sum ( FAHRZEITEN + WARTEZEITEN ) Minuten
% Zuege benoetigt, also ist die Anzahl der benotigten Zuege
%   sum ( FAHRZEITEN + WARTEZEITEN ) / PERIODE
fahrzeugminuten_benotigt(ZUGTYP, FAHRZEUGMIN, TAGESZEIT)
  :- FAHRZEUGMIN =
        #sum{ FAHRZEIT + (PERIODE + T_AB - T_AN)\PERIODE, LINIE_AB, T_AB
           : fahrzeit(LINIE_AB, FAHRZEIT),
	     anab(LINIE_AN, LINIE_AB, T_AN, T_AB, ZUGTYP, TAGESZEIT),
             periode(TAGESZEIT, PERIODE)
        },
     fahrzeugtyp(ZUGTYP, _),
     periode(TAGESZEIT, _).

fahrzeuge_benotigt(ZUGTYP, FAHRZEUGMIN / PERIODE, TAGESZEIT)
  :- fahrzeugminuten_benotigt(ZUGTYP, FAHRZEUGMIN, TAGESZEIT),
     periode(TAGESZEIT, PERIODE).

:- BEN_ANZAHL > FAHRZEUGANZAHL,
   fahrzeuganzahl(ZUGTYP, FAHRZEUGANZAHL, TAGESZEIT),
   fahrzeuge_benotigt(ZUGTYP, BEN_ANZAHL, TAGESZEIT).

% die naechste ankommende Bahn, muss gross genug sein, um die Passagiere
% aufnehmen zu koennen, die sich in der zwischenzeit angesammelt haben
:- abfahrt_nach(LINIE, _, _, DELTA_T, ZUGTYP_NEXT, TAGESZEIT),
   fahrzeugtyp(ZUGTYP_NEXT, PLATZ),
   % PLATZ muss ausreichend sein, um
   % ANZAHL_PRO_STUNDE / 60 * DELTA_T
   % Passagiere aufzunehmen
   PLATZ * 60 < ANZAHL_PRO_STUNDE * DELTA_T,
   max_passagiere_linienrichtung(LINIE, TAGESZEIT, ANZAHL_PRO_STUNDE).

% mind. 1 Bahn muss auf jeder Linie unterwegs sein
:- not abfahrt_starthalt(LINIE, _, TAGESZEIT),
   periode(TAGESZEIT, _),
   linie(LINIE).
