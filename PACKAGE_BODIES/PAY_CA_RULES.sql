--------------------------------------------------------
--  DDL for Package Body PAY_CA_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_RULES" as
/*   $Header: pycarule.pkb 120.14.12010000.4 2010/03/23 10:12:30 aneghosh ship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993,1994. All rights reserved
--
   Name        : pay_ca_rules
--
   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -------------------------------------------
   23-MAR-2010  aneghosh    115.21 Added the code to display employee and employer
                                   country name on pdf payslip
   05-MAR-2010  aneghosh    115.20 For Bug9445414. Online PDF Payslip enhancement.
                                   Modified add_custom_xml procedure.
   30-APR-2009  sapalani    115.19 For bug 8459792, Added new IN OUT parameter
                                   p_wk_sch_found to function
                                   work_schedule_total_hours.
   21-SEP-2006  pganguly    115.18 Changed the add_custom_xml procedure.
   08-SEP-2006  ydevi       115.16 Added code in add_custom_xml to support
                                   CIBC Direct Deposit Bank Format
   30-AUG_2006  ssmukher    115.15 Added code in add_custom_xml to support
                                   CPA 005 Direct Deposit Format.
   17-AUG-2006	pganguly    115.14 Added code in add_custom_xml to support TD
                                   Direct Deposit Format.
   10-AUG-2006  pganguly    115.13 Added nocopy in FILE_NO out parameter.
   10-AUG-2006  pganguly    115.12 Fixed bug# 5234705. Added a new procedure
                                   get_file_creation_no. Also changed the
                                   signature of add_custom_xml procedure.
   03-MAR-2006  pganguly    115.11 Fixed bug# 5104801. Changed the
                                   legislation_code to 'CA' in the function
                                   work_schedule_total_hours.
   27-OCT-2005  mmukherj    115.10 Added the function
                                   work_schedule_total_hours used by new
                                   work schedule functionality
   21-OCT-2005              115.9  Changed the format of payment_date in
                                   add_custom_xml procedure.
   20-OCT-2005              115.8  Added archiving of Payment_date in the
                                   add_custom_xml procedure.
   03-OCT-2005              115.7  Added add_custom_xml procedure to this
                                   package. This procedure served as a
                                   legislation hook for the Direct Deposit
                                   process which uses XMl Publisher Utility.
                                   #4650317.
   13-SEP-2005  ssouresr    115.6  The application_id for the error messages
                                   introduced in the previous update should
                                   have been 801 and not 800
   08-AUG-2005  saurgupt    115.5  Modified the proc get_dynamic_tax_unit.
                                   Raised the error if tax_unit_id is not
                                   present for the element being processed.
   10-APR-2002  vpandya     115.4  Added get_multi_tax_unit_pay_flag procedure
                                   to get 'Payroll Archiver Level' of the
                                   business group for prepayment.
                                   GRE - Separate Cheque by GRE
                                   TAXGRP - Consolidated Cheque for all GREs.
   04-SEP-2002  vpandya     115.3  Added get_dynamic_tax_unit procedure for
                                   Multi GRE functionality.
   14-Apr-2000  SSattini    115.1  Changed pay_ca_emp_all_fedtax_info to
                                   pay_ca_emp_all_fedtax_info_v.
   07-May-1999  Lwthomps           Modified to use the allfed info view.
   16-APr-1999  mmukherj    110.0  Created.
*/
--
--
   PROCEDURE get_default_jurisdiction(p_asg_act_id number,
                                      p_ee_id number,
                                      p_jurisdiction in out nocopy varchar2)
   IS

     l_geocode varchar2(15);

     cursor csr_get_jd is
     Select employment_province, geocode
     from pay_ca_emp_all_fedtax_info_v cft,
          pay_assignment_actions paa
     where cft.assignment_id = paa.assignment_id
     and   paa.assignment_action_id = p_asg_act_id;

   BEGIN

     open csr_get_jd;
     fetch csr_get_jd into p_jurisdiction, l_geocode;
     close csr_get_jd;

   END get_default_jurisdiction;

   PROCEDURE get_dynamic_tax_unit(p_asg_act_id   in     number,
                                  p_run_type_id  in     number,
                                  p_tax_unit_id  in out nocopy number) IS

     cursor cur_run_type(cp_run_type_id in number) is
     select substr(run_type_name,1,instr(run_type_name,' ')-1)
     from   pay_run_types_f
     where  run_type_id = cp_run_type_id;

     cursor cur_tax_unit(cp_asg_act_id in number) is
     select segment1 T4_RL1_GRE
           ,segment11 T4A_RL1_GRE
           ,segment12 T4A_RL2_GRE
     from   hr_soft_coding_keyflex hsck
           ,per_all_assignments_f paf
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
     where paa.assignment_action_id = cp_asg_act_id
     and   ppa.payroll_action_id    = paa.payroll_action_id
     and   paf.assignment_id        = paa.assignment_id
     and   ppa.effective_date between paf.effective_start_date
                                 and  paf.effective_end_date
     and   hsck.soft_coding_keyflex_id = paf.soft_coding_keyflex_id;

     cursor cur_check_gre_type(cp_tax_unit_id in number) is
     select hoi.org_information5
     from   hr_organization_information hoi
     where  hoi.organization_id = cp_tax_unit_id
     and    hoi.org_information_context = 'Canada Employer Identification';

     cursor cur_tu_for_old_run(cp_asg_act_id in number) is
     select decode(segment1, NULL, 0, 1 ) +
            decode(segment11, NULL, 0, 1 ) +
            decode(segment12, NULL, 0, 1 ) tot_no_of_tu
            ,nvl(segment1, nvl(segment11,segment12) ) tax_unit_id
     from   hr_soft_coding_keyflex hsck
           ,per_all_assignments_f paf
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
     where paa.assignment_action_id = cp_asg_act_id
     and   ppa.payroll_action_id    = paa.payroll_action_id
     and   paf.assignment_id        = paa.assignment_id
     and   ppa.effective_date between paf.effective_start_date
                                 and  paf.effective_end_date
     and   hsck.soft_coding_keyflex_id = paf.soft_coding_keyflex_id;

     ln_t4_rl1_gre    number;
     ln_t4a_rl1_gre   number;
     ln_t4a_rl2_gre   number;

     lv_run_type_gre  varchar2(240);
     lv_gre_type      varchar2(240);

     ln_tax_unit_id   number;
     ln_tot_no_of_tu  number;
   BEGIN


     p_tax_unit_id := null;

     open  cur_run_type(p_run_type_id);
     fetch cur_run_type into lv_run_type_gre;
     close cur_run_type;

     open  cur_tax_unit(p_asg_act_id);
     fetch cur_tax_unit into ln_t4_rl1_gre
                            ,ln_t4a_rl1_gre
                            ,ln_t4a_rl2_gre;
     close cur_tax_unit;

     if lv_run_type_gre = 'T4/RL1' then

        open  cur_check_gre_type(ln_t4_rl1_gre);
        fetch cur_check_gre_type into lv_gre_type;
        close cur_check_gre_type;

        if lv_gre_type = 'T4/RL1' then
           p_tax_unit_id := ln_t4_rl1_gre;
        else
           p_tax_unit_id := null;
           hr_utility.set_message(801,'PAY_74161_MISSING_GRE');
           pay_core_utils.push_message(801,'PAY_74161_MISSING_GRE','P');
           hr_utility.raise_error;
	end if;

    elsif lv_run_type_gre = 'T4A/RL1' then

        open  cur_check_gre_type(ln_t4a_rl1_gre);
        fetch cur_check_gre_type into lv_gre_type;
        close cur_check_gre_type;

        if lv_gre_type = 'T4A/RL1' then
	   p_tax_unit_id := ln_t4a_rl1_gre;
        else
           p_tax_unit_id := null;
           hr_utility.set_message(801,'PAY_74161_MISSING_GRE');
           pay_core_utils.push_message(801,'PAY_74161_MISSING_GRE','P');
           hr_utility.raise_error;
        end if;

    elsif lv_run_type_gre = 'T4A/RL2' then

        open  cur_check_gre_type(ln_t4a_rl2_gre);
        fetch cur_check_gre_type into lv_gre_type;
        close cur_check_gre_type;

        if lv_gre_type = 'T4A/RL2' then
           hr_utility.trace('in lv_gre_type = T4A/RL2');
           p_tax_unit_id := ln_t4a_rl2_gre;
        else
           p_tax_unit_id := null;
           hr_utility.set_message(801,'PAY_74161_MISSING_GRE');
           pay_core_utils.push_message(801,'PAY_74161_MISSING_GRE','P');
           hr_utility.raise_error;
        end if;

    else

       open  cur_tu_for_old_run(p_asg_act_id);
       fetch cur_tu_for_old_run into ln_tot_no_of_tu
                                    ,ln_tax_unit_id;
       close cur_tu_for_old_run;

       if ln_tot_no_of_tu > 1 then
          -- error
          null;
       else
           p_tax_unit_id := ln_tax_unit_id;
       end if;

    end if;

   END get_dynamic_tax_unit;

   PROCEDURE get_multi_tax_unit_pay_flag
                              (p_bus_grp in number,
                               p_mtup_flag in out nocopy varchar2) IS

        l_reporting_level   hr_organization_information.org_information1%type;

   BEGIN
     --
           select org_information1
             into l_reporting_level
             from hr_organization_information
            where org_information_context = 'Payroll Archiver Level'
              and organization_id = p_bus_grp;
     --
                 --
           if l_reporting_level is null then
              null;
           elsif l_reporting_level = 'TAXGRP' then
             p_mtup_flag := 'Y';
           else
             p_mtup_flag := 'N';
           end if;
     --
        exception
            when no_data_found then
              p_mtup_flag := 'N';
     --
   END get_multi_tax_unit_pay_flag;

  PROCEDURE add_custom_xml as

  /* CURSOR get_assignment_number(p_asg_action_id number) IS
     SELECT assignment_number
     FROM per_assignments_f paf, pay_assignment_actions paa
     WHERE paa.assignment_action_id = p_asg_action_id
     and   paa.assignment_id = paf.assignment_id; */

  TYPE char_tab IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;


  CURSOR cur_ppa(p_payroll_action_id NUMBER) IS
  SELECT
    SYSDATE,
    NVL(overriding_dd_date,effective_date)
  FROM
    pay_payroll_actions
  WHERE
    payroll_action_id = p_payroll_action_id;

  l_direct_deposit_date DATE;
  l_dd_date           VARCHAR2(30);
  l_dd_type           VARCHAR2(20);
  l_payroll_action_id pay_payroll_actions.payroll_action_id%TYPE;
  l_text              VARCHAR(900);
  l_override_cpa_code VARCHAR2(100);
  l_payment_date      DATE;
  l_payment_date1    VARCHAR2(30);


  BEGIN

     hr_utility.trace('Add Custom XML starts here .... ');

     l_payroll_action_id
       := pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');
     l_override_cpa_code
       :=  pay_magtape_generic.get_parameter_value('OVERRIDE_CPA_CODE');
     l_dd_type
       :=  pay_magtape_generic.get_parameter_value('MAGTAPE_REPORT_ID');

     hr_utility.trace('l_payroll_action_id = ' ||
                      to_char(l_payroll_action_id));
     hr_utility.trace('l_override_cpa_code = ' || l_override_cpa_code);

     OPEN cur_ppa(l_payroll_action_id);
     FETCH cur_ppa
     INTO  l_payment_date,
           l_direct_deposit_date;
     CLOSE cur_ppa;

     hr_utility.trace('l_payment_date = ' || to_char(l_payment_date));
     hr_utility.trace('l_direct_deposit_date = ' ||
                       to_char(l_direct_deposit_date));
     SELECT
       decode(l_dd_type, 'NOVA_SCOT',to_char(l_direct_deposit_date,'YYDDD'),
                         'TD', to_char(l_direct_deposit_date,'DDMMYY'),
			 'CPA','0'||to_char(l_direct_deposit_date,'YYDDD'),
			 'CIBC',to_char(l_direct_deposit_date,'YYMMDD'))
     INTO
       l_dd_date
     FROM
       DUAL;

     SELECT
       decode(l_dd_type, 'NOVA_SCOT',to_char(l_payment_date,'YYDDD'),
                         'TD', to_char(l_payment_date,'DDMMYY'),
			 'CPA','0'||to_char(l_payment_date,'YYDDD'),
			 'CIBC',to_char(l_payment_date,'YYMMDD'))
     INTO
       l_payment_date1
     FROM
       DUAL;
     l_text :=
        '<DEPOSIT_DATE_CA>' || l_payment_date1 || '</DEPOSIT_DATE_CA>' ||
        '<FILE_CREATION_DATE_CA>'|| l_dd_date || '</FILE_CREATION_DATE_CA>' ||
        '<OVERRIDE_CPA_CODE>'  || l_override_cpa_code || '</OVERRIDE_CPA_CODE>';

     pay_core_files.write_to_magtape_lob(l_text);
     hr_utility.trace('Add Custom XML ends here .......');

   END add_custom_xml;

