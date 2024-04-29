--------------------------------------------------------
--  DDL for Package Body WF_MONITOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_MONITOR" as
/* $Header: wfmonb.pls 120.14 2006/09/19 11:34:35 santosin ship $: */

type NameArrayTyp is table of varchar2(240) index by binary_integer;

gClob clob;
gUseClob boolean := false;
gClobInit boolean := false;

l_data varchar2(32000);
NL_CHAR varchar2(1):= '
';

 /*
 ** Set up a table for the list of activity status and there associated
 ** icons.  This is used for the advanced activity filtering capability
 ** as well as the listing of the activity statuses
 */
 /*
 ** Here is the list of status subscripts that are used to reference the table
 ** elements
 */
 G_FIRST_STATUS   PLS_INTEGER := 1;
 G_ACTIVE         PLS_INTEGER := 1;
 G_COMPLETE       PLS_INTEGER := 2;
 G_ERROR          PLS_INTEGER := 3;
 G_SUSPEND        PLS_INTEGER := 4;
 G_LAST_STATUS    PLS_INTEGER := 4;
 /*
 ** Here is the record definition that holds the
 ** list of status_codes and their associated icons
 */
 TYPE wf_status_icons_record IS RECORD (
    status_code         VARCHAR2(8),
    icon_file_name      VARCHAR2(30)
);

 /*
 ** Here is the table that is populated with the appropriate icon information
 */
 TYPE wf_status_icons_table IS TABLE OF wf_status_icons_record
    INDEX BY BINARY_INTEGER;



--
-- Error (PRIVATE)
--   Print a page with an error message.
--   Errors are retrieved from these sources in order:
--     1. wf_core errors
--     2. Oracle errors
--     3. Unspecified INTERNAL error
--
procedure Error
as
begin
   null;
end Error;

procedure appendClobData(newData in varchar2)
is
begin
  if (gUseClob) then
    if NOT (gClobInit) then
      dbms_lob.createTemporary(gClob, true, dbms_lob.session);
      dbms_lob.open(gClob, dbms_lob.lob_readwrite);
      gClobInit := true;
    end if;
    if (newData is not null) then
        dbms_lob.writeAppend(gClob, length(newData), newData);
    end if;
  end if;
end;

--appendData (PRIVATE)
procedure appendData(newData in varchar2)
is
begin
  if (gUseClob) then
   appendClobData(newData|| NL_CHAR);
  else
   if(newData is not null) then
     l_data := l_data || NL_CHAR || newData;
   end if;
  end if;

end;


/*
** Create the status icons table.  This table is
** used to draw to advanced options list and the
** status column in the activities list when youre
** in advanced mode
*/
procedure create_status_icons_table (
x_status_icons_table IN OUT NOCOPY wf_status_icons_table
)
IS

BEGIN

   x_status_icons_table(G_ACTIVE).status_code       := 'ACTIVE';
   x_status_icons_table(G_ACTIVE).icon_file_name    := 'FNDIACTV.gif';

   x_status_icons_table(G_COMPLETE).status_code     := 'COMPLETE';
   x_status_icons_table(G_COMPLETE).icon_file_name  := 'FNDIDONE.gif';

   x_status_icons_table(G_ERROR).status_code        := 'ERROR';
   x_status_icons_table(G_ERROR).icon_file_name     := 'FNDIREDL.gif';

   x_status_icons_table(G_SUSPEND).status_code      := 'SUSPEND';
   x_status_icons_table(G_SUSPEND).icon_file_name   := 'FNDIYLWL.gif';

  EXCEPTION
  WHEN OTHERS THEN
     Wf_Core.Context('wf_monitor',
        'create_status_icons_table');
     Error;

END create_status_icons_table;


-- GetAccessKey
function GetAccessKey(
    x_item_type  varchar2,
    x_item_key   varchar2,
    x_admin_mode varchar2) return varchar2 is

  access_key varchar2(2000);
begin

  if (upper(substr(x_admin_mode, 1, 1)) <> 'Y') then
    access_key := Wf_Engine.GetItemAttrText(x_item_type,
                                            x_item_key, '.MONITOR_KEY');
  else
    access_key := Wf_Engine.GetItemAttrText(x_item_type,
                                            x_item_key, '.ADMIN_KEY');
  end if;

  return access_key;

  exception
    when others then
      raise;
end;

-- AccessKeyCheck
function AccessKeyCheck(
    x_item_type  varchar2,
    x_item_key   varchar2,
    x_admin_mode varchar2,
    x_access_key varchar2) return boolean is

  access_key varchar2(2000);
begin

  if (x_access_key is null) then
    return(false);
  end if;

  -- Check for access key
  begin
    if (GetAccessKey(x_item_type,x_item_key,x_admin_mode) <> x_access_key) then
      return(false);
    end if;

    return(true);

    exception
      when others then
        Error;
        return(false);
  end;
end;

-- Html
--   Sends back a very simple dynamic HTML page to tell the browser what
--   applet to run.
-- IN
--   x_item_type
--   x_item_key
--   x_admin_mode
procedure Html(
    x_item_type  in varchar2,
    x_item_key   in varchar2,
    x_admin_mode in varchar2,
    x_access_key in varchar2,
    x_nls_lang   in varchar2) is

 username varchar2(320);
 rt_activity varchar2(30) := '';
 rt_activity_version pls_integer;
 bg_date date;
 access_key varchar2(30);
 lang_codeset varchar2(50);
 admin_role varchar2(320);
 admin_privilege boolean := FALSE;
 pseudo_login BOOLEAN := FALSE;
 item_type_tl varchar2(80);
 l_ie_plugin_ver varchar2(80);  -- IE version is delimited by ','
 l_archive varchar2(2000);      -- first look for java classes at this archive
 l_java_loc VARCHAR2(80) := '/OA_JAVA/';
 l_code varchar2(80) :=  'oracle.apps.fnd.wf.Monitor';
 l_wf_plugin_download varchar2(80);
 l_wf_plugin_version varchar2(80);
 l_wf_classid varchar2(80);
 l_admin varchar(4) := 'no';
 l_installType varchar2(30);

begin

 -- We will check the installation type to be passed to the monitor applet.
  l_installType := WF_CORE.Translate('WF_INSTALL');

  /*
  ** Hide any session creation issues for now and depend on the
  ** access key to prevent a user from running this function without
  ** logging in.
  */
  begin

     -- set the validate_only flag to true so you don't throw up the login
     -- page and you have a chance to check the access key.
     wfa_sec.validate_only := TRUE;

     wfa_sec.GetSession(username);

     -- Security checking
     admin_role := wf_core.Translate('WF_ADMIN_ROLE');
     if (admin_role <> '*')  then
        if (wf_directory.IsPerformer(username, admin_role)) then
           admin_privilege := true;
           if (upper(substr(x_admin_mode, 1, 1)) = 'Y') then
              l_admin := 'yes';
           end if;
        else
           admin_privilege := false;
        end if;
     else
        -- no security. Eveybody is admin
        admin_privilege := true;
        if (upper(substr(x_admin_mode, 1, 1)) = 'Y') then
           l_admin := 'yes';
        end if;
     end if;
  exception
     when others then
        -- If AccessKeyCheck will return "ERROR" directly if failed
        if (not(AccessKeyCheck(x_item_type, x_item_key, x_admin_mode,
                x_access_key))) then
           htp.p(wf_core.translate('WRONG_ACCESS_KEY'));
           return;
        else
           dbms_session.set_nls('NLS_LANGUAGE', ''''||x_nls_lang||'''');
           pseudo_login := TRUE;
           if (upper(substr(x_admin_mode, 1, 1)) = 'Y') then
              admin_privilege := TRUE;
              l_admin := 'yes';
           else
              admin_privilege := FALSE;
           end if;
        end if;
  end;

  begin
    select root_activity,
           root_activity_version,
           begin_date
    into rt_activity,
         rt_activity_version,
         bg_date
    from wf_items
    where item_type = x_item_type
    and item_key = x_item_key;

  exception
    when NO_DATA_FOUND then
      wf_core.Context('Wf_Monitor', 'HTML', x_item_type, x_item_key);
      wf_core.Token('TYPE', x_item_type);
      wf_core.Token('KEY', x_item_key);
      wf_core.Raise('WFENG_ITEM');
    when OTHERS then
      htp.p(sqlerrm);
      return;
  end;

  lang_codeset := substr(userenv('LANGUAGE'),instr(userenv('LANGUAGE'),'.')+1,
                         length(userenv('LANGUAGE')));

  begin
    select display_name
    into item_type_tl
    from wf_item_types_vl
    where name = x_item_type;

  exception
    when OTHERS then
      htp.p(sqlerrm);
      return;
  end;

  -- Otherwise, we can continue our work here
  -- Generate the html page
  htp.p('<html>');
  if (admin_privilege) then
      htp.p('<head><title> ' || item_type_tl || ', ' || x_item_type
            || ', ' || x_item_key || ' </title>');
  else
     htp.p('<head><title> ' || item_type_tl || ', ' || x_item_key || ' </title>');
  end if;

  wfa_html.create_help_function('wf/links/wfm.htm?WFMON');
  htp.p('</head>');

  -- Open body and draw standard header
  wfa_sec.header(FALSE, 'wf_monitor.find_instance" TARGET="_top',
         wf_core.translate('WFMON_VIEW_DIAGRAM'), TRUE, pseudo_login);

  if (l_installType = 'EMBEDDED') then
    if (instr(UPPER(owa_util.get_cgi_env('HTTP_USER_AGENT')), 'WIN') > 0) then
      l_archive := '/OA_JAVA/oracle/apps/fnd/jar/wfmon.jar, ' ||
                   '/OA_JAVA/oracle/apps/fnd/jar/fndewt.jar, ' ||
                   '/OA_JAVA/oracle/apps/fnd/jar/fndswing.jar, ' ||
                   '/OA_JAVA/oracle/apps/fnd/jar/fndbalishare.jar, ' ||
                   '/OA_JAVA/oracle/apps/fnd/jar/fndctx.jar';

      l_wf_plugin_download := Wf_Core.translate('WF_PLUGIN_DOWNLOAD');
      l_wf_plugin_version := Wf_Core.translate('WF_PLUGIN_VERSION');
      l_wf_classid := Wf_Core.translate('WF_CLASSID');
      l_ie_plugin_ver := replace(Wf_Core.translate('WF_PLUGIN_VERSION'), '.', ',');

      htp.p('<OBJECT classid="clsid:'||l_wf_classid||'" '||
            'WIDTH=100% HEIGHT=90% '||
            'CODEBASE="'||l_wf_plugin_download||
            '#Version='||l_ie_plugin_ver||'">'||
            '<PARAM NAME="jinit_appletcache" VALUE="off">'||
            '<PARAM NAME="CODE"     VALUE="'||l_code||'">'||
            '<PARAM NAME="CODEBASE" VALUE="'||'/OA_JAVA/'||'">'||
            '<PARAM NAME="ARCHIVE"  VALUE="'||l_archive||'">' ||
            '<PARAM NAME="itemtype"  VALUE="'||x_item_type||'">' ||
            '<PARAM NAME="itemkey"  VALUE="'||x_item_key||'">' ||
            '<PARAM NAME="langcodeset"  VALUE="'||lang_codeset||'">' ||
            '<PARAM NAME="accesskey"  VALUE="'||x_access_key||'">' ||
            '<PARAM NAME="admin"  VALUE="'||l_admin||'">' ||
            '<PARAM NAME="type"     VALUE="'||
                        'application/x-jinit-applet;version='||
                        l_wf_plugin_version||'">' ||
            '<PARAM NAME="installType"  VALUE="' || l_installType || '">');
      htp.p('<COMMENT>'||
            '<EMBED type="application/x-jinit-applet;version='||
             l_wf_plugin_version||'"'||
            ' WIDTH="100%" HEIGHT="90%"'||
            ' jinit_appletcache="off"'||
            ' java_CODE="'||l_code||'"'||
            ' java_CODEBASE="'||l_java_loc||'"'||
            ' java_ARCHIVE="'||l_archive||'"');
      htp.p(' itemtype="'||x_item_type||'"' ||
            ' itemkey="'||x_item_key||'"' ||
            ' langcodeset="'||lang_codeset||'"' ||
            ' accesskey="'||x_access_key||'"' ||
            ' admin="'||l_admin||'"' ||
            ' pluginurl="'|| l_wf_plugin_download||'"' ||
            ' installType="' || l_installType || '">'||
            '<NOEMBED></COMMENT></NOEMBED></EMBED></OBJECT>');
    else
      -- Client is not Windows, so we don't want to call Jinitiator.
      htp.p('<applet code=oracle.apps.fnd.wf.Monitor.class codebase="/OA_JAVA"');

      l_archive := '/OA_JAVA/oracle/apps/fnd/jar/wfmon.jar, ' ||
                   '/OA_JAVA/oracle/apps/fnd/jar/fndewt.jar, ' ||
                   '/OA_JAVA/oracle/apps/fnd/jar/fndswing.jar, ' ||
                   '/OA_JAVA/oracle/apps/fnd/jar/fndbalishare.jar, ' ||
                   '/OA_JAVA/oracle/apps/fnd/jar/fndctx.jar';

      htp.p(' archive="' || l_archive || '"');

      htp.p(' width=100% height=90%>');
      htp.p('<param name=itemtype value="' || x_item_type || '">');
      htp.p('<param name=itemkey value="' || x_item_key || '">');
      htp.p('<param name=langcodeset value="' || lang_codeset || '">');
      htp.p('<param name=admin value="' || l_admin || '">');
      htp.p('<param name=accesskey value="' || x_access_key || '">');
      htp.p('<param name=installType value="' || l_installType || '">');
      htp.p('</applet>');

    end if;

  else

    htp.p('<applet code=oracle.apps.fnd.wf.Monitor.class codebase="/OA_JAVA"');

    -- ### We should have this be under fnd/jar after 2.6
    -- htp.p(' archive="/OA_JAVA/oracle/apps/fnd/wf/jar/wfmon.jar, /OA_JAVA/oracle/apps/fnd/wf/jar/fndewt.jar, /OA_JAVA/oracle/apps/fnd/wf/jar/fndswing.jar, /OA_JAVA/oracle/apps/fnd/wf/jar/fndbalishare.jar"');

    -- Path for 9i, OA_JAVA sets to ORACLE_HOME/jlib, where all needed jar file locates
    htp.p(' archive="/OA_JAVA/wfmon.jar, /OA_JAVA/ewt3.jar, /OA_JAVA/ewt3-nls.jar, /OA_JAVA/swingall-1_1_1.jar, /OA_JAVA/share.jar, /OA_JAVA/fndctx.jar"');

    htp.p(' width=100% height=90%>');
    htp.p('<param name=itemtype value="' || x_item_type || '">');
    htp.p('<param name=itemkey value="' || x_item_key || '">');
    htp.p('<param name=langcodeset value="' || lang_codeset || '">');
    htp.p('<param name=admin value="' || l_admin || '">');
    htp.p('<param name=accesskey value="' || x_access_key || '">');
    htp.p('<param name=installType value="' || l_installType || '">');
    htp.p('</applet>');
  end if;

  htp.p('</body>');

exception
   when others then
        Error;
        return;
end html;

-- GetRootInfo (Private Procedure)
--   Gets the root process information about the item key.
-- IN
--  x_item_type
--  x_item_key
--  x_proc_name varchar2,
--  x_proc_type varchar2,
--  x_version   number,
--  x_begin_date varchar2);
procedure GetRootInfo(
    x_item_type varchar2,
    x_item_key  varchar2,
    x_proc_parent varchar2,
    x_proc_name varchar2,
    x_proc_type varchar2,
    x_version   number,
    x_begin_date varchar2) is

  -- To find info about the "root" process, we first figure out
  -- what its parent process is, then perform the same select we
  -- use in the 'GetProcessInfo' procedure.

  cursor rootproc_info is
   select a.item_type,          /* activity definition */
          ait.display_name item_type_disp,
          a.name,
          a1.display_name,
          a1.description,
          a.type,
          l1.meaning  type_disp,
          a.function,
          a.result_type,
          art.display_name result_type_disp,
          a.cost,
          a.rerun,
          a.icon_name,
          a.message,
          to_char(s.due_date)||' '||to_char(s.due_date, 'HH24:MI:SS') due_date,
          a.error_item_type||'/'||a.error_process error_process,
          a.expand_role,
          p.instance_id,        /* activity usage */
          p.instance_label,     /* activity usage */
          '' timeout,
          p.start_end,
          p.default_result,
          wf_core.activity_result(a.result_type, p.default_result)
            activity_usage_result,
          p.icon_geometry,
          p.perform_role,
          p.user_comment,
          s.activity_status,    /* activity status */
          l2.meaning  activity_status_disp,
          s.activity_result_code,
          wf_core.activity_result(a.result_type, s.activity_result_code)
            activity_status_result,
          s.assigned_user,
          wf_directory.getroledisplayname(s.assigned_user) rolename,
          s.notification_id,
          /* date conversion is ok */
          /* BINDVAR_SCAN_IGNORE */
          to_char(s.begin_date) || ' ' || to_char(s.begin_date, 'HH24:MI:SS')
            begin_date,
          /* date conversion is ok */
          /* BINDVAR_SCAN_IGNORE */
          to_char(s.end_date) || ' ' || to_char(s.end_date, 'HH24:MI:SS')
            end_date,
          s.execution_time,
          s.error_name,
          s.error_message,
          s.error_stack,
          n.recipient_role,
          n.status not_status,
          n.due_date not_due_date,
          n.begin_date not_begin_date,
          n.end_date not_end_date
   from   wf_activities pd,
          wf_process_activities p,
          wf_activities a,
          wf_activities_tl a1,
          wf_item_types_vl ait,
          wf_item_activity_statuses s,
          wf_lookups l1,
          wf_lookups l2,
          wf_lookup_types art,
          wf_notifications n
   where  pd.item_type = x_item_type
     and  pd.name = x_proc_parent
     and  pd.begin_date <= to_date(x_begin_date, 'DD/MM/YYYY HH24:MI:SS')
     and (pd.end_date is null or
          pd.end_date > to_date(x_begin_date, 'DD/MM/YYYY HH24:MI:SS'))
     and  p.process_version = pd.version
     and  p.process_name = pd.name
     and  p.process_item_type = pd.item_type
     and  p.activity_name = x_proc_name
     and  a.item_type = p.activity_item_type
     and  a.name = p.activity_name
     and  a.begin_date <= to_date(x_begin_date, 'DD/MM/YYYY HH24:MI:SS')
     and (a.end_date is null or
          a.end_date > to_date(x_begin_date, 'DD/MM/YYYY HH24:MI:SS'))
     and  a1.item_type = a.item_type
     and  a1.name = a.name
     and  a1.version = a.version
     and  a1.language = userenv('LANG')
     and  ait.name = a.item_type
     and  s.item_type (+) = x_item_type
     and  s.item_key (+) = x_item_key
     and  s.process_activity (+) = p.instance_id
     and art.lookup_type(+) = a.result_type
     and l1.lookup_code (+) = a.type
     and l1.lookup_type (+) = 'WFENG_ACTIVITY_TYPE'
     and l2.lookup_code (+) = s.activity_status
     and l2.lookup_type (+) = 'WFENG_STATUS'
     and s.notification_id = n.notification_id(+);

  cursor act_result(act_result_type varchar2) is
    select l.lookup_code,
           l.meaning
    from wf_lookups l
    where l.lookup_type = act_result_type;

  rc rootproc_info%rowtype;

  tokenized_mesg  VARCHAR2(10000);
  tokenized_stack  VARCHAR2(10000);
  tokenized_description  VARCHAR2(10000);
  return_token  VARCHAR2(9) := '@#@';
  l_tab varchar2(30) := wf_core.tab;

