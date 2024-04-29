--------------------------------------------------------
--  DDL for Package MSD_COMMON_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_COMMON_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: msdcmuts.pls 120.3 2006/03/31 08:27:13 amitku noship $ */


/* Common Table Definitions */

SHIPMENT_FACT_TABLE     VARCHAR2(50) := 'MSD_SHIPMENT_DATA' ;
BOOKING_FACT_TABLE    VARCHAR2(50) := 'MSD_BOOKING_DATA' ;
SALES_FCST_FACT_TABLE     VARCHAR2(50) := 'MSD_SALES_FORECAST' ;
MFG_FCST_FACT_TABLE     VARCHAR2(50) := 'MSD_MFG_FORECAST' ;
OPPORTUNITY_FACT_TABLE    VARCHAR2(50) := 'MSD_SALES_OPPORTUNITY_DATA' ;
CURRENCY_FACT_TABLE   VARCHAR2(50) := 'MSD_CURRENCY_CONVERSIONS' ;
UOM_FACT_TABLE      VARCHAR2(50) := 'MSD_UOM_CONVERSIONS' ;
LEVEL_VALUES_FACT_TABLE   VARCHAR2(50) := 'MSD_LEVEL_VALUES' ;
LEVEL_ASSOC_FACT_TABLE    VARCHAR2(50) := 'MSD_LEVEL_ASSOCIATIONS' ;
ITEM_INFO_FACT_TABLE    VARCHAR2(50) := 'MSD_ITEM_LIST_PRICE' ;
TIME_FACT_TABLE     VARCHAR2(50) := 'MSD_TIME' ;
PRICING_FACT_TABLE              VARCHAR2(50) := 'MSD_PRICE_LIST';
SCENARIO_ENTRIES_TABLE          VARCHAR2(50) := 'MSD_DP_SCENARIO_ENTRIES';
MSD_LOCAL_ID_SETUP_TABLE        VARCHAR2(50) := 'MSD_LOCAL_ID_SETUP' ;
LEVEL_ORG_ASSCNS_FACT_TABLE  VARCHAR2(50) := 'MSD_LEVEL_ORG_ASSCNS' ;
ITEM_RELATIONSHIPS_FACT_TABLE  VARCHAR2(50) := 'MSD_ITEM_RELATIONSHIPS';

SHIPMENT_STAGING_TABLE          VARCHAR2(50) := 'MSD_ST_SHIPMENT_DATA' ;
BOOKING_STAGING_TABLE           VARCHAR2(50) := 'MSD_ST_BOOKING_DATA' ;
SALES_FCST_STAGING_TABLE        VARCHAR2(50) := 'MSD_ST_SALES_FORECAST' ;
MFG_FCST_STAGING_TABLE          VARCHAR2(50) := 'MSD_ST_MFG_FORECAST' ;
OPPORTUNITY_STAGING_TABLE     VARCHAR2(50) := 'MSD_ST_SALES_OPPORTUNITY_DATA' ;
CURRENCY_STAGING_TABLE        VARCHAR2(50) := 'MSD_ST_CURRENCY_CONVERSIONS' ;
UOM_STAGING_TABLE             VARCHAR2(50) := 'MSD_ST_UOM_CONVERSIONS' ;
LEVEL_VALUES_STAGING_TABLE  VARCHAR2(50) := 'MSD_ST_LEVEL_VALUES' ;
LEVEL_ASSOC_STAGING_TABLE   VARCHAR2(50) := 'MSD_ST_LEVEL_ASSOCIATIONS' ;
ITEM_INFO_STAGING_TABLE         VARCHAR2(50) := 'MSD_ST_ITEM_LIST_PRICE' ;
TIME_STAGING_TABLE    VARCHAR2(50) := 'MSD_ST_TIME' ;
PRICING_STAGING_TABLE           VARCHAR2(50) := 'MSD_ST_PRICE_LIST';

