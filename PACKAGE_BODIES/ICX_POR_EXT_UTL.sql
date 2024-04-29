--------------------------------------------------------
--  DDL for Package Body ICX_POR_EXT_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_EXT_UTL" AS
/* $Header: ICXEXTUB.pls 120.1 2006/01/10 11:59:20 sbgeorge noship $*/

--------------------------------------------------------------
--                   Global Variables                       --
--------------------------------------------------------------
ANALYSIS_REPORT		PLS_INTEGER := 1;
LOG_REPORT		PLS_INTEGER := 0;

-- bug 2920845: increase size from 200 to 20000
-- gFilePath		VARCHAR2(200) := NULL;
gFilePath		VARCHAR2(2000) := NULL;
gFileHandle		UTL_FILE.FILE_TYPE := NULL;
-- FPI feature, Analysis Report
gReportHandle		UTL_FILE.FILE_TYPE := NULL;
gUseFile		PLS_INTEGER := USE_CONCURRENT_LOG;

type tErrorStackType IS TABLE of varchar2(1000)
  index by binary_integer;

gErrorStack		tErrorStackType;

gPendingCommitRecords	PLS_INTEGER := 0;

gIcxSchema		VARCHAR2(20) := NULL;

--------------------------------------------------------------
--                   Write Debug Message                    --
--------------------------------------------------------------

PROCEDURE clearErrorStack IS
BEGIN
  if (gErrorStack.COUNT > 0) then
    gErrorStack.DELETE;
  end if;
END clearErrorStack;

PROCEDURE pushError(pMsg	IN VARCHAR2) IS
BEGIN
  if (pMsg is not null) then
    gErrorStack(gErrorStack.COUNT + 1) := pMsg;
  end if;
END pushError;

PROCEDURE setFilePath(pFilePath	IN VARCHAR2) IS
lTmpFilePath		VARCHAR2(200) := NULL;
BEGIN
  IF pFilePath = UTL_FILE_DIR THEN

    -- Bug#2876721
    select trim(value)
    into   gFilePath
    from   v$parameter
    where  name = 'utl_file_dir';

    if(gFilePath is not null) then
      lTmpFilePath := substrb(translate(ltrim(gFilePath),',',' '), 1,
    	   instr(translate(ltrim(gFilePath),',',' '),' ') - 1);

      -- Bug#2876721
      if ( lTmpFilePath is not null ) then
          gFilePath := lTmpFilePath;
      end if;
    end if;

  ELSIF pFilePath = 'ECE_OUT_FILE_PATH' THEN
    fnd_profile.get('ECE_OUT_FILE_PATH', gFilePath);
  ELSE
    gFilePath := pFilePath;
  END IF;
END setFilePath;

FUNCTION getFilePath RETURN VARCHAR2 IS
BEGIN
  RETURN gFilePath;
END getFilePath;

PROCEDURE setUseFile(pUseFile	IN PLS_INTEGER) IS
BEGIN
  if (pUseFile = USE_FILE_SYSTEM) then
    gUseFile := USE_FILE_SYSTEM;
  else
    gUseFile := USE_CONCURRENT_LOG;
  end if;
END setUseFile;

PROCEDURE openLog(pFileName	IN varchar2,
                  pOpenMode	IN varchar2) IS
  xErrLoc       PLS_INTEGER := 100;
BEGIN
  gFileHandle := null;
  clearErrorStack;
  xErrLoc := 150;

  -- Bug 1937391
  if (gDebugLevel = -1) then
    return;
  end if;

  -- open the log file
  if (gUseFile = USE_FILE_SYSTEM) then
    IF gFilePath IS NULL THEN
      setFilePath('ECE_OUT_FILE_PATH');
    END IF;

    gFileHandle := utl_file.fopen(gFilePath, pFileName||'_log', pOpenMode);
    gReportHandle := utl_file.fopen(gFilePath, pFileName||'_out', pOpenMode);
  end if;

  xErrLoc := 200;
  -- for concurrent process log file
  -- This function does nothing if called from a concurrent program
  if (gUseFile = USE_CONCURRENT_LOG) then
    fnd_file.put_names(pFileName||'_log', pFileName||'_out', gFilePath);
  end if;

