--------------------------------------------------------
--  DDL for Package ICX_AK_JAVA_QUERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_AK_JAVA_QUERY" AUTHID CURRENT_USER as
/* $Header: ICXAKJQS.pls 115.4 99/07/17 03:15:13 porting ship $ */


procedure execute_query(p_region_app_id in varchar2,
                        p_region_code in varchar2,
                        p_where_clause in varchar2,
                        p_order_clause in varchar2,
                        p_time in varchar2);

procedure get_item(p_item_id in number,
                   p_attribute_code out varchar2,
                   p_value_id out number,
                   p_attribute_label_long out varchar2,
                   p_display_sequence out number,
                   p_object_attribute_flag out varchar2,
                   p_node_display_flag out varchar2,
                   p_display_length out number);

procedure get_result_row(p_row_num in number,
                         p_result_row out icx_util.char240_table);

procedure update_oc_kids(p_group_id in number);


end icx_ak_java_query;

 

/
