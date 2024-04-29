--------------------------------------------------------
--  DDL for Package Body WF_DIAGNOSTICS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_DIAGNOSTICS" as
/* $Header: WFDIAGPB.pls 120.14.12010000.2 2010/03/23 12:56:40 skandepu ship $ */

-- Table attributes in line with BLAF standards
table_width  varchar2(8) := '100%';
table_border varchar2(2) := '0';
table_bgcolor varchar2(7) := 'white';

-- Header attributes
th_bgcolor varchar2(7) := wf_mail.g_th_bgcolor;
th_fontcolor varchar2(7) := wf_mail.g_th_fontcolor;
th_fontface varchar2(80) := wf_mail.g_th_fontface;
th_fontsize varchar2(2) := wf_mail.g_th_fontsize;

-- Cell attributes
td_bgcolor varchar2(7) := wf_mail.g_td_bgcolor;
td_fontcolor varchar2(7) := wf_mail.g_td_fontcolor;
td_fontface varchar2(80) := wf_mail.g_td_fontface;
td_fontsize varchar2(2) := wf_mail.g_td_fontsize;

-- Header
g_head varchar2(50) := '<html><body>';
g_end  varchar2(50) := '</body></html>';

-- Temp CLOB
l_temp CLOB;

-- Queue owner
g_qowner varchar2(30) := Wf_Core.Translate('WF_SCHEMA');

-- Queue name constants
WFD_NTF_OUT  varchar2(30) := 'WF_NOTIFICATION_OUT';
WFD_NTF_IN   varchar2(30) := 'WF_NOTIFICATION_IN';
WFD_DEFERRED varchar2(30) := 'WF_DEFERRED';
WFD_ERROR    varchar2(30) := 'WF_ERROR';
WFD_PROV_OUT varchar2(30) := 'WF_PROV_OUT';
WFD_PROV_IN  varchar2(30) := 'WF_PROV_IN';
WFD_JAVA_DEFERRED varchar2(30) := 'WF_JAVA_DEFERRED';
WFD_JAVA_ERROR    varchar2(30) := 'WF_JAVA_ERROR';

--
-- Get_Table
--   Implemented from WF_NOTIFICATION.NTF_Table procedure.
--   Returns a Vertical or Horizontal Headered table

procedure Get_Table(p_cells   in tdType,
                    p_cols    in pls_integer,
                    p_dir     in varchar2,
                    p_table   in out nocopy varchar2)
is
  l_table_width   varchar2(8);
  l_table_border  varchar2(1);
  l_table_bgcolor varchar2(7);
  l_th_bgcolor    varchar2(7);
  l_th_fontcolor  varchar2(7);
  l_th_fontface   varchar2(80);
  l_th_fontsize   varchar2(2);
  l_td_bgcolor    varchar2(7);
  l_td_fontcolor  varchar2(7);
  l_td_fontface   varchar2(80);
  l_td_fontsize   varchar2(2);
  i               pls_integer;
  l_mod           pls_integer;
  l_colon         pls_integer;
  l_width         varchar2(10);
  l_text          varchar2(4000);
  l_table         varchar2(32000);
  l_rowcolor      varchar2(10);
begin

  l_table_width  := table_width;
  l_table_border := table_border;
  l_table_bgcolor:= table_bgcolor;
  l_th_bgcolor   := th_bgcolor;
  l_th_fontcolor := th_fontcolor;
  l_th_fontface  := th_fontface;
  l_th_fontsize  := th_fontsize;
  l_td_bgcolor   := td_bgcolor;
  l_td_fontcolor := td_fontcolor;
  l_td_fontface  := td_fontface;
  l_td_fontsize  := td_fontsize;

  if (p_cells.COUNT = 0) then
     p_table := null;
     return;
  end if;

  l_table := '<table width='||l_table_width||
            ' border='||l_table_border||
            ' bgcolor='||l_table_bgcolor||'>';

  if (p_cells.COUNT = 1) then
    l_rowcolor := substr(p_cells(1), 1, 3);
    l_text := substr(p_cells(1), 4);
    if (l_rowcolor = 'TD:') then
      l_table := l_table||'<tr><td bgcolor='||l_td_bgcolor||'><font color='||l_td_fontcolor||
                        ' face="'||l_td_fontface||'"'||' size='||l_td_fontsize||'>'||
                        l_text||'</font></td></tr>';
    else
      l_table := l_table||'<tr><td><font color='||l_td_fontcolor||' face="'||l_td_fontface||'"'||
                          ' size='||l_td_fontsize||'>'||l_text||'</font></td></tr>';
    end if;
  else
    for i in 1..p_cells.LAST loop
      l_mod := mod(i, p_cols);
      if (l_mod = 1) then
        l_table := l_table || '<tr>';
      end if;

      l_text := p_cells(i);
      if ((p_dir = 'V' and l_mod = 1) or (p_dir = 'H' and i <= p_cols)) then
        l_colon := instr(l_text,':');
        l_width := substr(l_text, 1, l_colon-1);
        l_text  := substr(l_text, l_colon+1);
        l_table := l_table||wf_core.newline||'<th align=left';

        if (l_width is not null) then
          l_table := l_table||' width='||l_width;
        end if;
        l_table := l_table||' bgcolor='||l_th_bgcolor||'>';
        l_table := l_table||'<font color='||l_th_fontcolor||' face="'||l_th_fontface||'"'
                          ||' size='||l_th_fontsize||'>';
        l_table := l_table|| l_text||'</font>';
        l_table := l_table||'</th>';
      else
        l_table := l_table||wf_core.newline||'<td';
        l_table := l_table||' bgcolor='||l_td_bgcolor||'>';
        l_table := l_table||'<font color='||l_td_fontcolor||' face="'||l_td_fontface||'"'
                          ||' size='||l_td_fontsize||'>';
        l_table := l_table||l_text||'</font></td>';
      end if;

      if (l_mod = 0) then
        l_table := l_table||'</tr>';
      end if;
    end loop;
  end if;
  l_table := l_table || '</table>';
  p_table := l_table;
  return;
exception
  when others then
     wf_core.context('WF_DIAGNOSTICS', 'Get_Table', 'Varchar2 Table');
     raise;
end Get_Table;

--
-- Get_Table
--   Implemented from WF_NOTIFICATION.NTF_Table procedure.
--   Returns a Vertical or Horizontal Headered table

procedure Get_Table(p_cells   in tdType,
                    p_cols    in pls_integer,
                    p_dir     in varchar2,
                    p_table   in out nocopy CLOB)
is
  l_table_width   varchar2(8);
  l_table_border  varchar2(1);
  l_table_bgcolor varchar2(7);
  l_th_bgcolor    varchar2(7);
  l_th_fontcolor  varchar2(7);
  l_th_fontface   varchar2(80);
  l_th_fontsize   varchar2(2);
  l_td_bgcolor    varchar2(7);
  l_td_fontcolor  varchar2(7);
  l_td_fontface   varchar2(80);
  l_td_fontsize   varchar2(2);

  i               pls_integer;
  l_mod           pls_integer;
  l_colon         pls_integer;
  l_width         varchar2(10);
  l_text          varchar2(4000);
  l_table         varchar2(32000);
  l_rowcolor      varchar2(10);
begin

  l_table_width   := table_width;
  l_table_border  := table_border;
  l_table_bgcolor := table_bgcolor;
  l_th_bgcolor    := th_bgcolor;
  l_th_fontcolor  := th_fontcolor;
  l_th_fontface   := th_fontface;
  l_th_fontsize   := th_fontsize;
  l_td_bgcolor    := td_bgcolor;
  l_td_fontcolor  := td_fontcolor;
  l_td_fontface   := td_fontface;
  l_td_fontsize   := td_fontsize;

  if (p_cells.COUNT = 0) then
     p_table := null;
     return;
  end if;

  l_table := '<table width='||l_table_width||
            ' border='||l_table_border||
            ' bgcolor='||l_table_bgcolor||'>';

  if (p_cells.COUNT = 1) then
    l_rowcolor := substr(p_cells(1), 1, 3);
    l_text := substr(p_cells(1), 4);
    if (l_rowcolor = 'TD:') then
       l_table := l_table||'<tr><td bgcolor='||l_td_bgcolor||'><font color='||l_td_fontcolor||
                        ' face="'||l_td_fontface||'"'||' size='||l_td_fontsize||'>'||
                        l_text||'</font></td></tr>';
    else
       l_table := l_table||'<tr><td><font color='||l_td_fontcolor||' face="'||l_td_fontface||'"'||
                        ' size='||l_td_fontsize||'>'||l_text||'</font></td></tr>';
    end if;
  else
    for i in 1..p_cells.LAST loop
      l_mod := mod(i, p_cols);
      if (l_mod = 1) then
        l_table := l_table || '<tr>';
      end if;

      l_text := p_cells(i);
      if ((p_dir = 'V' and l_mod = 1) or (p_dir = 'H' and i <= p_cols)) then
        l_colon := instr(l_text,':');
        l_width := substr(l_text, 1, l_colon-1);
        l_text  := substr(l_text, l_colon+1);
        l_table := l_table||wf_core.newline||'<th align=left';

        if (l_width is not null) then
          l_table := l_table||' width='||l_width;
        end if;
        l_table := l_table||' bgcolor='||l_th_bgcolor||'>';
        l_table := l_table||'<font color='||l_th_fontcolor||' face="'||l_th_fontface||'"'
                          ||' size='||l_th_fontsize||'>';
        l_table := l_table|| l_text||'</font>';
        l_table := l_table||'</th>';
      else
        l_table := l_table||wf_core.newline||'<td';
        l_table := l_table||' bgcolor='||l_td_bgcolor||'>';
        l_table := l_table||'<font color='||l_td_fontcolor||' face="'||l_td_fontface||'"'
                          ||' size='||l_td_fontsize||'>';
        l_table := l_table||l_text||'</font></td>';
      end if;

      if (l_mod = 0) then
        l_table := l_table||'</tr>';
      end if;
      dbms_lob.WriteAppend(p_table, length(l_table), l_table);
      l_table := '';
    end loop;
  end if;
  l_table := '</table>';
  dbms_lob.WriteAppend(p_table, length(l_table), l_table);
  return;
exception
  when others then
     wf_core.context('WF_DIAGNOSTICS', 'Get_Table', 'CLOB Table');
     raise;
end Get_Table;

--
-- Get_Ntf_Item_Info - <Explained in WFDIAGPS.pls>
--
function Get_Ntf_Item_Info(p_nid in number)
return varchar2
is
  l_result varchar2(32000);
  l_temp   varchar2(32000);
  cursor c_ntf is
  select notification_id nid,
         message_type msg_type,
         message_name msg_name,
         begin_date,
         end_date,
         recipient_role rec_role,
         more_info_role more_role,
         status stat,
         mail_status m_stat,
         callback cb,
         context ctx,
	 responder resp,
	 subject subj
   from   wf_notifications
   where  notification_id = p_nid;

   l_ntf_rec c_ntf%rowtype;
   l_cells tdType;
   l_role     varchar2(320);
   l_dname    varchar2(360);
   l_email    varchar2(320);
   l_npref    varchar2(8);
   l_lang     varchar2(30);
   l_terr     varchar2(30);
   l_orig_sys varchar2(30);
   l_orig_id  number;
   l_install  varchar2(1);
   doctype    varchar(30) := WF_NOTIFICATION.doc_html;

begin
   l_cells(1) := 'WH:<b>Notification Item Information</b>';
   Get_table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;

   l_cells(1) := 'Notification Id';
   l_cells(2) := 'Message Type';
   l_cells(3) := 'Message Name';
   l_cells(4) := 'Fwk Content';
   l_cells(5) := 'Begin Date';
   l_cells(6) := 'End Date';
   l_cells(7) := 'Recipient Role';
   l_cells(8) := 'More Info Role';
   l_cells(9) := 'Status';
   l_cells(10) := 'Mail Status';
   l_cells(11) := 'Call back';
   l_cells(12) := 'Context';
   l_cells(13) := 'Responder';
   l_cells(14) := 'Subject';


   open c_ntf;
   fetch c_ntf into l_ntf_rec;
   l_cells(15) := l_ntf_rec.nid;
   l_cells(16) := l_ntf_rec.msg_type;
   l_cells(17) := l_ntf_rec.msg_name;
   -- Begin bug#5529150
   -- Get role from current cursure
   l_role := l_ntf_rec.rec_role;
   -- get Role's preferences
   Wf_Directory.GetRoleInfoMail(l_role, l_dname, l_email, l_npref, l_lang, l_terr,
                                l_orig_sys, l_orig_id, l_install);

   -- Set the document type based on the notification preference.
   if l_npref = 'MAILTEXT' then
     doctype := WF_NOTIFICATION.doc_text;
   elsif l_npref in ('MAILHTML', 'MAILHTM2', 'MAILATTH') then
    doctype := WF_NOTIFICATION.doc_html;
   end if;

   l_cells(18) :=  WF_NOTIFICATION.isFwkRegion(p_nid, doctype);
   -- l_cells(18) := Wf_Notification.IsFwkBody(p_nid);
   -- End bug 5529150

   l_cells(19) := to_char(l_ntf_rec.begin_date, 'DD-MON-YYYY HH24:MI:SS');
   l_cells(20) := to_char(l_ntf_rec.end_date, 'DD-MON-YYYY HH24:MI:SS');
   l_cells(21) := l_ntf_rec.rec_role;
   l_cells(22) := l_ntf_rec.more_role;
   l_cells(23) := l_ntf_rec.stat;
   l_cells(24) := l_ntf_rec.m_stat;
   l_cells(25) := l_ntf_rec.cb;
   l_cells(26) := l_ntf_rec.ctx;
   l_cells(27) := l_ntf_rec.resp;
   l_cells(28) := l_ntf_rec.subj;

   close c_ntf;

   Get_Table(l_cells, 14, 'H', l_temp);
   l_result := l_result || l_temp;
   return l_result;
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when generating Notification Item Information for nid '||p_nid;
      l_cells(3) := '10%:Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      return l_result;
end Get_Ntf_Item_Info;

--
-- Get_Ntf_Role_Users - <Explained in WFDIAGPS.pls>
--
function Get_Ntf_Role_Users(p_nid in number)
return varchar2
is
   l_result varchar2(32000);
   l_temp   varchar2(32000);

   CURSOR user_curs IS
   SELECT wur.user_name
   FROM   wf_user_roles wur, wf_notifications wn
   WHERE  wur.role_name = wn.recipient_role
   AND    wn.notification_id = p_nid;

   l_cells tdType;
   i pls_integer;

   l_role     varchar2(320);
   l_dname    varchar2(360);
   l_email    varchar2(320);
   l_npref    varchar2(8);
   l_lang     varchar2(30);
   l_terr     varchar2(30);
   l_orig_sys varchar2(30);
   l_orig_id  number;
   l_install  varchar2(1);
begin
   l_cells(1) := 'WH:<b>Notification Recipient Role Members</b>';
   Get_table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;

   l_cells(1) := '15%:User Name';
   l_cells(2) := '20%:Display Name';
   l_cells(3) := '25%:Email Address';
   l_cells(4) := '10%:Notification Pref';
   l_cells(5) := '5%:Language';
   l_cells(6) := '10%:Territory';
   l_cells(7) := '10%:Orig Sys';
   l_cells(8) := '5%:Orig Sys Id';
   l_cells(9) := '5%:Installed';
   i := 9;

   for l_rec in user_curs loop
      Wf_Directory.GetRoleInfoMail(l_rec.user_name, l_dname, l_email, l_npref,
                                   l_lang, l_terr, l_orig_sys, l_orig_id, l_install);
      l_cells(i+1) := l_rec.user_name;
      l_cells(i+2) := l_dname;
      l_cells(i+3) := l_email;
      l_cells(i+4) := l_npref;
      l_cells(i+5) := l_lang;
      l_cells(i+6) := l_terr;
      l_cells(i+7) := l_orig_sys;
      l_cells(i+8) := l_orig_id;
      l_cells(i+9) := l_install;
      i := i+9;
   end loop;
   Get_Table(l_cells, 9, 'H', l_temp);
   l_result := l_result || l_temp;
   return l_result;
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when generating Notification Recipient Role Members Information for nid '||p_nid;
      l_cells(3) := '10%:Error';
      if (wf_core.error_name is null) then
         l_cells(4) := sqlerrm;
      else
         l_cells(4) := wf_core.error_name;
      end if;
      Get_Table(l_cells, 2, 'V', l_result);
      return l_result;
end Get_Ntf_Role_Users;

--
-- Get_Ntf_Role_Info - <Explained in WFDIAGPS.pls>
--
function Get_Ntf_Role_Info(p_nid in number)
return varchar2
is
   l_result   varchar2(32000);
   l_temp     varchar2(32000);
   l_role     varchar2(320);
   l_dname    varchar2(360);
   l_email    varchar2(320);
   l_npref    varchar2(8);
   l_lang     varchar2(30);
   l_terr     varchar2(30);
   l_orig_sys varchar2(30);
   l_orig_id  number;
   l_install  varchar2(1);
   l_cells    tdType;

begin
   l_cells(1) := 'WH:<b>Notification Recipient Role Information</b>';
   Get_Table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;

   l_cells(1) := '15%:Role Name';
   l_cells(2) := '20%:Display Name';
   l_cells(3) := '25%:Email Address';
   l_cells(4) := '10%:Notification Pref';
   l_cells(5) := '5%:Launguage';
   l_cells(6) := '5%:Territory';
   l_cells(7) := '10%:Orig Sys';
   l_cells(8) := '5%:Orig Sys Id';
   l_cells(9) := '5%:Installed';

   SELECT recipient_role
   INTO   l_role
   FROM   wf_notifications
   WHERE  notification_id = p_nid;

   Wf_Directory.GetRoleInfoMail(l_role, l_dname, l_email, l_npref, l_lang, l_terr,
                                l_orig_sys, l_orig_id, l_install);

   l_cells(10) := l_role;
   l_cells(11) := l_dname;
   l_cells(12) := l_email;
   l_cells(13) := l_npref;
   l_cells(14) := l_lang;
   l_cells(15) := l_terr;
   l_cells(16) := l_orig_sys;
   l_cells(17) := l_orig_id;
   l_cells(18) := l_install;

   Get_Table(l_cells, 9, 'H', l_temp);
   l_result := l_result || l_temp;
   return l_result;
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when generating Notification Recipient Role Information for nid '||p_nid;
      l_cells(3) := '10%:Error';
      if (wf_core.error_name is null) then
         l_cells(4) := sqlerrm;
      else
         l_cells(4) := wf_core.error_name;
      end if;
      Get_Table(l_cells, 2, 'V', l_result);
      return l_result;
end Get_Ntf_Role_Info;

-- Get_Summary_Ntf_Role_Users - <Explained in WFDIAGPS.pls>
--
function Get_Summary_Ntf_Role_Users(p_role  in varchar2)
return varchar2
is
   l_result varchar2(32000);
   l_temp   varchar2(32000);

   CURSOR user_curs IS
   SELECT wur.user_name
   FROM   wf_user_roles wur
   WHERE  wur.role_name = p_role;

   l_cells tdType;
   i pls_integer;

   l_role     varchar2(320);
   l_dname    varchar2(360);
   l_email    varchar2(320);
   l_npref    varchar2(8);
   l_lang     varchar2(30);
   l_terr     varchar2(30);
   l_orig_sys varchar2(30);
   l_orig_id  number;
   l_install  varchar2(1);
begin
   l_cells(1) := 'WH:<b>Summary Notification Recipient Role Members</b>';
   Get_table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;

   l_cells(1) := '15%:User Name';
   l_cells(2) := '20%:Display Name';
   l_cells(3) := '25%:Email Address';
   l_cells(4) := '10%:Notification Pref';
   l_cells(5) := '5%:Language';
   l_cells(6) := '10%:Territory';
   l_cells(7) := '10%:Orig Sys';
   l_cells(8) := '5%:Orig Sys Id';
   l_cells(9) := '5%:Installed';
   i := 9;

   for l_rec in user_curs loop
      Wf_Directory.GetRoleInfoMail(l_rec.user_name, l_dname, l_email, l_npref,
                                   l_lang, l_terr, l_orig_sys, l_orig_id, l_install);
      l_cells(i+1) := l_rec.user_name;
      l_cells(i+2) := l_dname;
      l_cells(i+3) := l_email;
      l_cells(i+4) := l_npref;
      l_cells(i+5) := l_lang;
      l_cells(i+6) := l_terr;
      l_cells(i+7) := l_orig_sys;
      l_cells(i+8) := l_orig_id;
      l_cells(i+9) := l_install;
      i := i+9;
   end loop;
   Get_Table(l_cells, 9, 'H', l_temp);
   l_result := l_result || l_temp;
   return l_result;
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when generating Summary Notification Recipient  ' ||
                    'Role Members Info. for role '||p_role;
      l_cells(3) := '10%:Error';
      if (wf_core.error_name is null) then
         l_cells(4) := sqlerrm;
      else
         l_cells(4) := wf_core.error_name;
      end if;
      Get_Table(l_cells, 2, 'V', l_result);
      return l_result;
