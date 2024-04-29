--------------------------------------------------------
--  DDL for Package ICX_CAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT" AUTHID CURRENT_USER as
/* $Header: ICXCATHS.pls 115.0 99/08/09 17:22:22 porting ship $ */

procedure main;

procedure cat_head(p_category_set_id in varchar2 default null,
   		   p_category_id in varchar2 default null,
		   p_category in varchar2 default null,
		   p_query_flag in varchar2 default 'F');

procedure cat_tail(p_category_set_id in varchar2 default null,
		   p_category_id in varchar2 default null,
		   p_category_name in varchar2 default null,
		   p_start_row in number default 1,
		   p_end_row in number default null);

procedure cat_insert(icx_category_set_id in varchar2 default null,
		     icx_category_id in varchar2 default null,
		     icx_category in varchar2 default null,
		     icx_relation in varchar2 default null,
		     icx_related_category_id in varchar2 default null,
		     icx_related_category in varchar2 default null);

procedure cat_delete(icx_category_set_id in varchar2 default null,
		     icx_category_id in varchar2 default null,
		     icx_related_category_id in varchar2 default null);


end icx_cat;

 

/
