--------------------------------------------------------
--  DDL for Package ICX_REQ_CATEGORIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_REQ_CATEGORIES" AUTHID CURRENT_USER as
/* $Header: ICXRQCAS.pls 115.1 99/07/17 03:22:48 porting ship $ */


  procedure GetCategoryTop( v_org_id number );


  procedure categories(start_row in number default 1,
                       c_end_row in number default null,
                       p_where in number);

  procedure GetCategoryChildren( p_where in number,
                                 nodeId  in varchar2  default null,
				 nodeIndex in varchar2 default null);

  procedure submit_items(cartId in number,
		         p_emergency in number default null,
		         p_start_row in number default 1,
			 p_end_row in number default null,
                         p_where in varchar2,
			 p_cat_name in varchar2 default null,
		         end_row IN number default null,
			 p_query_set IN number default null,
		         p_row_count IN number default null,
			 Quantity in ICX_OWA_PARMS.ARRAY default ICX_OWA_PARMS.empty,
			 Line_Id in ICX_OWA_PARMS.ARRAY default ICX_OWA_PARMS.empty);

  procedure catalog_items( p_start_row in number default 1,
                           p_end_row in number default null,
				   p_where in varchar2);

  procedure catalog_items_display( p_start_row in number default 1,
                                   p_end_row in number default null,
				   p_where in varchar2);

  procedure catalog_items_buttons( p_start_row in number default 1,
                                   p_end_row in number default null,
				   p_total_rows in number,
				   p_where in varchar2);
end ICX_REQ_CATEGORIES;

 

/
