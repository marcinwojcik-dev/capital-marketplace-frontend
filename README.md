# Capital Marketplace Frontend

A modern, responsive Next.js application for founders to onboard their companies, manage documents, and track their investability score in a capital marketplace platform.

## 🚀 Features

### Core Functionality
- **Onboarding Wizard**: Multi-step company registration with validation
- **Dashboard**: Company profile overview with status badges and investability scoring
- **Data Room**: Secure document upload and management (PDF, PPTX, XLSX)
- **Scheduling Integration**: Embedded Cal.com booking interface
- **Real-time Notifications**: In-app notification system
- **Responsive Design**: Mobile-first approach with Material-UI components

### Technical Highlights
- **Next.js 14** with App Router and TypeScript
- **Material-UI (MUI)** for consistent, accessible design
- **React Hook Form** with Zod validation
- **Axios** for API communication with interceptors
- **File Upload** with drag-and-drop support
- **Session-based Authentication** with context management

## 🛠️ Tech Stack

- **Framework**: Next.js 15.5.3
- **Language**: TypeScript 5
- **UI Library**: Material-UI 7.3.2
- **Form Management**: React Hook Form 7.62.0 + Zod 4.1.9
- **HTTP Client**: Axios 1.12.2
- **File Handling**: React Dropzone 14.3.8
- **Notifications**: Knock Labs React 0.8.5
- **Styling**: Emotion (CSS-in-JS)

## 📋 Prerequisites

- **Node.js**: 18.x or higher
- **npm**: 9.x or higher
- **Backend API**: Capital Marketplace Backend running on configured endpoint

## 🌐 Live Demo
**Live Application**: [https://capital-marketplace-frontend.vercel.app](https://capital-marketplace-frontend.vercel.app)

*Experience the full onboarding flow, dashboard, and document management features in action.*

## 🚀 Quick Start

### 1. Clone and Install
```bash
git clone <repository-url>
cd capital-marketplace-frontend
npm install
```

### 2. Environment Setup
Create a `.env.local` file in the root directory:

```env
# API Configuration
NEXT_PUBLIC_API_ENDPOINT=http://localhost:3001

# Cal.com Integration (Optional)
NEXT_PUBLIC_CAL_COM_BOOKING_URL=https://cal.com/your-username

# Development Settings
NODE_ENV=development
```

### 3. Start Development Server
```bash
npm run dev
```

The application will be available at `http://localhost:3000`

### 4. Build for Production
```bash
npm run build
npm start
```

## 📁 Project Structure

```
src/
├── app/                    # Next.js App Router pages
│   ├── (founder)/         # Protected founder routes
│   │   ├── dashboard/     # Main dashboard
│   │   └── onboarding/   # Company onboarding wizard
│   ├── auth/             # Authentication pages
│   │   ├── login/        # Login page
│   │   └── register/     # Registration page
│   └── layout.tsx        # Root layout with providers
├── components/           # Reusable UI components
│   ├── layouts/          # Layout components
│   ├── ui/              # Generic UI components
│   └── views/           # Page-specific components
│       ├── companyTabs/ # Dashboard tab components
│       ├── inputFields/ # Form input components
│       └── onboardingForms/ # Onboarding step forms
├── contexts/            # React contexts
│   └── AuthContext.tsx  # Authentication state management
├── lib/                 # Utility libraries
│   ├── axios.ts        # HTTP client configuration
│   └── theme.ts        # Material-UI theme
└── middleware.ts        # Next.js middleware for routing
```

## 🔧 Configuration

### API Integration
The frontend communicates with the backend API through a configured Axios instance:

```typescript
// src/lib/axios.ts
const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_ENDPOINT,
  headers: {
    'Content-Type': 'application/json',
  },
});
```

### Authentication Flow
- Session-based authentication using `sessionStorage`
- Automatic token injection via Axios interceptors
- Protected routes with middleware
- Context-based user state management

### File Upload Configuration
- **Supported formats**: PDF, PPTX, XLSX
- **Maximum file size**: 10MB per file
- **Maximum files**: 5 files per upload
- **Storage**: Local file system (configurable)

## 🎨 UI/UX Features

### Design System
- **Material Design 3** principles
- **Responsive breakpoints** for mobile, tablet, and desktop
- **Accessibility** compliance with ARIA labels
- **Loading states** and error handling
- **Empty states** for better user experience

### Component Library
- **StringAvatar**: Dynamic avatar generation from company names
- **TabPanel**: Accessible tab panel implementation
- **FileDropzone**: Drag-and-drop file upload with validation
- **Form Components**: Validated input fields with error states

## 🔒 Security Features

- **File Type Validation**: Only allowed document types
- **File Size Limits**: Prevents large file uploads
- **CORS Configuration**: Proper cross-origin setup
- **Input Sanitization**: Zod schema validation
- **Session Management**: Secure token handling

## 🐳 Docker Deployment

### Development
```bash
docker-compose -f docker-compose.dev.yml up
```

### Production
```bash
docker-compose -f docker-compose.prod.yml up -d
```

See [Docker Deployment Guide](./docs/DOCKER_DEPLOYMENT.md) for detailed instructions.

## 🧪 Testing

```bash
# Run linting
npm run lint

# Type checking (built into Next.js)
npm run build
```

## 📊 Performance Optimizations

- **Next.js Standalone Output**: Optimized Docker builds
- **Code Splitting**: Automatic route-based splitting
- **Image Optimization**: Next.js Image component
- **Bundle Analysis**: Built-in webpack bundle analyzer
- **Caching**: Strategic use of React.memo and useMemo

## 🔄 State Management

### Authentication State
- **Context Provider**: Global auth state
- **Session Persistence**: Browser sessionStorage
- **Automatic Refresh**: Token validation on app load

### Form State
- **React Hook Form**: Efficient form management
- **Zod Validation**: Type-safe validation schemas
- **Error Handling**: User-friendly error messages

## 🌐 API Endpoints Integration

The frontend integrates with the following backend endpoints:

- `POST /api/company` - Company registration/update
- `POST /api/kyc/verify` - KYC verification
- `POST /api/financials/link` - Financial data linking
- `POST /api/files` - Document upload
- `GET /api/files` - Document listing
- `GET /api/score` - Investability score
- `GET /api/notifications` - User notifications

## 🚀 Deployment

### Vercel (Recommended)
1. Connect your GitHub repository
2. Set environment variables
3. Deploy automatically on push

### Docker
1. Build the Docker image
2. Configure environment variables
3. Run with docker-compose

### Manual Deployment
1. Build the application: `npm run build`
2. Start the server: `npm start`
3. Configure reverse proxy (nginx)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📝 License

This project is proprietary software. All rights reserved.

## 🆘 Support

For technical support or questions:
- Check the [Decisions Documentation](./docs/DECISIONS.md)
- Review the [Docker Deployment Guide](./docs/DOCKER_DEPLOYMENT.md)
- Contact the development team

---

**Built with ❤️ for the Capital Marketplace Platform**