SHIPMENT_SOURCE_TABLE          VARCHAR2(50) := 'MSD_SR_SHIPMENT_DATA_V' ;
BOOKING_SOURCE_TABLE           VARCHAR2(50) := 'MSD_SR_BOOKING_DATA_V' ;
SALES_FCST_SOURCE_TABLE        VARCHAR2(50) := 'MSD_SR_SALES_FCST_V' ;
MFG_FCST_SOURCE_TABLE          VARCHAR2(50) := 'MSD_SR_MFG_FCST_V' ;
OPPORTUNITY_SOURCE_TABLE       VARCHAR2(50) := 'MSD_SR_OPPORTUNITY_V' ;
CURRENCY_SOURCE_TABLE          VARCHAR2(50) := 'MSD_SR_CURRENCY_CONVERSIONS_V' ;
UOM_SOURCE_TABLE               VARCHAR2(50) := 'MSD_SR_UOM_CONVERSIONS_V' ;
ITEM_INFO_SOURCE_TABLE         VARCHAR2(50) := 'MSD_SR_ITEM_LIST_PRICE_V' ;
MFG_TIME_SOURCE_TABLE        VARCHAR2(50) := 'MSD_SR_MFG_TIME_V' ;
FISCAL_TIME_SOURCE_TABLE       VARCHAR2(50) := 'MSD_SR_FISCAL_TIME_V' ;
PRICING_SOURCE_TABLE           VARCHAR2(50) := 'MSD_SR_PRICE_LIST_V';

/* OPM Comment Rajesh Patangya ***/
/* OPM source Definitions ***/
OPM_SHIPMENT_SOURCE_TABLE       VARCHAR2(50) := 'GMP_SR_SHIPMENT_DATA_V' ;
OPM_BOOKING_SOURCE_TABLE        VARCHAR2(50) := 'GMP_SR_BOOKING_DATA_V' ;
OPM_MFG_FCST_SOURCE_TABLE       VARCHAR2(50) := 'GMP_SR_MFG_FCST_V' ;
OPM_MFG_TIME_SOURCE_TABLE       VARCHAR2(50) := 'GMP_SR_MFG_TIME_V' ;

/* Common Column Definitions ***/
LEVEL_VALUE_COLUMN		VARCHAR2(50) := 'LEVEL_VALUE' ;
LEVEL_VALUE_PK_COLUMN		VARCHAR2(50) := 'SR_LEVEL_PK' ;
LEVEL_VALUE_DESC_COLUMN         VARCHAR2(50) := 'LEVEL_VALUE_DESC' ;
PARENT_LEVEL_VALUE_COLUMN 	VARCHAR2(50) := 'PARENT_LEVEL_VALUE' ;
PARENT_LEVEL_VALUE_PK_COLUMN	VARCHAR2(50) := 'SR_PARENT_LEVEL_PK' ;
PARENT_LEVEL_VALUE_DESC_COLUMN  VARCHAR2(50) := 'PARENT_VALUE_DESC' ;


SHIPMENT_DATE_USED    VARCHAR2(50) := 'SHIPPED_DATE' ;
BOOKING_DATE_USED   VARCHAR2(50) := 'BOOKED_DATE' ;
CURRENCY_DATE_USED    VARCHAR2(50) := 'CONVERSION_DATE' ;
OPPORTUNITY_DATE_USED   VARCHAR2(50) := 'SHIP_DATE' ;

/**** Calendar Types *** Same as MSD_CALENDAR_TYPE *********/
GREGORIAN_CALENDAR    NUMBER := 1 ;
MANUFACTURING_CALENDAR  NUMBER := 2 ;
FISCAL_CALENDAR   NUMBER := 3 ;
COMPOSITE_CALENDAR      NUMBER := 4 ;

/****** Level Collection Type same as MSD_LEVEL_COLLECTION_TYPE *****/
COLLECT_ALL                     VARCHAR2(1) := '1' ;
COLLECT_DP                      VARCHAR2(1) := '2' ;
COLLECT_DIMENSION               VARCHAR2(1) := '3' ;
COLLECT_HIERARCHY               VARCHAR2(1) := '4' ;
COLLECT_LEVEL                   VARCHAR2(1) := '5' ;

