import json
import pytest
from unittest.mock import patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'functions'))

from get_tasks import lambda_handler

@patch('get_tasks.dynamodb')
def test_get_tasks_returns_user_tasks(mock_dynamodb):
    mock_table = MagicMock()
    mock_dynamodb.Table.return_value = mock_table

    mock_table.scan.return_value = {
        'Items': [
            {'task_id': 'abc-123', 'user_id': 'user-123', 'title': 'Task 1'},
            {'task_id': 'def-456', 'user_id': 'user-123', 'title': 'Task 2'}
        ]
    }

    event = {
        'requestContext': {
            'authorizer': {
                'claims': {'sub': 'user-123'}
            }
        }
    }

    result = lambda_handler(event, None)

    assert result['statusCode'] == 200
    body = json.loads(result['body'])
    assert len(body) == 2

@patch('get_tasks.dynamodb')
def test_get_tasks_empty(mock_dynamodb):
    mock_table = MagicMock()
    mock_dynamodb.Table.return_value = mock_table

    mock_table.scan.return_value = {'Items': []}

    event = {
        'requestContext': {
            'authorizer': {
                'claims': {'sub': 'user-123'}
            }
        }
    }

    result = lambda_handler(event, None)

    assert result['statusCode'] == 200
    body = json.loads(result['body'])
    assert len(body) == 0