begin

  open rootproc_info;

  fetch rootproc_info into rc;

  if (rootproc_info%notfound) then
    appendData('ERROR:' || 'Internal Error in GetRootProcess');
    return;
  end if;

   -- The htp.p proc does not handle returns well, replace them
   -- with the value <RET_TOK>, will resubstitute later on.
--   tokenized_mesg := substr((replace (rc.error_message, wf_core.newline, return_token)), 1, 220);
   tokenized_mesg := replace (rc.error_message, wf_core.newline,
                              return_token);
   tokenized_stack := replace (rc.error_stack, wf_core.newline,
                               return_token);
   tokenized_description := replace (rc.description, wf_core.newline,
                                     return_token);

  -- The format we use is to list all the fields,
  -- delineated by tabs (wf_core.tab).  We place a space after each
  -- field, in case the value returned is null (then the space
  -- acts as a 'placeholder'), making sure to strip those spaces
  -- off when we read this into our javacode.

   appendData('ROOT:' || rc.item_type        || ' ' || l_tab
                 || rc.item_type_disp   || ' ' || l_tab
                 || rc.name     || ' ' || l_tab
                 || rc.display_name     || ' ' || l_tab
                 || tokenized_description       || ' ' || l_tab
                 || rc.type     || ' ' || l_tab
                 || rc.type_disp        || ' ' || l_tab
                 || rc.function || ' ' || l_tab
                 || rc.result_type      || ' ' || l_tab
                 || rc.result_type_disp || ' ' || l_tab
                 || rc.cost     || ' ' || l_tab
                 || rc.rerun    || ' ' || l_tab
                 || rc.icon_name        || ' ' || l_tab
                 || rc.message  || ' ' || l_tab
                 || rc.due_date|| ' ' || l_tab
                 || rc.error_process    || ' ' || l_tab
                 || rc.expand_role      || ' ' || l_tab
                 || rc.instance_id      || ' ' || l_tab
                 || rc.instance_label   || ' ' || l_tab
                 || rc.timeout  || ' ' || l_tab
                 || rc.start_end        || ' ' || l_tab
                 || rc.default_result   || ' ' || l_tab
                 || rc.activity_usage_result    || ' ' || l_tab
                 || rc.icon_geometry    || ' ' || l_tab
                 || rc.perform_role     || ' ' || l_tab
                 || rc.user_comment     || ' ' || l_tab
                 || rc.activity_status  || ' ' || l_tab
                 || rc.activity_status_disp     || ' ' || l_tab
                 || rc.activity_result_code     || ' ' || l_tab
                 || rc.activity_status_result   || ' ' || l_tab
                 || rc.assigned_user    || ' ' || l_tab
                 || rc.rolename || ' ' || l_tab
                 || rc.notification_id  || ' ' || l_tab
                 || rc.begin_date       || ' ' || l_tab
                 || rc.end_date || ' ' || l_tab
                 || rc.execution_time   || ' ' || l_tab
                 || rc.error_name       || ' ' || l_tab
                 || rc.recipient_role   || ' ' || l_tab
                 || rc.not_status       || ' ' || l_tab
                 || rc.not_due_date     || ' ' || l_tab
                 || rc.not_begin_date   || ' ' || l_tab
                 || rc.not_end_date     || ' ' || l_tab
                 || tokenized_mesg      || ' ' || l_tab
                 || tokenized_stack || ' ');

    if (rc.result_type <> '*') then
      for code in act_result(rc.result_type) loop
        appendData('ROOT_ACTIVITY_RESULT:' || code.lookup_code || ' ' || l_tab
                                      || code.meaning || ' ');

      end loop;
    end if;

end GetRootInfo;


-- GetItemInfo (Private Procedure)
--   Gets the item information.
-- IN
--   x_item_type
--   x_item_key
procedure GetItemInfo(
    x_item_type varchar2,
    x_item_key  varchar2,
    x_admin_mode varchar2) is

  cursor item_info is
   select ia.name,
          ia.display_name,
          ia.type,
          ia.format,
          decode(ia.type,
                 'NUMBER', to_char(iav.number_value),
                 'DATE', to_char(iav.date_value, nvl(ia.format,
                                                    'DD-MON-YYYY HH24:MI:SS')),
                  'LOOKUP', wf_core.activity_result(ia.format, iav.text_value),
                 iav.text_value) value
   from wf_item_attributes_vl ia,
        wf_item_attribute_values iav
   where iav.item_type = x_item_type
     and iav.item_key = x_item_key
     and ia.item_type = iav.item_type
     and ia.name = iav.name
     and substr(ia.name, 1, 1) <> '.'
   order by ia.sequence;

  item_rec item_info%rowtype;

  /* 05/14/01 JWSMITH BUG1708024 - CHANGED tokenized_value from */
  /* VARCHAR2(2100) to VARCHAR2(4000) */
  tokenized_value  VARCHAR2(4000);
  return_token  VARCHAR2(9) := '@#@';
  l_tab varchar2(30) := wf_core.tab;

  begin

  open item_info;

  loop
   fetch item_info into item_rec;
   exit when item_info%notfound;

   if ( (upper(substr(x_admin_mode, 1, 1)) = 'Y') or
        (substr(item_rec.name, 1, 1) <> '.') ) then
   tokenized_value := replace (item_rec.value, wf_core.newline,
                               return_token);
   appendData('ITEM_ATTRIBUTE:' || item_rec.name     || ' ' || l_tab
                           || item_rec.display_name     || ' ' || l_tab
                           || item_rec.type     || ' ' || l_tab
                           || item_rec.format   || ' ' || l_tab
                           || tokenized_value   || ' ');
   end if;

  end loop;

end GetItemInfo;

-- GetProcessInfo (Private Procedure)
--   Gets process activity information.
-- IN
--   x_item_type
--   x_item_key
--   x_proc_name
--   x_proc_type
--   x_begin_date
--   x_admin_mode
procedure GetProcessInfo(
    x_item_type varchar2,
    x_item_key varchar2,
    x_proc_name varchar2,
    x_proc_type varchar2,
    x_begin_date varchar2,
    x_admin_mode varchar2) is

  cursor proc_info is
   select a.item_type,          /* activity definition */
          ait.display_name item_type_disp,
          a.name,
          a1.display_name,
          a.version,
          a1.description,
          a.type,
          l1.meaning type_disp,
          a.function,
          a.result_type,
          art.display_name result_type_disp,
          a.cost,
          a.rerun,
          a.icon_name,
          a.message,
          to_char(s.due_date)||' '||to_char(s.due_date, 'HH24:MI:SS') due_date,
          a.error_item_type||'/'||a.error_process error_process,
          a.expand_role,
          p.instance_id,        /* activity usage */
          p.instance_label,     /* activity usage */
          wf_engine_util.activity_timeout(p.instance_id) timeout,
          p.start_end,
          p.default_result,
          wf_core.activity_result(pd.result_type, p.default_result)
            activity_usage_result,
          p.icon_geometry,
          p.perform_role,
          p.user_comment,
          s.activity_status,    /* activity status */
          l2.meaning  activity_status_disp,
          s.activity_result_code,
          wf_core.activity_result(a.result_type, s.activity_result_code)
            activity_status_result,
          s.assigned_user,
          wf_directory.getroledisplayname(s.assigned_user) rolename,
          s.notification_id,
          to_char(s.begin_date) || ' ' || to_char(s.begin_date, 'HH24:MI:SS')
            begin_date,
          to_char(s.end_date) || ' ' || to_char(s.end_date, 'HH24:MI:SS')
            end_date,
          s.execution_time,
          s.error_name,
          s.error_message,
          s.error_stack,
          n.recipient_role,
          n.status not_status,
          to_char(n.due_date) || ' '|| to_char(n.due_date, 'HH24:MI:SS')
            not_due_date,
          to_char(n.begin_date) || ' '|| to_char(n.begin_date, 'HH24:MI:SS')
            not_begin_date,
          to_char(n.end_date) || ' '|| to_char(n.end_date, 'HH24:MI:SS')
            not_end_date
   from   wf_activities pd,
          wf_process_activities p,
          wf_activities a,
          wf_activities_tl a1,
          wf_item_types_vl ait,
          wf_item_activity_statuses s,
          wf_notifications n,
          wf_lookups l1,
          wf_lookups l2,
          wf_lookup_types art
   where  pd.item_type = x_proc_type
     and  pd.name = x_proc_name
     and  pd.begin_date <= to_date(x_begin_date, 'DD/MM/YYYY HH24:MI:SS')
     and (pd.end_date is null or
          pd.end_date > to_date(x_begin_date, 'DD/MM/YYYY HH24:MI:SS'))
     and  p.process_item_type = pd.item_type
     and  p.process_name = pd.name
     and  p.process_version = pd.version
     and  a.item_type = p.activity_item_type
     and  a.name = p.activity_name
     and  a.begin_date <= to_date(x_begin_date, 'DD/MM/YYYY HH24:MI:SS')
     and (a.end_date is null or
          a.end_date > to_date(x_begin_date, 'DD/MM/YYYY HH24:MI:SS'))
     and  a1.item_type = a.item_type
     and  a1.name = a.name
     and  a1.version = a.version
     and  a1.language = userenv('LANG')
     and  ait.name = a.item_type
     and  s.item_type (+) = x_item_type
     and  s.item_key (+) = x_item_key
     and  s.process_activity (+) = p.instance_id
     and art.lookup_type(+) = a.result_type
     and l1.lookup_code (+) = a.type
     and l1.lookup_type (+) = 'WFENG_ACTIVITY_TYPE'
     and l2.lookup_code (+) = s.activity_status
     and l2.lookup_type (+) = 'WFENG_STATUS'
     and s.notification_id = n.notification_id(+);

  cursor act_result(act_result_type varchar2) is
    select l.lookup_code,
           l.meaning
    from wf_lookups l
    where l.lookup_type = act_result_type;

  cursor act_attr(act_item_type varchar2, act_name varchar2,
                  act_version number, act_instance_id number) is
    select aa.name,
           aa.display_name,
           aa.type,
           aa.format,
           decode(aa.type,
                  'NUMBER', to_char(aav.number_value),
                  'DATE', to_char(aav.date_value, nvl(aa.format,
                                                    'DD-MON-YYYY HH24:MI:SS')),
                  'LOOKUP', wf_core.activity_result(aa.format, aav.text_value),
                  aav.text_value) value
    from wf_activity_attributes_vl aa,
         wf_activity_attr_values aav
    where aa.activity_item_type = act_item_type
    and   aa.activity_name = act_name
    and   aa.activity_version = act_version
    and   aav.process_activity_id = act_instance_id
    and   aa.name = aav.name
    and   aa.name not like '#%';

  cursor not_attr(nid pls_integer) is
    select n.notification_id,
           n.recipient_role,
           n.status,
           to_char(n.due_date) || ' ' || to_char(n.due_date, 'HH24:MI:SS')
            due_date,
           to_char(n.begin_date) || ' ' || to_char(n.begin_date, 'HH24:MI:SS')
            begin_date,
           to_char(n.end_date) || ' ' || to_char(n.end_date, 'HH24:MI:SS')
            end_date,
           ma.name,
           ma.display_name,
           ma.type,
           ma.format,
           decode(ma.type,
                  'NUMBER', to_char(na.number_value),
                  'DATE', to_char(na.date_value, nvl(ma.format,
                                                    'DD-MON-YYYY HH24:MI:SS')),
                  'LOOKUP', wf_core.activity_result(ma.format, na.text_value),
                  na.text_value) value
    from wf_notifications n,
         wf_notification_attributes na,
         wf_message_attributes_vl ma
    where n.group_id = nid
    and   n.message_type = ma.message_type
    and   n.message_name = ma.message_name
    and   ma.name = na.name
    and   na.notification_id = n.notification_id;


  prc proc_info%rowtype;

  tokenized_mesg  VARCHAR2(10000);
  tokenized_stack  VARCHAR2(10000);
  /* JWSMITH, BUG1708024M CHANGED tokenized_value VARCHAR2(2100) */
  /* to tokenized_value  VARCHAR2(4000) */
  tokenized_value  VARCHAR2(4000);
  tokenized_description  VARCHAR2(1000);
  return_token  VARCHAR2(9) := '@#@';
  l_tab varchar2(30) := wf_core.tab;

begin
  open proc_info;

  loop
   fetch proc_info into prc;
   exit when proc_info%notfound;

   -- The htp.p proc does not handle returns well, replace them
   -- with the value <RET_TOK>, will resubstitute later on.
--   tokenized_mesg := substr((replace (prc.error_message, wf_core.newline, return_token)), 1, 220);
   tokenized_mesg := replace (prc.error_message, wf_core.newline,
                              return_token);
   tokenized_stack := replace (prc.error_stack, wf_core.newline,
                               return_token);
   tokenized_description := replace (prc.description, wf_core.newline,
                                     return_token);

  -- The format we use is to list all the fields,
  -- delineated by tabs (wf_core.tab).  We place a space after each
  -- field, in case the value returned is null (then the space
  -- acts as a 'placeholder'), making sure to strip those spaces
  -- off when we read this into our javacode.


   appendData('ACTIVITY:' || prc.item_type   || ' ' || l_tab
                     || prc.item_type_disp      || ' ' || l_tab
                     || prc.name        || ' ' || l_tab
                     || prc.display_name        || ' ' || l_tab
                     || tokenized_description   || ' ' || l_tab
                     || prc.type        || ' ' || l_tab
                     || prc.type_disp   || ' ' || l_tab
                     || prc.function    || ' ' || l_tab
                     || prc.result_type || ' ' || l_tab
                     || prc.result_type_disp    || ' ' || l_tab
                     || prc.cost        || ' ' || l_tab
                     || prc.rerun       || ' ' || l_tab
                     || prc.icon_name   || ' ' || l_tab
                     || prc.message     || ' ' || l_tab
                     || prc.due_date|| ' ' || l_tab
                     || prc.error_process       || ' ' || l_tab
                     || prc.expand_role || ' ' || l_tab
                     || prc.instance_id || ' ' || l_tab
                     || prc.instance_label || ' ' || l_tab
                     || prc.timeout || ' ' || l_tab
                     || prc.start_end   || ' ' || l_tab
                     || prc.default_result      || ' ' || l_tab
                     || prc.activity_usage_result       || ' ' || l_tab
                     || prc.icon_geometry       || ' ' || l_tab
                     || prc.perform_role        || ' ' || l_tab
                     || prc.user_comment        || ' ' || l_tab
                     || prc.activity_status     || ' ' || l_tab
                     || prc.activity_status_disp        || ' ' || l_tab
                     || prc.activity_result_code        || ' ' || l_tab
                     || prc.activity_status_result      || ' ' || l_tab
                     || prc.assigned_user       || ' ' || l_tab
                     || prc.rolename    || ' ' || l_tab
                     || prc.notification_id     || ' ' || l_tab
                     || prc.begin_date  || ' ' || l_tab
                     || prc.end_date    || ' ' || l_tab
                     || prc.execution_time      || ' ' || l_tab
                     || prc.error_name  || ' ' || l_tab
                     || prc.recipient_role      || ' ' || l_tab
                     || prc.not_status  || ' ' || l_tab
                     || prc.not_due_date        || ' ' || l_tab
                     || prc.not_begin_date      || ' ' || l_tab
                     || prc.not_end_date        || ' ' || l_tab
                     || tokenized_mesg  || ' ' || l_tab
                     || tokenized_stack || ' ');

    if (prc.result_type <> '*') then
      for code in act_result(prc.result_type) loop
        appendData('ACTIVITY_RESULT:' || code.lookup_code || ' ' || l_tab
                                 || code.meaning || ' ');

      end loop;
    end if;

    -- Fetch activity attributes
    for attr_value in act_attr(prc.item_type, prc.name, prc.version, prc.instance_id) loop
      if ( (upper(substr(x_admin_mode, 1, 1)) = 'Y') or
           (substr(attr_value.name, 1, 1) <> '.') ) then
      tokenized_value := replace (attr_value.value, wf_core.newline,
                                  return_token);

      appendData('ACTIVITY_ATTRIBUTE:' || attr_value.name          || ' ' || l_tab
                                  || attr_value.display_name  || ' ' || l_tab
                                  || attr_value.type          || ' ' || l_tab
                                  || attr_value.format        || ' ' || l_tab
                                  || tokenized_value         || ' ');
      end if;
    end loop;

    if (prc.notification_id is not null) then
      -- Fetch notification attributes
      for not_attr_value in not_attr(prc.notification_id) loop
        if ( (upper(substr(x_admin_mode, 1, 1)) = 'Y') or
           (substr(not_attr_value.name, 1, 1) <> '.') ) then
        tokenized_value := replace (not_attr_value.value,
                                    wf_core.newline, return_token);
        appendData('NOTIFICATION_ATTRIBUTE:'
                         || not_attr_value.notification_id || ' ' || l_tab
                         || not_attr_value.recipient_role   || ' ' || l_tab
                         || not_attr_value.status   || ' ' || l_tab
                         || not_attr_value.due_date   || ' ' || l_tab
                         || not_attr_value.begin_date   || ' ' || l_tab
                         || not_attr_value.end_date   || ' ' || l_tab
                         || not_attr_value.name      || ' ' || l_tab
                         || not_attr_value.display_name || ' ' || l_tab
                         || not_attr_value.type || ' ' || l_tab
                         || not_attr_value.format    || ' ' || l_tab
                         || tokenized_value        || ' ');
        end if;
      end loop;
    end if;


  end loop;

end GetProcessInfo;


-- GetTransitionInfo (Private Procedure)
--   Gets the transition information for each process activity.
-- IN
--   x_item_type
--   x_item_key
--   x_proc_name
--   x_proc_type
--   x_begin_date
procedure GetTransitionInfo(
    x_item_type varchar2,
    x_item_key varchar2,
    x_proc_name varchar2,
    x_proc_type varchar2,
    x_begin_date varchar2) is

cursor trans is
   select p1.icon_geometry from_icon_geometry,  /* from activity */
          p1.instance_id from_instance_id,
          t.result_code,                        /* transition info */
          decode((wf_core.activity_result(a.result_type, t.result_code)),
                 '*', wf_core.translate('DEFAULT'),
                 '#ANY', wf_core.translate('WFMON_ANYRESULT'),
                 wf_core.activity_result(a.result_type, t.result_code))
            activity_result,
          t.arrow_geometry,
          s.activity_status,            /* transition status */
          s.activity_result_code,
          l.lookup_code,
          p2.icon_geometry to_icon_geometry,    /* to activity */
          p2.instance_id to_instance_id
   from   wf_activities pd,
          wf_process_activities p1,
          wf_activities a,
          wf_activity_transitions t,
          wf_item_activity_statuses s,
          wf_lookups l,
          wf_process_activities p2
   where  pd.item_type = x_proc_type
     and  pd.name = x_proc_name
     and  pd.begin_date <= to_date(x_begin_date, 'DD/MM/YYYY HH24:MI:SS')
     and (pd.end_date is null or
          pd.end_date > to_date(x_begin_date, 'DD/MM/YYYY HH24:MI:SS'))
     and  p1.process_item_type = pd.item_type
     and  p1.process_name = pd.name
     and  p1.process_version = pd.version
     and  a.item_type = p1.activity_item_type
     and  a.name = p1.activity_name
     and  a.begin_date <= to_date(x_begin_date, 'DD/MM/YYYY HH24:MI:SS')
     and (a.end_date is null or
          a.end_date > to_date(x_begin_date, 'DD/MM/YYYY HH24:MI:SS'))
     and  t.from_process_activity = p1.instance_id
     and  s.item_type (+) = x_item_type
     and  s.item_key (+) = x_item_key
     and  s.process_activity (+) = p1.instance_id
     and  l.lookup_type = 'WFSTD_BOOLEAN'
     and ((s.activity_status = 'COMPLETE' and
           (t.result_code in (nvl(s.activity_result_code, '#NULL'),
                              wf_engine.eng_trans_any) or
            t.result_code = wf_engine.eng_trans_default and not exists
              (select null from wf_activity_transitions tr
               where  tr.from_process_activity = p1.instance_id
               and  tr.result_code = nvl(s.activity_result_code, '#NULL'))) and
            l.lookup_code = 'T') or
          (not (s.activity_status = 'COMPLETE' and
           (t.result_code in (nvl(s.activity_result_code, '#NULL'),
                              wf_engine.eng_trans_any) or
            t.result_code = wf_engine.eng_trans_default and not exists
               (select null from wf_activity_transitions tr
                where tr.from_process_activity = p1.instance_id
                and  tr.result_code = nvl(s.activity_result_code, '#NULL')))) or
            s.activity_status is null) and
           l.lookup_code = 'F')
     and  p2.instance_id = t.to_process_activity;

  tr trans%rowtype;
  l_tab varchar2(30) := wf_core.tab;

