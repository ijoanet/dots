#!/bin/bash

# Language Server Installation Script

set -e

echo "🚀 Installing Language Servers..."

echo "📘 Installing TypeScript Language Server..."
brew install node
curl -fsSL https://bun.sh/install | bash
bun install -g typescript typescript-language-server npm

echo "📝 Installing Bash Language Server..."
bun i -g bash-language-server

echo "🤖 Installing Copilot Language Server..."
bun i -g @github/copilot-language-server

echo "🐳 Installing Docker Language Server..."
go install github.com/docker/docker-language-server/cmd/docker-language-server@latest

echo "🐹 Installing Go Language Servers..."
brew install go
go install golang.org/x/tools/gopls@latest
go install github.com/nametake/golangci-lint-langserver@latest
go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest
go install github.com/rakyll/gotest@latest

echo "🌐 Installing HTML/CSS/JSON Language Server..."
bun i -g vscode-langservers-extracted css-variables-language-server cssmodules-language-server

echo "🌙 Installing Lua Language Servers..."
brew install lua-language-server stylua

echo "🦀 Installing Rust Language Server..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh && rustup component add rust-analyzer rustfmt

echo "🏗️ Installing Terraform Language Servers..."
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
# brew install hashicorp/tap/terraform-ls
brew install terragrunt tflint terraform-lsp

echo "📄 Installing YAML Language Server..."
bun i -g yaml-language-server

echo "⚡ Installing EFM Language Server..."
go install github.com/mattn/efm-langserver@latest

echo "🔧 Installing Basics Language Server..."
bun install -g basics-language-server

echo "✅ All language servers installed successfully!"
