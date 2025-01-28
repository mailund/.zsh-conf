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


def instance_status(instance_names: list[str]) -> None:
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
        print("[bright_black]No instances found :confounded_face:")
        return

    status = aws_cmds.status(list(success.values()))
    status_map = {
        "running": "[bold green]running[/bold green] :green_circle:",
        "stopped": "[bright_black]stopped[/bright_black] :red_circle:",
    }
    for name, state in status.items():
        print(f"[underline]{name}:", status_map.get(state, state))


def status(args: argparse.Namespace) -> None:
    instance_names = args.instances or list(NAME2ID.keys())
    instance_status(instance_names)


def start(args: argparse.Namespace) -> None:
    instance_ids = [NAME2ID[name] for name in args.instances]
    print("Starting instances...")
    aws_cmds.start(instance_ids)
    print("...done")
    instance_status(args.instances)


def stop(args: argparse.Namespace) -> None:
    instance_ids = [NAME2ID[name] for name in args.instances]
    print("Stopping instances...")
    aws_cmds.stop(instance_ids)
    print("...done")
    instance_status(args.instances)


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
