--------------------------------------------------------
--  DDL for Package MSD_WS_DEM_RENAME_FORECAST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_WS_DEM_RENAME_FORECAST" AUTHID DEFINER AS
/* $Header: MSDWDRFS.pls 120.7.12010000.7 2009/10/28 12:06:36 lannapra ship $ */

   /*** CONSTANTS ***/
   C_DUMMY_SCENARIO_ID_OFFSET		NUMBER	:= 8888888;
   C_ASSOCIATE_PARAMETER VARCHAR2(100) := 'Assign Plan Name';



   /*** PROCEDURES & FUNCTIONS ***
    * ASSIGN_PLAN_NAME_TO_FORECAST
    * GET_PLAN_SCENARIO_MEMBER_ID
    * REFRESH_MVIEW
    */

      /*
       *   Procedure Name - ASSIGN_PLAN_NAME_TO_FORECAST
       *      This procedure assigns a user specified name to the forecast
       *      uploaded from Demantra into the MSD_DP_SCN_ENTRIES_DENORM table.
       *
       *   Parameters -
       *      NewPlanName     - Name to be assigned to the recently exported
       *                        forecast output.
       *      DataProfileName - Name of the Data Profile used to export
       *                        forecast out of Demantra
       *
       *      Given the parameter NewPlanName, create (or replace) an entry in the table MSD_DP_SCENARIOS.
       *         Demand Plan Id - (Hardcoded to) 5555555
       *         Scenario Id    - Sequence starting from 8888888
       *
       *      Using the DataProfileName, populate the table MSD_DP_SCENARIO_OUTPUT_LEVELS with
       *      the levels at which the forecast has been exported.
       *
       *      Update the scenario id in the MSD_DP_SCN_ENTRIES_DENORM table to the Scenario Id generated
       *      for the given Plan Name.
       *
       *   Return Values -
       *      The procedure returns a status. The possible return statuses are:
       *         SUCCESS, ERROR, INVALID_DATA_PROFILE
       *
       */
       PROCEDURE ASSIGN_PLAN_NAME_TO_FORECAST (
                   status		OUT NOCOPY 	VARCHAR2,
                   NewPlanName		IN		VARCHAR2,
                   DataProfileName	IN		VARCHAR2,
                   ArchiveFlag          IN              NUMBER );

       PROCEDURE ASSIGN_PLAN_NAME_PUBLIC (
                          status		OUT NOCOPY 	VARCHAR2,
                          UserName               IN VARCHAR2,
       		          RespName     IN VARCHAR2,
       		          RespApplName IN VARCHAR2,
       		          SecurityGroupName      IN VARCHAR2,
       		          Language            IN VARCHAR2,
                          NewPlanName		IN		VARCHAR2,
                          DataProfileName	IN		VARCHAR2,
                          ArchiveFlag          IN              NUMBER );

 /*
       *   Procedure Name - ASSIGN_PLAN_NAME_TO_FORECAST
       *  This  is made use of in the assign plan name concurrent program
*/

 PROCEDURE ASSIGN_PLAN_NAME_TO_FORECAST_C (
 			errbuf out NOCOPY varchar2,
  			retcode out NOCOPY varchar2,
                   	NewPlanName		IN		VARCHAR2,
                   	DataProfileName		IN		VARCHAR2,
                   	ArchiveFlag          	IN              NUMBER default 1);

      /*
       *  Procedure Name - PUSH_ODS_DATA
       *  This  procedure is made use of in the workflow- Export OBI Data
       *  to push demantra ODS data from export profile mview to the APCC table - msc_demantra_ods_f.
       *  It is a wrapper to APCC procedure - msc_phub_pkg.populate_demantra_ods.
       */

       PROCEDURE PUSH_ODS_DATA;

      /*
       *   Function Name - GET_PLAN_SCENARIO_MEMBER_ID
       *      Given the id of a supply plan in ASCP, this function gets the plan scenario member id
       *      from Demantra.
       *
       *   Parameters -
       *      PlanId     - ID of the supply plan from the table MSC_PLANS.
       *
       *   Return Values -
       *      The procedure returns the plan scenario member ID in Demantra. If not found or in case
       *      of any error it returns -1.
       *
       */
       FUNCTION GET_PLAN_SCENARIO_MEMBER_ID (
                   PlanId	IN		NUMBER )
          RETURN NUMBER;

        /*
       *  Procedure Name - REFRESH_MVIEW
       *      Given the name of a materialized view, this procedure refreshed the mview
       *
       *   Parameters -
       *     MviewName - ame of the materialized view
       *
       */
       PROCEDURE REFRESH_MVIEW (
                   MviewName	IN		VARCHAR2 );

       /*
       *  Procedure Name - DROP_MVIEW
       *      Given the name of a materialized view, this procedure drops the mview
       *
       *   Parameters -
       *     MviewName - Name of the materialized view
       *
       */
PROCEDURE drop_mview(
	mviewname IN   VARCHAR2);


/*
        *   Procedure Name - UPDATE_DEM_APCC_SYNONYM
        *   This procedure creates the required dummy objets for APCC
        *     1) Checks if demantra is installed and the mview created
        *     1.1.a) If mview is available, drop it.
        *     1.1.b) Create a new mview with the same name - BIEO_OBI_MV
        *     1.2) If demantra is not installed, and dummy table available
        *     1.2.a) Drop the dummy table
        *     1.2.b) Create the dummy table - MSD_DEM_BIEO_OBI_MV_DUMMY
        *     2) Create synonym MSD_DEM_BIEO_OBI_MV_SYN accordingly.
        *
        */


END MSD_WS_DEM_RENAME_FORECAST;

/