end Get_Summary_Ntf_Role_Users;

--
-- Get_Summary_Ntf_Role_Info - <Explained in WFDIAGPS.pls>
-- Returns the info about a specified Role
function Get_Summary_Ntf_Role_Info(p_role in varchar2)
return varchar2
is
   l_result   varchar2(32000);
   l_temp     varchar2(32000);

   l_dname    varchar2(360);
   l_email    varchar2(320);
   l_npref    varchar2(8);
   l_lang     varchar2(30);
   l_terr     varchar2(30);
   l_orig_sys varchar2(30);
   l_orig_id  number;
   l_install  varchar2(1);
   l_cells    tdType;

begin
   l_cells(1) := 'WH:<b>Summary Notification Recipient Role Information</b>';
   Get_Table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;

   l_cells(1) := '15%:Role Name';
   l_cells(2) := '20%:Display Name';
   l_cells(3) := '25%:Email Address';
   l_cells(4) := '10%:Notification Pref';
   l_cells(5) := '5%:Launguage';
   l_cells(6) := '5%:Territory';
   l_cells(7) := '10%:Orig Sys';
   l_cells(8) := '5%:Orig Sys Id';
   l_cells(9) := '5%:Installed';

   -- If user passes Role's display name then findout
   --SELECT recipient_role
   --INTO   l_role
   --FROM   wf_roles
   --WHERE  name = p_nid;

   Wf_Directory.GetRoleInfoMail(p_role, l_dname, l_email, l_npref, l_lang, l_terr,
                                l_orig_sys, l_orig_id, l_install);

   l_cells(10) := p_role;
   l_cells(11) := l_dname;
   l_cells(12) := l_email;
   l_cells(13) := l_npref;
   l_cells(14) := l_lang;
   l_cells(15) := l_terr;
   l_cells(16) := l_orig_sys;
   l_cells(17) := l_orig_id;
   l_cells(18) := l_install;

   Get_Table(l_cells, 9, 'H', l_temp);
   l_result := l_result || l_temp;
   return l_result;
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when generating Notification Recipient Role Information for nid '||p_role;
      l_cells(3) := '10%:Error';
      if (wf_core.error_name is null) then
         l_cells(4) := sqlerrm;
      else
         l_cells(4) := wf_core.error_name;
      end if;
      Get_Table(l_cells, 2, 'V', l_result);

      return l_result;
end Get_Summary_Ntf_Role_Info;

--
-- Get_Ntf_More_Info - <Explained in WFDIAGPS.pls>
--
function Get_Ntf_More_Info(p_nid in number)
return varchar2
is
   l_result   varchar2(32000);
   l_temp     varchar2(32000);
   l_role     varchar2(320);
   l_dname    varchar2(360);
   l_email    varchar2(320);
   l_npref    varchar2(8);
   l_lang     varchar2(30);
   l_terr     varchar2(30);
   l_orig_sys varchar2(30);
   l_orig_id  number;
   l_install  varchar2(1);
   l_cells    tdType;

begin
   l_cells(1) := 'WH:<b>Notification More Info Role Information</b>';
   Get_Table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;

   l_cells(1) := '15%:Role Name';
   l_cells(2) := '20%:Display Name';
   l_cells(3) := '25%:Email Address';
   l_cells(4) := '10%:Notification Pref';
   l_cells(5) := '5%:Launguage';
   l_cells(6) := '5%:Territory';
   l_cells(7) := '10%:Orig Sys';
   l_cells(8) := '5%:Orig Sys Id';
   l_cells(9) := '5%:Installed';

   SELECT more_info_role
   INTO   l_role
   FROM   wf_notifications
   WHERE  notification_id = p_nid;

   if (l_role is not null) then

      Wf_Directory.GetRoleInfoMail(l_role, l_dname, l_email, l_npref, l_lang, l_terr,
                                   l_orig_sys, l_orig_id, l_install);

      l_cells(10) := l_role;
      l_cells(11) := l_dname;
      l_cells(12) := l_email;
      l_cells(13) := l_npref;
      l_cells(14) := l_lang;
      l_cells(15) := l_terr;
      l_cells(16) := l_orig_sys;
      l_cells(17) := l_orig_id;
      l_cells(18) := l_install;

      Get_Table(l_cells, 9, 'H', l_temp);
      l_result := l_result || l_temp;
   end if;
   return l_result;
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when generating Notification More Info Role Information for nid '||p_nid;
      l_cells(3) := '10%:Error';
      if (wf_core.error_message is null) then
         l_cells(4) := sqlerrm;
      else
         l_cells(4) := wf_core.error_message;
      end if;
      Get_Table(l_cells, 2, 'V', l_result);
      return l_result;
end Get_Ntf_More_Info;

--
-- Get_Routing_Rules - <Explained in WFDIAGPS.pls>
--
function Get_Routing_Rules(p_nid in number)
return varchar2
is
  l_result varchar2(32000);
  l_temp   varchar2(32000);
  l_cells tdType;
  i pls_integer;

  CURSOR c_rules IS
  SELECT wr.action action,
         wr.begin_date begin_date,
         wr.end_date end_date,
         wr.message_type msg_type,
         wr.message_name msg_name,
         wr.action_argument act_arg,
         wra.name,
         wra.type,
         nvl(nvl(wra.text_value, to_char(wra.number_value)), to_char(wra.date_value)) value
  FROM   wf_routing_rules wr,
         wf_routing_rule_attributes wra,
         wf_notifications wn
  WHERE  wr.rule_id = wra.rule_id (+)
  AND    (wr.role = wn.recipient_role or wr.action_argument = wn.recipient_role)
  AND    wn.notification_id = p_nid;

begin
   l_cells(1) := 'WH:<b>Notification Recipient Routing Rules</b>';
   Get_Table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;

   l_cells(1) := '10%:Action';
   l_cells(2) := '5%:Begin Date';
   l_cells(3) := '5%:End Date';
   l_cells(4) := '15%:Message Type';
   l_cells(5) := '15%:Message Name';
   l_cells(6) := '15%:Action Argument';
   l_cells(7) := '10%:Name';
   l_cells(8) := '15%:Type';
   l_cells(9) := '10%:Value';
   i := 9;

   for l_rec in c_rules loop
     l_cells(i+1) := l_rec.action;
     l_cells(i+2) := l_rec.begin_date;
     l_cells(i+3) := l_rec.end_Date;
     l_cells(i+4) := l_rec.msg_type;
     l_cells(i+5) := l_rec.msg_name;
     l_cells(i+6) := l_rec.act_arg;
     l_cells(i+7) := l_rec.name;
     l_cells(i+8) := l_rec.type;
     l_cells(i+9) := l_rec.value;
     i := i+9;
   end loop;
   Get_Table(l_cells, 9, 'H', l_temp);
   l_result := l_result || l_temp;
   return l_result;
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when generating Notification Recipient Role Routing Rules Information for nid '||p_nid;
      l_cells(3) := '10%:Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      return l_result;
end Get_Routing_Rules;

--
-- Get_Ntf_Msg_Attrs - <Explained in WFDIAGPS.pls>
--
procedure Get_Ntf_Msg_Attrs(p_nid   in  number,
                            p_value in out nocopy clob)
is
   l_result varchar2(32000);
   l_cells  tdType;
   i        pls_integer;

   cursor c_msg_attr is
   select wma.name name,
          wmat.display_name d_name,
          wma.sequence seq,
          wma.type type,
          wma.subtype s_type,
          wma.value_type v_type,
          decode (wma.type,
               'DATE', to_char(wma.date_default),
               'NUMBER', to_char(wma.number_default),
               wma.text_default) value,
          wma.format format
   from   wf_message_attributes wma,
          wf_message_attributes_tl wmat,
          wf_notifications wn
   where  wma.message_name = wmat.message_name
   and    wma.message_type = wmat.message_type
   and    wma.name = wmat.name
   and    wmat.language = userenv('LANG')
   and    wma.message_type = wn.message_type
   and    wma.message_name = wn.message_name
   and    wn.notification_id = p_nid;

begin
   dbms_lob.trim(l_temp, 0);

   l_cells(1) := 'WH:<b>Notification Message Attribute Values</b>';
   Get_Table(l_cells, 1, 'H', l_result);
   dbms_lob.WriteAppend(p_value, length(l_result), l_result);
   l_cells.DELETE;

   l_cells(1) := '10%:Name';
   l_cells(2) := '15%:Display Name';
   l_cells(3) := '5%:Sequence';
   l_cells(4) := '10%:Type';
   l_cells(5) := '10%:Sub Type';
   l_cells(6) := '10%:Value Type';
   l_cells(7) := '30%:Value';
   l_cells(8) := '10%:Format';
   i := 8;

   for l_msg_rec in c_msg_attr loop
      l_cells(i+1) := l_msg_rec.name;
      l_cells(i+2) := l_msg_rec.d_name;
      l_cells(i+3) := l_msg_rec.seq;
      l_cells(i+4) := l_msg_rec.type;
      l_cells(i+5) := l_msg_rec.s_type;
      l_cells(i+6) := l_msg_rec.v_type;
      l_cells(i+7) := l_msg_rec.value;
      l_cells(i+8) := l_msg_rec.format;
      i := i+8;
   end loop;

   Get_Table(l_cells, 8, 'H', l_temp);
   dbms_lob.Append(p_value, l_temp);
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when generating Notification Message Attribute Values Information for nid '||p_nid;
      l_cells(3) := '10%:Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      dbms_lob.WriteAppend(p_value, length(l_result), l_result);
end Get_Ntf_Msg_Attrs;

--
-- Get_Ntf_Attrs - <Explained in WFDIAGPS.pls>
--
procedure Get_Ntf_Attrs(p_nid   in  number,
                        p_value in out nocopy clob)
is
   l_result varchar2(32000);
   l_cells  tdType;
   i        pls_integer;

   cursor c_ntf_attr is
   select name name,
          number_value num_val,
          date_value date_val,
          text_value txt_val
   from   wf_notification_attributes
   where  notification_id = p_nid;

begin
   dbms_lob.Trim(l_temp, 0);

   l_cells(1) := 'WH:<b>Notification Attribute Values</b>';
   Get_Table(l_cells, 1, 'H', l_result);
   dbms_lob.WriteAppend(p_value, length(l_result), l_result);
   l_cells.DELETE;

   l_cells(1) := '15%:Name';
   l_cells(2) := '15%:Number Value';
   l_cells(3) := '15%:Date Value';
   l_cells(4) := '55%:Text Value';
   i := 4;

   for l_attr_rec in c_ntf_attr loop
      l_cells(i+1) := l_attr_rec.name;
      l_cells(i+2) := l_attr_rec.num_val;
      l_cells(i+3) := l_attr_rec.date_val;
      l_cells(i+4) := l_attr_rec.txt_val;
      i := i+4;
   end loop;
   Get_Table(l_cells, 4, 'H', l_temp);
   dbms_lob.Append(p_value, l_temp);
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when generating Notification Attributes Values Information for nid '||p_nid;
      l_cells(3) := '10%:Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      dbms_lob.WriteAppend(p_value, length(l_result), l_result);
end Get_Ntf_Attrs;


--
-- Bug 6677333
-- Get_Ntf_Msg_Attrs
--   Returns a HTML table of all the Message Result Attribute values associated with the
--   Notification message
--

procedure Get_Ntf_Msg_Result_Attrs(p_nid   in  number,
                        p_value in out nocopy clob)
is
   l_result         varchar2(32000);
   l_cells          tdType;
   i                pls_integer;
   l_format         varchar2(100);
   l_msg_type       varchar2(100);
   l_msg_name       varchar2(100);
   l_lookup_code    varchar2(100);
   l_display_value  varchar2(100);
   l_lang           varchar2(100) ;
   l_lang_code      varchar2(10) ;

   cursor c_msg_attr(type VARCHAR2, lang varchar2) is
   select lookup_type lookup_type,
          lookup_code lookup_code,
          meaning display_Value,
	  language lang_code
   from   WF_LOOKUPS_TL
   where  language = lang
   AND    lookup_type = type;


begin
   dbms_lob.Trim(l_temp, 0);

   l_cells(1) := 'WH:<b>Notification Message Result Attribute Values</b>';
   Get_Table(l_cells, 1, 'H', l_result);
   dbms_lob.WriteAppend(p_value, length(l_result), l_result);
   l_cells.DELETE;

   l_cells(1) := '15%:Lookup Type';
   l_cells(2) := '15%:Lookup Code';
   l_cells(3) := '15%:Display Value';
   l_cells(4) := '55%:Language Code';
   i := 4;

   select message_type, message_name, language
   into   l_msg_type, l_msg_name, l_lang_code
   from   wf_notifications
   where  notification_id = p_nid;

   begin

      select format
      into   l_format
      from   wf_message_attributes
      where  message_type = l_msg_type
      and    message_name = l_msg_name
      and    name = 'RESULT' ;

   exception
       when no_data_found then
            Get_Table(l_cells, 4, 'H', l_temp);
            dbms_lob.Append(p_value, l_temp);

            l_cells.DELETE;
	    l_cells(1) := '20%(not defined)'||wf_core.newline;
	    Get_Table(l_cells, 1, 'V', l_result);
	    dbms_lob.WriteAppend(p_value, length(l_result), l_result);

	    return;
   end;

   for l_attr_rec in c_msg_attr(l_format,'US') loop
      l_cells(i+1) := l_attr_rec.lookup_type;
      l_cells(i+2) := l_attr_rec.lookup_code;
      l_cells(i+3) := l_attr_rec.display_Value;
      l_cells(i+4) := l_attr_rec.lang_code;
      i := i+4;
   end loop;

   if(not l_lang_code = 'US') then
      for l_attr_rec in c_msg_attr(l_format,l_lang_code) loop
         l_cells(i+1) := l_attr_rec.lookup_type;
         l_cells(i+2) := l_attr_rec.lookup_code;
         l_cells(i+3) := l_attr_rec.display_Value;
	 l_cells(i+4) := l_attr_rec.lang_code;
         i := i+4;
      end loop;
   end if;

   Get_Table(l_cells, 4, 'H', l_temp);
   dbms_lob.Append(p_value, l_temp);
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when generating Notification Result Attributes Values Information for nid '||p_nid;
      l_cells(3) := '10%:Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      dbms_lob.WriteAppend(p_value, length(l_result), l_result);
end Get_Ntf_Msg_Result_Attrs;

--
-- Get_User_Comments - <Explained in WFDIAGPS.pls>
--
procedure Get_User_Comments(p_nid   in number,
                            p_value in out nocopy clob)
is
   l_result varchar2(32000);
   l_cells  tdType;
   i        pls_integer;

   cursor c_comm is
   select wc.from_role,
          wc.from_user,
          to_char(wc.comment_date, 'DD-MON-RRRR HH24:MI:SS') comm_date,
          wc.action,
          wc.user_comment
   from   wf_comments wc
   where  wc.notification_id = p_nid
   order by comment_date;

begin
   dbms_lob.Trim(l_temp, 0);

   l_cells(1) := 'WH:<b>Notification User Comments</b>';
   Get_Table(l_cells, 1, 'H', l_result);
   dbms_lob.WriteAppend(p_value, length(l_result), l_result);
   l_cells.DELETE;

   l_cells(1) := '10%:From Role';
   l_cells(2) := '10%:From User';
   l_cells(3) := '5%:Comment Date';
   l_cells(4) := '15%:Action';
   l_cells(5) := '60%:User Comment';
   i := 5;

   for l_comm_rec in c_comm loop
      l_cells(i+1) := l_comm_rec.from_role;
      l_cells(i+2) := l_comm_rec.from_user;
      l_cells(i+3) := l_comm_rec.comm_date;
      l_cells(i+4) := l_comm_rec.action;
      l_cells(i+5) := l_comm_rec.user_comment;
      i := i+5;
   end loop;
   Get_Table(l_cells, 5, 'H', l_temp);
   dbms_lob.Append(p_value, l_temp);
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when generating Notification User Comments Information for nid '||p_nid;
      l_cells(3) := '10%:Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      dbms_lob.WriteAppend(p_value, length(l_result), l_result);
end Get_User_Comments;

--
-- Get_Event_Queue_Status - <Explained in WFDIAGPS.pls>
--
function Get_Event_Queue_Status(p_queue_name in varchar2,
                                p_event_name in varchar2,
                                p_event_key  in varchar2)
return varchar2
is
   l_result  varchar2(32767);
   l_temp    varchar2(32767);
   l_cells   tdType;
   i         pls_integer;
   l_sql_str varchar2(4000);

   type t_eventq is ref cursor;
   c_eventq  t_eventq;

   type t_eventq_rec is record
   (
      msgid    raw(16),
      state    varchar2(13),
      con_name varchar2(30),
      queue_name varchar2(30),
      exception_queue varchar2(30),
      retry_count number,
      ev_name  varchar2(240),
      ev_key   varchar2(240),
      enq_time date,
      deq_time date ,
      err_msg  varchar2(4000),
      err_stk  varchar2(4000)
    );
   l_eventq_rec t_eventq_rec;

begin
   l_cells(1) := 'WH:<b>'||p_queue_name||' Queue Status</b>';
   Get_table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;

   l_cells(1) := 'Message Id';
   l_cells(2) := 'Message State';
   l_cells(3) := 'Consumer Name';
   l_cells(4) := 'Queue';
   l_cells(5) := 'Exception Queue';
   l_cells(6) := 'Retry Count';
   l_cells(7) := 'Event Name';
   l_cells(8) := 'Event Key';
   if (p_queue_name = 'WF_ERROR') then
     l_cells(9) := 'Error Message';
     l_cells(10) := 'Error Stack';
   else
     l_cells(9) := 'Enqueue Time';
     l_cells(10) := 'Dequeue Time';
   end if;
   i := 10;

   l_sql_str := 'select tab.msg_id msgid, '||
                'tab.msg_state state, '||
                'tab.consumer_name con_name, '||
                'tab.queue queue_name, '||
                'tab.exception_queue ex_queue_name, '||
                'tab.retry_count, '||
                'tab.user_data.event_name ev_name, '||
                'tab.user_data.event_key ev_key, '||
                'tab.enq_time, '||
                'tab.deq_time, '||
                'tab.user_data.error_message err_msg, '||
                'tab.user_data.error_stack err_stack '||
                'from   '||g_qowner||'.aq$'||p_queue_name||' tab '||
                'where  tab.user_data.event_name like :p1 '||
                'and    tab.user_data.event_key like :p2';

   open c_eventq for l_sql_str using p_event_name, p_event_key;
   loop
      fetch c_eventq into l_eventq_rec;
      exit when c_eventq%NOTFOUND;

      l_cells(i+1) := l_eventq_rec.msgid;
      l_cells(i+2) := l_eventq_rec.state;
      l_cells(i+3) := l_eventq_rec.con_name;
      l_cells(i+4) := l_eventq_rec.queue_name;
      l_cells(i+5) := l_eventq_rec.exception_queue;
      l_cells(i+6) := l_eventq_rec.retry_count;
      l_cells(i+7) := l_eventq_rec.ev_name;
      l_cells(i+8) := l_eventq_rec.ev_key;
      if (p_queue_name = 'WF_ERROR') then
        l_cells(i+9) := l_eventq_rec.err_msg;
        l_cells(i+10) := l_eventq_rec.err_stk;
      else
        l_cells(i+9) := to_char(l_eventq_rec.enq_time, 'DD-MON-RRRR HH24:MI:SS');
        l_cells(i+10) := to_char(l_eventq_rec.deq_time, 'DD-MON-RRRR HH24:MI:SS');
      end if;
      i := i+10;
   end loop;
   close c_eventq;

   Get_Table(l_cells, 10, 'H', l_temp);
   l_result := l_result || l_temp;
   return l_result;
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := 'Note';
      l_cells(2) := 'Error when generating '||p_queue_name||' Queue Status Information for Event Name '
                    ||p_event_name||' and Event Key '||p_event_key;
      l_cells(3) := 'Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      return l_result;
