--------------------------------------------------------
--  DDL for Package Body PAY_US_PAYROLL_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_PAYROLL_UTILS" AS
/* $Header: pyusutil.pkb 120.1.12010000.2 2009/03/06 18:08:06 tclewis ship $ */
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
    ----------- ---------- ------  -------  ------------------------------------
    24-APR-2003 ahanda     115.0            Created.
    30-MAY-2003 vnatari    115.1   2938540  modified check_balance_status to avoid
                                            reports erroring out
    30-MAY-2003 vinaraya   115.2   2973119  Added code for city tax information
                                            in populate_jit_information and
					    check for county and city tax in
					    get_tax_exists.
    05-JUN-2003 vinaraya   115.3   2973119  Changed the code as per review comments
                                            for the bug.Modified the return
					    statments in get_tax_exists function.
    05-JUN-2003 vnatari    115.4   2938540  overloaded function get_tax_exists and
    					    added code for WC
    05-JUN-2003 ahanda     115.5   3012587  Changed code for WC.
    23-JUN-2003 djoshi     115.6            Changed the code in
                                            check_balance_status
                                            to make sure that we compare bg
                                            for pba also.
    07-AUG-2003 sshetty    115.8            Value for DCP limit is derived.
    21-AUG-2003 meshah     115.9            removed the call to
                                            pay_emp_action_arch.set_error_message
    21-AUG-2003 meshah     115.10           Uncommented commit and exit.
    29-AUG-2003 rsethupa   115.11  2527077  Added functions formated_header_string
                                            and formated_data_string that will be
                                            used by reports displaying in HTML and
                                            CSV formats.
    29-AUG-2003 rsethupa   115.12  2527077  Added local variables and comments.
    11-SEP-2003 meshah     115.13  3136815  changed check_balance_status
                                            function. created two cursors
                                            c_get_valid_count and
                                            c_get_attribute_count. A balance is
                                            valid only if the counts returned
                                            from both the cursors are same.
    13-NOV-2003 tclewis    115.14           Added code to STEIC.
    18-DEC-2003 saurgupt   115.17  3312482  Remove the call to
                                            pay_core_utils.push_message and
                                            pay_core_utils.push_tokens
    29-DEC-2003 saurgupt   115.18  3340952  Calls to pay_core_utils.push_message
                                            and pay_core_utils.push_tokens are
                                            added again to show warning messages
                                            in the log file of Unacceptable Tax
                                            Balances report.
    06-JAN-2004 meshah     115.19  3349198  Now when getting city taxes we check
                                            if there is a user defined city. If
                                            it is then we return N.
                                            Get_tax_exists has been changed for
                                            this.
    13-JAN-2004 meshah     115.21  3349198  For user defined cities now checking
                                            for just the first char instead of
                                            the whole string.
    30-JAN-2004 rmonge     115.22  3358113  Modified cursor 'c_get_states_jit'
                                            to use a decode on
                                            sdi_ee_wage_limit. This will
                                            return STA_INFORMATION1 instead
                                            in case sdi_ee_wage_limit is null
                                            or 0. STA_INFORMATION1 stores
                                            the sdi_ee_wage_limit per week.
    18-MAR-2004 sdahiya    115.23  3258868  Modified check_balance_status, now
                                            truncating the date passed to year.

                                   3179050  Modified function formated_data_string
                                            to display nothing for NULL values
                                            for HTML format.

                                            Both these changes were already done in
                                            ver 115.14 and 115.15 respectively. But
                                            ver 115.16 was modified over 115.13. So
                                            doing required changes again.

                                            Added p_legislation_code parameter to
                                            check_balance_status to allow CA package
                                            to act as wrapper and call this package
                                            for actual results. This parameter is
                                            defaulted to 'US' to avoid breaking of
                                            existing calls.
    26-APR-2004 ahanda     115.24           Added function get_parameter.
    20-SEP-2004 tmehra     115.25           Changed the limit calculation for
                                            403b Catchup and 457 Catchup Limits.
    20-DEC-2004 schauhan   115.26 3892148   Added function ssn_reporting_preferences
                                            for Check Writer and Deposit Advice Reports.
    25-DEC-2004 schauhan   115.27 3892148   Made changes to function
                                            ssn_reporting_preferences.
    12-JAN-2005 ahanda     115.28 3980866   Added check for FUTA at state level for
                                            the mentioned bug.
    13-JAN-2005 schauhan    115.29 3892148  Added comments to the funtion
                                            ssn_reporting_preferences
    28-jan-2005 djoshi      115.30          Check_balance_status should return 'N' if
                                            the no balance is associated with attribute
                                            currently we dont have any zero check
    19-APR-2005 ahanda      115.31          Added a new function get_min_action
                                            to get the min assignment_action_id
                                            for a given business_group, GRE, payroll
                                            and dates.
    21-APR-2005 schauhan    115.32          Bug 3969061. Added a check for 'FUTA ' to
                                            get_tax_exists in the state section.
    25-MAY-2005 ahanda      115.33          Changed function get_parameter to check if
                                            exact param exists i.e. ' ' || name || '='
    24-AUG-2005 sackumar    115.34 4518409  Changed function get_parameter to check if
                                            exact param exists i.e. ' ' || name || '='
					    except for the first token in the
					    legislative_parameters field.
	03-MAR-2009 tclewis     115.35           Added SDI1 EE to populate_jit_information
	                                         and get_tax_exists.
  *****************************************************************************/

  /*****************************************************************************
  ** Package Local Variables
  *****************************************************************************/
   gv_package        VARCHAR2(100) := 'pay_us_payroll_utils';
   gc_csv_delimiter       VARCHAR2(1) := ',';
   gc_csv_data_delimiter  VARCHAR2(1) := '"';

   gv_html_start_data     VARCHAR2(5) := '<td>'  ;
   gv_html_end_data       VARCHAR2(5) := '</td>' ;


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
	       ,p_jurisdiction_code in varchar2 default NULL) is

    lv_state_code             VARCHAR2(2);
    lv_sit_exists             VARCHAR2(1);
    ln_sdi_ee_limit           NUMBER;
    ln_sdi1_ee_limit           NUMBER;
    ln_sdi_er_limit           NUMBER;
    ln_sui_ee_limit           NUMBER;
    ln_sui_er_limit           NUMBER;
    lv_steic_exists           VARCHAR2(1);
    ln_state_futa_rate        NUMBER;

    lv_jurisdiction_code      VARCHAR2(11);
    lv_county_tax_exists      VARCHAR2(1);
    lv_county_sd_tax_exists   VARCHAR2(1);
    lv_county_head_tax_exists VARCHAR2(1);

    lv_temp_state_code        VARCHAR2(3);
    lv_county_code            VARCHAR2(4);
    lv_city_code              VARCHAR2(5);
    lv_temp_code              VARCHAR2(11);
    ln_index                  NUMBER;

    lv_city_jurisdiction_code VARCHAR2(11);
    lv_city_tax_exists        VARCHAR2(1);
    lv_city_head_tax_exists   VARCHAR2(1);
    lv_city_sd_tax_exists     VARCHAR2(1);

    ln_fed_count              NUMBER := 0;
    ln_state_count            NUMBER := 0;
    ln_county_count           NUMBER := 0;
    ln_city_count             NUMBER := 0;
    ln_schdist_count          NUMBER := 0;

    ln_futa_wage              NUMBER;
    ln_futa_rate              NUMBER;
    ln_ss_ee_wage             NUMBER;
    ln_ss_ee_rate             NUMBER;
    ln_ss_er_wage             NUMBER;
    ln_ss_er_rate             NUMBER;
    ln_medi_ee_rate           NUMBER;
    ln_medi_er_rate           NUMBER;
    ln_401k                   NUMBER;
    ln_403b                   NUMBER;
    ln_457                    NUMBER;
    ln_401k_catchup           NUMBER;
    ln_403_catchup            NUMBER;
    ln_457_catchup            NUMBER;
    ln_dcp_limit              NUMBER;

    lv_error_message          VARCHAR2(500);
    lv_procedure_name         VARCHAR2(100) := '.populate_jit_information';
    ln_step                   NUMBER;

    cursor c_get_federal_jit (cp_effective_date    in date
                             ,cp_fed_info_category in varchar2) is
      select futa_wage_limit, futa_rate,
             ss_ee_wage_limit, ss_ee_rate,
             ss_er_wage_limit, ss_er_rate,
             medi_ee_rate, medi_er_rate,
             fed_information1, fed_information2
       from pay_us_federal_tax_info_f
      where cp_effective_date between effective_start_date
                                  and effective_end_date
        and fed_information_category = cp_fed_info_category;

    /* Rosie monge chaning the cursor to fix bug 3358113 */
    /* Added decode statement to sdi_ee_wage_limit */
    cursor c_get_states_jit (cp_effective_date in date) is
      select state_code,
             sit_exists,
             sui_ee_wage_limit,
             sui_er_wage_limit,
             decode(sdi_ee_wage_limit,
                    NULL, STA_INFORMATION1,
                    0, STA_INFORMATION1,
                    sdi_ee_wage_limit) sdi_ee_wage_limit,
             sdi_er_wage_limit,
             nvl(sta_information17,'N'),
             sta_information19 futa_rate,
             sta_information21 sdi1_ee_wage_limit
        from pay_us_state_tax_info_f
      where cp_effective_date between effective_start_date
                                  and effective_end_date
        and sta_information_category = 'State tax limit rate info'
      order by 1 ;

    cursor c_get_county_jit (cp_effective_date in date) is
      select jurisdiction_code,
             county_tax,
             head_tax,
             school_tax
        from pay_us_county_tax_info_f
      where cp_effective_date between effective_start_date
                                  and effective_end_date
        and cnty_information_category = 'County tax status info'
      order by 1 ;

  /*******************************************************************
  **    Cursor to populate ltr_city_info_tax pl/sql table           **
  **    Bug Number: 2973119   Changes start                         **
  ********************************************************************/

    cursor c_get_city_jit ( cp_effective_date in date
                          , cp_jurisdiction_code in varchar2) is
      select jurisdiction_code,
             city_tax,
             head_tax,
             school_tax
        from pay_us_city_tax_info_f
      where cp_effective_date between effective_start_date
                                  and effective_end_date
        and jurisdiction_code = cp_jurisdiction_code
        and city_information_category = 'City tax status info';

   /**********   Bug Number:2973119  End    ***************************/

  BEGIN
     ln_step := 1;
     hr_utility.set_location(gv_package || lv_procedure_name, 1);
     /***************************************************************
     ** Build a PL/SQL table which has federal tax info
     ***************************************************************/
     if p_get_federal = 'Y' and
        pay_us_payroll_utils.ltr_fed_tax_info.count < 1 then
        ln_step := 5;
        open c_get_federal_jit (p_effective_date, '401K LIMITS');
        fetch c_get_federal_jit into ln_futa_wage, ln_futa_rate,
                                     ln_ss_ee_wage, ln_ss_ee_rate,
                                     ln_ss_er_wage, ln_ss_er_rate,
                                     ln_medi_ee_rate, ln_medi_er_rate,
                                     ln_401k, ln_401k_catchup;
        close c_get_federal_jit;
        ln_403b := pay_ff_functions.get_pqp_limit(
                       p_effective_date => p_effective_date,
                       p_limit          => 'ELECTIVE_DEFERRAL_LIMIT');
        ln_403_catchup := pay_ff_functions.get_pqp_limit (
                              p_effective_date => p_effective_date,
                              p_limit          => 'GENERAL_CATCHUP_LIMIT');
        ln_457  := pay_ff_functions.get_457_annual_limit(
                       p_effective_date => p_effective_date,
                       p_limit          => '457 LIMIT');
        ln_457_catchup  := pay_ff_functions.get_457_annual_limit(
                               p_effective_date => p_effective_date,
                               p_limit          => '457 ADDITIONAL CATCHUP');
        ln_dcp_limit    := pqp_us_srs_extracts.get_dcp_limit(p_effective_date);

        pay_us_payroll_utils.ltr_fed_tax_info(1).futa_wage    := ln_futa_wage;
        pay_us_payroll_utils.ltr_fed_tax_info(1).futa_rate    := ln_futa_rate;
        pay_us_payroll_utils.ltr_fed_tax_info(1).ss_ee_wage   := ln_ss_ee_wage;
        pay_us_payroll_utils.ltr_fed_tax_info(1).ss_ee_rate   := ln_ss_ee_rate;
        pay_us_payroll_utils.ltr_fed_tax_info(1).ss_er_wage   := ln_ss_er_wage;
        pay_us_payroll_utils.ltr_fed_tax_info(1).ss_er_rate   := ln_ss_er_rate;
        pay_us_payroll_utils.ltr_fed_tax_info(1).med_ee_rate  := ln_medi_ee_rate;
        pay_us_payroll_utils.ltr_fed_tax_info(1).med_er_rate  := ln_medi_er_rate;
        pay_us_payroll_utils.ltr_fed_tax_info(1).p401_limit   := ln_401k;
        pay_us_payroll_utils.ltr_fed_tax_info(1).p403_limit   := ln_403b;
        pay_us_payroll_utils.ltr_fed_tax_info(1).p457_limit   := ln_457;
        pay_us_payroll_utils.ltr_fed_tax_info(1).catchup_401k := ln_401k_catchup;
        pay_us_payroll_utils.ltr_fed_tax_info(1).catchup_403b := ln_403_catchup;
        pay_us_payroll_utils.ltr_fed_tax_info(1).catchup_457  := ln_457_catchup;
        pay_us_payroll_utils.ltr_fed_tax_info(1).dcp_limit    := ln_dcp_limit;
     end if;

     /***************************************************************
     ** Build a PL/SQL table which has state tax info for all states
     ***************************************************************/
     hr_utility.set_location(gv_package || lv_procedure_name, 300);
     ln_step := 10;
     hr_utility.set_location(p_get_state,310);
     hr_utility.set_location(to_char( pay_us_payroll_utils.ltr_state_tax_info.count),320);
     if p_get_state = 'Y' and
        pay_us_payroll_utils.ltr_state_tax_info.count < 1 then
        open c_get_states_jit(p_effective_date);
        loop
           fetch c_get_states_jit into lv_state_code, lv_sit_exists,
                                       ln_sui_ee_limit, ln_sui_er_limit ,
                                       ln_sdi_ee_limit, ln_sdi_er_limit,
                                       lv_steic_exists, ln_state_futa_rate,
									   ln_sdi1_ee_limit;
           if c_get_states_jit%notfound then
              hr_utility.set_location(gv_package || lv_procedure_name, 310);
              exit;
           end if;
           hr_utility.set_location(gv_package || lv_procedure_name, 320);
           hr_utility.trace('lv_state_code = ' || lv_state_code);
           hr_utility.trace('lv_sit_exists = ' || lv_sit_exists);
           hr_utility.trace('ln_sui_ee_limit  = ' || ln_sui_ee_limit);
           hr_utility.trace('ln_sui_er_limit  = ' || ln_sui_er_limit);
           hr_utility.trace('ln_sdi_ee_limit  = ' || ln_sdi_ee_limit);
           hr_utility.trace('ln_sdi1_ee_limit  = ' || ln_sdi1_ee_limit);
           hr_utility.trace('ln_sdi_er_limit  = ' || ln_sdi_er_limit);
           hr_utility.trace('lv_steic_exists = '  || lv_steic_exists);
           hr_utility.trace('ln_state_futa_rate= '|| ln_state_futa_rate);

           pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).sit_exists
                := lv_sit_exists;
           pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).sui_ee_limit
                := ln_sui_ee_limit;
           pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).sui_er_limit
               := ln_sui_er_limit;
           pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).sdi_ee_limit
               := ln_sdi_ee_limit;
           pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).sdi_er_limit
               := ln_sdi_er_limit;
           pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).steic_exists
               := lv_steic_exists;
           pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).futa_rate
               := ln_state_futa_rate;
           pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).sdi1_ee_limit
               := ln_sdi1_ee_limit;

        end loop;
        close c_get_states_jit;
     end if;
     hr_utility.set_location(gv_package || lv_procedure_name, 350);

     ln_step := 55;
     if p_get_county = 'Y' and
        pay_us_payroll_utils.ltr_county_tax_info.count < 1 then
        open c_get_county_jit(p_effective_date);
        loop
           fetch c_get_county_jit into lv_jurisdiction_code,
                                       lv_county_tax_exists,
                                       lv_county_head_tax_exists,
                                       lv_county_sd_tax_exists;
           if c_get_county_jit%notfound then
              hr_utility.set_location(gv_package || lv_procedure_name, 360);
              exit;
           end if;
           hr_utility.set_location(gv_package || lv_procedure_name, 370);
           hr_utility.trace('lv_jurisdiction_code = ' || lv_jurisdiction_code);

    /******************   Start       ****************************************************/
	   lv_temp_state_code  := substr(lv_jurisdiction_code,1,2);
           lv_county_code      := substr(lv_jurisdiction_code,4,3);
           lv_temp_code        := lv_temp_state_code||lv_county_code;

           ln_index            := to_number(lv_temp_code);

   /********************* End         ****************************************************/

           pay_us_payroll_utils.ltr_county_tax_info(ln_index).jurisdiction_code
               := lv_jurisdiction_code;
           pay_us_payroll_utils.ltr_county_tax_info(ln_index).cnty_tax_exists
                := lv_county_tax_exists;
           pay_us_payroll_utils.ltr_county_tax_info(ln_index).cnty_head_tax_exists
                := lv_county_head_tax_exists;
           pay_us_payroll_utils.ltr_county_tax_info(ln_index).cnty_sd_tax_exists
                := lv_county_sd_tax_exists;

        end loop;
        close c_get_county_jit;
     end if;

     hr_utility.set_location(gv_package || lv_procedure_name, 400);
     ln_step := 60;

