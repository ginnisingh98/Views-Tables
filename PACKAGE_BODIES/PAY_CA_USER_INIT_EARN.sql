--------------------------------------------------------
--  DDL for Package Body PAY_CA_USER_INIT_EARN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_USER_INIT_EARN" AS
/* $Header: pycauiet.pkb 120.1.12010000.2 2009/05/15 07:30:16 sneelapa ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1998 Oracle Corporation.                        *
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

    Name        : pay_ca_user_init_earn
    Filename	: pycauiet.pkb
    Change List
    -----------
    Date        Name          	Vers    Bug No  Description
    ----        ----          	----    ------  -----------
    10-NOV-98   R.Murthy  	115.0		First Created.

    03-JUN-99	R. Murthy	115.4   901531	Update shadow structure
						also updates the user-entered
						element description and element
						reporting name.

						Added a check to see if the
                                                element being created has the
                                                same name as that of an
                                                existing balance (seeded or
                                                otherwise).  If yes, an error
                                                is raised.  This prevents
                                                users from creating elements
                                                with reserved words as names.
    17-FEB-2000 RThirlby        115.5           Added p_ele_calc_method to
                                                procedure create_user_init_
                                                earning. Used in update_shadow_
                                                element.
    17-FEB-2000 RThirlby                        Added new procedure
                                                update_jd_level_on_balance.
                                                This updates jurisdiction_level
                                                on pay_balance_types for all
                                                balances.
                                                Changes for Flexi date too.
    29-FEB-2000 RThirlby                        Added p_ele_eoy_type to
                                                procedure create_user_init_
                                                earning. Used in update_shadow_
                                                element. This parameter inserts
                                                the Year End Form for an
                                                earning.
    21-MAR-2000 ACai                            Update date mask for 11i.
    31-OCT-2000 JARTHURT        115.9           Update t4a footnote,rl1 footnote
                                                and registration number for
                                                new reference in element DFF.
    20-FEB-2001 Ekim           115.10          Added Procedure update_ntg_element
                                               to enable 'Net to Gross'
                                               functionality and also corrected
                                               process_mode.
    27-FEB-2001 SSattini       115.11          Removed extra comment symbol
    31-May-2001 VPandya        115.12          Added Hours by Rate functionality
    01-OCT-2001 mmukherj       115.15,16       Added the functionality of defaul
                                               ting element_information9 to 'T'
                                               or 'A' for HoursXRate elements.
    11-APR-2002 SSattini       115.17          Fixed the bug#2304888
                                               and also added dbdrv.
    11-APR-2002 SSattini       115.18          Corrected GSCC complaint.
    06-JUN-2002 mmukherj       115.19          Changed the defaulting of
                                               Regular Earnings Adjustment Rule
                                               for  'Earnings' elements
                                               to A from T,
                                               bugfix #2402284
    20-Jan-2003 vpandya        115.20,21       Creating skip records in
                                               element type usages table. If
                                               Tax processing type and Year End
                                               form (gre type) is matches with
                                               run type name of pay_run_types_f
                                               table then one record will be
                                               created with inclusion_flag 'Y'
                                               and usage_type 'T', and 8 records
                                               created with inclusion_flag 'N'
                                               and usage_type NULL for other run
                                               types. For Non Payroll Payments
                                               element, there will be 3 records
                                               with 'Y' and 'T', and 6 records
                                               with 'N' and NULL. New skip rules
                                               will be assigned to new elements
                                               are REG_EARNINGS_SKIP and
                                               SUPP_EARNINGS_SKIP.
    18-Feb-2003 vpandya        115.22          Using API for element type usage.
    20-Mar-2003 vpandya        115.23          For Non-Payroll Payment element,
                                               defaulting T4/RL1 Regular trigger
                                               for element type usage if form
                                               type is blank otherwise it
                                               it defaults to form type +
                                               Regulae (e.g. T4A/RL2 Regular)
    01-MAY-2003 mmukherj       115.24          The process mode for non sepcheck
                                               element has been changed from 'N'
                                               to 'S'. Bugfix: 2811154,2802065
    23-MAY-2003 pganguly       115.25 2924151  For Base/Special Feature Element
                                               the element_information3 is
                                               updated to 'DE'(Date Earned).
                                               This is only done for Elements
                                               with classification 'Earnings',
                                               'Supplemental Earnings',
                                               'Taxable Benefits'. Also for Sp
                                               Feature elements element_infor
                                               mation_category, element_infor
                                               mation1 will be populated with
                                               the value of the Base element
                                               for those classifications.
    20-JUN-2003 vpandya        115.26          The process mode for non sepcheck
                                               element has been changed from 'N'
                                               to 'S' only for 'Supplemental
                                               Earnings'. Using existing
                                               variable l_sep_check_create to
                                               set process mode.
    05-AUG-2003 ssouresr       115.28          Saving run balances for _GRE_RUN
                                               _GRE_JD_RUN, _ASG_GRE_RUN  and
                                               _ASG_JD_GRE_RUN on
                                               pay_defined_balances
    05-AUG-2003 ssouresr       115.29          Removed _GRE_RUN and _GRE_JD_RUN                                                from previous change as these
                                               dimensions are not required for
                                               saving nonseeded balances

    25-SEP-2003 mmukherj       115.30          Bugfix : 2851568.
                                               Feed Taxable Benefits for Quebec                                                for all Taxable Benefits Element                                                with Category PHSP.In
                                               create_user_init earning a
                                               section has been added to feed
                                               Taxable Benefits for Quebec
                                               balance for PHSP.
    26-SEP-2003 ssattini       115.31         Added update to set the
                                              post_termination_rule to 'Last
                                              Standard Process Date' for all
                                              recurring elements.  Fix for
                                              bug#2219028.
    22-MAR-2004 ssmukher       115.32         Bug#2646705 Enhancement for
                                              adding the termination rule
    27-APR-2004 ssmukher       115.33         Bug#2646705 Replaced the skip rule from
                                              REG_EARNINGS_SKIP to REGULAR_EARNINGS_SKIP
    13-APR-2006 ahanda         115.34         Modfied package ot create a formula result
                                              rule to Hours by Rate element
                                              EARNINGS_AMOUNT > Pay Value

    13-APR-2006 sneelapa         115.35       Bug 8491239, p_termination_rule parameter
                                              should be passed to PAY_SHADOW_ELEMENT_API
                                              For updating correct value of Termination Rule.

*/
--
--
------------------------- create_user_init_earning ----------------------------
--
FUNCTION create_user_init_earning (
		p_ele_name 		in varchar2,
		p_ele_reporting_name 	in varchar2,
		p_ele_description 	in varchar2 	default NULL,
		p_ele_classification 	in varchar2,
		p_ele_category 		in varchar2	default NULL,
                p_ele_calc_method       in varchar2,
                p_ele_eoy_type          in varchar2,
                p_ele_t4a_footnote      in varchar2,
                p_ele_rl1_footnote      in varchar2,
                p_ele_registration_number in varchar2,
		p_ele_ot_earnings	in varchar2 	default 'N',
		p_ele_ot_hours 		in varchar2 	default 'N',
		p_ele_ei_hours 		in varchar2 	default 'N',
		p_ele_processing_type 	in varchar2,
		p_ele_priority 		in number	default NULL,
		p_ele_standard_link 	in varchar2 	default 'N',
		p_ele_calc_rule 	in varchar2,
		p_ele_calc_rule_code 	in varchar2	default NULL,
		p_sep_check_option	in varchar2	default 'N',
		p_reduce_regular	in varchar2	default 'N',
		p_ele_eff_start_date	in date 	default NULL,
		p_ele_eff_end_date	in date		default NULL,
		p_bg_id			in number ,
                p_termination_rule      in varchar2     default 'F')--Bug 2646705
                RETURN NUMBER IS

  --
  -- cursor to retrieve the element id from element name
  --

  CURSOR cur_element_type_id(p_element_name VARCHAR2) IS
  SELECT element_type_id
  FROM   pay_element_types_f
  WHERE  upper(element_name) = upper(p_element_name)
  AND    legislation_code    = 'CA';

  --
  -- cursor to retrieve the Input Value id
  --

  CURSOR cur_input_id(p_element_name varchar2,
                      p_input_value_name varchar2) is
  SELECT piv.input_value_id
  FROM   pay_input_values_f piv, pay_element_types_f pet
  WHERE  upper(pet.element_name)        = upper(p_element_name)
  AND    pet.element_type_id            = piv.element_type_id
  AND    upper(pet.legislation_code)    = upper('CA')
  AND    upper(piv.name)                = upper(p_input_value_name);

  --
  CURSOR cur_input_id2(p_element_type_id Number,
                      p_input_value_name varchar2) is
  SELECT piv.input_value_id
  FROM   pay_input_values_f piv, pay_element_types_f pet
  WHERE  pet.element_type_id            = p_element_type_id
  AND    pet.element_type_id            = piv.element_type_id