EXCEPTION
  when fnd_file.utl_file_error then
    -- Bug#2876721
    if (gUseFile = USE_CONCURRENT_LOG) then
      pushError('ICX_POR_EXT_UTL.openLog-'||xErrLoc||
              ' fnd_file.utl_file_error');
      raise gFatalException;
    else
      gDebugLevel := -1;
      gFileHandle := null;
    end if;
  when others then
    pushError('ICX_POR_EXT_UTL.openLog-'||xErrLoc||' '||SQLERRM);
    if (utl_file.is_open(gFileHandle)) then
      utl_file.fclose(gFileHandle);
    end if;
    if (utl_file.is_open(gReportHandle)) then
      utl_file.fclose(gReportHandle);
    end if;
    raise gFatalException;
END openLog;

PROCEDURE closeLog IS
BEGIN
  if (gDebugLevel = NOLOG_LEVEL) then
    return;
  end if;

  if (gUseFile = USE_FILE_SYSTEM) then
    if (utl_file.is_open(gFileHandle)) then
      utl_file.fclose(gFileHandle);
    end if;
    if (utl_file.is_open(gReportHandle)) then
      utl_file.fclose(gReportHandle);
    end if;
  end if;

  if (gUseFile = USE_CONCURRENT_LOG) then
    -- if the context is not concurrent program then
    -- close open files. FND_FILE.CLOSE should not
    -- be called from a concurrent program.
    if (fnd_global.conc_request_id <= 0) then
      fnd_file.close;
    end if;
  end if;

EXCEPTION
  when others then
    null;
END closeLog;

PROCEDURE log(pString IN VARCHAR2,
              pReport PLS_INTEGER) IS
  xErrLoc PLS_INTEGER;
  xLength PLS_INTEGER;
  xPnt    PLS_INTEGER := 1;
BEGIN
  xErrLoc := 100;
  if (gUseFile = USE_FILE_SYSTEM) then
    -- FPI feature, Analysis Report
    if (pReport = LOG_REPORT) then
      if (utl_file.is_open(gFileHandle)) then
        xErrLoc := 200;
        xLength := length(pString);
        while (xPnt < xLength) loop
          utl_file.put_line(gFileHandle, substr(pString, xPnt, 1000));
          xPnt := xPnt + 1000;
        end loop;
        xErrLoc := 240;
        utl_file.fflush(gFileHandle);
      end if;
    else
      -- FPI feature, Analysis Report
      if (utl_file.is_open(gReportHandle)) then
        xErrLoc := 300;
        xLength := length(pString);
        while (xPnt < xLength) loop
          utl_file.put_line(gReportHandle, substr(pString, xPnt, 1000));
          xPnt := xPnt + 1000;
        end loop;
        xErrLoc := 340;
        utl_file.fflush(gFileHandle);
      end if;
    end if;
  else
    xErrLoc := 400;
    xLength := length(pString);
    while (xPnt < xLength) loop
      -- FPI feature, Analysis Report
      if (pReport = LOG_REPORT) then
        -- Log for concurrent request
        fnd_file.put_line(fnd_file.log, substr(pString, xPnt, 1000));
      else
        -- Out for concurrent request
        fnd_file.put_line(fnd_file.output, substr(pString, xPnt, 1000));
      end if;
      xPnt := xPnt + 1000;
    end loop;
    xErrLoc := 420;
  end if;

EXCEPTION
  when fnd_file.utl_file_error then
    pushError('ICX_POR_EXT_UTL.log-fnd_file.utl_file_error');
    -- Bug 3488764 : Add custom message to the error stack trace so that customer
    -- can understand the problem and fix.
    -- Raise utl_file_error. This is handled seperately by upgrade script
    raise_application_error(-20100, ICX_POR_EXT_UTL.UTL_FILE_ERR_MSG, TRUE);
  when others then
    pushError('ICX_POR_EXT_UTL.log-'||xErrLoc || ': ' ||SQLERRM);
    raise gException;
END log;

PROCEDURE log(pString IN VARCHAR2) IS
BEGIN
  log(pString, LOG_REPORT);
END log;

PROCEDURE setDebugLevel(pLevel  IN PLS_INTEGER) IS
BEGIN
  gDebugLevel := pLevel;
END setDebugLevel;