begin
  open trans;
  loop
   fetch trans into tr;
   exit when trans%notfound;

   appendData('TRANSITION:'|| tr.from_icon_geometry  || ' ' || l_tab
                      || tr.from_instance_id    || ' ' || l_tab
                      || tr.result_code || ' ' || l_tab
                      || tr.activity_result     || ' ' || l_tab
                      || tr.arrow_geometry      || ' ' || l_tab
                      || tr.activity_status     || ' ' || l_tab
                      || tr.activity_result_code        || ' ' || l_tab
                      || tr.lookup_code || ' ' || l_tab
                      || tr.to_icon_geometry    || ' ' || l_tab
                      || tr.to_instance_id || ' ');

  end loop;

end GetTransitionInfo;

-- GetResource
--   Called by Monitor.class.
--   Printf's all the role information back to the
--   Monitor applet, which reads them a line at a time, interpreting them.
-- IN
--  x_filter
function GetResource(x_restype varchar2,
                      x_resname varchar2) return varchar2 is

  res_name varchar2(30);
  res_text varchar2(2000);
  res_id number;
  username varchar2(320);
  l_tab varchar2(30);
begin
  l_data := '';
  gUseClob := false;
  --wfa_sec.validate_only := TRUE;
  --wfa_sec.GetSession(username);

  l_tab := wf_core.tab;

  begin

  select NAME, TEXT, ID
  into res_name, res_text, res_id
  from WF_RESOURCES
  where TYPE = x_restype
  and NAME = x_resname
  and NAME <> 'WF_ADMIN_ROLE'
  and LANGUAGE = userenv('LANG');

  exception
  when OTHERS then
    res_name := x_resname;
    res_text := x_resname;
    res_id := 999;
  end;

  appendData('RESOURCE:'|| res_name  || ' ' || l_tab
                   || res_text || ' ' || l_tab
                   || to_char(res_id) || ' ');
  return l_data;
end GetResource;

-- GetResources
--   Called by Monitor.class.
--   Printf's all the role information back to the
--   Monitor applet, which reads them a line at a time, interpreting them.
-- IN
--  x_filter
function GetResources(x_restype varchar2,
                      x_respattern varchar2) return varchar2 is

  cursor matched_resource is
    select NAME, TEXT, ID
    from WF_RESOURCES
    where TYPE = x_restype
    and NAME like x_respattern||'%'
    and NAME <> 'WF_ADMIN_ROLE'
    and LANGUAGE = userenv('LANG')
    order by NAME;

  res_name varchar2(30);
  res_text varchar2(2000);
  res_id number;
  pattern varchar2(30);
  username varchar2(320);
  l_tab varchar2(30);
begin
  gUseClob := false;
  l_data := '';
  --wfa_sec.validate_only := TRUE;
  --wfa_sec.GetSession(username);

  l_tab := wf_core.tab;

  if (x_respattern is null)  then
    pattern := '%';
  end if;

  for r in matched_resource loop
    appendData('RESOURCE:' || r.name || ' ' || l_tab
                  || r.text || ' ' || l_tab
                  || to_char(r.id) || ' ');

  end loop;
  return l_data || NL_CHAR;
end GetResources;

procedure GetRole(p_titles_only varchar2,
                  P_FIND_CRITERIA varchar2) is

    username varchar2(320);

    cursor role(tmpbuf1 varchar2, tmpbuf2 varchar2,
             tmpbuf3 varchar2, tmpbuf4 varchar2) is

    select r.name,
           r.display_name
    from wf_roles r
    where display_name not like '~WF_ADHOC-%'
    and (display_name like tmpbuf1 or
          display_name like tmpbuf2 or
          display_name like tmpbuf3 or
          display_name like tmpbuf4) and
          upper(display_name) like upper(P_FIND_CRITERIA)||'%'
    order by r.display_name;
    first_char varchar2(1) := null;
    second_char varchar2(1) := null;
    tmpbuf1 varchar2(10);
    tmpbuf2 varchar2(10);
    tmpbuf3 varchar2(10);
    tmpbuf4 varchar2(10);
    cnt number;
begin
   -- Authenticate user
 --  wfa_sec.GetSession(username);

  if (P_FIND_CRITERIA is null)  then
    first_char := null;
    second_char := null;
  else
    first_char := substr(P_FIND_CRITERIA, 1, 1);
    second_char := substr(P_FIND_CRITERIA, 2, 1);
  end if;
  tmpbuf1 := upper(first_char)||upper(second_char)||'%';
  tmpbuf2 := upper(first_char)||lower(second_char)||'%';
  tmpbuf3 := lower(first_char)||upper(second_char)||'%';
  tmpbuf4 := lower(first_char)||lower(second_char)||'%';
  select count(*) into cnt
  from wf_roles
  where display_name not like '~WF_ADHOC-%'
  and (display_name like tmpbuf1 or
       display_name like tmpbuf2 or
       display_name like tmpbuf3 or
       display_name like tmpbuf4) and
       upper(display_name) like upper(P_FIND_CRITERIA) ||'%';
  appendData(wf_core.translate('WFMON_REASSIGN_TO'));
  appendData('2');
  appendData(to_char(cnt));
  appendData(wf_core.translate('WFITD_ATTR_TYPE_ROLE'));
  appendData('50');
  appendData(wf_core.translate('WFITD_INTERNAL_NAME'));
  appendData('50');
  if (upper(substr(p_titles_only, 1, 1)) <> 'Y') then
  for r in role(tmpbuf1, tmpbuf2, tmpbuf3, tmpbuf4) loop
    appendData(r.display_name);
    appendData(r.name);
  end loop;
  end if;
end GetRole;

-- GetProcess
--   Called by Monitor.class.
--   Printf's all the information about the workflow objects back to the
--   Monitor applet, which reads them a line at a time, interpreting them.
function GetProcess(
    x_item_type varchar2,
    x_item_key  varchar2,
    x_admin_mode varchar2,
    x_access_key varchar2,
    x_proc_name varchar2,
    x_proc_type varchar2) return clob is

  cursor role is
    select r.name,
           r.display_name
    from wf_roles r
    order by r.display_name;


 username varchar2(320);
 rt_activity varchar2(30);
 rt_activity_version pls_integer;
 bg_date date;
 ed_date date;
 ukey varchar2(240);
 owner varchar2(320);
 parent_activity varchar2(30);
 l_tab varchar2(30);
begin
  l_tab := wf_core.tab;
  l_data := '';
  gUseClob := false; --init for error msgs only

  /*
  ** Hide any session creation issues for now and depend on the
  ** access key to prevent a user from running this function without
  ** logging in.
  */
  /*
begin
     -- set the validate_only flag to true so you don't throw up the login
     -- page and you have a chance to check the access key.
     wfa_sec.validate_only := TRUE;

     wfa_sec.GetSession(username);

     exception
       when others then
           -- If AccessKeyCheck will return "ERROR" directly if failed
           if (not(AccessKeyCheck(x_item_type, x_item_key, x_admin_mode,
                x_access_key))) then

               appendData(wf_core.translate('WRONG_ACCESS_KEY'));

               return l_data;

           end if;
  end;
*/
  begin
    select root_activity,
           root_activity_version,
           begin_date,
           end_date,
           user_key,
           owner_role
    into rt_activity,
         rt_activity_version,
         bg_date,
         ed_date,
         ukey,
         owner
    from wf_items
    where item_type = x_item_type
    and item_key = x_item_key;

    exception
      when NO_DATA_FOUND then
        appendData(wf_core.translate('WRONG_TYPE_OR_KEY'));
        return l_data;
      when OTHERS then
        appendData(wf_core.translate('ERROR'));
        return l_data;
  end;
  /* Set to useClob here */
  gUseClob := true;
  -- Otherwise, we can continue our work here
  appendData('ITEM:' || owner|| ' ' || l_tab
                || ukey || ' ' || l_tab
                || bg_date || ' ' || l_tab
                || ed_date || ' ');
  if (x_proc_name is null) then

    GetRootInfo(x_item_type, x_item_key,
                  'ROOT', rt_activity, x_item_type,
                  rt_activity_version,
                  to_char(bg_date, 'DD/MM/YYYY HH24:MI:SS'));

    GetItemInfo (x_item_type, x_item_key, x_admin_mode);

    GetProcessInfo(x_item_type, x_item_key,
                     rt_activity, x_item_type,
                     to_char(bg_date, 'DD/MM/YYYY HH24:MI:SS'), x_admin_mode);

    GetTransitionInfo(x_item_type, x_item_key,
                        rt_activity, x_item_type,
                        to_char(bg_date, 'DD/MM/YYYY HH24:MI:SS'));

  else

    GetProcessInfo(x_item_type, x_item_key,
                     x_proc_name, x_proc_type,
                     to_char(bg_date, 'DD/MM/YYYY HH24:MI:SS'), x_admin_mode);

    GetTransitionInfo(x_item_type, x_item_key,
                        x_proc_name, x_proc_type,
                        to_char(bg_date, 'DD/MM/YYYY HH24:MI:SS'));

  end if;
  --resetting global variables here.This api is currently the only point of use.
  gUseClob := false;
  gClobInit := false;
  return gClob;

end GetProcess;

function GetUrl (x_agent in varchar2,
                 x_item_type in varchar2,
                 x_item_key in varchar2,
                 x_admin_mode in varchar2) return varchar2 is

begin

  return (GetDiagramUrl(x_agent,x_item_type, x_item_key, x_admin_mode));
  exception
    when others then
     raise;
end;


function GetDiagramURL (x_agent in varchar2,
                        x_item_type in varchar2,
                        x_item_key in varchar2,
                        x_admin_mode in varchar2) return varchar2 is

  l_url varchar2(4000);
  l_adminMode varchar2(2048);
  l_accessKey varchar2(2048);
  l_regionToDisplay varchar2(30);
  l_itemType varchar2(2000);
  l_itemKey varchar2(2000);
  l_installType varchar2(30);

  access_key varchar2(2000);
  l_item_key varchar2(30);
  xnls_lang varchar2(60);

begin
  l_regionToDisplay := 'WF_G_MONITOR_DIAGRAM_PAGE';
  -- vbhatia - 06/09/03
  -- check to see if the current context is APPS context or Standalone context
  -- if APPS, then redirect to OA Fwk page
  -- if Standalone, then redirect to a PL/SQL Web toolkit page (as was originally done)
  l_installType := WF_CORE.Translate('WF_INSTALL');

  if l_installType = 'EMBEDDED' then    -- APPS context

    --
    -- Encrypt all parameters.
    --
    l_accessKey := getAccessKey(x_item_type, x_item_key, x_admin_mode);
    l_accessKey := icx_call.encrypt(l_accessKey);
    l_adminMode := icx_call.encrypt(x_admin_mode);
    l_itemType := icx_call.encrypt(x_item_type);
    l_itemKey := icx_call.encrypt(x_item_key);
    getFwkMonitorUrl(l_regionToDisplay, l_accessKey, l_adminMode, l_itemType, l_itemKey, l_url);
    return l_url;

  else          -- Standalone context

    access_key := GetAccessKey(x_item_type, x_item_key, x_admin_mode);

    select replace(nls_language,' ','%20')
    into xnls_lang
    from wf_languages
    where code=userenv('LANG');

    return(x_agent||'/wf_monitor.html'||
           '?'||'x_item_type=' ||wfa_html.conv_special_url_chars(x_item_type)||
           '&'||'x_item_key='  ||wfa_html.conv_special_url_chars(x_item_key)||
           '&'||'x_admin_mode='||x_admin_mode||
           '&'||'x_access_key='||access_key||
           '&'||'x_nls_lang='||xnls_lang);

  end if;

  exception
    when others then
     raise;
end;

-- vbhatia - 06/09/03
-- Procedure to build a URL to access Status Monitor History, Diagram or
-- Responses pages.
PROCEDURE buildMonitorUrl (akRegionCode in varchar2 default null,
                           wa in varchar2 default null,
                           wm in varchar2 default null,
                           itemType in varchar2 default null,
                           itemKey in varchar2 default null,
                           ntfId in varchar2 default null) is

  l_session_id number;
  l_validate boolean;
  l_url varchar2(4000);
  l_dbc varchar2(240);
  l_language_code varchar2(30);
  l_transaction_id number;
  l_accessKey varchar2(2000);
  l_adminMode varchar2(2000);
  l_itemType varchar2(2000);
  l_itemKey varchar2(2000);
  username varchar2(320);

begin

  -- set the validate_only flag to true so you don't hold up the page
  wfa_sec.validate_only := TRUE;
  wfa_sec.GetSession(username);

  -- Converting to use the new FND_SESSION_MANAGEMENT model
  if (FND_SESSION_MANAGEMENT.g_transaction_id = -1) then
    l_transaction_id := FND_SESSION_MANAGEMENT.NewTransactionId;
  else
    l_transaction_id := FND_SESSION_MANAGEMENT.g_transaction_id;
  end if;

  -- Get the framework agent and make sure it always has a trailing slash.

  l_url := fnd_web_config.trail_slash(fnd_profile.value('APPS_FRAMEWORK_AGENT'));

  fnd_profile.get(name => 'APPS_DATABASE_ID',
                   val => l_dbc);

  if l_dbc is null
  then
    l_dbc := FND_WEB_CONFIG.DATABASE_ID;
  end if;

  --
  -- Encode all the parameters
  --

  l_accessKey := wfa_html.conv_special_url_chars(wa);

  l_adminMode := wfa_html.conv_special_url_chars(wm);

  l_itemType := wfa_html.conv_special_url_chars(itemType);

  l_itemKey := wfa_html.conv_special_url_chars(itemKey);

  l_url := l_url||'OA_HTML/';

  l_url := l_url||'OA.jsp?'||'akRegionCode='||akRegionCode||
                  '&'||'akRegionApplicationId=0'||
                  '&'||'dbc='||l_dbc||
                  '&'||'transactionid='||l_transaction_id||
                  '&'||'wa='||l_accessKey||
                  '&'||'wm='||l_adminMode||
                  '&'||'itemType='||l_itemType||
                  '&'||'itemKey='||l_itemKey||
                  '&'||'addBreadCrumb=Y'||
                  '&'||'retainAM=Y';

owa_util.redirect_url(l_url);

end buildMonitorUrl;

/** Returns Monitor URL constructed in the RF.jsp format. For invalid function the
 * URL returned will be NULL
 */
PROCEDURE getFWKMonitorUrl(akRegionCode in varchar2 default null,
                           wa in varchar2 default null,
                           wm in varchar2 default null,
                           itemType in varchar2 default null,
                           itemKey in varchar2 default null,
                           l_lurl out nocopy varchar2) is

  l_function varchar2(4000);
  l_params varchar2(4000);
  functionId number;

begin

  l_function := getFunctionForRegion(akRegionCode);
  if(l_function is not null) then
    functionId := fnd_function.get_function_id (l_function);
    l_params := 'itemType='||itemType||
              '&'||'itemKey='||itemkey||
              '&'||'wa='||wa||
              '&'||'wm='||wm||
              '&'||'fExt=X';
    l_lurl := fnd_run_function.get_run_function_url( p_function_id => functionId,
                                p_resp_appl_id => -1,
                                p_resp_id => -1,
                                p_security_group_id => null,
                                p_parameters => l_params,
                                p_encryptParameters => false);

  end if;
end getFWKMonitorUrl;

--Get the function name for a given region name
function getFunctionForRegion(akRegionCode in varchar2)
         return varchar2 is
  l_function varchar2(4000);
begin

  if(akRegionCode = 'WF_G_MONITOR_DIAGRAM_PAGE') then
         l_function := 'WF_G_DIAGRAM';
  elsif(akRegionCode = 'WF_G_MONITOR_HISTORY_PAGE') then
         l_function := 'WF_G_ACTIVITIES';
  elsif(akRegionCode = 'WF_G_MONITOR_RESPONSES_PAGE') then
         l_function := 'WF_G_RESPONSES';
  elsif(akRegionCode = 'WF_G_MON_WORKFLOW_DETAILS_PAGE') then
         l_function := 'WF_G_WORKFLOW_DETAILS';
  end if;
  return l_function;

end getFunctionForRegion;


/**Gets old Status monitor URL's of the form
   host:port/pls/<sid>/wf_monitor.buildMonitorUrl?<params>
   and converts it to a URL of the form RF.jsp so that the corresponding
   Status monitor function(digram, activities etc) gets directly accessed
   without the using PL/SQL catridge.Returns following error code
   0 - Success
   1 - failure
  */
PROCEDURE updateToFWKMonitorUrl(oldUrl in varchar2,
                               newUrl out nocopy varchar2,
                               errorCode out nocopy pls_integer) is
 region varchar2(4000);
 wm     varchar2(4000);
 wa     varchar2(4000);
 itemType varchar2(4000);
 itemKey varchar2(4000);
 l_oldUrl varchar2(4000);
begin
   errorCode := 1;
   l_oldUrl := oldUrl;
   parseUrlForParams('akRegionCode', l_oldUrl, region);
   parseUrlForParams('wa', l_oldUrl, wa);
   parseUrlForParams('wm', l_oldUrl, wm);
   parseUrlForParams('itemType', l_oldUrl, itemType);
   parseUrlForParams('itemKey', l_oldUrl, itemKey);
   getFwkMonitorUrl(region, wa, wm, itemType, itemKey, newUrl);
   if (newUrl is not null) then
      errorCode := 0; --success
   end if;
end updateToFWKMonitorUrl;

PROCEDURE parseUrlForParams(paramName in varchar2,
                            l_oldUrl in varchar2,
                            paramValue out nocopy varchar2) is
startPos Number;
endPos Number;
keyPos Number;
begin
  keyPos := instr(l_oldUrl,paramName);
  if keyPos = 0 then
     paramValue := '';
     return;
  else
     startPos := instr(l_oldUrl,'=',keyPos)+1;
     endPos := instr(l_oldUrl,'&',startPos);
     if endPos = 0 then     -- No '&', use remaining string as value
         endPos := length(l_oldUrl)+1;
     end if;
     paramValue := substr(l_oldUrl,startPos,endPos-startPos);
  end if;
end parseUrlForParams;

function GetAdvancedEnvelopeURL (
  x_agent               IN VARCHAR2,
  x_item_type           IN VARCHAR2,
  x_item_key            IN VARCHAR2,
  x_admin_mode          IN VARCHAR2,
  x_options             IN VARCHAR2
) return varchar2 is

  l_url varchar2(4000);
  l_adminMode varchar2(2048);
  l_accessKey varchar2(2048);
  l_regionToDisplay varchar2(30) := 'WF_G_MONITOR_HISTORY_PAGE';
  l_itemType varchar2(2000);
  l_itemKey varchar2(2000);
  l_installType varchar2(30);

  access_key      varchar2(2000);
  xnls_lang       varchar2(60);

