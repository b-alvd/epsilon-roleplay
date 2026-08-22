import { useState, useEffect } from 'react'
import { onNUI } from '../../hooks/useNUI'
import s from './InterimHUD.module.css'

export interface InterimHUDData {
  visible: boolean
  mission: string
  step:    number
  total:   number
  label:   string
  earned:  number
  color:   string
}

export function InterimHUD() {
  const [data, setData] = useState<InterimHUDData | null>(null)

  useEffect(() => {
    return onNUI<InterimHUDData>('epsilon:interim:hud', d => {
      setData(d.visible ? d : null)
    })
  }, [])

  if (!data) return null

  const pct = data.total > 0 ? (data.step / data.total) * 100 : 0

  return (
    <div className={s.hud} style={{ ['--ic' as string]: data.color }}>
      <div className={s.title}>
        <span className={s.dot} />
        {data.mission.toUpperCase()}
      </div>

      <div className={s.progress}>
        <div className={s.progressHeader}>
          <span className={s.progressLabel}>Progression</span>
          <span>
            <span className={s.progressNum}>{data.step}</span>
            <span className={s.progressTotal}> / {data.total}</span>
          </span>
        </div>
        <div className={s.track}>
          <div className={s.fill} style={{ width: `${pct}%` }} />
        </div>
      </div>

      <div className={s.info}>
        <div className={s.task}>{data.label}</div>
        <div className={s.earnedRow}>
          <span style={{ fontSize: '0.55vw', color: 'rgba(255,255,255,0.22)' }}>Gagné</span>
          <span className={s.earned}>{data.earned}$</span>
        </div>
        <div className={s.keyRow}>
          <span className={s.key}>F6</span>
          Abandonner la mission
        </div>
      </div>
    </div>
  )
}
