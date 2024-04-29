--------------------------------------------------------
--  DDL for Package Body MSD_DEM_PUSH_SETUP_PARAMETERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_PUSH_SETUP_PARAMETERS" AS
/* $Header: msddempspb.pls 120.1.12010000.5 2009/03/31 12:37:28 nallkuma ship $ */

   /*** CUSTOM DATA TYPES ***/

         TYPE PROFILE_REC	IS RECORD (
         				profile_code		VARCHAR2(50),
         				profile_value		VARCHAR2(255),
         				function_name		VARCHAR2(100),
         				destination_flag	VARCHAR2(1),
         				function_profile_code	VARCHAR2(1));

         TYPE PROFILE_TAB	IS TABLE OF PROFILE_REC INDEX BY BINARY_INTEGER;

   /*** GLOBAL VARIABLES ***/
      g_dblink		VARCHAR2(50)  	:= NULL;
      g_profile_list	PROFILE_TAB;
      g_num_profiles	NUMBER	       	:= -1;
      g_msd_schema_name	VARCHAR2(50)	:= NULL;
      /* Master Organizatioin parameter name */
    g_master_org VARCHAR2(50)   := 'MSD_DEM_MASTER_ORG';
    /* Source Category Set parameter name */
    g_sr_category_set VARCHAR2(50) := 'MSD_DEM_CATEGORY_SET_NAME';
      g_user_id		NUMBER		:= NULL;
      g_login_id	NUMBER		:= NULL;


   /*** PRIVATE FUNCTIONS ***
    * GET_PROFILE_VALUE
    * GET_FUNCTION_VALUE
    * GET_MULTI_ORG_FLAG
    * DECODE_PROFILE_FUNCTION
    */


      FUNCTION GET_PROFILE_VALUE (
      			p_profile_code 		IN VARCHAR2,
      			p_destination_flag	IN VARCHAR2)
      RETURN VARCHAR2
      IS
         x_return_value		VARCHAR2(255);
         x_sql			VARCHAR2(100);
      BEGIN

         IF (p_destination_flag = 'Y')
         THEN
            x_return_value := fnd_profile.value (p_profile_code);
         ELSE
            x_sql := 'BEGIN :x_ret1 := fnd_profile.value' || g_dblink ||
                     '(''' || p_profile_code || '''); END;';
            EXECUTE IMMEDIATE x_sql USING OUT x_return_value;
         END IF;

         RETURN x_return_value;

      EXCEPTION
         WHEN OTHERS THEN
            msd_dem_common_utilities.log_message ('Exception: msd_dem_push_setup_parameters.get_profile_value - ' || sysdate);
            RETURN NULL;

      END GET_PROFILE_VALUE;


      FUNCTION GET_FUNCTION_VALUE (
      			p_function_name 	IN VARCHAR2,
      			p_destination_flag 	IN VARCHAR2)
      RETURN VARCHAR2
      IS
         x_return_value		VARCHAR2(255);
         x_sql			VARCHAR2(100);
      BEGIN

         IF (p_destination_flag = 'Y')
         THEN
            x_sql := 'BEGIN :x_ou1 := ' || p_function_name || '; END;';
            EXECUTE IMMEDIATE x_sql USING OUT x_return_value;
         ELSE
            x_sql := 'BEGIN :x_ou1 := ' || p_function_name || g_dblink || '; END;';
            EXECUTE IMMEDIATE x_sql USING OUT x_return_value;
         END IF;

         RETURN x_return_value;

      EXCEPTION
         WHEN OTHERS THEN
            msd_dem_common_utilities.log_message ('Exception: msd_dem_push_setup_parameters.get_function_value - ' || sysdate);
            RETURN NULL;

      END GET_FUNCTION_VALUE;


      FUNCTION GET_MULTI_ORG_FLAG
      RETURN VARCHAR2
      IS
         x_return_value		VARCHAR2(1);
         x_sql			VARCHAR2(100);
      BEGIN

         x_sql := 'SELECT multi_org_flag FROM fnd_product_groups' || g_dblink ||
                  ' WHERE product_group_type = ''Standard''';
         EXECUTE IMMEDIATE x_sql INTO x_return_value;
         RETURN x_return_value;

      EXCEPTION
         WHEN OTHERS THEN
            msd_dem_common_utilities.log_message ('Exception: msd_dem_push_setup_parameters.get_multi_org_flag - ' || sysdate);
            RETURN NULL;

      END GET_MULTI_ORG_FLAG;


      FUNCTION DECODE_PROFILE_FUNCTION (p_profile_rec  	IN PROFILE_REC)
      RETURN VARCHAR2
      IS
         x_return_value 	VARCHAR2(255);
      BEGIN

         IF (p_profile_rec.function_profile_code = 'P')
         THEN
            x_return_value := to_char(get_profile_value (p_profile_rec.profile_code, p_profile_rec.destination_flag));
         ELSE
            x_return_value := to_char(get_function_value (p_profile_rec.function_name, p_profile_rec.destination_flag));
         END IF;

         RETURN x_return_value;

      EXCEPTION
         WHEN OTHERS THEN
            msd_dem_common_utilities.log_message ('Exception: msd_dem_push_setup_parameters.decode_profile_function - ' || sysdate);
            RETURN NULL;

      END DECODE_PROFILE_FUNCTION;



   /*** PRIVATE PROCEDURES ***
    * CHECK_CUSTOMER_ATTRIBUTE
    * INIT
    * PUSH_PROFILES
    * PUSH_ORGANIZATIONS
    * PUSH_TIME_DATA
    */


      /*
       * Usability Enhancements. Bug # 3509147.
       * This procedure sets the value of the profile MSD_DEM_CUSTOMER_ATTRIBUTE to NONE
       * if collecting for the first time.
       */
      PROCEDURE CHECK_CUSTOMER_ATTRIBUTE (
      			errbuf         		OUT  NOCOPY VARCHAR2,
      			retcode        		OUT  NOCOPY VARCHAR2)
      IS

         /*** LOCAL VARIABLES ***/

            x_errbuf		          VARCHAR2(200)	 := NULL;
            x_retcode		          VARCHAR2(100)	 := NULL;

            x_check_customer_attr_log_msg VARCHAR2(1000) := 'Warning - The collection of customers, ship to locations (customer sites), regions,