/*  AND    upper(pet.legislation_code)    = upper('CA') */
  AND    upper(piv.name)                = upper(p_input_value_name);

  --
  -- Processing rule already exists
  --

  CURSOR cur_processing_rule_exists(p_element_type_id number) is
  SELECT status_processing_rule_id
  FROM   pay_status_processing_rules_f pspfr,
         pay_element_types_f petf
  WHERE  pspfr.element_type_id    = petf.element_type_id
  AND    petf.element_type_id     = p_element_type_id;

  --
  -- Creating element type usages for exclusion
  --

  CURSOR c_ele_tp_usg(cp_busi_grp_id number,
                      cp_ele_name    varchar2) is
    select pet.element_type_id
          ,pet.element_name
          ,pet.element_information2
          ,pet.element_information4
          ,pet.effective_start_date
          ,pet.effective_end_date
          ,pet.legislation_code
          ,pet.business_group_id
    from  pay_element_types_f pet
    where ( pet.element_name = cp_ele_name or
            pet.element_name = cp_ele_name || ' Special Inputs' )
      and   pet.business_group_id = cp_busi_grp_id
    order by pet.element_name;


  CURSOR c_run_tp is
    select prt.*
    from   pay_run_types_f     prt
    where  prt.legislation_code = 'CA'
    and  ( prt.shortname like 'REG_T4%' or
           prt.shortname like 'NP_T4%'  or
           prt.shortname like 'LS_T4%' );

  CURSOR get_asg_gre_run_dim_id IS
  SELECT balance_dimension_id
  FROM pay_balance_dimensions
  WHERE dimension_name = 'Assignment within Government Reporting Entity Run'
  AND   legislation_code = 'CA';

  CURSOR get_asg_jd_gre_run_dim_id IS
  SELECT balance_dimension_id
  FROM pay_balance_dimensions
  WHERE dimension_name = 'Assignment in JD within GRE Run'
  AND   legislation_code = 'CA';

  l_asg_gre_run_dim_id    pay_balance_dimensions.balance_dimension_id%TYPE;
  l_asg_jd_gre_run_dim_id pay_balance_dimensions.balance_dimension_id%TYPE;

--
-- Hours by Rate Variables
--
  lv_legislation                 varchar2(10) := 'CA';
  lv_element_name                varchar2(30) := 'Hours by Rate';
  lv_input_value_name            varchar2(30);
  lv_result_name                 varchar2(30);
  lv_element_type_id             number;
  lv_input_value_id              number;
  lv_proc_rule_id                number;
  lv_formula_result_rule_id      number;

--
-- global constants
c_end_of_time  CONSTANT DATE := TO_DATE('4712/12/31','YYYY/MM/DD');

-- global vars
g_inpval_disp_seq 	NUMBER := 0;	-- Display seq counter for input vals.
g_eff_start_date  	DATE;
g_eff_end_date  	DATE;

-- local vars
l_hr_only		BOOLEAN;
l_reserved              VARCHAR2(1) := 'N';
l_source_template_id	NUMBER(9); -- Source Template ID.
l_template_id		NUMBER(9); -- Template ID.
l_object_version_number	NUMBER(9); -- Object Version Number
l_sep_check_create      VARCHAR2(1);

l_bg_name		VARCHAR2(60);	-- Get from bg short name passed in.
l_element_type_id	NUMBER(9); -- Get from pay_shadow_element_types
l_ele_obj_ver_number	NUMBER(9); -- Object Version Number
l_sf_element_type_id	NUMBER(9); -- Get from pay_shadow_element_types
l_sf_ele_obj_ver_number	NUMBER(9); -- Object Version Number
l_si_element_type_id	NUMBER(9); -- Get from pay_shadow_element_types
l_si_ele_obj_ver_number	NUMBER(9); -- Object Version Number
l_base_element_type_id	NUMBER(9); -- Populated by insertion of element type.
l_pay_value_iv_id     	NUMBER(9); --
l_balance_feed_id     	NUMBER(9); --
l_balance_row_id     	NUMBER(9); --
l_balance_type_id     	NUMBER(9); --

l_pri_bal_id            NUMBER(9); -- Get from pay_shadow_balance_types
l_hrs_bal_id            NUMBER(9):= NULL; -- Get from pay_shadow_balance_types
l_exists                number(10) := 0;

l_ele_repname		VARCHAR2(30);
l_skip_formula		VARCHAR2(80);
l_primary_class_id	NUMBER(9);
l_priority		NUMBER(9);
l_class_hi_priority	NUMBER(9);
g_neg_earn_inpval_id	NUMBER(9);	-- ID of neg earn inpval for bal feed.

