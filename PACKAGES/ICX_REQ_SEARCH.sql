--------------------------------------------------------
--  DDL for Package ICX_REQ_SEARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_REQ_SEARCH" AUTHID CURRENT_USER as
/* $Header: ICXSRCHS.pls 115.4 99/07/17 03:25:09 porting ship $ */

  procedure itemsearch(n_org number);

  procedure itemsearch_display( searchX in varchar2 default null,
			               paramX  in varchar2 default null );

  procedure itemsearch_buttons(p_start_row in number default 1,
                               p_end_row in number default null,
                               p_total_rows in number,
                               p_where in number,
			       p_context in varchar2 default 'Y');

  procedure displayItem(a_1 in varchar2 default null,
                        c_1 in varchar2 default null,
                        i_1 in varchar2 default null,
                        a_2 in varchar2 default null,
                        c_2 in varchar2 default null,
                        i_2 in varchar2 default null,
                        a_3 in varchar2 default null,
                        c_3 in varchar2 default null,
                        i_3 in varchar2 default null,
                        a_4 in varchar2 default null,
                        c_4 in varchar2 default null,
                        i_4 in varchar2 default null,
                        a_5 in varchar2 default null,
                        c_5 in varchar2 default null,
                        i_5 in varchar2 default null,
                        p_start_row in number default 1,
                        p_end_row in number default null,
     	                p_where in varchar2 default null,
			p_cat in varchar2 default null,
			p_values in number default null,
                        m in  varchar2 default null ,
                        o in  varchar2 default null,
			p_hidden in varchar2 default null);

   procedure submit_items (cartId IN NUMBER,
                      p_emergency IN number default null,
                      a_1 in varchar2 default null,
                      c_1 in varchar2 default null,
                      i_1 in varchar2 default null,
                      a_2 in varchar2 default null,
                      c_2 in varchar2 default null,
                      i_2 in varchar2 default null,
                      a_3 in varchar2 default null,
                      c_3 in varchar2 default null,
                      i_3 in varchar2 default null,
                      a_4 in varchar2 default null,
                      c_4 in varchar2 default null,
                      i_4 in varchar2 default null,
                      a_5 in varchar2 default null,
                      c_5 in varchar2 default null,
                      i_5 in varchar2 default null,
                      p_start_row IN NUMBER default 1,
                      p_end_row IN NUMBER default null,
                      p_where IN varchar2,
		      p_hidden IN varchar2 default null,
     	              end_row IN number default null,
              	      p_query_set IN number default null,
		      p_row_count IN number default null,
                      Quantity IN ICX_OWA_PARMS.ARRAY default ICX_OWA_PARMS.empty,
                      Line_Id IN ICX_OWA_PARMS.ARRAY default ICX_OWA_PARMS.empty);


end ICX_REQ_SEARCH;

 

/
