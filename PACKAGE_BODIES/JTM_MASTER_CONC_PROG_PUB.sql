--------------------------------------------------------
--  DDL for Package Body JTM_MASTER_CONC_PROG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTM_MASTER_CONC_PROG_PUB" AS
/* $Header: jtmpconb.pls 120.2 2006/01/13 01:16:36 utekumal noship $ */

-- Start of Comments
--
-- NAME
--   JTM_MASTER_CONC_PROG_PUB
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
--  01-14-2003 PWU
--  re-write the concurrent program. The package name is change, too.
--  we now accept parameter and get rid of the interval counter.
--   09-21 DLIAO
--         populate data in txc_start, txc_end, completion_context
--   03-01-2004 PWU
--      Change the protocol to call registered program by passing two output
--      parameters status and message to report the running status of the
--      program.
-- Notes
--   Do_Refresh_Mobile_Data will call each procedure according to EXECUTE_FLAG, EXECUTION_ORDER,
--   and FREQUENCY. Do_Refresh_Mobile_Data itself it runs every hour.
--   Each Procedure must make use of SAVEPOINT, because, at the end, Concurrent Manager will commit everything.
-- End of Comments
--
--
--
G_PKG_NAME     CONSTANT VARCHAR2(30) := 'JTM_MASTER_CONC_PROG_PUB';

PROCEDURE Do_Refresh_Mobile_Data
(
    errbuf              OUT NOCOPY VARCHAR2,
    retcode             OUT NOCOPY NUMBER,
    Category_Type       IN    VARCHAR2
) as

  L_API_NAME CONSTANT varchar2(30) := 'DO_REFRESH_MOBILE_DATA';

  CURSOR X_TO_BE_RUN_REQUEST(p_Category_Type varchar2) IS
  SELECT PACKAGE_NAME, PROCEDURE_NAME
  FROM JTM_CON_REQUEST_DATA
  WHERE Category = p_Category_Type
  AND EXECUTE_FLAG = 'Y'
  ORDER BY EXECUTION_ORDER, PRODUCT_CODE;

  l_active_count number := 1;
  l_proc_start Date;
  l_start_log_id number;

  dynamic_stmt VARCHAR2(2000);
  l_api_start  DATE;
  l_api_end    DATE := null;
  l_api_status varchar2(30);
  l_status_message VARCHAR2(2000);
  l_full_procedure_name varchar2(60);
  l_log_id NUMBER;

  l_status VARCHAR2(30);
  l_message VARCHAR2(2000);
  l_successful_msg CONSTANT varchar2(200) := 'This program runs successfully.';
  l_conc_message varchar2(2000) := l_successful_msg;

