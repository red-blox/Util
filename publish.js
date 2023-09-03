import { exec } from 'child_process';
import { promisify } from 'util';
import { readdir } from 'fs';

const preaddir = promisify(readdir);

const execAsync = promisify(exec);

preaddir('./libs').then(async (files) => {
	for (const file of files) {
		await execAsync(`wally publish --project-path ./libs/${file}`).then((res) => {
			console.log(res.stdout);
		});
	}
});
