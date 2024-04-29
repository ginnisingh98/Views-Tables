--------------------------------------------------------
--  DDL for Package Body BEN_DM_GEN_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DM_GEN_UPLOAD" as
/* $Header: benfdmgnup.pkb 120.0 2006/05/04 04:49:21 nkkrishn noship $ */


--
-- Exception for generated text exceeding the maximum allowable buffer size.
--
g_package_body    dbms_sql.varchar2s;
g_package_index   number := 0;
type t_varchar2_32k_tbl is table of varchar2(32767) index by binary_integer;
g_package            varchar2(75) := 'ben_dm_gen_upload.' ;
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



-- ----------------------- generate_upload --------------------------------
-- Description:
-- Generates the upload procedure of the upload
-- ------------------------------------------------------------------------
procedure generate_upload
(
  p_table_info              in     ben_dm_gen_download.t_ben_dm_table,
  p_header                  in out nocopy varchar2,
  p_body                    in out nocopy varchar2
)
is
  l_interface    varchar2(32767);
  l_locals       varchar2(32767) := null;
  l_cursor       varchar2(32767) := null;
  l_comment      varchar2(4000);
  l_proc_comment varchar2(4000);
  l_cursor_name  varchar2(30) := 'csr_mig_' || p_table_info.table_alias;

  -- block body of the procedure i.e between begin and end.

  l_proc_name   varchar2(30)    := 'upload';
  l_proc_body   varchar2(32767) := null;
  l_resolve_pk_local_var   varchar2(2000) := null;



  cursor c_cols_map (c_tbl_id number , c_table_name  varchar2) is
  select a.column_name ,
         a.entity_result_column_name
  from   ben_dm_column_mappings a ,
         sys.all_tab_columns  b
  where  a.table_id = c_tbl_id
    and  a.column_name = b.column_name
    and  b.table_name = c_table_name
  order by b.column_id
  ;

  -- indentation for the statements.it specifies number of blank spaces
  -- after which the staement should start.

  l_indent                  number;
  l_proc_body_tbl           t_varchar2_32k_tbl;
  l_proc_index              number := 1;
  l_proc                    varchar2(75) ;