end Get_Event_Queue_Status;



--
-- Get_JMS_Queue_Status - <Explained in WFDIAGPS.pls>
--
function Get_JMS_Queue_Status(p_queue_name in varchar2,
                              p_event_name in varchar2,
                              p_event_key  in varchar2,
			      p_corr_id    in varchar2 )
return varchar2
is
   l_result varchar2(32767);
   l_temp   varchar2(32767);
   l_cells  tdType;
   i        pls_integer;
   l_retention varchar2(40);
   l_event_t wf_event_t;

   type t_jmsq is ref cursor;
   c_jmsq  t_jmsq;

   type t_jmsq_rec is record
   (
      msg_id        raw(16),
      corr_id       varchar2(128),
      msg_state     varchar2(13),
      consumer_name varchar2(30),
      queue_name    varchar2(30),
      exception_queue varchar2(30),
      retry_count   number,
      enq_time      date,
      deq_time      date,
      user_data     SYS.AQ$_JMS_TEXT_MESSAGE
    );
   l_jmsq_rec t_jmsq_rec;

begin
   l_cells(1) := 'WH:<b>'||p_queue_name||' Queue Status </b>' || p_corr_id ;
   Get_Table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;

   l_cells(1) := 'Message Id';
   l_cells(2) := 'Message State';
   l_cells(3) := 'Consumer Name';
   l_cells(4) := 'Queue';
   l_cells(5) := 'Exception Queue';
   l_cells(6) := 'Retry Count';
   l_cells(7) := 'Enqueue Time';
   l_cells(8) := 'Dequeue Time';
   i := 8;


   wf_event_t.Initialize(l_event_t);

    -- org
   open c_jmsq for 'select msg_id, corr_id, msg_state, consumer_name, queue, exception_queue, '||
                   ' retry_count, enq_time, deq_time, user_data'||
                   ' from '||g_qowner||'.aq$'||p_queue_name ||
                   ' order by enq_time desc';


   loop
      fetch c_jmsq into l_jmsq_rec;
      exit when c_jmsq%NOTFOUND;

      -- deserialize DOES NOT updates l_event_t.correlation_id field, so we have
      -- to use l_jmsq_rec.corr_id to compare

      wf_event_ojmstext_qh.deserialize(l_jmsq_rec.user_data, l_event_t);



      if ( (l_event_t.event_key like p_event_key)   AND
           (l_event_t.event_name like p_event_name) AND
	   (p_corr_id is null or upper(l_jmsq_rec.corr_id)
	                         like  upper(p_corr_id ) )) then

          l_cells(i+1) := l_jmsq_rec.msg_id;
          l_cells(i+2) := l_jmsq_rec.msg_state ;
          l_cells(i+3) := l_jmsq_rec.consumer_name;
          l_cells(i+4) := l_jmsq_rec.queue_name;
          l_cells(i+5) := l_jmsq_rec.exception_queue;
          l_cells(i+6) := l_jmsq_rec.retry_count;
          l_cells(i+7) := to_char(l_jmsq_rec.enq_time, 'DD-MON-YYYY HH24:MI:SS');
          l_cells(i+8) := to_char(l_jmsq_rec.deq_time, 'DD-MON-YYYY HH24:MI:SS');
          i := i+8;

      end if;

   end loop;

   close c_jmsq;

   Get_Table(l_cells, 8, 'H', l_temp);
   l_result := l_result || l_temp;
   return l_result;
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := 'Note';
      l_cells(2) := 'Error when generating '||p_queue_name||' Queue Status Information for Event Name'
                    ||p_event_name||' and Event Key '||p_event_key;
      l_cells(3) := 'Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      return l_result;
end Get_JMS_Queue_Status;
--
-- Get_JMS_Queue_Status - <Explained in WFDIAGPS.pls>
--
function Get_JMS_Queue_Status(p_queue_name in varchar2,
                              p_event_name in varchar2,
                              p_event_key  in varchar2 )
return varchar2
is
begin

  return Get_JMS_Queue_Status(p_queue_name => p_queue_name,
                              p_event_name => p_event_name,
			      p_event_key => p_event_key,
			      p_corr_id =>null );

end Get_JMS_Queue_Status;

--
-- SetNLS - Sets the NLS parameters Langauge and Territory for the current session
--
procedure SetNLS(p_language  in varchar2,
                 p_territory in varchar2)
is
  l_lang varchar2(30);
  l_terr varchar2(30);
  l_install varchar2(10);
begin
  if (p_language is null) then
     l_lang := 'AMERICAN';
  end if;
  if (p_territory is null) then
     l_terr := 'AMERICA';
  end if;
  begin
     SELECT installed_flag
     INTO   l_install
     FROM   wf_languages
     WHERE  nls_language = p_language
     AND    installed_flag = 'Y';

     l_lang := ''''||p_language||'''';
     l_terr := ''''||p_territory||'''';
  exception
     when others then
        l_lang := 'AMERICAN';
        l_terr := 'AMERICA';
  end;
  dbms_session.set_nls('NLS_LANGUAGE', l_lang);
  dbms_session.set_nls('NLS_TERRITORY', l_terr);

end SetNLS;

--
-- Get_Ntf_Templates - <Explained in WFDIAGPS.pls>
--
procedure Get_Ntf_Templates(p_nid   in number,
                            p_value in out nocopy clob)
is
   l_result     varchar2(32767);
   l_temp       varchar2(32767);
   l_cells      tdType;
   i            pls_integer;
   l_txt_body   varchar2(4000);
   l_htm_body   varchar2(4000);
   l_subj       varchar2(240);
   l_tname      varchar2(100);
   l_ttype      varchar2(100);
   l_status     varchar2(8);
   l_mstatus    varchar2(8);
   l_msg_type   varchar2(8);
   l_msg_name   varchar2(30);
   l_nid        number;
   l_recip_role varchar2(320);
   l_dname      varchar2(360);
   l_email      varchar2(320);
   l_npref      varchar2(8);
   l_user_lang  varchar2(30);
   l_user_terr  varchar2(30);
   l_osys       varchar2(30);
   l_osysid     number;
   l_installed  varchar2(10);

   l_ses_lang    varchar2(30);
   l_ses_terr    varchar2(30);
   l_ses_codeset varchar2(30);
   l_ntf_lang    varchar2(30);
   l_ntf_terr    varchar2(30);
   l_ntf_codeset varchar2(30);
   l_nls_lang    varchar2(30);
   l_nls_terr    varchar2(30);

   type t_lang_terr is record
   (
     language varchar2(30),
     territory varchar2(30)
   );

   type t_lang_list is table of t_lang_terr index by binary_integer;
   l_lang_list t_lang_list;

begin
   l_nid := p_nid;

   l_cells(1) := 'WH:<b>Notification Message Template Definition</b>';
   Get_Table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;

   select status, mail_status, message_type, message_name, recipient_role
   into   l_status, l_mstatus, l_msg_type, l_msg_name, l_recip_role
   from   wf_notifications
   where  notification_id = p_nid;

   if (l_mstatus not in ('MAIL')) then
      wf_mail.test_flag := TRUE;
      l_cells(1) := 'WH:<b>Setting MAIL_STATUS to MAIL since the original status was ' || l_mstatus || '.</b>';
      Get_Table(l_cells, 1, 'H', l_temp);
      l_cells.DELETE;
      l_result := l_result || l_temp;
      l_mstatus := 'MAIL';
      if (l_status not in ('OPEN','CANCELED','CLOSED')) then
         l_status := 'OPEN';
      end if;
   end if;

   begin
     wf_mail.getTemplateName(l_nid, l_status, l_mstatus, l_ttype, l_tname);
   exception
     when others then
       l_ttype := null;
       l_tname := null;
   end;

   -- We want to generate in all possible language/territory associated to
   -- the notification
   --   1. Recipient's preference
   --   2. Setting at the language level using #WFM_NLS_XXXXXX attribute
   --   3. Current session language
   Wf_Directory.GetRoleInfoMail(l_recip_role, l_dname, l_email, l_npref, l_user_lang,
                                l_user_terr, l_osys, l_osysid, l_installed);

   l_ntf_lang := l_user_lang;
   l_ntf_terr := l_user_terr;
   Wf_Mail.Get_Ntf_Language(l_nid, l_ntf_lang, l_ntf_terr, l_ntf_codeset);

   Wf_Mail.GetSessionLanguage(l_ses_lang, l_ses_terr, l_ses_codeset);

   -- Storing all the possible language/territory combinations for the given
   -- notification id in a parameter list
   l_lang_list(1).language := l_user_lang;
   l_lang_list(1).territory := l_user_terr;
   if (l_ntf_lang||l_ntf_terr <> l_user_lang||l_user_terr) then
     l_lang_list(2).language := l_ntf_lang;
     l_lang_list(2).territory := l_ntf_terr;
     if (l_ses_lang||l_ses_terr not in (l_ntf_lang||l_ntf_terr, l_user_lang||l_user_terr)) then
       l_lang_list(3).language := l_ses_lang;
       l_lang_list(3).territory := l_ses_terr;
     end if;
   elsif (l_ses_lang||l_ses_terr <> l_user_lang||l_user_terr) then
     l_lang_list(2).language := l_ses_lang;
     l_lang_list(2).territory := l_ses_terr;
   end if;

   for i in 1..l_lang_list.COUNT loop
      l_nls_lang := l_lang_list(i).language;
      l_nls_terr := l_lang_list(i).territory;

      -- l_user_lang should be valid within wf_langauges
      select installed_flag
      into   l_installed
      from   wf_languages
      where  nls_language = l_nls_lang;

      if (l_installed = 'Y') then
        -- Generate based on User's preference
        SetNLS(l_nls_lang, l_nls_terr);

        if (l_ttype is not null and l_tname is not null) then
          begin
            select subject, body, html_body
            into   l_subj, l_txt_body, l_htm_body
            from   wf_messages_vl
            where  name = l_tname
            and    type = l_ttype;
          exception
            when no_data_found then
              wf_core.token('NAME', l_tname);
              wf_core.token('TYPE', l_ttype);
              wf_core.raise('WFNTF_MESSAGE');
         end;

         l_result := NULL;
         l_cells(1) := '25%:Message Type';
         l_cells(2) := l_ttype;
         l_cells(3) := '25%:Message Name';
         l_cells(4) := l_tname;
         Get_Table(l_cells, 2, 'V', l_temp);
         l_result := l_result||l_temp||wf_core.newline;
         l_cells.DELETE;
         dbms_lob.WriteAppend(p_value, length(l_result), l_result);
         l_result := NULL;

         l_result := '<table width='||table_width||'><tr>';
         l_result := l_result||'<tr><th bgcolor='||th_bgcolor||' align=left><font face='||th_fontface||
                               ' size='||th_fontsize||' color='||th_fontcolor||'>';
         l_result := l_result||'E-mail Message Template in TEXT format. ('||l_nls_lang||'_'||l_nls_terr||')</th></tr>';
         l_result := l_result||'<tr><td bgcolor='||td_bgcolor||'><pre>';
         if (l_txt_body is not null) then
           l_result := l_result||Wf_Notification.SubstituteSpecialChars(l_txt_body);
         else
           l_result := '(not defined)';
         end if;
         l_result := l_result||'</pre></td></tr>'||wf_core.newline;

         l_result := l_result||'<tr><th bgcolor='||th_bgcolor||' align=left><font face='||th_fontface||
                               ' size='||th_fontsize||' color='||th_fontcolor||'>';
         l_result := l_result||'E-mail Message Template in HTML format. ('||l_nls_lang||'_'||l_nls_terr||')</th></tr>';
         l_result := l_result||'<tr><td bgcolor='||td_bgcolor||'><pre>';
         if (l_htm_body is not null) then
           l_result := l_result||Wf_Notification.SubstituteSpecialChars(l_htm_body);
         else
           l_result := l_result||'(not defined)';
         end if;
         l_result := l_result||'</pre></td></tr></table>';
         dbms_lob.WriteAppend(p_value, length(l_result), l_result);
       else
         l_result := NULL;
         l_cells(1) := 'Warning';
         l_cells(2) := 'Unable to generate E-mail full template information. This can occur when the '||
                       'mail status of the notification is NULL';
         Get_Table(l_cells, 2, 'V', l_result);
         dbms_lob.WriteAppend(p_value, length(l_result), l_result);
       end if;

       begin
         select subject, body, html_body
         into   l_subj, l_txt_body, l_htm_body
         from   wf_messages_vl
         where  name = l_msg_name
         and    type = l_msg_type;
       exception
         when no_data_found then
            wf_core.token('NAME', l_msg_name );
            wf_core.token('TYPE', l_msg_type);
            wf_core.raise('WFNTF_MESSAGE');
       end;

       l_result := NULL;
       l_cells(1) := '25%:Message Type';
       l_cells(2) := l_msg_type;
       l_cells(3) := '25%:Message Name';
       l_cells(4) := l_msg_name;
       l_cells(5) := '25%:Subject';
       l_cells(6) := l_subj;

       Get_Table(l_cells, 2, 'V', l_temp);
       l_result := l_result||l_temp||wf_core.newline;
       l_cells.DELETE;
       dbms_lob.WriteAppend(p_value, length(l_result), l_result);
       l_result := NULL;

       l_result := '<table width='||table_width||'><tr>';
       l_result := l_result||'<tr><th bgcolor='||th_bgcolor||' align=left><font face='||th_fontface||
                             ' size='||th_fontsize||' color='||th_fontcolor||'>';
       l_result := l_result||'Notification Message Definition in TEXT format. ('||l_nls_lang||'_'||l_nls_terr||')</th></tr>';
       l_result := l_result||'<tr><td bgcolor='||td_bgcolor||'><pre>';
       if (l_txt_body is not null) then
         l_result := l_result||Wf_Notification.SubstituteSpecialChars(l_txt_body);
       else
         l_result := l_result||'(not defined)';
       end if;
       l_result := l_result||'</pre></td></tr>'||wf_core.newline;

       l_result := l_result||'<tr><th bgcolor='||th_bgcolor||' align=left><font face='||th_fontface||
                             ' size='||th_fontsize||' color='||th_fontcolor||'>';
       l_result := l_result||'Notification Message Definition in HTML format. ('||l_nls_lang||'_'||l_nls_terr||')</th></tr>';
       l_result := l_result||'<tr><td bgcolor='||td_bgcolor||'><pre>';
       if (l_htm_body is not null) then
         l_result := l_result||Wf_Notification.SubstituteSpecialChars(l_htm_body);
       else
         l_result := l_result||'(not defined)';
       end if;
       l_result := l_result||'</pre></td></tr></table>';
       dbms_lob.WriteAppend(p_value, length(l_result), l_result);
     end if; -- installed flag check
   end loop;
   -- Reset to the base NLS settings
   SetNLS(l_ses_lang, l_ses_terr);
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when generating Notification Template Information for nid '||p_nid;
      l_cells(3) := '10%:Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      dbms_lob.WriteAppend(p_value, length(l_result), l_result);
end Get_Ntf_Templates;



-- get_Summary_Template -
--
-- IN
--    Role
--    Role pref.  (SUMHTML or SUMMARY)
-- OUT
--    Item type and Message name for template
procedure get_Summary_Templates(p_role in varchar2,
                                p_ntf_pref in varchar2,
                                p_value in out nocopy clob)
is

   l_result     varchar2(32767);
   l_temp       varchar2(32767);
   l_cells      tdType;
   i            pls_integer;
   l_txt_body   varchar2(4000);
   l_htm_body   varchar2(4000);
   l_subj       varchar2(240);
   l_tname      varchar2(100);
   l_ttype      varchar2(100);
  -- l_status     varchar2(8);
  -- l_mstatus    varchar2(8);
  -- l_msg_type   varchar2(8);
  -- l_msg_name   varchar2(30);

   l_dname      varchar2(360);
   l_email      varchar2(320);
   l_npref      varchar2(8);
   l_user_lang  varchar2(30);
   l_user_terr  varchar2(30);
   l_osys       varchar2(30);
   l_osysid     number;
   l_installed  varchar2(10);

   l_ses_lang    varchar2(30);
   l_ses_terr    varchar2(30);
   l_ses_codeset varchar2(30);
   l_ntf_lang    varchar2(30);
   l_ntf_terr    varchar2(30);
   l_ntf_codeset varchar2(30);
   l_nls_lang    varchar2(30);
   l_nls_terr    varchar2(30);

   l_component_id number;
   l_summary_param varchar(50);
   l_summary varchar(50);
   --
   CURSOR c_get_components_id is
	SELECT component_id
	FROM FND_SVC_COMPONENTS
	WHERE component_type = 'WF_MAILER'
	order by DECODE(component_status, 'RUNNING', 1, 'NOT_CONFIGURED', 3, 2) ASC ;

