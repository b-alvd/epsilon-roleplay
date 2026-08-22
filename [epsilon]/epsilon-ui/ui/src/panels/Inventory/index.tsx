import { useState, useEffect, useRef, useCallback } from 'react'
import { nuiPost, onNUI } from '../../hooks/useNUI'
import s from './Inventory.module.css'

// ── Types ─────────────────────────────────────────────────────────────────────

export interface ItemInst {
  id: number
  name: string
  label: string
  category: string
  quantity: number
  image?: string
  weight: number
  slot?: number
  data: Record<string, unknown>
  idata: Record<string, unknown>
}

export interface HotbarSlot {
  slot: number
  name: string
  label: string
  image?: string
  quantity?: number
}

// Le serveur envoie des tableaux séparés par catégorie
export interface InventoryData {
  items:    ItemInst[]
  keys:     ItemInst[]
  weapons:  ItemInst[]
  clothing: ItemInst[]
  hotbar:   (HotbarSlot | null)[] | Record<string, HotbarSlot>
  weight?:    number
  maxWeight?: number
  cash?:      number
  playerName?: string
  hunger?:       number
  thirst?:       number
  stamina?:      number
  statusPaused?: boolean
  atmNearby?:   boolean
}

interface NearbyPlayer { src: number; name: string }

