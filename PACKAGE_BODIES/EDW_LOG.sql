--------------------------------------------------------
--  DDL for Package Body EDW_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_LOG" AS
/* $Header: EDWSRLGB.pls 120.1 2005/06/13 00:31:32 amitgupt noship $  */
VERSION	CONSTANT CHAR(80) := '$Header: EDWSRLGB.pls 120.1 2005/06/13 00:31:32 amitgupt noship $';


-- ------------------------------------------------------------------
-- Name: put_names
-- Desc: Setup which directory to put the log and what the log file
--       name is.  The directory setup is used only if the program
--       is not run thru concurrent manager
-- -----------------------------------------------------------------
PROCEDURE put_names(
	p_log_file		VARCHAR2,
	p_out_file		VARCHAR2,
	p_directory		VARCHAR2) IS
BEGIN
    /*
    logic used is :
    if edw_debug is set to yes, we need detailed file logging.
    if edw_debug is set to no, but the fnd profile AFLOG_ENABLED is 'Y' and
    AFLOG_LEVEL is at statement level, then also we need g_debug to be true.
    when a user says that AFLOG_LEVEL is at statement level, they are expecting
    detailed logging.
    scenario:
    A user may set the AFLOG level to statement and may not set the EDW_DEBUG flag
    to Yes. In this case, we need to start the detailed logging.
    we need to have two separate entities, edw_debug and then fnd since we
    want to keep separate the file logging and the fnd logging
    */
    --do not directly access AFLOG_ENABLED and AFLOG_LEVEL
	IF (fnd_profile.value('EDW_DEBUG') = 'Y') or FND_LOG.G_CURRENT_RUNTIME_LEVEL=FND_LOG.LEVEL_STATEMENT then
		g_debug := true;
	ELSE
      g_debug := false;
    END IF;
    FND_FILE.PUT_NAMES(p_log_file,p_out_file,p_directory);
    g_version_GT_1159:=is_oracle_apps_GT_1159;
END put_names;


-- ------------------------------------------------------------------
-- Name: print_duration
-- Desc: Given a duration in days, it return the dates in
--       a more readable format: x days HH:MM:SS
-- -----------------------------------------------------------------
FUNCTION duration(
	p_duration		number) return VARCHAR2 IS
BEGIN
   return(to_char(floor(p_duration)) ||' Days '||
        to_char(mod(floor(p_duration*24), 24))||':'||
        to_char(mod(floor(p_duration*24*60), 60))||':'||
        to_char(mod(floor(p_duration*24*60*60), 60)));
END duration;

-- ------------------------------------------------------------------
-- Name: debug_line
-- Desc: If debug flag is turned on, the log will be printed
-- -----------------------------------------------------------------
PROCEDURE debug_line(
                p_text			VARCHAR2) IS
BEGIN
  IF (g_debug) THEN
    put_line(p_text,FND_LOG.LEVEL_STATEMENT);
  END IF;
END debug_line;

procedure put_conc_log(p_text varchar2) is
l_len number;
l_start number:=1;
l_end number:=1;
last_reached boolean:=false;
Begin
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
    FND_FILE.PUT_LINE(FND_FILE.LOG,substr(p_text, l_start, 250));
    l_start:=l_start+250;
    if last_reached then
      exit;
    end if;
  end loop;
Exception when others then
  null;
End;

-- ------------------------------------------------------------------
-- Name: put_line
-- Desc: For now, just a wrapper on top of fnd_file
-- -----------------------------------------------------------------
PROCEDURE put_line(
p_text VARCHAR2
) IS
BEGIN
  put_line(p_text,FND_LOG.LEVEL_PROCEDURE);
END put_line;
----------------------
PROCEDURE put_line(
p_text VARCHAR2,
p_severity number
) IS
Begin
  put_conc_log(p_text);
  if p_severity>=FND_LOG.G_CURRENT_RUNTIME_LEVEL and g_version_GT_1159 then --this is for perf
    put_fnd_log(p_text,p_severity);
  end if;
Exception when others then
  null;
End;

procedure put_fnd_log(p_text varchar2,p_severity number) is
l_len number;
l_start number:=1;
l_end number:=1;
last_reached boolean:=false;
Begin
  if p_text is null or p_text='' then
    return;
  end if;
  l_len:=nvl(length(p_text),0);
  if l_len <=0 then
    return;
  end if;
  if g_fnd_log_module is null then
    g_fnd_log_module:='bis.edw.collection';
  end if;
  while true loop
    l_end:=l_start+3990;
    if l_end>=l_len then
      last_reached:=true;
    end if;
    --check added to supress GSCC warning
    if(p_severity >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(p_severity,g_fnd_log_module,substr(p_text, l_start,3990));
    end if;
    l_start:=l_start+3990;
    if last_reached then
      exit;
    end if;
  end loop;
Exception when others then
  put_conc_log('Error in put_fnd_log '||sqlerrm);
  null;
End;

function is_oracle_apps_GT_1159 return boolean is
l_list varcharTableType;
l_number_list number;
l_version varchar2(200);
l_version_GT_1159 boolean;
Begin
  l_version:=get_app_version;
  if l_version is null then
    l_version_GT_1159:=false;
    return l_version_GT_1159;
  end if;
  if parse_names(l_version,'.',l_list,l_number_list)=false then
    return false;
  end if;
  if to_number(l_list(1))>11 then
    l_version_GT_1159:=true;
  elsif to_number(l_list(2))>5 then
    l_version_GT_1159:=true;
  elsif to_number(l_list(3))>9 then
    l_version_GT_1159:=true;
  else
    l_version_GT_1159:=false;
  end if;
  if l_version_GT_1159 then
    put_conc_log('Oracle Apps version > 11.5.9');
  else
    put_conc_log('Oracle Apps version NOT > 11.5.9');
  end if;
  return l_version_GT_1159;
Exception when others then
  put_conc_log('Error in is_oracle_apps_GT_1159 '||sqlerrm);
  return false;
End;

function get_app_version return varchar2 is
cursor c1 is select release_name from fnd_product_groups;
l_version varchar2(200);
Begin
  open c1;
  fetch c1 into l_version;
  close c1;
  put_conc_log('Oracle Apps Version '||l_version);
  return l_version;
Exception when others then
  put_conc_log('Error in get_app_version '||sqlerrm);
  return null;
End;

function parse_names(
p_list varchar2,
p_separator varchar2,
p_names out NOCOPY varcharTableType,
p_number_names out NOCOPY number)
return boolean is
l_start number;
l_end number;
l_len number;
Begin
  p_number_names:=0;
  if p_list is null then
    return true;
  end if;
  l_len:=length(p_list);
  if l_len<=0 then
    return true;
  end if;
  if instr(p_list,p_separator)=0 then
    p_number_names:=1;
    p_names(p_number_names):=ltrim(rtrim(p_list));
    return true;
  end if;
  l_start:=1;
  loop
    l_end:=instr(p_list,p_separator,l_start);
    if l_end=0 then
      l_end:=l_len+1;
    end if;
    p_number_names:=p_number_names+1;
    p_names(p_number_names):=ltrim(rtrim(substr(p_list,l_start,(l_end-l_start))));
    l_start:=l_end+1;
    if l_end>=l_len then
      exit;
    end if;
  end loop;
  return true;
Exception when others then
 put_conc_log('Error in parse_names '||sqlerrm);
 return false;
End;

End;

/
