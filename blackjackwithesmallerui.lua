local UserInputService = game:GetService("UserInputService")
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.25, 0, 0.4, 0) -- Smaller size
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(53, 53, 53)
mainFrame.Parent = gui

local uiScale = Instance.new("UIScale")
uiScale.Parent = mainFrame

-- UI Toggle State
local uiVisible = true

-- Game UI Elements
local dealerFrame = Instance.new("Frame")
dealerFrame.Size = UDim2.new(1, 0, 0.3, 0)
dealerFrame.BackgroundTransparency = 1
dealerFrame.Parent = mainFrame

local playerFrame = Instance.new("Frame")
playerFrame.Size = UDim2.new(1, 0, 0.3, 0)
playerFrame.Position = UDim2.new(0, 0, 0.3, 0)
playerFrame.BackgroundTransparency = 1
playerFrame.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0.1, 0)
statusLabel.Position = UDim2.new(0, 0, 0.6, 0)
statusLabel.Text = "Press New Game to start!"
statusLabel.TextColor3 = Color3.new(1,1,1)
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = mainFrame

local buttonFrame = Instance.new("Frame")
buttonFrame.Size = UDim2.new(1, 0, 0.1, 0)
buttonFrame.Position = UDim2.new(0, 0, 0.7, 0)
buttonFrame.BackgroundTransparency = 1
buttonFrame.Parent = mainFrame

local hitButton = Instance.new("TextButton")
hitButton.Size = UDim2.new(0.19, 0, 1, 0)
hitButton.Text = "HIT"
hitButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
hitButton.Visible = false
hitButton.Parent = buttonFrame

local standButton = Instance.new("TextButton")
standButton.Size = UDim2.new(0.19, 0, 1, 0)
standButton.Position = UDim2.new(0.2, 0, 0, 0)
standButton.Text = "STAND"
standButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
standButton.Visible = false
standButton.Parent = buttonFrame

local splitButton = Instance.new("TextButton")
splitButton.Size = UDim2.new(0.19, 0, 1, 0)
splitButton.Position = UDim2.new(0.4, 0, 0, 0)
splitButton.Text = "SPLIT"
splitButton.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
splitButton.Visible = false
splitButton.Parent = buttonFrame

local doubleButton = Instance.new("TextButton")
doubleButton.Size = UDim2.new(0.19, 0, 1, 0)
doubleButton.Position = UDim2.new(0.6, 0, 0, 0)
doubleButton.Text = "DOUBLE"
doubleButton.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
doubleButton.Visible = false
doubleButton.Parent = buttonFrame

local newGameButton = Instance.new("TextButton")
newGameButton.Size = UDim2.new(0.19, 0, 1, 0)
newGameButton.Position = UDim2.new(0.8, 0, 0, 0)
newGameButton.Text = "NEW GAME"
newGameButton.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
newGameButton.Parent = buttonFrame

-- Credit System
local credits = 1000
local currentBet = 0

local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.new(1, 0, 0.05, 0)
creditLabel.Position = UDim2.new(0, 0, 0.95, 0)
creditLabel.Text = "Credits: $" .. credits
creditLabel.TextColor3 = Color3.new(1,1,1)
creditLabel.BackgroundTransparency = 1
creditLabel.Parent = mainFrame

local betBox = Instance.new("TextBox")
betBox.Size = UDim2.new(0.2, 0, 0.05, 0)
betBox.Position = UDim2.new(0.4, 0, 0.9, 0)
betBox.PlaceholderText = "Enter Bet"
betBox.Text = ""
betBox.BackgroundColor3 = Color3.new(1,1,1)
betBox.TextColor3 = Color3.new(0,0,0)
betBox.Parent = mainFrame

-- Game variables
local deck = {}
local playerHands = {{}}
local currentHandIndex = 1
local dealerHand = {}
local gameInProgress = false

local cardValues = {
    ["A"] = 11, ["2"] = 2, ["3"] = 3, ["4"] = 4, ["5"] = 5,
    ["6"] = 6, ["7"] = 7, ["8"] = 8, ["9"] = 9, ["10"] = 10,
    ["J"] = 10, ["Q"] = 10, ["K"] = 10
}

local suits = {"♠", "♣", "♥", "♦"}

-- UI Toggle Function
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        uiVisible = not uiVisible
        mainFrame.Visible = uiVisible
    end
end)

-- Create and shuffle deck
local function createDeck()
    local newDeck = {}
    for _, suit in pairs(suits) do
        for rank in pairs(cardValues) do
            table.insert(newDeck, {
                suit = suit,
                rank = rank,
                value = cardValues[rank]
            })
        end
    end
    return newDeck
