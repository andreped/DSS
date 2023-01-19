from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input, Dense, BatchNormalization, Dropout,\
    Activation, Concatenate, Conv1D, MaxPool1D, GlobalAveragePooling1D, Reshape,\
    Conv2D, LSTM, Masking, Normalization
from .layers import transformer_encoder


def get_model(ret, mu=None, var=None):
    nb_classes = 20
    maxlen = 50
    if ret.arch == "rnn":
        inputs = Input(shape=(maxlen, 3))

        # disabled zero-mean normalization for now
        #x = Normalization(axis=-1, mean=mu, variance=var, input_shape=(maxlen, 3))(inputs)
        #x = Masking(mask_value=-999)(x)  # @TODO: ordinary 0.0 values can happen!

        x = Masking(mask_value=0, input_shape=(maxlen, 3))(inputs)
        x = LSTM(32)(x)
        x = Dropout(rate=0.5)(x)
        x = Dense(32)(x)
        x = Activation("relu")(x)
        x = Dense(nb_classes, activation="softmax")(x)
        return Model(inputs=inputs, outputs=x)

    elif ret.arch == "vit":
        inputs = Input(shape=(maxlen, 3))
        x = inputs
        for _ in range(4):
            x = transformer_encoder(x, head_size=128, num_heads=4, ff_dim=4, dropout=0.25)

        x = GlobalAveragePooling1D(data_format="channels_first")(x)
        for dim in [64]:
            x = Dense(dim, activation="relu")(x)
        x = Dense(nb_classes, activation="softmax")(x)
        return Model(inputs=inputs, outputs=x)

    else:
        raise ValueError("Unknown architecture provided:", ret.arch)
