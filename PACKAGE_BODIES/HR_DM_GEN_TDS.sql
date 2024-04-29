--------------------------------------------------------
--  DDL for Package Body HR_DM_GEN_TDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DM_GEN_TDS" as
/* $Header: perdmgnd.pkb 120.0 2005/05/31 17:08:28 appldev noship $ */


--type t_varchar2_tbl is table of varchar2(32767) index by binary_integer;
type t_varchar2_32k_tbl is table of varchar2(32767) index by binary_integer;


g_table_info                  hr_dm_gen_main.t_table_info;
g_columns_tbl                 hr_dm_library.t_varchar2_tbl;
g_parameters_tbl              hr_dm_library.t_varchar2_tbl;
g_hier_columns_tbl            hr_dm_library.t_varchar2_tbl;
g_hier_parameters_tbl         hr_dm_library.t_varchar2_tbl;
g_resolve_pk_columns_tbl      hr_dm_gen_main.t_fk_to_aol_columns_tbl;
g_surrogate_pk_col_param      varchar2(30);

-- to store the package body in to array so as to overcome the limit of 32767
-- character the global variable is defined.
g_package_body    dbms_sql.varchar2s;
g_package_index   number := 0;

--c_newline               constant varchar(1) default '
--';

--
-- Exception for generated text exceeding the maximum allowable buffer size.
--
plsql_value_error    exception;
pragma exception_init(plsql_value_error, -6502);

-- ----------------------- indent -----------------------------------------
-- Description:
-- returns the 'n' blank spaces on a newline.used to indent the procedure
-- statements.
-- if newline parameter is 'Y' then start the indentation from new line.
-- ------------------------------------------------------------------------

function indent
(
 p_indent_spaces  in number default 0,
 p_newline        in varchar2 default 'Y'
) return varchar2 is
  l_spaces     varchar2(100);
begin

  l_spaces := hr_dm_library.indent(p_indent_spaces => p_indent_spaces,
                                   p_newline       => p_newline);
  return l_spaces;
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.indent',
                         '(p_indent_spaces - ' || p_indent_spaces ||
                         ')(p_newline - ' || p_newline || ')',
                         'R');
end indent;

-- ----------------------- format_comment ---------------------------------
-- Description:
-- formats the comments to be written into the procedure body
-- e.g comment string ' This is a example comment text' will be converted t
--       --
--       -- This is a example comment text.
--       --
-- ------------------------------------------------------------------------

function format_comment
(
 p_comment_text      in  varchar2,
 p_indent_spaces     in  number default 0,
 p_ins_blank_lines   in  varchar2 default 'Y'
) return varchar2 is

  l_comment_text       varchar2(20000);
  l_comment_length     number := length(p_comment_text);

  --
  -- maximum chracters for single comment text line ensuring the single
  -- comment line cannot be more than 77 characters long excluding 3
  -- characters ('-- ') at the begning of comment.
  --

  l_max_comment_line_len   number := 77 - p_indent_spaces;
  l_comment_line_len       number;
  l_comment_line_txt       varchar2(80);

  -- start and end pointer of comment line to be copied from comment text.
  l_start_ptr          number := 1;
  l_end_ptr            number;

  -- used for wrapping
  l_last_space_ptr     number;
begin

  if p_ins_blank_lines = 'Y' then
    l_comment_text := indent(p_indent_spaces) || '--';
  end if;

  loop
    l_end_ptr := l_start_ptr + l_max_comment_line_len - 1;

    l_comment_line_txt := substr(p_comment_text,l_start_ptr,(l_end_ptr - l_start_ptr + 1));

    l_comment_line_len  := length(l_comment_line_txt);

    -- comment line is less than the maximum text that come then it is ok,
    -- otherwise do word wrapping.If the next character is a space there is
    -- no need for wrapping

    if l_comment_line_len >= l_max_comment_line_len and
       substr(p_comment_text,l_end_ptr + 1,1) <> ' '
    then

      -- this function ensures the wrapping of the word. last word will come
      -- either full or move to the next line.This gives the position of the
      -- last space in the comment line text.

      l_last_space_ptr := instr(l_comment_line_txt,' ',-1);

     -- adjust the end pointer as we want to copy the string upto the last
      -- space only, the remaining word should go into next line.

      l_end_ptr := l_end_ptr - (length(l_comment_line_txt) - l_last_space_ptr);

    end if;

    -- now the end_ptr gives the length of the comment line that can be copied
    -- with a space in the end.

    l_comment_text := l_comment_text || indent(p_indent_spaces) || '-- ';


    l_comment_text := l_comment_text || substr(p_comment_text,l_start_ptr,
                                                 (l_end_ptr - l_start_ptr + 1));

    l_start_ptr := l_end_ptr +1;

    if l_start_ptr > l_comment_length then
       exit;
    end if;
  end loop;


  if p_ins_blank_lines = 'Y' then
    l_comment_text := l_comment_text || indent(p_indent_spaces) || '--';
  end if;
  return l_comment_text;
exception
  when others then
    hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.format_comment',
                        '(p_ins_blank_lines - ' || p_ins_blank_lines ||
                        ')(p_indent_spaces - ' || p_indent_spaces ||
                        ')(p_comment_text - ' || p_comment_text || ')'
                        ,'R');
end format_comment;

--------------------- init_package_body----------------------------------------
-- This package will delete all the elements from the package body pl/sql table.
-------------------------------------------------------------------------------
procedure init_package_body is
  l_index      number := g_package_body.first;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.init_package_body', 5);

  -- delete all elements from package body pl/sql table.
  while l_index is not null loop
    g_package_body.delete(l_index);
    l_index := g_package_body.next(l_index);
  end loop;
  --initialize the index
  g_package_index := 0;
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.init_package_body',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.init_package_body',
                         '(none)','R');
     raise;
end init_package_body;
-- -----------------------add_debug_messages ---------------------------------
-- Description:
-- This procedure will add the debug messages to the generated procedures.
-- Debug messages are added depending upon the procedure and location.
-- Debug messages are added at the start of the procedure body or at the end.
-- Input Parameter :
--      p_procedure_name : procedure name of the TDS package. e.g 'DOWNLOAD',
--                         'CALCULATE_RANGES', 'DELETE_SOURCE', e.t.c.
--      p_message_location : it can have following two values
--                        'START' - to put the debug message at start
--                        'END' - to put the debug message at end.
-- ------------------------------------------------------------------------
procedure add_debug_messages
(
 p_table_info       in     hr_dm_gen_main.t_table_info,
 p_procedure_name   in     varchar2,
 p_message_location in     varchar2,
 p_proc_body        in out nocopy varchar2
) is
 l_package_name             varchar2(30) := 'hrdmd_' ||  p_table_info.short_name;
 l_parameter_string         varchar2(1000);
 l_local_variable_string    varchar2(1000);
 l_indent                   number;
