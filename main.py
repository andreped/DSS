from argparse import ArgumentParser
import sys
import os


def main():
    parser = ArgumentParser()
    parser.add_argument('--task', metavar='--t', type=str, nargs='?', default="train",
                        help="which task to perform - either 'train' or 'eval'.")
    parser.add_argument('--verbose', metavar='--v', type=int, nargs='?', default=1,
                        help="sets the verbose level.")
    parser.add_argument('--batch_size', metavar='--bs', type=int, nargs='?', default=512,
                        help="set which batch size to use for training.")
    parser.add_argument('--learning_rate', metavar='--lr', type=float, nargs='?', default=0.0003,
                        help="set which learning rate to use for training.")
    ret = parser.parse_known_args(sys.argv[1:])[0]

    if ret.task == "train":
        from src.train import Trainer
        Trainer(ret).fit()
    elif ret.task == "deploy":
        from src.eval import Evaluator
        Evaluator(ret)
    else:
        raise ValueError("Unknown task specified. Available tasks include {'train', 'eval'}, but used:", ret.task)


if __name__ == "__main__":
    main()
