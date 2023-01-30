from argparse import ArgumentParser
import sys
import os


def main():
    parser = ArgumentParser()
    parser.add_argument('-t', '--task', type=str, nargs='?', default="train",
                        help="which task to perform - either 'train' or 'eval'.")
    parser.add_argument('-v', '--verbose', type=int, nargs='?', default=1,
                        help="sets the verbose level.")
    parser.add_argument('-bs', '--batch_size', type=int, nargs='?', default=8,
                        help="set which batch size to use for training.")
    parser.add_argument('-lr', '--learning_rate', type=float, nargs='?', default=0.001,
                        help="set which learning rate to use for training.")
    parser.add_argument('-ep', '--epochs', type=int, nargs='?', default=500,
                        help="number of epochs to train.")
    parser.add_argument('-pa', '--patience', type=int, nargs='?', default=10,
                        help="number of epochs to wait (patience) for early stopping.")
    parser.add_argument('-a', '--arch', type=str, nargs='?', default="vit",
                        help="which architecture to use.")
    parser.add_argument('-ls', '--loss', type=str, nargs='?', default="cce",
                        help="which loss function to use. Supportes losses are: {'cce', 'focal'}.")
    args = parser.parse_known_args(sys.argv[1:])[0]
    
    print(args)

    # setup folders
    os.makedirs("output/models/", exist_ok=True)
    os.makedirs("output/history/", exist_ok=True)
    os.makedirs("output/datasets/", exist_ok=True)

    if args.task == "train":
        from dss.train import Trainer
        Trainer(args).fit()
    elif args.task == "deploy":
        from src.eval import Evaluator
        Evaluator(args)
    else:
        raise ValueError("Unknown task specified. Available tasks include {'train', 'eval'}, but used:", args.task)


if __name__ == "__main__":
    main()
