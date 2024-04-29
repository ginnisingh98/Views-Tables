--------------------------------------------------------
--  DDL for Package Body OZF_TP_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_TP_UTIL_PVT" AS
/* $Header: ozfvtpub.pls 120.1 2005/09/26 16:42:42 mkothari noship $  */
   VERSION      CONSTANT CHAR(80) := '$Header: ozfvtpub.pls 120.1 2005/09/26 16:42:42 mkothari noship $';


-- ------------------------
-- Global Variables
-- ------------------------
g_debug 	BOOLEAN := FALSE;
g_timer_start	DATE := NULL;
g_duration	NUMBER := NULL;


PROCEDURE initialize(
	p_log_file		VARCHAR2,
	p_out_file		VARCHAR2,
	p_directory		VARCHAR2) IS
BEGIN
	g_debug := TRUE;

/*
  FND_FILE.PUT_NAMES(
	p_log_file,
	p_out_file,
	NVL(p_directory, fnd_profile.value('BIS_DEBUG_LOG_DIRECTORY')));
*/


END initialize;


PROCEDURE put_timestamp(
	p_text			VARCHAR2) IS
BEGIN
  put_line(p_text||' - '||to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
END put_timestamp;



PROCEDURE start_timer IS
BEGIN
  g_duration := 0;
  g_timer_start := sysdate;
END start_timer;



PROCEDURE stop_timer IS
BEGIN

  IF g_timer_start IS NULL THEN
       g_duration := 0;
  ELSE
	g_duration := sysdate - g_timer_start;
  END IF;
  g_timer_start := NULL;

END stop_timer;


PROCEDURE print_timer(
	p_text		VARCHAR2)
IS
	l_duration		NUMBER := NULL;
BEGIN
   IF (g_timer_start IS NOT NULL) THEN
	l_duration := sysdate - g_timer_start;
   ELSE
	l_duration := g_duration;
   END IF;

   IF (l_duration IS NOT NULL) THEN
     put_line(p_text||' - '||
        to_char(floor(l_duration)) ||' Days '||
        to_char(mod(floor(l_duration*24), 24))||':'||
        to_char(mod(floor(l_duration*24*60), 60))||':'||
        to_char(mod(floor(l_duration*24*60*60), 60)));
   END IF;

END print_timer;



PROCEDURE debug_line(
                p_text			VARCHAR2) IS
BEGIN
  IF (g_debug) THEN
    put_line(p_text);
  END IF;
END debug_line;



PROCEDURE put_line(
                p_text			VARCHAR2) IS
BEGIN
     FND_FILE.PUT_LINE(FND_FILE.LOG, p_text);

--     DBMS_OUTPUT.PUT_LINE(  to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') || '-- ' ||p_text);

END put_line;


FUNCTION get_schema_name(
    p_app_short_name in varchar2 default 'OZF'
) return varchar2 IS
    l_status    varchar2(512);
    l_industry  varchar2(512);
        l_schema        varchar2(512);
BEGIN
    if( fnd_installation.get_app_info( p_app_short_name,
                            l_status, l_industry, l_schema ) )
    then
                return l_schema;
        else
                return null;
    end if;
END get_schema_name;

Function get_utl_file_dir return VARCHAR2 IS
 l_dir          VARCHAR2(1000);
 l_utl_dir      VARCHAR2(100);
 l_count        NUMBER := 0;
 l_log_begin    NUMBER := 0;
 l_log_end      NUMBER := 0;
 l_comma_pos    NUMBER := 0;
 l_dummy        NUMBER;

BEGIN
 SELECT value into l_dir
 FROM v$parameter where upper(name) = 'UTL_FILE_DIR';

 l_dir := l_dir || ',';         -- Add sentinel

 l_log_begin := INSTR(l_dir, '/log');

    IF (l_log_begin = 0) THEN /* then get the first string */
        l_utl_dir := substr(l_dir, 1, INSTR(l_dir, ',') - 1);
        return l_utl_dir;
    END IF;
 l_log_end  := INSTR(l_dir, ',', l_log_begin) - 1;

 --have now determined the first occurrence of '/log' and the end pos
 -- now to determine the start position of the log directory

 l_dir := substr(l_dir, 0, l_log_end);

 LOOP
   l_comma_pos := INSTR(l_dir, ',', l_comma_pos+1);
   IF (l_comma_pos <> 0) THEN
    l_count :=   l_comma_pos + 1;
   END IF;

   EXIT WHEN l_comma_pos = 0;
 END LOOP;

 l_utl_dir := substr(l_dir, l_count+1, l_log_end);

 RETURN l_utl_dir;

EXCEPTION
     when others then
        return null;
END;



END OZF_TP_UTIL_PVT;

/
