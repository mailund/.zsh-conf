import argparse
import sys

from rich import print
from rich.table import Table

from .aws_cmds import AwsCmds, InstanceName

cmds = AwsCmds()


def instance_status(instance_names: list[InstanceName] | None) -> None:
    instances = cmds.instances(instance_names)
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

    status = cmds.status(list(success.keys()))
    status_map = {
        "running": "[bold green]running[/bold green]",
        "stopped": "[red]stopped[/red]",
    }
    status_icon = {
        "running": ":green_circle:",
        "stopped": ":red_circle:",
    }

    table = Table(title="Instance status", min_width=80)
    table.add_column()
    table.add_column("Name", justify="left", no_wrap=True)
    table.add_column("Status", style="magenta", justify="left")
    for name, state in status.items():
        table.add_row(status_icon.get(state, ""), name, status_map.get(state, state))
    print(table)


def status(args: argparse.Namespace) -> None:
    instance_status(args.instances or None)


def start(args: argparse.Namespace) -> None:
    print("Starting instances...")
    cmds.start(args.instances)
    print("...done")
    instance_status(args.instances)


def stop(args: argparse.Namespace) -> None:
    print("Stopping instances...")
    cmds.stop(args.instances)
    print("...done")
    instance_status(args.instances)


def main():

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


if __name__ == "__main__":
    main()