begin

    l_ttype := 'WFMAIL'; -- Set the default type;
    wf_mail.Set_FYI_Flag(FALSE);

    -- GET tamplte name of a Mailer component
    for rec_component in c_get_components_id loop

	l_component_id := rec_component.component_id;

	if (p_ntf_pref = 'SUMHTML') then

           SELECT a.parameter_value into l_summary_param
           FROM   fnd_svc_comp_param_vals a,
                  fnd_svc_components b,
                  fnd_svc_comp_params_vl c
           WHERE  b.component_id = a.component_id
           AND    b.component_type = c.component_type
           AND    c.parameter_id = a.parameter_id
           AND    c.encrypted_flag = 'N'
           AND    b.component_id = l_component_id
           AND  c.parameter_name in ('SUMHTML' );

	else

           SELECT a.parameter_value into l_summary_param
	   FROM   fnd_svc_comp_param_vals a,
		  fnd_svc_components b,
		  fnd_svc_comp_params_vl c
	  WHERE  b.component_id = a.component_id
	  AND    b.component_type = c.component_type
	  AND    c.parameter_id = a.parameter_id
	  AND    c.encrypted_flag = 'N'
	  AND    b.component_id = l_component_id
	  AND    c.parameter_name in ('SUMMARY' );

	end if;

	-- get values only for one and running Mailer components
	exit;

    end loop; -- end for loop

    -- parse for template type and name for summary html
    l_ttype := substr(l_summary_param, 1, instr(l_summary_param, ':')-1) ;
    l_tname := substr(l_summary_param, instr(l_summary_param, ':')+1) ;

    -- Get Roles' language pref.
    Wf_Directory.GetRoleInfoMail(p_role, l_dname, l_email,
				 l_npref, l_user_lang, l_user_terr,
				 l_osys, l_osysid, l_installed);
    -- get Session lang
    Wf_Mail.GetSessionLanguage(l_ses_lang, l_ses_terr, l_ses_codeset);

     -- l_user_lang should be valid within wf_langauges
     select installed_flag
     into   l_installed
     from   wf_languages
     where  nls_language = l_user_lang;

     if (l_installed = 'Y') then
        -- Generate based on User's preference
        SetNLS(l_user_lang, l_user_terr);

	select subject, body, html_body
	into   l_subj, l_txt_body, l_htm_body
	from   wf_messages_vl
	where  name = l_tname
	and    type = l_ttype;

        l_result := NULL;

        l_cells(1) := '25%:Message Type';
        l_cells(2) := l_ttype;
        l_cells(3) := '25%:Message Name';
        l_cells(4) := l_tname;

        Get_Table(l_cells, 2, 'V', l_temp);
        l_result := l_result||l_temp||wf_core.newline;
        l_cells.DELETE;

        dbms_lob.WriteAppend(p_value, length(l_result), l_result);

        l_result := NULL;

        l_result := '<table width='||table_width||'><tr>';
        l_result := l_result||'<tr><th bgcolor='||th_bgcolor||' align=left><font face='
                         || th_fontface|| ' size='||th_fontsize||' color='||th_fontcolor||'>';

        l_result := l_result||'Summary Message Template in TEXT format. ('||
	                    l_user_lang||'_'||l_user_terr||')</th></tr>';
        --l_result := l_result||wf_core.newline;
        l_result := l_result||'<tr><td bgcolor='||td_bgcolor||'><pre>';

        if (l_txt_body is not null) then
            l_result := l_result||Wf_Notification.SubstituteSpecialChars(l_txt_body);
        else
	   l_result := '(not defined or user language ' || l_user_lang ||' is not installed )';
        end if;

        l_result := l_result||'</pre></td></tr>'||wf_core.newline;

        l_result := l_result||'<tr><th bgcolor='||th_bgcolor||' align=left><font face='||th_fontface||
			   ' size='||th_fontsize||' color='||th_fontcolor||'>';
        l_result := l_result||'Summary Message Template in HTML format. ('||
	                    l_user_lang||'_'||l_user_terr||')</th></tr>';
        l_result := l_result||'<tr><td bgcolor='||td_bgcolor||'><pre>';

        if (l_htm_body is not null) then
	    l_result := l_result||Wf_Notification.SubstituteSpecialChars(l_htm_body);
        else
	    l_result := l_result||'(not defined)';
        end if;

        l_result := l_result||'</pre></td></tr></table>';

        dbms_lob.WriteAppend(p_value, length(l_result), l_result);

     end if;

     -- Generate template based on session lang
     SetNLS(l_ses_lang, l_ses_terr);

     -- We don't want to show same template two times.
     if (l_user_lang <> l_ses_lang) THEN

        -- Generate template based on session lang
        SetNLS(l_ses_lang, l_ses_terr);

	select subject, body, html_body
	into   l_subj, l_txt_body, l_htm_body
	from   wf_messages_vl
	where  name = l_tname
	and    type = l_ttype;

        l_result := NULL;

        l_cells(1) := '25%:Message Type';
        l_cells(2) := l_ttype;
        l_cells(3) := '25%:Message Name';
        l_cells(4) := l_tname;

        Get_Table(l_cells, 2, 'V', l_temp);
        l_result := l_result||l_temp||wf_core.newline;
        l_cells.DELETE;

        dbms_lob.WriteAppend(p_value, length(l_result), l_result);

        l_result := NULL;

        l_result := '<table width='||table_width||'><tr>';
        l_result := l_result||'<tr><th bgcolor='||th_bgcolor||' align=left><font face='
                         || th_fontface|| ' size='||th_fontsize||' color='||th_fontcolor||'>';

        l_result := l_result||'Summary Message Template in TEXT format. ('||
	                      l_ses_lang||'_'||l_ses_terr||')</th></tr>';
        --l_result := l_result||wf_core.newline;
        l_result := l_result||'<tr><td bgcolor='||td_bgcolor||'><pre>';

        if (l_txt_body is not null) then
            l_result := l_result||Wf_Notification.SubstituteSpecialChars(l_txt_body);
        else
	   l_result := '(not defined or user language ' || l_ses_lang ||' is not installed )';
        end if;

        l_result := l_result||'</pre></td></tr>'||wf_core.newline;

        l_result := l_result||'<tr><th bgcolor='||th_bgcolor||' align=left><font face='||th_fontface||
			   ' size='||th_fontsize||' color='||th_fontcolor||'>';
        l_result := l_result||'Summary Message Template in HTML format. ('||
	                      l_ses_lang||'_'||l_ses_terr||')</th></tr>';
        l_result := l_result||'<tr><td bgcolor='||td_bgcolor||'><pre>';

        if (l_htm_body is not null) then
	    l_result := l_result||Wf_Notification.SubstituteSpecialChars(l_htm_body);
        else
	    l_result := l_result||'(not defined)';
        end if;

        l_result := l_result||'</pre></td></tr></table>';

        dbms_lob.WriteAppend(p_value, length(l_result), l_result);

     end if; -- If language installed

     -- Reset to the base NLS settings
     SetNLS(l_ses_lang, l_ses_terr);

 exception
     when no_data_found then
	wf_core.token('NAME', l_tname);
        wf_core.token('TYPE', l_ttype);
        wf_core.raise('WFNTF_MESSAGE');

     when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when generating Summary Notification Template for Role '||p_role;
      l_cells(3) := '10%:Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      dbms_lob.WriteAppend(p_value, length(l_result), l_result);

end get_Summary_Templates;


--
-- Get_Ntf_Message - <Explained in WFDIAGPS.pls>
--
procedure Get_Ntf_Message(p_nid   in number,
                          p_value in out nocopy clob)
is
   l_result  varchar2(32000);
   l_temp    varchar2(32000);
   l_cells   tdType;
   i         pls_integer;

   p_event_name  varchar2(100);
   p_event_key   varchar2(100);
   p_parameter_list wf_parameter_list_t;
   l_doc         clob;
   l_evt         wf_event_t;
   l_parameters  wf_parameter_list_t;
   l_erragt      wf_agent_t;
   l_role        varchar2(320);
   l_msg_type    varchar2(8);
   l_amount      number;
   l_chunksize   pls_integer;
   l_offset      pls_integer;
   l_buffer      varchar2(32767);
   l_buffer_size pls_integer;

   l_before      number;
   l_time_taken  varchar2(100);
begin
   p_event_name := 'oracle.apps.wf.notification.send';

   p_event_key  := p_nid;

   l_cells(1) := 'WH:<b>Generate Notification Message</b>';
   Get_Table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;

   l_result := l_result||'<table width='||table_width||'>';
   l_result := l_result||'<tr bgcolor='||th_bgcolor||'>';
   l_result := l_result||'<th align=left><font face='||th_fontface||' size='||th_fontsize||
                       ' color='||th_fontcolor||'>Notification Message in XML format</font></th>';

   begin
      select recipient_role, message_type
      into   l_role, l_msg_type
      from   wf_notifications
      where  notification_id = p_nid;
   exception
      when others then
         wf_core.context('WF_DIAGNOSTICS', 'Fetch Role', to_char(p_nid));
         raise;
   end;
   wf_event.AddParameterToList('NOTIFICATION_ID', to_char(p_nid), l_parameters);
   wf_event.AddParameterToList('ROLE', l_role, l_parameters);
   wf_event.AddParameterToList('GROUP_ID', to_char(p_nid), l_parameters);
   wf_event.addParameterToList('Q_CORRELATION_ID', l_msg_type, l_parameters);

   dbms_lob.CreateTemporary(l_doc, false, dbms_lob.Call);

   wf_mail.test_flag := TRUE;
   l_before := dbms_utility.get_time();
   begin
      l_doc := wf_xml.generate(p_event_name, p_event_key, l_parameters);
   exception
      when others then
         wf_core.context('WF_DIAGNOSTICS', 'Generate', p_event_name, p_event_key);
         raise;
   end;
   l_time_taken := to_char((dbms_utility.get_time()-l_before)/100);

   l_result := l_result||'<th align=right><font face='||th_fontface||' size='||th_fontsize||
                       ' color='||th_fontcolor||'>Time Taken to complete Generate: '||l_time_taken||' Seconds</font></th></tr></table>';
   l_result := l_result||'<table width='||table_width||'><tr><td bgcolor='||td_bgcolor||'><pre>';
   dbms_lob.WriteAppend(p_value, length(l_result), l_result);

   l_amount := dbms_lob.getlength(l_doc);
   l_chunksize := 10000;
   l_offset := 1;
   loop
      l_result := NULL;
      if (l_amount > l_chunksize) then
         dbms_lob.read(l_doc, l_chunksize, l_offset, l_buffer);
         l_result := Wf_Notification.SubstituteSpecialChars(l_buffer);
         l_amount := l_amount - l_chunksize;
         l_offset := l_offset + l_chunksize;
         l_buffer := NULL;
         dbms_lob.WriteAppend(p_value, length(l_result), l_result);
     else
         dbms_lob.read(l_doc, l_amount, l_offset, l_buffer);
         l_result := Wf_Notification.SubstituteSpecialChars(l_buffer);
         exit;
     end if;
  end loop;

   l_result := l_result||'</pre></td></tr></table>';
   dbms_lob.WriteAppend(p_value, length(l_result), l_result);
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when generating Notification Message Information for nid '||p_nid;
      l_cells(3) := '10%:Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      dbms_lob.WriteAppend(p_value, length(l_result), l_result);
end Get_Ntf_Message;


-- Get_Summary_Ntf_Message
-- Get the XML for oracle.apps.wf.notification.summary.send event
-- Output of WF_XML.generate function
--
procedure Get_Summary_Ntf_Message(p_role   in varchar2,
                                  p_value in out nocopy clob)
is
   l_result  varchar2(32000);
   l_temp    varchar2(32000);
   l_cells   tdType;
   i         pls_integer;

   p_event_name  varchar2(100);
   p_event_key   varchar2(100);
   p_parameter_list wf_parameter_list_t;
   l_doc         clob;
   l_evt         wf_event_t;
   l_parameters  wf_parameter_list_t;
   l_erragt      wf_agent_t;
   l_role        varchar2(320);
   l_msg_type    varchar2(8);
   l_amount      number;
   l_chunksize   pls_integer;
   l_offset      pls_integer;
   l_buffer      varchar2(32767);
   l_buffer_size pls_integer;

   l_before      number;
   l_time_taken  varchar2(100);
begin

   -- SSTOMAR
   p_event_name := 'oracle.apps.wf.notification.summary.send';
   -- event key would be Role name.
   p_event_key  := p_role;

   l_cells(1) := 'WH:<b>Generate Summary Notification Message</b>';
   Get_Table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;

   l_result := l_result||'<table width='||table_width||'>';
   l_result := l_result||'<tr bgcolor='||th_bgcolor||'>';
   l_result := l_result||'<th align=left><font face='||th_fontface||' size='||th_fontsize||
                       ' color='||th_fontcolor||'>Notification Message in XML format</font></th>';

   wf_event.AddParameterToList('ROLE_NAME', p_role, l_parameters);
   -- Set AQs correlation id to item type i.e. 'WFMAIL'
   wf_event.addParameterToList('Q_CORRELATION_ID', 'WFMAIL', l_parameters);

   -- wf_event.AddParameterToList('GROUP_ID', to_char(0), l_parameters);
   dbms_lob.CreateTemporary(l_doc, false, dbms_lob.Call);

   wf_mail.test_flag := TRUE;

   l_before := dbms_utility.get_time();

   begin
      l_doc :=  wf_xml.generate(p_event_name, p_event_key, l_parameters);
   exception
      when others then
         wf_core.context('WF_DIAGNOSTICS', 'Generate', p_event_name, p_event_key);
         raise;
   end;

   l_time_taken := to_char((dbms_utility.get_time()-l_before)/100);

   l_result := l_result||'<th align=right><font face='||th_fontface||' size='||th_fontsize||
                       ' color='||th_fontcolor||'>Time Taken to complete Generate: '||l_time_taken||' Seconds</font></th></tr></table>';
   l_result := l_result||'<table width='||table_width||'><tr><td bgcolor='||td_bgcolor||'><pre>';
   dbms_lob.WriteAppend(p_value, length(l_result), l_result);

   l_amount := dbms_lob.getlength(l_doc);
   l_chunksize := 10000;
   l_offset := 1;
   loop
      l_result := NULL;
      if (l_amount > l_chunksize) then
         dbms_lob.read(l_doc, l_chunksize, l_offset, l_buffer);
         l_result := Wf_Notification.SubstituteSpecialChars(l_buffer);
         l_amount := l_amount - l_chunksize;
         l_offset := l_offset + l_chunksize;
         l_buffer := NULL;
         dbms_lob.WriteAppend(p_value, length(l_result), l_result);
     else
         dbms_lob.read(l_doc, l_amount, l_offset, l_buffer);
         l_result := Wf_Notification.SubstituteSpecialChars(l_buffer);
         exit;
     end if;
  end loop;

   l_result := l_result||'</pre></td></tr></table>';
   dbms_lob.WriteAppend(p_value, length(l_result), l_result);
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when generating Summary Notification Message Information for Role '||p_role;
      l_cells(3) := '10%:Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      dbms_lob.WriteAppend(p_value, length(l_result), l_result);
end Get_Summary_Ntf_Message;


--
-- Get_GSC_Comp_Parameters - <Explained in WFDIAGPS.pls>
--
procedure Get_GSC_Comp_Parameters(p_comp_type in varchar2,
                                  p_comp_name in varchar2 default null,
                                  p_value     in out nocopy clob)
is
   l_result varchar2(32767);
   l_temp CLOB;
   l_cells  tdType;
   i        pls_integer;

   cursor c_comps is
   select component_id,
          component_name,
          component_status,
          startup_mode,
          container_type,
          inbound_agent_name,
          outbound_agent_name,
          correlation_id
   from   fnd_svc_components
   where  component_type = p_comp_type
   and    component_name like nvl(p_comp_name, '%');

   cursor c_params (p_comp_id in number) is
   select p.parameter_name,
          v.parameter_value,
          v.parameter_description,
          v.default_parameter_value
   from   fnd_svc_comp_param_vals_v v,
          fnd_svc_comp_params_b p
   where  p.encrypted_flag = 'N'
   and    v.component_id = p_comp_id
   and    v.parameter_id = p.parameter_id
   order by p.parameter_name;

begin
   l_cells(1) := 'WH:<b>GSC '||p_comp_type||' Component Parameters</b>';
   Get_Table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;
   dbms_lob.WriteAppend(p_value, length(l_result), l_result);

   for l_crec in c_comps loop
      l_cells(1) := '20%:Component Id';
      l_cells(2) := l_crec.component_id;
      l_cells(3) := '20%:Component Name';
      l_cells(4) := l_crec.component_name;
      l_cells(5) := '20%:Component Status';
      l_cells(6) := l_crec.component_status;
      l_cells(7) := '20%:Startup Mode';
      l_cells(8) := l_crec.startup_mode;
      l_cells(9) := '20%:Inbound Agent Name';
      l_cells(10) := l_crec.inbound_agent_name;
      l_cells(11) := '20%:Outbound Agent Name';
      l_cells(12) := l_crec.outbound_agent_name;
      l_cells(13) := '20%:Correlation Id';
      l_cells(14) := l_crec.correlation_id;

      Get_Table(l_cells, 2, 'V', l_result);
      l_result := l_result||wf_core.newline;
      l_cells.DELETE;
      dbms_lob.WriteAppend(p_value, length(l_result), l_result);
      l_result := NULL;

      l_cells(1) := '25%:Parameter Name';
      l_cells(2) := '25%:Parameter Value';
      l_cells(3) := '25%:Parameter Description';
      l_cells(4) := '25%:Default Value';
      i := 4;

      for l_prec in c_params(l_crec.component_id) loop
         l_cells(i+1) := l_prec.parameter_name;
         l_cells(i+2) := l_prec.parameter_value;
         l_cells(i+3) := l_prec.parameter_description;
         l_cells(i+4) := l_prec.default_parameter_value;
         i := i+4;
      end loop;

      dbms_lob.createTemporary(l_temp, TRUE, DBMS_LOB.CALL);
      Get_Table(l_cells, 4, 'H', l_temp);
      l_cells.DELETE;
      dbms_lob.append(dest_lob => p_value, src_lob => l_temp);
      l_result := NULL;
      dbms_lob.freeTemporary(l_temp);
   end loop;
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when generating Parameters Information for GSC Component Type '||p_comp_type;
      l_cells(3) := '10%:Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      dbms_lob.WriteAppend(p_value, length(l_result), l_result);
end Get_GSC_Comp_Parameters;


--
-- Get_GSC_Comp_ScheduledEvents - <Explained in WFDIAGPS.pls>
--
-- Returns scheduled events for a given component
-- Out
--  p_value
procedure Get_GSC_Comp_ScheduledEvents(p_comp_type in varchar2,
                                       p_comp_name in varchar2 default null,
                                       p_value     in out nocopy clob)
is
   l_result varchar2(32767);
   l_temp CLOB;
   l_cells  tdType;
   i        pls_integer;

   -- Cusrsor for components
   cursor c_comps is
   select component_id,
          component_name,
          component_status,
          startup_mode,
          container_type,
          inbound_agent_name,
          outbound_agent_name,
          correlation_id
   from   fnd_svc_components
   where  component_type = p_comp_type
   and    component_name like nvl(p_comp_name, '%')
   order by DECODE(component_status, 'RUNNING', 1, 'NOT_CONFIGURED', 3, 2) ASC ;

   -- cursor for scheduled events   for a component
   cursor c_params (p_comp_id in number) is
   SELECT component_request_id,
          job_id,
	  event_name,
	  event_params,
	  event_date,
	  event_frequency,
	  requested_by_user,
	  b.what,
          b.last_Date,
          b.last_sec
   from   fnd_svc_comp_requests a,
          user_jobs b
   WHERE  a.component_id = p_comp_id
   AND    a.job_id = b.job;

begin
   l_cells(1) := 'WH:<b>GSC '||p_comp_type||' Component Scheduled Events </b>';
   Get_Table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;
   dbms_lob.WriteAppend(p_value, length(l_result), l_result);

   for l_crec in c_comps loop
      l_cells(1) := '20%:Component Id';
      l_cells(2) := l_crec.component_id;
      l_cells(3) := '20%:Component Name';
      l_cells(4) := l_crec.component_name;
      l_cells(5) := '20%:Component Status';
      l_cells(6) := l_crec.component_status;


      Get_Table(l_cells, 2, 'V', l_result);
      l_result := l_result||wf_core.newline;
      l_cells.DELETE;
      dbms_lob.WriteAppend(p_value, length(l_result), l_result);
      l_result := NULL;

      l_cells(1) := '12%:Request Id';
      l_cells(2) := '12%:Job Id';
      l_cells(3) := '12%:Event Name';
      l_cells(4) := '12%:Event Params';
      l_cells(5) := '12%:Event Frequency';
      l_cells(6) := '16%:What';
      l_cells(7) := '12%:Last Date';
      l_cells(8) := '12%:Last Scheduled';

      i := 8;

      for l_prec in c_params(l_crec.component_id) loop
         l_cells(i+1) := l_prec.component_request_id;
         l_cells(i+2) := l_prec.job_id;
         l_cells(i+3) := l_prec.event_name;
         l_cells(i+4) := l_prec.event_params;
	 l_cells(i+5) := l_prec.event_frequency;
         l_cells(i+6) := l_prec.what;
	 l_cells(i+7) := l_prec.last_Date;
         l_cells(i+8) := l_prec.last_sec;

         i := i+8;
      end loop;

      -- Just add a blank row
      l_cells(i+1) := '';
      l_cells(i+2) := '';
      l_cells(i+3) := '';
      l_cells(i+4) := '';
      l_cells(i+5) := '';
      l_cells(i+6) := '';
      l_cells(i+7) := '';
      l_cells(i+8) := '';

      dbms_lob.createTemporary(l_temp, TRUE, DBMS_LOB.CALL);
      Get_Table(l_cells, 8, 'H', l_temp);
      l_cells.DELETE;

      dbms_lob.append(dest_lob => p_value, src_lob => l_temp);
      l_result := NULL;
      dbms_lob.freeTemporary(l_temp);
   end loop;
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when generating Scheduled Events Information for GSC Component Type '||p_comp_type;
      l_cells(3) := '10%:Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      dbms_lob.WriteAppend(p_value, length(l_result), l_result);
end Get_GSC_Comp_ScheduledEvents;

--
-- Get_Profile_Option_Values
-- Fetch the Profile Option Values that are relevant to the Mailer
--
procedure Get_Profile_Option_Values(p_value   in out nocopy clob)
is
   l_result varchar2(32767);
   l_temp   CLOB;
   l_cells  tdType;
   i        pls_integer;

   cursor c_opts is
   select profile_option_name, profile_option_value
   from fnd_profile_options a, fnd_profile_option_values b
   where a.application_id = b.application_id and
   a.profile_option_id = b.profile_option_id and
   a.profile_option_name in ('APPS_FRAMEWORK_AGENT', 'WF_MAIL_WEB_AGENT',
                             'AMPOOL_ENABLED', 'ICX_LIMIT_TIME',
                             'ICX_LIMIT_CONNECT', 'ICX_SESSION_TIMEOUT',
                             'FRAMEWORK_URL_TIMEOUT')
   and b.level_value = 0;

