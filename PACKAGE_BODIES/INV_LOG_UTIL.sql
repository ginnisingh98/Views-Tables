--------------------------------------------------------
--  DDL for Package Body INV_LOG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LOG_UTIL" AS
/* $Header: INVLOGUB.pls 120.2 2006/10/13 16:41:35 rambrose noship $ */

/** Globals to hold Logging attributs **/
g_fd utl_file.file_type;         -- Log file descriptor
g_trace_on number := NULL;          -- Log ON state
g_dbg_lvl number := 0;
g_cp_flag number := 0;
g_file_init boolean := false;
g_dbgpath varchar2(256) := '_';
g_invfile  varchar2(256) := NULL;

g_conc_request_id number := FND_GLOBAL.CONC_REQUEST_ID;


--
-- ***** trace ****
-- Looks up the profile values INV_DEBUG_LEVEL, INV_DEBUG_TRACE, and
-- INV_DEBUG_FILE and redirects the log-output based on the profile values.
-- If this is invoked in the context of a concurrent program, then
-- the output is also redirected to the concurrent program's log file
--
PROCEDURE trace(p_message VARCHAR2,
                p_module  VARCHAR2,
                p_level   NUMBER := 9) IS

  l_dbgfile        varchar2(256) ;
  l_errmsg         varchar2(256);
  l_timestamp      varchar2(256);
  l_dbgpath        varchar2(128);
  l_ndx            number;
  l_strlen         number;
  l_dbgdir         varchar2(256);
  l_dir_separator  varchar2(1);
  l_session     varchar2(256);
  l_message     VARCHAR2(2000);
  --Bug 3559334 fix. Variable not used in code, but resulting in
  --extra calls to fnd api.
  --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  -- Since the forms-server and MWA server recycles database connections
  -- we need to always check for debug profiles values and see if they
  -- are different from the values with which it was initialized earlier. If
  -- different then reinitialize the debug variables
  IF g_maintain_log_profile AND g_trace_on IS NOT NULL THEN
    l_dbgpath := g_dbgpath;
  ELSE
    g_trace_on := nvl(fnd_profile.value('INV_DEBUG_TRACE'),0);
    l_dbgpath := fnd_profile.value('INV_DEBUG_FILE') ;
    if (g_conc_request_id > 0) then
        g_maintain_log_profile := TRUE;
    end if;

  END IF;

  if ((g_trace_on = 1) AND (l_dbgpath <> g_dbgpath) ) then
    g_dbgpath := l_dbgpath;
    g_cp_flag :=  NVL(fnd_profile.value('CONC_REQUEST_ID'), 0) ;
    if (g_trace_on = 1) then
    select to_char(sysdate, 'DD-MON-YY:HH.MI.SS'),userenv('SESSIONID') into l_errmsg,l_session from dual;
      g_dbg_lvl := fnd_profile.value('INV_DEBUG_LEVEL') ;

      if ( g_cp_flag > 0 ) then
   FND_FILE.put_line(FND_FILE.LOG, ' ******** New Session:'||l_session||'****'||l_errmsg||' **********');
      end if;

      -- Separate the filename from the directory
      l_strlen := length(l_dbgpath);
      l_dbgfile := l_dbgpath;
      l_dir_separator := '/';
      --Check if separator exits, could be different depending on os
      l_ndx := instr(l_dbgfile, l_dir_separator);
      if ( l_ndx = 0 ) then
        l_dir_separator := '\';
      end if;

      loop
        l_ndx := instr(l_dbgfile, l_dir_separator);
      exit when ((l_ndx = 0) or (l_ndx is null));
        l_dbgfile := substr(l_dbgfile, l_ndx+1, l_strlen - l_ndx + 1);
      end loop;

      l_dbgdir := substr(l_dbgpath, 1, l_strlen - length(l_dbgfile) - 1);

      -- Open Log file
    IF l_dbgdir is not null then
      if utl_file.is_open(INV_DEBUG_INTERFACE.g_file_handle) then
          g_fd := INV_DEBUG_INTERFACE.g_file_handle;
      else
          g_fd := utl_file.fopen(l_dbgdir, l_dbgfile, 'a');
      end if;
      utl_file.put_line(g_fd, '');
      utl_file.put_line(g_fd, ' ******** New Session:'||l_session||'****'||l_errmsg||' **********');
     if g_invfile IS NULL then
       WSH_DEBUG_INTERFACE.Start_Debugger(l_dbgdir,l_dbgfile,g_fd); --call shipping debugger
      OE_DEBUG_PUB.Start_ONT_Debugger(l_dbgdir,l_dbgfile,g_fd);  -- call OM debugger
      g_invfile := l_dbgfile;
     end if;

      g_file_init := true;
    END IF;

    end if;  -- if g_trace_on = 1
  end if;


  if (g_trace_on = 1) AND (g_dbg_lvl >= p_level ) then

     l_timestamp := '[' || to_char(sysdate,'DD-MON-YY HH24:MI:SS') || '] ';

     -- Bug 3695496: The log file gets truncated if g_miss_char is sent to
     -- the output file. The text has to be searched and replaced for any
     -- occurence of fnd_api.g_miss_char -- initialized to chr(0)in the fnd
     -- API.

     l_message := REPLACE
       ( p_message,
	 FND_API.G_MISS_CHAR,
	 'FND_API.G_MISS_CHAR'
	 );

     --If called from a concurrent program add msg to FND log
     if ( g_cp_flag > 0 ) then
        FND_FILE.put_line(FND_FILE.LOG, l_timestamp || p_module ||': '|| l_message);
        if (g_file_init) then
	   utl_file.put_line(g_fd, l_timestamp || p_module ||': '|| l_message);
	   utl_file.fflush(g_fd);
        end if;
      else
        if (g_file_init) then
           utl_file.put_line(g_fd, l_timestamp || p_module ||': '|| l_message);
           utl_file.fflush(g_fd);
        end if;
     end if;
  end if;
  --  dbms_output.put_line(p_message);
exception
   when utl_file.INVALID_PATH then
      null;
      --    dbms_output.put_line('*** Error: Invalid Path');
   when others then
      null;
      --    l_errmsg := substr(sqlerrm, 1, 240);
      --    dbms_output.put_line('*** SQL error:'||l_errmsg);
END;
END inv_log_util;

/
