// src/services/apiService.js
import axios from "axios";

const API_BASE_URL =
  import.meta.env.VITE_API_URL || "http://localhost:3000/api/v1";

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
  timeout: 30000, // 30 seconds
});

// Request interceptor for logging
apiClient.interceptors.request.use(
  (config) => {
    console.log("📤 API Request:", config.method.toUpperCase(), config.url);
    return config;
  },
  (error) => {
    console.error("❌ Request Error:", error);
    return Promise.reject(error);
  },
);

// Response interceptor for logging and error handling
apiClient.interceptors.response.use(
  (response) => {
    console.log("📥 API Response:", response.status, response.config.url);
    return response;
  },
  (error) => {
    console.error("❌ Response Error:", error.response?.status, error.message);
    return Promise.reject(error);
  },
);

export const sunriseSunsetAPI = {
  /**
   * Fetch sunrise/sunset data for a location and date range
   * @param {string} location - Location name (e.g., "Lisbon", "Berlin")
   * @param {string} startDate - Start date in YYYY-MM-DD format
   * @param {string} endDate - End date in YYYY-MM-DD format
   * @returns {Promise} Response data
   */
  fetchData: async (location, startDate, endDate) => {
    try {
      const response = await apiClient.post("/sunrise_sunsets", {
        location,
        start_date: startDate,
        end_date: endDate,
      });
      return response.data;
    } catch (error) {
      throw handleApiError(error);
    }
  },

  /**
   * Get existing records (optional filters)
   * @param {Object} filters - Optional filters {location, start_date, end_date}
   * @returns {Promise} Response data
   */
  getRecords: async (filters = {}) => {
    try {
      const response = await apiClient.get("/sunrise_sunsets", {
        params: filters,
      });
      return response.data;
    } catch (error) {
      throw handleApiError(error);
    }
  },

  /**
   * Delete a specific record
   * @param {number} id - Record ID
   * @returns {Promise}
   */
  deleteRecord: async (id) => {
    try {
      await apiClient.delete(`/sunrise_sunsets/${id}`);
    } catch (error) {
      throw handleApiError(error);
    }
  },

  /**
   * Health check - verify backend is running
   * @returns {Promise}
   */
  healthCheck: async () => {
    try {
      const response = await axios.get(
        `${API_BASE_URL.replace("/api/v1", "")}/health`,
      );
      return response.data;
    } catch {
      throw new Error(
        "Backend is not responding. Please make sure the server is running.",
      );
    }
  },
};

/**
 * Handle API errors and return user-friendly messages
 * @param {Error} error - Axios error object
 * @returns {Error} Formatted error
 */
function handleApiError(error) {
  if (error.response) {
    // Server responded with error status
    const { status, data } = error.response;

    switch (status) {
      case 400:
        return new Error(
          data.error?.message ||
            "Invalid request. Please check your parameters.",
        );
      case 422:
        return new Error(
          data.error?.message ||
            "Location not found. Please check the spelling.",
        );
      case 502:
        return new Error(
          data.error?.message || "External API error. Please try again later.",
        );
      case 500:
        return new Error("Server error. Please try again later.");
      default:
        return new Error(
          data.error?.message || `An error occurred (Status: ${status})`,
        );
    }
  } else if (error.request) {
    // Request made but no response received
    return new Error(
      "No response from server. Please check your connection and make sure the backend is running.",
    );
  } else {
    // Something else happened
    return new Error(error.message || "An unexpected error occurred");
  }
}

export default apiClient;
