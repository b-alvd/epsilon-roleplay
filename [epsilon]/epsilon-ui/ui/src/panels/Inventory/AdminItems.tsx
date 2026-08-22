import { useState, useEffect, useRef } from 'react'
import { nuiPost, onNUI } from '../../hooks/useNUI'
import s from './AdminItems.module.css'

// ─── Custom Select ────────────────────────────────────────────────────────────
function CustomSelect({ value, onChange, options }: {
  value: string
  onChange: (v: string) => void
  options: { value: string; label: string }[]
}) {
  const [open, setOpen] = useState(false)
  const ref = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!open) return
    const handler = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false)
    }
    document.addEventListener('mousedown', handler)
    return () => document.removeEventListener('mousedown', handler)
  }, [open])

  const current = options.find(o => o.value === value)?.label ?? value

  return (
    <div ref={ref} className={s.customSelect} onClick={() => setOpen(v => !v)}>
      <span className={s.customSelectValue}>{current}</span>
      <i className={`bi bi-chevron-down ${s.customSelectArrow}${open ? ' ' + s.customSelectArrowOpen : ''}`} />
      {open && (
        <div className={s.customSelectDropdown} onClick={e => e.stopPropagation()}>
          {options.map(o => (
            <div
              key={o.value}
              className={`${s.customSelectOption}${o.value === value ? ' ' + s.customSelectOptionActive : ''}`}
              onClick={() => { onChange(o.value); setOpen(false) }}
            >
              {o.label}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

// ─── Types ────────────────────────────────────────────────────────────────────
interface ItemDef {
  name: string
  label: string
  weight: number
  data: string      // JSON string from DB
  image?: string
}

interface ParsedItem extends Omit<ItemDef, 'data'> {
  data: Record<string, unknown>
}

const ITEM_TYPES = [
  { value: 'consumable', label: 'Consommable' },
  { value: 'objects',    label: 'Objet'       },
  { value: 'weapon',     label: 'Arme'        },
  { value: 'ammo',       label: 'Munitions'   },
  { value: 'key',        label: 'Clé'         },
  { value: 'clothing',   label: 'Tenue'       },
  { value: 'money',      label: 'Argent'      },
]

const TYPE_ICONS: Record<string, string> = {
  consumable: 'bi-cup-hot-fill',
  objects:    'bi-box-fill',
  weapon:     'bi-gun',
  ammo:       'bi-bullseye',
  key:        'bi-key-fill',
  clothing:   'bi-tags-fill',
  money:      'bi-cash-stack',
}

function parseItem(raw: ItemDef): ParsedItem {
  let data: Record<string, unknown> = {}
  try { data = JSON.parse(raw.data || '{}') } catch { /* */ }
  return { ...raw, data }
}

const WEAPON_CATEGORIES = [
  { value: 'melee',     label: 'Mêlée'            },
  { value: 'pistol',    label: 'Pistolet'          },
  { value: 'smg',       label: 'Mitraillette'      },
  { value: 'shotgun',   label: 'Fusil à pompe'     },
  { value: 'rifle',     label: 'Fusil d\'assaut'   },
  { value: 'mg',        label: 'Mitrailleuse'      },
  { value: 'sniper',    label: 'Sniper'            },
  { value: 'heavy',     label: 'Arme lourde'       },
  { value: 'throwable', label: 'Arme à lancer'     },
]

const AMMO_TYPES = [
  'AMMO_PISTOL', 'AMMO_SMG', 'AMMO_RIFLE', 'AMMO_SHOTGUN',
  'AMMO_SNIPER', 'AMMO_MG', 'AMMO_MUSKET', 'AMMO_STUNGUN',
  'AMMO_FLARE', 'AMMO_RPG', 'AMMO_GRENADE_LAUNCHER',
  'AMMO_FIREWORK', 'AMMO_HOMING_LAUNCHER',
  'AMMO_GRENADE', 'AMMO_MOLOTOV', 'AMMO_STICKYBOMB',
  'AMMO_PROXMINE', 'AMMO_PIPEBOMB', 'AMMO_BZGAS',
]

// ─── Item form ────────────────────────────────────────────────────────────────
function ItemForm({
  item,
  onSave,
  onDelete,
  onDuplicate,
}: {
  item: ParsedItem | null
  onSave: (item: ParsedItem) => void
  onDelete: (name: string) => void
  onDuplicate: (name: string) => void
}) {
  const isNew = !item?.name

  const [form, setForm] = useState<ParsedItem>(() => item ?? {
    name: '', label: '', weight: 0.1,
    image: '', data: { type: 'objects' },
  })
  const [confirmDelete, setConfirmDelete] = useState(false)

  useEffect(() => {
    setForm(item ?? { name: '', label: '', weight: 0.1, image: '', data: { type: 'objects' } })
    setConfirmDelete(false)
  }, [item?.name])

  const set = (k: keyof ParsedItem, v: unknown) => setForm(prev => ({ ...prev, [k]: v }))
  const setData = (k: string, v: unknown) => setForm(prev => ({ ...prev, data: { ...prev.data, [k]: v } }))

  const itemType     = (form.data.type as string)     || 'objects'
  const weaponCat    = (form.data.category as string) || 'pistol'
  const isMelee      = weaponCat === 'melee'

  const typeLabel = ITEM_TYPES.find(t => t.value === itemType)?.label ?? itemType

  return (
    <div className={s.form}>

      <div className={s.sectionHeader}>Preview</div>
      <div className={s.previewRow}>
        <div className={s.previewImgBox}>
          {form.image
            ? <img src={form.image} alt={form.label} className={s.previewImg} />
            : <i className={`bi ${TYPE_ICONS[itemType] ?? 'bi-box'}`} style={{ fontSize: 48, color: 'rgba(255,255,255,0.2)' }} />
          }
        </div>
        <div className={s.previewInfo}>
          <div className={s.previewLabel}>{form.label || '—'}</div>
          <div className={s.previewSub}>{typeLabel}</div>
        </div>
      </div>

      <div className={s.sectionHeader}>Informations</div>
      <div className={s.formScroll}>
        <div className={s.infoList}>
          <div className={s.infoRow}>
            <div className={s.infoRowLeft}><i className="bi bi-tag" /> Nom de spawn</div>
            <input className={s.infoInput} value={form.name}
              onChange={e => set('name', e.target.value.toLowerCase().replace(/\s+/g, '_'))}
              placeholder="item_name" readOnly={!isNew}
              style={!isNew ? { opacity: 0.45 } : undefined} />
          </div>
          <div className={s.infoRow}>
            <div className={s.infoRowLeft}><i className="bi bi-cursor-text" /> Nom d&apos;affichage</div>
            <input className={s.infoInput} value={form.label} onChange={e => set('label', e.target.value)} placeholder="Label" />
          </div>
          <div className={s.infoRow}>
            <div className={s.infoRowLeft}><i className="bi bi-speedometer2" /> Poids (kg)</div>
            <input className={s.infoInput} type="number" step="0.01" min="0" value={form.weight}
              onChange={e => set('weight', parseFloat(e.target.value) || 0)} />
          </div>
          <div className={s.infoRow}>
            <div className={s.infoRowLeft}><i className="bi bi-grid" /> Type</div>
            <CustomSelect value={itemType} onChange={v => setData('type', v)} options={ITEM_TYPES} />
          </div>
          <div className={s.infoRow}>
            <div className={s.infoRowLeft}><i className="bi bi-image" /> Image URL</div>
            <input className={s.infoInput} value={form.image ?? ''} onChange={e => set('image', e.target.value)} placeholder="https://…" />
          </div>

          {itemType === 'consumable' && <>
            <div className={s.infoSectionLabel}>Effets</div>
            <div className={s.infoRow}>
              <div className={s.infoRowLeft}><i className="bi bi-egg-fried" /> Faim</div>
              <input className={s.infoInput} type="number" value={(form.data.hunger as number) ?? 0}
                onChange={e => setData('hunger', parseInt(e.target.value) || 0)} />
            </div>
            <div className={s.infoRow}>
              <div className={s.infoRowLeft}><i className="bi bi-droplet" /> Soif</div>
              <input className={s.infoInput} type="number" value={(form.data.thirst as number) ?? 0}
                onChange={e => setData('thirst', parseInt(e.target.value) || 0)} />
            </div>
          </>}

          {itemType === 'weapon' && <>
            <div className={s.infoSectionLabel}>Arme</div>
            <div className={s.infoRow}>
              <div className={s.infoRowLeft}><i className="bi bi-list-ul" /> Catégorie</div>
              <CustomSelect value={weaponCat} onChange={v => setData('category', v)} options={WEAPON_CATEGORIES} />
            </div>
            {!isMelee && <>
              <div className={s.infoRow}>
                <div className={s.infoRowLeft}><i className="bi bi-bullseye" /> Munition</div>
                <CustomSelect value={(form.data.ammoType as string) ?? ''}
                  onChange={v => setData('ammoType', v)}
                  options={[{ value: '', label: '— Aucun —' }, ...AMMO_TYPES.map(a => ({ value: a, label: a }))]} />
              </div>
              <div className={s.infoRow}>
                <div className={s.infoRowLeft}><i className="bi bi-123" /> Chargeur</div>
                <input className={s.infoInput} type="number" min="1" value={(form.data.maxAmmo as number) ?? 12}
                  onChange={e => setData('maxAmmo', parseInt(e.target.value) || 1)} />
              </div>
            </>}
          </>}

          {itemType === 'ammo' && <>
            <div className={s.infoSectionLabel}>Munitions</div>
            <div className={s.infoRow}>
              <div className={s.infoRowLeft}><i className="bi bi-bullseye" /> Type</div>
              <CustomSelect value={(form.data.ammoType as string) ?? ''}
                onChange={v => setData('ammoType', v)}
                options={[{ value: '', label: '— Sélectionner —' }, ...AMMO_TYPES.map(a => ({ value: a, label: a }))]} />
            </div>
            <div className={s.infoRow}>
              <div className={s.infoRowLeft}><i className="bi bi-123" /> Quantité</div>
              <input className={s.infoInput} type="number" min="1" value={(form.data.amount as number) ?? 12}
                onChange={e => setData('amount', parseInt(e.target.value) || 1)} />
            </div>
          </>}

          <div className={s.sectionHeader}>Actions</div>
          <div className={s.formActions}>
            <button className={`${s.actionRow} ${s.actionPrimary}`} onClick={() => onSave(form)}>
              <i className="bi bi-check-lg" /> Sauvegarder
            </button>
            {!isNew && (
              <button className={s.actionRow} onClick={() => onDuplicate(form.name)}>
                <i className="bi bi-copy" /> Dupliquer
              </button>
            )}
            {!isNew && !confirmDelete && (
              <button className={`${s.actionRow} ${s.actionDanger}`} onClick={() => setConfirmDelete(true)}>
                <i className="bi bi-trash" /> Supprimer
              </button>
            )}
            {!isNew && confirmDelete && (
              <>
                <button className={`${s.actionRow} ${s.actionDanger}`} onClick={() => onDelete(form.name)}>
                  <i className="bi bi-exclamation-triangle" /> Confirmer
                </button>
                <button className={s.actionRow} onClick={() => setConfirmDelete(false)}>
                  Annuler
                </button>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

// ─── Main AdminItems panel ────────────────────────────────────────────────────
interface AdminItemsProps {
  onClose: () => void
}

const DEV_ITEMS: ItemDef[] = window.location.href.includes('localhost') ? [
  { name:'sandwich',           label:'Sandwich',            weight:0.2,  data:'{"type":"consumable","hunger":25,"thirst":5}' },
  { name:'water_bottle',       label:'Eau en bouteille',    weight:0.5,  data:'{"type":"consumable","hunger":0,"thirst":40}' },
  { name:'medkit',             label:'Kit médical',         weight:0.8,  data:'{"type":"consumable","hunger":0,"thirst":0}' },
  { name:'coffee',             label:'Café',                weight:0.3,  data:'{"type":"consumable","hunger":5,"thirst":20}' },
  { name:'pizza',              label:'Pizza',               weight:0.6,  data:'{"type":"consumable","hunger":50,"thirst":10}' },
  { name:'beer',               label:'Bière',               weight:0.4,  data:'{"type":"consumable","hunger":5,"thirst":15}' },
  { name:'phone',              label:'Téléphone',           weight:0.2,  data:'{"type":"objects"}' },
  { name:'rope',               label:'Corde',               weight:1.0,  data:'{"type":"objects"}' },
  { name:'fuel_can',           label:"Bidon d'essence",     weight:2.5,  data:'{"type":"objects"}' },
  { name:'briefcase',          label:'Valise',              weight:1.5,  data:'{"type":"objects"}' },
  { name:'lighter',            label:'Briquet',             weight:0.1,  data:'{"type":"objects"}' },
  { name:'weapon_pistol',      label:'Pistolet',            weight:1.2,  data:'{"type":"weapon","category":"pistol","ammoType":"AMMO_PISTOL","maxAmmo":12}' },
  { name:'weapon_assaultrifle',label:"Fusil d'assaut",      weight:3.5,  data:'{"type":"weapon","category":"rifle","ammoType":"AMMO_RIFLE","maxAmmo":30}' },
  { name:'weapon_knife',       label:'Couteau',             weight:0.4,  data:'{"type":"weapon","category":"melee"}' },
  { name:'weapon_sniperrifle', label:'Sniper',              weight:4.0,  data:'{"type":"weapon","category":"sniper","ammoType":"AMMO_SNIPER","maxAmmo":5}' },
  { name:'ammo_pistol',        label:'Munitions pistolet',  weight:0.05, data:'{"type":"ammo","ammoType":"AMMO_PISTOL","amount":12}' },
  { name:'ammo_smg',           label:'Munitions SMG',       weight:0.05, data:'{"type":"ammo","ammoType":"AMMO_SMG","amount":30}' },
  { name:'ammo_rifle',         label:'Munitions fusil',     weight:0.08, data:'{"type":"ammo","ammoType":"AMMO_RIFLE","amount":30}' },
  { name:'ammo_shotgun',       label:'Munitions shotgun',   weight:0.1,  data:'{"type":"ammo","ammoType":"AMMO_SHOTGUN","amount":8}' },
  { name:'ammo_sniper',        label:'Munitions sniper',    weight:0.12, data:'{"type":"ammo","ammoType":"AMMO_SNIPER","amount":5}' },
  { name:'car_key',            label:'Clé de voiture',      weight:0.05, data:'{"type":"key"}' },
  { name:'access_badge',       label:"Badge d'accès",       weight:0.05, data:'{"type":"key"}' },
  { name:'house_key',          label:'Clé de maison',       weight:0.05, data:'{"type":"key"}' },
  { name:'bulletproof_vest',   label:'Gilet pare-balles',   weight:2.0,  data:'{"type":"clothing"}' },
  { name:'tactical_helmet',    label:'Casque tactique',     weight:1.2,  data:'{"type":"clothing"}' },
  { name:'cash',               label:'Cash',                weight:0.01, data:'{"type":"money"}' },
  { name:'check',              label:'Chèque',              weight:0.01, data:'{"type":"money"}' },
] : []

export default function AdminItems({ onClose }: AdminItemsProps) {
  const [items, setItems]       = useState<ParsedItem[]>(() => DEV_ITEMS.map(parseItem))
  const [search, setSearch]     = useState('')
  const [typeFilter, setTypeFilter] = useState<string>('all')
  const [selected, setSelected] = useState<ParsedItem | null>(null)
  const [creating, setCreating] = useState(false)

  useEffect(() => {
    const off = onNUI<ItemDef[]>('epsilon:inventory:admin:itemsList', raw => {
      setItems(raw.map(parseItem))
    })
    nuiPost('inventory:admin:getItems', {})
    return off
  }, [])

  const filtered = items.filter(i => {
    const matchSearch = !search || i.label.toLowerCase().includes(search.toLowerCase()) || i.name.includes(search.toLowerCase())
    const matchType   = typeFilter === 'all' || (i.data.type as string) === typeFilter
    return matchSearch && matchType
  })

  // Count by type
  const typeCounts: Record<string, number> = {}
  for (const i of items) {
    const t = (i.data.type as string) || 'objects'
    typeCounts[t] = (typeCounts[t] || 0) + 1
  }

  function handleSave(item: ParsedItem) {
    nuiPost('inventory:admin:saveItem', { item })
    setCreating(false)
    setSelected(null)
  }

  function handleDelete(name: string) {
    nuiPost('inventory:admin:deleteItem', { name })
    setSelected(null)
  }

  function handleDuplicate(name: string) {
    nuiPost('inventory:admin:duplicateItem', { name })
    setSelected(null)
  }

  const activeItem = creating ? null : selected

  return (
    <div className={s.root}>
      {/* ── Header unifié ── */}
      <div className={s.header}>
        <div className={s.headerLeft}>
          <button className={s.backBtn} onClick={onClose}><i className="bi bi-chevron-left" /></button>
          <span className={s.headerTitle}>Gestion Items</span>
        </div>
        <div className={s.headerRight}>
          <button className={s.newItemBtn} onClick={() => { setCreating(true); setSelected(null) }}>
            <i className="bi bi-plus-lg" /> Nouvel item
          </button>
          <button className={s.plainClose} onClick={onClose}><i className="bi bi-x" /></button>
        </div>
      </div>

      {/* ── Body ── */}
      <div className={s.body}>

        {/* ── Colonne Catégories ── */}
        <div className={s.col}>
          <div className={s.colHeader} style={{ background: 'rgba(0,0,0,0.45)', border: 'none', color: '#fff', textTransform: 'none', fontSize: 13, fontWeight: 400, borderRadius: '2px 2px 0 0' }}>Catégories</div>
          <div className={s.sidebar}>
            <div className={s.catList}>
              <div
                className={`${s.catRow}${typeFilter === 'all' ? ' ' + s.catActive : ''}`}
                onClick={() => setTypeFilter('all')}
              >
                <i className="bi bi-grid-fill" /> Tous
                <span className={s.catCount}>{items.length}</span>
              </div>
              {ITEM_TYPES.map(t => (
                <div
                  key={t.value}
                  className={`${s.catRow}${typeFilter === t.value ? ' ' + s.catActive : ''}`}
                  onClick={() => setTypeFilter(t.value)}
                >
                  <i className={`bi ${TYPE_ICONS[t.value]}`} /> {t.label}
                  <span className={s.catCount}>{typeCounts[t.value] ?? 0}</span>
                </div>
              ))}
            </div>
          </div>
          <div className={s.sidebarSearch} style={{ marginTop: 8 }}>
            <i className="bi bi-search" style={{ color: 'rgba(255,255,255,0.65)', fontSize: 10, position: 'absolute', left: 10, top: '50%', transform: 'translateY(-50%)' }} />
            <input
              className={s.searchInput}
              style={{ paddingLeft: 28 }}
              placeholder="Rechercher..."
              value={search}
              onChange={e => setSearch(e.target.value)}
            />
            {search && (
              <button
                onClick={() => setSearch('')}
                style={{ position: 'absolute', right: 8, top: '50%', transform: 'translateY(-50%)', background: 'none', border: 'none', cursor: 'pointer', color: 'rgba(255,255,255,0.35)', fontSize: 14, lineHeight: 1, padding: 0, display: 'flex', alignItems: 'center' }}
              >
                <i className="bi bi-x" />
              </button>
            )}
          </div>
        </div>

        {/* ── Colonne Liste des items ── */}
        <div className={`${s.col} ${s.colMain}`}>
          <div className={s.colHeader} style={{ background: 'rgba(0,0,0,0.45)', border: 'none', color: '#fff', textTransform: 'none', fontWeight: 400, fontSize: 13, borderRadius: '2px 2px 0 0' }}>Liste des items</div>
          <div className={s.itemGrid}>
            {filtered.map(item => {
              const t = (item.data.type as string) || 'objects'
              const isActive = !creating && selected?.name === item.name
              return (
                <div
                  key={item.name}
                  className={`${s.itemCard}${isActive ? ' ' + s.itemCardActive : ''}`}
                  onClick={() => { setSelected(isActive ? null : item); setCreating(false) }}
                >
                  <div className={s.itemCardImg}>
                    {item.image
                      ? <img src={item.image} alt={item.label} style={{ width: '100%', height: '100%', objectFit: 'contain' }} />
                      : <i className={`bi ${TYPE_ICONS[t] ?? 'bi-box'}`} style={{ fontSize: 28, color: 'rgba(255,255,255,0.25)' }} />
                    }
                  </div>
                  <div className={s.itemCardName}>{item.label}</div>
                </div>
              )
            })}
            {filtered.length === 0 && (
              <div style={{ gridColumn: '1/-1', textAlign: 'center', padding: '40px 0', color: 'rgba(255,255,255,0.2)', fontSize: 12 }}>
                Aucun item
              </div>
            )}
          </div>
        </div>

        {/* ── Colonne Sélection ── */}
        <div className={s.col} style={{ width: 380 }}>
          <div className={s.colHeader} style={{ background: 'rgba(0,0,0,0.45)', border: 'none', color: '#fff', textTransform: 'none', fontWeight: 400, fontSize: 13, borderRadius: '2px 2px 0 0' }}>Sélection</div>
          {(creating || selected)
            ? <ItemForm
                item={creating ? null : activeItem}
                onSave={handleSave}
                onDelete={handleDelete}
                onDuplicate={handleDuplicate}
              />
            : <div className={s.noSelection}>
                <i className="bi bi-box" style={{ fontSize: 32, opacity: 0.15 }} />
                <span>Aucune sélection</span>
              </div>
          }
        </div>

      </div>
    </div>
  )
}
