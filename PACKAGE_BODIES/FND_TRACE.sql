--------------------------------------------------------
--  DDL for Package Body FND_TRACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_TRACE" as
/* $Header: AFPMTRCB.pls 120.3 2005/12/21 23:27:33 appldev noship $ */

DBUSER              VARCHAR2(30);
SESSION_ID_G        NUMBER;
SERIAL#_G           NUMBER;
SPID                NUMBER;
MODULE_G            VARCHAR2(80):='MOD_NA';

IDENT_STRING_G      VARCHAR2(120) ;
IDENT_STRING_O      VARCHAR2(120) ;   -- external override
INVALID_IDENT       VARCHAR2(1):='N';  -- identifier contains invalid chars


IDENT_FLAG          VARCHAR2(1):='N';
TRC_ID              NUMBER :=0;

PROF_FLAG           VARCHAR2(1):='N';
PROF_RUNID          NUMBER:=0;
PROF_REQID          NUMBER:=-1;


procedure DLOG(MESG IN VARCHAR2) IS
BEGIN
     -- dbms_output.put_line(mesg);
     FND_FILE.put_line(FND_FILE.log,MESG);
END;

function GET_DB_VERSION return NUMBER IS
versn number:=8;
BEGIN
  select substr(version,1,instr(version,'.')-1) into versn from v$instance;
  return versn;
EXCEPTION
  WHEN OTHERS THEN
   return 8;  -- Just in case, default it to 8
END;

procedure SET_IDENT_FOR_SESS(TRACE_TYPE in NUMBER) IS

 IDENT_STRING_T varchar2(120);  -- temporary local variable
 l_pl_str varchar2(200);

