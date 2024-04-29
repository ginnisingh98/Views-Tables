--------------------------------------------------------
--  DDL for Package Body JTF_DIAGNOSTIC_COREAPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DIAGNOSTIC_COREAPI" AS
/* $Header: jtfdiagcoreapi_b.pls 120.11.12000000.3 2007/04/05 09:33:32 rudas ship $ */


-----------------------------------------------------
--- HTML output APIs
-----------------------------------------------------

procedure line_out_html (text varchar2) is
   l_ptext      varchar2(32767);
   l_hold_num   number;
   tempClob     clob;
begin
   l_hold_num := mod(g_curr_loc, 32767);
   if l_hold_num + length(text) > 32759 then
      l_ptext := '<!--' || rpad('*', 32761-l_hold_num,'*') || '-->';
      --dbms_lob.write(g_hold_output, length(l_ptext), g_curr_loc, l_ptext);
      --dbms_lob.write(tempClob, length(l_ptext), g_curr_loc, l_ptext);
      --JTF_DIAGNOSTIC_ADAPTUTIL.setReportClob(tempClob);
      JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(l_ptext);
      g_curr_loc := g_curr_loc + length(l_ptext);
   end if;
   --dbms_lob.write(g_hold_output, length(text)+1, g_curr_loc, text || l_newline);
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(text||l_newline);
   --dbms_lob.write(tempClob, length(text)+1, g_curr_loc, text || l_newline);
   g_curr_loc := g_curr_loc + length(text)+1;
end line_out_html;


-- Procedure Name: Insert_Style_Sheet
--
-- Usage:
--      Insert_Style_Sheet;
--
-- Output:
--      Inserts a Style Sheet into the output
--
-- Comments:
--      This is not normally needed as the style sheet is automatically
--      inserted with the header.
--
procedure Insert_Style_Sheet_html is
styleSheet varchar2(5000);
begin
/*line_out('<style type="text/css">');
   line_out('<!--');
   line_out('.tab0 {font-size: 9pt; font-weight: normal}');
   line_out('.tab1 {text-indent: .25in; font-size: 9pt; font-weight: normal}');
   line_out('.tab2 {text-indent: .5in; font-size: 9pt; font-weight: normal}');
   line_out('.tab3 {text-indent: .75in; font-size: 9pt; font-weight: normal}');
   line_out('.error {color: #cc0000; font-size: 9pt; font-weight: normal}');
   line_out('.errorbold {font-weight: bold; color: #cc0000; font-size: 9pt}');
   line_out('.warning {font-weight: normal; color: #3c3c3c; font-size: 9pt}');
   line_out('.warningbold {font-weight: bold; color: #3c3c3c; font-size: 9pt}');
   line_out('.section {font-weight: normal; font-size: 9pt}');
   line_out('.sectionbold {font-weight: bold; font-size: 9pt}');
   line_out('.BigPrint {font-weight: bold; font-size: 12pt}');
   line_out('.SmallPrint {font-weight: normal; font-size: 8pt}');
   line_out('.BigError {color: #cc0000; font-size: 12pt; font-weight: bold}');
   line_out('body.report {background-color: white; font: normal 12pt Ariel;}');
   line_out('table.report {background-color: #f2f2f5 color:#000000; font-size: 9pt; font-weight: bold; line-height:1.5; padding:2px; text-align:left}');
   line_out('h1.report, h2.report, h3.report, h4.report {color: #00000}');
   line_out('h3.report {font-size: 16pt}');
   line_out('td.report {background-color: #eaeff5; color: #000000; font-weight: normal; font-size: 9pt; border-style: solid; border-width: 1; border-color: #c9cdb3; white-space: nowrap}');
   line_out('tr.report {background-color: #f2f2f5; color: #c3c3c3; font-weight: normal; font-size: 9pt; white-space: nowrap}');
   line_out('th.report {background-color: #cfe0f1; color: #000000; height: 20; border-style: solid; border-width: 1; border-left-color: #c9cdb3; border-right-color: #c9cdb3; border-top-width: 0; border-bottom-width: 0; white-space: nowrap}');
   line_out('th.rowh {background-color: #cfe0f1; color: #000000; height: 20; border-style: solid; border-width: 1; border-top-color: #c9cdb3; border-bottom-color: #c9cdb3; border-left-width: 0; border-right-width: 0; white-space: nowrap}');
   line_out('-->');
   line_out('</style>'); */
   styleSheet := '<style type="text/css">';
   styleSheet := concat(styleSheet, '<!--');
   styleSheet := concat(styleSheet, '.tab0 {font-size: 10pt; font-weight: normal}');
   styleSheet := concat(styleSheet, '.tab1 {text-indent: .25in; font-size: 10pt; font-weight: normal}');
   styleSheet := concat(styleSheet, '.tab2 {text-indent: .5in; font-size: 10pt; font-weight: normal}');
   styleSheet := concat(styleSheet, '.tab2 {text-indent: .5in; font-size: 10pt; font-weight: normal}');
   styleSheet := concat(styleSheet, '.tab3 {text-indent: .75in; font-size: 10pt; font-weight: normal}');
   styleSheet := concat(styleSheet, '.error {color: #cc0000; font-size: 10pt; font-weight: normal}');
   styleSheet := concat(styleSheet, '.errorbold {font-weight: bold; color: #cc0000; font-size: 10pt}');
   styleSheet := concat(styleSheet, '.warning {font-weight: normal; color: #336699; font-size: 10pt}');
   styleSheet := concat(styleSheet, '.warningbold {font-weight: bold; color: #336699; font-size: 10pt}');
   styleSheet := concat(styleSheet, '.section {font-weight: normal; font-size: 10pt}');
   styleSheet := concat(styleSheet, '.sectionbold {font-weight: bold; font-size: 10pt}');
   styleSheet := concat(styleSheet, '.BigPrint {font-weight: bold; font-size: 12pt}');
   styleSheet := concat(styleSheet, '.SmallPrint {font-weight: normal; font-size: 8pt}');
   styleSheet := concat(styleSheet, '.BigError {color: #cc0000; font-size: 12pt; font-weight: bold}');
   styleSheet := concat(styleSheet, 'body.report {background-color: white; font: normal 12pt Ariel;}');
   styleSheet := concat(styleSheet, 'table.report {background-color: #000000 color:#000000; font-size: 10pt; font-weight: bold; line-height:1.5; padding:2px; text-align:left}');
   styleSheet := concat(styleSheet, 'h1.report, h2.report, h3.report, h4.report {color: #00000}');
   styleSheet := concat(styleSheet, 'h3.report {font-size: 16pt}');
   styleSheet := concat(styleSheet, 'td.report {background-color: #f7f7e7; color: #000000; font-weight: normal; font-size: 9pt; border-style: solid; border-width: 1; border-color: #CCCC99; white-space: nowrap}');
   styleSheet := concat(styleSheet, 'tr.report {background-color: #f7f7e7; color: #000000; font-weight: normal; font-size: 9pt; white-space: nowrap}');
   styleSheet :=
		concat(styleSheet, 'th.report {background-color: #CCCC99; color: #336699; height: 20; border-style: solid; border-width: 1; border-left-color: #f7f7e7; border-right-color: #f7f7e7; border-top-width: 0; border-bottom-width: 0; white-space: nowrap}');
   styleSheet :=
		concat(styleSheet, 'th.rowh {background-color: #CCCC99; color: #336699; height: 20; border-style: solid; border-width: 1; border-top-color: #f7f7e7; border-bottom-color: #f7f7e7; border-left-width: 0; border-right-width: 0; white-space: nowrap}');
   styleSheet := concat(styleSheet, '-->');
   styleSheet := concat(styleSheet, '</style>');

   line_out(styleSheet);

end;

-- Procedure Name: Insert_HTML
--
-- Usage:
--      Insert_HMTL('String');
--
-- Parameters:
--      String - Any text string
--
-- Output:
--      Displays the text string
--
-- Examples:
--      begin
--         Insert_HTML('<em>This can be any text you want.</em>');
--      end;
--
-- Notes:
--      Usage of this procedure may make the script not compatible with
--      standards or 508.  Please avoid if possible.
--
procedure Insert_HTML_html(p_text varchar2) is
begin
   line_out(p_text);
end Insert_HTML_html;

-- Procedure Name: ActionErrorPrint
--
-- Usage:
--      ActionErrorPrint('String');
--
-- Parameters:
--      String - Any text string
--
-- Output:
--      Displays the text string with the word ACTION - prior to the string
--
-- Examples:
--      begin
--         ActionErrorPrint('Run Gather Schema Statistics');
--      end;
--
procedure ActionErrorPrint_html(p_text varchar2) is
begin
   line_out('<span class="errorbold">ACTION - </span><span class="error">'  || p_text || '</span><br/>');
end ActionErrorPrint_html;

-- Procedure Name: ActionPrint
--
-- Usage:
--      ActionPrint('String');
--
-- Parameters:
--      String - Any text string
--
-- Output:
--      Displays the text string
--
-- Examples:
--      begin
--         ActionPrint('Run Gather Schema Statistics');
--      end;
--
procedure ActionPrint_html(p_text varchar2) is
begin
   line_out(p_text || '<br/>');
end ActionPrint_html;

-- Procedure Name: ActionWarningPrint
--
-- Usage:
--      ActionWarningPrint('String');
--
-- Parameters:
--      String - Any text string
--
-- Output:
--      Displays the text string in warning format
--
-- Examples:
--      begin
--         ActionWarningPrint('Run Gather Schema Statistics');
--      end;
--
procedure ActionWarningPrint_html(p_text varchar2) is
begin
   line_out('<span class="warningbold">ACTION - </span><span class="warning">'  || p_text || '</span><br/>');
end ActionWarningPrint_html;

-- Procedure Name: WarningPrint
--
-- Usage:
--      WarningPrint('String');
--
-- Parameters:
--      String - Any text string
--
-- Output:
--      Displays the text string in warning format
--
-- Examples:
--      begin
--         WarningPrint('Statistics are not up to date');
--      end;
--
procedure WarningPrint_html(p_text varchar2) is
begin
   line_out('<span class="warningbold">WARNING - </span><span class="warning">'  || p_text || '</span><br/>');
end WarningPrint_html;

-- Procedure Name: ActionErrorLink
--
-- Usage:
--      ActionErrorLink('Pre_String','Note_Number','Post_String');
--      ActionErrorLink('Pre_String','URL','Link_Text', 'Post_String');
--
-- Parameters:
--      Pre_String - Text to appear prior to the link
--      Note_Number - Number of a metalink note to link to
--      URL - Any valid URL
--      Link_Text - Text for the link to URL
--      Post_String - Text to appear after the link
--
-- Output:
--      Displays the pre-link string, the link (as specified either by the
--      note number or by the URL and link text), and the post-link string
--      all in the format of an Error Action
--
-- Examples:
--      begin
--         ActionErrorLink('For clarification see note', 112233.1,
--           'which provides more information on the subject');
--         ActionErrorLink('For clarification see the',
--           'http://someurl.us.com/somepage.html','Development Homepage',
--           'which provides more information on the subject');
--      end;
--
procedure ActionErrorLink_html(p_txt1 varchar2
         , p_note varchar2
         , p_txt2 varchar2) is
begin
   line_out('<span class="errorbold">ACTION - </span><span class="error">'
         || p_txt1
         || ' <a href="http://metalink.oracle.com/metalink/plsql/ml2_documents.showDocument?p_database_id=NOT&amp;p_id='
         || p_note
         || '">'
         || p_note
         || '</a> '
         || p_txt2
         || '</span><br/>');
end ActionErrorLink_html;

procedure ActionErrorLink_html(p_txt1 varchar2
         , p_url varchar2
         , p_link_txt varchar2
         , p_txt2 varchar2) is
begin
   line_out('<span class="errorbold">ACTION - </span><span class="error">'
         || p_txt1
         || ' <a href="'
         || p_url
         || '">'
         || p_link_txt
         || '</a> '
         || p_txt2
         || '</span><br/>');
end ActionErrorLink_html;

-- Procedure Name: ActionWarningLink
--
-- Usage:
--      ActionWarningLink('Pre_String','Note_Number','Post_String');
--      ActionWarningLink('Pre_String','URL','Link_Text', 'Post_String');
--
-- Parameters:
--      Pre_String - Text to appear prior to the link
--      Note_Number - Number of a metalink note to link to
--      URL - Any valid URL
--      Link_Text - Text for the link to URL
--      Post_String - Text to appear after the link
--
-- Output:
--      Displays the pre-link string, the link (as specified either by the
--      note number or by the URL and link text), and the post-link string
--      all in the format of a Warning Action
--
-- Examples:
--      begin
--         ActionWarningLink('For clarification see note', 112233.1,
--           'which provides more information on the subject');
--         ActionWarningLink('For clarification see the',
--           'http://someurl.us.com/somepage.html','Development Homepage',
--           'which provides more information on the subject');
--      end;
--

procedure ActionWarningLink_html(p_txt1 varchar2
                          , p_note varchar2
                          , p_txt2 varchar2) is
begin
   line_out('<span class="warningbold">ACTION - </span><span class="warning">'
         || p_txt1
         || ' <a href="http://metalink.oracle.com/metalink/plsql/'
         || 'ml2_documents.showDocument?p_database_id=NOT&amp;p_id='
         || p_note
         || '">'
         || p_note
         || '</a> '
         || p_txt2
         || '</span><br/>');
end ActionWarningLink_html;

procedure ActionWarningLink_html(p_txt1 varchar2
           , p_url varchar2
           , p_link_txt varchar2
           , p_txt2 varchar2) is
begin
   line_out('<span class="warningbold">ACTION - </span><spanclass="warning">'
         || p_txt1
         || ' <a href="'
         || p_url
         || '">'
         || p_link_txt
         || '</a> '
         || p_txt2
         || '</span><br/>');
end ActionWarningLink_html;

-- Procedure Name: ErrorPrint
--
-- Usage:
--      ErrorPrint('String');
--
-- Parameters:
--      String - Any text string
--
-- Output:
--      Displays the text string
--
-- Examples:
--      begin
--         ErrorPrint('Statistics have not been run');
--      end;
--
procedure ErrorPrint_html(p_text varchar2) is
begin
   line_out('<span class="errorbold">ERROR - </span><span class="error">'  || p_text || '</span><br/>');
end ErrorPrint_html;

-- Procedure Name: SectionPrint
--
-- Usage:
--      SectionPrint('String');
--
-- Parameters:
--      String - Any text string
--
-- Output:
--      Displays the text string in bold print
--
-- Examples:
--      begin
--         SectionPrint('Checking OE Parameters');
--      end;
--
procedure SectionPrint_html (p_text varchar2) is
begin
   line_out('<br/><span class="sectionbold">' || p_text || '</span><br/>');
end SectionPrint_html;

-- Procedure Name: Tab0Print
--
-- Usage:
--      Tab0Print('String');
--
-- Parameters:
--      String - Any text string
--
-- Output:
--      Displays the text string with no indentation
--
-- Examples:
--      begin
--         Tab0Print('Layer 0');
--      end;
--
procedure Tab0Print_html (p_text varchar2) is
begin
   line_out('<div class="tab0">' || p_text || '</div>');
end Tab0Print_html;

-- Procedure Name: Tab1Print
--
-- Usage:
--      Tab1Print('String');
--
-- Parameters:
--      String - Any text string
--
-- Output:
--      Displays the text string indented .25 inch
--
-- Examples:
--      begin
--         Tab1Print('Layer 1');
--      end;
--
procedure Tab1Print_html (p_text varchar2) is
begin
   line_out('<div class="tab1">' || p_text || '</div>');
end Tab1Print_html;

-- Procedure Name: Tab2Print
--
-- Usage:
--      Tab2Print('String');
--
-- Parameters:
--      String - Any text string
--
-- Output:
--      Displays the text string indented .50 inch
--
-- Examples:
--      begin
--         Tab2Print('Layer 2');
--      end;
--
procedure Tab2Print_html (p_text varchar2) is
begin
   line_out('<div class="tab2">' || p_text || '</div>');
end Tab2Print_html;

-- Procedure Name: Tab3Print
--
-- Usage:
--      Tab3Print('String');
--
-- Parameters:
--      String - Any text string
--
-- Output:
--      Displays the text string indented .75 inch
--
-- Examples:
--      begin
--         Tab3Print('Layer 3');
--      end;
--
procedure Tab3Print_html (p_text varchar2) is
begin
   line_out('<div class="tab3">' || p_text || '</div>');
end Tab3Print_html;

-- Procedure Name: BRPrint
--
-- Usage:
--      BRPrint;
--
-- Output:
--      Displays a blank Line
--
-- Examples:
--      begin
--         Tab3Print('Layer 3');
--         BRPrint;
--         Tab3Print('Layer 4');
--      end;
--
procedure BRPrint_html is
begin
   line_out('<br/>');
end BRPrint_html;

-- Procedure Name: CheckFinPeriod
--
-- Usage:
--    CheckFinPeriod('Set of Books ID','Application ID');
--
-- Paramteters:
--    Set of Books ID - ID for the set of books
--    Application ID - ID of the application whose periods are being checked
--
-- Output:
--    List the number of defined and open periods. Indicate the latest
--    open period. Produce warnings if no periods are open or if the
--    current date is not in an open period.
--
-- Examples:
--    CheckFinPeriod(62, 222);  -- Check open periods for AR SOB 62
--    CheckFinPeriod(202, 201); -- Check open periods for PO SOB 202
--
-- BVS-START <- Starting ignoring this section

procedure checkFinPeriod_html (p_sobid NUMBER, p_appid NUMBER ) IS
l_appname            VARCHAR2(50) :=NULL;
l_period_name        VARCHAR2(50);
l_user_period_type   VARCHAR2(50);
l_start_date         DATE;
l_end_date           DATE;
l_sysdate            DATE;
l_sysopen            VARCHAR2(1);

CURSOR C1 IS
  select   a.name sobname,
           count(b.period_name) total_periods,
           count(decode(b.closing_status,'O',b.PERIOD_NAME,null)) open_periods,
           a.accounted_period_type period_type
  from     gl_sets_of_books a,
           gl_period_statuses b
  where    a.set_of_books_id = b.set_of_books_id (+)
  and      b.application_id = p_appId
  and      a.set_of_books_id = p_sobId
  and      b.period_type = a.accounted_period_type
  group by a.name, a.accounted_period_type;

c1_rec  c1%rowtype;
no_rows exception;

BEGIN

select application_name
into   l_appname
from   fnd_application_vl
where  application_id = p_appid ;

open c1;
fetch c1 into c1_rec;
IF c1%notfound THEN
  raise no_rows;
END IF;

select user_period_type into l_user_period_type
from   gl_period_types
where  period_type = c1_rec.period_type;

Tab1Print('Set of books '|| c1_rec.sobname ||' for application '
  || l_appname || ' has ' || to_char(c1_rec.total_periods)
  || ' periods defined and '|| to_char(c1_rec.open_periods)
  || ' periods open for period type '|| l_user_period_type);
IF c1_rec.total_periods = 0 THEN
  WarningPrint('There are no periods defined for this Set of books');
  ActionWarningPrint('There must be periods defined for this set of books');
END IF;
IF c1_rec.open_periods = 0 THEN
  WarningPrint('There are no open periods defined for this Set of books');
  ActionWArningprint('Please consider opening a period for this '||
    'application and set of books');
ELSE
  BEGIN
    SELECT  period_name, start_date, end_date, sysdate
    INTO    l_period_name, l_start_date, l_end_date, l_sysdate
    FROM gl_period_statuses
    WHERE adjustment_period_flag = 'N'
    AND   period_type = c1_rec.period_type
    AND   start_date = (
      SELECT MAX(start_date)
      FROM gl_period_statuses
      WHERE  closing_status = 'O'
      AND    adjustment_period_flag = 'N'
      AND    period_type = c1_rec.period_type
      AND    application_id = p_appId
      AND    set_of_books_id = p_sobId )
    AND closing_status  = 'O'
    AND application_id  =  p_appId
    AND set_of_books_id = p_sobId;

/* check if sysdate is in the latest open period*/
    l_sysopen := 'N';
    IF  l_sysdate >= l_start_date AND l_sysdate <= l_end_date THEN
       l_sysOpen := 'Y';
    END IF;
    Tab1Print('Latest open period is '|| l_period_name
      || ' with a start date of '|| to_char(l_start_date)
      || ' and an end date of ' || to_char(l_end_date) );
    IF l_sysopen = 'Y' THEN
      Tab2Print('Current date '|| to_char(l_sysdate)
        || ' is in the latest open period');
    ELSE
      BEGIN
        SELECT period_name, start_date, end_date, sysdate
        INTO   l_period_name, l_start_date, l_end_date, l_sysdate
        FROM   gl_period_statuses
        WHERE  adjustment_period_flag = 'N'
        AND    period_type = c1_rec.period_type
        AND    sysdate between start_date and end_date
        AND    closing_status = 'O'
        AND    application_id = p_appId
        AND    set_of_books_id = p_sobId;

        Tab2Print('Current date '|| to_char(sysDate)
          || ' is in the open period ' || l_period_name
          || ' with a start date of ' || to_char(l_start_date)
          || ' and an end date of ' || to_char(l_end_date) );

      EXCEPTION WHEN NO_DATA_FOUND THEN
        WarningPrint('Current date '|| to_char(l_sysdate)
          || ' is not in an open period');
        ActionwarningPrint('Please consider opening the current period');
      END;
    END IF;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    /* not really possible to fall in this exception as we already
       checked that there were open periods */
    WarningPrint('There are no open periods defined for this Set of books');
    ActionWArningprint('Please consider opening a period for this '||
      'application and set of books');
  END;
END IF;
EXCEPTION
  WHEN NO_ROWS THEN
    WarningPrint('There are no accounting periods defined in '||
      'gl_period_statuses for this application and set of books');
    ActionWArningprint('If required, define the accounting calendar for this '||
      'application and set of books');
  WHEN NO_DATA_FOUND THEN
    ErrorPrint('Invalid Application id passed to checkFinPeriod');
    ActionErrorPrint('Application id ' || to_char(p_appid)
      || ' is not valid on this system');
  WHEN OTHERS THEN
    ErrorPrint(sqlerrm||' occurred in CheckFinPeriod');
    ActionErrorPrint('Report this error to your support representative');
END checkFinPeriod_html;

-- BVS-STOP  <- Stop ignoring this section (restart scanning)


-- Function  Name: CheckKeyFlexfield
-- Procedure Name: CheckKeyFlexfield
--
-- Usage:
--      CheckKeyFlexfield('Key Flex Code','Flex Structure ID','Print Header');
--
-- Parameters:
--      Key Flex Code - The code of the Key Flexfield to be displayed.  For
--                      example, for the Accounting Flexfield use 'GL#'.
--      Flex Structure ID - The id_flex_num of the specific structure
--                          of the key flexfield whose details are to be
--                          displayed.  If null, print details of all
--                          structures. (default NULL)
--      Print Header - A boolean (true or false) indicating whether the output
--                     should print a heading before outputting the details
--                     of the key flexfield. (default TRUE)
-- Returns:
--      If value has been provided for the Flex Structure ID, the function
--      will returns an array of character strings with the following structure
--         1 name of the flexfield
--         2 enabled flag
--         3 frozen flag
--         4 dynamic instert flag
--         5 cross validation allowed flag
--         6 number of enabled segments defined
--         7 number of enabled segments with value sets
--         8 Y if any segment has security otherwise N
--      If no value is passed to the parameter the function will return an
--      array will null values.:w
--
-- Output:
--      Displays key information about the flexfield, its structure, and the
--      individual flexfield segments that make it up.
--
-- Examples:
--      declare
--         flexarray V2T;
--      begin
--         CheckKeyFlexfield('GL#', 50577, true);
--         CheckKeyFlexfield('MSTK',  null, false);
--         flexarray := CheckKeyFlexfield('GL#', 12345, false);
--      end;
--
-- BVS-START <- Starting ignoring this section

