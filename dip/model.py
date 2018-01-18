import numpy as np
import pandas as pd
import argparse
import extract_features as ef
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import GaussianNB
from sklearn.cluster import KMeans
from sklearn.neighbors import KNeighborsClassifier

def load_files(filenames):
	data = pd.concat((pd.read_csv(f) for f in filenames))
	return data.values

def kNN(k, train, target):
	clf = KNeighborsClassifier(n_neighbors=k)
	return clf.fit(train, target)

def NaiveBayes(train, target):
	clf = GaussianNB()
	return clf.fit(train, target)

def main(args):
	#load data
	if args.raw_data_files is not None:
		features = map(lambda raw_file: ef.generate_features(pd.read_csv(raw_file)), args.raw_data_files)
		data = pd.concat(features).values
	elif args.features is not None:
		data = load_files(args.features)

	data_train, data_test, target_train, target_test = train_test_split(data[:, 1:], data[:, 0], test_size = 0.3)
	
	nn_3 = kNN(3, data_train, target_train)
	nn_5 = kNN(5, data_train, target_train)
	gnb = NaiveBayes(data_train, target_train)
	names = ["3nn", "5nn", "GNB"]
	classifiers = [nn_3, nn_5, gnb]
	for name, clf in zip(names, classifiers):
		print("Score for {0}: {1}".format(name, clf.score(data_test, target_test)))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run Models")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--features', nargs='*', type=str,  dest="features", help='the relative filepaths')
    group.add_argument('--raws', nargs='*', type=str,  dest="raw_data_files", help='the relative filepaths')
    args = parser.parse_args()

    main(args)