BEGIN
  -- Get the current identifier string
      IF FND_GLOBAL.USER_NAME IS NOT NULL THEN
       IDENT_STRING_T:=upper(FND_GLOBAL.USER_NAME);
       -- change - to _
       IDENT_STRING_T:=translate( IDENT_STRING_T,'-','_');
       -- remove special chars, ie all chars other than alphanumeric and _
       IDENT_STRING_T:=translate( IDENT_STRING_T,'x'||translate( IDENT_STRING_T,
               '-_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ',
               '-'),'x');
       -- Remove @ from ident_string_g, if if contains one
       -- Next three lines have been commented as they are not needed anymore, it
       -- has been taken care of by the earlier translate.
       -- IF instr(IDENT_STRING_T,'@') > 0 THEN
         -- IDENT_STRING_T:=substr(IDENT_STRING_T,1,instr(IDENT_STRING_T,'@')-1);
       -- END IF;
       -- Cap ident_string_g at 12 chars
       IDENT_STRING_T:=substr(IDENT_STRING_T,1,12);
       IF (FND_GLOBAL.CONC_REQUEST_ID > 0) then
        IDENT_STRING_T:=IDENT_STRING_T||'_CR'||FND_GLOBAL.CONC_REQUEST_ID;
       END IF;
    ELSE
      SELECT USER INTO DBUSER FROM DUAL;
       IDENT_STRING_T:=substr(DBUSER,1,12);
    END IF;

  IF(nvl(IDENT_STRING_G,' ') <> IDENT_STRING_T) THEN
    -- Reset the identifier string and flag.
    IDENT_STRING_G:=IDENT_STRING_T;
    IDENT_FLAG:='N';
  END IF;

  -- Set the invalid flag if the ident string contains a space
  IF instr(IDENT_STRING_O,' ') > 0 THEN
     INVALID_IDENT:='Y';
   END IF;
  IF instr(IDENT_STRING_G,' ') > 0 THEN
     INVALID_IDENT:='Y';
   END IF;


 IF ( (IDENT_FLAG='N') AND (INVALID_IDENT='N'))  THEN
  IF (IDENT_STRING_O IS NOT NULL ) THEN  -- external override
     EXECUTE IMMEDIATE 'ALTER SESSION SET TRACEFILE_IDENTIFIER='''||IDENT_STRING_O||'''';
  ELSE
      EXECUTE IMMEDIATE 'ALTER SESSION SET TRACEFILE_IDENTIFIER='''||IDENT_STRING_G||'''';
  END IF;
  IDENT_FLAG:='Y';
 END IF;

END;


procedure RESET_SESSION IS
BEGIN
   execute immediate 'dbms_session.reset_package';
END;

function SUBMIT_PROFILER_REPORT  RETURN NUMBER IS
BEGIN

  RETURN SUBMIT_PROFILER_REPORT(PROF_RUNID,RELATED_RUNID,'Y') ;

 EXCEPTION
   WHEN OTHERS THEN
     RETURN -1;
END SUBMIT_PROFILER_REPORT;

function SUBMIT_PROFILER_REPORT(PROF_RUNID IN NUMBER,
                                RELATED_RUNID IN NUMBER,
                                PURGE_DATA IN VARCHAR2) RETURN NUMBER IS
PRAGMA AUTONOMOUS_TRANSACTION;
PURGE_DATA_L VARCHAR2(5);
BEGIN

-- Default value for PURGE_DATA is 'Y', but if this profile option
-- is set, then we override the default value.

PURGE_DATA_L:=NVL(FND_PROFILE.VALUE('FND_PURGE_PROFILER_DATA'),'Y');

 IF FND_GLOBAL.USER_NAME IS NOT NULL THEN
   PROF_REQID := FND_REQUEST.SUBMIT_REQUEST(application => 'FND',
                                            program => 'FNDPMPRPT',
                                            argument1 => PROF_RUNID,
                                            argument2 => RELATED_RUNID,
                                            argument3 => PURGE_DATA_L);
   COMMIT;
 ELSE
   PROF_REQID := -1;
 END IF;
  RETURN PROF_REQID;

 EXCEPTION
   WHEN OTHERS THEN
     RETURN -1;
END SUBMIT_PROFILER_REPORT;


procedure START_TRACE(TRACE_TYPE in NUMBER) IS
l_trc_cmd varchar2(200);
l_pl_str varchar2(200);
err_code  number;
curr_trace_level number:=0;

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
       SET_IDENT_FOR_SESS(TRACE_TYPE);

  IF(TRACE_TYPE < 20) THEN  -- < 20 reserved for sql trace levels
     curr_trace_level:=get_trace_level(TRACE_TYPE);
     IF (TRACE_TYPE > curr_trace_level) THEN
       l_trc_cmd:='alter session set events=''10046 trace name context forever, level  '
                  ||trace_type||'''';
       EXECUTE IMMEDIATE l_trc_cmd;
     END IF;
  ELSIF (TRACE_TYPE=10941) THEN
     IF PROF_FLAG = 'N' THEN   -- Profiler has not been started yet.

       SELECT nvl(S.MODULE,'MOD_NA')
       INTO MODULE_G
       FROM V$SESSION S
       WHERE AUDSID=USERENV('SESSIONID');


        IF (FND_GLOBAL.LOGIN_ID > 0) then
           RELATED_RUNID:=FND_GLOBAL.LOGIN_ID;
        ELSE
           RELATED_RUNID:=SPID;
        END IF;

        DLOG('Related Run Id is '||RELATED_RUNID);

        l_pl_str:='begin dbms_profiler.start_profiler(nvl(:IDENT_STRING_G,''PROFILER''),:MODULE_G,:PROF_RUNID); end;';
        PROF_FLAG:='Y';
        BEGIN
          EXECUTE IMMEDIATE l_pl_str USING IN IDENT_STRING_G,
                                           IN MODULE_G,
                                          OUT PROF_RUNID;
       dlog('Started the PL/SQL profiler for runid '||prof_runid);
       -- Manually stamp the related run column
       l_pl_str:='update plsql_profiler_runs set related_run=:RELATED_RUNID '||
                 'where runid=:PROF_RUNID';
        EXECUTE IMMEDIATE l_pl_str USING IN RELATED_RUNID, IN PROF_RUNID;
        commit;
       -- If db is 10g, also enable plstimer
        IF GET_DB_VERSION > 9 THEN
         l_pl_str:='alter session set events=''10928 trace name context forever, level 1024''';
         EXECUTE IMMEDIATE l_pl_str ;
        END IF;
        EXCEPTION
          WHEN OTHERS THEN
            PROF_FLAG:='E';
            dlog('Exception occured while starting the PL/SQL profiler.');
        END;

     ELSIF (PROF_FLAG='Y') THEN
        l_pl_str:='begin :err_code:=dbms_profiler.flush_data; end;';
        dlog('Executing call to Flush Profiler');
        EXECUTE IMMEDIATE l_pl_str USING OUT ERR_CODE;
        IF ERR_CODE =2 THEN
          DLOG('Error occured while writing to Profiler Tables. Error Ocde - 2');
        ELSE
          DLOG('Error occured while flushing profiler data. Error code returned by call - '||err_code);
        END IF;
     END IF;
  ELSIF (TRACE_TYPE=10928) THEN
   l_trc_cmd:='alter session set events=''10928 trace name context forever, level 1''';
     EXECUTE IMMEDIATE l_trc_cmd;
  ELSIF (TRACE_TYPE=10053) THEN
   l_trc_cmd:='alter session set events=''10053 trace name context forever, level 1''';
     EXECUTE IMMEDIATE l_trc_cmd;
  ELSE
     null;
     -- log message , should never fall thru to this branch.
  END IF;

