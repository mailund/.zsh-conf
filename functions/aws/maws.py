import argparse
import os
import subprocess
import sys

try:
    import rich
except ImportError:
    subprocess.run([sys.executable, "-m", "pip", "install", "rich"])
    import rich

from rich import print

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
        print(f"[bright_black]Instance {error} not found :confused:")
    if not success:
        return

    status = aws_cmds.status(list(success.values()))
    for name, state in status.items():
        print(name, state)


def start(args: argparse.Namespace) -> None:
    aws_cmds.start(args.instances)


def stop(args: argparse.Namespace) -> None:
    aws_cmds.stop(args.instances)


if __name__ == "__main__":
    ID2NAME, NAME2ID = get_instance_dicts()

    parser = argparse.ArgumentParser("maws")

    commands = parser.add_subparsers(dest="command")

    status_group = commands.add_parser("status")
    status_group.set_defaults(func=status)
    status_group.add_argument("instances", nargs="*")

    start_group = commands.add_parser("start")
    start_group.set_defaults(func=start)
    start_group.add_argument("instances", nargs="+")

    stop_group = commands.add_parser("stop")
    stop_group.set_defaults(func=stop)
    stop_group.add_argument("instances", nargs="+")

    args = parser.parse_args()
    if not args.command:
        parser.print_help()
        sys.exit(1)
    else:
        args.func(args)
