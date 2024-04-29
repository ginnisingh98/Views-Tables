--------------------------------------------------------
--  DDL for Package Body BSC_LOCKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_LOCKS_PUB" AS
/* $Header: BSCPLOKB.pls 120.10 2006/01/24 16:21:49 calaw noship $ */

/*------------------------------------------------------------------------------------------
Procedure CHECK_SYSTEM_LOCK
        This procedure is called when users enter a UI flow.  It verifies
        that the Object being modified is not locked as a top-level Object.
        If the Object is locked as a top-level Object, some other user
        is currently in the process of saving his changes to the database.
        As a result, the value retrieved from the database is still the old value.
        An error will be raised to indicate that the user has to wait until
        the save is completed.
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        p_program_id: -100 = Data Loader UI
                      -101 = Data Loader Backend
                      -200 = Generate Database
                      -201 = Generate Documentation
                      -202 = Rename Interface Table
                      -203 = Generate Database Configuration
                      -300 = Administrator
                      -400 = Objective Designer
                      -500 = Builder
                      -600 = Performance Scorecard
                      -700 = System Upgrade
                      -800 = System Migration
        p_user_id: Application User ID
        p_cascade_lock_level: Number of level for cascade locks
                              Default is -1 which means enable cascade locking
                              all the way to the lowest level
-------------------------------------------------------------------------------------------*/
Procedure  CHECK_SYSTEM_LOCK (
    p_object_key          IN         varchar2
   ,p_object_type         IN         varchar2
   ,p_program_id          IN         number
   ,p_user_id             IN         number   := NULL
   ,p_cascade_lock_level  IN         number   := -1
   ,x_return_status       OUT NOCOPY varchar2
   ,x_msg_count           OUT NOCOPY number
   ,x_msg_data            OUT NOCOPY varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'CHECK_SYSTEM_LOCK';
    l_child_object_keys BSC_LOCKS_PVT.t_array_object_key;
    l_child_object_types BSC_LOCKS_PVT.t_array_object_type;
    l_child_object_count NUMBER := 0;
    l_last_save_time DATE;
    l_object_type BSC_OBJECT_LOCKS.OBJECT_TYPE%TYPE;
    l_lowest_level_type BSC_OBJECT_LOCKS.OBJECT_TYPE%TYPE;
    l_machine BSC_OBJECT_LOCK_USERS.MACHINE%TYPE;
    l_terminal BSC_OBJECT_LOCK_USERS.TERMINAL%TYPE;

BEGIN
    --DBMS_OUTPUT.PUT_LINE('CHECK_SYSTEM_LOCK: '||p_object_key||' '||p_object_type);
    SAVEPOINT BSCLocksPubCheckSystemLock;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    BSC_LOCKS_PVT.Initialize;

    -- Get the machine and terminal information
    BSC_LOCKS_PVT.GET_SESSION
    (
        x_machine        => l_machine
       ,x_terminal       => l_terminal
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Check the top level object's lock
    BSC_LOCKS_PVT.LOCK_USER
    (
        p_object_key     => p_object_key
       ,p_object_type    => p_object_type
       ,p_user_type      => 'M'
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => l_machine
       ,p_terminal       => l_terminal
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    SAVEPOINT BSCLocksPubCheckAll1;
    BSC_LOCKS_PVT.LOCK_USER
    (
        p_object_key     => 'ALL'
       ,p_object_type    => 'ALL'
       ,p_user_type      => 'M'
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => l_machine
       ,p_terminal       => l_terminal
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );
    BSC_LOCKS_PVT.LOCK_USER
    (
        p_object_key     => 'ALL'
       ,p_object_type    => p_object_type
       ,p_user_type      => 'M'
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => l_machine
       ,p_terminal       => l_terminal
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );
    ROLLBACK TO BSCLocksPubCheckAll1;

    -- Find out the child objects
    l_lowest_level_type := NULL;
    IF (p_program_id = -203 OR p_object_type = 'CUSTOM_VIEW') THEN
        l_lowest_level_type := 'OBJECTIVE';
    END IF;
    BSC_LOCKS_PVT.GET_CHILD_OBJECTS
    (
        p_object_key         => p_object_key
       ,p_object_type        => p_object_type
       ,p_cascade_lock_level => p_cascade_lock_level
       ,p_lowest_level_type  => l_lowest_level_type
       ,x_child_object_keys  => l_child_object_keys
       ,x_child_object_types => l_child_object_types
       ,x_child_object_count => l_child_object_count
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
    );

    -- Check the child objects' locks
    l_object_type := p_object_type;
    FOR i IN 1..l_child_object_count LOOP
        BSC_LOCKS_PVT.LOCK_USER
        (
            p_object_key     => l_child_object_keys(i)
           ,p_object_type    => l_child_object_types(i)
           ,p_user_type      => 'M'
           ,p_program_id     => p_program_id
           ,p_user_id        => p_user_id
           ,p_machine        => l_machine
           ,p_terminal       => l_terminal
           ,x_return_status  => x_return_status
           ,x_msg_count      => x_msg_count
           ,x_msg_data       => x_msg_data
        );
        IF (l_object_type <> l_child_object_types(i)) THEN
            l_object_type := l_child_object_types(i);
            SAVEPOINT BSCLocksPubCheckAll2;
            BSC_LOCKS_PVT.LOCK_USER
            (
                p_object_key     => 'ALL'
               ,p_object_type    => l_object_type
               ,p_user_type      => 'M'
               ,p_program_id     => p_program_id
               ,p_user_id        => p_user_id
               ,p_machine        => l_machine
               ,p_terminal       => l_terminal
               ,x_return_status  => x_return_status
               ,x_msg_count      => x_msg_count
               ,x_msg_data       => x_msg_data
            );
            ROLLBACK TO BSCLocksPubCheckAll2;
        END IF;
    END LOOP;
    ROLLBACK TO BSCLocksPubCheckSystemLock;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCLocksPubCheckSystemLock;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BSCLocksPubCheckSystemLock;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO BSCLocksPubCheckSystemLock;
        FND_MSG_PUB.Add_Exc_Msg(
            G_PKG_NAME,
            l_api_name,
            SQLERRM
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
END CHECK_SYSTEM_LOCK;


/*------------------------------------------------------------------------------------------
Procedure CHECK_SYSTEM_LOCKS
        This procedure is called when users enter a UI flow.  It verifies that the
        Objects being modified are not locked.  If any of the Objects is locked,
        some other user is currently in the process of saving his changes to the database.
        As a result, the value retrieved from the database is still the old value.
        An error will be raised to indicate that the user has to wait until
        the save is completed.
  <parameters>
        p_object_keys: The primary key of the Objects, usually the TO_CHAR value
                       of the Object ID.  If the Object has composite keys,
                       the value to pass in will be a concatenation of
                       all the keys, separated by commas
        p_object_types: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                        "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                        "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                        "PERIODICITY", and "TABLE"
        p_program_id: -100 = Data Loader UI
                      -101 = Data Loader Backend
                      -200 = Generate Database
                      -201 = Generate Documentation
                      -202 = Rename Interface Table
                      -203 = Generate Database Configuration
                      -300 = Administrator
                      -400 = Objective Designer
                      -500 = Builder
                      -600 = Performance Scorecard
                      -700 = System Upgrade
                      -800 = System Migration
        p_user_id: Application User ID
        p_cascade_lock_level: Number of level for cascade locks
                              Default is -1 which means enable cascade locking
                              all the way to the lowest level
-------------------------------------------------------------------------------------------*/
Procedure  CHECK_SYSTEM_LOCKS (
          p_object_keys         IN             BSC_LOCK_OBJECT_KEY_LIST
         ,p_object_types        IN             BSC_LOCK_OBJECT_TYPE_LIST
         ,p_program_id          IN             number
         ,p_user_id             IN             number   := NULL
         ,p_cascade_lock_level  IN             number   := -1
         ,x_return_status       OUT NOCOPY     varchar2
         ,x_msg_count           OUT NOCOPY     number
         ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'CHECK_SYSTEM_LOCKS';

BEGIN
    --DBMS_OUTPUT.PUT_LINE('CHECK_SYSTEM_LOCKS');
    SAVEPOINT BSCLocksPubCheckSystemLocks;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    BSC_LOCKS_PVT.Initialize;

    IF (p_object_keys.COUNT <> 0 AND p_object_keys.COUNT = p_object_types.COUNT) THEN
        FOR i IN p_object_keys.FIRST..p_object_keys.LAST LOOP
            BSC_LOCKS_PUB.CHECK_SYSTEM_LOCK
            (
                p_object_key         => p_object_keys(i)
               ,p_object_type        => p_object_types(i)
               ,p_program_id         => p_program_id
               ,p_user_id            => p_user_id
               ,p_cascade_lock_level => p_cascade_lock_level
               ,x_return_status      => x_return_status
               ,x_msg_count          => x_msg_count
               ,x_msg_data           => x_msg_data
            );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                EXIT;
            END IF;
        END LOOP;
    END IF;
    ROLLBACK TO BSCLocksPubCheckSystemLocks;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCLocksPubCheckSystemLocks;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BSCLocksPubCheckSystemLocks;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO BSCLocksPubCheckSystemLocks;
        FND_MSG_PUB.Add_Exc_Msg(
            G_PKG_NAME,
            l_api_name,
            SQLERRM
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
END CHECK_SYSTEM_LOCKS;


/*------------------------------------------------------------------------------------------
Function GET_SYSTEM_TIME
        This function returns the current database system date.
        The system date will be cached by the calling module as the "Query Time",
        which will be used by BSC_LOCKS_PUB.Get_System_Lock to determine
        if a lock can be acquired on an Object.
  <parameters>
        none
-------------------------------------------------------------------------------------------*/
FUNCTION GET_SYSTEM_TIME
    RETURN DATE IS
BEGIN
    RETURN SYSDATE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END GET_SYSTEM_TIME;


/*------------------------------------------------------------------------------------------
Procedure SYNCHRONIZE
        This procedure removes the invalid and deleted Objects from the locking tables
        When we delete an Object or update the key value of an Object,
        the entries in the lock tables remain there.  After some time,
        more and more invalid rows will be in the lock tables.
        This SYNCHRONIZE api cleans up the lock tables and synchronizes the data
        with the latest metadata.  It will be called by the Generate Database
        concurrent request after the generation process has completed.
  <parameters>
        p_program_id: -100 = Data Loader UI
                      -101 = Data Loader Backend
                      -200 = Generate Database
                      -201 = Generate Documentation
                      -202 = Rename Interface Table
                      -203 = Generate Database Configuration
                      -300 = Administrator
                      -400 = Objective Designer
                      -500 = Builder
                      -600 = Performance Scorecard
                      -700 = System Upgrade
                      -800 = System Migration
        p_user_id: Application User ID
-------------------------------------------------------------------------------------------*/
PROCEDURE SYNCHRONIZE(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'SYNCHRONIZE';
    l_bsc_schema VARCHAR2(32);
    l_machine BSC_OBJECT_LOCK_USERS.MACHINE%TYPE;
    l_terminal BSC_OBJECT_LOCK_USERS.TERMINAL%TYPE;
    l_object_key BSC_OBJECT_LOCKS.OBJECT_KEY%TYPE;
    l_object_type BSC_OBJECT_LOCKS.OBJECT_TYPE%TYPE;

    CURSOR c_get_invalid_objects
    IS
        SELECT DISTINCT OBJECT_TYPE, OBJECT_KEY
        FROM   BSC_OBJECT_LOCKS
        WHERE  OBJECT_KEY <> 'ALL'
        AND  ((OBJECT_TYPE = 'OBJECTIVE' AND
               OBJECT_KEY NOT IN (
                   SELECT TO_CHAR(INDICATOR)
                   FROM BSC_KPIS_B))
        OR    (OBJECT_TYPE = 'SCORECARD' AND
               OBJECT_KEY NOT IN (
                   SELECT TO_CHAR(TAB_ID)
                   FROM BSC_TABS_B))
        OR    (OBJECT_TYPE = 'DIMENSION' AND
               OBJECT_KEY NOT IN (
                   SELECT TO_CHAR(DIM_GROUP_ID)
                   FROM BSC_SYS_DIM_GROUPS_TL))
        OR    (OBJECT_TYPE = 'DIMENSION_OBJECT' AND
               OBJECT_KEY NOT IN (
                   SELECT TO_CHAR(DIM_LEVEL_ID)
                   FROM BSC_SYS_DIM_LEVELS_B
                   UNION
                   SELECT LEVEL_TABLE_NAME
                   FROM BSC_SYS_DIM_LEVELS_B))
        OR    (OBJECT_TYPE = 'MEASURE' AND
               OBJECT_KEY NOT IN (
                   SELECT TO_CHAR(DATASET_ID)
                   FROM BSC_SYS_DATASETS_B))
        OR    (OBJECT_TYPE = 'DATA_COLUMN' AND
               OBJECT_KEY NOT IN (
                   SELECT TO_CHAR(MEASURE_ID)
                   FROM BSC_SYS_MEASURES))
        OR    (OBJECT_TYPE = 'CUSTOM_VIEW' AND
               OBJECT_KEY NOT IN (
                   SELECT TO_CHAR(TAB_ID)||','||TO_CHAR(TAB_VIEW_ID)
                   FROM BSC_TAB_VIEWS_B))
        OR    (OBJECT_TYPE = 'LAUNCHPAD' AND
               OBJECT_KEY NOT IN (
                   SELECT TO_CHAR(MENU_ID)
                   FROM FND_MENUS))
        OR    (OBJECT_TYPE = 'PERIODICITY' AND
               OBJECT_KEY NOT IN (
                   SELECT TO_CHAR(PERIODICITY_ID)
                   FROM BSC_SYS_PERIODICITIES))
        OR    (OBJECT_TYPE = 'CALENDAR' AND
               OBJECT_KEY NOT IN (
                   SELECT TO_CHAR(CALENDAR_ID)
                   FROM BSC_SYS_CALENDARS_B))
        OR    (OBJECT_TYPE = 'TABLE' AND
               OBJECT_KEY NOT IN (
                   SELECT TABLE_NAME
                   FROM BSC_DB_TABLES))
        OR    (OBJECT_TYPE NOT IN (
                   'SCORECARD',
                   'OBJECTIVE',
                   'DIMENSION',
                   'DIMENSION_OBJECT',
                   'MEASURE',
                   'DATA_COLUMN',
                   'CUSTOM_VIEW',
                   'LAUNCHPAD',
                   'PERIODICITY',
                   'CALENDAR',
                   'TABLE')));

BEGIN
    --DBMS_OUTPUT.PUT_LINE('SYNCHRONIZE');
    SAVEPOINT BSCLocksPubSynchronize;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    BSC_LOCKS_PVT.Initialize;
    l_bsc_schema := BSC_LOCKS_PVT.GET_BSC_SCHEMA;

    -- Get the machine and terminal information
    BSC_LOCKS_PVT.GET_SESSION
    (
        x_machine        => l_machine
       ,x_terminal       => l_terminal
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Find out the invalid objects
    FOR cobj IN c_get_invalid_objects LOOP
        l_object_type := cobj.OBJECT_TYPE;
        l_object_key := cobj.OBJECT_KEY;
        --DBMS_OUTPUT.PUT_LINE('Invalid Object: '||l_object_type||' '||l_object_key);
        BEGIN
            -- Lock the invalid object
            BSC_LOCKS_PVT.DELETE_LOCK_INFO
            (
                p_object_key     => l_object_key
               ,p_object_type    => l_object_type
               ,p_program_id     => p_program_id
               ,p_user_id        => p_user_id
               ,p_machine        => l_machine
               ,p_terminal       => l_terminal
               ,x_return_status  => x_return_status
               ,x_msg_count      => x_msg_count
               ,x_msg_data       => x_msg_data
            );
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
    END LOOP;

    ---- Check the Lock in the lock table
    --SAVEPOINT BSCLocksPubLockObjectAll;
    --BSC_LOCKS_PVT.LOCK_OBJECT_ALL
    --(
    --    x_return_status  => x_return_status
    --   ,x_msg_count      => x_msg_count
    --   ,x_msg_data       => x_msg_data
    --);
    --ROLLBACK TO BSCLocksPubLockObjectAll;
    --
    ---- Truncate the lock table
    --IF (l_bsc_schema IS NULL) THEN
    --    EXECUTE IMMEDIATE ('TRUNCATE TABLE BSC_OBJECT_LOCKS');
    --    EXECUTE IMMEDIATE ('TRUNCATE TABLE BSC_OBJECT_LOCK_USERS');
    --ELSE
    --    EXECUTE IMMEDIATE ('TRUNCATE TABLE '||l_bsc_schema||'.BSC_OBJECT_LOCKS');
    --    EXECUTE IMMEDIATE ('TRUNCATE TABLE '||l_bsc_schema||'.BSC_OBJECT_LOCK_USERS');
    --END IF;
    --
    ---- Create the entries for "ALL"
    --BSC_LOCKS_PVT.INSERT_LOCK_ALL_AUTONOMOUS
    --(
    --    p_object_type    => 'ALL'
    --   ,p_program_id     => p_program_id
    --   ,p_user_id        => p_user_id
    --   ,p_machine        => l_machine
    --   ,p_terminal       => l_terminal
    --   ,p_session_id     => USERENV('SESSIONID')
    --   ,x_return_status  => x_return_status
    --   ,x_msg_count      => x_msg_count
    --   ,x_msg_data       => x_msg_data
    --);
    --
    ---- Lock the lock table
    --BSC_LOCKS_PVT.LOCK_OBJECT_ALL
    --(
    --    x_return_status  => x_return_status
    --   ,x_msg_count      => x_msg_count
    --   ,x_msg_data       => x_msg_data
    --);
    --
    ---- Insert Scorecards
    --BSC_LOCKS_PVT.INSERT_LOCK_SCORECARD
    --(
    --    p_program_id     => p_program_id
    --   ,p_user_id        => p_user_id
    --   ,p_machine        => l_machine
    --   ,p_terminal       => l_terminal
    --   ,x_return_status  => x_return_status
    --   ,x_msg_count      => x_msg_count
    --   ,x_msg_data       => x_msg_data
    --);
    --
    ---- Insert Objectives
    --BSC_LOCKS_PVT.INSERT_LOCK_OBJECTIVE
    --(
    --    p_program_id     => p_program_id
    --   ,p_user_id        => p_user_id
    --   ,p_machine        => l_machine
    --   ,p_terminal       => l_terminal
    --   ,x_return_status  => x_return_status
    --   ,x_msg_count      => x_msg_count
    --   ,x_msg_data       => x_msg_data
    --);
    --
    ---- Insert Dimensions
    --BSC_LOCKS_PVT.INSERT_LOCK_DIMENSION
    --(
    --    p_program_id     => p_program_id
    --   ,p_user_id        => p_user_id
    --   ,p_machine        => l_machine
    --   ,p_terminal       => l_terminal
    --   ,x_return_status  => x_return_status
    --   ,x_msg_count      => x_msg_count
    --   ,x_msg_data       => x_msg_data
    --);
    --
    ---- Insert Dimension Objects
    --BSC_LOCKS_PVT.INSERT_LOCK_DIMENSION_OBJECT
    --(
    --    p_program_id     => p_program_id
    --   ,p_user_id        => p_user_id
    --   ,p_machine        => l_machine
    --   ,p_terminal       => l_terminal
    --   ,x_return_status  => x_return_status
    --   ,x_msg_count      => x_msg_count
    --   ,x_msg_data       => x_msg_data
    --);
    --
    ---- Insert Measures
    --BSC_LOCKS_PVT.INSERT_LOCK_MEASURE
    --(
    --    p_program_id     => p_program_id
    --   ,p_user_id        => p_user_id
    --   ,p_machine        => l_machine
    --   ,p_terminal       => l_terminal
    --   ,x_return_status  => x_return_status
    --   ,x_msg_count      => x_msg_count
    --   ,x_msg_data       => x_msg_data
    --);
    --
    ---- Insert Data Columns
    --BSC_LOCKS_PVT.INSERT_LOCK_DATA_COLUMN
    --(
    --    p_program_id     => p_program_id
    --   ,p_user_id        => p_user_id
    --   ,p_machine        => l_machine
    --   ,p_terminal       => l_terminal
    --   ,x_return_status  => x_return_status
    --   ,x_msg_count      => x_msg_count
    --   ,x_msg_data       => x_msg_data
    --);
    --
    ---- Insert Custom Views
    --BSC_LOCKS_PVT.INSERT_LOCK_CUSTOM_VIEW
    --(
    --    p_program_id     => p_program_id
    --   ,p_user_id        => p_user_id
    --   ,p_machine        => l_machine
    --   ,p_terminal       => l_terminal
    --   ,x_return_status  => x_return_status
    --   ,x_msg_count      => x_msg_count
    --   ,x_msg_data       => x_msg_data
    --);
    --
    ---- Insert Launchpads
    --BSC_LOCKS_PVT.INSERT_LOCK_LAUNCHPAD
    --(
    --    p_program_id     => p_program_id
    --   ,p_user_id        => p_user_id
    --   ,p_machine        => l_machine
    --   ,p_terminal       => l_terminal
    --   ,x_return_status  => x_return_status
    --   ,x_msg_count      => x_msg_count
    --   ,x_msg_data       => x_msg_data
    --);
    --
    ---- Insert Periodicities
    --BSC_LOCKS_PVT.INSERT_LOCK_PERIODICITY
    --(
    --    p_program_id     => p_program_id
    --   ,p_user_id        => p_user_id
    --   ,p_machine        => l_machine
    --   ,p_terminal       => l_terminal
    --   ,x_return_status  => x_return_status
    --   ,x_msg_count      => x_msg_count
    --   ,x_msg_data       => x_msg_data
    --);
    --
    ---- Insert Calendars
    --BSC_LOCKS_PVT.INSERT_LOCK_CALENDAR
    --(
    --    p_program_id     => p_program_id
    --   ,p_user_id        => p_user_id
    --   ,p_machine        => l_machine
    --   ,p_terminal       => l_terminal
    --   ,x_return_status  => x_return_status
    --   ,x_msg_count      => x_msg_count
    --   ,x_msg_data       => x_msg_data
    --);
    --
    ---- Insert Tables
    --BSC_LOCKS_PVT.INSERT_LOCK_TABLE
    --(
    --    p_program_id     => p_program_id
    --   ,p_user_id        => p_user_id
    --   ,p_machine        => l_machine
    --   ,p_terminal       => l_terminal
    --   ,x_return_status  => x_return_status
    --   ,x_msg_count      => x_msg_count
    --   ,x_msg_data       => x_msg_data
    --);

    COMMIT;
    -- Gather Table Stats
    DBMS_STATS.GATHER_TABLE_STATS(NVL(l_bsc_schema, 'BSC'), 'BSC_OBJECT_LOCKS');
    DBMS_STATS.GATHER_TABLE_STATS(NVL(l_bsc_schema, 'BSC'), 'BSC_OBJECT_LOCK_USERS');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCLocksPubSynchronize;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BSCLocksPubSynchronize;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO BSCLocksPubSynchronize;
        FND_MSG_PUB.Add_Exc_Msg(
            G_PKG_NAME,
            l_api_name,
            SQLERRM
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
END SYNCHRONIZE;


/*------------------------------------------------------------------------------------------
Procedure GET_SYSTEN_LOCK
        This procedure replaces the existing API BSC_SECURITY.Check_System_Lock
        to be the locking procedure for BSC modules.  Instead of calling the API
        at the start of the process flow, this new API will be called right
        before the changes are committed to the database.

        Passing in the key and type of the top-level object, this API will
        figure out all the related objects that needed to be locked.
        If the locks cannot be acquired, either because some other users
        are possessing one of more of the required locks or the data
        has been modified since the last query time, an exception will be raised
        indicating that the user has to requery and re-do the changes.
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        p_lock_type: 'W' for write lock, 'R' for read lock
        p_query_time: The query time at the start of the process flow
        p_program_id: -100 = Data Loader UI
                      -101 = Data Loader Backend
                      -200 = Generate Database
                      -201 = Generate Documentation
                      -202 = Rename Interface Table
                      -203 = Generate Database Configuration
                      -300 = Administrator
                      -400 = Objective Designer
                      -500 = Builder
                      -600 = Performance Scorecard
                      -700 = System Upgrade
                      -800 = System Migration
        p_user_id: Application User ID
        p_cascade_lock_level: Number of level for cascade locks
                              Default is -1 which means enable cascade locking
                              all the way to the lowest level
-------------------------------------------------------------------------------------------*/
PROCEDURE GET_SYSTEM_LOCK(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_lock_type           IN             varchar2 := 'W'
   ,p_query_time          IN             date
   ,p_program_id          IN             number
   ,p_user_id             IN             number   := NULL
   ,p_cascade_lock_level  IN             number   := -1
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'GET_SYSTEM_LOCK';
    l_child_object_keys BSC_LOCKS_PVT.t_array_object_key;
    l_child_object_types BSC_LOCKS_PVT.t_array_object_type;
    l_child_object_count NUMBER := 0;
    l_last_save_time DATE;
    l_lowest_level_type BSC_OBJECT_LOCKS.OBJECT_TYPE%TYPE;
    l_machine BSC_OBJECT_LOCK_USERS.MACHINE%TYPE;
    l_terminal BSC_OBJECT_LOCK_USERS.TERMINAL%TYPE;
    l_session_id NUMBER := USERENV('SESSIONID');

BEGIN
    --DBMS_OUTPUT.PUT_LINE('GET_SYSTEM_LOCK: '||p_object_key||' '||p_object_type||' '||p_lock_type);
    SAVEPOINT BSCLocksPubGetSystemLock;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    BSC_LOCKS_PVT.Initialize;

    -- Validate the top level object
    --BSC_LOCKS_PVT.VALIDATE_OBJECT
    --(
    --    p_object_key     => p_object_key
    --   ,p_object_type    => p_object_type
    --   ,x_return_status  => x_return_status
    --   ,x_msg_count      => x_msg_count
    --   ,x_msg_data       => x_msg_data
    --);

    -- Get the machine and terminal information
    BSC_LOCKS_PVT.GET_SESSION
    (
        x_machine        => l_machine
       ,x_terminal       => l_terminal
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Lock the user entry for the top level object
    IF (p_lock_type <> 'R') THEN
        BSC_LOCKS_PVT.LOCK_USER
        (
            p_object_key     => p_object_key
           ,p_object_type    => p_object_type
           ,p_user_type      => 'M'
           ,p_program_id     => p_program_id
           ,p_user_id        => p_user_id
           ,p_machine        => l_machine
           ,p_terminal       => l_terminal
           ,x_return_status  => x_return_status
           ,x_msg_count      => x_msg_count
           ,x_msg_data       => x_msg_data
        );
    END IF;

    -- Lock the top level object
    l_last_save_time :=
        BSC_LOCKS_PVT.LOCK_OBJECT
        (
            p_object_key     => p_object_key
           ,p_object_type    => p_object_type
           ,p_lock_type      => p_lock_type
           ,p_query_time     => p_query_time
           ,p_program_id     => p_program_id
           ,p_user_id        => p_user_id
           ,p_machine        => l_machine
           ,p_terminal       => l_terminal
           ,x_return_status  => x_return_status
           ,x_msg_count      => x_msg_count
           ,x_msg_data       => x_msg_data
        );

    -- Find out the child objects
    l_lowest_level_type := NULL;
    IF (p_program_id = -203 OR p_object_type = 'CUSTOM_VIEW') THEN
        l_lowest_level_type := 'OBJECTIVE';
    END IF;
    BSC_LOCKS_PVT.GET_CHILD_OBJECTS
    (
        p_object_key         => p_object_key
       ,p_object_type        => p_object_type
       ,p_cascade_lock_level => p_cascade_lock_level
       ,p_lowest_level_type  => l_lowest_level_type
       ,x_child_object_keys  => l_child_object_keys
       ,x_child_object_types => l_child_object_types
       ,x_child_object_count => l_child_object_count
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
    );

    -- Lock the child objects
    FOR i IN 1..l_child_object_count LOOP
        l_last_save_time :=
            BSC_LOCKS_PVT.LOCK_OBJECT
            (
                p_object_key     => l_child_object_keys(i)
               ,p_object_type    => l_child_object_types(i)
               ,p_lock_type      => p_lock_type
               ,p_query_time     => p_query_time
               ,p_program_id     => p_program_id
               ,p_user_id        => p_user_id
               ,p_machine        => l_machine
               ,p_terminal       => l_terminal
               ,x_return_status  => x_return_status
               ,x_msg_count      => x_msg_count
               ,x_msg_data       => x_msg_data
            );
    END LOOP;

    IF (p_lock_type <> 'R') THEN
        -- Update the user information
        BSC_LOCKS_PVT.UPDATE_USER_INFO
        (
            p_object_key     => p_object_key
           ,p_object_type    => p_object_type
           ,p_user_type      => 'M'
           ,p_program_id     => p_program_id
           ,p_user_id        => p_user_id
           ,p_machine        => l_machine
           ,p_terminal       => l_terminal
           ,x_return_status  => x_return_status
           ,x_msg_count      => x_msg_count
           ,x_msg_data       => x_msg_data
        );

        -- Update last_save_time
        BSC_LOCKS_PVT.UPDATE_LOCK_INFO
        (
            p_object_key     => p_object_key
           ,p_object_type    => p_object_type
           ,p_lock_type      => p_lock_type
           ,p_last_save_time => SYSDATE
           ,p_session_id     => l_session_id
           ,x_return_status  => x_return_status
           ,x_msg_count      => x_msg_count
           ,x_msg_data       => x_msg_data
        );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCLocksPubGetSystemLock;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BSCLocksPubGetSystemLock;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO BSCLocksPubGetSystemLock;
        FND_MSG_PUB.Add_Exc_Msg(
            G_PKG_NAME,
            l_api_name,
            SQLERRM
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
END GET_SYSTEM_LOCK;


/*------------------------------------------------------------------------------------------
Procedure GET_SYSTEN_LOCKS
        This procedure replaces the existing API BSC_SECURITY.Check_System_Lock
        to be the locking procedure for BSC modules.  Instead of calling the API
        at the start of the process flow, this new API will be called right
        before the changes are committed to the database.

        Passing in the keys and types of the top-level objects, this API will
        figure out all the related objects that needed to be locked.
        If the locks cannot be acquired, either because some other users
        are possessing one of more of the required locks or the data
        has been modified since the last query time, an exception will be raised
        indicating that the user has to requery and re-do the changes.
  <parameters>
        p_object_keys: The primary key of the Objects, usually the TO_CHAR value
                       of the Object IDs.  If the Object has composite keys,
                       the value to pass in will be a concatenation of
                       all the keys, separated by commas
        p_object_types: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                        "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                        "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                        "PERIODICITY", and "TABLE"
        p_lock_type: 'W' for write lock, 'R' for read lock
        p_query_time: The query time at the start of the process flow
        p_program_id: -100 = Data Loader UI
                      -101 = Data Loader Backend
                      -200 = Generate Database
                      -201 = Generate Documentation
                      -202 = Rename Interface Table
                      -203 = Generate Database Configuration
                      -300 = Administrator
                      -400 = Objective Designer
                      -500 = Builder
                      -600 = Performance Scorecard
                      -700 = System Upgrade
                      -800 = System Migration
        p_user_id: Application User ID
        p_cascade_lock_level: Number of level for cascade locks
                              Default is -1 which means enable cascade locking
                              all the way to the lowest level
-------------------------------------------------------------------------------------------*/
Procedure GET_SYSTEM_LOCKS (
          p_object_keys         IN             BSC_LOCK_OBJECT_KEY_LIST
         ,p_object_types        IN             BSC_LOCK_OBJECT_TYPE_LIST
         ,p_lock_type           IN             varchar2 := 'W'
         ,p_query_time          IN             date
         ,p_program_id          IN             number
         ,p_user_id             IN             number   := NULL
         ,p_cascade_lock_level  IN             number   := -1
         ,x_return_status       OUT NOCOPY     varchar2
         ,x_msg_count           OUT NOCOPY     number
         ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'GET_SYSTEM_LOCKS';

BEGIN
    --DBMS_OUTPUT.PUT_LINE('GET_SYSTEM_LOCKS');
    SAVEPOINT BSCLocksPubGetSystemLocks;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    BSC_LOCKS_PVT.Initialize;

    IF (p_object_keys.COUNT <> 0 AND
        p_object_keys.COUNT = p_object_types.COUNT) THEN
        FOR i IN p_object_keys.FIRST..p_object_keys.LAST LOOP
            FOR j IN p_object_keys.FIRST..i LOOP
                IF (i = j) THEN
                    BSC_LOCKS_PUB.GET_SYSTEM_LOCK
                    (
                        p_object_key         => p_object_keys(i)
                       ,p_object_type        => p_object_types(i)
                       ,p_lock_type          => p_lock_type
                       ,p_query_time         => p_query_time
                       ,p_program_id         => p_program_id
                       ,p_user_id            => p_user_id
                       ,p_cascade_lock_level => p_cascade_lock_level
                       ,x_return_status      => x_return_status
                       ,x_msg_count          => x_msg_count
                       ,x_msg_data           => x_msg_data
                    );
                    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                        RAISE FND_API.G_EXC_ERROR;
                    ELSIF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                ELSIF (p_object_keys(i) = p_object_keys(j) AND
                       p_object_types(i) = p_object_types(j)) THEN
                    EXIT;
                END IF;
            END LOOP;
        END LOOP;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCLocksPubGetSystemLocks;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BSCLocksPubGetSystemLocks;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO BSCLocksPubGetSystemLocks;
        FND_MSG_PUB.Add_Exc_Msg(
            G_PKG_NAME,
            l_api_name,
            SQLERRM
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
END GET_SYSTEM_LOCKS;


/*------------------------------------------------------------------------------------------
Procedure GET_SYSTEN_LOCKS
        This procedure replaces the existing API BSC_SECURITY.Check_System_Lock
        to be the locking procedure for BSC modules.  Instead of calling the API
        at the start of the process flow, this new API will be called right
        before the changes are committed to the database.

        Passing in the keys and types of the top-level objects, this API will
        figure out all the related objects that needed to be locked.
        If the locks cannot be acquired, either because some other users
        are possessing one of more of the required locks or the data
        has been modified since the last query time, an exception will be raised
        indicating that the user has to requery and re-do the changes.
  <parameters>
        p_object_keys: The primary key of the Objects, usually the TO_CHAR value
                       of the Object IDs.  If the Object has composite keys,
                       the value to pass in will be a concatenation of
                       all the keys, separated by commas
        p_object_types: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                        "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                        "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                        "PERIODICITY", and "TABLE"
        p_lock_types: 'W' for write lock, 'R' for read lock
        p_query_time: The query time at the start of the process flow
        p_program_id: -100 = Data Loader UI
                      -101 = Data Loader Backend
                      -200 = Generate Database
                      -201 = Generate Documentation
                      -202 = Rename Interface Table
                      -203 = Generate Database Configuration
                      -300 = Administrator
                      -400 = Objective Designer
                      -500 = Builder
                      -600 = Performance Scorecard
                      -700 = System Upgrade
                      -800 = System Migration
        p_user_id: Application User ID
        p_cascade_lock_level: Number of level for cascade locks
                              Default is -1 which means enable cascade locking
                              all the way to the lowest level
-------------------------------------------------------------------------------------------*/
Procedure  GET_SYSTEM_LOCKS (
          p_object_keys         IN             BSC_LOCK_OBJECT_KEY_LIST
         ,p_object_types        IN             BSC_LOCK_OBJECT_TYPE_LIST
         ,p_lock_types          IN             BSC_LOCK_LOCK_TYPE_LIST
         ,p_query_time          IN             date
         ,p_program_id          IN             number
         ,p_user_id             IN             number   := NULL
         ,p_cascade_lock_level  IN             number   := -1
         ,x_return_status       OUT NOCOPY     varchar2
         ,x_msg_count           OUT NOCOPY     number
         ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'GET_SYSTEM_LOCKS';

BEGIN
    --DBMS_OUTPUT.PUT_LINE('GET_SYSTEM_LOCKS');
    SAVEPOINT BSCLocksPubGetSystemLocks;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    BSC_LOCKS_PVT.Initialize;

    IF (p_object_keys.COUNT <> 0 AND
        p_object_keys.COUNT = p_object_types.COUNT AND
        p_object_keys.COUNT = p_lock_types.COUNT) THEN
        FOR i IN p_object_keys.FIRST..p_object_keys.LAST LOOP
            IF (p_lock_types(i) = 'W') THEN
                FOR j IN p_object_keys.FIRST..i LOOP
                    IF (i = j) THEN
                        BSC_LOCKS_PUB.GET_SYSTEM_LOCK
                        (
                            p_object_key         => p_object_keys(i)
                           ,p_object_type        => p_object_types(i)
                           ,p_lock_type          => p_lock_types(i)
                           ,p_query_time         => p_query_time
                           ,p_program_id         => p_program_id
                           ,p_user_id            => p_user_id
                           ,p_cascade_lock_level => p_cascade_lock_level
                           ,x_return_status      => x_return_status
                           ,x_msg_count          => x_msg_count
                           ,x_msg_data           => x_msg_data
                        );
                        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                            RAISE FND_API.G_EXC_ERROR;
                        ELSIF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                    ELSIF (p_lock_types(j) = 'W' AND
                           p_object_keys(i) = p_object_keys(j) AND
                           p_object_types(i) = p_object_types(j)) THEN
                        EXIT;
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
        FOR i IN p_object_keys.FIRST..p_object_keys.LAST LOOP
            IF (p_lock_types(i) <> 'W') THEN
                FOR j IN p_object_keys.FIRST..i LOOP
                    IF (i = j) THEN
                        BSC_LOCKS_PUB.GET_SYSTEM_LOCK
                        (
                            p_object_key         => p_object_keys(i)
                           ,p_object_type        => p_object_types(i)
                           ,p_lock_type          => p_lock_types(i)
                           ,p_query_time         => p_query_time
                           ,p_program_id         => p_program_id
                           ,p_user_id            => p_user_id
                           ,p_cascade_lock_level => p_cascade_lock_level
                           ,x_return_status      => x_return_status
                           ,x_msg_count          => x_msg_count
                           ,x_msg_data           => x_msg_data
                        );
                        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                            RAISE FND_API.G_EXC_ERROR;
                        ELSIF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                    ELSIF (p_object_keys(i) = p_object_keys(j) AND
                           p_object_types(i) = p_object_types(j)) THEN
                        EXIT;
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCLocksPubGetSystemLocks;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BSCLocksPubGetSystemLocks;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO BSCLocksPubGetSystemLocks;
        FND_MSG_PUB.Add_Exc_Msg(
            G_PKG_NAME,
            l_api_name,
            SQLERRM
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
END GET_SYSTEM_LOCKS;


/*------------------------------------------------------------------------------------------
Procedure GET_SYSTEN_LOCK
        This procedure locks all the objects with a certain type
  <parameters>
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        p_lock_type: 'W' for write lock, 'R' for read lock
        p_query_time: The query time at the start of the process flow
        p_program_id: -100 = Data Loader UI
                      -101 = Data Loader Backend
                      -200 = Generate Database
                      -201 = Generate Documentation
                      -202 = Rename Interface Table
                      -203 = Generate Database Configuration
                      -300 = Administrator
                      -400 = Objective Designer
                      -500 = Builder
                      -600 = Performance Scorecard
                      -700 = System Upgrade
                      -800 = System Migration
        p_user_id: Application User ID
        p_cascade_lock_level: Number of level for cascade locks
                              Default is -1 which means enable cascade locking
                              all the way to the lowest level
-------------------------------------------------------------------------------------------*/
Procedure  GET_SYSTEM_LOCK (
          p_object_type         IN             varchar2
         ,p_lock_type           IN             varchar2 := 'W'
         ,p_query_time          IN             date
         ,p_program_id          IN             number
         ,p_user_id             IN             number   := NULL
         ,p_cascade_lock_level  IN             number   := -1
         ,x_return_status       OUT NOCOPY     varchar2
         ,x_msg_count           OUT NOCOPY     number
         ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'GET_SYSTEM_LOCK';
    l_machine BSC_OBJECT_LOCK_USERS.MACHINE%TYPE;
    l_terminal BSC_OBJECT_LOCK_USERS.TERMINAL%TYPE;
    l_session_id NUMBER := USERENV('SESSIONID');

    CURSOR c_get_object(
        c_object_type VARCHAR2
    ) IS
        SELECT DISTINCT OBJECT_KEY
        FROM   BSC_OBJECT_LOCKS
        WHERE  OBJECT_TYPE = c_object_type;

BEGIN
    --DBMS_OUTPUT.PUT_LINE('GET_SYSTEM_LOCK: '||p_object_type);
    SAVEPOINT BSCLocksPubGetSystemLock;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    BSC_LOCKS_PVT.Initialize;

    -- Get the machine and terminal information
    BSC_LOCKS_PVT.GET_SESSION
    (
        x_machine        => l_machine
       ,x_terminal       => l_terminal
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Lock the user entry for the top level object
    IF (p_lock_type <> 'R') THEN
        BSC_LOCKS_PVT.LOCK_USER
        (
            p_object_key     => 'ALL'
           ,p_object_type    => p_object_type
           ,p_user_type      => 'M'
           ,p_program_id     => p_program_id
           ,p_user_id        => p_user_id
           ,p_machine        => l_machine
           ,p_terminal       => l_terminal
           ,x_return_status  => x_return_status
           ,x_msg_count      => x_msg_count
           ,x_msg_data       => x_msg_data
        );
    END IF;

    -- Lock the object
    BSC_LOCKS_PVT.LOCK_OBJECT
    (
        p_object_type        => p_object_type
       ,p_lock_type          => p_lock_type
       ,p_query_time         => p_query_time
       ,p_program_id         => p_program_id
       ,p_user_id            => p_user_id
       ,p_machine            => l_machine
       ,p_terminal           => l_terminal
       ,p_cascade_lock_level => p_cascade_lock_level
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
    );

    IF (p_lock_type <> 'R') THEN
        FOR cobj IN c_get_object(p_object_type) LOOP
            -- Update the user information
            BSC_LOCKS_PVT.UPDATE_USER_INFO
            (
                p_object_key     => cobj.OBJECT_KEY
               ,p_object_type    => p_object_type
               ,p_user_type      => 'M'
               ,p_program_id     => p_program_id
               ,p_user_id        => p_user_id
               ,p_machine        => l_machine
               ,p_terminal       => l_terminal
               ,x_return_status  => x_return_status
               ,x_msg_count      => x_msg_count
               ,x_msg_data       => x_msg_data
            );

            -- Update last_save_time
            BSC_LOCKS_PVT.UPDATE_LOCK_INFO
            (
                p_object_key     => cobj.OBJECT_KEY
               ,p_object_type    => p_object_type
               ,p_lock_type      => p_lock_type
               ,p_last_save_time => SYSDATE
               ,p_session_id     => l_session_id
               ,x_return_status  => x_return_status
               ,x_msg_count      => x_msg_count
               ,x_msg_data       => x_msg_data
            );
        END LOOP;
    END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCLocksPubGetSystemLock;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BSCLocksPubGetSystemLock;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO BSCLocksPubGetSystemLock;
        FND_MSG_PUB.Add_Exc_Msg(
            G_PKG_NAME,
            l_api_name,
            SQLERRM
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
END GET_SYSTEM_LOCK;


/*------------------------------------------------------------------------------------------
Procedure GET_SYSTEN_LOCK
        This procedure lock the whole table.  This feature is used in Migration.
  <parameters>
        p_program_id: -100 = Data Loader UI
                      -101 = Data Loader Backend
                      -200 = Generate Database
                      -201 = Generate Documentation
                      -202 = Rename Interface Table
                      -203 = Generate Database Configuration
                      -300 = Administrator
                      -400 = Objective Designer
                      -500 = Builder
                      -600 = Performance Scorecard
                      -700 = System Upgrade
                      -800 = System Migration
        p_user_id: Application User ID
-------------------------------------------------------------------------------------------*/
PROCEDURE GET_SYSTEM_LOCK(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'GET_SYSTEM_LOCK';
    l_last_save_time BSC_OBJECT_LOCKS.LAST_SAVE_TIME%TYPE;
    l_machine BSC_OBJECT_LOCK_USERS.MACHINE%TYPE;
    l_terminal BSC_OBJECT_LOCK_USERS.TERMINAL%TYPE;
    l_insert_flag BOOLEAN;
    l_session_id NUMBER := USERENV('SESSIONID');

    CURSOR c_locate_object(
        c_object_key VARCHAR2,
        c_object_type VARCHAR2,
        c_lock_type VARCHAR2
    ) IS
        SELECT LAST_SAVE_TIME
        FROM   BSC_OBJECT_LOCKS
        WHERE  OBJECT_KEY = c_object_key
        AND    OBJECT_TYPE = c_object_type
        AND    LOCK_TYPE = c_lock_type;

BEGIN
    --DBMS_OUTPUT.PUT_LINE('GET_SYSTEM_LOCK');
    SAVEPOINT BSCLocksPubGetSystemLock;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    BSC_LOCKS_PVT.Initialize;
    l_insert_flag := FALSE;

    -- Get the machine and terminal information
    BSC_LOCKS_PVT.GET_SESSION
    (
        x_machine        => l_machine
       ,x_terminal       => l_terminal
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Create the entries for "ALL"
    OPEN c_locate_object('ALL', 'ALL', 'W');
    FETCH c_locate_object INTO l_last_save_time;
    l_insert_flag := (c_locate_object%NOTFOUND);
    CLOSE c_locate_object;
    IF (l_insert_flag) THEN
        BSC_LOCKS_PVT.INSERT_LOCK_ALL_AUTONOMOUS
        (
            p_object_type    => 'ALL'
           ,p_program_id     => p_program_id
           ,p_user_id        => p_user_id
           ,p_machine        => l_machine
           ,p_terminal       => l_terminal
           ,p_session_id     => l_session_id
           ,x_return_status  => x_return_status
           ,x_msg_count      => x_msg_count
           ,x_msg_data       => x_msg_data
        );
    END IF;

    -- Lock the user entry
    BSC_LOCKS_PVT.LOCK_USER
    (
        p_object_key     => 'ALL'
       ,p_object_type    => 'ALL'
       ,p_user_type      => 'M'
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => l_machine
       ,p_terminal       => l_terminal
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Check the Lock in the lock table
    SAVEPOINT BSCLocksPubLockObjectAll;
    BSC_LOCKS_PVT.LOCK_OBJECT_ALL
    (
        x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );
    ROLLBACK TO BSCLocksPubLockObjectAll;

    -- Update the user information for 'ALL'
    BSC_LOCKS_PVT.UPDATE_USER_INFO_AUTONOMOUS
    (
        p_object_key     => 'ALL'
       ,p_object_type    => 'ALL'
       ,p_user_type      => 'L'
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => l_machine
       ,p_terminal       => l_terminal
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Lock the lock table
    BSC_LOCKS_PVT.LOCK_OBJECT_ALL
    (
        x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Update the user information
    BSC_LOCKS_PVT.UPDATE_USER_INFO
    (
        p_object_key     => 'ALL'
       ,p_object_type    => 'ALL'
       ,p_user_type      => 'ALL'
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => l_machine
       ,p_terminal       => l_terminal
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Update last_save_time
    BSC_LOCKS_PVT.UPDATE_LOCK_INFO
    (
        p_object_key     => 'ALL'
       ,p_object_type    => 'ALL'
       ,p_lock_type      => 'ALL'
       ,p_last_save_time => SYSDATE
       ,p_session_id     => l_session_id
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCLocksPubGetSystemLock;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BSCLocksPubGetSystemLock;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO BSCLocksPubGetSystemLock;
        FND_MSG_PUB.Add_Exc_Msg(
            G_PKG_NAME,
            l_api_name,
            SQLERRM
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
END GET_SYSTEM_LOCK;


/*------------------------------------------------------------------------------------------
Procedure GET_SYSTEM_LOCK
        Due to the fact that not all the BSC modules will uptake the new locking scheme
        immediately, we will temporaily keep populating the BSC_CURRENT_SESSIONS table
        for backward compatibility issues.  In this procedure, we will check for whole
        system exclusive locks acquired by modules that haven't uptaken the new
        locking scheme.  Only when none of these modules have acquired locks that
        the new Object-Level locking will be proceeded.  Next, a row will be inserted
        into BSC_CURRENT_SESSIONS.  It will be seen as a whole system exclusive lock by
        modules haven't implemented the new locking scheme.  For modules that have uptaken
        the new locking scheme, those entries in BSC_CURRENT_SESSION will be ignored.
  <parameters>
        p_program_id: -100 = Data Loader UI
                      -101 = Data Loader Backend
                      -200 = Generate Database
                      -201 = Generate Documentation
                      -202 = Rename Interface Table
                      -203 = Generate Database Configuration
                      -300 = Administrator
                      -400 = Objective Designer
                      -500 = Builder
                      -600 = Performance Scorecard
                      -700 = System Upgrade
                      -800 = System Migration
        p_user_id: Application User ID
        p_icx_session_id: Application Session ID
-------------------------------------------------------------------------------------------*/
Procedure  GET_SYSTEM_LOCK (
    p_program_id       IN           number
   ,p_user_id          IN           number
   ,p_icx_session_id   IN           number
   ,x_return_status    OUT NOCOPY   varchar2
   ,x_msg_count        OUT NOCOPY   number
   ,x_msg_data         OUT NOCOPY   varchar2
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_api_name CONSTANT VARCHAR2(30) := 'GET_SYSTEM_LOCK';
    l_session_id NUMBER;

    CURSOR c_conflict_session(c_program_id NUMBER) IS
    SELECT c.program_id, u.user_name, s.machine, s.terminal
    FROM   bsc_current_sessions c, v$session s, bsc_apps_users_v u
    WHERE  c.session_id = s.audsid
    AND  ((c_program_id = -100 AND c.program_id IN (-300, -400, -500, -700, -800, -802))
    OR    (c_program_id = -101 AND c.program_id IN (-300, -400, -500, -700, -800, -802))
    OR    (c_program_id = -200 AND c.program_id IN (-300, -400, -500, -700, -800, -802))
    OR    (c_program_id = -201 AND c.program_id IN (-400, -500, -700, -800, -802))
    OR    (c_program_id = -202 AND c.program_id IN (-700, -800, -802))
    OR    (c_program_id = -300 AND c.program_id IN (-100, -101, -200, -700, -800, -802))
    OR    (c_program_id = -400 AND c.program_id IN (-100, -101, -200, -201, -700, -800, -802))
    OR    (c_program_id = -500 AND c.program_id IN (-100, -101, -200, -201, -700, -800, -802))
    OR    (c_program_id = -600 AND c.program_id IN (-700, -800))
    OR    (c_program_id = -801 AND c.program_id IN (-700, -800, -801, -802))
    OR    (c_program_id = -802 AND c.program_id IN (-100, -101, -200, -201, -202, -300, -400, -500, -700, -800, -801))
    OR    (c_program_id NOT IN (-100, -101, -200, -201, -202, -300, -400, -500, -600, -801, -802)
    AND    c.program_id IN (-100, -101, -200, -201, -202, -300, -400, -500, -600, -700, -800, -801, -802)))
    AND    c.session_id <> USERENV('SESSIONID')
    AND    c.user_id = u.user_id (+);

    CURSOR c_existing_session(c_program_id NUMBER, c_icx_session_id NUMBER) IS
    SELECT SESSION_ID
    FROM  BSC_CURRENT_SESSIONS
    WHERE SESSION_ID = USERENV('SESSIONID')
    AND   ICX_SESSION_ID = c_icx_session_id
    AND   PROGRAM_ID = c_program_id;

BEGIN
    --DBMS_OUTPUT.PUT_LINE('GET_SYSTEM_LOCK');
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    BSC_LOCKS_PVT.Initialize;

    BSC_SECURITY.Refresh_System_Lock(p_program_id);
    --Delete all orphan the sessions
    --DELETE BSC_CURRENT_SESSIONS
    --WHERE  SESSION_ID NOT IN
    --       (SELECT VS.AUDSID
    --        FROM V$SESSION VS);
    --
    --Delete all the session not being reused by FND
    --DELETE BSC_CURRENT_SESSIONS
    --WHERE  ICX_SESSION_ID IN (
    --        SELECT SESSION_ID
    --        FROM ICX_SESSIONS
    --        WHERE (FND_SESSION_MANAGEMENT.CHECK_SESSION(SESSION_ID,NULL,NULL,'N') <> 'VALID'));
    --
    --Delete all sessions, which have their concurrent programs in invalid or hang status
    --DELETE BSC_CURRENT_SESSIONS
    --WHERE SESSION_ID IN (
    --        SELECT NVL(ORACLE_SESSION_ID, -1)
    --        FROM  FND_CONCURRENT_REQUESTS
    --        WHERE PHASE_CODE = 'C');
    --
    -- Kill IViewer Sessions that have been INACTIVE more than 20 minutes
    --IF p_program_id <> -600 THEN
    --    IF BSC_APPS.APPS_ENV THEN
    --        DELETE BSC_CURRENT_SESSIONS
    --        WHERE  PROGRAM_ID = -600
    --        AND    SESSION_ID IN (
    --                   SELECT s.audsid
    --                   FROM   v$session s, v$session_wait w
    --                   WHERE  s.sid = w.sid
    --                   AND    w.seconds_in_wait > 1200);
    --    END IF;
    --END IF;
    --
    --Delete all the Killed Sessions
    --DELETE BSC_CURRENT_SESSIONS
    --WHERE  SESSION_ID IN (
    --       SELECT VS.AUDSID
    --       FROM V$SESSION VS
    --       WHERE VS.STATUS = 'KILLED');
    --COMMIT;

    FOR cd IN c_conflict_session(p_program_id) LOOP
        FND_MESSAGE.SET_NAME('BSC','BSC_SEC_LOCKED_SYSTEM');
        FND_MESSAGE.SET_TOKEN('COMPONENT',BSC_LOCKS_PVT.g_modules(cd.program_id) , TRUE);
        FND_MESSAGE.SET_TOKEN('USERNAME' ,cd.user_name, TRUE);
        FND_MESSAGE.SET_TOKEN('MACHINE'  ,cd.machine, TRUE);
        FND_MESSAGE.SET_TOKEN('TERMINAL' ,cd.terminal, TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END LOOP;

    OPEN c_existing_session(p_program_id, p_icx_session_id);
    FETCH c_existing_session INTO l_session_id;
    IF (c_existing_session%NOTFOUND) THEN
        INSERT INTO BSC_CURRENT_SESSIONS (
            SESSION_ID,
            PROGRAM_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            USER_ID,
            ICX_SESSION_ID
        ) VALUES (
            USERENV('SESSIONID'),
            p_program_id,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            USERENV('SESSIONID'),
            p_user_id,
            p_icx_session_id
        );
        COMMIT;
    END IF;
    CLOSE c_existing_session;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN OTHERS THEN
        FND_MSG_PUB.Add_Exc_Msg(
            G_PKG_NAME,
            l_api_name,
            SQLERRM
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
END GET_SYSTEM_LOCK;


/*------------------------------------------------------------------------------------------
Procedure REMOVE_SYSTEM_LOCK
        Due to the fact that not all the BSC modules will uptake the new locking scheme
        immediately, we will temporaily keep populating the BSC_CURRENT_SESSIONS table
        for backward compatibility issues.  This procedure will be called at the end
        of the process.  The entry in BSC_CURRENT_SESSIONS for the current session
        will be deleted
  <parameters>
        none
-------------------------------------------------------------------------------------------*/
Procedure  REMOVE_SYSTEM_LOCK
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    --DBMS_OUTPUT.PUT_LINE('REMOVE_SYSTEM_LOCK');
    DELETE BSC_CURRENT_SESSIONS
    WHERE SESSION_ID = USERENV('SESSIONID');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END REMOVE_SYSTEM_LOCK;

END BSC_LOCKS_PUB;

/
