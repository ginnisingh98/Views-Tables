--------------------------------------------------------
--  DDL for Package Body IEC_COMMON_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_COMMON_UTIL_PVT" AS
/* $Header: IECCMUTB.pls 120.1 2006/03/28 07:30:08 minwang noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'IEC_COMMON_UTIL_PVT';

-- Translated error message that will be raised if an exception occurs
-- Encoded error message will also be initialized in FND_MESSAGE
-- so that calling program can log the encoded message with appropriate
-- module name

g_error_message VARCHAR2(4000) := NULL;
g_encoded_message VARCHAR2(4000) := NULL;

FUNCTION Get_AppsSchemaName

RETURN VARCHAR2

IS

   l_schema_name VARCHAR2(30);

BEGIN


   SELECT ORACLE_USERNAME

   INTO l_schema_name

   FROM FND_ORACLE_USERID

   WHERE READ_ONLY_FLAG = 'U';



   RETURN l_schema_name;



EXCEPTION

   WHEN OTHERS THEN

      RAISE fnd_api.g_exc_unexpected_error;

END Get_AppsSchemaName;



PROCEDURE Init_SourceTypeNotSupportedMsg

   ( p_source_type IN VARCHAR2)

IS

BEGIN



   -- Since this is a shared utility package, we will not

   -- log the message, calling program will do logging

   -- so that error can be logged with calling program's module

   IEC_OCS_LOG_PVT.Init_SourceTypeNotSupportedMsg

      ( p_source_type

      , g_error_message -- returns translated error message string

      , g_encoded_message -- returns encoded error message string

      );



END Init_SourceTypeNotSupportedMsg;



PROCEDURE Init_SourceTypeDoesNotExistMsg

   ( p_source_type IN VARCHAR2)

IS

BEGIN



   -- Since this is a shared utility package, we will not

   -- log the message, calling program will do logging

   -- so that error can be logged with calling program's module

   IEC_OCS_LOG_PVT.Init_SourceTypeDoesNotExistMsg

      ( p_source_type

      , g_error_message -- returns translated error message string

      , g_encoded_message -- returns encoded error message string

      );





END Init_SourceTypeDoesNotExistMsg;



PROCEDURE Init_SqlErrmMsg

   ( p_sql_errm IN VARCHAR2)

IS

BEGIN



   -- Since this is a shared utility package, we will not

   -- log the message, calling program will do logging

   -- so that error can be logged with calling program's module

   IEC_OCS_LOG_PVT.Init_SqlErrmMsg

      ( p_sql_errm

      , g_error_message   -- returns translated error message string

      , g_encoded_message -- returns encoded error message string

      );



END Init_SqlErrmMsg;



-----------------------------++++++-------------------------------

--

-- Start of comments

--

--  API name    : Get_SourceTypeView

--  Type        : Private

--  Pre-reqs    : None

--  Function    : Return the source type view name for specified

--                target group.  Raises exception if unable to

--                locate view.

--

--  Parameters  : p_list_id              IN     NUMBER             Required

--                x_source_type_view        OUT VARCHAR2           Required

--

--  Version     : Initial version 1.0

--

-- End of comments

--

-----------------------------++++++-------------------------------

PROCEDURE Get_SourceTypeView

   ( p_list_id          IN            NUMBER

   , x_source_type_view    OUT NOCOPY VARCHAR2)

IS



   l_ignore           VARCHAR2(500);
   l_source_type_code VARCHAR2(50);

   l_schema           VARCHAR2(30);

BEGIN



   x_source_type_view := NULL;



   -- Get Source Type of List

   BEGIN

      EXECUTE IMMEDIATE

         'SELECT B.TAG, A.LIST_SOURCE_TYPE

          FROM AMS_LIST_HEADERS_ALL A, IEC_LOOKUPS B

          WHERE A.LIST_HEADER_ID = :list_id

          AND B.LOOKUP_TYPE = ''IEC_SOURCE_VIEW_MAP''

          AND A.LIST_SOURCE_TYPE = B.LOOKUP_CODE'

      INTO x_source_type_view, l_source_type_code

      USING p_list_id;

   EXCEPTION

      WHEN NO_DATA_FOUND THEN

         -- Get source type of list for logging purposes

         BEGIN

            SELECT LIST_SOURCE_TYPE

            INTO l_source_type_code

            FROM AMS_LIST_HEADERS_ALL

            WHERE LIST_HEADER_ID = p_list_id;

         EXCEPTION

            WHEN OTHERS THEN

               l_source_type_code := NULL;

         END;



         Init_SourceTypeNotSupportedMsg(l_source_type_code);

         RAISE_APPLICATION_ERROR(-20999, g_error_message);

      WHEN OTHERS THEN

         Init_SqlErrmMsg(SQLERRM);

         RAISE_APPLICATION_ERROR(-20999, g_error_message);

   END;

  l_schema := Get_AppsSchemaName;

   BEGIN

      EXECUTE IMMEDIATE

         'SELECT VIEW_NAME

          FROM ALL_VIEWS

          WHERE VIEW_NAME = UPPER(:source_type_view)

          AND OWNER = :apps_schema'

      INTO l_ignore

      USING x_source_type_view, l_schema;

   EXCEPTION

      WHEN NO_DATA_FOUND THEN

         Init_SourceTypeDoesNotExistMsg(l_source_type_code);
         RAISE_APPLICATION_ERROR(-20999, g_error_message);

   END;



END Get_SourceTypeView;



-----------------------------++++++-------------------------------

--

-- Start of comments

--

--  API name    : Get_SubsetName

--  Type        : Private

--  Pre-reqs    : None

--  Function    : Return the name for specified subset.

--                Initializes FND_MESSAGE and raises

--                exception if unable to locate name.

--

--  Parameters  : p_subset_id       IN     NUMBER             Required

--                x_subset_name        OUT VARCHAR2           Required

--

--  Version     : Initial version 1.0

--

-- End of comments

--

-----------------------------++++++-------------------------------

PROCEDURE Get_SubsetName

   ( p_subset_id   IN            NUMBER

   , x_subset_name    OUT NOCOPY VARCHAR2)

IS

BEGIN



   x_subset_name := NULL;



   -- Get Subset Name

   BEGIN

      EXECUTE IMMEDIATE

         'SELECT SUBSET_NAME

          FROM IEC_G_LIST_SUBSETS

          WHERE LIST_SUBSET_ID = :subset_id'

      INTO x_subset_name

      USING p_subset_id;

   EXCEPTION

      WHEN NO_DATA_FOUND THEN

         x_subset_name := NULL;

      WHEN OTHERS THEN

         Init_SqlErrmMsg(SQLERRM);

         RAISE_APPLICATION_ERROR(-20999, g_error_message);

   END;



END Get_SubsetName;



-----------------------------++++++-------------------------------

--

-- Start of comments

--

--  API name    : Get_ListName

--  Type        : Private

--  Pre-reqs    : None

--  Function    : Return the name for specified list.

--                Initializes FND_MESSAGE and raises

--                exception if unable to locate name.

--

--  Parameters  : p_list_id       IN     NUMBER             Required

--                x_list_name        OUT VARCHAR2           Required

--

--  Version     : Initial version 1.0

--

-- End of comments

--

-----------------------------++++++-------------------------------

PROCEDURE Get_ListName

   ( p_list_id   IN            NUMBER

   , x_list_name    OUT NOCOPY VARCHAR2)

IS

BEGIN

   -- Get List Name

   BEGIN

      EXECUTE IMMEDIATE

         'SELECT LIST_NAME

          FROM AMS_LIST_HEADERS_VL

          WHERE LIST_HEADER_ID = :list_id'

      INTO x_list_name

      USING p_list_id;

   EXCEPTION

      WHEN NO_DATA_FOUND THEN

         x_list_name := NULL;

      WHEN OTHERS THEN

         Init_SqlErrmMsg(SQLERRM);

         RAISE_APPLICATION_ERROR(-20999, g_error_message);

   END;



END Get_ListName;



-----------------------------++++++-------------------------------

--

-- Start of comments

--

--  API name    : Get_ScheduleName

--  Type        : Private

--  Pre-reqs    : None

--  Function    : Return the name for specified schedule.

--                Initializes FND_MESSAGE and raises

--                exception if unable to locate name.

--

--  Parameters  : p_schedule_id       IN     NUMBER             Required

--                x_schedule_name        OUT VARCHAR2           Required

--

--  Version     : Initial version 1.0

--

-- End of comments

--

-----------------------------++++++-------------------------------

PROCEDURE Get_ScheduleName

   ( p_schedule_id   IN            NUMBER

   , x_schedule_name    OUT NOCOPY VARCHAR2)

IS

BEGIN

   -- Get Schedule Name

   BEGIN

      EXECUTE IMMEDIATE

         'SELECT SCHEDULE_NAME

          FROM AMS_CAMPAIGN_SCHEDULES_VL

          WHERE SCHEDULE_ID = :schedule_id'

      INTO x_schedule_name

      USING p_schedule_id;

   EXCEPTION

      WHEN NO_DATA_FOUND THEN

         x_schedule_name := NULL;

      WHEN OTHERS THEN

         Init_SqlErrmMsg(SQLERRM);

         RAISE_APPLICATION_ERROR(-20999, g_error_message);

   END;



END Get_ScheduleName;



-----------------------------++++++-------------------------------

--

-- Start of comments

--

--  API name    : Get_ScheduleId

--  Type        : Private

--  Pre-reqs    : None

--  Function    : Return the schedule id for specified list.

--                Initializes FND_MESSAGE and raises

--                exception if unable to locate name.

--

--  Parameters  : p_list_id         IN     NUMBER           Required

--                x_schedule_id        OUT NUMBER           Required

--

--  Version     : Initial version 1.0

--

-- End of comments

--

-----------------------------++++++-------------------------------

PROCEDURE Get_ScheduleId

   ( p_list_id     IN            NUMBER

   , x_schedule_id    OUT NOCOPY NUMBER)

IS

BEGIN

   -- Get Campaign Schedule Id

   BEGIN

      EXECUTE IMMEDIATE

         'SELECT LIST_USED_BY_ID

          FROM AMS_ACT_LISTS

          WHERE LIST_HEADER_ID = :list_id

          AND LIST_USED_BY = ''CSCH''

          AND LIST_ACT_TYPE = ''TARGET'''

      INTO x_schedule_id

      USING p_list_id;

   EXCEPTION

      WHEN OTHERS THEN

         Init_SqlErrmMsg(SQLERRM);

         RAISE_APPLICATION_ERROR(-20999, g_error_message);

   END;



END Get_ScheduleId;



-----------------------------++++++-------------------------------

--

-- Start of comments

--

--  API name    : Get_ListId

--  Type        : Private

--  Pre-reqs    : None

--  Function    : Return the list header id for specified schedule.

--                Initializes FND_MESSAGE and raises

--                exception if unable to locate name.

--

--  Parameters  : p_schedule_id IN     NUMBER           Required

--                x_list_id        OUT NUMBER           Required

--

--  Version     : Initial version 1.0

--

-- End of comments

--

-----------------------------++++++-------------------------------

PROCEDURE Get_ListId

   ( p_schedule_id IN            NUMBER

   , x_list_id        OUT NOCOPY NUMBER)

IS

BEGIN

   -- Get List Header Id

   BEGIN

      EXECUTE IMMEDIATE

         'SELECT LIST_HEADER_ID

          FROM IEC_G_AO_LISTS_V

          WHERE SCHEDULE_ID = :schedule_id

          AND LANGUAGE = USERENV(''LANG'')'

      INTO x_list_id

      USING p_schedule_id;

   EXCEPTION

      WHEN OTHERS THEN

         Init_SqlErrmMsg(SQLERRM);

         RAISE_APPLICATION_ERROR(-20999, g_error_message);

   END;



END Get_ListId;



-----------------------------++++++-------------------------------

--

-- Start of comments

--

--  API name    : LOCK_SCHEDULE

--  Type        : Public

--  Pre-reqs    : None

--  Function    : Attempt to lock the schedule.

--  Parameters  : P_SOURCE_ID        IN     NUMBER    Required

--                P_SCHED_ID         IN     NUMBER    Required

--                P_SERVER_ID        IN     NUMBER    Required

--                P_LOCK_ATTEMPTS    IN     VARCHAR2  Required

--                P_ATTEMPT_INTERVAL IN     VARCHAR2  Required

--                X_SUCCESS_FLAG        OUT VARCHAR2  Required

--  Future      : Not sure this should be an autonomous transaction.  Leaving

--                for now.

--

--  Version     : Initial version 1.0

--

-- End of comments

--

-----------------------------++++++-------------------------------

PROCEDURE Lock_Schedule

   ( P_SOURCE_ID        IN            NUMBER

   , P_SCHED_ID         IN            NUMBER

   , P_SERVER_ID        IN            NUMBER

   , P_LOCK_ATTEMPTS    IN            NUMBER

   , P_ATTEMPT_INTERVAL IN            NUMBER

   , X_SUCCESS_FLAG        OUT NOCOPY VARCHAR2

   )

IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  l_api_name CONSTANT VARCHAR2(30) := 'Lock_Schedule';

  l_server_id NUMBER;

  l_lock_flag VARCHAR2(1);

  l_refresh_rate NUMBER;

  l_insert_flag VARCHAR2(1);

  l_lock_attempts NUMBER;



BEGIN

  l_server_id := -1;

  l_lock_flag := 'N';

  l_refresh_rate := -1;

  l_insert_flag := 'N';

    ----------------------------------------------------------------

    -- initialize the local variables to indicate that we do not

    -- have the lock.

    ----------------------------------------------------------------

    X_SUCCESS_FLAG := 'N';

    l_lock_attempts := P_LOCK_ATTEMPTS;



    LOOP

       BEGIN



          SELECT server_id

          ,      nvl( lock_flag, 'N' )

          INTO   l_server_id

          ,      l_lock_flag

              FROM   IEC_G_LIST_LOCK_STATES

	      WHERE  CAMPAIGN_SCHEDULE_ID = P_SCHED_ID

          FOR UPDATE;



          ----------------------------------------------------------------

          -- If either we were given the lock or the schedule is not locked

          -- then we can proceed to locking the schedule.

          ----------------------------------------------------------------

          IF (l_server_id = P_SERVER_ID OR l_lock_flag = 'N')

          THEN

             X_SUCCESS_FLAG := 'Y';

             EXIT;



          ----------------------------------------------------------------

          -- If another server has locked the schedule then we will wait

          -- for 5 seconds and try again.

          ----------------------------------------------------------------

          ELSE

             COMMIT;

             l_lock_attempts := l_lock_attempts - 1;



             ----------------------------------------------------------------

             -- If already tried P_LOCK_ATTEMPTS times to gain lock

             -- then exit out of loop otherwise sleep for P_ATTEMPT_INTERVAL

             -- seconds and try again.

             ----------------------------------------------------------------

             IF (l_lock_attempts <= 0 )

             THEN

                EXIT;

             ELSE

                DBMS_LOCK.SLEEP(P_ATTEMPT_INTERVAL);

             END IF;

          END IF;



       EXCEPTION

         WHEN NO_DATA_FOUND

         THEN

            INSERT INTO IEC_G_LIST_LOCK_STATES

            (           cpn_lock_state_id

            ,           campaign_schedule_id

            ,           server_id

            ,           lock_flag

            ,           object_version_number )

            VALUES

            (           iec_g_list_lock_states_s.nextval

            ,           p_sched_id

            ,           p_server_id

            ,           'Y'

            ,           1);

            l_insert_flag := 'Y';



         WHEN OTHERS

         THEN

            RAISE;

       END;



    END LOOP;



     ----------------------------------------------------------------

     -- If we could not get the lock try to see if the server with

     -- the lock is still operating.  If it isn't than grab the

     -- entry and lock it.

     ----------------------------------------------------------------

     IF (X_SUCCESS_FLAG = 'N')

     THEN



        BEGIN

           SELECT a.rt_refresh_rate

           INTO   l_refresh_rate

           FROM   ieo_svr_types_b a

           ,      ieo_svr_servers b

           WHERE  a.type_id = b.type_id

           AND    b.server_id = l_server_id;

        EXCEPTION

           -- We need to let them know that the necessary parameter

           -- does not exist.

           WHEN OTHERS THEN

              RAISE;

        END;



        l_refresh_rate := 3 * l_refresh_rate;



        BEGIN



           -- The server that grabbed the lock hasn't updated within

           -- 3 X the refresh rate.  We therefore allow the lock.

           SELECT 'Y'

           INTO   X_SUCCESS_FLAG

           FROM   ieo_svr_rt_info

           WHERE  last_update_date < ( sysdate - l_refresh_rate / 1440 )

           AND    server_id = l_server_id;



        EXCEPTION

           WHEN NO_DATA_FOUND

           THEN

              -- The server that grabbed the lock has updated within

              -- 3 X the refresh rate.  We therefore do not allow the lock.

              NULL;

           WHEN OTHERS

           THEN

              RAISE;

        END;





     END IF;



     IF X_SUCCESS_FLAG = 'Y' AND l_insert_flag = 'N'

     THEN

        BEGIN



           IF l_lock_flag = 'N' THEN



              ----------------------------------------------------------------

              -- Attempt to update the lock entry if it isn't currently locked.

              ----------------------------------------------------------------

              UPDATE IEC_G_LIST_LOCK_STATES

              SET    LOCK_FLAG = 'Y'

              ,      SERVER_ID = P_SERVER_ID

              WHERE  CAMPAIGN_SCHEDULE_ID = P_SCHED_ID

              AND    LOCK_FLAG = 'N';



              ----------------------------------------------------------------

              --  If we were unable to lock the schedule then set the success

              -- flag to 'N'.

              ----------------------------------------------------------------

              IF SQL%ROWCOUNT = 0 THEN

                 X_SUCCESS_FLAG := 'N';

              END IF;



           ELSIF l_server_id <> P_SERVER_ID AND l_lock_flag = 'Y' THEN



              ----------------------------------------------------------------

              -- Attempt to update the lock entry if it isn't currently locked.

              ----------------------------------------------------------------

              UPDATE IEC_G_LIST_LOCK_STATES

              SET    LOCK_FLAG = 'Y'

              ,      SERVER_ID = P_SERVER_ID

              WHERE  CAMPAIGN_SCHEDULE_ID = P_SCHED_ID;



              ----------------------------------------------------------------

              --  If we were unable to lock the schedule then set the success

              -- flag to 'N'.

              ----------------------------------------------------------------

              IF SQL%ROWCOUNT = 0 THEN

                 X_SUCCESS_FLAG := 'N';

              END IF;



           END IF;



        EXCEPTION

        WHEN OTHERS

        THEN

           RAISE;

        END;

     END IF;



  ----------------------------------------------------------------

  -- Commit all updates to the tables.

  ----------------------------------------------------------------

  COMMIT;



EXCEPTION

  WHEN OTHERS THEN

    ROLLBACK;

    Init_SqlErrmMsg(SQLERRM);

    RAISE_APPLICATION_ERROR(-20999, g_error_message);



END Lock_Schedule;



-----------------------------++++++-------------------------------

--

-- Start of comments

--

--  API name    : UNLOCK_SCHEDULE

--  Type        : Public

--  Pre-reqs    : None

--  Function    : Attempt to unlock the schedule.

--  Parameters  : P_SOURCE_ID        IN     NUMBER    Required

--                P_SCHED_ID         IN     NUMBER    Required

--                P_SERVER_ID        IN     NUMBER    Required

--                X_SUCCESS_FLAG        OUT VARCHAR2  Required

--  Future      : Not sure this should be an autonomous transaction.  Leaving

--                for now.

--

--  Version     : Initial version 1.0

--

-- End of comments

--

-----------------------------++++++-------------------------------

PROCEDURE Unlock_Schedule

   ( P_SOURCE_ID    IN            NUMBER

   , P_SCHED_ID     IN            NUMBER

   , P_SERVER_ID    IN            NUMBER

   , X_SUCCESS_FLAG    OUT NOCOPY VARCHAR2

   )

IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  l_api_name CONSTANT VARCHAR2(30) := 'Unlock_Schedule';



BEGIN



   ----------------------------------------------------------------

   -- Attempt to update the lock entry.

   ----------------------------------------------------------------

   UPDATE IEC_G_LIST_LOCK_STATES

   SET    LOCK_FLAG = 'N'

   ,      SERVER_ID = P_SERVER_ID

   WHERE  CAMPAIGN_SCHEDULE_ID = P_SCHED_ID

   AND    SERVER_ID = P_SERVER_ID;



   ----------------------------------------------------------------

   --  If we weren't able to unlock the schedule b/c this server

   --  doesn't have a lock on the schedule, then set the success

   --  flag to 'N'.

   ----------------------------------------------------------------

   IF SQL%ROWCOUNT = 0 THEN

      X_SUCCESS_FLAG := 'N';

   ELSE

      X_SUCCESS_FLAG := 'Y';

   END IF;



  ----------------------------------------------------------------

  -- Commit all updates to the tables.

  ----------------------------------------------------------------

  COMMIT;



EXCEPTION

  WHEN OTHERS THEN

    ROLLBACK;

    Init_SqlErrmMsg(SQLERRM);

    RAISE_APPLICATION_ERROR(-20999, g_error_message);



END Unlock_Schedule;



-----------------------------++++++-------------------------------

--

-- Start of comments

--

--  API name    : LOCK_SCHEDULE

--  Type        : Public

--  Pre-reqs    : None

--  Function    : Either attempt to gain a lock on the schedule or unlock the schedule.

--

--  Parameters  : P_SOURCE_ID        IN     NUMBER    Required

--                P_SCHED_ID         IN     NUMBER    Required

--                P_SERVER_ID        IN     NUMBER    Required

--                P_LOCK_FLAG        IN     NUMBER    Required

--                X_SUCCESS_FLAG        OUT VARCHAR2  Required

--  Future      : Not sure this should be an autonomous transaction.  Leaving

--                for now.

--

--  Version     : Initial version 1.0

--

-- End of comments

--

-----------------------------++++++-------------------------------

PROCEDURE Lock_Schedule

   ( P_SOURCE_ID    IN            NUMBER

   , P_SCHED_ID     IN            NUMBER

   , P_SERVER_ID    IN            NUMBER

   , P_LOCK_FLAG    IN            VARCHAR2

   , X_SUCCESS_FLAG    OUT NOCOPY VARCHAR2

   )

IS

  l_api_name CONSTANT VARCHAR2(30) := 'Lock_Schedule';

  l_attempt_interval NUMBER := 5;

  l_lock_attempts NUMBER := 20;

  l_success_flag VARCHAR2(1);



BEGIN



  IF P_LOCK_FLAG = 'Y'

  THEN



     LOCK_SCHEDULE

        ( P_SOURCE_ID => P_SOURCE_ID

        , P_SCHED_ID  => P_SCHED_ID

        , P_SERVER_ID => P_SERVER_ID

        , P_LOCK_ATTEMPTS => l_lock_attempts

        , P_ATTEMPT_INTERVAL => l_attempt_interval

        , X_SUCCESS_FLAG => l_success_flag

        );

   ELSE

     UNLOCK_SCHEDULE

        ( P_SOURCE_ID => P_SOURCE_ID

        , P_SCHED_ID  => P_SCHED_ID

        , P_SERVER_ID => P_SERVER_ID

        , X_SUCCESS_FLAG => l_success_flag

        );

   END IF;



   X_SUCCESS_FLAG := l_success_flag;



EXCEPTION

  WHEN OTHERS THEN

    RAISE;

END Lock_Schedule;

END IEC_COMMON_UTIL_PVT;


/