begin
   l_cells(1) := 'WH:<b>Profile Option Values</b>';
   Get_Table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;
   dbms_lob.WriteAppend(p_value, length(l_result), l_result);

   l_cells(1) := '25%:Parameter Name';
   l_cells(2) := '25%:Parameter Value';

   i := 2;
   for l_rec in c_opts loop
       l_cells(i+1) := l_rec.profile_option_name;
       l_cells(i+2) := l_rec.profile_option_value;
       i := i+2;
   end loop;

   Get_Table(l_cells, 2, 'H', l_result);
   l_cells.DELETE;
   dbms_lob.WriteAppend(p_value, length(l_result), l_result);
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when fetching Profile Option Values';
      l_cells(3) := '10%:Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      dbms_lob.WriteAppend(p_value, length(l_result), l_result);
end Get_Profile_Option_Values;



--
-- Get_Mailer_Tags
--    Returns a HTML table of all the Mailer Tag information
--
function Get_Mailer_Tags
return varchar2
is
   l_result varchar2(32000);
   l_temp   varchar2(32000);
   l_cells  tdType;
   i        pls_integer;
   cursor c_tags is
   select name,
          tag_id,
          action,
          pattern,
          allow_reload
   from   wf_mailer_tags
   order by name;
begin
   l_cells(1) := 'WH:<b>Workflow Notification Tags Value</b>';
   Get_Table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;

   l_cells(1) := '20%:Name';
   l_cells(2) := '10%:Tag ID';
   l_cells(3) := '20%:Action';
   l_cells(4) := '40%:Pattern';
   l_cells(5) := '10%:Reload';
   i := 5;

   for l_tag_rec in c_tags loop
      l_cells(i+1) := l_tag_rec.name;
      l_cells(i+2) := l_tag_rec.tag_id;
      l_cells(i+3) := l_tag_rec.action;
      l_cells(i+4) := l_tag_rec.pattern;
      l_cells(i+5) := l_tag_rec.allow_reload;
      i := i+5;
   end loop;
   Get_Table(l_cells, 5, 'H', l_temp);
   return l_result||l_temp;
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when generating Mailer Tags Information';
      l_cells(3) := '10%:Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      return l_result;
end Get_Mailer_Tags;

--
-- Get_Mailer_TOC  <Explained in WFDIAGPS.pls>
--
function Get_Mailer_TOC(p_nid in number)
return varchar2
is
   l_result varchar2(32000);
   l_temp   varchar2(32000);
   l_cells  tdType;

begin
   l_cells(1) := 'WH:<b>TABLE OF CONTENTS</b>';
   Get_Table(l_cells, 1, 'H', l_result);
   l_result := l_result||wf_core.newline;
   l_cells.DELETE;

   l_cells(1) := '20%:Serial No.';
   l_cells(2) := '80%:Contents';
   l_cells(3) := '1';
   l_cells(4) := '<a href="wfmlrdbg'||p_nid||'.html#ntf_item">Notification Item Information</a>';
   l_cells(5) := '2';
   l_cells(6) := '<a href="wfmlrdbg'||p_nid||'.html#ntf_rec_role">Notification Recipient Role Members</a>';
   l_cells(7) := '3';
   l_cells(8) := '<a href="wfmlrdbg'||p_nid||'.html#ntf_rec">Notification Recipient Role Information</a>';
   l_cells(9) := '4';
   l_cells(10) := '<a href="wfmlrdbg'||p_nid||'.html#ntf_routing_rules">Notification Recipient Routing Rules</a>';
   l_cells(11) := '5';
   l_cells(12) := '<a href="wfmlrdbg'||p_nid||'.html#ntf_more_info">Notification More Info Role Information</a>';
   l_cells(13) := '6';
   l_cells(14) := '<a href="wfmlrdbg'||p_nid||'.html#ntf_msg_attr_vals">Notification Message Attribute Values</a>';
   l_cells(15) := '7';
   l_cells(16) := '<a href="wfmlrdbg'||p_nid||'.html#ntf_attr_vals">Notification Attribute Values</a>';
   l_cells(17) := '8';
   l_cells(18) := '<a href="wfmlrdbg'||p_nid||'.html#ntf_msg_result_attr_vals">Notification Message Result Attribute Values</a>';
   l_cells(19) := '9';
   l_cells(20) := '<a href="wfmlrdbg'||p_nid||'.html#ntf_comments">Notification User Comments</a>';
   l_cells(21) := '10';
   l_cells(22) := '<a href="wfmlrdbg'||p_nid||'.html#def_q">Deferred Queue Status</a>';
   l_cells(23) := '11';
   l_cells(24) := '<a href="wfmlrdbg'||p_nid||'.html#error_q">Error Queue Status</a>';
   l_cells(25) := '12';
   l_cells(26) := '<a href="wfmlrdbg'||p_nid||'.html#err_ntf">Error Notification(s)</a>';
   l_cells(27) := '13';
   l_cells(28) := '<a href="wfmlrdbg'||p_nid||'.html#ntf_out_q">Notification OUT Queue Status</a>';
   l_cells(29) := '14';
   l_cells(30) := '<a href="wfmlrdbg'||p_nid||'.html#ntf_in_q">Notification IN Queue Status</a>';
   l_cells(31) := '15';
   l_cells(32) := '<a href="wfmlrdbg'||p_nid||'.html#ntf_templ">Message Templates</a>';
   l_cells(33) := '16';
   l_cells(34) := '<a href="wfmlrdbg'||p_nid||'.html#ntf_body">Generate Notification Message</a>';
   l_cells(35) := '17';
   l_cells(36) := '<a href="wfmlrdbg'||p_nid||'.html#ntf_body_out">Message Content from Notification OUT Queue</a>';
   l_cells(37) := '18';
   l_cells(38) := '<a href="wfmlrdbg'||p_nid||'.html#ntf_body_in">Message Content from Notification IN Queue</a>';
   l_cells(39) := '19';
   l_cells(40) := '<a href="wfmlrdbg'||p_nid||'.html#profile_opts">Profile Option Values</a>';
   l_cells(41) := '20';
   l_cells(42) := '<a href="wfmlrdbg'||p_nid||'.html#gsc_params">GSC Mailer Component Parameters</a>';
   l_cells(43) := '21';
   l_cells(44) := '<a href="wfmlrdbg'||p_nid||'.html#gsc_scheduled_evt">GSC Mailer Scheduled Events</a>';
   l_cells(45) := '22';

   l_cells(46) := '<a href="wfmlrdbg'||p_nid||'.html#ntf_tags">Mailer Tags</a>';
   Get_Table(l_cells, 2, 'H', l_temp);
   return l_result||l_temp;
exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when generating Table of Contents for nid '||p_nid;
      l_cells(3) := '10%:Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      return l_result;
end Get_Mailer_TOC;

--
-- Get_Ntf_Msg_From_Out
-- Fetches the notification content from WF_NOTIFICATION_OUT queue
--
procedure Get_Ntf_Msg_From_Out(p_nid      in varchar2,
                               p_corr_id  in varchar2,
                               p_value    in out nocopy clob)
is
   l_result  varchar2(32000);
   l_temp    varchar2(32000);
   l_cells   tdType;
   i         pls_integer := 1;


   cursor cout is
   select nout.user_data.text_lob lob
   from wf_notification_out nout
   where instr(nout.user_data.get_string_property('BES_EVENT_KEY'), p_nid) > 0
   and   (p_corr_id is null or nout.corrid like p_corr_id)
   order by ENQ_TIME;

   l_doc         clob;
   l_amount      number;
   l_chunksize   pls_integer;
   l_offset      pls_integer;
   l_buffer      varchar2(32767);

begin

   l_cells(1) := 'WH:<b>Content from WF_NOTIFICATION_OUT</b>';
   Get_Table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;

   l_result := l_result||'<table width='||table_width||'>';
   l_result := l_result||'<tr bgcolor='||th_bgcolor||'>';
   l_result := l_result||'<th align=left><font face='||th_fontface||' size='||th_fontsize||
               ' color='||th_fontcolor||'>Notification Message from WF_NOTIFICATION_OUT</font></th></tr>';

   for l_lob_rec in cout loop
     l_doc := l_lob_rec.lob;

     if (i=1) then
       l_result := l_result||'</table> ';
     end if;

     l_result := l_result||'<table width='||table_width||'><tr><td bgcolor='||td_bgcolor||'> <pre> ';
     dbms_lob.WriteAppend(p_value, length(l_result), l_result);
     l_amount := dbms_lob.getlength(l_doc);
     l_chunksize := 10000;
     l_offset := 1;

     loop
        l_result := NULL;
        if (l_amount > l_chunksize) then
           dbms_lob.read(l_doc, l_chunksize, l_offset, l_buffer);
           l_result := Wf_Notification.SubstituteSpecialChars(l_buffer);
           l_amount := l_amount - l_chunksize;
           l_offset := l_offset + l_chunksize;
           l_buffer := NULL;
           dbms_lob.WriteAppend(p_value, length(l_result), l_result);
        else
           dbms_lob.read(l_doc, l_amount, l_offset, l_buffer);
           l_result := Wf_Notification.SubstituteSpecialChars(l_buffer);
           exit;
        end if;
     end loop;

     l_result := l_result||'</pre></td></tr></table><br>';
     dbms_lob.WriteAppend(p_value, length(l_result), l_result);
     l_result := NULL;
     i := i+1;
   end loop;

   if (i=1) then
     l_result := l_result||'<tr><td bgcolor='||td_bgcolor||'>(not available)</td></tr></table>';
     dbms_lob.WriteAppend(p_value, length(l_result), l_result);
   end if;

exception
   when others then
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when fetching Notification Message ' ||
                    'from WF_NOTIFICATION_OUT for nid '||p_nid;
      l_cells(3) := '10%:Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      dbms_lob.WriteAppend(p_value, length(l_result), l_result);
end Get_Ntf_Msg_From_Out;

--
-- Get_Ntf_Msg_From_Out
-- Fetches the notification content from WF_NOTIFICATION_OUT queue
--
procedure Get_Ntf_Msg_From_Out(p_nid   in number,
                               p_value in out nocopy clob)
is
begin
   -- Call with Corr_Id as Null
   Get_Ntf_Msg_From_Out(p_nid => p_nid, p_corr_id => null, p_value => p_value);
 exception
   when others then
   DBMS_OUTPUT.PUT_LINE('ERROR =' || sqlerrm); -- DEBUG
   RAISE;  -- DEBUG
end Get_Ntf_Msg_From_Out;


--
-- Get_Summary_Msg_From_Out
-- Fetches the notification content from WF_NOTIFICATION_OUT queue
--
procedure Get_Summary_Msg_From_Out(p_role   in varchar2,
                                   p_value in out nocopy clob)
is
   l_result  varchar2(32000);
   l_temp    varchar2(32000);
   l_cells   tdType;
   i         pls_integer := 1;

   l_sql_str varchar2(4000);

   type t_ref_out is ref cursor;
   c_ntf_out  t_ref_out;


   l_doc         clob;
   l_amount      number;
   l_chunksize   pls_integer;
   l_offset      pls_integer;
   l_buffer      varchar2(32767);

begin
   l_cells(1) := 'WH:<b>Content from WF_NOTIFICATION_OUT AQ</b>';
   Get_Table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;

   l_result := l_result||'<table width='||table_width||'>';
   l_result := l_result||'<tr bgcolor='||th_bgcolor||'>';
   l_result := l_result||'<th align=left><font face='||th_fontface||' size='||th_fontsize||
                      ' color='||th_fontcolor||'>XML for Summary Message from ' ||
	              ' WF_NOTIFICATION_OUT AQ </font></th></tr>';
   l_result := l_result||'</table>';

   -- SQL string to get XML from wf_notification_out queue
   l_sql_str := ' select tab.user_data.text_lob '||
                ' from '||g_qowner||'.aq$wf_notification_out tab' ||
                ' where  instr(tab.user_data.get_string_property(''ROLE_NAME''), :p1) > 0 ' ||
                ' order by tab.enq_time desc';

   open c_ntf_out for l_sql_str using p_role;

   loop

     fetch c_ntf_out into l_doc;
     exit when c_ntf_out%NOTFOUND;

     l_result := l_result||'<table width='||table_width||'><tr><td bgcolor='||td_bgcolor||'><pre>';

     dbms_lob.WriteAppend(p_value, length(l_result), l_result);

     l_amount := dbms_lob.getlength(l_doc);

     l_chunksize := 10000;
     l_offset := 1;

     loop
        l_result := NULL;

        if (l_amount > l_chunksize) then
           dbms_lob.read(l_doc, l_chunksize, l_offset, l_buffer);
           l_result := Wf_Notification.SubstituteSpecialChars(l_buffer);
           l_amount := l_amount - l_chunksize;
           l_offset := l_offset + l_chunksize;
           l_buffer := NULL;
           dbms_lob.WriteAppend(p_value, length(l_result), l_result);
       else
           dbms_lob.read(l_doc, l_amount, l_offset, l_buffer);
           l_result := Wf_Notification.SubstituteSpecialChars(l_buffer);
           exit;
       end if;
     end loop;

     l_result := l_result||'</pre></td></tr></table><br>';
     dbms_lob.WriteAppend(p_value, length(l_result), l_result);
     l_result := NULL;

	 i := i+1;

   end loop; -- cursor loop

   if (i=1) then
     l_result := l_result||'<tr><td bgcolor='||td_bgcolor||'>(not available)</td></tr></table>';
     dbms_lob.WriteAppend(p_value, length(l_result), l_result);
   end if;

exception
   when others then
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when fetching Summary Ntf. Message from ' ||
                     ' WF_NOTIFICATION_OUT for role '||p_role;
      l_cells(3) := '10%:Error';
      l_cells(4) := sqlerrm;
	  Get_Table(l_cells, 2, 'V', l_result);
      dbms_lob.WriteAppend(p_value, length(l_result), l_result);
end Get_Summary_Msg_From_Out;

--
-- Get_Ntf_Msg_From_In
-- Fetches the notification content from WF_NOTIFICATION_IN queue
--
procedure Get_Ntf_Msg_From_In(p_nid       in varchar2,
                              p_corr_id   in varchar2,
                              p_value      in out nocopy clob)
is
   l_result  varchar2(32000);
   l_temp    varchar2(32000);
   l_cells   tdType;
   i         pls_integer := 1;

   cursor cin is
   select nin.user_data.text_lob lob
   from wf_notification_in nin
   where instr(nin.user_data.get_string_property('BES_EVENT_KEY'), p_nid) > 0
   and   (p_corr_id is null or upper(nin.corrid) like upper(p_corr_id))
   order by ENQ_TIME;

   l_doc         clob;
   l_amount      number;
   l_chunksize   pls_integer;
   l_offset      pls_integer;
   l_buffer      varchar2(32767);

begin
   l_cells(1) := 'WH:<b>Content from WF_NOTIFICATION_IN</b>';
   Get_Table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;

   l_result := l_result||'<table width='||table_width||'>';
   l_result := l_result||'<tr bgcolor='||th_bgcolor||'>';
   l_result := l_result||'<th align=left><font face='||th_fontface||' size='||th_fontsize||
               ' color='||th_fontcolor||'>Notification Message from WF_NOTIFICATION_IN</font></th></tr>';

   for l_lob_rec in cin loop
     l_doc := l_lob_rec.lob;
     if (i=1) then
       l_result := l_result||'</table>';
     end if;
     l_result := l_result||'<table width='||table_width||'><tr><td bgcolor='||td_bgcolor||'><pre>';
     dbms_lob.WriteAppend(p_value, length(l_result), l_result);
     l_amount := dbms_lob.getlength(l_doc);
     l_chunksize := 10000;
     l_offset := 1;
     loop
        l_result := NULL;
        if (l_amount > l_chunksize) then
           dbms_lob.read(l_doc, l_chunksize, l_offset, l_buffer);
           l_result := Wf_Notification.SubstituteSpecialChars(l_buffer);
           l_amount := l_amount - l_chunksize;
           l_offset := l_offset + l_chunksize;
           l_buffer := NULL;
           dbms_lob.WriteAppend(p_value, length(l_result), l_result);
       else
           dbms_lob.read(l_doc, l_amount, l_offset, l_buffer);
           l_result := Wf_Notification.SubstituteSpecialChars(l_buffer);
           exit;
       end if;
     end loop;

     l_result := l_result||'</pre></td></tr></table><br>';
     dbms_lob.WriteAppend(p_value, length(l_result), l_result);
     l_result := NULL;
     i := i+1;
   end loop;

   if (i=1) then
     l_result := l_result||'<tr><td bgcolor='||td_bgcolor||'>(not available)</td></tr></table>';
     dbms_lob.WriteAppend(p_value, length(l_result), l_result);
   end if;

exception
   when others then
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when fetching Notification Message from WF_NOTIFICATION_IN for nid '||p_nid;
      l_cells(3) := '10%:Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      dbms_lob.WriteAppend(p_value, length(l_result), l_result);
end Get_Ntf_Msg_From_In;

--
-- Get_Ntf_Msg_From_In
-- Fetches the notification content from WF_NOTIFICATION_IN queue
--
procedure Get_Ntf_Msg_From_In(p_nid   in number,
                              p_value in out nocopy clob)
is
begin

  Get_Ntf_Msg_From_In(p_nid => p_nid, p_corr_id=> null, p_value=>p_value);

END Get_Ntf_Msg_From_In;

--
-- Bug 6677333: Modified the logic so that error message will be retrieved
-- using both wf_notification_attributes and wf_item_activity_statuses tables
--
-- Get_Error_Ntf_Details
--   Gets the Details of the Error Notification, if any
function Get_Error_Ntf_Details(p_event_name in varchar2,
                               p_event_key  in varchar2)
return varchar2
is
    l_result     varchar2(2000);
    l_temp       varchar2(32000);
    l_cells      tdType;
    i            pls_integer := 1;
    l_nid        number;
    l_date       varchar2(20);
    l_subject    varchar2(2000);
    l_err_msg    varchar2(2000);
    l_err_name   varchar2(30);
    l_err_stack  varchar2(4000);
    l_ntf_id     number;

    cursor c_ntf is
    select wfn.notification_id nid, to_char(begin_date, 'DD-MON-YYYY HH:MI:SS') dt, subject ntf_sub
    from   wf_notifications wfn, wf_notification_attributes wfa, wf_notification_attributes wfna
    where  wfn.notification_id = wfa.notification_id and wfn.notification_id = wfna.notification_id
    and    wfn.message_type = 'WFERROR'
    and    wfn.message_name in ('DEFAULT_EVENT_ERROR' , 'DEFAULT_EVENT_EXT_ERROR')
    and    wfa.name         = 'EVENT_NAME'
    and    wfa.text_value like p_event_name
    and    wfna.name        = 'EVENT_KEY'
    and    wfna.text_value  = p_event_key
    order by 1;

    cursor c_ntf_attr(p_nid in number) is
    select decode(name, 'ERROR_NAME', 'Error', 'ERROR_MESSAGE', 'Error Message',
                        'ERROR_STACK', 'Error Stack', name) name, text_value value
    from   wf_notification_attributes
    where  notification_id = p_nid
    and    name in ('ERROR_NAME', 'ERROR_MESSAGE', 'ERROR_STACK');

    c_ntf_rec       c_ntf%rowtype;
    c_ntf_attr_rec  c_ntf_attr%rowtype;

