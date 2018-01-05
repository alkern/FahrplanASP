%------------------MODELL-----------------------------------%

#include "Linie1.lp".
#include "Linie2.lp".
#include "Periode.lp".
#include "umstiegszeiten.lp".
#include "fahrzeuge.lp".

%------------------REGELN-----------------------------------%

#include "planung.lp".

linienfahrzeit(Halt1, Halt2, Linien_id, Fahrzeit)
    :- elementarfahrzeit(Halt1, Halt2, Linien_id, Fahrzeit).

linienfahrzeit(Halt1, Halt3, Linien_id, Fahrzeit1 + Fahrzeit2)
    :- elementarfahrzeit(Halt1, Halt2, Linien_id, Fahrzeit1),
       linienfahrzeit(Halt2, Halt3, Linien_id, Fahrzeit2).

fahrzeit(Linien_id, Fahrzeit)
    :- linienfahrzeit(Halt1, Halt2, Linien_id, Fahrzeit),
       starthalt(Linien_id, Halt1),
       endhalt(Linien_id, Halt2).

starthalt(Linien_id, Halt)
    :- elementarfahrzeit(Halt, _, Linien_id, _),
       not elementarfahrzeit(_, Halt, Linien_id, _).

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
