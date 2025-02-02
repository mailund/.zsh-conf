"""
Wrapper around pydot so I have a typed interface, 
and so I can have a better interface to the stuff
I want to do with dot graphs.
"""

from __future__ import annotations

import re
from typing import Any, Iterator

import pydot  # type: ignore


class Wrap:
    """
    Wraps an untyped object and lets us call methods and access attributes on it.

    It is slightly better than using Any, as Any can be confused with our
    existing types without any type checking errors.
    """

    __pydot: Any

    def __init__(self, pydot: Any) -> None:
        self.__pydot = pydot

    @property
    def wrapped(self) -> Any:
        return self.__pydot

    def __getattribute__(self, name: str) -> Any:
        return getattr(self.__pydot, name)


def _strip_quotes(x: str) -> str:
    x = x.strip()
    return x[1:-1] if x[0] == x[-1] == '"' or x[0] == x[-1] == "'" else x


class NodeLabel:
    __node: Node

    def __init__(self, node: Node) -> None:
        self.__node = node

    def __str__(self) -> str:
        return self.__node.label_string

    def re_sub(self, pattern: str, replacement: str) -> NodeLabel:
        self.__node.label = re.sub(
            pattern,
            replacement,
            str(self),
        )
        return self

    def __bool__(self) -> bool:
        return bool(self.__node.label_string)


class Node:
    __node: Wrap

    def __init__(self, node: Wrap) -> None:
        self.__node = node

    @property
    def name(self) -> str:
        return self.__node.get_name()

    @property
    def label_string(self) -> str:
        return self.__node.get_label() or ""  # None -> "" here

    @property
    def label(self) -> NodeLabel:
        return NodeLabel(self)

    @label.setter
    def label(self, label: str | NodeLabel) -> None:
        self.__node.set_label(str(label))


class LabelIter:
    __labels: list[NodeLabel]

    def __init__(self, labels: list[NodeLabel]) -> None:
        self.__labels = labels

    def re_sub(self, pattern: str, replacement: str) -> LabelIter:
        return LabelIter(
            [label.re_sub(pattern, replacement) for label in self.__labels]
        )

    def strip_prefix(self, prefix: str) -> LabelIter:
        return self.re_sub(rf"^{prefix}", "")

    def __iter__(self) -> Iterator[NodeLabel]:
        return iter(self.__labels)


class NodesIter:
    """
    Returns an iterator over the nodes in the graph.

    The nodes are wrapped in a Node object, which provides a
    typed interface to the node's properties.
    """

    __nodes: list[Node]

    def __init__(self, nodes: list[Node]) -> None:
        self.__nodes = nodes

    def __iter__(self) -> Iterator[Node]:
        return iter(self.__nodes)

    @property
    def labels(self) -> LabelIter:
        return LabelIter([node.label for node in self.__nodes])


class Graph:
    __graph: Wrap

    def __init_labels(self) -> None:
        """
        Set node labels to their name, if there isn't a label already.

        This is necessary to run before we can access labels.

        Labels are by default the node's name, but this isn't reflected
        in the pydot object.
        """
        for node in self.nodes:
            node.label = node.label or _strip_quotes(node.name)

    def __init__(self, dotfile: str) -> None:
        self.__graph = pydot.graph_from_dot_data(dotfile)[0]  # type: ignore
        self.__init_labels()

    @property
    def nodes(self) -> NodesIter:
        """
        Returns an iterator over the nodes in the graph.

        The nodes are wrapped in a Node object, which provides a
        typed interface to the node's properties.
        """
        return NodesIter([Node(node) for node in self.__graph.get_nodes()])

    def node_re_replace(self, pattern: str, replacement: str) -> None:
        self.nodes.labels.re_sub(pattern, replacement)

    def node_strip_prefix(self, prefix: str) -> None:
        self.node_re_replace(rf"^{prefix}", "")

    def set_rankdir(self, rankdir: str) -> None:
        self.__graph.set_rankdir(rankdir)

    def __str__(self) -> str:
        return self.__graph.to_string()  # type: ignore
