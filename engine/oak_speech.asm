SetDefaultNames:
	ld a, [wLetterPrintingDelayFlags]
	push af
	ld a, [wOptions]
	push af
	ld a, [wd732]
	push af
	ld a, [wCurPalette]
	push af
	ld hl, wPlayerName
	ld bc, wBoxDataEnd - wPlayerName
	xor a
	call FillMemory
	ld hl, wSpriteStateData1
	ld bc, wOAMBuffer - wSpriteStateData1
	xor a
	call FillMemory
	pop af
	ld [wCurPalette], a
	dec a
	ld [wLastPalette], a ; force reload just in case vblank/hblank happened
	pop af
	ld [wd732], a
	pop af
	ld [wOptions], a
	pop af
	ld [wLetterPrintingDelayFlags], a
	ld a, [wOptionsInitialized]
	and a
	jp z, InitOptions
	ret

OakSpeech:
	ld a, $FF
	call PlaySound ; stop music
	ld a, BANK(Music_Routes2)
	ld c, a
	ld a, MUSIC_ROUTES2
	call PlayMusic
	call ClearScreen
	call LoadTextBoxTilePatterns
	call SetDefaultNames
	predef InitPlayerData2
	callab IntroPermaOptions
	ldafarbyte KeyItemRandoActive
	and a
	call nz, HideShowObjectsKeyItemRando
	call ClearScreen
	call OakSpeechBoxItems
	ld a, [wDefaultMap]
	ld [wDestinationMap], a
	call SpecialWarpIn
	xor a
	ld [hTilesetType], a
	ld a, [wd732]
	bit 1, a ; possibly a debug mode bit
	jp nz, OakSpeechSkipChoosingNames
	ld de, ProfOakPic
	lb bc, Bank(ProfOakPic), $00
	call IntroDisplayPicCenteredOrUpperRight
	call FadeInIntroPic
	ld hl, OakSpeechText1
	call PrintText
	call GBFadeOutToWhite
	call ClearScreen
OakSpeechIntroPokemon::
	ld a, NIDORINO
	ld [wd0b5], a
	ld [wcf91], a
	call GetMonHeader
	coord hl, 6, 4
	call LoadFlippedFrontSpriteByMonIndex
	call MovePicLeft
	ld hl, OakSpeechText2
	call PrintText
	call GBFadeOutToWhite
	call ClearScreen
	ld de, RedPicFront
	lb bc, Bank(RedPicFront), $00
	call IntroDisplayPicCenteredOrUpperRight
	call MovePicLeft
	ld hl, IntroducePlayerText
	call PrintText
	;call ChoosePlayerName
	call GBFadeOutToWhite
	call ClearScreen
	ld de, Rival1Pic
	lb bc, Bank(Rival1Pic), $00
	call IntroDisplayPicCenteredOrUpperRight
	call FadeInIntroPic
	ld hl, IntroduceRivalText
	call PrintText
	;call ChooseRivalName
OakSpeechSkipChoosingNames:
	call GBFadeOutToWhite
	call ClearScreen
	ld de, RedPicFront
	lb bc, Bank(RedPicFront), $00
	call IntroDisplayPicCenteredOrUpperRight
	call GBFadeInFromWhite
	ld a, [wd72d]
	and a
	jr nz, .next
	ld hl, OakSpeechText3
	call PrintText
