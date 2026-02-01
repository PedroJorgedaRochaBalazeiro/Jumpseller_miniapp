// src/utils/dateHelpers.js
import { parse, format } from "date-fns";

/**
 * Convert time string "7:45:23 AM" to decimal hours
 * @param {string} timeString - Time in format "HH:MM:SS AM/PM"
 * @returns {number|null} - Hours as decimal (e.g., 7.75)
 */
export function parseTime(timeString) {
  if (!timeString || timeString === "N/A") return null;

  try {
    const date = parse(timeString, "h:mm:ss a", new Date());
    return date.getHours() + date.getMinutes() / 60 + date.getSeconds() / 3600;
  } catch (error) {
    console.error("Error parsing time:", error);
    return null;
  }
}

/**
 * Format date for display
 * @param {string} dateString - Date string (YYYY-MM-DD)
 * @returns {string} - Formatted date (MMM dd, yyyy)
 */
export function formatDate(dateString) {
  if (!dateString) return "";

  try {
    const date = new Date(dateString);
    return format(date, "MMM dd, yyyy");
  } catch (error) {
    console.error("Error formatting date:", error);
    return dateString;
  }
}

/**
 * Format date for short display (for charts)
 * @param {string} dateString - Date string (YYYY-MM-DD)
 * @returns {string} - Formatted date (MM/dd)
 */
export function formatDateShort(dateString) {
  if (!dateString) return "";

  try {
    const date = new Date(dateString);
    return format(date, "MM/dd");
  } catch {
    return dateString;
  }
}

/**
 * Convert duration string "09:44:52" to minutes
 * @param {string} duration - Duration in format "HH:MM:SS"
 * @returns {number} - Total minutes
 */
export function durationToMinutes(duration) {
  if (!duration || duration === "N/A") return 0;

  try {
    const [hours, minutes, seconds] = duration.split(":").map(Number);
    return hours * 60 + minutes + seconds / 60;
  } catch (error) {
    console.error("Error parsing duration:", error);
    return 0;
  }
}

/**
 * Convert minutes to hours and minutes display
 * @param {number} minutes - Total minutes
 * @returns {string} - Formatted as "Xh Ym"
 */
export function minutesToHoursMinutes(minutes) {
  if (!minutes) return "0h 0m";

  const hours = Math.floor(minutes / 60);
  const mins = Math.round(minutes % 60);
  return `${hours}h ${mins}m`;
}

/**
 * Format time for tooltip display
 * @param {number} decimalHours - Hours as decimal
 * @returns {string} - Formatted time "HH:MM"
 */
export function formatTimeFromDecimal(decimalHours) {
  if (decimalHours === null || decimalHours === undefined) return "N/A";

  const hours = Math.floor(decimalHours);
  const minutes = Math.round((decimalHours % 1) * 60);

  return `${String(hours).padStart(2, "0")}:${String(minutes).padStart(2, "0")}`;
}

/**
 * Validate date range
 * @param {Date} startDate - Start date
 * @param {Date} endDate - End date
 * @returns {Object} - {valid: boolean, error: string}
 */
export function validateDateRange(startDate, endDate) {
  if (!startDate || !endDate) {
    return { valid: false, error: "Please select both start and end dates" };
  }

  if (endDate < startDate) {
    return { valid: false, error: "End date must be after start date" };
  }

  const daysDiff = Math.ceil((endDate - startDate) / (1000 * 60 * 60 * 24));
  if (daysDiff > 365) {
    return { valid: false, error: "Date range cannot exceed 365 days" };
  }

  return { valid: true, error: null };
}
