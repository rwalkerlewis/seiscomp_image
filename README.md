# Docker based environment for SeisComP

This environment provides an extensive Ubuntu 20.04 environment, as well as building the latest
SeisComP from source. The number of packages is likely far more than necessary at the moment.

Here is what it gives:
1. Basic commands like sudo, wget, nano
2. g++, gfortran, gcc, openmpi
3. Git support
4. SeisComP build from source
5. A dataless SEED and stationXML file for the CI network for 
   Southern California (BH* only)

Here is what it DOES NOT give:
1. This DOES NOT set environment variables (see housekeeping.sh)
2. This DOES NOT setup the database for seiscomp

## Usage
0. Ensure you have docker installed and running
1. Clone this repo
2. Open terminal and run, `chmod +x build.sh`
3. And run `chmod +x run.sh`
4. Run `./build.sh`
5. Run `./run.sh`
6. Run `chmod +x housekeeping.sh`
7. Setup database for seiscomp using SCConfig
8. Load CI stationXML/DSLV via SCConfig or other means
9. Set up parameter files for run and commence run (as outlined in the SeisComP documentation).

## Note:
- The `build_seiscomp.sh` file is for reference and not to be used (dockerfile auto builds seiscomp)