/********Yes, No values *****************/
MSD_YES_FLAG NUMBER :=1;
MSD_NO_FLAG  NUMBER :=2;

 -- ================== Process Flag ===================
   G_NEW                                   CONSTANT NUMBER := 1;
   G_IN_PROCESS                            CONSTANT NUMBER := 2;
   G_ERROR_FLG                             CONSTANT NUMBER := 3;
   G_VALID                                 CONSTANT NUMBER := 5;


/* Public Procedures */
procedure get_inst_info(
      p_instance_id   IN  NUMBER,
                        p_dblink        IN OUT NOCOPY   VARCHAR2,
      p_icode         IN OUT NOCOPY   VARCHAR2,
      p_apps_ver      IN OUT NOCOPY   NUMBER,
      p_dgmt          IN OUT NOCOPY   NUMBER,
      p_instance_type IN OUT NOCOPY  VARCHAR2,
      p_retcode       IN OUT NOCOPY  NUMBER) ;

procedure get_db_link(
                        p_instance_id    IN  NUMBER,
                        p_dblink         IN OUT NOCOPY  VARCHAR2,
      p_retcode        IN OUT NOCOPY  NUMBER);

function get_item_key(
                        p_instance_id   IN  NUMBER,
                        p_sr_key        IN  VARCHAR2,
                        p_val           IN  VARCHAR2,
      p_level_id      IN  NUMBER
                     ) return number ;

function get_org_key(
                        p_instance_id   IN  NUMBER,
                        p_sr_key        IN  VARCHAR2,
                        p_val           IN  VARCHAR2,
                        p_level_id      IN  NUMBER
                     ) return number ;

function get_level_value_pk(
                        p_instance_id   IN  NUMBER,
                        p_sr_key   	IN  VARCHAR2,
                        p_val      	IN  VARCHAR2,
                        p_level_id      IN  NUMBER
                     ) return number ;

function get_loc_key(
                        p_instance_id   IN  NUMBER,
                        p_sr_key        IN  VARCHAR2,
                        p_val           IN  VARCHAR2,
                        p_level_id      IN  NUMBER
                     ) return number ;

function get_cus_key(
                        p_instance_id   IN  NUMBER,
                        p_sr_key        IN  VARCHAR2,
                        p_val           IN  VARCHAR2,
                        p_level_id      IN  NUMBER
                     ) return number ;

function get_salesrep_key(
                        p_instance_id   IN  NUMBER,
                        p_sr_key        IN  VARCHAR2,
                        p_val           IN  VARCHAR2,
                        p_level_id      IN  NUMBER
                     ) return number ;

function get_sc_key(
                        p_instance_id   IN  NUMBER,
                        p_sr_key        IN  VARCHAR2,
                        p_val           IN  VARCHAR2,
                        p_level_id      IN  NUMBER
                     )  return number ;

function get_dcs_key(
                        p_instance_id   IN  NUMBER,
                        p_sr_key        IN  VARCHAR2,
                        p_val           IN  VARCHAR2,
                        p_level_id      IN  NUMBER
                     )  return number;

function get_level_pk return number ;

function get_level_name( p_level_id   IN NUMBER ) return varchar2 ;

function get_sr_level_pk return number;

function get_sr_level_pk (p_instance_id in NUMBER,
                          p_instance_code in VARCHAR2)
return number;

/* OPM Procedure added for OPM DP integration
   This takes level_id as input and gets the dimension code of the owning dimens
ion
*/
procedure get_dimension_code(
                        p_level_id         IN  NUMBER,
                        p_dimension_code    IN OUT NOCOPY   VARCHAR2,
                        p_retcode          IN OUT NOCOPY  NUMBER) ;

function get_level_value(p_level_pk in number) return varchar2;


PROCEDURE msd_uom_conversion (from_unit         varchar2,
                              to_unit           varchar2,
                              item_id           number,
                              uom_rate    OUT NOCOPY    number );

FUNCTION  msd_uom_convert (p_item_id           number,
                           p_precision         number,
                           p_from_unit         varchar2,
                           p_to_unit           varchar2) RETURN number;



FUNCTION  get_parent_level_pk (
                                p_instance_id varchar2,
                                p_level_id number,
                                p_parent_level_id number,
                                p_sr_level_pk varchar2
                               ) return number;