Function CheckKeyFlexfield_html(p_flex_code     in varchar2
                       ,   p_flex_num  in number default null
                       ,   p_print_heading in boolean default true)
return V2T is

l_ret_array         V2T := V2T(null,null,null,null,null,null,null,null);
l_no_value_sets     integer := 0;
l_any_sec_enabled   varchar2(1) := 'N';
l_sec_enabled       varchar2(1) := 'N';
l_flex_name         fnd_id_flexs.id_flex_name%type;
l_counter           integer := 0;
l_counter2          integer := 0;
l_num_segs          integer := 0;
l_num_segs_vs       integer := 0;
l_rule_count        integer := 0;
l_rule_assign_count integer := 0;
l_value_set_str     varchar2(400);
leave_api           exception;

cursor get_structs (p_f_code varchar2, p_f_num number) is
  select id_flex_num                   flex_str_num,
         id_flex_structure_name        flex_str_name,
         to_char(last_update_date,'MM-DD-YYYY HH24:MI:SS') last_updated,
         cross_segment_validation_flag cross_val,
         dynamic_inserts_allowed_flag  dyn_insert,
         enabled_flag                  enabled,
         freeze_flex_definition_flag   frozen
  from   fnd_id_flex_structures_vl
  where  id_flex_code = p_f_code
  and    enabled_flag ='Y'
  and    id_flex_num = nvl(p_f_num,id_flex_num);

cursor get_segments (p_f_code varchar2, p_f_num number) is
  select s.application_column_name          col_name,
         s.segment_name                     seg_name,
         s.segment_num                      seg_num,
         s.enabled_flag                     enabled,
         s.required_flag                    required,
         s.display_flag                     displayed,
         s.flex_value_set_id                value_set_id,
         vs.flex_value_set_name             value_set_name,
         DECODE(vs.validation_type,
              'I', 'Independent', 'N', 'None',  'D', 'Dependent',
              'U', 'Special',     'P', 'Pair',  'F', 'Table',
              'X', 'Translatable Independent',  'Y', 'Translatable Dependent',
              vs.validation_type)           validation_type,
         s.security_enabled_flag            seg_security,
         nvl(vs.security_enabled_flag,'N')  value_set_security
  from   fnd_id_flex_segments_vl s, fnd_flex_value_sets vs
  where  s.flex_value_set_id = vs.flex_value_set_id (+)
  and    s.id_flex_code = p_f_code
  and    s.id_flex_num =  p_f_num
  order by s.segment_num ;

cursor get_qualifiers(p_f_code varchar2, p_f_num number, p_col_name varchar2) is
  select segment_prompt
  from fnd_segment_attribute_values sav,
       fnd_segment_attribute_types  sat
  where sav.attribute_value = 'Y'
  and   sav.segment_attribute_type <> 'GL_GLOBAL'
  and   sav.application_id = sat.application_id
  and   sav.id_flex_code = sat.id_flex_code
  and   sav.segment_attribute_type = sat.segment_attribute_type
  and   sav.id_flex_code = p_f_code
  and   sav.id_flex_num =  p_f_num
  and   sav.application_column_name = p_col_name;

begin
  begin
    select id_flex_name into l_flex_name
    from   fnd_id_flexs
    where id_flex_code = p_flex_code;
  exception when no_data_found then
    WarningPrint('ID Flex Code passed '||p_flex_code||' is not valid on this '||
      'system');
    ActionWarningPrint('ID Flex Code '||p_flex_code||' will not be tested');
  end;

  BRPrint;
  if p_flex_num is null then
    if (p_print_heading) then
      SectionPrint('Details of Key flexfield: '||l_flex_name);
    else
      Tab0Print('Key flexfield: '||l_flex_name);
    end if;
  else
    l_ret_array(1) := l_flex_name;
    if (p_print_heading) then
      SectionPrint('Details of Key flexfield: '||l_flex_name
        ||' with id_flex_num '||to_char(p_flex_num));
    else
      Tab0Print('Key flexfield: '||l_flex_name||' with id_flex_num '
        || to_char(p_flex_num));
    end if;
  end if;

  l_counter := 0;
  for str in get_structs(p_flex_code, p_flex_num) loop
    l_counter := l_counter + 1;
    if p_flex_num is not null then
      l_ret_array(2) := str.enabled;
      l_ret_array(3) := str.frozen;
      l_ret_array(4) := str.dyn_insert;
      l_ret_array(5) := str.cross_val;
    end if;
    BRPrint;
    Tab1Print('Structure '||str.flex_str_name||' (ID='||
      to_char(str.flex_str_num) ||')');
    Tab1Print('Enabled Flag = '||str.enabled||', Frozen = '||str.frozen
      ||', Dynamic Inserts = '||str.dyn_insert||', Cross Validation Allowed = '
      ||str.cross_val||', Last Updated '||str.last_updated);


    l_counter2    := 0;
    l_num_segs    := 0;
    l_num_segs_vs := 0;
    for seg in get_segments(p_flex_code, str.flex_str_num) loop
      if l_counter2 = 0 then
        Tab1Print('Segment Details for '||str.flex_str_name);
        BRPrint;
      end if;
      l_counter2 := l_counter2 + 1;

      if (p_flex_num is not null) then
        if seg.enabled = 'Y' then
          l_num_segs := l_num_segs + 1;
          if (seg.value_set_id is not null) then
            l_num_segs_vs := l_num_segs_vs + 1;
          end if;
        end if;
      end if;
      if (seg.seg_security = 'Y' and seg.value_set_security in ('Y','H')) then
        l_any_sec_enabled := 'Y';
        l_sec_enabled := 'Y';
      end if;
      if (seg.value_set_id is not null) then
        l_value_set_str := ', Value Set = '||seg.value_set_name||
          ', Value Set Type = '||seg.validation_type;
      else
        l_value_set_str := ' with no value set assigned';
      end if;
      Tab2Print('Segment Name = '||seg.seg_name);
      Tab2Print('Enabled      = '||seg.enabled||', Displayed = '||
        seg.displayed||l_value_set_str);

      for qual in get_qualifiers(p_flex_code,str.flex_str_num,seg.col_name) loop
        Tab3Print('Qualifier '||qual.segment_prompt||' is assigned to '||
          'segment '|| seg.seg_name);
      end loop;

      if l_sec_enabled = 'Y' then
        select count(*) into l_rule_count
        from   fnd_flex_value_rules_vl
        where  flex_value_set_id = seg.value_set_id;

        select count(*) into l_rule_assign_count
        from   fnd_flex_value_rules_vl r,
               fnd_flex_value_rule_usages ru
        where  r.flex_value_rule_id = ru.flex_value_rule_id
        and    r.flex_value_set_id =  seg.value_set_id;

        Tab3Print('Security is enabled for this segment and value set with '||
          to_char(l_rule_count)||' rules defined and '||
          to_char(l_rule_assign_count)||' rule assignments');
      end if;
    end loop;
    if (p_flex_num is not null) then
      l_ret_array(6) := to_char(l_num_segs);
      l_ret_array(7) := to_char(l_num_segs_vs);
      l_ret_array(8) := l_any_sec_enabled;
    end if;
    if l_counter2 = 0 then
      ErrorPrint('There are no segments defined for this structure');
      ActionErrorPrint('Please enable or define at least one segment for '||
        str.flex_str_name);
    end if;
  end loop;
  if l_counter = 0 then
    if p_flex_num is null then
      ErrorPrint('There are no Key Flexfields enabled for ' || p_flex_code);
      ActionErrorPrint('Please enable or define a Key Flexfield for ' ||
        p_flex_code);
    else
      ErrorPrint('The requested flexfield structure (ID_FLEX_NUM='||
        to_char(p_flex_num)||') is inactive or does not exist');
      ActionErrorPrint('Verify that the flexfield structure is defined '||
        'and enabled for Key Flexfield '||p_flex_code);
    end if;
  end if;
  return l_ret_array;
exception
  when leave_api then
    return l_ret_array;
end CheckKeyFlexfield_html;
-- BVS-STOP  <- Stop ignoring this section (restart scanning)


procedure CheckKeyFlexfield_html(p_flex_code     in varchar2
                        ,   p_flex_num  in number default null
                        ,   p_print_heading in boolean default true)  is
dummy_v2t  V2T;
begin
  dummy_v2t := CheckKeyFlexfield(p_flex_code, p_flex_num, p_print_heading);
end CheckKeyFlexfield_html;

-- Function  Name: CheckProfile
-- Procedure Name: CheckProfile
--
-- Usage:
--      CheckProfile('Profile Name', UserID, ResponsibilityID,
--                   ApplicationID, 'Default Value', Indent Level);
--
-- Parameters:
--      Profile Name - System name of the profile option being checked
--      UserID - The identifier of that applications user for which the
--               profile option is to be checked.
--      ResponsibilityID - The identifier of the responsibility for which
--                         the profile option is to be checked
--      ApplicationID - The identifier of the application for which the profile
--                      option is to be checked
--      Default Value - The value that will be used as a default if the profile
--                      option is not set by the users (Default=NULL)
--      Indent Level - Number of tabs (0,1,2,3) that output should be indented
--                     (Default=0)
--
-- Returns:
--      If called as a function the return value will be either:
--         1 the value of the profile option if set
--         2 'DOESNOTEXIST' if the profile option does not exist
--         3 'DISABLED' if the profile option has been end dated
--         4 null if the profile option is not set
--
-- Output:
--      If the profile is set, displays its current setting.  If not set and
--      a default value exists, displays a warning indicating that the default
--      value will be used and indicating the value of the default.  If not set
--      and no default value is supplied, displays an error indicating that
--      the profile option should be set. Output will be indented according
--      to the Indent Level parameter supplied.
--
--      If the profile option does not exist or is disabled there is no
--      output.
--
-- Examples:
--      declare
--         profile_val fnd_profile_option_values.profile_option_value%type;
--      begin
--         profile_val := CheckProfile('PA_SELECTIVE_FLEX_SEG',g_user_id,
--            g_resp_id, g_appl_id, null, 1);
--
--         CheckProfile('PA_DEBUG_MODE',g_user_id, g_resp_id, g_appl_id);
--         CheckProfile('PA_DEBUG_MODE',g_user_id, g_resp_id, g_appl_id,'Y',2);
--      end;
--
-- BVS-START <- Starting ignoring this section

function CheckProfile_html(p_prof_name in varchar2
                    , p_user_id   in number
                    , p_resp_id   in number
                    , p_appl_id   in number
                    , p_default   in varchar2 default null
                    , p_indent    in integer default 0)
return varchar2 is
l_user_prof_name  fnd_profile_options_tl.user_profile_option_name%type;
l_prof_value      fnd_profile_option_values.profile_option_value%type;
l_start_date      date;
l_end_date        date;
l_opt_defined     boolean;
l_output_txt      varchar2(500);
begin
   begin
      select user_profile_option_name,
             nvl(start_date_active,sysdate-1),
             nvl(end_date_active,sysdate+1)
      into   l_user_prof_name, l_start_date, l_end_date
      from   fnd_profile_options_vl
      where  profile_option_name = p_prof_name;
   exception
      when no_data_found then
         l_prof_value := 'DOESNOTEXIST';
         return(l_prof_value);
      when others then
         ErrorPrint(sqlerrm||' occured while getting profile option '||
            'information');
         ActionErrorPrint('Report the above information to your support '||
            'representative');
         return(null);
   end;
   if ((sysdate < l_start_date) or (sysdate > l_end_date)) then
      l_prof_value := 'DISABLED';
      return(l_prof_value);
   end if;
   fnd_profile.get_specific(p_prof_name, p_user_id, p_resp_id, p_appl_id,
      l_prof_value, l_opt_defined);
   if not l_opt_defined then
      l_prof_value := null;
   end if;
   if l_prof_value is null then
      if p_default is null then
         ErrorPrint(l_user_prof_name || ' profile option is not set');
         ActionErrorPrint('Please set the profile option according to '||
            'the user manual');
         return(l_prof_value);
      else
         WarningPrint(l_user_prof_name || ' profile option is not set '||
            'and will default to ' || p_default);
         ActionWarningPrint('Please set the profile option according to '||
            'the user manual if you do not want to use the default');
         return(l_prof_value);
      end if;
   else
      l_output_txt := l_user_prof_name || ' profile option is set to -- ' ||
         l_prof_value;
      if p_indent = 1 then
         Tab1Print(l_output_txt);
      elsif p_indent = 2 then
         Tab2Print(l_output_txt);
      elsif p_indent = 3 then
         Tab3Print(l_output_txt);
      else
         Tab0Print(l_output_txt);
      end if;
      return(l_prof_value);
   end if;
exception when others then
   ErrorPrint(sqlerrm||' occured in CheckProfile');
   ActionErrorPrint('Please report this error to your support representative');
end CheckProfile_html;

procedure CheckProfile_html(p_prof_name in varchar2
                    , p_user_id   in number
                    , p_resp_id   in number
                    , p_appl_id   in number
                    , p_default   in varchar2 default null
                    , p_indent    in integer default 0) is
l_dummy_prof_value fnd_profile_option_values.profile_option_value%type;
begin
   l_dummy_prof_value := CheckProfile(p_prof_name, p_user_id, p_resp_id,
                            p_appl_id, p_default, p_indent);
end CheckProfile_html;
-- BVS-STOP  <- Stop ignoring this section (restart scanning)


-- Function Name: Column_Exists
--
-- Usage:
--    Column_Exists('Table Name','Column Name');
--
-- Paramteters:
--    Table Name - Table in which to check for the column
--    Column Name - Column to check
--
-- Returns:
--    'Y' if the column exists in the table, 'N' if not.
--
-- Example:
--   declare
--      sqltxt varchar2(1000);
--   begin
--      if Column_Exists('PA_IMPLEMENTATIONS_ALL','UTIL_SUM_FLAG') = 'Y' then ;
--         sqltxt := sqltxt||' and i.util_sum_flag is not null';
--      end if;
--   end;
--
function Column_Exists_html(p_tab in varchar, p_col in varchar, p_owner in varchar) return varchar2 is
l_counter integer:=0;
begin

  -- UNSURE!! SHOULD WE SEEK OWNER AS PARAMETER
  -- DECIDED TO DO SO

  select count(*) into l_counter
  from   all_tab_columns z
  where  z.table_name = upper(p_tab)
  and    z.column_name = upper(p_col)
  and 	 upper(z.owner) = upper(p_owner);

  if l_counter > 0 then
    return('Y');
  else
    return('N');
  end if;
exception when others then
  ErrorPrint(sqlerrm||' occured in Column_Exists');
  ActionErrorPrint('Report this information to your support analyst');
  raise;
end Column_Exists_html;

-- Procedure Name: Begin_Pre
--
-- Usage:
--      Begin_Pre;
--
-- Output:
--      Allows the following output to be preformatted
--
-- Examples:
--      begin
--         Begin_Pre;
--      end;
--
procedure Begin_Pre_html is
begin
   line_out('<pre>');
end Begin_Pre_html;

-- Procedure Name: End_Pre
--
-- Usage:
--      End_Pre;
--
-- Output:
--      Closes the Begin_Pre procedure
--
-- Examples:
--      begin
--         End_Pre;
--      end;
--
procedure End_Pre_html is
begin
   line_out('</pre>');
end End_Pre_html;

procedure Show_Table_html(p_type varchar2, p_values V2T, p_caption varchar2 default null, p_options V2T default null) is
   l_hold_option   varchar2(500);
   temp varchar2(500);
begin

   -- if table, then add viewInExcel attr to help Excel reporting
   if upper(p_type) in ('START','TABLE') then
      if p_caption is null then
         line_out('<table class="report" cellspacing="0" viewInExcel="true">');
      else
	 temp := replace(p_caption, '&', '&amp;');
      	 temp := replace(temp, '"', '&quot;');
	 temp := replace(replace(temp,'<','&lt;'),'>','&gt;');
         line_out('<br/><table class="report" cellspacing="0" summary="' || temp || '" viewInExcel="true">');
      end if;
   end if;
   if upper(p_type) in ('TABLE','ROW', 'HEADER') then
      line_out('<tr class="report">');
      for i in 1..p_values.COUNT loop
         if p_options is not null then
            l_hold_option := ' ' || p_options(i);
         end if;
         if p_values(i) = '&nbsp;'
         or p_values(i) is null then
            if upper(p_type) = 'HEADER' then
               line_out('<th class="report" id="' || i || '">&nbsp;</th>');
            else
               line_out('<td class="report" headers="' || i || '">&nbsp;</td>');
            end if;
         else
            if upper(p_type) = 'HEADER' then
               line_out('<th class="report" ' || l_hold_option || ' id="' || i || '">' || p_values(i) || '</th>');
            else
               line_out('<td class="report" ' || l_hold_option || ' headers="' || i || '">' || p_values(i) || '</td>');
            end if;
         end if;
      end loop;
      line_out('</tr>');
   end if;
   if upper(p_type) in ('TABLE','END') then
      line_out('</table>');
      --line_out('</TABLE>');
   end if;
end Show_Table_html;

procedure Show_Table_html(p_values V2T) is
begin
   Show_Table('TABLE',p_values);
end Show_Table_html;

procedure Show_Table_html(p_type varchar2) is
begin
   Show_Table(p_type,null);
end Show_Table_html;

procedure Show_Table_Row_html(p_values V2T, p_options V2T default null) is
begin
   Show_Table('ROW', p_values, null, p_options);
end Show_Table_Row_html;

procedure Show_Table_Header_html(p_values V2T, p_options V2T default null) is
begin
   Show_Table('HEADER', p_values, null, p_options);
end Show_Table_Header_html;

procedure Start_Table_html (p_caption varchar2 default null) is
begin
   Show_Table('START',null, p_caption);
end Start_Table_html;

procedure End_Table_html is
begin
   Show_Table('END',null);
end End_Table_html;

-- Function Name: Display_SQL
--
-- Usage:
--     a_number := Display_SQL('SQL statement','Name for Header','Long Flag',
--                 'Feedback', 'Max Rows');
--
-- Parameters:
--     SQL Statement - Any valid SQL Select Statement
--     Name for Header - Text String to for heading the output
--     Long Flag - Y or N  - If set to N then this will not output
--                 any LONG columns (default = Y)
--     Feedback - Y or N indicates whether to indicate the number of rows
--                selected automatically in the output (default = Y)
--     Max Rows - Limits the number of rows output to this number. NULL or
--                ZERO value indicates unlimited. (Default = NULL)
--
-- Returns:
--      The function returns the # of rows selected.
--      If there is an error then the function returns -1.
--
-- Output:
--      Displays the output of the SQL statement as an HTML table.
--
-- Examples:
--      declare
--         num_rows number;
--      begin
--         num_rows := Display_SQL('select * from ar_system_parameters_all',
--                                 'AR Parameters', 'Y', 'N',null);
--         num_rows := Display_SQL('select * from pa_implementations_all',
--                                 'PA Implementation Options');
--      end;
--

function Display_SQL_html (p_sql_statement  varchar2
                    , table_alias      varchar2
                    , hideHeader Boolean
                    , display_longs    varchar2 default 'Y'
                    , p_feedback       varchar2 default 'Y'
                    , p_max_rows       number   default null
                    , p_current_exec   number default 0) return number is

   error_position       number;
   error_position_end   number;
   row_counter          number;
   hold_exclude_cols    boolean;
   hold_sql_needed      varchar2(3);
   hold_string          varchar2(32767)  default null;
   hold_option          varchar2(32767)  default null;
   hold_sql             varchar2(32767)  default null;
   hold_sql_remain      varchar2(32767)  default null;
   hold_element         varchar2(32767)  default null;
   hold_long            long;
   hold_clob            clob;
   hold_length          varchar2(40);
   hold_bgcolor         varchar2(40);
   hold_color           varchar2(40);
   hold_open_paren      number;
   hold_curr_loc        number;
   hold_end_pos         number;
   column_counter       binary_integer  default 1;
   value_counter        binary_integer  default 1;

   column_high          binary_integer  default 1;
   value_high           binary_integer  default 1;
   v_cursor_id          number;
   v_dummy              integer;
   l_hold_length        varchar2(20);
   l_hold_date_format   varchar2(40);
   l_hold_type          varchar2(40);
   l_max_rows           integer;
   l_feedback_txt       varchar2(200);

   v_values     V2T;
   v_options    V2T;
   v_describe   dbms_sql.desc_tab;

   T_VARCHAR2   constant integer := 1;
   T_NUMBER     constant integer := 2;
   T_LONG       constant integer := 8;
   T_ROWID      constant integer := 11;
   T_DATE       constant integer := 12;
   T_RAW        constant integer := 23;
   T_CHAR       constant integer := 96;
   T_TYPE       constant integer := 109;
   T_CLOB       constant integer := 112;
   T_BLOB       constant integer := 113;
   T_BFILE      constant integer := 114;
   temp varchar2(500);

