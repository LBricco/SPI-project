#ifndef TOOLS_H
#define TOOLS_H

using namespace std;

class Tools {
    public:
        // Costruttore esplicito che assegna un valore di default a "correct"
        explicit Tools(unsigned int default_correct = 1);
        unsigned int isBin(string number);
        unsigned int isInt(string number);
        unsigned int isHex(string number);

    private:
        unsigned int correct; // flag che ci dice se la conversione è andata bene
};

#endif