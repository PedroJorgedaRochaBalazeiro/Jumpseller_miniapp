# 🚀 Quick Start Guide - Backend

## Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- **Ruby 3.2.0+**: `ruby -v`
- **Bundler**: `gem install bundler`
- **PostgreSQL 12+**: `psql --version` (ou SQLite3 para desenvolvimento)
- **Git**: `git --version`

## Setup Rápido (5 minutos)

### Opção 1: Script Automático

```bash
cd backend
chmod +x setup.sh
./setup.sh
```

### Opção 2: Setup Manual

```bash
# 1. Entrar no diretório
cd backend

# 2. Instalar dependências
bundle install

# 3. Configurar variáveis de ambiente
cp .env.example .env
# Editar .env com suas configurações

# 4. Configurar database
# Para PostgreSQL - editar config/database.yml
# Ou manter SQLite3 (padrão para desenvolvimento)

# 5. Criar e configurar banco de dados
rails db:create
rails db:migrate

# 6. (Opcional) Popular com dados de exemplo
rails db:seed

# 7. Iniciar servidor
rails server
```

## ✅ Verificar Instalação

### 1. Health Check

```bash
curl http://localhost:3000/health
```

**Resposta esperada:**
```json
{
  "status": "ok",
  "timestamp": "2024-01-29T10:30:00Z"
}
```

### 2. Testar API

```bash
curl -X POST http://localhost:3000/api/v1/sunrise_sunsets \
  -H "Content-Type: application/json" \
  -d '{
    "location": "Lisbon",
    "start_date": "2024-01-01",
    "end_date": "2024-01-03"
  }'
```

### 3. Executar Testes

```bash
bundle exec rspec
```

**Output esperado:**
```
Finished in X seconds
XX examples, 0 failures
```

## 🔧 Configuração Detalhada

### Database (PostgreSQL)

Se estiver usando PostgreSQL, edite `config/database.yml`:

```yaml
development:
  adapter: postgresql
  encoding: unicode
  database: sunrise_sunset_development
  pool: 5
  username: seu_usuario
  password: sua_senha
  host: localhost
```

### Database (SQLite - Mais Simples)

Para usar SQLite em desenvolvimento, edite o `Gemfile`:

```ruby
# Substituir esta linha:
gem 'pg', '~> 1.5'

# Por esta:
gem 'sqlite3', '~> 1.4'
```

Depois:
```bash
bundle install
rails db:create db:migrate
```

### Variáveis de Ambiente

Edite o arquivo `.env`:

```env
# Email para o serviço de geocoding (Nominatim)
GEOCODER_EMAIL=seu-email@example.com

# Ambiente
RAILS_ENV=development
```

## 📦 Estrutura de Ficheiros Criada

```
backend/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   └── api/v1/
│   │       └── sunrise_sunsets_controller.rb
│   ├── models/
│   │   └── sunrise_sunset_record.rb
│   ├── services/
│   │   ├── geocoding_service.rb
│   │   └── sunrise_sunset_api_service.rb
│   └── serializers/
│       └── sunrise_sunset_serializer.rb
├── config/
│   ├── database.yml
│   ├── routes.rb
│   └── initializers/
│       ├── cors.rb
│       └── geocoder.rb
├── db/
│   ├── migrate/
│   │   └── 20240101000000_create_sunrise_sunset_records.rb
│   └── seeds.rb
├── spec/
│   ├── controllers/
│   ├── models/
│   ├── services/
│   ├── factories/
│   ├── rails_helper.rb
│   └── spec_helper.rb
├── Gemfile
├── README.md
├── .env.example
├── .gitignore
└── setup.sh
```

## 🎯 Endpoints Disponíveis

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/health` | Health check |
| POST | `/api/v1/sunrise_sunsets` | Criar/buscar dados |
| GET | `/api/v1/sunrise_sunsets` | Listar registros |
| GET | `/api/v1/sunrise_sunsets/:id` | Mostrar registro |
| DELETE | `/api/v1/sunrise_sunsets/:id` | Deletar registro |

## 🧪 Executar Testes

```bash
# Todos os testes
bundle exec rspec

# Apenas models
bundle exec rspec spec/models

# Apenas services
bundle exec rspec spec/services

# Apenas controllers
bundle exec rspec spec/controllers

# Com cobertura
COVERAGE=true bundle exec rspec
```

## 🐛 Troubleshooting

### Erro: "Database does not exist"

```bash
rails db:create
```

### Erro: "Pending migrations"

```bash
rails db:migrate
```

### Erro: "LoadError: cannot load such file -- pg"

**Solução 1**: Instalar PostgreSQL
```bash
# Ubuntu/Debian
sudo apt-get install postgresql postgresql-contrib libpq-dev

# Mac
brew install postgresql
```

**Solução 2**: Usar SQLite (mais simples)
```ruby
# No Gemfile, substituir:
gem 'pg' 
# por:
gem 'sqlite3'
```

### Erro: Port 3000 já está em uso

```bash
# Encontrar processo
lsof -ti:3000

# Matar processo
kill -9 $(lsof -ti:3000)

# Ou usar outra porta
rails server -p 3001
```

### Erro: "Geocoder::OverQueryLimitError"

O serviço Nominatim tem limite de 1 req/segundo. O cache deveria prevenir isso, mas se ocorrer:
- Aguarde alguns segundos
- Verifique se o email está configurado no .env

## 📊 Dados de Teste

O arquivo `db/seeds.rb` cria dados de exemplo para:
- **Lisbon, Berlin, Tokyo**
- **Últimos 7 dias**

Para popular:
```bash
rails db:seed
```

Para limpar e repopular:
```bash
rails db:reset
```

## 🔄 Workflow de Desenvolvimento

1. **Fazer mudanças no código**
2. **Executar testes**: `bundle exec rspec`
3. **Testar manualmente**: Use Postman ou curl
4. **Verificar logs**: `tail -f log/development.log`
5. **Commit**: `git add . && git commit -m "sua mensagem"`

## 📝 Comandos Úteis

```bash
# Console do Rails
rails console

# Rotas disponíveis
rails routes

# Status do database
rails db:version

# Reverter última migration
rails db:rollback

# Ver logs em tempo real
tail -f log/development.log

# Limpar cache
rails cache:clear

# Análise de código
bundle exec rubocop
```

## 🎓 Próximos Passos

1. ✅ Backend está rodando
2. → Desenvolver Frontend (React)
3. → Integrar Frontend com Backend
4. → Testar aplicação completa
5. → Criar documentação
6. → Gravar screencast

## 💡 Dicas

- **Sempre execute os testes** antes de fazer commit
- **Use o console do Rails** para testar queries e serviços
- **Monitore os logs** durante desenvolvimento
- **Cache funciona**: Segunda requisição para mesma localização é instantânea
- **API externa é gratuita** mas tem rate limits

## 🆘 Precisa de Ajuda?

- Verifique o `README.md` completo no diretório backend
- Leia os comentários no código
- Execute `rails console` e teste interativamente
- Revise os testes em `spec/` para ver exemplos de uso

## 🎉 Pronto!

Se o health check funcionou, o backend está pronto para uso!

```bash
curl http://localhost:3000/health
# {"status":"ok","timestamp":"..."}
```

Agora você pode:
1. Testar os endpoints com Postman/curl
2. Começar o desenvolvimento do frontend
3. Conectar frontend ao backend

---

**Backend criado com sucesso! 🚀**