and other level values in the geography dimension from e-business source
instance to Demand Planning depends on the profile, MSD:Customer Attribute.
It is recommended to set the profile to selectively collect these level values.
To collect all the available geography dimension level values, please clear
out the dummy profile value. Until the profile value is set appropriately or
cleared out, only the dummy level value (other) will be collected into
Demand Management for geography dimension.';

            x_is_table_not_empty	  NUMBER         := -1;
            x_set_profile		  NUMBER	 := -1;
            x_sql			  VARCHAR2(1000) := NULL;

      BEGIN

         msd_dem_common_utilities.log_debug ('Entering: msd_dem_push_setup_parameters.check_customer_attribute - ' || sysdate);

         /*
          * If collecting for the first time, then the table msd_dem_setup_parameters
          * will be empty in the source instance
          */
         x_sql := 'SELECT count(*) FROM msd_dem_setup_parameters' || g_dblink;
         EXECUTE IMMEDIATE x_sql INTO x_is_table_not_empty;

         IF (x_is_table_not_empty = 0)
         THEN

            x_sql := 'BEGIN :x_out1 := msd_dem_sr_util.set_customer_attribute' || g_dblink ||
                     ' (''MSD_DEM_CUSTOMER_ATTRIBUTE'', ''NONE'', ''SITE''); END;';
            EXECUTE IMMEDIATE x_sql USING OUT x_set_profile;
            msd_dem_common_utilities.log_message (x_check_customer_attr_log_msg);

            IF (x_set_profile = 2)
            THEN
               retcode := -1;
               errbuf := 'Error while Setting Value for Profile MSD_CUSTOMER_ATTRIBUTE';
               msd_dem_common_utilities.log_message ('Error: msd_dem_push_setup_parameters.check_customer_attribute - ' || sysdate);
               msd_dem_common_utilities.log_message ('Error while Setting Value for Profile MSD_CUSTOMER_ATTRIBUTE');
               RETURN;
            END IF;

            COMMIT;
            retcode := 1;
         END IF;
         msd_dem_common_utilities.log_debug ('Exiting: msd_dem_push_setup_parameters.check_customer_attribute - ' || sysdate);

      EXCEPTION
         WHEN OTHERS THEN
            retcode := -1 ;
	    errbuf  := substr(SQLERRM,1,150);
	    msd_dem_common_utilities.log_message ('Exception: msd_dem_push_setup_parameters.check_customer_attribute - ' || sysdate);
	    msd_dem_common_utilities.log_message (errbuf);
	    RETURN;

      END CHECK_CUSTOMER_ATTRIBUTE;


      /*
       * This procedure initializes the profiles nested table.
       */
      PROCEDURE INIT (
      			errbuf         		OUT  NOCOPY VARCHAR2,
      			retcode        		OUT  NOCOPY VARCHAR2)
      IS

         /*** LOCAL VARIABLES ***/

            x_errbuf		VARCHAR2(200)	:= NULL;
            x_retcode		VARCHAR2(100)	:= NULL;

      BEGIN

         msd_dem_common_utilities.log_debug ('Entering: msd_dem_push_setup_parameters.init - ' || sysdate);

         g_profile_list(1).profile_code := 'MSD_DEM_CATEGORY_SET_NAME';
         g_profile_list(1).function_name := 'MSD_DEM_SR_UTIL.GET_CATEGORY_SET_ID';
         g_profile_list(1).destination_flag := 'N';
         g_profile_list(1).function_profile_code := 'F';

         g_profile_list(2).profile_code := 'MSD_DEM_CONVERSION_TYPE';
         g_profile_list(2).function_name := 'MSD_DEM_SR_UTIL.GET_CONVERSION_TYPE';
         g_profile_list(2).destination_flag := 'N';
         g_profile_list(2).function_profile_code := 'F';

         g_profile_list(3).profile_code := 'MSD_DEM_CURRENCY_CODE';
         g_profile_list(3).destination_flag := 'Y';
         g_profile_list(3).function_profile_code := 'P';

         g_profile_list(4).profile_code := 'MSD_DEM_MASTER_ORG';
         g_profile_list(4).function_name := 'MSD_DEM_SR_UTIL.GET_MASTER_ORGANIZATION';
         g_profile_list(4).destination_flag := 'N';
         g_profile_list(4).function_profile_code := 'F';

         g_profile_list(5).profile_code := 'MSD_DEM_CUSTOMER_ATTRIBUTE';
         g_profile_list(5).function_name := 'MSD_DEM_SR_UTIL.GET_CUSTOMER_ATTRIBUTE';
         g_profile_list(5).destination_flag := 'N';
         g_profile_list(5).function_profile_code := 'F';

         g_profile_list(6).profile_code := 'MSD_DEM_TWO_LEVEL_PLANNING';
         g_profile_list(6).destination_flag := 'Y';
         g_profile_list(6).function_profile_code := 'P';

         g_profile_list(7).profile_code := 'MSD_DEM_SCHEMA';
         g_profile_list(7).destination_flag := 'Y';
         g_profile_list(7).function_profile_code := 'P';

         g_profile_list(8).profile_code := 'MSD_DEM_PLANNING_PERCENTAGE';
         g_profile_list(8).destination_flag := 'Y';
         g_profile_list(8).function_profile_code := 'P';

         g_profile_list(9).profile_code := 'MSD_DEM_INCLUDE_DEPENDENT_DEMAND';
         g_profile_list(9).destination_flag := 'Y';
         g_profile_list(9).function_profile_code := 'P';

         g_profile_list(10).profile_code := 'MSD_DEM_EXPLODE_DEMAND_METHOD';
         g_profile_list(10).destination_flag := 'Y';
         g_profile_list(10).function_profile_code := 'P';

         g_num_profiles := g_profile_list.LAST;

         msd_dem_common_utilities.log_debug ('Exiting: msd_dem_push_setup_parameters.init - ' || sysdate);

      EXCEPTION
         WHEN OTHERS THEN
            retcode := -1 ;
	    errbuf  := substr(SQLERRM,1,150);
	    msd_dem_common_utilities.log_message ('Exception: msd_dem_push_setup_parameters.init - ' || sysdate);
	    msd_dem_common_utilities.log_message (errbuf);
	    RETURN;

      END INIT;


      /*
       * This procedure pushes the profiles and their values to the source instance
       * in MSD_DEM_SETUP_PARAMETERS.
       */
      PROCEDURE PUSH_PROFILES (
      			errbuf         		OUT  NOCOPY VARCHAR2,
      			retcode        		OUT  NOCOPY VARCHAR2,
      			p_sr_instance_id	IN	    NUMBER,
      			p_dblink		IN	    VARCHAR2)
      IS

         /*** LOCAL VARIABLES ***/

            x_errbuf		VARCHAR2(200)	:= NULL;
            x_retcode		VARCHAR2(100)	:= NULL;

            x_error		NUMBER		:= -1;
            x_warning		NUMBER		:= -1;
            x_master_org_prf_value	VARCHAR2(100)	:= NULL;
            x_multi_org_flag		VARCHAR2(1)	:= NULL;

            x_sql			VARCHAR2(1000)  := NULL;

      BEGIN

         msd_dem_common_utilities.log_debug ('Entering: msd_dem_push_setup_parameters.push_profiles - ' || sysdate);

         x_sql := 'alter session set session_cached_cursors = 0';
         execute immediate x_sql;


         msd_dem_common_utilities.log_message (' Push Profiles ');
         msd_dem_common_utilities.log_message ('---------------');
         msd_dem_common_utilities.log_message (' ');
	 msd_dem_common_utilities.log_message ('-------------------------------------------------------------');
         msd_dem_common_utilities.log_message ('    Profile Name                        -    Value');
         msd_dem_common_utilities.log_message ('-------------------------------------------------------------');

         /* Initializing profiles */
         init (x_errbuf,
               x_retcode);

         /* Get the Profile values */
         FOR i IN g_profile_list.FIRST..g_profile_list.LAST
         LOOP
            g_profile_list(i).profile_value := decode_profile_function (g_profile_list(i));
            msd_dem_common_utilities.log_message (rpad('Profile ' || g_profile_list(i).profile_code,40)
                                                    || '-  ' || g_profile_list(i).profile_value);
         END LOOP;

         msd_dem_common_utilities.log_message ('-------------------------------------------------------------');
         msd_dem_common_utilities.log_message (' ');

         /* Check if all the mandatory profiles are defined */
         IF (   (g_profile_list(2).profile_value IS NULL)
             OR (g_profile_list(3).profile_value IS NULL)
             OR (g_profile_list(4).profile_value IS NULL)
             OR (g_profile_list(7).profile_value IS NULL)
             OR (g_profile_list(8).profile_value IS NULL)
             OR (g_profile_list(9).profile_value IS NULL)
             OR (g_profile_list(10).profile_value IS NULL))
         THEN
            x_error := 1;
         END IF;

         /* In case of multi org, l_para_prof(4) will have master org id
          * through master_organization function call even though
          * profile value is not specified.  In this case, give warning to user
          * to confirm that master_org_id for the source will be the org_id from
          * master_organization function call, not from the source profile value
          */
         IF (g_profile_list(4).profile_value IS NOT NULL)
         THEN
            x_master_org_prf_value := get_profile_value ('MSD_DEM_MASTER_ORG', 'N');
            x_multi_org_flag       := get_multi_org_flag;
            IF (    x_master_org_prf_value IS NULL
                AND x_multi_org_flag = 'Y')
            THEN
               x_warning := 1;
            END IF;
         END IF;

         /* If Two-Level Planning has not been set, then default it to NO
          */
         IF (g_profile_list(6).profile_value IS NULL)
         THEN
            msd_dem_common_utilities.log_message ('Profile ' ||
                                                  g_profile_list(6).profile_code ||
                                                  ' is not defined. Defaulting this profile to - ');
            msd_dem_common_utilities.log_message ('''Exclude family members with forecast control NONE''');
            g_profile_list(6).profile_value := 2;

         END IF;

	 IF ( (x_error <> 1) AND (x_warning = 1) )
	 THEN
	    msd_dem_common_utilities.log_message ('Profile ' || g_profile_list(4).profile_code ||
	                                          ' in the Source instance NOT SET !!!');
	    msd_dem_common_utilities.log_message ('The system has determined to use Organization Id = ' ||
	                                          g_profile_list(4).profile_value ||
	                                          ' as the master org.');
	    msd_dem_common_utilities.log_message ('If this is not the master org, please update the MSD_DEM_MASTER_ORG profile on the Source');
	    msd_dem_common_utilities.log_message ('and rerun collections.');
	 END IF;

         IF (x_error = 1)
         THEN
            msd_dem_common_utilities.log_message ('Please make sure that profiles ' ||
                                                  'MSD_DEM_CONVERSION_TYPE and MSD_DEM_MASTER_ORG are set in Source instance');
            msd_dem_common_utilities.log_message (' and MSD_DEM_PLANNING_PERCENTAGE and MSD_DEM_INCLUDE_DEPENDENT_DEMAND and MSD_DEM_EXPLODE_DEMAND_METHOD');
            msd_dem_common_utilities.log_message (' and MSD_DEM_CURRENCY_CODE and MSD_DEM_SCHEMA profiles in the Planning Server are set.');

            retcode := -1;
            errbuf  := 'Profiles not set';
            RETURN;
         ELSE

            msd_dem_common_utilities.log_message (' Actions');
            msd_dem_common_utilities.log_message ('---------');

            msd_dem_common_utilities.log_message ('Deleting records from msd_dem_setup_parameters in the Source instance');
