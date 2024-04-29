--------------------------------------------------------
--  DDL for Package Body PAY_CA_USER_INIT_DEDN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_USER_INIT_DEDN" AS
/* $Header: pycauidt.pkb 120.0.12010000.3 2009/05/18 11:44:52 sapalani ship $ */
/*
*/
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

    Name        : pay_ca_user_init_dedn
    Filename	: pycauidt.pkb
    Change List
    -----------
 Date        Name      	 Vers    Bug No  Description
 ----        ----      	 ----    ------  -----------
 10-NOV-98   R.Murthy    115.0           First Created.
 27-APR-99   M.Mukherjee                 Passed the paramether p_description
                                         to update_shadow_element procedure
 07-JUN-99   R. Murthy   115.4           Created exclusion rule for start
                                         rule - if it is 'Earnings Threshold',
                                         the template engine creates the input
                                         value 'Threshold Amount', and the
                                         element uses the skip rule
                                         'THRESHOLD_SKIP_RULE'.
                                         Update shadow structure also updates
                                         the user-entered element reporting
                                         name and benefit classification.
                                         Added a check to see if the element
                                         being created has the same name as
                                         that of an existing balance (seeded or
                                         otherwise).  If yes, an error is
                                         raised.  This prevents users from
                                         creating elements with reserved
                                         words as names.
 05-APR-00   RThirlby   115.6            Added call to new procedure
                                         pay_ca_user_init_earn.update_jd_level-
                                         _on_balance. This updates jurisdiction_
                                         level on pay_balance_types for all
                                         balances. Call added to create user-
                                         _init_deduction. NB. THIS WILL NEED TO
                                         BE ADDED TO CREATE_USER_INIT_GARNISH-
                                         MENT WHEN GARNISHMENTS ARE ADDED TO
                                         R11i.
 11-APR-00   ACai       115.7            Replaced the code with Ver. 110.14 to                                           include garnishment process for R11i.

 11-APR-00   mmukherj   115.8            Added update and insert of footnote
                                         and registration no for Year end info
 11-APR-02   ssattini   115.9            Fixed the bug#2304888 and also
                                         also added dbdrv.
 11-APR-2002 SSattini   115.10           Corrected GSCC complaint.
 18-FEB-2003 vpandya    115.11 ,12       Creating element type usages for
                                         deduction elements which has tax proc
                                         type is 'Regular'.
 05-AUG-2003 ssouresr   115.13           Saving run balances for _GRE_RUN
                                         _GRE_JD_RUN, _ASG_GRE_RUN  and
                                         _ASG_JD_GRE_RUN on pay_defined_balances
 05-AUG-2003 ssouresr  115.14            Removed _GRE_RUN and _GRE_JD_RUN from
                                         previous change as these dimensions are
                                         not required for saving nonseeded
                                         balances
 26-SEP-2003 ssattini  115.15            Added update to set the
                                         post_termination_rule to 'Last
                                         Standard Process Date' for all
                                         recurring elements.  Fix for
                                         bug#2219028.
 18-MAY-2009 sapalani  115.16  5676728   Removed the skip formula
                                         FREQ_RULE_SKIP_FORMULA from
                                         deduction elements.
*/

--
--
----------------- create_element_type_usages -----------------
--
--

PROCEDURE create_element_type_usages (
                 p_element_name      in varchar2,
                 p_bg_id             in number,
                 p_ele_proc_run_type in varchar2 ) IS
cursor c_ele_tp_usg is
  select pet.element_type_id
         ,prt.run_type_id
         ,'N' inclusion_flag
         ,pet.effective_start_date
         ,pet.effective_end_date
         ,pet.legislation_code
         ,pet.business_group_id
         ,NULL usage_type
  from pay_element_types_f pet
      ,pay_run_types_f     prt
  where pet.element_name      = p_element_name
  and   pet.business_group_id = p_bg_id
  and   prt.legislation_code = 'CA'
  and ( prt.shortname like 'REG%' or
        prt.shortname like 'NP%' or
        prt.shortname like 'LS%' )
  and   prt.shortname <> 'REG_T4_RL1'
  and   prt.run_method = 'C'
  and   nvl(prt.srs_flag,'N') <> 'Y';

  ln_element_type_usage_id number;
  ln_object_version_number number;
  ld_effective_start_date  date;
  ld_effective_end_date    date;

BEGIN

  for etu in c_ele_tp_usg loop
       pay_element_type_usage_api.create_element_type_usage(
                 p_effective_date        => etu.effective_start_date
                ,p_run_type_id           => etu.run_type_id
                ,p_element_type_id       => etu.element_type_id
                ,p_business_group_id     => etu.business_group_id
                ,p_legislation_code      => etu.legislation_code
                ,p_usage_type            => etu.usage_type
                ,p_inclusion_flag        => etu.inclusion_flag
                ,p_element_type_usage_id => ln_element_type_usage_id
                ,p_object_version_number => ln_object_version_number
                ,p_effective_start_date  => ld_effective_start_date
                ,p_effective_end_date    => ld_effective_end_date);
  end loop;

  Exception
  when others then
  null;
END create_element_type_usages;
--
--
------------------------- create_user_init_deduction ----------------------------
--
FUNCTION create_user_init_deduction (
                p_ele_name              in varchar2,
                p_ele_reporting_name    in varchar2,
                p_ele_description       in varchar2     default NULL,
                p_ele_classification    in varchar2,
                p_ben_class_id          in number,
                p_ele_category          in varchar2     default NULL,
                p_ele_processing_type   in varchar2,
                p_ele_priority          in number       default NULL,
                p_ele_standard_link     in varchar2     default 'N',
                p_ele_proc_runtype      in varchar2,
                p_ele_start_rule        in varchar2,
                p_ele_stop_rule         in varchar2,
                p_ele_calc_rule         in varchar2,
                p_ele_calc_rule_code    in varchar2,
                p_ele_insuff_funds      in varchar2,
                p_ele_insuff_funds_code in varchar2,
                p_ele_t4a_footnote      in varchar2,
                p_ele_rl1_footnote      in varchar2,
                p_ele_registration_number in varchar2,
                p_ele_eff_start_date    in date         default NULL,
                p_ele_eff_end_date      in date         default NULL,
		p_bg_id			in number) RETURN NUMBER IS
