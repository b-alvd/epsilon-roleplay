import { useState, useEffect, useRef, useCallback } from 'react'
import { onNUI, nuiPost } from '../../hooks/useNUI'
import s from './Notifications.module.css'

const _notifImgs = import.meta.glob('../../assets/images_notifs/*', { eager: true, query: '?url', import: 'default' }) as Record<string, string>
function resolveNotifImage(name?: string): string | undefined {
  if (!name) return undefined
  if (/^(nui|https?|data):/.test(name)) return name
  const entry = Object.entries(_notifImgs).find(([k]) => {
    const base = k.split('/').pop()?.replace(/\.[^.]+$/, '')
    return base === name
  })
  return entry?.[1]
}

// ── Notification stack ─────────────────────────────────────────

const NOTIF_ANIMS = `
@keyframes notifIn {
  from { opacity:0; transform:translate(-100%) }
  to   { opacity:1; transform:translate(0) }
}
@keyframes notifOut {
  from { opacity:1; transform:translate(0); margin-bottom:0 }
  to   { opacity:0; transform:translate(-100%); margin-bottom:-10px }
}
`

const TYPE_COLORS: Record<string, string> = {
  error:   'rgba(220,38,38,0.85)',
  warning: 'rgba(217,119,6,0.85)',
  success: 'rgba(22,163,74,0.85)',
  info:    'rgba(37,99,235,0.85)',
}

interface NotifData {
  text?: string; msg?: string; icon?: string; color?: string; duration?: number
  image?: string; title?: string; subtitle?: string; type?: string
  banner?: string; affiche?: string;
}

interface Notif extends Required<Pick<NotifData, 'color' | 'duration'>> {
  id: number; type: 'simple' | 'advanced' | 'weazel'
  text?: string; icon?: string; image?: string; title?: string; subtitle?: string
  banner?: string; affiche?: string
}

let _nid = 0
const stripGta = (t: string) => t.replace(/~\w+~/g, '').trim()

function makeNotif(d: NotifData, type: Notif['type']): Notif {
  const rawText = d.text ?? d.msg
  const dur = d.duration ?? (type === 'advanced' ? 8 : type === 'weazel' ? 10 : 5)
  return {
    id: ++_nid, type,
    color:    d.color ?? (d.type && TYPE_COLORS[d.type]) ?? 'rgba(147,51,234,0.85)',
    duration: dur,
    text:     rawText ? stripGta(rawText) : undefined,
    icon: d.icon, image: d.image, title: d.title, subtitle: d.subtitle,
    banner: d.banner, affiche: d.affiche,
  }
}

function NotifItem({ notif, onDone }: { notif: Notif; onDone: () => void }) {
  const [leaving, setLeaving] = useState(false)
  const onDoneRef  = useRef(onDone)
  const leavingRef = useRef(false)
  useEffect(() => { onDoneRef.current = onDone }, [onDone])

  const dismiss = useCallback(() => {
    if (leavingRef.current) return
    leavingRef.current = true
    setLeaving(true)
    setTimeout(() => onDoneRef.current(), 320)
  }, [])

  useEffect(() => {
    const t = setTimeout(dismiss, notif.duration * 1000)
    return () => clearTimeout(t)
  }, [notif.id, notif.duration, dismiss])

  const anim   = leaving ? 'notifOut 0.5s ease forwards' : 'notifIn 0.5s ease forwards'
  const durStr = `${notif.duration}s`

  return (
    <div className={s.notif} style={{ ['--nc' as string]: notif.color, animation: anim }} onClick={dismiss}>
      {notif.type === 'simple' && (
        notif.icon ? (
          <div className={s.notifBody}>
            <div className={s.notifIconWrap}><i className={`bi ${notif.icon} ${s.notifIcon}`} /></div>
            <span className={s.notifText}>{notif.text}</span>
          </div>
        ) : (
          <div className={s.notifBodyBasic}><span className={s.notifText}>{notif.text}</span></div>
        )
      )}
      {notif.type === 'advanced' && (() => {
        const imgSrc = resolveNotifImage(notif.image)
        return (
          <div className={s.notifBodyAdv}>
            <div className={s.notifAdvTop}>
              {imgSrc && <img className={s.notifImg} src={imgSrc} alt="" />}
              <div className={s.notifAdvHeader}>
                {notif.title    && <span className={s.notifTitle}>{notif.title}</span>}
                {notif.subtitle && <span className={s.notifSubtitle}>{notif.subtitle}</span>}
              </div>
            </div>
            {notif.text && <span className={s.notifAdvText}>{notif.text}</span>}
          </div>
        )
      })()}
      {notif.type === 'weazel' && (() => {
        const bannerSrc  = resolveNotifImage(notif.banner)
        const afficheSrc = resolveNotifImage(notif.affiche)
        return (
          <div className={s.notifWeazel}>
            <div className={s.notifWeazelContent}>
              {bannerSrc  && <img className={s.notifWeazelBanner}  src={bannerSrc}  alt="" />}
              {afficheSrc && <img className={s.notifWeazelAffiche} src={afficheSrc} alt="" />}
              <div className={s.notifWeazelBar}>
                {notif.text && <span className={s.notifWeazelBarText}>{notif.text}</span>}
              </div>
            </div>
          </div>
        )
      })()}
      <div className={s.notifTimer}>
        <div className={s.notifTimerBar} style={{ ['--notif-dur' as string]: durStr }} />
      </div>
    </div>
  )
}

