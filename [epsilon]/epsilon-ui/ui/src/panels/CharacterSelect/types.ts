export interface Character {
  id: number
  slot: number
  firstname: string
  lastname: string
  gender: 0 | 1
  dob: string
  skin: string | null
  outfit: string | null
}

export interface CharacterListData {
  maxSlots: number
  characters: Character[]
  playerUid: number
}
