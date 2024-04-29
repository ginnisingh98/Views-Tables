--------------------------------------------------------
--  DDL for Package OEP_CMERGE_OESET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OEP_CMERGE_OESET" AUTHID CURRENT_USER AS
/* $Header: oesetps.pls 115.0 99/07/16 08:28:06 porting ship $ */
  	PROCEDURE MERGE (REQ_ID NUMBER, SET_NUM NUMBER, PROCESS_MODE VARCHAR2);
END OEP_CMERGE_OESET;

 

/