/***********************   Bug Number:2973119 Changes Start *********************/

     ln_step := 65;
     if p_get_city = 'Y' then

	ln_step := 70 ;
        hr_utility.set_location(gv_package || lv_procedure_name, 450);

	lv_temp_state_code  := substr(p_jurisdiction_code,1,2);
        lv_county_code      := substr(p_jurisdiction_code,4,3);
        lv_city_code        := substr(p_jurisdiction_code,8,4);
        lv_temp_code        := lv_temp_state_code||lv_county_code||lv_city_code;
        ln_index            := to_number(lv_temp_code);

	open c_get_city_jit(p_effective_date,p_jurisdiction_code);
        fetch c_get_city_jit into      lv_city_jurisdiction_code,
                                       lv_city_tax_exists,
                                       lv_city_head_tax_exists,
                                       lv_city_sd_tax_exists;
           if c_get_city_jit%notfound then
              hr_utility.set_location(gv_package || lv_procedure_name, 460);
              pay_us_payroll_utils.ltr_city_tax_info(ln_index).jurisdiction_code
                   := p_jurisdiction_code;
              pay_us_payroll_utils.ltr_city_tax_info(ln_index).city_tax_exists
                   := NULL;
              pay_us_payroll_utils.ltr_city_tax_info(ln_index).city_head_tax_exists
                   := NULL;
              pay_us_payroll_utils.ltr_city_tax_info(ln_index).city_sd_tax_exists
                   := NULL;
           else
              hr_utility.set_location(gv_package || lv_procedure_name, 470);
              hr_utility.trace('lv_jurisdiction_code = ' || lv_city_jurisdiction_code);

              pay_us_payroll_utils.ltr_city_tax_info(ln_index).jurisdiction_code
                   := lv_city_jurisdiction_code;
              pay_us_payroll_utils.ltr_city_tax_info(ln_index).city_tax_exists
                   := lv_city_tax_exists;
              pay_us_payroll_utils.ltr_city_tax_info(ln_index).city_head_tax_exists
                   := lv_city_head_tax_exists;
              pay_us_payroll_utils.ltr_city_tax_info(ln_index).city_sd_tax_exists
                   := lv_city_sd_tax_exists;
           end if;

        close c_get_city_jit;
     end if;

     hr_utility.set_location(gv_package || lv_procedure_name, 480);
     ln_step := 75;

