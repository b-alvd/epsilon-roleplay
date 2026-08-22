import { useState, useCallback, useEffect, useRef } from 'react'
import {} from 'lucide-react'
import { cx } from '../../../utils/cx'
import { nuiPost } from '../../../hooks/useNUI'
import shared from '../CharacterSelect.module.css'
import s from './CreatorScreen.module.css'
import imgBanner from '../../../assets/bannieres/creator.png'
import imgLS     from '../../../assets/charcreator/spawn-ls.jpg'
import imgPaleto from '../../../assets/charcreator/spawn-paleto.jpg'
import imgSandy  from '../../../assets/charcreator/spawn-sandy.jpg'

// ── Boutons caméra ────────────────────────────────────────────────────────────
const CAM_BTN_LIST: { id: 'full'|'face'|'torso'|'legs'|'feet', icon: React.ReactNode }[] = [
  { id: 'full', icon: (
    <svg viewBox="0 0 640 1280" fill="currentColor">
      <g transform="translate(0,1280) scale(0.1,-0.1)">
        <path d="M3027 12784 c-290 -52 -544 -220 -705 -463 -134 -204 -189 -425 -170 -681 30 -386 296 -743 659 -886 143 -56 212 -68 389 -69 168 0 209 6 340 47 263 83 515 309 630 562 124 273 129 581 13 856 -73 174 -231 368 -378 465 -233 154 -520 216 -778 169z"/>
        <path d="M1920 10435 c-8 -2 -49 -9 -90 -15 -106 -17 -265 -71 -371 -126 -394 -204 -653 -566 -731 -1024 -10 -59 -13 -445 -13 -1815 l0 -1740 22 -71 c71 -223 311 -355 546 -300 161 38 267 129 328 281 l24 60 3 1553 2 1552 110 0 110 0 2 -4152 3 -4153 21 -61 c59 -169 154 -284 295 -353 190 -93 392 -93 586 0 152 73 269 220 314 394 10 40 14 536 16 2472 l3 2423 105 0 105 0 0 -2407 c0 -2080 2 -2418 15 -2478 61 -293 341 -494 655 -471 260 18 457 165 538 401 l27 80 3 4153 2 4153 108 -3 107 -3 5 -1555 c4 -1101 8 -1564 16 -1585 75 -204 232 -315 447 -315 234 0 413 158 447 395 8 58 10 541 8 1770 -3 1588 -5 1696 -22 1785 -110 572 -500 992 -1046 1128 l-105 26 -1290 2 c-709 1 -1297 1 -1305 -1z"/>
      </g>
    </svg>
  )},
  { id: 'face', icon: (
    <svg viewBox="0 0 24 24" fill="currentColor">
      <circle cx="12" cy="8" r="6"/>
      <path d="M2 22 Q5 14 12 14 Q19 14 22 22 Z"/>
    </svg>
  )},
  { id: 'torso', icon: (
    <svg viewBox="0 0 40.143 40.143" fill="currentColor">
      <path d="M29.248,4.118l-0.502,0.503V4.118h-2.473c-1.115,1.723-3.469,2.914-6.202,2.914c-2.732,0-5.086-1.191-6.201-2.914h-2.473 v0.503l-0.503-0.503L2,13.017l4.865,4.869l4.532-4.534v22.672h17.347V13.353l4.533,4.534l4.864-4.87L29.248,4.118z"/>
    </svg>
  )},
  { id: 'legs', icon: (
    <svg viewBox="0 0 909 1280" fill="currentColor" preserveAspectRatio="none">
      <g transform="translate(0,1280) scale(0.1,-0.1)">
        <path d="M1922 12428 l3 -373 2620 0 2620 0 3 373 2 372 -2625 0 -2625 0 2 -372z"/>
        <path d="M3187 11633 l-1267 -3 2 -408 3 -407 568 -5 c627 -6 591 -1 582 -70 -2 -19 -7 -78 -10 -130 -17 -264 -121 -587 -260 -801 -104 -161 -213 -272 -358 -367 -137 -90 -276 -132 -433 -132 -103 0 -168 20 -259 81 -38 26 -71 46 -73 45 -1 -2 -25 -129 -52 -282 -27 -153 -126 -712 -220 -1241 -93 -530 -247 -1396 -340 -1925 -94 -530 -184 -1037 -200 -1128 -16 -91 -92 -520 -169 -955 -77 -434 -187 -1058 -245 -1385 -58 -327 -134 -757 -170 -955 -45 -256 -60 -362 -52 -367 6 -4 581 -8 1277 -8 997 0 1268 3 1281 13 9 7 43 124 87 297 70 283 319 1269 701 2785 109 435 298 1186 420 1670 122 484 291 1154 376 1489 138 550 164 640 178 625 2 -2 90 -346 196 -764 105 -418 247 -980 315 -1250 68 -269 230 -911 359 -1425 130 -514 330 -1311 446 -1770 115 -459 256 -1017 311 -1240 64 -253 108 -410 117 -417 13 -10 284 -13 1281 -13 696 0 1271 4 1277 8 8 5 -7 111 -52 367 -36 198 -112 628 -170 955 -58 327 -168 951 -245 1385 -77 435 -153 864 -169 955 -16 91 -106 598 -200 1128 -93 529 -247 1395 -340 1925 -94 529 -193 1088 -220 1241 -27 153 -51 280 -52 282 -2 1 -35 -19 -73 -45 -91 -61 -156 -81 -259 -81 -157 0 -296 42 -433 132 -145 95 -254 206 -358 367 -139 214 -243 537 -260 801 -3 52 -8 111 -10 130 -9 69 -45 64 582 70 l568 5 3 408 2 407 -1217 0 c-670 0 -1281 2 -1358 3 -77 2 -710 2 -1408 0z"/>
        <path d="M1900 10553 c0 -5 -34 -195 -74 -423 l-75 -415 22 -19 c52 -44 120 -69 189 -68 212 1 403 139 533 385 74 141 131 363 123 487 l-3 55 -357 3 c-197 1 -358 -1 -358 -5z"/>
        <path d="M6453 10552 c-16 -10 -1 -172 27 -289 64 -268 220 -490 411 -581 135 -65 252 -73 347 -22 55 29 72 45 72 68 0 11 -31 198 -70 416 -38 218 -70 401 -70 406 0 12 -699 14 -717 2z"/>
        <path d="M81 403 c-35 -197 -67 -366 -72 -375 -5 -9 -9 -19 -9 -22 0 -3 562 -6 1250 -6 l1249 0 10 38 c46 178 181 712 181 716 0 3 -573 6 -1273 6 l-1273 0 -63 -357z"/>
        <path d="M6400 754 c0 -4 135 -538 181 -716 l10 -38 1250 0 c1188 0 1251 1 1244 17 -12 28 -29 117 -86 441 l-53 302 -1273 0 c-700 0 -1273 -3 -1273 -6z"/>
      </g>
    </svg>
  )},
  { id: 'feet', icon: (
    <svg viewBox="0 0 1200 1200" fill="currentColor">
      <g transform="translate(0,1200) scale(0.1,-0.1)">
        <path d="M5667 8485 c-63 -23 -95 -53 -152 -140 -67 -102 -133 -162 -287 -265 -366 -243 -955 -445 -1543 -529 -270 -38 -385 -46 -695 -45 -325 0 -478 12 -768 59 -409 67 -841 189 -1202 341 -236 98 -230 97 -293 91 -67 -6 -134 -41 -171 -90 -80 -105 -307 -678 -411 -1037 -106 -368 -140 -589 -139 -910 1 -406 63 -768 196 -1140 l34 -95 -119 -475 c-130 -519 -131 -529 -85 -617 27 -54 91 -107 146 -123 51 -14 8188 -14 8392 0 1250 87 2466 454 3040 917 210 170 372 399 387 548 19 178 -74 503 -212 745 -283 496 -765 832 -1385 964 -172 37 -330 55 -580 66 -232 10 -324 23 -517 75 l-97 26 -1278 -1278 -1278 -1278 -142 38 c-294 77 -401 106 -406 112 -4 3 573 585 1281 1293 l1288 1288 -193 76 -193 76 -1310 -1309 -1310 -1308 -275 71 c-151 39 -277 72 -280 75 -2 2 598 606 1335 1343 737 737 1337 1341 1334 1344 -7 7 -349 166 -357 166 -4 0 -626 -619 -1382 -1375 l-1375 -1375 -140 30 c-135 28 -427 80 -449 80 -6 0 638 649 1431 1443 l1443 1442 -128 70 c-308 168 -590 341 -822 504 -74 52 -151 101 -170 108 -46 16 -115 15 -163 -2z m-4695 -1101 c209 -79 573 -279 803 -439 460 -320 811 -727 1005 -1162 108 -243 161 -439 204 -750 l5 -33 -1162 0 -1162 0 -27 88 c-115 371 -162 800 -124 1122 28 227 102 528 196 790 44 125 161 420 165 420 2 0 45 -16 97 -36z"/>
      </g>
    </svg>
  )},
]

