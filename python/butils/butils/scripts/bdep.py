import argparse
import subprocess

from moddot import Graph


def collect_tags(tags: list[list[str]]) -> list[str]:
    return [tag for tag_list in tags for tag in tag_list]


def tag_filter(tags: list[str]) -> list[str]:
    return [f"attr(tags, '{'|'.join(tags)}', //...)"] if tags else []


def create_query(target: str, tags: list[str]) -> str:
    queries = [f"deps({target})"]
    queries += tag_filter(tags)
    return f'"{" intersect ".join(queries)}"'


def get_bazel_deps(target: str, tags: list[str]) -> str:
    cmd_args = [
        "bazel",
        "query",
        create_query(target, tags),
        "--noimplicit_deps",
        "--output=graph",
    ]
    cmd = " ".join(cmd_args)
    return subprocess.check_output(cmd, shell=True).decode()


def main() -> None:
    parser = argparse.ArgumentParser("moddot")
    parser.add_argument(
        "target",
        help="The bazel target to get the dependencies for",
        type=str,
    )
    parser.add_argument(
        "-o",
        "--output",
        type=argparse.FileType("w"),
        default="-",
        help="The output file",
    )
    parser.add_argument(
        "-t",
        "--tags",
        type=str,
        action="append",
        help="Tags to filter the dependencies by",
        nargs="*",
    )
    parser.add_argument(
        "-s",
        "--strip-prefix",
        type=str,
        default="",
        help="Strip the given prefix from the node labels",
    )
    parser.add_argument(
        "-r",
        "--rankdir",
        type=str,
        default="LR",
        help="The rankdir to use for the graph",
    )
    parser.add_argument(
        "-l",
        "--levels",
        type=int,
        default=2,
        help="Number of levels to keep in the node labels",
    )

    args = parser.parse_args()

    bazel_deps = get_bazel_deps(
        args.target,
        collect_tags(args.tags),
    )
    graph = Graph(bazel_deps)

    target_prefix = args.target.rsplit("/", 1)[0]
    graph.node_strip_prefix(args.strip_prefix or target_prefix)
    graph.node_re_replace(
        r"(.*)(/?)([^/:]+):\3$",
        r"\1\2\3",
    )
    graph.node_re_replace(  # FIXME: I'm not sure this is working any longer
        r"^(([^/]+/){0,levels}[^/]+).*".replace("levels", str(args.levels)),
        r"\1",
    )

    graph.set_rankdir(args.rankdir)

    print(graph, file=args.output)


if __name__ == "__main__":
    main()
