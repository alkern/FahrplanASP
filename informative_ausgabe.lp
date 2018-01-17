#show anab/6.
#show periode/2.
#show fahrzeugminuten_benotigt/3.
#show fahrzeuge_benotigt/3.
#show fahrzeugtyp/2.

#show abfahrt_modell/4.

abfahrt_modell(LINIE, HALT, T_AB, TAGESZEIT)
  :- abfahrt(LINIE, HALT, T_AB, TAGESZEIT).

abfahrt_modell(LINIE, HALT, T_AB, TAGESZEIT)
  :- abfahrt_modell(LINIE, HALT, T_AB_PREV, TAGESZEIT),
     T_AB = T_AB_PREV + PERIODE,
     T_AB < 60,
     periode(TAGESZEIT, PERIODE).
