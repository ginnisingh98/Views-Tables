--------------------------------------------------------
--  DDL for Package Body HR_SUM_STORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SUM_STORE" as
/* $Header: hrsumsto.pkb 115.8 2003/05/22 10:36:03 jheer noship $ */
--
procedure store_data (p_business_group_id in number,
                      p_item_name in varchar2,
                      p_itu_name in varchar2,
                      p_item_type_usage_id in number,
                      p_count_clause1 in varchar2,
                      p_count_clause2 in varchar2,
                      p_stmt in varchar2,
                      p_debug in varchar2,
                      p_key_col_clause in varchar2,
                      p_error out nocopy number ) is

l_key_value hr_summary_key_value.name%type;
l_item_value  number;
l_item_value_char varchar2(240);
l_item_value2 number;
z number;
j number;
l_key_value_id number;
l_error_mesg varchar2(100);
l_error boolean;
l_item_value_id number;
l_object_version_number number;
source_cursor integer;
ignore integer;
l_new_stmt long;
l_count_clause_columns varchar2(4000);
l_columns_to_append long := ' ';
l_columns_required number :=0;
l_full_name_avail varchar2(1);
l_start_index number;

l_concat_debug_string varchar2(4000);
l_pos1 number;
l_pos2 number;
TYPE ColNameRecType IS RECORD
  (col_name long);
TYPE ColNameTabType IS TABLE of ColNameRecType INDEX BY BINARY_INTEGER;

ColNameTab  ColNameTabType;

--

