# servoball_code
operating program for the servoball virtual reality system

servoball_code

operating program for the servoball virtual reality system

Delphi6 (Borland)

This program works with a servoball setup consisting of 2 servomotors (controlled by (Addidata APCI-3120), 6 TFT screens, camera (BaslerKam_602f), x/y sensors (ADNS-3080 Chip, Agilent technologies) , feeders and doors for 24h/7d automatic experiment system, controlled by PCI_1710, Addidata (Agilent Technologies)

For description of the setup see: xxx

content of the program:

    there must be a definition of a maze in the folder "labdat". It has to be a ***.txt file in a certain structure: There are examples for several different mazes in the folder "labdat"
    unit1.pas: defines parameters of perspective and position of virtual camera in the VR
    unit2.pas: counts nose-pokes
    unit3.pas: controles feeding events
    unit4.pas: implements T-form
    unit5.pas: connects TCPIP with Basler camera
    unit mapandvars.pas: creates the virtual reality with walls, crossings and floors and covers them with a defined texture
    compensation will only be activated in alleys defined in the maze- file
    unit lakutpu.pas: compares tracking data with the geometrical structure of the maze and initalizes and stops compensation
    in the T-form serveral experimental parameters can be chosen
    there will be an automatically generated datafile with tracking data and experimental data like nose-poke and feeding events in the folder "data"
    unit global_variables.pas: defines a set of global variables and arrays

