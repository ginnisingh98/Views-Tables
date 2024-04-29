--------------------------------------------------------
--  DDL for Package Body PAY_NO_EERR_CONTINUOUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_EERR_CONTINUOUS" as
/* $Header: pynoeerc.pkb 120.1.12010000.3 2010/03/28 11:19:05 vijranga ship $ */
--------------------------------------------------------------------------------
-- Global Variables
--------------------------------------------------------------------------------
--

   type lock_rec is record (
      archive_assact_id   number
   );

   type lock_table is table of lock_rec
      index by binary_integer;

       TYPE t_detailed_output_tab_rec IS RECORD
(
    dated_table_id       pay_dated_tables.dated_table_id%TYPE     ,
    datetracked_event    pay_datetracked_events.datetracked_event_id%TYPE  ,
    update_type          pay_datetracked_events.update_type%TYPE  ,
    surrogate_key        pay_process_events.surrogate_key%type    ,
    column_name          pay_event_updates.column_name%TYPE       ,
    effective_date       date,
    creation_date        date,
    old_value            varchar2(2000),
    new_value            varchar2(2000),
    change_values        varchar2(2000),
    proration_type       varchar2(10),
    change_mode          pay_process_events.change_type%type,--'DATE_PROCESSED' etc
    element_entry_id     pay_element_entries_f.element_entry_id%type,
    next_ee              number    ,
    assignment_id        per_all_Assignments_f.assignment_id%type
);

   TYPE l_detailed_output_table_type IS TABLE OF t_detailed_output_tab_rec
                                                    INDEX BY BINARY_INTEGER ;

   g_debug                       boolean           := hr_utility.debug_enabled;
   g_lock_table                  lock_table;
   g_package                     varchar2 (33)    := 'PAY_NO_EERR_CONTINUOUS.';
   g_business_group_id           number;
   g_legal_employer_id           number;
   g_effective_date              date;
   g_start_date                  date;
   g_end_date                    date;
   g_archive                     varchar2 (50);
   g_err_num                     number;
   g_errm                        varchar2 (150);
   g_min_avg_weekly_hours        number                                   := 0;
   g_hour_change_limit           number                                   := 0;
   g_absence_termination_limit   number                                   := 0;
   g_report_mode                 varchar2 (80);
   g_legal_employer_name         hr_all_organization_units.name%type;
   g_legal_employer_org_no       hr_organization_information.org_information1%type;
   g_no_hours_change_weeks       number;
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
      l_proc        varchar2 (240)            := g_package || ' get parameter ';
   begin
      if g_debug then
         hr_utility.set_location (' Entering Function GET_PARAMETER', 10);
      end if;

      l_start_pos := instr (
                        ' ' || p_parameter_string,
                        l_delimiter || p_token || '='
                     );

      --
      if l_start_pos = 0 then
         l_delimiter := '|';
         l_start_pos := instr (
                           ' ' || p_parameter_string,
                           l_delimiter || p_token || '='
                        );
      end if;

      if l_start_pos <> 0 then
         l_start_pos := l_start_pos + length (p_token || '=');
         l_parameter := substr (
                           p_parameter_string,
                           l_start_pos,
                           instr (
                              p_parameter_string || ' ',
                              l_delimiter,
                              l_start_pos
                           )
                           - l_start_pos
                        );

         if p_segment_number is not null then
            l_parameter := ':' || l_parameter || ':';
            l_parameter := substr (
                              l_parameter,
                              instr (l_parameter, ':', 1, p_segment_number) + 1,
                              instr (
                                 l_parameter,
                                 ':',
                                 1,
                                 p_segment_number + 1
                              )
                              - 1 - instr (
                                       l_parameter,
                                       ':',
                                       1,
                                       p_segment_number
                                    )
                           );
         end if;
      end if;

      --
      if g_debug then
         hr_utility.set_location (' Leaving Function GET_PARAMETER', 20);
      end if;

      return l_parameter;
   end;
   /* GET ALL PARAMETERS */
   procedure get_all_parameters (
      p_payroll_action_id   in              number,
      p_business_group_id   out nocopy      number,
      p_legal_employer_id   out nocopy      number,
      p_archive             out nocopy      varchar2,
      p_start_date          out nocopy      date,
      p_end_date            out nocopy      date,
      p_effective_date      out nocopy      date
   -- p_report_mode         OUT NOCOPY      VARCHAR2
   ) is
      cursor csr_parameter_info (
         p_payroll_action_id   number
      ) is
         select pay_no_eerr_continuous.get_parameter (
                   legislative_parameters,
                   'LEGAL_EMPLOYER'
                ),
                fnd_date.canonical_to_date (
                   pay_no_eerr_continuous.get_parameter (
                      legislative_parameters,
                      'REPORT_START_DATE'
                   )
                ),
                fnd_date.canonical_to_date (
                   pay_no_eerr_continuous.get_parameter (
                      legislative_parameters,
                      'REPORT_END_DATE'
                   )
                ),
                pay_no_eerr_continuous.get_parameter (
                   legislative_parameters,
                   'ARCHIVE'
                ),
                /*  pay_no_eerr_CONTINUOUS.get_parameter (
      legislative_parameters,
      'REPORT_MODE'
   ),*/
                effective_date, business_group_id
           from pay_payroll_actions
          where payroll_action_id = p_payroll_action_id;

      l_proc   varchar2 (240) := g_package || ' GET_ALL_PARAMETERS ';
   --
   begin
      fnd_file.put_line (fnd_file.log, 'Entering Get all Parameters');
      open csr_parameter_info (p_payroll_action_id);
      fetch csr_parameter_info into p_legal_employer_id,
                                    p_start_date,
                                    p_end_date,
                                    p_archive,
                                    --     p_report_mode,
                                    p_effective_date,
                                    p_business_group_id;
      close csr_parameter_info;

      --
      if g_debug then
         hr_utility.set_location (
            ' Leaving Procedure GET_ALL_PARAMETERS',
            30
         );
      end if;
   end get_all_parameters;
   /* RANGE CODE */
    /* RANGE CODE */
   procedure range_code (
      p_payroll_action_id   in              number,
      p_sql                 out nocopy      varchar2
   ) is
      l_action_info_id       number;
      l_ovn                  number;

      cursor csr_legal_employers (
         p_legal_employer_id   in   number
      ) is
         select org.organization_id legal_employer_id,
                org.name
                      legal_employer_name, org.location_id,
                hoi1.org_information1
                      legal_employer_org_no
           from hr_all_organization_units org,
                hr_organization_information hoi1
          where org.organization_id = p_legal_employer_id
            and hoi1.organization_id(+) = org.organization_id
            and hoi1.org_information_context(+) = 'NO_LEGAL_EMPLOYER_DETAILS';

      l_legal_employer_rec   csr_legal_employers%rowtype;

      cursor csr_all_local_unit_details (
         csr_v_legal_employer_id   hr_organization_information.organization_id%type
      ) is
         select hoi_le.org_information1 local_unit_id,
                hou_lu.name
                      local_unit_name,
                hoi_lu.org_information1
                      local_unit_org_no, hou_lu.location_id
           from hr_all_organization_units hou_le,
                hr_organization_information hoi_le,
                hr_all_organization_units hou_lu,
                hr_organization_information hoi_lu
          where hoi_le.organization_id = hou_le.organization_id
            and hou_le.organization_id = csr_v_legal_employer_id
            and hoi_le.org_information_context = 'NO_LOCAL_UNITS'
            and hou_lu.organization_id = hoi_le.org_information1
            and hou_lu.organization_id = hoi_lu.organization_id
            and hoi_lu.org_information_context = 'NO_LOCAL_UNIT_DETAILS';


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
      pay_no_eerr_continuous.get_all_parameters (
         p_payroll_action_id,
         g_business_group_id,
         g_legal_employer_id,
         g_archive,
         g_start_date,
         g_end_date,
         g_effective_date
      --  g_report_mode
      );

      --
      --
      if g_archive = 'Y' then
         /* Get the Legal Employer Details */
         open csr_legal_employers (g_legal_employer_id);
         fetch csr_legal_employers into l_legal_employer_rec;
         close csr_legal_employers;
         --
         --
         g_legal_employer_name := l_legal_employer_rec.legal_employer_name;
         g_legal_employer_org_no := l_legal_employer_rec.legal_employer_org_no;
         --
         --
         pay_action_information_api.create_action_information (
            p_action_information_id            => l_action_info_id,
            p_action_context_id                => p_payroll_action_id,
            p_action_context_type              => 'PA',
            p_object_version_number            => l_ovn,
            p_effective_date                   => g_effective_date,
            p_source_id                        => null,
            p_source_text                      => null,
            p_action_information_category      => 'EMEA REPORT DETAILS',
            p_action_information1              => 'PYNOEERCNT',
            p_action_information2              => g_legal_employer_id,
            p_action_information3              => g_legal_employer_name,
            p_action_information4              => g_start_date,
            p_action_information5              => g_end_date
         );

         for i in csr_all_local_unit_details (g_legal_employer_id)
         loop
            pay_action_information_api.create_action_information (
               p_action_information_id            => l_action_info_id,
               p_action_context_id                => p_payroll_action_id,
               p_action_context_type              => 'PA',
               p_object_version_number            => l_ovn,
               p_effective_date                   => g_effective_date,
               p_source_id                        => null,
               p_source_text                      => null,
               p_action_information_category      => 'EMEA REPORT INFORMATION',
               p_action_information1              => 'PYNOEERCNT',
               p_action_information2              => g_business_group_id,
               p_action_information3              => g_legal_employer_id,
               p_action_information4              => g_legal_employer_name, -- Legal Employer Name
               p_action_information5              => g_legal_employer_org_no, -- Legal Employer Org No
               p_action_information6              => i.local_unit_id, -- Local Unit Id
               p_action_information7              => i.local_unit_name, -- Local Unit Name
               p_action_information8              => i.local_unit_org_no -- Local Unit Org No
            );
         --
         --
         end loop;
      end if;
   end range_code;                                  /* ASSIGNMENT ACTION CODE */

   procedure assignment_action_code (
      p_payroll_action_id   in   number,
      p_start_person        in   number,
      p_end_person          in   number,
      p_chunk               in   number
   ) is


       cursor get_global_value (
           p_global_name   varchar2,
   p_effective_date date
        ) is
           select nvl(fnd_number.canonical_to_number (global_value),0)
             from ff_globals_f
            where legislation_code = 'NO' and global_name = p_global_name
              and p_effective_date between effective_start_date and effective_end_date ;

      /* Cursor to get Local Unit Details based on the Legal Employers */
      cursor csr_all_local_unit_details (
         csr_v_legal_employer_id   hr_organization_information.organization_id%type
      ) is
         select hoi_le.org_information1 local_unit_id,
                hou_lu.name
                      local_unit_name,
                hoi_lu.org_information1
                      local_unit_org_no, hou_lu.location_id
           from hr_all_organization_units hou_le,
                hr_organization_information hoi_le,
                hr_all_organization_units hou_lu,
                hr_organization_information hoi_lu
          where hoi_le.organization_id = hou_le.organization_id
            and hou_le.organization_id = csr_v_legal_employer_id
            and hoi_le.org_information_context = 'NO_LOCAL_UNITS'
            and hou_lu.organization_id = hoi_le.org_information1
            and hou_lu.organization_id = hoi_lu.organization_id
            and hoi_lu.org_information_context = 'NO_LOCAL_UNIT_DETAILS';

      --
      --
      /* Cursor to get Employee Details based on the Local Unit , Start Date
    and End Date*/
      cursor csr_employee_details (
         p_local_unit   hr_all_organization_units.organization_id%type,
         p_start_date   date,
         p_end_date     date
      ) is
         select papf.person_id person_id, paaf.assignment_id,
                papf.effective_start_date, null effective_end_date, null emp_end_date,
                national_identifier, full_name, employee_number, normal_hours,
                hourly_salaried_code, hsc.segment3 position_code, frequency
           from per_all_people_f papf,
                per_all_assignments_f paaf,
                hr_soft_coding_keyflex hsc,
                per_assignment_status_types past
          where papf.person_id between p_start_person and p_end_person
            and paaf.person_id = papf.person_id
            and paaf.business_group_id = papf.business_group_id
           -- and paaf.primary_flag = 'Y'
            and hsc.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
            and hsc.segment2 = to_char (p_local_unit)
            and paaf.assignment_status_type_id =
                                               past.assignment_status_type_id
            and past.PER_SYSTEM_STATUS in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
	    and paaf.assignment_id = (select min(assignment_id)
			              from  per_all_assignments_f asg,hr_soft_coding_keyflex hsck
				      where person_id = papf.person_id
				      and   hsck.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
				      and   hsck.segment2 = to_char (p_local_unit))
            and p_end_date between paaf.effective_start_date
                               and paaf.effective_end_date
            and p_end_date between papf.effective_start_date
                               and papf.effective_end_date
            and not exists (select actual_termination_date
                          from per_periods_of_service
                         where actual_termination_date =
                                                      paaf.effective_end_date
                           and person_id  = papf.person_id
                           and actual_termination_date = nvl(final_process_date,actual_termination_date )
			    and p_end_date >= actual_termination_date
                    )
         union
         select papf.person_id person_id, paaf.assignment_id,
                papf.effective_start_date, paaf.effective_end_date, papf.effective_end_date emp_end_date,
                national_identifier, full_name, employee_number, normal_hours,
                hourly_salaried_code, hsc.segment3 position_code, frequency
           from per_all_people_f papf,
                per_all_assignments_f paaf,
                hr_soft_coding_keyflex hsc,
                per_assignment_status_types past
          where paaf.person_id = papf.person_id
	  and   papf.person_id between p_start_person and p_end_person
            and paaf.business_group_id = papf.business_group_id
            --and paaf.primary_flag = 'Y'
            and hsc.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
            and hsc.segment2 = to_char (p_local_unit)
            and paaf.assignment_status_type_id =
                                               past.assignment_status_type_id
            and paaf.assignment_id = (select min(assignment_id)
			              from  per_all_assignments_f asg,hr_soft_coding_keyflex hsck
				      where person_id = papf.person_id
				      and   hsck.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
				      and   hsck.segment2 = to_char (p_local_unit))
            --and past.PER_SYSTEM_STATUS = 'TERM_ASSIGN'
            and (( papf.effective_end_date <= p_end_date
            --and paaf.effective_end_date between p_start_date and p_end_date
           and exists (select actual_termination_date
                          from per_periods_of_service
                         where actual_termination_date =
                                                      paaf.effective_end_date
                           and person_id  = papf.person_id
                           and actual_termination_date = nvl(final_process_date,actual_termination_date )))
		or (paaf.effective_start_date <= p_end_date
		   and past.PER_SYSTEM_STATUS = 'TERM_ASSIGN'
		     and papf.effective_end_date <= p_end_date));

      --
      --
      /* Cursor to get the Start Date of the Assignment */
      cursor csr_start_date (
         p_assignment_id   per_all_assignments_f.assignment_id%type
      ) is
         select min (effective_start_date)
           from per_all_assignments_f paaf, per_assignment_status_types past
          where assignment_id = p_assignment_id
            and paaf.assignment_status_type_id =
                                               past.assignment_status_type_id
            and past.PER_SYSTEM_STATUS in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN');

      --
      --
      /* Cursor to get the Absence Start Date and End Date when employee is on
    absence for more than 14 days */
      cursor csr_absence_start_days (
         p_person_id   per_all_people_f.person_id%type
      ) is
         select paa.date_start, paa.date_end
           from per_absence_attendances paa, per_absence_attendance_types paat
          where paat.absence_attendance_type_id =
                                               paa.absence_attendance_type_id
            and paa.person_id = p_person_id
            and nvl(paa.date_end,g_end_date) - paa.date_start >= g_absence_termination_limit
            and paa.date_start between g_start_date and g_end_date
            and paat.absence_category not in
                              ('S', 'PTM', 'PTS', 'PTP', 'PTA', 'VAC', 'MRE'); /* 5520062 5648385 */

      cursor csr_absence_end_days (
         p_person_id   per_all_people_f.person_id%type
	 ,p_prev_last_date date
      ) is
         select paa.date_start, paa.date_end
           from per_absence_attendances paa, per_absence_attendance_types paat
          where paat.absence_attendance_type_id =
                                               paa.absence_attendance_type_id
            and paa.person_id = p_person_id
            and paa.date_end - paa.date_start >= g_absence_termination_limit
            and paa.date_end between p_prev_last_date and g_end_date
            and paat.absence_category not in
                              ('S', 'PTM', 'PTS', 'PTP', 'PTA', 'VAC', 'MRE'); /* 5648385 */
      --
      --
      /* Cursor to get Event Group Details */
      cursor csr_event_group_details (
         p_event_group_name    varchar2,
         p_business_group_id   number
      ) is
         select event_group_id
           from pay_event_groups
          where event_group_name = p_event_group_name
            and nvl (business_group_id, p_business_group_id) =
                                                          p_business_group_id;

      --
      --

      /* Cursor to get the Organization No for the Local Unit based on the soft
     coding keyflex id */
      cursor csr_get_org_no (
         p_soft_coding_keyflex_id   hr_soft_coding_keyflex.soft_coding_keyflex_id%type
      ) is
         select org_information1
           from hr_organization_information hoi, hr_soft_coding_keyflex hsc
          where org_information_context = 'NO_LOCAL_UNIT_DETAILS'
            and hsc.segment2 = organization_id
            and soft_coding_keyflex_id = p_soft_coding_keyflex_id;

      --
      --

      /* Cursor to get the SSB Position Code based on the soft coding keyflex id */
      cursor csr_get_job_position_code (
         p_assignment_id    number,
         p_effective_date   date,
         p_job_id           number
      ) is
         select segment3
           from hr_soft_coding_keyflex hsc, per_all_assignments_f paaf
          where paaf.job_id = p_job_id
            and assignment_id = p_assignment_id
            and p_effective_date between paaf.effective_start_date
                                     and paaf.effective_end_date
            and paaf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id;

      --
      --
      /* Cursor to get Assignment Status */
      cursor csr_get_assignment_status (
         p_assignment_status_type_id   per_assignment_status_types.assignment_status_type_id%type
      ) is
           select PER_SYSTEM_STATUS
           from per_assignment_status_types
          where assignment_status_type_id = p_assignment_status_type_id;

      --
      --

      /* Cursor to get the Element Entries Id for the Element Type */
      cursor csr_get_element_entries (
         c_assignment_id   number,
         c_eff_date        date,
         c_element_name    varchar2
      ) is
         select peef.element_entry_id
           from pay_element_entries_f peef, pay_element_types_f pet
          where pet.element_name = c_element_name
            and pet.legislation_code = 'NO'
            and peef.assignment_id = c_assignment_id
            and peef.element_type_id = pet.element_type_id
            and c_eff_date between peef.effective_start_date
                               and peef.effective_end_date
            and c_eff_date between pet.effective_start_date
                               and pet.effective_end_date;

      --
      --
      /* Cursor to get the Local Unit Id for the passed soft coding keyflex id */
      cursor csr_get_lu_scl (
         p_soft_coding_keyflex_id   number
      ) is
         select nvl (segment2, '0')
           from hr_soft_coding_keyflex
          where soft_coding_keyflex_id = (p_soft_coding_keyflex_id);

      --
      --
      /* Cursor to get the Position Code for the passed soft coding keyflex id */
      cursor csr_get_pos_scl (
         p_soft_coding_keyflex_id   number
      ) is
         select nvl(segment3, 0)
           from hr_soft_coding_keyflex
          where soft_coding_keyflex_id = (p_soft_coding_keyflex_id);

      --
      --

      /* Cursor to get the Position Code for the passed soft coding keyflex id */
      cursor csr_get_latest_st_date_scl (
         p_soft_coding_keyflex_id   number
      ) is
         select fnd_date.canonical_to_date(segment24)
	       /* fnd_date.canonical_to_date(nvl(segment24,'0001/01/01'))*/
           from hr_soft_coding_keyflex
          where soft_coding_keyflex_id = (p_soft_coding_keyflex_id);

	l_new_latest_start_date date ;
	l_old_latest_start_date date ;

      /* Cursor to get Eleent Entry ID */
      cursor csr_get_element_entry (
         c_assignment_id   number,
         c_eff_date        date,
         c_element_name    varchar2
      ) is
         select peef.element_entry_id
           from pay_element_entries_f peef, pay_element_types_f pet
          where pet.element_name = c_element_name
            and pet.legislation_code = 'NO'
            and peef.assignment_id = c_assignment_id
            and peef.element_type_id = pet.element_type_id
            and c_eff_date between peef.effective_start_date
                               and peef.effective_end_date
            and c_eff_date between pet.effective_start_date
                               and pet.effective_end_date;

      --
      /* Cursor to get Sickness Unpaid Eleent Entry ID 5648385 */
      cursor csr_get_sick_unpaid_entry (
         p_assignment_id   number,
         p_start_date        date,
         p_end_date        date,
         p_element_name    varchar2
      ) is
         select peef.element_entry_id
           from pay_element_entries_f peef, pay_element_types_f pet
          where pet.element_name = p_element_name
            and pet.legislation_code = 'NO'
            and peef.assignment_id = p_assignment_id
            and peef.element_type_id = pet.element_type_id
            and peef.effective_start_date between p_start_date
                                              and p_end_date ;
      --
      /* Cursor to get the Element Details */
      cursor csr_get_element_det (
         c_element_name     varchar2,
         c_input_val_name   varchar2,
         c_assignment_id    number,
         c_eff_date         date
      ) is
         select fnd_date.canonical_to_date (peev.screen_entry_value)
           from pay_element_types_f pet,
                pay_input_values_f piv,
                pay_element_entries_f peef,
                pay_element_entry_values_f peev
          where pet.element_name = c_element_name
            and pet.element_type_id = piv.element_type_id
            and piv.name = c_input_val_name
            and pet.legislation_code = 'NO'
            and piv.legislation_code = 'NO'
            and peef.assignment_id = c_assignment_id
            and peef.element_entry_id = peev.element_entry_id
            and peef.element_type_id = pet.element_type_id
            and peev.input_value_id = piv.input_value_id
            and c_eff_date between piv.effective_start_date
                               and piv.effective_end_date
            and c_eff_date between pet.effective_start_date
                               and pet.effective_end_date
            and c_eff_date between peev.effective_start_date
                               and peev.effective_end_date
            and c_eff_date between peef.effective_start_date
                               and peef.effective_end_date;

      --
      --
      /* Cursor to get the Dated Table ID */
      cursor csr_get_table_id (
         c_table_name   varchar2
      ) is
         select dated_table_id
           from pay_dated_tables
          where table_name = c_table_name;

      --
      --
      /* Cursor to get the Element Value for Hours */
      cursor csr_get_element_value (
         c_element_entry_id   number,
         c_eff_start_date     date,
         c_eff_end_date       date
      ) is
         select effective_start_date,
                fnd_number.canonical_to_number (screen_entry_value) entry_value
           from pay_element_entry_values_f peev
          where element_entry_id = c_element_entry_id
            and effective_start_date between c_eff_start_date and c_eff_end_date
            and screen_entry_value is not null
            and effective_start_date =
                   (select max (effective_start_date)
                      from pay_element_entry_values_f peevf
                     where element_entry_id = c_element_entry_id
                       and effective_start_date between c_eff_start_date
                                                    and c_eff_end_date
                       --  and peevf.effective_start_date = peev.effective_start_date
                       and to_char (peev.effective_start_date, 'MM') =
                                    to_char (peevf.effective_start_date, 'MM'));

      /* Cursor to get the current element value */
      cursor csr_get_curr_element_value (
         c_element_entry_id   number,
         c_effective_date     date
      ) is
         select fnd_number.canonical_to_number (screen_entry_value) entry_value
           from pay_element_entry_values_f
          where element_entry_id = c_element_entry_id
            and c_effective_date between effective_start_date
                                     and effective_end_date
            and screen_entry_value is not null;

      /* cursor to get the previous changed hour value */
      cursor previous_hour_value (
         p_assignment_id   per_all_assignments_f.assignment_id%type,
		 p_effective_date date
      ) is
      select normal_hours , effective_start_date
        from per_all_assignments_f
       where assignment_id = p_assignment_id
	  and p_effective_date - 1  between effective_start_date and  effective_end_date;
