PREFIX=
ARMLINK=
CC=g++

main: main.o Converter.o Simulation.o
	$(CC) -o main main.o Converter.o Simulation.o

main.o: main.cpp Converter.hpp Simulation.hpp
	$(CC) -c main.cpp

Converter.o: Converter.cpp Converter.hpp
	$(CC) -c Converter.cpp

Simulation.o: Simulation.cpp Converter.hpp Simulation.hpp
	$(CC) -c Simulation.cpp