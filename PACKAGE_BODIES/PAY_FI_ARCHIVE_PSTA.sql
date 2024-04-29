--------------------------------------------------------
--  DDL for Package Body PAY_FI_ARCHIVE_PSTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_ARCHIVE_PSTA" as
   /* $Header: pyfipsta.pkb 120.0.12000000.1 2007/04/26 12:13:01 dbehera noship $ */
      /* Define the Global variables */
   type lock_rec is record (
      archive_assact_id   number
   );

   type lock_table is table of lock_rec
      index by binary_integer;

   g_actid                    number;
   g_run_payroll_action_id    number;
   g_package                  varchar2 (33)                                       := 'PAY_FI_ARCHIVE_PSTA .';
   g_debug                    boolean                                             := hr_utility.debug_enabled;
   g_business_group_id        number;
   g_legal_employer_id        number;
   g_effective_date           date;
   g_year                     varchar2 (4);
   g_local_unit_id            number;
   g_archive                  varchar2 (50);
   g_payroll_type_code        varchar2 (50);
   g_legal_empl_y_num         hr_organization_information.org_information1%type;
   g_legal_emp_name           hr_organization_units.name%type;
   g_local_unit_sd_no         hr_organization_information.org_information1%type;
   g_local_unit_name          hr_organization_units.name%type;
   g_year_last_date           date;
   g_year_start_date          date;
   g_lock_table               lock_table;
   g_index                    number                                              := -1;
   g_index_assact             number                                              := -1;
   g_payroll_id               number;
   g_pay_period_id            number;
   g_pay_period               varchar2 (240);
   g_payroll                  varchar2 (240);
   g_pay_period_end_date      date;
   g_pay_period_start_date    date;
   g_period_type              per_time_periods.period_type%type;
   g_time_period_id           per_time_periods.time_period_id%type;
   g_legal_employer_name      varchar2 (240);
   g_person_id                number                                              := -1;
   g_arch_payroll_action_id   number;
   g_payroll_type             varchar2 (200);
   g_emp_local_unit_id        varchar2 (30);
   --
   --
      /* GET PARAMETER */
   function get_parameter (
      p_parameter_string   in   varchar2,
      p_token              in   varchar2,
      p_segment_number     in   number default null
   )
      return varchar2 is
      l_parameter   pay_payroll_actions.legislative_parameters%type   := null;
      l_start_pos   number;
      l_delimiter   varchar2 (1)                                      := ' ';
      l_proc        varchar2 (240)                                    := g_package || ' get parameter ';
   begin
      if g_debug then
         hr_utility.set_location (' Entering Function GET_PARAMETER', 10);
      end if;

      l_start_pos := instr (' ' || p_parameter_string, l_delimiter || p_token || '=');

      --
      if l_start_pos = 0 then
         l_delimiter := '|';
         l_start_pos := instr (' ' || p_parameter_string, l_delimiter || p_token || '=');
      end if;

      if l_start_pos <> 0 then
         l_start_pos := l_start_pos + length (p_token || '=');
         l_parameter := substr (
                           p_parameter_string,
                           l_start_pos,
                           instr (p_parameter_string || ' ', l_delimiter, l_start_pos) - l_start_pos
                        );

         if p_segment_number is not null then
            l_parameter := ':' || l_parameter || ':';
            l_parameter := substr (
                              l_parameter,
                              instr (l_parameter, ':', 1, p_segment_number) + 1,
                              instr (l_parameter, ':', 1, p_segment_number + 1) - 1
                              - instr (l_parameter, ':', 1, p_segment_number)
                           );
         end if;
      end if;

      --
      if g_debug then
         hr_utility.set_location (' Leaving Function GET_PARAMETER', 20);
      end if;

      return l_parameter;
   end;
   --
   --
      /* GET ALL PARAMETERS */
   procedure get_all_parameters (
      p_payroll_action_id   in              number,
      p_business_group_id   out nocopy      number,
      p_legal_employer_id   out nocopy      number,
      p_local_unit_id       out nocopy      number,
      p_year                out nocopy      varchar2,
      p_payroll_type_code   out nocopy      varchar2,
      p_payroll_id          out nocopy      varchar2,
      p_archive             out nocopy      varchar2,
      p_effective_date      out nocopy      date
   ) is
      cursor csr_parameter_info (
         p_payroll_action_id   number
      ) is
         select pay_fi_archive_psta.get_parameter (legislative_parameters, 'LEGAL_EMPLOYER_ID'),
                pay_fi_archive_psta.get_parameter (legislative_parameters, 'ARCHIVE'),
                pay_fi_archive_psta.get_parameter (legislative_parameters, 'LOCAL_UNIT_ID'),
                pay_fi_archive_psta.get_parameter (legislative_parameters, 'YEAR_RPT'),
                pay_fi_archive_psta.get_parameter (legislative_parameters, 'PAYROLL_TYPE'),
                pay_fi_archive_psta.get_parameter (legislative_parameters, 'PAYROLL_ID'), effective_date, business_group_id
           from pay_payroll_actions
          where payroll_action_id = p_payroll_action_id;

      l_proc   varchar2 (240) := g_package || ' GET_ALL_PARAMETERS ';
   --
   begin
      fnd_file.put_line (fnd_file.log, 'Entering Get all Parameters');
      open csr_parameter_info (p_payroll_action_id);
      fetch csr_parameter_info into p_legal_employer_id,
                                    p_archive,
                                    p_local_unit_id,
                                    p_year,
                                    p_payroll_type_code,
                                    p_payroll_id,
                                    p_effective_date,
                                    p_business_group_id;
      close csr_parameter_info;

      --
      if g_debug then
         hr_utility.set_location (' Leaving Procedure GET_ALL_PARAMETERS', 30);
      end if;
   end get_all_parameters;
   --
   --
      /* Range Code*/
   procedure range_code (
      p_payroll_action_id   in              number,
      p_sql                 out nocopy      varchar2
   ) is
      cursor csr_legal_employer_details (
         csr_v_legal_employer_id   hr_organization_information.organization_id%type
      ) is
         select o1.name legal_employer_name, hoi2.org_information1 legal_emp_y_num, hoi2.org_information11
           from hr_organization_units o1, hr_organization_information hoi1, hr_organization_information hoi2
          where o1.business_group_id = g_business_group_id
            and hoi1.organization_id = o1.organization_id
            and hoi1.organization_id = csr_v_legal_employer_id
            and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            and hoi1.org_information_context = 'CLASS'
            and o1.organization_id = hoi2.organization_id
            and hoi2.org_information_context = 'FI_LEGAL_EMPLOYER_DETAILS';

      l_legal_employer_details   csr_legal_employer_details%rowtype;

      cursor csr_local_unit_details (
         csr_v_local_unit_id   hr_organization_information.organization_id%type
      ) is
         select o1.name local_unit_name, hoi2.org_information1 local_unit_sd_no, hoi2.org_information7
           from hr_organization_units o1, hr_organization_information hoi1, hr_organization_information hoi2
          where o1.business_group_id = g_business_group_id
            and hoi1.organization_id = o1.organization_id
            and hoi1.organization_id = csr_v_local_unit_id
            and hoi1.org_information1 = 'FI_LOCAL_UNIT'
            and hoi1.org_information_context = 'CLASS'
            and o1.organization_id = hoi2.organization_id
            and hoi2.org_information_context = 'FI_LOCAL_UNIT_DETAILS';

      cursor csr_all_local_unit_details (
         csr_v_legal_employer_id   hr_organization_information.organization_id%type
      ) is
         select hoi_le.org_information1 local_unit_id, hou_lu.name local_unit_name, hoi_lu.org_information1 local_unit_sd_no,
                hoi_lu.org_information7
           from hr_all_organization_units hou_le,
                hr_organization_information hoi_le,
                hr_all_organization_units hou_lu,
                hr_organization_information hoi_lu
          where hoi_le.organization_id = hou_le.organization_id
            and hou_le.organization_id = csr_v_legal_employer_id
            and hoi_le.org_information_context = 'FI_LOCAL_UNITS'
            and hou_lu.organization_id = hoi_le.org_information1
            and hou_lu.organization_id = hoi_lu.organization_id
            and hoi_lu.org_information_context = 'FI_LOCAL_UNIT_DETAILS';

      cursor csr_get_org_address (
         p_organization_id   number
      ) is
         select style, address_line_1, address_line_2, address_line_3, country, postal_code
           from hr_organization_units hou, hr_locations hl
          where hou.organization_id = p_organization_id and hou.location_id = hl.location_id;

      rl_get_org_address         csr_get_org_address%rowtype;
      rg_local_unit_details      csr_local_unit_details%rowtype;
      l_action_info_id           number;
      l_ovn                      number;
      l_postal_code              hr_locations.postal_code%type;
      l_country                  hr_locations.country%type;
      l_payroll_name             pay_payrolls_f.payroll_name%type;
   begin
      if g_debug then
         hr_utility.set_location (' Entering Procedure RANGE_CODE', 10);
      end if;

      p_sql :=
         'SELECT DISTINCT person_id
                    FROM  per_people_f ppf
                    ,pay_payroll_actions ppa
                    WHERE ppa.payroll_action_id = :payroll_action_id
                    AND   ppa.business_group_id = ppf.business_group_id
                    ORDER BY ppf.person_id';
      --
      --
      /* Get the Parameters'value */
      pay_fi_archive_psta.get_all_parameters (
         p_payroll_action_id,
         g_business_group_id,
         g_legal_employer_id,
         g_local_unit_id,
         g_year,
         g_payroll_type_code,
         g_payroll_id,
         g_archive,
         g_effective_date
      );

      if g_archive = 'Y' then
         g_payroll_type := hr_general.decode_lookup ('FI_PROC_PERIOD_TYPE', g_payroll_type_code);

         /* Get the Last Date of the Year */
         select fnd_date.canonical_to_date (g_year || '12/31')
           into g_year_last_date
           from dual;

         /* Get the First Date of the Year */
         g_year_start_date := add_months (g_year_last_date, -12) + 1;

         /* Get the Payroll Name */
         if g_payroll_id is not null then
            select payroll_name
              into l_payroll_name
              from pay_payrolls_f
             where payroll_id = g_payroll_id and g_year_last_date between effective_start_date and effective_end_date;
         end if;

         g_arch_payroll_action_id := p_payroll_action_id;
         --
         --
         /* Get the legal employer's detail*/
         open csr_legal_employer_details (g_legal_employer_id);
         fetch csr_legal_employer_details into l_legal_employer_details;
         close csr_legal_employer_details;
         g_legal_emp_name := l_legal_employer_details.legal_employer_name;
         g_legal_empl_y_num := l_legal_employer_details.legal_emp_y_num;

         /* Get the Local Unit Detail */
         if g_local_unit_id is not null then
            open csr_local_unit_details (g_local_unit_id);
            fetch csr_local_unit_details into rg_local_unit_details;
            close csr_local_unit_details;
            g_local_unit_name := rg_local_unit_details.local_unit_name;
            g_local_unit_sd_no := rg_local_unit_details.local_unit_sd_no;
         end if;

         /* Archive the Parameters */
         pay_action_information_api.create_action_information (
            p_action_information_id            => l_action_info_id,
            p_action_context_id                => p_payroll_action_id,
            p_action_context_type              => 'PA',
            p_object_version_number            => l_ovn,
            p_effective_date                   => g_effective_date,
            p_source_id                        => null,
            p_source_text                      => null,
            p_action_information_category      => 'EMEA REPORT DETAILS',
            p_action_information1              => 'PYFIPSTA',
            p_action_information2              => g_business_group_id,
            p_action_information3              => g_legal_employer_id,
            p_action_information4              => g_legal_emp_name,
            p_action_information5              => g_legal_empl_y_num,
            p_action_information6              => g_local_unit_id,
            p_action_information7              => g_local_unit_name,
            p_action_information8              => g_local_unit_sd_no,
            p_action_information9              => g_year,
            p_action_information10             => g_payroll_type,
            p_action_information11             => l_payroll_name
         );

         for i in csr_all_local_unit_details (g_legal_employer_id)
         loop
            rl_get_org_address.address_line_1 := null;
            rl_get_org_address.address_line_2 := null;
            rl_get_org_address.address_line_3 := null;
            rl_get_org_address.country := null;
            rl_get_org_address.postal_code := null;
            open csr_get_org_address (i.local_unit_id);
            fetch csr_get_org_address into rl_get_org_address;
            close csr_get_org_address;

            if rl_get_org_address.style = 'FI' then
               l_postal_code := hr_general.decode_lookup ('FI_POSTAL_CODE', rl_get_org_address.postal_code);
            else
               l_postal_code := rl_get_org_address.postal_code;
            end if;

            /* Get the Country Name */
            l_country := pay_fi_archive_psta.get_country_name (rl_get_org_address.country);
            /* Archive the Local Units Details */
            pay_action_information_api.create_action_information (
               p_action_information_id            => l_action_info_id,
               p_action_context_id                => p_payroll_action_id,
               p_action_context_type              => 'PA',
               p_object_version_number            => l_ovn,
               p_effective_date                   => g_effective_date,
               p_source_id                        => null,
               p_source_text                      => null,
               p_action_information_category      => 'EMEA REPORT INFORMATION',
               p_action_information1              => 'PYFIPSTA',
               p_action_information2              => 'LU_DETAILS',
               p_action_information3              => g_business_group_id,
               p_action_information4              => g_legal_employer_id,
               p_action_information5              => i.local_unit_id,
               p_action_information6              => i.local_unit_name,
               p_action_information7              => i.local_unit_sd_no,
               p_action_information8              => rl_get_org_address.address_line_1,
               p_action_information9              => rl_get_org_address.address_line_2,
               p_action_information10             => rl_get_org_address.address_line_3,
               p_action_information11             => l_country,
               p_action_information12             => l_postal_code
            );
         end loop;
      --
      --
      end if;
   --
   --
   end;
   --
   --
   /* Assignment Action Code*/
   procedure assignment_action_code (
      p_payroll_action_id   in   number,
      p_start_person        in   number,
      p_end_person          in   number,
      p_chunk               in   number
   ) is
      l_year_last_date         date;
      l_prepay_action_id       number;
      l_actid                  number;
      l_assignment_id          number;

      /* Cursor to take all the payroll runs for the given period for given Payroll Type and Payroll */
      cursor csr_prepaid_assignments_lu (
         p_payroll_action_id   number,
         p_start_person        number,
         p_end_person          number,
         p_legal_employer_id   number,
         p_local_unit_id       number,
         p_start_date          date,
         p_end_date            date
      ) is
         select   paaf.person_id, paaf.primary_flag, act.assignment_id assignment_id, act.assignment_action_id run_action_id,
                  act1.assignment_action_id
                        prepaid_action_id, appa.effective_date, appa.payroll_action_id,
                  appa2.payroll_action_id payactid, hsck.segment2 local_unit_id
             from pay_payroll_actions appa,
                  pay_payroll_actions appa2,
                  pay_assignment_actions act,
                  pay_assignment_actions act1,
                  pay_action_interlocks pai,
                  per_all_assignments_f paaf,
                  hr_soft_coding_keyflex hsck,
                  hr_organization_information hoi,
                  pay_payrolls_f ppa
            where appa.action_type in ('R', 'Q')
              and act.payroll_action_id = appa.payroll_action_id
              and act.source_action_id is null -- Master Action
              and act.action_status = 'C' -- Completed
              and act.assignment_action_id = pai.locked_action_id
              and act1.assignment_action_id = pai.locking_action_id
              and act1.action_status = 'C' -- Completed
              and act1.payroll_action_id = appa2.payroll_action_id
              and appa2.action_type in ('P', 'U')
              and paaf.assignment_id = act.assignment_id
              --  and paaf.assignment_id = p_assignemtn_id
              and appa.effective_date between paaf.effective_start_date and paaf.effective_end_date
              and appa.effective_date between p_start_date and p_end_date
              and paaf.primary_flag = 'Y'
              and paaf.person_id between p_start_person and p_end_person
              and ppa.payroll_id = paaf.payroll_id
              and ppa.payroll_id = nvl (g_payroll_id, ppa.payroll_id)
              and ppa.period_type = g_payroll_type
              and g_year_last_date between ppa.effective_start_date and ppa.effective_end_date
              and hsck.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
              and hsck.segment2 = nvl (to_char (p_local_unit_id), hsck.segment2)
              and hoi.organization_id = p_legal_employer_id
              and hoi.org_information_context = 'FI_LOCAL_UNITS'
              and hoi.org_information1 = hsck.segment2
         order by person_id, assignment_id, payroll_action_id, prepaid_action_id;

      /* Cursor to get the time period details for the given payroll action id */
      cursor csr_time_period_details (
         csr_v_payroll_action_id   pay_payroll_actions.payroll_action_id%type
      ) is
         select papf.payroll_id, papf.payroll_name, ptp.start_date, ptp.end_date, ptp.period_name, ptp.period_type,
                ptp.regular_payment_date, ptp.time_period_id
           from pay_payroll_actions ppa, per_time_periods ptp, pay_all_payrolls_f papf
          where ptp.time_period_id = ppa.time_period_id
            and ppa.payroll_id = papf.payroll_id
            and ppa.payroll_action_id = csr_v_payroll_action_id;

      lr_time_period_details   csr_time_period_details%rowtype;
      l_action_info_id         number;
      l_ovn                    number;


      /* PL/SQL table to take the period and assignment action details for the benefits */
      type time_period_detail_rec is record (
         time_period_id          per_time_periods.time_period_id%type,
         pay_period_start_date   per_time_periods.start_date%type,
         pay_period_end_date     per_time_periods.end_date%type,
         pay_period              per_time_periods.period_name%type,
         assignment_action_id    number
      );

      type benefit_time_period is table of time_period_detail_rec
         index by binary_integer;

      /* PL/SQL table to take the person and his corresponding payroll runs in the given period .The table consists
         person id,assignment id and the time period details for that person which it self a PL/SQL table */

      type per_period_detail_rec is record (
         person_id       per_all_people_f.person_id%type,
         assignment_id   per_all_assignments_f.assignment_id%type,
         time_period     benefit_time_period
      );

      type person_period_detail is table of per_period_detail_rec
         index by binary_integer;

      benefit_person_detail    person_period_detail;
      l_person_index           number                            := -1;
      l_period_index           number                            := 0;
      l_previous_person_id     number                            := -1;

      /* Procedure to archive the benefit details  :--
         Details of parameters :-
	 1. benefit_person_period  - PL/SQL table to take the person and his corresponding payroll runs in the given period .
	                             The table consists person id,assignment id and the time period details for that person which
				     it self a PL/SQL table
         2.P_payroll_action_id     - Payroll action id for the archiving

	 Logic for the procedure -   First the for the each person in the benefit_type_tab PL/SQL table and after that
	                             each benefit will be checked it has some value for the year or not .and if it's some value for then
				     for the that benefit for each period the value will be checked for the change ,and if it's some change
				     then it'll be stored in the PL/SQL table for archiving */



      procedure archive_benefit_details (
         benefit_person_period   in   person_period_detail,
         p_payroll_action_id     in   number
      ) is
         cursor csr_balance (
            p_balance_category_name   varchar2
         ) is
            select pbt.balance_name
              from pay_balance_types pbt, pay_balance_categories_f pbc
             where pbc.legislation_code = 'FI'
               and pbt.balance_category_id = pbc.balance_category_id
               and pbt.business_group_id = g_business_group_id
               and pbc.category_name = p_balance_category_name;

         l_monetary_value             number                                             := 0;

	 /* PL/SQL table to take the Benefit details for final archiving the data */
         type benefit_archive_details_rec is record (
            pay_period_start_date   per_time_periods.start_date%type,
            pay_period_end_date     per_time_periods.end_date%type,
            pay_current_end_date    per_time_periods.end_date%type,
            benefit_name            varchar2 (240),
            benfit_value            number,
            assignment_id           number,
            person_id               number,
            assignment_action_id    number
         );

         type benefit_archive_details_tab is table of benefit_archive_details_rec
            index by binary_integer;

         benefit_archive_details      benefit_archive_details_tab;
         l_old_value                  number                                             := 0;
         l_current_value              number                                             := 0;
         l_index                      number                                             := 0;
         l_old_period_end_date        date;
         l_period_number              number;
         l_car_old_value              varchar2 (240)                                     := ' ';
         l_car_current_value          varchar2 (240);
         l_old_car_period_end_date    date;

	 /* PL/SQL table to take all the benefit types */
         type benefit_type is table of varchar2 (240)
            index by binary_integer;

         benefit_type_tab             benefit_type;
         l_database_ytd_item_suffix   pay_balance_dimensions.database_item_suffix%type;
         l_database_ptd_item_suffix   pay_balance_dimensions.database_item_suffix%type;
         l_actid                      number;
         l_ytd_value                  number                                             := 0;
         l_person_last_period         number;

         cursor get_car_element_details (
            p_assignment_id   number,
            p_value_date      date,
            p_input_name      varchar2
         ) is
            select iv1.name, eev1.effective_start_date, eev1.screen_entry_value screen_entry_value, iv1.lookup_type, uom
              from per_all_assignments_f asg1,
                   per_all_assignments_f asg2,
                   per_all_people_f per,
                   pay_element_links_f el,
                   pay_element_types_f et,
                   pay_input_values_f iv1,
                   pay_element_entries_f ee,
                   pay_element_entry_values_f eev1
             where asg1.assignment_id = p_assignment_id
               and p_value_date between asg1.effective_start_date and asg1.effective_end_date
               and p_value_date between asg2.effective_start_date and asg2.effective_end_date
               and p_value_date between per.effective_start_date and per.effective_end_date
               and per.person_id = asg1.person_id
               and asg2.person_id = per.person_id
               and asg2.primary_flag = 'Y'
               and et.element_name = 'Car Benefit'
               and (et.legislation_code = 'FI' or et.business_group_id = g_business_group_id)
               and iv1.element_type_id = et.element_type_id
               and iv1.name = nvl (p_input_name, iv1.name)
               and el.business_group_id = per.business_group_id
               and el.element_type_id = et.element_type_id
               and ee.assignment_id = asg2.assignment_id
               and ee.element_link_id = el.element_link_id
               and eev1.element_entry_id = ee.element_entry_id
               and eev1.input_value_id = iv1.input_value_id
               and eev1.screen_entry_value is not null
               and p_value_date between ee.effective_start_date and ee.effective_end_date
               and p_value_date between eev1.effective_start_date and eev1.effective_end_date;
      begin
         benefit_type_tab (0) := 'Phone Benefit';
         benefit_type_tab (1) := 'Internet Connection Benefit';
         benefit_type_tab (2) := 'Housing Benefit';
         benefit_type_tab (3) := 'Child Care Benefit';
         benefit_type_tab (4) := 'Tool Benefit';
         benefit_type_tab (5) := 'Staff Benefit';
         benefit_type_tab (6) := 'Stock Options Benefit';
         benefit_type_tab (7) := 'Mortgage Benefit';
         benefit_type_tab (8) := 'Other Benefits';
         benefit_type_tab (9) := 'Travel Ticket Benefit';
         benefit_type_tab (10) := 'Lunch Benefit';

         --     benefit_type_tab (11) := 'Cumulative Car Benefit';

         if benefit_person_detail.count > 0 then
            if g_local_unit_id is null then
               l_database_ytd_item_suffix := '_PER_LE_YTD';
               l_database_ptd_item_suffix := '_PER_LE_PTD';
            elsif g_local_unit_id is not null then
               l_database_ytd_item_suffix := '_PER_LU_YTD';
               l_database_ptd_item_suffix := '_PER_LU_PTD';
               pay_balance_pkg.set_context ('LOCAL_UNIT_ID', g_local_unit_id);
            end if;

            for i in benefit_person_period.first .. benefit_person_period.last
            loop
               for m in benefit_type_tab.first .. benefit_type_tab.last
               loop
                  l_ytd_value := 0;
                  l_period_number := benefit_person_period (i).time_period.last;
                  pay_balance_pkg.set_context (
                     'ASSIGNMENT_ACTION_ID',
                     benefit_person_period (i).time_period (l_period_number).assignment_action_id
                  );

                  /* To Check the YTD value for the Benefit */
                  if benefit_type_tab (m) = 'Lunch Benefit' then
                     begin
                        l_ytd_value :=
                           get_balance_value (
                              p_balance_name              => benefit_type_tab (m),
                              p_assignment_id             => benefit_person_period (i).assignment_id,
                              p_database_item_suffix      => l_database_ytd_item_suffix,
                              p_bal_date                  => benefit_person_period (i).time_period (l_period_number).pay_period_end_date
                           );
                     exception
                        when others then
                           l_ytd_value := l_ytd_value;
                     end;
                  elsif benefit_type_tab (m) <> 'Lunch Benefit' then
                     for balance_rec in csr_balance (benefit_type_tab (m))
                     loop
                        begin
                           -- pay_balance_pkg.set_context ('ASSIGNMENT_ACTION_ID', p_assignment_action_id);
                           l_ytd_value :=
                              l_ytd_value
                              + get_balance_value (
                                   p_balance_name              => balance_rec.balance_name,
                                   p_assignment_id             => benefit_person_period (i).assignment_id,
                                   p_database_item_suffix      => l_database_ytd_item_suffix,
                                   p_bal_date                  => benefit_person_period (i).time_period (l_period_number).pay_period_end_date
                                );
                        exception
                           when others then
                              l_ytd_value := l_ytd_value;
                        end;
                     end loop;
                  end if;

                  if l_ytd_value > 0 then
                     l_old_value := 0;
                     l_old_period_end_date := null;
                     l_person_last_period := benefit_person_period (i).time_period.last;

                     for j in benefit_person_period (i).time_period.first .. benefit_person_period (i).time_period.last
                     loop
                        l_monetary_value := 0;

                        if benefit_type_tab (m) = 'Lunch Benefit' then
                           begin
                              l_monetary_value :=
                                  get_balance_value (
                                     p_balance_name              => 'Lunch Benefit',
                                     p_assignment_id             => benefit_person_period (i).assignment_id,
                                     p_database_item_suffix      => l_database_ptd_item_suffix,
                                     p_bal_date                  => benefit_person_period (i).time_period (j).pay_period_end_date
                                  );
                           exception
                              when others then
                                 l_monetary_value := l_monetary_value;
                           end;
                        elsif benefit_type_tab (m) not in ('Lunch Benefit', 'Car Benefit') then
                           for balance_rec in csr_balance (benefit_type_tab (m))
                           loop
                              begin
                                 pay_balance_pkg.set_context (
                                    'ASSIGNMENT_ACTION_ID',
                                    benefit_person_period (i).time_period (j).pay_period_end_date
                                 );
                                 l_monetary_value :=
                                    l_monetary_value
                                    + get_balance_value (
                                         p_balance_name              => balance_rec.balance_name,
                                         p_assignment_id             => benefit_person_period (i).assignment_id,
                                         p_database_item_suffix      => l_database_ptd_item_suffix,
                                         p_bal_date                  => benefit_person_period (i).time_period (j).pay_period_end_date
                                      );
                              exception
                                 when others then
                                    l_monetary_value := l_monetary_value;
                              end;
                           end loop;
                        end if;

                        l_current_value := l_monetary_value;

                        if l_current_value > 0 and (l_current_value <> l_old_value) then
                           benefit_archive_details (l_index).pay_period_start_date :=
                                                             benefit_person_period (i).time_period (j).pay_period_start_date;

                           if     benefit_archive_details.first < l_index
                              and l_old_value <> 0
                              and benefit_archive_details (l_index - 1).benefit_name = benefit_type_tab (m)
                              and benefit_archive_details (l_index - 1).person_id = benefit_person_period (i).person_id then
                              benefit_archive_details (l_index - 1).pay_period_end_date := l_old_period_end_date;
                           end if;

                           benefit_archive_details (l_index).benefit_name := benefit_type_tab (m);
                           benefit_archive_details (l_index).benfit_value := l_current_value;
                           benefit_archive_details (l_index).assignment_id := benefit_person_period (i).assignment_id;
                           benefit_archive_details (l_index).person_id := benefit_person_period (i).person_id;

                           if benefit_person_period (i).time_period (l_person_last_period).time_period_id =
                                                                     benefit_person_period (i).time_period (j).time_period_id then
                              benefit_archive_details (l_index).pay_period_end_date :=
                                                               benefit_person_period (i).time_period (j).pay_period_end_date;
                           end if;

                           l_index := l_index + 1;
                        elsif     l_current_value = 0
                              and (l_current_value <> l_old_value)
                              and benefit_archive_details (l_index - 1).benefit_name = benefit_type_tab (m)
                              and benefit_archive_details (l_index - 1).person_id = benefit_person_period (i).person_id then
                           benefit_archive_details (l_index - 1).pay_period_end_date := l_old_period_end_date;
                        end if;

                        l_old_value := l_current_value;
                        l_old_period_end_date := benefit_person_period (i).time_period (j).pay_period_end_date;
                     -- null;
                     end loop;
                  end if;
               end loop;

               -- For Car Benefit
               l_car_old_value := ' ';
               l_old_car_period_end_date := null;

               for j in benefit_person_period (i).time_period.first .. benefit_person_period (i).time_period.last
               loop
                  for car_element_detail in
                     get_car_element_details (
                        benefit_person_period (i).assignment_id,
                        benefit_person_period (i).time_period (j).pay_period_end_date,
                        'Registration Number'
                     )
                  loop
                     l_car_current_value := car_element_detail.screen_entry_value;

                     if l_car_current_value <> ' ' and (l_car_current_value <> l_car_old_value) then
                        benefit_archive_details (l_index).pay_period_start_date :=
                                                                 benefit_person_period (i).time_period (j).pay_period_start_date;

                        if     benefit_archive_details.first < l_index
                           and l_car_old_value <> ' '
                           and benefit_archive_details (l_index - 1).benefit_name = 'Car Benefit'
                           and benefit_archive_details (l_index - 1).person_id = benefit_person_period (i).person_id then
                           benefit_archive_details (l_index - 1).pay_period_end_date := l_old_car_period_end_date;
                        end if;

                        benefit_archive_details (l_index).benefit_name := 'Car Benefit';
                        benefit_archive_details (l_index).assignment_id := benefit_person_period (i).assignment_id;
                        benefit_archive_details (l_index).person_id := benefit_person_period (i).person_id;
                        benefit_archive_details (l_index).pay_current_end_date :=
                                                                    benefit_person_period (i).time_period (j).pay_period_end_date;

                        if benefit_person_period (i).time_period (l_person_last_period).time_period_id =
                                                                     benefit_person_period (i).time_period (j).time_period_id then
                           benefit_archive_details (l_index).pay_period_end_date :=
                                                                   benefit_person_period (i).time_period (j).pay_period_end_date;
                        end if;

                        l_index := l_index + 1;
                     elsif     l_car_current_value is null
                           and (l_car_current_value <> l_car_old_value)
                           and benefit_archive_details (l_index - 1).benefit_name = 'Car Benefit'
                           and benefit_archive_details (l_index - 1).person_id = benefit_person_period (i).person_id then
                        benefit_archive_details (l_index - 1).pay_period_end_date := l_old_car_period_end_date;
                     end if;

                     l_car_old_value := l_car_current_value;
                     l_old_car_period_end_date := benefit_person_period (i).time_period (j).pay_period_end_date;
                  end loop;
               end loop;
            end loop;

            if benefit_archive_details.count > 0 then
               for k in benefit_archive_details.first .. benefit_archive_details.last
               loop
                  if benefit_archive_details (k).benefit_name <> 'Car Benefit' then
                     select pay_assignment_actions_s.nextval
                       into l_actid
                       from dual;

                     hr_nonrun_asact.insact (
                        l_actid,
                        benefit_archive_details (k).assignment_id,
                        p_payroll_action_id,
                        p_chunk,
                        null
                     );
                     pay_action_information_api.create_action_information (
                        p_action_information_id            => l_action_info_id,
                        p_action_context_id                => l_actid, --p_arch_assignment_action_id,
                        p_action_context_type              => 'AAP',
                        p_object_version_number            => l_ovn,
                        p_effective_date                   => g_effective_date,
                        p_source_id                        => null,
                        p_source_text                      => null,
                        p_action_information_category      => 'EMEA REPORT INFORMATION',
                        p_action_information1              => 'PYFIPSTA',
                        p_action_information2              => 'Benefit Details',
                        p_action_information3              => benefit_archive_details (k).person_id,
                        p_action_information5              => benefit_archive_details (k).person_id,
                        p_action_information6              => fnd_date.date_to_canonical (
                                                                 nvl (
                                                                    benefit_archive_details (k).pay_period_start_date,
                                                                    g_year_last_date
                                                                 )
                                                              ),
                        p_action_information7              => fnd_date.date_to_canonical (
                                                                 benefit_archive_details (k).pay_period_end_date
                                                              ),
                        p_action_information11             => benefit_archive_details (k).benefit_name,
                        p_action_information12             => fnd_number.number_to_canonical (
                                                                 benefit_archive_details (k).benfit_value
                                                              ),
                        p_assignment_id                    => benefit_archive_details (k).assignment_id
                     );
                  else
                     for car_element_detail in get_car_element_details (
                                                  benefit_archive_details (k).assignment_id,
                                                  benefit_archive_details (k).pay_current_end_date,
                                                  null
                                               )
                     loop
                        select pay_assignment_actions_s.nextval
                          into l_actid
                          from dual;

                        hr_nonrun_asact.insact (
                           l_actid,
                           benefit_archive_details (k).assignment_id,
                           p_payroll_action_id,
                           p_chunk,
                           null
                        );

                        if car_element_detail.lookup_type is not null then
                           car_element_detail.screen_entry_value :=
                                                             hr_general.decode_lookup (
                                                                car_element_detail.lookup_type,
                                                                car_element_detail.screen_entry_value
                                                             );
                        end if;

                        pay_action_information_api.create_action_information (
                           p_action_information_id            => l_action_info_id,
                           p_action_context_id                => l_actid, --p_arch_assignment_action_id,
                           p_action_context_type              => 'AAP',
                           p_object_version_number            => l_ovn,
                           p_effective_date                   => g_effective_date,
                           p_source_id                        => null,
                           p_source_text                      => null,
                           p_action_information_category      => 'EMEA REPORT INFORMATION',
                           p_action_information1              => 'PYFIPSTA',
                           p_action_information2              => 'Car Benefit Details',
                           p_action_information3              => benefit_archive_details (k).person_id,
                         --  p_action_information5              => benefit_archive_details (k).person_id,
                           p_action_information6              => fnd_date.date_to_canonical (
                                                                    benefit_archive_details (k).pay_period_start_date
                                                                 ),
                           p_action_information7              => fnd_date.date_to_canonical (
                                                                    nvl (
                                                                       benefit_archive_details (k).pay_period_end_date,
                                                                       g_year_last_date
                                                                    )
                                                                 ),
                           p_action_information11             => 'Car Benefit',
                           --    p_action_information18             => fnd_number.number_to_canonical (benefit_archive_details (k).time_period_id),
                           p_action_information19             => car_element_detail.name,
                           p_action_information20             => car_element_detail.screen_entry_value,
                           p_action_information22             => car_element_detail.uom,
                           p_assignment_id                    => benefit_archive_details (k).assignment_id
                        );
                     end loop;
                  end if;
               end loop;
            end if;

         end if; --End if benefit_person_detail.count > 0
      end;
   --  l_prepay_action_id NUMBER;
   begin
      /* Get the Parameters'value */
      pay_fi_archive_psta.get_all_parameters (
         p_payroll_action_id,
         g_business_group_id,
         g_legal_employer_id,
         g_local_unit_id,
         g_year,
         g_payroll_type_code,
         g_payroll_id,
         g_archive,
         g_effective_date
      );
      g_payroll_type := hr_general.decode_lookup ('FI_PROC_PERIOD_TYPE', g_payroll_type_code);

      g_arch_payroll_action_id := p_payroll_action_id;

      --
      --
      /* Get the Last Date of the Year */
      select fnd_date.canonical_to_date (g_year || '12/31')
        into g_year_last_date
        from dual;

      /* Get the First Date of the Year */
      g_year_start_date := add_months (g_year_last_date, -12) + 1;

      for rec_prepaid_assignments in csr_prepaid_assignments_lu (
                                        p_payroll_action_id      => p_payroll_action_id,
                                        p_start_person           => p_start_person,
                                        p_end_person             => p_end_person,
                                        p_legal_employer_id      => g_legal_employer_id,
                                        p_local_unit_id          => g_local_unit_id,
                                        p_start_date             => g_year_start_date,
                                        p_end_date               => g_year_last_date
                                     )
      loop
         l_prepay_action_id := 0;

         if l_prepay_action_id <> rec_prepaid_assignments.prepaid_action_id then
            select pay_assignment_actions_s.nextval
              into l_actid
              from dual;

            g_run_payroll_action_id := rec_prepaid_assignments.payroll_action_id;

