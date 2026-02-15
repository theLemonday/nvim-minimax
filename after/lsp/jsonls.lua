return require("schema-companion").setup_client(
	require("schema-companion").adapters.jsonls.setup({
		sources = {
			require("schema-companion").sources.lsp.setup(),
			require("schema-companion").sources.none.setup(),
		},
	}),
	{
		--- your language server configuration
		settings = {
			json = {
				schemas = require("schemastore").json.schemas(),
				validate = { enable = true },
			},
		},
	}
)
