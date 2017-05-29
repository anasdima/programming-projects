#!/usr/bin/ruby

def score(prediction, real)
    score = 0;
    if prediction[0] > prediction[1] && real[0] > real[1]
        score = score + 10;
    elsif prediction[0] < prediction[1] && real[0] < real[1]
        score = score + 10;
    end
    score = score + [0, 5 - (prediction[0] - real[0]).abs].max
    score = score + [0, 5 - (prediction[1] - real[1]).abs].max
    score = score + [0, 5 - (prediction[0] - prediction[1] - real[0] + real[1]).abs].max
end

N = gets.chomp.to_i

N.times do
    input = gets.chomp.split.map(&:to_i)
    players = input[0]
    games = input[1]

    playerName = Array.new(players)
    predictionMap = Array.new(players)
    realResults = Array.new(games)
    (0...players).each do |i|
        playerName[i] = gets.chomp
        playerPredictions = Array.new(games)
        (0...games).each do |j|
            playerPredictions[j] = gets.chomp.split.map(&:to_i)
        end
        predictionMap[i] = playerPredictions
    end
    (0...games).each do |i|
        realResults[i] = gets.chomp.split
    end

    unknownGames = [];
    playerScore = Array.new(players, 0)
    realResults.each_with_index do |result, gameID|
        if result == ["?", "?"]
            unknownGames.push(gameID)
        else
            predictionMap.each_with_index do |prediction, playerID|
                playerScore[playerID] = playerScore[playerID] + score(prediction[gameID], result.map(&:to_i))
            end
        end
    end

    p playerScore

    maxPlayerBonus = Array.new(players) {Array.new(players, 0)}
    unknownGames.each do |gameID|
        (0...players).each do |i|
            (0...players).each do |j|
                maxPlayerBonus[i][j] = maxPlayerBonus[i][j] + score(predictionMap[j][gameID], predictionMap[i][gameID])
            end
        end
    end

    candidates = []
    (0...players).each do |i|
        maxPlayerScore = playerScore
        (0...players).each do |j|
            maxPlayerScore[j] = maxPlayerScore[j] + maxPlayerBonus[i][j]
            if maxPlayerScore[j] > 200
                maxPlayerScore[j] = 200
                candidates.push(playerName[i])
            end
        end
        if maxPlayerScore[i] == maxPlayerScore.max #&& maxPlayerScore.count(200) < 2
            candidates.push(playerName[i])
        end
    end

    p maxPlayerBonus

    tmp = ""
    candidates.uniq.sort.each do |candidate|
        tmp = tmp + candidate + " "
    end
    puts tmp.chomp.strip

end
