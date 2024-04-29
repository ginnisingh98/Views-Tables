--------------------------------------------------------
--  DDL for Package Body MRP_ATP_RES_SUPPLY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_ATP_RES_SUPPLY" AS
/* $Header: MRPATPRB.pls 120.1 2006/02/15 17:27:50 schaudha noship $  */
PROCEDURE Calculate_Resource_Supply(
		        ERRBUF              OUT NOCOPY VARCHAR2, --2663505
			RETCODE             OUT NOCOPY NUMBER,   --2663505
			v_org_id	    IN  NUMBER,
			v_all_res           IN  NUMBER,
			v_dummy             IN  NUMBER,
			v_res_group         IN  VARCHAR2,
			v_simulation_set    IN  VARCHAR2,
			v_cutoff_date       IN  VARCHAR2)
IS
  v_start_date  NUMBER;
  v_end_date    NUMBER;
  v_stmt        NUMBER;
  G_MRP_DEBUG   VARCHAR2(1); /*2663505*/
BEGIN
 /* Removed the code as this procedure is not referenced anywhere.
    Its just a stub */
  NULL;
END Calculate_Resource_Supply;

END MRP_ATP_RES_SUPPLY;


/
