%------------------MODELL-----------------------------------%

% elementarfahrzeit( halt1, halt2, linien_id, fahrzeit ).
%   gibt die Fahrzeit (gerichtet) zwischen zwei benachbarten Haltepunkten an
%   halt1, halt2: Haltestellen
%   linien_id: Linie und Richtung (d.h. Gegenrichtungen haben unterschiedliche linien_id)

% einstiege(halt, linien_id, tageszeit, anzahl).
% ausstiege(halt, linien_id, tageszeit, anzahl).
%   halt: Haltepunkt
%   linien_id: Linie und Richtung
%   tageszeit: Tageszeit + Wochentag
%   anzahl: Fahrgastanzahl pro Stunde

% symmLinie(linien_id_hin, linien_id_ruck).
%   spiegelt elementarfahrzeit, einstiege und ausstiege (fur weniger Schreibaufwand)
%   linien_id_hin: Richtung für die Definitionen gegeben sind
%   linien_id_ruck: Richtung für die Definitionen gespiegelt werden sollen


%------------------REGELN-----------------------------------%

% linienfahrzeit: Die Fahrzeit auf einer Linie
linienfahrzeit(Halt1, Halt2, Linien_id, Fahrzeit)
    :- elementarfahrzeit(Halt1, Halt2, Linien_id, Fahrzeit).

linienfahrzeit(Halt1, Halt3, Linien_id, Fahrzeit1 + Fahrzeit2)
    :- elementarfahrzeit(Halt1, Halt2, Linien_id, Fahrzeit1),
       linienfahrzeit(Halt2, Halt3, Linien_id, Fahrzeit2).

% Die Geseamtfahrzeit einer Linie
fahrzeit(Linien_id, Fahrzeit)
    :- linienfahrzeit(Halt1, Halt2, Linien_id, Fahrzeit),
       starthalt(Linien_id, Halt1),
       endhalt(Linien_id, Halt2).

% Der erste Haltepunkt einer Linie
starthalt(Linien_id, Halt)
    :- elementarfahrzeit(Halt, _, Linien_id, _),
       not elementarfahrzeit(_, Halt, Linien_id, _).

% Der letzte Haltepunkt einer Linie
endhalt(Linien_id, Halt)
    :- not elementarfahrzeit(Halt, _, Linien_id, _),
       elementarfahrzeit(_, Halt, Linien_id, _).

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

%#show ankunft/3.
%#show abfahrt/3.
