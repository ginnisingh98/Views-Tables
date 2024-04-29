--------------------------------------------------------
--  DDL for Package Body FA_RX_PUBLISH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RX_PUBLISH" as
/* $Header: FARXPBSB.pls 120.6.12010000.3 2009/10/09 04:34:06 anujain ship $ */

------------------------------------------------
-- CONSTANTS
------------------------------------------------
NEWLINE constant varchar2(10) := fnd_global.local_chr(10);
--      convert(chr(10), 'US7ASCII');

------------------------------------------------
-- Private types and private globals
------------------------------------------------
g_print_debug boolean := fa_cache_pkg.fa_print_debug;
g_release     number  := fa_cache_pkg.fazarel_release;  --global variable to get release name #8402286
--
-- Report Level
-- GLCHEN
type reportrec is record (
        request_id number,
        multiformat boolean,
        report_id number,
        attribute_set varchar2(30),
        output_format varchar2(30),
        display_report_title varchar2(1),
        display_set_of_books varchar2(1),
        display_functional_currency varchar2(1),
        display_submission_date varchar2(1),
        display_current_page varchar2(1),
        display_total_page varchar2(1),
        report_title varchar2(240),
        set_of_books_id number,
        set_of_books_name varchar2(200),
        functional_currency_prompt varchar2(100),
        functional_currency varchar2(100),
        real_submission_date date,
        submission_date varchar2(100),
        current_page_prompt varchar2(100),
        total_page_prompt varchar2(100),
        page_width number,
        page_height number,
        nls_end_of_report varchar2(200),
        nls_no_data_found varchar2(100),
        date_prompt VARCHAR2(100), /* bug #1401113, rravunny */
        conc_appname VARCHAR2(50),
        concurrent_program_name varchar2(30));
m_report reportrec;


--
-- Direct Select RX Arguments
--
type argumentrec is record (
  where_clause varchar2(100),
  value varchar2(240),
  datatype varchar2(10));
type argumenttab is table of argumentrec index by binary_integer;
m_arguments argumenttab;
m_argument_count number;

--
-- Format Level
--
type formatrec is record (
  report_id number,
  request_id number,
  attribute_set varchar2(30),
  conc_appname VARCHAR2(240),
  concurrent_program_name varchar2(30),
  interface_table varchar2(80),
  where_clause_api varchar2(80),
  display_parameters varchar2(3),
  display_page_break varchar2(3),
  group_display_type varchar2(20),
  complex_flag varchar2(1),
  group_id number,
  where_clause varchar2(400),
  default_date_format varchar2(20),
  default_date_time_format varchar2(30));
type formattab is table of formatrec index by binary_integer;
m_formats formattab;
m_format_count number;
s_current_format_idx number;


--
-- Parameters
--
type paramrec is record (
  name varchar2(100),
  value varchar2(240),
  display_flag VARCHAR2(3),
  format_type varchar2(30),
  flex_value_set_id NUMBER,
  flex_value_set_name VARCHAR2(60),
  param_idx number,
  column_name varchar2(30),
  operator varchar2(30));
type paramtab is table of paramrec index by binary_integer;
m_params paramtab;
m_params_with_actual_value paramtab;
m_param_count number;
m_param_display_count NUMBER;
s_current_param_idx number;

--
-- Break Levels
--
type breakrec is record (
  columncnt number,
  summarycnt number
);
type breaktab is table of breakrec index by binary_integer;
m_breaks breaktab;
m_break_count number;
s_current_break_idx number;


--
-- Columns
--
type columnrec is record (
  attribute_name varchar2(80),
  column_name varchar2(30),
  ordering varchar(30),
  display_length number,
  display_format varchar2(30),
  display_status varchar2(30),
  break varchar2(1),
  break_group_level number,
  currency_column varchar2(30),
  currency_column_id number,
  precision number,
  minimum_accountable_unit number,
  units number,
  format_mask varchar2(50),
  --bug 2848621 lgandhi
  -- Column values
  --
  vvalue varchar2(240),
  dvalue date,
  nvalue number
);
type columntab is table of columnrec index by binary_integer;
m_columns columntab;
m_column_count number;
m_displayed_column_count number;
s_current_column_idx number;

--
-- Summary Columns
--
type summaryrec is record (
  column_name varchar2(30),
  source_column_id number,
  function varchar2(15),
  summary_prompt varchar2(80),
  print_level number,
  reset_level number,
  compute_level number,
  value number
);
type summarytab is table of summaryrec index by binary_integer;
m_summaries summarytab;
m_summary_count number;
s_current_summary_idx number;



--
--
--
TYPE bindtab IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
m_binds bindtab;
m_bind_count NUMBER;
s_bind_idx NUMBER;

m_page_break_cnt number;
m_page_carry_forward_cnt number;
m_report_break_cnt number;

m_main_cursor integer;
m_row_count number;
m_max_rows number;


----------------------------------------------------------------
-- PRIVATE Procedures/Functions
----------------------------------------------------------------

function get_select_list return varchar2;
function get_from_clause return varchar2;
function get_where_clause return varchar2;
function get_order_by_clause return varchar2;

function is_multi_format_report(p_request_id in number) return boolean;
procedure Expand_Complex_Multiformat(p_formats in formattab, p_count in number);
procedure Validate_Report;
PROCEDURE bind_variables(c IN INTEGER);


---------------------------------------------------------
-- Procedure populate_report
--
-- Populates the m_report structure
---------------------------------------------------------
procedure populate_report(
        p_request_id in number,
        p_report_id in number,
        p_attribute_set in varchar2,
        p_output_format in varchar2)
is
  appname varchar2(50);
begin
   IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'populate_report()+');
   END IF;

   m_report.multiformat :=  is_multi_format_report(p_request_id);
   if m_report.multiformat then
      m_report.request_id := p_request_id;
      m_report.output_format := p_output_format;

      select sub_report_id, sub_attribute_set
        into m_report.report_id, m_report.attribute_set
        from fa_rx_multiformat_reps
        where request_id = p_request_id
        and   seq_number = (
                            select min(seq_number) from fa_rx_multiformat_reps
                            where request_id = p_request_id)
        and rownum=1;

    else
      m_report.request_id := p_request_id;
      m_report.output_format := p_output_format;

      m_report.report_id := p_report_id;
      m_report.attribute_set := p_attribute_set;
   end if;

   IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' ||
                        'Request ID = '||p_request_id||newline||
                        'Report ID = '||p_report_id||newline||
                        'Attribute Set = '||p_attribute_set||newline||
                        'Output Format = '||p_output_format);
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'Getting attribute_set flags...');
   END IF;
   select
     nvl(print_title, 'Y')              print_title,
     nvl(print_sob_flag, 'Y')           print_sob_flag,
     nvl(print_func_curr_flag, 'Y')     print_func_curr_flag,
     nvl(print_submission_date,'Y')     print_submission_date,
     nvl(print_current_page, 'Y')       print_current_pages,
     nvl(print_total_pages, 'N')        print_total_pages,
     report_title                       report_title,
     nvl(page_width, 0)                 page_width,
     nvl(page_height, 0)                page_height
     into
     m_report.display_report_title,
     m_report.display_set_of_books,
     m_report.display_functional_currency,
     m_report.display_submission_date,
     m_report.display_current_page,
     m_report.display_total_page,
     m_report.report_title,
     m_report.page_width, m_report.page_height
     from
     fa_rx_attrsets
     where
     report_id = m_report.report_id and
     attribute_set = m_report.attribute_set;

   IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'Get report title...');
   END IF;
   if m_report.report_title is null then
      select distinct substrb (user_program_name, 1, 100)
        into m_report.report_title
        from fa_rx_reports_v
        where report_id = m_report.report_id;
   end if;

   --
   -- SOB and functional currency cannot be
   -- initialized until the format level
   --

   IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'Get NLS flags...');
   END IF;
   select meaning into m_report.functional_currency_prompt
     from fnd_lookups where lookup_type='FARX_NLS_PARAMS' and lookup_code = 'CURRENCY_PROMPT';

--* bug #1401113, rravunny
   select meaning into m_report.date_prompt
     from fnd_lookups where lookup_type='FARX_NLS_PARAMS' and lookup_code = 'DATE_PROMPT';

   select meaning into m_report.current_page_prompt
     from fnd_lookups where lookup_type='FARX_NLS_PARAMS' and lookup_code = 'CURRENT_PAGE';

   select meaning into m_report.total_page_prompt
     from fnd_lookups where lookup_type='FARX_NLS_PARAMS' and lookup_code = 'TOTAL_PAGE';

   select meaning into m_report.nls_end_of_report
     from fnd_lookups where lookup_type='FARX_NLS_PARAMS' and lookup_code = 'END_OF_REPORT';

   select meaning into m_report.nls_no_data_found
     from fnd_lookups where lookup_type='FARX_NLS_PARAMS' and lookup_code = 'NO_DATA_FOUND';

   m_report.real_submission_date := sysdate;

   get_report_name(
                   m_report.report_id,
                   m_report.conc_appname,
                   m_report.concurrent_program_name);

   if m_report.output_format in ('CSV', 'HTML', 'TAB') then
      m_report.page_width := 0;
      m_report.page_height := 0;
   end if;

   IF m_report.page_height = 0 THEN
      m_report.display_current_page := 'N';
      m_report.display_total_page := 'N';
   END IF;
end populate_report;


---------------------------------------------------------
-- Procedure populate_sob
--
-- Populates the set of books info in the m_report structure
---------------------------------------------------------
procedure populate_sob is
  c number;
  rows number;
  where_clause varchar2(1000);
  sqlstmt varchar2(1000);
begin
  --
  -- This routine looks for the column SET_OF_BOOKS_ID
  -- from the interface table. It assumes that
  -- that there will only be one distinct value
  -- in this column
  --
   m_report.set_of_books_id := null;
   --
   -- Per instructions from bug 1082862, FIRST_ROWS hint has been taken out.
    sqlstmt := 'SELECT ORGANIZATION_NAME, FUNCTIONAL_CURRENCY_CODE '||NEWLINE||
                Get_From_Clause||NEWLINE||get_where_clause;
    c := dbms_sql.open_cursor;
    IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || sqlstmt);
    END IF;
    fa_rx_util_pkg.debug('Parsing statement : '||To_char(Sysdate, 'YY/MM/DD HH24:MI:SS'));
    dbms_sql.parse(c, sqlstmt, dbms_sql.native);
    IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'Binding statement');
    END IF;
    bind_variables(c);
    fa_rx_util_pkg.debug('Defining columns : '||To_char(Sysdate, 'YY/MM/DD HH24:MI:SS'));
    dbms_sql.define_column(c, 1, m_report.set_of_books_name, 100);
    dbms_sql.define_column(c, 2, m_report.functional_currency, 100);
    fa_rx_util_pkg.debug('Executing : '||To_char(Sysdate, 'YY/MM/DD HH24:MI:SS'));
    rows := dbms_sql.execute(c);
    fa_rx_util_pkg.debug('Fetching : '||To_char(Sysdate, 'YY/MM/DD HH24:MI:SS'));
    rows := dbms_sql.fetch_rows(c);
    fa_rx_util_pkg.debug('Got '||To_char(rows)||' row(s) : '||To_char(Sysdate, 'YY/MM/DD HH24:MI:SS'));
    if rows = 0 then
        --
        -- The column did not exist in the database
        -- Set SOB info to null;
        --
        fnd_message.set_name('OFA', 'FA_RX_NO_SOB_COLUMN');
        IF (g_print_debug) THEN
                fa_rx_util_pkg.debug('is_multi_format_report: ' || fnd_message.get);
        END IF;
        m_report.display_set_of_books := 'N';
        m_report.display_functional_currency := 'N';
        m_report.set_of_books_name := null;
        m_report.functional_currency := null;

     else

       dbms_sql.column_value(c, 1, m_report.set_of_books_name);
       dbms_sql.column_value(c, 2, m_report.functional_currency);

    end if;
    dbms_sql.close_cursor(c);

