

```

<<<Uwagi do dokumentacji modelu>>>>>>

Dokumentacja z budowy modelu BEHAV nie jest spójną z regulacjami zewnętrznymi.
W szczegułności z Rekomendacją W (z rek. 11.3 str. 30-32),
bo brakuje znacznej częsci elementów tam wymienianych.
Zwiazku z tym jest duża szansa że na to zwóruci uwagę audytor/KNF albo walidacja.

Przykładowe braki: - źródło pochodzenia modelu, rodzaj modelu, 
opis zastosowanych transformacji zmiennych wejściowych, ich powodów wraz z analizą intuicyjności otrzymanych wyników 
- informacje na temat zidentyfikowanych słabych stron modelu, jego ograniczeń
i okoliczności, w których model nie działa skutecznie, 
- stosowane kryteria oceny jakości działania modelu wraz z uzasadnieniem i oceną stopnia
spełnienia tych kryteriów przez finalną postać modelu
- oceny intuicyjności zwracanych przez model oszacowań.
....

Nałeży uzupelnić aneks dokumentacji. W anaksie brakuje Listy zakładów ograniczonego ryzyka (ZOR), 
Listy procesów/lini biznesowych oraz wyjaśnienie ich mapowania,Listy kodów mapójących produkty, itd.

Brakuje wyjaśnienia metodyki stosowania ekspeckich korekt.
Przykład używane w EMA i SMA (wg. rekomendacji W, stosowanie wwszelkich korekt jest kontrowersyjne);


<<<Uwagi dot. modeli>>>>>>

a) model dla kredytów gotówkowych "model GOT":

Kwestie ważne:
-  [budowa modeli] uwaga na zmienną MAX_DPD_12M (maksymalna liczba dni zaległości z ostatnich 12 mc) 
zmienna o wysokim ryzyku przecieku informacji do fragi_default gdyż jest podobna do flagi default.
Analogiczne zmienne mogą zaburzać  parametry oszacowań (i powodować nie ituicyjne znaki przy betach).
Nałezy zwrócic uwagę na b. wysoki poziom IV(0,57) > 0,5 oraz wysoki poziom GINI 0,37 
gdy dla pozostałych zmiennych GINI krztaltowało się w przedziałe 0,13 do 0,25

- [stabilność] delta mocy dysryminacyjnej (P. UCZĄCA / P.TESTOWAi)-1 jest w porządku (nie przekracza -15% na nowszym zakresie danych. Walidacja może dać zółte światło jeżeli 15>delta_gini<=25%, czerwone światło: delta_gini>25% )
- [stabilność] delta iv jest w porządku (P. UCZĄCA / P.TESTOWAi)-1 (zółte światło jeżeli -25>delta_iv<=-50%, czerwone światło: iv>-50%)

Kwestie mało ważne:
- [koncentracja] koncentracja nieporządanych ekspozycji w odrebie klas ryzyka na poziomie HHI=15 %(umiarkowana)
Walidacja może dać czerwone światło za HHI>.18
- [PSI w dokumenatcji] doprecyzować, w zasadzie nałeży wyłaczać defaulty, nic o tym nie wspominięto
---


b) model dla kredytów zabiespieczonych hipotycznie "model HIP":

Kwestie ważne:
Uwaga na zmienną IF_1DPD_ALL, jak i w modelu GOT zmienna o wysokim ryzyku przecieku informacji do fragi_default. 
Dla tej zmiennej wskazniki mocy dyskrymianacyjnej osiągają bardzo wysokie wartości IV=3,51 a gini=0.8.

!!! zbyt małe liczbności badów by modelowac flagę default (88 ekpozycji na próbie uczącej, 44 i na próbie testowej 52).
W tym pzypadku nałezałoby dla sprawdzać błąd pomiarówy wskażnikow mocy dyskryminacyjnej (GINI, IV, ROC).
Byłoby dobrze wyliczyć przedziały ufności dla GINI i krzywej ROC.

Krzywa ROC wskazuje na nadmierne dopasowanie modelu do danych (str. 47), co potwierdzają wskazniki delta_gini i delta_iv.
Spadek gini na próbie 2019-03-31 wynosi -30% a na próbie 2019-06-31 już -42%.


c) model dla kredytów w koncie, debet w ROR, karta kredytowa "model REV":
jedynie można przyczepić się do b wysokiego poziomu IV dla miennej TOTAL_POS_BALANCE_L6M 
dla tej zmiennje można byłob dać czerwone światło gdyż IV(0,67)>.60.
Moc dyskryminacyjna modelu jest stabilna w czasie. 



```

