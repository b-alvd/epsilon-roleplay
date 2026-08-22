import { useState, useEffect, useRef, useCallback } from 'react'
import { onNUI, nuiPost } from '../../hooks/useNUI'
import s from './NoclipHUD.module.css'
import a from './Admin.module.css'

// ── Announce overlay ───────────────────────────────────────────

const ANN_ANIMS = `
@keyframes annSlideDown { from { opacity:0; transform:translateY(-12px) } to { opacity:1; transform:translateY(0) } }
@keyframes annSlideUp   { from { opacity:1; transform:translateY(0) } to { opacity:0; transform:translateY(-12px) } }
`

// ── ReportHUD ──────────────────────────────────────────────────
interface ReportStatus {
  id: number
  status: 'open' | 'in_progress' | 'closed'
  created_at: string
  assigned_name?: string
  assigned_at?: string
  closed_by_name?: string
  closed_at?: string
}

function useElapsed(from: string | undefined, stopped: boolean) {
  const [elapsed, setElapsed] = useState('')
  useEffect(() => {
    if (!from) { setElapsed(''); return }
    const compute = () => {
      const ms = Date.now() - new Date(from).getTime()
      if (ms < 0) return ''
      const total = Math.floor(ms / 1000)
      const h = Math.floor(total / 3600)
      const m = Math.floor((total % 3600) / 60)
      const sc = total % 60
      if (h > 0) return `${h}h${String(m).padStart(2,'0')}`
      if (m > 0) return `${m}min${String(sc).padStart(2,'0')}s`
      return `${sc}s`
    }
    setElapsed(compute())
    if (stopped) return
    const id = setInterval(() => setElapsed(compute()), 1000)
    return () => clearInterval(id)
  }, [from, stopped])
  return elapsed
}

export function ReportHUD() {
  const [report, setReport] = useState<ReportStatus | null>(null)
  const dismissRef = useRef<ReturnType<typeof setTimeout> | null>(null)
  const elapsed = useElapsed(report?.created_at, report?.status === 'closed')

  useEffect(() => {
    const u1 = onNUI<ReportStatus>('epsilon:report:status', d => {
      if (dismissRef.current) clearTimeout(dismissRef.current)
      setReport(prev => {
        const next = prev ? { ...prev, ...d } : d
        if (prev?.created_at && !d.created_at) next.created_at = prev.created_at
        return next
      })
      if (d.status === 'closed') {
        dismissRef.current = setTimeout(() => setReport(null), 5000)
      }
    })
    const u2 = onNUI<void>('epsilon:report:clear', () => {
      if (dismissRef.current) clearTimeout(dismissRef.current)
      setReport(null)
    })
    return () => { u1(); u2() }
  }, [])

  if (!report) return null

  const ST = {
    open:        { color: '#ef4444', label: 'En attente' },
    in_progress: { color: '#f59e0b', label: 'En cours'   },
    closed:      { color: '#22c55e', label: 'Clôturé'    },
  }
  const st = ST[report.status]

  return (
    <div className={a.reportHud} style={{ ['--rhud-color' as string]: st.color, animation: 'rhudIn .25s ease' }}>
      <style>{`@keyframes rhudIn { from { opacity:0; transform:translateX(10px) } to { opacity:1; transform:none } }`}</style>
      <div className={a.reportHudHead}>
        <span className={a.reportHudDot} />
        <span className={a.reportHudId}>Report #{report.id}</span>
        <span className={a.reportHudStatus}>{st.label}</span>
      </div>
      <div className={a.reportHudBody}>
        <div className={a.reportHudRow}>
          <i className="bi bi-clock" />
          <span>Ouvert il y a <strong>{elapsed}</strong></span>
        </div>
        {report.assigned_name && (
          <div className={a.reportHudRow}>
            <i className="bi bi-person-check-fill" style={{ color: '#f59e0b' }} />
            <span>Pris en charge par <strong>{report.assigned_name}</strong></span>
          </div>
        )}
        {report.closed_by_name && (
          <div className={a.reportHudRow}>
            <i className="bi bi-check-circle-fill" style={{ color: '#22c55e' }} />
            <span>Clôturé par <strong>{report.closed_by_name}</strong></span>
          </div>
        )}
      </div>
    </div>
  )
}

// ── NoclipHUD ──────────────────────────────────────────────────
interface NoclipState { active: boolean; speedIdx?: number }

