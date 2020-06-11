# matlab-4-nastran
Object-oriented Matlab framework for the manipulation of Nastran input models and simulation results.

## Motivation
This project was created as a follow-up of my work for several tasks dealing with aeroelastic analyses with MSC Nastran. The motivation behind the creation and maintenance of this project stems from the desire to have an object-oriented framework to manage input and output data of simulations in Nastran. Such object-oriented framework is considered to give advantages in terms of modularity and flexibility, together with the convenient opportunity to track the dependencies of the elements composing the computational model. A big step towards the formalization of this framework was made while working on a research project at TU Delft involving the design of an aeroelastically tailored wing. This research project ended up in a [paper for SciTech 2020](https://arc.aiaa.org/doi/abs/10.2514/6.2020-1636), where the framework is partially explained.

## Installation
***Warning: you must have Nastran already installed in your computer to use the framework!***

1. Download the package to a local folder (e.g. ~/matlab-4-nastran/) by running: 
```console
git clone https://github.com/fmamitrotta/matlab-4-nastran.git
```
2. Run Matlab and add the folder (~/matlab-4-nastran/) to your Matlab path.

3. Try some of the example scripts to get an understanding of the framework. Enjoy!

## Contributing
Please don't hesistate to throw feedback and suggestions. Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[GPL-3.0](https://choosealicense.com/licenses/gpl-3.0/)
