% Fur je zwei Linien mit Umsteigebeziehung soll an einer Umsteigestation
% eine Umsteigezeit von 4-6 Minuten erreicht werden. 4-6 Minuten sind
% in der Aufgabenstellung gefordert.

% Als Eingabe fur die Anwendung:
optimale_umstiegszeit_min(4).
optimale_umstiegszeit_max(6).


% Skizze von umsteigebeziehung(LINIE_AN, LINIE_AB):
%             D
%             ^
%     LINIE_AB|
%             |
% A --------->o---------> B
%   LINIE_AN  ^
%             |
%             |
%             C
%
% gerichtet! Fahrgaste wollen in dieser umsteigebeziehung von A nach D
umsteigebeziehung(LINIE_AN, LINIE_AB)
  :- elementarfahrzeit(_,    HALT, LINIE_AN, _),
     elementarfahrzeit(HALT, _,    LINIE_AB, _),
     LINIE_AN != LINIE_AB.

% Beispiel fur umsteigebeziehung(LINIE_AN, LINIE_AB):
%
%           LINIE_AB
%               ^ 20 min Takt
%               |
%               |
% LINIE_AN----->o---->
%  10 min Takt  ^
%               |
%               |
%
% Im Fall von Takt(LINIE_AN) < Takt(LINIE_AB) sollte fur jeden abfahrenden Zug
% von LINIE_AB die umsteigezeit optimiert werden.
umstieg_ab_not_opt(LINIE_AN, LINIE_AB, TAGESZEIT)
  :- umsteigebeziehung(LINIE_AN, LINIE_AB),
     abfahrt(LINIE_AB, HALT, T_AB, TAGESZEIT),
     not ankunft(LINIE_AN, HALT, T_AN, TAGESZEIT),
     T_AN = (PER + T_AB - UMSTIEGS_T) \ PER,
     periode(TAGESZEIT, PER),
     optimale_umstiegszeit_min(MIN),
     optimale_umstiegszeit_max(MAX),
     UMSTIEGS_T = MIN .. MAX.

% Andernfalls sollte fur Takt(LINIE_AB) < Takt(LINIE_AN) fur jeden ankommenden
% Zug die Umsteigezeit optimiert werden.
umstieg_an_not_opt(LINIE_AN, LINIE_AB, TAGESZEIT)
  :- umsteigebeziehung(LINIE_AN, LINIE_AB),
     ankunft(LINIE_AN, HALT, T_AN, TAGESZEIT),
     not abfahrt(LINIE_AB, HALT, T_AB, TAGESZEIT),
     T_AB = (T_AN + UMSTIEGS_T) \ PER,
     periode(TAGESZEIT, PER),
     optimale_umstiegszeit_min(MIN),
     optimale_umstiegszeit_max(MAX),
     UMSTIEGS_T = MIN .. MAX.

%-------------------------Preferences--------------%

% Wenn die umstiegsbeziehung weder bez. abfahrender noch ankommender
% Bahnen optimal ist, dann ist die umstiegsbeziehung nicht optimal.
% Mit einem Weak constraint wird uber alle umstiegsbeziehungen optimiert.
:~ umstieg_an_not_opt(LINIE_AN, LINIE_AB, TAGESZEIT),
   umstieg_ab_not_opt(LINIE_AN, LINIE_AB, TAGESZEIT). [1@2]

% Anzahl der Fahrzeuge soll mit niedrigerer Preferenz minimert werden
:~ fahrzeuge_benotigt(TYP, ANZAHL, TAGESZEIT). [ANZAHL@1]
