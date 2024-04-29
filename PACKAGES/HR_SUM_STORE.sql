--------------------------------------------------------
--  DDL for Package HR_SUM_STORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SUM_STORE" AUTHID CURRENT_USER as
/* $Header: hrsumsto.pkh 115.5 2003/05/19 15:13:17 jheer noship $ */
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
			p_error out nocopy number);
--
end hr_sum_store;

 

/