begin


  if upper(p_procedure_name) in ('DOWNLOAD', 'DOWNLOAD_HIERARCHY') then
    l_indent := 4;
    l_parameter_string := '''(p_migration_type - '' || p_migration_type || ' ||
    indent(l_indent + 29) || ''')(p_business_group_id  - ''  || p_business_group_id  ||' ||
    indent(l_indent + 29) || ''')(p_last_migration_date  - ''  || p_last_migration_date  ||' ||
    indent(l_indent + 29) || ''')(p_start_id  - ''  || p_start_id  ||' ||
    indent(l_indent + 29) || ''')(p_end_id  - ''  || p_end_id  ||' ||
    indent(l_indent + 29) || ''')(p_batch_id  - ''  || p_batch_id  || ' ||
    indent(l_indent + 29) || ''')(p_chunk_size  - ''  || p_chunk_size ||' ||
    indent(l_indent + 29) || ''')''';

    l_local_variable_string :=
      ' || ' || '''(l_rec_inserted_cnt  - ''  || l_rec_inserted_cnt ||' ||
      indent(l_indent + 29) || ''')''';

  elsif upper(p_procedure_name) = 'CALCULATE_RANGES' then
    l_indent := 2;
    l_parameter_string := '''(p_business_group_id - '' || p_business_group_id || ' ||
    indent(l_indent + 29) || ''')(p_last_migration_date  - ''  || p_last_migration_date  ||' ||
    indent(l_indent + 29) || ''')(p_phase_item_id  - ''  || p_phase_item_id  ||' ||
    indent(l_indent + 29) || ''')(p_no_of_threads  - ''  || p_no_of_threads  ||' ||
    indent(l_indent + 29) || ''')''';

    if p_table_info.surrogate_primary_key = 'Y'  then
      l_local_variable_string :=
      ' || ' || '''(l_max_key_value  - ''  || l_max_key_value ||' ||
      indent(l_indent + 29) || ''')(l_min_key_value  - ''  || l_min_key_value  ||' ||
      indent(l_indent + 29) || ''')(l_starting_process_sequence  - ''  || l_starting_process_sequence  ||' ||
      indent(l_indent + 29) || ''')(l_ending_process_sequence  - ''  || l_ending_process_sequence  ||' ||
      indent(l_indent + 29) || ''')l_range_value  - ''  || l_range_value  ||' ||
      indent(l_indent + 29) || ''')''';
   end if;

  elsif upper(p_procedure_name) = 'DELETE_DATAPUMP' then
    l_indent := 2;
    l_parameter_string := '''(p_start_id - '' || p_start_id || ' ||
    indent(l_indent + 29) || ''')(p_end_id  - ''  || p_end_id  ||' ||
    indent(l_indent + 29) || ''')(p_batch_id  - ''  || p_batch_id  ||' ||
    indent(l_indent + 29) || ''')(p_chunk_size  - ''  || p_chunk_size  ||' ||
    indent(l_indent + 29) || ''')''';

    l_local_variable_string :=
      ' || ' || '''(l_rec_deleted_cnt  - ''  || l_rec_deleted_cnt ||' ||
      indent(l_indent + 29) || ''')''';

  elsif upper(p_procedure_name) = 'DELETE_SOURCE' then
    l_indent := 2;
    l_parameter_string := '''(p_business_group_id - '' || p_business_group_id || ' ||
    indent(l_indent + 29) || '''(p_start_id - '' || p_start_id || ' ||
    indent(l_indent + 29) || ''')(p_end_id  - ''  || p_end_id  ||' ||
    indent(l_indent + 29) || ''')(p_chunk_size  - ''  || p_chunk_size  ||' ||
    indent(l_indent + 29) || ''')''';

    l_local_variable_string :=
      ' || ' || '''(l_rec_deleted_cnt  - ''  || l_rec_deleted_cnt ||' ||
      indent(l_indent + 29) || ''')''';

  end if;

  if p_message_location = 'START' then
    p_proc_body :=  indent(l_indent) || '-- debug messages ';
    p_proc_body := p_proc_body  ||  indent(l_indent) ||
                   'hr_dm_utility.message(''ROUT'',''entry:' || l_package_name ||
                   '.' ||  p_procedure_name || ''', 5);' || indent(l_indent);

    p_proc_body := p_proc_body  ||  'hr_dm_utility.message(''PARA'','
        || l_parameter_string || ', 10);';

  end if;


  if p_message_location = 'END' then
    p_proc_body :=  indent(2) || '-- debug messages ';

    -- procedure specific debug messages.

    if upper(p_procedure_name) in ('DOWNLOAD', 'DOWNLOAD_HIERARCHY') then
      p_proc_body := p_proc_body ||indent(2) ||
       'hr_dm_utility.message(''INFO'',''Number Of records downloaded '' || ' ||
       indent( l_indent + 27) ||'''(l_rec_inserted_cnt) : '' || ' ||
       'l_rec_inserted_cnt , 15);';

    elsif upper(p_procedure_name) = 'CALCULATE RANGES' then
      p_proc_body := p_proc_body ||indent(2) ||
       'hr_dm_utility.message(''INFO'',''Range Value '' || ' ||
       indent( l_indent + 27) ||'''(l_range_value) : '' || ' ||
       'l_range_value , 15);';

    elsif upper(p_procedure_name) in ('DELETE_SOURCE', 'DELETE_DATAPUMP') then
      p_proc_body := p_proc_body ||indent(2) ||
       'hr_dm_utility.message(''INFO'',''Number Of records deleted '' || ' ||
       indent( l_indent + 27) ||'''(l_rec_deleted_cnt) : '' || ' ||
       'l_rec_deleted_cnt , 15);';
    end if;

    p_proc_body := p_proc_body ||indent(2) ||
                    'hr_dm_utility.message(''ROUT'',''exit:' || l_package_name ||
                   '.' ||  p_procedure_name || ''', 25);';

    p_proc_body := p_proc_body  ||   indent || 'exception' ||
      indent(2) || 'when others then ' || indent(4) ||
     'hr_dm_utility.error(SQLCODE,''' || l_package_name || '.' ||
      p_procedure_name || ''', ' || indent(l_indent + 29) ||  l_parameter_string ||
      l_local_variable_string || ',''R'');' || indent(2) || ' raise;' ||
      indent || 'end ' || p_procedure_name|| ';';
  end if;

  hr_dm_utility.message('PARA','(p_proc_body_tbl - table of varchar2' ,10);

  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.add_debug_messages',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.add_debug_messages',
                        '(none)','R');
     raise;
end add_debug_messages;
-- -----------------------add_to_package_body; ---------------------------------
-- Description:
-- This procedure will be called by each procedure to be created by TUPS.
-- Each procedure will be stored in the array of varchar2(32767).
-- The input to this procedure is pl/sql table i.e array of string.
-- Now the task of this procedure is to split the above array elements into
-- array elements of size 256. This is required so as to the package body
-- of more than 32 K size can be parsed using dbms_sql procedure.
--
-- ------------------------------------------------------------------------

procedure add_to_package_body
(
 p_proc_body_tbl  t_varchar2_32k_tbl
) is

 l_proc_index    number := p_proc_body_tbl.first;
 l_string_index  number;  -- variable to read the string characters
 l_loop_cnt      number;
begin

  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.add_to_package_body-1', 5);
  hr_dm_utility.message('PARA','(p_proc_body_tbl - table of varchar2' ,10);

  while l_proc_index is not null loop

   l_string_index := 1;
   l_loop_cnt     := 1;
    -- read the string of the procedure body and chop it into the array element
    -- size of 256 and store it into the global package body. Each looping will
    -- will read the 256 characters from the procedure body and it will go on
    -- until no more characters to read.
   loop
     if substr(p_proc_body_tbl(l_proc_index),l_string_index,256) is null
     then
        exit;
     end if;
     g_package_index  := g_package_index  + 1;

     -- add the procedure body to
     g_package_body (g_package_index) :=
                               substr(p_proc_body_tbl(l_proc_index),
                                      l_string_index ,256);
     l_string_index :=  256*l_loop_cnt + 1;
     l_loop_cnt := l_loop_cnt + 1;
   end loop;

    l_proc_index := p_proc_body_tbl.next(l_proc_index);
  end loop;
  hr_dm_utility.message('INFO',
                        '(l_loop_cnt - ' || l_loop_cnt ||
                        ')(l_string_index - ' ||l_string_index ||
                        ')( g_package_index - ' ||  g_package_index || ')'
                         ,15);
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.add_to_package_body -1',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.add_to_package_body-1',
                        '(l_loop_cnt - ' || l_loop_cnt ||
                        ')(l_string_index - ' ||l_string_index ||
                        ')( g_package_index - ' ||  g_package_index || ')'
                        ,'R');
     raise;
end add_to_package_body;
-- ----------------------- get_derive_from_clause -------------------------
-- Description:
-- Uses the derive_sql_source_tables info stored in HR_DM_TABLES to form the
-- 'from clause'.
-- The from clause stored in each derive field will be in the following format :
--   table1 tbl,:table2 tbl2, :table3   tbl3
--   where ':' is the next line indicator  i.e : will be replaced with new line.
--   o If 'from' string is not there it puts the from string.
-- ------------------------------------------------------------------------------
procedure get_derive_from_clause
(
  p_table_info       in     hr_dm_gen_main.t_table_info,
  p_from_clause     in out nocopy    varchar2,
  p_lpad_spaces      in     number    default 2
) is
  l_derive_sql     hr_dm_tables.derive_sql_download_full%type;
  l_start_ptr      number;
  l_end_ptr        number;
  l_where_string   varchar2(25) := 'where';
  l_terminator     varchar2(5) := ';';
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.get_derive_from_clause', 5);
  hr_dm_utility.message('PARA','(p_from_clause - ' || p_from_clause ||
                             ')(p_lpad_spaces - ' || p_lpad_spaces ||
                             ')', 10);
  l_derive_sql := p_table_info.derive_sql_source_tables;


  -- if 'where' string is not there then add the where string.
  if instr(lower(l_derive_sql),'from')  <= 0 then
     p_from_clause := '  from ';
  end if;

  l_end_ptr := instr(l_derive_sql,':') - 1;
  -- read the where clause string until first ':' . add the new line and chop
  -- the where clause string upto ':' character. Continue this process until
  -- full where clause is formatted.
  loop

    p_from_clause := p_from_clause || substr(l_derive_sql,1,
                                                l_end_ptr) || indent(p_lpad_spaces + 5);
    -- remove the characters from where clause which have been appended in
    -- the where clause.
    l_derive_sql := substr(l_derive_sql,l_end_ptr + 2);
    --
    l_end_ptr := instr(l_derive_sql,':') - 1;

    if l_end_ptr <= 0  or l_end_ptr is null then
       p_from_clause := p_from_clause || l_derive_sql;
       exit;
    end if;
  end loop;

  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.get_derive_from_clause',
                         25);
  hr_dm_utility.message('PARA','(p_from_clause - ' || p_from_clause || ')',30);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.get_derive_from_clause',
                        '(l_derive_sql - ' || l_derive_sql ||
                        ')(l_end_ptr - ' || l_end_ptr ||
                        ')(p_from_clause - ' || p_from_clause || ')'
                        ,'R');
     raise;
end get_derive_from_clause;
---
-- ----------------------- get_cursor_from_clause -------------------------
-- Description:
-- Get the list of all the tables required to get the download from clause.
-- if the business group_id field does not exist in the table to be downloaded
-- then it is derived from the table hierarchy table.
-- ------------------------------------------------------------------------
procedure get_cursor_from_clause
(
  p_table_info       in     hr_dm_gen_main.t_table_info,
  p_from_clause      out nocopy    varchar2 ,
  p_lpad_spaces      in     number default 2
) is

l_parent_table_info     hr_dm_gen_main.t_table_info;

-- get all parent tables required to get the business group id, if business
-- group id is not there in the table to be downloaded.

cursor csr_get_table is

       select distinct parent_table_id
       from  (select table_id,parent_table_id
              from hr_dm_hierarchies
              where hierarchy_type = 'PC')
              start with table_id = p_table_info.table_id
              connect by prior parent_table_id = table_id;
begin

    hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.get_cursor_from_clause', 5);

    -- check if the from clause is defined for this table i.e
    -- derive_sql_source_tables field is not null. If yes then
    -- call get_derive_from_clause procedure to format the from
    -- clause defined in the table.

    if p_table_info.derive_sql_source_tables is not null then
      get_derive_from_clause ( p_table_info   => p_table_info,
                               p_from_clause => p_from_clause,
                               p_lpad_spaces  => p_lpad_spaces);
      return;
    end if;

    p_from_clause := lpad(' ',p_lpad_spaces) ||'from  ' ||
    p_table_info.table_name || '  ' || p_table_info.alias;

    -- if the table to be downloaded has table hierarchy i.e business group id
    -- has to be derived from table hierarchy i.e parent tables.
    if p_table_info.table_hierarchy = 'Y'  and p_table_info.global_data = 'N' then
      for cst_get_table_rec in csr_get_table loop
        -- get the parent table name
        hr_dm_library.get_table_info (cst_get_table_rec.parent_table_id,
                                      l_parent_table_info);
        p_from_clause := p_from_clause || indent(p_lpad_spaces + 5) || ',' ||
         l_parent_table_info.table_name ||'  ' || l_parent_table_info.alias;
      end loop;
    end if;
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.get_cursor_from_clause',
                         25);
  hr_dm_utility.message('PARA','(p_from_clause - ' || p_from_clause,30);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.get_cursor_from_clause',
                         '(none)','R');
     p_from_clause := null;
     raise;
end get_cursor_from_clause;

-- ----------------------- get_derive_where_clause -------------------------
-- Description:
-- Uses the derive_sql info stored in HR_DM_TABLES for each type of cursors.
-- The where clause stored in each derive field will
--   example derive where clause :
-- where tbl.col1 = tbl2.col1 : and tbl.col2 = tbl1.col2 : and tbl.col3 = tbl3.col3
--  Above derive where clause will be converted as
--      where tbl.col1 = tbl2.col1
--      and tbl.col2 = tbl1.col2
--      and tbl.col3 = tbl3.col3
--  by this procedure. replace ':' by newline feed.
--  o may or may not include the 'where' string. If the 'where' string is not
--    there this procedure will put the 'where' string
--  o may or may not have the where clause terminator ';'. If it is not there
--    it will add it.
--  o the next line indicator will be ':' i.e : will be replaced with new line.
--  p_cursor_type  :-  'DOWNLOAD' - where clause for full download
--                     'DOWNLOAD_DT' - where clause for date track table additive
--                                     download
--                     'CALCULATE_RANGES' - where clause for calculated ranges
--                     'DELETE_SOURCE'    - where clause for delete source
-- ------------------------------------------------------------------------------
procedure get_derive_where_clause
(
  p_table_info       in     hr_dm_gen_main.t_table_info,
  p_where_clause     in out nocopy    varchar2,
  p_cursor_type      in     varchar2  default 'DOWNLOAD',
  p_lpad_spaces      in     number    default 2
) is
  l_derive_sql     hr_dm_tables.derive_sql_download_full%type;
  l_start_ptr      number;
  l_end_ptr        number;
  l_where_string   varchar2(25) := 'where ';
  l_terminator     varchar2(5) := ';';
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.get_derive_where_clause', 5);
  hr_dm_utility.message('PARA','(p_cursor_type- ' || p_cursor_type ,10);

  if p_cursor_type = 'DOWNLOAD' then
    l_derive_sql := p_table_info.derive_sql_download_full;
  elsif p_cursor_type = 'DOWNLOAD_DT' then
    l_derive_sql := p_table_info.derive_sql_download_add;
  elsif p_cursor_type = 'CALCULATE_RANGES' then
    l_derive_sql := p_table_info.derive_sql_calc_ranges;
  elsif p_cursor_type = 'DELETE_SOURCE' then
    l_derive_sql := p_table_info.derive_sql_delete_source;
  end if;

  -- if terminator ';' is there in derive sql then set the terminator to null.
  if instr(l_derive_sql,';')  > 0 then
     l_terminator := null;
  end if;

  -- if 'where' string is not there then add the where string.
  if instr(lower(l_derive_sql),'where')  <= 0 then
     p_where_clause := '  where ';
  end if;

  l_end_ptr := instr(l_derive_sql,':') - 1;
  -- read the where clause string until first ':' . add the new line and chop
  -- the where clause string upto ':' character. Continue this process until
  -- full where clause is formatted.
  loop

    p_where_clause := p_where_clause || substr(l_derive_sql,1,
                          l_end_ptr) || indent(p_lpad_spaces);
    -- remove the characters from where clause which have been appended in
    -- the where clause.
    l_derive_sql := substr(l_derive_sql,l_end_ptr + 2);
    --
    l_end_ptr := instr(l_derive_sql,':') - 1;
    if l_end_ptr <= 0  or l_end_ptr is null then
       p_where_clause := p_where_clause || l_derive_sql;
       exit;
    end if;
  end loop;

  p_where_clause := p_where_clause || l_terminator;
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.get_derive_where_clause',
                         25);
  hr_dm_utility.message('PARA','(p_where_clause - ' || p_where_clause,30);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.get_derive_where_clause',
                         '(none)','R');
     raise;
end get_derive_where_clause;
-- ----------------------- format_selective_where_clause -------------------------
-- Description:
-- Selective criteria is entered by the user and stored in hr_dm_migrations table.
-- The selective string is stored in the following_format
--            A:B:C:D:E
-- The obejective is to to convert the above string as follows
--           'A','B','C','D','E'
-- The above string will be used in the where clause to restrict the data.
-- ------------------------------------------------------------------------------
procedure format_selective_where_clause
(
  p_text             in out nocopy   varchar2,
  p_lpad_spaces      in       number    default 25
) is
  l_in_str           varchar2(32767);
  l_out_str          varchar2(32767);
  l_start_ptr        number;
  l_end_ptr          number;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.format_selective_where_clause', 5);
  hr_dm_utility.message('PARA','(p_text - ' || p_text ,10);

  l_in_str  := p_text;
  l_end_ptr := instr(l_in_str,':') - 1;

  -- read the where clause string until first ':' . add the new line and chop
  -- the where clause string upto ':' character. Continue this process until
  -- full where clause is formatted.
  loop

    if l_end_ptr > 0 then
      l_out_str := l_out_str ||',''' || substr(l_in_str,1,l_end_ptr) ||
                  '''' || indent(p_lpad_spaces);
      -- remove the characters from where clause which have been appended in
      -- the where clause.
      l_in_str := substr(l_in_str,l_end_ptr + 2);
      --
      l_end_ptr := instr(l_in_str,':') - 1;
    end if;

    if l_end_ptr <= 0  or l_end_ptr is null then
       l_out_str := l_out_str || ',''' ||  l_in_str || '''' || indent(p_lpad_spaces);
       exit;
    end if;
  end loop;

  -- the l_where_clause string contains ',' as the first character, hence
  -- the need of using substr function.

  p_text  := '(' || '  ' || substr(l_out_str,2) || ')';
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.format_selective_where_clause',
                         25);
  hr_dm_utility.message('PARA','(p_text - ' || p_text,30);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.format_selective_where_clause',
                         '(none)','R');
     raise;
end format_selective_where_clause;
-- ----------------------- get_gen_cursor_where_clause -------------------------
-- Description:
-- prepares the where clause for the following data to be downloaded:
--    o non date track table data
--    o full migration of date track table data
-- if the business group_id field does not exist in the table to be downloaded
-- then complex joins are to be made with the parent tables. Information about
-- the join is stored in hr_dm_hierarchy table for a given table.
-- The where clause consist of three things
--  a) range of surrogate id  b) last_update_date and c) business_group_id
--  Depending upon the cursor type the where clause will be formed with the above
--  components.
--  p_cursor_type  :-  'DOWNLOAD' - where clause for download procedure
--                      components : (a,b,c)
--                     'CALCULATE_RANGES' - where clause for calculated ranges
--                      components : (b,c)
--                     'DELETE_SOURCE'    - where clause for delete source
--                     components : (a,c)
-- ------------------------------------------------------------------------------
procedure get_gen_cursor_where_clause
(
  p_table_info       in     hr_dm_gen_main.t_table_info,
  p_where_clause     in out nocopy varchar2,
  p_cursor_type      in     varchar2  default 'DOWNLOAD',
  p_lpad_spaces      in     number    default 2
) is

l_parent_table_info     hr_dm_gen_main.t_table_info;
l_selective_criteria    varchar2(8000);

-- get the selective formula criteria
cursor get_sel_formula is
select selective_migration_criteria
from hr_dm_migrations
where migration_id = p_table_info.migration_id
and migration_type = 'SF'
and selective_migration_criteria is not null;

begin

/*
     Following where clause stmt will be created by the assignment below e.g
        where  adr.address_id between p_start_id and p_end_id
        and    adr.last_update_date >= decode(p_migration_type, 'full',
                                             adr.last_update_date,
                                            p_last_update_date)
        adr - table alias name, address_id  -  surrogate primary key.
     Note: it does not have business group_id.

     If cursor is for calculate range then the where clause will not contain
     the first line of the where clause mentioned above.
*/

  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.get_gen_cursor_where_clause ', 5);
  hr_dm_utility.message('PARA','(p_cursor_type - ' || p_cursor_type ||
                                ')', 10);

  -- check if the where clause is defined for this table i.e
  -- derive_sql_download_full field is not null.If yes then
  -- call get_derive_where_clause procedure to format the where
  -- clause defined in the table.

  if p_table_info.derive_sql_download_full is not null then
     get_derive_where_clause ( p_table_info   => p_table_info,
                               p_where_clause => p_where_clause,
                               p_cursor_type  => p_cursor_type,
                               p_lpad_spaces  => p_lpad_spaces);
     return;
  end if;

  --
  -- if it is a table hierarchy then call the implicit business group where
  -- clause package to prepare the where clause, otherwise, create the where
  -- clause.
  if p_table_info.table_hierarchy = 'Y'  and p_table_info.global_data = 'N' then
     hr_dm_imp_bg_where.main (p_table_info   => p_table_info,
                              p_cursor_type  => p_cursor_type,
                              p_query_type   => 'MAIN_QUERY',
                              p_where_clause => p_where_clause);
  else
    -- preparing where clause for explicit business group id.

    p_where_clause := lpad(' ',p_lpad_spaces) || 'where  ';

    -- component range_id and last update date of the where clause

    if p_cursor_type = 'DOWNLOAD' THEN
      --
      -- put the search condition of id between start and end id if the
      -- table has a surrogate id.
      --
      if p_table_info.surrogate_primary_key = 'Y'
      then
        p_where_clause := p_where_clause || p_table_info.alias || '.' ||
        p_table_info.surrogate_pk_column_name || ' between p_start_id and ' ||
        'p_end_id';

      --  p_where_clause := p_where_clause || indent(p_lpad_spaces) ||  'and ';
      end if;

      -- Add the last_update_date comparison in the where clause for non date
      -- track table only.
      -- if the table has a child table with 'L' type hierarchy then the
      -- last_update_date clause is ommitted.

      if (p_table_info.missing_who_info = 'N') and
         (p_table_info.datetrack = 'N') and
         (hr_dm_gen_main.chk_ins_resolve_pk(p_table_info.table_id) = 'N') then

        -- add 'and' if the surrogate id criteria has been applied.

        if p_table_info.surrogate_primary_key = 'Y' then
           p_where_clause := p_where_clause || indent(p_lpad_spaces) ||  'and ';
        end if;

        p_where_clause := p_where_clause || p_table_info.alias
        || '.' ||  'last_update_date >= nvl(p_last_migration_date,' ||
        indent(38) || p_table_info.alias || '.last_update_date)';

     end if;
    elsif p_cursor_type = 'DELETE_SOURCE' THEN
      --
      -- put the search condition of id between start and end id if the
      -- table has a surrogate id.
      --
      if p_table_info.surrogate_primary_key = 'Y'
      then
        p_where_clause := p_where_clause || p_table_info.alias || '.' ||
        p_table_info.surrogate_pk_column_name || ' between p_start_id and ' ||
        'p_end_id' ;

      end if;

    elsif p_cursor_type = 'CALCULATE_RANGES' THEN

      -- Add the last_update_date comparison in the where clause, if table has
      -- WHO columns.
      if p_table_info.missing_who_info = 'N' and
         (hr_dm_gen_main.chk_ins_resolve_pk(p_table_info.table_id) = 'N') then

        p_where_clause :=  p_where_clause ||  p_table_info.alias || '.' ||
        'last_update_date >= nvl(p_last_migration_date,' ||
        indent(38) || p_table_info.alias || '.last_update_date)';
      end if;
    else
      null;
    end if;

    -- component business_group_id of the where clause

    -- put the business group search condition into where clause.
    -- if business group exists in the table then it is simple and if not
    -- then it hass to be derived from the parent table hierarchy information
    -- stored in hierarchy table.

    if p_table_info.table_hierarchy = 'N' then

         -- for explicit business group id, the business group id will not be
         -- in the sub query of date track cursor.

         if p_table_info.global_data = 'N' then
            -- check whether there is any selection criteria already added to this
            -- where clause. If yes then only add the ' and '

            if  ltrim(rtrim(p_where_clause)) <> 'where' then
              p_where_clause := p_where_clause || indent(p_lpad_spaces) ||  'and ';
            end if;

            p_where_clause := p_where_clause ||  p_table_info.alias || '.' ||
            'business_group_id = p_business_group_id' ;
         else
            -- if no criteria has been added to the where clause then remove the
            -- where clause.
            if  ltrim(rtrim(p_where_clause)) = 'where' then
              p_where_clause := null;
            end if;
         end if;
      -- end if; -- not required.
    end if;
  end if;

  -- add the selective migration clause for FF_FORMULAS table
  if lower(p_table_info.table_name) = 'ff_formulas_f' then
    open get_sel_formula;
    fetch get_sel_formula into l_selective_criteria;
    if get_sel_formula%found then
      format_selective_where_clause (p_text => l_selective_criteria);
      p_where_clause := p_where_clause || indent || '  and ' || p_table_info.alias
                        || '.formula_name in ' || l_selective_criteria;
    end if;
    close get_sel_formula;
  end if;

  -- add the order by clause for datetrack table
  if p_table_info.datetrack = 'Y'
     and p_cursor_type <> 'DELETE_SOURCE' then
    p_where_clause := p_where_clause || indent(p_lpad_spaces) ||
                      'order by ' || p_table_info.alias || '.' ||
                      p_table_info.surrogate_pk_column_name ;
  end if;

  p_where_clause := p_where_clause || ';' ;

  -- if the where clause is empty then remove it
  if p_where_clause ='  where  ;' then
    p_where_clause := '  ;';
  end if;



  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.get_gen_cursor_where_clause',
                         25);
  hr_dm_utility.message('PARA','(p_where_clause - ' || p_where_clause || ')' ,30);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.get_gen_cursor_where_clause',
                         '(none)','R');
     raise;
end get_gen_cursor_where_clause;

-- ----------------------- get_dt_subqry_where_clause -------------------------
-- Description:
-- prepares the where clause for the sub query of the  date track table data to
-- be downloaded.
-- if the business group_id field does not exist in the table to be downloaded
-- then complex joins are to be made with the parent tables. Information about
-- the join is stored in hr_dm_hierarchy table for a given table.
-- The where clause consist of three things
--  a) range of surrogate id  b) last_update_date and c) business_group_id
--  Depending upon the cursor type the where clause will be formed with the above
--  components.
--  p_cursor_type  :-  'DOWNLOAD' - where clause for download procedure
--                      components : (a,b,c)
--                     'CALCULATE_RANGES' - where clause for calculated ranges
--                      components : (b,c)
--                     'DELETE_SOURCE'    - where clause for delete source
--                     components : (c)
-- ------------------------------------------------------------------------
procedure get_dt_subqry_where_clause
(
  p_table_info       in     hr_dm_gen_main.t_table_info,
  p_where_clause     in out nocopy varchar2,
  p_cursor_type      in     varchar2  default 'DOWNLOAD',
  p_lpad_spaces      in     number    default 2
) is

l_parent_table_info     hr_dm_gen_main.t_table_info;
begin

/*
     Following where clause stmt will be created by the assignment below e.g
        where  adr.last_update_date >= nvl(p_migration_type,
                                             adr.last_update_date)
        adr - table alias name, address_id  -  surrogate primary key.
     Note: it does not have business group_id.

     If cursor is for calculate range then the where clause will not contain
     the first line of the where clause mentioned above.
*/

    -- last update date comparison for additive migration of the where clause

    if (p_table_info.missing_who_info = 'N')  then
      p_where_clause := p_where_clause || indent(17) ||  'and ' ||
                        p_table_info.alias || '.' ||
                        'last_update_date >= nvl(p_last_migration_date,' ||
                        indent(50) || p_table_info.alias || '.last_update_date)';
    end if;

    hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.get_dt_subqry_where_clause',
                         25);
    hr_dm_utility.message('PARA','(p_where_clause - ' || p_where_clause
                         || ')' ,30);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.get_dt_subqry_where_clause',
                         '(none)','R');
     raise;
end get_dt_subqry_where_clause;


-- ----------------------- get_dt_cursor_where_clause -------------------------
-- Description:
-- prepares the where clause for the date track table data to to be downloaded.
-- if the business group_id field does not exist in the table to be downloaded
-- then complex joins are to be made with the parent tables. Information about
-- the join is stored in hr_dm_hierarchy table for a given table.
-- The where clause consist of three things
--  a) range of surrogate id  b) last_update_date and c) business_group_id
--  Depending upon the cursor type the where clause will be formed with the above
--  components.
--  p_cursor_type  :-  'DOWNLOAD' - where clause for download procedure
--                      components : (a,b,c)
-- ------------------------------------------------------------------------
procedure get_dt_cursor_where_clause
(
  p_table_info       in     hr_dm_gen_main.t_table_info,
  p_where_clause     out nocopy    varchar2,
  p_cursor_type      in     varchar2  default 'DOWNLOAD',
  p_lpad_spaces      in     number    default 2
) is

l_sub_from_clause    varchar2(32767);
l_sub_where_clause   varchar2(32767);
l_selective_criteria varchar2(32767);

-- get the selective formula criteria
cursor get_sel_formula is
select selective_migration_criteria
from hr_dm_migrations
where migration_id = p_table_info.migration_id
and migration_type = 'SF'
and selective_migration_criteria is not null;


begin

/*
     Following where clause stmt will be created by the assignment below e.g
    where  ff1.formula_id between p_start_id and p_end_id
    and    ff1.business_group_id = p_business_group_id -- only if table has
                                        -- explicit business_group_id
    and    exists ( select 1
                    from avt_ff_formulas ff
                    where ff.formula_id = ff1.formula_id
                    and   ff.last_update_date >= NVL(p_last_migration_date,
                                                       ff1.last_update_date)
                   );
     Note: it does not have business group_id.

     If cursor is for calculate range then the where clause will not contain
     the first line of the where clause mentioned above.
*/

  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.get_dt_cursor_where_clause ', 5);
  hr_dm_utility.message('PARA','(p_cursor_type - ' || p_cursor_type ||
                                ')', 10);

  -- check if the where clause is defined for this table i.e
  -- derive_sql_download_full field is not null.If yes then
  -- call get_derive_where_clause procedure to format the where
  -- clause defined in the table.

  if p_table_info.derive_sql_download_full is not null then
     get_derive_where_clause ( p_table_info   => p_table_info,
                               p_where_clause => p_where_clause,
                               p_cursor_type  => 'DOWNLOAD_DT',
                               p_lpad_spaces  => p_lpad_spaces);
     return;
  end if;
  --
  -- if it is a table hierarchy then call the implicit business group where
  -- clause package to prepare the where clause, otherwise, create the where
  -- clause.
  if p_table_info.table_hierarchy = 'Y' then
     hr_dm_imp_bg_where.main (p_table_info   => p_table_info,
                              p_cursor_type  => p_cursor_type,
                              p_query_type   => 'SUB_QUERY',
                              p_where_clause => p_where_clause);
  else

   p_where_clause := lpad(' ',p_lpad_spaces) || 'where ';

   -- put the search condition of id between start and end id.

   if p_table_info.surrogate_primary_key = 'Y'
   then
      p_where_clause := p_where_clause || p_table_info.alias || '1.' ||
      p_table_info.surrogate_pk_column_name || ' between p_start_id and ' ||
      'p_end_id';

      p_where_clause := p_where_clause || indent(p_lpad_spaces) ||  'and   ';
   end if;

   -- if business group id field exists in the table then put the business
   -- group condition in the main query

   if p_table_info.table_hierarchy = 'N'  and
      p_table_info.global_data = 'N'
   then
      -- derive business group id search condition from parent tables.
      p_where_clause := p_where_clause ||  p_table_info.alias || '1.' ||
      'business_group_id = p_business_group_id';

     p_where_clause := p_where_clause || indent(p_lpad_spaces) ||  'and ';
   end if;


   -- add the selective migration clause for FF_FORMULAS table
   if lower(p_table_info.table_name) = 'ff_formulas_f' then
     open get_sel_formula;
     fetch get_sel_formula into l_selective_criteria;
     if get_sel_formula%found then
       format_selective_where_clause (p_text => l_selective_criteria);
       p_where_clause := p_where_clause || p_table_info.alias
                        || '1.formula_name in ' || l_selective_criteria ||
                        indent(p_lpad_spaces) ||  'and ';
     end if;
     close get_sel_formula;
   end if;


   -- prepare the sub query.
   p_where_clause := p_where_clause || '  exists ( select 1';

   -- get the from clause for sub query
   get_cursor_from_clause (p_table_info  => p_table_info,
                           p_from_clause => l_sub_from_clause,
                           p_lpad_spaces => 17);

    -- get the where clause for sub query
   l_sub_where_clause :=  lpad(' ',17) || 'where ';

   l_sub_where_clause := l_sub_where_clause || p_table_info.alias || '1.'||
   p_table_info.surrogate_pk_column_name || ' = '|| p_table_info.alias
    || '.'|| p_table_info.surrogate_pk_column_name;


   -- get the where clause of sub query.
   get_dt_subqry_where_clause (p_table_info   => p_table_info,
                               p_where_clause => l_sub_where_clause,
                               p_cursor_type  => p_cursor_type,
                               p_lpad_spaces  => 17);
/*
    p_where_clause := p_where_clause || indent ||
                      l_sub_from_clause || indent ||
                      l_sub_where_clause || indent(16)  || ')' ||
                      indent(2) || 'order by ' ||
                      p_table_info.surrogate_pk_column_name  || ';';
p_cursor_type
*/
    p_where_clause := p_where_clause || indent ||
                      l_sub_from_clause || indent ||
                      l_sub_where_clause || indent(16)  || ')';

    if p_cursor_type <> 'DELETE_SOURCE' then
      p_where_clause := p_where_clause || indent(2) || 'order by ' ||
                      p_table_info.surrogate_pk_column_name  || ';';
    else
      p_where_clause := p_where_clause || ';';
    end if;


  end if;
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.get_dt_cursor_where_clause',
                         25);
  hr_dm_utility.message('PARA','(p_where_clause - ' || p_where_clause ||
                                 ')' ,30);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.get_dt_cursor_where_clause',
                         '(none)','R');
     raise;
end get_dt_cursor_where_clause;


-- ----------------------- prepare_download_cursor --------------------------------
-- Description:
-- Preapre the cursor for download data.
-- The download cursor fall into two categories.
--   o Non date track table download (Full and Additive migration) and
--     Date Track Full migration. Cursor where clause is same for both types.
--   o Date Track table Additive migration. In this type the objective is to
--     fetch all the physical records of the logical record if one or more
--     physical records matches the criteria. So subquery is used to achieve
--     this objective.
-- Input Parameters :
--      p_cursor_type  - It can have following values :
--           FULL_BG_MIGRATION - full business group migration for date track
--                               and non date track table.
--           ADDITIVE_BG_MIGRATION : Additive business group id for date track
--           table only as for non date track the cursor for full or additive
--           migration is same.
-- ------------------------------------------------------------------------
procedure prepare_download_cursor
(
  p_table_info       in     hr_dm_gen_main.t_table_info,
  p_cursor           out nocopy    varchar2,
  p_cursor_type      in     varchar2 default 'FULL_BG_MIGRATION',
  p_hier_column      in     varchar2 default 'N'
)
is
  l_cursor_comment       varchar2(2000);
  l_cursor_defination    varchar2(2000);
  l_cursor_select_cols   varchar2(32767);
  l_cursor_select_from   varchar2(32767);
  l_cursor_select_where  varchar2(32767);
  l_columns_tbl          hr_dm_library.t_varchar2_tbl;
  l_prefix_col           varchar2(30);

begin

  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.prepare_download_cursor ', 5);
  hr_dm_utility.message('PARA','(p_cursor_type - ' || p_cursor_type ||
                                ')(p_hier_column - ' || p_hier_column, 10);
  if p_hier_column = 'Y' then
     l_columns_tbl :=  g_hier_columns_tbl;
  else
     l_columns_tbl :=  g_columns_tbl;
  end if;

  -- comments about the cursor
  l_cursor_comment := indent || '--' || indent ||
                      '-- cursor to select the data from the ' ||
                     p_table_info.table_name || ' table to be migrated.' ||
                      indent || '--';

  -- comment and definition of cursor
  if p_cursor_type = 'FULL_BG_MIGRATION' then
    if p_table_info.datetrack = 'Y' then
      l_cursor_comment := format_comment(' cursor to select the data from the '
      || p_table_info.table_name || ' for FULL business group migration.',2 );
      l_cursor_defination := ' cursor csr_full_mig_' || p_table_info.alias ||
                             ' is ';
    else
      l_cursor_comment := format_comment(' cursor to select the data from the '
      || p_table_info.table_name || ' table to be migrated.',2);
      l_cursor_defination := ' cursor csr_mig_' || p_table_info.alias || ' is ';
    end if;
  else
    l_cursor_comment := format_comment(' cursor to select the data from the '
    || p_table_info.table_name || ' for ADDITIVE business group migration.',2 );
    l_cursor_defination := ' cursor csr_adt_mig_' || p_table_info.alias ||
                           ' is ';
  end if;
  --
  -- for normal main query the column name will be alias.col1,alias.col2 but
  -- for sub query it will be alias1.col1,alias1.col2
  --
  if p_cursor_type = 'FULL_BG_MIGRATION' then
    l_prefix_col :=  p_table_info.alias || '.';
  else
    l_prefix_col :=  p_table_info.alias || '1.';
  end if;

  -- select columns in the cursor. This will return the list of all columns
  -- of the table separated by comma's.



  l_cursor_select_cols := hr_dm_library.conv_list_to_text( p_rpad_spaces => 8,
                                    p_columns_tbl => l_columns_tbl,
                                    p_prefix_col => l_prefix_col);

  -- Key combination tables have foreign key on AOL table
  --  'FND_ID_FLEX_STRUCTURES' i.e hierarchy_type = 'A'. To identify
  -- the business group for a row in these tables it is required to
  -- check whether the ID value of the row is used by any of the
  -- child tables. The 'Where' clause generated by this generator
  -- does not use the 'exists' clause which results in the same row
  -- being fetch equals to the number of child rows it matches. To
  -- avoid this ' distinct' clause is added for only these tables.
  -- If the 'distinct' clause causes the performance problem then
  -- remove it and seed the derive_sql columns in HR_DM_TABLES for
  -- these tables.

  hr_dm_utility.message('INFO','Distinct form for ' || p_table_info.table_name, 25);
  hr_dm_utility.message('INFO','p_table_info.use_distinct - ' || p_table_info.use_distinct, 25);
  hr_dm_utility.message('INFO','p_table_info.use_distinct_download - ' || p_table_info.use_distinct_download, 25);

  if (p_table_info.use_distinct = 'Y')
    or
     (p_table_info.use_distinct_download = 'Y') then
     l_cursor_select_cols := '  select distinct ' || l_cursor_select_cols;
     hr_dm_utility.message('INFO','Using distinct form', 25);
  else
     l_cursor_select_cols := '  select ' || l_cursor_select_cols;
     hr_dm_utility.message('INFO','Not using distinct form', 25);
  end if;


  if p_cursor_type = 'FULL_BG_MIGRATION' then
    -- get from clause
    get_cursor_from_clause (p_table_info  => p_table_info,
                           p_from_clause => l_cursor_select_from);

    -- get where clause
    get_gen_cursor_where_clause (p_table_info   => p_table_info,
                                 p_where_clause => l_cursor_select_where);


  else  -- date track table additive migration cursor.
    -- get from clause
    l_cursor_select_from := '  from ' || p_table_info.table_name || ' ' ||
                            p_table_info.alias || '1';

    -- get where clause for date track
    get_dt_cursor_where_clause (p_table_info   => p_table_info,
                                 p_where_clause => l_cursor_select_where);


  end if;

  -- finally put the components of where clause together
  p_cursor := l_cursor_comment      || indent ||
              l_cursor_defination   || indent ||
              l_cursor_select_cols  || indent ||
              l_cursor_select_from  || indent ||
              l_cursor_select_where || indent;

  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.prepare_download_cursor',
                         25);
  hr_dm_utility.message('PARA','(p_cursor - ' || p_cursor || ')' ,30);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.prepare_download_cursor',
                         '(none)','R');
     raise;
end prepare_download_cursor;
-- ----------------------- prepare_dt_private_procedures ------------------
-- Description:
-- Define private procedures to open and fetch cursors depending
-- upon the migration type i.e full or additive  for datetrack tables.
-- ------------------------------------------------------------------------

procedure prepare_dt_private_procedures
(
  p_table_info       in     hr_dm_gen_main.t_table_info,
  p_body             out nocopy    varchar2
) is
 l_proc_body          varchar2(32767) := null;
 l_indent             number;
 l_full_mig_csr_name  varchar2(30) := 'csr_full_mig_' || p_table_info.alias;
 l_adt_mig_csr_name   varchar2(30) := 'csr_adt_mig_' || p_table_info.alias;

begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.prepare_dt_private_procedures ', 5);

 l_indent := 2;

 -- write the code for privte procedure open_cursor.
 l_proc_body := format_comment('Private procedure to open the cursor depending '
 || 'upon the migration type  i.e full or additive', l_indent);

 --
 -- define the private procedure open_cursor
 --
 l_proc_body := l_proc_body  || indent(l_indent) ||
 'procedure private_open_cursor is' ||  indent(l_indent) || 'begin';

 --
 -- define the  body of private procedure open_cursor.
 --

 l_indent := 4;
 l_proc_body := l_proc_body || indent(l_indent) ||
 'if p_last_migration_date is null then ' ||
  format_comment('Open cursor for a Full Migration of a business group',
  l_indent + 2,'N') || indent(l_indent + 2) ||
 'open csr_full_mig_' || p_table_info.alias || ';' || indent(l_indent) ||
 'else   -- additive migration' || indent(l_indent + 2) ||
 format_comment('Open cursor for a Additive Migration of a business group'
                , l_indent + 2, 'N') || indent(l_indent + 2) ||
 'open csr_adt_mig_' || p_table_info.alias || ';' || indent(l_indent) ||
 'end if;';

 l_indent := 2;
 l_proc_body := l_proc_body || indent(l_indent) ||'end private_open_cursor;';

 --
 -- define the private procedure fetch_cursor
 --

 l_proc_body := l_proc_body || indent(l_indent) ||
 format_comment('Fetch another row from the cursor depending upon migration '
 || 'type.', l_indent);

 l_proc_body := l_proc_body  || indent(l_indent) ||
 'procedure private_fetch_cursor is' ||  indent(l_indent) || 'begin';

 --
 -- define the  body of private procedure fetch_cursor.
 --

 l_indent := 4;

 l_proc_body := l_proc_body ||  indent(l_indent) ||
 'if p_last_migration_date is null then ' ||
 format_comment('Fetch a row from the full migration cursor.', l_indent + 2) ||
 indent(l_indent + 2) ||
 'fetch '|| l_full_mig_csr_name || ' into l_table_rec;' || indent(l_indent +2) ||
 'if ' || l_full_mig_csr_name || '%found then' || indent(l_indent +4) ||
 'l_row_fetched := TRUE;' || indent(l_indent +2) ||
 'else -- no row fetched' || indent(l_indent +4) ||
 'l_row_fetched := FALSE;' || indent(l_indent +4) ||
 'close ' || l_full_mig_csr_name || ';' || indent(l_indent +2) || 'end if;' ||
  indent(l_indent) || 'else   -- additive migration' || indent(l_indent + 2)
  || format_comment('Fetch a row from the additive migration cursor',
  l_indent + 2)||  indent(l_indent + 2) ||
 'fetch '|| l_adt_mig_csr_name || ' into l_table_rec;' || indent(l_indent +2) ||
 'if ' || l_adt_mig_csr_name || '%found then' || indent(l_indent +4) ||
 'l_row_fetched := TRUE;' || indent(l_indent +2) ||
 'else -- no row fetched' || indent(l_indent +4) ||
 'l_row_fetched := FALSE;' || indent(l_indent +4) ||
 'close ' || l_adt_mig_csr_name || ';' || indent(l_indent +2) || 'end if;' ||
 indent(l_indent) || 'end if;';

 l_proc_body := l_proc_body|| indent(2) || 'end private_fetch_cursor;';

 p_body := l_proc_body;

 hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.prepare_dt_private_procedures',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.prepare_dt_private_procedures',
                         '(none)','R');
     raise;
end  prepare_dt_private_procedures;
-- ----------------------- nullify_hierarchical_cols -----------------------
-- Description:
-- Generates the text which assigns null values to the hierarchical columns.
--    hier_col1 := null;
--    hier_col2 := null;
-- ------------------------------------------------------------------------
procedure nullify_hierarchical_cols
(
  p_table_info       in     hr_dm_gen_main.t_table_info,
  p_lpad_spaces      in     number,
  p_body             out nocopy varchar2
)
is
l_list_index   number;
l_count        number;

begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.nullify_hierarchical_cols ', 5);

 -- initialise the variables
 l_list_index := g_hier_columns_tbl.first;
 l_count      := 1;

 p_body := rpad(' ', p_lpad_spaces) || indent ||
           format_comment('assign null values to hierarchical columns',p_lpad_spaces)
           || indent;

 -- read the hierarchy columns one by one and set them to null except the
 -- surrogate id.

 while l_list_index is not null loop
   --
   -- do not nullify the surrogate_id
   --
   if g_hier_columns_tbl(l_list_index) <> p_table_info.surrogate_pk_column_name
   then
      p_body := p_body || indent(p_lpad_spaces) || 'l_table_rec.' ||
                g_hier_columns_tbl(l_list_index) || ' := null;';
   end if;

   l_list_index := g_hier_columns_tbl.next(l_list_index);
   l_count := l_count + 1;
 end loop;
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.nullify_hierarchical_cols',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.nullify_hierarchical_cols',
                         '(none)','R');
     raise;
end nullify_hierarchical_cols;

-- ----------------------- generate_get_link_value -----------------------
-- Description:
-- Generates the get link value from the sequence procedure of the TDS
-- ------------------------------------------------------------------------
procedure generate_get_link_value
(
  p_table_info       in     hr_dm_gen_main.t_table_info
)
is
  l_interface    varchar2(32767);
  l_locals       varchar2(32767) := null;
  l_cursor       varchar2(32767) := null;
  l_proc_comment varchar2(4000);
  l_cursor_name  varchar2(30) := 'csr_get_link_value';

  -- block body of the procedure i.e between begin and end.
  l_proc_body   varchar2(32767) := null;

  -- indentation for the statements.it specifies number of blank spaces
  -- after which the staement should start.

  l_indent                  number;
  l_proc_body_tbl           t_varchar2_32k_tbl;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.generate_get_link_value ', 5);
  -- input parameters for the procedure

  l_interface :=  indent || '(p_link_value   out nocopy number)' || indent;

  -- local variables of the procedure

  l_locals := indent || '  --' || indent ||
              '  -- Declare cursors and local variables' || indent ||
              '  --' || indent ||
              '  l_proc                     varchar2(72) := g_package ' ||
              '|| ''get_link_value'';' || indent ||
              '  l_link_value               number;' || indent;

  -- cursor to get the link value from the sequence from the data pump table
  l_cursor := format_comment('Cursor to get the link value from the link '||
                              'value sequence.');

  l_cursor := l_cursor || indent || '  cursor csr_get_link_value is select '
               || 'hr_dm_link_value_s.nextval' || indent ||
              '                             from dual;';
  -- add the logic of the body

  l_indent := 2;

  l_proc_body := l_proc_body || indent(l_indent) ||
  'open ' || l_cursor_name || ';' || indent(l_indent) || 'fetch ' ||
  l_cursor_name || ' into l_link_value;' || indent(l_indent) ||
  'close ' || l_cursor_name || ';' || indent(l_indent)  ||
  ' p_link_value := l_link_value;';

  l_proc_body := l_proc_body || indent || 'end get_link_value;';


  l_proc_comment := format_comment('procedure to get the link value from the '
  || 'link sequence. Physical records of a date track logical record will ' ||
  ' have same link value so as to enable the processing of logical record by '
  || 'single thread while uploading. Used by Data Pump.') || indent;


  -- add the procedure comment,local variables , cursor and procedure body to
  -- complete the procedure

  l_proc_body_tbl(1)  :=  l_proc_comment || 'procedure get_link_value' ||
             l_interface || ' is' || l_locals || l_cursor || indent ||
            'begin' || indent || l_proc_body;

 -- add the body of this procedure to the package.
 add_to_package_body( l_proc_body_tbl );
 hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.generate_get_link_value',
                         25);

exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.generate_get_link_value',
                         '(none)','R');
     raise;
end generate_get_link_value;

-- ----------------------- generate_developer_key_func -----------------------
-- Description:
-- This function will
--    - Generates the procedure which will get the developer key from the
--      AOL table for the column which have a foreign key to AOL table.
--    - Creates a call to the function to get the developer key
--      for the column value which has a foreign key on AOL table.
--    - Creates a local variable for the developer key.
--
-- This procedure will generate the function for each column which have a
-- foreign key to AOL table.
-- Assumption :  Id value is assumed to be number and developer key is assumed
--               to be varchar2.
--  Input Parameters
--      p_fk_to_aol_columns_tbl - Contains the information about all the columns
--                                which have foreign key to AOL table.
--      p_table_info            - Contains the info about the table to be
--                                downloaded
--  Out Parameters
--      p_body                  - returns the actual procedure body for getting
--                                the
--      p_call_to_proc_body     - returns the string for a call to the function
--      p_dev_key_local_var_body - returns the string defining local var for
--                                 developer key
-- ------------------------------------------------------------------------
procedure generate_developer_key_func
(
  p_fk_to_aol_columns_tbl    in     hr_dm_gen_main.t_fk_to_aol_columns_tbl,
  p_table_info               in     hr_dm_gen_main.t_table_info,
  p_call_to_proc_body        in out nocopy varchar2,
  p_dev_key_local_var_body   in out nocopy varchar2
)
is
  l_interface    varchar2(32767);
  l_locals       varchar2(32767) := null;
  l_cursor       varchar2(32767) := null;
  l_where_clause varchar2(32767) := null;
  l_proc_comment varchar2(4000);
  l_cursor_name  varchar2(30) := 'csr_get_developer_key';
  l_proc_name    varchar2(32767);

  -- variables to store the information about p_fk_to_aol_columns_tbl elements.
  -- this is to reduce the variable name and add clarity.

  l_column_name               hr_dm_hierarchies.column_name%type;
  l_parent_table_id           hr_dm_hierarchies.parent_table_id%type;
  l_parent_table_name         hr_dm_tables.table_name%type;
  l_parent_table_alias        hr_dm_tables.table_alias%type;
  l_parent_column_name        hr_dm_hierarchies.parent_column_name%type;
  l_parent_id_column_name     hr_dm_hierarchies.parent_id_column_name%type;


  -- block body of the procedure i.e between begin and end.
  l_proc_body   varchar2(32767) := null;

  -- indentation for the statements.it specifies number of blank spaces
  -- after which the staement should start.

  l_indent                  number;
  l_index    number := p_fk_to_aol_columns_tbl.first;
  l_proc_body_tbl           t_varchar2_32k_tbl;
  l_code                    varchar2(4);
  l_table                   varchar2(30);
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.generate_developer_key_func ', 5);
  hr_dm_utility.message('PARA','(p_fk_to_aol_columns_tbl - table of varchar2)', 10);

  -- generate the function to get the developer key for each of the column
  -- which has a foreign key on AOL table.

  while l_index is not null loop

    l_column_name    :=
                   p_fk_to_aol_columns_tbl(l_index).column_name;
    l_parent_table_id    :=
                   p_fk_to_aol_columns_tbl(l_index).parent_table_id;
    l_parent_table_name    :=
                   p_fk_to_aol_columns_tbl(l_index).parent_table_name;
    l_parent_table_alias    :=
                   p_fk_to_aol_columns_tbl(l_index).parent_table_alias;
    l_parent_column_name    :=
                   p_fk_to_aol_columns_tbl(l_index).parent_column_name;
    l_parent_id_column_name    :=
                   p_fk_to_aol_columns_tbl(l_index).parent_id_column_name;

    l_where_clause := l_parent_id_column_name  || ' = ' ||
                      rpad('p_' || l_column_name, 30);

    l_proc_name := 'get_developer_key_frm_' ||   l_parent_table_alias;

    -- input parameters for the procedure
    l_interface :=  indent || '(' ||rpad('p_' || l_column_name, 30) ||
                   ' in  number,' || indent || ' ' ||
                    rpad('p_'|| l_parent_column_name ,30) || ' out nocopy varchar2)';

    -- local variables of the procedure

    l_locals := indent || '  --' || indent ||
              '  -- Declare cursors and local variables' || indent ||
              '  --' || indent ||
              '  l_proc     varchar2(72) := g_package ' ||
              '|| ''' || l_proc_name || ''';' || indent;

    -- cursor to get the link value from the sequence from the data pump table
    l_cursor := format_comment('Cursor to get the developer key from the '||
                l_parent_table_name || ' table.',2);

    if lower(l_parent_column_name) <> 'id_flex_structure_name' then
      l_cursor := l_cursor || indent(2) || 'cursor csr_get_developer_key is ' ||
                'select ' || l_parent_column_name || indent(33) ||
                'from ' || l_parent_table_name ||
                indent(33) || 'where ' || rtrim(l_where_clause) || ';';
    else
    -- for id_flex_num, we need both id_flex_structure_name and
    -- id_flex_code, so download both, concaternated with
    -- -dm-dev-key- as a seperator
      l_table := upper(p_table_info.table_name);
      if (l_table = 'HR_SOFT_CODING_KEYFLEX')
         or
         (l_table = 'HR_DMVP_HR_SOFT_CODING_KEYFLEX') then
        l_code := 'SCL';
      elsif (l_table = 'PAY_COST_ALLOCATION_KEYFLEX') then
        l_code := 'COST';
      elsif (l_table = 'PAY_EXTERNAL_ACCOUNTS') then
        l_code := 'BANK';
      elsif (l_table = 'PAY_PEOPLE_GROUPS') then
        l_code := 'GRP';
      elsif (l_table = 'PER_GRADE_DEFINITIONS') then
        l_code := 'GRD';
      elsif (l_table = 'PER_POSITION_DEFINITIONS') then
        l_code := 'POS';
      elsif (l_table = 'PER_PERSON_ANALYSES')
         or
         (l_table = 'PER_SPECIAL_INFO_TYPES')
         or
         (l_table = 'PER_ANALYSIS_CRITERIA') then
        l_code := 'PEA';
      elsif (l_table = 'PER_JOB_GROUPS')
         or
         (l_table = 'HR_DMV_PER_JOB_GROUPS')
         or
         (l_table = 'PER_JOB_DEFINITIONS') then
        l_code := 'JOB';
      end if;

      l_cursor := l_cursor || indent(2) || 'cursor csr_get_developer_key is ' ||
                'select id_flex_structure_name' ||
                indent(33) || ' || ''-dm-dev-key-' || l_code || '''' ||
                indent(33) || 'from fnd_id_flex_structures_vl' ||
                indent(33) || 'where ' || rtrim(l_where_clause) ||
                indent(33) || '  and id_flex_code = ''' || l_code || ''';';
    end if;


    -- add the logic of the body

    l_indent := 2;

    l_proc_body :=  indent(l_indent) ||
    'open ' || l_cursor_name || ';' || indent(l_indent) || 'fetch ' ||
    l_cursor_name || ' into ' || rpad('p_'|| l_parent_column_name ,30) || ';' ||
    indent(l_indent) ||
    'if ' || l_cursor_name || '%notfound then' || indent(l_indent + 2) ||
    'close ' || l_cursor_name || ';' || indent(l_indent + 2) ||
    'hr_dm_utility.message(''FAIL'',''When obtaining the developer key'' || ' ||
    indent(l_indent + 2) ||
    '  '' from table / view ' || l_parent_table_name || ' no data was found.'' ||' ||
    indent(l_indent + 2) ||
    '  '' check for a null or orphaned data.'',10);' ||
    indent(l_indent + 2) ||
    'hr_utility.raise_error;' || indent(l_indent) || 'else' ||indent(l_indent + 2)
    ||'close ' || l_cursor_name || ';' || indent(l_indent) || 'end if;';


    l_proc_body := l_proc_body || indent || 'end ' || l_proc_name || ';';


    l_proc_comment := format_comment('procedure to get the the developer key '
    || 'from the '|| l_parent_table_name || ' table for ' ||
    l_column_name || ' column.' ) || indent;


    -- add the procedure commentlocal variables , cursor and procedure body to
    -- complete the procedure

     l_proc_body_tbl(1)    :=  l_proc_comment || 'procedure ' || l_proc_name ||
             l_interface || ' is' || l_locals || l_cursor || indent ||
             'begin' ||  indent || l_proc_body;

    -- add the body of this procedure to the package.
    add_to_package_body( l_proc_body_tbl );

    -- construct a call to the procedure created above.
    l_indent := 6;
    p_call_to_proc_body  := p_call_to_proc_body  || indent ||
         format_comment('Get the developer key for ' ||  l_column_name || '.',
                        l_indent);
    p_call_to_proc_body  := p_call_to_proc_body || indent(l_indent) ||
        l_proc_name || '(l_table_rec.' || rpad(l_column_name,28)  || ','  ||
        indent(l_indent + 25) || 'l_' ||  rpad(l_parent_column_name,28) || ');';

    -- construct the defination of local variable
    l_indent := 2;

    -- for id_flex_structure_name of fnd_id_flex_structures_vl
    -- use varchar2(2000) as column type
    -- to allow for encoding of name plus code
    if (l_parent_table_name = 'fnd_id_flex_structures_vl')
      and
       (l_parent_column_name = 'id_flex_structure_name') then
      p_dev_key_local_var_body := p_dev_key_local_var_body || indent(l_indent)
          || 'l_' || rpad(l_parent_column_name,28) || '  varchar2(2000);';
    else
      p_dev_key_local_var_body := p_dev_key_local_var_body || indent(l_indent)
          || 'l_' || rpad(l_parent_column_name,28) || '  ' || l_parent_table_name
          || '.' || l_parent_column_name ||'%type;';
    end if;
    l_index   := p_fk_to_aol_columns_tbl.next(l_index);
  end loop;
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.generate_developer_key_func',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.generate_developer_key_func',
                         '(none)','R');
     raise;
end generate_developer_key_func;

-- ----------------------- generate_download --------------------------------
-- Description:
-- Generates the download procedure of the TDS
-- ------------------------------------------------------------------------
procedure generate_download
(
  p_table_info              in     hr_dm_gen_main.t_table_info,
  p_header                  in out nocopy varchar2,
  p_hier_column             in     varchar2 default 'N',
  p_call_to_proc_body       in     varchar2,
  p_dev_key_local_var_body  in     varchar2,
  p_fk_to_aol_columns_tbl   in     hr_dm_gen_main.t_fk_to_aol_columns_tbl
)
is
  l_interface    varchar2(32767);
  l_locals       varchar2(32767) := null;
  l_cursor       varchar2(32767) := null;
  l_adt_cursor   varchar2(32767) := null;
  l_comment      varchar2(4000);
  l_proc_comment varchar2(4000);
  l_cursor_name  varchar2(30) := 'csr_mig_' || p_table_info.alias;
  l_func_name    varchar2(30) := 'download';
  l_dp_func_name varchar2(100);
  l_null_col     varchar2(30);


  -- block body of the procedure i.e between begin and end.
  l_proc_body            varchar2(32767) := null;
  l_debug_message_text   varchar2(32767) := null;
  l_func_body            varchar2(32767) := null;

  -- block body to store private procedures
  l_prv_proc_body  varchar2(32767) := null;

  -- indentation for the statements.it specifies number of blank spaces
  -- after which the staement should start.

  l_indent                  number;
  l_columns_tbl          hr_dm_library.t_varchar2_tbl;

  l_proc_body_tbl           t_varchar2_32k_tbl;
  l_proc_index              number := 1;

  cursor csr_null_hierarchy is
    select h.column_name
      from hr_dm_hierarchies h,
           hr_dm_tables t
      where h.hierarchy_type = 'N'
        and h.table_id = t.table_id
        and t.table_name = upper(p_table_info.table_name);

begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.generate_download', 5);
  hr_dm_utility.message('PARA','(  p_hier_column   - ' || p_hier_column ||
                                ')', 10);
  if p_hier_column = 'Y' then
     l_columns_tbl  :=  g_hier_columns_tbl;
     l_func_name    := 'download_hierarchy';
     l_dp_func_name := 'hrdpp_h' || p_table_info.short_name || '.insert_batch_lines';
  else
     l_columns_tbl :=  g_columns_tbl;
     l_func_name   := 'download';
     l_dp_func_name := 'hrdpp_u' || p_table_info.short_name || '.insert_batch_lines';
  end if;

  -- input parameters for the procedure

  l_interface :=  indent ||
  '(p_migration_type       in  varchar2,'    || indent ||
  ' p_business_group_id    in  number,'      || indent ||
  ' p_last_migration_date  in  date,'      || indent ||
  ' p_start_id             in  number,'      || indent ||
  ' p_end_id               in  number,'      || indent ||
  ' p_batch_id             in  number,'      || indent ||
  ' p_chunk_size           in  number,'      || indent ||
  ' p_rec_downloaded       out nocopy number)' ||   indent;


  l_proc_body_tbl(l_proc_index) := l_interface;
  l_proc_index := l_proc_index + 1;

  -- message (' l_interface = ' || l_interface);
  -- local variables of the procedure

  l_locals := indent ||
              '  -- Declare local variables' || indent ||
              '  l_proc                         varchar2(72) := g_package ' ||
              '|| ''' || l_func_name || ''' ;' || indent ||
              '  l_link_value                   number;' || indent ||
              '  l_rec_inserted_cnt             number := 0;' || indent ||
              '  l_row_fetched                  boolean := FALSE;' || indent;

  -- if table has a column which have foreign key to the AOL table then create
  -- local variable for each corresponding developer key.

  if p_table_info.fk_to_aol_table = 'Y' then
    l_locals := l_locals || p_dev_key_local_var_body || indent;
  end if;


  --
  -- if p_hier_column flag is set to 'Y' then prepare the download cursor to
  -- get only hierarchy cols only. If it is 'N' then prepare the download
  -- cursor to get all the columns.
  --

  if p_table_info.datetrack = 'N' then
    -- call prepare_down_load procedure to create the cursor.
    prepare_download_cursor ( p_table_info   => p_table_info,
                              p_cursor       => l_cursor,
                              p_cursor_type  => 'FULL_BG_MIGRATION',
                              p_hier_column  => p_hier_column);
    l_locals :=  l_locals ||
              '  l_table_rec                    ' || 'csr_mig_' ||
              lower(p_table_info.alias)  ||'%rowtype;' || indent;
  else -- date track table
    --
    -- for datetrack table two cursors are required.
    --    o For FULL data migration of the business group.
    --    o For ADDITIVE migration of the business group.
    --

    -- call prepare_down_load procedure to create the cursor for FULL data
    -- migration
     prepare_download_cursor ( p_table_info   => p_table_info,
                              p_cursor       => l_cursor,
                              p_cursor_type  => 'FULL_BG_MIGRATION',
                              p_hier_column  =>  p_hier_column);

    -- call prepare_down_load procedure to create the cursor for ADDITIVE
    -- data  migration

    prepare_download_cursor ( p_table_info   => p_table_info,
                              p_cursor       => l_adt_cursor,
                              p_cursor_type  => 'ADDITIVE_BG_MIGRATION',
                              p_hier_column  =>  p_hier_column);

    -- declare private procedures to open and fetch cursors depending
    -- upon the migration type i.e full or additive.
    prepare_dt_private_procedures (p_table_info   => p_table_info,
                                   p_body         => l_prv_proc_body);


    l_locals :=  l_locals ||
               '  l_table_rec                    ' || 'csr_full_mig_' ||
               lower(p_table_info.alias)  ||'%rowtype;' || indent || '  ' ||
               rpad('l_prv_' || p_table_info.surrogate_pk_column_name,30)
               ||'  number := -999;' || indent;
  end if;

  -- message (' l_cursor = ' || l_cursor);
  -- add the body of the download procedure

  l_indent := 2;
  l_proc_body_tbl(l_proc_index) := indent(l_indent) ||
                 'l_rec_inserted_cnt := 0;' || indent(l_indent) || 'begin';
  l_proc_index := l_proc_index + 1;

  add_debug_messages (p_table_info       => p_table_info,
                      p_procedure_name   => l_func_name,
                      p_message_location => 'START',
                      p_proc_body        => l_debug_message_text);
  l_proc_body_tbl(l_proc_index) := l_debug_message_text;
  l_proc_index := l_proc_index + 1;
  l_indent := 4;

  if p_table_info.datetrack = 'N' then

    l_proc_body_tbl(l_proc_index) := indent(l_indent) ||
    'open ' || l_cursor_name || ';' || indent(l_indent) || 'loop';
    l_proc_index := l_proc_index + 1;

    l_indent := 6;
    l_proc_body_tbl(l_proc_index) := indent(l_indent) ||
    'fetch ' || l_cursor_name ||' into l_table_rec;' ||indent(l_indent) ||
    'if '  || l_cursor_name || '%notfound then' ||  indent(l_indent + 2) ||
    'close ' || l_cursor_name || ';' || indent(l_indent + 2) ||
    'l_row_fetched := FALSE;' || indent(l_indent) || 'else' ||
    indent(l_indent + 2) || 'l_row_fetched := TRUE;' || indent(l_indent) ||
    'end if;';
    l_proc_index := l_proc_index + 1;
  else --  datetrack
    l_proc_body_tbl(l_proc_index) := indent(l_indent) ||
    'private_open_cursor;' || indent(l_indent) || 'loop' || indent(l_indent + 2)
    ||  'private_fetch_cursor;' ;
    l_proc_index := l_proc_index + 1;
  end if;

  l_indent := 6;

  l_comment := format_comment('if no row fetched then exit the loop',l_indent);


  l_proc_body_tbl(l_proc_index) := l_comment || indent(l_indent) ||
  'if not l_row_fetched then' ||indent(l_indent + 2) || 'exit;' ||
  indent(l_indent) || 'end if;';
  l_proc_index := l_proc_index + 1;


  --
  -- if it is a datetrack then add the code to  get the link value from the
  -- sequence.
  --
  if p_table_info.datetrack = 'Y' then
    l_proc_body_tbl(l_proc_index) :=  indent(l_indent) ||
    'if ' || rpad('l_prv_' || p_table_info.surrogate_pk_column_name,30) ||
    ' <> '|| 'l_table_rec.' || p_table_info.surrogate_pk_column_name ||
    ' then' || indent(l_indent + 2) || 'get_link_value(l_link_value);' ||
    indent(l_indent) || 'end if;';
    l_proc_index := l_proc_index + 1;
  end if;

  -- if p_hier_column is 'N' i.e this procedure is generated for download of
  -- all columns. If this table has a column hierarchy then set the hierarchy
  -- columns to null.

  if p_hier_column = 'N' and p_table_info.column_hierarchy = 'Y' then
      nullify_hierarchical_cols  ( p_table_info   => p_table_info,
                                   p_lpad_spaces  => l_indent,
                                   p_body         => l_proc_body );
  end if;


  -- if table has a column which have foreign key to the AOL table then call
  -- procedures to get the developer key.

  if p_table_info.fk_to_aol_table = 'Y' then
    l_proc_body := l_proc_body || p_call_to_proc_body ;
  end if;

  l_comment := 'insert the data into batch_lines table of datapump for ' ||
              'all columns of ' ||p_table_info.table_name ||
              ' and assign null values to hierarchy columns.';

  l_proc_body := l_proc_body ||  format_comment(l_comment,l_indent);

  l_proc_body_tbl(l_proc_index) := l_proc_body;
  l_proc_index := l_proc_index + 1;


  -- nullify columns where an N hierarchy exists
  -- only for download procedure

  if p_hier_column = 'N' then
    open csr_null_hierarchy;
    loop
      fetch csr_null_hierarchy into l_null_col;
      exit when csr_null_hierarchy%notfound;
      l_comment := 'Nullify column ' || l_null_col || ' for N hierarchy.';
      l_proc_body_tbl(l_proc_index) :=  format_comment(l_comment,l_indent) ||
                                        indent(l_indent) ||
                                        'l_table_rec.' ||
                                        lower(l_null_col) ||
                                        ' := null;' || indent(l_indent) ;
      l_proc_index := l_proc_index + 1;
    end loop;
    close csr_null_hierarchy;
  end if;

  -- form a call to data pump function to insert data into batch_lines
  -- table.

  l_proc_body_tbl(l_proc_index) :=  indent(l_indent) || l_dp_func_name ||
  indent(l_indent) ||
  '( p_batch_id                     => p_batch_id'|| indent(l_indent) ||
  ' ,p_user_sequence                => l_link_value' || indent(l_indent) ||
  ' ,p_link_value                   => l_link_value' || indent(l_indent) ||
  ' ,p_last_migration_date          => p_last_migration_date' || indent(l_indent) ||
  ' ,p_migration_type               => p_migration_type' || indent;
  l_proc_index := l_proc_index + 1;

  -- if the columns of the table have foreign key to AOL table then call
  -- call assignment function which replaces those columns with developer key.
  if p_table_info.fk_to_aol_table = 'N' then

    l_proc_body_tbl(l_proc_index) :=   hr_dm_library.get_func_asg (
                                   p_rpad_spaces      => l_indent +1,
                                   p_columns_tbl      => l_columns_tbl,
                                   p_prefix_left_asg  => 'p_',
                                   p_prefix_right_asg => 'l_table_rec.',
                                   p_right_asg_pad_len => 55);
  else
    l_proc_body_tbl(l_proc_index) :=  hr_dm_library.get_func_asg_with_dev_key (
                                   p_rpad_spaces      => l_indent +1,
                                   p_columns_tbl      => l_columns_tbl,
                                   p_prefix_left_asg  => 'p_',
                                   p_prefix_right_asg => 'l_table_rec.',
                                   p_right_asg_pad_len => 55,
                                   p_prefix_left_asg_dev_key  => 'p_',
                                   p_prefix_right_asg_dev_key => 'l_',
                                   p_use_aol_id_col           => 'N',
                                   p_fk_to_aol_columns_tbl    => p_fk_to_aol_columns_tbl,
                                   p_resolve_pk_columns_tbl   => g_resolve_pk_columns_tbl );

  end if;

  l_proc_body_tbl(l_proc_index) :=  l_proc_body_tbl(l_proc_index)  ||  ');';
  l_proc_index := l_proc_index + 1;

  --
  l_indent := 6;
  l_proc_body_tbl(l_proc_index) :=  indent(l_indent) ||
  'l_rec_inserted_cnt := l_rec_inserted_cnt + 1;' || indent(l_indent) ||
  format_comment('commit after every chunk_size_value (e.g. 10) records.',
  l_indent) || indent(l_indent) || 'if mod (l_rec_inserted_cnt, ' ||
  'p_chunk_size) = 0 then ' ||  indent(l_indent + 2) || 'commit;' ||
  indent(l_indent) || 'end if;';

  l_proc_index := l_proc_index + 1;
  --
  -- if it is a datetrack then store the id value.
  --
  if p_table_info.datetrack = 'Y' then
    l_proc_body_tbl(l_proc_index) := indent(l_indent) ||
    rpad('l_prv_' || p_table_info.surrogate_pk_column_name,30) || ' := ' ||
     'l_table_rec.' || p_table_info.surrogate_pk_column_name || ';';
    l_proc_index := l_proc_index + 1;
  end if;

  l_proc_body_tbl(l_proc_index) :=  indent(l_indent - 2)  ||
  'end loop;' ||  indent(l_indent - 2) || 'commit;' || indent(l_indent - 2) ||
  'p_rec_downloaded := l_rec_inserted_cnt;' ||  indent(l_indent - 4) ||
  'end;';
  l_proc_index := l_proc_index + 1;

  -- if p_hier_column is 'N' i.e this procedure is generated for download of
  -- all columns. If this table has a column hierarchy then include a call to
  -- call the download hieararchy procedure.


  if p_hier_column = 'N' and p_table_info.column_hierarchy = 'Y' then
    l_indent := 22;
    l_proc_body_tbl(l_proc_index) :=  indent ||
    '  download_hierarchy (p_migration_type,'    || indent(l_indent) ||
    'p_business_group_id,'      || indent(l_indent) ||
    'p_last_migration_date,'    || indent(l_indent) ||
    'p_start_id,'               || indent(l_indent) ||
    'p_end_id ,'                || indent(l_indent) ||
    'p_batch_id ,'              || indent(l_indent) ||
    'p_chunk_size,'             || indent(l_indent) ||
    'l_rec_inserted_cnt);' || indent;
    l_proc_index := l_proc_index + 1;
  end if;

  l_indent := 4;
  add_debug_messages (p_table_info       => p_table_info,
                      p_procedure_name   => l_func_name,
                      p_message_location => 'END',
                      p_proc_body        => l_debug_message_text);
  l_proc_body_tbl(l_proc_index) := l_debug_message_text;
  l_proc_index := l_proc_index + 1;

  l_proc_comment := format_comment('procedure to download all columns of '
  || upper(p_table_info.table_name) || ' data into datapump interface table.')
  || indent;

  -- add the procedure comment defination to the package header and body
  p_header := p_header || l_proc_comment ||'procedure ' || l_func_name ||
              l_proc_body_tbl(1) ||  ';';
  l_proc_body_tbl(1) :=  l_proc_comment || 'procedure ' || l_func_name ||
             l_proc_body_tbl(1) ||  'is';

  -- add local variables , cursor and procedure body to complete the procedure
  l_proc_body_tbl(1) := l_proc_body_tbl(1) || l_cursor ||  l_adt_cursor ||
     l_locals  || l_prv_proc_body ||  indent ||'begin' || indent ;

  -- add the body of this procedure to the package.
  add_to_package_body( l_proc_body_tbl );

  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.generate_download',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.generate_download',
                         '(none)','R');
     raise;
end generate_download;
-- -----------------------  prepare_calc_range_cursor ---------------------
-- Description:
-- Preapre the cursor for calculate ranges procedure
-- ------------------------------------------------------------------------
procedure prepare_calc_range_cursor
(
  p_table_info       in     hr_dm_gen_main.t_table_info,
  p_cursor           out nocopy    varchar2
)
is
  l_cursor_comment       varchar2(2000);
  l_cursor_defination    varchar2(2000);
  l_cursor_select_cols   varchar2(32767);
  l_cursor_select_from   varchar2(32767);
  l_cursor_select_where  varchar2(32767);

begin

  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.prepare_calc_range_cursor'
                        , 5);

  -- comments about the cursor
  l_cursor_comment := format_comment('cursor to get the minimum and maximum' ||
                                      ' value of the primary key.');

  -- defination of cursor
  l_cursor_defination := '  cursor csr_get_pk_min_max_val is ' || indent;

  -- select columns in the cursor. This will return the list of all columns
  -- of the table separated by comma's.

  l_cursor_select_cols := '  select min( ' || p_table_info.alias || '.' ||
  p_table_info.surrogate_pk_column_name || ')' || indent(10) || ',max( '||
  p_table_info.alias || '.' || p_table_info.surrogate_pk_column_name || ')';

  -- get from clause
  get_cursor_from_clause (p_table_info   => p_table_info,
                          p_from_clause =>   l_cursor_select_from);
  -- get where clause
  get_gen_cursor_where_clause (p_table_info   => p_table_info,
                               p_where_clause =>   l_cursor_select_where,
                               p_cursor_type  => 'CALCULATE_RANGES');

  -- finally put the components of where clause together
  p_cursor := l_cursor_comment      || indent ||
              l_cursor_defination   || indent ||
              l_cursor_select_cols  || indent ||
              l_cursor_select_from  || indent ||
              l_cursor_select_where || indent;
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.prepare_calc_range_cursor',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.prepare_calc_range_cursor',
                         '(none)','R');
     raise;
end prepare_calc_range_cursor;


-- ----------------------- generate_calculate_ranges -----------------------
-- Description:
-- Generates the calculate_ranges procedure of the TDS
-- ------------------------------------------------------------------------
procedure generate_calculate_ranges
(
  p_table_info       in     hr_dm_gen_main.t_table_info,
  p_header           in out nocopy varchar2
)
is
  l_interface    varchar2(32767);
  l_locals       varchar2(32767) := null;
  l_cursor       varchar2(32767) := null;
  l_comment      varchar2(4000);
  l_proc_comment varchar2(4000);
  l_cursor_name  varchar2(30) := 'csr_get_pk_min_max_val';

  -- block body of the procedure i.e between begin and end.
  l_proc_body           varchar2(32767) := null;
  l_func_body           varchar2(32767) := null;
  l_debug_message_text  varchar2(32767) := null;
  l_package_name        varchar2(30) := 'hrdmd_' || p_table_info.short_name;

  -- indentation for the statements.it specifies number of blank spaces
  -- after which the staement should start.

  l_indent                  number;
  l_proc_body_tbl           t_varchar2_32k_tbl;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.generate_calculate_ranges', 5);

  -- input parameters for the procedure

  l_interface :=  indent ||
  '(p_business_group_id in  number,'      || indent ||
  ' p_last_migration_date  in  date,'      || indent ||
  ' p_phase_item_id     in  number,'      || indent ||
  ' p_no_of_threads     in  number)' || indent;

  -- if the table has surrogate primary key then open up a cursor
  -- to get the minimum and maximum key value.

  if p_table_info.surrogate_primary_key = 'Y' then

    -- local variables of the procedure

    l_locals := indent || '--' || indent ||
              '-- Declare cursors and local variables' || indent ||
              '--' || indent ||
              '  l_proc                        varchar2(72) := g_package ' ||
              '|| ''calculate_ranges'';' || indent ||
              '  l_max_key_value               number := 0;' || indent ||
              '  l_min_key_value               number := 0;' || indent ||
              '  l_starting_process_sequence   number := 0;' || indent ||
              '  l_ending_process_sequence     number := 0;' || indent ||
              '  l_range_value                 number := 0;' || indent ||
              '  l_row_fetched                 boolean := FALSE;' || indent;
    prepare_calc_range_cursor(p_table_info  => p_table_info,
                               p_cursor      => l_cursor);

    -- add the body of the download procedure

    l_indent := 2;

    l_proc_body := l_proc_body || indent|| 'begin';

    add_debug_messages (p_table_info       => p_table_info,
                      p_procedure_name   => 'calculate_ranges',
                      p_message_location => 'START',
                      p_proc_body        => l_debug_message_text);

    l_proc_body := l_proc_body || l_debug_message_text || indent;

    -- open the cursor , fetch the data and close the cursor.

    l_proc_body :=
    l_proc_body || indent(l_indent) ||
    'open ' || l_cursor_name || ';' || indent(l_indent) ||'fetch ' ||
    l_cursor_name ||' into l_min_key_value ,l_max_key_value;' ||
    indent(l_indent) || 'if l_min_key_value is null or l_max_key_value is null '
    || 'then' ||
    format_comment('No rows selected in this table for download.',l_indent + 2) ||
    indent(l_indent + 2) || 'close csr_get_pk_min_max_val;' ||
    indent(l_indent + 2) ||   'hr_dm_utility.message(''ROUT'',''exit:' ||
    l_package_name || '.calculate_ranges (no rows found). '', 25);' ||
    indent(l_indent + 2) ||'return;' || indent(l_indent ) ||
    'end if;' || indent(l_indent) || 'close csr_get_pk_min_max_val;' || indent;

    l_proc_body := l_proc_body || format_comment('find the first range',2);

    l_proc_body := l_proc_body || indent(l_indent) ||
    'l_range_value := TRUNC ((l_max_key_value - l_min_key_value) / ' ||
    'p_no_of_threads);' || indent(l_indent) || 'l_starting_process_sequence :='
    ||' l_min_key_value;' || indent(l_indent) ||
    'l_ending_process_sequence   := l_min_key_value + l_range_value;';

    l_proc_body :=  l_proc_body || format_comment(
    'insert the range records equal to the number of threads available for' ||
    'processing',2);


    -- build up insert statement to insert data into migration range table.
    l_proc_body :=  l_proc_body || indent(l_indent) ||
    'for i in 1..p_no_of_threads loop '|| indent(l_indent + 2) ||
    'insert into hr_dm_migration_ranges ( range_id ' ;
    l_indent := 40;

    l_proc_body :=  l_proc_body ||
    indent(l_indent) || ',phase_item_id' ||
    indent(l_indent) || ',status' || indent(l_indent) ||
    ',starting_process_sequence' || indent(l_indent) ||
    ',ending_process_sequence)' ||
    indent(l_indent - 7) || 'values ( ' ||
    'hr_dm_migration_ranges_s.nextval' ||
    indent(l_indent) || ',p_phase_item_id' ||
    indent(l_indent) || ',''NS''' || indent(l_indent) ||
    ',l_starting_process_sequence' || indent(l_indent) ||
    ',l_ending_process_sequence);' || indent;

    l_indent := 4;

    l_proc_body :=  l_proc_body || indent(l_indent) ||
    'l_starting_process_sequence := l_ending_process_sequence + 1;' ||
    format_comment('if it is a last thread then assign the maximum key value to end'
    || ' sequence.', l_indent) || indent(l_indent) ||
    'if i = p_no_of_threads  then' || indent(l_indent+2) ||
    'l_ending_process_sequence := l_max_key_value;' || indent(l_indent) ||
    'else' || indent(l_indent + 2) ||
    'l_ending_process_sequence := l_starting_process_sequence + l_range_value;'
    || indent(l_indent) || 'end if;' || indent(l_indent -2) || 'end loop;' ||
     indent(l_indent -2) || 'commit;' ;


  else
    -- if the table does not have a surrogate primary key then insert a
    -- dummy row into migration_range table.

    -- local variables of the procedure

    l_locals := indent || '  --' || indent ||
              '  -- Declare cursors and local variables' || indent ||
              '  --' || indent ||
              '  l_proc                        varchar2(72) := g_package ' ||
              '|| ''calculate_ranges'';' ;

    l_indent := 2;

    l_proc_body := l_proc_body || indent|| 'begin';

    add_debug_messages (p_table_info       => p_table_info,
                      p_procedure_name   => 'calculate_ranges',
                      p_message_location => 'START',
                      p_proc_body        => l_debug_message_text);

    l_proc_body := l_proc_body || l_debug_message_text || indent;

    -- build up insert statement to insert data into migration range table.

    l_indent := 2;
    l_proc_body :=  l_proc_body || indent(l_indent) ||
    'insert into hr_dm_migration_ranges ( range_id ' ;
    l_indent := 38;

    l_proc_body :=  l_proc_body ||
    indent(l_indent) || ',phase_item_id' ||
    indent(l_indent) || ',status' || indent(l_indent) ||
    ',starting_process_sequence' || indent(l_indent) ||
    ',ending_process_sequence)' ||
    indent(l_indent - 9) || 'values (' ||
    'hr_dm_migration_ranges_s.nextval' ||
    indent(l_indent) || ',p_phase_item_id' ||
    indent(l_indent) || ',''NS''' || indent(l_indent) ||
    ',-99' || indent(l_indent) ||
    ',-99);';
  end if;

  -- add debug messages
  add_debug_messages (p_table_info       => p_table_info,
                      p_procedure_name   => 'calculate_ranges',
                      p_message_location => 'END',
                      p_proc_body        => l_debug_message_text);
  l_proc_body := l_proc_body || l_debug_message_text || indent;

  l_proc_comment := format_comment('procedure to calculate ranges for '
  || upper(p_table_info.table_name) || ' data') ||
  indent;

  -- add the procedure defination to the package header and body
  p_header := p_header || l_proc_comment ||'procedure calculate_ranges' ||
             l_interface || ';';

  -- add the procedure comment defination,local variables , cursor and
  -- procedure body

  l_proc_body_tbl(1) := l_proc_comment ||'procedure calculate_ranges' ||
          l_interface || ' is'|| l_locals || l_cursor ||  l_proc_body;

  -- add the body of this procedure to the package.
  add_to_package_body( l_proc_body_tbl );

  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.generate_calculate_ranges',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.generate_calculate_ranges',
                         '(none)','R');
     raise;
