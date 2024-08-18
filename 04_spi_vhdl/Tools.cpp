#include <iostream>
#include <cstring>
#include <string>

#include "Tools.hpp"

// Costruttore che assegna un valore di default a "correct"
Tools::Tools(unsigned int default_correct)
    : correct{default_correct} {}

// Verifica se la stringa "number" contiene un numero intero
unsigned int Tools::isInt(string number)
{
    correct = 1;
    char *c_number = new char[number.length() + 1]; // numero convertito in array di char (per poter usare i codici ASCII)
    strcpy(c_number, number.c_str());               // copio number in c_number

    for (int i = 0; i < strlen(c_number); i++)
    { // scorro un carattere per volta
        if (c_number[i] < 48 || c_number[i] > 57)
        { // cifre decimali --> codici ASCII 48-57
            correct = 0;
            continue; // esci dal for
        }
    }
    return correct;
}

// Verifica se la stringa "number" contiene un numero binario
unsigned int Tools::isBin(string number)
{
    correct = 1;
    char *c_number = new char[number.length() + 1];
    strcpy(c_number, number.c_str());

    for (int i = 0; i < strlen(c_number); i++)
    { // scorro un carattere per volta
        if (c_number[i] != 48 && c_number[i] != 49)
        { // cifre binarie --> codici ASCII 48-49
            correct = 0;
            continue; // esci dal for
        }
    }
    return correct;
}

// Verifica se la stringa "number" contiene un numero esadecimale
unsigned int Tools::isHex(string number)
{
    correct = 1;
    char *c_number = new char[number.length() + 1];
    strcpy(c_number, number.c_str());

    for (int i = 0; i < strlen(c_number); i++)
    {                                                     // scorro un carattere per volta
        if (!((c_number[i] >= 48 && c_number[i] <= 57) || // cifre da 0 a 9 --> codici ASCII 48-57
              (c_number[i] >= 65 && c_number[i] <= 70) || // lettere maiuscole A-F --> codici ASCII 65-70
              (c_number[i] >= 97 && c_number[i] <= 102)))
        { // lettere minuscole a-f --> codici ASCII 97-102
            correct = 0;
            continue;
        }
    }
    return correct;
}