import { useState, useEffect, useCallback, useRef } from 'react'
import { nuiPost, onNUI } from '../../hooks/useNUI'
import s from './Bank.module.css'

// ── Types ─────────────────────────────────────────────────────────────────────

interface BankAccount { id: number; iban: string; balance: number; savings: number }

interface SavingsPlacement { id: number; character_id: number; profile: string; amount: number; deposited_at: string; last_tick_at: string }
interface SavingsRates { secure: number; mixed: number; aggressive: number; score: number }
interface SavingsData {
  placement: SavingsPlacement | null
  rates:     SavingsRates
  history:   { secure: number[]; mixed: number[]; aggressive: number[] }
}
interface BankTx { id: number; amount: number; type: string; label: string; created_at: string }
interface WeekDay { day: string; day_name: string; deposits: number; withdrawals: number }
interface Character { firstname: string; lastname: string }

export interface CardInfo {
  tier:        string
  label:       string
  color:       string
  expires:     string
  hasPin:      boolean
  number?:     string
  cvv?:        string
  pin?:        string
  maxWithdraw: number
  dailyLimit:  number
  dailyUsed:   number
}

export interface CardTier {
  id:          string
  label:       string
  color:       string
  price:       number
  monthly:     number
  maxWithdraw: number
  dailyLimit:  number
  description: string
}

export interface BankData {
  mode:         'bank' | 'atm'
  account:      BankAccount
  cash:         number
  transactions: BankTx[]
  weekly:       WeekDay[]
  character:    Character
  card?:        CardInfo | null
  cardTiers?:   CardTier[]
  savings?:     SavingsData | null
}

type Page = 'accueil' | 'virement' | 'historique' | 'carte' | 'epargne'

// ── Helpers ───────────────────────────────────────────────────────────────────

const n = (v: unknown) => { const x = Number(v); return isFinite(x) ? x : 0 }

function fmtMoney(v: unknown) {
  return n(v).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

function fmtIban(iban: string) {
  return iban || ''
}

function fmtDate(raw: string) {
  const d = new Date(raw)
  if (isNaN(d.getTime())) return raw
  return d.toLocaleString('fr-FR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' })
}

const DAY_SHORT: Record<string, string> = {
  Monday: 'Lun', Tuesday: 'Mar', Wednesday: 'Mer',
  Thursday: 'Jeu', Friday: 'Ven', Saturday: 'Sam', Sunday: 'Dim',
}

const TX_LABELS: Record<string, string> = {
  deposit: 'Dépôt', withdrawal: 'Retrait', transfer: 'Virement',
  credit: 'Crédit', debit: 'Débit', salary: 'Salaire',
  tax: 'Taxe', purchase: 'Achat', loan_payment: 'Prêt',
}

const TX_IN = new Set(['deposit', 'credit', 'salary', 'mission', 'aide', 'refund'])

// ── Reveal field (CVV / PIN) ──────────────────────────────────────────────────

function RevealField({ label, value, mask }: { label: string; value?: string; mask: string }) {
  const [visible, setVisible] = useState(false)
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null)
  const reveal = () => {
    if (!value) return
    setVisible(true)
    if (timer.current) clearTimeout(timer.current)
    timer.current = setTimeout(() => setVisible(false), 5000)
  }
  useEffect(() => () => { if (timer.current) clearTimeout(timer.current) }, [])
  return (
    <div className={s.revealRow} onClick={reveal}>
      <span className={s.revealLabel}>{label}</span>
      <span className={s.revealVal} style={{ letterSpacing: visible ? '0.05em' : '0.2em', opacity: visible ? 1 : 0.35 }}>
        {visible ? value : mask}
      </span>
      {value && !visible && <span className={s.revealHint}>Cliquer</span>}
    </div>
  )
}

// ── Bar chart ─────────────────────────────────────────────────────────────────

