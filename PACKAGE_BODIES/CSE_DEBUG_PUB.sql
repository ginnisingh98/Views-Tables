--------------------------------------------------------
--  DDL for Package Body CSE_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_DEBUG_PUB" AS
/* $Header: CSEPDBGB.pls 120.3 2006/08/16 20:21:33 brmanesh noship $  */

  l_debug varchar2(1) := nvl(fnd_profile.value('cse_debug_option'),'N');

  FUNCTION set_debug_file(p_file in varchar2 default null) RETURN varchar2 IS
    rtn_val    varchar2(100);
    l_cse      varchar2(3) := 'cse';
    l_sysdate  date := sysdate;
  BEGIN

    IF g_dir is null THEN
      g_dir  := nvl(fnd_profile.value('cse_debug_log_directory'), '/tmp');
    END IF;

    IF g_file IS null THEN
      IF p_file IS null THEN
        g_file := l_cse||'.'||to_char(l_sysdate,'DDMONYYYY')||'.dbg';
      ELSE
        g_file := P_FILE;
      END IF;
    END IF;

    rtn_val := g_dir||'/'|| g_file;
    return(rtn_val);

  EXCEPTION
    WHEN others THEN
      debug_off;
      rtn_val := null;
      return(rtn_val);
  END set_debug_file;


  PROCEDURE debug_on IS
    l_file  varchar2(250);
  BEGIN
    IF g_file is null THEN
      l_file := set_debug_file;
    END IF;
    g_file_ptr := utl_file.fopen(g_dir, g_file, 'a');
    cse_debug_pub.g_debug := TRUE;
  EXCEPTION
    WHEN others THEN
      null;
  END debug_on;


  PROCEDURE debug_off IS
  BEGIN
    cse_debug_pub.g_debug := FALSE;
    utl_file.fclose(g_file_ptr);
  EXCEPTION
    WHEN others THEN
      null;
  END debug_off;


  FUNCTION isdebugon RETURN boolean IS
  BEGIN
    RETURN(CSE_DEBUG_PUB.G_DEBUG);
  END isdebugon;


  PROCEDURE set_debug_level(p_debug_level in number ) IS
  BEGIN
    IF p_debug_level = G_BASIC THEN
      g_debug_level := G_BASIC;
    ELSE
      g_debug_level := G_DETAILED;
    END IF;
  END set_debug_level;


  PROCEDURE add(debug_msg in Varchar2, debug_level in Number ) IS
  BEGIN
    IF l_debug = 'Y' THEN
      debug_on;
      IF (isdebugon) THEN
        IF g_file IS not null THEN
          IF (g_debug_level >= debug_level) THEN
            utl_file.put_line(g_file_ptr, debug_msg);
            utl_file.fflush(g_file_ptr);
          END IF;
        END IF; -- file
      END IF; -- debug on
      debug_off;
    END IF;
  EXCEPTION
    WHEN others THEN
      debug_off; -- Internal exception turn the debug off
  END add; -- Add

END cse_debug_pub;

/
