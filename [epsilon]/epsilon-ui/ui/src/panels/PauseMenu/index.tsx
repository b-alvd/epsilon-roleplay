import { useState, useEffect, useCallback } from 'react'
import { nuiPost } from '../../hooks/useNUI'
import s from './PauseMenu.module.css'
import SupportPanel from './SupportPanel'

/* ── Types ──────────────────────────────────────────────────── */
type TileId = 'personnage' | 'carte' | 'reglages' | 'support'

export interface JobEntry {
  name:       string
  label:      string
  gradeLabel: string
  salary:     number
  color:      string
  type:       string
}

export interface PauseMenuData {
  playerName?:    string
  characterName?: string
  serverId?:      number
  ping?:          number
  citizenId?:     string
  jobs?:          JobEntry[]
  health?:        number
  armor?:         number
  hunger?:        number
  thirst?:        number
  cash?:          number
  bankBalance?:   number
  playtime?:      number   // secondes
  discord?:       string
}

/* ── Tuiles ─────────────────────────────────────────────────── */
const TILES: { id: TileId; label: string; icon: string; bg: string }[] = [
  { id: 'personnage', label: 'Personnage', icon: 'bi-person-fill',
    bg: 'linear-gradient(160deg,#0f1923 0%,#162030 60%,#1c2d40 100%)' },
  { id: 'carte',      label: 'Carte',      icon: 'bi-map-fill',
    bg: 'linear-gradient(160deg,#0d2218 0%,#12352a 60%,#183d30 100%)' },
  { id: 'reglages',   label: 'Réglages',   icon: 'bi-gear-fill',
    bg: 'linear-gradient(160deg,#181818 0%,#242424 60%,#2e2e2e 100%)' },
  { id: 'support',    label: 'Support',    icon: 'bi-headset',
    bg: 'linear-gradient(160deg,#12101e 0%,#1a1730 60%,#221e3a 100%)' },
]


/* ── Helpers ────────────────────────────────────────────────── */
function pingCls(ms: number, s: Record<string, string>) {
  return ms < 80 ? s.pingG : ms < 150 ? s.pingO : s.pingR
}

function fmtMoney(n: number) {
  return n.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + ' $'
}
function fmtPlaytime(secs: number) {
  const h = Math.floor(secs / 3600)
  const m = Math.floor((secs % 3600) / 60)
  if (h === 0) return `${m}m`
  return `${h}h ${String(m).padStart(2, '0')}m`
}

/* ── Ring SVG (pattern inventaire) ─────────────────────────── */
const RING_R = 27
const RING_C = 2 * Math.PI * RING_R

function StatRing({ pct, color, icon, label }: { pct: number; color: string; icon: string; label: string }) {
  const clamped = Math.max(0, Math.min(100, pct))
  const offset  = RING_C - (clamped / 100) * RING_C
  return (
    <div className={s.pRingItem}>
      <div className={s.pRingCircle}>
        <i className={`bi ${icon}`} style={{ position: 'absolute', top: '50%', left: '50%',
          transform: 'translate(-50%,-50%)', fontSize: 15, color: 'rgba(255,255,255,0.35)',
          pointerEvents: 'none', zIndex: 1 }} />
        <svg height="60" width="60" style={{ position: 'absolute', top: 0, left: 0 }}>
          <circle cx="30" cy="30" r={RING_R} fill="transparent" stroke={color + '33'} strokeWidth="5" />
        </svg>
        <svg height="60" width="60" style={{ position: 'absolute', top: 0, left: 0 }}>
          <circle cx="30" cy="30" r={RING_R} fill="transparent" stroke={color} strokeWidth="5.5"
            strokeDasharray={RING_C} strokeDashoffset={offset}
            style={{ transform: 'rotate(-90deg)', transformOrigin: '50% 50%',
              transition: 'stroke-dashoffset .6s ease, stroke .3s ease' }} />
        </svg>
      </div>
      <span className={s.pRingPct}>{Math.round(clamped)}%</span>
      <span className={s.pRingLabel}>{label}</span>
    </div>
  )
}

