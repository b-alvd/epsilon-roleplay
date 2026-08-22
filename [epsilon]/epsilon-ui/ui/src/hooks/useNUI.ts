const RESOURCE_NAME = (() => {
  try { return (window as any).GetParentResourceName() as string }
  catch { return 'epsilon-ui' }
})()

export const IS_FIVEM = RESOURCE_NAME !== 'epsilon-ui' || (() => {
  try { (window as any).GetParentResourceName(); return true }
  catch { return false }
})()

/** Envoie un callback NUI vers le Lua de epsilon-ui */
export function nuiPost<T = unknown>(cb: string, data?: unknown): Promise<T> {
  return fetch(`https://${RESOURCE_NAME}/${cb}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data ?? {}),
  }).then(r => r.json())
}

/** Écoute les messages NUI entrants (SendNUIMessage côté Lua) */
export function onNUI<T>(action: string, handler: (data: T) => void): () => void {
  const listener = (e: MessageEvent) => {
    if (e.data?.action === action) handler(e.data.data as T)
  }
  window.addEventListener('message', listener)
  return () => window.removeEventListener('message', listener)
}
