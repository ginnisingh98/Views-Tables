--------------------------------------------------------
--  DDL for Package INVP_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVP_CMERGE" AUTHID CURRENT_USER as
/*  $Header: invcm3s.pls 120.0 2005/05/25 05:14:34 appldev noship $ */
	procedure MERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2);
end INVP_CMERGE;

 

/
