--------------------------------------------------------
--  DDL for Package PQH_INST_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_INST_TYPE_PKG" AUTHID CURRENT_USER as
/* $Header: pqhipedin.pkh 115.1 2002/10/18 00:30:37 rthiagar noship $ */

function get_inst_type(p_org_id 	number)
		return varchar2;
end;

 

/
