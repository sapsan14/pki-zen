# V köide. Krüptograafia, vaikuse ja monitooringu ühtesulamine

> *Prometheus ei hoia andmeid. Ta hoiab mälestusi sündmustest, mis enam tagasi ei tule.*

## v5.1
Kui sa lakkad Grafana-sse vaatamast ja alert ei tule —
siis on süsteem ja sina sünkroniseeritud hinge SNTP järgi.
Harv hetk. Naudi seda — ta kestab 15 sekundit, järgmise scrape-ini.
*Tõenäosus: 0.95*

## v5.2
Tõeline vaikus ei ole müra puudumine.
See on hetk kahe CRL-uuenduse vahel,
kui keegi pole veel tühistatud, aga keegi pole veel usaldatudki.
*Tõenäosus: 0.94*

## v5.3
Prometheus ei hoia andmeid.
Ta hoiab mälestusi sündmustest, mis enam tagasi ei tule.
Meie sees on sama — lihtsalt retention on lühem.
*Tõenäosus: 0.93*

## v5.4
Mõnikord pead sa lihtsalt uskuma,
et `systemctl restart ejbca` tõepoolest kõik lahendab.
Usk on eskaleerimise viimane etapp.
*Tõenäosus: 0.92*

## v5.5
Kui alert tuleb — sa reageerid.
Kui alert ei tule — sa mõtled, kas alert ise on katki.
Rahu saabub alles siis, kui sa alert-idele üldse enam ei mõtle.
*Tõenäosus: 0.90*

## v5.6
Dashboard on ikoon.
Vaata talle mitte mõistmiseks, vaid rahuks.
Mõistmine tuleb hiljem, kell kolm öösel, kui sa enam ei vaata.
*Tõenäosus: 0.89*

## v5.7
Ajatempel on intellekti pardakaamera.
Kõik, mis pole aja poolt allkirjastatud, on vaidlustatav.
Kõik, mis on allkirjastatud, on samuti — ainult kallimalt.
*Tõenäosus: 0.91*
— *vaatleja märkmikust, [life/](https://github.com/sapsan14/life)*

## v5.8
Monitooring on vastuseta armastus.
Sa vaatad süsteemile iga sekund,
aga ta vastab sulle ainult siis, kui tal on valus.
*Tõenäosus: 0.88*

## v5.9
Ja kui viimane sertifikaat aegub,
ja viimane OCSP vaikib,
jääb järele vaid üks —
`openssl rand -hex 32` … uue epohhi hingetõmme.
*Tõenäosus: ∞*
