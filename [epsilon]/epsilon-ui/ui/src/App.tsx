import { useState, useEffect, useRef, useCallback } from 'react'
import { onNUI, nuiPost, IS_FIVEM } from './hooks/useNUI'
import CharacterSelect from './panels/CharacterSelect'
import Admin from './panels/Admin'
import PauseMenu from './panels/PauseMenu'
import Bank from './panels/Bank'
import ATM from './panels/ATM'
import type { BankData } from './panels/Bank'
import type { ATMData } from './panels/ATM'
import Inventory, { HotbarOverlay } from './panels/Inventory'
import AmmoHUD from './panels/Inventory/AmmoHUD'
import { NoclipHUD, AnnounceOverlay, SpectateBar, ReportHUD } from './panels/Admin/overlays'
import { NotificationStack, ProgressBar, KeyboardInput, ChoiceInput, HelpNotification, InstructionalButtons } from './hud/notifications/Notifications'
import { InterimHUD } from './panels/Interim/InterimHUD'
import { InterimSelect } from './panels/Interim/InterimSelect'
import { EmoteMenu } from './panels/Emotes/EmoteMenu'
import DevToolbar from './dev/DevToolbar'
import type { CharacterListData } from './panels/CharacterSelect/types'
import type { AdminData } from './panels/Admin'
import type { PauseMenuData } from './panels/PauseMenu'
import type { InventoryData, HotbarSlot } from './panels/Inventory'
import devBg from './assets/dev-bg.png'

type ActivePanel =
  | { name: 'characters'; data: CharacterListData }
  | { name: 'admin'; data: AdminData }
  | { name: 'pausemenu'; data: PauseMenuData }
  | { name: 'inventory'; data: InventoryData }
  | { name: 'bank'; data: BankData }
  | { name: 'atm';  data: ATMData }
  | null

const DEV_BG: React.CSSProperties = {
  position: 'fixed',
  inset: 0,
  background: `url("${devBg}") center/cover no-repeat`,
  overflow: 'hidden',
}

export default function App() {
  const [panel, setPanel]           = useState<ActivePanel>(null)
  const [hotbar, setHotbar]         = useState<(HotbarSlot | null)[]>([])
  const [activeSlot, setActiveSlot] = useState<number | null>(null)
  const [hotbarVisible, setHotbarVisible] = useState(false)
  const hotbarTimer = useRef<ReturnType<typeof setTimeout> | null>(null)
  const panelRef    = useRef<string | null>(null)

  useEffect(() => { panelRef.current = panel?.name ?? null }, [panel])

  const showHotbarFlash = useCallback(() => {
    setHotbarVisible(true)
    if (hotbarTimer.current) clearTimeout(hotbarTimer.current)
    hotbarTimer.current = setTimeout(() => setHotbarVisible(false), 2000)
  }, [])

  useEffect(() => {
    if (IS_FIVEM) {
      const offOpen = onNUI<{ panel: string; data: unknown }>('epsilon:ui:open', ({ panel: name, data }) => {
        if (name === 'characters') setPanel({ name, data: data as CharacterListData })
        else if (name === 'admin')     setPanel({ name, data: data as AdminData })
        else if (name === 'pausemenu') setPanel({ name, data: data as PauseMenuData })
        else if (name === 'bank')      setPanel({ name, data: data as BankData })
        else if (name === 'atm')       setPanel({ name, data: data as ATMData })
        else if (name === 'inventory') {
          setPanel({ name, data: data as InventoryData })
          if (hotbarTimer.current) clearTimeout(hotbarTimer.current)
          setHotbarVisible(true)
        }
      })
      const offPinPrompt = onNUI<{ itemId: number; needSetup: boolean }>('epsilon:bank:pinPrompt', d => {
        setPanel({ name: 'atm', data: { ...d, mode: 'atm', account: { id: 0, iban: '', balance: 0, savings: 0 }, cash: 0, transactions: [], weekly: [], character: { firstname: '', lastname: '' } } })
      })
      const offClose = onNUI<void>('epsilon:ui:close', () => {
        setPanel(null)
        setHotbarVisible(false)
      })
      const offUpdate = onNUI<{ panel: string; data: unknown }>('epsilon:ui:update', ({ panel: name, data }) => {
        if (name === 'characters') setPanel(prev => prev?.name === 'characters' ? { name, data: data as CharacterListData } : prev)
      })
      const offHotbar = onNUI<(HotbarSlot | null)[]>('epsilon:inventory:hotbar', slots => {
        setHotbar(slots)
      })
      const offActiveSlot = onNUI<number | null>('epsilon:inventory:activeSlot', d => {
        setActiveSlot(d ?? null)
      })
      const offHotbarFlash = onNUI<void>('epsilon:inventory:hotbarFlash', showHotbarFlash)

      const onKeydown = (e: KeyboardEvent) => {
        if (e.key === 'Escape' && panelRef.current === 'inventory') nuiPost('inventory:close', {})
      }
      window.addEventListener('keydown', onKeydown)

      return () => { offOpen(); offClose(); offUpdate(); offHotbar(); offActiveSlot(); offHotbarFlash(); offPinPrompt(); window.removeEventListener('keydown', onKeydown) }
    }
  }, [showHotbarFlash])

  const openDevPanel = (id: string, data: unknown) => {
    if (id === 'characters') setPanel({ name: 'characters', data: data as CharacterListData })
    else if (id === 'admin')     setPanel({ name: 'admin', data: data as AdminData })
    else if (id === 'pausemenu') setPanel({ name: 'pausemenu', data: data as PauseMenuData })
    else if (id === 'inventory') setPanel({ name: 'inventory', data: data as InventoryData })
    else if (id === 'bank')      setPanel({ name: 'bank',     data: data as BankData })
    else if (id === 'atm')       setPanel({ name: 'atm',      data: data as ATMData })
  }

  const renderPanel = () => {
    if (!panel) return null
    if (panel.name === 'characters') return <CharacterSelect data={panel.data} />
    if (panel.name === 'admin')      return <Admin data={panel.data} />
    if (panel.name === 'pausemenu')  return <PauseMenu data={panel.data} onClose={() => { setPanel(null); nuiPost('pausemenu:close', {}) }} />
    if (panel.name === 'inventory')  return <Inventory data={panel.data} />
    if (panel.name === 'bank')       return <Bank data={panel.data} onClose={() => { setPanel(null); nuiPost('bank:close', {}) }} />
    if (panel.name === 'atm')        return <ATM  data={panel.data} onClose={() => { setPanel(null); nuiPost('bank:close', {}) }} />
    return null
  }

  const overlays = (
    <>
      <NoclipHUD />
      <AnnounceOverlay />
      <SpectateBar />
      <ReportHUD />
      <NotificationStack />
      <ProgressBar />
      <KeyboardInput />
      <ChoiceInput />
      <HelpNotification />
      <InstructionalButtons />
      <InterimHUD />
      <InterimSelect />
      <EmoteMenu />
      {hotbar.some(Boolean) && <HotbarOverlay hotbar={hotbar} activeSlot={activeSlot} visible={hotbarVisible && panel?.name !== 'inventory'} />}
      <AmmoHUD />
    </>
  )

  if (!IS_FIVEM) {
    return (
      <div style={DEV_BG}>
        {renderPanel()}
        {overlays}
        <DevToolbar
          activePanel={panel?.name ?? null}
          onOpen={openDevPanel}
          onClose={() => setPanel(null)}
        />
      </div>
    )
  }

  return <>{renderPanel()}{overlays}</>
}