---- Procedures / Functions Added for CA PDF Payslip enhancement. (Bug 9445414)

  PROCEDURE add_custom_xml (P_ASSIGNMENT_ACTION_ID IN NUMBER ,
                          P_ACTION_INFORMATION_CATEGORY IN VARCHAR2,
                          P_DOCUMENT_TYPE IN VARCHAR2)  AS

  TYPE char_tab IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;


  CURSOR cur_ppa(p_payroll_action_id NUMBER) IS
  SELECT
    SYSDATE,
    NVL(overriding_dd_date,effective_date)
  FROM
    pay_payroll_actions
  WHERE
    payroll_action_id = p_payroll_action_id;

  CURSOR get_employee_country (CP_ASSIGNMENT_ACTION_ID IN NUMBER) IS
  select ft.nls_territory
  from pay_action_information pai,fnd_territories ft
  where pai.action_context_id = cp_assignment_action_id
  and pai.action_information_category='ADDRESS DETAILS'
  and ft.territory_code=pai.action_information13;

  CURSOR get_employer_country (CP_ASSIGNMENT_ACTION_ID IN NUMBER) IS
  select DISTINCT ft.nls_territory
  from pay_action_information pai,fnd_territories ft
  where pai.action_context_id =
                    (SELECT payroll_action_id
                       FROM pay_assignment_actions
                      WHERE assignment_action_id = cp_assignment_action_id)
  and pai.action_information_category='ADDRESS DETAILS'
  and ft.territory_code=pai.action_information13;

   CURSOR get_net_pay(CP_ASSIGNMENT_ACTION_ID IN NUMBER) IS
       SELECT net_pay
        FROM  PAY_AC_EMP_SUM_ACTION_INFO_V
       WHERE  action_context_id = cp_assignment_action_id
         AND  action_information_category = 'AC SUMMARY CURRENT';

   CURSOR get_net_pay_ytd(CP_ASSIGNMENT_ACTION_ID IN NUMBER) is
       SELECT net_pay
       FROM PAY_AC_EMP_SUM_ACTION_INFO_V
       WHERE action_context_id = cp_assignment_action_id
       AND ACTION_INFORMATION_CATEGORY  = 'AC SUMMARY YTD';

 CURSOR get_proposed_salary(CP_ASSIGNMENT_ACTION_ID IN NUMBER) is
       SELECT nvl(ACTION_INFORMATION28,0)
        FROM  PAY_ACTION_INFORMATION
       WHERE  action_context_id = cp_assignment_action_id
         AND  action_information_category = 'EMPLOYEE DETAILS';

  CURSOR get_net_pay_dstr_details ( cp_assignment_action_id in number) IS
  SELECT check_deposit_number,
         segment5,
         segment2,
         segment3,
         value,segment4,segment7 from
  pay_emp_net_dist_action_info_v
  WHERE action_context_id=cp_assignment_action_id;

  l_direct_deposit_date DATE;
  l_dd_date           VARCHAR2(30);
  l_dd_type           VARCHAR2(20);
  l_payroll_action_id pay_payroll_actions.payroll_action_id%TYPE;
  l_text              VARCHAR(900);
  l_override_cpa_code VARCHAR2(100);
  l_payment_date      DATE;
  l_payment_date1    VARCHAR2(30);

  ln_amount                    number;
  ln_net_pay_ytd               number;
  ln_proposed_salary           number;

 lv_check_number              varchar2(200);
 ln_check_value               number ;
 lv_account_name              varchar2(200);
 lv_account_type              varchar2(200);
 ln_account_number            varchar2(200);
 lv_transit_code              varchar2(200);
 lv_bank_name                 varchar2(200);
 lv_bank_number               varchar2(200);
 ln_employee_country          varchar2(200); --For displaying country code as country
 ln_employer_country          varchar2(200); --name on PDF Payslip.


  BEGIN

     hr_utility.trace('Add Custom XML starts here .... ');

     l_payroll_action_id
       := pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');
     l_override_cpa_code
       :=  pay_magtape_generic.get_parameter_value('OVERRIDE_CPA_CODE');
     l_dd_type
       :=  pay_magtape_generic.get_parameter_value('MAGTAPE_REPORT_ID');