function WeekChart({ data }: { data: WeekDay[] }) {
  if (!data || data.length === 0) {
    return (
      <div className={s.chartEmpty}>
        <i className="bi bi-bar-chart" /><span>Aucune donnée cette semaine</span>
      </div>
    )
  }

  const maxVal = Math.max(...data.flatMap(d => [n(d.deposits), n(d.withdrawals)]), 1)
  const W = 560; const H = 190
  const pad = { t: 10, r: 10, b: 42, l: 48 }
  const innerW = W - pad.l - pad.r
  const innerH = H - pad.t - pad.b
  const colW   = innerW / data.length
  const barW   = Math.min(colW * 0.32, 22)
  const gap    = barW * 0.4

  const yLines = [0, 0.25, 0.5, 0.75, 1].map(f => ({
    y: pad.t + innerH * (1 - f),
    label: fmtMoney(maxVal * f),
  }))

  return (
    <svg viewBox={`0 0 ${W} ${H}`} className={s.chart}>
      {yLines.map((l, i) => (
        <g key={i}>
          <line x1={pad.l} x2={W - pad.r} y1={l.y} y2={l.y} stroke="rgba(255,255,255,0.06)" strokeWidth="1" />
          <text x={pad.l - 6} y={l.y + 3.5} textAnchor="end" fontSize="9" fill="rgba(255,255,255,0.25)">{l.label}</text>
        </g>
      ))}
      {data.map((d, i) => {
        const cx   = pad.l + colW * i + colW / 2
        const depH = (n(d.deposits)    / maxVal) * innerH
        const witH = (n(d.withdrawals) / maxVal) * innerH
        const dateStr = (() => {
          if (!d.day) return ''
          const raw = d.day
          if (typeof raw === 'number') {
            const dt = new Date(raw)
            if (isNaN(dt.getTime())) return ''
            return String(dt.getDate()).padStart(2,'0') + '/' + String(dt.getMonth()+1).padStart(2,'0')
          }
          return String(raw).slice(5).replace('-','/')
        })()
        return (
          <g key={i}>
            <rect x={cx - gap / 2 - barW} y={pad.t + innerH - depH} width={barW} height={depH} fill="rgba(74,222,128,0.7)" rx="0" />
            <rect x={cx + gap / 2}         y={pad.t + innerH - witH} width={barW} height={witH} fill="rgba(248,113,113,0.7)" rx="0" />
            <text x={cx} y={H - pad.b + 13} textAnchor="middle" fontSize="9" fill="rgba(255,255,255,0.35)">
              {DAY_SHORT[d.day_name] ?? d.day_name?.slice(0, 3)}
            </text>
            <text x={cx} y={H - pad.b + 25} textAnchor="middle" fontSize="8" fill="rgba(255,255,255,0.2)">
              {dateStr}
            </text>
          </g>
        )
      })}
    </svg>
  )
}

// ── Table transactions (réutilisée accueil + historique) ──────────────────────

function TxTable({ txs, limit }: { txs: BankTx[]; limit?: number }) {
  const rows = limit ? txs.slice(0, limit) : txs
  return (
    <div className={s.txTable}>
      <div className={s.txHead}>
        <span /><span>Libellé</span><span>Date</span><span>Montant</span><span>Type</span>
      </div>
      <div className={s.txScroll}>
        {rows.length === 0 && (
          <div className={s.txEmpty}><i className="bi bi-inbox" /> Aucune transaction</div>
        )}
        {rows.map(tx => {
          const isIn = TX_IN.has(tx.type)
          return (
            <div key={tx.id} className={s.txRow}>
              <div className={s.txDot} style={{ background: isIn ? 'rgba(74,222,128,0.7)' : 'rgba(248,113,113,0.7)' }} />
              <span className={s.txLabel}>{tx.label || ''}</span>
              <span className={s.txDate}>{fmtDate(tx.created_at)}</span>
              <span className={s.txAmount} style={{ color: isIn ? '#4ade80' : '#f87171' }}>
                {isIn ? '+' : '-'}{fmtMoney(tx.amount)} $
              </span>
              <span className={s.txType}>{TX_LABELS[tx.type] ?? tx.type}</span>
            </div>
          )
        })}
      </div>
    </div>
  )
}

// ── Page virement ─────────────────────────────────────────────────────────────

function TransferPage({ balance }: { balance: number }) {
  const [targetIban, setTargetIban] = useState('')
  const [amount,     setAmount]     = useState('')
  const [label,      setLabel]      = useState('')
  const [sent,       setSent]       = useState(false)

  const amt   = parseFloat(amount) || 0
  const valid = targetIban.trim() !== '' && amt > 0 && amt <= balance

  const doTransfer = () => {
    if (!valid) return
    nuiPost('bank:transfer', { targetIban: targetIban.trim(), amount: amt, label: label.trim() || 'Virement' })
    setSent(true)
    setTimeout(() => setSent(false), 3000)
  }

  const fields: { icon: string; label: string; node: React.ReactNode }[] = [
    {
      icon: 'bi-credit-card-2-front',
      label: 'IBAN destinataire',
      node: <input className={s.infoInput} type="text" placeholder="EP-XXXX-XXXX-XXXX-XXXX-XXXX"
        value={targetIban} onChange={e => setTargetIban(e.target.value.toUpperCase())} maxLength={27} />,
    },
    {
      icon: 'bi-cash',
      label: 'Montant',
      node: (
        <div style={{ display: 'flex', alignItems: 'center', flex: 1, minWidth: 0 }}>
          <input className={s.infoInput} type="number" placeholder="0" min={1} max={balance}
            value={amount} onChange={e => setAmount(e.target.value)}
            style={{ borderRight: 'none' }} />
          <span className={s.infoSuffix}>$</span>
        </div>
      ),
    },
    {
      icon: 'bi-chat-left-text',
      label: 'Motif',
      node: <input className={s.infoInput} placeholder="Optionnel…"
        value={label} onChange={e => setLabel(e.target.value)} maxLength={80} />,
    },
    {
      icon: 'bi-wallet2',
      label: 'Solde après',
      node: <span className={s.infoReadonly}>{fmtMoney(balance - amt)} $</span>,
    },
  ]

  return (
    <div className={s.transferWrap}>
      <div className={s.infoSectionLabel}>Virement bancaire</div>
      <div className={s.infoList}>
        {fields.map((f, i) => (
          <div key={i} className={s.infoRow}>
            <div className={s.infoRowLeft}><i className={`bi ${f.icon}`} />{f.label}</div>
            {f.node}
          </div>
        ))}
      </div>
      <div className={s.formActions}>
        <button
          className={`${s.actionRow} ${s.actionPrimary}`}
          disabled={!valid || sent}
          onClick={doTransfer}
        >
          {sent
            ? <><i className="bi bi-check2" /> Virement envoyé</>
            : <><i className="bi bi-send-fill" /> Envoyer {valid ? `${fmtMoney(amt)} $` : ''}</>
          }
        </button>
      </div>
    </div>
  )
}

