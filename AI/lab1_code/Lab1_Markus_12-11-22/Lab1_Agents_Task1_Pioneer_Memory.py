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


def align_robot_energy():
    """
    aligns the robot so it faces the nearest energy block

    :return:
    """
    print("Aligning Robot to next Energy point ", World.getSensorReading("energySensor"))
    direction = World.getSensorReading("energySensor").direction
    motorSpeed = dict(speedLeft=0, speedRight=0)
    timeStarting = World.getSimulationTime()
    timeCurrent = timeStarting

    while abs(direction) > 0.2:
        # update sensor values
        timeCurrent = World.getSimulationTime() - timeStarting
        direction = World.getSensorReading("energySensor").direction

        # if got stuck during alignment, drive back a bit (e.g. 2 blocks have the same distance -> endless loop)
        if timeCurrent > 10000 and timeCurrent % 10000 < 500:
            motorSpeed = dict(speedLeft=-1, speedRight=-1)
        elif direction > 0.1:
            motorSpeed = dict(speedLeft=0.5, speedRight=-0.5)
        elif direction < -0.1:
            motorSpeed = dict(speedLeft=-0.5, speedRight=0.5)

        collect_energy_block()
        World.setMotorSpeeds(motorSpeed)


def align_wall():
    """
    aligns the robot with the wall in fron of it, so the robot will be normal to the wall with the wall on it's left
    prerequisite: wall in close range in front of the robot
    :return:
    """
    # initiate sensor values
    currentDistanceLeft0 = World.getSensorReading("ultraSonicSensorLeft0")
    currentDistanceLeft = World.getSensorReading("ultraSonicSensorLeft")
    currentDistanceFront = World.getSensorReading("ultraSonicSensorFront")
    lastDistanceLeft0 = currentDistanceLeft0

    motorSpeed = dict(speedLeft=0, speedRight=0)
    while currentDistanceFront < 0.6 or (currentDistanceLeft0 - lastDistanceLeft0) > 0 or currentDistanceLeft < 0.3:
        # update sensor values
        currentDistanceLeft = World.getSensorReading("ultraSonicSensorLeft")
        currentDistanceFront = World.getSensorReading("ultraSonicSensorFront")
        lastDistanceLeft0 = currentDistanceLeft0

        collect_energy_block()
        motorSpeed = dict(speedLeft=0.5, speedRight=-0.5)
        World.setMotorSpeeds(motorSpeed)

    motorSpeed = dict(speedLeft=0, speedRight=0)
    World.setMotorSpeeds(motorSpeed)
    print("finished aligning to wall")


def follow_wall(duration_ms):
    """
    makes the robot follow a wall to its left ( includes going around corners)
    :param duration_ms: duration in [ms] to follow the wall
    :return:
    """
    print("following wall for", duration_ms)
    currentDistanceLeft0 = World.getSensorReading("ultraSonicSensorLeft0")
    currentDistanceLeft = World.getSensorReading("ultraSonicSensorLeft")
    currentDistanceRight = World.getSensorReading("ultraSonicSensorRight")
    currentDistanceFront = World.getSensorReading("ultraSonicSensorFront")
    lastDistanceLeft = 0
    timeStarting = World.getSimulationTime()
    timeCurrent = timeStarting

    motorSpeed = dict(speedLeft=0, speedRight=0)

    while timeCurrent < (timeStarting + duration_ms) and collect_energy_block() == 0:
        # update sensor values
        timeCurrent = World.getSimulationTime()
        lastDistanceLeft0 = currentDistanceLeft0
        currentDistanceLeft0 = World.getSensorReading("ultraSonicSensorLeft0")
        currentDistanceLeft = World.getSensorReading("ultraSonicSensorLeft")
        currentDistanceFront = World.getSensorReading("ultraSonicSensorFront")

        if currentDistanceFront < 0.5 or currentDistanceLeft < 0.2:
            align_wall()
        # if wall to the left ends, turn sharp left to go around the corner
        elif currentDistanceLeft0 > 0.4:
            print("go around the corner")
            motorSpeed = dict(speedLeft=0.2, speedRight=1.5)
        elif currentDistanceLeft0 - lastDistanceLeft0 > 0:
            print("turn left")
            motorSpeed = dict(speedLeft=1, speedRight=1.2)
        elif currentDistanceLeft0 - lastDistanceLeft0 < 0:
            print("turn right")
            motorSpeed = dict(speedLeft=1.2, speedRight=1)
        else:
            print("follow straight")
            motorSpeed = dict(speedLeft=2, speedRight=2)

        World.setMotorSpeeds(motorSpeed)

        print("Distance Left0: ", currentDistanceLeft0)

    print("finished following wall, aiming for next energy block")


def collect_energy_block():
    """
    tries to collect the nearest energy block and prints message on console if successful
    increments global counter for collected blocks and resets global wall following duration if successful
    :return:
    0: if not successful
    1: if successful
    """
    global blocksCollected
    global durationFollowWall
    if World.collectNearestBlock() == 'Energy collected :)':
        print("Energy collected")
        blocksCollected + 1
        durationFollowWall = 0
        return 1
    return 0


# initialize  global variables
blocksCollected = 0
durationFollowWall = 0
# connect to the server
robot = World.init()
# print important parts of the robot
print(sorted(robot.keys()))

print("Test energy Sensor reading: ", World.getSensorReading("energySensor"))

# align robot to next energy block before main control loop
align_robot_energy()

while robot:  # main Control loop
    #######################################################
    # Perception Phase: Get information about environment #
    #######################################################
    simulationTime = World.getSimulationTime()

    currentDistanceLeft = World.getSensorReading("ultraSonicSensorLeft")
    currentDistanceRight = World.getSensorReading("ultraSonicSensorRight")
    currentDistanceFront = World.getSensorReading("ultraSonicSensorFront")

    ##############################################
    # Reasoning: figure out which action to take #
    ##############################################
    if currentDistanceFront < 0.5:
        motorSpeed = dict(speedLeft=0, speedRight=0)
        World.setMotorSpeeds(motorSpeed)
        # align normal to wall to follow it later
        align_wall()
        durationFollowWall += 30000
        follow_wall(durationFollowWall)
        # motorSpeed = dict(speedLeft=-1, speedRight=-1)
    elif currentDistanceLeft < 0.2:
        motorSpeed = dict(speedLeft=1.5, speedRight=0)
    elif currentDistanceRight < 0.2:
        motorSpeed = dict(speedLeft=0, speedRight=1.5)
    else:
        motorSpeed = dict(speedLeft=2, speedRight=2)

    ########################################
    # Action Phase: Assign speed to wheels #
    ########################################
    # assign speed to the wheels
    World.setMotorSpeeds(motorSpeed)
    # try to collect energy block
    collect_energy_block()
    align_robot_energy()
