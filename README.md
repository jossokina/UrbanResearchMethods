## UrbanResearchMethods

This project contains the assignment on speed prediction using speed detectors.

All project files are located in the ./scripts folder. Inside you will find three files:

main_preprocessing_part1.R – Students work on the linear models part of the assignment here.
The script already includes the code to load the training and test sets, as well as the required libraries.

main_linear_models_part2.R – Students work on the linear models part of the assignment here.
The script already includes the code to load the training and test sets, as well as the required libraries.

main_tree_models_part3.R – Students work on the tree models part of the assignment here.
This script includes code to load the training and test sets, the required libraries, and the constants for each model.
Important: Do not change these constants; they represent the optimal parameters for the models.

helpers.R – Contains the auxiliary function summarize_feature_importance_trees() which students should use to retrieve the feature importance of the tree models and return it as a table.
Important: Do not modify this script and do not use other libraries for the tree models, otherwise the function will not work.

Data must be contained in the folder ./data. There are 4 datasets in the folder. One train and test set for part 1 (*_part1.csv) and one train and one test set used in both part 2 and 3 (*_clean.py). Students are not required to save the final dataset after preprocessing part. However, if it would be ever needed to produced new clean dataset, the solution script for part 1 has already the code to save the dataset.

All the .tex and .html tables are saved in the ./tables. The folder is created automatically when the main files are run.