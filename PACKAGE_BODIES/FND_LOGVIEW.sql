--------------------------------------------------------
--  DDL for Package Body FND_LOGVIEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_LOGVIEW" as
/* $Header: AFUTLPFB.pls 115.16 2002/02/08 21:49:36 nbhambha ship $ */


M_ROWS_PER_PAGE NUMBER := 1000;

function convert_special_chars(inval in varchar2) return varchar2 is
begin
 return(replace(
             replace(
             replace(
             replace(inval, '&', '&'||'amp;' ),
                            '"', '&'||'quot;'),
                            '<', '&'||'lt;'  ),
                            '>', '&'||'gt;'  ));
end;

procedure preferences is
begin
   preferences_sysadmin;
end;

procedure preferences_user is
begin
   preferences_generic('U');
end;

procedure preferences_sysadmin is
begin
   preferences_generic('S');
end;

procedure preferences_sysadmin_debug is
begin
   preferences_generic('SD');
end;

/* Mode = 'U' for user mode, or 'S' for sysadmin */
procedure preferences_generic(user_mode in varchar2,
                              user_id_x in number default NULL) is
   AFLOG_ENABLED     BOOLEAN;
   AFLOG_ENABLED_TXT VARCHAR2(30);
   AFLOG_FILENAME    VARCHAR2(255);
   AFLOG_LEVEL       NUMBER;
   AFLOG_MODULE      VARCHAR2(2000);
   RESULT            BOOLEAN;
   SESSION_ID        NUMBER;
   LEVEL_1           VARCHAR2(30);
   LEVEL_2           VARCHAR2(30);
   LEVEL_3           VARCHAR2(30);
   LEVEL_4           VARCHAR2(30);
   LEVEL_5           VARCHAR2(30);
   LEVEL_6           VARCHAR2(30);
begin

