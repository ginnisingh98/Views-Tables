--------------------------------------------------------
--  DDL for Package MRP_ATP_RES_SUPPLY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_ATP_RES_SUPPLY" AUTHID CURRENT_USER AS
/* $Header: MRPATPRS.pls 115.1 2002/11/29 13:43:35 rashteka ship $  */
PROCEDURE Calculate_Resource_Supply(
	                ERRBUF              OUT NOCOPY VARCHAR2, --2663505
			RETCODE             OUT NOCOPY NUMBER,   --2663505
			v_org_id	    IN  NUMBER,
			v_all_res           IN  NUMBER,
			v_dummy             IN  NUMBER,
			v_res_group         IN  VARCHAR2,
			v_simulation_set    IN  VARCHAR2,
			v_cutoff_date       IN  VARCHAR2);

END MRP_ATP_RES_SUPPLY;

 

/
