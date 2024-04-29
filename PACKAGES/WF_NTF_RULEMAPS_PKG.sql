--------------------------------------------------------
--  DDL for Package WF_NTF_RULEMAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_NTF_RULEMAPS_PKG" AUTHID CURRENT_USER as
/* $Header: WFNTFRMS.pls 120.1 2005/07/02 03:16:30 appldev noship $ */

procedure insert_row(x_rule_name      in varchar2,
		     x_attribute_name in varchar2,
		     x_column_name    in varchar2);

procedure delete_row(x_rule_name      in varchar2,
		     x_attribute_name in varchar2);

procedure update_row(x_rule_name      in varchar2,
		     x_attribute_name in varchar2,
		     x_column_name    in varchar2);

procedure load_row(x_rule_name      in varchar2,
		   x_attribute_name in varchar2,
		   x_column_name    in varchar2);

end WF_NTF_RULEMAPS_PKG;


 

/