end

local function shuffleDeck()
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
end

-- Calculate hand value
local function calculateHandValue(hand)
    local total = 0
    local aces = 0
    
    for _, card in pairs(hand) do
        total += card.value
        if card.rank == "A" then aces += 1 end
    end
    
    while total > 21 and aces > 0 do
        total -= 10
        aces -= 1
    end
    
    return total
end

-- Update UI
local function updateUI()
    playerFrame:ClearAllChildren()
    dealerFrame:ClearAllChildren()

    -- Player hands layout
    local playerLayout = Instance.new("UIListLayout")
    playerLayout.FillDirection = Enum.FillDirection.Horizontal
    playerLayout.Padding = UDim.new(0.05, 0)
    playerLayout.Parent = playerFrame

    -- Player hands
    for handIndex, hand in pairs(playerHands) do
        local handContainer = Instance.new("Frame")
        handContainer.BackgroundTransparency = 1
        handContainer.Size = UDim2.new(0.3, 0, 1, 0)
        
        -- Current hand highlight
        if handIndex == currentHandIndex then
            local highlight = Instance.new("Frame")
            highlight.Size = UDim2.new(1, 0, 1, 0)
            highlight.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
            highlight.BackgroundTransparency = 0.8
            highlight.ZIndex = -1
            highlight.Parent = handContainer
        end

        -- Cards layout
        local cardLayout = Instance.new("UIListLayout")
        cardLayout.FillDirection = Enum.FillDirection.Horizontal
        cardLayout.Padding = UDim.new(0.05, 0)
        cardLayout.Parent = handContainer

        for _, card in pairs(hand) do
            local cardLabel = Instance.new("TextLabel")
            cardLabel.Text = card.rank .. card.suit
            cardLabel.Size = UDim2.new(0, 40, 0, 60) -- Smaller card size
            cardLabel.BackgroundColor3 = Color3.new(1,1,1)
            cardLabel.TextColor3 = (card.suit == "♥" or card.suit == "♦") and Color3.new(1,0,0) or Color3.new(0,0,0)
            cardLabel.Parent = handContainer
        end
        handContainer.Parent = playerFrame
    end

    -- Dealer cards layout
    local dealerLayout = Instance.new("UIListLayout")
    dealerLayout.FillDirection = Enum.FillDirection.Horizontal
    dealerLayout.Padding = UDim.new(0.05, 0)
    dealerLayout.Parent = dealerFrame

    for i, card in pairs(dealerHand) do
        local cardLabel = Instance.new("TextLabel")
        cardLabel.Text = (i == 2 and gameInProgress) and "??" or card.rank .. card.suit
        cardLabel.Size = UDim2.new(0, 40, 0, 60) -- Smaller card size
        cardLabel.BackgroundColor3 = Color3.new(1,1,1)
        cardLabel.TextColor3 = (i == 2 and gameInProgress) and Color3.new(0,0,0) or 
                              ((card.suit == "♥" or card.suit == "♦") and Color3.new(1,0,0) or Color3.new(0,0,0))
        cardLabel.Parent = dealerFrame
    end

    -- Update status
    local currentHandValue = calculateHandValue(playerHands[currentHandIndex])
    statusLabel.Text = string.format("Hand %d/%d: %d | Dealer Shows: %s",
        currentHandIndex,
        #playerHands,
        currentHandValue,
        gameInProgress and dealerHand[1].value or calculateHandValue(dealerHand)
    )
end

-- Deal card
local function dealCard(hand)
    table.insert(hand, table.remove(deck, 1))
end

