<div align="center">
    <img src="assets/sketch.png" alt="drawing" width="400">
</div>
<div align="center">
<h1 align="center">DSS: Deep Sensors Systems</h1>
<h3 align="center">Framework for training and deploying deep neural networks for sensor systems</h3>

[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
![CI](https://github.com/andreped/DSS/workflows/Build%20APK/badge.svg)
[![GitHub Downloads](https://img.shields.io/github/downloads/andreped/DSS/total?label=GitHub%20downloads&logo=github)](https://github.com/andreped/DSS/releases)
 
**DSS** was developed by SINTEF Health with aim to integrate AIs into smart sensor systems. From training RNNs to deploying them in a mobile app in real time!
</div>


## Setup

When using this framework, it is a good idea to setup a virtual environment:
```
virtualenv -ppython3 venv --clear
./venv/Scripts/activate
pip install -r requirements.txt
```

Tested with Python 3.7.9.

## Usage

To train a model, simply run:
```
python main.py
```

The script supports multiple arguments. To see supported arguments, run `python main.py -h`.

## Training history

To visualize training history, use TensorBoard (with example):
```
tensorboard --logdir .\output\logs\gesture_classifier_arch_rnn
```

Example of training history for a Recurrent Neural Network (RNN) can be seen underneath:

<img src="assets/RNN_training_curve.png">

The figure shows macro-averaged F1-score for each step during training, with black curve for training and blue curve for validation sets.
Best model reached a macro-averaged F1 score of 99.66 % on the validation set, across all 20 classes.

**Disclaimer:** This model was only trained for testing purposes. The input features were stratified on sample-level and not patient-level, and thus validation performance will likely not represent true performance on new data. However, having a trained model enables us to test it in a Mobile app.

## Mobile app

A simple Mobile app was developed in Flutter, which demonstrates the AI in action using the accelerometer data from the mobile phone in real time:

<p align="center" width="100%">
<img src="sw_app/assets/app_snapshot_data.jpg" width="20%" height="20%"> <img src="sw_app/assets/app_snapshot_charts.jpg" width="20%" height="20%">
</p>

## Feature structure

I'm currently using the SmartWatch Gestures dataset,
which is available in [tensorflow-datasets](https://www.tensorflow.org/datasets/catalog/smartwatch_gestures). The dataset has the
following structure:
```
FeaturesDict({
    'attempt': tf.uint8,
    'features': Sequence({
        'accel_x': tf.float64,
        'accel_y': tf.float64,
        'accel_z': tf.float64,
        'time_event': tf.uint64,
        'time_millis': tf.uint64,
        'time_nanos': tf.uint64,
    }),
    'gesture': ClassLabel(shape=(), dtype=tf.int64, num_classes=20),
    'participant': tf.uint8,
})
```

## Acknowledgements

The training framework was mainly developed using [Keras](https://github.com/keras-team/keras) with [TensorFlow](https://github.com/tensorflow/tensorflow) backend.

The mobile app was developed using Flutter, which is a framework developed by Google.
For the app, the following _open_ packages were used [flutter_sensors](https://pub.dev/packages/flutter_sensors), [tflite_flutter](https://pub.dev/packages/tflite_flutter), and [wakelock](https://pub.dev/packages/wakelock).