/* Added the code for CA pdf payslip enhancement bug:9445414 */

IF p_document_type = 'PAYSLIP'
     AND p_action_information_category IS NOT NULL THEN

  IF p_action_information_category = 'EMPLOYEE DETAILS'  THEN
     OPEN get_proposed_salary(p_assignment_action_id);
     FETCH get_proposed_salary INTO ln_proposed_salary;

/*  Takes care of NULL value for proposed salary. Custom tag
    PROPOSED_SALARY_CUSTOM  is populated*/

    pay_payroll_xml_extract_pkg.load_xml_data('D','PROPOSED_SALARY_CUSTOM',ln_proposed_salary );
    CLOSE get_proposed_salary;

/*Added the code to display net pay distribution section on pdf payslip
  it appends employee details with new context CA_EMPLOYEE_NET_PAY_DISTRIBUTION */

           OPEN get_net_pay_dstr_details (P_ASSIGNMENT_ACTION_ID);
           LOOP
           FETCH get_net_pay_dstr_details INTO lv_check_number,
                                             lv_bank_name,
                                             lv_account_type,
                                             ln_account_number,
                                             ln_check_value,
                                             lv_transit_code,
                                             lv_bank_number;
             IF get_net_pay_dstr_details%NOTFOUND THEN
             close get_net_pay_dstr_details;
             EXIT;
              ELSE
              pay_payroll_xml_extract_pkg.load_xml_data('CS','CA_EMPLOYEE_NET_PAY_DISTRIBUTION',null);
              pay_payroll_xml_extract_pkg.load_xml_data('D','CHECK_DEPOSIT_NUMBER',lv_check_number);
              pay_payroll_xml_extract_pkg.load_xml_data('D','VALUE',ln_check_value);
              pay_payroll_xml_extract_pkg.load_xml_data('D','ACCOUNT_TYPE',lv_account_type);
              pay_payroll_xml_extract_pkg.load_xml_data('D','BANK_NAME',lv_bank_name);
              pay_payroll_xml_extract_pkg.load_xml_data('D','BANK_NUMBER',lv_bank_number);
              pay_payroll_xml_extract_pkg.load_xml_data('D','ACCOUNT_NUMBER',
              HR_GENERAL2.mask_characters(ln_account_number));
              pay_payroll_xml_extract_pkg.load_xml_data('D','TRANSIT_CODE',lv_transit_code);
              pay_payroll_xml_extract_pkg.load_xml_data('CE','CA_EMPLOYEE_NET_PAY_DISTRIBUTION',null);

              END IF;
              END LOOP;

      END IF;