--         and effective_start_date < p_effective_date
--       order by effective_start_date desc ;

       /* Cursor to get all the assignment for the person except the given assignment*/
       cursor csr_get_all_assignments
         (p_person_id  per_all_people_f.person_id%type,
	  p_assignment_id per_all_assignments_f.assignment_id%type,
	  p_local_unit   hr_all_organization_units.organization_id%type)
	 is
	   select assignment_id
           from per_all_assignments_f paaf ,hr_soft_coding_keyflex hsck
           where person_id = p_person_id
	   and assignment_id <> p_assignment_id
           and  hsck.segment2 = to_char (p_local_unit)
	   and  hsck.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id;

       /*Cursor csr_get_assignment_details
       (p_effective_date  date,
	p_assignment_id per_all_assignments_f.assignment_id%type,
	p_local_unit   hr_all_organization_units.organization_id%type)
	is
       select normal_hours,
                hourly_salaried_code, hsc.segment3 position_code, frequency
	from per_all_assignments_f paaf,  hr_soft_coding_keyflex hsc
	where paaf.assignment_id = p_assignment_id
	and   hsc.segment2 = to_char (p_local_unit)
	and   hsc.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
	and   p_effective_date between  paaf.effective_start_date and paaf.effective_End_date;*/

	Cursor csr_get_assignment_details
       (p_effective_date  date,
	p_assignment_id per_all_assignments_f.assignment_id%type)
	is
      select normal_hours,
                hourly_salaried_code, hsc.segment3 position_code, frequency
	from per_all_assignments_f paaf,  hr_soft_coding_keyflex hsc
	where paaf.assignment_id = p_assignment_id
	--and   hsc.segment2 = to_char (p_local_unit)
	and   hsc.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
	and   p_effective_date between  paaf.effective_start_date and paaf.effective_End_date;

	rl_assignment_details  csr_get_assignment_details%rowtype;

         cursor curr_hours_frequency (
                p_assignment_id   per_all_assignments_f.assignment_id%type,
                p_effective_date date ) is
         select normal_hours, frequency
           from per_all_assignments_f
          where assignment_id = p_assignment_id
            and p_effective_date between effective_start_date and effective_end_date;

         cursor curr_lu_org_number (
                p_assignment_id   per_all_assignments_f.assignment_id%type,
	        p_effective_date date     ) is
         select org_information1
           from per_all_assignments_f paaf, hr_soft_coding_keyflex hsc,hr_organization_information hoi
          where paaf.assignment_id = p_assignment_id
            and p_effective_date between paaf.effective_start_date and paaf.effective_end_date
            and hsc.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
            and hoi.org_information_context = 'NO_LOCAL_UNIT_DETAILS'
            and hoi.organization_id = hsc.segment2;

         cursor curr_position_code (
                p_assignment_id   per_all_assignments_f.assignment_id%type,
	        p_effective_date date     ) is
	   select segment3
           from hr_soft_coding_keyflex hsc, per_all_assignments_f paaf
          where paaf.assignment_id = p_assignment_id
            and p_effective_date between paaf.effective_start_date
                                     and paaf.effective_end_date
            and paaf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id;

      /* Declaration for Local Variables */
      type emprec is record (
         value_flag             char (1),
         start_date             date,
         end_date               date,
         working_hours          number,
         corrected_start_date   date,
         hour_date_change       date,
         temination_date        date,
         lu_change_date         date,
         lu_value               varchar2 (100),
         job_id                 hr_soft_coding_keyflex.segment2%type,
         job_change_date        date,
         status_type            varchar2 (2),
	 old_lu_value           varchar2 (100), /* 5519990 */
	 rev_temination         varchar2(8)
      );

      type emptable is table of emprec
         index by binary_integer;

      collemptable                   emptable;
      l_ovn                          number;
      l_action_info_id               number;
      l_legal_employer_id            hr_organization_units.organization_id%type;
      l_business_group_id            hr_all_organization_units.business_group_id%type;
      l_start_date                   date;
      l_end_date                     date;
      l_legal_employer_id            hr_organization_units.organization_id%type;
      l_effective_date               date;
      l_emp_start_date               date;
      l_emp_end_date                 date;
      l_person_id                    per_all_people_f.person_id%type;
      l_event_group_id               pay_event_groups.event_group_id%type;
      l_detailed_output              l_detailed_output_table_type; -- pay_interpreter_pkg.t_detailed_output_table_type;
      l_proration_changes            pay_interpreter_pkg.t_proration_type_table_type;
      l_detail_tab                   pay_interpreter_pkg.t_detailed_output_table_type;
      l_pro_type_tab                 pay_interpreter_pkg.t_proration_type_table_type;
      l_proration_dates              pay_interpreter_pkg.t_proration_dates_table_type;
      l_total_hours                  number                               := 0;
      l_total_hours_all              number                               := 0;
      l_frequency                    per_all_assignments_f.frequency%type;
      l_hour_effective_end_date      date;
      l_hour_value                   varchar2 (100);
      l_hour_value1                  varchar2 (100);
      l_job_value                    varchar2 (100);
      l_local_unit_value             varchar2 (100);
      l_hour_change_effective_date   date;
      l_job_change_effective_date    date;
      l_lu_change_effective_date     date;
      y                              number                               := 1;
      l_assact_id                    number;
      l_status_type                  varchar2 (2);
      l_effective_start_date         date;
      l_lu_change_effective_date1    date;
      l_job_change_effective_date1   date;
      l_hour_value_reported          number                               := 0;
      l_user_status                  per_assignment_status_types.PER_SYSTEM_STATUS%type;
      l_last_update_date             date;
      l_alter_change                 char (1);
      l_lu_org_no                    hr_organization_information.org_information1%type;
      l_hour_element_entry_id        number;
      l_new_job_value                varchar2 (100);
      l_old_job_value                varchar2 (100);
      l_normal_hours                 number;
      l_table1                       pay_dated_tables.dated_table_id%type;
      l_table2                       pay_dated_tables.dated_table_id%type;
      l_table3                       pay_dated_tables.dated_table_id%type;
      l_element_entry_id             pay_element_entries_f.element_entry_id%type;
      l_defined_balance_id           number;
      l_get_prev_mon_bal_value       number;
      l_get_current_mon_bal_value    number;
      l_abs_start_date               date;
      l_abs_end_date                 date;
      l_hour_date_reported           date;
      l_hour_value_primary           number;
      l_houry_change_flag            char (1)                           := 'N';
      l_job_id                       number;
      l_empl_start_date              date;
      l_old_scl                      varchar2 (30);
      l_new_scl                      varchar2 (30);
      l_new_lu                       hr_soft_coding_keyflex.segment3%type;
      l_old_lu                       hr_soft_coding_keyflex.segment3%type;
      l_sickness_unpaid_start        date;
      l_sickness_unpaid_end          date;
      l_prev_hour_flag               char (1);
      l_hour_year_change_flag        char (1);
      l_corr_change_flag             char (1);
      l_detailed_output1             pay_interpreter_pkg.t_detailed_output_table_type;
      l_detailed_output2             pay_interpreter_pkg.t_detailed_output_table_type;
      l_detailed_output3             pay_interpreter_pkg.t_detailed_output_table_type;
      l_detailed_output4             pay_interpreter_pkg.t_detailed_output_table_type;
      l_empty_detailed_output        l_detailed_output_table_type;--pay_interpreter_pkg.t_detailed_output_table_type;
      merge_cnt                      number ;
      l_hour_old_value               number;
      l_prev_hour_value_primary      number;
      l_prev_hour_eff_date           date;
      l_lu_change_flag               char (1); /* 5519990 */
      l_local_unit_org_no            hr_organization_information.org_information1%type; /* 5519990 */
      l_national_identifier          per_all_people_f.national_identifier%type; /* 5526181 */
      l_old_date                     date;
      l_curr_hours                   number;
      l_curr_frequency               per_all_assignments_f.frequency%type;
      l_eff_end_date_need            char (1);
      l_curr_position                varchar2 (100);
      /* Work schedule variables 5525977 */
      l_days_or_hours         Varchar2(10) := 'D';
      l_include_event         Varchar2(10) := 'Y';
      l_start_time_char       Varchar2(10) := '0';
      l_end_time_char         Varchar2(10) := '23.59';
      l_duration              Number;
      l_wrk_schd_return       Number;
      l_schedule        cac_avlblty_time_varray;
      l_schedule_source VARCHAR2(10);
      l_return_status   VARCHAR2(1);
      l_return_message  VARCHAR2(2000);
      l_retrospective_hire_flag  char(1) := 'N';
      l_retrospective_date        date ;
      l_prev_last_date            date;
      dummy_date		  date;
      l_new_hour               number;

       procedure copy1 (
      p_copy_from   in out nocopy   l_detailed_output_table_type,
      p_from        in              number,
      p_copy_to     in out nocopy   l_detailed_output_table_type,
      p_to          in              number
   ) is
   begin
      --
      p_copy_to (p_to).dated_table_id := p_copy_from (p_from).dated_table_id;
      p_copy_to (p_to).datetracked_event :=
                                       p_copy_from (p_from).datetracked_event;
      p_copy_to (p_to).surrogate_key := p_copy_from (p_from).surrogate_key;
      p_copy_to (p_to).update_type := p_copy_from (p_from).update_type;
      p_copy_to (p_to).column_name := p_copy_from (p_from).column_name;
      p_copy_to (p_to).effective_date := p_copy_from (p_from).effective_date;
      p_copy_to (p_to).old_value := p_copy_from (p_from).old_value;
      p_copy_to (p_to).new_value := p_copy_from (p_from).new_value;
      p_copy_to (p_to).change_values := p_copy_from (p_from).change_values;
      p_copy_to (p_to).proration_type := p_copy_from (p_from).proration_type;
      p_copy_to (p_to).change_mode := p_copy_from (p_from).change_mode;
      p_copy_to (p_to).creation_date := p_copy_from (p_from).creation_date;
      p_copy_to (p_to).element_entry_id :=
                                        p_copy_from (p_from).element_entry_id;
      p_copy_to (p_to).assignment_id :=
                                        p_copy_from (p_from).assignment_id;
   --
   end copy1;