end generate_calculate_ranges;

-- -----------------------  prepare_del_datapump_cursor ---------------------
-- Description:
-- Preapre the cursor for delete data pump procedure
-- ------------------------------------------------------------------------
procedure prepare_del_datapump_cursor
(
  p_table_info       in     hr_dm_gen_main.t_table_info,
  p_cursor           out nocopy    varchar2
)
is
  l_cursor_comment       varchar2(2000);
  l_cursor_defination    varchar2(2000);
  l_cursor_select_cols   varchar2(32767);
  l_cursor_select_from   varchar2(32767);
  l_cursor_select_where  varchar2(32767);

begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.prepare_del_datapump_cursor', 5);

  -- comments about the cursor
  l_cursor_comment := format_comment('cursor to get the '||
                      p_table_info.table_name
                     || ' data from data pump batch table for a given batch.');
  -- defination of cursor
  l_cursor_defination := '  cursor csr_' ||p_table_info.alias || ' is ';

  -- select columns in the cursor. This will return the list of all columns
  -- of the table separated by comma's.

  l_cursor_select_cols := '  select rowid row_id ' ;

  -- get from clause. dtapump creates a view of the table to be uploaded.
  -- view is based on batch_lines table and TUPS load program parameters.

  l_cursor_select_from := '  from  hrdpv_u'|| p_table_info.short_name;

  -- get where clause
  -- if the table has a surrogate primary key then a range of the surrogate
  -- primary key will be deleted, otherwise, full table will be deleted.

  if p_table_info.surrogate_primary_key = 'Y' then
    l_cursor_select_where := '  where batch_id = p_batch_id ' || indent ||
    ' and p_start_id <= (select to_number(' || g_surrogate_pk_col_param ||
    ') from dual)'  || indent ||
    ' and p_end_id >= (select to_number(' || g_surrogate_pk_col_param ||
    ') from dual);';
  else
    l_cursor_select_where := '  where batch_id = p_batch_id;';
  end if;

  -- finally put the components of where clause together
  p_cursor := l_cursor_comment      || indent ||
              l_cursor_defination   || indent ||
              l_cursor_select_cols  || indent ||
              l_cursor_select_from  || indent ||
              l_cursor_select_where || indent;

  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.prepare_del_datapump_cursor',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.prepare_del_datapump_cursor',
                         '(none)','R');
     raise;