// ── Page épargne ─────────────────────────────────────────────────────────────

const PROFILES = [
  { id: 'secure',     label: 'Sécurisé',   color: '#4ade80', desc: 'Taux fixe, aucun risque.',                icon: 'bi-shield-fill-check' },
  { id: 'mixed',      label: 'Mixte',       color: '#facc15', desc: 'Rendement lié aux marchés, risque modéré.', icon: 'bi-graph-up-arrow' },
  { id: 'aggressive', label: 'Agressif',    color: '#f87171', desc: 'Fort potentiel, pertes possibles.',       icon: 'bi-lightning-fill' },
]

function RateSparkline({ data, color }: { data: number[]; color: string }) {
  if (!data || data.length < 2) return <div className={s.sparklineEmpty}>Aucun historique</div>
  const W = 200; const H = 40
  const min = Math.min(...data); const max = Math.max(...data)
  const range = max - min || 0.0001
  const pts = data.map((v, i) => {
    const x = (i / (data.length - 1)) * W
    const y = H - ((v - min) / range) * (H - 6) - 3
    return `${x},${y}`
  }).join(' ')
  const zeroY = H - ((0 - min) / range) * (H - 6) - 3
  return (
    <svg viewBox={`0 0 ${W} ${H}`} className={s.sparkline} preserveAspectRatio="none">
      <line x1={0} x2={W} y1={Math.min(H, Math.max(0, zeroY))} y2={Math.min(H, Math.max(0, zeroY))}
        stroke="rgba(255,255,255,0.1)" strokeWidth="1" strokeDasharray="3,3" />
      <polyline points={pts} fill="none" stroke={color} strokeWidth="1.5" />
    </svg>
  )
}

