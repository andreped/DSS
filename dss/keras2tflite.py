from tensorflow import lite
import tensorflow as tf
from argparse import ArgumentParser
import os
import sys


def convert(model_path):
    model = tf.saved_model.load(model_path)
    concrete_func = model.signatures[
        tf.saved_model.DEFAULT_SERVING_SIGNATURE_DEF_KEY]
    concrete_func.inputs[0].set_shape([1, 50, 3])
    converter = lite.TFLiteConverter.from_concrete_functions([concrete_func])
    tflite_model = converter.convert()


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument('-m', '--model', type=str, nargs='?',
                        help="full path to which pretrained model to convert to TensorFlow Lite.")
    args = parser.parse_known_args(sys.argv[1:])[0]

    if not os.path.exists(args.model):
        raise ValueError("Provided model does not exist on disk.")

    convert(args.model)