--

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


-- global constants
c_end_of_time  CONSTANT DATE := TO_DATE('4712/12/31','YYYY/MM/DD');

-- global vars
g_eff_start_date  	DATE;
g_eff_end_date  	DATE;

-- local vars
l_hr_only               BOOLEAN;
l_reserved              VARCHAR2(1) := 'N';
l_source_template_id	NUMBER(9); -- Source Template ID.
l_template_id		NUMBER(9); -- Template ID.
l_object_version_number	NUMBER(9); -- Object Version Number
l_arrearage_create      VARCHAR2(1);
l_total_owed_create     VARCHAR2(1);
l_threshold_amt_create  VARCHAR2(1);

l_bg_name		VARCHAR2(60);	-- Get from bg short name passed in.
l_element_type_id	NUMBER(9); -- Get from pay_shadow_element_types
l_ele_obj_ver_number    NUMBER(9); -- Object Version Number
l_sf_element_type_id    NUMBER(9); -- Get from pay_shadow_element_types
l_sf_ele_obj_ver_number NUMBER(9); -- Object Version Number
l_si_element_type_id    NUMBER(9); -- Get from pay_shadow_element_types
l_si_ele_obj_ver_number NUMBER(9); -- Object Version Number
l_base_element_type_id	NUMBER(9); -- Populated by insertion of element type.

l_pri_bal_id		NUMBER(9); -- Get from pay_balance_types
l_accr_bal_id		NUMBER(9); -- Get from pay_balance_types
l_arr_bal_id		NUMBER(9); -- Get from pay_balance_types
l_not_taken_bal_id	NUMBER(9); -- Get from pay_balance_types
l_proc_run_type		VARCHAR2(30); -- User-specified

l_ele_repname		VARCHAR2(30);
l_ben_class_name	VARCHAR2(80);
l_skip_formula          VARCHAR2(80);
l_primary_class_id	NUMBER(9);
l_class_lo_priority	NUMBER(9);
l_class_hi_priority	NUMBER(9);

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
hr_utility.set_location('pay_ca_user_init_dedn.get_template_id',1);
--
if p_calc_rule_code = 'FLT' then
   l_template_name := 'Flat Amount Deduction';
   --l_template_name := 'Test Flat Amount Deductions';
elsif p_calc_rule_code = 'PCT' then
   l_template_name := 'Percent of Earnings Deduction';
else
   hr_utility.set_location('pay_ca_user_init_dedn.get_template_id',2);
   hr_utility.set_message(801,'HR_XXXXX_INVALID_CALC_RULE_DEDN');
   hr_utility.raise_error;
end if;
--
hr_utility.set_location('pay_ca_user_init_dedn.get_template_id',3);
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
hr_utility.set_location('pay_ca_user_init_dedn.get_template_id',4);
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
hr_utility.set_location('pay_ca_user_init_dedn.chk_ca_pay_installed',1);
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
hr_utility.set_location('pay_ca_user_init_dedn.chk_ca_pay_installed',2);
--
RETURN (l_installed);
--
END chk_ca_pay_installed;

--
--
------------------------ create_user_init_deduction Main --------------------
--
-- Main Procedure

BEGIN
--
-- hr_utility.trace_on('Y', 'RANJANA');
--
hr_utility.set_location('pay_ca_user_init_dedn.create_user_init_deduction',1);
--
-- Set session date
pay_db_pay_setup.set_session_date(nvl(p_ele_eff_start_date, sysdate));
--
g_eff_start_date 	:= NVL(p_ele_eff_start_date, sysdate);
g_eff_end_date		:= NVL(p_ele_eff_end_date, c_end_of_time);
--
hr_utility.set_location('pay_ca_user_init_dedn.create_user_init_deduction',2);
--
---------------------------- Check Element Name ---------------------------
--
hr_utility.set_location('pay_ca_user_init_earn.create_user_init_deduction',25);
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
   hr_utility.set_location('pay_ca_user_init_earn.create_user_init_deduction',26);
   hr_utility.set_message(801,'HR_7564_ALL_RES_WORDS');
   hr_utility.raise_error;
end if;
--
---------------------------- Get Source Template ID -----------------------
--
hr_utility.set_location('pay_ca_user_init_dedn.create_user_init_deduction',3);
--
l_source_template_id := get_template_id(
				 p_legislation_code => g_template_leg_code,
				 p_calc_rule_code   => p_ele_calc_rule_code);
--
------------------------ Set Arrearage Creation ---------------------------
--
hr_utility.set_location('pay_ca_user_init_dedn.create_user_init_deduction',4);
--
if p_ele_insuff_funds_code in ('A', 'APD') then
   l_arrearage_create := 'Y';
else
   l_arrearage_create := 'N';
end if;
--
------------------------ Set Total Owed Creation --------------------------
--
hr_utility.set_location('pay_ca_user_init_dedn.create_user_init_deduction',5);
--
if UPPER(p_ele_stop_rule) = 'TOTAL REACHED' then
   l_total_owed_create := 'Y';
else
   l_total_owed_create := 'N';
end if;
--
if UPPER(p_ele_start_rule) = 'ET' then
   l_threshold_amt_create := 'Y';
   l_skip_formula     := 'THRESHOLD_SKIP_FORMULA';
else
   l_threshold_amt_create := 'N';
   l_skip_formula     := null; --'FREQ_RULE_SKIP_FORMULA';  --Bug 5676728
