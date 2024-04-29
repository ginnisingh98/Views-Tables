--------------------------------------------------------
--  DDL for Package AD_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_UTIL" AUTHID CURRENT_USER as
/* $Header: adutils.pls 115.5 2004/06/04 14:31:41 sallamse ship $ */
procedure update_column
           (p_old_oid  in number,
            p_new_oid  in number,
            p_tab_name in varchar2,
            p_col_name in varchar2,
            p_option   in varchar2);

procedure update_oracle_id
           (p_release in varchar2,     /* for future use */
            p_old_oid in number,
            p_option  in varchar2 );

procedure update_oracle_id
           (p_release in varchar2,     /* for future use */
            p_old_oid in number);

procedure update_oracle_id
           (p_release in varchar2,     /* for future use */
            p_old_oid in number,
            p_new_oid in number,
            p_option  in varchar2 );

procedure update_oracle_id
           (p_release in varchar2,     /* for future use */
            p_old_oid in number,
            p_new_oid in number);

procedure set_prod_to_shared
           (p_release         in varchar2,
            p_apps_short_name in varchar2);

end ad_util;

 

/
