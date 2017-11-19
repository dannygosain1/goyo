import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import GaussianNB
walk6csv = np.loadtxt ('feature_vectors/walk6front_raw.csv', delimiter=",", skiprows=1)
walk6_target = walk6csv[:, 0]
walk6_data = walk6csv[:, 1:]

data_train, data_test, target_train, target_test = train_test_split(walk6_data, walk6_target, test_size = 0.4)

gnb = GaussianNB()

walk_pred = gnb.fit(data_train, target_train).predict(data_test)
print("Number of mislabeled points out of a total %d points : %d" % (data_test.shape[0],(target_test != walk_pred).sum()))
