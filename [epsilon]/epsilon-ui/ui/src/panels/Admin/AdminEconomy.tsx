import { useState, useEffect, useCallback } from 'react'
import { nuiPost, onNUI } from '../../hooks/useNUI'
import s from './AdminEconomy.module.css'

// ── Types ─────────────────────────────────────────────────────────────────────

interface MarketData {
  id: number
  name: string
  label: string
  icon: string
  base_price: number
  current_price: number
  supply: number
  demand: number
  history: number[]
}

interface TxEntry {
  id: number
  amount: number   // positif = crédit, négatif = débit (calculé côté SQL)
  type: string
  label: string
  created_at: string
}

interface EcoStats {
  total_circulation: number
  account_count: number
  volume_24h: number
  tx_count_24h: number
}

type MarketEvent = 'shortage' | 'surplus' | 'crisis' | 'reset'

// ── Helpers ───────────────────────────────────────────────────────────────────

function n(v: unknown): number {
  const x = Number(v)
  return isFinite(x) ? x : 0
}

function fmt(v: unknown, decimals = 2) {
  const x = n(v)
  if (x >= 1_000_000) return (x / 1_000_000).toFixed(1) + 'M'
  if (x >= 1_000)     return (x / 1_000).toFixed(1) + 'k'
  return x.toFixed(decimals)
}

