import { useState, useEffect, useCallback } from 'react'
import { nuiPost, onNUI } from '../../hooks/useNUI'
import s from './AdminLogs.module.css'

// ── Types ─────────────────────────────────────────────────────────────────────
interface LogEntry {
  id: number
  admin_name: string | null
  target_name: string | null
  action: string
  reason: string | null
  created_at: string
  // reports only
  status?: 'open' | 'in_progress' | 'closed'
  assigned_name?: string | null
}

type LogCategory = 'all' | 'sanctions' | 'joueur' | 'inventaire' | 'outils' | 'serveur' | 'reports' | 'context_menu'

// ── Constants ─────────────────────────────────────────────────────────────────
const CATEGORIES: { key: LogCategory; label: string; icon: string }[] = [
  { key: 'all',          label: 'Tous',          icon: 'bi-list-ul' },
  { key: 'sanctions',    label: 'Sanctions',     icon: 'bi-hammer' },
  { key: 'joueur',       label: 'Joueur',        icon: 'bi-person-fill' },
  { key: 'inventaire',   label: 'Inventaire',    icon: 'bi-box-seam' },
  { key: 'outils',       label: 'Outils',        icon: 'bi-tools' },
  { key: 'serveur',      label: 'Serveur',       icon: 'bi-server' },
  { key: 'context_menu', label: 'Context menu',  icon: 'bi-cursor-fill' },
  { key: 'reports',      label: 'Reports',       icon: 'bi-flag-fill' },
]

const REPORT_CAT_LABELS: Record<string, string> = {
  bug: 'Bug', suggestion: 'Suggestion', question: 'Question',
  triche: 'Triche', comportement: 'Comportement',
  harcelement: 'Harcèlement', autre: 'Autre',
}

const REPORT_STATUS_LABEL: Record<string, string> = {
  open: 'Ouvert', in_progress: 'En cours', closed: 'Fermé',
}

type StatusColor = 'red' | 'amber' | 'gray'
function reportStatusColor(status?: string): StatusColor {
  if (status === 'open')        return 'red'
  if (status === 'in_progress') return 'amber'
  return 'gray'
}

const ACTION_LABELS: Record<string, string> = {
  warn: 'Avertissement', kick: 'Kick', ban: 'Ban',
  give_item: 'Item donné', remove_item: 'Item retiré', give_self_item: 'Item perso',
  item_save: 'Item sauvegardé', item_delete: 'Item supprimé', item_duplicate: 'Item dupliqué',
  heal_player: 'Heal vie', kill_player: 'Tuer', revive_player: 'Revive',
  freeze_player: 'Freeze', toggle_fire: 'Feu', toggle_cage: 'Cage',
  damage_player: 'Dégâts', teleport_to: 'TP vers', bring_player: 'TP ici',
  bring_back: 'Bring Back', heal_armour: 'Heal armure',
  fill_player_hunger: 'Remplir faim', fill_player_thirst: 'Remplir soif',
  drain_player_hunger: 'Vider faim', drain_player_thirst: 'Vider soif',
  announce: 'Annonce globale', teleport_coords: 'TP coordonnées', teleport_waypoint: 'TP waypoint',
  mass_delete_vehicles: 'Suppr. véhicules', mass_delete_peds: 'Suppr. peds',
  super_sprint_on: 'Super Sprint ON', super_sprint_off: 'Super Sprint OFF',
  super_jump_on: 'Super Jump ON', super_jump_off: 'Super Jump OFF',
  super_swim_on: 'Super Swim ON', super_swim_off: 'Super Swim OFF',
  stamina_on: 'Stamina ON', stamina_off: 'Stamina OFF',
  show_names_on: 'Noms ON', show_names_off: 'Noms OFF',
  show_blips_on: 'Blips ON', show_blips_off: 'Blips OFF',
  self_heal_health: 'Heal perso', self_heal_armour: 'Armure perso',
  self_damage: 'Dégâts perso', self_suicide: 'Suicide perso', self_revive: 'Revive perso',
  self_fix_vehicle: 'Réparer véh.', self_clean_vehicle: 'Laver véh.',
  self_refuel: 'Réservoir véh.', self_change_plate: 'Plaque véh.',
  self_engine_damage: 'Moteur véh.', self_break_windows: 'Fenêtres véh.',
  self_burst_tyres: 'Pneus véh.', self_freeze_vehicle: 'Freeze véh.',
  self_spawn_vehicle: 'Spawn véh.', self_delete_vehicle: 'Suppr. véh.',
  spawn_vehicle_for: 'Spawn véh. joueur',
  // Context menu
  ctx_fix_vehicle:    '[CTX] Réparer véh.',
  ctx_delete_vehicle: '[CTX] Supprimer véh.',
  ctx_refuel_vehicle: '[CTX] Ravitailler véh.',
  ctx_heal:           '[CTX] Heal',
  ctx_revive:         '[CTX] Revive',
  ctx_kill:           '[CTX] Tuer',
  ctx_freeze:         '[CTX] Freeze',
  ctx_bring:          '[CTX] Bring',
  ctx_goto:           '[CTX] Goto',
  ctx_kick:           '[CTX] Kick',
  ctx_warn:           '[CTX] Warn',
  ctx_staff_message:  '[CTX] Message staff',
  ctx_teleport_coords:'[CTX] TP coordonnées',
  ctx_spawn_vehicle:  '[CTX] Spawn véh.',
  ctx_explosion:      '[CTX] Explosion',
}