begin

  -- vbhatia - 06/09/03
  -- check to see if the current context is APPS context or Standalone context
  -- if APPS, then redirect to OA Fwk page
  -- if Standalone, then redirect to a PL/SQL Web toolkit page (as was originally done)

  l_installType := WF_CORE.Translate('WF_INSTALL');

  if l_installType = 'EMBEDDED' then    -- APPS context

    --
    -- Encrypt all parameters.
    --
    l_accessKey := getAccessKey(x_item_type, x_item_key, x_admin_mode);
    l_accessKey := icx_call.encrypt(l_accessKey);
    l_adminMode := icx_call.encrypt(x_admin_mode);
    l_itemType := icx_call.encrypt(x_item_type);
    l_itemKey := icx_call.encrypt(x_item_key);
    getFwkMonitorUrl(l_regionToDisplay, l_accessKey, l_adminMode, l_itemType, l_itemKey, l_url);

    return l_url;

  else     -- Standalone context

    access_key := GetAccessKey(x_item_type, x_item_key, x_admin_mode);

    select replace(nls_language,' ','%20')
    into xnls_lang
    from wf_languages
    where code=userenv('LANG');

    --
    if x_options is not null then

      return(x_agent||'/wf_monitor.envelope'||
            '?'||'x_item_type=' ||wfa_html.conv_special_url_chars(x_item_type)||
            '&'||'x_item_key='  ||wfa_html.conv_special_url_chars(x_item_key)||
            '&'||'x_admin_mode='||x_admin_mode||
            '&'||'x_access_key='||access_key||
            '&'||'x_advanced=TRUE'||
            '&'||'x_active=ACTIVE'||
            '&'||'x_complete=COMPLETE&x_error=ERROR'||
            '&'||'x_suspend=SUSPEND&x_proc_func=Y'||
            '&'||'x_note_resp=Y&x_note_noresp=Y'||
            '&'||'x_func_std=Y&x_event=Y&x_sort_column=STARTDATE'||
            '&'||'x_sort_order=ASC'||
            '&'||'x_nls_lang='||xnls_lang);

    else

      return(x_agent||'/wf_monitor.envelope'||
            '?'||'x_item_type=' ||wfa_html.conv_special_url_chars(x_item_type)||
            '&'||'x_item_key='  ||wfa_html.conv_special_url_chars(x_item_key)||
            '&'||'x_admin_mode='||x_admin_mode||
            '&'||'x_access_key='||access_key||
            '&'||'x_advanced=TRUE'||
            '&'||'x_nls_lang='||xnls_lang);

    end if;

  end if;

  exception
    when others then
     raise;
end;



function GetEnvelopeURL (
  x_agent               IN VARCHAR2,
  x_item_type           IN VARCHAR2,
  x_item_key            IN VARCHAR2,
  x_admin_mode          IN VARCHAR2
) return varchar2 is

  l_url varchar2(4000);
  l_adminMode varchar2(2048);
  l_accessKey varchar2(2048);
  l_regionToDisplay varchar2(30) := 'WF_G_MONITOR_RESPONSES_PAGE';
  l_itemType varchar2(2000);
  l_itemKey varchar2(2000);
  l_installType varchar2(30);

  access_key      varchar2(2000);
  xnls_lang       varchar2(60);

begin

  -- vbhatia - 06/09/03
  -- check to see if the current context is APPS context or Standalone context
  -- if APPS, then redirect to OA Fwk page
  -- if Standalone, then redirect to a PL/SQL Web toolkit page (as was originally done)

  l_installType := WF_CORE.Translate('WF_INSTALL');

  if l_installType = 'EMBEDDED' then    -- APPS context

      --
    -- Encrypt all parameters.
    --
    l_accessKey := getAccessKey(x_item_type, x_item_key, x_admin_mode);
    l_accessKey := icx_call.encrypt(l_accessKey);
    l_adminMode := icx_call.encrypt(x_admin_mode);
    l_itemType := icx_call.encrypt(x_item_type);
    l_itemKey := icx_call.encrypt(x_item_key);
    getFwkMonitorUrl(l_regionToDisplay, l_accessKey, l_adminMode, l_itemType, l_itemKey, l_url);
    return l_url;

  else           -- Standalone context

    access_key := GetAccessKey(x_item_type, x_item_key, x_admin_mode);

    select replace(nls_language,' ','%20')
    into xnls_lang
    from wf_languages
    where code=userenv('LANG');

    return(x_agent||'/wf_monitor.envelope'||
           '?'||'x_item_type=' ||wfa_html.conv_special_url_chars(x_item_type)||
           '&'||'x_item_key='  ||wfa_html.conv_special_url_chars(x_item_key)||
           '&'||'x_admin_mode='||x_admin_mode||
           '&'||'x_access_key='||access_key||
           '&'||'x_advanced=FALSE'||
           '&'||'x_nls_lang='||xnls_lang);

  end if;

  exception
    when others then
     raise;
end;


procedure EngApi (api_name in varchar2,
                  x_item_type in varchar2,
                  x_item_key in varchar2,
                  x_access_key in varchar2,
                  third_arg in varchar2,
                  forth_arg in varchar2,
                  fifth_arg in varchar2) is

  username varchar2(320);

begin

  -- Security check
  if (x_access_key <> GetAccessKey(x_item_type, x_item_key, 'Y')) then
    htp.p('ENG_API_ACCESS_DENIED:');
  end if;

  begin
    -- Validate the session that comes from monitor
    wfa_sec.validate_only := TRUE;
    wfa_sec.GetSession(username);
  exception
    when OTHERS then
      null;      -- ignore any error
  end;


  if (api_name = 'AbortProcess') then
    Wf_Engine.AbortProcess(x_item_type, x_item_key, third_arg, forth_arg);

  elsif (api_name = 'SuspendProcess') then
    Wf_Engine.SuspendProcess(x_item_type, x_item_key, third_arg);

  elsif (api_name = 'ResumeProcess') then
    Wf_Engine.ResumeProcess(x_item_type, x_item_key, third_arg);

  elsif (api_name = 'AssignActivity') then
    Wf_Engine.AssignActivity(x_item_type, x_item_key, third_arg, forth_arg);

  elsif (api_name = 'HandleError') then
    Wf_Engine.HandleError(x_item_type, x_item_key, third_arg, forth_arg,
                          fifth_arg);

  elsif (api_name = 'SetItemAttrText') then
    Wf_Engine.SetItemAttrText(x_item_type, x_item_key, third_arg, forth_arg);
  end if;

  htp.p('ENG_API_SUCC:');
  return;

exception
   when others then
        Error;
        return;
end;


 /**********************************************************************
  *
  *  Find window procedures
  *
  **********************************************************************/

-- Show
--   This is to be called by forms when people want to link to workflow.
--   If nothing to be passed, this will take you to Find_Instance().
--   Otherwise, this will take you to the envelope() page.
procedure Show (
  item_type              VARCHAR2,
  item_key               VARCHAR2,
  admin_mode             VARCHAR2,
  access_key             VARCHAR2) is
begin
  if (item_type is null and item_key is null) then
    wf_monitor.Find_Instance();
  else
    wf_monitor.Envelope(item_type, item_key, admin_mode, access_key);
  end if;
end ;


--
-- Find_Instance
--   Query page to find processes
--
-- MODIFICATION LOG:
-- 06-JUN-2001 JWSMITH BUG 1819232 - added alt attrib for the following gifs
--             FNDIACTV,FNDIDONE,FNDIYLWL, FNDIREDL for ADA ENHANCEMENT
procedure Find_Instance
is
 begin
       null;
 end;


-- createenvsortlink (PRIVATE)
--   Print a single column header in Envelope page
/*
** x_cur_sort_column     = Current column that the activity list is sorted by
** x_cur_sort_order      = Is the list currently sorted ASC or DESC
** x_sort_column         = What is the current column header to display
** x_advanced            = Are you in advanced mode
** x_column_title        = What is the display text for the column header
** x_column_title_not_adv= What is the display text for the column header
**                         when youre not in advanced mode (Done vs Status)
** x_show_when_not_adv   = Do you display this column if youre not in
**                         advanced mode (Parent_activity)
** x_standard_url        = The fixed set of parameters for the envelope
**                         routine
*/
procedure createenvsortlink (

x_cur_sort_column        VARCHAR2,
x_cur_sort_order         VARCHAR2,
x_sort_column            VARCHAR2,
x_advanced               VARCHAR2,
x_column_title           VARCHAR2,
x_column_title_not_adv   VARCHAR2,
x_show_when_not_adv      BOOLEAN,
x_standard_url           VARCHAR2) IS

BEGIN

   /*
   ** If youre supposed to show this column when youre in advanced mode
   ** or youre only supposed to show it in advanced mode and you're in
   ** advanced mode then determine how to draw the column title.
   */
   IF (x_show_when_not_adv = TRUE OR
        (x_show_when_not_adv = FALSE AND
           x_advanced IN  ('FIRST', 'TRUE'))) THEN

      /*
      ** If the current column to display matches the current sort column
      ** and the current order is ascending and youre in advanced mode
      ** then show the column header as a soft link with 'Header*'to resort
      ** the list DESC
      */
      IF (NVL(x_cur_sort_column, 'UNSET') = x_sort_column  AND
           NVL(x_cur_sort_order, 'ASC') = 'ASC' AND
                x_advanced IN ('FIRST', 'TRUE')) THEN

             htp.tableHeader(
                cvalue=>'<A HREF="'||x_standard_url||
                     '&x_sort_column='||x_sort_column||
                     '&x_sort_order='||'DESC'||
                     '" onMouseOver="window.status='||''''||
      /* Token and text controlled by us */
      /* BINDVAR_SCAN_IGNORE[2] */
                     wfa_html.replace_onMouseOver_quotes(wf_core.translate('WFMON_REVERSE_SORT_PROMPT'))||' '||
                     x_column_title||''''||
                     '; return true"'||
                     ' TARGET="_top">'||
                     '<font color=#FFFFFF>'||x_column_title||'*'||'</font>'||
                     '</A>',
                calign=>'Center');

      /*
      ** If the current column to display matches the current sort column
      ** and the current order is descending and youre in advanced mode
      ** then show the column header as a soft link with '*Header'to resort
      ** the list DESC
      */
      ELSIF (NVL(x_cur_sort_column, 'UNSET') = x_sort_column  AND
                NVL(x_cur_sort_order, 'ASC') = 'DESC'  AND
                   x_advanced IN ('FIRST', 'TRUE')) THEN

             htp.tableHeader(
                cvalue=>'<A HREF="'||x_standard_url||
                     '&x_sort_column='||x_sort_column||
                     '&x_sort_order='||'ASC'||
                     '" onMouseOver="window.status='||''''||
                     wfa_html.replace_onMouseOver_quotes(wf_core.translate('WFMON_REVERSE_SORT_PROMPT'))||' '||
                     x_column_title||''''||
                     '; return true"'||
                     ' TARGET="_top">'||
                     '<font color=#FFFFFF>'||'*'|| x_column_title||'</font>'||
                     '</A>',
                calign=>'Center');

      /*
      ** If the current column to display does not match the current sort column
      ** and youre in advanced mode then show the column header as a soft link
      ** with 'Header'to sort the list ASC by this column
      */
      ELSIF (NVL(x_cur_sort_column, 'UNSET') <> x_sort_column AND
                 x_advanced IN ('FIRST', 'TRUE')) THEN

          htp.tableHeader(
             cvalue=>'<A HREF="'||x_standard_url||
                  '&x_sort_column='||x_sort_column||
                  '" onMouseOver="window.status='||''''||
                  wfa_html.replace_onMouseOver_quotes(wf_core.translate('WFMON_SORT_PROMPT'))||' '||
                  x_column_title||''''||
                  '; return true"'||
                  ' TARGET="_top">'||
                  '<font color=#FFFFFF>'||x_column_title||'</font>'||
                  '</A>',
             calign=>'Center');

      /*
      ** If this is not an applicable sort column or your not
      ** in advanced mode then just show the header normally.
      */
      ELSE

         htp.tableHeader('<font color=#FFFFFF>'||x_column_title_not_adv||'</font>', 'Center');

      END IF;

   END IF;

exception
  when others then
    Wf_Core.Context(
          'Wf_Monitor',
          'createenvsortlink',
          x_cur_sort_column        ,
          x_cur_sort_order         ,
          x_sort_column           );

    raise;

END createenvsortlink;

--
-- ShowEnvColumnHeaders (PRIVATE)
--   Print column header in Envelope page
--
procedure showEnvColumnHeaders (
  x_item_type              varchar2,
  x_item_key               varchar2,
  x_admin_mode             varchar2,
  x_access_key             varchar2,
  x_advanced               varchar2,
  x_active                 varchar2,
  x_complete               varchar2,
  x_error                  varchar2,
  x_suspend                varchar2,
  x_proc_func              varchar2,
  x_note_resp              varchar2,
  x_note_noresp            varchar2,
  x_func_std               varchar2,
  x_event                  varchar2,
  x_sort_column            varchar2,
  x_sort_order             varchar2,
  x_nls_lang               varchar2)

is

x_standard_url    VARCHAR2(2000);

begin

   /*
   ** Create the fixed set of parameters for the envelope
   ** routine that gets passed anywhere you create an
   ** envelope url
   */
   x_standard_url := owa_util.get_owa_service_path||
                  'wf_monitor.envelope'||
                  '?x_item_type='||wfa_html.conv_special_url_chars(x_item_type)||
                  '&x_item_key='||wfa_html.conv_special_url_chars(x_item_key)||
                  '&x_admin_mode='||x_admin_mode||
                  '&x_access_key='||x_access_key||
                  '&x_advanced='||x_advanced||
                  '&x_active='||x_active||
                  '&x_complete='||x_complete||
                  '&x_error='||x_error||
                  '&x_suspend='||x_suspend||
                  '&x_proc_func='||x_proc_func||
                  '&x_note_resp='||x_note_resp||
                  '&x_note_noresp='||x_note_noresp||
                  '&x_func_std='||x_func_std ||
                  '&x_event='||x_event ||
                  '&x_nls_lang='||x_nls_lang;

   htp.tableRowOpen(cattributes=>'BGCOLOR=#006699');

   /*
   ** Create the done or status column header depending on whether
   ** you're in advanced mode or not
   */
   createenvsortlink(x_sort_column,
                     x_sort_order,
                     'STATUS',
                     x_advanced,
                     wf_core.translate('WFMON_STATUS'),
                     wf_core.translate('WFMON_DONE'),
                     TRUE,
                     x_standard_url);

   /*
   ** Create the WHO column header
   */
   createenvsortlink(x_sort_column,
                     x_sort_order,
                     'WHO',
                     x_advanced,
                     wf_core.translate('WFMON_WHO'),
                     wf_core.translate('WFMON_WHO'),
                     TRUE,
                     x_standard_url);

   /*
   ** Create the PARENT activity column header depending on whether
   ** you're in advanced mode or not
   */
   createenvsortlink(x_sort_column,
                     x_sort_order,
                     'PARENT',
                     x_advanced,
                     wf_core.translate('WFMON_PARENT_ACTIVITY'),
                     NULL,
                     FALSE,
                     x_standard_url);

   /*
   ** Create the ACTIVITY column header
   */
   createenvsortlink(x_sort_column,
                     x_sort_order,
                     'ACTIVITY',
                     x_advanced,
                     wf_core.translate('WFMON_ACTIVITY'),
                     wf_core.translate('WFMON_ACTIVITY'),
                     TRUE,
                     x_standard_url);

   /*
   ** Create the STARTDATE column header
   */
   createenvsortlink(x_sort_column,
                     x_sort_order,
                     'STARTDATE',
                     x_advanced,
                     wf_core.translate('WFMON_STARTED'),
                     wf_core.translate('WFMON_STARTED'),
                     TRUE,
                     x_standard_url);

   /*
   ** Create the DURATION column header
   */
   createenvsortlink(x_sort_column,
                     x_sort_order,
                     'DURATION',
                     x_advanced,
                     wf_core.translate('WFMON_DURATION'),
                     wf_core.translate('WFMON_DURATION'),
                     TRUE,
                     x_standard_url);

   /*
   ** Create the RESULT column header
   */
   createenvsortlink(x_sort_column,
                     x_sort_order,
                     'RESULT',
                     x_advanced,
                     wf_core.translate('WFMON_RESULT'),
                     wf_core.translate('WFMON_RESULT'),
                     TRUE,
                     x_standard_url);

   htp.tableRowClose;

end showEnvColumnHeaders;

--
-- ShowColumnHeaders (PRIVATE)
--   Print column header in InstanceList page
--
procedure showColumnHeaders
is
begin
   htp.tableRowOpen(cattributes=>'BGCOLOR=#006699');

   htp.tableHeader('<font color=#FFFFFF>'||wf_core.translate('ITEMTYPE')||'</font>', 'Center');
   htp.tableHeader('<font color=#FFFFFF>'||wf_core.translate('ITEMKEY')||'</font>', 'Center');
   htp.tableHeader('<font color=#FFFFFF>'||wf_core.translate('USER_ITEMKEY')||'</font>', 'Center');
   htp.tableHeader('<font color=#FFFFFF>'||wf_core.translate('PROCESS_NAME')||'</font>', 'Center');
   htp.tableHeader('<font color=#FFFFFF>'||wf_core.translate('COMPLETE')||'</font>', 'Center');
   htp.tableHeader('<font color=#FFFFFF>'||wf_core.translate('IN_ERROR')||'</font>', 'Center');
   htp.tableHeader('<font color=#FFFFFF>'||wf_core.translate('SUSPENDED')||'</font>', 'Center');
   htp.tableHeader('<font color=#FFFFFF>'||wf_core.translate('WFENG_BEGINDATE')||'</font>', 'Center');

   htp.tableRowClose;

exception
  when others then
    Wf_Core.Context('Wf_Monitor', 'ShowColumnHeaders');
    raise;
end showColumnHeaders;

--
-- TableRow (PRIVATE)
--   Show a row in the Instance_List table
-- IN
--   itemtype - item type
--   itemkey - item key
--   process - process name
--   url - url for monitor page
--   active - active or completed flag
--   error - errors exist flag
--   suspend - suspensions exist flag
--   startdate - date process started
--
-- MODIFICATION LOG:
-- 06-JUN-2001 JWSMITH 1819232 - added alt attribute to img tags for
--              following gifs: FNDIDONE, FNDIREDL, FNDIYLWL for ADA
--
procedure tableRow(itemtype     varchar2,
                   itemkey      varchar2,
                   userkey      varchar2,
                   process      varchar2,
                   url          varchar2,
                   active       boolean,
                   error        boolean,
                   suspend      boolean,
                   startdate    varchar2)
