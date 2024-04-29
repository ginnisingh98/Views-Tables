--------------------------------------------------------
--  DDL for Package AD_DD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_DD" AUTHID CURRENT_USER as
/* $Header: addds.pls 115.5 2004/06/02 08:09:46 sallamse ship $ */
procedure register_table
           (p_appl_short_name in varchar2,
            p_tab_name        in varchar2,
            p_tab_type        in varchar2,
            p_next_extent     in number default 512,
            p_pct_free        in number default 10,
            p_pct_used        in number default 70);

procedure register_column
           (p_appl_short_name in varchar2,
            p_tab_name        in varchar2,
            p_col_name        in varchar2,
            p_col_seq         in number,
            p_col_type        in varchar2,
            p_col_width       in number,
            p_nullable        in varchar2,
            p_translate       in varchar2,
            p_precision       in number default null,
            p_scale           in number default null);

procedure register_primary_key
           (p_appl_short_name in varchar2,
            p_key_name        in varchar2,
            p_tab_name        in varchar2,
            p_description     in varchar2,
            p_key_type        in varchar2,
            p_audit_flag      in varchar2,
            p_enabled_flag    in varchar2);

procedure update_primary_key
           (p_appl_short_name in varchar2,
            p_key_name        in varchar2,
            p_tab_name        in varchar2,
            p_description     in varchar2 default null,
            p_key_type        in varchar2 default null,
            p_audit_flag      in varchar2 default null,
            p_enabled_flag    in varchar2 default null);

procedure register_primary_key_column
           (p_appl_short_name in varchar2,
            p_key_name        in varchar2,
            p_tab_name        in varchar2,
            p_col_name        in varchar2,
            p_col_sequence    in number);

procedure delete_primary_key_column
           (p_appl_short_name in varchar2,
            p_key_name        in varchar2,
            p_tab_name        in varchar2,
            p_col_name        in varchar2 default null);


procedure delete_table
           (p_appl_short_name in varchar2,
            p_tab_name        in varchar2);

procedure delete_column
           (p_appl_short_name in varchar2,
            p_tab_name        in varchar2,
            p_col_name        in varchar2);

end ad_dd;

 

/