exception
when others then
    -- no set of books
    fnd_message.set_name('OFA', 'FA_RX_NO_SOB_COLUMN');
    IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || fnd_message.get);
    END IF;

    m_report.display_set_of_books := 'N';
    m_report.display_functional_currency := 'N';
    m_report.set_of_books_name := null;
    m_report.functional_currency := null;

    if dbms_sql.is_open(c) then
        dbms_sql.close_cursor(c);
    end if;
    return;
end populate_sob;


---------------------------------------------------------
-- Procedure populate_arguments
--
-- Populates the m_arguments structure. For
-- Direct Select RX reports only.
---------------------------------------------------------
procedure populate_arguments(
        p_argument1 in varchar2 ,
        p_argument2 in varchar2 ,
        p_argument3 in varchar2 ,
        p_argument4 in varchar2 ,
        p_argument5 in varchar2 ,
        p_argument6 in varchar2 ,
        p_argument7 in varchar2 ,
        p_argument8 in varchar2 ,
        p_argument9 in varchar2 ,
        p_argument10 in varchar2 ,
        p_argument11 in varchar2 ,
        p_argument12 in varchar2 ,
        p_argument13 in varchar2 ,
        p_argument14 in varchar2 ,
        p_argument15 in varchar2 ,
        p_argument16 in varchar2 ,
        p_argument17 in varchar2 ,
        p_argument18 in varchar2 ,
        p_argument19 in varchar2 ,
        p_argument20 in varchar2 ,
        p_argument21 in varchar2 ,
        p_argument22 in varchar2 ,
        p_argument23 in varchar2 ,
        p_argument24 in varchar2 ,
        p_argument25 in varchar2 ,
        p_argument26 in varchar2 ,
        p_argument27 in varchar2 ,
        p_argument28 in varchar2 ,
        p_argument29 in varchar2 ,
        p_argument30 in varchar2 ,
        p_argument31 in varchar2 ,
        p_argument32 in varchar2 ,
        p_argument33 in varchar2 ,
        p_argument34 in varchar2 ,
        p_argument35 in varchar2 ,
        p_argument36 in varchar2 ,
        p_argument37 in varchar2 ,
        p_argument38 in varchar2 ,
        p_argument39 in varchar2 ,
        p_argument40 in varchar2 ,
        p_argument41 in varchar2 ,
        p_argument42 in varchar2 ,
        p_argument43 in varchar2 ,
        p_argument44 in varchar2 ,
        p_argument45 in varchar2 ,
        p_argument46 in varchar2 ,
        p_argument47 in varchar2 ,
        p_argument48 in varchar2 ,
        p_argument49 in varchar2 ,
        p_argument50 in varchar2 ,
        p_argument51 in varchar2 ,
        p_argument52 in varchar2 ,
        p_argument53 in varchar2 ,
        p_argument54 in varchar2 ,
        p_argument55 in varchar2 ,
        p_argument56 in varchar2 ,
        p_argument57 in varchar2 ,
        p_argument58 in varchar2 ,
        p_argument59 in varchar2 ,
        p_argument60 in varchar2 ,
        p_argument61 in varchar2 ,
        p_argument62 in varchar2 ,
        p_argument63 in varchar2 ,
        p_argument64 in varchar2 ,
        p_argument65 in varchar2 ,
        p_argument66 in varchar2 ,
        p_argument67 in varchar2 ,
        p_argument68 in varchar2 ,
        p_argument69 in varchar2 ,
        p_argument70 in varchar2 ,
        p_argument71 in varchar2 ,
        p_argument72 in varchar2 ,
        p_argument73 in varchar2 ,
        p_argument74 in varchar2 ,
        p_argument75 in varchar2 ,
        p_argument76 in varchar2 ,
        p_argument77 in varchar2 ,
        p_argument78 in varchar2 ,
        p_argument79 in varchar2 ,
        p_argument80 in varchar2 ,
        p_argument81 in varchar2 ,
        p_argument82 in varchar2 ,
        p_argument83 in varchar2 ,
        p_argument84 in varchar2 ,
        p_argument85 in varchar2 ,
        p_argument86 in varchar2 ,
        p_argument87 in varchar2 ,
        p_argument88 in varchar2 ,
        p_argument89 in varchar2 ,
        p_argument90 in varchar2 ,
        p_argument91 in varchar2 ,
        p_argument92 in varchar2 ,
        p_argument93 in varchar2 ,
        p_argument94 in varchar2 ,
        p_argument95 in varchar2 ,
        p_argument96 in varchar2 ,
        p_argument97 in varchar2 ,
        p_argument98 in varchar2 ,
        p_argument99 in varchar2 ,
        p_argument100 in varchar2)
is
  cursor cargs is
  select  f.end_user_column_name ,
        decode(v.format_type,
                'C', 'VARCHAR2',
                'D', 'DATE',
                'I', 'DATE',
                'N', 'NUMBER',
                'T', 'DATE',
                'X', 'DATE',
                'Y', 'DATE',
                'VARCHAR2')
    from
    fnd_application a,
    fnd_concurrent_programs p,
    fnd_descr_flex_column_usages f,
    fnd_flex_value_sets v
    WHERE
    a.application_short_name = m_report.conc_appname AND
    a.application_id = p.application_id AND
    p.concurrent_program_name = m_report.concurrent_program_name AND
    f.descriptive_flexfield_name = '$SRS$.'||p.concurrent_program_name AND
    f.enabled_flag = 'Y' AND
    f.flex_value_set_id = v.flex_value_set_id
    ORDER BY f.column_seq_num;

  l_column_name fnd_descr_flex_column_usages.end_user_column_name%type;
  l_data_type varchar2(10);
begin
   IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'FA_RX_PUBLISH.populate_arguments()+');
   END IF;

  m_arguments(1).value := p_argument1;
  m_arguments(2).value := p_argument2;
  m_arguments(3).value := p_argument3;
  m_arguments(4).value := p_argument4;
  m_arguments(5).value := p_argument5;
  m_arguments(6).value := p_argument6;
  m_arguments(7).value := p_argument7;
  m_arguments(8).value := p_argument8;
  m_arguments(9).value := p_argument9;
  m_arguments(10).value := p_argument10;
  m_arguments(11).value := p_argument11;
  m_arguments(12).value := p_argument12;
  m_arguments(13).value := p_argument13;
  m_arguments(14).value := p_argument14;
  m_arguments(15).value := p_argument15;
  m_arguments(16).value := p_argument16;
  m_arguments(17).value := p_argument17;
  m_arguments(18).value := p_argument18;
  m_arguments(19).value := p_argument19;
  m_arguments(20).value := p_argument20;
  m_arguments(21).value := p_argument21;
  m_arguments(22).value := p_argument22;
  m_arguments(23).value := p_argument23;
  m_arguments(24).value := p_argument24;
  m_arguments(25).value := p_argument25;
  m_arguments(26).value := p_argument26;
  m_arguments(27).value := p_argument27;
  m_arguments(28).value := p_argument28;
  m_arguments(29).value := p_argument29;
  m_arguments(30).value := p_argument30;
  m_arguments(31).value := p_argument31;
  m_arguments(32).value := p_argument32;
  m_arguments(33).value := p_argument33;
  m_arguments(34).value := p_argument34;
  m_arguments(35).value := p_argument35;
  m_arguments(36).value := p_argument36;
  m_arguments(37).value := p_argument37;
  m_arguments(38).value := p_argument38;
  m_arguments(39).value := p_argument39;
  m_arguments(40).value := p_argument40;
  m_arguments(41).value := p_argument41;
  m_arguments(42).value := p_argument42;
  m_arguments(43).value := p_argument43;
  m_arguments(44).value := p_argument44;
  m_arguments(45).value := p_argument45;
  m_arguments(46).value := p_argument46;
  m_arguments(47).value := p_argument47;
  m_arguments(48).value := p_argument48;
  m_arguments(49).value := p_argument49;
  m_arguments(50).value := p_argument50;
  m_arguments(51).value := p_argument51;
  m_arguments(52).value := p_argument52;
  m_arguments(53).value := p_argument53;
  m_arguments(54).value := p_argument54;
  m_arguments(55).value := p_argument55;
  m_arguments(56).value := p_argument56;
  m_arguments(57).value := p_argument57;
  m_arguments(58).value := p_argument58;
  m_arguments(59).value := p_argument59;
  m_arguments(60).value := p_argument60;
  m_arguments(61).value := p_argument61;
  m_arguments(62).value := p_argument62;
  m_arguments(63).value := p_argument63;
  m_arguments(64).value := p_argument64;
  m_arguments(65).value := p_argument65;
  m_arguments(66).value := p_argument66;
  m_arguments(67).value := p_argument67;
  m_arguments(68).value := p_argument68;
  m_arguments(69).value := p_argument69;
  m_arguments(70).value := p_argument70;
  m_arguments(71).value := p_argument71;
  m_arguments(72).value := p_argument72;
  m_arguments(73).value := p_argument73;
  m_arguments(74).value := p_argument74;
  m_arguments(75).value := p_argument75;
  m_arguments(76).value := p_argument76;
  m_arguments(77).value := p_argument77;
  m_arguments(78).value := p_argument78;
  m_arguments(79).value := p_argument79;
  m_arguments(80).value := p_argument80;
  m_arguments(81).value := p_argument81;
  m_arguments(82).value := p_argument82;
  m_arguments(83).value := p_argument83;
  m_arguments(84).value := p_argument84;
  m_arguments(85).value := p_argument85;
  m_arguments(86).value := p_argument86;
  m_arguments(87).value := p_argument87;
  m_arguments(88).value := p_argument88;
  m_arguments(89).value := p_argument89;
  m_arguments(90).value := p_argument90;
  m_arguments(91).value := p_argument91;
  m_arguments(92).value := p_argument92;
  m_arguments(93).value := p_argument93;
  m_arguments(94).value := p_argument94;
  m_arguments(95).value := p_argument95;
  m_arguments(96).value := p_argument96;
  m_arguments(97).value := p_argument97;
  m_arguments(98).value := p_argument98;
  m_arguments(99).value := p_argument99;
  m_arguments(100).value := p_argument100;

  open cargs;
  fetch cargs into l_column_name, l_data_type; -- DIRECT
  fetch cargs into l_column_name, l_data_type; -- REPORT_ID
  fetch cargs into l_column_name, l_data_type; -- ATTRIBUTE_SET
  fetch cargs into l_column_name, l_data_type; -- FORMAT TYPE
  m_argument_count := 0;
  loop
        fetch cargs into l_column_name, l_data_type;
        exit when cargs%notfound;

        m_argument_count := m_argument_count + 1;

        if l_column_name like '[%]' THEN -- used for WHERE clause
          m_arguments(m_argument_count).where_clause :=
                        substr(l_column_name, 2, length(l_column_name)-2); -- Strip [ and ]
          m_arguments(m_argument_count).datatype := l_data_type;
        else
          m_arguments(m_argument_count).where_clause := null;
          m_arguments(m_argument_count).datatype := l_data_type;
        end if;
  end loop;
  close cargs;

   IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'FA_RX_PUBLISH.populate_arguments()-');
   END IF;
end populate_arguments;



