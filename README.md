<div align="center">
    <img src="assets/sketch.png" alt="drawing" width="400">
</div>
<div align="center">
<h1 align="center">DSS: Deep Sensors Systems</h1>
<h3 align="center">From training and deployment of ViTs to development of real-time cross-platform mobile apps</h3>

[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![GitHub Downloads](https://img.shields.io/github/downloads/andreped/DSS/total?label=GitHub%20downloads&logo=github)](https://github.com/andreped/DSS/releases)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7603053.svg)](https://doi.org/10.5281/zenodo.7603053)
[![codecov](https://codecov.io/gh/andreped/DSS/branch/main/graph/badge.svg?token=Nf2GKXXYXE)](https://codecov.io/gh/andreped/DSS)
 
**DSS** was developed by SINTEF Health with aim to integrate AIs into smart sensor systems.
</div>

Below there are described some of the key features of this project, but to see what else is possible, please, see [the wiki](https://github.com/andreped/DSS/wiki).

## Continuous integration

| Build Type | Status |
| - | - |
| **Test Training** | ![CI](https://github.com/andreped/DSS/workflows/Test%20Training/badge.svg) |
| **Test Flutter** | ![CI](https://github.com/andreped/DSS/workflows/Test%20Flutter/badge.svg)| 
| **Build APK** | ![CI](https://github.com/andreped/DSS/workflows/Build%20APK/badge.svg) |


## How to your train own model?

### Setup

When using this framework, it is a good idea to setup a virtual environment:
```
virtualenv -ppython3 venv --clear
source venv/bin/activate
pip install -r requirements.txt
```

Tested with Python 3.7.9, on Win10, macOS, and Ubuntu Linux operating systems.

Note that to activate the virtual environment on Windows instead run `./venv/Scripts/activate`.

### Usage

To train a model, simply run:
```
python main.py
```

The script supports multiple arguments. To see supported arguments, run `python main.py -h`.

### Training history

To visualize training history, use TensorBoard (with example):
```
tensorboard --logdir ./output/logs/gesture_classifier_arch_rnn/
```

Example of training history for a Recurrent Neural Network (RNN) can be seen underneath:

<img src="assets/RNN_training_curve.png">

The figure shows macro-averaged F1-score for each step during training, with black curve for training and blue curve for validation sets.
Best model reached a macro-averaged F1 score of 99.66 % on the validation set, across all 20 classes.

**Disclaimer:** This model was only trained for testing purposes. The input features were stratified on sample-level and not patient-level, and thus validation performance will likely not represent true performance on new data. However, having a trained model enables us to test it in a Mobile app.

## How to test the model in a mobile app?

### Converting model to TF-Lite

In order to be able to use the trained model in a mobile app, it is necessary to convert the model to a compatible format. TensorFlow Lite is an inference engine tailored for mobile devices. To convert the model to TF-Lite, simply run this command:

```
python dss/keras2tflite.py -m /path/to/pretrained/saved_model/ -o /path/to/save/converted/model.tflite
```

### Model integration and testing in app

A simple Mobile app was developed in Flutter, which demonstrates the AI in action using the accelerometer data from the mobile phone in real time:

<p align="center" width="100%">
<img src="sw_app/assets/app_snapshot_data.jpg" width="20%" height="20%"> <img src="sw_app/assets/app_snapshot_charts.jpg" width="20%" height="20%">
</p>

To use the app, you need an Android phone and have developer mode enabled (see [here](https://developer.android.com/studio/debug/dev-options) for how to enable it). Then simply download the APK from [here](https://github.com/andreped/DSS/releases/tag/v0.1.0), double-click to install, and use the app as you normally would.

Info on how the mobile app was developed (and how to make your own app), can be found [in the wiki](https://github.com/andreped/DSS/wiki/Getting-started-with-mobile-development).

## Which data is available?

### SmartWatch Gestures

The current data used to train the AI model is the SmartWatch Gestures dataset,
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
For the app, the following _open_ packages were used (either MIT or BSD-2 licensed):
* [flutter_sensors](https://pub.dev/packages/flutter_sensors)
* [tflite_flutter](https://pub.dev/packages/tflite_flutter)
* [wakelock](https://pub.dev/packages/wakelock)
* [sqflite](https://pub.dev/packages/sqflite)
* [provider](https://pub.dev/packages/provider)

## How to cite

If you found this project useful, please, consider citing it in your research article:

```
@software{andre_pedersen_2023_7603053,
  author       = {André Pedersen and Ute Spiske and Javier Pérez de Frutos},
  title        = {andreped/DSS: v0.1.3},
  month        = feb,
  year         = 2023,
  publisher    = {Zenodo},
  version      = {v0.1.3},
  doi          = {10.5281/zenodo.7603053},
  url          = {https://doi.org/10.5281/zenodo.7603053}
}
```

