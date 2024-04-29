--------------------------------------------------------
--  DDL for Package Body HR_DM_IMP_BG_WHERE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DM_IMP_BG_WHERE" as
/* $Header: perdmwer.pkb 120.2 2006/03/23 10:29:42 mmudigon noship $ */


  --
  -- PL/SQL record to store the hierarchy information. It stores the join
  -- condition to join immediate parent table.
  --


  type t_hierarchy_rec is record
  (  table_name               varchar2(30),
     parent_table_name        varchar2(30),
     join_condition           varchar2(1000),
     logical_delete           varchar2(1),
     parent_table_alias       varchar2(30)
  );

  type t_hierarchy_tbl is table of t_hierarchy_rec index by binary_integer;

  type t_where_clause_tbl is table of varchar2(6000) index by binary_integer;

  g_hierarchy_info_tbl   t_hierarchy_tbl;

  -- this table will store the where clause for each chain in the hierarchy.

  g_where_clause_tbl     t_where_clause_tbl;
  g_where_clause_index   number := 0;



--  c_newline               constant varchar(1) default '
--';

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
     hr_dm_utility.error(SQLCODE,'hr_dm_imp_bg_where.indent',
                         '(p_indent_spaces - ' || p_indent_spaces ||
                         ')(p_newline - ' || p_newline || ')',
                         'R');
