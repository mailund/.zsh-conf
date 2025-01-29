import json
import subprocess

from .instance_dicts import get_instance_dicts
from .typedefs import Instance2Name, Name2Instance


class AwsCmds:
    name2id: Name2Instance
    id2name: Instance2Name

    def __init__(self):
        self.id2name, self.name2id = get_instance_dicts()

    def instances(self, names: list[str] | None) -> dict[str, str | None]:
        names = names or list(self.name2id.keys())
        return {name: self.name2id.get(name, None) for name in names}

    def status(self, names: list[str] | None) -> dict[str, str]:
        names = names or list(self.name2id.keys())
        instance_ids = [
            instance_id
            for instance_id in self.instances(names).values()
            if instance_id is not None
        ]
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

    def start(self, names: list[str]):
        instance_ids = [NAME2ID[name] for name in names]
        subprocess.run(
            ["aws", "ec2", "start-instances", "--instance-ids", *instance_ids]
        )

    def stop(self, names: list[str]):
        instance_ids = [NAME2ID[name] for name in names]
        subprocess.run(
            ["aws", "ec2", "stop-instances", "--instance-ids", *instance_ids]
        )