ln_run_type_id          NUMBER;
lv_earn_shortname       varchar2(80);
lv_inclusion_flag       varchar2(80);
lv_usage_type           varchar2(80);

ln_element_type_usage_id number;
ln_object_version_number number;
ld_effective_start_date  date;
ld_effective_end_date    date;
l_roe_allocation_by      VARCHAR2(2);
l_sf_ele_info_category   pay_element_types_f.element_information_category%TYPE;
l_sf_ele_category        pay_element_types_f.element_information1%TYPE;

--
---------------------------- get_template_id -------------------------------
--
FUNCTION get_template_id (p_legislation_code	in varchar2,
			  p_calc_rule_code	in varchar2)
RETURN number IS
-- local vars
l_template_id		NUMBER(9);
l_template_name		VARCHAR2(80);

BEGIN
--
hr_utility.set_location('pay_ca_user_init_earn.get_template_id',1);
--
if p_calc_rule_code = 'FLT' then
   l_template_name := 'Flat Amount Earning';
   --l_template_name := 'Test Flat Amount Earnings';
elsif p_calc_rule_code = 'HXR' then
   l_template_name := 'Hours X Rate Earning';
   --l_template_name := 'Test Hours X Rate Earnings';
elsif p_calc_rule_code = 'PCT' then
   l_template_name := 'Percent of Earnings Earning';
elsif p_calc_rule_code = 'NTG FLT' then
   l_template_name := 'Net To Gross Earning';
else
   hr_utility.set_location('pay_ca_user_init_earn.get_template_id',2);
   hr_utility.set_message(801,'HR_XXXXX_INVALID_CALC_RULE_EARN');
   hr_utility.raise_error;
end if;
--
hr_utility.set_location('pay_ca_user_init_earn.get_template_id',3);
hr_utility.trace('Template Name is :'||l_template_name||'****'||
		 'Legislation is :'||p_legislation_code);
--
select template_id
into   l_template_id
from   pay_element_templates
where  template_name = l_template_name
and    legislation_code = p_legislation_code
and    business_group_id is NULL
and    template_type = 'T';
--
hr_utility.set_location('pay_ca_user_init_earn.get_template_id',4);
--
RETURN l_template_id;
--
END get_template_id;

--
--------------------------- chk_ca_pay_installed ---------------------------
--
FUNCTION chk_ca_pay_installed
RETURN varchar2 IS

-- local vars
l_installed           VARCHAR2(1) := 'N';

BEGIN
--
hr_utility.set_location('pay_ca_user_init_earn.chk_ca_pay_installed',1);
--
BEGIN
select 'Y'
into l_installed
from pay_balance_types
where upper(balance_name) = 'FED SUBJECT'
and legislation_code = 'CA';

EXCEPTION WHEN NO_DATA_FOUND THEN
   l_installed := 'N';

END;
--
hr_utility.set_location('pay_ca_user_init_earn.chk_ca_pay_installed',2);
--
RETURN (l_installed);
--
END chk_ca_pay_installed;

--
--
-------------------------- create_user_init_earning Main --------------------
--
-- Main Procedure

BEGIN
--
--
--hr_utility.trace_on('y','ORACLE');

--
hr_utility.set_location('pay_ca_user_init_earn.create_user_init_earning',1);
--
-- Set session date
pay_db_pay_setup.set_session_date(nvl(p_ele_eff_start_date, sysdate));
--
g_eff_start_date 	:= NVL(p_ele_eff_start_date, sysdate);
g_eff_end_date		:= NVL(p_ele_eff_end_date, c_end_of_time);
--
hr_utility.set_location('pay_ca_user_init_earn.create_user_init_earning',2);
--
---------------------------- Check Element Name ---------------------------
--
hr_utility.set_location('pay_ca_user_init_earn.create_user_init_earning',25);
--
BEGIN
select 'Y'
into l_reserved
from pay_balance_types
where upper(p_ele_name) = upper(balance_name)
and nvl(legislation_code, 'CA') = 'CA'
and nvl(business_group_id, p_bg_id) = p_bg_id;

EXCEPTION WHEN NO_DATA_FOUND THEN
   l_reserved := 'N';

END;
   --
if l_reserved = 'Y' then
   hr_utility.set_location('pay_ca_user_init_earn.create_user_init_earning',26);
   hr_utility.set_message(801,'HR_7564_ALL_RES_WORDS');
   hr_utility.raise_error;
end if;
--
---------------------------- Get Source Template ID -----------------------
--
hr_utility.set_location('pay_ca_user_init_earn.create_user_init_earning',3);
--
l_source_template_id := get_template_id(
				 p_legislation_code => g_template_leg_code,
				 p_calc_rule_code   => p_ele_calc_rule_code);
--
--------------------- Set Separate Check Creation -------------------------
--
hr_utility.set_location('pay_ca_user_init_earn.create_user_init_earning',4);
--
if p_ele_classification = 'Supplemental Earnings' then
   l_sep_check_create := 'Y';
   l_skip_formula     := 'SUPP_EARNINGS_SKIP';
else
   l_sep_check_create := 'N';
   l_skip_formula     := 'REGULAR_EARNINGS_SKIP'; --Bug 2646705 Changed by ssmukher
end if;
--
---------------------------- Create User Structure ------------------------
--
hr_utility.set_location('pay_ca_user_init_earn.create_user_init_earning',5);
--
-- The Configuration Flex segments are as follows:
-- Config 1 - exclusion rule - create Separate Check input value if 'Y'
-- Config 2 - input value default - update default value for Sep Check IV
-- Config 3 - exclusion rule - create balance feeds to OT Earnings if 'Y'
-- Config 4 - exclusion rule - create balance feeds to OT Hours if 'Y'
-- Config 5 - exclusion rule - create balance feeds to Reg Earnings/Hours if 'Y'
-- Config 6 - exclusion rule - create balance feeds to EI Hours if 'Y'
-- Config 7 - exclusion rule - create SI elements if 'R', SF always created.
--
if p_reduce_regular = 'Y' then
   l_priority := 1501;
else
   l_priority := p_ele_priority;
end if;
--
pay_element_template_api.create_user_structure
  (p_validate                      =>     false
  ,p_effective_date                =>     p_ele_eff_start_date
  ,p_business_group_id             =>     p_bg_id
  ,p_source_template_id            =>     l_source_template_id
  ,p_base_name                     =>     p_ele_name
  ,p_base_processing_priority      =>     l_priority
  ,p_configuration_information1    =>     l_sep_check_create
  ,p_configuration_information2    =>     p_sep_check_option
  ,p_configuration_information3    =>     p_ele_ot_earnings
  ,p_configuration_information4    =>     p_ele_ot_hours
  ,p_configuration_information5    =>     p_reduce_regular
  ,p_configuration_information6    =>     p_ele_ei_hours
  ,p_configuration_information7    =>     p_ele_processing_type
  ,p_template_id                   =>     l_template_id
  ,p_object_version_number         =>     l_object_version_number);
