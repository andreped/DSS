from datetime import datetime, date
import tensorflow as tf
import tensorflow_datasets as tfds
import tensorflow_addons as tfa
from tensorflow.keras.callbacks import CSVLogger, ModelCheckpoint, EarlyStopping, TensorBoard
import numpy as np
from .models import get_model
from .losses import categorical_focal_loss


class Trainer:
    def __init__(self, ret):
        self.ret = ret
        date_time = self.get_datetime()
        self.name = date_time[0] + "_" + date_time[1] + "_gesture_classifier_arch_" + ret.arch
        self.history_path = "output/history/"
        self.model_path = "output/models/"
        self.dataset_path = "output/datasets/" + self.name + "/"
        self.nb_classes = 20
        self.maxlen = 50
        self.feature_names = ['accel_x', 'accel_y', 'accel_z']

    def setup_dataset(self, dataset):
        dataset = dataset.map(lambda x, y: ({elem: tf.expand_dims(x[elem], axis=-1) for elem in x},
                                            tf.one_hot(y, depth=self.nb_classes, axis=0)))
        return dataset.map(lambda x, y: (self.merge(x), y))

    def merge(self, x):
        out = []
        for key_ in self.feature_names:
            tmp = x[key_]
            out.append(tmp)
        out = tf.concat(out, axis=1)
        return out

    def pad(self, dataset, value=0):
        return dataset.map(lambda x, y: (tf.pad(x, [[0, self.maxlen - tf.shape(x)[0]], [0, 0]],
                                                mode='CONSTANT', constant_values=value),
                                         y))

    def get_datetime(self):
        curr_date = "".join(date.today().strftime("%d/%m").split("/")) + date.today().strftime("%Y")[2:]
        curr_time = "".join(str(datetime.now()).split(" ")[1].split(".")[0].split(":"))
        return curr_date, curr_time

    def get_mu_and_var(self, dataset):
        tmp = []
        for x, y in dataset:
            x = np.array(x)
            tmp.extend(x)
        return np.mean(tmp, axis=0), np.var(tmp, axis=0)

    def fit(self):
        # get supervised data
        train, test, val = tfds.load('smartwatch_gestures', split=['train[:80%]', 'train[80%:90%]', 'train[90%:]'],
                                     as_supervised=True, shuffle_files=True)

        N_train = len(list(train))
        N_val = len(list(val))

        # preprocess data
        train = self.setup_dataset(train)
        val = self.setup_dataset(val)
        test = self.setup_dataset(test)

        # get mu and std from train set, for each feature
        mu, var = self.get_mu_and_var(train)

        # pad all sequences to fixed maxlen
        train = self.pad(train)
        val = self.pad(val)
        test = self.pad(test)

        train = train.shuffle(buffer_size=4).batch(self.ret.batch_size).prefetch(1).repeat(-1)
        val = val.shuffle(buffer_size=4).batch(self.ret.batch_size).prefetch(1).repeat(-1)

        # define architecture
        model = get_model(self.ret, mu=mu, var=var)

        # tensorboard history logger
        tb_logger = TensorBoard(log_dir="output/logs/" + self.name + "/", histogram_freq=1, update_freq="batch")

        # early stopping
        early = EarlyStopping(patience=self.ret.patience, verbose=1)

        # setup history logger
        history = CSVLogger(
            self.history_path + "history_" + self.name + ".csv",
            append=True
        )

        # model checkpoint to save best model only
        save_best = ModelCheckpoint(
            self.model_path + "model_" + self.name + ".h5",
            monitor="val_loss",
            verbose=2,
            save_best_only=True,
            save_weights_only=False,
            mode="auto",
            save_freq="epoch"
        )

        # define loss
        if self.ret.loss == "cce":
            loss_ = "categorical_crossentropy"
        elif self.ret.loss == "focal":
            loss_ = categorical_focal_loss()
        else:
            raise ValueError("Unknown loss function specified. Supported losses are: {'cce', 'focal'}.")

        # compile model (define optimizer, losses, metrics)
        model.compile(
            optimizer=tf.keras.optimizers.Adam(learning_rate=self.ret.learning_rate),
            loss=loss_,
            metrics=["acc"],  # , tfa.metrics.F1Score(num_classes=self.nb_classes, average="macro")],
        )

        # train model
        model.fit(
            train,
            steps_per_epoch=N_train // self.ret.batch_size,
            epochs=self.ret.epochs,
            validation_data=val,
            validation_steps=N_val // self.ret.batch_size,
            callbacks=[save_best, history, early, tb_logger],
            verbose=1,
        )
