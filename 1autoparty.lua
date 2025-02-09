setDefaultTab("Main")

local panelName = "autoParty"
local ui = setupUI([[
Panel
  height: 38

  BotSwitch
    id: status
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    height: 18
    text: Auto Party

  Button
    id: editPlayerList
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 18
    text: Setup

  Button
    id: ptLeave
    text: Leave Party
    anchors.left: parent.left
    anchors.top: prev.bottom
    width: 86
    height: 17
    margin-top: 3
    color: #ee0000
    font: verdana-11px-rounded

  BotSwitch
    id: ptShare
    text: Auto Share
    anchors.left: prev.right
    anchors.bottom: prev.bottom
    margin-left: 4
    height: 17
    width: 86
]], parent)

g_ui.loadUIFromString([[
AutoPartyName < Label
  background-color: alpha
  text-offset: 2 0
  focusable: true
  height: 16

  $focus:
    background-color: #00000055

  Button
    id: remove
    text: x
    anchors.right: parent.right
    margin-right: 15
    width: 15
    height: 15

AutoPartyListWindow < MainWindow
  text: Auto Party
  size: 200 315
  @onEscape: self:hide()

  Label
    id: lblLeader
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.right: parent.right
    text-align: center
    text: Leader Name

  TextEdit
    id: txtLeader
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5

  Label
    id: lblParty
    anchors.left: parent.left
    anchors.top: prev.bottom
    anchors.right: parent.right
    margin-top: 5
    text-align: center
    text: Party List

  TextList
    id: lstAutoParty
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 5
    margin-bottom: 5
    padding: 1
    height: 100
    vertical-scrollbar: AutoPartyListListScrollBar

  VerticalScrollBar
    id: AutoPartyListListScrollBar
    anchors.top: lstAutoParty.top
    anchors.bottom: lstAutoParty.bottom
    anchors.right: lstAutoParty.right
    step: 14
    pixels-scroll: true

  TextEdit
    id: playerName
    anchors.left: parent.left
    anchors.top: lstAutoParty.bottom
    margin-top: 5
    width: 120

  Button
    id: addPlayer
    text: +
    font: verdana-11px-rounded
    anchors.right: parent.right
    anchors.left: prev.right
    anchors.top: prev.top
    anchors.bottom: prev.bottom
    color: green
    margin-left: 3

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.top: prev.bottom
    margin-top: 8

  CheckBox
    id: inviteMsg
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 6
    text: Invite/Accept on Msg:
    tooltip: If you are the leader, invite player that said this msg, else, accept party when someone say this.\n

  TextEdit
    id: inviteTxt
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: inviteMsg.bottom
    margin-top: 5
    width: 148

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 6

  Button
    id: closeButton
    text: Close
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21

  Button
    id: info
    text: Credits
    font: cipsoftFont
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    size: 45 21
    color: yellow
    !tooltip: tr('Original made by Lee#7225\nModified by F.Almeida#8019')
]])
ui:setId(panelName)

if not storage[panelName] then
  storage[panelName] = {
    leaderName = 'Leader',
    autoPartyList = {},
    enabled = false,
    inviteTxt = 'party me'
  }
end

if not storage[panelName].autoShare then
  storage[panelName].autoShare = false
end

if not storage[panelName].onMsg then
  storage[panelName].onMsg = false
end

