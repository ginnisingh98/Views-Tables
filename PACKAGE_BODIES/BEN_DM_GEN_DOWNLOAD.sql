--------------------------------------------------------
--  DDL for Package Body BEN_DM_GEN_DOWNLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DM_GEN_DOWNLOAD" as
/* $Header: benfdmgndn.pkb 120.0 2006/05/04 04:48:57 nkkrishn noship $ */

g_package  varchar2(100) := 'ben_dm_gen_download.' ;
type t_varchar2_32k_tbl is table of varchar2(32767) index by binary_integer;

-- to store the package body in to array so as to overcome the limit of 32767
-- character the global variable is defined.
g_package_body    dbms_sql.varchar2s;
g_package_index   number := 0;
g_columns_tbl     hr_dm_library.t_varchar2_tbl;
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
  l_proc       varchar2(100);
begin
  l_proc := g_package||'indent' ;

  l_spaces := hr_dm_library.indent(p_indent_spaces => p_indent_spaces,
                                   p_newline       => p_newline);
  return l_spaces;
exception
  when others then
     ben_dm_utility.error(SQLCODE,l_proc ,
                         '(p_indent_spaces - ' || p_indent_spaces ||
                         ')(p_newline - ' || p_newline || ')',
                         'R');
end indent;


--------------------- init_package_body----------------------------------------
-- This package will delete all the elements from the package body pl/sql table.
-------------------------------------------------------------------------------
procedure init_package_body is
  l_index      number := g_package_body.first;
  l_proc       varchar2(75) ;
begin
  l_proc  := g_package|| 'init_package_body' ;
  hr_utility.set_location('Entering : ' || l_proc , 5 ) ;

  ben_dm_utility.message('ROUT','entry: '|| l_proc , 5);

  -- delete all elements from package body pl/sql table.
  while l_index is not null loop
    g_package_body.delete(l_index);
    l_index := g_package_body.next(l_index);
  end loop;
  --initialize the index
  g_package_index := 0;
  ben_dm_utility.message('ROUT','exit :' || l_proc , 25);
  hr_utility.set_location('Leaving : ' || l_proc , 10 ) ;
exception
  when others then
     ben_dm_utility.error(SQLCODE,l_proc, '(none)','R');
     raise;
end init_package_body;


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
    ben_dm_utility.error(SQLCODE,'hr_dm_gen_tds.format_comment',
                        '(p_ins_blank_lines - ' || p_ins_blank_lines ||
                        ')(p_indent_spaces - ' || p_indent_spaces ||
                        ')(p_comment_text - ' || p_comment_text || ')'
                        ,'R');
end format_comment;




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

  ben_dm_utility.message('ROUT','entry:hr_dm_gen_tds.add_to_package_body-1', 5);
  ben_dm_utility.message('PARA','(p_proc_body_tbl - table of varchar2' ,10);

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
  ben_dm_utility.message('INFO',
                        '(l_loop_cnt - ' || l_loop_cnt ||
                        ')(l_string_index - ' ||l_string_index ||
                        ')( g_package_index - ' ||  g_package_index || ')'
                         ,15);
  ben_dm_utility.message('ROUT','exit:hr_dm_gen_tds.add_to_package_body -1',
                         25);
exception
  when others then
     ben_dm_utility.error(SQLCODE,'hr_dm_gen_tds.add_to_package_body-1',
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
  p_table_info       in     t_ben_dm_table,
  p_from_clause      in out nocopy    varchar2,
  p_lpad_spaces      in     number    default 2
) is
  l_derive_sql     ben_dm_tables.derive_sql%type;
  l_start_ptr      number;
  l_end_ptr        number;
  l_where_string   varchar2(25) := 'where';
  l_terminator     varchar2(5) := ';';
  l_proc           varchar2(75) ;
begin
  l_proc    := g_package||'get_derive_from_clause' ;

  hr_utility.set_location('Entering '|| l_proc, 5) ;

  ben_dm_utility.message('ROUT','entry: '|| l_proc , 5);
  ben_dm_utility.message('PARA','(p_from_clause - ' || p_from_clause ||
                             ')(p_lpad_spaces - ' || p_lpad_spaces ||
                             ')', 10);

  l_derive_sql := p_table_info.derive_sql;


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

  ben_dm_utility.message('ROUT','exit: ' || l_proc , 25);
  ben_dm_utility.message('PARA','(p_from_clause - ' || p_from_clause || ')',30);
  hr_utility.set_location('Leaving '|| l_proc, 5) ;
