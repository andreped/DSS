from main import main
import sys


def test_train(monkeypatch):
    with monkeypatch.context() as m:
        m.setattr(sys, 'argv', ['main', '-ep', '2'])
        main()