end if;
--
---------------------------- Create User Structure ------------------------
--
hr_utility.set_location('pay_ca_user_init_dedn.create_user_init_deduction',6);
--
-- The Configuration Flex segments are as follows:
-- Config 1 - exclusion rule - create Arrearage related structures if 'Y'
-- Config 2 - exclusion rule - create Total Owed related structures if 'Y'
-- Config 3 - exclusion rule - create SI and SF elements if 'R', no if 'N'
-- Config 4 - exclusion rule - create Earnings Threshold Input Value if 'Y'
--
pay_element_template_api.create_user_structure
  (p_validate                      =>     false
  ,p_effective_date                =>     p_ele_eff_start_date
  ,p_business_group_id             =>     p_bg_id
  ,p_source_template_id            =>     l_source_template_id
  ,p_base_name                     =>     p_ele_name
  ,p_base_processing_priority      =>     p_ele_priority
  ,p_configuration_information1    =>     l_arrearage_create
  ,p_configuration_information2    =>     l_total_owed_create
  ,p_configuration_information3    =>     p_ele_processing_type
  ,p_configuration_information4    =>     l_threshold_amt_create
  ,p_template_id                   =>     l_template_id
  ,p_object_version_number         =>     l_object_version_number);
--
---------------------- Get Element Type ID of new Template-----------------
--
hr_utility.set_location('pay_ca_user_init_dedn.create_user_init_deduction',7);
--
select element_type_id, object_version_number
into   l_element_type_id, l_ele_obj_ver_number
from   pay_shadow_element_types
where  template_id = l_template_id
and    element_name = p_ele_name;
--
select element_type_id, object_version_number
into   l_sf_element_type_id, l_sf_ele_obj_ver_number
from   pay_shadow_element_types
where  template_id = l_template_id
and    element_name = p_ele_name||' Special Features';
--
if p_ele_processing_type = 'R' then
   select element_type_id, object_version_number
   into   l_si_element_type_id, l_si_ele_obj_ver_number
   from   pay_shadow_element_types
   where  template_id = l_template_id
   and    element_name = p_ele_name||' Special Inputs';
end if;
--
---------------------------- Update Shadow Structure ----------------------
--
hr_utility.set_location('pay_ca_user_init_dedn.create_user_init_deduction',8);
--
if p_ben_class_id IS NOT NULL then
   select benefit_classification_name
   into   l_ben_class_name
   from   ben_benefit_classifications
   where  benefit_classification_id = p_ben_class_id;
end if;
--
-- Update user-specified Classification, Processing Type and Standard Link.
--
pay_shadow_element_api.update_shadow_element
  (p_validate                =>  false
  ,p_effective_date          =>  p_ele_eff_start_date
  ,p_element_type_id         =>  l_element_type_id
  ,p_classification_name     =>  nvl(p_ele_classification, hr_api.g_varchar2)
  ,p_processing_type         =>  nvl(p_ele_processing_type, hr_api.g_varchar2)
  ,p_standard_link_flag      =>  nvl(p_ele_standard_link, hr_api.g_varchar2)
  ,p_description             =>  p_ele_description
  ,p_reporting_name	     =>  p_ele_reporting_name
  ,p_benefit_classification_name => l_ben_class_name
  ,p_element_information_category    =>   nvl(upper(g_template_leg_code||'_'||p_ele_classification), hr_api.g_varchar2)
  ,p_element_information1    =>  nvl(p_ele_category, hr_api.g_varchar2)
  ,p_element_information2    =>  nvl(p_ele_insuff_funds_code, hr_api.g_varchar2)
  ,p_element_information3    =>  nvl(p_ele_proc_runtype, hr_api.g_varchar2)
--  ,p_element_information18   =>  nvl(p_ele_t4a_footnote, hr_api.g_varchar2)
--  ,p_element_information19   =>  nvl(p_ele_rl1_footnote, hr_api.g_varchar2)
--  ,p_element_information20   =>  nvl(p_ele_registration_number, hr_api.g_varchar2)
--  ,p_element_information10   =>  l_pri_bal_id
--  ,p_element_information11   =>  l_accr_bal_id
--  ,p_element_information12   =>  l_arr_bal_id
--  ,p_element_information13   =>  l_not_taken_bal_id
  ,p_skip_formula            =>  l_skip_formula
  ,p_object_version_number   =>  l_ele_obj_ver_number);
--
--
-- Update user-specified Classification on Special Features Element.
--
hr_utility.set_location('pay_ca_user_init_dedn.create_user_init_deduction',9);
--
pay_shadow_element_api.update_shadow_element
  (p_validate                =>   false
  ,p_effective_date          =>   p_ele_eff_start_date
  ,p_element_type_id         =>   l_sf_element_type_id
  ,p_classification_name     =>   nvl(p_ele_classification, hr_api.g_varchar2)
  ,p_reporting_name          =>   p_ele_reporting_name||' SF'
  ,p_object_version_number   =>   l_sf_ele_obj_ver_number);
--
--
-- Update user-specified Classification Special Inputs if it exists.
--
hr_utility.set_location('pay_ca_user_init_dedn.create_user_init_deduction',10);
--
if p_ele_processing_type = 'R' then
   pay_shadow_element_api.update_shadow_element
     (p_validate                => false
     ,p_effective_date          => p_ele_eff_start_date
     ,p_element_type_id         => l_si_element_type_id
     ,p_classification_name     => nvl(p_ele_classification, hr_api.g_varchar2)
     ,p_reporting_name          =>   p_ele_reporting_name||' SI'
     ,p_object_version_number   => l_si_ele_obj_ver_number);
end if;
--
---------------------------- Generate Core Objects ------------------------
--
hr_utility.set_location('pay_ca_user_init_dedn.create_user_init_deduction',11);
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
hr_utility.set_location('pay_ca_user_init_dedn.create_user_init_deduction',12);
--
if l_hr_only = FALSE then
   pay_element_template_api.generate_part2
     (p_validate                      =>     false
     ,p_effective_date                =>     p_ele_eff_start_date
     ,p_template_id                   =>     l_template_id);
