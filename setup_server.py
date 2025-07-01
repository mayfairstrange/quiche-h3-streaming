#!/usr/bin/env python3
import subprocess
import re

# ANSI color codes
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
BLUE = "\033[94m"
RESET = "\033[0m"

def ask(prompt, default, suffix, pattern, description):
    while True:
        v = input(f"{BLUE}{prompt} [{default}]: {RESET}").strip() or default

        # If suffix is expected and not provided, append it
        if not v.endswith(suffix) and re.fullmatch(r"\d+(\.\d+)?", v):
            v += suffix

        if re.fullmatch(pattern, v):
            return v

        print(f"{RED}Invalid input: '{v}'. Expected format: {description}{RESET}")

print(f"{YELLOW}Quiche + netem Docker setup\n{RESET}")

rate = ask(
    "Bandwidth (e.g. 1mbit, 500kbit)",
    "30mbit",
    "",
    r"\d+(kbit|mbit|gbit)",
    "e.g. 1mbit, 500kbit, 10gbit"
)

delay = ask(
    "Delay (e.g. 50ms, 100ms)",
    "0ms",
    "ms",
    r"\d+ms",
    "e.g. 50ms, 100ms"
)

jitter = ask(
    "Jitter (e.g. 0ms, 10ms)",
    "0ms",
    "ms",
    r"\d+ms",
    "e.g. 0ms, 10ms"
)

loss = ask(
    "Loss (e.g. 0%, 0.5%, 1%)",
    "0%",
    "%",
    r"\d+(\.\d+)?%",
    "e.g. 0%, 0.5%, 1%"
)

image = "quiche-server"
container = "quiche-server"

print(f"\n{YELLOW}Cleaning up previous container...{RESET}")
subprocess.run(["docker", "rm", "-f", container], stderr=subprocess.DEVNULL)

print(f"\n{YELLOW}Building image...{RESET}")
subprocess.check_call([
    "docker", "build",
    "--target", "quiche-server",
    "-t", image,
    "."
])

print(f"\n{YELLOW}Running container...{RESET}")
subprocess.check_call([
    "docker", "run", "-d",
    "--name", container,
    "--cap-add=NET_ADMIN",
    "-p", "4433:4433/tcp",
    "-p", "4433:4433/udp",
    "-e", f"TC_RATE={rate}",
    "-e", f"TC_DELAY={delay}",
    "-e", f"TC_JITTER={jitter}",
    "-e", f"TC_LOSS={loss}",
    image
])

print(f"\n{GREEN}✓ Server up at https://localhost:4433/test.html{RESET}")
print(f"{GREEN}  ↪ Shaping: {rate} bw, {delay} delay, {jitter} jitter, {loss} loss{RESET}")