begin

   l_ntf_id := to_number(p_event_key);

   l_cells(1) := 'WH:<b>Error Notification(s)</b>';
   Get_table(l_cells, 1, 'H', l_temp);
   l_cells.DELETE;


   begin

	SELECT  wn.notification_id, to_char(wn.begin_date, 'DD-MON-YYYY HH:MI:SS'), subject,
	        error_message, error_name, error_stack
        INTO    l_nid, l_date, l_subject, l_err_msg, l_err_name, l_err_stack
	FROM    wf_notifications wn,
	        wf_item_activity_statuses wias
        WHERE   wn.notification_id = l_ntf_id
	AND     wias.notification_id = l_ntf_id
        AND     wn.message_type = wias.item_type
	AND     wn.item_key = wias.item_key;


        if ((l_err_msg is not null) or (l_err_name is not null) or (l_err_stack is not null)) then

           l_cells(1) := '20%:<br>Notification ID';
           l_cells(2) := '<b><br>'||l_nid||'</b>';
           Get_Table(l_cells, 2, 'V', l_result);
           l_temp := l_temp || l_result;

           l_cells(1) := '20%:Date';
           l_cells(2) := l_date;
           Get_Table(l_cells, 2, 'V', l_result);
           l_temp := l_temp || l_result;

           l_cells(1) := '20%:Notification Subject';
           l_cells(2) := l_subject;
           Get_Table(l_cells, 2, 'V', l_result);
           l_temp := l_temp || l_result;

           l_cells(1) := '20%:Error Message';
           l_cells(2) := l_err_msg;
           Get_Table(l_cells, 2, 'V', l_result);
           l_temp := l_temp || l_result;

           l_cells(1) := '20%:Error';
           l_cells(2) := l_err_name;
           Get_Table(l_cells, 2, 'V', l_result);
           l_temp := l_temp || l_result;

           l_cells(1) := '20%:Error Stack';
           l_cells(2) := l_err_stack;
           Get_Table(l_cells, 2, 'V', l_result);
           l_temp := l_temp || l_result;

           i := i+1;

        end if;

   exception
        -- just handle no_data_found exception in case notification is
	-- sent using wf_notification.send() API
	when no_data_found then null;

   end;


   for c_ntf_rec in c_ntf loop
      l_cells(1) := '20%:<br>Notification ID';
      l_cells(2) := '<b><br>'||c_ntf_rec.nid||'</b>';
      Get_Table(l_cells, 2, 'V', l_result);
      l_temp := l_temp || l_result;

      l_cells(1) := '20%:Date';
      l_cells(2) := c_ntf_rec.dt;
      Get_Table(l_cells, 2, 'V', l_result);
      l_temp := l_temp || l_result;

      l_cells(1) := '20%:Notification Subject';
      l_cells(2) := c_ntf_rec.ntf_sub;
      Get_Table(l_cells, 2, 'V', l_result);
      l_temp := l_temp || l_result;

      for c_ntf_attr_rec in c_ntf_attr(c_ntf_rec.nid) loop
        l_cells(1) := '20%:'||c_ntf_attr_rec.name;

        if(c_ntf_attr_rec.value is not null) then
          l_cells(2) := c_ntf_attr_rec.value;
        else
          l_cells(2) := ' ';
        end if;
        Get_Table(l_cells, 2, 'V', l_result);
        l_temp := l_temp || l_result;
      end loop;
      i := i+1;
    end loop;

    if (i=1) then
      l_cells.DELETE;
      l_cells(1) := '100%:No error notifications were found';
      l_cells(2) := '';
      Get_Table(l_cells, 1, 'H', l_result);
      l_temp := l_temp || l_result;
    end if;

   return l_temp;

exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Exception encountered when fetching Error Notification Details';
      l_cells(3) := '10%:Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      return l_result;

end Get_Error_Ntf_Details;

--
-- Get_Mailer_Debug - <Explained in WFDIAGPS.pls>
--
procedure Get_Mailer_Debug(p_nid   in number,
                           p_value out nocopy clob)
is
   l_value       clob;
   l_temp_result varchar2(32000);
   l_amount      number;
   l_dummy       varchar2(1);
   l_cells       tdType;
   l_anchor      varchar2(100);
   l_head        varchar2(100);
begin
   dbms_lob.CreateTemporary(l_value, TRUE, dbms_lob.session);
   dbms_lob.CreateTemporary(l_temp, TRUE, dbms_lob.session);
   l_head := '<html><head><title>'||to_char(p_nid)||' - wfmlrdbg output</title></head><body>';
   dbms_lob.WriteAppend(l_value, length(l_head), l_head);

   begin
      select null
      into   l_dummy
      from   wf_notifications
      where  notification_id = p_nid;
   exception
      when NO_DATA_FOUND then
         l_cells(1) := 'WH:<b>Notification Id '||p_nid||' has been purged and is not available in the Database.</b>';
         Get_Table(l_cells, 1, 'H', l_temp_result);
         l_cells.DELETE;
         dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

	 -- Profile Option Values
	 l_temp_result := '<br>'||wf_core.newline;
	 dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
	 Get_Profile_Option_Values(l_value);

	 -- GSC Mailer component parameters
	 l_temp_result := '<br>'||wf_core.newline;
	 dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
	 Get_GSC_Comp_Parameters('WF_MAILER', null, l_value);

	 -- GSC Mailer component scheduled events
	 l_temp_result := '<br>'||wf_core.newline;
	 dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
	 Get_GSC_Comp_ScheduledEvents('WF_MAILER', null, l_value);

         -- Mailer Tags
	 l_temp_result := '<br>'||Get_Mailer_Tags()||wf_core.newline;
         dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

         -- Send the final HTML Output to the caller
	 dbms_lob.WriteAppend(l_value, length(g_end), g_end);

         p_value := l_value;
         return;
   end;

   -- Get Table of Contents
   l_temp_result := '<a name=top>'||Get_Mailer_TOC(p_nid)||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Get Notfication Item Info
   l_temp_result := '<br><a name=ntf_item>'||Get_Ntf_Item_Info(p_nid)||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Get Users belonging to the recipient Role
   l_temp_result := '<br><a name=ntf_rec_role>'||Get_Ntf_Role_Users(p_nid)||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Get the recipient Role Information
   l_temp_result := '<br><a name=ntf_rec>'||Get_Ntf_Role_Info(p_nid)||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Get the Recipient Role routing rules information
   l_temp_result := '<br><a name=ntf_routing_rules>'||Get_Routing_Rules(p_nid)||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Get the Nore Info Role Information
   l_temp_result := '<br><a name=ntf_more_info>'||Get_Ntf_More_Info(p_nid)||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   l_temp_result := '<br><a name=ntf_msg_attr_vals>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
   Get_Ntf_Msg_Attrs(p_nid, l_value);
   l_temp_result := '<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   l_temp_result := '<br><a name=ntf_attr_vals>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
   Get_Ntf_Attrs(p_nid, l_value);
   l_temp_result := '<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Get Notification result attribute values
   l_temp_result := '<br><a name=ntf_msg_result_attr_vals>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
   Get_Ntf_Msg_Result_Attrs(p_nid, l_value);
   l_temp_result := '<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Get the Notification User comments
   l_temp_result := '<br><a name=ntf_comments>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
   Get_User_Comments(p_nid, l_value);
   l_temp_result := '<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Queue Statuses
   -- Deferred queue status
   l_temp_result := '<br><a name=def_q>'
                    ||Get_Event_Queue_Status(p_queue_name => WFD_DEFERRED,
                                             p_event_name => 'oracle.apps.wf.notification%',
                                             p_event_key  => to_char(p_nid))
                    ||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Error Queue Status
   l_temp_result := '<br><a name=error_q>'
                    ||Get_Event_Queue_Status(p_queue_name => WFD_ERROR,
                                             p_event_name => 'oracle.apps.wf.notification%',
                                             p_event_key  => to_char(p_nid))
                    ||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Error Notification Details
   l_temp_result := '<br><a name=err_ntf>'
                    ||Get_Error_Ntf_Details(p_event_name => 'oracle.apps.wf.notification.%',
                                            p_event_key  => p_nid)
                    ||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Notification OUT Queue Status
   l_temp_result := '<br><a name=ntf_out_q>'
                    ||Get_JMS_Queue_Status(p_queue_name => WFD_NTF_OUT,
                                           p_event_name => 'oracle.apps.wf.notification%',
                                           p_event_key  => to_char(p_nid))
                    ||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Notification IN Queue Status
   l_temp_result := '<br><a name=ntf_in_q>'
                    ||Get_JMS_Queue_Status(p_queue_name => WFD_NTF_IN,
                                           p_event_name => 'oracle.apps.wf.notification%',
                                           p_event_key  => to_char(p_nid))
                    ||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Email and Notification message definition
   l_temp_result := '<br><a name=ntf_templ>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
   Get_Ntf_Templates(p_nid, l_value);
   l_temp_result := '<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- XML Message for the notification
   l_temp_result := '<br><a name=ntf_body>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
   Get_Ntf_Message(p_nid, l_value);
   l_temp_result := '<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- XML Message for the notification from WF_NOTIFICATION_OUT
   l_temp_result := '<br><a name=ntf_body_out>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
   Get_Ntf_Msg_From_Out(p_nid, l_value);
   l_temp_result := '<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- XML Message for the notification from WF_NOTIFICATION_IN
   l_temp_result := '<br><a name=ntf_body_in>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
   Get_Ntf_Msg_From_In(p_nid, l_value);
   l_temp_result := '<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Profile Option Values
   l_temp_result := '<br><a name=profile_opts>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
   Get_Profile_Option_Values(l_value);
   l_temp_result := '<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- GSC Mailer component parameters
   l_temp_result := '<br><a name=gsc_params>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
   Get_GSC_Comp_Parameters('WF_MAILER', null, l_value);
   l_temp_result := '<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- GSC Mailer component scheduled events
   l_temp_result := '<br><a name=gsc_scheduled_evt>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
   Get_GSC_Comp_ScheduledEvents('WF_MAILER', null, l_value);
   l_temp_result := '<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Mailer Tags
   l_temp_result := '<br><a name=ntf_tags>'||Get_Mailer_Tags()||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfmlrdbg'||p_nid||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);


   -- Send the final HTML Output to the caller
   dbms_lob.WriteAppend(l_value, length(g_end), g_end);
   p_value := l_value;
exception
   when others then
      l_temp_result := 'Error encountered while Generating Mailer Debug Information for nid '||p_nid||wf_core.newline;
      l_temp_result := l_temp_result||'Error Name : '||wf_core.newline||wf_core.error_name;
      l_temp_result := l_temp_result||'Error Stack: '||wf_core.newline||wf_core.error_stack;
      dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
      dbms_lob.WriteAppend(l_value, length(g_end), g_end);
      p_value := l_value;
end Get_Mailer_Debug;

--
-- Get_Control_Queue_Status  - <Explained in WFDIAGPS.pls>
--
procedure Get_Control_Queue_Status(p_value out nocopy clob)
is
    l_subscriber_number NUMBER := 0;

    queue_corruption EXCEPTION;
    PRAGMA EXCEPTION_INIT(queue_corruption, -24026);

    job_count NUMBER ;
    l_temp_result varchar2(32000);
    l_value clob;
    l_dead_subscriber NUMBER;
    l_subscriber varchar2(300);

    type t_controlq is ref cursor;
    l_unresponded_subs_c t_controlq;
begin
    dbms_lob.CreateTemporary(l_value, TRUE, dbms_lob.Session);
    -- Set up Header
    l_temp_result := g_head ;
    dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

    l_temp_result :=  '<table width="100%">';

    -- Removed check for concurrent request in order to make this work in Standalone too
    -- Originally the control queue cleanup is set up as DBMS job by wfctqcln.sql.
    -- Check if the dbms_job is running
    select count(1) into job_count
    from   user_jobs
    where  upper(what) like '%WF_BES_CLEANUP.CLEANUP_SUBSCRIBERS%'
    and    broken = 'N';

    if (job_count = 0) then
      l_temp_result := l_temp_result || '<tr><td>DBMS JOB for Control Queue cleanup is not Running</td></tr> ';
    end if;
    l_temp_result := l_temp_result || ' </table>';

    dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

    l_temp_result :=  '<table width="100%">';

    execute immediate 'SELECT COUNT(1) FROM '||g_qowner||'.AQ$WF_CONTROL_S' INTO l_subscriber_number;

    -- If the number is less than 1024, return
    -- the message.
    IF (l_subscriber_number < 1024) THEN
        -- return message saying that the number of subscriber is OK.
        l_temp_result := l_temp_result || '<tr><td>WF Control Queue has less than 1024 active subscribers.</td></tr> </table> ';
        dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
        dbms_lob.WriteAppend(l_value, length(g_end), g_end);
        p_value := l_value;
        return;
    END IF;


    l_temp_result := l_temp_result || '<tr><td>1024 Subscribers have subscribed to WF_CONTROL queue.</td></tr> ';

    -- Now try to remove an unused subscriber.
    execute immediate 'SELECT COUNT(1) '||
    'FROM WF_BES_SUBSCRIBER_PINGS wbsp, '||g_qowner||'.AQ$WF_CONTROL_S sub '||
    'WHERE sub.name = wbsp.subscriber_name '||
    'AND   sub.queue = wbsp.queue_name '||
    'AND   wbsp.queue_name = ''WF_CONTROL'' '||
    'AND   wbsp.status IN (''REMOVE_FAILED'', ''PINGED'') '||
    'AND   wbsp.ping_time < SYSDATE - 1/48'
    INTO l_dead_subscriber;

    IF (l_dead_subscriber > 0) THEN
       l_temp_result := l_temp_result || '<tr><td>' || l_dead_subscriber || ' dead subscribers subscribe to WF_CONTROL queue. </td></tr> ';

       -- Ref cursor in order to make the schema name based on WF_SCHEMA.
       OPEN l_unresponded_subs_c FOR
       'SELECT wbsp.subscriber_name ' ||
       'FROM WF_BES_SUBSCRIBER_PINGS wbsp, '||g_qowner||'.AQ$WF_CONTROL_S sub ' ||
       'WHERE sub.name = wbsp.subscriber_name '||
       'AND   sub.queue = wbsp.queue_name '||
       'AND   wbsp.queue_name = ''WF_CONTROL'' '||
       'AND   wbsp.status IN (''REMOVE_FAILED'', ''PINGED'') '||
       'AND   wbsp.ping_time < SYSDATE - 1/48';

       FETCH l_unresponded_subs_c INTO l_subscriber;
       CLOSE l_unresponded_subs_c;

       -- manually remove the AQ subscriber.
       BEGIN
         dbms_aqadm.remove_subscriber(
           g_qowner||'.WF_CONTROL',
           sys.aq$_agent(l_subscriber, null,null));
         l_temp_result := l_temp_result || '<tr><td> Removing one dead subscriber succeeded </td></tr> ';

       EXCEPTION
         WHEN queue_corruption THEN
              l_temp_result := l_temp_result || '<tr><td> ORA-24026 happened, WF_CONTROL queue corrupted. Please re-create WF_CONTROL queue.</td></tr>';

         WHEN OTHERS THEN
              l_temp_result := l_temp_result || '<tr><td>Remove Subscriber operation failed with Error ' || SQLCODE || ' message ' || SQLERRM || ' </td></tr>';
       END;
    END IF;

    l_temp_result := l_temp_result || '</table>';
    dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

    -- Send the final HTML Output to the caller
    dbms_lob.WriteAppend(l_value, length(g_end), g_end);

    p_value := l_value;
end Get_Control_Queue_Status;

--
-- Get_BES_Clone_Status - <Explained in WFDIAGPS.pls>
--
procedure Get_BES_Clone_Status(p_value out nocopy clob)
is
    l_sys_name VARCHAR2(240);
    l_temp_result VARCHAR2(32000);
    l_value clob;
    cursor c_agent is
        SELECT '<tr><td> ' || a.NAME || '</td>' agent_name ,
           '<td> ' ||  s.NAME || '</td>' sys_name,
           '<td> ' || a.status ||'</td></tr>' status
        FROM   WF_AGENTS a, WF_SYSTEMS s
        WHERE  a.system_guid = s.guid
        AND    a.name IN ('WF_CONTROL', 'WF_NOTIFICATION_IN', 'WF_NOTIFICATION_OUT',
                          'WF_DEFERRED', 'WF_ERROR');

    cursor c_sub is
        SELECT e.name EVENT_NAME,
               DECODE(sub.guid, NULL, 'Subscription Not Defined',
                                DECODE(sub.rule_function, NULL, 'Not  Defined',
                                                          sub.rule_function || '@' || s.name)) RULE_FUNCTION,
               DECODE(sub.guid, NULL, 'Subscription Not Defined',
                                DECODE(sub.out_agent_guid, NULL, 'Not Defined',
                                                           oa.name || '@' || oas.name)) OUT_AGENT,
               sub.status STATUS
        FROM   WF_EVENTS e, WF_SYSTEMS s, WF_EVENT_SUBSCRIPTIONS sub, WF_AGENTS oa, WF_SYSTEMS oas
        WHERE  e.NAME IN  ('oracle.apps.wf.notification.send.group',
                           'oracle.apps.fnd.cp.gsc.bes.control.group',
                           'oracle.apps.wf.notification.summary.send')
        AND    e.guid = sub.event_filter_guid(+)
        AND    sub.licensed_flag(+) = 'Y'
        AND    e.licensed_flag = 'Y'
        AND    sub.system_guid = s.guid(+)
        AND    oa.guid(+) = sub.out_agent_guid
        AND    oa.system_guid = oas.guid(+)
        ORDER BY e.name;
begin
    dbms_lob.CreateTemporary(l_value, TRUE, dbms_lob.Session);
    -- Set up Header
    l_temp_result := g_head ;
    dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

    l_temp_result :=  '<table width="100%">';

    SELECT WF_EVENT.LOCAL_SYSTEM_NAME INTO l_sys_name FROM dual;

    l_temp_result := l_temp_result || '<tr><td>The local System Name is ' || l_sys_name || '</td></tr>';

    l_temp_result := l_temp_result || '</table>';
    dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

    l_temp_result :=  '<table width="100%">';
    l_temp_result := l_temp_result || '<tr><td class=h>Agent Name </td><td class=h>System Name</td><td class=h>Status</td></tr>';

    for r_agent in c_agent loop
        l_temp_result := l_temp_result || r_agent.agent_name || r_agent.sys_name || r_agent.status;
    end loop;

    l_temp_result := l_temp_result || '</table>';
    dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

    l_temp_result :=  '<table width="100%">';
    l_temp_result := l_temp_result || '<tr><td>Event Name </td><td class=h>Subscription Rule Function</td><td class=h>Subscription Out Agent</td><td class=h>Status</td></tr>';

    for r_sub in c_sub loop
        l_temp_result := l_temp_result || '<tr><td> '|| r_sub.event_name ||'</td>';
        l_temp_result := l_temp_result || '<td>  '|| r_sub.RULE_FUNCTION ||'</td>';
        l_temp_result := l_temp_result || '<td>  '|| r_sub.OUT_AGENT ||'</td>';
        l_temp_result := l_temp_result || '<td>  '|| r_sub.STATUS ||'</td></tr>';

    end loop;
    l_temp_result := l_temp_result || '</table>';
    dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);


    -- Send the final HTML Output to the caller
    dbms_lob.WriteAppend(l_value, length(g_end), g_end);

    p_value := l_value;
end Get_BES_Clone_Status;

--
-- Show  <Explained in WFDIAGPS.pls
--
procedure Show(p_value   in varchar2)
is
  l_amount     number;
  l_chunksize  pls_integer;
  l_offset     pls_integer;
  l_buffer     varchar2(4000);
  l_buffer_size pls_integer;
  l_last_cr    pls_integer;
  l_last_gt    pls_integer;
  l_last_sc    pls_integer;
  l_value      varchar2(32000);
begin
  l_amount := length(p_value);
  l_chunksize := 100;
  l_offset := 1;
  l_buffer_size := 0;
  if (l_amount > 0) then
    loop
      l_last_cr := 0;
      if (l_amount > l_chunksize) then
        l_buffer := substr(p_value, l_offset, l_chunksize);
        l_last_cr := instr(l_buffer, wf_core.newline, -1);
        l_last_gt := instr(l_buffer, '>', -1);
        l_last_sc := instr(l_buffer, ';', -1);
        if (l_last_cr > 1) then
           l_buffer_size := l_last_cr;
        elsif (l_last_gt > 1) then
           l_buffer_size := l_last_gt;
        elsif (l_last_sc > 1) then
           l_buffer_size := l_last_sc;
        else
           l_buffer_size := l_chunksize;
        end if;
        dbms_output.put_line(substr(l_buffer, 1, l_buffer_size));
        l_amount := l_amount - l_buffer_size + 1;
        l_offset := l_offset + l_buffer_size;
        l_buffer := '';
      else
        l_buffer := substr(p_value, l_offset, l_amount);
        dbms_output.put_line(l_buffer);
        exit;
      end if;
    end loop;
  end if;
end Show;

--
-- Show  <Explained in WFDIAGPS.pls
--
procedure Show(p_value   in CLOB)
is
  l_amount     number;
  l_chunksize  pls_integer;
  l_offset     pls_integer;
  l_buffer     varchar2(4000);
  l_tmpbuff    varchar2(32000);
  l_buffer_size pls_integer;
  l_last_cr    pls_integer;
  l_last_gt    pls_integer;
  l_last_sc    pls_integer;
  l_value      varchar2(32000);
