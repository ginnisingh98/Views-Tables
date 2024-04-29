--------------------------------------------------------
--  DDL for Package MRP_ATP_COLLECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_ATP_COLLECTION" AUTHID CURRENT_USER AS
/* $Header: MRPATPCS.pls 115.0 99/07/16 12:17:30 porting sh $  */
PROCEDURE Collect_Atp_Info(
	                ERRBUF              OUT VARCHAR2,
			RETCODE             OUT NUMBER);

END MRP_ATP_COLLECTION;

 

/
