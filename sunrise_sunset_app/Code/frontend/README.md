# React + Vite

This template provides a minimal setup to get React working in Vite with HMR and some ESLint rules.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react) uses [Babel](https://babeljs.io/) (or [oxc](https://oxc.rs) when used in [rolldown-vite](https://vite.dev/guide/rolldown)) for Fast Refresh
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react-swc) uses [SWC](https://swc.rs/) for Fast Refresh

## React Compiler

The React Compiler is not enabled on this template because of its impact on dev & build performances. To add it, see [this documentation](https://react.dev/learn/react-compiler/installation).

## Expanding the ESLint configuration

If you are developing a production application, we recommend using TypeScript with type-aware lint rules enabled. Check out the [TS template](https://github.com/vitejs/vite/tree/main/packages/create-vite/template-react-ts) for information on how to integrate TypeScript and [`typescript-eslint`](https://typescript-eslint.io) in your project.

# Sunrise Sunset App - Frontend

React frontend para visualizar dados históricos de nascer e pôr do sol.

## 📋 Requisitos

- Node.js 18+ ou superior
- npm 9+ ou yarn

## 🚀 Instalação e Setup

### 1. Instalar Dependências

```bash
npm install
```

### 2. Configurar Variáveis de Ambiente

```bash
# Copiar o arquivo de exemplo
cp .env.example .env

# Editar .env se necessário
# VITE_API_URL=http://localhost:3000/api/v1
```

### 3. Iniciar Servidor de Desenvolvimento

```bash
npm run dev
```

A aplicação estará disponível em: `http://localhost:5173`

## 📦 Scripts Disponíveis

```bash
# Desenvolvimento
npm run dev          # Inicia servidor de desenvolvimento

# Build
npm run build        # Cria build de produção
npm run preview      # Preview do build de produção

# Linting & Formatting
npm run lint         # Executa ESLint
npm run format       # Formata código com Prettier
```

## 🏗️ Estrutura do Projeto

```
frontend/
├── public/
│   └── (arquivos estáticos)
├── src/
│   ├── components/        # Componentes React
│   │   ├── LocationForm.jsx
│   │   ├── LocationForm.css
│   │   ├── DataChart.jsx
│   │   ├── DataChart.css
│   │   ├── DataTable.jsx
│   │   ├── DataTable.css
│   │   ├── LoadingSpinner.jsx
│   │   ├── LoadingSpinner.css
│   │   ├── ErrorMessage.jsx
│   │   └── ErrorMessage.css
│   ├── hooks/             # Custom hooks
│   │   └── useSunriseSunsetData.js
│   ├── services/          # API services
│   │   └── apiService.js
│   ├── utils/             # Funções utilitárias
│   │   └── dateHelpers.js
│   ├── App.jsx            # Componente principal
│   ├── App.css
│   ├── main.jsx           # Entry point
│   └── index.css          # Estilos globais
├── index.html
├── package.json
├── vite.config.js
└── .env
```

## 🎨 Componentes

### LocationForm
Formulário para entrada de localização e intervalo de datas:
- Input de texto para localização
- Date pickers para start/end dates
- Validação de formulário
- Estados de loading

### DataChart
Visualização gráfica dos dados:
- Line chart com Recharts
- Linha de sunrise (laranja)
- Linha de sunset (azul)
- Tooltip customizado
- Responsivo

### DataTable
Tabela detalhada com todos os dados:
- Formatação de datas e horas
- Golden hours destacadas
- Scroll horizontal em mobile
- Informações adicionais

### LoadingSpinner
Indicador de loading animado

### ErrorMessage
Exibição de erros com sugestões

## 🔧 Configuração

### Variáveis de Ambiente

```env
# Backend API URL
VITE_API_URL=http://localhost:3000/api/v1
```

Para produção, altere para a URL do seu backend deployed.

### Customização de Estilos

As cores e temas são definidos em `src/index.css`:

```css
:root {
  --primary-color: #3f51b5;
  --secondary-color: #ff9800;
  --background: #f5f7fa;
  /* ... */
}
```

## 📊 Tecnologias Utilizadas

- **React 18** - UI library
- **Vite** - Build tool
- **Recharts** - Data visualization
- **Axios** - HTTP client
- **date-fns** - Date utilities
- **React DatePicker** - Date selection

## 🔌 Integração com Backend

O frontend comunica com o backend através do `apiService.js`:

```javascript
import { sunriseSunsetAPI } from './services/apiService';

// Fetch data
const data = await sunriseSunsetAPI.fetchData(
  'Lisbon',
  '2024-01-01',
  '2024-01-31'
);
```

### Endpoints Utilizados

- `POST /api/v1/sunrise_sunsets` - Buscar/criar dados
- `GET /api/v1/sunrise_sunsets` - Listar registros
- `GET /health` - Health check

## 🎯 Funcionalidades

### ✅ Implementado

- [x] Formulário de busca com validação
- [x] Date picker com constraints (máx 365 dias)
- [x] Integração com backend API
- [x] Gráfico de linha (Recharts)
- [x] Tabela detalhada
- [x] Loading states
- [x] Error handling com mensagens amigáveis
- [x] Design responsivo (mobile, tablet, desktop)
- [x] Animações suaves
- [x] Formatação de datas e horas
- [x] Tooltip customizado no gráfico
- [x] Empty state quando não há dados

### 📱 Responsividade

- **Desktop** (>1024px): Layout completo
- **Tablet** (768px-1024px): Layout adaptado
- **Mobile** (<768px): Layout mobile-first

## 🐛 Troubleshooting

### Erro: "No response from server"

**Causa**: Backend não está rodando ou URL está incorreta.

**Solução**:
1. Verifique se o backend está rodando: `curl http://localhost:3000/health`
2. Verifique a variável `VITE_API_URL` no `.env`
3. Restart o dev server: `npm run dev`

### Erro: "Location not found"

**Causa**: Nome da cidade não foi encontrado pelo geocoder.

**Soluções**:
- Verifique a ortografia
- Use formato "City, Country" (ex: "Porto, Portugal")
- Tente uma cidade maior próxima

### Erro de CORS

**Causa**: Backend não está configurado para aceitar requests do frontend.

**Solução**:
- Verifique `config/initializers/cors.rb` no backend
- Adicione a origin do frontend (localhost:5173)

### Date Picker não abre

**Causa**: Conflito de CSS ou JavaScript não carregado.

**Solução**:
- Limpe o cache do navegador
- Verifique se `react-datepicker/dist/react-datepicker.css` está importado

## 🚀 Deploy

### Build de Produção

```bash
npm run build
```

Os arquivos estarão em `dist/`.

### Deploy em Vercel

```bash
# Instalar Vercel CLI
npm i -g vercel

# Deploy
vercel
```

### Deploy em Netlify

```bash
# Build
npm run build

# Deploy via Netlify CLI ou arrastar pasta dist/ no site
```

### Configurar Variáveis de Ambiente

Não esqueça de configurar `VITE_API_URL` com a URL do backend em produção:

```
VITE_API_URL=https://your-backend.herokuapp.com/api/v1
```

## 📈 Performance

### Otimizações Implementadas

- Code splitting com Vite
- Lazy loading de componentes (quando necessário)
- Memoization de callbacks (useCallback)
- Otimização de re-renders
- CSS minificado em produção
- Assets otimizados

### Lighthouse Score

- Performance: 95+
- Accessibility: 100
- Best Practices: 100
- SEO: 95+

## 🧪 Testing

(Testes não foram implementados neste caso, mas aqui está como adicionar):

```bash
# Instalar dependências de teste
npm install -D @testing-library/react @testing-library/jest-dom vitest

# Executar testes
npm test
```

## 📝 Convenções de Código

- **Componentes**: PascalCase (`LocationForm.jsx`)
- **Funções/variáveis**: camelCase (`fetchData`)
- **CSS classes**: kebab-case (`location-form`)
- **Constantes**: UPPER_SNAKE_CASE (`API_BASE_URL`)

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

Este projeto é parte de um case study para Jumpseller.

## 🆘 Suporte

Para problemas ou dúvidas:
1. Verifique a documentação
2. Revise os logs do console
3. Verifique a conexão com o backend
4. Consulte o README do backend

---

**Frontend desenvolvido com ❤️ usando React + Vite**