import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Suspense, lazy } from 'react';
import { PageLoading } from './components/Common/Loading';

const Landing = lazy(() => import('./pages/Landing'));
const Login = lazy(() => import('./pages/Login'));
const Register = lazy(() => import('./pages/Register'));
const RegisterCreator = lazy(() => import('./pages/RegisterCreator'));
const VerifyEmail = lazy(() => import('./pages/VerifyEmail'));
const Home = lazy(() => import('./pages/Home'));
const CreatorProfile = lazy(() => import('./pages/CreatorProfile'));
const Chat = lazy(() => import('./pages/Chat'));
const Dashboard = lazy(() => import('./pages/Dashboard'));
const DiamondStore = lazy(() => import('./pages/DiamondStore'));
const CreateContent = lazy(() => import('./pages/CreateContent'));
const NotFound = lazy(() => import('./pages/NotFound'));

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<PageLoading />}>
        <Routes>
          <Route path="/" element={<Landing />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          <Route path="/register/creadora" element={<RegisterCreator />} />
          <Route path="/verify-email" element={<VerifyEmail />} />
          <Route path="/home" element={<Home />} />
          <Route path="/creadora/:username" element={<CreatorProfile />} />
          <Route path="/chat/:username" element={<Chat />} />
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/dashboard/influencer" element={<Dashboard />} />
          <Route path="/crear" element={<CreateContent />} />
          <Route path="/diamantes" element={<DiamondStore />} />
          <Route path="*" element={<NotFound />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}

export default App;