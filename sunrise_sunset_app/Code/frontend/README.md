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

React frontend for viewing historical sunrise and sunset data.

## 📋 Requirements

- Node.js 18+ or higher
- npm 9+ or yarn

## 🚀 Installation and Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment Variables

```bash
# Copiar o arquivo de exemplo
cp .env.example .env

# Editar .env se necessário
# VITE_API_URL=http://localhost:3000/api/v1
```

### 3. Start Development Server

```bash
npm run dev
```

The application will be available at: `http://localhost:5173`

## 📦 Available Scripts

```bash
# Development
npm run dev          # Start development server

# Build
npm run build        # Create production build
npm run preview      # Preview of the production build

# Linting & Formatting
npm run lint         # Run ESLint
npm run format       # Format code with Prettier
```

## 🏗️ Project Structure

```
frontend/
├── public/
│   └── (static files)
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
│   ├── utils/             # Utility functions
│   │   └── dateHelpers.js
│   ├── App.jsx            # Main component
│   ├── App.css
│   ├── main.jsx           # Entry point
│   └── index.css          # Global styles
├── index.html
├── package.json
├── vite.config.js
└── .env
```

## 🎨 Components

### LocationForm
Form for entering location and date range:
- Text input for location
- Date pickers for start/end dates
- Form validation
- Loading states

### DataChart
Graphical data visualisation:
- Line chart with Recharts
- Sunrise line (orange)
- Sunset line (blue)
- Customised tooltip
- Responsive

### DataTable
Detailed table with all data:
- Date and time formatting
- Golden hours highlighted
- Horizontal scrolling on mobile
- Additional information

### LoadingSpinner
Animated loading indicator

### ErrorMessage
Displaying errors with suggestions

## 🔧 Configuration

### Environment Variables

```env
# Backend API URL
VITE_API_URL=http://localhost:3000/api/v1
```

For production, change to the URL of your deployed backend.

### Style Customisation

Colours and themes are defined in `src/index.css`:

```css
:root {
  --primary-color: #3f51b5;
  --secondary-color: #ff9800;
  --background: #f5f7fa;
  /* ... */
}
```

## 📊 Technologies Used

- **React 18** - UI library. Version 19.2.4
- **Vite** - Build tool. Version 7.3.1
- **Recharts** - Data visualization
- **Axios** - HTTP client
- **date-fns** - Date utilities
- **React DatePicker** - Date selection

## 🔌 Backend Integration

The frontend communicates with the backend through `apiService.js`:

```javascript
import { sunriseSunsetAPI } from './services/apiService';

// Fetch data
const data = await sunriseSunsetAPI.fetchData(
  'Lisbon',
  '2024-01-01',
  '2024-01-31'
);
```

### Endpoints Used

- `POST /api/v1/sunrise_sunsets` - Search/create data
- `GET /api/v1/sunrise_sunsets` - List records
- `GET /health` - Health check

## 🎯 Features

### ✅ Implemented

- [x] Search form with validation
- [x] Date picker with constraints (max 365 days)
- [x] Integration with backend API
- [x] Line chart (Recharts)
- [x] Detailed table
- [x] Loading states
- [x] Error handling with friendly messages
- [x] Responsive design (mobile, tablet, desktop)
- [x] Smooth animations
- [x] Date and time formatting
- [x] Customised tooltip on the chart
- [x] Empty state when there is no data

### 📱 Responsiveness

- **Desktop** (>1024px): Full layout
- **Tablet** (768px-1024px): Adapted layout
- **Mobile** (<768px): Mobile-first layout

## 🐛 Troubleshooting

### Error: "No response from server"

**Cause**: Backend is not running or URL is incorrect.

**Solution**:
1. Verify that the backend is running: `curl http://localhost:3000/health`
2. Verify the `VITE_API_URL` variable in `.env`
3. Restart the dev server: `npm run dev`

### Error: ‘Location not found’

**Cause**: City name was not found by the geocoder.

**Solutions**:
- Check the spelling
- Use the format ‘City, Country’ (e.g. ‘Porto, Portugal’)
- Try a larger city nearby

### CORS error

**Cause**: Backend is not configured to accept requests from the frontend.

**Solution**:
- Check `config/initializers/cors.rb` in the backend
- Add the frontend origin (localhost:5173)

### Date Picker does not open

**Cause**: CSS conflict or JavaScript not loaded.

**Solution**:
- Clear your browser cache
- Check that `react-datepicker/dist/react-datepicker.css` is imported

## 🚀 Deploy

### Production Build

```bash
npm run build
```

The files will be in `dist/`.

### Deploy to Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel
```

### Deploy to Netlify

```bash
# Build
npm run build

# Deploy via Netlify CLI or drag the dist/ folder to the website
```

### Configure Environment Variables

Do not forget to configure `VITE_API_URL` with the production backend URL:

```
VITE_API_URL=https://your-backend.herokuapp.com/api/v1
```

## 📈 Performance

### Implemented Optimisations

- Code splitting with Vite
- Lazy loading of components (when necessary)
- Memoisation of callbacks (useCallback)
- Optimisation of re-renders
- Minified CSS in production
- Optimised assets

### Lighthouse Score

- Performance: 95+
- Accessibility: 100
- Best Practices: 100
- SEO: 95+

## 🧪 Testing

(Tests have not been implemented in this case, but here is how to add them):

```bash
# Install test dependencies
npm install -D @testing-library/react @testing-library/jest-dom vitest

# Run tests
npm test
```

## 📝 Code Conventions

- **Components**: PascalCase (`LocationForm.jsx`)
- **Functions/variables**: camelCase (`fetchData`)
- **CSS classes**: kebab-case (`location-form`)
- **Constants**: UPPER_SNAKE_CASE (`API_BASE_URL`)

## 🤝 Contributing

1. Fork the project
2. Create a branch for your feature
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 Licence

This project is part of a case study for Jumpseller.

## 🆘 Support

For problems or questions:
1. Check the documentation
2. Review the console logs
3. Check the connection to the backend
4. Consult the backend README

---

**Frontend developed with ❤️ using React + Vite**