.next
	ld a, [H_LOADEDROMBANK]
	push af
	ld a, SFX_SHRINK
	call PlaySound
	pop af
	ld [H_LOADEDROMBANK], a
	ld [MBC1RomBank], a
	ld c, 4
	call DelayFrames
	ld de, RedSprite
	ld hl, vSprites
	lb bc, BANK(RedSprite), $0C
	call CopyVideoData
	ld de, ShrinkPic1
	lb bc, BANK(ShrinkPic1), $00
	call IntroDisplayPicCenteredOrUpperRight
	ld c, 4
	call DelayFrames
	ld de, ShrinkPic2
	lb bc, BANK(ShrinkPic2), $00
	call IntroDisplayPicCenteredOrUpperRight
	call ResetPlayerSpriteData
	ld a, [H_LOADEDROMBANK]
	push af
	ld a, BANK(Music_PalletTown)
	ld [wAudioROMBank], a
	ld [wAudioSavedROMBank], a
	ld a, 10
	ld [wAudioFadeOutControl], a
	ld a, $FF
	ld [wNewSoundID], a
	call PlaySound ; stop music
	pop af
	ld [H_LOADEDROMBANK], a
	ld [MBC1RomBank], a
	ld c, 20
	call DelayFrames
	coord hl, 6, 5
	ld b, 7
	ld c, 7
	call ClearScreenArea
	call LoadTextBoxTilePatterns
	ld a, 1
	ld [wUpdateSpritesEnabled], a
	ld c, 50
	call DelayFrames
	call GBFadeOutToWhite
	jp ClearScreen
OakSpeechText1:
	TX_FAR _OakSpeechText1
	db "@"
OakSpeechText2:
	TX_FAR _OakSpeechText2A
	TX_CRY_NIDORINA
	TX_FAR _OakSpeechText2B
	db "@"
IntroducePlayerText:
	TX_FAR _IntroducePlayerText
	db "@"
IntroduceRivalText:
	TX_FAR _IntroduceRivalText
	db "@"
OakSpeechText3:
	TX_FAR _OakSpeechText3
	db "@"

FadeInIntroPic:
	ld hl, IntroFadePalettes
	ld b, 6
.next
	ld a, [hli]
	ld [rBGP], a
	ld c, 10
	call DelayFrames
	dec b
	jr nz, .next
	ret

IntroFadePalettes:
	db %01010100
	db %10101000
	db %11111100
	db %11111000
	db %11110100
	db %11100100

MovePicLeft:
	ld a, 119
	ld [rWX], a
	call DelayFrame

	ld a, %11100100
	ld [rBGP], a
.next
	call DelayFrame
	ld a, [rWX]
	sub 8
	cp $FF
	ret z
	ld [rWX], a
	jr .next

DisplayPicCenteredOrUpperRight:
	call GetPredefRegisters
IntroDisplayPicCenteredOrUpperRight:
; b = bank
; de = address of compressed pic
; c: 0 = centred, non-zero = upper-right
	push bc
	ld a, b
	call UncompressSpriteFromDE
	ld hl, sSpriteBuffer1
	ld de, sSpriteBuffer0
	ld bc, $310
	call CopyData
	ld de, vFrontPic
	call InterlaceMergeSpriteBuffers
	pop bc
	ld a, c
	and a
	coord hl, 15, 1
	jr nz, .next
	coord hl, 6, 4
.next
	xor a
	ld [hStartTileID], a
	predef_jump CopyUncompressedPicToTilemap
	
HideShowObjectsKeyItemRando:
; silph is open immediately
	ld a, HS_SAFFRON_CITY_E
	ld [wMissableObjectIndex], a
	predef HideObject
	ld a, HS_SAFFRON_CITY_F
	ld [wMissableObjectIndex], a
	predef ShowObject
; cerulean guard house is open immediately
	ld a, HS_CERULEAN_GUARD_1
	ld [wMissableObjectIndex], a
	predef ShowObject
	ld a, HS_CERULEAN_GUARD_2
	ld [wMissableObjectIndex], a
	predef_jump HideObject
	
OakSpeechBoxItems::
	ld a, POTION
	ld hl, wNumBoxItems
	call .giveItem
; also give a pokedex if not normal startin
	ld a, [wPermanentOptions3]
	and STARTIN_MASK
	ret z
	ld a, POKEDEX_NEW
.giveItem
	ld [wcf91], a
	ld a, 1
	ld [wItemQuantity], a
	ld [H_INGAME], a ; hijack this to write the "use artificial delays now" flag
	jp AddItemToInventory  ; give one potion
