--------------------------------------------------------
--  DDL for Package Body MSD_DEM_UPLOAD_FORECAST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_UPLOAD_FORECAST" AS
/* $Header: msddemufb.pls 120.4.12010000.22 2010/03/11 15:13:58 nallkuma ship $ */

   /*** CONSTANTS ***/


      VS_MSG_SALES_TABLE		CONSTANT VARCHAR2(16)	:= 'LOAD SALES TABLE';
      VS_MSG_ITEMS_TABLE		CONSTANT VARCHAR2(16) := 'LOAD ITEMS TABLE';
      VS_MSG_LOCATION_TABLE	CONSTANT VARCHAR2(19)	:= 'LOAD LOCATION TABLE';
      VS_MSG_UPLOAD_FCST	CONSTANT VARCHAR2(15) := 'UPLOAD FORECAST';
      VS_MSG_UPLOAD_PCTG	CONSTANT VARCHAR2(30)     := 'UPLOAD PLANNING PERCENTAGE';
      VS_MSG_UPLOAD_TD		CONSTANT VARCHAR2(30)   := 'UPLOAD TOTAL DEMAND';

      VS_MSG_LOADING		    CONSTANT VARCHAR2(8) := 'Loading ';
      VS_MSG_LOADED		      CONSTANT VARCHAR2(7) := 'Loaded ';
      VS_MSG_STARTED		    CONSTANT VARCHAR2(7) := 'Started';
      VS_MSG_SUCCEEDED	    CONSTANT VARCHAR2(9) := 'Succeeded';
      VS_MSG_LOADE_ERROR	  CONSTANT VARCHAR2(12) := 'Load error: ';
      VS_MSG_ITEMS          CONSTANT VARCHAR2(12) := 'Items';
      VS_MSG_LOCATIONS      CONSTANT VARCHAR2(12) := 'Locations';
      VS_MSG_SALES          CONSTANT VARCHAR2(12) := 'Sales';

   /*** PRIVATE FUNCTIONS ***
    * GET_LEVEL_COLUMN
    * GET_SERIES_COLUMN
    */

      /*
       * This function given the level name gives the level# column for the level
       * in the data profile
       */
      FUNCTION GET_LEVEL_COLUMN (
      			p_data_profile_id	IN NUMBER,
      			p_level_name		IN VARCHAR2)
      RETURN VARCHAR2
      IS
         x_table_name 	VARCHAR2(50)	:= NULL;
         x_sql		VARCHAR2(1000)	:= NULL;

         x_lorder	NUMBER		:= NULL;
         x_level_column VARCHAR2(30)    := NULL;

         /*
          * Bug#7199587 - Use Group Table Id instead of the Table Label field
          *               Use the ID obtained from lookups instead of hard-coded one
          */
         x_group_table_id	NUMBER  := NULL;
         x_level_id_lkup_code VARCHAR2(30) := NULL;

      BEGIN

         /*
          * Bug#7199587 - Use Group Table Id instead of the Table Label field
          *               Use the ID obtained from lookups instead of hard-coded one
          */
         IF (p_level_name = C_ITEM)
         THEN
            x_level_id_lkup_code := 'LEVEL_ITEM';
         ELSIF (p_level_name = C_PRODUCT_FAMILY)
         THEN
            x_level_id_lkup_code := 'LEVEL_PRODUCT_FAMILY';
         ELSIF (p_level_name = C_ORGANIZATION)
         THEN
            x_level_id_lkup_code := 'LEVEL_ORGANIZATION';
         ELSIF (p_level_name = C_SITE)
         THEN
            x_level_id_lkup_code := 'LEVEL_SITE';
         ELSIF (p_level_name = C_CUSTOMER)
         THEN
            x_level_id_lkup_code := 'LEVEL_ACCOUNT';
         ELSIF (p_level_name = C_CUSTOMER_ZONE)
         THEN
            x_level_id_lkup_code := 'LEVEL_TRADING_PARTNER_ZONE';
         ELSIF (p_level_name = C_ZONE)
         THEN
            x_level_id_lkup_code := 'LEVEL_ZONE';
         ELSIF (p_level_name = C_DEMAND_CLASS)
         THEN
            x_level_id_lkup_code := 'LEVEL_DEMAND_CLASS';
         ELSIF (p_level_name = C_PARENT_ITEM)
         THEN
            x_level_id_lkup_code := 'LEVEL_PARENT_ITEM';
         ELSE
            RETURN NULL;
         END IF;

         --syenamar Bug#7199587 /* Bug#8224935 - APP ID */ -- nallkuma
         x_group_table_id := to_number(msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                      x_level_id_lkup_code,
                                                                      1,
                                                                      'group_table_id'));
         /*
          * Return NULL in case group_table_id is null, i.e. no value fetched from lookups.
          * In case lookup contains invalid number exception block at end of function handles it and returns NULL.
         */
         IF (x_group_table_id IS NULL)
         THEN
            RETURN NULL;
         END IF;
         --syenamar

         x_table_name := msd_dem_common_utilities.get_lookup_value ('MSD_DEM_TABLES', 'TRANSFER_QUERY_LEVELS');
         x_sql := 'SELECT tql.lorder ' ||
                     ' FROM ' || x_table_name || ' tql, ';

         x_table_name := NULL;
         x_table_name := msd_dem_common_utilities.get_lookup_value ('MSD_DEM_TABLES', 'GROUP_TABLES');
         x_sql := x_sql || x_table_name || ' gt ' ||
                           ' WHERE gt.group_table_id = ' || x_group_table_id ||
                           '    AND gt.status = ''ACTIVE'' ' ||
                           '    AND gt.group_table_id = tql.level_id ' ||
                           '    AND tql.id = ' || p_data_profile_id;

         EXECUTE IMMEDIATE x_sql INTO x_lorder;

         x_level_column := 'LEVEL' || to_char(x_lorder);

         RETURN upper(x_level_column);

      EXCEPTION
         WHEN OTHERS THEN
	    RETURN NULL;

      END GET_LEVEL_COLUMN;


      /*
       * This function gets the column for the series in the data profile
       */
      FUNCTION GET_SERIES_COLUMN (
      			p_data_profile_id	IN NUMBER,
      			p_series_prefix		IN VARCHAR2,
      			p_add_prefix		IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
      IS
         x_table_name 		VARCHAR2(50)	:= NULL;
         x_sql			VARCHAR2(1000)	:= NULL;

         x_series_prefix 	VARCHAR2(50)	:= NULL;
         x_ffs			VARCHAR2(10)    := NULL;

         x_series		VARCHAR2(50)	:= NULL;


      BEGIN

         IF (p_series_prefix = 'FCST_')
         THEN
            x_series_prefix := p_series_prefix;
            x_ffs := 'C_PRED';
         ELSIF (p_series_prefix IN  ('PRTY_', 'ACRY_'))
         THEN
            x_series_prefix := p_series_prefix;
            x_ffs := '$$$';
         ELSIF (p_series_prefix = 'DKEY_')
         THEN
            x_series_prefix := p_series_prefix || p_add_prefix;
            x_ffs := '$$$';
         ELSE
            RETURN NULL;
         END IF;

         x_table_name := msd_dem_common_utilities.get_lookup_value ('MSD_DEM_TABLES', 'TRANSFER_QUERY_SERIES');
         x_sql := 'SELECT cf.computed_name ' ||
                  '   FROM ' || x_table_name || ' tqs, ';

         x_table_name := NULL;
         x_table_name := msd_dem_common_utilities.get_lookup_value ('MSD_DEM_TABLES', 'COMPUTED_FIELDS');
         x_sql := x_sql || x_table_name || ' cf ' ||
                           ' WHERE tqs.id = ' || p_data_profile_id ||
                           '    AND cf.forecast_type_id = tqs.series_id ' ||
                           '    AND ( upper(cf.computed_name) like ''' || x_series_prefix || '%'' ' ||
                           '         OR upper(cf.computed_name) = ''' || x_ffs || ''') ' ||
                           '    AND rownum < 2 ';

         EXECUTE IMMEDIATE x_sql INTO x_series;

         RETURN upper(x_series);

      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END GET_SERIES_COLUMN;



   /*** PRIVATE PROCEDURES
    * GET_TIME_STRINGS
    */


   /*
    */
   PROCEDURE GET_TIME_STRINGS (
                        p_bucket_type		OUT NOCOPY	NUMBER,
                        p_start_time		OUT NOCOPY	VARCHAR2,
                        p_end_time		OUT NOCOPY	VARCHAR2,
                        p_res_type		OUT NOCOPY	NUMBER,
                        p_time_from_clause	OUT NOCOPY	VARCHAR2,
   			p_time_res		IN 		NUMBER)
   IS

      x_sql			VARCHAR2(1000)	:= NULL;
      x_tgroup_res		VARCHAR2(50)	:= NULL;
      x_dm_wiz_dm_def		VARCHAR2(50)	:= NULL;

      x_tg_res			VARCHAR2(100)	:= NULL;
      x_months_number		NUMBER		:= NULL;
      x_inputs_column		VARCHAR2(50)	:= NULL;
      x_is_default		NUMBER		:= NULL;

      x_dm_time_bucket		VARCHAR2(30)    := NULL;
      x_aggregation_method   	NUMBER(1)	:= NULL;

      x_is_forward	     	BOOLEAN		:= NULL;

      x_inputs			VARCHAR2(50)	:= NULL;
      x_bucket_size		NUMBER		:= NULL;

   BEGIN

      x_tgroup_res := msd_dem_common_utilities.get_lookup_value ('MSD_DEM_TABLES', 'TGROUP_RES');

      IF (x_tgroup_res IS NULL)
      THEN
         RETURN;
      END IF;

      /* Get Time Res Info */
      x_sql := 'SELECT tg_res, months_number, inputs_column, is_default ' ||
               '   FROM ' || x_tgroup_res ||
               '   WHERE tg_res_id = ' || p_time_res;

     EXECUTE IMMEDIATE x_sql INTO x_tg_res,
                                  x_months_number,
                                  x_inputs_column,
                                  x_is_default;

      x_dm_wiz_dm_def := msd_dem_common_utilities.get_lookup_value ('MSD_DEM_TABLES', 'DM_WIZ_DM_DEF');
      IF (x_dm_wiz_dm_def IS NULL)
      THEN
         RETURN;
      END IF;

      /* Get the data model lowest time level */
      x_sql := 'SELECT time_bucket, aggregation_method ' ||
               '   FROM ' || x_dm_wiz_dm_def ||
               '   WHERE  dm_or_template = 2 ' ||
               '      AND is_active = 1 ' ||
               '      AND rownum < 2 ';

      EXECUTE IMMEDIATE x_sql INTO x_dm_time_bucket,
                                   x_aggregation_method;

      /* Get the aggregation type */
      IF (upper(x_dm_time_bucket) = 'DAY')
      THEN
         x_is_forward := FALSE;
      ELSIF (upper(x_dm_time_bucket) = 'WEEK')
      THEN
         IF (x_aggregation_method = 1)
         THEN
            x_is_forward := TRUE;
         ELSE
            x_is_forward := FALSE;
         END IF;
      ELSIF (upper(x_dm_time_bucket) = 'MONTH')
      THEN
         x_is_forward := FALSE;
      ELSE
         RETURN;
      END IF;


      /* Get the time strings */
      IF (upper(x_dm_time_bucket) = 'DAY')
      THEN
         /* Export Time Level = Day */
         IF (x_is_default = 1)
         THEN
            p_bucket_type := C_BUCKET_TYPE_DAY;

            p_start_time := ' exp.sdate ';
            p_end_time := ' exp.sdate ';

            p_res_type := 1;

            RETURN;

         END IF;

         IF (x_months_number IS NOT NULL)
         THEN
            IF (x_months_number = 7)
            THEN
               p_bucket_type := C_BUCKET_TYPE_WEEK;
            ELSE
               p_bucket_type := C_BUCKET_TYPE_MONTH;
            END IF;

            p_start_time := ' exp.sdate ';
            p_end_time := ' exp.sdate + ' || to_char(x_months_number - 1) || ' ';

            p_res_type := 1;

            RETURN;

         END IF;

      ELSIF (upper(x_dm_time_bucket) = 'WEEK')
      THEN
         IF (x_months_number IS NOT NULL)
         THEN
            /* Export Time Level = Day */
            IF (x_is_default = 1)
            THEN
               p_bucket_type := C_BUCKET_TYPE_WEEK;
            ELSE
               p_bucket_type := C_BUCKET_TYPE_MONTH;
            END IF;

            IF (x_is_forward)
            THEN
               p_start_time := ' exp.sdate - ' || to_char((x_months_number * 7) - 1) || ' ';
               p_end_time := ' exp.sdate ';
            ELSE
               p_start_time := ' exp.sdate ';
               p_end_time := ' exp.sdate + ' || to_char((x_months_number * 7) - 1) || ' ';
            END IF;

            p_res_type := 1;

            RETURN;
         END IF;

      ELSIF (upper(x_dm_time_bucket) = 'MONTH')
      THEN
         IF (x_is_default = 1)
         THEN
            p_bucket_type := C_BUCKET_TYPE_MONTH;

            p_start_time := ' exp.sdate ';
            p_end_time := ' round(exp.sdate + 16, ''MONTH'') - 1 ';

            p_res_type := 1;

         END IF;

         RETURN;
      ELSE
         RETURN;
      END IF;

      /* Time Resolution Bucket Size is not fixed, availabe in INPUTS */
      x_inputs := msd_dem_common_utilities.get_lookup_value ('MSD_DEM_TABLES', 'INPUTS');
      IF (x_inputs IS NULL OR x_inputs_column IS NULL)
      THEN
         RETURN;
      END IF;

      p_time_from_clause := ' (SELECT min(datet) start_time, max(datet) end_time ' ||
                            '      FROM ' || x_inputs || ' GROUP BY ' || x_inputs_column ||
                            ' ) inp ';

      IF (upper(x_dm_time_bucket) = 'DAY')
      THEN
         p_res_type := 3;

         p_start_time := ' inp.start_time ';
         p_end_time   := ' inp.end_time ';

      ELSIF (upper(x_dm_time_bucket) = 'WEEK')
      THEN
         IF (x_is_forward)
         THEN
            p_res_type := 2;

            p_start_time := ' inp.start_time - 6 ';
            p_end_time   := ' inp.end_time ';
         ELSE
            p_res_type := 3;

            p_start_time := ' inp.start_time  ';
            p_end_time   := ' inp.end_time + 6 ';
         END IF;
      ELSE
         p_res_type := 3;

         p_start_time := ' inp.start_time ';
         p_end_time   := ' round(inp.end_time + 16, ''MONTH'') - 1 ';
      END IF;

      IF (upper(x_dm_time_bucket) = 'WEEK')
      THEN
         p_bucket_type := C_BUCKET_TYPE_MONTH;
      ELSE

         /* Get the Bucket Type */
         x_sql := 'SELECT count(*) FROM ' || x_inputs || ' WHERE ' || x_inputs_column || ' = 1 ';

         EXECUTE IMMEDIATE x_sql INTO x_bucket_size;

         IF (x_bucket_size = 7)
         THEN
            p_bucket_type := C_BUCKET_TYPE_WEEK;
         ELSE
            p_bucket_type := C_BUCKET_TYPE_MONTH;
         END IF;
      END IF;

      RETURN;

   EXCEPTION
      WHEN OTHERS THEN
         RETURN;
   END GET_TIME_STRINGS;


   /*** PUBLIC FUNCTIONS ***/

      /*
       * This function returns the sr_instance_id to be used for a global forecast
       */
      FUNCTION GET_SR_INSTANCE_ID_FOR_GLOBAL
      RETURN NUMBER
      IS
         CURSOR c_get_sr_instance_id
         IS
            SELECT min(instance_id)
               FROM msc_apps_instances
               WHERE  instance_type <> 3
                  AND validation_org_id IS NOT NULL;

         x_sr_instance_id	NUMBER	:= NULL;
      BEGIN
         -- Check the profile MSD_DEM_SR_INSTANCE_FOR_GLOBAL_FCST, use this value if the profile is set
         x_sr_instance_id := fnd_profile.value('MSD_DEM_SR_INSTANCE_FOR_GLOBAL_FCST');

         -- If the profile is not set find the sr_instance_id using cursor
         if (x_sr_instance_id is null) then
             OPEN c_get_sr_instance_id;
             FETCH c_get_sr_instance_id INTO x_sr_instance_id;
             CLOSE c_get_sr_instance_id;
         end if;

         RETURN x_sr_instance_id;

      EXCEPTION
         WHEN OTHERS THEN
	    RETURN NULL;
      END GET_SR_INSTANCE_ID_FOR_GLOBAL;



      /* This function returns 1 if the data profile is fit for upload to ASCP
       * Current check only includes that a forecast series with internal name
       * starting 'FCST_' must be present.
       */
      FUNCTION IS_VALID_SCENARIO (
      			p_data_profile_id	IN	NUMBER)
      RETURN NUMBER
      IS
         x_fcst_column		VARCHAR2(50)	:= NULL;
      BEGIN
         x_fcst_column := get_series_column (
         				p_data_profile_id,
         				C_FORECAST_SERIES_PREFIX);

         IF (x_fcst_column IS NOT NULL)
         THEN
            RETURN 1;
         END IF;

         RETURN 2;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN 2;
      END IS_VALID_SCENARIO;



      FUNCTION UPLOAD_TO_CP (
      			p_data_profile_id    	IN 	NUMBER)
      RETURN NUMBER
      IS

      CURSOR FCST_AT_ITEM(data_profile_id in NUMBER) is
      select nvl((select 1 from msd_dp_scn_output_levels_v
      WHERE demand_plan_id = 5555555
      and scenario_id = data_profile_id + 5555555
      and level_id = 1),0) from dual;

      CURSOR FCST_AT_GEO(data_profile_id in NUMBER) is
      select nvl((select 1 from msd_dp_scn_output_levels_v
      WHERE demand_plan_id = 5555555
      and scenario_id = data_profile_id + 5555555
      and level_id = 11),0) from dual;

      CURSOR FCST_AT_ORG(data_profile_id in NUMBER) is
      select nvl((select 1 from msd_dp_scn_output_levels_v
      WHERE demand_plan_id = 5555555
      and scenario_id = data_profile_id + 5555555
      and level_id = 7),0) from dual;

      fc_item number;
      fc_geo number;
      fc_org number;

      ret_value number := 0;

      BEGIN

      	OPEN FCST_AT_ITEM(p_data_profile_id);
	FETCH FCST_AT_ITEM into fc_item;
	CLOSE FCST_AT_ITEM;

      	OPEN FCST_AT_GEO(p_data_profile_id);
	FETCH FCST_AT_GEO into fc_geo;
	CLOSE FCST_AT_GEO;

      	OPEN FCST_AT_ORG(p_data_profile_id);
	FETCH FCST_AT_ORG into fc_org;
	CLOSE FCST_AT_ORG;

	IF ( fc_item = 1 and fc_geo = 1 and fc_org = 1) THEN

		ret_value := 1;

	END IF;

	return ret_value;

	EXCEPTION WHEN OTHERS THEN
	return 2;

      END UPLOAD_TO_CP;




      /* This function returns -23453 if the data profile contains non-global
       * forecast, else it returns the id of the source instance for which
       * global forecasting is being done.
       */
      FUNCTION GET_SR_INSTANCE_ID_FOR_PROFILE (
      			p_data_profile_id	IN	NUMBER)
      RETURN NUMBER
      IS
         x_org_level			VARCHAR2(50)	:= NULL;
         x_sr_instance_id_for_global	NUMBER		:= NULL;
      BEGIN
         x_org_level := get_level_column (
         				p_data_profile_id,
         				C_ORGANIZATION);

         IF (x_org_level IS NULL) /* Global */
         THEN
            x_sr_instance_id_for_global := get_sr_instance_id_for_global;

            IF (x_sr_instance_id_for_global IS NOT NULL)
            THEN
               RETURN x_sr_instance_id_for_global;
            ELSE
               RETURN NULL;
            END IF;

         END IF;

         /* Local */
         RETURN -23453;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END GET_SR_INSTANCE_ID_FOR_PROFILE;



      /* This function gets the error type 'MAD' or 'MAPE' given the data
       * profile id
       */
      FUNCTION GET_ERROR_TYPE (
      			p_data_profile_id	IN	NUMBER)
      RETURN VARCHAR2
      IS
         x_error_column		VARCHAR2(50)	:= NULL;
         x_error_type		VARCHAR2(50)	:= NULL;
      BEGIN
         x_error_column := get_series_column (
         				p_data_profile_id,
         				C_FCST_ACRY_SERIES_PREFIX);

         IF (x_error_column IS NULL)
         THEN
            RETURN NULL;
         ELSE

            IF (instr(x_error_column, 'MAD') <> 0)
            THEN
               x_error_type := 'MAD';
            ELSIF (instr(x_error_column, 'MAPE') <> 0)
            THEN
               x_error_type := 'MAPE';
            ELSE
               RETURN NULL;
            END IF;

            RETURN x_error_type;

         END IF;

         RETURN NULL;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END GET_ERROR_TYPE;



      /* This function return 'Y' if the data profile contains global forecast
       * else returns 'N'.
       */
      FUNCTION IS_GLOBAL_SCENARIO (
      			p_data_profile_id	IN	NUMBER)
      RETURN VARCHAR2
      IS
         x_org_level			VARCHAR2(50)	:= NULL;
      BEGIN
         x_org_level := get_level_column (
         				p_data_profile_id,
         				C_ORGANIZATION);

         IF (x_org_level IS NULL) /* Global */
         THEN
            RETURN 'Y';
         END IF;

         RETURN 'N';

      EXCEPTION
         WHEN OTHERS THEN
            RETURN 'N';
      END IS_GLOBAL_SCENARIO;



      /* This function returns the source key of the customer, given the customer
       * zone
       */
      FUNCTION GET_CUSTOMER_FROM_TPZONE (
      			p_tp_zone		IN	VARCHAR2,
      			p_sr_instance_id	IN	NUMBER)
      RETURN NUMBER
      IS

         x_sr_customer_pk	NUMBER	       := NULL;
         x_account_number	VARCHAR2(255)  := NULL;

      BEGIN

         IF (msd_dem_common_utilities.is_use_new_site_format = 0)
         THEN
            x_account_number := to_char(substr (p_tp_zone,
                                                  instr(p_tp_zone, ':', 1) + 1,
                                                  instr(p_tp_zone, ':', 1, 2) - instr(p_tp_zone, ':', 1) - 1));
         ELSE
            x_account_number := to_char(substr (p_tp_zone,
                                                  instr(p_tp_zone, '::', 1) + 2,
                                                  instr(p_tp_zone, '::', 1, 2) - instr(p_tp_zone, '::', 1) - 2));
         END IF;

         IF (x_account_number IS NOT NULL)
         THEN

            SELECT mtil.sr_tp_id
               INTO x_sr_customer_pk
               FROM
                  msc_tp_id_lid mtil
               WHERE
                      mtil.sr_cust_account_number = x_account_number
                      and mtil.sr_instance_id = p_sr_instance_id;

         END IF;

         RETURN x_sr_customer_pk;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END GET_CUSTOMER_FROM_TPZONE;




      /* This function returns the source key of the zone, given the customer zone
       */
      FUNCTION GET_ZONE_FROM_TPZONE (
      			p_tp_zone		IN	VARCHAR2,
      			p_sr_instance_id	IN	NUMBER)
      RETURN NUMBER
      IS

         x_zone		VARCHAR2(255)	:= NULL;
         x_sr_zone_pk	NUMBER		:= NULL;

      BEGIN

         IF (msd_dem_common_utilities.is_use_new_site_format = 0)
         THEN
            x_zone := substr (p_tp_zone,
                              instr(p_tp_zone, ':', 1, 2) + 1);
         ELSE
            x_zone := substr (p_tp_zone,
                              instr(p_tp_zone, '::', 1, 2) + 2);
         END IF;

         IF (x_zone IS NOT NULL)
         THEN
            SELECT mr.region_id
               INTO x_sr_zone_pk
               FROM msc_regions mr
               WHERE
                      mr.zone = x_zone
                  AND mr.sr_instance_id = p_sr_instance_id;
         END IF;

         RETURN x_sr_zone_pk;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END GET_ZONE_FROM_TPZONE;


   /*** PUBLIC PROCEDURES ***/

      /*
       * This procedure, given the export integration data profile name, pushes the
       * forecast data along with forecast accuracy and demand priority from the
       * export view to table MSD_DP_SCN_ENTRIES_DENORM. The member codes are
       * transformed to the corresponding source identifiers. The 'Organization'
       * level member is used to find out the source instance to which the record
       * belongs.
       * The internal names of the series will be used to get the semantic of the
       * series. They are as follows -
       *    1. Forecast Series          - The internal name should start with 'FCST_'
       *    2. Demand Priority Series   - The internal name should start with 'PRTY_'
       *    3. Forecast Accuracy Series - The internal name should start with 'ACRY_'
       *    4. Destination Key Series   - The internal name should start with 'DKEY_'
       */
      PROCEDURE UPLOAD_FORECAST (
      			p_export_data_profile	IN VARCHAR2,
      			p_ind_fcst_series_iname	IN VARCHAR2 DEFAULT NULL,
      			p_dep_fcst_series_iname IN VARCHAR2 DEFAULT NULL)
      IS

         TYPE CUR_TYPE	IS REF CURSOR;
         x_cur_type		CUR_TYPE;

         x_errbuf		VARCHAR2(200)	:= NULL;
         x_retcode		VARCHAR2(100)	:= NULL;

         x_sql			VARCHAR2(2000)	:= NULL;
         x_table_name		VARCHAR2(50)	:= NULL;
         x_schema		VARCHAR(50)	:= NULL;

   	     x_profile_id		NUMBER		:= NULL;
   	     x_export_data_profile	VARCHAR2(50)	:= NULL;
         x_presentation_type	NUMBER		:= NULL;
         x_view_name		VARCHAR2(30)	:= NULL;
         x_time_res_id		NUMBER		:= NULL;
         x_unit_id		NUMBER		:= NULL;
         x_index_id		NUMBER		:= NULL;
         x_data_scale		NUMBER		:= NULL;
         x_integration_type	NUMBER		:= NULL;
         x_export_type		NUMBER		:= NULL;
         x_last_export_date	DATE		:= NULL;
         x_is_view_present      NUMBER		:= 0;

         x_dm_time_bucket	VARCHAR2(30)    := NULL;
         x_aggregation_method   NUMBER(1)	:= NULL;

         x_demand_plan_id	NUMBER		:= NULL;
         x_scenario_id		NUMBER		:= NULL;
         x_demand_id_offset	NUMBER		:= NULL;
         x_bucket_type		NUMBER		:= NULL;
         x_start_time		VARCHAR2(100)	:= NULL;
         x_end_time		VARCHAR2(100)   := NULL;
         x_sr_organization_id	VARCHAR2(50)	:= NULL;
         x_sr_ship_to_loc_id	VARCHAR2(50)	:= NULL;
         x_sr_customer_id	VARCHAR2(100)	:= NULL;
         x_sr_zone_id		VARCHAR2(100)	:= NULL;
         x_sr_demand_class	VARCHAR(50)	:= NULL;
         x_uom_code		VARCHAR2(100)	:= NULL;
         x_quantity		VARCHAR2(500)	:= NULL;
         x_fcst_column		VARCHAR2(200)	:= NULL;
         x_error_type		VARCHAR2(50)	:= NULL;
         x_error_column		VARCHAR2(50)	:= NULL;
	 x_error_column_alias   VARCHAR2(50)    := NULL;
         x_demand_priority_column	VARCHAR2(50) 	:= NULL;

         x_select_clause	VARCHAR2(3000)  := NULL;
         x_from_clause		VARCHAR2(500)	:= NULL;
         x_where_clause		VARCHAR2(3000)  := NULL;
         x_insert_clause	VARCHAR2(1000)	:= NULL;
         x_small_sql		VARCHAR2(600)	:= NULL;
         x_large_sql		VARCHAR2(6000)  := NULL;
         x_inner_view       VARCHAR2(1000)  := NULL;
         x_iv_group_by		VARCHAR2(1000)	:= NULL;

         x_is_global_fcst	NUMBER(1)	:= NULL;

         x_org_level		VARCHAR2(30)    := NULL;
         x_prd_level		VARCHAR2(30)    := NULL;
         x_ship_to_level	VARCHAR2(30)    := NULL;
         x_cust_level		VARCHAR2(30)	:= NULL;
         x_zone_level		VARCHAR2(30)	:= NULL;
         x_cust_zone_level      VARCHAR2(30)    := NULL;
         x_demand_class_level	VARCHAR2(30)    := NULL;

         x_org_key_column	VARCHAR2(30)	:= NULL;
         x_prd_key_column	VARCHAR2(30)	:= NULL;
         x_final_prd_column	VARCHAR2(30)	:= NULL;
         x_ship_to_key_column	VARCHAR2(30)	:= NULL;

         x_sr_instance_id_for_global	NUMBER	:= NULL;

         x_res_type		NUMBER		:= NULL;
         x_time_from_clause	VARCHAR2(500)	:= NULL;

         /* sjagathe - Added for Product Family Forecast Support */
         x_is_pf_level		VARCHAR2(30)	:= NULL;
         x_num_rows		NUMBER		:= 0;

      BEGIN

         /* Alter session to APPS */
         x_small_sql := 'alter session set current_schema = APPS';
         EXECUTE IMMEDIATE x_small_sql;


         x_schema := fnd_profile.value('MSD_DEM_SCHEMA');
         IF (x_schema IS NULL)
         THEN
            raise_application_error (-20001, 'Error: msd_dem_upload_forecast.upload_forecast - Unable to find schema name');
         END IF;



         x_small_sql := ' BEGIN ' || x_schema || '.dl_log_status(''' || VS_MSG_UPLOAD_FCST || ''' , ''' ||
                        VS_MSG_LOADING || ' ' || p_export_data_profile || ''' , ''' || VS_MSG_STARTED || ''' ); END;';

         EXECUTE IMMEDIATE x_small_sql;

         /* Initialize global variables */
         IF (p_export_data_profile IS NULL)
         THEN
            raise_application_error (-20002, 'Error: msd_dem_upload_forecast.upload_forecast - No export data profile name provided');
	 ELSE
            x_export_data_profile := upper(p_export_data_profile);
         END IF;

         /* Get the export data profile info */
         x_table_name := msd_dem_common_utilities.get_lookup_value ('MSD_DEM_TABLES', 'TRANSFER_QUERY');
         x_sql := 'SELECT id, presentation_type, view_name, ' ||
                     ' time_res_id, unit_id, index_id, data_scale, ' ||
                     ' integration_type, export_type, last_export_date ' ||
                     ' FROM ' || x_table_name ||
                     ' WHERE upper(query_name) = ''' || x_export_data_profile || '''';

         OPEN x_cur_type FOR x_sql;
         FETCH x_cur_type INTO x_profile_id,
                               x_presentation_type,
                               x_view_name,
                               x_time_res_id,
                               x_unit_id,
                               x_index_id,
                               x_data_scale,
                               x_integration_type,
                               x_export_type,
                               x_last_export_date;
         CLOSE x_cur_type;

         /* Bug# 6326524 */
         x_sql := 'SELECT count(1) FROM dba_objects ' ||
                     ' WHERE owner = upper(''' || x_schema || ''')' ||
                     '   AND object_type IN (''VIEW'', ''MATERIALIZED VIEW'') ' ||
                     '   AND object_name = upper(''' || x_view_name || ''')';
         EXECUTE IMMEDIATE x_sql INTO x_is_view_present;


            /*** Check basic error conditions - BEGIN ***/

         IF (x_profile_id IS NULL)
         THEN
            raise_application_error (-20003, 'Error: msd_dem_upload_forecast.upload_forecast - Unable to get export data profile id');
         ELSIF (x_integration_type = C_IMPORT_DATA_PROFILE)
         THEN
            raise_application_error (-20004, 'Error: msd_dem_upload_forecast.upload_forecast - ' || p_export_data_profile || 'is not an export data profile');
         ELSIF (x_export_type = C_EXPORT_TYPE_INCR)
         THEN
            raise_application_error (-20005, 'Error: msd_dem_upload_forecast.upload_forecast - Incremental export type is not supported');
         ELSIF (x_index_id IS NOT NULL)
         THEN
            raise_application_error (-20006, 'Error: msd_dem_upload_forecast.upload_forecast - Forecast amount cannot be uploaded');
         ELSIF (x_is_view_present = 0)
         THEN
            raise_application_error (-20007, 'Error: msd_dem_upload_forecast.upload_forecast - Forecast has not yet been exported');
         ELSIF (x_presentation_type = C_PSNT_TYPE_DESC)
         THEN
            raise_application_error (-20008, 'Error: msd_dem_upload_forecast.upload_forecast - Presentation type must by Code');
         END IF;

            /*** Check basic error conditions - END ***/


         x_demand_plan_id := C_DEMAND_PLAN_ID;
         x_scenario_id    := x_profile_id + C_SCENARIO_ID_OFFSET;

         x_select_clause := ' SELECT ' || x_demand_plan_id || ' , ' ||
                                          x_scenario_id || ' , ' ||
                            '             rownum - 1 , ';

            /*** Get Time Info - BEGIN ***/

         get_time_strings (
         		x_bucket_type,
         		x_start_time,
         		x_end_time,
         		x_res_type,
         		x_time_from_clause,
         		x_time_res_id);

         IF (x_res_type IS NULL)
         THEN
            raise_application_error (-20009, 'Error: msd_dem_upload_forecast.upload_forecast - Unable to find schema name');
         END IF;

            /*** Get Time Info - END ***/

         x_select_clause := x_select_clause || x_bucket_type || ' , '
                                            || x_start_time || ' , '
                                            || x_end_time || ' , ';

         x_from_clause := ' FROM ' || x_schema || '.' || x_view_name || ' exp, ' ||
                          '    msc_system_items msi, ';

         /* Get the levels at which forecast has been exported
          * Expected Levels -
          *  1. Item AND/OR Product Family
          *  2. (Site/Customer/Customer Zone/Zone) AND/OR (Ship From dimension levels)
          *  3. Demand Class (Not Mandatory)
          */

         /* PRODUCT */
         x_prd_level := get_level_column (x_profile_id, C_ITEM);
         IF (x_prd_level IS NULL)
         THEN
            x_prd_level := get_level_column (x_profile_id, C_PRODUCT_FAMILY);

            IF (x_prd_level IS NULL)
            THEN
               raise_application_error (-20010, 'Error: msd_dem_upload_forecast.upload_forecast - Item or Product Family level is required for upload');
            END IF;
         ELSE
            x_prd_key_column := get_series_column (x_profile_id, C_DKEY_SERIES_PREFIX, C_DKEY_ITEM);

            /* sjagathe - Added for Product Family Forecast Support */
            x_is_pf_level := get_level_column (x_profile_id, C_PRODUCT_FAMILY);

         END IF;

         x_select_clause := x_select_clause || ' msi.sr_instance_id, ';

         /* ORGANIZATION */
         x_org_level := get_level_column (x_profile_id, C_ORGANIZATION);
         IF (x_org_level IS NULL) /* global */
         THEN
            x_is_global_fcst := 1;
            x_sr_organization_id := '-1';

            x_sr_instance_id_for_global := get_sr_instance_id_for_global;
            IF (x_sr_instance_id_for_global IS NULL)
            THEN
               raise_application_error (-20011, 'Error: msd_dem_upload_forecast.upload_forecast - Unable to get sr_instance_id for global forecast');
            END IF;

         ELSE
            x_is_global_fcst := 2;
            x_sr_organization_id := ' msi.organization_id ';

         END IF;

         x_select_clause := x_select_clause || x_sr_organization_id || ' , ' ||
                                             ' msi.sr_inventory_item_id, ';

         IF (x_is_global_fcst = 2)
         THEN
            x_from_clause := x_from_clause || ' msc_trading_partners mtp_org, ';
         END IF;

         /* GEOGRAPHY */

         x_sr_ship_to_loc_id := ' NULL ';
         x_sr_customer_id := ' NULL ';
         x_sr_zone_id := ' NULL ';

         x_ship_to_level := get_level_column (x_profile_id, C_SITE);
         IF (x_ship_to_level IS NOT NULL)
         THEN
            x_sr_ship_to_loc_id := ' mtpsil.sr_tp_site_id ';
            x_from_clause := x_from_clause || ' msc_tp_site_id_lid mtpsil, ';
            x_ship_to_key_column := get_series_column (x_profile_id, C_DKEY_SERIES_PREFIX, C_DKEY_SITE);

            IF (x_ship_to_key_column IS NULL)
            THEN
               raise_application_error (-20013, 'Error: msd_dem_upload_forecast.upload_forecast - Destination key series for the level Site not found');
            END IF;

         END IF;

         x_cust_level := get_level_column (x_profile_id, C_CUSTOMER);
         x_cust_zone_level := get_level_column (x_profile_id, C_CUSTOMER_ZONE);
         IF (x_cust_level IS NOT NULL)
         THEN
            x_sr_customer_id := ' mtil.sr_tp_id ';
            x_from_clause := x_from_clause || ' msc_tp_id_lid mtil, ';
         ELSIF (x_ship_to_level IS NOT NULL)
         THEN
            x_sr_customer_id := ' mtpsil.sr_cust_acct_id ';
         ELSIF (x_cust_zone_level IS NOT NULL)
         THEN
            x_sr_customer_id := ' msd_dem_upload_forecast.get_customer_from_tpzone ( exp.' || x_cust_zone_level || ', mai.instance_id ) ';
         END IF;

         x_zone_level := get_level_column (x_profile_id, C_ZONE);
         IF (x_zone_level IS NOT NULL)
         THEN
            x_sr_zone_id := ' mr.region_id ';
            x_from_clause := x_from_clause || ' msc_regions mr, ';
         ELSIF (x_cust_zone_level IS NOT NULL)
         THEN
            x_sr_zone_id := ' msd_dem_upload_forecast.get_zone_from_tpzone ( exp.' || x_cust_zone_level || ', mai.instance_id ) ';
         END IF;

         x_select_clause := x_select_clause || x_sr_ship_to_loc_id || ' , ' ||
                                               x_sr_customer_id || ' , ' ||
                                               x_sr_zone_id || ' , ';

         /* DEMAND CLASS */
         x_demand_class_level := get_level_column (x_profile_id, C_DEMAND_CLASS);
         IF (x_demand_class_level IS NULL)
         THEN
            x_sr_demand_class := ' NULL ';
         ELSE
            x_sr_demand_class := ' mdc.demand_class ';
            x_from_clause := x_from_clause || ' msc_demand_classes mdc, ';
         END IF;

         IF (x_res_type = 1)
         THEN
            x_from_clause := x_from_clause || ' msc_apps_instances mai ';
         ELSE
            x_from_clause := x_from_clause || ' msc_apps_instances mai, ' || x_time_from_clause;
         END IF;

         x_select_clause := x_select_clause || x_sr_demand_class || ' , ' ||
                                             ' msi.inventory_item_id, ';


         x_uom_code := msd_dem_common_utilities.get_uom_code (x_unit_id);
         x_select_clause := x_select_clause || '''' || x_uom_code || ''', ' ||
                                             ' msi.uom_code, ';

         /* SINCE AMOUNT IS NOT AVAILABLE USE ASCP's LIST PRICE VALUE */
         x_select_clause := x_select_clause || ' msi.list_price * ((100 - msi.average_discount)/100), ';

         /* FORECAST SERIES */
         IF (   p_ind_fcst_series_iname IS NULL
             AND p_dep_fcst_series_iname IS NULL)
         THEN
            x_fcst_column := get_series_column (x_profile_id, C_FORECAST_SERIES_PREFIX);

            IF (x_fcst_column IS NULL)
            THEN
               raise_application_error (-20014, 'Error: msd_dem_upload_forecast.upload_forecast - Forecast series not found');
            END IF;

            x_fcst_column := 'exp.' || x_fcst_column;

         ELSE

            IF (    p_ind_fcst_series_iname IS NOT NULL
                AND p_dep_fcst_series_iname IS NOT NULL)
            THEN
               x_fcst_column := '( nvl(exp.' || p_ind_fcst_series_iname || ',0) + nvl(exp.' || p_dep_fcst_series_iname || ',0) * decode( nvl (msi.ato_forecast_control, 3), 3, 0, 1 ) )';
            ELSIF (p_ind_fcst_series_iname IS NOT NULL)
            THEN
               x_fcst_column := '( nvl(exp.' || p_ind_fcst_series_iname || ',0))';
            ELSE
               x_fcst_column := '( nvl(exp.' || p_dep_fcst_series_iname || ',0) * decode( nvl (msi.ato_forecast_control, 3), 3, 0, 1 ) )';
            END IF;

         END IF;


         IF (x_unit_id = 1 OR upper(x_uom_code) = 'UNITS')
         THEN
            x_quantity := ' round (' || x_fcst_column || ' * ' || x_data_scale || ', ' || C_ROUNDOFF_PLACES || ' ) ';
         ELSE
            x_quantity := ' round (' || x_fcst_column ||
                          ' * ' || x_data_scale ||
                          ' * decode ( ''' || x_uom_code || ''', msi.uom_code, 1, ' ||
                          ' msd_dem_common_utilities.uom_convert(msi.inventory_item_id, ' ||
                          '                                        null, ' ||
                                                                   '''' || x_uom_code || ''' , ' ||
                          '                                        msi.uom_code)), ' ||
                                   C_ROUNDOFF_PLACES || ' ) ';
         END IF;

         x_select_clause := x_select_clause || x_quantity || ' , ';

         /* FORECAST ACCURACY */
         x_error_column := get_series_column (x_profile_id, C_FCST_ACRY_SERIES_PREFIX);
	 x_error_column_alias := x_error_column;

         IF (x_error_column IS NULL)
         THEN
            x_select_clause := x_select_clause || ' NULL , NULL , ';
         ELSE
            IF (instr(x_error_column, 'MAD') = 0)
            THEN
               x_error_type := 'MAPE';
	       --syenamar
	       --bug#9025110    MAPE series value will be multiplied by 100 for	inserting into denorm table as percentage
	       x_error_column := x_error_column || '*100';
	       --syenamar
            ELSE
               x_error_type := 'MAD';
            END IF;
            x_select_clause := x_select_clause || '''' || x_error_type || ''' , exp.' || x_error_column || ' , ';
         END IF;

         /* DEMAND PRIORITY SERIES */
         x_demand_priority_column := get_series_column (x_profile_id, C_DEMAND_PRTY_SERIES_PREFIX);

         IF (x_demand_priority_column IS NULL)
         THEN
            x_select_clause := x_select_clause || ' NULL , ';
         ELSE
            x_select_clause := x_select_clause || ' exp.' || x_demand_priority_column || ' , ';
         END IF;

         /* sjagathe - Added for Product Family Forecast Support */
         IF (x_is_pf_level IS NULL)
         THEN
            x_select_clause := x_select_clause || ' NULL , ';
            x_select_clause := x_select_clause || ' NULL , ';
         ELSE
            x_select_clause := x_select_clause || ' exp.' || x_is_pf_level || ' , ';
            x_select_clause := x_select_clause || ' nvl (msi.ato_forecast_control, 3) , ';
         END IF;


         x_select_clause := x_select_clause || ' sysdate, ' ||
                                               ' FND_GLOBAL.USER_ID, ' ||
                                               ' FND_GLOBAL.LOGIN_ID ';

         /* BUILD WHERE CLAUSE */
         IF (x_is_global_fcst = 2)
         THEN

            x_where_clause := ' WHERE mtp_org.partner_type = 3 ' ||
                              '    AND exp.' || x_org_level || ' = mtp_org.organization_code ' ||
                              '    AND msi.plan_id = -1 ' ||
                              '    AND msi.sr_instance_id = mtp_org.sr_instance_id ' ||
                              '    AND msi.organization_id = mtp_org.sr_tp_id ';
         ELSE

            x_where_clause := ' WHERE msi.plan_id = -1 ' ||
                              '    AND msi.sr_instance_id = ' || to_char(x_sr_instance_id_for_global) ||
                              '    AND msi.organization_id = mai.validation_org_id ';
         END IF;

         IF (x_prd_key_column IS NOT NULL)
         THEN
            x_where_clause := x_where_clause ||
                              '    AND msi.inventory_item_id = exp.' || x_prd_key_column || ' ';
         ELSE
            x_where_clause := x_where_clause ||
                              '    AND msi.item_name = exp.' || x_prd_level || ' ';
         END IF;

         x_where_clause := x_where_clause ||
                           '    AND msi.sr_instance_id = mai.instance_id ' ||
                           '    AND msi.mrp_planning_code <> 6 ';

         /* Independent Forecast for options with forecast control none should be exported.
         IF (x_is_pf_level IS NULL) THEN

            x_where_clause := x_where_clause || '    AND msi.ato_forecast_control <> 3 ';

         END IF;
         */

         /* Bug# 5765391 - Upload forecast for 'Unassociated' geo dimension members also */

         IF (x_ship_to_level IS NOT NULL)
         THEN
            x_where_clause := x_where_clause ||
                           ' AND mtpsil.tp_site_id (+) = exp.' || x_ship_to_key_column || ' ' ||
                           ' AND decode (mtpsil.sr_instance_id, null, decode (exp.' || x_ship_to_key_column || ' , null, 1, 0), mai.instance_id, 1, 0) = 1 ';
         END IF;

         IF (x_cust_level IS NOT NULL)
         THEN
            IF (msd_dem_common_utilities.is_use_new_site_format <> 0)
            THEN
               x_where_clause := x_where_clause ||
                              ' AND mtil.sr_cust_account_number (+) = to_char(substr(exp.' || x_cust_level || ',instr(exp.' || x_cust_level || ', ''::'', -1) + 2)) ' ||
                              ' AND mtil.partner_type (+) = 2 ' ||
                              ' AND decode (mtil.sr_instance_id, null, decode (exp.' || x_cust_level || ' , msd_dem_sr_util.get_null_code, 1, 0), mai.instance_id, 1, 0) = 1 ';
            ELSE
               x_where_clause := x_where_clause ||
                              ' AND mtil.sr_cust_account_number (+) = to_char(substr(exp.' || x_cust_level || ',instr(exp.' || x_cust_level || ', '':'', -1) + 1)) ' ||
                              ' AND mtil.partner_type (+) = 2 ' ||
                              ' AND decode (mtil.sr_instance_id, null, decode (exp.' || x_cust_level || ' , msd_dem_sr_util.get_null_code, 1, 0), mai.instance_id, 1, 0) = 1 ';
            END IF;
         END IF;

         IF (x_zone_level IS NOT NULL)
         THEN
            x_where_clause := x_where_clause ||
                           ' AND mr.zone (+) = exp.' || x_zone_level || ' ' ||
                           ' AND decode (mr.sr_instance_id, null, decode (exp.' || x_zone_level || ' , msd_dem_sr_util.get_null_code, 1, 0), mai.instance_id, 1, 0) = 1 ';
         END IF;

         IF (x_demand_class_level IS NOT NULL)
         THEN
            x_where_clause := x_where_clause ||
                           ' AND mdc.meaning (+) = exp.' || x_demand_class_level || ' ' ||
                           ' AND decode (mdc.sr_instance_id, null, decode (exp.' || x_demand_class_level || ' , msd_dem_sr_util.get_null_code, 1, 0), mai.instance_id, 1, 0) = 1 ';
         END IF;

         IF (x_res_type = 2)
         THEN
            x_where_clause := x_where_clause ||
                           ' AND exp.sdate = inp.end_time ';
         ELSIF (x_res_type = 3)
         THEN
            x_where_clause := x_where_clause ||
                           ' AND exp.sdate = inp.start_time ';
         END IF;


         /* Upload ZERO forecast quantity only if MAD forecast error is NON-ZERO */
         IF (x_error_column IS NOT NULL AND x_error_type = 'MAD')
         THEN

            x_where_clause := x_where_clause ||
                              ' AND decode ( ' || x_fcst_column || ' , 0 , ' ||
                              '              decode ( nvl( exp.' || x_error_column || ' , 0) , 0, ' ||
                              '                       -1, ' ||
                              '                        1), ' ||
                              '              1) = 1 ';
         ELSE
            x_where_clause := x_where_clause ||
                              ' AND decode ( nvl( ' || x_fcst_column || ' , 0), 0, ' ||
                              '              -1, ' ||
                              '               1) = 1 ';
         END IF;

         x_insert_clause := 'INSERT INTO MSD_DP_SCN_ENTRIES_DENORM ( ' ||
                            '   DEMAND_PLAN_ID, ' ||
                            '   SCENARIO_ID, ' ||
                            '   DEMAND_ID, ' ||
                            '   BUCKET_TYPE, ' ||
                            '   START_TIME, ' ||
                            '   END_TIME, ' ||
                            '   SR_INSTANCE_ID, ' ||
                            '   SR_ORGANIZATION_ID, ' ||
                            '   SR_INVENTORY_ITEM_ID, ' ||
                            '   SR_SHIP_TO_LOC_ID, ' ||
                            '   SR_CUSTOMER_ID, ' ||
                            '   SR_ZONE_ID, ' ||
                            '   DEMAND_CLASS, ' ||
                            '   INVENTORY_ITEM_ID, ' ||
                            '   DP_UOM_CODE, ' ||
                            '   ASCP_UOM_CODE, ' ||
                            '   UNIT_PRICE, ' ||
                            '   QUANTITY, ' ||
                            '   ERROR_TYPE, ' ||
                            '   FORECAST_ERROR, ' ||
                            '   PRIORITY, ' ||
                            '   PF_NAME, ' ||                                                /* sjagathe - Added for Product Family Forecast Support */
                            '   REQUEST_ID, ' ||                                             /* sjagathe - Added for Product Family Forecast Support */
                            '   CREATION_DATE, ' ||
                            '   CREATED_BY, ' ||
                            '   LAST_UPDATE_LOGIN )';

         x_large_sql := x_insert_clause || x_select_clause || x_from_clause || x_where_clause;

         IF (p_dep_fcst_series_iname IS NOT NULL)
         THEN

            x_inner_view := '(SELECT SDATE, '
                               || x_prd_level;

            IF (x_prd_key_column IS NOT NULL)
            THEN
               x_inner_view := x_inner_view || ' , ' || x_prd_key_column;
               x_iv_group_by := ' , ' || x_prd_key_column;
            END IF;

            IF (x_is_global_fcst = 2)
            THEN
               x_inner_view := x_inner_view || ' , ' || x_org_level;
               x_iv_group_by := x_iv_group_by || ' , ' || x_org_level;
            END IF;

            IF (x_ship_to_level IS NOT NULL)
            THEN
               x_inner_view := x_inner_view || ' , ' || x_ship_to_level
                                            || ' , ' || x_ship_to_key_column;
               x_iv_group_by := x_iv_group_by || ' , ' || x_ship_to_level
                                            || ' , ' || x_ship_to_key_column;
            END IF;

            IF (x_cust_level IS NOT NULL)
            THEN
               x_inner_view := x_inner_view || ' , ' || x_cust_level;
               x_iv_group_by := x_iv_group_by || ' , ' || x_cust_level;
            END IF;

            IF (x_cust_zone_level IS NOT NULL)
            THEN
               x_inner_view := x_inner_view || ' , ' || x_cust_zone_level;
               x_iv_group_by := x_iv_group_by || ' , ' || x_cust_zone_level;
            END IF;

            IF (x_zone_level IS NOT NULL)
            THEN
               x_inner_view := x_inner_view || ' , ' || x_zone_level;
               x_iv_group_by := x_iv_group_by || ' , ' || x_zone_level;
            END IF;

            IF (x_demand_class_level IS NOT NULL)
            THEN
               x_inner_view := x_inner_view || ' , ' || x_demand_class_level;
               x_iv_group_by := x_iv_group_by || ' , ' || x_demand_class_level;
            END IF;

            IF (p_ind_fcst_series_iname IS NOT NULL)
            THEN
               x_inner_view := x_inner_view || ' , MAX( ' || p_ind_fcst_series_iname || ' ) ' || p_ind_fcst_series_iname;
            END IF;

            IF (p_dep_fcst_series_iname IS NOT NULL)
            THEN
               x_inner_view := x_inner_view || ' , SUM( ' || p_dep_fcst_series_iname || ' ) ' || p_dep_fcst_series_iname;
            END IF;

            IF (x_error_column IS NOT NULL)
            THEN
               x_inner_view := x_inner_view || ' , AVG( ' || x_error_column_alias || ' ) ' || x_error_column_alias;
            END IF;

            IF (x_demand_priority_column IS NOT NULL)
            THEN
               x_inner_view := x_inner_view || ' , MIN( ' || x_demand_priority_column || ' ) ' || x_demand_priority_column;
            END IF;

             x_inner_view := x_inner_view || ' FROM ' || x_schema || '.' || x_view_name;
             x_inner_view := x_inner_view || ' GROUP BY SDATE, ' || x_prd_level || x_iv_group_by || ' ) ';

             x_large_sql := replace (x_large_sql, x_schema || '.' || x_view_name, x_inner_view);

         END IF;

         /* Delete all data in the denorm for the export data profile */
         DELETE FROM MSD_DP_SCN_ENTRIES_DENORM
         WHERE demand_plan_id = x_demand_plan_id
            AND scenario_id = x_scenario_id;

         COMMIT;

         /* Insert forecast data into denorm table */
         EXECUTE IMMEDIATE x_large_sql;
         x_num_rows := SQL%ROWCOUNT;

         /* Call Custom Hook for Upload */

         msd_dem_custom_hooks.upload_hook (
           		x_errbuf,
           		x_retcode);

         IF (x_retcode = -1)
         THEN

            x_small_sql := ' BEGIN ' || x_schema || '.dl_log_status(''' || VS_MSG_UPLOAD_FCST || ''' , ''' ||
                           VS_MSG_LOADED || ' ' || p_export_data_profile || ''' , ''' || VS_MSG_LOADE_ERROR || ''',''' || x_errbuf || ''' ); END;';


            EXECUTE IMMEDIATE x_small_sql;

	    raise_application_error (-20014, 'Error: msd_dem_upload_forecast.upload_forecast - Error in call to custom hook msd_dem_custom_hooks.upload_hook');
         END IF;

         COMMIT;

         msd_dem_collect_history_data.analyze_table (
         				x_errbuf,
         				x_retcode,
         				'MSD_DP_SCN_ENTRIES_DENORM');


         /* sjagathe - Added for Product Family Forecast Support */
         IF (x_is_pf_level IS NOT NULL)
         THEN

            IF ( x_is_global_fcst = 2 )
            THEN

               INSERT INTO MSD_DP_SCN_ENTRIES_DENORM (
                  DEMAND_PLAN_ID,
                  SCENARIO_ID,
                  DEMAND_ID,
                  BUCKET_TYPE,
                  START_TIME,
                  END_TIME,
                  SR_INSTANCE_ID,
                  SR_ORGANIZATION_ID,
                  SR_INVENTORY_ITEM_ID,
                  SR_SHIP_TO_LOC_ID,
                  SR_CUSTOMER_ID,
                  SR_ZONE_ID,
                  DEMAND_CLASS,
                  INVENTORY_ITEM_ID,
                  DP_UOM_CODE,
                  ASCP_UOM_CODE,
                  UNIT_PRICE,
                  QUANTITY,
                  ERROR_TYPE,
                  FORECAST_ERROR,
                  PRIORITY,
                  PF_NAME,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_LOGIN )
                     SELECT /*+ ORDERED */
                        x_demand_plan_id,
                        x_scenario_id,
                        x_num_rows + rownum - 1,
                        x_bucket_type,
                        entries.start_time,
                        entries.end_time,
                        entries.sr_instance_id,
                        entries.sr_organization_id,
                        msi.sr_inventory_item_id,
                        entries.sr_ship_to_loc_id,
                        entries.sr_customer_id,
                        entries.sr_zone_id,
                        entries.demand_class,
                        msi.inventory_item_id,
                        x_uom_code,
                        msi.uom_code,
                        msi.list_price * ((100 - msi.average_discount)/100),
                        entries.quantity,
                        null,
                        null,
                        null,
                        null,
                        sysdate,
                        FND_GLOBAL.USER_ID,
                        FND_GLOBAL.LOGIN_ID
                     FROM (SELECT
                              sr_instance_id,
                              pf_name,
                              sr_organization_id,
                              sr_ship_to_loc_id,
                              sr_customer_id,
                              sr_zone_id,
                              demand_class,
                              start_time,
                              end_time,
                              sum(quantity) QUANTITY
                           FROM msd_dp_scn_entries_denorm
                           WHERE scenario_id = x_scenario_id
                           GROUP BY sr_instance_id,
                                    pf_name,
                                    sr_organization_id,
                                    sr_ship_to_loc_id,
                                    sr_customer_id,
                                    sr_zone_id,
                                    demand_class,
                                    start_time,
                                    end_time) entries,
                          msc_system_items msi
                     WHERE  msi.plan_id = -1
                        AND msi.sr_instance_id = entries.sr_instance_id
                        AND msi.organization_id = entries.sr_organization_id
                        AND msi.item_name = entries.pf_name;

            ELSE

               INSERT INTO MSD_DP_SCN_ENTRIES_DENORM (
                  DEMAND_PLAN_ID,
                  SCENARIO_ID,
                  DEMAND_ID,
                  BUCKET_TYPE,
                  START_TIME,
                  END_TIME,
                  SR_INSTANCE_ID,
                  SR_ORGANIZATION_ID,
                  SR_INVENTORY_ITEM_ID,
                  SR_SHIP_TO_LOC_ID,
                  SR_CUSTOMER_ID,
                  SR_ZONE_ID,
                  DEMAND_CLASS,
                  INVENTORY_ITEM_ID,
                  DP_UOM_CODE,
                  ASCP_UOM_CODE,
                  UNIT_PRICE,
                  QUANTITY,
                  ERROR_TYPE,
                  FORECAST_ERROR,
                  PRIORITY,
                  PF_NAME,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_LOGIN )
                     SELECT /*+ ORDERED */
                        x_demand_plan_id,
                        x_scenario_id,
                        x_num_rows + rownum - 1,
                        x_bucket_type,
                        entries.start_time,
                        entries.end_time,
                        entries.sr_instance_id,
                        entries.sr_organization_id,
                        msi.sr_inventory_item_id,
                        entries.sr_ship_to_loc_id,
                        entries.sr_customer_id,
                        entries.sr_zone_id,
                        entries.demand_class,
                        msi.inventory_item_id,
                        x_uom_code,
                        msi.uom_code,
                        msi.list_price * ((100 - msi.average_discount)/100),
                        entries.quantity,
                        null,
                        null,
                        null,
                        null,
                        sysdate,
                        FND_GLOBAL.USER_ID,
                        FND_GLOBAL.LOGIN_ID
                     FROM (SELECT
                              sr_instance_id,
                              pf_name,
                              sr_organization_id,
                              sr_ship_to_loc_id,
                              sr_customer_id,
                              sr_zone_id,
                              demand_class,
                              start_time,
                              end_time,
                              sum(quantity) QUANTITY
                           FROM msd_dp_scn_entries_denorm
                           WHERE scenario_id = x_scenario_id
                           GROUP BY sr_instance_id,
                                    pf_name,
                                    sr_organization_id,
                                    sr_ship_to_loc_id,
                                    sr_customer_id,
                                    sr_zone_id,
                                    demand_class,
                                    start_time,
                                    end_time) entries,
                          msc_apps_instances mai,
                          msc_system_items msi
                     WHERE  mai.instance_id = entries.sr_instance_id
                        AND msi.plan_id = -1
                        AND msi.sr_instance_id = mai.instance_id
                        AND msi.organization_id = mai.validation_org_id
                        AND msi.item_name = entries.pf_name;

            END IF;

            /* Delete Product Family members with forecast control none */
            DELETE FROM MSD_DP_SCN_ENTRIES_DENORM
            WHERE demand_plan_id = x_demand_plan_id
               AND scenario_id = x_scenario_id
               AND request_id = 3;

            COMMIT;

         END IF;

         x_small_sql := ' BEGIN ' || x_schema || '.dl_log_status(''' || VS_MSG_UPLOAD_FCST || ''' , ''' ||
                        VS_MSG_LOADED || ' ' || p_export_data_profile || ''' , ''' || VS_MSG_SUCCEEDED || ''' ); END;';


         EXECUTE IMMEDIATE x_small_sql;

         /* Alter session to demantra schema */
         x_small_sql := 'alter session set current_schema = ' || x_schema;
         EXECUTE IMMEDIATE x_small_sql;

      EXCEPTION
         WHEN OTHERS THEN

            x_small_sql := ' BEGIN ' || x_schema || '.dl_log_status(''' || VS_MSG_UPLOAD_FCST || ''' , ''' ||
                           VS_MSG_LOADED || ' ' || p_export_data_profile || ''' , ''' || VS_MSG_LOADE_ERROR || ''',''' || substr(SQLERRM,1,150) || ''' ); END;';


            EXECUTE IMMEDIATE x_small_sql;

            /* Alter session to demantra schema */
            x_small_sql := 'alter session set current_schema = ' || x_schema;
            EXECUTE IMMEDIATE x_small_sql;

	    raise_application_error (-20015, 'Exception: msd_dem_upload_forecast.upload_forecast - ' || substr(SQLERRM,1,150));

      END UPLOAD_FORECAST;





      /*
       * This procedure export the planning percentages from Demantra to the table
       * MSD_DP_PLANNING_PCT_DENORM table.
       * The parameters are -
       *   p_pp_export_data_profile - Export data profile used to export planning
       *                              percentages
       *   p_fcst_export_data_profile - Export data profile used to export total demand
       *   p_parent_item_series_iname - Internal Name of the series which holds parent
       *                                item total demand
       *   p_option_item_series_iname - Internal Name of the series which holds the option
       *                                item dependent demand
       */
      PROCEDURE UPLOAD_PLANNING_PERCENTAGES (
      			p_pp_export_data_profile	IN	VARCHAR2,
      			p_fcst_export_data_profile	IN	VARCHAR2,
      			p_pctg_series_iname		IN	VARCHAR2,
      			p_parent_item_series_iname	IN	VARCHAR2 DEFAULT NULL,
      			p_option_item_series_iname	IN	VARCHAR2 DEFAULT NULL )
      IS

         TYPE CUR_TYPE	IS REF CURSOR;
         x_cur_type		CUR_TYPE;

         x_errbuf		VARCHAR2(200)	:= NULL;
         x_retcode		VARCHAR2(100)	:= NULL;

         x_small_sql		VARCHAR2(600)	:= NULL;
         x_schema		VARCHAR(50)	:= NULL;
         x_pctg_exp_dp		VARCHAR2(200)	:= NULL;
         x_fcst_exp_dp		VARCHAR2(200)	:= NULL;
         x_pctg_series_iname	VARCHAR2(200)	:= NULL;
         x_parent_series_iname	VARCHAR2(30)	:= NULL;
         x_option_series_iname  VARCHAR2(30)	:= NULL;
         x_publish_variant	NUMBER		:= 0;		/* 0 - Pctg, 1-Fcst */
         x_table_name		VARCHAR2(70)	:= NULL;
         x_sql			VARCHAR2(2000)	:= NULL;
         x_uom_code		VARCHAR2(100)	:= NULL;

   	 x_profile_id		NUMBER		:= NULL;
         x_presentation_type	NUMBER		:= NULL;
         x_view_name		VARCHAR2(30)	:= NULL;
         x_time_res_id		NUMBER		:= NULL;
         x_unit_id		NUMBER		:= NULL;
         x_index_id		NUMBER		:= NULL;
         x_data_scale		NUMBER		:= NULL;
         x_integration_type	NUMBER		:= NULL;
         x_export_type		NUMBER		:= NULL;
         x_is_view_present      NUMBER		:= 0;

         x_fcst_profile_id	NUMBER		:= NULL;
         x_demand_plan_id	NUMBER		:= NULL;
         x_scenario_id		NUMBER		:= NULL;
         x_bucket_type		NUMBER		:= NULL;
         x_start_time		VARCHAR2(100)	:= NULL;
         x_end_time		VARCHAR2(100)   := NULL;
         x_res_type		NUMBER		:= NULL;
         x_time_from_clause	VARCHAR2(500)	:= NULL;
         x_sr_organization_id	VARCHAR2(50)	:= NULL;
         x_pctg_column		VARCHAR2(500)	:= NULL;

         x_select_clause	VARCHAR2(3000)  := NULL;
         x_from_clause		VARCHAR2(500)	:= NULL;
         x_where_clause		VARCHAR2(3000)  := NULL;
         x_insert_clause	VARCHAR2(1000)	:= NULL;
         x_large_sql		VARCHAR2(6000)  := NULL;
         x_inner_view       VARCHAR2(1000)  := NULL;

         x_org_level		VARCHAR2(30)    := NULL;
         x_prd_level		VARCHAR2(30)    := NULL;
         x_prd_key_column	VARCHAR2(30)	:= NULL;
         x_parent_item_level    VARCHAR2(30)    := NULL;

         x_is_global_fcst	NUMBER(1)	:= NULL;
         x_sr_instance_id_for_global	NUMBER	:= NULL;
         x_num_rows		NUMBER		:= 0;

      BEGIN

         /* Alter session to APPS */
         x_small_sql := 'alter session set current_schema = APPS';
         EXECUTE IMMEDIATE x_small_sql;


         x_schema := fnd_profile.value('MSD_DEM_SCHEMA');
         IF (x_schema IS NULL)
         THEN
            raise_application_error (-20001, 'Error: msd_dem_upload_forecast.upload_planning_percentages - Unable to find schema name');
         END IF;



         x_small_sql := ' BEGIN ' || x_schema || '.dl_log_status(''' || VS_MSG_UPLOAD_PCTG || ''' , ''' ||
                        VS_MSG_LOADING || ' ' || p_pp_export_data_profile || ''' , ''' || VS_MSG_STARTED || ''' ); END;';

         EXECUTE IMMEDIATE x_small_sql;


         /* Initialize local variables */
         IF (p_pp_export_data_profile IS NULL)
         THEN
            raise_application_error (-20002, 'Error: msd_dem_upload_forecast.upload_planning_percentages - Planning Percentage export data profile name NOT provided');
	 ELSE
            x_pctg_exp_dp := lower(p_pp_export_data_profile);
         END IF;

         IF (p_fcst_export_data_profile IS NULL)
         THEN
            raise_application_error (-20003, 'Error: msd_dem_upload_forecast.upload_planning_percentages - Total Demand export data profile name NOT provided');
	 ELSE
            x_fcst_exp_dp := lower(p_fcst_export_data_profile);
         END IF;

         IF (p_pctg_series_iname IS NULL)
         THEN
            raise_application_error (-20004, 'Error: msd_dem_upload_forecast.upload_planning_percentages - Planning Percentage series internal name NOT provided');
	 ELSE
            x_pctg_series_iname := lower(p_pctg_series_iname);
         END IF;

         IF (p_parent_item_series_iname IS NOT NULL
             AND p_option_item_series_iname IS NOT NULL)
         THEN
            x_parent_series_iname := lower(p_parent_item_series_iname);
            x_option_series_iname := lower(p_option_item_series_iname);
         END IF;

         IF (p_parent_item_series_iname IS NULL
             AND p_option_item_series_iname IS NOT NULL)
         THEN
            raise_application_error (-20005, 'Error: msd_dem_upload_forecast.upload_planning_percentages - Parent Item Demand series internal name NOT provided');
         END IF;

         IF (p_option_item_series_iname IS NULL
             AND p_parent_item_series_iname IS NOT NULL)
         THEN
            raise_application_error (-20006, 'Error: msd_dem_upload_forecast.upload_planning_percentages - Option Item Demand series internal name NOT provided');
         END IF;

         /* Determine how is planning percentage exported */
         IF (p_parent_item_series_iname IS NOT NULL)
         THEN
            x_publish_variant := 1;
         ELSE
            x_publish_variant := 0;
         END IF;

         /* Get the export data profile info */
         x_table_name := msd_dem_common_utilities.get_lookup_value ('MSD_DEM_TABLES', 'TRANSFER_QUERY');
         x_sql := 'SELECT id, presentation_type, view_name, ' ||
                     ' time_res_id, unit_id, index_id, data_scale, ' ||
                     ' integration_type, export_type ' ||
                     ' FROM ' || x_table_name ||
                     ' WHERE lower(query_name) = ''' || x_pctg_exp_dp || '''';

         OPEN x_cur_type FOR x_sql;
         FETCH x_cur_type INTO x_profile_id,
                               x_presentation_type,
                               x_view_name,
                               x_time_res_id,
                               x_unit_id,
                               x_index_id,
                               x_data_scale,
                               x_integration_type,
                               x_export_type;
         CLOSE x_cur_type;


         x_sql := 'SELECT count(1) FROM dba_objects ' ||
                     ' WHERE owner = upper(''' || x_schema || ''')' ||
                     '   AND object_type IN (''VIEW'', ''MATERIALIZED VIEW'') ' ||
                     '   AND object_name = upper(''' || x_view_name || ''')';
         EXECUTE IMMEDIATE x_sql INTO x_is_view_present;

         x_uom_code := msd_dem_common_utilities.get_uom_code (x_unit_id);

         /* Get the id of the forecast profile */
         x_sql := 'SELECT id ' ||
                     ' FROM ' || x_table_name ||
                     ' WHERE lower(query_name) = ''' || x_fcst_exp_dp || '''';

         OPEN x_cur_type FOR x_sql;
         FETCH x_cur_type INTO x_fcst_profile_id;
         CLOSE x_cur_type;

            /*** Check basic error conditions - BEGIN ***/

         IF (x_profile_id IS NULL)
         THEN
            raise_application_error (-20007, 'Error: msd_dem_upload_forecast.upload_planning_percentages - Unable to get pctg export data profile id');
         ELSIF (x_integration_type = C_IMPORT_DATA_PROFILE)
         THEN
            raise_application_error (-20008, 'Error: msd_dem_upload_forecast.upload_planning_percentages - ' || x_pctg_exp_dp || 'is not an export data profile');
         ELSIF (x_export_type = C_EXPORT_TYPE_INCR)
         THEN
            raise_application_error (-20009, 'Error: msd_dem_upload_forecast.upload_planning_percentages - Incremental export type is not supported');
         ELSIF (x_index_id IS NOT NULL)
         THEN
            raise_application_error (-20010, 'Error: msd_dem_upload_forecast.upload_planning_percentages - Forecast amount cannot be uploaded');
         ELSIF (x_is_view_present = 0)
         THEN
            raise_application_error (-20011, 'Error: msd_dem_upload_forecast.upload_planning_percentages - Forecast has not yet been exported');
         ELSIF (x_presentation_type = C_PSNT_TYPE_DESC)
         THEN
            raise_application_error (-20012, 'Error: msd_dem_upload_forecast.upload_planning_percentages - Presentation type must by Code');
         ELSIF (x_unit_id <> 1 AND lower(x_uom_code) <> 'units')
         THEN
            raise_application_error (-20013, 'Error: msd_dem_upload_forecast.upload_planning_percentages - Display unit is not UNITS.');
         ELSIF (x_fcst_profile_id IS NULL)
         THEN
            raise_application_error (-20013, 'Error: msd_dem_upload_forecast.upload_planning_percentages - Unable to get forecast export data profile id');
         END IF;

            /*** Check basic error conditions - END ***/

         x_demand_plan_id := C_DEMAND_PLAN_ID;
         x_scenario_id    := x_fcst_profile_id + C_SCENARIO_ID_OFFSET;

         x_select_clause := ' SELECT ' || x_demand_plan_id || ' , ' ||
                                          x_scenario_id || ' , ';

            /*** Get Time Info - BEGIN ***/

         get_time_strings (
         		x_bucket_type,
         		x_start_time,
         		x_end_time,
         		x_res_type,
         		x_time_from_clause,
         		x_time_res_id);

         IF (x_res_type IS NULL)
         THEN
            raise_application_error (-20014, 'Error: msd_dem_upload_forecast.upload_planning_percentages - Unable to find schema name in get_time_strings');
         END IF;

            /*** Get Time Info - END ***/

         x_select_clause := x_select_clause || x_start_time || ' , '
                                            || x_end_time || ' , ';

         x_from_clause := ' FROM ' || x_schema || '.' || x_view_name || ' exp, ' ||
                          '    msc_system_items msi, ';

         /* Get the levels at which planning percentages are being exported
          * Expected Levels -
          *  1. Item (Mandatory)
          *  2. Parent Item (Mandatory)
          *  3. Organization (Not Mandatory)
          */

         /* PRODUCT */
         x_prd_level := get_level_column (x_profile_id, C_ITEM);
         IF (x_prd_level IS NULL)
         THEN
            raise_application_error (-20015, 'Error: msd_dem_upload_forecast.upload_planning_percentages - Item level is required for upload');
         ELSE
            x_prd_key_column := get_series_column (x_profile_id, C_DKEY_SERIES_PREFIX, C_DKEY_ITEM);
         END IF;

         x_select_clause := x_select_clause || ' msi.sr_instance_id, ';

         /* Parent Item */
         x_parent_item_level := get_level_column (x_profile_id, C_PARENT_ITEM);
         IF (x_parent_item_level IS NULL)
         THEN
            raise_application_error (-20016, 'Error: msd_dem_upload_forecast.upload_planning_percentages - Parent Item level is required for upload');
         END IF;

         /* ORGANIZATION */
         x_org_level := get_level_column (x_profile_id, C_ORGANIZATION);
         IF (x_org_level IS NULL) /* global */
         THEN
            x_is_global_fcst := 1;
            x_sr_organization_id := '-1';

            x_sr_instance_id_for_global := get_sr_instance_id_for_global;
            IF (x_sr_instance_id_for_global IS NULL)
            THEN
               raise_application_error (-20017, 'Error: msd_dem_upload_forecast.upload_planning_percentages - Unable to get sr_instance_id for global planning percentages');
            END IF;

         ELSE
            x_is_global_fcst := 2;
            x_sr_organization_id := ' msi.organization_id ';

         END IF;

         x_select_clause := x_select_clause || x_sr_organization_id || ' , ' ||
                                             ' msi.inventory_item_id, ';

         IF (x_is_global_fcst = 2)
         THEN
            x_from_clause := x_from_clause || ' msc_trading_partners mtp_org, ';
         END IF;

         x_from_clause := x_from_clause || ' msc_system_items pitem, '
                                        || ' msc_boms mb, '
                                        || ' msc_bom_components mbc, ';

         IF (x_res_type = 1)
         THEN
            x_from_clause := x_from_clause || ' msc_apps_instances mai ';
         ELSE
            x_from_clause := x_from_clause || ' msc_apps_instances mai, ' || x_time_from_clause;
         END IF;

         x_select_clause := x_select_clause || ' MSD_DP_PLANNING_PERCENTAGES_S.nextval, '
                                            || ' mbc.component_sequence_id, '
                                            || ' mb.bill_sequence_id, '
                                            || ' pitem.inventory_item_id, ';

         /* Planning Percentage Columns */
         IF (x_publish_variant = 0)
         THEN
            x_pctg_column := 'exp.' || x_pctg_series_iname;
         ELSE
            x_pctg_column := ' ( decode ( exp.' || p_parent_item_series_iname || ', null, exp.' || x_pctg_series_iname || ', 0, exp.'|| x_pctg_series_iname || ', (exp.'|| p_option_item_series_iname  || '/exp.' || p_parent_item_series_iname|| ' ) ) ) ';
         END IF;

         x_select_clause := x_select_clause || x_pctg_column || ' , ';
         x_select_clause := x_select_clause || '1, ';

         x_select_clause := x_select_clause || ' sysdate, ' ||
                                               ' FND_GLOBAL.USER_ID, ' ||
                                               ' FND_GLOBAL.LOGIN_ID ';

         /* BUILD WHERE CLAUSE */
         IF (x_is_global_fcst = 2)
         THEN

            x_where_clause := ' WHERE mtp_org.partner_type = 3 ' ||
                              '    AND exp.' || x_org_level || ' = mtp_org.organization_code ' ||
                              '    AND msi.plan_id = -1 ' ||
                              '    AND msi.sr_instance_id = mtp_org.sr_instance_id ' ||
                              '    AND msi.organization_id = mtp_org.sr_tp_id ';
         ELSE

            x_where_clause := ' WHERE msi.plan_id = -1 ' ||
                              '    AND msi.sr_instance_id = ' || to_char(x_sr_instance_id_for_global) ||
                              '    AND msi.organization_id = mai.validation_org_id ';
         END IF;

         IF (x_prd_key_column IS NOT NULL)
         THEN
            x_where_clause := x_where_clause ||
                              '    AND msi.inventory_item_id = exp.' || x_prd_key_column || ' ';
         ELSE
            x_where_clause := x_where_clause ||
                              '    AND msi.item_name = exp.' || x_prd_level || ' ';
         END IF;

         x_where_clause := x_where_clause ||
                           '    AND msi.sr_instance_id = mai.instance_id ';

         x_where_clause := x_where_clause ||
                           '    AND pitem.item_name = exp.' || x_parent_item_level ||
                           '    AND pitem.plan_id = -1 ' ||
                           '    AND pitem.sr_instance_id = msi.sr_instance_id ' ||
                           '    AND pitem.organization_id = msi.organization_id ' ||
                           '    AND mb.plan_id = -1 ' ||
                           '    AND mb.organization_id = msi.organization_id ' ||
                           '    AND mb.sr_instance_id = msi.sr_instance_id ' ||
                           '    AND mb.assembly_item_id = pitem.inventory_item_id ' ||
                           '    AND mb.alternate_bom_designator is null ' ||
                           '    AND mbc.plan_id = -1 ' ||
                           '    AND mbc.sr_instance_id = mb.sr_instance_id ' ||
                           '    AND mbc.bill_sequence_id = mb.bill_sequence_id ' ||
                           '    AND mbc.inventory_item_id = msi.inventory_item_id ';

         IF (x_res_type = 2)
         THEN
            x_where_clause := x_where_clause ||
                           ' AND exp.sdate = inp.end_time ';
         ELSIF (x_res_type = 3)
         THEN
            x_where_clause := x_where_clause ||
                           ' AND exp.sdate = inp.start_time ';
         END IF;

         x_insert_clause := 'INSERT INTO MSD_DP_PLANNING_PCT_DENORM ( ' ||
                            '   DEMAND_PLAN_ID, ' ||
                            '   DP_SCENARIO_ID, ' ||
                            '   DATE_FROM, ' ||
                            '   DATE_TO, ' ||
                            '   SR_INSTANCE_ID, ' ||
                            '   ORGANIZATION_ID, ' ||
                            '   INVENTORY_ITEM_ID, ' ||
                            '   COMPONENT_SEQUENCE_ID, ' ||
                            '   ORIG_COMPONENT_SEQUENCE_ID, ' ||
                            '   BILL_SEQUENCE_ID, ' ||
                            '   ASSEMBLY_ITEM_ID, ' ||
                            '   PLANNING_FACTOR, ' ||
                            '   PLAN_PERCENTAGE_TYPE, ' ||
                            '   CREATION_DATE, ' ||
                            '   CREATED_BY, ' ||
                            '   LAST_UPDATE_LOGIN )';

         x_large_sql := x_insert_clause || x_select_clause || x_from_clause || x_where_clause;

         /* For Planning Percentages - Pre-aggregate the view */
         IF (x_publish_variant = 1)
         THEN

            x_inner_view := '(SELECT SDATE, '
                            || x_prd_level;

            IF (x_prd_key_column IS NOT NULL)
            THEN
               x_inner_view := x_inner_view || ' , ' || x_prd_key_column;
            END IF;

            x_inner_view := x_inner_view || ' , ' || x_parent_item_level;

            IF (x_is_global_fcst = 2)
            THEN
               x_inner_view := x_inner_view || ' , ' || x_org_level;
            END IF;

            x_inner_view := x_inner_view || ' , SUM( ' || x_parent_series_iname || ' ) ' || x_parent_series_iname;
            x_inner_view := x_inner_view || ' , SUM( ' || x_option_series_iname || ' ) ' || x_option_series_iname;
            x_inner_view := x_inner_view || ' , AVG( ' || x_pctg_series_iname   || ' ) ' || x_pctg_series_iname;

            x_inner_view := x_inner_view || ' FROM ' || x_schema || '.' || x_view_name;

            x_inner_view := x_inner_view || ' GROUP BY SDATE, ' || x_prd_level;

            IF (x_prd_key_column IS NOT NULL)
            THEN
               x_inner_view := x_inner_view || ' , ' || x_prd_key_column;
            END IF;

            x_inner_view := x_inner_view || ' , ' || x_parent_item_level;

            IF (x_is_global_fcst = 2)
            THEN
               x_inner_view := x_inner_view || ' , ' || x_org_level;
            END IF;

            x_inner_view := x_inner_view || ' ) ';

            x_large_sql := replace (x_large_sql, x_schema || '.' || x_view_name, x_inner_view);

         END IF;


         /* Delete all data in the denorm for the export data profile */
         DELETE FROM MSD_DP_PLANNING_PCT_DENORM
         WHERE demand_plan_id = x_demand_plan_id
            AND dp_scenario_id = x_scenario_id;

         COMMIT;

         /* Insert planning percentages into denorm table */
         EXECUTE IMMEDIATE x_large_sql;
         x_num_rows := SQL%ROWCOUNT;

         COMMIT;

         msd_dem_collect_history_data.analyze_table (
         				x_errbuf,
         				x_retcode,
         				'MSD_DP_PLANNING_PCT_DENORM');

         x_small_sql := ' BEGIN ' || x_schema || '.dl_log_status(''' || VS_MSG_UPLOAD_PCTG || ''' , ''' ||
                        VS_MSG_LOADED || ' ' || p_pp_export_data_profile || ''' , ''' || VS_MSG_SUCCEEDED || ''' ); END;';


         EXECUTE IMMEDIATE x_small_sql;

         /* Alter session to demantra schema */
         x_small_sql := 'alter session set current_schema = ' || x_schema;
         EXECUTE IMMEDIATE x_small_sql;

      EXCEPTION
         WHEN OTHERS THEN

            x_small_sql := ' BEGIN ' || x_schema || '.dl_log_status(''' || VS_MSG_UPLOAD_PCTG || ''' , ''' ||
                           VS_MSG_LOADED || ' ' || p_pp_export_data_profile || ''' , ''' || VS_MSG_LOADE_ERROR || ''',''' || substr(SQLERRM,1,150) || ''' ); END;';


            EXECUTE IMMEDIATE x_small_sql;

            /* Alter session to demantra schema */
            x_small_sql := 'alter session set current_schema = ' || x_schema;
            EXECUTE IMMEDIATE x_small_sql;

            raise_application_error (-20015, 'Exception: msd_dem_upload_forecast.upload_planning_percentages - ' || substr(SQLERRM,1,150));

      END UPLOAD_PLANNING_PERCENTAGES;




      /*
       * This procedure exports total demand, forecast error and demand priority from Demantra
       * to the table MSD_DP_SCN_ENTRIES_DENOM.
       * The parameters are -
       * p_ind_export_data_profile - Export Data Profile used to export independent demand
       * p_dep_export_data_profile - Export Data Profile used to export dependent demand
       * p_ind_fcst_series_iname   - Internal Name of the series for independent demand
       * p_dep_fcst_series_iname   - Internal Name of the series for dependent demand
       */
      PROCEDURE UPLOAD_TOTAL_DEMAND (
      			p_ind_export_data_profile	IN VARCHAR2,
      			p_dep_export_data_profile   IN VARCHAR2,
      			p_ind_fcst_series_iname		IN VARCHAR2,
      			p_dep_fcst_series_iname 	IN VARCHAR2)
      IS

         x_errbuf				VARCHAR2(200)		:= NULL;
         x_retcode				VARCHAR2(100)		:= NULL;

         x_small_sql			VARCHAR2(600)		:= NULL;
         x_schema				VARCHAR(50)			:= NULL;
         x_ind_scenario_id		NUMBER				:= NULL;
         x_dep_scenario_id		NUMBER				:= NULL;
         x_max_demand_id		NUMBER				:= NULL;

      BEGIN

         /*** VALIDATE INPUT PARAMETERS - BEGIN ***/

         IF (   p_ind_export_data_profile IS NULL
             OR p_dep_export_data_profile IS NULL
             OR p_ind_fcst_series_iname IS NULL
             OR p_dep_fcst_series_iname IS NULL)
         THEN
            raise_application_error (-20001, 'Error: msd_dem_upload_forecast.upload_total_demand - All the four input parameters must be specified');
         END IF;

         /*** VALIDATE INPUT PARAMETERS - END ***/


         /* Independent Demand Publish */
         upload_forecast(p_ind_export_data_profile, p_ind_fcst_series_iname, null);

         /* Dependent Demand Publish */
         upload_forecast(p_dep_export_data_profile, null, p_dep_fcst_series_iname);


         /* Alter session to APPS */
         x_small_sql := 'alter session set current_schema = APPS';
         EXECUTE IMMEDIATE x_small_sql;


         x_schema := fnd_profile.value('MSD_DEM_SCHEMA');
         IF (x_schema IS NULL)
         THEN
            raise_application_error (-20002, 'Error: msd_dem_upload_forecast.upload_total_demand - Unable to find schema name');
         END IF;



         x_small_sql := ' BEGIN ' || x_schema || '.dl_log_status(''' || VS_MSG_UPLOAD_TD || ''' , ''' ||
                        VS_MSG_LOADING || ' ' || p_ind_export_data_profile || ''' , ''' || VS_MSG_STARTED || ''' ); END;';

         EXECUTE IMMEDIATE x_small_sql;



         x_small_sql := 'SELECT id FROM ' || x_schema || '.TRANSFER_QUERY WHERE lower(query_name) = :1 ';

         /* Get the id for independent data profile */
         EXECUTE IMMEDIATE x_small_sql
            INTO x_ind_scenario_id
            USING lower(p_ind_export_data_profile);
         x_ind_scenario_id := x_ind_scenario_id + C_SCENARIO_ID_OFFSET;

         /* Get the id for dependent data profile */
         EXECUTE IMMEDIATE x_small_sql
            INTO x_dep_scenario_id
            USING lower(p_dep_export_data_profile);
         x_dep_scenario_id := x_dep_scenario_id + C_SCENARIO_ID_OFFSET;

         /* Get the max demand id for independent demand */
         EXECUTE IMMEDIATE 'SELECT max(demand_id) FROM msd_dp_scn_entries_denorm WHERE scenario_id = :1'
            INTO x_max_demand_id
            USING x_ind_scenario_id;
         IF (x_max_demand_id IS NULL)
         THEN
             x_max_demand_id := 0; --bug#9466697 nallkuma
         ELSE
            x_max_demand_id := x_max_demand_id + 1;
         END IF;


         UPDATE msd_dp_scn_entries_denorm
         SET scenario_id = x_ind_scenario_id,
             demand_id = demand_id + x_max_demand_id
         WHERE scenario_id = x_dep_scenario_id;
         COMMIT;


         msd_dem_collect_history_data.analyze_table (
         				x_errbuf,
         				x_retcode,
         				'MSD_DP_SCN_ENTRIES_DENORM');

         x_small_sql := ' BEGIN ' || x_schema || '.dl_log_status(''' || VS_MSG_UPLOAD_TD || ''' , ''' ||
                        VS_MSG_LOADED || ' ' || p_ind_export_data_profile || ''' , ''' || VS_MSG_SUCCEEDED || ''' ); END;';


         EXECUTE IMMEDIATE x_small_sql;

         /* Alter session to demantra schema */
         x_small_sql := 'alter session set current_schema = ' || x_schema;
         EXECUTE IMMEDIATE x_small_sql;

      EXCEPTION
         WHEN OTHERS THEN

            x_small_sql := ' BEGIN ' || x_schema || '.dl_log_status(''' || VS_MSG_UPLOAD_TD || ''' , ''' ||
                           VS_MSG_LOADED || ' ' || p_ind_export_data_profile || ''' , ''' || VS_MSG_LOADE_ERROR || ''',''' || substr(SQLERRM,1,150) || ''' ); END;';


            EXECUTE IMMEDIATE x_small_sql;

            /* Alter session to demantra schema */
            x_small_sql := 'alter session set current_schema = ' || x_schema;
            EXECUTE IMMEDIATE x_small_sql;

            raise_application_error (-20015, 'Exception: msd_dem_upload_forecast.upload_total_demand - ' || substr(SQLERRM,1,150));

      END UPLOAD_TOTAL_DEMAND;





      /*
       * This procedure is a wrapper on top of existing procedure UPLOAD_FORECAST
       * This procedure accepts Application_IDs as arguments instead of data profile names.
       * The procedure get the data profile names from Demantra and then call UPLOAD FORECAST
       * The parameters are -
       * p_export_data_profile_wai - Application Id of the export data profile
       * p_ind_fcst_series_wai     - Application Id of the independent demand series
       * p_dep_fcst_series_wai     - Application Id of the dependent demand series
       */
      PROCEDURE UPLOAD_FORECAST_WITH_APP_ID (
      			p_export_data_profile_wai	IN VARCHAR2,
      			p_ind_fcst_series_wai		IN VARCHAR2 DEFAULT NULL,
      			p_dep_fcst_series_wai 		IN VARCHAR2 DEFAULT NULL)
      IS

         x_small_sql			VARCHAR2(600)		:= NULL;
         x_schema				VARCHAR2(50)		:= NULL;

         x_export_data_profile	VARCHAR2(255)		:= NULL;
         x_ind_fcst_series		VARCHAR2(50)		:= NULL;
         x_dep_fcst_series		VARCHAR2(50)		:= NULL;

      BEGIN

         IF (p_export_data_profile_wai IS NULL)
         THEN
            raise_application_error(-20001, 'Error: msd_dem_upload_forecast.upload_forecast_with_app_id - Export Data Profile Application ID is null');
         END IF;

         /* Alter session to APPS */
         x_small_sql := 'alter session set current_schema = APPS';
         EXECUTE IMMEDIATE x_small_sql;


         x_schema := fnd_profile.value('MSD_DEM_SCHEMA');
         IF (x_schema IS NULL)
         THEN
            raise_application_error (-20002, 'Error: msd_dem_upload_forecast.upload_forecast_with_app_id - Unable to find schema name');
         END IF;

         /* Get the name of the data profile */
         BEGIN

            EXECUTE IMMEDIATE 'SELECT query_name FROM ' || x_schema || '.TRANSFER_QUERY WHERE application_id = :1 '
               INTO x_export_data_profile
               USING p_export_data_profile_wai;

         EXCEPTION
            WHEN OTHERS THEN
               /* Alter session to demantra schema */
               x_small_sql := 'alter session set current_schema = ' || x_schema;
               EXECUTE IMMEDIATE x_small_sql;

               raise_application_error (-20003, 'Exception: msd_dem_upload_forecast.upload_forecast_with_app_id - Unable to find data profile ' || substr(SQLERRM,1,150));
         END;


         /* Get the internal name of the independent demand forecast series */
         BEGIN

            IF (p_ind_fcst_series_wai IS NOT NULL)
            THEN

               EXECUTE IMMEDIATE 'SELECT computed_name FROM ' || x_schema || '.COMPUTED_FIELDS WHERE application_id = :1 '
                  INTO x_ind_fcst_series
                  USING p_ind_fcst_series_wai;

            END IF;

         EXCEPTION
            WHEN OTHERS THEN
               /* Alter session to demantra schema */
               x_small_sql := 'alter session set current_schema = ' || x_schema;
               EXECUTE IMMEDIATE x_small_sql;

               raise_application_error (-20004, 'Exception: msd_dem_upload_forecast.upload_forecast_with_app_id - Unable to find ind fcst series ' || substr(SQLERRM,1,150));
         END;


         /* Get the internal name of the dependent demand forecast series */
         BEGIN

            IF (p_dep_fcst_series_wai IS NOT NULL)
            THEN

               EXECUTE IMMEDIATE 'SELECT computed_name FROM ' || x_schema || '.COMPUTED_FIELDS WHERE application_id = :1 '
                  INTO x_dep_fcst_series
                  USING p_dep_fcst_series_wai;

            END IF;

         EXCEPTION
            WHEN OTHERS THEN
               /* Alter session to demantra schema */
               x_small_sql := 'alter session set current_schema = ' || x_schema;
               EXECUTE IMMEDIATE x_small_sql;

               raise_application_error (-20005, 'Exception: msd_dem_upload_forecast.upload_forecast_with_app_id - Unable to find dep fcst series ' || substr(SQLERRM,1,150));
         END;

         /* Alter session to demantra schema */
         x_small_sql := 'alter session set current_schema = ' || x_schema;
         EXECUTE IMMEDIATE x_small_sql;


         upload_forecast(x_export_data_profile, x_ind_fcst_series, x_dep_fcst_series);


      EXCEPTION
         WHEN OTHERS THEN

            /* Alter session to demantra schema */
            x_small_sql := 'alter session set current_schema = ' || x_schema;
            EXECUTE IMMEDIATE x_small_sql;

            raise_application_error (-20015, 'Exception: msd_dem_upload_forecast.upload_forecast_with_app_id - ' || substr(SQLERRM,1,150));

      END UPLOAD_FORECAST_WITH_APP_ID;




     /*
      * This procedure is a wrapper on top of existing procedure UPLOAD_PLANNING_PERCENTAGES
      * This procedure accepts Application-IDs as arguments instead of data profile names.
      * The procedure gets thedata profile names from Demantra and then calls UPLOAD_PLANNING_PERCENTAGES
      * The parameters are -
      *
      */
     PROCEDURE UPLOAD_PLNG_PCTG_WITH_APP_ID (
      			p_pp_export_data_profile_wai	IN	VARCHAR2,
      			p_fcst_export_data_profile_wai	IN	VARCHAR2,
      			p_pctg_series_wai				IN	VARCHAR2,
      			p_parent_item_series_wai		IN	VARCHAR2 DEFAULT NULL,
      			p_option_item_series_wai		IN	VARCHAR2 DEFAULT NULL )
     IS

        x_small_sql						VARCHAR2(600)		:= NULL;
        x_schema						VARCHAR2(50)		:= NULL;

        x_pp_export_data_profile		VARCHAR2(255)		:= NULL;
        x_fcst_export_data_profile		VARCHAR2(255)		:= NULL;
        x_pctg_series					VARCHAR2(50)		:= NULL;
        x_parent_item_series			VARCHAR2(50)		:= NULL;
        x_option_item_series			VARCHAR2(50)		:= NULL;

     BEGIN

        IF (p_pp_export_data_profile_wai IS NULL)
        THEN
            raise_application_error (-20001, 'Error: msd_dem_upload_forecast.upload_plng_pctg_with_app_id - Planning Percentage export data profile APP ID NOT provided');
	    END IF;

	    IF (p_fcst_export_data_profile_wai IS NULL)
        THEN
            raise_application_error (-20002, 'Error: msd_dem_upload_forecast.upload_plng_pctg_with_app_id - Total Demand export data profile APP ID NOT provided');
	    END IF;

	    IF (p_pctg_series_wai IS NULL)
        THEN
            raise_application_error (-20003, 'Error: msd_dem_upload_forecast.upload_plng_pctg_with_app_id - Planning Percentage series APP ID NOT provided');
	    END IF;

	    x_schema := fnd_profile.value('MSD_DEM_SCHEMA');
        IF (x_schema IS NULL)
        THEN
           raise_application_error (-20004, 'Error: msd_dem_upload_forecast.upload_plng_pctg_with_app_id - Unable to find schema name');
        END IF;


	    /* Get the name of the planning percentage data profile */
         BEGIN

            EXECUTE IMMEDIATE 'SELECT query_name FROM ' || x_schema || '.TRANSFER_QUERY WHERE application_id = :1 '
               INTO x_pp_export_data_profile
               USING p_pp_export_data_profile_wai;

         EXCEPTION
            WHEN OTHERS THEN
               /* Alter session to demantra schema */
               x_small_sql := 'alter session set current_schema = ' || x_schema;
               EXECUTE IMMEDIATE x_small_sql;

               raise_application_error (-20005, 'Exception: msd_dem_upload_forecast.upload_forecast_with_app_id - Unable to find plan pct data profile ' || substr(SQLERRM,1,150));
         END;

	    /* Get the name of the total demand data profile */
         BEGIN

            EXECUTE IMMEDIATE 'SELECT query_name FROM ' || x_schema || '.TRANSFER_QUERY WHERE application_id = :1 '
               INTO x_fcst_export_data_profile
               USING p_fcst_export_data_profile_wai;

         EXCEPTION
            WHEN OTHERS THEN
               /* Alter session to demantra schema */
               x_small_sql := 'alter session set current_schema = ' || x_schema;
               EXECUTE IMMEDIATE x_small_sql;

               raise_application_error (-20006, 'Exception: msd_dem_upload_forecast.upload_forecast_with_app_id - Unable to find total demand data profile ' || substr(SQLERRM,1,150));
         END;

         /* Get the internal name of the planning percentage series */
         BEGIN

            EXECUTE IMMEDIATE 'SELECT computed_name FROM ' || x_schema || '.COMPUTED_FIELDS WHERE application_id = :1 '
               INTO x_pctg_series
               USING p_pctg_series_wai;

         EXCEPTION
            WHEN OTHERS THEN
               /* Alter session to demantra schema */
               x_small_sql := 'alter session set current_schema = ' || x_schema;
               EXECUTE IMMEDIATE x_small_sql;

               raise_application_error (-20007, 'Exception: msd_dem_upload_forecast.upload_forecast_with_app_id - Unable to find plan pct series ' || substr(SQLERRM,1,150));
         END;

         /* Get the internal name of the parent item demand forecast series */
         BEGIN

            IF (p_parent_item_series_wai IS NOT NULL)
            THEN

               EXECUTE IMMEDIATE 'SELECT computed_name FROM ' || x_schema || '.COMPUTED_FIELDS WHERE application_id = :1 '
                  INTO x_parent_item_series
                  USING p_parent_item_series_wai;

            END IF;

         EXCEPTION
            WHEN OTHERS THEN
               /* Alter session to demantra schema */
               x_small_sql := 'alter session set current_schema = ' || x_schema;
               EXECUTE IMMEDIATE x_small_sql;

               raise_application_error (-20008, 'Exception: msd_dem_upload_forecast.upload_forecast_with_app_id - Unable to find parent item demand fcst series ' || substr(SQLERRM,1,150));
         END;

         /* Get the internal name of the option item demand forecast series */
         BEGIN

            IF (p_option_item_series_wai IS NOT NULL)
            THEN

               EXECUTE IMMEDIATE 'SELECT computed_name FROM ' || x_schema || '.COMPUTED_FIELDS WHERE application_id = :1 '
                  INTO x_option_item_series
                  USING p_option_item_series_wai;

            END IF;

         EXCEPTION
            WHEN OTHERS THEN
               /* Alter session to demantra schema */
               x_small_sql := 'alter session set current_schema = ' || x_schema;
               EXECUTE IMMEDIATE x_small_sql;

               raise_application_error (-20009, 'Exception: msd_dem_upload_forecast.upload_forecast_with_app_id - Unable to find option item demand fcst series ' || substr(SQLERRM,1,150));
         END;

        /* Alter session to demantra schema */
        x_small_sql := 'alter session set current_schema = ' || x_schema;
        EXECUTE IMMEDIATE x_small_sql;


        upload_planning_percentages (x_pp_export_data_profile, x_fcst_export_data_profile, x_pctg_series, x_parent_item_series, x_option_item_series);


     EXCEPTION
        WHEN OTHERS THEN

            /* Alter session to demantra schema */
            x_small_sql := 'alter session set current_schema = ' || x_schema;
            EXECUTE IMMEDIATE x_small_sql;

            raise_application_error (-20015, 'Exception: msd_dem_upload_forecast.upload_plng_pctg_with_app_id - ' || substr(SQLERRM,1,150));

     END UPLOAD_PLNG_PCTG_WITH_APP_ID;




      /*
       * This procedure is a wraper on top of existing procedure UPLOAD_TOTAL_DEMAND
       * This procedure accepts Application_IDs as arguments instead of data profile names.
       * The procedure gets the data profile names from Demantra and then calls UPLOAD_TOTAL_DEMAND
       * The parameters are -
       * p_ind_export_data_profile_wai - Application Id of the export data profile used to export independent demand
       * p_dep_export_data_profile_wai - Application Id of the export data profile used to export dependent demand
       * p_ind_fcst_series_wai         - Application Id of the series which holds independent demand
       * p_dep_fcst_series_wai         - Application Id of the series which holds dependent demand
       */
      PROCEDURE UPLOAD_CTO_FCST_WITH_APP_ID (
      			p_ind_export_data_profile_wai	IN VARCHAR2,
      			p_dep_export_data_profile_wai   IN VARCHAR2,
      			p_ind_fcst_series_wai			IN VARCHAR2,
      			p_dep_fcst_series_wai 			IN VARCHAR2)
      IS

         x_small_sql					VARCHAR2(600)		:= NULL;
         x_schema						VARCHAR2(50)		:= NULL;

         x_ind_export_data_profile		VARCHAR2(255)		:= NULL;
         x_dep_export_data_profile      VARCHAR2(255)		:= NULL;
         x_ind_fcst_series              VARCHAR2(50)		:= NULL;
         x_dep_fcst_series              VARCHAR2(50)		:= NULL;

      BEGIN

         IF (   p_ind_export_data_profile_wai IS NULL
             OR p_dep_export_data_profile_wai IS NULL
             OR p_ind_fcst_series_wai IS NULL
             OR p_dep_fcst_series_wai IS NULL)
         THEN
            raise_application_error (-20001, 'Error: msd_dem_upload_forecast.upload_cto_fcst_with_app_id - All the four input parameters must be specified');
         END IF;


        x_schema := fnd_profile.value('MSD_DEM_SCHEMA');
        IF (x_schema IS NULL)
        THEN
           raise_application_error (-20002, 'Error: msd_dem_upload_forecast.upload_cto_fcst_with_app_id - Unable to find schema name');
        END IF;


        /* Get the name of the independent demand data profile */
         BEGIN

            EXECUTE IMMEDIATE 'SELECT query_name FROM ' || x_schema || '.TRANSFER_QUERY WHERE application_id = :1 '
               INTO x_ind_export_data_profile
               USING p_ind_export_data_profile_wai;

         EXCEPTION
            WHEN OTHERS THEN
               /* Alter session to demantra schema */
               x_small_sql := 'alter session set current_schema = ' || x_schema;
               EXECUTE IMMEDIATE x_small_sql;

               raise_application_error (-20003, 'Exception: msd_dem_upload_forecast.upload_cto_fcst_with_app_id - Unable to find independent demand data profile ' || substr(SQLERRM,1,150));
         END;

        /* Get the name of the dependent demand data profile */
         BEGIN

            EXECUTE IMMEDIATE 'SELECT query_name FROM ' || x_schema || '.TRANSFER_QUERY WHERE application_id = :1 '
               INTO x_dep_export_data_profile
               USING p_dep_export_data_profile_wai;

         EXCEPTION
            WHEN OTHERS THEN
               /* Alter session to demantra schema */
               x_small_sql := 'alter session set current_schema = ' || x_schema;
               EXECUTE IMMEDIATE x_small_sql;

               raise_application_error (-20004, 'Exception: msd_dem_upload_forecast.upload_cto_fcst_with_app_id - Unable to find dependent demand data profile ' || substr(SQLERRM,1,150));
         END;

        /* Get the internal name of the independent demand forecast series */
         BEGIN

            EXECUTE IMMEDIATE 'SELECT computed_name FROM ' || x_schema || '.COMPUTED_FIELDS WHERE application_id = :1 '
               INTO x_ind_fcst_series
               USING p_ind_fcst_series_wai;

         EXCEPTION
            WHEN OTHERS THEN
               /* Alter session to demantra schema */
               x_small_sql := 'alter session set current_schema = ' || x_schema;
               EXECUTE IMMEDIATE x_small_sql;

               raise_application_error (-20005, 'Exception: msd_dem_upload_forecast.upload_cto_fcst_with_app_id - Unable to find independent demand series ' || substr(SQLERRM,1,150));
         END;

        /* Get the internal name of the dependent demand forecast series */
         BEGIN

            EXECUTE IMMEDIATE 'SELECT computed_name FROM ' || x_schema || '.COMPUTED_FIELDS WHERE application_id = :1 '
               INTO x_dep_fcst_series
               USING p_dep_fcst_series_wai;

         EXCEPTION
            WHEN OTHERS THEN
               /* Alter session to demantra schema */
               x_small_sql := 'alter session set current_schema = ' || x_schema;
               EXECUTE IMMEDIATE x_small_sql;

               raise_application_error (-20005, 'Exception: msd_dem_upload_forecast.upload_cto_fcst_with_app_id - Unable to find dependent demand series ' || substr(SQLERRM,1,150));
         END;

        /* Alter session to demantra schema */
        x_small_sql := 'alter session set current_schema = ' || x_schema;
        EXECUTE IMMEDIATE x_small_sql;


        upload_total_demand (x_ind_export_data_profile, x_dep_export_data_profile, x_ind_fcst_series, x_dep_fcst_series);


      EXCEPTION
         WHEN OTHERS THEN

            /* Alter session to demantra schema */
            x_small_sql := 'alter session set current_schema = ' || x_schema;
            EXECUTE IMMEDIATE x_small_sql;

            raise_application_error (-20015, 'Exception: msd_dem_upload_forecast.upload_cto_fcst_with_app_id - ' || substr(SQLERRM,1,150));

      END UPLOAD_CTO_FCST_WITH_APP_ID;

END MSD_DEM_UPLOAD_FORECAST;

/
