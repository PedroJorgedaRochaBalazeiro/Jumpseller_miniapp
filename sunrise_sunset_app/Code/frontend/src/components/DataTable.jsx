// src/components/DataTable.jsx
import { formatDate, minutesToHoursMinutes } from '../utils/dateHelpers';
import './DataTable.css';

const DataTable = ({ data }) => {
  if (!data || data.length === 0) {
    return (
      <div className="table-container">
        <div className="no-data">
          <p>📋 No data to display</p>
        </div>
      </div>
    );
  }

  return (
    <div className="table-container">
      <div className="table-header">
        <h3>📋 Detailed Data</h3>
        <p className="table-subtitle">
          {data.length} {data.length === 1 ? 'record' : 'records'} for {data[0].attributes.location}
        </p>
      </div>

      <div className="table-wrapper">
        <table className="data-table">
          <thead>
            <tr>
              <th>Date</th>
              <th>🌅 Sunrise</th>
              <th>🌇 Sunset</th>
              <th>☀️ Solar Noon</th>
              <th>⏱️ Day Length</th>
              <th>🌄 Golden Hour (AM)</th>
              <th>🌆 Golden Hour (PM)</th>
            </tr>
          </thead>
          <tbody>
            {data.map((record) => {
              const attrs = record.attributes;
              return (
                <tr key={record.id}>
                  <td className="date-cell">
                    <div className="date-display">
                      <span className="date-full">{formatDate(attrs.date)}</span>
                      <span className="date-short">{attrs.date}</span>
                    </div>
                  </td>
                  <td className="time-cell sunrise">
                    {attrs.sunrise || 'N/A'}
                  </td>
                  <td className="time-cell sunset">
                    {attrs.sunset || 'N/A'}
                  </td>
                  <td className="time-cell">
                    {attrs.solar_noon || 'N/A'}
                  </td>
                  <td className="duration-cell">
                    <div className="duration-display">
                      <span className="duration-primary">
                        {attrs.day_length_minutes 
                          ? minutesToHoursMinutes(attrs.day_length_minutes)
                          : attrs.day_length || 'N/A'}
                      </span>
                      {attrs.day_length && attrs.day_length !== 'N/A' && (
                        <span className="duration-secondary">
                          {attrs.day_length}
                        </span>
                      )}
                    </div>
                  </td>
                  <td className="time-cell golden-hour">
                    {attrs.golden_hour || 'N/A'}
                  </td>
                  <td className="time-cell golden-hour">
                    {attrs.golden_hour_end || 'N/A'}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      <div className="table-footer">
        <div className="table-info">
          <p>
            ℹ️ <strong>Golden Hour:</strong> The period shortly after sunrise or before sunset, 
            perfect for photography with warm, soft light.
          </p>
          {data[0].attributes.is_polar_region && (
            <p className="polar-warning">
              ⚠️ <strong>Polar Region:</strong> This location experiences extreme daylight variations. 
              Some dates may have no sunrise or sunset.
            </p>
          )}
        </div>
      </div>
    </div>
  );
};

export default DataTable;