import { useState } from 'react'
import { nuiPost } from '../../hooks/useNUI'
import s from './Document.module.css'

export interface DocumentSigner {
  character_id: number
  role: string
  signed_at: string | null
}

export interface DocumentData {
  id: number
  template: string
  title: string
  data: Record<string, unknown>
  created_by: number
  created_at: string
  expires_at?: string
  signers: number[]
  myCharId: number
  hasPen: boolean
  myRole?: string
}

const TEMPLATE_LABELS: Record<string, string> = {
  contract: 'Contrat de travail',
  amendment: 'Avenant au contrat',
  generic: 'Document',
}

const CONTRACT_TYPE_LABELS: Record<string, string> = {
  CDI: 'CDI — Contrat à Durée Indéterminée',
  CDD: 'CDD — Contrat à Durée Déterminée',
  stage: 'Convention de stage',
  interim: 'Mission intérimaire',
}

function Row({ label, value }: { label: string; value: React.ReactNode | string | number }) {
  return (
    <div className={s.row}>
      <span className={s.rowLabel}>{label}</span>
      <span className={s.rowVal}>{value}</span>
    </div>
  )
}

function ContractBody({ data }: { data: Record<string, unknown> }) {
  return (
    <div className={s.body}>
      <Row label="Entreprise / Service" value={String(data.job_label ?? '—')} />
      <Row label="Type de contrat"      value={CONTRACT_TYPE_LABELS[String(data.type)] ?? String(data.type ?? '—')} />
      <Row label="Salaire brut"         value={data.salary != null ? `${Number(data.salary).toLocaleString('fr-FR')} $` : '—'} />
      <Row label="Date de début"        value={String(data.start_date ?? '—')} />
      {data.end_date != null && <Row label="Date de fin" value={String(data.end_date)} />}
    </div>
  )
}

function AmendmentBody({ data }: { data: Record<string, unknown> }) {
  return (
    <div className={s.body}>
      <Row label="Ancien salaire"    value={data.old_salary != null ? `${Number(data.old_salary).toLocaleString('fr-FR')} $` : '—'} />
      <Row label="Nouveau salaire"   value={data.new_salary != null ? `${Number(data.new_salary).toLocaleString('fr-FR')} $` : '—'} />
      {data.reason != null && <Row label="Motif" value={String(data.reason)} />}
    </div>
  )
}

function GenericBody({ data }: { data: Record<string, unknown> }) {
  return (
    <div className={s.body}>
      {Object.entries(data).map(([k, v]) => (
        <Row key={k} label={k} value={String(v ?? '—')} />
      ))}
    </div>
  )
}

export default function Document({ data, onClose }: { data: DocumentData; onClose: () => void }) {
  const [signing, setSigning] = useState(false)

  const alreadySigned = data.signers.includes(data.myCharId)
  const canSign       = !alreadySigned && data.hasPen && !!data.myRole

  async function handleSign() {
    if (!canSign || signing) return
    setSigning(true)
    await nuiPost('documents:sign', { docId: data.id, role: data.myRole })
    setSigning(false)
    onClose()
  }

  const templateLabel = TEMPLATE_LABELS[data.template] ?? 'Document'

  return (
    <div className={s.overlay}>
      <div className={s.panel}>
        {/* Header */}
        <div className={s.header}>
          <div className={s.headerLeft}>
            <i className="bi bi-file-text" />
            <div>
              <div className={s.headerType}>{templateLabel}</div>
              <div className={s.headerTitle}>{data.title}</div>
            </div>
          </div>
          <button className={s.closeBtn} onClick={onClose}>
            <i className="bi bi-x-lg" />
          </button>
        </div>

        {/* Corps selon template */}
        <div className={s.content}>
          {data.template === 'contract'  && <ContractBody  data={data.data} />}
          {data.template === 'amendment' && <AmendmentBody data={data.data} />}
          {data.template !== 'contract' && data.template !== 'amendment' && <GenericBody data={data.data} />}

          {/* Métadonnées */}
          <div className={s.meta}>
            <span>Établi le {new Date(data.created_at).toLocaleDateString('fr-FR')}</span>
            {data.expires_at && <span>· Expire le {new Date(data.expires_at).toLocaleDateString('fr-FR')}</span>}
          </div>

          {/* Signatures */}
          <div className={s.signSection}>
            <div className={s.signTitle}>SIGNATURES</div>
            {data.signers.length === 0 ? (
              <div className={s.signEmpty}>Aucune signature pour le moment.</div>
            ) : (
              <div className={s.signList}>
                {data.signers.map(id => (
                  <div key={id} className={s.signChip}>
                    <i className="bi bi-pen-fill" />
                    Personnage #{id}
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Footer */}
        <div className={s.footer}>
          {!data.hasPen && !alreadySigned && (
            <div className={s.noPen}>
              <i className="bi bi-pen" /> Vous avez besoin d'un stylo pour signer.
            </div>
          )}
          {canSign && (
            <button className={s.signBtn} onClick={handleSign} disabled={signing}>
              <i className="bi bi-pen-fill" />
              {signing ? 'Signature en cours…' : 'Signer ce document'}
            </button>
          )}
          {alreadySigned && (
            <div className={s.signed}>
              <i className="bi bi-check-circle-fill" /> Vous avez signé ce document.
            </div>
          )}
          <button className={s.closeFooterBtn} onClick={onClose}>Fermer</button>
        </div>
      </div>
    </div>
  )
}