END;

procedure START_TRACE(TRACE_TYPE in NUMBER,
                      SESSION_ID in NUMBER,
                      SERIAL# in NUMBER)    IS
BEGIN

  IF ((TRACE_TYPE=10053) OR (TRACE_TYPE=10046) OR (TRACE_TYPE=10928)) THEN
     SET_IDENT_FOR_SESS(TRACE_TYPE);
  END IF;


  IF(TRACE_TYPE < 20) THEN  -- < 20 reserved for sql trace levels

     DBMS_SYSTEM.SET_EV(SESSION_ID,SERIAL#,10046,TRACE_TYPE,'');

  ELSIF ((TRACE_TYPE=10053) OR (TRACE_TYPE=10928) OR (TRACE_TYPE=10941)) THEN
         DBMS_SYSTEM.SET_EV(SESSION_ID_G,SERIAL#_G,TRACE_TYPE,1,'');
  ELSE
     null;
     -- log message , should never fall thru to this branch.
  END IF;

END;


procedure STOP_TRACE(TRACE_TYPE in NUMBER) IS
l_trc_cmd varchar2(200);
l_pl_str varchar2(200);
l_reqid number;
BEGIN

  IF(TRACE_TYPE < 20) THEN
    IDENT_FLAG:='N';
    IDENT_STRING_G:=' ';
    -- l_trc_cmd:='ALTER SESSION SET SQL_TRACE=FALSE';
    l_trc_cmd:='alter session set events=''10046 trace name context off''';
    EXECUTE IMMEDIATE l_trc_cmd;
  ELSIF ( (TRACE_TYPE=10941) AND (PROF_FLAG='Y')) THEN
        l_pl_str:='begin dbms_profiler.stop_profiler;  end;';
        BEGIN
          EXECUTE IMMEDIATE l_pl_str ;
          dlog('Stopped the PL/SQL profiler for runid '||prof_runid);
          PROF_FLAG:='N';
          -- If db version is 10g or greater, also switch off plstimer
          IF GET_DB_VERSION > 9 THEN
           l_pl_str:='alter session set events=''10928 trace name context off''';
           EXECUTE IMMEDIATE l_pl_str ;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            PROF_FLAG:='E';
            dlog('Exception occured while stopping profiler');
        END;
  ELSIF (TRACE_TYPE=10928) THEN
    l_trc_cmd:='alter session set events=''10928 trace name context off''';
  ELSIF (TRACE_TYPE=10053) THEN
    l_trc_cmd:='alter session set events=''10053 trace name context off''';
    EXECUTE IMMEDIATE l_trc_cmd;
  ELSE
     l_trc_cmd:='select sysdate into l_trc_cmd from dual';
     -- log message , should never fall thru to this branch.
       END IF;
END;

procedure STOP_TRACE(TRACE_TYPE in NUMBER,
                      SESSION_ID in NUMBER,
                      SERIAL# in NUMBER)    IS
BEGIN


  IF(TRACE_TYPE < 20) THEN  -- < 20 reserved for sql trace levels

      DBMS_SYSTEM.SET_EV(SESSION_ID,SERIAL#,10046,0,'');
  ELSIF ((TRACE_TYPE=10053) OR (TRACE_TYPE=10928))  THEN
         DBMS_SYSTEM.SET_EV(SESSION_ID,SERIAL#,TRACE_TYPE,0,'');
  ELSIF (TRACE_TYPE=10941) THEN
         -- level 8 stands for "Store data in db and Stop"
         DBMS_SYSTEM.SET_EV(SESSION_ID,SERIAL#,TRACE_TYPE,8,'');

  END IF;

END;



procedure SET_TRACE_IDENTIFIER(IDENTIFIER_STRING in VARCHAR2) IS

BEGIN
  IF (nvl(IDENT_STRING_G,' ') <> IDENTIFIER_STRING) THEN
    IDENT_FLAG:='N'; -- new identifier has been set, reset flag
  END IF;
  IDENT_STRING_G := IDENTIFIER_STRING;
  IDENT_STRING_O := IDENTIFIER_STRING;  -- set the override identifier
END;

procedure SET_MAX_DUMP_FILE_SIZE(TRACEFILE_SIZE in NUMBER) IS
l_dump_cmd varchar2(100);
BEGIN
    l_dump_cmd:='alter session set max_dump_file_size='||tracefile_size||' M';
    EXECUTE IMMEDIATE l_dump_cmd;
END;



function GET_TRACE_IDENTIFIER RETURN VARCHAR2 IS
BEGIN

  IF IDENT_STRING_G IS NOT NULL THEN
    RETURN IDENT_STRING_G;
  ELSE
    RETURN 'NOT_SET'; -- actually should never fall thru to this.
  END IF;

END;

function GET_TRACE_FILENAME RETURN VARCHAR2 IS
l_filename varchar2(256);
BEGIN
   BEGIN
     EXECUTE IMMEDIATE
        'begin :l_filename:=fnd_debug_util.get_trace_file_name(); end;'
           USING OUT l_filename;

   EXCEPTION
    WHEN OTHERS THEN
      l_filename:='FND_DEBUG_UTILS_NOT_INSTALLED';
    END;

RETURN l_filename;

END;

function IS_TRACE_ENABLED(TRACE_TYPE in NUMBER) RETURN BOOLEAN IS

EVENT_LEVEL NUMBER;
TRACE_ON BOOLEAN;
BEGIN

  IF(TRACE_TYPE < 20) THEN
   DBMS_SYSTEM.READ_EV(10046,EVENT_LEVEL);
  ELSIF TRACE_TYPE=10941 THEN
    IF PROF_FLAG='Y' THEN
      EVENT_LEVEL:=1;
    ELSE
      EVENT_LEVEL:=0;
    END IF;
  ELSE
   DBMS_SYSTEM.READ_EV(TRACE_TYPE,EVENT_LEVEL);
  END IF;

  IF EVENT_LEVEL > 0 THEN
    TRACE_ON:= TRUE;
  ELSE
    TRACE_ON:= FALSE;
  END IF;
RETURN TRACE_ON;
END;

function GET_TRACE_LEVEL(TRACE_TYPE in NUMBER) RETURN NUMBER IS

EVENT_LEVEL NUMBER:=0;
BEGIN

  IF(TRACE_TYPE < 20) THEN
   DBMS_SYSTEM.READ_EV(10046,EVENT_LEVEL);
  ELSIF TRACE_TYPE=10941 THEN
    IF PROF_FLAG='Y' THEN
      EVENT_LEVEL:=1;
    ELSE
      EVENT_LEVEL:=0;
    END IF;
  ELSE
   DBMS_SYSTEM.READ_EV(TRACE_TYPE,EVENT_LEVEL);
  END IF;

RETURN EVENT_LEVEL;

END;

function GET_TRACE_ID (TRACE_TYPE in NUMBER) RETURN NUMBER IS
BEGIN
  -- for sql trace types return spid
  -- for plsql profiler return runid
  -- for cbo trace return spid

  IF((TRACE_TYPE < 20) OR (TRACE_TYPE=10053) OR (TRACE_TYPE=10928)) THEN
    IF(SPID IS NOT NULL) THEN
      RETURN SPID;
    ELSE
      RETURN 0;
    END IF;
  ELSIF TRACE_TYPE=10941 THEN
     RETURN PROF_RUNID;
  END IF;
END;

BEGIN    -- Package Initialization section
    -- Removed module from here as it gets reset for each form.

   SELECT S.SID,S.SERIAL#,P.SPID
   INTO SESSION_ID_G,SERIAL#_G,SPID
   FROM V$SESSION S, V$PROCESS P
   WHERE S.PADDR=P.ADDR
     AND AUDSID=USERENV('SESSIONID');



  EXECUTE IMMEDIATE 'alter session set max_dump_file_size=unlimited';

END FND_TRACE;

/