--
--------------------------------------------------------------------------------
-- SORT_CHANGES
--------------------------------------------------------------------------------
   procedure sort_changes1 (
      p_detail_tab   in out nocopy   l_detailed_output_table_type
   ) is
      --
      l_temp_table   l_detailed_output_table_type;
   --**x NUMBER;
   --
   begin
      if p_detail_tab.count > 0 then
         for i in p_detail_tab.first .. p_detail_tab.last
         loop
            --x :=  i + 1;
            for j in i + 1 .. p_detail_tab.last
            loop
               if p_detail_tab (j).effective_date <
                                              p_detail_tab (i).effective_date then
                  copy1 (p_detail_tab, j, l_temp_table, 1);
                  copy1 (p_detail_tab, i, p_detail_tab, j);
                  copy1 (l_temp_table, 1, p_detail_tab, i);
               elsif p_detail_tab (j).effective_date = p_detail_tab (i).effective_date
	          and p_detail_tab (j).creation_date = p_detail_tab (i).creation_date then
                  copy1 (p_detail_tab, j, l_temp_table, 1);
                  copy1 (p_detail_tab, i, p_detail_tab, j);
                  copy1 (l_temp_table, 1, p_detail_tab, i);
               end if;
            end loop;
         end loop;
      end if;
   --

   --
   end sort_changes1;
   --
   --
   begin
      /* Get the Parameters'value */
      pay_no_eerr_continuous.get_all_parameters (
         p_payroll_action_id,
         g_business_group_id,
         g_legal_employer_id,
         g_archive,
         g_start_date,
         g_end_date,
         g_effective_date
      --  g_report_mode
      );

	  --
         --
         /* Get the Absence Days after which the employee should be shown
       terminated */
         open get_global_value ('NO_ABSENCE_OTHERS_TERMINATION_LIMIT',g_end_date);
         fetch get_global_value into g_absence_termination_limit;
         close get_global_value;
         --
         --
         /* Get the Hour Change Limit that should be igmored while showing the
       change in hours */
         open get_global_value ('NO_HOUR_CHANGE_LIMIT',g_end_date);
         fetch get_global_value into g_hour_change_limit;
         close get_global_value;
         --
         --
         /*  Get the Min Average Weekly Hours below which the employee should
        be shown terminated */
         open get_global_value ('NO_MIN_AVG_WEEKLY_HOURS',g_end_date);
         fetch get_global_value into g_min_avg_weekly_hours;
         close get_global_value;
         --
         --
         /* get the No of weeks after which the employee shoud be shown as
       terminated if the Average weekly hours continues to be less than
       Min Average Weekly Hours*/
         open get_global_value ('NO_HOURS_CHANGE_WEEKS',g_end_date);
         fetch get_global_value into g_no_hours_change_weeks;
         g_no_hours_change_weeks := g_no_hours_change_weeks * 7;
         close get_global_value;

         --
         --
      if g_archive = 'Y' then
         open csr_get_table_id ('PAY_ELEMENT_ENTRIES_F');
         fetch csr_get_table_id into l_table1;
         close csr_get_table_id;
         --
         --
         open csr_get_table_id ('PAY_ELEMENT_ENTRY_VALUES_F');
         fetch csr_get_table_id into l_table2;
         close csr_get_table_id;
         --
         open csr_get_table_id ('PER_ALL_ASSIGNMENTS_F');
         fetch csr_get_table_id into l_table3;
         close csr_get_table_id;
         --
         open csr_event_group_details (
            'NO_REGISTER_REPORT_EVG',
            g_business_group_id
         );
         fetch csr_event_group_details into l_event_group_id;
         close csr_event_group_details;

         --
         --
         for i in csr_all_local_unit_details (g_legal_employer_id)
         loop
            for j in csr_employee_details (
                        i.local_unit_id,
                        g_start_date,
                        g_end_date
                     )
            loop
              l_national_identifier := pay_no_eerr_continuous.check_national_identifier (
                                           j.national_identifier);

	      if l_national_identifier <> 'INVALID_ID' then /* 5526181*/
               for i in 1 .. 5
               loop
                  collemptable (i).value_flag := null;
                  collemptable (i).start_date := null;
                  collemptable (i).end_date := null;
                  collemptable (i).working_hours := null;
                  collemptable (i).corrected_start_date := null;
                  collemptable (i).hour_date_change := null;
                  collemptable (i).temination_date := null;
                  collemptable (i).lu_change_date := null;
                  collemptable (i).lu_value := null;
                  collemptable (i).job_id := null;
                  collemptable (i).job_change_date := null;
                  collemptable (i).old_lu_value := null;
                  collemptable (i).rev_temination := null;
		  collemptable (i).corrected_start_date  := null;
               end loop;

               collemptable (1).status_type := '8I';
               collemptable (2).status_type := '8E';
               collemptable (3).status_type := '8K';
               collemptable (4).status_type := '8O';
               collemptable (5).status_type := '8F';
               --
               --
               /* Initialize the variables */
               l_lu_org_no := i.local_unit_org_no;
               l_local_unit_value := null;
               l_lu_change_effective_date := null;
               l_lu_change_effective_date1 := null;
               l_job_change_effective_date := null;
               l_job_change_effective_date1 := null;
               l_hour_element_entry_id := null;
               l_hour_year_change_flag := 'N';
               l_hour_value := null;
               l_hour_change_effective_date := null;
               l_hour_value_reported := null;
               l_element_entry_id := null;
               l_houry_change_flag := 'N';
               l_sickness_unpaid_end := null;
               l_sickness_unpaid_start := null;
               l_empl_start_date := null;
               l_emp_start_date := null;
               l_emp_end_date := null;
               l_abs_start_date := null;
               l_abs_end_date := null;
               l_element_entry_id := null;
               l_job_value := j.position_code;
               l_prev_hour_flag := 'Y';
               l_corr_change_flag := 'M'; -- C for correction , M for Change
	       l_hour_old_value := null;
               l_prev_hour_value_primary := null;
               l_prev_hour_eff_date := null;
	       l_lu_change_flag := 'N';
	       l_local_unit_org_no := i.local_unit_org_no ;
	       l_retrospective_hire_flag := 'N';
	       l_retrospective_date  := fnd_date.canonical_to_date('0001/01/01');
	       l_new_latest_start_date   := null;
               --
               --
               /* Get the Start Date */
               open csr_start_date (j.assignment_id);
               fetch csr_start_date into l_emp_start_date;
               close csr_start_date;

               l_empl_start_date := l_emp_start_date;
               l_emp_end_date := j.effective_end_date;
               IF l_emp_start_date < g_start_date then /* 5498504 */
                  l_prev_hour_flag := 'N';
               END IF;

--	     if nvl (find_total_hour (j.normal_hours,j.frequency), 0) >= g_min_avg_weekly_hours then  /* 5526111 */
               for k in csr_absence_start_days (j.person_id)
               loop
                  l_emp_end_date := k.date_start - 1;
                  loop /* 5525977 Find the week ends and public holidays */
                    hr_wrk_sch_pkg.get_per_asg_schedule (
                       p_person_assignment_id      => j.assignment_id,
                       p_period_start_date         => l_emp_end_date,
                       p_period_end_date           => l_emp_end_date + 1,
                       p_schedule_category         => null,
                       p_include_exceptions        => 'Y',
                       p_busy_tentative_as         => 'FREE',
                       x_schedule_source           => l_schedule_source,
                       x_schedule                  => l_schedule,
                       x_return_status             => l_return_status,
                       x_return_message            => l_return_message
                    );

                if l_schedule_source in ('PER_ASG', 'BUS_GRP', 'HR_ORG', 'JOB', 'POS', 'LOC') then
                    l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                    ( j.assignment_id, l_days_or_hours, l_include_event,
                    l_emp_end_date, l_emp_end_date, l_start_time_char,
                    l_end_time_char, l_duration
                    );

                    IF l_duration = 1 THEN
                       exit;
                    END IF;
                    l_emp_end_date := l_emp_end_date - 1;
                 else
		    exit;
                 end if;
                  end loop;

                  l_curr_hours      := 0;
                  l_curr_frequency  := null;
                  open curr_hours_frequency (j.assignment_id,l_emp_end_date);
                  fetch curr_hours_frequency into l_curr_hours,l_curr_frequency;
                  close curr_hours_frequency;
                  l_hour_value := get_assignment_all_hours (
                                  j.assignment_id,
                                  j.person_id,
                                  l_emp_end_date,
                                  l_curr_hours,
                                  i.local_unit_id );

		  if l_hour_value >= g_min_avg_weekly_hours then
                     collemptable (4).temination_date := l_emp_end_date;
                     collemptable (4).value_flag := 'Y';
--                  l_abs_start_date := k.date_start;
--                  l_abs_end_date := k.date_end;
                      /* Multiple absence recording */
                       open curr_lu_org_number  (j.assignment_id,l_emp_end_date);
                       fetch curr_lu_org_number  into l_local_unit_org_no;
                       close curr_lu_org_number ;

                       select pay_assignment_actions_s.nextval
                         into l_assact_id
                         from dual;

                        hr_nonrun_asact.insact (
                           l_assact_id,
                           j.assignment_id,
                           p_payroll_action_id,
                           20, --P_chunk,
                           null );

                           pay_action_information_api.create_action_information (
                           p_action_information_id            => l_action_info_id,
                           p_action_context_id                => l_assact_id,
                           p_action_context_type              => 'AAP',
                           p_object_version_number            => l_ovn,
                           p_effective_date                   => g_effective_date,
                           p_source_id                        => null,
                           p_source_text                      => null,
                           p_action_information_category      => 'EMEA REPORT INFORMATION',
                           p_action_information1              => 'PYNOEERCNT',
                           p_action_information2              => g_business_group_id,
                           p_action_information3              => g_legal_employer_id,
                           p_action_information4              => g_legal_employer_org_no,
                           p_action_information5              => i.local_unit_id,
                           p_action_information6              => l_local_unit_org_no,
                           p_action_information7              => j.person_id,
                           p_action_information8              => j.national_identifier,
                           p_action_information9              => j.full_name,
                           p_action_information10             => j.employee_number,
                           p_action_information14             => fnd_date.date_to_canonical(
			                                         collemptable (4).temination_date),
                           p_action_information21             => collemptable (4).status_type,
                           p_assignment_id                    => j.assignment_id
                        );

                       for i in 1 .. 5
                       loop
                          collemptable (i).value_flag := null;
                          collemptable (i).start_date := null;
                          collemptable (i).end_date := null;
                          collemptable (i).working_hours := null;
                          collemptable (i).corrected_start_date := null;
                          collemptable (i).hour_date_change := null;
                          collemptable (i).temination_date := null;
                          collemptable (i).lu_change_date := null;
                          collemptable (i).lu_value := null;
                          collemptable (i).job_id := null;
                          collemptable (i).job_change_date := null;
                          collemptable (i).old_lu_value := null;
                          collemptable (i).rev_temination := null;
                          collemptable (i).corrected_start_date  := null;
                       end loop;
                      /* Multiple absence recording End*/
                  end if;
               end loop; /* csr_absence_start_days */

                  /* 5648385 start */
		  l_prev_last_date := g_start_date - 1;
		  loop /* 5648385 Find the last working day of the previous period */

                    hr_wrk_sch_pkg.get_per_asg_schedule (
                       p_person_assignment_id      => j.assignment_id,
                       p_period_start_date         => l_prev_last_date,
                       p_period_end_date           => l_prev_last_date + 1,
                       p_schedule_category         => null,
                       p_include_exceptions        => 'Y',
                       p_busy_tentative_as         => 'FREE',
                       x_schedule_source           => l_schedule_source,
                       x_schedule                  => l_schedule,
                       x_return_status             => l_return_status,
                       x_return_message            => l_return_message
                    );

                if l_schedule_source in ('PER_ASG', 'BUS_GRP', 'HR_ORG', 'JOB', 'POS', 'LOC') then
                    l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                    ( j.assignment_id, l_days_or_hours, l_include_event,
                    l_prev_last_date, l_prev_last_date, l_start_time_char,
                    l_end_time_char, l_duration
                    );

		    IF l_duration = 1 THEN
                       exit;
                    END IF;
                    l_prev_last_date := l_prev_last_date - 1;
                else
		   exit;
                end if;
                  end loop;
                  /* 5648385 End */
	       /* 5525977 */
               for k in csr_absence_end_days (j.person_id,l_prev_last_date)
               loop
                  l_emp_start_date := k.date_end + 1;
                  loop /* 5525977 Find the week ends and public holidays */

                    hr_wrk_sch_pkg.get_per_asg_schedule (
                       p_person_assignment_id      => j.assignment_id,
                       p_period_start_date         => l_emp_start_date - 1,
                       p_period_end_date           => l_emp_start_date,
                       p_schedule_category         => null,
                       p_include_exceptions        => 'Y',
                       p_busy_tentative_as         => 'FREE',
                       x_schedule_source           => l_schedule_source,
                       x_schedule                  => l_schedule,
                       x_return_status             => l_return_status,
                       x_return_message            => l_return_message
                    );

                if l_schedule_source in ('PER_ASG', 'BUS_GRP', 'HR_ORG', 'JOB', 'POS', 'LOC') then
                    l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                    ( j.assignment_id, l_days_or_hours, l_include_event,
                    l_emp_start_date, l_emp_start_date, l_start_time_char,
                    l_end_time_char, l_duration
                    );

		    IF l_duration = 1 THEN
                       exit;
                    END IF;
                    l_emp_start_date := l_emp_start_date + 1;
                 else
		    exit;
                 end if;
                  end loop;

                  l_curr_hours      := 0;
                  l_curr_frequency  := null;
                  open curr_hours_frequency (j.assignment_id,l_emp_start_date);
                  fetch curr_hours_frequency into l_curr_hours,l_curr_frequency;
                  close curr_hours_frequency;
                  l_hour_value := get_assignment_all_hours (
                                  j.assignment_id,
                                  j.person_id,
                                  l_emp_start_date,
                                  l_curr_hours,
                                  i.local_unit_id );

                  if l_hour_value >= g_min_avg_weekly_hours
		  and l_emp_start_date <= g_end_date then  /* 5648385 */
                     l_curr_position := null;
                     open curr_position_code (j.assignment_id,l_emp_start_date);
                     fetch curr_position_code into l_curr_position;
                     close curr_position_code;
                     collemptable (1).start_date := l_emp_start_date;
                     collemptable (1).value_flag := 'Y';
                     collemptable (1).working_hours := l_hour_value;
                     collemptable (1).job_id := l_curr_position ;
                      /* Multiple absence recording */
                       open curr_lu_org_number  (j.assignment_id,l_emp_start_date);
                       fetch curr_lu_org_number  into l_local_unit_org_no;
                       close curr_lu_org_number ;

                       select pay_assignment_actions_s.nextval
                         into l_assact_id
                         from dual;

                        hr_nonrun_asact.insact (
                           l_assact_id,
                           j.assignment_id,
                           p_payroll_action_id,
                           20, --P_chunk,
                           null );

                           pay_action_information_api.create_action_information (
                           p_action_information_id            => l_action_info_id,
                           p_action_context_id                => l_assact_id,
                           p_action_context_type              => 'AAP',
                           p_object_version_number            => l_ovn,
                           p_effective_date                   => g_effective_date,
                           p_source_id                        => null,
                           p_source_text                      => null,
                           p_action_information_category      => 'EMEA REPORT INFORMATION',
                           p_action_information1              => 'PYNOEERCNT',
                           p_action_information2              => g_business_group_id,
                           p_action_information3              => g_legal_employer_id,
                           p_action_information4              => g_legal_employer_org_no,
                           p_action_information5              => i.local_unit_id,
                           p_action_information6              => l_local_unit_org_no,
                           p_action_information7              => j.person_id,
                           p_action_information8              => j.national_identifier,
                           p_action_information9              => j.full_name,
                           p_action_information10             => j.employee_number,
                           p_action_information11             => fnd_date.date_to_canonical(
			                                         collemptable (1).start_date),
                           p_action_information12             => fnd_number.number_to_canonical(
			                                         collemptable (1).working_hours),
                           p_action_information17             => collemptable (1).job_id,
			   p_action_information21             => collemptable (1).status_type,
                           p_assignment_id                    => j.assignment_id
                        );

                       for i in 1 .. 5
                       loop
                          collemptable (i).value_flag := null;
                          collemptable (i).start_date := null;
                          collemptable (i).end_date := null;
                          collemptable (i).working_hours := null;
                          collemptable (i).corrected_start_date := null;
                          collemptable (i).hour_date_change := null;
                          collemptable (i).temination_date := null;
                          collemptable (i).lu_change_date := null;
                          collemptable (i).lu_value := null;
                          collemptable (i).job_id := null;
                          collemptable (i).job_change_date := null;
                          collemptable (i).old_lu_value := null;
                          collemptable (i).rev_temination := null;
			  collemptable (i).corrected_start_date  := null;
                       end loop;
                      /* Multiple absence recording End*/
                  end if;
               end loop;  /* csr_absence_end_days */
