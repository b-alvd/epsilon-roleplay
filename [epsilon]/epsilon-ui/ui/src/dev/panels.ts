export interface DevPanel {
  id: string
  label: string
  icon: string
  mockData?: unknown
  /** Dispatche un message NUI au lieu d'ouvrir un panel */
  nuiMessage?: { action: string; data: unknown }
  /** Message NUI envoyé pour fermer/désactiver l'overlay */
  nuiClose?: { action: string; data: unknown }
}

export const DEV_PANELS: DevPanel[] = [
  {
    id: 'characters',
    label: 'Personnages',
    icon: '👤',
    mockData: {
      maxSlots: 3,
      playerUid: 42,
      characters: [
        { id: 1, slot: 1, firstname: 'John',  lastname: 'Doe',    gender: 0, dob: '1990-05-12', skin: null },
        { id: 2, slot: 2, firstname: 'Sarah', lastname: 'Conner', gender: 1, dob: '1985-03-28', skin: null },
      ],
    },
  },
  {
    id: 'pausemenu',
    label: 'Pause Menu',
    icon: '⏸️',
    mockData: {
      playerName: 'John Doe',
      serverId: 42,
      citizenId: 'VRP-1042',
      job: 'Mécanicien',
      health: 85,
      armor: 40,
      discord: 'discord.gg/visionrp',
    },
  },
  {
    id: 'admin',
    label: 'Admin',
    icon: '🛡️',
    mockData: {
      rank: 'Fondateur',
      weather: 'CLEAR', nextWeather: 'RAIN',
      hour: 14, minute: 30,
      freezeTime: false, freezeWeather: false,
      grade: {
        id: 4, name: 'fondateur', label: 'Fondateur', color: '#9333ea',
        perms: {
          perm_players: true, perm_teleport: true, perm_spectate: true,
          perm_health: true, perm_effects: true, perm_vehicle: true,
          perm_sanctions: true, perm_message: true, perm_weather: true,
          perm_announce: true, perm_tools: true, perm_grades: true,
        },
      },
    },
  },
  {
    id: 'inventory',
    label: 'Inventaire',
    icon: '🎒',
    mockData: {
      playerName: 'Sana Deeve',
      hunger: 46,
      thirst: 100,
      stamina: 100,
      cash: 12500,
      weight: 3.2,
      maxWeight: 30,
      hotbar: [
        { slot: 1, name: 'weapon_pistol', label: 'Pistolet', image: 'nui://epsilon-inventory/images/weapon_pistol.png' },
        null, null, null, null,
      ],
      // Format serveur : tableaux séparés par catégorie
      items: [
        { id: 1,  name: 'argent',      label: 'Argent',          quantity: 1000, slot: 1, category: 'items', weight: 0,   idata: { type: 'money'   }, data: {}, image: 'nui://epsilon-inventory/images/argent.png' },
        { id: 2,  name: 'argent_sale', label: 'Argent sale',     quantity: 500,  slot: 2, category: 'items', weight: 0,   idata: { type: 'money'   }, data: {}, image: 'nui://epsilon-inventory/images/argent_sale.png' },
        { id: 3,  name: 'pain',        label: 'Pain',            quantity: 3,    slot: 3, category: 'items', weight: 0.3, idata: { type: 'food'    }, data: {}, image: '' },
        { id: 4,  name: 'bouteille',   label: "Bouteille d'eau", quantity: 2,    slot: 4, category: 'items', weight: 0.5, idata: { type: 'drink'   }, data: {}, image: '' },
        { id: 5,  name: 'bandage',     label: 'Bandage',         quantity: 5,    slot: 5, category: 'items', weight: 0.1, idata: { type: 'medical' }, data: {}, image: '' },
      ],
      keys: [
        { id: 6, name: 'cle_voiture', label: 'Clé Voiture', quantity: 1, slot: 1, category: 'keys', weight: 0.05, idata: { type: 'key' }, data: {}, image: '' },
      ],
      weapons: [
        { id: 20, name: 'weapon_pistol', label: 'Pistolet', quantity: 1, slot: 1, category: 'weapons', weight: 0.8, idata: { type: 'weapon', weapon: 'weapon_pistol', maxAmmo: 17, ammoType: 'munitions_pistol' }, data: { loadedAmmo: 12 }, image: 'nui://epsilon-inventory/images/weapon_pistol.png' },
        { id: 21, name: 'weapon_knife',  label: 'Couteau',  quantity: 1, slot: 2, category: 'weapons', weight: 0.3, idata: { type: 'weapon', weapon: 'weapon_knife',  maxAmmo: 0,  ammoType: null              }, data: { loadedAmmo: 0  }, image: 'nui://epsilon-inventory/images/weapon_knife.png' },
      ],
      clothing: [],
      atmNearby: true,
    },
  },
  {
    id: 'atm',
    label: 'ATM PIN',
    icon: '🏧',
    mockData: {
      itemId: 1,
      needSetup: false,
      mode: 'atm',
      account: { id: 1, balance: 42000, savings: 0 },
      cash: 500,
      character: { firstname: 'John', lastname: 'Doe' },
      transactions: [],
      weekly: [],
    },
  },
  {
    id: 'bank',
    label: 'Banque',
    icon: '🏦',
    mockData: {
      mode: 'bank',
      account: { id: 1, balance: 142000, savings: 0 },
      cash: 3500,
      character: { firstname: 'John', lastname: 'Doe' },
      transactions: [
        { id: 1, type: 'deposit',     amount: 5000, label: 'Dépôt liquide',    created_at: '2026-07-22T10:00:00Z' },
        { id: 2, type: 'withdraw',    amount: 1200, label: 'Retrait espèces',  created_at: '2026-07-21T15:30:00Z' },
        { id: 3, type: 'transfer_in', amount: 3000, label: 'Virement reçu',    created_at: '2026-07-20T09:00:00Z' },
        { id: 4, type: 'transfer_out',amount: 500,  label: 'Loyer appartement',created_at: '2026-07-19T12:00:00Z' },
      ],
      card: {
        tier: 'gold', label: 'Carte Gold', color: '#f59e0b',
        expires: '2026-08-22', hasPin: true,
        maxWithdraw: 3000, dailyLimit: 8000, dailyUsed: 1500,
      },
      cardTiers: [
        { id: 'classique', label: 'Carte Classique', color: '#94a3b8', price: 500,  monthly: 100,  maxWithdraw: 500,   dailyLimit: 1500,  description: 'Accès basique aux distributeurs.' },
        { id: 'gold',      label: 'Carte Gold',      color: '#f59e0b', price: 2000, monthly: 400,  maxWithdraw: 3000,  dailyLimit: 8000,  description: 'Plafonds élevés pour usage courant.' },
        { id: 'platinum',  label: 'Carte Platinum',  color: '#a78bfa', price: 5000, monthly: 1200, maxWithdraw: 10000, dailyLimit: 30000, description: 'Accès illimité, plafonds premium.' },
      ],
      weekly: [
        { day: 'Lun', deposits: 5000,  withdrawals: 1200 },
        { day: 'Mar', deposits: 3000,  withdrawals: 500  },
        { day: 'Mer', deposits: 0,     withdrawals: 2000 },
        { day: 'Jeu', deposits: 8000,  withdrawals: 300  },
        { day: 'Ven', deposits: 1500,  withdrawals: 4000 },
        { day: 'Sam', deposits: 2000,  withdrawals: 0    },
        { day: 'Dim', deposits: 0,     withdrawals: 600  },
      ],
    },
  },

  // ── Documents ─────────────────────────────────────────────────
  {
    id: 'document',
    label: 'Document',
    icon: '📄',
    mockData: {
      id: 1,
      template: 'contract',
      title: 'Contrat de travail — Police',
      data: {
        job_label: 'Police de Los Santos',
        type: 'CDI',
        salary: 3200,
        start_date: '2026-07-27',
        end_date: null,
        employer_id: 5,
        employee_id: 12,
      },
      created_by: 5,
      created_at: '2026-07-27T14:00:00Z',
      signers: [5],
      myCharId: 12,
      hasPen: true,
      myRole: 'employee',
    },
  },

  // ── Storage ───────────────────────────────────────────────────
  {
    id: 'storage',
    label: 'Coffre',
    icon: '🗄️',
    mockData: {
      storage: { id: 1, name: 'police_locker_h', label: 'Vestiaire H', type: 'locker', slots: 16 },
      contents: [
        { id: 1, slot: 1, name: 'bandage', quantity: 5, data: {}, label: 'Bandage', image: '', weight: 0.1 },
        { id: 2, slot: 3, name: 'pain',    quantity: 2, data: {}, label: 'Pain',    image: '', weight: 0.3 },
        { id: 3, slot: 7, name: 'pen',     quantity: 1, data: {}, label: 'Stylo',   image: '', weight: 0.05 },
      ],
      playerItems: [
        { id: 10, slot: 1, name: 'argent', quantity: 500, data: {}, label: 'Argent', image: '', weight: 0 },
        { id: 11, slot: 2, name: 'bouteille', quantity: 1, data: {}, label: "Bouteille d'eau", image: '', weight: 0.5 },
      ],
    },
  },

  // ── Jobs RH ───────────────────────────────────────────────────
  {
    id: 'jobshr',
    label: 'Jobs RH',
    icon: '💼',
    mockData: {
      jobName: 'police',
      jobLabel: 'Police de Los Santos',
      myCharId: 5,
      myGrade: 4,
      employees: [
        {
          charId: 12,
          firstname: 'Marc',
          lastname: 'Durant',
          grade: 1,
          gradeLabel: 'Officier',
          position: 'Patrouilleur',
          contractId: 3,
          contractType: 'CDI',
          salary: 2800,
          contractStatus: 'active',
          startDate: '2026-06-01',
          endDate: null,
          noticeEnd: null,
          pendingAmendment: null,
          hoursThisMonth: 420,
        },
        {
          charId: 14,
          firstname: 'Lena',
          lastname: 'Rousseau',
          grade: 0,
          gradeLabel: 'Recrue',
          position: null,
          contractId: 4,
          contractType: 'CDD',
          salary: 2000,
          contractStatus: 'pending',
          startDate: '2026-07-20',
          endDate: '2026-10-20',
          noticeEnd: null,
          pendingAmendment: { id: 1, new_salary: 2400, reason: 'Promotion période essai' },
          hoursThisMonth: 180,
        },
      ],
      grades: [
        { grade: 0, label: 'Recrue',     salary: 2000 },
        { grade: 1, label: 'Officier',   salary: 2800 },
        { grade: 2, label: 'Sergent',    salary: 3500 },
        { grade: 3, label: 'Lieutenant', salary: 4200 },
        { grade: 4, label: 'Capitaine',  salary: 5500 },
      ],
    },
  },

  // ── Overlays ──────────────────────────────────────────────────

  {
    id: 'interim-select',
    label: 'Interim Select',
    icon: '🗂️',
    nuiMessage: {
      action: 'epsilon:interim:openSelect',
      data: {
        mission: 'eboueur',
        label: 'Eboueur',
        color: 'rgb(132,204,22)',
        quartiers: [
          { name: 'rockford_hills', label: 'Rockford Hills', spotCount: 44 },
          { name: 'vespucci',       label: 'Vespucci',       spotCount: 40 },
          { name: 'mirror_park',    label: 'Mirror Park',    spotCount: 40 },
          { name: 'pillbox',        label: 'Pillbox Hill',   spotCount: 25 },
        ],
        stopOptions:   [],
        timePerStop:   2.0,
        payMinPerStop: 5,
        payMaxPerStop: 10,
      },
    },
  },

  {
    id: 'interim-hud',
    label: 'Interim HUD',
    icon: '🚛',
    nuiMessage: {
      action: 'epsilon:interim:hud',
      data: { visible: true, mission: 'eboueur', step: 4, total: 10, label: 'Ramasser la poubelle', earned: 120, color: 'rgb(132,204,22)' },
    },
    nuiClose: {
      action: 'epsilon:interim:hud',
      data: { visible: false, mission: '', step: 0, total: 0, label: '', earned: 0, color: '' },
    },
  },

  {
    id: 'noclip-hud',
    label: 'NoClip HUD',
    icon: '🚀',
    nuiMessage: {
      action: 'epsilon:admin:noclipHUD',
      data: { active: true, speedIdx: 3 },
    },
    nuiClose: {
      action: 'epsilon:admin:noclipHUD',
      data: { active: false },
    },
  },

  {
    id: 'announce',
    label: 'Annonce',
    icon: '📢',
    nuiMessage: {
      action: 'epsilon:admin:announce',
      data: { admin: 'AdminTest', message: 'Ceci est un message de test depuis le panel admin.', duration: 10 },
    },
    nuiClose: { action: 'epsilon:admin:announceClose', data: {} },
  },

  {
    id: 'spectate',
    label: 'Spectate',
    icon: '👁️',
    nuiMessage: {
      action: 'epsilon:admin:spectateState',
      data: { state: true, target: 'John Doe', serverId: 42 },
    },
    nuiClose: {
      action: 'epsilon:admin:spectateState',
      data: { state: false },
    },
  },

  {
    id: 'report-hud',
    label: 'Report HUD',
    icon: '🆘',
    nuiMessage: {
      action: 'epsilon:report:status',
      data: { id: 12, status: 'in_progress', created_at: new Date(Date.now() - 4 * 60 * 1000).toISOString(), assigned_name: 'AdminTest' },
    },
    nuiClose: { action: 'epsilon:report:clear', data: {} },
  },

  {
    id: 'emote-menu',
    label: 'Emotes',
    icon: '💃',
    nuiMessage: {
      action: 'epsilon:emotes:open',
      data: {
        categories: [
          {
            id: 'gestes', label: 'Gestes', icon: 'bi-hand-index-thumb',
            emotes: [
              { key: 'checkwatch', label: 'Regarder sa montre',  icon: 'bi-watch' },
              { key: 'cheer',      label: 'Célébrer',            icon: 'bi-trophy' },
              { key: 'respect',    label: 'Respect',             icon: 'bi-person-check' },
              { key: 'bang',       label: 'Bang Bang',           icon: 'bi-hand-index' },
              { key: 'cleanhands', label: 'Se laver les mains',  icon: 'bi-droplet' },
              { key: 'block',      label: 'Protéger son visage', icon: 'bi-shield' },
              { key: 'snot',       label: "S'essuyer les yeux",  icon: 'bi-emoji-expressionless' },
              { key: 'hhands',     label: 'Cœur avec les mains', icon: 'bi-heart' },
            ],
          },
          {
            id: 'danses', label: 'Danses', icon: 'bi-music-note-beamed',
            emotes: [
              { key: 'dance',  label: 'Dance 1',    icon: 'bi-music-note-beamed' },
              { key: 'dance2', label: 'Dance 2',    icon: 'bi-music-note-beamed' },
              { key: 'dance3', label: 'Dance 3',    icon: 'bi-music-note-beamed' },
              { key: 'dance4', label: 'Dance 4',    icon: 'bi-music-note-beamed' },
              { key: 'dance5', label: 'Dance 5 (F)',icon: 'bi-music-note-beamed' },
              { key: 'dance6', label: 'Dance 6',    icon: 'bi-music-note-beamed' },
              { key: 'dance8', label: 'Dance 8',    icon: 'bi-music-note-beamed' },
              { key: 'dance9', label: 'Dance 9 (F)',icon: 'bi-music-note-beamed' },
            ],
          },
          {
            id: 'social', label: 'Social', icon: 'bi-people',
            emotes: [
              { key: 'handshake', label: 'Poignée de main', icon: 'bi-people' },
              { key: 'hug',       label: 'Câlin',           icon: 'bi-heart' },
              { key: 'bro',       label: 'Bro',             icon: 'bi-people-fill' },
              { key: 'carry',     label: 'Porter',          icon: 'bi-person-arms-up' },
              { key: 'carry3',    label: 'Porter (boîte)',  icon: 'bi-box' },
            ],
          },
          {
            id: 'props', label: 'Props', icon: 'bi-box',
            emotes: [
              { key: 'umbrella', label: 'Parapluie', icon: 'bi-umbrella' },
              { key: 'notepad',  label: 'Notepad',   icon: 'bi-journal-text' },
              { key: 'gift',     label: 'Cadeau',    icon: 'bi-gift' },
              { key: 'box',      label: 'Carton',    icon: 'bi-box-seam' },
            ],
          },
          {
            id: 'positions', label: 'Positions', icon: 'bi-person-arms-up',
            emotes: [
              { key: 'bumsleep',  label: 'Grosse Sieste',     icon: 'bi-moon-stars' },
              { key: 'chill',     label: 'Allongé relax',     icon: 'bi-person-laid-down' },
              { key: 'cloudgaze', label: 'Allongé dos au sol',icon: 'bi-cloud' },
              { key: 'posecutef', label: 'Cute Pose',         icon: 'bi-camera' },
            ],
          },
        ],
        numpad: [
          { key: 'dance',     label: 'Dance 1',           icon: 'bi-play-fill' },
          { key: 'checkwatch',label: 'Regarder sa montre',icon: 'bi-play-fill' },
          { key: 'respect',   label: 'Respect',           icon: 'bi-play-fill' },
          false,
          { key: 'cheer',     label: 'Célébrer',          icon: 'bi-play-fill' },
          false,
          { key: 'bumsleep',  label: 'Grosse Sieste',     icon: 'bi-play-fill' },
          { key: 'umbrella',  label: 'Parapluie',         icon: 'bi-play-fill' },
          false,
          { key: 'bang',      label: 'Bang Bang',         icon: 'bi-play-fill' },
        ],
      },
    },
    nuiClose: { action: 'epsilon:emotes:close', data: {} },
  },

  {
    id: 'ammo-hud',
    label: 'Munitions',
    icon: '🔫',
    nuiMessage: {
      action: 'epsilon:inventory:ammo',
      data: { clip: 11, max: 17 },
    },
    nuiClose: { action: 'epsilon:inventory:ammo', data: null },
  },

  {
    id: 'notify',
    label: 'Notif',
    icon: '🔔',
    nuiMessage: {
      action: 'epsilon:notify',
      data: { text: 'Notification de test', duration: 5 },
    },
  },

  {
    id: 'notify-icon',
    label: 'Notif Icon',
    icon: '🔔',
    nuiMessage: {
      action: 'epsilon:notify',
      data: { text: 'Action effectuée', type: 'success', icon: 'bi-check-circle-fill', duration: 5 },
    },
  },

  {
    id: 'notify-advanced',
    label: 'Notif Avancée',
    icon: '🔔+',
    nuiMessage: {
      action: 'epsilon:notifyAdvanced',
      data: { title: 'Salaire reçu', subtitle: 'Mission Eboueur', text: 'Vous avez gagné 340 $', image: 'argent', duration: 8 },
    },
  },

  {
    id: 'notify-weazel',
    label: 'Notif Weazel',
    icon: '📺',
    nuiMessage: {
      action: 'epsilon:notifyWeazel',
      data: {
        banner:  'nui://epsilon-ui/images_notifs/weazel_banner.png',
        affiche: 'nui://epsilon-ui/images_notifs/weazel_affiche.png',
        text: 'IS THIS WEAZEL NOTIFICATION',
        duration: 10,
      },
    },
  },

  {
    id: 'progress-bar',
    label: 'Progress Bar',
    icon: '⏳',
    nuiMessage: {
      action: 'epsilon:progressBar',
      data: { text: 'Chargement en cours...', duration: 5 },
    },
    nuiClose: { action: 'epsilon:progressBarHide', data: {} },
  },

  {
    id: 'keyboard-input',
    label: 'Keyboard Input',
    icon: '⌨️',
    nuiMessage: {
      action: 'epsilon:keyboardInput',
      data: { title: 'Raison', placeholder: 'Entrez une raison...', icon: 'bi-pencil' },
    },
  },

  {
    id: 'choice-input',
    label: 'Choice Input',
    icon: '🔘',
    nuiMessage: {
      action: 'epsilon:choiceInput',
      data: {
        title: 'Que souhaitez-vous faire ?',
        icon: 'bi-question-circle',
        options: [
          { label: 'Option A', value: 'a' },
          { label: 'Option B', value: 'b' },
          { label: 'Option C', value: 'c' },
        ],
      },
    },
  },

  {
    id: 'help-notif',
    label: 'Help Notif',
    icon: '💡',
    nuiMessage: {
      action: 'epsilon:helpNotif',
      data: { text: 'Appuyez sur [E] pour interagir.' },
    },
    nuiClose: { action: 'epsilon:helpNotifHide', data: {} },
  },

  {
    id: 'instructional',
    label: 'Instructional',
    icon: '🎮',
    nuiMessage: {
      action: 'epsilon:instructionalButtons',
      data: { show: true, buttons: [
        { key: 'E', action: 'Interagir' },
        { key: 'F', action: 'Annuler' },
      ]},
    },
    nuiClose: { action: 'epsilon:instructionalButtons', data: { show: false } },
  },
]