/*            x_sql := 'TRUNCATE TABLE ' || g_msd_schema_name || '.msd_dem_setup_parameters' || g_dblink;
*/
            x_sql := 'DELETE FROM msd_dem_setup_parameters' || g_dblink;

            EXECUTE IMMEDIATE x_sql;

            msd_dem_common_utilities.log_message ('Inserting profiles into source msd_dem_setup_parameters');
            x_sql := 'INSERT INTO msd_dem_setup_parameters' || g_dblink ||
                     ' (parameter_name, parameter_value, last_update_date, last_updated_by, creation_date, ' ||
                     '  created_by, last_update_login) values (:1, :2, sysdate, :3, sysdate, ' ||
                     '  :4, :5)';

            FOR j IN g_profile_list.FIRST..g_profile_list.LAST
            LOOP
               EXECUTE IMMEDIATE x_sql USING g_profile_list(j).profile_code, g_profile_list(j).profile_value, g_user_id, g_user_id, g_login_id;
            END LOOP;

            COMMIT;

            msd_dem_common_utilities.log_message (' ');

         END IF;


         msd_dem_common_utilities.log_debug ('Exiting: msd_dem_push_setup_parameters.push_profiles - ' || sysdate);

      EXCEPTION
         WHEN OTHERS THEN
            retcode := -1 ;
	    errbuf  := substr(SQLERRM,1,150);
	    msd_dem_common_utilities.log_message ('Exception: msd_dem_push_setup_parameters.push_profiles - ' || sysdate);
	    msd_dem_common_utilities.log_message (errbuf);
	    RETURN;

      END PUSH_PROFILES;


      /*
       * This procedure pushes the collection enabled orgs to the source instance
       * in MSD_DEM_APP_INSTANCE_ORGS.
       */
      PROCEDURE PUSH_ORGANIZATIONS (
      			errbuf         		OUT  NOCOPY VARCHAR2,
      			retcode        		OUT  NOCOPY VARCHAR2,
      			p_sr_instance_id	IN	    NUMBER,
      			p_collection_group      IN	    VARCHAR2,
      			p_dblink		IN	    VARCHAR2)
      IS

         /*** LOCAL VARIABLES ***/

            x_errbuf		VARCHAR2(200)	:= NULL;
            x_retcode		VARCHAR2(100)	:= NULL;

            x_sql			VARCHAR2(1000)  := NULL;

      BEGIN

         msd_dem_common_utilities.log_debug ('Entering: msd_dem_push_setup_parameters.push_organizations - ' || sysdate);

         msd_dem_common_utilities.log_message (' Push Organizations - Actions');
         msd_dem_common_utilities.log_message ('------------------------------');
         msd_dem_common_utilities.log_message (' ');

         msd_dem_common_utilities.log_message ('Deleting Organizations from source msd_dem_app_instance_orgs');
