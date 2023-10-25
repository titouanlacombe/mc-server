import asyncio, signal, dotenv

secrets = dotenv.dotenv_values(".env")

processes = []

def kill_processes():
	print("Killing processes...")
	for process in processes:
		try:
			process.terminate()
		except ProcessLookupError:
			# Process might have ended, ignore the error
			pass

async def manage_process(cmd):
	process = await asyncio.create_subprocess_exec(
		*cmd,
		stdout=asyncio.subprocess.PIPE,
		stderr=asyncio.subprocess.PIPE
	)
	processes.append(process)

	await process.wait()

	stdout, stderr = await process.communicate()

	if stdout:
		print(f"[stdout]\n{stdout.decode()}")
	if stderr:
		print(f"[stderr]\n{stderr.decode()}")

	return process.returncode

async def shutdown(signal, loop):
	print(f"Received exit signal {signal.name}...")
	tasks = [task for task in asyncio.all_tasks() if task is not asyncio.current_task()]

	for task in tasks:
		task.cancel()

	await asyncio.gather(*tasks, return_exceptions=True)
	loop.stop()

async def main():
	loop = asyncio.get_running_loop()

	signals = (signal.SIGHUP, signal.SIGTERM, signal.SIGINT)
	for s in signals:
		loop.add_signal_handler(
			s, lambda s=s: asyncio.create_task(shutdown(s, loop))
		)

	# Tunnel ports for the minecraft server and the voice chat
	server_loc = f"{secrets['SERVER_USER']}@{secrets['SERVER_IP']}"
	cmds = [
		# Convert voice chat from UDP to TCP
		['socat', 'UDP4-LISTEN:24455,reuseaddr,fork', 'UDP4:localhost:24454'],
		# Tunnel the minecraft server port and the TCP voice chat port
		['ssh', server_loc, '-nNT', "-R 25565:localhost:25565", "-R 24455:localhost:24455"],
		# Convert on the server TCP voice chat back to UDP
		['ssh', server_loc, 'socat UDP4-LISTEN:24455,reuseaddr,fork UDP4:localhost:24454'],
	]

	print("Starting processes...")
	await asyncio.gather(*[manage_process(cmd) for cmd in cmds])

if __name__ == "__main__":
	print("Main start")

	loop = asyncio.get_event_loop()
	try:
		loop.run_until_complete(main())
	finally:
		loop.close()
		kill_processes()
