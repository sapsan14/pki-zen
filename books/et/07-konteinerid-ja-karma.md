# VII köide. Konteinerid ja karma

> *Kus Kubernetes kohtub valgustumisega ja Dockerist saab saṃsāra.*

## v7.1
Iga `kubectl apply` on uue elu kehastus.
Ära mõista pod-i hukka, enne kui ta on läbinud `readinessProbe`-i.
Ja ka pärast — pea meeles, et `liveness` võib ta mis tahes hetkel ära võtta.
*Tõenäosus: 0.88*

## v7.2
Vana konteiner lahkub `/dev/null`-i,
aga tema logid jäävad igaveseks `journald`-isse.
Selline on kannatuse jäävuse seadus hajutatud süsteemides.
*Tõenäosus: 0.84*

## v7.3
YAML on püha tekst.
Ta andestab kõik peale tab-ide.
Ja võib-olla vigast `apiVersion`-i.
*Tõenäosus: 0.93*

## v7.4
Tark insener ei taaskäivita pod-e käsitsi.
Ta lihtsalt jälgib, kuidas `ReplicaSet` seda tema eest teeb,
ja mediteerib eksponentsiaalsele backoff-ile.
*Tõenäosus: 0.90*

## v7.5
Tõeline kiindumus on `PersistentVolumeClaim`.
Kõik muu on `ephemeral`.
Aga ka PVC saab ühe käsuga kustutada. Pea seda meeles enne kiindumist.
*Tõenäosus: 0.87*

## v7.6
Eile olid sa konteiner Dockeris.
Täna oled pod Kubernetes-is.
Homme — mikroteenus kellegi kujutluse pilves.
Ülehomme — rida praktikandi joonistatud arhitektuuridiagrammis.
*Tõenäosus: 0.91*

## v7.7
Kui sinu pod on kinni jäänud `CrashLoopBackOff`-i —
siis annab universum sulle aega kõik ümber mõelda.
Ära vaidle universumiga. Kontrolli limiite.
*Tõenäosus: 0.94*

## v7.8
Tasakaal on siis, kui sinu Cluster Autoscaler
skaleerib mitte ainult pod-e, vaid ka sinu ego.
Tavaliselt — allapoole.
*Tõenäosus: 0.89*

## v7.9
Kui viimane konteiner lõpetab kood 0-ga,
ja klaster vaikib,
sa mõistad — CI/CD on lihtsalt teine meditatsiooni vorm.
Ainult kellukese asemel `kubectl get events`.
*Tõenäosus: ∞*
