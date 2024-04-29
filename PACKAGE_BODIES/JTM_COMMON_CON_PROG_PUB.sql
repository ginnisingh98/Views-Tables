--------------------------------------------------------
--  DDL for Package Body JTM_COMMON_CON_PROG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTM_COMMON_CON_PROG_PUB" AS
/* $Header: jtmpconb.pls 115.10 2002/12/06 23:38:57 pwu ship $ */

-- Start of Comments
--
-- NAME
--   JTM_COMMON_CON_PROG_PUB
--
-- PURPOSE
--   Central Entry for Mobile Concurrent Programs.
--
--   PROCEDURES:
--
--
-- NOTES
--
--
-- HISTORY
--   04-09-2002 YOHUANG Created.
--   07-29-2002 PWU
--      Make change to catch "run away" interval program.
--      And add log message.
--   09-21 DLIAO
--         populate data in txc_start, txc_end, completion_context
-- Notes
--   Do_Refresh_Mobile_Data will call each procedure according to EXECUTE_FLAG, EXECUTION_ORDER,
--   and FREQUENCY. Do_Refresh_Mobile_Data itself it runs every hour.
--   Each Procedure must make use of SAVEPOINT, because, at the end, Concurrent Manager will commit everything.

-- End of Comments
--
--
--

PROCEDURE Do_Refresh_Mobile_Data
(
    errbuf              OUT   NOCOPY VARCHAR2,
    retcode             OUT   NOCOPY NUMBER
) IS

  -- Reason to Use two cursor is for EXECUTION_ORDER.
  CURSOR X_INTERVAL IS
  SELECT INTERVAL_ID FROM JTM_CON_REQUEST_INTERVALS
  WHERE  INTERVAL <= CURRENT_ROUND;

  CURSOR X_TO_BE_RUN_REQUEST(x_interval_id NUMBER, x_interval NUMBER) IS
  SELECT PACKAGE_NAME, PROCEDURE_NAME
  FROM JTM_CON_REQUEST_DATA req
  WHERE (req.INTERVAL_ID = x_interval_id
            AND   req.EXECUTE_FLAG = 'Y')
  OR
        (req.INTERVAL_ID = x_interval_id
            AND SYSDATE - req.LAST_RUN_DATE > x_interval/1440)
  ORDER BY PRODUCT_CODE, EXECUTION_ORDER;


  dynamic_stmt VARCHAR2(2000);
  l_api_start  DATE;
  l_api_end    DATE;
  l_api_status varchar2(30);

  x_return_status VARCHAR2(1);
  -- For each procedure, it should init the FND_MESSAGE Stack.

  p_api_version_number    NUMBER := 1.0;
  p_init_msg_list         VARCHAR2(1) := FND_API.G_TRUE;
  p_validation_level      NUMBER :=FND_API.G_VALID_LEVEL_FULL;

  x_msg_data VARCHAR2(2000);
  x_msg_index_out NUMBER;
  x_msg_count NUMBER;

 l_interval_id NUMBER;
 l_interval NUMBER := 0;

BEGIN

   -- Update  JTM_CON_REQUEST_FREQUENCY , BOUNCE CURRENT_ROUND with 1
   -- And Lock the whole JTM_CON_REQUEST Table.
   -- When Apply patch to add new FREQUENCY, it shouldn't do any UPDATE.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Initalize the Apps Context

   UPDATE JTM_CON_REQUEST_INTERVALS
   SET CURRENT_ROUND = CURRENT_ROUND + 1 ;

   -- Careful, For Dynamic SQL, VARCHAR2 has to be initialized first.
  -- remove parameters from dynamic sql.
 FOR r_interval IN X_INTERVAL LOOP
           l_interval_id := r_interval.INTERVAL_ID;
       SELECT INTERVAL INTO l_interval FROM jtm_con_request_intervals
       where INTERVAL_ID = r_interval.INTERVAL_ID;
       FOR x_request IN X_TO_BE_RUN_REQUEST(r_interval.INTERVAL_ID, l_interval) LOOP

          l_api_start := sysdate;
           dynamic_stmt := 'BEGIN ' || x_request.PACKAGE_NAME || '.' ||
                           x_request.PROCEDURE_NAME || ' ; END; ';

           JTM_MESSAGE_LOG_PKG.log_msg(
               v_object_id   => 'Do_Refresh_Mobile_Data',
               v_object_name => 'JTM_COMMON_CON_PROG_PUB',
               v_message     => 'Execute ' || dynamic_stmt,
               v_level_id    => JTM_HOOK_UTIL_PKG.g_debug_level_sql,
               v_module      => 'JTM_COMMON_CON_PROG_PUB');


           BEGIN
          	EXECUTE IMMEDIATE dynamic_stmt;

           l_api_end := sysdate;
           l_api_status := 'COMPLETED';

	    UPDATE JTM_CON_REQUEST_INTERVALS
            SET CURRENT_ROUND = 0
            WHERE INTERVAL_ID = r_interval.INTERVAL_ID;

     	   EXCEPTION
       	        WHEN OTHERS THEN
                 JTM_MESSAGE_LOG_PKG.log_msg(
                   v_object_id   => x_request.PROCEDURE_NAME,
                   v_object_name => x_request.PACKAGE_NAME,
                   v_message     => 'Error ocurrs on exection',
                   v_level_id    => JTM_HOOK_UTIL_PKG.g_debug_level_error,
                   v_module      => 'JTM_COMMON_CON_PROG_PUB');

                   l_api_end := sysdate;
                   l_api_status := 'FAILED';


     	  END;

     	    UPDATE JTM_CON_REQUEST_DATA
 	    SET LAST_TXC_START = l_api_start,
 	    	LAST_TXC_END = l_api_end,
 		COMPLETION_TEXT = l_api_status
 	    WHERE PACKAGE_NAME = x_request.PACKAGE_NAME
 	    AND PROCEDURE_NAME = x_request.PROCEDURE_NAME;

          COMMIT;
        END LOOP;
   END LOOP;

   UPDATE JTM_CON_REQUEST_INTERVALS
   SET CURRENT_ROUND = 0
   WHERE CURRENT_ROUND >= INTERVAL;
   Commit;


   retcode := 0;
Exception
     When others then

         UPDATE JTM_CON_REQUEST_INTERVALS
         SET CURRENT_ROUND = 0
         WHERE CURRENT_ROUND >= INTERVAL;

         JTM_MESSAGE_LOG_PKG.log_msg(
           v_object_id   => 'Do_Refresh_Mobile_Data',
           v_object_name => 'JTM_COMMON_CON_PROG_PUB',
           v_message     => 'Exection occurs.',
           v_level_id    => JTM_HOOK_UTIL_PKG.g_debug_level_error,
           v_module      => 'JTM_COMMON_CON_PROG_PUB');



END Do_Refresh_Mobile_Data;

END JTM_COMMON_CON_PROG_PUB;

/
