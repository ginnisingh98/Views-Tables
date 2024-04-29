--------------------------------------------------------
--  DDL for Package MSC_PERS_QUERIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_PERS_QUERIES" AUTHID CURRENT_USER as
/* $Header: MSCPQS.pls 120.5 2007/10/05 21:25:34 cnazarma ship $ */

  p_item_type constant number := 1;
  p_res_type constant number := 2;
  p_excp_type constant number := 4;
  p_supp_type constant number := 5;
  p_shipment_type constant number := 6;
  p_order_type constant number := 9;
  p_wl_type    constant number := 10;
  p_crit_type constant number := 12;

  p_item_view constant varchar2(50) := 'MSC_SYSTEM_ITEMS_SC_V';
  p_excp_view constant varchar2(50) := 'MSC_EXCEPTION_DETAILS_V';
  p_cp_custom_excp_view constant varchar2(50) := 'MSC_CP_CUSTOM_EXC_DETAILS_V';
  p_cp_excp_view constant varchar2(50) := 'MSC_X_EXCEPTION_DETAILS_V';
  p_supp_view constant varchar2(50) := 'MSC_ITEM_SUPPLIER_V';
  p_res_view constant varchar2(50) := 'MSC_PLANNED_RESOURCES_V';
  p_shipment_view constant varchar2(50) := 'MSC_SHIPMENT_DETAILS_V';
  p_order_view constant varchar2(50) := 'MSC_ORDERS_V';
  p_item_attributes_view constant varchar2(80) := 'MSC_ITEM_ATTRIBUTES_V';

  procedure populate_result_table(p_query_id in number,
		p_query_type in number,
                p_plan_id in number,
		p_where_clause in varchar2,
		p_execute_flag in boolean,
                P_MASTER_QUERY_ID in NUMBER DEFAULT NULL,
                p_sequence_id in NUMBER DEFAULT NULL);

  function get_user(p_user_id in number) return varchar2;
  function get_query_name(p_query_id in number) return varchar2;
  function get_query_type(p_query_id in number) return number;

  procedure populate_cp_temp_table(p_query_id in number);

  Procedure purge_plan(p_plan_id IN NUMBER);
  procedure update_category( ERRBUF     OUT NOCOPY VARCHAR2,
                             RETCODE    OUT NOCOPY NUMBER,
                             p_query_id in NUMBER);

  procedure save_as(p_query_id in number,
	p_query_name in varchar2,
	p_query_desc in varchar2,
	p_public_flag in number);

  procedure delete_query(p_query_id in number,
	p_query_name in varchar2 default null);

FUNCTION save_as(p_query_id in number,
	p_query_name in varchar2,
	p_query_desc in varchar2,
	p_public_flag in number) return number;

FUNCTION copy_query(p_query_id in number,
	p_query_name in varchar2,
	p_query_desc in varchar2,
	p_public_flag in number) return number;

end MSC_PERS_QUERIES;

/
