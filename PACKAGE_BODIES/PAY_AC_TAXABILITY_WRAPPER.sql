--------------------------------------------------------
--  DDL for Package Body PAY_AC_TAXABILITY_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AC_TAXABILITY_WRAPPER" as
/* $Header: payactxabltywrap.pkb 120.5 2006/11/20 10:49:23 rpasumar noship $ */

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

    Package Body Name : pay_ac_taxability_wrapper
    Package File Name : payactxabltywrap.pkb
    Description : This package declares functions and procedures
                  which supports US and CA taxability rules upload
                  via spread sheet loader.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    21-JUN-04   fusman      115.0             Created
    29-JUL-04   fusman      115.1             Added State information.
    01-AUG-04   fusman      115.2             Added Canada information.
    11-AUG-04   fusman      115.3             Added Local  information.
    16-AUG-04   fusman      115.4             Added new message for invalid
                                              type values.

    18-AUG-04   fusman      115.5             Added tax types for Local
                                              Pre-tax deductions.
    18-AUG-04   fusman      115.6  3840695    Initialized the ltt_tax_type
                                              pl/sql table.
                                              Cleared the City,County values
                                              for Local taxability rules.
    24-AUG-04   fusman      115.6             Changed the city,county,tax type
                                              value names to upper case.
    25-AUG-04   fusman      115.9  3847970    Changed the code to not insert
                                              a row with status of D for Canada.
                                              Also, if user enters N in spreadsheet
                                              the value is deleted from table.
    26-AUG-04   fusman      115.10  3855943   Added nvl when checking valid status for CA
    04-AUG-05   meshah      115.11            Added AEIC for state pretax and earnings
    27-DEC-05   sudedas     115.12  4591127   Changed create_taxability_rules,
                                              transfer_tax_type_values and
                                              create_ca_prov_taxability
    15-NOV-06  rpasumar    115.13  Modified create_taxability_rules for the bug# 5652699.
 *******************************************************************/

  -- Package Variables
  g_package  VARCHAR2(100);
  TYPE character_data_table IS TABLE OF VARCHAR2(280)
                               INDEX BY BINARY_INTEGER;

  ltt_tax_types       character_data_table;
  ltt_tax_type_values character_data_table;


  PROCEDURE transfer_tax_type_values
                (p_input_tax_type_value1    IN  VARCHAR2
                ,p_input_tax_type_value2    IN  VARCHAR2
                ,p_input_tax_type_value3    IN  VARCHAR2
                ,p_input_tax_type_value4    IN  VARCHAR2
                ,p_input_tax_type_value5    IN  VARCHAR2
                ,p_input_tax_type_value6    IN  VARCHAR2
                ,p_input_tax_type_value7    IN  VARCHAR2
                ,p_input_tax_type_value8    IN  VARCHAR2
                ,p_input_tax_type_value9    IN  VARCHAR2
                ,p_input_tax_type_value10   IN  VARCHAR2
		,p_input_tax_type_value11   IN  VARCHAR2)
  IS
  BEGIN

     pay_ac_taxability_wrapper.ltt_tax_type_values(1) := upper(p_input_tax_type_value1);
     pay_ac_taxability_wrapper.ltt_tax_type_values(2) := upper(p_input_tax_type_value2);
     pay_ac_taxability_wrapper.ltt_tax_type_values(3) := upper(p_input_tax_type_value3);
     pay_ac_taxability_wrapper.ltt_tax_type_values(4) := upper(p_input_tax_type_value4);
     pay_ac_taxability_wrapper.ltt_tax_type_values(5) := upper(p_input_tax_type_value5);
     pay_ac_taxability_wrapper.ltt_tax_type_values(6) := upper(p_input_tax_type_value6);
     pay_ac_taxability_wrapper.ltt_tax_type_values(7) := upper(p_input_tax_type_value7);
     pay_ac_taxability_wrapper.ltt_tax_type_values(8) := upper(p_input_tax_type_value8);
     pay_ac_taxability_wrapper.ltt_tax_type_values(9) := upper(p_input_tax_type_value9);
     pay_ac_taxability_wrapper.ltt_tax_type_values(10):= upper(p_input_tax_type_value10);
     pay_ac_taxability_wrapper.ltt_tax_type_values(11):= upper(p_input_tax_type_value11);

     hr_utility.trace('ltt_tax_type_values(1) = '||
                       pay_ac_taxability_wrapper.ltt_tax_type_values(1));
     hr_utility.trace('ltt_tax_type_values(2) = '||
                       pay_ac_taxability_wrapper.ltt_tax_type_values(2));
     hr_utility.trace('ltt_tax_type_values(3) = '||
                       pay_ac_taxability_wrapper.ltt_tax_type_values(3));
     hr_utility.trace('ltt_tax_type_values(4) = '||
                       pay_ac_taxability_wrapper.ltt_tax_type_values(4));
     hr_utility.trace('ltt_tax_type_values(5) = '||
                       pay_ac_taxability_wrapper.ltt_tax_type_values(5));
     hr_utility.trace('ltt_tax_type_values(6) = '||
                       pay_ac_taxability_wrapper.ltt_tax_type_values(6));
     hr_utility.trace('ltt_tax_type_values(7) = '||
                       pay_ac_taxability_wrapper.ltt_tax_type_values(7));
     hr_utility.trace('ltt_tax_type_values(8) = '||
                       pay_ac_taxability_wrapper.ltt_tax_type_values(8));
     hr_utility.trace('ltt_tax_type_values(9) = '||
                       pay_ac_taxability_wrapper.ltt_tax_type_values(9));
     hr_utility.trace('ltt_tax_type_values(10) = '||
                       pay_ac_taxability_wrapper.ltt_tax_type_values(10));
     hr_utility.trace('ltt_tax_type_values(11) = '||
                       pay_ac_taxability_wrapper.ltt_tax_type_values(11));

  END transfer_tax_type_values;

  /************************************************************
  ** Function called for US Federal Context is passed
  ************************************************************/
  FUNCTION get_taxability_rule_date_id
                 (p_legislation_code  IN  VARCHAR2,
                  p_effective_date    IN DATE)
  RETURN NUMBER

  IS

    cursor c_taxability_rule_date (cp_legislation_code in varchar2
                                  ,cp_effective_date   in date) is
      select taxability_rules_date_id
        from pay_taxability_rules_dates
       where legislation_code = cp_legislation_code
         and cp_effective_date between valid_date_from
                                   and valid_date_to;

    ln_taxability_rule_date_id NUMBER;

  BEGIN
    open c_taxability_rule_date(p_legislation_code
                               ,p_effective_date);
    fetch c_taxability_rule_date into ln_taxability_rule_date_id;
    if c_taxability_rule_date%notfound then
       hr_utility.trace('No Taxability Rule Date found');
       hr_utility.raise_error;
    end if;
    close c_taxability_rule_date;

    return (ln_taxability_rule_date_id);

  END get_taxability_rule_date_id;

  PROCEDURE initialize
  IS
  BEGIN

       ltt_tax_types(1) := null;
       ltt_tax_types(2) := null;
       ltt_tax_types(3) := null;
       ltt_tax_types(4) := null;
       ltt_tax_types(5) := null;
       ltt_tax_types(6) := null;
       ltt_tax_types(7) := null;
       ltt_tax_types(8) := null;
       ltt_tax_types(9) := null;
       ltt_tax_types(10) := null;

       ltt_tax_types.delete;

  END initialize;

  /************************************************************
  ** Function called for US Federal Context is passed
  ** Following values are currently used
  **    p_input_tax_type_value1 = FIT Not Withheld
  **    p_input_tax_type_value2 = FIT Withheld
  **    p_input_tax_type_value3 = EIC
  **    p_input_tax_type_value4 = FUTA
  **    p_input_tax_type_value5 = Medicare
  **    p_input_tax_type_value6 = SS
  ************************************************************/
  PROCEDURE create_us_federal_taxability(p_classification in varchar2)
  IS
  BEGIN

    if p_classification in ('Supplemental Earnings',
                            'Imputed Earnings') then

       ltt_tax_types(1) := 'NW_FIT';
       ltt_tax_types(2) := 'FIT';
       ltt_tax_types(3) := 'EIC';
       ltt_tax_types(4) := 'FUTA';
       ltt_tax_types(5) := 'MEDICARE';
       ltt_tax_types(6) := 'SS';

    elsif p_classification in ('Pre-Tax Deductions') then
       ltt_tax_types(1) := 'FIT';
       ltt_tax_types(2) := 'EIC';
       ltt_tax_types(3) := 'FUTA';
       ltt_tax_types(4) := 'MEDICARE';
       ltt_tax_types(5) := 'SS';

    end if;

    hr_utility.trace('In create_us_federal_taxability');
    hr_utility.trace('ltt_tax_types.count = '||to_char(ltt_tax_types.count));
    hr_utility.trace('ltt_tax_types(1) = '||ltt_tax_types(1));

  END create_us_federal_taxability;

  /************************************************************
  ** Function called for US State Context is passed
  ** Following values are currently used
  ** Earnings:
  **    p_input_tax_type_value1 = SIT Not Withheld
  **    p_input_tax_type_value2 = SIT Withheld
  **    p_input_tax_type_value3 = SDI
  **    p_input_tax_type_value4 = SUI
  **    p_input_tax_type_value5 = WC
  **    p_input_tax_type_value6 = STEIC
  ** Pre Tax Deductions:
  **    p_input_tax_type_value1 = SIT
  **    p_input_tax_type_value2 = SDI
  **    p_input_tax_type_value3 = SUI
  **    p_input_tax_type_value4 = STEIC

  ************************************************************/
  PROCEDURE create_us_state_taxability(p_classification in varchar2)
  IS
  BEGIN

    if p_classification in ('Supplemental Earnings',
                            'Imputed Earnings') then
       ltt_tax_types(1) := 'NW_SIT';
       ltt_tax_types(2) := 'SIT';
       ltt_tax_types(3) := 'SDI';
       ltt_tax_types(4) := 'SUI';
       ltt_tax_types(5) := 'WC';
       ltt_tax_types(6) := 'STEIC';

    elsif p_classification in ('Pre-Tax Deductions') then
       ltt_tax_types(1) := 'SIT';
       ltt_tax_types(2) := 'SDI';
       ltt_tax_types(3) := 'SUI';
       ltt_tax_types(4) := 'STEIC';

    end if;

    hr_utility.trace('In create_us_state_taxability');
    hr_utility.trace('ltt_tax_types.count = '||to_char(ltt_tax_types.count));
    hr_utility.trace('ltt_tax_types(1) = '||ltt_tax_types(1));

  END create_us_state_taxability;

  /************************************************************
  ** Function called for US Local County is passed
  ** Following values are currently used for
  ** Earnings,Pre Tax Deductions and  Taxable Benefits
  **    p_input_tax_type_value1 = COUNTY -- County Withheld
  **    p_input_tax_type_value2 = NW_COUNTY -- County Not Withheld

  ************************************************************/
  PROCEDURE create_us_loc_county_tax_rule(p_classification in varchar2)
  IS
  BEGIN

    if p_classification in ('Supplemental Earnings',
                            'Imputed Earnings') then
       ltt_tax_types(1) := 'NW_COUNTY';
       ltt_tax_types(2) := 'COUNTY';
       hr_utility.trace('ltt_tax_types(1) = '||ltt_tax_types(1));
       hr_utility.trace('ltt_tax_types(2) = '||ltt_tax_types(2));
    elsif p_classification in ('Pre-Tax Deductions') then
       ltt_tax_types(1) := 'COUNTY';
       hr_utility.trace('ltt_tax_types(1) = '||ltt_tax_types(1));
    end if;
    hr_utility.trace('In create_ca_federal_taxability');
    hr_utility.trace('ltt_tax_types.count = '||to_char(ltt_tax_types.count));

  END create_us_loc_county_tax_rule;


  /************************************************************
  ** Function called for US Local City is passed
  ** Following values are currently used for
  ** Earnings,Pre Tax Deductions and  Taxable Benefits
  **    p_input_tax_type_value1 = CITY -- City Withheld
  **    p_input_tax_type_value2 = NW_CITY -- City Not Withheld

  ************************************************************/
  PROCEDURE create_us_loc_city_tax_rule(p_classification in varchar2)
  IS
  BEGIN

    if p_classification in ('Supplemental Earnings',
                            'Imputed Earnings') then
       ltt_tax_types(1) := 'NW_CITY';
       ltt_tax_types(2) := 'CITY';
       hr_utility.trace('ltt_tax_types(1) = '||ltt_tax_types(1));
       hr_utility.trace('ltt_tax_types(2) = '||ltt_tax_types(2));
    elsif p_classification in ('Pre-Tax Deductions') then
       hr_utility.trace('In create_ca_federal_taxability');
       ltt_tax_types(1) := 'CITY';
       hr_utility.trace('ltt_tax_types(1) = '||ltt_tax_types(1));
    end if;
    hr_utility.trace('ltt_tax_types.count = '||to_char(ltt_tax_types.count));

  END create_us_loc_city_tax_rule;

  /************************************************************
  ** Function called for CA Federal Context is passed
  ** Following values are currently used for
  ** Earnings,Pre Tax Deductions and  Taxable Benefits
  **    p_input_tax_type_value1 = FED -- Federal Income Tax
  **    p_input_tax_type_value2 = CPP -- Canada Pension Plan
  **    p_input_tax_type_value3 = EIM -- Employment Insurance Money

  ************************************************************/
  PROCEDURE create_ca_federal_taxability
  IS
  BEGIN

    ltt_tax_types(1) := 'FED';
    ltt_tax_types(2) := 'CPP';
    ltt_tax_types(3) := 'EIM';

    hr_utility.trace('In create_ca_federal_taxability');
    hr_utility.trace('ltt_tax_types.count = '||to_char(ltt_tax_types.count));
    hr_utility.trace('ltt_tax_types(1) = '||ltt_tax_types(1));
    hr_utility.trace('ltt_tax_types(2) = '||ltt_tax_types(2));
    hr_utility.trace('ltt_tax_types(3) = '||ltt_tax_types(3));

  END create_ca_federal_taxability;


  /************************************************************
  ** Function called for Canadian Context is passed
  ** Following values are currently used
  ** Supplemental Earnings:
  **    p_input_tax_type_value1 = PRV  -- Provincial Income Tax
  **    p_input_tax_type_value2 = QPP  -- Quebec Pension Plan
  **    p_input_tax_type_value3 = PMED -- Provincial Medical Plan
  **    p_input_tax_type_value4 = WCB  -- Workers Compensation
  **    p_input_tax_type_value5 = VAC  -- Vacationable Earnings
  **    p_input_tax_type_value6 = PPIP
  **
  ** Taxable Benefits
  **    p_input_tax_type_value1 = PRV  -- Provincial Income Tax
  **    p_input_tax_type_value2 = QPP  -- Quebec Pension Plan
  **    p_input_tax_type_value3 = PMED -- Provincial Medical Plan
  **    p_input_tax_type_value4 = WCB  -- Workers Compensation
  **    p_input_tax_type_value5 = PST/QST Provincial Sales Tax/Quebec Sales Tax
  **    p_input_tax_type_value6 = GST  -- Goods and Services Tax
  **    p_input_tax_type_value7 = HST  -- Harmonized Sales Tax
  **    p_input_tax_type_value8 = PPT  -- Provincial Premium Tax
  **    p_input_tax_type_value9 = RSTI -- Retail Sales Tax on Insurance
  **    p_input_tax_type_value10 =VAC  -- Vacationable Earnings
  **    p_input_tax_type_value11 = PPIP
  **
  ** Pre Tax Deductions:
  **    p_input_tax_type_value1 = PRV  -- Provincial Income Tax
  **    p_input_tax_type_value2 = QPP  -- Quebec Pension Plan
  **    p_input_tax_type_value3 = PMED -- Provincial Medical Plan
  **    p_input_tax_type_value4 = WCB  -- Workers Compensation
  **    p_input_tax_type_value5 = PST/QST Provincial Sales Tax/Quebec Sales Tax
  **    p_input_tax_type_value6 = GST  -- Goods and Services Tax
  **    p_input_tax_type_value7 = HST  -- Harmonized Sales Tax
  **    p_input_tax_type_value8 = PPT  -- Provincial Premium Tax
  **    p_input_tax_type_value9 = RSTI -- Retail Sales Tax on Insurance
  **    p_input_tax_type_value10 = PPIP

  ************************************************************/
  PROCEDURE create_ca_prov_taxability(p_classification in varchar2
                                     ,p_jurisdiction   in varchar2)
  IS
  BEGIN

    if p_classification = 'Supplemental Earnings' then
       ltt_tax_types(1) := 'PRV';
       ltt_tax_types(2) := 'QPP';
       ltt_tax_types(3) := 'PMED';
       ltt_tax_types(4) := 'WCB';
       ltt_tax_types(5) := 'VAC';
       ltt_tax_types(6) := 'PPIP';
       hr_utility.trace('Supplemental Earnings');

    elsif p_classification = 'Taxable Benefits' then
       hr_utility.trace('Taxable Benefits ');
       ltt_tax_types(1) := 'PRV';
       ltt_tax_types(2) := 'QPP';
       ltt_tax_types(3) := 'PMED';
       ltt_tax_types(4) := 'WCB';

       if substr(p_jurisdiction,1,2) = 'QC' then
          ltt_tax_types(5) := 'QST';
          hr_utility.trace('Quebec. ltt_tax_types(5) = '||ltt_tax_types(5));

       else
          ltt_tax_types(5) := 'PST';
       end if;

       ltt_tax_types(6) := 'GST';
       ltt_tax_types(7) := 'HST';
       ltt_tax_types(8) := 'PPT';
       ltt_tax_types(9) := 'RSTI';
       ltt_tax_types(10) := 'VAC';
       ltt_tax_types(11) := 'PPIP';

     elsif p_classification = 'Pre-Tax Deductions' then
       ltt_tax_types(1) := 'PRV';
       ltt_tax_types(2) := 'QPP';
       ltt_tax_types(3) := 'PMED';
       ltt_tax_types(4) := 'WCB';

       if substr(p_jurisdiction,1,2) = 'QC' then
          ltt_tax_types(5) := 'QST';
          hr_utility.trace('Quebec. ltt_tax_types(5) = '||ltt_tax_types(5));
       else
          ltt_tax_types(5) := 'PST';
       end if;

       ltt_tax_types(6) := 'GST';
       ltt_tax_types(7) := 'HST';
       ltt_tax_types(8) := 'PPT';
       ltt_tax_types(9) := 'RSTI';
       ltt_tax_types(10) := 'PPIP';
    end if;

    hr_utility.trace('In create_ca_prov_taxability');
    hr_utility.trace('ltt_tax_types.count = '||to_char(ltt_tax_types.count));