// ── Parents ───────────────────────────────────────────────────────────────────
const PARENTS: Record<number, string> = {
  0:'Benjamin', 1:'Daniel', 2:'Joshua', 3:'Noah', 4:'Andrew',
  5:'Joan', 6:'Alex', 7:'Isaac', 8:'Evan', 9:'Ethan',
  10:'Vincent', 11:'Angel', 12:'Diego', 13:'Adrian', 14:'Gabriel',
  15:'Michael', 16:'Santiago', 17:'Kevin', 18:'Louis', 19:'Samuel',
  20:'Anthony', 21:'Hannah', 22:'Audrey', 23:'Jasmine', 24:'Giselle',
  25:'Amelia', 26:'Isabella', 27:'Zoe', 28:'Ava', 29:'Camila',
  30:'Violet', 31:'Sophia', 32:'Evelyn', 33:'Nicole', 34:'Ashley',
  35:'Grace', 36:'Brianna', 37:'Natalie', 38:'Olivia', 39:'Elizabeth',
  40:'Charlotte', 41:'Emma', 42:'John', 43:'Niko', 44:'Claude', 45:'Misty',
}
const FATHERS = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,42,43,44]
const MOTHERS  = [21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,45]

const parentImgs = import.meta.glob('../../../assets/charcreator/parents/*.webp', { eager: true, import: 'default' }) as Record<string, string>

function parentPortraitUrl(id: number): string | null {
  const name = PARENTS[id]
  if (!name) return null
  const key = `../../../assets/charcreator/parents/${name}.webp`
  return parentImgs[key] ?? null
}

const HAIR_COLORS = [
  '#0D0D0D','#1A0905','#270E06','#391807','#502508','#61340C','#6F4315','#885830',
  '#A07040','#B88C58','#CCA870','#E0C48A','#EEDA9F','#F5E9B8','#FAF2D0','#FEFDF0',
  '#350E0E','#500D08','#6B160C','#882818','#9E3520','#B04020','#C15528','#D07030',
  '#E08C3A','#D4AA32','#BF9830','#A88028','#8C6820','#705015','#503510','#38220C',
  '#1A1A1A','#282828','#363636','#484848','#585858','#686868','#787878','#888888',
  '#9C9C9C','#ACACAC','#C0C0C0','#D0D0D0','#E0E0E0','#EEEEEE','#F8F8F8','#FFFFFF',
  '#EE4444','#EE2266','#DD0099','#AA00CC','#6600BB','#3300AA','#2244EE','#4488FF',
  '#00AAFF','#00DDEE','#00EE88','#66FF00','#EEFF00','#FFCC00','#FF8800','#FF5500',
]
const MAKEUP_COLORS = [
  '#F5DEB3','#F0C8A0','#E8B88A','#DFA878','#D49060','#C87848','#B86030','#A84818',
  '#8C3010','#6A1808','#500808','#380404','#FF9999','#FF6677','#FF3355','#FF0033',
  '#CC0044','#990033','#660022','#440011','#FFAACC','#FF77AA','#FF4488','#EE1166',
  '#CC0055','#AA0044','#880033','#660022','#DDAAFF','#CC88FF','#AA55EE','#8833CC',
  '#6611AA','#440088','#330066','#220044','#AACCFF','#88AAFF','#5577EE','#2244CC',
  '#1133AA','#002288','#001166','#000044','#AAFFCC','#66EEBB','#33CC99','#009966',
  '#007744','#005533','#003322','#001111','#FFFFAA','#FFEE88','#FFCC55','#FFAA22',
  '#FF8800','#EE6600','#CC4400','#AA2200','#884400','#663300','#442200','#221100',
]

const FACE_FEATURES = [
  { id:0,  label:'Nez - Largeur',        group:'nose' as const },
  { id:1,  label:'Nez - Hauteur pointe', group:'nose' as const },
  { id:2,  label:'Nez - Longueur',       group:'nose' as const },
  { id:3,  label:'Nez - Arête',          group:'nose' as const },
  { id:4,  label:'Nez - Abaissement',    group:'nose' as const },
  { id:5,  label:'Nez - Torsion',        group:'nose' as const },
  { id:6,  label:'Sourcils - Hauteur',   group:'eyes' as const },
  { id:7,  label:'Sourcils - Largeur',   group:'eyes' as const },
  { id:11, label:'Yeux - Ouverture',     group:'eyes' as const },
  { id:8,  label:'Pommettes - Hauteur',  group:'jaw'  as const },
  { id:9,  label:'Pommettes - Largeur',  group:'jaw'  as const },
  { id:10, label:'Joues - Largeur',      group:'jaw'  as const },
  { id:13, label:'Mâchoire - Largeur',   group:'jaw'  as const },
  { id:14, label:'Mâchoire - Avancée',   group:'jaw'  as const },
  { id:12, label:'Lèvres - Épaisseur',   group:'chin' as const },
  { id:15, label:'Menton - Avancée',     group:'chin' as const },
  { id:16, label:'Menton - Longueur',    group:'chin' as const },
  { id:17, label:'Menton - Largeur',     group:'chin' as const },
  { id:18, label:'Menton - Fossette',    group:'chin' as const },
  { id:19, label:'Cou - Épaisseur',      group:'neck' as const },
]

