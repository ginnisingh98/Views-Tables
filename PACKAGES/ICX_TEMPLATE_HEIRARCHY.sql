--------------------------------------------------------
--  DDL for Package ICX_TEMPLATE_HEIRARCHY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_TEMPLATE_HEIRARCHY" AUTHID CURRENT_USER as
/* $Header: ICXTMPHS.pls 115.1 99/07/17 03:29:46 porting ship $ */

procedure main;

procedure template_head(p_template in varchar2 default null,
 		        p_query_flag in varchar2 default 'F');

procedure template_tail(p_template in varchar2 default null,
		        p_start_row in number default 1,
		        p_end_row in number default null);

procedure template_insert(icx_template1 in varchar2 default null,
		          icx_relation in varchar2 default null,
		          icx_related_template in varchar2 default null);

procedure template_delete(icx_template1 in varchar2 default null,
		          icx_related_template in varchar2 default null);


end icx_template_heirarchy;

 

/