end prepare_del_datapump_cursor;


-- ----------------------- generate_delete_datapump -----------------------
-- Description:
-- Generates the delete_datapump procedure of the TDS
-- ------------------------------------------------------------------------
procedure generate_delete_datapump
(
  p_table_info       in     hr_dm_gen_main.t_table_info,
  p_header           in out nocopy varchar2
)
is
  l_interface    varchar2(32767);
  l_locals       varchar2(32767) := null;
  l_cursor       varchar2(32767) := null;
  l_comment      varchar2(4000);
  l_proc_comment varchar2(4000);
  l_cursor_name  varchar2(30) := 'csr_' || p_table_info.alias;
  l_cursor_rec   varchar2(30) := 'csr_' || p_table_info.alias || '_rec';

  -- block body of the procedure i.e between begin and end.
  l_proc_body          varchar2(32767) := null;
  l_func_body          varchar2(32767) := null;
  l_debug_message_text varchar2(32767) := null;

  -- indentation for the statements.it specifies number of blank spaces
  -- after which the staement should start.

  l_indent                  number;
  l_proc_body_tbl           t_varchar2_32k_tbl;
begin

  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.generate_delete_datapump', 5);

  -- input parameters for the procedure

  l_interface :=  indent ||
  '(p_start_id          in  number,'      || indent ||
  ' p_end_id            in  number,'      || indent ||
  ' p_batch_id          in  number,'      || indent ||
  ' p_chunk_size        in  number)' || indent;

  -- local variables of the procedure

  l_locals := indent || '--' || indent ||
              '-- Declare cursors and local variables' || indent ||
              '--' || indent ||
              '  l_proc                     varchar2(72) := g_package ' ||
              '|| ''delete_datapump'';' || indent ||
              '  l_rec_deleted_cnt          number := 0;' || indent;

  -- cursor to get the data from the data pump table
  prepare_del_datapump_cursor (p_table_info,
                               l_cursor);
  -- add the body of the download procedure

  l_indent := 2;
  l_proc_body := l_proc_body || indent|| 'begin';
  l_proc_body := l_proc_body || indent(l_indent) ||
                 'l_rec_deleted_cnt := 0;';

  add_debug_messages (p_table_info       => p_table_info,
                      p_procedure_name   => 'delete_datapump',
                      p_message_location => 'START',
                      p_proc_body        => l_debug_message_text);

  l_proc_body := l_proc_body || l_debug_message_text || indent;

  l_proc_body :=
  l_proc_body || indent(l_indent) ||
  'for ' || l_cursor_rec || ' in ' || l_cursor_name || ' loop' ||indent(l_indent);

  l_indent := l_indent + 2;

  l_comment := format_comment('delete the data from the data pump view for this'
               || ' table.',l_indent);

  l_proc_body := l_proc_body || l_comment;

  l_proc_body := l_proc_body || indent(l_indent) ||
  'delete from hrdpv_u' || p_table_info.short_name || indent(l_indent) ||
  'where rowid = ' || l_cursor_rec || '.row_id;';

  l_proc_body := l_proc_body || indent(l_indent) ||
  'l_rec_deleted_cnt := l_rec_deleted_cnt + 1;' || indent(l_indent) ||
  format_comment('commit after every chunk_size_value (e.g. 10) records.',
  l_indent) || indent(l_indent) || 'if mod (l_rec_deleted_cnt, ' ||
  'p_chunk_size) = 0 then ' ||  indent(l_indent + 2) || 'commit;' ||
  indent(l_indent) || 'end if;' || indent(l_indent - 2)  || 'end loop;' ||
  indent(l_indent - 2) || 'commit;';

  add_debug_messages (p_table_info       => p_table_info,
                      p_procedure_name   => 'delete_datapump',
                      p_message_location => 'END',
                      p_proc_body        => l_debug_message_text);

  l_proc_body := l_proc_body || l_debug_message_text;

  if p_table_info.surrogate_primary_key = 'Y' then
    l_proc_comment := format_comment('procedure to delete a range of '
    || upper(p_table_info.table_name) || ' data from datapump interface table.')||
    indent;
  else
    l_proc_comment := format_comment('procedure to delete data of '
    || upper(p_table_info.table_name) || ' from datapump interface table.')||
    indent;
  end if;

  -- add the procedure comment defination to the package header and body
  p_header := p_header || l_proc_comment ||'procedure delete_datapump' ||
              l_interface ||   ';';


  -- add the procedure comment defination,local variables , cursor and
  -- procedure body

  l_proc_body_tbl(1) := l_proc_comment || 'procedure delete_datapump' ||
        l_interface || ' is' || l_locals || l_cursor || l_proc_body;

  -- add the body of this procedure to the package.
  add_to_package_body( l_proc_body_tbl );

  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.generate_delete_datapump',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.generate_delete_datapump',
                         '(none)','R');
     raise;
