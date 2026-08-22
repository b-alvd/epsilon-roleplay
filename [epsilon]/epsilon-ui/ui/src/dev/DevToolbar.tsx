import { useState } from 'react'
import { DEV_PANELS } from './panels'
import { cx } from '../utils/cx'
import s from './DevToolbar.module.css'

interface Props {
  activePanel: string | null
  onOpen: (id: string, data: unknown) => void
  onClose: () => void
}

function dispatchNUI(action: string, data: unknown) {
  window.dispatchEvent(new MessageEvent('message', { data: { action, data } }))
}

export default function DevToolbar({ activePanel, onOpen, onClose }: Props) {
  const [open, setOpen]               = useState(true)
  const [activeOverlays, setActiveOverlays] = useState<Set<string>>(new Set())

  const toggleOverlay = (id: string, nuiMessage: { action: string; data: unknown }, nuiClose?: { action: string; data: unknown }) => {
    setActiveOverlays(prev => {
      const next = new Set(prev)
      if (next.has(id)) {
        next.delete(id)
        if (nuiClose) dispatchNUI(nuiClose.action, nuiClose.data)
      } else {
        next.add(id)
        dispatchNUI(nuiMessage.action, nuiMessage.data)
      }
      return next
    })
  }

  const panels   = DEV_PANELS.filter(p => !p.nuiMessage)
  const overlays = DEV_PANELS.filter(p =>  p.nuiMessage)

  return (
    <>
      <button className={cx(s.toggle, open && s.open)} onClick={() => setOpen(o => !o)}>
        {open ? '›' : '‹'}
      </button>

      <div className={cx(s.sidebar, !open && s.hidden)}>
        <div className={s.header}>
          <span className={s.label}>DEV</span>
        </div>

        <div className={s.body}>
          {panels.map(panel => (
            <button
              key={panel.id}
              className={cx(s.btn, activePanel === panel.id && s.active, !panel.mockData && s.disabled)}
              title={!panel.mockData ? 'Pas de données mock — à venir' : undefined}
              onClick={() => {
                if (!panel.mockData) return
                if (activePanel === panel.id) onClose()
                else onOpen(panel.id, panel.mockData)
              }}
            >
              <span className={s.icon}>{panel.icon}</span>
              {panel.label}
            </button>
          ))}

          {overlays.length > 0 && <div className={s.sep} />}

          {overlays.map(panel => (
            <button
              key={panel.id}
              className={cx(s.btn, activeOverlays.has(panel.id) && s.active)}
              onClick={() => toggleOverlay(panel.id, panel.nuiMessage!, panel.nuiClose)}
            >
              <span className={s.icon}>{panel.icon}</span>
              {panel.label}
            </button>
          ))}
        </div>

        {activePanel && (
          <div className={s.footer}>
            <button className={s['close-btn']} onClick={onClose}>✕ Fermer le panel</button>
          </div>
        )}
      </div>
    </>
  )
}