function SavingsPage({ data, balance }: { data: SavingsData; balance: number }) {
  const [amount,  setAmount]  = useState('')
  const [profile, setProfile] = useState<string>('secure')
  const [confirm, setConfirm] = useState(false)

  const p  = data.placement
  const amt = Math.max(0, parseFloat(amount) || 0)
  const valid = !p && amt >= 500 && amt <= balance
  const score = data.rates?.score ?? 0
  const scoreLabel = score > 0.3 ? 'Marchés favorables' : score < -0.3 ? 'Marchés en crise' : 'Marchés neutres'
  const scoreColor = score > 0.3 ? '#4ade80' : score < -0.3 ? '#f87171' : '#facc15'

  const doDeposit = () => {
    if (!valid) return
    nuiPost('bank:savings:deposit', { amount: amt, profile })
    setAmount(''); setConfirm(false)
  }

  const doWithdraw = () => {
    nuiPost('bank:savings:withdraw', {})
    setConfirm(false)
  }

  const hoursOld = p ? Math.floor((Date.now() - new Date(p.deposited_at).getTime()) / 3600000) : 0
  const earlyPenalty = p && hoursOld < 24

  return (
    <div className={s.savingsWrap}>

      {/* Indicateur marchés */}
      <div className={s.savingsMarket}>
        <i className="bi bi-activity" style={{ color: scoreColor }} />
        <span style={{ color: scoreColor }}>{scoreLabel}</span>
        <span className={s.savingsMarketSub}>Score : {score >= 0 ? '+' : ''}{(score * 100).toFixed(0)}%</span>
      </div>

      {/* Placement actif */}
      {p ? (
        <div className={s.savingsActive}>
          <div className={s.savingsActiveHeader}>
            <div>
              <div className={s.savingsActiveLabel}>Placement actif</div>
              <div className={s.savingsActiveProfile} style={{ color: PROFILES.find(x => x.id === p.profile)?.color }}>
                <i className={`bi ${PROFILES.find(x => x.id === p.profile)?.icon}`} />
                {PROFILES.find(x => x.id === p.profile)?.label}
              </div>
            </div>
            <div className={s.savingsActiveAmount}>{fmtMoney(p.amount)} $</div>
          </div>
          <div className={s.savingsActiveInfo}>
            <span>Placé depuis {hoursOld}h</span>
            {earlyPenalty && <span className={s.savingsPenalty}><i className="bi bi-exclamation-triangle" /> Pénalité 5% si retrait avant 24h</span>}
          </div>
          <div className={s.savingsRateRow}>
            <span>Taux actuel</span>
            <span style={{ color: (data.rates as any)[p.profile] >= 0 ? '#4ade80' : '#f87171' }}>
              {((data.rates as any)[p.profile] * 100).toFixed(4)}% / cycle
            </span>
          </div>
          <RateSparkline data={data.history[p.profile as keyof typeof data.history]} color={PROFILES.find(x => x.id === p.profile)?.color ?? '#a78bfa'} />
          {confirm ? (
            <div className={s.savingsConfirm}>
              <span>Confirmer le retrait {earlyPenalty ? '(pénalité 5%)' : ''} ?</span>
              <div className={s.savingsConfirmBtns}>
                <button className={s.savingsBtnSecondary} onClick={() => setConfirm(false)}>Annuler</button>
                <button className={s.savingsBtnDanger}    onClick={doWithdraw}>Retirer</button>
              </div>
            </div>
          ) : (
            <button className={s.savingsBtnDanger} style={{ marginTop: 12 }} onClick={() => setConfirm(true)}>
              <i className="bi bi-arrow-up-right" /> Retirer mon placement
            </button>
          )}
        </div>
      ) : (
        <>
          {/* Choix du profil */}
          <div className={s.infoSectionLabel}>Choisir un profil</div>
          <div className={s.savingsProfiles}>
            {PROFILES.map(pr => (
              <div key={pr.id}
                className={`${s.savingsProfile}${profile === pr.id ? ' ' + s.savingsProfileActive : ''}`}
                style={{ '--pc': pr.color } as React.CSSProperties}
                onClick={() => setProfile(pr.id)}
              >
                <i className={`bi ${pr.icon}`} style={{ color: pr.color, fontSize: 18 }} />
                <div className={s.savingsProfileName} style={{ color: profile === pr.id ? pr.color : undefined }}>{pr.label}</div>
                <div className={s.savingsProfileDesc}>{pr.desc}</div>
                <div className={s.savingsProfileRate} style={{ color: pr.color }}>
                  {(data.rates[pr.id as keyof SavingsRates] as number * 100).toFixed(4)}% / cycle
                </div>
                <RateSparkline data={data.history[pr.id as keyof typeof data.history]} color={pr.color} />
              </div>
            ))}
          </div>

          {/* Montant */}
          <div className={s.infoSectionLabel} style={{ marginTop: 16 }}>Montant à placer</div>
          <div className={s.inputRow}>
            <input className={s.infoInput} type="number" placeholder="Min. 500$" min={500} max={balance}
              value={amount} onChange={e => setAmount(e.target.value)} />
            <span className={s.infoSuffix}>$</span>
          </div>
          <div className={s.savingsPresets}>
            {[500, 1000, 5000, 10000].filter(p => p <= balance).map(p => (
              <button key={p} className={s.preset} onClick={() => setAmount(String(p))}>{fmtMoney(p)}</button>
            ))}
          </div>
          <div className={s.formActions} style={{ marginTop: 12 }}>
            <button className={`${s.actionRow} ${s.actionPrimary}`} disabled={!valid} onClick={doDeposit}>
              <i className="bi bi-safe2" /> Placer {valid ? `${fmtMoney(amt)} $` : ''}
            </button>
          </div>
        </>
      )}
    </div>
  )
}

// ── Page carte ────────────────────────────────────────────────────────────────

function PinSetup() {
  const [pin,     setPin]     = useState('')
  const [confirm, setConfirm] = useState('')
  const [step,    setStep]    = useState<'enter' | 'confirm'>('enter')
  const [error,   setError]   = useState('')

  const current = step === 'enter' ? pin : confirm
  const handleDigit = (d: string) => {
    if (step === 'enter'   && pin.length     < 4) setPin(p => p + d)
    if (step === 'confirm' && confirm.length < 4) setConfirm(p => p + d)
  }
  const handleDel = () => {
    if (step === 'enter')   setPin(p => p.slice(0, -1))
    if (step === 'confirm') setConfirm(p => p.slice(0, -1))
  }
  const handleOk = () => {
    if (step === 'enter') { if (pin.length < 4) return; setStep('confirm'); setError('') }
    else {
      if (confirm !== pin) { setError('Les codes ne correspondent pas.'); setConfirm(''); return }
      nuiPost('bank:setPin', { pin, mode: 'bank' })
    }
  }

  return (
    <div className={s.pinSetupBlock}>
      <div className={s.infoSectionLabel}><i className="bi bi-shield-lock" /> Code PIN requis</div>
      <div className={s.pinSetupHint}>{step === 'enter' ? 'Définissez votre code à 4 chiffres.' : 'Confirmez votre code PIN.'}</div>
      <div className={s.pinSetupDots}>
        {[0,1,2,3].map(i => <div key={i} className={i < current.length ? s.pinDotOn : s.pinDotOff} />)}
      </div>
      <div className={s.pinSetupKeypad}>
        {['1','2','3','4','5','6','7','8','9'].map(k => (
          <button key={k} className={s.pinSetupKey} onClick={() => handleDigit(k)}>{k}</button>
        ))}
        <button className={`${s.pinSetupKey} ${s.pinSetupDel}`} onClick={handleDel}>⌫</button>
        <button className={s.pinSetupKey} onClick={() => handleDigit('0')}>0</button>
        <button className={`${s.pinSetupKey} ${s.pinSetupOk}`} disabled={current.length < 4} onClick={handleOk}>OK</button>
      </div>
      {error && <div className={s.pinSetupError}>{error}</div>}
    </div>
  )
}

