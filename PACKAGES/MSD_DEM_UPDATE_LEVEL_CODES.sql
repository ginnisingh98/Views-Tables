--------------------------------------------------------
--  DDL for Package MSD_DEM_UPDATE_LEVEL_CODES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_UPDATE_LEVEL_CODES" AUTHID CURRENT_USER AS
/* $Header: msddemupdlvs.pls 120.0.12010000.3 2009/04/15 10:17:07 sjagathe ship $ */

procedure update_code(errbuf              OUT NOCOPY VARCHAR2,
                      retcode             OUT NOCOPY VARCHAR2,
                      p_instance_id        IN  NUMBER,
                      p_level              IN VARCHAR2,
                      p_dest_table_name		 IN VARCHAR2,
                      p_dest_column_name   IN VARCHAR2,
                      p_src_coulmn_name    IN VARCHAR2);


   /*
    * This procedure converts the level code format from descriptive to integer format based upon the
    * given parameters.
    * If p_convert_type = 1, then change from new to old (descriptive)
    * If p_convert_type = 2, then change from old to new
    */
   PROCEDURE CONVERT_SITE_CODE (
   					errbuf              	OUT NOCOPY 	VARCHAR2,
                    retcode             	OUT NOCOPY 	VARCHAR2,
                    p_sr_instance_id        IN  		NUMBER,
                    p_level              	IN 			VARCHAR2,
                    p_dest_table_name		IN 			VARCHAR2,
                    p_dest_column_name   	IN 			VARCHAR2,
                    p_convert_type    		IN 			NUMBER);


   /*
    * This procedure updates the level codes from descriptive to id format. The levels are -
    * SITE, ACCOUNT, CUSTOMER, SUPPLIER, TRADING PARTNER ZONE
    *
    * This is an upgrade procedure hence proper backup of the Demantra Schema must be taken
    * before running this procedure.
    *
    * This procedure must be run once for each instance for which data is available inside
    * Demantra.
    *
    * This procedure creates a backup copy of the tables before updating them.
    *
    * The Demantra Application Server should be down when the procedure is run.
    *
    * Once the procedure has finished, bring up the Demantra Application Server and verify data.
    *
    * Run Data Load and verify data.
    */
    PROCEDURE UPGRADE_GEO_LEVEL_CODES (
    				errbuf              	OUT NOCOPY 	VARCHAR2,
                    retcode             	OUT NOCOPY 	VARCHAR2,
                    p_sr_instance_id        IN  		NUMBER);

END MSD_DEM_UPDATE_LEVEL_CODES;


/