/*Added the code to display net pay current and ytd values on pdf payslip  */

      IF p_action_information_category = 'AC SUMMARY YTD' THEN

    OPEN get_net_pay_ytd(p_assignment_action_id);
    FETCH get_net_pay_ytd INTO ln_net_pay_ytd;
    pay_payroll_xml_extract_pkg.load_xml_data('D','NET_PAY_YTD',ln_net_pay_ytd );
    CLOSE get_net_pay_ytd;

  END IF;

  IF p_action_information_category = 'AC SUMMARY CURRENT'  THEN

      OPEN get_net_pay(p_assignment_action_id);
      FETCH get_net_pay into ln_amount;
      CLOSE get_net_pay;

      pay_payroll_xml_extract_pkg.load_xml_data('D','NET_PAY',ln_amount);

  END IF;

/*Added the code to display employee and employer country name on pdf payslip  */

    IF p_action_information_category = 'ADDRESS DETAILS' THEN
    OPEN get_employee_country(p_assignment_action_id);
    FETCH get_employee_country INTO ln_employee_country;
    pay_payroll_xml_extract_pkg.load_xml_data('D','EE_COUNTRY',ln_employee_country );
    CLOSE get_employee_country;

    OPEN get_employer_country(p_assignment_action_id);
    FETCH get_employer_country INTO ln_employer_country;
    pay_payroll_xml_extract_pkg.load_xml_data('D','ER_COUNTRY',ln_employer_country );
    CLOSE get_employer_country;

  END IF;