--
---------------------- Get Element Type ID of new Template -----------------
--
hr_utility.set_location('pay_ca_user_init_earn.create_user_init_earning',6);
--
select element_type_id, object_version_number
into   l_element_type_id, l_ele_obj_ver_number
from   pay_shadow_element_types
where  template_id = l_template_id
and    element_name = p_ele_name;
--
-- NTG elements do not have SF nor SI elements.
--

if p_ele_calc_rule_code <> 'NTG FLT' then
  select element_type_id, object_version_number
  into   l_sf_element_type_id, l_sf_ele_obj_ver_number
  from   pay_shadow_element_types
  where  template_id = l_template_id
  and    element_name = p_ele_name||' Special Features';
end if;
--
if (p_ele_processing_type = 'R') and (p_ele_calc_rule_code <> 'NTG FLT') then
   select element_type_id, object_version_number
   into   l_si_element_type_id, l_si_ele_obj_ver_number
   from   pay_shadow_element_types
   where  template_id = l_template_id
   and    element_name = p_ele_name||' Special Inputs';
end if;
--
---------------------------- Update Shadow Structure ----------------------
--
hr_utility.set_location('pay_ca_user_init_earn.create_user_init_earning',7);
--
  SELECT
  DECODE(p_ele_classification,'Earnings','DE',
      'Supplemental Earnings','DE','Taxable Benefits','DE','')
   INTO l_roe_allocation_by
  FROM dual;
--
  SELECT
  DECODE(p_ele_classification,
        'Earnings',nvl(p_ele_category, hr_api.g_varchar2),
        'Supplemental Earnings',nvl(p_ele_category, hr_api.g_varchar2),
        'Taxable Benefits',nvl(p_ele_category, hr_api.g_varchar2),
        '')
   INTO l_sf_ele_category
  FROM dual;
--
  SELECT
  DECODE(p_ele_classification,
    'Earnings', nvl(upper(g_template_leg_code||'_'||p_ele_classification), hr_api.g_varchar2),
    'Supplemental Earnings', nvl(upper(g_template_leg_code||'_'||p_ele_classification), hr_api.g_varchar2),
    'Taxable Benefits', nvl(upper(g_template_leg_code||'_'||p_ele_classification), hr_api.g_varchar2),
     '')
   INTO l_sf_ele_info_category
  FROM dual;
--
-- Update user-specified Classification, Category,
-- Processing Type and Standard Link.
--
pay_shadow_element_api.update_shadow_element
  (p_validate                =>   false
  ,p_effective_date          =>   p_ele_eff_start_date
  ,p_element_type_id         =>   l_element_type_id
  ,p_classification_name     =>   nvl(p_ele_classification, hr_api.g_varchar2)
  ,p_post_termination_rule   =>   p_termination_rule -- bug 8491239
  ,p_processing_type         =>   nvl(p_ele_processing_type, hr_api.g_varchar2)
  ,p_standard_link_flag      =>   nvl(p_ele_standard_link, hr_api.g_varchar2)
  ,p_description             =>   p_ele_description
  ,p_reporting_name          =>   p_ele_reporting_name
  ,p_element_information_category    =>   nvl(upper(g_template_leg_code||'_'||p_ele_classification), hr_api.g_varchar2)
  ,p_element_information1    =>   nvl(p_ele_category, hr_api.g_varchar2)
  ,p_element_information2    =>  p_ele_calc_method
  ,p_element_information4    =>  p_ele_eoy_type
  ,p_element_information18    =>  p_ele_t4a_footnote
  ,p_element_information19    =>  p_ele_rl1_footnote
  ,p_element_information20    =>  p_ele_registration_number
--  ,p_element_information10   =>   l_pri_bal_id
--  ,p_element_information12   =>   l_hrs_bal_id
  ,p_skip_formula	     =>   l_skip_formula
  ,p_object_version_number   =>   l_ele_obj_ver_number);
--
-- Update user-specified Classification on Special Features Element.
-- Only for Non NTG elements.
--
hr_utility.set_location('pay_ca_user_init_earn.create_user_init_earning',8);
--
if p_ele_calc_rule_code <> 'NTG FLT' then
  pay_shadow_element_api.update_shadow_element
    (p_validate                =>   false
    ,p_effective_date          =>   p_ele_eff_start_date
    ,p_element_type_id         =>   l_sf_element_type_id
    ,p_classification_name     =>   nvl(p_ele_classification, hr_api.g_varchar2)
    ,p_post_termination_rule   =>   p_termination_rule -- bug 8491239
    ,p_element_information_category => l_sf_ele_info_category
    ,p_reporting_name          =>   p_ele_reporting_name||' SF'
    ,p_element_information1    =>   l_sf_ele_category
    ,p_element_information3    =>   l_roe_allocation_by
    ,p_object_version_number   =>   l_sf_ele_obj_ver_number);
end if;
--
--
-- Update user-specified Classification Special Inputs if it exists.
-- Only for Non NTG elements.
--
hr_utility.set_location('pay_ca_user_init_earn.create_user_init_earning',9);
--
if (p_ele_processing_type = 'R') and (p_ele_calc_rule_code <> 'NTG FLT') then
   pay_shadow_element_api.update_shadow_element
     (p_validate                => false
     ,p_effective_date          => p_ele_eff_start_date
     ,p_element_type_id         => l_si_element_type_id
     ,p_classification_name     => nvl(p_ele_classification, hr_api.g_varchar2)
     ,p_post_termination_rule   =>   p_termination_rule -- bug 8491239
     ,p_reporting_name          =>   p_ele_reporting_name||' SI'
     ,p_object_version_number   => l_si_ele_obj_ver_number);
end if;
--
---------------------------- Generate Core Objects ------------------------
--
hr_utility.set_location('pay_ca_user_init_earn.create_user_init_earning',10);
--
if chk_ca_pay_installed = 'Y' then
   l_hr_only := FALSE;
else
   l_hr_only := TRUE;
end if;
--
hr_utility.trace('HR ONLY is :'||chk_ca_pay_installed);
--
pay_element_template_api.generate_part1
  (p_validate                      =>     false
  ,p_effective_date                =>     p_ele_eff_start_date
  ,p_hr_only                       =>     l_hr_only
  ,p_hr_to_payroll                 =>     false
  ,p_template_id                   =>     l_template_id);
