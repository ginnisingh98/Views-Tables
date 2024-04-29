--------------------------------------------------------
--  DDL for Package OEP_CMERGE_OEPIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OEP_CMERGE_OEPIC" AUTHID CURRENT_USER AS
/* $Header: oepicps.pls 115.0 99/07/16 08:27:57 porting ship $ */
  	PROCEDURE MERGE (REQ_ID NUMBER, SET_NUM NUMBER, PROCESS_MODE VARCHAR2);
END OEP_CMERGE_OEPIC;

 

/
