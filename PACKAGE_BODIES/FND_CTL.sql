--------------------------------------------------------
--  DDL for Package Body FND_CTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CTL" AS
/* $Header: AFSESCTB.pls 115.11.1150.2 2000/01/04 12:07:07 pkm ship $ */

PROCEDURE FND_SESS_CTL(oltp_opt_mode IN VARCHAR2,
                                        conc_opt_mode IN VARCHAR2,
                                        trace_opt     IN VARCHAR2,
                                        timestat    IN VARCHAR2,
                                        logmode    IN VARCHAR2,
                                        event_stmt   IN VARCHAR2) AS

PRAGMA AUTONOMOUS_TRANSACTION ;

BEGIN
   DECLARE
     cid  INTEGER;
     ret integer;
     user_name VARCHAR2(30);
     event_stmt1 VARCHAR2(200);
     resp_name VARCHAR2(100);
     application_short_name VARCHAR2(50);
     conc_program_id NUMBER ;
     conc_program_name VARCHAR2(30) ;
     user_conc_program_name VARCHAR2(240) ;
     conc_request_id      NUMBER ;
     concat_var  VARCHAR2(2000);
     output_conc_request_id varchar2(15);
     timestamp   VARCHAR2(20);
     sql_stmt VARCHAR2(2000) := null;
   BEGIN

     if trace_opt is not null  then
        sql_stmt := 'ALTER SESSION SET SQL_TRACE = '|| trace_opt ;
        EXECUTE IMMEDIATE sql_stmt ;
     end if;
     if ((fnd_global.conc_request_id <= 0) and
         (oltp_opt_mode is not null)) then
        sql_stmt := 'ALTER SESSION SET OPTIMIZER_MODE = '|| oltp_opt_mode ;
        EXECUTE IMMEDIATE sql_stmt ;
     end if;
     if ((fnd_global.conc_request_id > 0) and
         (conc_opt_mode is not null)) then
        sql_stmt := 'ALTER SESSION SET OPTIMIZER_MODE = '|| conc_opt_mode ;
        EXECUTE IMMEDIATE sql_stmt ;
     end if;
     if timestat is not null  then
        sql_stmt := 'ALTER SESSION SET TIMED_STATISTICS = '|| timestat ;
        EXECUTE IMMEDIATE sql_stmt ;
     end if;
     if event_stmt is not null  then
        EXECUTE IMMEDIATE event_stmt ;
     end if;
     --get all the env stuff here  (if trace_opt is true )
     if ( upper(trace_opt) = 'TRUE' or upper(logmode) = 'LOG' ) then
         user_name       := substr(replace(fnd_global.user_name,'''',' '),1,30);
         conc_program_id := fnd_global.conc_program_id;
         resp_name       := substr(replace(fnd_global.resp_name,'''',' '),1,100);
         application_short_name := substr(replace(fnd_global.application_short_name,'''',' '),1,50);
         conc_request_id := fnd_global.conc_request_id;
         if fnd_global.conc_request_id > 0 then
            BEGIN
               SELECT substr(replace(user_concurrent_program_name,'''',' '),1,240),
                  substr(concurrent_program_name,1,30)
               INTO   user_conc_program_name, conc_program_name
               FROM   FND_CONCURRENT_PROGRAMS_VL
               WHERE  concurrent_program_id = conc_program_id
               AND    APPLICATION_ID        = fnd_global.prog_appl_id;
               EXCEPTION
               WHEN OTHERS THEN
                         NULL;
              END;
              output_conc_request_id := to_char(conc_request_id);
          else
              output_conc_request_id := 'FORMS';
          end if;
          SELECT TO_CHAR(SYSDATE,'DD-MON-YY:HH24:MI:SS')
          INTO   timestamp
          FROM SYS.DUAL;
     end if;
     if ( upper(trace_opt) = 'TRUE' ) then
          concat_var :='SELECT ' ||  ''''||
                  'TRACE_USER_DETAILS: '||
                  'TIMESTAMP='||
                  nvl(timestamp,' ')||': '||
                  'USER_NAME='||
                  nvl(user_name,' ')||': '||
                  'CONC_REQUEST_ID='||
                  nvl(output_conc_request_id,' ')||': '||
                  'OLTP_OPT_MODE='||
                  nvl(oltp_opt_mode,' ')||': '||
                  'CONC_OPT_MODE='||
                  nvl(conc_opt_mode,' ')||': '||
                  'CONC_PROG_EXE='||
                  nvl(conc_program_name,' ')||': '||
                  'CONC_PROG_NAME='||
                  nvl(user_conc_program_name,' ')||': '||
                  'RESPONSIBILITY='||
                  nvl(resp_name,' ')||': '||
                  'APPL_NAME='||
                  nvl(application_short_name,' ')||
                  ''''|| ' FROM DUAL' ;
            --dbms_output.put_line(substr(concat_var,1,250));
            EXECUTE IMMEDIATE concat_var ;
     end if;

     /* LOG them in a table if needed */
      if (upper(logmode) = 'LOG' )  then
         BEGIN
         INSERT INTO FND_TRACE_LOG VALUES (
            user_name,
            sysdate,
            conc_request_id,
            oltp_opt_mode,
            conc_opt_mode,
            conc_program_name,
            user_conc_program_name,
            resp_name,
            application_short_name
         );
         EXCEPTION
           WHEN OTHERS THEN NULL;
         END;
         COMMIT;
     end if;   /* END of LOGGING */



   END;
END FND_SESS_CTL;
END FND_CTL ;

/
