<div align="center">
<h1 align="center">DSWS: Deep Smart Watch Sensors</h1>
<h3 align="center">Framework for training deep models for sensor interaction</h3>
 
**DSWS** was developed by SINTEF Health with aim to integrate state-of-the-art methods into Smart Watch sensor systems.
</div>


### Setup

When using this framework, it is a good idea to setup a virtual environment:
```
virtualenv -ppython3 venv --clear
./venv/Scripts/activate
pip install -r requirements.txt
```

### Usage

To train a model, simply run:
```
python main.py
```

The script supports multiple arguments. To see supported arguments, run `python main.py -h`.

### Training history

To visualize training history, use TensorBoard (with example):
```
tensorboard --logdir .\output\logs\gesture_classifier_arch_rnn
```

Example of training history for Vision Transformer can be seen underneath:

<img src="assets/RNN_training_curve.png">

The figure shows macro-averaged F1-score for each step during training, with black curve for training and blue curve for validation sets.
Best model reached a macro-averaged F1 score of 99.66 % on the validation set, across all 20 classes.

### Feature structure

I'm currently using the SmartWatch Gestures dataset,
which is available in tensorflow-datasets. The dataset has the
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
