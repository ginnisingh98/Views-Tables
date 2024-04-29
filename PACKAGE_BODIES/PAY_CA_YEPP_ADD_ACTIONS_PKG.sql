--------------------------------------------------------
--  DDL for Package Body PAY_CA_YEPP_ADD_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_YEPP_ADD_ACTIONS_PKG" AS
/* $Header: pycayeaa.pkb 120.0.12010000.2 2008/09/16 10:09:27 sapalani ship $ */
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

    Name        : pay_ca_yepp_add_actions_pkg

    Description : Package used to report the Employees which are not
                  picked up by the Year End Process and mark them for
                  retry. It is used by the concurrent request -
                 'Add Assignment Actions to Year End Preprocess'

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    18-Oct-2004 ssouresr   115.0            Created.
    06-Nov-2004 ssouresr   115.1            Corrected the cursor c_all_gres
    16-Sep-2008 sapalani   115.2   7392645  Replaced correct report type in
                                            cursors c_rl1_magtape_run_exists
                                            and c_rl2_magtape_run_exists
  ********************************************************************/

  gv_title               VARCHAR2(100);
  gv_package_name        VARCHAR2(50) := 'pay_ca_yepp_add_actions_pkg';
  gv_sec_asg_reported    VARCHAR2(1)  := 'N';


 /********************************************************************
  Function to display the Titles of the columns of the employee details
  ********************************************************************/

  FUNCTION formated_header_string (p_report_type       in varchar2,
                                   p_output_file_type  in varchar2)
  RETURN varchar2
  IS

    lv_format1          varchar2(32000);
    lv_year_heading     varchar2(200);
    lv_gre_heading      varchar2(200);
    lv_pre_heading      varchar2(200);
    lv_emp_name_heading varchar2(200);
    lv_emp_sin_heading  varchar2(200);
    lv_emp_num_heading  varchar2(200);

   BEGIN

     lv_year_heading     := hr_general.decode_lookup('PAY_CA_MISSING_ASG','YEAR');
     lv_emp_name_heading := hr_general.decode_lookup('PAY_CA_MISSING_ASG','EMP_NAME');
     lv_emp_sin_heading  := hr_general.decode_lookup('PAY_CA_MISSING_ASG','EMP_SIN');
     lv_emp_num_heading  := hr_general.decode_lookup('PAY_CA_MISSING_ASG','EMP_NUM');

     if p_report_type in ('T4','T4A') then

       lv_gre_heading      := hr_general.decode_lookup('PAY_CA_MISSING_ASG','GRE');

       lv_format1 :=
          pay_us_payroll_utils.formated_data_string
                            (p_input_string => lv_year_heading
                            ,p_bold         => 'Y'
                            ,p_output_file_type => p_output_file_type) ||
          pay_us_payroll_utils.formated_data_string
                            (p_input_string => lv_gre_heading
                            ,p_bold         => 'Y'
                            ,p_output_file_type => p_output_file_type) ||
          pay_us_payroll_utils.formated_data_string
                            (p_input_string => lv_emp_name_heading
                            ,p_bold         => 'Y'
                            ,p_output_file_type => p_output_file_type) ||
          pay_us_payroll_utils.formated_data_string
                            (p_input_string => lv_emp_sin_heading
                            ,p_bold         => 'Y'
                            ,p_output_file_type => p_output_file_type) ||
          pay_us_payroll_utils.formated_data_string
                            (p_input_string => lv_emp_num_heading
                            ,p_bold         => 'Y'
                            ,p_output_file_type => p_output_file_type);

    elsif p_report_type in ('RL1','RL2') then

      lv_pre_heading      := hr_general.decode_lookup('PAY_CA_MISSING_ASG','PRE');

      lv_format1 :=
          pay_us_payroll_utils.formated_data_string
                            (p_input_string => lv_year_heading
                            ,p_bold         => 'Y'
                            ,p_output_file_type => p_output_file_type) ||
          pay_us_payroll_utils.formated_data_string
                            (p_input_string => lv_pre_heading
                            ,p_bold         => 'Y'
                            ,p_output_file_type => p_output_file_type) ||
          pay_us_payroll_utils.formated_data_string
                            (p_input_string => lv_emp_name_heading
                            ,p_bold         => 'Y'
                            ,p_output_file_type => p_output_file_type) ||
          pay_us_payroll_utils.formated_data_string
                            (p_input_string => lv_emp_sin_heading
                            ,p_bold         => 'Y'
                            ,p_output_file_type => p_output_file_type) ||
          pay_us_payroll_utils.formated_data_string
                            (p_input_string => lv_emp_num_heading
                            ,p_bold         => 'Y'
                            ,p_output_file_type => p_output_file_type);
     end if;

     return lv_format1 ;

   EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in gv_package_name' || '.formated_header_string');
        RAISE;

   END formated_header_string;



 /********************************************************************
  Function to display the details of the selected employee
  ********************************************************************/

  FUNCTION  formated_detail_string(
              p_output_file_type  in varchar2
             ,p_year                 varchar2
             ,p_gre_name             varchar2
             ,p_pre_name             varchar2
             ,p_employee_name        varchar2
             ,p_employee_sin         varchar2
             ,p_employee_number      varchar2
             ,p_report_type          varchar2
             ) RETURN varchar2
   IS

    lv_format1          varchar2(22000);

   BEGIN

     if p_report_type in ('T4','T4A') then

        lv_format1 :=
          pay_us_payroll_utils.formated_data_string
                               (p_input_string => p_year
                               ,p_bold         => 'N'
                               ,p_output_file_type => p_output_file_type) ||
          pay_us_payroll_utils.formated_data_string
                               (p_input_string => p_gre_name
                               ,p_bold         => 'N'
                               ,p_output_file_type => p_output_file_type) ||
          pay_us_payroll_utils.formated_data_string
                               (p_input_string => p_employee_name
                               ,p_bold         => 'N'
                               ,p_output_file_type => p_output_file_type) ||
          pay_us_payroll_utils.formated_data_string
                               (p_input_string => p_employee_sin
                               ,p_bold         => 'N'
                               ,p_output_file_type => p_output_file_type) ||
          pay_us_payroll_utils.formated_data_string
                               (p_input_string => p_employee_number
                               ,p_bold         => 'N'
                               ,p_output_file_type => p_output_file_type);

    elsif p_report_type in ('RL1','RL2') then

        lv_format1 :=
          pay_us_payroll_utils.formated_data_string
                               (p_input_string => p_year
                               ,p_bold         => 'N'
                               ,p_output_file_type => p_output_file_type) ||
          pay_us_payroll_utils.formated_data_string
                               (p_input_string => p_pre_name
                               ,p_bold         => 'N'
                               ,p_output_file_type => p_output_file_type) ||
          pay_us_payroll_utils.formated_data_string
                               (p_input_string => p_employee_name
                               ,p_bold         => 'N'
                               ,p_output_file_type => p_output_file_type) ||
          pay_us_payroll_utils.formated_data_string
                               (p_input_string => p_employee_sin
                               ,p_bold         => 'N'
                               ,p_output_file_type => p_output_file_type) ||
          pay_us_payroll_utils.formated_data_string
                               (p_input_string => p_employee_number
                               ,p_bold         => 'N'
                               ,p_output_file_type => p_output_file_type);

    end if;

    return lv_format1;

   EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '|| gv_package_name || '.formated_detail_string');
        raise;

   END formated_detail_string;


 /********************************************************************
  Procedure to display message if no employees are selected for
  any of the four sections -
  - Processed Assignments
  - Eligible Assignments
  - Not Eligible Assignments
  ********************************************************************/

  PROCEDURE  formated_zero_count(output_file_type varchar2,
                                 p_flag varchar2)
   IS
      lvc_message1 varchar2(200);
      lvc_message2 varchar2(200);
      lvc_message3 varchar2(200);

   BEGIN

     lvc_message1 :=   '1. '|| hr_general.decode_lookup('PAY_CA_MISSING_ASG','PROCESSED_NONE');
     lvc_message2 :=   '2. '|| hr_general.decode_lookup('PAY_CA_MISSING_ASG','ELIGIBLE_NONE');
     lvc_message3 :=   '3. '|| hr_general.decode_lookup('PAY_CA_MISSING_ASG','NONELIGIBLE_NONE');

     if output_file_type = 'HTML' then
        lvc_message1 := '<H4> '||lvc_message1||' </H4>';
	lvc_message2 := '<H4> '||lvc_message2||' </H4>';
	lvc_message3 := '<H4> '||lvc_message3||' </H4>';
     end if;

     if p_flag='PROCESSED' then
        fnd_file.put_line(fnd_file.output,lvc_message1);
     end if;

     hr_utility.set_location(gv_package_name || '.formated_zero_count', 20);

     if p_flag='ELGBLE' then
        fnd_file.put_line(fnd_file.output, lvc_message2);
     end if;

     hr_utility.set_location(gv_package_name || '.formated_zero_count', 30);

     if p_flag='NOTELGBLE' then
        fnd_file.put_line(fnd_file.output, lvc_message3);
     end if;

     hr_utility.set_location(gv_package_name || '.formated_zero_count', 40);

   EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '|| gv_package_name || '.formated_zero_count');
        RAISE;

   END formated_zero_count;



 /********************************************************************
  Procedure to print the table in HTML format
  ********************************************************************/

  PROCEDURE print_table_header (p_header_text      in varchar2,
                                p_report_type      in varchar2,
                                p_output_file_type in varchar2)
   IS
    l_header_text  varchar2(200);
   BEGIN
     hr_utility.set_location(gv_package_name || '.print_table_header', 10);
     l_header_text  := p_header_text ;

     if p_output_file_type = 'HTML' then
        l_header_text := '<H4> '||l_header_text||' </H4>';
     end if;

     fnd_file.put_line(fnd_file.output,l_header_text);

     if p_output_file_type ='HTML' then
        fnd_file.put_line(fnd_file.output, '<table border=1 align=center>');
        fnd_file.put_line(fnd_file.output, '<tr>');
     end if;

     hr_utility.set_location(gv_package_name || '.print_table_header', 20);

     fnd_file.put_line(fnd_file.output,formated_header_string(p_report_type, p_output_file_type));

     if p_output_file_type ='HTML' then
        fnd_file.put_line(fnd_file.output, '</tr>');
     end if;

    EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '|| gv_package_name || '.print_table_header');
        RAISE;
   END print_table_header;


   FUNCTION get_parameter(name in varchar2,
                          parameter_list varchar2)
   RETURN varchar2
   IS
     start_ptr number;
     end_ptr   number;
     token_val pay_payroll_actions.legislative_parameters%type;
     par_value pay_payroll_actions.legislative_parameters%type;

   BEGIN

        token_val := name||'=';

        start_ptr := instr(parameter_list, token_val) + length(token_val);
        end_ptr := instr(parameter_list, ' ', start_ptr);

   /* if there is no spaces use then length of the string  */
        if end_ptr = 0 then
           end_ptr := length(parameter_list)+1;
        end if;

   /*      Did we find the token  */
        if instr(parameter_list, token_val) = 0 then
          par_value := NULL;
        else
          par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
        end if;

        return par_value;

   END get_parameter;


 /********************************************************************
  Main procedure called from the concurrent program.
  Name: add_actions_to_yepp

  Description: The input parameters for the procedure are Date,GRE,PRE,
               Assignment Set and output file type from the concurrent
               program. The procedure identifies the eligible/processed
               /not eligible and secondary assignments from the
               Assignment set and report them as the output in the
               specified format.

  ********************************************************************/

  PROCEDURE add_actions_to_yepp(errbuf           out  nocopy    varchar2,
                                retcode          out  nocopy    number,
                                p_effective_date in             varchar2,
                                p_bus_grp        in             number,
                                p_report_type    in             varchar2,
                                p_dummy1         in             varchar2,
                                p_gre_id         in             number,
                                p_dummy2         in             varchar2,
                                p_pre_id         in             number,
                                p_assign_set     in             varchar2,
                                p_output_file_type in           varchar2)
  IS

   cursor c_t4_magtape_run_exists(cp_effective_date    date,
                                  cp_business_group_id number,
                                  cp_gre_id            number) is
   select 1 from dual
   where exists
               (select 'X'
                from hr_organization_information mag,
                     hr_organization_information gre,
                     hr_all_organization_units   hou,
                     pay_payroll_actions         ppa
                where hou.business_group_id       = cp_business_group_id
                and   hou.organization_id         = gre.organization_id
                and   gre.org_information_context = 'Canada Employer Identification'
                and   gre.organization_id         = cp_gre_id
                and   gre.org_information11       = get_parameter('TRANSMITTER_GRE',ppa.legislative_parameters)
                and   ppa.business_group_id+0     = cp_business_group_id
                and   ppa.effective_date + 0      = add_months(cp_effective_date,12) - 1
                and   ppa.action_status           = 'C'
                and   ppa.report_type             = 'PYT4MAG'
                and   mag.org_information_context = 'Fed Magnetic Reporting'
                and   mag.organization_id         = to_number(gre.org_information11) );


   cursor c_t4a_magtape_run_exists(cp_effective_date    date,
                                   cp_business_group_id number,
                                   cp_gre_id            number) is
   select 1 from dual
   where exists
               (select 'X'
                from hr_organization_information mag,
                     hr_organization_information gre,
                     hr_all_organization_units   hou,
                     pay_payroll_actions         ppa
                where hou.business_group_id       = cp_business_group_id
                and   hou.organization_id         = gre.organization_id
                and   gre.org_information_context = 'Canada Employer Identification'
                and   gre.organization_id         = cp_gre_id
                and   gre.org_information11       = get_parameter('TRANSMITTER_GRE',ppa.legislative_parameters)
                and   ppa.business_group_id+0     = cp_business_group_id
                and   ppa.effective_date + 0      = add_months(cp_effective_date,12) - 1
                and   ppa.action_status           = 'C'
                and   ppa.report_type             = 'MAG_T4A'
                and   mag.org_information_context = 'Fed Magnetic Reporting'
                and   mag.organization_id         = to_number(gre.org_information11) );


   cursor c_rl1_magtape_run_exists(cp_effective_date    date,
                                   cp_business_group_id number,
                                   cp_pre_id            number) is
   select 1 from dual
   where exists
               (select 'X'
                from hr_organization_information pre,
                     hr_all_organization_units   hou,
                     pay_payroll_actions         ppa
                where hou.business_group_id       = cp_business_group_id
                and   hou.organization_id         = pre.organization_id
                and   pre.org_information4        = 'P01'
                and   pre.org_information_context = 'Prov Reporting Est'
                and   pre.organization_id         = cp_pre_id
                and   decode(pre.org_information3, 'Y', to_char(pre.organization_id), pre.org_information20) =
                                             get_parameter('TRANSMITTER_PRE',ppa.legislative_parameters)
                and   ppa.business_group_id+0     = cp_business_group_id
                and   ppa.effective_date + 0      = add_months(cp_effective_date,12) - 1
                and   ppa.action_status           = 'C'
                and   ppa.report_type             = 'RL1_XML_MAG'); --Bug 7392645


   cursor c_rl2_magtape_run_exists(cp_effective_date    date,
                                   cp_business_group_id number,
                                   cp_pre_id            number) is
   select 1 from dual
   where exists
               (select 'X'
                from hr_organization_information pre,
                     hr_all_organization_units   hou,
                     pay_payroll_actions         ppa
                where hou.business_group_id       = cp_business_group_id
                and   hou.organization_id         = pre.organization_id
                and   pre.org_information4        = 'P02'
                and   pre.org_information_context = 'Prov Reporting Est'
                and   pre.organization_id         = cp_pre_id
                and   decode(pre.org_information3, 'Y', to_char(pre.organization_id), pre.org_information20) =
                                             get_parameter('TRANSMITTER_PRE',ppa.legislative_parameters)
                and   ppa.business_group_id+0     = cp_business_group_id
                and   ppa.effective_date + 0      = add_months(cp_effective_date,12) - 1
                and   ppa.action_status           = 'C'
                and   ppa.report_type             = 'RL2_XML_MAG'); ----Bug 7392645


   -- Cursor to get the GRE or PRE Name

   cursor c_name (cp_org_id number) is
   select name
   from hr_all_organization_units_tl
   where organization_id  = cp_org_id
   and   language         = userenv('LANG');

   -- Cursor to get person_id of the assignments selected

   cursor c_person_id (cp_assign_id number) is
   select person_id
   from per_all_assignments_f
   where assignment_id = cp_assign_id;

   -- Cursor to get Employee details

   cursor c_employee_details (cp_person_id number ) is
   select full_name,national_identifier
   from per_all_people_f
   where  person_id   = cp_person_id;

   cursor c_assignment_no (cp_assign_id number ) is
   select assignment_number
   from per_all_assignments_f
   where  assignment_id   = cp_assign_id;

   lv_person_id            per_all_people_f.person_id%type;
   lv_gre_name             hr_all_organization_units_tl.name%type;
   lv_pre_name             hr_all_organization_units_tl.name%type;
   lv_emp_name             per_all_people_f.full_name%type;
   lv_emp_no               per_all_people_f.employee_number%type;
   lv_emp_sin              per_all_people_f.national_identifier%type;
   lv_data_row             varchar2(4000);
   l_assignment_inserted   number :=0;
   l_effective_date        date;
   l_temp                  number;
   l_mag_exists            number := 0;

   l_elgbl_table_header    varchar2(200);
   l_prced_table_header    varchar2(200);
   l_nonelgbl_table_header varchar2(200);
   l_secasg_table_header   varchar2(200);
   l_othasg_table_header   varchar2(200);

   /******************************************************************
    Procedure get_eligible_assignments_fed
    Description : Gets the list of all assignments eligible for
                  the archive by year end process and mark them for retry.
    ******************************************************************/

    PROCEDURE get_eligible_assignments_fed(p_effective_date    in date,
                                           p_gre_id            in number,
                                           p_assignment_set_id in number,
                                           p_report_type       in varchar2)
    IS

     cursor c_get_person_id (cp_assign_set_id  number) is
     select distinct paf.person_id
     from hr_assignment_set_amendments has,
          per_all_assignments_f paf
     where has.assignment_set_id      = cp_assign_set_id
     and   has.include_or_exclude     = 'I'
     and   paf.assignment_id          = has.assignment_id
     and   paf.assignment_type        = 'E'
     and   paf.business_group_id+ 0   = p_bus_grp;

     /* Cursor to get the latest assignment_action_id based
        on person_id */
     cursor c_get_latest_asg (cp_person_id      number,
                              cp_gre_id         number,
                              cp_effective_date date) is
     select paa.assignment_action_id
     from pay_assignment_actions     paa,
          per_all_assignments_f      paf,
          pay_payroll_actions        ppa,
          pay_action_classifications pac
     where paf.person_id         = cp_person_id
     and paa.assignment_id       = paf.assignment_id
     and paa.tax_unit_id         = cp_gre_id
     and paa.payroll_action_id   = ppa.payroll_action_id
     and ppa.business_group_id+0 = p_bus_grp
     and ppa.action_type         = pac.action_type
     and pac.classification_name = 'SEQUENCED'
     and ppa.effective_date +0 between paf.effective_start_date
                                   and paf.effective_end_date
     and ppa.effective_date +0 between cp_effective_date
                                   and add_months(cp_effective_date, 12) - 1
     and ((nvl(paa.run_type_id, ppa.run_type_id) is null
           and  paa.source_action_id is null)
       or (nvl(paa.run_type_id, ppa.run_type_id) is not null
           and paa.source_action_id is not null)
       or (ppa.action_type = 'V'
           and ppa.run_type_id is null
           and paa.run_type_id is not null
           and paa.source_action_id is null))
     and not exists (select 1
                     from pay_payroll_actions    ppa1,
                          pay_assignment_actions paa1
                     where ppa1.report_type = p_report_type
                     and ppa1.business_group_id+0 = p_bus_grp
                     and ppa1.effective_date = add_months(cp_effective_date, 12) - 1
                     and to_number(get_parameter('TRANSFER_GRE',
                                                 ppa1.legislative_parameters)) = cp_gre_id
                     and ppa1.payroll_action_id = paa1.payroll_action_id
                     and paa1.serial_number = to_char(paf.person_id))
     order by paa.action_sequence desc;


  /* Cursor to get details of payroll action of the Year End Pre-Process */
     cursor get_yepp_payroll_action(cp_effective_date date,
                                    cp_gre_id         number) is
     select payroll_action_id
     from pay_payroll_actions
     where action_type = 'X'
     and action_status = 'C'
     and report_type   = p_report_type
     and business_group_id+0 = p_bus_grp
     and to_number(get_parameter('TRANSFER_GRE',legislative_parameters)) = cp_gre_id
     and effective_date = add_months(cp_effective_date, 12) - 1;

   /* we should always be stamping the primary assignment_id, even
      if the assignment selected in the assignment set is secondary
      Get the primary assignment for the given person_id */

     cursor c_get_asg_id (cp_person_id number) is
     select assignment_id
     from per_all_assignments_f paf
     where person_id       = cp_person_id
     and   primary_flag    = 'Y'
     and   assignment_type = 'E'
     and   paf.effective_start_date  <= add_months(p_effective_date, 12) - 1
     and   paf.effective_end_date    >= p_effective_date
     order by assignment_id desc;

     l_bal_aaid               pay_assignment_actions.assignment_action_id%type;
     ln_non_taxable_earnings  number(30);
     ln_gross_earnings        number(30);
     ln_no_gross_earnings     number(30);
     l_assignment_id          per_all_assignments_f.assignment_id%type;
     l_person_id              per_all_assignments_f.person_id%type;
     l_yepp_payroll_action_id pay_payroll_actions.payroll_action_id%type;
     lockingactid             pay_assignment_actions.assignment_action_id%type;
     l_prev_person_id         per_all_assignments_f.person_id%type;

    BEGIN

     hr_utility.set_location(gv_package_name || '.get_eligible_assignments_fed', 10);

     open get_yepp_payroll_action(p_effective_date,
            			  p_gre_id);
     fetch get_yepp_payroll_action into l_yepp_payroll_action_id;
     close get_yepp_payroll_action ;

     open c_get_person_id (p_assignment_set_id);
     loop

         fetch c_get_person_id into l_person_id;
         exit when c_get_person_id%NOTFOUND;

         l_bal_aaid              := 0;
         ln_non_taxable_earnings := 0;
         ln_gross_earnings       := 0;
         ln_no_gross_earnings    := 0;

     /* Get the latest assignment action of selected person */

         open c_get_latest_asg(l_person_id,
                               p_gre_id,
                               p_effective_date);
         fetch c_get_latest_asg into l_bal_aaid;

         if c_get_latest_asg%NOTFOUND then
            l_bal_aaid := -9999;
         end if;

         close c_get_latest_asg;


         hr_utility.set_location(gv_package_name || '.get_eligible_assignments_fed', 40);

         if (l_prev_person_id <> l_person_id) or
            (l_prev_person_id is null)  then

            l_prev_person_id := l_person_id;

            if l_bal_aaid <> -9999 then

               hr_utility.trace('bal_aaid = '||to_char(l_bal_aaid));

               hr_utility.trace('Setting context');

               pay_ca_balance_view_pkg.set_context('TAX_UNIT_ID',p_gre_id);
               pay_ca_balance_view_pkg.set_context ('ASSIGNMENT_ACTION_ID',l_bal_aaid);


               hr_utility.trace('person_id = '||to_char(l_person_id));

          /* Get the primary assignment */

               open c_get_asg_id(l_person_id);
               fetch c_get_asg_id into l_assignment_id;
               if c_get_asg_id%NOTFOUND then
                  close c_get_asg_id;
                  hr_utility.trace('Primary asg not found');
                  hr_utility.raise_error;
               else
                  close c_get_asg_id;
               end if;

               if p_report_type = 'T4' then

                 ln_non_taxable_earnings :=
                      nvl(pay_ca_balance_pkg.call_ca_balance_get_value('T4 Non Taxable Earnings',
                           'YTD',l_bal_aaid, l_assignment_id,NULL,'PER',p_gre_id,p_bus_grp,NULL),
                          0);

                 hr_utility.trace('T4 Non Taxable Earnings :'||
                             to_char(ln_non_taxable_earnings));

                 ln_gross_earnings :=
                      nvl(pay_ca_balance_pkg.call_ca_balance_get_value('Gross Earnings',
                           'YTD',l_bal_aaid, l_assignment_id,NULL,'PER',p_gre_id,p_bus_grp,NULL),
                          0);

                 hr_utility.trace('Gross Earnings :'||
                             to_char(ln_gross_earnings));

                 ln_no_gross_earnings :=
                      nvl(pay_ca_balance_pkg.call_ca_balance_get_value('T4 No Gross Earnings',
                           'YTD',l_bal_aaid, l_assignment_id,NULL,'PER',p_gre_id,p_bus_grp,NULL),
                          0);

                 hr_utility.trace('T4 No Gross Earnings :'||
                             to_char(ln_no_gross_earnings));


                 if (((ln_gross_earnings <> 0) and
                     (ln_non_taxable_earnings <> ln_gross_earnings)) or
                     (ln_no_gross_earnings <> 0)) then

                     hr_utility.set_location(gv_package_name || '.get_eligible_assignments_fed', 100);

                     select pay_assignment_actions_s.nextval
                     into  lockingactid
                     from  dual;

                     hr_utility.trace('creating asg action');

                     hr_nonrun_asact.insact(lockingactid  => lockingactid,
	     	              	            assignid      => l_assignment_id,
			                    pactid        => l_yepp_payroll_action_id,
			                    chunk         => '1',
			                    greid         => p_gre_id,
			                    status        => 'M');

                     hr_utility.set_location(gv_package_name || '.get_eligible_assignments_fed', 110);

                     update pay_assignment_actions aa
                     set    aa.serial_number = to_char(l_person_id)
                     where  aa.assignment_action_id = lockingactid;

                     l_yepp_elgble_asg_table(l_assignment_id).c_assignment_id := l_assignment_id;
	             l_all_reported_asg_table(l_assignment_id).c_assignment_id := l_assignment_id;

                 end if;

           elsif p_report_type = 'T4A' then

                 ln_gross_earnings :=
                      nvl(pay_ca_balance_pkg.call_ca_balance_get_value('Gross Earnings',
                           'YTD',l_bal_aaid, l_assignment_id,NULL,'PER',p_gre_id,p_bus_grp,NULL),
                          0);

                 hr_utility.trace('Gross Earnings :'||
                             to_char(ln_gross_earnings));

                 ln_no_gross_earnings :=
                      nvl(pay_ca_balance_pkg.call_ca_balance_get_value('T4A No Gross Earnings',
                           'YTD',l_bal_aaid, l_assignment_id,NULL,'PER',p_gre_id,p_bus_grp,NULL),
                          0);

                 hr_utility.trace('T4A No Gross Earnings :'||
                             to_char(ln_no_gross_earnings));

                 if ((ln_gross_earnings <> 0) or
                     (ln_no_gross_earnings <> 0)) then

                     hr_utility.set_location(gv_package_name || '.get_eligible_assignments_fed', 130);

                     select pay_assignment_actions_s.nextval
                     into  lockingactid
                     from  dual;

                     hr_utility.trace('creating asg action');

                     hr_nonrun_asact.insact(lockingactid  => lockingactid,
	     	              	            assignid      => l_assignment_id,
			                    pactid        => l_yepp_payroll_action_id,
			                    chunk         => '1',
			                    greid         => p_gre_id,
			                    status        => 'M');

                     hr_utility.set_location(gv_package_name || '.get_eligible_assignments_fed', 140);

                     update pay_assignment_actions aa
                     set    aa.serial_number = to_char(l_person_id)
                     where  aa.assignment_action_id = lockingactid;

                     l_yepp_elgble_asg_table(l_assignment_id).c_assignment_id := l_assignment_id;
	             l_all_reported_asg_table(l_assignment_id).c_assignment_id := l_assignment_id;

                 end if;

           end if; /* p_report_type */

         end if; /* l_bal_aaid <> -9999 */

      end if; /* l_prev_person_id <> l_person_id */

     end loop;
     close c_get_person_id;

     EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '|| gv_package_name || '.get_eligible_assignments_fed');
        raise;

    END get_eligible_assignments_fed;


   /******************************************************************
    Procedure get_eligible_assignments_prov
    Description : Gets the list of all assignments eligible for the provincial
                  archivers by year end process and mark them for retry.
    ******************************************************************/

    PROCEDURE get_eligible_assignments_prov (p_effective_date    in date,
                                             p_pre_id            in number,
                                             p_assignment_set_id in number,
                                             p_report_type       in varchar2)
    IS

     cursor c_get_person_id (cp_assign_set_id  number) is
     select distinct paf.person_id
     from hr_assignment_set_amendments has,
          per_all_assignments_f paf
     where has.assignment_set_id      = cp_assign_set_id
     and   has.include_or_exclude     = 'I'
     and   paf.assignment_id          = has.assignment_id
     and   paf.assignment_type        = 'E'
     and   paf.business_group_id+0    = p_bus_grp;

     cursor c_all_gres is
     select hoi.organization_id
     from hr_organization_information hoi,
          hr_all_organization_units   hou
     where hoi.org_information_context = 'Canada Employer Identification'
     and   hoi.org_information2        = to_char(p_pre_id)
     and   hou.business_group_id       = p_bus_grp
     and   hou.organization_id         = hoi.organization_id;

     /* Cursor to get the latest assignment_action_id based
        on person_id */
     cursor c_get_latest_asg (cp_person_id      number,
                              cp_gre_id         number,
                              cp_effective_date date) is
     select paa.assignment_action_id
     from pay_assignment_actions     paa,
          per_all_assignments_f      paf,
          per_all_people_f           ppf,
          pay_payroll_actions        ppa,
          pay_action_classifications pac
     where ppf.person_id   = cp_person_id
     and paf.person_id     = ppf.person_id
     and paa.assignment_id = paf.assignment_id
     and paa.tax_unit_id         = cp_gre_id
     and ppa.business_group_id+0 = p_bus_grp
     and ppa.payroll_action_id = paa.payroll_action_id
     and ppa.effective_date between ppf.effective_start_date
                                and ppf.effective_end_date
     and ppa.effective_date between paf.effective_start_date
                                and paf.effective_end_date
     and ppa.effective_date between cp_effective_date
                                and add_months(cp_effective_date, 12) - 1
     and ppa.action_type = pac.action_type
     and pac.classification_name = 'SEQUENCED'
     and not exists (select 1
                     from pay_payroll_actions    ppa1,
                          pay_assignment_actions paa1
                     where ppa1.report_type = p_report_type
                     and ppa1.business_group_id+0 = p_bus_grp
                     and ppa1.effective_date = add_months(cp_effective_date, 12) - 1
                     and to_number(get_parameter('PRE_ORGANIZATION_ID',
                                                 ppa1.legislative_parameters)) = p_pre_id
                     and ppa1.payroll_action_id = paa1.payroll_action_id
                     and paa1.serial_number = to_char(paf.person_id))
     order by paa.action_sequence desc;


     cursor get_yepp_payroll_action(cp_effective_date date,
                                    cp_pre_id         number) is
     select payroll_action_id
     from pay_payroll_actions
     where action_type = 'X'
     and action_status = 'C'
     and report_type   = p_report_type
     and business_group_id+0 = p_bus_grp
     and to_number(get_parameter('PRE_ORGANIZATION_ID',legislative_parameters)) = cp_pre_id
     and effective_date = add_months(cp_effective_date, 12) - 1;

   /* we should always be stamping the primary assignment_id, even
      if the assignment selected in the assignment set is secondary
      Get the primary assignment for the given person_id */

     cursor c_get_asg_id (cp_person_id number) is
     select assignment_id
     from per_all_assignments_f paf
     where person_id       = cp_person_id
     and   primary_flag    = 'Y'
     and   assignment_type = 'E'
     and   paf.effective_start_date  <= add_months(p_effective_date, 12) - 1
     and   paf.effective_end_date    >= p_effective_date
     order by assignment_id desc;

     l_bal_aaid               pay_assignment_actions.assignment_action_id%type;
     ln_non_taxable_earnings  number(30);
     ln_gross_earnings        number(30);
     ln_no_gross_earnings     number(30);
     l_assignment_id          per_all_assignments_f.assignment_id%type;
     l_person_id              per_all_assignments_f.person_id%type;
     l_prev_person_id         per_all_assignments_f.person_id%type;
     l_yepp_payroll_action_id pay_payroll_actions.payroll_action_id%type;
     lockingactid             pay_assignment_actions.assignment_action_id%type;
     l_tax_unit_id            pay_assignment_actions.tax_unit_id%type;

    BEGIN

     hr_utility.set_location(gv_package_name || '.get_eligible_assignments_prov', 10);

     open get_yepp_payroll_action(p_effective_date,
            			  p_pre_id);
     fetch get_yepp_payroll_action into l_yepp_payroll_action_id;
     close get_yepp_payroll_action ;

     open c_get_person_id (p_assignment_set_id);
     loop

         fetch c_get_person_id into l_person_id;
         exit when c_get_person_id%NOTFOUND;

         if (l_prev_person_id <> l_person_id) or
            (l_prev_person_id is null)  then

            l_prev_person_id := l_person_id;

            l_bal_aaid              := 0;
            ln_non_taxable_earnings := 0;
            ln_gross_earnings       := 0;
            ln_no_gross_earnings    := 0;

            open c_get_asg_id (l_person_id);
            fetch c_get_asg_id into l_assignment_id;
            if c_get_asg_id%NOTFOUND then
               close c_get_asg_id;
               hr_utility.trace('Primary asg not found');
               hr_utility.raise_error;
            else
               close c_get_asg_id;
            end if;

            open c_all_gres;
            loop

                fetch c_all_gres into l_tax_unit_id;
                exit when c_all_gres%NOTFOUND;

               /* Get the latest assignment action of selected person */

                open c_get_latest_asg(l_person_id,
                                      l_tax_unit_id,
                                      p_effective_date);
                fetch c_get_latest_asg into l_bal_aaid;

                if c_get_latest_asg%NOTFOUND then
                   l_bal_aaid := -9999;
                end if;

                close c_get_latest_asg;

                if l_bal_aaid <> -9999 then

                   hr_utility.trace('Setting context');

                   pay_ca_balance_view_pkg.set_context('TAX_UNIT_ID',l_tax_unit_id);
                   pay_ca_balance_view_pkg.set_context('ASSIGNMENT_ACTION_ID',l_bal_aaid);

                   if p_report_type = 'RL1' then

                      ln_gross_earnings := ln_gross_earnings +
                                nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                                ('Gross Earnings','YTD',l_bal_aaid,l_assignment_id,
                                 NULL,'PER',l_tax_unit_id,p_bus_grp,'QC'),0);

                      ln_no_gross_earnings := ln_no_gross_earnings +
                                nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                                ('RL1 No Gross Earnings','YTD',l_bal_aaid,l_assignment_id,
                                 NULL,'PER',l_tax_unit_id,p_bus_grp,'QC'),0);

                      ln_non_taxable_earnings := ln_non_taxable_earnings +
                                nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                                ('RL1 Non Taxable Earnings','YTD',l_bal_aaid,l_assignment_id,
                                 NULL,'PER',l_tax_unit_id,p_bus_grp,'QC'),0);

                  elsif p_report_type = 'RL2' then

                      ln_gross_earnings := ln_gross_earnings +
                                nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                                ('Gross Earnings','YTD',l_bal_aaid,l_assignment_id,
                                 NULL,'PER',l_tax_unit_id,p_bus_grp,'QC'),0);

                      ln_no_gross_earnings := ln_no_gross_earnings +
                                nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                                ('RL2 No Gross Earnings','YTD',l_bal_aaid,l_assignment_id,
                                 NULL,'PER',l_tax_unit_id,p_bus_grp,'QC'),0);

                  end if; /* p_report_type */

                end if; /* l_bal_aaid <> -9999 */

            end loop;
            close c_all_gres;

            if ( ((p_report_type = 'RL1') and
                  (
                    ((ln_gross_earnings <> 0) and
                     (ln_non_taxable_earnings <> ln_gross_earnings))
                    or
                     (ln_no_gross_earnings <> 0)
                  )
                 )
              or ((p_report_type = 'RL2') and
                  ((ln_gross_earnings <> 0) or
                   (ln_no_gross_earnings <> 0)
                  )
                 )
               ) then

                hr_utility.set_location(gv_package_name || '.get_eligible_assignments_prov', 100);

                select pay_assignment_actions_s.nextval
                into  lockingactid
                from  dual;

                hr_utility.trace('creating asg action');

                hr_nonrun_asact.insact(lockingactid  => lockingactid,
	               	            assignid      => l_assignment_id,
	                            pactid        => l_yepp_payroll_action_id,
	                            chunk         => '1',
	                            greid         => null,
	                            status        => 'M');

                hr_utility.set_location(gv_package_name || '.get_eligible_assignments_prov', 110);

                update pay_assignment_actions aa
                set    aa.serial_number = to_char(l_person_id)
                where  aa.assignment_action_id = lockingactid;


                l_yepp_elgble_asg_table(l_assignment_id).c_assignment_id := l_assignment_id;
	        l_all_reported_asg_table(l_assignment_id).c_assignment_id := l_assignment_id;

                hr_utility.set_location(gv_package_name || '.get_eligible_assignments_prov', 150);

            end if;

        end if; /* l_prev_person_id <> l_person_id */

     end loop;
     close c_get_person_id;

     EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '|| gv_package_name || '.get_eligible_assignments_prov');
        raise;

    END get_eligible_assignments_prov;

   /******************************************************************
    Procedure get_processed_assignments
    Description : Gets the list of all assignments from the
                  assignment set which are processed by the year end process
    ******************************************************************/

    PROCEDURE get_processed_assignments(p_effective_date    in date,
                                        p_gre_id            in number,
                                        p_pre_id            in number,
                                        p_assignment_set_id in number,
                                        p_report_type       in varchar2)
    IS

    cursor c_get_processed_asg_fed(cp_effective_date    date,
                                   cp_gre_id	        number,
                                   cp_assignment_set_id number) is
    select distinct has.assignment_id
    from  hr_assignment_set_amendments has,
          per_all_assignments_f        paf
    where has.assignment_set_id   = cp_assignment_set_id
    and   paf.assignment_id       = has.assignment_id
    and   paf.assignment_type     = 'E'
    and   paf.primary_flag        = 'Y'
    and   paf.business_group_id+0 = p_bus_grp
    and   paf.effective_start_date <= add_months(cp_effective_date, 12) - 1
    and   paf.effective_end_date   >= cp_effective_date
    and exists (select 1
                from pay_payroll_actions ppa1,
                     pay_assignment_actions paa1
                where ppa1.report_type = p_report_type
                and ppa1.business_group_id+0 = p_bus_grp
                and ppa1.effective_date = add_months(cp_effective_date, 12) - 1
                and to_number(get_parameter('TRANSFER_GRE', ppa1.legislative_parameters))
                                                          = cp_gre_id
                and ppa1.payroll_action_id = paa1.payroll_action_id
                and paa1.serial_number = to_char(paf.person_id));


    cursor c_get_processed_asg_prov(cp_effective_date    date,
                                    cp_pre_id	         number,
                                    cp_assignment_set_id number) is
    select distinct has.assignment_id
    from  hr_assignment_set_amendments has,
          per_all_assignments_f        paf
    where has.assignment_set_id   = cp_assignment_set_id
    and   paf.assignment_id       = has.assignment_id
    and   paf.assignment_type     = 'E'
    and   paf.primary_flag        = 'Y'
    and   paf.business_group_id+0 = p_bus_grp
    and   paf.effective_start_date <= add_months(cp_effective_date, 12) - 1
    and   paf.effective_end_date   >= cp_effective_date
    and exists (select 1
                from pay_payroll_actions ppa1,
                     pay_assignment_actions paa1
                where ppa1.report_type = p_report_type
                and ppa1.business_group_id+0 = p_bus_grp
                and ppa1.effective_date = add_months(cp_effective_date, 12) - 1
                and to_number(get_parameter('PRE_ORGANIZATION_ID', ppa1.legislative_parameters))
                                                          = cp_pre_id
                and ppa1.payroll_action_id = paa1.payroll_action_id
                and paa1.serial_number = to_char(paf.person_id));

    l_processed_assignment_id     per_all_assignments_f.assignment_id%type;

    BEGIN

     if p_report_type in ('T4','T4A') then

        open c_get_processed_asg_fed(p_effective_date ,
                                     p_gre_id,
                                     p_assignment_set_id);
        loop

           fetch c_get_processed_asg_fed into l_processed_assignment_id;
           exit when c_get_processed_asg_fed%notfound;

           hr_utility.set_location(gv_package_name || '.get_processed_assignments', 20);

           if l_yepp_elgble_asg_table.exists(l_processed_assignment_id) then

              hr_utility.trace('Assignment Exists');

           else

              l_yepp_prc_asg_table(l_processed_assignment_id).c_assignment_id     := l_processed_assignment_id;
              l_all_reported_asg_table(l_processed_assignment_id).c_assignment_id := l_processed_assignment_id;

           end if;

        end loop;
        close c_get_processed_asg_fed;

     elsif p_report_type in ('RL1','RL2') then

        open c_get_processed_asg_prov(p_effective_date ,
                                      p_pre_id,
                                      p_assignment_set_id);
        loop

           fetch c_get_processed_asg_prov into l_processed_assignment_id;
           exit when c_get_processed_asg_prov%notfound;

           hr_utility.set_location(gv_package_name || '.get_processed_assignments', 20);

           if l_yepp_elgble_asg_table.exists(l_processed_assignment_id) then

              hr_utility.trace('Assignment Exists');

           else

              l_yepp_prc_asg_table(l_processed_assignment_id).c_assignment_id     := l_processed_assignment_id;
              l_all_reported_asg_table(l_processed_assignment_id).c_assignment_id := l_processed_assignment_id;

           end if;

        end loop;
        close c_get_processed_asg_prov;

     end if;

     EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '|| gv_package_name || '.get_processed_assignments');
        raise;
    END get_processed_assignments;


   /******************************************************************
    Procedure get_non_elgble_assignments
    Description : Gets the list of all primary assignments from the
                  assignment set which are not eligible for the year
                  end process.
    ******************************************************************/

    PROCEDURE get_non_elgble_assignments(p_assignment_set_id in number,
                                         p_gre_id            in number,
                                         p_pre_id            in number,
					 p_effective_date    in date,
                                         p_report_type       in varchar2)
    IS

     cursor c_get_assignments(cp_assignment_set_id number,
                              cp_gre_id            number,
			      cp_effective_date    date) is
     select distinct has.assignment_id
     from hr_assignment_set_amendments has,
          per_all_assignments_f        paf,
          pay_assignment_actions       paa,
          pay_payroll_actions          ppa
     where has.assignment_set_id         = cp_assignment_set_id
     and paf.assignment_id               = has.assignment_id
     and nvl(has.include_or_exclude,'I') = 'I'
     and paf.effective_start_date        <= add_months(cp_effective_date, 12) - 1
     and paf.effective_end_date          >= cp_effective_date
     and paf.business_group_id+0         = p_bus_grp
     and paa.assignment_id               = paf.assignment_id
     and paa.tax_unit_id                 = cp_gre_id
     and ppa.business_group_id+0         = p_bus_grp
     and ppa.payroll_action_id           = paa.payroll_action_id
     and ppa.action_type in ('R','Q','V','B','I')
     and ppa.effective_date   between  cp_effective_date
                                  and  add_months(cp_effective_date, 12) - 1
     and paf.assignment_type             = 'E'
     and paf.primary_flag                = 'Y';

     cursor c_all_gres is
     select hoi.organization_id
     from hr_organization_information hoi,
          hr_all_organization_units   hou
     where hoi.org_information_context = 'Canada Employer Identification'
     and   hoi.org_information2        = to_char(p_pre_id)
     and   hou.business_group_id       = p_bus_grp
     and   hou.organization_id         = hoi.organization_id;

     l_assignment_id per_all_assignments_f.assignment_id%type;
     l_gre           pay_assignment_actions.tax_unit_id%type;

    BEGIN

     if p_report_type in ('T4','T4A') then

        open c_get_assignments(p_assignment_set_id, p_gre_id, p_effective_date);

        loop

         fetch c_get_assignments into l_assignment_id;
         exit when c_get_assignments%notfound;

         if l_yepp_elgble_asg_table.exists(l_assignment_id) then

            hr_utility.set_location(gv_package_name || '.get_non_elgble_assignments', 30);
            hr_utility.trace('Assignment Exists');

         elsif l_yepp_prc_asg_table.exists(l_assignment_id) then

            hr_utility.trace('Assignment Exists');
            hr_utility.set_location(gv_package_name || '.get_non_elgble_assignments', 40);

         else

            l_yepp_not_elgble_asg_table(l_assignment_id).c_assignment_id := l_assignment_id;
 	    l_all_reported_asg_table(l_assignment_id).c_assignment_id    := l_assignment_id;

         end if;

        end loop;
        close c_get_assignments;

     elsif p_report_type in ('RL1','RL2') then

        open c_all_gres;
        loop

             fetch c_all_gres into l_gre;
             exit when c_all_gres%notfound;

             open c_get_assignments(p_assignment_set_id, l_gre, p_effective_date);
             loop
                  fetch c_get_assignments into l_assignment_id;
                  exit when c_get_assignments%notfound;

                  if l_yepp_elgble_asg_table.exists(l_assignment_id) then

                     hr_utility.set_location(gv_package_name || '.get_non_elgble_assignments', 30);
                     hr_utility.trace('Assignment Exists');

                  elsif l_yepp_prc_asg_table.exists(l_assignment_id) then

                     hr_utility.trace('Assignment Exists');
                     hr_utility.set_location(gv_package_name || '.get_non_elgble_assignments', 40);

                  else

                     l_yepp_not_elgble_asg_table(l_assignment_id).c_assignment_id := l_assignment_id;
          	     l_all_reported_asg_table(l_assignment_id).c_assignment_id    := l_assignment_id;

                  end if;

             end loop;
             close c_get_assignments;

        end loop;
        close c_all_gres;

     end if;

     EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '|| gv_package_name || '.get_non_elgble_assignments');
        raise;

    END get_non_elgble_assignments;


   /******************************************************************
    Procedure print_table_details
    Description : prints the table details in HTML format
    ******************************************************************/
    PROCEDURE print_table_details(p_assignment_id in number,
                                  p_report_type   in varchar2)
    IS
    BEGIN

     -- Get person_id of the employee
     open c_person_id(p_assignment_id);
     fetch c_person_id into lv_person_id;
     close c_person_id;

     -- Get Assignment Number
     open c_assignment_no(p_assignment_id);
     fetch c_assignment_no into lv_emp_no;
     close c_assignment_no;

     -- Get Employee Details
     open c_employee_details(lv_person_id);
     fetch c_employee_details into lv_emp_name,lv_emp_sin;
     close c_employee_details;

     l_assignment_inserted  := l_assignment_inserted  + 1;
     lv_data_row :=   formated_detail_string(
                               p_output_file_type
                              ,to_char(l_effective_date,'YYYY')
                              ,lv_gre_name
                              ,lv_pre_name
             		      ,lv_emp_name
			      ,lv_emp_sin
			      ,lv_emp_no
                              ,p_report_type);
     if p_output_file_type ='HTML' then
        lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
     end if;

     fnd_file.put_line(fnd_file.output, lv_data_row);

    END print_table_details;

   /******************************************************************
    Procedure report_secondary_assignments
    Description : Gets the list of secondary assignments from the
                  assignment set and report them
    ******************************************************************/
    PROCEDURE report_secondary_assignments(p_assignment_set_id in number,
                                           p_gre_id            in number,
                                           p_pre_id            in number,
					   p_effective_date    in date,
                                           p_report_type       in varchar2)
    IS

     cursor c_secondary_asg_fed(cp_assignment_set_id number,
                                cp_gre_id            number,
				cp_effective_date    date) is
     select distinct has.assignment_id
     from hr_assignment_set_amendments has,
          per_all_assignments_f        paf,
          pay_assignment_actions       paa,
          pay_payroll_actions          ppa
     where has.assignment_set_id         = cp_assignment_set_id
     and paf.assignment_id               = has.assignment_id
     and nvl(has.include_or_exclude,'I') = 'I'
     and paf.effective_start_date      <= add_months(cp_effective_date, 12) - 1
     and paf.effective_end_date        >= cp_effective_date
     and paf.business_group_id+0        = p_bus_grp
     and paa.assignment_id              = paf.assignment_id
     and ppa.business_group_id+0        = p_bus_grp
     and ppa.payroll_action_id          = paa.payroll_action_id
     and ppa.action_type in ('R','Q','V','B','I')
     and ppa.effective_date   between  cp_effective_date
                                  and  add_months(cp_effective_date, 12) - 1
     and paa.tax_unit_id                = cp_gre_id
     and paf.assignment_type            = 'E'
     and paf.primary_flag              <> 'Y';

     cursor c_secondary_asg_prov(cp_assignment_set_id number,
                                 cp_pre_id            number,
			         cp_effective_date    date) is
     select distinct has.assignment_id
     from hr_assignment_set_amendments has,
          per_all_assignments_f        paf,
          pay_assignment_actions       paa,
          pay_payroll_actions          ppa
     where has.assignment_set_id         = cp_assignment_set_id
     and paf.assignment_id               = has.assignment_id
     and nvl(has.include_or_exclude,'I') = 'I'
     and paf.effective_start_date      <= add_months(cp_effective_date, 12) - 1
     and paf.effective_end_date        >= cp_effective_date
     and paf.business_group_id+0        = p_bus_grp
     and paa.assignment_id              = paf.assignment_id
     and ppa.business_group_id+0        = p_bus_grp
     and ppa.payroll_action_id          = paa.payroll_action_id
     and ppa.action_type in ('R','Q','V','B','I')
     and ppa.effective_date   between  cp_effective_date
                                  and  add_months(cp_effective_date, 12) - 1
     and paf.assignment_type            = 'E'
     and paf.primary_flag              <> 'Y'
     and paa.tax_unit_id in (select hoi.organization_id
                             from hr_organization_information hoi,
                                  hr_all_organization_units   hou
                             where hoi.org_information_context = 'Canada Employer Identification'
                             and   hoi.org_information2        = to_char(cp_pre_id)
                             and   hou.business_group_id       = p_bus_grp
                             and   hou.organization_id         = hoi.organization_id);

     l_assignment_id       per_all_assignments_f.assignment_id%type;
     l_count               number;
     l_header_printed      varchar2(1);

    BEGIN

     l_count              := 0;
     l_header_printed     := 'N';

     if p_report_type in ('T4','T4A') then

        open c_secondary_asg_fed(p_assignment_set_id,
                                 p_gre_id,
   			         p_effective_date);
        loop

           fetch c_secondary_asg_fed into l_assignment_id;
           exit when c_secondary_asg_fed%notfound;

           if l_yepp_elgble_asg_table.exists(l_assignment_id) then

              hr_utility.set_location(gv_package_name || '.report_secondary_assignments', 20);
              hr_utility.trace('Assignment Exists');

           elsif l_yepp_prc_asg_table.exists(l_assignment_id) then

              hr_utility.trace('Assignment Exists');
              hr_utility.set_location(gv_package_name || '.report_secondary_assignments', 30);

           elsif  l_yepp_not_elgble_asg_table.exists(l_assignment_id) then

              hr_utility.trace('Assignment Exists');
              hr_utility.set_location(gv_package_name || '.report_secondary_assignments', 40);

           else

              l_count  := l_count + 1 ;

              if l_header_printed = 'N' then

                print_table_header('4. '||l_secasg_table_header, p_report_type, p_output_file_type);
       	        l_header_printed  := 'Y';

              end if;

              print_table_details(l_assignment_id, p_report_type);
              l_all_reported_asg_table(l_assignment_id).c_assignment_id := l_assignment_id;

           end if;

        end loop;
        close c_secondary_asg_fed;

        if p_output_file_type ='HTML' then
           fnd_file.put_line(fnd_file.output,'</table>') ;
        end if;


     elsif p_report_type in ('RL1','RL2') then

        open c_secondary_asg_prov(p_assignment_set_id,
                                  p_pre_id,
   		                  p_effective_date);
        loop

           fetch c_secondary_asg_prov into l_assignment_id;
           exit when c_secondary_asg_prov%notfound;

           if l_yepp_elgble_asg_table.exists(l_assignment_id) then

              hr_utility.set_location(gv_package_name || '.report_secondary_assignments', 20);
              hr_utility.trace('Assignment Exists');

           elsif l_yepp_prc_asg_table.exists(l_assignment_id) then

              hr_utility.trace('Assignment Exists');
              hr_utility.set_location(gv_package_name || '.report_secondary_assignments', 30);

           elsif  l_yepp_not_elgble_asg_table.exists(l_assignment_id) then

              hr_utility.trace('Assignment Exists');
              hr_utility.set_location(gv_package_name || '.report_secondary_assignments', 40);

           else

              l_count  := l_count + 1 ;

              if l_header_printed = 'N' then

                print_table_header('4. '||l_secasg_table_header, p_report_type, p_output_file_type);
       	        l_header_printed  := 'Y';

              end if;

              print_table_details(l_assignment_id, p_report_type);
              l_all_reported_asg_table(l_assignment_id).c_assignment_id := l_assignment_id;

           end if;

        end loop;
        close c_secondary_asg_prov;

        if p_output_file_type ='HTML' then
           fnd_file.put_line(fnd_file.output,'</table>') ;
        end if;

     end if;

     if l_count > 0 then
        gv_sec_asg_reported := 'Y';
     end if;

     EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '|| gv_package_name || '.report_secondary_assignments');
        raise;

    END report_secondary_assignments;


   /******************************************************************
    Procedure report_other_assignments
    Description : Gets the list of assignments in the assignment set
                  but in different GRE/PRE than entered as parameter
    ******************************************************************/
    PROCEDURE report_other_assignments(p_assignment_set_id in number,
                                       p_gre_id            in number,
                                       p_pre_id            in number,
				       p_effective_date    in date,
                                       p_report_type       in varchar2)

    IS
     cursor c_other_assignments_fed(cp_assignment_set_id number,
                                    cp_gre_id            number,
	    			    cp_effective_date    date) is
     select distinct has.assignment_id,
                     paa.tax_unit_id
     from hr_assignment_set_amendments has,
          per_all_assignments_f        paf,
          pay_assignment_actions       paa,
          pay_payroll_actions          ppa
     where has.assignment_set_id         = cp_assignment_set_id
     and paf.assignment_id               = has.assignment_id
     and nvl(has.include_or_exclude,'I') = 'I'
     and paf.effective_start_date    <= add_months(cp_effective_date, 12) - 1
     and paf.effective_end_date      >= cp_effective_date
     and paf.business_group_id+0      = p_bus_grp
     and paf.assignment_type          = 'E'
     and paa.assignment_id            = paf.assignment_id
     and ppa.business_group_id+0      = p_bus_grp
     and ppa.payroll_action_id        = paa.payroll_action_id
     and ppa.action_type in ('R','Q','V','B','I')
     and ppa.effective_date   between  cp_effective_date
                                  and  add_months(cp_effective_date, 12) - 1
     and nvl(paa.tax_unit_id, cp_gre_id) <> cp_gre_id;

     cursor c_other_assignments_prov(cp_assignment_set_id number,
                                     cp_pre_id            number,
				     cp_effective_date    date) is
     select distinct has.assignment_id,
                     hoi.org_information2
     from hr_assignment_set_amendments has,
          per_all_assignments_f        paf,
          pay_assignment_actions       paa,
          pay_payroll_actions          ppa,
          hr_organization_information  hoi
     where has.assignment_set_id         = cp_assignment_set_id
     and paf.assignment_id               = has.assignment_id
     and nvl(has.include_or_exclude,'I') = 'I'
     and paf.effective_start_date    <= add_months(cp_effective_date, 12) - 1
     and paf.effective_end_date      >= cp_effective_date
     and paf.business_group_id+0      = p_bus_grp
     and paf.assignment_type          = 'E'
     and paa.assignment_id            = paf.assignment_id
     and ppa.business_group_id+0      = p_bus_grp
     and ppa.payroll_action_id        = paa.payroll_action_id
     and ppa.action_type in ('R','Q','V','B','I')
     and ppa.effective_date   between  cp_effective_date
                                  and  add_months(cp_effective_date, 12) - 1
     and paa.tax_unit_id              = hoi.organization_id
     and hoi.org_information_context  = 'Canada Employer Identification'
     and paa.tax_unit_id   not in (select hoi1.organization_id
                                   from hr_organization_information hoi1,
                                        hr_all_organization_units   hou1
                                   where hoi1.org_information_context = 'Canada Employer Identification'
                                   and   hoi1.org_information2        = to_char(cp_pre_id)
                                   and   hou1.business_group_id       = p_bus_grp
                                   and   hou1.organization_id         = hoi1.organization_id);

     cursor c_get_name(cp_org_id number) is
     select name
     from hr_all_organization_units_tl
     where organization_id = cp_org_id
     and   language        = userenv('LANG');

     l_oth_assignment_id    per_all_assignments_f.assignment_id%type;
     l_gre_id               pay_assignment_actions.tax_unit_id%type;
     l_pre_id               pay_assignment_actions.tax_unit_id%type;
     l_header_printed       varchar2(1) := 'N';

    BEGIN

     if gv_sec_asg_reported = 'Y' then
        l_othasg_table_header := '5. '||l_othasg_table_header;
     else
        l_othasg_table_header := '4. '||l_othasg_table_header;
     end if;

     if p_report_type in ('T4A','T4') then

        open c_other_assignments_fed(p_assignment_set_id,
                                     p_gre_id,
   			             p_effective_date);
        loop

           fetch c_other_assignments_fed into l_oth_assignment_id, l_gre_id;
           exit when c_other_assignments_fed%notfound;

           if l_all_reported_asg_table.exists(l_oth_assignment_id) then

              hr_utility.trace('The assignment already reported above');

           else
                open c_get_name(l_gre_id);
                fetch c_get_name into lv_gre_name;
                close c_get_name;

                if l_header_printed  = 'N' then

                  print_table_header(l_othasg_table_header, p_report_type, p_output_file_type);
	          l_header_printed  := 'Y';

                end if;

                print_table_details(l_oth_assignment_id, p_report_type);
	        hr_utility.set_location(gv_package_name || '.report_other_assignments', 50);

           end if;

        end loop;
        close c_other_assignments_fed;

        if p_output_file_type ='HTML' then
           fnd_file.put_line(fnd_file.output,'</table>') ;
        end if;

     elsif p_report_type in ('RL1','RL2') then

        open c_other_assignments_prov(p_assignment_set_id,
                                      p_pre_id,
   			              p_effective_date);
        loop

           fetch c_other_assignments_prov into l_oth_assignment_id, l_pre_id;
           exit when c_other_assignments_prov%notfound;

           if l_all_reported_asg_table.exists(l_oth_assignment_id) then

              hr_utility.trace('The assignment already reported above');

           else

                if l_pre_id is null then
                   lv_pre_name := hr_general.decode_lookup('PAY_CA_MISSING_ASG','NO_PRE');
                else
                   open c_get_name(l_pre_id);
                   fetch c_get_name into lv_pre_name;
                   close c_get_name;
                end if;

                if l_header_printed  = 'N' then

                  print_table_header(l_othasg_table_header, p_report_type, p_output_file_type);
	          l_header_printed  := 'Y';

                end if;

                print_table_details(l_oth_assignment_id, p_report_type);
	        hr_utility.set_location(gv_package_name || '.report_other_assignments', 50);

           end if;

        end loop;
        close c_other_assignments_prov;

        if p_output_file_type ='HTML' then
           fnd_file.put_line(fnd_file.output,'</table>') ;
        end if;

     end if;

     EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '|| gv_package_name || '.report_other_assignments');
        raise;

    END report_other_assignments;

  --------------------------------------------------------------------
  -- The Main Procedure Begins Here
  --------------------------------------------------------------------
  BEGIN

   l_effective_date := fnd_date.canonical_to_date(p_effective_date);

   -- Add Assignment Actions Report
   gv_title := hr_general.decode_lookup('PAY_CA_MISSING_ASG','ADD_ASG_HEADING');

   l_elgbl_table_header    := '2. '||hr_general.decode_lookup('PAY_CA_MISSING_ASG','ELIGIBLE')||':';
   l_prced_table_header    := '1. '||hr_general.decode_lookup('PAY_CA_MISSING_ASG','PROCESSED')||':';
   l_nonelgbl_table_header := '3. '||hr_general.decode_lookup('PAY_CA_MISSING_ASG','NONELIGIBLE')||':';
   l_secasg_table_header   :=        hr_general.decode_lookup('PAY_CA_MISSING_ASG','SECONDARY')||':';

   if p_report_type in ('T4','T4A') then

      l_othasg_table_header :=  hr_general.decode_lookup('PAY_CA_MISSING_ASG','OTHER')||' '||
                                hr_general.decode_lookup('PAY_CA_MISSING_ASG','OTHER_GRE')||':';

      open c_name(p_gre_id);
      fetch c_name into lv_gre_name;
      close c_name;

   elsif p_report_type in ('RL1','RL2') then

      l_othasg_table_header :=  hr_general.decode_lookup('PAY_CA_MISSING_ASG','OTHER')||' '||
                                hr_general.decode_lookup('PAY_CA_MISSING_ASG','OTHER_PRE')||':';

      open c_name(p_pre_id);
      fetch c_name into lv_pre_name;
      close c_name;

   end if;

   if p_report_type = 'T4' then

      open c_t4_magtape_run_exists(l_effective_date,
                                   p_bus_grp,
                                   p_gre_id);
      fetch c_t4_magtape_run_exists into l_temp;

      if c_t4_magtape_run_exists%found then
         l_mag_exists := 1;
      end if;

      close c_t4_magtape_run_exists;

   elsif p_report_type = 'T4A' then

      open c_t4a_magtape_run_exists(l_effective_date,
                                    p_bus_grp,
                                    p_gre_id);
      fetch c_t4a_magtape_run_exists into l_temp;

      if c_t4a_magtape_run_exists%found then
         l_mag_exists := 1;
      end if;

      close c_t4a_magtape_run_exists;

   elsif p_report_type = 'RL1' then

      open c_rl1_magtape_run_exists(l_effective_date,
                                    p_bus_grp,
                                    p_pre_id);
      fetch c_rl1_magtape_run_exists into l_temp;

      if c_rl1_magtape_run_exists%found then
         l_mag_exists := 1;
      end if;

      close c_rl1_magtape_run_exists;

   elsif p_report_type = 'RL2' then

      open c_rl2_magtape_run_exists(l_effective_date,
                                    p_bus_grp,
                                    p_pre_id);
      fetch c_rl2_magtape_run_exists into l_temp;

      if c_rl2_magtape_run_exists%found then
         l_mag_exists := 1;
      end if;

      close c_rl2_magtape_run_exists;

   end if;

   fnd_file.put_line(fnd_file.output,
                     pay_us_payroll_utils.formated_header_string(gv_title || ' - ' || p_report_type || ' ' ||
                              to_char(l_effective_date,'YYYY'),p_output_file_type));

   if p_output_file_type ='HTML' then
     fnd_file.put_line(fnd_file.output, '<body>');
   end if;

   if l_mag_exists = 1 then  -- Magnetic tape processed

      if p_output_file_type ='HTML' then
         fnd_file.put_line(fnd_file.output, '<br><br><table align=center>');
      end if;

      if p_output_file_type ='HTML' then
        fnd_file.put_line(fnd_file.output, '<tr>');
      end if;

      fnd_file.put_line(fnd_file.output,
                        pay_us_payroll_utils.formated_data_string
                          (p_input_string =>  hr_general.decode_lookup('PAY_CA_MISSING_ASG','MAG_RUN')
                          ,p_bold         => 'Y'
                          ,p_output_file_type => p_output_file_type));

      if p_output_file_type ='HTML' then
        fnd_file.put_line(fnd_file.output, '</tr>');
        fnd_file.put_line(fnd_file.output, '<tr>');
      end if;

      fnd_file.put_line(fnd_file.output,
                        pay_us_payroll_utils.formated_data_string
                          (p_input_string => hr_general.decode_lookup('PAY_CA_MISSING_ASG','MAG_ROLLBACK')
                          ,p_bold         => 'Y'
                          ,p_output_file_type => p_output_file_type));

      if p_output_file_type ='HTML' then
         fnd_file.put_line(fnd_file.output, '</tr> </table> </body> </HTML>');
      end if;


   else -- Magnetic tape not processed

      l_effective_date := fnd_date.canonical_to_date(p_effective_date);

      if p_report_type in ('T4','T4A') then

         get_eligible_assignments_fed(l_effective_date,
                                      p_gre_id,
                                      p_assign_set,
                                      p_report_type);

      elsif p_report_type in ('RL1','RL2') then

         get_eligible_assignments_prov(l_effective_date,
                                       p_pre_id,
                                       p_assign_set,
                                       p_report_type);
      end if;

      get_processed_assignments(l_effective_date,
                                p_gre_id,
                                p_pre_id,
                                p_assign_set,
                                p_report_type);

      get_non_elgble_assignments(p_assign_set,
                                 p_gre_id,
                                 p_pre_id,
       			         l_effective_date,
                                 p_report_type);

    /***Start Formating of the output for already Processed Assignments****/

      if l_yepp_prc_asg_table.count > 0 then

        print_table_header(l_prced_table_header, p_report_type, p_output_file_type);

        for l_assignment_id in l_yepp_prc_asg_table.first..l_yepp_prc_asg_table.last
        loop
          if l_yepp_prc_asg_table.exists(l_assignment_id) then

             print_table_details(l_yepp_prc_asg_table(l_assignment_id).c_assignment_id, p_report_type);
          end if;
        end loop;

        if p_output_file_type ='HTML' then
          fnd_file.put_line(fnd_file.output,'</table>') ;
        end if;

      end if;

      if l_assignment_inserted = 0 then
         hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 110);
         formated_zero_count(p_output_file_type,'PROCESSED');
      end if;


    /***Start Formating of the out put for all Eligible Assignments****/

      l_assignment_inserted  := 0;
      if l_yepp_elgble_asg_table.count > 0 then

        print_table_header(l_elgbl_table_header, p_report_type, p_output_file_type);

        for l_assignment_id in l_yepp_elgble_asg_table.first..l_yepp_elgble_asg_table.last
        loop

          if l_yepp_elgble_asg_table.exists(l_assignment_id) then

	    print_table_details(l_yepp_elgble_asg_table(l_assignment_id).c_assignment_id, p_report_type);

          end if;
        end loop;

        if p_output_file_type ='HTML' then
          fnd_file.put_line(fnd_file.output,'</table>') ;
        end if;
      end if;

      hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 150);

      if l_assignment_inserted = 0 then
         formated_zero_count(p_output_file_type,'ELGBLE');
      end if;


    /***Start Formating of the output for Non Eligible Assignments*****/

      l_assignment_inserted  := 0;
      if l_yepp_not_elgble_asg_table.count > 0 then

        print_table_header(l_nonelgbl_table_header, p_report_type, p_output_file_type);

        for l_assignment_id in l_yepp_not_elgble_asg_table.first..l_yepp_not_elgble_asg_table.last
        loop

          if l_yepp_not_elgble_asg_table.exists(l_assignment_id) then

             print_table_details(l_yepp_not_elgble_asg_table(l_assignment_id).c_assignment_id, p_report_type);

          end if;
        end loop;

        if p_output_file_type ='HTML' then
         fnd_file.put_line(fnd_file.output,'</table>') ;
        end if;

      end if;

      if l_assignment_inserted = 0 then
         formated_zero_count(p_output_file_type,'NOTELGBLE');
      end if;

      report_secondary_assignments(p_assign_set,
                                   p_gre_id,
                                   p_pre_id,
  				   l_effective_date,
                                   p_report_type);

      report_other_assignments(p_assign_set,
                               p_gre_id,
                               p_pre_id,
		   	       l_effective_date,
                               p_report_type);

      if p_output_file_type ='HTML' then
         fnd_file.put_line(fnd_file.output, '</body> </HTML>');
      end if;

   end if; -- Magnetic tape not processed

   if p_output_file_type ='HTML' then

      update fnd_concurrent_requests
      set output_file_type = 'HTML'
      where request_id = FND_GLOBAL.CONC_REQUEST_ID ;

      commit;

   end if;

   EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '|| gv_package_name || '.add_actions_to_yepp');
        raise;

  END add_actions_to_yepp;

END pay_ca_yepp_add_actions_pkg;

/