--             end if;

               if j.hourly_salaried_code = 'H' then
                  l_prev_hour_flag := 'N';
                  open csr_get_element_entry (
                     j.assignment_id,
                     g_end_date,
                     'Average Weekly Hours'
                  );
                  fetch csr_get_element_entry into l_hour_element_entry_id;
                  close csr_get_element_entry;

                  if l_hour_element_entry_id is null then
                     l_houry_change_flag := 'Y';
                  else
                     l_hour_year_change_flag := 'Y';
                     open csr_get_curr_element_value (
                        l_hour_element_entry_id,
                        g_end_date
                     );
                     fetch csr_get_curr_element_value into l_hour_value;
                     close csr_get_curr_element_value;
                  /*end if;

                  for i in csr_get_element_value (
                              l_hour_element_entry_id,
                              g_start_date,
                              g_end_date
                           )
                  loop
                     if i.entry_value < g_min_avg_weekly_hours then
                        --   l_emp_start_date := null;
                        l_emp_end_date :=
                            add_months (last_day (i.effective_start_date), -1);
                        collemptable (5).temination_date := l_emp_end_date;
			collemptable (5).start_date := l_emp_start_date;
                        collemptable (5).value_flag := 'Y';
                        l_hour_value := null;
                        l_hour_change_effective_date := null;
                        l_prev_hour_flag := 'Y';
                     else
                        l_hour_value := i.entry_value;
                        l_hour_change_effective_date := i.effective_start_date;
                        collemptable (2).working_hours := l_hour_value;
                        collemptable (2).hour_date_change :=
                                                 l_hour_change_effective_date;
                        collemptable (2).value_flag := 'Y';

                        if l_prev_hour_flag = 'Y' then
                           l_emp_start_date :=
                              add_months (
                                 last_day (i.effective_start_date),
                                 -1
                              )
                              + 1;
                           collemptable (1).start_date :=
                                                 l_hour_change_effective_date;
                           collemptable (1).value_flag := 'Y';
                           collemptable (1).working_hours := l_hour_value;
                        else
                           l_hour_change_effective_date :=
                                                       i.effective_start_date;
                           l_prev_hour_flag := 'N';
                        end if;
                     end if;
                  end loop; */
                     l_hour_old_value := 0;
                     open csr_get_element_value (l_hour_element_entry_id,
                              add_months(trunc(g_start_date,'MM'),-1) , trunc(g_end_date,'MM') - 1 );
                     fetch csr_get_element_value into dummy_date,l_hour_old_value;
                     close csr_get_element_value;

                  for i in csr_get_element_value (l_hour_element_entry_id,g_start_date, g_end_date )
                  loop
                      l_hour_change_effective_date := i.effective_start_date ;
		      l_hour_value := i.entry_value;

			if trunc(l_empl_start_date,'MM') <> trunc(l_hour_change_effective_date,'MM') then
                             /* if hourly value is < avg and the old value is > avg then populate 8O record */
			      if nvl(l_hour_old_value,0) >= g_min_avg_weekly_hours
			      and nvl(l_hour_value,0) < g_min_avg_weekly_hours then
				l_emp_end_date := trunc(l_hour_change_effective_date,'MM') - 1;
				collemptable (4).temination_date := l_emp_end_date;
				collemptable (4).value_flag := 'Y';
				l_hour_value := null;
				l_hour_change_effective_date := null;
				l_prev_hour_flag := 'Y';
                             end if;
			      if nvl(l_hour_old_value,0) < g_min_avg_weekly_hours
			      and nvl(l_hour_value,0) >= g_min_avg_weekly_hours then
			        collemptable (1).start_date := trunc(l_hour_change_effective_date,'MM') ;
			        collemptable (1).value_flag := 'Y';
			        collemptable (1).working_hours := l_hour_value;
			        l_curr_position := null;
			        open curr_position_code (j.assignment_id, l_hour_change_effective_date);
			        fetch curr_position_code into l_curr_position;
			        close curr_position_code;
			        collemptable (1).job_id := l_curr_position;
                             /* if hourly value is less then avarage, should not populate 8E record */
			     elsif nvl(l_hour_value,0)  >= g_min_avg_weekly_hours then
				collemptable (2).working_hours := l_hour_value;
				collemptable (2).hour_date_change := l_hour_change_effective_date;
				collemptable (2).value_flag := 'Y';
                              end if;
                        else
                           /* if hourly value is less then avarage, should not populate 8I record */
			   if l_hour_value >= g_min_avg_weekly_hours then
                             collemptable (1).start_date := l_empl_start_date ;
                             collemptable (1).value_flag := 'Y';
                             collemptable (1).working_hours := l_hour_value;
                             l_curr_position := null;
                             open curr_position_code (j.assignment_id, l_hour_change_effective_date);
                             fetch curr_position_code into l_curr_position;
                             close curr_position_code;
                             collemptable (1).job_id := l_curr_position;
			   end if;
                        end if;
                  end loop;
                  end if; /* l_hour_element_entry_id not null */
               end if; -- End if of Hourly_salaried_code = 'H'
               begin
                  open csr_get_sick_unpaid_entry (
                     j.assignment_id,
		     g_start_date,
                     g_end_date,
                     'Sickness Unpaid'
                  );
                  fetch csr_get_sick_unpaid_entry into l_element_entry_id;
                  close csr_get_sick_unpaid_entry;

                  if l_element_entry_id is not null then
                     begin
                        pay_interpreter_pkg.entry_affected (
                           p_element_entry_id           => l_element_entry_id,
                           p_assignment_action_id       => null,
                           p_assignment_id              => j.assignment_id,
                           p_mode                       => 'DATE_EARNED',
                           p_process                    => 'U',
                           p_event_group_id             => l_event_group_id,
                           p_process_mode               => 'ENTRY_EFFECTIVE_DATE' --ENTRY_CREATION_DATE
                           ,
                           p_start_date                 => g_start_date - 1,  /* 5496538 */
                           p_end_date                   => g_end_date,
                           t_detailed_output            => l_detail_tab,
                           t_proration_dates            => l_proration_dates,
                           t_proration_change_type      => l_proration_changes,
                           t_proration_type             => l_pro_type_tab
                        );
                     exception
                        when no_data_found then
                           l_detail_tab.delete;
                        when others then
                           l_detail_tab.delete;
                     end;

                     sort_changes (l_detail_tab);

                     if l_detail_tab.count <> 0 then
                        /* Start If for count check */
                        for cnt in l_detail_tab.first .. l_detail_tab.last
                        loop
                           /* 5648385 begin
                              if    (l_detail_tab (cnt).dated_table_id =
                                                                     l_table1
                                    )
                                 or (l_detail_tab (cnt).dated_table_id =
                                                                     l_table2
                                    ) then
                                 if csr_get_element_det%isopen then
                                    close csr_get_element_det;
                                 end if;

                                 open csr_get_element_det (
                                    'Sickness Unpaid',
                                    'Start Date',
                                    j.assignment_id,
                                    l_detail_tab (cnt).effective_date
                                 );
                                 fetch csr_get_element_det into l_sickness_unpaid_start;
                                 close csr_get_element_det;

                                 if csr_get_element_det%isopen then
                                    close csr_get_element_det;
                                 end if;

                                 open csr_get_element_det (
                                    'Sickness Unpaid',
                                    'End Date',
                                    j.assignment_id,
                                    l_detail_tab (cnt).effective_date
                                 );
                                 fetch csr_get_element_det into l_sickness_unpaid_end;
                                 close csr_get_element_det;
                              end if;
                           end;*/
                           if l_detail_tab (cnt).dated_table_id = l_table1 then
                              l_sickness_unpaid_start := l_detail_tab (cnt).effective_date ;
			   end if;
                        end loop;
                     end if;

                     l_emp_end_date := l_sickness_unpaid_start - 1;

                     collemptable (4).temination_date := l_emp_end_date;
                     collemptable (4).value_flag := 'Y';

                     /*if l_sickness_unpaid_end >= g_end_date then
                        l_emp_start_date := null;
                     else
                        l_emp_start_date := l_sickness_unpaid_end + 1;
                        collemptable (4).temination_date := l_emp_end_date;
                        collemptable (4).value_flag := 'Y';
                     end if;*/
                  end if;
               end;

	       /* Multiple entry Start*/
               for cnt in collemptable.first .. collemptable.last
               loop
                  if collemptable (cnt).value_flag = 'Y' then
                     select pay_assignment_actions_s.nextval
                       into l_assact_id
                       from dual;

                     hr_nonrun_asact.insact (
                        l_assact_id,
                        j.assignment_id,
                        p_payroll_action_id,
                        20, --P_chunk,
                        null );

                     if    (    cnt = 1
                            and collemptable (1).working_hours is not null
                            and collemptable (1).job_id is not null
			    and collemptable (1).job_id <> '0'
                           )
                        or (cnt <> 1) then
                           pay_action_information_api.create_action_information (
                           p_action_information_id            => l_action_info_id,
                           p_action_context_id                => l_assact_id,
                           p_action_context_type              => 'AAP',
                           p_object_version_number            => l_ovn,
                           p_effective_date                   => g_effective_date,
                           p_source_id                        => null,
                           p_source_text                      => null,
                           p_action_information_category      => 'EMEA REPORT INFORMATION',
                           p_action_information1              => 'PYNOEERCNT',
                           p_action_information2              => g_business_group_id -- Business Group id
                           ,
                           p_action_information3              => g_legal_employer_id -- Legal Employer Org ID
                           ,
                           p_action_information4              => g_legal_employer_org_no -- Legal Employer Org ID
                           ,
                           p_action_information5              => i.local_unit_id,
                           p_action_information6              => l_local_unit_org_no, /* 5519990 */
                           p_action_information7              => j.person_id -- Person id
                           ,
                           p_action_information8              => j.national_identifier -- National Identifier
                           ,
                           p_action_information9              => j.full_name -- Full Name
                           ,
                           p_action_information10             => j.employee_number -- Employee Number
                           ,
                           p_action_information11             => fnd_date.date_to_canonical(collemptable (
                                                                    cnt
                                                                 ).start_date) -- Employment Start Date
                           --,p_action_information16         => p_time_period_id
                           ,
                           p_action_information12             =>fnd_number.number_to_canonical(collemptable (
                                                                    cnt
                                                                 ).working_hours) -- Weekly Working Hours
                           ,
                           p_action_information13             => fnd_date.date_to_canonical(collemptable (
                                                                    cnt
                                                                 ).hour_date_change) -- Date of change of hours
                           ,
                           p_action_information14             => fnd_date.date_to_canonical(collemptable (
                                                                    cnt
                                                                 ).temination_date) -- Employment Termination Date
                           ,
                           p_action_information15             => collemptable (
                                                                    cnt
                                                                 ).lu_value -- Local Unit Org No
                           ,
                           p_action_information16             => fnd_date.date_to_canonical(collemptable (
                                                                    cnt
                                                                 ).lu_change_date) -- Local Unit Change Date
                           ,
                           p_action_information17             => collemptable (
                                                                    cnt
                                                                 ).job_id -- Occupation
                           ,
                           p_action_information18             =>fnd_date.date_to_canonical( collemptable (
                                                                    cnt
                                                                 ).job_change_date) -- Occupation change date
                           ,
                           p_action_information19             => fnd_date.date_to_canonical(l_abs_start_date) -- Occupation change date
                           ,
                           p_action_information20             => fnd_date.date_to_canonical(l_abs_end_date),
                           p_action_information21             => collemptable (
                                                                    cnt
                                                                 ).status_type,
                           p_action_information22             => fnd_date.date_to_canonical(collemptable (
                                                                    cnt
                                                                 ).corrected_start_date),
                           p_action_information23             => collemptable (cnt).rev_temination,
                           p_assignment_id                    => j.assignment_id
                        );                     end if;
                  end if;
               end loop;

               for i in 1 .. 5
               loop
                 collemptable (i).value_flag := null;
                 collemptable (i).start_date := null;
                 collemptable (i).end_date := null;
                 collemptable (i).working_hours := null;
                 collemptable (i).corrected_start_date := null;
                 collemptable (i).hour_date_change := null;
                 collemptable (i).temination_date := null;
                 collemptable (i).lu_change_date := null;
                 collemptable (i).lu_value := null;
                 collemptable (i).job_id := null;
                 collemptable (i).job_change_date := null;
                 collemptable (i).old_lu_value := null;
                 collemptable (i).rev_temination := null;
		 collemptable (i).corrected_start_date  := null;
               end loop;
	       /* Multiple entry End*/

               begin
                  pay_interpreter_pkg.entry_affected (
                     p_element_entry_id           => null,
                     p_assignment_action_id       => null,
                     p_assignment_id              => j.assignment_id,
                     p_mode                       => 'DATE_PROCESSED',
                     p_process                    => 'U',
                     p_event_group_id             => l_event_group_id,
                     p_process_mode               => 'ENTRY_EFFECTIVE_DATE' --ENTRY_CREATION_DATE
                     ,
                     p_start_date                 => g_start_date - 1, /* 5496538 */
                     p_end_date                   => g_end_date,
                     t_detailed_output            => l_detailed_output1,
                     t_proration_dates            => l_proration_dates,
                     t_proration_change_type      => l_proration_changes,
                     t_proration_type             => l_pro_type_tab
                  );
               exception
                  when no_data_found then
                     l_detailed_output1.delete;
                  when others then
                     l_detailed_output1.delete;
               end;
               /* 8K Start */
	       begin
                  pay_interpreter_pkg.entry_affected (
                     p_element_entry_id           => null,
                     p_assignment_action_id       => null,
                     p_assignment_id              => j.assignment_id,
                     p_mode                       => 'DATE_PROCESSED',
                     p_process                    => 'U',
                     p_event_group_id             => l_event_group_id,
                     p_process_mode               => 'ENTRY_CREATION_DATE',
                     p_start_date                 => g_start_date - 1, /* 5496538 */
                     p_end_date                   => g_end_date,
                     t_detailed_output            => l_detailed_output2,
                     t_proration_dates            => l_proration_dates,
                     t_proration_change_type      => l_proration_changes,
                     t_proration_type             => l_pro_type_tab
                  );
               exception
                  when no_data_found then
                     l_detailed_output2.delete;
                  when others then
                     l_detailed_output2.delete;
               end;

	     l_detailed_output := l_empty_detailed_output;
	     merge_cnt := 1 ;
	     if l_detailed_output1.count <> 0 then
               for i in l_detailed_output1.first .. l_detailed_output1.last
               loop
                 l_detailed_output(merge_cnt).effective_date    := l_detailed_output1(i).effective_date;
	         l_detailed_output(merge_cnt).creation_date     := l_detailed_output1(i).creation_date  ;
	         l_detailed_output(merge_cnt).column_name       := l_detailed_output1(i).column_name;
	         l_detailed_output(merge_cnt).new_value         := l_detailed_output1(i).new_value;
	         l_detailed_output(merge_cnt).change_values     := l_detailed_output1(i).change_values;
	         l_detailed_output(merge_cnt).old_value         := l_detailed_output1(i).old_value;
	         l_detailed_output(merge_cnt).dated_table_id    := l_detailed_output1(i).dated_table_id ;
                 l_detailed_output(merge_cnt).datetracked_event := l_detailed_output1(i).datetracked_event;
	         l_detailed_output(merge_cnt).surrogate_key     := l_detailed_output1(i).surrogate_key ;
	         l_detailed_output(merge_cnt).update_type       := l_detailed_output1(i).update_type ;
	         l_detailed_output(merge_cnt).proration_type    := l_detailed_output1(i).proration_type;
	         l_detailed_output(merge_cnt).change_mode       := l_detailed_output1(i).change_mode;
	         l_detailed_output(merge_cnt).element_entry_id  := l_detailed_output1(i).element_entry_id;
		 l_detailed_output(merge_cnt).assignment_id     := j.assignment_id;
	         merge_cnt := merge_cnt + 1;
	       end loop;
	     end if;
	     /* merge the creation date records */
	     if l_detailed_output2.count <> 0 then
              for i in l_detailed_output2.first .. l_detailed_output2.last
              loop
	       if l_detailed_output2(i).effective_date < g_start_date or
	        ( l_detailed_output2(i).column_name = 'EFFECTIVE_END_DATE'
		  and l_detailed_output2(i).effective_date > g_end_date ) then
  	         l_detailed_output(merge_cnt).effective_date    := l_detailed_output2(i).effective_date;
	         l_detailed_output(merge_cnt).creation_date     := l_detailed_output2(i).creation_date  ;
	         l_detailed_output(merge_cnt).column_name       := l_detailed_output2(i).column_name;
	         l_detailed_output(merge_cnt).new_value         := l_detailed_output2(i).new_value;
	         l_detailed_output(merge_cnt).change_values     := l_detailed_output2(i).change_values;
	         l_detailed_output(merge_cnt).old_value         := l_detailed_output2(i).old_value;
	         l_detailed_output(merge_cnt).dated_table_id    := l_detailed_output2(i).dated_table_id ;
                 l_detailed_output(merge_cnt).datetracked_event := l_detailed_output2(i).datetracked_event;
	         l_detailed_output(merge_cnt).surrogate_key     := l_detailed_output2(i).surrogate_key ;
	         l_detailed_output(merge_cnt).update_type       := l_detailed_output2(i).update_type ;
	         l_detailed_output(merge_cnt).proration_type    := l_detailed_output2(i).proration_type;
	         l_detailed_output(merge_cnt).change_mode       := l_detailed_output2(i).change_mode;
	         l_detailed_output(merge_cnt).element_entry_id  := l_detailed_output2(i).element_entry_id;
		 l_detailed_output(merge_cnt).assignment_id     := j.assignment_id;
	         merge_cnt := merge_cnt + 1;
	       end if;
              end loop;
             end if;

		 for l_get_all_assignments in csr_get_all_assignments (j.person_id,
							              j.assignment_id,
								      i.local_unit_id)
                  loop
		    begin
			  pay_interpreter_pkg.entry_affected (
			     p_element_entry_id           => null,
			     p_assignment_action_id       => null,
			     p_assignment_id              => l_get_all_assignments.assignment_id,
			     p_mode                       => 'DATE_PROCESSED',
			     p_process                    => 'U',
			     p_event_group_id             => l_event_group_id,
			     p_process_mode               => 'ENTRY_EFFECTIVE_DATE',
			     p_start_date                 => g_start_date - 1, /* 5496538 */
			     p_end_date                   => g_end_date,
			     t_detailed_output            => l_detailed_output3,
			     t_proration_dates            => l_proration_dates,
			     t_proration_change_type      => l_proration_changes,
			     t_proration_type             => l_pro_type_tab
			  );
		       exception
			  when no_data_found then
			     l_detailed_output3.delete;
			  when others then
			     l_detailed_output3.delete;
		     end;
                     begin
		     pay_interpreter_pkg.entry_affected (
			     p_element_entry_id           => null,
			     p_assignment_action_id       => null,
			     p_assignment_id              => l_get_all_assignments.assignment_id,
			     p_mode                       => 'DATE_PROCESSED',
			     p_process                    => 'U',
			     p_event_group_id             => l_event_group_id,
			     p_process_mode               => 'ENTRY_CREATION_DATE',
			     p_start_date                 => g_start_date - 1, /* 5496538 */
			     p_end_date                   => g_end_date,
			     t_detailed_output            => l_detailed_output4,
			     t_proration_dates            => l_proration_dates,
			     t_proration_change_type      => l_proration_changes,
			     t_proration_type             => l_pro_type_tab
			  );
		       exception
			  when no_data_found then
			     l_detailed_output4.delete;
			  when others then
			     l_detailed_output4.delete;
		     end;

	      if l_detailed_output3.count <> 0 then
                 for i in l_detailed_output3.first .. l_detailed_output3.last
   	         loop
	           if l_detailed_output3(i).column_name = 'NORMAL_HOURS' OR l_detailed_output3(i).column_name = 'ASSIGNMENT_STATUS_TYPE_ID'
			OR (l_detailed_output3(i).dated_table_id = l_table3 and l_detailed_output3(i).update_type  = 'I' )then
			 l_detailed_output(merge_cnt).effective_date    := l_detailed_output3(i).effective_date;
			 l_detailed_output(merge_cnt).creation_date     := l_detailed_output3(i).creation_date  ;
			 l_detailed_output(merge_cnt).column_name       := l_detailed_output3(i).column_name;
			 l_detailed_output(merge_cnt).new_value         := l_detailed_output3(i).new_value;
			 l_detailed_output(merge_cnt).change_values     := l_detailed_output3(i).change_values;
			 l_detailed_output(merge_cnt).old_value         := l_detailed_output3(i).old_value;
			 l_detailed_output(merge_cnt).dated_table_id    := l_detailed_output3(i).dated_table_id ;
			 l_detailed_output(merge_cnt).datetracked_event := l_detailed_output3(i).datetracked_event;
			 l_detailed_output(merge_cnt).surrogate_key     := l_detailed_output3(i).surrogate_key ;
			 l_detailed_output(merge_cnt).update_type       := l_detailed_output3(i).update_type ;
			 l_detailed_output(merge_cnt).proration_type    := l_detailed_output3(i).proration_type;
			 l_detailed_output(merge_cnt).change_mode       := l_detailed_output3(i).change_mode;
			 l_detailed_output(merge_cnt).element_entry_id  := l_detailed_output3(i).element_entry_id;
			 l_detailed_output(merge_cnt).assignment_id     := l_get_all_assignments.assignment_id;
			 merge_cnt := merge_cnt + 1;
	           end if;

		  end loop;
	      end if;



	       if l_detailed_output4.count <> 0 then
                 for i in l_detailed_output4.first .. l_detailed_output4.last
   	         loop
		   if l_detailed_output4(i).effective_date < g_start_date or
	              ( l_detailed_output4(i).column_name = 'EFFECTIVE_END_DATE'
		      and l_detailed_output4(i).effective_date > g_end_date ) then
			   if l_detailed_output4(i).column_name = 'NORMAL_HOURS' OR l_detailed_output4(i).column_name = 'ASSIGNMENT_STATUS_TYPE_ID' OR (l_detailed_output4(i).dated_table_id = l_table3 and l_detailed_output4(i).update_type  = 'I' )then
				 l_detailed_output(merge_cnt).effective_date    := l_detailed_output4(i).effective_date;
				 l_detailed_output(merge_cnt).creation_date     := l_detailed_output4(i).creation_date  ;
				 l_detailed_output(merge_cnt).column_name       := l_detailed_output4(i).column_name;
				 l_detailed_output(merge_cnt).new_value         := l_detailed_output4(i).new_value;
				 l_detailed_output(merge_cnt).change_values     := l_detailed_output4(i).change_values;
				 l_detailed_output(merge_cnt).old_value         := l_detailed_output4(i).old_value;
				 l_detailed_output(merge_cnt).dated_table_id    := l_detailed_output4(i).dated_table_id ;
				 l_detailed_output(merge_cnt).datetracked_event := l_detailed_output4(i).datetracked_event;
				 l_detailed_output(merge_cnt).surrogate_key     := l_detailed_output4(i).surrogate_key ;
				 l_detailed_output(merge_cnt).update_type       := l_detailed_output4(i).update_type ;
				 l_detailed_output(merge_cnt).proration_type    := l_detailed_output4(i).proration_type;
				 l_detailed_output(merge_cnt).change_mode       := l_detailed_output4(i).change_mode;
				 l_detailed_output(merge_cnt).element_entry_id  := l_detailed_output4(i).element_entry_id;
				 l_detailed_output(merge_cnt).assignment_id     := l_get_all_assignments.assignment_id;
				 merge_cnt := merge_cnt + 1;
			   end if;
		   end if;
		  end loop;
	      end if;
            end loop;

	       /* 8K End */
               sort_changes1 (l_detailed_output);
               if l_detailed_output.count <> 0 then
                  /* Start If for count check */
                  for cnt in l_detailed_output.first .. l_detailed_output.last
                  loop
                     if (l_detailed_output(cnt).effective_date not between
                       g_start_date and g_end_date) and
                       (l_detailed_output(cnt).creation_date between
                       g_start_date and g_end_date) then
                        l_corr_change_flag := 'C';
                     else
                        l_corr_change_flag := 'M';
                     end if;

                     /* Start loop for Column Check*/
                     l_hour_effective_end_date := null;
                     l_new_scl := null;
                     l_old_scl := null;
                     l_new_lu := null;
                     l_old_lu := null;
                     l_old_job_value := null;
                     l_new_job_value := null;
		     l_new_latest_start_date := null;
		     l_old_latest_start_date := null;

		     if     l_detailed_output(cnt).dated_table_id = l_table3 and l_detailed_output (cnt).update_type  = 'I' then

			    rl_assignment_details.normal_hours := 0;
			    rl_assignment_details.hourly_salaried_code := null;
			    rl_assignment_details.position_code := null;
			    rl_assignment_details.frequency := null;
			   -- rl_assignment_details.effective_Date := null;

			    open csr_get_assignment_details(l_detailed_output(cnt).effective_Date,
			                                   l_detailed_output (cnt).assignment_id);-- j.assignment_id,
							   -- i.local_unit_id);
			    fetch csr_get_assignment_details into rl_assignment_details;
			    close csr_get_assignment_details;
                        --
			if rl_assignment_details.normal_hours is not null and ( j.hourly_salaried_code = 'S'
                                or l_houry_change_flag = 'Y') then

                        l_hour_value := get_assignment_all_hours (
                                           l_detailed_output (cnt).assignment_id,
                                           j.person_id,
                                           l_detailed_output (cnt).effective_date,
                                           rl_assignment_details.normal_hours,
                                           i.local_unit_id
                                        );

			 if nvl (l_hour_value, 0) >= g_min_avg_weekly_hours and l_detailed_output (cnt).assignment_id = j.assignment_id then
                             collemptable (1).value_flag := 'Y';
			     collemptable (1).start_date :=
                                                             l_detailed_output (cnt).effective_date;
                             collemptable (1).working_hours := l_hour_value;
                             collemptable (1).job_id := rl_assignment_details.position_code;
			     l_job_value := rl_assignment_details.position_code;
			     l_emp_start_date := l_detailed_output (cnt).effective_date;


			     if l_detailed_output (cnt).effective_date not between g_start_date and g_end_date then
				l_retrospective_hire_flag := 'Y' ;
				l_retrospective_date := l_detailed_output(cnt).effective_date;

                             else
			        l_retrospective_date := fnd_date.canonical_to_date('0001/01/01');
		             end if;

			 else
                           if l_Emp_start_Date <> l_detailed_output (cnt).effective_date then
			     if l_corr_change_flag = 'M' then
			     collemptable (2).value_flag := 'Y';
                             collemptable (2).working_hours := l_hour_value;
                             collemptable (2).hour_date_change := l_detailed_output (cnt).effective_date;
			     elsif l_corr_change_flag = 'C' then
			     collemptable (3).value_flag := 'Y';
                             collemptable (3).working_hours := l_hour_value;
                             collemptable (3).hour_date_change := l_detailed_output (cnt).effective_date;
			     end if;
			   end if ;
			 end if;
		        end if;
                     elsif     l_detailed_output (cnt).column_name =
                                                                'NORMAL_HOURS'
                        and (   j.hourly_salaried_code = 'S'
                             or l_houry_change_flag = 'Y'
                            ) and
			     l_retrospective_date <> l_detailed_output (cnt).effective_date then
                        l_hour_year_change_flag := 'Y' ;

                        begin
                           l_hour_value_primary := fnd_number.canonical_to_number (
                                                      nvl (
                                                         l_detailed_output (
                                                            cnt
                                                         ).new_value,
                                                         substr (
                                                            l_detailed_output (
                                                               cnt
                                                            ).change_values,
                                                            instr (
                                                               l_detailed_output (
                                                                  cnt
                                                               ).change_values,
                                                               '->'
                                                            )
                                                            + 3
                                                         )
                                                      )
                                                   );
                        exception
                           when value_error then
                              l_hour_value_primary := 0;
                        end;

                        l_hour_change_effective_date :=
                                        l_detailed_output (cnt).effective_date;
                        --
                        l_hour_value := get_assignment_all_hours (
                                           l_detailed_output (cnt).assignment_id,
                                           j.person_id,
                                           l_detailed_output (cnt).effective_date,
                                           l_hour_value_primary,
                                           i.local_unit_id
                                        );

                      /*find the previous (old) working hours */
                      l_hour_old_value := 0;
                      l_prev_hour_value_primary := 0 ;
                      l_prev_hour_eff_date := null ;
                      for i in previous_hour_value (l_detailed_output (cnt).assignment_id, l_hour_change_effective_date)
                      loop
                           if i.normal_hours <> l_hour_value_primary then
                              l_prev_hour_value_primary := i.normal_hours ;
                              l_prev_hour_eff_date := i.effective_start_date ;
                              --exit;
                           end if;
                      end loop;
                      l_hour_old_value := get_assignment_all_hours (
                                           l_detailed_output (cnt).assignment_id,
                                           j.person_id,
                                           l_hour_change_effective_date - 1,  --l_prev_hour_eff_date,
                                           l_prev_hour_value_primary,
                                           i.local_unit_id
                                        );

			/* IF ends for When Column = NORMAL_HOURS*/
                        if nvl (l_hour_value, 0) < g_min_avg_weekly_hours then
                           for cnt1 in
                              l_detailed_output.first .. l_detailed_output.last
                           loop
			      begin
			      l_new_hour := 0;
			      l_new_hour :=  fnd_number.canonical_to_number (
                                                         nvl (
                                                            l_detailed_output (
                                                               cnt1
                                                            ).new_value,
                                                            substr (
                                                               l_detailed_output (
                                                                  cnt1
                                                               ).change_values,
                                                               instr (
                                                                  l_detailed_output (
                                                                     cnt1
                                                                  ).change_values,
                                                                  '->'
                                                               )
                                                               + 3
                                                            )
                                                         )
                                                      );
                           exception
                              when value_error then
                                 l_new_hour := 0;
                              end;
                              if     l_detailed_output (cnt1).column_name =
                                                               'NORMAL_HOURS'
                                 and l_detailed_output (cnt1).effective_date >
                                                 l_hour_change_effective_date and nvl(l_new_hour,0) >= g_min_avg_weekly_hours then
                                 l_hour_effective_end_date :=
                                      l_detailed_output (cnt1).effective_date;
                                 exit;
                              end if;
                           end loop;


                           if nvl (l_hour_effective_end_date, g_end_date)
                              - nvl (
                                   l_hour_change_effective_date,
                                   g_start_date
                                ) > g_no_hours_change_weeks then
                               if l_emp_start_date <> l_hour_change_effective_date
                               and l_corr_change_flag = 'M'
			       and nvl(l_hour_old_value,0) >= g_min_avg_weekly_hours then
                                --   l_emp_start_date := null;
                                 l_emp_end_date :=
                                             l_hour_change_effective_date - 1;
                                 collemptable (4).temination_date :=
                                                               l_emp_end_date;
                                 collemptable (4).value_flag := 'Y';
                                 l_prev_hour_flag := 'Y';
                           /* else
             if l_emp_start_date is null then
                l_emp_start_date := l_hour_change_effective_date;
             end if;               /* End if of Emp Start Date Null*/
	                       else
                                 collemptable (1).value_flag := 'N';
                               end if;
			    end if;
                        /* End if of when min hours remain more than 2 weeks*/
                        else
                           /* to check if changes are more than the min limint for Hour change*/
			   /* Min hour check is only for 8E not 8I
                           if abs (
                                 nvl (l_hour_value, 0)
                                 - nvl (l_hour_old_value, 0)
                              ) >= g_hour_change_limit then*/
                              /*if l_emp_start_date is null then*/
                              if    l_prev_hour_flag = 'Y' or
			            (nvl (l_hour_old_value, 0) < g_min_avg_weekly_hours   /* 5512163 */
				    and l_corr_change_flag <> 'C') then
                                 --or nvl (l_hour_value_reported, 0) = 0 then /* 5498504 */
                                 l_emp_start_date :=
                                                 l_hour_change_effective_date;
                                 collemptable (1).start_date :=
                                                             l_emp_start_date;
                                 collemptable (1).value_flag := 'Y';
                                 collemptable (1).working_hours :=
                                                                 l_hour_value;
                                 l_curr_position := null;
                                 open curr_position_code (l_detailed_output (cnt).assignment_id,
				                          l_detailed_output (cnt).effective_date);
                                 fetch curr_position_code into l_curr_position;
                                 close curr_position_code;
                                 collemptable (1).job_id := l_curr_position;
                              end if;

                           /*   l_hour_value_reported := l_hour_value;
                              l_hour_date_reported :=
                                                  l_hour_change_effective_date;
                           else
                              l_hour_value := l_hour_value_reported;
                              l_hour_change_effective_date :=
                                                         l_hour_date_reported;
                           end if;*/

                           l_prev_hour_flag := 'N';
                        end if;

			if l_emp_start_date <> l_hour_change_effective_date
			   or l_corr_change_flag = 'C' then
                           if l_corr_change_flag = 'M' then
			     if nvl (l_hour_value, 0) >= g_min_avg_weekly_hours and
                                abs (nvl (l_hour_value, 0) - nvl (l_hour_old_value, 0)) >= g_hour_change_limit then /* 5512251 */
                              collemptable (2).working_hours := l_hour_value;
                              collemptable (2).hour_date_change :=
                                                 l_hour_change_effective_date;
                              collemptable (2).value_flag := 'Y';
                             end if;
                           else
                              if nvl (l_hour_value, 0) < g_min_avg_weekly_hours then
				if nvl(l_hour_old_value,0) >= g_min_avg_weekly_hours then
					l_emp_end_date := l_hour_change_effective_date - 1;
					collemptable (5).start_date := l_emp_start_date;
					--psingla
					--if l_emp_end_date >  l_emp_start_date then
					collemptable (5).temination_date := l_emp_end_date;
					--end if;
					collemptable (5).value_flag := 'Y';
				end if;
                              else
                                collemptable (3).working_hours := l_hour_value;
                                collemptable (3).hour_date_change :=
                                                 l_hour_change_effective_date;
                                collemptable (3).start_date := l_emp_start_date;
                                collemptable (3).value_flag := 'Y';
			      end if;
                           end if;
                        else
                           /* if hourly value is less then avarage, should not populate 8I record */
			   if nvl (l_hour_value, 0) >= g_min_avg_weekly_hours then
                             collemptable (1).value_flag := 'Y';
                             collemptable (1).working_hours := l_hour_value;
                             l_curr_position := null;
                             open curr_position_code (l_detailed_output (cnt).assignment_id,
                                                      l_detailed_output (cnt).effective_date);
                             fetch curr_position_code into l_curr_position;
                             close curr_position_code;
                             collemptable (1).job_id := l_curr_position;
			   end if;
                        end if;
                     elsif l_detailed_output (cnt).column_name = 'JOB_ID' and
			     l_retrospective_date <> l_detailed_output (cnt).effective_date then
                        l_job_id :=
                           fnd_number.canonical_to_number (
                              nvl (
                                 l_detailed_output (cnt).new_value,
                                 fnd_number.canonical_to_number (
                                    substr (
                                       l_detailed_output (cnt).change_values,
                                       instr (
                                          l_detailed_output (cnt).change_values,
                                          '->'
                                       )
                                       + 3
                                    )
                                 )
                              )
                           );
                        open csr_get_job_position_code (
                           j.assignment_id,
                           l_detailed_output (cnt).effective_date,
                           l_job_id
                        );
                        fetch csr_get_job_position_code into l_job_value;
                        close csr_get_job_position_code;
                        collemptable (2).job_id := l_job_value;
                        collemptable (2).job_change_date :=
                                       l_detailed_output (cnt).effective_date;
                        collemptable (2).value_flag := 'Y';

                        if l_detailed_output (cnt).effective_date >
                                                            l_empl_start_date then
                           l_job_change_effective_date :=
                                       l_detailed_output (cnt).effective_date;
                        else
                           collemptable (1).job_id := l_job_value;
                        end if;


		   elsif l_detailed_output(cnt).column_name = 'SOFT_CODING_KEYFLEX_ID'     /*and
		       l_retrospective_date <> l_detailed_output (cnt).effective_date*/
		   then
		      l_local_unit_value :=
			 nvl(l_detailed_output(cnt).new_value,
			     fnd_number.canonical_to_number(substr(l_detailed_output(cnt).change_values,
								      instr(l_detailed_output(cnt
											     ).change_values,
									    '->'
									   )
								    + 3
								  )
							   )
			    );
		      l_old_scl :=
			 substr(l_detailed_output(cnt).change_values,
				0,
				   instr(l_detailed_output(cnt).change_values, '->')
				 - 1
			       );
		      l_new_scl :=
			 substr(l_detailed_output(cnt).change_values,
				   instr(l_detailed_output(cnt).change_values, '->')
				 + 3
			       );

		      if l_retrospective_date <> l_detailed_output(cnt).effective_date
		      then
			 if l_old_scl = '<null> '
			 then
			    l_old_scl := '0';
			    l_local_unit_value := l_new_scl;
			    open csr_get_pos_scl(fnd_number.canonical_to_number(l_new_scl));
			    fetch csr_get_pos_scl into l_job_value;

			    if l_emp_start_date <> l_detailed_output(cnt).effective_date
			    then
			       collemptable(2).job_change_date :=
							l_detailed_output(cnt).effective_date;
			       collemptable(2).job_id := l_job_value;
			       collemptable(2).value_flag := 'Y';
			    else
			       collemptable(1).job_id := l_job_value;
			    end if;

			    close csr_get_pos_scl;
			    open csr_get_org_no(fnd_number.canonical_to_number(l_new_scl));
			    fetch csr_get_org_no into l_lu_org_no;

			    if    l_emp_start_date <> l_detailed_output(cnt).effective_date
			       or l_corr_change_flag = 'C'
			    then
			       if l_corr_change_flag = 'M'
			       then
				  collemptable(2).lu_value := l_lu_org_no;
				  collemptable(2).lu_change_date :=
							l_detailed_output(cnt).effective_date;
				  collemptable(2).value_flag := 'Y';
			       else
				  collemptable(3).lu_value := l_lu_org_no;
				  collemptable(3).lu_change_date :=
							l_detailed_output(cnt).effective_date;
				  collemptable(3).start_date := l_emp_start_date;
				  collemptable(3).value_flag := 'Y';
			       end if;
			    /*else 5511746
			       collemptable (1).lu_value := l_lu_org_no;*/
			    end if;

			    close csr_get_org_no;

			    if    l_detailed_output(cnt).effective_date > l_empl_start_date
			       or l_corr_change_flag = 'C'
			    then
			       l_lu_change_effective_date :=
							l_detailed_output(cnt).effective_date;

			       if l_job_value is not null
			       then
				  l_job_change_effective_date :=
							l_detailed_output(cnt).effective_date;
				  collemptable(2).job_change_date :=
								  l_job_change_effective_date;
			       end if;
			    else
			       if l_job_value is not null
			       then
				  collemptable(1).job_id := l_job_value;
			       end if;
			    end if;

			    /*5695791*/
			       /* Code for Latest Start Date */
			    open csr_get_latest_st_date_scl(fnd_number.canonical_to_number(l_new_scl
											  )
							   );
			    fetch csr_get_latest_st_date_scl into l_new_latest_start_date;
			    close csr_get_latest_st_date_scl;

			    if     l_new_latest_start_date is not null
			       and (l_new_latest_start_date <> l_emp_start_date)
			    then
			       collemptable(3).start_date := l_emp_start_date;
			       collemptable(3).corrected_start_date :=
								      l_new_latest_start_date;
			       collemptable(3).value_flag := 'Y';
			    end if;
			 else
			    /* Code for Local Unit */
			    open csr_get_lu_scl(fnd_number.canonical_to_number(l_new_scl));
			    fetch csr_get_lu_scl into l_new_lu;
			    close csr_get_lu_scl;
			    open csr_get_lu_scl(fnd_number.canonical_to_number(l_old_scl));
			    fetch csr_get_lu_scl into l_old_lu;
			    close csr_get_lu_scl;

			    if l_old_lu <> l_new_lu
			    then
			       if l_detailed_output(cnt).effective_date > l_empl_start_date
			       then
				  l_lu_change_effective_date :=
							l_detailed_output(cnt).effective_date;
			       end if;

			       open csr_get_org_no(fnd_number.canonical_to_number(l_new_scl));
			       fetch csr_get_org_no into l_lu_org_no;
			       close csr_get_org_no;

			       if    l_emp_start_date <> l_detailed_output(cnt).effective_date
				  or l_corr_change_flag = 'C'
			       then
				  if l_corr_change_flag = 'M'
				  then
				     l_lu_change_flag := 'Y';                    /* 5519990 */
				     open csr_get_org_no(fnd_number.canonical_to_number(l_old_scl
										       )
							);
				     fetch csr_get_org_no into collemptable(2).old_lu_value;
				     close csr_get_org_no;
				     collemptable(2).lu_value := l_lu_org_no;
				     collemptable(2).lu_change_date :=
							 l_detailed_output(cnt).effective_date;
				     collemptable(2).value_flag := 'Y';
				  else
				     collemptable(3).lu_value := l_lu_org_no;
				     collemptable(3).lu_change_date :=
							l_detailed_output(cnt).effective_date;
				     collemptable(3).start_date := l_emp_start_date;
				     collemptable(3).value_flag := 'Y';
				  end if;
			       /*else 5511746
				  collemptable (1).lu_value := l_lu_org_no;*/
			       end if;
			    end if;

			    /* End Code for Local Unit */

			    /* Code for Position Code */
			    open csr_get_pos_scl(fnd_number.canonical_to_number(l_new_scl));
			    fetch csr_get_pos_scl into l_new_job_value;
			    close csr_get_pos_scl;
			    open csr_get_pos_scl(fnd_number.canonical_to_number(l_old_scl));
			    fetch csr_get_pos_scl into l_old_job_value;
			    close csr_get_pos_scl;

			    if l_new_job_value <> l_old_job_value
			    then
			       if l_detailed_output(cnt).effective_date > l_empl_start_date
			       then
				  l_job_change_effective_date :=
							l_detailed_output(cnt).effective_date;
			       end if;

			       if l_new_job_value <> '0'
			       then
				  l_job_value := l_new_job_value;
			       else
				  l_job_value := null;
			       end if;
			    end if;
			 /* End Code for Position Code */
			 end if;

			 if l_new_job_value <> '0' and l_new_job_value <> l_old_job_value
			 then
			    if    l_emp_start_date <> l_detailed_output(cnt).effective_date
			       or l_corr_change_flag = 'C'
			    then
			       if l_corr_change_flag = 'M'
			       then
				  l_job_value := l_new_job_value;
				  collemptable(2).job_id := l_job_value;
				  collemptable(2).job_change_date :=
							l_detailed_output(cnt).effective_date;
				  collemptable(2).value_flag := 'Y';
			       else
				  l_job_value := l_new_job_value;
				  collemptable(3).job_id := l_job_value;
				  collemptable(3).job_change_date :=
							l_detailed_output(cnt).effective_date;
				  collemptable(3).start_date := l_emp_start_date;
				  collemptable(3).value_flag := 'Y';
			       end if;
			    else
			       collemptable(1).job_id := l_new_job_value;
			    end if;
			 end if;

			 /* Code for Latest Start Date */
			 open csr_get_latest_st_date_scl(fnd_number.canonical_to_number(l_new_scl
										       )
							);
			 fetch csr_get_latest_st_date_scl into l_new_latest_start_date;
			 close csr_get_latest_st_date_scl;
			 open csr_get_latest_st_date_scl(fnd_number.canonical_to_number(l_old_scl
										       )
							);
			 fetch csr_get_latest_st_date_scl into l_old_latest_start_date;
			 close csr_get_latest_st_date_scl;

			 if l_new_latest_start_date <> l_old_latest_start_date
			 then
			    collemptable(3).start_date := l_emp_start_date;
			    collemptable(3).corrected_start_date := l_new_latest_start_date;
			    collemptable(3).value_flag := 'Y';
			 end if;
		      end if;

		      if l_old_scl <> '<null> '
		      then
			 /* Code for Latest Start Date */
			 open csr_get_latest_st_date_scl(fnd_number.canonical_to_number(l_new_scl
										       )
							);
			 fetch csr_get_latest_st_date_scl into l_new_latest_start_date;
			 close csr_get_latest_st_date_scl;
			 open csr_get_latest_st_date_scl(fnd_number.canonical_to_number(l_old_scl
										       )
							);
			 fetch csr_get_latest_st_date_scl into l_old_latest_start_date;
			 close csr_get_latest_st_date_scl;

			 if l_new_latest_start_date <> l_old_latest_start_date
			 then
			    collemptable(3).start_date := l_emp_start_date;
			    collemptable(3).corrected_start_date := l_new_latest_start_date;
			    collemptable(3).value_flag := 'Y';
			 end if;
		      end if;



                     elsif l_detailed_output (cnt).column_name =
                                                   'ASSIGNMENT_STATUS_TYPE_ID'
						   and
			     l_retrospective_date <> l_detailed_output (cnt).effective_date  then

                        open csr_get_assignment_status (
                           fnd_number.canonical_to_number (l_detailed_output (cnt).new_value)
                        );
                        fetch csr_get_assignment_status into l_user_status;
                        close csr_get_assignment_status;

                        if l_user_status = 'TERM_ASSIGN' then
