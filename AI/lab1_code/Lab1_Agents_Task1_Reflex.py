# Make sure to have the server side running in V-REP:
# in a child script of a V-REP scene, add following command
# to be executed just once, at simulation start:
#
# simExtRemoteApiStart(19999)
# then start simulation, and run this program.
#
# IMPORTANT: for each successful call to simxStart, there
# should be a corresponding call to simxFinish at the end!
import Lab1_Agents_Task1_World as World



def look_at_nearest_block(motor_speed):
    block = World.findEnergyBlocks()[0]
    if left<.5 and right<.5:
        World.execute(dict(speedLeft = -1, speedRight = 1),1000,1)
        motor_speed = dict(speedLeft = 1, speedRight = 1)
        World.setMotorSpeeds(motor_speed)
        return
    if block[2] > 2:
        return
    while abs(block[-1]) > 0.1:
        if block[-1] < 0:
            motor_speed = dict(speedLeft = -.5, speedRight = .5)
        elif block[-1] > 0:
            motor_speed = dict(speedLeft = .5, speedRight = -.5)
        if block[2] < 0.5:
            World.collectNearestBlock()
            break
        #print(block[-1], block[2], motor_speed)
        block = World.findEnergyBlocks()[0]
        print('Looking')
        World.setMotorSpeeds(motor_speed)
    World.STOP()            


# connect to the server
robot = World.init()
# print important parts of the robot
print(sorted(robot.keys()))

while robot: # main Control loop
    #######################################################
    # Perception Phase: Get information about environment #
    #######################################################
    simulationTime = World.getSimulationTime()
    left = World.getSensorReading("ultraSonicSensorLeft")
    right = World.getSensorReading("ultraSonicSensorRight")

    if simulationTime%1000==0:
        # print some useful info, but not too often
        print ('Time:',simulationTime,\
               'ultraSonicSensorLeft:',left,\
               "ultraSonicSensorRight:",right)

    ##############################################
    # Reasoning: figure out which action to take #
    

    if left<.5 and right<.5:
        World.execute(dict(speedLeft = -1, speedRight = 1),1000,1)
        motorSpeed = dict(speedLeft = 1, speedRight = 1)
    elif left<right:
        motorSpeed = dict(speedLeft = 1.5, speedRight = 1)

    elif right<left:
        motorSpeed = dict(speedLeft = 1, speedRight = 1.5)

    else:
        motorSpeed = dict(speedLeft=1, speedRight=1)

    if simulationTime%1000==0:
        look_at_nearest_block(motorSpeed)


    ########################################
    # Action Phase: Assign speed to wheels #
    ########################################
    # assign speed to the wheels
    World.setMotorSpeeds(motorSpeed)
    # try to collect energy block (will fail if not within range)
    if simulationTime%500==0:
        print("Energy blocks:", World.findEnergyBlocks()[0])
        print ("Trying to collect a block...",World.collectNearestBlock())