begin
--   line_out('<table>');
   if nvl(p_max_rows,0) = 0 then
     l_max_rows := null;
   else
     l_max_rows := p_max_rows;
   end if;

   if p_current_exec = 0 then
      select value into l_hold_date_format
      from   nls_session_parameters where parameter = 'NLS_DATE_FORMAT';
      execute immediate 'alter session set nls_date_format =
         ''MM-DD-YYYY HH24:MI''';
   end if;
   begin
      v_cursor_id := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE(v_cursor_id, p_sql_statement, DBMS_SQL.V7);
      DBMS_SQL.DESCRIBE_COLUMNS(v_cursor_id, column_high, v_describe);
      hold_sql := 'select ';
      hold_sql_needed := null;
      hold_exclude_cols := false;
      hold_sql_remain := ltrim(substr(replace(p_sql_statement,l_newline,' '), 7));
      for value_counter in 1..column_high loop
         if v_describe(value_counter).col_type = T_LONG then
            hold_length := 25000;
         else
            hold_length := to_number(v_describe(value_counter).col_max_len);
         end if;
         if v_describe(value_counter).col_type in (T_DATE, T_VARCHAR2,
         T_NUMBER, T_CHAR, T_ROWID) then
            DBMS_SQL.DEFINE_COLUMN(v_cursor_id, value_counter,
              hold_string, greatest(TO_NUMBER(hold_length),30));
         elsif v_describe(value_counter).col_type = T_CLOB then
            DBMS_SQL.DEFINE_COLUMN(v_cursor_id, value_counter, hold_clob);
         else
            null;
         end if;
         hold_string := v_describe(value_counter).col_name;
         if value_counter = 1 then
            v_values := V2T(replace(initcap(hold_string),'|','<br/>'));
         else
            v_values.EXTEND;
            v_values(value_counter) := replace(initcap(hold_string),'|','<br/>');
         end if;
         if substr(hold_sql_remain,1,1) <> '*' then
            hold_end_pos := 1;
            hold_open_paren := 0;
            loop
               if substr(hold_sql_remain,hold_end_pos,1) = '(' then
                  hold_open_paren := hold_open_paren + 1;
               elsif substr(hold_sql_remain,hold_end_pos,1) = ')' then
                  hold_open_paren := hold_open_paren - 1;
               elsif substr(hold_sql_remain,hold_end_pos,1) = ',' or
               lower(substr(hold_sql_remain, hold_end_pos, 4)) = ' from ' then
                  if hold_open_paren = 0 then
                     exit;
                  end if;
               end if;
               hold_end_pos := hold_end_pos + 1;
               if hold_end_pos > length(p_sql_statement) then
                  exit;
               end if;
            end loop;
            hold_element := substr(hold_sql_remain, 1, hold_end_pos);
            hold_sql_remain := ltrim(substr(hold_sql_remain, hold_end_pos + 1));
         else
            hold_element := v_describe(value_counter).col_name;
         end if;
         if v_describe(value_counter).col_type in
         (T_VARCHAR2, T_CHAR, T_NUMBER, T_DATE, T_LONG, T_CLOB, T_ROWID) then
            hold_sql := hold_sql || hold_sql_needed || hold_element;
         else
            hold_exclude_cols := true;
         end if;
         hold_sql_needed := ', ';
      end loop;
      if hold_exclude_cols then
         DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
         hold_sql := hold_sql || ' ' ||
            substr(p_sql_statement,instr(lower(p_sql_statement),' from '));
         row_counter := Display_SQL (hold_sql, table_alias, display_longs,
            p_feedback, p_max_rows, p_current_exec + 1) + 1;
      else
         if table_alias is not null then
            temp := replace(table_alias, '&', '&amp;');
            temp := replace(replace(temp,'<','&lt;'),'>','&gt;');
         end if;
         if hideHeader = FALSE then
	 --Always print the header if user doesnot want to hide headers
            line_out('<br/><span class="BigPrint">' || temp || '</span>');
         end if;

         v_dummy := DBMS_SQL.EXECUTE(v_cursor_id);

         row_counter := 1;
         loop
            if DBMS_SQL.FETCH_ROWS(v_cursor_id) = 0 then
		if row_counter > 1 then
			Show_Table('END');
                end if;
               exit;
            end if;
            if row_counter = 1 then
	       /*This will print the header if the user doesnot want to print
	         header if there is no rows.This line will be reached only if there is
		 atleast one row and it will pirnt header only if rows are selected
	        */
               if hideHeader = TRUE then
                  line_out('<br/><span class="BigPrint">' || temp || '</span>');
               end if;
               Start_Table(table_alias);
               Show_Table_Header(v_values);
            end if;
            for value_counter in 1..column_high loop
               if v_describe(value_counter).col_type in
               (T_DATE, T_VARCHAR2, T_NUMBER, T_CHAR, T_ROWID) then
                  DBMS_SQL.COLUMN_VALUE(v_cursor_id,value_counter,hold_string);
               else
                  DBMS_SQL.COLUMN_VALUE(v_cursor_id,value_counter,hold_clob);
                  hold_string := 'CLOB';
               end if;
	       hold_string := nvl(hold_string,' ');
               hold_option := null;
               if v_describe(value_counter).col_type = T_DATE then
                  --hold_string := replace(hold_string,' ','&nbsp;');
                  hold_option := 'nowrap="nowrap" align="right"';
               elsif v_describe(value_counter).col_type = T_VARCHAR2 then
		  hold_string := replace(hold_string, '&', '&amp;');
                  hold_string := replace(replace(hold_string,'<','&lt;'),
                     '>','&gt;');
                  if hold_string <> rtrim(hold_string) then
                     hold_option := 'nowrap="nowrap" bgcolor="yellow"';
                  else
                     hold_option := 'nowrap="nowrap"';
                  end if;
               elsif v_describe(value_counter).col_type = T_NUMBER then
                  hold_option := 'nowrap="nowrap" align="right"';
               else
                  null;
               end if;
               if value_counter = 1 then
                  v_values := V2T(hold_string);
                  v_options := V2T(hold_option);
               else
                  v_values.EXTEND;
                  v_values(value_counter) := hold_string;
                  v_options.EXTEND;
                  v_options(value_counter) := hold_option;
               end if;
            end loop;
            Show_Table_Row(v_values, v_options);
            row_counter := row_counter + 1;
            if row_counter >  nvl(l_max_rows,row_counter) then
	       Show_Table('END');
               exit;
            end if;
         end loop;
         DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
      end if;
      if p_current_exec = 0 and p_feedback = 'Y' then
         if row_counter = 1 then
           if hideHeader = FALSE then
		   l_feedback_txt := '<BR/><span class="SmallPrint">'||
		      '0 Rows Selected</span><br/>';
	   end if;
         elsif row_counter = 2 then
           l_feedback_txt := '<span class="SmallPrint">'||
              '1 Row Selected</span><br/>';
         else
           l_feedback_txt := '<span class="SmallPrint">'||
              ltrim(to_char(row_counter - 1,'9999999')) ||
              ' Rows Selected</span><br/>';
         end if;
         line_out(l_feedback_txt);
         execute immediate 'alter session set nls_date_format = ''' ||
            l_hold_date_format || '''';
      end if;
      if p_current_exec = 0 and row_counter = 1 then
         line_out('<BR/>');
      end if;
      return row_counter-1;
   exception
      when others then
         line_out('</table><br/>');
         error_position := DBMS_SQL.LAST_ERROR_POSITION;
         ErrorPrint(sqlerrm || ' occurred in Display_SQL');
         ActionErrorPrint('Please report the error below to your support '||
            'representative');
         line_out('Position: ' || error_position  || ' of ' ||
            length(p_sql_statement) || '<br/>');
         line_out(replace(substr(p_sql_statement,1,error_position),l_newline,
            '<br/>'));
         error_position_end := instr(p_sql_statement,' ',error_position+1) -
            error_position;
         line_out('<span class="error">' ||
            replace(substr(p_sql_statement,error_position+1,
            error_position_end),l_newline,'<br/>') || '</span>');
         line_out(replace(substr(p_sql_statement,error_position+
            error_position_end+1),l_newline,'<br/>') || '<br/>');
         DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
         if p_current_exec = 0 then
            execute immediate 'alter session set nls_date_format = ''' ||
               l_hold_date_format || '''';
         end if;
         return -1;
   end;
end Display_SQL_html;

-- Function Name: Run_SQL
--
-- Usage:
--      a_number := Run_SQL('Heading', 'SQL statement');
--      a_number := Run_SQL('Heading', 'SQL statement', 'Feedback');
--      a_number := Run_SQL('Heading', 'SQL statement', 'Max Rows');
--      a_number := Run_SQL('Heading', 'SQL statement', 'Feedback', 'Max Rows');
--
-- Parameters:
--      Heading - Text String to for heading the output
--      SQL Statement - Any valid SQL Select Statement
--      Feedback - Y or N to indicate whether to automatically print the
--                 number of rows returned (default 'Y')
--      Max Rows - Limit the output to this many rows.  NULL or ZERO values
--                 indicate unlimited rows (default NULL)
--
-- Returns:
--      The function returns the # of rows selected.
--      If there is an error then the function returns -1.
--
-- Output:
--      Displays the output of the SQL statement as an HTML table.
--
-- Examples:
--      declare
--         num_rows number;
--      begin
--         num_rows := Run_SQL('AR Parameters', 'select * from ar_system_parameters_all');
--      end;
--
function Run_SQL_html(p_title varchar2, p_sql_statement varchar2) return number is
begin
   return(Display_SQL(p_sql_statement , p_title ,'Y','Y',null));
end Run_SQL_html;

function Run_SQL_html(p_title varchar2
               , p_sql_statement varchar2
               , p_feedback varchar2) return number is
begin
   return(Display_SQL(p_sql_statement , p_title ,'Y',p_feedback,null));
end Run_SQL_html;

function Run_SQL_html(p_title varchar2
               , p_sql_statement varchar2
               , p_max_rows number) return number is
begin
   return(Display_SQL(p_sql_statement , p_title ,'Y','Y',p_max_rows));
end Run_SQL_html;

function Run_SQL_html(p_title varchar2
               , p_sql_statement varchar2
               , p_feedback varchar2
               , p_max_rows number) return number is
begin
   return(Display_SQL(p_sql_statement , p_title ,'Y',p_feedback,p_max_rows));
end Run_SQL_html;

-- Procedure Name: Run_SQL
--
-- Usage:
--      Run_SQL('Heading', 'SQL statement');
--      Run_SQL('Heading', 'SQL statement', 'Feedback');
--      Run_SQL('Heading', 'SQL statement', 'Max Rows');
--      Run_SQL('Heading', 'SQL statement', 'Feedback', 'Max Rows');
--
-- Parameters:
--      SQL Statement - Any valid SQL Select Statement
--     Heading - Text String to for heading the output
--
-- Output:
--      Displays the output of the SQL statement as an HTML table.
--
-- Examples:
--      begin
--         Run_SQL('AR Parameters', 'select * from ar_system_parameters_all');
--      end;
--
procedure Run_SQL_html(p_title varchar2, p_sql_statement varchar2) is
   dummy   number;
begin
   dummy := Display_SQL (p_sql_statement , p_title , 'Y','Y',null);
end Run_SQL_html;

procedure Run_SQL_html(p_title varchar2
                , p_sql_statement varchar2
                , p_feedback varchar2) is
   dummy   number;
begin
   dummy := Display_SQL (p_sql_statement , p_title , 'Y', p_feedback, null);
end Run_SQL_html;

procedure Run_SQL_html(p_title varchar2
                , p_sql_statement varchar2
                , p_max_rows number) is
   dummy   number;
begin
   dummy := Display_SQL (p_sql_statement , p_title , 'Y', 'Y', p_max_rows);
end Run_SQL_html;

procedure Run_SQL_html(p_title varchar2
                , p_sql_statement varchar2
                , p_feedback varchar2
                , p_max_rows number) is
   dummy   number;
begin
   dummy := Display_SQL (p_sql_statement , p_title , 'Y',
      p_feedback, p_max_rows);
end Run_SQL_html;

-- Procedure Name: Display_Table
--
-- Usage:
--      Display_Table('Table Name', 'Heading', 'Where Clause', 'Order By', 'Long Flag');
--
-- Parameters:
--      Table Name - Any Valid Table or View
--      Heading - Text String to for heading the output
--      Where Clause - Where clause to apply to the table dump
--      Order By - Order By clause to apply to the table dump
--      Long Flag - 'Y' or 'N'  - If set to 'N' then this will not output any LONG columns
--
-- Output:
--      Displays the output of the 'select * from table' as an HTML table.
--
-- Examples:
--      begin
--         Display_Table('AR_SYSTEM_PARAMETERS_ALL', 'AR Parameters', 'Where Org_id <> -3113'
--                         , 'order by org_id, set_of_books_id', 'N');
--      end;
--
-- BVS-START <- Starting ignoring this section

procedure Display_Table_html (p_table_name   varchar2,
          p_table_alias   varchar2,
          p_where_clause   varchar2,
          p_order_by_clause varchar2 default null,
          p_display_longs   varchar2 default 'Y') is
   dummy      number;
   hold_char   varchar(1) := null;
begin
   if p_where_clause is not null then
      hold_char := l_newline;
   end if;
   dummy := Display_SQL ('select * from ' ||
      replace(upper(p_table_name),'V_$','V$') || l_newline || p_where_clause ||
      hold_char || nvl(p_order_by_clause,'order by 1')
      , nvl(p_table_alias, p_table_name)
      , p_display_longs);
end Display_Table_html;

-- BVS-STOP  <- Stop ignoring this section (restart scanning)


-- Function Name: Display_Table
--
-- Usage:
--      a_number := Display_Table('Table Name', 'Heading', 'Where Clause', 'Order By', 'Long Flag');
--
-- Parameters:
--      Table Name - Any Valid Table or View
--      Heading - Text String to for heading the output
--      Where Clause - Where clause to apply to the table dump
--      Order By - Order By clause to apply to the table dump
--      Long Flag - 'Y' or 'N'  - If set to 'N' then this will not output any LONG columns
--
-- Output:
--      Displays the output of the 'select * from table' as an HTML table.
--
-- Returns:
--      Number of rows displayed.
--
-- Examples:
--      declare
--         num_rows   number;
--      begin
--         num_rows := Display_Table('AR_SYSTEM_PARAMETERS_ALL', 'AR Parameters', 'Where Org_id <> -3113'
--                                     , 'order by org_id, set_of_books_id', 'N');
--      end;
--
function Display_Table_html (p_table_name   varchar2,
          p_table_alias   varchar2,
          p_where_clause   varchar2,
          p_order_by_clause varchar2 default null,
          p_display_longs   varchar2 default 'Y') return number is
begin
   return(Display_SQL ('select * from ' ||
      replace(upper(p_table_name),'V_$','V$') || l_newline || p_where_clause ||
      l_newline || nvl(p_order_by_clause,'order by 1')
      , nvl(p_table_alias, p_table_name)
      , p_display_longs));
end Display_Table_html;

-- Function Name: Get_DB_Apps_Version
--
-- Usage:
--      a_varchar := Get_DB_Apps_Version;
--
-- Returns:
--      The version of applications from fnd_product_groups
--      Also sets the variable g_appl_version to '10.7','11.0', or '11.5'
--      as appropriate.
--
-- Examples:
--      declare
--         apps_ver   varchar2(20);
--      begin
--         apps_ver := Get_DB_Apps_Version;
--      end;
--
function Get_DB_Apps_Version_html return varchar2 is
   l_appsver   fnd_product_groups.release_name%type := null;
begin
   select release_name into l_appsver from fnd_product_groups;
        g_appl_version := substr(l_appsver,1,4);
   return(l_appsver);
end;

-- Procedure Name: Show_Header
--
-- Usage:
--      Show_Header('Note Number', 'Title');
--
-- Parameters:
--      Note Number - Any Valid Metalink Note Number
--      Title - Text string to go beside the note link
--
-- Output:
--      Displays Standard Header Information
--
-- Examples:
--      begin
--         Show_Header('139684.1', 'Oracle Applications Current Patchsets Comparison to applptch.txt');
--      end;
--
procedure Show_Header_html(p_note varchar2, p_title varchar2) is
   l_instance_name   varchar2(16) := null;
   l_host_name   varchar2(64) := null;
   l_version   varchar2(17) := null;
begin
   DBMS_LOB.CREATETEMPORARY(g_hold_output,TRUE,DBMS_LOB.SESSION);
   select instance_name
             , host_name
             , version
          into l_instance_name
             , l_host_name
             , l_version
          from v$instance;
   Insert_Style_Sheet;
   line_out('<table class="report" cellspacing="0" summary="Header Table to start off Script"><tr class="report">');
   line_out('<th class="rowh" align="left" id="note" nowrap="nowrap">Note</th>');
   line_out('<td class="report" align="left" headers="note" nowrap="nowrap">');
   line_out('<a href="http://metalink.oracle.com/metalink/plsql/ml2_documents.showDocument?p_database_id=NOT&amp;p_id=' || p_note || '" target="new">' );
   line_out(p_note||'</a>');
   line_out('<a href="http://metalink.oracle.com/metalink/plsql/ml2_documents.showDocument?p_database_id=NOT&amp;p_id=' || p_note || '" target="new"></a>' );
   line_out(p_title || '</td>');
   line_out('</tr><tr class="report">');
   line_out('<th class="rowh" align="left" id="machine" nowrap="nowrap">Machine</th>');
   line_out('<td class="report" align="left" headers="machine" nowrap="nowrap">' || l_host_name || '</td>');
   line_out('</tr><tr class="report">');
   line_out('<th class="rowh" align="left" id="date" nowrap="nowrap">Date Run</th>');
   line_out('<td class="report" align="left" headers="date" nowrap="nowrap">' || to_char(sysdate,'MM-DD-YYYY HH24:MI') || '</td>');
   line_out('</tr><tr class="report">');
   line_out('<th class="rowh" align="left" id="info" nowrap="nowrap">Oracle Info</th>');
   line_out('<td class="report" align="left" headers="info" nowrap="nowrap">SID: ' || l_instance_name || ' Version: ' || l_version || '</td>');
   line_out('</tr><tr class="report">');
   line_out('<th class="rowh" align="left" id="appver" nowrap="nowrap">Apps Version</th>');
   line_out('<td class="report" align="left" headers="appver" nowrap="nowrap">' || Get_DB_Apps_Version || '</td>');
   line_out('</tr></table><br/>' );
end Show_Header_html;

-- Procedure Name: Show_Footer
--
-- Usage:
--      Show_Footer('Script Name','Header');
--
-- Output:
--      Displays Standard Footer
--
-- Examples:
--      begin
--         Show_Footer('AR Setup Script', '$Header: jtfdiagcoreapi_b.pls 120.11.12000000.3 2007/04/05 09:33:32 rudas ship $';
--      end;
--
procedure Show_Footer_html(p_script_name varchar2, p_header varchar2) is
begin
   line_out('<br/><br/>Please provide ');
   line_out('<a href="mailto:support-diagnostics_ww@oracle.com?Subject=Diagnostic Framework feedback for ' || p_script_name || ' - ' || p_header || '">');
   line_out('feedback</a> regarding the usefulness of this test and/or');
   line_out('<br/>tool.We appreciate your feedback, however, there will be no replies to');
   line_out('<br/>feedback emails.  For support issues, please log an iTar (Service Request).');
end Show_Footer_html;

-- Procedure Name: Show_Link
--
-- Usage:
--      Show_Link('Note #');
--
-- Output:
--      Displays A link to a Metalink Note
--
-- Examples:
--      begin
--         Show_Link('139684.1');
--      end;
--
procedure Show_Link_html(p_note varchar2) is
begin
   line_out('Click to see Note: <a href="http://metalink.oracle.com/metalink/plsql/ml2_documents.showDocument?p_database_id=NOT&amp;p_id='  || p_note || '">' || p_note || '</a>');
end Show_Link_html;

-- Procedure Name: Show_Link
--
-- Usage:
--   Show_Link('URL', 'Name');
--
-- Output:
--      Displays A link to a URL using the Name Parameter
--
-- Examples:
--      begin
--         Show_Link('http://metalink.us.oracle.com', 'Metalink');
--      end;
--
procedure Show_Link_html(p_link varchar2, p_link_name varchar2 ) is
begin
   line_out('<a href="'  || p_link || '">' || p_link_name || '</a>');
end Show_Link_html;


-- Procedure Name: Send_Email
--
-- Usage:
--   Send_Email('Sender', 'Recipient', 'Subject', 'Message', 'SMTP Host');
--
-- Output:
--      Sends E-mail - No screen output.
--
-- Examples:
--      begin
--         Send_Email ('somebody@oracle.com','tosomebody@oracle.com','this is a subject', 'this is a body','gmsmtp01.oraclecorp.com');
--      end;
--
procedure Send_Email_html ( p_sender varchar2
                     , p_recipient varchar2
                     , p_subject varchar2
                     , p_message varchar2
                     , p_mailhost varchar2) is

   l_mail_conn   utl_smtp.connection;
begin
   l_mail_conn := utl_smtp.open_connection(p_mailhost, 25);
   utl_smtp.helo(l_mail_conn, p_mailhost);
   utl_smtp.mail(l_mail_conn, p_sender);
   utl_smtp.rcpt(l_mail_conn, p_recipient);
   utl_smtp.open_data(l_mail_conn);
   if p_subject is not null then
      utl_smtp.write_data(l_mail_conn, 'Subject: ' || p_subject || utl_tcp.CRLF);
   end if;
   utl_smtp.write_data(l_mail_conn, utl_tcp.CRLF || p_mailhost);
   utl_smtp.close_data(l_mail_conn);
   utl_smtp.quit(l_mail_conn);
exception
   when others then
      utl_smtp.quit(l_mail_conn);
      ErrorPrint('<br/>Error in Sending Mail' || sqlerrm);
end Send_Email_html;

-- Function Name: Get_Package_Version
--
-- Usage:
--   a_varchar := Get_Package_Version ('Object Type', 'Schema', 'Package Name');
--
-- Returns:
--      The version of the package or spec
--
-- Examples:
--   declare
--         spec_ver   varchar2(20);
--         body_ver   varchar2(20);
--      begin
--         spec_ver := Get_Package_Version('PACKAGE','APPS','ARH_ADDR_PKG');
--         body_ver := Get_Package_Version('PACKAGE BODY','APPS','ARH_ADDR_PKG');
--      end;
--
function Get_Package_Version_html (p_type varchar2, p_schema varchar2, p_package varchar2) return varchar2 is
   hold_version   varchar2(50);
begin
   select substr(z.text, instr(z.text,'$Header')+10, 40)
     into hold_version
     from all_source z
    where z.name = p_package
      and z.type = p_type
      and z.owner = p_schema
      and z.text like '%$Header%';
   hold_version := substr(hold_version, instr(hold_version,' ')+1, 50);
   hold_version := substr(hold_version, 1, instr(hold_version,' ')-1);
   return (hold_version);
end Get_Package_Version_html;

-- Function Name: Get_Package_Spec
--
-- Usage:
--      a_varchar := Get_Package_Spec('Package Name');
--
-- Returns:
--      The version of the package specification in the APPS schema
--
-- Examples:
--      declare
--         spec_ver   varchar2(20);
--      begin
--         spec_ver := Get_Package_Spec('ARH_ADDR_PKG');
--      end;
--
function Get_Package_Spec_html(p_package varchar2) return varchar2 is
begin
   return Get_Package_Version('PACKAGE','APPS',p_package);
end Get_Package_Spec_html;

-- Function Name: Get_Package_Body
--
-- Usage:
--      a_varchar := Get_Package_Body('Package Name');
--
-- Returns:
--      The version of the package body in the APPS schema
--
-- Examples:
--      declare
--         body_ver   varchar2(20);
--      begin
--         body_ver := Get_Package_Body('ARH_ADDR_PKG');
--      end;
--
function Get_Package_Body_html(p_package varchar2) return varchar2 is
begin
   return Get_Package_Version('PACKAGE BODY','APPS',p_package);
end Get_Package_Body_html;

-- BVS-START <- Starting ignoring this section
-- Procedure Name: Display_Profiles
--
-- Usage:
--      Display_Profiles(application id, 'profile short name');
--
-- Output:
--      Displays all Profile settings for the application or profile
--      in an HTML table
--
-- Examples:
--      begin
--         Display_Profiles(222,null);
--         Display_Profiles(null, 'AR_ALLOW_OVERAPPLICATION_IN_LOCKBOX');
--      end;
--
procedure Display_Profiles_html (p_application_id varchar2
                          , p_short_name     varchar2 default null) is
begin
   Run_SQL('Profile Options',
      'select b.USER_PROFILE_OPTION_NAME "Long<br/>Name"'
      || ' , a.profile_option_name "Short<br/>Name"'
      || ' , decode(to_char(c.level_id),''10001'',''Site'''
      || '                             ,''10002'',''Application'''
      || '                             ,''10003'',''Responsibility'''
      || '                             ,''10004'',''User'''
      || '                             ,''Unknown'') "Level"'
      || ' , decode(to_char(c.level_id),''10001'',''Site'''
      || '    ,''10002'',nvl(h.application_short_name,to_char(c.level_value))'
      || '    ,''10003'',nvl(g.responsibility_name,to_char(c.level_value))'
      || '    ,''10004'',nvl(e.user_name,to_char(c.level_value))'
      || '    ,''Unknown'') "Level<br/>Value"'
      || ' , c.PROFILE_OPTION_VALUE "Profile<br/>Value"'
      || ' , c.profile_option_id "Profile<br/>ID"'
      || ' , to_char(c.LAST_UPDATE_DATE,''MM-DD-YYYY HH24:MI'') '
      || '      "Updated<br/>Date"'
      || ' , nvl(d.user_name,to_char(c.last_updated_by)) "Updated<br/>By"'
      || ' from fnd_profile_options a'
      || '   , FND_PROFILE_OPTIONS_TL b'
      || '   , FND_PROFILE_OPTION_VALUES c'
      || '   , FND_USER d'
      || '   , FND_USER e'
      || '   , FND_RESPONSIBILITY_TL g'
      || '   , FND_APPLICATION h'
      || ' where a.application_id = nvl(' || nvl(p_application_id,'null')
      || '          , a.application_id)'
      || '   and a.profile_option_name = nvl(''' || p_short_name
      || '''        , a.profile_option_name)'
      || '   and a.profile_option_name = b.profile_option_name'
      || '   and a.profile_option_id = c.profile_option_id'
      || '   and a.application_id = c.application_id'
      || '   and c.last_updated_by = d.user_id (+)'
      || '   and c.level_value = e.user_id (+)'
      || '   and c.level_value = g.responsibility_id (+)'
      || '   and c.level_value = h.application_id (+)'
      || '   and b.language = ''US'''
      || ' order by 1, 4, 5');
