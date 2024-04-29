--------------------------------------------------------
--  DDL for Package Body BSC_LOCKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_LOCKS_PVT" AS
/*$Header: BSCVLOKB.pls 120.8 2005/12/07 18:27:12 calaw noship $ */

/*------------------------------------------------------------------------------------------
Procedure VALIDATE_OBJECT
        This procedure inspects the validity of an Object.
        An exception will be raised if the Object does not exist in the database.
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
-------------------------------------------------------------------------------------------*/
PROCEDURE VALIDATE_OBJECT(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'VALIDATE_OBJECT';
    l_valid NUMBER;
    l_object_key1 NUMBER;
    l_object_key2 NUMBER;

    CURSOR c_validate_scorecard(c_tab_id NUMBER) IS
        SELECT 1 FROM BSC_TABS_B
        WHERE TAB_ID = c_tab_id;
    CURSOR c_validate_objective(c_indicator NUMBER) IS
        SELECT 1 FROM BSC_KPIS_B
        WHERE INDICATOR = c_indicator;
    CURSOR c_validate_dimension(c_dim_group_id NUMBER) IS
        SELECT 1 FROM BSC_SYS_DIM_GROUPS_TL
        WHERE DIM_GROUP_ID = c_dim_group_id;
    CURSOR c_validate_dimension_object(c_dim_level_id NUMBER) IS
        SELECT 1 FROM BSC_SYS_DIM_LEVELS_B
        WHERE DIM_LEVEL_ID = c_dim_level_id;
    CURSOR c_validate_measure(c_dataset_id NUMBER) IS
        SELECT 1 FROM BSC_SYS_DATASETS_B
        WHERE DATASET_ID = c_dataset_id;
    CURSOR c_validate_data_column(c_measure_id NUMBER) IS
        SELECT 1 FROM BSC_SYS_MEASURES
        WHERE MEASURE_ID = c_measure_id;
    CURSOR c_validate_custom_view(c_tab_id NUMBER, c_tab_view_id NUMBER) IS
        SELECT 1 FROM BSC_TAB_VIEWS_B
        WHERE TAB_ID = c_tab_id
        AND TAB_VIEW_ID = c_tab_view_id;
    CURSOR c_validate_launchpad(c_menu_id NUMBER) IS
        SELECT 1 FROM FND_MENUS
        WHERE MENU_ID = c_menu_id;
    CURSOR c_validate_periodicity(c_periodicity_id NUMBER) IS
        SELECT 1 FROM BSC_SYS_PERIODICITIES
        WHERE PERIODICITY_ID = c_periodicity_id;
    CURSOR c_validate_calendar(c_calendar_id NUMBER) IS
        SELECT 1 FROM BSC_SYS_CALENDARS_B
        WHERE CALENDAR_ID = c_calendar_id;
    CURSOR c_validate_table(c_table_name VARCHAR2) IS
        SELECT 1 FROM BSC_DB_TABLES
        WHERE TABLE_NAME = c_table_name;

BEGIN
    --DBMS_OUTPUT.PUT_LINE('VALIDATE_OBJECT: '||p_object_key||' '||p_object_type);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_valid := 0;
    IF (UPPER(p_object_type) = 'SCORECARD') THEN
        l_object_key1 := TO_NUMBER(p_object_key);
        OPEN c_validate_scorecard(l_object_key1);
        FETCH c_validate_scorecard INTO l_valid;
        CLOSE c_validate_scorecard;

    ELSIF (UPPER(p_object_type) = 'OBJECTIVE') THEN
        l_object_key1 := TO_NUMBER(p_object_key);
        OPEN c_validate_objective(l_object_key1);
        FETCH c_validate_objective INTO l_valid;
        CLOSE c_validate_objective;

    ELSIF (UPPER(p_object_type) = 'DIMENSION') THEN
        l_object_key1 := TO_NUMBER(p_object_key);
        OPEN c_validate_dimension(l_object_key1);
        FETCH c_validate_dimension INTO l_valid;
        CLOSE c_validate_dimension;

    ELSIF (UPPER(p_object_type) = 'DIMENSION_OBJECT') THEN
        l_object_key1 := TO_NUMBER(p_object_key);
        OPEN c_validate_dimension_object(l_object_key1);
        FETCH c_validate_dimension_object INTO l_valid;
        CLOSE c_validate_dimension_object;

    ELSIF (UPPER(p_object_type) = 'MEASURE') THEN
        l_object_key1 := TO_NUMBER(p_object_key);
        OPEN c_validate_measure(l_object_key1);
        FETCH c_validate_measure INTO l_valid;
        CLOSE c_validate_measure;

    ELSIF (UPPER(p_object_type) = 'DATA_COLUMN') THEN
        l_object_key1 := TO_NUMBER(p_object_key);
        OPEN c_validate_data_column(l_object_key1);
        FETCH c_validate_data_column INTO l_valid;
        CLOSE c_validate_data_column;

    ELSIF (UPPER(p_object_type) = 'CUSTOM_VIEW') THEN
        l_object_key1 := SUBSTR(p_object_key, 1, INSTR(p_object_key, ',')-1);
        l_object_key2 := SUBSTR(p_object_key, INSTR(p_object_key, ',')+1);
        --DBMS_OUTPUT.PUT_LINE('l_object_key1 = '||l_object_key1);
        --DBMS_OUTPUT.PUT_LINE('l_object_key2 = '||l_object_key2);
        OPEN c_validate_custom_view(l_object_key1, l_object_key2);
        FETCH c_validate_custom_view INTO l_valid;
        CLOSE c_validate_custom_view;

    ELSIF (UPPER(p_object_type) = 'LAUNCHPAD') THEN
        l_object_key1 := TO_NUMBER(p_object_key);
        OPEN c_validate_launchpad(l_object_key1);
        FETCH c_validate_launchpad INTO l_valid;
        CLOSE c_validate_launchpad;

    ELSIF (UPPER(p_object_type) = 'PERIODICITY') THEN
        l_object_key1 := TO_NUMBER(p_object_key);
        OPEN c_validate_periodicity(l_object_key1);
        FETCH c_validate_periodicity INTO l_valid;
        CLOSE c_validate_periodicity;

    ELSIF (UPPER(p_object_type) = 'CALENDAR') THEN
        l_object_key1 := TO_NUMBER(p_object_key);
        OPEN c_validate_calendar(l_object_key1);
        FETCH c_validate_calendar INTO l_valid;
        CLOSE c_validate_calendar;

    ELSIF (UPPER(p_object_type) = 'TABLE') THEN
        l_object_key1 := p_object_key;
        OPEN c_validate_table(l_object_key1);
        FETCH c_validate_table INTO l_valid;
        CLOSE c_validate_table;

    ELSE
        RETURN;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('l_valid = '||l_valid);
    IF (l_valid <> 1) THEN
        --DBMS_OUTPUT.PUT_LINE('OBJECT NOT VALID');
        FND_MESSAGE.SET_NAME('BSC','BSC_LOCK_ERR_INVALID');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --DBMS_OUTPUT.PUT_LINE('OBJECT VALID');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END VALIDATE_OBJECT;


/*------------------------------------------------------------------------------------------
Function LOCK_OBJECT
        This function puts a database lock on the corresponding row in the
        lock table and returns the last_save_time value.  If the row does
        not exist, a new row will be inserted to the lock table.
        In addition to that, the user table will also be updated.
        If someone else already locked the object, an exception will be raised.
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
FUNCTION LOCK_OBJECT(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_lock_type           IN             varchar2
   ,p_query_time          IN             date
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) RETURN DATE IS

    l_api_name CONSTANT VARCHAR2(30) := 'LOCK_OBJECT';
    l_last_save_time DATE;
    l_session_id NUMBER := USERENV('SESSIONID');
    l_last_session_id NUMBER;

    CURSOR c_get_session_id(
        c_object_key VARCHAR2,
        c_object_type VARCHAR2
    ) IS
        SELECT SESSION_ID
        FROM   BSC_OBJECT_LOCKS
        WHERE  OBJECT_KEY = c_object_key
        AND    OBJECT_TYPE = c_object_type
        AND    LOCK_TYPE = 'W';

BEGIN
    --DBMS_OUTPUT.PUT_LINE('LOCK_OBJECT: '||p_object_key||' '||p_object_type);
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_last_save_time := NULL;

    IF (p_lock_type = 'R') THEN
        l_last_save_time :=
            BSC_LOCKS_PVT.LOCK_OBJECT_READ
            (
                p_object_key     => p_object_key
               ,p_object_type    => p_object_type
               ,p_program_id     => p_program_id
               ,p_user_id        => p_user_id
               ,p_machine        => p_machine
               ,p_terminal       => p_terminal
               ,x_return_status  => x_return_status
               ,x_msg_count      => x_msg_count
               ,x_msg_data       => x_msg_data
            );
    ELSE
        l_last_save_time :=
            BSC_LOCKS_PVT.LOCK_OBJECT_WRITE
            (
                p_object_key     => p_object_key
               ,p_object_type    => p_object_type
               ,p_program_id     => p_program_id
               ,p_user_id        => p_user_id
               ,p_machine        => p_machine
               ,p_terminal       => p_terminal
               ,x_return_status  => x_return_status
               ,x_msg_count      => x_msg_count
               ,x_msg_data       => x_msg_data
            );
    END IF;

    -- Check the last save time
    IF (l_last_save_time IS NOT NULL AND l_last_save_time > p_query_time) THEN
        OPEN c_get_session_id(p_object_key, p_object_type);
        FETCH c_get_session_id INTO l_last_session_id;
        CLOSE c_get_session_id;
        IF (l_last_session_id IS NOT NULL AND l_last_session_id <> l_session_id) THEN
            BSC_LOCKS_PVT.RAISE_EXCEPTION
            (
                p_object_key     => p_object_key
               ,p_object_type    => p_object_type
               ,p_exception_type => 'M'
               ,x_return_status  => x_return_status
               ,x_msg_count      => x_msg_count
               ,x_msg_data       => x_msg_data
            );
        END IF;
    END IF;
    RETURN l_last_save_time;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END LOCK_OBJECT;


/*------------------------------------------------------------------------------------------
Procedure LOCK_OBJECT
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
        p_machine: The Machine
        p_terminal: The Terminal
        p_cascade_lock_level: Number of level for cascade locks
                              Default is -1 which means enable cascade locking
                              all the way to the lowest level
-------------------------------------------------------------------------------------------*/
Procedure LOCK_OBJECT(
    p_object_type         IN             varchar2
   ,p_lock_type           IN             varchar2
   ,p_query_time          IN             date
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,p_cascade_lock_level  IN             number
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'LOCK_OBJECT';
    l_last_save_time DATE;

    CURSOR c_get_object(
        c_object_type VARCHAR2
    ) IS
        SELECT DISTINCT OBJECT_KEY
        FROM   BSC_OBJECT_LOCKS
        WHERE  OBJECT_TYPE = c_object_type;

BEGIN
    --DBMS_OUTPUT.PUT_LINE('LOCK_OBJECT: '||p_object_type);
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_last_save_time := NULL;

    -- Lock the top level object
    FOR cobj IN c_get_object(p_object_type) LOOP
        l_last_save_time :=
            BSC_LOCKS_PVT.LOCK_OBJECT
            (
                p_object_key     => cobj.OBJECT_KEY
               ,p_object_type    => p_object_type
               ,p_lock_type      => p_lock_type
               ,p_query_time     => p_query_time
               ,p_program_id     => p_program_id
               ,p_user_id        => p_user_id
               ,p_machine        => p_machine
               ,p_terminal       => p_terminal
               ,x_return_status  => x_return_status
               ,x_msg_count      => x_msg_count
               ,x_msg_data       => x_msg_data
            );
    END LOOP;

    -- Lock the ALL entry
    l_last_save_time :=
        BSC_LOCKS_PVT.LOCK_OBJECT
        (
            p_object_key     => 'ALL'
           ,p_object_type    => p_object_type
           ,p_lock_type      => p_lock_type
           ,p_query_time     => p_query_time
           ,p_program_id     => p_program_id
           ,p_user_id        => p_user_id
           ,p_machine        => p_machine
           ,p_terminal       => p_terminal
           ,x_return_status  => x_return_status
           ,x_msg_count      => x_msg_count
           ,x_msg_data       => x_msg_data
        );

    -- Lock the child objects
    IF (p_cascade_lock_level <> 0) THEN
        IF (UPPER(p_object_type) = 'SCORECARD') THEN
            BSC_LOCKS_PVT.LOCK_OBJECT
            (
                p_object_type        => 'OBJECTIVE'
               ,p_lock_type          => p_lock_type
               ,p_query_time         => p_query_time
               ,p_program_id         => p_program_id
               ,p_user_id            => p_user_id
               ,p_machine            => p_machine
               ,p_terminal           => p_terminal
               ,p_cascade_lock_level => p_cascade_lock_level - 1
               ,x_return_status      => x_return_status
               ,x_msg_count          => x_msg_count
               ,x_msg_data           => x_msg_data
            );
            BSC_LOCKS_PVT.LOCK_OBJECT
            (
                p_object_type        => 'CUSTOM_VIEW'
               ,p_lock_type          => p_lock_type
               ,p_query_time         => p_query_time
               ,p_program_id         => p_program_id
               ,p_user_id            => p_user_id
               ,p_machine            => p_machine
               ,p_terminal           => p_terminal
               ,p_cascade_lock_level => 0
               ,x_return_status      => x_return_status
               ,x_msg_count          => x_msg_count
               ,x_msg_data           => x_msg_data
            );
            IF (p_cascade_lock_level > 1) THEN
                BSC_LOCKS_PVT.LOCK_OBJECT
                (
                    p_object_type        => 'LAUNCHPAD'
                   ,p_lock_type          => p_lock_type
                   ,p_query_time         => p_query_time
                   ,p_program_id         => p_program_id
                   ,p_user_id            => p_user_id
                   ,p_machine            => p_machine
                   ,p_terminal           => p_terminal
                   ,p_cascade_lock_level => 0
                   ,x_return_status      => x_return_status
                   ,x_msg_count          => x_msg_count
                   ,x_msg_data           => x_msg_data
                );
            END IF;

        -- No cascade lock for generate database configuration
        ELSIF (UPPER(p_object_type) = 'OBJECTIVE' AND p_program_id <> -203) THEN
            BSC_LOCKS_PVT.LOCK_OBJECT
            (
                p_object_type        => 'DIMENSION'
               ,p_lock_type          => p_lock_type
               ,p_query_time         => p_query_time
               ,p_program_id         => p_program_id
               ,p_user_id            => p_user_id
               ,p_machine            => p_machine
               ,p_terminal           => p_terminal
               ,p_cascade_lock_level => p_cascade_lock_level - 1
               ,x_return_status      => x_return_status
               ,x_msg_count          => x_msg_count
               ,x_msg_data           => x_msg_data
            );
            BSC_LOCKS_PVT.LOCK_OBJECT
            (
                p_object_type        => 'MEASURE'
               ,p_lock_type          => p_lock_type
               ,p_query_time         => p_query_time
               ,p_program_id         => p_program_id
               ,p_user_id            => p_user_id
               ,p_machine            => p_machine
               ,p_terminal           => p_terminal
               ,p_cascade_lock_level => p_cascade_lock_level - 1
               ,x_return_status      => x_return_status
               ,x_msg_count          => x_msg_count
               ,x_msg_data           => x_msg_data
            );

        ELSIF (UPPER(p_object_type) = 'DIMENSION') THEN
            BSC_LOCKS_PVT.LOCK_OBJECT
            (
                p_object_type        => 'DIMENSION_OBJECT'
               ,p_lock_type          => p_lock_type
               ,p_query_time         => p_query_time
               ,p_program_id         => p_program_id
               ,p_user_id            => p_user_id
               ,p_machine            => p_machine
               ,p_terminal           => p_terminal
               ,p_cascade_lock_level => p_cascade_lock_level - 1
               ,x_return_status      => x_return_status
               ,x_msg_count          => x_msg_count
               ,x_msg_data           => x_msg_data
            );

        ELSIF (UPPER(p_object_type) = 'MEASURE') THEN
            BSC_LOCKS_PVT.LOCK_OBJECT
            (
                p_object_type        => 'DATA_COLUMN'
               ,p_lock_type          => p_lock_type
               ,p_query_time         => p_query_time
               ,p_program_id         => p_program_id
               ,p_user_id            => p_user_id
               ,p_machine            => p_machine
               ,p_terminal           => p_terminal
               ,p_cascade_lock_level => p_cascade_lock_level - 1
               ,x_return_status      => x_return_status
               ,x_msg_count          => x_msg_count
               ,x_msg_data           => x_msg_data
            );

        -- Custom View: only lock 1 level down
        ELSIF (UPPER(p_object_type) = 'CUSTOM_VIEW') THEN
            BSC_LOCKS_PVT.LOCK_OBJECT
            (
                p_object_type        => 'LAUNCHPAD'
               ,p_lock_type          => p_lock_type
               ,p_query_time         => p_query_time
               ,p_program_id         => p_program_id
               ,p_user_id            => p_user_id
               ,p_machine            => p_machine
               ,p_terminal           => p_terminal
               ,p_cascade_lock_level => 0
               ,x_return_status      => x_return_status
               ,x_msg_count          => x_msg_count
               ,x_msg_data           => x_msg_data
            );
            BSC_LOCKS_PVT.LOCK_OBJECT
            (
                p_object_type        => 'OBJECTIVE'
               ,p_lock_type          => p_lock_type
               ,p_query_time         => p_query_time
               ,p_program_id         => p_program_id
               ,p_user_id            => p_user_id
               ,p_machine            => p_machine
               ,p_terminal           => p_terminal
               ,p_cascade_lock_level => 0
               ,x_return_status      => x_return_status
               ,x_msg_count          => x_msg_count
               ,x_msg_data           => x_msg_data
            );
            BSC_LOCKS_PVT.LOCK_OBJECT
            (
                p_object_type        => 'MEASURE'
               ,p_lock_type          => p_lock_type
               ,p_query_time         => p_query_time
               ,p_program_id         => p_program_id
               ,p_user_id            => p_user_id
               ,p_machine            => p_machine
               ,p_terminal           => p_terminal
               ,p_cascade_lock_level => 0
               ,x_return_status      => x_return_status
               ,x_msg_count          => x_msg_count
               ,x_msg_data           => x_msg_data
            );
        END IF;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END LOCK_OBJECT;


/*------------------------------------------------------------------------------------------
Function LOCK_OBJECT_WRITE
        This function acquires a write (exclusive) lock on an Object
        and returns the last_save_time value.
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
FUNCTION LOCK_OBJECT_WRITE(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) RETURN DATE IS

    l_api_name CONSTANT VARCHAR2(30) := 'LOCK_OBJECT_WRITE';
    l_object_key BSC_OBJECT_LOCKS.OBJECT_KEY%TYPE;
    l_object_type BSC_OBJECT_LOCKS.OBJECT_TYPE%TYPE;
    l_insert_flag BOOLEAN;
    l_last_save_time DATE;
    l_session_id NUMBER := USERENV('SESSIONID');

    CURSOR c_locate_lock(
        c_object_key VARCHAR2,
        c_object_type VARCHAR2,
        c_lock_type VARCHAR2
    ) IS
        SELECT LAST_SAVE_TIME
        FROM   BSC_OBJECT_LOCKS
        WHERE  OBJECT_KEY = c_object_key
        AND    OBJECT_TYPE = c_object_type
        AND    LOCK_TYPE = c_lock_type
        FOR UPDATE NOWAIT;

BEGIN
    --DBMS_OUTPUT.PUT_LINE('LOCK_OBJECT_WRITE: '||p_object_key||' '||p_object_type);
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_last_save_time := NULL;
    l_insert_flag := TRUE;

    -- Lock the object
    l_last_save_time :=
        BSC_LOCKS_PVT.LOCK_OBJECT_WRITE
        (
            p_object_key     => p_object_key
           ,p_object_type    => p_object_type
           ,x_insert_flag    => l_insert_flag
           ,x_return_status  => x_return_status
           ,x_msg_count      => x_msg_count
           ,x_msg_data       => x_msg_data
        );

    IF (l_insert_flag) THEN
        l_object_key := p_object_key;
        l_object_type := p_object_type;
        BEGIN
            SAVEPOINT BSCLocksPvtLockObjectWrite;

            -- Check for "ALL" entries
            l_object_key := 'ALL';
            OPEN c_locate_lock(l_object_key, l_object_type, 'W');
            FETCH c_locate_lock INTO l_last_save_time;
            CLOSE c_locate_lock;
            l_object_type := 'ALL';
            OPEN c_locate_lock(l_object_key, l_object_type, 'W');
            FETCH c_locate_lock INTO l_last_save_time;
            CLOSE c_locate_lock;

            -- Insert new lock entry
            BSC_LOCKS_PVT.INSERT_LOCK_INFO_AUTONOMOUS
            (
                p_object_key     => p_object_key
               ,p_object_type    => p_object_type
               ,p_lock_type      => 'W'
               ,p_last_save_time => NULL
               ,p_session_id     => l_session_id
               ,x_return_status  => x_return_status
               ,x_msg_count      => x_msg_count
               ,x_msg_data       => x_msg_data
            );
            ROLLBACK TO BSCLocksPvtLockObjectWrite;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO BSCLocksPvtLockObjectWrite;
                BSC_LOCKS_PVT.RAISE_EXCEPTION
                (
                    p_object_key     => l_object_key
                   ,p_object_type    => l_object_type
                   ,p_exception_type => 'L'
                   ,x_return_status  => x_return_status
                   ,x_msg_count      => x_msg_count
                   ,x_msg_data       => x_msg_data
                );
        END;

        l_last_save_time :=
            BSC_LOCKS_PVT.LOCK_OBJECT_WRITE
            (
                p_object_key     => p_object_key
               ,p_object_type    => p_object_type
               ,p_program_id     => p_program_id
               ,p_user_id        => p_user_id
               ,p_machine        => p_machine
               ,p_terminal       => p_terminal
               ,x_return_status  => x_return_status
               ,x_msg_count      => x_msg_count
               ,x_msg_data       => x_msg_data
            );

    -- Update the user info
    ELSE
        BSC_LOCKS_PVT.UPDATE_USER_INFO_AUTONOMOUS
        (
            p_object_key     => p_object_key
           ,p_object_type    => p_object_type
           ,p_user_type      => 'L'
           ,p_program_id     => p_program_id
           ,p_user_id        => p_user_id
           ,p_machine        => p_machine
           ,p_terminal       => p_terminal
           ,x_return_status  => x_return_status
           ,x_msg_count      => x_msg_count
           ,x_msg_data       => x_msg_data
        );
    END IF;
    RETURN l_last_save_time;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END LOCK_OBJECT_WRITE;


/*------------------------------------------------------------------------------------------
Function LOCK_OBJECT_WRITE
        This function acquires a write (exclusive) lock on an Object
        and returns the last_save_time value.
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        x_insert_flag: True if the lock entry is missing in the lock table
-------------------------------------------------------------------------------------------*/
Function LOCK_OBJECT_WRITE(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,x_insert_flag         OUT NOCOPY     boolean
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) return DATE IS

    l_api_name CONSTANT VARCHAR2(30) := 'LOCK_OBJECT_WRITE';
    l_count NUMBER;
    l_last_save_time DATE;
    l_lock_type BSC_OBJECT_LOCKS.LOCK_TYPE%TYPE;
    l_user_type BSC_OBJECT_LOCK_USERS.USER_TYPE%TYPE;

    CURSOR c_get_object(
        c_object_key VARCHAR2,
        c_object_type VARCHAR2
    ) IS
        SELECT LOCK_TYPE
        FROM   BSC_OBJECT_LOCKS
        WHERE  OBJECT_KEY = c_object_key
        AND    OBJECT_TYPE = c_object_type;

    CURSOR c_lock_object(
        c_object_key VARCHAR2,
        c_object_type VARCHAR2
    ) IS
        SELECT LAST_SAVE_TIME
        FROM   BSC_OBJECT_LOCKS
        WHERE  OBJECT_KEY = c_object_key
        AND    OBJECT_TYPE = c_object_type
        ORDER BY LOCK_TYPE
        FOR UPDATE NOWAIT;

    CURSOR c_locate_lock(
        c_object_key VARCHAR2,
        c_object_type VARCHAR2,
        c_lock_type VARCHAR2
    ) IS
        SELECT LAST_SAVE_TIME
        FROM   BSC_OBJECT_LOCKS
        WHERE  OBJECT_KEY = c_object_key
        AND    OBJECT_TYPE = c_object_type
        AND    LOCK_TYPE = c_lock_type
        FOR UPDATE NOWAIT;

BEGIN
    --DBMS_OUTPUT.PUT_LINE('LOCK_OBJECT_WRITE: '||p_object_key||' '||p_object_type);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_last_save_time := NULL;
    x_insert_flag := TRUE;
    BEGIN
        FOR clock IN c_lock_object(p_object_key, p_object_type) LOOP
            l_last_save_time := clock.LAST_SAVE_TIME;
            x_insert_flag := FALSE;
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            l_user_type := 'L';
            BEGIN
                FOR cobj IN c_get_object(p_object_key, p_object_type) LOOP
                    l_lock_type := cobj.LOCK_TYPE;
                    l_user_type := REPLACE(REPLACE(l_lock_type,'R','L'),'W','L');
                    OPEN c_locate_lock(p_object_key, p_object_type, l_lock_type);
                    FETCH c_locate_lock INTO l_last_save_time;
                    CLOSE c_locate_lock;
                END LOOP;
            EXCEPTION
                WHEN OTHERS THEN
                    BSC_LOCKS_PVT.RAISE_EXCEPTION
                    (
                        p_object_key     => p_object_key
                       ,p_object_type    => p_object_type
                       ,p_exception_type => l_user_type
                       ,x_return_status  => x_return_status
                       ,x_msg_count      => x_msg_count
                       ,x_msg_data       => x_msg_data
                    );
            END;
    END;
    RETURN l_last_save_time;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END LOCK_OBJECT_WRITE;


/*------------------------------------------------------------------------------------------
Function LOCK_OBJECT_READ
        This procedure acquires puts a read (shared) lock on the Object.
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Function LOCK_OBJECT_READ(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) return DATE IS

    l_api_name CONSTANT VARCHAR2(30) := 'LOCK_OBJECT_READ';
    l_count NUMBER;
    l_insert_flag BOOLEAN;
    l_last_save_time DATE;
    l_object_key BSC_OBJECT_LOCKS.OBJECT_KEY%TYPE;
    l_object_type BSC_OBJECT_LOCKS.OBJECT_TYPE%TYPE;
    l_lock_type BSC_OBJECT_LOCKS.LOCK_TYPE%TYPE;
    l_user_type BSC_OBJECT_LOCK_USERS.USER_TYPE%TYPE;
    l_session_id NUMBER := USERENV('SESSIONID');

    CURSOR c_get_object(
        c_object_key VARCHAR2,
        c_object_type VARCHAR2
    ) IS
        SELECT OBJECT_KEY, OBJECT_TYPE, LOCK_TYPE
        FROM   BSC_OBJECT_LOCKS
        WHERE  OBJECT_KEY = c_object_key
        AND    OBJECT_TYPE = c_object_type
        AND    LENGTH(LOCK_TYPE) > 1
        AND    SUBSTR(LOCK_TYPE,1,1) = 'R'
        ORDER BY LOCK_TYPE;

    CURSOR c_locate_lock(
        c_object_key VARCHAR2,
        c_object_type VARCHAR2,
        c_lock_type VARCHAR2
    ) IS
        SELECT LAST_SAVE_TIME
        FROM   BSC_OBJECT_LOCKS
        WHERE  OBJECT_KEY = c_object_key
        AND    OBJECT_TYPE = c_object_type
        AND    LOCK_TYPE = c_lock_type
        FOR UPDATE NOWAIT;

    CURSOR c_get_last_save_time(
        c_object_key VARCHAR2,
        c_object_type VARCHAR2
    ) IS
        SELECT LAST_SAVE_TIME
        FROM   BSC_OBJECT_LOCKS
        WHERE  OBJECT_KEY = c_object_key
        AND    OBJECT_TYPE = c_object_type
        AND    LOCK_TYPE = 'W';

BEGIN
    --DBMS_OUTPUT.PUT_LINE('LOCK_OBJECT_READ: '||p_object_key||' '||p_object_type);
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_last_save_time := NULL;
    l_insert_flag := TRUE;
    l_count := 0;

    FOR cobj IN c_get_object(p_object_key, p_object_type) LOOP
        l_object_key := cobj.OBJECT_KEY;
        l_object_type := cobj.OBJECT_TYPE;
        l_lock_type := cobj.LOCK_TYPE;
        l_count := TO_NUMBER(SUBSTR(l_lock_type,2));
        BEGIN
            OPEN c_locate_lock(l_object_key, l_object_type, l_lock_type);
            FETCH c_locate_lock INTO l_last_save_time;
            CLOSE c_locate_lock;
            l_insert_flag := FALSE;
            EXIT;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
    END LOOP;

    -- Check for write lock
    IF (l_insert_flag) THEN
        l_object_key := p_object_key;
        l_object_type := p_object_type;
        l_count := l_count + 1;
        BEGIN
            SAVEPOINT BSCLocksPvtLockObjectRead;
            OPEN c_locate_lock(l_object_key, l_object_type, 'W');
            FETCH c_locate_lock INTO l_last_save_time;
            l_insert_flag := (c_locate_lock%NOTFOUND);
            CLOSE c_locate_lock;

            -- Check for "ALL" entries
            IF (l_insert_flag) THEN
                l_object_key := 'ALL';
                OPEN c_locate_lock(l_object_key, l_object_type, 'W');
                FETCH c_locate_lock INTO l_last_save_time;
                CLOSE c_locate_lock;
                l_object_type := 'ALL';
                OPEN c_locate_lock(l_object_key, l_object_type, 'W');
                FETCH c_locate_lock INTO l_last_save_time;
                CLOSE c_locate_lock;

                -- Insert write lock entry
                BSC_LOCKS_PVT.INSERT_LOCK_INFO_AUTONOMOUS
                (
                    p_object_key     => p_object_key
                   ,p_object_type    => p_object_type
                   ,p_lock_type      => 'W'
                   ,p_last_save_time => NULL
                   ,p_session_id     => l_session_id
                   ,x_return_status  => x_return_status
                   ,x_msg_count      => x_msg_count
                   ,x_msg_data       => x_msg_data
                );
            END IF;

            -- Insert read lock entry
            BSC_LOCKS_PVT.INSERT_LOCK_INFO_AUTONOMOUS
            (
                p_object_key     => p_object_key
               ,p_object_type    => p_object_type
               ,p_lock_type      => 'R'||TO_CHAR(l_count)
               ,p_last_save_time => NULL
               ,p_session_id     => l_session_id
               ,x_return_status  => x_return_status
               ,x_msg_count      => x_msg_count
               ,x_msg_data       => x_msg_data
            );
            ROLLBACK TO BSCLocksPvtLockObjectRead;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO BSCLocksPvtLockObjectRead;
                BSC_LOCKS_PVT.RAISE_EXCEPTION
                (
                    p_object_key     => l_object_key
                   ,p_object_type    => l_object_type
                   ,p_exception_type => 'L'
                   ,x_return_status  => x_return_status
                   ,x_msg_count      => x_msg_count
                   ,x_msg_data       => x_msg_data
                );
        END;

        -- Acquire read lock
        BEGIN
            OPEN c_locate_lock(p_object_key, p_object_type, 'R'||TO_CHAR(l_count));
            FETCH c_locate_lock INTO l_last_save_time;
            CLOSE c_locate_lock;
        EXCEPTION
            WHEN OTHERS THEN
                BSC_LOCKS_PVT.RAISE_EXCEPTION
                (
                    p_object_key     => p_object_key
                   ,p_object_type    => p_object_type
                   ,p_exception_type => 'L'||TO_CHAR(l_count)
                   ,x_return_status  => x_return_status
                   ,x_msg_count      => x_msg_count
                   ,x_msg_data       => x_msg_data
                );
        END;
    END IF;

    -- Update the user info
    BSC_LOCKS_PVT.UPDATE_USER_INFO_AUTONOMOUS
    (
        p_object_key     => p_object_key
       ,p_object_type    => p_object_type
       ,p_user_type      => 'L'||TO_CHAR(l_count)
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => p_machine
       ,p_terminal       => p_terminal
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Get the last save time
    OPEN c_get_last_save_time(p_object_key, p_object_type);
    FETCH c_get_last_save_time INTO l_last_save_time;
    CLOSE c_get_last_save_time;
    RETURN l_last_save_time;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END LOCK_OBJECT_READ;


/*------------------------------------------------------------------------------------------
Procedure LOCK_OBJECT_ALL
        This procedure locks the locking tables
-------------------------------------------------------------------------------------------*/
Procedure LOCK_OBJECT_ALL(
    x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'LOCK_OBJECT_ALL';
    l_object_key BSC_OBJECT_LOCKS.OBJECT_KEY%TYPE;
    l_object_type BSC_OBJECT_LOCKS.OBJECT_TYPE%TYPE;
    l_lock_type BSC_OBJECT_LOCKS.LOCK_TYPE%TYPE;
    l_user_type BSC_OBJECT_LOCK_USERS.USER_TYPE%TYPE;
    l_last_save_time BSC_OBJECT_LOCKS.LAST_SAVE_TIME%TYPE;
    l_exception_flag BOOLEAN;

    CURSOR c_lock_object IS
    SELECT LAST_SAVE_TIME
    FROM BSC_OBJECT_LOCKS
    FOR UPDATE NOWAIT;

    CURSOR c_get_object IS
    SELECT OBJECT_TYPE, OBJECT_KEY, LOCK_TYPE
    FROM BSC_OBJECT_LOCKS;

    CURSOR c_locate_lock(
        c_object_key VARCHAR2,
        c_object_type VARCHAR2,
        c_lock_type VARCHAR2
    ) IS
        SELECT LAST_SAVE_TIME
        FROM   BSC_OBJECT_LOCKS
        WHERE  OBJECT_KEY = c_object_key
        AND    OBJECT_TYPE = c_object_type
        AND    LOCK_TYPE = c_lock_type
        FOR UPDATE NOWAIT;

BEGIN
    --DBMS_OUTPUT.PUT_LINE('LOCK_OBJECT_ALL');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_exception_flag := FALSE;

    -- Lock the user entry for the top level object
    BEGIN
        LOCK TABLE BSC_OBJECT_LOCK_USERS IN EXCLUSIVE MODE NOWAIT;
        LOCK TABLE BSC_OBJECT_LOCKS IN EXCLUSIVE MODE NOWAIT;
        --FOR clock IN c_lock_object LOOP
        --    l_last_save_time := clock.LAST_SAVE_TIME;
        --END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            l_exception_flag := TRUE;
            FOR cobj IN c_get_object LOOP
                l_object_type := cobj.OBJECT_TYPE;
                l_object_key := cobj.OBJECT_KEY;
                l_lock_type := cobj.LOCK_TYPE;
                l_user_type := REPLACE(REPLACE(l_lock_type,'R','L'),'W','L');
                --DBMS_OUTPUT.PUT_LINE('objectType='||l_object_type||', objectKey='||l_object_key||', lockType='||l_lock_type||', userType='||l_user_type);
                BEGIN
                    OPEN c_locate_lock(l_object_key, l_object_type, l_lock_type);
                    FETCH c_locate_lock INTO l_last_save_time;
                    CLOSE c_locate_lock;
                EXCEPTION
                    WHEN OTHERS THEN
                        BSC_LOCKS_PVT.RAISE_EXCEPTION
                        (
                            p_object_key     => l_object_key
                           ,p_object_type    => l_object_type
                           ,p_exception_type => l_user_type
                           ,x_return_status  => x_return_status
                           ,x_msg_count      => x_msg_count
                           ,x_msg_data       => x_msg_data
                        );
                END;
            END LOOP;
    END;

    -- Couldn't find the entry being locked, try again
    IF (l_exception_flag) THEN
        BSC_LOCKS_PVT.LOCK_OBJECT_ALL
        (
            x_return_status  => x_return_status
           ,x_msg_count      => x_msg_count
           ,x_msg_data       => x_msg_data
        );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END LOCK_OBJECT_ALL;


/*------------------------------------------------------------------------------------------
Procedure LOCK_USER
        This procedure puts a database lock on the corresponding row in the
        lock user table.  If the row does not exist, a new row will be inserted
        to the lock user table.  If someone else already locked the object,
        an exception will be raised.
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        p_user_type:  "L" = Lock, "M" = Modify
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure LOCK_USER(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_user_type           IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'LOCK_USER';
    l_user_id BSC_OBJECT_LOCK_USERS.USER_ID%TYPE;
    --l_insert_flag BOOLEAN;

    CURSOR c_lock_user(c_object_key VARCHAR2, c_object_type VARCHAR2, c_user_type VARCHAR2) IS
    SELECT USER_ID FROM BSC_OBJECT_LOCK_USERS
    WHERE OBJECT_KEY = c_object_key
    AND OBJECT_TYPE = c_object_type
    AND USER_TYPE = c_user_type
    FOR UPDATE NOWAIT;

BEGIN
    --DBMS_OUTPUT.PUT_LINE('LOCK_USER: '||p_object_key||' '||p_object_type||' '||p_user_type);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_user_id := NULL;
    BEGIN
        OPEN c_lock_user(p_object_key, p_object_type, p_user_type);
        FETCH c_lock_user INTO l_user_id;
        --l_insert_flag := (c_lock_user%NOTFOUND);
        CLOSE c_lock_user;
    EXCEPTION
        WHEN OTHERS THEN
            BSC_LOCKS_PVT.RAISE_EXCEPTION
            (
                p_object_key     => p_object_key
               ,p_object_type    => p_object_type
               ,p_exception_type => 'L'
               ,x_return_status  => x_return_status
               ,x_msg_count      => x_msg_count
               ,x_msg_data       => x_msg_data
            );
    END;

    -- Commended out because of compatibility issues with "ALL" entries
    --IF (l_insert_Flag) THEN
    --    BEGIN
    --        BSC_LOCKS_PVT.INSERT_LOCK_INFO_AUTONOMOUS
    --        (
    --            p_object_key     => p_object_key
    --           ,p_object_type    => p_object_type
    --           ,p_lock_type      => 'W'
    --           ,p_last_save_time => NULL
    --           ,p_session_id     => USERENV('SESSIONID')
    --           ,x_return_status  => x_return_status
    --           ,x_msg_count      => x_msg_count
    --           ,x_msg_data       => x_msg_data
    --        );
    --    EXCEPTION
    --        WHEN OTHERS THEN
    --            NULL;
    --    END;
    --    BSC_LOCKS_PVT.INSERT_USER_INFO_AUTONOMOUS
    --    (
    --        p_object_key     => p_object_key
    --       ,p_object_type    => p_object_type
    --       ,p_user_type      => p_user_type
    --       ,p_program_id     => p_program_id
    --       ,p_user_id        => p_user_id
    --       ,p_machine        => p_machine
    --       ,p_terminal       => p_terminal
    --       ,x_return_status  => x_return_status
    --       ,x_msg_count      => x_msg_count
    --       ,x_msg_data       => x_msg_data
    --    );
    --    BSC_LOCKS_PVT.LOCK_USER
    --    (
    --        p_object_key     => p_object_key
    --       ,p_object_type    => p_object_type
    --       ,p_user_type      => p_user_type
    --       ,p_program_id     => p_program_id
    --       ,p_user_id        => p_user_id
    --       ,p_machine        => p_machine
    --       ,p_terminal       => p_terminal
    --       ,x_return_status  => x_return_status
    --       ,x_msg_count      => x_msg_count
    --       ,x_msg_data       => x_msg_data
    --    );
    --END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END LOCK_USER;


/*------------------------------------------------------------------------------------------
Procedure GET_CHILD_OBJECTS
        This procedure retrieves the list of child objects down the hierarchy
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        p_cascade_lock_level: Number of level for cascade locks
                              Default is -1 which means enable cascade locking
                              all the way to the lowest level
        p_lowest_level_type: The type of the lowest level object
        x_child_object_keys: Table of child object keys
        x_child_object_types: Table of child object types
        x_child_object_count: Total number of child objects (Should pass in 0 initially)
-------------------------------------------------------------------------------------------*/
Procedure GET_CHILD_OBJECTS(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_cascade_lock_level  IN             number
   ,p_lowest_level_type   IN             varchar2
   ,x_child_object_keys   IN OUT NOCOPY  t_array_object_key
   ,x_child_object_types  IN OUT NOCOPY  t_array_object_type
   ,x_child_object_count  IN OUT NOCOPY  number
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'GET_CHILD_OBJECTS';
    l_object_key1 NUMBER;
    l_object_key2 NUMBER;
    l_initial_count NUMBER;
    l_cascade_lock_level NUMBER;
    l_measure_cols dbms_sql.varchar2_table;

    CURSOR c_get_child_scorecard(c_tab_id NUMBER) IS
        SELECT TO_CHAR(INDICATOR) OBJECT_KEY,
               'OBJECTIVE' OBJECT_TYPE
        FROM BSC_TAB_INDICATORS
        WHERE TAB_ID = c_tab_id
        UNION
        SELECT TO_CHAR(c_tab_id)||','||TO_CHAR(TAB_VIEW_ID) OBJECT_KEY,
               'CUSTOM_VIEW' OBJECT_TYPE
        FROM BSC_TAB_VIEWS_B
        WHERE TAB_ID = c_tab_id;

    CURSOR c_get_child_objective(c_indicator NUMBER) IS
        SELECT TO_CHAR(DIM_GROUP_ID) OBJECT_KEY,
               'DIMENSION' OBJECT_TYPE
        FROM BSC_KPI_DIM_GROUPS
        WHERE INDICATOR = c_indicator
        UNION
        SELECT TO_CHAR(DATASET_ID) OBJECT_KEY,
               'MEASURE' OBJECT_TYPE
        FROM BSC_DB_DATASET_DIM_SETS_V
        WHERE INDICATOR = c_indicator;

    CURSOR c_get_child_dimension(c_dim_group_id NUMBER) IS
        SELECT TO_CHAR(DIM_LEVEL_ID) OBJECT_KEY,
               'DIMENSION_OBJECT' OBJECT_TYPE
        FROM BSC_SYS_DIM_LEVELS_BY_GROUP
        WHERE DIM_GROUP_ID = c_dim_group_id;

    CURSOR c_get_child_measure(c_dataset_id NUMBER) IS
        SELECT TO_CHAR(MEASURE_ID1) OBJECT_KEY,
               'DATA_COLUMN' OBJECT_TYPE
        FROM BSC_SYS_DATASETS_B
        WHERE DATASET_ID = c_dataset_id
        UNION
        SELECT TO_CHAR(MEASURE_ID2) OBJECT_KEY,
               'DATA_COLUMN' OBJECT_TYPE
        FROM BSC_SYS_DATASETS_B
        WHERE DATASET_ID = c_dataset_id
        AND MEASURE_ID2 IS NOT NULL;

    CURSOR c_get_child_custom_view(c_tab_id NUMBER, c_tab_view_id NUMBER) IS
        SELECT TO_CHAR(LINK_ID) OBJECT_KEY,
               DECODE(LABEL_TYPE,
                   2, 'LAUNCHPAD',
                   3, 'MEASURE',
                   4, 'OBJECTIVE') OBJECT_TYPE
        FROM BSC_TAB_VIEW_LABELS_B
        WHERE TAB_ID = c_tab_id
        AND TAB_VIEW_ID = c_tab_view_id
        AND LABEL_TYPE IN (2,3,4)
        AND LINK_ID IS NOT NULL;

    CURSOR c_get_measure_col(c_measure_id NUMBER) IS
        SELECT MEASURE_COL, SOURCE
        FROM BSC_SYS_MEASURES
        WHERE MEASURE_ID = c_measure_id;

    CURSOR c_get_measure_id(c_measure_col VARCHAR2, c_source VARCHAR2) IS
        SELECT TO_CHAR(MEASURE_ID) OBJECT_KEY,
               'DATA_COLUMN' OBJECT_TYPE
        FROM BSC_SYS_MEASURES
        WHERE MEASURE_COL = c_measure_col
        AND SOURCE = c_source;

BEGIN
    --DBMS_OUTPUT.PUT_LINE('GET_CHILD_OBJECTS: '||p_object_key||' '||p_object_type);
    --DBMS_OUTPUT.PUT_LINE('p_cascade_lock_level='||TO_CHAR(p_cascade_lock_level));
    --DBMS_OUTPUT.PUT_LINE('p_lowest_level_type='||p_lowest_level_type);
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_initial_count := x_child_object_count;
    l_cascade_lock_level := p_cascade_lock_level;

    IF ((p_lowest_level_type IS NULL OR p_object_type <> p_lowest_level_type) AND l_cascade_lock_level <> 0) THEN
        IF (UPPER(p_object_type) = 'SCORECARD') THEN
            l_object_key1 := TO_NUMBER(p_object_key);
            FOR cchild IN c_get_child_scorecard(l_object_key1) LOOP
                x_child_object_count := x_child_object_count + 1;
                x_child_object_keys(x_child_object_count) := cchild.OBJECT_KEY;
                x_child_object_types(x_child_object_count) := cchild.OBJECT_TYPE;
                --DBMS_OUTPUT.PUT_LINE('x_child_object_key('||TO_CHAR(x_child_object_count)||') = '||cchild.OBJECT_KEY);
                --DBMS_OUTPUT.PUT_LINE('x_child_object_type('||TO_CHAR(x_child_object_count)||') = '||cchild.OBJECT_TYPE);
            END LOOP;

        ELSIF (UPPER(p_object_type) = 'OBJECTIVE') THEN
            l_object_key1 := TO_NUMBER(p_object_key);
            FOR cchild IN c_get_child_objective(l_object_key1) LOOP
                x_child_object_count := x_child_object_count + 1;
                x_child_object_keys(x_child_object_count) := cchild.OBJECT_KEY;
                x_child_object_types(x_child_object_count) := cchild.OBJECT_TYPE;
                --DBMS_OUTPUT.PUT_LINE('x_child_object_key('||TO_CHAR(x_child_object_count)||') = '||cchild.OBJECT_KEY);
                --DBMS_OUTPUT.PUT_LINE('x_child_object_type('||TO_CHAR(x_child_object_count)||') = '||cchild.OBJECT_TYPE);
            END LOOP;

        ELSIF (UPPER(p_object_type) = 'DIMENSION') THEN
            l_object_key1 := TO_NUMBER(p_object_key);
            FOR cchild IN c_get_child_dimension(l_object_key1) LOOP
                x_child_object_count := x_child_object_count + 1;
                x_child_object_keys(x_child_object_count) := cchild.OBJECT_KEY;
                x_child_object_types(x_child_object_count) := cchild.OBJECT_TYPE;
                --DBMS_OUTPUT.PUT_LINE('x_child_object_key('||TO_CHAR(x_child_object_count)||') = '||cchild.OBJECT_KEY);
                --DBMS_OUTPUT.PUT_LINE('x_child_object_type('||TO_CHAR(x_child_object_count)||') = '||cchild.OBJECT_TYPE);
            END LOOP;

        ELSIF (UPPER(p_object_type) = 'MEASURE') THEN
            l_object_key1 := TO_NUMBER(p_object_key);
            FOR cchild IN c_get_child_measure(l_object_key1) LOOP
                x_child_object_count := x_child_object_count + 1;
                x_child_object_keys(x_child_object_count) := cchild.OBJECT_KEY;
                x_child_object_types(x_child_object_count) := cchild.OBJECT_TYPE;
                --DBMS_OUTPUT.PUT_LINE('x_child_object_key('||TO_CHAR(x_child_object_count)||') = '||cchild.OBJECT_KEY);
                --DBMS_OUTPUT.PUT_LINE('x_child_object_type('||TO_CHAR(x_child_object_count)||') = '||cchild.OBJECT_TYPE);
                FOR c_measure_col IN c_get_measure_col(TO_NUMBER(cchild.OBJECT_KEY)) LOOP
                    --DBMS_OUTPUT.PUT_LINE('PARENT COL = '||c_measure_col.MEASURE_COL);
                    l_measure_cols := BSC_DBGEN_UTILS.get_measure_list(c_measure_col.MEASURE_COL);
                    --DBMS_OUTPUT.PUT_LINE('MEASURE COL COUNT = '||TO_CHAR(l_measure_cols.count));
                    IF (l_measure_cols.count > 0 AND l_measure_cols(l_measure_cols.first) <> c_measure_col.MEASURE_COL) THEN
                        FOR i IN l_measure_cols.first..l_measure_cols.last LOOP
                            --DBMS_OUTPUT.PUT_LINE('CHILD COL('||TO_CHAR(i)||') = '||l_measure_cols(i));
                            FOR c_measure_id IN c_get_measure_id(l_measure_cols(i), c_measure_col.SOURCE) LOOP
                                x_child_object_count := x_child_object_count + 1;
                                x_child_object_keys(x_child_object_count) := c_measure_id.OBJECT_KEY;
                                x_child_object_types(x_child_object_count) := c_measure_id.OBJECT_TYPE;
                                --DBMS_OUTPUT.PUT_LINE('x_child_object_key('||TO_CHAR(x_child_object_count)||') = '||c_measure_id.OBJECT_KEY);
                                --DBMS_OUTPUT.PUT_LINE('x_child_object_type('||TO_CHAR(x_child_object_count)||') = '||c_measure_id.OBJECT_TYPE);
                            END LOOP;
                        END LOOP;
                    END IF;
                END LOOP;
            END LOOP;

        ELSIF (UPPER(p_object_type) = 'CUSTOM_VIEW') THEN
            l_object_key1 := SUBSTR(p_object_key, 1, INSTR(p_object_key, ',')-1);
            l_object_key2 := SUBSTR(p_object_key, INSTR(p_object_key, ',')+1);
            --DBMS_OUTPUT.PUT_LINE('l_object_key1 = '||l_object_key1);
            --DBMS_OUTPUT.PUT_LINE('l_object_key2 = '||l_object_key2);
            FOR cchild IN c_get_child_custom_view(l_object_key1, l_object_key2) LOOP
                x_child_object_count := x_child_object_count + 1;
                x_child_object_keys(x_child_object_count) := cchild.OBJECT_KEY;
                x_child_object_types(x_child_object_count) := cchild.OBJECT_TYPE;
                --DBMS_OUTPUT.PUT_LINE('x_child_object_key('||TO_CHAR(x_child_object_count)||') = '||cchild.OBJECT_KEY);
                --DBMS_OUTPUT.PUT_LINE('x_child_object_type('||TO_CHAR(x_child_object_count)||') = '||cchild.OBJECT_TYPE);
            END LOOP;
        END IF;

        IF (l_cascade_lock_level > 0) THEN
            l_cascade_lock_level := l_cascade_lock_level - 1;
        END IF;
        FOR i IN (l_initial_count+1)..x_child_object_count LOOP
            BSC_LOCKS_PVT.GET_CHILD_OBJECTS
            (
                p_object_key         => x_child_object_keys(i)
               ,p_object_type        => x_child_object_types(i)
               ,p_cascade_lock_level => l_cascade_lock_level
               ,p_lowest_level_type  => p_lowest_level_type
               ,x_child_object_keys  => x_child_object_keys
               ,x_child_object_types => x_child_object_types
               ,x_child_object_count => x_child_object_count
               ,x_return_status      => x_return_status
               ,x_msg_count          => x_msg_count
               ,x_msg_data           => x_msg_data
            );
        END LOOP;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GET_CHILD_OBJECTS;


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_ALL
        This procedure inserts the ALL entries into the lock table and user table
  <parameters>
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
        p_machine: The Machine
        p_terminal: The Terminal
        p_session_id: The Database Session ID
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_ALL(
    p_object_type         IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,p_session_id          IN             number
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_LOCK_ALL';

BEGIN
    --DBMS_OUTPUT.PUT_LINE('INSERT_LOCK_ALL: '||p_object_type);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BSC_LOCKS_PVT.INSERT_LOCK_INFO
    (
        p_object_key     => 'ALL'
       ,p_object_type    => p_object_type
       ,p_lock_type      => 'W'
       ,p_last_save_time => SYSDATE
       ,p_session_id     => p_session_id
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );
    BSC_LOCKS_PVT.INSERT_USER_INFO
    (
        p_object_key     => 'ALL'
       ,p_object_type    => p_object_type
       ,p_user_type      => 'L'
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => p_machine
       ,p_terminal       => p_terminal
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );
    BSC_LOCKS_PVT.INSERT_USER_INFO
    (
        p_object_key     => 'ALL'
       ,p_object_type    => p_object_type
       ,p_user_type      => 'M'
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => p_machine
       ,p_terminal       => p_terminal
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_LOCK_ALL;


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_ALL_AUTONOMOUS
        This procedure inserts the ALL entries into the lock table and user table
  <parameters>
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
        p_machine: The Machine
        p_terminal: The Terminal
        p_session_id: The Database Session ID
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_ALL_AUTONOMOUS(
    p_object_type         IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,p_session_id          IN             number
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_LOCK_ALL_AUTONOMOUS';

BEGIN
    --DBMS_OUTPUT.PUT_LINE('INSERT_LOCK_ALL_AUTONOMOUS: '||p_object_type);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BSC_LOCKS_PVT.INSERT_LOCK_ALL
    (
        p_object_type    => p_object_type
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => p_machine
       ,p_terminal       => p_terminal
       ,p_session_id     => p_session_id
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );
    COMMIT;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_LOCK_ALL_AUTONOMOUS;


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_SCORECARD
        This procedure inserts scorecard entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_SCORECARD(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_LOCK_SCORECARD';
    l_object_type BSC_OBJECT_LOCKS.OBJECT_TYPE%TYPE;
    l_session_id NUMBER := USERENV('SESSIONID');

BEGIN
    --DBMS_OUTPUT.PUT_LINE('INSERT_LOCK_SCORECARD');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_object_type := 'SCORECARD';

    -- Insert the ALL entries
    BSC_LOCKS_PVT.INSERT_LOCK_ALL
    (
        p_object_type    => l_object_type
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => p_machine
       ,p_terminal       => p_terminal
       ,p_session_id     => l_session_id
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Insert Scorecard entries
    INSERT INTO BSC_OBJECT_LOCKS (
        OBJECT_KEY,
        OBJECT_TYPE,
        LOCK_TYPE,
        LAST_SAVE_TIME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SESSION_ID
    ) SELECT TO_CHAR(TAB_ID),
             l_object_type,
             'W',
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             l_session_id
      FROM BSC_TABS_B;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT TO_CHAR(TAB_ID),
             l_object_type,
             'L',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_TABS_B;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT TO_CHAR(TAB_ID),
             l_object_type,
             'M',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_TABS_B;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_LOCK_SCORECARD;


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_OBJECTIVE
        This procedure inserts objective entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_OBJECTIVE(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_LOCK_OBJECTIVE';
    l_object_type BSC_OBJECT_LOCKS.OBJECT_TYPE%TYPE;
    l_session_id NUMBER := USERENV('SESSIONID');

BEGIN
    --DBMS_OUTPUT.PUT_LINE('INSERT_LOCK_OBJECTIVE');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_object_type := 'OBJECTIVE';

    -- Insert the ALL entries
    BSC_LOCKS_PVT.INSERT_LOCK_ALL
    (
        p_object_type    => l_object_type
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => p_machine
       ,p_terminal       => p_terminal
       ,p_session_id     => l_session_id
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Insert Objective entries
    INSERT INTO BSC_OBJECT_LOCKS (
        OBJECT_KEY,
        OBJECT_TYPE,
        LOCK_TYPE,
        LAST_SAVE_TIME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SESSION_ID
    ) SELECT TO_CHAR(INDICATOR),
             l_object_type,
             'W',
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             l_session_id
      FROM BSC_KPIS_B;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT TO_CHAR(INDICATOR),
             l_object_type,
             'L',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_KPIS_B;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT TO_CHAR(INDICATOR),
             l_object_type,
             'M',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_KPIS_B;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_LOCK_OBJECTIVE;


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_DIMENSION
        This procedure inserts dimension entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_DIMENSION(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_LOCK_DIMENSION';
    l_object_type BSC_OBJECT_LOCKS.OBJECT_TYPE%TYPE;
    l_session_id NUMBER := USERENV('SESSIONID');

BEGIN
    --DBMS_OUTPUT.PUT_LINE('INSERT_LOCK_DIMENSION');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_object_type := 'DIMENSION';

    -- Insert the ALL entries
    BSC_LOCKS_PVT.INSERT_LOCK_ALL
    (
        p_object_type    => l_object_type
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => p_machine
       ,p_terminal       => p_terminal
       ,p_session_id     => l_session_id
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Insert Dimension entries
    INSERT INTO BSC_OBJECT_LOCKS (
        OBJECT_KEY,
        OBJECT_TYPE,
        LOCK_TYPE,
        LAST_SAVE_TIME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SESSION_ID
    ) SELECT DISTINCT TO_CHAR(DIM_GROUP_ID),
             l_object_type,
             'W',
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             l_session_id
      FROM BSC_SYS_DIM_GROUPS_TL;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT DISTINCT TO_CHAR(DIM_GROUP_ID),
             l_object_type,
             'L',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_SYS_DIM_GROUPS_TL;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT DISTINCT TO_CHAR(DIM_GROUP_ID),
             l_object_type,
             'M',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_SYS_DIM_GROUPS_TL;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_LOCK_DIMENSION;


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_DIMENSION_OBJECT
        This procedure inserts dimension object entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_DIMENSION_OBJECT(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_LOCK_DIMENSION_OBJECT';
    l_object_type BSC_OBJECT_LOCKS.OBJECT_TYPE%TYPE;
    l_session_id NUMBER := USERENV('SESSIONID');

BEGIN
    --DBMS_OUTPUT.PUT_LINE('INSERT_LOCK_DIMENSION_OBJECT');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_object_type := 'DIMENSION_OBJECT';

    -- Insert the ALL entries
    BSC_LOCKS_PVT.INSERT_LOCK_ALL
    (
        p_object_type    => l_object_type
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => p_machine
       ,p_terminal       => p_terminal
       ,p_session_id     => l_session_id
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Insert Dimension Object entries
    INSERT INTO BSC_OBJECT_LOCKS (
        OBJECT_KEY,
        OBJECT_TYPE,
        LOCK_TYPE,
        LAST_SAVE_TIME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SESSION_ID
    ) SELECT TO_CHAR(DIM_LEVEL_ID),
             l_object_type,
             'W',
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             l_session_id
      FROM BSC_SYS_DIM_LEVELS_B;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT TO_CHAR(DIM_LEVEL_ID),
             l_object_type,
             'L',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_SYS_DIM_LEVELS_B;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT TO_CHAR(DIM_LEVEL_ID),
             l_object_type,
             'M',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_SYS_DIM_LEVELS_B;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_LOCK_DIMENSION_OBJECT;


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_MEASURE
        This procedure inserts measure entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_MEASURE(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_LOCK_MEASURE';
    l_object_type BSC_OBJECT_LOCKS.OBJECT_TYPE%TYPE;
    l_session_id NUMBER := USERENV('SESSIONID');

BEGIN
    --DBMS_OUTPUT.PUT_LINE('INSERT_LOCK_MEASURE');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_object_type := 'MEASURE';

    -- Insert the ALL entries
    BSC_LOCKS_PVT.INSERT_LOCK_ALL
    (
        p_object_type    => l_object_type
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => p_machine
       ,p_terminal       => p_terminal
       ,p_session_id     => l_session_id
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Insert Measure entries
    INSERT INTO BSC_OBJECT_LOCKS (
        OBJECT_KEY,
        OBJECT_TYPE,
        LOCK_TYPE,
        LAST_SAVE_TIME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SESSION_ID
    ) SELECT TO_CHAR(DATASET_ID),
             l_object_type,
             'W',
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             l_session_id
      FROM BSC_SYS_DATASETS_B;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT TO_CHAR(DATASET_ID),
             l_object_type,
             'L',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_SYS_DATASETS_B;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT TO_CHAR(DATASET_ID),
             l_object_type,
             'M',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_SYS_DATASETS_B;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_LOCK_MEASURE;


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_DATA_COLUMN
        This procedure inserts data column entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_DATA_COLUMN(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_LOCK_DATA_COLUMN';
    l_object_type BSC_OBJECT_LOCKS.OBJECT_TYPE%TYPE;
    l_session_id NUMBER := USERENV('SESSIONID');

BEGIN
    --DBMS_OUTPUT.PUT_LINE('INSERT_LOCK_DATA_COLUMN');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_object_type := 'DATA_COLUMN';

    -- Insert the ALL entries
    BSC_LOCKS_PVT.INSERT_LOCK_ALL
    (
        p_object_type    => l_object_type
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => p_machine
       ,p_terminal       => p_terminal
       ,p_session_id     => l_session_id
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Insert Data Column entries
    INSERT INTO BSC_OBJECT_LOCKS (
        OBJECT_KEY,
        OBJECT_TYPE,
        LOCK_TYPE,
        LAST_SAVE_TIME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SESSION_ID
    ) SELECT TO_CHAR(MEASURE_ID),
             l_object_type,
             'W',
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             l_session_id
      FROM BSC_SYS_MEASURES;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT TO_CHAR(MEASURE_ID),
             l_object_type,
             'L',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_SYS_MEASURES;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT TO_CHAR(MEASURE_ID),
             l_object_type,
             'M',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_SYS_MEASURES;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_LOCK_DATA_COLUMN;


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_CUSTOM_VIEW
        This procedure inserts custom view entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_CUSTOM_VIEW(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_LOCK_CUSTOM_VIEW';
    l_object_type BSC_OBJECT_LOCKS.OBJECT_TYPE%TYPE;
    l_session_id NUMBER := USERENV('SESSIONID');

BEGIN
    --DBMS_OUTPUT.PUT_LINE('INSERT_LOCK_CUSTOM_VIEW');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_object_type := 'CUSTOM_VIEW';

    -- Insert the ALL entries
    BSC_LOCKS_PVT.INSERT_LOCK_ALL
    (
        p_object_type    => l_object_type
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => p_machine
       ,p_terminal       => p_terminal
       ,p_session_id     => l_session_id
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Insert Custom View entries
    INSERT INTO BSC_OBJECT_LOCKS (
        OBJECT_KEY,
        OBJECT_TYPE,
        LOCK_TYPE,
        LAST_SAVE_TIME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SESSION_ID
    ) SELECT TO_CHAR(TAB_ID)||','||TO_CHAR(TAB_VIEW_ID),
             l_object_type,
             'W',
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             l_session_id
      FROM BSC_TAB_VIEWS_B;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT TO_CHAR(TAB_ID)||','||TO_CHAR(TAB_VIEW_ID),
             l_object_type,
             'L',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_TAB_VIEWS_B;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT TO_CHAR(TAB_ID)||','||TO_CHAR(TAB_VIEW_ID),
             l_object_type,
             'M',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_TAB_VIEWS_B;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_LOCK_CUSTOM_VIEW;


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_LAUNCHPAD
        This procedure inserts launchpad entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_LAUNCHPAD(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_LOCK_LAUNCHPAD';
    l_object_type BSC_OBJECT_LOCKS.OBJECT_TYPE%TYPE;
    l_session_id NUMBER := USERENV('SESSIONID');

BEGIN
    --DBMS_OUTPUT.PUT_LINE('INSERT_LOCK_LAUNCHPAD');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_object_type := 'LAUNCHPAD';

    -- Insert the ALL entries
    BSC_LOCKS_PVT.INSERT_LOCK_ALL
    (
        p_object_type    => l_object_type
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => p_machine
       ,p_terminal       => p_terminal
       ,p_session_id     => l_session_id
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Insert Launchpad entries
    INSERT INTO BSC_OBJECT_LOCKS (
        OBJECT_KEY,
        OBJECT_TYPE,
        LOCK_TYPE,
        LAST_SAVE_TIME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SESSION_ID
    ) SELECT TO_CHAR(LINK_ID),
             l_object_type,
             'W',
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             l_session_id
      FROM BSC_TAB_VIEW_LABELS_B
      WHERE LABEL_TYPE = 2;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT TO_CHAR(LINK_ID),
             l_object_type,
             'L',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_TAB_VIEW_LABELS_B
      WHERE LABEL_TYPE = 2;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT TO_CHAR(LINK_ID),
             l_object_type,
             'M',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_TAB_VIEW_LABELS_B
      WHERE LABEL_TYPE = 2;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_LOCK_LAUNCHPAD;


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_PERIODICITY
        This procedure inserts periodicity entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_PERIODICITY(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_LOCK_PERIODICITY';
    l_object_type BSC_OBJECT_LOCKS.OBJECT_TYPE%TYPE;
    l_session_id NUMBER := USERENV('SESSIONID');

BEGIN
    --DBMS_OUTPUT.PUT_LINE('INSERT_LOCK_PERIODICITY');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_object_type := 'PERIODICITY';

    -- Insert the ALL entries
    BSC_LOCKS_PVT.INSERT_LOCK_ALL
    (
        p_object_type    => l_object_type
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => p_machine
       ,p_terminal       => p_terminal
       ,p_session_id     => l_session_id
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Insert Periodicity entries
    INSERT INTO BSC_OBJECT_LOCKS (
        OBJECT_KEY,
        OBJECT_TYPE,
        LOCK_TYPE,
        LAST_SAVE_TIME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SESSION_ID
    ) SELECT TO_CHAR(PERIODICITY_ID),
             l_object_type,
             'W',
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             l_session_id
      FROM BSC_SYS_PERIODICITIES;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT TO_CHAR(PERIODICITY_ID),
             l_object_type,
             'L',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_SYS_PERIODICITIES;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT TO_CHAR(PERIODICITY_ID),
             l_object_type,
             'M',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_SYS_PERIODICITIES;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_LOCK_PERIODICITY;


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_CALENDAR
        This procedure inserts calendar entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_CALENDAR(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_LOCK_CALENDAR';
    l_object_type BSC_OBJECT_LOCKS.OBJECT_TYPE%TYPE;
    l_session_id NUMBER := USERENV('SESSIONID');

BEGIN
    --DBMS_OUTPUT.PUT_LINE('INSERT_LOCK_CALENDAR');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_object_type := 'CALENDAR';

    -- Insert the ALL entries
    BSC_LOCKS_PVT.INSERT_LOCK_ALL
    (
        p_object_type    => l_object_type
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => p_machine
       ,p_terminal       => p_terminal
       ,p_session_id     => l_session_id
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Insert Calendar entries
    INSERT INTO BSC_OBJECT_LOCKS (
        OBJECT_KEY,
        OBJECT_TYPE,
        LOCK_TYPE,
        LAST_SAVE_TIME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SESSION_ID
    ) SELECT TO_CHAR(CALENDAR_ID),
             l_object_type,
             'W',
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             l_session_id
      FROM BSC_SYS_CALENDARS_B;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT TO_CHAR(CALENDAR_ID),
             l_object_type,
             'L',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_SYS_CALENDARS_B;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT TO_CHAR(CALENDAR_ID),
             l_object_type,
             'M',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_SYS_CALENDARS_B;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_LOCK_CALENDAR;


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_TABLE
        This procedure inserts table entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_TABLE(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_LOCK_TABLE';
    l_object_type BSC_OBJECT_LOCKS.OBJECT_TYPE%TYPE;
    l_session_id NUMBER := USERENV('SESSIONID');

BEGIN
    --DBMS_OUTPUT.PUT_LINE('INSERT_LOCK_TABLE');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_object_type := 'TABLE';

    -- Insert the ALL entries
    BSC_LOCKS_PVT.INSERT_LOCK_ALL
    (
        p_object_type    => l_object_type
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => p_machine
       ,p_terminal       => p_terminal
       ,p_session_id     => l_session_id
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Insert Table entries
    INSERT INTO BSC_OBJECT_LOCKS (
        OBJECT_KEY,
        OBJECT_TYPE,
        LOCK_TYPE,
        LAST_SAVE_TIME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SESSION_ID
    ) SELECT TABLE_NAME,
             l_object_type,
             'W',
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             l_session_id
      FROM BSC_DB_TABLES;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT TABLE_NAME,
             l_object_type,
             'L',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_DB_TABLES;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) SELECT TABLE_NAME,
             l_object_type,
             'M',
             p_program_id,
             p_user_id,
             p_machine,
             p_terminal,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID
      FROM BSC_DB_TABLES;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_LOCK_TABLE;


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_INFO
        This procedure inserts a row in the lock table
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
        p_last_save_time: The last time the Object being modified
        p_session_id: The Database Session ID
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_INFO(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_lock_type           IN             varchar2
   ,p_last_save_time      IN             date
   ,p_session_id          IN             number
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_LOCK_INFO';

BEGIN
    --DBMS_OUTPUT.PUT_LINE('INSERT_LOCK_INFO');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO BSC_OBJECT_LOCKS (
        OBJECT_KEY,
        OBJECT_TYPE,
        LOCK_TYPE,
        LAST_SAVE_TIME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SESSION_ID
    ) VALUES (
        p_object_key,
        p_object_type,
        p_lock_type,
        p_last_save_time,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        p_session_id
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_LOCK_INFO;


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_INFO_AUTONOMOUS
        This procedure inserts a row in the lock table
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
        p_last_save_time: The last time the Object being modified
        p_session_id: The Database Session ID
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_INFO_AUTONOMOUS(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_lock_type           IN             varchar2
   ,p_last_save_time      IN             date
   ,p_session_id          IN             number
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_LOCK_INFO_AUTONOMOUS';

BEGIN
    --DBMS_OUTPUT.PUT_LINE('INSERT_LOCK_INFO_AUTONOMOUS');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BSC_LOCKS_PVT.INSERT_LOCK_INFO
    (
        p_object_key     => p_object_key
       ,p_object_type    => p_object_type
       ,p_lock_type      => p_lock_type
       ,p_last_save_time => p_last_save_time
       ,p_session_id     => p_session_id
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );
    COMMIT;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_LOCK_INFO_AUTONOMOUS;


/*------------------------------------------------------------------------------------------
Procedure UPDATE_LOCK_INFO
        This procedure updates the lock table
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
        p_last_save_time: The last time the Object being modified
        p_session_id: The Database Session ID
-------------------------------------------------------------------------------------------*/
Procedure UPDATE_LOCK_INFO(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_lock_type           IN             varchar2
   ,p_last_save_time      IN             date
   ,p_session_id          IN             number
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_LOCK_INFO';

BEGIN
    --DBMS_OUTPUT.PUT_LINE('UPDATE_LOCK_INFO');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_object_key = 'ALL' AND p_object_type = 'ALL') THEN
        UPDATE BSC_OBJECT_LOCKS
        SET LAST_SAVE_TIME = p_last_save_time,
            LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID,
            SESSION_ID = p_session_id
        WHERE p_lock_type = 'ALL'
        OR LOCK_TYPE = p_lock_type;

    ELSE
        UPDATE BSC_OBJECT_LOCKS
        SET LAST_SAVE_TIME = p_last_save_time,
            LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID,
            SESSION_ID = p_session_id
        WHERE OBJECT_TYPE = p_object_type
        AND   OBJECT_KEY = p_object_key
        AND   LOCK_TYPE = p_lock_type;

        IF (SQL%NOTFOUND) THEN
            BSC_LOCKS_PVT.INSERT_LOCK_INFO
            (
                p_object_key     => p_object_key
               ,p_object_type    => p_object_type
               ,p_lock_type      => p_lock_type
               ,p_last_save_time => p_last_save_time
               ,p_session_id     => p_session_id
               ,x_return_status  => x_return_status
               ,x_msg_count      => x_msg_count
               ,x_msg_data       => x_msg_data
            );
        END IF;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END UPDATE_LOCK_INFO;


/*------------------------------------------------------------------------------------------
Procedure UPDATE_LOCK_INFO_AUTONOMOUS
        This procedure updates the lock table
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
        p_last_save_time: The last time the Object being modified
        p_session_id: The Database Session ID
-------------------------------------------------------------------------------------------*/
Procedure UPDATE_LOCK_INFO_AUTONOMOUS(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_lock_type           IN             varchar2
   ,p_last_save_time      IN             date
   ,p_session_id          IN             number
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_LOCK_INFO_AUTONOMOUS';

BEGIN
    --DBMS_OUTPUT.PUT_LINE('UPDATE_LOCK_INFO_AUTONOMOUS');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BSC_LOCKS_PVT.UPDATE_LOCK_INFO
    (
        p_object_key     => p_object_key
       ,p_object_type    => p_object_type
       ,p_lock_type      => p_lock_type
       ,p_last_save_time => p_last_save_time
       ,p_session_id     => p_session_id
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );
    COMMIT;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END UPDATE_LOCK_INFO_AUTONOMOUS;


/*------------------------------------------------------------------------------------------
Procedure INSERT_USER_INFO
        This procedure inserts a row into the lock user table
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        p_user_type:  "L" = Lock, "M" = Modify
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_USER_INFO(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_user_type           IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_USER_INFO';

BEGIN
    --DBMS_OUTPUT.PUT_LINE('INSERT_USER_INFO');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO BSC_OBJECT_LOCK_USERS (
        OBJECT_KEY,
        OBJECT_TYPE,
        USER_TYPE,
        PROGRAM_ID,
        USER_ID,
        MACHINE,
        TERMINAL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    ) VALUES (
        p_object_key,
        p_object_type,
        p_user_type,
        p_program_id,
        p_user_id,
        p_machine,
        p_terminal,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_USER_INFO;


/*------------------------------------------------------------------------------------------
Procedure INSERT_USER_INFO_AUTONOMOUS
        This procedure inserts a row into the lock user table
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        p_user_type:  "L" = Lock, "M" = Modify
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_USER_INFO_AUTONOMOUS(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_user_type           IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_USER_INFO_AUTONOMOUS';

BEGIN
    --DBMS_OUTPUT.PUT_LINE('INSERT_USER_INFO_AUTONOMOUS');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BSC_LOCKS_PVT.INSERT_USER_INFO
    (
        p_object_key     => p_object_key
       ,p_object_type    => p_object_type
       ,p_user_type      => p_user_type
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => p_machine
       ,p_terminal       => p_terminal
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );
    COMMIT;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_USER_INFO_AUTONOMOUS;


/*------------------------------------------------------------------------------------------
Procedure UPDATE_USER_INFO
        This procedure updates the current user info
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        p_user_type:  "L" = Lock, "M" = Modify
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure UPDATE_USER_INFO(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_user_type           IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_USER_INFO';

BEGIN
    --DBMS_OUTPUT.PUT_LINE('UPDATE_USER_INFO');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_object_key = 'ALL' AND p_object_type = 'ALL') THEN
        UPDATE BSC_OBJECT_LOCK_USERS
        SET PROGRAM_ID = p_program_id,
            USER_ID = p_user_id,
            MACHINE = p_machine,
            TERMINAL = p_terminal,
            LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
        WHERE p_user_type = 'ALL'
        OR USER_TYPE = p_user_type;

    ELSE
        UPDATE BSC_OBJECT_LOCK_USERS
        SET PROGRAM_ID = p_program_id,
            USER_ID = p_user_id,
            MACHINE = p_machine,
            TERMINAL = p_terminal,
            LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
        WHERE OBJECT_TYPE = p_object_type
        AND   OBJECT_KEY = p_object_key
        AND   USER_TYPE = p_user_type;

        IF (SQL%NOTFOUND) THEN
            BSC_LOCKS_PVT.INSERT_USER_INFO_AUTONOMOUS
            (
                p_object_key     => p_object_key
               ,p_object_type    => p_object_type
               ,p_user_type      => p_user_type
               ,p_program_id     => p_program_id
               ,p_user_id        => p_user_id
               ,p_machine        => p_machine
               ,p_terminal       => p_terminal
               ,x_return_status  => x_return_status
               ,x_msg_count      => x_msg_count
               ,x_msg_data       => x_msg_data
            );
            BSC_LOCKS_PVT.LOCK_USER
            (
                p_object_key     => p_object_key
               ,p_object_type    => p_object_type
               ,p_user_type      => p_user_type
               ,p_program_id     => p_program_id
               ,p_user_id        => p_user_id
               ,p_machine        => p_machine
               ,p_terminal       => p_terminal
               ,x_return_status  => x_return_status
               ,x_msg_count      => x_msg_count
               ,x_msg_data       => x_msg_data
            );
        END IF;

        IF (p_user_type = 'L') THEN
            UPDATE BSC_OBJECT_LOCK_USERS
            SET PROGRAM_ID = p_program_id,
                USER_ID = p_user_id,
                MACHINE = p_machine,
                TERMINAL = p_terminal,
                LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
            WHERE OBJECT_TYPE = p_object_type
            AND   OBJECT_KEY = p_object_key
            AND   SUBSTR(USER_TYPE,1,1) = 'L';
        END IF;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END UPDATE_USER_INFO;


/*------------------------------------------------------------------------------------------
Procedure UPDATE_USER_INFO_AUTONOMOUS
        This procedure updates the current user info
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        p_user_type:  "L" = Lock, "M" = Modify
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure UPDATE_USER_INFO_AUTONOMOUS(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_user_type           IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_USER_INFO_AUTONOMOUS';

BEGIN
    --DBMS_OUTPUT.PUT_LINE('UPDATE_USER_INFO_AUTONOMOUS');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BSC_LOCKS_PVT.UPDATE_USER_INFO
    (
        p_object_key     => p_object_key
       ,p_object_type    => p_object_type
       ,p_user_type      => p_user_type
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => p_machine
       ,p_terminal       => p_terminal
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );
    COMMIT;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END UPDATE_USER_INFO_AUTONOMOUS;


/*------------------------------------------------------------------------------------------
Procedure DELETE_LOCK_INFO
        This procedure delete the object from the lock tables
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure DELETE_LOCK_INFO(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'DELETE_LOCK_INFO';
    l_last_save_time DATE;

BEGIN
    --DBMS_OUTPUT.PUT_LINE('DELETE_LOCK_INFO');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Lock the user entry of the object
    BSC_LOCKS_PVT.LOCK_USER
    (
        p_object_key     => p_object_key
       ,p_object_type    => p_object_type
       ,p_user_type      => 'M'
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => p_machine
       ,p_terminal       => p_terminal
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );

    -- Lock the object
    l_last_save_time :=
        BSC_LOCKS_PVT.LOCK_OBJECT
        (
            p_object_key     => p_object_key
           ,p_object_type    => p_object_type
           ,p_lock_type      => 'W'
           ,p_query_time     => SYSDATE
           ,p_program_id     => p_program_id
           ,p_user_id        => p_user_id
           ,p_machine        => p_machine
           ,p_terminal       => p_terminal
           ,x_return_status  => x_return_status
           ,x_msg_count      => x_msg_count
           ,x_msg_data       => x_msg_data
        );

    DELETE FROM BSC_OBJECT_LOCKS
    WHERE  OBJECT_TYPE = p_object_type
    AND    OBJECT_KEY = p_object_key;

    DELETE FROM BSC_OBJECT_LOCK_USERS
    WHERE  OBJECT_TYPE = p_object_type
    AND    OBJECT_KEY = p_object_key;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END DELETE_LOCK_INFO;


/*------------------------------------------------------------------------------------------
Procedure DELETE_LOCK_INFO_AUTONOMOUS
        This procedure delete the object from the lock tables
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure DELETE_LOCK_INFO_AUTONOMOUS(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_api_name CONSTANT VARCHAR2(30) := 'DELETE_LOCK_INFO_AUTONOMOUS';

BEGIN
    --DBMS_OUTPUT.PUT_LINE('DELETE_LOCK_INFO_AUTONOMOUS');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BSC_LOCKS_PVT.DELETE_LOCK_INFO
    (
        p_object_key     => p_object_key
       ,p_object_type    => p_object_type
       ,p_program_id     => p_program_id
       ,p_user_id        => p_user_id
       ,p_machine        => p_machine
       ,p_terminal       => p_terminal
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
    );
    COMMIT;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END DELETE_LOCK_INFO_AUTONOMOUS;


/*------------------------------------------------------------------------------------------
Procedure RAISE_EXCEPTION
        This procedure retrieves the session information and raises an exception
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        p_exception_type: "L" = BSC_LOCK_ERR_LOCKED, "M" = BSC_LOCK_ERR_MODIFIED
-------------------------------------------------------------------------------------------*/
Procedure RAISE_EXCEPTION(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_exception_type      IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'RAISE_EXCEPTION';
    l_component BSC_LOOKUPS.MEANING%TYPE;
    l_user_name BSC_APPS_USERS_V.USER_NAME%TYPE;
    l_machine BSC_OBJECT_LOCK_USERS.MACHINE%TYPE;
    l_terminal BSC_OBJECT_LOCK_USERS.TERMINAL%TYPE;

    CURSOR c_get_user(
        c_object_key VARCHAR2
       ,c_object_type VARCHAR2
       ,c_user_type VARCHAR2
    ) IS
        SELECT L.PROGRAM_ID, U.USER_NAME, L.MACHINE, L.TERMINAL
        FROM   BSC_OBJECT_LOCK_USERS L, BSC_APPS_USERS_V U
        WHERE  L.OBJECT_KEY = c_object_key
        AND    L.OBJECT_TYPE = c_object_type
        AND    L.USER_TYPE = c_user_type
        AND    L.USER_ID = U.USER_ID (+);

BEGIN
    --DBMS_OUTPUT.PUT_LINE('RAISE_EXCEPTION: '||p_object_key||' '||p_object_type||' '||p_exception_type);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_component := NULL;
    l_user_name := NULL;
    l_machine := NULL;
    l_terminal := NULL;
    FOR cuser IN c_get_user(p_object_key, p_object_type, p_exception_type) LOOP
        l_component := g_modules(cuser.PROGRAM_ID);
        l_user_name := cuser.USER_NAME;
        l_machine := cuser.MACHINE;
        l_terminal := cuser.TERMINAL;
    END LOOP;

    -- Cover the case when the whole table is locked
    IF (l_component IS NULL) THEN
        FOR cuser IN c_get_user('ALL', 'ALL', p_exception_type) LOOP
            l_component := g_modules(cuser.PROGRAM_ID);
            l_user_name := cuser.USER_NAME;
            l_machine := cuser.MACHINE;
            l_terminal := cuser.TERMINAL;
        END LOOP;
    END IF;

    IF (p_exception_type = 'M') THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_LOCK_ERR_MODIFIED');
    ELSE
        FND_MESSAGE.SET_NAME('BSC','BSC_LOCK_ERR_LOCKED');
    END IF;
    FND_MESSAGE.SET_TOKEN('COMPONENT', NVL(l_component, ''), TRUE);
    FND_MESSAGE.SET_TOKEN('USERNAME' , NVL(l_user_name, ''), TRUE);
    FND_MESSAGE.SET_TOKEN('MACHINE'  , NVL(l_machine, ''), TRUE);
    FND_MESSAGE.SET_TOKEN('TERMINAL' , NVL(l_terminal, ''), TRUE);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END RAISE_EXCEPTION;


/*------------------------------------------------------------------------------------------
Procedure GET_SESSION
        This procedure retrieves the session information (machine, terminal, etc.)
  <parameters>
        x_machine: The machine
        x_terminal: The terminal
-------------------------------------------------------------------------------------------*/
Procedure GET_SESSION(
    x_machine             OUT NOCOPY     varchar2
   ,x_terminal            OUT NOCOPY     varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'GET_SESSION';

    CURSOR c_get_session(c_session_id NUMBER) IS
    SELECT MACHINE, TERMINAL
    FROM v$session S
    WHERE S.AUDSID = c_session_id;

BEGIN
    --DBMS_OUTPUT.PUT_LINE('GET_SESSION');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR csession IN c_get_session(USERENV('SESSIONID')) LOOP
        x_machine := csession.MACHINE;
        x_terminal := csession.TERMINAL;
    END LOOP;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
        RAISE;
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GET_SESSION;

/*------------------------------------------------------------------------------------------
  Procedure INITIALIZE

  DESCRIPTION:
     Populate global variables
-------------------------------------------------------------------------------------------*/
Procedure INITIALIZE
IS
BEGIN
    g_modules(-100) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'BSC_LOADER'); -- Loader UI
    g_modules(-101) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'BSC_LOADER'); -- Loader concurrent program
    g_modules(-200) := bsc_apps.get_lookup_value('BSC_UI_COMMON', 'METADATA_OPTIMIZER'); --Generate Database
    g_modules(-201) := bsc_apps.get_lookup_value('BSC_UI_COMMON', 'METADATA_OPTIMIZER'); --Generate documentation
    g_modules(-202) := bsc_apps.get_lookup_value('BSC_UI_COMMON', 'METADATA_OPTIMIZER'); --Rename interface tables
    g_modules(-203) := bsc_apps.get_lookup_value('BSC_UI_COMMON', 'METADATA_OPTIMIZER'); --Generate Database Configuration
    g_modules(-300) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'BSC_ADMINISTRATOR');
    g_modules(-400) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'KPI_DESIGNER');
    g_modules(-500) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'BSC_BUILDER');
    g_modules(-600) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'OBSC_VIEWER');
    g_modules(-700) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'UPGRADE');
    g_modules(-800) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'SYSTEM_MIGRATION');
    g_modules(-801) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'SYSTEM_MIGRATION');
    g_modules(-802) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'SYSTEM_MIGRATION');
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;


/*------------------------------------------------------------------------------------------
  GET_BSC_SCHEMA

  DESCRIPTION:
     Returns the BSC schema name
-------------------------------------------------------------------------------------------*/
FUNCTION GET_BSC_SCHEMA
RETURN VARCHAR2 IS
    l_bsc_schema VARCHAR2(32);
    dummy1 VARCHAR2(32);
    dummy2 VARCHAR2(32);
    dummy3 BOOLEAN;
BEGIN
    l_bsc_schema := NULL;
    dummy1 := NULL;
    dummy2 := NULL;
    dummy3 := FND_INSTALLATION.GET_APP_INFO('BSC', dummy1, dummy2, l_bsc_schema);
    RETURN l_bsc_schema;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;

END BSC_LOCKS_PVT;

/
