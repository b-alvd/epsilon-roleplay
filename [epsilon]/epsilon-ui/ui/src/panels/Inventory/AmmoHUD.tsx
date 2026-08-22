import { useState, useEffect } from 'react'
import { onNUI } from '../../hooks/useNUI'

interface AmmoData {
  clip:      number
  max:       number
  throwable?: boolean
}

const styles: Record<string, React.CSSProperties> = {
  root: {
    position:       'fixed',
    bottom:         '48px',
    right:          '48px',
    display:        'flex',
    flexDirection:  'column',
    alignItems:     'flex-end',
    gap:            '8px',
    pointerEvents:  'none',
    userSelect:     'none',
  },
  counter: {
    display:        'flex',
    alignItems:     'baseline',
    gap:            '4px',
  },
  clip: {
    fontSize:       '48px',
    fontWeight:     700,
    lineHeight:     1,
    color:          'var(--text)',
    letterSpacing:  '-0.03em',
    textShadow:     '0 2px 12px rgba(0,0,0,0.6)',
  },
  sep: {
    fontSize:       '20px',
    fontWeight:     400,
    color:          'var(--dim)',
  },
  max: {
    fontSize:       '20px',
    fontWeight:     600,
    color:          'var(--muted)',
  },
  bullets: {
    display:        'flex',
    flexDirection:  'row-reverse',
    flexWrap:       'wrap-reverse',
    justifyContent: 'flex-start',
    gap:            '4px',
    maxWidth:       '160px',
  },
}

function Bullet({ filled }: { filled: boolean }) {
  return (
    <svg width="8" height="20" viewBox="0 0 8 20" fill="none">
      <rect x="1" y="6" width="6" height="12" rx="3"
        fill={filled ? 'var(--accent)' : 'var(--dim)'}
        opacity={filled ? 1 : 0.4}
        style={{ transition: 'fill .15s, opacity .15s' }}
      />
      <rect x="2" y="1" width="4" height="7" rx="2"
        fill={filled ? 'var(--text)' : 'var(--dim)'}
        opacity={filled ? 0.7 : 0.25}
        style={{ transition: 'fill .15s, opacity .15s' }}
      />
    </svg>
  )
}

export default function AmmoHUD() {
  const [ammo, setAmmo] = useState<AmmoData | null>(null)

  useEffect(() => {
    return onNUI<AmmoData | null>('epsilon:inventory:ammo', data => {
      setAmmo(data ?? null)
    })
  }, [])

  if (!ammo) return null

  if (ammo.throwable) {
    return (
      <div style={styles.root}>
        <div style={styles.counter}>
          <span style={styles.clip}>{ammo.clip}</span>
        </div>
      </div>
    )
  }

  if (ammo.max === 0) return null

  const bullets = Array.from({ length: ammo.max }, (_, i) => i < ammo.clip)

  return (
    <div style={styles.root}>
      <div style={styles.counter}>
        <span style={styles.clip}>{ammo.clip}</span>
        <span style={styles.sep}>/</span>
        <span style={styles.max}>{ammo.max}</span>
      </div>
      <div style={styles.bullets}>
        {bullets.map((filled, i) => (
          <Bullet key={i} filled={filled} />
        ))}
      </div>
    </div>
  )
}