end;
-- BVS-STOP  <- Stop ignoring this section (restart scanning)


-- Procedure Name: Get_Profile_Option
--
-- Usage:
--      a_varchar := Get_Profile_Option('Short Name');
--
-- Parameters:
--      Short Name - The Short Name of the Profile Option
--
-- Returns:
--      The value of the profile option based on the user.
--      If Set_Client has not been run successfully then
--      it will return the site level.
--
-- Output:
--      None
--
-- Examples:
--      declare
--         prof_value   varchar2(150);
--      begin
--         prof_value := Get_Profile_Option('AR_ALLOW_OVERAPPLICATION_IN_LOCKBOX')
--      end;
--
function Get_Profile_Option_html (p_profile_option varchar2) return varchar2 is
begin
   return FND_PROFILE.VALUE(p_profile_option);
end;

-- Procedure Name: Set_Org
--
-- Usage:
--      Set_Org(org_id);
--
-- Parameters:
--      Org_ID - The id of the organization to set.
--
-- Output:
--      None
--
-- Examples:
--      begin
--         Set_Org(204);
--      end;
--
procedure Set_Org_html (p_org_id number) is
begin
   fnd_client_info.set_org_context(p_org_id);
end Set_Org_html;

-- Procedure Name: Set_Client
--
-- Description:
--   Validates user_name, responsibility_id, and application_id  parameters
--   If valid it initializes the session (which results in the operating
--   unit being set for the session as well.  Also sets the global variables
--   g_user_id, g_resp_id, g_appl_id, and g_org_id which can then be used
--   throughout the script.
--
-- Usage:
--   Set_Client(UserName, Responsibility_ID);
--   Set_Client(UserName, Responsibility_ID, Application_ID);
--   Set_Client(UserName, Responsibility_ID, Application_ID, SecurityGrp_ID);
--
-- Parameters:
--   UserName - The Name of the Applications User
--   Responsibility_ID - Any Valid Responsibility ID
--   Application_ID - Any Valid Application ID (275=PA) If no value
--                    provided, attempt to obtain from responsibility_id
--   SecurityGrp_ID - A valid security_group_id
--
-- Examples:
--   begin
--      Set_Client('JOEUSER',50719, 222);
--   end;
-- BVS-START <- Starting ignoring this section
procedure Set_Client_html(p_user_name varchar2, p_resp_id number,
                     p_app_id number, p_sec_grp_id number) is
   l_cursor     integer;
   l_num_rows   integer;
   l_user_name  fnd_user.user_name%type;
   l_user_id    number;
   l_app_id     number;
   l_counter    integer;
   l_appl_vers  fnd_product_groups.release_name%type;
   sqltxt       varchar2(2000);
   inv_user exception;
   inv_resp exception;
   inv_app  exception;
   no_app   exception;
begin
  l_user_name := upper(p_user_name);
  begin
    select user_id into l_user_id
    from fnd_user where user_name = l_user_name;
  exception
    when others then
      raise inv_user;
  end;
  l_appl_vers := get_db_apps_version; -- sets g_appl_version
  if g_appl_version = '11.0' or g_appl_version = '10.7' then
    sqltxt := 'select rg.application_id '||
              'from   fnd_user_responsibility rg '||
              'where  rg.responsibility_id = '||to_char(p_resp_id)||' '||
              'and    rg.user_id = '||to_char(l_user_id);
  elsif g_appl_version = '11.5' then
    sqltxt := 'select rg.responsibility_application_id '||
              'from   fnd_user_resp_groups rg '||
              'where  rg.responsibility_id = '||to_char(p_resp_id)||' '||
              'and    rg.user_id = '||to_char(l_user_id);
  end if;
  begin
    l_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(l_cursor, sqltxt, dbms_sql.native);
    dbms_sql.define_column(l_cursor, 1, l_app_id);
    l_num_rows := dbms_sql.execute_and_fetch(l_cursor, TRUE);
    dbms_sql.column_value(l_cursor, 1, l_app_id);
    dbms_sql.close_cursor(l_cursor);

  exception
    when no_data_found then
      raise inv_resp;
    when too_many_rows then
      if p_app_id is null then
        raise no_app;
      else
        dbms_sql.close_cursor(l_cursor);
        l_cursor := dbms_sql.open_cursor;
        dbms_sql.parse(l_cursor, sqltxt, dbms_sql.native);
        dbms_sql.define_column(l_cursor, 1, l_app_id);
        l_num_rows := dbms_sql.execute(l_cursor);
        while dbms_sql.fetch_rows(l_cursor) > 0 loop
          dbms_sql.column_value(l_cursor, 1, l_app_id);
          if l_app_id = p_app_id then
            exit;
          end if;
        end loop;
        dbms_sql.close_cursor(l_cursor);
        if l_app_id <> p_app_id then
          raise inv_app;
        end if;
      end if;
  end;
  l_cursor := dbms_sql.open_cursor;
  if g_appl_version = '11.5' then
    sqltxt := 'begin '||
                'fnd_global.apps_initialize(:user, :resp, '||
                ':appl, :secg); '||
              'end; ';
    dbms_sql.parse(l_cursor, sqltxt, dbms_sql.native);
    dbms_sql.bind_variable(l_cursor,':user',l_user_id);
    dbms_sql.bind_variable(l_cursor,':resp',p_resp_id);
    dbms_sql.bind_variable(l_cursor,':appl',l_app_id);
    dbms_sql.bind_variable(l_cursor,':secg',p_sec_grp_id);
  else
    sqltxt := 'begin '||
                'fnd_global.apps_initialize(:user,:resp,:appl); '||
              'end; ';
    dbms_sql.parse(l_cursor, sqltxt, dbms_sql.native);
    dbms_sql.bind_variable(l_cursor,':user',l_user_id);
    dbms_sql.bind_variable(l_cursor,':resp',p_resp_id);
    dbms_sql.bind_variable(l_cursor,':appl',l_app_id);
  end if;
  l_num_rows := dbms_sql.execute(l_cursor);
  g_user_id := l_user_id;
  g_resp_id := p_resp_id;
  g_appl_id := l_app_id;
  g_org_id := Get_Profile_Option('ORG_ID');
exception
  when inv_user then
    ErrorPrint('Unable to initialize client due to invalid username: '||
      l_user_name);
    ActionErrorPrint('Set_Client has been passed an invalid username '||
      'parameter.  Please correct this parameter if possible, and if not, '||
      'inform your support representative.');
    raise;
  when inv_resp then
    ErrorPrint('Unable to initialize client due to invalid responsibility '||
      'ID: '||to_char(p_resp_id));
    ActionErrorPrint('Set_Client has been passed an invalid responsibility '||
      'ID parameter. This responsibility_id either does not exist or has not '||
      'been assigned to the user ('||l_user_name||'). Please correct these '||
      'parameter values if possible, and if not inform your support '||
      'representative.');
    raise;
  when inv_app then
    ErrorPrint('Unable to initialize client due to invalid application ID: '||
      to_char(p_app_id));
    ActionErrorPrint('Set_Client has been passed an invalid application ID '||
      'parameter. This application either does not exist or is not '||
      'associated with the responsibility id ('||to_char(p_resp_id)||'). '||
      'Please correct this parameter value if possible, and if not inform '||
      'your support representative.');
    raise;
  when no_app then
    ErrorPrint('Set_Client was unable to obtain an application ID to '||
      'initialize client settings');
    ActionErrorPrint('No application_id was supplied and Set_Client was '||
      'unable to determine this from the responsibility because multiple '||
      'responsibilities with the same responsibility_id have been assigned '||
      'to this user ('||l_user_name||').');
    raise;
  when others then
    ErrorPrint(sqlerrm||' occured in Set_Client');
    ActionErrorPrint('Please inform your support representative');
    raise;
end Set_Client_html;
-- BVS-STOP  <- Stop ignoring this section (restart scanning)

procedure Set_Client_html(p_user_name varchar2, p_resp_id number) is
begin
  Set_Client(p_user_name, p_resp_id, null, null);
end Set_Client_html;

procedure Set_Client_html(p_user_name varchar2, p_resp_id number,
                     p_app_id number ) is
begin
  Set_Client(p_user_name, p_resp_id, p_app_id, null);
end Set_Client_html;

/*
-- OBSOLETED API SINCE THIS IS NOT COMPLIANT WITH GSCC STANDARD
-- FILE.SQL.6 WHICH DOES NOT PERMIT USING OF SCHEMA
-- NAMES WITHIN PLSQL CODE
--
-- Procedure Name: Get_DB_Patch_List
--
-- Usage:
--      a_string := Get_DB_Patch_List('heading', 'short name', 'bug number', 'start date');
--
-- Parameters:
--      Heading = Title to go at the top of TABLE or TEXT outputs
--      Short Name = Limits to Bugs that match this expression for the Applications Production Short Name (LIKE)
--      Bug Number = Limits to bugs that match this expression (LIKE)
--      Start Date = Limits to Bugs created after this date
--
-- Output:
--      An HTML table of patches applied for the application since the date
--      indicated is displayed.
--
-- Examples:
--      begin
--         Get_DB_Patch_List(null, 'AD','%', '03-MAR-2002', 'SILENT');
--      end;
--

-- BVS-START <- Starting ignoring this section
procedure Get_DB_Patch_List_html (p_heading varchar2 default 'AD_BUGS'
           , p_app_short_name varchar2 default '%'
           , p_bug_number varchar2 default '%'
           , p_start_date date default to_date(olddate,'MM-DD-YYYY')
           , p_output_option varchar2 default 'TABLE')  is
   l_cursor      integer;
   l_sqltxt      varchar2(5000);
   l_list_out      varchar2(32767);
   l_hold_comma      varchar2(2);
   l_counter      integer;
   l_app_short_name   varchar2(50);
   l_bug_number      varchar2(30);
   l_creation_date      date;

begin

   select count(*) into l_counter
     from all_tables z
    where z.table_name = 'AD_BUGS'
    and upper(z.owner) = 'APPLSYS';

   if l_counter > 0 then
      l_sqltxt := 'select application_short_name'
         || '     , bug_number'
         || '     , creation_date'
         || ' from ad_bugs'
         || ' where upper(application_short_name) like '''
         ||     upper(p_app_short_name)
         || '''   and creation_date >= '''
         ||     nvl(to_char(p_start_date,'MM-DD-YYYY'),olddate)
         || '''   and bug_number like '''||p_bug_number||'''';
      Run_SQL(p_heading, l_sqltxt);
   else
      WarningPrint('Table AD_BUGS does not exist');
      ActionWarningPrint('Unable to retrieve a patch list from the database as this feature is not available on this version of the applications');
   end if;
end Get_DB_Patch_List_html;
-- BVS-STOP  <- Stop ignoring this section (restart scanning)
*/

-- Function Name: Get_RDBMS_Header
--
-- Usage:
--      Get_RDBMS_Header;
--
-- Returns:
--      Version of the Database from v$version
--
-- Examples:
--      declare
--         RDBMS_Ver := v$version.banner%type;
--      begin
--         RDBMS_Ver := Get_RDBMS_Header;
--      end;
--
Function Get_RDBMS_Header_html return varchar2 is
   l_hold_name   v$database.name%type;
   l_DB_Ver   v$version.banner%type;
begin
   begin
      select name
        into l_hold_name
        from v$database;
   exception
      when others then
         l_hold_name := 'Not Available';
   end;
   begin
      select banner
        into l_DB_Ver
        from v$version
       where banner like 'Oracle%';
   exception
      when others then
         l_DB_Ver := 'Not Available';
   end;
   return(l_hold_name || ' - ' || l_DB_Ver);
end Get_RDBMS_Header_html;

/*
-- OBSOLETED API SINCE THIS IS NOT COMPLIANT WITH GSCC STANDARD
-- FILE.SQL.6 WHICH DOES NOT PERMIT USING OF SCHEMA
-- NAMES WITHIN PLSQL CODE
--
-- Procedure Name: Show_Invalids
--
-- Usage:
--      Show_Invalids('start string', 'include errors', 'heading');
--
-- Parameters:
--      start string - An string indicating the beginning of object names to
--                     be included.  The underscore '_' character will be
--                     escaped in this string so that it does not act as a
--                     wild card character.  For example, 'PA_' will not match
--                     'PAY' even though it normally would in SQL*Plus.
--      include errors - Y or N to indicate whether to search on and report
--                       the errors from  ALL_ERRORS for each of the invalid
--                       objects found. (DEFAULT = N)
--      heading - An optional heading for the table.  If null the heading will
--                be "Invalid Objects (Starting with 'XXX')" where XXX is
--                the start string parameter.
--
-- Output:
--      A listing of invalid objects whose name starts with the 'start string'.
--      For packages, procedures, and functions, file versions will be included,
--      and when requested, error messages associated with the object will
--      be reported.
--
-- Examples:
--      Show_Invalids('PA_','Y');
--      Show_Invalids('GL_');
--
Procedure Show_Invalids_html (p_start_string   varchar2
                      ,  p_include_errors varchar2 default 'N'
                      ,  p_heading        varchar2 default null) is
l_start_string   varchar2(60);
l_errors         varchar2(32767);
l_file_version   varchar2(100);
l_heading        varchar2(500);
l_first_row      boolean := true;
l_table_row      V2T;
l_row_options    V2T;


-- OWNER CHANGE
cursor get_invalids(c_start_string varchar2) is
select o.object_name, o.object_type, o.owner
from   all_objects o
where  o.status = 'INVALID'
and    o.object_name like c_start_string escape '~'
and    upper(o.owner) in ('APPS', 'JTF', 'APPLSYS')
order by o.object_name;

cursor get_file_version(
            c_obj_name varchar2
          , c_obj_type varchar2
          , c_obj_owner varchar2) is
select substr(substr(s.text,instr(s.text,'$Header')+9),1,
          instr(substr(s.text,instr(s.text,'$Header')+9),' ',1,2)-1) file_vers
from   all_source s
where  s.name = c_obj_name
and    s.type = c_obj_type
and    s.owner = c_obj_owner
and    s.text like '%$Header%';

cursor get_errors (
            c_obj_name varchar2
          , c_obj_type varchar2
          , c_obj_owner varchar2) is
select to_char(sequence)||') LINE: '||to_char(line)||' CHR: '||
          to_char(position)||'  '||text error_row
from   all_errors z
where  z.name = c_obj_name
and    z.type = c_obj_type
and    z.owner = c_obj_owner;

begin
   l_start_string := upper(replace(p_start_string,'_','~_')) || '%';
   if p_heading is null then
      l_heading := 'Invalid Objects (Starting with '''||p_start_string||''')';
   else
      l_heading := p_heading;
   end if;
   line_out('<br/><span class="BigPrint">' || l_heading || '</span>');
   for inv_rec in get_invalids(l_start_string) loop
      if l_first_row then
         Start_Table('Invalid Objects');
         if p_include_errors = 'Y' then
            Show_Table_Header(V2T('Object Name','Object Type', 'Owner',
               'File Version', 'Errors'));
         else
            Show_Table_Header(V2T('Object Name', 'Object Type', 'Owner',
               'File Version'));
         end if;
         l_first_row := false;
      end if;

      if inv_rec.object_type like 'PACKAGE%' or
         inv_rec.object_type in ('PROCEDURE','FUNCTION') then
         open get_file_version(inv_rec.object_name, inv_rec.object_type,
            inv_rec.owner);
         fetch get_file_version into l_file_version;
         if get_file_version%notfound then
            l_file_version := null;
         end if;
         close get_file_version;
      else
         l_file_version := null;
      end if;

      if p_include_errors = 'Y' then
         for err_rec in get_errors(inv_rec.object_name, inv_rec.object_type,
             inv_rec.owner) loop
           l_errors := l_errors||err_rec.error_row||'<br/>';
         end loop;
         l_table_row := V2T(inv_rec.object_name, inv_rec.object_type,
            inv_rec.owner, l_file_version, l_errors);
         l_row_options := V2T(null,'nowrap',null,'nowrap','nowrap');
         Show_Table_Row(l_table_row,l_row_options);
      else
         l_table_row := V2T(inv_rec.object_name, inv_rec.object_type,
            inv_rec.owner, l_file_version);
         Show_Table_Row(l_table_row);
      end if;
   end loop;
   End_Table;
   if l_first_row then
      Insert_HTML('<br/><span class="SmallPrint">No Rows Selected</span><br/>');
   end if;
exception when others then
  ErrorPrint(sqlerrm||' occured in Show_Invalids');
  ActionErrorPrint('Use the feedback link to report the above error to '||
     'support');
end Show_Invalids_html;
*/

---------------------------------------------------------------
-- Text Output APIs
---------------------------------------------------------------


-- Procedure Name: Line_Out
-- Description:
--    Outputs plain text - same as Tab0Print
-- Usage:
--    Line_Out('String');
-- Parameters:
--   String - Any text string
-- Output:
--   Writes the text to the reportClob object
-- Examples:
--   begin
--      Line_Out('Run Gather Schema Statistics');
--   end;

procedure line_out_text(text varchar2) is
begin
   --dbms_lob.write(JTF_DIAGNOSTIC_ADAPTUTIL.reportClob, length(text)+1, g_curr_loc, text || l_newline);
   --JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(text || l_newline);
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(text||FND_GLOBAL.Local_Chr(10));
   g_curr_loc := g_curr_loc + length(text)+1;
end line_out_text;

-- Procedure Name: ActionPrint
-- Usage:
--    ActionPrint('String');
-- Parameters:
--   String - Any text string
-- Output:
--   Displays the text string with no indention preceded by 'ACTION - '
-- Examples:
--   begin
--      ActionPrint('Run Gather Schema Statistics');
--   end;

procedure ActionPrint_text(p_text varchar2) is
begin
  line_out('ACTION - '||p_text);
end ActionPrint_text;

-- Procedure Name: ActionErrorPrint
-- Usage:
--    ActionErrorPrint('String');
-- Parameters:
--   String - Any text string
-- Output:
--   Displays the text string with the word ACTION - prior to the string
--   Same as ActionPrint
-- Examples:
--   begin
--      ActionErrorPrint('Run Gather Schema Statistics');
--   end;

procedure ActionErrorPrint_text(p_text varchar2) is
begin
  ActionPrint(p_text);
end ActionErrorPrint_text;

-- Procedure Name: ActionWarningPrint
-- Usage:
--    ActionWarningPrint('String');
-- Parameters:
--   String - Any text string
-- Output:
--   Displays the text string in warning format
--   Same as ActionPrint
-- Examples:
--   begin
--      ActionWarningPrint('Run Gather Schema Statistics');
--   end;

procedure ActionWarningPrint_text(p_text varchar2) is
begin
  ActionPrint(p_text);
end ActionWarningPrint_text;

-- Procedure Name: WarningPrint
-- Usage:
--    WarningPrint('String');
-- Parameters:
--   String - Any text string
-- Output:
--   Displays the text string with no indentation preceded by 'WARNING - '
-- Examples:
--   begin
--      WarningPrint('Statistics are not up to date');
--   end;

procedure WarningPrint_text(p_text varchar2) is
begin
   line_out('WARNING - ' ||p_text);
end WarningPrint_text;

-- Procedure Name: ErrorPrint
-- Usage:
--    ErrorPrint('String');
-- Parameters:
--   String - Any text string
-- Output:
--   Displays the text string with no indentation preceded by 'ERROR - '
-- Examples:
--   begin
--      ErrorPrint('Statistics have not been run');
--   end;

procedure ErrorPrint_text(p_text varchar2) is
begin
  line_out('ERROR - '||p_text);
end ErrorPrint_text;

-- Procedure Name: SectionPrint
-- Usage:
--    SectionPrint('String');
-- Parameters:
--   String - Any text string
-- Output:
--   Displays the text underlined with two preceding carriage returns
-- Examples:
--   begin
--      SectionPrint('Checking OE Parameters');
--   end;

procedure SectionPrint_text (p_text varchar2) is
 ultxt varchar2(1000) := '-';
begin
  line_out(l_newline||l_newline||p_text);
  ultxt := rpad(ultxt, length(p_text),'-');
  line_out(ultxt);
end SectionPrint_text;

-- Procedure Name: BRPrint
-- Usage:
--    BRPrint;
-- Output:
--   Inserts a blank line.
-- Examples:
--   begin
--      BRPrint;
--   end;
procedure BRPrint_text is
begin
  line_out(l_tab);
end BRPrint_text;



-- Function Name: Column_Exists
-- Usage:
--    Column_Exists('Table Name','Column Name');
-- Paramteters:
--    Table Name - Table in which to check for the column
--    Column Name - Column to check
-- Returns:
--    'Y' if the column exists in the table, 'N' if not.
-- Examples:
--   declare
--      sqltxt varchar2(1000);
--   begin
--      if Column_Exists('PA_IMPLEMENTATIONS_ALL','UTIL_SUM_FLAG') = 'Y' then ;
--         sqltxt := sqltxt||' and i.util_sum_flag is not null';
--      end if;
--   end;

function Column_Exists_text(p_tab in varchar, p_col in varchar, p_owner in varchar) return varchar2 is
l_counter integer:=0;

begin
  -- UNSURE!! SHOULD WE SEEK OWNER AS PARAMETER
  -- DECIDED TO DO SO

  select count(*) into l_counter
  from   all_tab_columns z
  where  z.table_name = upper(p_tab)
  and    z.column_name = upper(p_col)
  and 	 upper(z.owner) = upper(p_owner);

  if l_counter > 0 then
    return('Y');
  else
    return('N');
  end if;
exception when others then
  ErrorPrint(sqlerrm||' occured in Column_Exists');
  ActionErrorPrint('Report this information to your support analyst');
  raise;
end Column_Exists_text;

-- Procedure Name: Tab0Print
-- Usage:
--    Tab0Print('String');
-- Parameters:
--   String - Any text string
-- Output:
--   Displays the text string unindented. (Same as Line_Out())
-- Examples:
--   begin
--      Tab0Print('Layer 0');
--   end;

procedure Tab0Print_text (p_text varchar2) is
begin
  line_out(p_text);
end Tab0Print_text;

-- Procedure Name: Tab1Print
-- Usage:
--    Tab1Print('String');
-- Parameters:
--   String - Any text string
-- Output:
--   Displays the text string indented by 1 tab character
-- Examples:
--   begin
--      Tab1Print('Layer 1');
--   end;

procedure Tab1Print_text (p_text varchar2) is
begin
  line_out(l_tab||p_text);
end Tab1Print_text;

-- Procedure Name: Tab2Print
-- Usage:
--    Tab2Print('String');
-- Parameters:
--   String - Any text string
-- Output:
--   Displays the text string indented two tab characters
-- Examples:
--   begin
--      Tab2Print('Layer 2');
--   end;

procedure Tab2Print_text (p_text varchar2) is
begin
  line_out(l_tab||l_tab||p_text);
end Tab2Print_text;

-- Procedure Name: Tab3Print
-- Usage:
--    Tab3Print('String');
-- Parameters:
--   String - Any text string
-- Output:
--   Displays the text string indented 3 tab characters
-- Examples:
--   begin
--      Tab3Print('Layer 3');
--   end;

procedure Tab3Print_text (p_text varchar2) is
begin
  line_out(l_tab||l_tab||l_tab||p_text);
end Tab3Print_text;

-- Procedure Name: CheckFinPeriod
-- Usage:
--    CheckFinPeriod('Set of Books ID','Application ID');
-- Paramteters:
--    Set of Books ID - ID for the set of books
--    Application ID - ID of the application whose periods are being checked
-- Output:
--    List the number of defined and open periods. Indicate the latest
--    open period. Produce warnings if no periods are open or if the
--    current date is not in an open period.
-- Examples:
--    CheckFinPeriod(62, 222);  -- Check open periods for AR SOB 62
--    CheckFinPeriod(202, 201); -- Check open periods for PO SOB 202
-- BVS-START <- Starting ignoring this section

procedure checkFinPeriod_text (p_sobid NUMBER, p_appid NUMBER ) IS
l_appname            VARCHAR2(50) :=NULL;
l_period_name        VARCHAR2(50);
l_user_period_type   VARCHAR2(50);
l_start_date         DATE;
l_end_date           DATE;
l_sysdate            DATE;
l_sysopen            VARCHAR2(1);

CURSOR C1 IS
  select   a.name sobname,
           count(b.period_name) total_periods,
           count(decode(b.closing_status,'O',b.PERIOD_NAME,null)) open_periods,
           a.accounted_period_type period_type
  from     gl_sets_of_books a,
           gl_period_statuses b
  where    a.set_of_books_id = b.set_of_books_id (+)
  and      b.application_id = p_appId
  and      a.set_of_books_id = p_sobId
  and      b.period_type = a.accounted_period_type
  group by a.name, a.accounted_period_type;

c1_rec  c1%rowtype;
no_rows exception;

BEGIN

select application_name
into   l_appname
from   fnd_application_vl
where  application_id = p_appid ;

open c1;
fetch c1 into c1_rec;
IF c1%notfound THEN
  raise no_rows;
END IF;
select user_period_type into l_user_period_type
from   gl_period_types
where  period_type = c1_rec.period_type;
Tab0Print('Application  = '||l_appname);
Tab0Print('Set of books = '|| c1_rec.sobname ||'(ID='||to_char(p_sobid)||')');
Tab0Print('Period type  = '||l_user_period_type);
Tab1Print('Periods Defined =   ' || to_char(c1_rec.total_periods));
Tab1Print('Periods Open    =   ' || to_char(c1_rec.open_periods));
IF c1_rec.total_periods = 0 THEN
  WarningPrint('There are no periods defined for this Set of books');
  ActionWarningPrint('There must be periods defined for this set of books');
END IF;
IF c1_rec.open_periods = 0 THEN
  WarningPrint('There are no open periods defined for this Set of books');
  ActionWArningprint('Please consider opening a period for this '||
    'application and set of books');
ELSE
  BEGIN
    SELECT  period_name, start_date, end_date, sysdate
    INTO    l_period_name, l_start_date, l_end_date, l_sysdate
    FROM gl_period_statuses
    WHERE adjustment_period_flag = 'N'
    AND   period_type = c1_rec.period_type
    AND   start_date = (
      SELECT MAX(start_date)
      FROM gl_period_statuses
      WHERE  closing_status = 'O'
      AND    adjustment_period_flag = 'N'
      AND    period_type = c1_rec.period_type
      AND    application_id = p_appId
      AND    set_of_books_id = p_sobId )
    AND closing_status  = 'O'
    AND application_id  =  p_appId
    AND set_of_books_id = p_sobId;

/* check if sysdate is in the latest open period  */

    l_sysopen := 'N';
    IF  l_sysdate >= l_start_date AND l_sysdate <= l_end_date THEN
       l_sysOpen := 'Y';
    END IF;
    Tab0Print('Latest open period is '|| l_period_name);
    Tab1Print('Start date = '|| to_char(l_start_date)||'  End date = '
      || to_char(l_end_date));
    IF l_sysopen = 'Y' THEN
      Tab0Print('Current date '|| to_char(l_sysdate)
        || ' is in the latest open period');
    ELSE
      BEGIN
        SELECT period_name, start_date, end_date, sysdate
        INTO   l_period_name, l_start_date, l_end_date, l_sysdate
        FROM   gl_period_statuses
        WHERE  adjustment_period_flag = 'N'
        AND    period_type = c1_rec.period_type
        AND    sysdate between start_date and end_date
        AND    closing_status = 'O'
        AND    application_id = p_appId
        AND    set_of_books_id = p_sobId;

        Tab0Print('Current date '|| to_char(sysDate)
          || ' is in the open period ' || l_period_name);
        Tab1Print('Start date = ' || to_char(l_start_date)||'  End date = '
          || to_char(l_end_date));

      EXCEPTION WHEN NO_DATA_FOUND THEN
        WarningPrint('Current date '|| to_char(l_sysdate)
          || ' is not in an open period');
        ActionwarningPrint('Please consider opening the current period');
      END;
    END IF;
  END;
END IF;
EXCEPTION
  WHEN NO_ROWS THEN
    WarningPrint('There are no accounting periods defined in '||
      'gl_period_statuses');
    ActionWArningprint('If required, define the accounting calendar for this '||
      'application and set of books');
  WHEN NO_DATA_FOUND THEN
    ErrorPrint('Invalid Application id passed to checkFinPeriod');
    ActionErrorPrint('Application id ' || to_char(p_appid)
      || ' is not valid on this system');
  WHEN OTHERS THEN
    ErrorPrint(sqlerrm||' occurred in CheckFinPeriod');
    ActionErrorPrint('Report this error to your support representative');
END checkFinPeriod_text;
-- BVS-STOP  <- Stop ignoring this section (restart scanning)


-- Function  Name: CheckKeyFlexfield
-- Procedure Name: CheckKeyFlexfield
--
-- Usage:
--      CheckKeyFlexfield('Key Flex Code','Flex Structure ID','Print Header');
--
-- Parameters:
--      Key Flex Code - The code of the Key Flexfield to be displayed.  For
--                      example, for the Accounting Flexfield use 'GL#'.
--      Flex Structure ID - The id_flex_num of the specific structure
--                          of the key flexfield whose details are to be
--                          displayed.  If null, print details of all
--                          structures. (default NULL)
--      Print Header - A boolean (true or false) indicating whether the output
--                     should print a heading before outputting the details
--                     of the key flexfield. (default TRUE)
-- Returns:
--      If value has been provided for the Flex Structure ID, the function
--      will returns an array of character strings with the following structure
--         1 name of the flexfield
--         2 enabled flag
--         3 frozen flag
--         4 dynamic instert flag
--         5 cross validation allowed flag
--         6 number of enabled segments defined
--         7 number of enabled segments with value sets
--         8 Y if any segment has security otherwise N
--      If no value is passed to the parameter the function will return an
--      array will null values.:w
--
-- Output:
--      Displays key information about the flexfield, its structure, and the
--      individual flexfield segments that make it up.
--
-- Examples:
--      declare
--         flexarray V2T;
--      begin
--         CheckKeyFlexfield('GL#', 50577, true);
--         CheckKeyFlexfield('MSTK',  null, false);
--         flexarray := CheckKeyFlexfield('GL#', 12345, false);
--      end;
--
-- BVS-START <- Starting ignoring this section

Function CheckKeyFlexfield_text(p_flex_code     in varchar2
                       ,   p_flex_num  in number default null
                       ,   p_print_heading in boolean default true)
return V2T is

l_ret_array         V2T := V2T(null,null,null,null,null,null,null,null);
l_no_value_sets     integer := 0;
l_any_sec_enabled   varchar2(1) := 'N';
l_sec_enabled       varchar2(1) := 'N';
l_flex_name         fnd_id_flexs.id_flex_name%type;
l_counter           integer := 0;
l_counter2          integer := 0;
l_num_segs          integer := 0;
l_num_segs_vs       integer := 0;
l_rule_count        integer := 0;
l_rule_assign_count integer := 0;
l_value_set_str     varchar2(400);
leave_api           exception;

cursor get_structs (p_f_code varchar2, p_f_num number) is
  select id_flex_num                   flex_str_num,
         id_flex_structure_name        flex_str_name,
         to_char(last_update_date,'MM-DD-YYYY HH24:MI:SS') last_updated,
         cross_segment_validation_flag cross_val,
         dynamic_inserts_allowed_flag  dyn_insert,
         enabled_flag                  enabled,
         freeze_flex_definition_flag   frozen
  from   fnd_id_flex_structures_vl
  where  id_flex_code = p_f_code
  and    enabled_flag ='Y'
  and    id_flex_num = nvl(p_f_num,id_flex_num);

cursor get_segments (p_f_code varchar2, p_f_num number) is
  select s.application_column_name          col_name,
         s.segment_name                     seg_name,
         s.segment_num                      seg_num,
         s.enabled_flag                     enabled,
         s.required_flag                    required,
         s.display_flag                     displayed,
         s.flex_value_set_id                value_set_id,
         vs.flex_value_set_name             value_set_name,
         DECODE(vs.validation_type,
              'I', 'Independent', 'N', 'None',  'D', 'Dependent',
              'U', 'Special',     'P', 'Pair',  'F', 'Table',
              'X', 'Translatable Independent',  'Y', 'Translatable Dependent',
              vs.validation_type)           validation_type,
         s.security_enabled_flag            seg_security,
         nvl(vs.security_enabled_flag,'N')  value_set_security
  from   fnd_id_flex_segments_vl s, fnd_flex_value_sets vs
  where  s.flex_value_set_id = vs.flex_value_set_id (+)
  and    s.id_flex_code = p_f_code
  and    s.id_flex_num =  p_f_num
  order by s.segment_num ;

cursor get_qualifiers(p_f_code varchar2, p_f_num number, p_col_name varchar2) is
  select segment_prompt
  from fnd_segment_attribute_values sav,
       fnd_segment_attribute_types  sat
  where sav.attribute_value = 'Y'
  and   sav.segment_attribute_type <> 'GL_GLOBAL'
  and   sav.application_id = sat.application_id
  and   sav.id_flex_code = sat.id_flex_code
  and   sav.segment_attribute_type = sat.segment_attribute_type
  and   sav.id_flex_code = p_f_code
  and   sav.id_flex_num =  p_f_num
  and   sav.application_column_name = p_col_name;

begin
  begin
    select id_flex_name into l_flex_name
    from   fnd_id_flexs
    where id_flex_code = p_flex_code;
  exception when no_data_found then
    WarningPrint('ID Flex Code passed '||p_flex_code||' is not valid on this '||
      'system');
    ActionWarningPrint('ID Flex Code '||p_flex_code||' will not be tested');
  end;

  BRPrint;
  if p_flex_num is null then
    if (p_print_heading) then
      SectionPrint('Details of Key flexfield: '||l_flex_name);
    else
      Tab0Print('Key flexfield: '||l_flex_name);
    end if;
  else
    l_ret_array(1) := l_flex_name;
    if (p_print_heading) then
      SectionPrint('Details of Key flexfield: '||l_flex_name
        ||' with id_flex_num '||to_char(p_flex_num));
    else
      Tab0Print('Key flexfield: '||l_flex_name||' with id_flex_num '
        || to_char(p_flex_num));
    end if;
  end if;

  l_counter := 0;
  for str in get_structs(p_flex_code, p_flex_num) loop
    l_counter := l_counter + 1;
    if p_flex_num is not null then
      l_ret_array(2) := str.enabled;
      l_ret_array(3) := str.frozen;
      l_ret_array(4) := str.dyn_insert;
      l_ret_array(5) := str.cross_val;
    end if;
    BRPrint;
    Tab0Print('Structure '||str.flex_str_name||' (ID='||
      to_char(str.flex_str_num) ||')');
    Tab1Print('Enabled Flag             = '||str.enabled);
    Tab1Print('Frozen                   = '||str.frozen);
    Tab1Print('Dynamic Inserts          = '||str.dyn_insert);
    Tab1Print('Cross Validation Allowed = '||str.cross_val);
    Tab1Print('Last Updated Date        = '||str.last_updated);


    l_counter2    := 0;
    l_num_segs    := 0;
    l_num_segs_vs := 0;
    for seg in get_segments(p_flex_code, str.flex_str_num) loop
      if l_counter2 = 0 then
        BRPrint;
        Tab0Print('Segment Details for '||str.flex_str_name);
      end if;
      l_counter2 := l_counter2 + 1;

      if (p_flex_num is not null) then
        if seg.enabled = 'Y' then
          l_num_segs := l_num_segs + 1;
          if (seg.value_set_id is not null) then
            l_num_segs_vs := l_num_segs_vs + 1;
          end if;
        end if;
      end if;
      if (seg.seg_security = 'Y' and seg.value_set_security in ('Y','H')) then
        l_any_sec_enabled := 'Y';
        l_sec_enabled := 'Y';
      end if;

      if (seg.value_set_id is not null) then
        l_value_set_str := ', Value Set = '||seg.value_set_name||
          ', Value Set Type = '||seg.validation_type;
      else
        l_value_set_str := ' with no value set assigned';
      end if;

      Tab1Print('Segment Name = '||seg.seg_name);
      Tab2Print('Enabled        = '||seg.enabled);
      Tab2Print('Displayed      = '||seg.displayed);
      if seg.value_set_id is not null then
        Tab2Print('Value Set      = '||seg.value_set_name);
        Tab2Print('Value Set Type = '||seg.validation_type);
      else
        Tab2Print('Value Set      = None assigned');
      end if;

      for qual in get_qualifiers(p_flex_code,str.flex_str_num,seg.col_name) loop
        Tab2Print('Qualifier '||qual.segment_prompt||' is assigned');
      end loop;

      if l_sec_enabled = 'Y' then
        select count(*) into l_rule_count
        from   fnd_flex_value_rules_vl
        where  flex_value_set_id = seg.value_set_id;

        select count(*) into l_rule_assign_count
        from   fnd_flex_value_rules_vl r,
               fnd_flex_value_rule_usages ru
        where  r.flex_value_rule_id = ru.flex_value_rule_id
        and    r.flex_value_set_id =  seg.value_set_id;

        Tab2Print('Security is enabled for this segment and value set');
        Tab3Print(to_char(l_rule_count)||' rules are defined');
        Tab3Print(to_char(l_rule_assign_count)||' rule assignments exist');
      end if;
    end loop;
    if (p_flex_num is not null) then
      l_ret_array(6) := to_char(l_num_segs);
      l_ret_array(7) := to_char(l_num_segs_vs);
      l_ret_array(8) := l_any_sec_enabled;
    end if;
    if l_counter2 = 0 then
      ErrorPrint('There are no segments defined for this structure');
      ActionErrorPrint('Please enable or define at least one segment for '||
        str.flex_str_name);
    end if;
  end loop;
  if l_counter = 0 then
    if p_flex_num is null then
      ErrorPrint('There are no Key Flexfields enabled for ' || p_flex_code);
      ActionErrorPrint('Please enable or define a Key Flexfield for ' ||
        p_flex_code);
    else
      ErrorPrint('The requested flexfield structure (ID_FLEX_NUM='||
        to_char(p_flex_num)||') is inactive or does not exist');
      ActionErrorPrint('Verify that the flexfield structure is defined '||
        'and enabled for Key Flexfield '||p_flex_code);
    end if;
  end if;
  return l_ret_array;
exception
  when leave_api then
    return l_ret_array;
end;

procedure CheckKeyFlexfield_text(p_flex_code     in varchar2
                        ,   p_flex_num  in number default null
                        ,   p_print_heading in boolean default true)  is
dummy_v2t  V2T;
begin
  dummy_v2t := CheckKeyFlexfield(p_flex_code, p_flex_num, p_print_heading);
end CheckKeyFlexfield_text;

-- Function  Name: CheckProfile
-- Procedure Name: CheckProfile
-- Usage:
--      CheckProfile('Profile Name', UserID, ResponsibilityID,
--                   ApplicationID, 'Default Value', Indent Level);
-- Parameters:
--      Profile Name - System name of the profile option being checked
--      UserID - The identifier of that applications user for which the
--               profile option is to be checked.
--      ResponsibilityID - The identifier of the responsibility for which
--                         the profile option is to be checked
--      ApplicationID - The identifier of the application for which the profile
--                      option is to be checked
--      Default Value - The value that will be used as a default if the profile
--                      option is not set by the users (Default=NULL)
--      Indent Level - Number of tabs (0,1,2,3) that output should be indented
--                     (Default=0)
-- Returns:
--      If called as a function the return value will be either:
--         1 the value of the profile option if set
--         2 'DOESNOTEXIST' if the profile option does not exist
--         3 'DISABLED' if the profile option has been end dated
--         4 null if the profile option is not set
-- Output:
--      If the profile is set, displays its current setting.  If not set and
--      a default value exists, displays a warning indicating that the default
--      value will be used and indicating the value of the default.  If not set
--      and no default value is supplied, displays an error indicating that
--      the profile option should be set. Output will be indented according
--      to the Indent Level parameter supplied.
--
--      If the profile option does not exist or is disabled there is no
--      output.
-- Examples:
--      declare
--         profile_val fnd_profile_option_values.profile_option_value%type;
--      begin
--         profile_val := CheckProfile('PA_SELECTIVE_FLEX_SEG',g_user_id,
--            g_resp_id, g_appl_id, null, 1);
--
--         CheckProfile('PA_DEBUG_MODE',g_user_id, g_resp_id, g_appl_id);
--         CheckProfile('PA_DEBUG_MODE',g_user_id, g_resp_id, g_appl_id,'Y',2);
--      end;

function CheckProfile_text(p_prof_name in varchar2
                    , p_user_id   in number
                    , p_resp_id   in number
                    , p_appl_id   in number
                    , p_default   in varchar2 default null
                    , p_indent    in integer default 0)
return varchar2 is
l_user_prof_name  fnd_profile_options_tl.user_profile_option_name%type;
l_prof_value      fnd_profile_option_values.profile_option_value%type;
l_start_date      date;
l_end_date        date;
l_opt_defined     boolean;
l_output_txt      varchar2(500);
begin
   begin
      select user_profile_option_name,
             nvl(start_date_active,sysdate-1),
             nvl(end_date_active,sysdate+1)
      into   l_user_prof_name, l_start_date, l_end_date
      from   fnd_profile_options_vl
      where  profile_option_name = p_prof_name;
   exception
      when no_data_found then
         l_prof_value := 'DOESNOTEXIST';
         return(l_prof_value);
      when others then
         ErrorPrint(sqlerrm||' occured while getting profile option '||
            'information');
         ActionErrorPrint('Report the above information to your support '||
            'representative');
         return(null);
   end;
   if ((sysdate < l_start_date) or (sysdate > l_end_date)) then
      l_prof_value := 'DISABLED';
      return(l_prof_value);
   end if;
   fnd_profile.get_specific(p_prof_name, p_user_id, p_resp_id, p_appl_id,
      l_prof_value, l_opt_defined);
   if not l_opt_defined then
      l_prof_value := null;
   end if;
   if l_prof_value is null then
      if p_default is null then
         ErrorPrint(l_user_prof_name || ' profile option is not set');
         ActionErrorPrint('Please set the profile option according to '||
            'the user manual');
         return(l_prof_value);
      else
         WarningPrint(l_user_prof_name || ' profile option is not set '||
            'and will default to ' || p_default);
         ActionWarningPrint('Please set the profile option according to '||
            'the user manual if you do not want to use the default');
         return(l_prof_value);
      end if;
   else
      l_output_txt := l_user_prof_name || ' profile option is set to -- ' ||
         l_prof_value;
      if p_indent = 1 then
         Tab1Print(l_output_txt);
      elsif p_indent = 2 then
         Tab2Print(l_output_txt);
      elsif p_indent = 3 then
         Tab3Print(l_output_txt);
      else
         Tab0Print(l_output_txt);
      end if;
      return(l_prof_value);
   end if;
exception when others then
   ErrorPrint(sqlerrm||' occured in CheckProfile');
   ActionErrorPrint('Please report this error to your support representative');
end CheckProfile_text;

procedure CheckProfile_text(p_prof_name in varchar2
                    , p_user_id   in number
                    , p_resp_id   in number
                    , p_appl_id   in number
                    , p_default   in varchar2 default null
                    , p_indent    in integer default 0) is
l_dummy_prof_value fnd_profile_option_values.profile_option_value%type;
begin
   l_dummy_prof_value := CheckProfile(p_prof_name, p_user_id, p_resp_id,
                            p_appl_id, p_default, p_indent);
end CheckProfile_text;

-- Procedure Name: Show_Table_Header
-- Description:
--   Private procedure used by Display_SQL to display the headers
-- Usage:  N/A
-- Examples: N/A

procedure Show_Table_Header_text(p_headers in headers,
                            p_lengths in out NOCOPY lengths) is
  hdr_str varchar2(5000);
  ul_str  varchar2(5000);
begin
  p_lengths := p_lengths;
  for i in 1..p_headers.count loop
    if p_lengths(i) is null or p_lengths(i) < length(p_headers(i)) then
      p_lengths(i) := length(p_headers(i));
    end if;
    if i = 1 then
      hdr_str := l_return||rpad(p_headers(i),p_lengths(i),' ');
      ul_str := rpad('-',p_lengths(i),'-');
    else
      hdr_str := hdr_str||' '||rpad(p_headers(i),p_lengths(i),' ');
      ul_str  := ul_str||' '||rpad('-',p_lengths(i),'-');
    end if;
  end loop;
  line_out(hdr_str);
  line_out(ul_str);
end Show_Table_Header_text;

-- Function  Name: Display_SQL
-- Procedure Name: Display_SQL
-- Usage:
--    Function:
--       a_number := Display_SQL('SQL statement', 'disp_lengths_tbl',
--          'headers_tbl', 'feedback', 'max rows');
--    Procedure:
--       Display_SQL('SQL statement', 'disp_lengths_tbl',
--          'headers_tbl', 'feedback', 'max rows');
-- Parameters:
--   SQL Statement - Any valid SQL select statement text which selects only
--                   columns of type Number, Date, or Varchar2.
--   disp_lengths_tbl - a table of type 'lengths' indicating the display
--                      length for each of the columns in the select.
--                      A value must be supplied for each column.  If the
--                      value is null, the length of the header will be used.
--   headers_tbl - a table of type 'headers' indicating the column heading
--                 for each of the columns in the select.  If an individual
--                 element of this parameter is null, or if this parameter
--                 is not provided (it is not required) the heading will be
--                 1) the column alias
--                 2) the column name
--   feedback - Y or N to indicate whether a count of rows should automaticall
--              be printed at the end of the output.  (Default = Y)
--   max rows - Maximum number of rows to output.  NULL or ZERO indicates
--              unlimited.  (Default = NULL)
-- Returns:
--    The function returns the number of rows selected.
--    If there is an error then the function returns null.
-- Output:
--   Displays the output of the SQL statement as text.
-- Examples:
--   declare
--      num_rows     number;
--      sqltxt       varchar2(2000);
--      disp_lengths lengths;
--      col_headers  headers;
--   begin
--     sqltxt := 'Select segment1, project_type, project_id '||
--               'from pa_projects_all'
--     disp_lengths := lengths(20,15,8);
--     col_headers  := headers('Project Number', 'Project Type', null);
--
--     num_rows := Display_SQL(sqltxt, disp_lengths);
--     /* or */
--     num_rows := Display_SQL(sqltxt, disp_lengths, col_headers);
--     /* or */
--     num_rows := Display_SQL(sqltxt, disp_lengths, col_headers,'N');
--     tab0Print(to_char(num_rows)||' rows selected');
--     /* or */
--     num_rows := Display_SQL(sqltxt, disp_lengths, col_headers,'N',5);
--     tab0Print(to_char(num_rows)||' rows selected');
--     /* or */
--     num_rows := Display_SQL(sqltxt, disp_lengths,null,'Y',5);
--     /* or */
--     Display_SQL(sqltxt, disp_lengths);
--     /* or */
--     Display_SQL(sqltxt, disp_lengths, col_headers);
--     /* or */
--     Display_SQL(sqltxt, disp_lengths, col_headers,'N');
--     /* or */
--     Display_SQL(sqltxt, disp_lengths, col_headers,'N',5);
--   end;

