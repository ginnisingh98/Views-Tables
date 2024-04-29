--------------------------------------------------------
--  DDL for Package MSD_DEM_COMMON_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_COMMON_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: msddemcus.pls 120.8.12010000.7 2010/03/11 15:21:08 nallkuma ship $ */

   /*** CONSTANTS ***/

      /* ENTITY TYPES */
         C_HIERARCHY       		NUMBER        := 1;
         C_SERIES          		NUMBER        := 2;

      /* ENTITIES - Hierarchy */
         C_ITEM            		NUMBER        := 1;
         C_SHIP_FROM       		NUMBER        := 2;
         C_TRADING_PARTNER 		NUMBER        := 3;
         C_DEMAND_CLASS    		NUMBER        := 4;
         C_SALES_CHANNEL   		NUMBER        := 5;
         C_TIME            		NUMBER        := 6;

      /* ENTITIES - Series */
         C_RETURN_HISTORY  		NUMBER        := 1;
         C_BH_BI_BD                     NUMBER        := 2;
         C_BH_BI_RD                     NUMBER        := 3;
         C_BH_RI_BD			NUMBER	      := 4;
         C_BH_RI_RD			NUMBER	      := 5;
         C_SH_SI_SD			NUMBER	      := 6;
         C_SH_SI_RD			NUMBER	      := 7;
         C_SH_RI_SD			NUMBER	      := 8;
         C_SH_RI_RD			NUMBER	      := 9;
         C_SRP_RETURN_HISTORY           NUMBER	      := 10;  --jarora
         C_SRP_USG_HISTORY_DR           NUMBER	      := 11;  --jarora
         C_SRP_USG_HISTORY_FS           NUMBER	      := 12;  --jarora
         C_INSTALL_BASE_HISTORY         NUMBER	      := 13;  --jarora
         C_TOTAL_BACKLOG                NUMBER	      := 14;  --sopjarora
         C_PAST_DUE_BACKLOG             NUMBER	      := 15;  --sopjarora
         C_ON_HAND_INVENTORY            NUMBER	      := 16;  --sopjarora
         C_ACTUAL_PRODUCTION            NUMBER	      := 17;  --sopjarora

      /* LEVEL TYPES */
         C_ITEM_LEVEL_TYPE 		NUMBER	      := 1;
         C_LOCATION_LEVEL_TYPE 		NUMBER	      := 2;
         C_TIME_LEVEL_TYPE		NUMBER	      := 3;

      /* YES/NO */
         C_YES             		NUMBER        := 1;
         C_NO              		NUMBER        := 2;

      /* COLLECTION TYPES */
         C_REFRESH         		NUMBER        := 1;
         C_NET_CHANGE      		NUMBER        := 2;

      /* MSD DEM Debug Profile Value */
         C_MSD_DEM_DEBUG   		VARCHAR2(1)   := nvl( fnd_profile.value( 'MSD_DEM_DEBUG_MODE'), 'N');

      /* Demantra Schema Name */
         C_MSD_DEM_SCHEMA		VARCHAR2(100) := nvl( fnd_profile.value( 'MSD_DEM_SCHEMA' ) , 'DMTRA_TEMPLATE');

      /* Demantra Sys_Params */
         C_DEM_MIN_SALES_DATE_D		DATE        := NULL;
         C_DEM_MAX_FORE_SALES_DATE_D    DATE  := NULL;
         C_DEM_MAX_SALES_DATE_D     DATE			:= NULL;
         C_DEM_HISTORY_PERIODS		NUMBER			:= NULL;
         C_DEM_LEAD					NUMBER			      := NULL;


   /*** PUBLIC PROCEDURES ***
    * LOG_MESSAGE
    * LOG_DEBUG
    * GET_DBLINK
    * GET_INSTANCE_INFO
    */

      /*
       * This procedure logs a given message text in the concurrent request log file.
       * param: p_buff - message text to be logged.
       */
      PROCEDURE LOG_MESSAGE ( p_buff           IN  VARCHAR2);

      /*
       * This procedure logs a given debug message text in the concurrent request log file
       * only if the profile MSD_DEM_DEBUG is set to 'Yes'.
       * param: p_buff - debug message text to be logged.
       */
      PROCEDURE LOG_DEBUG ( p_buff           IN  VARCHAR2);

       /*
        * This procedure gets the db link to the given source instance
        */
       PROCEDURE GET_DBLINK (
      			errbuf         		OUT  NOCOPY VARCHAR2,
      			retcode        		OUT  NOCOPY VARCHAR2,
      			p_sr_instance_id	IN	    NUMBER,
      			p_dblink		OUT  NOCOPY VARCHAR2);

      /*
       * This procedure gets the instance info given the source instance id
       */
      PROCEDURE GET_INSTANCE_INFO (
      			errbuf         		OUT  NOCOPY VARCHAR2,
      			retcode        		OUT  NOCOPY VARCHAR2,
                        p_instance_code		OUT  NOCOPY VARCHAR2,
                        p_apps_ver		OUT  NOCOPY NUMBER,
                        p_dgmt			OUT  NOCOPY NUMBER,
                        p_instance_type		OUT  NOCOPY NUMBER,
                        p_sr_instance_id	IN	    NUMBER);

      /*
       * This procedure will refresh Purge Series Data data profile to its defualt value
       * i.e. it will set the data profile option to No Load and No Purge for all series
       * included in the profile.
       */

       PROCEDURE REFRESH_PURGE_SERIES (
                        errbuf         		OUT  NOCOPY VARCHAR2,
      			retcode        		OUT  NOCOPY VARCHAR2,
      			p_profile_id            IN   NUMBER,
      			p_schema		IN   VARCHAR2);

    /*
    * Update the synonyms MSD_DEM_TRANSFER_LIST and MSD_DEM_TRANSFER_QUERY
    * to point to the Demantra's tables TRANSFER_LIST and TRANSFER_QUERY
    * if Demantra is installed.
    * Sets the profile MSD_DEM_SCHEMA to the Demantra Schema Name
    * The checks if the table MDP_MATRIX exists in the Demantra Schema
    */

    PROCEDURE UPDATE_SYNONYMS (
            errbuf         		OUT  NOCOPY VARCHAR2,
            retcode        		OUT  NOCOPY VARCHAR2,
            p_demantra_schema		IN	    VARCHAR2	DEFAULT NULL);

    /* Deletes the msd_dem_entities_inuse table if the new demantra schema is intstalled
    this will ensure that there will be no mapping between the seeded units in APPS and
    the (display uints,exchange rate,indexes) in Demantra */

    PROCEDURE CLEANUP_ENTITIES_INUSE(
            errbuf out nocopy varchar2,
            retcode out nocopy varchar2);


   /*** FUNCTIONS ***
    * GET_ALL_ORGS
    * DM_TIME_LEVEL
    * GET_PARAMETER_VALUE
    * GET_LOOKUP_VALUE
    * GET_UOM_CODE
    * GET_SR_INSTANCE_ID_FOR_ZONE
    * UOM_CONVERT
    * IS_PF_FCSTABLE_FOR_ITEM
    * IS_PRODUCT_FAMILY_FORECASTABLE
    * GET_SUPPLIER_CALENDAR
    * GET_SAFETY_STOCK_ENDDATE
    * GET_PERIOD_DATE_FOR_DUMMY
    * GET_SITE_FOR_CSF
    * IS_LAST_DATE_IN_BUCKET
    * GET_SNO_PLAN_CUTOFF_DATE
    * IS_SUPPLIER_CALENDAR_PRESENT
    * UOM_CONV
    * GET_LOOKUP_CODE
    * GET_LEVEL_NAME
    * GET_DEMANTRA_DATE
    * IS_USE_NEW_SITE_FORMAT
    * GET_DEMANTRA_VERSION
    * GET_APP_ID_TEXT
    * UPDATE_DEM_APCC_SYNONYM
    * GET_CTO_EFFECTIVE_DATE
    */



      /*
       * This function returns the comma(,) separated list of demand management enabled orgs
       * belonging to the given org group.
       */
      FUNCTION GET_ALL_ORGS (
      			p_org_group 		IN	VARCHAR2,
      			p_sr_instance_id	IN	NUMBER)
      RETURN VARCHAR2;

      /* This function returns the Active Demantra Data Model time level (Day/Month/week) */
      FUNCTION DM_TIME_LEVEL RETURN VARCHAR2;

      /* This function returns the parameter_value in msd_dem_setup_parameters given the parameter_name */
      FUNCTION GET_PARAMETER_VALUE (
                        p_sr_instance_id	NUMBER,
      			p_parameter_name	VARCHAR2)
      RETURN VARCHAR2;

      /* This function returns the lookup_value given the lookup_type and lookup_code */
      FUNCTION GET_LOOKUP_VALUE (
      			p_lookup_type	IN	VARCHAR2,
      			p_lookup_code	IN	VARCHAR2)
      RETURN VARCHAR2;

      /* This function returns the UOM code given the display unit id */
      FUNCTION GET_UOM_CODE (
      			p_unit_id	IN	NUMBER)
      RETURN VARCHAR2;

      /* This function returns a sr_instance_id in which the zone is defined */
      FUNCTION GET_SR_INSTANCE_ID_FOR_ZONE (
      			p_zone		IN	VARCHAR2)
      RETURN NUMBER;

      /* This function returns the conversion rate for the given item, From UOM and To UOM */
      FUNCTION UOM_CONVERT (
      			p_inventory_item_id	IN	NUMBER,
      			p_precision		IN 	NUMBER,
      			p_from_unit		IN	VARCHAR2,
      			p_to_unit		IN	VARCHAR2)
      RETURN NUMBER;

      /* This function returns 1 if the product family's forecast control is set for the given
         item in the master org, else returns 2 */
      FUNCTION IS_PF_FCSTABLE_FOR_ITEM (
      			p_sr_inventory_item_id	IN	NUMBER,
      			p_sr_instance_id	IN	NUMBER,
      			p_master_org_id		IN	NUMBER)
      RETURN NUMBER;

      /* This function returns 1 if the product family forecast control flag is set,
       * else returns 2
       */
      FUNCTION IS_PRODUCT_FAMILY_FORECASTABLE (
      			p_inventory_item_id	IN	NUMBER,
      			p_sr_instance_id	IN	NUMBER)
      RETURN NUMBER;

      /*
       * This function gets the calendar code
       */
      FUNCTION GET_SUPPLIER_CALENDAR (
      			p_plan_id		IN	NUMBER,
      			p_sr_instance_id	IN	NUMBER,
      			p_organization_id	IN	NUMBER,
      			p_inventory_item_id	IN	NUMBER,
      			p_supplier_id		IN	NUMBER,
      			p_supplier_site_id	IN	NUMBER,
      			p_using_organization_id	IN	NUMBER)
      RETURN VARCHAR2;

      /*
       * This function gets the period end date
       */
      FUNCTION GET_SAFETY_STOCK_ENDDATE (
      			p_plan_id		IN	NUMBER,
      			p_sr_instance_id	IN	NUMBER,
      			p_organization_id	IN	NUMBER,
      			p_inventory_item_id	IN	NUMBER,
      			p_period_start_date	IN	DATE)
      RETURN DATE;

      /*
       * Returns a valid date from the table INPUTS in Demantra
       */
      FUNCTION GET_PERIOD_DATE_FOR_DUMMY
      RETURN DATE;

      /*
       * Given, the instance, customer and/or site, this function returns
       * the site level member name. If only the customer is specified then
       * then any arbit site belonging to the customer is returned.
       */
      FUNCTION GET_SITE_FOR_CSF (
      			p_sr_instance_id	IN	NUMBER,
      			p_customer_id		IN	NUMBER,
      			p_customer_site_id	IN	NUMBER)
      RETURN VARCHAR2;

      /*
       * Given, the instance, calendar_code, calendar_date, this function
       * returns 1 if the date is the last date in its demantra bucket,
       * else returns 2.
       * Note: This function requires the table msd_dem_dates to be
       *       populated.
       */
      FUNCTION IS_LAST_DATE_IN_BUCKET (
      			p_sr_instance_id	IN	NUMBER,
      			p_calendar_code		IN	VARCHAR2,
      			p_calendar_date		IN	DATE)
      RETURN NUMBER;

      /*
       * Given the plan id of a SNO plan, this function returns
       * the cutoff date for the plan.
       */
      FUNCTION GET_SNO_PLAN_CUTOFF_DATE (
      			p_plan_id		IN	NUMBER)
      RETURN DATE;

      /*
       * This function returns 1 if a supplier calendar is present else returns 2.
       */
      FUNCTION IS_SUPPLIER_CALENDAR_PRESENT (
      			p_plan_id		IN	NUMBER,
      			p_sr_instance_id	IN	NUMBER,
      			p_organization_id	IN	NUMBER,
      			p_inventory_item_id	IN	NUMBER,
      			p_supplier_id		IN	NUMBER,
      			p_supplier_site_id	IN	NUMBER,
      			p_using_organization_id	IN	NUMBER)
      RETURN NUMBER;

      /*
       * Given the item and the uom code, this function gives the conversion factor
       * to the base uom of the item.
       */
      FUNCTION UOM_CONV (
      		   	p_sr_instance_id	IN	NUMBER,
      		   	p_uom_code 		IN	VARCHAR2,
                        p_inventory_item_id  		IN	NUMBER DEFAULT NULL)
      RETURN NUMBER;

      /*
       * This function given the Demantra lookup table name and lookup ID
       * returns the lookup Code
       */
      FUNCTION GET_LOOKUP_CODE (
      			p_lookup_table_name	IN	VARCHAR2,
      			p_lookup_id		IN	NUMBER)
      RETURN VARCHAR2;

      /*
       * This function given the Demantra lookup table name and lookup ID
       * returns the lookup Code
       */
      FUNCTION GET_LEVEL_NAME (
      			p_it_level_code		IN	NUMBER)
      RETURN VARCHAR2;

      /*
       * Given a date, the function returns the the bucket date to which the date belongs.
       * If p_date is null, p_from is 1, the the function returns
       *     max of (min_sales_date, sysdate - 2 years )
       * If p_date is null, p_from is 2, the the function returns
       *     min of (max_fore_sales_date, sysdate + 2 years )
       */
      FUNCTION GET_DEMANTRA_DATE (
      			p_date			IN	DATE,
      			p_from			IN	NUMBER)
      RETURN DATE;

      /*
       * The function is used to determine whether to use the new site format or not.
       * Returns -
       *    1 - use new site format, from 7.3.x onwards
       *    0 - use old site format, for 7.2.x release
       */
      FUNCTION IS_USE_NEW_SITE_FORMAT
         RETURN NUMBER;

      /*
       * The function returns the Demantra release version.
       */
      FUNCTION GET_DEMANTRA_VERSION
         RETURN VARCHAR2;


      /*
       * The function returns the request Demantra value or the join condition
       * given the lookup code. This function uses APP ID for Demantra 7.3 release
       * and internal ids for Demantra 7.2 release.
       */
      FUNCTION GET_APP_ID_TEXT (
      			p_lookup_type		IN	VARCHAR2,
      			p_lookup_code		IN	VARCHAR2,
      			p_is_select		IN	NUMBER,
      			p_column_name		IN	VARCHAR2)
         RETURN VARCHAR2;

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
    PROCEDURE UPDATE_DEM_APCC_SYNONYM(
		        errbuf out NOCOPY varchar2,
  			retcode out NOCOPY varchar2);

   /*
    * Use this function to determine start/end date of a CTO item
    * Dates calculated, to be closer to max sales date in demantra, as follows :
    * (If 'max_sales_date' sys_param is used the value will be used, else the max date from sales staging table will be considered)
    * Start date - bom_effective_date or (max_sales_date - cto_history_periods) whichever is higher
    * End date - bom_inactive_date or (max_sales_date + lead) whichever is closer to lower
    *
    * params :
    *          p_bom_date - bom_effective_date or bom_inactive_date
    *          p_min_max - if 1 (date passed is bom_effective_date) else (date passed is  bom_inactive_date)
    */
   FUNCTION GET_CTO_EFFECTIVE_DATE (
               p_bom_date IN DATE,
               p_min_max IN NUMBER DEFAULT 1)
   RETURN DATE;

END MSD_DEM_COMMON_UTILITIES;

/
