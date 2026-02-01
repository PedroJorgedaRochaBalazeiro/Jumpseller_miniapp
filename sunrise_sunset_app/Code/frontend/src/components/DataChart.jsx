// src/components/DataChart.jsx
import React from "react";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  Area,
  ComposedChart,
} from "recharts";
import { parseTime, formatDateShort, formatTimeFromDecimal } from "../utils/dateHelpers";
import "./DataChart.css";

const CustomTooltip = ({ active, payload }) => {
  if (active && payload && payload.length) {
    const data = payload[0].payload;
    return (
      <div className="custom-tooltip">
        <p className="tooltip-date">📅 {data.fullDate}</p>
        <p className="tooltip-location">📍 {data.location}</p>
        <hr />
        <p className="tooltip-sunrise">
          🌅 Sunrise: <strong>{formatTimeFromDecimal(data.sunrise)}</strong>
        </p>
        <p className="tooltip-sunset">
          🌇 Sunset: <strong>{formatTimeFromDecimal(data.sunset)}</strong>
        </p>
        <p className="tooltip-day-length">
          ☀️ Day Length:{" "}
          <strong>
            {Math.floor(data.dayLengthMinutes / 60)}h {Math.round(data.dayLengthMinutes % 60)}m
          </strong>
        </p>
      </div>
    );
  }
  return null;
};

const DataChart = ({ data }) => {
  if (!data || data.length === 0) {
    return (
      <div className="chart-container">
        <div className="no-data">
          <p>📊 No data to display</p>
        </div>
      </div>
    );
  }

  const chartData = data.map((record) => {
    const attrs = record.attributes;
    return {
      date: formatDateShort(attrs.date),
      fullDate: attrs.date,
      sunrise: parseTime(attrs.sunrise),
      sunset: parseTime(attrs.sunset),
      dayLengthMinutes: attrs.day_length_minutes || 0,
      location: attrs.location,
    };
  });

  return (
    <div className="chart-container">
      <div className="chart-header">
        <h3>📈 Sunrise & Sunset Times</h3>
        <p className="chart-subtitle">
          {data[0].attributes.location} • {data.length} days
        </p>
      </div>

      <ResponsiveContainer width="100%" height={400}>
        <ComposedChart data={chartData} margin={{ top: 20, right: 30, left: 20, bottom: 60 }}>
          <defs>
            <linearGradient id="colorDayLength" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor="#ffd700" stopOpacity={0.3} />
              <stop offset="95%" stopColor="#ffd700" stopOpacity={0} />
            </linearGradient>
          </defs>

          <CartesianGrid strokeDasharray="3 3" stroke="#e0e0e0" />
          <XAxis dataKey="date" tick={{ fontSize: 12, fill: "#666" }} angle={-45} textAnchor="end" height={80} stroke="#999" />
          <YAxis
            label={{ value: "Time (24h format)", angle: -90, position: "insideLeft", style: { fontSize: 14, fill: "#666" } }}
            domain={[0, 24]}
            ticks={[0, 3, 6, 9, 12, 15, 18, 21, 24]}
            tick={{ fontSize: 12, fill: "#666" }}
            stroke="#999"
          />

          <Tooltip content={<CustomTooltip />} />
          <Legend wrapperStyle={{ paddingTop: "20px" }} iconType="line" />

          <Area type="monotone" dataKey="dayLengthMinutes" fill="url(#colorDayLength)" stroke="none" yAxisId="right" name="Day Length (hours)" hide />
          <Line type="monotone" dataKey="sunrise" stroke="#ff9800" strokeWidth={3} name="Sunrise" dot={{ r: 4, fill: "#ff9800" }} activeDot={{ r: 6 }} />
          <Line type="monotone" dataKey="sunset" stroke="#3f51b5" strokeWidth={3} name="Sunset" dot={{ r: 4, fill: "#3f51b5" }} activeDot={{ r: 6 }} />
        </ComposedChart>
      </ResponsiveContainer>

      <div className="chart-footer">
        <div className="legend-item">
          <span className="legend-dot sunrise"></span>
          <span>Sunrise</span>
        </div>
        <div className="legend-item">
          <span className="legend-dot sunset"></span>
          <span>Sunset</span>
        </div>
      </div>
    </div>
  );
};

export default DataChart;
