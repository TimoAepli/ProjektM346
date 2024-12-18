# Projekt M346

## CSV zu JSON Converter mit AWS Lambda

**Inhaltsverzeichnis**

- [Projekt Team](#projekt-team)
- [Einleitung zur Projektdokumentation](#einleitung-zur-projektdokumentation)
- [Vorbereitung](#vorbereitung)
- [Aufbau des Services](#aufbau-des-services)
- [Nutzung](#nutzung)
    - [Anforderungen](#anforderungen)
    - [Inbetriebnahme](#inbetriebnahme)
- [Test Protokoll](#test-protokoll)
    - [JSON File anstelle vom CSV File](#json-file-anstelle-vom-csv-file)
    - [Leeres CSV File](#leeres-csv-file)
    - [Korruptes CSV File](#korruptes-csv-file)
- [Reflexion](#reflexion)
    - [Benjamin Nater](#benjamin-nater)
    - [Matteo Bucher](#matteo-bucher)
    - [Timo Aepli](#timo-aepli)
- [Quellenverzeichnis](#quellenverzeichnis)

## Projekt Team

- Timo Aepli
- Matteo Bucher
- Benjamin Nater

## Einleitung zur Projektdokumentation

In diesem Projekt haben wir, Timo Aepli, Matteo Bucher und Benjamin Nater, einen Cloud-Service entwickelt, der CSV-Dateien automatisch in JSON konvertiert. Mithilfe von AWS S3 und Lambda stellen wir die Lösung im AWS Learner Lab bereit. Alle Dateien sowie die gesamte Dokumentation, einschließlich Aufbau, Nutzung und Testergebnisse, haben wir in einem Git-Repository abgelegt.

## Vorbereitung

Zuerst haben wir ein öffentliches Git-Repository erstellt. Danach haben wir eine Aufgabenliste erstellt, in der festgelegt ist, wer was macht.

| Aufgabe | Erledigt bis | Wer | Verantwortlich |
| ----------- | ----------- | ----------- | ----------- |
| Lambda Funktion | 18.12.2024 | alle | Matteo, Benjamin |
| Buckets per Script erstellen CLI-Datei | 18.12.2024 | alle | Matteo, Benjamin |
| Dokumentation | 18.12.2024 | alle | Timo |
| Selbstreflektion | 19.12.2024 | alle | alle |
| Testen | 19.12.2024 | Timo | Timo |

## Aufbau des Services

## Nutzung

### Anforderungen

- **Unix-Betriebssystem**  
  Geeignet für Linux und macOS.  

- **AWS Learner Lab**  
  Deine Lernumgebung für Cloud-Technologien.  

- **AWS CLI**  
  [Installation und Konfiguration von AWS CLI](https://gbssg.gitlab.io/m346/iac-aws-cli/ "AWS CLI")  

- **.NET 8**  
  ![.NET 8](pictures/NET-8.png)  

- **AWS Lambda**  
  ![AWS Lambda](pictures/Lambda.png)  

### Inbetriebnahme

1. Folgenede Befehle asführen:
    ```git
    git clone https://github.com/TimoAepli/ProjektM346.git
    cd ProjektM346
    ./initalize.sh
    ```

## Test Protokoll

### JSON File anstelle vom CSV File

### Leeres CSV File

### Korruptes CSV File

## Reflexion

### Benjamin Nater

### Matteo Bucher

### Timo Aepli

## Quellenverzeichnis

[AWS CLI](https://docs.aws.amazon.com/cli/)

[ChatGPT](https://chatgpt.com/)