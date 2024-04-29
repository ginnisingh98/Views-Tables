--------------------------------------------------------
--  DDL for Package INVP_CMERGE_TXHI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVP_CMERGE_TXHI" AUTHID CURRENT_USER as
/* $Header: invcmts.pls 115.3 2003/03/11 23:28:10 lplam ship $ */
	procedure MERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2);
END INVP_CMERGE_TXHI;

 

/
