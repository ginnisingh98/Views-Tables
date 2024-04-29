--------------------------------------------------------
--  DDL for Package Body WFE_HTML_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WFE_HTML_UTIL" as
/* $Header: wfehtmb.pls 120.4 2005/11/08 00:43:44 nravindr ship $ */

-- Private Type
type spanRecType is record (
  level   number,
  span    number
);

type spanTabType is table of spanRecType index by binary_integer;

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


--
-- RenderTitle (PRIVATE)
--   print out html code for the title
--
procedure RenderTitle (
  headerTab      headerTabType,
  spanTab        spanTabType,
  include_select boolean,
  include_delete boolean,
  detail_index   pls_integer  default 0,
  edit_index     pls_integer  default 0,
  title_start    pls_integer  default 0,
  level          number       default null
)
is
  i pls_integer;
  k pls_integer;

  prev_level pls_integer;

  include_edit   boolean;
  include_detail boolean;

  openrowcount pls_integer := 0;

begin
  if (headerTab.COUNT = 0) then
    return;  -- do not do anything if nothing to render
  end if;

  include_edit   := (edit_index > 0);
  include_detail := (detail_index > 0);

  if (spanTab.COUNT = 0) then
    -- simple table
    openrowcount := openrowcount + 1;

    for i in title_start..headerTab.COUNT loop
      -- include the row attribute here for the first data
      if (i=title_start) then
        if (headerTab(i).trattr is null) then
          htp.tableRowOpen(cattributes=>'bgcolor=#006699');
        else
          htp.p('<TR '||headerTab(i).trattr||'>');
        end if;
      end if;

      -- only include select before the first column
      if (i=title_start and include_select) then
        htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
              wf_core.translate('SELECT')||'</font>',
              calign=>'Center',
              cattributes=>'ID="' || wf_core.translate('SELECT') || '"');
      end if;

      htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
            headerTab(i).value||'</font>',
            calign=>'Center',
            cattributes=>'ID="' || headerTab(i).value || '"');
    end loop;
  else
    prev_level := -1;
    k := 0;
    -- group by table
    for i in title_start..headerTab.COUNT loop
      if (level is null or headerTab(i).level is null or
          level = headerTab(i).level) then
        if (headerTab(i).level is null or headerTab(i).level = 0) then
          if (prev_level = -1 or prev_level <> headerTab(i).level) then
            -- multi level
              if (prev_level <> -1) then
                htp.tableRowClose;
                openrowcount := openrowcount - 1;
              end if;
            prev_level := headerTab(i).level;

            if (headerTab(i).trattr is null) then
              htp.tableRowOpen(cattributes=>'bgcolor=#006699');
            else
              htp.p('<TR '||headerTab(i).trattr||'>');
            end if;
            openrowcount := openrowcount + 1;

            -- only include select before the first column
            if (include_select) then
              htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                    wf_core.translate('SELECT')||'</font>',
                    calign=>'Center',
                    cattributes=>'id="' || wf_core.translate('SELECT') ||'"');
            end if;
          end if;

          htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                headerTab(i).value||'</font>',
                calign=>'Center',
                cattributes=>headerTab(i).attr);
        elsif (headerTab(i).level <= 0 or
               headerTab(i).level > spanTab.COUNT) then
          null;  -- ignore such data
        else
          k := k+1;

          -- this is first multi level
          if (prev_level <> headerTab(i).level) then
            -- close the previous level row
            if (prev_level <> -1) then
              htp.tableRowClose;
              openrowcount := openrowcount - 1;
            end if;

            if (headerTab(i).trattr is null) then
              htp.tableRowOpen(cattributes=>'bgcolor=#006699');
            else
              htp.p('<TR '||headerTab(i).trattr||'>');
            end if;

            openrowcount := openrowcount + 1;
            prev_level := headerTab(i).level;
          end if;
          htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                headerTab(i).value||'</font>',
                calign=>'Center',
                ccolspan=>to_char(spanTab(k).span),
                cattributes=>headerTab(i).attr);
        end if;
      end if;  -- level matched
    end loop;
  end if;

  -- if show all levels or show level 0
  if (level is null or level = 0) then
    -- place these titles at the end
    if (include_detail) then
      htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
            headerTab(detail_index).value||'</font>',
            calign=>'Center',
            cattributes=>'id="' || headerTab(detail_index).value || '"');
    end if;

    -- include the edit title
    if (include_edit) then
      htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
            headerTab(edit_index).value||'</font>',
            calign=>'Center',
            cattributes=>'id="' || headerTab(edit_index).value || '"');
    end if;

    -- place the delete to the very end
    if (include_delete) then
      htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
            wf_core.translate('DELETE')||'</font>',
            calign=>'Center',
            cattributes=>'id="' || wf_core.translate('DELETE') ||'"');
    end if;
  end if;

  if (openrowcount > 0) then
    htp.tableRowClose;
    openrowcount := openrowcount - 1;
  end if;

