import tensorflow as tf
# from tfds.time_series.smartwatch_gestures import SmartwatchGestures
import tensorflow_datasets as tfds


class Trainer:
    def __init__(self, ret):
        self.ret = ret

    def fit(self):
        train, test, val = tfds.load('smartwatch_gestures', split=['train[:80%]', 'train[80%:95%]', 'train[95%:]'],
                                     as_supervised=True, shuffle_files=True)

        print(train)

