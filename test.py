#!/usr/bin/env python

from kombu.connection import Connection

import ssl


def test_connection():
    conn = Connection('amqp://guest:guest@localhost:5672/')
    conn.connect()
    assert conn.connected
    conn.release()


def test_secure_connection():
    conn = Connection('amqp://guest:guest@localhost:5671/', ssl={
        'ca_certs': 'certs/cacert.pem',
        'keyfile': 'certs/clientkey.pem',
        'certfile': 'certs/clientcert.pem',
        'cert_reqs': ssl.CERT_REQUIRED,
    })
    conn.connect()
    assert conn.connected
    conn.release()
