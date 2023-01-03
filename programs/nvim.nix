inputs: with inputs;
with utility;
with builtins;
with lib;
free.neovim.override {
	configure = {
		packages.myPlugins = with free.vimPlugins; {
			start = [

				free.lua
				free.nodejs

				vim-nix


				#telescope-asynctasks-nvim
				#telescope-cheat-nvim
				#telescope-coc-nvim
				#telescope-dap-nvim
				#telescope-file-browser-nvim
				#telescope-frecency-nvim
				#telescope-fzf-native-nvim
				#telescope-fzf-writer-nvim
				#telescope-fzy-native-nvim
				#telescope-github-nvim
				#telescope-lsp-handlers-nvim
				telescope-nvim
				#telescope-project-nvim
				#telescope-symbols-nvim
				#telescope-ui-select-nvim
				#telescope-ultisnips-nvim
				#telescope-vim-bookmarks-nvim
				#telescope-z-nvim
				#telescope-zoxide



				FixCursorHold-nvim
				multiple-cursors


#				barbar-nvim
				nvim-web-devicons
#				nvim-tree-lua

				#nvim-code-action-menu
				nvim-lspconfig
				free.haskell-language-server

				#orgmode

				nvim-cmp
				cmp-nvim-lsp
				cmp-treesitter
				cmp-spell
				cmp-emoji
				LanguageTool-nvim
#				free.languagetool

				ultisnips
				vim-snippets

#				free.python38Packages.pylint

				coc-nvim
#				coc-pairs # annoying
#				coc-smartf # annoying
				telescope-coc-nvim
				coc-ultisnips
				coc-snippets # TODO
				coc-lists
#				coc-sources
				coc-prettier
				coc-markdownlint
				coc-java
				coc-python
				coc-json
				coc-fzf
				coc-smartf
				coc-spell-checker
				coc-git
#				coc-explorer


				(nvim-treesitter.withPlugins (plugins:
					free.tree-sitter.allGrammars			# might as well
				))
				nvim-colorizer-lua
			];
			opt = [];
		};
		customRC = (builtins.readFile ../config/.vimrc);
	};
}
