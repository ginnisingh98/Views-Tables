--------------------------------------------------------
--  DDL for Package FII_FINANCIAL_DIMENSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_FINANCIAL_DIMENSION_PKG" AUTHID CURRENT_USER as
/*$Header: FIIFDIMS.pls 115.4 2003/10/27 23:41:08 tkoshio ship $*/


function range_or_single(p_coa_id in number) return varchar2;

procedure update_dimension(	p_short_name		in varchar2,
				p_name  		in varchar2,
				p_description  		in varchar2,
				p_system_enabled_flag 	in varchar2,
				p_dbi_enabled_flag 	in varchar2,
				p_master_value_set_id 	in number,
				p_dbi_hier_top_node 	in varchar2,
				p_dbi_hier_top_node_id 	in number,
				x_status 		out nocopy varchar2,
                                x_message_count out nocopy number,
                                x_error_message out nocopy varchar2);

procedure manage_dimension_map_rules(p_chart_of_accounts_id in number,
                                     p_event in varchar2,
                                     x_status out nocopy varchar2,
                                     x_message_count out nocopy number,
                                     x_error_message out nocopy varchar2);

PROCEDURE DeleteJeInclusionRules(p_je_rule_set_id     IN NUMBER,
                                 x_status            OUT nocopy VARCHAR2,
                                 x_message_count     OUT nocopy NUMBER,
                                 x_error_message     OUT nocopy VARCHAR2);
procedure resetProdCateg(        x_status     	     OUT nocopy VARCHAR2,
                                 x_message_count     OUT nocopy NUMBER,
                                 x_error_message     OUT nocopy VARCHAR2);

end FII_FINANCIAL_DIMENSION_PKG;

 

/