end if;
--
-------------------- Get Element Type ID of Base Element ------------------
--
hr_utility.set_location('pay_ca_user_init_dedn.create_user_init_deduction',13);
--
select element_type_id
into   l_base_element_type_id
from   pay_element_types_f
where  element_name = p_ele_name
and    business_group_id + 0 = p_bg_id;
--
------------------ Get Balance Type IDs to update Flex Info ---------------
--
hr_utility.set_location('pay_ca_user_init_dedn.create_user_init_deduction',14);
--
select ptco.core_object_id
into   l_pri_bal_id
from   pay_shadow_balance_types psbt,
       pay_template_core_objects ptco
where  psbt.template_id = l_template_id
and    psbt.balance_name = p_ele_name
and    ptco.template_id = psbt.template_id
and    ptco.shadow_object_id = psbt.balance_type_id;
--
hr_utility.set_location('pay_ca_user_init_dedn.create_user_init_deduction',15);
--
if l_arrearage_create = 'Y' then
   select ptco.core_object_id
   into   l_arr_bal_id
   from   pay_shadow_balance_types psbt,
          pay_template_core_objects ptco
   where  psbt.template_id = l_template_id
   and    psbt.balance_name = p_ele_name||' Arrears'
   and    ptco.template_id = psbt.template_id
   and    ptco.shadow_object_id = psbt.balance_type_id;

   --
   select ptco.core_object_id
   into   l_not_taken_bal_id
   from   pay_shadow_balance_types psbt,
          pay_template_core_objects ptco
   where  psbt.template_id = l_template_id
   and    psbt.balance_name = p_ele_name||' Not Taken'
   and    ptco.template_id = psbt.template_id
   and    ptco.shadow_object_id = psbt.balance_type_id;
else
   l_not_taken_bal_id := '';
   l_arr_bal_id := '';
end if;
--
hr_utility.set_location('pay_ca_user_init_dedn.create_user_init_deduction',16);
--
if l_total_owed_create = 'Y' then
   select ptco.core_object_id
   into   l_accr_bal_id
   from   pay_shadow_balance_types psbt,
          pay_template_core_objects ptco
   where  psbt.template_id = l_template_id
   and    psbt.balance_name = p_ele_name||' Accrued'
   and    ptco.template_id = psbt.template_id
   and    ptco.shadow_object_id = psbt.balance_type_id;
else
   l_accr_bal_id := '';
end if;
--
hr_utility.set_location('pay_ca_user_init_dedn.create_user_init_deduction',17);
--
update pay_element_types_f
set    element_information10 = l_pri_bal_id,
       element_information11 = l_accr_bal_id,
       element_information12 = l_arr_bal_id,
       element_information13 = l_not_taken_bal_id,
       element_information18 = p_ele_t4a_footnote,
       element_information19 = p_ele_rl1_footnote,
       element_information20 = p_ele_registration_number
where  element_type_id = l_base_element_type_id
and    business_group_id + 0 = p_bg_id;
--

/* Fix for Bug#2219028, setting the termination rule to 'Last Standard
   Process Date' for all Recurring Elements */

  If p_ele_processing_type = 'R' then

   update pay_element_types_f
   set post_termination_rule = 'L'
   where element_type_id = l_base_element_type_id
   and business_group_id + 0 = p_bg_id;

  End if;
/* End of fix for bug#2219028 */

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
--

IF p_ele_proc_runtype = 'REG' THEN

   create_element_type_usages (
                 p_element_name      => p_ele_name,
                 p_bg_id             => p_bg_id,
                 p_ele_proc_run_type => p_ele_proc_runtype);

   create_element_type_usages (
                 p_element_name      => p_ele_name || ' Special Inputs',
                 p_bg_id             => p_bg_id,
                 p_ele_proc_run_type => p_ele_proc_runtype);

END IF;
--
--
------------------ Update jurisdiction_level on balances --------------------
--
-- Added update for jurisdiction level, this needs to be set for all balances
-- to '2'. This is currently a hardcoded update to base table as the balance
-- apis do not support jurisdiction_level.
--
pay_ca_user_init_earn.update_jd_level_on_balance(l_template_id);
--
------------------ Conclude Create_User_Init_Deduction Main -----------------
--
hr_utility.set_location('pay_ca_user_init_dedn.create_user_init_deduction',18);
--
RETURN l_base_element_type_id;
--
END create_user_init_deduction;
--
--
--
------------------------- create_user_init_garnishment -------------------------
--
--
FUNCTION create_user_init_garnishment (
                p_ele_name              in varchar2,
                p_ele_reporting_name    in varchar2,
                p_ele_description       in varchar2     default NULL,
                p_ele_classification    in varchar2,
                p_ben_class_id          in number,
                p_ele_category          in varchar2     default NULL,
                p_ele_processing_type   in varchar2,
                p_ele_priority          in number       default NULL,
                p_ele_standard_link     in varchar2     default 'N',
                p_ele_proc_runtype      in varchar2,
                p_ele_start_rule        in varchar2,
                p_ele_stop_rule         in varchar2,
                p_ele_calc_rule         in varchar2,
                p_ele_calc_rule_code    in varchar2,
                p_ele_insuff_funds      in varchar2,
                p_ele_insuff_funds_code in varchar2,
                p_ele_t4a_footnote      in varchar2,
                p_ele_rl1_footnote      in varchar2,
                p_ele_registration_number in varchar2,
                p_ele_eff_start_date    in date         default NULL,
                p_ele_eff_end_date      in date         default NULL,
                p_bg_id                 in number)      RETURN NUMBER IS
--

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

-- global constants
c_end_of_time  CONSTANT DATE := TO_DATE('4712/12/31','YYYY/MM/DD');

-- global vars
g_eff_start_date        DATE;
g_eff_end_date          DATE;

-- local vars
l_hr_only               BOOLEAN;
l_reserved              VARCHAR2(1) := 'N';
l_source_template_id    NUMBER(9); -- Source Template ID.
l_template_id           NUMBER(9); -- Template ID.
l_object_version_number NUMBER(9); -- Object Version Number

l_bg_name                 VARCHAR2(60);        -- Get from bg short name passed in.

