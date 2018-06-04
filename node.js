let count = 0;

process.stdin.on("data", data => {
  count++;
  process.stdout.write(data);

  if (count >= 5) process.exit(0);
});