function Display_SQL_text (
           p_sql_statement varchar2
         , p_disp_lengths  lengths
         , p_headers       headers default null
         , p_feedback      varchar2 default 'Y'
         , p_max_rows      number default null)
return number is
   error_position      number;
   error_position_end  number;
   i                   binary_integer   :=  1;
   l_row_counter       number;
   l_row_str           varchar2(32767)  :=  null;
   l_column_high         binary_integer   :=  1;
   l_cursor            number;
   l_cols              dbms_sql.desc_tab;
   l_number_value      number;
   l_date_value        date;
   l_varchar_value     varchar2(32767);
   l_dummy             integer;
   l_headers           headers;
   l_disp_lengths      lengths;
   l_max_rows          number;

   T_VARCHAR2 constant integer := 1;
   T_NUMBER   constant integer := 2;
   T_LONG     constant integer := 8;
   T_DATE     constant integer := 12;
   T_RAW      constant integer := 23;
   T_CHAR     constant integer := 96;
   T_TYPE     constant integer := 109;
   T_CLOB     constant integer := 112;
   T_BLOB     constant integer := 113;
   T_BFILE    constant integer := 114;

   param_error exception;

begin
  if p_max_rows = 0 then
     l_max_rows := null;
  else
     l_max_rows := p_max_rows;
  end if;
  l_headers := p_headers;
  l_disp_lengths := p_disp_lengths;
  l_cursor := DBMS_SQL.OPEN_CURSOR;
  begin
    DBMS_SQL.PARSE(l_cursor, p_sql_statement, DBMS_SQL.V7);
  exception when others then
    ErrorPrint('Unable to parse the statement passed to Display_SQL: '||
      sqlerrm);
    ActionErrorPrint('Review the SQL statement below for errors and provide '||
      'the information to your support representative:'||l_newline||
      p_sql_statement);
    raise param_error;
  end;

  DBMS_SQL.DESCRIBE_COLUMNS(l_cursor, l_column_high, l_cols);
  if l_column_high <> l_disp_lengths.count then
    ErrorPrint('The column length is not specified for the correct number '||
      'of columns in call to Display_SQL');
    ActionErrorPrint('You must spefify the display length for each and every '||
      'column of the SQL select statement');
    raise param_error;
  end if;
  if l_headers is null then
    l_headers := headers();
  end if;
  if l_headers.count <> 0 and l_headers.count <> l_disp_lengths.count then
    ErrorPrint('Incorrect number of headers passed to Display_SQL');
    ActionErrorPrint('Either no headers must be passed, or a header value '||
      '(which can be null) must be passed for every column of the select');
    raise param_error;
  end if;
  for i in 1..l_column_high loop
    if l_cols(i).col_type not in (T_VARCHAR2,T_NUMBER,T_DATE) then
      ErrorPrint('Invalid column datatype');
      ActionErrorPrint('The Display_SQL api does not support queries on '||
        'columns of type '||l_cols(i).col_type);
      raise param_error;
    end if;
    if l_cols(i).col_type = T_NUMBER then
      DBMS_SQL.DEFINE_COLUMN(l_cursor, i, l_number_value);
    elsif l_cols(i).col_type = T_DATE then
      DBMS_SQL.DEFINE_COLUMN(l_cursor, i, l_date_value);
      l_disp_lengths(i) := greatest(l_disp_lengths(i),11);
    elsif l_cols(i).col_type = T_VARCHAR2 then
      DBMS_SQL.DEFINE_COLUMN(l_cursor, i, l_varchar_value,
                             l_cols(i).col_max_len);
    else
      null;
    end if;
    if l_headers.count < i then -- no header supplied
      while l_headers.count < i loop
        l_headers.extend;
      end loop;
      l_headers(i) := l_cols(i).col_name;
    elsif l_headers(i) is null then -- header supplied is null
      l_headers(i) :=  l_cols(i).col_name;
    end if;
    if l_cols(i).col_type = T_NUMBER then
      l_disp_lengths(i) := nvl(l_disp_lengths(i),length(l_headers(i)));
      l_headers(i) := lpad(l_headers(i),l_disp_lengths(i),' ');
    end if;
  end loop;
  l_dummy := dbms_sql.execute(l_cursor);
  l_row_counter := 0;
  while dbms_sql.fetch_rows(l_cursor) <> 0 loop
    if l_row_counter = 0 then
      Show_Table_Header(l_headers, l_disp_lengths);
    end if;
    l_row_counter := l_row_counter + 1;
    if l_row_counter > nvl(l_max_rows,l_row_counter) then
      l_row_counter := l_row_counter - 1;
      exit;
    end if;
    for i in 1..l_column_high loop
      if l_cols(i).col_type = T_NUMBER then
        dbms_sql.column_value(l_cursor, i, l_number_value);
        if length(to_char(l_number_value)) > l_disp_lengths(i) then
          l_varchar_value := rpad('*',l_disp_lengths(i),'*');
        else
          if i = 1 then
            if l_number_value is null then
              l_varchar_value := rpad(l_return,l_disp_lengths(i)+1,' ');
            else
              l_varchar_value := l_return||lpad(to_char(l_number_value),
                                 l_disp_lengths(i),' ');
            end if;
          else
            l_varchar_value := lpad(nvl(to_char(l_number_value),' '),
                               l_disp_lengths(i),' ');
          end if;
        end if;
      elsif l_cols(i).col_type = T_DATE then
        dbms_sql.column_value(l_cursor, i, l_date_value);
        if i = 1 and l_date_value is null then
          l_varchar_value := rpad(l_return,l_disp_lengths(i)+1, ' ');
        else
          l_varchar_value:=rpad(nvl(to_char(l_date_value,'MM-DD-YYYY'),' '),
                           l_disp_lengths(i), ' ');
        end if;
      elsif l_cols(i).col_type = T_VARCHAR2 then
        dbms_sql.column_value(l_cursor, i, l_varchar_value);
        if i = 1 and l_varchar_value is null then
          l_varchar_value := rpad(l_return,l_disp_lengths(i)+1,' ');
        else
          l_varchar_value := rpad(substr(nvl(l_varchar_value,' '),1,
                             l_disp_lengths(i)),l_disp_lengths(i), ' ');
        end if;
      end if;
      if i = 1 then
        l_row_str := l_varchar_value;
      else
        l_row_str := l_row_str||' '||l_varchar_value;
      end if;
    end loop;
    l_row_str := rtrim(l_row_str);
    line_out(l_row_str);
  end loop;
  if p_feedback = 'Y' then
    BRPrint;
    line_out(to_char(l_row_counter)||' rows selected');
    BRPrint;
  end if;
  return(l_row_counter);
