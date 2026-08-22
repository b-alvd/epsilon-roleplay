import { useState, useEffect, useCallback } from 'react'
import { nuiPost, onNUI } from '../../hooks/useNUI'
import type { BankData } from '../Bank'
import s from './ATM.module.css'

export interface ATMData extends BankData {
  itemId?:    number
  needSetup?: boolean
}

type Phase = 'pin-setup' | 'pin-confirm' | 'pin-entry' | 'withdraw'

const n   = (v: unknown) => { const x = Number(v); return isFinite(x) ? x : 0 }
const fmt = (v: unknown) => n(v).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })

const notify = (msg: string) => {
  window.dispatchEvent(new MessageEvent('message', {
    data: { action: 'epsilon:notify', data: { msg, type: 'error' } }
  }))
}

// ── Clavier numérique ─────────────────────────────────────────────────────────

function Keypad({ value, onChange, onConfirm, maxLen = 4 }: {
  value: string; onChange: (v: string) => void; onConfirm: () => void; maxLen?: number
}) {
  const press = useCallback((d: string) => { if (value.length < maxLen) onChange(value + d) }, [value, maxLen, onChange])
  const del   = useCallback(() => onChange(value.slice(0, -1)), [value, onChange])

  useEffect(() => {
    const h = (e: KeyboardEvent) => {
      if (e.key >= '0' && e.key <= '9') press(e.key)
      else if (e.key === 'Backspace') del()
      else if (e.key === 'Enter' && value.length === maxLen) onConfirm()
    }
    window.addEventListener('keydown', h)
    return () => window.removeEventListener('keydown', h)
  }, [press, del, onConfirm, value.length, maxLen])

  return (
    <div className={s.keypad}>
      {['1','2','3','4','5','6','7','8','9'].map(k => (
        <button key={k} className={s.key} onClick={() => press(k)}>{k}</button>
      ))}
      <button className={`${s.key} ${s.keyDel}`} onClick={del}>⌫</button>
      <button className={`${s.key} ${s.keyZero}`} onClick={() => press('0')}>0</button>
      <button className={`${s.key} ${s.keyOk}`} disabled={value.length !== maxLen} onClick={onConfirm}>OK</button>
    </div>
  )
}

// ── Écran PIN ─────────────────────────────────────────────────────────────────

function PinScreen({ initPhase, itemId, onSuccess }: {
  initPhase: 'pin-setup' | 'pin-entry'; itemId: number; onSuccess: (d: BankData) => void
}) {
  const [pin,   setPin]   = useState('')
  const [saved, setSaved] = useState('')
  const [phase, setPhase] = useState<Phase>(initPhase)
  const [error, setError] = useState('')

  useEffect(() => {
    const u1 = onNUI<{ ok: boolean; msg?: string }>('epsilon:bank:pinResult', d => { setError(d.msg ?? 'Erreur'); setPin('') })
    const u2 = onNUI<BankData>('epsilon:bank:dataResult', d => { if (d?.mode === 'atm') onSuccess(d) })
    return () => { u1(); u2() }
  }, [onSuccess])

  const confirm = useCallback(() => {
    setError('')
    if (phase === 'pin-setup') {
      setSaved(pin); setPin(''); setPhase('pin-confirm')
    } else if (phase === 'pin-confirm') {
      if (pin !== saved) { setError('Codes différents, recommencez.'); setPin(''); setPhase('pin-setup'); setSaved('') }
      else { nuiPost('bank:setPin', { pin, mode: 'atm' }); setPin('') }
    } else {
      nuiPost('bank:verifyPin', { itemId, pin }); setPin('')
    }
  }, [phase, pin, saved, itemId])

  const titles: Record<string, string> = {
    'pin-setup':   'Définir votre PIN',
    'pin-confirm': 'Confirmer le PIN',
    'pin-entry':   'Code PIN',
  }
  const hints: Record<string, string> = {
    'pin-setup':   'Choisissez un code à 4 chiffres.',
    'pin-confirm': 'Saisissez à nouveau votre code.',
    'pin-entry':   'Entrez votre code à 4 chiffres.',
  }

  return (
    <div className={s.pinWrap}>
      <div className={s.pinTitle}>{titles[phase]}</div>
      <div className={s.pinHint}>{hints[phase]}</div>
      <div className={s.pinDots}>
        {[0,1,2,3].map(i => <div key={i} className={i < pin.length ? s.dotOn : s.dotOff} />)}
      </div>
      <Keypad value={pin} onChange={setPin} onConfirm={confirm} />
      {error && <div className={s.pinError}>{error}</div>}
    </div>
  )
}

// ── Écran retrait ─────────────────────────────────────────────────────────────

