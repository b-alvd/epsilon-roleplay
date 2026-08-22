import { useState, useCallback } from 'react'
import { nuiPost } from '../../hooks/useNUI'
import type { CharacterListData } from './types'
import SelectScreen from './screens/SelectScreen'
import CreatorScreen from './screens/CreatorScreen'

type Screen = 'select' | 'create'

interface Props {
  data: CharacterListData
}

export default function CharacterSelect({ data }: Props) {
  const [screen, setScreen] = useState<Screen>('select')
  const [createSlot, setCreateSlot] = useState(1)
  const [gender, setGender] = useState<0 | 1>(0)

  const openCreate = useCallback((slot: number) => {
    setCreateSlot(slot)
    setGender(0)
    nuiPost('selectPreview', { slot, gender: 0, skin: null })
    setScreen('create')
  }, [])

  const handleGenderChange = useCallback((g: 0|1, slot: number) => {
    setGender(g)
    nuiPost('selectPreview', { slot, gender: g, skin: null })
  }, [])

  const handleAppearanceChange = useCallback((skin: unknown, g: 0|1) => {
    nuiPost('updateAppearance', { appearance: skin, gender: g })
  }, [])

  const handleOutfitChange = useCallback((outfit: unknown) => {
    nuiPost('updateOutfit', { outfit })
  }, [])

  const handleConfirm = useCallback((firstname: string, lastname: string, dob: string, g: 0|1, skin: unknown, outfit: unknown, spawnZone: string) => {
    nuiPost('createCharacter', { slot: createSlot, firstname, lastname, dob, gender: g, skin, outfit, spawnZone })
  }, [createSlot])

  if (screen === 'select') {
    return (
      <SelectScreen
        data={data}
        onPlay={id => nuiPost('selectCharacter', { id })}
        onPreview={(slot, char) => nuiPost('selectPreview', { slot, gender: char?.gender ?? 0, skin: char?.skin ? JSON.parse(char.skin) : null, outfit: char?.outfit ? JSON.parse(char.outfit) : null })}
        onCreate={openCreate}
      />
    )
  }

  return (
    <CreatorScreen
      slot={createSlot}
      gender={gender}
      onBack={() => {
        setScreen('select')
        const first = data.characters[0]
        if (first) nuiPost('selectPreview', { slot: first.slot, gender: first.gender ?? 0, skin: first.skin ? JSON.parse(first.skin) : null, outfit: first.outfit ? JSON.parse(first.outfit) : null })
        else nuiPost('clearPreview', {})
      }}
      onGenderChange={handleGenderChange}
      onAppearanceChange={handleAppearanceChange}
      onOutfitChange={handleOutfitChange}
      onConfirm={handleConfirm}
    />
  )
}
