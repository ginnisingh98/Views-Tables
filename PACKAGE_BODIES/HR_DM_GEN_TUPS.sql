--------------------------------------------------------
--  DDL for Package Body HR_DM_GEN_TUPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DM_GEN_TUPS" as
/* $Header: perdmgnu.pkb 120.1 2005/08/14 23:22:37 mmudigon noship $ */


type t_varchar2_32k_tbl is table of varchar2(32767) index by binary_integer;

--
-- this record stores the information to build and call the chk_row_exists
-- procedure. It will be used only if criteia to check whether row exists
-- is other than the primary key. This will be populated only if the
-- table need to use non primary key columns.
--
type t_chk_row_exists is record
(
  where_clause                 varchar2(32767),
  call_to_proc                 varchar2(32767),
  proc_parameters              varchar2(32767)
);

--
-- this record stores the information to build and call the delete_dml
-- procedure. It will be used only if criteia to check whether row exists
-- is other than the primary key. This will be populated only if the
-- table need to use non primary key columns.
--
type t_delete_dml is record
(
  where_clause                 varchar2(32767),
  call_to_proc                 varchar2(32767),
  proc_parameters              varchar2(32767)
);

g_table_info                  hr_dm_gen_main.t_table_info;
g_columns_tbl                 hr_dm_library.t_varchar2_tbl;
g_parameters_tbl              hr_dm_library.t_varchar2_tbl;
g_hier_columns_tbl            hr_dm_library.t_varchar2_tbl;
g_hier_parameters_tbl         hr_dm_library.t_varchar2_tbl;
g_aol_columns_tbl             hr_dm_library.t_varchar2_tbl;
g_aol_parameters_tbl          hr_dm_library.t_varchar2_tbl;
g_pk_columns_tbl              hr_dm_library.t_varchar2_tbl;
g_pk_parameters_tbl           hr_dm_library.t_varchar2_tbl;
g_fk_to_aol_columns_tbl       hr_dm_gen_main.t_fk_to_aol_columns_tbl;
g_resolve_pk_columns_tbl      hr_dm_gen_main.t_fk_to_aol_columns_tbl;
g_surrogate_pk_col_param      varchar2(30);
g_no_of_pk_columns            number;
g_chk_row_exists              t_chk_row_exists;
g_delete_dml                  t_delete_dml;
g_exception_tbl               hr_dm_library.t_varchar2_tbl;

-- to store the package body in to array so as to overcome the limit of 32767
-- character the global variable is defined.
g_package_body    dbms_sql.varchar2s;
g_package_index   number := 0;
/*
c_newline               constant varchar(1) default '
';
*/

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
--------------------- migrate_table_data----------------------------------------
-- This function will decide if the table is on the exception list
-- Exception list is maintained here for now
-------------------------------------------------------------------------------
function migrate_table_data (p_table_info  in  hr_dm_gen_main.t_table_info )
return boolean is

l_migrate boolean := true;
begin

   g_exception_tbl.delete;
   g_exception_tbl(1) := 'HR_DMV_FF_FORMULAS_F';

   for i in 1.. g_exception_tbl.count
   loop
       if  upper(p_table_info.table_name) = g_exception_tbl(i) then
           l_migrate := false;
           exit;
       end if;
   end loop;

   return l_migrate;

end migrate_table_data;
--------------------- init_package_body----------------------------------------
-- This package will delete all the elements from the package body pl/sql table.
-------------------------------------------------------------------------------
procedure init_package_body is
  l_index      number := g_package_body.first;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tups.init_package_body', 5);
  -- delete all elements from package body pl/sql table.
  while l_index is not null loop
    g_package_body.delete(l_index);
    l_index := g_package_body.next(l_index);
  end loop;


  -- delete all elements from resolve_pk pl/sql table.
  l_index := g_resolve_pk_columns_tbl.first;

  while l_index is not null loop
    g_resolve_pk_columns_tbl.delete(l_index);
    l_index := g_resolve_pk_columns_tbl.next(l_index);
  end loop;

  --initialize the index
  g_package_index := 0;

  g_chk_row_exists.where_clause             := null;
  g_chk_row_exists.call_to_proc     := null;
  g_chk_row_exists.proc_parameters  := null;

  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tups.init_package_body',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.init_package_body',
                         '(none)','R');
     raise;
end init_package_body;

-- -----------------------add_to_package_body; ---------------------------------
-- Description:
-- This procedure will be called by each procedure to be created by TUPS.
-- Each procedure will be stored in the array of varchar2(32767).
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

  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tups.add_to_package_body-1', 5);
  hr_dm_utility.message('PARA','(p_proc_body_tbl - table of varchar2',10);

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
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tups.add_to_package_body -1',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.add_to_package_body-1',
                        '(l_loop_cnt - ' || l_loop_cnt ||
                        ')(l_string_index - ' ||l_string_index ||
                        ')( g_package_index - ' ||  g_package_index || ')'
                        ,'R');
     raise;
end add_to_package_body;

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
    hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.format_comment',
                        '(p_ins_blank_lines - ' || p_ins_blank_lines ||
                        ')(p_indent_spaces - ' || p_indent_spaces ||
                        ')(p_comment_text - ' || p_comment_text || ')'
                        ,'R');
end format_comment;
------- prepare_code_for_resolving_pk(Overloaded)-----------------------
-- Description:
-- This function will
--    - Creates a call to the function to get the get the id value
--      in the parent table of destination corresponding to the
--      given parent id value of source database.
--  Input Parameters
--      g_pk_columns_tbl        - Contains the information about all the columns
--                                whose primary key has to be resolved.
--      p_table_info            - Contains the info about the table to be
--                                downloaded
--  Out Parameters
--      p_call_to_proc_body     - returns the string for a call to the function
--      p_dev_key_local_var_body - returns the string defining local variable
-- ------------------------------------------------------------------------
 procedure prepare_code_for_resolving_pk
(
  p_pk_columns_tbl           in     hr_dm_library.t_varchar2_tbl,
  p_table_info               in     hr_dm_gen_main.t_table_info,
  p_call_to_proc_body        in out nocopy varchar2,
  p_local_var_body           in out nocopy varchar2
)
is
  l_interface               varchar2(32767);
  l_locals                  varchar2(32767) := null;
  l_cursor                  varchar2(32767) := null;
  l_where_clause            varchar2(32767) := null;
  l_proc_comment            varchar2(4000);
  l_cursor_name             varchar2(30) := 'csr_get_id_val';
  l_proc_name               varchar2(32767);
  l_proc_body_tbl           t_varchar2_32k_tbl;

  -- variables to store the information about p_pk_columns_tbl elements.
  -- this is to reduce the variable name and add clarity.
  l_column_name               hr_dm_hierarchies.column_name%type;


  -- block body of the procedure i.e between begin and end.
  l_proc_body   varchar2(32767) := null;

  -- indentation for the statements.it specifies number of blank spaces
  -- after which the statment should start.

  l_indent                  number;
  l_index    number := g_pk_columns_tbl.first;
  l_index2   number;
  l_duplicate number;

begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tups.prepare_code_for_resolving_pk ', 5);


  while l_index is not null loop
    l_column_name    :=
                   p_pk_columns_tbl(l_index);

     -- construct a call to the procedure created above.
    l_indent := 4;
    p_call_to_proc_body  := p_call_to_proc_body  || indent ||
         format_comment('Get the id value in the destination database for ' ||  l_column_name ||
                        ' from table ' || p_table_info.table_name  || ' corresponding to ' ||
                        ' the value in source database.',
                        l_indent) || indent(l_indent);

   p_call_to_proc_body  :=  p_call_to_proc_body  ||
                   'hr_dm_library.get_resolved_pk  ('   ||
                   'p_table_name       => ''' || upper(p_table_info.table_name) || '''' ||
                   indent(l_indent+32) ||
                   ', p_source_id      => ' ||rpad('p_' || l_column_name,30)
                   || indent(l_indent+32) ||
                   ', p_destination_id => ' || rpad('l_' || l_column_name,30)
                   || ');'  || indent(l_indent);

    -- construct the definition of local variable
    l_indent := 4;

    -- ensure we only add each local variable once.
    l_duplicate := 0;
    l_index2 := g_pk_columns_tbl.first;
    while l_index2 <= l_index loop
       if (l_column_name =
                   g_pk_columns_tbl(l_index2)) then
        l_duplicate := l_duplicate + 1;
      end if;
      l_index2   := g_pk_columns_tbl.next(l_index2);
    end loop;
    if l_duplicate = 1 then
      p_local_var_body := p_local_var_body || indent(l_indent)
            || 'l_' || rpad(l_column_name,28) || '  ' ||
            p_table_info.upload_table_name  || '.' || l_column_name ||'%type;';
    end if;
    l_index   := g_pk_columns_tbl.next(l_index);
  end loop;
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tups.prepare_code_for_resolving_pk',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.prepare_code_for_resolving_pk',
                         '(none)','R');
     raise;
end prepare_code_for_resolving_pk;
------- prepare_code_for_resolving_pk(Overloaded)-----------------------
-- Description:
-- This function will
--    - Creates a call to the function to get the get the id value
--      in the parent table of destination corresponding to the
--      given parent id value of source database.
--  Input Parameters
--      g_resolve_pk_columns_tbl - Contains the information about all the columns
--                                whose primary key has to be resolved.
--      p_table_info            - Contains the info about the table to be
--                                downloaded
--  Out Parameters
--      p_call_to_proc_body     - returns the string for a call to the function
--      p_dev_key_local_var_body - returns the string defining local variable
-- ------------------------------------------------------------------------
 procedure prepare_code_for_resolving_pk
(
  p_resolve_pk_columns_tbl   in     hr_dm_gen_main.t_fk_to_aol_columns_tbl,
  p_table_info               in     hr_dm_gen_main.t_table_info,
  p_call_to_proc_body        in out nocopy varchar2,
  p_local_var_body           in out nocopy varchar2
)
is
  l_interface               varchar2(32767);
  l_locals                  varchar2(32767) := null;
  l_cursor                  varchar2(32767) := null;
  l_where_clause            varchar2(32767) := null;
  l_proc_comment            varchar2(4000);
  l_cursor_name             varchar2(30) := 'csr_get_id_val';
  l_proc_name               varchar2(32767);
  l_proc_body_tbl           t_varchar2_32k_tbl;

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
  -- after which the statment should start.

  l_indent                  number;
  l_index    number := g_resolve_pk_columns_tbl.first;
  l_index2   number;
  l_duplicate number;

begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tups.prepare_code_for_resolving_pk ', 5);


  while l_index is not null loop
    l_column_name    :=
                   g_resolve_pk_columns_tbl(l_index).column_name;
    l_parent_table_id    :=
                   g_resolve_pk_columns_tbl(l_index).parent_table_id;
    l_parent_table_name    :=
                   g_resolve_pk_columns_tbl(l_index).parent_table_name;
    l_parent_table_alias    :=
                   g_resolve_pk_columns_tbl(l_index).parent_table_alias;
    l_parent_column_name    :=
                   g_resolve_pk_columns_tbl(l_index).parent_column_name;
    l_parent_id_column_name    :=
                   g_resolve_pk_columns_tbl(l_index).parent_id_column_name;

     -- construct a call to the procedure created above.
    l_indent := 2;
    p_call_to_proc_body  := p_call_to_proc_body  || indent ||
         format_comment('Get the id value in the destination database for ' ||  l_column_name ||
                        ' from parent table ' || l_parent_table_name  || ' corresponding to ' ||
                        ' the value in source database.',
                        l_indent) || indent(l_indent);

   p_call_to_proc_body  :=  p_call_to_proc_body  ||
                   'hr_dm_library.get_resolved_pk  ('   ||
                   'p_table_name       => ''' || upper(l_parent_table_name) || '''' ||
                   indent(l_indent+32) ||
                   ', p_source_id      => ' ||rpad('p_' || l_column_name,30)
                   || indent(l_indent+32) ||
                   ', p_destination_id => ' || rpad('l_' || l_column_name,30)
                   || ');'  || indent(l_indent);

    -- construct the definition of local variable
    l_indent := 2;

    -- ensure we only add each local variable once.
    l_duplicate := 0;
    l_index2 := g_resolve_pk_columns_tbl.first;
    while l_index2 <= l_index loop
       if (l_column_name =
                   g_resolve_pk_columns_tbl(l_index2).column_name) then
        l_duplicate := l_duplicate + 1;
      end if;
      l_index2   := g_resolve_pk_columns_tbl.next(l_index2);
    end loop;
    if l_duplicate = 1 then
      p_local_var_body := p_local_var_body || indent(l_indent)
            || 'l_' || rpad(l_column_name,28) || '  ' ||
            p_table_info.upload_table_name  || '.' || l_column_name ||'%type;';
    end if;
    l_index   := g_resolve_pk_columns_tbl.next(l_index);
  end loop;
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tups.prepare_code_for_resolving_pk',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.prepare_code_for_resolving_pk',
                         '(none)','R');
     raise;
end prepare_code_for_resolving_pk;
------- generate_get_id_frm_dev_key -----------------------
-- Description:
-- This function will
--    - Generates the procedure which will get the id value from the
--      AOL table for a given developer key.
--    - Creates a call to the function to get the id value from the
--      AOL table for a given developer key.
--    - Creates a local variable for the id value.
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
 procedure generate_get_id_frm_dev_key
(
  p_fk_to_aol_columns_tbl    in     hr_dm_gen_main.t_fk_to_aol_columns_tbl,
  p_table_info               in     hr_dm_gen_main.t_table_info,
  p_body                     in out nocopy varchar2,
  p_call_to_proc_body        in out nocopy varchar2,
  p_dev_key_local_var_body   in out nocopy varchar2
)
is
  l_interface               varchar2(32767);
  l_locals                  varchar2(32767) := null;
  l_cursor                  varchar2(32767) := null;
  l_where_clause            varchar2(32767) := null;
  l_proc_comment            varchar2(4000);
  l_cursor_name             varchar2(30) := 'csr_get_id_val';
  l_proc_name               varchar2(32767);
  l_proc_body_tbl           t_varchar2_32k_tbl;

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
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tups.generate_get_id_frm_dev_key ', 5);

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

    if lower(l_parent_column_name) <> 'id_flex_structure_name' then
      l_where_clause := l_parent_column_name  || ' = ' ||
                        rtrim(rpad('p_' || l_parent_column_name, 30));
    else
      l_where_clause := 'id_flex_structure_name = ' || indent(8) ||
                        'substr(p_id_flex_structure_name, 1, ' || indent(10) ||
                        'instr(p_id_flex_structure_name,''-dm-dev-key-'') - 1)'
                        || indent(6) ||
                        'and id_flex_code = ' || indent(8) ||
                        'substr(p_id_flex_structure_name, ' || indent(16) ||
                        'instr(p_id_flex_structure_name,''-dm-dev-key-'') + 12' ||
                        indent(16) ||
                        ', length(p_id_flex_structure_name) - ' || indent(18) ||
                        'instr(p_id_flex_structure_name,''-dm-dev-key-''))';
    end if;

    l_proc_name := 'get_id_val_frm_' ||   l_parent_table_alias;

    -- input parameters for the procedure
    l_interface :=  indent || '(' ||rpad('p_' || l_parent_column_name, 30) ||
                   ' in  varchar2,' || indent || ' ' ||
                    rpad('p_'|| l_column_name ,30) || ' out nocopy number)';

    -- local variables of the procedure

  l_locals :=  format_comment('Declare cursors and local variables',2)
               || indent ||
              '  l_proc     varchar2(72) := g_package ' ||
              '|| ''' || l_proc_name || ''';' || indent;

    -- cursor to get the link value from the sequence from the data pump table
    l_cursor := format_comment('Cursor to get the developer key from the '||
                l_parent_table_name || ' table.',2);

    l_cursor := l_cursor || indent(2) || 'cursor csr_get_id_val is ' ||
              indent(4) ||
              'select ' || l_parent_id_column_name || indent(4) ||
              'from ' || l_parent_table_name ||
              indent(4) || 'where ' || rtrim(l_where_clause) || ';';

    -- add the logic of the body

    l_indent := 2;

    l_proc_body :=  indent(l_indent) ||
    'open ' || l_cursor_name || ';' || indent(l_indent) || 'fetch ' ||
    l_cursor_name || ' into ' || rpad('p_'|| l_column_name ,30)
    || ';' || indent(l_indent) ||
    'if ' || l_cursor_name || '%notfound then' || indent(l_indent + 2) ||
    'close ' || l_cursor_name || ';' || indent(l_indent + 2) ||
    'hr_utility.raise_error;' || indent(l_indent) || 'else'
    ||indent(l_indent + 2)
    ||'close ' || l_cursor_name || ';' || indent(l_indent) || 'end if;';


    l_proc_body := l_proc_body || indent || 'end ' || l_proc_name || ';';


    l_proc_comment := format_comment('procedure to get the the id value from '
    || l_parent_table_name || ' table for ' ||
    l_parent_column_name || ' column.' ) || indent;

    -- add the procedure comment defination,local variables , cursor and
    -- procedure body

    l_proc_body_tbl(1) :=   l_proc_comment || 'procedure ' || l_proc_name ||
                     l_interface || ' is' || l_locals || l_cursor || indent ||
                     'begin' || indent || l_proc_body;

    -- add the body of this procedure to the package.
    add_to_package_body( l_proc_body_tbl );

    -- construct a call to the procedure created above.
    l_indent := 2;
    p_call_to_proc_body  := p_call_to_proc_body  || indent ||
         format_comment('Get the id value key for ' ||  l_column_name || '.',
                        l_indent);
    p_call_to_proc_body  := p_call_to_proc_body || indent(l_indent) ||
         l_proc_name || '(p_' || rpad(l_parent_column_name,28)  || ','  ||
         indent(l_indent + 19) || 'l_' ||  rpad(l_column_name,28)
         || ');';


    -- construct the defination of local variable
    l_indent := 2;
    p_dev_key_local_var_body := p_dev_key_local_var_body || indent(l_indent)
          || 'l_' || rpad(l_column_name,28) || '  ' ||
          p_table_info.upload_table_name  || '.' || l_column_name ||'%type;';
    l_index   := p_fk_to_aol_columns_tbl.next(l_index);
  end loop;
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tups.generate_get_id_frm_dev_key',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.generate_get_id_frm_dev_key',
                         '(none)','R');
     raise;
end generate_get_id_frm_dev_key;
--
-- ----------------------- prepare_glob_var_def_for_dt  ----------------------
-- Description:
-- prepares the defination of the global variables for the primary key.
-- e.g g_old_pk_col1  number;
--     g_old_pk_col2  number;
-- the data type derived from g_pk_parameters_tbl which have entries like
--      column1  in  number | column2  in  varchar2
-- use instr function in conjunction with substr to get the data type.
-- ------------------------------------------------------------------------
procedure prepare_glob_var_def_for_dt
(
  p_table_info       in        hr_dm_gen_main.t_table_info,
  p_body             in out nocopy    varchar2
) is
  l_list_index   number;
  l_count        number;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tups.prepare_glob_var_def_for_dt ', 5);

 -- initialise the variables
 l_list_index := g_pk_columns_tbl.first;
 l_count      := 1;
 --
 -- read all the elements of pl/sql table and append them into text.
 --
 p_body := p_body || format_comment ( ' Global variables to store the primary '
           || 'key columns of the last physical record processed.');

 while l_list_index is not null loop

    p_body := p_body || indent ||
            rpad('g_old_'|| g_pk_columns_tbl(l_list_index),30) || '      ' ||
             p_table_info.upload_table_name || '.' || g_pk_columns_tbl(l_list_index)
             || '%type;';

   l_list_index := g_pk_columns_tbl.next(l_list_index);
   l_count := l_count + 1;
 end loop;
 hr_dm_utility.message('ROUT','exit:hr_dm_gen_tups.prepare_glob_var_def_for_dt',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.prepare_glob_var_def_for_dt',
                         '(none)','R');
     raise;
end prepare_glob_var_def_for_dt;

--
-- ----------------------- prepare_ins_dt_delete_stmt  ----------------------
-- Description:
-- Parameter to the above procedures are  also different.
-- Prepares the call to the ins_dt_delete procedure depending upon the number
-- of primary key columns and whether table has surrogate id or not.
-- ------------------------------------------------------------------------
procedure prepare_ins_dt_delete_stmt
(
  p_table_info       in        hr_dm_gen_main.t_table_info,
  p_proc_body        in out nocopy    varchar2 ,
  p_ins_type         in        varchar2 default 'P',
  p_indent           in        number
)
is
 l_table_name  varchar2(30) := upper(p_table_info.upload_table_name);
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tups.prepare_ins_dt_delete_stmt ', 5);

 if p_table_info.surrogate_primary_key  = 'Y' then
   p_proc_body := p_proc_body ||
    'hr_dm_library.ins_dt_delete (p_id          => ' || 'p_' ||
     rpad(g_pk_columns_tbl(1),28) ||',' ||indent(p_indent + 29) ||
     'p_table_name  => '''|| l_table_name || ''','  ||
     indent(p_indent + 29) || 'p_ins_type    => ''' || p_ins_type ||
     ''');' ;
 else
  p_proc_body := p_proc_body ||
   'hr_dm_library.ins_dt_delete ( p_table_name  => '''|| l_table_name
    || ''''  ||  indent(p_indent + 29) || ',p_ins_type    => ''' ||
    p_ins_type || '''' ;
  -- add the first column of the primary key.
  p_proc_body :=  p_proc_body || indent(p_indent + 29) ||
     ',p_pk_column_1 => p_' || rpad(g_pk_columns_tbl(1),28);

  -- if the composite primary key has more than one column then add the column
  -- to the call to ins_dt procedure.
  if g_no_of_pk_columns > 1 then
    p_proc_body :=  p_proc_body || indent(p_indent + 29) ||
    ',p_pk_column_2 => p_' || rpad(g_pk_columns_tbl(2),28);
  end if;

  -- if the composite primary key has more than two column then add the column
  -- to the call to ins_dt procedure.

  if g_no_of_pk_columns > 2 then
    p_proc_body :=  p_proc_body || indent(p_indent + 29) ||
    ',p_pk_column_3 => p_' || rpad(g_pk_columns_tbl(3),28);
  end if;

  -- if the composite primary key has more than three column then add the
  -- column to the call to ins_dt procedure.

  if g_no_of_pk_columns > 3 then
    p_proc_body :=  p_proc_body || indent(p_indent + 29) ||
    ',p_pk_column_4 => p_' || rpad(g_pk_columns_tbl(4),28);
  end if;

  p_proc_body := p_proc_body || ');';
 end if;
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tups.prepare_ins_dt_delete_stmt',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.prepare_ins_dt_delete_stmt',
                         '(none)','R');
     raise;
end prepare_ins_dt_delete_stmt;
--
-- ----------------------- prepare_chk_dt_delete_stmt  ----------------------
-- Description:
-- Prepares the call to the  procedure to check the row in dt_delete table
-- depending upon the number of primary key columns and whether table has
-- surrogate id or not. The procedure name for table with surrogate_id is
--    Table Type               procedure name
--   surrogate_id              chk_row_in_dt_delete
--   1 column primary key      chk_row_in_dt_delete_1_pkcol
--   2 column primary key      chk_row_in_dt_delete_2_pkcol
--   3 column primary key      chk_row_in_dt_delete_3_pkcol
--   4 column primary key      chk_row_in_dt_delete_4_pkcol
-- ------------------------------------------------------------------------
procedure prepare_chk_dt_delete_stmt
(
  p_table_info       in        hr_dm_gen_main.t_table_info,
  p_proc_body        in out nocopy    varchar2 ,
  p_indent           in        number
)
is
 l_proc_name   varchar2(30) ;
 l_table_name  varchar2(30) := upper(p_table_info.upload_table_name);
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tups.prepare_chk_dt_delete_stmt ', 5);

  if p_table_info.surrogate_primary_key  = 'Y' then
    p_proc_body := p_proc_body ||
       'hr_dm_library.chk_row_in_dt_delete (p_id          => p_' ||
       rpad(g_pk_columns_tbl(1),28) ||',' ||indent(p_indent + 30) ||
      'p_table_name  => '''|| l_table_name || ''','  ||
      indent(p_indent + 30) || 'p_ins_type    => l_ins_type,' ||
      indent(p_indent + 30) || 'p_row_exists  => l_row_exists);';
  else
    -- form the procedure name based on the number of columns in primary
    -- key.
    l_proc_name := 'chk_row_in_dt_delete_' || to_char(g_no_of_pk_columns) ||
                   '_pkcol' ;
    p_proc_body := p_proc_body ||
       'hr_dm_library.' || l_proc_name || '(' ||
      indent(p_indent + 28) || 'p_table_name  => ''' || l_table_name || ''''  ||
      indent(p_indent + 29) || ',p_ins_type    => l_ins_type' ||
      indent(p_indent + 29) || ',p_row_exists  => l_row_exists';

    -- add the first column of the primary key.
    p_proc_body :=  p_proc_body || indent(p_indent + 29) ||
     ',p_pk_column_1 => p_' || rpad(g_pk_columns_tbl(1),28);

    -- if the composite primary key has more than one column then add the column
    -- to the call to ins_dt procedure.
    if g_no_of_pk_columns > 1 then
      p_proc_body :=  p_proc_body || indent(p_indent + 29) ||
      ',p_pk_column_2 => p_' || rpad(g_pk_columns_tbl(2),28);
    end if;

    -- if the composite primary key has more than two column then add the column
    -- to the call to ins_dt procedure.

    if g_no_of_pk_columns > 2 then
      p_proc_body :=  p_proc_body || indent(p_indent + 29) ||
      ',p_pk_column_3 => p_' || rpad(g_pk_columns_tbl(3),28);
    end if;

    -- if the composite primary key has more than three column then add the
    -- column to the call to ins_dt procedure.

    if g_no_of_pk_columns > 3 then
      p_proc_body :=  p_proc_body || indent(p_indent + 29) ||
      ',p_pk_column_4 => p_' || rpad(g_pk_columns_tbl(4),28);
    end if;

    p_proc_body := p_proc_body || ');';
  end if;
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tups.prepare_chk_dt_delete_stmt',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.prepare_chk_dt_delete_stmt',
                         '(none)','R');
     raise;
end prepare_chk_dt_delete_stmt;
--
-- ----------------------- prepare_dt_upload_body  ----------------------
-- Description:
-- Prepare the procedure body of upload procedure for date tracked table.
-- ------------------------------------------------------------------------
procedure prepare_dt_upload_body
(
  p_table_info       in     hr_dm_gen_main.t_table_info,
  p_proc_body        out nocopy    varchar2
)
is
  l_proc_comment varchar2(4000);

  -- block body of the procedure i.e between begin and end.
  l_proc_body   varchar2(32767) := null;
  l_func_body   varchar2(32767) := null;

  -- indentation for the statements.it specifies number of blank spaces
  -- after which the staement should start.

  l_migrate_data                boolean := true;
  l_indent                      number;

begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tups.prepare_dt_upload_body', 5);

  l_indent := 2;

-- add in SR migration code

  l_proc_body :=  format_comment ('For an SR migration the existance of the' ||
                  ' logical record is checked and if the id values are ' ||
                  'different then an entry is made into the resolve pks ' ||
                  'table.');
  l_proc_body :=  l_proc_body || indent(l_indent) ||
                   'if p_migration_type = ''SR'' then ';

  l_indent := 4;
-- call chk_row_exists code
  l_proc_comment := format_comment('Call chk_row_exists code to populate' ||
                    ' the hr_dm_resolve_pks table.');
  if p_table_info.use_non_pk_col_for_chk_row  = 'Y' then
    l_proc_body  :=  l_proc_body || l_proc_comment || indent(l_indent) ||
                     g_chk_row_exists.call_to_proc;
  else
    l_proc_body  :=  l_proc_body || l_proc_comment || indent(l_indent) ||
       'chk_row_exists( ' ||
                 hr_dm_library.conv_list_to_text(
                  p_rpad_spaces    => l_indent + 13,
                  p_pad_first_line => 'N',
                  p_prefix_col     => 'p_',
                  p_columns_tbl    => g_pk_columns_tbl,
                  p_col_length     => 28,
                  p_overide_tbl    => g_resolve_pk_columns_tbl,
                  p_overide_prefix => 'l_') || indent(l_indent + 13) ||
       ',l_row_exists)' || ';';
  end if;

  l_proc_body :=  l_proc_body || indent(l_indent-2) || 'else';



  if p_table_info.global_data = 'N' then

   -- if code to chk row exists is required always then do not
   -- put the if clause.

   if p_table_info.chk_row_exists_for_non_glb_tbl = 'N' then

      -- comment for the logic
      l_proc_comment := l_proc_comment || format_comment (
      ' For FULL migration no checks are made. ' ||
      'For ADDITIVE migration a physical'||
      ' row is inserted if a logical record does not exist (excluding the logical'
      || ' record created by other slave processes). if logical record exists  for'
      || ' a Application data type migration, then logical record is deleted from '
      || ' destination and a record is created into ' ||
      'dt_delete table with type ''D'' (so as other physical records for this ' ||
      'logical record will skip this check) and will upload the ' ||
      'data. If logical record exists  for'
      || ' any other type of data migration then  a record is created into ' ||
      'dt_delete table with type ''P''.', l_indent)  || indent;


      l_proc_body :=  l_proc_body || l_proc_comment || indent(l_indent) ||
                   'if p_last_migration_date is not null then ' ||
                    indent(l_indent);

       l_indent := 6;
    else
       -- comment for the logic

       l_proc_comment := l_proc_comment || format_comment (
       ' For FULL or ADDITIVE migration a physical'||
       ' row is inserted if a logical record does not exist (excluding the logical'
       || ' record created by other slave processes). if logical record exists  for'
       || ' a Application data type migration, then logical record is deleted from '
       || ' destination and a record is created into ' ||
       'dt_delete table with type ''D'' (so as other physical records for this ' ||
       'logical record will skip this check) and will upload the ' ||
       'data. If logical record exists  for'
       || ' any other type of data migration then a record is created into ' ||
       'dt_delete table with type ''P''.', l_indent)  || indent;


       l_proc_body :=  l_proc_body || l_proc_comment || indent(l_indent);

       l_indent := 4;
    end if;
  else

    -- comment for the logic

    l_proc_comment := l_proc_comment || format_comment (
    ' For FULL or ADDITIVE migration a physical'||
    ' row is inserted if a logical record does not exist (excluding the logical'
    || ' record created by other slave processes). if logical record exists  for'
    || ' a Application data type migration, then logical record is deleted from '
    || ' destination and a record is created into ' ||
    'dt_delete table with type ''D'' (so as other physical records for this ' ||
    'logical record will skip this check) and will upload the ' ||
    'data. If logical record exists  for'
    || ' any other type of data migration then a record is created into ' ||
    'dt_delete table with type ''P''.', l_indent)  || indent;


    l_proc_body :=  l_proc_body || l_proc_comment || indent(l_indent);

    l_indent := 4;

  end if;

  -- code to check whether this Id had been processed earlier by comapring the
  -- Id value of the last

  l_proc_body := l_proc_body || indent(l_indent) || 'if ' ||
                           hr_dm_library.get_func_asg
                           ( p_rpad_spaces     => l_indent,
                             p_columns_tbl     => g_pk_columns_tbl,
                             p_prefix_left_asg => 'g_old_',
                             p_prefix_right_asg => 'p_',
                             p_omit_business_group_id  => 'N',
                             p_comma_on_first_line     => 'N',
                             p_pad_first_line          => 'N',
                             p_equality_sign           => ' = ',
                             p_start_terminator        => 'and ',
                             p_end_terminator          => null);

  l_proc_body := l_proc_body || indent(l_indent) ||'then' ||
  indent(l_indent + 2) || 'l_insert := TRUE;' || indent(l_indent) || 'else' ||
  indent(l_indent + 2);


  l_indent := l_indent + 2; -- l_indent = 6

  l_proc_comment := format_comment (p_comment_text =>
  'Find out nocopy if the row already exists for this id in the dt_deletes table '||
  'in the database or not.',
  p_indent_spaces    => l_indent) || indent;

  --
  -- construct a call to function to check whether a row exists in dt_delete
  -- table for the given table/id combination.
  --

  l_proc_body := l_proc_body ||l_proc_comment || indent(l_indent);

  -- call to procedure to check whether row exists in dt_delete table.
  prepare_chk_dt_delete_stmt
  ( p_table_info  => p_table_info,
    p_proc_body   => l_proc_body,
    p_indent      => l_indent);

  --
  -- Processing logic based on if row exists in dt_delete.
  --
  l_proc_body := l_proc_body || indent(l_indent) ||
  'if l_row_exists = ''Y'' then' || indent(l_indent + 2) ||'if l_ins_type = ' ||
  '''D'' then ' || indent(l_indent + 4) ||  'l_insert := TRUE;' ||
    indent(l_indent + 2) || 'else -- l_ins_type = ''P''' || indent(l_indent + 4)
   ||  'l_insert := FALSE;' || indent(l_indent + 2) || 'end if; -- l_row_exists'
   || '= ''Y'''  ||indent(l_indent) || 'else   -- l_row_exists <> ''Y''. ';


  --
  -- Processing logic based on if row does not exists in dt_delete.
  --

  l_indent := l_indent + 4;  -- l_indent = 10

  l_proc_comment := format_comment (p_comment_text =>
  'call chk_row_exists procedure to check whether this row already exist ' ||
  'in the database or not.',
  p_indent_spaces    => l_indent) || indent;

  --
  -- Row does not exist in DT_DELETE table for this table/Id combination, so
  -- call the function to check whether row exists in the destination table
  -- for the given unique fields.
  --
  if p_table_info.use_non_pk_col_for_chk_row  = 'Y' then
    l_proc_body  :=  l_proc_body || l_proc_comment || indent(l_indent) ||
                     g_chk_row_exists.call_to_proc;
  else
    l_proc_body  :=  l_proc_body || l_proc_comment || indent(l_indent) ||
       'chk_row_exists( ' ||
                 hr_dm_library.conv_list_to_text(
                  p_rpad_spaces    => l_indent + 15,
                  p_pad_first_line => 'N',
                  p_prefix_col     => 'p_',
                  p_columns_tbl    => g_pk_columns_tbl,
                  p_col_length     => 28,
                  p_overide_tbl    => g_resolve_pk_columns_tbl,
                  p_overide_prefix => 'l_') || indent(l_indent + 15) ||
       ',l_row_exists)' || ';';
  end if;

  --
  -- Row does not exists in the destination table for the given Id.
  -- Construct a call to function to insert a row into dt_deletes table
  -- so that other physical records can be uploaded without performing
  -- any checks.
  --

  l_migrate_data := migrate_table_data(p_table_info);

  l_proc_body := l_proc_body || indent(l_indent) ||
  'if l_row_exists = ''N'' then' || indent(l_indent + 2) ||
   format_comment('create a row into dt_deletes table of type ''D'',so the' ||
  ' subsequent physical records can be uploaded without performing any ' ||
  'checks.',l_indent+2) || indent(l_indent + 2);

  if l_migrate_data then
     -- call to insert a row in to dt_delete table.
     prepare_ins_dt_delete_stmt
     ( p_table_info  => p_table_info,
       p_proc_body   => l_proc_body,
       p_ins_type    => 'D',
       p_indent      => l_indent + 2);

     l_proc_body := l_proc_body || indent(l_indent + 2)   ||
     'l_insert := TRUE;' || indent(l_indent) || 'else  -- row already exists' ||
     ' in the database';
  else
     l_proc_body := l_proc_body || indent(l_indent + 2)   ||
     'l_insert := FALSE;' || indent(l_indent) || 'else  -- row already exists' ||
     ' in the database';
  end if;

  --
  -- Row exists in the destination table for the given Id and Migration type
  -- is Application Data Migration. Call functionto create a row in DT_DELETE
  -- table of type 'D'. Delete the existing rows from the table for the
  -- given ID.
  --
  l_indent := l_indent + 4;   --  l_indent := 14
  l_proc_body := l_proc_body || indent(l_indent - 2) ||
  format_comment('if migration_type is application then update the row',
   l_indent,'N') || indent(l_indent - 2);
  if  not l_migrate_data then

      -- call to insert a row in to dt_elete table.
      prepare_ins_dt_delete_stmt
      ( p_table_info  => p_table_info,
        p_proc_body   => l_proc_body,
        p_ins_type    => 'P',
        p_indent      => l_indent);

     l_proc_body := l_proc_body || indent(l_indent) ||
     'l_insert := FALSE;';
  else
     l_proc_body := l_proc_body||'if p_migration_type in (''FW'', ''A'', ''SF'') then' ||indent(l_indent) ||
     format_comment('create a row into dt_deletes table of type ''D'',so the' ||
     ' subsequent physical records can be uploaded without performing any ' ||
     'checks.',l_indent,'N') || indent(l_indent) ;

      -- call to insert a row in to dt_elete table.
      prepare_ins_dt_delete_stmt
      ( p_table_info  => p_table_info,
        p_proc_body   => l_proc_body,
        p_ins_type    => 'D',
        p_indent      => l_indent);

      l_proc_body := l_proc_body || indent(l_indent) ||
      format_comment('call delete_dml procedure to delete all existing rows for' ||
      ' the given id',l_indent);

      hr_dm_utility.message('INFO','use_non_pk_col_for_chk_row '||p_table_info.use_non_pk_col_for_chk_row, 5);
      hr_dm_utility.message('INFO','upload_table_name '||p_table_info.upload_table_name, 5);
      if p_table_info.use_non_pk_col_for_chk_row  = 'Y' then
         l_proc_body  := l_proc_body || indent(l_indent) || g_delete_dml.call_to_proc;
      else
         l_proc_body := l_proc_body || indent(l_indent) ||
         'delete_dml( ' || hr_dm_library.conv_list_to_text(
                                              p_rpad_spaces    => l_indent + 11,
                                              p_pad_first_line => 'N',
                                              p_prefix_col     => 'p_',
                                              p_columns_tbl => g_pk_columns_tbl,
                                              p_col_length  => 28)  || ');';
      end if;
      l_proc_body := l_proc_body || indent(l_indent) ||
     'l_insert := TRUE;';

     l_proc_body := l_proc_body|| indent(l_indent - 2) || 'else  -- migration type other' ||
     ' than application data migration';

     --
     -- Row exists in the destination table for the given Id and Migration type
     -- is other than Application Data Migration. Call functionto create a row
     -- in DT_DELETE table of type 'P'.
     --

     l_proc_body := l_proc_body || indent(l_indent) ||
     format_comment('create a row into dt_deletes table of type ''P'',so the' ||
     ' subsequent physical records can skip these checks and info will be used' ||
     'for reporting.',l_indent,'N') || indent(l_indent);

     -- call to insert a row in to dt_delete table.
     prepare_ins_dt_delete_stmt
     ( p_table_info  => p_table_info,
       p_proc_body   => l_proc_body,
       p_ins_type    => 'P',
       p_indent      => l_indent);

     l_proc_body := l_proc_body ||  indent(l_indent) || 'l_insert := FALSE;' ||
     indent(l_indent - 2) || 'end if;  ' || '--p_migration_type = ''A''';

  end if;
  --
  -- close all the if's statements
  --
  l_proc_body := l_proc_body || indent(l_indent - 4) ||
  'end if; -- l_row_exists = ''N''' || indent(l_indent - 6) ||
  'end if; -- l_row_exists = ''Y''' || indent(l_indent - 8) ||
  'end if; -- g_old_' || rpad(g_pk_columns_tbl(1),24) ||
  ' = p_' || g_pk_columns_tbl(1);

  if p_table_info.global_data = 'N' and
     p_table_info.chk_row_exists_for_non_glb_tbl = 'N' then
    l_indent := 4;
    l_proc_body := l_proc_body || indent(l_indent) || 'else    -- full migration ' ||
    indent(l_indent + 2) || 'l_insert := TRUE;' || indent(l_indent) ||
    'end if;';
  end if;

  p_proc_body := p_proc_body || l_proc_body;
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tups.prepare_dt_upload_body',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.prepare_dt_upload_body',
                         '(none)','R');
     raise;
