--------------------------------------------------------
--  DDL for Package ICX_REQ_TEMPLATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_REQ_TEMPLATES" AUTHID CURRENT_USER as
/* $Header: ICXRQTMS.pls 115.1 99/07/17 03:23:39 porting ship $ */


  procedure GetTemplateTop( v_org_id    number,
                            v_emergency varchar2 default NULL );

  procedure templates(start_row in number default 1,
                      c_end_row in number default null,
                      p_where in number);

  procedure GetTemplateChildren( p_where in number,
                                 nodeId  in varchar2  default null,
			         nodeIndex in varchar2 default null);


  procedure template_items(p_start_row in number default 1,
                           p_end_row in number default null,
				   p_where in varchar2);

  procedure template_items_display(p_start_row in number default 1,
                                   p_end_row in number default null,
				   p_where in varchar2);

  procedure template_items_buttons(p_start_row in number default 1,
                                   p_end_row in number default null,
				   p_total_rows in number,
				   p_where in number);

  PROCEDURE submit_items (cartId IN NUMBER,
                          p_start_row      IN NUMBER DEFAULT 1,
		          p_end_row        IN NUMBER DEFAULT NULL,
		          p_where          IN VARCHAR2,
                          v_express_name   IN VARCHAR2,
			  p_emergency      IN NUMBER DEFAULT NULL,
                          end_row          IN NUMBER DEFAULT NULL,
                          p_query_set      IN NUMBER DEFAULT NULL,
                          p_row_count      IN NUMBER DEFAULT NULL,
                          Quantity         IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          v_sequence_num   IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty);

PROCEDURE total_page(l_rows_added NUMBER DEFAULT 0,
                     l_rows_updated NUMBER DEFAULT 0,
                     l_qty_added NUMBER DEFAULT 0,
                     l_qty_updated NUMBER DEFAULT 0,
                     l_order_total NUMBER DEFAULT 0,
                     l_dest_org_id NUMBER,
                     v_express_name VARCHAR2 default null,
                     p_start_row NUMBER DEFAULT 1,
                     p_end_row NUMBER DEFAULT NULL,
                     p_where   VARCHAR2,
                     end_row NUMBER DEFAULT NULL,
                     p_query_set NUMBER DEFAULT NULL,
                     p_row_count NUMBER DEFAULT NULL);

end ICX_REQ_TEMPLATES;

 

/