end generate_delete_datapump;

-- -----------------------  prepare_delete_source_cursor; ---------------------
-- Description:
-- Preapre the cursor for delete data from the table for a business group
-- which has been migrated.
-- ------------------------------------------------------------------------
procedure prepare_delete_source_cursor
(
  p_table_info       in     hr_dm_gen_main.t_table_info,
  p_cursor           out nocopy    varchar2
)
is
  l_cursor_comment       varchar2(2000);
  l_cursor_defination    varchar2(2000);
  l_cursor_select_cols   varchar2(32767);
  l_cursor_select_from   varchar2(32767);
  l_cursor_select_where  varchar2(32767);

begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.prepare_delete_source_cursor', 5);

  -- comments about the cursor
  l_cursor_comment := format_comment('cursor to get the '||
                      p_table_info.table_name
                     || ' data for a given business group.');
  -- defination of cursor
  l_cursor_defination := '  cursor csr_' ||p_table_info.alias || ' is ';

  -- select columns in the cursor. This will return the list of all columns
  -- of the table separated by comma's.

  -- Key combination tables have foreign key on AOL table
  --  'FND_ID_FLEX_STRUCTURES' i.e hierarchy_type = 'A'. To identify
  -- the business group for a row in these tables it is required to
  -- check whether the ID value of the row is used by any of the
  -- child tables. The 'Where' clause generated by this generator
  -- does not use the 'exists' clause which results in the same row
  -- being fetch equals to the number of child rows it matches. To
  -- avoid this ' distinct' clause is added for only these tables.
  -- If the 'distinct' clause causes the performance problem then
  -- remove it and seed the derive_sql columns in HR_DM_TABLES for
  -- these tables.

  if p_table_info.use_distinct = 'Y' then
     l_cursor_select_cols := '  select distinct ' || p_table_info.alias ||
                             '.rowid row_id ';
  else
     l_cursor_select_cols := '  select ' || p_table_info.alias ||
                             '.rowid row_id ';
  end if;

  -- get from clause
  get_cursor_from_clause (p_table_info  => p_table_info,
                          p_from_clause => l_cursor_select_from);
  -- get where clause
  get_gen_cursor_where_clause ( p_table_info    => p_table_info ,
                                p_where_clause  => l_cursor_select_where,
                                p_cursor_type   => 'DELETE_SOURCE');

  -- finally put the components of where clause together
  p_cursor := l_cursor_comment      || indent ||
              l_cursor_defination   || indent ||
              l_cursor_select_cols  || indent ||
              l_cursor_select_from  || indent ||
              l_cursor_select_where || indent;

  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.prepare_delete_source_cursor',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.prepare_delete_source_cursor',
                         '(none)','R');
     raise;