ELSE

     hr_utility.trace('l_payroll_action_id = ' ||
                      to_char(l_payroll_action_id));
     hr_utility.trace('l_override_cpa_code = ' || l_override_cpa_code);

     OPEN cur_ppa(l_payroll_action_id);
     FETCH cur_ppa
     INTO  l_payment_date,
           l_direct_deposit_date;
     CLOSE cur_ppa;

     hr_utility.trace('l_payment_date = ' || to_char(l_payment_date));
     hr_utility.trace('l_direct_deposit_date = ' ||
                       to_char(l_direct_deposit_date));
     SELECT
       decode(l_dd_type, 'NOVA_SCOT',to_char(l_direct_deposit_date,'YYDDD'),
                         'TD', to_char(l_direct_deposit_date,'DDMMYY'),
			 'CPA','0'||to_char(l_direct_deposit_date,'YYDDD'),
			 'CIBC',to_char(l_direct_deposit_date,'YYMMDD'))
     INTO
       l_dd_date
     FROM
       DUAL;

     SELECT
       decode(l_dd_type, 'NOVA_SCOT',to_char(l_payment_date,'YYDDD'),
                         'TD', to_char(l_payment_date,'DDMMYY'),
			 'CPA','0'||to_char(l_payment_date,'YYDDD'),
			 'CIBC',to_char(l_payment_date,'YYMMDD'))
     INTO
       l_payment_date1
     FROM
       DUAL;
     l_text :=
        '<DEPOSIT_DATE_CA>' || l_payment_date1 || '</DEPOSIT_DATE_CA>' ||
        '<FILE_CREATION_DATE_CA>'|| l_dd_date || '</FILE_CREATION_DATE_CA>' ||
        '<OVERRIDE_CPA_CODE>'  || l_override_cpa_code || '</OVERRIDE_CPA_CODE>';

     pay_core_files.write_to_magtape_lob(l_text);
     hr_utility.trace('Add Custom XML ends here .......');

