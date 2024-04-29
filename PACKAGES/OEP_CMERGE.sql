--------------------------------------------------------
--  DDL for Package OEP_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OEP_CMERGE" AUTHID CURRENT_USER AS
/* $Header: oeoemps.pls 115.0 99/07/16 08:27:25 porting ship $ */
	PROCEDURE MERGE (REQ_ID NUMBER,
		         SET_NUM NUMBER,
			 PROCESS_MODE VARCHAR2);
END OEP_CMERGE;

 

/