if icx_sec.validateSession
then
 if(user_mode = 'SD') then
   htp.p('<P><B>Note: you are running an unsupported screen.  This developer/troubleshooting screen is intended only as a last resort when regular screens are unreachable from the menu.  ');
   htp.p('You may get "access denied" errors after you press buttons in this screen; ignore them and press the back arrow to get back.</B></P>');
 end if;

  if(substr(user_mode,1,1) = 'S') then
    /* Don't allow people who don't have sysadmin function */
    /* to run sysadmin version of the page.  */
    if((user_mode = 'S') and
      (not fnd_function.test('FND_LOGPREFS'))) then
       htp.p('Access denied; function FND_LOGPREFS required.');
       return;
    end if;

    FND_PROFILE.GET_SPECIFIC(name_z => 'AFLOG_ENABLED',
                             user_id_z =>           -9999999,
                             responsibility_id_z => -9999999,
                             application_id_z =>    -9999999,
                             val_z => aflog_enabled_txt,
                             defined_z => result);
    FND_PROFILE.GET_SPECIFIC(name_z => 'AFLOG_FILENAME',
                             user_id_z =>           -9999999,
                             responsibility_id_z => -9999999,
                             application_id_z =>    -9999999,
                             val_z => aflog_filename,
                             defined_z => result);
    FND_PROFILE.GET_SPECIFIC(name_z => 'AFLOG_LEVEL',
                             user_id_z =>           -9999999,
                             responsibility_id_z => -9999999,
                             application_id_z =>    -9999999,
                             val_z => aflog_level,
                             defined_z => result);
    FND_PROFILE.GET_SPECIFIC(name_z => 'AFLOG_MODULE',
                             user_id_z =>           -9999999,
                             responsibility_id_z => -9999999,
                             application_id_z =>    -9999999,
                             val_z => aflog_module,
                             defined_z => result);
    if (aflog_enabled_txt = 'Y') then
       aflog_enabled := TRUE;
     else
       aflog_enabled := FALSE;
    end if;
  elsif(user_id_x is not null) then
    /* Getting profile values for a particular user (not current user)*/
    FND_PROFILE.GET_SPECIFIC(name_z => 'AFLOG_ENABLED',
                             user_id_z => user_id_x,
                             val_z => aflog_enabled_txt,
                             defined_z => result);
    FND_PROFILE.GET_SPECIFIC(name_z => 'AFLOG_FILENAME',
                             user_id_z => user_id_x,
                             val_z => aflog_filename,
                             defined_z => result);
    FND_PROFILE.GET_SPECIFIC(name_z => 'AFLOG_LEVEL',
                             user_id_z => user_id_x,
                             val_z => aflog_level,
                             defined_z => result);
    FND_PROFILE.GET_SPECIFIC(name_z => 'AFLOG_MODULE',
                             user_id_z => user_id_x,
                             val_z => aflog_module,
                             defined_z => result);
    if (aflog_enabled_txt = 'Y') then
       aflog_enabled := TRUE;
     else
       aflog_enabled := FALSE;
    end if;
  else /* Getting profile values for the current user */
    if (FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y') then
       aflog_enabled_txt := 'Y';
       aflog_enabled := TRUE;
     else
       aflog_enabled_txt := 'N';
       aflog_enabled := FALSE;
    end if;
    aflog_filename := FND_PROFILE.VALUE('AFLOG_FILENAME');
    aflog_level := to_number(FND_PROFILE.VALUE('AFLOG_LEVEL'));
    aflog_module := FND_PROFILE.VALUE('AFLOG_MODULE');
  end if;

  if(AFLOG_ENABLED) then
     AFLOG_ENABLED_TXT := 'Checked';
  else
     AFLOG_ENABLED_TXT := '';
  end if;

  LEVEL_1 := '';
  LEVEL_2 := '';
  LEVEL_3 := '';
  LEVEL_4 := '';
  LEVEL_5 := '';
  LEVEL_6 := '';

  if(AFLOG_LEVEL = '1') then
     LEVEL_1 := 'Checked';
  elsif(AFLOG_LEVEL = '2') then
     LEVEL_2 := 'Checked';
  elsif(AFLOG_LEVEL = '3') then
     LEVEL_3 := 'Checked';
  elsif(AFLOG_LEVEL = '4') then
     LEVEL_4 := 'Checked';
  elsif(AFLOG_LEVEL = '5') then
     LEVEL_5 := 'Checked';
  elsif(AFLOG_LEVEL = '6') then
     LEVEL_6 := 'Checked';
  end if;


 htp.p('<html>');
 if (substr(user_mode,1,1) = 'S') then
    htp.p('<title>'||'Site Logging Preferences'||'</title>');
 else
    htp.p('<title>'||'User Logging Preferences'||'</title>');
 end if;


 if (icx_sec.g_mode_code in ('115J', '115P', 'SLAVE')) then
    htp.p('<body bgcolor= "#CCCCCC">');
 else
    htp.p('<body bgcolor="'||icx_plug_utilities.bgcolor||'">');
 end if;

 htp.p('

<FORM Method="post" Action="FND_LOGVIEW.UPDATE_PREFS">

<TABLE>
<TR>
<TH></TH><TH ALIGN=LEFT>
');
 if (substr(user_mode,1,1) = 'S') then
    htp.p('<H2>Site Logging Preferences</H2>');
 else
    if (user_id_x is not null) then
       htp.p('<H2>User Logging Preferences</H2><P> preferences for Userid: '||
       '<INPUT Type="text" size=20 maxlength=255 name="USER_ID" value="'||
       to_char(user_id_x)||'"></P>');
    else
       htp.p('<H2>User Logging Preferences</H2>');
    end if;
 end if;

htp.p('
</TH>
</TR>
<TR><TD ALIGN=RIGHT VALIGN=TOP>
Runtime Logging Enabled:
</TD><TD>
<INPUT Type="checkbox"  Name="ENABLED" '||aflog_enabled_txt||
                      '>

</TD><P></P><TR><TD ALIGN=RIGHT VALIGN=TOP>
Logging level:
</TD><TD>
<INPUT Type="radio"  '||LEVEL_6||' Name="LEVEL" Value="6">Unexpected<BR>
<INPUT Type="radio"  '||LEVEL_5||' Name="LEVEL" Value="5">Error<BR>
<INPUT Type="radio"  '||LEVEL_4||' Name="LEVEL" Value="4">Exception<BR>
<INPUT Type="radio"  '||LEVEL_3||' Name="LEVEL" Value="3">Event<BR>
<INPUT Type="radio"  '||LEVEL_2||' Name="LEVEL" Value="2">Procedure<BR>
<INPUT Type="radio"  '||LEVEL_1||' Name="LEVEL" Value="1">Statement<BR>

</TD><P></P><TR><TD ALIGN=RIGHT VALIGN=TOP>
Filename:<BR>
(Normally left blank to log in database)
</TD><TD>
<INPUT Type="text" size=60 maxlength=255 name="FILENAME" value="'||
    AFLOG_FILENAME||'">


</TD><P></P><TR><TD ALIGN=RIGHT VALIGN=TOP>
Modules Enabled:
</TD><TD>
<TEXTAREA Type="text" maxlength=2000 rows=5 cols = 60 wrap=soft name="MODULE" >'||AFLOG_MODULE||'
</TEXTAREA>

</TD>
');
if(substr(user_mode,1,1) = 'S') then /* SYSADMIN MODE..... */
htp.p('
<TR><TD ALIGN=RIGHT VALIGN=TOP>
</TD><TD>
<INPUT Type=submit name=sysclearprefs
      Value="Clear site preferences">
</TD><P></P><TR><TD ALIGN=RIGHT VALIGN=TOP>
<!-- <INPUT Type=reset name=sysclear Value="Cancel">  -->
</TD><TD>
<INPUT Type=submit name=syssave Value="Save as site preferences">
<hr />
</TD></TR><TR><TD ALIGN=RIGHT VALIGN=TOP></TD><TD>
<TABLE border="1" ><TR><TD>
Session id to purge:
<INPUT Type="text" size=20 maxlength=255 name="SESSION_TO_PURGE" value="'||
to_char(icx_sec.getsessioncookie())||'">
</TD></TR><TR><TD><INPUT Type=submit name=sysclearsessionlog
     Value="Purge log data for particular session"></TD></TR>
</TR></TABLE>
</TD></TR><TR><TD ALIGN=RIGHT VALIGN=TOP></TD><TD>
<TABLE border="1" ><TR><TD>
User name to purge:
<INPUT Type="text" size=20 maxlength=255 name="USER_TO_PURGE" value="'||
fnd_global.user_name()||'">
</TD></TR><TR><TD><INPUT Type=submit name=sysclearuserlog
     Value="Purge log data for particular user"></TR>
</TD></TR></TABLE>
</TD></TR><TR><TD ALIGN=RIGHT VALIGN=TOP></TD><TD>
<TABLE border="1" ><TR><TD>
User name to set preferences for:
<INPUT Type="text" size=20 maxlength=255 name="USER_TO_SET" value="'||
fnd_global.user_name()||'">
</TD></TR><TR><TD><INPUT Type=submit name=syssetuserprefs
     Value="Navigate to user log preferences screen"></TR>
</TD></TR></TABLE>
</TD></TR><TR><TD ALIGN=RIGHT VALIGN=TOP></TD><TD>
<INPUT Type=submit name=syspurgeallusers
     Value="Purge log data for all sessions for all users"></TR>
</TD></TR>');
else /* USER MODE..... */
htp.p('
<TR><TD ALIGN=RIGHT VALIGN=TOP>
</TD><TD>
<INPUT Type=submit name=clearprefs
      Value="Clear user preferences and use defaults">

<TR><TD ALIGN=RIGHT VALIGN=TOP>
</TD><TD>
<INPUT Type=submit name=save Value="Save as user preferences">
<HR />
</TD></TR>
<TR><TD ALIGN=RIGHT VALIGN=TOP>
<!-- <INPUT Type=reset name=clear Value="Cancel">  -->
</TD><TD>
<INPUT Type=submit name=clearsessionlog
     Value="Purge log data for this current user session">

</TD></TR><TR><TD ALIGN=RIGHT VALIGN=TOP>
</TD><TD>
<INPUT Type=submit name=clearuserlog
     Value="Purge log data for all sessions belonging to this user">

</TD></TR>
');
end if;
htp.p('
</TABLE>
</FORM>
');
end if;  --icx_sec.validatesession

exception
    when others then
        htp.p(SQLERRM);
end;

/* Deprecated */
procedure find_display is
begin
  find;
end;

/* Deprecated */
procedure find is
begin
  find_sysadmin;
end;

procedure find_user is
begin
  find_log('U');
end;

procedure find_sysadmin is
begin
  find_log('S');
end;

procedure find_sysadmin_debug is
begin
  find_log('SD');
end;

/* Mode = 'U' for user mode, or 'S' for sysadmin */
procedure find_log(user_mode in varchar2) is
begin
if icx_sec.validateSession
then

 if(user_mode = 'SD') then
   htp.p('<P><B>Note: you are running an unsupported screen.  This developer/troubleshooting screen is intended only as a last resort when the regular screens are unreachable from the menu. </B></P>');
 end if;

 /* Don't allow people who don't have sysadmin function */
 /* to run sysadmin version of the page.  */
 if(user_mode = 'S') then
    if(not fnd_function.test('FND_LOGFIND')) then
       htp.p('Access denied; function FND_LOGFIND required.');
       return;
    end if;
 end if;


 htp.p('<html>');
 htp.p('<title>'||'Find Log'||'</title>');

 if (icx_sec.g_mode_code in ('115J', '115P', 'SLAVE')) then
    htp.p('<body bgcolor= "#CCCCCC">');
 else
    htp.p('<body bgcolor="'||icx_plug_utilities.bgcolor||'">');
 end if;

 htp.p('

<FORM Method="post" Action="FND_LOGVIEW.DISPLAY">

<TABLE>
<TR>
<TH></TH><TH ALIGN=LEFT>
<H2>Find Log</H2>
</TH>
</TR>
<TR><TD ALIGN=RIGHT VALIGN=TOP>
Logging level:
</TD><TD>
<INPUT Type="radio" Name="LEVEL" Value="6">Unexpected<BR>
<INPUT Type="radio" Name="LEVEL" Value="5">Error<BR>
<INPUT Type="radio" Name="LEVEL" Value="4">Exception<BR>
<INPUT Type="radio" Name="LEVEL" Value="3">Event<BR>
<INPUT Type="radio" Name="LEVEL" Value="2">Procedure<BR>
<INPUT Type="radio" checked Name="LEVEL" Value="1">Statement<BR>

</TD><P></P><TR><TD ALIGN=RIGHT VALIGN=TOP>
Module to view:
</TD><TD>
<INPUT Type="text" size=60 maxlength=255 name="MODULE" >

</TD><P></P><TR><TD ALIGN=RIGHT VALIGN=TOP>
Start Date in format <BR>'||fnd_date.canonical_DT_mask||':
</TD><TD>
<INPUT Type="text" size=40 maxlength=200 name="START_DATE" >

</TD><P></P><TR><TD ALIGN=RIGHT VALIGN=TOP>
End Date in format <BR>'||fnd_date.canonical_DT_mask||':
</TD><TD>
<INPUT Type="text" size=40 maxlength=200 name="END_DATE">

</TD><P></P><TR><TD ALIGN=RIGHT VALIGN=TOP>
Only show log for current self service session:
</TD><TD>
<INPUT Type="checkbox"  Name="ONLY_SESSION" >
</TD><P></P><TR><TD ALIGN=RIGHT VALIGN=TOP>
');

if(substr(user_mode,1,1) = 'S') then
htp.p('
Only show log for user
<INPUT Type="text" size=20 maxlength=80 name="USERNAME" value="'||
    fnd_profile.value('USERNAME')||'">:
</TD><TD>
<INPUT Type="checkbox"  Name="ONLY_USER" checked >

</TD><P></P><TR><TD ALIGN=RIGHT VALIGN=TOP>
');
end if;
htp.p('
Messages per result page:
</TD><TD>
<INPUT Type="text" size=10 maxlength=80 name="NUMROWS" value="'||
    M_ROWS_PER_PAGE||'">
</TD><P></P><TR><TD ALIGN=RIGHT VALIGN=TOP>
');
htp.p('
</TD><TD>
<INPUT Type=submit name=clearsessionlog
     Value="Purge log data for this current user session">

</TD><TR><TD ALIGN=RIGHT VALIGN=TOP>
</TD><TD>
<INPUT Type=submit name=clearuserlog
     Value="Purge log data for all sessions belonging to this user">

</TD><TR><TD ALIGN=RIGHT VALIGN=TOP>
<!-- <INPUT Type=reset name=clear Value="Cancel"> -->
</TD><TD>
');

if(substr(user_mode,1,1) = 'S') then
htp.p('
<INPUT Type=submit name=find_sysadmin Value="Find">
');
else
htp.p('
<INPUT Type=submit name=find_user Value="Find">
');
end if;

htp.p('

</TD></TABLE>
</FORM>
');
end if;  --icx_sec.validatesession

exception
    when others then
        htp.p(SQLERRM);
end;


procedure display( LEVEL     in VARCHAR2,
                MODULE       in VARCHAR2,
                START_DATE   in VARCHAR2,
                END_DATE     in VARCHAR2,
                ONLY_SESSION in VARCHAR2 default NULL,
                USERNAME     in VARCHAR2 default NULL,
                ONLY_USER    in VARCHAR2 default NULL,
                FIND_USER    in VARCHAR2 default NULL,
                FIND_SYSADMIN    in VARCHAR2 default NULL,
                CLEARSESSIONLOG  in VARCHAR2 default NULL,
                CLEARUSERLOG     in VARCHAR2 default NULL,
                STARTROW         in VARCHAR2 default NULL,
                NUMROWS          in VARCHAR2 default NULL)
is
  f_level      number;
  f_module     varchar2(2000);
  f_start_date date;
  f_end_date   date;
  f_session_id number;
  f_user_id    number;
  f_startrow   number;
  f_maxrow     number;
  f_numrows    number;
  f_buttonname   varchar2(255) := 'FIND_USER';
  log_level_name varchar2(80);
  timestamp_str  varchar2(80);
  found_username varchar2(100) := NULL;
  last_username  varchar2(100) := NULL;
  last_userid    number;

  TYPE  DYNAMIC_CUR IS REF CURSOR;
  row_set DYNAMIC_CUR;

  l_level      number;
  l_module     varchar2(255);
  l_msg_text   varchar2(4000);
  l_timestamp  date;
  l_session_id number;
  l_user_id    number;
  l_index      number;
  l_dynamic_sql varchar(2000);

  b_level      boolean := FALSE;
  b_module     boolean := FALSE;
  b_dates      boolean := FALSE;
  b_session_id boolean := FALSE;
  b_user_id    boolean := FALSE;
  b_previous_clause boolean := FALSE;

  nrows number;
begin
if icx_sec.validateSession
then
 if (find_user is not null) then
    f_buttonname := 'FIND_USER';
    f_user_id := fnd_global.user_id;
 elsif (find_sysadmin is not null) then
    f_buttonname := 'FIND_SYSADMIN';
    f_user_id := NULL;
 elsif (clearsessionlog is not null) then /* if user pressed... */
    nrows := FND_LOG_ADMIN.DELETE_BY_USER_SESSION(FND_GLOBAL.USER_ID,
                                   icx_sec.getsessioncookie());
    commit;
    htp.p(
       '<B>Cleared '|| nrows||
       ' rows of log data for this session.  Use back arrow to get back.</B>');
    return;
 elsif (clearuserlog is not null) then /* if user pressed... */
    nrows := FND_LOG_ADMIN.DELETE_BY_USER(FND_GLOBAL.USER_ID);
    commit;
    htp.p(
      '<B>Cleared '|| nrows ||
      ' rows of log data for this user.  Use back arrow to get back.</B>');
    return;
 else
    htp.p('<B>Error- no buttonpress in fnd_logview.display.</B>');
    return; /* Should never happen */
 end if;

 if (startrow is NULL) then
   f_startrow := 1;
 else
   f_startrow := to_number(startrow);
 end if;

 if (numrows is NULL) then
   f_numrows := M_ROWS_PER_PAGE;
 else
   f_numrows := to_number(numrows);
 end if;

 f_maxrow := f_startrow + f_numrows;


 f_level := level;
 f_module := module;

 if(start_date is not null) then
    f_start_date := fnd_date.canonical_to_date(start_date);
 else
    f_start_date := null;
 end if;

 if(end_date is not null) then
    f_end_date := fnd_date.canonical_to_date(end_date);
 else
    f_end_date := null;
 end if;

 if(only_session is not null) then
    f_session_id := icx_sec.getsessioncookie();
 else
    f_session_id := NULL;
 end if;

 if(only_user is not null and username is not null) then
    begin
        select user_id into f_user_id from fnd_user
        where user_name = upper(username);
    exception
        when no_data_found then
           htp.p('Invalid username entered.  Finding data for current user.');
        f_user_id := fnd_global.user_id;
    end;
 end if;


 /* level 1 gets all levels, so we don't put level in the where clause */
 /* in that case, to avoid confusing the db */
 if ((f_level is not NULL) and (f_level > 1)) then
   b_level := TRUE;
 else
   b_level := FALSE;
 end if;

 if(f_module is not NULL)  then
   b_module := TRUE;
 else
   b_module := FALSE;
 end if;

 if ((f_start_date is not NULL) or (f_end_date is not NULL)) then
   b_dates := TRUE;
 else
   b_dates := FALSE;
 end if;

 if(f_session_id is not NULL)  then
   b_session_id := TRUE;
 else
   b_session_id := FALSE;
 end if;

 if(f_user_id is not NULL)  then
   b_user_id := TRUE;
 else
   b_user_id := FALSE;
 end if;

 l_dynamic_sql :=
  'select MODULE||to_number(rownum), LOG_LEVEL, MESSAGE_TEXT, SESSION_ID, USER_ID, TIMESTAMP '||
   'from fnd_log_messages '||
  'where ';

 b_previous_clause := FALSE;

 if(b_level) then
   if (b_previous_clause) then
     l_dynamic_sql :=  l_dynamic_sql || 'AND ';
   end if;
   l_dynamic_sql := l_dynamic_sql || '(log_level >= :f_level) ';
   b_previous_clause := TRUE;
 end if;

 if(b_module) then
   if (b_previous_clause) then
     l_dynamic_sql :=  l_dynamic_sql || 'AND ';
   end if;
   l_dynamic_sql := l_dynamic_sql ||
                   '(module like :f_module||''%'') ';
   b_previous_clause := TRUE;
 end if;

 if(b_dates) then
   if (b_previous_clause) then
     l_dynamic_sql :=  l_dynamic_sql || 'AND ';
   end if;
   l_dynamic_sql := l_dynamic_sql ||
                '((:f_start_date is NULL) or (timestamp >= :f_start_date)) '||
            'AND ((:f_end_date is NULL)   or (timestamp <= :f_end_date)) ';
   b_previous_clause := TRUE;
 end if;

 if(b_session_id) then
   if (b_previous_clause) then
     l_dynamic_sql :=  l_dynamic_sql || 'AND ';
   end if;
   l_dynamic_sql := l_dynamic_sql ||
                   '(session_id = :f_session_id) ';
   b_previous_clause := TRUE;
 end if;

 if(b_user_id) then
   if (b_previous_clause) then
     l_dynamic_sql :=  l_dynamic_sql || 'AND ';
   end if;
   l_dynamic_sql := l_dynamic_sql ||
                   '(user_id = :f_user_id) ';
   b_previous_clause := TRUE;
 end if;

 /* if none of the arguments are passed, use a dummy where clause */
 if ((not b_level) AND (not b_module) AND (not b_dates) AND
     (not b_session_id) AND (not b_user_id) ) then
   l_dynamic_sql := l_dynamic_sql || '(1=1) ';
   b_previous_clause := TRUE;
 end if;

 l_dynamic_sql := l_dynamic_sql ||
                  ' AND (rownum <= :f_maxrow) '||
                  'order by timestamp, log_sequence';

 /* We account for every possible combination of bind presence, */
/* and only bind in the ones that are actually present.  */
/* This allows the database to use the proper indexes for */
/* the binds that are present instead of just giving up */
/* and doing a full table scan.*/

if (b_level) then
  if (b_module) then
    if (b_dates) then
      if (b_session_id) then
        if (b_user_id) then
          OPEN row_set FOR l_dynamic_sql USING
          f_level, f_module, f_start_date, f_start_date,
          f_end_date, f_end_date, f_session_id, f_user_id,
          f_maxrow;
        else
          OPEN row_set FOR l_dynamic_sql USING
            f_level, f_module, f_start_date, f_start_date,
            f_end_date, f_end_date, f_session_id, f_maxrow;
        end if;
      else
        if (b_user_id) then
          OPEN row_set FOR l_dynamic_sql USING
            f_level, f_module, f_start_date, f_start_date,
            f_end_date, f_end_date, f_user_id, f_maxrow;
        else
          OPEN row_set FOR l_dynamic_sql USING
            f_level, f_module, f_start_date, f_start_date,
            f_end_date, f_end_date, f_maxrow;
        end if;
      end if;
    else
      if (b_session_id) then
        if (b_user_id) then
          OPEN row_set FOR l_dynamic_sql USING
            f_level, f_module, f_session_id, f_user_id, f_maxrow;
        else
          OPEN row_set FOR l_dynamic_sql USING
            f_level, f_module, f_session_id, f_maxrow;
        end if;
      else
        if (b_user_id) then
          OPEN row_set FOR l_dynamic_sql USING
            f_level, f_module, f_user_id, f_maxrow;
        else
          OPEN row_set FOR l_dynamic_sql USING
            f_level, f_module, f_maxrow;
        end if;
      end if;
    end if;
  else
    if (b_dates) then
      if (b_session_id) then
        if (b_user_id) then
          OPEN row_set FOR l_dynamic_sql USING
            f_level, f_start_date, f_start_date, f_end_date, f_end_date,
            f_session_id, f_user_id, f_maxrow;
        else
          OPEN row_set FOR l_dynamic_sql USING
            f_level, f_start_date, f_start_date, f_end_date, f_end_date,
            f_session_id, f_maxrow;
        end if;
      else
        if (b_user_id) then
          OPEN row_set FOR l_dynamic_sql USING
            f_level, f_start_date, f_start_date, f_end_date, f_end_date,
            f_user_id, f_maxrow;
        else
          OPEN row_set FOR l_dynamic_sql USING
            f_level, f_start_date, f_start_date, f_end_date, f_end_date,
            f_maxrow;
        end if;
      end if;
    else
      if (b_session_id) then
        if (b_user_id) then
          OPEN row_set FOR l_dynamic_sql USING
            f_level, f_session_id, f_user_id, f_maxrow;
        else
          OPEN row_set FOR l_dynamic_sql USING
            f_level, f_session_id, f_maxrow;
        end if;
      else
        if (b_user_id) then
          OPEN row_set FOR l_dynamic_sql USING
            f_level, f_user_id, f_maxrow;
        else
          OPEN row_set FOR l_dynamic_sql USING
            f_level, f_maxrow;
        end if;
      end if;
    end if;
  end if;
else
  if (b_module) then
    if (b_dates) then
      if (b_session_id) then
        if (b_user_id) then
          OPEN row_set FOR l_dynamic_sql USING
            f_module, f_start_date, f_start_date, f_end_date, f_end_date,
            f_session_id, f_user_id, f_maxrow;
        else
          OPEN row_set FOR l_dynamic_sql USING
            f_module, f_start_date, f_start_date, f_end_date, f_end_date,
            f_session_id, f_maxrow;
        end if;
      else
        if (b_user_id) then
          OPEN row_set FOR l_dynamic_sql USING
            f_module, f_start_date, f_start_date, f_end_date, f_end_date,
            f_user_id, f_maxrow;
        else
          OPEN row_set FOR l_dynamic_sql USING
            f_module, f_start_date, f_start_date, f_end_date,
            f_end_date, f_maxrow;
        end if;
      end if;
    else
      if (b_session_id) then
        if (b_user_id) then
          OPEN row_set FOR l_dynamic_sql USING
            f_module, f_session_id, f_user_id, f_maxrow;
        else
          OPEN row_set FOR l_dynamic_sql USING
            f_module, f_session_id, f_maxrow;
        end if;
      else
        if (b_user_id) then
          OPEN row_set FOR l_dynamic_sql USING
            f_module, f_user_id, f_maxrow;
        else
          OPEN row_set FOR l_dynamic_sql USING
            f_module, f_maxrow;
        end if;
      end if;
    end if;
  else
    if (b_dates) then
      if (b_session_id) then
        if (b_user_id) then
          OPEN row_set FOR l_dynamic_sql USING
            f_start_date, f_start_date, f_end_date, f_end_date,
            f_session_id, f_user_id, f_maxrow;
        else
          OPEN row_set FOR l_dynamic_sql USING
            f_start_date, f_start_date, f_end_date, f_end_date,
            f_session_id, f_maxrow;
        end if;
      else
        if (b_user_id) then
          OPEN row_set FOR l_dynamic_sql USING
            f_start_date, f_start_date, f_end_date, f_end_date,
            f_user_id, f_maxrow;
        else
          OPEN row_set FOR l_dynamic_sql USING
            f_start_date, f_start_date, f_end_date, f_end_date,
            f_maxrow;
        end if;
      end if;
    else
      if (b_session_id) then
        if (b_user_id) then
          OPEN row_set FOR l_dynamic_sql USING
            f_session_id, f_user_id, f_maxrow;
        else
          OPEN row_set FOR l_dynamic_sql USING
            f_session_id, f_maxrow;
        end if;
      else
        if (b_user_id) then
          OPEN row_set FOR l_dynamic_sql USING
            f_user_id, f_maxrow;
        else
          OPEN row_set FOR l_dynamic_sql USING
            f_maxrow;
        end if;
      end if;
    end if;
  end if;
end if;

 htp.p('<html>');
 htp.p('<title>'||'Logged Messages'||'</title>');

 htp.p('
<H1>Logged Messages</H1>

');
 htp.p('<B>Context</B>');
 if(f_level = 1) then
    htp.p('<BR>Level: Statement');
  elsif(f_level = 2) then
    htp.p('<BR>Level: Procedure');
 elsif(f_level = 3) then
    htp.p('<BR>Level: Event');
 elsif(f_level = 4) then
    htp.p('<BR>Level: Exception');
 elsif(f_level = 5) then
    htp.p('<BR>Level: Error');
 elsif(f_level = 6) then
    htp.p('<BR>Level: Unexpected');
 end if;
 htp.p('<BR>Module: '||nvl(f_module, '(None Specified)'));
 htp.p('<BR>Start Date: '||nvl(fnd_date.date_to_canonical(f_start_date),
                              '(None Specified)'));
 htp.p('<BR>End Date: '||nvl(fnd_date.date_to_canonical(f_end_date),
                              '(None Specified)'));
 htp.p('<BR>Session ID: '||nvl(to_char(f_session_id), '(None Specified)'));
 htp.p('<BR>User ID: '||nvl(to_char(f_user_id), '(None Specified)'));
 htp.p('<BR><P></P>');

 htp.p('<TABLE border="1">');
 htp.p('<TR>');
 htp.p('<TH Align=Left>Time</TH>');
 htp.p('<TH Align=Left>Session</TH>');
 htp.p('<TH Align=Left>User</TH>');
 htp.p('<TH Align=Left>Level</TH>');
 htp.p('<TH Align=Left>Module</TH>');
 htp.p('<TH Align=Left>Message Text</TH>');
 htp.p('</TR>');


 l_index := 0;
 LOOP
   FETCH row_set INTO l_module, l_level, l_msg_text,
                     l_session_id, l_user_id, l_timestamp;
   EXIT WHEN (l_index >= (f_maxrow-1));
   EXIT WHEN row_set%NOTFOUND;
   l_index:=l_index+1;
   if (l_index >= f_startrow) then
     /* This will need to be redone to use the lookups */
     log_level_name := 'Unknown';
     if(l_level = 1) then
        log_level_name := 'Statement';
     elsif(l_level = 2) then
        log_level_name := 'Procedure';
     elsif(l_level = 3) then
        log_level_name := 'Event';
     elsif(l_level = 4) then
        log_level_name := 'Exception';
     elsif(l_level = 5) then
        log_level_name := 'Error';
     elsif(l_level = 6) then
        log_level_name := 'Unexpected';
     end if;

     timestamp_str := fnd_date.date_to_canonical(l_timestamp);

     if(l_user_id is not null) then   /* Simple username cache for speed*/
        if(l_user_id = last_userid) then
           found_username := last_username;
        else
           begin
             select user_name into found_username
               from fnd_user
              where user_id = l_user_id;
           exception when no_data_found then
             found_username := 'Invalid Userid: '||to_char(l_user_id);
           end;
           last_username := found_username;
           last_userid   := l_user_id;
        end if;
     else
        found_username := NULL;
     end if;

     htp.p('<TR>');
     htp.p('<TD ALIGN=LEFT VALIGN=TOP>'||
                    convert_special_chars(timestamp_str)||'</TD>');
     htp.p('<TD ALIGN=LEFT VALIGN=TOP>'||
                    convert_special_chars(l_session_id)||'</TD>');
     htp.p('<TD ALIGN=LEFT VALIGN=TOP>'||
                    convert_special_chars(found_username)||'</TD>');
     htp.p('<TD ALIGN=LEFT VALIGN=TOP>'||
                    convert_special_chars(log_level_name)||'</TD>');
     htp.p('<TD ALIGN=LEFT VALIGN=TOP>'||
                    convert_special_chars(l_module)||'</TD>');
     if ((not( instr(l_msg_text, fnd_global.local_chr(0)) = 0)) or
           substr(l_msg_text,1,1) = '<') then /* If encoded message */
        FND_MESSAGE.SET_ENCODED(l_msg_text);
        htp.p('<TD ALIGN=LEFT VALIGN=TOP>'||
                convert_special_chars(FND_MESSAGE.GET)||'</TD>');
     else
        htp.p('<TD ALIGN=LEFT VALIGN=TOP>'||
                convert_special_chars(l_msg_text)||'</TD>');
     end if;
     htp.p('</TR>');
   end if; /* if (l_index >= f_startrow) */
 END LOOP;
 CLOSE row_set;
 if (l_index > 0) then
   htp.p('<P>Showing messages '||to_char(f_startrow)||
          '..'||to_char(l_index));
 end if;
 if (l_index >= (f_maxrow-1)) then
 /* If this row is further than what will fit on screen, render a */
 /* button for the next screen of data */
   f_startrow := f_startrow + f_numrows;
   htp.p('
<FORM Method="post" Action="FND_LOGVIEW.DISPLAY">
<INPUT Type=submit name="'||f_buttonname||'"
     Value="Next '||to_char(f_numrows)|| ' Messages">
<INPUT type="hidden" name="LEVEL" value="'||LEVEL||'" />
<INPUT type="hidden" name="MODULE" value="'||MODULE||'" />
<INPUT type="hidden" name="START_DATE" value="'||START_DATE||'" />
<INPUT type="hidden" name="END_DATE" value="'||END_DATE||'" />
<INPUT type="hidden" name="ONLY_SESSION" value="'||ONLY_SESSION||'" />
<INPUT type="hidden" name="USERNAME" value="'||USERNAME||'" />
<INPUT type="hidden" name="ONLY_USER" value="'||ONLY_USER||'" />
<INPUT type="hidden" name="STARTROW" value="'||to_char(f_startrow)||'" />
<INPUT type="hidden" name="NUMROWS" value="'||NUMROWS||'" />
<P>
');
 elsif (l_index = 0) then
   htp.p('<TR>');
   htp.p('<TD ALIGN=LEFT VALIGN=TOP>'||'No Log Messages returned.'||'</TD>');
   htp.p('</TR>');
 end if;
htp.p('</TABLE>');

end if;  --icx_sec.validatesession

exception
    when others then
        htp.p(SQLERRM);
end;


procedure internal_check_results(result1 in boolean, result2 in boolean,
                                 result3 in boolean, result4 in boolean) is
begin
      if(result1 = FALSE or
         result2 = FALSE or
         result3 = FALSE or
         result4 = FALSE  ) then
         htp.p(
          '<P></P>'||
          '<B><P>Error- could not save value(s) to the '||
          'profiles option(s): ');
          if(result1 = FALSE) then
             htp.p(' AFLOG_ENABLED');
          end if;
          if(result2 = FALSE) then
             htp.p(' AFLOG_FILENAME');
          end if;
          if(result3 = FALSE) then
             htp.p(' AFLOG_LEVEL');
          end if;
          if(result4 = FALSE) then
             htp.p(' AFLOG_MODULE');
          end if;
          htp.p(
          '.  Check to make sure that profile options are '||
          'in the fnd_profile_options table and if not, use the '||
          'aflogpro.ldt loader file to upload.</B></P>');
      end if;
end;

procedure Update_Prefs(
                ENABLED     in VARCHAR2 default 'off',
                FILENAME    in VARCHAR2,
                LEVEL       in VARCHAR2 default NULL,
                MODULE      in VARCHAR2,
                SESSION_TO_PURGE   in VARCHAR2 default NULL,
                USER_TO_PURGE      in VARCHAR2 default NULL,
                USER_TO_SET        in VARCHAR2 default NULL,
                SAVE               in VARCHAR2 default NULL,
                clearprefs         in VARCHAR2 default NULL,
                clearsessionlog    in VARCHAR2 default NULL,
                clearuserlog       in VARCHAR2 default NULL,
                clear              in VARCHAR2 default NULL,
                sysclear           in VARCHAR2 default NULL,
                syssave            in VARCHAR2 default NULL,
                syspurgeallusers   in VARCHAR2 default NULL,
                syssetuserprefs    in VARCHAR2 default NULL,
                SYSCLEARPREFS      in VARCHAR2 default NULL,
                SYSCLEARSESSIONLOG in VARCHAR2 default NULL,
                SYSCLEARUSERLOG    in VARCHAR2 default NULL,
                USER_ID            in VARCHAR2 default NULL) is

c_error_message varchar2(2000);
err_mesg varchar2(240);
err_num number;
made_changes boolean;
result1 boolean;
result2 boolean;
result3 boolean;
result4 boolean;
purged       boolean;
go_back_to_prefs boolean;
user_id_x number;
the_module varchar2(2000);
the_filename varchar2(2000);
nrows  number;

begin
if icx_sec.validateSession
then
   made_changes     := TRUE;
   purged           := FALSE;
   go_back_to_prefs := TRUE;

   the_module := module;
   /* strip whitespace */

   /* Per bug 1687209, the following line was modified to use fnd_global.local_chr() instead of chr() */
   -- the_module := translate(the_module, chr(9)||chr(10)||chr(13), '   ');
   the_module := translate(the_module, fnd_global.local_chr(9)||fnd_global.local_chr(10)||fnd_global.local_chr(13), '   ');
   the_module := rtrim(ltrim(the_module));

   the_filename := filename;
   /* strip whitespace */

    /* Per bug 1687209, the following line was modified to use fnd_global.local_chr() instead of chr() */
   the_filename := translate(the_filename, fnd_global.local_chr(9)||fnd_global.local_chr(10)||fnd_global.local_chr(13), '   ');
   the_filename := rtrim(ltrim(the_filename));

   htp.p('<html>');

   if(syssave is not null) then /* If user pressed system save button */
      if(ENABLED = 'on') then
         result1 := FND_PROFILE.SAVE('AFLOG_ENABLED', 'Y', 'SITE');
      else
         result1 := FND_PROFILE.SAVE('AFLOG_ENABLED', 'N', 'SITE');
      end if;
      result2 := FND_PROFILE.SAVE('AFLOG_FILENAME', THE_FILENAME, 'SITE');
      result3 := FND_PROFILE.SAVE('AFLOG_LEVEL', LEVEL, 'SITE');
      result4 := FND_PROFILE.SAVE('AFLOG_MODULE', THE_MODULE, 'SITE');
      internal_check_results(result1, result2, result3, result4);
      commit;
      fnd_log_repository.init;
      htp.p('<B>Saved Site Level information.  </B>');
   elsif(save is not null) then /* If user pressed user save  */
      if(user_id is not NULL) then
         user_id_x := user_id;
      else
         user_id_x := FND_GLOBAL.USER_ID;
      end if;
      if(ENABLED = 'on') then
         result1 := FND_PROFILE.SAVE('AFLOG_ENABLED', 'Y', 'USER', user_id_x);
      else
         result1 := FND_PROFILE.SAVE('AFLOG_ENABLED', 'N', 'USER', user_id_x);
      end if;
      result2 := FND_PROFILE.SAVE('AFLOG_FILENAME', THE_FILENAME, 'USER',
                user_id_x);
      result3 := FND_PROFILE.SAVE('AFLOG_LEVEL', LEVEL, 'USER', user_id_x);
      result4 := FND_PROFILE.SAVE('AFLOG_MODULE', THE_MODULE, 'USER',
                user_id_x);
      internal_check_results(result1, result2, result3, result4);
      commit;
      fnd_log_repository.init;
      htp.p('<B>Saved User Level information.  </B>');
   elsif (sysclearprefs is not null) then /* If user pressed sysclearprefs*/
      result1 := FND_PROFILE.SAVE('AFLOG_ENABLED', '', 'SITE');
      result2 := FND_PROFILE.SAVE('AFLOG_FILENAME', '', 'SITE');
      result3 := FND_PROFILE.SAVE('AFLOG_LEVEL', '', 'SITE');
      result4 := FND_PROFILE.SAVE('AFLOG_MODULE', '', 'SITE');
      internal_check_results(result1, result2, result3, result4);
      commit;
      fnd_log_repository.init;
      htp.p('<B>Cleared site level information.</B>');
   elsif (clearprefs is not null) then /* If user pressed clearprefs */
      if(user_id is not NULL) then
         user_id_x := user_id;
      else
         user_id_x := FND_GLOBAL.USER_ID;
      end if;
      result1 := FND_PROFILE.SAVE('AFLOG_ENABLED',  '', 'USER', user_id_x);
      result2 := FND_PROFILE.SAVE('AFLOG_FILENAME', '', 'USER', user_id_x);
      result3 := FND_PROFILE.SAVE('AFLOG_LEVEL',    '', 'USER', user_id_x);
      result4 := FND_PROFILE.SAVE('AFLOG_MODULE',   '', 'USER', user_id_x);
      internal_check_results(result1, result2, result3, result4);
      commit;
      fnd_log_repository.init;
      htp.p('<B>Cleared user level information.</B>');
   elsif (sysclearsessionlog is not null) then /* if user pressed... */
      nrows := FND_LOG_ADMIN.DELETE_BY_SESSION(to_number(SESSION_TO_PURGE));
      commit;
      htp.p('<B>Purged '|| nrows ||' rows of log data for session '
           ||SESSION_TO_PURGE||'.</B>');
      purged := TRUE;
   elsif (clearsessionlog is not null) then /* if user pressed... */
      if(user_id is not NULL) then
         user_id_x := user_id;
      else
         user_id_x := FND_GLOBAL.USER_ID;
      end if;
      nrows := FND_LOG_ADMIN.DELETE_BY_USER_SESSION(user_id_x,
                                   icx_sec.getsessioncookie());
      commit;
      htp.p('<B>Purged '|| nrows || ' rows of log data for this session.</B>');
      purged := TRUE;
   elsif (sysclearuserlog is not null) then /* if user pressed... */
      user_id_x := NULL;
      begin
        select user_id into user_id_x from fnd_user
          where user_name = upper(USER_TO_PURGE);
      exception
        when no_data_found then
           htp.p('Invalid username entered.  Enter a valid username.');
           user_id_x := NULL;
      end;
      if(user_id_x is not NULL) then
         nrows := FND_LOG_ADMIN.DELETE_BY_USER(user_id_x);
         commit;
         htp.p('<B><P>Purged '|| nrows|| ' rows of log data for user '
                ||USER_TO_PURGE||'.</P></B>');
         purged := TRUE;
      else
         made_changes := FALSE;
      end if;
   elsif (syspurgeallusers is not null) then /* if user pressed... */
      nrows := FND_LOG_ADMIN.DELETE_ALL;
      commit;
      htp.p('<B>Purged '|| nrows||
            ' rows of log data for all users, all sessions.</B>');
      purged := TRUE;
   elsif (syssetuserprefs is not null) then /* if user pressed... */
      user_id_x := NULL;
      begin
        select user_id into user_id_x from fnd_user
          where user_name = upper(USER_TO_SET);
      exception
        when no_data_found then
           htp.p('Invalid username entered.  Enter a valid username.');
           user_id_x := NULL;
      end;
      if(user_id_x is not NULL) then
         fnd_logview.preferences_generic('U', user_id_x);
         go_back_to_prefs := FALSE;
      end if;
      made_changes := FALSE;
   elsif (clearuserlog is not null) then /* if user pressed... */
      if(user_id is not NULL) then
         user_id_x := user_id;
      else
         user_id_x := FND_GLOBAL.USER_ID;
      end if;
      nrows := FND_LOG_ADMIN.DELETE_BY_USER(user_id_x);
      commit;
      purged := TRUE;
      htp.p('<B><P>Purged '|| nrows ||
            ' rows of log data for this user.</P></B>');
   else
      htp.p('<B><P>Internal Error- update_prefs call missing args.</P></B>');
      htp.p('<B><P>No data was changed.</P></B>');
   end if;
   if ((made_changes) and (not purged)) then
      htp.p('<P>This change will be in effect upon switching responsibility.</P>');
   end if;

   if((save is not NULL) or (clear is not NULL) or (clearprefs is not NULL) or
      (clearsessionlog is not NULL) or (clearuserlog is not NULL)) then
      if(user_id_x is not NULL) then
         if(user_id is NULL) then
           fnd_logview.preferences_generic('U');
         else
           fnd_logview.preferences_generic('U', user_id);
         end if;
         go_back_to_prefs := FALSE;
      end if;
   else
      if (go_back_to_prefs) then
         fnd_logview.preferences_sysadmin;
      end if;
   end if;

end if;
exception
    when others then
        err_num := SQLCODE;
        c_error_message := SQLERRM;
        select substr(c_error_message, 12, 512) into err_mesg from dual;
        icx_util.add_error(err_mesg);
        icx_admin_sig.error_screen(err_mesg);
end;



procedure test is
   AFLOG_ENABLED   BOOLEAN;
   AFLOG_FILENAME  VARCHAR2(255);
   AFLOG_LEVEL     NUMBER;
   AFLOG_MODULE    VARCHAR2(2000);
   SESSION_ID      NUMBER;
   USER_ID         NUMBER;
begin

if icx_sec.validateSession
then
    htp.p('<html>');

  FND_LOGVIEW.Update_Prefs('on', null, 3,
    'FnD.sRc.FlEx.%, fnd.src.dict.afdict.afdget.start, fnd.src.flex.fdfv.fdfval.dff',
    null, null, null, 'Save', null, null, null, null, null, null,
            null, null, null, null, null, null);

  if (FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y') then
     aflog_enabled := TRUE;
  else
     aflog_enabled := FALSE;
  end if;

  aflog_filename := FND_PROFILE.VALUE('AFLOG_FILENAME');
  aflog_level := to_number(FND_PROFILE.VALUE('AFLOG_LEVEL'));
  aflog_module := FND_PROFILE.VALUE('AFLOG_MODULE');
  user_id := fnd_profile.value('USER_ID');
  session_id :=  icx_sec.getsessioncookie();

  htp.p('<BR> AFLOG_FILENAME='||AFLOG_FILENAME);
  htp.p('<BR> AFLOG_LEVEL='||TO_CHAR(AFLOG_LEVEL));
  htp.p('<BR> AFLOG_MODULE='||AFLOG_MODULE);
  htp.p('<BR> SESSION_ID='||SESSION_ID);
  htp.p('<BR> USER_ID='||USER_ID);

  htp.p('<title>'||'Logging system self-test results:'||'</title>');

  htp.p(' <B><P>Note: This test routine clears the log messages for the ');
  htp.p('  user and resets the user preferences, so be careful! </P></B>');
     if (icx_sec.g_mode_code in ('115J', '115P', 'SLAVE')) then
        htp.p('<body bgcolor= "#CCCCCC">');
    else
        htp.p('<body bgcolor="'||icx_plug_utilities.bgcolor||'">');
    end if;

 htp.p('
<H1>Test logging system</H1>
');

delete from FND_LOG_MESSAGES where user_id = USER_ID;
commit;

  FND_LOG.STRING(3, 'fnd.src.dict.afdict.afdget.start', '1 (first)');
  FND_LOG.STRING(3, 'fnd.src.dict.afdict.afdget.start', '2 ');
  FND_LOG.STRING(3, 'fnd.src.flex.fdfvl.fdfval.kff.start', '3 ');
  FND_LOG.STRING(4, 'fnd.src.flex.fdfvl.fdfval.kff.start', '4 '||
  'Lots of text: (1200 characters or so) '||
  '123456789 123456789 123456789 123456789 123456789 -------- '||
  '123456789 123456789 123456789 123456789 123456789 -------- '||
  '123456789 123456789 123456789 123456789 123456789 -------- '||
  '123456789 123456789 123456789 123456789 123456789 -------- '||
  '123456789 123456789 123456789 123456789 123456789 -------- '||
  '123456789 123456789 123456789 123456789 123456789 -------- '||
  '123456789 123456789 123456789 123456789 123456789 -------- '||
  '123456789 123456789 123456789 123456789 123456789 -------- '||
  '123456789 123456789 123456789 123456789 123456789 -------- '||
  '123456789 123456789 123456789 123456789 123456789 -------- '||
  '123456789 123456789 123456789 123456789 123456789 -------- '||
  '123456789 123456789 123456789 123456789 123456789 -------- '||
  '123456789 123456789 123456789 123456789 123456789 -------- '||
  '123456789 123456789 123456789 123456789 123456789 -------- '||
  '123456789 123456789 123456789 123456789 123456789 -------- '||
  '123456789 123456789 123456789 123456789 123456789 -------- '||
  '123456789 123456789 123456789 123456789 123456789 -------- '||
  '123456789 123456789 123456789 123456789 123456789 -------- '||
  '123456789 123456789 123456789 123456789 123456789 -------- '||
  '123456789 123456789 123456789 123456789 123456789 -------- '||
  '123456789 123456789 123456789 123456789 123456789 -------- '
  );
  FND_LOG.STRING(5, 'fnd.src.dict.afdict.afdget.start', '5 (last)');
  FND_LOG.STRING(3, 'ThisWontLog', 'String that wont log');
  FND_LOG.STRING(1, 'fnd.src.dict.afdict.afdget.start', 'String that wont log 2');

  if FND_LOG.TEST(3, 'fnd.src.flex.fdfvl.fdfval.kff.start') then
     htp.p('correct- fnd.src.flex.fdfvl.fdfval.kff.start found<BR>');
  else
     htp.p('incorrect- fnd.src.flex.fdfvl.fdfval.kff.start not found<BR>');
  end if;


  if FND_LOG.TEST(3, 'fnd.src.something.blah.blah') then
     htp.p('incorrect- fnd.src.something.blah.blah found<BR>');
  else
     htp.p('correct- fnd.src.something.blah.blah not found<BR>');
  end if;


  if FND_LOG.TEST(2, 'fnd.src.flex.fdfvl.fdfval.kff.start') then
     htp.p('incorrect- fnd.src.flex.fdfvl.fdfval.kff.start found at level 2<BR>');
  else
     htp.p('correct- fnd.src.flex.fdfvl.fdfval.kff.start not found at level 2<BR>');
  end if;


  FND_LOGVIEW.Display(3, 'fnd.src.%',
           null, null, null, null, null, 'Find');

end if;  --icx_sec.validatesession

exception
    when others then
        htp.p(SQLERRM);
end;

end fnd_logview;

/