function fmtPrice(v: unknown) {
  return n(v).toLocaleString('fr-FR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

function fmtDate(raw: string) {
  const d = new Date(raw)
  if (isNaN(d.getTime())) return raw
  return d.toLocaleString('fr-FR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' })
}

function pctChange(current: unknown, base: unknown) {
  const b = n(base)
  if (!b) return 0
  return ((n(current) - b) / b) * 100
}

// ── Sparkline ─────────────────────────────────────────────────────────────────

function Sparkline({ data, w = 120, h = 36, color }: { data: unknown[]; w?: number; h?: number; color: string }) {
  const nums = (data ?? []).map(v => n(v))
  if (nums.length < 2) {
    return <svg width={w} height={h} />
  }
  const min = Math.min(...nums)
  const max = Math.max(...nums)
  const range = max - min || 1
  const pad = 2
  const pts = nums.map((v, i) => {
    const x = pad + (i / (data.length - 1)) * (w - pad * 2)
    const y = pad + (1 - (v - min) / range) * (h - pad * 2)
    return `${x.toFixed(1)},${y.toFixed(1)}`
  })
  const polyPts = pts.join(' ')
  const fillPts = `${pad},${h - pad} ${polyPts} ${(w - pad).toFixed(1)},${h - pad}`
  const gradId = `sg-${color.replace(/[^a-z0-9]/gi, '')}`
  return (
    <svg width={w} height={h} viewBox={`0 0 ${w} ${h}`} style={{ display: 'block', overflow: 'visible' }}>
      <defs>
        <linearGradient id={gradId} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%"   stopColor={color} stopOpacity="0.25" />
          <stop offset="100%" stopColor={color} stopOpacity="0.01" />
        </linearGradient>
      </defs>
      <polygon points={fillPts} fill={`url(#${gradId})`} />
      <polyline points={polyPts} fill="none" stroke={color} strokeWidth="1.5" strokeLinejoin="round" strokeLinecap="round" />
      {/* Endpoint dot */}
      {(() => {
        const last = pts[pts.length - 1].split(',')
        return <circle cx={last[0]} cy={last[1]} r="2.5" fill={color} />
      })()}
    </svg>
  )
}

// ── SupplyDemandBar ───────────────────────────────────────────────────────────

function Bar({ value, color, label }: { value: unknown; color: string; label: string }) {
  const v = n(value)
  const pct = Math.min(100, (v / 300) * 100)
  return (
    <div className={s.barWrap}>
      <span className={s.barLabel}>{label}</span>
      <div className={s.barTrack}>
        <div className={s.barFill} style={{ width: `${pct}%`, background: color }} />
      </div>
      <span className={s.barVal}>{v.toFixed(0)}</span>
    </div>
  )
}

// ── Market color logic ────────────────────────────────────────────────────────

function marketColor(pct: number): string {
  if (pct > 15)  return '#ef4444'
  if (pct > 5)   return '#f59e0b'
  if (pct < -15) return '#22c55e'
  if (pct < -5)  return '#86efac'
  return 'rgba(255,255,255,0.5)'
}

function sparklineColor(pct: number): string {
  if (pct > 5)  return '#f87171'
  if (pct < -5) return '#4ade80'
  return '#a78bfa'
}

// ── Market Card ───────────────────────────────────────────────────────────────

const EVENT_PRESETS: { key: MarketEvent; label: string; cls: string; icon: string }[] = [
  { key: 'shortage', label: 'Pénurie',  cls: s.evtAmber,  icon: 'bi-exclamation-triangle-fill' },
  { key: 'surplus',  label: 'Surplus',  cls: s.evtBlue,   icon: 'bi-arrow-down-circle-fill' },
  { key: 'crisis',   label: 'Crise',    cls: s.evtRed,    icon: 'bi-fire' },
  { key: 'reset',    label: 'Reset',    cls: s.evtGray,   icon: 'bi-arrow-counterclockwise' },
]

function MarketCard({ m, onEvent }: { m: MarketData; onEvent: (market: string, event: MarketEvent) => void }) {
  const pct     = pctChange(m.current_price, m.base_price)
  const clr     = marketColor(pct)
  const spClr   = sparklineColor(pct)
  const sign    = pct >= 0 ? '+' : ''

  return (
    <div className={s.marketCard}>
      <div className={s.marketCardTop}>
        <div className={s.marketMeta}>
          <i className={`bi ${m.icon} ${s.marketIcon}`} />
          <span className={s.marketLabel}>{m.label}</span>
        </div>
        <span className={s.marketPct} style={{ color: clr }}>
          {sign}{pct.toFixed(1)}%
        </span>
      </div>
      <div className={s.marketPrice}>{fmtPrice(m.current_price)}<span className={s.marketUnit}>$</span></div>
      <div className={s.marketBase}>Base: {fmtPrice(m.base_price)} $</div>
      <div className={s.sparklineWrap}>
        <Sparkline data={m.history} color={spClr} w={130} h={36} />
      </div>
      <div className={s.bars}>
        <Bar value={m.supply} color="#60a5fa" label="Offre" />
        <Bar value={m.demand} color="#f97316" label="Dem." />
      </div>
      <div className={s.evtRow}>
        {EVENT_PRESETS.map(ev => (
          <button
            key={ev.key}
            className={`${s.evtBtn} ${ev.cls}`}
            title={ev.label}
            onClick={() => onEvent(m.name, ev.key)}
          >
            <i className={`bi ${ev.icon}`} />
            <span>{ev.label}</span>
          </button>
        ))}
      </div>
    </div>
  )
}

// ── Transaction type styles ───────────────────────────────────────────────────

const TX_TYPE_LABELS: Record<string, string> = {
  credit:    'Crédit',    debit:    'Débit',
  transfer:  'Virement',  salary:   'Salaire',
  tax:       'Taxe',      purchase: 'Achat',
  deposit:   'Dépôt',     withdrawal: 'Retrait',
  loan_payment: 'Prêt',
}
const TX_TYPE_COLOR: Record<string, string> = {
  credit: '#22c55e', salary: '#22c55e',
  debit:  '#ef4444', tax: '#ef4444', purchase: '#f59e0b',
  transfer: '#a78bfa', deposit: '#60a5fa', withdrawal: '#fb923c',
}

// ── Main component ────────────────────────────────────────────────────────────

export default function AdminEconomy({ onClose }: { onClose: () => void }) {
  const [loading,  setLoading]  = useState(true)
  const [stats,    setStats]    = useState<EcoStats | null>(null)
  const [markets,  setMarkets]  = useState<MarketData[]>([])
  const [txs,      setTxs]      = useState<TxEntry[]>([])

  const fetchData = useCallback(() => {
    setLoading(true)
    nuiPost('economy:admin:getData', {})
  }, [])

  useEffect(() => {
    const offs = [
      onNUI<{ stats: EcoStats; markets: MarketData[]; transactions: TxEntry[] }>(
        'epsilon:economy:admin:dataResult', d => {
          setStats(d.stats)
          setMarkets(d.markets ?? [])
          setTxs(d.transactions ?? [])
          setLoading(false)
        }
      ),
      onNUI<MarketData[]>('epsilon:economy:marketUpdate', d => {
        setMarkets(d)
      }),
    ]
    fetchData()
    return () => offs.forEach(f => f())
  }, [fetchData])

  const handleEvent = useCallback((market: string, event: MarketEvent) => {
    nuiPost('economy:admin:adjustMarket', { market, event })
  }, [])

  // Sort markets consistently
  const sortedMarkets = [...markets].sort((a, b) => a.label.localeCompare(b.label, 'fr'))

  return (
    <div className={s.root}>

      {/* ── Header ── */}
      <div className={s.header}>
        <div className={s.headerLeft}>
          <button className={s.backBtn} onClick={onClose}><i className="bi bi-chevron-left" /></button>
          <span className={s.headerTitle}>Économie</span>
          {loading && <i className="bi bi-arrow-repeat" style={{ fontSize: 12, opacity: 0.4, marginLeft: 8 }} />}
        </div>
        <button className={s.refreshBtn} onClick={fetchData} title="Actualiser">
          <i className="bi bi-arrow-clockwise" />
        </button>
        <button className={s.plainClose} onClick={onClose}><i className="bi bi-x" /></button>
      </div>

      {/* ── Stats row ── */}
      <div className={s.statsRow}>
        <div className={s.statChip}>
          <i className="bi bi-currency-euro" />
          <div className={s.statBody}>
            <span className={s.statVal}>{fmt(stats?.total_circulation ?? 0)} $</span>
            <span className={s.statLbl}>Circulation</span>
          </div>
        </div>
        <div className={s.statChip}>
          <i className="bi bi-people-fill" />
          <div className={s.statBody}>
            <span className={s.statVal}>{(stats?.account_count ?? 0).toLocaleString('fr-FR')}</span>
            <span className={s.statLbl}>Comptes</span>
          </div>
        </div>
        <div className={s.statChip}>
          <i className="bi bi-graph-up-arrow" />
          <div className={s.statBody}>
            <span className={s.statVal}>{fmt(stats?.volume_24h ?? 0)} $</span>
            <span className={s.statLbl}>Volume 24h</span>
          </div>
        </div>
        <div className={s.statChip}>
          <i className="bi bi-arrow-left-right" />
          <div className={s.statBody}>
            <span className={s.statVal}>{(stats?.tx_count_24h ?? 0).toLocaleString('fr-FR')}</span>
            <span className={s.statLbl}>Transactions 24h</span>
          </div>
        </div>
      </div>

      {/* ── Body ── */}
      <div className={s.body}>

        {/* ── Markets grid ── */}
        <div className={s.col}>
          <div className={s.colHeader}><i className="bi bi-graph-up" /> Marchés</div>
          <div className={s.marketsGrid}>
            {sortedMarkets.length === 0 && !loading && (
              <div className={s.empty}><i className="bi bi-inbox" /> Aucun marché</div>
            )}
            {sortedMarkets.map(m => (
              <MarketCard key={m.id} m={m} onEvent={handleEvent} />
            ))}
          </div>
        </div>

        {/* ── Transactions ── */}
        <div className={s.colTx}>
          <div className={s.colHeader}><i className="bi bi-clock-history" /> Transactions récentes</div>
          <div className={s.txList}>
            {txs.length === 0 && !loading && (
              <div className={s.empty}><i className="bi bi-inbox" /> Aucune transaction</div>
            )}
            {txs.map(tx => {
              const typeLabel = TX_TYPE_LABELS[tx.type] ?? tx.type
              const typeColor = TX_TYPE_COLOR[tx.type] ?? 'rgba(255,255,255,0.4)'
              const isIn = tx.amount >= 0
              return (
                <div key={tx.id} className={s.txRow}>
                  <div className={s.txLeft}>
                    <span className={s.txBadge} style={{ color: typeColor, borderColor: typeColor + '44', background: typeColor + '14' }}>
                      {typeLabel}
                    </span>
                    <span className={s.txLabel}>{tx.label || '—'}</span>
                  </div>
                  <div className={s.txRight}>
                    <span className={s.txAmount} style={{ color: isIn ? '#4ade80' : '#f87171' }}>
                      {isIn ? '+' : '-'}{fmtPrice(Math.abs(tx.amount))} $
                    </span>
                    <span className={s.txDate}>{fmtDate(tx.created_at)}</span>
                  </div>
                </div>
              )
            })}
          </div>
        </div>

      </div>
    </div>
  )
}
