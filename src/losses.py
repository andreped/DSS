from tensorflow.python.keras import backend as K
import tensorflow as tf


# https://github.com/zhezh/focalloss/blob/master/focalloss.py
def categorical_focal_loss(alpha=1., gamma=2.):
    def focal_loss(y_true, y_pred):
        # clip the prediction value to prevent NaN's and Inf's
        epsilon = K.epsilon()
        y_pred = K.clip(y_pred, epsilon, 1. - epsilon)

        # calculate Cross Entropy
        cross_entropy = -y_true * K.log(y_pred)

        # calculate Focal Loss
        loss = alpha * y_true * K.pow(1 - y_pred, gamma) * cross_entropy

        # compute loss in each mini batch
        return tf.reduce_sum(loss, axis=-1)
    return focal_loss
