--------------------------------------------------------
--  DDL for Package PAY_US_PAYROLL_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_PAYROLL_UTILS" AUTHID CURRENT_USER AS
/* $Header: pyusutil.pkh 120.0.12010000.2 2009/03/06 18:06:16 tclewis ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_payroll_utils

    Description : The package has all the common packages used in
                  US Payroll.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    24-APR-2003 ahanda     115.0            Created.
    30-MAY-2003 vinaraya   115.1  2973119   Added code for city tax information
                                            in populate_jit_information and
					    check for county and city tax in
					    get_tax_exists.
    05-JUN-2003 vnatari    115.2  2938540   Overloaded function get_tax_exists.
    18-jun-2003 sodhingr   115.3  3011003   Added the cursor c_get_defined_balance_id
    06-AUG-2003 sshetty    115.4            Added a field dcp_limit to record type
                                            fed_tax_info_rec.
    29-AUG-2003 rsethupa   115.5  2527077   Added functions formated_header_string
                                            and formated_data_string which will be
                                            used by reports in HTML and CSV formats.
    13-NOV-2003 tclewis    115.6            Added structure for STEIC to state
                                            structure.
    18-MAR-2004 sdahiya    115.7            Added p_legislation_code parameter to
                                            check_balance_status.
    26-APR-2004 ahanda     115.8            Added function get_parameter.
    08-NOV-2004 ahanda     115.9            defaulted p_bold to 'N'
    20-DEC-2004 schauhan   115.10 3892148   Added fucntion ssn_reporting_preferences.
    12-JAN-2005 ahanda     115.11 3980866   Added check for FUTA at state level for
                                            the mentioned bug.
    19-APR-2005 ahanda     115.13           Added a new function get_min_action
                                            to get the min assignment_action_id
                                            for a given business_group, GRE, payroll
                                            and dates.
    06-MAR-2009 tclewis    115.14           Added SDI1_EE_wage_limit to the state
                                            record.
   *****************************************************************************/

  /*****************************************************************************
   Name      : populate_jit_information
   Purpose   : This procedure populates a PL/SQL table with JIT information
   Arguments :
   Notes     :
  *****************************************************************************/
  PROCEDURE populate_jit_information(
                p_effective_date    in date     default sysdate
               ,p_get_federal       in varchar2 default 'N'
               ,p_get_state         in varchar2 default 'N'
               ,p_get_county        in varchar2 default 'N'
	       ,p_get_city          in varchar2 default 'N'
	       ,p_jurisdiction_code in varchar2 default NULL);

 /********************************************************************
  ** Function : get_tax_exists
  ** Arguments: p_jurisdiction_code
  **            p_tax_type
  ** Returns  : Y/N
  ** Purpose  : This function has 2 parameters as input. The function
  **            gets the effective_date from fnd_sessions. If the date
  **            in fnd_sessions is not found, get the data as of sysdate.
  *********************************************************************/
  FUNCTION get_tax_exists (p_jurisdiction_code in varchar2 default '00-000-0000'
                          ,p_tax_type          in varchar2)
  RETURN varchar2;

 /********************************************************************
  ** Function : get_tax_exists
  ** Arguments: p_jurisdiction_code
  **            p_tax_type
  **            p_effective_date
  ** Returns  : Y/N
  ** Purpose  : This function has 3 parameters as input. The function
  **            gets the data as of the effective_date passed to it.
  *********************************************************************/
  FUNCTION get_tax_exists (p_jurisdiction_code in varchar2 default '00-000-0000'
                          ,p_tax_type          in varchar2
                          ,p_effective_date    in date)
  RETURN varchar2;

  /********************************************************************
  ** Global PL/SQL Tables
  *********************************************************************/
  TYPE fed_tax_info_rec IS RECORD
     (futa_wage     NUMBER
     ,futa_rate     NUMBER
     ,ss_ee_wage    NUMBER
     ,ss_ee_rate    NUMBER
     ,ss_er_wage    NUMBER
     ,ss_er_rate    NUMBER
     ,med_ee_rate   NUMBER
     ,med_er_rate   NUMBER
     ,p401_limit    NUMBER
     ,p403_limit    NUMBER
     ,p457_limit    NUMBER
     ,catchup_401k  NUMBER
     ,catchup_403b  NUMBER
     ,catchup_457   NUMBER
     ,dcp_limit     NUMBER
     );

  TYPE fed_tax_info_table IS TABLE OF
      fed_tax_info_rec
  INDEX BY BINARY_INTEGER;

  TYPE state_tax_info_rec IS RECORD
     ( sit_exists    varchar2(1)
      ,sui_ee_limit  NUMBER
      ,sui_er_limit  NUMBER
      ,sdi_ee_limit  NUMBER
      ,sdi_er_limit  NUMBER
      ,steic_exists  VARCHAR2(1)
      ,futa_rate     NUMBER
      ,sdi1_ee_limit  NUMBER
     );

  TYPE state_tax_info_table IS TABLE OF
      state_tax_info_rec
  INDEX BY BINARY_INTEGER;

  TYPE county_tax_info_rec IS RECORD
     ( jurisdiction_code    varchar2(11)
      ,cnty_tax_exists      varchar2(1)
      ,cnty_head_tax_exists varchar2(1)
      ,cnty_sd_tax_exists   varchar2(1)
     );

  TYPE county_tax_info_table IS TABLE OF
      county_tax_info_rec
  INDEX BY BINARY_INTEGER;

  /************************  Bug 2971119 Changes Start   ***********************
  ***** Added code to populate city information into pl/sql table **************
  *****************************************************************************/

  TYPE city_tax_info_rec IS RECORD
       ( jurisdiction_code    varchar2(11)
       , city_tax_exists      varchar2(1)
       , city_head_tax_exists varchar2(1)
       , city_sd_tax_exists   varchar2(1)
       );

  TYPE city_tax_info_table IS TABLE OF
       city_tax_info_rec
  INDEX BY BINARY_INTEGER;

  ltr_city_tax_info     city_tax_info_table;

  /**********************   Bug 2973119 Changes End ***************************/

  ltr_fed_tax_info      fed_tax_info_table;
  ltr_state_tax_info    state_tax_info_table;
  ltr_county_tax_info   county_tax_info_table;

  /*****************************************************************************
   Name      : check_balance_status
   Purpose   : Function should be used to identify whether the balances relevant
               to partcular attribute are valid for use of BRA.
   Arguments : 1. Start Date
               2. Business Group Id
               3. Atttribute Name
               4. Legislation Code
   Return    : 'Y' for valid status and 'N' for invalid status of balance
   Notes     : It will used by group level reports (940,941,GRE Totals etc) to find
               if all the balances related to a report are valid or not
  *****************************************************************************/
  FUNCTION check_balance_status(
              p_start_date        in date,
              p_business_group_id in hr_organization_units.organization_id%type,
              p_attribute_name    in varchar2,
              p_legislation_code  in varchar2 default 'US')
  RETURN VARCHAR2;

  /*****************************************************************************
   Name      : c_get_defined_balance_id
   Purpose   : This is the cursor to get the defined balance id
	       and user entity name for given balance name and the dimension in
	       a business group. This is mainly used by year end archiver.
   Arguments : 1. Balance Dimension
	       3. Business Group Id
   Return    : Balance name, defined balance id and user entity name
   Notes     : It will used by group level reports (940,941,GRE Totals etc) to find
               if all the balances related to a report are valid or not
  *****************************************************************************/
  CURSOR c_get_defined_balance_id (
              cp_balance_name  in varchar2,
               cp_balance_dimension in varchar2,
               cp_business_group_id in number ) is
        select pdb.defined_balance_id,fue.user_entity_name
         from ff_user_entities fue,
              pay_defined_balances pdb,
              pay_balance_dimensions pbd,
              pay_balance_types pbt
        where pbt.balance_name in  (cp_balance_name)
          and pbd.database_item_suffix= cp_balance_dimension
          and pbt.balance_type_id = pdb.balance_type_id
          and pbd.balance_dimension_id = pdb.balance_dimension_id
          and fue.creator_id = pdb.defined_balance_id
          and fue.creator_type = 'B'
          and ((pbt.legislation_code = 'US' and
                pbt.business_group_id is null)
            or (pbt.legislation_code is null and
                pbt.business_group_id = cp_business_group_id))
          and ((pbd.legislation_code ='US' and
                pbd.business_group_id is null)
            or (pbd.legislation_code is null and
                pbd.business_group_id = cp_business_group_id)) ;

 /************************************************************
  ** Function : formated_header_string
  ** Arguments: p_input_string
  **            p_output_file_type
  ** Returns  : input string with the HTML Header tags
  ** Purpose  : This Function will be used by reports that are
  **            displaying in HTML format. It returns the input
  **            string with the HTML Header tags
  ************************************************************/
  FUNCTION formated_header_string
             (p_input_string     in VARCHAR2
             ,p_output_file_type in VARCHAR2
             )
  RETURN VARCHAR2;

 /***********************************************************
  ** Function : formated_data_string
  ** Arguments: p_input_string
  **            p_output_file_type
  **            p_bold
  ** Returns  : the formated input string based on the Output
  **            format. If the format is CSV then the values are
  **            returned seperated by comma (,). If the format is
  **            HTML then the returned string has the HTML tags.
  **            The parameter p_bold only works for the HTML
  **            format.
  ** Purpose  : This Function will be used by reports that are
  **            displaying in HTML/CSV format.
  ************************************************************/
  FUNCTION formated_data_string
             (p_input_string     in VARCHAR2
             ,p_output_file_type in VARCHAR2
             ,p_bold             in VARCHAR2 default 'N'
             )
  RETURN VARCHAR2;

  /**************************************************************************
  ** Function : get_parameter
  ** Arguments: p_param_name
  **            p_parameter_list
  ** Returns  : the the value for the parameter p_param_name
  **            from the p_parameter_list
  **            This function is called to get the value entered
  **            by the user which is stored in legislative
  **            parameters. Both the name and list is passed to
  **            the function.
  **************************************************************************/
  FUNCTION get_parameter(p_parameter_name in varchar2,
                         p_parameter_list in varchar2)
  RETURN VARCHAR2;


  /**************************************************************************
  ** Function : ssn_reporting_preferences
  ** Arguments: p_loc_id location Id,
  **            p_org_id organization Id,
  **            p_bg_id  business group Id
  ** Returns  : The value for the parameter lv_display_ssn
  **
  **            This function is called is called from Check Writer,
  **            Deposit Advice and Archive Check WRiter and Deposit
  **            Advice Reports.It is supposed to return if we want to
  **            show SSN on the output of these reoprts or not.
  **            The Function checks the value set by the user at location
  **            then organization and finally at BG level.It was added
  **            for Bug 3892148.
  **************************************************************************/
  FUNCTION ssn_reporting_preferences(p_loc_id in number,
                                     p_org_id in number,
                                     p_bg_id  in number)
  RETURN VARCHAR2;


  /**************************************************************************
  **    Function: get_min_actions
  **    Argument:
  ** Description:
  **************************************************************************/
  FUNCTION get_min_action(p_business_group_id in number
                         ,p_start_date        in date
                         ,p_end_date          in date
                         ,p_tax_unit_id       in number default null
                         ,p_payroll_id        in number default null)
  RETURN NUMBER;

end pay_us_payroll_utils;

/