function CardPage({ card, tiers, balance }: { card: CardInfo | null | undefined; tiers: CardTier[] | undefined; balance: number }) {
  const today      = new Date().toISOString().slice(0, 10)
  const isExpired  = card?.expires ? card.expires < today : false
  const daysLeft   = card?.expires ? Math.max(0, Math.round((new Date(card.expires).getTime() - Date.now()) / 86400000)) : 0
  const dailyPct   = card ? Math.min(100, (n(card.dailyUsed) / Math.max(1, n(card.dailyLimit))) * 100) : 0

  return (
    <div className={s.cardPageWrap}>

      {card && !card.hasPin && <PinSetup />}

      {card ? (
        <div className={s.cardInfoBlock}>
          {/* Infos principales */}
          <div className={s.infoSectionLabel}>
            <span style={{ color: card.color }}>{card.label}</span>
            <span className={isExpired ? s.badgeRed : daysLeft <= 5 ? s.badgeYellow : s.badgeGreen}>
              {isExpired ? 'Expirée' : `${daysLeft}j`}
            </span>
          </div>

          <div className={s.infoList}>
            {card.number && (
              <div className={s.infoRow}>
                <div className={s.infoRowLeft}><i className="bi bi-credit-card" />Numéro</div>
                <span className={s.infoReadonly} style={{ fontFamily: 'monospace', letterSpacing: '0.12em' }}>{card.number}</span>
              </div>
            )}
            <div className={s.infoRow}>
              <div className={s.infoRowLeft}><i className="bi bi-calendar" />Expire le</div>
              <span className={s.infoReadonly}>{card.expires ? card.expires.split('-').reverse().join('/') : ''}</span>
            </div>
            <div className={s.infoRow}>
              <div className={s.infoRowLeft}><i className="bi bi-arrow-up-right" />Plafond retrait</div>
              <span className={s.infoReadonly}>{fmtMoney(card.maxWithdraw)} $</span>
            </div>
            <div className={s.infoRow}>
              <div className={s.infoRowLeft}><i className="bi bi-calendar-day" />Plafond journalier</div>
              <span className={s.infoReadonly}>{fmtMoney(card.dailyLimit)} $</span>
            </div>
            <div className={s.infoRow}>
              <div className={s.infoRowLeft}><i className="bi bi-graph-up" />Utilisé aujourd'hui</div>
              <span className={s.infoReadonly}>{fmtMoney(card.dailyUsed)} / {fmtMoney(card.dailyLimit)} $</span>
            </div>
          </div>

          {/* Barre utilisation */}
          <div className={s.dailyBarWrap}>
            <div className={s.dailyBar} style={{ width: `${dailyPct}%`, background: dailyPct > 80 ? '#f87171' : '#a78bfa' }} />
          </div>

          {/* CVV + PIN */}
          <div className={s.infoList}>
            <RevealField label="CVV" value={card.cvv} mask="•••" />
            <RevealField label="Code PIN" value={card.pin} mask="••••" />
          </div>

          {/* Renouveler */}
          <div className={s.formActions}>
            <button className={`${s.actionRow} ${s.actionPrimary}`} onClick={() => nuiPost('bank:renewCard', {})}>
              <i className="bi bi-arrow-repeat" /> Renouveler · {tiers?.find(t => t.id === card.tier)?.monthly ?? '?'} $ / mois
            </button>
          </div>
        </div>
      ) : (
        <div className={s.cardEmpty}>
          <i className="bi bi-credit-card" />
          Aucune carte bancaire active
        </div>
      )}

      {/* Offres */}
      <div className={s.infoSectionLabel}>{card ? 'Changer de carte' : 'Choisir une carte'}</div>
      <div className={s.tierList}>
        {(tiers ?? []).map(tier => {
          const isCurrent = card?.tier === tier.id
          const canAfford = balance >= (isCurrent ? tier.monthly : tier.price)
          return (
            <div key={tier.id} className={`${s.tierRow}${isCurrent ? ' ' + s.tierRowActive : ''}`}>
              <div className={s.tierDot} style={{ background: tier.color }} />
              <div className={s.tierInfo}>
                <div className={s.tierLabel} style={{ color: isCurrent ? tier.color : undefined }}>{tier.label}</div>
                <div className={s.tierDesc}>{tier.description}</div>
                <div className={s.tierLimits}>Retrait max {fmtMoney(tier.maxWithdraw)} $ · {fmtMoney(tier.dailyLimit)} $/j</div>
              </div>
              <div className={s.tierAction}>
                {isCurrent ? (
                  <span className={s.tierCurrent} style={{ color: tier.color }}>Active</span>
                ) : (
                  <>
                    <div className={s.tierPrice}>{fmtMoney(tier.price)} $</div>
                    <button
                      className={s.tierBtn}
                      disabled={!canAfford}
                      onClick={() => nuiPost(card ? 'bank:upgradeCard' : 'bank:buyCard', { tierId: tier.id })}
                    >
                      {card ? 'Upgrade' : 'Souscrire'}
                    </button>
                  </>
                )}
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}

// ── Flip card (panneau droit) ─────────────────────────────────────────────────

function FlipCard({ card, character }: { card: CardInfo; character: Character }) {
  const [flipped, setFlipped] = useState(false)
  const [cvvVisible, setCvvVisible] = useState(false)
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null)

  const revealCvv = (e: React.MouseEvent) => {
    e.stopPropagation()
    if (!card.cvv) return
    setCvvVisible(true)
    if (timer.current) clearTimeout(timer.current)
    timer.current = setTimeout(() => setCvvVisible(false), 5000)
  }
  useEffect(() => () => { if (timer.current) clearTimeout(timer.current) }, [])

  const num = card.number ?? '•••• •••• •••• ••••'
  const exp = card.expires
    ? (() => {
        const raw = card.expires
        if (typeof raw === 'number') {
          const dt = new Date(raw)
          return isNaN(dt.getTime()) ? '' : String(dt.getMonth()+1).padStart(2,'0') + '/' + String(dt.getFullYear()).slice(2)
        }
        return raw.split('-').reverse().slice(0, 2).join('/')
      })()
    : ''

  return (
    <div className={s.flipWrap} onClick={() => setFlipped(f => !f)}>
      <div className={`${s.flipInner}${flipped ? ' ' + s.flipped : ''}`}>

        {/* Recto */}
        <div className={s.flipFront}>
          <div className={s.fcTop}>
            <div className={s.fcChip} />
            <div className={s.fcBrand}>
              <span className={s.fcBrandName}>EPSILON</span>
              <span className={s.fcBrandSub}>BANK</span>
            </div>
          </div>
          <div className={s.fcNumber}>{num}</div>
          <div className={s.fcBottom}>
            <div className={s.fcMeta}>
              <span className={s.fcMetaLabel}>EXPIRE</span>
              <span className={s.fcMetaVal}>{exp}</span>
            </div>
            <div className={s.fcMeta} style={{ textAlign: 'right' }}>
              <span className={s.fcMetaLabel}>TITULAIRE</span>
              <span className={s.fcMetaVal}>{character.firstname} {character.lastname}</span>
            </div>
          </div>
          <div className={s.fcTier}>{card.label}</div>
          <div className={s.fcHint}>Cliquer pour retourner</div>
        </div>

        {/* Verso */}
        <div className={s.flipBack}>
          <div className={s.fcStripe} />
          <div className={s.fcCvvRow}>
            <span className={s.fcCvvLabel}>CVV</span>
            <span className={s.fcCvvVal} onClick={revealCvv}>
              {cvvVisible ? (card.cvv ?? '') : '•••'}
            </span>
          </div>
          <div className={s.fcCvvHint}>{cvvVisible ? 'Masqué dans 5s' : 'Cliquer pour révéler'}</div>
        </div>

      </div>
    </div>
  )
}

// ── Amount modal ──────────────────────────────────────────────────────────────

function AmountModal({ title, max, suffix = '$ disponibles', onConfirm, onCancel }: {
  title: string; max: number; suffix?: string; onConfirm: (v: number) => void; onCancel: () => void
}) {
  const [val, setVal] = useState('')
  const inputRef = useRef<HTMLInputElement>(null)
  useEffect(() => { inputRef.current?.focus() }, [])

  const amount = Math.min(Math.max(0, parseFloat(val) || 0), max)
  const valid  = amount > 0 && amount <= max

  return (
    <div className={s.modalBackdrop}>
      <div className={s.modal}>
        <div className={s.modalTitle}>{title}</div>
        <div className={s.modalMax}>{fmtMoney(max)} {suffix}</div>
        <div className={s.modalInputRow}>
          <input ref={inputRef} className={s.modalInput} type="number" min={1} max={max}
            value={val} onChange={e => setVal(e.target.value)}
            onKeyDown={e => { if (e.key === 'Enter' && valid) onConfirm(amount); if (e.key === 'Escape') onCancel() }}
            placeholder="Montant..." />
          <span className={s.modalCurrency}>$</span>
        </div>
        <div className={s.modalPresets}>
          {[500, 1000, 5000, 10000].filter(p => p <= max).map(p => (
            <button key={p} className={s.preset} onClick={() => setVal(String(p))}>{fmtMoney(p)}</button>
          ))}
          <button className={s.preset} onClick={() => setVal(String(max))}>MAX</button>
        </div>
        <div className={s.modalActions}>
          <button className={s.modalCancel} onClick={onCancel}>Annuler</button>
          <button className={s.modalConfirm} disabled={!valid} onClick={() => onConfirm(amount)}>
            Confirmer · {fmtMoney(amount)} $
          </button>
        </div>
      </div>
    </div>
  )
}

// ── Composant principal ───────────────────────────────────────────────────────

function BankToast({ msg, type }: { msg: string; type: string }) {
  const isSuccess = type === 'success'
  const isError   = type === 'error'
  const accent    = isSuccess ? '#4ade80' : isError ? '#f87171' : '#a78bfa'
  const bg        = isSuccess ? 'rgba(74,222,128,0.10)' : isError ? 'rgba(248,113,113,0.10)' : 'rgba(167,139,250,0.10)'
  const icon      = isSuccess ? 'bi-check-circle-fill' : isError ? 'bi-x-circle-fill' : 'bi-info-circle-fill'
  const label     = isSuccess ? 'Succès' : isError ? 'Erreur' : 'Info'
  return (
    <div className={s.bankToast} style={{ '--ta': accent, '--tb': bg } as React.CSSProperties}>
      <div className={s.bankToastIcon}>
        <i className={`bi ${icon}`} />
      </div>
      <div className={s.bankToastBody}>
        <span className={s.bankToastLabel}>{label}</span>
        <span className={s.bankToastMsg}>{msg}</span>
      </div>
      <div className={s.bankToastProgress} />
    </div>
  )
}

export default function Bank({ data, onClose }: { data: BankData; onClose: () => void }) {
  const [page,      setPage]      = useState<Page>('accueil')
  const [account,   setAccount]   = useState(data.account)
  const [cash,      setCash]      = useState(data.cash)
  const [txs,       setTxs]       = useState(data.transactions)
  const [weekly,    setWeekly]    = useState(data.weekly)
  const [card,      setCard]      = useState(data.card)
  const [cardTiers, setCardTiers] = useState(data.cardTiers)
  const [modal,     setModal]     = useState<'deposit' | 'withdraw' | null>(null)
  const [savings,   setSavings]   = useState<SavingsData | null>(data.savings ?? null)
  const [toast,     setToast]     = useState<{ msg: string; type: string } | null>(null)
  const toastTimer = useRef<ReturnType<typeof setTimeout> | null>(null)
  const mode = data.mode

  useEffect(() => {
    return onNUI<BankData>('epsilon:bank:dataResult', d => {
      if (!d) return
      setAccount(d.account); setCash(d.cash); setTxs(d.transactions); setWeekly(d.weekly)
      if (d.card !== undefined) setCard(d.card)
      if (d.cardTiers)          setCardTiers(d.cardTiers)
      if (d.savings !== undefined) setSavings(d.savings ?? null)
      setModal(null)
    })
  }, [])

  useEffect(() => {
    return onNUI<{ text: string; type: string }>('epsilon:bank:notify', d => {
      if (!d) return
      setToast({ msg: d.text, type: d.type })
      if (toastTimer.current) clearTimeout(toastTimer.current)
      toastTimer.current = setTimeout(() => setToast(null), 4000)
    })
  }, [])

  useEffect(() => {
    const h = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose() }
    window.addEventListener('keydown', h)
    return () => window.removeEventListener('keydown', h)
  }, [onClose])

  const doDeposit  = useCallback((amount: number) => { nuiPost('bank:deposit', amount);                          setModal(null) }, [])
  const doWithdraw = useCallback((amount: number) => { nuiPost('bank:withdraw', { amount, mode: 'bank' });       setModal(null) }, [])

  const NAV: { key: Page; label: string; icon: string; bankOnly?: boolean }[] = [
    { key: 'accueil',    label: 'Accueil',    icon: 'bi-house-fill' },
    { key: 'virement',   label: 'Virement',   icon: 'bi-send-fill',        bankOnly: true },
    { key: 'epargne',    label: 'Épargne',    icon: 'bi-safe2',            bankOnly: true },
    { key: 'historique', label: 'Historique', icon: 'bi-clock-history',    bankOnly: true },
    { key: 'carte',      label: 'Ma carte',   icon: 'bi-credit-card-fill', bankOnly: true },
  ]

  return (
    <div className={s.root}>

      {/* ── Sidebar ── */}
      <div className={s.sidebar}>
        <div className={s.logo}>
          <div className={s.logoIcon}><i className="bi bi-bank" /></div>
          <div className={s.logoText}>
            <span className={s.logoEpsilon}>BANQUE</span>
          </div>
        </div>

        <div className={s.navSection}>
          <div className={s.navLabel}>Pages</div>
          {NAV.filter(p => !p.bankOnly || mode === 'bank').map(p => (
            <button key={p.key} className={`${s.navItem}${page === p.key ? ' ' + s.navItemActive : ''}`} onClick={() => setPage(p.key)}>
              <i className={`bi ${p.icon}`} />{p.label}
            </button>
          ))}
        </div>

        <div className={s.navSection}>
          <div className={s.navLabel}>Comptes</div>
          <button className={`${s.navItem} ${s.navItemActive}`}>
            <i className="bi bi-person-fill" />
            {data.character.firstname} {data.character.lastname}
          </button>
        </div>

        <div className={s.sidebarBottom}>
          <div className={s.playerName}>{data.character.firstname} {data.character.lastname}</div>
          <div className={s.playerType}>{mode === 'atm' ? 'Distributeur automatique' : 'Compte particulier'}</div>
        </div>
      </div>

      {/* ── Centre ── */}
      <div className={s.center}>

        {page === 'accueil' && (
          <>
            <div className={s.sectionHeader}>
              <span>Analyse</span>
              <div className={s.legend}>
                <span className={s.legendDot} style={{ background: 'rgba(74,222,128,0.8)' }} />Dépôts
                <span className={s.legendDot} style={{ background: 'rgba(248,113,113,0.8)', marginLeft: 12 }} />Retraits
              </div>
            </div>
            <div className={s.chartWrap}><WeekChart data={weekly} /></div>
            <div className={s.sectionHeader} style={{ marginTop: 16 }}>Transactions récentes</div>
            <TxTable txs={txs} limit={20} />
          </>
        )}

        {page === 'virement' && mode === 'bank' && <TransferPage balance={n(account.balance)} />}

        {page === 'epargne' && mode === 'bank' && savings && (
          <>
            <div className={s.sectionHeader}>Épargne</div>
            <div className={s.scrollArea}><SavingsPage data={savings} balance={n(account.balance)} /></div>
          </>
        )}

        {page === 'carte' && mode === 'bank' && (
          <>
            <div className={s.sectionHeader}>Ma carte bancaire</div>
            <div className={s.scrollArea}>
              <CardPage card={card} tiers={cardTiers} balance={n(account.balance)} />
            </div>
          </>
        )}

        {page === 'historique' && mode === 'bank' && (
          <>
            <div className={s.sectionHeader}>Historique complet</div>
            <TxTable txs={txs} />
          </>
        )}

      </div>

      {/* ── Panneau droit ── */}
      <div className={s.right}>
        <div className={s.rightTitle}>Mon compte</div>
        <div className={s.balanceRow}>
          <span className={s.balanceLabel}>Solde</span>
          <span className={s.balanceVal}>{fmtMoney(account.balance)} $</span>
        </div>
        {n(account.savings) > 0 && (
          <div className={s.balanceRow}>
            <span className={s.balanceLabel}>Épargne</span>
            <span className={s.balanceVal} style={{ fontSize: 14, opacity: 0.7 }}>{fmtMoney(account.savings)} $</span>
          </div>
        )}

        {account.iban && (
          <div style={{ marginTop: 6, padding: '6px 0', borderTop: '1px solid rgba(255,255,255,0.06)' }}>
            <div style={{ fontSize: 9, opacity: 0.4, textTransform: 'uppercase', letterSpacing: '0.08em', marginBottom: 3 }}>IBAN</div>
            <div style={{ fontFamily: 'monospace', fontSize: 11, letterSpacing: '0.05em', opacity: 0.7, whiteSpace: 'nowrap' }}>
              {fmtIban(account.iban)}
            </div>
          </div>
        )}

        {/* Flip card */}
        {card && <FlipCard card={card} character={data.character} />}

        <div className={s.actions}>
          <button className={s.actionBtn} onClick={() => setModal('withdraw')}>
            <i className="bi bi-arrow-up-right" /> Retrait
          </button>
          {mode === 'bank' && (
            <button className={s.actionBtnGreen} onClick={() => setModal('deposit')}>
              <i className="bi bi-arrow-down-left" /> Dépôt
            </button>
          )}
        </div>

        <button className={s.closeBtn} onClick={onClose}><i className="bi bi-x" /> Fermer</button>
      </div>

      {/* ── Toast inline ── */}
      {toast && <BankToast msg={toast.msg} type={toast.type} />}


      {/* ── Modals ── */}
      {modal === 'deposit' && (
        <AmountModal title="Déposer de l'argent liquide" max={n(cash)} suffix="$ disponibles en liquide"
          onConfirm={doDeposit} onCancel={() => setModal(null)} />
      )}
      {modal === 'withdraw' && (
        <AmountModal title="Retirer de l'argent" max={n(account.balance)} suffix="$ disponibles en banque"
          onConfirm={doWithdraw} onCancel={() => setModal(null)} />
      )}
    </div>
  )
}