is
begin

  htp.tableRowOpen(calign=>'middle');
  htp.tableData(itemtype, 'Left', cattributes=>'id=""');
  htp.tableData(itemkey, 'Left', cattributes=>'id=""');
  if (userkey is not null) then
    htp.tableData(userkey, 'Left',cattributes=>'id=""');
  else
    htp.tableData(htf.br,cattributes=>'id=""');
  end if;

  if (url is not null) then
    htp.tableData(htf.anchor2(curl=>url, ctext=>process, ctarget=>'_top'),
                  'Left',
                  cattributes=>'id=""');
  else
    htp.tableData(process, 'Left', cattributes=>'id=""');
  end if;

  -- Active/Complete icon
  if (active) then
    htp.tableData(htf.br,cattributes=>'id=""');
  else
    htp.tableData(cvalue=>htf.img(curl=>wfa_html.image_loc||'FNDIDONE.gif',
                                  calt=>wf_core.translate('COMPLETE'),
                                  cattributes=>'border=no height=26'),
                  calign=>'center',
                  cattributes=>'id=""');
  end if;

  -- Error icon if error
  if (error) then
    htp.tableData(cvalue=>htf.img(curl=>wfa_html.image_loc||'FNDIREDL.gif',
                                  calt=>wf_core.translate('IN_ERROR'),
                                  cattributes=>'border=no height=26'),
                  calign=>'center',
                  cattributes=>'id=""');
  else
    htp.tableData(htf.br,cattributes=>'id=""');
  end if;

  -- Suspend icon if suspended
  if (suspend) then
    htp.tableData(cvalue=>htf.img(curl=>wfa_html.image_loc||'FNDIYLWL.gif',
                                  calt=>wf_core.translate('SUSPEND'),
                                  cattributes=>'border=no height=26'),
                  calign=>'center', cattributes=>'id=""');
  else
    htp.tableData(htf.br,cattributes=>'id=""');
  end if;

  htp.tableData(startdate, 'Left', cattributes=>'id=""');
  htp.tableRowClose;

exception
  when others then
    Wf_Core.Context('Wf_Monitor', 'TableRow', itemtype, itemkey, process,
                    url, startdate);
    raise;
end TableRow;

--
-- Instance_List
--   Produce list of processes matching criteria
-- IN
--   x_active - Item active or complete (ACTIVE, COMPLETE, ALL)
--   x_itemtype - Itemtype (null for all)
--   x_ident - Itemkey (null for all)
--   x_user_ident - User Itemkey (null for all)
--   x_process - Root process name (null for all)
--   x_status - Only with activities of status (SUSPEND, ERROR, ALL)
--   x_person - Only waiting for reponse from
--   x_numdays - No progress in x days
--
-- MODIFICATION LOG:
-- 06-JUN-2001 JWSMITH BUG 1819232 -Added summary attr for table tag for ADA
--
procedure Instance_List (
  x_active      VARCHAR2,
  x_itemtype    VARCHAR2,
  x_ident       VARCHAR2,
  x_user_ident  VARCHAR2,
  x_process     VARCHAR2,
  x_process_owner       VARCHAR2,
  x_display_process_owner       VARCHAR2,
  x_admin_privilege     VARCHAR2,
  x_status      VARCHAR2,
  x_person      VARCHAR2,
  x_display_person      VARCHAR2,
  x_numdays     VARCHAR2)
is
  -- Select items matching criteria
  cursor proc_info (c_process_owner IN VARCHAR2,
                    c_person IN VARCHAR2)is
  select wit.display_name,
         wi.item_key,
         wi.user_key,
         wi.begin_date,
         wi.item_type,
         wi.end_date,
         wa.display_name process_name
  from   wf_items wi,
         wf_item_types_vl wit,
         wf_activities_vl wa
  where  wi.item_type = wit.name
    and  wa.item_type = wi.item_type
    and  wa.name = wi.root_activity
    and  wa.version = wi.root_activity_version
    and  wi.item_type like decode(x_itemtype,
                                  '', '%',
                                  'ALL', '%',
                                  '*', '%',
                                  x_itemtype)
    and  wi.item_key like x_ident||'%'
    and  (wi.owner_role like upper(c_process_owner)||'%' or
          c_process_owner is null)
    and  (wi.user_key like x_user_ident||'%' or
          x_user_ident is null)
    and  (wa.display_name like x_process||'%')
    and (((wi.end_date is null) and (x_active in ('ACTIVE', 'ALL'))) or
         ((wi.end_date is not null) and (x_active in ('COMPLETE', 'ALL'))))
    and  ((x_numdays is null) or
          (wi.end_date is null and not exists
              (select null
               from wf_item_activity_statuses ias
               where ias.item_type = wi.item_type
               and ias.item_key = wi.item_key
               and ias.end_date > sysdate - x_numdays)))
    and  ((c_person is null) or exists
              (select null
               from wf_item_activity_statuses ias,
                    wf_notifications ntf
               where wi.end_date is null
               and ias.item_type = wi.item_type
               and ias.item_key = wi.item_key
               and ias.activity_status||'' = 'NOTIFIED'
               and ntf.group_id = ias.notification_id
               and ntf.recipient_role||'' = upper(c_person)))
    and  ((x_status = 'ALL') or exists
              (select null
               from wf_item_activity_statuses ias
               where ias.item_type = wi.item_type
               and ias.item_key = wi.item_key
               and ias.activity_status||'' = x_status))
    order by 1,2;

   proc proc_info%rowtype;

   cursor status_info(itype varchar2, ikey varchar2, status varchar2) is
   select count(1)
   from wf_item_activity_statuses wias
   where wias.item_type = itype
   and wias.item_key = ikey
   and wias.activity_status = status;

   error_count pls_integer;
   suspend_count pls_integer;

   envurl   varchar2(2000);

   username varchar2(320);
   admin_role varchar2(320);
   l_process_owner       VARCHAR2(320) := x_process_owner;
   l_person              VARCHAR2(320) := x_person;