--
--
/* Get the Payroll Details */
            open csr_time_period_details (g_run_payroll_action_id);
            fetch csr_time_period_details into lr_time_period_details;
            close csr_time_period_details;
            --
            --
            g_payroll_id := lr_time_period_details.payroll_id;
            g_pay_period := lr_time_period_details.period_name;
            g_pay_period_end_date := lr_time_period_details.end_date;
            g_pay_period_start_date := lr_time_period_details.start_date;
            g_time_period_id := lr_time_period_details.time_period_id;
            g_period_type := lr_time_period_details.end_date;
            g_emp_local_unit_id := rec_prepaid_assignments.local_unit_id;
                 --
                 --
            /* Generate Assignment Actions */
            g_index_assact := g_index_assact + 1;
            g_lock_table (g_index_assact).archive_assact_id := l_actid;
            hr_nonrun_asact.insact (l_actid, rec_prepaid_assignments.assignment_id, p_payroll_action_id, p_chunk, null);

--
--
/* Call the procedure to archive the data */
            archive_data (
               p_arch_assignment_action_id      => l_actid,
               p_assignment_action_id           => rec_prepaid_assignments.prepaid_action_id,
               p_assignment_id                  => rec_prepaid_assignments.assignment_id
            );
         end if;

         if rec_prepaid_assignments.person_id <> l_previous_person_id then
            l_person_index := l_person_index + 1;
            benefit_person_detail (l_person_index).person_id := rec_prepaid_assignments.person_id;
            benefit_person_detail (l_person_index).assignment_id := rec_prepaid_assignments.assignment_id;
            l_period_index := 0;
            benefit_person_detail (l_person_index).time_period (l_period_index).time_period_id :=
                                                                                       lr_time_period_details.time_period_id;
            benefit_person_detail (l_person_index).time_period (l_period_index).pay_period_start_date :=
                                                                                           lr_time_period_details.start_date;
            benefit_person_detail (l_person_index).time_period (l_period_index).pay_period_end_date :=
                                                                                             lr_time_period_details.end_date;
            benefit_person_detail (l_person_index).time_period (l_period_index).pay_period :=
                                                                                          lr_time_period_details.period_name;
            benefit_person_detail (l_person_index).time_period (l_period_index).assignment_action_id :=
                                                                                   rec_prepaid_assignments.prepaid_action_id;
            l_period_index := l_period_index + 1;
            l_previous_person_id := rec_prepaid_assignments.person_id;
         else
            benefit_person_detail (l_person_index).time_period (l_period_index).time_period_id :=
                                                                                       lr_time_period_details.time_period_id;
            benefit_person_detail (l_person_index).time_period (l_period_index).pay_period_start_date :=
                                                                                           lr_time_period_details.start_date;
            benefit_person_detail (l_person_index).time_period (l_period_index).pay_period_end_date :=
                                                                                             lr_time_period_details.end_date;
            benefit_person_detail (l_person_index).time_period (l_period_index).pay_period :=
                                                                                          lr_time_period_details.period_name;
            benefit_person_detail (l_person_index).time_period (l_period_index).assignment_action_id :=
                                                                                   rec_prepaid_assignments.prepaid_action_id;
            l_period_index := l_period_index + 1;
         end if;

         l_prepay_action_id := rec_prepaid_assignments.prepaid_action_id;
      --  l_assignment_id := rec_prepaid_assignments.assignment_id;
      end loop;

      archive_benefit_details (benefit_person_detail, p_payroll_action_id);
   end;
   --
   --
   /* Initialization Code*/
   procedure initialization_code (
      p_payroll_action_id   in   number
   ) is
   begin
      null;
   end;
   --
   --

   procedure archive_code (
      p_assignment_action_id   in   number,
      p_effective_date         in   date
   ) is
   begin
      null;
   end;
   /* Archive Code */
   procedure archive_data (
      p_arch_assignment_action_id   in   number,
      p_assignment_action_id        in   number,
      p_assignment_id               in   number
   ) is
      type benefit_expense_element_rec is record (
         benefit_expense_type             varchar2 (200),
         benefit_expense_monetary_value   number,
         benefit_exp_flag                 char (1), -- 'B' for Benefit and 'E' for expense
         input_value_name                 pay_input_values_f.name%type,
         input_value                      pay_element_entry_values_f.screen_entry_value%type,
         input_value_uom                  pay_input_values_f.uom%type
      );

      type benefit_expense_element_table is table of benefit_expense_element_rec
         index by binary_integer;

      l_benefit_expense_types      benefit_expense_element_table;
      l_index_benefit_exp_type     number                                             := 0;
      l_action_info_id             number;
      l_ovn                        number;
      l_hourly_salaried_code       varchar2 (100);
      l_tax_card_type_code         varchar2 (50);
      l_tax_municipality_code      varchar2 (100);
      l_tax_municipality           varchar2 (200);
      l_base_rate                  number (5, 2);
      l_additional_rate            number (5, 2);
      l_yearly_income_limit        number (10);
      l_actual_tax_days            number;
      l_year_last_date             date;
      l_year_start_date            date;
      l_payroll_flag               char (1);
      l_payroll_date               varchar2 (2);
      l_perioud_last_day           date;
      l_assignment_id              number;
      l_salary_income              number;
      l_benefits_in_kind           number;
      l_notional_salary            number;
      l_tax_card_type              varchar2 (200);

      /*Cursor csr_temination_date is
select paaf.effective_start_date - 1 term_dt
from per_all_assignments_f paaf, pay_assignment_actions paa
where paaf.assignment_id = paa.assignment_id
and paa.assignment_action_id = p_arch_assignment_action_id
and assignment_status_type_id = (select assignment_status_type_id
                            from per_assignment_status_types
                           where per_system_status = 'TERM_ASSIGN'
                             and active_flag = 'Y'
                             and legislation_code is null
                             and business_group_id is null)
and effective_end_date between g_year_start_date and g_year_last_date;*/
      cursor csr_asg_effective_date (
         p_asg_id              number,
         p_end_date            date,
         p_start_date          date,
         p_business_group_id   number
      ) is
         select max (effective_end_date) effective_date
           from per_all_assignments_f paa
          where assignment_id = p_asg_id
            and paa.effective_start_date <= p_end_date
            and paa.effective_end_date > = p_start_date
            and assignment_status_type_id in (select assignment_status_type_id
                                                from per_assignment_status_types
                                               where per_system_status = 'ACTIVE_ASSIGN'
                                                 and active_flag = 'Y'
                                                 and (   (legislation_code is null and business_group_id is null)
                                                      or (business_group_id = p_business_group_id)
                                                     ));

      cursor csr_employee_detail (
         p_effective_date   date
      ) is
         select papf.person_id person_id, paaf.assignment_id, national_identifier, full_name, employee_number,
                hourly_salaried_code, paaf.primary_flag, papf.date_of_birth, paaf.job_id, position_id
           from per_all_people_f papf, per_all_assignments_f paaf, pay_assignment_actions pac
          where pac.assignment_action_id = p_arch_assignment_action_id
            and paaf.assignment_id = pac.assignment_id
            and paaf.person_id = papf.person_id
            and p_effective_date between paaf.effective_start_date and paaf.effective_end_date
            and p_effective_date between papf.effective_start_date and papf.effective_end_date;

      cursor get_element_details (
         p_assignment_id   number,
         p_element_name    varchar2,
         p_input_value     varchar2,
         p_value_date      date
      ) is
         select eev1.screen_entry_value screen_entry_value
           from per_all_assignments_f asg1,
                per_all_assignments_f asg2,
                per_all_people_f per,
                pay_element_links_f el,
                pay_element_types_f et,
                pay_input_values_f iv1,
                pay_element_entries_f ee,
                pay_element_entry_values_f eev1
          where asg1.assignment_id = p_assignment_id
            and p_value_date between asg1.effective_start_date and asg1.effective_end_date
            and p_value_date between asg2.effective_start_date and asg2.effective_end_date
            and p_value_date between per.effective_start_date and per.effective_end_date
            and per.person_id = asg1.person_id
            and asg2.person_id = per.person_id
            and asg2.primary_flag = 'Y'
            and et.element_name = p_element_name --'Tax Card'
            and (et.legislation_code = 'FI' or et.business_group_id = g_business_group_id)
            and iv1.element_type_id = et.element_type_id
            and iv1.name = p_input_value
            and el.business_group_id = per.business_group_id
            and el.element_type_id = et.element_type_id
            and ee.assignment_id = asg2.assignment_id
            and ee.element_link_id = el.element_link_id
            and eev1.element_entry_id = ee.element_entry_id
            and eev1.input_value_id = iv1.input_value_id
            and p_value_date between ee.effective_start_date and ee.effective_end_date
            and p_value_date between eev1.effective_start_date and eev1.effective_end_date;

      cursor get_car_element_details (
         p_assignment_id   number,
         p_value_date      date
      ) is
         select iv1.name, eev1.effective_start_date, eev1.screen_entry_value screen_entry_value, iv1.lookup_type, uom
           from per_all_assignments_f asg1,
                per_all_assignments_f asg2,
                per_all_people_f per,
                pay_element_links_f el,
                pay_element_types_f et,
                pay_input_values_f iv1,
                pay_element_entries_f ee,
                pay_element_entry_values_f eev1
          where asg1.assignment_id = p_assignment_id
            and p_value_date between asg1.effective_start_date and asg1.effective_end_date
            and p_value_date between asg2.effective_start_date and asg2.effective_end_date
            and p_value_date between per.effective_start_date and per.effective_end_date
            and per.person_id = asg1.person_id
            and asg2.person_id = per.person_id
            and asg2.primary_flag = 'Y'
            and et.element_name = 'Car Benefit'
            and (et.legislation_code = 'FI' or et.business_group_id = g_business_group_id)
            and iv1.element_type_id = et.element_type_id
            --and iv1.name = p_input_value
            and el.business_group_id = per.business_group_id
            and el.element_type_id = et.element_type_id
            and ee.assignment_id = asg2.assignment_id
            and ee.element_link_id = el.element_link_id
            and eev1.element_entry_id = ee.element_entry_id
            and eev1.input_value_id = iv1.input_value_id
            and eev1.screen_entry_value is not null
            and p_value_date between ee.effective_start_date and ee.effective_end_date
            and p_value_date between eev1.effective_start_date and eev1.effective_end_date;

      cursor csr_get_benefit_type (
         p_assignment_id   per_all_assignments_f.assignment_id%type
      ) is
         select   pat.element_type_id, pat.element_name, pat.element_information1 benefit_type_code
             from pay_element_classifications pec, pay_element_types_f pat, pay_element_entries_f pet
            where pec.classification_name = 'Benefits in Kind'
              and pec.legislation_code = 'FI'
              and (pat.legislation_code = 'FI' or pat.business_group_id = g_business_group_id)
              and pec.classification_id = pat.classification_id
              and pat.element_type_id = pet.element_type_id
              and pet.assignment_id = p_assignment_id
              and g_pay_period_end_date between pat.effective_start_date and pat.effective_end_date
              and g_pay_period_end_date between pet.effective_start_date and pet.effective_end_date
         order by pat.element_type_id;

      cursor csr_person_archived (
         p_person_id   number
      ) is
         select 'Y'
           from pay_action_information pai, pay_assignment_actions paa
          where pai.action_context_id = paa.assignment_action_id
            and paa.payroll_action_id = g_arch_payroll_action_id
            and action_information1 = 'PYFIPSTA'
            and action_information2 = 'PERSON DETAILS'
            and action_information3 = to_char (p_person_id);

      cursor csr_payroll_archived (
         p_person_id   number
      ) is
         select 'Y'
           from pay_action_information pai, pay_assignment_actions paa
          where pai.action_context_id = paa.assignment_action_id
            and paa.payroll_action_id = g_arch_payroll_action_id
            and action_information1 = 'PYFIPSTA'
            and action_information2 = 'Payroll Details'
            and action_information3 = to_char (p_person_id)
            and action_information4 = to_char (g_payroll_id)
            and action_information5 = to_char (g_pay_period);

      cursor csr_primary_address (
         p_person_id        number,
         p_effective_date   date
      ) is
         select pa.person_id person_id, pa.style style, pa.address_type ad_type, pa.country country, pa.region_1 r1,
                pa.region_2
                      r2, pa.region_3 r3, pa.town_or_city city, pa.address_line1 al1, pa.address_line2 al2,
                pa.address_line3
                      al3, pa.postal_code postal_code
           from per_addresses pa
          where pa.primary_flag = 'Y'
            and pa.person_id = p_person_id
            and p_effective_date between pa.date_from and nvl (pa.date_to, to_date ('31-12-4712', 'DD-MM-YYYY'));

      cursor csr_permanent_address (
         p_person_id        number,
         p_effective_date   date
      ) is
         select pa.person_id person_id, pa.style style, pa.address_type ad_type, pa.country country, pa.region_1 r1,
                pa.region_2
                      r2, pa.region_3 r3, pa.town_or_city city, pa.address_line1 al1, pa.address_line2 al2,
                pa.address_line3
                      al3, pa.postal_code postal_code
           from per_addresses pa
          where pa.address_type = 'FI_PR'
            and pa.person_id = p_person_id
            and p_effective_date between pa.date_from and nvl (pa.date_to, to_date ('31-12-4712', 'DD-MM-YYYY'));

      cursor csr_balance (
         p_balance_category_name   varchar2
      ) is
         select pbt.balance_name
           from pay_balance_types pbt, pay_balance_categories_f pbc
          where pbc.legislation_code = 'FI'
            and pbt.balance_category_id = pbc.balance_category_id
            and pbt.business_group_id = g_business_group_id
            and pbc.category_name = p_balance_category_name;

      cursor get_global_value (
         p_global_name   varchar2
      ) is
         select to_number (nvl (global_value, 0))
           from ff_globals_f
          where legislation_code = 'FI' and global_name = p_global_name;

      cursor csr_get_job (
         p_job_id           per_jobs.job_id%type,
         p_effective_date   date
      ) is
         select name
           from per_jobs
          where job_id = p_job_id and p_effective_date between date_from and nvl (date_to, p_effective_date);

      cursor csr_get_position (
         p_position_id      hr_positions_f.position_id%type,
         p_effective_date   date
      ) is
         select name
           from hr_positions_f
          where position_id = p_position_id
            and p_effective_date between effective_start_date and nvl (effective_end_date, p_effective_date);

      l_balance_name               pay_balance_types.balance_name%type;
      rl_primary_address           csr_primary_address%rowtype;
      l_postal_code                per_addresses.postal_code%type;
      l_country                    per_addresses.country%type;
      rl_permanent_address         csr_permanent_address%rowtype;
      l_permanent_postal_code      per_addresses.postal_code%type;
      l_permanent_country          per_addresses.country%type;
      l_payroll_id                 pay_action_information.action_information3%type;
      l_pay_period                 pay_action_information.action_information4%type;
      l_pay_period_start_date      pay_action_information.action_information5%type;
      l_pay_period_end_date        pay_action_information.action_information3%type;
      l_period_type                pay_action_information.action_information3%type;
      l_run_assignment_action_id   number;
      -- l_benefit_type_code          pay_element_types_f.element_information1%type;
      l_benefit_type               varchar2 (200);
      l_benefit_monetary_value     number;
      l_sal_sub_to_tax             number;
      l_tax_at_source              number;
      l_withholding_tax            number;
      l_net_salary                 number;
      l_person_archived_flag       char (1)                                           := 'N';
      l_withholding_tax_base       number;
      l_tax_at_source_base         number;
      l_deductions_b_tax           number;
      l_external_expenses          number;
      l_payroll_archived_flag      char (1)                                           := 'N';
      l_database_item_suffix       pay_balance_dimensions.database_item_suffix%type;
      l_tax_amount                 number;
      l_termination_date           date;
      l_effective_date             date;
      l_monetary_value             number                                             := 0;
      l_lunch_benefit              number                                             := 0;
      l_car_benefit                number                                             := 0;
      l_pension                    number                                             := 0;
      l_unemployment_insurance     number                                             := 0;
      l_trade_union_fee            number                                             := 0;
      l_job_name                   per_jobs.name%type;
   begin
      if g_archive = 'Y' then
         open csr_asg_effective_date (
            p_asg_id                 => p_assignment_id,
            p_end_date               => g_year_last_date,
            p_start_date             => g_year_start_date,
            p_business_group_id      => g_business_group_id
         );
         fetch csr_asg_effective_date into l_termination_date;
         close csr_asg_effective_date;

         if l_termination_date < g_year_last_date then
            l_effective_date := l_termination_date;
         else
            l_effective_date := g_year_last_date;
         end if;

         for i in csr_employee_detail (l_effective_date)
         loop
            open csr_person_archived (i.person_id);
            fetch csr_person_archived into l_person_archived_flag;
            close csr_person_archived;

            if l_person_archived_flag = 'N' then --*/ i.primary_flag = 'Y' then
               --  g_person_id := i.person_id;
                 /* Initialize tax card details to null for each assignment */
               l_tax_card_type_code := null;
               l_tax_card_type := null;
               l_tax_municipality := null;
               l_tax_municipality_code := null;
               l_base_rate := null;
               l_additional_rate := null;
               l_yearly_income_limit := null;
               l_assignment_id := i.assignment_id;
               l_benefit_type := null;
               l_benefit_monetary_value := null;
               l_job_name := null;

               --
               --
               if i.job_id is not null then
                  open csr_get_job (i.job_id, l_effective_date);
                  fetch csr_get_job into l_job_name;
                  close csr_get_job;
               elsif i.position_id is not null then
                  open csr_get_position (i.position_id, l_effective_date);
                  fetch csr_get_position into l_job_name;
                  close csr_get_position;
               end if;

               /* Get the tax card type */
               open get_element_details (i.assignment_id, 'Tax Card', 'Tax Card Type', l_effective_date);
               fetch get_element_details into l_tax_card_type_code;
               close get_element_details;

               --
               --
               if l_tax_card_type_code is not null then
                  l_tax_card_type := hr_general.decode_lookup ('FI_TAX_CARD_TYPE', l_tax_card_type_code);
               else
                  l_tax_card_type := null;
               end if;

               /* Get the Tax Municipality */
               open get_element_details (i.assignment_id, 'Tax Card', 'Tax Municipality', l_effective_date);
               fetch get_element_details into l_tax_municipality_code;
               close get_element_details;