/***********************   Bug Number:2973119 Changes End    **********************/

  exception
    when others then
      hr_utility.set_location(gv_package || lv_procedure_name, 500);
      lv_error_message := 'Error at step ' || ln_step ||
                          ' in ' || gv_package || lv_procedure_name;
      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END populate_jit_information;

 /********************************************************************
  ** Function : get_tax_exists
  ** Arguments: p_jurisdiction_code
  **            p_tax_type
  ** Returns  : Y/N
  ** Purpose  : This function has 2 parameters as input. The function
  **            gets the effective_date from fnd_sessions. If the date
  **            in fnd_sessions is not found, get the data as of sysdate.
  *********************************************************************/
  FUNCTION get_tax_exists (p_jurisdiction_code in varchar2
                          ,p_tax_type          in varchar2)
  RETURN varchar2
  IS

    cursor c_sessions is
      select effective_date from fnd_sessions fs
       where session_id = userenv('sessionid');

    ld_effective_date DATE;

  BEGIN
    open c_sessions;
    fetch c_sessions into ld_effective_date;
    if c_sessions%notfound then
       ld_effective_date := sysdate;
    end if;
    close c_sessions;

    return (get_tax_exists (p_jurisdiction_code => p_jurisdiction_code
                           ,p_tax_type          => p_tax_type
                           ,p_effective_date    => ld_effective_date)
           );
  END get_tax_exists;

  /********************************************************************
  ** Function : get_tax_exists
  ** Arguments: p_jurisdiction_code
  **            p_tax_type
  **            p_effective_date
  ** Returns  : Y/N
  ** Purpose  : This function has 3 parameters as input. The function
  **            gets the data as of the effective_date passed to it.
  *********************************************************************/
  FUNCTION get_tax_exists(p_jurisdiction_code in varchar2
                         ,p_tax_type          in varchar2
                         ,p_effective_date    in date )
  RETURN varchar2

  IS

  /***********************   Bug Number:2973119  Start ****************/

   lv_county_code  VARCHAR2(20);
   lv_city_code    VARCHAR2(20);
   lv_temp_code    VARCHAR2(20);
   ln_index_code   NUMBER;

  /***********************   Bug Number:2973119  End ******************/

   lv_state_code   VARCHAR2(20);
   lv_value        VARCHAR2(20);
   lv_return_value VARCHAR2(1);

  BEGIN

      hr_utility.trace('p_jurisdiction_code is : '|| p_jurisdiction_code);
      hr_utility.trace('p_tax_type is : '|| p_tax_type);
      hr_utility.trace('p_effective_date is : '|| p_effective_date);

      lv_state_code := substr(p_jurisdiction_code,1,2);

  /*********************   Bug Number:2973119  Start *****************/

      lv_county_code := substr(p_jurisdiction_code,4,3);
      lv_city_code   := substr(p_jurisdiction_code,8,4);

  /*********************   Bug Number:2973119  End   *****************/

      --federal
      if p_jurisdiction_code = '00-000-0000' then

         if pay_us_payroll_utils.ltr_fed_tax_info.count < 1 then
	    populate_jit_information( p_effective_date => p_effective_date
                                    , p_get_federal    => 'Y');
         end if;

         if p_tax_type = 'FUTA WAGE' then
            lv_value := pay_us_payroll_utils.ltr_fed_tax_info(1).futa_wage;
         elsif p_tax_type = 'FUTA RATE' then
            lv_value := pay_us_payroll_utils.ltr_fed_tax_info(1).futa_rate;
         elsif p_tax_type = 'SS EE' then
            lv_value := pay_us_payroll_utils.ltr_fed_tax_info(1).ss_ee_wage;
         elsif p_tax_type = 'SS EE RATE' then
            lv_value := pay_us_payroll_utils.ltr_fed_tax_info(1).ss_ee_rate;
         elsif p_tax_type = 'SS ER' then
            lv_value := pay_us_payroll_utils.ltr_fed_tax_info(1).ss_er_wage;
         elsif p_tax_type = 'SS ER RATE' then
            lv_value := pay_us_payroll_utils.ltr_fed_tax_info(1).ss_er_rate;
         elsif p_tax_type = 'MED EE RATE' then
            lv_value := pay_us_payroll_utils.ltr_fed_tax_info(1).med_ee_rate;
         elsif p_tax_type = 'MED ER RATE' then
            lv_value := pay_us_payroll_utils.ltr_fed_tax_info(1).med_er_rate;
         elsif p_tax_type = '401K' then
            lv_value := pay_us_payroll_utils.ltr_fed_tax_info(1).p401_limit;
         elsif p_tax_type = '403B' then
            lv_value := pay_us_payroll_utils.ltr_fed_tax_info(1).p403_limit;
         elsif p_tax_type = '457' then
            lv_value := pay_us_payroll_utils.ltr_fed_tax_info(1).p457_limit;
         elsif p_tax_type = '401K CATCHUP' then
            lv_value := pay_us_payroll_utils.ltr_fed_tax_info(1).catchup_401k;
         elsif p_tax_type = '403B CATCHUP' then
            lv_value := pay_us_payroll_utils.ltr_fed_tax_info(1).catchup_403b;
         elsif p_tax_type = '457 CATCHUP' then
            lv_value := pay_us_payroll_utils.ltr_fed_tax_info(1).catchup_457;
         elsif p_tax_type = 'DCP' then
            lv_value := pay_us_payroll_utils.ltr_fed_tax_info(1).dcp_limit;
         end if;

      --state
      elsif lv_state_code <> '00'  and
            lv_county_code = '000' and
            lv_city_code = '0000' then

	 if pay_us_payroll_utils.ltr_state_tax_info.count < 1 then
            populate_jit_information(p_effective_date => p_effective_date
                                    ,p_get_state      => 'Y');
         end if;

         if p_tax_type = 'SUI EE' then
            lv_value := pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).sui_ee_limit;
         elsif p_tax_type = 'SUI ER' then
            lv_value := pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).sui_er_limit;
            hr_utility.set_location(lv_value,230);
         elsif p_tax_type = 'SDI EE' then
            lv_value := pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).sdi_ee_limit;
         elsif p_tax_type = 'SDI1 EE' then
            lv_value := pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).sdi1_ee_limit;
         elsif p_tax_type = 'SDI ER' then
            lv_value := pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).sdi_er_limit;
         elsif p_tax_type = 'SIT EE' then
            lv_value := pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).sit_exists;
         elsif p_tax_type = 'STEIC EE' then
            lv_value := pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).steic_exists;
         elsif p_tax_type = 'FUTA ER' then
            lv_value := pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).futa_rate;
	 elsif p_tax_type = 'FUTA ' then
	    lv_value := 'Y'; -- Bug3969061
         elsif p_tax_type in ('WC EE', 'WC2 EE') then
            begin
              select 'Y' into lv_value from dual
               where exists (
                 select 'x'
                   from pay_wc_funds wcf, pay_us_states uss
                  where uss.state_code = lv_state_code
                    and uss.state_abbrev = wcf.state_code
                    and wcf.business_group_id =
                       nvl(hr_general.get_business_group_id, wcf.business_group_id));
            exception
              when no_data_found then
                lv_value := 'N';
            end;
         end if;

      /*****************   Bug Number:2973119  Start **************************************/

      --county
      elsif lv_state_code <> '00' and
            lv_county_code <> '000' and
            lv_city_code = '0000' then

	 if pay_us_payroll_utils.ltr_county_tax_info.count<1 then
	    populate_jit_information(p_effective_date => p_effective_date
                                    ,p_get_county     => 'Y');
         end if;

	 lv_temp_code  := lv_state_code||lv_county_code;
	 ln_index_code := to_number(lv_temp_code);

	 if pay_us_payroll_utils.ltr_county_tax_info.exists(ln_index_code) then
            lv_value := pay_us_payroll_utils.ltr_county_tax_info(ln_index_code).cnty_tax_exists;
         end if;

      --city
      elsif lv_state_code <> '00' and
            lv_county_code <> '000' and
            lv_city_code <> '0000' then

         if substr(lv_city_code,1,1) = 'U' then
            /* for user defined cities we should return N because they are not
               primary cities and will never have tax */
            lv_value := 'N';
         else
	    if pay_us_payroll_utils.ltr_city_tax_info.count < 1 then
	       populate_jit_information(p_effective_date    => p_effective_date
                                       ,p_get_city          => 'Y'
                                       ,p_jurisdiction_code => p_jurisdiction_code);
            end if;

	    lv_temp_code  := lv_state_code||lv_county_code||lv_city_code;
            hr_utility.trace('lv_temp_code : '|| lv_temp_code);
            hr_utility.trace(' B4 ln_index_code');
	    ln_index_code := to_number(lv_temp_code);
            hr_utility.trace(' A4 ln_index_code');

	    if p_tax_type = 'CITY' then
	       if pay_us_payroll_utils.ltr_city_tax_info.exists(ln_index_code) then

                  hr_utility.trace(' CITY found in PLSQL table');
                  null;
               else
                  hr_utility.trace(' CITY NOT found in PLSQL table');

	          populate_jit_information(p_effective_date    => p_effective_date
		                          ,p_get_city          => 'Y'
					  ,p_jurisdiction_code => p_jurisdiction_code);
               end if;
               lv_value
                  := pay_us_payroll_utils.ltr_city_tax_info(ln_index_code).city_tax_exists;
            end if;

            if p_tax_type = 'HT' then
	      if pay_us_payroll_utils.ltr_city_tax_info.exists(ln_index_code) then
                 hr_utility.trace(' HT found in PLSQL table');
                 null;
              else
                 hr_utility.trace(' HT NOT found in PLSQL table');
	         populate_jit_information(p_effective_date    => p_effective_date
                                         ,p_get_city          => 'Y'
					 ,p_jurisdiction_code => p_jurisdiction_code);
              end if;
              lv_value := pay_us_payroll_utils.ltr_city_tax_info(ln_index_code).city_head_tax_exists;
            end if;

         /*********************   Bug Number:2973119  End   ****************************/

         end if; /* substr(lv_city_code,1,1) = 'U' */

      end if;

      if lv_value = 'Y' then
         lv_return_value := 'Y';
      elsif nvl(lv_value,'0')  = '0' or lv_value = 'N' then
         lv_return_value := 'N';
      elsif nvl(lv_value,'0') <> '0' then
         lv_return_value := 'Y';
      end if;

      return(lv_return_value);
  END get_tax_exists;


  /*****************************************************************************
   Name      : check_balance_status
   Purpose   : Function should be used to identify whether the balances relevant
               to partcular attribute are valid for use of BRA.
   Arguments : 1. Start Date
               2. Business Group Id
               3. Atttribute Name
               4. Legislation Code
   Return    : 'Y' for valid status and 'N' for invalid status of balance
   Notes     : It will used by group level reports (940,941,GRE Totals) to find
               if all the balances related to a report are valid or not
  *****************************************************************************/

  FUNCTION check_balance_status(
              p_start_date        in date,
              p_business_group_id in hr_organization_units.organization_id%type,
              p_attribute_name    in varchar2,
              p_legislation_code  in varchar2 default 'US')
  RETURN VARCHAR2
  IS

    /*************************************************************
    ** Cursor to check if the attribute_name passed as parameter
    ** exists or not.
    **************************************************************/
    CURSOR c_attribute_exists(
            c_attribute_name in pay_bal_attribute_definitions.attribute_name%type)
    is
      select 1
        from pay_bal_attribute_definitions
       where attribute_name     = c_attribute_name
         and legislation_code   = p_legislation_code;

    CURSOR c_get_valid_count(cp_start_date           in date,
                             cp_business_group_id    in per_business_groups.business_group_id%type,
                             cp_attribute_name       in varchar2) IS
              select /*+ ORDERED */ count(*)
                from pay_bal_attribute_definitions pbad,
                     pay_balance_attributes        pba,
                     pay_balance_validation        pbv
               where pbad.attribute_name     = cp_attribute_name
                 and pbad.attribute_id       = pba.attribute_id
                 and (pba.business_group_id = cp_business_group_id
                      OR
                      pba.legislation_code = p_legislation_code)
                 and pba.defined_balance_id  = pbv.defined_balance_id
                 and pbv.business_group_id = cp_business_group_id
                 and NVL(pbv.balance_load_date, cp_start_date) <= cp_start_date
                 and nvl(pbv.run_balance_status, 'I') = 'V';

    CURSOR c_get_attribute_count(
                cp_business_group_id    in per_business_groups.business_group_id%type,
                cp_attribute_name       in varchar2) IS

              select count(*)
                from pay_bal_attribute_definitions pbad,
                     pay_balance_attributes        pba
               where pbad.attribute_name     = cp_attribute_name
                 and pbad.attribute_id       = pba.attribute_id
                 and (pba.business_group_id = cp_business_group_id
                      OR
                      pba.legislation_code = p_legislation_code );

     ln_attribute_exists NUMBER(1);
     ln_valid_bal_exists NUMBER(1);
     lv_return_status    VARCHAR2(1) := 'N';
     lv_package_stage    VARCHAR2(50) := 'pay_us_payroll_utils.check_balance_status';

     l_attribute_count   number;
     l_valid_count       number;
     l_trunc_date        date; /* Bug 3258868 */

  BEGIN
     hr_utility.trace('Start of Procedure '||lv_package_stage);
     hr_utility.set_location(lv_package_stage,10);

     l_trunc_date := trunc(p_start_date,'Y'); -- Bug 3258868

     -- Validate if the attribute passed as parameter exists
     open c_attribute_exists(p_attribute_name);
     fetch c_attribute_exists INTO ln_attribute_exists;
     if c_attribute_exists%notfound then
        hr_utility.set_location(lv_package_stage,20);
        lv_return_status := 'N';
        hr_utility.trace('Invalid Attribute Name');
        raise_application_error(-20101, 'Error in pay_us_.check_balance_status');
     end if;
     close c_attribute_exists ;

     hr_utility.set_location(lv_package_stage,30);

     open c_get_valid_count(l_trunc_date,  -- Bug 3258868
                            p_business_group_id,
                            p_attribute_name );
     fetch c_get_valid_count into l_valid_count;
     close c_get_valid_count;

     hr_utility.trace('Valid Count for '||p_attribute_name||' is '||to_char(l_valid_count));

     /* Do following check only if the attribute count >  zero */

     IF l_valid_count > 0 THEN

       open c_get_attribute_count(
                            p_business_group_id,
                            p_attribute_name );
       fetch c_get_attribute_count into l_attribute_count;
       close c_get_attribute_count;

       hr_utility.trace('Attribute Count for '||p_attribute_name||' is '||to_char(l_attribute_count));

       if l_valid_count = l_attribute_count then

          hr_utility.set_location(lv_package_stage,40);
          lv_return_status := 'Y';
       else

        -- Bug 3312482 Push statements are deleted.
          hr_utility.set_location(lv_package_stage,50);

          -- Bug 3340952 Push statements are added again.
          pay_core_utils.push_message(801,'PAY_EXCEPTION','A');
          pay_core_utils.push_token('description','Warning Invalid Balance Status . ,In Attribute -> ' ||p_attribute_name);

          hr_utility.trace('Balance Status is Invalid for Attribute -> ' ||p_attribute_name);

          lv_return_status := 'N';
       end if;
     end if; /*   IF l_valid_count > 0 */
     hr_utility.trace('End of Procedure ' || lv_package_stage);
     return(lv_return_status);


  EXCEPTION
    WHEN others THEN
      hr_utility.set_location(lv_package_stage,60);
      hr_utility.trace('Invalid Attribute Name');
      raise_application_error(-20101, 'Error in pay_us_.check_balance_status');
      raise;
  END check_balance_status;