exception
  when OTHERS then
    rollback;
    wf_core.context('WFE_HTML_UTIL', 'RenderTitle');
    wfe_html_util.Error;
end RenderTitle;

--
-- headerTab orders
--   FUNCTION
--    1. Delete
--    2. Detail
--    3. Edit
--   TITLE
--    1. Title for Detail Column
--    2. Title for Edit Column (if func_edit is defined, otherwise it is
--       the beginning of the rest of the titles)
--    3-X. Rest of the titles with descending level (e.g. 2, 1, 0)
--
--   NOTE
--    Set the color for the row in trattr
--      For headers, it tooks the definition for the first column not
--      counting the special columns above.
--
--    Set showtitle to TRUE if you want to show the title instead of a data
--
--
-- MODIFICATION LOG:
--    06-JUN-2001 JWSMITH BUG 1819232 - ADA Enhancement
--         - Added alt attr for IMG tag for ADA
--         - Added component to dataTable - tdattr to pass in table data
--           tag attributes.
--
procedure Simple_Table (
  headerTab  headerTabType,
  dataTab    dataTabType,
  tabattr    varchar2    default null,
  show_1st_title boolean default TRUE,
  show_level number      default null
)
is
  i pls_integer;
  j pls_integer;
  k pls_integer;
  m pls_integer;

  funccnt pls_integer := 0;
  colmcnt pls_integer := 0;
  colmcnt2 pls_integer := 0;
  title_start pls_integer;
  func_delete varchar2(4000);
  func_detail varchar2(4000);
  func_edit   varchar2(4000);
  include_select boolean := FALSE;
  include_delete boolean := FALSE;
  include_detail boolean := TRUE;  -- always include detail now

  detail_index pls_integer := 0;
  edit_index pls_integer := 0;

  spanTab    spanTabType;
  totalcol   pls_integer := 0;
  prev_level pls_integer;
  show       boolean := TRUE;
  hascspan   boolean := FALSE;
  l_td       varchar2(240);  -- table data tag content

  l_tabattr  varchar2(2000); -- table attributes
