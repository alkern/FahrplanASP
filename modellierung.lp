%------------------MODELL-----------------------------------%
% elementarfahrzeit( halt1, halt2, linien_id, fahrzeit ).
%   gibt die FAHRZEIT (gerichtet) zwischen zwei benachbarten HALTepunkten an
%   halt1, halt2: HALTestellen
%   linien_id: Linie und Richtung (d.h. Gegenrichtungen haben unterschiedliche linien_id)

% einstiege(halt, linien_id, tageszeit, anzahl).
% ausstiege(halt, linien_id, tageszeit, anzahl).
%   halt: HALTepunkt
%   linien_id: Linie und Richtung
%   tageszeit: Tageszeit + Wochentag
%   anzahl: Fahrgastanzahl pro Stunde

% symmLinie(linien_id_hin, linien_id_ruck).
%   spiegelt elementarfahrzeit, einstiege und ausstiege (fur weniger Schreibaufwand)
%   linien_id_hin: Richtung für die Definitionen gegeben sind
%   linien_id_ruck: Richtung für die Definitionen gespiegelt werden sollen


%------------------REGELN-----------------------------------%
% linie
%   LINIEN_ID: Linienrichtung
linie(LINIEN_ID) :- elementarfahrzeit(_, _, LINIEN_ID, _).

% linienfahrzeit: Die FAHRZEIT auf einer Linie
linienfahrzeit(HALT1, HALT2, LINIEN_ID, FAHRZEIT)
    :- elementarfahrzeit(HALT1, HALT2, LINIEN_ID, FAHRZEIT).

linienfahrzeit(HALT1, HALT3, LINIEN_ID, FAHRZEIT1 + FAHRZEIT2)
    :- elementarfahrzeit(HALT1, HALT2, LINIEN_ID, FAHRZEIT1),
       linienfahrzeit(HALT2, HALT3, LINIEN_ID, FAHRZEIT2).

% Die Geseamtfahrzeit einer Linie
fahrzeit(LINIEN_ID, FAHRZEIT)
    :- linienfahrzeit(HALT1, HALT2, LINIEN_ID, FAHRZEIT),
       starthalt(LINIEN_ID, HALT1),
       endhalt(LINIEN_ID, HALT2).

% Der erste Haltepunkt einer Linie
starthalt(LINIEN_ID, HALT)
    :- elementarfahrzeit(HALT, _, LINIEN_ID, _),
       not elementarfahrzeit(_, HALT, LINIEN_ID, _).

% Der letzte HALTepunkt einer Linie
endhalt(LINIEN_ID, HALT)
    :- not elementarfahrzeit(HALT, _, LINIEN_ID, _),
       elementarfahrzeit(_, HALT, LINIEN_ID, _).

% Regeln fur symmetrische Linien

elementarfahrzeit(HALT2, HALT1, LINIE_RUCK, FAHRZEIT)
    :- symmLinie(LINIE_HIN, LINIE_RUCK),
       elementarfahrzeit(HALT1, HALT2, LINIE_HIN, FAHRZEIT).

einstiege(HALT, LINIE_RUCK, TAGESZEIT, ANZAHL)
    :- symmLinie(LINIE_HIN, LINIE_RUCK),
       ausstiege(HALT, LINIE_HIN, TAGESZEIT, ANZAHL).

ausstiege(HALT, LINIE_RUCK, TAGESZEIT, ANZAHL)
    :- symmLinie(LINIE_HIN, LINIE_RUCK),
       einstiege(HALT, LINIE_HIN, TAGESZEIT, ANZAHL).


%----------------CONSTRAINTS--------------------------------%
% Linien durfen sich nicht verzweigen

:- elementarfahrzeit(HALT1, HALT2, LINIE, _),
   elementarfahrzeit(HALT1, HALT3, LINIE, _),
   HALT2 != HALT3.
:- elementarfahrzeit(HALT2, HALT1, LINIE, _),
   elementarfahrzeit(HALT3, HALT1, LINIE, _),
   HALT2 != HALT3.

% Fahrzeit muss eindeutig sein
:- elementarfahrzeit(HALT1, _, LINIE, FAHRZEIT1),
   elementarfahrzeit(HALT1, _, LINIE, FAHRZEIT2),
   FAHRZEIT1 != FAHRZEIT2.