import pandas as pd
# GOT
pd.DataFrame({"Bad":[88, 43, 52],
              "Good":[22912, 22947, 23517],
              "Total":[23009, 22990, 23569],
              "Próbka":["Budowa", 'test', 'test']
             }, index=['2018-09-30','2018-12-31','2019-03-31' ])




# GOT
tab1 = pd.DataFrame({
              "IV":[1.007, 0.923, 0.968, 0.877, 0.816 ],
              "KS":[0.388, 0.384, 0.364, 0.347, 0.338],
              "GINI":[52.6, 51.2, 49, 48.2, 45.4],
              "Próbka":["Budowa", 'test', 'test', 'test','test']
             }, index=['2018-09-30','2018-09-30','2018-12-31','2018-12-31','2019-03-31' ])
tab1['DELTA_GINI'] = (tab1['GINI']/tab1['GINI'][0])-1
tab1['DELTA_IV'] = (tab1['IV']/tab1['IV'][0])-1
tab1


tab1 = pd.DataFrame({"good":[0, 206, 695, 1542, 4996, 8717, 9015, 9726, 8853, 3162, 1613, 634, 408, 0],
              "bad":[0, 0, 3, 3, 11, 69, 110, 160, 248, 155, 160, 82, 105,0]
             }, index=['A','A-','BBB+','BBB','BBB-','BB+','BB','BB-','B+','B','B-','CCC+','CCC','CCC-' ])
tab1['total'] = tab1['good']+tab1['bad']
hhi = sum((tab1['total']/tab1['total'].sum())**2)


# Urzyto HHI, w celu Weryfikacji koncentracji ekpozycji, która mogłąby skutkowac tworzeniem nieporzadanych klas 
# albo przedziaów dominujących w strukturze.


if hhi<.1:
    print(f'brak koncentracji {hhi}')
elif hhi>=.1 and hhi <=.18:
    print(f'umiarkowana koncentracja {hhi}')
elif hh1>.18:
    print(f'bardzo wysoka {hhi}')
    
# GOT
tab1 = pd.DataFrame({
              "IV":[3.047, 2.116, 2.074, 1.054],
              "KS":[0.818, 0.609, 0.542, 0.481],
              "GINI":[87.8, 67.4, 61.8, 51],
              "Próbka":["Budowa", 'test', 'test', 'test']
             }, index=['2018-12-31','2018-12-31','2019-03-31','2019-06-30'])
                    
tab1['DELTA_GINI'] = (tab1['GINI']/tab1['GINI'][0])-1
tab1['DELTA_IV'] = (tab1['IV']/tab1['IV'][0])-1
tab1


tab1 = pd.DataFrame({"good":[2187, 5006, 2520, 1323, 3238, 2376, 2813, 654, 736, 357, 104, 302, 156, 535, 356, 123, 68, 62, 5],
              "bad":[1, 0, 1, 1, 2, 1, 3, 1, 1, 0, 0, 0, 2, 5, 6, 9, 2, 2, 0]
             }, index=['AAA','AA+','AA','AA-','A+','A','A-','BBB+','BBB','BBB-','BB+','BB','BB-','B+','B','B-','CCC+','CCC','CCC-' ])
tab1['total'] = tab1['good']+tab1['bad']
hhi = sum((tab1['total']/tab1['total'].sum())**2)

if hhi<.1:
    print(f'brak koncentracji {hhi}')
elif hhi>=.1 and hhi <=.18:
    print(f'umiarkowana koncentracja {hhi}')
elif hh1>.18:
    print(f'bardzo wysoka {hhi}')
