--------------------------------------------------------
--  DDL for Package ICX_ON_CABO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_ON_CABO" AUTHID CURRENT_USER as
/* $Header: ICXONCS.pls 120.0 2005/10/07 12:16:03 gjimenez noship $ */

type number_table is table of number
        index by binary_integer;

type v2000_table is table of varchar2(2000)
        index by binary_integer;

procedure findPage(p_flow_appl_id in number default null,
                   p_flow_code in varchar2 default null,
                   p_page_appl_id in number default null,
                   p_page_code in varchar2 default null,
		   p_region_appl_id in number default null,
		   p_region_code in varchar2 default null,
                   p_lines_now in number default 1,
                   p_lines_next in number default 5,
                   p_hidden_name in varchar2 default null,
                   p_hidden_value in varchar2 default null,
                   p_help_url in varchar2 default null);

procedure findForm(p_flow_appl_id in number default null,
                   p_flow_code in varchar2 default null,
                   p_page_appl_id in number default null,
                   p_page_code in varchar2 default null,
                   p_region_appl_id in number,
                   p_region_code in varchar2,
                   p_lines_now in number default 1,
                   p_lines_next in number default 5,
                   p_hidden_name in varchar2 default null,
                   p_hidden_value in varchar2 default null,
                   p_help_url in varchar2 default null);

procedure displayPage;

procedure wherePage;

procedure WFPage;

end icx_on_cabo;

 

/