exception
  when param_error then
    return(null);
  when others then
    ErrorPrint(sqlerrm||' occured in Display_SQL');
    ActionErrorPrint('Report this information to your support representative.');
    return(sqlcode);
end Display_SQL_text;


procedure Display_SQL_text (
           p_sql_statement varchar2
         , p_disp_lengths  lengths) is
l_dummy number;
begin
  l_dummy := Display_SQL(p_sql_statement, p_disp_lengths);
end Display_SQL_text;

procedure Display_SQL_text (
           p_sql_statement varchar2
         , p_disp_lengths  lengths
         , p_headers       headers) is
l_dummy number;
begin
  l_dummy := Display_SQL(p_sql_statement, p_disp_lengths, p_headers);
end Display_SQL_text;

procedure Display_SQL_text (
           p_sql_statement varchar2
         , p_disp_lengths  lengths
         , p_headers       headers
         , p_feedback      varchar2) is
l_dummy number;
begin
  l_dummy := Display_SQL(p_sql_statement, p_disp_lengths, p_headers,
     p_feedback);
end Display_SQL_text;

procedure Display_SQL_text (
           p_sql_statement varchar2
         , p_disp_lengths  lengths
         , p_headers       headers
         , p_feedback      varchar2
         , p_max_rows      number) is
l_dummy number;
begin
  l_dummy := Display_SQL(p_sql_statement, p_disp_lengths, p_headers,
     p_feedback, p_max_rows);
end Display_SQL_text;

-- Function Name: Run_SQL
-- Procedure Name: Run_SQL
-- Usage:
--    Function:
--       a_number := Run_SQL('Header', 'SQL statement','disp_lengths_tbl',
--          'col_headers_tbl');
--       a_number := Run_SQL('Header', 'SQL statement','disp_lengths_tbl',
--          'col_headers_tbl','feedback');
--       a_number := Run_SQL('Header', 'SQL statement','disp_lengths_tbl',
--          'col_headers_tbl','max rows');
--       a_number := Run_SQL('Header', 'SQL statement','disp_lengths_tbl',
--          'col_headers_tbl','feedback', 'max rows');
--    Procedure:
--       Run_SQL('Header', 'SQL statement', 'disp_lengths_tbl',
--          'col_headers_tbl');
--       Run_SQL('Header', 'SQL statement', 'disp_lengths_tbl',
--          'col_headers_tbl','feedback');
--       Run_SQL('Header', 'SQL statement', 'disp_lengths_tbl',
--          'col_headers_tbl','max rows');
--       Run_SQL('Header', 'SQL statement', 'disp_lengths_tbl',
--          'col_headers_tbl','feedback','max rows');
-- Parameters:
--   Header - Text String to for heading the output
--   SQL Statement - Any valid SQL Select Statement
--   disp_lengths_tbl - a table of type 'lengths' indicating the display
--                      length for each of the columns in the select.
--                      A value must be supplied for each column even if
--                      that value is null.  If the value is null,
--                      the length of the header will be used.
--   headers_tbl - a table of type 'headers' indicating the column heading
--                 for each of the columns in the select.  If an individual
--                 element of this parameter is null, or if this parameter
--                 is not provided (it is not required) the heading will be
--                 1) the column alias
--                 2) the column name
--   feedback - Y or N to indicate whether a count of rows should automaticall
--              be printed at the end of the output.  (Default = Y)
--   max rows - Maximum number of rows to output.  NULL or ZERO indicates
--              unlimited.  (Default = NULL)
-- Returns:
--    The function returns the number of rows selected.
--    If there is an error then the function returns null.
-- Output:
--   Displays the output of the SQL statement as text. The only difference
--   between this and display SQL is that this will print a Title or
--   heading statement prior to the actual sql output.
-- Examples:
--   declare
--      num_rows     number;
--      sqltxt       varchar2(2000);
--      disp_lengths lengths;
--      col_headers  headers;
--   begin
--     sqltxt := 'Select segment1, project_type, project_id '||
--               'from pa_projects_all'
--     disp_lengths := lengths(20,15,8);
--     col_headers  := headers('Project Number', 'Project Type', null);
--
--     num_rows := Run_SQL('All Projects', sqltxt, disp_lengths, col_headers);
--     tab0Print(to_char(num_rows)||' rows selected');
--     /* or */
--     num_rows := Run_SQL('All Projects', sqltxt, disp_lengths);
--     /* or */
--     Run_SQL('All Projects', sqltxt, disp_lengths, col_headers);
--     /* or */
--     Run_SQL('All Projects', sqltxt, disp_lengths);
--   end;

function Run_SQL_text(p_title         varchar2,
                 p_sql_statement varchar2,
                 p_disp_lengths  lengths)
return number is
begin
   SectionPrint(p_title);
   BRPrint;
   return(Display_SQL(p_sql_statement , p_disp_lengths));
end Run_SQL_text;

function Run_SQL_text(p_title         varchar2,
                 p_sql_statement varchar2,
                 p_disp_lengths  lengths,
                 p_headers       headers)
return number is
begin
   SectionPrint(p_title);
   BRPrint;
   return(Display_SQL(p_sql_statement , p_disp_lengths, p_headers));
end Run_SQL_text;

function Run_SQL_text(p_title         varchar2,
                 p_sql_statement varchar2,
                 p_disp_lengths  lengths,
                 p_headers       headers,
                 p_feedback      varchar2)
return number is
begin
   SectionPrint(p_title);
   BRPrint;
   return(Display_SQL(p_sql_statement, p_disp_lengths, p_headers, p_feedback));
end Run_SQL_text;

function Run_SQL_text(p_title         varchar2,
                 p_sql_statement varchar2,
                 p_disp_lengths  lengths,
                 p_headers       headers,
                 p_max_rows      number)
return number is
begin
   SectionPrint(p_title);
   BRPrint;
   return(Display_SQL(p_sql_statement , p_disp_lengths, p_headers,
      'Y',p_max_rows));
end Run_SQL_text;

function Run_SQL_text(p_title         varchar2,
                 p_sql_statement varchar2,
                 p_disp_lengths  lengths,
                 p_headers       headers,
                 p_feedback      varchar2,
                 p_max_rows      number)
return number is
begin
   SectionPrint(p_title);
   BRPrint;
   return(Display_SQL(p_sql_statement , p_disp_lengths, p_headers,
      p_feedback,p_max_rows));
end Run_SQL_text;

procedure Run_SQL_text(p_title         varchar2,
                 p_sql_statement varchar2,
                 p_disp_lengths  lengths) is
  dummy   number;
begin
   SectionPrint(p_title);
   BRPrint;
   dummy := Display_SQL(p_sql_statement , p_disp_lengths);
end Run_SQL_text;

procedure Run_SQL_text(p_title         varchar2,
                 p_sql_statement varchar2,
                 p_disp_lengths  lengths,
                 p_headers       headers) is
  dummy   number;
begin
   SectionPrint(p_title);
   BRPrint;
   dummy := Display_SQL(p_sql_statement , p_disp_lengths, p_headers);
end Run_SQL_text;

procedure Run_SQL_text(p_title        varchar2,
                 p_sql_statement varchar2,
                 p_disp_lengths  lengths,
                 p_headers       headers,
                 p_feedback      varchar2) is
  dummy   number;
begin
   SectionPrint(p_title);
   BRPrint;
   dummy := Display_SQL(p_sql_statement , p_disp_lengths, p_headers,
      p_feedback);
end Run_SQL_text;

procedure Run_SQL_text(p_title        varchar2,
                 p_sql_statement varchar2,
                 p_disp_lengths  lengths,
                 p_headers       headers,
                 p_max_rows      number) is
  dummy   number;
begin
   SectionPrint(p_title);
   BRPrint;
   dummy := Display_SQL(p_sql_statement , p_disp_lengths, p_headers,
      'Y', p_max_rows);
end Run_SQL_text;

procedure Run_SQL_text(p_title        varchar2,
                 p_sql_statement varchar2,
                 p_disp_lengths  lengths,
                 p_headers       headers,
                 p_feedback      varchar2,
                 p_max_rows      number) is
  dummy   number;
begin
   SectionPrint(p_title);
   BRPrint;
   dummy := Display_SQL(p_sql_statement , p_disp_lengths, p_headers,
      p_feedback, p_max_rows);
end Run_SQL_text;

/*
 Procedure Name: Display_Table
 Usage:
    Display_Table('Table Name', 'Heading', 'Where Clause',
      'Order By', 'Long Flag');
 Parameters:
   Table Name - Any Valid Table or View
      Heading - Text String to for heading the output
   Where Clause - Where clause to apply to the table dump
      Order By - Order By clause to apply to the table dump
      Long Flag - 'Y' or 'N'  - If set to 'N' then this will not
                  output any LONG columns
 Output:
   Displays the output of the 'select * from table' as an HTML table.
 Examples:
   begin
      Display_Table('AR_SYSTEM_PARAMETERS_ALL', 'AR Parameters',
         'Where Org_id <> -3113'
                         , 'order by org_id, set_of_books_id', 'N');
   end;

procedure Display_Table_text (p_table_name   varchar2,
          p_table_alias   varchar2,
          p_where_clause   varchar2,
          p_order_by_clause varchar2 default null,
          p_display_longs   varchar2 default 'Y') is
   dummy      number;
   hold_char   varchar(1) := null;
begin
   if p_where_clause is not null then
      hold_char := l_newline;
   end if;
   dummy := Display_SQL ('select * from ' || replace(upper(p_table_name),'V_$','V$') || l_newline || p_where_clause || hold_char || nvl(p_order_by_clause,'order by 1')
          , nvl(p_table_alias, p_table_name)
          , p_display_longs);
end Display_Table_text;

 Function Name: Display_Table
 Usage:
    a_number := Display_Table('Table Name', 'Heading', 'Where Clause',
      'Order By', 'Long Flag');
 Parameters:
   Table Name - Any Valid Table or View
      Heading - Text String to for heading the output
   Where Clause - Where clause to apply to the table dump
      Order By - Order By clause to apply to the table dump
      Long Flag - 'Y' or 'N'  - If set to 'N' then this will not output
                  any LONG columns
 Output:
   Displays the output of the 'select * from table' as an HTML table.
 Returns:
   Number of rows displayed.
 Examples:
   declare
      num_rows   number;
   begin
      num_rows := Display_Table('AR_SYSTEM_PARAMETERS_ALL',
        'AR Parameters', 'Where Org_id <> -3113',
        'order by org_id, set_of_books_id', 'N');
   end;

function Display_Table_text (p_table_name   varchar2,
          p_table_alias   varchar2,
          p_where_clause   varchar2,
          p_order_by_clause varchar2 default null,
          p_display_longs   varchar2 default 'Y') return number is
begin
   return(Display_SQL ('select * from ' || replace(upper(p_table_name),'V_$','V$') || l_newline || p_where_clause || l_newline || nvl(p_order_by_clause,'order by 1')
          , nvl(p_table_alias, p_table_name)
          , p_display_longs));
end Display_Table_text;

*/

--  Function Name: Get_DB_Apps_Version
-- Description:
--   Finds the applications version and sets the global variable
--   g_appl_version to the string value 10.7, 11.0, or 11.5 for
--   use throughout the script where branching due to applications
--   release may be necessary.
-- Usage:
--    a_string := Get_DB_Apps_Version;
-- Parameters:
--   None
-- Output:
--   None
-- Examples:
--   begin
--     Tab0Print('Applications Version: '||Get_DB_Apps_Version);
--   end;

function Get_DB_Apps_Version_text return varchar2 is
   l_appsver  fnd_product_groups.release_name%type := null;
begin
   select release_name into l_appsver from fnd_product_groups;
   g_appl_version := substr(l_appsver,1,4);
   return(l_appsver);
end;



-- Procedure Name: Show_Header
-- Usage:
--    Show_Header('Note Number', 'Title');
-- Parameters:
--   Note Number - Any Valid Metalink Note Number
--   Title - Text string to go beside the note link
-- Output:
--   Displays Standard Header Information
-- Examples:
--   begin
--     Show_Header('139684.1',
--       'Oracle Applications Current Patchsets Comparison to applptch.txt');
--   end;

procedure Show_Header_text(p_note varchar2, p_title varchar2) is
   l_instance_name   varchar2(16) := null;
   l_host_name       varchar2(64) := null;
   l_language        varchar2(512):= null;
   l_version         varchar2(17) := null;
   l_org_name        hr_all_organization_units.name%type;