--
hr_utility.set_location('pay_ca_user_init_earn.create_user_init_earning',11);
--
if l_hr_only = FALSE then
   pay_element_template_api.generate_part2
     (p_validate                      =>     false
     ,p_effective_date                =>     p_ele_eff_start_date
     ,p_template_id                   =>     l_template_id);
   --
   hr_utility.set_location('pay_ca_user_init_earn.create_user_init_earning',12);
   --
end if;
--
-------------------- Get Element Type ID of Base Element ------------------
--
hr_utility.set_location('pay_ca_user_init_earn.create_user_init_earning',13);
--
select element_type_id
into   l_base_element_type_id
from   pay_element_types_f
where  element_name = p_ele_name
and    business_group_id + 0 = p_bg_id;

/* Create formula result rules ELEMENT_TYPE_ID_PASSED,HOURS_PASSED and
   RATE_PASSED only if the element has a calculation rule of hours time rate */

if p_ele_calc_rule_code = 'HXR' and nvl(p_reduce_regular,'N') <> 'Y' then

     open cur_processing_rule_exists(l_base_element_type_id);
     fetch cur_processing_rule_exists INTO lv_proc_rule_id;
     if cur_processing_rule_exists%found then
        close cur_processing_rule_exists;
     else
        hr_utility.trace('Processing rule: '||p_ele_name|| ' does not exist');
     end if;

     open  cur_element_type_id(lv_element_name);
     fetch cur_element_type_id into lv_element_type_id;
     close cur_element_type_id;

     lv_input_value_name := 'Element Type Id';
     lv_result_name      := 'ELEMENT_TYPE_ID_PASSED';
     open  cur_input_id(lv_element_name, lv_input_value_name);
     fetch cur_input_id into lv_input_value_id;
     close cur_input_id;

hr_utility.trace(to_char(lv_element_type_id)||' '||to_char(lv_input_value_id));

       lv_formula_result_rule_id :=
                pay_formula_results.ins_form_res_rule(
                p_business_group_id         => p_bg_id,
                p_legislation_code          => NULL,
                p_legislation_subgroup      => NULL,
                p_effective_start_date      => fnd_date.canonical_to_date(
                                               '1901/01/01'),
                p_effective_end_date        => fnd_date.canonical_to_date(
                                               '4712/12/31'),
                p_status_processing_rule_id => lv_proc_rule_id,
                p_input_value_id            => lv_input_value_id,
                p_result_name               => lv_result_name,
                p_result_rule_type          => 'I',
                p_severity_level            => NULL,
                p_element_type_id           => lv_element_type_id);

              hr_utility.trace('Creating Result Rule: '|| lv_result_name);

     lv_input_value_name := 'Hours';
     lv_result_name      := 'HOURS_PASSED';
     open  cur_input_id(lv_element_name, lv_input_value_name);
     fetch cur_input_id into lv_input_value_id;
     close cur_input_id;

       lv_formula_result_rule_id :=
                pay_formula_results.ins_form_res_rule(
                p_business_group_id         => p_bg_id,
                p_legislation_code          => NULL,
                p_legislation_subgroup      => NULL,
                p_effective_start_date      => fnd_date.canonical_to_date(
                                               '1901/01/01'),
                p_effective_end_date        => fnd_date.canonical_to_date(
                                               '4712/12/31'),
                p_status_processing_rule_id => lv_proc_rule_id,
                p_input_value_id            => lv_input_value_id,
                p_result_name               => lv_result_name,
                p_result_rule_type          => 'I',
                p_severity_level            => NULL,
                p_element_type_id           => lv_element_type_id);

              hr_utility.trace('Creating Result Rule: '|| lv_result_name);

     lv_input_value_name := 'Rate';
     lv_result_name      := 'RATE_PASSED';
     open  cur_input_id(lv_element_name, lv_input_value_name);
     fetch cur_input_id into lv_input_value_id;
     close cur_input_id;

       lv_formula_result_rule_id :=
                pay_formula_results.ins_form_res_rule(
                p_business_group_id         => p_bg_id,
                p_legislation_code          => NULL,
                p_legislation_subgroup      => NULL,
                p_effective_start_date      => fnd_date.canonical_to_date(
                                               '1901/01/01'),
                p_effective_end_date        => fnd_date.canonical_to_date(
                                               '4712/12/31'),
                p_status_processing_rule_id => lv_proc_rule_id,
                p_input_value_id            => lv_input_value_id,
                p_result_name               => lv_result_name,
                p_result_rule_type          => 'I',
                p_severity_level            => NULL,
                p_element_type_id           => lv_element_type_id);

              hr_utility.trace('Creating Result Rule: '|| lv_result_name);

     lv_input_value_name := 'Multiple';
     lv_result_name      := 'MULTIPLE_PASSED';
     open  cur_input_id(lv_element_name, lv_input_value_name);
     fetch cur_input_id into lv_input_value_id;
     close cur_input_id;

       lv_formula_result_rule_id :=
                pay_formula_results.ins_form_res_rule(
                p_business_group_id         => p_bg_id,
                p_legislation_code          => NULL,
                p_legislation_subgroup      => NULL,
                p_effective_start_date      => fnd_date.canonical_to_date(
                                               '1901/01/01'),
                p_effective_end_date        => fnd_date.canonical_to_date(
                                               '4712/12/31'),
                p_status_processing_rule_id => lv_proc_rule_id,
                p_input_value_id            => lv_input_value_id,
                p_result_name               => lv_result_name,
                p_result_rule_type          => 'I',
                p_severity_level            => NULL,
                p_element_type_id           => lv_element_type_id);

     lv_input_value_name := 'Pay Value';
     lv_result_name      := 'EARNINGS_AMOUNT';
     open  cur_input_id(lv_element_name, lv_input_value_name);
     fetch cur_input_id into lv_input_value_id;
     close cur_input_id;

       lv_formula_result_rule_id :=
                pay_formula_results.ins_form_res_rule(
                p_business_group_id         => p_bg_id,
                p_legislation_code          => NULL,
                p_legislation_subgroup      => NULL,
                p_effective_start_date      => fnd_date.canonical_to_date(
                                               '1901/01/01'),
                p_effective_end_date        => fnd_date.canonical_to_date(
                                               '4712/12/31'),
                p_status_processing_rule_id => lv_proc_rule_id,
                p_input_value_id            => lv_input_value_id,
                p_result_name               => lv_result_name,
                p_result_rule_type          => 'I',
                p_severity_level            => NULL,
                p_element_type_id           => lv_element_type_id);

              hr_utility.trace('Creating Result Rule: '|| lv_result_name);

end if;
--
------------------ Get Balance Type IDs to update Flex Info ---------------
--
hr_utility.set_location('pay_ca_user_init_earn.create_user_init_earning',14);
--
BEGIN
select ptco.core_object_id
into   l_pri_bal_id
from   pay_shadow_balance_types psbt,
       pay_template_core_objects ptco
