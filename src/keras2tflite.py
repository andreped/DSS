from tensorflow import lite
import tensorflow as tf

if __name__ == "__main__":
    saved_model_dir = "C:/Users/andrp/workspace/DeepSWSensor/" +\
                      "output/models/model_gesture_classifier_arch_rnn/"

    model = tf.saved_model.load(saved_model_dir)
    concrete_func = model.signatures[
        tf.saved_model.DEFAULT_SERVING_SIGNATURE_DEF_KEY]
    concrete_func.inputs[0].set_shape([1, 50, 3])
    converter = lite.TFLiteConverter.from_concrete_functions([concrete_func])
    tflite_model = converter.convert()
