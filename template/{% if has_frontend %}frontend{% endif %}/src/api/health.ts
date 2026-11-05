export type HealthStatus = 'checking' | 'up' | 'down';

export async function fetchHealth(fetcher: typeof fetch = fetch): Promise<HealthStatus> {
  try {
    const response = await fetcher('/actuator/health');
    if (!response.ok) return 'down';
    const body = (await response.json()) as { status?: string };
    return body.status === 'UP' ? 'up' : 'down';
  } catch {
    return 'down';
  }
}
