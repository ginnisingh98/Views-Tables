--------------------------------------------------------
--  DDL for Package OEP_CMERGE_OEDIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OEP_CMERGE_OEDIS" AUTHID CURRENT_USER AS
/* $Header: oedisps.pls 115.0 99/07/16 08:25:36 porting ship $ */
  	PROCEDURE MERGE (REQ_ID NUMBER, SET_NUM NUMBER, PROCESS_MODE VARCHAR2);
END OEP_CMERGE_OEDIS;

 

/
