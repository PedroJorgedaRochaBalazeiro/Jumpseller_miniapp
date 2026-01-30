// src/components/LoadingSpinner.jsx
import './LoadingSpinner.css';

const LoadingSpinner = ({ message = 'Loading data...' }) => {
  return (
    <div className="loading-container">
      <div className="loading-spinner">
        <div className="spinner-circle"></div>
        <div className="spinner-circle"></div>
        <div className="spinner-circle"></div>
      </div>
      <p className="loading-message">{message}</p>
      <p className="loading-hint">
        This may take a few seconds while we fetch data from the API
      </p>
    </div>
  );
};

export default LoadingSpinner;