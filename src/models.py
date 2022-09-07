from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input, Dense, BatchNormalization, Dropout,\
    Activation, Concatenate, Conv1D, MaxPool1D, GlobalAveragePooling1D, Reshape,\
    Conv2D, LSTM, Masking, Normalization


def get_model(ret):
    nb_classes = 20
    class_names = ['accel_x', 'accel_y', 'accel_z']  # , 'time_event', 'time_millis', 'time_nanos']
    if ret.arch == "mlp":
        # inputs = [Input(shape=(None, 1), name=class_) for class_ in class_names]
        inputs = Input(shape=(50, 3))
        # x = Concatenate(axis=-1)(inputs)

        x = Masking(mask_value=0.0, input_shape=(50, 3))(inputs)
        # x = Normalization(axis=-1, mean=None, variance=None)(x)  # @TODO: Vector of nb_features for mean and variance
        x = LSTM(32)(x)
        x = Dropout(rate=0.5)(x)
        x = Dense(32)(x)
        x = Activation("relu")(x)
        x = Dense(nb_classes, activation="softmax")(x)  # @TODO: Y U NO SOFTMAX?
        return Model(inputs=inputs, outputs=x)
        # return Model(inputs={c: z for c, z in zip(class_names, inputs)}, outputs=x)
    else:
        raise ValueError("Unknown architecture provided:", ret.arch)