begin
  l_amount := dbms_lob.GetLength(p_value);
  l_chunksize := 100;
  l_offset := 1;
  l_buffer_size := 0;
  if (l_amount > 0) then
    loop
      l_last_cr := 0;
      if (l_amount > l_chunksize) then
        dbms_lob.read(p_value, l_chunksize, l_offset, l_buffer);
        l_last_cr := instr(l_buffer, wf_core.newline, -1);
        l_last_gt := instr(l_buffer, '>', -1);
        l_last_sc := instr(l_buffer, ';', -1);
        if (l_last_cr > 1) then
           l_buffer_size := l_last_cr;
        elsif (l_last_gt > 1) then
           l_buffer_size := l_last_gt;
        elsif (l_last_sc > 1) then
           l_buffer_size := l_last_sc;
        else
           l_buffer_size := l_chunksize;
        end if;
        dbms_output.put_line(substr(l_buffer, 1, l_buffer_size));
        l_amount := l_amount - l_buffer_size;
        l_offset := l_offset + l_buffer_size;
        l_buffer := '';
      else
        dbms_lob.read(p_value, l_amount, l_offset, l_buffer);
        dbms_output.put_line(l_buffer);
        exit;
      end if;
    end loop;
  end if;
end Show;

--
-- CheckObjectsValidity - <Explained in WFDIAGS.pls>
--
procedure CheckObjectsValidity(p_status  out nocopy varchar2,
                               p_report  out nocopy varchar2)
is
  CURSOR c_objs IS
  SELECT uo.object_name name,
         uo.object_type type,
         uo.status status
  FROM   user_objects uo
  WHERE  (uo.object_name LIKE 'WF%'
          OR uo.object_name LIKE 'ECX%'
          OR uo.object_name LIKE 'FND_SVC_%')
  AND    uo.object_type IN ('PACKAGE', 'PACKAGE BODY')
  AND    uo.status <> 'VALID'
  ORDER BY 1, 2;

  l_invalids  varchar2(32000);
  obj_rec c_objs%ROWTYPE;
  l_temp  varchar2(32000);
  l_cells tdType;
  i       pls_integer;
begin
  -- Get the title
  l_cells(1) := 'WH:<b>Workflow/XML Gateway Database invalid objects report.</b>';
  Get_Table(l_cells, 1, 'H', l_temp);
  l_cells.DELETE;
  p_report := l_temp;

  open c_objs;
  fetch c_objs into obj_rec;
  if (c_objs%NOTFOUND) then
     p_status := 'SUCCESS';
     l_cells(1) := 'TD:All the Workflow and XML Gateway Database objects are valid.';
     Get_Table(l_cells, 1, 'H', l_temp);
     l_cells.DELETE;
     p_report := p_report || l_temp;
  else
     p_status := 'FAIL';
     l_cells(1) := '50%:Object Name';
     l_cells(2) := '50%:Object Type';
     i := 2;
     loop
        l_cells(i+1) := obj_rec.name;
        l_cells(i+2) := obj_rec.type;
        i := i+2;
        fetch c_objs into obj_rec;
        exit when c_objs%NOTFOUND;
     end loop;
     Get_table(l_cells, 2, 'H', l_temp);
     l_cells.DELETE;
     p_report := p_report || l_temp;
  end if;
  close c_objs;
exception
  when others then
     -- No SQLException is sent to Java
     p_status := 'FAIL';
     l_cells(1) := 'TD:<b>Error: '||sqlerrm||'</b>';
     Get_table(l_cells, 1, 'H', l_temp);
     p_report := p_report || l_temp;
     l_cells.DELETE;
     close c_objs;
end CheckObjectsValidity;

--
-- CheckXMLParserStatus
--   Checks the installation status of XML Parser.
procedure CheckXMLParserStatus(p_status  out nocopy varchar2,
                               p_report  out nocopy varchar2)
is
  CURSOR c_dom IS
  SELECT status, owner
  FROM   all_objects
  WHERE  object_name = 'XMLDOM'
  AND    object_type = 'PACKAGE'
  AND    (owner in ('SYS', 'SYSTEM') OR owner = g_qowner)
  UNION
  SELECT status, user
  FROM   user_objects
  WHERE  object_name = 'XMLDOM'
  AND    object_type = 'PACKAGE';

  CURSOR c_java IS
  SELECT object_name, status, owner
  FROM   all_objects
  WHERE  object_type = 'JAVA RESOURCE'
  AND    object_name like '%xmlparser%'
  AND    (owner in ('SYS', 'SYSTEM') OR owner = g_qowner)
  UNION
  SELECT object_name, status, user
  FROM   user_objects
  WHERE  object_type = 'JAVA RESOURCE'
  AND    object_name like '%xmlparser%';

  dom_rec   c_dom%ROWTYPE;
  java_rec  c_java%ROWTYPE;

  l_temp  varchar2(32000);
  l_cells tdType;
  i       pls_integer;
  l_xml_ver varchar2(1000);
begin

  -- Get the XML Parser version
  begin
     l_xml_ver := Wf_Diagnostics.GetXMLParserVersion();
  exception
    when others then
       l_xml_ver := 'Unable to retrieve XML Parser Version due to error ['||sqlerrm||']';
  end;

  l_cells(1) := 'WH:<b>XML Parser Version:</b> '||l_xml_ver;
  Get_Table(l_cells, 1, 'H', l_temp);
  p_report := l_temp||'<br>';
  l_cells.DELETE;

  l_cells(1) := 'WH:<b>XML Parser Installation Status.</b>';
  Get_Table(l_cells, 1, 'H', l_temp);
  p_report := p_report||l_temp;
  l_cells.DELETE;

  l_cells(1) := '40%:Object Name';
  l_cells(2) := '20%:Object Type';
  l_cells(3) := '20%:Owner';
  l_cells(4) := '20%:Status';
  i := 4;

  p_status := 'SUCCESS';

  -- XML Parser PL/SQL package validation
  open c_dom;
  loop
     fetch c_dom into dom_rec;
     exit when c_dom%NOTFOUND;
     if (dom_rec.status <> 'VALID') then
        p_status := 'FAIL';
     end if;
     l_cells(i+1) := 'XMLDOM';
     l_cells(i+2) := 'PACKAGE';
     l_cells(i+3) := dom_rec.owner;
     l_cells(i+4) := dom_rec.status;
     i := i+4;
  end loop;
  -- XML Parser Java Class
  open c_java;
  loop
     fetch c_java into java_rec;
     exit when c_java%NOTFOUND;
     if (java_rec.status <> 'VALID') then
        p_status := 'FAIL';
        td_fontcolor := 'red';
     end if;
     l_cells(i+1) := java_rec.object_name;
     l_cells(i+2) := 'JAVA SOURCE';
     l_cells(i+3) := java_rec.owner;
     l_cells(i+4) := java_rec.status;
     i := i+4;
     td_fontcolor := 'black';
  end loop;
  Get_Table(l_cells, 4, 'H', l_temp);
  p_report := p_report||l_temp;
  l_cells.DELETE;

  -- Close cursors
  close c_dom;
  close c_java;
exception
  when others then
     -- The SQLException is not sent to Java
     p_status := 'FAIL';
     l_cells(1) := 'TD:<b>Error: '||sqlerrm||'</b>';
     Get_table(l_cells, 1, 'H', l_temp);
     p_report := p_report || l_temp;
     l_cells.DELETE;
     close c_dom;
     close c_java;
end CheckXMLParserStatus;

--
-- CheckAgentsAQStatus
--   Checks the validity of the Agents, AQs associated with the Agents, rules
--   and AQ subscribers
procedure CheckAgentsAQStatus(p_status  out nocopy varchar2,
                              p_report  out nocopy CLOB)
is
  l_queue_name varchar2(30);
  l_owner    varchar2(30);

  CURSOR c_agents IS
  SELECT name, queue_name, status
  FROM   wf_agents
  WHERE  (name like 'WF%'
         OR name like 'ECX%');

  CURSOR c_queue IS
  SELECT aq.enqueue_enabled, aq.dequeue_enabled, db1.status queue_status, db2.status table_status
  FROM   all_queues aq, dba_objects db1, dba_objects db2
  WHERE  db1.object_name = l_queue_name
  AND    db1.owner = l_owner
  AND    db1.object_type = 'QUEUE'
  AND    aq.name = l_queue_name
  AND    aq.owner = l_owner
  AND    db2.object_name = aq.queue_table
  AND    db2.object_type = 'TABLE'
  AND    db2.owner = l_owner;

  type subs_t is ref cursor;
  c_subs subs_t;

  type rules_t is ref cursor;
  c_rules rules_t;

  agt_rec c_agents%ROWTYPE;
  que_rec c_queue%ROWTYPE;

  type sub_rec_t is record
  (
    l_quname    varchar2(30),
    l_subname   varchar2(30),
    l_address   varchar2(1024),
    l_protocol  number
  );
  sub_rec sub_rec_t;

  type rule_rec_t is record
  (
    l_rulename  varchar2(30),
    l_condition varchar2(4000)
  );
  rule_rec rule_rec_t;

  l_temp    varchar2(32000);
  l_message CLOB;
  l_cells   tdType;
  i         pls_integer;
  l_dbver   varchar2(17);
  l_rule_count pls_integer := 0;
  l_main_version varchar2(100);
begin
  -- Get the version of Database
  SELECT   version
  INTO     l_dbver
  FROM     v$instance;

  dbms_lob.CreateTemporary(l_message, TRUE, dbms_lob.Call);

  l_cells(1) := 'WH:<b>Workflow Agents/Queues Status report.</b>';
  Get_table(l_cells, 1, 'H', l_temp);
  dbms_lob.WriteAppend(l_message, length(l_temp), l_temp);
  l_cells.DELETE;

  p_status := 'SUCCESS';

  open c_agents;
  loop
     fetch c_agents into agt_rec;
     exit when c_agents%NOTFOUND;
     l_owner := substr(agt_rec.queue_name, 1, instr(agt_rec.queue_name, '.', 1)-1);
     l_queue_name := substr(agt_rec.queue_name, instr(agt_rec.queue_name, '.', 1)+1);

     open c_queue;
     fetch c_queue into que_rec;

     if (c_queue%ROWCOUNT > 0) then
        -- If a queue is enqueue/dequeue disabled or invalid, this test case will fail
        if (que_rec.enqueue_enabled = 'NO' or que_rec.dequeue_enabled = 'NO' or
            que_rec.queue_status <> 'VALID' or que_rec.table_status <> 'VALID') then
            p_status := 'FAIL';
            td_fontcolor := 'red';
        end if;
        l_cells(1) := '20%:Agent Name';
        l_cells(2) := '20%:Agent Status';
        l_cells(3) := '20%:Queue Name';
        l_cells(4) := '10%:Enqueue Enabled';
        l_cells(5) := '10%:Dequeue Enabled';
        l_cells(6) := '10%:Queue Status';
        l_cells(7) := '10%:Queue Table Status';
        l_cells(8) := '<b>'||agt_rec.name||'</b>';
        l_cells(9) := agt_rec.status;
        l_cells(10) := agt_rec.queue_name;
        l_cells(11) := que_rec.enqueue_enabled;
        l_cells(12) := que_rec.dequeue_enabled;
        l_cells(13) := que_rec.queue_status;
        l_cells(14) := que_rec.table_status;
        td_fontcolor := 'black';

        Get_table(l_cells, 7, 'H', l_temp);
        l_temp := '<br>'||l_temp;
        dbms_lob.WriteAppend(l_message, length(l_temp), l_temp);
        l_temp := '';
        l_cells.DELETE;

      if (agt_rec.name <> 'WF_CONTROL') then

        begin
          -- Get Table header for writing Subscribers
          l_cells(1) := '30%:Sub Que Name';
          l_cells(2) := '30%:Sub Name';
          l_cells(3) := '25%:Sub Address';
          l_cells(4) := '15%:Sub Protocol';
          i := 4;

          -- Get the subscribers for queue
          open c_subs for 'SELECT s.queue_name, s.name, s.address, s.protocol '||
                          'FROM   '||l_owner||'.aq$_'||l_queue_name||'_s s';
          loop
             fetch c_subs into sub_rec;
             exit when c_subs%NOTFOUND;

             l_cells(i+1) := sub_rec.l_quname;
             l_cells(i+2) := sub_rec.l_subname;
             l_cells(i+3) := sub_rec.l_address;
             l_cells(i+4) := sub_rec.l_protocol;
             i := i+4;
          end loop;
          close c_subs;
        exception
          when others then
             l_cells.DELETE;
             l_cells(1) := 'TD:No Subscribers for the Agent '||agt_rec.name;
             close c_subs;
        end;
        if (l_cells.COUNT = 1) then
           Get_Table(l_cells, 1, 'H', l_temp);
        else
           Get_Table(l_cells, 4, 'H', l_temp);
        end if;
        dbms_lob.WriteAppend(l_message, length(l_temp), l_temp);
        l_cells.DELETE;

        -- Get Table header for writing Subscribers Rules
        l_cells(1) := '30%:Rule Name';
        l_cells(2) := '70%:Rule Condition';
        i := 2;
        l_rule_count := 0;
        begin
          -- Get the rules for the subscribers
          open c_rules for 'SELECT name, rule '||
                           'FROM   '||l_owner||'.aq$'||l_queue_name||'_r';
          loop
             fetch c_rules into rule_rec;
             exit when c_rules%NOTFOUND;

             l_cells(i+1) := rule_rec.l_rulename;
             l_cells(i+2) := rule_rec.l_condition;
             i := i+2;
             l_rule_count := l_rule_count+1;
          end loop;
          close c_rules;
        exception
          when others then
             i := 2;
             l_rule_count := 0;
             close c_rules;
        end;

        l_main_version := substr(l_dbver, 1, instr(l_dbver, '.', 1, 2)-1);

        if (l_rule_count = 0 and to_number(l_main_version) >= 9.2) then
          -- for DBs 9.2 or higher, check for rules in DBA_RULES.
          begin
             open c_rules for 'SELECT  s.name name, rule_condition rule '||
                              'FROM    '||l_owner||'.aq$_'||l_queue_name||'_s s, dba_rules r '||
                              'WHERE   (bitand(s.subscriber_type, 1) = 1) '||
                              'AND     s.rule_name = r.rule_name '||
                              'AND     r.rule_owner = :1' using l_owner;

             loop
                fetch c_rules into rule_rec;
                exit when c_rules%NOTFOUND;

                l_cells(i+1) := rule_rec.l_rulename;
                l_cells(i+2) := rule_rec.l_condition;
                i := i+2;
                l_rule_count := l_rule_count + 1;
             end loop;
             close c_rules;
           exception
             when others then
                l_rule_count := 0;
                close c_rules;
          end;
        end if;

        if (l_rule_count = 0) then
           l_cells.DELETE;
           l_cells(1) := 'TD:No Rules for the subscribers of Agent/Queue '||agt_rec.name;
           Get_Table(l_cells, 1, 'H', l_temp);
        else
           Get_Table(l_cells, 2, 'H', l_temp);
        end if;
        dbms_lob.WriteAppend(l_message, length(l_temp), l_temp);
        l_temp := '';
        l_cells.DELETE;
      end if;
     end if;
     close c_queue;
  end loop;
  close c_agents;

  -- dbms_lob.Copy(p_report, l_message, dbms_lob.GetLength(l_message), 1, 1);
  -- dbms_lob.FreeTemporary(l_message);
  p_report := l_message;

end CheckAgentsAQStatus;

--
-- GetXMLParserVersion
--   Gets the XML Parser version in the database. This function is modeled
--   after ECX_UTILS.XMLVersion for use within Standalone Workflow
function GetXMLParserVersion
return  varchar2
is language java name 'oracle.xml.parser.v2.XMLParser.getReleaseVersion() returns java.lang.String';

--
-- Get_Evt_Sys_Status
--   Gets the Workflow System Name, Status, GUID
function Get_Evt_Sys_Status(p_event_name in varchar2,
                            p_event_key  in varchar2)
return varchar2
is
   l_result     varchar2(2000);
   l_temp       varchar2(32000);
   l_cells      tdType;
begin
    l_cells(1) := 'WH:<b>Event and System Information</b>';
    Get_table(l_cells, 1, 'H', l_temp);
    l_cells.DELETE;

    l_cells(1) := '35%:BUSINESS EVENT NAME';
    l_cells(2) := p_event_name;
    Get_Table(l_cells, 2, 'V', l_result);
    l_temp := l_temp || l_result;

    l_cells(1) := '35%:EVENT KEY';
    l_cells(2) := p_event_key;
    Get_Table(l_cells, 2, 'V', l_result);
    l_temp := l_temp || l_result;

    l_cells(1) := '35%:WORKFLOW SYSTEM STATUS';
    select text into l_result from wf_resources where name='WF_SYSTEM_STATUS' and language='US';
    l_cells(2) := l_result;
    Get_Table(l_cells, 2, 'V', l_result);
    l_temp := l_temp || l_result;

    l_cells(1) := '35%:WORKFLOW SYSTEM GUID';
    select text into l_result from wf_resources where name='WF_SYSTEM_GUID' and language='US';
    l_cells(2) := l_result;
    Get_Table(l_cells, 2, 'V', l_result);
    l_temp := l_temp || l_result;

    l_cells(1) := '35%:WORKFLOW SYSTEM NAME';
    select name into l_result from wf_systems where guid=l_cells(2);
    l_cells(2) := l_result;
    Get_Table(l_cells, 2, 'V', l_result);
    l_temp := l_temp || l_result;

    return l_temp;

exception
   when others then
      l_cells.DELETE;
      l_cells(1) := '10%:Note';
      l_cells(2) := 'Error when fetching Workflow System Information';
      l_cells(3) := '10%:Error';
      l_cells(4) := sqlerrm;
      Get_Table(l_cells, 2, 'V', l_result);
      return l_result;

end Get_Evt_Sys_Status;

--
-- Get_Bus_Evt_Info
--   Gets the relevant information for the passed Business Event
function Get_Bus_Evt_Info(p_event_name in varchar2)
return varchar2
is
  l_result      varchar2(32000);
  l_temp        varchar2(32000);

  l_type        varchar2(8);
  l_status      varchar2(8);
  l_own_name    varchar2(30);
  l_own_tag     varchar2(30);
  l_gen_func    varchar2(240);
  l_jgen_func   varchar2(240);
  l_cust_level  varchar2(1);
  l_lic_flag    varchar2(1);

  l_cells       tdType;

begin

   l_cells(1) := 'WH:<b>Business Event Information</b>';
   Get_table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;

   l_cells(1) := 'Event Type';
   l_cells(2) := 'Event Status';
   l_cells(3) := 'Owner Name';
   l_cells(4) := 'Owner Tag';
   l_cells(5) := 'Generate Function';
   l_cells(6) := 'Java Generate Function';
   l_cells(7) := 'Customization Level';
   l_cells(8) := 'License Flag';

   select type, status, owner_name, owner_tag,
          generate_function gen_func,
          java_generate_func jgen_func,
          customization_level cust_level,
          licensed_flag lic_flag
   into   l_type, l_status, l_own_name, l_own_tag,
          l_gen_func, l_jgen_func, l_cust_level, l_lic_flag
   from   wf_events
   where  name = p_event_name;

   l_cells(9)  := l_type;
   l_cells(10)  := l_status;
   l_cells(11) := l_own_name;
   l_cells(12) := l_own_tag;
   l_cells(13) := l_gen_func;
   l_cells(14) := l_jgen_func;
   l_cells(15) := l_cust_level;
   l_cells(16) := l_lic_flag;

   Get_Table(l_cells, 8, 'H', l_temp);
   l_result := l_result || l_temp;
   return l_result;

end Get_Bus_Evt_Info;

--
-- Get_Evt_Subs_Cac_Info
--   Gets the details of Subscriptions from the BES Cache
--   Makes use of WF_BES_CACHE.GetSubscriptions.
function Get_Evt_Subs_Cac_Info(p_event_name in varchar2)
return varchar2
is
   l_result     varchar2(32000);
   l_temp       varchar2(32000);
   l_subs_list  wf_event_subs_tab;

   l_cells      tdType;
   j            pls_integer;
   l_agent_tmp  varchar2(80);

