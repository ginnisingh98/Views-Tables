--------------------------------------------------------
--  DDL for Package BIS_COMMON_PARAMETERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_COMMON_PARAMETERS" AUTHID CURRENT_USER AS
/* $Header: BISGPFVS.pls 120.0.12000000.2 2007/04/20 09:04:17 rkumar ship $  */
   version               CONSTANT VARCHAR (80)
            := '$Header: BISGPFVS.pls 120.0.12000000.2 2007/04/20 09:04:17 rkumar ship $';

-- ------------------------
-- Global Variables
-- ------------------------


/*
HIGH 	number := nvl(FND_PROFILE.VALUE('BIS_TXN_COMPLEXITY_HIGH'), 0.5);
MEDIUM  number := nvl(FND_PROFILE.VALUE('BIS_TXN_COMPLEXITY_MEDIUM'), 1.0);
LOW 	number := nvl(FND_PROFILE.VALUE('BIS_TXN_COMPLEXITY_LOW'),2.0);
*/

FUNCTION HIGH 	return number;
FUNCTION MEDIUM return number;
FUNCTION LOW 	return number;

-- ------------------------
-- Public functions
--More will be added later
-- ------------------------


   function get_rate_type return varchar2;

   FUNCTION get_secondary_rate_type
      return  varchar2;

   function get_currency_code
     return varchar2;

   function get_secondary_currency_code
     return varchar2;

   function get_period_set_name
     return varchar2;

   function get_START_DAY_OF_WEEK_ID
     return varchar2;

   function get_period_type
     return varchar2;

   function get_workforce_mes_type_id
     return varchar2;

   function get_auto_factor_mode
     return varchar2;

   function get_ITM_HRCHY3_VBH_TOP_NODE
     return varchar2;

   function get_GLOBAL_START_DATE
     return date;

   function get_implementation_type
    return varchar2;

   procedure get_global_parameters(
	 p_parameter_list	IN DBMS_SQL.VARCHAR2_TABLE,
	 p_attribute_values	OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE);

   FUNCTION check_global_parameters(
	 p_parameter_list		IN DBMS_SQL.VARCHAR2_TABLE) return boolean;

  function get_item_category_set_1
     return varchar2;

  function get_item_category_set_2
     return varchar2;

  function get_item_category_set_3
     return varchar2;

  function get_item_org_catset_1
     return varchar2;

  function get_item_hierarchy3_type
     return varchar2;

  function get_master_instance
    return varchar2;

  function GET_DISPLAY_VALUE(NAME in varchar2)
    return varchar2;

  function GET_PRIMARY_CURDIS_NAME
    return varchar2;

  function GET_SECONDARY_CURDIS_NAME
    return varchar2;

  FUNCTION get_batch_size(p_complexity_level IN NUMBER) RETURN NUMBER;

  FUNCTION get_degree_of_parallelism RETURN NUMBER;

  FUNCTION get_current_date_id return DATE;

  FUNCTION get_value_at_site_level(pname IN VARCHAR2) RETURN VARCHAR2;


  FUNCTION get_annualized_currency_code
    return varchar2;

  FUNCTION get_annualized_rate_type
    return  varchar2;

  FUNCTION GET_ANNUALIZED_CURDIS_NAME
    return varchar2;

  -- get the profile option value at site level
  -- although this profile option is enabled for site, application, responsibility, and user levels
  FUNCTION get_low_percentage_range
    RETURN VARCHAR2;

  -- get the profile option value at site level
  -- although this profile option is enabled for site, application, responsibility, and user levels
  FUNCTION get_high_percentage_range
    RETURN VARCHAR2;

  FUNCTION get_treasury_rate_type
    RETURN VARCHAR2;

  FUNCTION GET_BIS_CUST_CLASS_TYPE
    RETURN VARCHAR2;
  --given an string removes multiple occurences of spaces with one space
  FUNCTION remove_extra_spaces(INPUT IN  VARCHAR2) RETURN VARCHAR2;


END bis_common_parameters;

 

/