/*         x_sql := 'TRUNCATE TABLE ' || g_msd_schema_name || '.msd_dem_app_instance_orgs' || g_dblink;
*/
         x_sql := 'DELETE FROM msd_dem_app_instance_orgs' || g_dblink;

         EXECUTE IMMEDIATE x_sql;

         msd_dem_common_utilities.log_message ('Inserting Organizations into source msd_dem_app_instance_orgs');
         x_sql := 'INSERT INTO msd_dem_app_instance_orgs' || g_dblink ||
                  ' ( organization_id, organization_code, last_update_date, last_updated_by, creation_date, ' ||
                  '   created_by, last_update_login) ' ||
                  ' SELECT mtp.sr_tp_id, mtp.organization_code, sysdate, :a1, sysdate, ' ||
                  '  :a2, :a3 ' ||
                  ' FROM msc_instance_orgs mio, ' ||
                  '      msc_trading_partners mtp ' ||
                  ' WHERE mio.sr_instance_id = :1 ' ||
                  '   AND nvl(mio.org_group, ''-888'') = decode( :2, ''-999'', nvl(mio.org_group, ''-888''), :3) ' ||
                  '   AND nvl(mio.dp_enabled_flag, mio.enabled_flag) = 1 ' ||
                  '   AND mtp.sr_instance_id = mio.sr_instance_id ' ||
                  '   AND mtp.sr_tp_id = mio.organization_id ' ||
                  '   AND mtp.partner_type = 3';
         EXECUTE IMMEDIATE x_sql USING g_user_id, g_user_id, g_login_id, p_sr_instance_id, p_collection_group, p_collection_group;

         COMMIT;

         msd_dem_common_utilities.log_message (' ');
         msd_dem_common_utilities.log_debug ('Exiting: msd_dem_push_setup_parameters.push_organizations - ' || sysdate);

      EXCEPTION
         WHEN OTHERS THEN
            retcode := -1 ;
	    errbuf  := substr(SQLERRM,1,150);
	    msd_dem_common_utilities.log_message ('Exception: msd_dem_push_setup_parameters.push_organizations - ' || sysdate);
	    msd_dem_common_utilities.log_message (errbuf);
	    RETURN;

      END PUSH_ORGANIZATIONS;


      /*
       * This procedure pushes the time data to the source instance
       * in MSD_DEM_INPUTS
       */
      PROCEDURE PUSH_TIME_DATA (
      			errbuf         		OUT  NOCOPY VARCHAR2,
      			retcode        		OUT  NOCOPY VARCHAR2,
      			p_sr_instance_id	IN	    NUMBER,
      			p_dblink		IN	    VARCHAR2)
      IS

         CURSOR c_get_table (p_lookup_code   VARCHAR2)
         IS
            SELECT meaning
            FROM fnd_lookup_values_vl
            WHERE lookup_type = 'MSD_DEM_TABLES'
              AND lookup_code = p_lookup_code;

         /*** LOCAL VARIABLES ***/

            x_errbuf			VARCHAR2(200)	:= NULL;
            x_retcode			VARCHAR2(100)	:= NULL;

            x_sql			VARCHAR2(1000)  := NULL;

            x_dm_table			VARCHAR2(100)    := NULL;
            x_source_time_table		VARCHAR2(100)    := NULL;
            x_start_date		VARCHAR2(100)   := NULL;
            x_end_date			VARCHAR2(100)   := NULL;

            x_time_bucket		VARCHAR2(30)    := NULL;
            x_first_day_of_week 	VARCHAR2(30)    := NULL;
            x_aggregation_method      	NUMBER(1)	:= NULL;
            x_actual_agg_method		NUMBER(1)	:= NULL;

      BEGIN

         msd_dem_common_utilities.log_debug ('Entering: msd_dem_push_setup_parameters.push_time_data - ' || sysdate);


         msd_dem_common_utilities.log_message (' Push Time Data - Actions');
         msd_dem_common_utilities.log_message ('------------------------------');
         msd_dem_common_utilities.log_message (' ');

         msd_dem_common_utilities.log_message ('Deleting time data from source msd_dem_dates');
         x_sql := 'DELETE FROM msd_dem_dates' || g_dblink;
         EXECUTE IMMEDIATE x_sql;

	 x_dm_table := msd_dem_common_utilities.get_lookup_value ('MSD_DEM_TABLES', 'DM_WIZ_DM_DEF');

         /* Get the time level info for the active data model */
         x_sql := 'SELECT time_bucket, first_day_of_week, aggregation_method ' ||
                  ' FROM ' || x_dm_table ||
                  ' WHERE dm_or_template = 2 ' ||
                  '   AND is_active = 1 ';

         EXECUTE IMMEDIATE x_sql INTO x_time_bucket, x_first_day_of_week, x_aggregation_method;

         IF (upper(x_time_bucket) = 'DAY')
         THEN
            msd_dem_common_utilities.log_message ('Lowest Time Bucket - Day : Time data not inserted into source msd_dem_dates');
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
            msd_dem_common_utilities.log_message ('Error(1): msd_dem_push_setup_parameters.push_time_data - ' || sysdate);
            msd_dem_common_utilities.log_message ('Invalid time bucket');
            RETURN;
         END IF;

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

         msd_dem_common_utilities.log_message ('Inserting time data into source msd_dem_dates');
         x_sql := 'INSERT INTO msd_dem_dates' || g_dblink ||
                  ' (datet, num_of_days, start_date, end_date, last_update_date, last_updated_by, creation_date, created_by, last_update_login) ' ||
                  ' SELECT datet, num_of_days, ' || x_start_date || x_end_date ||
                  ' sysdate, :1, sysdate, :2, :3 ' ||
                  ' FROM ' || x_source_time_table;
         EXECUTE IMMEDIATE x_sql USING g_user_id, g_user_id, g_login_id;

         COMMIT;

         IF (g_dblink IS NOT NULL)
         THEN

            msd_dem_common_utilities.log_message ('Deleting time data from destination msd_dem_dates');
            x_sql := 'DELETE FROM msd_dem_dates';
            EXECUTE IMMEDIATE x_sql;

            msd_dem_common_utilities.log_message ('Inserting time data into destination msd_dem_dates');
            x_sql := 'INSERT INTO msd_dem_dates' ||
                     ' (datet, num_of_days, start_date, end_date, last_update_date, last_updated_by, creation_date, created_by, last_update_login) ' ||
                     ' SELECT datet, num_of_days, ' || x_start_date || x_end_date ||
                     ' sysdate, :1, sysdate, :2, :3 ' ||
                     ' FROM ' || x_source_time_table;
            EXECUTE IMMEDIATE x_sql USING g_user_id, g_user_id, g_login_id;

            msd_dem_common_utilities.log_message ('Analyzing destination msd_dem_dates');
            msd_dem_collect_history_data.analyze_table (x_errbuf, x_retcode, 'MSD_DEM_DATES');

            COMMIT;

         END IF;

         msd_dem_common_utilities.log_debug ('Exiting: msd_dem_push_setup_parameters.push_time_data - ' || sysdate);

      EXCEPTION
         WHEN OTHERS THEN
            retcode := -1 ;
	    errbuf  := substr(SQLERRM,1,150);
	    msd_dem_common_utilities.log_message ('Exception: msd_dem_push_setup_parameters.push_time_data - ' || sysdate);
	    msd_dem_common_utilities.log_message (errbuf);
	    RETURN;

      END PUSH_TIME_DATA;



   /*** PUBLIC PROCEDURES ***/

      /*
       * This procedure pushes the profile values, collection enabled orgs and
       * the time data in the source instance, which will be used in the source
       * views.
       */
      PROCEDURE PUSH_SETUP_PARAMETERS (
      			errbuf         		OUT  NOCOPY VARCHAR2,
      			retcode        		OUT  NOCOPY VARCHAR2,
      			p_sr_instance_id	IN	    NUMBER,
      			p_collection_group	IN	    VARCHAR2)
      IS

         /*** LOCAL VARIABLES ***/

            x_errbuf		VARCHAR2(200)	:= NULL;
            x_retcode		VARCHAR2(100)	:= NULL;

            x_sql		VARCHAR2(500)	:= NULL;

            x_dem_schema	       VARCHAR2(50)	:= NULL; --jarora

         CURSOR c_get_dm_schema         --jarora
         IS
         SELECT owner
         FROM dba_objects
         WHERE  owner = owner
            AND object_type = 'TABLE'
            AND object_name = 'MDP_MATRIX'
         ORDER BY created desc;

      BEGIN

         msd_dem_common_utilities.log_debug ('Entering: msd_dem_push_setup_parameters.push_setup_parameters - ' || sysdate);

         /* Get the db link to the source instance */
         msd_dem_common_utilities.get_dblink (
         			x_errbuf,
         			x_retcode,
         			p_sr_instance_id,
         			g_dblink);

         IF (x_retcode = '-1')
         THEN
            retcode := -1;
            errbuf := x_errbuf;
            msd_dem_common_utilities.log_message ('Error(1): msd_dem_push_setup_parameters.push_setup_parameters - ' || sysdate);
            RETURN;
         END IF;

         /* Get the msd schema name */