procedure check_group_display_type(fidx in number)
is
  cursor c is select Least(display_length, 255) display_length
  from fa_rx_rep_columns
  where report_id = m_formats(fidx).report_id
  and   attribute_set = m_formats(fidx).attribute_set
  and   break = 'Y'
  and   break_group_level >=
        decode(m_formats(fidx).display_page_break, 'Y', 2, 1)
  and   display_status = 'YES'
  order by break_group_level, attribute_counter;
  crec c%rowtype;

  current_pos number;
  max_len number;

begin
  if m_report.output_format in ('CSV', 'HTML', 'TAB') then
        --
        -- CSV and HTML and TAB always use GROUP LEFT
        m_formats(fidx).group_display_type := 'GROUP LEFT';
        return;
  end if;

  if m_formats(fidx).group_display_type = 'GROUP ABOVE' then
        -- Nothing to check
        return;
  end if;

  if m_report.page_width = 0 or m_report.page_width is null then
        -- Nothing to check
        return;
  end if;
  current_pos := -2; -- Adds 2 to take care of spaces except first item in line
  for crec in c loop
    if current_pos + crec.display_length + 2 > m_report.page_width then
        current_pos := -2;
    end if;

    current_pos := current_pos + crec.display_length + 2;
  end loop;

  select max(Least(display_length, 255)) into max_len
  from fa_rx_rep_columns
  where report_id = m_formats(fidx).report_id
  and   attribute_set = m_formats(fidx).attribute_set
  and   nvl(break, 'N') = 'N'
  and   display_status = 'YES';
  if current_pos + max_len + 2 > m_report.page_width then
    m_formats(fidx).group_display_type := 'GROUP ABOVE';
  end if;
end check_group_display_type;


---------------------------------------------------------
-- Procedure populate_formats
--
-- Populates the m_formats structure
---------------------------------------------------------
procedure populate_formats
is
  cursor cformat is
        select
                m.sub_report_id,
                m.sub_request_id,
                m.sub_attribute_set,
                m.group_id,
                m.complex_flag,
                m.seq_number
        from fa_rx_multiformat_reps m
        where m.request_id = m_report.request_id
        order by m.group_id, m.seq_number;
  rformat cformat%rowtype;

  c integer;
  rows number;
  sqlstmt varchar2(2000);

  appname varchar2(240);
  l_formats formattab;
  idx number;
begin
  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'populate_formats()+');
  END IF;

  m_format_count := 0;

  --
  -- First check to see if this is a multi-format report
  idx := 1;
  open cformat;
  loop
        fetch cformat into rformat;
        exit when cformat%notfound;

        l_formats(idx).report_id := rformat.sub_report_id;
        l_formats(idx).request_id := rformat.sub_request_id;
        l_formats(idx).attribute_set := rformat.sub_attribute_set;
        l_formats(idx).group_id := rformat.group_id;
        l_formats(idx).complex_flag := rformat.complex_flag;
        l_formats(idx).where_clause := null;

        select
                nvl(print_page_break_cols, 'N') print_page_break_cols,
                nvl(print_parameters, 'Y')      print_parameters,
                nvl(group_display_type, 'GROUP LEFT') group_display_type,
                default_date_format, default_date_time_format
        into
                l_formats(idx).display_page_break,
                l_formats(idx).display_parameters,
                l_formats(idx).group_display_type,
                l_formats(idx).default_date_format,
                l_formats(idx).default_date_time_format
        from fa_rx_attrsets
        where report_id = rformat.sub_report_id and
                attribute_set = rformat.sub_attribute_set;

        select interface_table, where_clause_api
        into l_formats(idx).interface_table,
             l_formats(idx).where_clause_api
        from fa_rx_reports
        where report_id = rformat.sub_report_id;

        get_report_name(l_formats(idx).report_id,
                        l_formats(idx).conc_appname,
                        l_formats(idx).concurrent_program_name);


        if (idx > 1) then
          if(l_formats(idx-1).complex_flag = 'Y' and
            (l_formats(idx).complex_flag <> 'Y' or
             l_formats(idx).group_id <> l_formats(idx-1).group_id)) then
            Expand_Complex_Multiformat(l_formats, idx-1);
            l_formats(1) := l_formats(idx);
            idx := 1;
          end if;
        end if;

        if l_formats(idx).complex_flag = 'Y' then
          IF (g_print_debug) THEN
                fa_rx_util_pkg.debug('is_multi_format_report: ' || 'Complex format found - '||to_char(l_formats(idx).group_id));
          END IF;

          l_formats(idx).display_page_break := 'Y';
          idx := idx + 1;
        else
          IF (g_print_debug) THEN
                fa_rx_util_pkg.debug('is_multi_format_report: ' || 'Regular format found - '||l_formats(idx).concurrent_program_name);
          END IF;
          m_format_count := m_format_count + 1;
          m_formats(m_format_count) := l_formats(1);
          idx := 1;
        end if;

        IF m_report.page_height = 0 THEN
           l_formats(idx).display_page_break := 'N';
        END IF;
  end loop;

  idx := idx - 1;
  if (idx > 1) then
    if (l_formats(idx).complex_flag = 'Y') then
          Expand_Complex_Multiformat(l_formats, idx);
    end if;
  end if;

  close cformat;

  if m_format_count = 0 then
  -- This was not a multi-format report.
  -- Copy over some of the information from m_report

        m_format_count := 1;
        m_formats(1).report_id := m_report.report_id;
        m_formats(1).request_id := m_report.request_id;
        m_formats(1).attribute_set := m_report.attribute_set;
        m_formats(1).group_id := 1;

        select
                nvl(print_page_break_cols, 'N') print_page_break_cols,
                nvl(print_parameters, 'N')      print_parameters,
                nvl(group_display_type, 'GROUP LEFT') group_display_type,
                default_date_format, default_date_time_format
        into m_formats(1).display_page_break, m_formats(1).display_parameters,
                m_formats(1).group_display_type,
                m_formats(1).default_date_format,
                m_formats(1).default_date_time_format
        from fa_rx_attrsets
        where report_id = m_report.report_id and
          attribute_set = m_report.attribute_set;

        select interface_table, where_clause_api
        into m_formats(m_format_count).interface_table,
             m_formats(m_format_count).where_clause_api
        from fa_rx_reports
        where report_id = m_report.report_id;


        get_report_name(
                m_formats(m_format_count).report_id,
                m_formats(m_format_count).conc_appname,
                m_formats(m_format_count).concurrent_program_name);

        check_group_display_type(m_format_count);

        IF m_report.page_height = 0 THEN
           l_formats(1).display_page_break := 'N';
        END IF;
  end if;

  s_current_format_idx := 1;

  --
  -- Initialize the first one
  if (m_formats(s_current_format_idx).default_date_format is not null) then
        fnd_date.initialize(m_formats(s_current_format_idx).default_date_format,
                        m_formats(s_current_format_idx).default_date_time_format);
  end if;
  m_report.submission_date := fnd_date.date_to_displaydt(m_report.real_submission_date);
end populate_formats;

---------------------------------------------------------
-- Procedure populate_parameters
--
-- Populates the m_parameters structure
---------------------------------------------------------
procedure populate_parameters(p_request_type IN VARCHAR2, p_request_id IN NUMBER)
  is
     cursor cparam(l_request_id IN NUMBER) IS
        select
          d.form_left_prompt,
          v.format_type,
          d.display_flag,
          v.flex_value_set_id,
          v.flex_value_set_name
          from
          fnd_descr_flex_col_usage_vl d,
          fnd_flex_value_sets v,
          fnd_concurrent_programs c,
          fnd_concurrent_requests r
          WHERE
          r.request_id = l_request_id
          AND c.application_id = r.program_application_id
          AND c.concurrent_program_id = r.concurrent_program_id
          and   d.application_id = c.application_id
          and   d.descriptive_flexfield_name = '$SRS$.'||c.concurrent_program_name
          and   d.enabled_flag = 'Y'
          --  and       d.flex_value_set_application_id = v.application_id
          and   d.flex_value_set_id = v.flex_value_set_id
          order by d.column_seq_num;

     rparam cparam%rowtype;
     flex_value_meaning VARCHAR2(240);
     sqlstmt varchar2(2000);
     sep varchar2(10);

     c integer;
     rows number;
     len number;
     dvalue date;
     idx number;

     max_param_idx number := 0;
begin
   IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'Getting parameters for request - '||To_char(p_request_id));
   END IF;

   fa_rx_shared_pkg.clear_flex_val_cache;

   m_param_count := 0;
   m_param_display_count := 0;

   --
   -- Check the descriptive flexfield definition for the concurrent program parameters
   -- (Descriptive flexfield name = $SRS$.<CONCURRENT_PROGRAM_NAME>
   open cparam(p_request_id);
   idx := 0;
   loop
      fetch cparam into rparam;
      exit when cparam%notfound;
      idx := idx + 1;

      m_param_count := m_param_count + 1;
      m_params(m_param_count).name := rparam.form_left_prompt;
      m_params(m_param_count).format_type := rparam.format_type;
      m_params(m_param_count).flex_value_set_id := rparam.flex_value_set_id;
      m_params(m_param_count).flex_value_set_name := rparam.flex_value_set_name;
      m_params(m_param_count).param_idx := idx;
      m_params(m_param_count).display_flag := rparam.display_flag;

      IF Upper(p_request_type) = 'DIRECT' AND idx <= 4 THEN
         m_params(m_param_count).display_flag := 'N';
       ELSIF Upper(p_request_type) = 'SUBMIT' AND idx <= 6 THEN
         m_params(m_param_count).display_flag := 'N';
       ELSIF rparam.display_flag = 'Y' then
         m_param_display_count := m_param_display_count + 1;
      end if;
   end loop;
   close cparam;
   max_param_idx := idx;

   IF idx = 0 then
      IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'There were no parameters for this report');
      END IF;
      return;
    ELSIF m_param_count = 0 then
      IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'There were no displayed parameters for this report');
      END IF;
      return;
   end if;
   IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'Found '||to_char(m_param_count)||' parameter(s).');
   END IF;


   --
   -- Build the SELECT statement which will retrieve the parameter values
   -- from FND_CONCURRENT_REQUESTS (and FND_CONC_REQUEST_ARGUMENTS)
   sqlstmt := 'SELECT ';
   for idx in 1..m_param_count loop
      if m_params(idx).param_idx <= 25 then
         sqlstmt := sqlstmt||sep||'r.argument'||to_char(m_params(idx).param_idx);
       else
         sqlstmt := sqlstmt||sep||'rs.argument'||to_char(m_params(idx).param_idx);
      end if;
      sep := NEWLINE||',';
   end loop;
   sqlstmt := sqlstmt||NEWLINE||'from fnd_concurrent_requests r';
   if max_param_idx > 25 then
      sqlstmt := sqlstmt||', fnd_conc_request_arguments rs';
   end if;

   sqlstmt := sqlstmt ||NEWLINE||'where r.request_id = to_char(:b_request_id)'; /* bug 2276534, rravunny */
   if m_param_count > 25 then
      sqlstmt := sqlstmt||NEWLINE||'and r.request_id = rs.request_id';
   end if;


   IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'SQL Statement...'||NEWLINE||sqlstmt);
   END IF;

   --
   -- Get the parameter values
   c := dbms_sql.open_cursor;
   dbms_sql.parse(c, sqlstmt, dbms_sql.native);
   dbms_sql.bind_variable(c, ':b_request_id', p_request_id); /* bug 2276534, rravunny */
   for idx in 1..m_param_count loop
      dbms_sql.define_column(c, idx, m_params(idx).value, 240);
   end loop;
   rows := dbms_sql.execute(c);
   rows := dbms_sql.fetch_rows(c);
   if rows = 0 then raise no_data_found;
   end if;
   for idx in 1..m_param_count loop
      dbms_sql.column_value(c, idx, m_params(idx).value);
   end loop;
   dbms_sql.close_cursor(c);

    m_params_with_actual_value := m_params;

   --
   -- Try to reformat date values
   for idx in 1..m_param_count loop
      m_params(idx).value := substrb(fa_rx_shared_pkg.get_flex_val_meaning(m_params_with_actual_value(idx).flex_value_set_id,
                                                                   m_params_with_actual_value(idx).flex_value_set_name,
                                                                   m_params_with_actual_value(idx).value), 1, 240);

      if m_params(idx).format_type in ('D', 'I', 'T', 'X', 'Y', 'Z', 't') then
                begin
                   dvalue := fnd_date.canonical_to_date(m_params(idx).value);
                exception
                   when others then
                      Null;