end prepare_delete_source_cursor;

-- ----------------------- generate_delete_source -----------------------
-- Description:
-- Generates the delete_source procedure of the TDS.
-- ------------------------------------------------------------------------
procedure generate_delete_source
(
  p_table_info       in     hr_dm_gen_main.t_table_info,
  p_header           in out nocopy varchar2
)
is
  l_interface    varchar2(32767);
  l_locals       varchar2(32767) := null;
  l_cursor       varchar2(32767) := null;
  l_comment      varchar2(4000);
  l_proc_comment varchar2(4000);
  l_cursor_name  varchar2(30) := 'csr_' || p_table_info.alias;
  l_cursor_rec   varchar2(30) := 'csr_' || p_table_info.alias || '_rec';

  -- block body of the procedure i.e between begin and end.
  l_proc_body           varchar2(32767) := null;
  l_func_body           varchar2(32767) := null;
  l_debug_message_text  varchar2(32767) := null;

  -- indentation for the statements.it specifies number of blank spaces
  -- after which the staement should start.

  l_indent                  number;
  l_proc_body_tbl           t_varchar2_32k_tbl;
begin

  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.generate_delete_source', 5);

  -- input parameters for the procedure

  l_interface :=  indent ||
  '(p_business_group_id in  number,'      || indent ||
  ' p_start_id          in  number,'      || indent ||
  ' p_end_id            in  number,'      || indent ||
  ' p_chunk_size        in  number)' || indent;

  -- message (' l_interface = ' || l_interface);
  -- local variables of the procedure

  l_locals := indent || '--' || indent ||
              '-- Declare cursors and local variables' || indent ||
              '--' || indent ||
              '  l_proc                     varchar2(72) := g_package ' ||
              '|| ''delete_source'';' || indent ||
              '  l_rec_deleted_cnt          number := 0;' || indent;

  -- cursor to get the data from the data pump table
  prepare_delete_source_cursor (p_table_info,
                                l_cursor);

  -- add the body of the download procedure

  l_indent := 2;
  l_proc_body := l_proc_body || indent|| 'begin';
  l_proc_body := l_proc_body || indent(l_indent) ||
                 'l_rec_deleted_cnt := 0;';



  add_debug_messages (p_table_info       => p_table_info,
                      p_procedure_name   => 'delete_source',
                      p_message_location => 'START',
                      p_proc_body        => l_debug_message_text);

  l_proc_body := l_proc_body || l_debug_message_text || indent;

  l_proc_body :=
  l_proc_body || indent(l_indent) ||
  'for ' || l_cursor_rec || ' in ' || l_cursor_name || ' loop' ||indent(l_indent);

  l_indent := l_indent + 2;

  l_comment := format_comment('delete the row read from the table.',l_indent);

  l_proc_body := l_proc_body || l_comment;

  l_proc_body := l_proc_body || indent(l_indent) ||
  'delete from ' || p_table_info.table_name || indent(l_indent) ||
  'where rowid = ' || l_cursor_rec || '.row_id;';


  l_proc_body := l_proc_body || indent(l_indent) ||
  'l_rec_deleted_cnt := l_rec_deleted_cnt + 1;' || indent(l_indent) ||
  format_comment('commit after every chunk_size_value (e.g. 10) records.',
  l_indent) || indent(l_indent) || 'if mod (l_rec_deleted_cnt, ' ||
  'p_chunk_size) = 0 then ' ||  indent(l_indent + 2) || 'commit;' ||
  indent(l_indent) || 'end if;' || indent(l_indent - 2)  || 'end loop;' ||
  indent(l_indent - 2) || 'commit;';

  add_debug_messages (p_table_info       => p_table_info,
                      p_procedure_name   => 'delete_source',
                      p_message_location => 'END',
                      p_proc_body        => l_debug_message_text);

  l_proc_body := l_proc_body || l_debug_message_text;

  l_proc_comment := format_comment('procedure to delete data of '
  || upper(p_table_info.table_name) || ' for a given business group.')||
  indent;

  -- add the procedure comment defination to the package header and body
   p_header := p_header || l_proc_comment ||'procedure delete_source' ||
               l_interface ||   ';';

  -- add the procedure comment defination,local variables , cursor and
  -- procedure body

  l_proc_body_tbl(1) := l_proc_comment || 'procedure delete_source' ||
        l_interface || ' is' || l_locals || l_cursor ||  l_proc_body;

 -- add the body of this procedure to the package.
 add_to_package_body( l_proc_body_tbl );


 hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.generate_delete_source',
                         25);

exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.generate_delete_source',
                         '(none)','R');
     raise;
end generate_delete_source;

-- ------------------------- create_tds_pacakge ------------------------
-- Description:  Create the TDS package and relevant procedures for the table.
--
-- Input Parameters :
--   p_table_info  - Information about table for which TDS to be generated. Info
--                  like Datetrack, Global Data, Surrogate Primary key etc about
--                  the table is passed as a record type.
--   p_columns_tbl - All the columns of the table stored as a list.
--   p_parameters_tbl - All the columns of the table stored with data type are
--                   stored as a list. e.g p_business_group_id   number
--                   This is used to create the procedure parameter list for
--                   TDS procedure.
--   p_aol_columns_tbl  -  All the columns of the table which have foreign key to
--                    AOL table are stored as a list.
--   p_aol_parameters_tbl - All the columns of the table which have foreign key to
--                    AOL table are stored with data type as a list. This is
--                    used as a parameter list for the procedure generated to
--                    get the  AOL developer key for the given ID value
--                    e.g p_user_id  number
--   p_fk_to_aol_columns_tbl  - It stores the list of all the columns which have
--                   foreign on AOL table and corresponding name of the AOL
--                   table.
-- ------------------------------------------------------------------------
procedure create_tds_pacakge
(
 p_table_info             in   hr_dm_gen_main.t_table_info,
 p_columns_tbl            in   hr_dm_library.t_varchar2_tbl,
 p_parameters_tbl         in   hr_dm_library.t_varchar2_tbl,
 p_aol_columns_tbl        in   hr_dm_library.t_varchar2_tbl,
 p_aol_parameters_tbl     in   hr_dm_library.t_varchar2_tbl,
 p_fk_to_aol_columns_tbl  in   hr_dm_gen_main.t_fk_to_aol_columns_tbl
)
is
  l_header                  varchar2(32767);
  l_body                    varchar2(32767);
  l_header_comment          varchar2(2048);
  l_package_name            varchar2(30) := 'hrdmd_' ||  p_table_info.short_name;
  l_generator_version       hr_dm_tables.generator_version%type;
  l_package_version         varchar2(200);
  l_index                   number := 1;
  l_call_to_aol_proc        varchar2(32767);
  l_dev_key_local_var       varchar2(32767);
  l_proc_body_tbl           t_varchar2_32k_tbl;
  l_proc_index              number := 1;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tds.create_tds_pacakge', 5);
  hr_dm_utility.message('PARA','(Table Name - ' || p_table_info.table_name ||
                                ')', 10);

  g_table_info     := p_table_info;
  g_columns_tbl    := p_columns_tbl;
  g_parameters_tbl := p_parameters_tbl;
  g_surrogate_pk_col_param := 'p_' ||
                           rpad(p_table_info.surrogate_pk_column_name,28);

  -- inialize the global package body pl/sql table by deleting all elements.
  init_package_body;

  -- Get the version of the generator to be appended to the TDS package
  -- generated for a table. This will help in finding out which version
  -- of  Generator is used to generate the TDS package.

   hr_dm_library.get_generator_version(p_generator_version  => l_generator_version,
                                       p_format_output      => 'Y');

  -- Get the package version of this TDS package body.
  hr_dm_library.get_package_version ( p_package_name     => 'HR_DM_GEN_TDS',
                                      p_package_version  =>  l_package_version,
                                      p_version_type     => 'FULL');


  -- if there is a column hirearchy then store the hierarchy columns list and
  -- parameter assignment in pl/sql variable.

  if p_table_info.column_hierarchy = 'Y' then
    -- get the columns and parameter list. store in pl/sql table.

    hr_dm_library.populate_hierarchy_cols_list
    (p_table_info         => p_table_info,
     p_hier_columns_tbl   => g_hier_columns_tbl,
     p_hier_parameter_tbl => g_hier_parameters_tbl,
     p_called_from       => 'TDS' );
  end if;

  -- Start the package header and body.
  begin
    --
    -- Set up initial parts of the package header and body.
    --
    l_header_comment :=  l_package_version || indent ||  '/*' || indent ||
    ' * Generated by hr_dm_gen_tds at: '  ||
    to_char( sysdate, 'YYYY/MM/DD HH24:MM:SS' ) || indent ||
    ' * Generated Data Migrator TDS for : ' || p_table_info.table_name || '.' ||
     indent ||
    ' * Generator Version Used to generate this TDS is : ' || indent ||
    l_generator_version ||  indent ||
    ' */' || indent || '--' || indent;

    l_header :=
    'create or replace package ' || l_package_name || ' as' || indent ||
    l_header_comment ||
    'g_generator_version constant varchar2(128) default ' ||
    '''$Revision: 120.0  $'';' || indent || '--' || indent;

    l_proc_body_tbl(1) :=
    'create or replace package body ' || l_package_name || ' as' || indent ||
    l_header_comment;

    -- private package variable
    l_proc_body_tbl(1) :=  l_proc_body_tbl(1) || indent || '--' ||
               indent || '--  Package Variables' || indent ||
              '--' || indent ||
              'g_package  varchar2(33) := ''' || l_package_name || ''';' ||
               indent;

   -- add the body of this procedure to the package.
   add_to_package_body( l_proc_body_tbl );
    --
    -- Generate the procedures and functions.
    --

    -- if it is a datetrack generate procedure to get link value.
    if p_table_info.datetrack = 'Y' then

      -- create a procedure to get the link value to be used by data pump for
      -- uploading.

      generate_get_link_value(p_table_info);
    end if;

    -- if the table has a columns which have a foreign key to AOL table then
    -- generate the procedures so as to create the procedures to get the
    -- corresponding developer's key for those columns.

    if p_table_info.fk_to_aol_table = 'Y' then
       generate_developer_key_func
       ( p_fk_to_aol_columns_tbl   => p_fk_to_aol_columns_tbl,
         p_table_info              => p_table_info,
         p_call_to_proc_body       => l_call_to_aol_proc,
         p_dev_key_local_var_body  => l_dev_key_local_var);
    end if;

    l_body := l_body || indent || '--' || indent;

    -- generate download procedure to download data into batch_lines.
    -- for column hierarchy.
    --
    -- for download of hierarchy columns, we are assuming that there
    -- will be no H hierarchy columns where the same column will also
    -- have an A hierarchy, ie there will be no A hierarchy calls and
    -- hence p_call_to_proc_body      => '', instead of
    -- p_call_to_proc_body      => l_call_to_aol_proc,

    if p_table_info.column_hierarchy = 'Y' then
      l_body := l_body || indent || '--' || indent;
      generate_download(p_table_info             => p_table_info,
                        p_header                 => l_header,
                        p_hier_column            => 'Y',
                        p_call_to_proc_body      => '',
                        p_dev_key_local_var_body => l_dev_key_local_var,
                        p_fk_to_aol_columns_tbl  => p_fk_to_aol_columns_tbl);
    end if;

    -- down load procedure to download all columns.
    generate_download(p_table_info             => p_table_info,
                      p_header                 => l_header,
                      p_hier_column            => 'N',
                      p_call_to_proc_body      => l_call_to_aol_proc,
                      p_dev_key_local_var_body => l_dev_key_local_var,
                      p_fk_to_aol_columns_tbl  => p_fk_to_aol_columns_tbl);


    l_header := l_header || indent || '--' || indent;
    l_body := l_body || indent || '--' || indent;

    -- generate calculate_ranges procedure to download data into batch_lines.

    l_body := l_body || indent || '--' || indent;
    generate_calculate_ranges(p_table_info,
                              l_header);

    -- generate delete_datapump procedure to delete data from batch_lines.
    -- table for the given table.

    l_body := l_body || indent || '--' || indent;
    generate_delete_datapump(p_table_info,
                             l_header );

    -- generate delete_source procedure to delete data from batch_lines.
    -- table for the given table.

    l_body := l_body || indent || '--' || indent;
    generate_delete_source(p_table_info,
                           l_header);

    l_header := l_header || indent || '--' || indent;
    l_body := l_body || indent || '--' || indent;

    -- Terminate the package body and header.
    --
    l_header := l_header || 'end ' || l_package_name || ';';
    l_body := l_body || 'end ' || l_package_name || ';';
  exception
    when plsql_value_error then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.create_tds_pacakge',
                         'Either TDS package code size is too big or  ' ||
                          ' a value error)',
                          'R');
     raise;
  end;

  g_package_index := g_package_index+1;
  g_package_body(g_package_index ) := indent || 'end ' ||
                              l_package_name || ';';

  --
  -- Compile the header and body.
  --

  hr_dm_library.run_sql( l_header );
  hr_dm_library.run_sql( g_package_body,
                         g_package_index);


  -- check the status of the package


  -- check the status of the package
  begin
    hr_dm_library.check_compile (p_object_name => l_package_name,
                                 p_object_type => 'PACKAGE BODY' );
  exception
    when others then
     hr_dm_utility.error(SQLCODE,'Error in compiling TDS for ' ||
                         p_table_info.table_name ,'(none)','R');
     raise;
  end;

  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tds.create_tds_pacakge',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tds.create_tds_pacakge ',
                         '(none)','R');
     raise;
end create_tds_pacakge ;

end hr_dm_gen_tds;

/
