#!/usr/bin/env python
import ssl
from os.path import abspath, dirname

from kombu.connection import Connection
import pytest


@pytest.fixture
def certs_dir():
    return dirname(abspath(__file__))


def test_connection():
    conn = Connection('amqp://guest:guest@localhost:5672/')
    conn.connect()
    assert conn.connected
    conn.release()


def test_secure_connection(certsdir):
    conn = Connection('amqp://guest:guest@localhost:5671/', ssl={
        'ca_certs': f'{certs_dir}/cacert.pem',
        'keyfile': f'{certs_dir}/clientkey.pem',
        'certfile': f'{certs_dir}/clientcert.pem',
        'cert_reqs': ssl.CERT_REQUIRED,
    })
    conn.connect()
    assert conn.connected
    conn.release()
