import { useState, useEffect } from 'react'
import './App.css'
import { adminApi } from './api.js'

const navItems = [
  'Overview',
  'Riders',
  'Mechanics',
  'Requests',
  'Earnings',
  'Reports',
  'Settings',
]

function App() {
  const [activeTab, setActiveTab] = useState('Overview')
  const [riders, setRiders] = useState([])
  const [mechanics, setMechanics] = useState([])
  const [serviceRequests, setServiceRequests] = useState([])
  const [dashboardSummary, setDashboardSummary] = useState({
    riders: 0,
    mechanics: 0,
    verifiedMechanics: 0,
    availableMechanics: 0,
    openRequests: 0,
    acceptedRequests: 0,
    completedRequests: 0,
  })
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  const chartBars = [42, 58, 35, 70, 52, 88, 66, 94]

  useEffect(() => {
    let cancelled = false
    async function load() {
      setLoading(true)
      try {
        const [users, summary] = await Promise.all([
          adminApi.getUsers(),
          adminApi.getDashboardSummary(),
        ])
        if (!cancelled) {
          setRiders(users.filter(u => u.role === 'RIDER'))
          setMechanics(users.filter(u => u.role === 'MECHANIC'))
          setDashboardSummary(summary)
          setServiceRequests([])
        }
      } catch (err) {
        if (!cancelled) setError(err.message)
      } finally {
        if (!cancelled) setLoading(false)
      }
    }
    load()
    return () => { cancelled = true }
  }, [])

  const renderTabContent = () => {
    if (loading) {
      return (
        <article className="panel table-panel">
          <div className="panel-header">
            <div>
              <p className="eyebrow">Loading</p>
              <h3>Fetching data from backend</h3>
            </div>
          </div>
        </article>
      )
    }

    if (error) {
      return (
        <article className="panel table-panel">
          <div className="panel-header">
            <div>
              <p className="eyebrow">Error</p>
              <h3>Unable to connect to backend</h3>
            </div>
          </div>
          <div style={{ padding: 20, color: '#111' }}>
            {error}
            <br />
            Make sure the Spring Boot backend is running on http://localhost:8081
          </div>
        </article>
      )
    }

    if (activeTab === 'Overview') {
      return (
        <article className="panel large-panel">
          <div className="panel-header">
            <div>
              <p className="eyebrow">Operations</p>
              <h3>Live network snapshot</h3>
            </div>
          </div>

          <div className="mechanic-list">
            <div className="mechanic-item">
              <div className="avatar">R</div>
              <div className="mechanic-copy">
                <strong>Riders</strong>
                <span>Active rider accounts</span>
              </div>
              <div className="mechanic-meta">
                <strong>{dashboardSummary.riders}</strong>
              </div>
            </div>
            <div className="mechanic-item">
              <div className="avatar">M</div>
              <div className="mechanic-copy">
                <strong>Mechanics</strong>
                <span>Registered service partners</span>
              </div>
              <div className="mechanic-meta">
                <strong>{dashboardSummary.mechanics}</strong>
              </div>
            </div>
            <div className="mechanic-item">
              <div className="avatar">V</div>
              <div className="mechanic-copy">
                <strong>Verified</strong>
                <span>Mechanics cleared for dispatch</span>
              </div>
              <div className="mechanic-meta">
                <strong>{dashboardSummary.verifiedMechanics}</strong>
              </div>
            </div>
            <div className="mechanic-item">
              <div className="avatar">A</div>
              <div className="mechanic-copy">
                <strong>Available</strong>
                <span>On duty nearby mechanics</span>
              </div>
              <div className="mechanic-meta">
                <strong>{dashboardSummary.availableMechanics}</strong>
              </div>
            </div>
          </div>

          <div className="panel-header" style={{ marginTop: 20 }}>
            <div>
              <p className="eyebrow">Bookings</p>
              <h3>Service status</h3>
            </div>
          </div>
          <table>
            <thead>
              <tr>
                <th>Open requests</th>
                <th>Accepted</th>
                <th>Completed</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>{dashboardSummary.openRequests}</td>
                <td>{dashboardSummary.acceptedRequests}</td>
                <td>{dashboardSummary.completedRequests}</td>
              </tr>
            </tbody>
          </table>
        </article>
      )
    }

    if (activeTab === 'Riders') {
      return (
        <article className="panel table-panel">
          <div className="panel-header">
            <div>
              <p className="eyebrow">Rider network</p>
              <h3>Rider activity</h3>
            </div>
          </div>
          <table>
            <thead>
              <tr>
                <th>Rider</th>
                <th>Trips</th>
                <th>Status</th>
                <th>Rating</th>
              </tr>
            </thead>
            <tbody>
              {riders.map((rider) => (
                <tr key={rider.id}>
                  <td>{rider.fullName || rider.email}</td>
                  <td>{rider.id}</td>
                  <td>{rider.status}</td>
                  <td>★ 4.9</td>
                </tr>
              ))}
              {riders.length === 0 && (
                <tr>
                  <td colSpan={4}>No riders found</td>
                </tr>
              )}
            </tbody>
          </table>
        </article>
      )
    }

    if (activeTab === 'Mechanics') {
      return (
        <article className="panel mechanics-panel">
          <div className="panel-header">
            <div>
              <p className="eyebrow">Mechanic network</p>
              <h3>Active mechanics</h3>
            </div>
          </div>
          <div className="mechanic-list">
            {mechanics.map((mechanic) => (
              <div key={mechanic.id} className="mechanic-item">
                <div className="avatar">{mechanic.fullName?.charAt(0) || 'M'}</div>
                <div className="mechanic-copy">
                  <strong>{mechanic.fullName || mechanic.email}</strong>
                  <span>{mechanic.id} jobs today</span>
                </div>
                <div className="mechanic-meta">
                  <span className="rating">★ 4.9</span>
                  <span className={`mini-status ${mechanic.status.toLowerCase()}`}>
                    {mechanic.status}
                  </span>
                </div>
              </div>
            ))}
            {mechanics.length === 0 && (
              <div>No mechanics found</div>
            )}
          </div>
        </article>
      )
    }

    if (activeTab === 'Requests') {
      return (
        <article className="panel table-panel">
          <div className="panel-header">
            <div>
              <p className="eyebrow">Operations</p>
              <h3>Service requests</h3>
            </div>
          </div>
          <table>
            <thead>
              <tr>
                <th>Request</th>
                <th>Rider</th>
                <th>Type</th>
                <th>Mechanic</th>
                <th>ETA</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {serviceRequests.map((request) => (
                <tr key={request.id}>
                  <td>#{request.id}</td>
                  <td>{request.riderId}</td>
                  <td>{request.requestType}</td>
                  <td>{request.mechanicId || '—'}</td>
                  <td>{request.eta || '—'}</td>
                  <td>
                    <span className={`table-status ${request.status.toLowerCase()}`}>
                      {request.status}
                    </span>
                  </td>
                </tr>
              ))}
              {serviceRequests.length === 0 && (
                <tr>
                  <td colSpan={6}>No service requests found</td>
                </tr>
              )}
            </tbody>
          </table>
        </article>
      )
    }

    if (activeTab === 'Earnings') {
      return (
        <article className="panel table-panel">
          <div className="panel-header">
            <div>
              <p className="eyebrow">Revenue</p>
              <h3>Earnings overview</h3>
            </div>
          </div>
          <table>
            <thead>
              <tr>
                <th>Region</th>
                <th>Revenue</th>
                <th>Orders</th>
                <th>Margin</th>
              </tr>
            </thead>
            <tbody>
              <tr><td>Kampala</td><td>UGX 10.4M</td><td>287</td><td>32%</td></tr>
              <tr><td>Jinja</td><td>UGX 6.8M</td><td>164</td><td>29%</td></tr>
              <tr><td>Mbale</td><td>UGX 5.1M</td><td>123</td><td>27%</td></tr>
            </tbody>
          </table>
        </article>
      )
    }

    if (activeTab === 'Reports') {
      return (
        <article className="panel table-panel">
          <div className="panel-header">
            <div>
              <p className="eyebrow">Insights</p>
              <h3>Operational reports</h3>
            </div>
          </div>
          <table>
            <thead>
              <tr>
                <th>Report</th>
                <th>Last update</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <tr><td>Response time trend</td><td>Today</td><td>Healthy</td></tr>
              <tr><td>Fleet utilization</td><td>Yesterday</td><td>Normal</td></tr>
              <tr><td>Customer satisfaction</td><td>2 days ago</td><td>Improving</td></tr>
            </tbody>
          </table>
        </article>
      )
    }

    if (activeTab === 'Settings') {
      return (
        <article className="panel table-panel">
          <div className="panel-header">
            <div>
              <p className="eyebrow">System</p>
              <h3>Account settings</h3>
            </div>
          </div>
          <table>
            <thead>
              <tr>
                <th>Setting</th>
                <th>Value</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              <tr><td>Notifications</td><td>Enabled</td><td>Manage</td></tr>
              <tr><td>Auto assignment</td><td>On</td><td>Adjust</td></tr>
              <tr><td>Partner access</td><td>Active</td><td>Review</td></tr>
            </tbody>
          </table>
        </article>
      )
    }

    return (
      <article className="panel large-panel">
        <div className="panel-header">
          <div>
            <p className="eyebrow">Service coverage</p>
            <h3>Requests over time</h3>
          </div>
          <button type="button" className="small-button">This week</button>
        </div>

        <div className="chart-block" aria-label="Request chart">
          {chartBars.map((value, index) => (
            <div key={index} className="chart-column-wrap">
              <span className="chart-value">{value}</span>
              <div
                className="chart-column"
                style={{ height: `${value}%` }}
              />
            </div>
          ))}
        </div>
      </article>
    )
  }

  return (
    <div className="admin-shell">
      <aside className="sidebar">
        <div className="brand-block">
          <div className="brand-mark">F</div>
          <div>
            <p className="brand-kicker">Fleet ops</p>
            <h1>FixaBoda</h1>
          </div>
        </div>

        <nav className="nav-menu" aria-label="Sidebar navigation">
          {navItems.map((item) => (
            <button
              key={item}
              type="button"
              className={item === activeTab ? 'nav-item active' : 'nav-item'}
              onClick={() => setActiveTab(item)}
            >
              {item}
            </button>
          ))}
        </nav>

        <div className="sidebar-card">
          <p className="muted-label">Daily target</p>
          <h3>82%</h3>
          <div className="progress-track">
            <span className="progress-bar" />
          </div>
          <p className="caption">24 of 29 service cases closed today</p>
        </div>
      </aside>

      <main className="main-panel">
        <header className="topbar">
          <div className="search-box">
            <span className="search-icon">⌕</span>
            <input type="text" value="Search riders, mechanics, jobs" readOnly />
          </div>

          <div className="topbar-actions">
            <button type="button" className="ghost-button">
              Export
            </button>
            <button type="button" className="primary-button">
              + New request
            </button>
          </div>
        </header>

        <section className="welcome-row">
          <div>
            <p className="eyebrow">Operations dashboard</p>
            <h2>Good morning, Admin</h2>
          </div>
          <div className="location-pill">Kampala • Live</div>
        </section>

        {renderTabContent()}
      </main>
    </div>
  )
}

export default App
