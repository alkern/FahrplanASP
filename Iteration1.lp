%------------------MODELL-----------------------------------%

% Die Fahrzeit (gerichtet) zwischen zwei benachberten Haltepunkten soll wie folgt angegeben sein:
% elementarfahrzeit(halt1, halt2, linien_id, fahrzeit).
%  halt1, halt2: Haltestellen
%  linien_id: Linie und Richtung (d.h. Gegenrichtungen haben unterschiedliche linien_id)

elementarfahrzeit(halt1, halt2, hin_1, 5).
elementarfahrzeit(halt2, halt3, hin_1, 10).
elementarfahrzeit(halt3, halt4, hin_1, 7).

% symmLinie(linien_id_hin, linien_id_ruck).
%   linien_id_hin: Richtung für die Definitionen gegeben sind
%   linien_id_ruck: Richtung für die Definitionen gespiegelt werden sollen
symmLinie(hin_1, ruck_1).

% einstiege(halt, linien_id, tageszeit, anzahl).
% ausstiege(halt, linien_id, tageszeit, anzahl).
%   halt: Haltepunkt
%   linien_id: Linie und Richtung
%   tageszeit: Tageszeit + Wochentag
%   anzahl: Fahrgastanzahl pro Stunde

einstiege(halt1, hin_1, morgens, 50).
einstiege(halt2, hin_1, morgens, 75).
einstiege(halt3, hin_1, morgens, 120).

ausstiege(halt2, hin_1, morgens, 20).
ausstiege(halt3, hin_1, morgens, 100).
ausstiege(halt4, hin_1, morgens, 125).

% umstiegszeit(HALT, UMSTEIGEZEIT).

umstiegszeit(halt1, 5).
umstiegszeit(halt2, 2).
umstiegszeit(halt3, 3).
umstiegszeit(halt4, 5).

%------------------REGELN-----------------------------------%
linienfahrzeit(Halt1, Halt2, Linien_id, Fahrzeit)
    :- elementarfahrzeit(Halt1, Halt2, Linien_id, Fahrzeit).

linienfahrzeit(Halt1, Halt3, Linien_id, Fahrzeit1 + Fahrzeit2)
    :- elementarfahrzeit(Halt1, Halt2, Linien_id, Fahrzeit1),
       linienfahrzeit(Halt2, Halt3, Linien_id, Fahrzeit2).


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

%Abfahrtszeit an einer Haltestelle
abfahrt(HALT, LINIE, ZEIT + UMSTEIGEZEIT) :- ankunft(HALT, LINIE, ZEIT), umstiegszeit(HALT, UMSTEIGEZEIT).
%Nächste Haltestelle bestimmen
ankunft(HALT_NEU, LINIE, ZEIT + FAHRT_DAUER + UMSTEIGEZEIT) :- ankunft(HALT, LINIE, ZEIT), elementarfahrzeit(HALT, HALT_NEU, LINIE, FAHRT_DAUER), umstiegszeit(HALT, UMSTEIGEZEIT).

	   
%----------------CONSTRAINTS--------------------------------%

%#show ankunft/3.
%#show abfahrt/3.