PROCEDURE debug(pLevel	IN PLS_INTEGER,
                pMsg 	IN VARCHAR2) IS

  xDebug	varchar2(20) := '';
  xReport	PLS_INTEGER := LOG_REPORT;
BEGIN
  if (gDebugLevel = NOLOG_LEVEL) then
    return;
  end if;

  if (pLevel <= gDebugLevel) then
    if (pLevel = ERROR_LEVEL) then
      xDebug := '[Error] ';
    elsif (pLevel = ANLYS_LEVEL) then
      xReport := ANALYSIS_REPORT;
    elsif (pLevel = INFO_LEVEL)  then
      xDebug := '[Info.] ';
    elsif (pLevel = DEBUG_LEVEL) then
      xDebug := '[Debug] ';
    elsif (pLevel = DETIL_LEVEL) then
      xDebug := '[Detil] ';
    end if;

    log(getTimeStamp || '   ' ||
        xDebug || '' || pMsg, xReport);
  end if;
END debug;

PROCEDURE debug(pMsg    IN VARCHAR2) IS
BEGIN
  debug(INFO_LEVEL, pMsg);
END debug;

PROCEDURE printStackTrace IS
  xIndex binary_integer;
BEGIN
  if (gErrorStack.COUNT > 0) then
    log('### Error Stack');
    xIndex := gErrorStack.FIRST;
    while (xIndex is not null) loop
      log('###   '||gErrorStack(xIndex));
      xIndex := gErrorStack.NEXT(xIndex);
    end loop;
    Log('### End of Stack');
    gErrorStack.DELETE;
  end if;
END printStackTrace;

FUNCTION getStackTraceString RETURN VARCHAR2 IS
  xString varchar2(2000) := '';
  xIndex binary_integer;
BEGIN
  if (gErrorStack.COUNT > 0) then
    xIndex := gErrorStack.FIRST;
    while (xIndex is not null) loop
      xString := xString || '>>> ' || gErrorStack(xIndex);
      xIndex := gErrorStack.NEXT(xIndex);
    end loop;
  end if;
  return xString;
END getStackTraceString;

--------------------------------------------------------------
--                    Commit/Rollback                       --
--------------------------------------------------------------

PROCEDURE extCommit IS
BEGIN
  gPendingCommitRecords := gPendingCommitRecords + SQL%ROWCOUNT;
  if (gPendingCommitRecords >= gCommitSize) then
    -- debug(DEBUG_LEVEL, 'Commit ' || gPendingCommitRecords || ' Records');
    -- FND_CONCURRENT.AF_COMMIT is used by concurrent programs that
    -- use a particular rollback segment. This rollback segment must
    -- be defined in the Define Concurrent Program form.
    FND_CONCURRENT.AF_COMMIT;

    gPendingCommitRecords := 0;
  end if;
END extCommit;

PROCEDURE extAFCommit IS
BEGIN
  -- debug(DEBUG_LEVEL, 'Commit ' || gPendingCommitRecords || ' Records');
  -- FND_CONCURRENT.AF_COMMIT is used by concurrent programs that
  -- use a particular rollback segment. This rollback segment must
  -- be defined in the Define Concurrent Program form.
  FND_CONCURRENT.AF_COMMIT;
  gPendingCommitRecords := 0;
END extAFCommit;

PROCEDURE extRollback IS
BEGIN
  -- FND_CONCURRENT.AF_ROLLBACK is used by concurrent programs that
  -- use a particular rollback segment. This rollback segment must
  -- be defined in the Define Concurrent Program form.
  FND_CONCURRENT.AF_ROLLBACK;
  gPendingCommitRecords := 0;
END extRollback;

--------------------------------------------------------------
--                    Get PL/SQL Table element              --
--------------------------------------------------------------
FUNCTION getTableElement(pTable	IN DBMS_SQL.NUMBER_TABLE,
                         pIndex IN BINARY_INTEGER)
  RETURN VARCHAR2
IS
  xString varchar2(2000) := '';
BEGIN
  IF pTable.EXISTS(pIndex) THEN
    xString := xString || pTable(pIndex);
  ELSE
    xString := xString || '<Not Exists>';
  END IF;
  RETURN xString;
END getTableElement;