--*                   len := length(m_params(idx).value);
--*                   if len = 8 then
--*                      dvalue := to_date(m_params(idx).value, 'YY/MM/DD');
--*                    elsif len = 9 then
--*                       dvalue := to_date(m_params(idx).value, 'DD-MON-YY');
--*                    elsif len = 10 then
--*                      dvalue := to_date(m_params(idx).value, 'YYYY/MM/DD');
--*                    elsif len = 11 then
--*                       dvalue := to_date(m_params(idx).value, 'DD-MON-YYYY');
--*                    elsif len = 17 then
--*                      dvalue := to_date(m_params(idx).value, 'YY/MM/DD HH24:MI:SS');
--*                    elsif len = 18 then
--*                       dvalue := to_date(m_params(idx).value, 'DD-MON-YY HH24:MI:SS');
--*                    elsif len = 19 then
--*                      dvalue := to_date(m_params(idx).value, 'YYYY/MM/DD HH24:MI:SS');
--*                    elsif len = 20 then
--*                       dvalue := to_date(m_params(idx).value, 'DD-MON-YYYY HH24:MI:SS');
--*                   end if;
                end;

                if m_params(idx).format_type in ('D', 'X') then
                   m_params(idx).value := fnd_date.date_to_displaydate(dvalue);
                 elsif m_params(idx).format_type in ('T', 'Y') then
                   m_params(idx).value := fnd_date.date_to_displaydt(dvalue);
                 elsif m_params(idx).format_type in ('I', 'Z', 't') then
                   m_params(idx).value := to_char(dvalue, 'HH24:MI:SS');
                end if;
      end if;

      IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || '--> '||to_char(idx)||' = '||m_params(idx).value);
      END IF;
  end loop;
end populate_parameters;


---------------------------------------------------------
-- Function find_column
--
-- Returns the index of the column name from m_columns
---------------------------------------------------------
function find_column(p_column_name in varchar2) return number
is
  idx number;
begin
  for idx in 1..m_column_count loop
        if m_columns(idx).column_name = p_column_name then
                return idx;
        end if;
  end loop;

  return null;
end find_column;

---------------------------------------------------------
-- Procedure populate_columns
--
-- Populates the m_columns structure
---------------------------------------------------------
procedure populate_columns
is
  cursor ccol is
  select
        attribute_name,
        column_name,
        ordering,
        display_length,
        display_format,
        nvl(display_status, 'NO') display_status,
        nvl(break, 'N') break,
        currency_column,
        precision,
        minimum_accountable_unit,
        units,
        format_mask,
        break_group_level
  from
        fa_rx_rep_columns
  where
        report_id = m_formats(s_current_format_idx).report_id
  and   display_status = 'YES'
  and   attribute_set = m_formats(s_current_format_idx).attribute_set
  order by decode(break, 'Y', 1, 2), break_group_level, attribute_counter;
  rcol ccol%rowtype;

  l_displayed_columns number;
  l_current_break number;
  l_last_break number;
begin
  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'FA_RX_PUBLISH.populate_columns()+'||NEWLINE||
                'Getting columns for...'||NEWLINE||
                'Format #  = '||to_char(s_current_format_idx)||NEWLINE||
                'Report ID = '||to_char(m_formats(s_current_format_idx).report_id)||NEWLINE||
                'Attribute Set = '||m_formats(s_current_format_idx).attribute_set);
  END IF;


  m_column_count := 0;
  open ccol;
  loop
        fetch ccol into rcol;
        exit when ccol%notfound;

        if (rcol.display_length = 0) then
                fnd_message.set_name('OFA', 'FA_RX_LENGTH_IS_ZERO');
                fnd_message.set_token('COLUMN_NAME', rcol.column_name);
                fa_rx_util_pkg.log(fnd_message.get);
                GOTO end_loop;
        end if;

        IF (rcol.display_length > 255) THEN
           fnd_message.set_name('OFA', 'FA_RX_LENGTH_RESET');
           fnd_message.set_token('COLUMN_NAME', rcol.column_name);
           fa_rx_util_pkg.Log(fnd_message.get);
           rcol.display_length := 255;
        END IF;

        m_column_count := m_column_count + 1;
        m_columns(m_column_count).attribute_name := rcol.attribute_name;
        m_columns(m_column_count).column_name := rcol.column_name;
        m_columns(m_column_count).ordering := rcol.ordering;
        m_columns(m_column_count).display_length := rcol.display_length;
        m_columns(m_column_count).display_status := rcol.display_status;
        m_columns(m_column_count).display_format := rcol.display_format;
        m_columns(m_column_count).break := rcol.break;
        m_columns(m_column_count).currency_column := rcol.currency_column;
        m_columns(m_column_count).precision := rcol.precision;
        m_columns(m_column_count).minimum_accountable_unit := rcol.minimum_accountable_unit;
        m_columns(m_column_count).units := rcol.units;
        m_columns(m_column_count).format_mask := rcol.format_mask;
        m_columns(m_column_count).break_group_level := rcol.break_group_level;

        IF m_report.output_format = 'CSV' THEN
           m_columns(m_column_count).currency_column := NULL;
           IF m_columns(m_column_count).display_format = 'NUMBER' THEN
              m_columns(m_column_count).format_mask := REPLACE(m_columns(m_column_count).format_mask, ',', NULL);
            ELSIF m_columns(m_column_count).display_format = 'DATE' THEN
              m_columns(m_column_count).format_mask := 'YYYY/MM/DD';
           END IF;
        END IF;

        <<end_loop>>
          NULL;
  end loop;

  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'Retrieved '||to_char(m_column_count)||' column(s)');
  END IF;
  IF (m_column_count = 0) THEN
     fnd_message.set_name('OFA', 'FA_RX_NO_DISPLAYED_COLUMNS');
--     fa_rx_util_pkg.Log(fnd_message.get);
     app_exception.raise_exception;
  END IF;

  --
  -- Get currency columns
  --
  m_displayed_column_count := m_column_count;
  l_displayed_columns := m_column_count;
  for idx in 1..l_displayed_columns loop
        if m_columns(idx).currency_column is not null then
          m_columns(idx).currency_column_id := find_column(m_columns(idx).currency_column);
          if m_columns(idx).currency_column_id is null then
            m_column_count := m_column_count + 1;

            m_columns(m_column_count).attribute_name := null;
            m_columns(m_column_count).column_name := m_columns(idx).currency_column;
            m_columns(m_column_count).ordering := null;
            m_columns(m_column_count).display_length := 0;
            m_columns(m_column_count).display_status := 'NO';
            m_columns(m_column_count).display_format := 'VARCHAR2';
            m_columns(m_column_count).break := 'N';
            m_columns(m_column_count).currency_column := null;
            m_columns(m_column_count).precision := null;
            m_columns(m_column_count).minimum_accountable_unit := null;
            m_columns(m_column_count).units := null;
            m_columns(m_column_count).format_mask := null;
            m_columns(m_column_count).break_group_level := null;

            m_columns(idx).currency_column_id := m_column_count;
          end if;
        end if;
  end loop;

  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'Retrieved '||to_char(m_column_count)||' column(s) with currency columns');
  END IF;

  --
  -- Reorder break level
  --
  l_current_break := 0;
  m_break_count := 0;
  l_last_break := -999999;
  for idx in 1..l_displayed_columns loop
        if l_last_break is null and
           m_columns(idx).break_group_level is null then
          l_last_break := null;
        elsif l_last_break is not null and
              m_columns(idx).break_group_level is null then
          l_current_break := l_current_break + 1;
          m_break_count := m_break_count + 1;
          l_last_break := null;
        elsif l_last_break <> m_columns(idx).break_group_level then
          l_current_break := l_current_break + 1;
          m_break_count := m_break_count + 1;
          l_last_break := m_columns(idx).break_group_level;
        end if;

        m_columns(idx).break_group_level := l_current_break;
  end loop;

  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'FA_RX_PUBLISH.populate_columns()-');
  END IF;
end populate_columns;

---------------------------------------------------------
-- Procedure populate_summaries
--
-- Populates the m_summaries structure
---------------------------------------------------------
procedure populate_summaries
is
--  cursor csum is
--  select
--      c.summary_prompt,
--      c.reset_level,
--      c.compute_level,
--      c.print_level,
--      r.function,
--      r.column_name
--  from
--      fa_rx_summary_rules r,
--      fa_rx_summary_columns c
--  where
--      r.report_id = m_formats(s_current_format_idx).report_id
--  and r.attribute_set = m_formats(s_current_format_idx).attribute_set
--  and r.summary_rule_id = c.summary_rule_id
--  order by print_level, compute_level, reset_level;
  cursor csum is
  select
        summary_prompt,
        reset_level,
        compute_level,
        print_level,
        summary_function function,
        column_name
  from
        fa_rx_summary s
  where
        report_id = m_formats(s_current_format_idx).report_id
  and   attribute_set = m_formats(s_current_format_idx).attribute_set
  and   display_status = 'Y'
  and   column_name in
                (select column_name from fa_rx_rep_columns c
                where c.report_id=s.report_id and
                 c.attribute_set=s.attribute_set and
                 display_status = 'YES')
  order by print_level, compute_level, reset_level;
  rsum csum%rowtype;
begin
  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'FA_RX_PUBLISH.populate_summaries()+
  report_id = '||to_char(m_formats(s_current_format_idx).report_id)||'
  attribute_set = '||m_formats(s_current_format_idx).attribute_set);
  END IF;

  m_summary_count := 0;
  open csum;
  loop
        fetch csum into rsum;
        exit when csum%notfound;

        m_summary_count := m_summary_count + 1;
        m_summaries(m_summary_count).summary_prompt := rsum.summary_prompt;
        m_summaries(m_summary_count).reset_level := rsum.reset_level;
        m_summaries(m_summary_count).compute_level := rsum.compute_level;
        m_summaries(m_summary_count).print_level := rsum.print_level;
        m_summaries(m_summary_count).function := rsum.function;
        m_summaries(m_summary_count).column_name := rsum.column_name;

        m_summaries(m_summary_count).source_column_id :=
                find_column(rsum.column_name);

        --
        -- Temporary bugfix until form is fixed.
        -- This should be taken out when the form-side is fixed.
        -- Compute Level, for the time being, is always the
        -- same as the break group level of the source column
        --
        m_summaries(m_summary_count).compute_level :=
                m_columns(m_summaries(m_summary_count).source_column_id).break_group_level;
  end loop;
  close csum;

  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'FA_RX_PUBLISH.populate_summaries()-');
  END IF;
end populate_summaries;