begin

  wfa_sec.GetSession(username);

  -- Get all the username find criteria resolved
  wfa_html.validate_display_name (x_display_process_owner, l_process_owner);
  wfa_html.validate_display_name (x_display_person, l_person);

  -- Window title
  htp.htmlOpen;
  htp.headOpen;
  htp.title(wf_core.translate('WFMON_LISTTITLE'));
  wfa_html.create_help_function('wf/links/pro.htm?PROLIST');
  htp.headClose;

  -- Open body and draw standard header
  wfa_sec.header(FALSE, 'wf_monitor.find_instance" TARGET="_top',
         wf_core.translate('WFMON_LISTTITLE'), TRUE);

  htp.tableOpen(cattributes=>'border=1 cellpadding=3 bgcolor=WHITE
                width=100% summary=""');

  showColumnHeaders;

  -- Security checking 1364970

  admin_role := wf_core.Translate('WF_ADMIN_ROLE');
  if (admin_role <> '*')  then
    if not (wf_directory.IsPerformer(username, admin_role)) then
            l_process_owner := username;
    end if;
  end if;

  for proc in proc_info (l_process_owner, l_person) loop
    -- Check for errors
    open status_info(proc.item_type, proc.item_key, 'ERROR');
    fetch status_info into error_count;
    close status_info;

    -- Check for suspensions
    open status_info(proc.item_type, proc.item_key, 'SUSPEND');
    fetch status_info into suspend_count;
    close status_info;

    begin
      envurl :=wf_monitor.GetEnvelopeURL(wfa_html.base_url,
                                         proc.item_type,
                                         proc.item_key,
                                         x_admin_privilege);
    exception
      when others then
      -- ### In case there are any exceptions raised.  Happens
      --     right now for older workflows which have not yet
      --     had access keys assigned, although all new ones shouled.
      envurl := null;
    end;

    tableRow(proc.display_name,
             proc.item_key,
             proc.user_key,
             proc.process_name,
             envurl,
             (proc.end_date is null),
             (error_count <> 0),
             (suspend_count <> 0),
             to_char(proc.begin_date) || ' '
              || to_char(proc.begin_date, 'HH24:MI:SS'));
  end loop;

  htp.tableClose;


  wfa_sec.footer;
  htp.htmlClose;
exception
  when others then
    Wf_Core.Context('Wf_Monitor', 'Instance_List', x_active, x_itemtype,
                    x_ident, x_process, x_status);
    Error;
end Instance_List;

/*===========================================================================
  PROCEDURE NAME:       draw_advanced_controls

  DESCRIPTION:

  -- MODIFICATION LOG:
  -- 06-JUN-2001 JWSMITH BUG 1819232 - added ID attrib for HD tag for ADA
                 - Added summary attr for table tag for ADA
============================================================================*/
procedure draw_advanced_controls (
  x_item_type              VARCHAR2,
  x_item_key               VARCHAR2,
  x_admin_mode             VARCHAR2,
  x_access_key             VARCHAR2,
  x_advanced               VARCHAR2,
  x_active                 VARCHAR2,
  x_complete               VARCHAR2,
  x_error                  VARCHAR2,
  x_suspend                VARCHAR2,
  x_proc_func              VARCHAR2,
  x_note_resp              VARCHAR2,
  x_note_noresp            VARCHAR2,
  x_func_std               VARCHAR2,
  x_event                  VARCHAR2,
  x_sort_column            VARCHAR2,
  x_sort_order             VARCHAR2,
  x_nls_lang               VARCHAR2)

IS
l_record_num           PLS_INTEGER;
l_status_icons_table   wf_status_icons_table;

BEGIN

  htp.p('<FORM NAME="controls" ACTION="wf_monitor.envelope_frame" METHOD="GET" TARGET="DETAILS">');

  /*
  ** Skip a line
  */
  wf_item_definition_util_pub.draw_summary_section_title (
     wf_core.translate('WFMON_STATUS_OPTIONS'),
     0);

  /*
  ** Open a new table for the list of checkboxes that show what
  ** statuses are currently displayed on the form
  */
  htp.tableOpen(cattributes=>'border=0 cellpadding=0 cellspacing=0
                              summary=""');

  /*
  ** Create the checkbox for each activity status.
  */
  /*
  ** Open the checkboxes row
  */
  htp.tableRowOpen;

  /*
  ** Create the icon filename list for the different statuses
  */
  create_status_icons_table (l_status_icons_table);

  /*
  ** Create the active activity checkbox
  */
  wf_item_definition_util_pub.create_checkbox(
        'x_active',
        'ACTIVE',
        x_active,
        wf_core.translate ('ACTIVE'),
        l_status_icons_table(G_ACTIVE).icon_file_name,
        FALSE);


  /*
  ** Create the completed activity checkbox
  */
  wf_item_definition_util_pub.create_checkbox(
        'x_complete',
        'COMPLETE',
        x_complete,
        wf_core.translate ('COMPLETE'),
        l_status_icons_table(G_COMPLETE).icon_file_name,
        FALSE);

  /*
  ** Create the error activity checkbox
  */
  wf_item_definition_util_pub.create_checkbox(
        'x_error',
        'ERROR',
        x_error,
        wf_core.translate ('ERROR'),
        l_status_icons_table(G_ERROR).icon_file_name,
        FALSE);

  /*
  ** Create the suspended activity checkbox
  */
  wf_item_definition_util_pub.create_checkbox(
        'x_suspend',
        'SUSPEND',
        x_suspend,
        wf_core.translate ('SUSPENDED'),
        l_status_icons_table(G_SUSPEND).icon_file_name,
        FALSE);

  /*
  ** Close the checkboxes row
  */
  htp.tableRowClose;

  /*
  ** Close the checkboxes table
  */
  htp.tableClose;

  /*
  ** Skip a line
  */
  htp.p('<BR>');

  /*
  ** Show the Processes activity options header
  */
  wf_item_definition_util_pub.draw_summary_section_title (
     wf_core.translate('WFMON_ACTIVITY_TYPE'),
     0);

  /*
  ** Open a new table for the list of checkboxes that show what
  ** statuses are currently displayed on the form
  */
  htp.tableOpen(cattributes=>'border=0 cellpadding=0 cellspacing=0
                              summary=""');

  /*
  ** Create the checkbox for each activity status.
  */
  /*
  ** Open the checkboxes row
  */
  htp.tableRowOpen;

  /*
  ** Create the checkbox for Notifications With Responses
  */
  wf_item_definition_util_pub.create_checkbox(
             'x_note_resp',
             'Y',
             x_note_resp,
              wf_core.translate('WFMON_NOTIF_RESPONSE'),
             null,
             FALSE);

  /*
  ** Create the checkbox for Notifications Without Responses
  */
  wf_item_definition_util_pub.create_checkbox(
             'x_note_noresp',
             'Y',
             x_note_noresp,
              wf_core.translate('WFMON_NOTIF_NO_RESPONSE'),
             null,
             FALSE);

  /*
  ** Create the checkbox for Processes with results
  */
  wf_item_definition_util_pub.create_checkbox(
             'x_proc_func',
             'Y',
             x_proc_func,
              wf_core.translate('WFMON_PROCESS_FUNCTION'),
             null,
             FALSE);

  /*
  ** Create the checkbox for Standard Workflow Functions
  */
  wf_item_definition_util_pub.create_checkbox(
             'x_func_std',
             'Y',
             x_func_std,
              wf_core.translate('WFMON_FUNCTION_STANDARD'),
             null,
             FALSE);


  /*
  ** Create the checkbox for Event Activity
  */
  wf_item_definition_util_pub.create_checkbox(
             'x_event',
             'Y',
             x_event,
              wf_core.translate('WFMON_EVENT')||
                 '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;',
             null,
             FALSE);

  htp.p('<TD ID="">');

  wfa_html.create_reg_button ('javascript:document.controls.submit()',
                              wf_core.translate ('WFMON_REQUERY'),
                              wfa_html.image_loc,
                              'fndfind.gif',
                              wf_core.translate ('WFMON_REQUERY'));

  htp.p('</TD>');

  /*
  ** Close the checkboxes row
  */
  htp.tableRowClose;

  /*
  ** Close the checkboxes table
  */
  htp.tableClose;

  htp.p(htf.formHidden('x_item_type', x_item_type));
  htp.p(htf.formHidden('x_item_key', x_item_key));
  htp.p(htf.formHidden('x_admin_mode', x_admin_mode));
  htp.p(htf.formHidden('x_access_key', x_access_key));
  htp.p(htf.formHidden('x_advanced', 'TRUE'));
  htp.p(htf.formHidden('x_sort_column', x_sort_column));
  htp.p(htf.formHidden('x_sort_order', x_sort_order));
  htp.p(htf.formHidden('x_nls_lang', x_nls_lang));

  htp.formClose;

  EXCEPTION
  WHEN OTHERS THEN
     Wf_Core.Context('wf_monitor',
        'draw_advanced_controls',
        x_advanced);

     error;

END draw_advanced_controls;

PROCEDURE draw_header (
    x_item_type  varchar2,
    x_item_key   varchar2,
    x_admin_mode varchar2,
    x_access_key varchar2,
    x_advanced   varchar2,
    x_nls_lang   varchar2) IS

  username       varchar2(320);
  l_agent        varchar2(100) := owa_util.get_cgi_env('SCRIPT_NAME');
  pseudo_login   BOOLEAN := FALSE;
BEGIN

  /*
  ** Hide any session creation issues for now and depend on the
  ** access key to prevent a user from running this function without
  ** logging in.
  */
  begin

     -- set the validate_only flag to true so you don't throw up the login
     -- page and you have a chance to check the access key.
     wfa_sec.validate_only := TRUE;

     wfa_sec.GetSession(username);

     exception
       when others then
           -- If AccessKeyCheck will return "ERROR" directly if failed
           if (not(AccessKeyCheck(x_item_type, x_item_key, x_admin_mode,
                x_access_key))) then

               htp.p(wf_core.translate('WRONG_ACCESS_KEY'));

               return;

           else

             dbms_session.set_nls('NLS_LANGUAGE', ''''||x_nls_lang||'''');
             pseudo_login := TRUE;
           end if;
  end;

  -- Window title
  htp.htmlOpen;
  htp.headOpen;

  /*
  ** If you are not in advanced mode then make the window title the
  ** standard Notifications List.  Otherwise make it Activities List
  */
  IF (x_advanced = 'FALSE') THEN

     htp.title(wf_core.translate('WFMON_ENVELOPE_LIST'));
     wfa_html.create_help_function('wf/links/nfl.htm?NFLIST');

  ELSE

     htp.title(wf_core.translate('WFMON_ACTIVITIES_LIST'));
     wfa_html.create_help_function('wf/links/aal.htm?AALIST');

  END IF;

  htp.headClose;

  -- Open body and draw standard header
  IF (x_advanced = 'FALSE') THEN

     wfa_sec.header(FALSE, 'wf_monitor.find_instance" TARGET="_top', wf_core.translate('WFMON_ENVELOPE_LIST'), TRUE, pseudo_login);

  else

     wfa_sec.header(FALSE, 'wf_monitor.find_instance" TARGET="_top', wf_core.translate('WFMON_ACTIVITIES_LIST'), TRUE, pseudo_login);

  end if;

exception
when others then
     Wf_Core.Context('wf_monitor',
        'draw_header',
        x_item_type,
        x_item_key,
        x_admin_mode,
        x_access_key,
        x_advanced);

     error;

end draw_header;

procedure Envelope (
  x_item_type              VARCHAR2,
  x_item_key               VARCHAR2,
  x_admin_mode             VARCHAR2,
  x_access_key             VARCHAR2,
  x_advanced               VARCHAR2,
  x_active                 VARCHAR2,
  x_complete               VARCHAR2,
  x_error                  VARCHAR2,
  x_suspend                VARCHAR2,
  x_proc_func              VARCHAR2,
  x_note_resp              VARCHAR2,
  x_note_noresp            VARCHAR2,
  x_func_std               VARCHAR2,
  x_event                  VARCHAR2,
  x_sort_column            VARCHAR2,
  x_sort_order             VARCHAR2,
  x_nls_lang               VARCHAR2
  ) is

  username              varchar2(320);
  l_child_item_list     wf_monitor.wf_items_tbl_type;
  l_number_of_children  NUMBER :=0;
  begin

  /*
  ** Hide any session creation issues for now and depend on the
  ** access key to prevent a user from running this function without
  ** logging in.
  */
  begin

     -- set the validate_only flag to true so you don't throw up the login
     -- page and you have a chance to check the access key.
     wfa_sec.validate_only := TRUE;

     wfa_sec.GetSession(username);

     exception
       when others then
           -- If AccessKeyCheck will return "ERROR" directly if failed
           if (not(AccessKeyCheck(x_item_type, x_item_key, x_admin_mode,
                x_access_key))) then

               htp.p(wf_core.translate('WRONG_ACCESS_KEY'));

               return;

           else

             dbms_session.set_nls('NLS_LANGUAGE', ''''||x_nls_lang||'''');

           end if;
  end;

  -- Window title
  htp.htmlOpen;
  htp.headOpen;

  /*
  ** If you are not in advanced mode then make the window title the
  ** standard Notifications List.  Otherwise make it Activities List
  */
  htp.title(wf_core.translate('WFMON_ENVELOPE_LIST'));

  wfa_html.create_help_function('wf/links/nfl.htm?NFLIST');

  htp.headClose;

  htp.htmlOpen;


  -- Open frameset
  htp.p('<FRAMESET ROWS="15%,85%" frameborder=no border=0
           TITLE="' || WF_CORE.Translate('WFMON_ENVELOPE_LIST') || '" LON
GDESC="' ||           owa_util.get_owa_service_path ||
           'wfa_html.LongDesc?p_token=WFMON_ENVELOPE_LIST">');

  htp.p('<FRAME NAME="header_bar" MARGINHEIGHT=10 MARGINWIDTH=10 ' ||
        'scrolling=no frameborder=no framespacing=noresize '||
        'src="'||owa_util.get_owa_service_path||
        'wf_monitor.draw_header'||
        '?x_item_type='||wfa_html.conv_special_url_chars(x_item_type)||
        '&x_item_key='||wfa_html.conv_special_url_chars(x_item_key)||
        '&x_admin_mode='||x_admin_mode||
        '&x_access_key='||x_access_key||
        '&x_advanced='||x_advanced||
        '&x_nls_lang='||x_nls_lang||
        '" TITLE="' ||
         WF_CORE.Translate('WFMON_ENVELOPE_LIST') || '" LONGDESC="' ||
         owa_util.get_owa_service_path ||
         'wfa_html.LongDesc?p_token=WFMON_ENVELOPE_LIST">');

  /*
  ** Check if there are any children for this process.  If there are
  ** then show a two frame set.  One frame for the process hierarchy the other
  ** with the envelope list.  If there are no children then just have a single
  ** frame for the envelope list details.
  */

  /*
  ** Get the process children for this row
  */
  wf_monitor.get_process_children(X_item_type,
                                  X_item_key,
                                  l_child_item_list,
                                  l_number_of_children);

  IF (l_number_of_children > 0) THEN

     htp.p('<FRAMESET COLS="25%,75%" frameborder=no border=1
           TITLE="' || WF_CORE.Translate('WFMON_ENVELOPE_LIST') || '" LON
GDESC="' ||           owa_util.get_owa_service_path ||
           'wfa_html.LongDesc?p_token=WFMON_ENVELOPE_LIST">');

     htp.p('<FRAME NAME="CHILDREN" scrolling=yes frameborder=no framespacing=noresize ' ||
           'src="'||owa_util.get_owa_service_path||
                 'wf_monitor.process_children'||
                 '?x_item_type='||wfa_html.conv_special_url_chars(x_item_type)||
                 '&x_item_key='||wfa_html.conv_special_url_chars(x_item_key)||
                 '&x_admin_mode='||x_admin_mode||
                 '&x_nls_lang='||x_nls_lang||'" WRAP=OFF "' ||
                  '" TITLE="' ||
           WF_CORE.Translate('WFMON_ENVELOPE_LIST') || '" LONGDESC="' ||
           owa_util.get_owa_service_path ||
           'wfa_html.LongDesc?p_token=WFMON_ENVELOPE_LIST">');

     htp.p('<FRAME NAME="DETAILS"  frameborder=no framespacing=0 '||
           'src="'||owa_util.get_owa_service_path||
           'wf_monitor.envelope_frame'||
           '?x_item_type='||wfa_html.conv_special_url_chars(x_item_type)||
           '&x_item_key='||wfa_html.conv_special_url_chars(x_item_key)||
           '&x_admin_mode='||wfa_html.conv_special_url_chars(x_admin_mode)||
           '&x_access_key='||wfa_html.conv_special_url_chars(x_access_key)||
           '&x_advanced='||wfa_html.conv_special_url_chars(x_advanced)||
           '&x_active='||wfa_html.conv_special_url_chars(x_active)||
           '&x_complete='||x_complete||
           '&x_error='||x_error||
           '&x_suspend='||x_suspend||
           '&x_proc_func='||x_proc_func||
           '&x_note_resp='||x_note_resp||
           '&x_note_noresp='||x_note_noresp||
           '&x_func_std='||x_func_std||
           '&x_event='||x_event||
           '&x_sort_column='||x_sort_column||
           '&x_sort_order='||x_sort_column||
           '&x_nls_lang='||x_nls_lang||
            '" TITLE="' ||
           WF_CORE.Translate('WFMON_ENVELOPE_LIST') || '" LONGDESC="' ||
           owa_util.get_owa_service_path ||
           'wfa_html.LongDesc?p_token=WFMON_ENVELOPE_LIST">');

  ELSE

     htp.p('<FRAMESET COLS="100%" frameborder=no border=0
            TITLE="' || WF_CORE.Translate('WFMON_ENVELOPE_LIST') || '" LON
GDESC="' ||           owa_util.get_owa_service_path ||
           'wfa_html.LongDesc?p_token=WFMON_ENVELOPE_LIST">');

     htp.p('<FRAME NAME="DETAILS"  frameborder=no framespacing=0 '||
           'src="'||owa_util.get_owa_service_path||
           'wf_monitor.envelope_frame'||
           '?x_item_type='||wfa_html.conv_special_url_chars(x_item_type)||
           '&x_item_key='||wfa_html.conv_special_url_chars(x_item_key)||
           '&x_admin_mode='||x_admin_mode||
           '&x_access_key='||x_access_key||
           '&x_advanced='||x_advanced||
           '&x_active='||x_active||
           '&x_complete='||x_complete||
           '&x_error='||x_error||
           '&x_suspend='||x_suspend||
           '&x_proc_func='||x_proc_func||
           '&x_note_resp='||x_note_resp||
           '&x_note_noresp='||x_note_noresp||
           '&x_func_std='||x_func_std||
           '&x_event='||x_event||
           '&x_sort_column='||x_sort_column||
           '&x_sort_order='||x_sort_order||
           '&x_nls_lang='||x_nls_lang||
           '" TITLE="' ||
           WF_CORE.Translate('WFITD_ITEM_TYPE_DEFINITION') || '" LONGDESC="' ||
           owa_util.get_owa_service_path ||
           'wfa_html.LongDesc?p_token=WFITD_ITEM_TYPE_DEFINITION">');

  END IF;

  htp.p('</FRAMESET>');

  htp.p('</FRAMESET>');

  htp.htmlClose;

exception
  when others then
    Wf_Core.Context('Wf_Monitor', 'Envelope', x_item_type, x_item_key);
    Error;
end envelope;

--
-- Envelope_Frame
--
-- MODIFICATION LOG:
-- 06-JUN-2001 JWSMITH BUG 1819232 - added alt attrib for the following gifs
--             FNDIACTV,FNDIDONE,FNDIYLWL, FNDIREDL for ADA
--             - Also added ID attrib for HD tag for ADA
--             - Also added summary attri for table tag for ADA
--
procedure Envelope_Frame (
  x_item_type              VARCHAR2,
  x_item_key               VARCHAR2,
  x_admin_mode             VARCHAR2,
  x_access_key             VARCHAR2,
  x_advanced               VARCHAR2,
  x_active                 VARCHAR2,
  x_complete               VARCHAR2,
  x_error                  VARCHAR2,
  x_suspend                VARCHAR2,
  x_proc_func              VARCHAR2,
  x_note_resp              VARCHAR2,
  x_note_noresp            VARCHAR2,
  x_func_std               VARCHAR2,
  x_event                  VARCHAR2,
  x_sort_column            VARCHAR2,
  x_sort_order             VARCHAR2,
  x_nls_lang               VARCHAR2
  ) is

  username varchar2(320);
  role_name varchar2(320);
  email_address varchar2(320);
  buf varchar2(2000);
  url  varchar2(2000);
  mlrurl varchar2(2000);
  status_options varchar2(2000);
  x_begin_date date;
  x_end_date date := null;
  proc_dispname varchar2(80);
  item_type_dispname varchar2(80);
  proc_duration varchar2(30);
  x_root_activity varchar2(30);
  x_font_color varchar2(30);
  x_font_color_end varchar2(30);
  title_info varchar2(4000);
  status_flag varchar2(15);
  x_show_activity              BOOLEAN := FALSE;
  x_valid_status               BOOLEAN := FALSE;
  l_agent                      VARCHAR2(100) := owa_util.get_cgi_env('SCRIPT_NAME');
  l_duration_days              NUMBER := 0;
  l_duration_hours             NUMBER := 0;
  l_duration_minutes           NUMBER := 0;
  l_duration_seconds           NUMBER := 0;
  l_record_num                 PLS_INTEGER;
  x_notification_id            PLS_INTEGER := NULL;
  x_notification_result        VARCHAR2(80) := NULL;
  x_notification_response      INTEGER := 0;
  x_icon_name                  VARCHAR2(30);
  x_duration_str               VARCHAR2(80);
  l_date_date                  DATE;
  l_valid_date                 BOOLEAN;
  l_expected_format            VARCHAR2(80);
  u_key                        VARCHAR2(240);
  l_status_icons_table         wf_status_icons_table;
  x_activity_cursor            wf_monitor.wf_activity_cursor;
  x_activity_record            wf_monitor.wf_activity_record;
  pseudo_login                 BOOLEAN := FALSE;

  cursor attrs(mnid in number) is
    select MA.NAME
    from WF_NOTIFICATION_ATTRIBUTES NA,
         WF_MESSAGE_ATTRIBUTES_VL MA,
         WF_NOTIFICATIONS N
    where N.NOTIFICATION_ID = mnid
    and NA.NOTIFICATION_ID = N.NOTIFICATION_ID
    and MA.MESSAGE_NAME = N.MESSAGE_NAME
    and MA.MESSAGE_TYPE = N.MESSAGE_TYPE
    and MA.NAME = NA.NAME
    and MA.SUBTYPE = 'RESPOND'
    and MA.TYPE <> 'FORM'
    and MA.NAME = 'RESULT';

  result attrs%rowtype;
  n_response varchar2(3200);  -- required response icon

BEGIN

  /*
  ** Hide any session creation issues for now and depend on the
  ** access key to prevent a user from running this function without
  ** logging in.
  */
  begin

     -- set the validate_only flag to true so you don't throw up the login
     -- page and you have a chance to check the access key.
     wfa_sec.validate_only := TRUE;

     wfa_sec.GetSession(username);

     exception
       when others then
           -- If AccessKeyCheck will return "ERROR" directly if failed
           if (not(AccessKeyCheck(x_item_type, x_item_key, x_admin_mode,
                x_access_key))) then

               htp.p(wf_core.translate('WRONG_ACCESS_KEY'));

               return;

           else

             dbms_session.set_nls('NLS_LANGUAGE', ''''||x_nls_lang||'''');
             pseudo_login := TRUE;

           end if;
  end;


  -- To avoid having Instance_List() send the begin_date of item_key,
  -- do the fetch here.
  -- This is to avoid sending spaces throught web server
  select i.begin_date, i.end_date, a.display_name, it.display_name, i.root_activity
  into  x_begin_date, x_end_date, proc_dispname, item_type_dispname, x_root_activity
  from  wf_items i, wf_activities_vl a, wf_item_types_vl it
  where i.item_type = x_item_type
  and   i.item_key = x_item_key
  and   i.item_type = it.name
  and   i.root_activity = a.name
  and   i.item_type = a.item_type
  and   a.begin_date <= i.begin_date
  and   (a.end_date is null or a.end_date > i.begin_date);

  if (x_end_date is null) then
    proc_duration := to_char(sysdate,'J') - to_char(x_begin_date, 'J');
    status_flag := 'FNDIACTV.gif';
  else
    proc_duration := to_char(x_end_date,'J') - to_char(x_begin_date, 'J');
    status_flag := 'FNDIDONE.gif';
  end if;

  -- Get User Key
  select user_key into u_key from wf_items
  where item_type=x_item_type and item_key = x_item_key;
  if u_key is null then
    u_key := x_item_key;
  end if;


  htp.htmlOpen;

  -- use onload to redraw the header with new title when moving to detail screen
  htp.p('<body bgcolor="#CCCCCC" onLoad="'||
        'open('||''''||'wf_monitor.draw_header'||
        '?x_item_type='||wfa_html.conv_special_url_chars(x_item_type)||
        '&x_item_key='||wfa_html.conv_special_url_chars(x_item_key)||
        '&x_admin_mode='||x_admin_mode||
        '&x_access_key='||x_access_key||
        '&x_advanced='||x_advanced||
        '&x_nls_lang='||x_nls_lang|| ''''||', '||
        ''''||'header_bar'||''''||')">');

  if (status_flag = 'FNDIACTV.gif') then
      htp.p(htf.img(wfa_html.image_loc||status_flag,'left',
                wf_core.translate('ACTIVE'), null, 'height=40 width=35'));
  else
      htp.p(htf.img(wfa_html.image_loc||status_flag,'left',
                wf_core.translate('COMPLETE'), null, 'height=40 width=35'));
  end if;

  title_info := proc_dispname||': '||item_type_dispname||', '||u_key;
  htp.p(title_info);

  htp.p(htf.br);
  title_info := wf_core.translate('WFMON_STARTED')||':  '||
                x_begin_date||'  ( '||
                proc_duration||' '||wf_core.translate('WFMON_DAYS')||' )';
  htp.p(title_info);
  htp.p(htf.br(cclear=>'clear=left'));
  htp.p('<P>');


  /*
  ** Get the NLS Date format that is currently set.  All to_char of
  ** date values should use the l_expected_format
  */
  wf_item_definition_util_pub.validate_date (
     TO_CHAR(x_begin_date, 'DD-MON-RRRR HH24:MI:SS'),
     l_date_date,
     l_valid_date,
     l_expected_format);

  /*
  **
  ** I've created an argument for the envelope procedure for each of the
  ** possible statuses.  If the checkbox is checked then the
  ** lookup code value will be passed through this argument.  I will concatenate
  ** all these arguments together into a single string so that I can use
  ** INSTR to determine if the status of a given activity has been requested
  ** as one of the activities that have been checked.
  */
  status_options :=
     x_active   ||'-'||
     x_complete ||'-'||
     x_error    ||'-'||
     x_suspend;

  /*
  ** Create the icon filename list for the different statuses
  */
  create_status_icons_table (l_status_icons_table);

  /*
  ** Create the advanced controls for the activities list.
  **If youre coming into this procedure from the process list
  ** then the x_advanced variable will be set to FALSE. If
  ** youre coming from the notifications list and select the
  ** advanced search option for the first time then the
  ** x_advanced variable will be set to FIRST.  All other
  ** times it will be set to true
  */
  IF (x_advanced in ('FIRST', 'TRUE')) THEN

     /*
     ** Create the controls frame
     */
     draw_advanced_controls(
        x_item_type,
        x_item_key,
        x_admin_mode,
        x_access_key,
        'TRUE',
        x_active,
        x_complete,
        x_error,
        x_suspend,
        x_proc_func,
        x_note_resp,
        x_note_noresp,
        x_func_std,
        x_event,
        x_sort_column,
        x_sort_order,
        x_nls_lang);

  END IF;

  /*
  ** Create the envelope form.  The envelope form is under the advanced_controls
  ** form and is implemented as a separate form so that you can have the
  ** diffent submit controls for View Monitor vs. Show Activities.
  */
  htp.p('<FORM NAME="envelope" ACTION="wf_monitor.html" METHOD="GET" TARGET="_top">');

  /*
  ** Open the main table for the list of activities
  */
  htp.tableOpen(calign=>'CENTER', cattributes=>'border=1 cellpadding=3 bgcolor=WHITE width=100% summary=""');

  /*
  ** Show the Envelope column headers.  All the parameters being passed
  ** around is required so that I can create soft links that cause the
  ** sorting on different columns to be set up.  We also need to pass
  ** the current sort options so we can let the user know what is the
  ** current sort column.  We pass the x_advanced parameter to tell the
  ** column header routine whether or not to enable the sorting option
  ** and whether or not to show the parent activity column or not.
  */
  showEnvColumnHeaders(
     x_item_type,
     x_item_key,
     x_admin_mode,
     x_access_key,
     x_advanced,
     x_active,
     x_complete,
     x_error,
     x_suspend,
     x_proc_func,
     x_note_resp,
     x_note_noresp,
     x_func_std,
     x_event,
     x_sort_column,
     x_sort_order,
     x_nls_lang);

  /*
  ** Open the appropriate cursor for the requested sort
  ** order.  We currently fetch all the activity rows for
  ** the given process and then programatically determine
  ** which rows to display based on your activity list
  ** filters.  You can see these down below.
  */

  /*
  ** The sorting issues are fairly complicated.
  ** You cannot use a decode statement to identify
  ** the direction of your sort only the column that
  ** will be used for the sort.  To get around this
  ** I've had to copy
  ** the select statement twice.  The first is the sort
  ** for the ascending list.  The second is the list
  ** for the descending sort.  The x_activity_cursor is
  ** defined in wfmons and can be shared across multiple
  ** selects as long as the select list matches the
  ** wf_activity_record definition
  */
  IF (NVL(x_sort_order, 'ASC') = 'ASC') THEN

     OPEN  x_activity_cursor FOR
     select item_type,
            item_key,
            begin_date,
            execution_time,
            end_date,
            begin_date_time,
            duration,
            activity_item_type,
            activity_type,
            parent_activity_name,
            activity_name,
            activity_display_name,
            parent_display_name,
            activity_status,
            notification_status,
            notification_id,
            recipient_role,
            recipient_role_name,
            activity_status_display,
            result
     from  wf_item_activities_history_v wfhist
     where wfhist.item_type = x_item_type
     and   wfhist.item_key = x_item_key
     and   wfhist.activity_def_begin_date <= x_begin_date
     and   (wfhist.activity_def_end_date is null or wfhist.activity_def_end_date > x_begin_date)
     order by
           DECODE(x_sort_column, 'STATUS',       activity_status_display,
                                 'WHO',          recipient_role_name,
                                 'PARENT',       parent_display_name,
                                 'ACTIVITY',     activity_display_name,
                                 'STARTDATE',    to_char(begin_date, 'J.SSSSS'),
                                 'DURATION',     to_char(duration, '00000000'),
                                 'RESULT',       result,
                                                 to_char(begin_date, 'J.SSSSS')),
           begin_date,
           execution_time;

  ELSE

     OPEN  x_activity_cursor FOR
     select item_type,
            item_key,
            begin_date,
            execution_time,
            end_date,
            begin_date_time,
            duration,
            activity_item_type,
            activity_type,
            parent_activity_name,
            activity_name,
            activity_display_name,
            parent_display_name,
            activity_status,
            notification_status,
            notification_id,
            recipient_role,
            recipient_role_name,
            activity_status_display,
            result
     from  wf_item_activities_history_v wfhist
     where wfhist.item_type = x_item_type
     and   wfhist.item_key = x_item_key
     and   wfhist.activity_def_begin_date <= x_begin_date
     and   (wfhist.activity_def_end_date is null or wfhist.activity_def_end_date > x_begin_date)
     order by
           DECODE(x_sort_column, 'STATUS',       activity_status_display,
                                 'WHO',          recipient_role_name,
                                 'PARENT',       parent_display_name,
                                 'ACTIVITY',     activity_display_name,
                                 'STARTDATE',    to_char(begin_date, 'J.SSSSS'),
                                 'DURATION',     to_char(duration, '00000000'),
                                 'RESULT',       result,
                                                 to_char(begin_date, 'J.SSSSS')) desc,
           begin_date desc,
           execution_time desc;

  END IF;

  /*
  ** Go fetch all the rows that were selected in the above cursor
  */
  LOOP

    FETCH x_activity_cursor INTO x_activity_record;

    EXIT WHEN x_activity_cursor%NOTFOUND;

    x_notification_id := x_activity_record.notification_id;

    /*
    ** Get the result for a notification
    */
    BEGIN

       SELECT decode(ma.type,
                  'NUMBER', to_char(na.number_value),
                  'DATE',   to_char(na.date_value,
                                 nvl(ma.format, 'DD/MON/YYYY HH24:MI:SS')),
                  'LOOKUP', wf_core.activity_result(ma.format, na.text_value),
                     na.text_value) result,
               1
        INTO   x_notification_result,
               x_notification_response
        FROM   wf_notification_attributes na,
               wf_message_attributes_vl ma,
               wf_notifications n
        WHERE  n.group_id = x_notification_id
        AND    n.message_type = ma.message_type
        AND    n.message_name = ma.message_name
        AND    ma.name = na.name
        AND    ma.name = 'RESULT'
        AND    na.notification_id = n.notification_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           x_notification_result := 'WF_NOTFOUND';
           x_notification_response := 0;

        /*
        ** The other exceptions that could occur are that more than one
        ** row was fetched into a single row select which is the case
        ** for a notification that was
        ** sent to a role with multiple receipients.  (Expand Roles is
        ** turned on.  In these cases use the result that was selected
        ** from the activity that was fetched above.
        */
        WHEN OTHERS THEN
           x_notification_result := x_activity_record.result;
           x_notification_response := 0;
    END;
  /*
    ** If the outcome for locating the RESULT is WF_NOTFOUND, then
    ** check to see if there are any RESPOND attributes other than
    ** RESULT.
    */
    IF x_notification_result = 'WF_NOTFOUND' THEN
       BEGIN
          SELECT count(*)
           INTO   x_notification_response
           FROM   wf_notification_attributes na,
                  wf_message_attributes_vl ma,
                  wf_notifications n
           WHERE  n.group_id = x_notification_id
           AND    n.message_type = ma.message_type
           AND    n.message_name = ma.message_name
           AND    ma.name = na.name
           AND    ma.subtype = 'RESPOND'
           AND    na.notification_id = n.notification_id;
       EXCEPTION
          WHEN OTHERS THEN
             x_notification_response := 0;

       END;
    END IF;

    /*
    ** Determine if the status of the activity has been requested on one of
    ** the checkboxes.  If the x_advanced is set to FALSE then you
    ** know you are calling this function from the main process list and not
    ** the framed list so just show the notifications with responses.
    */
    IF (INSTR(status_options, x_activity_record.activity_status) <> 0 OR
        x_advanced IN ('FALSE', 'FIRST')) THEN

       x_valid_status := TRUE;

    ELSE

       x_valid_status := FALSE;

    END IF;

    /*
    ** Now determine if the activity type matches what was checked in the
    ** activity options checkbox
    */
    x_show_activity := FALSE;

    /*
    ** Show the default list of open or closed notifications as it
    ** had done in the original monitor.  The criteria that the original
    ** monitor had was that the activity be a notification with a result
    ** value and that the notification status was either OPEN or CLOSED
    ** The x_advanced parameter tells the envelope function whether this
    ** is being called from the process list or the advanced query
    ** frame
    */
    IF (x_activity_record.activity_type = 'NOTICE' AND
        x_activity_record.notification_id IS NOT NULL AND
        NVL(x_notification_result,'UNSET') <> 'WF_NOTFOUND' AND
        NVL(x_activity_record.notification_status, 'OTHER') IN ('OPEN', 'CLOSED') AND
        (x_advanced = 'FALSE' OR
         x_advanced = 'FIRST')) THEN

        x_show_activity := TRUE;

    /*
    ** If the notification has a response and the Notification Option
    ** with responses has been checked or if you are in single frame mode
    ** which is the case when you first open the window then show the acitivity or
    ** If you've just started the multi frame mode in which case the x_advanced is
    ** set to FIRST then show the notification
    */
    ELSIF (x_activity_record.activity_type = 'NOTICE' AND
        x_activity_record.notification_id IS NOT NULL AND
        x_notification_response <> 0 AND
        NVL(x_activity_record.notification_status, 'OTHER') IN ('OPEN', 'CLOSED') AND
        x_note_resp IS NOT NULL AND
        (x_advanced = 'TRUE' OR
         x_advanced = 'FIRST')) THEN

        x_show_activity := TRUE;

    ELSIF (x_activity_record.activity_type = 'NOTICE' AND
         x_advanced = 'TRUE' AND x_note_noresp IS NOT NULL AND
         x_notification_response = 0 AND
        (x_activity_record.notification_id IS NULL OR
        NVL(x_notification_result, 'UNSET') = 'WF_NOTFOUND' OR
        NVL(x_activity_record.notification_status, 'OTHER') NOT IN ('OPEN', 'CLOSED'))) THEN

        x_show_activity := TRUE;

    ELSIF (x_activity_record.activity_type IN  ('FUNCTION', 'PROCESS') AND
        x_proc_func IS NOT NULL AND
        x_advanced = 'TRUE') THEN

        x_show_activity := TRUE;

    ELSIF (x_activity_record.activity_type = 'EVENT' AND
        x_event IS NOT NULL AND
        x_advanced = 'TRUE') THEN

        x_show_activity := TRUE;

    /*
    ** Check if you satisfy the show standard activities
    ** checkbox.  If the checkbox is set then we should show all
    ** standard activities.  We later check to see if the checkbox
    ** is not checked and eliminate all standard activities even if
    ** all the other criteria are met.
    */
    ELSIF (x_activity_record.activity_item_type = 'WFSTD' AND
           x_func_std IS NOT NULL) THEN

        x_show_activity := TRUE;

    END IF;

    /*
    ** Check if you satisfy the show standard activities
    ** checkbox.  If the checkbox is not set the don't show
    ** the activity under any circumstances.
    */
    IF (x_activity_record.activity_item_type = 'WFSTD' AND
           x_func_std IS NULL) THEN

        x_show_activity := FALSE;

    END IF;

    /*
    ** If the status of the activity matches the activity filter
    ** checkboxes and the activity options are satisfied then
    ** create the row on the html page.
    */
    IF (x_valid_status = TRUE AND x_show_activity = TRUE) THEN

       htp.tableRowOpen(calign=>'middle');

       /*
       ** If you are viewing the standard activity listing with the
       ** with the notifications with responses then use the DONE column
       ** to tell the user that this notification is completed or not.
       ** If you are viewing the Filtered Activity Listing then show the
       ** status of each activity rather than just if it's done or not
       */
       IF (x_advanced IN ('FIRST', 'TRUE')) THEN

           /*
           ** Get the appropriate icon for the given status
           */
           FOR l_record_num IN G_FIRST_STATUS..G_LAST_STATUS LOOP

             /*
             ** Check for the matching status_code
             */
             IF (x_activity_record.activity_status
                  = l_status_icons_table(l_record_num).status_code) THEN

                 x_icon_name :=l_status_icons_table(l_record_num).icon_file_name;

                 EXIT;

             END IF;

           END LOOP;

           if (x_icon_name = 'FNDIACTV.gif') then
                 htp.tableData(
                 htf.img(wfa_html.image_loc||x_icon_name, 'absmiddle',
                    wf_core.translate('ACTIVE'),
                    null, 'height=26')||
                 '&nbsp;'||
                 x_activity_record.activity_status_display,
                 cattributes=>'id=""');
           elsif (x_icon_name = 'FNDIDONE.gif') then
                 htp.tableData(
                 htf.img(wfa_html.image_loc||x_icon_name, 'absmiddle',
                    wf_core.translate('COMPLETE'),
                    null, 'height=26')||
                 '&nbsp;'||
                 x_activity_record.activity_status_display,
                 cattributes=>'id=""');
           elsif (x_icon_name = 'FNDIREDL.gif') then
                 htp.tableData(
                 htf.img(wfa_html.image_loc||x_icon_name, 'absmiddle',
                    wf_core.translate('ERROR'),
                    null, 'height=26')||
                 '&nbsp;'||
                 x_activity_record.activity_status_display,
                 cattributes=>'id=""');
           else
                 htp.tableData(
                 htf.img(wfa_html.image_loc||x_icon_name, 'absmiddle',
                    wf_core.translate('SUSPEND'),
                    null, 'height=26')||
                 '&nbsp;'||
                 x_activity_record.activity_status_display,
                 cattributes=>'id=""');
            end if;


       /*
       ** If you are still just looking at the notifications list
       ** and you are not in advanced mode then just show a DONE
       ** checkmark if the activity meets the criteria for being
       ** considered completed.
       */
       ELSE

          IF (x_activity_record.activity_status = 'COMPLETE' OR
              NVL(x_activity_record.notification_status, 'OPEN') =
                 'CLOSED') THEN

             htp.tableData(
                htf.img(wfa_html.image_loc||'chckmark.gif', 'absmiddle',
                    wf_core.translate('COMPLETE'), null, 'height=26'),
                    cattributes=>'id=""');

          ELSE

              htp.tableData(htf.br,cattributes=>'id=""');

          END IF;

       END IF;
       /*
       ** If this activity has completed with status of ERROR then set
       ** the font color to red for any column that is not a soft link.
       ** If this activity has not completed in error then the string is
       ** set to null so that the default color is used.
       */
       IF (x_activity_record.activity_status = 'ERROR') THEN

          x_font_color := '<font color=#FF0000>';
          x_font_color_end := '</font>';

       ELSE

          x_font_color := null;
          x_font_color_end := null;

       END IF;

       /*
       ** Check to see if the activity you're about to list is a notification.
       ** If it is a notification then get the full name of the role that
       ** received the notification.
       ** If the activity is a process or a function then then use workflow
       ** engine for the who column.
       */
       IF (x_activity_record.activity_type = 'NOTICE') THEN

          /*
          ** Retrieve role information.  This has to be selected separately
          ** instead of joining into main select so the orig_system_ids can
          ** be used on wf_roles to preserve indexes over the view.
          */
          if (x_activity_record.recipient_role is not null) then
             wf_directory.getroleinfo(x_activity_record.recipient_role,
                role_name, email_address, buf, buf, buf);
          end if;

          /*
          ** Default role info to recipient if role cannot be found
          */
          role_name := nvl(role_name, x_activity_record.recipient_role);
          email_address := nvl(email_address, x_activity_record.recipient_role);

          mlrurl := null;
          if (email_address is not null) then
            mlrurl := 'mailto:'||email_address;
          end if;

       ELSE

          mlrurl := NULL;
          role_name := wf_core.translate('WFMON_WF_ENGINE');

       END IF;

       /*
       ** Create the WHO column.  If the activity is a notification then
       ** the WHO column is based on the role that a notification was sent
       ** to.  If it is any other type of activity then the WHO column is
       ** set to Workflow engine.
       */
       if (mlrurl is not null) then
         htp.tableData(htf.anchor2(mlrurl, role_name, 'anchor_text', '_top'),
                    'Left',cattributes=>'id=""');
       else
         htp.tableData(x_font_color||role_name||x_font_color_end, 'Left',
             cattributes=>'id=""');
       end if;

       /*
       ** Only show the parent activity column if you are showing the
       ** advanced list .  Only create a hotlink in the parent activity
       ** column if the activity is not the ROOT activity.
       */
       IF (x_activity_record.parent_activity_name <> 'ROOT' AND
           x_advanced IN ('FIRST','TRUE')and not (pseudo_login)) THEN

          htp.tableData(
             cvalue=>'<A HREF="'||
                  owa_util.get_owa_service_path||
                  'wf_activities_vl_pub.fetch_draw_activity_details?p_item_type='||
                  wfa_html.conv_special_url_chars(x_item_type)||
                  '&p_activity_type='||
                  'PROCESS'||
                  '&p_effective_date='||
                  TO_CHAR(x_activity_record.begin_date, 'YYYY/MM/DD+HH24:MI:SS')||
                  '&p_name='||
                  wfa_html.conv_special_url_chars(x_activity_record.parent_activity_name)||
                  '" onMouseOver="window.status='||''''||
                  wfa_html.replace_onMouseOver_quotes(wf_core.translate('WFMON_VIEW_ACTIVITY_DETAILS'))||''''||
                  '; return true"'||
                  ' TARGET="_top">'||
                  x_activity_record.parent_display_name||
                  '</A>',
             calign=>'Left', cattributes=>'id=""');

       ELSIF (x_advanced in ('FIRST', 'TRUE')) THEN

            htp.tableData('<BR>', 'Left',cattributes=>'id=""');

       END IF;

       /*
       ** Only create a hotlink in the activity column if this is not a folder
       ** activity type
       */
       IF (x_activity_record.activity_type <> 'FOLDER' and not (pseudo_login)) THEN

          -- add this response to point to the notification detail screen
          -- so that admin/user can response to a notification.
          n_response := null;
          if (x_activity_record.notification_status = 'OPEN') then
            open attrs(x_activity_record.notification_id);
            fetch attrs into result;
            if (attrs%found) then
              n_response :=
                htf.anchor2(curl=>Wfa_Sec.DetailURL(
                                   x_activity_record.notification_id),
                           ctarget=>'_top',
                           ctext=>htf.img(
                                    curl=>wfa_html.image_loc||'reqresp.gif',
                        calt=>wf_core.translate('WFSRV_RECIPIENT_MUST_RESPOND'),
                                    cattributes=>'BORDER=0'));
            end if;
            close attrs;
          end if;

             htp.tableData(
             cvalue=>'<A HREF="'||
                     owa_util.get_owa_service_path||
                     'wf_activities_vl_pub.fetch_draw_activity_details?p_item_type='||
                     wfa_html.conv_special_url_chars(x_activity_record.activity_item_type)||
                     '&p_activity_type='||
                     x_activity_record.activity_type||
                     '&p_effective_date='||
                     TO_CHAR(x_activity_record.begin_date, 'YYYY/MM/DD+HH24:MI:SS')||
                     '&p_name='||
                     wfa_html.conv_special_url_chars(x_activity_record.activity_name)||
                     '" onMouseOver="window.status='||''''||
                     wfa_html.replace_onMouseOver_quotes(wf_core.translate('WFMON_VIEW_ACTIVITY_DETAILS'))||''''||
                     '; return true"'||
                     ' TARGET="_top">'||
                     x_activity_record.activity_display_name||
                     '</A>'||n_response,
             calign=>'Left',cattributes=>'id=""');

       ELSE

          htp.tableData(x_font_color||
              x_activity_record.activity_display_name||
              x_font_color_end, 'Left',cattributes=>'id=""');

       END IF;

       /*
       ** Show the begin date column
       */
       htp.tableData(x_font_color||x_activity_record.begin_date_time||x_font_color_end, 'Left',cattributes=>'id=""');

       /*
       ** The x_activity_record.duration is based on the difference between
       ** the activity end_date or sysdate if the end_date is null minus the
       ** begin_date multiplied by 86400. (The number of seconds in a day.)
       ** Thus the x_activity_record.duration is defined in seconds.  We
       ** then calculate how many days, hours, minutes, and seconds that
       ** equates to.  The duration column is displayed in the most significant
       ** unit plus one lower unit.  Therefore if the the duration is more than
       ** a day the duration would show days and hours.  If the duration was
       ** just over a minute then we would show minutes and seconds.  If it were
       ** just a couple of seconds then thats all we show.
       */
       l_duration_seconds := x_activity_record.duration;
       l_duration_days := TRUNC(l_duration_seconds/86400);
       l_duration_hours :=
          TRUNC((l_duration_seconds - (l_duration_days * 86400))/3600);
       l_duration_minutes :=
          TRUNC((l_duration_seconds - (l_duration_days * 86400) -
             (l_duration_hours * 3600))/60);
       l_duration_seconds :=
          TRUNC(l_duration_seconds - (l_duration_days * 86400) -
             (l_duration_hours * 3600) - (l_duration_minutes * 60));

       IF (l_duration_days > 0) THEN

          x_duration_str :=
             TO_CHAR(l_duration_days)||' '||
                wf_core.translate('WFMON_DAYS')||' '||
             TO_CHAR(l_duration_hours + (ROUND(l_duration_minutes/60)))||' '||
                wf_core.translate('WFMON_HOURS');

       ELSIF (l_duration_hours > 0) THEN

          x_duration_str :=
             TO_CHAR(l_duration_hours)||' '||
                wf_core.translate('WFMON_HOURS')||' '||
             TO_CHAR(l_duration_minutes +(ROUND(l_duration_seconds/60)))||' '||
                wf_core.translate('WFMON_MINUTES');

       ELSIF (l_duration_minutes > 0) THEN

          x_duration_str :=
             TO_CHAR(l_duration_minutes)||' '||
                wf_core.translate('WFMON_MINUTES')||' '||
             TO_CHAR(l_duration_seconds)||' '||
                wf_core.translate('WFMON_SECONDS');

       ELSIF (l_duration_seconds >= 0) THEN

          x_duration_str :=
             TO_CHAR(l_duration_seconds)||' '||
                wf_core.translate('WFMON_SECONDS');


       ELSE

          x_duration_str :=
             '0'||' '||wf_core.translate('WFMON_SECONDS');

       END IF;

       /*
       ** Show the duration string that we just constructed
       */
       htp.tableData(x_font_color||x_duration_str||x_font_color_end,
          'Left',cattributes=>'id=""');

       /*
       ** Show the result column value if the activity is completed or has
       ** exited with an error or its a notification and the notification is
       ** closed.
       */
       if (x_activity_record.activity_status IN ('COMPLETE', 'ERROR') OR
           NVL(x_activity_record.notification_status, 'OPEN') = 'CLOSED') then

         /*
         ** If this is a notification then show the result for that
         ** notification otherwise show the display name for the
         ** activity result
         */
         if (x_activity_record.activity_type = 'NOTICE' AND
             x_notification_result <> 'WF_NOTFOUND') THEN

            x_activity_record.result :=  x_notification_result;

         end if;

         /*
         ** If this is an activity that has exited with an error
         ** then create a hotlink in this column to be able to navigate
         ** to the error view.
         */
         IF (x_activity_record.activity_status = 'ERROR') THEN

            IF NOT (pseudo_login) then
             htp.tableData(
                cvalue=>'<A TARGET="_top" HREF="'||
                        owa_util.get_owa_service_path||
                        'wf_monitor.draw_activity_error?x_item_type='||
                        wfa_html.conv_special_url_chars(x_item_type)||
                        '&x_item_key='||
                        wfa_html.conv_special_url_chars(x_item_key)||
                        '" onMouseOver="window.status='||''''||
                        wfa_html.replace_onMouseOver_quotes(wf_core.translate('WFMON_VIEW_ERROR_DETAILS'))||' '||
                        wfa_html.conv_special_url_chars(x_activity_record.result)||''''||
                        '; return true"'||
                        '>'||
                        x_activity_record.result||
                        '</A>',
                calign=>'Left',
                cattributes=>'id=""');
              ELSE
               htp.tableData(x_font_color||x_activity_record.result||x_font_color_end, 'Left',cattributes=>'id=""');
              END IF;

         ELSE

            IF (x_activity_record.result IS NOT NULL) THEN

               htp.tableData(x_font_color||x_activity_record.result||x_font_color_end, 'Left',cattributes=>'id=""');

            ELSE

               htp.tableData(htf.br,cattributes=>'id=""');

            END IF;

         END IF;

       else

         htp.tableData(htf.br,cattributes=>'id=""');

       end if;

       htp.tableRowClose;

    end if;

  end loop;

  CLOSE x_activity_cursor;

  htp.tableClose;

  htp.p(htf.formHidden('x_item_type', x_item_type));
  htp.p(htf.formHidden('x_item_key', x_item_key));
  htp.p(htf.formHidden('x_admin_mode', x_admin_mode));
  htp.p(htf.formHidden('x_access_key', x_access_key));
  htp.p(htf.formHidden('x_nls_lang', x_nls_lang));

  htp.formClose;

  htp.tableOpen(cattributes=>'border=0 cellpadding=5 cellspacing=0
                       ALIGN=CENTER summary=""');

  htp.tableRowOpen;

  htp.p('<TD ID="">');

  wfa_html.create_reg_button ('javascript:document.envelope.submit()',
                              wf_core.translate ('WFMON_VIEW_DIAGRAM'),
                              wfa_html.image_loc,
                              null,
                              wf_core.translate ('WFMON_VIEW_DIAGRAM'));

  htp.p('</TD>');


  /*
  ** If the envelope function is being called from the main process
  ** window then there will always be FALSE in the activity
  ** options parameter so you want to show the advanced options button.
  */
  IF (x_advanced = 'FALSE') THEN

     htp.p('<FORM NAME="advanced" ACTION="wf_monitor.envelope_frame" METHOD="GET" TARGET="DETAILS">');

     htp.p(htf.formHidden('x_advanced', 'FIRST'));
     htp.p(htf.formHidden('x_item_type', x_item_type));
     htp.p(htf.formHidden('x_item_key', x_item_key));
     htp.p(htf.formHidden('x_admin_mode', x_admin_mode));
     htp.p(htf.formHidden('x_access_key', x_access_key));
     htp.p(htf.formHidden('x_active','ACTIVE'));
     htp.p(htf.formHidden('x_complete','COMPLETE'));
     htp.p(htf.formHidden('x_error','ERROR'));
     htp.p(htf.formHidden('x_suspend','SUSPEND'));
     htp.p(htf.formHidden('x_proc_func',null));
     htp.p(htf.formHidden('x_note_resp','Y'));
     htp.p(htf.formHidden('x_note_noresp',null));
     htp.p(htf.formHidden('x_func_std',null));
     htp.p(htf.formHidden('x_event',null));
     htp.p(htf.formHidden('x_sort_column','STARTDATE'));
     htp.p(htf.formHidden('x_sort_order', 'ASC'));
     htp.p(htf.formHidden('x_nls_lang', x_nls_lang));


     htp.p('<TD ID="">');

     wfa_html.create_reg_button ('javascript:document.advanced.submit()',
                                 wf_core.translate ('WFMON_REPORT_OPTIONS'),
                                 wfa_html.image_loc,
                                 null,
                                 wf_core.translate ('WFMON_REPORT_OPTIONS'));

     htp.p('</TD>');

     htp.formClose;

  END IF;

  htp.tableRowClose;

  htp.tableClose;

  wfa_sec.footer;

  htp.htmlClose;

exception
  when others then
    Wf_Core.Context('Wf_Monitor', 'Envelope_Frame', x_item_type, x_item_key);
    Error;
end envelope_frame;

-- MODIFICATION LOG:
-- 06-JUN-2001 JWSMITH BUG 1819232 -Added summary attr for table tag for ADA
--
procedure draw_activity_error (
 x_item_type IN VARCHAR2,
 x_item_key  IN VARCHAR2
) IS

CURSOR fetch_errors (c_item_type VARCHAR2,
                     c_item_key  VARCHAR2) IS
select  ac.display_name,
        wf_core.activity_result(ac.result_type, ias.activity_result_code) result,
        ias.error_name,
        ias.error_message,
        ias.error_stack
from    wf_item_activity_statuses ias,
        wf_process_activities pa,
        wf_activities_vl ac,
        wf_activities_vl ap,
        wf_items i
where   ias.item_type = c_item_type
and     ias.item_key  = c_item_key
and     ias.activity_status     = 'ERROR'
and     ias.process_activity    = pa.instance_id
and     pa.activity_name        = ac.name
and     pa.activity_item_type   = ac.item_type
and     pa.process_name         = ap.name
and     pa.process_item_type    = ap.item_type
and     pa.process_version      = ap.version
and     i.item_type             = c_item_type
and     i.item_key              = ias.item_key
and     i.begin_date            >= ac.begin_date
and     i.begin_date            < nvl(ac.end_date, i.begin_date+1)
order by ias.begin_date, ias.execution_time;

l_title          VARCHAR2(240) := wf_core.translate ('WFMON_ERROR_TITLE');
username varchar2(320);

BEGIN

  /*
  ** Create the  Window title
  */
  htp.htmlOpen;
  htp.headOpen;
  htp.title(l_title);
  wfa_html.create_help_function('wf/links/wfm.htm?WFMON');

  -- call getsession to set context else header will print
  -- differently in apps.

  wfa_sec.GetSession(username);

  /*
  ** Open body and draw standard header
  */
  wfa_sec.header;

  htp.p('</BODY><BR>');

  /*
  ** Draw the section title for the lookup detail section
  */
  wf_item_definition_util_pub.draw_detail_section_title (
     l_title,
     0);


  FOR l_error_rec IN fetch_errors(x_item_type, x_item_key) LOOP

     /*
     ** Open a new table for each lookup so you can control the spacing
     ** between each attribute
     */
     htp.tableOpen(cattributes=>'border=0 cellpadding=0 cellspacing=0
                       summary=""');

     wf_item_definition_util_pub.draw_detail_prompt_value_pair (
        wf_core.translate('WFMON_ACTIVITY'),
        l_error_rec.display_name);

     wf_item_definition_util_pub.draw_detail_prompt_value_pair (
        wf_core.translate('WFMON_RESULT'),
        l_error_rec.result);

     wf_item_definition_util_pub.draw_detail_prompt_value_pair (
        wf_core.translate('WFMON_ERROR_NAME'),
        l_error_rec.error_name);

     wf_item_definition_util_pub.draw_detail_prompt_value_pair (
        wf_core.translate('WFMON_ERROR_MESSAGE'),
        l_error_rec.error_message);

     wf_item_definition_util_pub.draw_detail_prompt_value_pair (
        wf_core.translate('WFMON_ERROR_STACK'),
        l_error_rec.error_stack);

     /*
     ** Table is created so close it out
     */
     htp.tableClose;

  END LOOP;

exception
  when others then
    Wf_Core.Context('Wf_Monitor', 'Draw_Activity_Error', x_item_type, x_item_key);
    Error;

END draw_activity_error;


procedure get_process_children (
p_parent_item_type IN VARCHAR2,
p_parent_item_key  IN VARCHAR2,
p_child_item_list  OUT NOCOPY wf_monitor.wf_items_tbl_type,
p_number_of_children OUT NOCOPY NUMBER) IS

cursor c_get_process_children IS
SELECT item_type,
       item_key,
       root_activity,
       root_activity_version,
       user_key,
       owner_role,
       begin_date,
       end_date
FROM   wf_items
WHERE  parent_item_type = p_parent_item_type
AND    parent_item_key  = p_parent_item_key;

l_record_num   NUMBER := 0;

BEGIN

    OPEN c_get_process_children;

    /*
    ** Loop through all the lookup_code rows for the given lookup_type
    ** filling in the p_wf_lookups_tbl
    */
    LOOP

       l_record_num := l_record_num + 1;

       FETCH c_get_process_children INTO
             p_child_item_list (l_record_num);

       EXIT WHEN c_get_process_children%NOTFOUND;

    END LOOP;

    CLOSE c_get_process_children;
    p_number_of_children := l_record_num - 1;


exception
  when no_data_found THEN
     CLOSE c_get_process_children;
     p_number_of_children := 0;
     return;
  when others then
    Wf_Core.Context('Wf_Monitor', 'get_process_children',
           p_parent_item_type, p_parent_item_key);
    Error;

END get_process_children;

procedure draw_process_children (
p_parent_item_type IN VARCHAR2,
p_parent_item_key  IN VARCHAR2,
p_admin_mode       IN VARCHAR2,
p_indent_level     IN NUMBER,
p_nls_lang         IN VARCHAR2) IS

username              VARCHAR2(320);
access_key            VARCHAR2(240);
l_child_item_list     wf_monitor.wf_items_tbl_type;
l_number_of_children  NUMBER :=0;
l_record_num          NUMBER := 0;
ii                    NUMBER := 0;
l_indent_str          VARCHAR2(240) := NULL;
l_item_type_disp_name VARCHAR2(80);

BEGIN

  access_key := GetAccessKey(p_parent_item_type, p_parent_item_key, p_admin_mode);

   /*
   ** Get the display name for the item type
   */
   BEGIN

   SELECT display_name
   INTO   l_item_type_disp_name
   FROM   wf_item_types_vl
   WHERE  name = p_parent_item_type;

   exception
   when no_data_found THEN
      l_item_type_disp_name := NULL;
   when others THEN
      raise;

   END;

   /*
   ** Create the indent string
   */
   for ii in 1..p_indent_level LOOP

      l_indent_str := l_indent_str || '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';

   END LOOP;

   /*
   ** Create the link for the current item
   */
   htp.tableRowOpen;
   htp.p ('<TD ID="" NOWRAP>');

   htp.p ('<FONT SIZE=-1>');

   htp.p(l_indent_str||'<A HREF="'||
         wfa_html.base_url||
         '/wf_monitor.envelope_frame'||
         '?'||'x_item_type=' ||wfa_html.conv_special_url_chars(p_parent_item_type)||
         '&'||'x_item_key='  ||wfa_html.conv_special_url_chars(p_parent_item_key)||
         '&'||'x_admin_mode='||p_admin_mode||
         '&'||'x_access_key='||access_key||
         '&'||'x_advanced=FALSE'||
         '&'||'x_nls_lang='||p_nls_lang||
     '" TARGET="DETAILS">'||
     l_item_type_disp_name||' - '||p_parent_item_key||'</A>');

   htp.p ('</FONT>');

   htp.tableRowClose;
   htp.p ('</TD>');

   /*
   ** Get the process children for this row
   */
   wf_monitor.get_process_children(p_parent_item_type,
                                   p_parent_item_key,
                                   l_child_item_list,
                                   l_number_of_children);


   /*
   ** Loop through the children and print their children recursively
   */
   FOR l_record_num IN 1..l_number_of_children LOOP

       wf_monitor.draw_process_children (l_child_item_list(l_record_num).item_type,
                                         l_child_item_list(l_record_num).item_key,
                                         p_admin_mode,
                                         p_indent_level+1,
                                         p_nls_lang);

   END LOOP;

exception
  when others then
    Wf_Core.Context('Wf_Monitor', 'draw_process_children',
           p_parent_item_type, p_parent_item_key,
           p_admin_mode , p_indent_level, p_nls_lang);

    Error;

END draw_process_children;

-- MODIFICATION LOG:
-- 06-JUN-2001 JWSMITH BUG 1819232 - Added summary attr for table tag for ADA
--
procedure process_children (
x_item_type        IN VARCHAR2,
x_item_key         IN VARCHAR2,
x_admin_mode       IN VARCHAR2,
x_nls_lang         IN varchar2) IS
BEGIN

   wfa_sec.header(background_only=>TRUE);

   htp.tableopen(cattributes=>'summary=""');

   wf_monitor.draw_process_children (x_item_type,
                                     x_item_key,
                                     x_admin_mode,
                                     0,x_nls_lang);


   htp.tableclose;

   wfa_sec.footer;

exception
  when others then
    Wf_Core.Context('Wf_Monitor', 'process_children',
           x_item_type, x_item_key);
    Error;

END process_children;


function getDiagramDataURL(
   p_item_type in varchar2,
   p_item_key in varchar2,
   p_admin_mode in varchar2,
   p_access_key in varchar2,
   p_lang_code in varchar2
)
return varchar2
is
   l_url_value varchar2(2000);
   l_func varchar2(2000);
   l_params varchar2(1000);
begin

   l_params := 'itemType='||p_item_type||
              '&'||'itemKey='||p_item_key||
              '&'||'adminMode='||p_admin_mode||
              '&'||'accessKey='||p_access_key||'&retainAM=Y';

   l_func := fnd_run_function.get_run_function_url(
               p_function_name =>'WF_MONITOR_DIAGRAM_DATA',
               p_resp_appl => null,
               p_resp_key => null,
               p_security_group_key => null,
               p_parameters => l_params,
               p_override_agent => null,
               p_encryptParameters => false);

   return l_func;
end getDiagramDataURL;

function getDiagramResourceURL return varchar2
is
   l_func varchar2(4000);
begin
   l_func := fnd_run_function.get_run_function_url(
                p_function_name =>'WF_MONITOR_RES',
                p_resp_appl => null,
                p_resp_key => null,
                p_security_group_key => null,
                p_parameters => 'retainAM=Y',
                p_override_agent => null,
                p_encryptParameters => false );

  return l_func;
end getDiagramResourceURL;

function getDiagramResourcesURL return varchar2
is
   l_func varchar2(4000);
   p_resType varchar2(10) := 'WFTKN';
   p_resPattern varchar2(10) := 'WFMON';
   l_params varchar2(2000);
begin
   l_params := 'resType='||p_resType||
              '&'||'resPattern='||p_resPattern||'&retainAM=Y';

   l_func := fnd_run_function.get_run_function_url(
                p_function_name =>'WF_MONITOR_CRES_DATA',
                p_resp_appl => null,
                p_resp_key => null,
                p_security_group_key => null,
                p_parameters => l_params,
                p_override_agent => null,
                p_encryptParameters => false );

  return l_func;
end getDiagramResourcesURL;

--   Sends back a very simple dynamic HTML page to tell the browser what
--   applet to run.
-- IN
--   x_item_type
--   x_item_key
--   x_admin_mode
function createapplettags(
    x_item_type  in varchar2,
    x_item_key   in varchar2,
    x_admin_mode in varchar2,
    x_access_key in varchar2,
    x_nls_lang   in varchar2,
    x_browser    in varchar2) return varchar2 is

 lang_codeset varchar2(50);
 l_code varchar2(80) :=  'oracle.apps.fnd.wf.Monitor';
 l_archive varchar2(2000);      -- first look for java classes at this archive
 l_wf_plugin_download varchar2(80);
 l_wf_plugin_version varchar2(80);
 l_wf_classid varchar2(80);
 l_ie_plugin_ver varchar2(80);  -- IE version is delimited by ','
 l_admin varchar(4) := 'no';
 l_installType varchar2(30) := 'EMBEDDED';
 l_java_loc VARCHAR2(80) := '/OA_JAVA/';
 l_return_buffer varchar2(32000) := '';
 username varchar2(320);
 admin_role varchar2(320);
 l_apps_fwk_agent varchar2(2000);
 l_data_url varchar2(4000);
 l_res_url varchar2(2000);
 l_ress_url varchar2(4000);

begin

   lang_codeset := substr(userenv('LANGUAGE'),instr(userenv('LANGUAGE'),'.')+1,
                         length(userenv('LANGUAGE')));

   -- this portion of the code wil not be executed now as this API is called
   -- with x_admin_mode = 'N' all the time.

   if (upper(substr(x_admin_mode, 1, 1)) = 'Y') then
      -- wfa_sec.GetSession commented out for the time being. we need to
      -- reimplement this in Framework in the future
      -- wfa_sec.GetSession(username);
      -- Security checking
      admin_role := wf_core.Translate('WF_ADMIN_ROLE');
      if (admin_role <> '*')  then
         if (wf_directory.IsPerformer(username, admin_role)) then
            l_admin := 'yes';
         end if;
      else
         -- no security. Eveybody is admin
         l_admin := 'yes';
      end if;
   end if;

   l_apps_fwk_agent :=  fnd_web_config.trail_slash(fnd_profile.value('APPS_FRAMEWORK_AGENT'));
   l_data_url := getDiagramDataURL(x_item_type, x_item_key, l_admin, x_access_key, lang_codeset);
   l_res_url := getDiagramResourceURL();
   l_ress_url := getDiagramResourcesUrl();


   if ( x_browser = 'WIN') then

      l_archive := '/OA_JAVA/oracle/apps/fnd/jar/wfmon.jar, ' ||
                   '/OA_JAVA/oracle/apps/fnd/jar/fndewt.jar, ' ||
                   '/OA_JAVA/oracle/apps/fnd/jar/fndswing.jar, ' ||
                   '/OA_JAVA/oracle/apps/fnd/jar/fndbalishare.jar, ' ||
                   '/OA_JAVA/oracle/apps/fnd/jar/fndctx.jar';

      l_wf_plugin_download := Wf_Core.translate('WF_PLUGIN_DOWNLOAD');
      l_wf_plugin_version := Wf_Core.translate('WF_PLUGIN_VERSION');
      l_wf_classid := Wf_Core.translate('WF_CLASSID');
      l_ie_plugin_ver := replace(Wf_Core.translate('WF_PLUGIN_VERSION'), '.', ',');

       l_return_buffer := l_return_buffer ||
             '<OBJECT classid="clsid:'||l_wf_classid||'" '||
             'WIDTH=100% HEIGHT=400 '||
             'CODEBASE="'||l_wf_plugin_download||
             '#Version='||l_ie_plugin_ver||'">'||
           '<PARAM NAME="jinit_appletcache" VALUE="off">'||
           '<PARAM NAME="CODE"     VALUE="'||l_code||'">'||
           '<PARAM NAME="CODEBASE" VALUE="'||'/OA_JAVA/'||'">'||
           '<PARAM NAME="ARCHIVE"  VALUE="'||l_archive||'">' ||
           '<PARAM NAME="itemtype"  VALUE="'||x_item_type||'">' ||
           '<PARAM NAME="itemkey"  VALUE="'||x_item_key||'">' ||
           '<PARAM NAME="docbase"  VALUE="'|| l_apps_fwk_agent || '">' ||
           '<PARAM NAME="langcodeset"  VALUE="'||lang_codeset||'">' ||
           '<PARAM NAME="accesskey"  VALUE="'||x_access_key||'">' ||
           '<PARAM NAME="admin"  VALUE="'||l_admin||'">' ||
           '<PARAM NAME="dataUrl"  VALUE="'||l_data_url||'">' ||
           '<PARAM NAME="resUrl"  VALUE="'||l_res_url||'">' ||
           '<PARAM NAME="ressUrl"  VALUE="'||l_ress_url||'">' ||
           '<PARAM NAME="type"     VALUE="'||
                        'application/x-jinit-applet;version='||
                        l_wf_plugin_version||'">' ||
           '<PARAM NAME="installType"  VALUE="' || l_installType || '">';

       l_return_buffer := l_return_buffer ||
             '<COMMENT>'||
             '<EMBED type="application/x-jinit-applet;version='||
               l_wf_plugin_version||'"'||
             ' WIDTH="100%" HEIGHT="90%"'||
             ' jinit_appletcache="off"'||
             ' java_CODE="'||l_code||'"'||
             ' java_CODEBASE="'||l_java_loc||'"'||
             ' java_ARCHIVE="'||l_archive||'"'||
             ' itemtype="'||x_item_type||'"' ||
             ' itemkey="'||x_item_key||'"' ||
             ' langcodeset="'||lang_codeset||'"' ||
             ' accesskey="'||x_access_key||'"' ||
             ' admin="'||l_admin||'"' ||
             ' dataUrl="'||l_data_url||'"' ||
             ' resUrl="'||l_res_url||'"' ||
             ' ressUrl="'||l_ress_url||'"' ||
             ' pluginurl="'|| l_wf_plugin_download||'"' ||
             ' installType="' || l_installType || '">'||
             '<NOEMBED></COMMENT></NOEMBED></EMBED></OBJECT>';
    else

     -- Client is not Windows, so we don't want to call Jinitiator.
      l_return_buffer := l_return_buffer ||
        '<applet code=oracle.apps.fnd.wf.Monitor.class codebase="/OA_JAVA"';

      l_archive :=  '/OA_JAVA/oracle/apps/fnd/jar/wfmon.jar, ' ||
                    '/OA_JAVA/oracle/apps/fnd/jar/fndewt.jar, ' ||
                    '/OA_JAVA/oracle/apps/fnd/jar/fndswing.jar, ' ||
                    '/OA_JAVA/oracle/apps/fnd/jar/fndbalishare.jar, ' ||
                    '/OA_JAVA/oracle/apps/fnd/jar/fndctx.jar';

      l_return_buffer := l_return_buffer ||
        ' archive="' || l_archive || '"';

      l_return_buffer := l_return_buffer ||
         ' width=800 height=400> '||
         ' <param name=itemtype value="' || x_item_type || '">' ||
         ' <param name=itemkey value="' || x_item_key || '">'||
         ' <param name=langcodeset value="' || lang_codeset || '">' ||
         ' <param name=docbase value="' || l_apps_fwk_agent || '">' ||
         ' <param name=admin value="' || l_admin || '">' ||
         ' <param name=accesskey value="' || x_access_key || '">' ||
         ' <param name="dataUrl"  value="'||l_data_url||'">' ||
         ' <param name="resUrl"  value="'||l_res_url||'">' ||
         ' <param name="ressUrl"  value="'||l_ress_url||'">' ||
         ' <param name=installType value="' || l_installType || '">' ||
         ' </applet>';

    end if;

    return l_return_buffer;

end createapplettags;

end WF_MONITOR;

/
