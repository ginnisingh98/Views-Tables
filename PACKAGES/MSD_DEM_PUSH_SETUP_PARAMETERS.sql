--------------------------------------------------------
--  DDL for Package MSD_DEM_PUSH_SETUP_PARAMETERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_PUSH_SETUP_PARAMETERS" AUTHID CURRENT_USER AS
/* $Header: msddempsps.pls 120.0.12010000.4 2009/03/31 12:40:41 nallkuma ship $ */


   /*** PROCEDURES ***/

      /*
       * This procedure pushes the profile values, collection enabled orgs and
       * the time data in the source instance, which will be used in the source
       * views.
       */
      PROCEDURE PUSH_SETUP_PARAMETERS (
      			errbuf         		OUT  NOCOPY VARCHAR2,
      			retcode        		OUT  NOCOPY VARCHAR2,
      			p_sr_instance_id	IN	    NUMBER,
      			p_collection_group	IN	    VARCHAR2);
    /*
     * This procedure updates profiles values configure for a particular legacy instance
     * to the legacy profiles table - MSD_DEM_LEGACY_SETUP_PARAMS
     */
    PROCEDURE CONFIGURE_LEGACY_PROFILES (
      			errbuf         		OUT  NOCOPY VARCHAR2,
      			retcode        		OUT  NOCOPY VARCHAR2,
      			p_legacy_instance_id	IN	    NUMBER,
      			p_master_org            IN      NUMBER,
                p_sr_category_set_id       IN      NUMBER);

    /*
     * This procedure pushes profiles values for a particular legacy instance
     * from legacy profiles table - MSD_DEM_LEGACY_SETUP_PARAMS to setup parameters table - MSD_DEM_SETUP_PARAMETERS
     */
    PROCEDURE PUSH_LEGACY_SETUP_PARAMETERS (
      			errbuf         		OUT  NOCOPY VARCHAR2,
      			retcode        		OUT  NOCOPY VARCHAR2,
      			p_legacy_instance_id	IN	    NUMBER);


END MSD_DEM_PUSH_SETUP_PARAMETERS;

/
