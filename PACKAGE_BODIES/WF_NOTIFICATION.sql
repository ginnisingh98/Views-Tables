--------------------------------------------------------
--  DDL for Package Body WF_NOTIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_NOTIFICATION" as
/* $Header: wfntfb.pls 120.43.12010000.98 2019/08/16 07:12:39 skandepu ship $ */

--
-- Constants
--

-- Max_forward - Max number of forwards allowed by routing rules
-- before a routing loop is inferred.
max_forward number := 10;

-- Sequence number for comments for notification actions in the same
-- session, caused by Routing Rules
g_comments_seq pls_integer := 0;

-- logging variable
g_plsqlName varchar2(35) := 'wf.plsql.WF_NOTIFICATION.';

--
-- Private Variables
--
table_direction varchar2(1) := 'L';
table_type varchar2(1) := 'V';
table_width  varchar2(8) := '100%';
table_border varchar2(2) := '0';
table_cellpadding varchar2(2) := '1';
table_cellspacing varchar2(2) := '0';
table_bgcolor varchar2(7) := 'white';
th_bgcolor varchar2(7) := '#cfe0f1';
th_fontcolor varchar2(7) := '#336699';
th_fontface varchar2(80) := 'Arial, Helvetica, Geneva, sans-serif';
th_fontsize varchar2(2) := '2';
td_bgcolor varchar2(7) := '#f7f7e7';
td_fontcolor varchar2(7) := 'black';
td_fontface varchar2(80) := 'Arial, Helvetica, Geneva, sans-serif';
td_fontsize varchar2(2) := '2';
table_summary  WF_RESOURCES.TEXT%TYPE := wf_core.translate('ACTION_HISTORY');

-- Session NLS_DATE_FORMAT
-- Use this to fulfill the GSCC requirement
s_nls_date_format varchar2(120);  -- session parameter value has length of 120

--Data types for custom columns API
type text_array_t is varray(10) of VARCHAR2(4000);
type numb_array_t is varray(5)  of NUMBER;
type date_array_t is varray(5)  of DATE;

-- checks if plsqlclob,plsqlblob exists
plsql_clob_exists  pls_integer;

--
-- Private Functions
--

-- NTF_TABLE
--   Generate a "Browser Look and Feel (BLAF)" look a like table.
-- ADA compliance is achieved through "scope".
--
-- IN
--   cells - array of table cells
--   col   - number of columns
--   type  - Two character code. First determines header position.
--         - optional second denotes direction for Bi-Di support.
--         - V to generate a vertical table
--         - H to generate a horizontal table
--         - N to generate a mailer notification header table which
--             is a form of vertical
--         - *L Left to Right (default)
--         - *R Right to Left
--   rs    - the result html code for the table
--
-- NOTE
--   type - Vertical table is Header always on the first column
--        - Horizontal table is Headers always on first row
--        - The direction can be omitted to which the default will be
--        - Left to Right.
--
--   cell has the format:
--     R40%:content of the cell here
--     ^ ^
--     | |
--     | + -- width specification
--     +-- align specification (L-Left, C-Center, R-Right, S-Start E-End)
--
procedure NTF_Table(cells in tdType,
                    col   in pls_integer,
                    type  in varchar2,  -- 'V'ertical or 'H'orizontal
                    rs    in out nocopy varchar2)
is
  i pls_integer;
  colon pls_integer;
  modv pls_integer;
  alignv   varchar2(1);
  l_align  varchar2(8);
  l_width  varchar2(3);
  l_text   varchar2(4000);
  l_type   varchar2(1);
  l_dir    varchar2(1);
  l_dirAttr varchar2(10);


  -- Define a local set and initialize with the default
  l_table_width  varchar2(8);
  l_table_border varchar2(2);
  l_table_cellpadding varchar2(2);
  l_table_cellspacing varchar2(2);
  l_table_bgcolor varchar2(7);
  l_th_bgcolor varchar2(7);
  l_th_fontcolor varchar2(7);
  l_th_fontface varchar2(80);
  l_th_fontsize varchar2(2);
  l_td_bgcolor varchar2(7);
  l_td_fontcolor varchar2(7);
  l_td_fontface varchar2(80);
  l_td_fontsize varchar2(4);
  l_table_summary  WF_RESOURCES.TEXT%TYPE;

begin
  l_table_width  := table_width;
  l_table_border := table_border;
  l_table_cellpadding := table_cellpadding;
  l_table_cellspacing := table_cellspacing;
  l_table_bgcolor := table_bgcolor;
  l_th_bgcolor := th_bgcolor;
  l_th_fontcolor := th_fontcolor;
  l_th_fontface := th_fontface;
  l_th_fontsize := th_fontsize;
  l_td_bgcolor := td_bgcolor;
  l_td_fontcolor := td_fontcolor;
  l_td_fontface := td_fontface;
  l_td_fontsize := '10pt';
  l_table_summary := table_summary;

  if length(type) > 1 then
     l_type := substrb(type, 1, 1);
     l_dir := substrb(type,2, 1);
  else
     l_type := type;
     l_dir := 'L';
  end if;

  if l_dir = 'L' then
     l_dirAttr := NULL;
  else
     l_dirAttr := 'dir="RTL"';
  end if;

  if (l_type = 'N') then
     -- Notification format. Alter the default colors.
     l_table_bgcolor := '#FFFFFF';
     l_th_bgcolor := '#FFFFFF';
     l_th_fontcolor := '#000000';
     l_td_bgcolor := '#FFFFFF';
     l_td_fontcolor := '#000000';
     l_table_cellpadding := '0';
     l_table_cellspacing := '0';
     l_table_width  := '100%';
  end if;

  if (cells.COUNT = 0) then
    rs := null;
    return;
  end if;

   --  << bug 6369346 >> :
   --  There is no need to increase width of <TD>
   --  in WF_MAIL.GetHeaderTable from 30% to 50%, just
   --  increase width of below html table to 100% ,
   --  irrespective of table Type ('N' -notification, 'H', 'V')
   rs := '<table width="100%" summary="'||l_table_summary||'" '||l_dirAttr|| '><tr><td>';

  if (l_type = 'N') then
     rs := rs||wf_core.newline||'<table width="'||l_table_width||'"'||
            ' border="'||l_table_border||'"'||
            ' cellpadding="'||l_table_cellpadding||'"'||
            ' cellspacing="'||l_table_cellspacing||'"'||
        ' summary="'||l_table_summary||'"'||
            ' bgcolor="'||l_table_bgcolor||'" '||l_dirAttr||'>';



  else -- Type ('V' and 'H')

     rs := rs||wf_core.newline||'<table width="'||l_table_width||'"'||
               ' class="OraTableContent" cellpadding="'||l_table_cellpadding||'"'||
               ' cellspacing="'||l_table_cellspacing||'"'||
               ' summary="'||l_table_summary||'"'||
               ' border="'||l_table_border||'"'||
               ' '||l_dirAttr||'>';
  end if;

  for i in 1..cells.LAST loop
    modv := mod(i, col);
    if (modv = 1) then
      rs := rs||wf_core.newline||'<tr>';
    end if;

    alignv := substrb(cells(i), 1, 1);
    if (alignv = 'R') then
      l_align := 'RIGHT';
    elsif (alignv = 'L') then
      l_align := 'LEFT';
    elsif (alignv = 'S') then
      if (l_dir = 'L') then
         l_align := 'LEFT';
      else
         l_align := 'RIGHT';
      end if;
    elsif (alignv = 'E') then
      if (l_dir = 'L') then
         l_align := 'RIGHT';
      else
         l_align := 'LEFT';
      end if;
    else
      l_align := 'CENTER';
    end if;

    colon := instrb(cells(i),':');
    l_width := substrb(cells(i), 2, colon-2);
    l_text  := substrb(cells(i), colon+1);   -- what is after the colon

    if ((l_type = 'V' and modv = 1) or (l_type = 'N' and modv = 1)
        or  (l_type = 'H' and i <= col)) then
      -- this is a header
      if (l_type = 'N') then
         rs := rs||wf_core.newline||'<td class="OraPromptText" ';
      elsif (l_type = 'H') then
         rs := rs||wf_core.newline||'<th class="OraTableColumnHeader" ';
         rs := rs||' scope="col"';
      else -- if (l_type = 'V') then
         rs := rs||wf_core.newline||'<th class="OraTableColumnHeader OraTableBorder0101" ';
         rs := rs||' scope="row"';
      end if;

      if (l_width is not null) then
        rs := rs||' width="'||l_width||'"';
      end if;
      rs := rs||' align="'||l_align||'" valign="baseline" >';
      if (l_type = 'N') then
        rs := rs||l_text;
        rs := rs||'</td><td width="12">&'||'nbsp;</td>';
      else
        rs := rs||'<span class="OraTableHeaderLink">'||l_text||'</span>';
        rs := rs||'</th>';
      end if;
    else
      -- this is regular data
      rs := rs||wf_core.newline||'<td';
      if (l_width is not null) then
        rs := rs||' width="'||l_width||'"';
      end if;
      rs := rs||' align="'||l_align||'" valign="baseline" ';

      if (l_type = 'N') then
       rs := rs||' class="OraDataText">'||l_text||'</td>';
      else
       rs := rs||' class="OraTableCellText OraTableBorder1100">'||l_text||'</td>';
      end if;
    end if;
    if (modv = 0) then
      rs := rs||wf_core.newline||'</tr>';
    end if;
  end loop;
  rs := rs||wf_core.newline||'</table>'||wf_core.newline||'</td></tr></table>';

exception
  when OTHERS then
    wf_core.context('Wf_Notification', 'NTF_Table',to_char(col),l_type);
    raise;
end NTF_Table;

--
-- WF_MSG_ATTR
--   Create a table of message attributes
-- NOTE
--   o Considered using dynamic sql passing in attributes as a comma delimited
--     list.  The cost of non-reusable sql may be high.
--   o Considered using bind variables with dynamic sql.  Then we must impose
--     a hard limit on the number of bind variables.  If a limit exceed we
--     need some fall back handling.
--   o Parsing the comma delimited list and making individual select is more
--     costly.  But the sql will be reusable, it may end up cheaper.
--
function wf_msg_attr(nid    in number,
                     attrs  in varchar2,
                     disptype in varchar2)
return varchar2
is
  l_attr      varchar2(30);
  l_dispname  varchar2(80);
  l_text      varchar2(4000);

  l_type      varchar2(8);
  l_cols      pls_integer;
  l_table_direction varchar2(1);
  l_format    varchar2(240);
  l_textv     varchar2(4000);
  l_numberv   number;
  l_datev     date;

  i           pls_integer;
  p1          pls_integer;
  p2          pls_integer;
  not_empty   boolean := true;
  role_info_tbl wf_directory.wf_local_roles_tbl_type;

  l_delim     varchar2(1);
  cells       tdType;
  result      varchar2(32000);
begin

  l_delim := ':';

  l_table_direction := table_direction;
  if (table_type = 'N') then
     l_cols := 3;
  else
     l_cols := 2;
  end if;

  i  := 1;
  p1 := 1;
  while not_empty loop
    p2 := instrb(attrs,',',p1);
    if (p2 = 0) then
      p2 := lengthb(attrs)+1;
      not_empty := false;
    end if;

    l_attr := ltrim(substrb(attrs,p1,p2-p1));

    begin
      select MA.DISPLAY_NAME,
             MA.TYPE,
             MA.FORMAT,
             NA.TEXT_VALUE,
             NA.NUMBER_VALUE,
             NA.DATE_VALUE
        into l_dispname, l_type, l_format, l_textv, l_numberv, l_datev
        from WF_MESSAGE_ATTRIBUTES_VL MA,
             WF_NOTIFICATION_ATTRIBUTES NA,
             WF_NOTIFICATIONS N
       where NA.NAME = l_attr
         and NA.NOTIFICATION_ID = nid
         and NA.NOTIFICATION_ID = N.NOTIFICATION_ID
         and N.MESSAGE_TYPE = MA.MESSAGE_TYPE
         and N.MESSAGE_NAME = MA.MESSAGE_NAME
         and MA.NAME = NA.NAME;
    exception
      when NO_DATA_FOUND then
        -- skip if this attribute or notification does not exist
        l_dispname := null;
        l_type  := 'VARCHAR2';
        l_format:= null;
        l_textv := null;
      when OTHERS then
        raise;
    end;

    if (l_type = 'DATE') then
      -- <bug 7514495> now as date format we use the first non-null value of:
      -- l_format, wf_notification_util.G_NLS_DATE_FORMAT (if nid is provided and matches
      -- wf_notification_util.G_NID), session user's WFDS preference, wf_core.nls_date_format.
      l_text := wf_notification_util.GetCalendarDate(nid, l_datev, l_format, false);
    elsif (l_type = 'NUMBER') then
      if (l_format is null) then
        l_text := to_char(l_numberv);
      else
        l_text := to_char(l_numberv, l_format);
      end if;
    elsif (l_type = 'ROLE') then
      Wf_Directory.GetRoleInfo2(l_textv,role_info_tbl);
      l_text := role_info_tbl(1).display_name;
    elsif (l_type = 'LOOKUP') then
      begin
        select MEANING
        into l_text
        from WF_LOOKUPS
        where LOOKUP_TYPE = l_format
        and LOOKUP_CODE = l_textv;
      exception
        when no_data_found then
          -- Use code directly if lookup not found.
          l_text := l_textv;
      end;
    elsif (l_type = 'VARCHAR2') then
      -- VARCHAR2 is text_value, truncated at format if one provided.
      if (l_format is null) then
        l_text := l_textv;
      else
        l_text := substrb(l_textv, 1, to_number(l_format));
      end if;
    else
      -- do not do any complicated substitution for URL and FORM
      -- do nothing for DOCUMENT as it is too costly
      l_text := l_textv;
    end if;

    -- make sure the text does not carry any HTML chars... though NUMBER is safe
    -- others possibly could carry.
    if (disptype = wf_notification.doc_html) then
      l_text := substrb(Wf_Core.SubstituteSpecialChars(l_text), 1, 4000);
    end if;

    -- display
    if (l_dispname is not null) then
      if (disptype = wf_notification.doc_html) then
        l_dispname := substrb(Wf_Core.SubstituteSpecialChars(l_dispname), 1, 80);
        if (table_type = 'N') then
           cells(i) := 'E:'||l_dispname;
           i := i+1;
           cells(i) := 'S12:';
        else
           cells(i) := 'E40%:'||l_dispname;
        end if;
        i := i+1;
        cells(i) := 'S:'||l_text;  -- normally align number to the right
                                   -- but not in vertical table
        i := i+1;
      else
        result := result||wf_core.newline||l_dispname||l_delim||' '||l_text;
      end if;
    end if;

    p1 := p2+1;
  end loop;

  if (disptype = wf_notification.doc_html) then
    if (table_type = 'N') then
       table_width := '100%';
    else
       table_width := '70%';
    end if;
    NTF_Table(cells=>cells,
              col=>l_cols,
              type=>table_type||l_table_direction,
              rs=>result);
  end if;

  return(result);

exception
  when OTHERS then
    wf_core.context('Wf_Notification','Wf_Msg_Attr',to_char(nid),attrs);
    raise;
end wf_msg_attr;


-- Wf_Ntf_History
--   Construct Action History table for a given notification from the WF_COMMENTS table
--   The table consists of actions like Reassign, More Info Request and Respond and related
--   comments. The user can restrict the rows in the table using the following format.
--   WF_NOTIFICATION(HISTORY, hide_reassign, hide_requestinfo)
--   Example:
--     WF_NOTIFICATION(HISTORY, Y, Y) - Hides comments related to Reassign and More Info Reqs
--     WF_NOTIFICATION(HISTORY, N, Y) - Hides comments related to More Info Reqs
--     WF_NOTIFICATION(HISTORY) - Shows all comments related to the notification
--
-- InPut
--   nid - Notification Id
--   disptype - text/plain or text/html
--   param - Hide Reassign, Hide Request Info indicators

function wf_ntf_history(nid      in number,
                        disptype in varchar2,
                        param    in varchar2)
return varchar2
is
   l_param            varchar2(100);
   l_hide_reassign    varchar2(1);
   l_hide_requestinfo varchar2(1);
   l_action_history   varchar2(32000);
   l_pos              pls_integer;
begin

   l_hide_reassign := 'N';
   l_hide_requestinfo := 'N';

   begin
      if (param is not null) then
         l_pos := instr(param, ',', 1);
         l_hide_reassign := trim(substr(param, 1, l_pos-1));
         l_hide_requestinfo := trim(substr(param, l_pos+1, length(param)-l_pos));
      end if;
   exception
      when others then
         l_hide_reassign := 'N';
         l_hide_requestinfo := 'N';
   end;

   Wf_Notification.GetComments2(p_nid => nid, p_display_type => disptype,
                                p_hide_reassign => l_hide_reassign,
                                p_hide_requestinfo => l_hide_requestinfo,
                                p_action_history => l_action_history);
   return l_action_history;

end wf_ntf_history;

/*
** This Procedure is obsolete. From 11.5.10 onwards, Action History table is based on
** WF_COMMENTS table and on the Notification Activities' history. Hence, WF_NTF_HISTORY
** procedure is reimplemented.
**
--
-- Wf_Ntf_History
--   Construct a history table for a notification activity.
-- NOTE
--   Consist of three sections:
--   1. Current Notification
--   2. Past Notifications in the history table
--   3. The owner role as the submitter and begin date for such item
--
function wf_ntf_history(nid      in number,
                        disptype in varchar2)
return varchar2
is
  -- current notification
  cursor hist0c(x_item_type varchar2, x_item_key varchar2, x_actid number) is
  select IAS.NOTIFICATION_ID, IAS.ASSIGNED_USER, A.RESULT_TYPE, IAS.ACTIVITY_RESULT_CODE, nvl(IAS.END_DATE, IAS.BEGIN_DATE) ACT_DATE, IAS.EXECUTION_TIME
    from WF_ITEM_ACTIVITY_STATUSES IAS,
         WF_ACTIVITIES A,
         WF_PROCESS_ACTIVITIES PA,
         WF_ITEM_TYPES IT,
         WF_ITEMS I
   where IAS.ITEM_TYPE = x_item_type
     and IAS.ITEM_KEY = x_item_key
     and IAS.PROCESS_ACTIVITY = x_actid
     and IAS.ITEM_TYPE          = I.ITEM_TYPE
     and IAS.ITEM_KEY           = I.ITEM_KEY
     and I.BEGIN_DATE between A.BEGIN_DATE and nvl(A.END_DATE, I.BEGIN_DATE)
     and I.ITEM_TYPE             = IT.NAME
     and IAS.PROCESS_ACTIVITY    = PA.INSTANCE_ID
     and PA.ACTIVITY_NAME        = A.NAME
     and PA.ACTIVITY_ITEM_TYPE   = A.ITEM_TYPE;

  -- past notifications
  cursor histc(x_item_type varchar2, x_item_key varchar2, x_actid number) is
  select IAS.NOTIFICATION_ID, IAS.ASSIGNED_USER, A.RESULT_TYPE, IAS.ACTIVITY_RESULT_CODE, nvl(IAS.END_DATE, IAS.BEGIN_DATE) ACT_DATE, IAS.EXECUTION_TIME
    from WF_ITEM_ACTIVITY_STATUSES_H IAS,
         WF_ACTIVITIES A,
         WF_PROCESS_ACTIVITIES PA,
         WF_ITEM_TYPES IT,
         WF_ITEMS I
   where IAS.ITEM_TYPE = x_item_type
     and IAS.ITEM_KEY = x_item_key
     and IAS.PROCESS_ACTIVITY = x_actid
     and IAS.ITEM_TYPE          = I.ITEM_TYPE
     and IAS.ITEM_KEY           = I.ITEM_KEY
     and I.BEGIN_DATE between A.BEGIN_DATE and nvl(A.END_DATE, I.BEGIN_DATE)
     and I.ITEM_TYPE             = IT.NAME
     and IAS.PROCESS_ACTIVITY    = PA.INSTANCE_ID
     and PA.ACTIVITY_NAME        = A.NAME
     and PA.ACTIVITY_ITEM_TYPE   = A.ITEM_TYPE
  order by IAS.BEGIN_DATE desc , IAS.EXECUTION_TIME desc;

  l_itype varchar2(30);
  l_ikey  varchar2(240);
  l_actid number;
  l_result_type varchar2(30);
  l_result_code varchar2(30);
  l_action varchar2(80);
  l_owner_role  varchar2(320);
  l_owner       varchar2(320);
  l_begin_date  date;
  i pls_integer;
  j pls_integer;
  role_info_tbl wf_directory.wf_local_roles_tbl_type;

  l_table_direction varchar2(1);
  l_delim     varchar2(1) := ':';
  cells       tdType;
  result      varchar2(32000);
  l_note      varchar2(4000);
begin

  l_table_direction := table_direction;

  begin
    select ITEM_TYPE, ITEM_KEY, PROCESS_ACTIVITY
      into l_itype, l_ikey, l_actid
      from WF_ITEM_ACTIVITY_STATUSES
     where notification_id = nid;
  exception
    when NO_DATA_FOUND then
      begin
        select ITEM_TYPE, ITEM_KEY, PROCESS_ACTIVITY
          into l_itype, l_ikey, l_actid
          from WF_ITEM_ACTIVITY_STATUSES_H
         where notification_id = nid;
      exception
        when NO_DATA_FOUND then
          null;  -- raise a notification not exist message
      end;
  end;

  j := 1;
  -- title
  cells(j) := wf_core.translate('NUM');
  if (disptype = wf_notification.doc_html) then
    cells(j) := 'S10%:'||cells(j);
  end if;
  j := j+1;
  cells(j) := wf_core.translate('NAME');
  if (disptype = wf_notification.doc_html) then
    cells(j) := 'S:'||cells(j);
  end if;
  j := j+1;
  cells(j) := wf_core.translate('ACTION');
  if (disptype = wf_notification.doc_html) then
    cells(j) := 'S:'||cells(j);
  end if;
  j := j+1;
  cells(j) := wf_core.translate('ACTION_DATE');
  if (disptype = wf_notification.doc_html) then
    cells(j) := 'S:'||cells(j);
  end if;
  j := j+1;
  cells(j) := wf_core.translate('NOTE');
  if (disptype = wf_notification.doc_html) then
    cells(j) := 'S:'||cells(j);
  end if;
  j := j+1;

  i := 0;
  for histr in hist0c(l_itype, l_ikey, l_actid) loop
    cells(j) := to_char(histr.notification_id);
    j := j+1;
    wf_directory.GetRoleInfo2(histr.assigned_user, role_info_tbl);
    if (disptype = wf_notification.doc_html) then
      cells(j) := 'S:'||Wf_Notification.SubstituteSpecialChars(role_info_tbl(1).display_name);
    else
      cells(j) := role_info_tbl(1).display_name;
    end if;
    j := j+1;
    if (l_result_type is null or l_result_code is null or
        histr.result_type <> l_result_type or
        histr.activity_result_code <> l_result_code) then
      l_result_type := histr.result_type;
      l_result_code := histr.activity_result_code;
      l_action := wf_core.activity_result(l_result_type, l_result_code);
    end if;
    if (disptype = wf_notification.doc_html) then
      if (l_action is null) then
        cells(j) := 'S:&nbsp;';
      else
        cells(j) := 'S:'||l_action;
      end if;
    else
      cells(j) := l_action;
    end if;
    j := j+1;
    if (disptype = wf_notification.doc_html) then
      cells(j) := 'S:'||to_char(histr.act_date);
    else
      cells(j) := to_char(histr.act_date);
    end if;
    j := j+1;
    begin
      l_note := Wf_Notification.GetAttrText(histr.notification_id,'WF_NOTE',TRUE);
      if (disptype = wf_notification.doc_html) then
        l_note := substrb(Wf_Notification.SubstituteSpecialChars(l_note), 1, 4000);
      end if;
      cells(j) := l_note;
    exception
      when OTHERS then
        cells(j) := null;
        wf_core.clear;
    end;
    if (disptype = wf_notification.doc_html) then
      if (cells(j) is null) then
        cells(j) := 'S:&nbsp;';
      else
        cells(j) := 'S:'||cells(j);
      end if;
    end if;
    j := j+1;

    i := i+1;
  end loop;

  for histr in histc(l_itype, l_ikey, l_actid) loop
    cells(j) := to_char(histr.notification_id);
    j := j+1;
    wf_directory.GetRoleInfo2(histr.assigned_user, role_info_tbl);
    if (disptype = wf_notification.doc_html) then
      cells(j) := 'S:'||Wf_Notification.SubstituteSpecialChars(role_info_tbl(1).display_name);
    else
      cells(j) := role_info_tbl(1).display_name;
    end if;
    j := j+1;
    if (l_result_type is null or l_result_code is null or
        histr.result_type <> l_result_type or
        histr.activity_result_code <> l_result_code) then
      l_result_type := histr.result_type;
      l_result_code := histr.activity_result_code;
      l_action := wf_core.activity_result(l_result_type, l_result_code);
    end if;
    if (disptype = wf_notification.doc_html) then
      if (l_action is null) then
        cells(j) := 'S:&nbsp;';
      else
        cells(j) := 'S:'||l_action;
      end if;
    else
      cells(j) := l_action;
    end if;
    j := j+1;
    if (disptype = wf_notification.doc_html) then
      cells(j) := 'S:'||to_char(histr.act_date);
    else
      cells(j) := to_char(histr.act_date);
    end if;
    j := j+1;
    begin
      l_note := Wf_Notification.GetAttrText(histr.notification_id,'WF_NOTE',TRUE);
      if (disptype = wf_notification.doc_html) then
        l_note := substrb(Wf_Notification.SubstituteSpecialChars(l_note), 1, 4000);
      end if;
      cells(j) := l_note;
    exception
      when OTHERS then
        cells(j) := null;
        wf_core.clear;
    end;
    if (disptype = wf_notification.doc_html) then
      if (cells(j) is null) then
        cells(j) := 'S:&nbsp;';
      else
        cells(j) := 'S:'||cells(j);
      end if;
    end if;
    j := j+1;

    i := i+1;
  end loop;

  -- submit row
  cells(j) := '0';
  j := j+1;
  begin
    select OWNER_ROLE, BEGIN_DATE
      into l_owner_role, l_begin_date
      from WF_ITEMS
     where ITEM_TYPE = l_itype
       and ITEM_KEY = l_ikey;
  exception
    when OTHERS then
      raise;
  end;
  wf_directory.GetRoleInfo2(l_owner_role, role_info_tbl);
  if (disptype = wf_notification.doc_html) then
    cells(j) := 'S:'||Wf_Notification.SubstituteSpecialChars(role_info_tbl(1).display_name);
  else
    cells(j) := role_info_tbl(1).display_name;
  end if;
  j := j+1;
  if (disptype = wf_notification.doc_html) then
    cells(j) := 'S:'||wf_core.translate('SUBMIT');
  else
    cells(j) := wf_core.translate('SUBMIT');
  end if;
  j := j+1;
  if (disptype = wf_notification.doc_html) then
    cells(j) := 'S:'||to_char(l_begin_date);
  else
    cells(j) := to_char(l_begin_date);
  end if;
  j := j+1;
  if (disptype = wf_notification.doc_html) then
    cells(j) := 'S:&nbsp;';
  else
    cells(j) := null;
  end if;

  -- calculate the sequence
  -- Only after we know the number of rows, then we can put the squence
  -- number on for each row.
  for k in 0..i loop
    if (disptype = wf_notification.doc_html) then
      cells((k+1)*5+1) := 'C:'||to_char(i-k);
    else
      cells((k+1)*5+1) := to_char(i-k);
    end if;
  end loop;

  if (disptype = wf_notification.doc_html) then
    table_width := '100%';
    NTF_Table(cells=>cells,
              col=>5,
              type=>'H'||l_table_direction,
              rs=>result);
  else
    for k in 1..cells.LAST loop
      if (mod(k, 5) <> 0) then
        result := result||cells(k)||' '||l_delim||' ';
      else
        result := result||cells(k)||wf_core.newline;
      end if;
    end loop;
  end if;

  return(result);
exception
  when OTHERS then
    wf_core.context('Wf_Notification', 'Wf_NTF_History', to_char(nid));
    raise;
end wf_ntf_history;
**
** End of obsoleted procedure WF_NTF_HISTORY
**/

--
-- runFuncOnBody
-- NOTE
--   Attempt to find, parse and replace the string
--   WF_NOTIFICATION(F,P1,P2,...)
--   F = function to run
--   P1,P2,... = comma delimited parameter list
--
function runFuncOnBody(nid      in     number,
                       body     in     varchar2,
                       disptype in varchar2)
return varchar2
is
  p1 pls_integer;
  p2 pls_integer;
  pp pls_integer;
  l_body varchar2(32000);
  rs     varchar2(32000);
  fname  varchar2(32);
  frun   varchar2(32);
  func   varchar2(8000);
  param  varchar2(8000);
  i  pls_integer;
  alldone boolean;
begin

  l_body := body;

  p1:=1;
  alldone:=false;
  while (not alldone) loop
    fname := 'WF_NOTIFICATION(';   -- lengthb(fname) is 16

    p1 := instrb(l_body, fname, p1);
    if (p1 <> 0) then
      p2 := instrb(l_body, ')', p1);
      if (p2 <> 0) then
        -- try to separate function to run and parameters
        func  := substrb(l_body, p1, p2-p1+1);
        pp    := instrb(func, ',');
        if (pp = 0) then
          pp := lengthb(func);  -- only the function to run exist.
          param := null;
        else
          param := substrb(func, pp+1, p2-p1-pp);
        end if;

        frun  := substrb(func, 17, pp-17);

    if (frun = 'ATTRS') then
          rs := wf_msg_attr(nid, param, disptype);
        elsif (frun = 'HISTORY') then
          rs := wf_ntf_history(nid, disptype, param);
        else
          rs := func;
        end if;

    -- do not replace a string with itself.
        -- if rs is null, then there is nothing to display for Action/Notifications History
        -- or Attributes table. We would not want WF_NOTIFICATION(ATTRS,...) or
        -- WF_NOTIFICATION(HISTORY) to appear in the notification as is.
        if (rs is null or rs <> func) then
          l_body := replace(l_body, func, rs);
        end if;

        -- now move p1 to the end
        p1 := p2+1;
      else
        -- since we cannot find a closing paranthesis
        alldone := true;
      end if;
    else
      alldone := true;
    end if;
  end loop;

  return(l_body);

exception
  when OTHERS then
    wf_core.context('Wf_Notification', 'runFuncOnBody', to_char(nid), disptype);
    raise;
end runFuncOnBody;

-- More Info mailer support
--
-- GetUserfromEmail (PRIVATE)
--   from_email - from email id
--   user_name  - user name
--   disp_name  - Display name of the user
--   found      - whether user/role has been reconciled
-- NOTE:
--   Get the user/role name and display name based on the email id. Else return
--   the stripped off email with the found flag FALSE

procedure GetUserfromEmail (from_email in  varchar2,
                            preferred_name in varchar2,
                            user_name  out nocopy varchar2,
                            disp_name  out nocopy varchar2,
                            found      out nocopy boolean)
is
   l_email    varchar2(1000);
   l_role     varchar2(320);
   l_dname    varchar2(360);
   l_desc     varchar2(1000);
   l_npref    varchar2(8);
   l_terr     varchar2(30);
   l_lang     varchar2(30);
   l_fax      varchar2(240);
   l_expire   date;
   l_status   varchar2(8);
   l_orig_sys varchar2(30);
   l_orig_sysid number;
   l_start    pls_integer;
   l_end      pls_integer;
   l_role_info_tbl wf_directory.wf_local_roles_tbl_type;

begin
   -- Stripping off unwanted info from email
   l_start := instr(from_email, '<', 1, 1);
   if (l_start > 0) then
      l_end := instr(from_email, '>', l_start);
      l_email := substr(from_email, l_start+1, l_end-l_start-1);
   else
      l_email := from_email;
   end if;
   -- user_name := substr(l_email, 1, instr(l_email, '@') - 1);

   -- Bug 13060615. Check if the expected user is the one who responded via e-mail
   if (preferred_name is not null) then
     if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_statement,
                         'wf.plsql.WF_NOTIFICATION.GetUserfromEmail',
                         'Obtaining user name using preferred name '||preferred_name);
     end if;
     if WF_DIRECTORY.UserActive(preferred_name) then
       WF_DIRECTORY.GetRoleInfo2(preferred_name, l_role_info_tbl);
       if (l_role_info_tbl.COUNT > 0) then
         if (upper(l_email) = upper(l_role_info_tbl(1).email_address)) then
           found := TRUE;
           user_name := l_role_info_tbl(1).name;
           disp_name := l_role_info_tbl(1).display_name;
           return;
         end if;
       end if;
     --elsif WF_DIRECTORY.RoleActive(preferred_name) then --meaning the preferred_name is a ROLE, not a user
     else --meaning the preferred_name is a ROLE, not a user
       begin
         select NAME
         into user_name
         from (select wlr.NAME,
                      decode (wlr.ORIG_SYSTEM, 'PER', 1, 'FND_USR', 2, 3) ORIG_SYS_ORDER
               from WF_LOCAL_ROLES wlr, WF_USER_ROLE_ASSIGNMENTS_V wurav
               where wurav.USER_NAME = wlr.NAME and
                     wurav.ROLE_NAME = preferred_name and
                     upper(wlr.EMAIL_ADDRESS)=l_email
               order by ORIG_SYS_ORDER)
         where rownum<2;
         WF_DIRECTORY.GetRoleInfo2(user_name, l_role_info_tbl);
         if (l_role_info_tbl.COUNT > 0) then
           if (upper(l_email) = upper(l_role_info_tbl(1).email_address)) then
             found := TRUE;
             user_name := l_role_info_tbl(1).name;
             disp_name := l_role_info_tbl(1).display_name;
             return;
           end if;
         end if;
       exception
         when no_data_found THEN
           -- Continue down to find any user with the given email address.
           null;
       end;
     end if;
   end if;
   found := false;

   -- Bug 8802669: If the user is not found for the given email address
   -- or multiple users found in the WF_ROLES table, then convert the
   -- username and displaname i.e email address here (username) to
   -- upper case so that correct username will be used in the case where
   -- the user name is same as email address
   user_name := upper(l_email);
   disp_name := upper(l_email);

   Wf_Directory.GetInfoFromMail(mailid         => l_email,
                                role           => l_role,
                                display_name   => l_dname,
                                description    => l_desc,
                                notification_preference => l_npref,
                                language       => l_lang,
                                territory      => l_terr,
                                fax            => l_fax,
                                expiration_date => l_expire,
                                status         => l_status,
                                orig_system    => l_orig_sys,
                                orig_system_id => l_orig_sysid);

   if (l_role is not null) then
      user_name := l_role;
      disp_name := l_dname;
      found := true;
   end if;
end GetUserfromEmail;

--
-- VALIDATE_CONTEXT
-- Introduced because of bug 7914921
--  Gets a noification contexts and derives the item type, key and activity ID, if any
-- Since the standard format itemtype:itemkey:actid is NOT mandatory this function
-- returns null values if the context does not meet the standard. Further validation is
-- requried by the calling program
-- IN
--  context: the notification context to validate
--  IN OUT
--  itemtype: string before the first colon in the context
--  itemkey: string between first and second colons in the contex
--  actid: NUMBER after the second colon
--
procedure validate_context (context IN WF_NOTIFICATIONS.CONTEXT%TYPE,
                            itemtype OUT NOCOPY varchar2,
                            itemkey OUT NOCOPY varchar2,
                            actid OUT NOCOPY number)
is
 col1 number;
 col2 number;
begin
  itemtype:=null;
  itemkey:=null;
  actid:=null;
  col1 := instr(context, ':', 1, 1);
  col2 := instr(context, ':', -1, 1);
  if col1>0 AND col2>col1 then --Context seems to have itemtype and key
    itemtype := substr(context, 1, col1-1);
    itemkey := substr(context, col1+1, col2-col1-1);
      if LENGTH(itemtype)<=8 then --Standard lenght for a valid item type
        BEGIN
          actid:=to_number(substr(context, col2+1));
        EXCEPTION
          WHEN OTHERS THEN --covers for an invalid conversion to number.
            itemtype:=null;
            itemkey:=null;
            actid:=null;
        END;
     end if;
  end if;
exception
  when OTHERS then --no_data_found or invalid_number
    itemtype:=null;
    itemkey:=null;
    actid:=null;
    wf_core.context('Wf_Notification', 'validate_context', context);
    raise;
end validate_context;


-- End Private Functions
--

--
-- AddAttr
--   Add a new run-time notification attribute.
--   The attribute will be completely unvalidated.  It is up to the
--   user to do any validation and insure consistency.
-- IN:
--   nid - Notification Id
--   aname - Attribute name
--
procedure AddAttr(nid in number,
                  aname in varchar2)
is
  dummy pls_integer;
begin
  if ((nid is null) or (aname is null)) then
    wf_core.token('NID', to_char(nid));
    wf_core.token('ANAME', aname);
    wf_core.raise('WFSQL_ARGS');
  end if;

  -- Insure this is a valid notification.
  begin
    select 1 into dummy from sys.dual where exists
      (select null
       from   WF_NOTIFICATIONS
       where  NOTIFICATION_ID = nid);
  exception
    when no_data_found then
      wf_core.token('NID', to_char(nid));
      wf_core.raise('WFNTF_NID');
  end;

  -- Insert new attribute
  begin
    insert into WF_NOTIFICATION_ATTRIBUTES (
      NOTIFICATION_ID,
      NAME,
      TEXT_VALUE,
      NUMBER_VALUE,
      DATE_VALUE
    ) values (
      nid,
      aname,
      '',
      '',
      ''
    );
  exception
    when dup_val_on_index then
      wf_core.token('NID', to_char(nid));
      wf_core.token('ATTRIBUTE', aname);
      wf_core.raise('WFNTF_ATTR_UNIQUE');
  end;

exception
  when others then
    wf_core.context('Wf_Notification', 'AddAttr', to_char(nid), aname);
    raise;
end AddAttr;

--
-- SetAttrText
--   Set the value of a notification attribute, given text representation.
--   If the attribute is a NUMBER or DATE type, then translate the
--   text-string value to a number/date using attribute format.
--   For all other types, store the value directly.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
--   avalue - New value for attribute
--
procedure SetAttrText(nid in number,
                      aname in varchar2,
                      avalue in varchar2)
is
  atype varchar2(8);
  format varchar2(240);
  rname varchar2(320);
  role_info_tbl wf_directory.wf_local_roles_tbl_type;
  l_parameterlist  wf_parameter_list_t := wf_parameter_list_t();
  l_language       varchar2(30);
  l_recipient_role varchar2(320);

begin
  if ((nid is null) or (aname is null)) then
    wf_core.token('NID', to_char(nid));
    wf_core.token('ANAME', aname);
    wf_core.raise('WFSQL_ARGS');
  end if;

  -- Get type and format of attr.
  -- This is used for translating number/date strings.
  begin
    select WMA.TYPE, WMA.FORMAT
    into atype, format
    from WF_NOTIFICATION_ATTRIBUTES WNA, WF_NOTIFICATIONS WN,
         WF_MESSAGE_ATTRIBUTES WMA
    where WNA.NOTIFICATION_ID = nid
    and WNA.NAME = aname
    and WNA.NOTIFICATION_ID = WN.NOTIFICATION_ID
    and WN.MESSAGE_NAME = WMA.MESSAGE_NAME
    and WN.MESSAGE_TYPE = WMA.MESSAGE_TYPE
    and WNA.NAME = WMA.NAME;
  exception
    when no_data_found then
      -- This is an unvalidated runtime attr.
      -- Treat it as a varchar2.
      atype := 'VARCHAR2';
      format := '';
  end;

  -- Update attribute value in appropriate type column.
  if (atype = 'NUMBER') then
    update WF_NOTIFICATION_ATTRIBUTES
    set NUMBER_VALUE = decode(format,
                              '', to_number(avalue),
                              to_number(avalue, format))
    where NOTIFICATION_ID = nid
    and NAME = aname;
  elsif (atype = 'DATE') then
    -- 4477386 gscc date format requirement change
    -- do not use a cached value, this allows nls change within the
    -- same session to be seen right away.
    update WF_NOTIFICATION_ATTRIBUTES
    set DATE_VALUE = decode(format,
                '',to_date(avalue,SYS_CONTEXT('USERENV','NLS_DATE_FORMAT')),
                to_date(avalue, format))
    where NOTIFICATION_ID = nid
    and NAME = aname;
  elsif (atype = 'VARCHAR2') then
    -- VARCHAR2
    -- Set the text value directly with no translation.
    -- bug 1996299 - JWSMITH , changes substr to substrb for korean char
    update WF_NOTIFICATION_ATTRIBUTES
    set TEXT_VALUE = decode(format,
                            '', avalue,
                            substrb(avalue, 1, to_number(format)))
    where NOTIFICATION_ID = nid
    and NAME = aname;
  elsif (atype = 'ROLE') then
    -- ROLE
    -- First check if value is internal name
    if (avalue is null) then
      -- Null values are ok
      rname := '';
    else
      Wf_Directory.GetRoleInfo2(avalue, role_info_tbl);
      rname := role_info_tbl(1).name;

      -- If not internal name, check for display_name
      if (rname is null) then
        begin
          -- look into the wf_role_lov_vl based on display name
          SELECT name
          INTO   rname
          FROM   wf_role_lov_vl
          WHERE  upper(display_name) = upper(avalue)
          AND    rownum = 1;
        exception
          when no_data_found then
            -- Not displayed or internal role name, error
            wf_core.token('ROLE', avalue);
            wf_core.raise('WFNTF_ROLE');
        end;
      end if;
    end if;

    -- Set the text value with internal role name
    update WF_NOTIFICATION_ATTRIBUTES
    set TEXT_VALUE = rname
    where NOTIFICATION_ID = nid
    and NAME = aname;
  else
    -- LOOKUP, FORM, URL, DOCUMENT, misc type.
    -- Set the text value.
    update WF_NOTIFICATION_ATTRIBUTES
    set TEXT_VALUE = avalue
    where NOTIFICATION_ID = nid
    and NAME = aname;
  end if;

  if (SQL%NOTFOUND) then
    wf_core.token('NID', to_char(nid));
    wf_core.token('ATTRIBUTE', aname);
    wf_core.raise('WFNTF_ATTR');
  end if;

  -- Redenormalize if attribute being updated is #FROM_ROLE
  if (aname = '#FROM_ROLE') then
    Wf_Notification.Denormalize_Notification(nid);
  end if;

  -- Bug 2437347 raising event after DML operation on WF_NOTIFICATION_ATTRIBUTES
  if (aname = 'SENDER') then
    wf_event.AddParameterToList('NOTIFICATION_ID', nid, l_parameterlist);
    wf_event.AddParameterToList(aname, avalue, l_parameterlist);




  select WN.RECIPIENT_ROLE
    into l_recipient_role
    from WF_NOTIFICATIONS WN
    where WN.NOTIFICATION_ID = nid ;

   Wf_Directory.GetRoleInfo2(l_recipient_role, role_info_tbl);
   l_language := role_info_tbl(1).language;

   select code into l_language from wf_languages where nls_language = l_language;

    -- AppSearch
  wf_event.AddParameterToList('OBJECT_NAME',
  'oracle.apps.fnd.wf.worklist.server.AllNotificationsVO', l_parameterlist);
  wf_event.AddParameterToList('CHANGE_TYPE', 'INSERT',l_parameterlist);
  wf_event.AddParameterToList('ID_TYPE', 'PK', l_parameterlist);
  wf_event.addParameterToList('PK_NAME_1', 'NOTIFICATION_ID',l_parameterlist);
  wf_event.addParameterToList('PK_VALUE_1', nid, l_parameterlist);
  wf_event.addParameterToList('PK_NAME_2', 'LANGUAGE',l_parameterlist);
  wf_event.addParameterToList('PK_VALUE_2', l_language, l_parameterlist);
    -- Raise the event
    wf_event.Raise(p_event_name => 'oracle.apps.wf.notification.setattrtext',
                 p_event_key  => to_char(nid),
                 p_parameters => l_parameterlist);
  end if;

exception
  when others then
    wf_core.context('Wf_Notification', 'SetAttrText', to_char(nid),
                    aname, avalue);
    raise;
end SetAttrText;

--
-- SetAttrNumber
--   Set the value of a number notification attribute.
--   Attribute must be a NUMBER-type attribute.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
--   avalue - New value for attribute
--
procedure SetAttrNumber (nid in number,
                         aname in varchar2,
                         avalue in number)
is
begin
  if ((nid is null) or (aname is null)) then
    wf_core.token('NID', to_char(nid));
    wf_core.token('ANAME', aname);
    wf_core.raise('WFSQL_ARGS');
  end if;

  -- Update attribute value
  update WF_NOTIFICATION_ATTRIBUTES
  set    NUMBER_VALUE = avalue
  where  NOTIFICATION_ID = nid and NAME = aname;

  if (SQL%NOTFOUND) then
    wf_core.token('NID', to_char(nid));
    wf_core.token('ATTRIBUTE', aname);
    wf_core.raise('WFNTF_ATTR');
  end if;

exception
  when others then
    wf_core.context('Wf_Notification', 'SetAttrNumber', to_char(nid),
                    aname, to_char(avalue));
    raise;
end SetAttrNumber;

--
-- SetAttrDate
--   Set the value of a date notification attribute.
--   Attribute must be a DATE-type attribute.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
--   avalue - New value for attribute
--
procedure SetAttrDate (nid in number,
                       aname in varchar2,
                       avalue in date)
is
begin
  if ((nid is null) or (aname is null)) then
    wf_core.token('NID', to_char(nid));
    wf_core.token('ANAME', aname);
    wf_core.raise('WFSQL_ARGS');
  end if;

  -- Update attribute value
  update WF_NOTIFICATION_ATTRIBUTES
  set    DATE_VALUE = avalue
  where  NOTIFICATION_ID = nid and NAME = aname;

  if (SQL%NOTFOUND) then
    wf_core.token('NID', to_char(nid));
    wf_core.token('ATTRIBUTE', aname);
    wf_core.raise('WFNTF_ATTR');
  end if;

exception
  when others then
    wf_core.context('Wf_Notification', 'SetAttrDate', to_char(nid),
                    aname, to_char(avalue));
    raise;
end SetAttrDate;

--
-- SubstituteSpecialChars (PRIVATE)
--   Substitutes the occurence of special characters like <, >, \, ', " etc
--   with their html codes in any arbitrary string.
-- IN
--   some_text - text to be substituted
-- RETURN
--   substituted text

function SubstituteSpecialChars(some_text in varchar2)
return varchar2 is
  l_amp     varchar2(1);
  buf       varchar2(32000);
  l_amp_flag  boolean;
  l_lt_flag   boolean;
  l_gt_flag   boolean;
  l_bsl_flag  boolean;
  l_apos_flag boolean;
  l_quot_flag boolean;
begin
  l_amp := '&';

  buf := some_text;

  -- bug 6025162 - This function should substitute only those chars that
  -- really require substitution. Any valid occurences should be retained.
  -- No validation should be required for calling this function

  if (instr(buf, l_amp) > 0) then
    l_amp_flag  := false;
    l_lt_flag   := false;
    l_gt_flag   := false;
    l_bsl_flag  := false;
    l_apos_flag := false;
    l_quot_flag := false;

    -- mask all valid ampersand containing patterns in the content
    -- issue is when ntf body already contains of these reserved words...
    if (instr(buf, l_amp||'amp;') > 0) then
      buf := replace(buf, l_amp||'amp;', '#AMP#');
      l_amp_flag := true;
    end if;
    if (instr(buf, l_amp||'lt;') > 0) then
      buf := replace(buf, l_amp||'lt;', '#LT#');
      l_lt_flag := true;
    end if;
    if (instr(buf, l_amp||'gt;') > 0) then
      buf := replace(buf, l_amp||'gt;', '#GT#');
      l_gt_flag := true;
    end if;
    if (instr(buf, l_amp||'#92;') > 0) then
      buf := replace(buf, l_amp||'#92;', '#BSL#');
      l_bsl_flag := true;
    end if;
    if (instr(buf, l_amp||'#39;') > 0) then
      buf := replace(buf, l_amp||'#39;', '#APO#');
      l_apos_flag := true;
    end if;
    if (instr(buf, l_amp||'quot;') > 0) then
      buf := replace(buf, l_amp||'quot;', '#QUOT#');
      l_quot_flag := true;
    end if;

    buf := replace(buf, l_amp, l_amp||'amp;');

    -- put the masked valid ampersand containing patterns back
    if (l_amp_flag) then
      buf := replace(buf, '#AMP#', l_amp||'amp;');
    end if;
    if (l_lt_flag) then
      buf := replace(buf, '#LT#', l_amp||'lt;');
    end if;
    if (l_gt_flag) then
      buf := replace(buf, '#GT#', l_amp||'gt;');
    end if;
    if (l_bsl_flag) then
      buf := replace(buf, '#BSL#', l_amp||'#92;');
    end if;
    if (l_apos_flag) then
      buf := replace(buf, '#APO#', l_amp||'#39;');
    end if;
    if (l_quot_flag) then
      buf := replace(buf, '#QUOT#', l_amp||'quot;');
    end if;
  end if;

  buf := replace(buf, '<', l_amp||'lt;');
  buf := replace(buf, '>', l_amp||'gt;');
  buf := replace(buf, '\', l_amp||'#92;');
  buf := replace(buf, '''', l_amp||'#39;');
  buf := replace(buf, '"', l_amp||'quot;');
  return buf;
exception
  when others then
    wf_core.context('Wf_Notification', 'SubstituteSpecialChars');
    raise;
end SubstituteSpecialChars;

--
-- GetTextInternal (PRIVATE)
--   Substitute tokens in text (pragma-friendly).
--   This is used in forms which only accept 1950 character strings
--   and in views hence document type is not supported
--   DOCUMENT-type attributes not supported.
-- IN:
--   some_text - Text to be substituted
--   nid - Notification id of notification to use for token values
--   target - Frame target
--   urlmode - Look for URL tokens with dashes
--   subparams - Recursively substitute FORM/URL parameters
--               (to prevent infinite recursion)
--   disptype - display type
-- ### This only consoliates GetShortText and GetUrlText.
-- ### GetText is a separate procedure and must be double-maintained.
-- ### This is so GetShortText can be pragma'd, and the DOCUMENT
-- ### attribute type uses dbms_sql, which violates pragmas.
--

function GetTextInternal(some_text in varchar2,
                         nid       in number,
                         target    in out nocopy varchar2,
                         urlmode   in boolean,
                         subparams in boolean,
                         disptype  in varchar2 default 'text/html')
return varchar2 is

  role_name     varchar2(320);
  email_address varchar2(320);
  username      varchar2(320);
  local_text    varchar2(2000);
  value         varchar2(32000);
  colon         pls_integer;
  params        pls_integer;
  buf           varchar2(2000);
  indx          number := 1;
  replace_text  varchar2(50);
  type url_attr_t is table of varchar2(50) index by varchar2(30);
  attr_list     url_attr_t;

  -- Select attr values, formatting numbers and dates as requested.
  -- The order-by is to handle cases where one attr name is a substring
  -- of another.

  --  Bug 17217302 : cursor for non-URL attributes
  cursor notification_attrs_cursor(nid number) is
    select WNA.NAME, WMA.TYPE, WMA.FORMAT, WMA.DISPLAY_NAME,
           WNA.TEXT_VALUE, WNA.NUMBER_VALUE, WNA.DATE_VALUE
    from WF_NOTIFICATION_ATTRIBUTES WNA, WF_NOTIFICATIONS WN,
         WF_MESSAGE_ATTRIBUTES_VL WMA
    where WNA.NOTIFICATION_ID = nid
      and WN.NOTIFICATION_ID = WNA.NOTIFICATION_ID
      and WN.MESSAGE_TYPE = WMA.MESSAGE_TYPE
      and WN.MESSAGE_NAME = WMA.MESSAGE_NAME
      and WMA.NAME = WNA.NAME
    order by length(WNA.NAME) desc,WNA.NAME asc;

  -- Bug 17217302 : cursor for URL attributes
  cursor notification_attrs_cursor_url(nid number) is
    select WNA.NAME, WMA.TYPE, WMA.FORMAT, WMA.DISPLAY_NAME,
           WNA.TEXT_VALUE, WNA.NUMBER_VALUE, WNA.DATE_VALUE
    from WF_NOTIFICATION_ATTRIBUTES WNA, WF_NOTIFICATIONS WN,
         WF_MESSAGE_ATTRIBUTES_VL WMA
    where WNA.NOTIFICATION_ID = nid
      and WN.NOTIFICATION_ID = WNA.NOTIFICATION_ID
      and WN.MESSAGE_TYPE = WMA.MESSAGE_TYPE
      and WN.MESSAGE_NAME = WMA.MESSAGE_NAME
      and WMA.NAME = WNA.NAME
      and WMA.TYPE = 'URL'
    order by length(WNA.NAME) desc,WNA.NAME asc;

begin

  -- make sure text never exceeds 1950 bytes
  local_text := substrb(some_text,1,1950);

  for ntf_attr_row in notification_attrs_cursor(nid) loop
    if (urlmode) then
      if (instr(local_text, '-&'||ntf_attr_row.name||'-') = 0) then
        goto nextattr;
      end if;
    else
      -- Bug 2843136 Check not only '&' but also '&amp;'
      if ((instr(local_text, '&'||ntf_attr_row.name) = 0) AND
          (instr(local_text, '&amp;'||ntf_attr_row.name) = 0)) then
         goto nextattr;
      end if;
    end if;

    -- Find displayed value of token depending on type
    if (ntf_attr_row.type = 'LOOKUP') then
      -- LOOKUP type select meaning from wf_lookups.
      begin
        select MEANING
        into value
        from WF_LOOKUPS
        where LOOKUP_TYPE = ntf_attr_row.format
        and LOOKUP_CODE = ntf_attr_row.text_value;
      exception
        when no_data_found then
          -- Use code directly if lookup not found.
          value := ntf_attr_row.text_value;
      end;

    elsif (ntf_attr_row.type = 'VARCHAR2') then
      -- VARCHAR2 is text_value, truncated at format if one provided.
      if (ntf_attr_row.format is null) then
        value := ntf_attr_row.text_value;
      else
        value := substrb(ntf_attr_row.text_value, 1,
                         to_number(ntf_attr_row.format));
      end if;

      -- Bug 2843136
      -- Replace '&' but also '&amp;' only if it hasn't been already substituted
      -- This is to prevent something like '&amp;amp;' from happening
      if (disptype = wf_notification.doc_html) then
         --  (instr(local_text,'&amp;'||ntf_attr_row.name) = 0) AND
         --  (instr(value,'&amp;') = 0)) then

         -- bug 6025162 - SubstituteSpecialChars function substitutes only those
         -- characters that really require substitution. Any valid occurences
         -- will be retained. No validation required from calling program.

         value := wf_core.SubstituteSpecialChars(value);
      end if;

    elsif (ntf_attr_row.type = 'NUMBER') then
      -- NUMBER is number_value, with format if provided.
      if (ntf_attr_row.format is null) then
        value := to_char(ntf_attr_row.number_value);
      else
        value := to_char(ntf_attr_row.number_value, ntf_attr_row.format);
      end if;

    elsif (ntf_attr_row.type = 'DATE') then
      -- DATE is date_value, with format if provided.
      -- if (ntf_attr_row.format is null) then
      --  value := to_char(ntf_attr_row.date_value);
      -- else
      --  value := to_char(ntf_attr_row.date_value, ntf_attr_row.format);
      -- end if;

      --  <<sstomar>>: bug8430385: Also  Removed restrict_references(WNDS) pragma
      --               from GETURLTEXT, GETSHORTTEXT and getShortBody etc..
      value := wf_notification_util.getCalendarDate(nid,
                      ntf_attr_row.date_value,
                      ntf_attr_row.format, false);

    elsif (ntf_attr_row.type = 'FORM') then
      -- FORM is display_name (function), with parameters of function
      -- recursively token-substituted if needed.
      value := ntf_attr_row.text_value;
      if (subparams) then
        params := instr(value, ':');
        if (params <> 0) then
          value := ntf_attr_row.display_name||' ( '||
                   substr(value, 1, params)||
                   wf_notification.GetTextInternal(substr(value, params+1), nid,
                                target, FALSE, FALSE, 'text/plain')||' )';
        end if;
      end if;

    elsif ((ntf_attr_row.type = 'URL') and (not urlmode) ) then
      -- Bug 17217302 : Replace URL attributes  with pre text to avoid sub string issues.
      -- Bug 20928724 : Replace URL attributes with special characters and process them at end
      attr_list(ntf_attr_row.name):= '##URL_ATTR##_'||indx;
      local_text := substrb(replace(local_text,ntf_attr_row.name,
                                    '##URL_ATTR##_'||indx),1,1950);
      indx := indx + 1;

    elsif (ntf_attr_row.type = 'ROLE') then
      -- ROLE type, get display_name of role
      begin
        -- NOTE: cannot use wf_directory.getroleinfo2 because of the
        --   pragma WNPS.
        -- Decode into orig_system if necessary for indexes
        colon := instr(ntf_attr_row.text_value, ':');
        if (colon = 0) then
          select WR.DISPLAY_NAME
          into value
          from WF_ROLES WR
          where WR.NAME = ntf_attr_row.text_value
          and   WR.ORIG_SYSTEM NOT IN ('HZ_PARTY','POS','ENG_LIST','AMV_CHN',
              'HZ_GROUP','CUST_CONT');
        else
          select WR.DISPLAY_NAME
          into value
          from WF_ROLES WR
          where WR.ORIG_SYSTEM = substr(ntf_attr_row.text_value, 1, colon-1)
          and WR.ORIG_SYSTEM_ID = substr(ntf_attr_row.text_value, colon+1)
          and WR.NAME = ntf_attr_row.text_value;
        end if;
      exception
        when no_data_found then
          -- Use code directly if role not found.
          value := ntf_attr_row.text_value;
      end;

    elsif ((ntf_attr_row.type = 'DOCUMENT') and (not urlmode)) then
      /*
      ** Only execute this function if this attribute is definitely
      ** in the subject
      */
      if (INSTR(local_text, '&'||ntf_attr_row.name) > 0) then

        if (SUBSTR(ntf_attr_row.text_value, 1, 2) = 'DM') then
          /*
          ** get the document name from the attribute.  We used
          ** to go fetch the document name from the DM system
          ** but that just kills performance because you have to
          ** bounce around to a bunch of different nodes using
          ** URLS
          */
          value := ntf_attr_row.display_name;
        else
          -- All others default to null since this is a plsql document
          value := null;
        end if;
      end if;

    else
      -- All others default to text_value
      value := ntf_attr_row.text_value;
    end if;

    --
    -- Substitute all occurrences of SEND tokens with values.
    -- Limit to 1950 chars to avoid value errors if substitution pushes
    -- it over the edge.
    --
    if (urlmode) then
      local_text := substrb(replace(local_text, '-&'||
                                    ntf_attr_row.name||'-',
                                    wf_mail.UrlEncode(value)), 1, 1950);

      --Bug 2346237
      --The target is set to the attribute format only
      --if the attribute is of type URL
      if (ntf_attr_row.type = 'URL') then
        target := substr(nvl(ntf_attr_row.format, '_top'), 1, 16);
      end if;
    else
      --Bug 2843136
      --Replace & or &amp;
      local_text := substrb(replace(local_text, '&amp;'||ntf_attr_row.name,
                                    value), 1, 1950);

      --Now replace any equivalent &amp;sametoken
      local_text := substrb(replace(local_text, '&'||ntf_attr_row.name,
                                    value), 1, 1950);
    end if;

    <<nextattr>>
    null;
  end loop;

  --- Bug 17217302 : INCORRECT TOKEN SUBSTITUTION OF MESSAGE ATTRIBUTES IF SUBSTRING TOKEN EXIST

  local_text := substr(local_text,1,1950);

  for ntf_attr_row in notification_attrs_cursor_url(nid) loop

    -- Bug 20768736 : Added the missing condition
    -- Bug 20928724 : Replace URL attributes with special characters and process them at end

    if ((instr(local_text, '&'||ntf_attr_row.name)>0) OR (instr(local_text, '&amp;'||ntf_attr_row.name)>0)
        or (instr(local_text,'&'||'##URL_ATTR##')>0 ) or (instr(local_text,'&amp;'||'##URL_ATTR##')>0 )) then

      if ((ntf_attr_row.type = 'URL') and (not urlmode) ) then
        -- URL is display_name (URL), with parameters of URL
        -- recursively token-substituted if needed.
        value := ntf_attr_row.text_value;
        -- Default value of target is "_top" (all lower case)
        target := substr(nvl(ntf_attr_row.format, '_top'), 1, 16);
        if (subparams) then
          params := instr(value, '?');
          if (params <> 0) then
            value := ntf_attr_row.display_name||' ( '||
                     substr(value, 1, params)||
                     wf_notification.GetTextInternal(substr(value, params+1), nid,
                                target, TRUE, FALSE, 'text/plain')||' )';
          end if;
        end if;

      end if;
        --
        -- Substitute all occurrences of SEND tokens with values.
        -- Limit to 1950 chars to avoid value errors if substitution pushes
        -- it over the edge.
        --
        if (urlmode) then
          local_text := substrb(replace(local_text, '-&'||
                                        ntf_attr_row.name||'-',
                                        wf_mail.UrlEncode(value)), 1, 1950);

          --Bug 2346237
          --The target is set to the attribute format only
          --if the attribute is of type URL
          if (ntf_attr_row.type = 'URL') then
            target := substr(nvl(ntf_attr_row.format, '_top'), 1, 16);
          end if;

      else
        --Bug 2843136
        --Replace & or &amp;
        -- Bug 20928724 : Replace URL attributes with special characters and process them at end
        if attr_list.exists(ntf_attr_row.name) then
          replace_text := attr_list(ntf_attr_row.name);
          local_text := substrb(replace(local_text, '&amp;'||replace_text,value), 1, 1950);
          --Now replace any equivalent &amp;sametoken
          local_text := substrb(replace(local_text, '&'||replace_text,value), 1, 1950);
        end if;
      end if;
    end if;  --instr end if
  end loop;

  --
  -- Process special '#' internal tokens.  Supported tokens are:
  --  &#NID - Notification id
  --
  if (urlmode) then
    local_text := substrb(replace(local_text, '-&'||'#NID-',
                                  to_char(nid)), 1, 1950);
  else
    local_text := substrb(replace(local_text, '&'||'#NID',
                                  to_char(nid)), 1, 1950);
  end if;

  return(local_text);

exception

  when others then
    wf_core.context('Wf_Notification','GetTextInternal', to_char(nid), disptype);
    raise;

end GetTextInternal;


--
-- SetFrameworkAgent
--   Check the URL for a JSP: entry and then substitute
--   it with the value of the APPS_FRAMEWORK_AGENT
--   profile option.
-- IN:
--   URL - URL to be ckecked
-- RETURNS:
--   URL with Frame work agent added
-- NOTE:
--   If errors are detected this routine returns some_text untouched
--   instead of raising exceptions.
--
function SetFrameworkAgent(url in varchar2)
return varchar2
is
   value varchar2(32000);
   params integer;
   apps_fwk_agent varchar2(256);
begin
   value := url;
   --Bug 2276779
   --Check if the URL is a javascript call.
   if ((lower(substr(value,1,11))) = 'javascript:') then
      --If the URL is a javascript function then
      --do not prefix the web agent to the URL.
      return value;
   end if;
   if ((wf_core.Translate('WF_INSTALL')='EMBEDDED') AND
       (substr(value, 1, 4) = 'JSP:')) then
      -- The URL is a APPS Framework reference and will need
      -- the JSP Agent rather than the WEB Agent
      value := substr(value, 5);
      value := '/' || ltrim(value, '/');
      apps_fwk_agent := rtrim(fnd_profile.Value('APPS_FRAMEWORK_AGENT'), '/');
      value :=  apps_fwk_agent || value;
      params := instr(value,'?');
      if (params <> 0) then
         value := value||'&'||'dbc='||fnd_web_config.Database_ID;
      else
         value := value||'?'||'dbc='||fnd_web_config.Database_ID;
      end if;
   else
      if instr(value,'//',1,1)=0 then
      -- CTILLEY: Added additional check to make sure a trailing slash
      -- is added to the WF_WEB_AGENT if it isn't the first character
      -- in the value.  Fix for bug 2207322.
         if substr(value,1,1)='/' then
             value := wf_core.translate('WF_WEB_AGENT')||value;
         else
             value := wf_core.translate('WF_WEB_AGENT')||'/'||value;
         end if;
      end if;
   end if;
   return value;

exception
  when others then
    wf_core.context('Wf_Notification', 'SetFrameworkAgent', url);
end;

--
-- GetText
--   Substitute tokens in an arbitrary text string.
--     This function may return up to 32K chars. It can NOT be used in a view
--   definition or in a Form.  For views and forms, use GetShortText, which
--   truncates values at 2000 chars.
-- IN:
--   some_text - Text to be substituted
--   nid - Notification id of notification to use for token values
--   disptype - Display type ('text/plain', 'text/html', '')
-- RETURNS:
--   Some_text with tokens substituted.
-- NOTE:
--   If errors are detected this routine returns some_text untouched
--   instead of raising exceptions.
--
function GetText(some_text in varchar2,
                 nid       in number,
                 disptype  in varchar2)
return varchar2
is
begin
  -- Calling original GetText logic to substitute all tokens
  return wf_notification.GetText2(some_text, nid, disptype, true);
end GetText;

--
-- GetText2 (INTERNAL ONLY)
--   This procedure is same as GetText above. Only difference is, this provides
--   a flag to suppress substitution of DOCUMENT type tokens in the text. This
--   is created for internal purposes only to substitute tokens within the
--   PLSQL DOCUMENT attribute's value. We don't support DOCUMENT type tokens
--   within a DOCUMENT type attribute.
-- IN:
--   some_text - Text to be substituted
--   nid - Notification id of notification to use for token values
--   disptype - Display type ('text/plain', 'text/html', '')
--   sub_doc - Substitute DOCUMENT type tokens (true, false)
-- RETURNS:
--   Some_text with tokens substituted.
--
function GetText2(some_text in varchar2,
                  nid       in number,
                  disptype  in varchar2,
                  sub_doc   in boolean)
return varchar2
is
  role_name     varchar2(320);
  email_address varchar2(320);
  buf           varchar2(2000);
  local_text    varchar2(32000);
  value         varchar2(32000);
  params        pls_integer;
  target        varchar2(16);
  extPos        pls_integer;    -- Image file extension position
  extStr        varchar2(1000); -- Image file extention
  renderType    varchar2(10); -- 4713416 Explicit rendering of URL html.
  indx          number:= 1;
  replace_text  varchar2(50);
  type url_attr_t is table of varchar2(50) index by  varchar2(30);
  attr_list     url_attr_t;

  -- Select attr values, formatting numbers and dates as requested.
  -- The order-by is to handle cases where one attr name is a substring
  -- of another.

  --  Bug 17217302 : cursor for non-URL attributes
  cursor notification_attrs_cursor(nid number) is
    select WNA.NAME, WMA.TYPE, WMA.FORMAT, WMA.DISPLAY_NAME,
           WNA.TEXT_VALUE, WNA.NUMBER_VALUE, WNA.DATE_VALUE
    from WF_NOTIFICATION_ATTRIBUTES WNA, WF_NOTIFICATIONS WN,
         WF_MESSAGE_ATTRIBUTES_VL WMA
    where WNA.NOTIFICATION_ID = nid
      and WN.NOTIFICATION_ID = WNA.NOTIFICATION_ID
      and WN.MESSAGE_TYPE = WMA.MESSAGE_TYPE
      and WN.MESSAGE_NAME = WMA.MESSAGE_NAME
      and WMA.NAME = WNA.NAME
    order by length(WNA.NAME) desc,WNA.NAME asc;

  --Bug 17217302 : cursor for URL attributes
  cursor notification_attrs_cursor_url(nid number) is
    select WNA.NAME, WMA.TYPE, WMA.FORMAT, WMA.DISPLAY_NAME,
           WNA.TEXT_VALUE, WNA.NUMBER_VALUE, WNA.DATE_VALUE
    from WF_NOTIFICATION_ATTRIBUTES WNA, WF_NOTIFICATIONS WN,
         WF_MESSAGE_ATTRIBUTES_VL WMA
    where WNA.NOTIFICATION_ID = nid
      and WN.NOTIFICATION_ID = WNA.NOTIFICATION_ID
      and WN.MESSAGE_TYPE = WMA.MESSAGE_TYPE
      and WN.MESSAGE_NAME = WMA.MESSAGE_NAME
      and WMA.NAME = WNA.NAME
      and WMA.TYPE = 'URL'
    order by length(WNA.NAME) desc,WNA.NAME asc;

  role_info_tbl wf_directory.wf_local_roles_tbl_type;

  error_name  varchar2(30);
  error_stack varchar2(32000);
  l_dummy     boolean;

begin

  local_text := some_text;

  for ntf_attr_row in notification_attrs_cursor(nid) loop

    -- only bother to find attribute value if it exists in the string
    -- dont place in select as each replace can introduce a new token
    --
    -- Bug 2843136 - Check not only '&' but also '&amp;'
    if ((instr(local_text, '&'||ntf_attr_row.name)>0) OR (instr(local_text, '&amp;'||ntf_attr_row.name)>0)) then

      -- Find displayed value of token depending on type
      if (ntf_attr_row.type = 'LOOKUP') then
        -- LOOKUP type select meaning from wf_lookups.
        begin
          select MEANING
          into value
          from WF_LOOKUPS
          where LOOKUP_TYPE = ntf_attr_row.format
          and LOOKUP_CODE = ntf_attr_row.text_value;
        exception
          when no_data_found then
            -- Use code directly if lookup not found.
            value := ntf_attr_row.text_value;
        end;

      elsif (ntf_attr_row.type = 'VARCHAR2') then
        -- VARCHAR2 is text_value, truncated at format if one provided.
        if (ntf_attr_row.format is null) then
          value := ntf_attr_row.text_value;
        else
          value := substrb(ntf_attr_row.text_value, 1,
                           to_number(ntf_attr_row.format));
        end if;

        -- JWSMITH bug 1725916 - add BR to attribute value
        if (disptype=wf_notification.doc_html) then
          -- bug 6025162 - SubstituteSpecialChars function substitutes only those
          -- characters that really require subsstitution. Any valid occurences
          -- will be retained. No validation required from calling program.

          value := wf_core.SubstituteSpecialChars(value);

          -- end if;
          value := substrb(replace(value, wf_core.newline,
                                   '<BR>'||wf_core.newline),1, 32000);
        end if;

      elsif (ntf_attr_row.type = 'NUMBER') then
        -- NUMBER is number_value, with format if provided.
        if (ntf_attr_row.format is null) then
          value := to_char(ntf_attr_row.number_value);
        else
          value := to_char(ntf_attr_row.number_value, ntf_attr_row.format);
        end if;

      elsif (ntf_attr_row.type = 'DATE') then
        -- <bug 7514495> now as date format we use the first non-null value of:
        -- ntf_attr_row.format, wf_notification_util.G_NLS_DATE_FORMAT (if nid is provided
        -- and matches wf_notification_util.G_NID), session user's WFDS preference,
        -- and wf_core.nls_date_format.
        value := wf_notification_util.GetCalendarDate(nid, ntf_attr_row.date_value
                                                    , ntf_attr_row.format, false);

      elsif (ntf_attr_row.type = 'FORM') then
        -- FORM is display_name (function), with parameters of function
        -- recursively token-substituted if needed.
        value := ntf_attr_row.text_value;
        params := instr(value, ':');
        if (params <> 0) then
          value := ntf_attr_row.display_name||' ( '||
                   substr(value, 1, params)||
                   wf_notification.GetTextInternal(substr(value,params+1), nid,
                          target, FALSE, FALSE, 'text/plain')||' )';
        end if;

        if (disptype = wf_notification.doc_html) then
          -- Bug 4634849
          -- Do not display potentially harmful text
          begin
            l_dummy := wf_core.CheckIllegalChars(value,true,';<>()');
          exception
            when OTHERS then
              wf_core.get_error(error_name, value, error_stack);

              value :=wf_core.substitutespecialchars(value);
              error_stack:= '';

          end;
        end if;

      elsif (ntf_attr_row.type = 'URL') then
        -- Bug 17217302 : Replace URL  with pre text to avoid sub string issues   bug 17217302
        -- Bug 20928724 : Replace URL attributes with special characters and process them at end"
        attr_list(ntf_attr_row.name):= '##URL_ATTR##_'||indx;
        local_text := replace(local_text,ntf_attr_row.name,
                              '##URL_ATTR##_'||indx);
        indx := indx + 1;

      elsif (ntf_attr_row.type = 'DOCUMENT') then
        -- Do not substitute Document type tokens
        if (not sub_doc) then
          goto nextattr;
        end if;

        --skilaru 28-July-03 fix for bug 3042471
        if( instr(ntf_attr_row.text_value, fwk_region_start) = 1 ) then
          wf_core.token('ANAME', ntf_attr_row.name );
          wf_core.token('FWK_CONTENT', ntf_attr_row.text_value );
          value := wf_core.translate('WFUNSUP_FWK_CONTENT');
        else
          -- DOCUMENT type retrieve document contents
          -- Bug 2879507 if doc generation fails, let the error propagate
          -- to the caller.
          value := GetAttrDoc(nid, ntf_attr_row.name, disptype);
        end if;

      elsif (ntf_attr_row.type = 'ROLE') then
        -- ROLE type, get display_name of role
        Wf_Directory.GetRoleInfo2(ntf_attr_row.text_value,role_info_tbl);
        -- Use code directly if role not found.
        value := nvl(role_info_tbl(1).display_name,ntf_attr_row.text_value);

        -- Retrieve role information
        if (ntf_attr_row.text_value is not null) then
          -- Default role info to recipient if role cannot be found
          role_name     := nvl(role_info_tbl(1).display_name,
                               ntf_attr_row.text_value);
          email_address := nvl(role_info_tbl(1).email_address,
                               ntf_attr_row.text_value);
        end if;

        if (disptype = wf_notification.doc_html) then

           value := '<A class="OraLink" HREF="mailto:'||email_address||'" TARGET="_top">'||value||'</A>';

        end if;

      else
        -- All others default to text_value
        value := ntf_attr_row.text_value;

        if (disptype = wf_notification.doc_html) then
          value := wf_core.substitutespecialchars(value);
        end if;
      end if;

      -- Substitute all occurrences of SEND tokens with values.
      -- Limit to 32000 chars to avoid value errors if substitution pushes
      -- it over the edge.
      --
      --Bug 2594012/2843136
      -- Bug 2917787 - added code to check if value is null.
      if ((value is null) or
          (lengthb(local_text) + (lengthb(value) - length('&'||ntf_attr_row.name)) <= 32000)) then
        local_text := replace(local_text, '&amp;'||ntf_attr_row.name, value);
        local_text := replace(local_text, '&'||ntf_attr_row.name, value);
      end if;
    end if;-- if instr(..

    <<nextattr>>
    null;
  end loop;

  -- Bug 17217302 INCORRECT TOKEN SUBSTITUTION OF MESSAGE ATTRIBUTES IF SUBSTRING TOKEN EXIST process URL type here
  -- Bug 20928724 : Replace URL attributes with special characters and process them at end

  for ntf_attr_row in notification_attrs_cursor_url(nid) loop
    if ((instr(local_text, '&'||ntf_attr_row.name)>0) OR (instr(local_text, '&amp;'||ntf_attr_row.name)>0)
        or (instr(local_text,'&'||'##URL_ATTR##')>0 ) or (instr(local_text,'&amp;'||'##URL_ATTR##')>0 )) then
      local_text := substr(local_text,1,length(local_text));
      if (ntf_attr_row.type = 'URL') then
        -- URL is display_name (URL), with parameters of URL
        -- recursively token-substituted if needed.
        value := ntf_attr_row.text_value;
        target := substr(nvl(ntf_attr_row.format, '_top'), 1, 16);
        value := wf_notification.SetFrameworkAgent(value);
        params := instr(value, '?');
        if (params <> 0) then
          value := substr(value, 1, params)||
                   wf_notification.GetTextInternal(substr(value,params+1), nid,
                        target, TRUE, FALSE, 'text/plain');
        end if;

        if (disptype = wf_notification.doc_html) then
          -- Bug 4634849
          -- Do not display potentially harmful URL
          begin
            if (not wf_core.CheckIllegalChars(value,true, ';<>"')) then

              -- 4713416 Determine the display formatting for the URI
              -- First validate the prefix to the known types.
              renderType := upper(substr(value, 1, 4));
              if renderType in ('IMG:','LNK:') then
                 -- Remove the prefix
                 value := substr(value, 5);
              else
                 -- Explicitly reset the type so that the file extention will
                 -- dictate the render type.
                 renderType := NULL;
              end if;

              -- Check the extention of the URI file but only if
              -- there are no URL parameters and either a render prefix has
              -- been added or no prefix at all.
              extPos := instrb(value, '.', -1, 1) + 1;
              extStr := lower(substrb(value, extPos));
              if (params = 0 and
                ( renderType is null or renderType = 'IMG:' ) and
                extStr in ('gif','jpg','png','tif','bmp','jpeg'))
              then
                value := '<IMG SRC="'||value||
                         '" alt="'|| ntf_attr_row.display_name||'"></IMG>';
                -- Set the renderType used to inform the next condition
                renderType := 'IMG:';
              else
                -- No IMG was rendered so set the type to a normal link.
                renderType := 'LNK:';
              end if;

              if renderType = 'LNK:' then
                -- If no render prefix was given or an explicit LNK: prefix
                -- then render as a normal anchor.

                -- For URL type display as an anchor
                value := '<A class="OraLink" HREF="'||value||'" TARGET="'||target||'">'||
                         ntf_attr_row.display_name||'</A>';
              end if;
            end if;
          exception
            when OTHERS then
              wf_core.get_error(error_name, value, error_stack);

              value :=wf_core.substitutespecialchars(value);
              error_stack:= '';
          end;
        else
          -- Other types get a text representation
          value := ntf_attr_row.display_name||' : '||value;
        end if;

        -- Limit to 32000 chars to avoid value errors if substitution pushes
        -- it over the edge.
        -- Bug 20928724 : Replace URL attributes with special characters and process them at end
        if attr_list.exists(ntf_attr_row.name) then
          replace_text := attr_list(ntf_attr_row.name);
          if((lengthb(local_text) + (lengthb(value) - length('&'||ntf_attr_row.name)) <= 32000)) then
            local_text := replace(local_text, '&amp;'||replace_text,value);
            local_text := replace(local_text, '&'||replace_text,value);
          end if;
        end if;

        -- Bug 28676830 - Substitute remaining (nested) URL tokens with values.
        -- Limit to 32000 chars to avoid value errors if substitution pushes
        -- it over the edge.
        if((value is null) or
           (lengthb(local_text) + (lengthb(value) - length('&'||ntf_attr_row.name)) <= 32000)) then
          local_text := replace(local_text, '&amp;'||ntf_attr_row.name, value);
          local_text := replace(local_text, '&'||ntf_attr_row.name, value);
        end if;
      end if;
    end if; ---instr if

    local_text := substr(local_text,1,length(local_text));

  end loop;

  --
  -- Process special '#' internal tokens.  Supports tokens are:
  --  &#NID - Notification id
  --
  local_text := substrb(replace(local_text, '&'||'#NID',
                                to_char(nid)), 1, 32000);

  return(local_text);

exception

  when others then
    wf_core.context('Wf_Notification','GetText2', to_char(nid), disptype);
    raise;
    -- return(some_text);

end GetText2;

--
-- GetUrlText
--   Substitute URL-style tokens (with dashes) in an arbitrary text string.
--     This function may return up to 32K chars. It can NOT be used in a view
--   definition or in a Form.  For views and forms, use GetShortText, which
--   truncates values at 2000 chars.
-- IN:
--   some_text - Text to be substituted
--   nid - Notification id of notification to use for token values
-- RETURNS:
--   Some_text with tokens substituted.
-- NOTE:
--   If errors are detected this routine returns some_text untouched
--   instead of raising exceptions.
--
function GetUrlText(some_text in varchar2,
                    nid in number)
return varchar2
is
  target  varchar2(16);
  l_error varchar2(32000);
begin
  return(GetTextInternal(some_text, nid, target, TRUE, TRUE, 'text/plain'));
exception
  when others then
    -- Return the error message with error stack
    l_error := wf_core.translate('ERROR') || wf_core.newline;
    if (wf_core.error_name is not null) then
      l_error := l_error || wf_core.error_message || wf_core.newline;
      l_error := l_error || wf_core.translate('WFENG_ERRNAME') || ': ' ||
                 wf_core.error_name || wf_core.newline;
    else
      l_error := l_error || sqlerrm || wf_core.newline;
      l_error := l_error || wf_core.translate('WFENG_ERRNAME') || ': ' ||
                 to_char(sqlcode) || wf_core.newline;
    end if;
    l_error := l_error || wf_core.translate('WFENG_ERRSTACK') || ': ' ||
               wf_core.error_stack || wf_core.newline;
    return (substrb(l_error, 1, 1950));
end GetUrlText;

--
-- GetShortText
--   Substitute tokens in an arbitrary text string, limited to 2000 chars.
--   (actually 1950, because of forms overhead).
--     This function is meant to be used in view definitions and Forms, where
--   the field size must be limited to 2000 chars.  Use GetText() to retrieve
--   up to 32K if the text may be longer.
-- IN:
--   some_text - Text to be substituted
--   nid - Notification id of notification to use for token values
-- RETURNS:
--   Some_text with tokens substituted.
-- NOTE:
--   If errors are detected this routine returns some_text untouched
--   instead of raising exceptions.
function GetShortText(some_text in varchar2,
                      nid in number)
return varchar2
is
  target varchar2(16);
  l_error varchar2(32000);

begin
  -- gettextinternal will truncate to 1950 characters.
  return(GetTextInternal(some_text, nid, target, FALSE, TRUE));
exception
  when others then
    -- Return the error message with error stack if GetTextInternal raises
    l_error := wf_core.translate('ERROR') || wf_core.newline;
    if (wf_core.error_name is not null) then
      l_error := l_error || wf_core.error_message || wf_core.newline;
      l_error := l_error || wf_core.translate('WFENG_ERRNAME') || ': ' ||
                 wf_core.error_name || wf_core.newline;
    else
      l_error := l_error || sqlerrm || wf_core.newline;
      l_error := l_error || wf_core.translate('WFENG_ERRNAME') || ': ' ||
                 to_char(sqlcode) || wf_core.newline;
    end if;
    l_error := l_error || wf_core.translate('WFENG_ERRSTACK') || ': ' ||
               wf_core.error_stack||wf_core.newline;
    return (substrb(l_error, 1, 1950));

end GetShortText;

--
-- GetAttrInfo
--   Get type information about a notification attribute.
-- IN:
--   nid - Notification id
--   aname - Attribute name
-- OUT:
--   atype  - Attribute type
--   subtype - 'SEND' or 'RESPOND',
--   format - Attribute format
--
procedure GetAttrInfo(nid in number,
                      aname in varchar2,
                      atype out nocopy varchar2,
                      subtype out nocopy varchar2,
                      format out nocopy varchar2)
is
begin
  if ((nid is null) or (aname is null)) then
    wf_core.token('NID', to_char(nid));
    wf_core.token('ANAME', aname);
    wf_core.raise('WFSQL_ARGS');
  end if;

  begin
    select WMA.TYPE, WMA.SUBTYPE, WMA.FORMAT
    into   atype, subtype, format
    from   WF_NOTIFICATION_ATTRIBUTES WNA, WF_NOTIFICATIONS WN,
           WF_MESSAGE_ATTRIBUTES WMA
    where  WNA.NOTIFICATION_ID = nid
    and    WNA.NAME = aname
    and    WNA.NOTIFICATION_ID = WN.NOTIFICATION_ID
    and    WN.MESSAGE_TYPE = WMA.MESSAGE_TYPE
    and    WN.MESSAGE_NAME = WMA.MESSAGE_NAME
    and    WMA.NAME = WNA.NAME;
  exception
    when no_data_found then
      wf_core.token('NID', to_char(nid));
      wf_core.token('ATTRIBUTE', aname);
      wf_core.raise('WFNTF_ATTR');
  end;

exception
  when others then
    wf_core.context('Wf_Notification', 'GetAttrInfo', to_char(nid),
                    aname);
    raise;
end GetAttrInfo;

--
-- GetAttrText
--   Get the value of a text notification attribute.
--   If the attribute is a NUMBER or DATE type, then translate the
--   number/date value to a text-string representation using attrbute format.
--   For all other types, get the value directly.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
--
function GetAttrText (nid in number,
                      aname in varchar2,
              ignore_notfound in boolean)
return varchar2 is
  atype varchar2(8);
  format varchar2(240);
  lvalue varchar2(4000);
  params pls_integer;
  l_valDate date;
begin
  if ((nid is null) or (aname is null)) then
    wf_core.token('NID', to_char(nid));
    wf_core.token('ANAME', aname);
    wf_core.raise('WFSQL_ARGS');
  end if;

  -- Get type and format of attr.
  -- This is used for translating number/date strings.
  begin
    select WMA.TYPE, WMA.FORMAT
    into atype, format
    from WF_NOTIFICATION_ATTRIBUTES WNA, WF_NOTIFICATIONS WN,
         WF_MESSAGE_ATTRIBUTES WMA
    where WNA.NOTIFICATION_ID = nid
    and WNA.NAME = aname
    and WNA.NOTIFICATION_ID = WN.NOTIFICATION_ID
    and WN.MESSAGE_NAME = WMA.MESSAGE_NAME
    and WN.MESSAGE_TYPE = WMA.MESSAGE_TYPE
    and WNA.NAME = WMA.NAME;
  exception
    when no_data_found then
      -- This is an unvalidated runtime attr.
      -- Treat it as a varchar2.
      atype := 'VARCHAR2';
      format := '';
  end;

  -- Select value from appropriate type column.
  begin
    if (atype = 'NUMBER') then
      select decode(format,
                    '', to_char(WNA.NUMBER_VALUE),
                    to_char(WNA.NUMBER_VALUE, format))
      into   lvalue
      from   WF_NOTIFICATION_ATTRIBUTES WNA
      where  WNA.NOTIFICATION_ID = nid and WNA.NAME = aname;
    elsif (atype = 'DATE') then
      -- <bug 7514495> apply format precedence to get date text
      select DATE_VALUE into l_valDate
      from   WF_NOTIFICATION_ATTRIBUTES WNA
      where  WNA.NOTIFICATION_ID = nid and WNA.NAME = aname;

      lvalue := wf_notification_util.GetCalendarDate(nid, l_valDate, format, false);

    else
      -- VARCHAR2, LOOKUP, FORM, or URL type.
      select WNA.TEXT_VALUE
      into   lvalue
      from   WF_NOTIFICATION_ATTRIBUTES WNA
      where  WNA.NOTIFICATION_ID = nid and WNA.NAME = aname;

      -- Recursively substitute attributes in parameter portion of
      -- FORM and URL type attributes.
      -- Note a slight chance of infinite recursion here if
      -- parameters are defined perversely.
      if (atype = 'FORM') then
        -- FORM params are after ':'
        params := instr(lvalue, ':');
        if (params <> 0) then
          lvalue := substr(lvalue, 1, params)||
                    wf_notification.GetShortText(substr(lvalue,
                                                 params+1), nid);
        end if;
      elsif (atype = 'URL') then
        -- URL params are after '?'
        params := instr(lvalue, '?');
        if (params <> 0) then
          lvalue := substr(lvalue, 1, params)||
                    wf_notification.GetUrlText(substr(lvalue,
                                               params+1), nid);
        end if;
       end if;
    end if;
  exception
    when no_data_found then
      if (ignore_notfound) then
         return(null);
      else
         wf_core.token('NID', to_char(nid));
         wf_core.token('ATTRIBUTE', aname);
         wf_core.raise('WFNTF_ATTR');
      end if;
  end;

  return(lvalue);
exception
  when others then
    wf_core.context('Wf_Notification', 'GetAttrText', to_char(nid), aname);
    raise;
end GetAttrText;

--
-- GetAttrNumber
--   Get the value of a number notification attribute.
--   Attribute must be a NUMBER-type attribute.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
--
function GetAttrNumber (nid in number,
                        aname in varchar2)
return number is
  lvalue number;
begin
  if ((nid is null) or (aname is null)) then
    wf_core.token('NID', to_char(nid));
    wf_core.token('ANAME', aname);
    wf_core.raise('WFSQL_ARGS');
  end if;

  begin
    select WNA.NUMBER_VALUE
    into   lvalue
    from   WF_NOTIFICATION_ATTRIBUTES WNA
    where  WNA.NOTIFICATION_ID = nid and WNA.NAME = aname;
  exception
    when no_data_found then
      wf_core.token('NID', to_char(nid));
      wf_core.token('ATTRIBUTE', aname);
      wf_core.raise('WFNTF_ATTR');
  end;

  return(lvalue);
exception
  when others then
    wf_core.context('Wf_Notification', 'GetAttrNumber', to_char(nid), aname);
    raise;
end GetAttrNumber;

--
-- GetAttrDate
--   Get the value of a date notification attribute.
--   Attribute must be a DATE-type attribute.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
--
function GetAttrDate (nid in number,
                      aname in varchar2)
return date is
  lvalue date;
begin
  if ((nid is null) or (aname is null)) then
    wf_core.token('NID', to_char(nid));
    wf_core.token('ANAME', aname);
    wf_core.raise('WFSQL_ARGS');
  end if;

  begin
    select WNA.DATE_VALUE
    into   lvalue
    from   WF_NOTIFICATION_ATTRIBUTES WNA
    where  WNA.NOTIFICATION_ID = nid and WNA.NAME = aname;
  exception
    when no_data_found then
      wf_core.token('NID', to_char(nid));
      wf_core.token('ATTRIBUTE', aname);
      wf_core.raise('WFNTF_ATTR');
  end;

  return(lvalue);
exception
  when others then
    wf_core.context('Wf_Notification', 'GetAttrDate', to_char(nid), aname);
    raise;
end GetAttrDate;

--
--
-- GetAttrDoc
--   Get the displayed value of a DOCUMENT-type attribute.
--   Returns referenced document in format requested.
--   Use GetAttrText to get retrieve the actual attr value (i.e. the
--   document key string instead of the actual document).
-- NOTE:
--   Only PLSQL document type is implemented.
--   This function will call a revised implementation of procedure GetAttrDoc2
--   which will return the document type also.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
--   disptype - Requested display type.  Valid values:
--               wf_notification.doc_text - 'text/plain'
--               wf_notification.doc_html - 'text/html'
-- RETURNS:
--   Referenced document in format requested.
--
function GetAttrDoc(
  nid in number,
  aname in varchar2,
  disptype in varchar2)
return varchar2
is
  document varchar2(32000);
  doctype  varchar2(255);
begin

  -- call the procedure to get the Document Content and return to the caller.
  wf_notification.GetAttrDoc2(nid, aname, disptype, document, doctype);
  return (document);

exception
  when others then
    wf_core.context('Wf_Notification', 'GetAttrDoc', to_char(nid), aname,
        disptype);
    raise;
end GetAttrDoc;

--
-- GetAttrDoc2 - <explained in wfntfs.pls>
--
procedure GetAttrDoc2(
  nid      in     number,
  aname    in     varchar2,
  disptype in     varchar2,
  document out nocopy varchar2,
  doctype  out nocopy varchar2)
is
  key          varchar2(4000);
  colon        pls_integer;
  slash        pls_integer;
  dmstype      varchar2(30);
  display_name varchar2(80);
  procname     varchar2(240);
  launch_url   varchar2(4000);
  procarg      varchar2(32000);
  username     varchar2(320);
  sqlbuf       varchar2(2000);
  target       varchar2(240);
  l_charcheck  boolean;
begin

  -- Check args
  if ((nid is null) or (aname is null) or
     (disptype not in (wf_notification.doc_text,
                       wf_notification.doc_html))) then
    wf_core.token('NID', to_char(nid));
    wf_core.token('ANAME', aname);
    wf_core.token('DISPTYPE', disptype);
    wf_core.raise('WFSQL_ARGS');
  end if;

  -- Retrieve key string
  key := GetAttrText(nid, aname);

  -- If the key is empty then return a null string
  if (key is null) then
     document := '';
     return;
  end if;

  -- Parse doc mgmt system type from key
  colon := instr(key, ':');
  if ((colon <> 0) and (colon < 30)) then
    dmstype := upper(substr(key, 1, colon-1));
  end if;

  if (dmstype in ('PLSQLCLOB','PLSQLBLOB')) then
    document := '&'||aname;
    plsql_clob_exists := 1;
    return;
  elsif (dmstype = 'PLSQL') then
    -- Parse out procedure name and arg
    slash := instr(key, '/');
    if (slash = 0) then
      procname := substr(key, colon+1);
      procarg := '';
    else
      procname := substr(key, colon+1, slash-colon-1);
      procarg := substr(key, slash+1);
    end if;

    -- Dynamic sql call to procedure
    if (procarg is null) then
       --force a dummy value since no doc id to pass
       procarg := NULL;
    else
       -- Substitute refs to other attributes in argument
       -- NOTE: There is a slight chance of recursive loop here,
       -- if the substituted string eventually contains a reference
       -- back to this same docattr.
       procarg := Wf_Notification.GetTextInternal(procarg, nid, target, FALSE,
                                                  FALSE, 'text/plain');
    end if;

    -- ### Review Note 4

    l_charcheck := wf_notification_util.CheckIllegalChar(procname);
    --Throw the Illegal exception when the check fails

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string2(wf_log_pkg.level_statement,
                        'wf.plsql.wf_notification.GetAttrDoc2.plsqldoc_callout',
                        'Start executing PLSQL Doc procedure - '||procname, true);
    end if;

    sqlbuf := 'begin '||procname||'(:p1, :p2, :p3, :p4); end;';
    -- Catch any exceptions from PLSQL Document APIs as is and log it to help
    -- troubleshoot issues from non-WF code
    begin
      execute immediate sqlbuf using
       in procarg,
       in disptype,
       in out document,
       in out doctype;
    exception
      when others then
        if (wf_log_pkg.level_exception >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_exception,
                      'wf.plsql.wf_notification.GetAttrDoc2.plsqldoc_api',
                      'Error executing PLSQL Doc API - '||procname||' -> '||sqlerrm);
        end if;

    -- Bug 10130433: Throwing the WF error 'WFNTF_GEN_DOC' with all the error information
        -- when an exception occurs while executing the PLSQL Document APIs
    WF_CORE.Token('DOC_TYPE', 'PLSQL');
    WF_CORE.Token('FUNC_NAME', procname);
        WF_CORE.Token('SQLCODE', to_char(sqlcode));
        WF_CORE.Token('SQLERRM', DBMS_UTILITY.FORMAT_ERROR_STACK());
        WF_CORE.Raise('WFNTF_GEN_DOC');
    end;

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string2(wf_log_pkg.level_statement,
                        'wf.plsql.wf_notification.GetAttrDoc2.plsqldoc_callout',
                        'End executing PLSQL Doc procedure - '||procname, false);
    end if;

    -- Bug 8552982, 8916583 - Call GetText2 to substitute any further tokens in DOCUMENT
    -- attr content but excluding further DOCUMENT type attibutes within it. We don't
    -- support DOCUMENTs within a DOCUMENT
    document := wf_notification.GetText2(document, nid, disptype, false);

    -- Translate doc types if needed
    if ((disptype = wf_notification.doc_html) and
        (doctype = wf_notification.doc_text)) then
      -- Change plain text to html by wrapping in preformatted tags
      document := '<PRE>'||document||'</PRE>';
    end if;
    return;

  else
     -- Get the attribute display name, get type and format of attr
     -- This is used for translating number/date strings.
     begin
       select WMATL.DISPLAY_NAME, NVL(WMA.FORMAT, '_blank')
         into display_name, target
         from WF_NOTIFICATION_ATTRIBUTES WNA, WF_NOTIFICATIONS WN,
              WF_MESSAGE_ATTRIBUTES_TL WMATL, WF_MESSAGE_ATTRIBUTES WMA
        where WNA.NOTIFICATION_ID = nid
          and WNA.NAME = aname
          and WNA.NOTIFICATION_ID = WN.NOTIFICATION_ID
          and WN.MESSAGE_NAME = WMATL.MESSAGE_NAME
          and WN.MESSAGE_TYPE = WMATL.MESSAGE_TYPE
          and WNA.NAME = WMATL.NAME
          and WN.MESSAGE_NAME = WMA.MESSAGE_NAME
          and WN.MESSAGE_TYPE = WMA.MESSAGE_TYPE
          and WNA.NAME = WMA.NAME
          and WMATL.LANGUAGE = userenv('LANG');
     exception
       when no_data_found then
         display_name := null;
       when others then
         raise;
     end;

     /*
     ** If this is a plain text request then just return the display
     ** name for the attribute.  If it is html then get the attachment
     ** URL link and return it.
     */
     if (disptype = wf_notification.doc_html) THEN

        -- Returns session user name if available
        username := Wfa_Sec.GetUser;

        fnd_document_management.get_launch_document_url (
                          username, key, FALSE, launch_url);

        document :=  '<A class="OraLink" HREF="'||launch_url|| '" TARGET="'||target||'">'||
                     display_name||'</A>';

     ELSE
         document :=  display_name;
     END IF;
     return;
  end if;
  document := null;
exception
   when others then
     wf_core.context('wf_notification', 'GetAttrDoc2', to_char(nid), aname, disptype);
     raise;
end GetAttrDoc2;

-- bug 2581129
-- GetSubject
--   Get subject of notification message with token values substituted
--   from notification attributes. Takes disptype as input.
-- IN:
--   nid - Notification Id
--   disptype - Display Type
-- RETURNS:
--   Substituted message subject
-- NOTE:
--   If errors are detected this routine returns the subject unsubstituted,
--   or null if all else fails, instead of raising exceptions.
--
function GetSubject(
  nid      in number,
  disptype in varchar2)
return varchar2 is
  local_subject varchar2(240);
  target        varchar2(16);
  l_error       varchar2(32000);

begin
  -- Get subject
  select WM.SUBJECT
  into local_subject
  from WF_NOTIFICATIONS N, WF_MESSAGES_VL WM
  where N.NOTIFICATION_ID = nid
  and N.MESSAGE_NAME = WM.NAME
  and N.MESSAGE_TYPE = WM.TYPE;

  -- Return substituted subject, limited to 240 chars in case
  -- tokens exceed length.
  -- return(substrb(GetTextInternal(local_subject, nid, target, FALSE,
  --                               TRUE, disptype), 1, 240));
  -- Allow PLSQL Document attributes within Subject
  return(substrb(GetText(local_subject, nid, disptype), 1, 240));

exception
  when others then
    -- Return the error message with error stack
    l_error := wf_core.translate('ERROR') || wf_core.newline;
    if (wf_core.error_name is not null) then
      l_error := l_error || wf_core.error_message || wf_core.newline;
      l_error := l_error || wf_core.translate('WFENG_ERRNAME') || ': ' ||
                 wf_core.error_name || wf_core.newline;
    else
      l_error := l_error || sqlerrm || wf_core.newline;
      l_error := l_error || wf_core.translate('WFENG_ERRNAME') || ': ' ||
                 to_char(sqlcode) || wf_core.newline;
    end if;
    l_error := l_error || wf_core.translate('WFENG_ERRSTACK') || ': ' ||
               wf_core.error_stack || wf_core.newline;
    return (substrb(l_error, 1, 240));
end GetSubject;

-- GetSubject
--   Get subject of notification message with token values substituted
--   from notification attributes.
-- IN:
--   nid - Notification Id
-- RETURNS:
--   Substituted message subject
-- NOTE:
--   If errors are detected this routine returns the subject unsubstituted,
--   or null if all else fails, instead of raising exceptions.
--
function GetSubject(nid in number)
return varchar2 is
  local_subject varchar2(240);
begin
  return (Wf_Notification.GetSubject(nid, 'text/html'));
end GetSubject;

--
-- GetBody
--   Get body of notification message with token values substituted
--   from notification attributes.
--     This function may return up to 32K chars. It can NOT be used in a view
--   definition or in a Form.  For views and forms, use GetShortBody, which
--   truncates values at 1950 chars.
-- IN:
--   nid - Notification Id
--   disptype - Requested display type.  Valid values:
--               wf_notification.doc_text - 'text/plain'
--               wf_notification.doc_html - 'text/html'
--               wf_notification.doc_attach - ''
-- RETURNS:
--   Substituted message body
-- NOTE:
--   If errors are detected this routine returns the body unsubstituted,
--   or null if all else fails, instead of raising exceptions.
--
function GetBody(
  nid in number,
  disptype in varchar2)
return varchar2 is
  local_body varchar2(32000);
  local_html_body varchar2(32000);

  -- To check if Reassign or Request Info is performed on a FYI Notification
  CURSOR c_comm IS
  SELECT count(1)
  FROM   wf_comments
  WHERE  action_type in ('REASSIGN', 'QA')
  AND    notification_id = nid
  AND    rownum = 1;

  l_resp_cnt    number;
  l_fyi         boolean;
  l_comm_cnt    pls_integer;
  l_html_hist   boolean;
  l_cust_hist   varchar2(4000);
  l_action_hist varchar2(240);
begin
  -- Get body
  select WM.BODY, WM.HTML_BODY
  into local_body, local_html_body
  from WF_NOTIFICATIONS N, WF_MESSAGES_VL WM
  where N.NOTIFICATION_ID = nid
  and N.MESSAGE_NAME = WM.NAME
  and N.MESSAGE_TYPE = WM.TYPE;

  -- If user has not used WF_NOTIFICATION(HISTORY) or #HISTORY, append Action History in the
  -- notification body by default if this is a...
  -- 1. Response required notification
  -- 2. FYI notification with at least one Reassign action
  -- Query to check if the ntf is FYI or not
  SELECT count(1)
  INTO   l_resp_cnt
  FROM   wf_message_attributes wma,
         wf_notifications wn
  WHERE  wn.notification_id = nid
  AND    wma.message_type = wn.message_type
  AND    wma.message_name = wn.message_name
  AND    wma.subtype = 'RESPOND'
  AND    rownum = 1;

  if (l_resp_cnt = 0) then
    l_fyi := true;
  else
    l_fyi := false;
  end if;

  -- If this is FYI, get the count of Reassign and Request Info actions
  if (l_fyi) then
    l_comm_cnt := 0;
    open c_comm;
    fetch c_comm into l_comm_cnt;
    if (c_comm%notfound) then
      l_comm_cnt := 0;
    end if;
    close c_comm;
  end if;

  l_html_hist := false;
  if ((l_fyi and l_comm_cnt > 0) or not l_fyi) then
    -- According to bug 3612609, if the user just defines #HISTORY, but does not place it in the
    -- message body, even then it should be used instead of default WF Action History
    begin
      l_cust_hist := Wf_Notification.GetAttrText(nid, '#HISTORY');
    exception
      when others then
        l_cust_hist := '';
        Wf_Core.Clear;
    end;
    -- Validate if l_cust_hist has a valid PLSQL doc api attached to it. If it ever has JSP: we
    -- would not be here.
    if (l_cust_hist is not null and upper(trim(substr(l_cust_hist, 1, 5))) = 'PLSQL') then
      l_action_hist := '&#HISTORY';
    else
      l_action_hist := 'WF_NOTIFICATION(HISTORY)';
    end if;

    -- Either a FYI with at least one reassign/Request Info or a Response notification.
    -- So, append Action History
    if (local_body is not null and instrb(local_body, 'WF_NOTIFICATION(HISTORY)') = 0 and
                                   instrb(local_body, '&#HISTORY') = 0) then

      local_body := local_body || Wf_Core.newline || l_action_hist;
    end if;

    if (local_html_body is not null and instrb(local_html_body, 'WF_NOTIFICATION(HISTORY)') = 0 and
                                        instrb(local_html_body, '&#HISTORY') = 0) then
      -- Defer adding history macro until after stripping off BODY tags
      l_html_hist := true;
    end if;
  end if;

  -- Return substituted body.
  if (disptype = wf_notification.doc_text) then
    local_body := GetText(local_body, nid, disptype);

    -- replace the functions here
    local_body := runFuncOnBody(nid, local_body, disptype);

    return(local_body);
  else
    if (local_html_body is null) then
      --use the plain text body but fake it as html by adding <BR>
      local_body := substrb(replace(local_body, wf_core.newline,
                                    '<BR>'||wf_core.newline),1, 32000);

      -- get the attribute values
      local_body := GetText(local_body, nid, disptype);

      -- replace the functions here
      local_body := runFuncOnBody(nid, local_body, disptype);

      return(local_body);
    else
      if instr(upper(local_html_body),'<BODY')>0 then
      --strip out the Body tag

      local_html_body:=  substr(local_html_body,
                         instr(local_html_body,'>',
                               instr(upper(local_html_body),'<BODY'))+1);
      end if;

      if instr(upper(local_html_body),'</BODY')>0 then
      local_html_body:=  substr(local_html_body,1,
                         instr(upper(local_html_body),'</BODY')-1);
      end if;

      if (l_html_hist) then
        local_html_body := local_html_body || Wf_Core.newline || l_action_hist;
      end if;

      local_html_body := GetText(local_html_body, nid, disptype);

      -- replace the functions here
      local_html_body := runFuncOnBody(nid, local_html_body, disptype);

      return(local_html_body);
    end if;
  end if;

exception
  when others then
    wf_core.context('Wf_Notification', 'GetBody', to_char(nid), disptype);
    raise;
end GetBody;

--
-- GetShortBody
--   Get body of notification message with token values substituted
--   from notification attributes.
--     This function is meant to be used in view definitions and Forms, where
--   the field size must be limited to 2000 chars.  Use GetBody() to retrieve
--   up to 32K if the text may be longer.
-- IN:
--   nid - Notification Id
-- RETURNS:
--   Substituted message body
-- NOTE:
--   If errors are detected this routine returns the body unsubstituted,
--   or null if all else fails, instead of raising exceptions.  It must do
--   this so the routine can be pragma'd and used in the
--   wf_notifications_view view.
--
function GetShortBody(nid in number)
return varchar2 is
  local_body varchar2(4000);
  l_error    varchar2(32000);
begin
  -- Get body
  select WM.BODY
  into local_body
  from WF_NOTIFICATIONS N, WF_MESSAGES_VL WM
  where N.NOTIFICATION_ID = nid
  and N.MESSAGE_NAME = WM.NAME
  and N.MESSAGE_TYPE = WM.TYPE;

  -- Return substituted body.
  -- GetShortText already limits to 1950 chars, so further limit is not needed.
  return(GetShortText(local_body, nid));
exception
  when others then
    -- If there is a failure in GetShortText, the error message is returned
        -- Return the error message with error stack
    l_error := wf_core.translate('ERROR') || wf_core.newline;
    if (wf_core.error_name is not null) then
      l_error := l_error || wf_core.error_message || wf_core.newline;
      l_error := l_error || wf_core.translate('WFENG_ERRNAME') || ': ' ||
                 wf_core.error_name || wf_core.newline;
    else
      l_error := l_error || sqlerrm || wf_core.newline;
      l_error := l_error || wf_core.translate('WFENG_ERRNAME') || ': ' ||
                 to_char(sqlcode) || wf_core.newline;
    end if;
    l_error := l_error || wf_core.translate('WFENG_ERRSTACK') || ': ' ||
               wf_core.error_stack || wf_core.newline;
    return (substrb(l_error, 1, 1950));
end GetShortBody;

--
-- GetInfo
--   Return info about notification
-- IN:
--   nid - Notification Id
-- OUT:
--   role - Role notification is sent to
--   message_type - Type flag of message
--   message_name - Message name
--   priority - Notification priority
--   due_date - Due date
--   status - Notification status (OPEN, CLOSED, CANCELED)
--
procedure GetInfo(nid in number,
                  role out nocopy varchar2,
                  message_type out nocopy varchar2,
                  message_name out nocopy varchar2,
                  priority out nocopy varchar2,
                  due_date out nocopy varchar2,
                  status out nocopy varchar2)
is
begin

  begin
    select
      N.RECIPIENT_ROLE,
      N.MESSAGE_TYPE,
      N.MESSAGE_NAME,
      N.PRIORITY,
      N.DUE_DATE,
      N.STATUS
    into
      GetInfo.role,
      GetInfo.message_type,
      GetInfo.message_name,
      GetInfo.priority,
      GetInfo.due_date,
      GetInfo.status
    from WF_NOTIFICATIONS N
    where N.NOTIFICATION_ID = nid;
  exception
    when no_data_found then
      wf_core.token('NID', to_char(nid));
      wf_core.raise('WFNTF_NID');
  end;

exception
  when others then
    wf_core.context('Wf_Notification', 'GetInfo', to_char(nid));
    raise;
end GetInfo;

--
-- Responder
--   Return responder of closed notification.
-- IN
--   nid - Notification Id
-- RETURNS
--   Responder to notification.  If no responder was set or notification
--   not yet closed, return null.
--
function Responder(
  nid in number)
return varchar2
is
  respbuf varchar2(240);
begin
  if (nid is null) then
    wf_core.token('NID', to_char(nid));
    wf_core.raise('WFSQL_ARGS');
  end if;

  -- Get responder
  begin
    select WN.RESPONDER
    into respbuf
    from WF_NOTIFICATIONS WN
    where WN.NOTIFICATION_ID = nid;
  exception
    when no_data_found then
      wf_core.token('NID', to_char(nid));
      wf_core.raise('WFNTF_NID');
  end;

  return(respbuf);
exception
  when others then
    Wf_Core.Context('Wf_Notification', 'Responder', to_char(nid));
    raise;
end Responder;

-- AccessCheck
--   Check that the access key is valid for this notification.
-- IN
--   Access string <nid>/<nkey>
-- RETURNS
--   user name (or NULL)
function AccessCheck(access_str in varchar2) return varchar2
is
    pos   pls_integer;
    nid   pls_integer;
    nkey  varchar2(80);
    uname varchar2(320);
begin
    pos  := instr(access_str, '/');
    nid  := to_number(substr(access_str, 1, pos-1));
    nkey := substr(access_str, pos+1);

    select recipient_role
    into   uname
    from   WF_NOTIFICATIONS
    where  NOTIFICATION_ID = nid
    and    ACCESS_KEY = nkey;

    return uname;
exception
    when others then
        return NULL;
end AccessCheck;

--
-- GetMailPreference (PRIVATE)
--   Get the mail preference of a role
-- IN
--   role - role notification being sent to
--   callback - engine callback
--   context -  engine callback context
-- RETURNS
--   mail preference of role
--
function GetMailPreference(
  role in varchar2,
  callback in varchar2,
  context in varchar2)
return varchar2
is
  colon pls_integer;
  mailpref varchar2(8);

  sqlbuf varchar2(2000);
  tvalue varchar2(4000);
  nvalue number;
  dvalue date;
  l_language    varchar2(80);
  l_territory   varchar2(80);
  l_email       varchar2(320);
  l_dname       varchar2(360);
        l_charcheck   boolean;

begin

  -- ROLE type, get display_name of role
  wf_directory.getroleinfo (GetMailPreference.role, l_dname,
                            l_email, mailpref,
                            l_language, l_territory);

  --
  -- Check for the "special" mail suppression item attribute.
  -- This attribute is set to the process originator in the Process
  -- Navigator, so that the originator doesn't receive mail generated
  -- by that process.
  --
  if (callback is not null) then
    -- ### Review Note 3 - private function
    l_charcheck := WF_NOTIFICATION_UTIL.CheckIllegalChar(callback);


       -- BINDVAR_SCAN_IGNORE
       sqlbuf := 'begin '||callback||
              '(:p1, :p2, :p3, :p4, :p5, :p6, :p7); end;';
       begin
         execute immediate sqlbuf using
          in 'GET',
          in context,
          in '.MAIL_QUERY',
          in 'VARCHAR2',
          in out tvalue,
          in out nvalue,
          in out dvalue;
       exception
          when others then
          -- Ignore cases where no attribute is defined
           if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
             wf_core.clear;
           else
             raise;
           end if;
       end;

       -- We have a match, this is the originator.  No mail for you.
       if (tvalue = role) then
        mailpref := 'QUERY';
       end if;
  end if;

  return mailpref;

exception
  when others then
    Wf_Core.Context('Wf_Notification', 'GetMailPreference', role);
    raise;
end GetMailPreference;

--
-- Route (PRIVATE)
--   Auto-forward or respond to notification according to routing rules
--   when notification is sent or forwarded.
--   Called from SendSingle and Forward.
-- IN
--   nid - Notification id
--
procedure Route(
  nid in number,
  cnt in number)
is
  l_dis_reassign_sub varchar2(1);
  recip   varchar2(320);
  o_recip varchar2(320);
  msgtype varchar2(8);
  msgname varchar2(30);

  newcomment varchar2(4000);

  badfwd   exception;          -- bad Forward/Transfer happened
  inactive_role exception;     -- Notification not routed if role is inactive
  errmsg   varchar2(4000);
  dummy    varchar2(4000);
  l_hide_reassign varchar(1);
  l_context WF_NOTIFICATIONS.CONTEXT%TYPE;
  l_item_key WF_ITEMS.ITEM_KEY%TYPE;
  l_act_id number;
  l_wf_owner WF_ITEMS.OWNER_ROLE%TYPE := null;
  l_init_role WF_COMMENTS.FROM_ROLE%TYPE := null;

  cursor rulecurs is
    select WRR.RULE_ID, WRR.ACTION, WRR.ACTION_ARGUMENT, WRR.RULE_COMMENT
    from WF_ROUTING_RULES WRR
    where WRR.ROLE = recip
    and sysdate between nvl(WRR.BEGIN_DATE, sysdate-1) and
                        nvl(WRR.END_DATE, sysdate+1)
    and nvl(WRR.MESSAGE_TYPE, msgtype) = msgtype
    and nvl(WRR.MESSAGE_NAME, msgname) = msgname
    order by WRR.MESSAGE_TYPE, WRR.MESSAGE_NAME;

  rulerec rulecurs%rowtype;

  cursor attrcurs(ruleid in number) is
    select WRRA.NAME, WRRA.TEXT_VALUE, WRRA.NUMBER_VALUE, WRRA.DATE_VALUE,
           WMA.TYPE
    from WF_ROUTING_RULE_ATTRIBUTES WRRA, WF_ROUTING_RULES WRR,
         WF_MESSAGE_ATTRIBUTES WMA
    where WRRA.RULE_ID = ruleid
    and WRRA.RULE_ID = WRR.RULE_ID
    and WRR.MESSAGE_TYPE = WMA.MESSAGE_TYPE
    and WRR.MESSAGE_NAME = WMA.MESSAGE_NAME
    and WRRA.NAME = WMA.NAME;

begin
  -- Get ntf current recipient and message
  begin
    select WN.RECIPIENT_ROLE, WN.MESSAGE_TYPE, WN.MESSAGE_NAME, WN.CONTEXT
    into recip, msgtype, msgname, l_context
    from WF_NOTIFICATIONS WN
    where WN.NOTIFICATION_ID = nid;

    o_recip := recip;  -- set original recipient
  exception
    when no_data_found then
      wf_core.token('NID', to_char(nid));
      wf_core.raise('WFNTF_NID');
  end;

  /* implement the above loop recursively */
  if (cnt > wf_notification.max_forward) then
    -- it means max_forward must have been exceeded.  Treat as a loop error.
    wf_core.token('NID', to_char(nid));
    wf_core.raise('WFNTF_ROUTE_LOOP');
  end if;

  -- Select one routing rule to execute
  open rulecurs;
  fetch rulecurs into rulerec;
  if (rulecurs%notfound) then
    -- No routing rules found - treat like a NOOP
    rulerec.action := 'NOOP';
    rulerec.rule_comment := '';
  end if;
  close rulecurs;

  -- If rule has a comment append it to the buffer
  -- if (rulerec.rule_comment is not null) then
  --  if (newcomment is not null) then
  --    newcomment := substrb(newcomment||wf_core.newline, 1, 4000);
  --  end if;
  --  newcomment := substrb(newcomment||recip||': '||rulerec.rule_comment,
  --                        1, 4000);
  -- end if;

  -- Check for value in #HIDE_REASSIGN attribute if defined
  -- Y: Donot allow Reassign
  -- N: Allow Reassign
  -- B: Allow Reassign only through Routing Rule
  l_hide_reassign := 'N';
  begin
    l_hide_reassign := Wf_Notification.GetAttrText(nid, '#HIDE_REASSIGN');
  exception
    when others then
      -- Clear the error stack since we ignore the error
      Wf_Core.Clear;
  end;
   -- Bug 7358225: If the recipient role of the routing rule is inactive then update the user_comment
   -- for the notification and return without executing the routing rule
  if LENGTH(rulerec.action_argument) > 0 then
    if Not Wf_Directory.RoleActive(rulerec.action_argument) then
      raise inactive_role;
    end if;
  end if;
  newcomment := rulerec.rule_comment;
  recip := rulerec.action_argument;

  -- get profile value for WF_DISABLE_REASSIGN_SUBMITTER
  l_dis_reassign_sub := substr(fnd_profile.value('WF_DISABLE_REASSIGN_SUBMITTER'),1,1);

  -- Bug 24294590: Use profile option to control delegation to owner/initiator.
  if (l_dis_reassign_sub = 'Y') then
    -- Should not route a notification to WF process owner or initiator.
    -- Cannot use getNtfActInfo because notification ID has not made it yet
    -- into WIAS. Have to use the context to get item type and key.
    if rulerec.action in ('FORWARD', 'TRANSFER') then
      validate_context (context  => l_context,
                        itemtype => msgtype,
                        itemkey  => l_item_key,
                        actid    => l_act_id);
      -- Bug 21386246: When wf_notificationotification.send called directly there is no workflow
      -- process associated, item type and item key will be null,check that condition here.
      if (msgtype is not null and l_item_key is not null) then
        select OWNER_ROLE into l_wf_owner
          from WF_ITEMS
          where ITEM_TYPE = msgtype
            and ITEM_KEY = l_item_key;
      end if;
      if (l_wf_owner is null) then
        select FROM_ROLE into l_init_role from
        (
          select FROM_ROLE
            from WF_ITEM_ACTIVITY_STATUSES IAS,
                 WF_COMMENTS C
            where IAS.ITEM_TYPE        = msgtype
              and IAS.ITEM_KEY         = l_item_key
              and IAS.PROCESS_ACTIVITY = l_act_id
              and IAS.NOTIFICATION_ID  = C.NOTIFICATION_ID
              and C.ACTION             = 'SEND_FIRST'
          union
          select FROM_ROLE
            from WF_ITEM_ACTIVITY_STATUSES_H IASH,
                 WF_COMMENTS C
            where IASH.ITEM_TYPE        = msgtype
              and IASH.ITEM_KEY         = l_item_key
              and IASH.PROCESS_ACTIVITY = l_act_id
              and IASH.NOTIFICATION_ID  = C.NOTIFICATION_ID
              and C.ACTION              = 'SEND_FIRST'
          union
          select FROM_ROLE
            from WF_COMMENTS C
            where C.NOTIFICATION_ID = nid
              and C.ACTION          = 'SEND_FIRST'
        );
      end if;
      if recip in (l_wf_owner, l_init_role) then
        raise badfwd;
      end if;
    end if;
  end if;

  if (rulerec.action = 'FORWARD' and l_hide_reassign in ('N', 'B')) then
    -- FORWARD
    -- Set savepoint before doing anything.
    -- savepoint fwd_ntf;

    -- Reset recipient and cycle through the loop again to check
    -- for another forward.

    begin
-- ### implement this in next release
--    Wf_Notification.Forward(nid, recip, newcomment, o_recip, cnt+1);
      Wf_Notification.Forward(nid, recip, newcomment, o_recip, cnt+1, 'RULE');
    exception
      when others then
        raise badfwd;
    end;
  elsif (rulerec.action = 'TRANSFER' and l_hide_reassign in ('N', 'B')) then
    -- TRANSFER
    -- Set savepoint before doing anything.
    -- savepoint fwd_ntf;

    -- Reset recipient and cycle through the loop again to check
    -- for another transfer.

    begin
-- ### implement this in next release
--    Wf_Notification.Transfer(nid, recip, newcomment, o_recip, cnt+1);
      Wf_Notification.Transfer(nid, recip, newcomment, o_recip, cnt+1, 'RULE');
    exception
      when others then
        raise badfwd;
    end;
  elsif (rulerec.action = 'RESPOND') then
    -- RESPOND
    -- Query response values for this rule and set attrs accordingly
    for respattr in attrcurs(rulerec.rule_id) loop
      if (respattr.type = 'NUMBER') then
        Wf_Notification.SetAttrNumber(nid, respattr.name,
                                      respattr.number_value);
      elsif (respattr.type = 'DATE') then
        Wf_Notification.SetAttrDate(nid, respattr.name,
                                    respattr.date_value);
      else -- All other types use text
        Wf_Notification.SetAttrText(nid, respattr.name,
                                    respattr.text_value);
      end if;
    end loop;

    -- Complete response
    Wf_Notification.Respond(nid, newcomment, recip, 'RULE');
  else
    -- This must be one of:
    --   a. NOOP rule
    --   b. No routing rule found
    --   c. Unimplemented rule type
    -- In any case, just return
    return;
  end if;
  return;
exception
  when inactive_role then
    begin
      update WF_NOTIFICATIONS set
        USER_COMMENT = substr(USER_COMMENT||decode(nvl(USER_COMMENT,'T'),
                       'T', null, wf_core.newline)||wf_core.translate('INACTIVE_ROLE'), 1, 4000)
       where NOTIFICATION_ID = nid;
    exception
      when others then
        wf_core.context('Wf_Notification', 'Route (update comment)',to_char(nid));
        raise;
    end;
  when badfwd then
    Wf_Core.Get_Error(dummy, errmsg, dummy);
    Wf_Core.Clear;
    if (newcomment is not null) then
      newcomment := newcomment||wf_core.newline;
    end if;
    if recip in (l_wf_owner, l_init_role) then
      Wf_Notification.SetComments(nid, o_recip, recip, rulerec.action,
                                  'RULE', Wf_Core.Translate('OWNER_ROUTE_FAIL'));
    else
      Wf_Core.Token('TO_ROLE', WF_Directory.GetRoleDisplayName(recip));
      newcomment := substrb(newcomment||
                    Wf_Core.Translate('AUTOROUTE_FAIL')||
                    wf_core.newline||errmsg, 1, 4000);
    end if;
    begin
        -- append newcomment to the existing comment.
        -- need to add a newline character if user_comment is not null.
        update WF_NOTIFICATIONS set
          USER_COMMENT = substr(USER_COMMENT||
                           decode(nvl(USER_COMMENT,'T'),
                                'T', null, wf_core.newline)||
                           Route.newcomment, 1, 4000)
         where NOTIFICATION_ID = nid;
    exception
      when OTHERS then
        wf_core.context('Wf_Notification', 'Route (update comment)',
                        to_char(nid));
        raise;
    end;

  when others then
    if (rulecurs%isopen) then
      close rulecurs;
    end if;
    wf_core.context('Wf_Notification', 'Route', to_char(nid));
    raise;
end Route;

--
-- First_Execution (Private)
--   Checks if the given item activity is executed for the first time
--   or was executed already
-- IN
--   context - Activity Context
-- RETURN
--   boolean status, TRUE or FALSE
--
function First_Execution(p_context in varchar2)
return boolean
is
  l_count     pls_integer;
  l_item_type varchar2(8);
  l_item_key  varchar2(240);
  l_actid     number;
begin

  -- Derive item type, item key and activity id from the context
  -- when no ':' or just one ':', context does not conform to WF standard
  -- it could be sent by calling wf_notification.send directly
  -- in this case, we just return false to preserve the old behavior
  validate_context (p_context, l_item_type, l_item_key, l_actid);
  if (l_item_type is null or l_item_key is null or l_actid is null) then
    return false;
  end if;

  -- If a record exists in history table for this item activity, it has already
  -- been executed
  SELECT count(1)
  INTO   l_count
  FROM   wf_item_activity_statuses_h
  WHERE  item_type = l_item_type
  AND    item_key = l_item_key
  AND    process_activity = l_actid
  AND    rownum = 1;

  if (l_count > 0) then
    return false;
  end if;
  return true;

exception
  when others then
    Wf_Core.Context('Wf_Notification', 'First_Execution', p_context);
    raise;
end First_Execution;

-- Denormalize_Columns_Internal(PRIVATE)
-- Custom Columns
procedure denormalize_columns_internal(p_item_key in varchar2,
                                       p_user_key in varchar2,
                                       p_nid  in number)
is
  cursor c_custom_cols is
      select to_number(
                 substr(wnrm.column_name,instr(wnrm.column_name,'UTE')+3)) idx,
                 wnrm.column_name,
                 wna.text_value,
                 wna.number_value,
                 wna.date_value
      from  wf_ntf_rules wnr,
            wf_ntf_rule_maps wnrm,
            wf_ntf_rule_criteria wnrc,
            wf_notification_attributes wna,
            wf_notifications wn
      where wnr.rule_name = wnrc.rule_name
      and   wnrc.message_type = wn.message_type
      and   wnr.status = 'ENABLED'
      and   wnrc.rule_name = wnrm.rule_name
      and   wnrm.attribute_name = wna.name
      and   wna.notification_id = wn.notification_id
      and   wn.notification_id = p_nid
      order by wnr.phase;

  pta     text_array_t;
  pfa     text_array_t;
  pua     text_array_t;
  pda     date_array_t;
  pna     numb_array_t;
  ta      text_array_t;
  fa      text_array_t;
  ua      text_array_t;
  da      date_array_t;
  na      numb_array_t;

  nd      date;   /* null date */
  nn      number; /* null number */
begin

  -- initialize the varrays
  pta := text_array_t('','','','','','','','','','');
  pfa := text_array_t('','','','','');
  pua := text_array_t('','','','','');
  pda := date_array_t(nd,nd,nd,nd,nd);
  pna := numb_array_t(nn,nn,nn,nn,nn);
  ta := text_array_t('','','','','','','','','','');
  fa := text_array_t('','','','','');
  ua := text_array_t('','','','','');
  da := date_array_t(nd,nd,nd,nd,nd);
  na := numb_array_t(nn,nn,nn,nn,nn);

  for c in c_custom_cols
  loop
    if (c.column_name like 'PROTECTED_TEXT%') then
      pta(c.idx) := c.text_value;
    elsif (c.column_name like 'PROTECTED_FORM%') then
      pfa(c.idx) := c.text_value;
    elsif (c.column_name like 'PROTECTED_URL%') then
      pua(c.idx) := c.text_value;
    elsif (c.column_name like 'PROTECTED_DATE%') then
      pda(c.idx) := c.date_value;
    elsif (c.column_name like 'PROTECTED_NUMBER%') then
      pna(c.idx) := c.number_value;
    elsif (c.column_name like 'TEXT%') then
      ta(c.idx) := c.text_value;
    elsif (c.column_name like 'FORM%') then
      fa(c.idx) := c.text_value;
    elsif (c.column_name like 'URL%') then
      ua(c.idx) := c.text_value;
    elsif (c.column_name like 'DATE%') then
      da(c.idx) := c.date_value;
    elsif (c.column_name like 'NUMBER%') then
      na(c.idx) := c.number_value;
    end if;
  end loop;

  update WF_NOTIFICATIONS
    set
       PROTECTED_TEXT_ATTRIBUTE1  = pta(1)
      ,PROTECTED_TEXT_ATTRIBUTE2  = pta(2)
      ,PROTECTED_TEXT_ATTRIBUTE3  = pta(3)
      ,PROTECTED_TEXT_ATTRIBUTE4  = pta(4)
      ,PROTECTED_TEXT_ATTRIBUTE5  = pta(5)
      ,PROTECTED_TEXT_ATTRIBUTE6  = pta(6)
      ,PROTECTED_TEXT_ATTRIBUTE7  = pta(7)
      ,PROTECTED_TEXT_ATTRIBUTE8  = pta(8)
      ,PROTECTED_TEXT_ATTRIBUTE9  = pta(9)
      ,PROTECTED_TEXT_ATTRIBUTE10 = pta(10)
      ,PROTECTED_FORM_ATTRIBUTE1  = pfa(1)
      ,PROTECTED_FORM_ATTRIBUTE2  = pfa(2)
      ,PROTECTED_FORM_ATTRIBUTE3  = pfa(3)
      ,PROTECTED_FORM_ATTRIBUTE4  = pfa(4)
      ,PROTECTED_FORM_ATTRIBUTE5  = pfa(5)
      ,PROTECTED_URL_ATTRIBUTE1   = pua(1)
      ,PROTECTED_URL_ATTRIBUTE2   = pua(2)
      ,PROTECTED_URL_ATTRIBUTE3   = pua(3)
      ,PROTECTED_URL_ATTRIBUTE4   = pua(4)
      ,PROTECTED_URL_ATTRIBUTE5   = pua(5)
      ,PROTECTED_DATE_ATTRIBUTE1  = pda(1)
      ,PROTECTED_DATE_ATTRIBUTE2  = pda(2)
      ,PROTECTED_DATE_ATTRIBUTE3  = pda(3)
      ,PROTECTED_DATE_ATTRIBUTE4  = pda(4)
      ,PROTECTED_DATE_ATTRIBUTE5  = pda(5)
      ,PROTECTED_NUMBER_ATTRIBUTE1= pna(1)
      ,PROTECTED_NUMBER_ATTRIBUTE2= pna(2)
      ,PROTECTED_NUMBER_ATTRIBUTE3= pna(3)
      ,PROTECTED_NUMBER_ATTRIBUTE4= pna(4)
      ,PROTECTED_NUMBER_ATTRIBUTE5= pna(5)
      ,TEXT_ATTRIBUTE1  = ta(1)
      ,TEXT_ATTRIBUTE2  = ta(2)
      ,TEXT_ATTRIBUTE3  = ta(3)
      ,TEXT_ATTRIBUTE4  = ta(4)
      ,TEXT_ATTRIBUTE5  = ta(5)
      ,TEXT_ATTRIBUTE6  = ta(6)
      ,TEXT_ATTRIBUTE7  = ta(7)
      ,TEXT_ATTRIBUTE8  = ta(8)
      ,TEXT_ATTRIBUTE9  = ta(9)
      ,TEXT_ATTRIBUTE10 = ta(10)
      ,FORM_ATTRIBUTE1  = fa(1)
      ,FORM_ATTRIBUTE2  = fa(2)
      ,FORM_ATTRIBUTE3  = fa(3)
      ,FORM_ATTRIBUTE4  = fa(4)
      ,FORM_ATTRIBUTE5  = fa(5)
      ,URL_ATTRIBUTE1   = ua(1)
      ,URL_ATTRIBUTE2   = ua(2)
      ,URL_ATTRIBUTE3   = ua(3)
      ,URL_ATTRIBUTE4   = ua(4)
      ,URL_ATTRIBUTE5   = ua(5)
      ,DATE_ATTRIBUTE1  = da(1)
      ,DATE_ATTRIBUTE2  = da(2)
      ,DATE_ATTRIBUTE3  = da(3)
      ,DATE_ATTRIBUTE4  = da(4)
      ,DATE_ATTRIBUTE5  = da(5)
      ,NUMBER_ATTRIBUTE1= na(1)
      ,NUMBER_ATTRIBUTE2= na(2)
      ,NUMBER_ATTRIBUTE3= na(3)
      ,NUMBER_ATTRIBUTE4= na(4)
      ,NUMBER_ATTRIBUTE5= na(5)
      ,ITEM_KEY = p_item_key
      ,USER_KEY = p_user_key
      where notification_id = p_nid;

 exception
  when OTHERS then
    wf_core.context('Wf_Notification', 'denormalize_columns_internal',
             p_item_key, p_user_key, to_char(p_nid));
    raise;
end Denormalize_columns_internal;

--
-- Denormalize Custom columns(PUBLIC)
-- Called by FNDWFDCC concurrent program
--
procedure denormalizeColsConcurrent(retcode      out nocopy varchar2,
                                    errbuf       out nocopy varchar2,
                                    p_item_type  in varchar2,
                                    p_status     in varchar2,
                                    p_recipient  in varchar2)
is
   cursor c_notifications is
     select wi.item_key, wi.user_key, wn.notification_id
     from  wf_items wi,
           wf_item_activity_statuses wias,
           wf_notifications wn
     where wi.item_key = wias.item_key
     and   wi.item_type = wias.item_type
     and   wias.notification_id = wn.group_id
     and   (wn.message_type = p_item_type or p_item_type is null)
     and   wn.status =  nvl(p_status, 'OPEN')
     and   (wn.recipient_role = p_recipient or p_recipient is null)
     order by wi.item_type;

  errname varchar2(30);
  errmsg varchar2(2000);
  errstack varchar2(4000);
begin

  for v_ntf in c_notifications
  loop
       denormalize_columns_internal(v_ntf.item_key, v_ntf.user_key, v_ntf.notification_id);
  end loop;

  -- Return 0 for successful completion.
  errbuf := '';
  retcode := '0';

exception
  when others then
    -- Retrieve error message into errbuf
    wf_core.get_error(errname, errmsg, errstack);
    if (errmsg is not null) then
      errbuf := errmsg;
    else
      errbuf := sqlerrm;
    end if;

    -- Return 2 for error.
    retcode := '2';
end denormalizeColsConcurrent;

--
-- SendSingle (PRIVATE)
--   Send a single notification.
--   Called by Send and SendGroup public functions.
--   Argument error checking should be done by Send and SendGroup before
--   calling this function.
-- IN:
--   role - Role to send notification to
--   msg_type - Message type
--   msg_name - Message name
--   due_date - Date due
--   callback - Callback function
--   context - Data for callback
--   send_comment - Comment to add to notification
--   priority - Notification priority
--   group_id - Id of notification group
--              (If null use not_id of notification sent)
-- RETURNS:
--   Notification id
--
function SendSingle(role in varchar2,
                    msg_type in varchar2,
                    msg_name in varchar2,
                    due_date in date,
                    callback in varchar2,
                    context in varchar2,
                    send_comment in varchar2,
                    priority in number,
                    group_id in number)
return number is
  mailpref     varchar2(8);
  nid          pls_integer;
  attr_name    varchar2(30);
  attr_type    varchar2(8);
  attr_tvalue  varchar2(4000);
  attr_nvalue  number;
  attr_dvalue  date;
  --  Bug 2376033
  attr_evalue  wf_event_t;
  -- Bug 2283697
  l_parameterlist wf_parameter_list_t := wf_parameter_list_t();
  -- the following variables for Dynamic SQL
  sqlbuf         varchar2(2000);
  l_from_role    varchar2(320);
  l_send_comment varchar2(4000);
  l_send_source  varchar2(30);
  l_charcheck    boolean;
  -- Custom columns fix
  l_itemkey      varchar2(240);
  l_userkey      varchar2(240);
  l_itemtype     varchar2(8);
  col1           pls_integer;
  col2           pls_integer;
  l_language     varchar2(30);
  role_info_tbl  wf_directory.wf_local_roles_tbl_type;
  l_new_rcpt_role WF_NOTIFICATIONS.RECIPIENT_ROLE%TYPE;
  l_resp_key_seq number;

  cursor message_attrs_cursor(msg_type varchar2, msg_name varchar2) is
    select NAME, TYPE, SUBTYPE, VALUE_TYPE,
           TEXT_DEFAULT, NUMBER_DEFAULT, DATE_DEFAULT
    from WF_MESSAGE_ATTRIBUTES
    where MESSAGE_TYPE = msg_type
    and MESSAGE_NAME = msg_name;
begin
  -- Check role is valid and get mail preference
  mailpref := Wf_Notification.GetMailPreference(role, callback, context);

  -- Create new nid and insert notification
  select WF_NOTIFICATIONS_S.NEXTVAL
  into nid
  from SYS.DUAL;

  insert into WF_NOTIFICATIONS (
    NOTIFICATION_ID,
    GROUP_ID,
    MESSAGE_TYPE,
    MESSAGE_NAME,
    RECIPIENT_ROLE,
    ORIGINAL_RECIPIENT,
    STATUS,
    ACCESS_KEY,
    MAIL_STATUS,
    PRIORITY,
    BEGIN_DATE,
    SENT_DATE,
    END_DATE,
    DUE_DATE,
    -- USER_COMMENT,
    CALLBACK,
    CONTEXT
  ) select
    sendsingle.nid,
    nvl(sendsingle.group_id, sendsingle.nid),
    sendsingle.msg_type,
    sendsingle.msg_name,
    sendsingle.role,
    sendsingle.role,
    'OPEN',
    wf_core.random,
    decode(sendsingle.mailpref, 'QUERY', '',
                                'SUMMARY', '',
                                'SUMHTML', '',
                                'DISABLED', 'FAILED',
                                null, '', 'MAIL'),
    nvl(SendSingle.priority, WM.DEFAULT_PRIORITY),
    sysdate,
    sysdate,
    null,
    sendsingle.due_date,
    -- sendsingle.send_comment,
    sendsingle.callback,
    sendsingle.context
  from WF_MESSAGES WM
  where WM.TYPE = sendsingle.msg_type
  and WM.NAME = sendsingle.msg_name;

  -- Open and parse cursor for dynamic sql for getting attr values
  -- Bug 2376033 added event value in call to CB
  if (callback is not null) then
     -- ### Review Note 2
     l_charcheck := wf_notification_util.CheckIllegalChar(callback);
     --Throw the Illegal exception when the check fails


     -- BINDVAR_SCAN_IGNORE
      sqlbuf := 'begin '||callback||
               '(:p1, :p2, :p3, :p4, :p5, :p6, :p7, :p8); end;';

  end if;

  --
  -- Get and insert notification attributes
  --
  for message_attr_row in message_attrs_cursor(msg_type, msg_name) loop

     attr_name := message_attr_row.name;
     attr_type := message_attr_row.type;

     -- Set up default values for attributes
     --Bug 14750553. It has to be set to null regardless, cannot be constant
     --as such thing cannot be done in WF builder
     attr_evalue := null;
     if (message_attr_row.value_type = 'CONSTANT') then
       -- Constant default values used directly
       attr_tvalue := message_attr_row.text_default;
       attr_nvalue := message_attr_row.number_default;
       attr_dvalue := message_attr_row.date_default;
     else
       -- Defaults to be fetched from cb - default to null
       attr_tvalue := '';
       attr_nvalue := '';
       attr_dvalue := '';
       --Bug 14750553
       attr_evalue := null;
     end if;

     -- Bug 2376033 initialize event to fetch value using cb
     if (attr_type = 'EVENT') then
       wf_event_t.initialize(attr_evalue);
     end if;

     -- If there is a cb defined and the default vtype is ITEMATTR
     -- then call the cb to fetch possible item attribute value.
     -- Bug 2376033 execute call to CB with event value
     if ((callback is not null) and
         (message_attr_row.value_type = 'ITEMATTR')) then
       begin
         execute immediate sqlbuf using
           in 'GET',
           in context,
           in message_attr_row.text_default,
           in attr_type,
           in out attr_tvalue,
           in out attr_nvalue,
           in out attr_dvalue,
           in out attr_evalue;

       exception
         when others then
           -- Ignore cases where no attribute is defined
          if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
             wf_core.clear;
          else
             -- Bug 2580807 call with original signature for backward
             -- compatibility
             -- ### Review Note 2 - callback is from table
             l_charcheck := wf_notification_util.CheckIllegalChar(callback);
             --Throw the Illegal exception when the check fails


               -- BINDVAR_SCAN_IGNORE
               sqlbuf := 'begin '||callback||
                       '(:p1, :p2, :p3, :p4, :p5, :p6, :p7); end;';
               begin
                execute immediate sqlbuf using
                  in 'GET',
                  in context,
                  in message_attr_row.text_default,
                  in attr_type,
                  in out attr_tvalue,
                  in out attr_nvalue,
                  in out attr_dvalue;
               exception
                when others then
                  if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
                    wf_core.clear;
                  else
                    raise;
                  end if;
               end;
          end if;
       end;
     end if;

     --
     -- Insert notification attribute
     -- Bug 2376033 insert the event value
     --
     insert into WF_NOTIFICATION_ATTRIBUTES  (
       NOTIFICATION_ID,
       NAME,
       TEXT_VALUE,
       NUMBER_VALUE,
       DATE_VALUE,
       EVENT_VALUE
     ) values (
       nid,
       attr_name,
       attr_tvalue,
       attr_nvalue,
       attr_dvalue,
       attr_evalue
     );
  end loop;

  --ER 29631318: Create next sequence to append to random number
  select WF_NTF_ATTRS_RESPONSE_KEY_S.NEXTVAL
  into l_resp_key_seq
  from SYS.DUAL;

  --ER 29631318: Add new notification attribute #RESPONSE_KEY to store large random number
  WF_NOTIFICATION.AddAttr(nid, '#RESPONSE_KEY');
  WF_NOTIFICATION.SetAttrText(nid, '#RESPONSE_KEY',
              trunc(DBMS_RANDOM.value(1000000000000000000000000000000000000000,
	                         9999999999999999999999999999999999999999)) || l_resp_key_seq );

  l_send_source := '';
  -- Notification sender comment
  if (send_comment is not null) then
    l_send_comment := send_comment;
  else
    -- Look for the sender comment in #SUBMIT_COMMENTS and store it
    -- only for the first time
    if (First_Execution(context)) then
      l_send_source := 'FIRST';
      begin
        l_send_comment := Wf_Notification.GetAttrText(nid, '#SUBMIT_COMMENTS');
      exception
        when others then
          if(Wf_Core.Error_Name = 'WFNTF_ATTR') then
             Wf_Core.Clear();
             l_send_comment := '';
          else
             raise;
          end if;
       end;
    end if;
  end if;

  -- If #FROM_ROLE is defined, we will get the value in this attribute
  begin
    l_from_role := Wf_Notification.GetAttrText(nid, '#FROM_ROLE');
  exception
    when OTHERS then
      wf_core.clear;
      -- Check if the notification is sent under a valid Fwk Session
      l_from_role := Wfa_Sec.GetUser();
  end;

  -- Use dummy user WF_SYSTEM as last resort
  if (l_from_role is null) then
     l_from_role := 'WF_SYSTEM';
  end if;
  Wf_Notification.SetComments(nid, l_from_role, role, 'SEND', l_send_source, l_send_comment);

  -- Check for auto-routing of notification just sent
  Wf_Notification.Route(nid, 0);

  --Bug 10243065. If the RECIPIENT_ROLE changed then the notification was
  -- either delegated or transfered. We need to flag this sutuation
  select RECIPIENT_ROLE
  into l_new_rcpt_role
  from WF_NOTIFICATIONS
  where NOTIFICATION_ID=nid;
  if SendSingle.Role<>l_new_rcpt_role then
    wf_event.AddParameterToList('IS_DUPLICATE','TRUE',l_parameterlist);
  end if;

  -- Denormalize the Notification after auto-routing is done
  Wf_Notification.Denormalize_Notification(nid);

  -- Denormalize custom columns
  -- Derive item type, item key and activity id from the context
  if context is not null then
      col1 := instr(context, ':', 1, 1);
      col2 := instr(context, ':', -1, 1);

      l_itemtype := substr(substr(context, 1, col1-1),1,8);
      l_itemkey  := substr(substr(context, col1+1, col2-col1-1),1,240);
      begin
         l_userkey  := wf_engine.GetItemUserKey(l_itemtype,l_itemkey);
      exception
         when others then
            l_userkey := null;
      end;
  else
      l_itemkey := null;
      l_userkey := null;
  end if;
  wf_notification.denormalize_columns_internal(l_itemkey, l_userkey, nid);


  -- DL: Move this to be the last step before returning the nid
  --     The recipient_role could be updated during auto-routing
  --     EnqueueNotification maybe able to take advantage of
  --     denormalization in the future.
  -- Push the notification to the outbound queue
  -- Enqueuing has been moved to a subscription for forward
  -- compatability. The subscription need only be enabled to use
  -- the older mailer. The subscription will call the
  -- wf_xml.enqueueNotification API.
  -- wf_xml.EnqueueNotification(nid);

  --Bug 2283697
  --To raise an EVENT whenever DML operation is performed on
  --WF_NOTIFICATIONS and WF_NOTIFICATION_ATTRIBUTES table.
  wf_event.AddParameterToList('NOTIFICATION_ID',nid,l_parameterlist);
  wf_event.AddParameterToList('ROLE',role,l_parameterlist);
  wf_event.AddParameterToList('GROUP_ID',nvl(group_id,nid),l_parameterlist);

  wf_event.addParameterToList('Q_CORRELATION_ID', sendsingle.msg_type||':'||
                              sendsingle.msg_name, l_parameterlist);

  Wf_Directory.GetRoleInfo2(sendsingle.role, role_info_tbl);
  l_language := role_info_tbl(1).language;

  select code into l_language from wf_languages where nls_language = l_language;

  -- AppSearch
  wf_event.AddParameterToList('OBJECT_NAME',
  'oracle.apps.fnd.wf.worklist.server.AllNotificationsVO', l_parameterlist);
  wf_event.AddParameterToList('CHANGE_TYPE', 'INSERT',l_parameterlist);
  wf_event.AddParameterToList('ID_TYPE', 'PK', l_parameterlist);
  wf_event.addParameterToList('PK_NAME_1', 'NOTIFICATION_ID',l_parameterlist);
  wf_event.addParameterToList('PK_VALUE_1', nid, l_parameterlist);
  wf_event.addParameterToList('PK_NAME_2', 'LANGUAGE',l_parameterlist);
  wf_event.addParameterToList('PK_VALUE_2', l_language, l_parameterlist);



  --Raise the event
  if wf_event.phase_maxthreshold is null then
    -- means deferred mode , avoid synchronous processing of Send event
    wf_event.SetDispatchMode('ASYNC');

    wf_event.Raise(p_event_name => 'oracle.apps.wf.notification.send',
                 p_event_key  => to_char(nid),
                 p_parameters => l_parameterlist);

    wf_event.phase_maxthreshold := null;
  else
    wf_event.Raise(p_event_name => 'oracle.apps.wf.notification.send',
                 p_event_key  => to_char(nid),
                 p_parameters => l_parameterlist);

  end if;

  --Raise the push approvals event if the item type and message name exists in wf_wl_config_types table
  RaisePushNotificationEvent(role,msg_type,msg_name,nid,false);

  return (nid);

exception
  when others then
    wf_core.context('Wf_Notification', 'SendSingle', role, msg_type,
                    msg_name, due_date, callback);
    raise;
end SendSingle;

--
-- Send
--   Send the role the specified message.
--   Insert a single notification in the notifications table, and set
--   the default send and respond attributes for the notification.
-- IN:
--   role - Role to send notification to
--   msg_type - Message type
--   msg_name - Message name
--   due_date - Date due
--   callback - Callback function
--   context - Data for callback
--   send_comment - Comment to add to notification
--   priority - Notification priority
-- RETURNS:
--   Notification ID
--
function Send(role in varchar2,
              msg_type in varchar2,
              msg_name in varchar2,
              due_date in date,
              callback in varchar2,
              context in varchar2,
              send_comment in varchar2,
              priority in number)
return number is
  dummy pls_integer;
  nid WF_NOTIFICATIONS.NOTIFICATION_ID%TYPE;
  rorig_system varchar2(30);
  rorig_system_id WF_LOCAL_ROLES.ORIG_SYSTEM_ID%TYPE;
  --Bug 4050078
  itemtype        varchar2(8);
  itemkey         varchar2(240);
  actid           number;
  col1            pls_integer;
  col2            pls_integer;
  prev_nid        pls_integer;
  l_proc_name     varchar2(100) := 'wf.plsql.wf_notification.Send';
begin
  if ((role is null) or (msg_type is null) or (msg_name is null)) then
    wf_core.token('ROLE', role);
    wf_core.token('TYPE', msg_type);
    wf_core.token('NAME', msg_name);
    wf_core.raise('WFSQL_ARGS');
  end if;

  -- Check message is valid
  begin
    select 1 into dummy from sys.dual where exists
    (select null
    from WF_MESSAGES M
    where M.TYPE = msg_type
    and M.NAME = msg_name);
  exception
    when no_data_found then
      wf_core.token('TYPE', msg_type);
      wf_core.token('NAME', msg_name);
      wf_core.raise('WFNTF_MESSAGE');
  end;

  Wf_Directory.GetRoleOrigSysInfo(role,rorig_system,rorig_system_id);

  -- if ORIG_SYSTEM is null, there is no data found for this role
  if (rorig_system is null) then
    wf_core.token('ROLE', role);
    wf_core.raise('WFNTF_ROLE');
  end if;

  -- Call SendSingle to complete notification,
  -- using group_id = null to create group of one.
  nid := SendSingle(role, msg_type, msg_name, due_date, callback,
                    context, send_comment, priority, null);

  -- Update action history of notifications in approval chain
  -- Bug 4050078
  begin
     -- Derive item type, item key and activity id from the context
     validate_context(context, itemtype, itemkey, actid);
     -- Bug 7914921. The context not always comes in format itemtype:itemkey:actid
      if (itemtype is not null AND itemkey is not null AND actid is not null) then
        -- bug 8729116. Need to select only one row
        SELECT max(wn.notification_id)
        INTO   prev_nid
        FROM  wf_notifications wn,
            wf_comments wc
        WHERE
           EXISTS ( SELECT  'x' -- 8554209
                 FROM wf_item_activity_statuses_h wiash
                 WHERE  wiash.notification_id= wn.notification_id
                 AND    wiash.item_type = wn.message_type
                 AND    wiash.item_type = itemtype
                 AND    wiash.item_key = itemkey
                 AND    wiash.process_activity = actid)
        AND  wn.status = 'CLOSED'
        AND  wn.notification_id = wc.notification_id
        AND  wc.to_role = 'WF_SYSTEM'
        AND  wc.action_type = 'RESPOND';

        UPDATE wf_comments
        SET to_role = role,
            to_user = nvl(Wf_Directory.GetRoleDisplayname(role), role)
        WHERE notification_id = prev_nid
        AND  to_role = 'WF_SYSTEM'
        AND  action_type = 'RESPOND';
      end if;
  exception
     when OTHERS then
       if (WF_LOG_PKG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
         WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_EXCEPTION, l_proc_name,
                            'Unable to retrieve notification Id :'||sqlerrm);
       end if;
  end;

  return (nid);
exception
  when others then
    wf_core.context('Wf_Notification', 'Send', role, msg_type,
                    msg_name, due_date, callback);
    raise;
end Send;

--
-- SendGroup
--   Send the role users the specified message.
--   Send a separate notification to every user assigned to the role.
-- IN:
--   role - Role of users to send notification to
--   msg_type - Message type
--   msg_name - Message name
--   due_date - Date due
--   callback - Callback function
--   context - Data for callback
--   send_comment - Comment to add to notification
--   priority - Notification priority
-- RETURNS:
--   Group ID - Id of notification group
--
function SendGroup(role in varchar2,
                   msg_type in varchar2,
                   msg_name in varchar2,
                   due_date in date,
                   callback in varchar2,
                   context in varchar2,
                   send_comment in varchar2,
                   priority in number)
return number is
  dummy pls_integer;
  nid WF_NOTIFICATIONS.NOTIFICATION_ID%TYPE;
  gid WF_NOTIFICATIONS.GROUP_ID%TYPE;

  rorig_system varchar2(30);
  rorig_system_id WF_LOCAL_ROLES.ORIG_SYSTEM_ID%TYPE;

  cursor role_users_curs is
    select WUR.USER_NAME
    from WF_USER_ROLES WUR
    where WUR.ROLE_ORIG_SYSTEM = rorig_system
    and WUR.ROLE_ORIG_SYSTEM_ID = rorig_system_id
    and WUR.ROLE_NAME = role;

begin
  if ((role is null) or (msg_type is null) or (msg_name is null)) then
    wf_core.token('ROLE', role);
    wf_core.token('TYPE', msg_type);
    wf_core.token('NAME', msg_name);
    wf_core.raise('WFSQL_ARGS');
  end if;

  -- Check message is valid
  begin
    select 1 into dummy from sys.dual where exists
    (select null
    from WF_MESSAGES M
    where M.TYPE = msg_type
    and M.NAME = msg_name);
  exception
    when no_data_found then
      wf_core.token('TYPE', msg_type);
      wf_core.token('NAME', msg_name);
      wf_core.raise('WFNTF_MESSAGE');
  end;

  -- Get the orig system ids for the role.
  -- Do this instead of using role_name directly so that indexes on
  -- the original tables are used when selecting through the view.
  Wf_Directory.GetRoleOrigSysInfo(role,rorig_system,rorig_system_id);

  -- if ORIG_SYSTEM is null, there is no data found for this role
  if (rorig_system is null) then
    wf_core.token('ROLE', role);
    wf_core.raise('WFNTF_ROLE');
  end if;

  -- Loop through users of role, sending notification to each one.
  gid := '';
  for user in role_users_curs loop
    -- Send Notification to only active users - Bug 7413050
    if Wf_Directory.UserActive(user.user_name) then
      -- Call SendSingle to complete notification,
      nid := SendSingle(user.user_name, msg_type, msg_name, due_date, callback,
                      context, send_comment, priority, gid);

      -- Use nid of the first notification as group id for the rest.
      if (gid is null) then
        gid := nid;
      end if;
    end if;
  end loop;

  -- Raise error if no users found for role.
  -- Most probable cause is role argument is invalid.
  if (gid is null) then
    wf_core.token('ROLE', role);
    wf_core.raise('WFNTF_ROLE');
  end if;

  return (gid);
exception
  when others then
    wf_core.context('Wf_Notification', 'SendGroup', role, msg_type,
                    msg_name, due_date, callback);
    raise;
end SendGroup;

--
-- ForwardInternal (PRIVATE)
--   Forward a notification, identified by NID to another user. Validate
--   the user and Return error messages ...
--   Depend on which mode 'FORWARD' or 'TRANSFER', it calls the call-back
--   function differently.
-- IN:
--   nid - Notification Id
--   new_role - Role to forward notification to
--   fmode - Callback mode: 'FORWARD', 'TRANSFER'
--   forward_comment - comment to append to notification
--   user - role who perform this action if provided
--   cnt - count for recursive purpose
--   action_source - Source from where the action is performed
--
procedure ForwardInternal(
  nid in number,
  new_role in varchar2,
  fmode in varchar2,
  forward_comment in varchar2,
  user in varchar2,
  cnt in number,
  action_source in varchar2)
is
  l_dis_reassign_sub varchar2(1);
  mailpref varchar2(8);
  newcomment varchar2(4000);
  old_role varchar2(320);
  old_origrole varchar2(320);
  status varchar2(8);
  cb varchar2(240);
  context varchar2(2000);
  sqlbuf varchar2(2000);
  tvalue varchar2(4000);
  nvalue number;
  dvalue date;

  --ER 2714169 variables
  l_act_id number;
  l_item_type WF_ITEMS.ITEM_TYPE%TYPE;
  l_item_key WF_ITEMS.ITEM_KEY%TYPE;
  l_wf_owner WF_ITEMS.OWNER_ROLE%TYPE := null;
  l_init_role WF_COMMENTS.FROM_ROLE%TYPE := null;

  -- Bug 2331070
  l_from_role varchar2(320);

  --Bug 2283697
  l_parameterlist        wf_parameter_list_t := wf_parameter_list_t();

  --Bug 2474770
  l_more_info_role       VARCHAR2(320);
  l_dispname     VARCHAR2(360);
  l_username     varchar2(320);
  l_found        boolean;
  l_dummy        varchar2(1);

  l_language    varchar2(30);
  l_recipient_role varchar2(320);
  role_info_tbl wf_directory.wf_local_roles_tbl_type;

  -- Bug 3827935
  l_charcheck   boolean;

  -- <bug 7641725>
  l_msgType varchar2(8);
  l_msgName varchar2(30);

begin
  if ((nid is null) or (new_role is null)) then
    wf_core.token('NID', to_char(nid));
    wf_core.token('NEW_ROLE', new_role);
    wf_core.raise('WFSQL_ARGS');
  end if;

  -- Check the notification exists and is open
  begin
    --Bug 2474770
    --Obtain the more_info_role in addition
    select WN.STATUS, WN.CALLBACK, WN.CONTEXT, -- , WN.USER_COMMENT
           WN.RECIPIENT_ROLE, WN.ORIGINAL_RECIPIENT,WN.MORE_INFO_ROLE,
           WN.FROM_ROLE
           , wn.message_type, wn.message_name -- <7641725>
    into  status, cb, context, old_role,   --  newcomment,
          old_origrole,l_more_info_role,l_from_role
          , l_msgType, l_msgName
    from  WF_NOTIFICATIONS WN
    where WN.NOTIFICATION_ID = nid
    for update nowait;
  exception
    when no_data_found then
      wf_core.token('NID', to_char(nid));
      wf_core.raise('WFNTF_NID');
  end;
  if (status <> 'OPEN') then
    wf_core.token('NID', to_char(nid));
    wf_core.raise('WFNTF_NID_OPEN');
  end if;

  -- If we are in a different Fwk session, need to clear Workflow PLSQL state
  if (not Wfa_Sec.CheckSession) then
    Wf_Global.Init;
  end if;

  -- Check role is valid and get mail preference
  begin
    mailpref := Wf_Notification.GetMailPreference(new_role, cb, context);
  exception
    when others then
      wf_core.token('ROLE', new_role);
      if (fmode = 'FORWARD') then
        wf_core.raise('WFNTF_DELEGATE_FAIL');
      elsif (fmode = 'TRANSFER') then
        wf_core.raise('WFNTF_TRANSFER_FAIL');
      end if;
  end;

  -- Bug 3065814
  -- Set the global context variables to appropriate values for this mode
  if (forward_comment is not null and
        substr(forward_comment, 1, 6) = 'email:') then
     -- If responded through mail then get the username from the email
     GetUserFromEmail(forward_comment, null, l_username, l_dispname, l_found);
     if (l_found) then
        g_context_user := l_username;
     else
        g_context_user := 'email:'||l_username;
     end if;
  else
     if (action_source = 'WA') then
        -- notification is reassigned by a proxy who is logged in and has a Fwk session
        g_context_proxy := Wfa_Sec.GetUser();
        g_context_user := ForwardInternal.user;
     elsif (action_source = 'RULE') then
        -- notification is reassigned by Routing Rule, the context user should be the user
        -- to whom the rule belongs and to whom the notification is reassigned
        g_context_proxy := null;
        g_context_user :=  ForwardInternal.user;
     else
        -- notification is reassigned by the recipient
        g_context_proxy := null;
        g_context_user := Wfa_Sec.GetUser();
     end if;
  end if;

  g_context_user_comment := forwardinternal.forward_comment;
  g_context_recipient_role := old_role;
  g_context_original_recipient:= old_origrole;
  g_context_from_role := l_from_role;
  g_context_new_role  := new_role;
  g_context_more_info_role  := l_more_info_role;

  -- Old style comment appending to existing user comment is obsolete
  -- Call SetComments with the required values. Also, the audit message
  -- is no longer available

  -- CTILLEY: Bug 2331070.
  if (fmode = 'FORWARD') then
     l_from_role := nvl(user,old_role);
  else
     l_from_role := nvl(user,old_origrole);
  end if;

  -- get profile value for WF_DISABLE_REASSIGN_SUBMITTER
  l_dis_reassign_sub := substr(fnd_profile.value('WF_DISABLE_REASSIGN_SUBMITTER'),1,1);

  -- Bug 24294590: Use profile option to control delegation to owner/initiator.
  if (l_dis_reassign_sub = 'Y') then
    -- Should not route a notification to WF process owner or initiator.
    -- Cannot use getNtfActInfo because notification ID has not made it yet
    -- into WIAS. Have to use the context to get item type and key.
    validate_context (context  => ForwardInternal.context,
                      itemtype => l_item_type,
                      itemkey  => l_item_key,
                      actid    => l_act_id);
    -- Bug 21386246: When wf_notificationotification.send called directly there is no workflow
    -- process associated, item type and item key will be null,check that condition here.
    if (l_item_type is not null and l_item_key is not null) then
      select OWNER_ROLE into l_wf_owner
        from WF_ITEMS
        where ITEM_TYPE = l_item_type
          and ITEM_KEY = l_item_key;
    end if;
    if (l_wf_owner is null) then
      select FROM_ROLE into l_init_role from
      (
        select FROM_ROLE
          from WF_ITEM_ACTIVITY_STATUSES IAS,
               WF_COMMENTS C
          where IAS.ITEM_TYPE        = l_item_type
            and IAS.ITEM_KEY         = l_item_key
            and IAS.PROCESS_ACTIVITY = l_act_id
            and IAS.NOTIFICATION_ID  = C.NOTIFICATION_ID
            and C.ACTION             = 'SEND_FIRST'
        union
        select FROM_ROLE
          from WF_ITEM_ACTIVITY_STATUSES_H IASH,
               WF_COMMENTS C
          where IASH.ITEM_TYPE        = l_item_type
            and IASH.ITEM_KEY         = l_item_key
            and IASH.PROCESS_ACTIVITY = l_act_id
            and IASH.NOTIFICATION_ID  = C.NOTIFICATION_ID
            and C.ACTION              = 'SEND_FIRST'
        union
        select FROM_ROLE
          from WF_COMMENTS C
          where C.NOTIFICATION_ID = nid
            and C.ACTION          = 'SEND_FIRST'
      );
    end if;
    if new_role in (l_wf_owner, l_init_role) then
      wf_core.raise('WFNTF_OWNER_TRANSFER_FAIL');
    end if;
  end if;

  -- Call the callback in whatever mode specified if callback is provided
  if (cb is not null) then
    tvalue := new_role;
    nvalue := nid;
    -- ### Review Note 2 - cb is from table
    -- BINDVAR_SCAN_IGNORE
    l_charcheck := wf_notification_util.CheckIllegalChar(cb);
    --Throw the Illegal exception when the check fails

    sqlbuf := 'begin '||cb||
              '(:p1, :p2, :p3, :p4, :p5, :p6, :p7); end;';
    execute immediate sqlbuf using
       in fmode,
       in context,
       in l_dummy,
       in l_dummy,
       in out tvalue,
       in out nvalue,
       in out dvalue;
  end if;

  --Bug 2474770
  --If the transfer/delegate role is the same as the more_info_role
  --the more_info_role is set to null
  --Bug 2609352 - if the notification is reassigned the more_info_role
  --will be set to null.
  if (l_more_info_role is not NULL) then
    l_more_info_role := null;
  end if;

  -- Finally, do the update.
  -- Reset the mail flag so mailer will look for it again.
  -- BUG 1772490 JWSMITH - added new access_key when fmode is transfer

  -- BUG 2331070 CTILLEY - added update to FROM_ROLE
  -- Bug 2474770
  -- Update the more_info_role aswell
  if (fmode = 'TRANSFER') then
      update WF_NOTIFICATIONS set
         RECIPIENT_ROLE = ForwardInternal.new_role,
         ORIGINAL_RECIPIENT = decode(ForwardInternal.fmode,
                                'TRANSFER', ForwardInternal.new_role,
                                ORIGINAL_RECIPIENT),
         -- USER_COMMENT = ForwardInternal.newcomment,
         MAIL_STATUS = decode(ForwardInternal.mailpref,
                         'QUERY', '',
                         'SUMMARY', '',
                         'SUMHTML', '',
                         'DISABLED', 'FAILED',
                         null, '', 'MAIL'),
         ACCESS_KEY = wf_core.random,
         FROM_ROLE = l_from_role,
         MORE_INFO_ROLE = l_more_info_role,
         SENT_DATE = SYSDATE
      where NOTIFICATION_ID = nid;

      Wf_Notification.SetComments(nid, l_from_role, new_role, 'TRANSFER',
                                  action_source, forward_comment);

  else
      update WF_NOTIFICATIONS set
        RECIPIENT_ROLE = ForwardInternal.new_role,
        ORIGINAL_RECIPIENT = decode(ForwardInternal.fmode,
                                'TRANSFER', ForwardInternal.new_role,
                                ORIGINAL_RECIPIENT),
        -- USER_COMMENT = ForwardInternal.newcomment,
        MAIL_STATUS = decode(ForwardInternal.mailpref,
                         'QUERY', '',
                         'SUMMARY', '',
                         'SUMHTML', '',
                         'DISABLED', 'FAILED',
                         null, '', 'MAIL'),
        FROM_ROLE = l_from_role,
        MORE_INFO_ROLE = l_more_info_role,
        SENT_DATE = SYSDATE
      where NOTIFICATION_ID = nid;

      Wf_Notification.SetComments(nid, l_from_role, new_role, 'DELEGATE',
                                  action_source, forward_comment);
  end if;

  -- Pop any messages from then outbound queue

  -- GK: 1636402: wf_xml.RemoveNotification is not necessary
  -- since the message is likely to be sent by the time the
  -- user goes in and does an action from the worklist.
  -- wf_xml.RemoveNotification(nid);

  -- Check for auto-routing of notification just forwarded
  Wf_Notification.Route(nid, cnt);

  -- Denormalize after all the routing is done
  if (cnt = 0) then
    Wf_Notification.Denormalize_Notification(nid);

    -- Push the new notification to the queue
    -- The call to wf_xml.EnqueueNotification has been moved
    -- to an event subscription.
    -- wf_xml.EnqueueNotification(nid);
  end if;

  --Bug 2283697
  --To raise an EVENT whenever DML operation is performed on
  --WF_NOTIFICATIONS and WF_NOTIFICATION_ATTRIBUTES table.
  wf_event.AddParameterToList('NOTIFICATION_ID',nid,l_parameterlist);
  wf_event.AddParameterToList('NEW_ROLE',new_role,l_parameterlist);
  wf_event.AddParameterToList('MODE',fmode,l_parameterlist);
  if (user is not null) then
    wf_event.AddParameterToList('USER',user,l_parameterlist);
  elsif (fmode = 'FORWARD') then
    wf_event.AddParameterToList('USER',old_role,l_parameterlist);
  else
    wf_event.AddParameterToList('USER',old_origrole,l_parameterlist);
  end if;

  -- <7641725> we need to include Q_CORRELATION_ID parameter
  wf_event.addParameterToList('Q_CORRELATION_ID'
                                  , l_msgType||':'||l_msgName, l_parameterlist);

    select WN.RECIPIENT_ROLE
    into  l_recipient_role
    from  WF_NOTIFICATIONS WN
    where WN.NOTIFICATION_ID = nid;

  Wf_Directory.GetRoleInfo2(l_recipient_role, role_info_tbl);
  l_language := role_info_tbl(1).language;

  select code into l_language from wf_languages where nls_language = l_language;

  -- AppSearch
  wf_event.AddParameterToList('OBJECT_NAME',
  'oracle.apps.fnd.wf.worklist.server.AllNotificationsVO', l_parameterlist);
  wf_event.AddParameterToList('CHANGE_TYPE', 'INSERT',l_parameterlist);
  wf_event.AddParameterToList('ID_TYPE', 'PK', l_parameterlist);
  wf_event.addParameterToList('PK_NAME_1', 'NOTIFICATION_ID',l_parameterlist);
  wf_event.addParameterToList('PK_VALUE_1', nid, l_parameterlist);
  wf_event.addParameterToList('PK_NAME_2', 'LANGUAGE',l_parameterlist);
  wf_event.addParameterToList('PK_VALUE_2', l_language, l_parameterlist);

  --Bug 17625187: Avoid synchronous processing of reassign event by setting the deferred mode.
  if wf_event.phase_maxthreshold is null then
    wf_event.SetDispatchMode('ASYNC');
    --Raise the event
    wf_event.Raise(p_event_name => 'oracle.apps.wf.notification.reassign',
                   p_event_key  => to_char(nid),
                   p_parameters => l_parameterlist);
    wf_event.phase_maxthreshold := null;
  else
    --Raise the event
    wf_event.Raise(p_event_name => 'oracle.apps.wf.notification.reassign',
                   p_event_key  => to_char(nid),
                   p_parameters => l_parameterlist);
  end if;
  --Raise the push approvals event if the item type and message name exists in wf_wl_config_types table
  RaisePushNotificationEvent(new_role,l_msgType,l_msgName,nid,false);

exception
  when others then
    wf_core.context('Wf_Notification', 'ForwardInternal', to_char(nid),
        new_role, fmode, forward_comment);
    raise;
end ForwardInternal;

--
-- Forward
--   Forward a notification, identified by NID to another user. Validate
--   the user and Return error messages ...
-- IN:
--   nid - Notification Id
--   new_role - Role to forward notification to
--   forward_comment - comment to append to notification
--   user - role who perform this action if provided
--   cnt - count for recursive purpose
--   action_source - Source from where the action is performed
--
procedure Forward(nid in number,
                  new_role in varchar2,
                  forward_comment in varchar2,
                  user in varchar2,
                  cnt in number,
                  action_source in varchar2)
is
begin
  ForwardInternal(nid, new_role, 'FORWARD', forward_comment, user, cnt, action_source);
exception
  when others then
    wf_core.context('Wf_Notification', 'Forward', to_char(nid),
        new_role, forward_comment);
    -- This call is for enhanced error handling with respect to OAFwk
    wf_notification.SetUIErrorMessage;
    raise;
end Forward;

--
-- Transfer
--   Transfer a notification, identified by NID to another user. Validate
--   the user and Return error messages ...
-- IN:
--   nid - Notification Id
--   new_role - Role to transfer notification to
--   forward_comment - comment to append to notification
--   user - role who perform this action if provided
--   cnt - count for recursive purpose
--   action_source - Source from where the action is performed
--
procedure Transfer(nid in number,
                  new_role in varchar2,
                  forward_comment in varchar2,
                  user in varchar2,
                  cnt in number,
                  action_source in varchar2)
is
begin
  ForwardInternal(nid, new_role, 'TRANSFER', forward_comment, user, cnt, action_source);
exception
  when others then
    wf_core.context('Wf_Notification', 'Transfer', to_char(nid),
        new_role, forward_comment);
    -- This call is for enhanced error handling with respect to OAFwk
    wf_notification.SetUIErrorMessage;
    raise;
end Transfer;

--
-- CancelSingle (PRIVATE)
--   Cancel a single notification.
--   Called by Cancel and CancelGroup public functions.
--   Argument error checking should be done by Cancel and CancelGroup before
--   calling this function.
-- IN:
--   nid - Notification Id
--   role - Role notification is sent to
--   cancel_comment - Comment to append to notification
--
procedure CancelSingle(nid in number,
                       role in varchar2,
                       cancel_comment in varchar2,
                       timeout in boolean)
is
  mailpref varchar2(8);
  newcomment varchar2(4000);
  status varchar2(8);
  cb varchar2(240);
  context varchar2(2000);
  dummy pls_integer;

 --Bug 2283697
 l_parameterlist        wf_parameter_list_t := wf_parameter_list_t();

 --Bug 2373925
 l_mail varchar2(4);
 l_from_role varchar2(320);
 l_action  varchar2(30);
 l_send_cancel varchar2(10);
 l_msg_type    varchar2(8);
 l_msg_name    varchar2(30);
 l_language    varchar2(30);
begin

  -- Check the notification exists and is open
  begin
    select WN.STATUS, WN.CALLBACK, WN.CONTEXT, WN.MESSAGE_TYPE, WN.MESSAGE_NAME, WN.LANGUAGE
    into status, cb, context, l_msg_type, l_msg_name, l_language
    from WF_NOTIFICATIONS WN
    where WN.NOTIFICATION_ID = nid
    for update nowait;
  exception
    when no_data_found then
      wf_core.token('NID', to_char(nid));
      wf_core.raise('WFNTF_NID');
  end;
  if (status <> 'OPEN') then
    wf_core.token('NID', to_char(nid));
    wf_core.raise('WFNTF_NID_OPEN');
  end if;

  -- Check role is valid and get mail preference
  mailpref := Wf_Notification.GetMailPreference(role, cb, context);

  -- If no responses expected, then do not mail cancel notice
  -- regardless of role notification_preference setting.
  begin
    select 1 into dummy from sys.dual where exists
    (select NULL
    from WF_NOTIFICATIONS WN, WF_MESSAGE_ATTRIBUTES WMA
    where WN.NOTIFICATION_ID = nid
    and WN.MESSAGE_NAME = WMA.MESSAGE_NAME
    and WN.MESSAGE_TYPE = WMA.MESSAGE_TYPE
    and WMA.SUBTYPE = 'RESPOND');

  exception
    when no_data_found then
      -- No responses, set mailpref to not mail cancel notice regardless.
      mailpref := 'QUERY';
  end;

  -- if mailer config parameter SEND_CANCELED_EMAIL is set to N, no e-mails
  -- are sent for canceled notifications
  l_send_cancel := wf_mailer_parameter.GetValueForCorr(pCorrId => l_msg_type || ':'|| l_msg_name,
                                                       pName   => 'SEND_CANCELED_EMAIL');
  if (l_send_cancel = 'Y') then
    l_mail := 'MAIL';
  else
    l_mail := '';
  end if;

  update WF_NOTIFICATIONS set
    STATUS = 'CANCELED',
    END_DATE = sysdate,
    -- USER_COMMENT = CancelSingle.newcomment,
    MAIL_STATUS = decode(MAIL_STATUS,
                         'ERROR', 'ERROR',
               -- if this was never sent, dont bother sending cancelation
                         'MAIL',  '',
                         decode(CancelSingle.mailpref,
                               'QUERY', '',
                               'SUMMARY', '',
                               'SUMHTML', '',
                               'DISABLED', 'FAILED',
                               null, '', l_mail))
  where NOTIFICATION_ID = nid;

  if (timeout) then
    l_action := 'TIMEOUT';
    l_from_role := role;
  else
    l_action := 'CANCEL';
    l_from_role := Wfa_Sec.GetUser();
  end if;

  if (l_from_role is null) then
     l_from_role := 'WF_SYSTEM';
  end if;
  Wf_Notification.SetComments(nid, l_from_role, 'WF_SYSTEM', l_action, null, newcomment);

  -- GK: 1636402: wf_xml.RemoveNotification is not necessary
  -- since the message is likely to be sent by the time the
  -- user goes in and does an action from the worklist.
  -- wf_xml.RemoveNotification(nid);
  -- SJM: 2122556 - Cancelled notifications are not being sent out
  -- becuase they are not being enqueued.
  -- The call to wf_xml.EnqueueNotification has been moved to an
  -- event subscription
  -- wf_xml.EnqueueNotification(nid);

  --Bug 2283697
  --To raise an EVENT whenever DML operation is performed on
  --WF_NOTIFICATIONS and WF_NOTIFICATION_ATTRIBUTES table.
  wf_event.AddParameterToList('NOTIFICATION_ID',nid,l_parameterlist);
  wf_event.AddParameterToList('ROLE',role,l_parameterlist);
  wf_event.addParameterToList('Q_CORRELATION_ID', l_msg_type || ':'||
                              l_msg_name, l_parameterlist);


   -- AppSearch
  wf_event.AddParameterToList('OBJECT_NAME',
  'oracle.apps.fnd.wf.worklist.server.AllNotificationsVO', l_parameterlist);
  wf_event.AddParameterToList('CHANGE_TYPE', 'INSERT',l_parameterlist);
  wf_event.AddParameterToList('ID_TYPE', 'PK', l_parameterlist);
  wf_event.addParameterToList('PK_NAME_1', 'NOTIFICATION_ID',l_parameterlist);
  wf_event.addParameterToList('PK_VALUE_1', nid, l_parameterlist);
  wf_event.addParameterToList('PK_NAME_2', 'LANGUAGE',l_parameterlist);
  wf_event.addParameterToList('PK_VALUE_2', l_language, l_parameterlist);

  --Raise the event
  wf_event.Raise(p_event_name => 'oracle.apps.wf.notification.cancel',
                 p_event_key  => to_char(nid),
                 p_parameters => l_parameterlist);


exception
  when others then
    wf_core.context('Wf_Notification', 'CancelSingle', to_char(nid),
                    role, cancel_comment);
    raise;
end CancelSingle;

--
-- Cancel
--   Cancel a single notification.
-- IN:
--   nid - Notification Id
--   cancel_comment - Comment to append to notification
--
procedure Cancel(nid in number,
                 cancel_comment in varchar2)
is
  status varchar2(8);
  role varchar2(320);
begin
  if (nid is null) then
    wf_core.token('NID', to_char(nid));
    wf_core.raise('WFSQL_ARGS');
  end if;

  -- Check the notification exists and is open
  begin
    select STATUS, RECIPIENT_ROLE
    into status, role
    from WF_NOTIFICATIONS
    where NOTIFICATION_ID = nid
    for update nowait;
  exception
    when no_data_found then
      wf_core.token('NID', to_char(nid));
      wf_core.raise('WFNTF_NID');
  end;

  if (status <> 'OPEN') then
    wf_core.token('NID', to_char(nid));
    wf_core.raise('WFNTF_NID_OPEN');
  end if;

  -- Call CancelSingle to complete cancellation of single notification
  CancelSingle(nid, role, cancel_comment, FALSE);

exception
  when others then
    wf_core.context('Wf_Notification', 'Cancel', to_char(nid), cancel_comment);
    raise;
end Cancel;

--
-- CancelGroup
--   Cancel all notifications belonging to a notification group
-- IN:
--   gid - Notification group id
--   cancel_comment - Comment to append to all notifications
--
procedure CancelGroup(gid in number,
                      cancel_comment in varchar2,
                      timeout in boolean)
is
  -- Get all still open notifications in the group
  cursor group_curs is
    select NOTIFICATION_ID, RECIPIENT_ROLE
    from WF_NOTIFICATIONS
    where GROUP_ID = gid
    and status = 'OPEN'
    for update nowait;

begin
  if (gid is null) then
    wf_core.token('NID', to_char(gid));
    wf_core.raise('WFSQL_ARGS');
  end if;

  -- Cancel all open notifications in this group
  for notice in group_curs loop
    -- Call CancelSingle to complete cancellation of single notification
    CancelSingle(notice.notification_id, notice.recipient_role,
                 cancel_comment, timeout);
  end loop;
exception
  when others then
    wf_core.context('Wf_Notification', 'CancelGroup', to_char(gid),
                    cancel_comment);
    raise;
end CancelGroup;

--
-- Respond
--   Respond to a notification.
--   ER 10177347: Moved its code to Respond2 and Complete APIs
-- IN:
--   nid - Notification Id
--   respond_comment - Comment to append to notification
--   responder - User or role responding to notification
--   action_source - Source from where the action is performed
--
procedure Respond(nid in number,
                  respond_comment in varchar2,
                  responder in varchar2,
                  action_source in varchar2)
is

  response_found boolean;
  l_status varchar2(10);

begin
  wf_notification.respond2(nid, respond_comment, responder, action_source, response_found);

  if (response_found) then
     wf_notification.complete(nid);
  end if;

exception
  when others then
    wf_core.context('Wf_Notification', 'Respond', to_char(nid),
                    respond_comment, responder);
    wf_core.clear;
    -- This call is for enhanced error handling with respect to OAFwk
    wf_notification.SetUIErrorMessage;
    raise;
end Respond;

--
-- TestContext
--   Test if current context is correct
-- IN
--   nid - Notification id
-- RETURNS
--   TRUE if context ok, or context check not implemented
--   FALSE if context check fails
--
function TestContext(
  nid in number)
return boolean
is
  callback varchar2(240);
  context varchar2(2000);

  -- Dynamic sql stuff
  sqlbuf varchar2(2000);
  tvalue varchar2(4000);
  nvalue number;
  dvalue date;
  l_dummy  varchar2(1);

  l_charcheck  boolean;
begin
  if (nid is null) then
    wf_core.token('NID', to_char(nid));
    wf_core.raise('WFSQL_ARGS');
  end if;

  -- Get callback, check for valid notification id.
  begin
    select N.CALLBACK, N.CONTEXT
    into   TestContext.callback, TestContext.context
    from   WF_NOTIFICATIONS N
    where  N.NOTIFICATION_ID = nid;
  exception
    when no_data_found then
      wf_core.token('NID', to_char(nid));
      wf_core.raise('WFNTF_NID');
  end;

  -- If no callback, then nothing to check
  if (callback is null) then
    return(TRUE);
  end if;

  -- Open dynamic sql cursor for callback call
  -- ### Review Note 2 - callback is from table
  -- Check for bug#3827935
  l_charcheck := wf_notification_util.CheckIllegalChar(callback);
  --Throw the Illegal exception when the check fails


    -- BINDVAR_SCAN_IGNORE
    sqlbuf := 'begin '||callback||
                   '(:p1, :p2, :p3, :p4, :p5, :p6, :p7); end;';
    execute immediate sqlbuf using
     in 'TESTCTX',
     in context,
     in l_dummy,
     in l_dummy,
     in out tvalue,
     in out nvalue,
     in out dvalue;

    if (tvalue in ('FALSE', 'NOTSET')) then
     return(FALSE);
    else
     -- Any other returned value means TEST_CTX mode is not implemented
     return(TRUE);
    end if;

exception
  when others then
    wf_core.context('Wf_Notification', 'TestContext', to_char(nid));
    raise;
end TestContext;

--
-- VoteCout
--      Count the number of responses for a result_code
-- IN:
--      Gid -  Notification group id
--      ResultCode - Result code to be tallied
-- OUT:
--      ResultCount - Number of responses for ResultCode
--      PercentOfTotalPop - % ResultCode ( As a % of total population )
--      PercentOfVotes - % ResultCode ( As a % of votes cast )
--
procedure VoteCount (   Gid                     in  number,
                        ResultCode              in  varchar2,
                        ResultCount             out nocopy number,
                        PercentOfTotalPop       out nocopy number,
                        PercentOfVotes          out nocopy number ) is
--
--
        l_code_count    pls_integer;
        l_total_pop     pls_integer;
        l_total_voted   pls_integer;
begin
        --
        --
        select  count(*)
        into    l_total_pop
        from    wf_notifications
        where   group_id        = Gid;
        --
        select  count(*)
        into    l_total_voted
        from    wf_notifications
        where   group_id        = Gid
        and     status          = 'CLOSED';
        --
        select  count(*)
        into    l_code_count
        from    wf_notifications wfn,
                wf_notification_attributes wfna
        where   wfn.group_id            = Gid
        and     wfn.notification_id     = wfna.notification_id
        and     wfn.status              = 'CLOSED'
        and     wfna.name               = 'RESULT'
        and     wfna.text_value         = ResultCode;
        --

        ResultCount := l_code_count;
        --
        -- Prevent division by zero if group has no notifications
        --
        if ( l_total_pop = 0 ) then
                --
                PercentOfTotalPop := 0;
                --
        else
                --
                PercentOfTotalPop := l_code_count/l_total_pop*100;
                --
        end if;
        --
        -- Prevent division by zero if nobody votes
        --
        if ( l_total_voted = 0 ) then
                --
                PercentOfVotes := 0;
                --
        else
                --
                PercentOfVotes := l_code_count/l_total_voted*100;
                --
        end if;
        --
exception
        when others then
                --
                wf_core.context('Wf_Notification', 'VoteCount', to_char(gid), ResultCode );
                raise;
                --
end VoteCount;
--
-- OpenNotifications
--      Determine if any Notifications in the Group are OPEN
--
--IN:
--      Gid -  Notification group id
--
--Returns:
--      TRUE  - if the Group contains open notifications
--      FALSE - if the group does NOT contain open notifications
--
function OpenNotificationsExist( Gid    in Number ) return Boolean is
--
dummy pls_integer;
--
begin
        --
        select  1
        into    dummy
        from    sys.dual
        where   exists  ( select null
                          from   wf_notifications
                          where  group_id = Gid
                          and    status   = 'OPEN'
                        );
        --
        return(TRUE);
        --
exception
        when NO_DATA_FOUND then
                --
                return(FALSE);
                --
        when others then
                --
                wf_core.context('Wf_Notification', 'OpenNotifications', to_char(gid) );
                raise;
                --
end OpenNotificationsExist;

--
-- WorkCount
--   Count number of open notifications for user
-- IN:
--   username - user to check
-- RETURNS:
--   Number of open notifications for that user
--
function WorkCount(
  username in varchar2)
return number
is
  ncount pls_integer;
  l_orig_system varchar2(320);
  l_orig_system_id number;
begin
   wf_directory.GetRoleOrigSysInfo(WorkCount.username, l_orig_system,
                                   l_orig_system_id);

      select count(1)
        into ncount
      from WF_NOTIFICATIONS WN,
        (select distinct(WUR.ROLE_NAME)
           from WF_USER_ROLES WUR
           where WUR.USER_NAME = WorkCount.username
           and WUR.USER_ORIG_SYSTEM = l_orig_system
           and WUR.USER_ORIG_SYSTEM_ID = l_orig_system_id
          ) wur
      where ( (WN.MORE_INFO_ROLE is null
           and WN.RECIPIENT_ROLE = WUR.ROLE_NAME)
           or (WN.MORE_INFO_ROLE = WUR.ROLE_NAME) )
           and WN.STATUS = 'OPEN';

  return(ncount);
exception
  when others then
    wf_core.context('Wf_Notification', 'WorkCount', username);
    raise;
end WorkCount;

--
-- Close
--   Close a notification.
-- IN:
--   nid - Notification Id
--   resp - Respond Required?  0 - No, 1 - Yes
--   responder - User or role close this notification
--
procedure Close(nid in number,
                responder in varchar2)
is
  status varchar2(8);

  -- Any existence of response attribute constitutes a response required.
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
    and MA.SUBTYPE = 'RESPOND';

  result attrs%rowtype;

  --Bug 2283697
  l_parameterlist        wf_parameter_list_t := wf_parameter_list_t();

  l_language        varchar2(30);

begin

  if (nid is null) then
    wf_core.token('NID', to_char(nid));
    wf_core.raise('WFSQL_ARGS');
  end if;

  -- Get Status
  begin

    select N.STATUS, N.LANGUAGE
    into   close.status, l_language
    from   WF_NOTIFICATIONS N
    where  N.NOTIFICATION_ID = nid
    for update nowait;
  exception
    when no_data_found then
      wf_core.token('NID', Wf_Notification.GetSubject(nid));
      wf_core.raise('WFNTF_NID');
  end;

  -- Check notification is open
  if (status <> 'OPEN') then
    wf_core.token('NID', Wf_Notification.GetSubject(nid) );
    wf_core.raise('WFNTF_NID_OPEN');
  end if;


  open attrs(nid);
  fetch attrs into result;
  if (attrs%found) then
  -- Check response required?
    wf_core.token('NID', Wf_Notification.GetSubject(nid));
    wf_core.raise('WFNTF_NID_REQUIRE');
  end if;

  -- Mark notification STATUS as 'CLOSED' and MAIL_STATUS as NULL
  update WF_NOTIFICATIONS
  set STATUS = 'CLOSED',
      MAIL_STATUS = NULL,
      END_DATE = sysdate,
      RESPONDER = close.responder
  where NOTIFICATION_ID = nid;


  -- Remove any messages from the outbound queue
  -- GK: 1636402: wf_xml.RemoveNotification is not necessary
  -- since the message is likely to be sent by the time the
  -- user goes in and does an action from the worklist.
  -- wf_xml.RemoveNotification(nid);

  --Bug 2283697
  --To raise an EVENT whenever DML operation is performed on
  --WF_NOTIFICATIONS and WF_NOTIFICATION_ATTRIBUTES table.
  wf_event.AddParameterToList('NOTIFICATION_ID',nid,l_parameterlist);
  wf_event.AddParameterToList('RESPONDER',close.responder,l_parameterlist);

  -- AppSearch
  wf_event.AddParameterToList('OBJECT_NAME',
  'oracle.apps.fnd.wf.worklist.server.AllNotificationsVO', l_parameterlist);
  wf_event.AddParameterToList('CHANGE_TYPE', 'INSERT',l_parameterlist);
  wf_event.AddParameterToList('ID_TYPE', 'PK', l_parameterlist);
  wf_event.addParameterToList('PK_NAME_1', 'NOTIFICATION_ID',l_parameterlist);
  wf_event.addParameterToList('PK_VALUE_1', nid, l_parameterlist);
  wf_event.addParameterToList('PK_NAME_2', 'LANGUAGE',l_parameterlist);
  wf_event.addParameterToList('PK_VALUE_2', l_language, l_parameterlist);

  --Raise the event
  wf_event.Raise(p_event_name => 'oracle.apps.wf.notification.close',
                 p_event_key  => to_char(nid),
                 p_parameters => l_parameterlist);

exception
  when others then
    wf_core.context('Wf_Notification', 'Close', to_char(nid), responder);
    raise;
end Close;

--
-- GetSubSubjectDisplay
--   Get the design subject of a notification and Substitute tokens in text
--   with the display name of the attributes in the subject.
--   This is used in routing rule poplists
-- IN:
--   message_type - Item type of the message
--   message_name - Name of the message to substitute
--
function GetSubSubjectDisplay(message_type IN VARCHAR2, message_name IN VARCHAR2)
return varchar2 is

  local_text varchar2(2000);

  -- Select attr values, formatting numbers and dates as requested.
  -- The order-by is to handle cases where one attr name is a substring
  -- of another.
  cursor message_attrs_cursor(c_message_type VARCHAR2,
                              c_message_name VARCHAR2) is
    select WMA.NAME, WMA.DISPLAY_NAME, WMA.TYPE
    from WF_MESSAGE_ATTRIBUTES_VL WMA
    where WMA.MESSAGE_TYPE = c_message_type
    and WMA.MESSAGE_NAME = c_message_name
    order by length(WMA.NAME) desc;

begin

  -- Get the message subject
  SELECT SUBJECT
  INTO   local_text
  FROM   wf_messages_vl
  WHERE  type = message_type
  AND    name = message_name;

  for msg_attr_row in message_attrs_cursor (message_type, message_name) loop

    --
    -- Substitute all occurrences of SEND tokens with values.
    -- Limit to 1950 chars to avoid value errors if substitution pushes
    -- it over the edge.
    -- Wanted to use '<' and '>' to denote substituted attribute but these
    -- characters are the tag markers in html and cause problems in the
    -- poplist
    --
    if (msg_attr_row.type = 'URL') then

      local_text := substrb(replace(local_text, '-&'||msg_attr_row.name||'-',
                            '['||msg_attr_row.display_name||']'), 1, 1950);
    else

      local_text := substrb(replace(local_text, '&'||msg_attr_row.name,
                            '[<I><B>'||msg_attr_row.display_name||'</B></I>]'), 1, 1950);

    end if;

  end loop;

  --
  -- Process special '#' internal tokens.  Supported tokens are:
  --  &#NID - Notification id
  --
  local_text := substrb(replace(local_text, '&'||'#NID',
                          '[<I><B>'||wf_core.translate('WF_NOTIFICATION_ID')||'</B></I>]'), 1, 1950);


  return(local_text);

exception
  when others then
    return(local_text);
end GetSubSubjectDisplay;

--
-- GetSubSubjectDisplayShort
--   Get the design subject of a notification and Substitute tokens in text
--   with ellipsis '...' in the subject.
--   This is used in routing rule poplists for the new web screens
-- IN:
--   message_type - Item type of the message
--   message_name - Name of the message to substitute
--
function GetSubSubjectDisplayShort(message_type IN VARCHAR2, message_name IN VARCHAR2)
return varchar2 is

  local_text varchar2(2000);

  -- Select attr values, formatting numbers and dates as requested.
  -- The order-by is to handle cases where one attr name is a substring
  -- of another.
  cursor message_attrs_cursor(c_message_type VARCHAR2,
                              c_message_name VARCHAR2) is
    select WMA.NAME, WMA.DISPLAY_NAME, WMA.TYPE
    from WF_MESSAGE_ATTRIBUTES_VL WMA
    where WMA.MESSAGE_TYPE = c_message_type
    and WMA.MESSAGE_NAME = c_message_name
    order by length(WMA.NAME) desc;

begin

  -- Get the message subject
  SELECT SUBJECT
  INTO   local_text
  FROM   wf_messages_vl
  WHERE  type = message_type
  AND    name = message_name;

  for msg_attr_row in message_attrs_cursor (message_type, message_name) loop

    --
    -- Substitute all occurrences of SEND tokens with values.
    -- Limit to 1950 chars to avoid value errors if substitution pushes
    -- it over the edge.
    -- Wanted to use '<' and '>' to denote substituted attribute but these
    -- characters are the tag markers in html and cause problems in the
    -- poplist
    --
    if (msg_attr_row.type = 'URL') then

      local_text := substrb(replace(local_text, '-&'||msg_attr_row.name||'-',
                            '['||msg_attr_row.display_name||']'), 1, 1950);
    else

      local_text := substrb(replace(local_text, '&'||msg_attr_row.name,
                            '...'), 1, 1950);

    end if;

  end loop;

  --
  -- Process special '#' internal tokens.  Supported tokens are:
  --  &#NID - Notification id
  --
  local_text := substrb(replace(local_text, '&'||'#NID',
                          '...'), 1, 1950);


  return(local_text);

exception
  when others then
    return(local_text);
end GetSubSubjectDisplayShort;

-- PLSQL-Clob Procssing
-----------------------------------------------------------
--Name : WriteToClob (PUBLIC)
--Desc : appends a string to the end of a clob.
--note : the efficiency of clob manipulation makes is dubious.
--       It is probably best to call this as infrequently as possible
--       by concatenating the string as long as possible before hand.

procedure WriteToClob  ( clob_loc      in out nocopy clob,
                         msg_string    in  varchar2) is
 pos integer;
 amt number;
begin

   pos :=   dbms_lob.getlength(clob_loc) +1;
   amt := length(msg_string);
   dbms_lob.write(clob_loc,amt,pos,msg_string);

exception
when others then
    wf_core.context('WF_NOTIFICATION','WriteToClob');
    raise;
end WriteToClob;

--Name : GetFullBody (PUBLIC)
--Desc : Gets full body of message with all PLSQLCLOB variables transalted.
--       and returns the message in 32K chunks in the msgbody out variable.
--       Call this repeatedly until end_of_body is true.
--       Call syntax is
--while not (end_of_msgbody) loop
--   wf_notification.getfullbody(nid,msgbody,end_of_msgbody);
--end loop;
procedure GetFullBody (nid in number,
                       msgbody  out nocopy varchar2,
                       end_of_body in out nocopy boolean,
                       disptype in varchar2) is

 buffer varchar2(200);
 buff_length number;


 msg varchar2(30);
 pos number;
 amt number;
 msg_body varchar2(3000);

 strt number;
 ampersand number;
 attr_name varchar2(30);
begin

-- if this is the same nid as was just used in this session,
-- and the message is stored as a clob (so clob_exists is not null) then
-- retrieve message from the temp clob.

  if  nid = wf_notification.last_nid
  and disptype = wf_notification.last_disptype
  and wf_notification.clob_exists is not null then
     wf_notification.read_Clob(msgbody, end_of_body);
     if end_of_body then
        wf_notification.last_nid := 0; --resetting to an inexistent value
     end if;
     return;
  end if;

  wf_notification.clob_exists :=null;
  wf_notification.last_nid:=nid;
  wf_notification.last_disptype:=disptype;
  plsql_clob_exists:=null;

  msgbody := wf_notification.getbody(nid,disptype);

  if msgbody is null
  or instr(msgbody,'&') = 0
  or plsql_clob_exists is null then

   end_of_body := TRUE;

  else

   strt:=1;

   wf_notification.newclob(wf_notification.temp_clob,null);
   wf_notification.clob_exists :=1;

   loop

      attr_name := null;
      ampersand := instr(msgbody,'&',strt);


      if ampersand = 0 then
         if strt <= length(msgbody) then

            wf_notification.WriteToClob(wf_notification.temp_clob,
                                       substr(msgbody,strt,length(msgbody)));
         end if;
         exit;
      end if;

      -- If the token starts at the first character of the message body, we
      -- would encounter an error in our logic.  1 - 1 is 0 so the call to
      -- substr would fail.

      if ((ampersand - strt) > 0) then
         wf_notification.writeToClob(wf_notification.temp_clob,
                                         substr(msgbody,strt,ampersand-strt));

      end if;

      -- 2691290 if the '&' is at the end of the body the notification
      -- will error when calling GetAttrClob API for "Invalid values for
      -- Arguments".
      if (substr(msgbody,ampersand+1,30) is not null) then
        wf_notification.getattrclob(nid,substr(msgbody,ampersand+1,30),disptype,
                    wf_notification.temp_clob , attr_name);
      end if;


      if attr_name is not null then
         --it was already written to clob.
         strt := ampersand + 1 + length(attr_name);
      else
         --the string was not a plsqlclob
         wf_notification.writeToClob(wf_notification.temp_clob,'&');
         strt := ampersand + 1;
      end if;

   end loop;


   --set the clob chunk to zero. then request the next chunk in the msgbody
   wf_notification.clob_chunk := 0;
   wf_notification.read_Clob(msgbody, end_of_body);
   if end_of_body then
      wf_notification.last_nid := 0; --resetting to an inexistent value
   end if;
  end if;

exception
   when others then
      wf_core.context('WF_NOTIFICATION','GetFullBody', 'nid => '||to_char(nid),
                      'disptype => '||disptype);
      raise;
end GetFullBody;


--Name: GetFullBodyWrapper (PUBLIC)
--Desc : Gets full body of message with all PLSQLCLOB variables transalted.
--       and returns the message in 32K chunks in the msgbody out variable.
--       Call this repeatedly until end_of_body is "Y". Uses string arg
--       instead of boolean like GetFullBody for end_of_msg_body
--       Call syntax is
--while (end_of_msgbody <> 'Y') loop
--   wf_notification.getfullbody(nid,msgbody,end_of_msgbody);
--end loop;
procedure GetFullBodyWrapper (nid in number,
                              msgbody  out nocopy varchar2,
                              end_of_body out nocopy varchar2,
                              disptype in varchar2)
is
  end_of_body_b boolean;
begin
  end_of_body_b := FALSE;
  WF_Notification.GetFullBody(nid, msgbody, end_of_body_b, disptype);
  if (end_of_body_b = TRUE) then
    end_of_body := 'Y';
  else
    end_of_body := 'N';
  end if;
end GetFullBodyWrapper;

--
-- GetAttrClob
--   Get the displayed value of a PLSQLCLOB DOCUMENT-type attribute.
--   Returns referenced document in format requested.
--   Use GetAttrText to get retrieve the actual attr value (i.e. the
--   document key string instead of the actual document).
-- NOTE:
--   a. Only PLSQL document type is implemented.
--   b. This will be called by old mailers. This is a wrapper to the
--      new implementation which returns the doctype also.
-- IN:
--   nid      - Notification id
--   astring  - the string to substitute on (ex: '&ATTR1 is your order..')
--   disptype - Requested display type.  Valid values:
--               wf_notification.doc_text - 'text/plain'
--               wf_notification.doc_html - 'text/html'
--   document - The clob into which
--   aname    - Attribute Name (the first part of the string that matches
--              the attr list)
--
procedure GetAttrClob(
  nid       in number,
  astring   in varchar2,
  disptype  in varchar2,
  document  in out nocopy clob,
  aname     out nocopy varchar2)
is
  doctype varchar2(500);
begin

  Wf_Notification.GetAttrClob(nid, astring, disptype, document, doctype, aname);

exception
  when others then
    wf_core.context('Wf_Notification', 'oldGetAttrClob', to_char(nid), aname,
        disptype);
    raise;
end GetAttrClob;

--
-- GetAttrClob
--   Get the displayed value of a PLSQLCLOB DOCUMENT-type attribute.
--   Returns referenced document in format requested.
--   Use GetAttrText to get retrieve the actual attr value (i.e. the
--   document key string instead of the actual document).
-- NOTE:
--   Only PLSQL document type is implemented.
-- IN:
--   nid      - Notification id
--   astring  - the string to substitute on (ex: '&ATTR1 is your order..')
--   disptype - Requested display type.  Valid values:
--               wf_notification.doc_text - 'text/plain'
--               wf_notification.doc_html - 'text/html'
--   document - Th clob into which
--   aname    - Attribute Name (the string that matches
--              the attr list)
--
procedure GetAttrClob(
  nid       in  number,
  astring   in  varchar2,
  disptype  in  varchar2,
  document  in  out nocopy clob,
  doctype   out nocopy varchar2,
  aname     out nocopy varchar2)
is
  key varchar2(4000);
  colon pls_integer;
  slash pls_integer;
  dmstype varchar2(30);
  display_name varchar2(80);
  procname varchar2(240);
  launch_url varchar2(4000);
  procarg varchar2(32000);
  username  varchar2(320);

  --curs integer;
  sqlbuf varchar2(2000);
  --rows integer;

  target   varchar2(240);
  l_charcheck   boolean;

begin

  -- Check args
  if ((nid is null) or (astring is null) or
     (disptype not in (wf_notification.doc_text,
                       wf_notification.doc_html))) then
    wf_core.token('NID', to_char(nid));
    wf_core.token('ASTRING', aname);
    wf_core.token('DISPTYPE', disptype);
    wf_core.raise('WFSQL_ARGS');
  end if;

  -- of all the possible Document type matches,
  -- make sure its a PLSQLCLOB
    dmstype := '';

  -- Bug 6324545: Replaced the cursor with a simple sql to fetch a single row.
  begin
    -- <7443088> improved query
    select NAME into aname from
      (select WMA.NAME
       from WF_NOTIFICATIONS WN,
            WF_MESSAGE_ATTRIBUTES WMA,
            WF_NOTIFICATION_ATTRIBUTES NA
       where WN.NOTIFICATION_ID = nid
       and wn.notification_id = na.notification_id
       and wma.name = na.name
       and WN.MESSAGE_TYPE = WMA.MESSAGE_TYPE
       and WN.MESSAGE_NAME = WMA.MESSAGE_NAME
       and WMA.TYPE = 'DOCUMENT'
       and instr( upper(astring) ,wma.name) = 1
       and upper(na.text_value) like 'PLSQLCLOB:%'
       order by length(wma.name) desc)
       where rownum=1;
  exception
   when no_data_found then
      aname:=null;
     return;
  end;

   if (aname is not null) then
     -- Retrieve key string
     key := wf_notification.GetAttrText(nid, aname);

     -- If the key is empty then return a null string
     if (key is not null) then

       -- Parse doc mgmt system type from key
       colon := instr(key, ':');
       if ((colon <> 0) and (colon < 30)) then
          dmstype := upper(substr(key, 1, colon-1));
       end if;
     end if;
   end if;

  -- if we didnt find any plsqlclobs then exit now
  if dmstype is null or (dmstype <> 'PLSQLCLOB') then
     aname:=null;
     return;
  end if;

  -- We must be processing a CLOB PLSQL doc type
  slash := instr(key, '/');
  if (slash = 0) then
    procname := substr(key, colon+1);
    procarg := '';
  else
    procname := substr(key, colon+1, slash-colon-1);
    procarg := substr(key, slash+1);
  end if;

  -- Bug 7476628 - Do not call WF_RENDER here, perform transformation
  -- in middle tier using WfRender.java
  if (not g_wf_render_xml_style_sheet) then
    if (dmstype = 'PLSQLCLOB' and upper(procname) = 'WF_RENDER.XML_STYLE_SHEET') then
      aname := null;
      return;
    end if;
  end if;

  -- Dynamic sql call to procedure
  -- bug 2706082 using execute immediate instead of dbms_sql.execute

  if (procarg is null) then
     procarg := NULL;
  else
     procarg := Wf_Notification.GetTextInternal(procarg, nid, target,
                                                FALSE, FALSE, 'text/plain');
  end if;

  -- ### Review Note 1
  l_charcheck := wf_notification_util.CheckIllegalChar(procname);
  --Throw the Illegal exception when the check fails

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string2(wf_log_pkg.level_statement,
                        'wf.plsql.wf_notification.GetAttrClob.plsqlclob_callout',
                        'Start executing PLSQLCLOB Doc procedure  - '||procname, true);
    end if;

    sqlbuf := 'begin '||procname||'(:p1, :p2, :p3, :p4); end;';
    -- Catch any exceptions from PLSQL Document APIs as is and log it to help
    -- troubleshoot issues from non-WF code
    begin
      execute immediate sqlbuf using
       in procarg,
       in disptype,
       in out document,
       in out doctype;
    exception
      when others then
        if (wf_log_pkg.level_exception >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_exception,
                'wf.plsql.wf_notification.GetAttrClob.plsqlclob_api',
                'Error executing PLSQLCLOB Doc API  - '||procname|| ' -> '||sqlerrm);
        end if;

    -- Bug 10130433: Throwing the WF error 'WFNTF_GEN_DOC' with all the error information
        -- when an exception occurs while executing the PLSQL Document APIs
        WF_CORE.Token('DOC_TYPE', 'PLSQLCLOB');
        WF_CORE.Token('FUNC_NAME', procname);
        WF_CORE.Token('SQLCODE', to_char(sqlcode));
        WF_CORE.Token('SQLERRM', DBMS_UTILITY.FORMAT_ERROR_STACK());
        WF_CORE.Raise('WFNTF_GEN_DOC');
    end;

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string2(wf_log_pkg.level_statement,
                        'wf.plsql.wf_notification.GetAttrClob.plsqlclob_callout',
                        'End executing PLSQLCLOB Doc procedure  - '||procname, false);
    end if;

exception
  when others then
    wf_core.context('Wf_Notification', 'GetAttrClob', to_char(nid), aname,
        disptype);
    raise;
end GetAttrClob;



-- Name: NewClob
-- Creates a new record in the temp table with a clob
-- this is necessary because clobs cannot reside in plsql
-- but must be part of a table.
Procedure NewClob  (clobloc       in out nocopy clob,
--                  --  clobid        in out nocopy number,
                    msg_string    in varchar2) is
 pos integer;
 amt number;

begin

   -- Before allocating TEMP LOb we should check whether existing Locator
   -- is pointing to a locator and whether being freed .
   -- bug 6511028
   begin
     if(clobloc is not null) then
        dbms_lob.freeTemporary(clobloc);
     end if;
   exception
      WHEN OTHERS THEN
         null;  -- ignore ORA-22275 and other exceptions
   end;

   -- make clob temporary. this may impact the speed of the UI
   -- such that user has to wait to see the notification.
   -- To improve performance make sure buffer cache is well tuned.
   dbms_lob.createtemporary(clobloc, TRUE, DBMS_LOB.session);

   if msg_string is not null then
      pos := 1;
      amt := length(msg_string);
      dbms_lob.write(clobloc,amt,pos,msg_string);
   end if;

exception
when others then
    wf_core.context('WF_NOTIFICATION','NewClob');
    raise;
end NewClob;

--Name Read_Clob
--reads a specific clob in 8K chunks. Call this repeatedly until
--end_of_clob is true.
procedure read_clob (line out nocopy varchar2 ,
                     end_of_clob in out nocopy boolean) is

 pos number;
 buff_length pls_integer:=8000;
begin

   --linenbr is always one before the line to print.
   --it is incremented afterwards.
   pos:=(buff_length * nvl(wf_notification.clob_chunk,0)  ) +1;

   dbms_lob.read(wf_notification.temp_clob,buff_length,pos,line);

   if pos+buff_length > dbms_lob.getlength(wf_notification.temp_clob)  then
      end_of_clob := TRUE;
      wf_notification.clob_chunk  := 0;
   else
      wf_notification.clob_chunk  := wf_notification.clob_chunk +1;
   end if;

exception
  when others then
    wf_core.context('Wf_Notification', 'Read_Clob','pos => '||to_char(pos),
                    'line => {'||line||'}');
    raise;
end Read_Clob;

--Name ReadAttrClob (PUBLIC)
--Desc : Gets full text of a PLSQLCLOB variable
--       and returns the 32K chunks in the doctext out variable.
--       Call this repeatedly until end_of_text is true.
--USE :  use this to get the value of idividual PLSQLCLOBs such as attachments.
--       to susbtitute a PLSQLSQL clob into a message body, use GetFullBody

procedure ReadAttrClob(nid         in number,
                       aname       in varchar2,
                       doctext     in out nocopy varchar2,
                       end_of_text in out nocopy boolean) is
clob_id    number;
attr_name varchar2(30);
begin
   if  nid = wf_notification.last_nid
   and wf_notification.clob_exists is not null then
         wf_notification.read_Clob(doctext, end_of_text);
   else
      --create a clob
      wf_notification.newclob(wf_notification.temp_clob,null);
      wf_notification.clob_exists :=1;

      --set the clob text
      wf_notification.getattrclob(nid, aname,
          wf_notification.doc_html, wf_notification.temp_clob , attr_name);

      --retreive all the clob text in 32K chunks.
      if attr_name = aname then
         -- the attribute was substituted with something in the clob so print it.
         wf_notification.clob_chunk  := 0;
         wf_notification.read_Clob(doctext, end_of_text);

      else
         --the aname was not substituted so just print it.
          doctext := aname;
      end if;

      --finally set the global vars
      wf_notification.last_nid:=nid;


  end if;

exception
  when others then
    wf_core.context('Wf_Notification', 'ReadAttrClob');
    raise;
end ReadAttrClob;

--
-- Denormalization of Notifications
--

--
-- GetSessionLanguage (PRIVATE)
--   Try to return the cached session language value.
--   If it is not cached yet, call the real query function.
--
function GetSessionLanguage
return varchar2
is
  l_lang  varchar2(64);
  l_terr  varchar2(64);
  l_chrs  varchar2(64);
begin
  -- <7514495> no cached variable in Wf_Notification now?
--  if (Wf_Notification.nls_language is not null) then
--    return Wf_Notification.nls_language;
--  end if;

  GetNLSLanguage(l_lang, l_terr, l_chrs);
  return l_lang;

end GetSessionLanguage;

--
-- GetNLSLanguage (PRIVATE)
--   Get the NLS Lanugage setting of current session
--   Try to cached the value for future use.
-- NOTE:
--   Because it tried to use cached values first.  The subsequent calls
-- will give you the cached values instead of the current value.
--
procedure GetNLSLanguage(language  out nocopy varchar2,
                         territory out nocopy varchar2,
                         charset   out nocopy varchar2)
is
  tmpbuf  varchar2(240);
  pos1    number;        -- position for '_'
  pos2    number;        -- position for '.'
  l_nlsDateFormat varchar2(64);
  l_nlsDateLang varchar2(64);
  l_nlsNumChars varchar2(64);
  l_nlsSort varchar2(64);
  l_nlsCalendar varchar2(64);

begin
  -- <7514495> now uses centralized api
--  if (Wf_Notification.nls_language is null) then
--    tmpbuf := userenv('LANGUAGE');
--    pos1 := instr(tmpbuf, '_');
--    pos2 := instr(tmpbuf, '.');
--
--    Wf_Notification.nls_language  := substr(tmpbuf, 1, pos1-1);
--    Wf_Notification.nls_territory := substr(tmpbuf, pos1+1, pos2-pos1-1);
--    Wf_Notification.nls_charset   := substr(tmpbuf, pos2+1);
--  end if;
--
--  GetNLSLanguage.language  := Wf_Notification.nls_language;
--  GetNLSLanguage.territory := Wf_Notification.nls_territory;
--  GetNLSLanguage.charset   := Wf_Notification.nls_charset;

  wf_notification_util.getNLSContext( p_nlsLanguage=> GetNLSLanguage.language,
                           p_nlsTerritory => GetNLSLanguage.territory,
                           p_nlsCode       => GetNLSLanguage.charset,
                           p_nlsDateFormat => l_nlsDateFormat,
                           p_nlsDateLanguage => l_nlsDateLang,
                           p_nlsNumericCharacters => l_nlsNumChars,
                           p_nlsSort => l_nlsSort,
                           p_nlsCalendar => l_nlsCalendar);

end GetNLSLanguage;



--
-- SetNLSLanguage (PRIVATE)
--   Set the NLS Lanugage setting of current session
--
procedure SetNLSLanguage(p_language  in varchar2,
                         p_territory in varchar2)
is
   l_language varchar2(30);
   l_territory varchar2(30);
begin
  -- <7514495> now we use centralized api
--  if (p_language = Wf_Notification.nls_language) then
--     return;
--  end if;
--
--  l_language := ''''||p_language||'''';
--  l_territory := ''''||p_territory||'''';
--
--  DBMS_SESSION.SET_NLS('NLS_LANGUAGE', l_language);
--  DBMS_SESSION.SET_NLS('NLS_TERRITORY', l_territory);
--
--  -- update cache
--  Wf_Notification.nls_language := p_language;
--  Wf_Notification.nls_territory := p_territory;

  wf_notification_util.SetNLSContext( -- p_nid  ,
                          p_nlsLanguage  => l_language,
                          p_nlsTerritory => p_territory
                          -- ok not to pass next parameters
                          -- as fnd_global.set_nls_context won't set
                          -- if null
--                          p_nlsDateFormat ,
--                          p_nlsDateLanguage ,
--                          p_nlsNumericCharacters ,
--                          p_nlsSort ,
--                          p_nlsCalendar
                          );
exception
  when others then
     Wf_Core.Context('Wf_Notification', 'SetNLSLanguage', p_language, p_territory);
     raise;
end SetNLSLanguage;

--
-- Denormalize_Notification
--   Populate the donormalized value to WF_NOTIFICATIONS table according
-- to the language setting of username provided.
-- IN:
--   nid - Notification id
--   username - optional role name, if not provided, use the
--              recipient_role of the notification.
--   langcode - language code
--
-- NOTE: username has precedence over langcode.  Either username or
--       langcode is needed.
--
procedure Denormalize_Notification(nid      in number,
                                   username in varchar2,
                                   langcode in varchar2)
is
  l_orig_lang varchar2(64);
  l_user      varchar2(320);
  l_from_role varchar2(320);
  l_from_user varchar2(360);
  l_to_user   varchar2(360);
  l_subject   varchar2(2000);
  l_language  varchar2(64);
  role_info_tbl wf_directory.wf_local_roles_tbl_type;
  l_territory varchar2(64);
  l_nls_date_format varchar2(64);
  l_nls_date_language varchar2(64);
  l_nls_calendar      varchar2(64);
  l_nls_numeric_characters varchar2(64);
  l_nls_sort   varchar2(64);
  l_nls_currency   varchar2(64);

  l_defer_denormalize boolean;
  l_parameterlist wf_parameter_list_t;
  l_orig_nlsterritory varchar2(64);
  l_orig_nlsCode varchar2(64);
  l_orig_nlsDateFormat varchar2(64);
  l_orig_nlsDateLang varchar2(64);
  l_orig_nlsNumChars varchar2(64);
  l_orig_nlsSort varchar2(64);
  l_orig_nlsCalendar varchar2(64);
  l_logSTMT boolean;
  l_logPRCD boolean;
  l_sessionUser varchar2(320);
  l_sessionUserInfo wf_directory.wf_local_roles_tbl_type;
  l_canDefer boolean;
  l_module       varchar2(100):=g_plsqlName|| 'Denormalize_Notification()';

begin
    l_logPRCD := WF_LOG_PKG.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level;
    l_logSTMT := WF_LOG_PKG.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level;
    if ( l_logPRCD ) then
      wf_log_pkg.String(wf_log_pkg.LEVEL_PROCEDURE, l_module
         , 'BEGIN, nid='||nid||', username='||username||', langcode='||langcode);
    end if;

  -- 8286459. Get value, and always reset flag;
  l_canDefer := wf_notification_util.g_allowDeferDenormalize;
  wf_notification_util.g_allowDeferDenormalize := true;

  -- <7720908>
  wf_notification_util.getNLSContext( l_orig_lang, l_orig_nlsterritory, l_orig_nlsCode
                         , l_orig_nlsDateFormat, l_orig_nlsDateLang
                         , l_orig_nlsNumChars, l_orig_nlsSort, l_orig_nlsCalendar);

  if (l_orig_nlsCalendar is null) then
    -- when null (typically, online session), get calendar from user prefs
    l_sessionUser := Wfa_Sec.GetUser();
    if ( l_logSTMT ) then
        wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, l_module
                                   , 'l_sessionUser=>'||l_sessionUser||'<');
    end if;

    if (l_sessionUser is not null) then
      Wf_Directory.GetRoleInfo2(l_sessionUser, l_sessionUserInfo);
      l_orig_nlsCalendar := l_sessionUserInfo(1).nls_calendar;
      if ( l_logSTMT ) then
          wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, l_module
                         , 'l_sessionUser calendar=>'||l_orig_nlsCalendar||'<');
      end if;
    end if;
  end if;

  l_defer_denormalize := FALSE;
  l_parameterlist := wf_parameter_list_t();

  -- if username is supplied, use the language setting of such user
  -- default to Recipient's setting if no valid language is found.
  begin
    if (username is not null) then
      Wf_Directory.GetRoleInfo2(username, role_info_tbl);
      l_language := role_info_tbl(1).language;

      -- <7514495> full NLS support
      l_territory := role_info_tbl(1).territory;
      l_nls_date_format  := role_info_tbl(1).nls_date_format;
      l_nls_date_language := role_info_tbl(1).nls_date_language;
      l_nls_calendar  := role_info_tbl(1).nls_calendar;
      l_nls_numeric_characters  := role_info_tbl(1).nls_numeric_characters;
      l_nls_sort  := role_info_tbl(1).nls_sort;
      l_nls_currency   := role_info_tbl(1).nls_currency; -- </7514495>

      role_info_tbl.DELETE;

      if ( l_logSTMT ) then
        wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, l_module
           , 'Got '||username||'''s preferences (passed by caller), lang='||l_language);
      end if;

      -- check if user language match
      if (l_orig_lang <> l_language) then
          return;
      end if;

    elsif (langcode is not null) then
      -- check if langcode match
      if (langcode <> userenv('LANG')) then
          if ( l_logPRCD ) then
            wf_log_pkg.String(wf_log_pkg.LEVEL_PROCEDURE, l_module
               , 'END - did nothing, langcode <> session lang');
          end if;
          return;
      end if;
      select NLS_LANGUAGE
        into l_language
        from WF_LANGUAGES
       where CODE = langcode;
        -- ###         and INSTALLED_FLAG = 'Y';
        -- ### Maybe we do not need to restrict installed flag to be Y
    end if;
  exception
    when OTHERS then
      l_language := null;
  end;

  begin
    select RECIPIENT_ROLE, FROM_ROLE
      into l_user, l_from_role
      from WF_NOTIFICATIONS
     where NOTIFICATION_ID = nid;
  exception
    when NO_DATA_FOUND then
      wf_core.token('NID', to_char(nid));
      wf_core.raise('WFNTF_NID');
  end;

  if ( l_logSTMT ) then
    wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, l_module
       , 'Getting '||l_user||'''s (recipient) preferences');
  end if;

  Wf_Directory.GetRoleInfo2(l_user, role_info_tbl);
  -- in most cases, l_language should be null and we use the language setting
  -- of the recipient role.
  if (l_language is null) then
    l_language := role_info_tbl(1).language;

    -- <7514495> full NLS support
    l_territory := role_info_tbl(1).territory;
    l_nls_date_format  := role_info_tbl(1).nls_date_format;
    l_nls_date_language := role_info_tbl(1).nls_date_language;
    l_nls_calendar  := role_info_tbl(1).nls_calendar;
    l_nls_numeric_characters  := role_info_tbl(1).nls_numeric_characters;
    l_nls_sort  := role_info_tbl(1).nls_sort;
    l_nls_currency   := role_info_tbl(1).nls_currency; -- </7514495>

    -- 8286459
    if l_canDefer and
       ((l_orig_lang          <> l_language) or
        (l_orig_nlsDateFormat <> l_nls_date_format) or
        (l_orig_nlsCalendar   <> l_nls_calendar)
      ) then
      -- do not do anything if the NLS settings do not match
      l_defer_denormalize := TRUE;

      if ( l_logSTMT ) then
          wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, l_module
               , 'l_orig_lang:>'|| l_orig_lang ||'<, l_language:>'||l_language);
          wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, l_module
               , 'l_orig_nlsDateFormat:>'||l_orig_nlsDateFormat ||'<, l_nls_date_format:>'||l_nls_date_format);
          wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, l_module
               , 'l_orig_nlsDateLang:>'||l_orig_nlsDateLang ||'<, l_nls_date_language:>'||l_nls_date_language);
          wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, l_module
               , 'l_orig_nlsCalendar:>'|| l_orig_nlsCalendar ||'<, l_nls_calendar:>'||l_nls_calendar);
          wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, l_module
               , 'l_orig_nlsterritory:>'|| l_orig_nlsterritory ||'<, l_territory:>'||l_territory);
          wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, l_module
               , 'l_orig_nlsSort:>'||  l_orig_nlsSort||'<, l_nls_sort:>'||l_nls_sort);
      end if;
    end if;
  end if;

  if (l_defer_denormalize) then

    -- To raise an EVENT when l_defer_denormalize is set true
    wf_event.AddParameterToList('NOTIFICATION_ID',nid,l_parameterlist);
    wf_event.AddParameterToList('ROLE',l_user,l_parameterlist);
    wf_event.AddParameterToList('LANGUAGE',l_language,l_parameterlist);
    wf_event.AddParameterToList('TERRITORY',l_territory,l_parameterlist);

    -- <7514495>
    wf_event.AddParameterToList('NLS_DATE_FORMAT', l_nls_date_format,l_parameterlist);
    wf_event.AddParameterToList('NLS_DATE_LANGUAGE', l_nls_date_language,l_parameterlist);
    wf_event.AddParameterToList('NLS_CALENDAR', l_nls_calendar,l_parameterlist);
    wf_event.AddParameterToList('NLS_NUMERIC_CHARACTERS', l_nls_numeric_characters,l_parameterlist);
    wf_event.AddParameterToList('NLS_SORT', l_nls_sort,l_parameterlist);
    wf_event.AddParameterToList('NLS_CURRENCY', l_nls_currency,l_parameterlist);
    -- </7514495>

    if ( l_logSTMT ) then
      wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, l_module, 'defer parameters: '||
                          'nid('||nid||'), role('||l_user||'), language('||l_language||')');
      wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, l_module, 'territory('||l_territory||
                          '), date_format('||l_nls_date_format||'), date_language('||
                          l_nls_date_language||')');
      wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, l_module, 'calendar('||l_nls_calendar||
                       '), numeric_characters('||l_nls_numeric_characters||'), sort('||
                       l_nls_sort||'), currency('||l_nls_currency||')');
    end if;
    if ( l_logPRCD ) then
      wf_log_pkg.String(wf_log_pkg.LEVEL_PROCEDURE, l_module, 'END - deferring denormalization');
    end if;

    -- Raise the event
    wf_event.Raise(p_event_name => 'oracle.apps.wf.notification.denormalize',
                 p_event_key  => to_char(nid),
                 p_parameters => l_parameterlist);

    return;
  end if;

  if ( l_logSTMT ) then
      wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, l_module,
                'Not deferring denormalization, so using session''s settings');
  end if;

  -- To User
  -- N.B.: substrb is used in stead of substr because 320 is a hard byte limit.
  --       substr in some characterset may return > 320 bytes.
  l_to_user := role_info_tbl(1).display_name;
  l_to_user := substrb(l_to_user,1,320);

  -- From User
  --  If FROM_ROLE has not been defined yet, we tried to draw this from
  --  #FROM_ROLE.
  if (l_from_role is NULL) then
    begin
      l_from_role := Wf_Notification.GetAttrText(nid, '#FROM_ROLE');
    exception
      when OTHERS then
        wf_core.clear;  -- clear the error stack
        l_from_role := NULL;
    end;
  end if;

  --  We need to make l_from_user consistant with l_from_role.
  if (l_from_role is not NULL) then
    l_from_user := Wf_Directory.GetRoleDisplayName(l_from_role);
    l_from_user := substrb(l_from_user, 1,320);
  end if;


  -- Subject
  -- skilaru 08-MAY-03 bug fix 2883247
  l_subject := Wf_Notification.GetSubject(nid, 'text/plain');

  if ( l_logSTMT ) then
      wf_log_pkg.String(wf_log_pkg.LEVEL_STATEMENT, l_module, 'subject('||l_subject||')');
  end if;
  -- Populate the notification values
  --
  begin
    update WF_NOTIFICATIONS
       set FROM_USER = l_from_user,
           FROM_ROLE = nvl(l_from_role,FROM_ROLE),
           TO_USER = l_to_user,
           SUBJECT = l_subject,
           LANGUAGE = userenv('LANG')
     where NOTIFICATION_ID = nid;
  exception
    when OTHERS then
      wf_core.token('NID', to_char(nid));
      wf_core.raise('WFNTF_DENORM_FAILED');
  end;

  if ( l_logPRCD ) then
      wf_log_pkg.String(wf_log_pkg.LEVEL_PROCEDURE, l_module, 'END');
  end if;
exception
  when OTHERS then
    wf_core.context('Wf_Notification', 'Denormalize_Notification',
                    to_char(nid), username);
    raise;
end Denormalize_Notification;

--
-- closeFYI
--   Close FYI notifications that are not associated with an item.
-- IN:
--   itemtype - Item Type the notification belongs to.
--   begindate  - Close FYI notifications that were opened on
--                or before this date.
--
procedure closeFYI( itemtype in varchar2,
                    messageName in varchar2,
                    begindate in date) is

  xitemtype    varchar2(8);
  xmessageName varchar2(30);

  cursor fyiNid is
         select WN.NOTIFICATION_ID
         from   WF_NOTIFICATIONS WN
         where  MESSAGE_TYPE like xitemtype
         and    MESSAGE_NAME like xmessageName
         and    BEGIN_DATE<=begindate
         and    STATUS = 'OPEN'
         and not exists (
             select NULL
             from WF_MESSAGE_ATTRIBUTES WMA
             where WMA.MESSAGE_TYPE = WN.MESSAGE_TYPE
             and   WMA.MESSAGE_NAME = WN.MESSAGE_NAME
             and   WMA.SUBTYPE = 'RESPOND');


begin

        xitemtype := nvl(itemtype, '%');
        xmessageName := nvl(messageName, '%');

        for c in fyiNid LOOP

            WF_NOTIFICATION.Close( c.NOTIFICATION_ID );

        end loop;

end closeFYI;

--
-- NtfSignRequirementsMet (PUBLIC) (Bug 2698999)
--   Checks if the notification's singature requirements are met
-- IN
--   nid - notification id
-- OUT
--   true - if the ntf is signed
--   false - if the ntf is not signed
--
function NtfSignRequirementsMet(nid in number)
return boolean is
  sig_policy    varchar2(100);
  sig_id        number;
  sig_status    number;
  creation_date date;
  signed_date   date;
  verified_date date;
  lastAttVal_date date;
  validated_date  date;
  ebuf          varchar2(4000);
  estack        varchar2(4000);
  l_attr_sigid  number;
  sig_required  Varchar2(1);
  fwk_sig_flavor   Varchar2(255);
  email_sig_flavor Varchar2(255);
  render_hint    Varchar2(255);

begin
  -- get the signature policy for the notification
  -- wf_mail.GetSignaturePolicy(nid, sig_policy);
  begin
    sig_policy := Wf_Notification.GetAttrText(nid, '#WF_SIG_POLICY');
  exception
    when others then
      if (wf_core.error_name = 'WFNTF_ATTR') then
        wf_core.clear;
        sig_policy := 'DEFAULT';
      else
        raise;
      end if;
  end;

  /* check if signature is required for this sig_policy*/
  GetSignatureRequired(sig_policy, nid,sig_required, fwk_sig_flavor,
    email_sig_flavor, render_hint);

  If(sig_required = 'N') then
    return TRUE;
  Elsif(sig_required = 'Y') then

    -- bug 2779748: Cancelled Notification does not need to be signed
    begin
      if (WF_Notification.GetAttrText(nid, 'RESULT') = '#SIG_CANCEL') then
        return TRUE;
      end if;
    exception
      when others then
        if (wf_core.error_name = 'WFNTF_ATTR') then
          wf_core.clear;
        else
          raise;
        end if;
    end;

    sig_id := WF_DIG_SIG_EVIDENCE_STORE.GetMostRecentSigID('WF_NTF', nid);
    begin
       -- #WF_SIG_ID may be defined as text or number... Now both will work
       -- Eventually should use GetAttrNumber
       l_attr_sigid := to_number(Wf_Notification.GetAttrText(nid, '#WF_SIG_ID'));
    exception
      when others then
        if (wf_core.error_name = 'WFNTF_ATTR') then
          wf_core.clear;
          l_attr_sigid := -1;
        else
          raise;
        end if;
    end;
    if (sig_id = -1 or sig_id <> l_attr_sigid) then
       return FALSE;
    end if;

    WF_DIG_SIG_EVIDENCE_STORE.GetSigStatusInfo(sig_id, sig_status, creation_date,
                         signed_date, verified_date, lastAttVal_date, validated_date,
                         ebuf, estack);
    if (sig_status >= WF_DIGITAL_SECURITY_PRIVATE.STAT_AUTHORIZED) then
       return TRUE;
    end if;
    return FALSE;
  end if;

  -- Currently only two policies supported. For others assume it is signed
  return TRUE;

exception
  when others then
    wf_core.context('Wf_Notification', 'NtfSignRequirementsMet', to_char(nid));
    raise;
end NtfSignRequirementsMet;

--
-- Request More Info
--

--
-- UpdateInfo
--   non-null username: Ask this user for more information
--   null username: Reply to the inquery
--   comment could be question or answer
-- NOTE:
--   This is a Framework specific api.  Embedded version SHOULD NOT call
-- this api.
--   Because we cannot validate a session inside Framework, calling such
-- api outside of Framework may produce erroneous result.
-- IN
--   nid - Notification Id
--   username - User to whom the comment is intended
--   comment - Comment text
--   wl_user - Worklist user to whom the notfication belongs, in case a proxy is acting
--   action_source - Source from where the call is made. Could be null or 'WA'
--
procedure UpdateInfo(nid      in number,
                     username in varchar2,
                     comment  in varchar2,
                     wl_user  in varchar2,
                     action_source in varchar2,
                     cnt      in number)
is
  resource_busy exception;
  pragma exception_init(resource_busy, -00054);

  l_from_role  varchar2(320);
  replyby      varchar2(320);
  myusername   varchar2(320);
  mydispname   varchar2(360);
  l_messageType    varchar2(8);
  l_messageName    varchar2(30);
  l_groupId        number;
  l_parameterlist  wf_parameter_list_t := wf_parameter_list_t();
  mailpref  varchar2 (8);
  recipient_role VARCHAR2 (320);
  cb             varchar2(240);
  context varchar2(2000);
  sqlbuf varchar2(2000);
  tvalue varchar2(4000);
  nvalue number ;
  dvalue date ;
 --Bug 3827935
  l_charcheck boolean;

  --Bug 3065814
  l_recip_role  varchar2(320);
  l_orig_recip_role  varchar2(320);
  l_more_info_role  varchar2(320);
  l_question_role   varchar2(320);
  l_admin_role   varchar2(320);
  l_dummy varchar2(1);

  --Bug 5444378
  l_ruleAction varchar2(8);
  l_newRole    varchar2(2000);
  l_sysComment varchar2(320);

  l_language  varchar2(30);
  role_info_tbl  wf_directory.wf_local_roles_tbl_type;

  -- bug 7130745
  l_event_name varchar2(240);
  l_subject varchar2(1000);
  l_mode VARCHAR2(20);


begin

  -- Framework has control of a session.
  -- We are not allowed to re-validate a session any more.  So we cannot
  -- use wfa_sec.GetSession() directly.
  myusername := wfa_sec.GetFWKUserName;

  -- Bug 3065814
  -- Set the global context variables to appropriate values for this mode
  if (action_source = 'WA') then
    -- Action is performed by a proxy on behalf of wl_user.
    g_context_proxy := myusername;
    g_context_user  := UpdateInfo.wl_user;
    -- In Answer mode, wl_user is the more_info_role and Fwk session user is the proxy_role
    myusername      := UpdateInfo.wl_user;
  else
    -- Action is performed by the recipient of the notification
    g_context_proxy := null;
    g_context_user  := myusername;
  end if;

  mydispname := Wf_Directory.GetRoleDisplayName(myusername);
  g_context_user_comment := updateinfo.comment;

  --Bug 3065814
  --Get the callback function
  SELECT    callback , context ,RECIPIENT_ROLE, ORIGINAL_RECIPIENT,
            MORE_INFO_ROLE ,from_role, message_type, message_name
  into      cb, context,l_recip_role , l_orig_recip_role,
            l_more_info_role, l_from_role, l_messageType, l_messageName
  FROM      wf_notifications
  WHERE     notification_id  = nid;

  g_context_original_recipient:= l_orig_recip_role;
  g_context_from_role := l_from_role;
  --The new role will be different for 'ANSWER mode
  --we overwrite it there.
  g_context_new_role  := username;
  g_context_more_info_role  := l_more_info_role;

  -- If we are in a different Fwk session, need to clear Workflow PLSQL state
  if (not Wfa_Sec.CheckSession) then
    Wf_Global.Init;
  end if;

  -- question mode
  if (username is not null) then
    --Bug 17254513: only allow request from an active, existing role
    if not WF_DIRECTORY.RoleActive(username) then
      wf_core.raise('WFNTF_NO_ROLE');
    end if;
    if (myusername = username) then
      --Bug 2474770
      --If the current user is the same as the one from
      --whom more-info is requested then raise the error
      --that you cannot ask for more info from yourself.
      wf_core.token('USER',username);
      wf_core.raise('WFNTF_INVALID_MOREINFO_REQUEST');
    else
          g_context_recipient_role := l_recip_role;
          -- do not want it hung when some one is doing update.
          begin
            select MORE_INFO_ROLE
            into l_from_role
            from WF_NOTIFICATIONS
            where NOTIFICATION_ID = nid
            for update nowait;
          exception
            when NO_DATA_FOUND then
              null;
            when resource_busy then
              wf_core.raise('WFNTF_BEING_UPDATED');
              -- ### This notification is being updated currently, please
              -- ### try again in a brief moment.
          end;

          l_mode := 'QUESTION';

          if (cb is not null) then
            tvalue := myusername;
            nvalue := nid;
            -- ### Review Note 2 - cb is from table
            --Check for bug#3827935
            l_charcheck := wf_notification_util.CheckIllegalChar(cb);
           --Throw the Illegal exception when the check fails


            -- BINDVAR_SCAN_IGNORE
             sqlbuf := 'begin '||cb||
                      '(:p1, :p2, :p3, :p4, :p5, :p6, :p7); end;';
             execute immediate sqlbuf using
              in l_mode,
              in context,
              in l_dummy,
              in l_dummy,
              in out tvalue,
              in out nvalue,
              in out dvalue;

          end if;

          -- always allow question
          -- bug 2474562
          -- allows any role, as restriction is done in the pop list level
          -- if (IsValidInfoRole(nid,username)) then

          -- shanjgik 01-JUL-03 bug 2887130
          -- get mail preference of the user who will respond with more information
          mailpref := wf_notification.GetMailPreference (username, null, null);

          -- if there is a valid session, then we can update the FROM_ROLE
          -- and FROM_USER accurately.
          if (myusername is not null) then
            update WF_NOTIFICATIONS
            set MORE_INFO_ROLE = username,
                FROM_USER = mydispname,
                FROM_ROLE = myusername,
                SENT_DATE = SYSDATE,
              MAIL_STATUS = decode (mailpref, 'QUERY', '',
                                    'SUMMARY', '',
                                    'SUMHTML','',
                                    'DISABLED', 'FAILED',
                                    null, '', 'MAIL')
            where NOTIFICATION_ID = nid;

          -- otherwise, we default to what it should be.  Unfortunately, if it
          -- is a group role, we will not be able to identify which member I am.
          else
            update WF_NOTIFICATIONS
            set MORE_INFO_ROLE = username,
                FROM_USER = TO_USER,
                FROM_ROLE = RECIPIENT_ROLE,
                SENT_DATE = SYSDATE,
              MAIL_STATUS = decode (mailpref, 'QUERY', '',
                                    'SUMMARY', '',
                                    'SUMHTML','',
                                    'DISABLED', 'FAILED',
                                    null, '', 'MAIL')
          where NOTIFICATION_ID = nid;
          end if;

          Wf_Notification.SetComments(nid, myusername, username, l_mode, action_source, substrb(comment,1,4000));

          -- LANGUAGE here is for FROM_USER which came from WF_NOTIFICATIONS above
          -- insert into WF_COMMENTS (
          --    NOTIFICATION_ID,
          --    FROM_ROLE,
          --    FROM_USER,
          --    COMMENT_DATE,
          --    ACTION,
          --    USER_COMMENT,
          --    LANGUAGE
          --  )
          --  select NOTIFICATION_ID,
          --         FROM_ROLE,
          --         FROM_USER,
          --         sysdate,
          --         'QUESTION',
          --         substrb(comment,1,4000),
          --         LANGUAGE
          --    from WF_NOTIFICATIONS
          --   where NOTIFICATION_ID = nid;

        -- bug 2474562
        -- else
        --   wf_core.token('ROLE',username);
        --   wf_core.raise('WFNTF_NOT_PARTICIPANTS');
        -- end if;
        end if;
    /* implement the above loop recursively */
    if (cnt > wf_notification.max_forward) then
        -- it means max_forward must have been exceeded.  Treat as a loop error.
        wf_core.token('NID', to_char(nid));
        wf_core.raise('WFNTF_ROUTE_LOOP');
    end if;

    -- Calling RouteMoreInfo to check and handle if there are any Routing Rules
    wf_notification.RouteMoreInfo(nid, myusername, action_source, cnt);

    -- if we are here, mean we are going to raise
    -- oracle.apps.wf.notification.question event.
    l_event_name := 'oracle.apps.wf.notification.question';

  -- answer mode
  -- NOTE: the language here is the language of the MORE_INFO_ROLE,
  --       no denormalization is needed here.
  else
    -- Do not allow reply when a question has not been asked, or it has
    -- already been answered.  In both cases, MORE_INFO_ROLE is set to null.
    -- Also acquire a row lock, so that we do not let multiple people to
    -- answer at the same time.
    begin
      select MORE_INFO_ROLE,Wf_Directory.GetRoleDisplayName(MORE_INFO_ROLE), RECIPIENT_ROLE
        into l_from_role, replyby, recipient_role
        from WF_NOTIFICATIONS
       where NOTIFICATION_ID = nid
         and MORE_INFO_ROLE is not null
         for update nowait;

    exception
      when NO_DATA_FOUND then
        -- if it has no row, we cannot reply to this notification
        -- ### You cannot reply to a question that has not been asked
        -- ### or has already been answered.
          WF_MAIL.SendMoreInfoResponseWarning(nid);
          return;
      when resource_busy then
        wf_core.raise('WFNTF_BEING_UPDATED');
        -- ### This notification is being updated currently, please
        -- ### try again in a brief moment.
    end;

    -- Bug 11893836: Checking whether Workflow Administrator is
    --Answering the Question
    l_admin_role := WF_CORE.Translate('WF_ADMIN_ROLE');

    if (myusername is not null and l_from_role <> myusername) then
      if (not Wf_Directory.IsPerformer(myusername, l_from_role) and not Wf_Directory.IsPerformer(myusername, l_admin_role)) then
        wf_core.token('ROLE',myusername);
        wf_core.token('MORE_INFO_ROLE', l_from_role);
        wf_core.token('NID', to_char(nid));
        wf_core.raise('WFNTF_NOT_PARTICIPANTS');
      end if;
      l_from_role := myusername;
      replyby := mydispname;
    end if;
    g_context_recipient_role := l_from_role;

    l_mode := 'ANSWER';
    if (cb is not null) then
      tvalue := myusername;
      nvalue := nid;
      g_context_new_role := recipient_role;
      -- ### Review Note 2 - cb is from table
      -- Check for bug#3827935
      l_charcheck := wf_notification_util.CheckIllegalChar(cb);
      --Throw the Illegal exception when the check fails

       -- BINDVAR_SCAN_IGNORE
       sqlbuf := 'begin '||cb||
                '(:p1, :p2, :p3, :p4, :p5, :p6, :p7); end;';
       execute immediate sqlbuf using
        in l_mode,
        in context,
        in l_dummy,
        in l_dummy,
        in out tvalue,
        in out nvalue,
        in out dvalue;

    end if;

    -- shanjgik 01-JUL-03 bug 2887130
    -- get the recipient's(one who requested more information) mail preference
    mailpref := wf_notification.GetMailPreference (recipient_role, null, null);

    update WF_NOTIFICATIONS
       set FROM_USER = replyby,
           FROM_ROLE = l_from_role,
           MORE_INFO_ROLE = null,
           SENT_DATE = SYSDATE,
           MAIL_STATUS = decode (mailpref, 'QUERY', '',
                                 'SUMMARY', '',
                                 'SUMHTML','',
                                 'DISABLED', 'FAILED',
                                 null, '', 'MAIL')
       where NOTIFICATION_ID = nid;

    Wf_Notification.SetComments(nid, l_from_role, recipient_role, l_mode, action_source, substrb(comment,1,4000));

    -- LANGUAGE here is for FROM_USER which came from GetRoleDisplayName above,
    -- so the LANGUAGE should be current userenv('LANG').
    -- insert into WF_COMMENTS (
    --      NOTIFICATION_ID,
    --      FROM_ROLE,
    --      FROM_USER,
    --      COMMENT_DATE,
    --      ACTION,
    --      USER_COMMENT,
    --      LANGUAGE
    --    )
    --    select NOTIFICATION_ID,
    --           FROM_ROLE,
    --           FROM_USER,
    --           sysdate,
    --           'ANSWER',
    --           substrb(comment,1,4000),
    --           userenv('LANG')
    --      from WF_NOTIFICATIONS
    --     where NOTIFICATION_ID = nid;

    -- <<BUG 7130745>>
    -- if we are here, mean we are going to raise
    -- oracle.apps.wf.notification.answer event.
    l_event_name := 'oracle.apps.wf.notification.answer';

  end if;

  -- Bug 8509185. Need to make clob_exists null so that GetFullBody reads the
  -- notification entirely
  wf_notification.clob_exists := null;

  -- Send the notification through email
  -- wf_xml.EnqueueNotification(nid);

  -- Bug 2283697
  -- To raise an EVENT whenever DML operation is performed on
  -- WF_NOTIFICATIONS and WF_NOTIFICATION_ATTRIBUTES table.
  wf_event.AddParameterToList('NOTIFICATION_ID', nid, l_parameterlist);
  wf_event.AddParameterToList('ROLE', username, l_parameterlist);
  wf_event.AddParameterToList('GROUP_ID', nvl(l_groupId, nid), l_parameterlist);
  wf_event.addParameterToList('Q_CORRELATION_ID', l_messageType||':'||
                              l_messageName, l_parameterlist);


  Wf_Directory.GetRoleInfo2(l_recip_role, role_info_tbl);
  l_language := role_info_tbl(1).language;

  select code into l_language from wf_languages where nls_language = l_language;

  -- AppSearch
  wf_event.AddParameterToList('OBJECT_NAME',
  'oracle.apps.fnd.wf.worklist.server.AllNotificationsVO', l_parameterlist);
  wf_event.AddParameterToList('CHANGE_TYPE', 'INSERT',l_parameterlist);
  wf_event.AddParameterToList('ID_TYPE', 'PK', l_parameterlist);
  wf_event.addParameterToList('PK_NAME_1', 'NOTIFICATION_ID',l_parameterlist);
  wf_event.addParameterToList('PK_VALUE_1', nid, l_parameterlist);
  wf_event.addParameterToList('PK_NAME_2', 'LANGUAGE',l_parameterlist);
  wf_event.addParameterToList('PK_VALUE_2', l_language, l_parameterlist);


  -- Raise the event
  -- wf_event.Raise(p_event_name => 'oracle.apps.wf.notification.send',
  --               p_event_key  => to_char(nid),
  --               p_parameters => l_parameterlist);

  -- <<sstomar: bug 7130745 : use different event names for question and answer >>
  wf_event.Raise(p_event_name => l_event_name,
                 p_event_key  => to_char(nid),
                 p_parameters => l_parameterlist);

  --Raise the push approvals event if the item type and message name exists in wf_wl_config_types table
  --25665061: TSTMB7.0:PUSH NTF NOT COMING FOR PROVIDE INFORMATION. Raise push in Answer mode.
  if (l_mode = 'QUESTION') then
     RaisePushNotificationEvent(username, l_messageType, l_messageName, nid, true);
  elsif (l_mode = 'ANSWER')then
     RaisePushNotificationEvent(recipient_role, l_messageType, l_messageName, nid, false);
  end if;

exception
  when OTHERS then
    Wf_Core.Context('Wf_Notification', 'UpdateInfo', to_char(nid), username, wl_user, action_source);
    raise;
end UpdateInfo;

--
-- Transfer Request Information
--

--
-- TransferMoreInfo
-- NOTE:
--   This API is used to Transfer Request More Information notification.
--   A Recipient or a Workflow Admin can transfer Request More Info Notification
--   to any other user.
-- IN
--   p_nid - Notification Id
--   p_new_user - User to whom the Question is Transferred
--   p_comment - Comment text while Transfer Request MorInformation
--   p_wl_user - Worklist user to whom the notfication belongs, in case a proxy is acting
--   p_action_source - Source from where the call is made. Could be null or 'WA'
--   p_count - Count used for recursive calls when there are vacation rules set recursively
--   p_routing_rule_user - User for which Routing rule is present.
--
procedure TransferMoreInfo(p_nid      in number,
                        p_new_user in varchar2,
                        p_comment  in varchar2,
                        p_wl_user  in varchar2,
                        p_action_source in varchar2,
                        p_count      in number,
                        p_routing_rule_user in varchar2)
is
    resource_busy exception;
    pragma exception_init(resource_busy, -00054);


    l_session_user   varchar2(320);
    l_session_user_display   varchar2(360);
    l_routing_rule_user_display varchar2(360);
    l_from_role  varchar2(320);
    l_messageType    varchar2(8);
    l_messageName    varchar2(30);
    l_groupId        number;

    l_parameterlist  wf_parameter_list_t := wf_parameter_list_t();
    l_mail_preference   varchar2 (8);
    l_callback_function             varchar2(240);
    l_context varchar2(2000);
    l_anon_block varchar2(2000);
    tvalue varchar2(4000);
    nvalue number ;
    dvalue date ;
    l_charcheck boolean;

    l_recip_role  varchar2(320);
    l_orig_recip_role  varchar2(320);
    l_more_info_role  varchar2(320);
    l_dummy varchar2(1);

    l_language  varchar2(30);
    role_info_tbl  wf_directory.wf_local_roles_tbl_type;

    l_event_name varchar2(240);

begin

    -- Framework has control of a session.
    -- We are not allowed to re-validate a session any more.  So we cannot
    -- use wfa_sec.GetSession() directly.
    l_session_user := wfa_sec.GetFWKUserName;

    -- Set the global context variables to appropriate values for this mode
    if (p_action_source = 'WA') then
        -- Action is performed by a proxy on behalf of p_wl_user.
        g_context_proxy := l_session_user;
        g_context_user  := TransferMoreInfo.p_wl_user;
        l_session_user      := TransferMoreInfo.p_wl_user;
    else
        -- Action is performed by the recipient of the notification
        g_context_proxy := null;
        g_context_user  := l_session_user;
    end if;

    l_session_user_display := Wf_Directory.GetRoleDisplayName(l_session_user);
    g_context_user_comment := TransferMoreInfo.p_comment;

    --Get the callback function
    SELECT callback, context, recipient_role, original_recipient,
           more_info_role ,from_role, message_type, message_name
    into   l_callback_function, l_context,l_recip_role , l_orig_recip_role,
           l_more_info_role, l_from_role, l_messageType, l_messageName
    FROM   wf_notifications
    WHERE  notification_id  = p_nid;

    -- Setting the Global Context Variables here
    g_context_recipient_role := g_context_user;
    g_context_original_recipient:= l_orig_recip_role;
    g_context_from_role := l_from_role;
    --The new role will be different for 'ANSWER mode
    --we overwrite it there.
    g_context_new_role  := p_new_user;
    g_context_more_info_role  := l_more_info_role;

    -- If we are in a different Fwk session, need to clear Workflow PLSQL state
    if (not Wfa_Sec.CheckSession) then
        Wf_Global.Init;
    end if;

    if (l_session_user = p_new_user) then
        --If the current user is the same as the one from
        --whom more-info is requested then raise the error
        --that you cannot ask for more info from yourself.
        wf_core.token('USER',p_new_user);
        wf_core.raise('WFNTF_INVALID_MOREINFO_REQUEST');
    else
        -- Check if anyone else is updating the row
        begin
            select MORE_INFO_ROLE
            into l_from_role
            from WF_NOTIFICATIONS
            where NOTIFICATION_ID = p_nid
            for update nowait;
        exception
            when NO_DATA_FOUND then
                null;
            when resource_busy then
                wf_core.raise('WFNTF_BEING_UPDATED');
                -- ### This notification is being updated currently, please
                -- ### try again in a brief moment.
        end;

        if (l_callback_function is not null) then
            tvalue := l_session_user;
            nvalue := p_nid;
            l_charcheck := wf_notification_util.CheckIllegalChar(l_callback_function);
            l_anon_block := 'begin '||l_callback_function||
            '(:p1, :p2, :p3, :p4, :p5, :p6, :p7); end;';

            execute immediate l_anon_block using
            in 'QUESTION',
            in l_context,
            in l_dummy,
            in l_dummy,
            in out tvalue,
            in out nvalue,
            in out dvalue;

        end if;

        -- get mail preference of the user who will respond with more information
        l_mail_preference := wf_notification.GetMailPreference (p_new_user, null, null);

        -- if there is a valid session, then we can update the FROM_ROLE
        -- and FROM_USER accurately.

        -- If there is a transfer action due to a vacation rule
        -- then we set the FROM_ROLE as the user for which there is a
        --routing rule
        if (p_routing_rule_user is not null) then
            l_routing_rule_user_display := Wf_Directory.GetRoleDisplayName(p_routing_rule_user);
            update WF_NOTIFICATIONS
            set MORE_INFO_ROLE = p_new_user,
            FROM_USER = l_routing_rule_user_display,
            FROM_ROLE = p_routing_rule_user,
            SENT_DATE = SYSDATE,
            MAIL_STATUS = decode (l_mail_preference, 'QUERY', '',
            'SUMMARY', '',
            'SUMHTML','',
            'DISABLED', 'FAILED',
            null, '', 'MAIL')
            where NOTIFICATION_ID = p_nid;
            Wf_Notification.SetComments(p_nid, p_routing_rule_user, p_new_user, 'TRANSFER_QUESTION', p_action_source, substrb(p_comment,1,4000));
        else
            if (l_session_user is not null) then
                update WF_NOTIFICATIONS
                set MORE_INFO_ROLE = p_new_user,
                FROM_USER = l_session_user_display,
                FROM_ROLE = l_session_user,
                SENT_DATE = SYSDATE,
                MAIL_STATUS = decode (l_mail_preference, 'QUERY', '',
                'SUMMARY', '',
                'SUMHTML','',
                'DISABLED', 'FAILED',
                null, '', 'MAIL')
                where NOTIFICATION_ID = p_nid;

            -- otherwise, we default to what it should be.  Unfortunately, if it
            -- is a group role, we will not be able to identify which member I am.
            else
                update WF_NOTIFICATIONS
                set MORE_INFO_ROLE = p_new_user,
                FROM_USER = TO_USER,
                FROM_ROLE = RECIPIENT_ROLE,
                SENT_DATE = SYSDATE,
                MAIL_STATUS = decode (l_mail_preference, 'QUERY', '',
                'SUMMARY', '',
                'SUMHTML','',
                'DISABLED', 'FAILED',
                null, '', 'MAIL')
                where NOTIFICATION_ID = p_nid;
            end if;
            Wf_Notification.SetComments(p_nid, l_session_user, p_new_user, 'TRANSFER_QUESTION', p_action_source, substrb(p_comment,1,4000));
        end if;

        --Calling RouteMoreInfo API to check whether there are any Routing rules for the recipient
        -- implement the loop recursively
        if (p_count > wf_notification.max_forward) then
            -- it means max_forward must have been exceeded.  Treat as a loop error.
            wf_core.token('NID', to_char(p_nid));
            wf_core.raise('WFNTF_ROUTE_LOOP');
        end if;
        wf_notification.RouteMoreInfo(p_nid, p_wl_user, p_action_source, p_count);
    end if;

    -- if we are here, mean we are going to raise
    -- oracle.apps.wf.notification.question event.
    l_event_name := 'oracle.apps.wf.notification.question';

    -- Need to make clob_exists null so that GetFullBody reads the
    -- notification entirely
    wf_notification.clob_exists := null;

    -- To raise an EVENT whenever DML operation is performed on
    -- WF_NOTIFICATIONS and WF_NOTIFICATION_ATTRIBUTES table.
    wf_event.AddParameterToList('NOTIFICATION_ID', p_nid, l_parameterlist);
    wf_event.AddParameterToList('ROLE', p_new_user, l_parameterlist);
    wf_event.AddParameterToList('GROUP_ID', nvl(l_groupId, p_nid), l_parameterlist);
    wf_event.addParameterToList('Q_CORRELATION_ID', l_messageType||':'||
    l_messageName, l_parameterlist);


    Wf_Directory.GetRoleInfo2(l_recip_role, role_info_tbl);
    l_language := role_info_tbl(1).language;

    select code into l_language from wf_languages where nls_language = l_language;

    -- AppSearch
    wf_event.AddParameterToList('OBJECT_NAME',
    'oracle.apps.fnd.wf.worklist.server.AllNotificationsVO', l_parameterlist);
    wf_event.AddParameterToList('CHANGE_TYPE', 'INSERT',l_parameterlist);
    wf_event.AddParameterToList('ID_TYPE', 'PK', l_parameterlist);
    wf_event.addParameterToList('PK_NAME_1', 'NOTIFICATION_ID',l_parameterlist);
    wf_event.addParameterToList('PK_VALUE_1', p_nid, l_parameterlist);
    wf_event.addParameterToList('PK_NAME_2', 'LANGUAGE',l_parameterlist);
    wf_event.addParameterToList('PK_VALUE_2', l_language, l_parameterlist);

    wf_event.Raise(p_event_name => l_event_name,
    p_event_key  => to_char(p_nid),
    p_parameters => l_parameterlist);

    -- Raise the push approvals event if the item type and message name exists in wf_wl_config_types table
    RaisePushNotificationEvent(p_new_user, l_messageType, l_messageName, p_nid, false);

exception
    when OTHERS then
    Wf_Core.Context('Wf_Notification', 'TransferMoreInfo', to_char(p_nid), p_new_user, p_wl_user, p_action_source);
    raise;
end TransferMoreInfo;

--
-- Route Request Information
--

--
-- RouteMoreInfo
-- This API checks whether there is any Routing rule defined for a user
-- and transfers the Request More Information if there is one by calling
-- TransferMoreInfo API recursively.
-- IN
--   p_nid - Notification Id
--   p_wl_user - Worklist user to whom the notfication belongs, in case a proxy is acting
--   p_action_source - Source from where the call is made. Could be null or 'WA'
--   p_count - Count used for recursive calls when there are vacation rules set recursively
--
procedure RouteMoreInfo(p_nid      in number,
                    p_wl_user  in varchar2,
                    p_action_source in varchar2,
                    p_count      in number)
is
    resource_busy exception;
    pragma exception_init(resource_busy, -00054);

    l_messageType    varchar2(8);
    l_messageName    varchar2(30);
    l_recip_role  varchar2(320);
    l_more_info_role  varchar2(320);
    l_more_info_role_display varchar2(320);
    l_mail_preference   varchar2 (8);

    -- Used for Vacation Rule
    l_ruleAction varchar2(8);
    l_newRole    varchar2(2000);
    l_sysComment varchar2(320);

    CURSOR rulecurs is
    select action, action_argument
    from wf_routing_rules
    where role = l_more_info_role
    and   nvl(message_type, l_messageType) = l_messageType
    and   nvl(message_name,l_messageName) = l_messageName
    and sysdate between nvl(begin_date, sysdate-1) and
                nvl(end_date, sysdate+1);

    begin

    -- Getting information pertaining to this NID
    select recipient_role, more_info_role, message_type, message_name
    into l_recip_role , l_more_info_role, l_messageType, l_messageName
    FROM wf_notifications
    WHERE notification_id  = p_nid;

    open rulecurs;
        fetch rulecurs INTO l_ruleAction,l_newRole;
        if rulecurs%NOTFOUND then
            l_ruleAction := 'NOOP';
        end if;
    close rulecurs;

    -- If there is a vacation rule defined to Reassign a notification
    if l_ruleAction IN ('FORWARD','TRANSFER') then
        if l_newRole = p_wl_user then
            wf_core.token('USER',p_wl_user);
            wf_core.raise('WFNTF_INVALID_MOREINFO_REQUEST');
        elsif l_newRole = l_recip_role then
            wf_core.token('USER',l_recip_role);
            wf_core.raise('WFNTF_INVALID_MOREINFO_REQUEST');
        else
            -- Routing rule defined
            wf_core.token('ROLE', WF_Directory.GetRoleDisplayName(l_newRole));
            l_sysComment := wf_core.translate('WFNTF_AUTO_RESPONSE_TO_ROLE');

            -- implement the above loop recursively
            if (p_count > wf_notification.max_forward) then
                -- it means max_forward must have been exceeded.  Treat as a loop error.
                wf_core.token('NID', to_char(p_nid));
                wf_core.raise('WFNTF_ROUTE_LOOP');
            end if;
            --Call to TransferMorInfo to implement Transfer Request Information
            -- as per the vacation rule
            TransferMoreInfo(p_nid, l_newRole, l_sysComment, p_wl_user, p_action_source, p_count+1, l_more_info_role);
        end if;
    else
        if l_ruleAction = 'RESPOND' then -- if there is a vacation rule for Response
            l_sysComment := wf_core.translate('WFNTF_AUTO_RESPONSE');
            l_more_info_role_display := Wf_Directory.GetRoleDisplayName(l_more_info_role);
            -- get mail preference of the user who will respond with more information
            l_mail_preference := wf_notification.GetMailPreference (l_recip_role, null, null);

            update WF_NOTIFICATIONS
            set FROM_USER = l_more_info_role_display,
                FROM_ROLE = l_more_info_role,
                MORE_INFO_ROLE = null,
                SENT_DATE = SYSDATE,
                MAIL_STATUS = decode (l_mail_preference, 'QUERY', '',
                             'SUMMARY', '',
                             'SUMHTML','',
                             'DISABLED', 'FAILED',
                              null, '', 'MAIL')
            where NOTIFICATION_ID = p_nid;

            Wf_Notification.SetComments(p_nid, l_more_info_role, l_recip_role, 'ANSWER', p_action_source, substrb(l_sysComment,1,4000));
        end if;
    end if;

exception
    when OTHERS then
    Wf_Core.Context('Wf_Notification', 'RouteMoreInfo', to_char(p_nid), l_newRole, p_wl_user, p_action_source);
    raise;
end RouteMoreInfo;

-- bug 2474562
-- deprecate - this api is no longer needed, keeps this for reference only
--
-- IsValidInfoRole
--   Check to see if a role is a participant so far
function IsValidInfoRole(nid      in number,
                         username in varchar2)
return boolean
is
  itype varchar2(30);
  ikey  varchar2(240);
  ans   number;
begin
  begin
    -- 99% of the case, it should be found in WIAS
    select ITEM_TYPE, ITEM_KEY
      into itype, ikey
      from WF_ITEM_ACTIVITY_STATUSES
     where NOTIFICATION_ID = nid;
  exception
    when NO_DATA_FOUND then
      begin
        -- rarely the nid is from WIASH, but just in case
        select ITEM_TYPE, ITEM_KEY
          into itype, ikey
          from WF_ITEM_ACTIVITY_STATUSES_H
         where NOTIFICATION_ID = nid;
      exception
        when NO_DATA_FOUND then
          -- Notification only
          begin
            select NULL, '#SYNCH'
              into itype, ikey
              from WF_NOTIFICATIONS
             where NOTIFICATION_ID = nid;
          exception
             when OTHERS then
               return(FALSE);
          end;
        when OTHERS then
          return(FALSE);
      end;
    when OTHERS then
      return(FALSE);
  end;

  -- check if this is item owner
  begin
    select 1 into ans
      from WF_ITEMS
     where ITEM_TYPE = itype
       and ITEM_KEY  = ikey
       and OWNER_ROLE = IsValidInfoRole.username;

    return(TRUE);
  exception
    when NO_DATA_FOUND then
      null;
  end;

  if (itype is null and ikey = '#SYNCH') then
    -- this is notification only
    begin
      select 1 into ans
        from WF_NOTIFICATIONS
       where IsValidInfoRole.username in (RECIPIENT_ROLE, ORIGINAL_RECIPIENT)
         and NOTIFICATION_ID = nid;
    exception
      when NO_DATA_FOUND then
        return(FALSE);
    end;
  else
    -- this is notification from a flow
    begin
      -- NOTE
      -- The following sql is suggested by Deb in the performance team
      -- it uses the index on group_id which is much more selective
      -- than those on recipient_role or original_recipient.
      -- Even though the explain plan seems to indicate a high cost, the
      -- run time performance on volumn database is much better.
      select 1 into ans
      from (
      select  /*+  leading(grp_id_view)  */
             RECIPIENT_ROLE , ORIGINAL_RECIPIENT
             from WF_NOTIFICATIONS a ,
                      ( select notification_id group_id
                         from WF_ITEM_ACTIVITY_STATUSES
                         where item_type = itype
                         and item_key = ikey
                         union all
                         select notification_id group_id
                         from WF_ITEM_ACTIVITY_STATUSES_H
                         where item_type = itype
                         and item_key = ikey
                       )  grp_id_view
           where grp_id_view.group_id = a.group_id
         )  recipient_view
      where (recipient_view.RECIPIENT_ROLE = IsValidInfoRole.username
             or recipient_view.ORIGINAL_RECIPIENT = IsValidInfoRole.username)
        and rownum < 2;
    exception
      when NO_DATA_FOUND then
        return(FALSE);
    end;
  end if;
  return(TRUE);
exception
  when OTHERS then
    Wf_Core.Context('Wf_Notification','IsValidInfoRole',to_char(nid),username);
    raise;
end IsValidInfoRole;

-- UpdateInfo2 - bug 2282139
--   non-null username - Ask this user for more information
--   null username - Reply to the inquery
--   from email - from email id of responder/requestor
--   comment -  could be question or answer
-- NOTE:
--   This is a WF Mailer specific API. Used when a user requests more info
--   or provides info through email response.
--
procedure UpdateInfo2(nid        in number,
                      username   in varchar2,
                      from_email in varchar2,
                      comment    in varchar2)
is
  resource_busy exception;
  pragma exception_init(resource_busy, -00054);

  l_from_role      varchar2(320);
  replyby          varchar2(320);
  myusername       varchar2(320);
  mydispname       varchar2(360);
  l_messageType    varchar2(8);
  l_messageName    varchar2(30);
  l_groupId        number;
  l_parameterlist  wf_parameter_list_t := wf_parameter_list_t();
  role_info_tbl wf_directory.wf_local_roles_tbl_type;
  l_username       varchar2(320);
  l_stat           varchar2(8);

  --Bug 3065814
  l_recip_role  varchar2(320);
  l_orig_recip_role  varchar2(320);
  l_more_info_role  varchar2(320);
  cb             varchar2(240);
  context varchar2(2000);
  sqlbuf varchar2(2000);
  tvalue varchar2(4000);
  nvalue number;
  dvalue date;
  l_question_role   varchar2(320);
  l_found boolean;
  l_dummy varchar2(1);
  -- Bug 3827935
  l_charcheck boolean;
  l_language  varchar2(30);
  --Bug 6164116
  l_ruleAction varchar2(8);
  l_newRole    varchar2(2000);
  l_sysComment varchar2(320);
  cnt number := 1; --Used to call UpdateInfo() for the first time, that means one time.

  CURSOR rulecurs is
    select action, action_argument
    from wf_routing_rules
    where role = username
    and   nvl(message_type, l_messageType) = l_messageType
    and   nvl(message_name,l_messageName) = l_messageName
    and sysdate between nvl(begin_date, sysdate-1) and
                        nvl(end_date, sysdate+1);
  -- bug 7130745
  l_event_name varchar2(240);

begin
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_NOTIFICATION.UpdateInfo2.Begin',
                      'NID: '||to_char(nid) ||', Username: '||username||
                      ' From: '||from_email);
  end if;

  -- Get notification related information
  SELECT callback, context, recipient_role, original_recipient,
         more_info_role, from_role, status, message_type, message_name
  INTO   cb, context, l_recip_role, l_orig_recip_role,
         l_more_info_role, l_from_role, l_stat, l_messageType, l_messageName
  FROM   wf_notifications
  WHERE  notification_id  = nid;

  -- Donot process the request if the notification is not open.
  if (l_stat <> 'OPEN') then
     if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_statement,
                         'wf.plsql.WF_NOTIFICATION.UpdateInfo2.not_open',
                         'Notification '||to_char(nid)||' is not OPEN. Returning.');
     end if;
     return;
  end if;

  -- mailer doesnot have a valid user session. need to get
  -- the user name based on the from_email
  if (username is not null) then
    GetUserfromEmail(from_email, l_recip_role, myusername, mydispname, l_found);
  else
    GetUserfromEmail(from_email, l_more_info_role, myusername, mydispname, l_found);
  end if;
  if (l_found) then
     g_context_user  := myusername;
  else
     g_context_user  := 'email:' || myusername;
  end if;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_NOTIFICATION.UpdateInfo2.got_user',
                      'Email: '||from_email||' User: '||myusername||' DispName: '||mydispname);
  end if;

  --Bug 3065814
  --Set the global context variables to appropriate values for this mode
  g_context_user_comment := updateinfo2.comment;
  g_context_recipient_role := l_recip_role;
  g_context_original_recipient:= l_orig_recip_role;
  g_context_from_role := l_from_role;

  -- The new role will be different for 'ANSWER mode we overwrite it there.
  g_context_new_role  := username;
  g_context_more_info_role  := l_more_info_role;

  -- question mode
  if (username is not null) then

    -- Check if the question is asked to a valid role
    --  i. The role should be valid within WF Directory Service.
    -- ii. We might also want to check if the user is a participant of the ntf??

    wf_directory.GetRoleInfo2(username, role_info_tbl);
    l_username := role_info_tbl(1).name;

    -- Check if it is a Display Name
    if (l_username is NULL) then
      begin
        SELECT name
        INTO   l_username
        FROM   wf_role_lov_vl
        WHERE  upper(display_name) = upper(username)
        AND    rownum = 1;
      exception
        when NO_DATA_FOUND then
           wf_core.token('ROLE', username);
           wf_core.raise('WFNTF_ROLE');
      end;
    end if;

    -- If the username was specified as display name, l_username would have the internal name
    if (l_username in (myusername, l_recip_role)) then
      -- If the current user is the same as the one from whom more-info is requested
      -- requested then raise the error that you cannot ask for more info from yourself.
      wf_core.token('USER',username);
      wf_core.raise('WFNTF_INVALID_MOREINFO_REQUEST');
    else
      open rulecurs;
      fetch rulecurs INTO l_ruleAction,l_newRole;
      if rulecurs%NOTFOUND then
        l_ruleAction := 'NOOP';
      end if;
      close rulecurs;

      if l_ruleAction IN ('FORWARD','TRANSFER') then
        if l_newRole = myusername then
           wf_core.token('USER',myusername);
           wf_core.raise('WFNTF_INVALID_MOREINFO_REQUEST');
        elsif l_newRole = l_recip_role then
          wf_core.token('USER',l_recip_role);
          wf_core.raise('WFNTF_INVALID_MOREINFO_REQUEST');
        else
          -- Routing rule defined
          wf_core.token('ROLE', WF_Directory.GetRoleDisplayName(l_newRole));
          l_sysComment := wf_core.translate('WFNTF_AUTO_RESPONSE_TO_ROLE');
          if myusername is not null then
            wf_notification.SetComments(nid, username, myusername, 'ANSWER', 'EMAIL', l_sysComment); --ER Bug 27224517: Approvals Source Tracking for Mobile Approval App
          else
            wf_notification.SetComments(nid, username, l_recip_role, 'ANSWER', 'EMAIL', l_sysComment); --ER Bug 27224517: Approvals Source Tracking for Mobile Approval App
          end if;

          /* implement the above loop recursively */
          if (cnt > wf_notification.max_forward) then
            -- it means max_forward must have been exceeded.  Treat as a loop error.
            wf_core.token('NID', to_char(nid));
            wf_core.raise('WFNTF_ROUTE_LOOP');
          end if;
          -- Better to call UpdateInfo. Use myusername instead of wl_user because myusername is the user associated to the responding e-mail address
          UpdateInfo(nid,l_newRole,g_context_user_comment,myusername,null, cnt);
        end if;
      else

        if l_ruleAction = 'RESPOND' then
          l_sysComment := wf_core.translate('WFNTF_AUTO_RESPONSE');
          if myusername is not null then
            wf_notification.SetComments(nid, username, myusername, 'ANSWER', 'EMAIL', l_sysComment); --ER Bug 27224517: Approvals Source Tracking for Mobile Approval App
          else
            wf_notification.SetComments(nid, username, l_recip_role, 'ANSWER', 'EMAIL', l_sysComment); --ER Bug 27224517: Approvals Source Tracking for Mobile Approval App
          end if;
        end if;

        -- do not want it hung when some one is doing update.
        begin
          select MORE_INFO_ROLE, MESSAGE_TYPE, MESSAGE_NAME, GROUP_ID
          into l_from_role, l_messageType, l_messageName, l_groupId
          from WF_NOTIFICATIONS
          where NOTIFICATION_ID = nid
          for update nowait;
        exception
          when NO_DATA_FOUND then
            null;
          when resource_busy then
            wf_core.raise('WFNTF_BEING_UPDATED');
        end;

        if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string(wf_log_pkg.level_statement,
                            'wf.plsql.WF_NOTIFICATION.UpdateInfo2.question',
                            'Updating QUESTION');
        end if;

        if (cb is not null) then
          tvalue := myusername;
          nvalue := nid;
          -- ### Review Note 2 - cb is from table
          -- Check for bug#3827935
          l_charcheck := wf_notification_util.CheckIllegalChar(cb);
          --Throw the Illegal exception when the check fails

          -- BINDVAR_SCAN_IGNORE
          sqlbuf := 'begin '||cb||
                  '(:p1, :p2, :p3, :p4, :p5, :p6, :p7); end;';
          execute immediate sqlbuf using
           in 'QUESTION',
           in context,
           in l_dummy,
           in l_dummy,
           in out tvalue,
           in out nvalue,
           in out dvalue;

        end if;

        -- as we donot have a user session for the mailer, the only way to
        -- find FROM_ROLE and FROM_USER are through the from_addr. If the
        -- user name and display name are not available, email address is updated
        /* if (myusername is not null) then
             update WF_NOTIFICATIONS
             set MORE_INFO_ROLE = username,
             FROM_USER = mydispname,
             FROM_ROLE = myusername
             where NOTIFICATION_ID = nid;

        -- otherwise, we default to what it should be.  Unfortunately, if it
        -- is a group role, we will not be able to identify which member I am.
        else */
        update WF_NOTIFICATIONS
        set MAIL_STATUS = 'MAIL',
            MORE_INFO_ROLE = l_username,
            FROM_USER = TO_USER,
            FROM_ROLE = RECIPIENT_ROLE,
            SENT_DATE = SYSDATE
        where NOTIFICATION_ID = nid;
        /*end if; */

        Wf_Notification.SetComments(nid, myusername, l_username, 'QUESTION', 'EMAIL', substrb(comment,1,4000)); --ER Bug 27224517: Approvals Source Tracking for Mobile Approval App
        Wf_Notification.Route(nid, 0);

        -- LANGUAGE here is for FROM_USER which came from WF_NOTIFICATIONS above
        -- insert into WF_COMMENTS (
        --    NOTIFICATION_ID,
        --    FROM_ROLE,
        --    FROM_USER,
        --    COMMENT_DATE,
        --    ACTION,
        --    USER_COMMENT,
        --    LANGUAGE
        --  )
        --  select NOTIFICATION_ID,
        --         FROM_ROLE,
        --         FROM_USER,
        --         sysdate,
        --         'QUESTION',
        --         substrb(comment,1,4000),
        --         LANGUAGE
        --    from WF_NOTIFICATIONS
        --   where NOTIFICATION_ID = nid;
      end if;
    end if;

    -- <<sstomar: bug 7130745>>
    --  we are here, mean we are going to raise
    --  oracle.apps.wf.notification.question event.
    l_event_name := 'oracle.apps.wf.notification.question';

  -- answer mode
  -- NOTE: the language here is the language of the MORE_INFO_ROLE,
  --       no denormalization is needed here.
  else
    -- Do not allow reply when a question has not been asked, or it has
    -- already been answered.  In both cases, MORE_INFO_ROLE is set to null.
    -- Also acquire a row lock, so that we do not let multiple people to
    -- answer at the same time.
    begin
      select MORE_INFO_ROLE, Wf_Directory.GetRoleDisplayName(MORE_INFO_ROLE),
             MESSAGE_TYPE, MESSAGE_NAME, GROUP_ID , from_role
        into l_from_role, replyby, l_messageType, l_messageName, l_groupId, l_question_role
        from WF_NOTIFICATIONS
       where NOTIFICATION_ID = nid
         and MORE_INFO_ROLE is not null
         for update nowait;

    exception
      when NO_DATA_FOUND then
        -- if it has no row, we cannot reply to this notification
        -- ### You cannot reply to a question that has not been asked
        -- ### or has already been answered.
         WF_MAIL.SendMoreInfoResponseWarning(nid,from_email);
        return;
      when resource_busy then
        wf_core.raise('WFNTF_BEING_UPDATED');
    end;

    -- we donot validate the role, it may be email address. we donot want
    -- FROM_ROLE and FROM_USER to be NULL.
    l_from_role := myusername;
    replyby := mydispname;
    if (cb is not null) then
      tvalue := myusername;
      nvalue := nid;
      g_context_new_role := l_question_role;
      -- ### Review Note 2 - cb is from table
      -- BINDVAR_SCAN_IGNORE
      sqlbuf := 'begin '||cb||
                '(:p1, :p2, :p3, :p4, :p5, :p6, :p7); end;';
      execute immediate sqlbuf using
        in 'ANSWER',
        in context,
        in l_dummy,
        in l_dummy,
        in out tvalue,
        in out nvalue,
        in out dvalue;

    end if;

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_NOTIFICATION.UpdateInfo2.answer',
                        'Updating ANSWER');
    end if;

    update WF_NOTIFICATIONS
       set MAIL_STATUS = 'MAIL',
           FROM_USER = replyby,
           FROM_ROLE = l_from_role,
           MORE_INFO_ROLE = null,
           SENT_DATE = SYSDATE
       where NOTIFICATION_ID = nid;

    Wf_Notification.SetComments(nid, myusername, l_recip_role, 'ANSWER', 'EMAIL', substrb(comment,1,4000)); --ER Bug 27224517: Approvals Source Tracking for Mobile Approval App

    -- LANGUAGE here is for FROM_USER which came from GetRoleDisplayName above,
    -- so the LANGUAGE should be current userenv('LANG').
    -- insert into WF_COMMENTS (
    --      NOTIFICATION_ID,
    --      FROM_ROLE,
    --      FROM_USER,
    --      COMMENT_DATE,
    --      ACTION,
    --      USER_COMMENT,
    --      LANGUAGE
    --    )
    --    select NOTIFICATION_ID,
    --           FROM_ROLE,
    --           FROM_USER,
    --           sysdate,
    --           'ANSWER',
    --           substrb(comment,1,4000),
    --           userenv('LANG')
    --      from WF_NOTIFICATIONS
    --     where NOTIFICATION_ID = nid;

    -- we are here, mean we are going to raise
    -- oracle.apps.wf.notification.answer event.
    l_event_name := 'oracle.apps.wf.notification.answer';

  end if;  -- End of Answer mode

  -- Send the notification through email
  -- Enqueuing has been moved to a subscription for forward
  -- compatability. The subscription need only be enabled to use
  -- the older mailer. The subscription will call the
  -- wf_xml.EnqueueNotification(nid);

  -- Bug 2283697
  -- To raise an EVENT whenever DML operation is performed on
  -- WF_NOTIFICATIONS and WF_NOTIFICATION_ATTRIBUTES table.
  wf_event.AddParameterToList('NOTIFICATION_ID', nid, l_parameterlist);

  -- username MAY be a display name
  wf_event.AddParameterToList('ROLE',  nvl(l_username, username), l_parameterlist);
  wf_event.AddParameterToList('GROUP_ID', nvl(l_groupId, nid), l_parameterlist);
  wf_event.addParameterToList('Q_CORRELATION_ID', l_messageType||':'||
                              l_messageName, l_parameterlist);

  Wf_Directory.GetRoleInfo2(l_recip_role, role_info_tbl);
  l_language := role_info_tbl(1).language;

  select code into l_language from wf_languages where nls_language = l_language;


  -- AppSearch
  wf_event.AddParameterToList('OBJECT_NAME',
  'oracle.apps.fnd.wf.worklist.server.AllNotificationsVO', l_parameterlist);
  wf_event.AddParameterToList('CHANGE_TYPE', 'INSERT',l_parameterlist);
  wf_event.AddParameterToList('ID_TYPE', 'PK', l_parameterlist);
  wf_event.addParameterToList('PK_NAME_1', 'NOTIFICATION_ID',l_parameterlist);
  wf_event.addParameterToList('PK_VALUE_1', nid, l_parameterlist);
  wf_event.addParameterToList('PK_NAME_2', 'LANGUAGE',l_parameterlist);
  wf_event.addParameterToList('PK_VALUE_2', l_language, l_parameterlist);


  -- Raise the event
  -- wf_event.Raise(p_event_name => 'oracle.apps.wf.notification.send',
  --               p_event_key  => to_char(nid),
  --               p_parameters => l_parameterlist);

  -- <<sstomar: bug 7130745 : use different event names for question and answer >>
  wf_event.Raise(p_event_name => l_event_name,
                 p_event_key  => to_char(nid),
                 p_parameters => l_parameterlist);

exception
  when OTHERS then
    Wf_Core.Context('Wf_Notification', 'UpdateInfo2', to_char(nid), username, from_email);
    raise;
end UpdateInfo2;


-- UpdateInfoGuest:
--                   Called for updating more info when access key is present,
--                   responder to the request more info role as the user
--                   is trying to respond to Request More Info as GUEST user
--                   via E-mail without logging in.
--   responder      - Responder to the request more info
--   moreinfoanswer - answer to request more information
--
procedure UpdateInfoGuest(nid                in number,
                          moreinforesponder  in varchar2 default null,
                          moreinfoanswer     in varchar2 default null)
is
  resource_busy exception;
  pragma exception_init(resource_busy, -00054);

  l_from_role      varchar2(320);
  l_recipient_role varchar2(320);
  replyby          varchar2(320);
  l_messageType    varchar2(8);
  l_messageName    varchar2(30);
  l_groupId        number;
  l_parameterlist  wf_parameter_list_t := wf_parameter_list_t();

  l_more_info_role  varchar2(320);
  cb             varchar2(240);
  context varchar2(2000);
  sqlbuf varchar2(2000);
  tvalue varchar2(4000);
  nvalue number;
  dvalue date;
  l_question_role   varchar2(320);
  l_dummy varchar2(1);
  l_orig_recip_role varchar2(320);
  l_language        varchar2(30);
  role_info_tbl  wf_directory.wf_local_roles_tbl_type;

begin
  wf_log_pkg.string(WF_LOG_PKG.LEVEL_STATEMENT, 'WF_NOTIFICATION.UpdateInfoGuest',
                        'NID: '||to_char(nid));

  -- Do not allow reply when a question has not been asked, or it has
  -- already been answered.  In both cases, MORE_INFO_ROLE is set to null.
  -- Also acquire a row lock, so that we do not let multiple people to
  -- answer at the same time.
  begin
    select ORIGINAL_RECIPIENT, RECIPIENT_ROLE, MORE_INFO_ROLE,
           Wf_Directory.GetRoleDisplayName(MORE_INFO_ROLE),
           MESSAGE_TYPE, MESSAGE_NAME, GROUP_ID , from_role, callback, context
      into l_orig_recip_role, l_recipient_role, l_from_role,
           replyby, l_messageType, l_messageName, l_groupId, l_question_role, cb, context
      from WF_NOTIFICATIONS
     where NOTIFICATION_ID = nid
       and MORE_INFO_ROLE is not null
       for update nowait;

    --Bug 3924931
    --Set the global context variables to appropriate values for this mode
    g_context_user := updateinfoguest.moreinforesponder;
    g_context_user_comment := updateinfoguest.moreinfoanswer;
    g_context_new_role  := l_question_role;
    g_context_recipient_role := l_recipient_role;
    g_context_original_recipient:= l_orig_recip_role;
    g_context_from_role := l_question_role;
    g_context_more_info_role  := l_from_role;

  exception
    when NO_DATA_FOUND then
      -- if it has no row, we cannot reply to this notification
      wf_core.raise('WFNTF_CANNOT_REPLY');
      -- ### You cannot reply to a question that has not been asked
      -- ### or has already been answered.

    when resource_busy then
      wf_core.raise('WFNTF_BEING_UPDATED');
  end;

  if (cb is not null) then
    tvalue := moreinforesponder;
    nvalue := nid;
    -- ### Note 2 - cb is from table
    -- BINDVAR_SCAN_IGNORE
    sqlbuf := 'begin '||cb||
              '(:p1, :p2, :p3, :p4, :p5, :p6, :p7); end;';
    execute immediate sqlbuf using
      in 'ANSWER',
      in context,
      in l_dummy,
      in l_dummy,
      in out tvalue,
      in out nvalue,
      in out dvalue;

  end if;


  wf_log_pkg.string(WF_LOG_PKG.LEVEL_STATEMENT, 'WF_NOTIFICATION.UpdateInfoGuest',
                   'Updating ANSWER');

  update WF_NOTIFICATIONS
     set MAIL_STATUS = 'MAIL',
         FROM_USER = moreinforesponder,
         FROM_ROLE = moreinforesponder,
         MORE_INFO_ROLE = null,
         SENT_DATE = SYSDATE
   where NOTIFICATION_ID = nid;

  Wf_Notification.SetComments(nid, moreinforesponder, l_recipient_role, 'ANSWER', null, substrb(moreinfoanswer,1,4000));

  -- Send the notification through email
  -- Enqueuing has been moved to a subscription for forward
  -- compatability. The subscription need only be enabled to use
  -- the older mailer. The subscription will call the
  -- wf_xml.EnqueueNotification(nid);

  -- Bug 2283697
  -- To raise an EVENT whenever DML operation is performed on
  -- WF_NOTIFICATIONS and WF_NOTIFICATION_ATTRIBUTES table.
  wf_event.AddParameterToList('NOTIFICATION_ID', nid, l_parameterlist);
  -- skilaru 12-MAR-04 In UpdateInfo2 username would be null in Answer mode
  -- to keep the behaviour same just pass null as ROLE..
  wf_event.AddParameterToList('ROLE', null, l_parameterlist);
  wf_event.AddParameterToList('GROUP_ID', nvl(l_groupId, nid), l_parameterlist);
  wf_event.addParameterToList('Q_CORRELATION_ID', l_messageType||':'||
                               l_messageName, l_parameterlist);

   Wf_Directory.GetRoleInfo2(l_recipient_role, role_info_tbl);
   l_language := role_info_tbl(1).language;

   select code into l_language from wf_languages where nls_language = l_language;

  -- AppSearch
  wf_event.AddParameterToList('OBJECT_NAME',
  'oracle.apps.fnd.wf.worklist.server.AllNotificationsVO', l_parameterlist);
  wf_event.AddParameterToList('CHANGE_TYPE', 'INSERT',l_parameterlist);
  wf_event.AddParameterToList('ID_TYPE', 'PK', l_parameterlist);
  wf_event.addParameterToList('PK_NAME_1', 'NOTIFICATION_ID',l_parameterlist);
  wf_event.addParameterToList('PK_VALUE_1', nid, l_parameterlist);
  wf_event.addParameterToList('PK_NAME_2', 'LANGUAGE',l_parameterlist);
  wf_event.addParameterToList('PK_VALUE_2', l_language, l_parameterlist);


  -- Raise the event
  -- wf_event.Raise(p_event_name => 'oracle.apps.wf.notification.send',
  --               p_event_key  => to_char(nid),
  --               p_parameters => l_parameterlist);

  -- <<sstomar: bug 7130745 : use different event names for question and answer >>
  wf_event.Raise(p_event_name => 'oracle.apps.wf.notification.answer',
                 p_event_key  => to_char(nid),
                 p_parameters => l_parameterlist);

  -- Raise the push approvals event if the item type and message name exists in wf_wl_config_types table
  RaisePushNotificationEvent(l_recipient_role, l_messageType, l_messageName, nid, false);

exception
  when OTHERS then
    Wf_Core.Context('Wf_Notification', 'UpdateInfoGuest', to_char(nid), moreinforesponder);
    raise;
end UpdateInfoGuest;



--
-- HideMoreInfo (PUBLIC)
--   Checks the notification attribute #HIDE_MOREINFO to see if the
--   More Information request button is allowed or hidden. Just in case
--   more_info_role becomes not null with direct table update...

function HideMoreInfo(nid in number)
return varchar2
is
  l_hide  varchar2(1);
begin
  -- Get value for #HIDE_MOREINFO attribute for the notification
  begin
     l_hide := substrb(WF_NOTIFICATION.GetAttrText(nid, '#HIDE_MOREINFO'), 1, 1);
     -- Bugfix 2880029 - changed sacsharm - 03/31/03
     -- Only if attribute value is explicitly 'Y' hide Request More Info. else
     -- if it is null or 'N' or any other character donot hide Request More Info.
     l_hide := upper(nvl(l_hide, 'N'));
     if (l_hide <> 'Y') then
         l_hide := 'N';
     end if;
  exception
     when others then
        -- Bugfix 2880029 - changed sacsharm - 03/31/03
        -- If attribute not defined, do not hide Request More Info.
        if (wf_core.error_name = 'WFNTF_ATTR') then
          wf_core.clear;
          l_hide := 'N';
        else
          raise;
        end if;
  end;
  return (l_hide);
exception
  when others then
     wf_core.context('Wf_Notification', 'HideMoreInfo', to_char(nid));
     raise;
end HideMoreInfo;

-- GetComments
--   Consolidates the questions and answers asked for the notification
--   Also returns the last question asked.
--   This is for the mailer to send the history with the email.
--   It assumes that the table has been already opened
-- IN
--   nid - Notification id
--   dislay_type The display type for the history
-- OUT
--   history in either text or html format
--   last asked question
procedure GetComments(nid          in  number,
                      display_type in varchar2,
                      html_history out nocopy varchar2,
                      last_ques    out nocopy varchar2)
is
  CURSOR c_ques IS
  SELECT user_comment
  FROM   wf_comments
  WHERE  notification_id = nid
  AND    action in ('QUESTION', 'QUESTION_WA', 'QUESTION_RULE')
  ORDER BY comment_date desc;
begin
  open c_ques;
  fetch c_ques into last_ques;
  if (c_ques%notfound) then
    last_ques := '';
  end if;
  close c_ques;

  -- Call the GetComments2 procedure to get the Action History for only
  -- More Info Requests. This procedure was doing that previously
  Wf_Notification.GetComments2(p_nid => nid,
                               p_display_type => display_type,
                               p_hide_reassign => 'Y',
                               p_hide_requestinfo => 'N',
                               p_action_history => html_history);

exception
  when others then
     wf_core.context('Wf_Notification', 'GetComments', to_char(nid), display_type);
     raise;
end GetComments;

--isBiDi
--Check for Language if it is Arabic or Hebrew

function isBiDi(lang in varchar2) return boolean
 is
 begin
   if upper(lang) in ('ARABIC','HEBREW') then
       return true;
   else
       return false;
    end if;
  end isBiDi;

--
-- GetComments2
--   Creates the Action History table for a given a notification id based on
--   different filter criteria.
-- IN
--   p_nid - Notification id
--   p_display_type - Display Type
--   p_action_type - Action Type to look for (REASSIGN, RESPOND, QA,...)
--   p_comment_date - Comment Date
--   p_from_role - Comment provider
--   p_to_role - Comment receiver
--   p_hide_reassign - If Reassign comments be shown or not
--   p_hide_requestinfo - If More Info request be shown or not
-- OUT
--   p_action_history - Action History table
--
procedure GetComments2(p_nid              in  number,
                       p_display_type     in  varchar2,
                       p_action_type      in  varchar2,
                       p_comment_date     in  date,
                       p_from_role        in  varchar2,
                       p_to_role          in  varchar2,
                       p_hide_reassign    in  varchar2,
                       p_hide_requestinfo in  varchar2,
                       p_action_history   out nocopy varchar2)
is
   l_user_comment varchar2(4000);
   i              pls_integer;
   j              pls_integer;
   l_pos          pls_integer;
   l_table_dir    varchar2(1);
   l_dir          varchar2(10);
   cells          tdType;
   l_result       varchar2(32000);
   l_delim        varchar2(1);
   l_note         varchar2(4000);
   l_action       varchar2(30);
   l_item_type    varchar2(8);
   l_item_key     varchar2(240);
   l_actid        number;
   l_result_type  varchar2(30);
   l_result_code  varchar2(30);
   l_action_str   varchar2(250);
   l_wf_system    varchar2(360);
   l_count        number;
   l_suppress_hist  varchar2(1);
   l_title        varchar2(250);
   l_language       VARCHAR2(30);
   l_value varchar2(64);
   l_pos1 number;

   CURSOR c_comments IS
   select rownum H_SEQUENCE,
          H_NOTIFICATION_ID,
          H_FROM_USER,
          H_TO_USER,
          H_ACTION_TYPE,
          H_ACTION,
          H_COMMENT,
          H_ACTION_DATE
   from
   (select H_SEQUENCE,
           H_NOTIFICATION_ID,
           H_FROM_USER,
           H_TO_USER,
           H_ACTION_TYPE,
           H_ACTION,
           H_COMMENT,
           H_ACTION_DATE
   from
   (select 99999999                          H_SEQUENCE,
           IAS.NOTIFICATION_ID               H_NOTIFICATION_ID,
           C.FROM_ROLE                       H_FROM_ROLE,
           C.FROM_USER                       H_FROM_USER,
           'WF_SYSTEM'                       H_TO_ROLE,
           l_wf_system                       H_TO_USER,
           A.RESULT_TYPE                     H_ACTION_TYPE,
           IAS.ACTIVITY_RESULT_CODE          H_ACTION,
           '#WF_NOTE#'                       H_COMMENT,
           nvl(IAS.END_DATE, IAS.BEGIN_DATE) H_ACTION_DATE
      from WF_ITEM_ACTIVITY_STATUSES IAS,
           WF_ACTIVITIES A,
           WF_PROCESS_ACTIVITIES PA,
           WF_ITEMS I,
           WF_COMMENTS C
      where IAS.ITEM_TYPE            = l_item_type
        and IAS.ITEM_KEY             = l_item_key
        and IAS.PROCESS_ACTIVITY     = l_actid
        and IAS.ITEM_TYPE            = I.ITEM_TYPE
        and IAS.ITEM_KEY             = I.ITEM_KEY
        and IAS.ACTIVITY_RESULT_CODE IS NOT NULL
        and IAS.ACTIVITY_RESULT_CODE not in ('#EXCEPTION', '#FORCE', '#MAIL', '#NULL', '#STUCK', '#TIMEOUT')
        and I.BEGIN_DATE             between A.BEGIN_DATE and nvl(A.END_DATE, I.BEGIN_DATE)
        and IAS.PROCESS_ACTIVITY     = PA.INSTANCE_ID
        and PA.ACTIVITY_NAME         = A.NAME
        and PA.ACTIVITY_ITEM_TYPE    = A.ITEM_TYPE
        and IAS.NOTIFICATION_ID      = C.NOTIFICATION_ID
        and C.ACTION                 in ('RESPOND', 'RESPOND_WA', 'RESPOND_RULE')
    union all
    --Bug 18252739: Get the From_role and From_user values from wf_comments table for respond
    --operation instead of WF_ITEM_ACTIVITY_STATUSES_H.ASSIGNED_USER as it will not be updated
    --with new value when notification with the expnad roles selected is TRANSFERRED to a new user
    select 99999999                          H_SEQUENCE,
           IAS.NOTIFICATION_ID               H_NOTIFICATION_ID,
           C.FROM_ROLE                       H_FROM_ROLE,
           C.FROM_USER                       H_FROM_USER,
           'WF_SYSTEM'                       H_TO_ROLE,
           l_wf_system                       H_TO_USER,
           A.RESULT_TYPE                     H_ACTION_TYPE,
           IAS.ACTIVITY_RESULT_CODE          H_ACTION,
           '#WF_NOTE#'                       H_COMMENT,
           nvl(IAS.END_DATE, IAS.BEGIN_DATE) H_ACTION_DATE
      from WF_ITEM_ACTIVITY_STATUSES_H IAS,
           WF_ACTIVITIES A,
           WF_PROCESS_ACTIVITIES PA,
           WF_ITEMS I,
           WF_COMMENTS C
      where IAS.ITEM_TYPE            = l_item_type
        and IAS.ITEM_KEY             = l_item_key
        and IAS.PROCESS_ACTIVITY     = l_actid
        and IAS.ITEM_TYPE            = I.ITEM_TYPE
        and IAS.ITEM_KEY             = I.ITEM_KEY
        and IAS.ACTIVITY_RESULT_CODE IS NOT NULL
        and IAS.ACTIVITY_RESULT_CODE not in ('#EXCEPTION', '#FORCE', '#MAIL', '#NULL', '#STUCK', '#TIMEOUT')
        and I.BEGIN_DATE             between A.BEGIN_DATE and nvl(A.END_DATE, I.BEGIN_DATE)
        and IAS.PROCESS_ACTIVITY     = PA.INSTANCE_ID
        and PA.ACTIVITY_NAME         = A.NAME
        and PA.ACTIVITY_ITEM_TYPE    = A.ITEM_TYPE
        and IAS.NOTIFICATION_ID      = C.NOTIFICATION_ID
        and C.ACTION                 in ('RESPOND', 'RESPOND_WA', 'RESPOND_RULE')
    union all
    select C.SEQUENCE        H_SEQUENCE,
           C.NOTIFICATION_ID H_NOTIFICATION_ID,
           C.FROM_ROLE       H_FROM_ROLE,
           C.FROM_USER       H_FROM_USER,
           C.TO_ROLE         H_TO_ROLE,
           C.TO_USER         H_TO_USER,
           '#WF_COMMENTS#'   H_ACTION_TYPE,
           C.ACTION          H_ACTION,
           C.USER_COMMENT    H_COMMENT,
           C.COMMENT_DATE    H_ACTION_DATE
      from WF_ITEM_ACTIVITY_STATUSES IAS,
           WF_COMMENTS C
      where IAS.ITEM_TYPE        = l_item_type
        and IAS.ITEM_KEY         = l_item_key
        and IAS.PROCESS_ACTIVITY = l_actid
        and IAS.NOTIFICATION_ID  = C.NOTIFICATION_ID
        and C.ACTION             not in ('RESPOND', 'RESPOND_WA', 'RESPOND_RULE', 'SEND')
    union all
    select C.SEQUENCE        H_SEQUENCE,
           C.NOTIFICATION_ID H_NOTIFICATION_ID,
           C.FROM_ROLE       H_FROM_ROLE,
           C.FROM_USER       H_FROM_USER,
           C.TO_ROLE         H_TO_ROLE,
           C.TO_USER         H_TO_USER,
           '#WF_COMMENTS#'   H_ACTION_TYPE,
           C.ACTION          H_ACTION,
           C.USER_COMMENT    H_COMMENT,
           C.COMMENT_DATE    H_ACTION_DATE
      from WF_ITEM_ACTIVITY_STATUSES_H IAS,
           WF_COMMENTS C
      where IAS.ITEM_TYPE        = l_item_type
        and IAS.ITEM_KEY         = l_item_key
        and IAS.PROCESS_ACTIVITY = l_actid
        and IAS.NOTIFICATION_ID  = C.NOTIFICATION_ID
        and C.ACTION             not in ('RESPOND', 'RESPOND_WA', 'RESPOND_RULE', 'SEND')
   )
   order by H_ACTION_DATE, H_NOTIFICATION_ID, H_SEQUENCE
   );

   cursor c_ntf_hist is
   select rownum H_SEQUENCE,
          H_NOTIFICATION_ID,
          H_FROM_USER,
          H_TO_USER,
          H_ACTION_TYPE,
          H_ACTION,
          H_COMMENT,
          H_ACTION_DATE
   from
   (select H_SEQUENCE,
           H_NOTIFICATION_ID,
           H_FROM_USER,
           H_TO_USER,
           H_ACTION_TYPE,
           H_ACTION,
           H_COMMENT,
           H_ACTION_DATE
   from
   (select C.SEQUENCE        H_SEQUENCE,
           C.NOTIFICATION_ID H_NOTIFICATION_ID,
           C.FROM_ROLE       H_FROM_ROLE,
           C.FROM_USER       H_FROM_USER,
           C.TO_ROLE         H_TO_ROLE,
           C.TO_USER         H_TO_USER,
           C.ACTION_TYPE     H_ACTION_TYPE,
           C.ACTION          H_ACTION,
           C.USER_COMMENT    H_COMMENT,
           C.COMMENT_DATE    H_ACTION_DATE
      from WF_ITEM_ACTIVITY_STATUSES IAS,
           WF_COMMENTS C
      where IAS.ITEM_TYPE        = l_item_type
        and IAS.ITEM_KEY         = l_item_key
        and IAS.PROCESS_ACTIVITY = l_actid
        and IAS.NOTIFICATION_ID  = C.NOTIFICATION_ID
        and C.ACTION_TYPE        in ('REASSIGN', 'QA')
    union all
    select C.SEQUENCE        H_SEQUENCE,
           C.NOTIFICATION_ID H_NOTIFICATION_ID,
           C.FROM_ROLE       H_FROM_ROLE,
           C.FROM_USER       H_FROM_USER,
           C.TO_ROLE         H_TO_ROLE,
           C.TO_USER         H_TO_USER,
           C.ACTION_TYPE     H_ACTION_TYPE,
           C.ACTION          H_ACTION,
           C.USER_COMMENT    H_COMMENT,
           C.COMMENT_DATE    H_ACTION_DATE
      from WF_ITEM_ACTIVITY_STATUSES_H IAS,
           WF_COMMENTS C
      where IAS.ITEM_TYPE        = l_item_type
        and IAS.ITEM_KEY         = l_item_key
        and IAS.PROCESS_ACTIVITY = l_actid
        and IAS.NOTIFICATION_ID  = C.NOTIFICATION_ID
        and C.ACTION_TYPE        in ('REASSIGN', 'QA')
    )
    order by H_ACTION_DATE, H_NOTIFICATION_ID, H_SEQUENCE
    );

   l_comm_rec     c_comments%ROWTYPE;
   l_ntf_hist_rec c_ntf_hist%ROWTYPE;
begin

   begin
      SELECT item_type, item_key, process_activity
      INTO   l_item_type, l_item_key, l_actid
      FROM   wf_item_activity_statuses
      WHERE  notification_id = p_nid;
   exception
      when NO_DATA_FOUND then
        begin
          SELECT item_type, item_key, process_activity
          INTO   l_item_type, l_item_key, l_actid
          FROM   wf_item_activity_statuses_h
          WHERE  notification_id = p_nid;
        exception
          when NO_DATA_FOUND then
            -- It is possible that notification is sent outside of a flow,
            -- in that case, it will not appear in Workflow runtime tables.
            -- Just return here.
            return;
        end;
   end;

   l_value := SYS_CONTEXT('USERENV', 'LANGUAGE');
   l_pos1 := instr(l_value, '_');
   l_language := substr(l_value, 1, l_pos1-1);

   if (l_item_type in ('POSCHORD', 'POSUPDNT', 'POSORDNT', 'POSASNNB', 'CREATEPO', 'POAPPRV',
                       'POPRICAT', 'PORCOTOL', 'PONGRQCH', 'POERROR', 'POWFDS', 'RCVDMEMO',
                       'APVRMDER', 'POREQCHA', 'PORCPT', 'REQAPPRV', 'PORPOCHA')) then
      l_suppress_hist := 'Y';
      l_title := Wf_Core.Translate('WFNTF_NTF_HISTORY');
   else
      l_suppress_hist := 'N';
      l_title := Wf_Core.Translate('WFNTF_ACTION_HISTORY');
   end if;

   l_wf_system := Wf_Core.Translate('WF_SYSTEM');
   l_delim := ':';

   if isBiDi(l_language) then
        l_table_dir := 'R';
   else
        l_table_dir := table_direction;
   end if;

   if (l_table_dir = 'L') then
     l_dir := null;
   else
     l_dir := 'dir="RTL"';
   end if;

   j := 1;
   -- Action History Title
   cells(j) := wf_core.translate('NUM');
   if (p_display_type = wf_notification.doc_html) then
     cells(j) := 'S5%:'||cells(j);
   end if;

   j := j+1;
   cells(j) := wf_core.translate('ACTION_DATE');
   if (p_display_type = wf_notification.doc_html) then
     cells(j) := 'S15%:'||cells(j);
   end if;

   j := j+1;
   cells(j) := wf_core.translate('ACTION');
   if (p_display_type = wf_notification.doc_html) then
     cells(j) := 'S10%:'||cells(j);
   end if;

   j := j+1;
   cells(j) := wf_core.translate('FROM');
   if (p_display_type = wf_notification.doc_html) then
     cells(j) := 'S15%:'||cells(j);
   end if;

   j := j+1;
   cells(j) := wf_core.translate('TO');
   if (p_display_type = wf_notification.doc_html) then
     cells(j) := 'S15%:'||cells(j);
   end if;

   j := j+1;
   cells(j) := wf_core.translate('DETAILS');
   if (p_display_type = wf_notification.doc_html) then
     cells(j) := 'S40%:'||cells(j);
   end if;

   j := j+1;

   -- OPEN l_comments_c FOR l_sql_stmt using p_action_type, p_action_type, p_action_type,
   --      l_action_type1, l_action_type2, p_comment_date, p_from_role, p_to_role, p_nid;

 if (l_suppress_hist = 'N') then

   OPEN c_comments;
   -- Construct the action history table with all the matching comments records
   loop
      fetch c_comments into l_comm_rec;
      exit when c_comments%NOTFOUND;

      cells(j) := to_char(l_comm_rec.h_sequence);

      j := j+1;

      -- Bug 9173224, Added by David on March 02,2010
      -- Convert server datetime to local datetime according to the client timezone.
      l_comm_rec.h_action_date := wf_notification_util.GetLocalDateTime(l_comm_rec.h_action_date);

      if (p_display_type = wf_notification.doc_html) then
         -- <bug 7514495>
         cells(j) := 'S:' || wf_notification_util.GetCalendarDate(p_nid, l_comm_rec.h_action_date, null, true);
      else
         cells(j) := wf_notification_util.GetCalendarDate(p_nid, l_comm_rec.h_action_date, null, true);
      end if;

      j := j+1;

      -- If the record is not from WF_COMMENTS, need to resolve the action
      if (l_comm_rec.h_action_type <> '#WF_COMMENTS#') then
         l_action_str := Wf_Core.Activity_Result(l_comm_rec.h_action_type, l_comm_rec.h_action);
      else
         l_action := l_comm_rec.h_action;
         --l_pos := instr(l_action, '_', 1);
         --if (l_pos > 0) then
           --l_action := substr(l_action, 1, l_pos-1);
         --end if;
         l_action_str := Wf_Core.Translate(l_action);
      end if;

      if (p_display_type = wf_notification.doc_html) then
         cells(j) := 'S:'||l_action_str;
      else
         cells(j) := l_action_str;
      end if;

      j := j+1;
      if (p_display_type = wf_notification.doc_html) then
         cells(j) := 'S:'||Wf_Notification.SubstituteSpecialChars(l_comm_rec.h_from_user);
      else
         cells(j) := l_comm_rec.h_from_user;
      end if;

      j := j+1;
      if (p_display_type = wf_notification.doc_html) then
         cells(j) := 'S:'||Wf_Notification.SubstituteSpecialChars(l_comm_rec.h_to_user);
      else
         cells(j) := l_comm_rec.h_to_user;
      end if;

      j := j+1;
      l_note := l_comm_rec.h_comment;
      -- WF_NOTE indicates that this is a Respond attribute.
      if (l_note = '#WF_NOTE#') then
        begin
          SELECT text_value
          INTO   l_note
          FROM   wf_notification_attributes
          WHERE  notification_id = l_comm_rec.h_notification_id
          AND    name = 'WF_NOTE';
        exception
      when no_data_found then
            l_note := '';
        end;
      end if;
      if (p_display_type = wf_notification.doc_html) then
         l_note := substrb(Wf_Notification.SubstituteSpecialChars(l_note), 1, 4000);
      end if;
      cells(j) := l_note;

      if (p_display_type = wf_notification.doc_html) then
         if (cells(j) is null) then
            cells(j) := 'S:&nbsp;';
         else
            cells(j) := 'S:'||cells(j);
         end if;
      end if;
      j := j+1;
   end loop;

   l_count := c_comments%rowcount;
   CLOSE c_comments;

 elsif (l_suppress_hist = 'Y') then

   OPEN c_ntf_hist;

   -- Construct the action history table with all the matching comments records
   loop
      fetch c_ntf_hist into l_ntf_hist_rec;
      exit when c_ntf_hist%NOTFOUND;

      cells(j) := to_char(l_ntf_hist_rec.h_sequence);

      j := j+1;

      -- Bug 9173224, Added by David on March 02,2010
      -- Convert server datetime to local datetime according to the client timezone.
      l_ntf_hist_rec.h_action_date := wf_notification_util.GetLocalDateTime(l_ntf_hist_rec.h_action_date);

      if (p_display_type = wf_notification.doc_html) then
         cells(j) := 'S:'|| wf_notification_util.GetCalendarDate(p_nid, l_ntf_hist_rec.h_action_date, null, true);
      else
         cells(j) := wf_notification_util.GetCalendarDate(p_nid, l_ntf_hist_rec.h_action_date, null, true);
      end if;

      j := j+1;

      l_action := l_ntf_hist_rec.h_action;
      --l_pos := instr(l_action, '_', 1);
      --if (l_pos > 0) then
        --l_action := substr(l_action, 1, l_pos-1);
      --end if;
      l_action_str := Wf_Core.Translate(l_action);

      if (p_display_type = wf_notification.doc_html) then
         cells(j) := 'S:'||l_action_str;
      else
         cells(j) := l_action_str;
      end if;

      j := j+1;
      if (p_display_type = wf_notification.doc_html) then
         cells(j) := 'S:'||Wf_Notification.SubstituteSpecialChars(l_ntf_hist_rec.h_from_user);
      else
         cells(j) := l_ntf_hist_rec.h_from_user;
      end if;

      j := j+1;
      if (p_display_type = wf_notification.doc_html) then
         cells(j) := 'S:'||Wf_Notification.SubstituteSpecialChars(l_ntf_hist_rec.h_to_user);
      else
         cells(j) := l_ntf_hist_rec.h_to_user;
      end if;

      j := j+1;
      l_note := l_ntf_hist_rec.h_comment;
      if (p_display_type = wf_notification.doc_html) then
         l_note := substrb(Wf_Notification.SubstituteSpecialChars(l_note), 1, 4000);
      end if;
      cells(j) := l_note;

      if (p_display_type = wf_notification.doc_html) then
         if (cells(j) is null) then
            cells(j) := 'S:&nbsp;';
         else
            cells(j) := 'S:'||cells(j);
         end if;
      end if;
      j := j+1;
   end loop;

   l_count := c_ntf_hist%rowcount;
   CLOSE c_ntf_hist;

 end if;

   -- If there is nothing to display, return a null
   if (l_count = 0) then
      p_action_history := '';
      return;
   end if;

   -- Sequence is now based on the rownum, not the reverse
   -- for k in 0..(i-1) loop
   --   if (p_display_type = wf_notification.doc_html) then
   --      cells((k+1)*6+1) := 'C:'||to_char(i-k-1);
   --   else
   --      cells((k+1)*6+1) := to_char(i-k-1);
   --   end if;
   -- end loop;

   -- Construct table from the cells
   if (p_display_type = wf_notification.doc_html) then
      table_width := '100%';
      -- bug 7718246 - set the table border to 1 only for action history
      table_border := '1';
      NTF_Table(cells=>cells,
                col=>6,
                type=>'H'||l_table_dir,
                rs=>l_result);

      -- Display title "Action History"
      l_result := '<table  width='||table_width||
                  ' border="0" cellspacing="0" cellpadding="0" '||l_dir||'>' ||
                  '<tr><td class="OraHeaderSub">'||
                  l_title||'</td></tr>'||'<tr><td>'||l_result||'</td></tr></table>';
      -- reset table border to default value after generating action history
      table_border := '0';
   else
      for k in 1..cells.LAST loop
         if (mod(k, 6) <> 0) then
            l_result := l_result||cells(k)||' '||l_delim||' ';
         else
            l_result := l_result||cells(k)||wf_core.newline;
        end if;
     end loop;
     l_result := wf_core.translate('WFNTF_ACTION_HISTORY')||wf_core.newline||l_result;
   end if;

   p_action_history := l_result;

exception
  when others then
     wf_core.context('Wf_Notification', 'GetComments2', to_char(p_nid), p_display_type);
     raise;
end GetComments2;

--
-- GetAttrblob
--   Get the displayed value of a PLSQLBLOB DOCUMENT-type attribute.
--   Returns referenced document in format requested.
--   Use GetAttrText to get retrieve the actual attr value (i.e. the
--   document key string instead of the actual document).
-- NOTE:
--   a. Only PLSQL document type is implemented.
--   b. This will be called by old mailers. This is a wrapper to the
--      new implementation which returns the doctype also.
-- IN:
--   nid      - Notification id
--   astring  - the string to substitute on (ex: '&ATTR1 is your order..')
--   disptype - Requested display type.  Valid values:
--               wf_notification.doc_text - 'text/plain'
--               wf_notification.doc_html - 'text/html'
--   document - The blob into which
--   aname    - Attribute Name (the first part of the string that matches
--              the attr list)
--
procedure GetAttrblob(
  nid       in number,
  astring   in varchar2,
  disptype  in varchar2,
  document  in out nocopy blob,
  aname     out nocopy varchar2)
is
  doctype varchar2(500);
begin

  Wf_Notification.GetAttrblob(nid, astring, disptype, document, doctype, aname);

exception
  when others then
    wf_core.context('Wf_Notification', 'oldGetAttrblob', to_char(nid), aname,
        disptype);
    raise;
end GetAttrblob;

-- GetAttrblob
--   Get the displayed value of a PLSQLBLOB DOCUMENT-type attribute.
--   Returns referenced document in format requested.
--   Use GetAttrText to get retrieve the actual attr value (i.e. the
--   document key string instead of the actual document).
-- NOTE:
--   Only PLSQL document type is implemented.
-- IN:
--   nid      - Notification id
--   astring  - the string to substitute on (ex: '&ATTR1 is your order..')
--   disptype - Requested display type.  Valid values:
--               wf_notification.doc_text - 'text/plain'
--               wf_notification.doc_html - 'text/html'
--   document - The blob into which
--   aname    - Attribute Name (the string that matches
--              the attr list)
--
procedure GetAttrblob(
  nid       in  number,
  astring   in  varchar2,
  disptype  in  varchar2,
  document  in  out nocopy blob,
  doctype   out nocopy varchar2,
  aname     out nocopy varchar2)
is
  key varchar2(4000);
  colon pls_integer;
  slash pls_integer;
  dmstype varchar2(30);
  display_name varchar2(80);
  procname varchar2(240);
  launch_url varchar2(4000) := null;
  procarg varchar2(32000);
  username  varchar2(320);

  --curs integer;
  sqlbuf varchar2(2000);
  --rows integer;

  target   varchar2(240);
  l_charcheck boolean;

begin

  -- Check args
  if ((nid is null) or (astring is null) or
     (disptype not in (wf_notification.doc_text,
                       wf_notification.doc_html))) then
    wf_core.token('NID', to_char(nid));
    wf_core.token('ASTRING', aname);
    wf_core.token('DISPTYPE', disptype);
    wf_core.raise('WFSQL_ARGS');
  end if;

  -- of all the possible Document type matches,
  -- make sure its a PLSQLBLOB
    dmstype := '';

  -- Bug 6324545: Replaced the cursor with a simple sql to fetch a single row.
  begin
      -- <7443088> improved query
      select NAME into aname from
        (select WMA.NAME
         from WF_NOTIFICATIONS WN,
              WF_MESSAGE_ATTRIBUTES WMA,
              WF_NOTIFICATION_ATTRIBUTES NA
         where WN.NOTIFICATION_ID = nid
          and wn.notification_id = na.notification_id
          and wma.name = na.name
          and WN.MESSAGE_TYPE = WMA.MESSAGE_TYPE
          and WN.MESSAGE_NAME = WMA.MESSAGE_NAME
          and WMA.TYPE = 'DOCUMENT'
          and instr( upper(astring) ,wma.name) = 1
          and upper(na.text_value) like 'PLSQLBLOB:%'
         order by length(wma.name) desc)
       where rownum=1;
  exception
     when no_data_found then
           aname:=null;
           return;
  end;

  if (aname is not null) then
     -- Retrieve key string
     key := wf_notification.GetAttrText(nid, aname);

     -- If the key is empty then return a null string
     if (key is not null) then

       -- Parse doc mgmt system type from key
       colon := instr(key, ':');
       if ((colon <> 0) and (colon < 30)) then
          dmstype := upper(substr(key, 1, colon-1));
       end if;
     end if;
   end if;

  -- if we didnt find any plsqlblobs then exit now
  if dmstype is null or (dmstype <> 'PLSQLBLOB') then
     aname:=null;
     return;
  end if;

  -- We must be processing a BLOB PLSQL doc type
  slash := instr(key, '/');
  if (slash = 0) then
    procname := substr(key, colon+1);
    procarg := '';
  else
    procname := substr(key, colon+1, slash-colon-1);
    procarg := substr(key, slash+1);
  end if;

  -- Dynamic sql call to procedure
  -- bug 2706082 using execute immediate instead of dbms_sql.execute

  if (procarg is null) then
     procarg := NULL;
  else
     procarg := Wf_Notification.GetTextInternal(procarg, nid, target,
                                                FALSE, FALSE);
  end if;

  -- ### Review Note 1
  -- Check for bug#3827935
  l_charcheck := wf_notification_util.CheckIllegalChar(procname);
  --Throw the Illegal exception when the check fails

   if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string2(wf_log_pkg.level_statement,
                       'wf.plsql.wf_notification.GetAttrBlob.plsqlblob_callout',
                       'Start executing PLSQLBLOB Doc procedure  - '||procname, true);
   end if;

   sqlbuf := 'begin '||procname||'(:p1, :p2, :p3, :p4); end;';
   -- Catch any exceptions from PLSQL Document APIs as is and log it to help
   -- troubleshoot issues from non-WF code
   begin
     execute immediate sqlbuf using
       in procarg,
       in disptype,
       in out document,
       in out doctype;
   exception
     when others then
       if (wf_log_pkg.level_exception >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.level_exception,
                    'wf.plsql.wf_notification.GetAttrBLOB.plsqlblob_api',
                    'Error executing PLSQLBLOB Doc API - '||procname||' -> '||sqlerrm);
       end if;

       -- Bug 10130433: Throwing the WF error 'WFNTF_GEN_DOC' with all the error information
       -- when an exception occurs while executing the PLSQL Document APIs
       WF_CORE.Token('DOC_TYPE', 'PLSQLBLOB');
       WF_CORE.Token('FUNC_NAME', procname);
       WF_CORE.Token('SQLCODE', to_char(sqlcode));
       WF_CORE.Token('SQLERRM', DBMS_UTILITY.FORMAT_ERROR_STACK());
       WF_CORE.Raise('WFNTF_GEN_DOC');
   end;

   if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string2(wf_log_pkg.level_statement,
                       'wf.plsql.wf_notification.GetAttrBlob.plsqlblob_callout',
                       'End executing PLSQLBLOB Doc procedure  - '||procname, false);
   end if;

exception
  when others then
    wf_core.context('Wf_Notification', 'GetAttrblob', to_char(nid), aname,
        disptype);
    raise;
end GetAttrblob;

--
-- Set_NTF_Table_Direction
-- Sets the default direction of notification tables
-- generated through wf_notification.wf_ntf_history
-- and wf_notification.wf_msg_attr
procedure Set_NTF_Table_Direction(direction in varchar2)
is
begin
   table_direction := direction;
end Set_NTF_Table_direction;

--
-- Set_NTF_Table_Type
-- Sets the default table type for attr tables
-- generated through wf_notification.wf_msg_attr
procedure Set_NTF_Table_Type(tableType in varchar2)
is
begin
   table_type := tableType;
end Set_NTF_Table_Type;


-- isFwkRegion
-- verifies whether message for given notification id contains
-- any framework regions.
-- Algorithm: Function returns 'Y' if one of the following condition is met
--            - If header region attribute #HDR_REGION of type 'DOCUMENT'
--              and its value starts with 'JSP:/OA_HTML/OA.jsp?'
--            - If the message body is of type framework region
--

function isFwkRegion(nid in number) return varchar2 is

begin
   return isFwkRegion(nid, wf_notification.doc_html);
end isFwkRegion;


-- isFwkRegion
-- verifies whether message for given notification id contains
-- any framework regions.
-- Algorithm: Function returns 'Y' if one of the following condition is met
--            - If header region attribute #HDR_REGION of type 'DOCUMENT'
--              and its value starts with 'JSP:/OA_HTML/OA.jsp?'
--            - If the message body is of type framework region
--
-- Auth : SSTOMAR

function isFwkRegion(nid in number, content_type in varchar2 ) return varchar2 is

  lv_body varchar2(32000);
  lv_html_body varchar2(32000);
  lv_final_body varchar2(32000);
  lv_fwk_region varchar2(1);
  lv_first_token varchar2(240);
  lv_token_start number;

  cursor cur_hdr_region is
    select WNA.NAME, WNA.TEXT_VALUE
    from WF_NOTIFICATION_ATTRIBUTES WNA,
         WF_MESSAGE_ATTRIBUTES_VL WMA
    where WNA.NOTIFICATION_ID = nid
    and WMA.NAME = WNA.NAME
    and WMA.TYPE = 'DOCUMENT'
    and WNA.NAME = '#HDR_REGION';

begin

  lv_fwk_region := 'N';

  for attr_row in cur_hdr_region loop
    if( instr(attr_row.text_value, fwk_region_start) = 1 ) then
      lv_fwk_region := 'Y';
      exit;
    end if;
  end loop;
  -- If framework header region exists then return
  if( lv_fwk_region = 'Y' ) then
   return lv_fwk_region;
  -- else check whether message body is of type framework region
  else
    return isFwkBody( nid, content_type);
  end if;
exception
  when OTHERS then
    wf_core.context('Wf_Notification','isFwkRegion',to_char(nid), content_type);
    raise;

End isFwkRegion;

-- isFwkBody
-- verifies whether message body for given notification id contains
-- any framework regions.
-- Algorithm: Function returns 'Y' if one of the following condition is met
--            - If the first attribute referred in the body is of
--              type 'DOCUMENT' and its value starts with 'JSP:/OA_HTML/OA.jsp?'
--            - If the message body does not have any attributes refered except
--              for WF_NOTIFICATION macro and simple text

function isFwkBody(nid in number) return varchar2 is


begin
  -- invoke overrided API with default as 'text/html'
  return isFwkBody(nid, wf_notification.doc_html);

End isFwkBody;

-- isFwkBody
-- verifies whether message body for given notification id contains
-- any framework regions.
-- Algorithm: Function returns 'Y' if one of the following condition is met
--            - If the first attribute referred in the body is of
--              type 'DOCUMENT' and its value starts with 'JSP:/OA_HTML/OA.jsp?'
--            - If the message body does not have any attributes refered except
--              for WF_NOTIFICATION macro and simple text
-- Auth : SSTOMAR
function isFwkBody(nid in number, content_type in varchar2) return varchar2 is

  lv_body varchar2(32000);
  lv_html_body varchar2(32000);
  lv_final_body varchar2(32000);
  lv_fwk_body varchar2(1);
  lv_first_token varchar2(240);
  lv_token_start number;

begin

  lv_fwk_body := 'N';

  select nvl(WM.BODY, ''), nvl(WM.HTML_BODY, '')
  into lv_body, lv_html_body
  from WF_NOTIFICATIONS N, WF_MESSAGES_VL WM
  where N.NOTIFICATION_ID = nid
  and N.MESSAGE_NAME = WM.NAME
  and N.MESSAGE_TYPE = WM.TYPE;

  --  bug 5456241 (SSTOMAR)
  --  Based on that, we will pick up corresponding message bdoy.
  --
  --  KNOWN ISSUE: Generally the simple text in message body also considered
  --  as Framework based notification but If message body has simple text contains
  --  '& ' character without token name
  --  then according to below logic it will be plsql based ntf.

  if (content_type = wf_notification.doc_html ) then
    if (length(trim(lv_html_body)) > 0 ) then

      if (fwkTokenExist(nid, lv_html_body) = 'Y'
          or instr(lv_html_body, '&') = 0 ) then
        lv_fwk_body := 'Y';
      end if;
    -- HTML body is blank, check text body. And if text body has any TOKEN which
    -- is a DOCUMENT type OR it does not has any attribute then assume it as Fwk based Ntf.
    elsif (length(trim(lv_body)) > 0
           and (fwkTokenExist(nid, lv_body) = 'Y'
                or instr(lv_body, '&') = 0)) then
      lv_fwk_body := 'Y';
    end if;
  else  -- doc_type is plan/text
    -- Check the text body only
    if (length(trim(lv_body)) > 0
        and (fwkTokenExist(nid, lv_body) = 'Y'
             or instr(lv_body, '&') = 0) ) then
      lv_fwk_body := 'Y';
    end if;
  end if;


  --lv_token_start := instr( lv_final_body, '&');
  -- get the first token in the body
  --if( lv_token_start > 0 ) then
  --  lv_first_token := substr(lv_final_body, lv_token_start+1, 30);
  --  for attr_row in cur_msg_attrs(nid, lv_first_token) loop
  --    if( instr(attr_row.text_value, fwk_region_start) = 1 ) then
  --      lv_fwk_body := 'Y';
  --      exit;
  --    end if;
  --  end loop;
  -- no attributes refered in body so render framework region
  --else
  --  lv_fwk_body := 'Y';
  -- end if;

  return lv_fwk_body;
exception
  when OTHERS then
    wf_core.context('Wf_Notification','isFwkBody',to_char(nid), content_type);
    raise;

End isFwkBody;

-- fwkTokenExist
-- This function check whether first TOKEN within the message body exist AND
-- has the value like 'JSP:/OA_HTML/OA.jsp?' (value hold by variable fwk_region_start) .
-- Auther : SSTOMAR
function fwkTokenExist(nid in number, msgbody in varchar2) return varchar2 is
  lv_token_exist varchar2(1) ;
  lv_token_start number;
  lv_first_token varchar2(240);

  -- Cursur to check for each message Attribute
  cursor cur_msg_attrs(nid number, msgToken varchar2) is
    select WNA.NAME, WNA.TEXT_VALUE, WMA.TYPE
    from WF_NOTIFICATION_ATTRIBUTES WNA, WF_NOTIFICATIONS WN,
         WF_MESSAGE_ATTRIBUTES_VL WMA
    where WNA.NOTIFICATION_ID = nid
    and WN.NOTIFICATION_ID = WNA.NOTIFICATION_ID
    and WN.MESSAGE_TYPE = WMA.MESSAGE_TYPE
    and WN.MESSAGE_NAME = WMA.MESSAGE_NAME
    and WMA.TYPE = 'DOCUMENT'
    and WMA.NAME = WNA.NAME
    and instr( msgToken, WMA.NAME ) = 1
    order by length(WMA.NAME) desc;

begin

    lv_token_exist := 'N';
    lv_token_start := instr( msgbody, '&');

    -- get the first token in the body
    if( lv_token_start > 0 ) then
     -- sstomar:
     -- Note: No. of characters 30 are hardcoded,
     -- I think we should take upto space ' ' mark.
     lv_first_token := substr(msgbody, lv_token_start+1, 30);

     for attr_row in cur_msg_attrs(nid, lv_first_token) loop
      if( instr(attr_row.text_value, fwk_region_start) = 1 ) then
       lv_token_exist := 'Y';
       exit;
      end if;
     end loop;
    end if;

 return lv_token_exist;
exception
  when OTHERS then
    wf_core.context('Wf_Notification','fwkTokenExist',to_char(nid));
    raise;

end fwkTokenExist;

--
-- getNtfActInfo
-- Fetch Notification Activity info of a given notification. It is possible
-- that there will not be an entry in WF_ITEM_ACTIVITY_STATUSES and/or
-- WF_ITEM_ACTIVITY_STATUSES_H in case when the notification is sent using
-- Send API instead of part of a process.
-- IN
--  nid - Notification ID
-- OUT
--  l_itype Itemtype of the notification activity
--  l_itype Itemkey of the process part of which the notification was sent
--  l_actid Activity ID of the Notification Activity in the process

procedure getNtfActInfo (nid     in  number,
                         l_itype out nocopy varchar2,
                         l_ikey  out nocopy varchar2,
                         l_actid out nocopy number)
is
  --bug 2276260 skilaru 15-July-03
  cursor act_info_statuses_cursor( group_nid number ) is
    select ITEM_TYPE, ITEM_KEY, PROCESS_ACTIVITY
      from WF_ITEM_ACTIVITY_STATUSES
     where notification_id = group_nid;

  cursor act_info_statuses_h_cursor( group_nid number ) is
    select ITEM_TYPE, ITEM_KEY, PROCESS_ACTIVITY
      from WF_ITEM_ACTIVITY_STATUSES_H
     where notification_id = group_nid;

  l_group_nid number;

begin
  --skilaru 16-July-03
  --WF_ITEM_ACTIVITY_STATUSES.NOTIFICATION_ID is the foreing key
  --mapped to WF_NOTIFICATIONS.GROUP_ID
  SELECT group_id
    INTO l_group_nid
    FROM wf_notifications
   WHERE notification_id = nid;

  for act_status_row in act_info_statuses_cursor( l_group_nid ) loop
    l_itype := act_status_row.ITEM_TYPE;
    l_ikey := act_status_row.ITEM_KEY;
    l_actid := act_status_row.PROCESS_ACTIVITY;
  end loop;

  if( l_itype is null and l_ikey is null ) then
    for act_status_row in act_info_statuses_h_cursor( l_group_nid ) loop
      l_itype := act_status_row.ITEM_TYPE;
      l_ikey := act_status_row.ITEM_KEY;
      l_actid := act_status_row.PROCESS_ACTIVITY;
    end loop;
  end if;

exception
  when OTHERS then
    wf_core.context('Wf_Notification','getNtfActInfo',to_char(nid));
    raise;

End getNtfActInfo;

--
-- getFwkBodyURLLang
--   This API returns a URL to access notification body with
--   Framework content embedded.
-- IN:
--   nid      - Notification id
--   disptype - Requested display type.  Valid values:
--               'text/plain' - plain text
--               'text/html' - html
-- RETURNS:
--   Returns the URL to access the notification detail body
--
function getFwkBodyURLLang(nid in number,
                           contenttype varchar2,
                           language in varchar2)
return varchar2
 is
 begin

  return getFwkBodyURL2(nid, contenttype, language, null);

end getFwkBodyURLLang;


--
-- getFwkBodyURL
--   This API returns a URL to access notification body with
--   Framework content embedded.
-- IN:
--   p_nid      - Notification id
--   p_contenttype - Requested display type.  Valid values:
--                 'text/plain' - plain text
--                 'text/html' - html,
--   p_language     language value of that notification / user
--   p_nlsCalendar  nls calender of that user

-- RETURNS:
--   Returns the URL to access the notification detail body
--

function getFwkBodyURL2( p_nid in number,
                         p_contentType varchar2,
                         p_language varchar2,
                         p_nlsCalendar varchar2) return varchar2
is
   url_value varchar2(2000);
   lang_code varchar2(4);
   l_api varchar2(250) := g_plsqlName ||'getFwkBodyURL2';
   l_nls_calendar varchar2(64);
begin
  if (WF_LOG_PKG.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'BEGIN');
  end if;

   url_value := rtrim(fnd_profile.Value('WF_MAIL_WEB_AGENT'), '/');

   if url_value is null then
      url_value := rtrim(fnd_profile.Value('APPS_FRAMEWORK_AGENT'), '/');
   end if;

   url_value := url_value || wf_notification.fwk_mailer_page;
   url_value := url_value || '&WFRegion=NtfDetail&NtfId=' || to_char(p_nid);
   url_value := url_value || '&dbc=' || fnd_web_config.Database_ID;

   if (p_contentType = wf_notification.doc_html) then
     -- url_value := url_value || '&OALAF=blaf&OARF=email';
     url_value := url_value || '&OARF=email';
   elsif  (p_contentType = wf_notification.doc_text) then
     url_value := url_value || '&OALAF=oaText&OARF=email';
   end if;

   -- Bug 5170348
   -- Append the language_code to the fwk URL to set session p_language
   if (p_language is not null) then
     begin

       select code into lang_code from wf_languages where nls_language=p_language;
       url_value := url_value || '&language_code='|| lang_code;

     exception
       when others then
          wf_log_pkg.string(WF_LOG_PKG.LEVEL_EXCEPTION, 'WF_NOTIFICATION.getFwkBodyURLLang',
                         'nid: '||to_char(p_nid)||'; language: '|| p_language);
     end;
   end if;

    l_nls_calendar := nvl(p_nlsCalendar, wf_core.nls_calendar);
    if (l_nls_calendar <> 'GREGORIAN') then
         url_value := url_value || '&nlsCalendar='||l_nls_calendar;
    end if;

   if (WF_LOG_PKG.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'p_nlsCalendar: '||p_nlsCalendar);
     wf_log_pkg.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'url: '||url_value);
     wf_log_pkg.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'END');
   end if;

   return url_value;

 exception
   when OTHERS then
     wf_core.context('Wf_Notification','getFwkBodyURL2',
                     to_char(p_nid), p_contentType,p_language,p_nlsCalendar );
     raise;

END getFwkBodyURL2;



--
-- getFwkBodyURL
--   This API returns a URL to access notification body with
--   Framework content embedded
-- IN:
--   nid      - Notification id
--   disptype - Requested display type.  Valid values:
--               'text/plain' - plain text
--               'text/html' - html
-- RETURNS:
--   Returns the URL to returned by call to getFwkBodyURLLang
--
function getFwkBodyURL(nid in number, contenttype varchar2 ) return varchar2
 is
 begin
  return getFwkBodyURLLang(nid, contenttype, null);
end getFwkBodyURL;

--
-- getSummaryURL
--   This API returns a URL to access summary of notiifications
--
-- IN:
--   mailer_role  - role for which summary of notifications required
--   disptype     - Requested display type.  Valid values:
--               'text/plain' - plain text
--               'text/html' - html
-- RETURNS:
--   Returns the URL to access the summary of notiification for the role
--

function getSummaryURL(mailer_role varchar2, contenttype varchar2 ) return varchar2
 is
 begin

   RETURN getSummaryURL2(p_mailer_role =>mailer_role,
                         p_contentType => contenttype,
                         p_nlsCalendar => null);

end getSummaryURL;

-- getSummaryURL
--   This API returns a URL to access summary of notiifications
--
-- IN:
--   p_mailer_role   - role for which summary of notifications required
--   p_contentType   - Requested display type.  Valid values:
--                   'text/plain' - plain text
--                   'text/html' - html
--   p_nlsCalendar   - nls Calender of that role / user
--
-- RETURNS:
--   Returns the URL to access the summary of notiification for the role
--

function getSummaryURL2( p_mailer_role varchar2,
                        p_contentType varchar2,
                        p_nlsCalendar varchar2) return varchar2
is
   url_value varchar2(2000);
   l_api varchar2(250) := g_plsqlName ||'getSummaryURL2';
   l_nls_calendar varchar2(64);
begin
   if (WF_LOG_PKG.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'BEGIN');
  end if;

   url_value := rtrim(fnd_profile.Value('WF_MAIL_WEB_AGENT'), '/');
   if url_value is null then
     url_value := rtrim(fnd_profile.Value('APPS_FRAMEWORK_AGENT'), '/');
   end if;

   url_value := url_value || wf_notification.fwk_mailer_page;
   url_value := url_value ||'&WFRegion=NtfSummary&mailerRole=' || p_mailer_role;
   url_value := url_value || '&dbc=' || fnd_web_config.Database_ID;

   if (p_contentType = wf_notification.doc_html) then
     -- url_value := url_value || '&OALAF=blaf&OARF=email';
     url_value := url_value || '&OARF=email';
   elsif  (p_contentType = wf_notification.doc_text) then
     url_value := url_value || '&OALAF=oaText&OARF=email';
   end if;

    l_nls_calendar := nvl(p_nlsCalendar, wf_core.nls_calendar);
    if (l_nls_calendar <> 'GREGORIAN') then
         url_value := url_value || '&nlsCalendar='||l_nls_calendar;
    end if;

   if (WF_LOG_PKG.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'p_nlsCalendar: '||p_nlsCalendar);
     wf_log_pkg.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'url: '||url_value);
     wf_log_pkg.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'END');
   end if;

   return url_value;

 exception
   when OTHERS then
     wf_core.context('Wf_Notification','getSummaryURL2', p_mailer_role, p_contentType, p_nlsCalendar);
     raise;

END getSummaryURL2;




   -- GetSignatureRequired
   -- Determine signing requirements for a policy
   -- IN:
   --   nid - Notification id - used for error context only
   --   p_sig_policy - Policy Name
   -- OUT:
   --   p_sig_required - Y/N
   --   p_fwk_sig_flavor - sigFlavor for browser signing.
   --   p_email_sig_flavor - sigFlavor for email
   --   p_render_hint - hints like ATTR_ONLY or FULL_TEXT

   procedure GetSignatureRequired(p_sig_policy in varchar2,
        p_nid in number,
        p_sig_required out nocopy varchar2,
        p_fwk_sig_flavor out nocopy varchar2,
        p_email_sig_flavor out nocopy varchar2,
        p_render_hint out nocopy varchar2)

     is

     v_sig_policy varchar2(50);

   begin
     -- if the signature policy is null, set it as  default
     if (p_sig_policy is null) then
           v_sig_policy := 'DEFAULT';
     else
           v_sig_policy := p_sig_policy;
     end if;

     --select the flavors corresponding to the sig policy
     select SIG_REQUIRED,FWK_SIG_FLAVOR,EMAIL_SIG_FLAVOR, RENDER_HINT
      into p_sig_required,p_fwk_sig_flavor,p_email_sig_flavor,p_render_hint
      from WF_SIGNATURE_POLICIES
     where  sig_policy=UPPER(TRIM(v_sig_policy));

     --when any exception raise the error with the corresponding notification id

   exception
      when others then
       wf_core.context('WF_Notification', 'GetSignatureRequired', to_char(p_nid));
       wf_core.token('NID', to_char(p_nid));
       wf_core.raise('WFMLR_INVALID_SIG_POLICY');
   end;

-- SetUIErrorMessage
-- API for Enhanced error handling for OAFwk UI Bug#2845488 grengara
-- This procedure can be used for handling exceptions gracefully when dynamic SQL is invloved

procedure SetUIErrorMessage
is
begin
    if ((wf_core.error_name is null) AND (sqlcode <= -20000) AND (sqlcode >= -20999)) then
    -- capture the SQL Error message in this global variable so that it can be propogated
    -- back to OAF without the need for an OUT paramter
        wf_core.error_message := sqlerrm;
    end if;
end SetUIErrorMessage;

--
-- SetComments
--   Private procedure that is used to store a comment record into WF_COMMENTS
--   table with the denormalized information. A record is inserted for every
--   action performed on a notification.
-- IN
--   p_nid - Notification Id
--   p_from_role - Internal Name of the comment provider
--   p_to_role - Internal Name of the comment recipient
--   p_action - Action performed
--   p_action_source - Source from where the action is performed
--   p_user_comment - Comment Text
--
procedure SetComments(p_nid           in number,
                      p_from_role     in varchar2,
                      p_to_role       in varchar2,
                      p_action        in varchar2,
                      p_action_source in varchar2,
                      p_user_comment  in varchar2)
is
   l_from_role   varchar2(320);
   l_from_user   varchar2(360);
   l_to_user     varchar2(360);
   l_action_type varchar2(30);
   l_proxy_user  varchar2(320);
   l_action      varchar2(30);
   l_seq_num     number;
   l_action_source wf_comments.action_source%type; --ER Bug 27224517: Approvals Source Tracking for Mobile Approval App
begin
   -- Just because p_from_role was null due to some reason, there should not be failure.
   -- All cases are taken care to make sure from_role is valid. Just in case...
   if (p_from_role is null) then
      l_from_role := 'WF_SYSTEM';
   else
      l_from_role := p_from_role;
   end if;

   -- If p_from_role is an e-mail address with 'email:' prefixed, it is better remove it
   -- since it would not appear good on the UI
   if (substr(l_from_role, 1, 6) = 'email:') then
     l_from_role := substr(l_from_role, 7);
   end if;

   -- Sometimes p_from_role is email address when answering for more info request
   if (l_from_role = 'WF_SYSTEM') then
      l_from_user := Wf_Core.Translate(l_from_role);
   else
      l_from_user := nvl(Wf_Directory.GetRoleDisplayName(l_from_role), l_from_role);
   end if;
   if (p_to_role = 'WF_SYSTEM') then
      l_to_user := Wf_Core.Translate(p_to_role);
   else
      l_to_user := nvl(Wf_Directory.GetRoleDisplayname(p_to_role), p_to_role);
   end if;
   l_action := p_action;

   if (l_action in ('DELEGATE','TRANSFER')) then
      l_action_type := 'REASSIGN';
   elsif (l_action in ('QUESTION','ANSWER', 'TRANSFER_QUESTION')) then
      l_action_type := 'QA';
   else
      -- Actions like RESPOND, CANCEL, SEND
      l_action_type := p_action;
   end if;

   -- suffix source to action... DELEGATE_RULE, FORWARD_WA, etc.
   --ER Bug 27224517: Approvals Source Tracking for Mobile Approval App
   if ((p_action_source is not null) and (p_action_source not in ('REST','MOBILE','WORKLIST','EMAIL','API'))) then
      l_action := l_action||'_'||p_action_source;
      -- if the action is performed from WA, the user performing the action
      -- should be acting as a proxy to another user
      if (p_action_source = 'WA') then
         l_proxy_user := Wfa_Sec.GetUser();
      end if;
   end if;

   -- Calculate sequence for comments in the same session
   l_seq_num := g_comments_seq + 1;
   g_comments_seq := g_comments_seq + 1;

   --ER Bug 27224517: Approvals Source Tracking for Mobile Approval App
   if(p_action_source is null or p_action_source = 'FIRST') then
     l_action_source := 'API';
   else
     l_action_source := p_action_source;
   end if;

   INSERT INTO wf_comments (
          sequence,
          notification_id,
          from_role,
          from_user,
          to_role,
      to_user,
          comment_date,
          action,
          action_type,
      proxy_role,
          user_comment,
          language,
          action_source --ER Bug 27224517: Approvals Source Tracking for Mobile Approval App
        ) VALUES (
          l_seq_num,
          p_nid,
          l_from_role,
          l_from_user,
          p_to_role,
          l_to_user,
          sysdate,
          l_action,
          l_action_type,
          l_proxy_user,
          p_user_comment,
          userenv('LANG'),
          l_action_source --ER Bug 27224517: Approvals Source Tracking for Mobile Approval App
        );

exception
   when others then
      wf_core.context('Wf_Notification', 'SetComments', to_char(p_nid), p_from_role,
                      p_to_role, p_action, p_action_source);
      raise;
end SetComments;

--
-- Resend
--   Private procedure to resend a notification given the notification id. This
--   procedure checks the mail status and recipient's notification preference to
--   see if it is eligible to send e-mail.
-- IN
--   p_nid - Notification Id
--
procedure Resend(p_nid in number)
is
  l_recipient_role varchar2(320);
  l_group_id       number;
  l_mail_status    varchar2(8);
  l_status         varchar2(8);
  l_message_type   varchar2(8);
  l_message_name   varchar2(30);
  l_paramlist      wf_parameter_list_t := wf_parameter_list_t();

  l_display_name    varchar2(360);
  l_email_address   varchar2(320);
  l_notification_pref varchar2(8);
  l_language        varchar2(30);
  l_territory       varchar2(30);
  l_orig_system     varchar2(30);
  l_orig_system_id  number;
  l_installed       varchar2(1);
  role_info_tbl  wf_directory.wf_local_roles_tbl_type;

begin

  begin
    SELECT message_type, message_name, status, mail_status, nvl(more_info_role, recipient_role) recipient_role, group_id
    INTO   l_message_type, l_message_name, l_status, l_mail_status, l_recipient_role, l_group_id
    FROM   wf_notifications
    WHERE  notification_id = p_nid;
  exception
    when no_data_found then
      wf_core.token('NID', to_char(p_nid));
      wf_core.raise('WFNTF_NID');
  end;

  -- Get recipient information using Dir Service API. Select from WF_ROLES
  -- may not give the right information
  Wf_Directory.GetRoleInfoMail(l_recipient_role, l_display_name, l_email_address,
                               l_notification_pref, l_language, l_territory,
                               l_orig_system, l_orig_system_id, l_installed);

  -- Check if the notification is eligible to be e-mailed. We throw specific error
  -- for the UI to display appropriately to the user
  if (l_status <> 'OPEN') then
    wf_core.token('NID', to_char(p_nid));
    wf_core.raise('WFNTF_NID_OPEN');
  end if;

  if (l_notification_pref not in ('MAILHTML','MAILTEXT','MAILATTH','MAILHTM2')) then
    wf_core.token('NTF_PREF', l_notification_pref);
    wf_core.token('RECIPIENT', l_recipient_role);
    wf_core.raise('WFNTF_INVALID_PREF');
  end if;

  if (l_mail_status not in ('SENT', 'ERROR', 'FAILED', 'UNAVAIL')) then
    wf_core.token('MAILSTATUS', l_mail_status);
    wf_core.raise('WFNTF_EMAIL_NOTSENT');
  end if;

  -- Raise the event to send an e-mail
  UPDATE wf_notifications
  SET    mail_status = 'MAIL'
  WHERE  notification_id =  p_nid;

  Wf_Event.AddParameterToList('NOTIFICATION_ID', p_nid, l_paramlist);
  Wf_Event.AddParameterToList('ROLE', l_recipient_role, l_paramlist);
  Wf_Event.AddParameterToList('GROUP_ID', l_group_id, l_paramlist);
  Wf_Event.AddParameterToList('Q_CORRELATION_ID', l_message_type||':'||
                              l_message_name, l_paramlist);

   Wf_Directory.GetRoleInfo2(l_recipient_role, role_info_tbl);
   l_language := role_info_tbl(1).language;

   select code into l_language from wf_languages where nls_language = l_language;

  -- AppSearch
  wf_event.AddParameterToList('OBJECT_NAME',
  'oracle.apps.fnd.wf.worklist.server.AllNotificationsVO', l_paramlist);
  wf_event.AddParameterToList('CHANGE_TYPE', 'INSERT',l_paramlist);
  wf_event.AddParameterToList('ID_TYPE', 'PK', l_paramlist);
  wf_event.addParameterToList('PK_NAME_1', 'NOTIFICATION_ID',l_paramlist);
  wf_event.addParameterToList('PK_VALUE_1', p_nid, l_paramlist);
  wf_event.addParameterToList('PK_NAME_2', 'LANGUAGE',l_paramlist);
  wf_event.addParameterToList('PK_VALUE_2', l_language, l_paramlist);

  Wf_Event.Raise(p_event_name => 'oracle.apps.wf.notification.send',
                 p_event_key  => to_char(p_nid),
                 p_parameters => l_paramlist);

exception
  when others then
    wf_core.context('Wf_Notification', 'Resend', to_char(p_nid));
    raise;
end Resend;

--
-- getNtfResponse
-- Fetches result(response) CODE and response display prompt to the notification
-- IN
--  p_nid - Notification ID
-- OUT
--  p_result_code    Result code of the notification
--  p_result_display Display value of the result code

procedure getNtfResponse (p_nid     in  number,
                          p_result_code out nocopy varchar2,
                          p_result_display  out nocopy varchar2)
is
 l_result_type varchar2(250);
begin

  begin
    select A.RESULT_TYPE, IAS.ACTIVITY_RESULT_CODE
    into l_result_type, p_result_code
      from WF_ITEM_ACTIVITY_STATUSES_H IAS,
           WF_ACTIVITIES A,
           WF_PROCESS_ACTIVITIES PA,
           WF_ITEMS I
      where IAS.NOTIFICATION_ID     = p_nid
        and IAS.ITEM_TYPE           = I.ITEM_TYPE
        and IAS.ITEM_KEY            = I.ITEM_KEY
        and IAS.PROCESS_ACTIVITY    = PA.INSTANCE_ID
        and I.BEGIN_DATE between A.BEGIN_DATE
        and nvl(A.END_DATE, I.BEGIN_DATE)
        and PA.ACTIVITY_NAME        = A.NAME
        and PA.ACTIVITY_ITEM_TYPE   = A.ITEM_TYPE;
  exception
    when NO_DATA_FOUND then
      select A.RESULT_TYPE, IAS.ACTIVITY_RESULT_CODE
        into l_result_type, p_result_code
          from WF_ITEM_ACTIVITY_STATUSES IAS,
               WF_ACTIVITIES A,
               WF_PROCESS_ACTIVITIES PA,
               WF_ITEMS I
          where IAS.NOTIFICATION_ID     = p_nid
            and IAS.ITEM_TYPE           = I.ITEM_TYPE
            and IAS.ITEM_KEY            = I.ITEM_KEY
            and IAS.PROCESS_ACTIVITY    = PA.INSTANCE_ID
            and I.BEGIN_DATE between A.BEGIN_DATE
            and nvl(A.END_DATE, I.BEGIN_DATE)
            and PA.ACTIVITY_NAME        = A.NAME
            and PA.ACTIVITY_ITEM_TYPE   = A.ITEM_TYPE;
  end;

  p_result_display  := wf_core.activity_result( l_result_type, p_result_code );

exception
  when NO_DATA_FOUND then
    p_result_code  := null;
    p_result_display  := null;
  when others then
    wf_core.context('Wf_Notification', 'getNtfResponse', to_char(p_nid));
    raise;
end getNtfResponse;

--
-- PropagateHistory (PUBLIC)
--  This API allows Product Teams to publish custom action
--  to WF_COMMENTS table.
--
procedure PropagateHistory(p_item_type     in varchar2,
                           p_item_key      in varchar2,
                           p_document_id   in varchar2,
                           p_from_role     in varchar2,
                           p_to_role       in varchar2,
                           p_action        in varchar2,
                           p_action_source in varchar2,
                           p_user_comment  in varchar2)
is
 --Get the nids in curs_nid which have the attribute document_id
 cursor curs_nid(l_doc_id varchar2,l_item_type varchar2,l_item_key varchar2) is
   select wfn.notification_id
   from  wf_item_activity_statuses wfas, wf_notifications wfn , wf_notification_attributes wfna
   where wfna.name             = '#DOCUMENT_ID'
   and   wfna.text_value       =  l_doc_id
   and   wfas.item_type        =  l_item_type
   and   wfas.item_key         =  l_item_key
   and   wfn.notification_id   =  wfna.notification_id
   and   wfas.notification_id  =  wfn.group_id;
begin
  for comment_curs in curs_nid(p_document_id,p_item_type,p_item_key) loop
    --Now loop through the cursor and set the comments
    wf_notification.SetComments(p_nid           => comment_curs.notification_id,
                                p_from_role     => p_from_role,
                                p_to_role       => p_to_role,
                                p_action        => p_action,
                                p_action_source => p_action_source,
                                p_user_comment  => p_user_comment);
 end loop;
exception
  when others then
    wf_core.context('Wf_Notification', 'propagatehistory', p_item_type,p_item_key, p_document_id);
    raise;
end;

--
-- Resend_Failed_Error_Ntfs (CONCURRENT PROGRAM API)
--   API to re-enqueue notifications with mail_status FAILED and/or ERROR
--   in order to re-send them. Mailer had processed these notifications
--   earlier and updated the status since these notifications could not be
--   delivered/processed. Only FYI notifications with ERROR mail status
--   can be resent.
--
-- OUT
--   errbuf  - CP error message
--   retcode - CP return code (0 = success, 1 = warning, 2 = error)
-- IN
--   p_mail_status - Mail status that needs to be resent.
--                   ERROR - Only for FYI notifications
--                   FAILED - All notifications
--   p_msg_type - Message type of the notification
--   p_role     - Workflow role whose notifications are to be re-enqueued
--   p_from_date - Notifications sent on or after this date
--   p_to_date   - Notifications sent on before this date
--               - Type is varchar2 because CP reports problems with Date type
procedure Resend_Failed_Error_Ntfs(errbuf        out nocopy varchar2,
                                   retcode       out nocopy varchar2,
                                   p_mail_status in varchar2,
                                   p_msg_type    in varchar2,
                                   p_role        in varchar2,
                   p_from_date    in varchar2,
                   p_to_date      in varchar2 )
is
  l_errname  varchar2(30);
  l_errmsg   varchar2(2000);
  l_errstack varchar2(2000);
  l_nid      number;
  l_from_date date;
  l_to_date   date;

  -- Cursor def. for FAILED notification
  CURSOR c_failed_ntfs(cp_msg_type varchar2,
                       cp_role     varchar2,
               cp_from_date date,
               cp_to_date   date)
  IS
  SELECT notification_id
  FROM   wf_notifications wn
  WHERE  wn.status = 'OPEN'
  AND    wn.mail_status = 'FAILED'
  AND    wn.recipient_role like nvl(cp_role, '%')
  AND    wn.message_type like nvl(cp_msg_type, '%')
          --  No date conversion  is required on wn.begin_date
  AND   (cp_from_date is null or  wn.begin_date  >= cp_from_date)
  AND   (cp_to_date   is null or  wn.begin_date  <= cp_to_date ) ;

  -- Cussor for FYI errored out notifications
  CURSOR c_error_fyi_ntfs(cp_msg_type varchar2,
                          cp_role     varchar2 ,
              cp_from_date date,
                  cp_to_date   date)
  IS
  SELECT notification_id
  FROM   wf_notifications wn
  WHERE  wn.status = 'OPEN'
  AND    wn.mail_status = 'ERROR'
  AND    wn.recipient_role like nvl(cp_role, '%')
  AND    wn.message_type like nvl(cp_msg_type, '%')
  AND   (cp_from_date is null or wn.begin_date >= cp_from_date)
  AND   (cp_to_date   is null or wn.begin_date <= cp_to_date )
  AND NOT EXISTS (
         SELECT 1
         FROM   wf_message_attributes wma,
                wf_notifications wn2
         WHERE  wn2.notification_id = wn.notification_id
         AND    wma.message_type = wn2.message_type
         AND    wma.message_name = wn2.message_name
         AND    wma.subtype = 'RESPOND'
         AND    rownum = 1);

begin

  -- Convert from varchar2 to date format
  if(p_from_date is not null) then
   l_from_date := to_date(p_from_date, wf_core.canonical_date_mask);
  end if;

  if(p_to_date is not null) then
   l_to_date   := to_date(p_to_date, wf_core.canonical_date_mask);
  end if;

  -- if mail status is specified as null, both failed and errored
  -- ntfs require to be resent
  if (nvl(p_mail_status, 'FAILED') = 'FAILED') then
    open c_failed_ntfs(p_msg_type, p_role, l_from_date, l_to_date);
    loop
      fetch c_failed_ntfs into l_nid;
      exit when c_failed_ntfs%NOTFOUND;
      begin
        -- Raise event
    Wf_Notification.Resend(l_nid);

      exception
        when others then
          -- ignore any error while enqueing
          Wf_Core.Clear();
      end;
      commit;
    end loop;
    close c_failed_ntfs;
  end if;

  -- only errored FYI notifications are resent. For response required
  -- ntfs, the activity would be errored which can be retried
  if (nvl(p_mail_status, 'ERROR') = 'ERROR') then
    open c_error_fyi_ntfs(p_msg_type, p_role , l_from_date, l_to_date);
    loop
      fetch c_error_fyi_ntfs into l_nid;
      exit when c_error_fyi_ntfs%NOTFOUND;
      begin
         -- Raise event
     Wf_Notification.Resend(l_nid);
      exception
        when others then
          -- ignore any error while enqueing
          Wf_Core.Clear();
      end;
      commit;
    end loop;
    close c_error_fyi_ntfs;
  end if;

  -- successful completion
  errbuf := '';
  retcode := '0';
exception
  when others then
    -- get error message into errbuf
    wf_core.get_error(l_errname, l_errmsg, l_errstack);
    if (l_errmsg is not null) then
      errbuf := l_errmsg;
    else
      errbuf := sqlerrm;
    end if;

    -- return 2 for error
    retcode := '2';
end Resend_Failed_Error_Ntfs;


--
-- isFYI (INTERNAL ONLY)
--   This function checks whether a notification is FYI or Response
--   Required notification.
-- IN:
--   nid - Notification id to be checked
-- RETURNS:
--   boolean value true | false.
--
function isFYI(nid   in number)  return boolean
is
 l_resp_attr_cnt number := 0;
begin

  SELECT count(1)
  INTO   l_resp_attr_cnt
  FROM   wf_message_attributes wma,
         wf_notifications wn
  WHERE  wn.notification_id = nid
  AND    wma.message_type = wn.message_type
  AND    wma.message_name = wn.message_name
  AND    wma.subtype = 'RESPOND'
  AND    rownum = 1;

  -- Either NID does not exist or No RESPOND type attribute mean: FYI.
  if (l_resp_attr_cnt = 0) then
    return true;
  else
    return false;
  end if;

end isFYI;

--
-- Respond2
--   ER 10177347: Process the response to the notification when the performer
--   applies the response from worklist in deferred mode. It has the same
--   functionality as that of the respond() API except that it does not
--   call Complete procedure to complete the notification activity.
-- IN
--   nid Notification ID
--   respond_comment Respond Comment
--   responder Performer who responded to the notification
--   action_source For Internal Use Only
--   response_found boolean value that tells whether respond attributes exists or not
procedure Respond2(nid            in  number,
                  respond_comment in  varchar2 default null,
                  responder       in  varchar2 default null,
                  action_source   in  varchar2 default null,
                  response_found  out nocopy boolean)
is
  callback varchar2(240);
  context varchar2(2000);
  status varchar2(8);
  newcomment varchar2(4000);
  l_item_type WF_ITEM_TYPES.NAME%TYPE;
  l_item_key WF_ITEMS.ITEM_KEY%TYPE;
  l_act_id number;

  -- Dynamic sql stuff
  sqlbuf varchar2(2000);

  --Bug 2283697
  l_parameterlist        wf_parameter_list_t := wf_parameter_list_t();


  cursor notification_attrs_cursor(nid number) is
    select WNA.NAME, WMA.TYPE, WNA.TEXT_VALUE, WNA.NUMBER_VALUE,
           WNA.DATE_VALUE
    from WF_NOTIFICATION_ATTRIBUTES WNA,
      WF_MESSAGE_ATTRIBUTES WMA,
      WF_NOTIFICATIONS WN
    where WNA.NOTIFICATION_ID = nid
    and WN.NOTIFICATION_ID = WNA.NOTIFICATION_ID
    and WN.MESSAGE_TYPE = WMA.MESSAGE_TYPE
    and WN.MESSAGE_NAME = WMA.MESSAGE_NAME
    and WNA.NAME = WMA.NAME
    and WMA.SUBTYPE = 'RESPOND';

  aname varchar2(30);
  atype varchar2(8);
  tvalue varchar2(4000);
  nvalue number;
  dvalue date;

  -- kma bug2376058 digital signature support
  proxyuser varchar2(4000);

  --Bug 3065814
  l_recip_role varchar2(320);
  l_orig_recip_role varchar2(320);
  l_more_info_role varchar2(320);
  l_from_role   varchar2(320);
  l_dispname   VARCHAR2(360);
  l_responder  varchar2(320);
  l_found      boolean;
  l_dummy      varchar2(1);

  l_language        varchar2(30);

  --Bug 3827935
  l_charcheck boolean;

begin
  if (nid is null) then
    wf_core.token('NID', to_char(nid));
    wf_core.raise('WFSQL_ARGS');
  end if;

  -- kma bug2376058 digital signature support
  begin
    proxyuser := Wf_Notification.GetAttrText(nid, '#WF_PROXIED_VIA');
  exception
    when others then
      if (wf_core.error_name = 'WFNTF_ATTR') then
        -- Pass null result if no result attribute.
        wf_core.clear;
        proxyuser := '';
      else
        raise;
      end if;
  end;
  if ((proxyuser is not null) and (proxyuser <> '') and
      ((responder is null) or
       ((responder is not null) and (proxyuser <> responder)))) then
    wf_core.token('NID', to_char(nid));
    wf_core.raise('WFNTF_DIGSIG_USER_MISMATCH');
  end if;

  -- bug 2698999 Checking if ntf's signature requirements are met
  if (NOT Wf_Notification.NtfSignRequirementsMet(nid)) then
     wf_core.token('NID', to_char(nid));
     wf_core.raise('WFNTF_NOT_SIGNED');
  end if;

  -- Get callback, check for valid notification id.
  begin
    select N.CALLBACK, N.CONTEXT, N.STATUS, N.USER_COMMENT,
           N.RECIPIENT_ROLE, N.ORIGINAL_RECIPIENT,N.MORE_INFO_ROLE, N.FROM_ROLE, N.LANGUAGE
    into   respond2.callback, respond2.context, respond2.status, newcomment,
           l_recip_role,l_orig_recip_role,l_more_info_role, l_from_role, l_language
    from   WF_NOTIFICATIONS N
    where  N.NOTIFICATION_ID = nid
    for update nowait;
  exception
    when no_data_found then
      wf_core.token('NID', to_char(nid));
      wf_core.raise('WFNTF_NID');
  end;

  -- Check notification is open
  if (status <> 'OPEN') then
    wf_core.token('NID', to_char(nid));
    wf_core.raise('WFNTF_NID_OPEN');
  end if;

  -- Tag the DB session as this function can be call isolatedly
  -- but first needs to find the corresponding item type
  validate_context(respond2.context, l_item_type, l_item_key, l_act_id);
  WF_CORE.TAG_DB_SESSION(WF_CORE.CONN_TAG_WF, l_item_type);

  -- If we are in a different Fwk session, need to clear Workflow PLSQL state
  if (not Wfa_Sec.CheckSession) then
    Wf_Global.Init;
  end if;

  -- Bug 3065814
  -- Set the global context variables to appropriate values for this mode
  if (respond2.responder is not null and
        substr(respond2.responder, 1, 6) = 'email:') then
     -- If responded through mail then get the username from email
     GetUserfromEmail(respond2.responder, l_recip_role, l_responder, l_dispname, l_found);
     if (not l_found) then
        l_responder := 'email:' || l_responder;
     end if;
  else
     if (action_source = 'WA') then
        -- notification is responded by a proxy who is logged in and has a Fwk session
        g_context_proxy := Wfa_Sec.GetUser();
        l_responder := respond2.responder;
     elsif (action_source = 'RULE') then
        -- notification is responded by Routing Rule, the context user should be the user
        -- to whom the rule belongs who is actually responding to the notification
        g_context_proxy := null;
        l_responder := respond2.responder;
     else
        -- notification is responded by the recipient.
    -- responder should be respond2.responder
        g_context_proxy := null;
        l_responder := respond2.responder;
     end if;
  end if;

  -- Set the approrpiate responder to context user
  g_context_user := l_responder;

  if respond2.respond_comment is null then
     g_context_user_comment := Wf_Notification.GetAttrText(nid,'WF_NOTE',TRUE);
  else
     g_context_user_comment := respond2.respond_comment;
  end if;
  g_context_recipient_role := l_recip_role;
  g_context_original_recipient:= l_orig_recip_role;
  g_context_from_role := l_from_role;
  g_context_new_role  := '';
  g_context_more_info_role  := l_more_info_role;

  -- Call the callback in VALIDATE mode to execute the post notification
  -- function to perform some custom validation and reject the response by
  -- raising exception. If validation is already done in RESPOND mode, it
  -- can stay there... VALIDATE mode can be called back from outside of
  -- notification code also before calling the Wf_Notification.Respond API
  if (callback is not null) then
    --Bug 19474347. When the notification is responded from email, the responder
    --is set to email:<email-address>. This happens from WF_XML and WF_MAILER.
    --In this case use variable l_responder which already contains the actual user name.
    tvalue := l_responder;
    nvalue := nid;
    -- ### Review Note 2 - callback is from table
                -- Check for bug#3827935
    l_charcheck := wf_notification_util.CheckIllegalChar(callback);
    --Throw the Illegal exception when the check fails


     -- BINDVAR_SCAN_IGNORE
     sqlbuf := 'begin '||callback||
              '(:p1, :p2, :p3, :p4, :p5, :p6, :p7); end;';
     execute immediate sqlbuf using
      in 'VALIDATE',
      in context,
      in l_dummy,
      in l_dummy,
      in out tvalue,
      in out nvalue,
      in out dvalue;

     -- Call the callback in RESPOND mode to perform the post-notification
     -- callback if there is one. Note this should be before the response is
     -- actually processed to give the callback a chance to reject the response
     -- by raising an exception.

     -- ### Review Note 2 - callback is from table
     -- BINDVAR_SCAN_IGNORE
     -- sqlbuf := 'begin '||callback||
     --          '(:p1, :p2, :p3, :p4, :p5, :p6, :p7); end;';
     execute immediate sqlbuf using
      in 'RESPOND',
      in context,
      in l_dummy,
      in l_dummy,
      in out tvalue,
      in out nvalue,
      in out dvalue;

      tvalue := '';
      nvalue := '';
  end if;

  -- Append the respond_comment (if any) to the user_comment
  -- if (respond_comment is not null) then
  --   if (newcomment is not null) then
  --     newcomment := substrb(newcomment||wf_core.newline||
  --                   respond_comment, 1, 4000);
  --   else
  --     newcomment := respond_comment;
  --   end if;
  -- end if;

  -- Mark notification closed
  update WF_NOTIFICATIONS
  set STATUS = 'CLOSED',
      MAIL_STATUS = NULL,
      END_DATE = sysdate,
      -- RESPONDER = respond2.responder
      -- For responses through e-mail, this helps strip off unwanted parts from e-mail like
      -- "John Doe" <John.Doe@oracle.com> and have only email:John.Doe@oracle.com
      RESPONDER = l_responder
      -- USER_COMMENT = respond2.newcomment
  where NOTIFICATION_ID = respond2.nid;

  -- responder should be the From role that appears in the action history
  Wf_Notification.SetComments(nid, l_responder, 'WF_SYSTEM', 'RESPOND',
                              action_source, respond_comment);

  --Bug 2283697
  --To raise an EVENT whenever DML operation is performed on
  --WF_NOTIFICATIONS and WF_NOTIFICATION_ATTRIBUTES table.
  wf_event.AddParameterToList('NOTIFICATION_ID',nid,l_parameterlist);
  wf_event.AddParameterToList('RESPONDER',respond2.responder,l_parameterlist);

  -- AppSearch
  wf_event.AddParameterToList('OBJECT_NAME',
  'oracle.apps.fnd.wf.worklist.server.AllNotificationsVO', l_parameterlist);
  wf_event.AddParameterToList('CHANGE_TYPE', 'INSERT',l_parameterlist);
  wf_event.AddParameterToList('ID_TYPE', 'PK', l_parameterlist);
  wf_event.addParameterToList('PK_NAME_1', 'NOTIFICATION_ID',l_parameterlist);
  wf_event.addParameterToList('PK_VALUE_1', nid, l_parameterlist);
  wf_event.addParameterToList('PK_NAME_2', 'LANGUAGE',l_parameterlist);
  wf_event.addParameterToList('PK_VALUE_2', l_language, l_parameterlist);

  --Raise the event
  wf_event.Raise(p_event_name => 'oracle.apps.wf.notification.respond',
                 p_event_key  => to_char(nid),
                 p_parameters => l_parameterlist);

  -- If no callback, there is nothing else to do.
  if (callback is null) then
    return;
  end if;

  --
  -- Open dynamic sql cursor for SET callback calls.
  --
  -- ### Review Note 2 - callback is from table
  l_charcheck := wf_notification_util.CheckIllegalChar(callback);
  --Throw the Illegal exception when the check fails


   -- BINDVAR_SCAN_IGNORE
   sqlbuf := 'begin '||callback||
            '(:p1, :p2, :p3, :p4, :p5, :p6, :p7); end;';
   --
   -- Call callback to SET all RESPOND attributes for notification.
   --
   response_found := FALSE;
   for response_row in notification_attrs_cursor(nid) loop
    response_found := TRUE;

    aname := response_row.name;
    atype := response_row.type;
    tvalue := response_row.text_value;
    nvalue := response_row.number_value;
    dvalue := response_row.date_value;

    execute immediate sqlbuf using
      in 'SET',
      in context,
      in aname,
      in atype,
      in out tvalue,
      in out nvalue,
      in out dvalue;
  end loop;

exception
  when others then
    wf_core.context('Wf_Notification', 'Respond2', to_char(nid),
                    respond_comment, responder);
    -- This call is for enhanced error handling with respect to OAFwk
    wf_notification.SetUIErrorMessage;
    raise;
end Respond2;

--
-- process_response
--   ER 10177347: Determines that the notification response has to be
--   processed in synschronous mode or defer mode, calls the respond()
--   or respond2() API and enqueues the event into WF_NOTIFICATION_IN queue
--   accordingly based on the value of the parameter 'defer_response'
-- IN
--   nid Notification ID
--   respond_comment Respond Comment
--   responder Performer who responded to the notification
--   action_source For Internal Use Only
--   defer_response value of the profile option 'WF_NTF_DEFER_RESPONSE_PROCESS'
procedure process_response(nid       in number,
                     respond_comment in varchar2 default null,
                     responder       in varchar2 default null,
                     action_source   in varchar2 default null,
                     defer_response  in varchar2 default null)
is

  l_eventname       varchar2(60) := 'oracle.apps.wf.notification.wl.response.message';
  l_event           wf_event_t;
  l_parameterlist   wf_parameter_list_t := wf_parameter_list_t() ;
  l_agent           wf_agent_t := null ;

  l_itemType        WF_NOTIFICATIONS.MESSAGE_TYPE%TYPE  := null;
  l_lookupCode_cnt  number := 0;
  l_lookupType      FND_LOOKUP_VALUES.LOOKUP_TYPE%TYPE  := 'WF_NTF_RESP_DEFER_ITEM_TYPES';
  l_ntf_status      WF_NOTIFICATIONS.STATUS%TYPE;

  l_dummy_var       varchar2(400);
  response_found    boolean;


begin

  -- Get the item type of the notification
  WF_NOTIFICATION.GetInfo(nid,
                     l_dummy_var,
                     l_itemType,
                     l_dummy_var,
                     l_dummy_var,
                     l_dummy_var,
                     l_dummy_var);

  -- Check that whether the given item type exists in the
  -- WF_NTF_RESP_DEFER_ITEM_TYPES Lookup Type for 'SPECIFIC' case
  if(defer_response = 'SPECIFIC') then
        select  count(1)
        into    l_lookupCode_cnt
        from    fnd_lookup_values
        where   lookup_type = l_lookupType
        and     lookup_code = l_itemType
        and     security_group_id = 0
        and     view_application_id = 0 ;     -- for FND product view application id is 0
  end if;

  if(defer_response = 'ALL' or
          (defer_response = 'SPECIFIC' and l_lookupCode_cnt > 0)) then

     -- all response processing except callback in COMPLETE mode
     WF_NOTIFICATION.Respond2(nid, respond_comment, responder, action_source, response_found);

     -- prepare event payload
     l_agent := wf_agent_t(null, null);
     l_agent.name := 'WF_NOTIFICATION_IN';
     l_agent.SYSTEM := wf_event.local_system_name;

     wf_event_t.initialize(l_event);
     l_event.event_name := l_eventname;
     l_event.event_key := nid;
     l_event.setFromAgent(l_agent);
     l_event.setPriority(1);
     l_event.setCorrelationId(l_itemType);                       --  SET CORRID forcefully

     l_event.AddParameterToList('NOTIFICATION_ID', nid);         --  Set the Notification ID as event parameter
     l_event.AddParameterToList('Q_CORRELATION_ID', l_itemType); --  Set the Queue correlation id as item type
     l_event.AddParameterToList('BES_EVENT_NAME', l_eventname) ;
     l_event.AddParameterToList('BES_EVENT_KEY', nid) ;          --  Set NID as the BES_EVENT_KEY parameter

     if (response_found) then
         l_event.AddParameterToList('RESPONSE_FOUND', 'TRUE');
     else
         l_event.AddParameterToList('RESPONSE_FOUND', 'FALSE');
     end if;

     wf_event_ojmstext_qh.enqueue( l_event,  l_agent);

  else
     -- default synchronous processing
     wf_notification.respond(nid, respond_comment, responder, action_source);

  end if;


exception
  when others then
    wf_core.context('Wf_Notification', 'process_response', to_char(nid),
                    respond_comment, responder);
    wf_core.clear;
    -- This call is for enhanced error handling with respect to OAFwk
    wf_notification.SetUIErrorMessage;
    raise;

end process_response;


--
-- Complete
--   ER 10177347: This procedure executes the callback function in
--   COMPLETE mode to comeplete the notification activity
-- IN
--   p_nid Notification ID
procedure Complete(p_nid in number)

is
   callback          varchar2(240);
   context           varchar2(2000);
   sqlbuf            varchar2(2000);
   l_charcheck       boolean;
   tvalue            varchar2(4000);
   nvalue            number;
   dvalue            date;

   resource_busy     exception;
   pragma            EXCEPTION_INIT(resource_busy,-00054);

begin

  -- Call callback in COMPLETE mode to mark activity COMPLETE.
  -- Send the result and notification id as the value.
  --
  begin
    tvalue := Wf_Notification.GetAttrText(p_nid, 'RESULT');

  exception
    when others then
      if (wf_core.error_name = 'WFNTF_ATTR') then
        -- Pass null result if no result attribute.
        wf_core.clear;
        tvalue := '';
      else
        raise;
      end if;
  end;

  nvalue := p_nid;
  dvalue := '';

  begin
    select N.CALLBACK, N.CONTEXT
    into   Complete.callback, Complete.context
    from   WF_NOTIFICATIONS N
    where  N.NOTIFICATION_ID = p_nid
    for update nowait;
  exception
    when no_data_found then
      wf_core.token('NID', to_char(p_nid));
      wf_core.raise('WFNTF_NID');
  end;

   l_charcheck := wf_notification_util.CheckIllegalChar(callback);

   sqlbuf := 'begin '||callback||
                   '(:p1, :p2, :p3, :p4, :p5, :p6, :p7); end;';
   execute immediate sqlbuf using
    in 'COMPLETE',
    in context,
    in 'NID',
    in 'NUMBER',
    in out tvalue,
    in out nvalue,
    in out dvalue;


exception
  --This exception alone raise to caller
  when resource_busy then
    --Raise this exception to caller
    wf_core.context('WF_NOTIFICATION', 'Complete', to_char(p_nid));
    raise;

end Complete;

-- Bug 25385061
-- This procedure raises a business event to send Push Notifications.
-- The event is raised only for Item Types and Messages configured
-- for Approvals Data Services i.e., Item Types and Messages present
-- in table wf_wl_config_types
-- IN
-- role - Role to send notification to
-- msg_type - Message type
-- msg_name - Message name
-- subject - Subject

procedure RaisePushNotificationEvent(p_recipient_role in varchar2,
                                     p_msg_type       in varchar2,
                                     p_msg_name       in varchar2,
                                     p_nid            in number,
                                     p_is_more_info   in boolean default false)
is
  l_count number := 0;
  l_parameterlist wf_parameter_list_t := wf_parameter_list_t();
  l_subject varchar2(1000);
  l_app varchar2(100);
  l_status varchar2(100);

  l_orig_lang varchar2(64);
  l_orig_terr varchar2(64);
  l_orig_chrs varchar2(64);
  l_orig_date_format varchar2(64);
  l_orig_date_language varchar2(64);
  l_orig_calendar varchar2(64);
  l_orig_numeric_characters varchar2(64);
  l_orig_sort varchar2(64);
  l_orig_currency varchar2(64);
  l_orig_client_timezone varchar2(64);
  l_recip_lang varchar2(64);
  l_recip_terr varchar2(100);
  l_null varchar2(1) := null;
  l_dyn_call varchar2(100);
  l_event_name varchar2(100);

 begin

    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string2(wf_log_pkg.level_procedure,
          'wf.plsql.wf_notification.RaisePushNotificationEvent','BEGIN');
    end if;

    execute immediate 'select count(1) from wf_wl_config_types where item_type = :i1 and message_name = :i2'
      into l_count using p_msg_type, p_msg_name;

    if(l_count > 0) then
     -- l_app := 'com.oracle.ebs.atg.owf.Approvals';
     l_event_name := 'oracle.apps.mobile.approvals.push.event';
     -- Bug 27625117 : Get all the application bundle ids configured to the push notification
     -- event and raise that event using the fnd_mbl_notification.send to send the push notifications
         select status
         into l_status
         from wf_events
         where name=l_event_name;

         if (l_status <> 'ENABLED') then
           if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
               wf_log_pkg.string2(wf_log_pkg.level_statement,
                    'wf.plsql.wf_notification.RaisePushNotificationEvent',
                    'Push Notification event is not enabled');
           end if;
         return;
        end if;

      -- TODO: Create a new push ntf API, FND_MBL_NOTIFICATION.ShouldSend(p_username)
      -- that will check if there are valid registrations before the notification can
      -- be sent to avoid all below processing if the user has no push registrations

      -- Retain original NLS context
      wf_notification_util.getNLSContext(p_nlsLanguage => l_orig_lang,
                                         p_nlsTerritory => l_orig_terr,
                                         p_nlsCode => l_orig_chrs,
                                         p_nlsDateFormat => l_orig_date_format,
                                         p_nlsDateLanguage => l_orig_date_language,
                                         p_nlsNumericCharacters => l_orig_numeric_characters,
                                         p_nlsSort => l_orig_sort,
                                         p_nlsCalendar => l_orig_calendar);

      l_dyn_call := 'BEGIN :r1 := FND_MBL_NOTIFICATION.GetDeviceLang(:p1,:p2); END;';
      execute immediate (l_dyn_call) using out l_recip_lang, in p_recipient_role, in l_event_name;

      l_dyn_call := 'BEGIN :r1 := FND_MBL_NOTIFICATION.GetDeviceTerr(:p1,:p2); END;';
      execute immediate (l_dyn_call) using out l_recip_terr, in p_recipient_role, in l_event_name;

      -- Set NLS context to that of the push notification recipient. Only  language and
      -- territory are available from device registration, for rest of the NLS context,leave it to DB default
      wf_notification_util.SetNLSContext(p_nlsLanguage => l_recip_lang,
                                         p_nlsTerritory => l_recip_terr);

      -- Get subject in recipient's NLS context
      l_subject := wf_notification.GetSubject(p_nid, 'text/html');

      if (p_is_more_info) then
        l_subject := FND_MESSAGE.GET_STRING('FND','FND_MORE_INFO_REQUESTED')||' '||l_subject;
      end if;

      -- Reset to original NLS context
      wf_notification_util.SetNLSContext(p_nlsLanguage => l_orig_lang,
                                         p_nlsTerritory => l_orig_terr,
                                         p_nlsDateFormat => l_orig_date_format,
                                         p_nlsDateLanguage => l_orig_date_language,
                                         p_nlsNumericCharacters => l_orig_numeric_characters,
                                         p_nlsSort => l_orig_sort,
                                         p_nlsCalendar => l_orig_calendar);

      wf_event.AddParameterToList('WF_NOTIFICATION_ID', to_char(p_nid), l_parameterlist);

      l_dyn_call := 'BEGIN FND_MBL_NOTIFICATION.Send(:p1,:p2,:p3,:p4,:p5,:p6,:p7); END;';
      execute immediate (l_dyn_call)
        using in l_event_name, in p_recipient_role, in l_subject, in l_null, in l_null, in l_null, in l_parameterlist;

      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
          wf_log_pkg.string2(wf_log_pkg.level_statement,
                        'wf.plsql.wf_notification.RaisePushNotificationEvent',
                        'Raised the approvals app push event');
      end if;
    else
      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string2(wf_log_pkg.level_statement,
                        'wf.plsql.wf_notification.RaisePushNotificationEvent',
                        'The notification message type and message name does not exist in wf_wl_config_types');
      end if;
    end if;

    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string2(wf_log_pkg.level_procedure,
          'wf.plsql.wf_notification.RaisePushNotificationEvent','END');
    end if;

  exception
    when others then
      if (wf_log_pkg.level_exception >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string2(wf_log_pkg.level_exception,
                        'wf.plsql.wf_notification.RaisePushNotificationEvent',
                        'Error occurred when sending push notification: '||sqlerrm);
      end if;
end RaisePushNotificationEvent;


begin
  -- Loads the user's nls date mask
  g_nls_date_mask := sys_context('USERENV','NLS_DATE_FORMAT');

  if (instr(upper(g_nls_date_mask), 'HH') = 0) then
    g_nls_date_mask := g_nls_date_mask||' HH24:MI:SS';
  end if;



End WF_Notification;


/