/*
    hr_utility.trace('ltt_tax_types(1) = '||ltt_tax_types(1));
    hr_utility.trace('ltt_tax_types(2) = '||ltt_tax_types(2));
    hr_utility.trace('ltt_tax_types(3) = '||ltt_tax_types(3));
    hr_utility.trace('ltt_tax_types(4) = '||ltt_tax_types(4));
    hr_utility.trace('ltt_tax_types(5) = '||ltt_tax_types(5));
    hr_utility.trace('ltt_tax_types(6) = '||ltt_tax_types(6));
    hr_utility.trace('ltt_tax_types(7) = '||ltt_tax_types(7));
    hr_utility.trace('ltt_tax_types(8) = '||ltt_tax_types(8));
    hr_utility.trace('ltt_tax_types(9) = '||ltt_tax_types(9));
    hr_utility.trace('ltt_tax_types(10) = '||ltt_tax_types(10)); */

  END create_ca_prov_taxability;

  PROCEDURE call_api_for_taxability_rules
                (p_classification_id       IN NUMBER
                ,p_jurisdiction            IN VARCHAR2
                ,p_legislation_code        IN VARCHAR2
                ,p_tax_category            IN VARCHAR2
                ,p_taxability_rule_date_id IN NUMBER
                ,ptt_tax_types             IN ltt_tax_types%type
                ,ptt_tax_type_values       IN ltt_tax_type_values%type)
  IS
    lv_status       VARCHAR2(10);
    lv_valid_status VARCHAR2(10);

  BEGIN

    hr_utility.trace('In call_api_for_taxability_rules');
    hr_utility.trace('p_classification_id ' || p_classification_id);
    hr_utility.trace('p_jurisdiction ' || p_jurisdiction);
    hr_utility.trace('p_legislation_code ' || p_legislation_code);
    hr_utility.trace('p_tax_category ' || p_tax_category);
    hr_utility.trace('p_taxability_rule_date_id ' || p_taxability_rule_date_id);
    hr_utility.trace('ptt_tax_types.count = '      ||
                                       to_char(ptt_tax_types.count));
    hr_utility.trace('ptt_tax_type_values.count = '||
                                       to_char(ptt_tax_type_values.count));
    hr_utility.trace('ptt_tax_types(1) = '||ptt_tax_types(1));

    for i in ptt_tax_types.first .. ptt_tax_types.last loop

        hr_utility.trace('In Loop. ptt_tax_types = '||ptt_tax_types(i));

        /*****************************************************************
        ** Only call Taxability Rules API if the use has entered a value
        *****************************************************************/
        if ptt_tax_type_values(i) is not null then

           if ptt_tax_type_values(i) = 'Y' OR
              ptt_tax_type_values(i) = 'N' then
              lv_status := pay_taxability_rules_api.check_taxability_rule_exists
                          (p_jurisdiction      => p_jurisdiction
                          ,p_legislation_code  => p_legislation_code
                          ,p_classification_id => p_classification_id
                          ,p_tax_category      => p_tax_category
                          ,p_tax_type          => ptt_tax_types(i)
                          );

              /* Do not touch the row if its a seeded one. */
              if lv_status = 'S' then /*Seed Row. */
                 hr_utility.trace('Do not modify Seed Data for Category: '||
                                                                p_tax_category);
                 hr_utility.set_message(801, 'PAY_DATAPUMP_UPD_TAX_SEED_ROW');
                 hr_utility.set_message_token('COLUMN', ptt_tax_types(i));
                 hr_utility.raise_error;

              else
                 hr_utility.trace('lv_status = '||lv_status);
                 hr_utility.trace('lv_valid_status = '||lv_valid_status);

                 /* No row exists. So insert a new row with status Null. */
                 if lv_status = 'N' then /*lv_status Check*/
                    /* No row exists. So insert a new row with status Null. */
                    if ptt_tax_type_values(i) = 'Y' then
                       hr_utility.trace('No row exists and user has passed Y.
                                         So insert a new row with status Null.');
                       lv_valid_status := null;
                    elsif ptt_tax_type_values(i) = 'N' then

                       hr_utility.trace('No row exists and user has passed N.
                                         So insert a new row with status D.');
                       lv_valid_status := 'D';
                    end if;

                    if p_legislation_code = 'US' or nvl(lv_valid_status,'V') <> 'D' then

                        hr_utility.trace('p_legislation_code = '||p_legislation_code||'
                                          ptt_tax_types = '||ptt_tax_types(i));
                       pay_taxability_rules_api.create_taxability_rules
                          (p_validate                 => FALSE
                          ,p_jurisdiction             => p_jurisdiction
                          ,p_tax_type                 => ptt_tax_types(i)
                          ,p_tax_category             => p_tax_category
                          ,p_classification_id        => p_classification_id
                          ,p_taxability_rules_date_id => p_taxability_rule_date_id
                          ,p_legislation_code         => p_legislation_code
                          ,p_status                   => lv_valid_status
                          );
                    end if;

                 elsif lv_status in ('V') then /*Active row exists. */

                    if ptt_tax_type_values(i) = 'N' then
                       /*the user wanted to delete it. So set the status to 'D'. */

                       hr_utility.trace('Active row exists. User wanted to delete'||
                                        ' it so set the status to D.');
                       lv_valid_status := 'D';

                       if p_legislation_code = 'US' then
                          pay_taxability_rules_api.update_taxability_rules
                            (p_validate                 => FALSE
                            ,p_jurisdiction             => p_jurisdiction
                            ,p_tax_type                 => ptt_tax_types(i)
                            ,p_tax_category             => p_tax_category
                            ,p_classification_id        => p_classification_id
                            ,p_taxability_rules_date_id => p_taxability_rule_date_id
                            ,p_legislation_code         => p_legislation_code
                            ,p_status                   => lv_valid_status
                            );
                       elsif p_legislation_code = 'CA' then

                          delete from pay_taxability_rules
                           where legislation_code = p_legislation_code
                             and tax_type = ptt_tax_types(i)
                             and jurisdiction_code = p_jurisdiction
                             and classification_id = p_classification_id
                             and tax_category = p_tax_category
                             and taxability_rules_date_id = p_taxability_rule_date_id;

                       end if;
                    end if;

                 elsif lv_status in ('D') then /*In active row exists. */

                    if ptt_tax_type_values(i) = 'Y' then
                       /* But the user wanted to insert a row.
                          So set the status to null. */

                       hr_utility.trace('In active row exists. User wanted ' ||
                                        'to insert a row. Set the status to null.');
                       lv_valid_status := null;
                       pay_taxability_rules_api.update_taxability_rules
                            (p_validate                 => FALSE
                            ,p_jurisdiction             => p_jurisdiction
                            ,p_tax_type                 => ptt_tax_types(i)
                            ,p_tax_category             => p_tax_category
                            ,p_classification_id        => p_classification_id
                            ,p_taxability_rules_date_id => p_taxability_rule_date_id
                            ,p_legislation_code         => p_legislation_code
                            ,p_status                   => lv_valid_status
                            );

                    end if;
                 end if; /*lv_status Check*/
              end if;     /*Seed Row. */
           else
              hr_utility.trace('Invalid Value for Column: '||
                                ptt_tax_types(i)||' = '||ptt_tax_type_values(i));
              hr_utility.set_message(801, 'PAY_DATAPUMP_INVALID_DATA');
              hr_utility.set_message_token('COLUMN', ptt_tax_types(i));
              hr_utility.raise_error;
           end if;
        end if;
  end loop;
    hr_utility.set_location('outside endloop call_api_for_taxability_rules',100);

  END call_api_for_taxability_rules;


  FUNCTION get_tax_category_code(p_classification    in varchar2
                                ,p_legislation_code  in varchar2
                                ,p_tax_category      in varchar2)
  RETURN VARCHAR2
  IS
    -- Bug# 5652699
    CURSOR c_tax_category_code(cp_lookup_type in varchar2,
                                 cp_lookup_code in varchar2) IS
      SELECT lookup_code
      FROM hr_lookups
      WHERE upper(lookup_type) = upper(ltrim(rtrim(cp_lookup_type)))
       AND (
                 upper(lookup_code) = upper(ltrim(rtrim(cp_lookup_code)))
		 OR
		 upper(meaning) = upper(ltrim(rtrim(cp_lookup_code))));

    l_lookup_type VARCHAR2(50);
    l_lookup_code VARCHAR2(11);

  BEGIN

    hr_utility.trace('Begin FUNCTION get_tax_category_code');
    hr_utility.trace('p_classification : ' || p_classification);
    hr_utility.trace('p_legislation_code : ' || p_legislation_code);
    hr_utility.trace('p_tax_category : ' || p_tax_category);
    l_lookup_type := replace(replace(p_legislation_code || '_' ||
                             upper(p_classification), ' ', '_'),'-', '_');

    hr_utility.trace('l_lookup_type : ' || l_lookup_type);

    hr_utility.trace('SELECT lookup_code FROM hr_lookups WHERE upper(lookup_type) = upper(ltrim(rtrim(cp_lookup_type))) AND upper(meaning) = upper(ltrim(rtrim(cp_lookup_code)))');

    OPEN c_tax_category_code(l_lookup_type,p_tax_category);
    FETCH c_tax_category_code INTO l_lookup_code;
    if c_tax_category_code%NOTFOUND then
       hr_utility.trace('Lookup Code not found for lookup_type '
                            || l_lookup_type ||
                        ' and for tax category '
                            || p_tax_category);
	/* Raise error that needs to be send to the sheet. */
	-- Bug# 5652699
	hr_utility.set_message(801, 'PAY_DATAPUMP_INVALID_DATA');
        hr_utility.set_message_token('COLUMN', p_tax_category);
	hr_utility.raise_error;
    end if;
    CLOSE c_tax_category_code;
    hr_utility.trace('returning l_lookup_code  : ' || l_lookup_code);
    return(l_lookup_code);

  END get_tax_category_code;


  PROCEDURE get_local_jurisdiction(p_state_abbrev   in varchar2
                                  ,p_county_name    in varchar2
                                  ,p_city_name      in varchar2
                                  ,p_local_jd_code out nocopy varchar2)
  IS
    cursor c_get_state_code (cp_state_abbrev in varchar2) is
      select state_code
        from pay_us_states pus
       where pus.state_abbrev = upper(cp_state_abbrev);

    cursor c_get_county_code(cp_state_code  in varchar2
                            ,cp_county_name in varchar2) is
      select puc.county_code
        from pay_us_counties puc
       where puc.state_code = cp_state_code
         and upper(puc.county_name) = upper(cp_county_name);

    cursor c_get_city_code(cp_state_code in varchar2
                          ,cp_city_name  in varchar2) is
      select city_code from pay_us_city_names
       where state_code = cp_state_code
         and upper(city_name) = upper(cp_city_name);

    lv_state_code  VARCHAR2(2);
    lv_county_code VARCHAR2(3);
    lv_city_code   VARCHAR2(5);

  BEGIN
    lv_state_code  := '00';
    lv_county_code := '000';
    lv_city_code   := '0000';

    open c_get_state_code(p_state_abbrev);
    fetch c_get_state_code into lv_state_code;
    close c_get_state_code;

    if p_county_name is not null then
       open c_get_county_code(lv_state_code, p_county_name);
       fetch c_get_county_code into lv_county_code;
       close c_get_county_code;
    end if;

    if p_city_name is not null then
       open c_get_city_code(lv_state_code, p_city_name);
       fetch c_get_city_code into lv_city_code;
       close c_get_city_code;
    end if;

    p_local_jd_code := lv_state_code  || '-' ||
                       lv_county_code || '-' ||
                       lv_city_code;

  END get_local_jurisdiction;

  PROCEDURE create_taxability_rules
                (p_classification_id        IN NUMBER
                ,p_tax_category             IN VARCHAR2
                ,p_jurisdiction             IN VARCHAR2 default null
                ,p_legislation_code         IN VARCHAR2 default null
                ,p_input_tax_type_value1    IN VARCHAR2 default null
                ,p_input_tax_type_value2    IN VARCHAR2 default null
                ,p_input_tax_type_value3    IN VARCHAR2 default null
                ,p_input_tax_type_value4    IN VARCHAR2 default null
                ,p_input_tax_type_value5    IN VARCHAR2 default null
                ,p_input_tax_type_value6    IN VARCHAR2 default null
                ,p_input_tax_type_value7    IN VARCHAR2 default null
                ,p_input_tax_type_value8    IN VARCHAR2 default null
                ,p_input_tax_type_value9    IN VARCHAR2 default null
                ,p_input_tax_type_value10   IN VARCHAR2 default null
		,p_input_tax_type_value11   IN VARCHAR2 default null
                ,p_spreadsheet_identifier   IN VARCHAR2 default null
                )
  IS

  CURSOR c_classification(cp_classification_id in number
                         ,cp_legislation_code  in varchar2) IS
    select classification_name
      from pay_element_classifications
     where classification_id = cp_classification_id
       and legislation_code = cp_legislation_code;


    lv_procedure               VARCHAR2(72);
    ln_taxability_rule_date_id NUMBER;
    lv_tax_category            VARCHAR2(20);
    lb_is_local                BOOLEAN;
    lv_classification_name     VARCHAR2(100);
    lv_jurisdiction_code       VARCHAR2(11);

  BEGIN
    lv_procedure := g_package||'create_taxability_rules';
    hr_utility.set_location('Entering:'|| lv_procedure, 10);
    lb_is_local := FALSE;
    lv_jurisdiction_code := p_jurisdiction;

    hr_utility.trace('p_classification_id = '||to_char(p_classification_id));
    hr_utility.trace('p_tax_category = '||p_tax_category);
    hr_utility.trace('p_jurisdiction = '||p_jurisdiction);
    hr_utility.trace('p_legislation_code = '||p_legislation_code);
    hr_utility.trace('p_input_tax_type_value1 = '||p_input_tax_type_value1);
    hr_utility.trace('p_input_tax_type_value2 = '||p_input_tax_type_value2);
    hr_utility.trace('p_input_tax_type_value3 = '||p_input_tax_type_value3);
    hr_utility.trace('p_input_tax_type_value4 = '||p_input_tax_type_value4);
    hr_utility.trace('p_input_tax_type_value5 = '||p_input_tax_type_value5);
    hr_utility.trace('p_input_tax_type_value6 = '||p_input_tax_type_value6);

    transfer_tax_type_values
                (p_input_tax_type_value1  => p_input_tax_type_value1
                ,p_input_tax_type_value2  => p_input_tax_type_value2
                ,p_input_tax_type_value3  => p_input_tax_type_value3
                ,p_input_tax_type_value4  => p_input_tax_type_value4
                ,p_input_tax_type_value5  => p_input_tax_type_value5
                ,p_input_tax_type_value6  => p_input_tax_type_value6
                ,p_input_tax_type_value7  => p_input_tax_type_value7
                ,p_input_tax_type_value8  => p_input_tax_type_value8
                ,p_input_tax_type_value9  => p_input_tax_type_value9
                ,p_input_tax_type_value10 => p_input_tax_type_value10
		,p_input_tax_type_value11 => p_input_tax_type_value11);

    if ln_taxability_rule_date_id is null then
       ln_taxability_rule_date_id
                := get_taxability_rule_date_id
                        (p_legislation_code => p_legislation_code
                        ,p_effective_date   => sysdate);
    end if;

    hr_utility.trace('Before checking p_jurisdiction = '||p_jurisdiction);
    hr_utility.trace('p_legislation_code = '||p_legislation_code);

    open c_classification(p_classification_id,
                          p_legislation_code);
    fetch c_classification INTO lv_classification_name;
    if c_classification%NOTFOUND then
       hr_utility.trace('No classification id found.');
       hr_utility.raise_error;
    end if;
    close c_classification;

    hr_utility.trace('lv_classification_name = '|| lv_classification_name);
    initialize;

    if p_legislation_code = 'US' then
       if ltrim(rtrim(p_jurisdiction)) = '00-000-0000' then
           hr_utility.trace('p_jurisdiction is Federal');
           create_us_federal_taxability(
                  p_classification => lv_classification_name);

       elsif substr(p_jurisdiction,1 ,2) <> '00' and
             substr(p_jurisdiction,4,3) = '000' and
             substr(p_jurisdiction,8,4) = '0000' then
           create_us_state_taxability(
                  p_classification => lv_classification_name);

       elsif length(p_jurisdiction) = 2 and
             p_input_tax_type_value1 is not null and
             p_input_tax_type_value2 is null then
           create_us_loc_county_tax_rule(
                  p_classification => lv_classification_name);
           lb_is_local:= TRUE;

       elsif length(p_jurisdiction) = 2 and
             p_input_tax_type_value1 is null and
             p_input_tax_type_value2 is not null then
           create_us_loc_city_tax_rule(
                  p_classification => lv_classification_name);
           lb_is_local:= TRUE;

       end if;

       if lb_is_local then
          get_local_jurisdiction(p_state_abbrev  => p_jurisdiction
                                ,p_county_name   => p_input_tax_type_value1
                                ,p_city_name     => p_input_tax_type_value2
                                ,p_local_jd_code => lv_jurisdiction_code);

          if lv_classification_name in ('Supplemental Earnings',
                                        'Imputed Earnings') then
             pay_ac_taxability_wrapper.ltt_tax_type_values(1)
                  := upper(p_input_tax_type_value3);
             pay_ac_taxability_wrapper.ltt_tax_type_values(2)
                  := upper(p_input_tax_type_value4);

             pay_ac_taxability_wrapper.ltt_tax_type_values(3)
                  := null;
             pay_ac_taxability_wrapper.ltt_tax_type_values(4)
                  := null;
             hr_utility.trace('Local Earnings. Tax type value1 = '||
                               pay_ac_taxability_wrapper.ltt_tax_type_values(1));
             hr_utility.trace('Local Earnings. Tax type value 2= '||
                               pay_ac_taxability_wrapper.ltt_tax_type_values(2));

          elsif lv_classification_name in ('Pre-Tax Deductions') then
             pay_ac_taxability_wrapper.ltt_tax_type_values(1)
                        := upper(p_input_tax_type_value3);
             pay_ac_taxability_wrapper.ltt_tax_type_values(2)
                        := null;
             pay_ac_taxability_wrapper.ltt_tax_type_values(3)
                        := null;
             hr_utility.trace('Local Earnings. Tax type value1 = '||
                               pay_ac_taxability_wrapper.ltt_tax_type_values(1));

          end if;
       end if;

    elsif p_legislation_code = 'CA' then

       if ltrim(rtrim(p_jurisdiction)) = '00-000-0000' then
          hr_utility.trace('p_jurisdiction is Federal');
          create_ca_federal_taxability;
       elsif substr(p_jurisdiction,4,3) = '000' and
             substr(p_jurisdiction,8,4) = '0000' then

          create_ca_prov_taxability(
                  p_classification => lv_classification_name
                 ,p_jurisdiction   => p_jurisdiction);
       end if;
    end if;

    hr_utility.trace('Before call_api_for_taxability_rules');
    hr_utility.trace('pay_ac_taxability_wrapper.ltt_tax_type_values(1) = '||
                      pay_ac_taxability_wrapper.ltt_tax_type_values(1));

    hr_utility.trace('ltt_tax_type_values(1) = '||
                      ltt_tax_type_values(1));
    hr_utility.trace('ltt_tax_type_values.count = '||
                      to_char(ltt_tax_type_values.count));
    hr_utility.trace('ltt_tax_types.count = '||to_char(ltt_tax_types.count));

    lv_tax_category := get_tax_category_code(
                            p_classification    => lv_classification_name
                           ,p_legislation_code  => p_legislation_code
                           ,p_tax_category      => p_tax_category);


    call_api_for_taxability_rules
                (p_classification_id => p_classification_id
                ,p_jurisdiction      => lv_jurisdiction_code
                ,p_legislation_code  => p_legislation_code
                ,p_tax_category      => lv_tax_category
                ,p_taxability_rule_date_id => ln_taxability_rule_date_id
                ,ptt_tax_types       => ltt_tax_types
                ,ptt_tax_type_values => ltt_tax_type_values);

  EXCEPTION

    WHEN OTHERS THEN
       hr_utility.set_location(' Leaving:'||lv_procedure, 80);
       RAISE;

  END create_taxability_rules;


  PROCEDURE update_taxability_rules
                (p_classification_id        IN NUMBER
                ,p_tax_category             IN VARCHAR2
                ,p_jurisdiction             IN VARCHAR2
                ,p_legislation_code         IN VARCHAR2
                ,p_input_tax_type_value1    IN VARCHAR2
                ,p_input_tax_type_value2    IN VARCHAR2
                ,p_input_tax_type_value3    IN VARCHAR2
                ,p_input_tax_type_value4    IN VARCHAR2
                ,p_input_tax_type_value5    IN VARCHAR2
                ,p_input_tax_type_value6    IN VARCHAR2
                ,p_input_tax_type_value7    IN VARCHAR2
                ,p_input_tax_type_value8    IN VARCHAR2
                ,p_input_tax_type_value9    IN VARCHAR2
                ,p_input_tax_type_value10   IN VARCHAR2
                ,p_spreadsheet_identifier   IN VARCHAR2
                )
  IS

    lv_procedure VARCHAR2(72);

  BEGIN
    lv_procedure := g_package||'update_taxability_rules';
    savepoint upd_taxability_rule;
    hr_utility.set_location('Entering:'|| lv_procedure, 10);

    hr_utility.set_location('Leaving:'|| lv_procedure, 20);

  EXCEPTION

    WHEN OTHERS THEN
      hr_utility.set_location(' Leaving:'||lv_procedure, 80);
      raise;

  END update_taxability_rules;

BEGIN
  g_package := 'pay_ac_taxability_rules_wrapper.';
  --hr_utility.trace_on(null,'ram');
end pay_ac_taxability_wrapper;

/