FUNCTION get_child_level_pk (
                                p_instance_id varchar2,
                                p_level_id number,
                                p_parent_level_id number,
                                p_sr_level_pk varchar2
                               ) return number;

FUNCTION is_global_scenario (
                                p_demand_plan_id number,
                                p_scenario_id number,
                                p_use_org_specific_bom_flag varchar2
                               ) return varchar2;

Function get_end_date(
    p_date             in date,
    p_calendar_type    in number,
    p_calendar_code    in varchar2,
    p_bucket_type      in number) return date;



FUNCTION IS_VALID_PF_EXIST ( p_instance  in  VARCHAR2,
                             p_inventory_item_id in  NUMBER) RETURN NUMBER;



Function get_lvl_pk_from_tp_id(
     p_tp_id   in  number,
     p_sr_instance_id    in number) return number;


FUNCTION get_translated_date (p_sql in varchar2, p_date in date) return date;

function get_iHelp_URL_prefix return varchar2;

procedure detach_all_aws;

function Get_Conc_Request_Status(conc_request_id NUMBER) return varchar2;

/* wrappers for dbms_aw package */
FUNCTION DBMS_AW_INTERP(cmd varchar2) RETURN CLOB;
FUNCTION DBMS_AW_INTERPCLOB(cmd clob) RETURN CLOB;
PROCEDURE DBMS_AW_INTERP_SILENT(cmd varchar2);
PROCEDURE DBMS_AW_EXECUTE(cmd varchar2);


FUNCTION GET_SR_LEVEL_PK(P_INSTANCE_ID IN NUMBER, P_LEVEL_ID IN NUMBER, P_LEVEL_PK IN NUMBER, P_LEVEL_VALUE OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION GET_AGE_IN_BUCKETS(P_START_DATE IN DATE,
                            P_END_DATE IN DATE,
			    P_TIME_LEVEL_ID IN NUMBER,
                            P_CALENDAR_CODE IN VARCHAR2) RETURN NUMBER;

FUNCTION GET_BUCKET_START_DATE (P_EFFECTIVE_DATE IN DATE,
                              P_OFFSET IN NUMBER,
			      P_TIME_LEVEL_ID IN NUMBER,
			      P_CALENDAR_CODE IN VARCHAR2) RETURN DATE;

FUNCTION GET_BUCKET_END_DATE (P_EFFECTIVE_DATE IN DATE,
                              P_OFFSET IN NUMBER,
			      P_TIME_LEVEL_ID IN NUMBER,
			      P_CALENDAR_CODE IN VARCHAR2) RETURN DATE;

FUNCTION get_supplier_calendar(
                             p_plan_id in number,
                             p_sr_instance_id in number,
                             p_organization_id in number,
                             p_inventory_item_id in number,
                             p_supplier_id in number,
                             p_supplier_site_id in number,
                             p_using_organization_id in number
                           ) return varchar2;

FUNCTION get_safety_stock_enddate(
                             p_plan_id in number,
                             p_sr_instance_id in number,
                             p_organization_id in number,
                             p_inventory_item_id in number,
                             p_period_start_date in date
                           ) return date;

function get_dp_enabled_flag (
                        p_instance_id   IN  NUMBER,
                        p_sr_key        IN  VARCHAR2,
                        p_val           IN  VARCHAR2,
                        p_level_id      IN  NUMBER
                     ) return number ;

procedure dp_log(plan_id in number, msg in varchar2, msg_type in varchar2 default null);

function uom_conv (uom_code varchar2,
                   item_id  number default null)
                   return number;

/*Bug#4249928 */
Function get_system_attribute1_desc(p_lookup_code in varchar2)
return varchar2 ;

Function EFFEC_AUTH( P_period_start_date in date
                                     ,p_period_end_date in date
                                     ,p_supplier_id in number
                                     ,p_sr_instance_id in number
                                     ,p_organization_id in number
                                     ,p_inventory_item_id in number
                                     ,p_supplier_site_id in number
                                     ,p_demand_plan_id in number)
return number ;

END MSD_COMMON_UTILITIES ;

 

/
