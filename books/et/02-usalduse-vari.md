# II köide. Usalduse vari ja hinge HSM

> *Usaldus on arhitektuur, mitte tunne.*
> — vaatleja märkmikust ([life/reflect/2026-02-18_trust-field-theory.md](https://github.com/sapsan14/life/blob/main/reflect/2026-02-18_trust-field-theory.md))

## v2.1
Elu on nagu PKI:
kõik on hästi, kuni keegi tühistab sinu juursertifikaadi.
Ja tavaliselt ei tühista seda vaenlane. Tühistab see, kes välja andis.
*Tõenäosus: 0.95*

## v2.2
Süda on nagu privaatvõti.
Ära jaga seda ka sellega, kes ütleb, et tahab lihtsalt "sinu armastust allkirjastada".
Tõeline armastus näitab kõigepealt oma sertifikaadiahelat.
*Tõenäosus: 0.94*

## v2.3
Tõelist usaldust ei saa importida.
See luuakse käsitsi ja hoitakse hinge HSM-is —
samas, millega sinagi ühendud PIN-koodi kaudu
ja mille vahel sa selle unustad.
*Tõenäosus: 0.96*

## v2.4
Aeg on nagu CRL:
varem või hiljem satuvad kõik sellesse nimekirja.
Kuni sa pole veel seal — mine ja allkirjasta.
*Tõenäosus: 0.93*

## v2.5
Sertifikaate saab kontrollida, aga elu ei saa —
sest elul on oma OCSP.
See ei vasta *valid* ega *revoked*, vaid *oota, kontrollin*.
*Tõenäosus: 0.92*

## v2.6
Tõeline juur-CA ei karju oma võimu pärast.
Ta lihtsalt allkirjastab, ja kõik allkirjastatu elab.
Ole nagu juur-CA. Aga palun tee varukoopia.
*Tõenäosus: 0.90*

## v2.7
Ära usalda seda, kes ütleb "trust me", ilma et ta nimetaks, *millist tulemust*.
Usalda tulemust, mitte seanssi.
*Tõenäosus: 0.89*

## v2.8
Iseallkirjastatud sertifikaat ei ole vale.
See on lihtsalt üksindus, vormistatud X.509 standardi järgi.
*Tõenäosus: 0.87*

## v2.9
Kui sertifikaat aegub, ei lagune maailm.
Maailm laguneb siis, kui sa unustasid selle jälgimise sisse lülitada.
*Tõenäosus: 0.95*
