# Mäkelän Kulma – sivusto ja hallintapaneeli

Sivusto ja hallintapaneeli samassa kansiossa, samalla mallilla kuin Limone Bistro Espoo.
Hosting Vercel, tietokanta ja kirjautuminen Supabase. Tilaukset GloriaFoodin kautta.

## Kansiorakenne

```
/index.html              sivusto suomeksi: etusivu (#/) ja menu (#/menu)
/en/index.html           englanninkielinen sivu (makelankulma.fi/en)
/sv/index.html           ruotsinkielinen sivu (makelankulma.fi/sv)
/admin/index.html        hallintapaneeli (tilastot, aukiolo ja tiedote, sisältö)
/api/track.js            kirjaa sivulatauksen
/api/stats.js            palauttaa tilastot paneelille
/assets/                 logo, kuvakkeet, jakokuva, ruoka- ja salikuvat
/supabase-schema.sql     tietokannan rakenne
/paivita-github.bat      lähettää muutokset GitHubiin (Windows)
/404.html                virhesivu, jos osoitetta ei löydy
/.vercelignore           pitää README:n, tietokantatiedoston ja bat-tiedoston pois julkiselta sivulta
```

Sivusto toimii heti ilman tietokantaa: tekstit ja aukioloajat on kirjoitettu tiedostoon.
Kun Supabase on kytketty, paneelissa tallennetut muutokset korvaavat ne.

## 1. Supabase

1. Luo uusi projekti supabase.com:ssa, esimerkiksi `makelankulma`, alue **eu-north-1 (Tukholma)**.
2. **SQL Editor** → liitä `supabase-schema.sql` kokonaan ja aja.
3. **Authentication → Users → Add user**: luo tunnus ravintolalle (sähköposti + salasana, "Auto confirm user" päälle).
4. **Authentication → Providers → Email**: laita **Enable signups** pois päältä.
5. Ota talteen **Settings → API**: Project URL, anon public key ja service_role key.

## 2. Vercel

1. Vercel → **Add New → Project** → valitse GitHub-repo `makelankulma`.
2. Framework preset **Other**, root directory repon juuri.
3. **Settings → Environment Variables**:

| Nimi | Arvo |
|---|---|
| `SUPABASE_URL` | Supabasen Project URL |
| `SUPABASE_ANON_KEY` | anon public key |
| `SUPABASE_SERVICE_ROLE_KEY` | service_role key |
| `TRACK_SALT` | mikä tahansa pitkä satunnainen merkkijono |

4. Deploy. Sivusto on osoitteessa `projekti.vercel.app`, paneeli `/admin`.

## 3. Yhdistä sivusto ja paneeli tietokantaan

**`/index.html`**, heti `<body>`-tagin jälkeen:

```html
<script>window.MK={SUPABASE_URL:"https://PROJEKTI.supabase.co",SUPABASE_ANON_KEY:"anon-key"};</script>
```

**`/admin/index.html`**, tiedoston lopun skriptissä:

```js
const SUPABASE_URL = "https://PROJEKTI.supabase.co";
const SUPABASE_ANON_KEY = "PASTE_ANON_KEY";
```

Anon key on tarkoitettu julkiseksi. Rivitason suojaus (RLS) sallii sillä vain sisällön lukemisen.

## 4. Käyttö

**Aukiolo & tiedote** – aukioloajat päivittäin (myös yli puolenyön, esim. 10:30–04:00). Sivun
"Avoinna nyt" -tila laskee niistä automaattisesti. Tiedote näkyy sivun ylälaidassa, kun se on päällä.

**Sisältö** – etusivun otsikko ja esittelyteksti, puhelin, sähköposti, osoite ja Meistä-teksti.

**Tilastot** – kävijät tänään, eilen, 7 päivää ja valittu jakso, päiväkohtainen kaavio,
suosituimmat näkymät, mistä kävijät tulivat ja laitejakauma. Ei evästeitä eikä IP-osoitteiden
tallennusta, joten evästebanneria ei tarvita.

## Kielet

Sivu on suomeksi, englanniksi ja ruotsiksi. Jokaisella kielellä on oma osoite (/, /en, /sv), ja sivuilla
on hreflang-merkinnät, joten Google näyttää hakijalle oikean kieliversion. Kielivalitsin on yläpalkissa,
mobiilivalikossa ja alatunnisteessa, ja se säilyttää näkymän (esim. menu pysyy menuna).

Hallintapaneelin tekstimuutokset (otsikot, esittelyt) näkyvät suomenkielisellä sivulla. Aukioloajat,
puhelin, sähköposti ja tiedote päivittyvät kaikille kielille.

## Tilaukset

Kaikki "Tilaa"-napit ja ruokalistan annoskortit avaavat GloriaFood-tilausikkunan
(ravintolan tunnus `cb7ab3cc-7ade-4888-86b4-bdd8cac7b31e`).

## Kuvat

Kaikki kuvat ovat sivuston omassa `/assets/`-kansiossa: ruokakuvat (`/assets/ruoka/`, ravintolan
oman ruokalistan kuvista) ja salikuvat (`/assets/sali/`). Ulkopuolisia kuvapalvelimia ei käytetä.

## Hinnat

Ruokalistan hinnat ovat ravintolan painetusta menusta (lokakuu 2026) ja kirjoitettu `index.html`:ään.
Kun hinnat muuttuvat, päivitä ne sinne. Tilausikkunan (GloriaFood) hinnat päivitetään GloriaFoodissa.

## Kustannukset

| Palvelu | Hinta |
|---|---|
| Vercel Hobby | 0 € |
| Supabase Free | 0 € |