export function NotificationStack() {
  const [notifs, setNotifs] = useState<Notif[]>([])
  const dismiss = useCallback((id: number) => setNotifs(p => p.filter(n => n.id !== id)), [])

  useEffect(() => {
    const add = (n: Notif) => setNotifs(p => [...p.slice(-4), n])
    const u1 = onNUI<NotifData>('epsilon:notify',         d => add(makeNotif(d, 'simple')))
    const u2 = onNUI<NotifData>('epsilon:notifyAdvanced', d => add(makeNotif(d, 'advanced')))
    const u3 = onNUI<NotifData>('epsilon:notifyWeazel',   d => add(makeNotif(d, 'weazel')))
    return () => { u1(); u2(); u3() }
  }, [])

  if (!notifs.length) return null
  return (
    <>
      <style>{NOTIF_ANIMS}</style>
      <div className={s.notifStack}>
        {notifs.map(n => <NotifItem key={n.id} notif={n} onDone={() => dismiss(n.id)} />)}
      </div>
    </>
  )
}

// ── Progress bar ───────────────────────────────────────────────

interface ProgressBarData { text?: string; duration?: number }

export function ProgressBar() {
  const [data, setData] = useState<ProgressBarData | null>(null)
  const [key, setKey] = useState(0)

  useEffect(() => {
    const u1 = onNUI<ProgressBarData>('epsilon:progressBar',     d => { setData(d); setKey(k => k + 1) })
    const u2 = onNUI<void>           ('epsilon:progressBarHide', () => setData(null))
    return () => { u1(); u2() }
  }, [])

  if (!data) return null
  const dur = `${data.duration ?? 5}s`
  return (
    <div className={s.progressBarWrap} key={key}>
      {data.text && <div className={s.progressBarText}>{data.text}</div>}
      <div className={s.progressBarContainer}>
        <div className={s.progressBarFill} style={{ ['--pb-dur' as string]: dur }} />
      </div>
    </div>
  )
}

// ── Keyboard input ─────────────────────────────────────────────

interface KeyboardInputData { title?: string; placeholder?: string; icon?: string; defaultVal?: string }

export function KeyboardInput() {
  const [data, setData]   = useState<KeyboardInputData | null>(null)
  const [value, setValue] = useState('')

  useEffect(() => {
    const u1 = onNUI<KeyboardInputData>('epsilon:keyboardInput', d => { setData(d); setValue(d.defaultVal ?? '') })
    return () => { u1() }
  }, [])

  const confirm = () => { nuiPost('keyboardInputDone', { value });       setData(null) }
  const cancel  = () => { nuiPost('keyboardInputDone', { value: null }); setData(null) }

  if (!data) return null
  return (
    <div className={s.dialogOverlay}>
      <div className={s.dialogBox}>
        <div className={s.dialogHeader}>
          {data.icon && <i className={`bi ${data.icon} ${s.dialogHeaderIcon}`} style={{ fontSize: 15 }} />}
          <p className={s.dialogTitle}>{data.title ?? 'Saisie'}</p>
        </div>
        <input
          className={s.dialogInput}
          autoFocus
          placeholder={data.placeholder ?? ''}
          value={value}
          onChange={e => setValue(e.target.value)}
          onKeyDown={e => { if (e.key === 'Enter') confirm(); if (e.key === 'Escape') cancel() }}
        />
      </div>
    </div>
  )
}