type BadgeColor = 'red' | 'amber' | 'green' | 'purple' | 'blue' | 'gray'

function badgeColor(action: string): BadgeColor {
  if (['ban', 'kill_player', 'damage_player', 'self_damage', 'self_suicide', 'toggle_fire', 'mass_delete_vehicles', 'mass_delete_peds', 'item_delete', 'drain_player_hunger', 'drain_player_thirst', 'ctx_kill', 'ctx_delete_vehicle', 'ctx_explosion'].includes(action)) return 'red'
  if (['warn', 'kick', 'freeze_player', 'toggle_cage', 'remove_item', 'self_burst_tyres', 'self_break_windows', 'self_engine_damage', 'ctx_warn', 'ctx_kick', 'ctx_freeze'].includes(action)) return 'amber'
  if (['give_item', 'heal_player', 'revive_player', 'heal_armour', 'fill_player_hunger', 'fill_player_thirst', 'self_heal_health', 'self_heal_armour', 'self_revive', 'ctx_heal', 'ctx_revive', 'ctx_fix_vehicle', 'ctx_refuel_vehicle'].includes(action)) return 'green'
  if (['item_save', 'item_duplicate', 'give_self_item', 'spawn_vehicle_for', 'self_spawn_vehicle', 'announce', 'ctx_spawn_vehicle'].includes(action)) return 'purple'
  if (['teleport_to', 'bring_player', 'bring_back', 'teleport_coords', 'teleport_waypoint', 'ctx_bring', 'ctx_goto', 'ctx_teleport_coords'].includes(action)) return 'blue'
  return 'gray'
}

function fmtDate(raw: string) {
  const d = new Date(raw)
  if (isNaN(d.getTime())) return raw
  return d.toLocaleString('fr-FR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit' })
}

// ── Log detail panel ──────────────────────────────────────────────────────────
function LogDetail({ log, isReport }: { log: LogEntry; isReport: boolean }) {
  const color = isReport ? reportStatusColor(log.status) : badgeColor(log.action)
  const label = isReport ? (REPORT_CAT_LABELS[log.action] ?? log.action) : (ACTION_LABELS[log.action] ?? log.action)
  return (
    <div className={s.detail}>
      <div className={s.detailHeader}>
        <span className={`${s.badge} ${s[`badge_${color}`]}`}>{label}</span>
        {isReport && log.status && (
          <span className={`${s.badge} ${s[`badge_${reportStatusColor(log.status)}`]}`} style={{ opacity: 0.65 }}>
            {REPORT_STATUS_LABEL[log.status]}
          </span>
        )}
        <span className={s.detailId}>#{log.id}</span>
      </div>
      <div className={s.detailBody}>
        <div className={s.detailRow}>
          <span className={s.detailKey}><i className={isReport ? 'bi bi-person' : 'bi bi-person-badge'} /> {isReport ? 'Auteur' : 'Admin'}</span>
          <span className={s.detailVal}>{log.admin_name ?? '—'}</span>
        </div>
        {log.target_name && (
          <div className={s.detailRow}>
            <span className={s.detailKey}><i className="bi bi-person" /> Cible</span>
            <span className={s.detailVal}>{log.target_name}</span>
          </div>
        )}
        {isReport && log.assigned_name && (
          <div className={s.detailRow}>
            <span className={s.detailKey}><i className="bi bi-person-badge" /> Assigné à</span>
            <span className={s.detailVal}>{log.assigned_name}</span>
          </div>
        )}
        {!isReport && (
          <div className={s.detailRow}>
            <span className={s.detailKey}><i className="bi bi-code" /> Action</span>
            <span className={s.detailValMono}>{log.action}</span>
          </div>
        )}
        <div className={s.detailRow}>
          <span className={s.detailKey}><i className="bi bi-clock" /> Date</span>
          <span className={s.detailVal}>{fmtDate(log.created_at)}</span>
        </div>
        {log.reason && (
          <div className={s.detailRowFull}>
            <span className={s.detailKey}><i className="bi bi-chat-left-text" /> {isReport ? 'Description' : 'Détail / Raison'}</span>
            <span className={s.detailValBlock}>{log.reason}</span>
          </div>
        )}
      </div>
    </div>
  )
}

