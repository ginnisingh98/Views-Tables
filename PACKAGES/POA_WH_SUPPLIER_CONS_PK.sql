--------------------------------------------------------
--  DDL for Package POA_WH_SUPPLIER_CONS_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_WH_SUPPLIER_CONS_PK" AUTHID CURRENT_USER AS
/* $Header: poaspc1s.pls 115.2 2002/01/25 14:02:49 pkm ship    $ */


  FUNCTION calc_savings
		(p_item_name		IN  VARCHAR2,
		 p_pref_supplier_name	IN  VARCHAR2,
		 p_cons_supplier_name	IN  VARCHAR2,
		 p_defect_cost		IN  NUMBER,
		 p_del_excp_cost	IN  NUMBER,
		 p_start_date		IN  DATE,
		 p_end_date		IN  DATE,
		 p_return_type		IN  NUMBER) 	RETURN NUMBER;


PRAGMA RESTRICT_REFERENCES(calc_savings, WNDS, WNPS, RNPS);

END poa_wh_supplier_cons_pk;

 

/
