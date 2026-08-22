import { useState, useEffect, useCallback, useRef } from 'react'
import { nuiPost, onNUI } from '../../hooks/useNUI'
import s from './Admin.module.css'
import AdminItems from '../Inventory/AdminItems'
import AdminLogs from './AdminLogs'
import AdminEconomy from './AdminEconomy'

export interface GradePerms {
  perm_players: boolean; perm_teleport: boolean; perm_spectate: boolean
  perm_health: boolean;  perm_effects: boolean;  perm_vehicle: boolean
  perm_sanctions: boolean; perm_message: boolean; perm_weather: boolean
  perm_announce: boolean; perm_tools: boolean;   perm_grades: boolean
}

export interface GradeData {
  id: number; name: string; label: string; color: string
  perms: GradePerms
}

export interface AdminData {
  rank?: string
  grade?: GradeData
  weather?: string
  nextWeather?: string
  hour?: number
  minute?: number
  freezeTime?: boolean
  freezeWeather?: boolean
  tools?: Record<string, boolean>
  myLicense?: string
  myName?: string
}

interface Player {
  id: number; name: string; ping: number
  x: number; y: number; z: number
  licenses?: string[]
  frozen?: boolean; onFire?: boolean; caged?: boolean; vehicleFrozen?: boolean; inVehicle?: boolean
  gradeId?: number; gradeLabel?: string; gradeColor?: string
}

type Tab = 'joueurs' | 'serveur' | 'outils' | 'reports'

interface ReportItem {
  id: number
  type: 'report' | 'signalement'
  player_id: number
  player_name: string
  category: string
  target_name: string
  description: string
  status: 'open' | 'in_progress' | 'closed'
  created_at: string
  assigned_name?: string
  assigned_license?: string
  assigned_at?: string
  closed_by_name?: string
  closed_at?: string
  collaborators?: string
  player_license?: string
}

function toDate(v: unknown): Date | null {
  if (!v) return null
  if (v instanceof Date) return v
  const d = new Date(v as string | number)
  return isNaN(d.getTime()) ? null : d
}

function fmtDate(v: unknown) {
  const d = toDate(v)
  if (!d) return null
  return d.toLocaleString('fr-FR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' })
}

function diffMins(a: unknown, b: unknown) {
  const da = toDate(a), db = toDate(b)
  if (!da || !db) return null
  const m = Math.floor((db.getTime() - da.getTime()) / 60000)
  if (m < 0) return null
  if (m < 60) return `${m}min`
  const h = Math.floor(m / 60), rm = m % 60
  return rm > 0 ? `${h}h${rm}min` : `${h}h`
}

const REPORT_CAT_LABELS: Record<string, string> = {
  bug: 'Bug / Erreur', suggestion: 'Suggestion', question: 'Question',
  triche: 'Triche', comportement: 'Comportement', harcelement: 'Harcèlement', autre: 'Autre',
}
type SanctionType = 'warn' | 'kick' | 'ban' | 'msg' | 'spawn'

const PERMISSIONS: { key: keyof GradePerms; label: string; icon: string }[] = [
  { key: 'perm_players',   label: 'Voir les joueurs',    icon: 'bi-people-fill' },
  { key: 'perm_teleport',  label: 'Téléportation',       icon: 'bi-crosshair' },
  { key: 'perm_spectate',  label: 'Spectate',            icon: 'bi-eye-fill' },
  { key: 'perm_health',    label: 'Santé joueur',        icon: 'bi-heart-pulse-fill' },
  { key: 'perm_effects',   label: 'Effets',              icon: 'bi-fire' },
  { key: 'perm_vehicle',   label: 'Véhicule',            icon: 'bi-car-front-fill' },
  { key: 'perm_sanctions', label: 'Sanctions',           icon: 'bi-hammer' },
  { key: 'perm_message',   label: 'Message direct',      icon: 'bi-chat-dots-fill' },
  { key: 'perm_weather',   label: 'Météo & Heure',       icon: 'bi-cloud-sun-fill' },
  { key: 'perm_announce',  label: 'Annonce globale',     icon: 'bi-megaphone-fill' },
  { key: 'perm_tools',     label: 'Outils perso',        icon: 'bi-tools' },
  { key: 'perm_grades',    label: 'Gestion des grades',  icon: 'bi-shield-lock-fill' },
]

const DEFAULT_PERMS: GradePerms = {
  perm_players: true, perm_teleport: false, perm_spectate: false,
  perm_health: false, perm_effects: false, perm_vehicle: false,
  perm_sanctions: false, perm_message: false, perm_weather: false,
  perm_announce: false, perm_tools: false, perm_grades: false,
}

const WEATHERS = [
  { key: 'EXTRASUNNY', label: 'Ensoleillé',  icon: 'bi-sun-fill' },
  { key: 'CLEAR',      label: 'Dégagé',      icon: 'bi-cloud-sun' },
  { key: 'CLOUDS',     label: 'Nuageux',     icon: 'bi-cloud' },
  { key: 'OVERCAST',   label: 'Couvert',     icon: 'bi-clouds-fill' },
  { key: 'RAIN',       label: 'Pluie',       icon: 'bi-cloud-rain-heavy' },
  { key: 'THUNDER',    label: 'Orage',       icon: 'bi-cloud-lightning-rain-fill' },
  { key: 'FOGGY',      label: 'Brouillard',  icon: 'bi-cloud-fog2' },
  { key: 'SMOG',       label: 'Smog',        icon: 'bi-cloud-haze2' },
  { key: 'XMAS',       label: 'Neige',       icon: 'bi-snow' },
]

const DURATIONS = [
  { value: 5,  label: '5 secondes' },
  { value: 10, label: '10 secondes' },
  { value: 15, label: '15 secondes' },
  { value: 30, label: '30 secondes' },
  { value: 60, label: '1 minute' },
]

const TOOLS_VISIBILITY = [
  { key: 'showNames', nui: 'admin:toggleShowNames', icon: 'bi-person-badge-fill', label: 'Afficher les noms',  desc: 'Noms et ID au-dessus des joueurs' },
  { key: 'showBlips', nui: 'admin:toggleShowBlips', icon: 'bi-geo-alt-fill',      label: 'Afficher les blips', desc: 'Blips de tous les joueurs sur la map' },
]
const TOOLS_CAPACITES = [
  { key: 'noclip',       nui: 'admin:toggleNoclip',       icon: 'bi-arrows-move',        label: 'No-Clip',         desc: 'Traverser les obstacles' },
  { key: 'god',          nui: 'admin:toggleGod',           icon: 'bi-shield-fill',        label: 'God Mode',        desc: 'Invincibilité totale' },
  { key: 'ghost',        nui: 'admin:toggleGhost',         icon: 'bi-eye-slash-fill',     label: 'Ghost Mode',      desc: 'Invisible pour les autres' },
  { key: 'sprint',       nui: 'admin:toggleSuperSprint',   icon: 'bi-lightning-fill',     label: 'Super Sprint',    desc: 'Vitesse de course augmentée' },
  { key: 'jump',         nui: 'admin:toggleSuperJump',     icon: 'bi-chevron-double-up',  label: 'Super Jump',      desc: 'Saut amplifié' },
  { key: 'swim',         nui: 'admin:toggleSuperSwim',     icon: 'bi-water',              label: 'Super Swim',      desc: 'Nage rapide' },
  { key: 'stamina',      nui: 'admin:toggleStamina',       icon: 'bi-battery-full',       label: 'Stamina Infinie', desc: 'Pas de fatigue' },
  { key: 'statusPaused', nui: 'admin:togglePauseStatus',   icon: 'bi-pause-circle-fill',  label: 'Pause besoins',   desc: 'Stoppe la perte de faim/soif' },
]
const TOOLS_SANTE = [
  { nui: 'admin:selfHealHealth',  icon: 'bi-heart-fill',      label: 'Heal vie',     warn: false, danger: false },
  { nui: 'admin:selfHealArmour',  icon: 'bi-shield-fill',     label: 'Heal armure',  warn: false, danger: false },
  { nui: 'admin:selfRevive',      icon: 'bi-activity',        label: 'Revive',       warn: false, danger: false },
  { nui: 'admin:selfDamage',      icon: 'bi-heartbreak-fill', label: 'Dégâts −10',   warn: true,  danger: false },
  { nui: 'admin:suicide',         icon: 'bi-x-circle-fill',   label: 'Suicide',      warn: false, danger: true  },
]
const TOOLS_STATUS = [
  { nui: 'admin:selfFillHunger',  icon: 'bi-egg-fried',      label: 'Remplir faim',  warn: false, danger: false },
  { nui: 'admin:selfFillThirst',  icon: 'bi-droplet-fill',   label: 'Remplir soif',  warn: false, danger: false },
  { nui: 'admin:selfDrainHunger', icon: 'bi-egg-fried',      label: 'Vider faim −10',warn: true,  danger: false },
  { nui: 'admin:selfDrainThirst', icon: 'bi-droplet-fill',   label: 'Vider soif −10',warn: true,  danger: false },
]

interface ItemEntry { name: string; label: string }

interface PInvItem {
  id: number; name: string; label: string; quantity: number; image?: string
  category: string
  idata?: { type?: string; category?: string }
  data?: { serial?: string; serialErased?: boolean }
}
interface PInv { items: PInvItem[]; weapons: PInvItem[]; keys: PInvItem[] }

function GiveItemPicker({ onGive, label = 'Donner' }: {
  onGive: (itemName: string, qty: number) => void
  label?: string
}) {
  const [search, setSearch] = useState('')
  const [qty, setQty] = useState(1)
  const [open, setOpen] = useState(false)
  const [chosen, setChosen] = useState<ItemEntry | null>(null)
  const [items, setItems] = useState<ItemEntry[]>([])
  const wrapRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const off = onNUI<{ name: string; label: string; data?: string }[]>('epsilon:inventory:admin:itemsList', raw => {
      setItems(raw.map(r => ({ name: r.name, label: r.label })))
    })
    nuiPost('inventory:admin:getItems', {})
    return off
  }, [])

  useEffect(() => {
    if (!open) return
    const handler = (e: MouseEvent) => {
      if (wrapRef.current && !wrapRef.current.contains(e.target as Node)) setOpen(false)
    }
    document.addEventListener('mousedown', handler)
    return () => document.removeEventListener('mousedown', handler)
  }, [open])

  const filtered = search
    ? items.filter(i => i.label.toLowerCase().includes(search.toLowerCase()) || i.name.includes(search.toLowerCase()))
    : items

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
      <div className={s.psWrap} ref={wrapRef}>
        <button
          className={`${s.psTrigger}${open ? ' ' + s.psTriggerOpen : ''}${chosen ? ' ' + s.psTriggerFilled : ''}`}
          onClick={() => setOpen(o => !o)}
        >
          <span>{chosen ? chosen.label : 'Sélectionner un item'}</span>
          {chosen && <span style={{ fontSize: 8, color: '#666670', marginLeft: 4 }}>{chosen.name}</span>}
          <i className={`bi bi-chevron-${open ? 'up' : 'down'}`} style={{ marginLeft: 'auto' }} />
        </button>
        {open && (
          <div className={s.psMenu}>
            <div className={s.psSearch}>
              <input autoFocus className={s.psSearchInput} value={search}
                onChange={e => setSearch(e.target.value)} placeholder="Nom ou spawn…" />
            </div>
            <div className={s.psList}>
              {filtered.length === 0
                ? <div className={s.psEmpty}>Aucun item</div>
                : filtered.slice(0, 50).map(i => (
                  <div key={i.name}
                    className={`${s.psItem}${chosen?.name === i.name ? ' ' + s.psItemActive : ''}`}
                    onClick={() => { setChosen(i); setOpen(false); setSearch('') }}
                  >
                    <span>{i.label}</span>
                    <span className={s.psItemId}>{i.name}</span>
                  </div>
                ))
              }
            </div>
          </div>
        )}
      </div>
      <div style={{ display: 'flex', gap: 6 }}>
        <input
          className={s.input} type="number" min={1} max={999} value={qty}
          onChange={e => setQty(Math.max(1, parseInt(e.target.value) || 1))}
          style={{ width: 70, flexShrink: 0 }}
          placeholder="Qté"
        />
        <button
          className={`${s.btn} ${s.btnGreen}`}
          style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6 }}
          disabled={!chosen}
          onClick={() => { if (chosen) { onGive(chosen.name, qty); setChosen(null); setQty(1) } }}
        >
          <i className="bi bi-gift" /> {label}
        </button>
      </div>
    </div>
  )
}

