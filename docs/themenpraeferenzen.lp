%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% es gibt 7 Gruppen
gruppe(1..7).

% es gibt 7 Themen
thema(1..7).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% define

% Prädikat pr(G, T1, T2): Gruppe G präferiert Thema T1 gegenüber Thema T2
% pr/3 wird zur "Eingabe" von Präferenzen verwendet

% Prädikat pref(G, T1, T2): Gruppe G präferiert Thema T1 gegenüber Thema T2
% pref/3 wird zur Erweiterung der Eingaben und dann in der Zuweisung verwendet

% Präferenzen ergeben sich aus angegebenen paarweisen Vergleichen
pref(G, T1, T2) :- pr(G, T1, T2).

% Präferenzen sind transitiv / werden transitiv abgeschlossen
pref(G, T1, T3) :- pref(G, T1, T2), pref(G, T2, T3).

% Präferenzen sollen irreflexiv sein
fehler(G, T) :- pref(G, T, T). %#show fehler/2.

% Gruppe G präferiert Thema/en T am meisten
wunschthema(G, T) :- pref(G, T, _), not pref(G, _, T).

% ein Thema wird in irgendeinem Vergleich von Gruppe G genannt
gt(G, T) :- pr(G, T, _).
gt(G, T) :- pr(G, _, T).

% alle in Vergleichen genannten Themen werden allen nicht genannten vorgezogen
pref(G, T1, T2) :- gt(G, T1), thema(T2), not gt(G, T2).


%%% Beispieldaten für 3 Gruppen (auskommentiert)
%% Gruppe 1: 
%pr(1, 7, 3). pr(1, 3, 6).
%% Gruppe 2: 
%pr(2, 4, 2). pr(2, 2, 6). pr(2, 1, 5). pr(2, 3, 5).
%% Gruppe 3: 
%pr(3, 6, 5). pr(3, 5, 1). pr(3, 1, 7). pr(3, 7, 3).