--                                ('TERM_ASSIGN', 'SUSP_ASSIGN') then /* 5663543 */
                           l_emp_end_date :=
                                       l_detailed_output (cnt).effective_date;
		           if j.assignment_id <> l_detailed_output (cnt).assignment_id then


                        --
			   if  ( j.hourly_salaried_code = 'S'
                                or l_houry_change_flag = 'Y') then

                             l_hour_value := get_assignment_all_hours (
                                           l_detailed_output (cnt).assignment_id,
                                           j.person_id,
                                           l_detailed_output (cnt).effective_date,
                                           0,
                                           i.local_unit_id
                                        );
			   end if;

			      collemptable (2).working_hours := l_hour_value;
                              collemptable (2).hour_date_change :=
                                                 l_detailed_output (cnt).effective_date;
                              collemptable (2).value_flag := 'Y';

			   else
				   if l_corr_change_flag = 'M' then
				      collemptable (4).temination_date :=
								       l_emp_end_date - 1 ;
				      collemptable (4).value_flag := 'Y';
				   else
				      collemptable (3).temination_date :=
								       l_emp_end_date - 1 ;
				       collemptable (3).start_date := l_emp_start_date;
				      collemptable (3).value_flag := 'Y';
				   end if;
		           end if;
                        elsif l_user_status = 'ACTIVE_ASSIGN' then
                           l_emp_start_date :=
                                       l_detailed_output (cnt).effective_date;

                           if l_corr_change_flag = 'M' then
                              collemptable (1).start_date := l_emp_start_date;
                              collemptable (1).working_hours := l_hour_value;
                              l_curr_position := null;
                              open curr_position_code (l_detailed_output (cnt).assignment_id,
                                                       l_detailed_output (cnt).effective_date);
                              fetch curr_position_code into l_curr_position;
                              close curr_position_code;
                              collemptable (1).job_id := l_curr_position;
                           else
			      /* 5519276 */
                              collemptable (3).start_date := l_emp_start_date;
                              collemptable (3).corrected_start_date :=
                                                             l_emp_start_date;

                              collemptable (3).value_flag := 'Y';
                           end if;
                        end if;
                     elsif l_detailed_output(cnt).column_name ='EFFECTIVE_END_DATE'  and
			     l_retrospective_date <> l_detailed_output (cnt).effective_date
		       and l_detailed_output (cnt).dated_table_id = l_table3  then /* 5519729 and 5525683 */
                          l_emp_end_date := j.emp_end_date ;
                          l_eff_end_date_need := 'Y';
                          if l_detailed_output(cnt).effective_date <> trunc(hr_general.end_of_time) then
                             for cont in l_detailed_output.first .. l_detailed_output.last
                             loop
                               if l_detailed_output (cont).column_name = 'ASSIGNMENT_STATUS_TYPE_ID'
                               and l_detailed_output(cont).effective_date = (l_emp_end_date + 1) then
                                   l_eff_end_date_need := 'N';
                               end if;
                             end loop;
                          end if;
                          if l_eff_end_date_need = 'Y' then
                           if l_corr_change_flag = 'M' then
                              collemptable (4).temination_date := l_emp_end_date;
                              collemptable (4).value_flag := 'Y';
                           else
                              If l_emp_end_date is null or l_detailed_output(cnt).effective_date = trunc(hr_general.end_of_time) then
			        l_emp_end_date := null;
                                collemptable (3).rev_temination := '--------' ;
			      end if;
                              If l_detailed_output(cnt).effective_date < g_start_date then
                                collemptable (3).temination_date :=l_emp_end_date;
  			        collemptable (3).start_date := l_empl_start_date;
                                collemptable (3).value_flag := 'Y';
 			      else
  			        l_old_date := null ;
                                l_old_date :=substr (l_detailed_output (cnt).change_values,0,
                                             instr (l_detailed_output (cnt).change_values,'->')- 1 );
	                        if l_detailed_output(cnt).effective_date =  trunc(hr_general.end_of_time) and
				 l_old_date < g_start_date then
                                  collemptable (3).temination_date :=l_emp_end_date;
	                          collemptable (3).start_date := l_empl_start_date;
                                  collemptable (3).value_flag := 'Y';
	   		        end if;
			      end if;
                           end if;
                          end if;
                     end if;
                  --l_hour_value := 6;

                  /*    if     l_empl_start_date = l_emp_start_date
                       and nvl (l_hour_value, 0) = 0 then
                       l_emp_start_date := null;
                    end if;*/


               /*    if l_empl_start_date = l_emp_start_date  and nvl(l_hour_value,0) = 0
         then
         l_emp_start_date := null;
         end if;*/

               l_curr_hours      := 0;
               l_curr_frequency  := null;
               if (l_hour_year_change_flag = 'N' and j.hourly_salaried_code = 'S' ) or
	          (l_hour_year_change_flag = 'N' and j.hourly_salaried_code = 'H' and l_houry_change_flag = 'Y' ) then
                  open curr_hours_frequency (l_detailed_output(cnt).assignment_id,l_detailed_output(cnt).effective_date);
                  fetch curr_hours_frequency into l_curr_hours,l_curr_frequency;
                  close curr_hours_frequency;

