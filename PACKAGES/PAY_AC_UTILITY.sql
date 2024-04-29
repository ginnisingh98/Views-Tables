--------------------------------------------------------
--  DDL for Package PAY_AC_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AC_UTILITY" AUTHID CURRENT_USER as
/* $Header: pyacutil.pkh 120.2 2005/12/01 08:45 sdahiya noship $ */

  /*********************************************************************
  **  Name      : get_defined_balance_id
  **  Purpose   : This function returns the defined_balance_id for a
  **              given Balance Name and Dimension for Mexico.
  **  Arguments : IN Parameters
  **              p_balance_type_id -> Balance Type ID
  **              p_balance_name    -> Balance Name
  **              p_dimension_name  -> Dimension Name or
  **                                   database_item_suffix
  **              p_bus_grp_id      -> Business Group ID
  **              p_legislation_cd  -> Legislation Code
  **
  **  Notes     : The combination of Business Group ID and
  **              Legislation Code would be 'Not NULL / NULL' or
  **              'NULL / Not NULL'.
  **
  **              When first character of p_dimension_name is
  **              underscore, then it is considered as
  **              database_item_suffix.
  *********************************************************************/

  FUNCTION get_defined_balance_id (p_balance_type_id IN NUMBER
                                  ,p_dimension_name  IN VARCHAR2
                                  ,p_bus_grp_id      IN NUMBER
                                  ,p_legislation_cd  IN VARCHAR2)
    RETURN NUMBER;

  FUNCTION get_defined_balance_id (p_balance_name    IN VARCHAR2
                                  ,p_dimension_name  IN VARCHAR2
                                  ,p_bus_grp_id      IN NUMBER
                                  ,p_legislation_cd  IN VARCHAR2)
    RETURN NUMBER;

  /**********************************************************************
  **  Name      : get_balance_name
  **  Purpose   : This function returns translated value of the balance
  **              name.
  **  Arguments : IN Parameters
  **              p_balance_type_id -> Balance Type ID
  **  Notes     :
  **********************************************************************/

  FUNCTION get_balance_name (p_balance_type_id IN NUMBER)
    RETURN VARCHAR2;

  /**********************************************************************
  **  Name      : get_bal_reporting_name
  **  Purpose   : This function returns translated value of reporting
  **              name of the balance.
  **  Arguments : IN Parameters
  **              p_balance_type_id -> Balance Type ID
  **  Notes     :
  **********************************************************************/

  FUNCTION get_bal_reporting_name (p_balance_type_id IN NUMBER)
    RETURN VARCHAR2;

  /************************************************************************
  **  Type      : PL/SQL Table Structure
  **  Purpose   : Cached following values to get balance name and balance
  **              reporting name.
  **
  **              bal_type_id       -> Balance Type ID
  **              bal_name          -> Balance Name (Translated)
  **              bal_rep_name      -> Balance Reporting Name (Translated)
  **  Notes     :
  ************************************************************************/

  TYPE balance  IS RECORD ( bal_type_id         number(15),
                            bal_name            varchar2(240),
                            bal_rep_name        varchar2(240));

  TYPE balance_tbl IS TABLE OF balance INDEX BY BINARY_INTEGER;

  bal_tbl      balance_tbl;

  /**********************************************************************
  **  Name      : get_balance_type_id
  **  Purpose   : This function returns balance type ID of given Balance
  **              Name, Business Group ID and Legislation Code.
  **  Arguments : IN Parameters
  **              p_balance_name    -> Balance Name
  **              p_bus_grp_id      -> Business Group ID
  **              p_legislation_cd  -> Legislation Code
  **  Notes     :
  **********************************************************************/
  FUNCTION get_balance_type_id ( p_balance_name   IN VARCHAR2
                               , p_bus_grp_id     IN NUMBER
                               , p_legislation_cd IN VARCHAR2)
    RETURN NUMBER;

  /**********************************************************************
  **  Name      : get_value
  **  Purpose   : This function returns balance value
  **
  **  Arguments : IN Parameters
  **              p_balance_type_id -> Balance Type ID
  **              p_dimension_name  -> Dimension Name or
  **                                   database_item_suffix
  **              p_bus_grp_id      -> Business Group ID
  **              p_legislation_cd  -> Legislation Code
  **              p_asg_act_id      -> Assignment Action ID
  **              p_tax_unit_id     -> Tax Unit ID
  **              p_date_paid       -> Date Paid
  **  Notes     :
  **********************************************************************/
  FUNCTION get_value (p_balance_type_id IN NUMBER
                     ,p_dimension_name  IN VARCHAR2
                     ,p_bus_grp_id      IN NUMBER
                     ,p_legislation_cd  IN VARCHAR2
                     ,p_asg_act_id      IN NUMBER
                     ,p_tax_unit_id     IN NUMBER
                     ,p_date_paid       IN DATE)
    RETURN NUMBER;

  FUNCTION get_value (p_balance_name    IN VARCHAR2
                     ,p_dimension_name  IN VARCHAR2
                     ,p_bus_grp_id      IN NUMBER
                     ,p_legislation_cd  IN VARCHAR2
                     ,p_asg_act_id      IN NUMBER
                     ,p_tax_unit_id     IN NUMBER
                     ,p_date_paid       IN DATE)
    RETURN NUMBER;

  /**************************************************************************
  ** Function : range_person_on
  ** Arguments: p_report_type
  **            p_report_format
  **            p_report_qualifier
  **            p_report_category
  ** Returns  : Returns true if the range_person performance enhancement is
  **            enabled for the process.
  **************************************************************************/
  FUNCTION range_person_on(p_report_type      in varchar2
                          ,p_report_format    in varchar2
                          ,p_report_qualifier in varchar2
                          ,p_report_category  in varchar2) RETURN BOOLEAN;

  /**************************************************************************
  ** Function : get_geocode
  ** Arguments: p_state_abbrev
  **            p_county_name
  **            p_city_name
  **            p_zip_code
  ** Returns  : Returns Vertex geocode. The function will currently return
  **            00-000-0000 for Canadian Cities
  **************************************************************************/
  FUNCTION get_geocode(p_state_abbrev in VARCHAR2
                      ,p_county_name  in VARCHAR2 DEFAULT null
                      ,p_city_name    in VARCHAR2 DEFAULT null
                      ,p_zip_code     in VARCHAR2 DEFAULT null)
  RETURN VARCHAR2;

  /****************************************************************************
    Name        : print_lob
    Description : This procedure prints contents of LOB passed as parameter.
  *****************************************************************************/

PROCEDURE print_lob(p_blob BLOB);


end pay_ac_utility;

 

/
