import { defineConfig } from 'vitepress'

function sidebar() {
	return [
		{ text: 'Bin', link: '/bin' },
		{ text: 'Clock', link: '/clock' },
		{ text: 'Collection', link: '/collection' },
		{ text: 'Fetch', link: '/fetch' },
		{ text: 'Promise', link: '/promise' },
		{ text: 'Ratelimit', link: '/ratelimit' },
		{ text: 'Signal', link: '/signal' },
		{ text: 'Spawn', link: '/spawn' },
	]
}

export default defineConfig({
	title: 'Redblox Util',
	description: 'A collection of small utilities for Roblox.',
	lang: 'en-US',
	head: [
		//['link', { rel: 'icon', href: '/favicon.png' }],
	],

	themeConfig: {
		//logo: '/logo.png',
		//siteTitle: false,
		outline: 'deep',

		socialLinks: [
			{ icon: 'github', link: 'https://github.com/red-blox/util' },
			{ icon: 'discord', link: 'https://discord.gg/mchCdAFPWU' },
		],

		sidebar: sidebar(),
	}
})
