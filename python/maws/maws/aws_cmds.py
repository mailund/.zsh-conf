import json
import subprocess
from typing import Any, Iterator, NewType, Optional

InstanceName = NewType("InstanceName", str)
InstanceId = NewType("InstanceId", str)
Instance2Name = NewType("Instance2Name", dict[InstanceId, InstanceName])
Name2Instance = NewType("Name2Instance", dict[InstanceName, InstanceId])


def _load_instances() -> Iterator[dict[str, Any]]:
    query_result = subprocess.check_output(
        [
            "aws",
            "ec2",
            "describe-instances",
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


class AwsCmds:
    name2id: Name2Instance
    id2name: Instance2Name

    def __init__(self):
        self.name2id = Name2Instance({})
        self.id2name = Instance2Name({})

        instances = _load_instances()
        for instance in instances:
            instance_id, instance_name = _instance_id_and_name(instance)
            if instance_name is not None and "mailund" in instance_name.lower():
                self.id2name[InstanceId(instance_id)] = InstanceName(instance_name)
                self.name2id[InstanceName(instance_name)] = InstanceId(instance_id)

    def instances(
        self, names: list[InstanceName] | None = None
    ) -> dict[InstanceName, InstanceId | None]:
        names = names or list(self.name2id.keys())
        map = {
            name: None if name not in self.name2id else self.name2id[name]
            for name in names
        }
        print("map", map)
        return map

    def status(self, names: list[InstanceName] | None) -> dict[str, str]:
        names = names or list(self.name2id.keys())
        print("names", names)
        instance_ids = [
            instance_id
            for instance_id in self.instances(names).values()
            if instance_id is not None
        ]
        print(instance_ids)
        query_result = subprocess.check_output(
            [
                "aws",
                "ec2",
                "describe-instances",
                "--query",
                "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value | [0], InstanceId, State.Name]",
                "--output",
                "text",
                "--instance-ids",
                *instance_ids,
            ]
        )
        result_lines = query_result.decode("utf-8").strip().split("\n")
        result_parsed = [line.split("\t") for line in result_lines]
        return {name: state for name, _, state in result_parsed}

    def start(self, names: list[InstanceName]):
        instance_ids = [self.name2id[name] for name in names]
        subprocess.run(
            ["aws", "ec2", "start-instances", "--instance-ids", *instance_ids]
        )

    def stop(self, names: list[InstanceName]):
        instance_ids = [self.name2id[name] for name in names]
        subprocess.run(
            ["aws", "ec2", "stop-instances", "--instance-ids", *instance_ids]
        )
