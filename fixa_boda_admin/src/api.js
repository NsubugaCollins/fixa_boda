const API_BASE = 'http://localhost:8081/api';

async function request(path, options = {}) {
  const res = await fetch(`${API_BASE}${path}`, {
    headers: {
      'Content-Type': 'application/json',
      ...options.headers,
    },
    ...options,
  });
  if (!res.ok) {
    const text = await res.text().catch(() => '');
    throw new Error(text || `Request failed: ${res.status}`);
  }
  return res.json();
}

export const adminApi = {
  getUsers: () => request('/admin/users'),
  getUsersByRole: (role) => request(`/admin/users/role/${role}`),
  updateUserStatus: (id, status) =>
    request(`/admin/users/${id}/status`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: `status=${status}`,
    }),
};