/* ── Panel Personnage ───────────────────────────────────────── */
function PersonnagePanel({ data, onBack }: { data: PauseMenuData; onBack: () => void }) {
  const hp      = Math.max(0, Math.min(100, data.health ?? 100))
  const hpColor = hp > 60 ? '#4ade80' : hp > 30 ? '#fbbf24' : '#f87171'

  return (
    <div className={s.pPanel}>

      {/* Header */}
      <div className={s.pHead}>
        <button className={s.pCloseBtn} onClick={onBack}><i className="bi bi-arrow-left" /></button>
        <span className={s.pHeadTitle}>Personnage</span>
      </div>

      {/* Corps — grille 2×2 */}
      <div className={s.pGrid}>

        {/* ── Haut gauche : identité ── */}
        <div className={s.pGridTL}>
          <div className={s.pSlabel}>Identité</div>
          <div className={s.pIdentity}>
            {/* Bloc nom + avatar initial */}
            <div className={s.pIdMain}>
              <div className={s.pIdInitial}>
                {(data.characterName || data.playerName || '?')[0].toUpperCase()}
              </div>
              <div className={s.pIdNames}>
                <span className={s.pIdCharName}>
                  {data.characterName || data.playerName || '—'}
                </span>
                {data.characterName && data.playerName && (
                  <span className={s.pIdAccount}>
                    <i className="bi bi-controller" /> {data.playerName}
                  </span>
                )}
              </div>
            </div>

            {/* Chips d'infos */}
            <div className={s.pIdChips}>
              {data.citizenId && (
                <div className={s.pIdChip}>
                  <span className={s.pIdChipLabel}>UID</span>
                  <span className={s.pIdChipVal}>#{data.citizenId}</span>
                </div>
              )}
              <div className={s.pIdChip}>
                <span className={s.pIdChipLabel}>ID Session</span>
                <span className={s.pIdChipVal}>#{data.serverId ?? '—'}</span>
              </div>
              {data.playtime != null && (
                <div className={s.pIdChip}>
                  <span className={s.pIdChipLabel}>Temps de jeu</span>
                  <span className={s.pIdChipVal}>{fmtPlaytime(data.playtime)}</span>
                </div>
              )}
              {data.ping != null && (
                <div className={`${s.pIdChip} ${pingCls(data.ping, s)}`}>
                  <span className={s.pIdChipLabel}>Latence</span>
                  <span className={s.pIdChipVal}>{data.ping} ms</span>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* ── Haut droite : finances ── */}
        <div className={s.pGridTR}>
          <div className={s.pSlabel}>Finances</div>
          <div className={s.pFinList}>
            <div className={`${s.pFinRow} ${s.pRowOdd}`}>
              <i className="bi bi-cash-stack" style={{ color: '#4ade80' }} />
              <span className={s.pFinRowLabel}>Liquide</span>
              <span className={s.pFinRowVal}>{fmtMoney(data.cash ?? 0)}</span>
            </div>
            <div className={`${s.pFinRow} ${s.pRowEven}`}>
              <i className="bi bi-bank2" style={{ color: '#a78bfa' }} />
              <span className={s.pFinRowLabel}>Compte banque</span>
              <span className={s.pFinRowVal}>{fmtMoney(data.bankBalance ?? 0)}</span>
            </div>
          </div>
        </div>

        {/* ── Bas gauche : emploi ── */}
        <div className={s.pGridBL}>
          <div className={s.pSlabel}>Emploi</div>
          {data.jobs && data.jobs.length > 0 ? data.jobs.map((job, i) => (
            <div key={job.name} className={`${s.pRow} ${i % 2 === 0 ? s.pRowOdd : s.pRowEven}`}>
              <div className={s.pRowLeft}>
                <span className={s.pJobDot} style={{ background: job.color }} />
                <div className={s.pJobInfo}>
                  <span>{job.label}</span>
                  <span className={s.pJobGrade}>{job.gradeLabel}</span>
                </div>
              </div>
              <div className={s.pRowVal}>{job.salary.toLocaleString('fr-FR')} $/h</div>
            </div>
          )) : (
            <div className={`${s.pRow} ${s.pRowOdd} ${s.pRowMuted}`}>
              <div className={s.pRowLeft}><i className="bi bi-briefcase" />Sans emploi</div>
            </div>
          )}
        </div>

        {/* ── Bas droite : état ── */}
        <div className={s.pGridBR}>
          <div className={s.pSlabel}>État</div>
          <div className={s.pRings}>
            <StatRing pct={hp}                 color={hpColor}  icon="bi-heart-fill"   label="Santé"  />
            <StatRing pct={data.armor  ?? 0}   color="#a78bfa"  icon="bi-shield-fill"  label="Armure" />
            <StatRing pct={data.hunger ?? 100} color="#fbbf24"  icon="bi-egg-fried"    label="Faim"   />
            <StatRing pct={data.thirst ?? 100} color="#38bdf8"  icon="bi-droplet-fill" label="Soif"   />
          </div>
        </div>

      </div>
    </div>
  )
}


/* ── Composant principal ────────────────────────────────────── */
export default function PauseMenu({ data, onClose }: { data: PauseMenuData; onClose: () => void }) {
  const [activeSub, setActiveSub] = useState<TileId | null>(null)

  const handleKey = useCallback((e: KeyboardEvent) => {
    if (e.key === 'Escape') {
      if (activeSub) setActiveSub(null)
      else onClose()
    }
  }, [activeSub, onClose])

  useEffect(() => {
    window.addEventListener('keydown', handleKey)
    return () => window.removeEventListener('keydown', handleKey)
  }, [handleKey])

  const NATIVE_TILES: TileId[] = ['carte', 'reglages']

  const handleTile = (id: TileId) => {
    nuiPost('pausemenu:tile', { id })
    if (!NATIVE_TILES.includes(id)) setActiveSub(id)
  }

  const [left, right] = [TILES.slice(0, 2), TILES.slice(2)]

  return (
    <div className={s.overlay}>
      <div className={s.serverInfo}>
        <span className={s.serverName}>EPSILON RP</span>
        {data.serverId && <span className={s.playerInfo}><i className="bi bi-wifi" /> ID {data.serverId}</span>}
      </div>

      {activeSub ? (
        <div className={s.subWrap}>
          {activeSub === 'personnage' && <PersonnagePanel data={data} onBack={() => setActiveSub(null)} />}
          {activeSub === 'support'    && <SupportPanel discord={data.discord} onBack={() => setActiveSub(null)} />}
        </div>
      ) : (
        <div className={s.grid}>
          {left.map(t => (
            <button key={t.id} className={s.tile} style={{ background: t.bg }} onClick={() => handleTile(t.id)}>
              <div className={s.tileOverlay} />
              <div className={s.tileCnt}>
                <i className={`bi ${t.icon} ${s.tileIcon}`} />
                <span className={s.tileLabel}>{t.label.toUpperCase()}</span>
              </div>
            </button>
          ))}
          <div className={s.sideCol}>
            {right.map(t => (
              <button key={t.id} className={`${s.tile} ${s.tileSide}`} style={{ background: t.bg }} onClick={() => handleTile(t.id)}>
                <div className={s.tileOverlay} />
                <div className={s.tileCnt}>
                  <i className={`bi ${t.icon} ${s.tileIcon}`} />
                  <span className={s.tileLabel}>{t.label.toUpperCase()}</span>
                </div>
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
