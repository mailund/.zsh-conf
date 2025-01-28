import argparse
import os
import subprocess
import sys

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import aws_cmds
from instance_dicts import get_instance_dicts
from typedefs import Instance2Name, Name2Instance


def status(args: argparse.Namespace) -> None:
    instance_names = args.instances or list(NAME2ID.keys())
    instances = {name: NAME2ID.get(name, None) for name in instance_names}
    errors = [name for name, instance_id in instances.items() if instance_id is None]
    success = {
        name: instance_id
        for name, instance_id in instances.items()
        if instance_id is not None
    }

    for error in errors:
        print(f"Instance {error} not found")

    status = aws_cmds.status(list(success.values()))
    for name, state in status.items():
        print(name, state)


def start(args: argparse.Namespace) -> None:
    pass


def stop(args: argparse.Namespace) -> None:
    pass


if __name__ == "__main__":
    ID2NAME, NAME2ID = get_instance_dicts()

    parser = argparse.ArgumentParser()
    commands = parser.add_subparsers(dest="command")

    status_group = commands.add_parser("status")
    status_group.set_defaults(func=status)
    status_group.add_argument("instances", nargs="*")

    start_group = commands.add_parser("start")
    start_group.set_defaults(func=start)

    stop_group = commands.add_parser("stop")
    stop_group.set_defaults(func=stop)

    args = parser.parse_args()
    if not args.command:
        parser.print_help()
        sys.exit(1)
    else:
        args.func(args)