exception
  when others then
     ben_dm_utility.error(SQLCODE,'hr_dm_gen_tds.get_derive_from_clause',
                        '(l_derive_sql - ' || l_derive_sql ||
                        ')(l_end_ptr - ' || l_end_ptr ||
                        ')(p_from_clause - ' || p_from_clause || ')'
                        ,'R');
     raise;
end get_derive_from_clause;
---


-- ------------------------------------------------------------------------
procedure get_dt_cursor_where_clause
(
  p_table_info       in     t_ben_dm_table,
  p_where_clause     out nocopy    varchar2,
  p_lpad_spaces      in     number    default 2
) is

  l_start_ptr      number;
  l_end_ptr        number;
  l_where_string   varchar2(25) := 'where';
  l_terminator     varchar2(5) := ';';
  l_derive_sql         ben_dm_tables.DERIVE_SQL%type  ;
  l_proc               varchar2(75);


begin

  l_proc := g_package|| 'get_dt_cursor_where_clause' ;
  hr_utility.set_location(' Entering '|| l_proc, 5 ) ;

  ben_dm_utility.message('ROUT','entry:' || l_proc  , 5);

  l_derive_sql := p_table_info.derive_sql ;
  if l_derive_sql is not null then


         -- if terminator ';' is there in derive sql then set the terminator to null.
        if instr(l_derive_sql,';')  > 0 then
           l_terminator := null;
        end if;

        -- if 'where' string is not there then add the where string.
        if instr(lower(l_derive_sql),'where')  <= 0 then
            p_where_clause := '  where ';
        end if;

        l_end_ptr := instr(l_derive_sql,':') - 1;
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

     return;
  end if;
  p_where_clause := lpad(' ',p_lpad_spaces) || ' ';


  ben_dm_utility.message('ROUT','exit:' || l_proc , 25);
  hr_utility.set_location('Leaving '|| l_proc, 10 ) ;
exception
  when others then
     ben_dm_utility.error(SQLCODE,'hr_dm_gen_tds.get_dt_cursor_where_clause',
                         '(none)','R');
     raise;
end get_dt_cursor_where_clause;


-- ----------------------- prepare_download_cursor --------------------------------
-- ------------------------------------------------------------------------
procedure prepare_download_cursor
(
  p_table_info       in          t_ben_dm_table,
  p_cursor           out nocopy  varchar2
  --p_person_id        in          number
)
is
  l_cursor_comment       varchar2(2000);
  l_cursor_defination    varchar2(2000);
  l_cursor_select_cols   varchar2(32767);
  l_cursor_select_from   varchar2(32767);
  l_cursor_select_where  varchar2(32767);
  l_columns_tbl          hr_dm_library.t_varchar2_tbl;
  l_prefix_col           varchar2(30);
  l_proc                 varchar2(75) ;
begin
  l_proc   := g_package || 'prepare_download_cursor' ;
  hr_utility.set_location('Entering '||  l_proc, 5 ) ;
  ben_dm_utility.message('ROUT','entry: ' || l_proc  , 5);



  l_columns_tbl :=  g_columns_tbl;


  -- comments about the cursor
  l_cursor_comment := indent || '--' || indent || '-- cursor to select the data from the ' ||
                      p_table_info.table_name || ' table to be migrated.'|| indent || '--';

  l_cursor_comment := format_comment(' cursor to select the data from the '
                      || p_table_info.table_name ,2 );
  l_cursor_defination := ' cursor csr_ben_mig' || p_table_info.table_alias || ' is ';
  --
  -- for normal main query the column name will be alias.col1,alias.col2 but
  -- for sub query it will be alias1.col1,alias1.col2
  --
  l_prefix_col :=  p_table_info.table_alias || '1.';


  -- select all the column from  the table
  if p_table_info.datetrack = 'Y' then
     l_cursor_select_cols :=  ' Select  distinct ' ||  p_table_info.table_alias || '.*' ;
  else
     l_cursor_select_cols :=  ' Select ' ||  p_table_info.table_alias || '.*' ;
  end if;


  --l_cursor_select_from := '  from ' || p_table_info.table_name || ' ' ||  p_table_info.table_alias ;

  -- get where clause for date track
  get_dt_cursor_where_clause (p_table_info   => p_table_info,
                              p_where_clause => l_cursor_select_where);



  -- finally put the components of where clause together
  p_cursor := l_cursor_comment      || indent ||
              l_cursor_defination   || indent ||
              l_cursor_select_cols  || indent ||
             /* l_cursor_select_from  || indent || */
               l_cursor_select_where || indent;

  ben_dm_utility.message('ROUT','exit:'|| l_proc , 25);
  ben_dm_utility.message('PARA','(p_cursor - ' || p_cursor || ')' ,30);
  hr_utility.set_location('Leaving '||  l_proc, 5 ) ;