FUNCTION getTableElement(pTable	IN DBMS_SQL.VARCHAR2_TABLE,
                         pIndex IN BINARY_INTEGER)
  RETURN VARCHAR2
IS
  xString varchar2(2000) := '';
BEGIN
  IF pTable.EXISTS(pIndex) THEN
    xString := xString || pTable(pIndex);
  ELSE
    xString := xString || '<Not Exists>';
  END IF;
  RETURN xString;
END getTableElement;

FUNCTION getTableElement(pTable	IN DBMS_SQL.UROWID_TABLE,
                         pIndex IN BINARY_INTEGER)
  RETURN VARCHAR2
IS
  xString varchar2(2000) := '';
BEGIN
  IF pTable.EXISTS(pIndex) THEN
    xString := xString || pTable(pIndex);
  ELSE
    xString := xString || '<Not Exists>';
  END IF;
  RETURN xString;
END getTableElement;

FUNCTION getTableElement(pTable	IN DBMS_SQL.DATE_TABLE,
                         pIndex IN BINARY_INTEGER)
  RETURN VARCHAR2
IS
  xString varchar2(2000) := '';
BEGIN
  IF pTable.EXISTS(pIndex) THEN
    xString := xString || TO_CHAR(pTable(pIndex), 'MM/DD/YY HH24:MI:SS');
  ELSE
    xString := xString || '<Not Exists>';
  END IF;
  RETURN xString;
END getTableElement;

--------------------------------------------------------------
--                         Get schemas                      --
--------------------------------------------------------------
FUNCTION getIcxSchema RETURN VARCHAR2
IS
  xStatus		varchar2(20);
  xIndustry		varchar2(20);
BEGIN
  IF (gIcxSchema IS NOT NULL OR
      FND_INSTALLATION.GET_APP_INFO('ICX', xStatus,
        xIndustry, gIcxSchema))
  THEN
    RETURN gIcxSchema;
  END IF;
  RETURN 'ICX';
END getIcxSchema;

FUNCTION getTimeStamp RETURN VARCHAR2
IS
  x100Sec 	PLS_INTEGER;
  xTimeStamp	VARCHAR2(40);
BEGIN
  x100Sec := MOD(dbms_utility.get_time, 100);
  /*
  IF x100Sec < 50 THEN
    xTimeStamp := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS') ||
                  ':' || x100Sec;
  ELSE
    xTimeStamp := TO_CHAR(SYSDATE-1/86400, 'MM/DD/YY HH24:MI:SS') ||
                  ':' || x100Sec;
  END IF;
  */
  xTimeStamp := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS') ||
                ':' || x100Sec;
  RETURN xTimeStamp;
END getTimeStamp;

-- Bug#3453882
FUNCTION getDatabaseVersion RETURN NUMBER
IS
  xErrLoc         PLS_INTEGER := 100;
  version         NUMBER := 0;
  majorReleasePos NUMBER := 0;
  minorReleasePos NUMBER := 0;
  compatibility   VARCHAR2(30) := NULL;
  majorVersion    VARCHAR2(10) := NULL;
  minorVersion    VARCHAR2(10) := NULL;
  versionString   VARCHAR2(30) := NULL;
BEGIN
  dbms_utility.db_version(versionString, compatibility);

  xErrLoc := 110;
  select instr(versionString, '.') into majorReleasePos from dual;
  select instr(substr(versionString,majorReleasePos), '.')
   into minorReleasePos from dual;

  xErrLoc := 120;
  majorVersion := substr(versionString, 1, majorReleasePos-1);
  minorVersion := substr(versionString, majorReleasePos+1, minorReleasePos);

  xErrLoc := 130;
  version := to_number(majorVersion) + (to_number(minorVersion) / 10);

  xErrLoc := 140;
  debug(MUST_LEVEL, 'Database Version: '|| to_char(version));
  RETURN version;
EXCEPTION
  when others then
    pushError('ICX_POR_EXT_UTL.getDatabaseVersion-'||xErrLoc || ': ' || 'versionString=' || versionString || ' majorVersion=' || majorVersion || ' minorVersion=' || majorVersion ||' ReturnedVersion=' || to_char(version) || ' - ' ||SQLERRM);
    raise gException;
END getDatabaseVersion;


END ICX_POR_EXT_UTL;

/