l_element_type_id         NUMBER(9); -- Get from pay_shadow_element_types
l_ele_obj_ver_number      NUMBER(9); -- Object Version Number
l_sf_element_type_id     NUMBER(9); -- Get from pay_shadow_element_types
l_sf_ele_obj_ver_number  NUMBER(9); -- Object Version Number
l_sf2_element_type_id     NUMBER(9); -- Get from pay_shadow_element_types
l_sf2_ele_obj_ver_number  NUMBER(9); -- Object Version Number
l_si_element_type_id      NUMBER(9); -- Get from pay_shadow_element_types
l_si_ele_obj_ver_number   NUMBER(9); -- Object Version Number
l_ver_element_type_id     NUMBER(9); -- Get from pay_shadow_element_types
l_ver_ele_obj_ver_number  NUMBER(9); -- Object Version Number
l_fee_element_type_id     NUMBER(9); -- Get from pay_shadow_element_types
l_fee_ele_obj_ver_number  NUMBER(9); -- Object Version Number
l_base_element_type_id    NUMBER(9); -- Populated by insertion of element type.

l_pri_bal_id            NUMBER(9); -- Get from pay_balance_types
l_accr_bal_id           NUMBER(9); -- Get from pay_balance_types
l_arr_bal_id            NUMBER(9); -- Get from pay_balance_types
l_repl_bal_id           NUMBER(9); -- Get from pay_balance_types
l_addl_bal_id           NUMBER(9); -- Get from pay_balance_types
l_fees_bal_id           NUMBER(9); -- Get from pay_balance_types
l_not_taken_bal_id      NUMBER(9); -- Get from pay_balance_types
l_proc_run_type         VARCHAR2(30); -- User-specified

l_ele_repname           VARCHAR2(30);
l_ben_class_name        VARCHAR2(80);
l_skip_formula          VARCHAR2(80):= 'WAT_SKIP';
l_primary_class_id      NUMBER(9);
l_class_lo_priority     NUMBER(9);
l_class_hi_priority     NUMBER(9);
--
---------------------------- get_template_id -------------------------------
--
FUNCTION get_template_id (p_legislation_code      in varchar2)
RETURN number IS
-- local vars
l_template_id           NUMBER(9);
l_template_name         VARCHAR2(80);

BEGIN
--
hr_utility.set_location('pay_ca_user_init_garn.get_template_id',1);
--
l_template_name := 'Generic Involuntary Deduction';
--
hr_utility.set_location('pay_ca_user_init_garn.get_template_id',3);
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
hr_utility.set_location('pay_ca_user_init_garn.get_template_id',4);
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
hr_utility.set_location('pay_ca_user_init_garn.chk_ca_pay_installed',1);
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
hr_utility.set_location('pay_ca_user_init_garn.chk_ca_pay_installed',2);
--
RETURN (l_installed);
--
END chk_ca_pay_installed;

--
--
------------------------ create_user_init_garnishment Main --------------------
--
-- Main Procedure

BEGIN
--
-- hr_utility.trace_on('Y', 'RANJANA');
--
hr_utility.set_location('pay_ca_user_init_garn.create_user_init_garnishment',1);
--
-- Set session date
pay_db_pay_setup.set_session_date(nvl(p_ele_eff_start_date, sysdate));
--
g_eff_start_date := NVL(p_ele_eff_start_date, sysdate);
g_eff_end_date   := NVL(p_ele_eff_end_date, c_end_of_time);
--
hr_utility.set_location('pay_ca_user_init_garn.create_user_init_garnishment',2);
--
---------------------------- Check Element Name ---------------------------
--
hr_utility.set_location('pay_ca_user_init_earn.create_user_init_garnishment',25);
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
   hr_utility.set_location('pay_ca_user_init_earn.create_user_init_garnishment',26);

   hr_utility.set_message(801,'HR_7564_ALL_RES_WORDS');
   hr_utility.raise_error;
end if;
--
---------------------------- Get Source Template ID -----------------------
--
hr_utility.set_location('pay_ca_user_init_garn.create_user_init_garnishment',3);
--
l_source_template_id := get_template_id(
                                 p_legislation_code => g_template_leg_code);
--
---------------------- Get Element Type ID of new Template-----------------
--
hr_utility.set_location('pay_ca_user_init_garn.create_user_init_garnishment',7);
--
pay_element_template_api.create_user_structure
  (p_validate                      =>     false
  ,p_effective_date                =>     p_ele_eff_start_date
  ,p_business_group_id             =>     p_bg_id
  ,p_source_template_id            =>     l_source_template_id
  ,p_base_name                     =>     p_ele_name
  ,p_base_processing_priority      =>     p_ele_priority
--  ,p_configuration_information1    =>     l_arrearage_create
--  ,p_configuration_information2    =>     l_total_owed_create
--  ,p_configuration_information3    =>     p_ele_processing_type
--  ,p_configuration_information4    =>     l_threshold_amt_create
  ,p_template_id                   =>     l_template_id
  ,p_object_version_number         =>     l_object_version_number);
