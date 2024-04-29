--------------------------------------------------------
--  DDL for Package ICX_TEMPLATE_PARSER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_TEMPLATE_PARSER" AUTHID CURRENT_USER AS
/* $Header: ICXPARSS.pls 115.2 99/07/17 03:19:56 porting ship $ */

procedure clear_variables;

procedure add_variable(p_variable_name in varchar2,
                       p_sequence in number,
                       p_value in varchar2,
                       p_related_id in number default null,
                       p_parent_name in varchar2 default null,
                       p_parent_related_id in number default null);

procedure parse(p_template_name in varchar2);

procedure get_HTML_file(p_file_name in varchar2);

procedure get_fnd_message(p_app_code in varchar2,
                          p_message_name in varchar2);

procedure tag_list;

procedure tag_details(tag_name in varchar2);

procedure print_variables;



end icx_template_parser;

 

/
