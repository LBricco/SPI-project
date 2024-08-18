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

int main(int argc, char **argv)
{

    int ret = 0;
    Simulation Simulator;

    /**********************************************************************************/
    /*        Inizializzazione degli oggetti necessari alla gestione dei file         */
    /**********************************************************************************/

    const string tbFileName = "tb_spi_complete.vhd";       // testbench
    const string compileFileName = "compile.do";           // file con le info per la simulazione
    const string writeFileName = "input_wr.txt";           // file con i comandi di scrittura
    const string readFileName = "input_rd.txt";            // file con i comandi di lettura
    const string ref_oFileName = "output_results_ref.txt"; // file dati per confronto
    const string tb_oFileName = "output_results.txt";      // file di output generato dalla testbench

    // check esistenza testbench
    if (!filesystem::exists(tbFileName))
    {
        cerr << "Errore! La testbench " << tbFileName << " non esiste." << endl;
        ret = 1;
    }

    // check esistenza file per la compilazione
    if (!filesystem::exists(compileFileName))
    {
        cerr << "Errore! Il file per la compilazione " << compileFileName << " non esiste." << endl;
        ret = 1;
    }

    /**********************************************************************************/
    /*                            Simulazione automatizzata                           */
    /**********************************************************************************/

    // generazione file di scrittura
    Simulator.generate(writeFileName, readFileName, ref_oFileName);

    // simulazione automatizzata
    cout << endl
         << "*********************************************************************" << endl;
    cout << "Inizio Simulazione Modelsim" << endl;
    Simulator.run(compileFileName);
    cout << "Fine Simulazione Modelsim" << endl;
    cout << "*********************************************************************" << endl
         << endl;

    // controllo risultati
    int simulazione_corretta = Simulator.report(ref_oFileName, tb_oFileName);
    if (simulazione_corretta == 1)
    {
        cout << "OK! Tutte le transazioni di lettura e scrittura sono andate a buon fine." << endl;
        cout << "Verosimilmente l'interfaccia SPI funziona correttamente! :)" << endl
             << endl;
    }
    else
    {
        cout << endl
             << "Non tutte le transazioni di lettura hanno prodotto risultati uguali ai dati trasmessi in scrittura." << endl;
        cout << "L'interfaccia SPI non funziona. :(" << endl
             << endl;
    }

    return ret; // punto di uscita dal programma
}