import sys
from main import main


def test_train(monkeypatch):
    with monkeypatch.context() as m:
        m.setattr(sys, 'argv', ['main', '-ep', '2'])
        main()
