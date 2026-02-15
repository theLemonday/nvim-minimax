return {
	settings = {
		texlab = {
			forwardSearch = {
				executable = "zathura", -- Match your viewer
				args = { "--synctex-forward", "%l:%c:%f", "%p" }, -- Synctex args for Zathura
			},
			chktex = {
				onEdit = false, -- Enable chktex on edit
				onSave = true, -- Enable chktex on save
			},
			lintOnChange = true, -- Enable linting on change
		},
	},
}
