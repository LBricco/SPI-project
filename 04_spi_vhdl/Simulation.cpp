#include <iostream>
#include <fstream>    // per file processing
#include <sstream>    // per trattare le stringhe come stream di dati
#include <filesystem> // per verificare l'esistenza dei file
#include <cstdlib>    // per usare comandi shell
#include <string>     // per manipolazione stringhe
#include <cstring>    // per manipolazione stringhe C-like
#include <vector>     // per manipolazione vettori
#include <cmath>      // per funzioni matematiche
#include <iomanip>    // per formattazione I/O

#include "Converter.hpp"
#include "Simulation.hpp"

using namespace std;

// Costruttore
Simulation::Simulation(unsigned int c)
    : correct{c} {}

// Distruttore
Simulation::~Simulation() {}

// Genero file per effettuare scritture e letture
// @param wFName = nome file contenente comandi di scrittura
// @param rFName = nome file contenente comandi di lettura
// @param ref_FName = nome file contenente i dati generati (per confronto con i risultati di Modelsim)
void Simulation::generate(string wFName, string rFName, string ref_FName)
{
    Converter C; // oggetto convertitore

    // check esistenza file (se non esistono li creo con una chiamata a system)
    if (!filesystem::exists(wFName))
        system(("touch " + wFName).c_str());
    if (!filesystem::exists(rFName))
        system(("touch " + rFName).c_str());
    if (!filesystem::exists(ref_FName))
        system(("touch " + ref_FName).c_str());

    // apro i file
    ofstream wF(wFName);
    ofstream rF(rFName);
    ofstream ref_F(ref_FName);

    // scrivo i comandi di scrittura e lettura generando casualmente i numeri di 16 bit da memorizzare
    if (wF && rF && ref_F) // se l'apertura è andata a buon fine
    {
        for (int add = 0; add < 256; add++)
        {
            int din = rand() % 65536; // dato da scrivere

            // scrivo comandi di scrittura
            C.intToBin(to_string(32), 8, wF);   // comando di scrittura
            C.intToBin(to_string(add), 8, wF);  // indirizzo
            C.intToBin(to_string(din), 16, wF); // dato
            wF << endl;

            // scrivo file di riferimento
            C.intToBin(to_string(din), 16, ref_F);
            ref_F << endl;

            // scrivo comandi di lettura
            C.intToBin(to_string(33), 8, rF);  // comando di lettura
            C.intToBin(to_string(add), 8, rF); // indirizzo
            rF << endl;
        }

        // chiudo i file
        wF.close();
        rF.close();
        ref_F.close();
    }
}

// Esecuzione simulazione mediante chiamata a system
void Simulation::run(string fileCompilazione)
{
    system(("vsim -c -do " + fileCompilazione).c_str()); // lancio la simulazione
}

// Controlla la correttezza dei risultati
unsigned int Simulation::report(string risultati_tb, string risultati_ref)
{
    string line_tb, line_ref; // righe dei due file
    int cnt_lines_tb = 0;     // contatore di riga del file generato dalla tb
    int cnt_lines_ref = 0;    // contatore di riga del file di riferimento
    int tot_correct = 0;      // numero totale di righe corrette all'interno del file generato dalla tb

    // apro i file in lettura
    ifstream tbF(risultati_tb);
    ifstream ref_F(risultati_ref);

    while (tbF.good() && ref_F.good())
    {
        // estraggo una riga da ognuno dei due file
        if (getline(tbF, line_tb) && getline(ref_F, line_ref))
        {
            // se i risultati della tb e del file di riferimento sono uguali incremento il contatore di righe corrette
            if (line_tb == line_ref)
            {
                tot_correct++;
            }
            // se i risultati sono diversi, esco dal ciclo (non ho più bisogno di controllare le righe restanti)
            else
            {
                cout << "Errore durante la transazione effettuata all'indirizzo " << cnt_lines_tb << endl;
                break;
            }

            // incremento i contatori di riga
            cnt_lines_tb++;
            cnt_lines_ref++;
        }
    }

    // chiudo i file
    tbF.close();
    ref_F.close();

    // stabilisco il valore del flag che mi dice se la simulazione è andata a buon fine
    if ((cnt_lines_tb == cnt_lines_ref) && (tot_correct == cnt_lines_ref))
        correct = 1;
    else
        correct = 0;

    return correct;
}
