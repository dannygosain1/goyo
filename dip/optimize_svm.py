import os
import numpy as np
import pandas as pd
from scipy import stats
import argparse
import extract_features as ef
from sklearn.model_selection import train_test_split
from sklearn.model_selection import KFold
from sklearn.model_selection import GridSearchCV
from sklearn.naive_bayes import GaussianNB
from sklearn.cluster import KMeans
from sklearn.neighbors import KNeighborsClassifier
from sklearn import svm
from sklearn.metrics import accuracy_score
from sklearn.metrics import precision_score
from sklearn.metrics import recall_score
from sklearn.metrics import f1_score

def load_files(feature_dir):
    files = os.listdir(feature_dir)
    files = list(map(lambda file: "{0}/{1}".format(feature_dir, file), files))
    data = pd.concat((pd.read_csv(f) for f in files))
    return data.values

def gen_svm_parameters() :
	C_params =[1, 10, 100, 1000, 2000, 10000] 
	# for x in range(200):
	# 	C_params.append(x*50+1)
	tuned_parameters = [{ 'kernel': ['rbf', 'poly'], 'gamma':['auto', 0.1, 1] 'C': C_params},
						{ 'kernel': ['linear'], 'C': C_params}
					   ]
	return tuned_parameters

def main(args):
	data = load_files(args.feature_dir)
	data_train, data_test, target_train, target_test = train_test_split(data[:, 1:], data[:, 0], test_size = 0.4)

	tuned_parameters = gen_svm_parameters()
	clf = GridSearchCV(svm.SVC(), tuned_parameters, cv=5)
	clf.fit(data_train, target_train)
	print("Best parameters set found on development set:")
	print()
	print(clf.best_params_)
	print()
	print("Grid scores on development set:")
	print()
	means = clf.cv_results_['mean_test_score']
	stds = clf.cv_results_['std_test_score']
	for mean, std, params in zip(means, stds, clf.cv_results_['params']):
		print("%0.3f (+/-%0.03f) for %r" % (mean, std * 2, params))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run Models")
    parser.add_argument('--features', type=str,  dest="feature_dir", help='the relative filepath of feature dir')
    args = parser.parse_args()
    main(args)