begin
   l_cells(1) := 'WH:<b>Event Subscriptions using WF_BES_CACHE API</b>';
   Get_table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;

   l_cells(1) := '5%:Source Type';
   l_cells(2) := '5%:Source Agent';
   l_cells(3) := '5%:Phase';
   l_cells(4) := '10%:Rule Data';
   l_cells(5) := '10%:Out Agent';
   l_cells(6) := '10%:To Agent';
   l_cells(7) := '15%:Rule Function';
   l_cells(8) := '10%:Workflow Process Type';
   l_cells(9) := '10%:Workflow Process Name';
   l_cells(10) := '10%:Parameters';
   l_cells(11) := '10%:On Error Code';
   l_cells(12) := '10%:Action Code';
   j := 12;

   l_subs_list := WF_BES_CACHE.GetSubscriptions(p_event_name, 'LOCAL', null);

    if (l_subs_list is not null) then
      for i in 1..l_subs_list.COUNT loop
          l_cells(j+1) := l_subs_list(i).SOURCE_TYPE;
          l_cells(j+2) := l_subs_list(i).SOURCE_AGENT_GUID;

          if (l_subs_list(i).SOURCE_AGENT_GUID is not null) then
            select display_name into l_agent_tmp from wf_agents where guid = l_subs_list(i).SOURCE_AGENT_GUID;
            l_cells(j+2) := l_agent_tmp;
          end if;

          l_cells(j+3) := l_subs_list(i).PHASE;
          l_cells(j+4) := l_subs_list(i).RULE_DATA;
          l_cells(j+5) := l_subs_list(i).OUT_AGENT_GUID;
          if (l_subs_list(i).OUT_AGENT_GUID is not null) then
            select display_name into l_agent_tmp from wf_agents where guid = l_subs_list(i).OUT_AGENT_GUID;
            l_cells(j+5) := l_agent_tmp;
          end if;

          l_cells(j+6) := l_subs_list(i).TO_AGENT_GUID;
          if (l_subs_list(i).TO_AGENT_GUID is not null) then
            select display_name into l_agent_tmp from wf_agents where guid = l_subs_list(i).TO_AGENT_GUID;
            l_cells(j+6) := l_agent_tmp;
          end if;

          l_cells(j+7) := l_subs_list(i).RULE_FUNCTION;
          l_cells(j+8) := l_subs_list(i).WF_PROCESS_TYPE;
          l_cells(j+9) := l_subs_list(i).WF_PROCESS_NAME;
          l_cells(j+10) := l_subs_list(i).PARAMETERS;
          l_cells(j+11) := l_subs_list(i).ON_ERROR_CODE;
          l_cells(j+12) := l_subs_list(i).ACTION_CODE;
          j := j+12;
      end loop;

      Get_Table(l_cells, 12, 'H', l_temp);
      l_result := l_result || l_temp;
    end if;

    return l_result;
end Get_Evt_Subs_Cac_Info;

--
-- Get_Evt_Subs_Info
--   Gets the details of Subscriptions from the Database
function Get_Evt_Subs_Info(p_event_name in varchar2)
return varchar2
is
   l_result     varchar2(32000);
   l_temp       varchar2(32000);

   CURSOR c_subs IS
   SELECT subscription_source_type source_type,
          ac.display_name source_agent,
          subscription_phase phase,
          subscription_rule_data rule_data,
          aa.display_name out_agent,
	      ab.display_name to_agent,
          subscription_rule_function rule_function,
          wf_process_type wf_process_type,
          wf_process_name wf_process_name,
          subscription_parameters parameters,
          subscription_on_error_type error_type
   FROM   wf_active_subscriptions_v wfact, wf_agents aa,
          wf_agents ab, wf_agents ac
   WHERE  event_name = p_event_name
   and    wfact.subscription_out_agent_guid = aa.guid(+)
   and    wfact.subscription_to_agent_guid  = ab.guid(+)
   and    wfact.subscription_source_agent_guid = ac.guid(+);

   l_cells      tdType;
   i            pls_integer;

begin
   l_cells(1) := 'WH:<b>Event Subscriptions from Database using the view WF_ACTIVE_SUBSCRIPTIONS_V</b>';
   Get_table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;

   l_cells(1) := '5%:Source Type';
   l_cells(2) := '5%:Source Agent';
   l_cells(3) := '5%:Phase';
   l_cells(4) := '10%:Rule Data';
   l_cells(5) := '10%:Out Agent';
   l_cells(6) := '10%:To Agent';
   l_cells(7) := '15%:Rule Function';
   l_cells(8) := '10%:Workflow Process Type';
   l_cells(9) := '10%:Workflow Process Name';
   l_cells(10) := '10%:Parameters';
   l_cells(11) := '10%:On Error Code';
   i := 11;

   for l_rec in c_subs loop
     l_cells(i+1) := l_rec.source_type;
     l_cells(i+2) := l_rec.source_agent;
     l_cells(i+3) := l_rec.phase;
     l_cells(i+4) := l_rec.rule_data;
     l_cells(i+5) := l_rec.out_agent;
     l_cells(i+6) := l_rec.to_agent;
     l_cells(i+7) := l_rec.rule_function;
     l_cells(i+8) := l_rec.wf_process_type;
     l_cells(i+9) := l_rec.wf_process_name;
     l_cells(i+10) := l_rec.parameters;
     l_cells(i+11) := l_rec.error_type;
     i := i+11;
   end loop;

   Get_Table(l_cells, 11, 'H', l_temp);
   l_result := l_result || l_temp;
   return l_result;

end Get_Evt_Subs_Info;

--
-- Get_Agent_Lsnrs_Status
--   Gets the details of all the Agent Listeners for component types
--    Workflow Agent Listener, Workflow Java Agent Listener
function Get_Agent_Lsnrs_Status
return varchar2
is
  l_result      varchar2(32000);
  l_temp        varchar2(32000);

  CURSOR c_comps IS
  select component_name comp_name, correlation_id corrid,
         inbound_agent_name inbound_agent,
         initcap(decode(FND_SVC_COMPONENT.Get_Component_Status(component_name),
                'NOT_CONFIGURED', 'Not Configured',
                'STOPPED_ERROR', 'Stopped with Error',
                'DEACTIVATED_USER', 'User Deactivated',
                FND_SVC_COMPONENT.Get_Component_Status(component_name))) status,
         component_status_info info
  FROM   fnd_svc_components_v
  WHERE  component_type in ('WF_AGENT_LISTENER', 'WF_JAVA_AGENT_LISTENER');

  l_cells       tdType;
  i             pls_integer;

begin

   l_cells(1) := 'WH:<b>Agent Listener Statuses</b>';
   Get_table(l_cells, 1, 'H', l_result);
   l_cells.DELETE;

   l_cells(1) := '25%:Component Name';
   l_cells(2) := '15%:Correlation ID';
   l_cells(3) := '15%:Inbound Agent';
   l_cells(4) := '15%:Status';
   l_cells(5) := '30%:Status Information';
   i := 5;

   for l_rec in c_comps loop
     l_cells(i+1) := l_rec.comp_name;
     l_cells(i+2) := l_rec.corrid;
     l_cells(i+3) := l_rec.inbound_agent;
     l_cells(i+4) := l_rec.status;
     l_cells(i+5) := l_rec.info;
     i := i+5;
   end loop;

   Get_Table(l_cells, 5, 'H', l_temp);
   l_result := l_result || l_temp;
   return l_result;

end Get_Agent_Lsnrs_Status;

--
-- Get_Bes_Debug - <Explained in WFDIAGPS.pls>
--
procedure Get_Bes_Debug(p_event_name in varchar2,
                        p_event_key  in varchar2,
                        p_value      out nocopy clob)
is
   l_value       clob;
   l_temp_result varchar2(32000);
   l_dummy       varchar2(1);
   l_cells       tdType;
   l_head        varchar2(200);
begin

   dbms_lob.CreateTemporary(l_value, TRUE, dbms_lob.session);
   l_head := '<html><head><title>'||'Event Info:'||p_event_name||' - wfbesdbg output</title></head><body>';
   dbms_lob.WriteAppend(l_value, length(l_head), l_head);

   begin
      select null
      into   l_dummy
      from   wf_events
      where  name = p_event_name;
   exception
      when NO_DATA_FOUND then
         l_cells(1) := 'WH:<b> Event '||p_event_name||' has been purged and is not available in the Database.</b>';
         Get_Table(l_cells, 1, 'H', l_temp_result);
         l_cells.DELETE;
         dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
         dbms_lob.WriteAppend(l_value, length(g_end), g_end);
         p_value := l_value;
         return;
   end;

   l_temp_result := '<a name=top>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Get WF_SYSTEM_STATUS
   l_temp_result := '<br><a name=wf_status>'
                    ||Get_Evt_Sys_Status(p_event_name => p_event_name,
                                         p_event_key  => p_event_key)
                    ||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfevtdbg'||p_event_key||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Get Business Event Item Info
   l_temp_result := '<br><a name=bus_evt>'||Get_Bus_Evt_Info(p_event_name)||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfevtdbg'||p_event_key||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Get Subscription Info using Cache API
   l_temp_result := '<br><a name=sub_info>'||Get_Evt_Subs_Cac_Info(p_event_name)||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfevtdbg'||p_event_key||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Get Subscription Info from DB
   l_temp_result := '<br><a name=sub_info>'||Get_Evt_Subs_Info(p_event_name)||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfevtdbg'||p_event_key||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Listener Statuses
   l_temp_result := '<br><a name=lsnr_info>'||Get_Agent_Lsnrs_Status||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfevtdbg'||p_event_key||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Queue Statuses
   -- Deferred queue status
   l_temp_result := '<br><a name=def_q>'
                    ||Get_Event_Queue_Status(p_queue_name => WFD_DEFERRED,
                                             p_event_name => p_event_name,
                                             p_event_key  => p_event_key)
                    ||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfevtdbg'||p_event_key||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Java Deferred Queue Status
   l_temp_result := '<br><a name=java_def_q>'
                    ||Get_JMS_Queue_Status(p_queue_name => WFD_JAVA_DEFERRED,
                                           p_event_name => p_event_name,
                                           p_event_key  => p_event_key)
                    ||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfevtdbg'||p_event_key||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Error Queue Status
   l_temp_result := '<br><a name=error_q>'
                    ||Get_Event_Queue_Status(p_queue_name => WFD_ERROR,
                                             p_event_name => p_event_name,
                                             p_event_key  => p_event_key)
                    ||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfevtdbg'||p_event_key||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Java Error Queue Status
   l_temp_result := '<br><a name=java_err_q>'
                    ||Get_JMS_Queue_Status(p_queue_name => WFD_JAVA_ERROR,
                                           p_event_name => p_event_name,
                                           p_event_key  => p_event_key)
                    ||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfevtdbg'||p_event_key||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Error Notification Details
   l_temp_result := '<br><a name=err_ntf>'
                     ||Get_Error_Ntf_Details(p_event_name => p_event_name,
                                            p_event_key  => p_event_key)
                    ||wf_core.newline;
   l_temp_result := l_temp_result||'<a href=wfevtdbg'||p_event_key||'.html#top><font face='||td_fontface||
                    ' size='||td_fontsize||'>Go to top</font></a><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Send the final HTML Output to the caller
   dbms_lob.WriteAppend(l_value, length(g_end), g_end);
   p_value := l_value;
exception
   when others then
      l_temp_result := 'Error encountered while Generating BES Debug Information for event '||p_event_name||wf_core.newline;
      l_temp_result := l_temp_result||'Error Name : '||wf_core.newline||wf_core.error_name;
      l_temp_result := l_temp_result||'Error Stack: '||wf_core.newline||wf_core.error_stack;
      dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
      dbms_lob.WriteAppend(l_value, length(g_end), g_end);
      p_value := l_value;
end Get_Bes_Debug;



-- Get_Mailer_Summary_Ntf_Debug
--  Returns information about summary notification for a role
procedure Get_Summary_Mailer_Debug(p_role in varchar2,
                                   p_content out nocopy clob)

is
   l_value       clob;
   l_temp_result varchar2(32000);
   l_dummy       varchar2(1);
   l_cells       tdType;
   l_head        varchar2(200);
   l_exist       varchar2(1);

   l_role     varchar2(320);
   l_dname    varchar2(360);
   l_email    varchar2(320);
   l_npref    varchar2(8);
   l_lang     varchar2(30);
   l_terr     varchar2(30);
   l_orig_sys varchar2(30);
   l_orig_id  number;
   l_install  varchar2(1);

begin

   dbms_lob.CreateTemporary(l_value, TRUE, dbms_lob.session);

   dbms_lob.CreateTemporary(l_temp, TRUE, dbms_lob.session);

   l_head := '<html><head><title>'||'Role Info:'||p_role||' - wfsmrdbg output</title></head><body>';

   l_head := l_head||wf_core.newline;

   dbms_lob.WriteAppend(l_value, length(l_head), l_head);

   -- check Role exist in  row exist
   -- Get_Ntf_Role_Info  / or some DIS Apis
   Wf_Directory.GetRoleInfoMail(p_role, l_dname, l_email,
                                l_npref, l_lang, l_terr,
				l_orig_sys, l_orig_id, l_install);

   -- check if associated fileds exists for a given role.
   -- If not, assume role does not exist and return
   if(l_dname is null and
      l_email is null and
      l_npref is null and
      l_lang  is null and
      l_orig_sys is null ) then

      l_cells(1) := 'WH:<b> The role : '||p_role||' does not exist in the Database.</b>';
      Get_Table(l_cells, 1, 'H', l_temp_result);
      l_cells.DELETE;

      -- Add to LOB
      dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
      --
      dbms_lob.WriteAppend(l_value, length(g_end), g_end);

      p_content := l_value;
      return;
   end if;

   -- Get Users belonging to the recipient Role
   l_temp_result := '<br>' ||Get_Summary_Ntf_Role_Users(p_role)||wf_core.newline;
   l_temp_result := l_temp_result || '<br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);


   -- Get the recipient Role Information
   l_temp_result := '<br>' ||Get_Summary_Ntf_Role_Info(p_role)||wf_core.newline;
   l_temp_result := l_temp_result || '<br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Queue Statuses : Since summary ntf always enqued in wf_notification_out.
   -- If SUMHTML  or SUMMARY  then contents are fetched from Fwk API :
   -- Detail can be seen at WF_NOTIFICATION.getSummaryURL

   -- Notification OUT Queue Status
   -- If a Role has more than  one notifications in  WF_NOTIFICATION_OUT table
   -- then need to show all of them OR XML part of each one.

   -- show number of rows in wf_notification_out AQ
   l_temp_result := '<br>' ||Get_JMS_Queue_Status(p_queue_name => WFD_NTF_OUT,
				   p_event_name => 'oracle.apps.wf.notification%',
	                           p_event_key  => p_role || '%')||wf_core.newline;

    dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

    -- Email and Notification message definition
    l_temp_result := '<br>'||wf_core.newline;
    dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
    -- Summary template : WFMAIL
    Get_Summary_Templates(p_role,  l_npref, l_value);

    -- WF_XML.generate FOR an event with
    -- event key for summary is generated as: role_name + sysdate
    --
    l_temp_result := '<br>'||wf_core.newline;
    dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
    Get_Summary_Ntf_Message(p_role,  l_value );

    --  XML Message for a role from WF_NOTIFICATION_OUT
    l_temp_result := '<br>'||wf_core.newline;
    dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
    Get_Summary_Msg_From_Out(p_role, l_value);

    -- Profile Option Values
    l_temp_result := '<br>'||wf_core.newline;
    dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
    Get_Profile_Option_Values(l_value);

    -- GSC Mailer component parameters
    l_temp_result := '<br>'||wf_core.newline;
    dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
    Get_GSC_Comp_Parameters('WF_MAILER', null, l_value);

    -- GSC Mailer component scheduled events
    l_temp_result := '<br>'||wf_core.newline;
    dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
    Get_GSC_Comp_ScheduledEvents('WF_MAILER', null, l_value);

    -- Mailer Tags
    l_temp_result := '<br>'||wf_core.newline;
    dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

    l_temp_result := Get_Mailer_Tags()||wf_core.newline;
    l_temp_result := l_temp_result || '<br>'||wf_core.newline;
    dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

    -- Send the final HTML Output to the caller
    dbms_lob.WriteAppend(l_value, length(g_end), g_end);

    p_content := l_value;

exception
   when others then
      l_temp_result := 'Error encountered while Generating Summary Mailer Debug '||
                         'Information for role '||p_role||wf_core.newline;
      l_temp_result := l_temp_result||'Error Name : '||wf_core.newline||wf_core.error_name;
      l_temp_result := l_temp_result||'Error Stack: '||wf_core.newline||wf_core.error_stack;
      dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
      dbms_lob.WriteAppend(l_value, length(g_end), g_end);
      p_content := l_value;

end Get_Summary_Mailer_Debug; -- end of Summary Mailer dbg

--
--  Get_Mailer_Alert_Debug
--  Returns information about alert for a module
--
procedure Get_Mailer_Alert_Debug(p_module   in varchar2,
				 p_idstring in varchar2,
                                 p_content  out nocopy clob)
is
   l_value       clob;
   l_temp_result varchar2(32000);
   l_dummy       varchar2(1);
   l_cells       tdType;
   l_head        varchar2(200);
   l_cnt         int;

   -- session user
   l_user  varchar(30)   := 'APPS';

begin

    -- get session user
    select user into l_user from dual;

    dbms_lob.CreateTemporary(l_value, TRUE, dbms_lob.session);
    dbms_lob.CreateTemporary(l_temp, TRUE, dbms_lob.session);

    l_head := '<html><head><title>'||'Alert Info:'||p_module||' - wfalrdbg output</title></head><body>';
    dbms_lob.WriteAppend(l_value, length(l_head), l_head);

   -- Error Notification Details
   -- Check whether wf_error aq will have ALERT in case it failes or not.
   --
   l_temp_result := '<br>'
                    ||Get_Error_Ntf_Details(p_event_name => 'oracle.apps.wf.notification.%',
                                            p_event_key  => p_idstring)
                    ||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Notification OUT Queue Status
   l_temp_result := '<br>'
                    ||Get_JMS_Queue_Status(p_queue_name => WFD_NTF_OUT,
                                           p_event_name => 'oracle.apps.wf.notification%',
                                           p_event_key  => to_char(p_idstring) || '%',
					   p_corr_id    => l_user || ':' || p_module || '%')
                    ||wf_core.newline;

   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Notification IN Queue Status
   l_temp_result := '<br>'
                    ||Get_JMS_Queue_Status(p_queue_name => WFD_NTF_IN,
                                           p_event_name => 'oracle.apps.alr.response.receive%',
                                           p_event_key  => to_char(p_idstring) || '%',
					   p_corr_id    => l_user || ':' || p_module || '%')
                    ||wf_core.newline;

   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   l_temp_result := '<br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- XML Message for the alert from WF_NOTIFICATION_OUT
    Get_Ntf_Msg_From_Out(p_idstring, l_user || ':' || p_module || '%', l_value);

   l_temp_result := '<br><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- XML Message for the notification from WF_NOTIFICATION_IN
   Get_Ntf_Msg_From_In(p_idstring, l_user || ':' || p_module || '%', l_value);

   l_temp_result := '<br><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Profile Option Values
   Get_Profile_Option_Values(l_value);
   l_temp_result := '<br><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- GSC Mailer component parameters
   Get_GSC_Comp_Parameters('WF_MAILER', null, l_value);
   l_temp_result := '<br><br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- GSC Mailer component scheduled events
   Get_GSC_Comp_ScheduledEvents('WF_MAILER', null, l_value);
   l_temp_result := '<br>'||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Mailer Tags
   l_temp_result := '<br><br>'||Get_Mailer_Tags()||wf_core.newline;
   dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

   -- Send the final HTML Output to the caller
   dbms_lob.WriteAppend(l_value, length(g_end), g_end);

   p_content := l_value;

exception
    when others then
      l_temp_result := 'Error encountered while Generating Mailer Alert Debug '||
                       ' Information for module '||p_module|| '<br>'|| wf_core.newline;
      l_temp_result := l_temp_result||'Error Name : '||wf_core.error_name || '<br>' || wf_core.newline;
      l_temp_result := l_temp_result||'Error Stack: '||wf_core.newline||wf_core.error_stack;

      dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);
      dbms_lob.WriteAppend(l_value, length(g_end), g_end);

      p_content := l_value;

end Get_Mailer_Alert_Debug;


end WF_DIAGNOSTICS;

/
