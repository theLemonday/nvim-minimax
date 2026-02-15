return {
	root_markers = { ".venv", "requirements.txt" },
	settings = {
		pylsp = {
			plugins = {
				pyflakes = { enabled = false },
				pycodestyle = { enabled = false },
				autopep8 = { enabled = false },
				yapf = { enabled = false },
				mccabe = { enabled = false },
				pylsp_mypy = { enabled = false },
				pylsp_black = { enabled = false },
				pylsp_isort = { enabled = false },
				rope_autoimport = { enabled = true },
				ruff = { enabled = true, formatEnabled = true },
			},
		},
	},
}
