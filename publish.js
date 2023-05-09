import { exec } from 'child_process';
import { promisify } from 'util';
import { readdir } from 'fs/promises';

const execAsync = promisify(exec);

readdir('./libs').then(async (files) => {
	for (const file of files) {
		execAsync(`wally publish --project-path ./libs/${file}`).then((res) => {
			console.log(res.stdout);
		});
	}
});