function PlayerSelect({
  players, value, onChange, placeholder = 'Ajouter un collaborateur'
}: {
  players: Player[]
  value: number | ''
  onChange: (id: number | '') => void
  placeholder?: string
}) {
  const [open, setOpen] = useState(false)
  const [search, setSearch] = useState('')
  const wrapRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!open) return
    const handler = (e: MouseEvent) => {
      if (wrapRef.current && !wrapRef.current.contains(e.target as Node)) {
        setOpen(false); setSearch('')
      }
    }
    document.addEventListener('mousedown', handler)
    return () => document.removeEventListener('mousedown', handler)
  }, [open])

  const selected = players.find(p => p.id === value)
  const list = search
    ? players.filter(p => p.name.toLowerCase().includes(search.toLowerCase()) || String(p.id).includes(search))
    : players

  return (
    <div className={s.psWrap} ref={wrapRef}>
      <button
        className={`${s.psTrigger}${open ? ' ' + s.psTriggerOpen : ''}${selected ? ' ' + s.psTriggerFilled : ''}`}
        onClick={() => setOpen(o => !o)}
      >
        <span>{selected ? selected.name : placeholder}</span>
        {selected && <span style={{ fontSize: 8, color: '#666670', marginLeft: 4 }}>#{selected.id}</span>}
        <i className={`bi bi-chevron-${open ? 'up' : 'down'}`} style={{ marginLeft: 'auto' }} />
      </button>

      {open && (
        <div className={s.psMenu}>
          <div className={s.psSearch}>
            <input
              autoFocus
              className={s.psSearchInput}
              value={search}
              onChange={e => setSearch(e.target.value)}
              placeholder="Nom ou ID…"
            />
          </div>
          <div className={s.psList}>
            {list.length === 0
              ? <div className={s.psEmpty}>Aucun joueur</div>
              : list.map(p => (
                <div
                  key={p.id}
                  className={`${s.psItem}${value === p.id ? ' ' + s.psItemActive : ''}`}
                  onClick={() => { onChange(p.id); setOpen(false); setSearch('') }}
                >
                  <span>{p.name}</span>
                  <span className={s.psItemId}>#{p.id}</span>
                </div>
              ))
            }
          </div>
        </div>
      )}
    </div>
  )
}

function GradeForm({
  grade, onChange, onSave, onCancel, onDelete, isNew
}: {
  grade: GradeData
  onChange: (g: GradeData) => void
  onSave: () => void
  onCancel: () => void
  onDelete?: () => void
  isNew?: boolean
}) {
  return (
    <div className={s.gradeForm}>
      <div className={s.gradeFormRow}>
        {isNew && (
          <div className={s.field} style={{ flex: 1 }}>
            <label>Identifiant (slug)</label>
            <input
              className={s.input}
              value={grade.name}
              onChange={e => onChange({ ...grade, name: e.target.value.toLowerCase().replace(/[^a-z0-9_]/g, '') })}
              placeholder="mon_grade"
            />
          </div>
        )}
        <div className={s.field} style={{ flex: 2 }}>
          <label>Label affiché</label>
          <input className={s.input} value={grade.label} onChange={e => onChange({ ...grade, label: e.target.value })} placeholder="Ex: Modérateur" />
        </div>
        <div className={s.field} style={{ flexShrink: 0 }}>
          <label>Couleur</label>
          <div className={s.colorRow}>
            <input
              type="color" value={grade.color}
              onChange={e => onChange({ ...grade, color: e.target.value })}
              className={s.colorPicker}
            />
            <span className={s.colorHex} style={{ color: grade.color }}>{grade.color}</span>
          </div>
        </div>
      </div>

      <div className={s.slabel}>Permissions</div>
      <div className={s.permGrid}>
        {PERMISSIONS.map(p => (
          <button
            key={p.key}
            className={`${s.permBtn}${grade.perms[p.key] ? ' ' + s.permBtnOn : ''}`}
            onClick={() => onChange({ ...grade, perms: { ...grade.perms, [p.key]: !grade.perms[p.key] } })}
          >
            <i className={`bi ${p.icon}`} />
            <span>{p.label}</span>
            <span className={s.permLed} />
          </button>
        ))}
      </div>

      <div className={s.gradeFormBtns}>
        {onDelete && (
          <button className={`${s.btn} ${s.btnRed}`} style={{ flex: 1 }} onClick={onDelete}>
            <i className="bi bi-trash3-fill" /> Supprimer
          </button>
        )}
        <button className={`${s.btn} ${s.btnGray}`} style={{ flex: 1 }} onClick={onCancel}>Annuler</button>
        <button className={`${s.btn} ${s.btnGreen}`} style={{ flex: 2 }} onClick={onSave}>
          <i className="bi bi-check2" /> Sauvegarder
        </button>
      </div>
    </div>
  )
}

