--------------------------------------------------------
--  DDL for Package MSD_COMMON_UTILITIES_LB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_COMMON_UTILITIES_LB" AUTHID CURRENT_USER AS
/* $Header: msdculbs.pls 120.0 2005/05/25 20:05:21 appldev noship $ */

/* Common Table Definitions */


LEVEL_VALUES_FACT_TABLE   VARCHAR2(50) := 'MSD_LEVEL_VALUES_LB' ;
LEVEL_ASSOC_FACT_TABLE    VARCHAR2(50) := 'MSD_LEVEL_ASSOCIATIONS_LB' ;
ITEM_INFO_FACT_TABLE    VARCHAR2(50) := 'MSD_ITEM_LIST_PRICE' ;
LEVEL_VALUES_STAGING_TABLE  VARCHAR2(50) := 'MSD_ST_LEVEL_VALUES_LB' ;
LEVEL_ASSOC_STAGING_TABLE   VARCHAR2(50) := 'MSD_ST_LEVEL_ASSOCIATIONS_LB' ;



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




FUNCTION get_level_pk( p_level_id IN NUMBER, p_sr_level_pk IN VARCHAR2) return number ;

FUNCTION get_demand_plan_id( p_plan_id IN NUMBER) return NUMBER;

FUNCTION get_item_cat_name( p_inventory_item_id IN NUMBER, p_category_set_id IN NUMBER ) return VARCHAR2 ;

FUNCTION get_supply_plan_start_date( p_plan_id IN NUMBER) return DATE ;

FUNCTION get_supply_plan_end_date( p_plan_id IN NUMBER) return DATE ;

FUNCTION get_cp_end_date  return DATE ;

FUNCTION get_plan_owning_org( p_plan_id IN NUMBER) return NUMBER ;

FUNCTION get_plan_owning_instance( p_plan_id IN NUMBER) return NUMBER ;


FUNCTION get_supply_plan_name( p_plan_id IN NUMBER) return VARCHAR2 ;

FUNCTION get_item_cat_desc( p_inventory_item_id IN NUMBER, p_category_set_id IN NUMBER ) RETURN VARCHAR2 ;

FUNCTION get_supply_plan_id( p_demand_plan_id IN NUMBER) return NUMBER ;

PROCEDURE liability_post_process( p_demand_plan_id IN NUMBER , p_scenario_name IN VARCHAR2,p_senario_rev_num IN NUMBER)  ;

FUNCTION liability_plan_update( p_demand_plan_id IN NUMBER ) RETURN NUMBER ;

FUNCTION get_default_mfg_cal ( p_org_id IN NUMBER , p_instance_id IN  NUMBER ) RETURN VARCHAR2 ;

FUNCTION get_default_uom RETURN VARCHAR2 ;

function get_liability_url(p_plan_id IN NUMBER ,  p_function_id IN VARCHAR2) RETURN VARCHAR2 ;

function get_base_uom(p_item_id in number, p_dp_plan_id in number) return varchar2;


procedure liability_preprocessor(p_plan_id IN NUMBER )   ;

 function liability_plan_exists(p_plan_id IN NUMBER ) return boolean  ;



END MSD_COMMON_UTILITIES_LB ;

 

/
