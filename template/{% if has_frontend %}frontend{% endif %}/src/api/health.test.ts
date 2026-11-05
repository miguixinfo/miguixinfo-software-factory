import { fetchHealth } from './health';

const respond = (ok: boolean, body: unknown) =>
  vi.fn().mockResolvedValue({ ok, json: () => Promise.resolve(body) } as Response);

describe('fetchHealth', () => {
  it('devuelve up cuando el backend responde UP', async () => {
    expect(await fetchHealth(respond(true, { status: 'UP' }))).toBe('up');
  });

  it('devuelve down cuando el estado no es UP', async () => {
    expect(await fetchHealth(respond(true, { status: 'DOWN' }))).toBe('down');
  });

  it('devuelve down ante un error HTTP', async () => {
    expect(await fetchHealth(respond(false, {}))).toBe('down');
  });

  it('devuelve down si la red falla', async () => {
    expect(await fetchHealth(vi.fn().mockRejectedValue(new Error('red')))).toBe('down');
  });
});
