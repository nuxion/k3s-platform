import argparse
import atexit
import json
import os
import pathlib
import re
import shlex
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime
from enum import Enum, auto
from typing import Optional

LOG_DIR = pathlib.Path("/tmp/gce")
LOG_DIR.mkdir(parents=True, exist_ok=True)


@dataclass
class Machine:
    name: str
    project: str
    machine: str
    disk_size: str
    image: str
    network: str
    tags: str
    zone: str


class Logger:
    STDOUT_LOG = LOG_DIR / "out.log"
    STDOUT_LOG_F = None
    STDERR_LOG = LOG_DIR / "err.log"
    STDERR_LOG_F = None

    @classmethod
    def close_logs(cls):
        if cls.STDOUT_LOG_F:
            cls.STDOUT_LOG_F.close()

        if cls.STDERR_LOG_F:
            cls.STDERR_LOG_F.close()

    @classmethod
    def setup_log_dir(cls):
        """
        Create the LOG_DIR path and STD(OUT|ERR)_LOG files.
        """
        cls.STDOUT_LOG.touch(exist_ok=True)
        cls.STDERR_LOG.touch(exist_ok=True)

        cls.STDOUT_LOG_F = open(cls.STDOUT_LOG, mode="a")
        cls.STDERR_LOG_F = open(cls.STDERR_LOG, mode="a")

        atexit.register(cls.close_logs)

    @classmethod
    def print_out(cls, msg: str, end=os.linesep, print_=True):
        if cls.STDOUT_LOG_F:
            cls.STDOUT_LOG_F.write(msg + end)
            cls.STDOUT_LOG_F.flush()
        if print_:
            print(msg, end=end, file=sys.stdout)

    @classmethod
    def print_err(cls, msg: str, end=os.linesep, print_=True):
        if cls.STDERR_LOG_F:
            cls.STDERR_LOG_F.write(msg + end)
            cls.STDERR_LOG_F.flush()
        if print_:
            print(msg, end=end, file=sys.stderr)


print_out = Logger.print_out
print_err = Logger.print_err


def run(
    command: str, check=True, input=None, cwd=None, silent=False, environment=None
) -> subprocess.CompletedProcess:
    """
    Runs a provided command, streaming its output to the log files.
    :param command: A command to be executed, as a single string.
    :param check: If true, will throw exception on failure (exit code != 0)
    :param input: Input for the executed command.
    :param cwd: Directory in which to execute the command.
    :param silent: If set to True, the output of command won't be logged or printed.
    :param environment: A set of environment variable for the process to use. If None, the current env is inherited.
    :return: CompletedProcess instance - the result of the command execution.
    """
    if not silent:
        log_msg = (
            f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] "
            f"Executing: {command}" + os.linesep
        )
        print_out(log_msg)
        print_err(log_msg, print_=False)

    proc = subprocess.run(
        shlex.split(command),
        check=check,
        stderr=subprocess.PIPE,
        stdout=subprocess.PIPE,
        input=input,
        cwd=cwd,
        env=environment,
    )

    if not silent:
        print_err(proc.stderr.decode())
        print_out(proc.stdout.decode())

    return proc


def check_python_version():
    """
    Makes sure that the script is run with Python 3.6 or newer.
    """
    if sys.version_info.major == 3 and sys.version_info.minor >= 6:
        return
    version = "{}.{}".format(sys.version_info.major, sys.version_info.minor)
    raise RuntimeError(
        "Unsupported Python version {}. "
        "Supported versions: 3.6 - 3.10".format(version)
    )


def create_instance(m: Machine):

    CMD_CREATE = (
        f"gcloud compute instances create {m.name} --project={m.project} "
        f"--zone={m.zone} "
        f"--machine-type={m.machine} "
        f"--network-interface=network-tier=PREMIUM,subnet={m.network} "
        f"--maintenance-policy=MIGRATE --provisioning-model=STANDARD "
        f"--create-disk=auto-delete=yes,boot=yes,device-name={m.name},image={m.image},mode=rw,size={ m.disk_size },type=projects/{m.project}/zones/{m.zone}/diskTypes/pd-balanced "
        f" --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring "
        " --reservation-affinity=any "
        f"--tags {m.tags}")
    run(CMD_CREATE, check=True)


def parse_args():
    """
    MIRROR = os.getenv("LF_MIRROR")  # with protocol
    REGISTRY = os.getenv("LF_REGISTRY")  # without protocol
    INSECURE = os.getenv("LF_INSECURE")  # yes or empty
    IMAGE = os.getenv("LF_DOCKER_IMG")  # fullname: nuxion/labfunctions
    VERSION = os.getenv("LF_DOCKER_VER")  # version
    """

    parser = argparse.ArgumentParser(description="Manage gce instance")
    parser.add_argument("action", choices=[
                        "create"], default="install", nargs="?")
    parser.add_argument("--name", help="Machine name")
    parser.add_argument("--machine", default="e2-small", help="Machine type")
    parser.add_argument("--project", default="algorinfo99", help="GCE Project")
    parser.add_argument("--disk-size", default="10",
                        help="Boot disk size in GB")
    parser.add_argument("--tags", help="comma separated tags")
    parser.add_argument("--network", default="default", help="network")
    parser.add_argument("--zone", default="us-central1-a" , help="network")
    parser.add_argument("--image", default="projects/debian-cloud/global/images/debian-11-bullseye-v20220719",
            help="Find one using gcloud compute images list --uri",
                        )
    args = parser.parse_args()
    machine = Machine(
        name=args.name,
        machine=args.machine,
        image=args.image,
        project=args.project,
        disk_size=args.disk_size,
        tags=args.tags,
        network=args.network,
        zone=args.zone,
    )

    return args


def main():
    Logger.setup_log_dir()
    check_python_version()
    args = parse_args()
    if args.action == "create":
        create_instance(args)


if __name__ == "__main__":
    main()
