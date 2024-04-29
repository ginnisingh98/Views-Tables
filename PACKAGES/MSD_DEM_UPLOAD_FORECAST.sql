--------------------------------------------------------
--  DDL for Package MSD_DEM_UPLOAD_FORECAST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_UPLOAD_FORECAST" AUTHID DEFINER AS
/* $Header: msddemufs.pls 120.0.12010000.6 2009/10/26 10:27:30 syenamar ship $ */

   /*** CONSTANTS ***/

   C_IMPORT_DATA_PROFILE	NUMBER := 1;
   C_EXPORT_DATA_PROFILE	NUMBER := 2;
   C_IMPORT_EXPORT_DATA_PROFILE NUMBER := 3;

   C_DEMAND_PLAN_ID		NUMBER := 5555555;
   C_SCENARIO_ID_OFFSET		NUMBER := 5555555;

   C_BUCKET_TYPE_DAY		NUMBER := 1;
   C_BUCKET_TYPE_WEEK		NUMBER := 2;
   C_BUCKET_TYPE_MONTH		NUMBER := 3;

   C_PSNT_TYPE_CODE		NUMBER := 1;
   C_PSNT_TYPE_DESC		NUMBER := 0;

   C_EXPORT_TYPE_FULL		NUMBER := 1;
   C_EXPORT_TYPE_INCR		NUMBER := 2;

   C_TIME_LEVEL_DAY		NUMBER := 7;
   C_TIME_LEVEL_WEEK		NUMBER := 6;
   C_TIME_LEVEL_MONTH		NUMBER := 5;


   C_ITEM			VARCHAR2(50) := 'ITEM';
   C_PRODUCT_FAMILY		VARCHAR2(50) := 'PRODUCT FAMILY';
   C_ORGANIZATION		VARCHAR2(50) := 'ORGANIZATION';
   C_SITE			VARCHAR2(50) := 'SITE';
   C_CUSTOMER			VARCHAR2(50) := 'ACCOUNT';
   C_CUSTOMER_ZONE		VARCHAR2(50) := 'TRADING PARTER ZONE';
   C_ZONE			VARCHAR2(50) := 'ZONE';
   C_DEMAND_CLASS		VARCHAR2(50) := 'DEMAND CLASS';
   C_PARENT_ITEM                VARCHAR2(50) := 'PARENT ITEM';

   C_ROUNDOFF_PLACES		NUMBER	:= 6;

   C_FORECAST_SERIES_PREFIX	VARCHAR2(10)	:= 'FCST_';
   C_FCST_ACRY_SERIES_PREFIX	VARCHAR2(10)	:= 'ACRY_';
   C_DEMAND_PRTY_SERIES_PREFIX	VARCHAR2(10)    := 'PRTY_';
   C_DKEY_SERIES_PREFIX		VARCHAR2(10)	:= 'DKEY_';

   C_DKEY_ITEM			VARCHAR2(30)	:= 'ITEM';
   C_DKEY_SITE			VARCHAR2(30)    := 'SITE';
   C_DKEY_ORG			VARCHAR2(30)	:= 'ORG';


   /*** FUNCTIONS ***
    * GET_SR_INSTANCE_ID_FOR_GLOBAL
    * IS_VALID_SCENARIO
    * GET_SR_INSTANCE_ID_FOR_PROFILE
    * GET_ERROR_TYPE
    * IS_GLOBAL_SCENARIO
    * GET_CUSTOMER_FROM_TPZONE
    * GET_ZONE_FROM_TPZONE
    */

      /*
       * This function returns the sr_instance_id to be used for a global forecast
       */
      FUNCTION GET_SR_INSTANCE_ID_FOR_GLOBAL
      RETURN NUMBER;

      /* This function returns 1 if the data profile is fit for upload to ASCP
       * Current check only includes that a forecast series with internal name
       * starting 'FCST_' must be present.
       */
      FUNCTION IS_VALID_SCENARIO (
      			p_data_profile_id	IN	NUMBER)
      RETURN NUMBER;

      FUNCTION UPLOAD_TO_CP (
      			p_data_profile_id    	IN 	NUMBER)
      RETURN NUMBER;

      /* This function returns -23453 if the data profile contains non-global
       * forecast, else it returns the id of the source instance for which
       * global forecasting is being done.
       */
      FUNCTION GET_SR_INSTANCE_ID_FOR_PROFILE (
      			p_data_profile_id	IN	NUMBER)
      RETURN NUMBER;

      /* This function gets the error type 'MAD' or 'MAPE' given the data
       * profile id
       */
      FUNCTION GET_ERROR_TYPE (
      			p_data_profile_id	IN	NUMBER)
      RETURN VARCHAR2;

      /* This function return 'Y' if the data profile contains global forecast
       * else returns 'N'.
       */
      FUNCTION IS_GLOBAL_SCENARIO (
      			p_data_profile_id	IN	NUMBER)
      RETURN VARCHAR2;

      /* This function returns the source key of the customer, given the customer
       * zone
       */
      FUNCTION GET_CUSTOMER_FROM_TPZONE (
      			p_tp_zone		IN	VARCHAR2,
      			p_sr_instance_id	IN	NUMBER)
      RETURN NUMBER;

      /* This function returns the source key of the zone, given the customer zone
       */
      FUNCTION GET_ZONE_FROM_TPZONE (
      			p_tp_zone		IN	VARCHAR2,
      			p_sr_instance_id	IN	NUMBER)
      RETURN NUMBER;

   /*** PROCEDURES ***/

      /*
       * This procedure, given the export integration interface name, pushes the
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
      			p_dep_fcst_series_iname IN VARCHAR2 DEFAULT NULL);



   PROCEDURE GET_TIME_STRINGS (
                        p_bucket_type		OUT NOCOPY	NUMBER,
                        p_start_time		OUT NOCOPY	VARCHAR2,
                        p_end_time		OUT NOCOPY	VARCHAR2,
                        p_res_type		OUT NOCOPY	NUMBER,
                        p_time_from_clause	OUT NOCOPY	VARCHAR2,
   			p_time_res		IN 		NUMBER);


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
      			p_option_item_series_iname	IN	VARCHAR2 DEFAULT NULL );




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
      			p_dep_fcst_series_iname 	IN VARCHAR2);




      /*
       * This procedure is a wrapper on top of existing procedure UPLOAD_FORECAST
       * This procedure accepts Application_IDs as arguments instead of data profile names.
       * The procedure gets the data profile names from Demantra and then calls UPLOAD FORECAST
       * The parameters are -
       * p_export_data_profile_wai - Application Id of the export data profile
       * p_ind_fcst_series_wai     - Application Id of the independent demand series
       * p_dep_fcst_series_wai     - Application Id of the dependent demand series
       */
      PROCEDURE UPLOAD_FORECAST_WITH_APP_ID (
      			p_export_data_profile_wai	IN VARCHAR2,
      			p_ind_fcst_series_wai		IN VARCHAR2 DEFAULT NULL,
      			p_dep_fcst_series_wai 		IN VARCHAR2 DEFAULT NULL);




     /*
      * This procedure is a wrapper on top of existing procedure UPLOAD_PLANNING_PERCENTAGES
      * This procedure accepts Application_IDs as arguments instead of data profile names.
      * The procedure gets the data profile names from Demantra and then calls UPLOAD_PLANNING_PERCENTAGES
      * The parameters are -
      * p_pp_export_data_profile_wai   - Application Id of the export data profile used to export planning percentages
      * p_fcst_export_data_profile_wai - Application Id of the export data profile used to export total demand
      * p_pctg_series_wai              - Application Id of the series which holds final planning percentages
      * p_parent_item_series_wai       - Application Id of the series which holds parent total demand
      * p_option_item_series_wai       - Application Id of the series which holds the option demand
      */
     PROCEDURE UPLOAD_PLNG_PCTG_WITH_APP_ID (
      			p_pp_export_data_profile_wai	IN	VARCHAR2,
      			p_fcst_export_data_profile_wai	IN	VARCHAR2,
      			p_pctg_series_wai				IN	VARCHAR2,
      			p_parent_item_series_wai		IN	VARCHAR2 DEFAULT NULL,
      			p_option_item_series_wai		IN	VARCHAR2 DEFAULT NULL );




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
      			p_dep_fcst_series_wai 			IN VARCHAR2);


END MSD_DEM_UPLOAD_FORECAST;

/
