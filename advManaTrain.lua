UI.Label("Mana training")

if type(storage.manaTrain6) ~= "table" then
  storage.manaTrain6 = {on=false, title="MP%", text="exevo gran mas flam", min=80, max=100}
end

-- Função para verificar se há jogadores não amigos na tela
local function hasNonFriendPlayersOnScreen()
  local spectators = getSpectators()
  for _, creature in ipairs(spectators) do
    if creature:isPlayer() and creature ~= player and not isFriend(creature:getName()) then
      return true -- Encontrou um jogador que não é amigo
    end
  end
  return false -- Nenhum jogador que não seja amigo foi encontrado
end

local manatrainmacro = macro(1000, function()
  -- Se o jogador estiver em PZ, não faz nada
  if isInPz() then
    return
  end

  local mana = math.min(100, math.floor(100 * (player:getMana() / player:getMaxMana())))

  -- Verifica se há jogadores não amigos na tela antes de executar a magia
  if not hasNonFriendPlayersOnScreen() and storage.manaTrain6.max >= mana and mana >= storage.manaTrain6.min then
    say(storage.manaTrain6.text)
  end
end)

manatrainmacro.setOn(storage.manaTrain6.on)

UI.DualScrollPanel(storage.manaTrain6, function(widget, newParams)
  storage.manaTrain6 = newParams
  manatrainmacro.setOn(storage.manaTrain6.on)
end)

UI.Separator()