END IF;

   END add_custom_xml;

-- modification for CA PDF Payslip enhancement ends here (Bug 9445414)

FUNCTION work_schedule_total_hours(
                assignment_action_id  IN number   --Context
               ,assignment_id         IN number   --Context
               ,p_bg_id	              IN NUMBER   -- Context
               ,element_entry_id      IN number   --Context
               ,date_earned           IN DATE   --Context
               ,p_range_start	      IN DATE
	             ,p_range_end           IN DATE
               ,p_wk_sch_found   IN OUT NOCOPY VARCHAR2 )
RETURN NUMBER IS

  -- local constants
  c_ws_tab_name	  VARCHAR2(80);

  -- local variables
  v_total_hours	  NUMBER(15,7);
  v_range_start   DATE;
  v_range_end     DATE;
  v_curr_date     DATE;
  v_curr_day      VARCHAR2(3);	-- 3 char abbrev for day of wk.
  v_ws_name       VARCHAR2(80);	-- Work Schedule Name.
  v_gtv_hours     VARCHAR2(80);	-- get_table_value returns varchar2
  v_fnd_sess_row  VARCHAR2(1);
  l_exists        VARCHAR2(1);
  v_day_no        NUMBER;
  p_ws_name       VARCHAR2(80);	-- Work Schedule Name from SCL
  l_id_flex_num   NUMBER;

  CURSOR get_id_flex_num IS
    SELECT rule_mode
      FROM pay_legislation_rules
     WHERE legislation_code = 'CA'
       and rule_type = 'S';

  Cursor get_ws_name (p_id_flex_num number,
                      p_date_earned date,
                      p_assignment_id number) IS
    SELECT target.SEGMENT4
      FROM /* route for SCL keyflex - assignment level */
           hr_soft_coding_keyflex target,
           per_all_assignments_f  ASSIGN
     WHERE p_date_earned BETWEEN ASSIGN.effective_start_date
                             AND ASSIGN.effective_end_date
       AND ASSIGN.assignment_id           = p_assignment_id
       AND target.soft_coding_keyflex_id  = ASSIGN.soft_coding_keyflex_id
       AND target.enabled_flag            = 'Y'
       AND target.id_flex_num             = p_id_flex_num;