/*         x_sql := 'DECLARE x_retval BOOLEAN; x_dummy1 VARCHAR2(50); x_dummy2 VARCHAR2(50); BEGIN x_retval := fnd_installation.get_app_info' || g_dblink || ' ( ''MSD'', x_dummy1, x_dummy2, :x_out1); END;';
         EXECUTE IMMEDIATE x_sql USING OUT g_msd_schema_name;

         msd_dem_common_utilities.log_debug ('MSD Schema: ' || g_msd_schema_name);
*/
         msd_dem_common_utilities.log_message ('               Push Setup Parameters Program');
         msd_dem_common_utilities.log_message ('               -----------------------------');
         msd_dem_common_utilities.log_message ('               Source Instance ID : ' || p_sr_instance_id);
         msd_dem_common_utilities.log_message ('               DB Link: ' || g_dblink);
	 msd_dem_common_utilities.log_message ('  ');

         g_user_id := fnd_global.user_id;
         g_login_id := fnd_global.login_id;

         /* Set the profile MSD_DEM_CUSTOMER_ATTRIBUTE to 'NONE' if collecting for the first time */
         check_customer_attribute (
         	x_errbuf,
         	x_retcode);

         IF (x_retcode = '-1')
         THEN
            retcode := -1;
            errbuf := x_errbuf;
            msd_dem_common_utilities.log_message ('Error(2): msd_dem_push_setup_parameters.push_setup_parameters - ' || sysdate);
            RETURN;
         ELSE
            retcode := x_retcode;
         END IF;

         /* Push the profile values to the source instance */
         push_profiles (
         	x_errbuf,
         	x_retcode,
         	p_sr_instance_id,
         	g_dblink);

         IF (x_retcode = '-1')
         THEN
            retcode := -1;
            errbuf := x_errbuf;
            msd_dem_common_utilities.log_message ('Error(3): msd_dem_push_setup_parameters.push_setup_parameters - ' || sysdate);
            RETURN;
         END IF;

         /* Push the profile values to the source instance */
         push_organizations (
         	x_errbuf,
         	x_retcode,
         	p_sr_instance_id,
         	p_collection_group,
         	g_dblink);

         IF (x_retcode = '-1')
         THEN
            retcode := -1;
            errbuf := x_errbuf;
            msd_dem_common_utilities.log_message ('Error(4): msd_dem_push_setup_parameters.push_organizations - ' || sysdate);
            RETURN;
         END IF;

         OPEN c_get_dm_schema;                    --jarora
         FETCH c_get_dm_schema INTO x_dem_schema;
         CLOSE c_get_dm_schema;

       /* Demantra is Installed */
      IF (x_dem_schema is not NULL)  --jarora
      THEN

         /* Push the time data to the source instance */
         push_time_data (
         	x_errbuf,
         	x_retcode,
         	p_sr_instance_id,
         	g_dblink);

         IF (x_retcode = '-1')
         THEN
            retcode := -1;
            errbuf := x_errbuf;
            msd_dem_common_utilities.log_message ('Error(5): msd_dem_push_setup_parameters.push_setup_parameters - ' || sysdate);
            RETURN;
         END IF;

      ELSE
        NULL;
      END IF;                      --jarora

         COMMIT;

         msd_dem_common_utilities.log_debug ('Exiting: msd_dem_push_setup_parameters.push_setup_parameters - ' || sysdate);

      EXCEPTION
         WHEN OTHERS THEN
            retcode := -1 ;
	    errbuf  := substr(SQLERRM,1,150);
	    msd_dem_common_utilities.log_message ('Exception: msd_dem_push_setup_parameters.push_setup_parameters - ' || sysdate);
	    msd_dem_common_utilities.log_message (errbuf);
	    RETURN;

      END PUSH_SETUP_PARAMETERS;

    /*
     * This procedure updates profiles values configure for a particular legacy instance
     * to the legacy profiles table - MSD_DEM_LEGACY_SETUP_PARAMS
     */
    PROCEDURE CONFIGURE_LEGACY_PROFILES (
      			errbuf         		OUT  NOCOPY VARCHAR2,
      			retcode        		OUT  NOCOPY VARCHAR2,
      			p_legacy_instance_id 	IN	    NUMBER,
      			p_master_org            IN      NUMBER,
                p_sr_category_set_id    IN      NUMBER)
    IS
        /*** LOCAL VARIABLES ***/
        x_sql		VARCHAR2(500)	:= NULL;

    BEGIN
        msd_dem_common_utilities.log_debug ('Entering: msd_dem_push_setup_parameters.configure_legacy_profiles - ' || sysdate);

        /* check if instance_id or master_org or category_set is null */
        IF (    (p_legacy_instance_id IS NULL)
             OR (p_master_org IS NULL))
         THEN
            retcode := -1;
            errbuf := 'Legacy Instance ID or Master Organization or Category set ID cannot be null.';
            msd_dem_common_utilities.log_message ('Error: msd_dem_push_setup_parameters.push_setup_parameters - ' || sysdate);
            RETURN;
        END IF;

        /* Before inserting parameter values for a legacy instance to the MSD_DEM_LEGACY_SETUP_PARAMS table
         * delete any rows which already exist for this instance.
         */
        msd_dem_common_utilities.log_message ('Deleting records from msd_dem_legacy_setup_params, for instance_id : ' || p_legacy_instance_id );
        x_sql := 'DELETE FROM msd_dem_legacy_setup_params where instance_id = ' || p_legacy_instance_id;
        EXECUTE IMMEDIATE x_sql;

        g_user_id := fnd_global.user_id;
        g_login_id := fnd_global.login_id;

        /* Insert values for the two parameters
         * MSD_DEM_MASTER_ORG and MSD_DEM_CATEGORY_SET_NAME
         * into MSD_DEM_LEGACY_SETUP_PARAMS table
         */
        x_sql := 'INSERT INTO msd_dem_legacy_setup_params' ||
                     ' (instance_id, parameter_name, parameter_value, last_update_date, last_updated_by, creation_date, ' ||
                     '  created_by, last_update_login) values (:1, :2, :3, sysdate, :4, sysdate, ' ||
                     '  :5, :6)';

        msd_dem_common_utilities.log_message ('Inserting profile ' || g_master_org || ' for legacy instance ' || p_legacy_instance_id || ' into msd_dem_legacy_setup_params');
        EXECUTE IMMEDIATE x_sql USING p_legacy_instance_id, g_master_org, p_master_org, g_user_id, g_user_id, g_login_id;

        msd_dem_common_utilities.log_message ('Inserting profile ' || g_sr_category_set || ' for legacy instance ' || p_legacy_instance_id || ' into msd_dem_legacy_setup_params');
        EXECUTE IMMEDIATE x_sql USING p_legacy_instance_id, g_sr_category_set, p_sr_category_set_id, g_user_id, g_user_id, g_login_id;

        COMMIT;

        msd_dem_common_utilities.log_debug ('Exiting: msd_dem_push_setup_parameters.configure_legacy_profiles - ' || sysdate);

    EXCEPTION
        WHEN OTHERS THEN
            retcode := -1 ;
	    errbuf  := substr(SQLERRM,1,150);
	    msd_dem_common_utilities.log_message ('Exception: msd_dem_push_setup_parameters.configure_legacy_profiles - ' || sysdate);
	    msd_dem_common_utilities.log_message (errbuf);
	    RETURN;

    END CONFIGURE_LEGACY_PROFILES;

    /*
     * This procedure pushes profiles values for a particular legacy instance
     * from legacy profiles table - MSD_DEM_LEGACY_SETUP_PARAMS to setup parameters table - MSD_DEM_SETUP_PARAMETERS
     */
    PROCEDURE PUSH_LEGACY_SETUP_PARAMETERS (
      			errbuf         		OUT  NOCOPY VARCHAR2,
      			retcode        		OUT  NOCOPY VARCHAR2,
      			p_legacy_instance_id	IN	    NUMBER)
    IS

        /*** LOCAL VARIABLES ***/
        x_sql		VARCHAR2(500)	:= NULL;
        x_master_org_value      VARCHAR2(240) := NULL;
        x_category_set_value    VARCHAR2(240) := NULL;

    BEGIN

        msd_dem_common_utilities.log_debug ('Entering: msd_dem_push_setup_parameters.push_legacy_setup_parameters - ' || sysdate);

        msd_dem_common_utilities.log_message ('               Push Legacy Setup Parameters Program');
        msd_dem_common_utilities.log_message ('               ------------------------------------');
        msd_dem_common_utilities.log_message ('               Legacy Instance ID : ' || p_legacy_instance_id);
        msd_dem_common_utilities.log_message ('  ');

        g_user_id := fnd_global.user_id;
        g_login_id := fnd_global.login_id;

        /* Push values for the two profiles MSD_DEM_MASTER_ORG and MSD_DEM_CATEGORY_SET_NAME
         * to MSD_DEM_SETUP_PARAMETERS table in the destination
         * as source is a legacy instance
         */
        x_sql := 'SELECT parameter_value FROM msd_dem_legacy_setup_params where instance_id = :1 and parameter_name = :2';

        BEGIN
            msd_dem_common_utilities.log_message ('Fetching value for parameter - ' || g_master_org || ' from msd_dem_legacy_setup_params');
            EXECUTE IMMEDIATE x_sql INTO x_master_org_value USING p_legacy_instance_id, g_master_org;

            /* Master Organization should be set*/
            IF (x_master_org_value IS NULL)
            THEN
                retcode := -1;
                errbuf  := 'Master Organization not set for legacy instance : ' || p_legacy_instance_id;
                msd_dem_common_utilities.log_message (errbuf);
                RETURN;
            END IF;

            msd_dem_common_utilities.log_message ('Fetching value for parameter - ' || g_sr_category_set || ' from msd_dem_legacy_setup_params');
            EXECUTE IMMEDIATE x_sql INTO x_category_set_value USING p_legacy_instance_id, g_sr_category_set;
            -- not checking for value of Category Set as it can be null
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                retcode := -1;
                errbuf  := 'No records found for one or more parameters for legacy instance : ' || p_legacy_instance_id;
                msd_dem_common_utilities.log_message ('Exception: msd_dem_push_setup_parameters.push_legacy_setup_parameters - ' || sysdate);
                msd_dem_common_utilities.log_message (errbuf);
                RETURN;
        END;

        msd_dem_common_utilities.log_message ('Deleting records for profiles ' || g_master_org || ' and ' || g_sr_category_set || ' from msd_dem_setup_parameters in the destination instance');
        x_sql := 'DELETE FROM msd_dem_setup_parameters where parameter_name in (''' || g_master_org || ''', ''' || g_sr_category_set || ''')';
        EXECUTE IMMEDIATE x_sql;

        g_user_id := fnd_global.user_id;
        g_login_id := fnd_global.login_id;

        /* Insert values for the two profiles
         * MSD_DEM_MASTER_ORG and MSD_DEM_CATEGORY_SET_NAME
         * into MSD_DEM_SETUP_PARAMETERS table
         */
        x_sql := 'INSERT INTO msd_dem_setup_parameters' ||
                     ' (parameter_name, parameter_value, last_update_date, last_updated_by, creation_date, ' ||
                     '  created_by, last_update_login) values (:1, :2, sysdate, :3, sysdate, ' ||
                     '  :4, :5)';

        msd_dem_common_utilities.log_message ('Inserting profile ' || g_master_org || ' into msd_dem_setup_parameters');
        EXECUTE IMMEDIATE x_sql USING g_master_org, x_master_org_value, g_user_id, g_user_id, g_login_id;

        msd_dem_common_utilities.log_message ('Inserting profile ' || g_sr_category_set || ' into msd_dem_setup_parameters');
        EXECUTE IMMEDIATE x_sql USING g_sr_category_set, x_category_set_value, g_user_id, g_user_id, g_login_id;

        COMMIT;

        msd_dem_common_utilities.log_debug ('Exiting: msd_dem_push_setup_parameters.push_legacy_setup_parameters - ' || sysdate);

    EXCEPTION
        WHEN OTHERS THEN
            retcode := -1 ;
            errbuf  := substr(SQLERRM,1,150);
            msd_dem_common_utilities.log_message ('Exception: msd_dem_push_setup_parameters.push_legacy_setup_parameters - ' || sysdate);
            msd_dem_common_utilities.log_message (errbuf);
            RETURN;

    END PUSH_LEGACY_SETUP_PARAMETERS;

END MSD_DEM_PUSH_SETUP_PARAMETERS;

/