--
select element_type_id, object_version_number
into   l_element_type_id, l_ele_obj_ver_number
from   pay_shadow_element_types
where  template_id = l_template_id
and    element_name = p_ele_name;
--
select element_type_id, object_version_number
into   l_sf_element_type_id, l_sf_ele_obj_ver_number
from   pay_shadow_element_types
where  template_id = l_template_id
and    element_name = p_ele_name||' Special Features';
--
select element_type_id, object_version_number
into   l_sf2_element_type_id, l_sf2_ele_obj_ver_number
from   pay_shadow_element_types
where  template_id = l_template_id
and    element_name = p_ele_name||' Special Features 2';
--
select element_type_id, object_version_number
into   l_fee_element_type_id, l_fee_ele_obj_ver_number
from   pay_shadow_element_types
where  template_id = l_template_id
and    element_name = p_ele_name||' Fees';
--
select element_type_id, object_version_number
into   l_ver_element_type_id, l_ver_ele_obj_ver_number
from   pay_shadow_element_types
where  template_id = l_template_id
and    element_name = p_ele_name||' Verifier';
--
select element_type_id, object_version_number
into   l_si_element_type_id, l_si_ele_obj_ver_number
from   pay_shadow_element_types
where  template_id = l_template_id
and    element_name = p_ele_name||' Special Inputs';
--
---------------------------- Update Shadow Structure ----------------------
--
hr_utility.set_location('pay_ca_user_init_garn.create_user_init_garnishment',8);
--
-- Update user-specified Classification, Processing Type and Standard Link.
--
pay_shadow_element_api.update_shadow_element
  (p_validate                     =>  false
  ,p_effective_date               =>  p_ele_eff_start_date
  ,p_element_type_id              =>  l_element_type_id
  ,p_classification_name          =>  nvl(p_ele_classification, hr_api.g_varchar2)
  ,p_processing_type              =>  nvl(p_ele_processing_type, hr_api.g_varchar2)
  ,p_standard_link_flag           =>  nvl(p_ele_standard_link, hr_api.g_varchar2)
  ,p_description                  =>  p_ele_description
  ,p_reporting_name               =>  p_ele_reporting_name
  ,p_benefit_classification_name  =>  l_ben_class_name
  ,p_element_information_category =>  nvl(upper(g_template_leg_code||'_'||p_ele_classification), hr_api.g_varchar2)
  ,p_element_information1         =>  nvl(p_ele_category, hr_api.g_varchar2)
--  ,p_element_information2         =>  nvl(p_ele_insuff_funds_code, hr_api.g_varchar2)
  ,p_element_information2         =>  'INV_DEDN'  /* Default Value as all insuff funds prcessing on entry_information */
  ,p_element_information3         =>  nvl(p_ele_proc_runtype, hr_api.g_varchar2)
  ,p_element_information6         =>  upper('P3') /* Creating all with a low priority default */
--  ,p_element_information18   =>  nvl(p_ele_t4a_footnote, hr_api.g_varchar2)
--  ,p_element_information19   =>  nvl(p_ele_rl1_footnote, hr_api.g_varchar2)
--  ,p_element_information20   =>  nvl(p_ele_registration_number, hr_api.g_varchar2)
--  ,p_element_information10      =>  l_pri_bal_id
--  ,p_element_information11      =>  l_accr_bal_id
--  ,p_element_information12      =>  l_arr_bal_id
--  ,p_element_information13      =>  l_not_taken_bal_id
  ,p_skip_formula                 =>  l_skip_formula
  ,p_object_version_number        =>  l_ele_obj_ver_number);
--
--
-- Update user-specified Classification on ISpecial Features Element.
--
hr_utility.set_location('pay_ca_user_init_garn.create_user_init_garnishment',9);


--
pay_shadow_element_api.update_shadow_element
  (p_validate                =>   false
  ,p_effective_date          =>   p_ele_eff_start_date
  ,p_element_type_id         =>   l_sf_element_type_id
  ,p_classification_name     =>   nvl(p_ele_classification, hr_api.g_varchar2)
  ,p_reporting_name               =>  p_ele_reporting_name||' SF'
  ,p_object_version_number   =>   l_sf_ele_obj_ver_number
  ,p_element_information_category =>  nvl(upper(g_template_leg_code||'_'||p_ele_classification), hr_api.g_varchar2)
  ,p_element_information1         =>  nvl(p_ele_category, hr_api.g_varchar2)
--  ,p_element_information2         =>  nvl(p_ele_insuff_funds_code, hr_api.g_varchar2)
  ,p_element_information2         =>  'INV_DEDN'  /* Default Value as all insuff funds prcessing on entry_information */
  ,p_element_information3         =>  nvl(p_ele_proc_runtype, hr_api.g_varchar2)
  ,p_element_information6         =>  upper('P3') /* Creating all with a low priority default */
);
--
pay_shadow_element_api.update_shadow_element
  (p_validate                =>   false
  ,p_effective_date          =>   p_ele_eff_start_date
  ,p_element_type_id         =>   l_sf2_element_type_id
  ,p_classification_name     =>   nvl(p_ele_classification, hr_api.g_varchar2)
  ,p_reporting_name               =>  p_ele_reporting_name||' SF 2'
  ,p_object_version_number   =>   l_sf2_ele_obj_ver_number
  ,p_element_information_category =>  nvl(upper(g_template_leg_code||'_'||p_ele_classification), hr_api.g_varchar2)
  ,p_element_information1         =>  nvl(p_ele_category, hr_api.g_varchar2)
--  ,p_element_information2         =>  nvl(p_ele_insuff_funds_code, hr_api.g_varchar2)
  ,p_element_information2         =>  'INV_DEDN'  /* Default Value as all insuff funds prcessing on entry_information */
  ,p_element_information3         =>  nvl(p_ele_proc_runtype, hr_api.g_varchar2)
  ,p_element_information6         =>  upper('P3') /* Creating all with a low priority default */
);
--
--
-- Update user-specified Classification Special Inputs if it exists.
--
hr_utility.set_location('pay_ca_user_init_garn.create_user_init_garnishment',11);

--
pay_shadow_element_api.update_shadow_element
  (p_validate                => false
  ,p_effective_date          => p_ele_eff_start_date
  ,p_element_type_id         => l_si_element_type_id
  ,p_classification_name     => nvl(p_ele_classification, hr_api.g_varchar2)
  ,p_reporting_name               =>  p_ele_reporting_name||' SI'
  ,p_object_version_number   => l_si_ele_obj_ver_number
  ,p_element_information_category =>  nvl(upper(g_template_leg_code||'_'||p_ele_classification), hr_api.g_varchar2)
  ,p_element_information1         =>  nvl(p_ele_category, hr_api.g_varchar2)
--  ,p_element_information2         =>  nvl(p_ele_insuff_funds_code, hr_api.g_varchar2)
  ,p_element_information2         =>  'INV_DEDN'  /* Default Value as all insuff funds prcessing on entry_information */
  ,p_element_information3         =>  nvl(p_ele_proc_runtype, hr_api.g_varchar2)
  ,p_element_information6         =>  upper('P3') /* Creating all with a low priority default */
);
--
--
-- Update user-specified Classification on Fees Element.
--
hr_utility.set_location('pay_ca_user_init_garn.create_user_init_garnishment',12);