/*                  l_hour_value := find_total_hour (
                                     l_curr_hours,
                                     l_curr_frequency
                                  );*/


                     l_hour_value := get_assignment_all_hours (
                                     l_detailed_output (cnt).assignment_id,
                                     j.person_id,
                                     l_detailed_output (cnt).effective_date,
                                     l_curr_hours,
                                     i.local_unit_id );

		       if nvl (l_hour_value, 0) < g_min_avg_weekly_hours  and collemptable (4).value_flag = 'Y' then
			  collemptable (4).value_flag := 'N';
		       end if;

               end if;

               if nvl (l_hour_value, 0) < g_min_avg_weekly_hours then /* 5519990 */
                  collemptable (2).value_flag := 'N';
                  collemptable (3).value_flag := 'N';
	       end if;

               open curr_lu_org_number  (l_detailed_output (cnt).assignment_id,l_detailed_output(cnt).effective_date);
               fetch curr_lu_org_number  into l_local_unit_org_no;
               close curr_lu_org_number ;

        if  cnt + 1 > l_detailed_output.count or
           (cnt + 1 <= l_detailed_output.count and
           l_detailed_output(cnt).effective_date <> l_detailed_output(cnt + 1).effective_date )
           then


               for cnt in collemptable.first .. collemptable.last
               loop
                  if collemptable (cnt).value_flag = 'Y' then
                     --     end loop;
                     select pay_assignment_actions_s.nextval
                       into l_assact_id
                       from dual;

                     hr_nonrun_asact.insact (
                        l_assact_id,
                        j.assignment_id,
                        p_payroll_action_id,
                        20, --P_chunk,
                        null
                     ); --

