import { useState } from 'react'
import { nuiPost } from '../../hooks/useNUI'
import s from './Support.module.css'

type Section = 'discord' | 'report' | 'signalement' | null

type ReportCat = 'bug' | 'suggestion' | 'question' | 'autre'
const REPORT_CATS: { id: ReportCat; label: string; icon: string }[] = [
  { id: 'bug',        label: 'Bug / Erreur',  icon: 'bi-bug-fill'             },
  { id: 'suggestion', label: 'Suggestion',     icon: 'bi-lightbulb-fill'       },
  { id: 'question',   label: 'Question',       icon: 'bi-question-circle-fill' },
  { id: 'autre',      label: 'Autre',          icon: 'bi-three-dots'           },
]

type SignalCat = 'triche' | 'comportement' | 'harcelement' | 'autre'
const SIGNAL_CATS: { id: SignalCat; label: string; icon: string }[] = [
  { id: 'triche',       label: 'Triche / Exploit',     icon: 'bi-shield-x-fill'          },
  { id: 'comportement', label: 'Comportement toxique',  icon: 'bi-emoji-angry-fill'       },
  { id: 'harcelement',  label: 'Harcèlement',          icon: 'bi-exclamation-octagon-fill'},
  { id: 'autre',        label: 'Autre',                icon: 'bi-three-dots'              },
]

/* ── Discord ─────────────────────────────────────────────────── */
function DiscordSection({ discord }: { discord?: string }) {
  const [copied, setCopied] = useState(false)
  const handleOpen = () => nuiPost('pausemenu:openUrl', { url: discord ?? '' })
  const handleCopy = () => {
    nuiPost('pausemenu:copyToClipboard', { text: discord ?? '' })
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }
  return (
    <div className={s.rowBody}>
      <p className={s.desc}>Rejoins notre communauté Discord pour de l'aide et les annonces du serveur.</p>
      {discord && (
        <div className={s.discordUrl}>
          <i className="bi bi-discord" /> {discord}
        </div>
      )}
      <div className={s.btnRow}>
        <button className={`${s.btn} ${s.btnPrimary}`} onClick={handleOpen}>
          <i className="bi bi-box-arrow-up-right" /> Ouvrir Discord
        </button>
        <button className={`${s.btn} ${s.btnGhost}${copied ? ' ' + s.btnCopied : ''}`} onClick={handleCopy}>
          {copied
            ? <><i className="bi bi-check-lg" /> Copié</>
            : <><i className="bi bi-clipboard" /> Copier le lien</>}
        </button>
      </div>
    </div>
  )
}

/* ── Report ──────────────────────────────────────────────────── */
function ReportSection() {
  const [cat,     setCat]     = useState<ReportCat | null>(null)
  const [message, setMessage] = useState('')
  const [sent,    setSent]    = useState(false)
  const [sending, setSending] = useState(false)
  const canSend = cat && message.trim().length >= 10

  const handleSend = () => {
    if (!canSend || sending) return
    setSending(true)
    nuiPost('pausemenu:sendReport', { type: 'report', category: cat, message })
    setTimeout(() => { setSent(true); setSending(false) }, 700)
  }

  if (sent) return (
    <div className={s.rowBody}>
      <div className={s.sent}>
        <i className="bi bi-check-circle-fill" style={{ color: '#22c55e', fontSize: 32 }} />
        <span className={s.sentTitle}>Report envoyé</span>
        <span className={s.sentSub}>L'équipe a bien reçu ton message.</span>
        <button className={`${s.btn} ${s.btnGhost}`} onClick={() => { setSent(false); setCat(null); setMessage('') }}>
          Nouveau report
        </button>
      </div>
    </div>
  )

  return (
    <div className={s.rowBody}>
      <p className={s.desc}>Signale un bug, fais une suggestion ou pose une question à l'équipe.</p>

      <div>
        <div className={s.fieldLabel}>Catégorie</div>
        <div className={s.catGrid}>
          {REPORT_CATS.map(c => (
            <button key={c.id} className={`${s.catBtn}${cat === c.id ? ' ' + s.catActive : ''}`} onClick={() => setCat(c.id)}>
              <i className={`bi ${c.icon}`} /> {c.label}
            </button>
          ))}
        </div>
      </div>

      <div>
        <div className={s.fieldLabel}>
          Message <span className={s.optional}>(min. 10 caractères)</span>
        </div>
        <textarea className={s.textarea} rows={4} maxLength={500}
          placeholder="Décris ton problème ou ta suggestion..."
          value={message} onChange={e => setMessage(e.target.value)} />
        <div className={s.charCount}>{message.length} / 500</div>
      </div>

      <div className={s.btnRow}>
        <button className={`${s.btn} ${s.btnDanger}${!canSend ? ' ' + s.btnDisabled : ''}`}
          onClick={handleSend} disabled={!canSend || sending}>
          {sending ? <><i className="bi bi-hourglass-split" /> Envoi...</> : <><i className="bi bi-send-fill" /> Envoyer</>}
        </button>
      </div>
    </div>
  )
}

