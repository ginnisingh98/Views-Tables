--------------------------------------------------------
--  DDL for Package MSD_DEM_SOP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_SOP" AUTHID DEFINER AS
/* $Header: msddemsops.pls 120.2.12010000.5 2010/02/15 13:04:19 syenamar ship $ */


   /*** GLOBAL VARIABLES ***/
   G_YES 		NUMBER	:= MSD_DEM_COMMON_UTILITIES.C_YES;
   G_NO			NUMBER	:= MSD_DEM_COMMON_UTILITIES.C_NO;
   G_SCI_BACKLOG 	NUMBER 	:= 1;
   G_SCI_OTHER   	NUMBER 	:= 2;
   /* MSD DEM Debug Profile Value */
   C_MSD_DEM_DEBUG   		VARCHAR2(1)   := nvl( fnd_profile.value( 'MSD_DEM_DEBUG_MODE'), 'N');
   C_MSD_DEM_PUSH_TIME		VARCHAR2(1)   := 'Y';
   /* ASCP Series Ids */
   C_MSD_DEM_SOP_ITEM_COST      NUMBER := 111;



   /*** PROCEDURES ***
    * SET_PLAN_ATTRIBUTES
    * LOAD_PLAN_DATA
    * LOAD_PLAN_MEMBERS
    * POST_DOWNLOAD_HOOK
    * LOAD_ITEM_COST
    * WAIT_UNTIL_DOWNLOAD_COMPLETE
    * COLLECT_SCI_DATA
    * LAUNCH_SCI_DATA_LOADS
    */


      /*
       *
       */
      PROCEDURE SET_PLAN_ATTRIBUTES (
      			p_member_id			IN	   NUMBER );


      /*
       *
       */
      PROCEDURE LOAD_PLAN_DATA (
      			p_member_id			IN	   NUMBER,
                p_delete_item_pop   IN   BOOLEAN default TRUE);


      /*
       *
       */
      PROCEDURE LOAD_PLAN_MEMBERS;


      /*
       *
       */
      PROCEDURE POST_DOWNLOAD_HOOK (
      			p_member_id			IN	   NUMBER );


      /*
       * This procedure loads item cost information from planning server ODS
       * for all DM enabled organizations into the import integration
       * staging table - BIIO_ITEM_COST
       */
      PROCEDURE LOAD_ITEM_COST;


      /*
       * This procedure is called by the Wait step of the Download Plan Scenario Data workflow.
       *
       */
      PROCEDURE WAIT_UNTIL_DOWNLOAD_COMPLETE (
      			p_wait_step_id		IN		VARCHAR2	DEFAULT '',
      			p_exception_step_id	IN		VARCHAR2	DEFAULT '');


      /*
       *
       */
      PROCEDURE COLLECT_SCI_DATA (
      			errbuf				OUT NOCOPY VARCHAR2,
      			retcode				OUT NOCOPY VARCHAR2,
      			p_sr_instance_id		IN	   NUMBER,
      			p_collection_group      	IN         VARCHAR2 DEFAULT '-999',
      			p_collection_method     	IN         NUMBER,
      			p_hidden_param1			IN	   VARCHAR2,
      			p_date_range_type		IN	   NUMBER,
      			p_collection_window		IN	   NUMBER,
      			p_from_date			IN	   VARCHAR2,
      			p_to_date			IN	   VARCHAR2 );


      /*
       *
       */
      PROCEDURE LAUNCH_SCI_DATA_LOADS (
      			errbuf				OUT NOCOPY VARCHAR2,
      			retcode				OUT NOCOPY VARCHAR2,
      			p_sr_instance_id		IN	   NUMBER,
      			p_collection_group      	IN         VARCHAR2 DEFAULT '-999',
      			p_collection_method     	IN         NUMBER,
      			p_date_range_type		IN	   NUMBER,
      			p_collection_window		IN	   NUMBER,
      			p_from_date			IN	   VARCHAR2,
      			p_to_date			IN	   VARCHAR2,
      			p_entity                        IN         NUMBER );

END MSD_DEM_SOP;

/