// ── Types ─────────────────────────────────────────────────────────────────────
interface ClothingComp { drawable: number; texture: number }
interface Outfit {
  components: Record<number, ClothingComp>  // SetPedComponentVariation
  props:      Record<number, ClothingComp>  // SetPedPropIndex (-1 = aucun)
}

// GTA V clothing components (SetPedComponentVariation)
const CLOTHING_COMPONENTS: { id:number; label:string; section:string; maxD:number; maxT:number }[] = [
  { id:11, label:'Haut / Veste',        section:'Hauts',        maxD:255, maxT:16 },
  { id:3,  label:'Torse',               section:'Hauts',        maxD:255, maxT:16 },
  { id:8,  label:'Sous-vêtement',       section:'Hauts',        maxD:255, maxT:16 },
  { id:4,  label:'Pantalon',            section:'Bas',          maxD:155, maxT:16 },
  { id:6,  label:'Chaussures',          section:'Bas',          maxD:103, maxT:16 },
  { id:1,  label:'Masque',              section:'Accessoires',  maxD:255, maxT:16 },
  { id:7,  label:'Accessoires (cou)',   section:'Accessoires',  maxD:255, maxT:16 },
  { id:5,  label:'Sac / Parachute',     section:'Accessoires',  maxD:62,  maxT:16 },
  { id:9,  label:'Gilet / Armure',      section:'Accessoires',  maxD:20,  maxT:16 },
  { id:10, label:'Décalcomanies',       section:'Accessoires',  maxD:11,  maxT:16 },
]
// GTA V props (SetPedPropIndex) — drawable -1 = retiré
const CLOTHING_PROPS: { id:number; label:string; section:string; maxD:number; maxT:number }[] = [
  { id:0, label:'Chapeau / Casque',   section:'Couvre-chefs', maxD:210, maxT:16 },
  { id:1, label:'Lunettes',           section:'Couvre-chefs', maxD:46,  maxT:16 },
  { id:2, label:'Accessoires oreille',section:'Couvre-chefs', maxD:10,  maxT:16 },
  { id:6, label:'Montre',             section:'Bijoux',       maxD:50,  maxT:16 },
  { id:7, label:'Bracelet',           section:'Bijoux',       maxD:15,  maxT:16 },
]
interface Overlay { index:number; opacity:number; colorType:number; colorId:number; secondColorId:number }
interface Skin {
  headBlend: { shapeFirst:number; shapeSecond:number; shapeMix:number; skinFirst:number; skinSecond:number; skinMix:number }
  faceFeatures: Record<number, number>
  hair: { style:number; color:number; highlight:number }
  eyeColor: number
  overlays: Record<number, Overlay>
}

function makeDefaultSkin(): Skin {
  return {
    headBlend: { shapeFirst:0, shapeSecond:21, shapeMix:0.5, skinFirst:0, skinSecond:21, skinMix:0.5 },
    faceFeatures: Object.fromEntries(FACE_FEATURES.map(f => [f.id, 0])),
    hair: { style:0, color:0, highlight:0 },
    eyeColor: 0,
    overlays: {
      0:  { index:255, opacity:0, colorType:0, colorId:0, secondColorId:0 },
      1:  { index:255, opacity:0, colorType:1, colorId:0, secondColorId:0 },
      2:  { index:0,   opacity:1, colorType:1, colorId:0, secondColorId:0 },
      3:  { index:255, opacity:0, colorType:0, colorId:0, secondColorId:0 },
      4:  { index:255, opacity:0, colorType:2, colorId:0, secondColorId:0 },
      5:  { index:255, opacity:0, colorType:2, colorId:0, secondColorId:0 },
      6:  { index:255, opacity:0, colorType:0, colorId:0, secondColorId:0 },
      7:  { index:255, opacity:0, colorType:0, colorId:0, secondColorId:0 },
      8:  { index:255, opacity:0, colorType:2, colorId:0, secondColorId:0 },
      9:  { index:255, opacity:0, colorType:0, colorId:0, secondColorId:0 },
      10: { index:255, opacity:0, colorType:1, colorId:0, secondColorId:0 },
    },
  }
}

// ── Composants utilitaires ────────────────────────────────────────────────────
function Palette({ colors, selected, onPick }: { colors:string[]; selected:number; onPick:(i:number)=>void }) {
  return (
    <div className={s.palette}>
      {colors.map((col, i) => (
        <div key={i} className={cx(s.swatch, i === selected && s.selected)}
          style={{ background: col }} onClick={() => onPick(i)} />
      ))}
    </div>
  )
}

function ParentCarousel({ value, list, onChange }: { value: number; list: number[]; onChange: (v: number) => void }) {
  const idx = list.indexOf(value)
  const cur = idx === -1 ? 0 : idx
  const trackRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const track = trackRef.current
    if (!track) return
    const card = track.children[cur] as HTMLElement
    if (!card) return
    track.scrollLeft = card.offsetLeft - track.offsetWidth / 2 + card.offsetWidth / 2
  }, [cur])

  return (
    <div className={s.carousel}>
      <button className={s.carouselChevron} onClick={() => onChange(list[Math.max(0, cur - 1)])}>‹</button>
      <div className={s.carouselTrack} ref={trackRef}>
        {list.map((id, i) => {
          const portrait = parentPortraitUrl(id)
          return (
            <div key={id} className={cx(s.carouselCard, i === cur && s.carouselCardActive)} onClick={() => onChange(id)}>
              {portrait
                ? <img src={portrait} className={s.carouselCardImg} />
                : <div className={s.carouselCardImg} />}
              <div className={s.carouselCardName}>{PARENTS[id] ?? '?'}</div>
            </div>
          )
        })}
      </div>
      <button className={s.carouselChevron} onClick={() => onChange(list[Math.min(list.length - 1, cur + 1)])}>›</button>
    </div>
  )
}

function Stepper({ value, min=0, max, onChange, labels }: {
  value:number; min?:number; max:number; onChange:(v:number)=>void; labels?: Record<number,string>
}) {
  return (
    <div className={s.stepper}>
      <button className={s.stepperBtn} onClick={() => onChange(Math.max(min, value-1))}>‹</button>
      <div className={s.stepperValue}>{labels ? `${String(value).padStart(2,'0')} - ${labels[value] ?? '?'}` : value}</div>
      <button className={s.stepperBtn} onClick={() => onChange(Math.min(max, value+1))}>›</button>
    </div>
  )
}

