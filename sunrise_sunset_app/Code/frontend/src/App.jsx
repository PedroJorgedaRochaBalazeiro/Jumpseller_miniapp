// src/App.jsx
import { useEffect } from "react";
import LocationForm from "./components/LocationForm";
import DataChart from "./components/DataChart";
import DataTable from "./components/DataTable";
import LoadingSpinner from "./components/LoadingSpinner";
import ErrorMessage from "./components/ErrorMessage";
import { useSunriseSunsetData } from "./hooks/useSunriseSunsetData";
import { sunriseSunsetAPI } from "./services/apiService";
import "./App.css";

function App() {
  const { data, loading, error, fetchData, reset } = useSunriseSunsetData();

  // Check backend health on mount
  useEffect(() => {
    const checkBackend = async () => {
      try {
        await sunriseSunsetAPI.healthCheck();
        console.log("✅ Backend is healthy");
      } catch (err) {
        console.warn("⚠️ Backend health check failed:", err.message);
      }
    };

    checkBackend();
  }, []);

  const handleSubmit = async (formData) => {
    try {
      await fetchData(formData.location, formData.startDate, formData.endDate);
    } catch (err) {
      // Error is already set by the hook
      console.error("Error in handleSubmit:", err);
    }
  };

  return (
    <div className="app">
      <header className="app-header">
        <div className="header-content">
          <h1 className="app-title">
            <span className="title-icon">🌅</span>
            Sunrise & Sunset Tracker
          </h1>
          <p className="app-description">
            Get historical sunrise and sunset data for any location around the
            world
          </p>
        </div>
      </header>

      <main className="app-main">
        <div className="form-section">
          <LocationForm onSubmit={handleSubmit} loading={loading} />
        </div>

        {loading && (
          <LoadingSpinner message="Fetching sunrise and sunset data..." />
        )}

        {error && !loading && (
          <ErrorMessage message={error} onDismiss={reset} />
        )}

        {data && !loading && !error && (
          <div className="results-section">
            <div className="results-header">
              <h2>Results for {data[0]?.attributes?.location}</h2>
              <p className="results-count">
                Showing {data.length} {data.length === 1 ? "day" : "days"} of
                data
              </p>
            </div>

            <DataChart data={data} />
            <DataTable data={data} />

            <div className="results-actions">
              <button onClick={reset} className="new-search-button">
                🔍 New Search
              </button>
            </div>
          </div>
        )}

        {!data && !loading && !error && (
          <div className="empty-state">
            <div className="empty-state-content">
              <span className="empty-icon">🌍</span>
              <h3>Ready to explore sunrise and sunset times?</h3>
              <p>
                Enter a location and date range above to get started. You can
                search for any city in the world!
              </p>
              <div className="example-queries">
                <p>
                  <strong>Try these examples:</strong>
                </p>
                <div className="example-chips">
                  <span className="chip">Lisbon</span>
                  <span className="chip">Porto, Portugal</span>
                  <span className="chip">Berlin, Germany</span>
                  <span className="chip">Tokyo, Japan</span>
                  <span className="chip">New York, USA</span>
                </div>
              </div>
            </div>
          </div>
        )}
      </main>

      <footer className="app-footer">
        <div className="footer-content">
          <p className="footer-credits">
            Data provided by{" "}
            <a
              href="https://sunrisesunset.io/api/"
              target="_blank"
              rel="noopener noreferrer"
            >
              SunriseSunset.io API
            </a>
          </p>
          <p className="footer-info">
            Geocoding by{" "}
            <a
              href="https://nominatim.org/"
              target="_blank"
              rel="noopener noreferrer"
            >
              Nominatim (OpenStreetMap)
            </a>
          </p>
        </div>
      </footer>
    </div>
  );
}

export default App;