export default function Admin({ data }: { data: AdminData }) {
  const [tab,    setTab]    = useState<Tab>('joueurs')
  const [_rank,  setRank]   = useState(data.rank ?? 'Admin')
  const [players, setPlayers] = useState<Player[]>([])
  const [search,  setSearch]  = useState('')
  const [selected, setSelected] = useState<Player | null>(null)
  const [sanction, setSanction] = useState<SanctionType | null>(null)
  const [reason,   setReason]   = useState('')
  const [duration, setDuration] = useState('')
  const [weather,       setWeatherKey]    = useState(data.weather      ?? 'EXTRASUNNY')
  const [nextWeather,   setNextWeather]   = useState(data.nextWeather  ?? 'EXTRASUNNY')
  const [hour,          setHour]          = useState(data.hour         ?? 12)
  const [minute,        setMinute]        = useState(data.minute       ?? 0)
  const [liveHour,      setLiveHour]      = useState(data.hour         ?? 12)
  const [liveMinute,    setLiveMinute]    = useState(data.minute       ?? 0)
  const [freezeTime,    setFreezeTime]    = useState(data.freezeTime   ?? false)
  const [freezeWeather, setFreezeWeather] = useState(data.freezeWeather ?? false)
  const [annStaff,    setAnnStaff]    = useState('')
  const [annMsg,      setAnnMsg]      = useState('')
  const [annDuration, setAnnDuration] = useState(10)
  const [showItemsMgr,  setShowItemsMgr]  = useState(false)
  const [showLogs,      setShowLogs]      = useState(false)
  const [showEconomy,   setShowEconomy]   = useState(false)
  const [annDurOpen,  setAnnDurOpen]  = useState(false)
  const [openSections, setOpenSections] = useState<Set<string>>(new Set(['meteo']))
  const toggleSection = (key: string) =>
    setOpenSections(prev => {
      const next = new Set(prev)
      if (next.has(key)) { next.delete(key) }
      else {
        next.add(key)
        if (key === 'outil_vehicule') nuiPost('admin:getVehicleInfo', {})
      }
      return next
    })
  const [tools, setTools] = useState<Record<string, boolean>>(
    data.tools ?? Object.fromEntries(
      [...TOOLS_VISIBILITY, ...TOOLS_CAPACITES].map(t => [t.key, false])
    )
  )
  const [tpX, setTpX] = useState(''); const [tpY, setTpY] = useState(''); const [tpZ, setTpZ] = useState('')

  // Véhicule
  interface VehInfo { inVehicle: boolean; model?: string; plate?: string; engineHealth?: number; bodyHealth?: number; fuelLevel?: number; dirtLevel?: number }
  const [massRadius, setMassRadius] = useState(100)
  const [vehInfo,    setVehInfo]    = useState<VehInfo | null>(null)
  const [plateInput, setPlateInput] = useState('')
  const [spawnModel, setSpawnModel] = useState('')
  const [vehFrozen,  setVehFrozen]  = useState(false)
  const [copied, setCopied] = useState<string | null>(null)
  const [myGrade,     setMyGrade]     = useState<GradeData | null>(data.grade ?? null)
  const [grades,      setGrades]      = useState<GradeData[]>([])
  const [editGrade,   setEditGrade]   = useState<GradeData | null>(null)
  const [expandedGrade, setExpandedGrade] = useState<number | null>(null)
  const [reports,        setReports]        = useState<ReportItem[]>([])
  const [reportFilter,   setReportFilter]   = useState<'all' | 'open' | 'in_progress' | 'closed'>('open')
  const [expandedReport,   setExpandedReport]   = useState<number | null>(null)
  const [myLicense,        setMyLicense]        = useState(data.myLicense ?? '')
  const [myName]                               = useState(data.myName ?? '')
  const [addCollabTarget,  setAddCollabTarget]  = useState<Record<number, number | ''>>({})

  // ── Jobs state ──
  interface JobGrade { grade: number; label: string }
  interface JobDef   { id: number; name: string; label: string; grades: JobGrade[] }
  interface PlayerJob { name: string; label: string; grade: number; gradeLabel: string }
  const [jobsList,     setJobsList]     = useState<JobDef[]>([])
  const [playerJobs,   setPlayerJobs]   = useState<Record<number, { charId?: number; jobs: PlayerJob[] }>>({})
  const [jobPick,      setJobPick]      = useState<JobDef | null>(null)
  const [jobGradePick, setJobGradePick] = useState<JobGrade | null>(null)
  const [jobOpen,      setJobOpen]      = useState(false)
  const [gradeOpen,    setGradeOpen]    = useState(false)
  const [jobSearch,    setJobSearch]    = useState('')
  const jobWrapRef   = useRef<HTMLDivElement>(null)
  const gradeWrapRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!jobOpen) return
    const h = (e: MouseEvent) => { if (!jobWrapRef.current?.contains(e.target as Node)) setJobOpen(false) }
    document.addEventListener('mousedown', h)
    return () => document.removeEventListener('mousedown', h)
  }, [jobOpen])

  useEffect(() => {
    if (!gradeOpen) return
    const h = (e: MouseEvent) => { if (!gradeWrapRef.current?.contains(e.target as Node)) setGradeOpen(false) }
    document.addEventListener('mousedown', h)
    return () => document.removeEventListener('mousedown', h)
  }, [gradeOpen])

  const [playerInv,     setPlayerInv]     = useState<PInv | null>(null)
  const [playerInvLoad, setPlayerInvLoad] = useState(false)
  const [pinvTab,       setPinvTab]       = useState<'items' | 'weapons' | 'keys'>('items')
  const [removeQty,     setRemoveQty]     = useState<Record<number, number>>({})

  const copyText = (text: string) => {
    try {
      const el = document.createElement('textarea')
      el.value = text
      el.style.cssText = 'position:fixed;opacity:0;pointer-events:none'
      document.body.appendChild(el)
      el.select()
      document.execCommand('copy')
      document.body.removeChild(el)
    } catch { /* silently fail */ }
    setCopied(text)
    setTimeout(() => setCopied(null), 1500)
  }

  useEffect(() => {
    interface ServerState { weather?: string; nextWeather?: string; hour?: number; minute?: number; freezeTime?: boolean; freezeWeather?: boolean }
    const offs = [
      onNUI<{ rank: string }>('epsilon:admin:setRank', d => setRank(d.rank)),
      onNUI<{ players: Player[] }>('epsilon:admin:playersList', d => setPlayers(d.players ?? [])),
      onNUI<{ tool: string; state: boolean }>('epsilon:admin:toolState', d =>
        setTools(prev => ({ ...prev, [d.tool]: d.state }))),
      onNUI<{ id: number; frozen: boolean }>('epsilon:admin:freezeState', d => {
        setPlayers(prev => prev.map(p => p.id === d.id ? { ...p, frozen: d.frozen } : p))
        setSelected(prev => prev?.id === d.id ? { ...prev, frozen: d.frozen } : prev)
      }),
      onNUI<{ id: number; vehicleFrozen: boolean; inVehicle: boolean }>('epsilon:admin:vehicleFreezeState', d => {
        setPlayers(prev => prev.map(p => p.id === d.id ? { ...p, vehicleFrozen: d.vehicleFrozen, inVehicle: d.inVehicle } : p))
        setSelected(prev => prev?.id === d.id ? { ...prev, vehicleFrozen: d.vehicleFrozen, inVehicle: d.inVehicle } : prev)
      }),
      onNUI<GradeData>('epsilon:admin:gradeInfo', d => setMyGrade(d)),
      onNUI<{ grades: GradeData[] }>('epsilon:admin:gradesList', d => setGrades(d.grades ?? [])),
      onNUI<{ reports: ReportItem[] }>('epsilon:admin:reportsList', d => setReports(d.reports ?? [])),
      onNUI<{ report: ReportItem }>('epsilon:admin:newReport', d => {
        if (d.report) setReports(prev => [d.report, ...prev])
      }),
      onNUI<{ id: number; collaborators?: string; collab_name?: string }>('epsilon:admin:reportUpdate', d => {
        setReports(prev => prev.map(r => r.id === d.id ? { ...r, collaborators: d.collaborators } : r))
      }),
      onNUI<{ myLicense: string }>('epsilon:admin:setLicense', d => {
        if (d.myLicense) setMyLicense(d.myLicense)
      }),
      onNUI<ServerState>('epsilon:admin:serverState', d => {
        if (d.weather       !== undefined) setWeatherKey(d.weather)
        if (d.nextWeather   !== undefined) setNextWeather(d.nextWeather)
        if (d.hour          !== undefined) { setHour(d.hour);     setLiveHour(d.hour) }
        if (d.minute        !== undefined) { setMinute(d.minute); setLiveMinute(d.minute) }
        if (d.freezeTime    !== undefined) setFreezeTime(d.freezeTime)
        if (d.freezeWeather !== undefined) setFreezeWeather(d.freezeWeather)
      }),
      onNUI<{ hour: number; minute: number }>('epsilon:admin:liveTime', d => {
        setLiveHour(d.hour)
        setLiveMinute(d.minute)
        // Update sliders too unless time is frozen — read current state without stale closure
        setFreezeTime(frozen => {
          if (!frozen) { setHour(d.hour); setMinute(d.minute) }
          return frozen
        })
      }),
      onNUI<{ info: VehInfo & { frozen?: boolean } }>('epsilon:admin:vehicleInfo', d => {
        setVehInfo(d.info)
        if (d.info.frozen !== undefined) setVehFrozen(d.info.frozen)
      }),
      onNUI<PInv | null>('epsilon:admin:playerInventory', d => {
        setPlayerInv(d)
        setPlayerInvLoad(false)
      }),
      onNUI<{ jobs: JobDef[] }>('epsilon:admin:jobsList', d => setJobsList(d.jobs ?? [])),
      onNUI<{ targetId: number; charId?: number; jobs: PlayerJob[] }>('epsilon:admin:playerJobs', d => {
        setPlayerJobs(prev => ({ ...prev, [d.targetId]: { charId: d.charId, jobs: d.jobs } }))
      }),
    ]
    nuiPost('admin:getPlayers', {})
    nuiPost('admin:getJobs', {})
    nuiPost('admin:getReports', { status: 'all' })
    if (data.grade?.perms.perm_grades) nuiPost('admin:getGrades', {})
    const poll = setInterval(() => nuiPost('admin:getPlayers', {}), 5000)
    return () => { offs.forEach(f => f()); clearInterval(poll) }
  }, [])

  // Charger l'inventaire et les jobs du joueur sélectionné
  useEffect(() => {
    if (!selected) { setPlayerInv(null); setJobPick(null); return }
    setPlayerInvLoad(true)
    setPlayerInv(null)
    setPinvTab('items')
    setJobPick(null)
    nuiPost('inventory:admin:getPlayerInventory', { targetSrc: selected.id })
    nuiPost('admin:getPlayerJobs', { id: selected.id })
  }, [selected?.id])

  // Polling état véhicule du joueur sélectionné
  useEffect(() => {
    if (!selected) return
    const id = setInterval(() => nuiPost('admin:queryPlayerVehicleFreezeState', { id: selected.id }), 2000)
    return () => clearInterval(id)
  }, [selected?.id])

  // Polling temps réel des infos véhicule quand la section est ouverte
  const vehiculeOpen = openSections.has('outil_vehicule')
  useEffect(() => {
    if (!vehiculeOpen) return
    nuiPost('admin:getVehicleInfo', {})
    const id = setInterval(() => nuiPost('admin:getVehicleInfo', {}), 1000)
    return () => clearInterval(id)
  }, [vehiculeOpen])

  const [coords, setCoords] = useState<{ x: number; y: number; z: number; h: number } | null>(null)
  const coordsOpen = tab === 'outils' && openSections.has('outil_coords')
  useEffect(() => {
    if (!coordsOpen) return
    nuiPost('admin:devGetCoords', {}).then((d: any) => d && setCoords(d))
    const id = setInterval(() => nuiPost('admin:devGetCoords', {}).then((d: any) => d && setCoords(d)), 500)
    return () => clearInterval(id)
  }, [coordsOpen])

  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.key !== 'Escape') return
      e.preventDefault()
      if (sanction) { setSanction(null); setReason(''); setDuration('') }
      else if (selected) setSelected(null)
      else nuiPost('admin:close', {})
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [sanction, selected])

  const filtered = search
    ? players.filter(p => p.name.toLowerCase().includes(search.toLowerCase()) || String(p.id).includes(search))
    : players

  const pingCls = (ms: number) => ms < 80 ? s.pingG : ms < 150 ? s.pingO : s.pingR

  const paction = useCallback((type: string) => {
    if (!selected) return
    nuiPost(type, { id: selected.id })
    if (type === 'admin:freezePlayer') setSelected(p => p ? { ...p, frozen: !p.frozen } : p)
    else if (type === 'admin:toggleFire') setSelected(p => p ? { ...p, onFire: !p.onFire } : p)
    else if (type === 'admin:toggleCage') setSelected(p => p ? { ...p, caged: !p.caged } : p)
  }, [selected])

  const doSanction = () => {
    if (!selected || !sanction) return
    if (sanction === 'warn')       nuiPost('admin:warnPlayer',    { id: selected.id, reason })
    else if (sanction === 'kick')  nuiPost('admin:kick',          { id: selected.id, reason })
    else if (sanction === 'ban')   nuiPost('admin:ban',           { id: selected.id, reason, duration })
    else if (sanction === 'msg')   nuiPost('admin:sendMessage',   { id: selected.id, message: reason })
    else if (sanction === 'spawn') nuiPost('admin:spawnVehicleFor', { id: selected.id, model: reason.trim() })
    setSanction(null); setReason(''); setDuration('')
  }

  const applyTime = (fr = freezeTime) =>
    nuiPost('admin:setTime', { hour, minute, freeze: fr })

  if (showItemsMgr) {
    return <AdminItems onClose={() => setShowItemsMgr(false)} />
  }

  if (showLogs) {
    return <AdminLogs onClose={() => setShowLogs(false)} />
  }

  if (showEconomy) {
    return <AdminEconomy onClose={() => setShowEconomy(false)} />
  }

  return (
    <div className={s.panel}>

      {/* ── Header ── */}
      <div className={s.header}>
        <div className={s.banner} />
        <div className={s.tabs}>
          {(['joueurs', 'serveur', 'outils', 'reports'] as Tab[]).map(t => {
            const openCount = t === 'reports' ? reports.filter(r => r.status === 'open').length : 0
            return (
              <button
                key={t} className={`${s.tab}${tab === t ? ' ' + s.tabActive : ''}`}
                style={{ position: 'relative' }}
                onClick={() => {
                  setTab(t)
                  if (t === 'joueurs') nuiPost('admin:getPlayers', {})
                  if (t === 'reports') nuiPost('admin:getReports', { status: 'all' })
                }}
              >
                {t === 'reports' ? 'Reports' : t.charAt(0).toUpperCase() + t.slice(1)}
                {t === 'reports' && openCount > 0 && (
                  <span style={{
                    position: 'absolute', top: 6, right: 6,
                    background: '#ef4444', color: '#fff',
                    fontSize: 8, fontWeight: 700, borderRadius: 8,
                    padding: '1px 4px', lineHeight: 1.4,
                  }}>{openCount}</span>
                )}
              </button>
            )
          })}
        </div>
      </div>

      {/* ── JOUEURS — liste ── */}
      {tab === 'joueurs' && (
        <div className={s.pane}>
          <div className={s.scroll}>
            <div className={s.search}>
              <i className={`bi bi-search ${s.searchIcon}`} />
              <input className={s.searchInput} value={search} onChange={e => setSearch(e.target.value)} placeholder="Nom ou ID…" />
            </div>
            <div className={s.slabel}>Joueurs en ligne ({players.length})</div>
            {filtered.map(p => (
              <div key={p.id} className={s.playerCard} onClick={() => { setSelected({ ...p, vehicleFrozen: false }); nuiPost('admin:queryPlayerVehicleFreezeState', { id: p.id }) }}>
                <div className={s.pAvatar}>{p.name[0].toUpperCase()}</div>
                <div className={s.pInfo}>
                  <div className={s.pName}>{p.name}</div>
                  <div className={s.pSub}>
                    <span>#{p.id}</span>
                    <span className={`${s.pPing} ${pingCls(p.ping)}`}>{p.ping}ms</span>
                    <span>{p.x}, {p.y}, {p.z}</span>
                    {p.gradeLabel && (
                      <span className={s.pGrade} style={{ color: p.gradeColor ?? '#fff', borderColor: p.gradeColor ?? '#fff' }}>
                        {p.gradeLabel}
                      </span>
                    )}
                  </div>
                  {(p.frozen || p.onFire || p.caged) && (
                    <div className={s.badges}>
                      {p.frozen && <span className={`${s.badge} ${s.badgeFrozen}`}><i className="bi bi-snow" /> Gel</span>}
                      {p.onFire  && <span className={`${s.badge} ${s.badgeFire}`}><i className="bi bi-fire" /> Feu</span>}
                      {p.caged   && <span className={`${s.badge} ${s.badgeCaged}`}><i className="bi bi-lock-fill" /> Cage</span>}
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* ── JOUEURS — modal détail (sans backdrop) ── */}
      {selected && !sanction && (
        <div className={s.playerModal}>
          <div className={s.playerModalBox}>
            {/* Header */}
            <div className={s.detailHeader}>
              <div className={s.detailAvatar}>{selected.name[0].toUpperCase()}</div>
              <div className={s.detailMeta}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
                  <span className={s.detailName}>{selected.name}</span>
                  {selected.gradeLabel && (
                    <span className={s.detailGrade} style={{ color: selected.gradeColor ?? '#fff', borderColor: (selected.gradeColor ?? '#fff') + '55' }}>
                      {selected.gradeLabel}
                    </span>
                  )}
                </div>
                <span className={s.detailSub}>#{selected.id} · {selected.x}, {selected.y}, {selected.z} · <span className={pingCls(selected.ping)}>{selected.ping}ms</span></span>
              </div>
              <button className={s.closeBtn} onClick={() => setSelected(null)}><i className="bi bi-x-lg" /></button>
            </div>

            {/* Licences */}
            {selected.licenses && selected.licenses.length > 0 && (
              <div className={s.modalSection}>
                <div className={s.slabel}>Licences</div>
                <div className={s.licenseList}>
                  {selected.licenses.map(lic => (
                    <div key={lic} className={s.licenseRow}>
                      <span className={s.licenseVal}>{lic}</span>
                      <button
                        className={`${s.licenseBtn}${copied === lic ? ' ' + s.licenseBtnOk : ''}`}
                        onClick={() => copyText(lic)}
                      >
                        <i className={`bi ${copied === lic ? 'bi-check2' : 'bi-clipboard'}`} />
                      </button>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Communication + Déplacement */}
            <div className={s.modalSection}>
              <div className={s.slabel}>Communication</div>
              <div className={s.mbtnGrid}>
                <button className={s.mbtn} onClick={() => setSanction('msg')}><i className="bi bi-chat-dots-fill" />Message</button>
                <button className={s.mbtn} onClick={() => { nuiPost('admin:spectate', { id: selected.id }); setSelected(null) }}><i className="bi bi-eye-fill" />Spectate</button>
              </div>
              <div className={s.slabel}>Déplacement</div>
              <div className={s.mbtnGrid}>
                <button className={s.mbtn} onClick={() => paction('admin:teleportTo')}><i className="bi bi-crosshair" />TP vers</button>
                <button className={s.mbtn} onClick={() => paction('admin:bringPlayer')}><i className="bi bi-person-walking" />TP ici</button>
                <button className={s.mbtn} onClick={() => paction('admin:bringBack')}><i className="bi bi-arrow-return-left" />Bring Back</button>
              </div>
            </div>

            {/* Santé */}
            <div className={s.modalSection}>
              <div className={s.slabel}>Santé</div>
              <div className={s.mbtnGrid}>
                <button className={s.mbtn} onClick={() => paction('admin:healPlayer')}><i className="bi bi-heart-pulse-fill" />Heal vie</button>
                <button className={s.mbtn} onClick={() => nuiPost('admin:healArmour', { id: selected.id })}><i className="bi bi-shield-fill" />Heal armure</button>
                <button className={s.mbtn} onClick={() => paction('admin:revivePlayer')}><i className="bi bi-activity" />Revive</button>
                <button className={`${s.mbtn} ${s.mbtnWarn}`} onClick={() => nuiPost('admin:damagePlayer', { id: selected.id })}><i className="bi bi-heartbreak-fill" />Dégâts</button>
                <button className={`${s.mbtn} ${s.mbtnDanger}`} onClick={() => paction('admin:killPlayer')}><i className="bi bi-x-circle-fill" />Tuer</button>
              </div>
            </div>

            {/* Besoins */}
            <div className={s.modalSection}>
              <div className={s.slabel}>Besoins</div>
              <div className={s.mbtnGrid}>
                <button className={s.mbtn} onClick={() => paction('admin:fillPlayerHunger')}><i className="bi bi-egg-fried" />Remplir faim</button>
                <button className={s.mbtn} onClick={() => paction('admin:fillPlayerThirst')}><i className="bi bi-droplet-fill" />Remplir soif</button>
                <button className={`${s.mbtn} ${s.mbtnWarn}`} onClick={() => paction('admin:drainPlayerHunger')}><i className="bi bi-egg-fried" />Vider faim −10</button>
                <button className={`${s.mbtn} ${s.mbtnWarn}`} onClick={() => paction('admin:drainPlayerThirst')}><i className="bi bi-droplet-fill" />Vider soif −10</button>
              </div>
            </div>

            {/* Effets */}
            <div className={s.modalSection}>
              <div className={s.slabel}>Effets</div>
              <div className={s.mbtnGrid}>
                <button className={`${s.mbtn}${selected.frozen ? ' ' + s.mbtnActive : ''}`} onClick={() => paction('admin:freezePlayer')}><i className="bi bi-snow" />Freeze</button>
                <button className={`${s.mbtn}${selected.onFire  ? ' ' + s.mbtnActive : ''}`} onClick={() => paction('admin:toggleFire')}><i className="bi bi-fire" />Enflammer</button>
                <button className={`${s.mbtn}${selected.caged   ? ' ' + s.mbtnActive : ''}`} onClick={() => paction('admin:toggleCage')}><i className="bi bi-lock-fill" />Cage</button>
              </div>
            </div>

            {/* Véhicule */}
            <div className={s.modalSection}>
              <div className={s.slabel}>Véhicule</div>
              <div className={s.mbtnGrid}>
                <button className={s.mbtn} onClick={() => setSanction('spawn')}><i className="bi bi-car-front-fill" />Spawn</button>
              </div>
            </div>
            <div className={s.modalSection} style={!selected.inVehicle ? { opacity: 0.35, pointerEvents: 'none' } : undefined}>
              <div className={s.mbtnGrid}>
                <button className={s.mbtn} onClick={() => paction('admin:fixVehicle')}><i className="bi bi-wrench-adjustable-circle-fill" />Réparer</button>
                <button className={s.mbtn} onClick={() => paction('admin:refuelVehicle')}><i className="bi bi-fuel-pump-fill" />Réservoir</button>
                <button className={s.mbtn} onClick={() => nuiPost('admin:cleanVehicle', { id: selected.id })}><i className="bi bi-droplet-fill" />Laver</button>
                <button className={`${s.mbtn} ${s.mbtnDanger}`} onClick={() => nuiPost('admin:engineDamage', { id: selected.id })}><i className="bi bi-exclamation-octagon-fill" />Moteur</button>
                <button className={`${s.mbtn} ${s.mbtnDanger}`} onClick={() => paction('admin:breakWindows')}><i className="bi bi-window-dash" />Fenêtres</button>
                <button className={`${s.mbtn} ${s.mbtnDanger}`} onClick={() => paction('admin:burstTyres')}><i className="bi bi-slash-circle-fill" />Pneus</button>
                <button className={`${s.mbtn}${selected.vehicleFrozen ? ' ' + s.mbtnActive : ''}`} onClick={() => nuiPost('admin:freezeVehicle', { id: selected.id })}><i className="bi bi-snow2" />{selected.vehicleFrozen ? 'Unfreeze véh' : 'Freeze véh'}</button>
                <button className={`${s.mbtn} ${s.mbtnDanger}`} onClick={() => paction('admin:deleteVehicle')}><i className="bi bi-trash-fill" />Supprimer</button>
              </div>
            </div>

            {/* Grade — fondateur uniquement */}
            {myGrade?.perms.perm_grades && grades.length > 0 && (
              <div className={s.modalSection}>
                <div className={s.slabel}>Grade</div>
                <div className={s.mbtnGrid}>
                  {grades.map(g => (
                    <button
                      key={g.id}
                      className={`${s.gradeBtn}${selected.gradeId === g.id ? ' ' + s.gradeBtnActive : ''}`}
                      style={{ ['--gc' as string]: g.color }}
                      onClick={() => {
                        const newId = selected.gradeId === g.id ? 0 : g.id
                        nuiPost('admin:setPlayerGrade', { id: selected.id, gradeId: newId })
                        setSelected(p => p ? { ...p, gradeId: newId || undefined, gradeLabel: newId ? g.label : undefined, gradeColor: newId ? g.color : undefined } : p)
                        setPlayers(prev => prev.map(p => p.id === selected.id ? { ...p, gradeId: newId || undefined, gradeLabel: newId ? g.label : undefined, gradeColor: newId ? g.color : undefined } : p))
                      }}
                    >
                      <svg width="22" height="26" viewBox="0 0 22 26" fill="none" className={s.gradeBtnIcon}>
                        <path d="M11 0L22 4.5V13C22 19.5 11 26 11 26C11 26 0 19.5 0 13V4.5L11 0Z" fill="var(--gc)" fillOpacity="0.18" />
                        <path d="M11 2.5L19.5 5.9V13C19.5 18.2 11 23.8 11 23.8C11 23.8 2.5 18.2 2.5 13V5.9L11 2.5Z" fill="var(--gc)" fillOpacity="0.28" />
                        <path d="M11 5L17 7.6V13C17 16.9 11 21 11 21C11 21 5 16.9 5 13V7.6L11 5Z" fill="var(--gc)" fillOpacity="0.6" />
                      </svg>
                      <span className={s.gradeBtnLabel}>{g.label}</span>
                    </button>
                  ))}
                </div>
              </div>
            )}

            {/* Jobs */}
            <div className={s.modalSection}>
              <div className={s.slabel}>Jobs actuels</div>
              {(() => {
                const pj = playerJobs[selected.id]
                if (!pj) return <div style={{ color: '#666', fontSize: 11 }}>Chargement…</div>
                if (pj.jobs.length === 0) return <div style={{ color: '#666', fontSize: 11 }}>Aucun job</div>
                return (
                  <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
                    {pj.jobs.map(j => (
                      <div key={j.name} style={{ display: 'flex', alignItems: 'center', gap: 6, background: 'rgba(255,255,255,0.04)', borderRadius: 6, padding: '5px 8px' }}>
                        <i className="bi bi-briefcase-fill" style={{ color: '#a855f7', fontSize: 12 }} />
                        <span style={{ flex: 1, fontSize: 12 }}>{j.label}</span>
                        <span style={{ fontSize: 10, color: '#888', background: 'rgba(168,85,247,0.12)', borderRadius: 4, padding: '1px 5px' }}>{j.gradeLabel}</span>
                        <button
                          className={`${s.mbtn} ${s.mbtnDanger}`}
                          style={{ padding: '2px 6px', fontSize: 10, minWidth: 0 }}
                          onClick={() => {
                            nuiPost('admin:removeJob', { id: selected.id, jobName: j.name })
                            setPlayerJobs(prev => ({
                              ...prev,
                              [selected.id]: { ...prev[selected.id], jobs: prev[selected.id].jobs.filter(x => x.name !== j.name) }
                            }))
                          }}
                        ><i className="bi bi-x" /></button>
                      </div>
                    ))}
                  </div>
                )
              })()}

              <div className={s.slabel} style={{ marginTop: 8 }}>Assigner un job</div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
                {/* Job picker */}
                <div className={s.psWrap} ref={jobWrapRef}>
                  <button
                    className={`${s.psTrigger}${jobOpen ? ' ' + s.psTriggerOpen : ''}${jobPick ? ' ' + s.psTriggerFilled : ''}`}
                    onClick={() => { setJobOpen(o => !o); setGradeOpen(false) }}
                  >
                    <span>{jobPick ? jobPick.label : 'Choisir un job…'}</span>
                    {jobPick && <span style={{ fontSize: 8, color: '#666670', marginLeft: 4 }}>{jobPick.name}</span>}
                    <i className={`bi bi-chevron-${jobOpen ? 'up' : 'down'}`} style={{ marginLeft: 'auto' }} />
                  </button>
                  {jobOpen && (
                    <div className={s.psMenu}>
                      <div className={s.psSearch}>
                        <input autoFocus className={s.psSearchInput} value={jobSearch}
                          onChange={e => setJobSearch(e.target.value)} placeholder="Rechercher…" />
                      </div>
                      <div className={s.psList}>
                        {jobsList.filter(j => !jobSearch || j.label.toLowerCase().includes(jobSearch.toLowerCase()) || j.name.includes(jobSearch.toLowerCase())).length === 0
                          ? <div className={s.psEmpty}>Aucun job</div>
                          : jobsList
                              .filter(j => !jobSearch || j.label.toLowerCase().includes(jobSearch.toLowerCase()) || j.name.includes(jobSearch.toLowerCase()))
                              .map(j => (
                                <div key={j.name}
                                  className={`${s.psItem}${jobPick?.name === j.name ? ' ' + s.psItemActive : ''}`}
                                  onClick={() => { setJobPick(j); setJobGradePick(j.grades[0] ?? null); setJobOpen(false); setJobSearch('') }}
                                >
                                  <span>{j.label}</span>
                                  <span className={s.psItemId}>{j.name}</span>
                                </div>
                              ))
                        }
                      </div>
                    </div>
                  )}
                </div>

                {/* Grade picker */}
                {jobPick && jobPick.grades.length > 0 && (
                  <div className={s.psWrap} ref={gradeWrapRef}>
                    <button
                      className={`${s.psTrigger}${gradeOpen ? ' ' + s.psTriggerOpen : ''}${jobGradePick != null ? ' ' + s.psTriggerFilled : ''}`}
                      onClick={() => { setGradeOpen(o => !o); setJobOpen(false) }}
                    >
                      <span>{jobGradePick != null ? jobGradePick.label : 'Choisir un grade…'}</span>
                      <i className={`bi bi-chevron-${gradeOpen ? 'up' : 'down'}`} style={{ marginLeft: 'auto' }} />
                    </button>
                    {gradeOpen && (
                      <div className={s.psMenu}>
                        <div className={s.psList}>
                          {jobPick.grades.map(g => (
                            <div key={g.grade}
                              className={`${s.psItem}${jobGradePick?.grade === g.grade ? ' ' + s.psItemActive : ''}`}
                              onClick={() => { setJobGradePick(g); setGradeOpen(false) }}
                            >
                              <span>{g.label}</span>
                              <span className={s.psItemId}>Grade {g.grade}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                )}

                <button
                  className={`${s.btn} ${s.btnGreen}`}
                  disabled={!jobPick}
                  onClick={() => {
                    if (!jobPick) return
                    nuiPost('admin:setJob', { id: selected.id, jobName: jobPick.name, grade: jobGradePick?.grade ?? 0 })
                    setJobPick(null); setJobGradePick(null)
                    setTimeout(() => nuiPost('admin:getPlayerJobs', { id: selected.id }), 600)
                  }}
                >
                  <i className="bi bi-briefcase-fill" /> Assigner le job
                </button>
              </div>
            </div>

            {/* Inventaire */}
            <div className={s.modalSection}>
              <div className={s.slabel}>Inventaire</div>
              <GiveItemPicker
                label={`Donner à ${selected.name}`}
                onGive={(itemName, qty) =>
                  nuiPost('inventory:admin:giveItem', { targetSrc: selected.id, itemName, quantity: qty })
                }
              />
            </div>

            {/* Gestion items */}
            <div className={s.modalSection}>
              <div className={s.slabel}>Gestion items</div>
              {/* Tabs */}
              <div className={s.pinvTabs}>
                {(['items', 'weapons', 'keys'] as const).map(cat => {
                  const icons: Record<string, string> = { items: 'bi-box-seam', weapons: 'bi-crosshair', keys: 'bi-key-fill' }
                  const labels: Record<string, string> = { items: 'Items', weapons: 'Armes', keys: 'Clés' }
                  const count = playerInv?.[cat]?.length ?? 0
                  return (
                    <button
                      key={cat}
                      className={`${s.pinvTab}${pinvTab === cat ? ' ' + s.pinvTabActive : ''}`}
                      onClick={() => setPinvTab(cat)}
                    >
                      <i className={`bi ${icons[cat]}`} />
                      {labels[cat]}
                      <span className={s.pinvTabCount}>{count}</span>
                    </button>
                  )
                })}
              </div>
              {/* List */}
              <div className={s.pinvList}>
                {playerInvLoad ? (
                  <div className={s.pinvLoading}>Chargement…</div>
                ) : !playerInv || playerInv[pinvTab].length === 0 ? (
                  <div className={s.pinvEmpty}>Aucun élément</div>
                ) : playerInv[pinvTab].map(item => {
                  const isFirearm = item.idata?.type === 'weapon'
                    && item.idata?.category !== 'melee'
                    && item.idata?.category !== 'throwable'
                  const serial = item.data?.serial
                  const serialErased = item.data?.serialErased
                  return (
                    <div key={item.id} className={s.pinvRow}>
                      {item.image ? (
                        <img
                          src={item.image}
                          className={s.pinvImg} alt=""
                        />
                      ) : (
                        <div className={s.pinvImgPlaceholder}><i className="bi bi-box" /></div>
                      )}
                      <div className={s.pinvInfo}>
                        <div className={s.pinvLabel}>{item.label}</div>
                        <div className={s.pinvSub}>
                          {item.name}
                          {isFirearm && (
                            <span className={serial ? s.pinvSerialOk : serialErased ? s.pinvSerialErased : s.pinvSerialNone}>
                              {' · '}{serial ?? (serialErased ? 'N/S effacé' : 'Aucun N/S')}
                            </span>
                          )}
                        </div>
                      </div>
                      <span className={s.pinvQty}>×{item.quantity}</span>
                      {item.quantity > 1 && (
                        <input
                          type="number" min={1} max={item.quantity}
                          value={removeQty[item.id] ?? 1}
                          onChange={e => setRemoveQty(prev => ({ ...prev, [item.id]: Math.min(item.quantity, Math.max(1, parseInt(e.target.value) || 1)) }))}
                          className={s.pinvQtyInput}
                          onClick={e => e.stopPropagation()}
                        />
                      )}
                      <button
                        className={s.pinvRemove}
                        onClick={() => {
                          const qty = item.quantity > 1 ? (removeQty[item.id] ?? 1) : 1
                          nuiPost('inventory:admin:removePlayerItem', { targetSrc: selected.id, itemId: item.id, quantity: qty })
                          setPlayerInvLoad(true)
                        }}
                      >
                        <i className="bi bi-trash3" />
                      </button>
                    </div>
                  )
                })}
              </div>
            </div>

            {/* Sanctions */}
            <div className={s.modalSection}>
              <div className={s.slabel}>Sanctions</div>
              <div className={s.mbtnGrid}>
                <button className={s.mbtn} onClick={() => setSanction('warn')}><i className="bi bi-exclamation-triangle-fill" />Warn</button>
                <button className={`${s.mbtn} ${s.mbtnWarn}`} onClick={() => setSanction('kick')}><i className="bi bi-box-arrow-right" />Kick</button>
                <button className={`${s.mbtn} ${s.mbtnDanger}`} onClick={() => setSanction('ban')}><i className="bi bi-hammer" />Ban</button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* ── SERVEUR ── */}
      {tab === 'serveur' && (
        <div className={s.pane}>
          <div className={s.scroll}>

            {/* Base de données */}
            <div className={s.slabel}>Base de données</div>
            <div className={s.mbtnGrid} style={{ marginBottom: 14 }}>
              <button className={s.mbtn} onClick={() => setShowItemsMgr(true)}>
                <i className="bi bi-box-fill" /> Gestion Items
              </button>
              <button className={s.mbtn} onClick={() => setShowLogs(true)}>
                <i className="bi bi-journal-text" /> Logs admin
              </button>
              <button className={s.mbtn} onClick={() => setShowEconomy(true)}>
                <i className="bi bi-graph-up-arrow" /> Économie
              </button>
            </div>

            <div className={s.slabel}>Actions disponibles</div>
            {/* Accordéon — Météo & Heure */}
            <div className={s.accordion}>
              <button className={`${s.accHeader}${openSections.has('meteo') ? ' ' + s.accHeaderOpen : ''}`} onClick={() => toggleSection('meteo')}>
                <div className={s.accHeaderLeft}><i className="bi bi-cloud-sun-fill" /><span>Météo &amp; Heure</span></div>
                <span className={`${s.accChevron}${openSections.has('meteo') ? ' ' + s.accChevronOpen : ''}`}>›</span>
              </button>
              {openSections.has('meteo') && (
                <div className={s.accBody}>
                  <div className={s.slabel}>Météo</div>
                  {!freezeWeather && (() => {
                    const cur  = WEATHERS.find(w => w.key === weather)
                    const next = WEATHERS.find(w => w.key === nextWeather)
                    return (
                      <div className={s.weatherInfo}>
                        <span className={s.wiCurrent}>
                          <i className={`bi ${cur?.icon ?? 'bi-question'}`} />
                          {cur?.label ?? weather}
                        </span>
                        <i className={`bi bi-arrow-right ${s.wiArrow}`} />
                        <span className={s.wiNext}>
                          <i className={`bi ${next?.icon ?? 'bi-question'}`} />
                          {next?.label ?? nextWeather}
                        </span>
                      </div>
                    )
                  })()}
                  <div className={s.weatherGrid}>
                    {WEATHERS.map(w => (
                      <button
                        key={w.key}
                        className={`${s.wbtn}${weather === w.key ? ' ' + s.wbtnActive : ''}${freezeWeather ? ' ' + s.wbtnLocked : ''}`}
                        onClick={() => { if (freezeWeather) return; setWeatherKey(w.key); nuiPost('admin:setWeather', { weather: w.key }) }}
                      >
                        <i className={`bi ${w.icon}`} />
                        {w.label}
                      </button>
                    ))}
                  </div>
                  <button
                    className={`${s.btn} ${freezeWeather ? s.btnFreezeActive : s.btnGray}`}
                    style={{ marginTop: 6, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6 }}
                    onClick={() => nuiPost('admin:toggleFreezeWeather', {})}
                  >
                    <i className={`bi ${freezeWeather ? 'bi-lock-fill' : 'bi-unlock'}`} />
                    {freezeWeather ? 'Déverrouiller la météo' : 'Figer la météo'}
                  </button>

                  <div className={s.slabel} style={{ paddingTop: 16 }}>Heure du serveur</div>
                  <div className={s.timeDisplay}>
                    {String(liveHour).padStart(2, '0')}:{String(liveMinute).padStart(2, '0')}
                  </div>
                  <div className={s.sliderRow} style={{ marginBottom: 6 }}>
                    <span className={s.sliderLbl}>H</span>
                    <input type="range" min={0} max={23} value={hour} onChange={e => setHour(+e.target.value)}
                      style={{ '--pct': `${(hour/23)*100}%`, '--origin': '0%' } as React.CSSProperties} />
                    <span className={s.sliderVal}>{hour}</span>
                  </div>
                  <div className={s.sliderRow} style={{ marginBottom: 10 }}>
                    <span className={s.sliderLbl}>M</span>
                    <input type="range" min={0} max={59} value={minute} onChange={e => setMinute(+e.target.value)}
                      style={{ '--pct': `${(minute/59)*100}%`, '--origin': '0%' } as React.CSSProperties} />
                    <span className={s.sliderVal}>{String(minute).padStart(2, '0')}</span>
                  </div>
                  <div style={{ display: 'flex', gap: 6 }}>
                    <button className={`${s.btn} ${s.btnGreen}`} style={{ flex: 1 }} onClick={() => applyTime()}>
                      <i className="bi bi-check2" /> Appliquer
                    </button>
                    <button
                      className={`${s.btn} ${freezeTime ? s.btnFreezeActive : s.btnGray}`}
                      style={{ flex: 1 }}
                      onClick={() => { const nf = !freezeTime; setFreezeTime(nf); applyTime(nf) }}
                    >
                      <i className={`bi ${freezeTime ? 'bi-play-fill' : 'bi-pause-fill'}`} />
                      {' '}{freezeTime ? 'Reprendre' : 'Pause'}
                    </button>
                  </div>
                </div>
              )}
            </div>

            {/* Accordéon — Annonce globale */}
            <div className={s.accordion}>
              <button className={`${s.accHeader}${openSections.has('annonce') ? ' ' + s.accHeaderOpen : ''}`} onClick={() => toggleSection('annonce')}>
                <div className={s.accHeaderLeft}><i className="bi bi-megaphone-fill" /><span>Annonce globale</span></div>
                <span className={`${s.accChevron}${openSections.has('annonce') ? ' ' + s.accChevronOpen : ''}`}>›</span>
              </button>
              {openSections.has('annonce') && (
                <div className={s.accBody}>
                  <div className={s.field} style={{ marginBottom: 6 }}>
                    <label>Nom staff</label>
                    <input className={s.input} value={annStaff} onChange={e => setAnnStaff(e.target.value)} placeholder="Direction RP, Modération…" />
                  </div>
                  <div className={s.field} style={{ marginBottom: 6 }}>
                    <label>Message</label>
                    <textarea
                      className={s.announceArea} rows={3}
                      value={annMsg} onChange={e => setAnnMsg(e.target.value)}
                      placeholder="Message à tous les joueurs…"
                    />
                  </div>
                  <div className={s.field} style={{ marginBottom: 8, position: 'relative' }}>
                    <label>Durée d'affichage</label>
                    <button className={s.dropBtn} onClick={() => setAnnDurOpen(o => !o)}>
                      <span>{DURATIONS.find(d => d.value === annDuration)?.label}</span>
                      <i className={`bi bi-chevron-${annDurOpen ? 'up' : 'down'}`} />
                    </button>
                    {annDurOpen && (
                      <div className={s.dropMenu}>
                        {DURATIONS.map(d => (
                          <div
                            key={d.value}
                            className={`${s.dropItem}${annDuration === d.value ? ' ' + s.dropItemActive : ''}`}
                            onClick={() => { setAnnDuration(d.value); setAnnDurOpen(false) }}
                          >
                            {d.label}
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                  <button
                    className={`${s.btn} ${s.btnGreen}`}
                    style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6 }}
                    onClick={() => {
                      if (annMsg.trim() && annStaff.trim()) {
                        nuiPost('admin:announce', { staffName: annStaff.trim(), message: annMsg.trim(), duration: annDuration })
                        setAnnMsg('')
                      }
                    }}
                  >
                    <i className="bi bi-megaphone-fill" /> Envoyer
                  </button>
                </div>
              )}
            </div>

            {/* Accordéon — Actions en masse */}
            <div className={s.accordion}>
              <button className={`${s.accHeader}${openSections.has('masse') ? ' ' + s.accHeaderOpen : ''}`} onClick={() => toggleSection('masse')}>
                <div className={s.accHeaderLeft}><i className="bi bi-lightning-charge-fill" /><span>Actions en masse</span></div>
                <span className={`${s.accChevron}${openSections.has('masse') ? ' ' + s.accChevronOpen : ''}`}>›</span>
              </button>
              {openSections.has('masse') && (
                <div className={s.accBody}>
                  <div className={s.slabel}>Périmètre</div>
                  <div style={{ display: 'flex', gap: 4, marginBottom: 12, flexWrap: 'wrap' as const }}>
                    {[50, 100, 250, 500, 0].map(r => (
                      <button key={r}
                        className={`${s.mbtn}${massRadius === r ? ' ' + s.mbtnActive : ''}`}
                        style={{ flex: '0 0 auto', fontSize: 9, padding: '5px 10px' }}
                        onClick={() => setMassRadius(r)}>
                        {r === 0 ? 'Serveur entier' : `${r} m`}
                      </button>
                    ))}
                  </div>
                  <div className={s.mbtnGrid} style={{ fontSize: 9 }}>
                    <button className={`${s.mbtn} ${s.mbtnWarn}`}
                      onClick={() => nuiPost('admin:massDeleteVehicles', { radius: massRadius })}>
                      <i className="bi bi-car-front-fill" />Suppr. véhicules
                    </button>
                    <button className={`${s.mbtn} ${s.mbtnWarn}`}
                      onClick={() => nuiPost('admin:massDeletePeds', { radius: massRadius })}>
                      <i className="bi bi-people-fill" />Suppr. peds
                    </button>
                  </div>
                </div>
              )}
            </div>

          {/* Accordéon — Grades staff (fondateur uniquement) */}
            {myGrade?.perms.perm_grades && (
              <div className={s.accordion}>
                <button
                  className={`${s.accHeader}${openSections.has('grades') ? ' ' + s.accHeaderOpen : ''}`}
                  onClick={() => {
                    toggleSection('grades')
                    if (!openSections.has('grades')) nuiPost('admin:getGrades', {})
                  }}
                >
                  <div className={s.accHeaderLeft}><i className="bi bi-shield-lock-fill" /><span>Grades staff</span></div>
                  <span className={`${s.accChevron}${openSections.has('grades') ? ' ' + s.accChevronOpen : ''}`}>›</span>
                </button>
                {openSections.has('grades') && (
                  <div className={s.accBody}>
                    <button
                      className={`${s.btn} ${s.btnGreen}`}
                      style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6, marginBottom: 10 }}
                      onClick={() => {
                        setEditGrade({ id: 0, name: '', label: 'Nouveau grade', color: '#9333ea', perms: { ...DEFAULT_PERMS } })
                        setExpandedGrade(-1)
                      }}
                    >
                      <i className="bi bi-plus-lg" /> Nouveau grade
                    </button>

                    {editGrade && editGrade.id === 0 && expandedGrade === -1 && (
                      <div className={s.gradeEditor}>
                        <GradeForm
                          grade={editGrade}
                          onChange={setEditGrade}
                          onSave={() => { nuiPost('admin:saveGrade', { ...editGrade, perms: editGrade.perms }); setEditGrade(null); setExpandedGrade(null) }}
                          onCancel={() => { setEditGrade(null); setExpandedGrade(null) }}
                          isNew
                        />
                      </div>
                    )}

                    {grades.map(g => (
                      <div key={g.id} className={s.gradeCard}>
                        <button
                          className={`${s.gradeHeader}${expandedGrade === g.id ? ' ' + s.gradeHeaderOpen : ''}`}
                          onClick={() => {
                            if (expandedGrade === g.id) { setExpandedGrade(null); setEditGrade(null) }
                            else { setExpandedGrade(g.id); setEditGrade({ ...g, perms: { ...g.perms } }) }
                          }}
                        >
                          <span className={s.gradeColorDot} style={{ background: g.color, boxShadow: `0 0 6px ${g.color}88` }} />
                          <span className={s.gradeHeaderLabel}>{g.label}</span>
                          <span className={s.gradeHeaderName}>{g.name}</span>
                          <span className={`${s.accChevron}${expandedGrade === g.id ? ' ' + s.accChevronOpen : ''}`}>›</span>
                        </button>
                        {expandedGrade === g.id && editGrade && (
                          <div className={s.gradeEditorBody}>
                            <GradeForm
                              grade={editGrade}
                              onChange={setEditGrade}
                              onSave={() => { nuiPost('admin:saveGrade', editGrade); setExpandedGrade(null); setEditGrade(null) }}
                              onCancel={() => { setExpandedGrade(null); setEditGrade(null) }}
                              onDelete={g.name !== 'fondateur' ? () => { nuiPost('admin:deleteGrade', { id: g.id }); setExpandedGrade(null); setEditGrade(null) } : undefined}
                            />
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}

          </div>
        </div>
      )}

      {/* ── OUTILS ── */}
      {tab === 'outils' && (
        <div className={s.pane}>
          <div className={s.scroll}>

            {/* Visibilité */}
            <div className={s.accordion}>
              <button className={`${s.accHeader}${openSections.has('outil_visibility') ? ' ' + s.accHeaderOpen : ''}`} onClick={() => toggleSection('outil_visibility')}>
                <div className={s.accHeaderLeft}><i className="bi bi-eye-fill" /><span>Visibilité</span></div>
                <span className={`${s.accChevron}${openSections.has('outil_visibility') ? ' ' + s.accChevronOpen : ''}`}>›</span>
              </button>
              {openSections.has('outil_visibility') && (
                <div className={s.accBody}>
                  {TOOLS_VISIBILITY.map(t => (
                    <div key={t.key} className={`${s.toggleRow}${tools[t.key] ? ' ' + s.toggleRowActive : ''}`} onClick={() => nuiPost(t.nui, {})}>
                      <i className={`bi ${t.icon} ${s.ti}`} />
                      <div className={s.tt}><div className={s.tl}>{t.label}</div><div className={s.ts}>{t.desc}</div></div>
                      <div className={s.led} />
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Capacités */}
            <div className={s.accordion}>
              <button className={`${s.accHeader}${openSections.has('outil_cap') ? ' ' + s.accHeaderOpen : ''}`} onClick={() => toggleSection('outil_cap')}>
                <div className={s.accHeaderLeft}><i className="bi bi-tools" /><span>Capacités</span></div>
                <span className={`${s.accChevron}${openSections.has('outil_cap') ? ' ' + s.accChevronOpen : ''}`}>›</span>
              </button>
              {openSections.has('outil_cap') && (
                <div className={s.accBody}>
                  {TOOLS_CAPACITES.map(t => (
                    <div key={t.key} className={`${s.toggleRow}${tools[t.key] ? ' ' + s.toggleRowActive : ''}`} onClick={() => nuiPost(t.nui, {})}>
                      <i className={`bi ${t.icon} ${s.ti}`} />
                      <div className={s.tt}><div className={s.tl}>{t.label}</div><div className={s.ts}>{t.desc}</div></div>
                      <div className={s.led} />
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Santé */}
            <div className={s.accordion}>
              <button className={`${s.accHeader}${openSections.has('outil_sante') ? ' ' + s.accHeaderOpen : ''}`} onClick={() => toggleSection('outil_sante')}>
                <div className={s.accHeaderLeft}><i className="bi bi-heart-pulse-fill" /><span>Santé</span></div>
                <span className={`${s.accChevron}${openSections.has('outil_sante') ? ' ' + s.accChevronOpen : ''}`}>›</span>
              </button>
              {openSections.has('outil_sante') && (
                <div className={s.accBody}>
                  <div className={s.mbtnGrid}>
                    {TOOLS_SANTE.map(t => (
                      <button key={t.nui}
                        className={`${s.mbtn}${t.danger ? ' ' + s.mbtnDanger : t.warn ? ' ' + s.mbtnWarn : ''}`}
                        onClick={() => nuiPost(t.nui, {})}>
                        <i className={`bi ${t.icon}`} />{t.label}
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </div>

            {/* Besoins */}
            <div className={s.accordion}>
              <button className={`${s.accHeader}${openSections.has('outil_status') ? ' ' + s.accHeaderOpen : ''}`} onClick={() => toggleSection('outil_status')}>
                <div className={s.accHeaderLeft}><i className="bi bi-egg-fried" /><span>Besoins</span></div>
                <span className={`${s.accChevron}${openSections.has('outil_status') ? ' ' + s.accChevronOpen : ''}`}>›</span>
              </button>
              {openSections.has('outil_status') && (
                <div className={s.accBody}>
                  <div className={s.mbtnGrid}>
                    {TOOLS_STATUS.map(t => (
                      <button key={t.nui}
                        className={`${s.mbtn}${t.warn ? ' ' + s.mbtnWarn : ''}`}
                        onClick={() => nuiPost(t.nui, {})}>
                        <i className={`bi ${t.icon}`} />{t.label}
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </div>

            {/* Inventaire — give à soi */}
            <div className={s.accordion}>
              <button className={`${s.accHeader}${openSections.has('outil_inventory') ? ' ' + s.accHeaderOpen : ''}`} onClick={() => toggleSection('outil_inventory')}>
                <div className={s.accHeaderLeft}><i className="bi bi-box-seam-fill" /><span>Inventaire</span></div>
                <span className={`${s.accChevron}${openSections.has('outil_inventory') ? ' ' + s.accChevronOpen : ''}`}>›</span>
              </button>
              {openSections.has('outil_inventory') && (
                <div className={s.accBody}>
                  <GiveItemPicker
                    label="Me donner"
                    onGive={(itemName, qty) => nuiPost('admin:giveSelfItem', { itemName, quantity: qty })}
                  />
                </div>
              )}
            </div>

            {/* Coordonnées */}
            <div className={s.accordion}>
              <button className={`${s.accHeader}${openSections.has('outil_coords') ? ' ' + s.accHeaderOpen : ''}`} onClick={() => toggleSection('outil_coords')}>
                <div className={s.accHeaderLeft}><i className="bi bi-crosshair" /><span>Coordonnées</span></div>
                <span className={`${s.accChevron}${openSections.has('outil_coords') ? ' ' + s.accChevronOpen : ''}`}>›</span>
              </button>
              {openSections.has('outil_coords') && (
                <div className={s.accBody}>
                  {coords ? (
                    <>
                      <div className={s.vehInfoGrid} style={{ gridTemplateColumns: '1fr 1fr 1fr 1fr', marginBottom: 8 }}>
                        {([['X', coords.x.toFixed(2)], ['Y', coords.y.toFixed(2)], ['Z', coords.z.toFixed(2)], ['H', coords.h.toFixed(1) + '°']] as [string,string][]).map(([label, value]) => (
                          <div key={label} className={s.vehStat}>
                            <span className={s.vehStatLabel}>{label}</span>
                            <span className={s.vehStatValue} style={{ fontFamily: 'monospace' }}>{value}</span>
                          </div>
                        ))}
                      </div>
                      <div className={s.mbtnGrid}>
                        {([
                          ['v3',    `vector3(${coords.x.toFixed(2)}, ${coords.y.toFixed(2)}, ${coords.z.toFixed(2)})`,                                        'vector3'    ],
                          ['v4',    `vector4(${coords.x.toFixed(2)}, ${coords.y.toFixed(2)}, ${coords.z.toFixed(2)}, ${coords.h.toFixed(1)})`,                'vector4'    ],
                          ['xyz',   `${coords.x.toFixed(2)}, ${coords.y.toFixed(2)}, ${coords.z.toFixed(2)}`,                                                 'X, Y, Z'   ],
                          ['xyzh',  `${coords.x.toFixed(2)}, ${coords.y.toFixed(2)}, ${coords.z.toFixed(2)}, ${coords.h.toFixed(1)}`,                         'X, Y, Z, H'],
                          ['eqxyzh',`X=${coords.x.toFixed(2)} Y=${coords.y.toFixed(2)} Z=${coords.z.toFixed(2)} H=${coords.h.toFixed(1)}`,                    'X= Y= Z= H='],
                          ['eqxyz', `X=${coords.x.toFixed(2)} Y=${coords.y.toFixed(2)} Z=${coords.z.toFixed(2)}`,                                             'X= Y= Z='  ],
                        ] as [string, string, string][]).map(([key, text, label]) => (
                          <button key={key} className={`${s.mbtn}${copied === key ? ' ' + s.mbtnActive : ''}`}
                            style={{ flex: '0 0 calc(50% - 1px)' }}
                            onClick={() => { copyText(text); setCopied(key) }}>
                            <i className={`bi ${copied === key ? 'bi-check2' : 'bi-clipboard'}`} />
                            {label}
                          </button>
                        ))}
                      </div>
                    </>
                  ) : (
                    <div className={s.vehNoVeh}>Chargement…</div>
                  )}
                </div>
              )}
            </div>

            {/* Véhicules */}
            <div className={s.accordion}>
              <button className={`${s.accHeader}${openSections.has('outil_vehicule') ? ' ' + s.accHeaderOpen : ''}`} onClick={() => toggleSection('outil_vehicule')}>
                <div className={s.accHeaderLeft}><i className="bi bi-car-front-fill" /><span>Véhicule</span></div>
                <span className={`${s.accChevron}${openSections.has('outil_vehicule') ? ' ' + s.accChevronOpen : ''}`}>›</span>
              </button>
              {openSections.has('outil_vehicule') && (
                <div className={s.accBody}>
                  {/* Spawn véhicule */}
                  <div className={s.slabel}>Spawn véhicule</div>
                  <div style={{ display: 'flex', gap: 6, marginBottom: 10 }}>
                    <input
                      className={s.input}
                      placeholder="Ex: zentorno, adder..."
                      value={spawnModel}
                      onChange={e => setSpawnModel(e.target.value.toLowerCase())}
                      style={{ flex: 1, fontFamily: 'var(--font-display)', letterSpacing: '0.05em' }}
                      onKeyDown={e => { if (e.key === 'Enter' && spawnModel.trim()) { nuiPost('admin:selfSpawnVehicle', { model: spawnModel.trim() }); setSpawnModel('') } }}
                    />
                    <button className={`${s.btn} ${s.btnGreen}`} style={{ padding: '0 14px' }}
                      onClick={() => { if (spawnModel.trim()) { nuiPost('admin:selfSpawnVehicle', { model: spawnModel.trim() }); setSpawnModel('') } }}>
                      <i className="bi bi-play-fill" />
                    </button>
                  </div>

                  {/* Infos */}
                  {vehInfo?.inVehicle ? (
                    <div className={s.vehInfoGrid}>
                      {[
                        { label: 'Modèle',    value: vehInfo.model ?? 'N/A' },
                        { label: 'Plaque',    value: vehInfo.plate ?? 'N/A' },
                        { label: 'Moteur',    value: `${vehInfo.engineHealth ?? 0} / 1000` },
                        { label: 'Carross.',  value: `${vehInfo.bodyHealth   ?? 0} / 1000` },
                        { label: 'Essence',   value: `${vehInfo.fuelLevel    ?? 0} %` },
                        { label: 'Saleté',    value: `${vehInfo.dirtLevel    ?? 0}` },
                      ].map(({ label, value }) => (
                        <div key={label} className={s.vehStat}>
                          <span className={s.vehStatLabel}>{label}</span>
                          <span className={s.vehStatValue}>{value}</span>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <div className={s.vehNoVeh}>Aucun véhicule détecté</div>
                  )}
                  {/* Actions */}
                  <div className={s.mbtnGrid} style={{ fontSize: 9 }}>
                    <button className={s.mbtn} onClick={() => nuiPost('admin:selfFixVehicle',   {})}><i className="bi bi-wrench-adjustable-circle-fill" />Réparer</button>
                    <button className={s.mbtn} onClick={() => nuiPost('admin:selfCleanVehicle', {})}><i className="bi bi-droplet-fill" />Laver</button>
                    <button className={s.mbtn} onClick={() => nuiPost('admin:selfRefuel',       {})}><i className="bi bi-fuel-pump-fill" />Réservoir</button>
                    <button className={`${s.mbtn}${vehFrozen ? ' ' + s.mbtnActive : ''}`}
                      onClick={() => nuiPost('admin:selfToggleFreezeVehicle', {})}>
                      <i className="bi bi-snow2" />{vehFrozen ? 'Unfreeze' : 'Freeze'}
                    </button>
                    <button className={`${s.mbtn} ${s.mbtnWarn}`} onClick={() => nuiPost('admin:selfEngineDamage',  {})}><i className="bi bi-exclamation-octagon-fill" />Casser moteur</button>
                    <button className={`${s.mbtn} ${s.mbtnWarn}`} onClick={() => nuiPost('admin:selfBreakWindows', {})}><i className="bi bi-window-dash" />Casser fenêtres</button>
                    <button className={`${s.mbtn} ${s.mbtnWarn}`} onClick={() => nuiPost('admin:selfBurstTyres',   {})}><i className="bi bi-slash-circle-fill" />Crever pneus</button>
                    <button className={`${s.mbtn} ${s.mbtnDanger}`} onClick={() => nuiPost('admin:selfDeleteVehicle', {})}><i className="bi bi-trash3-fill" />Supprimer</button>
                  </div>

                  {/* Changer la plaque */}
                  <div className={s.slabel} style={{ marginTop: 10 }}>Changer la plaque</div>
                  <div style={{ display: 'flex', gap: 6 }}>
                    <input
                      className={s.input}
                      maxLength={8}
                      placeholder="Ex: BRIK1234"
                      value={plateInput}
                      onChange={e => setPlateInput(e.target.value.toUpperCase())}
                      style={{ flex: 1, fontFamily: 'var(--font-display)', letterSpacing: '0.1em' }}
                    />
                    <button className={`${s.btn} ${s.btnGreen}`} style={{ padding: '0 14px' }}
                      onClick={() => { if (plateInput.trim()) { nuiPost('admin:selfChangePlate', { plate: plateInput.trim() }); setPlateInput('') } }}>
                      <i className="bi bi-check" />
                    </button>
                  </div>
                </div>
              )}
            </div>

            {/* Téléportation */}
            <div className={s.accordion}>
              <button className={`${s.accHeader}${openSections.has('outil_tp') ? ' ' + s.accHeaderOpen : ''}`} onClick={() => toggleSection('outil_tp')}>
                <div className={s.accHeaderLeft}><i className="bi bi-crosshair" /><span>Téléportation</span></div>
                <span className={`${s.accChevron}${openSections.has('outil_tp') ? ' ' + s.accChevronOpen : ''}`}>›</span>
              </button>
              {openSections.has('outil_tp') && (
                <div className={s.accBody}>
                  <div className={s.coordRow}>
                    <div className={s.field}><label>X</label><input className={s.input} type="number" value={tpX} onChange={e => setTpX(e.target.value)} placeholder="X" /></div>
                    <div className={s.field}><label>Y</label><input className={s.input} type="number" value={tpY} onChange={e => setTpY(e.target.value)} placeholder="Y" /></div>
                    <div className={s.field}><label>Z</label><input className={s.input} type="number" value={tpZ} onChange={e => setTpZ(e.target.value)} placeholder="Z" /></div>
                    <button
                      className={`${s.btn} ${s.btnGreen}`} style={{ height: 38, width: 44, padding: 0 }}
                      onClick={() => {
                        const x = parseFloat(tpX), y = parseFloat(tpY), z = parseFloat(tpZ)
                        if (!isNaN(x) && !isNaN(y) && !isNaN(z)) nuiPost('admin:teleportCoords', { x, y, z })
                      }}
                    ><i className="bi bi-arrow-right" /></button>
                  </div>
                  <button
                    className={`${s.btn} ${s.btnGreen}`} style={{ marginTop: 6, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6 }}
                    onClick={() => nuiPost('admin:teleportWaypoint', {})}
                  >
                    <i className="bi bi-pin-map-fill" /> TP au marqueur GPS
                  </button>
                </div>
              )}
            </div>

          </div>
        </div>
      )}

      {/* ── REPORTS ── */}
      {tab === 'reports' && (
        <div className={s.pane}>

          {/* ── Barre de filtres ── */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '8px 20px', borderBottom: '1px solid rgba(255,255,255,0.06)', flexShrink: 0 }}>
            {([
              { key: 'open',        label: 'Ouverts',  color: '#ef4444' },
              { key: 'in_progress', label: 'En cours', color: '#f59e0b' },
              { key: 'closed',      label: 'Clôturés', color: '#22c55e' },
              { key: 'all',         label: 'Tous',     color: undefined  },
            ] as { key: typeof reportFilter; label: string; color?: string }[]).map(f => {
              const count = f.key === 'all' ? reports.length : reports.filter(r => r.status === f.key).length
              const active = reportFilter === f.key
              return (
                <button key={f.key} onClick={() => setReportFilter(f.key)} style={{
                  padding: '4px 10px', border: 'none', cursor: 'pointer',
                  fontFamily: 'var(--font-display)', fontSize: 9, fontWeight: 700,
                  letterSpacing: '0.08em', textTransform: 'uppercase' as const,
                  background: active
                    ? (f.color ? `${f.color}22` : 'rgba(255,255,255,0.08)')
                    : 'transparent',
                  color: active ? (f.color ?? '#e8e8ec') : '#666670',
                  borderBottom: active ? `2px solid ${f.color ?? 'rgba(255,255,255,0.4)'}` : '2px solid transparent',
                  transition: 'all .12s',
                }}>
                  {f.label}{count > 0 ? ` (${count})` : ''}
                </button>
              )
            })}
          </div>

          <div className={s.scroll}>
            {(() => {
              const filtered = reportFilter === 'all' ? reports : reports.filter(r => r.status === reportFilter)
              if (filtered.length === 0) return (
                <div style={{ padding: '40px 0', textAlign: 'center', color: '#666670', fontSize: 12 }}>
                  <i className="bi bi-inbox" style={{ fontSize: 28, display: 'block', marginBottom: 8 }} />
                  Aucun report
                </div>
              )
              return filtered.map(r => {
                const isReport    = r.type === 'report'
                const ST          = { open: { label: 'Ouvert', color: '#ef4444' }, in_progress: { label: 'En cours', color: '#f59e0b' }, closed: { label: 'Clôturé', color: '#22c55e' } }
                const st          = ST[r.status]
                const onlinePlayer = players.find(p => r.player_license ? p.licenses?.includes(r.player_license) : p.id === r.player_id)
                const isExpanded  = expandedReport === r.id
                const toggle      = () => setExpandedReport(p => p === r.id ? null : r.id)
                const collabs: string[] = r.collaborators ? (() => { try { return JSON.parse(r.collaborators) } catch { return [] } })() : []
                const canAct      = !r.assigned_license || r.assigned_license === myLicense || collabs.includes(myLicense)
                return (
                  <div key={r.id} className={s.reportCard}>
                    <button className={`${s.reportHeader}${isExpanded ? ' ' + s.reportHeaderOpen : ''}`} onClick={toggle}>
                      <span style={{ width: 7, height: 7, borderRadius: '50%', flexShrink: 0, background: st.color, boxShadow: `0 0 5px ${st.color}88` }} />
                      <span className={`${s.reportBadge} ${isReport ? s.reportBadgeReport : s.reportBadgeSignal}`}>
                        {isReport ? 'Report' : 'Signal.'}
                      </span>
                      <span className={s.reportCat}>{REPORT_CAT_LABELS[r.category] ?? r.category}</span>
                      <span className={s.reportAuthor}>{r.player_name}{r.target_name ? ` → ${r.target_name}` : ''}</span>
                      {r.assigned_name && <span className={s.reportAssigned}><i className="bi bi-person-check-fill" />{r.assigned_name}</span>}
                      <span className={s.reportDate}>{fmtDate(r.created_at)}</span>
                      <span className={`${s.reportChevron}${isExpanded ? ' ' + s.reportChevronOpen : ''}`}>›</span>
                    </button>

                    {isExpanded && (
                      <div className={s.reportBody}>
                        <div className={s.reportDesc}>{r.description}</div>

                        {(r.assigned_name || r.closed_by_name) && (
                          <div className={s.reportMeta}>
                            {r.assigned_name && (
                              <div className={s.reportMetaRow}>
                                <i className="bi bi-person-check-fill" style={{ color: '#f59e0b' }} />
                                <span>Pris par <strong>{r.assigned_name}</strong></span>
                                {r.assigned_at && <><span style={{ opacity: .3 }}>·</span><span>{fmtDate(r.assigned_at)}</span>{(() => { const d = diffMins(r.created_at, r.assigned_at); return d ? <span className={s.reportMetaAccent}>({d} après)</span> : null })()}</>}
                              </div>
                            )}
                            {r.closed_by_name && (
                              <div className={s.reportMetaRow}>
                                <i className="bi bi-check-circle-fill" style={{ color: '#22c55e' }} />
                                <span>Clôturé par <strong>{r.closed_by_name}</strong></span>
                                {r.closed_at && <><span style={{ opacity: .3 }}>·</span><span>{fmtDate(r.closed_at)}</span>{(() => { const d = diffMins(r.created_at, r.closed_at); return d ? <span className={s.reportMetaGreen}>(résolu en {d})</span> : null })()}</>}
                              </div>
                            )}
                          </div>
                        )}

                        {collabs.length > 0 && (
                          <div className={s.collabTags}>
                            <span className={s.slabel} style={{ padding: 0, marginRight: 4 }}>Collabs</span>
                            {collabs.map((c, i) => <span key={i} className={s.collabTag}><i className="bi bi-person-fill" />{c}</span>)}
                          </div>
                        )}

                        {!canAct && (
                          <div className={s.lockBanner}>
                            <i className="bi bi-lock-fill" />
                            <span>Pris en charge par <strong>{r.assigned_name}</strong></span>
                          </div>
                        )}

                        {canAct && r.status === 'in_progress' && r.assigned_license === myLicense && (
                          <div className={s.collabSection}>
                            <div className={s.collabAddRow}>
                              <PlayerSelect players={players.filter(p => p.id !== r.player_id)} value={addCollabTarget[r.id] ?? ''} onChange={v => setAddCollabTarget(prev => ({ ...prev, [r.id]: v }))} />
                              <button className={s.collabAddBtn} disabled={!addCollabTarget[r.id]} onClick={() => { if (!addCollabTarget[r.id]) return; nuiPost('admin:joinReport', { id: r.id, targetId: addCollabTarget[r.id] }); setAddCollabTarget(prev => ({ ...prev, [r.id]: '' })) }}>
                                <i className="bi bi-person-plus-fill" />
                              </button>
                            </div>
                          </div>
                        )}

                        {canAct && (
                          <div className={s.reportActions}>
                            {r.status === 'open' && (<>
                              <button className={`${s.btn} ${s.btnGreen}`} onClick={() => { nuiPost('admin:updateReport', { id: r.id, status: 'in_progress' }); setReports(prev => prev.map(x => x.id === r.id ? { ...x, status: 'in_progress', assigned_license: myLicense, assigned_name: myName, assigned_at: new Date().toISOString() } : x)) }}>
                                <i className="bi bi-play-fill" /> Prendre en charge
                              </button>
                              <button className={`${s.btn} ${s.btnRed}`} style={{ marginLeft: 'auto' }} onClick={() => { nuiPost('admin:deleteReport', { id: r.id }); setReports(prev => prev.filter(x => x.id !== r.id)) }}>
                                <i className="bi bi-trash3-fill" /> Supprimer
                              </button>
                            </>)}
                            {r.status === 'in_progress' && (<>
                              <button className={`${s.btn} ${s.btnRed}`} onClick={() => { nuiPost('admin:updateReport', { id: r.id, status: 'closed' }); setReports(prev => prev.map(x => x.id === r.id ? { ...x, status: 'closed', closed_by_name: myName, closed_at: new Date().toISOString() } : x)) }}>
                                <i className="bi bi-check2" /> Clôturer
                              </button>
                              {onlinePlayer && <button className={`${s.btn} ${s.btnPurple}`} onClick={() => setSelected(onlinePlayer)}><i className="bi bi-person-fill" /> Actions joueur</button>}
                            </>)}
                            {r.status === 'closed' && (<>
                              {onlinePlayer && <button className={`${s.btn} ${s.btnPurple}`} onClick={() => setSelected(onlinePlayer)}><i className="bi bi-person-fill" /> Actions joueur</button>}
                              <button className={`${s.btn} ${s.btnRed}`} style={{ marginLeft: 'auto' }} onClick={() => { nuiPost('admin:deleteReport', { id: r.id }); setReports(prev => prev.filter(x => x.id !== r.id)) }}>
                                <i className="bi bi-trash3-fill" /> Supprimer
                              </button>
                            </>)}
                          </div>
                        )}
                      </div>
                    )}
                  </div>
                )
              })
            })()}
          </div>
        </div>
      )}

      {/* ── Sanction modal ── */}
      {sanction && (
        <div className={s.modalOverlay} onClick={e => { if (e.target === e.currentTarget) { setSanction(null); setReason(''); setDuration('') } }}>
          <div className={s.modal}>
            <div className={s.modalTitle}>
              {sanction === 'warn'  ? `Avertir ${selected?.name}` :
               sanction === 'kick'  ? `Kick ${selected?.name}` :
               sanction === 'ban'   ? `Bannir ${selected?.name}` :
               sanction === 'spawn' ? `Spawn véhicule pour ${selected?.name}` :
               `Message à ${selected?.name}`}
            </div>
            {sanction === 'ban' && (
              <div className={s.field}>
                <label>Durée (7j, 24h, 30m…)</label>
                <input className={s.input} value={duration} onChange={e => setDuration(e.target.value)} placeholder="7j" />
              </div>
            )}
            <div className={s.field}>
              <label>{sanction === 'msg' ? 'Message' : sanction === 'spawn' ? 'Modèle' : 'Raison'}</label>
              <input
                className={s.input}
                value={reason}
                onChange={e => setReason(e.target.value)}
                placeholder={sanction === 'spawn' ? 'adder, zentorno, sultan…' : '…'}
                autoFocus
              />
            </div>
            <div className={s.modalBtns}>
              <button className={`${s.btn} ${s.btnGray}`} onClick={() => { setSanction(null); setReason(''); setDuration('') }}>Annuler</button>
              <button
                className={`${s.btn} ${['kick', 'ban'].includes(sanction) ? s.btnDanger : s.btnPrimary}`}
                onClick={doSanction}
              >
                {sanction === 'warn' ? 'Avertir' : sanction === 'kick' ? 'Kick' : sanction === 'ban' ? 'Bannir' : sanction === 'spawn' ? 'Spawn' : 'Envoyer'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
