import argparse
import re
from typing import cast

import pydot


def set_labels_from_names(graph: pydot.Dot) -> None:
    for node in graph.get_node_list():
        node.set_label(node.get_name()[1:-1])


def strip_prefix(graph: pydot.Dot, prefix: str) -> None:
    for node in graph.get_node_list():
        label = node.get_label()
        new_label = label.removeprefix(prefix)
        node.set_label(new_label)


def replace(graph: pydot.Dot, pattern: str, replacement: str) -> None:
    for node in graph.get_node_list():
        label = node.get_label()
        new_label = re.sub(pattern, replacement, label)
        node.set_label(new_label)


def main() -> None:
    parser = argparse.ArgumentParser("moddot")
    parser.add_argument(
        "dotfile",
        type=argparse.FileType("r"),
        default="-",
        help="The dotfile to modify",
        nargs="?",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=argparse.FileType("w"),
        default="-",
        help="The output file",
    )

    args = parser.parse_args()
    graph: pydot.Dot = cast(pydot.Dot, pydot.graph_from_dot_data(args.dotfile.read())[0])  # type: ignore

    set_labels_from_names(graph)  # Must be run before any other node op.

    # FIXME: make these into options
    strip_prefix(graph, "//common/kwf/")
    replace(graph, r"(.*)(/?)([^/:]+):\3$", r"\1\2\3")
    levels = 0
    replace(
        graph, r"^(([^/]+/){0,levels}[^/]+).*".replace("levels", str(levels)), r"\1"
    )

    graph.set_rankdir("LR")  # type: ignore

    print(graph, file=args.output)


if __name__ == "__main__":
    main()
