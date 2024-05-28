# trigger

## Innledning

Trigger er en lettvektsversjon av airflow for R, som kan brukes til å planlegge, sett i gang og overvåke jobber.

Programvaren har en oversikt over registrerte jobber, og en oversikt over kjøringer. Den registrerer når jobber starter, når de stopper, og hvilken status de stopper med.
Den tar i mot feilmeldinger ved stans grunnet `error`/`warning`, og varsler om status på jobber til personer som er registrert for dette. Den går daglig gjennom hvilke jobber som skulle vært kjørt, og hvilke jobber som er kjørt, og sender ut varsel om dette.

Programvaren kommer med en shiny-app, der man kan overvåke jobber, se hvilke jobber som skulle gå på en gitt dato, og hvilke jobber som har gått.

Programvaren bygger på `rsqlite`, `dplyr`, `callr`, `lubridate` og `sbmailr`. Web-applikasjonen bygger på `shiny` og `bs4dash`.


## Installasjon og oppsett

Installer filen med følgende kommando

```r
renv::install("trigger")

```
.

Angi plasseringen av databasen.

```r
locate_database(path = "<path/to/database>")
```

Innstaller databasen med nødvendige tabeller på angitt plass.

```r
init()
```


## Bruk



### Registrer jobb

Før en jobb sin kjøringer kan registreres i trigger må selve jobben registres i `trigger`-databasen. Det gjør du på følgende måte:

```
registrer_job(
  navn = "Daglig datalast",
  hyppighet = run_frequencies$daily()
)
```

Navnet på jobben må være unikt for jobben, og for angivelse av hyppighet kan du bruke funksjonene `daily()` eller `monthly()` fra listen `run_frequency`. 
Dersom du oppgir et navn som alt er registrert i databsen vil du få en feilmelding som antyder dette.

Kjøre koden som jobben består av gjør du det på følgende måte:

```r
run_job <- set_up_job_runner(
  name = "Daglig datalast",
  alerts = "example@email.com"
)

run_job({
  # source("script.r")
})

```

`alerts` om noen skal varsles når jobben er ferdig, mens `waiting_for` angir om denne jobben skal vente til en annen jobb er ferdig. 

## Programvarearkitektur

Programvaren er bygget opp med følgende mappestruktur, database og funksjoner.

### Mappestruktur

- `<path>/database/trigger.sqlite` inneholder databasen
- `<path>/logfiles/<job_name>/log_message_<date>.log` inneholder logg-meldinger.

### Database

Programvaren bygger på en filbasert SQLIite-database der informasjon registreres. Databasen har følgende tabeller

- `jobs` inneholder en oversikt over jobbene som kjøres
- `runs` er en tabell som inneholder aggregert informasjon fra alle kjøringer.
- `events` er en transaksjonstabell som inneholder informasjon fra alle kjøringer.

### Funksjoner

- **Installasjon/oppsett**
  - `locate_database()`
  - `init()`
- **Kjøring**
  - `register_job()`
  - `run_frequency`
  - `set_up_job_runner()`
  - `get_job_status()`
  - `job_is_complete()`
- **Applikasjon**
  - `get_jobs()`
  - `get_runs()`
  - `get_planned_runs()`
  - `launch_monitor()`
- **Status**
  - `review_runs()`






