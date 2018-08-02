import os
import ctypes

for d, _, files in os.walk('lib'):
    for f in files:
        if f.endswith('.a'):
            continue
        ctypes.cdll.LoadLibrary(os.path.join(d, f))


import scipy
from scipy import special
from ampercore.objects.metric import StateType
import logging
import numpy as np
import pandas as pd
from statsmodels import api
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
from sklearn import datasets

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

def handler(event, context):
    logger.info(special.gammaln(12345))
    logger.info(StateType.Lost)
    a = np.array(10)
    logger.info(a)
    d = {'test': list(range(10))}
    df = pd.DataFrame(data=list(range(10)))
    logger.info(df)
    logger.info(api.tsa.acf(list(range(10)), 10))
    dataset = datasets.load_iris()
    X = dataset.data
    y = dataset.target
    kmeans_model = KMeans(n_clusters=3, random_state=1).fit(X)
    labels = kmeans_model.labels_
    logger.info(silhouette_score(X, labels, metric='euclidean'))
    return {'yay': 'done'}