function WithdrawScreen({ data }: { data: BankData }) {
  const [balance, setBalance] = useState(n(data.account.balance))
  const [card,    setCard]    = useState(data.card)
  const [amount,  setAmount]  = useState('')

  useEffect(() => {
    return onNUI<BankData>('epsilon:bank:dataResult', d => {
      if (d?.mode !== 'atm') return
      setBalance(n(d.account.balance))
      if (d.card) setCard(d.card)
    })
  }, [])

  const maxW   = card ? n(card.maxWithdraw) : 0
  const limit  = card ? n(card.dailyLimit)  : 0
  const used   = card ? n(card.dailyUsed)   : 0
  const remain = Math.max(0, limit - used)
  const cap    = Math.min(balance, maxW, remain)
  const amt = Math.max(0, parseInt(amount) || 0)

  const doWithdraw = () => {
    if (amt <= 0) return
    if (amt > balance) { notify('Solde insuffisant.'); return }
    if (amt > maxW)    { notify(`Plafond de retrait dépassé (max ${fmt(maxW)} $).`); return }
    if (amt > remain)  { notify(`Limite journalière dépassée (restant ${fmt(remain)} $).`); return }
    nuiPost('bank:withdraw', { amount: amt, mode: 'atm' })
    setAmount('')
  }

  const PRESETS = [20, 50, 100, 200, 500, 1000].filter(p => p <= cap)

  return (
    <div className={s.withdrawWrap}>

      {/* Infos compte */}
      <div className={s.infoBlock}>
        <div className={s.infoRow}>
          <span className={s.infoLabel}>Solde disponible</span>
          <span className={s.infoVal}>{fmt(balance)} $</span>
        </div>
        <div className={s.infoRow}>
          <span className={s.infoLabel}>Plafond par retrait</span>
          <span className={s.infoVal}>{fmt(maxW)} $</span>
        </div>
        <div className={s.infoRow}>
          <span className={s.infoLabel}>Limite journalière restante</span>
          <span className={`${s.infoVal}${remain < 50 ? ' ' + s.valWarn : ''}`}>{fmt(remain)} $</span>
        </div>
      </div>

      {/* Presets */}
      {PRESETS.length > 0 && <>
        <div className={s.subHeader}>Montant rapide</div>
        <div className={s.presets}>
          {PRESETS.map(p => (
            <button key={p}
              className={`${s.preset}${amt === p ? ' ' + s.presetOn : ''}`}
              onClick={() => setAmount(String(p))}
            >{p} $</button>
          ))}
        </div>
      </>}

      {/* Input libre */}
      <div className={s.inputRow}>
        <input className={s.input} type="number" placeholder="Autre montant…"
          min={1} max={cap} value={amount}
          onChange={e => setAmount(e.target.value)}
          onKeyDown={e => e.key === 'Enter' && doWithdraw()} />
        <span className={s.inputSfx}>$</span>
      </div>

      <button className={s.withdrawBtn} disabled={amt <= 0} onClick={doWithdraw}>
        <i className="bi bi-arrow-up-right" /> Retirer {amt > 0 ? fmt(amt) + ' $' : ''}
      </button>
    </div>
  )
}

// ── Composant principal ───────────────────────────────────────────────────────

export default function ATM({ data, onClose }: { data: ATMData; onClose: () => void }) {
  const initPhase: Phase = data.itemId !== undefined
    ? (data.needSetup ? 'pin-setup' : 'pin-entry')
    : 'withdraw'

  const [bankData, setBankData] = useState<BankData | null>(initPhase === 'withdraw' ? data : null)
  const [phase,    setPhase]    = useState<Phase>(initPhase)

  const onPinSuccess = useCallback((d: BankData) => { setBankData(d); setPhase('withdraw') }, [])

  useEffect(() => {
    const h = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose() }
    window.addEventListener('keydown', h)
    return () => window.removeEventListener('keydown', h)
  }, [onClose])

  return (
    <div className={s.root}>
      <div className={s.panel}>

        <div className={s.header}>
          <div className={s.hIcon}><i className="bi bi-credit-card-2-front" /></div>
          <div className={s.hInfo}>
            <div className={s.hTitle}>Epsilon Bank</div>
            <div className={s.hSub}>Distributeur automatique</div>
          </div>
          <button className={s.hClose} onClick={onClose}><i className="bi bi-x-lg" /></button>
        </div>

        {(phase === 'pin-setup' || phase === 'pin-entry') && data.itemId !== undefined && (
          <PinScreen initPhase={phase} itemId={data.itemId} onSuccess={onPinSuccess} />
        )}
        {phase === 'withdraw' && bankData && (
          <WithdrawScreen data={bankData} />
        )}

      </div>
    </div>
  )
}