--
pay_shadow_element_api.update_shadow_element
  (p_validate                =>   false
  ,p_effective_date          =>   p_ele_eff_start_date
  ,p_element_type_id         =>   l_fee_element_type_id
  ,p_classification_name     =>   nvl(p_ele_classification, hr_api.g_varchar2)
  ,p_reporting_name               =>  p_ele_reporting_name||' Fees'
  ,p_object_version_number   =>   l_fee_ele_obj_ver_number
  ,p_element_information_category =>  nvl(upper(g_template_leg_code||'_'||p_ele_classification), hr_api.g_varchar2)
  ,p_element_information1         =>  nvl(p_ele_category, hr_api.g_varchar2)
--  ,p_element_information2         =>  nvl(p_ele_insuff_funds_code, hr_api.g_varchar2)
  ,p_element_information2         =>  'INV_DEDN'  /* Default Value as all insuff funds prcessing on entry_information */
  ,p_element_information3         =>  nvl(p_ele_proc_runtype, hr_api.g_varchar2)
  ,p_element_information6         =>  upper('P3') /* Creating all with a low priority default */
);
--
--
-- Update user-specified Classification on, last but not least, Verifier Element.
--
hr_utility.set_location('pay_ca_user_init_garn.create_user_init_garnishment',13);

--
pay_shadow_element_api.update_shadow_element
  (p_validate                =>   false
  ,p_effective_date          =>   p_ele_eff_start_date
  ,p_element_type_id         =>   l_ver_element_type_id
  ,p_classification_name     =>   nvl(p_ele_classification, hr_api.g_varchar2)
  ,p_reporting_name               =>  p_ele_reporting_name||' Verifier'
  ,p_object_version_number   =>   l_ver_ele_obj_ver_number
  ,p_element_information_category =>  nvl(upper(g_template_leg_code||'_'||p_ele_classification), hr_api.g_varchar2)
  ,p_element_information1         =>  nvl(p_ele_category, hr_api.g_varchar2)
--  ,p_element_information2         =>  nvl(p_ele_insuff_funds_code, hr_api.g_varchar2)
  ,p_element_information2         =>  'INV_DEDN'  /* Default Value as all insuff funds prcessing on entry_information */
  ,p_element_information3         =>  nvl(p_ele_proc_runtype, hr_api.g_varchar2)
  ,p_element_information6         =>  upper('P3') /* Creating all with a low priority default */
);
--
--
---------------------------- Generate Core Objects ------------------------
--
--
hr_utility.set_location('pay_ca_user_init_garn.create_user_init_garnishment',14);

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
hr_utility.set_location('pay_ca_user_init_garn.create_user_init_garnishment',12);

--
if l_hr_only = FALSE then
   pay_element_template_api.generate_part2
     (p_validate                      =>     false
     ,p_effective_date                =>     p_ele_eff_start_date
     ,p_template_id                   =>     l_template_id);
end if;
--
-------------------- Get Element Type ID of Base Element ------------------
--
hr_utility.set_location('pay_ca_user_init_garn.create_user_init_garnishment',13);

--
select element_type_id
into   l_base_element_type_id
from   pay_element_types_f
where  element_name = p_ele_name
and    business_group_id + 0 = p_bg_id;
--
select element_type_id
into   l_fee_element_type_id
from   pay_element_types_f
where  element_name = p_ele_name||' Fees'
and    business_group_id + 0 = p_bg_id;
--
------------------ Get Balance Type IDs to update Flex Info ---------------
--
hr_utility.set_location('pay_ca_user_init_garn.create_user_init_garnishment',14);

--
select ptco.core_object_id
into   l_pri_bal_id
from   pay_shadow_balance_types psbt,
       pay_template_core_objects ptco
where  psbt.template_id = l_template_id
and    psbt.balance_name = p_ele_name
and    ptco.template_id = psbt.template_id
and    ptco.shadow_object_id = psbt.balance_type_id;
--
select ptco.core_object_id
into   l_repl_bal_id
from   pay_shadow_balance_types psbt,
       pay_template_core_objects ptco
where  psbt.template_id = l_template_id
and    psbt.balance_name = p_ele_name||' Replacement'
and    ptco.template_id = psbt.template_id
and    ptco.shadow_object_id = psbt.balance_type_id;
--
select ptco.core_object_id
into   l_addl_bal_id
from   pay_shadow_balance_types psbt,
       pay_template_core_objects ptco
where  psbt.template_id = l_template_id
and    psbt.balance_name = p_ele_name||' Additional'
and    ptco.template_id = psbt.template_id
and    ptco.shadow_object_id = psbt.balance_type_id;
--
select ptco.core_object_id
into   l_not_taken_bal_id
from   pay_shadow_balance_types psbt,
       pay_template_core_objects ptco
where  psbt.template_id = l_template_id
and    psbt.balance_name = p_ele_name||' Not Taken'
and    ptco.template_id = psbt.template_id
and    ptco.shadow_object_id = psbt.balance_type_id;
--
select ptco.core_object_id
into   l_accr_bal_id
from   pay_shadow_balance_types psbt,
       pay_template_core_objects ptco
where  psbt.template_id = l_template_id
and    psbt.balance_name = p_ele_name||' Accrued'
and    ptco.template_id = psbt.template_id
and    ptco.shadow_object_id = psbt.balance_type_id;
--
select ptco.core_object_id
into   l_fees_bal_id
from   pay_shadow_balance_types psbt,
       pay_template_core_objects ptco
where  psbt.template_id = l_template_id
and    psbt.balance_name = p_ele_name||' Fees'
and    ptco.template_id = psbt.template_id
and    ptco.shadow_object_id = psbt.balance_type_id;
--
select ptco.core_object_id
into   l_arr_bal_id
from   pay_shadow_balance_types psbt,
       pay_template_core_objects ptco
