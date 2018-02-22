import os
import numpy as np
import pandas as pd
import argparse
import extract_features as ef
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import GaussianNB
from sklearn.cluster import KMeans
from sklearn.neighbors import KNeighborsClassifier

def load_files(feature_dir):
	files = os.listdir(feature_dir)
	files = list(map(lambda file: "{0}/{1}".format(feature_dir, file), files))
	print(files)
	data = pd.concat((pd.read_csv(f) for f in files))
	return data.values

def kNN(k, train, target):
	clf = KNeighborsClassifier(n_neighbors=k)
	return clf.fit(train, target)

def NaiveBayes(train, target):
	clf = GaussianNB()
	return clf.fit(train, target)

def main(args):
	#load data
	if args.raw_data_dir is not None:
		print(type(args.raw_data_dir))
		print(args.raw_data_dir)
		raw_data_files = os.listdir(args.raw_data_dir)
		print(raw_data_files)
		print("Generating features from data files")
		features = map(lambda raw_file: ef.generate_features(pd.read_csv("data/{0}".format(raw_file))), raw_data_files)
		data = pd.concat(features).values
		print("Done generating features")
	elif args.feature_dir is not None:
		data = load_files(args.feature_dir)

	data_train, data_test, target_train, target_test = train_test_split(data[:, 1:], data[:, 0], test_size = 0.4)
	
	print("Creating classifiers")
	nn_3 = kNN(3, data_train, target_train)
	nn_5 = kNN(5, data_train, target_train)
	gnb = NaiveBayes(data_train, target_train)
	names = ["3nn", "5nn", "GNB"]
	classifiers = [nn_3, nn_5, gnb]
	print("Testing classifiers")
	for name, clf in zip(names, classifiers):
		print("Score for {0}: {1}".format(name, clf.score(data_test, target_test)))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run Models")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--features', type=str,  dest="feature_dir", help='the relative filepath of feature dir')
    group.add_argument('--raws', type=str,  dest="raw_data_dir", help='the relative filepaths of the raw data dir')
    args = parser.parse_args()

    main(args)