rootWidget = g_ui.getRootWidget()
if rootWidget then
  tcAutoParty = ui.status
  tcAutoShare = ui.ptShare

  autoPartyListWindow = UI.createWindow('AutoPartyListWindow', rootWidget)
  autoPartyListWindow:hide()

  ui.editPlayerList.onClick = function(widget)
    autoPartyListWindow:show()
    autoPartyListWindow:raise()
    autoPartyListWindow:focus()
  end

  ui.ptLeave.onClick = function(widget)
    g_game.partyLeave()
  end

  autoPartyListWindow.closeButton.onClick = function(widget)
    autoPartyListWindow:hide()
  end

  if storage[panelName].autoPartyList and #storage[panelName].autoPartyList > 0 then
    for _, pName in ipairs(storage[panelName].autoPartyList) do
      local label = g_ui.createWidget("AutoPartyName", autoPartyListWindow.lstAutoParty)
      label.remove.onClick = function(widget)
        table.removevalue(storage[panelName].autoPartyList, label:getText())
        label:destroy()
      end
      label:setText(pName)
    end
  end
  autoPartyListWindow.addPlayer.onClick = function(widget)
    local playerName = autoPartyListWindow.playerName:getText()
    if playerName:len() > 0 and not (table.contains(storage[panelName].autoPartyList, playerName, true) or storage[panelName].leaderName == playerName) then
      table.insert(storage[panelName].autoPartyList, playerName)
      local label = g_ui.createWidget("AutoPartyName", autoPartyListWindow.lstAutoParty)
      label.remove.onClick = function(widget)
        table.removevalue(storage[panelName].autoPartyList, label:getText())
        label:destroy()
      end
      label:setText(playerName)
      autoPartyListWindow.playerName:setText('')
    end
  end

  ui.status:setOn(storage[panelName].enabled)
  ui.status.onClick = function(widget)
    storage[panelName].enabled = not storage[panelName].enabled
    widget:setOn(storage[panelName].enabled)
  end

  ui.ptShare:setOn(storage[panelName].autoShare)
  ui.ptShare.onClick = function(widget)
    storage[panelName].autoShare = not storage[panelName].autoShare
    widget:setOn(storage[panelName].autoShare)
  end

  autoPartyListWindow.inviteMsg:setChecked(storage[panelName].onMsg)
  autoPartyListWindow.inviteMsg.onClick = function(widget)
    storage[panelName].onMsg = not storage[panelName].onMsg
    widget:setChecked(storage[panelName].onMsg)
  end

  autoPartyListWindow.playerName.onKeyPress = function(self, keyCode, keyboardModifiers)
    if not (keyCode == 5) then
      return false
    end
    autoPartyListWindow.addPlayer.onClick()
    return true
  end

  autoPartyListWindow.playerName.onTextChange = function(widget, text)
    if table.contains(storage[panelName].autoPartyList, text, true) then
      autoPartyListWindow.addPlayer:setColor("#FF0000")
    else
      autoPartyListWindow.addPlayer:setColor("#FFFFFF")
    end
  end

  autoPartyListWindow.txtLeader.onTextChange = function(widget, text)
    storage[panelName].leaderName = text
  end
  autoPartyListWindow.txtLeader:setText(storage[panelName].leaderName)

  autoPartyListWindow.inviteTxt.onTextChange = function(widget, text)
    storage[panelName].inviteTxt = text
  end
  autoPartyListWindow.inviteTxt:setText(storage[panelName].inviteTxt)
  
  -- main loop
  macro(500,function()
    if not storage[panelName].enabled then return true end
    local lider = player:getName():lower() == storage[panelName].leaderName:lower()
    for s, spec in pairs(getSpectators()) do
      if spec:isPlayer() and spec ~= player then
        if lider then
          if spec:getShield() == 0 then
            if table.find(storage[panelName].autoPartyList,spec:getName(),true) then
              g_game.partyInvite(spec:getId())
            end
          end
        else
          if spec:getShield() == 1 then
           if spec:getName():lower() == storage[panelName].leaderName:lower() then
            g_game.partyJoin(spec:getId())
           end
          end
        end
      end
    end
    if lider and storage[panelName].autoShare then
      if not player:isPartySharedExperienceActive() then
      	g_game.partyShareExperience(true)
      end
    end
  end)

  -- invite on msg
  onTalk(function(name, level, mode, text, channelId, pos)
    if not storage[panelName].enabled then return true end
    if not storage[panelName].onMsg or not string.find(text, storage[panelName].inviteTxt) then return true end
    local c = getCreatureByName(name)
    if c then 
      if c:isPlayer() and c ~= player then
        if c:getShield() == 0 then
          g_game.partyInvite(c:getId())
        elseif c:getShield() == 1 then
          g_game.partyJoin(c:getId())
        end
      end
    end
  end)
end

addSeparator()
