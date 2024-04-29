--------------------------------------------------------
--  DDL for Package Body MSD_DEM_SOP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_SOP" AS
/* $Header: msddemsopb.pls 120.17.12010000.18 2010/03/09 15:52:17 syenamar ship $ */


   /*** CUSTOM DATA TYPES ***/


   /*** CONSTANTS ***/


   /*** GLOBAL VARIABLES ***/
      g_schema			VARCHAR(50)	:= NULL;


   /*** PRIVATE FUNCTIONS ***
    * GET_PLAN_ID
    * GET_PLAN_TYPE
    */


      /*
       * This functions returns the plan_id in msc_plans given
       * the member_id of a supply plan
       * param: p_member_id - member_id of the supply plan level member
       */
       FUNCTION GET_PLAN_ID ( p_member_id	IN	NUMBER )
       RETURN NUMBER
       IS
          x_plan_id			NUMBER		:= NULL;
       BEGIN

          EXECUTE IMMEDIATE 'SELECT plan_id FROM ' ||
                               msd_dem_common_utilities.get_lookup_value ('MSD_DEM_TABLES', 'SUPPLY_PLAN') ||
                               ' WHERE supply_plan_id = ' || p_member_id
             INTO x_plan_id;

          RETURN x_plan_id;

       EXCEPTION
          WHEN OTHERS THEN
             RETURN NULL;

       END GET_PLAN_ID;


      /*
       * This functions returns the plan_type given
       * the member_id of a supply plan
       * param: p_member_id - member_id of the supply plan level member
       */
       FUNCTION GET_PLAN_TYPE ( p_member_id	IN	NUMBER )
       RETURN NUMBER
       IS
          x_plan_type			NUMBER		:= NULL;
       BEGIN

          EXECUTE IMMEDIATE 'SELECT plan_type FROM ' ||
                               msd_dem_common_utilities.get_lookup_value ('MSD_DEM_TABLES', 'SUPPLY_PLAN') ||
                               ' WHERE supply_plan_id = ' || p_member_id
             INTO x_plan_type;

          RETURN x_plan_type;

       EXCEPTION
          WHEN OTHERS THEN
             RETURN NULL;

       END GET_PLAN_TYPE;




   /*** PRIVATE PROCEDURES ***
    * LOG_DEBUG
    * LOG_MESSAGE
    * TRUNCATE_STAGING_TABLES
    * LOAD_SERIES_DATA
    * PRE_DOWNLOAD_HOOK
    * LOAD_ASCP_DATA
    * PUSH_TIME_DATA
    * LOAD_SUP_PLAN_GL
    * LOAD_PLAN_GL
    * LOAD_RESOURCE_GL
    * LOAD_ITEM_LOCS
    */


      /*
       * This procedure logs a given debug message text in ???
       * only if the profile MSD_DEM_DEBUG is set to 'Yes'.
       * param: p_buff - debug message text to be logged.
       */
       PROCEDURE LOG_DEBUG ( p_buff           IN  VARCHAR2)
       IS
       BEGIN
          IF (C_MSD_DEM_DEBUG = 'Y') THEN
             NULL;

/***** REMOVE AFTER USE *****/
/***** INS IN SJ_T1 VAL (p_buff); *****/
/***** REMOVE AFTER USE *****/

          END IF;

       END LOG_DEBUG;



      /*
       * This procedure logs a given message text in ???
       * param: p_buff - message text to be logged.
       */
       PROCEDURE LOG_MESSAGE ( p_buff           IN  VARCHAR2)
       IS
       BEGIN
          NULL;

