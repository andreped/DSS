import tensorflow as tf
import tensorflow_datasets as tfds
from tensorflow.keras.callbacks import CSVLogger, ModelCheckpoint, EarlyStopping
from .models import get_model
import numpy as np


class Trainer:
    def __init__(self, ret):
        self.ret = ret
        self.history_path = "output/history/"
        self.model_path = "output/models/"
        self.name = "gesture_classifier_arch_" + ret.arch
        self.nb_classes = 20
        self.maxlen = 50
        self.feature_names = ['accel_x', 'accel_y', 'accel_z']

    def setup_dataset(self, dataset):
        dataset = dataset.map(lambda x, y: ({elem: tf.expand_dims(x[elem], axis=-1) for elem in x},
                                            tf.one_hot(y, depth=self.nb_classes, axis=0)))
        return dataset.map(lambda x, y: (merge_and_pad(x), y))

    def merge_and_pad(self, x):
        out = []
        for key_ in self.feature_names:
            tmp = x[key_]
            out.append(tmp)
        out = tf.concat(out, axis=1)
        return tf.pad(out, [[0, self.maxlen - tf.shape(out)[0]], [0, 0]])

    def fit(self):
        train, test, val = tfds.load('smartwatch_gestures', split=['train[:70%]', 'train[70%:85%]', 'train[85%:]'],
                                     as_supervised=True, shuffle_files=True)

        N_train = len(list(train))
        N_val = len(list(val))

        train = self.setup_dataset(train)
        val = self.setup_dataset(val)

        train = train.shuffle(buffer_size=4).batch(self.ret.batch_size).repeat(-1)
        val = val.shuffle(buffer_size=4).batch(self.ret.batch_size).repeat(-1)

        # define architecture
        model = get_model(self.ret)

        # early stopping
        early = EarlyStopping(patience=self.ret.patience, verbose=1)

        # setup history logger
        history = CSVLogger(
            self.history_path + "history_" + self.name + ".csv",
            append=True
        )

        # model checkpoint to save best model only
        save_best = ModelCheckpoint(
            self.model_path + "model_" + self.name,
            monitor="val_loss",
            verbose=2,
            save_best_only=True,
            save_weights_only=False,
            mode="auto",
            save_freq="epoch"
        )

        # compile model (define optimizer, losses, metrics)
        model.compile(
            optimizer=tf.keras.optimizers.Adam(learning_rate=self.ret.learning_rate),
            loss="categorical_crossentropy",
            metrics=["categorical_accuracy"],
        )

        # train model
        model.fit(
            train,
            steps_per_epoch=N_train // self.ret.batch_size,
            epochs=self.ret.epochs,
            validation_data=val,
            validation_steps=N_val // self.ret.batch_size,
            callbacks=[save_best, history, early],
            verbose=1,
        )

