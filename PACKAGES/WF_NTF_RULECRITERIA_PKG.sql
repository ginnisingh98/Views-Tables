--------------------------------------------------------
--  DDL for Package WF_NTF_RULECRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_NTF_RULECRITERIA_PKG" AUTHID CURRENT_USER as
/* $Header: WFNTFRCS.pls 120.1 2005/07/02 03:16:15 appldev noship $ */

procedure insert_row(x_rule_name  in varchar2,
		     x_msg_type   in varchar2);

procedure delete_row(x_rule_name  in varchar2,
     		     x_msg_type   in varchar2);

procedure update_row(x_rule_name  in varchar2,
		     x_msg_type   in varchar2);

procedure load_row(x_rule_name  in varchar2,
		   x_msg_type   in varchar2);

end WF_NTF_RULECRITERIA_PKG;


 

/
