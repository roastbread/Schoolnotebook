# identify if there is one or more pairs in the hand

# Rank: {2, 3, 4, 5, 6, 7, 8, 9, T, J, Q, K, A}
# Suit: {s, h, d, c}
import random
from abc import ABC, abstractmethod


#########################
#      Agent classes    #
#########################
class PokerAgent(ABC):
    money: int

    def __init__(self):
        self.money = 0

    @abstractmethod
    def bid(self):
        pass

    @abstractmethod
    def recall(self):
        pass


class PokerAgentRandom(PokerAgent):
    def __init__(self):
        super().__init__()

    def bid(self):
        return random.randint(0, 50)

    def recall(self, hand, bid):
        pass


class PokerAgentFixed(PokerAgent):
    def __init__(self):
        super().__init__()

    def bid(self, bidding_phase):
        return bidding_phase * 10
    
    def recall(self, hand, bid):
        pass

class PokerAgentReflex(PokerAgent):
    def __init__(self):
        super().__init__()

    def bid(self, hand):
        global rank
        potential = identify_hand(hand)
        if potential['name'] == 'three of a kind':
            k = 26
        elif potential['name'] == 'pair':
            k = 13
        else:
            k = 0
        
        m = max([rank.index(potential['rank']), rank.index(potential['rank2']), rank.index(potential['rank3'])])
        return int(k+m*2)

    def recall(self, hand, bid):
        pass

class PokerAgentMemory(PokerAgent):
    def __init__(self):
        super().__init__()
        self.memory = dict()
        self.rebet = 0
    def bid(self, hand, opponentBid):
        global rank
        potential = identify_hand(hand)
        if potential['name'] == 'three of a kind':
            k = 26
        elif potential['name'] == 'pair':
            k = 13
        else:
            k = 0
        
        m = max([rank.index(potential['rank']), rank.index(potential['rank2']), rank.index(potential['rank3'])])
        s = 1
        if opponentBid in self.memory:
            winner = compare_identified_hands(identify_hand(hand), identify_hand(self.memory[opponentBid]))
            if winner == 1:
                s = 1
            elif winner == 2:
                s = k+m
            else:
                s = 1
        return (k+m*2)//s

    def recall(self, hand, bid):
        #hand = ''.join(sorted(hand))
        if bid in self.memory and self.memory[bid] != hand:
            self.rebet += 1
        self.memory[bid]=hand
    


###################################
#      functions for game flow    #
###################################
def generate_deck():
    global rank
    global suit
    deck = []

    for s in suit:
        for r in rank:
            deck.append(r + s)
    return deck


# Randomly generate two hands of n cards
def generate_2hands(nn_card=3):
    pass


# identify hand category using IF-THEN rule
def identify_hand(hand: list):
    global rank
    hand.sort(reverse=True, key=lambda x: rank.index(x[0]))
    c1 = hand[0]
    c2 = hand[1]
    c3 = hand[2]

    # due to previous sorting it is possible to reduce comparisons
    if c1[0] == c3[0]:
        return dict(name='three of a kind', rank=c1[0], rank2='2', rank3='2', suit1=c1[1], suit2=c2[1], suit3=c3[1])
    elif c1[0] == c2[0]:
        return dict(name='pair', rank=c1[0], rank2=c3[0], rank3='2', suit1=c1[1], suit2=c2[1], suit3=c3[1])
    elif c2[0] == c3[0]:
        return dict(name='pair', rank=c2[0], rank2=c1[0], rank3='2', suit1=c1[1], suit2=c2[1], suit3=c3[1])
    else:
        return dict(name='high cards', rank=c1[0], rank2=c2[0], rank3=c3[0],
                    suit1=c1[1], suit2=c2[1], suit3=c3[1])


def compare_identified_hands(hand1: dict, hand2: dict):
    global rank
    figure_ranks = ['high cards', 'pair', 'three of a kind']

    # figure out if it is a draw
    if hand1["name"] == hand2["name"] and hand1["rank"] == hand2["rank"] and hand1["rank2"] == hand2["rank2"] and hand1[
        "rank3"] == hand2["rank3"]:
        return 0

    hands = [hand1, hand2]
    hands.sort(reverse=True, key=lambda x: (figure_ranks.index(x['name']),
                                            rank.index(x['rank']), rank.index(x['rank2']), rank.index(x['rank3'])))

    # return the winning hand
    if hand1 == hands[0]:
        return 1
    else:
        return 2


def analyse_hand(hand):
    analyzed = identify_hand(hand)
    print(analyzed)


#########################
#      Game flow        #
#########################

# initialize global variables
rank = ['2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A']
suit = ['s', 'h', 'd', 'c']

Player1 = PokerAgentRandom()
Player2 = PokerAgentMemory()

GameStats = dict(draws=0, player1=0, player2=0)

# play 50 rounds
for rounds in range(50):
    #########################
    # phase 1: Card Dealing #
    #########################

    # instantiate poker hands
    CurrentHand1 = []
    CurrentHand2 = []

    # generate a full deck
    Deck = generate_deck()

    # randomly draw 2 hands with 3 cards each
    for i in range(3):
        # ith card of hand 1
        index = random.randint(0, len(Deck) - 1)
        CurrentHand1.append(Deck.pop(index))
        # ith card of hand 2
        index = random.randint(0, len(Deck) - 1)
        CurrentHand2.append(Deck.pop(index))

    # # analyze hands
    # print(CurrentHand1)
    # print(CurrentHand2)
    # analyse_hand(CurrentHand1)
    # analyse_hand(CurrentHand2)

    #########################
    # phase 2:   Bidding    #
    #########################

    PotSize = 0
    for BiddingPhase in range(1, 3):
        Bid1 = Player1.bid()
        Bid2 = Player2.bid(CurrentHand2, Bid1)
        PotSize += Bid1
        PotSize += Bid2

    #########################
    # phase 3:   Showdown   #
    #########################
    winner = compare_identified_hands(identify_hand(CurrentHand1), identify_hand(CurrentHand2))
    # print("Winning hand:", winner)

    Player2.recall(CurrentHand1, Bid1)

    if winner == 0:
        Player1.money += PotSize / 2
        Player2.money += PotSize / 2
        GameStats['draws'] += 1
    elif winner == 1:
        Player1.money += PotSize
        GameStats['player1'] += 1
    elif winner == 2:
        Player2.money += PotSize
        GameStats['player2'] += 1

####################
#   Show Results   #
####################

if len(Player2.memory) == 1:
    print('Opponent is fixed')

elif Player2.rebet > 0:
    print('Opponent is random')

elif Player2.money > Player1.money and GameStats['player2'] >= GameStats['player1']:
    print('Opponent is reflex')

else:
    print('Opponent could be memory or reflex')


print("Player1 money:", Player1.money)
print("Player2 money:", Player2.money)
print(GameStats)