export function NoclipHUD() {
  const [state, setState] = useState<NoclipState>({ active: false, speedIdx: 1 })
  useEffect(() => onNUI<NoclipState>('epsilon:admin:noclipHUD', setState), [])
  if (!state.active) return null
  const idx = state.speedIdx ?? 1
  const total = 8
  return (
    <div className={s.hud}>
      <div className={s.title}><span className={s.dot} />NoClip actif</div>
      <div className={s.speed}>
        <div className={s.speedHeader}>
          <span className={s.speedLabel}>Vitesse</span>
          <span className={s.speedVal}><span className={s.speedNum}>{idx}</span><span className={s.speedTotal}>/{total}</span></span>
        </div>
        <div className={s.speedTrack}>
          <div className={s.speedFill} style={{ width: `${(idx / total) * 100}%` }} />
        </div>
      </div>
      <div className={s.keys}>
        <div className={s.keyRow}><span className={s.key}>Z</span><span className={s.key}>S</span><span>Avancer / Reculer</span></div>
        <div className={s.keyRow}><span className={s.key}>Q</span><span className={s.key}>D</span><span>Tourner</span></div>
        <div className={s.keyRow}><span className={s.key}>A</span><span className={s.key}>W</span><span>Monter / Descendre</span></div>
        <div className={s.keyRow}><span className={s.key}>SHIFT</span><span>Changer vitesse</span></div>
      </div>
    </div>
  )
}

// ── AnnounceOverlay ────────────────────────────────────────────
interface AnnounceMsg { admin: string; message: string; duration?: number }

export function AnnounceOverlay() {
  const [msg, setMsg] = useState<AnnounceMsg | null>(null)
  const [leaving, setLeaving] = useState(false)
  const [key, setKey] = useState(0)
  const timerRef  = useRef<ReturnType<typeof setTimeout> | null>(null)
  const leaveRef  = useRef<ReturnType<typeof setTimeout> | null>(null)
  const leavingRef = useRef(false)

  const dismiss = useCallback(() => {
    if (leavingRef.current) return
    leavingRef.current = true
    setLeaving(true)
    leaveRef.current = setTimeout(() => {
      setMsg(null)
      setLeaving(false)
      leavingRef.current = false
    }, 400)
  }, [])

  useEffect(() => {
    const show = (d: AnnounceMsg) => {
      if (timerRef.current) clearTimeout(timerRef.current)
      if (leaveRef.current)  clearTimeout(leaveRef.current)
      leavingRef.current = false
      setLeaving(false)
      setMsg(d); setKey(k => k + 1)
      timerRef.current = setTimeout(dismiss, (d.duration ?? 10) * 1000)
    }
    const u1 = onNUI<AnnounceMsg>('epsilon:admin:announce', show)
    const u2 = onNUI<{ admin?: string; message: string; duration?: number }>('epsilon:notifyStaff', d =>
      show({ admin: d.admin ?? 'Serveur', message: d.message, duration: d.duration })
    )
    const u3 = onNUI<void>('epsilon:admin:announceClose', dismiss)
    return () => { u1(); u2(); u3() }
  }, [dismiss])

  if (!msg) return null
  const durationMs = `${(msg.duration ?? 10) * 1000}ms`
  const anim = leaving
    ? 'annSlideUp 0.40s ease-in forwards'
    : 'annSlideDown 0.55s cubic-bezier(0.22,1,0.36,1) forwards'
  return (
    <>
      <style>{ANN_ANIMS}</style>
    <div className={a.announceOverlay}>
      <div className={a.announceBox} key={key} style={{ animation: anim }}>
        <div className={a.annTop}>
          <i className={`bi bi-megaphone-fill ${a.annIcon}`} />
          <span className={a.annLabel}>Administration</span>
          <span className={a.annAdmin}>{msg.admin}</span>
        </div>
        <div className={a.annMsg}>{msg.message}</div>
        <div className={a.annBar} style={{ ['--ann-duration' as string]: durationMs }} />
      </div>
    </div>
    </>
  )
}

// ── SpectateBar ────────────────────────────────────────────────
interface SpectateState { state: boolean; target?: string; serverId?: number }

export function SpectateBar() {
  const [spec, setSpec] = useState<SpectateState>({ state: false })
  useEffect(() => onNUI<SpectateState>('epsilon:admin:spectateState', setSpec), [])
  if (!spec.state) return null
  return (
    <div className={a.spectateBar}>
      <i className="bi bi-eye-fill" />
      <span className={a.specLabel}>Spectateur — {spec.target}</span>
      <button onClick={() => nuiPost('admin:spectate', { id: spec.serverId })}>Quitter</button>
    </div>
  )
}