begin
  select instance_name, host_name, version
  into l_instance_name, l_host_name, l_version
  from v$instance;

  begin
    select upper(value) into l_language
    from  v$parameter
    where  name = 'nls_language';
  exception when others then
    l_language := null;
  end;
  SectionPrint('System Information');
  line_out('Machine:        '|| l_host_name);
  line_out('Date Run:       '|| to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
  line_out('DB Info:        SID: '||l_instance_name||' Version: '||l_version);
  line_out('DB Language:    '||l_language);
  line_out('Apps Version:   '|| Get_DB_Apps_Version);
  if g_org_id is not null then
    begin
      select name into l_org_name
      from   hr_all_organization_units
      where  organization_id = g_org_id;
    exception when others then
      l_org_name := null;
    end;
    if l_org_name is not null then
      line_out('Operating Unit: '||l_org_name||' (ID='||to_char(g_org_id)||')');
    end if;
  end if;
  BRPrint;
  if p_note is not null then
    if p_title is not null then
      line_out('Note:         '||p_note||' - '||p_title);
    else
      line_out('Note:         '||p_note);
    end if;
  else
    if p_title is not null then
      line_out('Title:        '||p_title);
    end if;
  end if;
end Show_Header_text;

-- Procedure Name: Show_Footer
-- Usage:
--    Show_Footer;
--    Show_Footer('Script Description','Script Header');
-- Parameters:
--    Script Description - Description of the script (not used)
--    Script Header - Header/version information for the script (not used)
--       These parameters are allowed so that calls for the HTML API will
--       work in the text API as well.  They are not used for anything.
-- Output:
--   Displays Standard Footer
-- Examples:
--   begin
--     Show_Footer;
--     Show_Footer('My Script','$Header: jtfdiagcoreapi_b.pls 120.11.12000000.3 2007/04/05 09:33:32 rudas ship $');
--   end;

procedure Show_Footer_text is
begin
  line_out('Please provide feedback regarding the usefulness of this test '||
    'and/or tool');
  line_out('to support-diagnostics_ww@oracle.com.  We appreciate your '||
    'feedback, however,');
  line_out('there will be no replies to feedback emails.  For '||
    'support issues, please log');
  line_out('an iTar (Service Request).');
end Show_Footer_text;

procedure Show_Footer_text(p_dummy1 varchar2, p_dummy2 varchar2) is
begin
  Show_Footer;
end Show_Footer_text;

-- Procedure Name: Show_Link
-- Usage:
--    Show_Link('Note #');
-- Output:
--   Displays A link to a Metalink Note
-- Examples:
--   begin
--      Show_Link('139684.1');
--   end;

procedure Show_Link_text(p_note varchar2) is
begin
  line_out('See Note: '||p_note);
end Show_Link_text;

-- Procedure Name: Show_Link
-- Usage:
--    Show_Link('URL', 'Name');
-- Output:
--   Displays A link to a URL using the Name Parameter
-- Examples:
--   begin
--      Show_Link('http://metalink.us.oracle.com', 'Metalink');
--   end;

procedure Show_Link_text(p_link varchar2, p_link_name varchar2 ) is
begin
   line_out('See '||p_link_name||' at '||p_link);
end Show_Link_text;

-- Function Name: Get_Package_Version
-- Usage:
--   a_varchar := Get_Package_Version ('Object Type', 'Schema', 'Package Name');
-- Returns:
--   The version of the package or spec
-- Examples:
--   declare
--     spec_ver   varchar2(20);
--     body_ver   varchar2(20);
--   begin
--     spec_ver := Get_Package_Version('PACKAGE','APPS','ARH_ADDR_PKG');
--     body_ver := Get_Package_Version('PACKAGE BODY','APPS','ARH_ADDR_PKG');
--   end;

function Get_Package_Version_text (p_type varchar2, p_schema varchar2,
                              p_package varchar2)
return varchar2 is
  hold_version   varchar2(50);
begin
  select substr(z.text, instr(z.text,'$Header')+10, 40)
    into hold_version
    from all_source z
   where z.name = p_package
     and z.type = p_type
     and z.owner = p_schema
     and z.text like '%$Header%';
  hold_version := substr(hold_version, instr(hold_version,' ')+1, 50);
  hold_version := substr(hold_version, 1, instr(hold_version,' ')-1);
  return (hold_version);
exception
  when no_data_found then
    ErrorPrint(p_type||' '||p_package||' owned by '||p_schema||
      ' does not exist');
    ActionPrint('Verify that this object is valid for your version of '||
      'applications and that the owner indicated is correct');
    return(null);
  when others then
    ErrorPrint(sqlerrm||' occured in Get_Package_Version');
    ActionPrint('Please provide this information to your support '||
      'representative');
    raise;
end Get_Package_Version_text;

-- Function Name: Get_Package_Spec
-- Usage:
--    a_varchar := Get_Package_Spec('Package Name');
-- Returns:
--   The version of the package specification in the APPS schema
-- Examples:
--    declare
--      spec_ver   varchar2(20);
--   begin
--      spec_ver := Get_Package_Spec('ARH_ADDR_PKG');
--   end;

function Get_Package_Spec_text(p_package varchar2) return varchar2 is
begin
   return Get_Package_Version('PACKAGE','APPS',p_package);
end Get_Package_Spec_text;

-- Function Name: Get_Package_Body
-- Usage:
--    a_varchar := Get_Package_Body('Package Name');
-- Returns:
--   The version of the package body in the APPS schema
-- Examples:
--    declare
--      body_ver   varchar2(20);
--   begin
--      body_ver := Get_Package_Body('ARH_ADDR_PKG');
--   end;

function Get_Package_Body_text(p_package varchar2) return varchar2 is
begin
   return Get_Package_Version('PACKAGE BODY','APPS',p_package);
end Get_Package_Body_text;

-- Procedure Name: Display_Profiles
-- Usage:
--    Display_Profiles(application_id, 'profile short name');
-- Parameters:
--   application_id - if provided will limit output to profile options
--                    associated with this application_id
--   profile_short_name - system name of the profile option. Will limit output
--                        to the settings for this specific profile option
-- Output:
--   Displays all Profile settings for the application or specific profile
--   option at all levels for which it is set.
-- Examples:
--   begin
--      Display_Profiles(275,null);
--      Display_Profiles(null, 'PA_DEBUG_MODE');
--   end;


procedure Display_Profiles_text (p_application_id varchar2, p_short_name varchar2) is
cursor get_profile_options is
select substr(ot.user_profile_option_name,1,45) user_profile_option_name,
       substr(o.profile_option_name,1,30) profile_option_name,
       decode(v.level_id,10001, 'Site',  10002, 'Appl',
                       10003, 'Resp',
                       10004, 'User') lev,
       substr(decode(v.level_id,
                       10001, ' ',
                       10002, a.application_name,
                       10003, r.responsibility_name,
                       10004, u.user_name),1,20) lev_value,
       v.profile_option_value opt_value
from fnd_profile_option_values v,
     fnd_profile_options o,
     fnd_profile_options_tl ot,
     fnd_application_tl a,
     fnd_responsibility_tl r,
     fnd_user u
where  o.application_id = nvl(p_application_id, o.application_id)
and    o.profile_option_name = nvl(p_short_name, o.profile_option_name)
and    v.LEVEL_VALUE =
           decode(level_id, 10004, u.user_id, 10003, r.responsibility_id,
                                      10002, a.application_id,10001,0)
and v.profile_option_id = o.profile_option_id
and v.application_id = o.application_id
and a.application_id (+) = v.level_value
and r.responsibility_id (+) = v.level_value
and u.user_id (+) = v.level_value
and ot.profile_option_name = o.profile_option_name
and nvl(ot.language,'US') = nvl(USERENV('LANG'),'US')
and sysdate between nvl(o.start_date_active, sysdate) and
    nvl(o.end_date_active,sysdate)
and v.profile_option_value is not null
order by ot.user_profile_option_name, v.level_id,
         decode(level_id,10001, 'Site',  10002, a.application_name, 10003,
              r.responsibility_name, 10004, u.user_name);
max_user_opt  integer;
max_opt       integer;
max_lev       integer;
max_lev_value integer;
max_opt_value integer;
begin
  select max(length(substr(ot.user_profile_option_name,1,45))) max_u_length,
         max(length(substr(o.profile_option_name,1,30)))       max_length,
         max(length(decode(v.level_id,10001, 'Site',  10002, 'Appl',
                       10003, 'Resp',
                       10004, 'User'))),
         max(length(substr(decode(v.level_id,
                       10001, ' ',
                       10002, a.application_name,
                       10003, r.responsibility_name,
                       10004, u.user_name),1,20))),
         max(length(v.profile_option_value))
  into   max_user_opt, max_opt, max_lev, max_lev_value, max_opt_value
  from fnd_profile_option_values v,
       fnd_profile_options o,
       fnd_profile_options_tl ot,
       fnd_application_tl a,
       fnd_responsibility_tl r,
       fnd_user u
  where  o.application_id = nvl(p_application_id, o.application_id)
  and    o.profile_option_name = nvl(p_short_name, o.profile_option_name)
  and    v.LEVEL_VALUE =
             decode(level_id, 10004, u.user_id, 10003, r.responsibility_id,
                                      10002, a.application_id,10001,0)
  and v.profile_option_id = o.profile_option_id
  and v.application_id = o.application_id
  and a.application_id (+) = v.level_value
  and r.responsibility_id (+) = v.level_value
  and u.user_id (+) = v.level_value
  and ot.profile_option_name = o.profile_option_name
  and nvl(ot.language,'US') = nvl(USERENV('LANG'),'US')
  and sysdate between nvl(o.start_date_active, sysdate) and
      nvl(o.end_date_active,sysdate)
  and v.profile_option_value is not null;

  line_out(rpad('User Profile Name',greatest(max_user_opt,17),' ')||' '||
           rpad('System Name',greatest(max_opt,11),' ')||' '||
           rpad('Level',greatest(max_lev,5),' ')||' '||
           rpad('Level Value',greatest(max_lev_value,11),' ')||' '||
           rpad('Opt Value',greatest(max_opt_value,9),' '));
  line_out(rpad('-',greatest(max_user_opt,17),'-')||' '||
           rpad('-',greatest(max_opt,11),'-')||' '||
           rpad('-',greatest(max_lev,5),'-')||' '||
           rpad('-',greatest(max_lev_value,11),'-')||' '||
           rpad('-',greatest(max_opt_value,9),'-'));
  for opt in get_profile_options loop
    line_out(rpad(opt.user_profile_option_name,
                  greatest(max_user_opt,17),' ')||' '||
             rpad(opt.profile_option_name,greatest(max_opt,11),' ')||' '||
             rpad(opt.lev,greatest(max_lev,5),' ')||' '||
             rpad(opt.lev_value,greatest(max_lev_value,11),' ')||' '||
             rpad(opt.opt_value,greatest(max_opt_value,9),' '));
  end loop;
exception when others then
  ErrorPrint('Unexpected error: '||sqlerrm||' occured in Display_Profiles');
  ActionErrorPrint('Report the above error message to your support '||
    'representative');
end Display_Profiles_text;

-- Procedure Name: Get_Profile_Option
-- Usage:
--    a_varchar := Get_Profile_Option('Short Name');
-- Parameters:
--   Short Name - The Short Name of the Profile Option
-- Returns:
--   The value of the profile option based on the user, responsibility,
--   and application context.
--   If Set_Client has not been run successfully then
--   it will return the site level setting.
-- Output:
--   None
-- Examples:
--   declare
--      prof_value   varchar2(150);
--   begin
--      prof_value := Get_Profile_Option('AR_ALLOW_OVERAPPLICATION_IN_LOCKBOX')
--   end;

function Get_Profile_Option_text (p_profile_option varchar2) return varchar2 is
begin
   return FND_PROFILE.VALUE(p_profile_option);
end;

-- Procedure Name: Set_Org
-- Usage:
--    Set_Org(org_id);
-- Parameters:
--    Org_ID - Character string containing the id of the organization to set.
-- Output:
--   None
-- Examples:
--   begin
--      Set_Org('204');
--   end;

procedure Set_Org_text (p_org_id Varchar2) is
begin
   fnd_client_info.set_org_context(p_org_id);
end Set_Org_text;

procedure Set_Org_text (p_org_id number) is
l_org_id varchar2(10);
begin
  l_org_id := to_char(p_org_id);
  fnd_client_info.set_org_context(l_org_id);
end Set_Org_text;

-- Procedure Name: Set_Client
-- Description:
--   Validates user_name, responsibility_id, and application_id  parameters
--   If valid it initializes the session (which results in the operating
--   unit being set for the session as well.  Also sets the global variables
--   g_user_id, g_resp_id, g_appl_id, and g_org_id which can then be used
--   throughout the script.
-- Usage:
--    Set_Client(UserName, Responsibility_ID);
--    Set_Client(UserName, Responsibility_ID, Application_ID);
--    Set_Client(UserName, Responsibility_ID, Application_ID, SecurityGrp_ID);
-- Parameters:
--   UserName - The Name of the Applications User
--   Responsibility_ID - Any Valid Responsibility ID
--   Application_ID - Any Valid Application ID (275=PA) If no value
--                    provided, attempt to obtain from responsibility_id
--   SecurityGrp_ID - A valid security_group_id
-- Examples:
--   begin
--      Set_Client('JOEUSER',50719, 222);
--   end;

procedure Set_Client_text(p_user_name varchar2, p_resp_id number,
                     p_app_id number, p_sec_grp_id number) is
   l_cursor     integer;
   l_num_rows   integer;
   l_user_name  fnd_user.user_name%type;
   l_user_id    number;
   l_app_id     number;
   l_counter    integer;
   l_appl_vers  fnd_product_groups.release_name%type;
   sqltxt       varchar2(2000);
   inv_user exception;
   inv_resp exception;
   inv_app  exception;
   no_app   exception;
begin
  l_user_name := upper(p_user_name);
  begin
    select user_id into l_user_id
    from fnd_user where user_name = l_user_name;
  exception
    when others then
      raise inv_user;
  end;
  l_appl_vers := get_db_apps_version; -- sets g_appl_version
  if g_appl_version = '11.0' or g_appl_version = '10.7' then
    sqltxt := 'select rg.application_id '||
              'from   fnd_user_responsibility rg '||
              'where  rg.responsibility_id = '||to_char(p_resp_id)||' '||
              'and    rg.user_id = '||to_char(l_user_id);
  elsif g_appl_version = '11.5' then
    sqltxt := 'select rg.responsibility_application_id '||
              'from   fnd_user_resp_groups rg '||
              'where  rg.responsibility_id = '||to_char(p_resp_id)||' '||
              'and    rg.user_id = '||to_char(l_user_id);
  end if;
  begin
    l_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(l_cursor, sqltxt, dbms_sql.native);
    dbms_sql.define_column(l_cursor, 1, l_app_id);
    l_num_rows := dbms_sql.execute_and_fetch(l_cursor, TRUE);
    dbms_sql.column_value(l_cursor, 1, l_app_id);
    dbms_sql.close_cursor(l_cursor);

  exception
    when no_data_found then
      raise inv_resp;
    when too_many_rows then
      if p_app_id is null then
        raise no_app;
      else
        dbms_sql.close_cursor(l_cursor);
        l_cursor := dbms_sql.open_cursor;
        dbms_sql.parse(l_cursor, sqltxt, dbms_sql.native);
        dbms_sql.define_column(l_cursor, 1, l_app_id);
        l_num_rows := dbms_sql.execute(l_cursor);
        while dbms_sql.fetch_rows(l_cursor) > 0 loop
          dbms_sql.column_value(l_cursor, 1, l_app_id);
          if l_app_id = p_app_id then
            exit;
          end if;
        end loop;
        dbms_sql.close_cursor(l_cursor);
        if l_app_id <> p_app_id then
          raise inv_app;
        end if;
      end if;
  end;
  l_cursor := dbms_sql.open_cursor;
  if g_appl_version = '11.5' then
    sqltxt := 'begin '||
                'fnd_global.apps_initialize(:user, :resp, '||
                ':appl, :secg); '||
              'end; ';
    dbms_sql.parse(l_cursor, sqltxt, dbms_sql.native);
    dbms_sql.bind_variable(l_cursor,':user',l_user_id);
    dbms_sql.bind_variable(l_cursor,':resp',p_resp_id);
    dbms_sql.bind_variable(l_cursor,':appl',l_app_id);
    dbms_sql.bind_variable(l_cursor,':secg',p_sec_grp_id);
  else
    sqltxt := 'begin '||
                'fnd_global.apps_initialize(:user,:resp,:appl); '||
              'end; ';
    dbms_sql.parse(l_cursor, sqltxt, dbms_sql.native);
    dbms_sql.bind_variable(l_cursor,':user',l_user_id);
    dbms_sql.bind_variable(l_cursor,':resp',p_resp_id);
    dbms_sql.bind_variable(l_cursor,':appl',l_app_id);
  end if;
  l_num_rows := dbms_sql.execute(l_cursor);
  g_user_id := l_user_id;
  g_resp_id := p_resp_id;
  g_appl_id := l_app_id;
  g_org_id := Get_Profile_Option('ORG_ID');
exception
  when inv_user then
    ErrorPrint('Unable to initialize client due to invalid username: '||
      l_user_name);
    ActionErrorPrint('Set_Client has been passed an invalid username '||
      'parameter.  Please correct this parameter if possible, and if not, '||
      'inform your support representative.');
    raise;
  when inv_resp then
    ErrorPrint('Unable to initialize client due to invalid responsibility '||
      'ID: '||to_char(p_resp_id));
    ActionErrorPrint('Set_Client has been passed an invalid responsibility '||
      'ID parameter. This responsibility_id either does not exist or has not '||
      'been assigned to the user ('||l_user_name||'). Please correct these '||
      'parameter values if possible, and if not inform your support '||
      'representative.');
    raise;
  when inv_app then
    ErrorPrint('Unable to initialize client due to invalid application ID: '||
      to_char(p_app_id));
    ActionErrorPrint('Set_Client has been passed an invalid application ID '||
      'parameter. This application either does not exist or is not '||
      'associated with the responsibility id ('||to_char(p_resp_id)||'). '||
      'Please correct this parameter value if possible, and if not inform '||
      'your support representative.');
    raise;
  when no_app then
    ErrorPrint('Set_Client was unable to obtain an application ID to '||
      'initialize client settings');
    ActionErrorPrint('No application_id was supplied and Set_Client was '||
      'unable to determine this from the responsibility because multiple '||
      'responsibilities with the same responsibility_id have been assigned '||
      'to this user ('||l_user_name||').');
    raise;
  when others then
    ErrorPrint(sqlerrm||' occured in Set_Client');
    ActionErrorPrint('Please inform your support representative');
    raise;
end Set_Client_text;

procedure Set_Client_text(p_user_name varchar2, p_resp_id number) is
begin
  Set_Client(p_user_name, p_resp_id, null, null);
end Set_Client_text;

procedure Set_Client_text(p_user_name varchar2, p_resp_id number,
                     p_app_id number ) is
begin
  Set_Client(p_user_name, p_resp_id, p_app_id, null);
end Set_Client_text;

/*
-- OBSOLETED API SINCE THIS IS NOT COMPLIANT WITH GSCC STANDARD
-- FILE.SQL.6 WHICH DOES NOT PERMIT USING OF SCHEMA
-- NAMES WITHIN PLSQL CODE

-- Procedure Name: Get_DB_Patch_List
-- Usage:
--   Get_DB_Patch_List('heading', 'short name', 'bug number', 'start date');
-- Parameters:
--   Heading = Title to go at the top of TABLE or TEXT outputs
--   Short Name = Limits to Bugs that match this expression for the
--                Applications Production Short Name (LIKE)
--   Bug Number = Limits to bugs that match this expression (LIKE)
--   Start Date = Limits to Bugs applied after this date
-- Output:
--   FORMATTED TEXT listing of patches applied is displayed
-- Examples:
--   begin
--        Get_DB_Patch_List('AD Patches Applied Since 03-MAR-2002',
--          'AD','%', '03-MAR-2002');
--   end;

procedure Get_DB_Patch_List_text (
             p_heading varchar2 default 'AD_BUGS'
           , p_app_short_name varchar2 default '%'
           , p_bug_number varchar2 default '%'
           , p_start_date date default to_date(olddate,'MM-DD-YYYY')) is
l_appl_version  fnd_product_groups.release_name%type;
l_disp_lengths lengths;
l_headers      headers;
l_counter      integer;
sqltxt         varchar2(32767);
begin
  if g_appl_version is null then
    l_appl_version := get_db_apps_version;  -- sets g_appl_version
  end if;
  SectionPrint(p_heading);
  if g_appl_version = '11.5' then

    select count(*) into l_counter from all_tables z
    where  z.table_name = 'AD_BUGS'
    and z.owner = 'APPLSYS';

    if l_counter = 0 then
      WarningPrint('The function Get_DB_Patch_List is not available');
      ActionPrint('If the table AD_BUGS does not exist in the database you '||
        'must review the applptch.txt file in the APPL_TOP directory '||
        'for patch application information. This functionality is available '||
        'with release 11.5.5 and above or 11.5 with AD patchset E or higher.');
    else
      BRPrint;
      l_headers := headers('Patch Number','Creation Date', 'Appl Short Name');
      l_disp_lengths := lengths(9, 11, 5);
      sqltxt := 'select bug_number, creation_date, application_short_name ' ||
                'from ad_bugs '||
                'where upper(application_short_name) like '''||
                 p_app_short_name||''''||
                'and bug_number like '''||p_bug_number||''''||
                'and creation_date >= nvl(to_date('''||
                   to_char(p_start_date,'MM-DD-YYYY')||
                ''',''MM-DD-YYYY''),creation_date)';
      display_sql(sqltxt,l_disp_lengths, l_headers);
      BRPrint;
    end if;
  else
    WarningPrint('The Get_DB_Patch_List function is only available on '||
      'applications 11.5');
    ActionPrint('For release 11.0 and 10.7 review the file applptch.txt '||
      'in your APPL_TOP directory');
  end if;
end Get_DB_Patch_List_text;
*/

-- Function Name: Get_RDBMS_Header
-- Usage:
--    Get_RDBMS_Header;
-- Returns:
--   Version of the Database from v$version
-- Examples:
--   declare
--      RDBMS_Ver := v$version.banner%type;
--   begin
--      RDBMS_Ver := Get_RDBMS_Header;
--   end;

Function Get_RDBMS_Header_text return varchar2 is
   l_hold_name   v$database.name%type;
   l_DB_Ver   v$version.banner%type;
begin
   begin
      select name
        into l_hold_name
        from v$database;
   exception
      when others then
         l_hold_name := 'Not Available';
   end;
   begin
      select banner
        into l_DB_Ver
        from v$version
       where banner like 'Oracle%';
   exception
      when others then
         l_DB_Ver := 'Not Available';
   end;
   return(l_hold_name || ' - ' || l_DB_Ver);
end Get_RDBMS_Header_text;

-- Function Name: Compare_Pkg_Version
-- Usage:
--    Compare_Pkg_Version('package_name','obj_type','obj_owner', 'outversvar',
--                        'reference_version');
--    Compare_Pkg_Version('package_name','obj_type', 'outversvar',
--                        'reference_version');
-- Parameters:
--   package_name - Name of the package whose version is being checked
--   obj_type - Either BODY or SPEC to determine which piece to check
--   obj_owner - The owner of the package being checked.  If null or
--               not supplied the default is APPS.
--   outversvar - A text out variable to hold the actual package version
--                of the package as returned from the database
--   reference_version - A string containing the version to which the
--                       package version should be compared (in format ###.##,
--                       ie, in a format convertible to a number.  As opposed
--                       to, for example, 11.5.119, use 115.119.
-- Returns:
--   'greater' if the version of the object is greater than the reference
--   'less'    if the version of the object is less than the reference
--   'equal'   if the version of the object is equal to the reference
--   'null'    if either the reference or db version is null
-- Examples:
--   declare
--      Comparison_Var  varchar2(8);
--      Package_Version varchar2(10);
--   begin
--      Comparison_Var := Compare_Pkg_Version('PA_UTILS2','BODY','APPS',
--                             Package_Version, '115.13');
--      Comparison_Var := Compare_Pkg_Version('PA_UTILS2','BODY',
--                             Package_Version, '115.13');
--   end;

Function Compare_Pkg_Version_text(
     package_name   in varchar2,
     object_type in varchar2,
     object_owner in varchar2,
     version_str in out NOCOPY varchar2,
     compare_version in varchar2)
return varchar2 is
  vers_line varchar2(1000);
  l_object_owner varchar2(250);
  db_vers_key number;
  in_vers_key number;
begin
  l_object_owner := object_owner;
  if l_object_owner is null then
    l_object_owner := 'APPS';
  end if;
  in_vers_key :=
    to_number(substr(compare_version,instr(compare_version,'.')+1));
  if upper(object_type) = 'BODY' then
    select z.text into vers_line
    from   dba_source z
    where  z.name = package_name
    and    z.owner = l_object_owner
    and    z.text like '%$Header%'
    and    z.type = 'PACKAGE BODY';
  else
    select z.text into vers_line
    from   dba_source z
    where  z.name = package_name
    and    z.owner = l_object_owner
    and    z.text like '%$Header%'
    and    z.type = 'PACKAGE';
  end if;
  vers_line := substr(vers_line,instr(vers_line,'$Header:')+9);
  vers_line := ltrim(vers_line);
  vers_line := substr(vers_line,1,instr(vers_line,' ',1,2)-1);
  vers_line := substr(vers_line,instr(vers_line,' ')+1);
  version_str := vers_line;
  db_vers_key :=
    to_number(substr(vers_line,instr(vers_line,'.')+1));
  if db_vers_key < in_vers_key then
    return('less');
  elsif db_vers_key > in_vers_key then
    return('greater');
  elsif db_vers_key = in_vers_key then
    return('equal');
  elsif db_vers_key is null or in_vers_key is null then
    return('null');
  end if;
exception when others then
  ErrorPrint('Unable to verify package version for '||package_name||' ('||
    object_type||') -- '||sqlerrm||' occured in Compare_Pkg_Version');
  ActionErrorPrint('Contact your support representative and supply the '||
    'above error information');
  return('null');
end Compare_Pkg_Version_text;

Function Compare_Pkg_Version_text(
     package_name   in varchar2,
     object_type in varchar2,
     version_str in out NOCOPY varchar2,
     compare_version in varchar2 default null)
return varchar2 is
begin
  return(compare_pkg_version(
    package_name, object_type, null, version_str,compare_version));
end Compare_Pkg_Version_text;

/*

-- OBSOLETED API SINCE THIS IS NOT COMPLIANT WITH GSCC STANDARD
-- FILE.SQL.6 WHICH DOES NOT PERMIT USING OF SCHEMA
-- NAMES WITHIN PLSQL CODE


-- Procedure Name: Show_Invalids
-- Usage:
--    Show_Invalids('start string','include errors','heading');
-- Parameters:
--    start string = Only return objects beginning with this string (case
--                   insensitive)
--    include errors - Y or N to indicate whether to search on and report
--                     the errors from  ALL_ERRORS for each of the invalid
--                     objects found. (DEFAULT = N)
--    heading - An optional heading for the table.  If null the heading will
--              be "Invalid Objects (Starting with 'XXX')" where XXX is
--              the start string parameter.
-- Ouput:
--    Will output a list of invalid objects.  For PL/SQL program units the
--    file name and version will be displayed.  If the 'include errors'
--    parameter is 'Y' a listing of errors associated with the object will
--    be printed.
-- Examples:
--    begin
--      Show_Invalids('PA_');
--      Show_Invalids('GL','N','General Ledger Invalid Objects');
--    end;
Procedure Show_Invalids_text (p_start_string varchar2 default null
                      ,  p_include_errors varchar2 default 'N'
                      ,  p_heading        varchar2 default null) is
   l_start_string   varchar2(60);
   l_file_version   varchar2(100);
   l_heading        varchar2(500);
   l_sqltxt         varchar2(32767);
   l_first_row      boolean := true;
   l_table_row      varchar2(32767);
   l_lengths        lengths;
   l_hdrs           headers;
   l_rows           integer := 0;
   l_counter        integer := 0;

-- OWNER CHANGE
cursor get_invalids(c_start_string varchar2) is
select o.object_name, o.object_type, o.owner
from   all_objects o
where  o.status = 'INVALID'
and    o.object_name like c_start_string escape '~'
and    upper(o.owner) in ('APPS', 'JTF', 'APPLSYS')
order by o.object_name;

cursor get_file_version(
            c_obj_name varchar2
          , c_obj_type varchar2
          , c_obj_owner varchar2) is
select substr(substr(s.text,instr(s.text,'$Header')+9),1,
          instr(substr(s.text,instr(s.text,'$Header')+9),' ',1,2)-1) file_vers
from   all_source s
where  name = c_obj_name
and    type = c_obj_type
and    owner = c_obj_owner
and    text like '%$Header%';

cursor get_errors (
            c_obj_name varchar2
          , c_obj_type varchar2
          , c_obj_owner varchar2) is
select to_char(z.sequence)||') LINE: '||to_char(z.line)||' CHR: '||
          to_char(z.position)||'  '||text error_row
from   all_errors z
where  z.name = c_obj_name
and    z.type = c_obj_type
and    z.owner = c_obj_owner;

begin
  l_start_string := upper(replace(p_start_string,'_','~_')) || '%';
  if p_heading is null then
    l_heading := 'Invalid Objects (Starting with '''||p_start_string||''')';
  else
    l_heading := p_heading;
  end if;
  SectionPrint(l_heading);
  l_lengths := lengths(35,13,9,20);
  l_hdrs    := headers('Object Name','Object Type','Owner','Version');

  for inv_rec in get_invalids(l_start_string) loop
    if l_first_row then
      Show_Table_Header(l_hdrs, l_lengths);
      l_first_row := false;
    end if;
    l_table_row :=
      rpad(nvl(substr(inv_rec.object_name,1,35),' '),35,' ')||' '||
      rpad(nvl(substr(inv_rec.object_type,1,13),' '),13,' ')||' '||
      rpad(nvl(substr(inv_rec.owner,1,9),' '),9,' ')||' ';
    if inv_rec.object_type like 'PACKAGE%' or
      inv_rec.object_type in ('PROCEDURE','FUNCTION') then
      open get_file_version(inv_rec.object_name, inv_rec.object_type,
        inv_rec.owner);
      fetch get_file_version into l_file_version;
      if get_file_version%notfound then
        l_file_version := null;
      end if;
      close get_file_version;
    else
      l_file_version := null;
    end if;
    l_file_version := rpad(nvl(substr(l_file_version,1,20),' '),20,' ');
    l_table_row := l_table_row||l_file_version;
    Tab0Print(l_table_row);
    l_rows := l_rows + 1;

    if p_include_errors = 'Y' then
      l_counter := 0;
      for err_rec in get_errors(inv_rec.object_name, inv_rec.object_type,
          inv_rec.owner) loop
        if l_counter = 0 then
          Tab1Print('Object Errors:');
        end if;
        l_counter := l_counter + 1;
        Tab1Print(err_rec.error_row);
      end loop;
      if l_counter > 0 then
        BRPrint;
      end if;
    end if;
  end loop
  BRPrint;
  Tab0Print(to_char(l_rows)||' rows selected');
  BRPrint;
exception when others then
   ErrorPrint(sqlerrm||' occurred in Show_Invalids');
   ActionErrorPrint('Please report this information to your support '||
     'representative');
end Show_Invalids_text;
*/

------------------------------------------------------------------------
-- External APIs
-----------------------------------------------------------------------

procedure line_out (text varchar2) IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   line_out_html (text);
  ELSE
   line_out_text (text );
  END IF;
END;


procedure Insert_Style_Sheet IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   Insert_Style_Sheet_html;
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;


procedure Insert_HTML(p_text varchar2) IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   Insert_HTML_html(p_text);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;


procedure ActionErrorPrint(p_text varchar2) IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   ActionErrorPrint_html(p_text);
  ELSE
   ActionErrorPrint_text(p_text);
  END IF;
END;




procedure ActionPrint(p_text varchar2) IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   ActionPrint_html(p_text);
  ELSE
   ActionPrint_text(p_text);
 END IF;
END;


procedure ActionWarningPrint(p_text varchar2) IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   ActionWarningPrint_html(p_text);
  ELSE
   ActionWarningPrint_text(p_text);
  END IF;
END;



procedure WarningPrint(p_text varchar2) IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   WarningPrint_html(p_text);
  ELSE
   WarningPrint_text(p_text);
  END IF;
END;


procedure ActionErrorLink(p_txt1 varchar2
         , p_note varchar2
         , p_txt2 varchar2) IS
BEGIN
   IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
     ActionErrorLink_html(p_txt1, p_note, p_txt2);
   ELSE
    -- API currently not implemented for text
    null;
  END IF;
END;


procedure ActionErrorLink(p_txt1 varchar2
         , p_url varchar2
         , p_link_txt varchar2
         , p_txt2 varchar2) IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    ActionErrorLink_html(p_txt1,p_url,p_link_txt,p_txt2);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;


procedure ActionWarningLink(p_txt1 varchar2
                          , p_note varchar2
                          , p_txt2 varchar2) IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   ActionWarningLink_html(p_txt1, p_note, p_txt2);
  ELSE
   -- API currently not implemented for text
   null;
 END IF;
END;


procedure ActionWarningLink(p_txt1 varchar2
           , p_url varchar2
           , p_link_txt varchar2
           , p_txt2 varchar2) IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   ActionWarningLink_html(p_txt1,p_url ,p_link_txt,p_txt2);
 ELSE
   -- API currently not implemented for text
   null;
 END IF;
END;


procedure ErrorPrint(p_text varchar2) IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   ErrorPrint_html(p_text);
 ELSE
   ErrorPrint_text(p_text);
 END IF;
END;


procedure SectionPrint(p_text varchar2) IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   SectionPrint_html(p_text);
 ELSE
   SectionPrint_text(p_text);
 END IF;
END;


procedure Tab0Print (p_text varchar2) IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   Tab0Print_html(p_text);
 ELSE
   Tab0Print_text(p_text);
 END IF;
END;


procedure Tab1Print (p_text varchar2) IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   Tab1Print_html(p_text);
 ELSE
  Tab1Print_text(p_text);
 END IF;
END;



procedure Tab2Print (p_text varchar2) IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   Tab2Print_html(p_text);
 ELSE
  Tab2Print_text(p_text);
 END IF;
END;

procedure Tab3Print (p_text varchar2) IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   Tab3Print_html(p_text);
 ELSE
  Tab3Print_text(p_text);
 END IF;
END;

procedure BRPrint IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   BRPrint_html;
 ELSE
   BRPrint_text;
 END IF;
END;

procedure checkFinPeriod (p_sobid NUMBER, p_appid NUMBER ) IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   checkFinPeriod_html(p_sobid, p_appid);
 ELSE
   checkFinPeriod_text(p_sobid, p_appid );
 END IF;
END;


procedure CheckKeyFlexfield(p_flex_code     in varchar2
                        ,   p_flex_num  in number default null
                        ,   p_print_heading in boolean default true) IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
  CheckKeyFlexfield_html(p_flex_code,p_flex_num,p_print_heading);
 ELSE
   CheckKeyFlexfield_text(p_flex_code,p_flex_num,p_print_heading);
 END IF;
END;


procedure CheckProfile(p_prof_name in varchar2
                    , p_user_id   in number
                    , p_resp_id   in number
                    , p_appl_id   in number
                    , p_default   in varchar2 default null
                    , p_indent    in integer default 0) IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
  CheckProfile_html(p_prof_name, p_user_id, p_resp_id,p_appl_id,p_default,p_indent);
 ELSE
   CheckProfile_text(p_prof_name, p_user_id, p_resp_id,p_appl_id,p_default,p_indent);
 END IF;
END;


procedure Begin_Pre IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    Begin_Pre_html;
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;


procedure End_Pre IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    End_Pre_html;
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;


procedure Show_Table(p_type varchar2, p_values V2T, p_caption varchar2 default null, p_options V2T default null) IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    Show_Table_html(p_type, p_values, p_caption, p_options);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;


procedure Show_Table(p_values V2T) IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   Show_Table_html(p_values);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;


procedure Show_Table(p_type varchar2) IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    Show_Table_html(p_type);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;


procedure Show_Table_Row(p_values V2T, p_options V2T default null) IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    Show_Table_Row_html(p_values, p_options);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;


procedure Show_Table_Header(p_values V2T, p_options V2T default null) IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    Show_Table_Header_html(p_values, p_options);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;

procedure Show_Table_Header(p_headers in headers, p_lengths in out NOCOPY lengths) IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    Show_Table_Header_text(p_headers,p_lengths);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;


procedure Start_Table(p_caption varchar2 default null) IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    Start_Table_html(p_caption);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;


procedure End_Table IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    End_Table_html;
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;


function Run_SQL(p_title varchar2, p_sql_statement varchar2) return number is
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    return Run_SQL_html(p_title,p_sql_statement);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;

function Run_SQL(p_title varchar2
               , p_sql_statement varchar2
               , p_feedback varchar2) return number is
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    return Run_SQL_html(p_title,p_sql_statement,p_feedback);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;


function Run_SQL(p_title varchar2
               , p_sql_statement varchar2
               , p_max_rows number) return number is
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    return Run_SQL_html(p_title,p_sql_statement,p_max_rows);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;



function Run_SQL(p_title varchar2
               , p_sql_statement varchar2
               , p_feedback varchar2
               , p_max_rows number) return number is
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    return Run_SQL_html(p_title,p_sql_statement,p_feedback ,p_max_rows);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;


procedure Run_SQL(p_title varchar2, p_sql_statement varchar2) is
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    Run_SQL_html(p_title,p_sql_statement);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;


procedure Run_SQL(p_title varchar2
                , p_sql_statement varchar2
                , p_feedback varchar2) is
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    Run_SQL_html(p_title,p_sql_statement,p_feedback);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;


procedure Run_SQL(p_title varchar2
                , p_sql_statement varchar2
                , p_max_rows number) is
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    Run_SQL_html(p_title,p_sql_statement,p_max_rows);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;

procedure Run_SQL(p_title varchar2
                , p_sql_statement varchar2
                , p_feedback varchar2
                , p_max_rows number) IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    Run_SQL_html(p_title,p_sql_statement,p_feedback ,p_max_rows);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;


function Run_SQL(p_title         varchar2,
                 p_sql_statement varchar2,
                 p_disp_lengths  lengths) return number is
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   -- API currently not implemented for html
   null;
  ELSE
   return Run_SQL_text(p_title,p_sql_statement,p_disp_lengths);
  END IF;
END;



function Run_SQL(p_title         varchar2,
                 p_sql_statement varchar2,
                 p_disp_lengths  lengths,
                 p_headers       headers) return number is
BEGIN
   IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
      -- API currently not implemented for html
     null;
   ELSE
     return Run_SQL_text(p_title,p_sql_statement,p_disp_lengths,p_headers);
  END IF;
END;

function Run_SQL(p_title         varchar2,
                 p_sql_statement varchar2,
                 p_disp_lengths  lengths,
                 p_headers       headers,
                 p_feedback      varchar2) return number is
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
      -- API currently not implemented for html
   null;
  ELSE
   return Run_SQL_text(p_title,p_sql_statement,p_disp_lengths,p_headers,p_feedback);
  END IF;
END;


function Run_SQL(p_title         varchar2,
                 p_sql_statement varchar2,
                 p_disp_lengths  lengths,
                 p_headers       headers,
                 p_max_rows      number) return number is
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    -- API currently not implemented for html
    null;
  ELSE
   return Run_SQL_text(p_title,p_sql_statement,p_disp_lengths,p_headers,p_max_rows);
  END IF;
END;


function Run_SQL(p_title         varchar2,
                 p_sql_statement varchar2,
                 p_disp_lengths  lengths,
                 p_headers       headers,
                 p_feedback      varchar2,
                 p_max_rows      number) return number is
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    -- API currently not implemented for html
    null;
  ELSE
   return Run_SQL_text(p_title,p_sql_statement,p_disp_lengths,p_headers,p_feedback,p_max_rows);
  END IF;
END;



procedure Run_SQL(p_title         varchar2,
                 p_sql_statement varchar2,
                 p_disp_lengths  lengths) IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    -- API currently not implemented for html
    null;
  ELSE
    Run_SQL_text(p_title,p_sql_statement,p_disp_lengths);
  END IF;

END;


procedure Run_SQL(p_title         varchar2,
                 p_sql_statement varchar2,
                 p_disp_lengths  lengths,
                 p_headers       headers) is
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    -- API currently not implemented for html
    null;
  ELSE
    Run_SQL_text(p_title,p_sql_statement,p_disp_lengths,p_headers);
  END IF;
END;



procedure Display_Table (p_table_name   varchar2,
          p_table_alias   varchar2,
          p_where_clause   varchar2,
          p_order_by_clause varchar2 default null,
          p_display_longs   varchar2 default 'Y') IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    Display_Table_html(p_table_name,p_table_alias ,p_where_clause,p_order_by_clause,p_display_longs);
  ELSE
   -- API currently not implemented for text
    null;
  END IF;
END;



procedure Show_Header(p_note varchar2, p_title varchar2) IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
  Show_Header_html(p_note, p_title);
 ELSE
  Show_Header_text(p_note, p_title);
 END IF;
END;




procedure Show_Footer(p_script_name varchar2, p_header varchar2) IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
  Show_Footer_html(p_script_name,p_header );
 ELSE
  Show_Footer_text;
 END IF;
END;


procedure Show_Footer IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    -- API currently not implemented for html
    null;
  ELSE
    Show_Footer_text;
  END IF;
END;


procedure Show_Link(p_note varchar2) IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
  Show_Link_html(p_note);
 ELSE
  Show_Link_text(p_note);
 END IF;
END;

procedure Show_Link(p_link varchar2, p_link_name varchar2 ) IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
  Show_Link_html(p_link, p_link_name);
 ELSE
  Show_Link_text(p_link, p_link_name);
 END IF;
END;


procedure Send_Email ( p_sender varchar2
                     , p_recipient varchar2
                     , p_subject varchar2
                     , p_message varchar2
                     , p_mailhost varchar2) IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    Send_Email_html( p_sender, p_recipient, p_subject , p_message , p_mailhost);
  ELSE
   -- API currently not implemented for text
    null;
  END IF;
END;


procedure Display_Profiles (p_application_id varchar2
                          , p_short_name     varchar2 default null) IS
BEGIN
IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
  Display_Profiles_html(p_application_id, p_short_name);
 ELSE
  Display_Profiles_text(p_application_id, p_short_name);
 END IF;
END;


procedure Set_Org (p_org_id number) IS
BEGIN
IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
  Set_Org_html(p_org_id);
 ELSE
  Set_Org_text(p_org_id);
 END IF;
END;

procedure Set_Client(p_user_name varchar2, p_resp_id number,
                     p_app_id number, p_sec_grp_id number) IS
BEGIN
IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
  Set_Client_html(p_user_name, p_resp_id,p_app_id, p_sec_grp_id);
 ELSE
  Set_Client_text(p_user_name, p_resp_id,p_app_id, p_sec_grp_id);
 END IF;
END;

procedure Set_Client(p_user_name varchar2, p_resp_id number) IS
BEGIN
IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
  Set_Client_html(p_user_name, p_resp_id);
 ELSE
  Set_Client_text(p_user_name, p_resp_id);
 END IF;
END;

procedure Set_Client(p_user_name varchar2, p_resp_id number,
                     p_app_id number ) IS
BEGIN
IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
  Set_Client_html(p_user_name, p_resp_id,p_app_id);
 ELSE
  Set_Client_text(p_user_name, p_resp_id,p_app_id);
 END IF;
END;


/*

-- OBSOLETED API SINCE THIS IS NOT COMPLIANT WITH GSCC STANDARD
-- FILE.SQL.6 WHICH DOES NOT PERMIT USING OF SCHEMA
-- NAMES WITHIN PLSQL CODE

procedure Get_DB_Patch_List (p_heading varchar2 default 'AD_BUGS'
           , p_app_short_name varchar2 default '%'
           , p_bug_number varchar2 default '%'
           , p_start_date date default to_date(olddate,'MM-DD-YYYY')
           , p_output_option varchar2 default 'TABLE') IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    Get_DB_Patch_List_html (p_heading, p_app_short_name, p_bug_number, p_start_date, p_output_option);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;
*/


/*

-- OBSOLETED API SINCE THIS IS NOT COMPLIANT WITH GSCC STANDARD
-- FILE.SQL.6 WHICH DOES NOT PERMIT USING OF SCHEMA
-- NAMES WITHIN PLSQL CODE

procedure Get_DB_Patch_List (
             p_heading varchar2 default 'AD_BUGS'
           , p_app_short_name varchar2 default '%'
           , p_bug_number varchar2 default '%'
           , p_start_date date default to_date(olddate,'MM-DD-YYYY')) is
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    -- API currently not implemented for html
    null;
  ELSE
   Get_DB_Patch_List_text(p_heading, p_app_short_name, p_bug_number, p_start_date);
  END IF;
END;

*/

/*

-- OBSOLETED API SINCE THIS IS NOT COMPLIANT WITH GSCC STANDARD
-- FILE.SQL.6 WHICH DOES NOT PERMIT USING OF SCHEMA
-- NAMES WITHIN PLSQL CODE


Procedure Show_Invalids (p_start_string   varchar2
                      ,  p_include_errors varchar2 default 'N'
                      ,  p_heading        varchar2 default null) IS
BEGIN
IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
  Show_Invalids_html(p_start_string,p_include_errors,p_heading);
 ELSE
  Show_Invalids_text(p_start_string,p_include_errors,p_heading);
 END IF;
END;
*/

Function CheckKeyFlexfield(p_flex_code     in varchar2
                       ,   p_flex_num  in number default null
                       ,   p_print_heading in boolean default true) return V2T IS
BEGIN
IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
 return CheckKeyFlexfield_html(p_flex_code,p_flex_num,p_print_heading);
 ELSE
  return CheckKeyFlexfield_text(p_flex_code,p_flex_num,p_print_heading);
 END IF;
END;


function CheckProfile(p_prof_name in varchar2
                    , p_user_id   in number
                    , p_resp_id   in number
                    , p_appl_id   in number
                    , p_default   in varchar2 default null
                    , p_indent    in integer default 0) return varchar2 IS
BEGIN
IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
  return CheckProfile_html(p_prof_name, p_user_id, p_resp_id, p_appl_id, p_default, p_indent);
 ELSE
  return CheckProfile_text(p_prof_name, p_user_id, p_resp_id, p_appl_id, p_default, p_indent);
 END IF;
END;



function Column_Exists(p_tab in varchar, p_col in varchar, p_owner in varchar) return varchar2 IS
BEGIN
IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
  return Column_Exists_html(p_tab, p_col, p_owner);
 ELSE
  return Column_Exists_text(p_tab, p_col, p_owner);
 END IF;
END;


function Display_SQL (p_sql_statement  varchar2
                    , table_alias      varchar2
                    , display_longs    varchar2 default 'Y'
                    , p_feedback       varchar2 default 'Y'
                    , p_max_rows       number   default null
                    , p_current_exec   number default 0) return number IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    return Display_SQL_html(p_sql_statement, table_alias, FALSE, display_longs, p_feedback, p_max_rows, p_current_exec);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;

function Display_SQL (p_sql_statement  varchar2
                    , table_alias      varchar2
                    , hideHeader Boolean
                    , display_longs    varchar2 default 'Y'
                    , p_feedback       varchar2 default 'Y'
                    , p_max_rows       number   default null
                    , p_current_exec   number default 0) return number IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    return Display_SQL_html(p_sql_statement, table_alias, hideHeader, display_longs, p_feedback, p_max_rows, p_current_exec);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;

Function Compare_Pkg_Version(
     package_name   in varchar2,
     object_type in varchar2,
     object_owner in varchar2,
     version_str in out NOCOPY varchar2,
     compare_version in varchar2)
return varchar2 is
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   -- API currently not implemented for html
   null;
  ELSE
   return Compare_Pkg_Version_text(package_name,object_type,object_owner,version_str,compare_version);
  END IF;
END;



function Display_Table (p_table_name   varchar2,
          p_table_alias   varchar2,
          p_where_clause   varchar2,
          p_order_by_clause varchar2 default null,
          p_display_longs   varchar2 default 'Y') return number IS
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    return Display_Table_html (p_table_name,p_table_alias, p_where_clause, p_order_by_clause, p_display_longs);
  ELSE
   -- API currently not implemented for text
   null;
  END IF;
END;



function Get_DB_Apps_Version return varchar2 IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
  return Get_DB_Apps_Version_html;
 ELSE
  return Get_DB_Apps_Version_text;
 END IF;
END;

function Get_Package_Version (p_type varchar2, p_schema varchar2, p_package varchar2) return varchar2 IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
  return Get_Package_Version_html(p_type, p_schema,p_package);
 ELSE
  return Get_Package_Version_text(p_type, p_schema,p_package);
 END IF;
END;

function Get_Package_Spec(p_package varchar2) return varchar2 IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
  return Get_Package_Spec_html(p_package);
 ELSE
  return Get_Package_Spec_text(p_package);
 END IF;
END;

function Get_Package_Body(p_package varchar2) return varchar2 IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
  return Get_Package_Body_html(p_package);
 ELSE
  return Get_Package_Body_text(p_package);
 END IF;
END;


function Get_Profile_Option (p_profile_option varchar2) return varchar2 IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
  return Get_Profile_Option_html(p_profile_option);
 ELSE
  return Get_Profile_Option_text(p_profile_option);
 END IF;
END;


Function Get_RDBMS_Header return varchar2 IS
BEGIN
 IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
  return Get_RDBMS_Header_html;
 ELSE
  return Get_RDBMS_Header_text;
 END IF;
END;



function Display_SQL (
           p_sql_statement varchar2
         , p_disp_lengths  lengths
         , p_headers       headers default null
         , p_feedback      varchar2 default 'Y'
         , p_max_rows      number default null)
return number is
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   -- API currently not implemented for html
   null;
  ELSE
    return Display_SQL_text(p_sql_statement,p_disp_lengths,p_headers,p_feedback, p_max_rows);
  END IF;
END;


procedure Display_SQL (
           p_sql_statement varchar2
         , p_disp_lengths  lengths) is
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   -- API currently not implemented for html
   null;
  ELSE
   Display_SQL_text(p_sql_statement,p_disp_lengths);
  END IF;
END;

procedure Display_SQL (
           p_sql_statement varchar2
         , p_disp_lengths  lengths
         , p_headers       headers) is
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
   -- API currently not implemented for html
   null;
  ELSE
   Display_SQL_text(p_sql_statement,p_disp_lengths,p_headers);
  END IF;
END;

procedure Display_SQL (
           p_sql_statement varchar2
         , p_disp_lengths  lengths
         , p_headers       headers
         , p_feedback      varchar2) is
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    -- API currently not implemented for html
    null;
  ELSE
    Display_SQL_text(p_sql_statement,p_disp_lengths,p_headers,p_feedback);
  END IF;
END;
-- BVS-STOP  <- Stop ignoring this section (restart scanning)


procedure Display_SQL(
           p_sql_statement varchar2
         , p_disp_lengths  lengths
         , p_headers       headers
         , p_feedback      varchar2
         , p_max_rows      number) is
BEGIN
  IF (JTF_DIAGNOSTIC_ADAPTUTIL.b_html_on) THEN
    -- API currently not implemented for html
    null;
  ELSE
    Display_SQL_text(p_sql_statement,p_disp_lengths,p_headers,p_feedback, p_max_rows);
  END IF;
END;


END JTF_DIAGNOSTIC_COREAPI;


/