begin
  l_proc                    := g_package|| 'generate_upload' ;
  hr_utility.set_location('Entering : ' || l_proc , 5 ) ;
  ben_dm_utility.message('ROUT','entry:' || l_proc , 5);


  l_interface := indent ||
                '(p_migration_id           in  number'  || indent ||
                ',p_business_group_id      in  number'  || indent ||
                ',p_business_group_name    in  varchar2'|| indent ||
                ',p_group_order            in  number'  || indent ||
                ',p_delimiter              in  varchar2'|| indent ||
                 ')' || indent ;


  -- build the curosr to get the  information from  ben_dm_entity_result
  l_indent  := 2  ;

  l_cursor := 'Cursor '||  l_cursor_name || ' is ' || indent (l_indent) ;
  l_indent := 4  ;
  l_cursor :=  l_cursor || 'Select  ' ||   indent (l_indent) ;
  if p_table_info.SEQUENCE_NAME is not null   then
     l_cursor :=  l_cursor || rpad(p_table_info.SEQUENCE_NAME || '.NEXTVAL',40)||' As  PM_KEY '||indent(l_indent);
  else
     l_cursor :=  l_cursor || rpad('Null',40) ||' As  PM_KEY '||indent(l_indent);
  end if ;
  for l_map in  c_cols_map (p_table_info.table_id, p_table_info.table_name) Loop
      l_cursor :=  l_cursor || ','|| rpad(l_map.ENTITY_RESULT_COLUMN_NAME,40) || ' as '||
                                        l_map.COLUMN_NAME || indent(l_indent);
  End Loop ;
  l_indent := 2  ;
  l_cursor :=  l_cursor ||' From BEN_DM_ENTITY_RESULTS ' ||indent (l_indent) ;
  l_indent := 4  ;
  l_cursor :=  l_cursor || 'where table_name = '''|| p_table_info.table_name ||''''  || indent (l_indent) ;
  l_cursor :=  l_cursor || ' And GROUP_ORDER  = P_GROUP_ORDER  ' ||indent (l_indent) ;
  --l_cursor :=  l_cursor || ' And MIGRATION_ID = P_MIGRATION_ID ' ||
  l_cursor :=  l_cursor || '  ; ' ||indent (l_indent) ;




  l_proc_body_tbl(l_proc_index) := l_interface;

  l_proc_index := l_proc_index + 1;

  -- local variables of the procedure

  l_locals :=  ben_dm_gen_download.format_comment('Declare cursors and local variables',2)
               || indent ||
              '  l_proc                     varchar2(72) := g_package '|| '|| ''upload'';' || indent ||
              '  l_fk_map_id                number       ;' || indent ||
              '  l_table_name               varchar2(72) ;' || indent ||
              '  l_old_pk_id                number       ;' || indent ||
              '  l_pk_key                   number       ;' || indent ||
              '  l_row_count                number  := 0;' || indent ||
              '  l_text                     varchar2(32767);'||indent||
              '  l_row_exists               varchar2(1) := ''N'';' ||indent || indent;



  if p_table_info.table_name = 'PER_ALL_PEOPLE_F' then

      l_locals :=  l_locals || 'Cursor c_target_ssn (p_per_id number) is ' || indent  ;
      l_locals :=  l_locals || 'select TARGET_NATIONAL_IDENTIFIER ' || indent ;
      l_locals :=  l_locals || '   from ben_dm_input_file  ' || indent ;
      l_locals :=  l_locals || '  where source_person_id = p_per_id   ' || indent ;
      --l_locals :=  l_locals || '    and migration_id  = p_migration_id ' || indent ;
      l_locals :=  l_locals || '    and TARGET_BUSINESS_GROUP_NAME  = p_BUSINESS_GROUP_NAME ' || indent ;
      l_locals :=  l_locals || '    and Group_order                 = p_group_order ' || indent ;
      l_locals :=  l_locals || '   ; ' || indent ;
      l_locals :=  l_locals || 'l_new_ssn                  varchar2(80) ;  ' || indent ;

  end if ;

  if p_table_info.table_name = 'BEN_LE_CLSN_N_RSTR' then

      l_locals :=  l_locals || 'Cursor c_pk_column (p_tbl_name varchar2) is ' || indent  ;
      l_locals :=  l_locals || 'select SURROGATE_PK_COLUMN_NAME  ' || indent ;
      l_locals :=  l_locals || '   from ben_dm_tables  ' || indent ;
      l_locals :=  l_locals || '  where table_name  = p_tbl_name   ' || indent ;
      l_locals :=  l_locals || '   ; ' || indent ;
      l_locals :=  l_locals || 'l_pk_column_name           varchar2(80) ;  ' || indent ;

  end if ;


  l_proc_comment := ben_dm_gen_download.format_comment('procedure to upload all columns of '
  || upper(p_table_info.table_name) || ' from entity results .')||
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
     ben_dm_utility.error(SQLCODE,'hr_dm_gen_tups.generate_upload',
                         '(none)','R');
     raise;
end generate_upload;

-- ----------------------- generate_insert_dml  ---------------------------
-- Description:
-- Generates the insert_dml procedure of the TUPS
-- ------------------------------------------------------------------------
procedure generate_insert_dml
(
  p_table_info       in     ben_dm_gen_download.t_ben_dm_table
)
is
  l_locals       varchar2(32767) := null;
  l_cursor       varchar2(32767) := null;
  l_cursor_name  varchar2(30)    := 'csr_mig_' || p_table_info.table_alias;
  l_temp         varchar2(32767);
  l_proc_comment varchar2(4000);

  -- block body of the procedure i.e between begin and end.
  l_proc_body   varchar2(32767) := null;

  -- indentation for the statements.it specifies number of blank spaces
  -- after which the staement should start.


  cursor c_pk_hier (c_tbl_id number) is
  select bdt.table_alias
         ,bdm.column_name
         ,bdm.parent_table_name
         ,bdm.parent_column_name
         ,bdm.parent_id_column_name
  from  ben_dm_hierarchies bdm , ben_dm_tables bdt
  where bdm.table_id = c_tbl_id
  and  bdm.parent_table_name = bdt.table_name
  ;


  cursor c_H_hier (c_tbl_id number) is
  select 'x'
  from  ben_dm_hierarchies bdm , ben_dm_tables bdt
  where bdm.table_id = c_tbl_id
  and  bdm.parent_table_name = bdt.table_name
  and  bdm.hierarchy_type = 'H'
  ;



  cursor c_cols_map (c_tbl_id number) is
  select decode(col.data_type,'DATE','to_char(l_rslt.'||map.column_name||','||''''||'dd-mon-rrrr'||''''||')','l_rslt.'
         ||map.column_name) column_name ,
         map.entity_result_column_name
  from   ben_dm_column_mappings map,
         ben_dm_tables tab,
         sys.all_tab_columns col
  where  tab.table_id = c_tbl_id
    and  map.table_id = tab.table_id
    and  col.column_name = map.column_name
    and  col.table_name = tab.table_name
  order by col.column_id
  ;

  cursor hier_type (p_col_name varchar2) is
  select bdh.hierarchy_type ,
        bdh.parent_table_name,
        bdh.parent_id_column_name
  from  ben_dm_hierarchies bdh
  where bdh.table_id    = p_table_info.table_id
   and  bdh.column_name= p_col_name
  ;


  l_indent                  number := 2;
  l_proc_body_tbl           t_varchar2_32k_tbl;
  l_proc_index              number := 1;
  l_list_index              number;
  l_hierarchy_type          ben_dm_hierarchies.hierarchy_type%type  ;
  l_parent_table_name       ben_dm_hierarchies.parent_table_name%type  ;
  l_parent_id_column_name   ben_dm_hierarchies.parent_id_column_name%type ;
  l_proc                    varchar2(75) ;
  l_h_hierarcy              varchar2(1) ;
  l_dummy                   varchar2(1) ;

begin
  l_proc           := g_package || 'generate_insert_dml' ;
  hr_utility.set_location('Entering : ' || l_proc , 5 ) ;
  ben_dm_utility.message('ROUT','entry:' || l_proc , 5);

  -- input parameters for the procedure

  l_cursor :=  indent( l_indent) || 'hr_utility.set_location(''Entering : '' || l_proc,5) ; ' || indent(l_indent) ||
               ' ben_dm_utility.message(''ROUT'','' Entering  '' ||l_proc,5) ; ' || indent(l_indent) ||
               ' ben_dm_utility.message(''PARA'', '' ( Source BG  - '' || p_business_group_id  || '')'' , 10) ;'||  indent(l_indent) ||
               ' ben_dm_utility.message(''PARA'', '' ( Target BG  - '' || p_business_group_name  || '')'' , 10) ;'||  indent(l_indent)||
               ' ben_dm_utility.message(''PARA'', '' ( group_order  - '' || p_group_order  || '')'' , 10) ; '|| indent(l_indent) ;

  -- decide the table has any pig year relation
  l_h_hierarcy   := 'N' ;
  open  c_H_hier(p_table_info.table_id) ;
  fetch  c_H_hier into l_dummy ;
  if c_H_hier%found then
    l_h_hierarcy  := 'Y' ;
  end if ;
  close c_H_hier ;

  l_cursor :=  l_cursor || '-- open the curosr to fetch the values from result table ' || indent(l_indent) ;
  l_cursor :=  l_cursor || 'for l_rslt in  ' || l_cursor_name || indent(l_indent) ;
  l_indent :=  4 ;
  l_cursor :=  l_cursor || 'Loop ' ||    indent(l_indent) ;
  -- Assign the Primary key to the variable
  -- if the table is date tracked find the key in cache before creating

  hr_utility.set_location('PK column name   : ' || p_table_info.SURROGATE_PK_COLUMN_NAME , 5 ) ;
  if  p_table_info.SURROGATE_PK_COLUMN_NAME is not null then
    l_indent := 6 ;
    l_cursor := l_cursor ||indent( l_indent) || '-- Assign the Primary key to the variable ' || indent(l_indent) ;
    l_cursor := l_cursor || 'if ' || 'l_rslt.' || p_table_info.SURROGATE_PK_COLUMN_NAME||' Is not null  '||indent(l_indent);
    l_indent := 9 ;
    l_cursor := l_cursor || '   and  ' || 'l_rslt.PM_KEY is not null then ' ||indent(l_indent);
    l_cursor := l_cursor|| 'l_fk_map_id   :=  l_rslt.'|| p_table_info.SURROGATE_PK_COLUMN_NAME||' ; '||indent(l_indent);
    l_cursor := l_cursor|| 'l_old_pk_id    :=  l_rslt.'|| p_table_info.SURROGATE_PK_COLUMN_NAME||' ; '||indent(l_indent);
    --l_indent :=  4 ;

    --- check the pk from cache whne the table is date track
    hr_utility.set_location('datetrack  : ' || p_table_info.DATETRACK , 5 ) ;
    if p_table_info.DATETRACK   = 'Y'  or l_h_hierarcy = 'Y'  then

       l_indent := 40 ;
       l_cursor:= l_cursor||'l_pk_key := ben_dm_data_util.get_cache_target('||indent(l_indent);
       l_cursor:= l_cursor||' p_table_name          => '''||p_table_info.table_name||'''' || indent(l_indent) ;
       l_cursor:= l_cursor||',p_source_id           => l_fk_map_id '||indent(l_indent);
       l_cursor:= l_cursor||',p_source_column       => '''||p_table_info.SURROGATE_PK_COLUMN_NAME||'''' || indent(l_indent);
       l_cursor:= l_cursor||',p_business_group_name => p_business_group_name ' || indent(l_indent);
       l_cursor:= l_cursor||  ');' || indent(l_indent) ;
       l_indent:= 9 ;
       l_cursor:= l_cursor|| indent(l_indent ) ;
       l_cursor:= l_cursor|| '-- if the l_pk_key is value null or same as source then assign the new value '||indent(l_indent);
       l_indent := 12 ;
       l_cursor:= l_cursor|| 'if l_pk_key  is null or l_pk_key = l_fk_map_id then  '||indent(l_indent);
       l_cursor := l_cursor || 'l_rslt.' || p_table_info.SURROGATE_PK_COLUMN_NAME || ':=  l_rslt.PM_KEY ; '|| indent(l_indent);
       l_cursor := l_cursor || 'hr_utility.set_location( ''PK OF '||p_table_info.table_name ||' ''|| l_rslt.PM_KEY'||',20) ;'
                               || indent(l_indent) ;

       -- update the  prmiary key to  mapping table
       l_cursor := l_cursor ||  '-- update the  primiary key to  mapping table ' || indent(l_indent) ;
       l_indent := 40 ;
       l_cursor := l_cursor || 'ben_dm_data_util.create_pk_cache( '  || indent(l_indent) ;
       l_cursor := l_cursor || ' p_target_id           =>  l_rslt.PM_KEY   '  || indent(l_indent) ;
       l_cursor := l_cursor || ',p_table_name          =>  '''||p_table_info.table_name||'''' || indent(l_indent) ;
       l_cursor := l_cursor || ',p_source_id           =>  l_fk_map_id' || indent(l_indent)    ;
       l_cursor := l_cursor || ',p_source_column       =>  '''||p_table_info.SURROGATE_PK_COLUMN_NAME||'''' ||indent(l_indent);
       l_cursor := l_cursor || ',p_business_group_name =>  p_business_group_name' || indent(l_indent) ;
       l_cursor := l_cursor || ' ); '   || indent(l_indent) ;
       l_indent:= 9  ;
       l_cursor:= l_cursor|| indent(l_indent);
       l_indent:= 12 ;
       l_cursor:= l_cursor|| 'Else   '||indent(l_indent);
       l_cursor:= l_cursor|| indent(l_indent)||'hr_utility.set_location('' PK Already exisit : '' || l_pk_key,10) ;'
                          ||indent(l_indent);
       l_cursor:= l_cursor || 'l_rslt.'||p_table_info.SURROGATE_PK_COLUMN_NAME || ':=  l_pk_key ; '|| indent(l_indent);
       l_indent:= 6 ;
       l_cursor:= l_cursor|| indent(l_indent);
       l_cursor:= l_cursor|| 'End if ;   --  Primary key for date track table    '||indent(l_indent);
    else
       l_cursor := l_cursor || 'l_rslt.' || p_table_info.SURROGATE_PK_COLUMN_NAME || ':=  l_rslt.PM_KEY ; '|| indent(l_indent);
       l_cursor := l_cursor || 'hr_utility.set_location( ''PK OF '||p_table_info.table_name ||' ''|| l_rslt.PM_KEY' ||',20) ;'
                               || indent(l_indent) ;

       -- update the  prmiary key to  mapping table
       l_cursor := l_cursor ||  '-- update the  prmiary key to  mapping table ' || indent(l_indent) ;
       l_indent := 40 ;
       l_cursor := l_cursor || 'ben_dm_data_util.create_pk_cache( '  || indent(l_indent) ;
       l_cursor := l_cursor || ' p_target_id           =>  l_rslt.PM_KEY   '  || indent(l_indent) ;
       l_cursor := l_cursor || ',p_table_name          =>  '''||p_table_info.table_name||'''' || indent(l_indent) ;
       l_cursor := l_cursor || ',p_source_id           =>  l_fk_map_id' || indent(l_indent)    ;
       l_cursor := l_cursor || ',p_source_column       =>  '''||p_table_info.SURROGATE_PK_COLUMN_NAME||'''' ||indent(l_indent);
       l_cursor := l_cursor || ',p_business_group_name =>  p_business_group_name' || indent(l_indent) ;
       l_cursor := l_cursor || ' ); '   || indent(l_indent) ;

   end if ;
   --l_cursor := l_cursor || ' ben_dm_utility.message(''INFO'','' Primary KEY  '' ||l_rslt.PM_KEY ,5) ; ' || indent(l_indent) ;
   l_indent := 4 ;
   l_cursor := l_cursor ||  indent(l_indent) ;

   --l_indent :=  6 ;
   l_cursor := l_cursor || 'End if  ; -- primary key handling' ||indent(l_indent);



 end if ;   --  if the surrogate key is not null create pm key
 hr_utility.set_location('after PK column name   : ' || p_table_info.SURROGATE_PK_COLUMN_NAME , 5 ) ;

 l_proc_body_tbl(l_proc_index) :=  l_cursor  ;
 l_proc_index := l_proc_index + 1;

  l_indent := 4 ;

  -- Assign the foreign  key to the variable
  hr_utility.set_location('before  FK column name   ' , 5 ) ;

  l_cursor :=  indent( l_indent) || '-- Assign the Foreign  key to the variable ' || indent(l_indent) ;
   --  download the mapping keys
  for  l_pk_rec  in   c_pk_hier(p_table_info.table_id )   Loop
       hr_utility.set_location('IN  FK column name   '||p_table_info.table_id ||  l_pk_rec.column_name  , 5 ) ;

       l_cursor := l_cursor||indent(l_indent)  || '--' || 'Get the Key for '||l_pk_rec.parent_table_name ||'.'||
                               l_pk_rec.parent_column_name  || indent(l_indent)  ;
       l_cursor := l_cursor|| 'If l_rslt.'||l_pk_rec.column_name||' IS NOT NULL THEN '||indent(l_indent+3);
       l_cursor := l_cursor|| 'l_fk_map_id   :=  l_rslt.'||l_pk_rec.column_name||' ; '||indent(l_indent+3);
       --- decide the function to be called if the hieracry type is 'S' call mapping target else cache_target
       --- pass the  parent table name and parent column name
       l_parent_table_name     := null ;
       l_parent_id_column_name := null ;
       l_hierarchy_type        := null ;
       open hier_type(l_pk_rec.column_name) ;
       fetch hier_type into
                       l_hierarchy_type,
                       l_parent_table_name ,
                       l_parent_id_column_name ;
       close hier_type ;
       hr_utility.set_location(' hierarchy_type e   '||  l_hierarchy_type   , 5 ) ;
       if l_hierarchy_type is not null then
          if  l_hierarchy_type = 'S' then
           l_cursor:=l_cursor||'l_rslt.'||l_pk_rec.column_name||':= ben_dm_data_util.get_mapping_target('||indent(l_indent+40);
          else
           l_cursor:=l_cursor||'l_rslt.'||l_pk_rec.column_name||':= ben_dm_data_util.get_cache_target('||indent(l_indent+40);
          end if ;
          l_cursor := l_cursor||' p_table_name          => '''||l_parent_table_name||'''' || indent(l_indent+40) ;
          l_cursor := l_cursor||',p_source_id           => l_fk_map_id '||indent(l_indent+40);
          l_cursor := l_cursor||',p_source_column       => '''||l_parent_id_column_name||'''' || indent(l_indent+40);
          l_cursor := l_cursor||',p_business_group_name => p_business_group_name  ' || indent(l_indent+40);
          l_cursor := l_cursor||  ');' || indent(l_indent) ;
          l_cursor := l_cursor|| indent(l_indent +3) ;
          l_cursor := l_cursor|| '-- if the source value is not null and target value is null '  || indent(l_indent +3) ;
          l_cursor := l_cursor|| '-- assign back the source value '  || indent(l_indent +3) ;
          l_cursor := l_cursor|| '-- if the column is pig year then get new id from seq and store in cache '  || indent(l_indent +3) ;
          l_cursor := l_cursor|| 'hr_utility.set_location(''FK OF '||l_pk_rec.column_name||'''||l_rslt.'||l_pk_rec.column_name
                                  ||',20) ; ' || indent(l_indent +3) ;
          l_cursor := l_cursor|| 'if l_fk_map_id is not null and  ( l_rslt.'||l_pk_rec.column_name||
                                     ' = l_fk_map_id or  l_rslt.'||l_pk_rec.column_name||' is null ) then '  ||indent(l_indent+6);
          -- handle the hieracy H - Pig year
          -- get new id from from the sequence and stroe in to cache , when the PK is generated,
          -- it wil lget it from the cache
          if  l_hierarchy_type = 'H' then
               l_cursor := l_cursor|| 'Begin ' || indent(l_indent+9);
               l_cursor := l_cursor|| 'select  '||p_table_info.SEQUENCE_NAME ||'.NEXTVAL into  l_rslt.'|| l_pk_rec.column_name
                                    ||' from dual ;'|| indent(l_indent+9);
               l_cursor := l_cursor || 'ben_dm_data_util.create_pk_cache( '  || indent(l_indent+9) ;
               l_cursor := l_cursor || ' p_target_id           =>  l_rslt.'||  l_pk_rec.column_name  || indent(l_indent+9) ;
               l_cursor := l_cursor || ',p_table_name          =>  '''||p_table_info.table_name||'''' || indent(l_indent+9) ;
               l_cursor := l_cursor || ',p_source_id           =>    l_fk_map_id '   || indent(l_indent+9)    ;
               l_cursor := l_cursor || ',p_source_column       =>  '''||p_table_info.SURROGATE_PK_COLUMN_NAME||'''' ||indent(l_indent+9);
               l_cursor := l_cursor || ',p_business_group_name =>  p_business_group_name' || indent(l_indent+9) ;
               l_cursor := l_cursor || ' ); '   || indent(l_indent+6) ;


               l_cursor := l_cursor|| 'Exception ' || indent(l_indent+9);
               l_cursor := l_cursor|| 'When others then  ' || indent(l_indent+9);
               l_cursor := l_cursor|| 'l_rslt.'||l_pk_rec.column_name|| ' := l_fk_map_id ; ' || indent(l_indent+6);
               l_cursor := l_cursor|| 'End  ; ' || indent(l_indent+3);
          else
             l_cursor := l_cursor|| 'l_rslt.'||l_pk_rec.column_name|| ' := l_fk_map_id ; ' || indent(l_indent+3);
          end if ;
          l_cursor := l_cursor|| 'End if ;' || indent(l_indent);
       end if ;
       hr_utility.set_location('after FK column name   '||  l_pk_rec.column_name  , 5 ) ;
       l_cursor := l_cursor|| 'End If ; '||indent(l_indent) ;

       --- whne the cariable length grows beyond
       if  length(l_cursor) > 30000  then
            hr_utility.set_location('length of cursor   '||  length(l_cursor)  , 5 ) ;
           l_proc_body_tbl(l_proc_index) :=  l_cursor  ;
           l_proc_index := l_proc_index + 1;
           l_cursor := ' ' ;

       end if ;
   End Loop ;
   -- end of call to get the FK values



   ---special treatment for per_all_people_f
   if p_table_info.table_name = 'PER_ALL_PEOPLE_F' then
      l_cursor := l_cursor||  indent(l_indent);
      l_cursor := l_cursor|| '-- get the new sssn from input file ' ||   indent(l_indent);
      l_cursor := l_cursor || 'l_new_ssn := null  ; ' || indent(l_indent)  ;
      l_cursor := l_cursor || 'open  c_target_ssn (l_old_pk_id) ; ' || indent(l_indent)  ;
      l_cursor := l_cursor || 'fetch c_target_ssn into l_new_ssn ; ' || indent(l_indent) ;
      l_cursor := l_cursor || 'close  c_target_ssn ;  ' || indent(l_indent) ;
      l_cursor := l_cursor || 'if l_new_ssn is not null then    ' || indent(l_indent) ;
      l_cursor := l_cursor || '   l_rslt.NATIONAL_IDENTIFIER := l_new_ssn ; ' || indent(l_indent) ;
      l_cursor := l_cursor || 'end if ;    ' || indent(l_indent) ;

  end if ;
  l_proc_body_tbl(l_proc_index) :=  l_cursor  ;
  l_proc_index := l_proc_index + 1;

   ---special treatment for  BEN_LE_CLSN_N_RSTR  to fix the PK
  l_cursor := indent(l_indent) ;
  if p_table_info.table_name = 'BEN_LE_CLSN_N_RSTR' then
          hr_utility.set_location('special handing BEN_LE_CLSN_N_RSTR ' , 99 ) ;
          l_cursor := l_cursor|| 'l_table_name   :=  l_rslt.BKUP_TBL_TYP_CD ; '||indent(l_indent);
          l_cursor := l_cursor|| 'if substr(l_table_name,-8)  =  ''_CORRECT''  then  '||indent(l_indent+3);
          l_cursor := l_cursor|| 'l_table_name   :=  rtrim(l_table_name, ''_CORRECT'') ; '||indent(l_indent);
          l_cursor := l_cursor|| 'End if ; '||indent(l_indent);

          l_cursor := l_cursor|| 'if substr(l_table_name,-5)  =  ''_CORR''  then  '||indent(l_indent+3);
          l_cursor := l_cursor|| 'l_table_name   :=  rtrim(l_table_name, ''_CORR'') ; '||indent(l_indent);
          l_cursor := l_cursor|| 'End if ; '||indent(l_indent) || indent(l_indent) ;
          l_cursor := l_cursor|| 'hr_utility.set_location(''table name ''  || l_table_name  , 90); '||indent(l_indent) ;

          l_cursor := l_cursor|| 'l_pk_column_name  := null  ; ' || indent(l_indent)  ;
          l_cursor := l_cursor|| 'open  c_pk_column (l_table_name) ; ' || indent(l_indent)  ;
          l_cursor := l_cursor|| 'fetch c_pk_column into l_pk_column_name ; ' || indent(l_indent) ;
          l_cursor := l_cursor|| 'close c_pk_column ;  ' || indent(l_indent) ;
          l_cursor := l_cursor|| 'hr_utility.set_location(''PK  name ''  || l_pk_column_name  , 90); ' || indent(l_indent) ;
          l_cursor := l_cursor|| 'hr_utility.set_location(''old value  ''  || l_rslt.BKUP_TBL_ID  , 90);' || indent(l_indent)  ;
          l_cursor := l_cursor|| 'if l_pk_column_name is not null then    ' || indent(l_indent+3) ;
          l_cursor := l_cursor|| 'l_fk_map_id   :=  l_rslt.BKUP_TBL_ID ; '||indent(l_indent+3);
          l_cursor := l_cursor|| 'l_rslt.BKUP_TBL_ID '||':= ben_dm_data_util.get_cache_target('||indent(l_indent+40);
          l_cursor := l_cursor|| ' p_table_name          => l_table_name '||indent(l_indent+40) ;
          l_cursor := l_cursor|| ',p_source_id           => l_rslt.BKUP_TBL_ID  '||indent(l_indent+40);
          l_cursor := l_cursor|| ',p_source_column       => l_pk_column_name ' || indent(l_indent+40);
          l_cursor := l_cursor|| ',p_business_group_name => p_business_group_name  ' || indent(l_indent+40);
          l_cursor := l_cursor||  ');' || indent(l_indent) ;
          l_cursor := l_cursor|| 'hr_utility.set_location(''new value  ''  || l_rslt.BKUP_TBL_ID  , 90); ' || indent(l_indent) ;
          l_cursor := l_cursor|| indent(l_indent +3) ;
          l_cursor := l_cursor|| '-- if the source value is not null and target value is null '  || indent(l_indent +3) ;
          l_cursor := l_cursor|| '-- assign back the source value '  || indent(l_indent +3) ;
          l_cursor := l_cursor|| 'hr_utility.set_location(''FK OF  BKUP_TBL_ID ''||l_rslt.BKUP_TBL_ID '||',20);'||indent(l_indent +3) ;
          l_cursor := l_cursor|| 'if l_fk_map_id is not null and l_rslt.BKUP_TBL_ID  is null then'||indent(l_indent+6);
          l_cursor := l_cursor|| 'l_rslt.BKUP_TBL_ID  := l_fk_map_id ; ' || indent(l_indent+3);
          l_cursor := l_cursor|| 'End if ;' || indent(l_indent);
          l_cursor := l_cursor || 'End if ; ---Spl handling   ' || indent(l_indent) ;
          hr_utility.set_location('EOF  BEN_LE_CLSN_N_RSTR ' , 99 ) ;
  elsif p_table_info.table_name = 'BEN_ELIG_PER_ELCTBL_CHC' then
    --
          hr_utility.set_location('special handing BEN_ELIG_PER_ELCTBL_CHC ' , 99 ) ;
          l_cursor := l_cursor|| 'declare '||indent(l_indent+3);

          l_cursor := l_cursor|| 'l_prev_rslt_id_at         number := 0 ;'||indent(l_indent+3);
          l_cursor := l_cursor|| 'l_prev_prtt_enrt_rslt_id  number ;' ||indent(l_indent+3);
          l_cursor := l_cursor|| 'l_curr_prtt_enrt_rslt_id  number ;'||indent(l_indent+3);
          l_cursor := l_cursor|| 'l_cryfwd_elig_dpnt_cd     varchar2(30);' ||indent(l_indent);

          l_cursor := l_cursor|| 'begin  '||indent(l_indent+3);

          --
          l_cursor := l_cursor|| 'l_prev_prtt_enrt_rslt_id := null; '||indent(l_indent+3);
          l_cursor := l_cursor|| 'l_prev_rslt_id_at        := instr(l_rslt.cryfwd_elig_dpnt_cd, ''^'') ;'||indent(l_indent+3);

          --
          l_cursor := l_cursor|| 'if l_prev_rslt_id_at   > 0  then '||indent(l_indent+5);
          l_cursor := l_cursor|| 'Begin '||indent(l_indent+7);
          l_cursor := l_cursor|| 'l_prev_prtt_enrt_rslt_id := to_number(substr(l_rslt.cryfwd_elig_dpnt_cd,l_prev_rslt_id_at+1) );'||indent(l_indent+7);
          l_cursor := l_cursor|| 'IF l_prev_prtt_enrt_rslt_id IS NOT NULL THEN '||indent(l_indent+9);
               --
          l_cursor := l_cursor|| 'l_fk_map_id   :=  l_prev_prtt_enrt_rslt_id ; '||indent(l_indent+9);
          l_cursor := l_cursor|| 'l_curr_prtt_enrt_rslt_id := ben_dm_data_util.get_cache_target( '||indent(l_indent+12);
          l_cursor := l_cursor|| 'p_table_name          => ''BEN_PRTT_ENRT_RSLT_F'' '||indent(l_indent+12);
          l_cursor := l_cursor|| ',p_source_id           => l_fk_map_id  '||indent(l_indent+12);
          l_cursor := l_cursor|| ',p_source_column       => ''PRTT_ENRT_RSLT_ID'' '||indent(l_indent+12);
          l_cursor := l_cursor|| ',p_business_group_name => p_business_group_name '||indent(l_indent+12);
          l_cursor := l_cursor|| '); '||indent(l_indent+9);
          l_cursor := l_cursor|| 'hr_utility.set_location(''FK OF PRTT_ENRT_RSLT_ID''||l_curr_prtt_enrt_rslt_id,20) ; '||indent(l_indent+7);
          l_cursor := l_cursor|| 'End If ; '||indent(l_indent+7);
          l_cursor := l_cursor|| 'Exception '||indent(l_indent+5);
          l_cursor := l_cursor|| 'when value_error then '||indent(l_indent+7);
          l_cursor := l_cursor|| 'l_prev_prtt_enrt_rslt_id := null; '||indent(l_indent+5);
          l_cursor := l_cursor|| 'End  ; '||indent(l_indent+5);

          l_cursor := l_cursor|| 'IF l_curr_prtt_enrt_rslt_id IS NOT NULL THEN '||indent(l_indent+7);
          l_cursor := l_cursor|| 'l_cryfwd_elig_dpnt_cd := substr(l_rslt.cryfwd_elig_dpnt_cd,1,l_prev_rslt_id_at-1) ; '||indent(l_indent+7);
          l_cursor := l_cursor|| 'l_rslt.cryfwd_elig_dpnt_cd := l_cryfwd_elig_dpnt_cd||''^''||l_curr_prtt_enrt_rslt_id ;'||indent(l_indent+5);
          l_cursor := l_cursor|| 'END IF; '||indent(l_indent+3);
          l_cursor := l_cursor|| ' end if ;  '||indent(l_indent);
          l_cursor := l_cursor|| ' end;  '||indent(l_indent);
         hr_utility.set_location('EOF special handing  BEN_ELIG_PER_ELCTBL_CHC ' , 99 ) ;
    --
  end if ;


  l_proc_body_tbl(l_proc_index) :=  l_cursor  ;
  l_proc_index := l_proc_index + 1;

  -- insert  into table  dml statement
  l_cursor  := indent(l_indent) || ' -- Inserting the values into  source table ' ||  indent(l_indent) ;
  l_indent  :=  8 ;

  l_locals := 'l_text := '||''''||p_table_info.table_name||''''||'||p_delimiter||';
  for l_cols_map in c_cols_map(p_table_info.table_id) Loop
     l_locals  :=  l_locals || l_cols_map.COLUMN_NAME || '||p_delimiter||';
  end Loop ;

  l_locals  :=  rtrim( l_locals , '||');

  l_indent :=  6 ;

  l_proc_body_tbl(l_proc_index) :=  l_cursor||indent(l_indent)||indent(l_indent)
                                    ||l_locals||';'||indent(l_indent)||'utl_file.put_line(ben_dm_utility.g_out_file_handle,l_text);'||indent(l_indent) || indent(l_indent-2)
                                    ||  'End Loop ;  -- for geting record informations ' ||    indent(l_indent-2) ;

  l_proc_index := l_proc_index + 1;

  l_proc_body_tbl(l_proc_index) :=   indent( l_indent)|| 'hr_utility.set_location(''Leaving : '' || l_proc,5) ; ' ||
                                     indent(l_indent) || ' ben_dm_utility.message(''ROUT'','' Exit  '' ||l_proc,5) ; ' ;
  l_proc_index := l_proc_index + 1;

  add_to_package_body( l_proc_body_tbl );

  ben_dm_utility.message('ROUT','exit:'|| l_proc , 25);
  hr_utility.set_location('Leaving '|| l_proc , 5 ) ;
exception
  when others then
     ben_dm_utility.error(SQLCODE,l_proc , '(none)','R');
     raise;
end generate_insert_dml;

-- ------------------------- main  ------------------------
-- ------------------------------------------------------------------------
procedure main
(
 --p_business_group_id      in   number ,
 p_table_alias            in   varchar2,
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
  l_tbl_rec   ben_dm_gen_download.t_ben_dm_table  ;




  l_proc                   varchar2(75) ;
begin

  l_proc               := g_package||'main' ;
  hr_utility.set_location('Entering:'||l_proc, 5);
  ben_dm_utility.message('ROUT','entry:'||l_proc , 5);



  -- open the table cursor and get the table informatons
  open c_tbl  ;
  fetch c_tbl into l_tbl_rec ;
  if c_tbl%NotFound then
     close c_tbl  ;
     --raise ;
  end if ;
  close c_tbl  ;


  l_package_name       := 'ben_dmu' ||  lower(l_tbl_rec.short_name ) ;

  ben_dm_utility.message('PARA','(Table Name - '||l_tbl_rec.table_name|| ')', 10);

  -- inialize the global package body pl/sql table by deleting all elements.
  init_package_body;


  -- Get the version of the generator to be appended to the TUPS package
  -- generated for a table. This will help in finding out which version
  -- of  Generator is used to generate the TUPS package.

  ben_dm_data_util.get_generator_version(p_generator_version  => l_generator_version,
                                       p_format_output      => 'Y');

  -- Get the package version of this TDS package body.
  hr_dm_library.get_package_version ( p_package_name     => 'BEN_DM_GEN_UPLOAD',
                                      p_package_version  =>  l_package_version,
                                      p_version_type     => 'FULL');




  -- Start the package header and body.
  begin
    --
    -- Set up initial parts of the package header and body.
    --
    l_header_comment :=  l_package_version || indent ||  '/*' || indent ||
    ' * Generated by ben_dm_gun_upload at: '  ||
    to_char( sysdate, 'YYYY/MM/DD HH24:MM:SS' ) || indent ||
    ' * Generated Data Migrator TUPS for : ' ||  l_tbl_rec.table_name|| '.' ||
     indent ||
    ' * Generator Version Used to generate this TUPS is : ' || indent ||
    l_generator_version ||  indent ||
    ' */' || indent || '--' || indent;

    l_header :=
    'create or replace package ' || l_package_name || ' as' || indent ||
    l_header_comment || indent;

    -- add in call to ben_dm_utility.set_globals to set the global variables
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
              'g_package  varchar2(50) := ''' || l_package_name || '.'';' ||
               indent;

   -- add the body of this procedure to the package.
   add_to_package_body( l_proc_body_tbl );



    -- if the table has a columns which have a foreign key to AOL table then
    -- generate the procedures so as to create the procedures to get the
    -- corresponding developer's key for those columns.
    generate_upload(p_table_info             =>  l_tbl_rec,
                    p_header                 => l_header,
                    p_body                   => l_body
                    );



    -- Generate the procedures and functions.
    --

    -- generate chk_row_exists procedure to download data into batch_lines.


    l_body := l_body || indent || '--' || indent;
    generate_insert_dml (p_table_info => l_tbl_rec  );

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

  hr_utility.set_location( 'calling  run_sql for header ' , 99 ) ;

  hr_dm_library.run_sql( l_header );

  g_package_index := g_package_index+1;

  g_package_body(g_package_index ) := indent(2) || 'Exception  ' || indent(4) ||
                                      'When others then ' ||indent(6) ||
                                     ' ben_dm_utility.message(''INFO'','' Error   '' ||substr(sqlerrm,1,100) ,5) ; '||
                                      indent(6)|| ' Raise ; ' || indent(2)  ||
                                      'End  upload  ;' || indent   || 'end ' ||
                                      l_package_name || ';';

  hr_utility.set_location( 'calling  run_sql for body ' , 99 ) ;
  hr_dm_library.run_sql( g_package_body,
                         g_package_index);

  -- check the status of the package
  begin
    hr_dm_library.check_compile (p_object_name => l_package_name,
                                 p_object_type => 'PACKAGE BODY' );
  exception
    when others then

      hr_utility.set_location('Error :'||l_tbl_rec.table_name, 10);
      ben_dm_utility.error(SQLCODE,'Error in compiling TUPS for ' ||
                         l_tbl_rec.table_name ,'(none)','R');
      raise;
  end;

  hr_utility.set_location( 'Uplaod complteed '|| l_tbl_rec.table_name  , 99 ) ;
  -- update the generated  version number
  -- ben_dm_data_util.update_gen_version (p_table_id   => l_tbl_rec.table_id
  --                                     ,p_version    => l_generator_version
  --                                    ) ;
  --

  ben_dm_utility.message('ROUT','exit:'|| l_proc , 25);
  hr_utility.set_location('Leaving:'||l_proc, 10);

exception
  when others then
     ben_dm_utility.error(SQLCODE,l_proc, '(none)','R');
     raise;
end main ;

end BEN_DM_GEN_UPLOAD;

/