--		     l_local_unit_org_no := i.local_unit_org_no;
		     if cnt = 2 and l_lu_change_flag = 'Y' then /* 5519990 */
		       l_local_unit_org_no := collemptable (cnt).old_lu_value;
		     end if;

                     if    (    cnt = 1
                            and collemptable (1).working_hours is not null
                            and collemptable (1).job_id is not null
   			    and collemptable (1).job_id <> '0'
                           )
                        or (cnt <> 1) then
                           pay_action_information_api.create_action_information (
                           p_action_information_id            => l_action_info_id,
                           p_action_context_id                => l_assact_id,
                           p_action_context_type              => 'AAP',
                           p_object_version_number            => l_ovn,
                           p_effective_date                   => g_effective_date,
                           p_source_id                        => null,
                           p_source_text                      => null,
                           p_action_information_category      => 'EMEA REPORT INFORMATION',
                           p_action_information1              => 'PYNOEERCNT',
                           p_action_information2              => g_business_group_id -- Business Group id
                           ,
                           p_action_information3              => g_legal_employer_id -- Legal Employer Org ID
                           ,
                           p_action_information4              => g_legal_employer_org_no -- Legal Employer Org ID
                           ,
                           p_action_information5              => i.local_unit_id,
                           p_action_information6              => l_local_unit_org_no, /* 5519990 */
                           p_action_information7              => j.person_id -- Person id
                           ,
                           p_action_information8              => j.national_identifier -- National Identifier
                           ,
                           p_action_information9              => j.full_name -- Full Name
                           ,
                           p_action_information10             => j.employee_number -- Employee Number
                           ,
                           p_action_information11             => fnd_date.date_to_canonical(collemptable (
                                                                    cnt
                                                                 ).start_date) -- Employment Start Date
                           --,p_action_information16         => p_time_period_id
                           ,
                           p_action_information12             =>fnd_number.number_to_canonical(collemptable (
                                                                    cnt
                                                                 ).working_hours) -- Weekly Working Hours
                           ,
                           p_action_information13             => fnd_date.date_to_canonical(collemptable (
                                                                    cnt
                                                                 ).hour_date_change) -- Date of change of hours
                           ,
                           p_action_information14             => fnd_date.date_to_canonical(collemptable (
                                                                    cnt
                                                                 ).temination_date) -- Employment Termination Date
                           ,
                           p_action_information15             => collemptable (
                                                                    cnt
                                                                 ).lu_value -- Local Unit Org No
                           ,
                           p_action_information16             => fnd_date.date_to_canonical(collemptable (
                                                                    cnt
                                                                 ).lu_change_date) -- Local Unit Change Date
                           ,
                           p_action_information17             => collemptable (
                                                                    cnt
                                                                 ).job_id -- Occupation
                           ,
                           p_action_information18             =>fnd_date.date_to_canonical( collemptable (
                                                                    cnt
                                                                 ).job_change_date) -- Occupation change date
                           ,
                           p_action_information19             => fnd_date.date_to_canonical(l_abs_start_date) -- Occupation change date
                           ,
                           p_action_information20             => fnd_date.date_to_canonical(l_abs_end_date),
                           p_action_information21             => collemptable (
                                                                    cnt
                                                                 ).status_type,
                           p_action_information22             => fnd_date.date_to_canonical(collemptable (
                                                                    cnt
                                                                 ).corrected_start_date),
                           p_action_information23             => collemptable (cnt).rev_temination,
                           p_assignment_id                    => j.assignment_id
                        );                     end if;
                  end if;
               end loop;

        for i in 1 .. 5
        loop
         collemptable (i).value_flag := null;
         collemptable (i).start_date := null;
         collemptable (i).end_date := null;
         collemptable (i).working_hours := null;
         collemptable (i).corrected_start_date := null;
         collemptable (i).hour_date_change := null;
         collemptable (i).temination_date := null;
         collemptable (i).lu_change_date := null;
         collemptable (i).lu_value := null;
         collemptable (i).job_id := null;
         collemptable (i).job_change_date := null;
         collemptable (i).old_lu_value := null;
         collemptable (i).rev_temination := null;
	 collemptable (i).corrected_start_date  := null;
        end loop;
       /* Initialize the variables */
       l_lu_org_no := i.local_unit_org_no;
       l_local_unit_value := null;
       l_lu_change_effective_date := null;
       l_lu_change_effective_date1 := null;
       l_job_change_effective_date := null;
       l_job_change_effective_date1 := null;
--     l_hour_element_entry_id := null;
       l_hour_year_change_flag := 'N';
       l_hour_value := null;
       l_hour_change_effective_date := null;
       l_hour_value_reported := null;
--     l_element_entry_id := null;
--     l_houry_change_flag := 'N';
       l_sickness_unpaid_end := null;
       l_sickness_unpaid_start := null;
--     l_empl_start_date := null;
       l_emp_start_date := null;
       l_emp_end_date := null;
       l_abs_start_date := null;
       l_abs_end_date := null;
       l_job_value := j.position_code;
--     l_prev_hour_flag := 'Y';
       l_corr_change_flag := 'M'; -- C for correction , M for Change
       l_hour_old_value := null;
       l_prev_hour_value_primary := null;
       l_prev_hour_eff_date := null;
       l_lu_change_flag := 'N';
       l_new_latest_start_date := null;

       /* Get the Start Date */
       open csr_start_date (j.assignment_id);
       fetch csr_start_date into l_emp_start_date;
       close csr_start_date;
       l_empl_start_date := l_emp_start_date;
       l_emp_end_date := j.effective_end_date;
    end if;
                  end loop;                      /* End loop for Column Check */
               end if;                         /* count check */
	       end if;                         /* End if for NI check */
            end loop;                         /* End loop for Employee Details*/
         end loop;                                /* End loop for Local Units */
      end if;                                           /* End if for Archive */
   end assignment_action_code;
   /* INITIALIZATION CODE */
   procedure initialization_code (
      p_payroll_action_id   in   number
   ) is
   begin
      fnd_file.put_line (fnd_file.log, 'Entering Initialization Code');
   end initialization_code;
   /* ARCHIVE CODE */
   procedure archive_code (
      p_assignment_action_id   in   number,
      p_effective_date         in   date
   ) is
   begin
      fnd_file.put_line (fnd_file.log, 'entering archive code');
   end archive_code;

   function find_total_hour (
      p_hours       in   number,
      p_frequency   in   varchar2
   )
      return number is
      p_total_hours   number := 0;
   begin
      if p_frequency = 'W' then
         p_total_hours := p_hours;
      elsif p_frequency = 'D' then
         p_total_hours := round (p_hours * 5, 2);
      elsif p_frequency = 'M' then
         p_total_hours := round (p_hours * 12 / 52, 2);
      elsif p_frequency = 'Y' then
         p_total_hours := round (p_hours / 52, 2);
      end if;

      return p_total_hours;
   end;

   function get_assignment_all_hours (
      p_assignment_id        in   per_all_assignments_f.assignment_id%type,
      p_person_id            in   per_all_people_f.person_id%type,
      p_effective_date       in   date,
      p_primary_hour_value        number,
      p_local_unit                number
   )
      return number is
      cursor csr_hour_frequency (
         p_assignment_id    per_all_assignments_f.assignment_id%type,
         p_effective_date   date
      ) is
         select frequency
           from per_all_assignments_f
          where assignment_id = p_assignment_id
            and p_effective_date between effective_start_date
                                     and effective_end_date;

      cursor csr_all_assignments_hours (
         p_person_id        per_all_people_f.person_id%type,
         p_assignment_id    per_all_assignments_f.assignment_id%type,
         p_effective_date   date,
         p_local_unit       number
      ) is
         select normal_hours, frequency
           from per_all_assignments_f paaf, hr_soft_coding_keyflex hsc
          where paaf.person_id = p_person_id
            and paaf.assignment_id <> p_assignment_id
            and paaf.normal_hours is not null
            and hsc.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
            and hsc.segment2 = to_char (p_local_unit)
            and hourly_salaried_code = 'S'
            and p_effective_date between paaf.effective_start_date
                                     and paaf.effective_end_date;
      l_frequency         per_all_assignments_f.frequency%type;
      l_total_hours       number                                 := 0;
      l_total_hours_all   number                                 := 0;
   begin
      open csr_hour_frequency (p_assignment_id, p_effective_date);
      fetch csr_hour_frequency into l_frequency;
      close csr_hour_frequency;
      l_total_hours := find_total_hour (p_primary_hour_value, l_frequency);
      l_total_hours_all := l_total_hours;

      for m in csr_all_assignments_hours (
                  p_person_id,
                  p_assignment_id,
                  p_effective_date,
                  p_local_unit
               )
      loop
         l_total_hours_all := l_total_hours_all
                              + find_total_hour (m.normal_hours, m.frequency);
      end loop;

      return l_total_hours_all;
   end;

--------------------------------------------------------------------------------
-- COPY
--------------------------------------------------------------------------------
   procedure copy (
      p_copy_from   in out nocopy   pay_interpreter_pkg.t_detailed_output_table_type,
      p_from        in              number,
      p_copy_to     in out nocopy   pay_interpreter_pkg.t_detailed_output_table_type,
      p_to          in              number
   ) is
   begin
      --
      p_copy_to (p_to).dated_table_id := p_copy_from (p_from).dated_table_id;
      p_copy_to (p_to).datetracked_event :=
                                       p_copy_from (p_from).datetracked_event;
      p_copy_to (p_to).surrogate_key := p_copy_from (p_from).surrogate_key;
      p_copy_to (p_to).update_type := p_copy_from (p_from).update_type;
      p_copy_to (p_to).column_name := p_copy_from (p_from).column_name;
      p_copy_to (p_to).effective_date := p_copy_from (p_from).effective_date;
      p_copy_to (p_to).old_value := p_copy_from (p_from).old_value;
      p_copy_to (p_to).new_value := p_copy_from (p_from).new_value;
      p_copy_to (p_to).change_values := p_copy_from (p_from).change_values;
      p_copy_to (p_to).proration_type := p_copy_from (p_from).proration_type;
      p_copy_to (p_to).change_mode := p_copy_from (p_from).change_mode;
      p_copy_to (p_to).creation_date := p_copy_from (p_from).creation_date;
      p_copy_to (p_to).element_entry_id :=
                                        p_copy_from (p_from).element_entry_id;
   --
   end copy;

--
--------------------------------------------------------------------------------
-- SORT_CHANGES
--------------------------------------------------------------------------------
   procedure sort_changes (
      p_detail_tab   in out nocopy   pay_interpreter_pkg.t_detailed_output_table_type
   ) is
      --
      l_temp_table   pay_interpreter_pkg.t_detailed_output_table_type;
   --**x NUMBER;
   --
   begin
      if p_detail_tab.count > 0 then
         for i in p_detail_tab.first .. p_detail_tab.last
         loop
            --x :=  i + 1;
            for j in i + 1 .. p_detail_tab.last
            loop
               if p_detail_tab (j).effective_date <
                                              p_detail_tab (i).effective_date then
                  copy (p_detail_tab, j, l_temp_table, 1);
                  copy (p_detail_tab, i, p_detail_tab, j);
                  copy (l_temp_table, 1, p_detail_tab, i);
               end if;
            end loop;
         end loop;
      end if;
   --

   --
   end sort_changes;
   --


--
--------------------------------------------------------------------------------

   procedure populate_details (
      p_business_group_id   in              number,
      p_payroll_action_id   in              varchar2,
      p_template_name       in              varchar2,
      p_xml                 out nocopy      clob
   ) is
      --
      --
      /* Cursor to fetch Header Information */
      cursor csr_get_hdr_info (
         p_payroll_action_id   number
      ) is
         select action_information1, action_information2 business_group_id,
                action_information3
                      legal_employer_id,
                action_information4
                      legal_employer_name,
                action_information5
                      legal_employer_org_no,
                action_information6 local_unit_id,
                action_information7
                      local_unit_name,
                action_information8 local_unit_org_no, effective_date
           from pay_action_information pai
          where action_context_type = 'PA'
            and action_context_id = p_payroll_action_id
            and action_information_category = 'EMEA REPORT INFORMATION'
            and action_information1 = 'PYNOEERCNT';

      --
      --
      /* Cursor to fetch Detail Information */
      --
      --
      cursor csr_get_detail_info (
         p_payroll_action_id   varchar2,
         p_legal_employer      varchar2,
         p_local_unit_id       varchar2
      ) is
         select action_information2, action_information3, action_information4,
                action_information5, action_information6, action_information7,
                action_information8, action_information9, action_information10,
                fnd_date.canonical_to_date(action_information11) action_information11,
		fnd_number.canonical_to_number(action_information12) action_information12,
                fnd_date.canonical_to_date(action_information13) action_information13,
		fnd_date.canonical_to_date(action_information14) action_information14,
                action_information15,
		fnd_date.canonical_to_date(action_information16) action_information16,
                action_information17,
		fnd_date.canonical_to_date(action_information18) action_information18,
                fnd_date.canonical_to_date(action_information19) action_information19,
		fnd_date.canonical_to_date(action_information20) action_information20,
                action_information21,
		fnd_date.canonical_to_date(action_information22) action_information22,
		action_information23
           from pay_payroll_actions paa,
                pay_assignment_actions assg,
                pay_action_information pai
          where paa.payroll_action_id = p_payroll_action_id
            and assg.payroll_action_id = paa.payroll_action_id
            and pai.action_context_id = assg.assignment_action_id
            and pai.action_context_type = 'AAP'
            and pai.action_information_category = 'EMEA REPORT INFORMATION'
            and pai.action_information1 = 'PYNOEERCNT'
            and pai.action_information3 = p_legal_employer
            and pai.action_information5 = p_local_unit_id
	     order by action_context_id;
--
--
 cursor cst_get_emp_count(
         p_payroll_action_id   varchar2,
         p_legal_employer      varchar2,
         p_local_unit_id       varchar2
      ) is