---------------------------------------------------------
-- function get_select_list
--
-- Returns the select list required
---------------------------------------------------------
function get_select_list return varchar2
is
  l_select varchar2(10000);
  sep varchar2(10);
begin
  l_select := 'SELECT ';
  sep := NEWLINE||'     ';

  for idx in 1..m_column_count loop
    if m_columns(idx).display_format = 'NUMBER' and
       m_columns(idx).units is not null then
        l_select := l_select || sep || m_columns(idx).column_name
                ||'/'||to_char(m_columns(idx).units);
    elsif m_columns(idx).display_format = 'DATE' and
          m_columns(idx).format_mask is not null then
        l_select := l_select || sep ||
                'to_char('||m_columns(idx).column_name||', '''||m_columns(idx).format_mask||''')';
    elsif m_columns(idx).display_format = 'DATE' then
        l_select := l_select || sep ||
                'fnd_date.date_to_displaydate('||m_columns(idx).column_name||')';
     ELSIF m_report.output_format = 'CSV' AND m_columns(idx).display_format = 'VARCHAR2' THEN
        l_select := l_select || sep || '''"''||' || m_columns(idx).column_name || '||''"''';
    else
        l_select := l_select || sep || m_columns(idx).column_name;
    end if;
    sep := NEWLINE||'   ,';
  end loop;

  return l_select;
end get_select_list;

---------------------------------------------------------
-- function get_from_clause
--
-- Returns the from clause
---------------------------------------------------------
function get_from_clause return varchar2
is
  l_from varchar2(100);
begin
  l_from := 'FROM '||m_formats(s_current_format_idx).interface_table;

  return l_from;
end get_from_clause;

---------------------------------------------------------
-- function get_where_clause
--
-- returns the where clause
---------------------------------------------------------
function get_where_clause return varchar2
is
   l_where varchar2(10000);
   sep varchar2(25);  --bug 8946154
begin
   s_bind_idx := 0;
   m_bind_count := 0;

   if m_formats(s_current_format_idx).request_id is null then
      sep := 'WHERE '||NEWLINE||'       ';
      l_where := NULL;
      for idx in 1..m_argument_count loop
         IF (g_print_debug) THEN
                fa_rx_util_pkg.debug('is_multi_format_report: ' || 'idx='||To_char(idx)||', where_clause='||
                              m_arguments(idx).where_clause||
                              ', value='||m_arguments(idx).value);
         END IF;
         if m_arguments(idx).where_clause is not null
           and m_arguments(idx).value is not null then

            m_bind_count := m_bind_count + 1;
            m_binds(m_bind_count) := m_arguments(idx).value;

            if m_arguments(idx).datatype = 'VARCHAR2' then
               l_where := l_where||sep||
                 m_arguments(idx).where_clause ||' :b'||To_char(m_bind_count);
                 --''''||m_arguments(idx).value||'''';
             elsif m_arguments(idx).datatype = 'NUMBER' then
               l_where := l_where||sep||
                 m_arguments(idx).where_clause ||' fnd_number.canonical_to_number(:b'||To_char(m_bind_count)||')';
                 -- 'fnd_number.canonical_to_number('''||m_arguments(idx).value||''')';
             else
               l_where := l_where||sep||
                 m_arguments(idx).where_clause ||' fnd_date.canonical_to_date(:b'||To_char(m_bind_count)||')';
                 --'fnd_date.canonical_to_date('''||m_arguments(idx).value||''')';
            end if;
            sep := NEWLINE||'AND        ';

         END IF; /* where clause is not null and value is not null */
      end loop;
    else
-- bug 7316487/ bug 8263761
--      l_where := 'WHERE REQUEST_ID=fnd_number.canonical_to_number(:b1)'
--      ||m_formats(s_current_format_idx).where_clause;
      l_where := 'WHERE REQUEST_ID=:b1'
        ||m_formats(s_current_format_idx).where_clause;

      m_binds(1) := fnd_number.number_to_canonical(m_formats(s_current_format_idx).request_id);
      m_bind_count := 1;
   end if;

   return l_where;
end get_where_clause;

---------------------------------------------------------
-- function get_order_by_clause
--
-- returns the order by clause
---------------------------------------------------------
function get_order_by_clause return varchar2
is
  l_order_by varchar2(10000);
  sep varchar2(10);
begin
  sep := 'ORDER BY ';
  for idx in 1..m_column_count loop
    if m_columns(idx).ordering is not null and
       m_columns(idx).ordering <> 'NONE' then
        l_order_by := l_order_by||sep||
                m_columns(idx).column_name;
        if m_columns(idx).ordering = 'DESCENDING' then
          l_order_by := l_order_by ||' DESC';
        end if;

        sep := ','|| NEWLINE;
    end if;
  end loop;

  return l_order_by;
end get_order_by_clause;


---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------


------------------------------------------------------------------
-- Get_Report_Name
--
-- Given a report_id, this routine returns
-- the application short name and concurrent program name of the
-- associated concurrent program.
-- If this is a Direct Select RX, it will return a NULL value
-- for p_appname and p_concname
------------------------------------------------------------------
procedure get_report_name(
        p_report_id in number,
        p_appname out nocopy varchar2,
        p_concname out nocopy varchar2)
is
begin
  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'FA_RX_PUBLISH.get_report_name('||to_char(p_report_id)||')+');
  END IF;

  select a.application_short_name, c.concurrent_program_name
  into p_appname, p_concname
  from
        fa_rx_reports rx,
        fnd_concurrent_programs c,
        fnd_application a
  where
        rx.application_id = c.application_id and
        rx.concurrent_program_id = c.concurrent_program_id and
        rx.application_id = a.application_id and
        rx.report_id = p_report_id;

  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'FA_RX_PUBLISH.get_report_name('||p_appname||','||p_concname||')-');
  END IF;
exception
  when no_data_found then
        p_appname := null;
        p_concname := null;
        IF (g_print_debug) THEN
                fa_rx_util_pkg.debug('is_multi_format_report: ' || 'FA_RX_PUBLISH.get_report_name('||p_appname||','||p_concname||')-');
        END IF;
end get_report_name;


------------------------------------------------------------------
-- Init_Request
--
-- Initializes this package with the given request ID, report ID,
-- attribute set and output format.
-- Should not call this for Direct Select RX.
-- Should only be called once per session.
------------------------------------------------------------------
procedure init_request(p_request_id in number,
                       p_report_id in number,
                       p_attribute_set in varchar2,
                       p_output_format in VARCHAR2,
                       p_request_type IN VARCHAR2 DEFAULT 'PUBLISH'
                       )
  is
     l_request_id NUMBER;
begin
   IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'FA_RX_PUBLISH.init_request()+'||NEWLINE||
                        'P_Request_ID = '||to_char(p_request_id)||NEWLINE||
                        'P_Report_ID  = '||to_char(p_report_id)||NEWLINE||
                        'P_Attribute_Set = '||p_attribute_set||NEWLINE||
                        'P_Output_Format = '||p_output_format);
   END IF;

   populate_report(p_request_id,
                   p_report_id,
                   p_attribute_set,
                   p_output_format);
   populate_formats;
   populate_sob;

   IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || '** Populate parameters');
   END IF;
   IF Upper(p_request_type) = 'PUBLISH' THEN
      populate_parameters('PUBLISH', p_request_id);
    ELSE
      fnd_profile.get('CONC_REQUEST_ID', l_request_id);
      IF l_request_id IS NOT NULL THEN
         -- If request ID is null then we just won't print the parameters.
         -- Include this form debuggin purposes
         populate_parameters('SUBMIT', l_request_id);
      END IF;
   END IF;


  Validate_Report;

  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'FA_RX_PUBLISH.init_request()-');
  END IF;
end init_request;

------------------------------------------------------------------
-- Init_Report
--
-- Initializes this package with the given report ID, attribute
-- set, output format, and concurrent program arguments.
-- This routine should only be called for Direct Select RX.
-- This routine should only be called once per session.
------------------------------------------------------------------
procedure init_report(
        p_report_id in number,
        p_attribute_set in varchar2,
        p_output_format in varchar2,
        p_argument1 in varchar2 ,
        p_argument2 in varchar2 ,
        p_argument3 in varchar2 ,
        p_argument4 in varchar2 ,
        p_argument5 in varchar2 ,
        p_argument6 in varchar2 ,
        p_argument7 in varchar2 ,
        p_argument8 in varchar2 ,
        p_argument9 in varchar2 ,
        p_argument10 in varchar2 ,
        p_argument11 in varchar2 ,
        p_argument12 in varchar2 ,
        p_argument13 in varchar2 ,
        p_argument14 in varchar2 ,
        p_argument15 in varchar2 ,
        p_argument16 in varchar2 ,
        p_argument17 in varchar2 ,
        p_argument18 in varchar2 ,
        p_argument19 in varchar2 ,
        p_argument20 in varchar2 ,
        p_argument21 in varchar2 ,
        p_argument22 in varchar2 ,
        p_argument23 in varchar2 ,
        p_argument24 in varchar2 ,
        p_argument25 in varchar2 ,
        p_argument26 in varchar2 ,
        p_argument27 in varchar2 ,
        p_argument28 in varchar2 ,
        p_argument29 in varchar2 ,
        p_argument30 in varchar2 ,
        p_argument31 in varchar2 ,
        p_argument32 in varchar2 ,
        p_argument33 in varchar2 ,
        p_argument34 in varchar2 ,
        p_argument35 in varchar2 ,
        p_argument36 in varchar2 ,
        p_argument37 in varchar2 ,
        p_argument38 in varchar2 ,
        p_argument39 in varchar2 ,
        p_argument40 in varchar2 ,
        p_argument41 in varchar2 ,
        p_argument42 in varchar2 ,
        p_argument43 in varchar2 ,
        p_argument44 in varchar2 ,
        p_argument45 in varchar2 ,
        p_argument46 in varchar2 ,
        p_argument47 in varchar2 ,
        p_argument48 in varchar2 ,
        p_argument49 in varchar2 ,
        p_argument50 in varchar2 ,
        p_argument51 in varchar2 ,
        p_argument52 in varchar2 ,
        p_argument53 in varchar2 ,
        p_argument54 in varchar2 ,
        p_argument55 in varchar2 ,
        p_argument56 in varchar2 ,
        p_argument57 in varchar2 ,
        p_argument58 in varchar2 ,
        p_argument59 in varchar2 ,
        p_argument60 in varchar2 ,
        p_argument61 in varchar2 ,
        p_argument62 in varchar2 ,
        p_argument63 in varchar2 ,
        p_argument64 in varchar2 ,
        p_argument65 in varchar2 ,
        p_argument66 in varchar2 ,
        p_argument67 in varchar2 ,
        p_argument68 in varchar2 ,
        p_argument69 in varchar2 ,
        p_argument70 in varchar2 ,
        p_argument71 in varchar2 ,
        p_argument72 in varchar2 ,
        p_argument73 in varchar2 ,
        p_argument74 in varchar2 ,
        p_argument75 in varchar2 ,
        p_argument76 in varchar2 ,
        p_argument77 in varchar2 ,
        p_argument78 in varchar2 ,
        p_argument79 in varchar2 ,
        p_argument80 in varchar2 ,
        p_argument81 in varchar2 ,
        p_argument82 in varchar2 ,
        p_argument83 in varchar2 ,
        p_argument84 in varchar2 ,
        p_argument85 in varchar2 ,
        p_argument86 in varchar2 ,
        p_argument87 in varchar2 ,
        p_argument88 in varchar2 ,
        p_argument89 in varchar2 ,
        p_argument90 in varchar2 ,
        p_argument91 in varchar2 ,
        p_argument92 in varchar2 ,
        p_argument93 in varchar2 ,
        p_argument94 in varchar2 ,
        p_argument95 in varchar2 ,
        p_argument96 in varchar2 ,
        p_argument97 in varchar2 ,
        p_argument98 in varchar2 ,
        p_argument99 in varchar2 ,
        p_argument100 in varchar2 )
is
  t_conc_request_id varchar2(20);
  conc_request_id number;
begin
   IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'Init_report()+');
   END IF;
  populate_report(
                null,           -- Request ID
                p_report_id,
                p_attribute_set,
                p_output_format);

  fnd_profile.get('CONC_REQUEST_ID', t_conc_request_id);
  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'Concurrent request_id = '||t_conc_request_id);
  END IF;

  if t_conc_request_id is null then
     m_report.conc_appname := NULL;
     m_report.concurrent_program_name := null; -- Debugging.
  else
     conc_request_id := to_number(t_conc_request_id);
     select
       p.concurrent_program_name,
       a.application_short_name
       INTO
       m_report.concurrent_program_name,
       m_report.conc_appname
       from
       fnd_concurrent_requests r,
       fnd_concurrent_programs p,
       fnd_application a
       where
       r.request_id = conc_request_id and
       r.program_application_id = p.application_id and
       r.concurrent_program_id = p.concurrent_program_id and
       p.application_id = a.application_id;
  end if;

  populate_arguments(
                p_argument1,
                p_argument2,
                p_argument3,
                p_argument4,
                p_argument5,
                p_argument6,
                p_argument7,
                p_argument8,
                p_argument9,
                p_argument10,
                p_argument11,
                p_argument12,
                p_argument13,
                p_argument14,
                p_argument15,
                p_argument16,
                p_argument17,
                p_argument18,
                p_argument19,
                p_argument20,
                p_argument21,
                p_argument22,
                p_argument23,
                p_argument24,
                p_argument25,
                p_argument26,
                p_argument27,
                p_argument28,
                p_argument29,
                p_argument30,
                p_argument31,
                p_argument32,
                p_argument33,
                p_argument34,
                p_argument35,
                p_argument36,
                p_argument37,
                p_argument38,
                p_argument39,
                p_argument40,
                p_argument41,
                p_argument42,
                p_argument43,
                p_argument44,
                p_argument45,
                p_argument46,
                p_argument47,
                p_argument48,
                p_argument49,
                p_argument50,
                p_argument51,
                p_argument52,
                p_argument53,
                p_argument54,
                p_argument55,
                p_argument56,
                p_argument57,
                p_argument58,
                p_argument59,
                p_argument60,
                p_argument61,
                p_argument62,
                p_argument63,
                p_argument64,
                p_argument65,
                p_argument66,
                p_argument67,
                p_argument68,
                p_argument69,
                p_argument70,
                p_argument71,
                p_argument72,
                p_argument73,
                p_argument74,
                p_argument75,
                p_argument76,
                p_argument77,
                p_argument78,
                p_argument79,
                p_argument80,
                p_argument81,
                p_argument82,
                p_argument83,
                p_argument84,
                p_argument85,
                p_argument86,
                p_argument87,
                p_argument88,
                p_argument89,
                p_argument90,
                p_argument91,
                p_argument92,
                p_argument93,
                p_argument94,
                p_argument95,
                p_argument96,
                p_argument97,
                p_argument98,
                p_argument99,
                p_argument100);
  populate_formats;
  populate_sob;

  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || '** Populate parameters');
  END IF;
  if t_conc_request_id is NOT null then
     -- If request ID is null then we just won't print the parameters.
     -- Include this form debuggin purposes
     populate_parameters('DIRECT', t_conc_request_id);
  END IF;

  Validate_Report;
   IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'Init_report()-');
   END IF;
end init_report;

------------------------------------------------------------------
-- Get_Report_Info
--
-- This routine returns report level information.
-- These are information that should not change between formats.
------------------------------------------------------------------
PROCEDURE get_report_info(
        p_display_report_title OUT NOCOPY VARCHAR2,
        p_display_set_of_books OUT NOCOPY VARCHAR2,
        p_display_functional_currency OUT NOCOPY VARCHAR2,
        p_display_submission_date OUT NOCOPY VARCHAR2,
        p_display_current_page OUT NOCOPY VARCHAR2,
        p_display_total_page OUT NOCOPY VARCHAR2,
        p_report_title OUT NOCOPY VARCHAR2,
        p_set_of_books_name OUT NOCOPY VARCHAR2,
        p_function_currency_prompt OUT NOCOPY VARCHAR2,
        p_function_currency OUT NOCOPY VARCHAR2,
        p_submission_date OUT NOCOPY VARCHAR2,
        p_report_date_prompt OUT NOCOPY VARCHAR2,  --* bug#2902895, rravunny
        p_current_page_prompt OUT NOCOPY VARCHAR2,
        p_total_page_prompt OUT NOCOPY VARCHAR2,
        p_page_width OUT NOCOPY NUMBER,
        p_page_height OUT NOCOPY NUMBER,
        p_output_format OUT NOCOPY VARCHAR2,
        p_nls_end_of_report OUT NOCOPY VARCHAR2,
        p_nls_no_data_found OUT NOCOPY VARCHAR2)
is
begin
  p_display_report_title := m_report.display_report_title;
  p_display_set_of_books := m_report.display_set_of_books;
  p_display_functional_currency := m_report.display_functional_currency;
  p_display_submission_date := m_report.display_submission_date;
  p_display_current_page := m_report.display_current_page;
  p_display_total_page := m_report.display_total_page;
  p_report_title := m_report.report_title;
  p_set_of_books_name := m_report.set_of_books_name;
  p_function_currency_prompt := m_report.functional_currency_prompt;
  p_function_currency := m_report.functional_currency;
  p_submission_date := m_report.submission_date;  --* bug#2902895, rravunny
  p_report_date_prompt := m_report.date_prompt; --* bug#2902895, rravunny
  p_current_page_prompt := m_report.current_page_prompt;
  p_total_page_prompt := m_report.total_page_prompt;
  p_page_width := m_report.page_width;
  p_page_height := m_report.page_height;
  p_output_format := m_report.output_format;
  p_nls_end_of_report := m_report.nls_end_of_report;
  p_nls_no_data_found := m_report.nls_no_data_found;
end get_report_info;

------------------------------------------------------------------
-- Bug 8460187 : RER Project overloaded this function
-- Get_Report_Info
-- This routine returns report level information.
-- These are information that should not change between formats.
------------------------------------------------------------------
PROCEDURE get_report_info(
        p_display_report_title OUT NOCOPY VARCHAR2,
        p_display_set_of_books OUT NOCOPY VARCHAR2,
        p_display_functional_currency OUT NOCOPY VARCHAR2,
        p_display_submission_date OUT NOCOPY VARCHAR2,
        p_display_current_page OUT NOCOPY VARCHAR2,
        p_display_total_page OUT NOCOPY VARCHAR2,
        p_report_title OUT NOCOPY VARCHAR2,
        p_set_of_books_name OUT NOCOPY VARCHAR2,
        p_function_currency_prompt OUT NOCOPY VARCHAR2,
        p_function_currency OUT NOCOPY VARCHAR2,
        p_submission_date OUT NOCOPY VARCHAR2,
        p_current_page_prompt OUT NOCOPY VARCHAR2,
        p_total_page_prompt OUT NOCOPY VARCHAR2,
        p_page_width OUT NOCOPY NUMBER,
        p_page_height OUT NOCOPY NUMBER,
        p_output_format OUT NOCOPY VARCHAR2,
        p_nls_end_of_report OUT NOCOPY VARCHAR2,
        p_nls_no_data_found OUT NOCOPY VARCHAR2)
is
begin
  p_display_report_title := m_report.display_report_title;
  p_display_set_of_books := m_report.display_set_of_books;
  p_display_functional_currency := m_report.display_functional_currency;
  p_display_submission_date := m_report.display_submission_date;
  p_display_current_page := m_report.display_current_page;
  p_display_total_page := m_report.display_total_page;
  p_report_title := m_report.report_title;
  p_set_of_books_name := m_report.set_of_books_name;
  p_function_currency_prompt := m_report.functional_currency_prompt;
  p_function_currency := m_report.functional_currency;
  p_current_page_prompt := m_report.current_page_prompt;
  p_total_page_prompt := m_report.total_page_prompt;
  p_page_width := m_report.page_width;
  p_page_height := m_report.page_height;
  p_output_format := m_report.output_format;
  p_nls_end_of_report := m_report.nls_end_of_report;
  p_nls_no_data_found := m_report.nls_no_data_found;
end get_report_info;


------------------------------------------------------------------
-- Format Available
--
-- This routine should be called after a format ends to determine
-- if there are any more formats.
------------------------------------------------------------------
function format_available return varchar2
is
begin
  s_current_format_idx := s_current_format_idx + 1;
  if s_current_format_idx > m_format_count then
        s_current_format_idx := null;
        return 'N';
  end if;

  return 'Y';
end format_available;

------------------------------------------------------------------
-- Get_Format_Info
--
-- This routine returns format level information.
-- These are information that may change from format to format.
------------------------------------------------------------------
procedure get_format_info(
        p_display_parameters out nocopy varchar2,
        p_display_page_break out nocopy varchar2,
        p_group_display_type out nocopy varchar2)
is
begin
  p_display_parameters := m_formats(s_current_format_idx).display_parameters;
  p_display_page_break := m_formats(s_current_format_idx).display_page_break;
  p_group_display_type := m_formats(s_current_format_idx).group_display_type;
end get_format_info;

------------------------------------------------------------------
-- Get_Param_Count
--
-- Returns the number of parameters for the current format.
------------------------------------------------------------------
function get_param_count return number
is
begin
  s_current_param_idx := 1;
  return m_param_display_count;
end get_param_count;

------------------------------------------------------------------
-- Get_Parameter
--
-- Returns parameter information.
-- Must be called exact number of times as is returned by
-- Get_Param_Count.
------------------------------------------------------------------
procedure get_parameter(
        p_param_id    in  number,
        p_param_name  out nocopy varchar2,
        p_param_value out nocopy varchar2)
is
begin
   WHILE (m_params(s_current_param_idx).display_flag <> 'Y') LOOP
      s_current_param_idx := s_current_param_idx + 1;
   END LOOP;
   p_param_name := m_params(s_current_param_idx).name;
   p_param_value := m_params(s_current_param_idx).value;
   s_current_param_idx := s_current_param_idx + 1;
end get_parameter;

------------------------------------------------------------------
-- Get_Break_Level
--
-- Returns the number of break levels in the current format.
------------------------------------------------------------------
function get_break_level_count return number
is
begin
  s_current_column_idx := null;
  s_current_summary_idx := null;

  return m_break_count;
end get_break_level_count;

------------------------------------------------------------------
-- Get_Column_Count
--
-- Returns the number of columns in the given break level.
-- Break level should be between 1 and the returned value of
-- Get_Break_Level.
------------------------------------------------------------------
function get_column_count(
        p_break_level in number) return number
is
  cnt number;
begin
  if s_current_column_idx is null then
        s_current_column_idx := 1;
  end if;

  cnt := 0;
  for idx in s_current_column_idx..m_column_count loop
        if m_columns(idx).break_group_level <> p_break_level
           or m_columns(idx).display_status = 'NO' then
          return cnt;
        end if;

        cnt := cnt + 1;
  end loop;

  return cnt;
end get_column_count;


------------------------------------------------------------------
-- Get_Column_Info
--
-- Returns the column information for the given break level.
-- This routine must be called as many times as is returned
-- by Get_Column_Count.
------------------------------------------------------------------
procedure get_column_info(
        p_break_level in number,
        p_column_id out nocopy number,
        p_column_name out nocopy varchar2,
        p_column_type out nocopy varchar2,
        p_attribute_name out nocopy varchar2,
        p_length out nocopy number,
        p_currency_column_id out nocopy number,
        p_precision out nocopy number,
        p_minimum_accountable_unit out nocopy number,
        p_break out nocopy varchar2)
is
begin
  p_column_id := s_current_column_idx;
  p_column_name := m_columns(s_current_column_idx).column_name;
  p_column_type := m_columns(s_current_column_idx).display_format;
  p_attribute_name := m_columns(s_current_column_idx).attribute_name;
  p_length := m_columns(s_current_column_idx).display_length;
  p_currency_column_id := m_columns(s_current_column_idx).currency_column_id;
  p_precision := m_columns(s_current_column_idx).precision;
  p_minimum_accountable_unit := m_columns(s_current_column_idx).minimum_accountable_unit;
  p_break := m_columns(s_current_column_idx).break;

  s_current_column_idx := s_current_column_idx + 1;
end get_column_info;


------------------------------------------------------------------
-- Get_Summary_Column_Count
--
-- Returns the number of summary columns in the given break level.
-- Break level should be between 1 and the returned value of
-- Get_Break_Level.
------------------------------------------------------------------
function get_summary_column_count(
        p_break_level in number) return number
is
  cnt number;
  idx number;
begin
  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'FA_RX_PUBLISH.get_summary_column_count('||to_char(p_break_level)||')+');
  END IF;

  idx := 1;
  loop
        exit when idx > m_summary_count;
        exit when m_summaries(idx).print_level = p_break_level;
        idx := idx + 1;
  end loop;

  cnt := 0;
  s_current_summary_idx := idx;
  loop
        if idx > m_summary_count then
          IF (g_print_debug) THEN
                fa_rx_util_pkg.debug('is_multi_format_report: ' || 'idx = '||to_char(idx)||', summary_count='||to_char(m_summary_count));
          END IF;
          exit;
        end if;
        IF (g_print_debug) THEN
                fa_rx_util_pkg.debug('is_multi_format_report: ' || 'Checking '||to_char(idx)||' with break level '||to_char(m_summaries(idx).print_level));
        END IF;
        exit when m_summaries(idx).print_level <> p_break_level;

        idx := idx + 1;
        cnt := cnt + 1;
  end loop;

  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'FA_RX_PUBLISH.get_summary_column_count('||to_char(cnt)||')-');
  END IF;
  return cnt;
end get_summary_column_count;

------------------------------------------------------------------
-- Get_Summary_Column_Info
--
-- Returns the summary column information for the given break level.
-- This routine must be called as many times as is returned
-- by Get_Summary_Column_Count.
------------------------------------------------------------------
procedure get_summary_column_info(
        p_break_level in number,
        p_summary_column_id out nocopy number,
        p_prompt out nocopy varchar2,
        p_source_column_id out nocopy number)
is
begin
  p_summary_column_id := s_current_summary_idx;
  p_prompt :=  m_summaries(s_current_summary_idx).summary_prompt;
  p_source_column_id := m_summaries(s_current_summary_idx).source_column_id;

  s_current_summary_idx := s_current_summary_idx + 1;
end get_summary_column_info;


------------------------------------------------------------------
-- Start_Format
--
-- This routine should be called at the beginning of every format.
------------------------------------------------------------------
procedure start_format
is
  rows number;
  dummy varchar2(240);
begin
  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'FA_RX_PUBLISH.START_FORMAT()+');
  END IF;

  --
  -- Initialize the date/time formats
  -- NOTE: The very first one was also initialized during populate_formats
  if (m_formats(s_current_format_idx).default_date_format is not null) then
        fnd_date.initialize(m_formats(s_current_format_idx).default_date_format,
                        m_formats(s_current_format_idx).default_date_time_format);
  end if;
  m_report.submission_date := fnd_date.date_to_displaydt(m_report.real_submission_date);

  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || '-- Populate columns');
  END IF;
  populate_columns;
  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || '-- Populate summaries');
  END IF;
  populate_summaries;

  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('is_multi_format_report: ' || 'FA_RX_PUBLISH.start_format()-');
  END IF;
end start_format;

------------------------------------------------------------------
-- End_Format
--
-- This routine should be called at the end of every format.
------------------------------------------------------------------
procedure end_format
is
begin
  null;
end end_format;

------------------------------------------------------------------
-- Get_All_Column_Count
--
-- This routine returns the number of columns in the select
-- statement returned by Get_Select_Stmt
-- May return more than get_break_level_count * get_column_count
-- since the select statement may include currency columns
-- as well.
------------------------------------------------------------------
function get_all_column_count return number
is
begin
  s_current_column_idx := 1;
  return m_column_count;
end get_all_column_count;

function get_disp_column_count return number
is
begin
  s_current_column_idx := 1;
  return m_displayed_column_count;
end get_disp_column_count;

------------------------------------------------------------------
-- Get_Format_Col_Info
--
-- This routine returns information required for formatting.
-- It will return the columns in order of the column_id returned
-- by Get_Column_Info. The p_currency_column_id returned here
-- will also point to a valid column_id returned by this routine.
------------------------------------------------------------------
procedure get_format_col_info(
        p_column_name out nocopy varchar2,
        p_display_format out nocopy varchar2,
        p_display_length out nocopy number,
        p_break_group_level out nocopy number,
        p_format_mask out nocopy varchar2,
        p_currency_column_id out nocopy number,
        p_precision out nocopy number,
        p_minunit out nocopy number)
is
begin
  if s_current_column_idx > m_column_count then
        raise no_data_found;
  end if;

  p_column_name := m_columns(s_current_column_idx).column_name;
  p_display_format := m_columns(s_current_column_idx).display_format;
  p_display_length := m_columns(s_current_column_idx).display_length;
  p_break_group_level := m_columns(s_current_column_idx).break_group_level;
  p_format_mask := m_columns(s_current_column_idx).format_mask;
  p_currency_column_id := m_columns(s_current_column_idx).currency_column_id;
  p_precision := m_columns(s_current_column_idx).precision;
  p_minunit := m_columns(s_current_column_idx).minimum_accountable_unit;

  s_current_column_idx := s_current_column_idx + 1;
end get_format_col_info;

------------------------------------------------------------------
-- Get_All_Summary_Count
--
-- This routine returns the number of summary columns
------------------------------------------------------------------
function get_all_summary_count return number
is
begin
 s_current_summary_idx := 1;
 return m_summary_count;
end get_all_summary_count;

------------------------------------------------------------------
-- Get_Format_Sum_Info
--
-- This routine returns information about summary columns as required
-- to format.
-- p_source_column_id will point to a valid column_id returned
-- by Get_Format_Column_Info.
-- This routine will return the columns in order of p_summary_column_id
-- returned by Get_Summary_Column_Info
------------------------------------------------------------------
procedure get_format_sum_info(
        p_source_column_id out nocopy number,
        p_reset_level out nocopy number,
        p_compute_level out nocopy number,
        p_summary_function out nocopy varchar2)
is
begin
  if s_current_summary_idx > m_summary_count then
    p_source_column_id := 0;
    p_reset_level := -99;
    p_compute_level := -99;
    p_summary_function := -99;
  else
    p_source_column_id := m_summaries(s_current_summary_idx).source_column_id;
    p_reset_level := m_summaries(s_current_summary_idx).reset_level;
    p_compute_level := m_summaries(s_current_summary_idx).compute_level;
    p_summary_function := m_summaries(s_current_summary_idx).function;
  end if;

  s_current_summary_idx := s_current_summary_idx + 1;
end get_format_sum_info;


------------------------------------------------------------------
-- Get_Select_Stmt
--
-- This routine returns the main select statment.
-- There will be no bind variables here.
------------------------------------------------------------------
function get_select_stmt return varchar2
is
  sqlstmt varchar2(10000);
  add_where_clause      varchar2(10000) := '';
  tmp_where_clause      varchar2(10000);
  plsql_block           varchar2(150);
  X_where_clause_api    varchar2(80);
  l_cursor              integer;

begin

  tmp_where_clause := get_where_clause;
  X_where_clause_api := m_formats(s_current_format_idx).where_clause_api;
  IF X_where_clause_api IS NOT NULL THEN
        plsql_block := 'BEGIN :where_clause := ' || X_where_clause_api ||'(:id); end;';
        execute immediate plsql_block using out add_where_clause, in m_formats(s_current_format_idx).request_id;
  END IF;

  IF add_where_clause IS NOT NULL THEN
     --
     IF tmp_where_clause IS NULL THEN
        tmp_where_clause := ' where '||add_where_clause;
     ELSE
        tmp_where_clause := tmp_where_clause||' AND '||add_where_clause;
     END IF;
     --
  END IF;
  sqlstmt :=  get_select_list||NEWLINE||
        get_from_clause||NEWLINE||
        tmp_where_clause||NEWLINE||
        get_order_by_clause;
  BEGIN
  l_cursor := dbms_sql.open_cursor;

  IF (g_print_debug) THEN
     arp_util_tax.debug('BEGIN '||rtrim(ltrim(sqlstmt))||'; END;');
  END IF;

  dbms_sql.parse(l_cursor,
                   'BEGIN '||rtrim(ltrim(sqlstmt))||'; END;', dbms_sql.native);
  dbms_sql.close_cursor(l_cursor);

  EXCEPTION
      WHEN OTHERS THEN
        IF (g_print_debug) THEN
           arp_util_tax.debug('get_select_stmt(-) wrong PL_SQL statement');
        END IF;
  END;

  return sqlstmt;
end get_select_stmt;

------------------------------------------------------------------
-- Is_Multi_Format_Report
-- Returns true if the request is a multiple format report.
------------------------------------------------------------------
function Is_Multi_Format_Report(p_request_id in number)
return boolean
is
  cnt number;
begin
  select count(*) into cnt
  from fa_rx_multiformat_reps
  where request_id = p_request_id;

  return (cnt > 0);
end is_multi_format_report;

procedure Expand_Complex_Multiformat(p_formats in formattab, p_count in number)
is
  cursor cols(p_report_id in number, p_attribute_set in varchar2) is select
        column_name, display_format
  from fa_rx_rep_columns
  where report_id = p_report_id
  and   attribute_set = p_attribute_set
  and   break = 'Y'
  and   break_group_level = 1
  order by attribute_counter;

  sqlstmt varchar2(2000);
  sep varchar2(30);
  numcols number;
  where_clause varchar2(1000);
  buf varchar2(400);
  colidx number;

  c integer;
  rows integer;

  invalid_result_columns exception;
  pragma exception_init(invalid_result_columns, -1789);
begin
  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('Expand_Complex_Multiformat()+');
  END IF;

  sqlstmt := null;
  for idx in 1..p_count loop
    if sqlstmt is null then
      sqlstmt := 'SELECT DISTINCT ';
    else
      sqlstmt := sqlstmt ||' UNION SELECT DISTINCT ';
    end if;

    sep := null;
    numcols := 0;
    for crow in cols(p_formats(idx).report_id, p_formats(idx).attribute_set) loop
        if crow.display_format = 'VARCHAR2' then
          sqlstmt := sqlstmt || sep || crow.column_name;
        elsif crow.display_format = 'NUMBER' then
          sqlstmt := sqlstmt || sep || 'fnd_number.number_to_canonical('||crow.column_name||')';
        elsif crow.display_format = 'DATE' then
          sqlstmt := sqlstmt || sep || 'fnd_date.date_to_canonical('||crow.column_name||')';
        end if;

        sep := ', ';
        numcols := numcols + 1;
    end loop;

    if numcols = 0 then
        -- There were no break columns!
        app_exception.raise_exception;
    end if;

    sqlstmt := sqlstmt || ' FROM '||p_formats(idx).interface_table
                || ' WHERE REQUEST_ID = '||to_char(p_formats(idx).request_id);
  end loop;


  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('Expand_Complex_Multiformat: ' || '
'||sqlstmt||'
');
  END IF;

  c := dbms_sql.open_cursor;
  begin
    dbms_sql.parse(c, sqlstmt, dbms_sql.native);
  exception
  when invalid_result_columns then
        IF (g_print_debug) THEN
                fa_rx_util_pkg.debug('Expand_Complex_Multiformat: ' || 'Cannot use complex mode for these sets of reports');
        END IF;
        fnd_message.set_name('OFA', 'FA_RX_INVALID_USE_OF_COMPLEX');
        app_exception.raise_exception;
  end;
  for idx in 1..numcols loop
        dbms_sql.define_column(c, idx, buf, 400);
  end loop;
  rows := dbms_sql.execute(c);
  loop
    rows := dbms_sql.fetch_rows(c);
    exit when rows = 0 ;

    for idx in 1..p_count loop
        m_format_count := m_format_count + 1;
        where_clause := null;
        sep := ' AND ';

        colidx := 0;
        for crow in cols(p_formats(idx).report_id, p_formats(idx).attribute_set) loop
          colidx := colidx + 1;
          dbms_sql.column_value(c, colidx, buf);

          if crow.display_format = 'VARCHAR2' then
            where_clause := where_clause || sep ||
                crow.column_name ||' = '''||buf||'''';
          elsif crow.display_format = 'NUMBER' then
            where_clause := where_clause || sep ||
                'FND_NUMBER.NUMBER_TO_CANONICAL('||crow.column_name ||') = '||buf;
          elsif crow.display_format = 'DATE' then
            where_clause := where_clause || sep ||
                'FND_DATE.DATE_TO_CANONICAL('||crow.column_name ||') = '||buf;
          end if;

          sep := ' AND ';
        end loop;

        m_formats(m_format_count) := p_formats(idx);
        m_formats(m_format_count).where_clause := where_clause;

        IF (g_print_debug) THEN
                fa_rx_util_pkg.debug('Expand_Complex_Multiformat: ' || where_clause);
        END IF;
    end loop;
  end loop;

  dbms_sql.close_cursor(c);
end expand_complex_multiformat;



-----------------------------------------------------------------
-- Validate_Report
-- Validate different portions of the report
-----------------------------------------------------------------
procedure Validate_Report
is
  max_lines number;
  pos number;
  line number;
  last_pos number;
  last_line number;


  function calculate_pos(format_idx in number, break_flag in varchar2, max_width in number,
                        last_pos out nocopy number, last_line out number) return boolean
  is
    min_level number;
    current_pos number;
    current_line number;

    cursor col(min_level in NUMBER, break_flag IN varchar2) is select
        attribute_name,
        Least(display_length, 255) display_length
        from fa_rx_rep_columns
        where report_id = m_formats(format_idx).report_id and attribute_set = m_formats(format_idx).attribute_set
        and display_status = 'YES'
      and decode(break, 'Y', break_group_level, -999) >= min_level
      AND Nvl(break, 'N') = break_flag
      ORDER BY Nvl(break,'N') DESC, break_group_level, attribute_counter;
  begin
    if break_flag = 'Y' then
        select min(break_group_level) into min_level from fa_rx_rep_columns
        where report_id = m_formats(format_idx).report_id and attribute_set = m_formats(format_idx).attribute_set
        and display_status = 'YES';

        if m_formats(format_idx).display_page_break = 'Y' then
          min_level := min_level + 1;
        end if;
    else
        min_level := -999;
    end if;

    current_pos := -2;
    current_line := 1;
    for colrow in col(min_level, break_flag) loop
        if colrow.display_length > max_width then
          fnd_message.set_name('OFA', 'FA_RX_COLUMN_TOO_WIDE');
          fnd_message.set_token('COLUMN_NAME', colrow.attribute_name);
          return FALSE;
        end if;

        if current_pos + 2 + colrow.display_length > max_width then
          current_pos := -2;
          current_line := current_line + 1;
        end if;

        current_pos := current_pos + 2 + colrow.display_length;
    end loop;

    last_pos := current_pos;
    last_line := current_line;

    return TRUE;
  end calculate_pos;

begin
  max_lines := 0;

  if m_report.page_width <> 0 then
    -- Check page widths
    for i in 1..m_format_count loop
        pos := 0;
        line := 0;
        if not calculate_pos(i, 'Y', m_report.page_width, last_pos, last_line) then
--     fa_rx_util_pkg.Log(fnd_message.get);
           app_exception.raise_exception;
        end if;
        pos := last_pos;
        line := last_line;

        if m_formats(i).group_display_type = 'GROUP LEFT' then
          if not calculate_pos(i, 'N', m_report.page_width - 2 - pos, last_pos, last_line) then
            fa_rx_util_pkg.debug(fnd_message.get);
            fnd_message.set_name('OFA', 'FA_RX_GROUP_ABOVE_USED');
            fa_rx_util_pkg.log(fnd_message.get);

            m_formats(i).group_display_type := 'GROUP ABOVE';
          else
            line := line + last_line - 1;
          end if;
        end if;

        if m_formats(i).group_display_type = 'GROUP ABOVE' then
          if not calculate_pos(i, 'N', m_report.page_width, last_pos, last_line) then
--     fa_rx_util_pkg.Log(fnd_message.get);
             app_exception.raise_exception;
          else
            line := line + last_line;
          end if;
        end if;

        if max_lines < line then max_lines := line; end if;
    end loop;
  else
    max_lines := 1;
  end if;

  if m_report.page_height <> 0 then
    -- Check page height
    if max_lines*2 + 20 > m_report.page_height then
        fnd_message.set_name('OFA', 'FA_RX_PAGE_HEIGHT_TOO_SMALL');
--     fa_rx_util_pkg.Log(fnd_message.get);
        app_exception.raise_exception;
    end if;
  end if;

end Validate_Report;



-----------------------------------------
-- Handle Bind variables
-----------------------------------------
FUNCTION get_bind_count RETURN NUMBER
  IS
BEGIN
   s_bind_idx := 0;
   RETURN m_bind_count;
END get_bind_count;

FUNCTION get_bind_variable RETURN VARCHAR2
  IS
BEGIN
   s_bind_idx := s_bind_idx + 1;
   IF s_bind_idx > m_bind_count THEN RETURN NULL;
   END IF;
   RETURN m_binds(s_bind_idx);
END get_bind_variable;

PROCEDURE bind_variables(c IN INTEGER)
  IS
     v VARCHAR2(240);
BEGIN
   FOR i IN 1..get_bind_count LOOP
      v := get_bind_variable;
      IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('bind_variables: ' || 'Bind :b'||To_char(i)||' => '||v);
      END IF;
      dbms_sql.bind_variable(c, ':b'||To_char(i), v);
   END LOOP;
END bind_variables;

PROCEDURE get_rows_purged(request_id IN VARCHAR2, l_report_id IN NUMBER,
                        l_purge_api OUT NOCOPY VARCHAR2,row_num out NUMBER)
is
  plsql_block           varchar2(200);

begin

  IF (g_print_debug) THEN
     arp_util_tax.debug('get_rows_purged()');
     arp_util_tax.debug('request_id: '||request_id);
  END IF;

  select purge_api into l_purge_api
  from fa_rx_reports
  where report_id = l_report_id;

  IF (g_print_debug) THEN
     arp_util_tax.debug('purge_api: '|| l_purge_api);
  END IF;

  if l_purge_api is not null then
        plsql_block := 'BEGIN :num := ' || l_purge_api||'(:id); end;';
        execute immediate plsql_block using out row_num, in to_number(request_id);

        IF (g_print_debug) THEN
           arp_util_tax.debug('rows purged : '||row_num);
        END IF;
  end if;
end get_rows_purged;

Procedure Get_Moac_Message(xMoac_Message out NOCOPY Varchar2)
Is
        l_ld_sp varchar2(1);
        l_Reporting_Level Varchar2(100);
        l_reporting_entity_id Varchar2(100);
Begin
        --Bug 8402286 intializing cache
        IF not fa_cache_pkg.fazprof then
           null;
        end if;
        g_release  := fa_cache_pkg.fazarel_release;  --global variable to get release name #8402286
        IF (g_release = 12) then

            xMoac_Message := Null;

            for s_current_param_idx in m_params_with_actual_value.first..m_params_with_actual_value.last
            LOOP
                   fa_rx_util_pkg.debug('   name  = '||m_params_with_actual_value(s_current_param_idx).name );
                   fa_rx_util_pkg.debug('   value =  '||m_params_with_actual_value(s_current_param_idx).value );
                   fa_rx_util_pkg.debug('   display_flag =   '||m_params_with_actual_value(s_current_param_idx).display_flag );
                   fa_rx_util_pkg.debug('   format_type  =  '||m_params_with_actual_value(s_current_param_idx).format_type  );
                   fa_rx_util_pkg.debug('   flex_value_set_id =   '||m_params_with_actual_value(s_current_param_idx).flex_value_set_id );
                   fa_rx_util_pkg.debug('   flex_value_set_name  =  '||m_params_with_actual_value(s_current_param_idx).flex_value_set_name  );
                   fa_rx_util_pkg.debug('   param_idx  = '||m_params_with_actual_value(s_current_param_idx).param_idx  );
                   fa_rx_util_pkg.debug('   column_name   = '||m_params_with_actual_value(s_current_param_idx).column_name   );
                   fa_rx_util_pkg.debug('   operator   = '||m_params_with_actual_value(s_current_param_idx).operator   );

                   If (m_params_with_actual_value(s_current_param_idx).flex_value_set_name = 'FND_MO_REPORTING_LEVEL') Then
                           l_Reporting_Level := m_params_with_actual_value(s_current_param_idx).value;
                   End If;
                   If (m_params_with_actual_value(s_current_param_idx).flex_value_set_name = 'FND_MO_REPORTING_ENTITY') Then
                           l_reporting_entity_id := m_params_with_actual_value(s_current_param_idx).value;
                   End If;
            END LOOP;

            fa_rx_util_pkg.debug('   l_Reporting_Level   = '||l_Reporting_Level);
            fa_rx_util_pkg.debug('   l_reporting_entity_id   = '||l_reporting_entity_id);

            If to_number(l_Reporting_Level) = 1000 Then --* if 1000, then it means it is legal entity.
                l_ld_sp:= mo_utils.check_ledger_in_sp(TO_NUMBER(l_reporting_entity_id)); --* if 1000, then use the p_reporting_entity_id
                IF l_ld_sp = 'N' THEN
                     FND_MESSAGE.SET_NAME('FND','FND_MO_RPT_PARTIAL_LEDGER');
                     xMoac_Message :=FND_MESSAGE.get;
                END IF;
            END IF;
            fa_rx_util_pkg.debug(' xMoac_Message = '||xMoac_Message);
        END IF; --if g_release = 12
        null;
Exception
        When Others Then
                xMoac_Message := Null;
                fa_rx_util_pkg.debug(' In exception xMoac_Message = '||xMoac_Message);
End get_Moac_Message;



end fa_rx_publish;

/
