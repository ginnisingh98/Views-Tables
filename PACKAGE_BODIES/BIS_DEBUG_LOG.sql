--------------------------------------------------------
--  DDL for Package Body BIS_DEBUG_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_DEBUG_LOG" AS
/* $Header: BISDLOGB.pls 120.2 2005/06/29 06:57:05 aguwalan noship $  */
g_module  VARCHAR2(200) := get_bis_schema_name ||'.BIS_DEBUG_LOG';

-- ------------------------
-- Public Procedures
-- ------------------------
PROCEDURE setup_file(
p_log_file VARCHAR2,
p_out_file VARCHAR2,
p_directory VARCHAR2) is
l_dir varchar2(300);
Begin
  g_module := get_bis_schema_name || '.' || NVL(p_log_file, 'BIS_DEBUG_LOG');
  l_dir:=p_directory;
  if l_dir is null then
    l_dir:=fnd_profile.value('UTL_FILE_LOG');
    if l_dir is null then
      l_dir:='/sqlcom/log';
    end if;
  end if;
  FND_FILE.PUT_NAMES(p_log_file,p_out_file,l_dir);

  --if fnd_profile.value('EDW_DEBUG')='Y' or
  --   FND_LOG.G_CURRENT_RUNTIME_LEVEL=FND_LOG.LEVEL_STATEMENT
  if FND_LOG.TEST( FND_LOG.LEVEL_STATEMENT , g_module ) then
    g_debug:=true;
  else
    g_debug:=false;
  end if;
Exception when others then
  raise;
End;

procedure set_debug is
Begin
  g_debug:=true;
Exception when others then
  raise;
End;

procedure unset_debug is
Begin
  g_debug:=false;
Exception when others then
  raise;
End;

Procedure close is
Begin
  FND_FILE.close;
Exception when others then
  raise;
End;

PROCEDURE debug_line(p_text VARCHAR2) is
Begin
  if g_debug then
    put_line(p_text, FND_LOG.LEVEL_STATEMENT);
  end if;
Exception when others then
  raise;
End;

/*
 * Added for FND_LOG uptaking.
 */
PROCEDURE debug_line(p_text VARCHAR2, p_severity NUMBER) is
Begin
  if g_debug then
    put_line(p_text, p_severity);
  end if;
Exception when others then
  raise;
End;

PROCEDURE debug(p_text VARCHAR2) is
Begin
  if g_debug then
    put(p_text, FND_LOG.LEVEL_STATEMENT);
  end if;
Exception when others then
  raise;
End;

/*
 * Added for FND_LOG uptaking.
 */
PROCEDURE debug(p_text VARCHAR2, p_severity NUMBER) is
Begin
  if g_debug then
    put(p_text, p_severity);
  end if;
Exception when others then
  raise;
End;

PROCEDURE debug_line_n(p_text VARCHAR2) is
Begin
  if g_debug then
    new_line;
    put_line(p_text, FND_LOG.LEVEL_STATEMENT);
  end if;
Exception when others then
  raise;
End;

/*
 * Added for FND_LOG uptaking.
 */
PROCEDURE debug_line_n(p_text VARCHAR2, p_severity NUMBER) is
Begin
  if g_debug then
    new_line;
    put_line(p_text, p_severity);
  end if;
Exception when others then
  raise;
End;


PROCEDURE put_line(p_text VARCHAR2) is
Begin
  put_line(p_text, FND_LOG.LEVEL_EXCEPTION);
End;

/*
 * Added for FND_LOG uptaking.
 */
PROCEDURE put_line(p_text VARCHAR2, p_severity NUMBER) is
 l_len number;
 l_start number:=1;
 l_end number:=1;
 last_reached boolean:=false;
 begin
 if p_text is null or p_text='' then
   return;
 end if;
 l_len:=nvl(length(p_text),0);
 if l_len <=0 then
   return;
 end if;
 while true loop
   l_end:=l_start+250;
   if l_end >= l_len then
     l_end:=l_len;
     last_reached:=true;
   end if;
   FND_FILE.PUT_LINE(FND_FILE.LOG,substr(p_text,l_start,250));

   if p_severity >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
   then
     FND_LOG.STRING( p_severity, g_module, substr(p_text,l_start,250));
   end if;

   l_start:=l_start+250;
   if last_reached then
     exit;
   end if;
 end loop;
Exception when others then
  raise;
End;



PROCEDURE put(p_text VARCHAR2) is
Begin
  put(p_text, FND_LOG.LEVEL_EXCEPTION);
End;

/*
 * Added for FND_LOG uptaking.
 */
PROCEDURE put(p_text VARCHAR2, p_severity NUMBER ) is
 l_len number;
 l_start number:=1;
 l_end number:=1;
 last_reached boolean:=false;
 begin
 if p_text is null or p_text='' then
   return;
 end if;
 l_len:=nvl(length(p_text),0);
 if l_len <=0 then
   return;
 end if;

 while true loop
   l_end:=l_start+250;
   if l_end >= l_len then
     l_end:=l_len;
     last_reached:=true;
   end if;
   FND_FILE.PUT(FND_FILE.LOG,substr(p_text,l_start,250));

   if p_severity >= FND_LOG.G_CURRENT_RUNTIME_LEVEL then
     FND_LOG.STRING( p_severity, g_module, substr(p_text,l_start,250));
   end if;

   l_start:=l_start+250;
   if last_reached then
     exit;
   end if;
 end loop;
Exception when others then
  raise;
End;



PROCEDURE put_line_n(p_text VARCHAR2) is
Begin
  put_line_n(p_text, FND_LOG.LEVEL_EXCEPTION );
Exception when others then
  raise;
End;

/*
 * Added for FND_LOG uptaking.
 */
PROCEDURE put_line_n(p_text VARCHAR2, p_severity NUMBER) is
Begin
  new_line;
  put_line(p_text, p_severity);
Exception when others then
  raise;
End;


PROCEDURE new_line is
Begin
  put_line(' ');
Exception when others then
  raise;
End;

PROCEDURE put_time is
Begin
  put_line(' '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
Exception when others then
  raise;
End;

PROCEDURE debug_time is
Begin
  if g_debug then
    put_line(' '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
  end if;
Exception when others then
  raise;
End;

function get_time return date is
Begin
  return sysdate;
Exception when others then
  raise;
End;

PROCEDURE put_out(p_text VARCHAR2) is
 l_len number;
 l_start number:=1;
 l_end number:=1;
 last_reached boolean:=false;
 begin
 if p_text is null or p_text='' then
   return;
 end if;
 l_len:=nvl(length(p_text),0);
 if l_len <=0 then
   return;
 end if;
 while true loop
   l_end:=l_start+250;
   if l_end >= l_len then
     l_end:=l_len;
     last_reached:=true;
   end if;
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,substr(p_text,l_start,250));
   l_start:=l_start+250;
   if last_reached then
     exit;
   end if;
 end loop;
Exception when others then
  raise;
End;

PROCEDURE put_out_n(p_text VARCHAR2) is
Begin
  put_out(' ');
  put_out(p_text);
Exception when others then
  raise;
End;

/*
function to return BIS schema name
*/
function get_bis_schema_name return varchar2 is
  l_dummy1 varchar2(2000);
  l_dummy2 varchar2(2000);
  l_schema varchar2(400);
Begin
  if FND_INSTALLATION.GET_APP_INFO('BIS',l_dummy1, l_dummy2,l_schema) = false then
    return null;
  end if;
  return l_schema;
Exception when others then
  return null;
End;
End;

/
