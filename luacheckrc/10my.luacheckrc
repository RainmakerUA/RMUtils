
-- custom settings go here
std = "lua51+wow8+wow8ext+addonlibs"

codes = true

quiet = 1

-- exclude files
exclude_files = {}

-- ignores
ignore = {
	-- ignore unused 'self' argument
	"212/self",
}

-- ignore long line warning for localization
files["**/Locales/*.lua"].ignore = { "631" }
