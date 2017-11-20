import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import GaussianNB
walk6csv = np.loadtxt ('feature_vectors/walk6top_raw.csv', delimiter=",", skiprows=1)
walk3csv = np.loadtxt ('feature_vectors/walk3top_raw.csv', delimiter=",", skiprows=1)
walk6_target = walk6csv[:, 0]
walk6_data = walk6csv[:, 1:]
walk3_target = walk3csv[:, 0]
walk3_data = walk3csv[:, 1:]

#data_train, data_test, target_train, target_test = train_test_split(walk6_data, walk6_target, test_size = 0.4)

gnb = GaussianNB()

walk_pred = gnb.fit(walk6_data, walk6_target).predict(walk3_data)
print("Number of mislabeled points out of a total %d points : %d" % (walk3_data.shape[0],(walk3_target != walk_pred).sum()))
