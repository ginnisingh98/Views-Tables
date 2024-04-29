--------------------------------------------------------
--  DDL for Package Body BEN_DM_GEN_SELF_REF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DM_GEN_SELF_REF" as
/* $Header: benfdmgnsr.pkb 120.0 2006/06/13 14:58:07 nkkrishn noship $ */


--
-- Exception for generated text exceeding the maximum allowable buffer size.
--
g_package_body    dbms_sql.varchar2s;
g_package_index   number := 0;
type t_varchar2_32k_tbl is table of varchar2(32767) index by binary_integer;
g_package            varchar2(75) := 'ben_dm_gen_self_ref.' ;
plsql_value_error    exception;
pragma exception_init(plsql_value_error, -6502);



--  indent call download indent to avoid the duplicate codes
--  indent created here to maintain the samm name in the codes
function indent
(
 p_indent_spaces  in number default 0,
 p_newline        in varchar2 default 'Y'
) return varchar2 is
  l_spaces     varchar2(100);
begin

  l_spaces := ben_dm_gen_download.indent(p_indent_spaces  => p_indent_spaces,
                                         p_newline        => p_newline ) ;
  return l_spaces;
end indent;


--------------------- init_package_body----------------------------------------
-- This package will delete all the elements from the package body pl/sql table.
-------------------------------------------------------------------------------
procedure init_package_body is
  l_index      number := g_package_body.first;
  l_proc       varchar2(75)  ;
begin
  l_proc     :=   g_package || 'init_package_body' ;
  hr_utility.set_location('Entering:'||l_proc, 5);
  ben_dm_utility.message('ROUT','entry:'|| l_proc , 5);
  -- delete all elements from package body pl/sql table.
  while l_index is not null loop
    g_package_body.delete(l_index);
    l_index := g_package_body.next(l_index);
  end loop;



  --initialize the index
  g_package_index := 0;


  ben_dm_utility.message('ROUT','exit:' || l_proc , 25);
  hr_utility.set_location('Leaving:'||l_proc, 10);
