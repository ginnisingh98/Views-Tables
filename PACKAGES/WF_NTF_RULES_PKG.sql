--------------------------------------------------------
--  DDL for Package WF_NTF_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_NTF_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: WFNTFRLS.pls 120.3 2005/12/15 22:01:46 hgandiko noship $ */

--Variables
g_seeduser varchar2(320) := 'DATAMERGE';
g_Mode varchar2(20) := null;


--APIs
procedure insert_row(x_owner_tag           in varchar2,
		     x_rule_name           in varchar2,
		     x_user_rule_name      in varchar2,
		     x_description         in varchar2,
		     x_customization_level in varchar2,
		     x_phase               in number,
		     x_status              in varchar2);

procedure delete_row(x_owner_tag  in varchar2,
		     x_rule_name  in varchar2);

procedure update_row(x_owner_tag           in varchar2,
		     x_rule_name           in varchar2,
		     x_user_rule_name      in varchar2,
		     x_description         in varchar2,
		     x_customization_level in varchar2,
		     x_phase               in number,
		     x_status              in varchar2);

procedure load_row(x_owner_tag           in varchar2,
		   x_rule_name           in varchar2,
		   x_user_rule_name      in varchar2,
		   x_description         in varchar2,
		   x_customization_level in varchar2,
		   x_phase               in number,
		   x_status              in varchar2,
		   x_custom_mode         in varchar2);

procedure FWKsetMode;

function is_update_allowed(X_CUSTOM_LEVEL_NEW in varchar2,
                           X_CUSTOM_LEVEL_OLD in varchar2) return varchar2;


procedure add_language;

procedure translate_row(x_rule_name           in varchar2,
                        x_user_rule_name      in varchar2,
                        x_description         in varchar2);

end WF_NTF_RULES_PKG;


 

/