where  psbt.template_id = l_template_id
and    psbt.balance_name = p_ele_name
and    ptco.template_id = psbt.template_id
and    ptco.shadow_object_id = psbt.balance_type_id;
--
EXCEPTION WHEN NO_DATA_FOUND THEN
  --
  -- Is this NTG element?
  -- NTG template does not have record in pay_template_core_objects.
  --
 IF p_ele_calc_rule_code = 'NTG FLT' then
   select balance_type_id
     into l_pri_bal_id
     from pay_shadow_balance_types
    where template_id = l_template_id
      and balance_name = p_ele_name;
 ELSE
   NULL;
 END IF;
END;
--
hr_utility.set_location('pay_ca_user_init_earn.create_user_init_earning',15);
--
BEGIN
select ptco.core_object_id
into   l_hrs_bal_id
from   pay_shadow_balance_types psbt,
       pay_template_core_objects ptco
where  psbt.template_id = l_template_id
and    psbt.balance_name = p_ele_name||' Hours'
and    ptco.template_id = psbt.template_id
and    ptco.shadow_object_id = psbt.balance_type_id;
--
hr_utility.set_location('pay_ca_user_init_earn.create_user_init_earning',16);
--
EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
END;
--
hr_utility.set_location('pay_ca_user_init_earn.create_user_init_earning',17);
--
if (p_sep_check_option = 'N' and p_ele_calc_rule_code <> 'NTG FLT') then
  update pay_element_types_f
  set    element_information10 = l_pri_bal_id,
         element_information12 = l_hrs_bal_id,
         process_mode          = decode(l_sep_check_create,'Y','S','N')
  where  element_type_id = l_base_element_type_id
    and    business_group_id + 0 = p_bg_id;
elsif (p_sep_check_option = 'N' and p_ele_calc_rule_code = 'NTG FLT') then
  update pay_element_types_f
  set    element_information10 = l_pri_bal_id,
         element_information12 = l_hrs_bal_id,
         process_mode          = 'P'
  where  element_type_id = l_base_element_type_id
  and    business_group_id + 0 = p_bg_id;
--
elsif (p_sep_check_option = 'Y') then
  update pay_element_types_f
  set    element_information10 = l_pri_bal_id,
         element_information12 = l_hrs_bal_id,
         process_mode          = 'S'
  where  element_type_id = l_base_element_type_id
  and    business_group_id + 0 = p_bg_id;
--
end if;

FOR dim IN get_asg_gre_run_dim_id LOOP
   l_asg_gre_run_dim_id := dim.balance_dimension_id;
END LOOP;

FOR dim IN get_asg_jd_gre_run_dim_id LOOP
   l_asg_jd_gre_run_dim_id := dim.balance_dimension_id;
END LOOP;

UPDATE pay_defined_balances
SET save_run_balance    = 'Y'
WHERE balance_type_id   = l_pri_bal_id
AND   balance_dimension_id IN
                  (l_asg_gre_run_dim_id,
                   l_asg_jd_gre_run_dim_id)
AND   business_group_id = p_bg_id;

/* Fix for Bug#2219028, setting the termination rule to 'Last Standard
   Process Date' for all Recurring Elements */

  If p_ele_processing_type = 'R' then

       update pay_element_types_f
       set post_termination_rule = p_termination_rule -- Bug 2646705
       where  element_type_id = l_base_element_type_id
       and    business_group_id + 0 = p_bg_id;

  End if;
/* End of bug fix#2219028 */
--
--
-- Added update for jurisdiction level, this needs to be set for all balances
-- to '2'. This is currently a hardcoded update to base table as the balance
-- apis do not support jurisdiction_level.
--
update_jd_level_on_balance(l_template_id);
--
-- Added NTG specific updates.
--
IF p_ele_calc_rule_code = 'NTG FLT' then
  update_ntg_element(l_base_element_type_id,
                     p_ele_eff_start_date,
                     p_bg_id);
END IF;
--
--
/* Defaulting Values for Regular Earnings Adjustment Rule.
   Bug #1588225 */
/* Changed the defaulting of Earnings to A from T, bugfix #2402284 */
if p_ele_classification in ('Supplemental Earnings','Earnings') then
/*   if p_ele_calc_rule_code = 'HXR'  then */
    if nvl(p_reduce_regular,'N') <> 'Y' then

     if p_ele_classification = 'Earnings' then
       update pay_element_types_f
       set    element_information9 = 'A'
        where  element_type_id = l_base_element_type_id
        and    business_group_id + 0 = p_bg_id;
     elsif p_ele_classification = 'Supplemental Earnings' then
       update pay_element_types_f
       set    element_information9 = 'A'
        where  element_type_id = l_base_element_type_id
        and    business_group_id + 0 = p_bg_id;
     end if;

    elsif nvl(p_reduce_regular,'N') = 'Y' then
     update pay_element_types_f
     set    element_information9 = 'R'
     where  element_type_id = l_base_element_type_id
     and    business_group_id + 0 = p_bg_id;
   end if;
/*  end if; */
end if;

