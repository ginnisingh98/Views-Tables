--------------------------------------------------------
--  DDL for Package Body MSD_WS_DEM_RENAME_FORECAST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_WS_DEM_RENAME_FORECAST" AS
/* $Header: MSDWDRFB.pls 120.10.12010000.8 2009/05/19 05:31:58 lannapra ship $ */


   /*** PROCEDURES & FUNCTIONS ***
    * ASSIGN_PLAN_NAME_TO_FORECAST
    * ASSIGN_PLAN_NAME_TO_FORECAST_C
    * GET_PLAN_SCENARIO_MEMBER_ID
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
                   ArchiveFlag          IN              NUMBER)
       IS

          TYPE CUR_TYPE	IS REF CURSOR;
          x_cur_type		CUR_TYPE;

          x_sql_stmt			VARCHAR2(2000)	:= NULL;

          x_new_plan_name		VARCHAR2(45)	:= NULL;
          x_data_profile_name		VARCHAR2(200) 	:= NULL;

          x_archive_flag                NUMBER          := NULL;
          x_data_profile_id		NUMBER		:= NULL;
          x_scenario_id			NUMBER		:= NULL;

          /* For Planning Hub */
          x_errbuf			VARCHAR2(1000)	:= NULL;
          x_retcode			VARCHAR2(1000)  := NULL;
          x_plan_run_id			NUMBER		:= NULL;

       BEGIN


          x_new_plan_name     := substr(NewPlanName, 1, 45);
          x_data_profile_name := DataProfileName;
          x_archive_flag      := ArchiveFlag;


          /* Check if the Data Profile Name specified is present inside Demantra or not */
          x_sql_stmt := 'SELECT nvl(sum(tq.id), 0) '
                        || ' FROM msd_dem_transfer_query tq '
                        || ' WHERE tq.query_name = ''' || x_data_profile_name || ''''
                        || '   AND msd_dem_upload_forecast.is_valid_scenario(tq.id) = 1 ';
          EXECUTE IMMEDIATE x_sql_stmt INTO x_data_profile_id;


          IF (x_data_profile_id <> 0)
          THEN


             /* Check if the given New Plan Name already exists */
             x_sql_stmt := 'SELECT nvl(sum(scenario_id), 0) '
                           || ' FROM msd_dp_scenarios mds '
                           || ' WHERE mds.demand_plan_id = ' || MSD_DEM_UPLOAD_FORECAST.C_DEMAND_PLAN_ID
                           || '   AND mds.scenario_name  = ''' || x_new_plan_name || '''';
            EXECUTE IMMEDIATE x_sql_stmt INTO x_scenario_id;


            /* Create/Update an entry for the Plan Name in the table msd_dp_scenarios */
            IF (x_scenario_id = 0) THEN

               SELECT MSD_DP_SCENARIOS_S.nextval
                  INTO x_scenario_id
                  FROM DUAL;
               x_scenario_id := x_scenario_id + C_DUMMY_SCENARIO_ID_OFFSET;

               INSERT INTO msd_dp_scenarios (
               		demand_plan_id,
               		scenario_id,
               		scenario_name,
               		forecast_based_on,
               		sc_type,
               		error_type,
               		associate_parameter,
               		last_update_date,
               		last_updated_by,
               		creation_date,
               		created_by )
               		VALUES (
               		   MSD_DEM_UPLOAD_FORECAST.C_DEMAND_PLAN_ID,
               		   x_scenario_id,
               		   x_new_plan_name,
               		   substr(x_data_profile_name,1,30),
               		   msd_dem_upload_forecast.is_global_scenario(x_data_profile_id),
               		   msd_dem_upload_forecast.get_error_type(x_data_profile_id),
               		   C_ASSOCIATE_PARAMETER,
               		   sysdate,
               		   FND_GLOBAL.USER_ID,
               		   sysdate,
               		   FND_GLOBAL.USER_ID);

            ELSE

               UPDATE msd_dp_scenarios
               SET
                  forecast_based_on = substr(x_data_profile_name,1,30),
                  sc_type = msd_dem_upload_forecast.is_global_scenario(x_data_profile_id),
                  error_type = msd_dem_upload_forecast.get_error_type(x_data_profile_id),
                  last_update_date = sysdate,
                  last_updated_by = FND_GLOBAL.USER_ID
               WHERE scenario_id = x_scenario_id;

               DELETE FROM msd_dp_scenario_output_levels
               WHERE scenario_id = x_scenario_id;

               DELETE FROM msd_dp_scn_entries_denorm
               WHERE scenario_id = x_scenario_id;

            END IF;


            /* Populate output levels for the forecast data */
            INSERT INTO msd_dp_scenario_output_levels (
            	demand_plan_id,
            	scenario_id,
            	level_id,
            	last_update_date,
            	last_updated_by,
            	creation_date,
            	created_by )
            	SELECT
            	   MSD_DEM_UPLOAD_FORECAST.C_DEMAND_PLAN_ID,
            	   x_scenario_id,
            	   to_number(flv.lookup_code),
            	   sysdate,
               	   FND_GLOBAL.USER_ID,
               	   sysdate,
               	   FND_GLOBAL.USER_ID
               	FROM
                   msd_dem_transfer_query tq,
                   msd_dem_transfer_query_levels tql,
                   msd_dem_group_tables gt,
                   fnd_lookup_values_vl flv
                WHERE
                       tq.id = x_data_profile_id
                   AND tql.id = tq.id
                   AND gt.group_table_id = tql.level_id
                   AND flv.lookup_type = 'MSD_DEM_LEVELS'
                   AND to_number(msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                          flv.meaning,
                                                                          1,
                                                                          'group_table_id')) = gt.group_table_id;


            /* Update the scenario id in the denorm table */
            UPDATE msd_dp_scn_entries_denorm
               SET scenario_id = x_scenario_id
               WHERE scenario_id = MSD_DEM_UPLOAD_FORECAST.C_SCENARIO_ID_OFFSET + x_data_profile_id;

          ELSE
             status := 'INVALID_DATA_PROFILE';
             RETURN;
          END IF;

          COMMIT;
          status := 'SUCCESS';


          /* For Planning Hub */
          msc_phub_pkg.populate_demantra_details (
          				x_errbuf,
          				x_retcode,
          				x_scenario_id,
          				x_plan_run_id,
          				x_archive_flag );

          IF (x_retcode <> '0')
          THEN
             status := 'ERROR';
          END IF;

       EXCEPTION
          WHEN OTHERS THEN
             status := 'ERROR';
             RETURN;


       END ASSIGN_PLAN_NAME_TO_FORECAST;




       PROCEDURE ASSIGN_PLAN_NAME_PUBLIC (
                   status		OUT NOCOPY 	VARCHAR2,
                   UserName               IN VARCHAR2,
		   RespName     IN VARCHAR2,
		   RespApplName IN VARCHAR2,
		   SecurityGroupName      IN VARCHAR2,
		   Language            IN VARCHAR2,
                   NewPlanName		IN		VARCHAR2,
                   DataProfileName	IN		VARCHAR2,
                   ArchiveFlag          IN              NUMBER ) AS
  userid    number;
  respid    number;
  l_String VARCHAR2(30);
  error_tracking_num number;
  l_SecutirtGroupId  NUMBER;
 BEGIN
   error_tracking_num :=2010;
    MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, userid, respid, l_SecutirtGroupId, UserName, RespName, RespApplName, SecurityGroupName, Language);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

     error_tracking_num :=2030;
    MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSD_DEM_WF_MGR', l_SecutirtGroupId);
   IF (l_String <> 'OK') THEN
       Status := l_String;
      RETURN;
   END IF;
    error_tracking_num :=2040;


  ASSIGN_PLAN_NAME_TO_FORECAST( Status,
                                NewPlanName,
                                DataProfileName,
                                ArchiveFlag );



      EXCEPTION
      WHEN others THEN
         status := 'ERROR_UNEXPECTED_'||error_tracking_num;

         return;


END ASSIGN_PLAN_NAME_PUBLIC;

      /*
       *   Procedure Name - ASSIGN_PLAN_NAME_TO_FORECAST_C
       *      This procedure calls the procedure ASSIGN_PLAN_NAME_TO_FORECAST
       *      This is used in the assign plan name concurrent program
       */
 PROCEDURE ASSIGN_PLAN_NAME_TO_FORECAST_C(
 			errbuf out NOCOPY varchar2,
  			retcode out NOCOPY varchar2,
                   	NewPlanName		IN		VARCHAR2,
                   	DataProfileName		IN		VARCHAR2,
                   	ArchiveFlag             IN              NUMBER default 1 )
       IS
	 x_status VARCHAR2(10) := NULL;
       BEGIN
       ASSIGN_PLAN_NAME_TO_FORECAST(x_status,NewPlanName,DataProfileName,ArchiveFlag);
       if x_status <> 'SUCCESS' then
       retcode := -1;
       end if;
       EXCEPTION
       WHEN OTHERS THEN
            retcode := -1;
             RETURN;
       END ASSIGN_PLAN_NAME_TO_FORECAST_C;

      /*
       *   Procedure Name - PUSH_ODS_DATA
       *  This procedure is made use of in the workflow- Export OBI Data to push
       *  demantra ODS data to APCC table- msc_demantra_ods_f
       *  It is a wrapper to APCC procedure - msc_phub_pkg.populate_demantra_ods.
       */

   PROCEDURE PUSH_ODS_DATA
   IS
    /* For Planning Hub */
          x_errbuf			VARCHAR2(1000)	:= NULL;
          x_retcode			VARCHAR2(1000)  := NULL;
	  x_small_sql 			VARCHAR2(200)   := NULL;
          x_schema 			VARCHAR2(30)    := NULL;

   BEGIN
           /* Alter session to APPS */
           x_schema := msd_dem_demantra_utilities.get_demantra_schema;
           x_small_sql := 'alter session set current_schema = APPS';
           EXECUTE IMMEDIATE x_small_sql;
           msc_phub_pkg.populate_demantra_ods(x_errbuf,
        			      x_retcode);
	       /* Alter session to demantra schema */
           x_small_sql := 'alter session set current_schema = ' || x_schema;
           EXECUTE IMMEDIATE x_small_sql;


   IF (x_retcode <> '0')
   THEN
     msd_dem_demantra_utilities.log_message ('The procedure MSD_WS_DEM_RENAME_FORECAST.PUSH_ODS_DATA failed with the following error : '||x_errbuf);
   END IF;
   EXCEPTION
       WHEN OTHERS THEN
        /* Alter session to demantra schema */
                   x_small_sql := 'alter session set current_schema = ' || x_schema;
                   EXECUTE IMMEDIATE x_small_sql;
        msd_dem_demantra_utilities.log_message ('The procedure MSD_WS_DEM_RENAME_FORECAST.PUSH_ODS_DATA failed with  error : '||SQLCODE||' -ERROR- '||SQLERRM);
   END PUSH_ODS_DATA;


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
          RETURN NUMBER
       IS

          x_member_id	NUMBER	:= NULL;

       BEGIN

          EXECUTE IMMEDIATE ' SELECT supply_plan_id '
                            || '    FROM ' || fnd_profile.value('MSD_DEM_SCHEMA') || '.supply_plan sp'
                            || '    WHERE sp.plan_id = ' || PlanId
             INTO x_member_id;

          RETURN x_member_id;

       EXCEPTION
          WHEN OTHERS THEN
             RETURN -1;

       END GET_PLAN_SCENARIO_MEMBER_ID;

                    /*
       *  Procedure Name - REFRESH_MVIEW
       *      Given the name of a materialized view, this procedure refreshed the mview
       *
       *   Parameters -
       *     MviewName - Name of the materialized view
       *
       */
       PROCEDURE REFRESH_MVIEW(
       			mviewname IN VARCHAR2)
       IS

        x_small_sql VARCHAR2(200) := NULL;
        x_schema VARCHAR2(30) := NULL;

        BEGIN

          /* Alter session to APPS */
          x_schema := apps.fnd_profile.VALUE('MSD_DEM_SCHEMA');
          x_small_sql := 'alter session set current_schema = APPS';
          EXECUTE IMMEDIATE x_small_sql;

          /*Refresh the mview */
          dbms_mview.refresh(upper(mviewname),   'C');

          /* Alter session to demantra schema */
          x_small_sql := 'alter session set current_schema = ' || x_schema;
          EXECUTE IMMEDIATE x_small_sql;

        EXCEPTION
        WHEN others THEN
          x_small_sql := 'alter session set current_schema = ' || x_schema;
          EXECUTE IMMEDIATE x_small_sql;

       END REFRESH_MVIEW;
       /*
       *  Procedure Name - DROP_MVIEW
       *      Given the name of a materialized view, this procedure drops the mview
       *
       *   Parameters -
       *     MviewName - Name of the materialized view
       *
       */
 PROCEDURE DROP_MVIEW(
	mviewname IN VARCHAR2)
 IS

   x_small_sql VARCHAR2(200) := NULL;
   x_schema VARCHAR2(30) := NULL;
   x_mview VARCHAR2(30) := NULL;
   x_drop_mview_sql  VARCHAR2(300) := NULL;

 BEGIN

     x_schema := apps.fnd_profile.VALUE('MSD_DEM_SCHEMA');

    /*Check if the Materialized view exists*/
   SELECT object_name into x_mview
   FROM dba_objects
   WHERE owner = x_schema
    AND object_type = 'MATERIALIZED VIEW'
    AND object_name = upper(mviewname)
   ORDER BY created DESC;
   /*If the meview is present, drop it*/
   IF (x_mview IS NOT NULL)
      THEN
        x_drop_mview_sql := 'DROP MATERIALIZED VIEW '||x_schema||'.'||mviewname;
         EXECUTE IMMEDIATE x_drop_mview_sql;
         END IF;



   EXCEPTION
   WHEN others THEN
      x_small_sql := 'alter session set current_schema = ' || x_schema;
          EXECUTE IMMEDIATE x_small_sql;
 END DROP_MVIEW;



END MSD_WS_DEM_RENAME_FORECAST;

/
