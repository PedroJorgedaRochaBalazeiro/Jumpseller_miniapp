// src/hooks/useSunriseSunsetData.js
import { useState, useCallback } from "react";
import { sunriseSunsetAPI } from "../services/apiService";

/**
 * Custom hook for managing sunrise/sunset data fetching
 * @returns {Object} - data, loading, error states and fetch function
 */
export const useSunriseSunsetData = () => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  /**
   * Fetch data from API
   * @param {string} location - Location name
   * @param {string} startDate - Start date (YYYY-MM-DD)
   * @param {string} endDate - End date (YYYY-MM-DD)
   */
  const fetchData = useCallback(async (location, startDate, endDate) => {
    setLoading(true);
    setError(null);
    setData(null);

    try {
      console.log("🔍 Fetching data for:", { location, startDate, endDate });
      const response = await sunriseSunsetAPI.fetchData(
        location,
        startDate,
        endDate,
      );

      if (response.data && Array.isArray(response.data)) {
        setData(response.data);
        console.log(
          "✅ Data fetched successfully:",
          response.data.length,
          "records",
        );
      } else {
        throw new Error("Invalid response format from server");
      }

      return response.data;
    } catch (err) {
      console.error("❌ Error fetching data:", err);
      setError(err.message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  /**
   * Reset all state
   */
  const reset = useCallback(() => {
    setData(null);
    setError(null);
    setLoading(false);
  }, []);

  return {
    data,
    loading,
    error,
    fetchData,
    reset,
  };
};

export default useSunriseSunsetData;
