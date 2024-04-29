--------------------------------------------------------
--  DDL for Package Body ICX_AK_JAVA_QUERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_AK_JAVA_QUERY" as
/* $Header: ICXAKJQB.pls 115.4 99/07/17 03:15:10 porting ship $ */



procedure execute_query(p_region_app_id in varchar2,
                        p_region_code in varchar2,
                        p_where_clause in varchar2,
                        p_order_clause in varchar2,
                        p_time in varchar2) is

l_result_row icx_util.char240_table;

begin
if icx_sec.validateSession then

  ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => p_region_app_id,
 		          P_PARENT_REGION_CODE => p_region_code,
                          P_WHERE_CLAUSE => p_where_clause,
                          P_ORDER_BY_CLAUSE => p_order_clause,
			  P_RETURN_PARENTS => 'T',
			  P_RETURN_CHILDREN => 'F');


  htp.p(ak_query_pkg.g_items_table.count);
  htp.p(ak_query_pkg.g_results_table.count);

  for item in 1..ak_query_pkg.g_items_table.count loop
    if ak_query_pkg.g_items_table(item-1).object_attribute_flag = 'Y' then
      htp.p(ak_query_pkg.g_items_table(item-1).attribute_code);
      htp.p(ak_query_pkg.g_items_table(item-1).value_id);
      htp.p(ak_query_pkg.g_items_table(item-1).attribute_label_long);
      htp.p(ak_query_pkg.g_items_table(item-1).display_sequence);
      htp.p(ak_query_pkg.g_items_table(item-1).object_attribute_flag);
      htp.p(ak_query_pkg.g_items_table(item-1).node_display_flag);
      htp.p(ak_query_pkg.g_items_table(item-1).display_value_length);
    end if;
  end loop;


  for result in 1 .. ak_query_pkg.g_results_table.count loop
    icx_util.transfer_Row_To_Column(ak_query_pkg.g_results_table(result-1),l_result_row);

    for l_item_num in 1..ak_query_pkg.g_items_table.count loop
      if ak_query_pkg.g_items_table(l_item_num-1).object_attribute_flag = 'Y' then
        htp.p(l_result_row(l_item_num));
      end if;
    end loop;
  end loop;

end if;
end;



procedure get_item(p_item_id in number,
                   p_attribute_code out varchar2,
                   p_value_id out number,
                   p_attribute_label_long out varchar2,
                   p_display_sequence out number,
                   p_object_attribute_flag out varchar2,
                   p_node_display_flag out varchar2,
                   p_display_length out number) is

begin

p_attribute_code := ak_query_pkg.g_items_table(p_item_id).attribute_code;
p_value_id := ak_query_pkg.g_items_table(p_item_id).value_id;
p_attribute_label_long := ak_query_pkg.g_items_table(p_item_id).attribute_label_long;
p_display_sequence := ak_query_pkg.g_items_table(p_item_id).display_sequence;
p_object_attribute_flag := ak_query_pkg.g_items_table(p_item_id).object_attribute_flag;
p_node_display_flag := ak_query_pkg.g_items_table(p_item_id).node_display_flag;
p_display_length := ak_query_pkg.g_items_table(p_item_id).display_value_length;

end;



procedure get_result_row(p_row_num in number,
                         p_result_row out icx_util.char240_table) is

l_item_num number;
l_result_row icx_util.char240_table;

begin

-- transfer one row of the l_results_table into a seperate pl/sql table
-- that will enable the specific transfer of only those elements of the
-- row that are populated (eliminating the need for a 100 member array
-- to be allocated in java)

icx_util.transfer_Row_To_Column(ak_query_pkg.g_results_table(p_row_num),l_result_row);

for l_item_num in 1..ak_query_pkg.g_items_table.count loop
    if ak_query_pkg.g_items_table(l_item_num - 1).object_attribute_flag = 'Y' then
      p_result_row(l_item_num) := l_result_row(ak_query_pkg.g_items_table(l_item_num - 1).value_id);
    else
      p_result_row(l_item_num) := '';
    end if;
end loop;

end;



procedure update_oc_kids(p_group_id in number) is

cursor option_classes is
select row_id,
       sort_order
from   icx_config_components_web_v
where  group_id = p_group_id
and    bom_item_type in (1,2)
order by sort_order;

l_option_count number;

begin

for oc in option_classes loop

  select count(*) into l_option_count
  from icx_config_components_web_v
  where group_id = p_group_id
  and   bom_item_type = 4
  and   substr(sort_order,1,length(sort_order)-4) = oc.sort_order
  and   selected_flag = 'Y';

  update icx_config_components_web_v
  set number_kids = l_option_count
  where row_id = oc.row_id;

end loop;

end;




end icx_ak_java_query;

/
