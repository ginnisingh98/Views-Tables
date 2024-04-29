--------------------------------------------------------
--  DDL for Package Body AK_RUN_FLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_RUN_FLOW_PKG" as
/* $Header: akdrunfb.pls 115.2 99/07/17 15:19:49 porting s $ */
procedure GET_ATTRIBUTE_LIST_VALUES (
  X_TRACE_NUM                  in NUMBER,
  X_REGION_APPLICATION_ID      in NUMBER,
  X_REGION_CODE                in VARCHAR2
) is
cursor check_object_csr is
  select 1
  from   all_objects ao, ak_regions ar
  where  ao.object_name = ar.database_object_name
  and    ar.region_application_id = x_region_application_id
  and    ar.region_code = x_region_code
  and    ao.object_type in ('TABLE', 'VIEW');
TYPE label_table_type is TABLE of varchar2(50)
  index by binary_integer;
l_regions_table                 AK_QUERY_PKG.regions_table_type;
l_items_table                   AK_QUERY_PKG.items_table_type;
l_results_table                 AK_QUERY_PKG.results_table_type;
l_label1_table                  label_table_type;
l_label2_table                  label_table_type;
l_label3_table                  label_table_type;

l_display_value                 varchar2(510);
l_dummy                         number;
l_index                         number;
l_region_rec_id                 number;
begin
  --
  -- Check to see if the database object for the given region exists.
  -- Otherwise, the call to exec_query will fail with errors.
  --
  open check_object_csr;
  fetch check_object_csr into l_dummy;
  if (check_object_csr%notfound) then
    close check_object_csr;
    return;
  end if;
  close check_object_csr;
  --
  -- Call exec_query to obtain the list values
  --
  AK_QUERY_PKG.exec_query(
        p_flow_appl_id => null,
        p_flow_code => null,
        p_parent_page_appl_id => null,
        p_parent_page_code => null,
	p_parent_region_appl_id => x_region_application_id,
	p_parent_region_code => x_region_code,
        p_parent_primary_key_name => null,
        p_child_page_appl_id => null,
        p_child_page_code => null,
        p_parent_key_value1 => null,
	p_parent_key_value2 => null,
	p_parent_key_value3 => null,
	p_parent_key_value4 => null,
	p_parent_key_value5 => null,
        p_parent_key_value6 => null,
	p_parent_key_value7 => null,
	p_parent_key_value8 => null,
	p_parent_key_value9 => null,
	p_parent_key_value10 => null,
	p_where_clause => null,
        p_return_parents => 'T',
	p_return_children => 'F',
        p_set_trace => 'F',
	p_return_node_display_only => 'F');
  --
  -- Load attribute labels into PL/SQL table - they will be used
  -- in building the string that will be the display_value column
  -- in the temp table.
  -- *Note 1: only load the labels for the first 3 attributes in each
  --          region - since only 3 attributes will be included in
  --          display_value.
  -- *Note 2: The PL/SQL table is sparse, and the region_rec_id returned
  --          from execute_query will be used as index
  --
  l_regions_table := ak_query_pkg.g_regions_table;
  l_items_table := ak_query_pkg.g_items_table;
  l_results_table := ak_query_pkg.g_results_table;

  if l_items_table.count > 0 then
    l_index := l_items_table.first;
    while l_index is not null loop
      l_region_rec_id := l_items_table(l_index).region_rec_id;
      if (l_items_table(l_index).value_id = 1) then
        l_label1_table(l_region_rec_id) :=
                           l_items_table(l_index).attribute_label_long;
      elsif (l_items_table(l_index).value_id = 2) then
        l_label2_table(l_region_rec_id) :=
                           l_items_table(l_index).attribute_label_long;
      elsif (l_items_table(l_index).value_id = 3) then
        l_label3_table(l_region_rec_id) :=
                           l_items_table(l_index).attribute_label_long;
      end if;
      l_index := l_items_table.next(l_index);
    end loop; /* while l_index is not null */
  end if; /* if l_items_table.count > 0 */
  --
  -- Insert result values into the temp table for use by the RUN FLOW FORM
  --
  if l_results_table.count > 0 then
    for l_index in l_results_table.first .. l_results_table.last loop
      --
      -- build display_value string
      --
      l_region_rec_id := l_results_table(l_index).region_rec_id;
      l_display_value := null;
      if l_label1_table.exists(l_region_rec_id) and
         l_label1_table(l_region_rec_id) is not null then
           l_display_value := substr(l_label1_table(l_region_rec_id),1,30)
                              || ':';
      end if;
      if (l_results_table(l_index).value1 is not null) then
        l_display_value := l_display_value ||
                           substr(l_results_table(l_index).value1,
                                  1,30);
      end if;
      if l_label2_table.exists(l_region_rec_id) and
         l_label2_table(l_region_rec_id) is not null then
           l_display_value := l_display_value || ', ' ||
                              substr(l_label2_table(l_region_rec_id),1,30)
                              || ': ';
      end if;
      if (l_results_table(l_index).value2 is not null) then
        l_display_value := l_display_value ||
                           substr(l_results_table(l_index).value2,
                                  1,30);
      end if;
      if l_label3_table.exists(l_region_rec_id) and
         l_label3_table(l_region_rec_id) is not null then
           l_display_value := l_display_value || ', ' ||
                              substr(l_label3_table(l_region_rec_id),1,30)
                              || ': ';
      end if;
      if (l_results_table(l_index).value3 is not null) then
        l_display_value := l_display_value ||
                           substr(l_results_table(l_index).value3,
                                  1,30);
      end if;
      l_display_value := l_display_value || ' ( ';
      if l_results_table(l_index).key1 is not null then
         l_display_value := l_display_value ||
                            substr(l_results_table(l_index).key1, 1, 30);
      end if;
      if l_results_table(l_index).key2 is not null then
         l_display_value := l_display_value || ', ' ||
                            substr(l_results_table(l_index).key2, 1, 30);
      end if;
      if l_results_table(l_index).key3 is not null then
         l_display_value := l_display_value || ', ' ||
                            substr(l_results_table(l_index).key3, 1, 30);
      end if;
      if l_results_table(l_index).key4 is not null then
         l_display_value := l_display_value || ', ' ||
                            substr(l_results_table(l_index).key4, 1, 30);
      end if;
      if l_results_table(l_index).key5 is not null then
         l_display_value := l_display_value || ', ' ||
                            substr(l_results_table(l_index).key5, 1, 30);
      end if;
      if l_results_table(l_index).key6 is not null then
         l_display_value := l_display_value || ', ' ||
                            substr(l_results_table(l_index).key6, 1, 30);
      end if;
      if l_results_table(l_index).key7 is not null then
         l_display_value := l_display_value || ', ' ||
                            substr(l_results_table(l_index).key7, 1, 30);
      end if;
      if l_results_table(l_index).key8 is not null then
         l_display_value := l_display_value || ', ' ||
                            substr(l_results_table(l_index).key8, 1, 30);
      end if;
      if l_results_table(l_index).key9 is not null then
         l_display_value := l_display_value || ', ' ||
                            substr(l_results_table(l_index).key9, 1, 30);
      end if;
      if l_results_table(l_index).key10 is not null then
         l_display_value := l_display_value || ', ' ||
                            substr(l_results_table(l_index).key10, 1, 30);
      end if;
      l_display_value := l_display_value || ' )';
      --
      -- Insert results into temp database table
      --
      insert into ak_object_values_temp (
        TRACE_NUM,
        REGION_APPLICATION_ID,
        REGION_CODE,
        DISPLAY_VALUE,
        KEY_VALUE1,
        KEY_VALUE2,
        KEY_VALUE3,
        KEY_VALUE4,
        KEY_VALUE5,
        KEY_VALUE6,
        KEY_VALUE7,
        KEY_VALUE8,
        KEY_VALUE9,
        KEY_VALUE10
      ) values (
        X_TRACE_NUM,
        X_REGION_APPLICATION_ID,
        X_REGION_CODE,
        l_display_value,
        l_results_table(l_index).key1,
        l_results_table(l_index).key2,
        l_results_table(l_index).key3,
        l_results_table(l_index).key4,
        l_results_table(l_index).key5,
        l_results_table(l_index).key6,
        l_results_table(l_index).key7,
        l_results_table(l_index).key8,
        l_results_table(l_index).key9,
        l_results_table(l_index).key10
      );
    end loop; /* for l_index in ... */
  end if; /* if l_results_table.count > 0 */
end GET_ATTRIBUTE_LIST_VALUES;

end AK_RUN_FLOW_PKG;

/