-- Dealer's turn
local function dealerTurn()
    gameInProgress = false
    updateUI()
    
    -- Dealer hits on soft 17
    while true do
        local total = calculateHandValue(dealerHand)
        local soft = false
        if total == 17 then
            for _, card in pairs(dealerHand) do
                if card.value == 11 then
                    soft = true
                    break
                end
            end
        end
        
        if total < 17 or (total == 17 and soft) then
            dealCard(dealerHand)
            updateUI()
            wait(1)
        else
            break
        end
    end
    
    local dealerTotal = calculateHandValue(dealerHand)
    local results = {}
    
    for i, hand in ipairs(playerHands) do
        local playerTotal = calculateHandValue(hand)
        local result
        
        if playerTotal > 21 then
            result = "Hand "..i..": Bust!"
            credits -= currentBet
        elseif dealerTotal > 21 then
            result = "Hand "..i..": Win!"
            credits += currentBet * 2 -- Double the bet for a win
        elseif playerTotal > dealerTotal then
            result = "Hand "..i..": Win!"
            credits += currentBet * 2 -- Double the bet for a win
        elseif playerTotal < dealerTotal then
            result = "Hand "..i..": Lose!"
            credits -= currentBet
        else
            result = "Hand "..i..": Push!"
            credits += currentBet -- Return the bet on a push
        end
        
        table.insert(results, result)
    end
    
    statusLabel.Text = table.concat(results, " | ")
    creditLabel.Text = "Credits: $" .. credits
    
    -- Check if credits are zero and offer a reset
    if credits <= 0 then
        statusLabel.Text = statusLabel.Text .. "\nYou're out of credits! Press RESET to start over."
        local resetButton = Instance.new("TextButton")
        resetButton.Size = UDim2.new(0.2, 0, 0.1, 0)
        resetButton.Position = UDim2.new(0.4, 0, 0.85, 0)
        resetButton.Text = "RESET"
        resetButton.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
        resetButton.Parent = mainFrame
        
        resetButton.MouseButton1Click:Connect(function()
            credits = 1000
            creditLabel.Text = "Credits: $" .. credits
            resetButton:Destroy()
            statusLabel.Text = "Press New Game to start!"
        end)
    end
    
    hitButton.Visible = false
    standButton.Visible = false
    splitButton.Visible = false
    doubleButton.Visible = false
    newGameButton.Visible = true
end

-- Start new game
local function newGame()
    local bet = tonumber(betBox.Text) or 0
    if bet <= 0 or bet > credits then
        statusLabel.Text = "Invalid bet!"
        return
    end
    
    currentBet = bet
    credits -= currentBet
    creditLabel.Text = "Credits: $" .. credits
    
    deck = createDeck()
    shuffleDeck()
    
    playerHands = {{}}
    currentHandIndex = 1
    dealerHand = {}
    
    -- Initial deal
    dealCard(playerHands[1])
    dealCard(dealerHand)
    dealCard(playerHands[1])
    dealCard(dealerHand)
    
    gameInProgress = true
    hitButton.Visible = true
    standButton.Visible = true
    splitButton.Visible = (#playerHands[1] == 2 and 
                          playerHands[1][1].rank == playerHands[1][2].rank)
    doubleButton.Visible = (#playerHands[1] == 2)
    newGameButton.Visible = false
    
    updateUI()
    
    -- Check for immediate blackjack
    if calculateHandValue(playerHands[1]) == 21 then
        dealerTurn()
    end
end

-- Button handlers
hitButton.MouseButton1Click:Connect(function()
    if not gameInProgress then return end
    
    dealCard(playerHands[currentHandIndex])
    splitButton.Visible = false
    doubleButton.Visible = false
    updateUI()
    
    if calculateHandValue(playerHands[currentHandIndex]) > 21 then
        if currentHandIndex < #playerHands then
            currentHandIndex += 1
            splitButton.Visible = (#playerHands[currentHandIndex] == 2 and 
                                  playerHands[currentHandIndex][1].rank == playerHands[currentHandIndex][2].rank)
            updateUI()
        else
            dealerTurn()
        end
    end
end)

standButton.MouseButton1Click:Connect(function()
    if not gameInProgress then return end
    
    if currentHandIndex < #playerHands then
        currentHandIndex += 1
        splitButton.Visible = (#playerHands[currentHandIndex] == 2 and 
                              playerHands[currentHandIndex][1].rank == playerHands[currentHandIndex][2].rank)
        updateUI()
    else
        dealerTurn()
    end
end)

splitButton.MouseButton1Click:Connect(function()
    if #playerHands >= 4 then return end
    
    local originalHand = playerHands[currentHandIndex]
    if #originalHand ~= 2 then return end
    if originalHand[1].rank ~= originalHand[2].rank then return end
    
    local newHand = {table.remove(originalHand)}
    table.insert(playerHands, newHand)
    
    dealCard(originalHand)
    dealCard(newHand)
    
    splitButton.Visible = (#originalHand == 2 and originalHand[1].rank == originalHand[2].rank)
    updateUI()
end)

doubleButton.MouseButton1Click:Connect(function()
    if not gameInProgress then return end
    if #playerHands[currentHandIndex] ~= 2 then return end
    
    credits -= currentBet
    currentBet *= 2
    creditLabel.Text = "Credits: $" .. credits
    
    dealCard(playerHands[currentHandIndex])
    dealerTurn()
end)

newGameButton.MouseButton1Click:Connect(newGame)

-- Initial state
newGameButton.Visible = true
hitButton.Visible = false
standButton.Visible = false
splitButton.Visible = false
doubleButton.Visible = false
mainFrame.Visible = uiVisible
