import argparse

from .dot import Graph


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
    graph = Graph(args.dotfile.read())

    # FIXME: make these into options
    graph.node_strip_prefix("//common/kwf/")
    graph.node_re_replace(r"(.*)(/?)([^/:]+):\3$", r"\1\2\3")
    levels = 0
    graph.node_re_replace(
        r"^(([^/]+/){0,levels}[^/]+).*".replace("levels", str(levels)), r"\1"
    )

    graph.set_rankdir("LR")  # type: ignore

    print(graph, file=args.output)


if __name__ == "__main__":
    main()
