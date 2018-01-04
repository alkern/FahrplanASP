
% Für jede Linie sind sämtliche mittlere Fahrzeiten zwischen den Haltestellen bekannt
% -----------------------------------------------------------------------------------

% Die Fahrzeit (gerichtet) zwischen zwei benachberten Haltepunkten soll wie folgt angegeben sein:
% elementarfahrzeit(halt1, halt2, linien_id, fahrzeit).
%  halt1, halt2: Haltestellen
%  linien_id: Linie und Richtung (d.h. Gegenrichtungen haben unterschiedliche linien_id)

% Haltezeit wird hier vernachla:ssigt
% Fahrzeit zwischen zwei Halten auf der selben Linie
linienfahrzeit(Halt1, Halt2, Linien_id, Fahrzeit)
    :- elementarfahrzeit(Halt1, Halt2, Linien_id, Fahrzeit).

linienfahrzeit(Halt1, Halt3, Linien_id, Fahrzeit1 + Fahrzeit2)
    :- elementarfahrzeit(Halt1, Halt2, Linien_id, Fahrzeit1),
       linienfahrzeit(Halt2, Halt3, Linien_id, Fahrzeit2).


% außerdem ist für jede Linie in jede Richtung bekannt, zu welcher Tageszeit
% --------------------------------------------------------------------------
% (jeweils an Arbeitstagen und Wochenenden) wieviele Menschen durchschnittlich an
% -------------------------------------------------------------------------------
% einer Haltestelle einsteigen wollen.
% ------------------------------------

% einstiege(halt, linien_id, tageszeit, anzahl).
% ausstiege(halt, linien_id, tageszeit, anzahl).
%   halt: Haltepunkt
%   linien_id: Linie und Richtung
%   tageszeit: Tageszeit + Wochentag
%   anzahl: Fahrgastanzahl pro Stunde

% Dabei hat die ÖPNV-Gesellschaft nur ein begrenztes Kontin-
% ---------------------------------------------------------
% gent an Straßenbahnen zur Verfügung
% -----------------------------------

% strassenbahn(id, sitzplatzanzahl).


% Ist nicht in der Aufgabenstellung, aber könnte wichtig sein:
% ------------------------------------------------------------

% strassenbahnfahrer(name, schicht).
%   name
%   schicht: Für jeden Tag und jede Arbeitsschicht (max 8 Stunden) eindeutig
%            z.B. montag_morgens, dienstag_mittags, donnerstag_abends