function Slider({ label, value, min=0, max=100, displayFn, onChange }: {
  label:string; value:number; min?:number; max?:number
  displayFn?:(v:number)=>string; onChange:(v:number)=>void
}) {
  const trackRef     = useRef<HTMLDivElement>(null)
  const thumbRef     = useRef<HTMLDivElement>(null)
  const labelValRef  = useRef<HTMLSpanElement>(null)
  const onChangeRef  = useRef(onChange);  onChangeRef.current = onChange
  const minRef       = useRef(min);       minRef.current = min
  const maxRef       = useRef(max);       maxRef.current = max
  const displayFnRef = useRef(displayFn); displayFnRef.current = displayFn
  const currentVal   = useRef(value)
  const dragging     = useRef(false)
  const prevX        = useRef(0)
  const trackW       = useRef(300) // largeur du track en px, mis à jour au mousedown

  const applyDOM = (v: number) => {
    const mn = minRef.current, mx = maxRef.current
    const cap = mx - 1
    v = Math.max(mn, Math.min(cap, v))
    currentVal.current = v
    const rng = cap - mn
    const pct       = rng > 0 ? ((v - mn) / rng) * 100 : 0
    const originPct = mn < 0 ? ((-mn) / rng) * 100 : 0
    const fillStart = Math.min(originPct, pct)
    const fillEnd   = Math.max(originPct, pct)
    if (thumbRef.current) thumbRef.current.style.left = `${pct}%`
    if (trackRef.current) {
      trackRef.current.style.setProperty('--fill-start', `${fillStart}%`)
      trackRef.current.style.setProperty('--fill-end',   `${fillEnd}%`)
    }
    if (labelValRef.current) {
      const fn = displayFnRef.current
      const display = v === cap ? mx : v
      labelValRef.current.textContent = fn ? fn(display) : String(display)
    }
  }

  const handlePointerDown = (e: React.PointerEvent<HTMLDivElement>) => {
    const track = trackRef.current
    if (!track) return
    try { e.currentTarget.setPointerCapture(e.pointerId) } catch {}
    dragging.current = true
    const rect = track.getBoundingClientRect()
    trackW.current = rect.width || 300
    const mn = minRef.current, mx = maxRef.current
    const cap = mx - 1
    const rng = mx - mn
    const pct = Math.max(0, Math.min(1, (e.clientX - rect.left) / trackW.current))
    // On mappe sur le range complet [mn, mx] puis on clamp à cap
    const v   = Math.min(cap, Math.round(mn + pct * rng))
    prevX.current = e.clientX
    applyDOM(v)
    onChangeRef.current(v)
  }

  const handlePointerMove = (e: React.PointerEvent<HTMLDivElement>) => {
    if (!dragging.current) return
    const deltaX = e.clientX - prevX.current
    prevX.current = e.clientX
    const mn = minRef.current, mx = maxRef.current
    const cap = mx - 1
    const rng = mx - mn
    const deltaV = rng > 0 ? (deltaX / trackW.current) * rng : 0
    const v = Math.min(cap, Math.max(mn, Math.round(currentVal.current + deltaV)))
    if (Math.abs(v - currentVal.current) >= rng * 0.5) return
    if (v === currentVal.current) return
    applyDOM(v)
    onChangeRef.current(v)
  }

  const handlePointerUp = () => { dragging.current = false }

  useEffect(() => {
    if (trackRef.current) trackW.current = trackRef.current.offsetWidth || 300
    applyDOM(value)
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const cap           = max - 1
  const initPct       = cap > min ? ((Math.min(value, cap) - min) / (cap - min)) * 100 : 0
  const initOriginPct = min < 0 ? ((-min) / (cap - min)) * 100 : 0
  const initFillStart = Math.min(initOriginPct, initPct)
  const initFillEnd   = Math.max(initOriginPct, initPct)

  return (
    <div className={s.slider}>
      <div className={s.sliderHeader}>
        <span className={s.sliderLabel}>{label}</span>
        <span ref={labelValRef} className={s.sliderValue}>
          {(() => { const cap = max - 1; const dv = value >= cap ? max : value; return displayFn ? displayFn(dv) : dv })()}
        </span>
      </div>
      <div ref={trackRef} className={s.sliderTrack}
        onPointerDown={handlePointerDown}
        onPointerMove={handlePointerMove}
        onPointerUp={handlePointerUp}
        onPointerCancel={handlePointerUp}
        style={{ '--fill-start': `${initFillStart}%`, '--fill-end': `${initFillEnd}%` } as React.CSSProperties}>
        <div ref={thumbRef} className={s.sliderThumb} />
      </div>
    </div>
  )
}

// ── Traits tab with collapsible groups ───────────────────────────────────────
const TRAIT_GROUPS = ['nose','eyes','jaw','chin','neck'] as const
const TRAIT_LABELS: Record<string,string> = { nose:'Nez', eyes:'Yeux & Sourcils', jaw:'Joues & Mâchoire', chin:'Lèvres & Menton', neck:'Cou' }

function TraitsTab({ skin, update }: { skin: Skin; update: (fn:(s:Skin)=>Skin)=>void }) {
  const [open, setOpen] = useState<Set<string>>(new Set(['nose']))
  const toggle = (g: string) => setOpen(prev => {
    const next = new Set(prev)
    next.has(g) ? next.delete(g) : next.add(g)
    return next
  })
  return (
    <div className={s.detail}>
      {TRAIT_GROUPS.map(group => {
        const feats = FACE_FEATURES.filter(f => f.group === group)
        const isOpen = open.has(group)
        return (
          <div key={group} className={s.dropdown}>
            <button className={s.dropdownHeader} onClick={() => toggle(group)}>
              <span>{TRAIT_LABELS[group]}</span>
              <span className={cx(s.dropdownChevron, isOpen && s.dropdownChevronOpen)}>›</span>
            </button>
            {isOpen && (
              <div className={s.dropdownBody}>
                {feats.map(f => (
                  <Slider key={f.id} label={f.label} value={Math.round((skin.faceFeatures[f.id]??0)*100)}
                    min={-100} max={100} displayFn={v=>(v/100).toFixed(2)}
                    onChange={v=>update(sk=>({...sk,faceFeatures:{...sk.faceFeatures,[f.id]:v/100}}))} />
                ))}
              </div>
            )}
          </div>
        )
      })}
    </div>
  )
}

// ── Tenue tab with collapsible sections ──────────────────────────────────────
function TenueTab({ outfit, setOutfit }: { outfit: Outfit; setOutfit: (fn:(o:Outfit)=>Outfit)=>void }) {
  const sections = [...new Set([
    ...CLOTHING_COMPONENTS.map(c => c.section),
    ...CLOTHING_PROPS.map(p => p.section),
  ])]
  const [open, setOpen] = useState<Set<string>>(new Set([sections[0]]))
  const toggle = (s: string) => setOpen(prev => { const n = new Set(prev); n.has(s) ? n.delete(s) : n.add(s); return n })

  return (
    <div className={s.detail} style={{ gap:'4px', padding:'0' }}>
      {sections.map(sec => {
        const comps = CLOTHING_COMPONENTS.filter(c => c.section === sec)
        const props = CLOTHING_PROPS.filter(p => p.section === sec)
        const isOpen = open.has(sec)
        return (
          <div key={sec} className={s.dropdown}>
            <button className={s.dropdownHeader} onClick={() => toggle(sec)}>
              <span>{sec}</span>
              <span className={cx(s.dropdownChevron, isOpen && s.dropdownChevronOpen)}>›</span>
            </button>
            {isOpen && (
              <div className={s.dropdownBody}>
                {comps.map(c => (
                  <div key={c.id} className={s.field}>
                    <div className={s.label}>{c.label}</div>
                    <div style={{ display:'flex', gap:'0.5vw' }}>
                      <div style={{ flex:1 }}>
                        <div className={s.sliderLabel} style={{ fontSize:'0.45vw', marginBottom:'4px' }}>Modèle</div>
                        <Stepper value={outfit.components[c.id]?.drawable ?? 0} max={c.maxD}
                          onChange={v => setOutfit(o => ({ ...o, components: { ...o.components, [c.id]: { ...o.components[c.id], drawable: v } } }))} />
                      </div>
                      <div style={{ flex:1 }}>
                        <div className={s.sliderLabel} style={{ fontSize:'0.45vw', marginBottom:'4px' }}>Texture</div>
                        <Stepper value={outfit.components[c.id]?.texture ?? 0} max={c.maxT}
                          onChange={v => setOutfit(o => ({ ...o, components: { ...o.components, [c.id]: { ...o.components[c.id], texture: v } } }))} />
                      </div>
                    </div>
                  </div>
                ))}
                {props.map(p => (
                  <div key={p.id} className={s.field}>
                    <div className={s.label}>{p.label}</div>
                    <div style={{ display:'flex', gap:'0.5vw' }}>
                      <div style={{ flex:1 }}>
                        <div className={s.sliderLabel} style={{ fontSize:'0.45vw', marginBottom:'4px' }}>Modèle (-1 = aucun)</div>
                        <Stepper value={outfit.props[p.id]?.drawable ?? -1} min={-1} max={p.maxD}
                          onChange={v => setOutfit(o => ({ ...o, props: { ...o.props, [p.id]: { ...o.props[p.id], drawable: v } } }))} />
                      </div>
                      <div style={{ flex:1 }}>
                        <div className={s.sliderLabel} style={{ fontSize:'0.45vw', marginBottom:'4px' }}>Texture</div>
                        <Stepper value={outfit.props[p.id]?.texture ?? 0} max={p.maxT}
                          onChange={v => setOutfit(o => ({ ...o, props: { ...o.props, [p.id]: { ...o.props[p.id], texture: v } } }))} />
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )
      })}
    </div>
  )
}

// ── Navigation tabs ───────────────────────────────────────────────────────────
type Tab = 'identite' | 'heritage' | 'traits' | 'apparence' | 'tenue' | 'spawn'
type SpawnZone = 'ls' | 'paleto' | 'sandy'
const SPAWN_ZONES: { id: SpawnZone; label: string; desc: string; img: string }[] = [
  { id:'ls',     label:'Los Santos',   desc:'Centre-ville',           img: imgLS     },
  { id:'paleto', label:'Paleto Bay',   desc:'Village du nord',        img: imgPaleto },
  { id:'sandy',  label:'Sandy Shores', desc:'Désert de Blaine County', img: imgSandy  },
]

// Lucide-style stroke icons
const IconIdentite = () => <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
  <circle cx="12" cy="7" r="4"/>
</svg>

const IconHeritage = () => <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M2 12C2 6.5 6.5 2 12 2a10 10 0 0 1 8 4"/>
  <path d="M9 6.8a6 6 0 0 1 9 5.2v1"/>
  <path d="M12 10a2 2 0 0 0-2 2c0 1.5-.2 3-.5 4.5"/>
  <path d="M5.5 19C6 17 6 15 6 12a6 6 0 0 1 .34-2"/>
  <path d="M14 13c0 3 0 6-1 9"/>
  <path d="M17.3 21c.2-1 .5-2.5.5-3"/>
  <path d="M21.8 16c.1-1.5.1-3 0-5"/>
  <path d="M8.5 22c.2-.7.4-1.4.5-2"/>
  <path d="M2.1 16h.01"/>
</svg>

const IconTraits = () => <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <circle cx="18" cy="5" r="3" fill="currentColor"/>
  <circle cx="6" cy="12" r="3" fill="currentColor"/>
  <circle cx="18" cy="19" r="3" fill="currentColor"/>
  <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/>
  <line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/>
</svg>

const IconAppar = () => <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/>
  <circle cx="12" cy="12" r="3"/>
</svg>

const IconVetem = () => <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M20.38 3.46 16 2a4 4 0 0 1-8 0L3.62 3.46a2 2 0 0 0-1.34 2.23l.58 3.57a1 1 0 0 0 .99.84H6v10a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2V10h2.15a1 1 0 0 0 .99-.84l.58-3.57a2 2 0 0 0-1.34-2.23z"/>
</svg>

const IconSpawn = () => <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/>
  <circle cx="12" cy="10" r="3"/>
</svg>

const TABS: { id: Tab; Icon: () => JSX.Element; title: string }[] = [
  { id:'identite',  Icon: IconIdentite, title:'Identité'  },
  { id:'heritage',  Icon: IconHeritage, title:'Héritage'  },
  { id:'traits',    Icon: IconTraits,   title:'Traits'    },
  { id:'apparence', Icon: IconAppar,    title:'Apparence' },
  { id:'tenue',     Icon: IconVetem,    title:'Tenue'     },
  { id:'spawn',     Icon: IconSpawn,    title:'Spawn'     },
]
const EXTRA_ICONS: (() => JSX.Element)[] = []

type AppItem =
  | 'cheveux' | 'barbe' | 'sourcils'
  | 'yeux'
  | 'fond-de-teint' | 'fard-a-joues' | 'levres'
  | 'imperfections' | 'vieillissement' | 'teint' | 'taches' | 'dommages'

const APP_LABEL: Record<AppItem, string> = {
  'cheveux':'Cheveux', 'barbe':'Barbe', 'sourcils':'Sourcils',
  'yeux':'Couleurs', 'fond-de-teint':'Fard à paupières',
  'fard-a-joues':'Fard à joues', 'levres':'Lèvres',
  'imperfections':'Imperfections', 'vieillissement':'Vieillissement',
  'teint':'Teint', 'taches':'Tâches cutanées', 'dommages':'Dommages solaires',
}

// ── Appearance tab with nested dropdowns ──────────────────────────────────────
const APP_GROUPS: { label: string; items: { id: AppItem; label: string }[] }[] = [
  { label: 'Pilosité',   items: [{ id:'cheveux', label:'Cheveux' }, { id:'barbe', label:'Barbe' }, { id:'sourcils', label:'Sourcils' }] },
  { label: 'Yeux',       items: [{ id:'yeux', label:'Couleurs des yeux' }] },
  { label: 'Maquillage', items: [{ id:'fond-de-teint', label:'Fard à paupières' }, { id:'fard-a-joues', label:'Fard à joues' }, { id:'levres', label:'Lèvres' }] },
  { label: 'Détails',    items: [{ id:'imperfections', label:'Imperfections' }, { id:'vieillissement', label:'Vieillissement' }, { id:'teint', label:'Teint' }, { id:'taches', label:'Tâches cutanées' }, { id:'dommages', label:'Dommages solaires' }] },
]

function AppearanceTab({ skin, update, gender }: { skin: Skin; update: (fn:(s:Skin)=>Skin)=>void; gender: 0|1 }) {
  const [openGroups, setOpenGroups] = useState<Set<string>>(new Set(['Pilosité']))
  const [openItems,  setOpenItems]  = useState<Set<string>>(new Set())

  const toggleGroup = (g: string) => setOpenGroups(prev => { const n = new Set(prev); n.has(g) ? n.delete(g) : n.add(g); return n })
  const toggleItem  = (id: string) => setOpenItems(prev => { const n = new Set(prev); n.has(id) ? n.delete(id) : n.add(id); return n })

  const setOvlIndex   = (i:number, v:number) => update(sk => ({ ...sk, overlays: { ...sk.overlays, [i]: { ...sk.overlays[i], index: v } } }))
  const setOvlOpacity = (i:number, v:number) => update(sk => ({ ...sk, overlays: { ...sk.overlays, [i]: { ...sk.overlays[i], opacity: v/100 } } }))
  const setOvlColor   = (i:number, c:number) => update(sk => ({ ...sk, overlays: { ...sk.overlays, [i]: { ...sk.overlays[i], colorId: c } } }))

  const renderItem = (id: AppItem) => {
    switch (id) {
      case 'cheveux': return (<>
        <div className={s.field}><div className={s.label}>Style</div>
          <Stepper value={skin.hair.style} max={74} onChange={v => update(sk => ({ ...sk, hair: { ...sk.hair, style:v } }))} /></div>
        <div className={s.field}><div className={s.label}>Couleur principale</div>
          <Palette colors={HAIR_COLORS} selected={skin.hair.color} onPick={i => update(sk => ({ ...sk, hair: { ...sk.hair, color:i } }))} /></div>
        <div className={s.field}><div className={s.label}>Reflets / Mèches</div>
          <Palette colors={HAIR_COLORS} selected={skin.hair.highlight} onPick={i => update(sk => ({ ...sk, hair: { ...sk.hair, highlight:i } }))} /></div>
      </>)
      case 'barbe': return (<>
        <div className={s.field}><div className={s.label}>Style</div>
          <Stepper value={skin.overlays[1].index===255?0:skin.overlays[1].index} max={28} onChange={v=>setOvlIndex(1,v)} /></div>
        <Slider label="Opacité" value={Math.round(skin.overlays[1].opacity*100)} displayFn={v=>(v/100).toFixed(1)} onChange={v=>setOvlOpacity(1,v)} />
        <div className={s.field}><div className={s.label}>Couleur</div>
          <Palette colors={HAIR_COLORS} selected={skin.overlays[1].colorId} onPick={i=>setOvlColor(1,i)} /></div>
      </>)
      case 'sourcils': return (<>
        <div className={s.field}><div className={s.label}>Style</div>
          <Stepper value={skin.overlays[2].index===255?0:skin.overlays[2].index} max={33} onChange={v=>setOvlIndex(2,v)} /></div>
        <Slider label="Opacité" value={Math.round(skin.overlays[2].opacity*100)} displayFn={v=>(v/100).toFixed(1)} onChange={v=>setOvlOpacity(2,v)} />
        <div className={s.field}><div className={s.label}>Couleur</div>
          <Palette colors={HAIR_COLORS} selected={skin.overlays[2].colorId} onPick={i=>setOvlColor(2,i)} /></div>
      </>)
      case 'yeux': return (
        <div className={s.field}><div className={s.label}>Couleur des yeux</div>
          <Stepper value={skin.eyeColor} max={30} onChange={v=>update(sk=>({...sk, eyeColor:v}))} /></div>
      )
      case 'fond-de-teint': return (<>
        <div className={s.field}><div className={s.label}>Style</div>
          <Stepper value={skin.overlays[4].index===255?0:skin.overlays[4].index} max={74} onChange={v=>setOvlIndex(4,v)} /></div>
        <Slider label="Opacité" value={Math.round(skin.overlays[4].opacity*100)} displayFn={v=>(v/100).toFixed(1)} onChange={v=>setOvlOpacity(4,v)} />
        <div className={s.field}><div className={s.label}>Couleur</div>
          <Palette colors={MAKEUP_COLORS} selected={skin.overlays[4].colorId} onPick={i=>setOvlColor(4,i)} /></div>
      </>)
      case 'fard-a-joues': return (<>
        <div className={s.field}><div className={s.label}>Style</div>
          <Stepper value={skin.overlays[5].index===255?0:skin.overlays[5].index} max={6} onChange={v=>setOvlIndex(5,v)} /></div>
        <Slider label="Opacité" value={Math.round(skin.overlays[5].opacity*100)} displayFn={v=>(v/100).toFixed(1)} onChange={v=>setOvlOpacity(5,v)} />
        <div className={s.field}><div className={s.label}>Couleur</div>
          <Palette colors={MAKEUP_COLORS} selected={skin.overlays[5].colorId} onPick={i=>setOvlColor(5,i)} /></div>
      </>)
      case 'levres': return (<>
        <div className={s.field}><div className={s.label}>Style</div>
          <Stepper value={skin.overlays[8].index===255?0:skin.overlays[8].index} max={8} onChange={v=>setOvlIndex(8,v)} /></div>
        <Slider label="Opacité" value={Math.round(skin.overlays[8].opacity*100)} displayFn={v=>(v/100).toFixed(1)} onChange={v=>setOvlOpacity(8,v)} />
        <div className={s.field}><div className={s.label}>Couleur</div>
          <Palette colors={MAKEUP_COLORS} selected={skin.overlays[8].colorId} onPick={i=>setOvlColor(8,i)} /></div>
      </>)
      case 'imperfections': return (<>
        <div className={s.field}><div className={s.label}>Style</div>
          <Stepper value={skin.overlays[0].index===255?0:skin.overlays[0].index} max={22} onChange={v=>setOvlIndex(0,v)} /></div>
        <Slider label="Opacité" value={Math.round(skin.overlays[0].opacity*100)} displayFn={v=>(v/100).toFixed(1)} onChange={v=>setOvlOpacity(0,v)} />
      </>)
      case 'vieillissement': return (<>
        <div className={s.field}><div className={s.label}>Style</div>
          <Stepper value={skin.overlays[3].index===255?0:skin.overlays[3].index} max={14} onChange={v=>setOvlIndex(3,v)} /></div>
        <Slider label="Opacité" value={Math.round(skin.overlays[3].opacity*100)} displayFn={v=>(v/100).toFixed(1)} onChange={v=>setOvlOpacity(3,v)} />
      </>)
      case 'teint': return (<>
        <div className={s.field}><div className={s.label}>Style</div>
          <Stepper value={skin.overlays[6].index===255?0:skin.overlays[6].index} max={11} onChange={v=>setOvlIndex(6,v)} /></div>
        <Slider label="Opacité" value={Math.round(skin.overlays[6].opacity*100)} displayFn={v=>(v/100).toFixed(1)} onChange={v=>setOvlOpacity(6,v)} />
      </>)
      case 'taches': return (<>
        <div className={s.field}><div className={s.label}>Style</div>
          <Stepper value={skin.overlays[9].index===255?0:skin.overlays[9].index} max={8} onChange={v=>setOvlIndex(9,v)} /></div>
        <Slider label="Opacité" value={Math.round(skin.overlays[9].opacity*100)} displayFn={v=>(v/100).toFixed(1)} onChange={v=>setOvlOpacity(9,v)} />
      </>)
      case 'dommages': return (
        <Slider label="Intensité" value={Math.round(skin.overlays[7].opacity*100)} displayFn={v=>(v/100).toFixed(1)} onChange={v=>setOvlOpacity(7,v)} />
      )
      default: return null
    }
  }

  return (
    <div className={s.detail} style={{ gap: '4px', padding:'0' }}>
      {APP_GROUPS.map(group => {
        const isGroupOpen = openGroups.has(group.label)
        const visibleItems = group.label === 'Pilosité' ? group.items.filter(i => i.id !== 'barbe' || gender === 0) : group.items
        return (
          <div key={group.label} className={s.dropdown}>
            <button className={s.dropdownHeader} onClick={() => toggleGroup(group.label)}>
              <span>{group.label}</span>
              <span className={cx(s.dropdownChevron, isGroupOpen && s.dropdownChevronOpen)}>›</span>
            </button>
            {isGroupOpen && (
              <div style={{ display:'flex', flexDirection:'column', gap:'2px', padding:'8px 0 10px' }}>
                {visibleItems.map(item => {
                  const isItemOpen = openItems.has(item.id)
                  return (
                    <div key={item.id} className={cx(s.dropdown, s.dropdownNested)}>
                      <button className={cx(s.dropdownHeader, s.dropdownHeaderNested)} onClick={() => toggleItem(item.id)}>
                        <span>{item.label}</span>
                        <span className={cx(s.dropdownChevron, isItemOpen && s.dropdownChevronOpen)}>›</span>
                      </button>
                      {isItemOpen && (
                        <div className={s.dropdownBody}>
                          {renderItem(item.id)}
                        </div>
                      )}
                    </div>
                  )
                })}
              </div>
            )}
          </div>
        )
      })}
    </div>
  )
}

// ── Props ─────────────────────────────────────────────────────────────────────
function makeDefaultOutfit(): Outfit {
  const comp = (): ClothingComp => ({ drawable: 0, texture: 0 })
  return {
    components: Object.fromEntries(CLOTHING_COMPONENTS.map(c => [c.id, comp()])),
    props:      Object.fromEntries(CLOTHING_PROPS.map(p => [p.id, { drawable: -1, texture: 0 }])),
  }
}

interface Props {
  slot: number
  gender: 0 | 1
  onBack: () => void
  onGenderChange: (g: 0|1, slot: number) => void
  onConfirm: (firstname:string, lastname:string, dob:string, gender:0|1, skin:Skin, outfit:Outfit, spawnZone:SpawnZone) => void
  onAppearanceChange: (skin:Skin, gender:0|1) => void
  onOutfitChange: (outfit:Outfit) => void
}

export default function CreatorScreen({ slot, gender: initGender, onBack, onGenderChange, onConfirm, onAppearanceChange, onOutfitChange }: Props) {
  const [tab, setTab]         = useState<Tab>('identite')
  const [appItem, setAppItem] = useState<AppItem | null>(null)
  const [gender, setGender]   = useState<0|1>(initGender)
  const [skin, setSkin]       = useState<Skin>(makeDefaultSkin)
  const [err, setErr]         = useState('')
  const [fn, setFn]           = useState('')
  const [ln, setLn]           = useState('')
  const [dob, setDob]         = useState('')
  const [spawnZone, setSpawnZone] = useState<SpawnZone>('ls')
  const [outfit, setOutfitRaw] = useState<Outfit>(makeDefaultOutfit)

  const setOutfit = useCallback((updater: (o: Outfit) => Outfit) => {
    setOutfitRaw(prev => {
      const next = updater(prev)
      onOutfitChange(next)
      return next
    })
  }, [onOutfitChange])

  const update = useCallback((updater:(s:Skin)=>Skin) => {
    setSkin(prev => {
      const next = updater(prev)
      onAppearanceChange(next, gender)
      return next
    })
  }, [onAppearanceChange, gender])

  useEffect(() => { onAppearanceChange(skin, gender) }, []) // eslint-disable-line

  const [camPreset, setCamPresetLocal] = useState<'full'|'face'|'torso'|'legs'|'feet'>('full')

  const changeCam = useCallback((preset: 'full'|'face'|'torso'|'legs'|'feet') => {
    setCamPresetLocal(preset)
    nuiPost('setCamPreset', { preset })
  }, [])

  // Remet la cam entière à chaque changement d'onglet
  useEffect(() => {
    changeCam('full')
  }, [tab])

  // Rotation du ped à la souris
  const isDragging = useRef(false)
  const lastDragX  = useRef(0)

  const handleDragDown = useCallback((e: React.MouseEvent) => {
    isDragging.current = true
    lastDragX.current  = e.clientX
  }, [])

  const handleDragMove = useCallback((e: React.MouseEvent) => {
    if (!isDragging.current) return
    const delta = e.clientX - lastDragX.current
    lastDragX.current = e.clientX
    if (delta !== 0) nuiPost('rotatePreview', { delta })
  }, [])

  const handleDragEnd = useCallback(() => { isDragging.current = false }, [])

  const handleGender = (g: 0|1) => {
    setGender(g)
    onGenderChange(g, slot)
  }

  const handleConfirm = () => {
    const f = fn.trim(), l = ln.trim()
    if (f.length < 2) { setErr('Prénom invalide (min. 2 caractères)'); setTab('identite'); return }
    if (l.length < 2) { setErr('Nom invalide (min. 2 caractères)');    setTab('identite'); return }
    if (!dob)         { setErr('Date de naissance requise');            setTab('identite'); return }
    setErr('')
    onConfirm(f, l, dob, gender, skin, outfit, spawnZone)
  }

  const tabIdx = TABS.findIndex(t => t.id === tab)
  const isLast = tabIdx === TABS.length - 1

  const goNext = () => {
    if (appItem) { setAppItem(null); return }
    if (isLast) { handleConfirm(); return }
    setTab(TABS[tabIdx + 1].id)
  }
  const goPrev = () => {
    if (appItem) { setAppItem(null); return }
    if (tabIdx === 0) { onBack(); return }
    setTab(TABS[tabIdx - 1].id)
  }



  const renderContent = () => {
    if (tab === 'identite') return (
      <div className={s.form}>
        <div className={s.field}>
          <div className={s.label}>Prénom</div>
          <input className={s.input} type="text" placeholder="John" maxLength={32} value={fn} onChange={e => setFn(e.target.value)} />
        </div>
        <div className={s.field}>
          <div className={s.label}>Nom de famille</div>
          <input className={s.input} type="text" placeholder="Doe" maxLength={32} value={ln} onChange={e => setLn(e.target.value)} />
        </div>
        <div className={s.field}>
          <div className={s.label}>Date de naissance</div>
          <input className={s.input} type="date" min="1940-01-01" max="2005-12-31" value={dob} onChange={e => setDob(e.target.value)} />
        </div>
        <div className={s.field}>
          <div className={s.label}>Genre</div>
          <div className={s.genderRow}>
            <button className={cx(s.genderBtn, gender===0 && s.active)} onClick={() => handleGender(0)}>Homme</button>
            <button className={cx(s.genderBtn, gender===1 && s.active)} onClick={() => handleGender(1)}>Femme</button>
          </div>
        </div>
        {err && <div className={s.error}>{err}</div>}
      </div>
    )

    if (tab === 'heritage') return (
      <div className={s.detail}>
        {/* Big accent preview — father behind, mother in front */}
        <div className={s.heritagePreview}>
          {(() => {
            const dadPortrait = parentPortraitUrl(skin.headBlend.shapeFirst)
            const mumPortrait = parentPortraitUrl(skin.headBlend.shapeSecond)
            return <>
              {dadPortrait
                ? <img src={dadPortrait} className={s.heritageImgDad} />
                : <div className={s.heritageImgDad} />}
              {mumPortrait
                ? <img src={mumPortrait} className={s.heritageImgMum} />
                : <div className={s.heritageImgMum} />}
            </>
          })()}
        </div>
        <div className={s.section}>Parent 1</div>
        <ParentCarousel value={skin.headBlend.shapeFirst} list={FATHERS}
          onChange={v => update(sk => ({ ...sk, headBlend: { ...sk.headBlend, shapeFirst:v, skinFirst:v } }))} />
        <div className={s.section}>Parent 2</div>
        <ParentCarousel value={skin.headBlend.shapeSecond} list={MOTHERS}
          onChange={v => update(sk => ({ ...sk, headBlend: { ...sk.headBlend, shapeSecond:v, skinSecond:v } }))} />
        <Slider label="Ressemblance" value={Math.round(skin.headBlend.shapeMix*100)} displayFn={v=>(v/100).toFixed(2)}
          onChange={v=>update(sk=>({...sk,headBlend:{...sk.headBlend,shapeMix:v/100}}))} />
        <Slider label="Peau" value={Math.round(skin.headBlend.skinMix*100)} displayFn={v=>(v/100).toFixed(2)}
          onChange={v=>update(sk=>({...sk,headBlend:{...sk.headBlend,skinMix:v/100}}))} />
      </div>
    )

    if (tab === 'traits') return (
      <TraitsTab skin={skin} update={update} />
    )

    if (tab === 'apparence') return (
      <AppearanceTab skin={skin} update={update} gender={gender} />
    )

    if (tab === 'tenue') return (
      <TenueTab outfit={outfit} setOutfit={setOutfit} />
    )

    if (tab === 'spawn') return (
      <div className={s.detail}>
        {SPAWN_ZONES.map(z => (
          <button key={z.id} className={cx(s.spawnBtn, spawnZone === z.id && s.spawnBtnActive)}
            style={{ backgroundImage: `url(${z.img})` }}
            onClick={() => setSpawnZone(z.id)}>
            <span className={s.spawnLabel}>{z.label}</span>
            <span className={s.spawnDesc}>{z.desc}</span>
          </button>
        ))}
      </div>
    )
  }

  const currentTitle = appItem ? APP_LABEL[appItem] : TABS.find(t=>t.id===tab)!.title

  return (
    <div className={shared.screen} onMouseMove={handleDragMove} onMouseUp={handleDragEnd} onMouseLeave={handleDragEnd}>
      <div className={cx(shared.panel, shared.wide, shared.solid)}>

        {/* Bannière */}
        <div className={s.banner}>
          <div className={s.bannerBg} style={{ backgroundImage: `url(${imgBanner})` }} />
        </div>

        {/* Onglets */}
        <div className={s.tabs}>
          {TABS.map(t => (
            <button key={t.id} className={cx(s.tab, tab===t.id && s.active)}
              onClick={() => { setAppItem(null); setTab(t.id) }}>
              <t.Icon />
            </button>
          ))}
          {EXTRA_ICONS.map((Icon, i) => (
            <button key={i} className={cx(s.tab, s.disabled)}>
              <Icon />
            </button>
          ))}
        </div>

        {/* Titre */}
        <div style={{ padding:'16px 20px 10px', flexShrink:0 }}>
          <div className={s.screenTitle} style={{ padding:0, margin:0 }}>{currentTitle.toUpperCase()}</div>
        </div>

        {/* Contenu */}
        <div className={s.content}>
          {renderContent()}
        </div>

        {/* Footer */}
        <div className={shared.footer} style={{ display:'flex', alignItems:'center', justifyContent:'space-between' }}>
          <button className={shared.btnBack} onClick={goPrev} style={{ padding:'1.0vh 1.7vw', fontSize:'0.8vw', boxSizing:'border-box' }}>
            Retour
          </button>
          <button className={cx(shared.btn, shared.btnPrimary)} onClick={goNext} style={{ width:'auto', padding:'1.0vh 1.7vw', fontSize:'0.8vw', boxSizing:'border-box' }}>
            {isLast && !appItem ? 'Créer le personnage' : 'Suivant'}
          </button>
        </div>
      </div>
      {/* Zone de rotation souris + boutons caméra */}
      <div className={s.dragZone} onMouseDown={handleDragDown}>
        <div className={s.camBtns}>
          {CAM_BTN_LIST.map(({ id, icon }) => (
            <button
              key={id}
              className={cx(s.camBtn, camPreset === id && s.camBtnActive)}
              onMouseDown={e => e.stopPropagation()}
              onClick={() => changeCam(id)}
            >
              {icon}
            </button>
          ))}
        </div>
      </div>
    </div>
  )
}