end prepare_dt_upload_body;
-- ----------------------- prepare_non_dt_upload_body  ----------------------
-- Description:
-- Prepare the procedure body of upload proxcedure for non date tracked table.
-- ------------------------------------------------------------------------
procedure prepare_non_dt_upload_body
(
  p_table_info       in     hr_dm_gen_main.t_table_info,
  p_proc_body        out nocopy    varchar2
)
is
  l_proc_comment varchar2(4000);

  l_check_row_exists varchar2(1);


  -- block body of the procedure i.e between begin and end.
  l_proc_body   varchar2(32767) := null;
  l_func_body   varchar2(32767) := null;

  -- indentation for the statements.it specifies number of blank spaces
  -- after which the staement should start.

  l_indent                  number;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tups.prepare_non_dt_upload_body ', 5);

  l_indent := 2;

-- add in SR migration code

  l_proc_body :=  format_comment ('For an SR migration the existance of the' ||
                  ' logical record is checked and if the id values are ' ||
                  'different then an entry is made into the resolve pks ' ||
                  'table.');
  l_proc_body :=  l_proc_body || indent(l_indent) ||
                   'if p_migration_type = ''SR'' then ' ||
                    indent(l_indent);

  l_proc_comment := format_comment('Call chk_row_exists code to populate' ||
                    ' the hr_dm_resolve_pks table.');
  if p_table_info.use_non_pk_col_for_chk_row  = 'Y' then
    l_proc_body  := l_proc_body || indent(l_indent) || l_proc_comment ||
                    indent(l_indent) || g_chk_row_exists.call_to_proc;
  else
    l_proc_body  := l_proc_body || indent(l_indent) ||  l_proc_comment ||
                    indent(l_indent) || 'chk_row_exists( ' ||
                 hr_dm_library.conv_list_to_text(
                  p_rpad_spaces    => l_indent + 13,
                  p_pad_first_line => 'N',
                  p_prefix_col     => 'p_',
                  p_columns_tbl    => g_pk_columns_tbl,
                  p_col_length     => 28,
                  p_overide_tbl    => g_resolve_pk_columns_tbl,
                  p_overide_prefix => 'l_') || indent(l_indent + 13) ||
               ',l_row_exists)' || ';';
  end if;

  l_proc_body :=  l_proc_body || indent(l_indent) || 'else';
  l_indent := 4;

  if (p_table_info.chk_row_exists_for_non_glb_tbl = 'Y')
   or (p_table_info.always_check_row = 'Y') then
    l_check_row_exists := 'Y';
  else
    l_check_row_exists := 'N';
  end if;


  if p_table_info.global_data = 'N' then
    -- comment for the logic
     l_proc_comment := format_comment (
    'if last_migration_date is null then it means a FULL migration for ' ||
    'this business group is done, otherwise, it is an ADDITIVE migration.',
     l_indent,'N');

     --
     -- if l_check_row_exists is set to 'Y' then
     -- don't put the code for row exists.
     --
     if l_check_row_exists = 'N' then
       l_proc_comment := l_proc_comment || format_comment (
       ' For FULL migration no checks are made. For ADDITIVE migration a row is ' ||
      'inserted if it does not exist or updated if row exists for a Application' ||
      ' data type migration, otherwise, a record is created in DT_DELETES table.',
      l_indent)  || indent;

      l_proc_body :=  l_proc_body || l_proc_comment || indent(l_indent) ||
                 'if p_last_migration_date is not null then ' ||
                  indent(l_indent);

      l_indent := 6;
    else  -- make the check for row exists
      l_proc_comment := l_proc_comment || format_comment (
      ' For data migration a row is ' ||
      'inserted, if it does not exist or updated if row exists for a Application' ||
      ' or Full data type migration, otherwise,a record is created in DT_DELETES table.',
       l_indent) || indent;
      l_proc_body :=  l_proc_body || l_proc_comment || indent(l_indent);
    end if;
  else

     l_proc_comment := l_proc_comment || format_comment (
     ' This table contains Global Data. For data migration a row is ' ||
    'inserted, if it does not exist or updated if row exists for a Application' ||
    ' or Full data type migration, otherwise,a record is created in DT_DELETES table.',
     l_indent) || indent;
    l_proc_body :=  l_proc_body || l_proc_comment || indent(l_indent);
  end if;

  l_proc_comment := format_comment (p_comment_text =>
  'call chk_row_exists procedure to check whether this row already exist ' ||
  'in the database or not.',
  p_indent_spaces    => l_indent) || indent;


  l_proc_body  := l_proc_body || l_proc_comment || indent(l_indent);

  if p_table_info.use_non_pk_col_for_chk_row  = 'Y' then
    l_proc_body  := l_proc_body || g_chk_row_exists.call_to_proc;
  else
    l_proc_body  := l_proc_body ||
       'chk_row_exists( ' ||
                 hr_dm_library.conv_list_to_text(
                  p_rpad_spaces    => l_indent + 15,
                  p_pad_first_line => 'N',
                  p_prefix_col     => 'p_',
                  p_columns_tbl    => g_pk_columns_tbl,
                  p_col_length     => 28,
                  p_overide_tbl    => g_resolve_pk_columns_tbl,
                  p_overide_prefix => 'l_') || indent(l_indent + 15) ||
       ',l_row_exists)' || ';';
  end if;

  l_proc_body := l_proc_body || indent(l_indent) ||
  'if l_row_exists = ''N'' then' || indent(l_indent + 2) ||'l_insert := TRUE;'
   || indent(l_indent + 2) ||'l_update := FALSE;' || indent(l_indent) ||
   'else   -- row already ' || 'exists in the database' ||
   indent(l_indent + 2) ||
   format_comment('if migration_type is application then update the row',
                   l_indent + 2);

  l_indent := l_indent + 4; --l_indent := 8;
  l_proc_body := l_proc_body || indent(l_indent - 2) ||
  'if p_migration_type in (''A'', ''FW'') then' ||
  indent(l_indent) || 'l_update := TRUE;'||
  indent(l_indent - 2) || 'else' || indent(l_indent) ||'l_update := FALSE;' ||
   indent(l_indent) || '-- write into dt_deletes_table' || indent(l_indent);

  -- call to insert a row in to dt_delete table.
  prepare_ins_dt_delete_stmt
  ( p_table_info  => p_table_info,
    p_proc_body   => l_proc_body,
    p_ins_type    => 'P',
    p_indent => l_indent);

  l_proc_body := l_proc_body || indent(l_indent - 2)
   || 'end if;'  || indent(l_indent - 4) || 'end if;';

   if p_table_info.global_data = 'N' and
      l_check_row_exists = 'N' then
     l_indent := 4;
     l_proc_body := l_proc_body || indent(l_indent) || 'else    -- full migration ' ||
     indent(l_indent + 2) || 'l_insert := TRUE;' || indent(l_indent) ||
     'end if;';
   end if;
   p_proc_body := p_proc_body || l_proc_body;
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tups.prepare_non_dt_upload_body',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.prepare_non_dt_upload_body',
                         '(none)','R');
     raise;
