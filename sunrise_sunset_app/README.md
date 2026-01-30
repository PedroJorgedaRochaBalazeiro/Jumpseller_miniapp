# 🌅 Sunrise Sunset App

Aplicação full-stack para consultar e visualizar dados históricos de nascer e pôr do sol para diferentes localizações, utilizando a API SunriseSunset.io.

## 📋 Índice

- [Sobre o Projeto](#sobre-o-projeto)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Características](#características)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Instalação e Configuração](#instalação-e-configuração)
- [Como Usar](#como-usar)
- [API Endpoints](#api-endpoints)
- [Testes](#testes)
- [Decisões de Design](#decisões-de-design)
- [Melhorias Futuras](#melhorias-futuras)

## 🎯 Sobre o Projeto

Este projeto foi desenvolvido como um case study para demonstrar habilidades em desenvolvimento full-stack, integrando:

- **Backend**: Ruby on Rails API para gerenciar dados e comunicação com API externa
- **Frontend**: React para interface de usuário interativa
- **External API**: SunriseSunset.io para obter dados astronômicos

### Funcionalidades Principais:

1. ✅ Busca de dados de nascer/pôr do sol por localização e intervalo de datas
2. ✅ Cache inteligente em database para evitar chamadas desnecessárias à API
3. ✅ Geocoding automático de nomes de cidades
4. ✅ Visualização em gráficos (charts) e tabelas
5. ✅ Tratamento robusto de erros (localizações inválidas, regiões polares, etc)
6. ✅ Testes automatizados

## 🚀 Tecnologias Utilizadas

### Backend
- **Ruby** 3.2+
- **Ruby on Rails** 7.1+ (API mode)
- **PostgreSQL** (Database)
- **HTTParty** (HTTP client)
- **Geocoder** (Geocoding service)
- **RSpec** (Testing)

### Frontend
- **React** 18+
- **Axios** (HTTP client)
- **Recharts** (Data visualization)
- **React DatePicker** (Date selection)
- **date-fns** (Date utilities)

### APIs Externas
- [SunriseSunset.io API](https://sunrisesunset.io/api/) - Dados de nascer/pôr do sol
- Nominatim (OpenStreetMap) - Geocoding

## ✨ Características

### Otimizações Implementadas:

1. **Database Caching**: Dados já consultados são armazenados localmente
2. **Batch Requests**: Uma única chamada para múltiplas datas (até 365 dias)
3. **Geocoding Cache**: Coordenadas de localizações são cacheadas
4. **Smart Data Fetching**: Busca apenas os dados que não existem no cache

### Tratamento de Casos Especiais:

- ❄️ **Regiões Polares**: Dias em que o sol não nasce ou não se põe
- 🗺️ **Localizações Inválidas**: Feedback claro quando cidade não é encontrada
- 📅 **Validação de Datas**: Verifica ranges e formatos inválidos
- 🔄 **API Failures**: Retry logic e mensagens de erro descritivas

## 📁 Estrutura do Projeto

```
sunrise-sunset-app/
├── backend/                 # Ruby on Rails API
│   ├── app/
│   │   ├── controllers/    # API controllers
│   │   ├── models/         # Database models
│   │   ├── services/       # Business logic
│   │   └── serializers/    # JSON serializers
│   ├── config/             # Rails configuration
│   ├── db/                 # Database migrations
│   └── spec/               # RSpec tests
│
├── frontend/               # React Application
│   ├── src/
│   │   ├── components/    # React components
│   │   ├── services/      # API service
│   │   └── utils/         # Helper functions
│   └── public/
│
└── docs/                  # Documentation
    ├── PROJECT_STRUCTURE.md
    ├── REQUIREMENTS_GUIDE.md
    └── API_DOCUMENTATION.md
```

## 🛠️ Instalação e Configuração

### Pré-requisitos

- Ruby 3.2+ e Rails 7.1+
- Node.js 18+ e npm
- PostgreSQL (ou SQLite para desenvolvimento)
- Git

### 1. Clone o Repositório

```bash
git clone https://github.com/seu-usuario/sunrise-sunset-app.git
cd sunrise-sunset-app
```

### 2. Setup Backend

```bash
cd backend

# Instalar dependências
bundle install

# Configurar database
cp config/database.yml.example config/database.yml
# Editar config/database.yml com suas credenciais

# Criar e configurar banco de dados
rails db:create
rails db:migrate

# (Opcional) Popular com dados de exemplo
rails db:seed

# Iniciar servidor (porta 3000)
rails server
```

**Configuração de Ambiente (backend/.env):**

```env
DATABASE_URL=postgresql://user:password@localhost/sunrise_db
RAILS_ENV=development
GEOCODER_EMAIL=your-email@example.com
```

### 3. Setup Frontend

```bash
cd ../frontend

# Instalar dependências
npm install

# Configurar variáveis de ambiente
cp .env.example .env
# VITE_API_URL=http://localhost:3000/api/v1

# Iniciar servidor de desenvolvimento (porta 5173 ou 3001)
npm run dev
```

### 4. Verificar Instalação

- Backend: http://localhost:3000/health
- Frontend: http://localhost:5173 (ou porta indicada)

## 💻 Como Usar

### Interface Web:

1. **Digite uma Localização**: Ex: "Lisbon", "Berlin", "Tokyo"
2. **Selecione Intervalo de Datas**: Data inicial e final (máx. 365 dias)
3. **Clique em "Get Sunrise & Sunset Data"**
4. **Visualize os Resultados**:
   - Gráfico de linha mostrando evolução ao longo do tempo
   - Tabela detalhada com todos os dados

### Exemplo de Uso via cURL:

```bash
curl -X POST http://localhost:3000/api/v1/sunrise_sunsets \
  -H "Content-Type: application/json" \
  -d '{
    "location": "Lisbon",
    "start_date": "2024-01-01",
    "end_date": "2024-01-31"
  }'
```

## 📡 API Endpoints

### POST /api/v1/sunrise_sunsets

Busca ou cria registros de nascer/pôr do sol para uma localização e range de datas.

**Request Body:**
```json
{
  "location": "Lisbon",
  "start_date": "2024-01-01",
  "end_date": "2024-01-31"
}
```

**Response (200 OK):**
```json
{
  "data": [
    {
      "id": "1",
      "type": "sunrise_sunset_record",
      "attributes": {
        "location": "Lisbon",
        "date": "2024-01-01",
        "sunrise": "7:45:23 AM",
        "sunset": "5:30:15 PM",
        "golden_hour": "6:15:00 AM",
        "golden_hour_end": "6:15:00 PM",
        "day_length": "09:44:52",
        "solar_noon": "12:37:49 PM"
      }
    }
  ]
}
```

**Error Responses:**

- `400 Bad Request`: Parâmetros faltando ou inválidos
- `422 Unprocessable Entity`: Localização não encontrada
- `502 Bad Gateway`: Falha na API externa

### GET /api/v1/sunrise_sunsets

Lista registros existentes (com filtros opcionais).

**Query Parameters:**
- `location` (string, opcional)
- `start_date` (date, opcional)
- `end_date` (date, opcional)

## 🧪 Testes

### Backend Tests (RSpec)

```bash
cd backend

# Rodar todos os testes
bundle exec rspec

# Rodar testes específicos
bundle exec rspec spec/models/sunrise_sunset_record_spec.rb
bundle exec rspec spec/services/

# Com cobertura de código
COVERAGE=true bundle exec rspec
```

**Cobertura de Testes:**
- Models: Validações, scopes, métodos
- Services: Integração com APIs externas (com WebMock)
- Controllers: Request specs para todos endpoints
- Edge cases: Regiões polares, erros de API, validações

### Frontend Tests

```bash
cd frontend

# Rodar testes
npm test

# Com cobertura
npm test -- --coverage
```

## 🎨 Decisões de Design

### Backend:

1. **Rails API Mode**: Mais leve, focado em JSON API
2. **Service Objects**: Lógica de negócio separada dos controllers
3. **Database Caching**: Evita custos e latência de API externa
4. **Geocoding Local**: Usa Nominatim (grátis) em vez de Google Maps API
5. **JSONAPI Serializer**: Formato consistente de resposta

### Frontend:

1. **Recharts**: Biblioteca declarativa e React-friendly para gráficos
2. **Axios**: Cliente HTTP mais robusto que fetch
3. **date-fns**: Mais leve que Moment.js
4. **Component Composition**: Componentes pequenos e reutilizáveis

### Database Schema:

- Índices compostos para queries otimizadas
- Armazenamento de strings para times (flexibilidade com formatos)
- Campo `status` para casos especiais (polar night, etc)

## 🔮 Melhorias Futuras

### Curto Prazo:
- [ ] Adicionar testes E2E (Cypress)
- [ ] Implementar dark mode
- [ ] Export para CSV/PDF
- [ ] Comparação lado-a-lado de localizações

### Médio Prazo:
- [ ] Background jobs com Sidekiq para fetching assíncrono
- [ ] WebSockets para updates em tempo real
- [ ] Cache com Redis
- [ ] Rate limiting no backend

### Longo Prazo:
- [ ] Sistema de autenticação de usuários
- [ ] Favoritos e histórico de pesquisas
- [ ] Notificações de golden hour
- [ ] Mobile app (React Native)

## 📝 Documentação Adicional

- [Estrutura Detalhada do Projeto](./PROJECT_STRUCTURE.md)
- [Guia Completo de Requisitos](./REQUIREMENTS_GUIDE.md)
- [Documentação da API](./docs/API_DOCUMENTATION.md)

## 🤝 Contribuições

Este é um projeto de demonstração, mas contribuições são bem-vindas!

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto é livre para uso educacional e demonstração.

## 👤 Autor

Desenvolvido como case study para Jumpseller

## 🙏 Agradecimentos

- [SunriseSunset.io](https://sunrisesunset.io) pela API gratuita
- [Nominatim/OpenStreetMap](https://nominatim.org) pelo serviço de geocoding
- Comunidades Ruby on Rails e React

---

**⚡ Quick Start:**

```bash
# Backend
cd backend && bundle install && rails db:setup && rails server

# Frontend (nova janela)
cd frontend && npm install && npm run dev
```

Acesse: http://localhost:5173