exception
  when others then
     ben_dm_utility.error(SQLCODE,'hr_dm_gen_tds.prepare_download_cursor',
                         '(none)','R');
     raise;
end prepare_download_cursor;




-- ----------------------- generate_download --------------------------------
-- Description:
-- Generates the download procedure of the TDS
-- ------------------------------------------------------------------------
procedure generate_download
(
  p_table_info              in     t_ben_dm_table,
  p_migration_id            in     number,
  --p_group_order             in     number,
  --p_person_id               in     number,
  --p_business_group_name     in     varchar2,
  p_header                  in out nocopy varchar2
)
is
  l_interface    varchar2(32767);
  l_locals       varchar2(32767) := null;
  l_cursor       varchar2(32767) := null;
  l_adt_cursor   varchar2(32767) := null;
  l_comment      varchar2(4000);
  l_proc_comment varchar2(4000);
  l_cursor_name  varchar2(30) := 'csr_ben_mig' || p_table_info.table_alias;
  l_func_name    varchar2(30) := 'Download';
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

  l_proc_body_tbl        t_varchar2_32k_tbl;
  l_proc_index           number := 1;



  cursor c_pk_hier (c_tbl_id number) is
  select bdt.table_alias
         ,bdm.column_name
         ,bdm.parent_table_name
         ,bdm.parent_column_name
         ,bdm.parent_id_column_name
  from  ben_dm_hierarchies bdm , ben_dm_tables bdt
  where bdm.HIERARCHY_TYPE = 'S'
  and  bdm.table_id = c_tbl_id
  and  bdm.parent_table_name = bdt.table_name
  ;

   cursor c_cols_map (c_tbl_id number , c_table_name  varchar2) is
  select a.column_name ,
         a.entity_result_column_name
  from   ben_dm_column_mappings a ,
         sys.all_tab_columns  b
  where  a.table_id = c_tbl_id
    and  a.column_name = b.column_name
    and  b.table_name = c_table_name
  order by a.entity_result_column_name
 ;


  l_proc    varchar2(75)  ;
