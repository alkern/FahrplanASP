%------------------MODELL-----------------------------------%

% Linie 2

% Die Fahrzeit (gerichtet) zwischen zwei benachberten Haltepunkten soll wie folgt angegeben sein:
% elementarfahrzeit(halt1, halt2, linien_id, fahrzeit).
%  halt1, halt2: Haltestellen
%  linien_id: Linie und Richtung (d.h. Gegenrichtungen haben unterschiedliche linien_id)

elementarfahrzeit(halt5, halt6, hin_2, 5).
elementarfahrzeit(halt6, halt3, hin_2, 10).
elementarfahrzeit(halt3, halt7, hin_2, 7).

% symmLinie(linien_id_hin, linien_id_ruck).
%   linien_id_hin: Richtung für die Definitionen gegeben sind
%   linien_id_ruck: Richtung für die Definitionen gespiegelt werden sollen
symmLinie(hin_2, ruck_2).

% einstiege(halt, linien_id, tageszeit, anzahl).
% ausstiege(halt, linien_id, tageszeit, anzahl).
%   halt: Haltepunkt
%   linien_id: Linie und Richtung
%   tageszeit: Tageszeit + Wochentag
%   anzahl: Fahrgastanzahl pro Stunde

einstiege(halt5, hin_2, morgens, 50).
einstiege(halt6, hin_2, morgens, 75).
einstiege(halt3, hin_2, morgens, 120).

ausstiege(halt6, hin_2, morgens, 20).
ausstiege(halt3, hin_2, morgens, 100).
ausstiege(halt7, hin_2, morgens, 125).