/************************************************************
  ** Function : formated_header_string
  ** Arguments: p_input_string
  **            p_output_file_type
  ** Returns  : input string with the HTML Header tags
  ** Purpose  : This Function will be used by the reports that are
  **            displaying in HTML format. It returns the input
  **            string with the HTML Header tags
  ************************************************************/

  FUNCTION formated_header_string
             (p_input_string     in VARCHAR2
             ,p_output_file_type in VARCHAR2
             )
  RETURN VARCHAR2
  IS

    lv_format          VARCHAR2(1000);

  BEGIN
    hr_utility.set_location(gv_package || '.formated_header_string', 10);
    IF p_output_file_type = 'CSV' THEN
       hr_utility.set_location(gv_package || '.formated_header_string', 20);
       lv_format := p_input_string;
    ELSIF p_output_file_type = 'HTML' THEN
       hr_utility.set_location(gv_package || '.formated_header_string', 30);
       lv_format := '<HTML><HEAD> <CENTER> <H1> <B>' || p_input_string ||
                             '</B></H1></CENTER></HEAD>';
    END IF;

    hr_utility.set_location(gv_package || '.formated_header_string', 40);
    return lv_format;

  END formated_header_string;


  /************************************************************
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
             ,p_bold             in VARCHAR2
             )
  RETURN VARCHAR2
  IS

    lv_format          VARCHAR2(1000);
    lv_bold           VARCHAR2(10);
  BEGIN
    lv_bold := nvl(p_bold,'N');
    hr_utility.set_location(gv_package || '.formated_data_string', 10);
    IF p_output_file_type = 'CSV' THEN
       hr_utility.set_location(gv_package || '.formated_data_string', 20);
       lv_format := gc_csv_data_delimiter || p_input_string ||
                           gc_csv_data_delimiter || gc_csv_delimiter;
    ELSIF p_output_file_type = 'HTML' THEN
       IF p_input_string is null THEN
          hr_utility.set_location(gv_package || '.formated_data_string', 30);
          lv_format := gv_html_start_data || '&nbsp;' || gv_html_end_data;  -- Bug 3179050
       ELSE
          IF lv_bold = 'Y' THEN
             hr_utility.set_location(gv_package || '.formated_data_string', 40);
             lv_format := gv_html_start_data || '<b> ' || p_input_string
                             || '</b>' || gv_html_end_data;
          ELSE
             hr_utility.set_location(gv_package || '.formated_data_string', 50);
             lv_format := gv_html_start_data || p_input_string || gv_html_end_data;
          END IF;
       END IF;
    END IF;

    hr_utility.set_location(gv_package || '.formated_data_string', 60);
    return lv_format;

  END formated_data_string;


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
  RETURN VARCHAR2
  IS
     ln_start_ptr   NUMBER;
     ln_end_ptr     NUMBER;

     lv_token_value pay_payroll_actions.legislative_parameters%type;
     lv_par_value   pay_payroll_actions.legislative_parameters%type;
  BEGIN

--4518409     lv_token_value := ' ' || p_parameter_name||'=';

     if substr(p_parameter_list,1,length(p_parameter_name)) <> p_parameter_name then
        lv_token_value := ' ' || p_parameter_name||'=';
     else
        lv_token_value := p_parameter_name||'=';
     end if;

     ln_start_ptr := instr(p_parameter_list, lv_token_value) + length(lv_token_value);
     ln_end_ptr := instr(p_parameter_list, ' ', ln_start_ptr);

     /* if there is no spaces use then length of the string */
     if ln_end_ptr = 0 then
        ln_end_ptr := length(p_parameter_list)+1;
     end if;

     /* Did we find the token */
     if instr(p_parameter_list, lv_token_value) = 0 then
        lv_par_value := NULL;
     else
        lv_par_value := substr(p_parameter_list, ln_start_ptr, ln_end_ptr - ln_start_ptr);
     end if;

     return lv_par_value;

  END get_parameter;




  /**************************************************************************
  ** Function : ssn_reporting_preferences
  ** Arguments: p_loc_id location Id,
                p_org_id organization Id,
                p_bg_id  business group Id
  ** Returns  : The value for the parameter lv_display_ssn
  **            This function is called is called from Check Writer,Deposit Advice
  **            and Archive Check WRiter and Deposit Advice Reports.It is supposed to
  **            return if we want to show SSN on the output of these reoprts or not.
  **            The Function checks the value set by the user at location then organization and
  **            finally at BG level.It was added for Bug 3892148.
  **************************************************************************/
  FUNCTION ssn_reporting_preferences(p_loc_id in number,
                                     p_org_id in number,
                                     p_bg_id  in number)
  RETURN VARCHAR2
  IS
    lv_display_ssn varchar2(100);

    cursor c_loc_pref(cp_location_id in number) is
      select lei_information1
        from hr_location_extra_info hlei
       where hlei.location_id = cp_location_id
         and  information_type = 'US_LOC_REP_PREFERENCES';

    cursor c_org_pref(cp_organization_id in number
                     ,cp_org_information_context in varchar2) is
      select org_information1
        from hr_organization_information hoi
       where organization_id =  cp_organization_id
         and org_information_context = cp_org_information_context;

  BEGIN
    open c_loc_pref(p_loc_id);
    fetch c_loc_pref into lv_display_ssn;
    if c_loc_pref%notfound or lv_display_ssn is null then
       open c_org_pref(p_org_id, 'US_ORG_REP_PREFERENCES');
       fetch c_org_pref into lv_display_ssn;
       if c_org_pref%notfound or lv_display_ssn is null then
          close c_org_pref;

          open c_org_pref(p_org_id, 'US_BG_REP_PREFERENCES');
          fetch c_org_pref into lv_display_ssn;
          if c_org_pref%notfound or lv_display_ssn is null then
             lv_display_ssn := 'Y';
          end if;
       end if;
       close c_org_pref;
    end if;
    close c_loc_pref;

    if nvl(lv_display_ssn,'Y') = 'Y' then
       return 'Y';
    else
       return 'N';
    end if;

  END ssn_reporting_preferences;


  FUNCTION get_min_action(p_business_group_id in number
                         ,p_start_date        in date
                         ,p_end_date          in date
                         ,p_tax_unit_id       in number default null
                         ,p_payroll_id        in number default null)
  RETURN NUMBER
  IS
    cursor c_get_min_action(cp_business_group_id in number
                           ,cp_start_date        in date
                           ,cp_end_date          in date
                           ,cp_tax_unit_id       in number
                           ,cp_payroll_id        in number) is
       select nvl(min(assignment_action_id),-1)
         from pay_assignment_actions paa,
              pay_payroll_actions ppa,
              pay_payrolls_f ppf
        where ppa.business_group_id +0 = cp_business_group_id
          and ppa.payroll_action_id = paa.payroll_action_id
          and ppa.effective_date between cp_start_date and cp_end_date
          and ppa.action_type in ('R','Q','I','B','V')
          and ppf.payroll_id = ppa.payroll_id
          and ppa.business_group_id +0 = ppf.business_group_id
          and paa.tax_unit_id = nvl(cp_tax_unit_id, paa.tax_unit_id)
          and ppf.payroll_id = nvl(cp_payroll_id, ppf.payroll_id);

    ln_min_action NUMBER;

  BEGIN
    open c_get_min_action(p_business_group_id
                         ,p_start_date
                         ,p_end_date
                         ,p_tax_unit_id
                         ,p_payroll_id);
    fetch c_get_min_action into ln_min_action;
    close c_get_min_action;

    pay_us_balance_view_pkg.set_session_var('GRP_AAID',to_char(ln_min_action));

    return(ln_min_action);

  END get_min_action;

END pay_us_payroll_utils;

/
