--------------------------------------------------------
--  DDL for Package MSD_DEM_SR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_SR_UTIL" AUTHID CURRENT_USER AS
/* $Header: msddemsus.pls 120.2.12010000.3 2008/11/04 11:34:39 sjagathe ship $ */

   /*** CONSTANTS ***/


   /*** PROCEDURES ***
   * EXECUTE_REMOTE_QUERY
   */

      /*
       * This procedure executes a query passed from a remote database.
       */

	procedure EXECUTE_REMOTE_QUERY(query IN VARCHAR2);


   /*** FUNCTIONS ***
    * SET_CUSTOMER_ATTRIBUTE
    * GET_CATEGORY_SET_ID
    * GET_CONVERSION_TYPE
    * GET_MASTER_ORGANIZATION
    * GET_CUSTOMER_ATTRIBUTE
    * GET_NULL_PK
    * GET_NULL_CODE
    * GET_NULL_DESC
    * UOM_CONV
    * IS_ITEM_OPTIONAL_FOR_LVL
    * IS_PRODUCT_FAMILY_FORECASTABLE
    * CONFIG_ITEM_EXISTS
    * CONVERT_GLOBAL_AMT
    * GET_ZONE_ATTR
    * GET_SR_ZONE_DESC
    * GET_SR_ZONE_PK
    * IS_TXN_DEPOT_REPAIR
    * GET_SERVICE_REQ_ORG_ID
    * FIND_PARENT_ITEM
    * FIND_BASE_MODEL
    * IS_ITEM_OPTIONAL_FOR_FACT
    */



      /*
       * Usability Enhancements. Bug # 3509147.
       * This function sets the value of profile MSD_CUSTOMER_ATTRIBUTE to NONE
       * if collecting for the first time
       */
      FUNCTION SET_CUSTOMER_ATTRIBUTE (
      			p_profile_code 		IN	VARCHAR2,
      			p_profile_value		IN	VARCHAR2,
      			p_profile_level		IN	VARCHAR2)
      RETURN NUMBER;

      /*
       * This function gets the value of the source profile MSD_DEM_CATEGORY_SET_NAME
       */
      FUNCTION GET_CATEGORY_SET_ID
      RETURN NUMBER;

      /*
       * This function gets the value of the source profile MSD_DEM_CONVERSION_TYPE
       */
      FUNCTION GET_CONVERSION_TYPE
      RETURN VARCHAR2;

      /*
       * This function gets the ID of the master organization in the source instance.
       */
      FUNCTION GET_MASTER_ORGANIZATION
      RETURN NUMBER;

      /*
       * This function gets the value of the source profile MSD_DEM_CUSTOMER_ATTRIBUTE
       */
      FUNCTION GET_CUSTOMER_ATTRIBUTE
      RETURN VARCHAR2;


      function get_null_pk return number;

      function get_null_code return VARCHAR2;

      function get_null_desc return VARCHAR2;

      function uom_conv (uom_code varchar2,
                   item_id  number)   return number;

      FUNCTION IS_ITEM_OPTIONAL_FOR_LVL(p_component_item_id  in  NUMBER) RETURN NUMBER;


      FUNCTION IS_PRODUCT_FAMILY_FORECASTABLE (p_org_id  in  NUMBER,
                                         p_inventory_item_id in  NUMBER,
                                         p_check_optional in NUMBER) RETURN NUMBER;

      FUNCTION CONFIG_ITEM_EXISTS ( p_header_id IN NUMBER,
                              p_org_id IN NUMBER,
                              p_ato_line_id IN NUMBER) RETURN NUMBER;

      function convert_global_amt(p_curr_code in varchar2, p_date in date) return number;

      FUNCTION get_zone_attr return varchar2;  --jarora

      FUNCTION get_sr_zone_desc ( p_location_id IN NUMBER,
			    p_zone_attr   IN VARCHAR2) RETURN VARCHAR2; --jarora

      FUNCTION get_sr_zone_pk ( p_location_id IN NUMBER,
			  p_zone_attr IN VARCHAR2) RETURN NUMBER; --jarora

      FUNCTION is_txn_depot_repair(p_txn_source_id IN NUMBER) return VARCHAR2;  --jarora

      FUNCTION get_service_req_org_id (p_txn_source_id IN NUMBER) return NUMBER; --jarora

      /* This function checks if data has to be collected for a given customer(party).
       * Returns 1 (true) if all the customer accounts associated with the customer are enabled,
       * returns 2 (false) if any of the customer accounts associated is disabled.
       */
      FUNCTION get_data_for_customer(p_party_id in number, p_cust_attribute in varchar2) return NUMBER; --syenamar

      /*
       * This function gets the parent item for the given item. If profile MSD_DEM: Calculate
       * Planning Percentage is set to 'Yes, for "Consume & Derive" Options only' then it gets
       * nearest parent model.
       */
      FUNCTION FIND_PARENT_ITEM ( p_link_to_line_id 	IN 	NUMBER,
                                  p_include_class	IN	VARCHAR2 )
         RETURN NUMBER;


      /*
       * This function get the inventory_item_id of the base model in the configuration.
       */
      FUNCTION FIND_BASE_MODEL ( p_top_model_line_id	IN	NUMBER )
         RETURN NUMBER;


      /*
       * This function is called when item has ato_forecast_control = NONE.
       * First, check whether the given component is optional component in the BOM or not.
       * If so, then find the parent's component sequence id and then check whether the
       * parent is either ((optional with forecast control = none) or (consume and derive))
       */
      FUNCTION IS_ITEM_OPTIONAL_FOR_FACT ( p_component_item_id		IN	NUMBER,
                                           p_component_sequence_id	IN	NUMBER,
                                           p_parent_line_id		IN	NUMBER )
         RETURN NUMBER;



END MSD_DEM_SR_UTIL;

/
