--------------------------------------------------------
--  DDL for Package Body ICX_POR_POPULATE_DESC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_POPULATE_DESC" AS
-- $Header: ICXPLCDB.pls 115.8 2004/03/31 21:52:02 vkartik ship $


/*
** Procedure : populateCtxDescAll
** Synopsis  : Update the ctx_desc column
**
** Parameter:  p_jobno - number of the job to rebuild
** Parameter:  Rebuild = Y/N  - 'Y'  - rebuild all ctx_<lang> columns
**                              'N'  - populate the ctx_<lang> column for
**                                     all items where the column is null
*/
PROCEDURE populateCtxDescAll(p_jobno IN INTEGER := 0,
			     p_rebuildAll IN VARCHAR2 := 'N') IS

  xErrLoc PLS_INTEGER;

BEGIN
  xErrLoc := 100;

  ICX_POR_CTX_DESC.populateCtxDescAll(p_jobno, p_rebuildAll, 'CONCURRENT');

EXCEPTION

    WHEN OTHERS THEN
      rollback;
      RAISE_APPLICATION_ERROR
        (-20000, 'Exception at ICX_POR_POPULATE_DESC.populateCtxDescAll('||
		xErrLoc||'), '|| SQLERRM );
END populateCtxDescAll;

/*
** Procedure : populateCtxDescAll
** Synopsis  : Update the ctx_desc column
**
** Parameter:  p_jobno - number of the job to rebuild
** Parameter:  Rebuild = Y/N  - 'Y'  - rebuild all ctx_<lang> columns
**                              'N'  - populate the ctx_<lang> column for
**                                     all items where the column is null
*/
PROCEDURE populateCtxDescAll(p_jobno IN INTEGER := 0,
                             p_rebuildAll IN VARCHAR2 := 'N',
                             p_loglevel IN NUMBER,
			     p_logfile IN VARCHAR2) IS
  xErrLoc PLS_INTEGER := 1000;
BEGIN
  ICX_POR_EXT_UTL.gDebugLevel := p_loglevel;
  populateCtxDescAll(p_jobno, p_rebuildAll, p_logfile);

EXCEPTION

    WHEN OTHERS THEN
      rollback;
      RAISE_APPLICATION_ERROR
        (-20000, 'Exception at ICX_POR_POPULATE_DESC.populateCtxDescAll('||
		xErrLoc||'), '|| SQLERRM );
END populateCtxDescAll;

PROCEDURE populateCtxDescAll(p_jobno IN INTEGER := 0,
                             p_rebuildAll IN VARCHAR2 := 'Y',
			     p_logfile IN VARCHAR2) IS
  xErrLoc PLS_INTEGER := 2000;

BEGIN
  xErrLoc := 2000;
  if ( p_logfile is not NULL ) then
     ICX_POR_EXT_UTL.openLog(p_logfile);
  end if;

  xErrLoc := 2010;
  populateCtxDescAll(p_jobno, p_rebuildAll);

EXCEPTION

    WHEN OTHERS THEN
      icx_por_ext_utl.debug(icx_por_ext_utl.DEBUG_LEVEL,
		'Exception at ICX_POR_POPULATE_DESC.populateCtxDescAll('||
                xErrLoc || '), ' || SQLERRM);
      rollback;
      ICX_POR_EXT_UTL.printStackTrace;
      ICX_POR_EXT_UTL.closeLog;
      RAISE_APPLICATION_ERROR
        (-20000, 'Exception at ICX_POR_POPULATE_DESC.populateCtxDescAll('||
		xErrLoc||'), '|| SQLERRM );
END populateCtxDescAll;


/*
** Procedure : populateDescAll
** Synopsis  : Update the ctx_desc column
*/
PROCEDURE populateDescAll(p_jobno IN INTEGER := 0) IS
    xErrLoc PLS_INTEGER := 100;

BEGIN

    xErrLoc := 100;
    ICX_POR_CTX_DESC.populateCtxDescAll(p_jobno, 'CONCURRENT');

EXCEPTION

    WHEN OTHERS THEN
      icx_por_ext_utl.debug(-- icx_por_ext_utl.DEBUG_LEVEL,
		'Exception at ICX_POR_POPULATE_DESC.populateDescAll('||
                xErrLoc || '), ' || SQLERRM);
      rollback;
      RAISE_APPLICATION_ERROR
        (-20000, 'Exception at ICX_POR_POPULATE_DESC.populateDescAll('||
		xErrLoc||'), '|| SQLERRM );

END populateDescAll;

/*
** Procedure : rebuildAll
** Synopsis  : Update the ctx_desc column
**
*/
PROCEDURE rebuildAll IS

  xErrLoc PLS_INTEGER := 100;
BEGIN
  ICX_POR_CTX_DESC.populateDescAll;
EXCEPTION

    WHEN OTHERS THEN
      icx_por_ext_utl.debug(-- icx_por_ext_utl.DEBUG_LEVEL,
		'Exception at ICX_POR_POPULATE_DESC.rebuildAll('||
                xErrLoc || '), ' || SQLERRM);
      rollback;
      RAISE_APPLICATION_ERROR
        (-20000, 'Exception at ICX_POR_POPULATE_DESC.rebuildAll('||
		xErrLoc||'), '|| SQLERRM );

END rebuildAll;

PROCEDURE rebuild_indexes is
  xErrLoc PLS_INTEGER := 100;
BEGIN

  ICX_POR_CTX_DESC.rebuild_indexes;

EXCEPTION
    WHEN OTHERS THEN
        icx_por_ext_utl.debug(-- icx_por_ext_utl.DEBUG_LEVEL,
		'Exception at ICX_POR_POPULATE_DESC.rebuild_indexes('||
                xErrLoc || '), ' || SQLERRM);

        RAISE_APPLICATION_ERROR(-20000, 'Exception at '||
		'ICX_POR_POPULATE_DESC.rebuild_indexes(' ||
                xErrLoc||'), '|| SQLERRM );
END rebuild_indexes;


END ICX_POR_POPULATE_DESC;

/
