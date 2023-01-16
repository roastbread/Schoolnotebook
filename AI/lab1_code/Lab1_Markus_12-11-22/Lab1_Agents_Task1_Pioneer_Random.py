# Make sure to have the server side running in V-REP:
# in a child script of a V-REP scene, add following command
# to be executed just once, at simulation start:
#
# simExtRemoteApiStart(19999)
# then start simulation, and run this program.
#
# IMPORTANT: for each successful call to simxStart, there
# should be a corresponding call to simxFinish at the end!
import random

import Lab1_Agents_Task1_World as World

# connect to the server
robot = World.init()
# print important parts of the robot
print(sorted(robot.keys()))

while robot: # main Control loop
    #######################################################
    # Perception Phase: Get information about environment #
    #######################################################
    simulationTime = World.getSimulationTime()

    ##############################################
    # Reasoning: figure out which action to take (random) #
    ##############################################
    Mode = random.randint(0,1) # 0: Turning Mode, 1: Driving Mode
    turningTime = random.randint(0,10000)
    drivingTime = random.randint(0,30000)

    ########################################
    # Action Phase: Assign speed to wheels #
    ########################################
    if Mode == 0:
        World.execute(dict(speedLeft=2, speedRight=-2), turningTime, -1)
    elif Mode == 1:
        World.execute(dict(speedLeft=2, speedRight=2), drivingTime, -1)

    # try to collect energy block (will fail if not within range)
    print ("Trying to collect a block...",World.collectNearestBlock())
