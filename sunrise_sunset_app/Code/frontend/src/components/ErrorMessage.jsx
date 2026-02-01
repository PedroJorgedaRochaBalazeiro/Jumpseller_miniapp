// src/components/ErrorMessage.jsx
import "./ErrorMessage.css";

const ErrorMessage = ({ message, onDismiss }) => {
  return (
    <div className="error-container">
      <div className="error-box">
        <div className="error-header">
          <span className="error-icon">⚠️</span>
          <h3>Oops! Something went wrong</h3>
        </div>

        <div className="error-body">
          <p className="error-message">{message}</p>

          <div className="error-suggestions">
            <p>
              <strong>Suggestions:</strong>
            </p>
            <ul>
              <li>Check the spelling of the location</li>
              <li>
                Try using "City, Country" format (e.g., "Porto, Portugal")
              </li>
              <li>Make sure the backend server is running</li>
              <li>Verify your internet connection</li>
            </ul>
          </div>
        </div>

        <div className="error-footer">
          <button onClick={onDismiss} className="dismiss-button">
            ✖ Dismiss
          </button>
        </div>
      </div>
    </div>
  );
};

export default ErrorMessage;