end indent;

  ----------------------------------------------------------------------------
  -- populate the PL/SQL table with the hierarchy information for deriving the
  -- business group id.
  -----------------------------------------------------------------------------
  procedure populate_table
  ( p_table_info       in     hr_dm_gen_main.t_table_info ) is

    --
    -- This cursor will get the information of all the parent tables to be
    -- used in deriving the business group id.
    --
    cursor csr_tab_rel is
          select distinct level,
                 table_id,
                 lower(column_name) column_name,
                 parent_table_id,
                 lower(parent_column_name) parent_column_name,
                 'N' logical_delete
          from   ( select table_id,
                 column_name,
                 parent_table_id,
                 parent_column_name,
                 'N' logical_delete
                 from hr_dm_hierarchies
                 where hierarchy_type = 'PC')
          start with table_id = p_table_info.table_id
          connect by prior parent_table_id = table_id
          order by level desc;

  l_child_table_info       hr_dm_gen_main.t_table_info;
  l_parent_table_info      hr_dm_gen_main.t_table_info;

  l_index     number := 1;
  begin
     hr_dm_utility.message('ROUT','entry:hr_dm_imp_bg_where.populate_table', 5);
     for csr_tab_rel_rec in csr_tab_rel loop
       -- get the child_table details such as alias, name etc.
       hr_dm_library.get_table_info (csr_tab_rel_rec.table_id,
                                     l_child_table_info);

       -- get the child_table details such as alias, name etc.
       hr_dm_library.get_table_info (csr_tab_rel_rec.parent_table_id,
                                      l_parent_table_info);

       -- child table name
       g_hierarchy_info_tbl(l_index).table_name   :=
                                           l_child_table_info.table_name;

       -- parent table name
       g_hierarchy_info_tbl(l_index).parent_table_name :=
                                         l_parent_table_info.table_name;

       -- join condition with immediate parent
       g_hierarchy_info_tbl(l_index).join_condition    :=
       l_child_table_info.alias || '.' || csr_tab_rel_rec.column_name  ||
       ' = ' || l_parent_table_info.alias || '.' ||
       csr_tab_rel_rec.parent_column_name ;

       -- logical delete is for internal use only.
       g_hierarchy_info_tbl(l_index).logical_delete    :=  'N';

       g_hierarchy_info_tbl(l_index).parent_table_alias :=
                                         l_parent_table_info.alias;
       l_index := l_index +1;
     end loop;
    hr_dm_utility.message('ROUT','exit:hr_dm_imp_bg_where.populate_table', 25);


  exception
   when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_imp_bg_where.populate_table',
                       '(none)','R');
     raise;
  end populate_table;
  ----------------------initialize_tables-------------------------
  --
  -- Initialize the PL/SQL tables namely hierarchy_info and
  -- where clause tables
  ----------------------------------------------------------------
  procedure initialize_tables is
    l_index      number := g_hierarchy_info_tbl.last;
  begin

    hr_dm_utility.message('ROUT','entry:hr_dm_imp_bg_where.initialize_tables', 5);
    -- delete all the elements in hierarchy info table.
    while l_index is not null loop
      g_hierarchy_info_tbl.delete(l_index);
      l_index := g_hierarchy_info_tbl.prior(l_index);
    end loop;

    -- delete all the elements in where clause table.
    l_index := g_where_clause_tbl.last;
    while l_index is not null loop
      g_where_clause_tbl.delete(l_index);
      l_index :=g_where_clause_tbl.prior(l_index);
    end loop;
    hr_dm_utility.message('ROUT','exit:hr_dm_imp_bg_where.initialize_tables', 25);


  exception
    when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_imp_bg_where.initialize_tables',
                       '(none)','R');
     raise;
  end  initialize_tables;

  --------------------- clear_logical_deletes---------------------
  -- It sets the logical_delete field in the hierarchy_info table
  -- to 'N' where it is set to 'Y'.
  ----------------------------------------------------------------
  procedure clear_logical_deletes is
    l_index      number := g_hierarchy_info_tbl.last;
  begin
    hr_dm_utility.message('ROUT','entry:hr_dm_imp_bg_where.clear_logical_deletes', 5);
    while l_index is not null loop
      if g_hierarchy_info_tbl(l_index).logical_delete = 'Y' then
         g_hierarchy_info_tbl(l_index).logical_delete := 'N';
      end if;
      l_index := g_hierarchy_info_tbl.prior(l_index);
    end loop;
   hr_dm_utility.message('ROUT','exit:hr_dm_imp_bg_where.clear_logical_deletes', 25);


  exception
    when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_imp_bg_where.clear_logical_deletes',
                       '(none)','R');
     raise;
  end  clear_logical_deletes;


  -----------------search_table_for_par_chld-----------------------
  -- Search table row where parent_table_name or table_name matches
  -- the table name parameter value depending upon search_type.
  -- It is used only if the parent and child has more than one column
  -- join. This finds out the other columns in the join condition.
  --
  -- Input Parameter :
  --    p_parent_search_value - Parent table name.
  --    p_child_search_value  - Child table name.
  --    p_original_index      - Index of the row with the above values
  --                            in g_hierarchy_info_tbl list.
  --
  -- Output Parameter :
  --    p_search_index        - Index of the row with the for the same
  --                            combination of parent and child table
  --                            in g_hierarchy_info_tbl list. More than
  --                            one row exists in the list if parent an
  --                            child table has join condition based on
  --                            more than one column.
  --                            If no row is found then it cintails NULL
  --                            value.
  ----------------------------------------------------------------
  procedure search_table_for_par_chld
  ( p_parent_search_value    in      varchar2,
    p_child_search_value     in      varchar2,
    p_original_index         in      number,
    p_search_index           in out nocopy  number) is

  l_index               number := g_hierarchy_info_tbl.first;
  l_original_row_index  number := p_original_index ;
  begin
    hr_dm_utility.message('ROUT','entry:hr_dm_imp_bg_where.search_table_for_par_chld ', 5);
    hr_dm_utility.message('PARA','(p_parent_search_value - ' || p_parent_search_value ||
                         ')(p_child_search_value - ' || p_child_search_value || ')' ||
                          ')(p_original_index - ' || p_original_index ||
                         ')', 10);
    while l_index is not null loop
      if g_hierarchy_info_tbl(l_index).parent_table_name = p_parent_search_value
      and g_hierarchy_info_tbl(l_index).table_name       = p_child_search_value
      and g_hierarchy_info_tbl(l_index).logical_delete   = 'N'
      and l_index <> l_original_row_index then
         p_search_index := l_index;
         exit;
      end if;
      l_index := g_hierarchy_info_tbl.next(l_index);
      p_search_index := l_index;
    end loop;
    hr_dm_utility.message('PARA','(p_search_index - ' || p_search_index ||
                       ')', 20);

    hr_dm_utility.message('ROUT','exit:hr_dm_imp_bg_where.search_table_for_par_chld', 25);


  exception
    when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_imp_bg_where.search_table_for_par_chld',
                       '(p_parent_search_value - ' || p_parent_search_value ||
                         ')(p_child_search_value - ' || p_child_search_value || ')' ||
                          ')(p_original_index - ' || p_original_index ||
                         ')','R');
     raise;
  end search_table_for_par_chld;

  ----------------------search_table -------------------------
  -- Get the index of table row where parent_table_name or table_name
  -- matches the given table name parameter value depending upon
  -- search_type.
  -- Input Parameters :
  --    p_search_type -  Type of match. Can have following values :
  --                    'P' get the row where parent_table_name
  --                        matches the table name parameter value.
  --          Other Values  get the row where child table_name
  --                        matches the table name parameter value.
  -- Output Parameters :
  --   p_search_index - Returns the index of the row matched in
  --                    g_hierarchy_info_tbl list.
  --
  ----------------------------------------------------------------
  procedure search_table ( p_search_type    in    varchar2,
                           p_table_name     in    varchar2,
                           p_search_index   out nocopy   number) is
  l_index    number := g_hierarchy_info_tbl.first;
  begin

    hr_dm_utility.message('ROUT','entry:hr_dm_imp_bg_where.search_table', 5);
    hr_dm_utility.message('PARA','(p_search_type - ' || p_search_type ||
                       ')(p_table_name    - ' || p_table_name    || ')' ||
                       ')', 10);

    while l_index is not null loop
      -- if serach type is for parent table.
      if p_search_type = 'P' then
        if g_hierarchy_info_tbl(l_index).parent_table_name = p_table_name
        then
           p_search_index := l_index;
           exit;
        end if;
      else
        if g_hierarchy_info_tbl(l_index).table_name = p_table_name then
           p_search_index := l_index;
           exit;
        end if;
      end if;
      l_index := g_hierarchy_info_tbl.next(l_index);
      p_search_index := l_index;
    end loop;
    hr_dm_utility.message('PARA','(p_search_index - ' || p_search_index ||
                       ')', 20);

    hr_dm_utility.message('ROUT','exit:hr_dm_imp_bg_where.search_table', 25);


  exception
    when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_imp_bg_where.search_table',
                       '(p_search_type - ' || p_search_type ||
                       ')(p_table_name    - ' || p_table_name    || ')' ||
                       ')','R');
     raise;
  end search_table;


  ---------------------delete_table_rows---------------------------
  -- Delete table row where the given child table exists as a parent
  -- table in any row but does not exists as a child table in any other
  -- row.
  -- Above is applied to all the rows processed in a current where clause
  -- chain. Seed row will change.
  -- Processing Logic :
  --    - get the Child table for the given index : 'C'
  --    - First a check is made whether this table exists as a
  --      child table in any other row.
  --      If it exists then skip the processing.
  --      If it does not exists then
  --         check if it exists as a Parent table in any other row
  --         if yes then
  --           store the index number of this row.
  --           get the child table for this index.
  --           delete the row.
  --         else
  --           exit.
  --         end if
  --      end if.
  --      repeat above process in loop.
  -- Example :
  --  A ---> B ---> C ---> D
  --  Row Number     Parent Table   Child Table    Join Condition
  --  1                 D              C           D.colf = C.colf
  --  2                 C              B           C.cole = B.cole
  --  3                 B              A           B.colc = A.colc
  --
  --  index of row number 1 is passed.
  --     Child table : 'C'.
  --     Found row 2 where it exist as parent table. Table 'C' does
  --     not have any child table.
  --     store the index of row 2.
  --     get the child table of row 2 i.e 'B'
  --     delete row 2.
  --
  --     Second iteration of the loop
  --     Child table : 'B'.  from index of row 2
  --     Found row 3 where it exist as parent table. Table 'B' does
  --     not have any child table.
  --     store the index of row 3.
  --     get the child table of row 3 i.e 'A'
  --     delete row 3.
  --
  --     No parent table exists for table 'A'.
  --     Stop processing.
  --
  -- Input Parameters :
  --    p_search_type - 'P' Delete the row where parent_table_name
  --                        matches the table name parameter value.
  --          Other Values  Delete the row where child table_name
  --                        matches the table name parameter value.
  --
  -----------------------------------------------------------------
  procedure delete_table_rows
  ( p_child_table      in     varchar2) is

