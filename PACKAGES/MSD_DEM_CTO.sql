--------------------------------------------------------
--  DDL for Package MSD_DEM_CTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_CTO" AUTHID CURRENT_USER AS
/* $Header: msddemctos.pls 120.1.12010000.5 2010/03/23 09:28:51 sjagathe noship $ */

   /*** GLOBAL VARIABLES ***/
   G_YES 	NUMBER	:= MSD_DEM_COMMON_UTILITIES.C_YES;
   G_NO		NUMBER	:= MSD_DEM_COMMON_UTILITIES.C_NO;



   /*** PROCEDURES ***
    *
    * POPULATE_STAGING_TABLE
    * COLLECT_MODEL_BOM_COMPONENTS
    * PURGE_CTO_GL_DATA
    *
    *** PROCEDURES  ***/


   /*
    * Given the entity name, this procedure runs the query for the entity name.
    * Usually this procedure will be used to populate the Demantra CTO staging tables.
    */
   PROCEDURE POPULATE_STAGING_TABLE (
   			    errbuf			OUT NOCOPY 	VARCHAR2,
      			retcode			OUT NOCOPY 	VARCHAR2,
      			p_entity_name		IN		VARCHAR2,
      			p_sr_instance_id	IN		NUMBER,
      			p_for_cto		IN		NUMBER DEFAULT 1);


   /*
    * This procedure populates the table msd_dem_model_bom_components for the base models
    * available in the sales staging table.
    */
   PROCEDURE COLLECT_MODEL_BOM_COMPONENTS (
            errbuf			OUT NOCOPY 	VARCHAR2,
      			retcode			OUT NOCOPY 	VARCHAR2,
      			p_sr_instance_id	IN		NUMBER,
            p_flat_file_load	IN		NUMBER DEFAULT 2 );


   /*
    * This procedure deletes all data from CTO GL Tables. This should only be run by
    * an admin user. The user must make sure that the Demantra AS is down before running
    * the procedure.
    * The procedure is used when the CTO related profile options have been changed which
    * result in changes to the bom structure brought into Demantra.
    *
    * Parameters -
    *    p_complete_refresh - If 1, then all data from CTO GL tables are deleted
    *                       - If 2, do nothing.
    */
   PROCEDURE PURGE_CTO_GL_DATA (
                errbuf              	OUT NOCOPY 	VARCHAR2,
                retcode             	OUT NOCOPY 	VARCHAR2,
                p_complete_refresh	IN		NUMBER );


END MSD_DEM_CTO;

/
