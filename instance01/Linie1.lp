%------------------MODELL-----------------------------------%

% Linie 1

% Die Fahrzeit (gerichtet) zwischen zwei benachberten Haltepunkten soll wie folgt angegeben sein:
% elementarfahrzeit(halt1, halt2, linien_id, fahrzeit).
%  halt1, halt2: Haltestellen
%  linien_id: Linie und Richtung (d.h. Gegenrichtungen haben unterschiedliche linien_id)

elementarfahrzeit(halt1, halt2, linie1_hin, 5).
elementarfahrzeit(halt2, halt3, linie1_hin, 10).
elementarfahrzeit(halt3, halt4, linie1_hin, 7).

% symmLinie(linien_id_hin, linien_id_ruck).
%   linien_id_hin: Richtung für die Definitionen gegeben sind
%   linien_id_ruck: Richtung für die Definitionen gespiegelt werden sollen
symmLinie(linie1_hin, linie1_ruck).

% einstiege(halt, linien_id, tageszeit, anzahl).
% ausstiege(halt, linien_id, tageszeit, anzahl).
%   halt: Haltepunkt
%   linien_id: Linie und Richtung
%   tageszeit: Tageszeit + Wochentag
%   anzahl: Fahrgastanzahl pro Stunde

einstiege(halt1, linie1_hin, morgens, 50).
einstiege(halt2, linie1_hin, morgens, 75).
einstiege(halt3, linie1_hin, morgens, 120).

ausstiege(halt2, linie1_hin, morgens, 20).
ausstiege(halt3, linie1_hin, morgens, 100).
ausstiege(halt4, linie1_hin, morgens, 125).
