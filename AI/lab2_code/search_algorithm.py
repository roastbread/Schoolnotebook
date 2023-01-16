import numpy as np
import math
import heapq
import path_planning as pp
import random

# Priority Queue based on heapq
class PriorityQueue:
    def __init__(self):
        self.elements = []
    def isEmpty(self):
        return len(self.elements) == 0
    def add(self, item, priority):
        heapq.heappush(self.elements,(priority,item))
    def remove(self):
        return heapq.heappop(self.elements)[1]

def get_neighbors(current, map):
    neighbors = []
    current_row = current[0]
    current_col = current[1]
    height, width = map.shape
    '''
    if current_row > 0:
        up = map[current_row - 1, current_col]
        if up != -1:
            neighbors.append((current_row - 1, current_col))

    if current_row < height -1:
        down = map[current_row + 1, current_col]
        if down != -1:
            neighbors.append((current_row + 1, current_col))

    if current_col > 0:
        left = map[current_row, current_col -1]
        if left != -1:
            neighbors.append((current_row, current_col -1))

    if current_col < width -1:
        right = map[current_row, current_col + 1]
        if right != -1:
            neighbors.append((current_row, current_col + 1))
    '''
    edges = map.shape
    for x in range(-1,2,2):
        if current[0]+x > -1 and current[0]+x < edges[0] and map[current[0]+x, current[1]] != -1:
            neighbors.append((current[0]+x, current[1]))
        if current[1]+x > -1 and current[1]+x < edges[1]and map[current[0], current[1]+x] != -1:
            neighbors.append((current[0], current[1]+x))
    
    return neighbors

def cost_function(current, moving_cost, args, distance):
    if args == 'random':
        return float(current + moving_cost*random.randint(1, 10))
    elif args == 'bfs':
        return float(current + moving_cost)
    elif args == 'dfs':
        return float(current - moving_cost)
    elif args == 'greedy':
        return float(distance)
    elif args == 'a_star':
        return float(current + distance)
    


def get_manhattan(current, goal):
    cx = current[0]
    cy = current[1]
    gx = goal[0]
    gy = goal[1]
    return np.abs(cx-gx) + np.abs(cy-gy) 

def get_euclidean(current, goal):
    cx = current[0]
    cy = current[1]
    gx = goal[0]
    gy = goal[1]
    return math.sqrt((cx-gx)**2 + (cy-gy)**2)

def get_path(came_from, start, current):
    steps = []
    location = came_from.pop(current)
    while came_from[location] != start:
        steps.append(location)
        location = came_from.pop(location)
    steps.append(location)
    steps.append(came_from.pop(location))
    return steps

def clean_map(map):
    width, height = map.shape 
    for y in range(height):
        for x in range(width):
            if map[y][x] > 0:
                map[y][x] = 0

# An example of search algorithm, feel free to modify and implement the missing part
def search(map, start, goal, moving_cost=1, args='random', heuristic='euclidean'):
    clean_map(map)
    # open list
    frontier = PriorityQueue()
    # add starting cell to open list
    frontier.add(start, 0)

    # path taken
    came_from = {}

    # expanded list with cost value for each cell
    cost = {}
    cost[start] = 0

    # if there is still nodes to open
    current = 0
    while not frontier.isEmpty():
        if current == goal:
            break

        current = frontier.remove()

        # check if the goal is reached
        if current == goal:
            break

        # for each neighbour of the current cell
        # Implement get_neighbors function (return nodes to expand next)
        # (make sure you avoid repetitions!)
        for next in get_neighbors(current, map):
            if next == goal:
                came_from[next] = current
                current = next
                break
            if next not in came_from:

                

                # compute cost to reach next cell
                # Implement cost function
                if heuristic == 'euclidean':
                    distance = get_euclidean(current, goal)
                elif heuristic == 'manhattan':
                    distance = get_manhattan(current,goal)
                cost[next] = cost_function(cost[current], moving_cost, args, distance)

                if map[next] != -2 and map[next] != -3:
                    map[next] = abs(cost[next])

                # add next cell to open list
                frontier.add(next, cost[next])
            
                # add to path
                came_from[next] = current
    return np.array(get_path(came_from, start, current)), cost



map_i = pp.generateMap2d([60,60])
print(map_i)
start1, start2 = np.where(map_i==-2)
print(start1, start2)
start = (start1[0], start2[0])
print(start, 'START')
end1, end2 = np.where(map_i==-3)
print(end1, end2)
end = (end1[0], end2[0])
print(end, 'END')

_random, cost = search(map_i, start, end, args='random')
pp.plotMap(map_i, _random, 'Random')

bfs, cost = search(map_i, start, end, args='bfs')
pp.plotMap(map_i, bfs, 'Breadth first')

dfs, cost = search(map_i, start, end, args='dfs')
pp.plotMap(map_i, dfs, 'Depth first')

greedy, cost = search(map_i, start, end, args='greedy')
pp.plotMap(map_i, greedy, 'Greedy euclidean')

a_star, cost = search(map_i, start, end, args='a_star')
pp.plotMap(map_i, a_star, 'A* euclidean')

greedy, cost = search(map_i, start, end, args='greedy', heuristic='manhattan')
pp.plotMap(map_i, greedy, 'Greedy manhattan')

a_star, cost = search(map_i, start, end, args='a_star', heuristic='manhattan')
pp.plotMap(map_i, a_star, 'A* manhattan')

'''### H-Obsatacle ###'''

map_h, info = pp.generateMap2d_obstacle([60,60])
print(map_h)
start1, start2 = np.where(map_h==-2)
print(start1, start2)
start = (start1[0], start2[0])
print(start, 'START')
end1, end2 = np.where(map_h==-3)
print(end1, end2)
end = (end1[0], end2[0])
print(end, 'END')


_random, cost = search(map_h, start, end, args='random')
pp.plotMap(map_h, _random, 'Random')

bfs, cost = search(map_h, start, end, args='bfs')
pp.plotMap(map_h, bfs, 'Breadth first')

dfs, cost = search(map_h, start, end, args='dfs')
pp.plotMap(map_h, dfs, 'Depth first')

greedy, cost = search(map_h, start, end, args='greedy')
pp.plotMap(map_h, greedy, 'Greedy euclidean')

a_star, cost = search(map_h, start, end, args='a_star')
pp.plotMap(map_h, a_star, 'A* euclidean')

greedy, cost = search(map_h, start, end, args='greedy', heuristic='manhattan')
pp.plotMap(map_h, greedy, 'Greedy manhattan')

a_star, cost = search(map_h, start, end, args='a_star', heuristic='manhattan')
pp.plotMap(map_h, a_star, 'A* manhattan')

