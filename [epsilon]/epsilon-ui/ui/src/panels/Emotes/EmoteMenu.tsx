import { useState, useEffect, useMemo } from 'react'
import { onNUI, nuiPost } from '../../hooks/useNUI'
import s from './EmoteMenu.module.css'

interface EmoteEntry  { key: string; label: string; icon: string; canWalk?: boolean }
interface Category    { id: string; label: string; icon: string; emotes: EmoteEntry[] }
interface NumpadSlot  { key: string; label: string; icon: string }
interface EmoteMenuData {
  categories: Category[]
  numpad: (NumpadSlot | false)[]
}

const NUM_LABELS = ['N0','N1','N2','N3','N4','N5','N6','N7','N8','N9']

export function EmoteMenu() {
  const [data,      setData]      = useState<EmoteMenuData | null>(null)
  const [activeCat, setActiveCat] = useState('')
  const [search,    setSearch]    = useState('')
  const [playing,   setPlaying]   = useState<string | null>(null)
  const [assigning, setAssigning] = useState<number | null>(null)

  useEffect(() => {
    const off1 = onNUI<EmoteMenuData>('epsilon:emotes:open', d => {
      setData(d)
      setActiveCat(d.categories[0]?.id ?? '')
      setSearch('')
      setAssigning(null)
    })
    const off2 = onNUI<void>('epsilon:emotes:close', () => {
      setData(null); setPlaying(null); setAssigning(null)
    })
    const off3 = onNUI<(NumpadSlot | false)[]>('epsilon:emotes:updateNumpad', slots =>
      setData(prev => prev ? { ...prev, numpad: slots } : prev)
    )
    return () => { off1(); off2(); off3() }
  }, [])

  const currentCat = useMemo(
    () => data?.categories.find(c => c.id === activeCat),
    [data, activeCat]
  )

  const visible = useMemo(() => {
    if (!data) return []
    const q = search.trim().toLowerCase()
    if (!q) return currentCat?.emotes ?? []
    return data.categories.flatMap(c => c.emotes).filter(e =>
      e.label.toLowerCase().includes(q) || e.key.toLowerCase().includes(q)
    )
  }, [data, currentCat, search])

  if (!data) return null

  const handlePlay = (key: string) => {
    if (assigning !== null) {
      nuiPost('emotes:saveNumpad', { slot: assigning, key })
      setAssigning(null)
      return
    }
    setPlaying(key)
    nuiPost('emotes:play', { key })
  }

  const handleStop = () => {
    setPlaying(null)
    nuiPost('emotes:stop', {})
  }

  const handleClose = () => nuiPost('emotes:close', {})

  const handleNumpad = (idx: number) => {
    const slot = data.numpad[idx]
    if (assigning === idx + 1) { setAssigning(null); return }
    if (assigning !== null)    { setAssigning(idx + 1); return }
    if (slot) { setPlaying(slot.key); nuiPost('emotes:play', { key: slot.key }) }
    else      { setAssigning(idx + 1) }
  }

  const slotOf = (key: string) => {
    const i = data.numpad.findIndex(s => s && s.key === key)
    return i >= 0 ? i + 1 : null
  }

  const totalCount = data.categories.reduce((n, c) => n + c.emotes.length, 0)

  return (
    <div className={s.panel}>

      {/* ── Banner / Header ── */}
      <div className={s.banner}>
        <div className={s.bannerOverlay} />
        <div className={s.bannerContent}>
          <span className={s.bannerEyebrow}>EPSILON ROLEPLAY</span>
          <span className={s.bannerTitle}>Animations</span>
          <span className={s.bannerSub}>{totalCount} emotes disponibles</span>
        </div>
        <div className={s.bannerActions}>
          <button className={s.stopBtn} onClick={handleStop} title="Arrêter">
            <i className="bi bi-stop-fill" />
          </button>
          <button className={s.closeBtn} onClick={handleClose} title="Fermer">
            <i className="bi bi-x-lg" />
          </button>
        </div>
      </div>

      {/* ── Onglets catégories ── */}
      <div className={s.tabs}>
        {data.categories.map(cat => (
          <button
            key={cat.id}
            className={[s.tab, activeCat === cat.id ? s.tabActive : ''].join(' ')}
            onClick={() => { setActiveCat(cat.id); setSearch('') }}
            title={cat.label}
          >
            <i className={`bi ${cat.icon}`} />
            <span className={s.tabLabel}>{cat.label}</span>
          </button>
        ))}
      </div>

      {/* ── Recherche ── */}
      <div className={s.searchRow}>
        <i className="bi bi-search" />
        <input
          className={s.searchInput}
          placeholder="Rechercher une animation..."
          value={search}
          onChange={e => setSearch(e.target.value)}
          autoComplete="off"
        />
        {search && (
          <>
            <button className={s.clearBtn} onClick={() => setSearch('')}>
              <i className="bi bi-x" />
            </button>
            <span className={s.resultCount}>{visible.length}</span>
          </>
        )}
      </div>

      {/* ── Grille emotes ── */}
      <div className={s.grid}>
        {visible.length === 0
          ? <div className={s.empty}>
              <i className="bi bi-emoji-frown" />
              <span>Aucune animation</span>
            </div>
          : visible.map(emote => {
              const slot = slotOf(emote.key)
              return (
                <button
                  key={emote.key}
                  className={[
                    s.card,
                    playing === emote.key ? s.cardPlaying : '',
                    assigning !== null    ? s.cardAssign  : '',
                  ].join(' ')}
                  onClick={() => handlePlay(emote.key)}
                  title={emote.label}
                >
                  {slot !== null && <span className={s.badge}>{NUM_LABELS[slot - 1]}</span>}
                  {emote.canWalk && (
                    <span className={s.walkBadge} title="Marchable">
                      <i className="bi bi-person-walking" />
                    </span>
                  )}
                  <i className="bi bi-play-circle" />
                  <span className={s.cardLabel}>{emote.label}</span>
                </button>
              )
            })
        }
      </div>

      {/* ── Numpad ── */}
      <div className={s.numpadSection}>
        <div className={s.numpadHeader}>
          <i className="bi bi-grid-3x3" />
          <span>Raccourcis Numpad</span>
          {assigning !== null && (
            <span className={s.assignHint}>
              → clique une animation pour <strong>{NUM_LABELS[assigning - 1]}</strong>
            </span>
          )}
        </div>
        <div className={s.numpad}>
          {data.numpad.map((slot, i) => (
            <div
              key={i}
              className={[s.numSlot, slot ? s.numFilled : '', assigning === i + 1 ? s.numAssigning : ''].join(' ')}
              onClick={() => handleNumpad(i)}
            >
              <span className={s.numKey}>{NUM_LABELS[i]}</span>
              {slot
                ? <span className={s.numLabel}>{slot.label}</span>
                : <span className={s.numEmpty}>+</span>
              }
            </div>
          ))}
        </div>
      </div>

    </div>
  )
}
