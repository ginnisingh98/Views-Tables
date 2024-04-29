--------------------------------------------------------
--  DDL for Package Body PA_FCK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FCK_UTIL" as
--/* $Header: PABFUTLB.pls 115.4 2003/03/22 00:35:21 skannoji noship $ */

/* ********** ***********************
TO RUN THE DEBUG MODE USING TEMP TABLE do the following:

1)uncomment the PRAGMA statement.
2)create temp table and indexes :

             drop table pa_buza_debug_log;
             create table pa_buza_debug_log
             (
              sess_seq_id         number,
              creation_date       date,
              creation_date_chr   varchar2(30),
              line_num            number,
              message             varchar2(250) );
             create sequence pa_buza_debug_log_s ;
             create unique index
              pa_buza_debug_log_U1
                  on pa_buza_debug_log ( sess_seq_id,line_num);
3)Apply the package.

************************************* */
--
pa_buza_debug_mode VARCHAR2(1) := NULL;-- Added for bug 2838796

PROCEDURE debug_msg ( p_msg             IN   VARCHAR2 )
IS
--PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

--null;

 /* Added code for bug 2838796 to print the log messages only when the debug mode is Yes */
   IF pa_buza_debug_mode IS NULL THEN
     pa_buza_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
   END IF;

   IF pa_buza_debug_mode  = 'Y' THEN
     -- PA_DEBUG.Set_Curr_Function( p_function   => 'Buza Message->',
     --                             p_debug_mode => pa_buza_debug_mode);
      PA_DEBUG.g_err_stage := p_msg;
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      --    PA_DEBUG.Reset_Curr_Function;
   END IF;
 /* Changes end here */


/* Commented out for bug 2838796 */
-- pa_debug.debug(p_msg);
/* Changes to bug 2838796 end here */

/* *********
if ( g_session_seq_id is null ) then
   select
      pa_buza_debug_log_s.nextval into g_session_seq_id
   from dual;
   g_msg_num := 0;
--   DBMS_PROFILER.START_PROFILER('BUZA-PLSQL-PERF-'||to_char(g_session_seq_id));
else
  g_msg_num := g_msg_num + 1;
end if;

   insert into pa_buza_debug_log
       ( SESS_SEQ_ID,creation_date,
         creation_date_chr,line_num,MESSAGE )
   values ( g_session_seq_id,sysdate,
            to_char(sysdate,'DD-MON-YYY HH24:MI:SS'), g_msg_num,p_msg);
commit;
* ************ */
END debug_msg;

END PA_FCK_UTIL;

/