end prepare_non_dt_upload_body;
-- ----------------------- generate_upload --------------------------------
-- Description:
-- Generates the upload procedure of the TUPS
-- ------------------------------------------------------------------------
procedure generate_upload
(
  p_table_info              in     hr_dm_gen_main.t_table_info,
  p_header                  in out nocopy varchar2,
  p_body                    in out nocopy varchar2,
  p_call_to_proc_body       in     varchar2,
  p_dev_key_local_var_body  in     varchar2,
  p_fk_to_aol_columns_tbl   in     hr_dm_gen_main.t_fk_to_aol_columns_tbl
)
is
  l_interface    varchar2(32767);
  l_locals       varchar2(32767) := null;
  l_cursor       varchar2(32767) := null;
  l_comment      varchar2(4000);
  l_proc_comment varchar2(4000);
  l_cursor_name  varchar2(30) := 'csr_mig_' || p_table_info.alias;

  -- block body of the procedure i.e between begin and end.

  l_proc_name   varchar2(30)    := 'u'|| p_table_info.short_name;
  l_proc_body   varchar2(32767) := null;
  l_resolve_pk_local_var   varchar2(2000) := null;

  -- indentation for the statements.it specifies number of blank spaces
  -- after which the staement should start.

  l_indent                  number;
  l_parameters_tbl          hr_dm_library.t_varchar2_tbl;
  l_proc_body_tbl           t_varchar2_32k_tbl;
  l_proc_index              number := 1;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tups.generate_upload', 5);

  if p_table_info.fk_to_aol_table = 'N' then
     l_parameters_tbl := g_parameters_tbl;
  else
     l_parameters_tbl := g_aol_parameters_tbl;
  end if;
  -- input parameters for the procedure

  l_interface := indent ||
                '(p_last_migration_date          in  date' || indent ||
                ',p_migration_type               in  varchar2' || indent ||
                  ',';

  -- add the column parameters to the procedure.
  l_interface := l_interface ||
                 hr_dm_library.conv_list_to_text(
                  p_rpad_spaces    => 0,
                  p_pad_first_line => 'N',
                  p_columns_tbl => l_parameters_tbl,
                  p_col_length  => 70) ||indent || ')' ;

  l_proc_body_tbl(l_proc_index) := l_interface;

  l_proc_index := l_proc_index + 1;

  -- local variables of the procedure

  l_locals :=  format_comment('Declare cursors and local variables',2)
               || indent ||
              '  l_proc                     varchar2(72) := g_package ' ||
              '|| ''u' || p_table_info.short_name || ''';' || indent ||
              '  l_insert                   boolean := FALSE;' || indent ||
              '  l_update                   boolean := FALSE;' || indent ||
              '  l_row_count                number  := 0;' || indent ||
              '  l_row_exists               varchar2(1) := ''N'';' ||indent;


  -- if table has a column which have foreign key to the AOL table then create
  -- local variable for each corresponding developer key.

  if p_table_info.fk_to_aol_table = 'Y' then
    l_locals := l_locals || p_dev_key_local_var_body || indent;
    -- l_proc_body := l_proc_body || p_call_to_proc_body ;
    l_proc_body_tbl(l_proc_index) := p_call_to_proc_body;
    l_proc_index := l_proc_index + 1;
  end if;

  -- if the table has 'L' or 'H' type hierarchy then add the code to get the
  -- code to get the ID value of the column used in the destination database.
  -- It is done by getting the value from get_resolve_pk function.

  if p_table_info.resolve_pk = 'Y' then
     prepare_code_for_resolving_pk
     ( p_resolve_pk_columns_tbl  => g_resolve_pk_columns_tbl,
       p_table_info              => p_table_info,
       p_call_to_proc_body       => l_proc_body,
       p_local_var_body          => l_resolve_pk_local_var
     );

    l_proc_body_tbl(l_proc_index) := l_proc_body;
    l_proc_index := l_proc_index + 1;

    l_locals :=  l_locals || l_resolve_pk_local_var || indent;

  end if;

  -- if the table is an HR_DMV_% view then add a p_business_group_id
  -- column for the chk_row_exists procedure
  if (p_table_info.use_non_pk_col_for_chk_row  = 'Y') and
     (upper(substr(p_table_info.table_name,1,7)) = 'HR_DMV_') then
    l_locals := l_locals || '  p_business_group_id        number      := NULL;'
                || indent;
  end if;

  -- if the table is non date track table then call non date track function
  -- to construct the non date track procedure body, otherwise, call
  -- date track procedure.
  l_proc_body := null;
  if p_table_info.datetrack = 'N' then
    -- call non date track procedure
    prepare_non_dt_upload_body  ( p_table_info,
                                 l_proc_body);
  else
    -- extra local parameters for date track table.
    l_locals := l_locals || '  l_ins_type                 varchar2(1) := ''N'';'
                || indent;
    -- call date track procedure
    prepare_dt_upload_body  ( p_table_info,
                              l_proc_body);
  end if;
  l_proc_body_tbl(l_proc_index) := l_proc_body;
  l_proc_index := l_proc_index + 1;
  l_proc_body := null;

  -- add the logic of proc body common for date track and non date track table
  l_indent := 4;
  l_proc_body_tbl(l_proc_index) :=  indent(l_indent) ||
  '-- if l_insert flag is true then insert the row. ' ||indent(l_indent )
  || 'if l_insert then ' || indent(l_indent + 2)
  || 'insert_dml (' ;

  l_proc_index := l_proc_index + 1;


  -- if the columns of the table have foreign key to AOL table then call
  -- call assignment function which uses the l_ instead of p_ for the
  -- that column assignment.
  if p_table_info.fk_to_aol_table = 'N' then
     l_proc_body_tbl(l_proc_index) := hr_dm_library.get_func_asg (
                           p_rpad_spaces     => l_indent + 14,
                           p_columns_tbl     => g_columns_tbl,
                           p_omit_business_group_id  => 'N',
                           p_comma_on_first_line     => 'N',
                           p_pad_first_line          => 'N',
                           p_resolve_pk_columns_tbl   => g_resolve_pk_columns_tbl ) || ');';
     l_proc_index := l_proc_index + 1;
  else
     l_proc_body_tbl(l_proc_index)  :=
                    hr_dm_library.get_func_asg_with_dev_key (
                           p_rpad_spaces     => l_indent + 14,
                           p_columns_tbl     => g_columns_tbl,
                           p_omit_business_group_id  => 'N',
                           p_comma_on_first_line     => 'N',
                           p_pad_first_line          => 'N',
                           p_prefix_left_asg_dev_key  => 'p_',
                           p_prefix_right_asg_dev_key => 'l_',
                           p_use_aol_id_col           => 'Y',
           p_fk_to_aol_columns_tbl    => p_fk_to_aol_columns_tbl,
           p_resolve_pk_columns_tbl    => g_resolve_pk_columns_tbl ) || ');' ;
      l_proc_index := l_proc_index + 1;
  end if;


  -- if it is a date track table then add the logic of storing the id value
  -- of the row uploaded.

  if p_table_info.datetrack = 'Y' then
     l_proc_body_tbl(l_proc_index) := indent ||
           format_comment ( ' Store the primary columns into global variables '
           || 'for avoiding the checks for upload of other physical recoprds ' ||
              'belonging to this logical record ',4);

     l_proc_index := l_proc_index + 1;

     l_proc_body_tbl(l_proc_index) :=  indent(l_indent + 1) ||
                           hr_dm_library.get_func_asg
                           ( p_rpad_spaces     => l_indent + 2,
                             p_columns_tbl     => g_pk_columns_tbl,
                             p_prefix_left_asg => 'g_old_',
                             p_prefix_right_asg => 'p_',
                             p_omit_business_group_id  => 'N',
                             p_comma_on_first_line     => 'N',
                             p_pad_first_line          => 'N',
                             p_equality_sign           => ' := ',
                             p_start_terminator        => null,
                             p_end_terminator          => ';');
     l_proc_index := l_proc_index + 1;
  end if;

  -- close the if statement.
  l_proc_body_tbl(l_proc_index) :=  indent(l_indent)  || l_proc_body ||
                                    indent(l_indent)  || 'end if;';
  l_proc_index := l_proc_index + 1;

  -- call update_dml function only in case of non date track table.
  if p_table_info.datetrack = 'N' then
    l_proc_body_tbl(l_proc_index) :=  indent(l_indent) ||
    '-- if l_update flag is true then update the row. ' ||indent(l_indent)
    || 'if l_update then ' || indent(l_indent + 2)
    || 'update_dml (' ;

    l_proc_index := l_proc_index + 1;
    -- if the columns of the table have foreign key to AOL table then call
    -- call assignment function which uses the l_ instead of p_ for the
    -- that column assignment.
    if p_table_info.fk_to_aol_table = 'N' then
      l_proc_body_tbl(l_proc_index ) :=  hr_dm_library.get_func_asg (
                           p_rpad_spaces     => l_indent + 14,
                           p_columns_tbl     => g_columns_tbl,
                           p_omit_business_group_id  => 'N',
                           p_comma_on_first_line     => 'N',
                           p_pad_first_line          => 'N',
                           p_resolve_pk_columns_tbl   => g_resolve_pk_columns_tbl ) || ');';
      l_proc_index := l_proc_index + 1;

    else
      l_proc_body_tbl(l_proc_index) :=
                    hr_dm_library.get_func_asg_with_dev_key (
                           p_rpad_spaces     => l_indent + 14,
                           p_columns_tbl     => g_columns_tbl,
                           p_omit_business_group_id  => 'N',
                           p_comma_on_first_line     => 'N',
                           p_pad_first_line          => 'N',
                           p_prefix_left_asg_dev_key  => 'p_',
                           p_prefix_right_asg_dev_key => 'l_',
                           p_use_aol_id_col           => 'Y',
           p_fk_to_aol_columns_tbl    => p_fk_to_aol_columns_tbl,
           p_resolve_pk_columns_tbl    => g_resolve_pk_columns_tbl ) || ');' ;
      l_proc_index := l_proc_index + 1;

    end if;

    -- close the if statement.
    l_proc_body_tbl(l_proc_index) :=  indent(l_indent)  || l_proc_body ||
                                    indent(l_indent)  || 'end if;';
    l_proc_index := l_proc_index + 1;
  end if;

-- end if for the end of the non-SR code
  l_indent := 2;
  l_proc_body_tbl(l_proc_index) := format_comment('End of non-SR code.') ||
                 indent(l_indent) || 'end if;';
  l_proc_index := l_proc_index + 1;


  l_proc_body_tbl(l_proc_index) :=  indent || 'end ' || l_proc_name || ';';
  l_proc_index := l_proc_index + 1;

  l_proc_comment := format_comment('procedure to upload all columns of '
  || upper(p_table_info.upload_table_name) || ' from datapump interface table.')||
  indent;

  -- add the procedure comment defination to the package header and body
  p_header := p_header || l_proc_comment ||'procedure ' || l_proc_name ||
              l_interface|| ';';

  l_proc_body_tbl(1)  := l_proc_comment || 'procedure ' || l_proc_name ||
             l_proc_body_tbl(1) || ' is';

  -- add local variables , cursor and procedure body to complete the procedure
  l_proc_body_tbl(1) := l_proc_body_tbl(1) || l_locals || indent || 'begin'
             || indent ;

 -- add the body of this procedure to the package.
 add_to_package_body( l_proc_body_tbl );
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tups.generate_upload',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.generate_upload',
                         '(none)','R');
     raise;
end generate_upload;
-- ----------------------- get_derive_from_clause -------------------------
-- Description:
-- Uses the derive_sql_source_tables info stored in HR_DM_TABLES to form the
-- 'from clause'.
-- The from clause stored in each derive field will be in the following format :
--   table1 tbl,:table2 tbl2, :table3   tbl3
--   where ':' is the next line indicator  i.e : will be replaced with new line.
--   o If 'from' string is not there it puts the from string.
--  Input Parameters :
--         p_table_info    - Table information stored in pl/sql table
--         p_derive_from   - derive_sql string which stores the from clause
--         p_lpad_spaces   - padding
--  Out Parameters
--         p_from_clause  - formatted from clause
--
-- ------------------------------------------------------------------------------
procedure get_derive_from_clause
(
  p_table_info       in        hr_dm_gen_main.t_table_info,
  p_derive_from      in        varchar2,
  p_from_clause      in out nocopy    varchar2,
  p_lpad_spaces      in        number    default 2
) is
  l_derive_sql     hr_dm_tables.derive_sql_download_full%type;
  l_start_ptr      number;
  l_end_ptr        number;
  l_terminator     varchar2(5) := ';';
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tups.get_derive_from_clause', 5);
  hr_dm_utility.message('PARA','(p_from_clause - ' || p_from_clause ||
                             ')(p_lpad_spaces - ' || p_lpad_spaces ||
                             ')', 10);
  l_derive_sql := p_derive_from;

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

  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tups.get_derive_from_clause',
                         25);
  hr_dm_utility.message('PARA','(p_from_clause - ' || p_from_clause || ')',30);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.get_derive_from_clause',
                        '(l_derive_sql - ' || l_derive_sql ||
                        ')(l_end_ptr - ' || l_end_ptr ||
                        ')(p_from_clause - ' || p_from_clause || ')'
                        ,'R');
     raise;
end get_derive_from_clause;
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
--  Input Parameters :
--         p_table_info    - Table information stored in pl/sql table
--         p_derive_sql    - derive_sql string which stores the where clause
--         p_lpad_spaces   - padding
--  Out Parameters
--         p_where_clause  - formatted where clause
--
-- ------------------------------------------------------------------------------
procedure get_derive_where_clause
(
  p_table_info       in        hr_dm_gen_main.t_table_info,
  p_derive_sql       in        varchar2,
  p_where_clause     in out nocopy    varchar2,
  p_lpad_spaces      in        number    default 2
) is
  l_derive_sql     hr_dm_tables.derive_sql_chk_row_exists%type;
  l_start_ptr      number;
  l_end_ptr        number;
  l_terminator     varchar2(5) := ';';
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tups.get_derive_where_clause', 5);

  l_derive_sql := p_table_info.derive_sql_chk_row_exists;

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
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tups.get_derive_where_clause',
                         25);
  hr_dm_utility.message('PARA','(p_where_clause - ' || p_where_clause,30);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.get_derive_where_clause',
                         '(none)','R');
     raise;
end get_derive_where_clause;
-- -----------------------  prepare_chk_row_exists_cursor ---------------------
-- Description:
-- Preapre the cursor for chk_row_exists procedure
-- ------------------------------------------------------------------------
procedure prepare_chk_row_exists_cursor
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
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tups.prepare_chk_row_exists_cursor', 5);

  -- comments about the cursor
  l_cursor_comment := format_comment('cursor to get the row from '||
                     p_table_info.upload_table_name || 'for a given primary key',2);

  -- defination of cursor
  l_cursor_defination := '  cursor csr_find_row_in_' ||p_table_info.alias ||
                         ' is ';

  -- select dummy column in the cursor as we just want to find that whether a
  -- row exist or not.

  if p_table_info.surrogate_pk_column_name is not null then
     l_cursor_select_cols := '  select ' || p_table_info.surrogate_pk_column_name;
  else
     l_cursor_select_cols := '  select ''1''' ;
  end if;

  -- get from clause. dtapump creates a view of the table to be uploaded.
  -- view is based on batch_lines table and TUPS load program parameters.

  if p_table_info.derive_sql_chk_source_tables is not null then
     get_derive_from_clause ( p_table_info   => p_table_info,
                               p_derive_from  => p_table_info.derive_sql_chk_source_tables,
                               p_from_clause  => l_cursor_select_from);
  else
    l_cursor_select_from := '  from  ' || p_table_info.upload_table_name  || ' ' || p_table_info.alias;
  end if;


  --
  -- Prepare where clause.
  --

  if p_table_info.derive_sql_chk_row_exists is not null then
         get_derive_where_clause ( p_table_info   => p_table_info,
                                   p_derive_sql   => p_table_info.derive_sql_chk_row_exists,
                                   p_where_clause => l_cursor_select_where);

  elsif p_table_info.use_non_pk_col_for_chk_row  = 'Y' then
    l_cursor_select_where := g_chk_row_exists.where_clause ;

  else  -- use primary key for where clause

     l_cursor_select_where := '  where' || hr_dm_library.get_func_asg (
                           p_rpad_spaces     => 0,
                           p_columns_tbl     => g_pk_columns_tbl,
                           p_prefix_left_asg => p_table_info.alias || '.' ,
                           p_prefix_right_asg => 'p_',
                           p_omit_business_group_id  => 'N',
                           p_comma_on_first_line     => 'N',
                           p_pad_first_line          => 'N',
                           p_equality_sign           => ' = ',
                           p_left_asg_pad_len        => 80,
                           p_right_asg_pad_len       => 80,
                           p_start_terminator        => '  and   ',
                           p_test_with_nvl           => 'Y',
                           p_table_name              => upper(p_table_info.upload_table_name))
                           ||';';
  end if;

  -- finally put the components of where clause together
  p_cursor := l_cursor_comment      || indent ||
              l_cursor_defination   || indent ||
              l_cursor_select_cols  || indent ||
              l_cursor_select_from  || indent ||
              l_cursor_select_where || indent;

  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tups.prepare_chk_row_exists_cursor',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.prepare_chk_row_exists_cursor',
                         '(none)','R');
     raise;