BEGIN -- work_schedule_total_hours
  /* Init */
  v_total_hours  := 0;
  c_ws_tab_name  := 'COMPANY WORK SCHEDULES';

  /* get ID FLEX NUM */
  --IF pay_us_rules.g_id_flex_num IS NULL THEN
  hr_utility.trace('Getting ID_FLEX_NUM for CA legislation  ');
  OPEN get_id_flex_num;
  FETCH get_id_flex_num INTO l_id_flex_num;
  -- pay_us_rules.g_id_flex_num := l_id_flex_num;
  CLOSE get_id_flex_num;
  --END IF;

  -- hr_utility.trace('pay_us_rules.g_id_flex_num '||pay_us_rules.g_id_flex_num);
  hr_utility.trace('l_id_flex_num '||l_id_flex_num);
  hr_utility.trace('assignment_action_id=' || assignment_action_id);
  hr_utility.trace('assignment_id='        || assignment_id);
  hr_utility.trace('business_group_id='    || p_bg_id);
  hr_utility.trace('p_range_start='        || p_range_start);
  hr_utility.trace('p_range_end='          || p_range_end);
  hr_utility.trace('element_entry_id='     || element_entry_id);
  hr_utility.trace('date_earned '          || date_earned);

  /* get work schedule_name */
  --IF pay_us_rules.g_id_flex_num IS NOT NULL THEN
  IF l_id_flex_num IS NOT NULL THEN
     hr_utility.trace('getting work schedule name  ');
     OPEN  get_ws_name (l_id_flex_num,--pay_ca_rules.g_id_flex_num,
                        date_earned,
                        assignment_id);
     FETCH get_ws_name INTO p_ws_name;
     CLOSE get_ws_name;
  END IF;

  IF p_ws_name IS NULL THEN
     hr_utility.trace('Work Schedule not found ');
     return 0;
  END IF;

  hr_utility.trace('Work Schedule '||p_ws_name);

  --changed to select the work schedule defined
  --at the business group level instead of
  --hardcoding the default work schedule
  --(COMPANY WORK SCHEDULES ) to the
  --variable  c_ws_tab_name

  begin
    select put.user_table_name
      into c_ws_tab_name
      from hr_organization_information hoi
          ,pay_user_tables put
     where  hoi.organization_id = p_bg_id
       and hoi.org_information_context ='Work Schedule'
       and hoi.org_information1 = put.user_table_id ;

  EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
  end;

  -- Set range to a single week if no dates are entered:
  -- IF (p_range_start IS NULL) AND (p_range_end IS NULL) THEN
  --
  v_range_start := NVL(p_range_start, sysdate);
  v_range_end	:= NVL(p_range_end, sysdate + 6);
  --
  -- END IF;

  -- Check for valid range
  IF v_range_start > v_range_end THEN
  --
     RETURN v_total_hours;
     --  hr_utility.set_message(801,'PAY_xxxx_INVALID_DATE_RANGE');
     --  hr_utility.raise_error;
     --
  END IF;

  -- Get_Table_Value requires row in FND_SESSIONS.  We must insert this
  -- record if one doe not already exist.
  SELECT DECODE(COUNT(session_id), 0, 'N', 'Y')
    INTO v_fnd_sess_row
    FROM fnd_sessions
   WHERE session_id = userenv('sessionid');

  IF v_fnd_sess_row = 'N' THEN
     dt_fndate.set_effective_date(trunc(sysdate));
  END IF;

  --
  -- Track range dates:
  --
  -- Check if the work schedule is an id or a name.  If the work
  -- schedule does not exist, then return 0.
  --
  BEGIN
    select 'Y'
      into l_exists
      from pay_user_tables PUT,
           pay_user_columns PUC
     where PUC.USER_COLUMN_NAME = p_ws_name
       and NVL(PUC.business_group_id, p_bg_id) = p_bg_id
       and NVL(PUC.legislation_code,'CA') = 'CA'
       and PUC.user_table_id = PUT.user_table_id
       and PUT.user_table_name = c_ws_tab_name;


  EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
  END;

  if l_exists = 'Y' then
     v_ws_name := p_ws_name;
  else
     BEGIN
        select PUC.USER_COLUMN_NAME
        into v_ws_name
        from  pay_user_tables PUT,
              pay_user_columns PUC
        where PUC.USER_COLUMN_ID = p_ws_name
          and NVL(PUC.business_group_id, p_bg_id) = p_bg_id
          and NVL(PUC.legislation_code,'CA') = 'CA'
          and PUC.user_table_id = PUT.user_table_id
          and PUT.user_table_name = c_ws_tab_name;

     EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN v_total_hours;
     END;
  end if;

  v_curr_date := v_range_start;

  LOOP

    v_day_no := TO_CHAR(v_curr_date, 'D');


    SELECT decode(v_day_no,1,'SUN',2,'MON',3,'TUE',
                           4,'WED',5,'THU',6,'FRI',7,'SAT')
    INTO v_curr_day
    FROM DUAL;

    v_total_hours := v_total_hours +
                     FND_NUMBER.CANONICAL_TO_NUMBER(
                                 hruserdt.get_table_value(p_bg_id,
                                                          c_ws_tab_name,
                                                          v_ws_name,
                                                          v_curr_day));
    v_curr_date := v_curr_date + 1;


    EXIT WHEN v_curr_date > v_range_end;

  END LOOP;

  p_wk_sch_found := 'TRUE'; -- For bug 8459792

  RETURN v_total_hours;