/* ── Signalement ─────────────────────────────────────────────── */
function SignalementSection() {
  const [cat,     setCat]     = useState<SignalCat | null>(null)
  const [target,  setTarget]  = useState('')
  const [message, setMessage] = useState('')
  const [sent,    setSent]    = useState(false)
  const [sending, setSending] = useState(false)
  const canSend = cat && target.trim().length > 0 && message.trim().length >= 10

  const handleSend = () => {
    if (!canSend || sending) return
    setSending(true)
    nuiPost('pausemenu:sendReport', { type: 'signalement', category: cat, target, message })
    setTimeout(() => { setSent(true); setSending(false) }, 700)
  }

  if (sent) return (
    <div className={s.rowBody}>
      <div className={s.sent}>
        <i className="bi bi-check-circle-fill" style={{ color: '#22c55e', fontSize: 32 }} />
        <span className={s.sentTitle}>Signalement envoyé</span>
        <span className={s.sentSub}>La modération a été notifiée.</span>
        <button className={`${s.btn} ${s.btnGhost}`} onClick={() => { setSent(false); setCat(null); setTarget(''); setMessage('') }}>
          Nouveau signalement
        </button>
      </div>
    </div>
  )

  return (
    <div className={s.rowBody}>
      <p className={s.desc}>Signale un joueur à la modération. Les abus entraînent des sanctions.</p>

      <div>
        <div className={s.fieldLabel}>Joueur concerné</div>
        <input className={s.input} maxLength={64}
          placeholder="Nom ou ID serveur (ex: John Doe / 42)..."
          value={target} onChange={e => setTarget(e.target.value)} />
      </div>

      <div>
        <div className={s.fieldLabel}>Motif</div>
        <div className={s.catGrid}>
          {SIGNAL_CATS.map(c => (
            <button key={c.id} className={`${s.catBtn}${cat === c.id ? ' ' + s.catActive : ''}`} onClick={() => setCat(c.id)}>
              <i className={`bi ${c.icon}`} /> {c.label}
            </button>
          ))}
        </div>
      </div>

      <div>
        <div className={s.fieldLabel}>
          Description <span className={s.optional}>(min. 10 caractères)</span>
        </div>
        <textarea className={s.textarea} rows={3} maxLength={500}
          placeholder="Décris ce qui s'est passé..."
          value={message} onChange={e => setMessage(e.target.value)} />
        <div className={s.charCount}>{message.length} / 500</div>
      </div>

      <div className={s.btnRow}>
        <button className={`${s.btn} ${s.btnDanger}${!canSend ? ' ' + s.btnDisabled : ''}`}
          onClick={handleSend} disabled={!canSend || sending}>
          {sending ? <><i className="bi bi-hourglass-split" /> Envoi...</> : <><i className="bi bi-flag-fill" /> Signaler</>}
        </button>
      </div>
    </div>
  )
}

/* ── Panel ───────────────────────────────────────────────────── */
interface Props { discord?: string; onBack: () => void }

const ROWS: { id: Exclude<Section, null>; label: string; icon: string; sub: string }[] = [
  { id: 'discord',     label: 'Discord',     icon: 'bi-discord',        sub: 'Rejoindre la communauté'   },
  { id: 'report',      label: 'Report',      icon: 'bi-megaphone-fill', sub: 'Bug, suggestion, question' },
  { id: 'signalement', label: 'Signalement', icon: 'bi-flag-fill',      sub: 'Signaler un joueur'        },
]

export default function SupportPanel({ discord, onBack }: Props) {
  const [open, setOpen] = useState<Section>(null)
  const toggle = (id: Exclude<Section, null>) => setOpen(p => p === id ? null : id)

  return (
    <div className={s.panel}>
      <div className={s.header}>
        <button className={s.backBtn} onClick={onBack}><i className="bi bi-arrow-left" /></button>
        <span className={s.headerTitle}>Support</span>
        <span className={s.headerSub}>Aide &amp; contact</span>
      </div>

      <div className={s.body}>
        {ROWS.map(row => (
          <div key={row.id} className={`${s.row}${open === row.id ? ' ' + s.rowOpen : ''}`}>
            <button className={s.rowHeader} onClick={() => toggle(row.id)}>
              <div className={s.rowIcon}>
                <i className={`bi ${row.icon}`} />
              </div>
              <div className={s.rowInfo}>
                <div className={s.rowLabel}>{row.label}</div>
                <div className={s.rowSub}>{row.sub}</div>
              </div>
              <i className={`bi bi-chevron-${open === row.id ? 'up' : 'down'} ${s.chevron}`} />
            </button>

            {open === row.id && (
              <>
                {row.id === 'discord'     && <DiscordSection discord={discord} />}
                {row.id === 'report'      && <ReportSection />}
                {row.id === 'signalement' && <SignalementSection />}
              </>
            )}
          </div>
        ))}
      </div>
    </div>
  )
}