--    l_index               number := p_index;
    l_parent_table_index  number;
    l_child_table_index   number;
    l_child_table         varchar2(30);
  begin
    hr_dm_utility.message('ROUT','entry:hr_dm_imp_bg_where.delete_table_rows', 5);
    hr_dm_utility.message('PARA','( p_child_table - ' ||  p_child_table ||
                         ')', 10);
     -- get child table
     l_child_table :=  p_child_table;

    loop

      l_child_table_index := null;
      l_parent_table_index := null;

      -- check whether this table exists as a child table in any other row.

      search_table('C',
                    l_child_table,
                    l_child_table_index);

      -- if child table also exists as a child table in another row then skip
      -- processing.

      if l_child_table_index is not null then
         exit;
      else
        -- check whether this table exists as a parent table in any other row.

        search_table('P',
                      l_child_table,
                      l_parent_table_index);

        if l_parent_table_index  is null then
           exit;
        else
           --
           -- get the child table for this parent table row for further
           -- processing.
           --
           l_child_table :=
                    g_hierarchy_info_tbl(l_parent_table_index).table_name;

           -- delete this row
           g_hierarchy_info_tbl.delete(l_parent_table_index);
        end if; -- if l_parent_table_index  is null then
      end if;  -- if l_child_table_index is not null then
    end loop;

    hr_dm_utility.message('ROUT','exit:hr_dm_imp_bg_where.delete_table_rows', 25);

  exception
    when others then
      hr_dm_utility.error(SQLCODE,'hr_dm_imp_bg_where.delete_table_rows',
                       '( p_child_table - ' ||  p_child_table ||
                       ')','R');
     raise;
  end delete_table_rows;

  -----------------prepare_where_clause_for_chain-------------------------
  -- It prepares where clause for a chain by joining parent and child
  -- table with operand 'AND'.
  -- The starting parent table and child table of the chain are passed as
  -- a parameter. The remaining part of the chain is derived by finding out
  -- the parent table for the given child table and so on until child table
  -- is reached which does not have any child or is not parent to any table.
  -- Input Parameter :
  --   p_cursor_type  -  The cursor for which where clause needs to be formed.
  --                     It can have following values :
  --                     'DOWNLOAD' - where clause for download procedure
  --                     'DELETE_SOURCE' - where clause for delete source
  --                                       procedure
  --                     'CALCULATE_RANGES' - where clause for calculate_ranges
  --                                          procedure
  --                     'VIEW' - where clause for view creation
  --
  --   p_query_type   - It defines whether the where clause to be build up is
  --                    for main query or sub query (used for date track table
  --                    additive migration).
  --                    It can have following values :
  --                    'MAIN_QUERY' - For Non date track download cursor and
  --                                   Date track full migration cursor.
  --                    'SUB_QUERY'  - Download cursor sub query where clause
  --                                   Additive migration of date track table.
  --   p_table_index   - Index of the g_hierarchy_info_tbl list. Index is used
  --                     get the starting parent and table name.
  ---------------------------------------------------------------------
  procedure prepare_where_clause_for_chain
  (p_table_info     in    hr_dm_gen_main.t_table_info,
   p_table_index    in    number,
   p_cursor_type    in    varchar2,
   p_query_type     in    varchar2
  ) is

    l_table_index           number := p_table_index;
    l_pc_table_index        number := p_table_index;
    l_parent_table          varchar2(30);
    l_child_table           varchar2(30);
    l_orig_parent_table     varchar2(30);
    l_orig_child_table      varchar2(30);
    l_operand               varchar2(30) := '     ';
    l_indent                number;
    l_who_info_alias        hr_dm_tables.table_alias%type;
  begin
    hr_dm_utility.message('ROUT','entry:hr_dm_imp_bg_where.prepare_where_clause_for_chain ', 5);
    hr_dm_utility.message('PARA','(p_cursor_type - ' || p_cursor_type ||
                         ')(p_query_type - ' || p_query_type || ')' ||
                         ')(p_table_index - ' || p_table_index || ')' ||
                          ')', 10);
    --
    -- if who column info is missing from the table then use the alias of the table
    -- whose who info should be used for additive migration, otherwise, use the
    -- table alias.

    if p_table_info.missing_who_info = 'Y' then
       l_who_info_alias := p_table_info.who_link_alias;
    else
       l_who_info_alias := p_table_info.alias;
    end if;

    if p_query_type = 'MAIN_QUERY' then
       l_indent := 2;
    else
       l_indent := 17;
    end if;
    -- stores the parent and child table name into local variables.
    l_parent_table       :=
    g_hierarchy_info_tbl(l_table_index).parent_table_name;

    l_child_table        :=   g_hierarchy_info_tbl(l_table_index).table_name;

    l_orig_parent_table  :=
    g_hierarchy_info_tbl(l_table_index).parent_table_name;

    l_orig_child_table   := g_hierarchy_info_tbl(l_table_index).table_name;

      -- if it is a sub query where clause then add the join condition for id.
    if p_query_type = 'SUB_QUERY' then
       g_where_clause_tbl(g_where_clause_index) :=  lpad(' ',l_indent + 5) ||
       p_table_info.alias || '1.'||
       p_table_info.surrogate_pk_column_name || ' = '|| p_table_info.alias
       || '.'|| p_table_info.surrogate_pk_column_name ;
       l_operand := ' and ';
    end if;

    --
    -- This loop is to traverse through the hierarchy info table and build up
    -- chain using parent table and child table passed as a starting point.
    --
    loop

      -- g_where_clause_tbl(g_where_clause_index) is null for the first time
      -- for the MAIN_QUERY so we do not want to insert the blank line but for
      -- SUB_QUERY the where clause is already populated and hence next line
      -- should start at new line.

      if g_where_clause_tbl(g_where_clause_index) is not null then
        g_where_clause_tbl(g_where_clause_index) :=
        g_where_clause_tbl(g_where_clause_index) ||indent(l_indent) ||
        l_operand || g_hierarchy_info_tbl(l_table_index).join_condition ;
      else
        g_where_clause_tbl(g_where_clause_index) :=
        g_where_clause_tbl(g_where_clause_index) ||
        l_operand || g_hierarchy_info_tbl(l_table_index).join_condition ;
      end if;

      l_pc_table_index  := l_table_index;

      --
      -- This loop builds up the where clause for the parent and child table
      -- if they are joined by more than one column. For a single column
      -- join it does not do anything.
      loop

        l_pc_table_index  := null;
        --
        -- find out if there is another row exists for the given parent and
        -- child table combination. This will be the case when the parent
        -- and child table will have join condition based on more than one
        -- column.
        -- l_pc_index will be null for a single column join and will return
        -- the table index of the row containing the other column joins for
        -- parent and child table join.
        --

        search_table_for_par_chld ( l_parent_table,
                                    l_child_table,
                                    l_table_index,
                                    l_pc_table_index );


        if l_pc_table_index is not null then

           -- add the conditionof the multiple columns to this chain of where
           -- clause.
           --

           g_where_clause_tbl(g_where_clause_index) :=
              g_where_clause_tbl(g_where_clause_index) || indent(l_indent) ||
             ' and ' || g_hierarchy_info_tbl(l_pc_table_index).join_condition;

           --
           -- if the parent table and child table are same as starting point of
           -- chain i.e parameters values passed then delete the row as it is
           -- not required any longer. Otherwise, just set the logical delete
           -- flag to 'Y' so as to ignore this row in the further processing of
           -- this chain.
           --

           if g_hierarchy_info_tbl(l_pc_table_index).parent_table_name =
                                                        l_orig_parent_table and
              g_hierarchy_info_tbl(l_pc_table_index).table_name        =
                                                       l_orig_child_table  then
                g_hierarchy_info_tbl.delete(l_pc_table_index);
           else
             -- do logical delete
             g_hierarchy_info_tbl(l_pc_table_index).logical_delete := 'Y';
           end if;
        else
           exit;
        end if;
      end loop;


      -- find out another table in the chain by looking for the row where the
      -- given child table appears as aparent table for another table.
      -- l_table_index is returned as null if this child table is the last one
      -- for the given chain.

      search_table ('P',
                     l_child_table,
                     l_table_index);

      if l_table_index is null then
         exit;
      else
        l_parent_table  := g_hierarchy_info_tbl(l_table_index).parent_table_name;
        l_child_table   := g_hierarchy_info_tbl(l_table_index).table_name;
        l_operand       := ' and ';
      end if;

    end loop;

    -- add id between start_id and end_id  clause
