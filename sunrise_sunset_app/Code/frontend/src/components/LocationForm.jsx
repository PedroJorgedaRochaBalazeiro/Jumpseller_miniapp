// src/components/LocationForm.jsx
import { useState } from "react";
import DatePicker from "react-datepicker";
import { format, subDays, addDays } from "date-fns";
import { validateDateRange } from "../utils/dateHelpers";
import "react-datepicker/dist/react-datepicker.css";
import "./LocationForm.css";

const LocationForm = ({ onSubmit, loading }) => {
  const [location, setLocation] = useState("");
  const [startDate, setStartDate] = useState(subDays(new Date(), 7));
  const [endDate, setEndDate] = useState(new Date());
  const [validationError, setValidationError] = useState("");

  const handleSubmit = (e) => {
    e.preventDefault();
    setValidationError("");

    // Validate location
    if (!location.trim()) {
      setValidationError("Please enter a location");
      return;
    }

    // Validate date range
    const validation = validateDateRange(startDate, endDate);
    if (!validation.valid) {
      setValidationError(validation.error);
      return;
    }

    // Submit the form
    onSubmit({
      location: location.trim(),
      startDate: format(startDate, "yyyy-MM-dd"),
      endDate: format(endDate, "yyyy-MM-dd"),
    });
  };

  const handleLocationChange = (e) => {
    setLocation(e.target.value);
    setValidationError("");
  };

  const handleStartDateChange = (date) => {
    setStartDate(date);
    setValidationError("");
  };

  const handleEndDateChange = (date) => {
    setEndDate(date);
    setValidationError("");
  };

  return (
    <form onSubmit={handleSubmit} className="location-form">
      <div className="form-header">
        <h2>🌍 Get Sunrise & Sunset Data</h2>
        <p className="form-subtitle">
          Enter a location and date range to view historical sun data
        </p>
      </div>

      <div className="form-group">
        <label htmlFor="location">
          <span className="label-text">Location</span>
          <span className="label-hint">City name or "City, Country"</span>
        </label>
        <input
          id="location"
          type="text"
          value={location}
          onChange={handleLocationChange}
          placeholder="e.g., Lisbon, Porto, Berlin, Tokyo"
          disabled={loading}
          className="form-input"
          autoComplete="off"
        />
        <p className="input-help">
          💡 Try: Lisbon, Porto, Berlin, Tokyo, London, New York
        </p>
      </div>

      <div className="form-row">
        <div className="form-group">
          <label htmlFor="start-date">
            <span className="label-text">Start Date</span>
          </label>
          <DatePicker
            id="start-date"
            selected={startDate}
            onChange={handleStartDateChange}
            maxDate={endDate}
            dateFormat="yyyy-MM-dd"
            disabled={loading}
            className="form-input date-input"
            placeholderText="Select start date"
          />
        </div>

        <div className="form-group">
          <label htmlFor="end-date">
            <span className="label-text">End Date</span>
          </label>
          <DatePicker
            id="end-date"
            selected={endDate}
            onChange={handleEndDateChange}
            minDate={startDate}
            maxDate={addDays(startDate, 365)}
            dateFormat="yyyy-MM-dd"
            disabled={loading}
            className="form-input date-input"
            placeholderText="Select end date"
          />
        </div>
      </div>

      {validationError && (
        <div className="validation-error">⚠️ {validationError}</div>
      )}

      <button
        type="submit"
        disabled={loading}
        className={`submit-button ${loading ? "loading" : ""}`}
      >
        {loading ? (
          <>
            <span className="spinner"></span>
            <span>Loading Data...</span>
          </>
        ) : (
          <>
            <span>🔍</span>
            <span>Get Sunrise & Sunset Data</span>
          </>
        )}
      </button>

      <div className="form-info">
        <p>ℹ️ Maximum date range: 365 days</p>
      </div>
    </form>
  );
};

export default LocationForm;
