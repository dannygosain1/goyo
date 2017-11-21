import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import GaussianNB

# top data

walk6_top_csv = np.loadtxt ('feature_vectors/walk6top_standard.csv', delimiter=",")
walk5_top_csv = np.loadtxt ('feature_vectors/walk5top_standard.csv', delimiter=",")
walk6_top_target = walk6_top_csv[:, 0]
walk6_top_data = walk6_top_csv[:, 1:]
walk5_top_target = walk5_top_csv[:, 0]
walk5_top_data = walk5_top_csv[:, 1:]

#data_train, data_test, target_train, target_test = train_test_split(walk6_top_data, walk6_top_target, test_size = 0.4)

gnb = GaussianNB()

walk5_top_pred = gnb.fit(walk6_top_data, walk6_top_target).predict(walk5_top_data)
print("Number of mislabeled points from top sensor with standard features out of a total %d points : %d" % (walk5_top_data.shape[0],(walk5_top_target != walk5_top_pred).sum()))
