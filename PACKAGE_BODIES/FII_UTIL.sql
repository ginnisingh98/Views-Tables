--------------------------------------------------------
--  DDL for Package Body FII_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_UTIL" AS
/* $Header: FIIUTILB.pls 115.15 2004/08/10 23:24:25 phu noship $  */
VERSION	CONSTANT CHAR(80) := '$Header: FIIUTILB.pls 115.15 2004/08/10 23:24:25 phu noship $';


-- ------------------------
-- Global Variables
-- ------------------------
g_debug 	BOOLEAN := FALSE;
g_timer_start	DATE := NULL;
g_duration	NUMBER := NULL;

PROCEDURE initialize(
	p_log_file		VARCHAR2,
	p_out_file		VARCHAR2,
	p_directory		VARCHAR2,
        p_obj_name              VARCHAR2 DEFAULT 'FII') IS
BEGIN
  IF (fnd_profile.value('FII_DEBUG_MODE') = 'Y') THEN
	g_debug := TRUE;
  ELSE
	g_debug := FALSE;
  END IF;

  g_obj_name := p_obj_name;

  FND_FILE.PUT_NAMES(
	p_log_file,
	p_out_file,
	NVL(p_directory, fnd_profile.value('BIS_DEBUG_LOG_DIRECTORY')));
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



 PROCEDURE put_line (p_text   VARCHAR2) IS

   l_len   number(10);
   l_start number(10) :=1;
   l_end   number(10) :=1;
   last_reached boolean:=false;

 BEGIN

     if p_text is null or p_text='' then
       return;
     end if;
     l_len:=nvl(length(p_text),0);
     if l_len <=0 then
       return;
     end if;

     while true loop
      l_end:=l_start+150;
      if l_end >= l_len then
       l_end:=l_len;
       last_reached:=true;
      end if;
      FND_FILE.PUT_LINE(FND_FILE.LOG,substr(p_text, l_start, 150));
      l_start:=l_start+150;
      if last_reached then
       exit;
      end if;
     end loop;

  ----------------------------------------------------------------------------------
  -- We need to comment out this call for now, as it impacts the Incremental Update
  -- for GL Base Summary which uses subworker (the parent request hangs after child
  -- requests are done). We will find out the reason and make necessary fix for 6.0G
  ----------------------------------------------------------------------------------
   --**  FND_LOG.String(6, g_obj_name, p_text);

 EXCEPTION
    WHEN OTHERS THEN
       NULL;
 END put_line;




FUNCTION get_schema_name(
    p_app_short_name in varchar2 default 'FII'
) return varchar2 IS
    l_status	varchar2(512);
    l_industry	varchar2(512);
	l_schema	varchar2(512);
BEGIN
    if( fnd_installation.get_app_info( p_app_short_name,
                            l_status, l_industry, l_schema ) )
    then
		return l_schema;
	else
		return null;
    end if;
END get_schema_name;


FUNCTION get_apps_schema_name RETURN VARCHAR2 IS

   l_apps_schema_name VARCHAR2(30);

   CURSOR c_apps_schema_name IS
      SELECT oracle_username
	FROM fnd_oracle_userid WHERE oracle_id
	BETWEEN 900 AND 999 AND read_only_flag = 'U';
BEGIN

   OPEN c_apps_schema_name;
   FETCH c_apps_schema_name INTO l_apps_schema_name;
   CLOSE c_apps_schema_name;
   RETURN l_apps_schema_name;

EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END get_apps_schema_name;



PROCEDURE truncate_table(
    p_table_name     in varchar2,
    p_app_short_name in varchar2 default 'FII',
	p_retcode		 out nocopy varchar2
) IS
	l_schema		varchar2(512);
	l_stmt			varchar2(1024);
	l_debug_flag    varchar2(1);
	bad_schema_ex	exception;
BEGIN
	p_retcode := 0;
	l_debug_flag := nvl( fnd_profile.value( 'FII_DEBUG_MODE' ), 'N' );
	l_schema := get_schema_name( p_app_short_name );
	if( l_schema = null )
	then
		raise bad_schema_ex;
	else
		l_stmt := 'truncate table ' || l_schema || '.' || p_table_name;
		execute immediate l_stmt;
	end if;
EXCEPTION
	when bad_schema_ex then
		if l_debug_flag = 'Y' then
			put_line( 'truncate_table : bad schema' );
		end if;
		p_retcode := -1;
    when others then
		if l_debug_flag = 'Y' then
			put_line( 'truncate_table : ' || sqlcode || ' ' || sqlerrm );
		end if;
		p_retcode := -1;
END truncate_table;

PROCEDURE drop_table(
    p_table_name     in varchar2,
    p_app_short_name in varchar2 default 'FII',
	p_retcode        out nocopy varchar2
) IS
    l_schema    	varchar2(512);
    l_stmt          varchar2(1024);
	l_debug_flag	varchar2(1);
	bad_schema_ex	exception;
BEGIN
	p_retcode := 0;
	l_debug_flag := nvl( fnd_profile.value( 'FII_DEBUG_MODE' ), 'N' );
    l_schema := get_schema_name( p_app_short_name );
    if( l_schema = null )
    then
		raise bad_schema_ex;
    else
        l_stmt := 'drop table ' || l_schema || '.' || p_table_name;
        execute immediate l_stmt;
    end if;
EXCEPTION
	when bad_schema_ex then
		if l_debug_flag = 'Y' then
			put_line( 'drop_table : bad schema' );
		end if;
		p_retcode := -1;
    when others then
		if l_debug_flag = 'Y' then
			put_line( 'drop_table : ' || sqlcode || ' ' || sqlerrm );
		end if;
		p_retcode := -1;
END drop_table;


Function get_Utl_File_Dir return VARCHAR2 IS
 l_dir VARCHAR2(1000);
 l_utl_dir VARCHAR2(100);
 l_count   NUMBER := 0;
 l_log_begin   NUMBER := 0;
 l_log_end   NUMBER := 0;
 l_comma_pos   NUMBER := 0;
 stmt   VARCHAR2(200);
 cid   NUMBER;
 l_dummy   NUMBER;

BEGIN
 SELECT value into l_dir
 FROM v$parameter where upper(name) = 'UTL_FILE_DIR';

 l_dir := l_dir || ',';		-- Add sentinel

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


 PROCEDURE write_log( p_text VARCHAR2) IS

   l_len   number(10);
   l_start number(10) :=1;
   l_end   number(10) :=1;
   last_reached boolean:=false;

 BEGIN

     if p_text is null or p_text='' then
       return;
     end if;
     l_len:=nvl(length(p_text),0);
     if l_len <=0 then
       return;
     end if;

     while true loop
      l_end:=l_start+150;
      if l_end >= l_len then
       l_end:=l_len;
       last_reached:=true;
      end if;
      FND_FILE.PUT_LINE(FND_FILE.LOG,substr(p_text, l_start, 150));
      l_start:=l_start+150;
      if last_reached then
       exit;
      end if;
     end loop;

  ----------------------------------------------------------------------------------
  -- We need to comment out this call for now, as it impacts the Incremental Update
  -- for GL Base Summary which uses subworker (the parent request hangs after child
  -- requests are done). We will find out the reason and make necessary fix for 6.0G
  ----------------------------------------------------------------------------------
   --**  FND_LOG.String(6, g_obj_name, p_text);

 EXCEPTION
    WHEN OTHERS THEN
       NULL;
 END write_log;


PROCEDURE write_output( p_text VARCHAR2) IS
BEGIN
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, p_text);
END write_output;

end;

/
