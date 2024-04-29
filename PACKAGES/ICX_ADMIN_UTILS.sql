--------------------------------------------------------
--  DDL for Package ICX_ADMIN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_ADMIN_UTILS" AUTHID CURRENT_USER as
-- $Header: ICXADUTS.pls 120.1 2005/10/07 13:19:01 gjimenez noship $

procedure displayList(a_1 in varchar2 default null,
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
		      p_hidden in varchar2 default null,
		      p_start_row in number default 1,
		      p_end_row in number default null,
		      p_where in varchar2 default null);

procedure LISTScript;

procedure selectList(   p_left_region_appl_id   in number,
                        p_left_region_code      in varchar2,
                        p_left_where            in varchar2     default null,
                        p_right_region_appl_id  in number,
                        p_right_region_code     in varchar2,
                        p_right_where           in varchar2     default null,
                        p_hidden_name           in varchar2     default null,
                        p_hidden_value          in varchar2     default null,
                        p_modify_url            in varchar2,
                        p_primary_key_size      in number);

end icx_admin_utils;

 

/