interface GroundItem {
  id: number
  name: string
  label: string
  quantity: number
  image?: string
  weight?: number
  item_data?: string
  x: number; y: number; z: number
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function normalizeHotbar(raw: InventoryData['hotbar']): (HotbarSlot | null)[] {
  const result: (HotbarSlot | null)[] = [null, null, null, null, null]
  if (!raw) return result
  const entries = Array.isArray(raw)
    ? raw.map((v, i) => [i + 1, v] as [number, HotbarSlot | null])
    : Object.entries(raw).map(([k, v]) => [Number(k), v] as [number, HotbarSlot | null])
  for (const [slot, val] of entries) {
    if (slot >= 1 && slot <= 5 && val) result[slot - 1] = val
  }
  return result
}

const fmtMoney = (v: number) => v.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
const fmtMoney2 = (v: number) => `${v.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} $`
const isMoney  = (item: ItemInst | GroundItem) =>
  ('idata' in item ? item.idata?.type : (item.item_data ? JSON.parse(item.item_data).type : null)) === 'money'
const fmtQty   = (item: ItemInst | GroundItem) =>
  isMoney(item)
    ? fmtMoney2(Number(item.quantity))
    : Math.floor(Number(item.quantity))

function getCatItems(inv: InventoryData, tab: string): ItemInst[] {
  const key = tab as keyof InventoryData
  const arr = inv[key]
  return Array.isArray(arr) ? (arr as ItemInst[]) : []
}

// ── Catégories ────────────────────────────────────────────────────────────────

const CATEGORIES = [
  { id: 'items',   label: 'Objets',  icon: 'bi-box-seam-fill'  },
  { id: 'keys',    label: 'Clés',    icon: 'bi-key-fill'       },
  { id: 'weapons', label: 'Armes',   icon: 'bi-crosshair2'     },
  { id: 'clothing',label: 'Tenues',  icon: 'bi-person-standing'},
]

const GRID_SLOTS = 40

const DRAG_THRESHOLD = 5  // px avant que le drag commence

// ── Drag ghost ────────────────────────────────────────────────────────────────

interface DragState {
  item: ItemInst | GroundItem
  fromGround?: boolean
  x: number
  y: number
}

interface PendingDrag {
  item: ItemInst | GroundItem
  fromGround: boolean
  startX: number
  startY: number
}

// ── Anneau stat (Vision RP) ───────────────────────────────────────────────────

function StatRing({ pct, color, icon, label, sublabel, paused }: { pct: number; color: string; icon: string; label?: string; sublabel?: string; paused?: boolean }) {
  const R = 27
  const C = 2 * Math.PI * R
  const offset = paused ? 0 : C - Math.max(0, Math.min(1, pct / 100)) * C
  const strokeColor = paused ? '#FFD700' : color
  return (
    <div className={s.hudItem}>
      <i className={icon} style={{ position:'absolute', top:'50%', left:'50%',
        transform:'translate(-50%,-50%)', fontSize:17, color:'rgba(255,255,255,0.4)',
        pointerEvents:'none', zIndex:1 }} />
      <svg height="60" width="60" style={{ position:'absolute', top:0, left:0 }}>
        <circle cx="30" cy="30" r={R} fill="transparent" stroke={strokeColor+'33'} strokeWidth="5" />
      </svg>
      <svg height="60" width="60" style={{ position:'absolute', top:0, left:0 }}>
        <circle cx="30" cy="30" r={R} fill="transparent" stroke={strokeColor} strokeWidth="5.5"
          strokeDasharray={C}
          strokeDashoffset={offset}
          className={paused ? s.ringPaused : undefined}
          style={{ transform:'rotate(-90deg)', transformOrigin:'50% 50%', transition:'stroke-dashoffset .6s ease, stroke .3s ease' }} />
      </svg>
      <div className={s.hudLabelStack}>
        <p className={s.hudPercent}>
          {paused ? <i className="bi-pause-fill" /> : (label ?? `${pct}%`)}
        </p>
        {sublabel && <p className={s.hudSubPercent}>{sublabel}</p>}
      </div>
    </div>
  )
}

// ── Modal Donner ──────────────────────────────────────────────────────────────

function GiveModal({ item, onClose, onConfirm }: {
  item: ItemInst; onClose: () => void; onConfirm: (src: number, qty: number) => void
}) {
  const isMoney = item.idata?.type === 'money'
  const minQty  = isMoney ? 0.01 : 1
  const [players, setPlayers] = useState<NearbyPlayer[]>([])
  const [target,  setTarget]  = useState<NearbyPlayer | null>(null)
  const [qty, setQty]         = useState(minQty)
  useEffect(() => { nuiPost<NearbyPlayer[]>('inventory:getNearbyPlayers',{}).then(r => setPlayers(r||[])) },[])
  return (
    <div className={s.modal}><div className={s.modalBox}>
      <div className={s.modalTitle}>Donner — {item.label}</div>
      <div className={s.playerList}>
        {players.length===0 && <div style={{fontSize:11,color:'rgba(255,255,255,0.35)',padding:'4px 0'}}>Aucun joueur à proximité</div>}
        {players.map(p=>(
          <div key={p.src} className={`${s.playerRow}${target?.src===p.src?' '+s.playerRowSel:''}`} onClick={()=>setTarget(p)}>
            <span className={s.playerRowId}>#{p.src}</span>
            <span className={s.playerRowName}>{p.name}</span>
          </div>
        ))}
      </div>
      <div className={s.qtyRow}>
        <span className={s.qtyLabel}>Quantité</span>
        <input type="number" min={minQty} max={item.quantity} step={isMoney ? 0.01 : 1} value={qty}
          onChange={e=>setQty(Math.min(item.quantity,Math.max(minQty,Number(e.target.value))))}
          className={s.qtyInput} />
      </div>
      <div className={s.modalBtns}>
        <button className={s.modalBtnCancel} onClick={onClose}>Annuler</button>
        <button className={s.modalBtnOk} disabled={!target} onClick={()=>target&&onConfirm(target.src,qty)}>Donner</button>
      </div>
    </div></div>
  )
}

// ── Modal Jeter ───────────────────────────────────────────────────────────────

function DropModal({ item, onClose, onConfirm }: {
  item: ItemInst; onClose: () => void; onConfirm: (qty: number) => void
}) {
  const isMoney = item.idata?.type === 'money'
  const minQty  = isMoney ? 0.01 : 1
  const [qty, setQty] = useState(minQty)
  return (
    <div className={s.modal}><div className={s.modalBox}>
      <div className={s.modalTitle}>Jeter — {item.label}</div>
      <div className={s.qtyRow}>
        <span className={s.qtyLabel}>Quantité</span>
        <input type="number" min={minQty} max={item.quantity} step={isMoney ? 0.01 : 1} value={qty}
          onChange={e=>setQty(Math.min(item.quantity,Math.max(minQty,Number(e.target.value))))}
          className={s.qtyInput} />
      </div>
      <div className={s.modalBtns}>
        <button className={s.modalBtnCancel} onClick={onClose}>Annuler</button>
        <button className={s.modalBtnOk} onClick={()=>onConfirm(qty)}>Jeter</button>
      </div>
    </div></div>
  )
}

// ── Composant principal ───────────────────────────────────────────────────────

export default function Inventory({ data }: { data: InventoryData }) {
  const [inv, setInv]           = useState<InventoryData>(data)
  const [tab, setTab]           = useState('items')
  const [search, setSearch]     = useState('')
  const [selected, setSelected] = useState<ItemInst | null>(null)
  const [hotbar, setHotbar]     = useState<(HotbarSlot|null)[]>(() => normalizeHotbar(data.hotbar))
  const [giveItem, setGiveItem] = useState<ItemInst | null>(null)
  const [dropItem, setDropItem] = useState<ItemInst | null>(null)
  const [drag, setDrag]               = useState<DragState | null>(null)
  const [dropSlot, setDropSlot]       = useState<number | null>(null)
  const [hoverGridSlot, setHoverGrid] = useState<number | null>(null)
  const [groundItems, setGround]      = useState<GroundItem[]>([])
  const [groundDrop, setGroundDrop]   = useState(false)
  const [activeSlot, setActiveSlot]   = useState<number | null>(null)
  const [atmNearby,  setAtmNearby]    = useState(data.atmNearby ?? false)
  const [showQuickInv, setShowQuickInv] = useState(true)
  const pendingDrag    = useRef<PendingDrag | null>(null)
  const searchRef      = useRef<HTMLInputElement>(null)
  const wrapperRef     = useRef<HTMLDivElement>(null)
  const atmNearbyRef   = useRef(data.atmNearby ?? false)
  const overPanelRef   = useRef(false)   // true quand la souris est sur le panneau inventaire

  useEffect(() => onNUI<InventoryData>('epsilon:inventory:update', d => {
    setInv(d); setHotbar(normalizeHotbar(d.hotbar))
  }), [])

  useEffect(() => onNUI<InventoryData['hotbar']>('epsilon:inventory:hotbar', d => {
    setHotbar(normalizeHotbar(d))
  }), [])

  useEffect(() => onNUI<GroundItem[]>('epsilon:inventory:groundItems', d => {
    setGround(d || [])
  }), [])

  useEffect(() => onNUI<number | null>('epsilon:inventory:activeSlot', d => {
    setActiveSlot(d ?? null)
  }), [])

  useEffect(() => onNUI<boolean>('epsilon:bank:atmNearby', d => {
    atmNearbyRef.current = !!d
    setAtmNearby(!!d)
  }), [])

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape' || e.key === 'Tab') {
        e.preventDefault()
        nuiPost('inventory:close', {})
      }
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [])

  // ── Mouse drag & drop (FiveM CEF ne supporte pas HTML5 drag) ──
  const dragRef = useRef<DragState | null>(null)
  useEffect(() => { dragRef.current = drag }, [drag])

  const startDrag = useCallback((e: React.MouseEvent, item: ItemInst | GroundItem, fromGround = false) => {
    e.preventDefault()
    pendingDrag.current = { item, fromGround, startX: e.clientX, startY: e.clientY }
  }, [])

  // Promotion pendingDrag → drag après DRAG_THRESHOLD, sinon click sur mouseup
  useEffect(() => {
    const onMove = (e: MouseEvent) => {
      if (!pendingDrag.current || dragRef.current) return
      const dx = e.clientX - pendingDrag.current.startX
      const dy = e.clientY - pendingDrag.current.startY
      if (Math.sqrt(dx * dx + dy * dy) >= DRAG_THRESHOLD) {
        const { item, fromGround } = pendingDrag.current
        pendingDrag.current = null
        setDrag({ item, fromGround, x: e.clientX, y: e.clientY })
        setSelected(null)
      }
    }
    const onUp = () => {
      if (!pendingDrag.current) return
      const { item, fromGround } = pendingDrag.current
      pendingDrag.current = null
      if (!fromGround) {
        setSelected(prev => prev?.id === (item as ItemInst).id ? null : (item as ItemInst))
      }
    }
    window.addEventListener('mousemove', onMove)
    window.addEventListener('mouseup', onUp)
    return () => { window.removeEventListener('mousemove', onMove); window.removeEventListener('mouseup', onUp) }
  }, [])

  useEffect(() => {
    if (!drag) return
    const onMove = (e: MouseEvent) => setDrag(d => d ? { ...d, x: e.clientX, y: e.clientY } : null)
    const onUp   = (_e: MouseEvent) => {
      if (drag) {
        const isCard      = !drag.fromGround && (drag.item as ItemInst).name === 'bank_card'
        const outsidePanel = !overPanelRef.current
        if (isCard && atmNearbyRef.current && outsidePanel) {
          // Carte relâchée hors du panneau inventaire → ATM
          nuiPost('inventory:close', {})
          nuiPost('bank:useCard', { itemId: drag.item.id })
        } else if (drag.fromGround && groundDrop) {
          // Sol → Inventaire joueur
          nuiPost('inventory:pickupItem', { id: drag.item.id })
          setGround(prev => prev.filter(g => g.id !== drag.item.id))
        } else if (!drag.fromGround && dropSlot !== null) {
          // Inventaire → Hotbar
          nuiPost('inventory:setHotbar', { slot: dropSlot, itemName: drag.item.name })
          setHotbar(prev => {
            const next = [...prev]
            next[dropSlot - 1] = {
              slot: dropSlot, name: drag.item.name,
              label: drag.item.label, image: drag.item.image,
            }
            return next
          })
        } else if (!drag.fromGround && hoverGridSlot !== null) {
          // Inventaire → autre case de la grille (déplacement/swap)
          const item = drag.item as ItemInst
          const toSlot = hoverGridSlot
          if (item.slot !== toSlot) {
            nuiPost('inventory:moveItem', { id: item.id, toSlot, toCategory: tab })
            // Mise à jour optimiste locale
            setInv(prev => {
              const catItems = getCatItems(prev, tab)
              const fromSlot = item.slot
              const updated = catItems.map(it => {
                if (it.id === item.id)    return { ...it, slot: toSlot }
                if (it.slot === toSlot)   return { ...it, slot: fromSlot ?? it.slot }
                return it
              })
              return { ...prev, [tab]: updated }
            })
          }
        }
      }
      setDrag(null)
      setDropSlot(null)
      setHoverGrid(null)
      setGroundDrop(false)
    }
    window.addEventListener('mousemove', onMove)
    window.addEventListener('mouseup', onUp)
    return () => { window.removeEventListener('mousemove', onMove); window.removeEventListener('mouseup', onUp) }
  }, [drag, dropSlot, groundDrop])

  const filtered = getCatItems(inv, tab).filter(it =>
    !search || it.label.toLowerCase().includes(search.toLowerCase())
  )

  // Grille positionnelle : chaque index = slot numéro (1-based)
  const gridSlots: (ItemInst | null)[] = Array(GRID_SLOTS).fill(null)
  filtered.forEach(it => {
    const idx = (it.slot ?? 0) - 1
    if (idx >= 0 && idx < GRID_SLOTS) gridSlots[idx] = it
    // Si pas de slot valide, mettre dans le premier vide
    else {
      const empty = gridSlots.indexOf(null)
      if (empty !== -1) gridSlots[empty] = it
    }
  })

  const handleUse = useCallback(() => {
    if (!selected) return
    nuiPost('inventory:useItem', { id: selected.id })
    setSelected(null)
  }, [selected])

  const handleGiveConfirm = useCallback((targetSrc: number, qty: number) => {
    if (!giveItem) return
    nuiPost('inventory:giveItem', { id: giveItem.id, quantity: qty, targetSrc })
    setGiveItem(null); setSelected(null)
  }, [giveItem])

  const handleDropConfirm = useCallback((qty: number) => {
    if (!dropItem) return
    nuiPost('inventory:dropItem', { id: dropItem.id, quantity: qty })
    setDropItem(null); setSelected(null)
  }, [dropItem])

  const weightPct = Math.round(((inv.weight ?? 0) / (inv.maxWeight || 30)) * 100)

  return (
    <div ref={wrapperRef} className={s.wrapper}>

      {/* ── Drag ghost ────────────────────────────────────────────── */}
      {drag && (
        <div className={s.dragGhost} style={{ left: drag.x, top: drag.y }}>
          {drag.item.image
            ? <div className={s.dragGhostImg} style={{ backgroundImage: `url("${drag.item.image}")` }} />
            : <i className="bi-box-seam-fill" style={{ fontSize: 28, color: '#fff' }} />
          }
        </div>
      )}

      {/* ── HUD droit ────────────────────────────────────────────── */}
      <div className={s.hud}>
        <div className={s.hudMoney}>
          <div className={s.hudMoneyValue}>
            <div className={s.labelMoneyValue}>
              <i className="bi-wallet2" />
              <p>Argent</p>
            </div>
            <span className={s.moneyAmount}>
              {fmtMoney(inv.cash ?? 0)} $
            </span>
          </div>
          <div className={s.hudGive} title="Donner de l'argent">
            <i className="bi-arrow-right-circle-fill" />
          </div>
        </div>
        <div className={s.hudCharacter}>
          <div className={s.hudCharAvatar}><i className="bi-person-fill" /></div>
          <p className={s.hudCharName}>{inv.playerName ?? 'Joueur'}</p>
        </div>
        <div className={s.hudItems}>
          <StatRing pct={weightPct} color="#ffffff" icon="bi-box-seam"
            sublabel={`${(inv.weight ?? 0).toFixed(1)}/${inv.maxWeight ?? 30}KG`}
          />
          <StatRing pct={inv.thirst ?? 100} color="#00f6ff" icon="bi-droplet-fill" paused={inv.statusPaused} />
          <StatRing pct={inv.hunger ?? 100} color="#00ff66" icon="bi-egg-fried"   paused={inv.statusPaused} />
        </div>

      </div>

      {/* ── Panneaux inventaire ───────────────────────────────────── */}
      <div className={s.baseContainer}
        onMouseEnter={() => { overPanelRef.current = true }}
        onMouseLeave={() => { overPanelRef.current = false }}
      >
        <div className={s.playerInventory}>
          <div className={s.mainContainer}>

            {/* Navigation catégories */}
            <div className={s.catNav}>
              {CATEGORIES.map(cat => {
                const active = cat.id === tab
                return (
                  <div key={cat.id}
                    className={`${s.nav}${active?' '+s.navActive:''}`}
                    onClick={() => { if (!active){ setTab(cat.id); setSearch(''); setSelected(null) } }}>
                    <i className={cat.icon} style={{ fontSize: active ? 26 : 20, flexShrink: 0, color:'#fff' }} />
                    {active && <span className={s.navLabel}>{cat.label}</span>}
                    {active && (
                      <div className={s.navSearch}>
                        <input ref={searchRef} type="text" className={s.navSearchInput}
                          placeholder="Rechercher un item…" value={search}
                          onChange={e=>setSearch(e.target.value)} />
                      </div>
                    )}
                  </div>
                )
              })}
            </div>

            {/* Grille — toujours 40 cases (accepte drop depuis Sol) */}
            <div className={s.gridsContainer}>
              <div className={s.gridContainer}
                onMouseEnter={() => drag?.fromGround && setGroundDrop(true)}
                onMouseLeave={() => setGroundDrop(false)}
              >
                <div className={s.grid}>
                  {gridSlots.map((item, i) => {
                    const slotNum  = i + 1
                    const isSel      = !!item && selected?.id === item.id
                    const isDragging = !!drag && !drag.fromGround && drag.item.id === item?.id
                    const isTarget   = !!drag && !drag.fromGround && hoverGridSlot === slotNum && !isDragging
                    return (
                      <div key={item ? item.id : `e${i}`} className={s.itemContainer}>
                        <div
                          className={`${s.item}${isSel?' '+s.itemSelected:''}${isDragging?' '+s.itemDragging:''}${isTarget?' '+s.itemSlotTarget:''}`}
                          onMouseDown={item ? e => startDrag(e, item) : undefined}
                          onMouseEnter={() => { if (drag && !drag.fromGround) setHoverGrid(slotNum) }}
                          onMouseLeave={() => { if (drag && !drag.fromGround) setHoverGrid(null) }}
                          style={{ cursor: drag ? 'grabbing' : item ? 'pointer' : 'default' }}
                        >
                          {item && item.quantity > 0 && <div className={s.itemQty}>{fmtQty(item)}</div>}
                          {item && <div className={s.itemImg}
                            style={item.image?{backgroundImage:`url("${item.image}")`}:undefined} />}
                          {item && <div className={s.itemLabel}>{item.label}</div>}
                        </div>
                      </div>
                    )
                  })}
                </div>
              </div>
            </div>

            {/* ── Hint ATM (overlay plein écran quand on glisse la carte) ── */}
            {atmNearby && drag && !drag.fromGround && (drag.item as ItemInst).name === 'bank_card' && (
              <div className={s.atmOverlay}>
                <div className={s.atmOverlayHint}>
                  <i className="bi bi-credit-card-2-front" />
                  Relâchez sur l'ATM pour insérer la carte
                </div>
              </div>
            )}

            {/* Panneau item sélectionné */}
            <div className={`${s.selectedPanel}${selected?' '+s.selectedPanelActive:''}`}>
              {selected && (() => {
                const isFirearm = selected.idata?.type === 'weapon'
                  && selected.idata?.category !== 'melee'
                  && selected.idata?.category !== 'throwable'
                const serial       = selected.data?.serial       as string | undefined
                const serialErased = selected.data?.serialErased as boolean | undefined
                return (
                  <>
                    <div className={s.ipImage}
                      style={selected.image?{backgroundImage:`url("${selected.image}")`}:undefined} />
                    <div className={s.ipMeta}>
                      <div className={s.ipName}>{selected.label}</div>
                      <div className={s.ipSub}>
                        {selected.quantity>1?(isMoney(selected)?`${fmtMoney2(Number(selected.quantity))} · `:`x${selected.quantity} · `):''}
                        {selected.weight?`${(selected.weight*selected.quantity).toFixed(1)} kg`:''}
                        {isFirearm && <span className={serial ? s.ipSerialOk : serialErased ? s.ipSerialErased : s.ipSerialNone}>
                          {' · '}{serial ?? (serialErased ? 'N/S effacé' : 'Aucun N/S')}
                        </span>}
                      </div>
                    </div>
                    <div className={s.ipActions}>
                      <button onClick={handleUse}>Utiliser</button>
                      <button onClick={()=>setGiveItem(selected)}>Donner</button>
                      <button onClick={()=>setDropItem(selected)}>Jeter</button>
                    </div>
                  </>
                )
              })()}
            </div>

          </div>

        </div>

        {/* ── Panneau Sol (affiché seulement si items proches) ─────── */}
        {groundItems.length > 0 && <div className={s.groundPanel}>
          <div className={s.mainContainer}>

            {/* Header Sol */}
            <div className={s.groundHeader}>
              <i className={`bi-box-arrow-in-down ${s.groundHeaderIcon}`} />
              <span className={s.groundHeaderLabel}>Sol</span>
              <div className={s.groundHeaderRefresh}
                onClick={() => nuiPost('inventory:getGroundItems', {})}>
                <i className="bi-bell-fill" />
              </div>
            </div>

            {/* Zone drop depuis sol → inventaire */}
            <div
              className={s.groundGrid}
              onMouseEnter={() => drag?.fromGround && setGroundDrop(true)}
              onMouseLeave={() => setGroundDrop(false)}
            >
              {groundItems.length === 0 ? (
                <div className={s.groundEmpty}>
                  <i className="bi-box2" />
                  <span>Aucun item à proximité</span>
                </div>
              ) : (
                <div className={s.grid}>
                  {[...groundItems, ...Array(Math.max(0, 40 - groundItems.length)).fill(null)].map((gi, i) => (
                    <div key={gi ? gi.id : `ge${i}`} className={s.itemContainer}>
                      {gi ? (
                        <div
                          className={s.item}
                          onMouseDown={e => startDrag(e, gi, true)}
                          style={{ cursor: 'grab' }}
                        >
                          <div className={s.itemQty}>{fmtQty(gi)}</div>
                          <div className={s.itemImg}
                            style={gi.image ? { backgroundImage: `url("${gi.image}")` } : undefined} />
                          <div className={s.itemLabel}>{gi.label}</div>
                        </div>
                      ) : (
                        <div className={s.item} style={{ cursor: 'default' }} />
                      )}
                    </div>
                  ))}
                </div>
              )}
            </div>

          </div>
        </div>}

      </div>


      {/* ── Inventaire rapide — BAS DROITE ───────────────────────── */}
      <div className={s.quickInvSection}>
        <button className={s.quickInvToggle} onClick={() => setShowQuickInv(v => !v)}>
          <i className="bi-grid-fill" />
          <span>Inventaire rapide</span>
          <i className={showQuickInv ? 'bi-chevron-up' : 'bi-chevron-down'} />
        </button>
        {showQuickInv && (
          <div className={s.quickInvBar}>
            {[1,2,3,4,5].map(slot => {
              const entry  = hotbar[slot - 1]
              const isOver = drag && dropSlot === slot
              const isActive = activeSlot === slot
              return (
                <div key={slot}
                  className={`${s.quickSlot}${isOver ? ' ' + s.weaponSlotOver : ''}${isActive ? ' ' + s.quickSlotActive : ''}`}
                  onMouseEnter={() => drag && setDropSlot(slot)}
                  onMouseLeave={() => drag && setDropSlot(null)}
                  onContextMenu={e => {
                    e.preventDefault()
                    if (entry) {
                      nuiPost('inventory:setHotbar', { slot, itemName: null })
                      setHotbar(prev => { const n = [...prev]; n[slot - 1] = null; return n })
                    }
                  }}
                >
                  <span className={s.keyHint}>{slot}</span>
                  {entry && <div className={s.itemImg}
                    style={entry.image ? { backgroundImage: `url("${entry.image}")` } : undefined} />}
                  {entry && <div className={s.itemLabel}>{entry.label}</div>}
                </div>
              )
            })}
          </div>
        )}
      </div>

      {/* Modales */}
      {giveItem && <GiveModal item={giveItem} onClose={()=>setGiveItem(null)} onConfirm={handleGiveConfirm} />}
      {dropItem && <DropModal item={dropItem} onClose={()=>setDropItem(null)} onConfirm={handleDropConfirm} />}

    </div>
  )
}

// ── HotbarOverlay (visible quand inventaire fermé) ────────────────────────────

export function HotbarOverlay({ hotbar, activeSlot, visible }: { hotbar: (HotbarSlot | null)[]; activeSlot?: number | null; visible: boolean }) {
  const slots = normalizeHotbar(hotbar as InventoryData['hotbar'])
  if (!slots.some(Boolean)) return null
  return (
    <div className={`${s.weaponContainer}${visible ? '' : ' ' + s.weaponContainerHidden}`}>
      <div className={s.weaponSlots}>
        {[0,1,2,3,4].map(i => {
          const entry    = slots[i]
          const isActive = activeSlot === i + 1
          return (
            <div key={i} className={`${s.weaponSlot}${isActive ? ' ' + s.weaponSlotActive : ''}`}>
              <span className={s.keyHint}>{i + 1}</span>
              {entry && <div className={s.slotImage}
                style={entry.image ? { backgroundImage: `url("${entry.image}")` } : undefined} />}
              {entry && <span className={s.slotLabel}>{entry.label}</span>}
            </div>
          )
        })}
      </div>
    </div>
  )
}