/***** REMOVE AFTER USE *****/
/***** INS IN SJ_T1 VAL (p_buff); *****/
/***** REMOVE AFTER USE *****/

       END LOG_MESSAGE;



       /*
        * This procedure truncates all the staging tables for ascp plan related series
        * NOTE: Must be called ONLY after global variable g_schema has been set.
        */
       PROCEDURE TRUNCATE_STAGING_TABLES (
       				errbuf			OUT NOCOPY 	VARCHAR2,
       				retcode			OUT NOCOPY 	VARCHAR2)
       IS
          x_table_name		VARCHAR2(60)	:= NULL;
       BEGIN

          log_debug ('Entering: msd_dem_sop.truncate_staging_tables - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));


          x_table_name := g_schema || '.BIIO_RESOURCE_CAPACITY';
          log_message ('Truncating table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||  x_table_name;

          x_table_name := g_schema || '.BIIO_RESOURCE_CAPACITY_ERR';
          log_message ('Truncating table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||  x_table_name;

          x_table_name := g_schema || '.BIIO_OTHER_PLAN_DATA';
          log_message ('Truncating table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||  x_table_name;

          x_table_name := g_schema || '.BIIO_OTHER_PLAN_DATA_ERR';
          log_message ('Truncating table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||  x_table_name;

          x_table_name := g_schema || '.BIIO_PURGE_PLAN';
          log_message ('Truncating table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||  x_table_name;

          x_table_name := g_schema || '.BIIO_PURGE_PLAN_ERR';
          log_message ('Truncating table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||  x_table_name;

          x_table_name := g_schema || '.BIIO_PURGE_PLAN_RESOURCE';
          log_message ('Truncating table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||  x_table_name;

          x_table_name := g_schema || '.BIIO_PURGE_PLAN_RESOURCE_ERR';
          log_message ('Truncating table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||  x_table_name;

          x_table_name := g_schema || '.BIIO_RESOURCES';
          log_message ('Truncating table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||  x_table_name;

          x_table_name := g_schema || '.BIIO_RESOURCES_ERR';
          log_message ('Truncating table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||  x_table_name;

          x_table_name := g_schema || '.BIIO_SCENARIO_RESOURCES';
          log_message ('Deleting data from table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'DELETE FROM ' ||  x_table_name;

          x_table_name := g_schema || '.BIIO_SCENARIO_RESOURCES_ERR';
          log_message ('Truncating table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||  x_table_name;

          x_table_name := g_schema || '.BIIO_SCENARIO_RESOURCE_POP';
          log_message ('Truncating table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||  x_table_name;

          x_table_name := g_schema || '.BIIO_SCENARIO_RESOURCE_POP_ERR';
          log_message ('Truncating table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||  x_table_name;

          x_table_name := g_schema || '.BIIO_SUPPLY_PLANS';
          log_message ('Deleting data from table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'DELETE FROM ' ||  x_table_name;

          x_table_name := g_schema || '.BIIO_SUPPLY_PLANS_ERR';
          log_message ('Truncating table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||  x_table_name;

          x_table_name := g_schema || '.BIIO_SUPPLY_PLANS_POP';
          log_message ('Truncating table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||  x_table_name;

          x_table_name := g_schema || '.BIIO_SUPPLY_PLANS_POP_ERR';
          log_message ('Truncating table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||  x_table_name;

          x_table_name := g_schema || '.T_SRC_ITEM_TMPL';
          log_message ('Truncating table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||  x_table_name;

          x_table_name := g_schema || '.T_SRC_ITEM_TMPL_ERR';
          log_message ('Truncating table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||  x_table_name;

          x_table_name := g_schema || '.T_SRC_LOC_TMPL';
          log_message ('Truncating table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||  x_table_name;

          x_table_name := g_schema || '.T_SRC_LOC_TMPL_ERR';
          log_message ('Truncating table ' ||  x_table_name || ' ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||  x_table_name;

          log_debug ('Exiting: msd_dem_sop.truncate_staging_tables - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

       EXCEPTION
          WHEN OTHERS THEN
             retcode := -1;
             errbuf := substr(SQLERRM,1,150);
             log_message ('Exception(1): msd_dem_sop.truncate_staging_tables - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
             RETURN;
       END TRUNCATE_STAGING_TABLES;




       /*
        *
        */
       PROCEDURE LOAD_SERIES_DATA (
       				errbuf			OUT NOCOPY 	VARCHAR2,
       				retcode			OUT NOCOPY 	VARCHAR2,
       				p_series_id		IN		NUMBER,
       				p_plan_id		IN		NUMBER,
       				p_dm_time_level		IN		NUMBER)
       IS

          CURSOR c_get_series_info
          IS
             SELECT
                series_name,
                series_type,
                identifier,
                custom_view_name,
                ps_view_name,
                stg_series_col_name
                FROM
                   msd_dem_series
                WHERE
                   series_id = p_series_id;

         /*** LOCAL VARIABLES - BEGIN ***/

            x_errbuf			VARCHAR2(200)	:= NULL;
            x_retcode			VARCHAR2(100)	:= NULL;

            x_series_name		VARCHAR2(250)	:= NULL;
            x_series_type		NUMBER		:= NULL;
            x_identifier		VARCHAR2(30)	:= NULL;
            x_custom_view_name		VARCHAR2(30)	:= NULL;
            x_view_name			VARCHAR2(30)	:= NULL;
            x_is_custom			NUMBER		:= NULL;
            x_stg_series_col_name	VARCHAR2(30)	:= NULL;
            x_key_values	   	VARCHAR2(4000)	:= NULL;
            x_large_sql			VARCHAR2(32000) := NULL;


         /*** LOCAL VARIABLES - END ***/

       BEGIN
          log_debug ('Entering: msd_dem_sop.load_series_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

          /* Validate INPUT Parameters */
          IF (p_series_id IS NULL OR p_plan_id IS NULL)
          THEN
             log_message ('Error(1): msd_dem_sop.load_series_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS') ||
                         ' - One or Both the parameters passed to the procedure is/are NULL.');
             RETURN;
          END IF;


          /* Get Series Info */
          OPEN c_get_series_info;
          FETCH c_get_series_info INTO  x_series_name,
          				x_series_type,
          				x_identifier,
          				x_custom_view_name,
          				x_view_name,
          				x_stg_series_col_name;
          IF (   x_series_name IS NULL
              OR x_series_type IS NULL
              OR x_identifier IS NULL)
          THEN
             log_message ('Error(2): msd_dem_sop.load_series_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS') ||
                         ' - Unable to get series info for id - ' || to_char(p_series_id));
             RETURN;
          END IF;

          /* Check if custom view is specified for the series */
          IF (x_custom_view_name IS NULL)
          THEN
             x_is_custom := 0;
          ELSE
             x_is_custom := 1;
          END IF;


          IF (p_dm_time_level = 1)
          THEN
             x_key_values := '$C_PLAN_ID#' || to_char(p_plan_id)
                                || '$C_DEST_DATE#' || 'mdbr.sdate'
                                || '$C_SERIES_QTY#' || x_stg_series_col_name
                                || '$C_DEM_SCHEMA#' || g_schema
                                || '$C_TIME_CLAUSE#    $';
          ELSE
             x_key_values := '$C_PLAN_ID#' || to_char(p_plan_id)
                                || '$C_DEST_DATE#' || 'inp.datet'
                                || '$C_SERIES_QTY#' || x_stg_series_col_name
                                || '$C_DEM_SCHEMA#' || g_schema
                                || '$C_TIME_CLAUSE#' || ', msd_dem_dates inp WHERE mdbr.sdate BETWEEN inp.start_date AND inp.end_date$';
          END IF;

          /* Get the query */
          msd_dem_query_utilities.get_query3 (
          			x_retcode,
          			x_large_sql,
          			x_identifier,
          			null,
          			x_key_values,
          			x_is_custom,
          			x_custom_view_name,
          			x_series_type,
          			x_view_name);

          IF (x_retcode = -1)
          THEN
             log_message ('Error(3): msd_dem_sop.load_series_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS') ||
                         ' - Unable to get query for identifier - ' || x_identifier);
             RETURN;
          END IF;

          log_debug ('Query - ');
          log_debug (x_large_sql);

          log_debug ('Query Start Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

          BEGIN
             EXECUTE IMMEDIATE x_large_sql;
          EXCEPTION
             WHEN OTHERS THEN
                retcode := -1;
                errbuf := substr(SQLERRM,1,150);
                log_message ('Exception(1): msd_dem_sop.load_series_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
                RETURN;
          END;


          log_debug ('Query End Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

          log_debug ('Exiting: msd_dem_sop.load_series_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
       EXCEPTION
          WHEN OTHERS THEN
             retcode := -1;
             errbuf := substr(SQLERRM,1,150);
             log_message ('Exception(2): msd_dem_sop.load_series_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
             RETURN;
       END LOAD_SERIES_DATA;



       /*
        *
        */
       PROCEDURE PRE_DOWNLOAD_HOOK (
       				errbuf			OUT NOCOPY 	VARCHAR2,
       				retcode			OUT NOCOPY 	VARCHAR2,
       				p_plan_id		IN		NUMBER)
       IS

          CURSOR c_get_series_for_purge
          IS
             SELECT
                series_id
                FROM msd_dem_series
                WHERE series_id IN (112, 113);

          Cursor c_plan_start_date is
          select curr_start_date
          from msc_plans
          where plan_id = p_plan_id;


         /*** LOCAL VARIABLES - BEGIN ***/

	    x_errbuf			VARCHAR2(200)	:= NULL;
            x_retcode			VARCHAR2(100)	:= NULL;

	    l_plan_start_date 		date		:= NULL;
            x_to_date			date		:= NULL;
            x_from_date			date            := NULL;
            l_profile_id1 		number          := NULL;
            l_profile_id2 		number          := NULL;
            l_sql			varchar2(1000)	:= NULL;
            g_schema			varchar2(50)    := NULL;


         /*** LOCAL VARIABLES - END ***/

       BEGIN
          log_debug ('Entering: msd_dem_sop.pre_download_hook - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

          /***** 1. DECIDE UPON HOW TO HANDLE CONCURRENCY *****/
          /***** Handled in WAIT_UNTIL_DOWNLOAD_COMPLETE *****/


          /***** 2. Load rows for purging existing plan related data  *****/

          FOR rec IN c_get_series_for_purge
          LOOP
             log_debug ('Start Of Loop for series id - ' || to_number(rec.series_id) || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

             load_series_data (
             		x_errbuf,
             		x_retcode,
             		rec.series_id,
             		p_plan_id,
             		1);
             IF (x_retcode = -1)
             THEN
                retcode := -1;
                errbuf := x_errbuf;
                log_message ('Error(2): msd_dem_sop.pre_download_hook - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
                RETURN;
             END IF;

             log_debug ('End Of Loop for series id - ' || to_number(rec.series_id) || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          END LOOP;


          /***** 3. UPDATE START DATES AND END DATES OF THE PURGE PLAN DATA *****/

           OPEN c_plan_start_date;
           FETCH c_plan_start_date  INTO l_plan_start_date;
           CLOSE c_plan_start_date;



           g_schema := fnd_profile.value('MSD_DEM_SCHEMA');

           if (g_schema is not null)
           then

           	l_sql := 'select datet from '|| g_schema ||'.inputs where datet > '''||l_plan_start_date||''' and rownum = 1 order by datet asc';
                execute immediate l_sql into x_from_date;

           	l_sql := 'select max(datet) from '||g_schema||'.inputs ';
           	execute immediate l_sql into x_to_date;

           	/* Setting start and end dates for  Purge Plan Data data profile */

                /* Bug#8224935 - APP ID */ -- nallkuma
                l_profile_id1 := to_number(msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                                    'PROFILE_PURGE_PLAN_DATA',
                                                                                    1,
                                                                                    'id'));

         	l_sql := 'begin ' || g_schema|| '.API_MODIFY_INTEG_SERIES_FDATE('||l_profile_id1||', '''|| x_from_date||''', '''||x_to_date||'''); end;';
               	execute immediate l_sql;


         	/* Calling API to notify the application server to refresh its engine */
         	msd_dem_common_utilities.log_debug ('Calling API_NOTIFY_APS_INTEGRATION - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         	l_sql := 'begin ' || g_schema|| '.API_NOTIFY_APS_INTEGRATION('||l_profile_id1 ||'); end;';
             	execute immediate l_sql;

             	/* Setting start and end dates for Purge Resource Data data profile*/

                /* Bug#8224935 - APP ID */ -- nallkuma
                l_profile_id2 := to_number(msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                                    'PROFILE_PURGE_RESOURCE_DATA',
                                                                                    1,
                                                                                    'id'));

         	l_sql := 'begin ' || g_schema|| '.API_MODIFY_INTEG_SERIES_FDATE('||l_profile_id2||', '''|| x_from_date||''', '''||x_to_date||'''); end;';
               	execute immediate l_sql;


         	/* Calling API to notify the application server to refresh its engine */
         	msd_dem_common_utilities.log_debug ('Calling API_NOTIFY_APS_INTEGRATION - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         	l_sql := 'begin ' || g_schema|| '.API_NOTIFY_APS_INTEGRATION('||l_profile_id2 ||'); end;';
             	execute immediate l_sql;
            -- syenamar
           else
           	msd_dem_common_utilities.log_message('Demantra Schema not set');
           end if;



          log_debug ('Exiting: msd_dem_sop.pre_download_hook - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
       EXCEPTION
          WHEN OTHERS THEN
             retcode := -1;
             errbuf := substr(SQLERRM,1,150);
             log_message ('Exception: msd_dem_sop.pre_download_hook - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
             RETURN;
       END PRE_DOWNLOAD_HOOK;



       /*
        *
        */
       PROCEDURE LOAD_ASCP_DATA (
       				errbuf			OUT NOCOPY 	VARCHAR2,
       				retcode			OUT NOCOPY 	VARCHAR2,
       				p_plan_id		IN		NUMBER)
       IS

          CURSOR c_get_all_series
          IS
             SELECT
                series_id
                FROM
                   msd_dem_series
                WHERE
                   series_id IN (101, 102, 103, 104, 105, 106, 107, 108, 109, 110);

         /*** LOCAL VARIABLES - BEGIN ***/

            x_errbuf			VARCHAR2(200)	:= NULL;
            x_retcode			VARCHAR2(100)	:= NULL;

            x_dm_time_level		NUMBER		:= NULL;
            x_dm_time_bucket    	VARCHAR2(30)    := NULL;

            x_sql			VARCHAR2(2000)  := NULL;

         /*** LOCAL VARIABLES - END ***/

       BEGIN
          log_debug ('Entering: msd_dem_sop.load_ascp_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

          /* Get the lowest time bucket */
          x_dm_time_bucket := msd_dem_common_utilities.dm_time_level;
          IF (x_dm_time_bucket IS NULL)
          THEN
             retcode := -1;
             errbuf := 'Unable to get lowest time bucket';
             log_message('Error(1): msd_dem_sop.load_ascp_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
             RETURN;
          ELSIF (upper(x_dm_time_bucket) = 'DAY')
          THEN
             x_dm_time_level := 1;
          ELSE
             x_dm_time_level := 2;
          END IF;


          FOR rec IN c_get_all_series
          LOOP
             log_debug ('Start Of Loop for series id - ' || to_number(rec.series_id) || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

             load_series_data (
             		x_errbuf,
             		x_retcode,
             		rec.series_id,
             		p_plan_id,
             		x_dm_time_level);
             IF (x_retcode = -1)
             THEN
                retcode := -1;
                errbuf := x_errbuf;
                log_message ('Error(2): msd_dem_sop.load_ascp_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
                RETURN;
             END IF;

             COMMIT;

             log_debug ('End Of Loop for series id - ' || to_number(rec.series_id) || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
          END LOOP;

          /* Delete non-saleable items from the staging table BIIO_OTHER_PLAN_DATA */
          --bug#9153872    syenamar
          -- In case 'Include dependent demand' is true, delete non-saleable items only if they are non-cto
          -- if false, no change in existing behaviour (any non-saleable item will be removed)
          x_sql := ' DELETE FROM ' || g_schema || '.BIIO_OTHER_PLAN_DATA bopd '
                    || ' WHERE ';

          IF (fnd_profile.value('MSD_DEM_INCLUDE_DEPENDENT_DEMAND') = 1)
          THEN
            x_sql := x_sql || ' NOT EXISTS '
                           || ' (SELECT 1 from '
                           || g_schema || '.t_ep_item tei, '
                           || g_schema || '.t_ep_cto_matrix tcm, '
                           || g_schema || '.items itm '
                           || '  where tei.item = bopd.level2 '
                           || '  and tei.t_ep_item_ep_id = itm.t_ep_item_ep_id '
                           || '  and itm.item_id = tcm.item_id '
                           || '  and rownum < 2) '
                           || '  AND ';
          END IF;

          x_sql := x_sql || ' NOT EXISTS ( SELECT 1 '
                   || '                    FROM ' || g_schema || '.t_ep_item tei, '
                   ||                                g_schema || '.mdp_matrix mm '
                   || '                    WHERE  tei.item = bopd.level2 '
                   || '                       AND mm.t_ep_item_ep_id = tei.t_ep_item_ep_id '
                   || '                       AND mm.is_fictive = 0 '
                   || '                       AND rownum < 2 ) '
                   || '    AND avail_sup_std_cap IS NULL '
                   || '    AND required_sup_cap IS NULL ';
           --syenamar

          log_debug ('Query - ');
          log_debug (x_sql);

          log_debug ('Query Start Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

          BEGIN
             EXECUTE IMMEDIATE x_sql;
          EXCEPTION
             WHEN OTHERS THEN
                retcode := -1;
                errbuf := substr(SQLERRM,1,150);
                log_message ('Exception(1): msd_dem_sop.load_ascp_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
                RETURN;
          END;

          COMMIT;

          log_debug ('Query End Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

          /* Updated non-supplier series to NULL for non-saleable:buy:critical items from the staging table BIIO_OTHER_PLAN_DATA */
          x_sql := ' UPDATE ' || g_schema || '.BIIO_OTHER_PLAN_DATA bopd '
                   || ' SET bopd.constrained_fcst = NULL, '
                   || '     bopd.prod_plan = NULL, '
                   || '     bopd.safety_stk = NULL, '
                   || '     bopd.beginning_on_hand = NULL, '
                   || '     bopd.dependent_demand = NULL, '
                   || '     bopd.planned_shipments = NULL '
                   || ' WHERE NOT EXISTS ( SELECT 1 '
                   || '                    FROM ' || g_schema || '.t_ep_item tei, '
                   ||                                g_schema || '.mdp_matrix mm '
                   || '                    WHERE  tei.item = bopd.level2 '
                   || '                       AND mm.t_ep_item_ep_id = tei.t_ep_item_ep_id '
                   || '                       AND mm.is_fictive = 0 '
                   || '                       AND rownum < 2 ) '
                   || '    AND ( avail_sup_std_cap IS NOT NULL '
                   || '          OR required_sup_cap IS NOT NULL ) ';

          log_debug ('Query - ');
          log_debug (x_sql);

          log_debug ('Query Start Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

          BEGIN
             EXECUTE IMMEDIATE x_sql;
          EXCEPTION
             WHEN OTHERS THEN
                retcode := -1;
                errbuf := substr(SQLERRM,1,150);
                log_message ('Exception(2): msd_dem_sop.load_ascp_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
                RETURN;
          END;

          COMMIT;

          log_debug ('Query End Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

          log_debug ('Exiting: msd_dem_sop.load_ascp_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
       EXCEPTION
          WHEN OTHERS THEN
             retcode := -1;
             errbuf := substr(SQLERRM,1,150);
             log_message ('Exception(3): msd_dem_sop.load_ascp_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
             RETURN;
       END LOAD_ASCP_DATA;



       /*
        *
        */
       PROCEDURE PUSH_TIME_DATA (
       				errbuf			OUT NOCOPY 	VARCHAR2,
       				retcode			OUT NOCOPY 	VARCHAR2 )
       IS

          /*** LOCAL VARIABLES - BEGIN ***/

             x_sql			VARCHAR2(1000)  := NULL;

             x_dm_table			VARCHAR2(100)   := NULL;
             x_source_time_table	VARCHAR2(100)   := NULL;
             x_start_date		VARCHAR2(100)   := NULL;
             x_end_date			VARCHAR2(100)   := NULL;

             x_time_bucket		VARCHAR2(30)    := NULL;
             x_first_day_of_week 	VARCHAR2(30)    := NULL;
             x_aggregation_method      	NUMBER(1)	:= NULL;
             x_actual_agg_method	NUMBER(1)	:= NULL;

          /*** LOCAL VARIABLES - END ***/

       BEGIN

          log_debug ('Entering: msd_dem_sop.push_time_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

          IF (C_MSD_DEM_PUSH_TIME = 'N')
          THEN
             log_debug ('Table msd_dem_dates has already been populated for this session.');
             RETURN;
          END IF;

          log_debug ('Deleting time data from msd_dem_dates');
          EXECUTE IMMEDIATE 'DELETE FROM msd_dem_dates';

          x_dm_table := msd_dem_common_utilities.get_lookup_value ('MSD_DEM_TABLES', 'DM_WIZ_DM_DEF');

          /* Get the time level info for the active data model */
          x_sql := 'SELECT time_bucket, first_day_of_week, aggregation_method ' ||
                      ' FROM ' || x_dm_table ||
                      ' WHERE dm_or_template = 2 ' ||
                      '   AND is_active = 1 ';

          EXECUTE IMMEDIATE x_sql INTO x_time_bucket, x_first_day_of_week, x_aggregation_method;


          IF (upper(x_time_bucket) = 'DAY')
          THEN
             log_debug ('Lowest Time Bucket - Day : Time data not inserted into source msd_dem_dates');
             RETURN;
          ELSIF (upper(x_time_bucket) = 'WEEK')
          THEN
             x_actual_agg_method := x_aggregation_method;
          ELSIF (upper(x_time_bucket) = 'MONTH')
          THEN
             /* Aggregate backwards */
             x_actual_agg_method := 2;
          ELSE
             retcode := -1;
             errbuf  := 'Invalid time bucket';
             log_message ('Error(1): msd_dem_push_setup_parameters.push_time_data - ' || 'Invalid time bucket - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
             RETURN;
          END IF;

          --bug#7361574    syenamar
          --adjust x_end_date so that time is set to 23hrs 59mins 59secs on that date
          IF (x_actual_agg_method = 1) /* Forward */
          THEN
             x_start_date := ' datet - num_of_days + 1, ';
             x_end_date   := ' datet ';
          ELSE
             x_start_date := ' datet, ';
             x_end_date   := ' datet + num_of_days - 1 ';
          END IF;

          x_end_date := 'trunc(' || x_end_date || ') + 86399/86400, ';

          x_source_time_table := msd_dem_common_utilities.get_lookup_value ('MSD_DEM_TABLES', 'INPUTS');

          log_debug ('Inserting time data into msd_dem_dates');
          x_sql := 'INSERT INTO msd_dem_dates' ||
                      ' (datet, num_of_days, start_date, end_date, last_update_date, last_updated_by, creation_date, created_by, last_update_login) ' ||
                      ' SELECT datet, num_of_days, ' || x_start_date || x_end_date ||
                      ' sysdate, :1, sysdate, :2, :3 ' ||
                      ' FROM ' || x_source_time_table;
          EXECUTE IMMEDIATE x_sql USING fnd_global.user_id, fnd_global.user_id, fnd_global.login_id;

          COMMIT;

          C_MSD_DEM_PUSH_TIME := 'N';

          log_debug ('Exiting: msd_dem_sop.push_time_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

       EXCEPTION
          WHEN OTHERS THEN
             retcode := -1;
             errbuf := substr(SQLERRM,1,150);
             log_message ('Exception: msd_dem_sop.push_time_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
             RETURN;
       END PUSH_TIME_DATA;





Procedure load_sup_plan_gl(p_plan_id in number,
			   p_compile_designator in varchar2,
			   p_plan_start_date in date,
			   p_end_date in date,
			   p_sop_enabled in number,
			   p_plan_type in number,
			   p_populate in number) is

x_plan_type varchar2(10);
x_plan_code varchar2(100);
x_plan_desc varchar2(240);
l_dem_sched varchar2(200);
x_dem_sched varchar2(2000):= NULL;

Type ref_cur is Ref Cursor;
c_dem_sched ref_cur;

c_scenario_status_id ref_cur;
c_scenario_status_code ref_cur;


l_scenario_status_id number;
l_scenario_status_code number;


l_stmt varchar2(240):= NULL;
l_sql varchar2(2000):= NULL;
g_schema varchar2(30):= NULL;

Begin

    -- BUG#9000156    syenamar
	--Enable download of RP plans into demantra (7.3 only)
    IF (p_plan_type in (101, 102, 103, 105)) THEN
       x_plan_type := 'Rapid Plan';
    ELSIF (p_plan_type <> 6) THEN
        		x_plan_type := 'ASCP';
    ELSIF(p_plan_type = 6) THEN
        		x_plan_type := 'SNO';
	end if;

    x_plan_code := p_compile_designator;
    x_plan_desc := p_compile_designator;
    --syenamar

        l_stmt := 'select input_name from msc_plan_sched_v where plan_id= ' ||p_plan_id ;

        open c_dem_sched for l_stmt;
        loop
              fetch c_dem_sched into l_dem_sched;
              exit when c_dem_sched%NOTFOUND;
              x_dem_sched := x_dem_sched ||', ' || l_dem_sched;
        end loop;
        close c_dem_sched;

              x_dem_sched := substr(x_dem_sched, 2, 200);

         g_schema := fnd_profile.value('MSD_DEM_SCHEMA');
         IF (g_schema IS NULL)
         THEN
            log_message ('Error(1): msd_dem_sop.load_plan_data - Unable to find schema name');
         END IF;

  l_sql := 'select scenario_status_id from '|| g_schema||'.supply_plan where plan_id = '||p_plan_id;

  open c_scenario_status_id for l_sql;
  fetch c_scenario_status_id into l_scenario_status_id;
  close c_scenario_status_id;

  if (l_scenario_status_id is null) then
       	l_scenario_status_code := 4;
  else
  	l_sql := 'select scenario_status_code from '|| g_schema||'.scenario_status where scenario_status_id = '||l_scenario_status_id;

  	open c_scenario_status_code for l_sql;
     	fetch c_scenario_status_code into l_scenario_status_code;
     	close c_scenario_status_code;

  end if;


  l_sql := 'insert into ' || g_schema||'.biio_supply_plans(supply_plan_code,
				      supply_plan_desc,
				      scenario_status_code,
				      plan_id,
				      method_status,
				      demand_schedules,
				      plan_type,
				      start_date,
				      end_date,
				      last_imported)
				      VALUES ('''
				      ||x_plan_code       ||''','
				      ||''''||x_plan_desc       ||''','
                                      ||''||l_scenario_status_code   ||','
				      ||''||p_plan_id         ||','
				      ||''''|| NULL              ||''','
				      ||''''||x_dem_sched       ||''','
				      ||''''||x_plan_type       ||''','
				      ||''''||p_plan_start_date ||''','
				      ||''''||p_end_date        ||''','
				      ||''''||sysdate           ||''')' ;

	execute immediate l_sql;

	If( p_populate = 0 ) then
	        /* Bug#8224935 - APP ID - Use get_app_id_text function instead of hard-coded level names */
        	l_sql := 'insert into ' || g_schema||'.biio_supply_plans_pop(level_member,
        				   from_date,
        				   until_date,
        				   filter_level,
        				   level_order,
        				   filter_member)
        				 values ('''
        				  ||x_plan_code ||''','
        				  ||''''||p_plan_start_date ||''','
        				  ||''''||sysdate ||''','
        				  ||''''|| msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                 'LEVEL_ITEM',
                                                                 1,
                                                                 'table_label') ||''','
        				  ||''||'2'      ||','
                                          ||''''||'0' ||''')' ;
                 execute immediate l_sql;

        	l_sql := 'insert into ' || g_schema||'.biio_supply_plans_pop(level_member,
        				   from_date,
        				   until_date,
        				   filter_level,
        				   level_order,
        				   filter_member)
        				 values ('''
        				  ||x_plan_code ||''','
        				  ||''''||p_plan_start_date ||''','
        				  ||''''||sysdate ||''','
        				  ||''''|| msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                 'LEVEL_DEMAND_CLASS',
                                                                 1,
                                                                 'table_label') ||''','
        				  ||''||'2'      ||','
                                          ||''''||'0' ||''')' ;
                 execute immediate l_sql;

        	l_sql := 'insert into ' || g_schema||'.biio_supply_plans_pop(level_member,
        				   from_date,
        				   until_date,
        				   filter_level,
        				   level_order,
        				   filter_member)
        				 values ('''
        				  ||x_plan_code ||''','
        				  ||''''||p_plan_start_date ||''','
        				  ||''''||sysdate ||''','
        				  ||''''|| msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                 'LEVEL_ORGANIZATION',
                                                                 1,
                                                                 'table_label') ||''','
        				  ||''||'1'      ||','
                                          ||''''||'0' ||''')' ;
                 execute immediate l_sql;

        	l_sql := 'insert into ' || g_schema||'.biio_supply_plans_pop(level_member,
        				   from_date,
        				   until_date,
        				   filter_level,
        				   level_order,
        				   filter_member)
        				 values ('''
        				  ||x_plan_code ||''','
        				  ||''''||p_plan_start_date ||''','
        				  ||''''||sysdate ||''','
        				  ||''''|| msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                 'LEVEL_SITE',
                                                                 1,
                                                                 'table_label') ||''','
        				  ||''||'1'      ||','
                                          ||''''||'0' ||''')' ;
                 execute immediate l_sql;

  		l_sql := 'insert into ' || g_schema||'.biio_supply_plans_pop(level_member,
        				   from_date,
        				   until_date,
        				   filter_level,
        				   level_order,
        				   filter_member)
        				 values ('''
        				  ||x_plan_code ||''','
        				  ||''''||p_plan_start_date ||''','
        				  ||''''||sysdate ||''','
        				  ||''''|| msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                 'LEVEL_SALES_CHANNEL',
                                                                 1,
                                                                 'table_label') ||''','
        				  ||''||'1'      ||','
                                          ||''''||'0' ||''')' ;
                 execute immediate l_sql;

	end if;
	commit;

end;




procedure load_plan_gl(p_plan_id number,
            p_populate number)

is

cursor get_plan_info is
select sr_instance_id, compile_designator, plan_type, curr_start_date, cutoff_date
from msc_plans
where plan_id = p_plan_id;

l_plan_type number;

l_plan_name varchar2(250);

l_instance_id number;

l_start_date date;
l_end_date date;

l_stmt varchar2(4000);
l_retcode number;

Cursor c_sup_plan is
select  compile_designator, curr_start_date, cutoff_date, sop_enabled, plan_type
from msc_plans
where plan_id=p_plan_id;

Type all_sup_plans is Ref Cursor;
c_all_sup_plans all_sup_plans;

p_compile_designator VARCHAR2(240);
p_plan_start_date DATE;
p_end_date DATE;
p_sop_enabled VARCHAR2(10);
p_plan_type NUMBER;

Type dem_sched is Ref Cursor;
c_dem_sched dem_sched;

l_dem_sched varchar2(2000);
x_dem_sched varchar2(2000):= NULL;


x_plan_id number;
x_dem_plan_type varchar2(100) := null;
x_dem_version   varchar2(3) := NULL;

begin


if p_populate <> 1 then

    If(p_plan_id is null) then

      l_stmt := 'select plan_id,  compile_designator, curr_start_date, cutoff_date, sop_enabled, plan_type
      from msc_plans
      where sop_enabled = 1 ';

      -- BUG#9000156    syenamar
      --Enable download of RP plans into demantra (7.3 only)
      x_dem_version := fnd_profile.value('MSD_DEM_VERSION');

      IF (x_dem_version < '7.3') THEN
        l_stmt := l_stmt || ' and plan_type not in (101, 102, 103, 105)';
      END IF;

      /* Do not supply plan members which are already present inside Demantra */
      l_stmt := l_stmt || ' AND compile_designator NOT IN '
                       || ' ( SELECT supply_plan_code FROM '
                       || g_schema || '.supply_plan )';


       open c_all_sup_plans for l_stmt;
       loop
        fetch c_all_sup_plans into x_plan_id, p_compile_designator, p_plan_start_date, p_end_date,  p_sop_enabled, p_plan_type;
        exit when c_all_sup_plans%NOTFOUND;
        load_sup_plan_gl(x_plan_id, p_compile_designator, p_plan_start_date, p_end_date,  p_sop_enabled, p_plan_type, p_populate);
       end loop;
       close c_all_sup_plans;

      Else
              open c_sup_plan;
              fetch c_sup_plan into  p_compile_designator, p_plan_start_date, p_end_date,  p_sop_enabled, p_plan_type;
              close c_sup_plan;

              load_sup_plan_gl(p_plan_id, p_compile_designator, p_plan_start_date, p_end_date,  p_sop_enabled, p_plan_type, p_populate);

      end if;

      return;

  end if;

   open get_plan_info;
		fetch get_plan_info into l_instance_id, l_plan_name, l_plan_type, l_start_date, l_end_date;
		close get_plan_info;


		if l_plan_name is not null then

				msd_dem_query_utilities.get_query(l_retcode, l_stmt, 'MSD_DEM_DELETE_STMT', l_instance_id);

				l_stmt := replace(l_stmt, 'C_TABLE_NAME', fnd_profile.value('MSD_DEM_SCHEMA') || '.biio_supply_plans');

				execute immediate l_stmt;

				msd_dem_query_utilities.get_query(l_retcode, l_stmt, 'MSD_DEM_DELETE_STMT', l_instance_id);

				l_stmt := replace(l_stmt, 'C_TABLE_NAME', fnd_profile.value('MSD_DEM_SCHEMA') || '.biio_supply_plans_pop');

				execute immediate l_stmt;

				l_stmt := 'select input_name from msc_plan_sched_v where plan_id= ' ||p_plan_id ;

        open c_dem_sched for l_stmt;
        loop
              fetch c_dem_sched into l_dem_sched;
              exit when c_dem_sched%NOTFOUND;
              x_dem_sched := x_dem_sched ||', ' || l_dem_sched;
        end loop;
        close c_dem_sched;

        x_dem_sched := substr(x_dem_sched, 2);

		end if;

		l_stmt := ' SELECT spd.from_date FROM ' || g_schema || '.supply_plan sp, '
		                                    || g_schema || '.supply_plan_dates spd '
		                                    || ' WHERE sp.plan_id = ' || p_plan_id
		                                    || '   AND spd.supply_plan_id = sp.supply_plan_id ';
		EXECUTE IMMEDIATE l_stmt INTO l_start_date;

		if l_plan_type <> 6 then

			msd_dem_query_utilities.get_query(l_retcode, l_stmt, 'MSD_DEM_PLANS', l_instance_id);

			if l_stmt is null then
					return;
			end if;

			l_stmt := replace(l_stmt, 'C_SCHEMANAME', fnd_profile.value('MSD_DEM_SCHEMA'));

            -- BUG#9000156    syenamar
            --Enable download of RP plans into demantra (7.3 only)
            IF (l_plan_type in (101, 102, 103, 105)) THEN
                x_dem_plan_type := 'Rapid Plan';
            ELSE
                x_dem_plan_type := 'ASCP';
            END IF;

			execute immediate l_stmt using l_plan_name, l_plan_name, x_dem_plan_type, 2, l_start_date, l_end_date, p_plan_id, substr(x_dem_sched,1,200);
            --syenamar

			if p_populate = 1 then

					msd_dem_query_utilities.get_query(l_retcode, l_stmt, 'MSD_DEM_PLANS_POP_EBS', l_instance_id);

					if l_stmt is null then
							return;
					end if;

					l_stmt := replace(l_stmt, 'C_SCHEMANAME', fnd_profile.value('MSD_DEM_SCHEMA'));

					execute immediate l_stmt using l_plan_name, l_start_date, l_end_date, p_plan_id, p_plan_id, p_plan_id, p_plan_id;
			end if;

		end if;

		if l_plan_type = 6 then

                        /* Get the end date for the SNO plan */
                        l_end_date := msd_dem_common_utilities.get_sno_plan_cutoff_date (p_plan_id);

			msd_dem_query_utilities.get_query(l_retcode, l_stmt, 'MSD_DEM_PLANS', l_instance_id);

			if l_stmt is null then
					return;
			end if;

			l_stmt := replace(l_stmt, 'C_SCHEMANAME', fnd_profile.value('MSD_DEM_SCHEMA'));

			execute immediate l_stmt using l_plan_name, l_plan_name, 'SNO', 2, l_start_date, l_end_date, p_plan_id, substr(x_dem_sched,1,200);

			if p_populate = 1 then

					msd_dem_query_utilities.get_query(l_retcode, l_stmt, 'MSD_DEM_PLANS_POP_SNO', l_instance_id);

					if l_stmt is null then
							return;
					end if;

					l_stmt := replace(l_stmt, 'C_SCHEMANAME', fnd_profile.value('MSD_DEM_SCHEMA'));

					execute immediate l_stmt using l_plan_name, l_start_date, l_end_date, p_plan_id, p_plan_id;

			end if;

		end if;

		commit;


end load_plan_gl;


procedure load_resource_gl(p_plan_id number)

is

cursor get_plan_info is
select sr_instance_id, compile_designator, plan_type, curr_start_date, cutoff_date
from msc_plans
where plan_id = p_plan_id;

l_plan_type number;

l_plan_name varchar2(250);

l_instance_id number;

l_start_date date;
l_end_date date;

l_stmt varchar2(4000);
l_retcode number;

begin

		open get_plan_info;
		fetch get_plan_info into l_instance_id, l_plan_name, l_plan_type, l_start_date, l_end_date;
		close get_plan_info;

		l_stmt := ' SELECT spd.from_date FROM ' || g_schema || '.supply_plan sp, '
		                                    || g_schema || '.supply_plan_dates spd '
		                                    || ' WHERE sp.plan_id = ' || p_plan_id
		                                    || '   AND spd.supply_plan_id = sp.supply_plan_id ';
		EXECUTE IMMEDIATE l_stmt INTO l_start_date;


		if l_plan_type <> 6 then

			msd_dem_query_utilities.get_query(l_retcode, l_stmt, 'MSD_DEM_SCENARIO_RESOURCES_EBS', l_instance_id);

			if l_stmt is null then
					return;
			end if;

			l_stmt := replace(l_stmt, 'C_PLAN_NAME', '''' || l_plan_name || '''');
			l_stmt := replace(l_stmt, 'C_PLAN_ID', p_plan_id);
			l_stmt := replace(l_stmt, 'C_SCHEMANAME', fnd_profile.value('MSD_DEM_SCHEMA'));

			execute immediate l_stmt;

			msd_dem_query_utilities.get_query(l_retcode, l_stmt, 'MSD_DEM_RESOURCES_EBS', l_instance_id);

			if l_stmt is null then
					return;
			end if;

			l_stmt := replace(l_stmt, 'C_RESOURCE_TABLE', msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES', 'BIIO_RESOURCES'));
			l_stmt := replace(l_stmt, 'C_PLAN_NAME', '''' || l_plan_name || '''');
			l_stmt := replace(l_stmt, 'C_PLAN_ID', p_plan_id);
			l_stmt := replace(l_stmt, 'C_SCHEMANAME', fnd_profile.value('MSD_DEM_SCHEMA'));

			execute immediate l_stmt;

			msd_dem_query_utilities.get_query(l_retcode, l_stmt, 'MSD_DEM_RESOURCE_POP_EBS', l_instance_id);

			l_stmt := replace(l_stmt, 'C_PLAN_NAME', '''' || l_plan_name || '''');
			l_stmt := replace(l_stmt, 'C_PLAN_ID', p_plan_id);
			l_stmt := replace(l_stmt, 'C_PLAN_START_DATE', 'to_date(''' || to_char(l_start_date, 'dd-mm-yyyy') || ''',''dd-mm-yyyy'')');
			l_stmt := replace(l_stmt, 'C_PLAN_END_DATE', 'to_date(''' || to_char(l_end_date, 'dd-mm-yyyy') || ''',''dd-mm-yyyy'')');
			l_stmt := replace(l_stmt, 'C_SCHEMANAME', fnd_profile.value('MSD_DEM_SCHEMA'));

			execute immediate l_stmt;

		end if;

		if l_plan_type = 6 then

                        /* Get the end date for the SNO plan */
                        l_end_date := msd_dem_common_utilities.get_sno_plan_cutoff_date (p_plan_id);

			msd_dem_query_utilities.get_query(l_retcode, l_stmt, 'MSD_DEM_SCENARIO_RESOURCES_SNO', l_instance_id);

			if l_stmt is null then
					return;
			end if;

			l_stmt := replace(l_stmt, 'C_TARGET_TABLE', msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES', 'BIIO_RESOURCES'));
			l_stmt := replace(l_stmt, 'C_SRC_TABLE', msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES', 'BIIO_RESOURCE_CAPACITY'));
			l_stmt := replace(l_stmt, 'C_SCHEMANAME', fnd_profile.value('MSD_DEM_SCHEMA'));

			execute immediate l_stmt;

			msd_dem_query_utilities.get_query(l_retcode, l_stmt, 'MSD_DEM_RESOURCES_SNO', l_instance_id);

			if l_stmt is null then
					return;
			end if;

			l_stmt := replace(l_stmt, 'C_TARGET_TABLE', msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES', 'BIIO_RESOURCES'));
			l_stmt := replace(l_stmt, 'C_SRC_TABLE', msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES', 'BIIO_RESOURCE_CAPACITY'));
			l_stmt := replace(l_stmt, 'C_SCHEMANAME', fnd_profile.value('MSD_DEM_SCHEMA'));

			execute immediate l_stmt;

			msd_dem_query_utilities.get_query(l_retcode, l_stmt, 'MSD_DEM_RESOURCE_POP_SNO', l_instance_id);

			if l_stmt is null then
					return;
			end if;

			l_stmt := replace(l_stmt, 'C_TARGET_TABLE', msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES', 'BIIO_RESOURCES'));
			l_stmt := replace(l_stmt, 'C_SRC_TABLE', msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES', 'BIIO_RESOURCE_CAPACITY'));
			l_stmt := replace(l_stmt, 'C_SCHEMANAME', fnd_profile.value('MSD_DEM_SCHEMA'));
			l_stmt := replace(l_stmt, 'C_PLAN_START_DATE', 'to_date(''' || to_char(l_start_date, 'dd-mm-yyyy') || ''',''dd-mm-yyyy'')');
			l_stmt := replace(l_stmt, 'C_PLAN_END_DATE', 'to_date(''' || to_char(l_end_date, 'dd-mm-yyyy') || ''',''dd-mm-yyyy'')');

			execute immediate l_stmt;

		end if;

		commit;


end;




procedure load_item_locs( p_plan_id number)
is

errbuf varchar2(1000);
retcode number;

cursor get_instance_id is
select sr_instance_id
from msc_plans
where plan_id = p_plan_id;

l_instance_id number;

begin

	  open get_instance_id;
	  fetch get_instance_id into l_instance_id;
	  close get_instance_id;


		msd_dem_collect_level_types.collect_levels(errbuf, retcode, l_instance_id, 2, p_plan_id);

		msd_dem_collect_level_types.collect_levels(errbuf, retcode, l_instance_id, 1, p_plan_id);


end load_item_locs;



   /*** PUBLIC PROCEDURES ***
    * SET_PLAN_ATTRIBUTES
    * LOAD_PLAN_DATA
    * LOAD_PLAN_MEMBERS
    * POST_DOWNLOAD_HOOK
    * LOAD_ITEM_COST
    * WAIT_UNTIL_DOWNLOAD_COMPLETE
    * COLLECT_SCI_DATA
    * LAUNCH_SCI_DATA_LOADS
    */



procedure set_plan_attributes(p_member_id in number) is

Type pln_id is Ref Cursor;
c_plan_id pln_id;

p_plan_id number;
l_sql varchar2(1000) := NULL;

g_schema varchar2(50);
x_small_sql varchar2(240);


Begin
    -- bug#9048688, syenamar
    -- this code will be executed with definer(apps) rights due to 'AUTHID DEFINER' clause in package spec, so need to specify demantra schema for demantra tables

    /* Alter session to APPS */
    x_small_sql := 'alter session set current_schema = APPS';
    EXECUTE IMMEDIATE x_small_sql;

    g_schema := fnd_profile.value('MSD_DEM_SCHEMA');
    IF (g_schema IS NULL)
    THEN
    log_message ('Error: msd_dem_sop.set_plan_attributes - Unable to find schema name');
    END IF;

	/* Inserting an entry into Integ_Status table
  	that loading of plan is running. */

	l_sql := 'Insert into ' || g_schema || '.integ_status(username, process, stage, status, info, status_date) values (''DMTRA_TEMPLATE'',
					''LOAD_PLAN_DATA'',
					''LOAD_PLAN_DATA'',
					''RUNNING'', '
					||''''|| ' '              ||''','
					||''''||sysdate           ||''')' ;

        execute immediate l_sql;

        l_sql := 'select plan_id from ' || g_schema || '.supply_plan
                where supply_plan_id = ' ||p_member_id;

	/* Get the ASCP or SNO plan_id and call procedure load_plan_gl */

	open c_plan_id for l_sql;
	fetch c_plan_id into p_plan_id;
	close c_plan_id ;

	load_plan_gl(p_plan_id, 0);

	/* Alter session to demantra schema */
         x_small_sql := 'alter session set current_schema = ' || g_schema;
         EXECUTE IMMEDIATE x_small_sql;

EXCEPTION
		when others then
		return;
End set_plan_attributes;




      /*
       *
       */
      PROCEDURE LOAD_PLAN_DATA (
      			p_member_id			IN	   NUMBER,
                p_delete_item_pop   IN   BOOLEAN default TRUE)
      IS

         /*** LOCAL VARIABLES - BEGIN ***/

            x_errbuf			VARCHAR2(200)	:= NULL;
            x_retcode			VARCHAR2(100)	:= NULL;

            x_plan_id			NUMBER		:= NULL;
            x_plan_type			NUMBER		:= NULL;
            x_small_sql			VARCHAR2(600)	:= NULL;
            x_sno_sql			VARCHAR2(600)   := NULL;
            v_demantra_version		NUMBER;


         /*** LOCAL VARIABLES - END ***/

      BEGIN


         /* Alter session to APPS */
         x_small_sql := 'alter session set current_schema = APPS';
         EXECUTE IMMEDIATE x_small_sql;

         g_schema := fnd_profile.value('MSD_DEM_SCHEMA');
         IF (g_schema IS NULL)
         THEN
            log_message ('Error(1): msd_dem_sop.load_plan_data - Unable to find schema name');
            RETURN;
         END IF;

         /* Alter session to demantra schema */
         x_small_sql := 'alter session set current_schema = ' || g_schema;

         log_debug ('Entering: msd_dem_sop.load_plan_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         /* Get plan id of the supply plan */
         x_plan_id := get_plan_id (p_member_id);
         IF (x_plan_id IS NULL)
         THEN
            log_message ('Error(2): msd_dem_sop.load_plan_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS') ||
                         ' - Unable to get plan id for the given plan scenario member id : ' || to_char(p_member_id));
            EXECUTE IMMEDIATE x_small_sql;
            RETURN;
         END IF;

         /* Get plan type of the supply plan */
         x_plan_type := get_plan_type (p_member_id);
         IF (x_plan_type IS NULL)
         THEN
            log_message ('Error(3): msd_dem_sop.load_plan_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS') ||
                         ' - Unable to get plan type for the given plan scenario member id : ' || to_char(p_member_id));
            EXECUTE IMMEDIATE x_small_sql;
            RETURN;
         END IF;

         /* Truncate all staging tables */
         truncate_staging_tables (
         		x_errbuf,
          		x_retcode);
         IF (x_retcode = -1)
         THEN
            log_message ('Error(4): msd_dem_sop.load_plan_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS') ||
                         ' - ' || x_errbuf );
            EXECUTE IMMEDIATE x_small_sql;
            RETURN;
         END IF;


         /* Call Pre-Download Hook */
         pre_download_hook (
         		x_errbuf,
         		x_retcode,
         		x_plan_id);
         IF (x_retcode = -1)
         THEN
            log_message ('Error(4): msd_dem_sop.load_plan_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS') || x_errbuf);
            EXECUTE IMMEDIATE x_small_sql;
            RETURN;
         END IF;


         /* For ASCP plan , call Load ASCP Plan */
         -- BUG#9000156
         --Enable download of RP plan data into demantra
         IF (x_plan_type = 0 or x_plan_type = 2)
         THEN

            push_time_data (
            		x_errbuf,
         		x_retcode);
            IF (x_retcode = -1)
            THEN
               log_message ('Error(5): msd_dem_sop.load_plan_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS') || x_errbuf);
               EXECUTE IMMEDIATE x_small_sql;
               RETURN;
            END IF;

            load_ascp_data (
            		x_errbuf,
         		x_retcode,
         		x_plan_id);
            IF (x_retcode = -1)
            THEN
               log_message ('Error(6): msd_dem_sop.load_plan_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS') || x_errbuf);
               EXECUTE IMMEDIATE x_small_sql;
               RETURN;
            END IF;

         ELSE /* For SNO plan, call Load SNO Plan */
            BEGIN
               x_sno_sql := 'BEGIN ' || g_schema || '.SNOP_DATA_LOAD.SNO_LOAD_DATA(''' || x_plan_id || '''); END;';
               EXECUTE IMMEDIATE x_sno_sql;
            EXCEPTION
               WHEN OTHERS THEN
                  log_message ('Error(7): msd_dem_sop.load_plan_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS') || 'Error in call to SNOP_DATA_LOAD.SNO_LOAD_DATA');
                  EXECUTE IMMEDIATE x_small_sql;
                  RETURN;
            END;
         END IF;


         /* Load Plan Scenario GL */
         load_plan_gl (x_plan_id, 1);

         /* Load Plan Resource GL */
         load_resource_gl (x_plan_id);

         /* Load Item Location */
         load_item_locs (x_plan_id);

         -- bug#9125335     syenamar
         -- delete item population from staging table only in 7.2, if p_delete_item_pop is true
         v_demantra_version := to_number(msd_dem_common_utilities.get_demantra_version);
         if (v_demantra_version < 7.3 and p_delete_item_pop)
         then
             -- bug#8266960
             EXECUTE IMMEDIATE 'DELETE FROM ' || g_schema || '.BIIO_SUPPLY_PLANS_POP WHERE LEVEL_ORDER = 2';
             COMMIT;
         end if;

         log_debug ('Exiting: msd_dem_sop.load_plan_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));


         /* Alter session to demantra schema */
         x_small_sql := 'alter session set current_schema = ' || g_schema;
         EXECUTE IMMEDIATE x_small_sql;

      EXCEPTION
         WHEN OTHERS THEN
            log_message ('Exception: msd_dem_sop.load_plan_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            log_message (substr(SQLERRM,1,150));

            /* Alter session to demantra schema */
            x_small_sql := 'alter session set current_schema = ' || g_schema;
            EXECUTE IMMEDIATE x_small_sql;

            RETURN;

      END LOAD_PLAN_DATA;




      /*
       *
       */
      PROCEDURE LOAD_PLAN_MEMBERS
      IS
      x_small_sql varchar2(1000);
      BEGIN

         log_debug ('Entering: msd_dem_sop.load_plan_members - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         /* Alter session to APPS */
         x_small_sql := 'alter session set current_schema = APPS';
         EXECUTE IMMEDIATE x_small_sql;

         g_schema := fnd_profile.value('MSD_DEM_SCHEMA');
         IF (g_schema IS NULL)
         THEN
            log_message ('Error(1): msd_dem_sop.load_plan_data - Unable to find schema name');
         END IF;

	 load_plan_gl(NULL, 0);

         /* Alter session to demantra schema */
         x_small_sql := 'alter session set current_schema = ' || g_schema;
         EXECUTE IMMEDIATE x_small_sql;

         log_debug ('Exiting: msd_dem_sop.load_plan_members - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
      EXCEPTION
         WHEN OTHERS THEN
            log_message ('Exception: msd_dem_sop.load_plan_members - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            log_message (substr(SQLERRM,1,150));

            /* Alter session to demantra schema */
            x_small_sql := 'alter session set current_schema = ' || g_schema;
            EXECUTE IMMEDIATE x_small_sql;
            RETURN;

      END LOAD_PLAN_MEMBERS;




      /*
       *
       */
      PROCEDURE POST_DOWNLOAD_HOOK (
      			p_member_id			IN	   NUMBER )
      IS
      BEGIN
         --log_debug ('Entering: msd_dem_sop.post_download_hook - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         NULL;
         --log_debug ('Exiting: msd_dem_sop.post_download_hook - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
      EXCEPTION
         WHEN OTHERS THEN
            --log_message ('Exception: msd_dem_sop.post_download_hook - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            --log_message (substr(SQLERRM,1,150));
            RETURN;

      END POST_DOWNLOAD_HOOK;




      /*
       * This procedure loads item cost information from planning server ODS
       * for all DM enabled organizations into the import integration
       * staging table - BIIO_ITEM_COST
       */
      PROCEDURE LOAD_ITEM_COST
      IS

         /*** LOCAL VARIABLES - BEGIN ***/

            x_errbuf			VARCHAR2(200)	:= NULL;
            x_retcode			VARCHAR2(100)	:= NULL;

            x_small_sql			VARCHAR2(600)	:= NULL;

         /*** LOCAL VARIABLES - END ***/

      BEGIN

         /* Alter session to APPS */
         x_small_sql := 'alter session set current_schema = APPS';
         EXECUTE IMMEDIATE x_small_sql;

         g_schema := fnd_profile.value('MSD_DEM_SCHEMA');
         IF (g_schema IS NULL)
         THEN
            log_message ('Error(1): msd_dem_sop.load_item_cost - Unable to find schema name');
         END IF;


         log_debug ('Entering: msd_dem_sop.load_item_cost - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         /* Delete all data (if any) from the staging table */
         x_small_sql := 'TRUNCATE TABLE ' || g_schema || '.BIIO_ITEM_COST';
         EXECUTE IMMEDIATE x_small_sql;

         /* Delete all data (if any) from the ERR staging table */
         x_small_sql := 'TRUNCATE TABLE ' || g_schema || '.BIIO_ITEM_COST_ERR';
         EXECUTE IMMEDIATE x_small_sql;

         push_time_data (
         		x_errbuf,
         		x_retcode);
         IF (x_retcode = -1)
         THEN
            log_message ('Error(2): msd_dem_sop.load_item_cost - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS') || x_errbuf);
            RAISE NO_DATA_FOUND;
         END IF;

         /* Load data for series Item Cost */
         load_series_data (
             		x_errbuf,
             		x_retcode,
             		C_MSD_DEM_SOP_ITEM_COST,
             		-1,
             		1);
         IF (x_retcode = -1)
         THEN
            log_message ('Error(3): msd_dem_sop.load_item_cost - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS') || x_errbuf);
            RAISE NO_DATA_FOUND;
         END IF;

         COMMIT;

         log_debug ('Exiting: msd_dem_sop.load_item_cost - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));


         /* Alter session to demantra schema */
         x_small_sql := 'alter session set current_schema = ' || g_schema;
         EXECUTE IMMEDIATE x_small_sql;

      EXCEPTION
         WHEN OTHERS THEN
            log_message ('Exception: msd_dem_sop.load_item_cost - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            log_message (substr(SQLERRM,1,150));

            COMMIT;

            /* Alter session to demantra schema */
            x_small_sql := 'alter session set current_schema = ' || g_schema;
            EXECUTE IMMEDIATE x_small_sql;

            RETURN;

      END LOAD_ITEM_COST;




      /*
       * This procedure is called by the Wait step of the Download Plan Scenario Data workflow.
       *
       * If WF_PROCESS_LOG lists a workflow instance as running and not in the Wait step,
       * then this procedure will sleep for a random number of seconds and then loop. It will
       * exit when no workflow instances are running that are not in the Wait step.
       *
       */
      PROCEDURE WAIT_UNTIL_DOWNLOAD_COMPLETE (
      			p_wait_step_id		IN		VARCHAR2	DEFAULT '',
      			p_exception_step_id	IN		VARCHAR2	DEFAULT '')
      IS
        v_schema_id number;
        v_sql varchar2(4000);
        v_status varchar2(100);
        v_not_in_steps			VARCHAR2(255);
        v_demantra_version		NUMBER;
        g_schema varchar2(30) := null;
      BEGIN
        -- bug#9048688, syenamar
        -- this code will be executed with definer(apps) rights due to 'AUTHID DEFINER' clause in package spec, so need to specify demantra schema for demantra tables
        g_schema := fnd_profile.value('MSD_DEM_SCHEMA');
        IF (g_schema IS NULL)
        THEN
        log_message ('Error: msd_dem_sop.set_plan_attributes - Unable to find schema name');
        END IF;
        -- syenamar

        -- get id of download plan scenario data wf
        /* Bug#8224935 - APP ID */ -- nallkuma
        v_schema_id := to_number(msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                          'WF_DOWNLOAD_PLAN_SCENARIO_DATA',
                                                                          1,
                                                                          'schema_id'));
        --syenamar

        v_demantra_version := to_number(msd_dem_common_utilities.get_demantra_version);
        IF (v_demantra_version >= 7.3)
        THEN
           v_not_in_steps := '(''' || nvl(p_wait_step_id, 'Wait') || ''', ''' || nvl(p_exception_step_id, 'Step2') || ''')';
        ELSE
           v_not_in_steps := '(''Wait'')';
        END IF;

        v_status := 'Running';
        WHILE (v_status = 'Running') LOOP
          -- check if an instance is running
          -- bug#9048688 (prepend demantra schema when referring demantra tables)
          v_sql := 'select nvl((select ''Running'' from ' || g_schema || '.wf_process_log ' ||
                   'where schema_id = :1 and step_id not in ' || v_not_in_steps ||
                   ' and status not in(0,-1,-2) and rownum = 1), ''Not Running'') from dual';
          execute immediate v_sql into v_status using v_schema_id;

          -- if another workflow is running, sleep for 1 to 3 minutes
          IF (v_status = 'Running') THEN
            dbms_lock.sleep(dbms_random.value(60,180));
          END IF;
        END LOOP;

        EXCEPTION
          WHEN OTHERS THEN
            null;

      END WAIT_UNTIL_DOWNLOAD_COMPLETE;




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
      			p_to_date			IN	   VARCHAR2 )
      IS
      lv_request_id1              NUMBER := to_number(NULL);
      lv_request_id2              NUMBER := to_number(NULL);

      BEGIN
         msd_dem_common_utilities.log_message ('Entering: msd_dem_sop.collect_sci_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));


         /*   Launching two Conc. Programs  (for each Import Integration
              Interfact definde for SCI Data) to have the collection
              in parallel mode.
         */

            BEGIN
            lv_request_id1 := fnd_request.submit_request('MSD',
                                                  'MSDDEMSCI',
                                                  NULL,
                                                  NULL,
                                                  FALSE,
                                                  p_sr_instance_id,
                                                  p_collection_group,
                                                  p_collection_method,
                                                  p_date_range_type,
                                                  p_collection_window,
                                                  p_from_date,
                                                  p_to_date,
                                                  G_SCI_BACKLOG );

             --commit;
             EXCEPTION
              WHEN OTHERS THEN
               msd_dem_common_utilities.log_message ('Error launching concurrent program for SCI BACKLOG Integration Interface ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               msd_dem_common_utilities.log_message (errbuf);
             END;

             BEGIN
             lv_request_id2 := fnd_request.submit_request('MSD',
                                                  'MSDDEMSCI',
                                                  NULL,
                                                  NULL,
                                                  FALSE,
                                                  p_sr_instance_id,
                                                  p_collection_group,
                                                  p_collection_method,
                                                  p_date_range_type,
                                                  p_collection_window,
                                                  p_from_date,
                                                  p_to_date,
                                                  G_SCI_OTHER );

             --commit;
             EXCEPTION
              WHEN OTHERS THEN
               msd_dem_common_utilities.log_message ('Error launching concurrent program for SCI OTHER Integration Interface ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               msd_dem_common_utilities.log_message (errbuf);
             END;

            IF ( lv_request_id1 <> 0 ) AND ( lv_request_id2 <> 0 ) THEN

              msd_dem_common_utilities.log_message ('Successfully launched concurrent programs for SCI Integration Interfaces. Please see the following concurrent programs for the individual request logs. '
                                                    || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
              msd_dem_common_utilities.log_message ('Request ID for the SCI BACKLOG Integration Interface concurrent program is - '|| lv_request_id1 ||' '|| TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
              msd_dem_common_utilities.log_message ('Request ID for the SCI OTHER Integration Interface concurrent program is - '|| lv_request_id2 ||' '|| TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

             ELSE

              msd_dem_common_utilities.log_message ('Request ID for the SCI BACKLOG Integration Interface concurrent program is - '|| lv_request_id1 ||' '|| TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
              msd_dem_common_utilities.log_message ('Request ID for the SCI OTHER Integration Interface concurrent program is - '|| lv_request_id2 ||' '|| TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
              msd_dem_common_utilities.log_message ('Error launching concurrent programs for SCI Integration Interfaces. Please relaunch the SCI Collections. ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
              retcode := -1 ;

            END IF;

            COMMIT;

         msd_dem_common_utilities.log_message ('Exiting: msd_dem_sop.collect_sci_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
      EXCEPTION
         WHEN OTHERS THEN
            retcode := -1 ;
	    errbuf  := substr(SQLERRM,1,150);
            msd_dem_common_utilities.log_message ('Exception: msd_dem_sop.collect_sci_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (errbuf);
            RETURN;

      END COLLECT_SCI_DATA;




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
      			p_entity                        IN         NUMBER )
IS

       l_errbuff1      VARCHAR2(1000) := to_char(NULL);
       l_retcode1      NUMBER         := 0;

       l_errbuff2      VARCHAR2(1000) := to_char(NULL);
       l_retcode2      NUMBER         := 0;

       x_dem_schema	VARCHAR2(50)	:= NULL;
       x_dest_table	VARCHAR2(100)   := NULL;
       l_sql_stmnt      VARCHAR2(5000)   := NULL;

       CURSOR c_get_dm_schema
         IS
         SELECT owner
         FROM dba_objects
         WHERE  owner = owner
            AND object_type = 'TABLE'
            AND object_name = 'MDP_MATRIX'
         ORDER BY created desc;


BEGIN

   msd_dem_common_utilities.log_message ('Entering: msd_dem_sop.launch_sci_data_loads - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

   retcode := 0;

    /* SCI BACKLOG */
    IF ( p_entity = G_SCI_BACKLOG )
    THEN

         /* Total Backlog */
         BEGIN

           MSD_DEM_COLLECT_RETURN_HISTORY.COLLECT_RETURN_HISTORY_DATA
                              (l_errbuff1,
                               l_retcode1,
                               p_sr_instance_id,
                               p_collection_group,
                               p_collection_method,
                               p_date_range_type,
                               p_collection_window,
                               p_from_date,
                               p_to_date,
                               'BIIO_SCI_BACKLOG:MSD_TOTAL_BACKLOG',
                               1
                                );



          IF l_retcode1 = -1
          THEN
             retcode := l_retcode1;
             errbuf  := l_errbuff1;
             msd_dem_common_utilities.log_message ('An Error occured in API call MSD_DEM_COLLECT_RETURN_HISTORY.COLLECT_RETURN_HISTORY_DATA,while inserting Total Backlog Data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
             RETURN;
          END IF;

         EXCEPTION
          WHEN OTHERS THEN
            retcode := -1 ;
	    errbuf  := substr(SQLERRM,1,150);
            msd_dem_common_utilities.log_message ('Exception while inserting Total Backlog Data in the table BIIIO_SCI_BACKLOG - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (errbuf);
            RETURN;
         END;

         /* Past Due Backlog*/
         BEGIN

           MSD_DEM_COLLECT_RETURN_HISTORY.COLLECT_RETURN_HISTORY_DATA
                              (l_errbuff2,
                               l_retcode2,
                               p_sr_instance_id,
                               p_collection_group,
                               p_collection_method,
                               p_date_range_type,
                               p_collection_window,
                               p_from_date,
                               p_to_date,
                               'BIIO_SCI_BACKLOG:MSD_PAST_DUE_BACKLOG',
                               2
                                );



          IF l_retcode2 = -1
          THEN
             retcode := l_retcode2;
             errbuf  := l_errbuff2;
             msd_dem_common_utilities.log_message ('An Error occured in API call MSD_DEM_COLLECT_RETURN_HISTORY.COLLECT_RETURN_HISTORY_DATA,while merging Past Due Backlog Data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
             RETURN;
          END IF;


         EXCEPTION
          WHEN OTHERS THEN
            retcode := -1 ;
	    errbuf  := substr(SQLERRM,1,150);
            msd_dem_common_utilities.log_message ('Exception while merging Past Due Backlog Data in the table BIIIO_SCI_BACKLOG - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (errbuf);
            RETURN;
         END;

         IF ( l_retcode1 = 1 ) OR ( l_retcode2 = 1)
         THEN
           retcode := 1;
           msd_dem_common_utilities.log_message ('Warning Text for Total Backlog Insertion is - ' || l_errbuff1);
           msd_dem_common_utilities.log_message ('Warning Text for Past Due Backlog Merge is - ' || l_errbuff2);
           errbuf  := l_errbuff1 || l_errbuff2 ;
         END IF;

         /* Call - Level Code Generation Query */
         OPEN c_get_dm_schema;
         FETCH c_get_dm_schema INTO x_dem_schema;
         CLOSE c_get_dm_schema;

         /* Demantra is Installed */
         IF (x_dem_schema IS NOT NULL)
         THEN
           x_dest_table := fnd_profile.value('MSD_DEM_SCHEMA')||'.BIIO_SCI_BACKLOG ';
         END IF;

         -- bug#7419035, syenamar
         -- update level3(customer), replace customer name with the unique partner_id from ASCP
         IF (msd_dem_common_utilities.is_use_new_site_format <> 0)
         THEN
            l_sql_stmnt :=   ' update '||x_dest_table||'  bsb '
                           ||' set level3 = ( select mtp.partner_id '
                           ||'                from msc_trading_partners mtp '
                           ||'                where mtp.partner_name = bsb.level3 '
                           ||'                and   mtp.partner_type = 2 )'
                           ||' WHERE LEVEL3 <> ''' || msd_dem_sr_util.get_null_code || ''' ';

            msd_dem_common_utilities.log_message(l_sql_stmnt);

            begin
            execute immediate l_sql_stmnt;
            exception
                when others then
                   null;
            end;
         END IF;

         l_sql_stmnt := ' UPDATE ' || x_dest_table
                       || ' SET level3 = ''' || msd_dem_sr_util.get_null_code || ''' '
                       || ' WHERE level3 IS NULL ';

         msd_dem_common_utilities.log_message(l_sql_stmnt);

         begin
         execute immediate l_sql_stmnt;
         exception
             when others then
                null;
         end;

         /* update dmtra_template.BIIO_SCI_BACKLOG bsb
         set level3 = ( select mtp.partner_name
                        from msc_trading_partners mtp,
			        msc_tp_id_lid mtil
			   where mtil.sr_tp_id = bsb.level3_sr_pk
			   and   mtil.sr_instance_id = (select instance_id
			                                from msc_apps_instances mai
						        where mai.instance_code = substr(bsb.level2,1,instr(bsb.level2,':')-1)
			                                )
			   and   mtil.partner_type = 2
			   and   mtil.tp_id = mtp.partner_id
			  ); */
         /* Ends - Level Code Generation Query */

    /* SCI OTHER */

    ELSIF ( p_entity = G_SCI_OTHER )
    THEN

         -- On-Hand Inventory

         BEGIN
         MSD_DEM_COLLECT_RETURN_HISTORY.COLLECT_RETURN_HISTORY_DATA
                              (l_errbuff1,
                               l_retcode1,
                               p_sr_instance_id,
                               p_collection_group,
                               p_collection_method,
                               p_date_range_type,
                               p_collection_window,
                               p_from_date,
                               p_to_date,
                               'BIIO_SCI:MSD_ON_HAND_INVENTORY',
                               1
                                );




          IF l_retcode1 = -1
          THEN
             retcode := l_retcode1;
             errbuf  := l_errbuff1;
             msd_dem_common_utilities.log_message ('An Error occured in API call MSD_DEM_COLLECT_RETURN_HISTORY.COLLECT_RETURN_HISTORY_DATA,while inserting On Hand Inventory Data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
             RETURN;
          END IF;
         EXCEPTION
          WHEN OTHERS THEN
            retcode := -1 ;
	    errbuf  := substr(SQLERRM,1,150);
            msd_dem_common_utilities.log_message ('Exception while inserting ON-Hand Inventory Data in the table BIIIO_SCI - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (errbuf);
            RETURN;

         END;

         -- Actual Production
         BEGIN

         MSD_DEM_COLLECT_RETURN_HISTORY.COLLECT_RETURN_HISTORY_DATA
                              (l_errbuff2,
                               l_retcode2,
                               p_sr_instance_id,
                               p_collection_group,
                               p_collection_method,
                               p_date_range_type,
                               p_collection_window,
                               p_from_date,
                               p_to_date,
                               'BIIO_SCI:MSD_ACTUAL_PRODUCTION',
                               2
                                );



          IF l_retcode2 = -1
          THEN
             retcode := l_retcode2;
             errbuf  := l_errbuff2;
             msd_dem_common_utilities.log_message ('An Error occured in API call MSD_DEM_COLLECT_RETURN_HISTORY.COLLECT_RETURN_HISTORY_DATA,while merging Actual Production Data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
             RETURN;
          END IF;


         EXCEPTION
          WHEN OTHERS THEN
            retcode := -1 ;
	    errbuf  := substr(SQLERRM,1,150);
            msd_dem_common_utilities.log_message ('Exception while merging Actual Production Data in the table BIIIO_SCI - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (errbuf);
            RETURN;
         END;

         IF ( l_retcode1 = 1 ) OR ( l_retcode2 = 1)
         THEN
           retcode := 1;
           msd_dem_common_utilities.log_message ('Warning Text for On-Hand Inventory Insertion is - ' || l_errbuff1);
           msd_dem_common_utilities.log_message ('Warning Text for Actual Production Merge is - ' || l_errbuff2);
           errbuf  := l_errbuff1 || l_errbuff2 ;
         END IF;
    END IF;  -- IF ( p_entity = G_SCI_BACKLOG )

    msd_dem_common_utilities.log_message ('Exiting: msd_dem_sop.launch_sci_data_loads - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

 EXCEPTION
   WHEN OTHERS THEN
            retcode := -1 ;
	    errbuf  := substr(SQLERRM,1,150);
            msd_dem_common_utilities.log_message ('Exception: msd_dem_sop.launch_sci_data_loads- ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (errbuf);
            RETURN;

 END LAUNCH_SCI_DATA_LOADS;



END MSD_DEM_SOP;

/
