--------------------------------------------------------
--  DDL for Package PAY_MX_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_UTILITY" AUTHID CURRENT_USER as
/* $Header: pymxutil.pkh 120.3.12010000.1 2008/07/27 23:10:48 appldev ship $ */


  /**********************************************************************
  **  Name      : get_days_bal_type_id
  **  Purpose   : This function returns Balance Type ID of Days Balance
  **              for Mexico.
  **  Arguments : IN Parameters
  **              p_balance_type_id -> Balance Type ID of Primary Balance
  **  Notes     :
  **********************************************************************/

  FUNCTION get_days_bal_type_id (p_balance_type_id IN NUMBER)
    RETURN NUMBER;

  /************************************************************************
  **  Type      : PL/SQL Table Structure
  **  Purpose   : Stores following values
  **              bal_type_id       -> Balance Type ID
  **              days_bal_type_id  -> Balance Type ID of Days Balance
  **              bal_uom           -> Unit of Measure of Balance
  **  Notes     :
  ************************************************************************/

  TYPE days_balance  IS RECORD ( bal_type_id         number(15),
                                 days_bal_type_id    number(15),
                                 days_bal_uom        varchar2(240));

  TYPE days_balance_tbl IS TABLE OF days_balance INDEX BY BINARY_INTEGER;

  days_bal_tbl days_balance_tbl;


  /**********************************************************************
  **  Name      : get_hours_bal_type_id
  **  Purpose   : This function returns Balance Type ID of Hours Balance
  **              for Mexico.
  **  Arguments : IN Parameters
  **              p_balance_type_id -> Balance Type ID of Primary Balance
  **  Notes     :
  **********************************************************************/

  FUNCTION get_hours_bal_type_id (p_balance_type_id IN NUMBER)
    RETURN NUMBER;

  /************************************************************************
  **  Type      : PL/SQL Table Structure
  **  Purpose   : Stores following values
  **              bal_type_id        -> Balance Type ID
  **              hours_bal_type_id  -> Balance Type ID of Hours Balance
  **              bal_uom            -> Unit of Measure of Balance
  **  Notes     :
  ************************************************************************/

  TYPE hours_balance  IS RECORD ( bal_type_id          number(15),
                                  hours_bal_type_id    number(15),
                                  hours_bal_uom        varchar2(240));

  TYPE hours_balance_tbl IS TABLE OF hours_balance INDEX BY BINARY_INTEGER;

  hours_bal_tbl hours_balance_tbl;


  /************************************************************************
  **  Type      : PL/SQL Table Structure
  **  Purpose   : Stores following values
  **              name              -> Period Type of The Payroll
  **              days              -> No. of days for the payroll
  **                                   frequency in a year.
  **
  **  Notes     :
  **  Below Table contains period type of Weekly, Bi-Weekly, Monthly and
  **  Semi-Monthly payroll and its number of days for the current year
  **  based on value entered in pay_mx_legislation_info_f for
  **  Legislation Type 'MX Annualization Factor'.
  ************************************************************************/

  TYPE payroll_period_type IS RECORD ( name       VARCHAR2(150)
                                     , days       NUMBER);

  TYPE g_period_type IS TABLE OF payroll_period_type INDEX BY BINARY_INTEGER;

  py_prd_tp  g_period_type;

  /**********************************************************************
  **  Type      : Procedure
  **  Name      : get_days_mth_yr_for_pay_period
  **  Purpose   : This procedure popuate payroll_period_type PL/SQL table
  **              for the period type of the payroll and its number of
  **              days. (PL/SQL table structure mentioned above)
  **
  **  Arguments : IN Parameters
  **              p_payroll_id -> Payroll ID
  **
  **              OUT Parameters
  **              p_period_type -> Period Type of the payroll
  **              p_days_year   -> No. of Days in Year for the payroll
  **
  **  Notes     :
  **********************************************************************/

  PROCEDURE get_days_yr_for_pay_period( p_payroll_id   IN NUMBER
                                       ,p_period_type  OUT NOCOPY VARCHAR2
                                       ,p_days_year    OUT NOCOPY NUMBER);

  /************************************************************************
  **  Type      : PL/SQL Table Structure
  **  Purpose   : Stores following values
  **              Tax Unit ID       -> Tax Unit ID
  **              days_month        -> No. of days per Month
  **              days_year         -> No. of days per Year
  **
  **  Notes     :
  **  Below Table contains Number of Days per Month and
  **  Number of Days per Year entered at GRE Level. If not found at GRE
  **  Level then get the value from Legal Employer Level.
  **  Two PL/SQL tables are used to hold the values entered at the GRE
  **  and legal employer level. Each table is indexed on organization_id
  ************************************************************************/

  TYPE number_of_days IS RECORD ( days_month    NUMBER
                                , days_year     NUMBER);

  TYPE g_no_of_days IS TABLE OF number_of_days INDEX BY BINARY_INTEGER;

  gre_no_of_days g_no_of_days;
  le_no_of_days  g_no_of_days;

  /**********************************************************************
  **  Type      : Procedure
  **  Name      : get_no_of_days_for_org
  **  Purpose   : This procedure populate number_of_days PL/SQL table
  **              for the Month and the Year for GRE or Legal Employer.
  **              (PL/SQL table structure mentioned above)
  **
  **  Arguments : IN Parameters
  **              p_business_group_id -> Business Group ID
  **              p_tax_unit_id       -> Tax Unit ID
  **
  **              OUT Parameters
  **              p_days_month -> No. of Days in Month
  **              p_days_year  -> No. of Days in Year
  **
  **  Notes     :
  **********************************************************************/

  PROCEDURE get_no_of_days_for_org( p_business_group_id IN NUMBER
                                   ,p_org_id            IN NUMBER
                                   ,p_gre_or_le         IN VARCHAR2
                                   ,p_days_month        OUT NOCOPY NUMBER
                                   ,p_days_year         OUT NOCOPY NUMBER);

  /**********************************************************************
  **  Type      : Function
  **  Name      : get_days_month_year
  **  Purpose   : This function returns number of days based on p_mode.
  **              If p_mode is 'MONTH', this function returns no of days
  **              in month and if it is 'YEAR', this function return
  **              returns no of days in year.
  **
  **  Arguments : IN Parameters
  **              p_business_group_id -> Business Group ID
  **              p_tax_unit_id       -> Tax Unit ID
  **              p_payroll_id        -> Payroll ID
  **              p_mode              -> 'MONTH' or 'YEAR'
  **
  **  Notes     :
  **********************************************************************/
  FUNCTION  get_days_month_year( p_business_group_id IN NUMBER
                                ,p_tax_unit_id       IN NUMBER
                                ,p_payroll_id        IN NUMBER
                                ,p_mode              IN VARCHAR2 )
  RETURN NUMBER;

  /**********************************************************************
  **  Type      : Function
  **  Name      : get_days_in_year
  **  Purpose   : This function returns number of days based in year.
  **              This function calls get_days_month_year function
  **              with p_mode 'YEAR'.
  **
  **  Arguments : IN Parameters
  **              p_business_group_id -> Business Group ID
  **              p_tax_unit_id       -> Tax Unit ID
  **              p_payroll_id        -> Payroll ID
  **
  **  Notes     :
  **********************************************************************/
  FUNCTION  get_days_in_year( p_business_group_id IN NUMBER
                             ,p_tax_unit_id       IN NUMBER
                             ,p_payroll_id        IN NUMBER)
  RETURN NUMBER;

  /**********************************************************************
  **  Type      : Function
  **  Name      : get_days_in_month
  **  Purpose   : This function returns number of days based in month.
  **              This function calls get_days_month_year function
  **              with p_mode 'MONTH'.
  **
  **  Arguments : IN Parameters
  **              p_business_group_id -> Business Group ID
  **              p_tax_unit_id       -> Tax Unit ID
  **              p_payroll_id        -> Payroll ID
  **
  **  Notes     :
  **********************************************************************/
  FUNCTION  get_days_in_month( p_business_group_id IN NUMBER
                              ,p_tax_unit_id       IN NUMBER
                              ,p_payroll_id        IN NUMBER)
  RETURN NUMBER;

  /**********************************************************************
  **  Type      : Function
  **  Name      : get_days_in_pay_period
  **  Purpose   : This function returns number of days based on payroll
  **              frequency.
  **              Week       -> 7 Days
  **              Bi-Week    -> 14 Days
  **              Month      -> Getting no of days using get_days_in_month
  **              Semi-Month -> Month Days (above) / 2
  **
  **  Arguments : IN Parameters
  **              p_business_group_id -> Business Group ID
  **              p_tax_unit_id       -> Tax Unit ID
  **              p_payroll_id        -> Payroll ID
  **
  **  Notes     :
  **********************************************************************/
  FUNCTION  get_days_in_pay_period( p_business_group_id IN NUMBER
                                   ,p_tax_unit_id       IN NUMBER
                                   ,p_payroll_id        IN NUMBER)
  RETURN NUMBER;


  /**********************************************************************
  **  Type      : Function
  **  Name      : get_days_in_bimonth
  **  Purpose   : This function returns number of days for current and
  **              previous month.
  **              If payroll processsing is on 15-APR-2005 then this function
  **              will return 30 (for april 2005) + 31 (for mar 2005) = 61
  **              days.
  **  Notes     :
  **********************************************************************/
  FUNCTION  get_days_in_bimonth
  RETURN NUMBER ;


  /**********************************************************************
  **  Type      : Function
  **  Name      : get_classification_id
  **  Purpose   : This function returns classification_id for Mexico.
  **
  **  Arguments : IN Parameters
  **              p_classification_name -> Classification Name.
  **  Notes     :
  **********************************************************************/
  FUNCTION  get_classification_id( p_classification_name IN VARCHAR2 )
  RETURN NUMBER;

  /**********************************************************************
  **  Type      : Procedure
  **  Name      : create_ele_tmplt_class_usg
  **  Purpose   : This procedure creates records for
  **              PAY_ELE_TMPLT_CLASS_USAGES table.
  **
  **  Arguments : IN Parameters
  **              p_classification_id    -> Classification ID
  **              p_template_id          -> Template ID
  **              p_display_process_mode -> Display Process Mode
  **              p_display_arrearage    -> Display Arrearage
  **  Notes     :
  **********************************************************************/
  PROCEDURE  create_ele_tmplt_class_usg( p_classification_id    IN NUMBER
                                        ,p_template_id          IN NUMBER
                                        ,p_display_process_mode IN VARCHAR2
                                        ,p_display_arrearage    IN VARCHAR2 );

  /**********************************************************************
  **  Type      : Procedure
  **  Name      : create_template_classification
  **  Purpose   : This procedure is getting called from the template
  **              with Template ID and Classification Type and will
  **              decides how many record to be created for
  **              PAY_ELE_TMPLT_CLASS_USAGES table.
  **
  **  Arguments : IN Parameters
  **              p_template_id          -> Template ID
  **              p_classification_type  -> Display Process Mode
  **  Notes     :
  **********************************************************************/
  PROCEDURE  create_template_classification( p_template_id         IN NUMBER
                                            ,p_classification_type IN VARCHAR2);

  /**********************************************************************
  **  Type      : Function
  **  Name      : get_default_imp_date
  **  Purpose   : This function is returning Implementation Date.
  **              Using in Social Security Archiver.
  **
  **  Arguments :
  **  Notes     :
  **********************************************************************/
  FUNCTION get_default_imp_date RETURN VARCHAR2;

  /**********************************************************************
  **  Type      : Function
  **  Name      : get_legi_param_val
  **  Purpose   : This function gets Paramter Value from
  **              legislation_parameters column of pay_payroll_actions
  **              WHENEVER TWO PARAMETERS ARE SEPARATED BY A PIPE (|)
  **
  **  WARNING   : IF THERE IS A SPACE IN THE VALUE
  **              THEN DONOT USE THIS FUNCTION
  **
  **  Arguments :
  **  Notes     :
  **********************************************************************/
  FUNCTION get_legi_param_val(name           IN VARCHAR2,
                              parameter_list IN VARCHAR2) RETURN VARCHAR2;

  /*************************************************************************
  **  Type      : Function
  **  Name      : get_legi_param_val
  **  Purpose   : This is an overloaded function that gets paramter Value
  **              from legislation_parameters column of pay_payroll_actions
  **              WHENEVER TWO PARAMETERS ARE SEPARATED BY EITHER A PIPE (|)
  **              OR A SPACE.
  **
  **  Arguments :
  **  Notes     :
  **********************************************************************/
  FUNCTION get_legi_param_val(name           IN VARCHAR2,
                              parameter_list IN VARCHAR2,
                              tag            IN VARCHAR2) RETURN VARCHAR2;

  /**********************************************************************
  **  Type      : Function
  **  Name      : get_parameter
  **  Purpose   : This function gets Paramter Value from
  **              legislation_parameters column of pay_payroll_actions
  **              WHENEVER TWO PARAMETERS ARE SEPARATED BY A SPACE
  **
  **  WARNING   : IF THERE IS A PIPE (OTHER THAN A SPACE)IN THE VALUE
  **              THEN DONOT USE THIS FUNCTION
  **
  **  Arguments :
  **  Notes     :
  **********************************************************************/
  FUNCTION get_parameter(name           IN VARCHAR2,
                         parameter_list IN VARCHAR2) RETURN VARCHAR2;

  /**********************************************************************
  **  Type      : Function
  **  Name      : get_process_parameters
  **  Purpose   : Returns Legislative parameters for specified payroll
  **              action
  **********************************************************************/
  FUNCTION get_process_parameters(p_cntx_payroll_action_id  IN NUMBER,
                                  p_parameter_name          IN VARCHAR2)
  RETURN VARCHAR2;

  /**************************************************************************
  **  Name        : GET_MX_ECON_ZONE
  **  Description : This function returns Economy Zone('A', 'B', 'C') for the
  **		  given tax_unit_id
  ***************************************************************************/

  FUNCTION GET_MX_ECON_ZONE
  (
      P_CTX_TAX_UNIT_ID           number,
      P_CTX_DATE_EARNED		DATE
  ) RETURN varchar2;

  /**************************************************************************
  **  Name        : GET_MIN_WAGE
  **  Description : This function returns Minimum Wage for the Economy Zone
  ***************************************************************************/

  FUNCTION GET_MIN_WAGE
  (
      P_CTX_DATE_EARNED		DATE,
      P_TAX_BASIS			varchar2,
      P_ECON_ZONE			varchar2

   ) RETURN varchar2;


END pay_mx_utility;

/
