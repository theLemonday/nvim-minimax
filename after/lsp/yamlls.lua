return require("schema-companion").setup_client(
	require("schema-companion").adapters.yamlls.setup({
		sources = {
			-- your sources for the language server
			require("schema-companion").sources.matchers.kubernetes.setup({ version = "master" }),
			require("schema-companion").sources.lsp.setup(),
			require("schema-companion").sources.schemas.setup({
				{
					name = "Kubernetes master",
					uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/all.json",
				},
			}),
		},
	}),
	{
		settings = {
			yaml = {
				validate = false,
				format = { enable = false },
				schemaStore = {
					-- You must disable built-in schemaStore support if you want to use
					-- this plugin and its advanced options like `ignore`.
					enable = false,
					-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
					url = "",
				},
				schemas = require("schemastore").yaml.schemas(),
			},
		},
	}
)
