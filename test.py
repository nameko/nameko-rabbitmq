#!/usr/bin/env python
import ssl
from os.path import abspath, dirname, join

from kombu.connection import Connection
import pytest


@pytest.fixture
def certs_dir():
    return join(dirname(abspath(__file__)), "certs")


def test_connection():
    conn = Connection('amqp://guest:guest@localhost:5672/')
    conn.connect()
    assert conn.connected
    conn.release()


def test_secure_connection(certs_dir):
    conn = Connection('amqp://guest:guest@localhost:5671/', ssl={
        'ca_certs': join(certs_dir, 'cacert.pem'),
        'keyfile': join(certs_dir, 'clientkey.pem'),
        'certfile': join(certs_dir, 'clientcert.pem'),
        'cert_reqs': ssl.CERT_REQUIRED,
    })
    conn.connect()
    assert conn.connected
    conn.release()


def test_secure_connection_without_cert_verification(certs_dir):
    conn = Connection('amqp://guest:guest@localhost:5671/', ssl=True)
    conn.connect()
    assert conn.connected
    conn.release()


def test_external_login_method(certs_dir):
    conn = Connection(
        'amqp://localhost:5671/',
        login_method="EXTERNAL",
        ssl={
            'ca_certs': join(certs_dir, 'cacert.pem'),
            'keyfile': join(certs_dir, 'clientkey.pem'),
            'certfile': join(certs_dir, 'clientcert.pem'),
            'cert_reqs': ssl.CERT_REQUIRED,
        },
    )
    conn.connect()
    assert conn.connected
    conn.release()
