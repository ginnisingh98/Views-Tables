--------------------------------------------------------
--  DDL for Package Body AP_WEB_CC_NOTIFICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_CC_NOTIFICATIONS_PKG" AS
/* $Header: apwcnotb.pls 120.2 2005/10/02 20:11:05 albowicz noship $ */

align_start constant varchar2(1) := 'S';
align_total constant varchar2(1) := 'T';
align_right constant varchar2(1) := 'R';
table_vertical constant varchar2(1) := 'V';
table_horizontal constant varchar2(1) := 'H';


--
-- Private Variables
--
table_direction varchar2(1) := 'L';
table_type varchar2(1) := 'V';
table_width  varchar2(8) := '100%';
table_border varchar2(2) := '0';
table_cellpadding varchar2(2) := '3';
table_cellspacing varchar2(2) := '1';
table_bgcolor varchar2(7) := 'white';
th_bgcolor varchar2(7) := '#cccc99';
th_fontcolor varchar2(7) := '#336699';
th_fontface varchar2(80) := 'Arial, Helvetica, Geneva, sans-serif';
th_fontsize varchar2(2) := '2';
td_bgcolor varchar2(7) := '#f7f7e7';
td_fontcolor varchar2(7) := 'black';
td_fontface varchar2(80) := 'Arial, Helvetica, Geneva, sans-serif';
td_fontsize varchar2(2) := '2';

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
procedure NTF_Table(cells in wf_notification.tdType,
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
  l_table_width  varchar2(8) := table_width;
  l_table_border varchar2(2) := table_border;
  l_table_cellpadding varchar2(2) := table_cellpadding;
  l_table_cellspacing varchar2(2) := table_cellspacing;
  l_table_bgcolor varchar2(7) := table_bgcolor;
  l_th_bgcolor varchar2(7) := th_bgcolor;
  l_th_fontcolor varchar2(7) := th_fontcolor;
  l_th_fontface varchar2(80) := th_fontface;
  l_th_fontsize varchar2(2) := th_fontsize;
  l_td_bgcolor varchar2(7) := td_bgcolor;
  l_td_fontcolor varchar2(7) := td_fontcolor;
  l_td_fontface varchar2(80) := td_fontface;
  l_td_fontsize varchar2(2) := td_fontsize;

begin
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
     l_table_cellpadding := '1';
     l_table_cellspacing := '1';
  end if;

  if (cells.COUNT = 0) then
    rs := null;
    return;
  end if;
  rs := '<table width=100% border=0 cellpadding=0 cellspacing=0 '||l_dirAttr||
        '><tr><td>';
  rs := rs||wf_core.newline||'<table sumarry="" width='||l_table_width||
            ' border='||l_table_border||
            ' cellpadding='||l_table_cellpadding||
            ' cellspacing='||l_table_cellspacing||
            ' bgcolor='||l_table_bgcolor||' '||l_dirAttr||'>';

-- ### implement as generic log in the future
--  if (wf_notification.debug) then
--    dbms_output.put_line(to_char(cells.LAST));
--  end if;

  for i in 1..cells.LAST loop
--    if (wf_notification.debug) then
--      dbms_output.put_line(substrb('('||to_char(i)||')='||cells(i),1,254));
--    end if;
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
    elsif (alignv = 'T') then
      l_align := 'RIGHT';
    else
      l_align := 'CENTER';
    end if;

--    if (wf_notification.debug) then
--      dbms_output.put_line('modv = '||to_char(modv));
--    end if;

    colon := instrb(cells(i),':');
    l_width := substrb(cells(i), 2, colon-2);
    l_text  := substrb(cells(i), colon+1);   -- what is after the colon

    if ((l_type = 'V' and modv = 1) or (l_type = 'N' and modv = 1)
        or  (l_type = 'H' and i <= col)
        or  (alignv = 'T') ) then
      if (l_type = 'N') then
         rs := rs||wf_core.newline||'<td';
      else
         -- this is a header
         rs := rs||wf_core.newline||'<th';
      end if;
      if (l_type = 'V') then
         rs := rs||' scope=row';
      else
         rs := rs||' scope=col';
      end if;

      if (l_width is not null) then
        rs := rs||' width='||l_width;
      end if;
      rs := rs||' align='||l_align||' valign=baseline bgcolor='||
              l_th_bgcolor||'>';
      rs := rs||'<font color='||l_th_fontcolor||' face="'||l_th_fontface||'"'
              ||' size='||l_th_fontsize||'>';
      rs := rs||l_text||'</font>';
      if (l_type = 'N') then
        rs := rs||'</td>';
      else
        rs := rs||'</th>';
      end if;
    else
      -- this is regular data
      rs := rs||wf_core.newline||'<td';
      if (l_width is not null) then
        rs := rs||' width='||l_width;
      end if;
      rs := rs||' align='||l_align||' valign=baseline bgcolor='||
              l_td_bgcolor||'>';
      rs := rs||'<font color='||l_td_fontcolor||' face="'||l_td_fontface||'"'
              ||' size='||l_td_fontsize||'>';
      if (l_type = 'N') then
        rs := rs||'<b>'||l_text||'</b></font></td>';
      else
        rs := rs||l_text||'</font></td>';
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


FUNCTION formattitle(title IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
   RETURN '<table cellpadding="0" cellspacing="0" border="0" width="100%" summary="">'||
     '<tr><td width="100%" class="OraHeader">' || title ||
     '</td></tr><tr><td class="OraBGAccentDark"></td></tr></table>';
END formattitle;

FUNCTION CELL_TEXT(cell IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  RETURN SUBSTR(cell, INSTR(cell, ':')+1);
END CELL_TEXT;

PROCEDURE GET_NEW_CARD_NOTIFICATION(document_id IN VARCHAR2,
                                    display_type IN VARCHAR2,
                                    document IN OUT NOCOPY CLOB,
                                    document_type IN OUT NOCOPY VARCHAR2) IS
  colon number;
  l_request_id number;
  l_card_program_id number;
  l_new_count number := 0;
  l_unassigned_count number := 0;
  l_inactive_count number := 0;
  l_active_count number := 0;
  l_registered_count number := 0;

  buf varchar2(2000);
  title VARCHAR2(200);
  cells wf_notification.tdType;
  cellcnt number;
BEGIN
  if ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                 'ap.pls.AP_WEB_CC_NOTIFICATIONS_PKG.GET_NEW_CARD_NOTIFICATION',
                 'Document = '||display_type||','||document_id);
  end if;

  title := fnd_message.get_string('SQLAP', 'OIE_CC_INACTIVE_TITLE');

  colon := instr(document_id, ':');
  l_request_id := to_number(substr(document_id, 1, colon-1));
  l_card_program_id := to_number(substr(document_id, colon+1));

  select count(*), sum(decode(employee_id, null, 1, 0)), sum(decode(employee_id, null, 0, 1))
  into l_new_count, l_registered_count, l_active_count
  from ap_cards_all
  where request_id = l_request_id;

  select count(*) into l_inactive_count from ap_cards_all c
  where request_id = l_request_id
  and employee_id is null
  and 1 = (select count(*) from ap_card_emp_candidates e
            where e.card_id = c.card_id);

  l_unassigned_count := l_registered_count - l_inactive_count;

  cellcnt := 0;
  cells(cellcnt+1) := align_start||':'||FND_MESSAGE.get_string('SQLAP', 'OIE_CC_STATUS');
  cells(cellcnt+2) := align_right||':'||FND_MESSAGE.get_string('SQLAP', 'OIE_CC_COUNT');
  cellcnt := cellcnt + 2;

  -- Unassigned Credit Cards
  cells(cellcnt+1) := align_start||':'||FND_MESSAGE.get_string('SQLAP', 'OIE_CC_UNASSIGNED_CARDS');
  cells(cellcnt+2) := align_right||':'||to_char(l_unassigned_count);
  cellcnt := cellcnt + 2;

  -- Inactive Credit Cards
  cells(cellcnt+1) := align_start||':'||FND_MESSAGE.get_string('SQLAP', 'OIE_CC_INACTIVE_CARDS');
  cells(cellcnt+2) := align_right||':'||to_char(l_inactive_count);
  cellcnt := cellcnt + 2;

  -- Credit Cards Activated
  cells(cellcnt+1) := align_start||':'||FND_MESSAGE.get_string('SQLAP', 'OIE_CC_ACTIVATED_CARDS');
  cells(cellcnt+2) := align_right||':'||to_char(l_active_count);
  cellcnt := cellcnt + 2;

  -- New Credit Cards Registered
  cells(cellcnt+1) := align_total||':'||FND_MESSAGE.get_string('SQLAP', 'OIE_CC_TOTAL_PROMPT');
  cells(cellcnt+2) := align_right||':'||to_char(l_new_count);
  cellcnt := cellcnt + 2;

  IF display_type = WF_NOTIFICATION.doc_text THEN
    buf := title || fnd_global.local_chr(10);
    for i in 1..cellcnt/2 loop
      buf := buf || cell_text(cells(i*2-1))||': '||cell_text(cells(i*2))||fnd_global.local_chr(10);
    end loop;
    document_type := WF_NOTIFICATION.doc_text;
  ELSE
    ntf_table(cells,2,table_horizontal,buf);
    buf := '<h1>'||formattitle(title)||'</h1>'||buf;
    document_type := WF_NOTIFICATION.doc_html;
  END IF;
  WF_NOTIFICATION.writetoclob(document, buf);

EXCEPTION
  WHEN OTHERS THEN
    if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                   'ap.pls.AP_WEB_CC_NOTIFICATIONS_PKG.GET_NEW_CARD_NOTIFICATION',
                   sqlerrm);
    end if;
    RAISE;
END GET_NEW_CARD_NOTIFICATION;

PROCEDURE GET_VAL_ERROR_NOTIFICATION(document_id IN VARCHAR2,
                                    display_type IN VARCHAR2,
                                    document IN OUT NOCOPY CLOB,
                                    document_type IN OUT NOCOPY VARCHAR2) IS
  colon number;
  l_request_id number;
  l_card_program_id number;

  buf varchar2(2000);
  title VARCHAR2(200);
  cells wf_notification.tdType;
  cellcnt number;

  cursor cvalidation is
    select lookup_code, displayed_field
    from ap_lookup_codes
    where lookup_type = 'OIE_CC_VALIDATION_ERROR'
    and lookup_code not in ('INVALID_ALL' );
  valcnt NUMBER;
  totcnt NUMBER;
BEGIN
  if ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                 'ap.pls.AP_WEB_CC_NOTIFICATIONS_PKG.GET_VAL_ERROR_NOTIFICATION',
                 'Document = '||display_type||','||document_id);
  end if;

  title := fnd_message.get_string('SQLAP', 'OIE_CC_INVALID_TITLE');

  colon := instr(document_id, ':');
  l_request_id := to_number(substr(document_id, 1, colon-1));
  l_card_program_id := to_number(substr(document_id, colon+1));


  cells(1) := align_start||':'||FND_MESSAGE.get_string('SQLAP', 'OIE_CC_VALIDATION_PROMPT');
  cells(2) := align_right||':'||FND_MESSAGE.get_string('SQLAP', 'OIE_CC_COUNT');
  cellcnt := 2;

  totcnt := 0;
  FOR cvalrec IN cvalidation LOOP
    SELECT COUNT(*) INTO valcnt
    FROM AP_CREDIT_CARD_TRXNS_ALL
    WHERE request_id = l_request_id
    AND validate_code = cvalrec.lookup_code;

    IF valcnt > 0 THEN
      cells(cellcnt+1) := align_start||':'||cvalrec.displayed_field;
      cells(cellcnt+2) := align_right||':'||to_char(valcnt);
      cellcnt := cellcnt + 2;

      totcnt := totcnt + valcnt;
    END IF;
  END LOOP;

  cells(cellcnt+1) := align_total||':'||FND_MESSAGE.get_string('SQLAP', 'OIE_CC_TOTAL_PROMPT');
  cells(cellcnt+2) := align_right||':'||to_char(totcnt);
  cellcnt := cellcnt + 2;

  IF display_type = WF_NOTIFICATION.doc_text THEN
    buf := title || fnd_global.local_chr(10);
    for i in 2..cellcnt/2 loop
      buf := buf || cell_text(cells(i*2-1))||': '||cell_text(cells(i*2))||fnd_global.local_chr(10);
    end loop;
    document_type := WF_NOTIFICATION.doc_text;
  ELSE
    ntf_table(cells,2,table_horizontal,buf);
    buf := '<h1>'||formattitle(title)||'</h1>'||buf;
    document_type := WF_NOTIFICATION.doc_html;
  END IF;
  WF_NOTIFICATION.writetoclob(document, buf);

EXCEPTION
  WHEN OTHERS THEN
    if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                   'ap.pls.AP_WEB_CC_NOTIFICATIONS_PKG.GET_VAL_ERROR_NOTIFICATION',
                   sqlerrm);
    end if;
    RAISE;
END GET_VAL_ERROR_NOTIFICATION;


FUNCTION GET_INACTIVE_COUNT(l_request_id NUMBER) return NUMBER
IS
   l_inactive_count NUMBER;
BEGIN
   select count(*) into l_inactive_count from ap_cards_all c
   where request_id = l_request_id
   and employee_id is null
   and 1 = (select count(*) from ap_card_emp_candidates e
            where e.card_id = c.card_id);
   return l_inactive_count;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
    RETURN 0;
END;
END AP_WEB_CC_NOTIFICATIONS_PKG;

/