BEGIN
   retcode := 0;
   errbuf := 'OK';
   l_proc_start := sysdate;

   JTM_MESSAGE_LOG_PKG.log_msg(
       v_object_id   => L_API_NAME,
       v_object_name => G_PKG_NAME,
       v_message     => 'Category = ' || Category_Type,
       v_level_id    => JTM_HOOK_UTIL_PKG.g_debug_level_sql,
       v_module      => G_PKG_NAME);
    /* check to see if there are already any active session of the
       same program with same parameter are running. If so, exit out
       to avoid the multiple session
    */
    SELECT count(*)
    INTO l_active_count
    FROM fnd_concurrent_requests req, fnd_concurrent_programs cp
    WHERE req.argument1 = Category_Type
    AND req.PHASE_CODE = 'R'
    AND req.STATUS_CODE = 'R'
    AND req.PROGRAM_APPLICATION_ID = 874
    AND req.PROGRAM_APPLICATION_ID = cp.APPLICATION_ID
    AND req.CONCURRENT_PROGRAM_ID = cp.CONCURRENT_PROGRAM_ID
    AND cp.concurrent_program_name = 'JTM_MASTER_CONC_PROG';
    IF (l_active_count > 1) THEN
       errbuf := 'There are multiple active sessions of JTM concurrent program'
           || ' with argument = ' || Category_Type;
       return;
    END IF;

    JTM_MESSAGE_LOG_PKG.INSERT_CONC_STATUS_LOG
        (v_package_name => G_PKG_NAME
	    ,v_procedure_name => L_API_NAME
	    ,v_con_query_id => NULL
        ,v_query_stmt => Category_Type
        ,v_start_time => l_proc_start
        ,v_end_time => NULL
        ,v_status => 'Running'
        ,v_message => 'JTM master concurrent program is called.'
        ,x_log_id => l_start_log_id
        ,x_status => l_status
        ,x_msg_data => l_message);

    IF (l_status = 'E') THEN
       RAISE JTM_MESSAGE_LOG_PKG.G_EXC_ERROR;
    END IF;

    FOR x_request IN X_TO_BE_RUN_REQUEST(Category_Type) LOOP
        l_api_start := sysdate;
        l_api_end := null;
        l_api_status := 'Running';
        l_full_procedure_name := x_request.PACKAGE_NAME || '.' ||
                                 x_request.PROCEDURE_NAME;

          /* Add run time status into JTM concurrent prog log table */
        JTM_MESSAGE_LOG_PKG.INSERT_CONC_STATUS_LOG
     	(v_package_name => x_request.PACKAGE_NAME
	    ,v_procedure_name =>  x_request.PROCEDURE_NAME
	    ,v_con_query_id => NULL
        ,v_query_stmt => Category_Type
        ,v_start_time => l_api_start
        ,v_end_time => l_api_end
        ,v_status =>  l_api_status
        ,v_message => 'The program is running.'
        ,x_log_id => l_log_id
        ,x_status => l_status
        ,x_msg_data => l_message);

        BEGIN
            dynamic_stmt := 'BEGIN ' || l_full_procedure_name || '(:1,:2); END; ';
            EXECUTE IMMEDIATE dynamic_stmt
              using out l_api_status, out l_status_message;
            l_api_end := sysdate;
            IF (upper(l_api_status) = upper(JTM_CON_QUERY_REQUEST_PKG.G_ERROR) ) THEN
                retcode := -1;
                IF (l_conc_message = l_successful_msg) THEN
                   l_conc_message:= 'Error message from ' || l_full_procedure_name
                    || ': ' || l_status_message;
                ELSE
                   l_conc_message:= l_conc_message || '. Error message from '
                        || l_full_procedure_name || ': ' || l_status_message;

                END IF;
            END IF;
        EXCEPTION
           WHEN OTHERS THEN
             /* This is to handle the registered program which has not added
                two output parameters */
             IF (sqlcode = -6537 OR sqlcode = -6550) THEN
                BEGIN
                    dynamic_stmt := 'BEGIN ' || l_full_procedure_name || '; END; ';
                    EXECUTE IMMEDIATE dynamic_stmt;
                    l_api_status := JTM_CON_QUERY_REQUEST_PKG.G_FINE;
                    l_status_message := 'No message from '|| l_full_procedure_name
                      || '. Assume all are fine.';
                    l_api_end := sysdate;
                EXCEPTION
                   WHEN OTHERS THEN
                       JTM_MESSAGE_LOG_PKG.log_msg(
                          v_object_id   => x_request.PROCEDURE_NAME,
                          v_object_name => x_request.PACKAGE_NAME,
                          v_message     => 'Error ocurrs on execution',
                          v_level_id    => JTM_HOOK_UTIL_PKG.g_debug_level_error,
                          v_module      => G_PKG_NAME);
                       if (errbuf = 'OK') then
                          errbuf := 'Error in ' || l_full_procedure_name;
                       else
                         errbuf := errbuf ||', ' || l_full_procedure_name;
                       end if;
                       retcode := -1;

                       l_api_end := sysdate;
                       l_api_status := JTM_CON_QUERY_REQUEST_PKG.G_ERROR;
                       l_status_message := SQLERRM;
                END;
             ELSE
                 JTM_MESSAGE_LOG_PKG.log_msg(
                    v_object_id   => x_request.PROCEDURE_NAME,
                    v_object_name => x_request.PACKAGE_NAME,
                    v_message     => 'Error ocurrs on exection',
                    v_level_id    => JTM_HOOK_UTIL_PKG.g_debug_level_error,
                    v_module      => G_PKG_NAME);
                 if (errbuf = 'OK') then
                    errbuf := 'Error in ' || G_PKG_NAME ||
                      ' while running ' || l_full_procedure_name;
                 else
                   errbuf := errbuf ||', ' ||l_full_procedure_name;
                 end if;
    		     retcode := -1;

                 l_api_end := sysdate;
                 l_api_status := JTM_CON_QUERY_REQUEST_PKG.G_ERROR;
                 l_status_message := SQLERRM;
             END IF;
      END;

      dynamic_stmt := 'UPDATE JTM_CON_REQUEST_DATA SET LAST_TXC_START = :1, '
          || 'LAST_TXC_END = :2, COMPLETION_TEXT = :3, STATUS = :4 '
          || 'WHERE PACKAGE_NAME = :5 AND PROCEDURE_NAME = :6';

	  EXECUTE IMMEDIATE dynamic_stmt USING l_api_start, l_api_end,l_status_message,
          l_api_status, x_request.PACKAGE_NAME,x_request.PROCEDURE_NAME;

      JTM_MESSAGE_LOG_PKG.UPDATE_CONC_STATUS_LOG
              (v_log_id =>l_log_id
              ,v_query_stmt => Category_Type
              ,v_start_time => l_api_start
              ,v_end_time   => l_api_end
              ,v_status     => l_api_status
              ,v_message    => l_status_message
              ,x_status     => l_status
              ,x_msg_data   => l_message);

   END LOOP;

   if (retcode = 0) then
     l_api_status := JTM_CON_QUERY_REQUEST_PKG.G_FINE;
   else
     l_api_status := JTM_CON_QUERY_REQUEST_PKG.G_ERROR;
   end if;
   if (errbuf = 'OK') then
      errbuf := l_conc_message;
   end if;
   JTM_MESSAGE_LOG_PKG.UPDATE_CONC_STATUS_LOG
           (v_log_id =>l_start_log_id
           ,v_query_stmt => Category_Type
           ,v_start_time => l_proc_start
           ,v_end_time   => sysdate
           ,v_status     => l_api_status
           ,v_message    => errbuf
           ,x_status     => l_status
           ,x_msg_data   => l_message);

Exception
     When others then
         JTM_MESSAGE_LOG_PKG.log_msg(
           v_object_id   => L_API_NAME,
           v_object_name => G_PKG_NAME,
           v_message     => 'Exception occurs.',
           v_level_id    => JTM_HOOK_UTIL_PKG.g_debug_level_error,
           v_module      => G_PKG_NAME);

        errbuf := 'Exception in '||G_PKG_NAME ||'.'|| L_API_NAME ||': '||sqlerrm;
        retcode := -1;

        JTM_MESSAGE_LOG_PKG.UPDATE_CONC_STATUS_LOG
           (v_log_id =>l_start_log_id
           ,v_query_stmt => Category_Type
           ,v_start_time => l_proc_start
           ,v_end_time   => sysdate
           ,v_status     => JTM_CON_QUERY_REQUEST_PKG.G_ERROR
           ,v_message    => errbuf
           ,x_status     => l_status
           ,x_msg_data   => l_message);

END Do_Refresh_Mobile_Data;

END JTM_MASTER_CONC_PROG_PUB;

/
