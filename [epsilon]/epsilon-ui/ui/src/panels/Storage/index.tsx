import { useState } from 'react'
import { nuiPost } from '../../hooks/useNUI'
import s from './Storage.module.css'

export interface StorageItem {
  id: number
  storage_id?: number
  slot: number
  name: string
  quantity: number
  data: Record<string, unknown>
  label?: string
  image?: string
  weight?: number
}

export interface StorageInfo {
  id: number
  name: string
  label: string
  type: 'locker' | 'safe' | 'company'
  slots: number
}

export interface StorageData {
  storage: StorageInfo
  contents: StorageItem[]
  playerItems: (StorageItem & { id: number })[]
}

const TYPE_ICONS: Record<string, string> = {
  locker: 'bi-person-badge',
  safe: 'bi-safe',
  company: 'bi-building',
}

function ItemSlot({
  item,
  selected,
  onClick,
  empty,
}: {
  item?: StorageItem
  selected?: boolean
  onClick: () => void
  empty?: boolean
}) {
  if (!item) {
    return (
      <div className={`${s.slot} ${s.slotEmpty}`} onClick={onClick}>
        {!empty && <span className={s.slotNum}></span>}
      </div>
    )
  }

  return (
    <div className={`${s.slot} ${selected ? s.slotSelected : ''}`} onClick={onClick} title={item.label ?? item.name}>
      {item.image ? (
        <img src={item.image} alt={item.label ?? item.name} className={s.itemImg} />
      ) : (
        <i className="bi bi-box-seam" style={{ fontSize: 20, color: 'rgba(255,255,255,0.25)' }} />
      )}
      <div className={s.itemQty}>{item.quantity}</div>
      <div className={s.itemName}>{item.label ?? item.name}</div>
    </div>
  )
}

export default function Storage({ data, onClose }: { data: StorageData; onClose: () => void }) {
  const [selectedStorage, setSelectedStorage] = useState<number | null>(null)
  const [selectedPlayer,  setSelectedPlayer]  = useState<number | null>(null)
  const [loading, setLoading] = useState(false)

  const { storage, contents, playerItems } = data

  const storageSlots: (StorageItem | undefined)[] = Array.from({ length: storage.slots }, (_, i) => {
    const slot = i + 1
    return contents.find(c => c.slot === slot)
  })

  async function takeItem(slot: number) {
    if (loading) return
    setLoading(true)
    await nuiPost('storage:take', { storageId: storage.id, slot })
    setSelectedStorage(null)
    setLoading(false)
  }

  async function putItem(playerItemId: number) {
    if (loading) return
    setLoading(true)
    await nuiPost('storage:put', { storageId: storage.id, playerItemId })
    setSelectedPlayer(null)
    setLoading(false)
  }

  function handleStorageSlotClick(slot: number) {
    const item = storageSlots[slot - 1]
    if (!item) { setSelectedStorage(null); return }
    if (selectedStorage === slot) {
      takeItem(slot)
    } else {
      setSelectedStorage(slot)
      setSelectedPlayer(null)
    }
  }

  function handlePlayerSlotClick(itemId: number) {
    if (selectedPlayer === itemId) {
      putItem(itemId)
    } else {
      setSelectedPlayer(itemId)
      setSelectedStorage(null)
    }
  }

  const selStorageItem = selectedStorage != null ? storageSlots[selectedStorage - 1] : null
  const selPlayerItem  = selectedPlayer  != null ? playerItems.find(p => p.id === selectedPlayer) : null

  return (
    <div className={s.overlay}>
      <div className={s.panel}>
        {/* Header */}
        <div className={s.header}>
          <div className={s.headerLeft}>
            <i className={`bi ${TYPE_ICONS[storage.type] ?? 'bi-box'}`} />
            <div>
              <div className={s.headerType}>{storage.type.toUpperCase()}</div>
              <div className={s.headerTitle}>{storage.label}</div>
            </div>
          </div>
          <button className={s.closeBtn} onClick={onClose}><i className="bi bi-x-lg" /></button>
        </div>

        <div className={s.body}>
          {/* Inventaire joueur — gauche */}
          <div className={s.side}>
            <div className={s.sideTitle}>
              <i className="bi bi-person" /> Mon inventaire
            </div>
            <div className={s.grid} style={{ '--cols': 4 } as React.CSSProperties}>
              {playerItems.map(item => (
                <ItemSlot
                  key={item.id}
                  item={item}
                  selected={selectedPlayer === item.id}
                  onClick={() => handlePlayerSlotClick(item.id)}
                />
              ))}
              {playerItems.length === 0 && (
                <div className={s.empty}>Inventaire vide</div>
              )}
            </div>
          </div>

          {/* Séparateur + action */}
          <div className={s.center}>
            {selPlayerItem && (
              <button className={s.actionBtn} onClick={() => putItem(selPlayerItem.id)} disabled={loading}>
                <i className="bi bi-arrow-right" />
                <span>Déposer</span>
              </button>
            )}
            {selStorageItem && (
              <button className={s.actionBtn} onClick={() => takeItem(selectedStorage!)} disabled={loading}>
                <i className="bi bi-arrow-left" />
                <span>Prendre</span>
              </button>
            )}
            {!selPlayerItem && !selStorageItem && (
              <div className={s.hint}>
                <i className="bi bi-hand-index" />
                <span>Cliquez<br/>un item</span>
              </div>
            )}
          </div>

          {/* Coffre — droite */}
          <div className={s.side}>
            <div className={s.sideTitle}>
              <i className="bi bi-box-seam" /> {storage.label}
              <span className={s.slotCount}>{contents.length}/{storage.slots}</span>
            </div>
            <div className={s.grid} style={{ '--cols': 4 } as React.CSSProperties}>
              {storageSlots.map((item, i) => (
                <ItemSlot
                  key={i}
                  item={item}
                  selected={selectedStorage === i + 1}
                  onClick={() => handleStorageSlotClick(i + 1)}
                />
              ))}
            </div>
          </div>
        </div>

        {/* Info item sélectionné */}
        {(selStorageItem || selPlayerItem) && (
          <div className={s.itemInfo}>
            {(selStorageItem ?? selPlayerItem) && (() => {
              const it = selStorageItem ?? selPlayerItem!
              return (
                <>
                  <span className={s.itemInfoName}>{it.label ?? it.name}</span>
                  <span className={s.itemInfoQty}>x{it.quantity}</span>
                  {it.weight && <span className={s.itemInfoWeight}>{(it.weight * it.quantity / 1000).toFixed(2)} kg</span>}
                  <span className={s.itemInfoHint}>
                    {selStorageItem ? 'Double-clic ou ← pour prendre' : 'Double-clic ou → pour déposer'}
                  </span>
                </>
              )
            })()}
          </div>
        )}
      </div>
    </div>
  )
}
