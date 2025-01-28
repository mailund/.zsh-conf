import json
import subprocess


def status(instance_ids: list[str]) -> dict[str, str]:
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