end prepare_chk_row_exists_cursor;

-- ----------------------- generate_chk_row_exists -----------------------
-- Description:
-- Generates the chk_row_exists procedure of the TUPS
-- ------------------------------------------------------------------------
procedure generate_chk_row_exists
(
  p_table_info       in     hr_dm_gen_main.t_table_info
)
is
  l_interface    varchar2(32767);
  l_locals       varchar2(32767) := null;
  l_cursor       varchar2(32767) := null;
  l_proc_comment varchar2(4000);
  l_cursor_name  varchar2(30) := 'csr_find_row_in_' || p_table_info.alias;

  -- block body of the procedure i.e between begin and end.
  l_proc_body   varchar2(32767) := null;

  -- indentation for the statements.it specifies number of blank spaces
  -- after which the staement should start.

  l_indent                  number;

  l_proc_body_tbl           t_varchar2_32k_tbl;
  l_proc_index              number := 1;
  l_operand                 varchar2(30);
  l_delete_operand          varchar2(30);
  l_seperator               varchar2(30);
  l_delete_seperator        varchar2(30);
  --l_fk_on_uc_col          varchar2(1);
  l_fetched_column_name     varchar2(30);
  l_index                   number;
  l_nvl_left                varchar2(100);
  l_nvl_right               varchar2(100);
  l_apps_name               varchar2(30);

  l_status    varchar2(50);
  l_industry  varchar2(50);
  l_per_owner     varchar2(30);
  l_ben_owner     varchar2(30);
  l_pay_owner     varchar2(30);
  l_ff_owner     varchar2(30);
  l_fnd_owner     varchar2(30);

  l_ret1      boolean := FND_INSTALLATION.GET_APP_INFO ('PAY', l_status,
                                                        l_industry, l_pay_owner);
  l_ret2      boolean := FND_INSTALLATION.GET_APP_INFO ('BEN', l_status,
                                                        l_industry, l_ben_owner);
  l_ret3      boolean := FND_INSTALLATION.GET_APP_INFO ('FF', l_status,
                                                        l_industry, l_ff_owner);
  l_ret4      boolean := FND_INSTALLATION.GET_APP_INFO ('FND', l_status,
                                                        l_industry, l_fnd_owner);
  l_ret5      boolean := FND_INSTALLATION.GET_APP_INFO ('PER', l_status,
                                                        l_industry, l_per_owner);
  cursor csr_apps_name is
  select ORACLE_USERNAME
  from fnd_oracle_userid
  where ORACLE_ID = 900;

  --
  -- cursor to get the column and data type if non pk columns are
  -- used for row exists chk.
  --
  cursor csr_get_chk_columns is
  select lower(hir.column_name) column_name ,
         lower(col.data_type) data_type,
         hir.hierarchy_type,
         lower(dmt.table_alias) table_alias,
         tbl.table_name table_name
  from all_tab_columns col,
       hr_dm_tables  tbl,
       hr_dm_tables  dmt,
       hr_dm_hierarchies hir
  where tbl.table_name = nvl(dmt.upload_table_name, dmt.table_name)
  and dmt.table_id = p_table_info.table_id
  and hierarchy_type = 'R'
  and tbl.table_id = hir.table_id
  and col.table_name =  tbl.table_name
  and col.column_name = hir.column_name
  and col.owner in
  (l_apps_name,
   l_fnd_owner,
   l_ff_owner,
   l_ben_owner,
   l_pay_owner,
   l_per_owner);

begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tups.generate_chk_row_exists', 5);

  -- indentation required for call to chk_row_exists procedure in upload process
  -- will vary depending upon the table properties.

  open csr_apps_name;
  fetch csr_apps_name into l_apps_name;
  close csr_apps_name;


  if p_table_info.datetrack = 'Y' then
    l_indent := 10;
  else
    if p_table_info.global_data = 'Y' then
      l_indent := 4;
    else
      l_indent := 4;
    end if;
  end if;

  if p_table_info.surrogate_pk_column_name is not null then
     l_fetched_column_name := rpad('l_' || p_table_info.surrogate_pk_column_name,30);
  else
     l_fetched_column_name := 'l_dummy';
  end if;

  --
  -- if non primary column have to be used to check whether row exist or not
  -- then the following are created and stored in the pl/sql record
  --   o where clause
  --   o call to the chk_row_exists procedure from upload procedure.
  --   o input parameters for chk_row_exists procedure
  --
  -- The columns which have 'L' or 'A' type hierarchy will use the local
  -- varaibles in the call to chk_row_exist procedure. Other columns will
  -- use the normal parameter i.t p_ column_name.
  --

  if p_table_info.use_non_pk_col_for_chk_row  = 'Y' then

     g_chk_row_exists.where_clause            := '  where ';
     g_chk_row_exists.call_to_proc    := 'chk_row_exists (';
     g_chk_row_exists.proc_parameters := '(';

     --
     -- the main difference is for date track table we the delete where clause
     -- will not contain the columns effective_start_date and effective_end_date.
     --
     g_delete_dml.where_clause            := '  where ';
     g_delete_dml.call_to_proc    := 'delete_dml (';
     g_delete_dml.proc_parameters := '(';

     -- for the first fetched record the following var will be null

     l_operand := '';
     l_delete_operand := '';
     l_seperator := '';
     l_delete_seperator := '';

     for csr_get_chk_columns_rec in csr_get_chk_columns loop

       --  if csr_get_chk_columns_rec.hierarchy_type = 'R' then

       hr_dm_library.get_nvl_arguement('Y',
                                       csr_get_chk_columns_rec.table_name,
                                       csr_get_chk_columns_rec.column_name,
                                       l_nvl_left,
                                       l_nvl_right);

       g_chk_row_exists.where_clause  := g_chk_row_exists.where_clause ||
           l_operand || ' ' || l_nvl_left ||
           csr_get_chk_columns_rec.table_alias || '.' ||
           csr_get_chk_columns_rec.column_name || l_nvl_right || ' = ' ||
           rpad(l_nvl_left || 'p_' ||
           substr(csr_get_chk_columns_rec.column_name,1,28) || l_nvl_right,70)
           || indent(2);

       l_operand := 'and   ';

       -- end if;

       -- since we need to delete the logical record hence the EST , EDT columns
       -- needs to be removed from the where clause

       if upper(csr_get_chk_columns_rec.column_name) not in ('EFFECTIVE_START_DATE',
                                                             'EFFECTIVE_END_DATE')
       then

       hr_dm_library.get_nvl_arguement('Y',
                                       csr_get_chk_columns_rec.table_name,
                                       csr_get_chk_columns_rec.column_name,
                                       l_nvl_left,
                                       l_nvl_right);

         g_delete_dml.where_clause  := g_delete_dml.where_clause ||
               l_delete_operand || ' ' || l_nvl_left ||
               csr_get_chk_columns_rec.table_alias || '.' ||
           substr(csr_get_chk_columns_rec.column_name,1,28) || l_nvl_right ||  ' = ' ||
           rpad(l_nvl_left ||'p_' ||
           csr_get_chk_columns_rec.column_name || l_nvl_right,80) || indent(2);


        g_delete_dml.proc_parameters := g_delete_dml.proc_parameters
          || l_delete_seperator || rpad('p_' || csr_get_chk_columns_rec.column_name,30) || '    ' ||
             csr_get_chk_columns_rec.data_type || indent;

         l_delete_operand := 'and   ';

       end if;


        -- if the column has a 'L' type hierarchy then we want to use the
        -- the local variable in the call so as to use the correct value
        -- of the column i.e value of the column in the destination database.

        hr_dm_library.check_col_for_fk_on_aol
        ( p_fk_to_aol_columns_tbl  => g_resolve_pk_columns_tbl,
          p_column_name            => upper(csr_get_chk_columns_rec.column_name),
          p_index                  => l_index);

        -- if the column does not have  a 'L' type hierarchy then check if table
        -- has a 'A' type hierarchy. If yes then check whether column has a foreign
        -- key on AOL table. The column should use the local variable in the call
        -- so as to use the correct value of the column i.e l_column_name instead
        -- of p_column_name.

        if l_index is null and p_table_info.fk_to_aol_table = 'Y' then
          hr_dm_library.check_col_for_fk_on_aol
          ( p_fk_to_aol_columns_tbl  => g_fk_to_aol_columns_tbl,
            p_column_name            => upper(csr_get_chk_columns_rec.column_name),
            p_index                  => l_index);
        end if;

        if l_index is null then
          g_chk_row_exists.call_to_proc := g_chk_row_exists.call_to_proc
            || l_seperator || rpad('p_' || csr_get_chk_columns_rec.column_name,30) ||
             indent (l_indent + 15);

          if upper(csr_get_chk_columns_rec.column_name) not in ('EFFECTIVE_START_DATE',
                                                                'EFFECTIVE_END_DATE')
          then
            g_delete_dml.call_to_proc := g_delete_dml.call_to_proc
              || l_delete_seperator || rpad('p_' || csr_get_chk_columns_rec.column_name,30) ||
               indent (l_indent + 15);
            l_delete_seperator := ',';
          end if;
        else
          g_chk_row_exists.call_to_proc := g_chk_row_exists.call_to_proc
            || l_seperator || rpad('l_' || csr_get_chk_columns_rec.column_name,30) ||
             indent (l_indent + 15);
          if upper(csr_get_chk_columns_rec.column_name) not in ('EFFECTIVE_START_DATE',
                                                             'EFFECTIVE_END_DATE')
          then
            g_delete_dml.call_to_proc := g_delete_dml.call_to_proc
              || l_delete_seperator || rpad('l_' || csr_get_chk_columns_rec.column_name,30) ||
               indent (l_indent + 15);
            l_delete_seperator := ',';
          end if;
        end if;


        g_chk_row_exists.proc_parameters := g_chk_row_exists.proc_parameters
          || l_seperator || rpad('p_' || csr_get_chk_columns_rec.column_name,30) || '    ' ||
             csr_get_chk_columns_rec.data_type || indent;
        l_seperator := ',';
     end loop;

     if p_table_info.ins_resolve_pk = 'Y'  then

        -- add surrogate id as one of the parameters to the call and interface
        -- of chk_row_exists procedure.

        g_chk_row_exists.call_to_proc := g_chk_row_exists.call_to_proc
          || l_seperator || rpad('p_' || p_table_info.surrogate_pk_column_name,30) ||
          indent (l_indent + 15);

        g_chk_row_exists.proc_parameters := g_chk_row_exists.proc_parameters
          || l_seperator || rpad('p_' || p_table_info.surrogate_pk_column_name,30)  || '    ' ||
             'number' || indent;
     end if;

     g_chk_row_exists.where_clause  := g_chk_row_exists.where_clause || ';';

     g_chk_row_exists.call_to_proc := g_chk_row_exists.call_to_proc ||
                                             ',l_row_exists);';
     g_chk_row_exists.proc_parameters := g_chk_row_exists.proc_parameters
                                      || ',p_row_exists               in out nocopy varchar2)';

     g_delete_dml.where_clause  := g_delete_dml.where_clause || ';';

     g_delete_dml.call_to_proc := g_delete_dml.call_to_proc || ');';
     g_delete_dml.proc_parameters := g_delete_dml.proc_parameters || ')';


  end if;


  if p_table_info.use_non_pk_col_for_chk_row  = 'Y' then

    l_interface :=  indent || g_chk_row_exists.proc_parameters || indent;

  else  -- use primary key for input parameters

     l_interface :=  indent || '(' ||
                     hr_dm_library.conv_list_to_text(
                                p_rpad_spaces    => 0,
                                p_pad_first_line => 'N',
                                p_columns_tbl => g_pk_parameters_tbl,
                                p_col_length  => 70) ||indent ||
                    ',p_row_exists                   out nocopy varchar2)' || indent;
  end if;

  -- local variables of the procedure
  l_locals := format_comment('Declare cursors and local variables',2) || indent ||
              '  l_proc                     varchar2(72) := g_package ' ||
              '|| ''chk_row_exists'';' || indent ||
              '  l_dummy                    varchar2(1);' || indent;

  -- add the variable to store the surrogate id .

  if p_table_info.surrogate_pk_column_name is not null then
   l_locals := l_locals || '  ' ||  l_fetched_column_name || '  number;'|| indent ;
  end if;

  -- cursor to check whether row exists in destination database.

    prepare_chk_row_exists_cursor (p_table_info,
                                   l_cursor);

  -- add the body of the upload procedure

  l_indent := 2;

  l_proc_body := l_proc_body || indent(l_indent) ||
  'open ' || l_cursor_name || ';' || indent(l_indent) || 'fetch ' ||
  l_cursor_name || ' into ' || l_fetched_column_name || ';' || indent(l_indent) || 'if ' ||
  l_cursor_name || '%found then' || indent(l_indent + 2) ||
  'p_row_exists := ''Y'';' || indent(l_indent + 2) || 'close ' || l_cursor_name
  || ';' || indent(l_indent) || 'else ' ||
   'p_row_exists := ''N'';' || indent(l_indent + 2) || 'close ' || l_cursor_name
  || ';' || indent(l_indent) || 'end if;' ;

  -- add the code to store the surrogate id in the hr_dm_pk_resolve table
  if p_table_info.ins_resolve_pk = 'Y' then
    l_proc_body := l_proc_body || indent(l_indent) || 'if p_row_exists = ''Y'' then' ||
                   indent (l_indent +2) || 'hr_dm_library.ins_resolve_pks ('   ||
                   'p_table_name       => ''' || upper(p_table_info.upload_table_name)
                   || '''' || indent(l_indent+32) ||
                   ', p_source_id      => ' ||rpad('p_' || p_table_info.surrogate_pk_column_name,30)
                   || indent(l_indent+32) ||
                   ', p_destination_id => ' || l_fetched_column_name || ');'
                   || indent(l_indent) || 'end if;';

  end if;

  l_proc_body := l_proc_body || indent || 'end chk_row_exists;';


  l_proc_comment := format_comment('procedure to check whether a row exist in '
  || upper(p_table_info.upload_table_name) || ' for a given primary key.')||
  indent;

  -- add the procedure comment defination to the package header and body

  l_proc_body_tbl(1) :=  l_proc_comment ||
      'procedure chk_row_exists' || l_interface || ' is';

  -- add local variables , cursor and procedure body to complete the procedure
  l_proc_body_tbl(1) := l_proc_body_tbl(1) || l_locals || l_cursor || indent ||
           'begin' ||indent || l_proc_body;

  -- add the body of this procedure to the package.
  add_to_package_body( l_proc_body_tbl );
 hr_dm_utility.message('ROUT','exit:hr_dm_gen_tups.generate_chk_row_exists',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.generate_chk_row_exists',
                         '(none)','R');
     raise;
end generate_chk_row_exists;

-- ----------------------- generate_insert_dml  ---------------------------
-- Description:
-- Generates the insert_dml procedure of the TUPS
-- ------------------------------------------------------------------------
procedure generate_insert_dml
(
  p_table_info       in     hr_dm_gen_main.t_table_info
)
is
  l_interface    varchar2(32767);
  l_locals       varchar2(32767) := null;
  l_cursor       varchar2(32767) := null;
  l_temp         varchar2(32767);
  l_proc_comment varchar2(4000);

  -- block body of the procedure i.e between begin and end.
  l_proc_body   varchar2(32767) := null;

  -- indentation for the statements.it specifies number of blank spaces
  -- after which the staement should start.

  l_indent                  number := 2;
  l_proc_body_tbl           t_varchar2_32k_tbl;
  l_proc_index              number := 1;
  l_list_index              number;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tups.generate_insert_dml', 5);

  -- input parameters for the procedure

  l_proc_body_tbl(l_proc_index) := indent || '(' ||
                 hr_dm_library.conv_list_to_text (
                 p_rpad_spaces    => l_indent + 2,
                 p_pad_first_line => 'Y',
                 p_columns_tbl    =>  g_parameters_tbl,
                 p_col_length     =>  70) || indent || ')';
  l_proc_index := l_proc_index + 1;

  -- local variables of the procedure
  l_locals :=  format_comment('Declare cursors and local variables',2)
               || indent ||
              '  l_proc                     varchar2(72) := g_package ' ||
              '|| ''insert_dml'';' || indent;

  -- if we need to check if the id is used
  if (p_table_info.sequence_name is not null) then

  -- add l_dummy
    l_locals := l_locals ||
                '  l_dummy number;' || indent ||
                '  l_ins_type varchar2(1) := ''N'';' || indent ||
                '  l_row_exists varchar2(1) := ''N'';' || indent ||
                '  l_row_exists_dt varchar2(1) := ''N'';' || indent ||
                '  l_row_exists_cr varchar2(1) := ''N'';'
                || indent || indent;

  -- add l_ style versions for p_ variables
    l_list_index := g_columns_tbl.first;
    while l_list_index is not null loop
      l_locals := l_locals || '  l_' || g_columns_tbl(l_list_index) ||
                  ' ' || p_table_info.upload_table_name || '.' ||
                  g_columns_tbl(l_list_index) ||
                  '%type;' || indent;
      l_list_index := g_columns_tbl.next(l_list_index);
    end loop;
    l_locals := l_locals || indent;

  -- if the table is an HR_DMV_% view then add a p_business_group_id
  -- local variable for the update where clause
  if (p_table_info.use_non_pk_col_for_chk_row  = 'Y') and
     (upper(substr(p_table_info.table_name,1,7)) = 'HR_DMV_') then
    l_locals := l_locals || '  p_business_group_id        number      := NULL;'
                || indent;
  end if;

  -- add cursor check if id value has already been used
    l_locals := l_locals ||
                '  cursor csr_check_if_used is' || indent(l_indent) ||
                '  select 1' || indent(l_indent) ||
                '  from ' || p_table_info.upload_table_name || indent(l_indent) ||
                '  where ' || p_table_info.surrogate_pk_column_name || ' = ' ||
                '        p_' || p_table_info.surrogate_pk_column_name || ';'
                || indent;

  -- add cursor to get new value from sequence
    l_locals := l_locals ||
                '  cursor csr_get_new_id is'|| indent(l_indent) ||
                '  select ' || p_table_info.sequence_name ||
                '.nextval' || indent(l_indent) ||
                '  from dual;'
                || indent || indent;
  end if;

  -- add the body of the download procedure
  l_indent := 2;

  -- if we need to check if the id is used
  if (p_table_info.sequence_name is null) then

  -- normal case

  -- prepare insert dml
    l_proc_body_tbl(l_proc_index) :=
                  format_comment('insert the row', l_indent) || indent ||
                   '  insert into ' || p_table_info.upload_table_name || indent(l_indent)
                   || '( ' || indent(l_indent) ||
                   hr_dm_library.conv_list_to_text (
                   p_rpad_spaces    => l_indent + 1,
                   p_pad_first_line => 'Y',
                   p_columns_tbl    =>  g_columns_tbl);
    l_proc_index := l_proc_index + 1;

    l_proc_body_tbl(l_proc_index) := indent(l_indent) || ')' ||
                   ' values' || indent(l_indent) || '(' || indent(l_indent) ||
                   hr_dm_library.conv_list_to_text (
                   p_rpad_spaces    => l_indent+ 1,
                   p_pad_first_line => 'Y',
                   p_prefix_col     => 'p_',
                   p_columns_tbl    => g_columns_tbl,
                   p_col_length     => 28) || indent(l_indent) ||
                   ');' || indent || 'end insert_dml;';
  else

  -- extra processing...

  -- see if id is used
    l_proc_body_tbl(l_proc_index) :=
           format_comment('see if id value already used and no DT_DELETE' ||
                          ' entry exists.', l_indent) || indent;
    l_proc_index := l_proc_index + 1;

  -- call to procedure to check whether row exists in dt_delete table.
    prepare_chk_dt_delete_stmt
      (p_table_info  => p_table_info,
       p_proc_body   => l_temp,
       p_indent      => l_indent);
    l_proc_body_tbl(l_proc_index) := l_temp || indent;
    l_proc_index := l_proc_index + 1;

    l_proc_body_tbl(l_proc_index)  :=  'l_row_exists_dt := l_row_exists;' || indent;
    l_proc_index := l_proc_index + 1;

    l_proc_body_tbl(l_proc_index) :=
           'open csr_check_if_used;' || indent ||
           'fetch csr_check_if_used into l_dummy;' || indent ||
           'close csr_check_if_used;' || indent || indent;
    l_proc_index := l_proc_index + 1;

  -- copy p_ to l_
    l_list_index := g_columns_tbl.first;
    while l_list_index is not null loop
      l_proc_body_tbl(l_proc_index) :=
         'l_' || g_columns_tbl(l_list_index) || ' := p_' || g_columns_tbl(l_list_index) ||
         ';' || indent;
      l_proc_index := l_proc_index + 1;
      l_list_index := g_columns_tbl.next(l_list_index);
    end loop;


    if p_table_info.use_non_pk_col_for_chk_row  = 'Y' then
      l_proc_body_tbl(l_proc_index)  := indent(l_indent) ||
                                        g_chk_row_exists.call_to_proc;
    else
      l_proc_body_tbl(l_proc_index)  :=  indent(l_indent) ||
        'chk_row_exists( ' ||
                 hr_dm_library.conv_list_to_text(
                  p_rpad_spaces    => l_indent + 15,
                  p_pad_first_line => 'N',
                  p_prefix_col     => 'p_',
                  p_columns_tbl    => g_pk_columns_tbl,
                  p_col_length     => 28) || indent(l_indent + 15) ||
        ',l_row_exists)' || ';';
    end if;
    l_proc_index := l_proc_index + 1;

    l_proc_body_tbl(l_proc_index)  :=  indent || 'l_row_exists_cr := l_row_exists;'
                                       || indent;
    l_proc_index := l_proc_index + 1;


-- see if we have done inserted any previous rows from this record
    l_proc_body_tbl(l_proc_index) := 'if l_row_exists_dt = ''Y''' || indent ||
                                     '  and l_ins_type = ''D''' || indent ||
                                     '  and l_row_exists_cr =''Y'' then' ||
                                     indent(l_indent) || 'null;' ||
                                     indent || 'else' || indent;
    l_proc_index := l_proc_index + 1;