begin
  -- do not render table if both header and data are empty
  if (headerTab.COUNT = 0 and dataTab.COUNT = 0) then
    return;
  end if;

  -- calculate the function, column count and initial spancol values from
  -- the header table
  --
  -- Example
  --          | Del F | Dtl F | Edt F | Dtl T | Edt T | T | T | T |
  --                                      ^
  --                                      title_start
  -- funccnt =   1       2       3
  -- colmcnt =   0      -1      -2       -1      0      1   2   3
  --
  k := 0;
  if (headerTab.COUNT <> 0) then
    for i in 1..headerTab.COUNT loop
      if (headerTab(i).def_type = 'FUNCTION') then
        funccnt := funccnt + 1;
        if (funccnt = 1) then
          func_delete := headerTab(i).value;
        elsif (funccnt = 2) then
          func_detail := headerTab(i).value;
          colmcnt := -1; -- remove Detail column title
        elsif (funccnt = 3) then
          func_edit := headerTab(i).value;
          colmcnt := -2; -- remove both Detail and Edit column titles
        else
          colmcnt := 1 - funccnt; -- remove defined and custom function titles
        end if;
      elsif (headerTab(i).def_type = 'TITLE') then
        colmcnt := colmcnt + 1;

        if (title_start is null) then
          title_start := i;
        end if;

        -- record the initial colspan value
        if (headerTab(i).level is null or headerTab(i).level > 0) then
          k := k+1;
          spanTab(k).level := headerTab(i).level;
          spanTab(k).span  := nvl(headerTab(i).span, 0);

        -- record the total level 0 column count
        else
          totalcol := totalcol + 1;
        end if;
      end if;
    end loop;
  end if;

  -- Determine what titles should be included
  if (dataTab.COUNT <> 0) then
    for i in 1..dataTab.COUNT loop
      if (dataTab(i).selectable) then
        include_select := TRUE;
      end if;
      if (dataTab(i).deletable) then
        include_delete := TRUE;
      end if;

      exit when (include_select and include_delete and include_detail);
    end loop;
  end if;

  -- no detail is no detail function
  if (func_detail is null) then
    include_detail := FALSE;
  end if;

  -- now we resolve all the include criteria, we can update the spanTab
  --
  -- +----------------+--
  -- | colspan=span+1 |  ...  when select is included
  -- +----------------+--
  --
  if (spanTab.COUNT <> 0) then
    prev_level := -1;
    for k in 1..spanTab.COUNT loop
      i := 0;  -- index of last column of previous level.
               -- 0 means it is not the last column

      -- add 1 to the colspan of the first column if select is included
      if (spanTab(k).level <> prev_level) then
        if (include_select) then
          spanTab(k).span := spanTab(k).span + 1;
        end if;
        prev_level := spanTab(k).level;

        if (k <> 1) then
          i := k-1;  -- index of last column of previous level

        -- handle a corner case when this is the only element
        elsif (k = 1 and k = spanTab.COUNT) then
          i := k;
        end if;

      -- also handle a corner case if this is the last element
      elsif (k = spanTab.COUNT) then
          i := k;
      end if;

   -- For the last column
   --   --+--------------------+
   -- ... | colspan = span + x |  where x is sum of detail, delete and edit
   --   --+--------------------+  columns.
   --
      -- update the colspan of the last column
      if (i <> 0) then
        if (include_detail) then
          spanTab(i).span := spanTab(i).span + 1;
        end if;
        if (include_delete) then
          spanTab(i).span := spanTab(i).span + 1;
        end if;
        if (func_edit is not null) then
          spanTab(i).span := spanTab(i).span + 1;
        end if;
      end if;

    end loop;    -- for spanTab
  end if;

  -- Render the Table
  if (tabattr is not null) then
    l_tabattr := tabattr;
  else
    l_tabattr := 'border=1 cellpadding=3 bgcolor=white width=100% summary=""';
  end if;

  htp.tableOpen(cattributes=>l_tabattr);

  -- calculate the title_start
  -- 1. Have nothing
  --    title_start is correct, no recalculation
  --
  -- 2. Have Detail
  --    |Detail|   | ...
  --             ^
  --             title start here
  --
  -- 3. Have Edit but detail function is null
  --    funccnt > 2, because it has at least "Delete" and "Detail", even
  --    though detail_func is null.
  --    ... |Edit|   | ...
  --               ^
  --               title start here
  --
  -- Column headers
  if (headerTab.COUNT <> 0) then
    if (include_detail) then
      detail_index := title_start;
      title_start := title_start + 1;

    -- detail_func is null, but there is edit
    elsif (funccnt > 2) then
      title_start := title_start + 1;
    end if;

    if (func_edit is not null) then
      edit_index := title_start;
      title_start := title_start + 1;  -- may not have edit title
    end if;
  end if;

  -- Render title
  if (show_1st_title) then
    Wfe_Html_Util.RenderTitle(headerTab, spanTab,
      include_select, include_delete,
      detail_index, edit_index,
      title_start, show_level);
  end if;

  prev_level := -1;
  -- render the data portion only if there are rows.
  if (dataTab.COUNT <> 0) then
    for i in 1..dataTab.COUNT loop
      -- render title here
      if (dataTab(i).showtitle is not null and dataTab(i).showtitle) then
        Wfe_Html_Util.RenderTitle(headerTab, spanTab,
          include_select, include_delete,
          detail_index, edit_index,
          title_start, dataTab(i).level);

      -- normal data
      else

        -- if attribute for TR tag is defined, use it.
        if (dataTab(i).trattr is null) then
          htp.tableRowOpen(null, 'TOP');
        else
          htp.p('<TR '||dataTab(i).trattr||'>');
        end if;

        if (spanTab.COUNT = 0 or dataTab(i).level is null or
            dataTab(i).level = 0) then

          if (include_select) then
            if (dataTab(i).selectable) then
              htp.tableData(htf.formCheckbox(cname=>'h_guids',
                                             cvalue=>dataTab(i).guid,
                            cattributes=>'id="i_select'||i||'"'),
                            'CENTER',cattributes=>'id=""');
            else
              htp.tableData('&nbsp',cattributes=>'id=""');
            end if;
          end if;
          hascspan := FALSE;
          show := TRUE;
        elsif (dataTab(i).level <= 0) then
          show := FALSE; -- ignore such data
          hascspan := FALSE;
        else
          hascspan := TRUE;
          show := TRUE;
        end if;

        if (show) then
          -- set k to the index before the firs spanTab item on the same level
          k := 0;
          for j in 1..spanTab.COUNT loop
            if (dataTab(i).level = spanTab(j).level) then
              k := j-1;
              exit;
            end if;
          end loop;

          -- align the attribute column with level
          -- m will eventually be the real starting column
          j := 1;
          m := title_start+j-1;

          while (headerTab(m).level is not null and
                 dataTab(i).level is not null and
                 headerTab(m).level > dataTab(i).level) loop
            m := m+1;
          end loop;

          -- adjust the column count as well, so it won't overflow
          colmcnt2 := colmcnt - (m - (title_start+j-1));

          for j in 1..colmcnt2 loop
            l_td := '<TD ';

          -- JWSMITH bug 1819232 ADA Enhancement, add tdattr
            if (headerTab(m+j-1).attr is null) then
              l_td := l_td||'ALIGN=LEFT' || dataTab(i).tdattr;
            else
              l_td := REPLACE(UPPER(l_td||headerTab(m+j-1).attr),
                              'ID=', 'HEADERS=') || ' ' || dataTab(i).tdattr;
            end if;


            -- allow null col01 for indentation
            if (j = 1 /* and dataTab(i).col01 */) then
              if (hascspan) then
                k := k+1;
                l_td := l_td||' COLSPAN='||to_char(spanTab(k).span);
              end if;
              l_td := l_td||'>';
              htp.p(l_td);
              htp.p(dataTab(i).col01);
              htp.p('</TD>');
            elsif (j = 2 and dataTab(i).col02 is not null) then
              if (hascspan) then
                k := k+1;
                l_td := l_td||' COLSPAN='||to_char(spanTab(k).span);
              end if;
              l_td := l_td||'>';
              htp.p(l_td);
              htp.p(dataTab(i).col02);
              htp.p('</TD>');
            elsif (j = 3 and dataTab(i).col03 is not null) then
              if (hascspan) then
                k := k+1;
                l_td := l_td||' COLSPAN='||to_char(spanTab(k).span)||
                        ' BGCOLOR=#99CCFF';
              end if;
              l_td := l_td||'>';
              htp.p(l_td);
              htp.p(dataTab(i).col03);
              htp.p('</TD>');
            elsif (j = 4 and dataTab(i).col04 is not null) then
              if (hascspan) then
                k := k+1;
                l_td := l_td||' COLSPAN='||to_char(spanTab(k).span)||
                        ' BGCOLOR=#99CCFF';
              end if;
              l_td := l_td||'>';
              htp.p(l_td);
              htp.p(dataTab(i).col04);
              htp.p('</TD>');
            elsif (j = 5 and dataTab(i).col05 is not null) then
              if (hascspan) then
                k := k+1;
                l_td := l_td||' COLSPAN='||to_char(spanTab(k).span)||
                        ' BGCOLOR=#99CCFF';
              end if;
              l_td := l_td||'>';
              htp.p(l_td);
              htp.p(dataTab(i).col05);
              htp.p('</TD>');
            elsif (j = 6 and dataTab(i).col06 is not null) then
              if (hascspan) then
                k := k+1;
                l_td := l_td||' COLSPAN='||to_char(spanTab(k).span)||
                        ' BGCOLOR=#99CCFF';
              end if;
              l_td := l_td||'>';
              htp.p(l_td);
              htp.p(dataTab(i).col06);
              htp.p('</TD>');
            elsif (j = 7 and dataTab(i).col07 is not null) then
              if (hascspan) then
                k := k+1;
                l_td := l_td||' COLSPAN='||to_char(spanTab(k).span)||
                        ' BGCOLOR=#99CCFF';
              end if;
              l_td := l_td||'>';
              htp.p(l_td);
              htp.p(dataTab(i).col07);
              htp.p('</TD>');
            elsif (j = 8 and dataTab(i).col08 is not null) then
              if (hascspan) then
                k := k+1;
                l_td := l_td||' COLSPAN='||to_char(spanTab(k).span)||
                        ' BGCOLOR=#99CCFF';
              end if;
              l_td := l_td||'>';
              htp.p(l_td);
              htp.p(dataTab(i).col08);
              htp.p('</TD>');
            elsif (j = 9 and dataTab(i).col09 is not null) then
              if (hascspan) then
                k := k+1;
                l_td := l_td||' COLSPAN='||to_char(spanTab(k).span)||
                        ' BGCOLOR=#99CCFF';
              end if;
              l_td := l_td||'>';
              htp.p(l_td);
              htp.p(dataTab(i).col09);
              htp.p('</TD>');
            elsif (j = 10 and dataTab(i).col10 is not null) then
              if (hascspan) then
                k := k+1;
                l_td := l_td||' COLSPAN='||to_char(spanTab(k).span)||
                        ' BGCOLOR=#99CCFF';
              end if;
              l_td := l_td||'>';
              htp.p(l_td);
              htp.p(dataTab(i).col10);
              htp.p('</TD>');
            elsif (j = 11 and dataTab(i).col11 is not null) then
              if (hascspan) then
                k := k+1;
                l_td := l_td||' COLSPAN='||to_char(spanTab(k).span)||
                        ' BGCOLOR=#99CCFF';
              end if;
              l_td := l_td||'>';
              htp.p(l_td);
              htp.p(dataTab(i).col11);
              htp.p('</TD>');
            elsif (j = 12 and dataTab(i).col12 is not null) then
              if (hascspan) then
                k := k+1;
                l_td := l_td||' COLSPAN='||to_char(spanTab(k).span)||
                        ' BGCOLOR=#99CCFF';
              end if;
              l_td := l_td||'>';
              htp.p(l_td);
              htp.p(dataTab(i).col12);
              htp.p('</TD>');
            elsif (j = 13 and dataTab(i).col13 is not null) then
              if (hascspan) then
                k := k+1;
                l_td := l_td||' COLSPAN='||to_char(spanTab(k).span)||
                        ' BGCOLOR=#99CCFF';
              end if;
              l_td := l_td||'>';
              htp.p(l_td);
              htp.p(dataTab(i).col13);
              htp.p('</TD>');
            elsif (j = 14 and dataTab(i).col14 is not null) then
              if (hascspan) then
                k := k+1;
                l_td := l_td||' COLSPAN='||to_char(spanTab(k).span)||
                        ' BGCOLOR=#99CCFF';
              end if;
              l_td := l_td||'>';
              htp.p(l_td);
              htp.p(dataTab(i).col14);
              htp.p('</TD>');
            elsif (j = 15 and dataTab(i).col15 is not null) then
              if (hascspan) then
                k := k+1;
                l_td := l_td||' COLSPAN='||to_char(spanTab(k).span)||
                        ' BGCOLOR=#99CCFF';
              end if;
              l_td := l_td||'>';
              htp.p(l_td);
              htp.p(dataTab(i).col15);
              htp.p('</TD>');
            end if;
          end loop;
        end if;  -- show

        -- Place these columns at the end
        -- Detail (subscription) Column
        if (spanTab.COUNT = 0 or dataTab(i).level is null or
            dataTab(i).level = 0) then
          if (include_detail) then
            if (dataTab(i).hasdetail) then
              htp.tableData(htf.anchor2(
                    curl=>wfa_html.base_url||'/'||func_detail||
                          rawtohex(dataTab(i).guid),
                    ctext=>'<IMG SRC="'||
                             wfa_html.image_loc||'i_evsub.gif"
                      alt="' || wf_core.translate('WFE_EDIT_SUBSC_TITLE') || '"
                      BORDER=0>'),
                   'CENTER', cattributes=>'valign="MIDDLE" id=""');
            else
              htp.tableData(htf.anchor2(
                    curl=>wfa_html.base_url||'/'||func_detail||
                          rawtohex(dataTab(i).guid),
                    ctext=>'<IMG SRC="'||
                             wfa_html.image_loc||'i_evsub2.gif"
                    alt="' || wf_core.translate('WFE_ADD_SUBSCRIPTION') || '"
                    BORDER=0>'),
                   'CENTER', cattributes=>'valign="MIDDLE" id=""');
            end if;
          end if;

          -- Edit Column
          if (func_edit is not null) then
            htp.tableData(htf.anchor2(
                  curl=>wfa_html.base_url||'/'||func_edit||
                        rawtohex(dataTab(i).guid),
                  ctext=>'<IMG SRC="'||
                             wfa_html.image_loc||'i_edit.gif"
                     alt="' || wf_core.translate('EDIT') || '" BORDER=0>'),
                  'CENTER', cattributes=>'valign="MIDDLE" id=""');

          end if;

          -- place the delete at the very end
          if (include_delete) then
            if (dataTab(i).deletable) then
              htp.tableData(htf.anchor2(
                    curl=>'javascript:confirm_url('''||
                          wf_core.translate('WFE_OK_DELETE')||''','''||
                          wfa_html.base_url||'/'||func_delete||
                          rawtohex(dataTab(i).guid)||''')',
                    ctext=>'<IMG SRC="'||
                             wfa_html.image_loc||'i_del.gif"
                  alt="' || wf_core.translate('DELETE') || '"BORDER=0>'),
                   'CENTER', cattributes=>'valign="MIDDLE" id=""');
            else
              htp.tableData('&nbsp',cattributes=>'id=""');
            end if;
          end if;  -- include_delete

        end if; -- spanTab

        htp.tableRowClose;

      end if;  -- title/normal data

    end loop; -- dataTab

  end if;  -- dataTab has rows

  htp.tableClose;

  -- if no row, put a page break here
  if (dataTab.COUNT = 0) then
    htp.br;
  end if;

exception
  when OTHERS then
    rollback;
    wf_core.context('WFE_HTML_UTIL', 'Simple_Table');
    wfe_html_util.Error;
end Simple_Table;


--
-- generate_check_all
--   generate the javascript to check all the check boxes
-- IN
--   p_jscript_tag - if 'Y' generate the SCRIPT tag
--
procedure generate_check_all (
  p_jscript_tag in varchar2 default 'Y'
)
is
begin
  if (p_jscript_tag = 'Y') then
    htp.p('<SCRIPT LANGUAGE="JavaScript">');
    htp.p('<!-- Hide from old browsers');
  end if;

  htp.p('function checkAll(field) {
           for (i = 0; i < field.length; i++)
             field[i].checked = true;
         }');

  htp.p('function uncheckAll(field) {
           for (i = 0; i < field.length; i++)
             field[i].checked = false;
         }');

  if (p_jscript_tag = 'Y') then
    htp.p('<!-- done hiding from old browsers -->');
    htp.p('</SCRIPT>');
  end if;
end generate_check_all;

--
-- generate_confirm
--   generate the javascript to do the confirm box
-- IN
--   p_jscript_tag - if 'Y' generate the SCRIPT tag
--
procedure generate_confirm (
  p_jscript_tag in varchar2 default 'Y'
)
is
begin
  if (p_jscript_tag = 'Y') then
    htp.p('<SCRIPT LANGUAGE="JavaScript">');
    htp.p('<!-- Hide from old browsers');
  end if;

  htp.p('function confirm_url(msg, url) {
           if (window.confirm(msg)) {
             window.document.write("<html><!-- empty page --></html>");
             window.location.replace(url);
           }
         }');

  if (p_jscript_tag = 'Y') then
    htp.p('<!-- done hiding from old browsers -->');
    htp.p('</SCRIPT>');
  end if;
end generate_confirm;

-- gotoURL
--   javascript script implementation of go to an url
-- IN
--   p_url - the url provided
--
procedure gotoURL (
  p_url  in varchar2,
  p_noblankpage in varchar2 default null
)
is
begin
  if (p_url is null) then
    return;  -- do not go to a blank url
  end if;
  htp.p('<SCRIPT>');
  if (p_noblankpage is null) then
    -- place a blank page before replace it.
    htp.p('window.document.write("<html></html>")');
  end if;
  htp.p(' window.location.replace("'||p_url||'")');
  htp.p('</SCRIPT>');
end;

procedure test
is
  hTab headerTabType;
  dTab dataTabType;
  i pls_integer;
begin
  -- populate the values
  i := 1;
  hTab(i).def_type := 'FUNCTION';
  hTab(i).value := 'wf_event_html.DeleteEvent?h_guid=';
  i := i+1;
  hTab(i).def_type := 'FUNCTION';
  hTab(i).value := 'wf_event_html.ListSubscriptions';
  i := i+1;
  hTab(i).def_type := 'FUNCTION';
  hTab(i).value := 'wf_event_html.EditEvent?h_guid=';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value := wf_core.translate('SUBSCRIPTIONS');
  hTab(i).level := 0;
  hTab(i).attr     := 'id="'||wf_core.translate('SUBSCRIPTIONS')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value := wf_core.translate('EDIT');
  hTab(i).level := 0;
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('SYSTEM');
  hTab(i).level    := 2;
  hTab(i).span     := 3;
  hTab(i).trattr   := 'bgcolor=#069CCC';
  hTab(i).attr     := 'bgcolor=#ACCCCC';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := null;  -- indentation
  hTab(i).level    := 1;
  hTab(i).span     := 1;
  hTab(i).trattr   := 'bgcolor=#069CCC';
  hTab(i).attr     := 'bgcolor=#BCCCCC';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := wf_core.translate('EVENT');
  hTab(i).level    := 1;
  hTab(i).span     := 2;
  hTab(i).attr     := 'id="'||wf_core.translate('EVENT')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value    := null;  -- indentation
  hTab(i).level    := 0;
  hTab(i).trattr   := 'bgcolor=#069CCC';
  hTab(i).attr     := 'bgcolor=#ABCCCC';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value := wf_core.translate('DISPLAY_NAME');
  hTab(i).level := 0;
  hTab(i).attr     := 'id="'||wf_core.translate('DISPLAY_NAME')||'"';
  i := i+1;
  hTab(i).def_type := 'TITLE';
  hTab(i).value := wf_core.translate('NAME');
  hTab(i).level := 0;
  hTab(i).attr     := 'id="'||wf_core.translate('NAME')||'"';

  i := 1;
  dTab(i).guid := hextoraw('64F1FCEF78EE5934E0340800208ACA52');
  dTab(i).level:= 2;
  dTab(i).selectable := FALSE;
  dTab(i).deletable  := FALSE;
  dTab(i).hasdetail  := FALSE;
  dTab(i).trattr     := 'VALIGN=TOP bgcolor=#CCCCCC';
  dTab(i).col01      := 'system ora816';
  i := i+1;
  dTab(i).guid := hextoraw('64F1FCEF78EE5934E0340800208ACA52');
  dTab(i).level:= 1;
  dTab(i).selectable := FALSE;
  dTab(i).deletable  := FALSE;
  dTab(i).hasdetail  := FALSE;
  dTab(i).trattr     := 'VALIGN=TOP bgcolor=#CCCCCC';
  dTab(i).col01      := '';
  dTab(i).col02      := 'event.testing';
  i := i+1;
  dTab(i).guid := hextoraw('64F1FCEF78EE5934E0340800208ACA52');
  dTab(i).level:= 0;
  dTab(i).showtitle  := TRUE;
  i := i+1;
  dTab(i).guid := hextoraw('64F1FCEF78EE5934E0340800208ACA52');
  dTab(i).level:= 0;
  dTab(i).selectable := FALSE;
  dTab(i).deletable  := TRUE;
  dTab(i).hasdetail  := TRUE;
  dTab(i).trattr     := 'VALIGN=TOP bgcolor=white';
  dTab(i).col01      := '';
  dTab(i).col02      := 'Test Event 1';
  dTab(i).col03      := 'TEST_EVENT1';
  i := i+1;
  dTab(i).guid := hextoraw('64F1FCEF78EE5934E0340800208ACA55');
  dTab(i).level:= 0;
  dTab(i).selectable := FALSE;
  dTab(i).deletable  := TRUE;
  dTab(i).hasdetail  := TRUE;
  dTab(i).trattr     := 'VALIGN=TOP bgcolor=white';
  dTab(i).col01      := '';
  dTab(i).col02      := 'Test Event 2';
  dTab(i).col03      := 'TEST_EVENT2';

  -- Render Page
  htp.htmlOpen;
  htp.p('<BODY bgcolor=#CCCCCC>');
  Wfe_Html_Util.Simple_Table(hTab, dTab,
      tabattr=>'border=0 cellpadding=3 cellspacing=2 bgcolor=#CCCCCC width=100%',
      show_1st_title=>FALSE);
  htp.bodyClose;
  htp.htmlClose;
end Test;

end WFE_HTML_UTIL;

/