exception
  when others then
     ben_dm_utility.error(SQLCODE,'hr_dm_gen_tups.init_package_body',
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
 l_proc          varchar2(75) ;
begin

  l_proc         :=  g_package||'add_to_package_body' ;
  hr_utility.set_location('Entering:'||l_proc, 5);

  ben_dm_utility.message('ROUT','entry:' || l_proc , 5);
  ben_dm_utility.message('PARA','(p_proc_body_tbl - table of varchar2',10);

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
  ben_dm_utility.message('ROUT','exit:'|| l_proc , 25);
  hr_utility.set_location('Leaving:'||l_proc, 5);
exception
  when others then
     ben_dm_utility.error(SQLCODE,l_proc,
                        '(l_loop_cnt - ' || l_loop_cnt ||
                        ')(l_string_index - ' ||l_string_index ||
                        ')( g_package_index - ' ||  g_package_index || ')'
                        ,'R');
     raise;
end add_to_package_body;



-- ----------------------- generate_reference --------------------------------
-- Description:
-- Generates the upload procedure of the upload
-- ------------------------------------------------------------------------
procedure generate_reference
(
  p_header                  in out nocopy varchar2,
  p_body                    in out nocopy varchar2
)
is
  l_interface    varchar2(32767);
  l_locals       varchar2(32767) := null;
  l_cursor       varchar2(32767) := null;
  l_comment      varchar2(4000);
  l_proc_comment varchar2(4000);
  l_cursor_name  varchar2(30) := 'csr_self_ref' ;

  -- block body of the procedure i.e between begin and end.

  l_proc_name   varchar2(30)    := 'main';
  l_proc_body   varchar2(32767) := null;
  l_resolve_pk_local_var   varchar2(2000) := null;




  cursor c_cols_map  is
     select bcm.column_name ,
         bcm.entity_result_column_name
  from   ben_dm_column_mappings bcm ,
         ben_dm_hierarchies  bdh ,
         ben_dm_Tables bdt
  where  bcm.table_id = bdh.table_id
    and  bdh.hierarchy_type = 'H'
    and  (bcm.column_name = bdh.column_name or  bcm.column_name =  bdt.surrogate_pk_column_name)
    and  bdh.table_id = bdt.table_id
  order by bcm.entity_result_column_name
  ;

  -- indentation for the statements.it specifies number of blank spaces
  -- after which the staement should start.

  l_indent                  number;
  l_proc_body_tbl           t_varchar2_32k_tbl;
  l_proc_index              number := 1;
  l_proc                    varchar2(75) ;
begin
  l_proc                    := g_package|| 'generate_reference' ;
  hr_utility.set_location('Entering : ' || l_proc , 5 ) ;
  ben_dm_utility.message('ROUT','entry:' || l_proc , 5);


  l_interface := indent ||
                '(p_migration_id           in  number'  || indent ||
                ',p_business_group_name    in  varchar2'|| indent ||
                ',p_group_order            in  number'|| indent ||
                ')' || indent ;


  -- build the curosr to get the  information from  ben_dm_entity_result
  l_indent  := 2  ;

  l_cursor := 'Cursor '||  l_cursor_name || '(c_tbl varchar2 )  is ' || indent (l_indent) ;
  l_indent := 4  ;
  l_cursor :=  l_cursor || 'Select  '  ;
  for l_map in  c_cols_map  Loop
      l_cursor :=  l_cursor || indent(l_indent)  || rpad(l_map.ENTITY_RESULT_COLUMN_NAME,40) || ' as '||
                             l_map.COLUMN_NAME || ' ,' ;
  End Loop ;

  l_cursor  := rtrim(l_cursor, ',') || indent(l_indent) ;
  l_indent := 2  ;
  l_cursor :=  l_cursor ||' From BEN_DM_ENTITY_RESULTS ' ||indent (l_indent) ;
  l_indent := 4  ;
  l_cursor :=  l_cursor || 'where table_name = c_tbl '  || indent (l_indent) ;
--  l_cursor :=  l_cursor || ' And MIGRATION_ID = P_MIGRATION_ID   ' ||indent (l_indent) ;
  l_cursor :=  l_cursor || ' And group_order  = P_group_order  ; ' ||indent (l_indent) ;




  l_proc_body_tbl(l_proc_index) := l_interface;

  l_proc_index := l_proc_index + 1;

  -- local variables of the procedure

  l_locals :=  ben_dm_gen_download.format_comment('Declare cursors and local variables',2)
               || indent ||
              '  l_proc                     varchar2(72) := g_package '|| '|| ''main'';' || indent ||
              '  l_fk_map_id                number       ;' || indent ||
              '  l_old_pk_key               number       ;' || indent ||
              '  l_new_pk_key               number       ;' || indent ||
              '  l_source_id                number       ;' || indent ||
              '  l_target_id                number       ;' || indent ||
              '  l_row_count                number  := 0;' || indent ||
              '  l_row_exists               varchar2(1) := ''N'';' ||indent;






  l_proc_comment := ben_dm_gen_download.format_comment('procedure to upload all columns of '
  || ' self reference  from entity results .')||
  indent;

  -- add the procedure comment defination to the package header and body
  p_header := p_header || l_proc_comment ||'procedure ' || l_proc_name ||
              l_interface|| ';';

  l_proc_body_tbl(1)  := l_proc_comment || 'procedure ' || l_proc_name ||
             l_proc_body_tbl(1) || ' is';

  -- add local variables , cursor and procedure body to complete the procedure
  l_proc_body_tbl(1) := l_proc_body_tbl(1) || l_locals || indent || l_cursor
                            || indent ||  'begin' || indent ;

  -- add the body of this procedure to the package.
  add_to_package_body( l_proc_body_tbl );
  ben_dm_utility.message('ROUT',l_proc, 25);
  hr_utility.set_location('Leaving:'||l_proc, 10);
exception
  when others then
     ben_dm_utility.error(SQLCODE,l_proc ,
                         '(none)','R');
     raise;
end generate_reference;

-- ----------------------- generate_insert_dml  ---------------------------
-- Description:
-- Generates the insert_dml procedure of the TUPS
-- ------------------------------------------------------------------------
procedure generate_update_dml
is
  l_locals       varchar2(32767) := null;
  l_cursor       varchar2(32767) := null;
  l_cursor_name  varchar2(30) := 'csr_self_ref' ;
  l_temp         varchar2(32767);
  l_proc_comment varchar2(4000);

  -- block body of the procedure i.e between begin and end.
  l_proc_body   varchar2(32767) := null;

  -- indentation for the statements.it specifies number of blank spaces
  -- after which the staement should start.


  cursor c_cols  is
  select bdh.parent_table_name,
         bdh.parent_id_column_name,
         bdh.column_name,
         bdt.table_name,
         bdt.surrogate_pk_column_name
  from   ben_dm_hierarchies  bdh ,
         ben_dm_Tables bdt
  where  bdh.hierarchy_type = 'H'
    and  bdh.table_id = bdt.table_id
  order by bdh.table_id,bdh.column_name
  ;



  l_indent                  number := 2;
  l_proc_body_tbl           t_varchar2_32k_tbl;
  l_proc_index              number := 1;
  l_list_index              number;
  l_hierarchy_type          ben_dm_hierarchies.hierarchy_type%type  ;
  l_parent_table_name       ben_dm_hierarchies.parent_table_name%type  ;
  l_parent_id_column_name   ben_dm_hierarchies.parent_id_column_name%type ;
  l_proc                    varchar2(75) ;

begin
  l_proc           := g_package || 'generate_update_dml' ;
  hr_utility.set_location('Entering : ' || l_proc , 5 ) ;
  ben_dm_utility.message('ROUT','entry:' || l_proc , 5);

  -- input parameters for the procedure

  l_cursor :=  indent( l_indent) || 'hr_utility.set_location(''Entering : '' || l_proc,5) ; ' || indent(l_indent) ;

  for  i in c_cols  Loop

    if i.SURROGATE_PK_COLUMN_NAME is not null then
       l_cursor :=   l_cursor ||indent(l_indent)||'hr_utility.set_location(''update : ' ||i.table_name||''''||' ,5) ; '||indent(l_indent);
       l_cursor :=  l_cursor || '-- open the curosr to fetch the values from result table ' || indent(l_indent) ;
       l_cursor :=  l_cursor || 'for l_rslt in  ' || l_cursor_name || '(''' || i.table_name||''')' || indent(l_indent) ;
       l_indent :=  4 ;
       l_cursor :=  l_cursor || 'Loop '    ;
       -- Assign the Primary key to the variable
       -- if the table is date tracked find the key in cache before creating

      l_indent := 6 ;
      l_cursor := l_cursor ||indent( l_indent) || '-- Assign the source Primary key to the variable ' || indent(l_indent) ;
      l_cursor := l_cursor|| 'l_old_pk_key    :=  l_rslt.'|| i.SURROGATE_PK_COLUMN_NAME||' ; '||indent(l_indent);
      l_cursor := l_cursor || '-- get the target  Primary key to the variable ' || indent(l_indent) ;
      l_indent := 40 ;
      l_cursor:= l_cursor||'l_new_pk_key := ben_dm_data_util.get_cache_target('||indent(l_indent);
      l_cursor:= l_cursor||' p_table_name          => '''||i.table_name||'''' || indent(l_indent) ;
      l_cursor:= l_cursor||',p_source_id           => l_old_pk_key '||indent(l_indent);
      l_cursor:= l_cursor||',p_source_column       => '''||i.SURROGATE_PK_COLUMN_NAME||'''' || indent(l_indent);
      l_cursor:= l_cursor||',p_business_group_name => p_business_group_name ' || indent(l_indent);
      l_cursor:= l_cursor||  ');' || indent(l_indent) ;
      l_indent := 6 ;
      l_cursor := l_cursor ||  indent(l_indent) ;

      l_proc_body_tbl(l_proc_index) :=  l_cursor  ;
      l_proc_index := l_proc_index + 1;

      -- Assign the foreign  key to the variable
      l_cursor :=  indent( l_indent) || '-- Assign the old Foreign  key to the variable ' || indent(l_indent) ;
      l_cursor :=  l_cursor||indent(l_indent)  || 'l_source_id  :=  l_rslt.' ||i.column_name  ||';' ;
      l_cursor :=  l_cursor|| indent( l_indent) || '-- get the target value  to the variable ' || indent(l_indent) ;
      --  download the mapping keys
      l_cursor := l_cursor||indent(l_indent)  || '--' || 'Get the Key for '||i.parent_table_name ||'.'||
                               i.parent_id_column_name  || indent(l_indent)  ;
       l_cursor := l_cursor|| 'If l_rslt.'||i.column_name||' IS NOT NULL THEN '||indent(l_indent+3);
       l_cursor := l_cursor|| 'l_source_id  :=  l_rslt.'||i.column_name||' ; '||indent(l_indent+3);
       l_cursor := l_cursor|| 'l_target_id  := ben_dm_data_util.get_cache_target('||indent(l_indent+40);
       l_cursor := l_cursor||' p_table_name          => '''||i.parent_table_name||'''' || indent(l_indent+40) ;
       l_cursor := l_cursor||',p_source_id           => l_source_id '||indent(l_indent+40);
       l_cursor := l_cursor||',p_source_column       => '''||i.parent_id_column_name||'''' || indent(l_indent+40);
       l_cursor := l_cursor||',p_business_group_name => p_business_group_name  ' || indent(l_indent+40);
       l_cursor := l_cursor||  ');' || indent(l_indent) ;
       l_cursor := l_cursor|| indent(l_indent +3) ;
       l_cursor := l_cursor|| 'if l_target_id  is not null and l_source_id <> l_target_id then  '||indent(l_indent+6);
       l_cursor := l_cursor|| 'update '|| i.table_name || ' Set ' || i.column_name || '  = l_target_id  ' || indent(l_indent+8)||
                              'where  ' ||  i.column_name || '  = l_source_id  and   ' ||indent(l_indent+8)||
                              i.SURROGATE_PK_COLUMN_NAME ||'  =  l_new_pk_key ; '   ||indent(l_indent+3) ;

       l_indent := 6 ;
       l_cursor := l_cursor|| 'End if ;' || indent(l_indent);
       l_indent := 4 ;
       l_cursor := l_cursor|| 'End if ;' || indent(l_indent);
       l_cursor := l_cursor|| 'End Loop ;  -- for geting record informations ' || indent(l_indent) || indent(l_indent);
    end if ;
  end loop ;

  l_proc_body_tbl(l_proc_index) :=  l_cursor||indent(l_indent) ;
  l_proc_index := l_proc_index + 1;

  l_proc_body_tbl(l_proc_index) :=   indent( l_indent) || 'hr_utility.set_location(''Leaving : '' || l_proc,5) ; ' ;
  l_proc_index := l_proc_index + 1;

  add_to_package_body( l_proc_body_tbl );

  ben_dm_utility.message('ROUT','exit:'|| l_proc , 25);
  hr_utility.set_location('Leaving '|| l_proc , 5 ) ;

exception
  when others then
     ben_dm_utility.error(SQLCODE,l_proc , '(none)','R');
     raise;
end generate_update_dml;

-- ------------------------- main  ------------------------
-- ------------------------------------------------------------------------
procedure main
(
 p_business_group_id      in   number ,
 p_migration_id           in   number
)
is
  l_header                 varchar2(32767);
  l_body                   varchar2(32767);
  l_header_comment         varchar2(2048);
  l_package_name           varchar2(30) ;
  l_generator_version      hr_dm_tables.generator_version%type;
  l_package_version        varchar2(200);
  l_index                  number := 1;
  l_call_to_aol_proc       varchar2(32767);
  l_dev_key_local_var      varchar2(32767);
  l_csr_sql                integer;
  l_rows                   number;
  l_proc_body_tbl          t_varchar2_32k_tbl;
  l_proc_index             number := 1;


  l_proc                   varchar2(75) ;
begin

  l_proc               := g_package||'main' ;
  hr_utility.set_location('Entering:'||l_proc, 5);
  ben_dm_utility.message('ROUT','entry:'||l_proc , 5);



  l_package_name       := 'ben_dm_resolve_reference'  ;

  -- inialize the global package body pl/sql table by deleting all elements.
  init_package_body;


  -- Get the version of the generator to be appended to the TUPS package
  -- generated for a table. This will help in finding out which version
  -- of  Generator is used to generate the TUPS package.

  ben_dm_data_util.get_generator_version(p_generator_version  => l_generator_version,
                                       p_format_output      => 'Y');

  -- Get the package version of this TDS package body.
  hr_dm_library.get_package_version ( p_package_name     => 'BEN_DM_GEN_SELF_REF',
                                      p_package_version  =>  l_package_version,
                                      p_version_type     => 'FULL');




  -- Start the package header and body.
  begin
    --
    -- Set up initial parts of the package header and body.
    --
    l_header_comment :=  l_package_version || indent ||  '/*' || indent ||
    ' * Generated by ben_dm_gen_self_ref at: '  ||
    to_char( sysdate, 'YYYY/MM/DD HH24:MM:SS' ) || indent ||
    ' * Generated Data Migrator TUPS for : .' ||
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
                '--g_temp_var NUMBER := hr_dm_upload.set_globals;' || indent;


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



    -- if the table has a columns which have a foreign key to AOL table then
    -- generate the procedures so as to create the procedures to get the
    -- corresponding developer's key for those columns.
    generate_reference(p_header                 => l_header,
                       p_body                   => l_body
                      );



    -- Generate the procedures and functions.
    --

    -- generate chk_row_exists procedure to download data into batch_lines.


    l_body := l_body || indent || '--' || indent;
    generate_update_dml ;

    -- For non date track table generate update_dml procedure to update the
    -- row data. For date track create delete_dml procedure to delete the
    -- data.



    l_header := l_header || indent || '--' || indent;
    l_body := l_body || indent || '--' || indent;

    --
    -- Terminate the package body and header.
    --
    l_header := l_header || 'end ' || l_package_name || ';';
    l_body := l_body || 'end ' || l_package_name || ';';
  exception
    when plsql_value_error then
     ben_dm_utility.error(SQLCODE,l_proc ,
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
  g_package_body(g_package_index ) := indent(2) || 'End  main  ;' || indent   || 'end ' ||
                              l_package_name || ';';

  hr_dm_library.run_sql( g_package_body,
                         g_package_index);

  -- check the status of the package
  begin
    hr_dm_library.check_compile (p_object_name => l_package_name,
                                 p_object_type => 'PACKAGE BODY' );
  exception
    when others then
      ben_dm_utility.error(SQLCODE,'Error in compiling '|| l_proc  ,'(none)','R');
      raise;
  end;

  ben_dm_utility.message('ROUT','exit:'|| l_proc , 25);
  hr_utility.set_location('Leaving:'||l_proc, 10);

exception
  when others then
     ben_dm_utility.error(SQLCODE,l_proc, '(none)','R');
     raise;
end main ;

end BEN_DM_GEN_SELF_REF;

/
