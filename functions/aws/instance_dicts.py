import json
import subprocess
from typing import Any, Iterator, NewType, Optional

__INSTANCE_PATTERN__ = "*Mailund*"

Instance2Name = NewType("Instance2Name", dict[str, str])
Name2Instance = NewType("Name2Instance", dict[str, str])


def _load_instances() -> Iterator[dict[str, Any]]:
    query_result = subprocess.check_output(
        [
            "aws",
            "ec2",
            "describe-instances",
            "--filters",
            f"Name=tag:Name,Values='{__INSTANCE_PATTERN__}'",
            "--output",
            "json",
        ]
    )
    json_query_res = json.loads(query_result)
    for reservation in json_query_res["Reservations"]:
        for instance in reservation["Instances"]:
            yield instance


def _get_name(instance: dict[str, Any]) -> Optional[str]:
    for tag in instance.get("Tags", []):
        if tag["Key"] == "Name":
            return tag["Value"]
    return None


def _instance_id_and_name(instance: dict[str, Any]) -> tuple[str, Optional[str]]:
    instance_id = instance["InstanceId"]
    instance_name = _get_name(instance)
    return instance_id, instance_name


def _map_id_names(
    instances: Iterator[dict[str, Any]]
) -> tuple[Instance2Name, Name2Instance]:

    id2name = {}
    name2id = {}
    for instance in instances:
        instance_id, instance_name = _instance_id_and_name(instance)
        if instance_name is not None:
            id2name[instance_id] = instance_name
            name2id[instance_name] = instance_id
    return id2name, name2id


def get_instance_dicts() -> tuple[Instance2Name, Name2Instance]:
    return _map_id_names(_load_instances())