begin
   --
   hr_utility.set_location('Entering: hr_sum_store.store_data', 10);
   --
   p_error := 0; /* Default error parameter to zero to indicate success */
   source_cursor := dbms_sql.open_cursor;
   --
   -- Define column 1 as the count column
   --

   --
   -- If p_debug = 'Y' change the statement to select just the name
   --
   hr_utility.trace ('convert statement');
   -- the following have multiple group bys' which are currently not handled by debug.
   if p_debug = 'Y' and p_item_name not in ('10_HIGHEST_REMUNERATION',
                                            '10_PC_HIGHEST_REMUNERATION',
					    '10_PC_LOWEST_REMUNERATION',
                                        --  'NEW_HIRE',
                                            'REMUNERATION_BREAKDOWN')
   then
      if p_item_name = 'NEW_HIRE' then
         l_full_name_avail := 'N';
      else
         l_full_name_avail := 'Y';
      end if;
      l_new_stmt := p_stmt;
   -- find the columns to append from the comment
      l_columns_to_append := ' ';
      l_columns_required := 0;
      if instr(l_new_stmt,'DBGCOLS',1) <> 0 then
         l_columns_to_append := ',' || substr(l_new_stmt,(instr(l_new_stmt,concat('/','*DBG'),1)+6),(
                                instr(l_new_stmt,'DBGCOLS',1) - (instr(l_new_stmt,concat('/','*DBG'),1)+6)));
         l_columns_required := to_number(nvl(substr(l_new_stmt,(instr(l_new_stmt,'DBGCOLS',1)+7),1),'0'));
         hr_utility.trace('cols required = ' ||  l_columns_required);
      end if;

      -- Determine the names of the appended debug columns so that they can be output with the value
      -- the column names follow the DBGCOLS text and are should appear in the corect order
      l_pos1 := instr(l_new_stmt,'DBGCOLS',1);
      l_pos2 := instr(l_new_stmt,' ',l_pos1); -- find the position of the space preceeding the 1st col
      hr_utility.trace('_pos1 = ' || l_pos1 || ' ' || l_pos2);
      for i in 0..(l_columns_required-1) loop
          hr_utility.trace('colname asssign');
          ColNameTab(i).col_name := substr(l_new_stmt,(l_pos2+1),instr(l_new_stmt,' ',(l_pos2+1))-(l_pos2));
          l_pos2 := instr(l_new_stmt,' ',l_pos2+1);
      end loop;

      l_new_stmt := substr(l_new_stmt,instr(l_new_stmt,'from',1),length(l_new_stmt));
      if instr(l_new_stmt,' group by',1) <> 0 then
         l_new_stmt := substr(l_new_stmt,1,instr(l_new_stmt,' group by',1));
         if l_full_name_avail = 'Y' then
            l_new_stmt := 'Select distinct p.full_name' || l_columns_to_append || nvl(p_key_col_clause,' ') ||
                           l_new_stmt;
         else
            l_new_stmt := 'Select distinct ''full_name unavail'' ' || l_columns_to_append || nvl(p_key_col_clause,' ') ||
                           l_new_stmt;
         end if;
      else
         if l_full_name_avail = 'N' then
            l_new_stmt := 'Select distinct ''full_name unavail'' ' || l_columns_to_append || l_new_stmt;
         else
            l_new_stmt := 'Select distinct p.full_name' || l_columns_to_append || l_new_stmt;
         end if;
      end if;

   else
      l_new_stmt := p_stmt;
   end if;

   if p_debug = 'Y' then
      hrsumrep.write_stmt_log(p_stmt => 'new stmt is' || l_new_stmt);
      hrsumrep.write_stmt_log('ITEM NAME = ' || p_itu_name || ' ' || p_item_name);
      hr_utility.trace('ITEM NAME = ' || p_itu_name || ' ' || p_item_name);
   end if;

   hr_utility.trace ('complete convert statement');


   <<dynamic_block>>
   begin
      l_error := false;
      l_error_mesg := fnd_message.get_string('PER','PER_74874_PARSE_ERROR')||' '||p_item_name;
      -- dbms_sql.parse(source_cursor,p_stmt,dbms_sql.v7);
      hr_utility.trace('parse stmt');
      dbms_sql.parse(source_cursor,l_new_stmt,dbms_sql.v7);
      hr_utility.trace('complete parse stmt');
      l_error_mesg := null;
      fnd_message.set_name('PER','PER_74877_DEFINE_COLUMN');
      fnd_message.set_token('NUM','1');
      l_error_mesg := fnd_message.get;
      If p_debug = 'Y' Then
         dbms_sql.define_column(source_cursor,1,l_item_value_char,240);
      Else
         dbms_sql.define_column(source_cursor,1,l_item_value);
      End If;
      l_error_mesg := null;
      --
      if p_debug <> 'Y' then
         if p_count_clause2 is not null then
            fnd_message.set_token('NUM','2');
            l_error_mesg := fnd_message.get;
            dbms_sql.define_column(source_cursor,2,l_item_value2);
            l_error_mesg := null;
            --
            -- Define subsequent columns based on the group by columns
            --
            j := 3;
         else
            j := 2;
         end if;
         --
         if hrsumrep.ktyTab.count > 0 then
           for i in hrsumrep.ktyTab.first..hrsumrep.ktyTab.last loop
               fnd_message.set_token('NUM',to_char(j));
               l_error_mesg := fnd_message.get;
               dbms_sql.define_column(source_cursor,j,l_key_value,80);
               l_error_mesg := null;
               j := j + 1;
           end loop;
         end if;

      else  -- if debug
         j := 2;
         -- if hrsumrep.ktyTab.count > 0 then
            if hrsumrep.ktyTab.count > 0 or l_columns_required > 0 then
            l_columns_required := l_columns_required + nvl(hrsumrep.ktyTab.last,0);
            hr_utility.trace('l_columns_required after adding is ' || l_columns_required);
         --for i in hrsumrep.ktyTab.first..hrsumrep.ktyTab.last loop
           for i in nvl(hrsumrep.ktyTab.first,1)..l_columns_required loop
               fnd_message.set_token('NUM',to_char(j));
               l_error_mesg := fnd_message.get;
               hr_utility.trace('define col');
               dbms_sql.define_column(source_cursor,j,l_key_value,80);
                hr_utility.trace('define col2');
               l_error_mesg := null;
               j := j + 1;
           end loop;
         end if;
      end if;
      --
      l_error_mesg := fnd_message.get_string('PER','PER_74875_EXECUTE_ERROR')||' '||p_item_name;
      ignore := dbms_sql.execute(source_cursor);
      l_error_mesg := null;
      --
      z := 0;
      loop
           if dbms_sql.fetch_rows(source_cursor) > 0 then
              fnd_message.set_name('PER','PER_74878_COLUMN_VALUE');
              fnd_message.set_token('NUM','1');
              l_error_mesg := fnd_message.get;

              if p_debug = 'Y' then
                  hr_utility.trace(' col value');
                 dbms_sql.column_value(source_cursor,1,l_item_value_char);
                 hrsumrep.write_stmt_log(p_stmt => null);
                 hrsumrep.write_stmt_log(p_stmt => '***** PERSON NAME is ' || l_item_value_char);
              else
                 dbms_sql.column_value(source_cursor,1,l_item_value);
              end if;

              l_error_mesg := null;

              if p_debug <> 'Y' then

                 if p_count_clause2 is not null then
                    fnd_message.set_token('NUM','2');
                    l_error_mesg := fnd_message.get;
                    dbms_sql.column_value(source_cursor,2,l_item_value2);
                    l_error_mesg := null;
                 end if;
                 --
                 -- Populate the Item Value Row
                 --
                 hr_summary_api.create_item_value(p_item_value_id         => l_item_value_id
                                              ,p_business_group_id     => p_business_group_id
                                              ,p_object_version_number => l_object_version_number
                                              ,p_process_run_id        => hr_summary_util.process_run_id
                                              ,p_item_type_usage_id    => p_item_type_usage_id
                                              ,p_textvalue             => null
                                              ,p_numvalue1             => l_item_value
                                              ,p_numvalue2             => l_item_value2
                                              ,p_datevalue             => null);
                 z := z + 1;
                 if p_count_clause2 is null then
                    j := 2;
                 else
                    j := 3;
                 end if;
                 if hrsumrep.ktyTab.count > 0 then
                    for i in hrsumrep.ktyTab.first..hrsumrep.ktyTab.last loop
                        fnd_message.set_token('NUM',to_char(j));
                        l_error_mesg := fnd_message.get;
                        dbms_sql.column_value(source_cursor,j,l_key_value);
                        l_error_mesg := null;
                        --
                        -- Populate the key value
                        --
                        hr_summary_api.create_key_value(p_key_value_id          => l_key_value_id
                                                    ,p_business_group_id     => p_business_group_id
                                                    ,p_object_version_number => l_object_version_number
                                                    ,p_key_type_id           => hrsumrep.ktyTab(i).key_type_id
                                                    ,p_item_value_id         => l_item_value_id
                                                    ,p_name                  => l_key_value);
                        --
                        --
                        -- If the value is OTHER then there may not be a
                        -- correpsonding zero item row (this is required in order
                        -- that each element in the multi-dimensional matrix has a
                        -- value
                        --
                        if l_key_value = hr_summary_util.OTHER
                        and not hrsumrep.ktyTab(i).key_other then
                           hr_summary_api.create_key_value(p_key_value_id          => l_key_value_id
                                                       ,p_business_group_id     => p_business_group_id
                                                       ,p_object_version_number => l_object_version_number
                                                       ,p_key_type_id           => hrsumrep.ktyTab(i).key_type_id
                                                       ,p_item_value_id         => hr_summary_util.zero_item_value_id
                                                       ,p_name                  => l_key_value);
                           hrsumrep.ktyTab(i).key_other := TRUE;
                        end if;
                        j := j + 1;
                    end loop;
                 end if;

              end if; -- p_debug end if

              If p_debug = 'Y' then
                 j :=2;
                 -- if hrsumrep.ktyTab.count > 0 then
                 hr_utility.trace('col value start');
                 if hrsumrep.ktyTab.count > 0 or l_columns_required > 0 then
                    --l_columns_required := l_columns_required + hrsumrep.ktyTab.count;
                 -- for i in hrsumrep.ktyTab.first..hrsumrep.ktyTab.last loop
                    hr_utility.trace('col value start loop');
                 -- cater for the situation where an item has no keys
                    if hrsumrep.ktyTab.count = 0 then
                       l_start_index :=0;
                    else
                       l_start_index := hrsumrep.ktyTab.first;
                    end if;
                 -- for i in hrsumrep.ktyTab.first..l_columns_required loop
                    l_concat_debug_string := ' ';
                    for i in l_start_index..(l_columns_required-1) loop
                        fnd_message.set_token('NUM',to_char(j));
                        l_error_mesg := fnd_message.get;
                        dbms_sql.column_value(source_cursor,j,l_key_value);
                        l_error_mesg := null;
                        if i < ColNameTab.count then
                           --hrsumrep.write_stmt_log(ColNameTab(i).Col_Name || ' = ' || l_key_value);
                           l_concat_debug_string := l_concat_debug_string || ' ' || ColNameTab(i).Col_Name || ' ' || l_key_value
                                                    || ',';
                        else
                           --hrsumrep.write_stmt_log(hrsumrep.ktytab(i-ColNameTab.count).key_type || ' = ' || l_key_value);
                           l_concat_debug_string := l_concat_debug_string || ' ' || hrsumrep.ktytab(i-ColNameTab.count).key_type
                                                    || ' ' || l_key_value || ',';
                        end if;
                        j := j+1;
                    end loop;
                    if l_concat_debug_string is not null and l_concat_debug_string <> ' ' then
                       hrsumrep.write_stmt_log(l_concat_debug_string);
                    end if;
                 end if;
              end if;

              else -- if fetch_rows > 0
                 exit;
              end if;
         end loop;
      --
      -- hrsumrep.write_error(p_itu_name||': '||z);
      --
      hr_utility.set_location('Leaving: hr_sum_store.store_data', 20);
      --
   exception when others then
       p_error := 1; /* If error occurs set p_error to 1 to indicate error */
       if l_error_mesg is null then
          hr_utility.trace('exception in HR_SUM_STORE');
          hr_utility.trace(SQLCODE);
          hr_utility.trace(SQLERRM);
          hrsumrep.write_stmt_log(p_stmt => l_new_stmt);
          null;
       else
          hr_utility.trace('error in HR_SUM_STORE');
          hrsumrep.write_error(null);
          hrsumrep.write_error(l_error_mesg);
          hrsumrep.write_error(sqlerrm);
    --    hrsumrep.write_stmt_log(p_stmt => p_stmt);
          hrsumrep.write_stmt_log(p_stmt => l_new_stmt);
       end if;
   end dynamic_block;
   dbms_sql.close_cursor(source_cursor);
end store_data;

end hr_sum_store;

/
