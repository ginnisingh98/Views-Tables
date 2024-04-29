--------------------------------------------------------
--  DDL for Package GMF_AP_GET_TERMS_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AP_GET_TERMS_ID" AUTHID CURRENT_USER AS
/* $Header: gmftrmis.pls 115.0 99/07/16 04:25:21 porting shi $ */
PROCEDURE ap_get_terms_id( terms_code in out varchar2,
		terms_id in out number,
		row_to_fetch in out number,
		statuscode out number);
END GMF_AP_GET_TERMS_ID;

 

/