select count(*)
from pay_payroll_actions paa,
                pay_assignment_actions assg,
                pay_action_information pai
          where paa.payroll_action_id = p_payroll_action_id
            and assg.payroll_action_id = paa.payroll_action_id
            and pai.action_context_id = assg.assignment_action_id
            and pai.action_context_type = 'AAP'
            and pai.action_information_category = 'EMEA REPORT INFORMATION'
            and pai.action_information1 = 'PYNOEERCNT'
            and pai.action_information3 = p_legal_employer
            and pai.action_information5 = p_local_unit_id;
      --
      --
      l_counter             number        := 0;
      l_count               number        := 0;
      l_payroll_action_id   number;
      l_prev_cost_seg       varchar2 (80) := ' ';
      l_prev_eoy_code       varchar2 (80) := ' ';
      l_total_cost_credit   number        := 0;
      l_total_cost_debit    number        := 0;
      xml_ctr               number;
      l_legal_employer      number;
      l_value_flag          char(1) := 'Y';
      l_total_count               number ;
   begin
      if p_payroll_action_id is null then
         begin
            select payroll_action_id
              into l_payroll_action_id
              from pay_payroll_actions ppa,
                   fnd_conc_req_summary_v fcrs,
                   fnd_conc_req_summary_v fcrs1
             where fcrs.request_id = fnd_global.conc_request_id
               and fcrs.priority_request_id = fcrs1.priority_request_id
               and ppa.request_id between fcrs1.request_id and fcrs.request_id
               and ppa.request_id = fcrs1.request_id;
         exception
            when others then
               null;
         end;
      else
         l_payroll_action_id := p_payroll_action_id;
      end if;

      --   l_payroll_action_id := 120690;
      for i in csr_get_hdr_info (l_payroll_action_id)
      loop
      l_total_count := 0;
         open cst_get_emp_count (
                     to_char (l_payroll_action_id),
                     i.legal_employer_id,
                     i.local_unit_id
                  );
         fetch cst_get_emp_count into l_total_count;
         close cst_get_emp_count;
	 --
	 --
         if l_total_count > 0 then
	 --
	 --

         xml_tab (l_counter).tagname := 'LEGAL_EMPLOYER_NAME';
         xml_tab (l_counter).tagvalue := i.legal_employer_name;
         l_counter := l_counter + 1;

         --
         xml_tab (l_counter).tagname := 'LEGAL_EMPLOYER_ORG_NO';
         xml_tab (l_counter).tagvalue := i.legal_employer_org_no;
         l_counter := l_counter + 1;
	 --
         xml_tab (l_counter).tagname := 'EFFECTIVE_DATE';
         xml_tab (l_counter).tagvalue := i.effective_date;
         l_counter := l_counter + 1;
	 --
         xml_tab (l_counter).tagname := 'LU_ORG_NO';
         xml_tab (l_counter).tagvalue := i.local_unit_org_no;
         l_counter := l_counter + 1;
         --
         for j in csr_get_detail_info (
                     to_char (l_payroll_action_id),
                     i.legal_employer_id,
                     i.local_unit_id
                  )
         loop

	    IF j.action_information21 not in ('8K', '8F')  then -- Bug#9529805 fix

	    /* Counter to count records fetched */
            l_count := l_count + 1;
            xml_tab (l_counter).tagname := 'EMPLOYEE_NUMBER';
            xml_tab (l_counter).tagvalue := j.action_information10;
            l_counter := l_counter + 1;
	    --
            xml_tab (l_counter).tagname := 'LEGAL_EMPL_ORG_NO';
            xml_tab (l_counter).tagvalue := i.legal_employer_org_no;
            l_counter := l_counter + 1;
	    --
            xml_tab (l_counter).tagname := 'LU_ORG_NUMBER';
--            xml_tab (l_counter).tagvalue := i.local_unit_org_no;
            xml_tab (l_counter).tagvalue := j.action_information6; /* 5519990 */
            l_counter := l_counter + 1;
            --
            xml_tab (l_counter).tagname := 'STATEMENT_TYPE';
            xml_tab (l_counter).tagvalue := j.action_information21;
            l_counter := l_counter + 1;
	    --
            xml_tab (l_counter).tagname := 'EFFECTIVE_DT';
            xml_tab (l_counter).tagvalue := i.effective_date;
            l_counter := l_counter + 1;
	    --
            xml_tab (l_counter).tagname := 'EFFECTIVE_E_DT';
            xml_tab (l_counter).tagvalue :=
                                        to_char (i.effective_date, 'DDMMRRRR');
            l_counter := l_counter + 1;
	    --
            xml_tab (l_counter).tagname := 'EFFECTIVE_TIME';
            xml_tab (l_counter).tagvalue :=
                                          to_char (i.effective_date, 'HHMISS');
            l_counter := l_counter + 1;
	    --
            xml_tab (l_counter).tagname := 'FULL_NAME';
            xml_tab (l_counter).tagvalue := j.action_information9;
            l_counter := l_counter + 1;
	    --
            xml_tab (l_counter).tagname := 'NI_NUMBER';
            xml_tab (l_counter).tagvalue := j.action_information8;
            l_counter := l_counter + 1;
	    --
            xml_tab (l_counter).tagname := 'NI_E_NUMBER';
            xml_tab (l_counter).tagvalue :=
               substr (
                  j.action_information8,
                  1,
                  instr (j.action_information8, '-') - 1
               )
               || substr (
                     j.action_information8,
                     instr (j.action_information8, '-') + 1
                  );
            l_counter := l_counter + 1;
	    --
	    IF j.action_information21 = '8I'  then -- Bug#9529805 fix
            xml_tab (l_counter).tagname := 'EMP_START_DATE';
            xml_tab (l_counter).tagvalue := j.action_information11;
            l_counter := l_counter + 1;
	    --
            xml_tab (l_counter).tagname := 'EMP_START_E_DATE';
            xml_tab (l_counter).tagvalue :=
               to_char (
                  j.action_information11,
                  'DDMMRRRR'
               );
            l_counter := l_counter + 1;
	    END IF;    -- Bug#9529805 fix
	    --
            xml_tab (l_counter).tagname := 'WORKING_HOURS';
            xml_tab (l_counter).tagvalue := round(j.action_information12);
            l_counter := l_counter + 1;
	    --
            xml_tab (l_counter).tagname := 'HOUR_CHANGE_DATE';
            xml_tab (l_counter).tagvalue := j.action_information13;
            l_counter := l_counter + 1;
	    --
            xml_tab (l_counter).tagname := 'HOUR_CHANGE_E_DATE';
            xml_tab (l_counter).tagvalue :=
               to_char (
                  j.action_information13,
                  'DDMMRRRR'
               );
            l_counter := l_counter + 1;
	    --
            xml_tab (l_counter).tagname := 'EMP_END_DATE';
            xml_tab (l_counter).tagvalue := j.action_information14;
            l_counter := l_counter + 1;
	    --
            xml_tab (l_counter).tagname := 'EMP_END_E_DATE';
	    If j.action_information14 is null and j.action_information23 = '--------' then
               xml_tab (l_counter).tagvalue := '--------' ;
	    else
               xml_tab (l_counter).tagvalue :=
               to_char (
                  j.action_information14,
                  'DDMMRRRR'
               );
            end if;
            l_counter := l_counter + 1;
	    --
            xml_tab (l_counter).tagname := 'LU_ORG_NUM';
            xml_tab (l_counter).tagvalue := j.action_information15;
            l_counter := l_counter + 1;
	    --
            xml_tab (l_counter).tagname := 'LU_CHANGE_DATE';
            xml_tab (l_counter).tagvalue := j.action_information16;
            l_counter := l_counter + 1;
	    --
            xml_tab (l_counter).tagname := 'LU_CHANGE_E_DATE';
            xml_tab (l_counter).tagvalue :=
               to_char (
                 j.action_information16,
                  'DDMMRRRR'
               );
            l_counter := l_counter + 1;
	    --
            xml_tab (l_counter).tagname := 'STATEMENT_TYPE';
            xml_tab (l_counter).tagvalue := j.action_information21;
            l_counter := l_counter + 1;
	    --
            xml_tab (l_counter).tagname := 'EMP_COR_START_DAT';
            xml_tab (l_counter).tagvalue :=
               to_char (
                 j.action_information22,
                  'DDMMRRRR'
               );
            l_counter := l_counter + 1;

	    xml_tab (l_counter).tagname := 'EMP_CORR_START_DATE';
            xml_tab (l_counter).tagvalue := j.action_information22;
            l_counter := l_counter + 1;

	    --
	    if j.action_information17 = '0' then
	       j.action_information17 := null;
	    end if;
            xml_tab (l_counter).tagname := 'JOB_CODE';
            xml_tab (l_counter).tagvalue := j.action_information17;
            l_counter := l_counter + 1;
	    --
            xml_tab (l_counter).tagname := 'JOB_CHANGE_E_DATE';
            xml_tab (l_counter).tagvalue :=
               to_char (
                 j.action_information18,
                  'DDMMRRRR'
               );
            l_counter := l_counter + 1;
	    --
            xml_tab (l_counter).tagname := 'JOB_CHANGE_DATE';
            xml_tab (l_counter).tagvalue := j.action_information18;
            l_counter := l_counter + 1;
	    --
	    end if; -- Bug#9529805 fix
         end loop;
        end if;
      end loop;

      writetoclob (p_xml);
--      fnd_file.put_line (fnd_file.log, 'Entering ');
--      fnd_file.put_line (fnd_file.log,   p_xml);

   end populate_details;



   procedure writetoclob (
      p_xfdf_clob   out nocopy   clob
   ) is
      l_xfdf_string    clob;
      l_str1           varchar2 (1000);
      l_str2           varchar2 (20);
      l_str3           varchar2 (20);
      l_str4           varchar2 (20);
      l_str5           varchar2 (20);
      l_str6           varchar2 (30);
      l_str7           varchar2 (1000);
      l_str8           varchar2 (240);
      l_str9           varchar2 (240);
      l_str10          varchar2 (20);
      l_str11          varchar2 (20);
      l_str12          varchar2 (30);
      l_str13          varchar2 (30);
      l_str14          varchar2 (30);
      l_str15          varchar2 (30);
      l_str16          varchar2 (30);
      l_str17          varchar2 (30);
      l_iana_charset   varchar2 (50);
      current_index    pls_integer;
   begin
      l_iana_charset := hr_no_utility.get_iana_charset;
      l_str1 := '<?xml version="1.0" encoding="' || l_iana_charset
                || '"?> <ROOT><PAACR>';
      l_str2 := '<';
      l_str3 := '>';
      l_str4 := '</';
      l_str5 := '>';
      l_str6 := '</PAACR></ROOT>';
      l_str7 := '<?xml version="1.0" encoding="' || l_iana_charset
                || '"?> <ROOT></ROOT>';
      l_str10 := '<PAACR>';
      l_str11 := '</PAACR>';
      l_str12 := '<FILE_HEADER_START>';
      l_str13 := '</FILE_HEADER_START>';
      l_str14 := '<Fields>';
      l_str15 := '</Fields>';
      l_str16 := '<EMP_RECORD>';
      l_str17 := '</EMP_RECORD>';
      dbms_lob.createtemporary (l_xfdf_string, false , dbms_lob.call);
      dbms_lob.open (l_xfdf_string, dbms_lob.lob_readwrite);
      current_index := 0;

      if xml_tab.count > 0 then
         dbms_lob.writeappend (l_xfdf_string, length (l_str1), l_str1);
         dbms_lob.writeappend (l_xfdf_string, length (l_str12), l_str12);

         for table_counter in xml_tab.first .. xml_tab.last
         loop
            l_str8 := xml_tab (table_counter).tagname;
            l_str9 := xml_tab (table_counter).tagvalue;

            if l_str8 = 'LEGAL_EMPLOYER_NAME' then
               dbms_lob.writeappend (
                  l_xfdf_string,
                  length (l_str14),
                  l_str14
               );
            elsif l_str8 = 'EMPLOYEE_NUMBER' then
               dbms_lob.writeappend (
                  l_xfdf_string,
                  length (l_str16),
                  l_str16
               );
            end if;

            if l_str9 is not null then
               dbms_lob.writeappend (l_xfdf_string, length (l_str2), l_str2);
               dbms_lob.writeappend (l_xfdf_string, length (l_str8), l_str8);
               dbms_lob.writeappend (l_xfdf_string, length (l_str3), l_str3);
               dbms_lob.writeappend (l_xfdf_string, length (l_str9), l_str9);
               dbms_lob.writeappend (l_xfdf_string, length (l_str4), l_str4);
               dbms_lob.writeappend (l_xfdf_string, length (l_str8), l_str8);
               dbms_lob.writeappend (l_xfdf_string, length (l_str5), l_str5);
            else
               dbms_lob.writeappend (l_xfdf_string, length (l_str2), l_str2);
               dbms_lob.writeappend (l_xfdf_string, length (l_str8), l_str8);
               dbms_lob.writeappend (l_xfdf_string, length (l_str3), l_str3);
               dbms_lob.writeappend (l_xfdf_string, length (l_str4), l_str4);
               dbms_lob.writeappend (l_xfdf_string, length (l_str8), l_str8);
               dbms_lob.writeappend (l_xfdf_string, length (l_str5), l_str5);
            end if;

            if l_str8 = 'JOB_CHANGE_DATE' then
               dbms_lob.writeappend (
                  l_xfdf_string,
                  length (l_str17),
                  l_str17
               );

               if    xml_tab.last = table_counter
                  or xml_tab (table_counter + 1).tagname <> 'EMPLOYEE_NUMBER' then
                  dbms_lob.writeappend (
                     l_xfdf_string,
                     length (l_str15),
                     l_str15
                  );
               end if;
            end if;
         end loop;

         dbms_lob.writeappend (l_xfdf_string, length (l_str13), l_str13);
         dbms_lob.writeappend (l_xfdf_string, length (l_str6), l_str6);
      else
         dbms_lob.writeappend (l_xfdf_string, length (l_str7), l_str7);
      end if;

      p_xfdf_clob := l_xfdf_string;
      hr_utility.set_location ('Leaving WritetoCLOB ', 20);
   exception
      when others then
         hr_utility.trace ('sqlerrm ' || sqlerrm || 'SQLCode :- ' || sqlcode);
         hr_utility.raise_error;
   end writetoclob;

   /* NI check function -5526181*/
 function check_national_identifier (
      p_national_identifier   varchar2
   )
      return varchar2 is
      l_return_value   per_all_people_f.national_identifier%type;
      l_check_value    number;
      d1               number;
      d2               number;
      m1               number;
      m2               number;
      y1               number;
      y2               number;
      i1               number;
      i2               number;
      i3               number;
      c1               number;
      c2               number;
      v1               number;
      v2               number;
      l_remainder      number;
      l_check          number;
   begin
      l_return_value := hr_ni_chk_pkg.chk_nat_id_format (
                           p_national_identifier,
                           'DDDDDD-DDDDD'
                        );

      if l_return_value <> '0' then
         l_check_value := hr_no_utility.chk_valid_date (l_return_value);

         if l_check_value <> 0 then
            /* Valid Birthdate */
            d1 := fnd_number.canonical_to_number (substr (l_return_value, 1, 1));
            d2 := fnd_number.canonical_to_number (substr (l_return_value, 2, 1));
            m1 := fnd_number.canonical_to_number (substr (l_return_value, 3, 1));
            m2 := fnd_number.canonical_to_number (substr (l_return_value, 4, 1));
            y1 := fnd_number.canonical_to_number (substr (l_return_value, 5, 1));
            y2 := fnd_number.canonical_to_number (substr (l_return_value, 6, 1));
            i1 := fnd_number.canonical_to_number (substr (l_return_value, 8, 1));
            i2 := fnd_number.canonical_to_number (substr (l_return_value, 9, 1));
            i3 := fnd_number.canonical_to_number (substr (l_return_value, 10, 1));
            c1 := fnd_number.canonical_to_number (substr (l_return_value, 11, 1));
            c2 := fnd_number.canonical_to_number (substr (l_return_value, 12, 1));
            v1 := 3 * d1 + 7 * d2 + 6 * m1 + m2 + 8 * y1 + 9 * y2 + 4 * i1 + 5 * i2 + 2 * i3;


            l_remainder := mod (v1, 11);

            if l_remainder = 0 then
               l_check := 0;
            else
               l_check := (11 - l_remainder);
            end if;

            if l_check <> c1 then
               l_return_value := 'INVALID_ID';
            else
               v2 := 5 * d1 + 4 * d2 + 3 * m1 + 2 * m2 + 7 * y1 + 6 * y2 + 5 * i1 + 4 * i2 + 3 * i3 + 2 * c1;

               l_remainder := mod (v2, 11);

               if l_remainder = 0 then
                  l_check := 0;
               else
                  l_check := (11 - l_remainder);
               end if;

               if l_check <> c2 then
                  l_return_value := 'INVALID_ID';
               end if;
            end if;
         else
            l_return_value := 'INVALID_ID';
         end if;
      else
         l_return_value := 'INVALID_ID';
      end if;

      return l_return_value;
   end;

end pay_no_eerr_continuous;

/
