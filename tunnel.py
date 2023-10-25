import asyncio, signal, dotenv

secrets = dotenv.dotenv_values(".env")
processes = []

async def manage_process(cmd):
	print("[Executing]", " ".join(cmd))
	process = await asyncio.create_subprocess_exec(
		*cmd,
		stdout=asyncio.subprocess.PIPE,
		stderr=asyncio.subprocess.PIPE
	)
	processes.append(process)

	await process.wait()
	stdout, stderr = await process.communicate()

	print("[Finished]", " ".join(cmd))
	print(f"[STDOUT] {stdout.decode() if stdout else ''}")
	print(f"[STDERR] {stderr.decode() if stderr else ''}")

	return process.returncode

async def shutdown(signal_name):
	print(f"Received {signal_name}, killing processes...")
	for process in processes:
		process.send_signal(signal.SIGINT)

async def main():
	loop = asyncio.get_running_loop()

	for s in [signal.SIGHUP, signal.SIGTERM, signal.SIGINT]:
		loop.add_signal_handler(s, lambda s=s: asyncio.create_task(shutdown(s.name)))

	# Tunnel ports for the minecraft server and the voice chat
	server_loc = f"{secrets['SERVER_USER']}@{secrets['SERVER_IP']}"
	cmds = [
		# Convert port 24454/UDP to port 24455/TCP
		['socat', 'UDP4-LISTEN:24455,reuseaddr,fork', 'TCP4:localhost:24454']
		# Tunnel ports 25565 and 24455 to the server
		['ssh', server_loc, '-nNT', "-R 25565:localhost:25565", "-R 24455:localhost:24455"],
		# On the server, convert port 24455/TCP to port 24454/UDP
		['ssh', server_loc, 'socat', 'TCP4-LISTEN:24455,reuseaddr,fork', 'UDP4:localhost:24454'],
	]

	print("Starting tunnel...")
	await asyncio.gather(*(manage_process(cmd) for cmd in cmds))

asyncio.run(main())