--
--
               l_tax_municipality := hr_general.decode_lookup ('FI_TAX_MUNICIPALITY', l_tax_municipality_code);
               /* Get the Base Rate */
               open get_element_details (i.assignment_id, 'Tax Card', 'Base Rate', l_effective_date);
               fetch get_element_details into l_base_rate;
               close get_element_details;
                   --
                   --
               /* Get the Additional Rate */
               open get_element_details (i.assignment_id, 'Tax Card', 'Additional Rate', l_effective_date);
               fetch get_element_details into l_additional_rate;
               close get_element_details;

               --
               --

               /* If the Tax Card type is cumulative */
               if l_tax_card_type_code = 'C' then
                  /* Get the Yearly Income Limit */
                  open get_element_details (i.assignment_id, 'Tax Card', 'Yearly Income Limit', l_effective_date);
                  fetch get_element_details into l_yearly_income_limit;
                  close get_element_details;
                    --
                    --
               /* When Tax Card Type = No Tax Card*/
               elsif l_tax_card_type_code = 'NTC' then
                  l_base_rate := null;
                  open get_global_value ('FI_PUNITIVE_TAX_PCT');
                  fetch get_global_value into l_base_rate;
                  close get_global_value;
                         --
               --
                        /* When Tax Card Type = Tax-at-Source */
               elsif l_tax_card_type_code = 'TS' and l_base_rate is null then
                  open get_global_value ('FI_TAX_AT_SOURCE_PCT');
                  fetch get_global_value into l_base_rate;
                  close get_global_value;
               --
               --
                        /* If Tax Card Type is Extra Income then the Base Rate and Additonal Rate will be taken from Tax Element */
               elsif l_tax_card_type_code = 'EI' then
                  l_base_rate := null;
                  l_additional_rate := null;
                  open get_element_details (i.assignment_id, 'Tax', 'Extra Income Rate', l_effective_date);
                  fetch get_element_details into l_base_rate;
                  close get_element_details;
                  open get_element_details (i.assignment_id, 'Tax', 'Extra Income Additional Rate', l_effective_date);
                  fetch get_element_details into l_additional_rate;
                  close get_element_details;
               end if;

               /* Set the context for Date Earned as the Effective Date */
               pay_balance_pkg.set_context ('DATE_EARNED', fnd_date.date_to_canonical (g_year_last_date));
               --
               --
                     /* Set the context forTAX_UNIT_ID as the Legal Employer Id */
               pay_balance_pkg.set_context ('TAX_UNIT_ID', g_legal_employer_id);
               pay_balance_pkg.set_context ('SOURCE_TEXT', null);
               pay_balance_pkg.set_context ('ASSIGNMENT_ACTION_ID', p_assignment_action_id);
               pay_balance_pkg.set_context ('ASSIGNMENT_ID', i.assignment_id);

               --
               --


               if g_local_unit_id is null then
                  l_database_item_suffix := '_PER_LE_YTD';
               elsif g_local_unit_id is not null then
                  l_database_item_suffix := '_PER_LU_YTD';
                  pay_balance_pkg.set_context ('LOCAL_UNIT_ID', g_local_unit_id);
               end if;

               /* Get the value for balnace Actual Tax Days */
               l_actual_tax_days := get_balance_value (
                                       p_balance_name              => 'Actual Tax Days',
                                       p_assignment_id             => i.assignment_id,
                                       p_database_item_suffix      => l_database_item_suffix,
                                       p_bal_date                  => l_effective_date
                                    );
               l_notional_salary := get_balance_value (
                                       p_balance_name              => 'Notional Salary',
                                       p_assignment_id             => i.assignment_id,
                                       p_database_item_suffix      => l_database_item_suffix,
                                       p_bal_date                  => l_effective_date
                                    );

               /* Get the Type of Benefit in Kind*/
               if i.hourly_salaried_code is not null then
                  l_hourly_salaried_code := hr_general.decode_lookup ('HOURLY_SALARIED_CODE', i.hourly_salaried_code);
               else
                  l_hourly_salaried_code := null;
               end if;

               open csr_primary_address (i.person_id, l_effective_date);
               fetch csr_primary_address into rl_primary_address;
               close csr_primary_address;

               if rl_primary_address.style = 'FI' then
                  l_postal_code := hr_general.decode_lookup ('FI_POSTAL_CODE', rl_primary_address.postal_code);
               else
                  l_postal_code := rl_primary_address.postal_code;
               end if;

               l_country := pay_fi_archive_psta.get_country_name (rl_primary_address.country);
               /* Retrieve the Permanent Address*/
               open csr_permanent_address (i.person_id, l_effective_date);
               fetch csr_permanent_address into rl_permanent_address;
               close csr_permanent_address;

               if rl_permanent_address.style = 'FI' then
                  l_permanent_postal_code := hr_general.decode_lookup ('FI_POSTAL_CODE', rl_permanent_address.postal_code);
               else
                  l_permanent_postal_code := rl_permanent_address.postal_code;
               end if;

               l_permanent_country := pay_fi_archive_psta.get_country_name (rl_permanent_address.country);
               /* Archive Person Details */
               pay_action_information_api.create_action_information (
                  p_action_information_id            => l_action_info_id,
                  p_action_context_id                => p_arch_assignment_action_id,
                  p_action_context_type              => 'AAP',
                  p_object_version_number            => l_ovn,
                  p_effective_date                   => g_effective_date,
                  p_source_id                        => null,
                  p_source_text                      => null,
                  p_action_information_category      => 'EMEA REPORT INFORMATION',
                  p_action_information1              => 'PYFIPSTA',
                  p_action_information2              => 'PERSON DETAILS',
                  p_action_information3              => i.person_id,
                  p_action_information4              => i.national_identifier,
                  p_action_information5              => i.full_name,
                  p_action_information6              => i.employee_number,
                  p_action_information7              => l_hourly_salaried_code,
                  p_action_information8              => l_tax_card_type,
                  p_action_information9              => l_tax_municipality,
                  p_action_information10             => fnd_number.number_to_canonical (l_base_rate),
                  p_action_information11             => fnd_number.number_to_canonical (l_additional_rate),
                  p_action_information12             => fnd_number.number_to_canonical (l_yearly_income_limit),
                  p_action_information13             => fnd_number.number_to_canonical (l_actual_tax_days),
                  p_action_information14             => fnd_number.number_to_canonical (l_notional_salary),
                  p_action_information15             => rl_primary_address.al1,
                  p_action_information16             => rl_primary_address.al2,
                  p_action_information17             => rl_primary_address.al3,
                  p_action_information18             => l_postal_code,
                  p_action_information19             => l_country,
                  p_action_information20             => g_emp_local_unit_id,
                  p_action_information21             => fnd_date.date_to_canonical (i.date_of_birth),
                  p_action_information22             => l_job_name,
                  p_action_information23             => rl_permanent_address.al1,
                  p_action_information24             => rl_permanent_address.al2,
                  p_action_information25             => rl_permanent_address.al3,
                  p_action_information26             => l_permanent_postal_code,
                  p_action_information27             => l_permanent_country,
                  p_assignment_id                    => i.assignment_id
               );
            /* Call procedure to archive person details
pay_fi_archive_psta.archive_person_address_details (
p_person_id                 => i.person_id,
p_assignment_action_id      => p_arch_assignment_action_id,
p_assignment_id             => i.assignment_id
);*/
            end if;

            open csr_payroll_archived (i.person_id);
            fetch csr_payroll_archived into l_payroll_archived_flag;
            close csr_payroll_archived;

            if l_payroll_archived_flag = 'N' then
               /* Set the context for Date Earned as the Effective Date */
               pay_balance_pkg.set_context ('DATE_EARNED', g_pay_period_end_date);
               --
               --
               l_database_item_suffix := null;

               if g_local_unit_id is null then
                  l_database_item_suffix := '_PER_LE_PTD';
               elsif g_local_unit_id is not null then
                  l_database_item_suffix := '_PER_LU_PTD';
                  pay_balance_pkg.set_context ('LOCAL_UNIT_ID', g_local_unit_id);
               end if;

               l_salary_income := get_balance_value (
                                     p_balance_name              => 'Salary Income',
                                     p_assignment_id             => i.assignment_id,
                                     p_database_item_suffix      => l_database_item_suffix,
                                     p_bal_date                  => g_pay_period_end_date
                                  );
               l_benefits_in_kind := get_balance_value (
                                        p_balance_name              => 'Benefits in Kind',
                                        p_assignment_id             => i.assignment_id,
                                        p_database_item_suffix      => l_database_item_suffix,
                                        p_bal_date                  => g_pay_period_end_date
                                     );
               l_deductions_b_tax := get_balance_value (
                                        p_balance_name              => 'Deductions Before Tax',
                                        p_assignment_id             => i.assignment_id,
                                        p_database_item_suffix      => l_database_item_suffix,
                                        p_bal_date                  => g_pay_period_end_date
                                     );
               /* Standard Deductions */
               l_pension := get_balance_value (
                               p_balance_name              => 'Pension',
                               p_assignment_id             => i.assignment_id,
                               p_database_item_suffix      => l_database_item_suffix,
                               p_bal_date                  => g_pay_period_end_date
                            );
               l_unemployment_insurance := get_balance_value (
                                              p_balance_name              => 'Unemployment Insurance',
                                              p_assignment_id             => i.assignment_id,
                                              p_database_item_suffix      => l_database_item_suffix,
                                              p_bal_date                  => g_pay_period_end_date
                                           );
               l_trade_union_fee := get_balance_value (
                                       p_balance_name              => 'Cumulative Trade Union Membership Fees',
                                       p_assignment_id             => i.assignment_id,
                                       p_database_item_suffix      => l_database_item_suffix,
                                       p_bal_date                  => g_pay_period_end_date
                                    );
               /* End of Standard Deductions*/
               l_external_expenses := get_balance_value (
                                         p_balance_name              => 'External Expenses',
                                         p_assignment_id             => i.assignment_id,
                                         p_database_item_suffix      => l_database_item_suffix,
                                         p_bal_date                  => g_pay_period_end_date
                                      );
               l_withholding_tax_base := get_balance_value (
                                            p_balance_name              => 'Withholding Tax Base',
                                            p_assignment_id             => i.assignment_id,
                                            p_database_item_suffix      => l_database_item_suffix,
                                            p_bal_date                  => g_pay_period_end_date
                                         );
               l_tax_at_source_base := get_balance_value (
                                          p_balance_name              => 'Tax at Source Base',
                                          p_assignment_id             => i.assignment_id,
                                          p_database_item_suffix      => l_database_item_suffix,
                                          p_bal_date                  => g_pay_period_end_date
                                       );
               l_tax_at_source := get_balance_value (
                                     p_balance_name              => 'Tax at Source',
                                     p_assignment_id             => i.assignment_id,
                                     p_database_item_suffix      => l_database_item_suffix,
                                     p_bal_date                  => g_pay_period_end_date
                                  );
               l_withholding_tax := get_balance_value (
                                       p_balance_name              => 'Withholding Tax',
                                       p_assignment_id             => i.assignment_id,
                                       p_database_item_suffix      => l_database_item_suffix,
                                       p_bal_date                  => g_pay_period_end_date
                                    );
               l_net_salary := get_balance_value (
                                  p_balance_name              => 'Net Pay',
                                  p_assignment_id             => i.assignment_id,
                                  p_database_item_suffix      => l_database_item_suffix,
                                  p_bal_date                  => g_pay_period_end_date
                               );
               l_car_benefit := get_balance_value (
                                   p_balance_name              => 'Cumulative Car Benefit',
                                   p_assignment_id             => i.assignment_id,
                                   p_database_item_suffix      => l_database_item_suffix,
                                   p_bal_date                  => g_pay_period_end_date
                                );

               if l_withholding_tax_base > 0 then
                  l_sal_sub_to_tax := nvl (l_withholding_tax_base, 0);
               elsif l_tax_at_source_base > 0 then
                  l_sal_sub_to_tax := nvl (l_tax_at_source_base, 0);
               else
                  l_sal_sub_to_tax := 0;
               end if;

               if l_withholding_tax > 0 then
                  l_tax_amount := nvl (l_withholding_tax, 0);
               elsif l_tax_at_source > 0 then
                  l_tax_amount := nvl (l_tax_at_source, 0);
               else
                  l_tax_amount := 0;
               end if;

               pay_action_information_api.create_action_information (
                  p_action_information_id            => l_action_info_id,
                  p_action_context_id                => p_arch_assignment_action_id,
                  p_action_context_type              => 'AAP',
                  p_object_version_number            => l_ovn,
                  p_effective_date                   => g_effective_date,
                  p_source_id                        => null,
                  p_source_text                      => null,
                  p_action_information_category      => 'EMEA REPORT INFORMATION',
                  p_action_information1              => 'PYFIPSTA',
                  p_action_information2              => 'Payroll Details',
                  p_action_information3              => i.person_id,
                  p_action_information4              => g_payroll_id,
                  p_action_information5              => g_pay_period,
                  p_action_information6              => fnd_date.date_to_canonical (g_pay_period_start_date),
                  p_action_information7              => fnd_date.date_to_canonical (g_pay_period_end_date),
                  p_action_information8              => g_period_type,
                  p_action_information9              => fnd_number.number_to_canonical (l_salary_income),
                  p_action_information10             => fnd_number.number_to_canonical (l_benefits_in_kind),
                  /*  p_action_information11             => l_benefit_type,
                p_action_information12             => fnd_number.number_to_canonical (
                                                  nvl (
                                                     l_benefit_expense_monetary_value,
                                                     0
                                                  )
                                               ),*/
                  p_action_information13             => fnd_number.number_to_canonical (l_sal_sub_to_tax),
                  p_action_information14             => fnd_number.number_to_canonical (l_tax_amount),
                  p_action_information15             => fnd_number.number_to_canonical (l_net_salary),
                  p_action_information16             => fnd_number.number_to_canonical (l_deductions_b_tax),
                  p_action_information17             => fnd_number.number_to_canonical (l_external_expenses),
                  p_action_information18             => fnd_number.number_to_canonical (g_time_period_id),
                  p_action_information19             => fnd_number.number_to_canonical (l_pension),
                  p_action_information20             => fnd_number.number_to_canonical (l_unemployment_insurance),
                  p_action_information21             => fnd_number.number_to_canonical (l_trade_union_fee),
                  p_action_information22             => fnd_number.number_to_canonical (l_car_benefit),
                  p_assignment_id                    => i.assignment_id
               );
            end if;
         end loop;
      end if;
   end;

   procedure archive_person_address_details (
      p_person_id              number,
      p_assignment_action_id   number,
      p_assignment_id          number
   ) is
      /* Cursor to retrieve primary address of Employee */
      cursor csr_primary_address (
         p_person_id   number
      ) is
         select pa.person_id person_id, pa.style style, pa.address_type ad_type, pa.country country, pa.region_1 r1,
                pa.region_2
                      r2, pa.region_3 r3, pa.town_or_city city, pa.address_line1 al1, pa.address_line2 al2,
                pa.address_line3
                      al3, pa.postal_code postal_code
           from per_addresses pa
          where pa.primary_flag = 'Y'
            and pa.person_id = p_person_id
            and g_year_last_date between pa.date_from and nvl (pa.date_to, to_date ('31-12-4712', 'DD-MM-YYYY'));

      /* Cursor to retrieve permanent address of Employee */
      cursor csr_permanent_address (
         p_person_id   number
      ) is
         select pa.person_id person_id, pa.style style, pa.address_type ad_type, pa.country country, pa.region_1 r1,
                pa.region_2
                      r2, pa.region_3 r3, pa.town_or_city city, pa.address_line1 al1, pa.address_line2 al2,
                pa.address_line3
                      al3, pa.postal_code postal_code
           from per_addresses pa
          where pa.address_type = 'FI_PR'
            and pa.person_id = p_person_id
            and g_year_last_date between pa.date_from and nvl (pa.date_to, to_date ('31-12-4712', 'DD-MM-YYYY'));

      rl_primary_address        csr_primary_address%rowtype;
      l_postal_code             per_addresses.postal_code%type;
      l_country                 per_addresses.country%type;
      rl_permanent_address      csr_primary_address%rowtype;
      l_permanent_postal_code   per_addresses.postal_code%type;
      l_permanent_country       per_addresses.country%type;
      l_action_info_id          number;
      l_ovn                     number;
   begin
      open csr_primary_address (p_person_id);
      fetch csr_primary_address into rl_primary_address;
      close csr_primary_address;

      if rl_primary_address.style = 'FI' then
         l_postal_code := hr_general.decode_lookup ('FI_POSTAL_CODE', rl_primary_address.postal_code);
      else
         l_postal_code := rl_primary_address.postal_code;
      end if;

      l_country := pay_fi_archive_psta.get_country_name (rl_primary_address.country);
      /* Retrieve the Permanent Address*/
      open csr_permanent_address (p_person_id);
      fetch csr_permanent_address into rl_permanent_address;
      close csr_permanent_address;

      if rl_permanent_address.style = 'FI' then
         l_permanent_postal_code := hr_general.decode_lookup ('FI_POSTAL_CODE', rl_permanent_address.postal_code);
      else
         l_permanent_postal_code := rl_permanent_address.postal_code;
      end if;

      l_permanent_country := pay_fi_archive_psta.get_country_name (rl_permanent_address.country);
      pay_action_information_api.create_action_information (
         p_action_information_id            => l_action_info_id,
         p_action_context_id                => p_assignment_action_id,
         p_action_context_type              => 'AAP',
         p_object_version_number            => l_ovn,
         p_effective_date                   => g_effective_date,
         p_source_id                        => null,
         p_source_text                      => null,
         p_action_information_category      => 'EMEA REPORT INFORMATION',
         p_action_information1              => 'PYFIPSTA',
         p_action_information2              => 'ADDRESS DETAILS',
         p_action_information3              => p_person_id,
         p_action_information4              => rl_primary_address.al1,
         p_action_information5              => rl_primary_address.al2,
         p_action_information6              => rl_primary_address.al3,
         p_action_information7              => l_postal_code,
         p_action_information8              => l_country,
         p_action_information9              => rl_permanent_address.al1,
         p_action_information10             => rl_permanent_address.al2,
         p_action_information11             => rl_permanent_address.al3,
         p_action_information12             => l_permanent_postal_code,
         p_action_information13             => l_permanent_country,
         p_assignment_id                    => p_assignment_id
      );
   end;

   function get_country_name (
      p_territory_code   varchar2
   )
      return varchar2 is
      cursor csr_get_territory_name (
         p_territory_code   varchar2
      ) is
         select territory_short_name
           from fnd_territories_vl
          where territory_code = p_territory_code;

      l_country   fnd_territories_vl.territory_short_name%type;
   begin
      if g_debug then
         hr_utility.set_location (' Entering Function GET_COUNTRY_NAME', 140);
      end if;

      open csr_get_territory_name (p_territory_code);
      fetch csr_get_territory_name into l_country;
      close csr_get_territory_name;
      return l_country;

      if g_debug then
         hr_utility.set_location (' Leaving Function GET_COUNTRY_NAME', 150);
      end if;
   end get_country_name;

   function get_balance_value (
      p_balance_name           in   varchar2,
      p_assignment_id          in   number,
      p_database_item_suffix   in   varchar2,
      p_bal_date               in   date
   )
      return number is
      --
      --
      /* Cursor to get the defined balance id */
      cursor csr_get_defined_balance_id (
         csr_v_balance_name   ff_database_items.user_name%type
      ) is
         select defined_balance_id
           from pay_balance_types pbt, pay_balance_dimensions pbd, pay_defined_balances pdb
          where pbt.balance_name = csr_v_balance_name
            and nvl(pbt.business_group_id,g_business_group_id) = g_business_group_id
            and pbt.balance_type_id = pdb.balance_type_id
            and pbd.database_item_suffix = p_database_item_suffix --'_PER_YTD'
            and pbd.legislation_code = 'FI'
            and pbd.balance_dimension_id = pdb.balance_dimension_id;

      l_get_defined_balance_id   number;
   begin
      /* Get teh defined Balance ID */
      open csr_get_defined_balance_id (p_balance_name);
      fetch csr_get_defined_balance_id into l_get_defined_balance_id;
      close csr_get_defined_balance_id;
      --
      --
      /* Get the Balance value and return it */
      --
      --
      return (pay_balance_pkg.get_value (
                 p_defined_balance_id      => l_get_defined_balance_id,
                 p_assignment_id           => p_assignment_id,
                 p_virtual_date            => p_bal_date --g_effective_date
              )
             );
   exception
      when others then
         hr_utility.trace ('SQLERR - ' || sqlerrm);
   end get_balance_value;
--
--
end pay_fi_archive_psta;

/