-- if id value used then get new sequence value and write details to resolve_pks
-- otherwise keep original
    l_proc_body_tbl(l_proc_index) := indent(l_indent) ||
           'if (l_dummy is null) then' || indent(l_indent) ||
           '  null;' || indent(l_indent) ||
           'else'  || indent || indent(l_indent) ||
           '  open csr_get_new_id;' || indent(l_indent) ||
           '  fetch csr_get_new_id into l_' ||
           p_table_info.surrogate_pk_column_name || ';' || indent(l_indent) ||
           '  close csr_get_new_id;' || indent;

    l_proc_index := l_proc_index + 1;

-- write details to resolve_pks table
    l_proc_body_tbl(l_proc_index) :=
           '    hr_dm_library.ins_resolve_pks ('   ||
           'p_table_name       => ''' || upper(p_table_info.upload_table_name) || '''' ||
           indent(l_indent+30) ||
           '  ,p_source_id      => ' || rpad('p_' || p_table_info.surrogate_pk_column_name,30)
           || indent(l_indent+30) ||
           '  ,p_destination_id =>  l_' || p_table_info.surrogate_pk_column_name || ' );'
           || indent(l_indent) ||
           'end if;' || indent;
    l_proc_index := l_proc_index + 1;

    l_proc_body_tbl(l_proc_index) := 'end if;';
    l_proc_index := l_proc_index + 1;


  -- prepare insert dml
  -- need to change to use l_pk_id
    l_proc_body_tbl(l_proc_index) :=
                  format_comment('insert the row', l_indent) || indent ||
                   '  insert into ' || p_table_info.upload_table_name || indent(l_indent)
                   || '( ' || indent(l_indent) ||
                   hr_dm_library.conv_list_to_text (
                   p_rpad_spaces    => l_indent + 1,
                   p_pad_first_line => 'Y',
                   p_columns_tbl    =>  g_columns_tbl);
    l_proc_index := l_proc_index + 1;

    l_proc_body_tbl(l_proc_index) := indent(l_indent) || ')' ||
                   ' values' || indent(l_indent) || '(' || indent(l_indent) ||
                   hr_dm_library.conv_list_to_text (
                   p_rpad_spaces    => l_indent+ 1,
                   p_pad_first_line => 'Y',
                   p_prefix_col     => 'l_',
                   p_columns_tbl    => g_columns_tbl,
                   p_col_length     => 28) || indent(l_indent) ||
                   ');' || indent || 'end insert_dml;';


  end if;


  l_proc_comment := format_comment('procedure to insert a row in '
  || upper(p_table_info.upload_table_name) || 'table.')||
  indent;

  -- add the procedure comment defination,local variables, cursor to the
  -- procedure body

  l_proc_body_tbl(1)  :=  l_proc_comment || 'procedure insert_dml' ||
         l_proc_body_tbl(1) || ' is' || l_locals || 'begin' ||indent;

  -- add the body of this procedure to the package.
  add_to_package_body( l_proc_body_tbl );
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tups.generate_insert_dml',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.generate_insert_dml',
                         '(none)','R');
     raise;
end generate_insert_dml;
-- ----------------------- generate_update_dml  ---------------------------
-- Description:
-- Generates the update_dml procedure of the TUPS
-- ------------------------------------------------------------------------
procedure generate_update_dml
(
  p_table_info       in     hr_dm_gen_main.t_table_info
)
is
  l_interface    varchar2(32767);
  l_locals       varchar2(32767) := null;
  l_cursor       varchar2(32767) := null;
  l_proc_comment varchar2(4000);

  -- block body of the procedure i.e between begin and end.
  l_proc_body   varchar2(32767) := null;

  -- indentation for the statements.it specifies number of blank spaces
  -- after which the staement should start.

  l_indent                  number;
  l_proc_body_tbl           t_varchar2_32k_tbl;
  l_proc_index              number := 1;

  l_columns_tbl              hr_dm_library.t_varchar2_tbl;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tups.generate_update_dml', 5);

  -- input parameters for the procedure

  l_proc_body_tbl(l_proc_index) := indent || '(' ||
                 hr_dm_library.conv_list_to_text (
                 p_rpad_spaces     => l_indent + 2,
                 p_pad_first_line  => 'Y',
                 p_columns_tbl     =>  g_parameters_tbl,
                 p_col_length      =>  70) || indent || ')';

  l_proc_index := l_proc_index + 1;

  -- local variables of the procedure
  l_locals :=  format_comment('Declare cursors and local variables',2)
               || indent ||
              '  l_proc                     varchar2(72) := g_package ' ||
              '|| ''update_dml'';' || indent;

  -- if the table is an HR_DMV_% view then add a p_business_group_id
  -- local variable for the update where clause
  if (p_table_info.use_non_pk_col_for_chk_row  = 'Y') and
     (upper(substr(p_table_info.table_name,1,7)) = 'HR_DMV_') then
    l_locals := l_locals || '  p_business_group_id        number      := NULL;'
                || indent;
  end if;

  -- add the body of the download procedure
  l_indent := 2;

  -- get the list of columns of the table without primary key columns
  hr_dm_library.get_cols_list_wo_pk_cols (
          p_columns_tbl          => g_columns_tbl,
          p_pk_columns_tbl       => g_pk_columns_tbl ,
          p_cols_wo_pk_cols_tbl  => l_columns_tbl );

  -- if there are columns in the table other than primary key column i.e
  -- l_columns_tbl list is not null then create the update script, otherwise,
  -- create the dummy update procedure.

  if l_columns_tbl.exists(1) then

   -- This table contains the column other than primary key columns.

    -- prepare update DML statement

    l_proc_body_tbl(l_proc_index) := format_comment('update all columns of' ||
              ' the row.', l_indent)  || indent ||
              '  update ' || p_table_info.upload_table_name || ' ' || p_table_info.alias
              || indent(l_indent) || 'set ' ||
               hr_dm_library.get_func_asg (
                             p_rpad_spaces     => l_indent + 4,
                             p_columns_tbl     => l_columns_tbl,
                             p_prefix_left_asg => null ,
                             p_omit_business_group_id  => 'N',
                             p_comma_on_first_line     => 'N',
                             p_pad_first_line          => 'N',
                             p_equality_sign           => ' = ');

    l_proc_index := l_proc_index + 1;

    --
    -- if the table has 'R' type hierarchy then use the where clause same as
    -- used in the chk_row_exists cursor
    --
    if p_table_info.use_non_pk_col_for_chk_row  = 'Y' then
      l_proc_body_tbl(l_proc_index) := indent(l_indent) ||
                                       g_chk_row_exists.where_clause ;
    else
      l_proc_body_tbl(l_proc_index) := indent(l_indent) ||
                      '  where' || hr_dm_library.get_func_asg (
                             p_rpad_spaces     => 0,
                             p_columns_tbl     => g_pk_columns_tbl,
                             p_prefix_left_asg => null ,
                             p_prefix_right_asg => 'p_',
                             p_omit_business_group_id  => 'N',
                             p_comma_on_first_line     => 'N',
                             p_pad_first_line          => 'N',
                             p_equality_sign           => ' = ',
                             p_start_terminator        => '  and   ') ||';';
    end if;
  else
     -- This table does not contains the column other than primary key columns.
     -- hence write a dummy procedure.

      l_proc_body_tbl(l_proc_index) := format_comment('This table does not' ||
      ' contain any columns other than primary key column. Hence no update' ||
      ' statement is required.', l_indent) || indent(l_indent) || 'null;';

  end if;
  l_proc_index := l_proc_index + 1;
  l_proc_body_tbl(l_proc_index) :=  indent || 'end update_dml;';


  l_proc_comment := format_comment('procedure to update a row in '
  || upper(p_table_info.upload_table_name) || ' table.') ||  indent;

   -- add local variables , cursor and procedure body to complete the procedure
   l_proc_body_tbl(1) :=  l_proc_comment || 'procedure update_dml' ||
              l_proc_body_tbl(1) || ' is'|| l_locals || indent ||
             'begin'  || indent;

   -- add the body of this procedure to the package.
   add_to_package_body( l_proc_body_tbl );
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tups.generate_update_dml',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.generate_update_dml',
                         '(none)','R');
     raise;
end generate_update_dml;
-- ----------------------- generate_upload_hierarchy  ---------------------------
-- Description:
-- Generates the update hierarchy procedure of the TUPS to update
-- hierarchical columns of the table.
-- For upload of hierarchy columns, we are assuming that there
-- will be no H hierarchy columns where the same column will also
-- have an A hierarchy.
-- ------------------------------------------------------------------------
procedure generate_upload_hierarchy
(
  p_table_info              in     hr_dm_gen_main.t_table_info,
  p_header                  in out nocopy varchar2
)
is
  l_interface    varchar2(32767);
  l_locals       varchar2(32767) := null;
  l_cursor       varchar2(32767) := null;
  l_proc_comment varchar2(4000);
  l_proc_name    varchar2(30) := 'h' || p_table_info.short_name;

  -- block body of the procedure i.e between begin and end.
  l_proc_body   varchar2(32767) := null;
  l_resolve_pk_local_var   varchar2(2000) := null;
  l_prefix_right_asg       varchar2(10) := 'p_';

  -- indentation for the statements.it specifies number of blank spaces
  -- after which the staement should start.

  l_indent                  number;
  l_proc_body_tbl           t_varchar2_32k_tbl;
  l_proc_index              number := 1;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tups.generate_upload_hierarchy', 5);

 -- input parameters for the procedure

  l_interface := indent ||'(p_last_migration_date          in  date' ||
                 indent  ||',p_migration_type               in  varchar2'
                 || indent ||',';

  -- add the column parameters to the procedure.
  l_interface := l_interface ||
                 hr_dm_library.conv_list_to_text(
                  p_rpad_spaces    => 0,
                  p_pad_first_line => 'N',
                  p_columns_tbl => g_hier_parameters_tbl,
                  p_col_length  => 70) ||indent || ')' ;

  l_proc_body_tbl(l_proc_index) := l_interface;
  l_proc_index := l_proc_index + 1;

  -- local variables of the procedure

  l_locals :=  format_comment('Declare cursors and local variables',2)
               || indent ||
              '  l_proc                     varchar2(72) := g_package ' ||
              '|| ''' || l_proc_name || ''';' || indent;

  -- add the body of the download procedure
  l_indent := 2;

  l_proc_body_tbl(l_proc_index) := indent(l_indent)||
                                   'if p_migration_type <> ''SR'' then ';
  l_proc_index := l_proc_index + 1;

  l_indent := 4;

  -- since the table has 'H' type hierarchy add the code to get the
  -- code to get the ID value of the column used in the destination database.
  -- It is done by getting the value from get_resolve_pk function.

  if p_table_info.use_non_pk_col_for_chk_row = 'Y' then
     prepare_code_for_resolving_pk
     (p_pk_columns_tbl          => g_pk_columns_tbl,
      p_table_info              => p_table_info,
      p_call_to_proc_body       => l_proc_body,
      p_local_var_body          => l_resolve_pk_local_var
     );

    l_locals :=  l_locals || l_resolve_pk_local_var || indent;

    l_proc_body_tbl(l_proc_index) := l_proc_body;
    l_proc_index := l_proc_index + 1;

    l_prefix_right_asg := 'l_';

  end if;



  l_proc_body_tbl(l_proc_index) :=
                 indent||format_comment('update all columns of the row.',l_indent);
  l_proc_index := l_proc_index + 1;

  -- update the row
  l_proc_body_tbl(l_proc_index) := indent(l_indent)||'update ' ||
                                   p_table_info.upload_table_name ||
                                   indent(l_indent)||'set ';
  l_proc_index := l_proc_index + 1;

  l_proc_body_tbl(l_proc_index) :=
                 hr_dm_library.get_func_asg (
                           p_rpad_spaces     => l_indent + 4,
                           p_columns_tbl     => g_hier_columns_tbl,
                           p_prefix_left_asg => null ,
                           p_prefix_right_asg => 'p_',
                           p_omit_business_group_id  => 'N',
                           p_comma_on_first_line     => 'N',
                           p_pad_first_line          => 'N',
                           p_equality_sign           => ' = ',
                           p_left_asg_pad_len        => 30,
                           p_right_asg_pad_len       => 30);
  l_proc_index := l_proc_index + 1;

  l_proc_body_tbl(l_proc_index) := indent(l_indent)||'  where'||
                hr_dm_library.get_func_asg (
                           p_rpad_spaces     => 0,
                           p_columns_tbl     => g_pk_columns_tbl,
                           p_prefix_left_asg => null ,
                           p_prefix_right_asg => l_prefix_right_asg,
                           p_omit_business_group_id  => 'N',
                           p_comma_on_first_line     => 'N',
                           p_pad_first_line          => 'N',
                           p_equality_sign           => ' = ',
                           p_start_terminator        => '  and   ') ||';';
  l_proc_index := l_proc_index + 1;

  l_indent := 2;
  l_proc_body_tbl(l_proc_index) := indent(l_indent)||'end if;'||indent || 'end ' || l_proc_name || ';';

  l_proc_comment := format_comment('procedure to upload hierarchy columns of '
  || upper(p_table_info.upload_table_name) || ' from datapump interface table.')||
  indent;

  -- add the procedure comment defination to the package header and body
  p_header := p_header || l_proc_comment ||'procedure ' || l_proc_name ||
              l_interface|| ';';

  l_proc_body_tbl(1)  := l_proc_comment || 'procedure ' || l_proc_name ||
             l_proc_body_tbl(1) || ' is';

  -- add local variables , cursor and procedure body to complete the procedure
  l_proc_body_tbl(1) := l_proc_body_tbl(1) || l_locals || indent || 'begin'
             || indent ;

  -- add the body of this procedure to the package.
  add_to_package_body( l_proc_body_tbl);
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tups.generate_upload_hierarchy',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.generate_upload_hierarchy',
                         '(none)','R');
     raise;
end generate_upload_hierarchy;
-- ----------------------- generate_delete_dml  ---------------------------
-- Description:
-- Generates the delete_dml procedure of the TUPS
-- ------------------------------------------------------------------------
procedure generate_delete_dml
(
  p_table_info       in     hr_dm_gen_main.t_table_info
)
is
  l_interface    varchar2(32767);
  l_locals       varchar2(32767) := null;
  l_cursor       varchar2(32767) := null;
  l_proc_comment varchar2(4000);

  -- block body of the procedure i.e between begin and end.
  l_proc_body   varchar2(32767) := null;

  -- indentation for the statements.it specifies number of blank spaces
  -- after which the staement should start.

  l_indent                  number;
  l_proc_body_tbl           t_varchar2_32k_tbl;
begin
  hr_dm_utility.message('ROUT','entry:hr_dm_gen_tups.generate_delete_dml', 5);

  -- input parameters for the procedure

  if p_table_info.use_non_pk_col_for_chk_row  = 'Y' then

    l_interface :=  indent || g_delete_dml.proc_parameters || indent;
  else
    l_interface :=  indent || '(' ||
                 hr_dm_library.conv_list_to_text(
                  p_rpad_spaces    => 0,
                  p_pad_first_line => 'N',
                  p_columns_tbl => g_pk_parameters_tbl,
                  p_col_length  => 70) || ') ' || indent;
  end if;

  -- local variables of the procedure

  l_locals :=  format_comment('Declare cursors and local variables',2)
               || indent ||
              '  l_proc                     varchar2(72) := g_package ' ||
              '|| ''delete_dml'';' || indent;
  -- add the body of the download procedure
  l_indent := 2;

  l_proc_body := format_comment('delete the logical records for the given id.',
                                 l_indent)  || indent;

  if upper(p_table_info.upload_table_name) = 'FF_FORMULAS_F' then
     -- construct delete dml to delte the logical record
     l_proc_body := l_proc_body ||
                    '  delete ff_compiled_info_f where formula_id in (
                       select '||p_table_info.alias||'.formula_id
                         from ff_formulas_f '||p_table_info.alias;

    l_proc_body := l_proc_body ||  indent(l_indent) ||
                                       replace(g_delete_dml.where_clause,';','')||');'||indent(l_indent) ;

  end if;

  -- construct delete dml to delte the logical record
  l_proc_body := l_proc_body ||
                 '  delete ' || p_table_info.upload_table_name || ' ' ||
                 p_table_info.alias;

  if p_table_info.use_non_pk_col_for_chk_row  = 'Y' then
    l_proc_body := l_proc_body ||  indent(l_indent) ||
                                       g_delete_dml.where_clause ;
  else
    l_proc_body := l_proc_body || indent(l_indent) ||
                 '  where' || hr_dm_library.get_func_asg (
                           p_rpad_spaces     => 0,
                           p_columns_tbl     => g_pk_columns_tbl,
                           p_prefix_left_asg => p_table_info.alias || '.'  ,
                           p_prefix_right_asg => 'p_',
                           p_omit_business_group_id  => 'N',
                           p_comma_on_first_line     => 'N',
                           p_pad_first_line          => 'N',
                           p_equality_sign           => ' = ',
                           p_left_asg_pad_len        => 80,
                           p_right_asg_pad_len       => 80,
                           p_test_with_nvl           => 'Y',
                           p_table_name              => upper(p_table_info.upload_table_name),
                           p_start_terminator        => '  and   ') ||';';

  end if;

  l_proc_body := l_proc_body || indent || 'end delete_dml;';


  l_proc_comment := format_comment('procedure to delete the logical record for'
  ||  ' a given id in '|| upper(p_table_info.upload_table_name) || ' table.')||
  indent;

  -- add the procedure comment defination,local variables , cursor and
  -- procedure body

  l_proc_body_tbl(1) :=   l_proc_comment || 'procedure delete_dml' ||
                     l_interface || ' is' || l_locals || 'begin' ||
                     indent || l_proc_body ;

  -- add the body of this procedure to the package.
  add_to_package_body( l_proc_body_tbl );
  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tups.generate_delete_dml',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.generate_delete_dml',
                         '(none)','R');
     raise;
end generate_delete_dml;

-- ------------------------- create_tups_pacakge ------------------------
-- Description:  Create the TUPS package and relevant procedures for the table.
-- Input Parameters :
--   p_table_info  - Information about table for which TUPS to be generated. Info
--                  like Datetrack, Global Data, Surrogate Primary key etc about
--                  the table is passed as a record type.
--   p_columns_tbl - All the columns of the table stored as a list.
--   p_parameters_tbl - All the columns of the table stored with data type are
--                   stored as a list. e.g p_business_group_id   number
--                   This is used to create the procedure parameter list for
--                   TUPS procedure.
--   p_aol_columns_tbl  -  All the columns of the table which have foreign key to
--                    AOL table are stored as a list.
--   p_aol_parameters_tbl - All the columns of the table which have foreign key to
--                    AOL table are stored with data type as a list. This is
--                    used as a parameter list for the procedure generated to
--                    get the ID value for the given AOL developer key.
--                    e.g p_user_id  number
--   p_fk_to_aol_columns_tbl  - It stores the list of all the columns which have
--                   foreign on AOL table and corresponding name of the AOL
--                   table.
-- ------------------------------------------------------------------------
procedure create_tups_pacakge
(
 p_table_info             in   hr_dm_gen_main.t_table_info ,
 p_columns_tbl            in   hr_dm_library.t_varchar2_tbl,
 p_parameters_tbl         in   hr_dm_library.t_varchar2_tbl,
 p_aol_columns_tbl        in   hr_dm_library.t_varchar2_tbl,
 p_aol_parameters_tbl     in   hr_dm_library.t_varchar2_tbl,
 p_fk_to_aol_columns_tbl  in   hr_dm_gen_main.t_fk_to_aol_columns_tbl
)
is
  l_header         varchar2(32767);
  l_body           varchar2(32767);
  l_header_comment varchar2(2048);
  l_package_name   varchar2(30) := 'hrdmu_' ||  p_table_info.short_name;
  l_generator_version      hr_dm_tables.generator_version%type;
  l_package_version         varchar2(200);
  l_index          number := 1;
  l_call_to_aol_proc    varchar2(32767);
  l_dev_key_local_var   varchar2(32767);
  l_csr_sql           integer;
  l_rows             number;
  l_proc_body_tbl           t_varchar2_32k_tbl;
  l_proc_index              number := 1;
begin
  g_table_info         := p_table_info;
  g_columns_tbl        := p_columns_tbl;
  g_parameters_tbl     := p_parameters_tbl;
  g_aol_columns_tbl    := p_aol_columns_tbl;
  g_aol_parameters_tbl := p_aol_parameters_tbl;
  g_fk_to_aol_columns_tbl := p_fk_to_aol_columns_tbl;
  g_surrogate_pk_col_param := 'p_' ||
                           rpad(p_table_info.surrogate_pk_column_name,28);

  -- inialize the global package body pl/sql table by deleting all elements.
  init_package_body;

  -- Get the version of the generator to be appended to the TUPS package
  -- generated for a table. This will help in finding out which version
  -- of  Generator is used to generate the TUPS package.

   hr_dm_library.get_generator_version(p_generator_version  => l_generator_version,
                                       p_format_output      => 'Y');

  -- Get the package version of this TDS package body.
  hr_dm_library.get_package_version ( p_package_name     => 'HR_DM_GEN_TUPS',
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
     p_called_from       => 'TUPS' );

  end if;

  -- if one or more columns have to resolve primary key then store the
  -- information about the column and corresponding AOL table e.t.c for each
  -- column.
  if p_table_info.resolve_pk = 'Y' then
    hr_dm_library.populate_fk_to_aol_cols_info
      ( p_table_info            => p_table_info,
        p_fk_to_aol_columns_tbl => g_resolve_pk_columns_tbl,
        p_hierarchy_type         => 'L');
   end if;


  -- populate the list with primary key columns.
  hr_dm_library.populate_pk_columns_list(p_table_info,
                                         g_pk_columns_tbl,
                                         g_pk_parameters_tbl,
                                         g_no_of_pk_columns);

  -- Start the package header and body.
  begin
    --
    -- Set up initial parts of the package header and body.
    --
    l_header_comment :=  l_package_version || indent ||  '/*' || indent ||
    ' * Generated by hr_dm_gen_tups at: '  ||
    to_char( sysdate, 'YYYY/MM/DD HH24:MM:SS' ) || indent ||
    ' * Generated Data Migrator TUPS for : ' || p_table_info.upload_table_name || '.' ||
     indent ||
    ' * Generator Version Used to generate this TUPS is : ' || indent ||
    l_generator_version ||  indent ||
    ' */' || indent || '--' || indent;

    l_header :=
    'create or replace package ' || l_package_name || ' as' || indent ||
    l_header_comment || indent;

    -- add in call to hr_dm_upload.set_globals to set the global variables
    l_header := l_header || indent || '--' || indent ||
                '-- call to hr_dm_upload.set_globals to set the global variables'
                || indent || '--' || indent ||
                'g_temp_var NUMBER := hr_dm_upload.set_globals;' || indent;


    l_proc_body_tbl(1) :=
    'create or replace package body ' || l_package_name || ' as' || indent ||
    l_header_comment;

    -- private package variable
    l_proc_body_tbl(1) :=  l_proc_body_tbl(1) || indent || '--' || indent ||
              '--  Package Variables' || indent ||
              '--' || indent ||
              'g_package  varchar2(33) := ''' || l_package_name || ''';' ||
               indent;

   -- add the body of this procedure to the package.
   add_to_package_body( l_proc_body_tbl );

   if p_table_info.datetrack = 'Y' then

     prepare_glob_var_def_for_dt (p_table_info,
                                  l_header);
   end if;

    -- if the table has a columns which have a foreign key to AOL table then
    -- generate the procedures so as to create the procedures to get the
    -- corresponding developer's key for those columns.

    if p_table_info.fk_to_aol_table = 'Y' then
       generate_get_id_frm_dev_key
       ( p_fk_to_aol_columns_tbl   => p_fk_to_aol_columns_tbl,
         p_table_info              => p_table_info,
         p_body                    => l_body,
         p_call_to_proc_body       => l_call_to_aol_proc,
         p_dev_key_local_var_body  => l_dev_key_local_var);
    end if;
    --
    -- Generate the procedures and functions.
    --

    -- generate chk_row_exists procedure to download data into batch_lines.

    l_body := l_body || indent || '--' || indent;

    -- generate chk_row_exist procedure.
    generate_chk_row_exists(p_table_info);

    -- generate insert_dml procedure to insert the data into table.
    l_body := l_body || indent || '--' || indent;
    generate_insert_dml (p_table_info);

    -- For non date track table generate update_dml procedure to update the
    -- row data. For date track create delete_dml procedure to delete the
    -- data.

    l_body := l_body || indent || '--' || indent;

    if p_table_info.datetrack = 'N' then
       generate_update_dml (p_table_info );
    else
       generate_delete_dml (p_table_info);
    end if;

    -- if the table has a column hierarchy then create a procedure to update
    -- hierarchy columns.
    if p_table_info.column_hierarchy = 'Y' then
       generate_upload_hierarchy
       (p_table_info             => p_table_info,
        p_header                 => l_header);
    end if;

    -- generate upload procedure to upload data into batch_lines.

    l_body := l_body || indent || '--' || indent;
    generate_upload(p_table_info             => p_table_info,
                    p_header                 => l_header,
                    p_body                   => l_body,
                    p_call_to_proc_body      => l_call_to_aol_proc,
                    p_dev_key_local_var_body => l_dev_key_local_var,
                    p_fk_to_aol_columns_tbl  => p_fk_to_aol_columns_tbl);


    l_header := l_header || indent || '--' || indent;
    l_body := l_body || indent || '--' || indent;

    --
    -- Terminate the package body and header.
    --
    l_header := l_header || 'end ' || l_package_name || ';';
    l_body := l_body || 'end ' || l_package_name || ';';
  exception
    when plsql_value_error then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.create_tds_pacakge',
                         'Either TDS package code size is too big or  ' ||
                          ' a value error)',
                          'R');
     raise;
  end;

  --
  -- Compile the header and body.
  --

  hr_dm_library.run_sql( l_header );

  g_package_index := g_package_index+1;
  g_package_body(g_package_index ) := indent || 'end ' ||
                              l_package_name || ';';

  hr_dm_library.run_sql( g_package_body,
                         g_package_index);

  -- check the status of the package
  begin
    hr_dm_library.check_compile (p_object_name => l_package_name,
                                 p_object_type => 'PACKAGE BODY' );
  exception
    when others then
      hr_dm_utility.error(SQLCODE,'Error in compiling TUPS for ' ||
                         p_table_info.table_name ,'(none)','R');
      raise;
  end;

  hr_dm_utility.message('ROUT','exit:hr_dm_gen_tups.create_tups_pacakge',
                         25);
exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_gen_tups.create_tups_pacakge',
                         '(none)','R');
     raise;
end create_tups_pacakge ;

end hr_dm_gen_tups;

/
