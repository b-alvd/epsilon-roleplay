import { useState, useEffect, useCallback, useMemo } from 'react'
import { onNUI, nuiPost } from '../../hooks/useNUI'
import s from './InterimSelect.module.css'

interface Quartier   { name: string; label: string; spotCount?: number }
interface SelectData {
  mission: string; label: string; color: string
  quartiers: Quartier[]
  stopOptions: number[]
  timePerStop: number
  payMinPerStop: number
  payMaxPerStop: number
}

const QUARTIER_ICONS: Record<string, string> = {
  rockford_hills: 'bi-gem',
  vespucci:       'bi-water',
  mirror_park:    'bi-houses',
  pillbox:        'bi-building',
  lsia:           'bi-airplane',
}

export function InterimSelect() {
  const [data,     setData]     = useState<SelectData | null>(null)
  const [quartier, setQuartier] = useState<string | null>(null)
  const [stops,    setStops]    = useState<number | null>(null)

  const stopOptions = useMemo<number[]>(() => {
    if (!data) return []
    const q = data.quartiers.find(q => q.name === quartier)
    const max = q?.spotCount ?? 0
    if (max === 0) return data.stopOptions
    const opts: number[] = []
    for (let i = 5; i < max; i += 5) opts.push(i)
    opts.push(max)
    return opts
  }, [quartier, data])

  useEffect(() => {
    return onNUI<SelectData>('epsilon:interim:openSelect', d => {
      setData(d)
      setQuartier(d.quartiers[0]?.name ?? null)
      setStops(null)
    })
  }, [])

  useEffect(() => {
    setStops(stopOptions[0] ?? null)
  }, [quartier])

  const close = useCallback(() => {
    nuiPost('interim:close', {})
    setData(null)
  }, [])

  const handleStart = useCallback(() => {
    if (!data) return
    if (data.quartiers.length > 0 && !quartier) return
    nuiPost('interim:start', { mission: data.mission, quartier, stops })
    setData(null)
  }, [data, quartier, stops])

  useEffect(() => {
    if (!data) return
    const h = (e: KeyboardEvent) => { if (e.key === 'Escape') close() }
    window.addEventListener('keydown', h)
    return () => window.removeEventListener('keydown', h)
  }, [data, close])

  if (!data) return null

  const hasQ     = data.quartiers.length > 0
  const hasS     = stopOptions.length > 0
  const canStart = (!hasQ || !!quartier) && (!hasS || !!stops)

  return (
    <div className={s.panel} style={{ ['--mc' as string]: data.color }}>
      <div className={s.banner}></div>
      <div className={s.body}>

        {hasQ && <>
          <div className={s.slabel}>Quartier</div>
          <div className={s.quartierGrid}>
            {data.quartiers.map(q => (
              <button
                key={q.name}
                className={`${s.qBtn} ${quartier === q.name ? s.on : ''}`}
                onClick={() => setQuartier(q.name)}
              >
                <i className={`bi ${QUARTIER_ICONS[q.name] ?? 'bi-geo-alt'}`} />
                {q.label}
              </button>
            ))}
          </div>
        </>}

        {hasQ && hasS && <div className={s.divider} />}

        {hasS && <>
          <div className={s.slabel}>Nombre d'arrêts</div>
          <div className={s.stopGrid}>
            {stopOptions.map(count => {
              const mins   = Math.ceil(count * data.timePerStop)
              const revMin = count * data.payMinPerStop
              const revMax = count * data.payMaxPerStop
              return (
                <button
                  key={count}
                  className={`${s.sBtn} ${stops === count ? s.on : ''}`}
                  onClick={() => setStops(count)}
                >
                  <span className={s.sCount}>{count}</span>
                  <span className={s.sTime}>~{mins} min</span>
                  <span className={s.sPay}>{revMin}$–{revMax}$</span>
                </button>
              )
            })}
          </div>
        </>}

      </div>
      <div className={s.footer}>
        <button className={s.cancelBtn} onClick={close}>Annuler</button>
        <button className={s.startBtn} onClick={handleStart} disabled={!canStart}>
          Commencer
        </button>
      </div>
    </div>
  )
}