END work_schedule_total_hours;

PROCEDURE get_file_creation_no(
   pactid IN NUMBER,
   file_no OUT NOCOPY NUMBER) AS

   l_override_file_no VARCHAR2(20);

   CURSOR cur_paid IS
   SELECT
     legislative_parameters,
     business_group_id,
     org_payment_method_id
   FROM
     pay_payroll_actions
   WHERE
     payroll_action_id = pactid;

   l_legislative_parameter  pay_payroll_actions.legislative_parameters%TYPE;
   l_bg_id                  pay_payroll_actions.business_group_id%TYPE;
   l_org_pm_id              pay_payroll_actions.org_payment_method_id%TYPE;
   l_dd_format              VARCHAR2(30);

BEGIN

  hr_utility.trace('Starting pay_ca_rules.get_file_creation_number !!!!');

  OPEN cur_paid;
  FETCH cur_paid
  INTO  l_legislative_parameter,
        l_bg_id,
        l_org_pm_id;
  CLOSE cur_paid;


  l_override_file_no :=
        pay_core_utils.get_parameter('FILE_CREATION_NUMBER_OVERRIDE',
                                      l_legislative_parameter);
  l_dd_format := pay_core_utils.get_parameter('MAGTAPE_REPORT_ID',
                                             l_legislative_parameter);

  hr_utility.trace('payroll_action_id = ' || to_char(pactid));
  hr_utility.trace('l_org_pm_id = ' || to_char(l_org_pm_id));
  hr_utility.trace('l_bg_id = ' || to_char(l_bg_id));
  hr_utility.trace('l_legislative_parameter = ' || l_legislative_parameter);
  hr_utility.trace('l_override_file_no = ' || l_override_file_no);
  hr_utility.trace('l_dd_format = ' || l_dd_format);

  IF l_override_file_no IS NOT NULL THEN
    file_no := l_override_file_no;
  ELSE
    file_no := pay_ca_direct_deposit_pkg.get_dd_file_creation_number(
                          l_org_pm_id,
                          l_dd_format,
                          l_override_file_no,
                          pactid ,
                          l_bg_id) ;
  END IF;

  hr_utility.trace('file_no = ' || file_no);
  hr_utility.trace('Ending pay_ca_rules.get_file_creation_number !!!!');

END get_file_creation_no;

end pay_ca_rules;

/
