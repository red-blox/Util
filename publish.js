let exec = require('child_process').exec;
let promisify = require('util').promisify;
let readdir = promisify(require('fs').readdir);

const execAsync = promisify(exec);

readdir('./libs').then(async (files) => {
	for (const file of files) {
		await execAsync(`wally publish --project-path ./libs/${file}`).then((res) => {
			console.log(res.stdout);
		});
	}
});
