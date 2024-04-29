--------------------------------------------------------
--  DDL for Package INVP_CMERGE_SPDM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVP_CMERGE_SPDM" AUTHID CURRENT_USER as
/* $Header: invcmsps.pls 120.0 2005/05/25 05:37:55 appldev noship $ */
	procedure MERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2);
END INVP_CMERGE_SPDM;

 

/