--
-- Updating element_information3 of the Base Element
-- to 'DE'(Date Earned') for Elements of Classification
-- 'Earnings','Supplemental Earnings','Taxable Benefits'.
--
  IF p_ele_classification in
      ('Supplemental Earnings','Earnings','Taxable Benefits') then
    UPDATE pay_element_types_f
    SET    element_information3 = 'DE'
    WHERE  element_type_id = l_base_element_type_id
    AND    business_group_id + 0 = p_bg_id;
  END IF;
--

--
-- Creating element type usages for exclusion
--

begin
  --hr_utility.trace_on(null,'ELEMENT');
  for etu in c_ele_tp_usg(p_bg_id, p_ele_name)
  loop

    hr_utility.trace('etu.element_name : '||etu.element_name);
    hr_utility.trace('p_ele_name : '||p_ele_name);
    hr_utility.trace('etu.element_information2 : '||etu.element_information2);
    hr_utility.trace('etu.element_information4 : '||etu.element_information4);

    if etu.element_name = p_ele_name then

       if p_ele_classification = 'Non-payroll Payments' then
          if etu.element_information4 is not null then
             select 'REG_' ||
                    replace(etu.element_information4,'/','_') earn_shortname
             into   lv_earn_shortname
             from   dual;
          else
             lv_earn_shortname := 'REG_T4_RL1';
          end if;
       else
          select decode(etu.element_information2, 'R','REG_',
                                                  'N','NP_',
                                                  'L','LS_', NULL)||
                 replace(etu.element_information4,'/','_') earn_shortname
          into   lv_earn_shortname
          from   dual;
       end if;

    end if;
    hr_utility.trace('ln_run_type_id : '||ln_run_type_id);

    for prt in c_run_tp
    loop

       if instr(prt.shortname, lv_earn_shortname) > 0 then
          lv_inclusion_flag := 'N';
          lv_usage_type     := 'T';
       else
          lv_inclusion_flag := 'N';
          lv_usage_type     := NULL;
       end if;

       pay_element_type_usage_api.create_element_type_usage(
                 p_effective_date        => etu.effective_start_date
                ,p_run_type_id           => prt.run_type_id
                ,p_element_type_id       => etu.element_type_id
                ,p_business_group_id     => etu.business_group_id
                ,p_legislation_code      => etu.legislation_code
                ,p_usage_type            => lv_usage_type
                ,p_inclusion_flag        => lv_inclusion_flag
                ,p_element_type_usage_id => ln_element_type_usage_id
                ,p_object_version_number => ln_object_version_number
                ,p_effective_start_date  => ld_effective_start_date
                ,p_effective_end_date    => ld_effective_end_date);


      end loop; -- cursor c_run_tp run_types

  end loop; -- cursor c_ele_tp_usg element_type_usages

  exception
  when others then
  null;
end;

begin
/* Bugfix : 2851568. Feed Taxable Benefits for Quebec for all Taxable
Benefits Element with Category PHSP */

    hr_utility.trace('1 element type id is '||to_char(l_element_type_id));

select element_type_id
into   l_element_type_id
from   pay_element_types_f
where  business_group_id = p_bg_id
and    element_name = p_ele_name;

     lv_input_value_name := 'Pay Value';
     open  cur_input_id2(l_base_element_type_id, lv_input_value_name);
     fetch cur_input_id2 into l_pay_value_iv_id;
     close cur_input_id2;

    hr_utility.trace('2');
-- if p_ele_category = 'Private Health Services Plan' then
 if p_ele_category = 'PHSP' then
    hr_utility.trace('3 input value id ' || to_char(l_pay_value_iv_id));


select balance_type_id
into l_balance_type_id
from pay_balance_types
where balance_name = 'Taxable Benefits for Quebec';

pay_balance_feeds_f_pkg.insert_row (l_balance_row_id,
                                    l_balance_feed_id,
				    p_ele_eff_start_date,
				    p_ele_eff_end_date,
			            p_bg_id,
				    'CA',
				    l_balance_type_id,
				    l_pay_value_iv_id,
				    '1',
				    NULL);

    hr_utility.trace('4 input value id ' || to_char(l_balance_feed_id));
 end if;
  exception
  when others then
    hr_utility.trace('5');
  null;
end;
hr_utility.trace_off;
--
--

------------------ Conclude Create_User_Init_Earning Main -----------------
--
hr_utility.set_location('pay_ca_user_init_earn.create_user_init_earning',18);
--
RETURN l_base_element_type_id;
--
END create_user_init_earning;
--
--
------------------------- Deletion procedures -----------------------------
--
PROCEDURE delete_user_init_earning (
			p_business_group_id	in number,
			p_ele_type_id		in number,
			p_ele_name		in varchar2,
			p_del_sess_date		in date,
			p_del_val_start_date	in date,
			p_del_val_end_date	in date) IS
-- local constants
c_end_of_time  CONSTANT DATE := TO_DATE('4712/12/31','YYYY/MM/DD');

-- local vars
l_del_sess_date DATE 		:= NULL;
l_del_val_start DATE 		:= NULL;
l_del_val_end	DATE 		:= NULL;

l_template_id   NUMBER(9);
--
BEGIN
-- Populate vars.
l_del_val_end	 	:= nvl(p_del_val_end_date, c_end_of_time);
l_del_val_start 	:= nvl(p_del_val_start_date, sysdate);
l_del_sess_date 	:= nvl(p_del_sess_date, sysdate);
--
hr_utility.set_location('pay_ca_user_init_earn.delete_user_init_earning',1);
--
select template_id
into   l_template_id
from   pay_element_templates
where  base_name = p_ele_name
and    business_group_id = p_business_group_id
and    template_type = 'U';
--
hr_utility.set_location('pay_ca_user_init_earn.delete_user_init_earning',2);
--
  begin
    delete from pay_element_type_usages_f
    where element_type_id in ( select element_type_id
                               from   pay_element_types_f
                               where ( element_name = p_ele_name or
                                       element_name =
                                              p_ele_name ||' Special Inputs' )
                               and    business_group_id = p_business_group_id );
    --
    hr_utility.set_location('pay_ca_user_init_earn.delete_user_init_earning',3);
    --
    exception
    when others then
    null;
  end;

pay_element_template_api.delete_user_structure
  (p_validate                      =>     false
  ,p_drop_formula_packages         =>     true
  ,p_template_id                   =>     l_template_id);
--
hr_utility.set_location('pay_ca_user_init_earn.delete_user_init_earning',4);
--
END delete_user_init_earning;
------------------------------------------------------------------------
-- PROCEDURE UPDATE_JD_LEVEL_ON_BALANCE
-- Update for jurisdiction level, this needs to be set for all balances
-- to '2'. This is currently a hardcoded update to base table as the balance
-- apis do not support jurisdiction_level.
------------------------------------------------------------------------
PROCEDURE UPDATE_JD_LEVEL_ON_BALANCE(p_template_id in number) is
--
CURSOR get_balance_type_ids(p_template_id number) IS
select ptco.core_object_id
from   pay_template_core_objects ptco
where  ptco.template_id = p_template_id
and    ptco.core_object_type = 'BT';
--
BEGIN
--
FOR each_balance in get_balance_type_ids(p_template_id) LOOP
--
  UPDATE pay_balance_types
  SET    jurisdiction_level = 2
  WHERE  balance_type_id = each_balance.core_object_id;
  --
END LOOP;
--
END UPDATE_JD_LEVEL_ON_BALANCE;
------------------------------------------------------------------------
PROCEDURE update_ntg_element(p_base_element_type_id in NUMBER,
                             p_ele_eff_start_date in DATE,
                             p_bg_id in NUMBER) IS
--
  CURSOR c_iter_formula_id IS
  SELECT formula_id
    FROM ff_formulas_f
   WHERE formula_name = 'CA_ITER_GROSSUP'
     and legislation_code = 'CA';

  CURSOR c_input_value_id IS
  SELECT input_value_id, name
    FROM pay_input_values_f
   WHERE element_type_id = p_base_element_type_id;

  CURSOR c_seeded_elmt_id IS
  SELECT element_type_id
    FROM pay_element_types_f
   WHERE upper(element_name) = 'FED_GROSSUP_ADJUSTMENT'
     AND legislation_code = 'CA';

  CURSOR c_seeded_elmt_iv_id(p_seed_ele_type_id number) IS
  SELECT input_value_id
    FROM pay_input_values_f
   WHERE element_type_id = p_seed_ele_type_id
     AND upper(name) = 'AMOUNT';

  CURSOR c_base_elmt_spr_id IS
  SELECT status_processing_rule_id
    FROM pay_status_processing_rules_f
   WHERE element_type_id = p_base_element_type_id;

  l_iter_formula_id     NUMBER;
  l_iter_rule_id        NUMBER;
  l_iter_rule_ovn       NUMBER;
  l_effective_start_date DATE;
  l_effective_end_date   DATE;
  l_insert              VARCHAR2(1) := 'N';
  l_result_name         VARCHAR2(20);
  l_iterative_rule_type VARCHAR2(1);
  l_iv_id               NUMBER;
  l_seeded_ele_type_id  NUMBER;
  l_nextval             NUMBER;
  l_seeded_input_val_id NUMBER;
  l_status_pro_rule_id  NUMBER;
  l_proc       VARCHAR2(50) := 'pay_ca_user_init_earn.update_ntg_element';

BEGIN
--
OPEN c_iter_formula_id;
FETCH c_iter_formula_id into l_iter_formula_id;
  IF c_iter_formula_id%NOTFOUND then
      hr_utility.set_location(l_proc,10);
      hr_utility.set_message(800,'ITERATIVE FORMULA NOT FOUND');
      hr_utility.raise_error;
  END IF;
CLOSE c_iter_formula_id;
-------------------------
-- Set iterative formula.
-------------------------
UPDATE pay_element_types_f
 SET    iterative_formula_id  = l_iter_formula_id,
        iterative_flag        = 'Y',
        grossup_flag          = 'Y'
 WHERE  element_type_id       = p_base_element_type_id
   AND  business_group_id + 0 = p_bg_id;
--
 hr_utility.set_location(l_proc,20);
--
---------------------------------
-- Set iterative processing rules
---------------------------------
FOR c_iv_rec in c_input_value_id LOOP
   IF     c_iv_rec.name = 'Additional Amount'
   then   l_result_name := 'ADDITIONAL_AMOUNT';
          l_iterative_rule_type := 'A';
          l_iv_id := c_iv_rec.input_value_id;
          l_insert := 'Y';

   elsif  c_iv_rec.name = 'Low Gross'
   then l_result_name := 'LOW_GROSS';
        l_iterative_rule_type := 'A';
        l_iv_id := c_iv_rec.input_value_id;
        l_insert := 'Y';

   elsif  c_iv_rec.name = 'High Gross'
   then l_result_name := 'HIGH_GROSS';
        l_iterative_rule_type := 'A';
        l_iv_id := c_iv_rec.input_value_id;
        l_insert := 'Y';

   elsif  c_iv_rec.name = 'Remainder'
   then l_result_name := 'REMAINDER';
        l_iterative_rule_type := 'A';
        l_iv_id := c_iv_rec.input_value_id;
        l_insert := 'Y';

   elsif c_iv_rec.name = 'Pay Value'
   -- Using any other Input Value to insert Stopper.
   then  l_result_name := 'STOPPER';
         l_iterative_rule_type := 'S';
         l_iv_id := NULL;
         l_insert := 'Y';
   END IF;
IF l_insert = 'Y' THEN
  hr_utility.set_location(l_proc,30);
     pay_iterative_rules_api.create_iterative_rule
           (
             p_effective_date        => p_ele_eff_start_date
            ,p_element_type_id       => p_base_element_type_id
            ,p_result_name           => l_result_name
            ,p_iterative_rule_type   => l_iterative_rule_type
            ,p_input_value_id        => l_iv_id
            ,p_severity_level        => NULL
            ,p_business_group_id     => p_bg_id
            ,p_legislation_code      => 'CA'
            ,p_iterative_rule_id     => l_iter_rule_id
            ,p_object_version_number => l_iter_rule_ovn
            ,p_effective_start_date  => l_effective_start_date
            ,p_effective_end_date    => l_effective_end_date
           );
END IF;
      l_insert := 'N';
END LOOP;
------------------------------------------------------------------
-- Amount(Desired NTG Amount) needs to feed the seeded element
-- FED_GROSSUP_ADJUSTMENT input value of Amount.
-- Thus need to get the element_type_id of the seeded element
-- and input_value_id of the Amount from the seeded element.
------------------------------------------------------------------
  hr_utility.set_location(l_proc,40);
--
OPEN c_seeded_elmt_id;
FETCH c_seeded_elmt_id into l_seeded_ele_type_id;
IF c_seeded_elmt_id%NOTFOUND then
  hr_utility.set_location(l_proc,45);
  hr_utility.set_message(800,'FED_GROSSUP_ADJUSTMENT NOT FOUND');
  hr_utility.raise_error;
END IF;
CLOSE c_seeded_elmt_id;
--
  hr_utility.set_location(l_proc,41);
--
OPEN c_seeded_elmt_iv_id(l_seeded_ele_type_id);
FETCH c_seeded_elmt_iv_id into l_seeded_input_val_id;
IF c_seeded_elmt_iv_id%NOTFOUND then
  hr_utility.set_location(l_proc,47);
  hr_utility.set_message(800,'INPUT VALUE NOT FOUND');
  hr_utility.raise_error;
END IF;
CLOSE c_seeded_elmt_iv_id;
--
  hr_utility.set_location(l_proc,42);
--
SELECT pay_formula_result_rules_s.nextval
  INTO l_nextval
  FROM dual;
--
  hr_utility.set_location(l_proc,43);
--
OPEN c_base_elmt_spr_id;
FETCH c_base_elmt_spr_id into l_status_pro_rule_id;
IF c_base_elmt_spr_id%NOTFOUND then
  hr_utility.set_location(l_proc,49);
  hr_utility.set_message(800,'STATUS PROC RULE NOT FOUND');
  hr_utility.raise_error;
END IF;
CLOSE c_base_elmt_spr_id;
--
  hr_utility.set_location(l_proc,50);
--
INSERT INTO PAY_FORMULA_RESULT_RULES_F
        (formula_result_rule_id,
         effective_start_date,
         effective_end_date,
         business_group_id,
         legislation_code,
         element_type_id,
         status_processing_rule_id,
         result_name,
         result_rule_type,
         input_value_id,
         last_update_date,
         last_updated_by,
         last_update_login,
         created_by,
         creation_date)
VALUES
        (l_nextval,
         trunc(TO_DATE('0001/01/01', 'YYYY/MM/DD')),
         trunc(TO_DATE('4712/12/31', 'YYYY/MM/DD')),
         p_bg_id,
         'CA',
         l_seeded_ele_type_id,
         l_status_pro_rule_id,
         'AMOUNT',
         'I',
         l_seeded_input_val_id,
         sysdate,
         -1,
         -1,
         -1,
         sysdate);
END update_ntg_element;

END pay_ca_user_init_earn;

/