begin
  l_proc   := g_package||'generate_download' ;

  hr_utility.set_location('Entering '|| l_proc , 5 ) ;
  ben_dm_utility.message('ROUT','entry:' || l_proc , 5);

  l_columns_tbl :=  g_columns_tbl;
  l_func_name   := 'download';

  -- input parameters for the procedure

  l_interface :=  indent ||
  '(p_migration_id         in  number,'    || indent ||
  ' p_business_group_id    in  number,'    || indent ||
  ' p_business_group_name  in  varchar2,'  || indent ||
  ' p_person_id            in  number,'    || indent ||
  ' p_group_order          in  number,'    || indent ||
  ' p_rec_downloaded       out nocopy number'||  indent||
  ' )' ||   indent;


  l_proc_body_tbl(l_proc_index) := l_interface;
  l_proc_index := l_proc_index + 1;



  -- call prepare_down_load procedure to create the cursor.
  prepare_download_cursor ( p_table_info   => p_table_info,
                              p_cursor       => l_cursor
                          --    p_person_id    => p_person_id
                           );
  -- local variables of the procedure

  l_locals := indent ||
              '  -- Declare local variables' || indent ||
              '  l_proc                         varchar2(72) := g_package ' ||
              '|| ''' || l_func_name || ''' ;' || indent ||
              '  l_link_value                   number;' || indent ||
              '  l_rec_inserted_cnt             number := 0;' || indent ||
              '  l_result_id                    number     ;' || indent ||
              '  l_return_fk_id                 number     ;' || indent ||
              '  l_row_fetched                  boolean := FALSE;' || indent;
  --end if;

  -- message (' l_cursor = ' || l_cursor);
  -- add the body of the download procedure

  l_indent := 3;
  l_proc_body_tbl(l_proc_index) := indent(l_indent) ||
                 'l_rec_inserted_cnt := 0;' || indent(l_indent) || indent(l_indent) ||
                 'hr_utility.set_location(''Entering : '' || l_proc,5) ; ' || indent(l_indent) ||
                 'ben_dm_utility.message(''ROUT'','' Entering  '' ||l_proc,5) ; ' || indent(l_indent) ||
                 'ben_dm_utility.message(''PARA'', '' ( Person - ''  || p_person_id  || '')'' , 10) ;'||  indent(l_indent) ||
                 'ben_dm_utility.message(''PARA'', '' ( Source BG  - '' || p_business_group_id  || '')'' , 10) ;'||  indent(l_indent) ||
                 'ben_dm_utility.message(''PARA'', '' ( Target BG  - '' || p_business_group_name  || '')'' , 10) ;'||  indent(l_indent)||
                 'ben_dm_utility.message(''PARA'', '' ( group_order  - '' || p_group_order  || '')'' , 10) ; '|| indent(l_indent) ;

  l_proc_index := l_proc_index + 1;
 /*
  add_debug_messages (p_table_info       => p_table_info,
                      p_procedure_name   => l_func_name,
                      p_message_location => 'START',
                      p_proc_body        => l_debug_message_text);
 */
  l_proc_body_tbl(l_proc_index) := l_debug_message_text;
  l_proc_index := l_proc_index + 1;
  --l_indent := 4;

  -- open  the cursor in for loop so u dont have to check   found
  l_proc_body_tbl(l_proc_index) := indent(l_indent) ||
  'For l_table_rec in  ' || l_cursor_name ||  indent(l_indent) || 'loop';
  l_proc_index := l_proc_index + 1;
  l_indent := 6;

  l_proc_body  :=  indent(l_indent) || '--Call procedure to  download all Mapping Key  of ' ||
                      upper(p_table_info.table_name) || indent(l_indent)  ;

  --  download the mapping keys
  for  l_pk_rec  in   c_pk_hier(p_table_info.table_id )   Loop

       l_proc_body := l_proc_body||indent(l_indent)  || '--' || 'Get the Key for '||l_pk_rec.parent_table_name ||'.'||
                               l_pk_rec.parent_column_name  || indent(l_indent)  ;
       l_proc_body := l_proc_body|| 'If l_table_rec.'||l_pk_rec.column_name||' IS NOT NULL THEN '||indent(l_indent+3);
       l_proc_body := l_proc_body|| 'ben_dm_download_dk.get_dk_frm_'||l_pk_rec.table_alias||' ( '
                                 || indent(l_indent+3) ;
       l_proc_body := l_proc_body||'p_business_group_name => p_business_group_name , ' || indent(l_indent+3);
       l_proc_body := l_proc_body||'p_resolve_mapping_id  => l_return_fk_id , ' || indent(l_indent+3);
       l_proc_body := l_proc_body||'p_source_id      =>   l_table_rec.'||l_pk_rec.column_name||indent(l_indent+3);
       l_proc_body := l_proc_body||  ');' || indent(l_indent) ;
       l_proc_body := l_proc_body|| 'End If ; '||indent(l_indent) ;
   End Loop ;
   -- end of call to get the FK values

  l_proc_body_tbl(l_proc_index) := l_proc_body;
  l_proc_index := l_proc_index + 1;


  --- call the procedure to upload the values into result table
  l_proc_body  :=  indent ||
                   indent||indent(l_indent)||
                    '-- Insert the values into result entity table ' || indent(l_indent) ;
  l_indent := 10;
  l_proc_body  :=  l_proc_body||  'ben_dm_data_util.create_entity_result(' || indent(l_indent) ;
  l_proc_body  :=  l_proc_body|| ' p_entity_result_id   =>  l_result_id ' || indent(l_indent) ;
  l_proc_body  :=  l_proc_body|| ',p_migration_id       =>  p_migration_id ' || indent(l_indent) ;
  l_proc_body  :=  l_proc_body|| ',p_table_name         =>  '||'''' ||p_table_info.table_name||''''||  indent(l_indent) ;
  l_proc_body  :=  l_proc_body|| ', p_group_order       =>  p_group_order '||  indent(l_indent) ;
  for l_cols_map in c_cols_map(p_table_info.table_id, p_table_info.table_name ) Loop
     l_proc_body  :=  l_proc_body|| ',p_'||rpad(l_cols_map.ENTITY_RESULT_COLUMN_NAME,30 )|| ' => l_table_rec.'||
                      l_cols_map.COLUMN_NAME  || indent(l_indent);
  end Loop ;
  l_proc_body  :=  l_proc_body|| ');' || indent(l_indent) ;
  l_proc_body  := l_proc_body|| 'l_rec_inserted_cnt := l_rec_inserted_cnt + 1 ; ' ;
  l_proc_body_tbl(l_proc_index) := l_proc_body;
  l_proc_index := l_proc_index + 1;
  l_proc_body :=  null  ;

  l_indent := 3;
  l_proc_body_tbl(l_proc_index) :=  indent(l_indent)  ||
  'end loop;' ||  indent(l_indent ) /*|| 'commit;' */ || indent(l_indent ) ||
  'p_rec_downloaded := l_rec_inserted_cnt;' ||  indent(l_indent)    ||
                       'ben_dm_utility.message(''INFO'','' Record  Inserterd  '' ||l_rec_inserted_cnt,5) ; '
                       ||  indent(l_indent) ;
  l_proc_index := l_proc_index + 1;

  --l_indent := 0;
  l_debug_message_text  := indent(l_indent) || 'hr_utility.set_location(''Leaving : '' || l_proc,5) ; '||
                           indent(l_indent) ||' ben_dm_utility.message(''ROUT'','' Exit  '' ||l_proc,5) ; ' ||
                           indent  || 'End  ' || l_func_name || ' ; ' ;
  l_proc_body_tbl(l_proc_index) := l_debug_message_text;
  l_proc_index := l_proc_index + 1;


  -- add the procedure comment defination to the package header and body
  p_header := p_header || l_proc_comment ||'procedure ' || l_func_name ||
              l_proc_body_tbl(1) ||  ';';
  l_proc_body_tbl(1) :=  l_proc_comment || 'procedure ' || l_func_name ||
             l_proc_body_tbl(1) ||  'is';

  -- add local variables , cursor and procedure body to complete the procedure
  l_proc_body_tbl(1) := l_proc_body_tbl(1) || l_cursor ||  /* l_adt_cursor || */
     l_locals  || l_prv_proc_body ||  indent ||'begin' || indent ;

  -- add the body of this procedure to the package.
  add_to_package_body( l_proc_body_tbl );

  ben_dm_utility.message('ROUT','exit:'||l_proc, 25);
  hr_utility.set_location('Leaving '|| l_proc , 5 ) ;
exception
  when others then
     ben_dm_utility.error(SQLCODE,l_proc, '(none)','R');
     raise;
end generate_download;


-- ------------------------- main  ------------------------
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
procedure main
(
--p_business_group_id      in   number,
-- p_person_id              in   number,
-- p_group_order            in   number,
-- p_business_group_name    in   varchar2,
 p_table_alias            in   varchar2,
 p_migration_id           in   number
)
is
  l_header                  varchar2(32767);
  l_body                    varchar2(32767);
  l_header_comment          varchar2(2048);
  l_package_name            varchar2(30)  ;
  l_generator_version       hr_dm_tables.generator_version%type;
  l_package_version         varchar2(200);
  l_index                   number := 1;
  l_proc_body_tbl           t_varchar2_32k_tbl;
  l_proc_index              number := 1;
  l_proc         varchar2(75) ;


  cursor c_tbl is
  select  TABLE_ID
         ,TABLE_NAME
         ,UPLOAD_TABLE_NAME
         ,TABLE_ALIAS
         ,DATETRACK
         ,DERIVE_SQL
         ,SURROGATE_PK_COLUMN_NAME
         ,SHORT_NAME
         ,LAST_GENERATED_DATE
         ,GENERATOR_VERSION
         ,SEQUENCE_NAME
         ,LAST_UPDATE_DATE
  from  ben_dm_tables
  where  table_alias = p_table_alias
  ;
  l_tbl_rec   t_ben_dm_table  ;




begin

  l_proc  :=  g_package || 'main' ;
  hr_utility.set_location('Entering:'||l_proc, 5);

  ben_dm_utility.message('ROUT','entry:'||l_proc , 5);


  -- opne the tabl curso and get the table informatons
  open c_tbl  ;
  fetch c_tbl into l_tbl_rec ;
  if c_tbl%NotFound then
     close c_tbl  ;
     --raise ;
  end if ;
  close c_tbl  ;


  ben_dm_utility.message('PARA','(Table Name - '||l_tbl_rec.table_name|| ')', 10);

  l_package_name    := 'ben_dmd' ||  lower(l_tbl_rec.short_name );
  -- inialize the global package body pl/sql table by deleting all elements.
  init_package_body;

  -- Get the version of the generator to be appended to the TDS package
  -- generated for a table. This will help in finding out which version
  -- of  Generator is used to generate the TDS package.

  ben_dm_data_util.get_generator_version(p_generator_version  => l_generator_version,
                                       p_format_output      => 'Y');

  -- Get the package version of this TDS package body.
  hr_dm_library.get_package_version ( p_package_name     => 'BEN_DM_GEN_DOENLOAD',
                                      p_package_version  =>  l_package_version,
                                      p_version_type     => 'FULL');



  -- Start the package header and body.
  begin
    --
    -- Set up initial parts of the package header and body.
    --
    l_header_comment :=  l_package_version || indent ||  '/*' || indent ||
    ' * Generated by ' || l_proc ||': '||to_char(sysdate,'YYYY/MM/DD HH24:MM:SS')||indent||
    ' * Generated Person Migrator TDS for : ' || l_tbl_rec.table_name || '.'||indent ||
    ' * Generator Version Used to generate this TDS is : ' || indent ||
    l_generator_version ||  indent ||
    ' */' || indent || '--' || indent;

    l_header :=
    'create or replace package ' || l_package_name||' as'||indent||l_header_comment ||
    'g_generator_version constant varchar2(128) default ' ||
    '''$Revision: 120.0 $'';' || indent || '--' || indent;

    l_proc_body_tbl(1) :=
    'create or replace package body ' || l_package_name || ' as' || indent ||
    l_header_comment;

    -- private package variable
    l_proc_body_tbl(1) :=  l_proc_body_tbl(1) || indent || '--' ||
               indent || '--  Package Variables' || indent ||
              '--' || indent ||
              'g_package  varchar2(50) := ''' || l_package_name || '.'';' ||
               indent;

    -- add the body of this procedure to the package.
    add_to_package_body( l_proc_body_tbl );
    --
    -- Generate the procedures and functions.
    --



    -- if the table has a columns which have a foreign key table then
    -- generate call in body to get the value in bn_dm_column_maping table
    -- th following look create code to call the proceurde get_dk_frm_<alias>
    -- corresponding developer's key for those columns.

  --  l_body := l_body || indent || '--' || indent;



    -- down load procedure to download all columns.
    generate_download(
                      p_table_info              =>     l_tbl_rec,
                      p_migration_id            =>     p_migration_id,
                      --p_group_order             =>     p_group_order,
                      --p_person_id               =>     p_person_id,
                      --p_business_group_name     =>     p_business_group_name,
                      p_header                  =>     l_header ) ;

    l_header := l_header || indent || '--' || indent;
    l_header := l_header || indent || '--' || indent;
    l_header := l_header || 'end ' || l_package_name || ';';
   -- l_body := l_body || 'end ' || l_package_name || ';';
  exception
    when plsql_value_error then
     ben_dm_utility.error(SQLCODE,'hr_dm_gen_tds.create_tds_pacakge',
                         'Either TDS package code size is too big or  ' ||
                          ' a value error)',
                          'R');
     raise;
  end;

  g_package_index := g_package_index+1;
  g_package_body(g_package_index ) := indent || 'end ' ||
                              l_package_name || ';';

  hr_utility.set_location('PACKAGE BODY :'||l_package_name, 5);
  --
  -- Compile the header and body.
  --

  hr_dm_library.run_sql( l_header );
  hr_dm_library.run_sql( g_package_body,
                         g_package_index);


  -- check the status of the package
   hr_utility.set_location('PACKAGE BODY :'||l_package_name, 5);
  -- check the status of the package
  begin
    hr_dm_library.check_compile (p_object_name => l_package_name,
                                 p_object_type => 'PACKAGE BODY' );
  exception
    when others then
     ben_dm_utility.error(SQLCODE,'Error in compiling TDS for ' ||
                         l_tbl_rec.table_name ,'(none)','R');
     raise;
  end;

  ben_dm_utility.message('ROUT','exit:'|| l_proc , 25);
  hr_utility.set_location('Leaving:'||l_proc, 10);
exception
  when others then
     ben_dm_utility.error(SQLCODE,'hr_dm_gen_tds.create_tds_pacakge ',
                         '(none)','R');
     raise;
end main ;

end BEN_DM_GEN_DOWNLOAD;

/