// ── Choice input ───────────────────────────────────────────────

interface ChoiceOption { label: string; value?: string; color?: string }
interface ChoiceInputData { title?: string; icon?: string; options: ChoiceOption[] }

export function ChoiceInput() {
  const [data, setData] = useState<ChoiceInputData | null>(null)

  useEffect(() => {
    const u1 = onNUI<ChoiceInputData>('epsilon:choiceInput', d => setData(d))
    return () => { u1() }
  }, [])

  const pick = (val: string | null) => { nuiPost('choiceInputDone', { value: val }); setData(null) }

  if (!data) return null
  return (
    <div className={s.dialogOverlay}>
      <div className={s.dialogBox}>
        <div className={s.dialogHeader}>
          {data.icon && <i className={`bi ${data.icon}`} style={{ fontSize: 15, color: '#fff' }} />}
          <p className={s.dialogTitle}>{data.title ?? 'Choix'}</p>
        </div>
        <div className={s.dialogButtons}>
          {data.options.map((opt, i) => (
            <button
              key={i}
              className={`${s.dialogBtn} ${s.dialogBtnGreen}`}
              style={opt.color ? { background: opt.color } : undefined}
              onClick={() => pick(opt.value ?? opt.label)}
            >
              {opt.label}
            </button>
          ))}
          <button className={`${s.dialogBtn} ${s.dialogBtnRed}`} onClick={() => pick(null)}>Annuler</button>
        </div>
      </div>
    </div>
  )
}

// ── Help notification ──────────────────────────────────────────

export function HelpNotification() {
  const [text, setText]     = useState<string | null>(null)
  const [leaving, setLeaving] = useState(false)
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null)

  const hide = useCallback(() => {
    setLeaving(true)
    setTimeout(() => { setText(null); setLeaving(false) }, 500)
  }, [])

  useEffect(() => {
    const u1 = onNUI<{ text: string; duration?: number }>('epsilon:helpNotif', d => {
      if (timerRef.current) clearTimeout(timerRef.current)
      setLeaving(false); setText(d.text)
      if (d.duration) timerRef.current = setTimeout(hide, d.duration * 1000)
    })
    const u2 = onNUI<void>('epsilon:helpNotifHide', hide)
    return () => { u1(); u2() }
  }, [hide])

  if (!text) return null
  const wrapClass = leaving ? `${s.helpNotifWrap} ${s.helpNotifWrapOut}` : s.helpNotifWrap
  const formatted = text.replace(/\[([^\]]+)\]/g, `<span class="${s.helpKey}">$1</span>`)
  return (
    <div className={wrapClass}>
      <div className={s.helpNotif}>
        <p className={s.helpText} dangerouslySetInnerHTML={{ __html: formatted }} />
      </div>
    </div>
  )
}

// ── Instructional buttons ──────────────────────────────────────

interface InstructionalBtn { key: string; action: string }

export function InstructionalButtons() {
  const [btns, setBtns] = useState<InstructionalBtn[]>([])

  useEffect(() => {
    const u1 = onNUI<{ show: boolean; buttons?: InstructionalBtn[] }>('epsilon:instructionalButtons', d => {
      setBtns(d.show ? (d.buttons ?? []) : [])
    })
    return u1
  }, [])

  if (!btns.length) return null
  return (
    <div className={s.instructionalWrap}>
      {btns.map((b, i) => (
        <div key={i} className={s.instructionalBtn}>
          <span className={s.instructionalAction}>{b.action}</span>
          <p className={s.instructionalKey}>{b.key}</p>
        </div>
      ))}
    </div>
  )
}