where  psbt.template_id = l_template_id
and    psbt.balance_name = p_ele_name||' Arrears'
and    ptco.template_id = psbt.template_id
and    ptco.shadow_object_id = psbt.balance_type_id;
--
hr_utility.set_location('pay_ca_user_init_garn.create_user_init_garnishment',17);

--
update pay_element_types_f
set    element_information10 = l_pri_bal_id,
       element_information11 = l_accr_bal_id,
       element_information12 = l_arr_bal_id,
       element_information13 = l_not_taken_bal_id,
       element_information17 = l_repl_bal_id,
       element_information16 = l_addl_bal_id,
       element_information15 = l_fees_bal_id,
       element_information18 = p_ele_t4a_footnote,
       element_information19 = p_ele_rl1_footnote,
       element_information20 = p_ele_registration_number
where  element_type_id = l_base_element_type_id
and    business_group_id + 0 = p_bg_id;
--
update pay_element_types_f
set    element_information10 = l_fees_bal_id
where  element_type_id = l_fee_element_type_id
and    business_group_id + 0 = p_bg_id;
--
--
FOR dim IN get_asg_gre_run_dim_id LOOP
   l_asg_gre_run_dim_id := dim.balance_dimension_id;
END LOOP;

FOR dim IN get_asg_jd_gre_run_dim_id LOOP
   l_asg_jd_gre_run_dim_id := dim.balance_dimension_id;
END LOOP;

UPDATE pay_defined_balances
SET save_run_balance    = 'Y'
WHERE balance_type_id IN
                  (l_pri_bal_id,
                   l_fees_bal_id)
AND   balance_dimension_id IN
                  (l_asg_gre_run_dim_id,
                   l_asg_jd_gre_run_dim_id)
AND   business_group_id = p_bg_id;

IF p_ele_proc_runtype = 'REG' THEN

   create_element_type_usages (
                 p_element_name      => p_ele_name,
                 p_bg_id             => p_bg_id,
                 p_ele_proc_run_type => p_ele_proc_runtype);

   create_element_type_usages (
                 p_element_name      => p_ele_name || ' Special Inputs',
                 p_bg_id             => p_bg_id,
                 p_ele_proc_run_type => p_ele_proc_runtype);

END IF;
--
--
------------------ Update jurisdiction_level on balances --------------------
--
-- Added update for jurisdiction level, this needs to be set for all balances
-- to '2'. This is currently a hardcoded update to base table as the balance
-- apis do not support jurisdiction_level.
--
pay_ca_user_init_earn.update_jd_level_on_balance(l_template_id);
--
------------------ Conclude Create_User_Init_Deduction Main -----------------
--
hr_utility.set_location('pay_ca_user_init_garn.create_user_init_garnishment',18);
--
RETURN l_base_element_type_id;
--
END create_user_init_garnishment;
--
--
------------------------- Deletion procedures -----------------------------
---------------------- delete_user_init_deduction -------------------------
--
PROCEDURE delete_user_init_deduction (
			p_business_group_id	in number,
			p_ele_type_id		in number,
			p_ele_name		in varchar2,
			p_ele_priority		in number,
			p_ele_info_10		in varchar2	default null,
			p_ele_info_12		in varchar2	default null,
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
hr_utility.set_location('pay_ca_user_init_dedn.delete_user_init_deduction',1);
--
select template_id
into   l_template_id
from   pay_element_templates
where  base_name = p_ele_name
and    business_group_id = p_business_group_id
and    template_type = 'U';
--
hr_utility.set_location('pay_ca_user_init_dedn.delete_user_init_deduction',2);
--
  begin
    delete from pay_element_type_usages_f
    where element_type_id in ( select element_type_id
                               from   pay_element_types_f
                               where  element_name = p_ele_name
                               and    business_group_id = p_business_group_id );
    --
    hr_utility.set_location('pay_ca_user_init_dedn.delete_user_init_deduction',3);
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
hr_utility.set_location('pay_ca_user_init_dedn.delete_user_init_deduction',4);
--
END delete_user_init_deduction;
--
------------------------- Deletion procedures -----------------------------
---------------------- delete_user_init_garnishment -----------------------
--
PROCEDURE delete_user_init_garnishment (
                        p_business_group_id       in number,
                        p_ele_type_id             in number,
                        p_ele_name                in varchar2,
                        p_ele_priority            in number,
                        p_ele_info_10             in varchar2        default null,

                        p_ele_info_12             in varchar2        default null,

                        p_del_sess_date           in date,
                        p_del_val_start_date      in date,
                        p_del_val_end_date        in date) IS
-- local constants
c_end_of_time  CONSTANT DATE := TO_DATE('4712/12/31','YYYY/MM/DD');

-- local vars
l_del_sess_date         DATE := NULL;
l_del_val_start         DATE := NULL;
l_del_val_end           DATE := NULL;

l_template_id   NUMBER(9);
--
BEGIN
-- Populate vars.
l_del_val_end   := nvl(p_del_val_end_date, c_end_of_time);
l_del_val_start := nvl(p_del_val_start_date, sysdate);
l_del_sess_date := nvl(p_del_sess_date, sysdate);
--
hr_utility.set_location('pay_ca_user_init_garn.delete_user_init_garnishment',1);
--
select template_id
into   l_template_id
from   pay_element_templates
where  base_name = p_ele_name
and    business_group_id = p_business_group_id
and    template_type = 'U';
--
hr_utility.set_location('pay_ca_user_init_garn.delete_user_init_garnishment',2);
--
  begin
    delete from pay_element_type_usages_f
    where element_type_id in ( select element_type_id
                               from   pay_element_types_f
                               where  element_name = p_ele_name
                               and    business_group_id = p_business_group_id );
    --
    hr_utility.set_location('pay_ca_user_init_dedn.delete_user_init_deduction',3
);
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
hr_utility.set_location('pay_ca_user_init_garn.delete_user_init_garnishment',3);
--
END delete_user_init_garnishment;
--
END pay_ca_user_init_dedn;

/
