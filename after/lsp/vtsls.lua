local vue_language_server_path = "vue-language-server"

local tsserver_filetypes =
	{ "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }

local vue_plugin = {
	name = "@vue/typescript-plugin",
	location = vue_language_server_path,
	languages = { "vue" },
	configNamespace = "typescript",
}

return {
	settings = {
		vtsls = {
			tsserver = {
				globalPlugins = {
					vue_plugin,
				},
			},
		},
		typescript = {
			preferences = {
				importModuleSpecifier = "non-relative",
			},
		},
	},
	filetypes = tsserver_filetypes,
}