// ── Main component ────────────────────────────────────────────────────────────
export default function AdminLogs({ onClose }: { onClose: () => void }) {
  const [logs,      setLogs]      = useState<LogEntry[]>([])
  const [loading,   setLoading]   = useState(true)
  const [category,  setCategory]  = useState<LogCategory>('all')
  const [search,    setSearch]    = useState('')
  const [offset,    setOffset]    = useState(0)
  const [hasMore,   setHasMore]   = useState(false)
  const [selected,  setSelected]  = useState<LogEntry | null>(null)
  const [isReports, setIsReports] = useState(false)

  const fetch = useCallback((cat: LogCategory, q: string, off: number) => {
    setLoading(true)
    nuiPost('admin:getLogs', { category: cat, search: q, offset: off })
  }, [])

  useEffect(() => {
    const off = onNUI<{ logs: LogEntry[]; hasMore: boolean; offset: number; isReports?: boolean }>('epsilon:admin:logsResult', d => {
      setLogs(prev => d.offset === 0 ? d.logs : [...prev, ...d.logs])
      setHasMore(d.hasMore)
      setOffset(d.offset + d.logs.length)
      setIsReports(d.isReports ?? false)
      setLoading(false)
    })
    fetch('all', '', 0)
    return off
  }, [fetch])

  // Debounce search
  useEffect(() => {
    const t = setTimeout(() => { setOffset(0); setSelected(null); fetch(category, search, 0) }, 350)
    return () => clearTimeout(t)
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [search])

  const switchCategory = (cat: LogCategory) => {
    setCategory(cat)
    setOffset(0)
    setSelected(null)
    setIsReports(false)
    fetch(cat, search, 0)
  }

  return (
    <div className={s.root}>

      {/* ── Header ── */}
      <div className={s.header}>
        <div className={s.headerLeft}>
          <button className={s.backBtn} onClick={onClose}><i className="bi bi-chevron-left" /></button>
          <span className={s.headerTitle}>Logs d'administration</span>
        </div>
        <button className={s.plainClose} onClick={onClose}><i className="bi bi-x" /></button>
      </div>

      {/* ── Body ── */}
      <div className={s.body}>

        {/* ── Colonne catégories ── */}
        <div className={s.col}>
          <div className={s.colHeader}>Catégories</div>
          <div className={s.sidebar}>
            <div className={s.catList}>
              {CATEGORIES.map(c => (
                <div
                  key={c.key}
                  className={`${s.catRow}${category === c.key ? ' ' + s.catActive : ''}`}
                  onClick={() => switchCategory(c.key)}
                >
                  <i className={`bi ${c.icon}`} /> {c.label}
                </div>
              ))}
            </div>
          </div>
          <div className={s.sidebarSearch}>
            <i className="bi bi-search" />
            <input
              className={s.searchInput}
              placeholder="Admin, cible, action…"
              value={search}
              onChange={e => setSearch(e.target.value)}
            />
            {search && <button className={s.searchClear} onClick={() => setSearch('')}><i className="bi bi-x" /></button>}
          </div>
        </div>

        {/* ── Colonne liste ── */}
        <div className={`${s.col} ${s.colMain}`}>
          <div className={s.colHeader}>
            Liste des logs
            {loading && <i className="bi bi-arrow-repeat" style={{ marginLeft: 8, fontSize: 10, opacity: 0.5 }} />}
          </div>
          <div className={s.logList}>
            {!loading && logs.length === 0 ? (
              <div className={s.empty}><i className="bi bi-inbox" /> Aucun log trouvé</div>
            ) : logs.map(log => {
              const isActive = selected?.id === log.id
              const color = isReports ? reportStatusColor(log.status) : badgeColor(log.action)
              const label = isReports
                ? (REPORT_CAT_LABELS[log.action] ?? log.action)
                : (ACTION_LABELS[log.action] ?? log.action)
              return (
                <div
                  key={log.id}
                  className={`${s.logRow}${isActive ? ' ' + s.logRowActive : ''}`}
                  onClick={() => setSelected(isActive ? null : log)}
                >
                  <div className={s.logRowTop}>
                    <span className={`${s.badge} ${s[`badge_${color}`]}`}>{label}</span>
                    {isReports && log.status && (
                      <span className={`${s.badge} ${s[`badge_${reportStatusColor(log.status)}`]}`} style={{ opacity: 0.6 }}>
                        {REPORT_STATUS_LABEL[log.status]}
                      </span>
                    )}
                    <span className={s.logDate}>{fmtDate(log.created_at)}</span>
                  </div>
                  <div className={s.logRowSub}>
                    <span className={s.logAdmin}>
                      <i className={isReports ? 'bi bi-person' : 'bi bi-person-badge'} />
                      {log.admin_name ?? '—'}
                    </span>
                    {log.target_name && <span className={s.logTarget}><i className="bi bi-arrow-right" /> {log.target_name}</span>}
                    {log.reason && <span className={s.logReason}>{log.reason}</span>}
                  </div>
                </div>
              )
            })}
            {hasMore && (
              <button className={s.loadMore} onClick={() => fetch(category, search, offset)} disabled={loading}>
                <i className="bi bi-arrow-down" /> Charger plus
              </button>
            )}
          </div>
        </div>

        {/* ── Colonne détail ── */}
        <div className={s.col} style={{ width: 320 }}>
          <div className={s.colHeader}>Détail</div>
          {selected
            ? <LogDetail log={selected} isReport={isReports} />
            : <div className={s.noSelection}><i className="bi bi-journal-text" style={{ fontSize: 32, opacity: 0.15 }} /><span>Sélectionnez un log</span></div>
          }
        </div>

      </div>
    </div>
  )
}