--    if p_cursor_type = 'DOWNLOAD' and p_query_type = 'MAIN_QUERY' then
    if p_cursor_type in ('DOWNLOAD', 'DELETE_SOURCE') and
       p_query_type = 'MAIN_QUERY' then
      if p_table_info.surrogate_primary_key = 'Y' then
        g_where_clause_tbl(g_where_clause_index) :=
        g_where_clause_tbl(g_where_clause_index) || indent(l_indent) ||
        ' and ' || p_table_info.alias || '.' ||
        p_table_info.surrogate_pk_column_name || ' between p_start_id ' ||
        'and p_end_id' ;
      end if;
    end if;

    -- add last update on clause
    if p_cursor_type in ('DOWNLOAD','CALCULATE_RANGES')  and
       p_query_type = 'MAIN_QUERY'  and
       p_table_info.datetrack = 'N' then

      g_where_clause_tbl(g_where_clause_index) :=
      g_where_clause_tbl(g_where_clause_index) ||  indent(l_indent) ||
      ' and ' || l_who_info_alias
      || '.last_update_date >= nvl(p_last_migration_date,'||  l_who_info_alias
      || '.last_update_date)';
    end if;

    -- add business group id clause
    if p_cursor_type = 'VIEW' then
      g_where_clause_tbl(g_where_clause_index) :=
               g_where_clause_tbl(g_where_clause_index) ||  indent(l_indent) ||
              ' and ' ||
               g_hierarchy_info_tbl(p_table_index).parent_table_alias  ||
              '.business_group_id is null' ;
    else
      g_where_clause_tbl(g_where_clause_index) :=
               g_where_clause_tbl(g_where_clause_index) ||  indent(l_indent) ||
              ' and ' ||
               g_hierarchy_info_tbl(p_table_index).parent_table_alias  ||
              '.business_group_id = p_business_group_id' ;
    end if;


 hr_dm_utility.message('ROUT','exit:hr_dm_imp_bg_where.prepare_where_clause_for_chain',
                       25);


exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_imp_bg_where. prepare_where_clause_for_chain',
                       '(p_cursor_type - ' || p_cursor_type ||
                       ')(p_query_type - ' || p_query_type || ')' ||
                       ')(p_table_index - ' || p_table_index  || ')' ||
                       ')','R');
     raise;
  end prepare_where_clause_for_chain;

  ----------------------------- prepare_where_clause --------------------------
  -- prepare the where clause involves the following step
  --   - read the pl/sql table rows one by one which contains the hierarchy info
  --      For each row develop the where clause for the chain
  --      delete the entries from table which no longer required.
  --   - prepare the where clause by joining the where clause elements of chains
  --     with 'OR' operand.
  -- Input Parameter :
  --   p_cursor_type  -  The cursor for which where clause needs to be formed.
  --                     It can have following values :
  --                     'DOWNLOAD' - where clause for download procedure
  --                     'CALCULATE_RANGES' - where clause for calculate_ranges
  --                                          procedure
  --
  --   p_query_type   - It defines whether the where clause to be build up is
  --                    for main query or sub query (used for date track table
  --                    additive migration).
  --                    It can have following values :
  --                    'MAIN_QUERY' - For Non date track download cursor and
  --                                   Date track full migration cursor.
  --                    'SUB_QUERY'  - Download cursor sub query where clause
  --                                   Additive migration of date track table.
  ------------------------------------------------------------------------------
  procedure prepare_where_clause
  (p_table_info    in     hr_dm_gen_main.t_table_info,
   p_cursor_type   in     varchar2,
   p_query_type    in     varchar2,
   p_where_clause  out nocopy    varchar2
  ) is

    l_table_index        number := g_hierarchy_info_tbl.first;
    l_child_table        varchar2(30);
    l_pc_table_index     number;
    l_index              number;
    l_indent             number;
    l_where_clause       varchar2(32767);
    l_sub_from_clause    varchar2(32767);
    l_sub_where_clause   varchar2(32767);
  begin
  hr_dm_utility.message('ROUT','entry:hr_dm_imp_bg_where.prepare_where_clause', 5);
  hr_dm_utility.message('PARA','(p_cursor_type - ' || p_cursor_type ||
                         ')(p_query_type - ' || p_query_type || ')' ||
                         ')', 10);

    g_where_clause_index := 1;
    while l_table_index is not null loop

      l_child_table := g_hierarchy_info_tbl(l_table_index).table_name;
      g_where_clause_tbl(g_where_clause_index) := null;

      -- call procedure to prepare the where clause of the chain.
      prepare_where_clause_for_chain (p_table_info,
                                      l_table_index,
                                      p_cursor_type,
                                      p_query_type);

      -- clear all the records which have been marked deleted, by setting
      -- the logical delete field to 'N'.
      clear_logical_deletes;

      -- delete the row which is read
      g_hierarchy_info_tbl.delete(l_table_index);

      -- if the child table does not exist as child column in any other row then
      -- delete all the rows where it exists as parent table.
      -- repeat the process for the whole where clause chain.
      delete_table_rows(l_child_table);


      g_where_clause_index := g_where_clause_index + 1;
       --display_table;
      l_table_index := g_hierarchy_info_tbl.next(l_table_index);

    end loop;

     -- prepare the final where clause by joining all the chains i.e all the
     -- elements of where_clause table.

     if p_query_type = 'MAIN_QUERY' then
       l_indent := 2;
       l_where_clause := '  where  ' ;

       l_table_index :=  g_where_clause_tbl.first;

       -- join the each where clause chain with 'OR' clause.

       while l_table_index is not null loop
         l_where_clause := l_where_clause || indent(l_indent) || '( ' ||
         indent(l_indent) || g_where_clause_tbl(l_table_index) ||
         indent(l_indent) || ') ';
         l_table_index := g_where_clause_tbl.next(l_table_index);
         if l_table_index is not null then
           l_where_clause := l_where_clause || indent(l_indent) || 'OR';
         end if;
       end loop;

      /*
       -- add the order by clause for datetrack table
       if p_table_info.datetrack = 'Y' then
          l_where_clause := l_where_clause || indent(2) ||
                      'order by ' || p_table_info.surrogate_pk_column_name ;
       end if;
       */

       p_where_clause := l_where_clause;

     else
       l_indent := 2;
       l_where_clause := '  where ';

       -- put the search condition of id between start and end id.

       if p_table_info.surrogate_primary_key = 'Y' then
         l_where_clause := l_where_clause || p_table_info.alias || '1.' ||
         p_table_info.surrogate_pk_column_name || ' between p_start_id and ' ||
         'p_end_id';
       end if;

       l_where_clause := l_where_clause || indent(l_indent) ||  'and   ';


       -- prepare the sub query.
       l_where_clause := l_where_clause || 'exists ( select 1';

       l_indent := 17;

       -- get the from clause for sub query
       hr_dm_gen_tds.get_cursor_from_clause (p_table_info  => p_table_info,
                                           p_from_clause => l_sub_from_clause,
                                           p_lpad_spaces => l_indent);

       -- get the where clause for sub query

       l_indent := 17;
       l_sub_where_clause := lpad(' ',l_indent) || 'where  ';

       l_table_index :=  g_where_clause_tbl.first;

       -- join the each where clause chain with 'OR' clause.
       while l_table_index is not null loop
         l_sub_where_clause := l_sub_where_clause || indent(l_indent) || '( ' ||
          indent || g_where_clause_tbl(l_table_index) || indent(l_indent) || ') ';
         l_table_index := g_where_clause_tbl.next(l_table_index);
         if l_table_index is not null then
           l_sub_where_clause := l_sub_where_clause ||indent(l_indent) ||'OR';
         end if;
       end loop;

       p_where_clause := l_where_clause || indent ||
                         l_sub_from_clause || indent ||
                         l_sub_where_clause || indent(15)  || ')' ;

       if p_table_info.surrogate_primary_key = 'Y' and
          p_table_info.datetrack = 'Y' and
          p_cursor_type  = 'DOWNLOAD' then
          p_where_clause := p_where_clause || indent(2) || 'order by ' ||
                            p_table_info.alias || '1.' ||p_table_info.surrogate_pk_column_name  || ';';
       else
          p_where_clause := p_where_clause || ';';
       end if;

    end if;
   hr_dm_utility.message('ROUT','exit:hr_dm_imp_bg_where.prepare_where_clause', 25);

exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_imp_bg_where.prepare_where_clause',
                       '(p_cursor_type - ' || p_cursor_type ||
                         ')(p_query_type - ' || p_query_type || ')' ||
                         ')','R');
     raise;
  end prepare_where_clause;

  -------------------------------------------------------------------------
  -- Main Procedure
  -- This function creates the where clause for the table which do not have
  -- business group id but the parent tables relationship is stored in
  -- hr_dm_hierarchies table is used to derive the 'where' clause.
  -- Input Parameter :
  --   p_cursor_type  -  The cursor for which where clause needs to be formed.
  --                     It can have following values :
  --                     'DOWNLOAD' - where clause for download procedure
  --                     'CALCULATE_RANGES' - where clause for calculate_ranges
  --                                          procedure
  --                     'VIEW' - where clause for view creation
  --
  --   p_query_type   - It defines whether the where clause to be build up is
  --                    for main query or sub query (used for date track table
  --                    additive migration).
  --                    It can have following values :
  --                    'MAIN_QUERY' - For Non date track download cursor and
  --                                   Date track full migration cursor.
  --                    'SUB_QUERY'  - Download cursor sub query where clause
  --                                   Additive migration of date track table.
  --
  -- Output Parameters :
  --   p_where_clause - Formatted where clause.
  --
  -------------------------------------------------------------------------
  procedure main
  (p_table_info    in     hr_dm_gen_main.t_table_info,
   p_cursor_type   in     varchar2,
   p_query_type    in     varchar2,
   p_where_clause  out nocopy    varchar2) is

   l_where_clause varchar2(32767);
begin

  hr_dm_utility.message('ROUT','entry:hr_dm_imp_bg_where.main', 5);
  hr_dm_utility.message('PARA','(p_cursor_type - ' || p_cursor_type ||
                         ')(p_query_type - ' || p_query_type || ')' ||
                         ')', 10);
  initialize_tables;
  populate_table (p_table_info);
  prepare_where_clause (p_table_info,
                        p_cursor_type,
                        p_query_type,
                        p_where_clause);
  l_where_clause := p_where_clause;
  hr_dm_utility.message('PARA','( p_where_clause - ' ||  p_where_clause ||
                             ')', 20);
  hr_dm_utility.message('ROUT','exit:hr_dm_imp_bg_where.get_generator_version', 25);

exception
  when others then
     hr_dm_utility.error(SQLCODE,'hr_dm_imp_bg_where.main',
                       '(p_cursor_type - ' || p_cursor_type ||
                       ')(p_query_type - ' || p_query_type || ')' ||
                       ')','R');
     raise;
end main;
end hr_dm_imp_bg_where;

/
