import { useState } from 'react'
import createIcon from '../../../assets/charcreator/createIcon.svg'
import type { Character, CharacterListData } from '../types'
import { cx } from '../../../utils/cx'
import shared from '../CharacterSelect.module.css'
import s from './SelectScreen.module.css'

interface Props {
  data: CharacterListData
  onPlay: (id: number) => void
  onPreview: (slot: number, char: Character | null) => void
  onCreate: (slot: number) => void
}

export default function SelectScreen({ data, onPlay, onPreview, onCreate }: Props) {
  const first = data.characters[0] ?? null
  const [selId, setSelId] = useState<number | null>(first?.id ?? null)
  const [selSlot, setSelSlot] = useState<number | null>(first?.slot ?? null)
  const [selName, setSelName] = useState(first ? `${first.firstname} ${first.lastname}` : '')

  const slots = Array.from({ length: data.maxSlots }, (_, i) => i + 1)

  return (
    <div className={shared.screen}>
      <div className={shared.panel}>
        <div className={s.list}>
          {slots.map(slot => {
            const char = data.characters.find(c => c.slot === slot) ?? null
            const selected = selSlot === slot
            if (char) {
              return (
                <div
                  key={slot}
                  className={cx(s.card, selected && s.selected)}
                  onClick={() => {
                    setSelId(char.id)
                    setSelSlot(slot)
                    setSelName(`${char.firstname} ${char.lastname}`)
                    onPreview(slot, char)
                  }}
                >
                  <div className={s.avatar}>
                    {char.firstname[0]}{char.lastname[0]}
                  </div>
                  <div className={s.info}>
                    <div className={s.name}>{char.firstname} {char.lastname}</div>
                  </div>
                </div>
              )
            }
            return (
              <div key={slot} className={cx(s.card, s.empty)} onClick={() => onCreate(slot)}>
                <div className={s.avatar}>
                  <img src={createIcon} alt="" className={s.avatarIcon} />
                </div>
                <div className={s.info}>
                  <div className={s.name}>Nouveau personnage</div>
                </div>
              </div>
            )
          })}
        </div>
        <div className={shared.footer}>
          <button
            className={cx(shared.btn, shared.btnPrimary)}
            disabled={selId === null}
            onClick={() => selId !== null && onPlay(selId)}
          >
            Jouer
          </button>
        </div>
      </div>
      {selName
        ? (
          <div className={s.watermark}>
            {(() => {
              const [first, ...rest] = selName.split(' ')
              return <>
                <span style={{ fontWeight: 100 }}>{first}</span>
                {rest.length > 0 && <> {rest.join(' ')}</>}
              </>
            })()}
          </div>
        )
        : null
      }
      <div className={s.badge}>
        <span style={{ fontWeight: 300 }}>UID</span> <span style={{ fontWeight: 700 }}>{data.playerUid}</span>
      </div>
    </div>
  )
}
