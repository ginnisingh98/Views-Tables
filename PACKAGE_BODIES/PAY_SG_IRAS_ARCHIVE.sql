--------------------------------------------------------
--  DDL for Package Body PAY_SG_IRAS_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SG_IRAS_ARCHIVE" as
/* $Header: pysgirar.pkb 120.19.12010000.17 2009/02/11 04:55:00 jalin ship $ */
     -----------------------------------------------------------------------------
     -- These are PUBLIC procedures that are used within this package.
     -----------------------------------------------------------------------------
     g_debug  boolean ;
     g_business_group_id   varchar2(20) ;
     g_basis_end           date;
     g_basis_start         date;
     g_basis_year          varchar2(4);
     g_legal_entity_id     varchar2(20);
     g_person_id           per_all_people_f.person_id%type;
     g_assignment_set_id   hr_assignment_sets.assignment_set_id%type;
     g_setup_action_id     pay_payroll_actions.payroll_action_id%type;
     g_report_type         varchar2(30);
     g_previous_person_id  per_all_people_f.person_id%type;
     g_moa_369_date        ff_archive_items.value%type;
     -- Added for bug 5435088 org cursor only need to run once
     g_name_of_bank        ff_archive_items.value%type;
     g_org_run             char(1);
     g_org_a8a_run         char(1);
     g_iras_method         char(1); /* Bug 7415444 , Original or Amendment*/
     g_national_identifier per_all_people_f.national_identifier%type;
     g_legal_entity_name     hr_organization_information.org_information1%type;
     g_er_income_tax_number  hr_organization_information.org_information4%type;
     g_er_ohq_status         hr_organization_information.org_information12%type;
     g_er_iras_category      hr_organization_information.org_information13%type;
     g_er_telephone_no       hr_organization_information.org_information14%type;
     g_er_payer_id           hr_organization_information.org_information15%type;
     g_er_designation_type   hr_organization_information.org_information17%type;
     g_er_position_seg_type  hr_organization_information.org_information18%type;
     g_er_bonus_date         hr_organization_information.org_information8%type;
     g_er_incorp_date    hr_organization_information.org_information9%type;
     g_er_auth_person_email  hr_organization_information.org_information5%type;
     g_er_division           hr_organization_information.org_information8%type;
     g_er_payer_id_check   char(1);
     g_er_incorp_date_1  char(10); /* Bug 7415444 */
     g_er_incorp_date_2  char(10);
     l_counter             number;
     g_a8b_moa_348             number;
     --------------------------------------------------------------------------------------------------------
     -- Bug# 3501927 A8A Balance store rec
     --------------------------------------------------------------------------------------------------------
     type ytd_a8a_balance_store_rec is record
  	 ( balance_id              ff_user_entities.user_entity_id%type,
           balance_value           number );
     type ytd_a8a_balance_tab is table of ytd_a8a_balance_store_rec index by binary_integer;
     ytd_a8a_balance_rec     ytd_a8a_balance_tab;
     -- Bug# 3933332
     g_org_a8a_flag char(1);

     -----------------------------------------------------------------------------
     -- The SELECT statement in this procedure returns the Person Ids for
     -- Assignments that require the archive process to create an Assignment
     -- Action.
     -- Core Payroll recommends the select has minimal restrictions.
     -----------------------------------------------------------------------------
     procedure range_code
      ( p_payroll_action_id   in  pay_payroll_actions.payroll_action_id%type,
        p_sql                 out nocopy varchar2 )
     is
     begin
         if g_debug then
              hr_utility.set_location(' Start of range_code',1);
         end if;
         --
         p_sql := 'select distinct person_id '                            ||
                  'from   per_people_f ppf, '                             ||
                  'pay_payroll_actions ppa '                              ||
                  'where  ppa.payroll_action_id = :payroll_action_id '    ||
                  'and    ppa.business_group_id = ppf.business_group_id ' ||
                  'order by ppf.person_id';
         --
         if g_debug then
              hr_utility.set_location('End of range_code',2);
         end if;
     end range_code;
     ----------------------------------------------------------------------------
     -- Bug 3435334 - Pre-processor process now introduced for this archive.
     -- Assignment actions are created for all assignments processed by pre-processor
     ----------------------------------------------------------------------------
     procedure assignment_action_code
      ( p_payroll_action_id    in  pay_payroll_actions.payroll_action_id%type,
        p_start_person_id      in  per_all_people_f.person_id%type,
        p_end_person_id        in  per_all_people_f.person_id%type,
        p_chunk                in  number )
     is
         v_next_action_id   pay_assignment_actions.assignment_action_id%type;
         v_setup_action_id  pay_payroll_actions.payroll_action_id%type;
         v_assignment_id    per_all_assignments_f.assignment_id%type;
         --
         cursor  get_params(c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type) is
         select  pay_core_utils.get_parameter('SETUP_ACTION_ID',legislative_parameters)
         from    pay_payroll_actions
         where   payroll_action_id = c_payroll_Action_id;
         --
         cursor  next_action_id is
         select  pay_assignment_actions_s.nextval
         from    dual;
         --
         cursor  process_assignments ( c_setup_action_id in pay_payroll_actions.payroll_action_id%type ) is
         select  distinct pai.assignment_id
         from    pay_action_information pai
         where   pai.action_context_id           = c_setup_action_id
         and     pai.action_context_type         = 'AAP'
         and     pai.action_information_category = 'SG_IRAS_SETUP'
         and     action_information2 between p_start_person_id and p_end_person_id ;
     begin
         if g_debug then
              hr_utility.set_location('Start of assignment_action_code',3);
         end if;
         --
         open   get_params( p_payroll_action_id );
         fetch  get_params into v_setup_action_id;
         close  get_params;
         --
         open process_assignments( v_setup_action_id ) ;
         loop
              fetch process_assignments into v_assignment_id;
              exit when process_assignments%notfound;
              --
              if g_debug then
                   hr_utility.set_location('Before calling hr_nonrun_asact.insact',4);
              end if;
              --
              open  next_action_id ;
              fetch next_action_id into v_next_action_id;
              close next_action_id;
              --
              hr_nonrun_asact.insact( v_next_action_id,
                                      v_assignment_id,
                                      p_payroll_action_id,
                                      p_chunk,
                                      null );
              --
              if g_debug then
                   hr_utility.set_location('After calling hr_nonrun_asact.insact',4);
              end if;
         end loop;
         --
         close process_assignments;
         --
         if g_debug then
              hr_utility.set_location('End of assignment_action_code',5);
         end if;
     end assignment_action_code;
     ------------------------------------------------------------------------
     -- Bug 3435334 - Pre-processor process now introduced for this archive.
     -- Populating PL/SQL table logic with rehire query is removed
     ------------------------------------------------------------------------
     procedure initialization_code
      (  p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type )
     is
         cursor   get_params( c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type ) is
         select   pay_core_utils.get_parameter('BUSINESS_GROUP_ID',legislative_parameters),
                  to_date('01-01-'||pay_core_utils.get_parameter('BASIS_YEAR',legislative_parameters),'DD-MM-YYYY'),
                  to_date('31-12-'|| pay_core_utils.get_parameter('BASIS_YEAR',legislative_parameters),'DD-MM-YYYY'),
                  pay_core_utils.get_parameter('BASIS_YEAR',legislative_parameters),
                  pay_core_utils.get_parameter('LEGAL_ENTITY_ID',legislative_parameters),
                  pay_core_utils.get_parameter('SETUP_ACTION_ID',legislative_parameters),
                  report_type
         from     pay_payroll_actions
         where    payroll_action_id = c_payroll_action_id;
         ------------------------------------------------------------------------
         -- Bug 3933332  - Get A8A_Applicable flag
         ------------------------------------------------------------------------
         cursor   get_org_a8a_applicable
         is
         select   org_information19
         from     hr_organization_information,
                  pay_payroll_actions
         where    org_information_context    ='SG_LEGAL_ENTITY'
         and      organization_id            = pay_core_utils.get_parameter('LEGAL_ENTITY_ID',legislative_parameters)
         and      payroll_action_id          = p_payroll_action_id;
     begin
         if g_debug then
               hr_utility.set_location('pysgirar: Start of initialization_code',6);
         end if;
         --
         if g_business_group_id is null then
               open   get_params( p_payroll_action_id );
               fetch  get_params
               into   g_business_group_id,
                      g_basis_start,
                      g_basis_end,
                      g_basis_year,
                      g_legal_entity_id,
                      g_setup_action_id,
                      g_report_type ;
               close  get_params;
         end if;
         ------------------------------------------------------------------------
         -- Bug 3933332  - Get A8A_Applicable flag
         ------------------------------------------------------------------------
         if g_org_a8a_run <> 'Y' then
               open  get_org_a8a_applicable;
               fetch get_org_a8a_applicable into g_org_a8a_flag;
               close get_org_a8a_applicable;
               g_org_a8a_run := 'Y';
         end if;

         if g_debug then
               hr_utility.set_location('pysgirar: End of initialization_code',8);
         end if;
     end initialization_code;
     --------------------------------------------------------------------------------
     -- Bug: 3118540 - This function is called from SRS 'IR8S Ad Hoc Printed Archive'
     --------------------------------------------------------------------------------
     procedure assignment_action_code_adhoc
      ( p_payroll_action_id    in  pay_payroll_actions.payroll_action_id%type,
        p_start_person_id    in  per_all_people_f.person_id%type,
        p_end_person_id      in  per_all_people_f.person_id%type,
        p_chunk              in  number )
     is
         v_next_action_id  pay_assignment_actions.assignment_action_id%type;
         v_person_id           per_all_people_f.person_id%type;
         v_assignment_set_id	hr_assignment_sets.assignment_set_id%type;
         v_business_group_id   number;
         v_basis_start         date;
         v_basis_end           date;
         v_legal_entity_id     number;
         v_basis_year          number;
         v_asg_id              per_all_assignments_f.assignment_id%type;
         ----------------------------------------------------------------------------
         -- Cursor to get the values of archive parameters
         ----------------------------------------------------------------------------
         cursor  get_params(c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type) is
         select  pay_core_utils.get_parameter('PERSON_ID',legislative_parameters),
                 pay_core_utils.get_parameter('BUSINESS_GROUP_ID',legislative_parameters),
                 to_date('01-01-'||pay_core_utils.get_parameter('BASIS_YEAR',legislative_parameters),'DD-MM-YYYY'),
                 to_date('31-12-'|| pay_core_utils.get_parameter('BASIS_YEAR',legislative_parameters),'DD-MM-YYYY'),
                 pay_core_utils.get_parameter('LEGAL_ENTITY_ID',legislative_parameters),
                 pay_core_utils.get_parameter('BASIS_YEAR',legislative_parameters),
                 pay_core_utils.get_parameter('ASSIGNMENT_SET_ID',legislative_parameters)
         from    pay_payroll_actions
         where   payroll_action_id = c_payroll_action_id;
         ----------------------------------------------------------------------------
         -- Cursor Next Assignment Action
         ----------------------------------------------------------------------------
         cursor  next_action_id is
         select  pay_assignment_actions_s.nextval
         from    dual;
         ----------------------------------------------------------------------------
         -- Cursor Process_assignments
         -- Bug: 3404526 - Added max(assignment_id) to pick the latest assignment in case of Normal rehire.
         -- Bug#3614563  Removed the Business Group id check from inner query to imporove the performence.
         ----------------------------------------------------------------------------
         cursor process_assignments
           ( c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
             c_start_person_id    in per_all_people_f.person_id%type,
             c_end_person_id      in per_all_people_f.person_id%type,
             c_person_id          in per_all_people_f.person_id%type,
             c_assignment_set_id  in hr_assignment_sets.assignment_set_id%type,
             c_business_group_id  in number,
             c_legal_entity_id    in number,
             c_basis_start        in date,
             c_basis_end          in date) is
         select max(paf.assignment_id)
         from   per_assignments_f paf,
                pay_payroll_actions ppa1
         where  ppa1.payroll_action_id = c_payroll_action_id
         and    paf.person_id between c_start_person_id and c_end_person_id
         and    ppa1.business_group_id = paf.business_group_id
         and    paf.person_id = nvl(c_person_id,paf.person_id)
         and    paf.assignment_type = 'E' /* Bug 5033609 */
         and    decode(c_assignment_set_id,null,'Y',
                    decode(hr_assignment_set.ASSIGNMENT_IN_SET(c_assignment_set_id,paf.assignment_id),'Y','Y','N')) = 'Y'
         and    exists
                (  select  null
                   from    pay_payroll_actions ppa,
                           pay_assignment_actions paa
                   where   ppa.payroll_action_id  = paa.payroll_action_id
                   and     paa.assignment_id      = paf.assignment_id
                   and     paa.tax_unit_id        = c_legal_entity_id
                   and     ppa.effective_date     between c_basis_start and c_basis_end
                   and     ppa.action_type        in ('R','B','I','Q','V')
                   and     ppa.action_status      = 'C'
                   and     ppa.effective_date     between paf.effective_start_date and paf.effective_end_date )
         group by paf.person_id;

     begin
         if g_debug then
             hr_utility.set_location('pysgirar: Start of Assignemnt Action Code Adhoc', 20);
         end if;
         --
         open   get_params(p_payroll_action_id);
         fetch  get_params into  v_person_id,
                                 v_business_group_id,
                                 v_basis_start,
                                 v_basis_end,
                                 v_legal_entity_id,
                                 v_basis_year,
                                 v_assignment_set_id ;
         close  get_params;
         --
         open process_assignments( p_payroll_action_id,
                                   p_start_person_id,
                                   p_end_person_id,
                                   v_person_id,
                                   v_assignment_set_id,
                                   v_business_group_id,
                                   v_legal_entity_id,
                                   v_basis_start,
                                   v_basis_end );
         loop
              fetch process_assignments into v_asg_id;
              exit when process_assignments%NOTFOUND;
              --
              open   next_action_id;
              fetch  next_action_id into v_next_action_id;
              close  next_action_id;
              --
              hr_nonrun_asact.insact( v_next_action_id,
                                      v_asg_id,
                                      p_payroll_action_id,
                                      p_chunk,
                                      null  );
         end loop;
         close process_assignments;
         --
         if g_debug then
              hr_utility.set_location('pysgirar: End of Assignemnt Action Code Adhoc', 20);
         end if;
     exception
         when others then
              hr_utility.set_location('pysgirar: Error in assignment action code adhoc',10);
              raise;
     end assignment_action_code_adhoc;
     --------------------------------------------------------------------------------
     -- Bug: 3118540 - This function is called from SRS 'IR8S Ad Hoc Printed Archive'
     -- Bug 3435334 - Fetching report_type into g_report_type which helps to identify
     -- which process is running IR8S adhoc archive/main archive process
     --------------------------------------------------------------------------------
     procedure initialization_code_adhoc
      (  p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type )
     is
         cursor get_params( c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type ) is
         select   pay_core_utils.get_parameter('PERSON_ID',legislative_parameters),
                  pay_core_utils.get_parameter('BUSINESS_GROUP_ID',legislative_parameters),
                  to_date('01-01-'||pay_core_utils.get_parameter('BASIS_YEAR',legislative_parameters),'DD-MM-YYYY'),
                  to_date('31-12-'|| pay_core_utils.get_parameter('BASIS_YEAR',legislative_parameters),'DD-MM-YYYY'),
                  pay_core_utils.get_parameter('LEGAL_ENTITY_ID',legislative_parameters),
                  pay_core_utils.get_parameter('BASIS_YEAR',legislative_parameters),
                  pay_core_utils.get_parameter('ASSIGNMENT_SET_ID',legislative_parameters),
                  report_type
         from     pay_payroll_actions
         where    payroll_action_id = c_payroll_action_id;
         --
     begin
         if g_debug then
               hr_utility.set_location('pysgirar: Start of initialization_code',6);
         end if;
         ------------------------------------------------------------------------
         -- Cursor Get Params
         ------------------------------------------------------------------------
         if g_business_group_id is null then
              open   get_params( p_payroll_action_id );
              fetch  get_params
              into   g_person_id,
                     g_business_group_id,
                     g_basis_start,
                     g_basis_end,
                     g_legal_entity_id,
                     g_basis_year,
                     g_assignment_set_id,
                     g_report_type ;
              close  get_params;
         end if;
         --
         if g_debug then
              hr_utility.set_location('pysgirar: End of initialization_code',8);
         end if;
     end initialization_code_adhoc;
     -----------------------------------------------------------------------------------------------------
     -- Bug: 3118540 - This function is called from the report PYSG8SAD.rdf - 'IR8S Ad Hoc Printed Report'
     -----------------------------------------------------------------------------------------------------
     function get_archive_value
       ( p_user_entity_name      in  ff_user_entities.user_entity_name%type,
         p_assignment_action_id  in  pay_assignment_actions.assignment_action_id%type) return varchar2
     is
         cursor  csr_get_value( p_user_entity_name      varchar2,
                                 p_assignment_action_id  number ) is
         select  fai.value
         from    ff_archive_items fai,
                 ff_user_entities fue
         where   fai.context1         = p_assignment_action_id
         and     fai.user_entity_id   = fue.user_entity_id
         and     fue.user_entity_name = p_user_entity_name;
         --
         l_value            ff_archive_items.value%type;
         e_no_value_found   exception;
     begin
         open csr_get_value ( p_user_entity_name,
                              p_assignment_action_id );
         fetch  csr_get_value into l_value;
         --
         if  csr_get_value%notfound then
               l_value := null;
               close csr_get_value;
               raise e_no_value_found;
         else
               close csr_get_value;
         end if;
         --
         return(l_value);
     exception
         when e_no_value_found then
             If g_debug then
                  hr_utility.set_location('error in get archive value  - assignment_action_id:' ||p_assignment_action_id,3);
                  hr_utility.set_location('error in get archive value  - user entity name    :' ||p_user_entity_name,3);
             end if;
             return (null);
         when others then
             If g_debug then
                  hr_utility.set_location('error in get archive value  - assignment_action_id:' ||p_assignment_action_id,3);
                  hr_utility.set_location('error in get archive value  - user entity name    :' ||p_user_entity_name,3);
             end if;
             return (null);
     end get_archive_value;
     ------------------------------------------------------------------------
     -- Selects the SRS parameters for the archive and calls other procedures
     -- to archive the data in groups because depending on the data,
     -- different parameters are required.
     ------------------------------------------------------------------------
     procedure archive_code
      ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
        p_effective_date        in date )
     is
         v_person_id              per_all_people_f.person_id%type;
         v_assignment_id          per_all_assignments_f.assignment_id%type;
         v_national_identifier    varchar2(50);
         v_archive_date           pay_payroll_actions.effective_date%type;
         l_person_id              per_all_people_f.person_id%type;
         l_archived_person_id     binary_integer;

         ------------------------------------------------------------------------
         -- Bug 2920732 - Modified the cursor to use secured views  per_people_f, per_assignments_f
         -- Bug 3260855 - Modified the cusor to fetch only person_id, asg_id instead of
         -- legislative parameters as global values can be used, which are initialized in Init_code.
         ------------------------------------------------------------------------
         cursor  get_details( c_assignment_action_id  pay_assignment_actions.assignment_action_id%type ) is
         select  pap.person_id,
                 nvl(pap.national_identifier,pap.per_information12),
                 pac.assignment_id
         from    pay_assignment_actions pac,
                 per_assignments_f      paa,
                 per_people_f           pap
         where   pac.assignment_action_id = c_assignment_action_id
         and     paa.assignment_id        = pac.assignment_id
         and     paa.person_id            = pap.person_id ;

     begin
         if g_debug then
              hr_utility.set_location('pysgirar: Start of archive_code',10);
         end if;
         --

         open get_details ( p_assignment_action_id );
         fetch get_details into  v_person_id,
                                 v_national_identifier,
                                 v_assignment_id;
         --
         if get_details%found then
              close get_details;
              --
              if g_debug then
                   hr_utility.set_location('pysgirar: Person Id: ' || to_char(v_person_id) ,100);
              end if;
              ------------------------------------------------------------------------------------------------
              -- Because there are different routes for each group of data, a separate procedure
              -- has been written for each.
              -- Bug 2640107 : Call the archive procedures only for the latest person id
              -- in case the employee is rehired with duplicate National Identifier/Income Tax Number
              -- Bug 3435334 Introduced function employee_if_latest which returns a boolean TRUE/FALSE
              -- to indicate if an employee needs to be archived / skipped for any rehires.
              ------------------------------------------------------------------------------------------------
              if employee_if_latest (  v_national_identifier,
                                       v_person_id,
                                       g_setup_action_id,
                                       g_report_type ) then

                      --
                      -- Bug 4688761, only archives once if it has re-hire/multi
                      -- assignments
                      if NOT  person_if_archived(v_person_id) then

                            archive_balances ( p_assignment_action_id,v_person_id,
                                               g_business_group_id,
                                               g_legal_entity_id,
                                               g_basis_year );

                            --
                            archive_person_details ( p_assignment_action_id,
                                                     v_person_id,
                                                     g_basis_start,
                                                     g_basis_end );
                            --
                            archive_person_addresses ( p_assignment_action_id,
                                                       v_person_id,
                                                       g_basis_start,
                                                       g_basis_end );
                            --
                            archive_emp_details ( p_assignment_action_id,
                                                  v_person_id,
                                                  g_basis_start,
                                                  g_basis_end );
                            --
                            archive_people_flex ( p_assignment_action_id,
                                                  v_person_id,
                                                  g_basis_start,
                                                  g_basis_end );
                            --
                            archive_person_cq_addresses ( p_assignment_action_id,
                                                       v_person_id,
                                                       g_basis_start,
                                                       g_basis_end );

                            archive_person_eits ( p_assignment_action_id,
                                                      v_person_id,
                                                      g_basis_start,
                                                      g_basis_end );

                            archive_org_info ( p_assignment_action_id ,
                                               g_business_group_id,
                                               g_legal_entity_id,
                                               v_person_id,
                                               g_basis_start,
                                               g_basis_end);

                            archive_payroll_date( p_assignment_action_id ,
                                               g_business_group_id,
                                               g_legal_entity_id,
                                               v_person_id,
                                               g_basis_year);

                            --
                            -- Added for bug 4688761, share details should only
                            -- be archived for latest LE with primary defined if
                            -- it has rehired/multi-assignments with diff LE
                            --
                            if pri_if_latest(v_person_id,
                                            g_legal_entity_id,
                                            g_basis_start,
                                            g_basis_end) then

                                archive_shares_details ( p_assignment_action_id,
                                                         v_person_id,
                                                         g_legal_entity_id,
                                                         g_basis_start,
                                                         g_basis_end );
                            end if;

                            archive_os_assignment ( p_assignment_action_id,
                                                    v_person_id,
                                                    g_legal_entity_id,
                                                    g_basis_start,
                                                    g_basis_end );
                            --
                            -- Added for bug 3027801
                            archive_ir8s_c_details ( p_assignment_action_id,
                                                     v_person_id,
                                                     g_legal_entity_id,
                                                     g_business_group_id,
                                                     g_basis_start,
                                                     g_basis_end );

                      end if;

                      l_archived_person_id := v_person_id;
                      t_archived_person(l_archived_person_id).person_id:= v_person_id;
              else
                      if g_debug then
                             hr_utility.trace('The Employee has a duplicate employee so will not be processed');
                      end if;
              end if;
         else
              close get_details;
         end if;
         --
         if g_debug then
               hr_utility.set_location('pysgirar: End of archive_code',20);
         end if;
     end archive_code;
     --------------------------------------------------------------------------------------
     -- Bug#3501927  Added new function to fetch and calculate A8A Balances
     -- Bug#6349937  Split the large group balances to small groups for
     --              better performance
     --              Do not include Obsoleted balances
     ---------------------------------------------------------------------------------------
     procedure a8a_balances_value
      ( p_person_id in per_people_f.person_id%type,
        p_assct_id in pay_assignment_actions.assignment_action_id%type,
        p_tax_uid in pay_assignment_actions.tax_unit_id%type,
        p_person_counter in number )
     is
         l_balance_value_tab      pay_balance_pkg.t_balance_value_tab;
         l_context_tab            pay_balance_pkg.t_context_tab;
         l_detailed_bal_out_tab   pay_balance_pkg.t_detailed_bal_out_tab;

         l_balance_value_tab1      pay_balance_pkg.t_balance_value_tab;
         l_detailed_bal_out_tab1   pay_balance_pkg.t_detailed_bal_out_tab;

         l_balance_value_tab2      pay_balance_pkg.t_balance_value_tab;
         l_detailed_bal_out_tab2   pay_balance_pkg.t_detailed_bal_out_tab;

         l_balance_value_tab3      pay_balance_pkg.t_balance_value_tab;
         l_detailed_bal_out_tab3   pay_balance_pkg.t_detailed_bal_out_tab;

         l_balance_value_tab4      pay_balance_pkg.t_balance_value_tab;
         l_detailed_bal_out_tab4   pay_balance_pkg.t_detailed_bal_out_tab;

         l_balance_value_tab5      pay_balance_pkg.t_balance_value_tab;
         l_detailed_bal_out_tab5   pay_balance_pkg.t_detailed_bal_out_tab;

         l_ytd_a8a_counter        number;
         --
         cursor  ytd_A8A_balances is
         select  fue.user_entity_id,
                 pdb.defined_balance_id def_bal_id
         from    ff_user_entities fue,
                 pay_balance_types pbt,
                 pay_defined_balances pdb,
                 pay_balance_dimensions pbd
         where   fue.user_entity_name        = 'X_' || upper(replace(pbt.balance_name,' ','_')) || '_PER_LE_YTD'
         and     fue.legislation_code        = 'SG'
         and     pbt.legislation_code        = 'SG'
         and     pbd.legislation_code        = pbt.legislation_code
         and     pdb.legislation_code        = pbt.legislation_code
         and     pbt.balance_name            like 'A8A%'
         and     upper(pbt.reporting_name) not like '%OBSOLETE%'
         and     pbt.balance_type_id         = pdb.balance_type_id
         and     pbd.balance_dimension_id    = pdb.balance_dimension_id
         and     pbd.dimension_name          = '_PER_LE_YTD'
         order by pbt.balance_name asc;
         --
         cursor  benefit_inkind_bal is
         select  nvl(pei_information2, l_detailed_bal_out_tab(1).balance_value), --A8A_MOA_500
                 nvl(pei_information3, l_detailed_bal_out_tab(2).balance_value), --A8A_MOA_501
                 nvl(pei_information4, l_detailed_bal_out_tab(3).balance_value), --A8A_MOA_502
                 nvl(pei_information5, l_detailed_bal_out_tab(7).balance_value), --A8A_MOA_506
                 nvl(pei_information6, l_detailed_bal_out_tab(8).balance_value), --A8A_MOA_507
                 nvl(pei_information7, l_detailed_bal_out_tab(9).balance_value), --A8A_MOA_508
                 nvl(pei_information8, l_detailed_bal_out_tab(10).balance_value),--A8A_MOA_509
                 nvl(pei_information9, l_detailed_bal_out_tab(11).balance_value),--A8A_MOA_510
                 nvl(pei_information10,l_detailed_bal_out_tab(12).balance_value),--A8A_MOA_511
                 nvl(pei_information11,l_detailed_bal_out_tab(13).balance_value),--A8A_MOA_512
                 nvl(pei_information12,l_detailed_bal_out_tab(14).balance_value),--A8A_MOA_513
                 nvl(pei_information13,l_detailed_bal_out_tab(15).balance_value),--A8A_MOA_514
                 nvl(pei_information14,l_detailed_bal_out_tab(17).balance_value),--A8A_MOA_516
                 nvl(pei_information15,l_detailed_bal_out_tab(26).balance_value),--A8A_MOA_525
                 nvl(pei_information16,l_detailed_bal_out_tab(27).balance_value),--A8A_MOA_526
                 nvl(pei_information17,l_detailed_bal_out_tab(28).balance_value),--A8A_MOA_527
                 nvl(pei_information22,l_detailed_bal_out_tab(29).balance_value),--A8A_MOA_528
                 nvl(pei_information23,l_detailed_bal_out_tab(30).balance_value),--A8A_MOA_529
                 nvl(pei_information24,l_detailed_bal_out_tab(31).balance_value),--A8A_MOA_530
                 nvl(pei_information18,l_detailed_bal_out_tab(32).balance_value),--A8A_MOA_531
                 nvl(pei_information19,l_detailed_bal_out_tab(33).balance_value),--A8A_MOA_532
                 nvl(pei_information20,l_detailed_bal_out_tab(34).balance_value),--A8A_MOA_533
                 nvl(pei_information21,l_detailed_bal_out_tab(35).balance_value) --A8A_MOA_534
         from   per_people_extra_info pae
         where  person_id        = p_person_id
         and    information_type = 'HR_A8A_BENEFITS_IN_KIND_SG'
         and    pei_information1 = g_basis_year;
         --
         cursor  furniture_exp_bal is
         select  nvl(pei_information2, l_detailed_bal_out_tab(45).balance_value), --A8A_QTY_304
                 nvl(pei_information3, l_detailed_bal_out_tab(46).balance_value), --A8A_QTY_305
                 nvl(pei_information4, l_detailed_bal_out_tab(47).balance_value), --A8A_QTY_306
                 nvl(pei_information5, l_detailed_bal_out_tab(48).balance_value), --A8A_QTY_307
                 nvl(pei_information6, l_detailed_bal_out_tab(49).balance_value), --A8A_QTY_308
                 nvl(pei_information7, l_detailed_bal_out_tab(50).balance_value), --A8A_QTY_309
                 nvl(pei_information8, l_detailed_bal_out_tab(51).balance_value), --A8A_QTY_310
                 nvl(pei_information9, l_detailed_bal_out_tab(52).balance_value), --A8A_QTY_311
                 nvl(pei_information10,l_detailed_bal_out_tab(53).balance_value), --A8A_QTY_312
                 nvl(pei_information11,l_detailed_bal_out_tab(54).balance_value), --A8A_QTY_313
                 nvl(pei_information12,l_detailed_bal_out_tab(55).balance_value), --A8A_QTY_314
                 nvl(pei_information13,l_detailed_bal_out_tab(56).balance_value), --A8A_QTY_315
                 nvl(pei_information14,l_detailed_bal_out_tab(57).balance_value), --A8A_QTY_316
                 nvl(pei_information15,l_detailed_bal_out_tab(58).balance_value), --A8A_QTY_317
                 nvl(pei_information16,l_detailed_bal_out_tab(59).balance_value), --A8A_QTY_318
                 nvl(pei_information17,l_detailed_bal_out_tab(60).balance_value), --A8A_QTY_319
                 nvl(pei_information18,l_detailed_bal_out_tab(61).balance_value), --A8A_QTY_320
                 nvl(pei_information19,l_detailed_bal_out_tab(18).balance_value), --A8A_MOA_517
                 nvl(pei_information20,l_detailed_bal_out_tab(19).balance_value), --A8A_MOA_518
                 nvl(pei_information21,l_detailed_bal_out_tab(20).balance_value), --A8A_MOA_519
                 nvl(pei_information22,l_detailed_bal_out_tab(21).balance_value), --A8A_MOA_520
                 nvl(pei_information23,l_detailed_bal_out_tab(22).balance_value), --A8A_MOA_521
                 nvl(pei_information24,l_detailed_bal_out_tab(23).balance_value), --A8A_MOA_522
                 nvl(pei_information25,l_detailed_bal_out_tab(24).balance_value), --A8A_MOA_523
                 nvl(pei_information26,l_detailed_bal_out_tab(25).balance_value) --A8A_MOA_524
         from    per_people_extra_info pae
         where   person_id        = p_person_id
         and     information_type ='HR_A8A_FURN_EXP_SG'
         and     pei_information1 = g_basis_year;
         --
         cursor  hotel_accom_bal is
         select  nvl(pei_information2, l_detailed_bal_out_tab(62).balance_value), --A8A_QTY_321
                 nvl(pei_information3, l_detailed_bal_out_tab(63).balance_value), --A8A_QTY_322
                 nvl(pei_information4, l_detailed_bal_out_tab(64).balance_value), --A8A_QTY_323
                 nvl(pei_information5, l_detailed_bal_out_tab(65).balance_value), --A8A_QTY_324
                 nvl(pei_information6, l_detailed_bal_out_tab(66).balance_value), --A8A_QTY_325
                 nvl(pei_information7, l_detailed_bal_out_tab(67).balance_value), --A8A_QTY_326
                 nvl(pei_information8, l_detailed_bal_out_tab(68).balance_value), --A8A_QTY_327
                 nvl(pei_information9, l_detailed_bal_out_tab(69).balance_value), --A8A_QTY_328
                 nvl(pei_information10,l_detailed_bal_out_tab(40).balance_value), --A8A_MOA_539
                 nvl(pei_information11,l_detailed_bal_out_tab(41).balance_value), --A8A_QTY_300
                 nvl(pei_information12,l_detailed_bal_out_tab(42).balance_value), --A8A_QTY_301
                 nvl(pei_information13,l_detailed_bal_out_tab(43).balance_value), --A8A_QTY_302
                 nvl(pei_information14,l_detailed_bal_out_tab(44).balance_value), --A8A_QTY_303
                 nvl(pei_information15,l_detailed_bal_out_tab(6).balance_value)  --A8A_MOA_505
,                nvl(pei_information16,l_detailed_bal_out_tab(70).balance_value) --A8A_QTY_329, bug 5435088
         from    per_people_extra_info pae
         where   person_id        = p_person_id
         and     information_type ='HR_A8A_HOTEL_ACCOM_SG'
         and     pei_information1 = g_basis_year;
         --
         cursor  c_globals (p_global_name in varchar2) is
         select  global_value
         from    ff_globals_f
         where   global_name = p_global_name;
         --
         l_a8a_person_20   number;
         l_a8a_child_8_20  number;
         l_a8a_child_3_7   number;
         l_a8a_child_3     number;

         /* Bug 5230059 */
         l_a8a_person_20_a   number;
         l_a8a_child_8_20_a  number;
         l_a8a_child_3_7_a   number;
         l_a8a_child_3_a     number;

         l_count             number;
     begin
         l_ytd_a8a_counter  := 1;
         l_balance_value_tab.delete;
         l_context_tab.delete;
         l_detailed_bal_out_tab.delete;
         --
         l_balance_value_tab1.delete;
         l_detailed_bal_out_tab1.delete;
         --
         l_balance_value_tab2.delete;
         l_detailed_bal_out_tab2.delete;
         --
         l_balance_value_tab3.delete;
         l_detailed_bal_out_tab3.delete;

         l_balance_value_tab4.delete;
         l_detailed_bal_out_tab4.delete;

         l_balance_value_tab5.delete;
         l_detailed_bal_out_tab5.delete;

         l_count := 14;

         if t_ytd_a8a_balanceid_store.count = 0 then
             open ytd_a8a_balances;
             loop
                 fetch ytd_a8a_balances into t_ytd_a8a_balanceid_store(l_ytd_a8a_counter).user_entity_id,
                                             t_ytd_a8a_balanceid_store(l_ytd_a8a_counter).defined_balance_id;
                 l_ytd_a8a_counter :=  l_ytd_a8a_counter + 1;
                 exit when ytd_a8a_balances%NOTFOUND;
             end loop;
             close ytd_a8a_balances;
         end if;
         --

         for counter in 1..l_count
         loop
             l_balance_value_tab1(counter).defined_balance_id := t_ytd_a8a_balanceid_store(counter).defined_balance_id;
             l_balance_value_tab2(counter).defined_balance_id := t_ytd_a8a_balanceid_store(counter+l_count).defined_balance_id;
             l_balance_value_tab3(counter).defined_balance_id := t_ytd_a8a_balanceid_store(counter+2*l_count).defined_balance_id;
             l_balance_value_tab4(counter).defined_balance_id := t_ytd_a8a_balanceid_store(counter+3*l_count).defined_balance_id;
             l_balance_value_tab5(counter).defined_balance_id := t_ytd_a8a_balanceid_store(counter+4*l_count).defined_balance_id;

             l_context_tab(counter).tax_unit_id := p_tax_uid;
         end loop;

         --
         if  p_assct_id is not null then
             pay_balance_pkg.get_value( p_assct_id,
                                        l_balance_value_tab1,
                                        l_context_tab,
                                        false,
                                        false,
                                        l_detailed_bal_out_tab1);
             pay_balance_pkg.get_value( p_assct_id,
                                        l_balance_value_tab2,
                                        l_context_tab,
                                        false,
                                        false,
                                        l_detailed_bal_out_tab2);
             pay_balance_pkg.get_value( p_assct_id,
                                        l_balance_value_tab3,
                                        l_context_tab,
                                        false,
                                        false,
                                        l_detailed_bal_out_tab3);
             pay_balance_pkg.get_value( p_assct_id,
                                        l_balance_value_tab4,
                                        l_context_tab,
                                        false,
                                        false,
                                        l_detailed_bal_out_tab4);
             pay_balance_pkg.get_value( p_assct_id,
                                        l_balance_value_tab5,
                                        l_context_tab,
                                        false,
                                        false,
                                        l_detailed_bal_out_tab5);
         end if;
         for counter in 1..l_count
         loop
             l_detailed_bal_out_tab(counter).balance_value := l_detailed_bal_out_tab1(counter).balance_value;
             l_detailed_bal_out_tab(counter+l_count).balance_value := l_detailed_bal_out_tab2(counter).balance_value;
             l_detailed_bal_out_tab(counter+2*l_count).balance_value := l_detailed_bal_out_tab3(counter).balance_value;
             l_detailed_bal_out_tab(counter+3*l_count).balance_value := l_detailed_bal_out_tab4(counter).balance_value;
             l_detailed_bal_out_tab(counter+4*l_count).balance_value := l_detailed_bal_out_tab5(counter).balance_value;
         end loop;

         --
         open   benefit_inkind_bal;
         fetch  benefit_inkind_bal into
                l_detailed_bal_out_tab(1).balance_value,  --A8A_MOA_500
                l_detailed_bal_out_tab(2).balance_value,  --A8A_MOA_501
                l_detailed_bal_out_tab(3).balance_value,  --A8A_MOA_502
                l_detailed_bal_out_tab(7).balance_value,  --A8A_MOA_506
                l_detailed_bal_out_tab(8).balance_value,  --A8A_MOA_507
                l_detailed_bal_out_tab(9).balance_value,  --A8A_MOA_508
                l_detailed_bal_out_tab(10).balance_value, --A8A_MOA_509
                l_detailed_bal_out_tab(11).balance_value, --A8A_MOA_510
                l_detailed_bal_out_tab(12).balance_value, --A8A_MOA_511
                l_detailed_bal_out_tab(13).balance_value, --A8A_MOA_512
                l_detailed_bal_out_tab(14).balance_value, --A8A_MOA_513
                l_detailed_bal_out_tab(15).balance_value, --A8A_MOA_514
                l_detailed_bal_out_tab(17).balance_value, --A8A_MOA_516
                l_detailed_bal_out_tab(26).balance_value, --A8A_MOA_525
                l_detailed_bal_out_tab(27).balance_value, --A8A_MOA_526
                l_detailed_bal_out_tab(28).balance_value, --A8A_MOA_527
                l_detailed_bal_out_tab(29).balance_value, --A8A_MOA_528
                l_detailed_bal_out_tab(30).balance_value, --A8A_MOA_529
                l_detailed_bal_out_tab(31).balance_value, --A8A_MOA_530
                l_detailed_bal_out_tab(32).balance_value, --A8A_MOA_531
                l_detailed_bal_out_tab(33).balance_value, --A8A_MOA_532
                l_detailed_bal_out_tab(34).balance_value, --A8A_MOA_533
                l_detailed_bal_out_tab(35).balance_value ; --A8A_MOA_534
         close  benefit_inkind_bal;
         --
         open   furniture_exp_bal;
         fetch  furniture_exp_bal  into
                l_detailed_bal_out_tab(45).balance_value,  --A8A_QTY_304
                l_detailed_bal_out_tab(46).balance_value,  --A8A_QTY_305
                l_detailed_bal_out_tab(47).balance_value,  --A8A_QTY_306
                l_detailed_bal_out_tab(48).balance_value,  --A8A_QTY_307
                l_detailed_bal_out_tab(49).balance_value,  --A8A_QTY_308
                l_detailed_bal_out_tab(50).balance_value,  --A8A_QTY_309
                l_detailed_bal_out_tab(51).balance_value,  --A8A_QTY_310
                l_detailed_bal_out_tab(52).balance_value,  --A8A_QTY_311
                l_detailed_bal_out_tab(53).balance_value,  --A8A_QTY_312
                l_detailed_bal_out_tab(54).balance_value,  --A8A_QTY_313
                l_detailed_bal_out_tab(55).balance_value,  --A8A_QTY_314
                l_detailed_bal_out_tab(56).balance_value,  --A8A_QTY_315
                l_detailed_bal_out_tab(57).balance_value,  --A8A_QTY_316
                l_detailed_bal_out_tab(58).balance_value,  --A8A_QTY_317
                l_detailed_bal_out_tab(59).balance_value,  --A8A_QTY_318
                l_detailed_bal_out_tab(60).balance_value,  --A8A_QTY_319
                l_detailed_bal_out_tab(61).balance_value,  --A8A_QTY_320
                l_detailed_bal_out_tab(18).balance_value,  --A8A_MOA_517
                l_detailed_bal_out_tab(19).balance_value,  --A8A_MOA_518
                l_detailed_bal_out_tab(20).balance_value,  --A8A_MOA_519
                l_detailed_bal_out_tab(21).balance_value,  --A8A_MOA_520
                l_detailed_bal_out_tab(22).balance_value,  --A8A_MOA_521
                l_detailed_bal_out_tab(23).balance_value,  --A8A_MOA_522
                l_detailed_bal_out_tab(24).balance_value,  --A8A_MOA_523
                l_detailed_bal_out_tab(25).balance_value ; --A8A_MOA_524
         close  furniture_exp_bal ;
         --
         open   hotel_accom_bal;
         fetch  hotel_accom_bal  into
                l_detailed_bal_out_tab(62).balance_value, --A8A_QTY_321
                l_detailed_bal_out_tab(63).balance_value, --A8A_QTY_322
                l_detailed_bal_out_tab(64).balance_value, --A8A_QTY_323
                l_detailed_bal_out_tab(65).balance_value, --A8A_QTY_324
                l_detailed_bal_out_tab(66).balance_value, --A8A_QTY_325
                l_detailed_bal_out_tab(67).balance_value, --A8A_QTY_326
                l_detailed_bal_out_tab(68).balance_value, --A8A_QTY_327
                l_detailed_bal_out_tab(69).balance_value, --A8A_QTY_328
                l_detailed_bal_out_tab(40).balance_value, --A8A_MOA_539
                l_detailed_bal_out_tab(41).balance_value, --A8A_QTY_300
                l_detailed_bal_out_tab(42).balance_value, --A8A_QTY_301
                l_detailed_bal_out_tab(43).balance_value, --A8A_QTY_302
                l_detailed_bal_out_tab(44).balance_value, --A8A_QTY_303
                l_detailed_bal_out_tab(6).balance_value, --A8A_MOA_505
                l_detailed_bal_out_tab(70).balance_value; -- A8A_QTY_329

         close  hotel_accom_bal;
         -------------------------------------------------------------
         -- Calculation for A8A_MOA_503 (Sum of MOA 517 to 534))
         -------------------------------------------------------------
         l_detailed_bal_out_tab(4).balance_value :=
                        l_detailed_bal_out_tab(18).balance_value + l_detailed_bal_out_tab(19).balance_value
                      + l_detailed_bal_out_tab(20).balance_value + l_detailed_bal_out_tab(21).balance_value
                      + l_detailed_bal_out_tab(22).balance_value + l_detailed_bal_out_tab(23).balance_value
                      + l_detailed_bal_out_tab(24).balance_value + l_detailed_bal_out_tab(25).balance_value
                      + l_detailed_bal_out_tab(26).balance_value + l_detailed_bal_out_tab(27).balance_value
                      + l_detailed_bal_out_tab(28).balance_value + l_detailed_bal_out_tab(29).balance_value
                      + l_detailed_bal_out_tab(30).balance_value + l_detailed_bal_out_tab(31).balance_value
                      + l_detailed_bal_out_tab(32).balance_value + l_detailed_bal_out_tab(33).balance_value
                      + l_detailed_bal_out_tab(34).balance_value + l_detailed_bal_out_tab(35).balance_value ;
         --
         open   c_globals( 'A8A_PERSON_20' );
         fetch  c_globals into l_a8a_person_20;
         close  c_globals;
         -------------------------------------------------------------
         -- Calculation for A8A_MOA_535
         -- (A8A_QTY_321 *  Rate * 12 * A8A_QTY_322 /365)
         -- Bug 7415444, A8A_QTY_322 can not <0
         -------------------------------------------------------------
         l_a8a_person_20_a := l_detailed_bal_out_tab(62).balance_value *  l_a8a_person_20 * 12 * l_detailed_bal_out_tab(63).balance_value / 365;
         --
         if l_detailed_bal_out_tab(62).balance_value > 0 and
                l_detailed_bal_out_tab(63).balance_value > 0 then
           if l_a8a_person_20_a between 0 and 1 then
              l_detailed_bal_out_tab(36).balance_value := 1;
           else
              l_detailed_bal_out_tab(36).balance_value := trunc(l_a8a_person_20_a);
           end if;
         else
           l_detailed_bal_out_tab(36).balance_value := 0;
         end if;
         --
         open   c_globals('A8A_CHILD_8_20');
         fetch  c_globals into l_a8a_child_8_20;
         close  c_globals;
         -------------------------------------------------------------
         -- Calculation for A8A_MOA_536
         -- (A8A_QTY_323 *  Rate * 12 * A8A_QTY_324 /365)
         -- Bug 5230059
         -- Bug 7415444, A8A_QTY_324 cannot < 0
         -------------------------------------------------------------
         l_a8a_child_8_20_a := l_detailed_bal_out_tab(64).balance_value *  l_a8a_child_8_20 * 12 * l_detailed_bal_out_tab(65).balance_value / 365;
         --
         if l_detailed_bal_out_tab(64).balance_value > 0 and
                l_detailed_bal_out_tab(65).balance_value > 0 then
           if l_a8a_child_8_20_a between 0 and 1 then
              l_detailed_bal_out_tab(37).balance_value := 1;
           else
              l_detailed_bal_out_tab(37).balance_value := trunc(l_a8a_child_8_20_a);
           end if;
         else
           l_detailed_bal_out_tab(37).balance_value := 0;
         end if;
         --
         open   c_globals ('A8A_CHILD_3_7');
         fetch  c_globals into l_a8a_child_3_7;
         close  c_globals;
         -------------------------------------------------------------
         -- Calculation for A8A_MOA_537
         -- (A8A_QTY_325 *  rate * 12 * A8A_QTY_326/365)
         -- Bug 7415444, A8A_QTY_326 cannot < 0
         -------------------------------------------------------------
         l_a8a_child_3_7_a := l_detailed_bal_out_tab(66).balance_value * l_a8a_child_3_7 * 12 * l_detailed_bal_out_tab(67).balance_value / 365;
         --
         if l_detailed_bal_out_tab(66).balance_value > 0 and
                l_detailed_bal_out_tab(67).balance_value > 0 then
           if l_a8a_child_3_7_a between 0 and 1 then
              l_detailed_bal_out_tab(38).balance_value := 1;
           else
              l_detailed_bal_out_tab(38).balance_value := trunc(l_a8a_child_3_7_a);
           end if;
         else
           l_detailed_bal_out_tab(38).balance_value := 0;
         end if;
         --
         open   c_globals('A8A_CHILD_3');
         fetch  c_globals into l_a8a_child_3;
         close  c_globals;
         -------------------------------------------------------------
         -- Calculation for A8A_MOA_538
         -- (A8A_QTY_327 *  rate * 12 * A8A_QTY_328/365)
         -- Bug 5230059
         -- Bug 7415444, A8A_QTY_328 cannot < 0
         -------------------------------------------------------------
         l_a8a_child_3_a := l_detailed_bal_out_tab(68).balance_value * l_a8a_child_3 * 12 * l_detailed_bal_out_tab(69).balance_value / 365;

         --
         if l_detailed_bal_out_tab(68).balance_value > 0 and
                l_detailed_bal_out_tab(69).balance_value > 0 then
           if l_a8a_child_3_a between 0 and 1 then
              l_detailed_bal_out_tab(39).balance_value := 1;
           else
              l_detailed_bal_out_tab(39).balance_value := trunc(l_a8a_child_3_a);
           end if;
         else
           l_detailed_bal_out_tab(39).balance_value := 0;
         end if;

         ------------------------------------------------------------
         -- Bug 5435088, if the No of employees sharing the Quarter is not zero
         -- MOA500 and MOA503 is divided by the number of employee sharing
         -- Removed calculation for bug fix 5644617
         ------------------------------------------------------------

         -------------------------------------------------------------
         -- Calculation for A8A_MOA_504  (Sum of MOA 535 to 539)
         -------------------------------------------------------------
         l_detailed_bal_out_tab(5).balance_value :=
                        l_detailed_bal_out_tab(36).balance_value + l_detailed_bal_out_tab(37).balance_value
                      + l_detailed_bal_out_tab(38).balance_value + l_detailed_bal_out_tab(39).balance_value
                      + l_detailed_bal_out_tab(40).balance_value;
         --
         -------------------------------------------------------------
         -- Calculation for A8A_MOA_515 (MOA 500 + 503 + 504 + 505 + 506 + 507 +508 + 509 + 510 + 511 + 512 + 513 + 514 + 516 )
         --  Bug#3948951 Moved the code after  A8A_MOA_504 balance calculation.
         -------------------------------------------------------------
         l_detailed_bal_out_tab(16).balance_value :=
                        l_detailed_bal_out_tab(1).balance_value  + l_detailed_bal_out_tab(4).balance_value
                      + l_detailed_bal_out_tab(5).balance_value  + l_detailed_bal_out_tab(6).balance_value
                      + l_detailed_bal_out_tab(7).balance_value  + l_detailed_bal_out_tab(8).balance_value
                      + l_detailed_bal_out_tab(9).balance_value  + l_detailed_bal_out_tab(10).balance_value
                      + l_detailed_bal_out_tab(11).balance_value + l_detailed_bal_out_tab(12).balance_value
                      + l_detailed_bal_out_tab(13).balance_value + l_detailed_bal_out_tab(14).balance_value
                      + l_detailed_bal_out_tab(15).balance_value + l_detailed_bal_out_tab(17).balance_value ;
         --
         for counter in 1..l_detailed_bal_out_tab.count
         loop
               if p_person_counter = 1 then
                     if l_detailed_bal_out_tab.exists(counter) then
                           ytd_a8a_balance_rec(counter).balance_id    := t_ytd_a8a_balanceid_store(counter).user_entity_id;
                           ytd_a8a_balance_rec(counter).balance_value := nvl(l_detailed_bal_out_tab(counter).balance_value,0) ;
                     end if;
               else
                     if l_detailed_bal_out_tab.exists(counter) then
                           if ytd_a8a_balance_rec.exists(counter) then
                                    ytd_a8a_balance_rec(counter).balance_value := nvl(l_detailed_bal_out_tab(counter).balance_value,0)
                                                                           + ytd_a8a_balance_rec(counter).balance_value;
                           end if;
                     end if;
               end if;
         end loop;
         --
     exception
         when others then
              hr_utility.set_location('pysgirar: Error in a8a_balances_value',10);
         raise;
     end;
     ---------------------------------------------------------------------------
     -- Selects data required to archive the YTD and Month balances. The
     -- cursors' main purpose is to select the latest action sequence for the
     -- PERSON (independent of assignment) within the Legal Entity, and pass
     -- that to pay_balance_pkg.
     -- Also the User Entity Name must match up to the balance.
     --
     -- YTD Balances: All IRAS balances + specific previously seeded balances
     -- Month Balances: Specific balances required for IR8S as this breaks down
     --                 earnings by month.
     ---------------------------------------------------------------------------
     procedure archive_balances
      ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
        p_person_id             in per_all_people_f.person_id%type,
        p_business_group_id     in hr_organization_units.business_group_id%type,
        p_tax_unit_id           in ff_archive_item_contexts.context%type,
        p_basis_year            in varchar2 )
     is
         v_run_ass_action_id      pay_assignment_actions.assignment_action_id%type;
         v_date_earned            ff_archive_item_contexts.context%type;
         v_balance_value          ff_archive_items.value%type;
         v_archive_item_id        ff_archive_items.archive_item_id%type;
         v_object_version_number  ff_archive_items.object_version_number%type;
         v_some_warning           boolean;
         --------------------------------------------------------------------------------------
         --Bug#3933332 Moved the records from package header as these pl/sql table is
         -- specific to procedure archive_balances()
         --------------------------------------------------------------------------------------
         type t_archive_items_tab is table of ff_archive_items.archive_item_id%TYPE index by binary_integer;
         t_archive_items               t_archive_items_tab;
         --
         type t_archive_value_tab is table of ff_archive_items.value%TYPE index by binary_integer;
         t_archive_value               t_archive_value_tab;
         --
         type t_date_earned_tab  is table of varchar2(30) index by binary_integer;
         t_date_earned                 t_date_earned_tab;
         --
         type t_user_entity_tab is table of ff_user_entities.user_entity_id%TYPE index by binary_integer;
         t_user_entity_id              t_user_entity_tab;
         --
         ---------------------------------------------------------------------------------------------------
         -- This ytd_balances cursor only gets the defined_balance_id and user_entity_id
         -- Bug 3232303- Added 4 new balances.
         -- Bug 6349937, do not include Obsoleted balances
         ---------------------------------------------------------------------------------------------------
         cursor  ytd_balances is
         select  fue.user_entity_id,
                 pdb.defined_balance_id def_bal_id
         from    ff_user_entities fue,
                 pay_balance_types pbt,
                 pay_defined_balances pdb,
                 pay_balance_dimensions pbd
         where   fue.user_entity_name = 'X_' || upper(replace(pbt.balance_name,' ','_')) || '_PER_LE_YTD'
         and     fue.legislation_code = 'SG'
         and     pbt.legislation_code = 'SG'
         and     pbd.legislation_code = pbt.legislation_code
         and     pdb.legislation_code = pbt.legislation_code
         and     ( pbt.balance_name in ('Voluntary CPF Liability','CPF Liability',
                                  'Voluntary CPF Withheld','CPF Withheld',
                                  'Employee CPF Contributions Additional Earnings',
                                  'Employee CPF Contributions Ordinary Earnings',
                                  'Employer CPF Contributions Additional Earnings',
                                  'Employer CPF Contributions Ordinary Earnings',
                                  'Additional Earnings','Ordinary Earnings',
				  'Employer Vol CPF Contributions Ordinary Earnings',
                                  'Employee Vol CPF Contributions Ordinary Earnings',
                                  'Employer Vol CPF Contributions Additional Earnings',
                                  'Employee Vol CPF Contributions Additional Earnings')
                 or
                 ( pbt.balance_name like 'IR8%' ) )
         and     upper(pbt.reporting_name) not like '%OBSOLETE%'
         and     pbt.balance_type_id = pdb.balance_type_id
         and     pbd.balance_dimension_id = pdb.balance_dimension_id
         and     pbd.dimension_name = '_PER_LE_YTD';
         ---------------------------------------------------------------------------------------------------
         -- Bug 2629839. Cursor month_year_action is split into two cursors month_year_action_sequence and
         -- month_year_action to improve the performance
         -- Bug# 2920732 - Modified the cursor to use secured view per_assignments_f
         -- Cursor month_year_action_sequence
         ---------------------------------------------------------------------------------------------------
         cursor month_year_action_sequence
             ( c_person_id          per_all_people_f.person_id%type,
               c_business_group_id  hr_organization_units.business_group_id%type,
               c_legal_entity_id    pay_assignment_actions.tax_unit_id%type,
               c_basis_year         varchar2 )
         is
         select   /*+ ORDERED USE_NL(pacmax) */
                  max(pacmax.action_sequence) act_seq,
                  to_char(ppamax.effective_date,'MM')
         from     per_assignments_f paamax,
                  pay_assignment_actions pacmax,
                  pay_payroll_actions ppamax
         where    ppamax.business_group_id = c_business_group_id
         and      pacmax.tax_unit_id = c_legal_entity_id
         and      paamax.person_id = c_person_id
         and      paamax.assignment_id = pacmax.assignment_id
         and      ppamax.effective_date between to_date('01-01-'||c_basis_year,'DD-MM-YYYY')
                                            and to_date('31-12-'||c_basis_year,'DD-MM-YYYY')
         and      ppamax.payroll_action_id = pacmax.payroll_action_id
         and      ppamax.action_type in ('R','B','I','Q','V')
         group by  to_char(ppamax.effective_date,'MM')
         order by  to_char(ppamax.effective_date,'MM');
         ---------------------------------------------------------------------------------------------------
         -- cursor month_year_action
         ---------------------------------------------------------------------------------------------------
         cursor  month_year_action
               ( c_person_id          per_all_people_f.person_id%type,
                 c_business_group_id  hr_organization_units.business_group_id%type,
                 c_legal_entity_id    pay_assignment_actions.tax_unit_id%type,
                 c_basis_year         varchar2,
                 c_action_sequence    pay_assignment_actions.action_sequence%type )
         is
         select  /*+ ORDERED USE_NL(pac) */
                  pac.assignment_action_id assact_id,
                  decode(ppa.action_type,'V',fnd_date.date_to_canonical(ppa.effective_date),fnd_date.date_to_canonical(ppa.date_earned)) date_earned,
                  pac.tax_unit_id tax_uid
         from     per_assignments_f paa,
                  pay_assignment_actions pac,
                  pay_payroll_actions ppa
         where    ppa.business_group_id = c_business_group_id
         and      pac.tax_unit_id = c_legal_entity_id
         and      paa.person_id = c_person_id
         and      paa.assignment_id = pac.assignment_id
         and      ppa.effective_date between to_date('01-01-'||c_basis_year,'DD-MM-YYYY')
                                         and to_date('31-12-'||c_basis_year,'DD-MM-YYYY')
         and      ppa.payroll_action_id = pac.payroll_action_id
         and      pac.action_sequence = c_action_sequence;
         ---------------------------------------------------------------------------------------------------
         -- this month_balances cursor only gets the defined_balance_id and user_entity_id
         -- Bug 3232303- Added 4 new balances.
         ---------------------------------------------------------------------------------------------------
         cursor month_balances
         is
         select  fue.user_entity_id,
                 pdb.defined_balance_id def_bal_id
         from    ff_user_entities fue,
                 pay_balance_types pbt,
                 pay_defined_balances pdb,
                 pay_balance_dimensions pbd
         where   fue.user_entity_name = 'X_' || upper(replace(pbt.balance_name,' ','_')) || '_PER_LE_MONTH'
         and     fue.legislation_code = 'SG'
         and     pbt.legislation_code = 'SG'
         and     pbd.legislation_code = pbt.legislation_code
         and     pdb.legislation_code = pbt.legislation_code
         and     pbt.balance_name in ('Employee CPF Contributions Additional Earnings',
                                      'Employee CPF Contributions Ordinary Earnings',
                                      'Employer CPF Contributions Additional Earnings',
                                      'Employer CPF Contributions Ordinary Earnings',
                                      'Additional Earnings','Ordinary Earnings',
                                      'Employer Vol CPF Contributions Ordinary Earnings',
                                      'Employee Vol CPF Contributions Ordinary Earnings',
                                      'Employer Vol CPF Contributions Additional Earnings',
                                      'Employee Vol CPF Contributions Additional Earnings',
                                      'IR8S_MOA_403','IR8S_MOA_407','CPF Liability' )
         and     pbt.balance_type_id = pdb.balance_type_id
         and     pbd.balance_dimension_id = pdb.balance_dimension_id
         and     pbd.dimension_name = '_PER_LE_MONTH';
         --
         ---------------------------------------------------------------------------------------------------
         -- Balance Store Record
         ---------------------------------------------------------------------------------------------------
         --
         type ytd_balance_store_rec is record
	  ( balance_id              ff_user_entities.user_entity_id%type,
            balance_value           number );
         type ytd_balance_tab is table of ytd_balance_store_rec index by binary_integer;
         ytd_balance_rec ytd_balance_tab;
         --
         type mtd_balance_store_rec is record
	  ( balance_id              ff_user_entities.user_entity_id%type,
            balance_value           number,
            date_earned             varchar2(6),
            date_earned_archive   varchar2(30),
            person_id             number,
            archive_status        varchar2(1) );
         type mtd_balance_tab is table of mtd_balance_store_rec index by binary_integer;
         mtd_balance_rec mtd_balance_tab;
         ---------------------------------------------------------------------------------------------------
         -- Bug 3064282  Batch Balance fetch implemented
         ---------------------------------------------------------------------------------------------------
         g_balance_value_tab    pay_balance_pkg.t_balance_value_tab;
         g_context_tab          pay_balance_pkg.t_context_tab;
         g_detailed_bal_out_tab pay_balance_pkg.t_detailed_bal_out_tab;

         g_balance_value_tab1    pay_balance_pkg.t_balance_value_tab;
         g_detailed_bal_out_tab1 pay_balance_pkg.t_detailed_bal_out_tab;

         g_balance_value_tab2    pay_balance_pkg.t_balance_value_tab;
         g_detailed_bal_out_tab2 pay_balance_pkg.t_detailed_bal_out_tab;
         g_balance_value_tab3    pay_balance_pkg.t_balance_value_tab;
         g_detailed_bal_out_tab3 pay_balance_pkg.t_detailed_bal_out_tab;
         g_balance_value_tab4    pay_balance_pkg.t_balance_value_tab;
         g_detailed_bal_out_tab4 pay_balance_pkg.t_detailed_bal_out_tab;
         ---------------------------------------------------------------------------------------------------
         -- Type to store the person ids with same national_identifier (Bug 2649107)
         ---------------------------------------------------------------------------------------------------
         type person_id_store_rec is record
          ( person_id      per_all_people_f.person_id%type );
         type person_id_tab is table of person_id_store_rec index by binary_integer;
         person_id_rec    person_id_tab;
         ---------------------------------------------------------------------------------------------------
         -- Type to store the months on which payroll is run for a perticular person id
         -- Bug: 3205321- Modifed the type of month variable to number. Deleted the cursor which uses the
         --               lookup MONTH_CODE.
         ---------------------------------------------------------------------------------------------------
         type month_store_rec is record
          ( month     number );
         type month_store_tab is table of month_store_rec index by binary_integer;
         month_recs       month_store_tab;
         ---------------------------------------------------------------------------------------------------
         -- Local Variables
         ---------------------------------------------------------------------------------------------------
         l_payroll_mon_counter           number;
         l_pmon_counter                  boolean;
         month_year_action_sequence_rec  month_year_action_sequence%rowtype;
         month_year_action_rec           month_year_action%rowtype;
         per_le_ytd_bal                  number;
         per_le_mtd_bal                  number;
         l_person_id                     per_all_people_f.person_id%type;
         l_ytd_counter                   number;
         l_mon_counter                   number;
         counter                         number;
         icounter                        number;
         l_counter                       number;
         duplicate_exists                varchar2(1);
         l_mtd_counter                   number;
         l_arch_counter                  number;
         l_asac_cont_id                  number;
         l_tax_cont_id                   number;
         l_date_cont_id                  number;

         ---------------------------------------------------------------------------------------------------
     begin
         l_payroll_mon_counter      := 1;
         l_pmon_counter             := false;
         l_ytd_counter              := 1;
         l_mon_counter              := 1;
         l_counter                  := 1;
         duplicate_exists           := 'N';
         l_arch_counter             := 1;
         --
         if g_debug then
              hr_utility.set_location('pysgirar: Start of archive_balances',10);
         end if;
         ------------------------------------------------------------------------------------------------
         -- Bug 3435334 Table g_person_id_tab is populated with duplicate records for current person
         -- in employee_if_latest( ) function
         ------------------------------------------------------------------------------------------------
         if g_person_id_tab.count > 1 then
              for l_person_id in g_person_id_tab.first..g_person_id_tab.last
              loop
                   person_id_rec(l_counter).person_id := g_person_id_tab(l_person_id);
                   l_counter                          := l_counter+1;
              end loop;
              --
              duplicate_exists := 'Y';
         end if;
         --
         t_archive_items.delete;
         t_user_entity_id.delete;
         t_archive_value.delete;
         t_date_earned.delete;
         ------------------------------------------------------------------------------------------------
         -- Populate with the only one person_id if the employee is not
         -- duplicated(Bug 2849107)
         ------------------------------------------------------------------------------------------------
         if  duplicate_exists = 'N' then
              person_id_rec(l_counter).person_id := p_person_id;
         end if;
         ------------------------------------------------------------------------------------------------
         -- 2556026 Used pl/sql table to store the month_balances values.
         -- now month_balances will get executed only once
         ------------------------------------------------------------------------------------------------
         if t_month_balanceid_store.count = 0 then
              open month_balances;
              loop
                  fetch month_balances  into t_month_balanceid_store(l_mon_counter).user_entity_id,
                                             t_month_balanceid_store(l_mon_counter).defined_balance_id;
                  l_mon_counter :=  l_mon_counter + 1;
                  exit when month_balances%NOTFOUND;
              end loop;
              close month_balances;
         end if;
         ------------------------------------------------------------------------------------------------
         -- 2556026 Used pl/sql table to store the ytd_balances values.
         -- Now ytd_balances will get executed only once
         ------------------------------------------------------------------------------------------------
         if t_ytd_balanceid_store.count = 0 then
              open ytd_balances;
              loop
                  fetch ytd_balances into t_ytd_balanceid_store(l_ytd_counter).user_entity_id,
                                  t_ytd_balanceid_store(l_ytd_counter).defined_balance_id;
                  l_ytd_counter :=  l_ytd_counter + 1;
                  exit when ytd_balances%NOTFOUND;
              end loop;
              close ytd_balances;
         end if;
         ------------------------------------------------------------------------------------------------
         -- Bug# 3501927
         ------------------------------------------------------------------------------------------------
         ytd_a8a_balance_rec.delete;
         ------------------------------------------------------------------------------------------------
         -- Bug 2629839 : Monthly balances are archived first and then the max assignment
         --   action id returned from the month_year_action cursor is used for archiving
         --   year balances
         ------------------------------------------------------------------------------------------------
         if person_id_rec.count > 0 then
              for l_person_counter in 1..person_id_rec.last
              loop
                  if person_id_rec.exists(l_person_counter) then
                        open month_year_action_sequence( person_id_rec(l_person_counter).person_id,
                                                         p_business_group_id,
                                                         p_tax_unit_id,
                                                         p_basis_year );
                        loop
                              fetch month_year_action_sequence into month_year_action_sequence_rec;
                              exit when month_year_action_sequence%notfound;
                              --
                              open month_year_action( person_id_rec(l_person_counter).person_id,
                                                      p_business_group_id,
                                                      p_tax_unit_id,
                                                      p_basis_year,
                                                      month_year_action_sequence_rec.act_seq );
                              --
                              fetch month_year_action into month_year_action_rec;
                              if month_year_action%found then
                                      ----------------------------------------------------------------------------------
                                      -- Start Bug 3038605 - Store the months which have payroll runs.
                                      -- Bug: 3205321 - Store Month in MM format in month_recs
                                      ----------------------------------------------------------------------------------
                                      month_recs(l_payroll_mon_counter).month := to_number(to_char(fnd_date.canonical_to_date(month_year_action_rec.date_earned),'MM'));
                                     l_payroll_mon_counter := l_payroll_mon_counter+1;
                                     ----------------------------------------------------------------------------------
                                     -- Bulk Balance Fetch for Bug 3064282
                                     ----------------------------------------------------------------------------------
                                     g_balance_value_tab.delete;
                                     g_context_tab.delete;
                                     g_detailed_bal_out_tab.delete;
                                     --
                                     for counter in 1..t_month_balanceid_store.count
                                     loop
                                           g_balance_value_tab(counter).defined_balance_id := t_month_balanceid_store(counter).defined_balance_id;
                                           g_context_tab(counter).tax_unit_id := month_year_action_rec.tax_uid;
                                     end loop;
                                     ----------------------------------------------------------------------------------
                                     -- Bug 3223822 - Modified call to the function pay_balance_pkg.get_value
                                     ----------------------------------------------------------------------------------
                                     pay_balance_pkg.get_value( month_year_action_rec.assact_id,
                                                                g_balance_value_tab,
                                                                g_context_tab,
                                                                false,
                                                                false,
                                                                g_detailed_bal_out_tab );
                                     --
                                     if duplicate_exists = 'N' then  /* Bug 3162955 */
                                           for counter in 1..t_month_balanceid_store.count
                                           loop
                                                if t_month_balanceid_store.exists(counter) then
                                                        t_user_entity_id(l_arch_counter) := t_month_balanceid_store(counter).user_entity_id;
                                                        t_archive_value(l_arch_counter)  := nvl(g_detailed_bal_out_tab(counter).balance_value,0);
                                                        t_date_earned(l_arch_counter)    := month_year_action_rec.date_earned;
                                                        l_arch_counter                   := l_arch_counter + 1;
                                                end if;
                                           end loop;
                                     else
                                           --------------------------------------------------------------------------
                                           -- Bug 3162955 - In case of Rechire with new employee number
                                           -- store the employee details in mtd_balance_rec table without archiving.
                                           --------------------------------------------------------------------------
                                           l_mtd_counter := mtd_balance_rec.count + 1;
                                           for counter in 1..t_month_balanceid_store.count
                                           loop
                                                mtd_balance_rec(l_mtd_counter).balance_id          := t_month_balanceid_store(counter).user_entity_id;
                                                mtd_balance_rec(l_mtd_counter).balance_value       := nvl(g_detailed_bal_out_tab(counter).balance_value,0);
                                                mtd_balance_rec(l_mtd_counter).date_earned         := to_char(fnd_date.canonical_to_date(month_year_action_rec.date_earned),'MMYYYY');
                                                mtd_balance_rec(l_mtd_counter).date_earned_archive := month_year_action_rec.date_earned;
                                                mtd_balance_rec(l_mtd_counter).person_id           := person_id_rec(l_person_counter).person_id;
                                                mtd_balance_rec(l_mtd_counter).archive_status      := 'Y';
                                                l_mtd_counter := l_mtd_counter + 1;
                                           end loop;
                                     end if;
                              end if;
                              close month_year_action;
                        end loop;
                        --
                        close month_year_action_sequence;
                        ----------------------------------------------------------------------------------
                        -- Bulk Balance Fetch for Bug 3064282
                        ----------------------------------------------------------------------------------
                        g_balance_value_tab.delete;
                        g_context_tab.delete;
                        g_detailed_bal_out_tab.delete;

                        --
                        for counter in 1..t_ytd_balanceid_store.count
    	                loop
 	                      g_balance_value_tab(counter).defined_balance_id := t_ytd_balanceid_store(counter).defined_balance_id;
                          g_context_tab(counter).tax_unit_id := month_year_action_rec.tax_uid;
                        end loop;

                        ----------------------------------------------------------------------------------
                        -- Bug 3223822 - Modified call to the function pay_balance_pkg.get_value
                        -- Bug 3430277 - Put a condition before function pay_balance_pkg.get_value call.
                        ----------------------------------------------------------------------------------
                        if  month_year_action_rec.assact_id is not null then
                              pay_balance_pkg.get_value( month_year_action_rec.assact_id,
                                                         g_balance_value_tab,
                                                         g_context_tab,
                                                         false,
                                                         false,
                                                         g_detailed_bal_out_tab );
                        end if;

                        ----------------------------------------------------------------------------------
                        -- Bug 3249043 - v_run_ass_action_id is initialized to latest persion assact_id
                        -- Assign here so cursor variable can be accessed outside of loop
                        -- Bug# 3328760 - Added g_detailed_bal_out_tab.exists(counter) check
                        ----------------------------------------------------------------------------------
                        for counter in 1..t_ytd_balanceid_store.count
                        loop
                              if l_person_counter = 1 then
                                   if g_detailed_bal_out_tab.exists(counter) then
                                          ytd_balance_rec(counter).balance_id    := t_ytd_balanceid_store(counter).user_entity_id;
                                          ytd_balance_rec(counter).balance_value := nvl(g_detailed_bal_out_tab(counter).balance_value,0) ;
                                          v_run_ass_action_id                    := month_year_action_rec.assact_id;
                                   end if;
                              else
                                   if g_detailed_bal_out_tab.exists(counter) then
                                          if ytd_balance_rec.exists(counter) then
                                                 ytd_balance_rec(counter).balance_value := nvl(g_detailed_bal_out_tab(counter).balance_value,0)
                                                                                     + ytd_balance_rec(counter).balance_value;
                                          end if;
                                   end if;
                              end if;
                        end loop;
                        --
                        --
                        ------------------------------------------------------------------------------------
                        -- Bug#3501927 A8A usablity
                        -- Bug#3933332 Added one more flag g_org_a8a_flag to check if a8a is applicable.
                        -------------------------------------------------------------------------------------
                        if  month_year_action_rec.assact_id is NOT NULL and g_org_a8a_flag ='Y' then
                               a8a_balances_value( person_id_rec(l_person_counter).person_id,
                                                   month_year_action_rec.assact_id,
                                                   month_year_action_rec.tax_uid,
                                                   l_person_counter );
                        end if;
                        --
                        g_balance_value_tab.delete;
	                g_detailed_bal_out_tab.delete;
                  end if;
                  ------------------------------------------------------------------------------------------------
                  -- Bug# 2858074 - Remove the values in the cursor variables and assign the variables to NULL
                  -- so that these variables will be populated with values in the next loop
                  -- Bug# 3328760 - These conditions are moved inside loop.
                  ------------------------------------------------------------------------------------------------
                  month_year_action_sequence_rec.act_seq := null;
                  month_year_action_rec.assact_id        := null;
                  --
              end loop ;
         end if;
         ------------------------------------------------------------------------------------------------
         -- Bug 3162955  Month Balance Implementation
         -- Bug 3162955 - Check whether multiple runs in a month exists for the OCBC rehired employee,
         -- If there exists multiple runs then sum the balances for the month
         -- and then archive the month details only once
         ------------------------------------------------------------------------------------------------
         if duplicate_exists = 'Y' then
              for counter in 1 .. mtd_balance_rec.count
              loop
                  for icounter in 1 .. mtd_balance_rec.count
                  loop
	                if  mtd_balance_rec(counter).balance_id  = mtd_balance_rec(icounter).balance_id  and
		                mtd_balance_rec(counter).date_earned = mtd_balance_rec(icounter).date_earned and
                                mtd_balance_rec(counter).person_id   <> mtd_balance_rec(icounter).person_id  and
                                mtd_balance_rec(counter).archive_status = 'Y' then
                                mtd_balance_rec(counter).balance_value := mtd_balance_rec(counter).balance_value
                                                                       +  mtd_balance_rec(icounter).balance_value;
                                mtd_balance_rec(icounter).archive_status := 'N';
                        end if;
                  end loop;
              end loop;
              --
              if t_user_entity_id.count >= 0 then
                  l_arch_counter := t_user_entity_id.count + 1;
              else
                  l_arch_counter := 1;
              end if;
              --
              for counter in 1 .. mtd_balance_rec.count
              loop
                  if mtd_balance_rec(counter).archive_status = 'Y' then
                        t_user_entity_id(l_arch_counter) := mtd_balance_rec(counter).balance_id;
                        t_archive_value(l_arch_counter)  := nvl(mtd_balance_rec(counter).balance_value,0);
                        t_date_earned(l_arch_counter)    := mtd_balance_rec(counter).date_earned_archive;
                        l_arch_counter := l_arch_counter + 1;
                  end if;
              end loop;
         end if;
         ------------------------------------------------------------------------------------------------
         -- Bug 3038605 - Added the following code to archive balances with 0 values for months with no payroll runs
         -- Logic Used:
         -- Search the pl/sql table month_recs to see if the specified month is already archived.
         -- a) If not archived then archive months details with 0 amounts.
         -- b) Else reset the flag l_pmon_counter and search for next months
         ------------------------------------------------------------------------------------------------
         for i in 1..12
         loop
              ----------------------------------------------------------------------------------------------
              -- Search if specified months is already archived
              -- Bug 3205321 - Compare month with variable i instead of MON format from lookup MONTH_CODE.
              ----------------------------------------------------------------------------------------------
              for j in 1..l_payroll_mon_counter-1
              loop
                    if month_recs(j).month = i then
                           l_pmon_counter := true;
                    end if;
              end loop;
              --
              if l_pmon_counter = false then
                     -------------------------------------------------------------------------------------------
                     -- Archive 0 balance amounts as there are no runs in this perticular month
                     -------------------------------------------------------------------------------------------
                     if t_user_entity_id.count >= 0 then
                           l_arch_counter := t_user_entity_id.count + 1;
                     else
                           l_arch_counter := 1;
                     end if;
                     --
                     per_le_mtd_bal := 0;
                     --
                     for counter in 1..t_month_balanceid_store.count
                     loop
                          if t_month_balanceid_store.exists(counter) then
                                t_user_entity_id(l_arch_counter) := t_month_balanceid_store(counter).user_entity_id;
                                t_archive_value(l_arch_counter)  := per_le_mtd_bal;
                                t_date_earned(l_arch_counter)    := to_char(last_day(to_date('01-'||to_char(i)||'-'||p_basis_year,'DD-MM-YYYY')),'YYYY/MM/DD HH:MM:SS');
                                l_arch_counter := l_arch_counter + 1;
                          end if;
                     end loop;
              else
                     l_pmon_counter := false;
              end if;
         end loop;
         ------------------------------------------------------------------------------------------------
         -- Bug: 3260855 Bulk Insert into ff_archive_items for month balances
         ------------------------------------------------------------------------------------------------
         select context_id
         into   l_asac_cont_id
         from   ff_contexts
         where  context_name = 'ASSIGNMENT_ACTION_ID' ;
         --
         select context_id
         into   l_tax_cont_id
         from   ff_contexts
         where  context_name = 'TAX_UNIT_ID' ;
         --
         select context_id
         into   l_date_cont_id
         from   ff_contexts
         where  context_name = 'DATE_EARNED' ;
         --
         forall counter in 1..t_user_entity_id.count
               insert into ff_archive_items
                 ( archive_item_id,
                   user_entity_id,
                   context1,
                   value,
                   archive_type )
               values
                 ( ff_archive_items_s.nextval,
                   t_user_entity_id(counter),
                   p_assignment_action_id,
                   t_archive_value(counter),
                   'AAP' )
         returning archive_item_id bulk collect into t_archive_items ;
         --
         forall counter in t_archive_items.first..t_archive_items.last
               insert into ff_archive_item_contexts
                 ( archive_item_id,
                   sequence_no,
                   context,
                   context_id )
               values
                 ( t_archive_items(counter),
                   1,
                   p_assignment_action_id,
                   l_asac_cont_id );
         --
         forall counter in t_archive_items.first..t_archive_items.last
               insert into ff_archive_item_contexts
                 ( archive_item_id,
                   sequence_no,
                   context,
                   context_id )
               values
                 ( t_archive_items(counter),
                   2,
                   p_tax_unit_id,
                   l_tax_cont_id );
         --
         forall counter in t_archive_items.first..t_archive_items.last
               insert into ff_archive_item_contexts
                 ( archive_item_id,
                   sequence_no,
                   context,
                   context_id )
               values
                 ( t_archive_items(counter),
                   3,
                   t_date_earned(counter),
                   l_date_cont_id );
         --
         t_archive_items.delete;
         t_user_entity_id.delete;
         t_archive_value.delete;
         t_date_earned.delete;
         l_arch_counter := 1;
         --
         for counter  in 1..ytd_balance_rec.count
         loop
              if ytd_balance_rec.exists(counter) then
                   t_user_entity_id(l_arch_counter) := ytd_balance_rec(counter).balance_id;
                   t_archive_value(l_arch_counter)  := ytd_balance_rec(counter).balance_value;
                   l_arch_counter := l_arch_counter + 1;
              end if;
         end loop;
         ---------------------------------------------------------------------------------------------------
         -- Bug# 3501927  A8A_USABLITY
         ---------------------------------------------------------------------------------------------------
         --Bug#3933332
         if  g_org_a8a_flag ='Y' then
         --
           for counter  in 1..ytd_a8a_balance_rec.count
           loop
              if ytd_a8a_balance_rec.exists(counter) then
                   t_user_entity_id(l_arch_counter) := ytd_a8a_balance_rec(counter).balance_id;
                   t_archive_value(l_arch_counter)  := ytd_a8a_balance_rec(counter).balance_value;
                   l_arch_counter                   := l_arch_counter + 1;
              end if;
           end loop;
         --
         end if;
         ------------------------------------------------------------------------------------------------
         -- Bug: 3260855 - Bulk Insert into ff_archive_items for ytd balances
         ------------------------------------------------------------------------------------------------
         forall counter in 1..t_user_entity_id.count
               insert into ff_archive_items
                 ( archive_item_id,
                   user_entity_id,
                   context1,
                   value,
                   archive_type )
               values
                 ( ff_archive_items_s.nextval,
                   t_user_entity_id(counter),
                   p_assignment_action_id,
                   t_archive_value(counter),
                   'AAP' )
         returning archive_item_id bulk collect into t_archive_items ;
         --
         forall counter in t_archive_items.first..t_archive_items.last
               insert into ff_archive_item_contexts
                 ( archive_item_id,
                   sequence_no,
                   context,
                   context_id )
               values
                 ( t_archive_items(counter),
                   1,
                   p_assignment_action_id,
                   l_asac_cont_id );
         --
         forall counter in t_archive_items.first..t_archive_items.last
               insert into ff_archive_item_contexts
                 ( archive_item_id,
                   sequence_no,
                   context,
                   context_id )
               values
                 ( t_archive_items(counter),
                   2,
                   p_tax_unit_id,
                   l_tax_cont_id );
         ------------------------------------------------------------------------------------------------
         -- Bug# 2833530 - Added p_person_id as the parameter for the archive_balance_dates for the
         -- employees having terminated and rehired in the same financial year
         ------------------------------------------------------------------------------------------------
         archive_balance_dates ( p_person_id,
                                 p_basis_year,
                                 p_business_group_id,
                                 p_assignment_action_id,
                                 v_run_ass_action_id,
                                 p_tax_unit_id );
         if g_debug then
               hr_utility.set_location('pysgirar: End of archive_balances',100);
         end if;
     end archive_balances;
     ---------------------------------------------------------------------------
     -- Copies the standard balance route code, but instead of selecting the run
     -- result value, selects the date_earned.
     -- Bug#2833530
     -- bug 2724020
     ---------------------------------------------------------------------------
     procedure archive_balance_dates
      (  p_person_id             in  per_all_people_f.person_id%TYPE,
         p_basis_year            in  varchar2,
         p_business_group_id     in  hr_organization_units.business_group_id%type,
         p_assignment_action_id  in  pay_assignment_actions.assignment_action_id%type,
         p_run_ass_action_id     in  pay_assignment_actions.assignment_action_id%type,
         p_tax_unit_id           in  pay_assignment_actions.tax_unit_id%type )
     is
     --
         v_date_from           ff_archive_items.value%type;
         v_date_to             ff_archive_items.value%type;
         v_no_of_times         number;
         v_date_from_old       ff_archive_items.value%type;
         v_date_to_old         ff_archive_items.value%type;
         v_no_of_times_old     number;
         v_no_of_times_411     number;
         v_no_of_times_413     number;
         v_265_indicator       varchar2(1);
         v_moa_410_date        ff_archive_items.value%type;
         v_moa_411_date        ff_archive_items.value%type;
         v_moa_413_date        ff_archive_items.value%type;
         l_terminated          varchar2(1);
         l_prev_ass_id         per_all_assignments_f.assignment_id%TYPE;
         l_new_ass_id          per_all_assignments_f.assignment_id%TYPE;
         l_run_ass_action_id   pay_assignment_actions.assignment_action_id%TYPE;
         l_term_max_assact_id  pay_assignment_actions.assignment_action_id%TYPE;
         l_person_id           per_all_people_f.person_id%type;
         v_person_id           per_all_people_f.person_id%type;

         ---------------------------------------------------------------------------
         -- Bug# 2833530
         -- Added check_termination and get_max_assactid cursors
         -- Bug# 2920732 - Modified the cursor to use secured views per_people_f, per_assignments_f
         ---------------------------------------------------------------------------
         cursor check_termination(  c_person_id per_all_people_f.person_id%TYPE,
                                    c_basis_year varchar2 )
         is
         select  'Y',
                 oldpaaf.assignment_id,
                 newpaaf.assignment_id
         from    per_people_f pap,
                 per_assignments_f oldpaaf,
                 per_assignments_f newpaaf
         where  pap.person_id = c_person_id
         and    pap.person_id = oldpaaf.person_id
         and    oldpaaf.person_id = newpaaf.person_id
         and    oldpaaf.assignment_type = 'E' /* Bug 5033609 */
         and    newpaaf.assignment_type = 'E' /* Bug 5033609 */
         and    oldpaaf.assignment_id <> newpaaf.assignment_id
         and    oldpaaf.effective_end_date between to_date('01-01-'||c_basis_year,'DD-MM-YYYY')
                                               and newpaaf.effective_start_date
         and    newpaaf.effective_start_date between  oldpaaf.effective_end_date
                                                 and to_date('31-12-'||c_basis_year,'DD-MM-YYYY');
         ---------------------------------------------------------------------------
         -- Bug# 2920732 - Modified the cursor to use secured view per_assignments_f
         ---------------------------------------------------------------------------
         cursor get_max_assactid( c_prev_ass_id per_all_assignments_f.assignment_id%TYPE ,
                                  c_basis_year varchar2,
                                  c_tax_unit_id pay_assignment_actions.tax_unit_id%type,
                                  c_business_group_id hr_organization_units.business_group_id%type )
         is
         select  assact1.assignment_action_id
         from    pay_assignment_actions assact1,
                 pay_payroll_actions pact1,
                 per_assignments_f paaf1
         where   assact1.tax_unit_id = c_tax_unit_id
         and     paaf1.assignment_id = c_prev_ass_id
         and     paaf1.assignment_id = assact1.assignment_id
         and     pact1.payroll_action_id = assact1.payroll_action_id
         and     paaf1.business_group_id = c_business_group_id
         and     pact1.action_status = 'C'
         and     assact1.action_sequence =
                      (  select  max(assact.action_sequence)
                         from    pay_assignment_actions assact,
        	                 pay_payroll_actions pact,
                                 per_assignments_f paaf
                         where   paaf.assignment_id = paaf1.assignment_id
                         and     paaf.assignment_id = assact.assignment_id
                         and     pact.payroll_action_id = assact.payroll_action_id
                         and     paaf.business_group_id = paaf1.business_group_id
                         and     assact.tax_unit_id = assact1.tax_unit_id
                         and     pact.action_type in ('Q','R','B')
                         and     pact.action_status = 'C'
                         and     pact.effective_date between to_date('01-01-'||c_basis_year,'DD-MM-YYYY')
                                                         and to_date('31-12-'||c_basis_year,'DD-MM-YYYY'));

      -----------------------------------------------------------------------------------------
         ---Bug#3956870 Function  uses run balances to fetch balance details if they are valid
         -------------------------------------------------------------------------------------------
         --
         procedure get_balance_dates ( p_asg_action_id         in   pay_assignment_actions.assignment_action_id%type,
                                       p_tax_unit_id           in   pay_assignment_actions.tax_unit_id%type,
                                       p_balance_name          in   pay_balance_types.balance_name%type,
                                       p_business_group_id     in   hr_organization_units.business_group_id%type,
                                       p_date_from             out  nocopy  ff_archive_items.value%type,
                                       p_date_to               out  nocopy  ff_archive_items.value%type,
                                       p_no_of_times           out  nocopy  number )
         is
           c_def_balance_id       pay_defined_balances.defined_balance_id%type;
           c_run_balance_status   pay_balance_validation.run_balance_status%type ;

           --
           cursor balance_dates_rr
           is
           select  fnd_date.date_to_canonical(min(pact.date_earned)) date_from,
                   fnd_date.date_to_canonical(max(pact.date_earned)) date_to,
                   sum(decode(pact.action_type,'V',-1,1))            no_of_times
           from    pay_run_result_values   target,
                   pay_balance_feeds_f     feed,
                   pay_balance_types       pbt,
                   pay_run_results         rr,
                   pay_assignment_actions  assact,
                   pay_assignment_actions  bal_assact,
                   pay_payroll_actions     pact,
                   pay_payroll_actions     bact,
                   per_assignments_f       ass
           where   bal_assact.assignment_action_id = p_asg_action_id
           and     bal_assact.payroll_action_id = bact.payroll_action_id
           and     feed.balance_type_id = pbt.balance_type_id + decode(target.input_value_id,null,0,0)
           and     pbt.legislation_code = 'SG'
           and     pbt.balance_name = p_balance_name
           and     feed.input_value_id = target.input_value_id
           and     nvl(target.result_value, '0') <> '0'
           and     target.run_result_id = rr.run_result_id
           and     rr.assignment_action_id = assact.assignment_action_id
           and     assact.payroll_action_id = pact.payroll_action_id
           and     pact.effective_date between feed.effective_start_date and feed.effective_end_date
           and     rr.status in ('P','PA')
           and     assact.action_sequence <= bal_assact.action_sequence
           and     assact.assignment_id = ass.assignment_id
           and     bal_assact.assignment_id = assact.assignment_id /* added the join for bug#2227759 */
           and     exists ( select  null
                          from    per_assignments_f start_ass
                          where   start_ass.assignment_id = bal_assact.assignment_id
                          and     person_id = ass.person_id )
           and    pact.effective_date between ass.effective_start_date and ass.effective_end_date
           and    assact.tax_unit_id = p_tax_unit_id
           and    pact.effective_date >= trunc(bact.effective_date,'Y');
           --
           cursor balance_dates_rb
           is
           select fnd_date.date_to_canonical(min(prb.effective_date)) date_from,
                  fnd_date.date_to_canonical(max(prb.effective_date)) date_to,
                  sum(decode(ppa.action_type,'V',-1,1))         no_of_times
           from   pay_run_balances        prb,
                  pay_assignment_actions  ASSACT,
                  pay_payroll_actions     PACT,
                  per_assignments_f       ass,
                  pay_payroll_actions     ppa,
                  pay_assignment_actions  paa
           where  prb.defined_balance_id       = c_def_balance_id
           and    assact.assignment_action_id  = p_asg_action_id
           and    assact.payroll_action_id     = pact.payroll_action_id
           and    prb.assignment_action_id     = paa.assignment_action_id
       	   and    ppa.payroll_action_id        = paa.payroll_action_id
           and    prb.action_sequence         <= assact.action_sequence
           and    prb.effective_date          <= pact.effective_date
           and    prb.balance_value <> 0
           and    ASS.person_id = (select person_id
                                   from per_assignments_f START_ASS
                                   where START_ASS.assignment_id   = assact.assignment_id
                                   and rownum = 1)
           and    prb.effective_date between ASS.effective_start_date
                                       and ASS.effective_end_date
           and    prb.assignment_id = ass.assignment_id
           and    prb.tax_unit_id              = p_tax_unit_id
           and    prb.effective_date >= trunc(PACT.effective_date,'Y');

           ------
           -- 3956870 Included get_balance_id, get_balance_status cursors to fetch balance id and status details.
           ------
           cursor get_balance_id(c_balance_name pay_balance_types.balance_name%type)
           is
           select  pdb.defined_balance_id
           from    pay_defined_balances pdb,
                   pay_balance_types pbt,
                   pay_balance_dimensions pbd
            where  pbt.balance_name         = c_balance_name
            and    pbd.dimension_name       = '_ASG_LE_RUN'
            and    pbt.balance_type_id      = pdb.balance_type_id
            and    pbd.balance_dimension_id = pdb.balance_dimension_id
            and    pdb.legislation_code     = 'SG'
            and    pbt.legislation_code     = 'SG'
            and    pbd.legislation_code     = 'SG';

            --
            cursor get_balance_status(c_def_balance_id pay_defined_balances.defined_balance_id%type,
                                      c_business_group_id hr_organization_units.business_group_id%type )
            is
            select  run_balance_status
            from    pay_balance_validation
            where   defined_balance_id =  c_def_balance_id
            and     business_group_id  =  c_business_group_id;
            --
         begin
           open   get_balance_id(p_balance_name);
           fetch  get_balance_id into c_def_balance_id;
           close  get_balance_id;
           --
           begin
         -------------------------------------------------------------------------------------------
         ---Bug#3956870 Balance status details are stored in the PL/SQL table t_bal_stat_rec
         -------------------------------------------------------------------------------------------
                    c_run_balance_status := 'U';
                    if t_bal_stat_rec.count > 0 then
                       for l_dup_count in t_bal_stat_rec.first..t_bal_stat_rec.last
                       loop
                         if ( p_business_group_id = t_bal_stat_rec(l_dup_count).business_group_id and
                            c_def_balance_id = t_bal_stat_rec(l_dup_count).defined_balance_id )  then
                              c_run_balance_status :=  t_bal_stat_rec(l_dup_count).run_balance_status;
                              exit ;
                         end if;
                       end loop;
                    end if;
        ---------------------------------------------------------------------------------------------
        -- Bug# 3956870 c_run_balance_status will remain as 'U' if the balance status information is not
        -- present in the PL/SQL table t_bal_stat_rec
        ---------------------------------------------------------------------------------------------
                    if c_run_balance_status = 'U' then
                        open   get_balance_status(c_def_balance_id,p_business_group_id);
                        fetch  get_balance_status into c_run_balance_status;
                        close  get_balance_status;
                        l_counter :=  t_bal_stat_rec.count + 1;
                        t_bal_stat_rec(l_counter).business_group_id  := p_business_group_id;
                        t_bal_stat_rec(l_counter).defined_balance_id := c_def_balance_id;
                        t_bal_stat_rec(l_counter).run_balance_status := c_run_balance_status;
                    end if;
            exception
                when others then
                        c_run_balance_status := 'I' ;
           end;

           --
           if   c_run_balance_status = 'V' then
                open   balance_dates_rb;
                fetch  balance_dates_rb into p_date_from, p_date_to, p_no_of_times ;
                close  balance_dates_rb;
           else
                open   balance_dates_rr;
                fetch  balance_dates_rr into p_date_from, p_date_to, p_no_of_times ;
                close  balance_dates_rr;

           end if;
           --
       end get_balance_dates;
       --
       --
     begin
     if g_debug then
              hr_utility.set_location('pysgirar: Start of archive_balance_dates',10);
     end if;
         ---------------------------------------------------------------------------------------
         -- Bug 2843586. Added v_no_of_times>0 check along with
         -- balance_dates%found check for all the below balances
         -- Archive IR8A_MOA_265 dates and indicator
         -- Bug#2833530
         -- Bug#3933332  Removed check g_rehire_same_person_table.exists(p_person_id)
         --              as after enhencement 3435334 this check is not required.
         ---------------------------------------------------------------------------------------
              v_person_id := p_person_id;
              ----------------------------------------------------------------------------------
              -- Bug 3435334 Table g_person_id_tab is populated with duplicate records for current person
              -- in employee_if_latest() function
              ----------------------------------------------------------------------------------
              if g_person_id_tab.count > 1 then
                    v_person_id := g_person_id_tab.last;
              end if;
              --
              open  check_termination( v_person_id, p_basis_year );
              fetch check_termination into l_terminated, l_prev_ass_id, l_new_ass_id;
              close check_termination;
              --
              if l_terminated = 'Y' then
                   open  get_max_assactid( l_prev_ass_id, p_basis_year, p_tax_unit_id, p_business_group_id );
                   fetch get_max_assactid into l_term_max_assact_id;
                   close get_max_assactid;
                   ---------------------------------------------------------------------------
                   --  Bug#3956870
                   ----------------------------------------------------------------------------
                   get_balance_dates ( p_run_ass_action_id,
                                       p_tax_unit_id,
                                       'IR8A_MOA_265',
                                       p_business_group_id,
                                       v_date_from ,
                                       v_date_to ,
                                       v_no_of_times);
                   --
                   get_balance_dates ( l_term_max_assact_id,
                                       p_tax_unit_id,
                                       'IR8A_MOA_265',
                                       p_business_group_id,
                                       v_date_from_old ,
                                       v_date_to_old ,
                                       v_no_of_times_old);
                   --------------------------------------------------------------------------
                   if v_date_from is null and v_date_to is null then
                         v_date_from := v_date_from_old;
                         v_date_to   := v_date_to_old;
                   elsif v_date_from_old is not null then
                         v_date_from := v_date_from_old;
                   end if;
                   --
                   v_no_of_times := nvl(v_no_of_times,0) + nvl(v_no_of_times_old,0);
              else
                   ---------------------------------------------------------------------------
                   --  Bug#3956870
                   ----------------------------------------------------------------------------
                   get_balance_dates ( p_run_ass_action_id,
                                       p_tax_unit_id,
                                       'IR8A_MOA_265',
                                       p_business_group_id,
                                       v_date_from ,
                                       v_date_to ,
                                       v_no_of_times);
              end if;
              ---------------------------------------------------------------------------------------
              --  Bug 2651294
              ---------------------------------------------------------------------------------------
              if (v_no_of_times = 1) then
                   v_265_indicator := 'O';
              elsif (v_no_of_times >= 12) then
                   v_265_indicator := 'M';
              else
                   v_265_indicator := 'B';
              end if;
              ---------------------------------------------------------------------------------------
              -- Bug#2843586. Archive dates only if v_no_of_times is greater then zero
              ---------------------------------------------------------------------------------------
              if v_no_of_times > 0 then
                   archive_item ('X_IR8A_MOA_265_DATE_FROM', p_assignment_action_id, v_date_from);
                   archive_item ('X_IR8A_MOA_265_DATE_TO', p_assignment_action_id, v_date_to);
                   archive_item ('X_IR8A_MOA_265_INDICATOR', p_assignment_action_id, v_265_indicator);
              end if;
              --------------------------------------------------------------------------------------
              -- Archive IR8A_MOA_369 dates
              --------------------------------------------------------------------------------------
              if l_terminated = 'Y' then
                   ---------------------------------------------------------------------------
                   --  Bug#3956870
                   ----------------------------------------------------------------------------
                   get_balance_dates ( p_run_ass_action_id,
                                       p_tax_unit_id,
                                       'IR8A_MOA_369',
                                       p_business_group_id,
                                       v_date_from ,
                                       v_date_to ,
                                       v_no_of_times);
                   ------------------------------------------------------------------------------
                   if v_date_from is null and v_date_to is null then
                   ---------------------------------------------------------------------------
                   --  Bug#3956870
                   ----------------------------------------------------------------------------
                     get_balance_dates ( l_term_max_assact_id,
                                         p_tax_unit_id,
                                        'IR8A_MOA_369',
                                         p_business_group_id,
                                         v_date_from ,
                                         v_date_to ,
                                         v_no_of_times);
                   ------------------------------------------------------------------------------

                   end if;
              else
                   ---------------------------------------------------------------------------
                   --  Bug#3956870
                   ----------------------------------------------------------------------------
                   get_balance_dates ( p_run_ass_action_id,
                                       p_tax_unit_id,
                                       'IR8A_MOA_369',
                                       p_business_group_id,
                                       v_date_from ,
                                       v_date_to ,
                                       v_no_of_times);
                   ------------------------------------------------------------------------------
              end if;
              --
              -- Bug 5078454, to store the date of balane 369 has into a
              -- global value

              if v_date_to is not null and v_no_of_times > 0 then
                   g_moa_369_date := v_date_to;
              end if;
              --------------------------------------------------------------------------------------
              -- Archive IR8A_MOA_340 dates
	      --------------------------------------------------------------------------------------
              if l_terminated = 'Y' then
                   ---------------------------------------------------------------------------
                   --  Bug#3956870
                   ----------------------------------------------------------------------------
                   get_balance_dates ( p_run_ass_action_id,
                                       p_tax_unit_id,
                                       'IR8A_MOA_340',
                                       p_business_group_id,
                                       v_date_from ,
                                       v_date_to ,
                                       v_no_of_times);
                   ------------------------------------------------------------------------------
                   if v_date_from is null and v_date_to is null then
                       ---------------------------------------------------------------------------
                       --  Bug#3956870
                       ----------------------------------------------------------------------------
                       get_balance_dates ( l_term_max_assact_id,
                                           p_tax_unit_id,
                                          'IR8A_MOA_340',
                                           p_business_group_id,
                                           v_date_from ,
                                           v_date_to ,
                                           v_no_of_times);
                       ------------------------------------------------------------------------------
                   end if;
              else
                   ---------------------------------------------------------------------------
                   --  Bug#3956870
                   ----------------------------------------------------------------------------
                    get_balance_dates ( p_run_ass_action_id,
                                        p_tax_unit_id,
                                       'IR8A_MOA_340',
                                        p_business_group_id,
                                        v_date_from ,
                                        v_date_to ,
                                        v_no_of_times);
                    ------------------------------------------------------------------------------

              end if;
              --
              if v_date_to is not null and v_no_of_times > 0 then
                   archive_item ('X_IR8A_MOA_340_DATE', p_assignment_action_id, v_date_to);
              end if;
              --------------------------------------------------------------------------------------
              -- Archive Additional Earnings dates
              --------------------------------------------------------------------------------------
              if l_terminated = 'Y' then
                   ---------------------------------------------------------------------------
                   --  Bug#3956870
                   ----------------------------------------------------------------------------
                    get_balance_dates ( p_run_ass_action_id,
                                        p_tax_unit_id,
                                        'Additional Earnings',
                                        p_business_group_id,
                                        v_date_from ,
                                        v_date_to ,
                                        v_no_of_times);
                    ------------------------------------------------------------------------------
                   if v_date_from is null and v_date_to is null then
                       ---------------------------------------------------------------------------
                       --  Bug#3956870
                       ----------------------------------------------------------------------------
                       get_balance_dates ( l_term_max_assact_id,
                                           p_tax_unit_id,
                                          'Additional Earnings',
                                           p_business_group_id,
                                           v_date_from ,
                                           v_date_to ,
                                           v_no_of_times);
                       ------------------------------------------------------------------------------
                   end if;
              else
                   ---------------------------------------------------------------------------
                   --  Bug#3956870
                   ----------------------------------------------------------------------------
                   get_balance_dates ( p_run_ass_action_id,
                                       p_tax_unit_id,
                                      'Additional Earnings',
                                       p_business_group_id,
                                       v_date_from ,
                                       v_date_to ,
                                       v_no_of_times);
                   ------------------------------------------------------------------------------

              end if;
              --
              if v_date_to is not null and v_no_of_times > 0 then
                   archive_item ('X_ADDITIONAL_EARNINGS_DATE', p_assignment_action_id, v_date_to);
              end if;
              --------------------------------------------------------------------------------------
              --  Start new code for bug 2724020
              -- Bug No : 2724020 - archive IR8S_MOA_410 balance dates
              -- Modified for Bug 3095823 replaced v_date_to with v_moa_410_date
              --------------------------------------------------------------------------------------
              if l_terminated = 'Y' then
                   ---------------------------------------------------------------------------
                   --  Bug#3956870
                   ----------------------------------------------------------------------------
                   get_balance_dates ( p_run_ass_action_id,
                                       p_tax_unit_id,
                                      'IR8S_MOA_410',
                                       p_business_group_id,
                                       v_date_from ,
                                       v_moa_410_date ,
                                       v_no_of_times);
                   ------------------------------------------------------------------------------
                   if v_date_from is null and v_moa_410_date is null then
                         ---------------------------------------------------------------------------
                         --  Bug#3956870
                         ----------------------------------------------------------------------------
                         get_balance_dates ( l_term_max_assact_id,
                                             p_tax_unit_id,
                                            'IR8S_MOA_410',
                                             p_business_group_id,
                                             v_date_from ,
                                             v_moa_410_date ,
                                             v_no_of_times);
                         ------------------------------------------------------------------------------
                   end if;
              else
                   ---------------------------------------------------------------------------
                   --  Bug#3956870
                   ----------------------------------------------------------------------------
                   get_balance_dates (  p_run_ass_action_id,
                                        p_tax_unit_id,
                                       'IR8S_MOA_410',
                                        p_business_group_id,
                                        v_date_from ,
                                        v_moa_410_date ,
                                        v_no_of_times);
                   ------------------------------------------------------------------------------

              end if;
              --
              if v_moa_410_date is not null and v_no_of_times > 0 then
                   archive_item ('X_IR8S_MOA_410_DATE', p_assignment_action_id, v_moa_410_date);
              end if;
              --------------------------------------------------------------------------------------
              -- Start new code for bug 2724020
              -- Archive IR8S_MOA_411 dates
              --------------------------------------------------------------------------------------
              if l_terminated = 'Y' then
                   ---------------------------------------------------------------------------
                   --  Bug#3956870
                   ----------------------------------------------------------------------------
                   get_balance_dates (  p_run_ass_action_id,
                                        p_tax_unit_id,
                                       'IR8S_MOA_411',
                                        p_business_group_id,
                                        v_date_from ,
                                        v_moa_411_date ,
                                        v_no_of_times_411);
                   ------------------------------------------------------------------------------
                   if v_date_from is null and v_moa_411_date is null then
                       ---------------------------------------------------------------------------
                       --  Bug#3956870
                       ----------------------------------------------------------------------------
                       get_balance_dates (  l_term_max_assact_id,
                                            p_tax_unit_id,
                                           'IR8S_MOA_411',
                                            p_business_group_id,
                                            v_date_from ,
                                            v_moa_411_date ,
                                            v_no_of_times_411);
                       ------------------------------------------------------------------------------
                   end if;
              else
                   ---------------------------------------------------------------------------
                   --  Bug#3956870
                   ----------------------------------------------------------------------------
                   get_balance_dates (  p_run_ass_action_id,
                                        p_tax_unit_id,
                                       'IR8S_MOA_411',
                                        p_business_group_id,
                                        v_date_from ,
                                        v_moa_411_date ,
                                        v_no_of_times_411);
                   ------------------------------------------------------------------------------
              end if;
              --------------------------------------------------------------------------------------
              -- Archive IR8S_MOA_412 dates
              --------------------------------------------------------------------------------------
              if l_terminated = 'Y' then
                   ---------------------------------------------------------------------------
                   --  Bug#3956870
                   ----------------------------------------------------------------------------
                   get_balance_dates (  p_run_ass_action_id,
                                        p_tax_unit_id,
                                       'IR8S_MOA_412',
                                        p_business_group_id,
                                        v_date_from ,
                                        v_date_to ,
                                        v_no_of_times);
                   ------------------------------------------------------------------------------
                   if v_date_from is null and v_date_to is null then
                        ---------------------------------------------------------------------------
                        --  Bug#3956870
                        ----------------------------------------------------------------------------
                        get_balance_dates (  l_term_max_assact_id,
                                             p_tax_unit_id,
                                            'IR8S_MOA_412',
                                             p_business_group_id,
                                             v_date_from ,
                                             v_date_to ,
                                             v_no_of_times);
                        ------------------------------------------------------------------------------
                   end if;
              else
                   ---------------------------------------------------------------------------
                   --  Bug#3956870
                   ----------------------------------------------------------------------------
                   get_balance_dates (  p_run_ass_action_id,
                                        p_tax_unit_id,
                                       'IR8S_MOA_412',
                                        p_business_group_id,
                                        v_date_from ,
                                        v_date_to ,
                                        v_no_of_times);
                  ------------------------------------------------------------------------------
              end if;
              --
              if v_date_to is not null and v_moa_411_date is not null then
                  if fnd_date.canonical_to_date(v_date_to) > fnd_date.canonical_to_date(v_moa_411_date) then
                        v_moa_411_date := v_date_to;
                  else
                        v_no_of_times := v_no_of_times_411;
                  end if;
              elsif v_date_to is not null and v_moa_411_date is null then
                  v_moa_411_date := v_date_to;
              end if;
              --
              if v_date_to is null then
                  v_no_of_times := v_no_of_times_411;
              end if;
              --
              if v_moa_411_date is not null and v_no_of_times > 0 then
                  archive_item ('X_IR8S_MOA_411_DATE', p_assignment_action_id, v_moa_411_date);
              end if;
              --------------------------------------------------------------------------------------
              -- Archive IR8S_MOA_413 dates
              --------------------------------------------------------------------------------------
              if l_terminated = 'Y' then
                  ---------------------------------------------------------------------------
                  --  Bug#3956870
                  ----------------------------------------------------------------------------
                  get_balance_dates (  p_run_ass_action_id,
                                       p_tax_unit_id,
                                      'IR8S_MOA_413',
                                       p_business_group_id,
                                       v_date_from ,
                                       v_moa_413_date ,
                                       v_no_of_times_413);
                  ------------------------------------------------------------------------------
                  if v_date_from is null and v_moa_413_date is null then
                       ---------------------------------------------------------------------------
                        --  Bug#3956870
                       ----------------------------------------------------------------------------
                       get_balance_dates (  l_term_max_assact_id,
                                            p_tax_unit_id,
                                           'IR8S_MOA_413',
                                            p_business_group_id,
                                            v_date_from ,
                                            v_moa_413_date ,
                                            v_no_of_times_413);
                       ------------------------------------------------------------------------------

                  end if;
              else
                  ---------------------------------------------------------------------------
                  --  Bug#3956870
                  ----------------------------------------------------------------------------
                  get_balance_dates (  p_run_ass_action_id,
                                       p_tax_unit_id,
                                      'IR8S_MOA_413',
                                       p_business_group_id,
                                       v_date_from ,
                                       v_moa_413_date ,
                                       v_no_of_times_413);
                  ------------------------------------------------------------------------------
              end if;
              --------------------------------------------------------------------------------------
              -- Archive IR8S_MOA_414 dates
              --------------------------------------------------------------------------------------
              if l_terminated = 'Y' then
                   ---------------------------------------------------------------------------
                   --  Bug#3956870
                   ----------------------------------------------------------------------------
                  get_balance_dates (  p_run_ass_action_id,
                                       p_tax_unit_id,
                                      'IR8S_MOA_414',
                                       p_business_group_id,
                                       v_date_from ,
                                       v_date_to ,
                                       v_no_of_times);
                  ------------------------------------------------------------------------------
                  if v_date_from is null and v_date_to is null then
                    ---------------------------------------------------------------------------
                    --  Bug#3956870
                    ----------------------------------------------------------------------------
                     get_balance_dates (   l_term_max_assact_id,
                                           p_tax_unit_id,
                                          'IR8S_MOA_414',
                                           p_business_group_id,
                                           v_date_from ,
                                           v_date_to ,
                                           v_no_of_times);
                     ------------------------------------------------------------------------------
                  end if;
              end if;
               --
               ---------------------------------------------------------------------------
               --  Bug#3956870
               ----------------------------------------------------------------------------
               get_balance_dates ( p_run_ass_action_id,
                                   p_tax_unit_id,
                                  'IR8S_MOA_414',
                                   p_business_group_id,
                                   v_date_from ,
                                   v_date_to ,
                                   v_no_of_times);
               ------------------------------------------------------------------------------
              if v_date_to is not null and v_moa_413_date is not null then
                   if fnd_date.canonical_to_date(v_date_to) > fnd_date.canonical_to_date(v_moa_413_date) then
                       v_moa_413_date := v_date_to;
                   else
                       v_no_of_times := v_no_of_times_413;
                   end if;
              elsif v_date_to is not null and v_moa_413_date is null then
                   v_moa_413_date := v_date_to;
              end if;
              --
              if v_date_to is null then
                   v_no_of_times := v_no_of_times_413;
              end if;
              --
              if v_moa_413_date is not null and v_no_of_times > 0 then
                   archive_item ('X_IR8S_MOA_413_DATE', p_assignment_action_id, v_moa_413_date);
              end if;
              --
              if g_debug then
                   hr_utility.set_location('pysgirar: End of archive_balance_dates',100);
              end if;

     end archive_balance_dates;
  ---------------------------------------------------------------------------
  -- Copies the Org Developer DF route code to get Legal Entity information.
  ---------------------------------------------------------------------------
  procedure archive_org_info
      ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
        p_business_group_id     in hr_organization_units.business_group_id%type,
        p_legal_entity_id       in hr_organization_units.organization_id%type,
        p_person_id             in per_all_people_f.person_id%type,
        p_basis_start           in date,
        p_basis_end             in date)
  is
  --
  v_legal_entity_name     hr_organization_information.org_information1%type;
  v_er_income_tax_number  hr_organization_information.org_information4%type;
  v_er_ohq_status         hr_organization_information.org_information12%type;
  v_er_iras_category      hr_organization_information.org_information13%type;
  v_er_telephone_no       hr_organization_information.org_information14%type;
  v_er_payer_id           hr_organization_information.org_information15%type;
  -- Added for bug 3093991
  v_er_designation_type   hr_organization_information.org_information17%type;
  v_er_position_seg_type  hr_organization_information.org_information18%type;
  -- Added for bug 5078454
  v_er_bonus_date         hr_organization_information.org_information8%type;
  -- Added for bug 5435088
  v_er_auth_person_email  hr_organization_information.org_information5%type;
  v_er_division           hr_organization_information.org_information8%type;
  -- Added for bug 7415444
  v_er_a8b_incorp_date    hr_organization_information.org_information9%type;
  v_shares_nsop_count      number;
  l_pri_assignment_id     per_all_assignments_f.assignment_id%type;
  l_id_assignment_id      per_all_assignments_f.assignment_id%type;


  --
  cursor org_info
      ( c_business_group_id  hr_organization_units.business_group_id%type,
        c_legal_entity_id    hr_organization_units.organization_id%type)
  is
  select  target.org_information1,
          target.org_information4,
          target.org_information12,
          target.org_information13,
          target.org_information14,
          target.org_information15,
          target.org_information17,
          target.org_information18,
          target.org_information8,
          target.org_information9
  from    hr_organization_units       org,
          hr_organization_information target,
          hr_soft_coding_keyflex      scl
  where   org.business_group_id = c_business_group_id
  and     org.organization_id = c_legal_entity_id
  and     org.organization_id = target.organization_id
  and     target.org_information_context = 'SG_LEGAL_ENTITY'
  and     to_char(org.organization_id) = scl.segment1;
  --
  -- Added for bug 5435088
  cursor org_info2
      ( c_business_group_id  hr_organization_units.business_group_id%type,
        c_legal_entity_id    hr_organization_units.organization_id%type)
  is
  select  target.org_information5,
          target.org_information7
  from    hr_organization_units       org,
          hr_organization_information target,
          hr_soft_coding_keyflex      scl
  where   org.business_group_id = c_business_group_id
  and     org.organization_id = c_legal_entity_id
  and     org.organization_id = target.organization_id
  and     target.org_information_context = 'SG_LE_IRAS'
  and     to_char(org.organization_id) = scl.segment1;

  -- Added for bug 7415444
  cursor  shares_nsop_count
      ( c_business_group_id  hr_organization_units.business_group_id%type,
        c_legal_entity_id    hr_organization_units.organization_id%type,
        c_basis_start        date,
        c_basis_end          date)
  is
  select
  count(distinct pei.person_extra_info_id)
  from    per_all_people_f pap,
          per_people_extra_info  pei,
          per_assignments_f assign,
          hr_soft_coding_keyflex hsc
  where   pap.person_id = pei.person_id
  and     pei.information_type = 'HR_STOCK_EXERCISE_SG'
  and     pap.person_id = pei.person_id
  and     pap.person_id = assign.person_id
  and     assign.soft_coding_keyflex_id  = hsc.soft_coding_keyflex_id
  and     hsc.segment1                = c_legal_entity_id
  and     assign.business_group_id = c_business_group_id
  and     pei.pei_information1 = 'N'
  and     to_char(fnd_date.canonical_to_date(pei.pei_information5),'YYYY') = to_char(c_basis_end,'YYYY')
  and     (pap.effective_start_date <= c_basis_end and pap.effective_end_date >= c_basis_start);


  begin
      if g_debug then
           hr_utility.set_location('pysgirar: Start of archive_org_info',10);
      end if;
      --
      if g_org_run <> 'Y' then
        open org_info (p_business_group_id, p_legal_entity_id);
        fetch org_info into  v_legal_entity_name,
                             v_er_income_tax_number,
                             v_er_ohq_status,
                             v_er_iras_category,
                             v_er_telephone_no,
                             v_er_payer_id,
                             v_er_designation_type,
                             v_er_position_seg_type,
                             v_er_bonus_date,
                             v_er_a8b_incorp_date;

        -- The org information are the same for all employees, bug 5435088
        if org_info%found then
              g_org_run := 'Y';
              g_legal_entity_name    := v_legal_entity_name;
              g_er_income_tax_number := v_er_income_tax_number;
              g_er_ohq_status        := v_er_ohq_status;
              g_er_iras_category     := v_er_iras_category;
              g_er_telephone_no      := v_er_telephone_no;
              g_er_payer_id          := v_er_payer_id;
              g_er_designation_type  := v_er_designation_type;
              g_er_position_seg_type := v_er_position_seg_type;
              g_er_bonus_date        := v_er_bonus_date;
              g_er_incorp_date   := v_er_a8b_incorp_date;
              g_er_payer_id_check := check_payer_id(v_er_income_tax_number,
                                                    v_er_payer_id);
            -- Added for bug 5435088
              open org_info2 (p_business_group_id, p_legal_entity_id);
              fetch org_info2 into  v_er_auth_person_email,
                                  v_er_division;
              if org_info2%found then
                  g_er_auth_person_email := v_er_auth_person_email;
                  g_er_division          := v_er_division;
              end if;
              close org_info2;

              --Added for bug 7415444

              open shares_nsop_count(p_business_group_id,
                                    p_legal_entity_id,
                                    p_basis_start,
                                    p_basis_end);
              fetch shares_nsop_count into v_shares_nsop_count;
              close shares_nsop_count;
         end if;
         close org_info;

      end if;
      --

      if g_org_run = 'Y' then
            archive_item ('X_SG_LEGAL_ENTITY_SG_LEGAL_ENTITY_NAME', p_assignment_action_id, g_legal_entity_name);
            archive_item ('X_SG_LEGAL_ENTITY_SG_ER_INCOME_TAX_NUMBER', p_assignment_action_id, g_er_income_tax_number);
            archive_item ('X_SG_LEGAL_ENTITY_SG_ER_OHQ_STATUS', p_assignment_action_id, g_er_ohq_status);
            archive_item ('X_SG_LEGAL_ENTITY_SG_ER_IRAS_CATEGORY', p_assignment_action_id, g_er_iras_category);
            archive_item ('X_SG_LEGAL_ENTITY_SG_ER_TELEPHONE_NUMBER', p_assignment_action_id, g_er_telephone_no);
            archive_item ('X_SG_LEGAL_ENTITY_SG_ER_PAYER_ID', p_assignment_action_id, g_er_payer_id);
            -- Added for bug 3093991
            archive_item ('X_SG_LEGAL_ENTITY_SG_ER_JOB_DES_TYPE', p_assignment_action_id, g_er_designation_type);
            -- Added for bug 5435088
            archive_item ('X_SG_LEGAL_ENTITY_SG_ER_AUTH_PERSON_EMAIL', p_assignment_action_id, g_er_auth_person_email);
            archive_item ('X_SG_LEGAL_ENTITY_SG_ER_DIVISION', p_assignment_action_id, g_er_division);
            archive_item ('X_SG_LEGAL_ENTITY_SG_ER_ID_CHECK', p_assignment_action_id, g_er_payer_id_check);
            -- Added for bug 7415444
            archive_item ('X_SG_LEGAL_ENTITY_SG_A8B_INCORP_DATE', p_assignment_action_id, g_er_incorp_date);
            archive_item ('X_IRAS_METHOD', p_assignment_action_id, g_iras_method);
            -- Bug 7415444, this is for A8B NSOP
            if g_er_incorp_date is not null then
                g_er_incorp_date_1 := to_char(fnd_date.canonical_to_date(g_er_incorp_date),'YYYY')||'/'||to_char(fnd_date.canonical_to_date(g_er_incorp_date),'MM')||'/'||to_char(fnd_date.canonical_to_date(g_er_incorp_date),'DD');
                g_er_incorp_date_2 := to_char(to_number(to_char(fnd_date.canonical_to_date(g_er_incorp_date),'YYYY'))+3)||'/'||to_char(fnd_date.canonical_to_date(g_er_incorp_date),'MM')||'/'||to_char(fnd_date.canonical_to_date(g_er_incorp_date),'DD');
                if v_shares_nsop_count = 0 then
                  archive_item ('X_SG_LE_A8B_INCORP_DATE_ERROR', p_assignment_action_id, 'Y');
                end if;
            end if;

            -- Bug 5078454, if moa369 balance is not zero, then store the date
            -- from LE to the global value g_moa_369_date if it is not blank
            if g_moa_369_date is not null then
                if to_char(fnd_date.canonical_to_date(g_er_bonus_date),'YYYY') = to_char(g_basis_end,'YYYY') then
                    g_moa_369_date := to_char(fnd_date.canonical_to_date(g_er_bonus_date),'YYYY')||'/'||to_char(fnd_date.canonical_to_date(g_er_bonus_date),'MM')||'/'||to_char(fnd_date.canonical_to_date(g_er_bonus_date),'DD');
                end if;
            end if;

            -- Added for bug 4890964, the info. based on the assignment should
            -- be archived for latest LE with primary defined, or latest
            -- effective start dtae with max assignment_id if it has no primary
            -- defined
            --
            l_pri_assignment_id := pri_LE_if_latest(p_person_id,
                                                    p_legal_entity_id,
                                                    p_basis_start,
                                                    p_basis_end);

            if l_pri_assignment_id is not null then

                 archive_job_designation(p_assignment_action_id,
                                         p_person_id,
                                         l_pri_assignment_id,
                                         p_legal_entity_id,
                                         p_basis_start,
                                         p_basis_end,
                                         g_er_designation_type,
                                         g_er_position_seg_type);

                 archive_assignment_eits(p_assignment_action_id,
                                         p_person_id,
                                         l_pri_assignment_id,
                                         p_legal_entity_id,
                                         p_basis_start,
                                         p_basis_end);

                 archive_ass_payment_method(p_assignment_action_id,
                                         p_person_id,
                                         l_pri_assignment_id,
                                         p_legal_entity_id,
                                         p_basis_start,
                                         p_basis_end);

                 archive_ass_bonus_date_eits(p_assignment_action_id,
                                             p_person_id,
                                             l_pri_assignment_id,
                                             p_legal_entity_id,
                                             p_basis_start,
                                             p_basis_end);

            else
                 l_id_assignment_id := id_LE_if_latest(p_person_id,
                                                       p_legal_entity_id,
                                                       p_basis_start,
                                                       p_basis_end);

                 if l_id_assignment_id is not null then

                       archive_job_designation(p_assignment_action_id,
                                               p_person_id,
                                               l_id_assignment_id,
                                               p_legal_entity_id,
                                               p_basis_start,
                                               p_basis_end,
                                               g_er_designation_type,
                                               g_er_position_seg_type);

                       archive_assignment_eits(p_assignment_action_id,
                                               p_person_id,
                                               l_id_assignment_id,
                                               p_legal_entity_id,
                                               p_basis_start,
                                               p_basis_end );

                       archive_ass_payment_method(p_assignment_action_id,
                                                  p_person_id,
                                                  l_pri_assignment_id,
                                                  p_legal_entity_id,
                                                  p_basis_start,
                                                  p_basis_end);

                       archive_ass_bonus_date_eits(p_assignment_action_id,
                                                   p_person_id,
                                                   l_pri_assignment_id,
                                                   p_legal_entity_id,
                                                   p_basis_start,
                                                   p_basis_end);

                  end if;
              end if;
      end if;
      --
      if g_debug then
           hr_utility.set_location('pysgirar: End of archive_org_info',20);
      end if;
  end archive_org_info;

   --------------------------------------------------------------------------
   -- Bug 5435088, Added for payroll date
   --------------------------------------------------------------------------
   procedure archive_payroll_date
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_business_group_id     in hr_organization_units.business_group_id%type,
       p_legal_entity_id       in hr_organization_units.organization_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_basis_year            in varchar2) is

   v_payroll_date            varchar2(30);
   cursor payroll_date
      ( c_business_group_id  hr_organization_units.business_group_id%type,
        c_legal_entity_id    hr_organization_units.organization_id%type,
        c_person_id          per_all_people_f.person_id%type,
        c_basis_year         varchar2)
   is
         select   fnd_date.date_to_canonical(max(ppamax.effective_date))
         from     per_assignments_f paamax,
                  pay_assignment_actions pacmax,
                  pay_payroll_actions ppamax
         where    ppamax.business_group_id = c_business_group_id
         and      pacmax.tax_unit_id = c_legal_entity_id
	 and	  paamax.person_id = c_person_id
         and      paamax.assignment_id = pacmax.assignment_id
         and      ppamax.effective_date between to_date('01-01-'||c_basis_year,'DD-MM-YYYY')
                                            and to_date('31-12-'||c_basis_year,'DD-MM-YYYY')
         and      ppamax.payroll_action_id = pacmax.payroll_action_id
         and      ppamax.action_type in ('R','B','I','Q','V');

   begin
       if g_debug then
            hr_utility.set_location('pysgirar: Start of archive_payroll_date',10);
       end if;
       --
       open payroll_date (p_business_group_id, p_legal_entity_id, p_person_id, p_basis_year);
       fetch payroll_date into v_payroll_date;
       --
       if payroll_date%found then
            archive_item ('X_PER_PAYROLL_DATE', p_assignment_action_id, v_payroll_date);
       end if;
       --
       close payroll_date;
       --
       if g_debug then
            hr_utility.set_location('pysgirar: End of archive_payroll_date',20);
       end if;
  end archive_payroll_date;

  ---------------------------------------------------------------------------
  -- Copies the standard Person information route code.
  ---------------------------------------------------------------------------
  procedure archive_person_details
      ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
        p_person_id      in per_all_people_f.person_id%type,
        p_basis_start    in date,
        p_basis_end      in date )
  is
  --
  v_national_identifier  per_all_people_f.national_identifier%type;
  v_sex                  hr_lookups.meaning%type;
  v_date_of_birth        varchar2(30);
  ---------------------------------------------------------------------------
  -- Bug# 2920732 - Modified the cursor to use secured view per_people_f
  -- Bug 2645599
  ---------------------------------------------------------------------------
  cursor person_details
      ( c_person_id      per_all_people_f.person_id%type,
        c_basis_start    date,
        c_basis_end      date )
   is
   select  people.national_identifier,
           h.meaning,
           fnd_date.date_to_canonical(people.date_of_birth)
   from    per_people_f      people,
           hr_lookups            h
   where   people.person_id = c_person_id
   and     people.effective_start_date = (
                   select  max(people1.effective_start_date)
                   from    per_people_f people1
                   where   people1.person_id = people.person_id
                   and     people1.effective_start_date <= c_basis_end
                   and     people1.effective_end_date >= c_basis_start
                    )
   and     h.lookup_type     (+)= 'SEX'
   and     h.lookup_code     (+)= people.sex
   and     h.application_id  (+)= 800;
   --
  begin
       if g_debug then
            hr_utility.set_location('pysgirar: Start of archive_person_details',10);
       end if;
       --
       open person_details (p_person_id, p_basis_start, p_basis_end);
       fetch person_details into v_national_identifier, v_sex, v_date_of_birth;
       --
       if person_details%found then
            g_national_identifier := v_national_identifier;
            archive_item ('X_PER_NATIONAL_IDENTIFIER', p_assignment_action_id, v_national_identifier);
            archive_item ('X_PER_SEX', p_assignment_action_id, v_sex);
            archive_item ('X_PER_DATE_OF_BIRTH', p_assignment_action_id, v_date_of_birth);
       end if;
       --
       close person_details;
       --
       if g_debug then
            hr_utility.set_location('pysgirar: End of archive_person_details',20);
       end if;
  end archive_person_details;
  ---------------------------------------------------------------------------
  -- Copies the standard Person Address information route code.
  ---------------------------------------------------------------------------
  procedure archive_person_addresses
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_basis_start           in date,
       p_basis_end             in date )
  is
      v_style           per_addresses.style%type;
      v_address_type    per_addresses.address_type%type;
      v_address_line_1  per_addresses.address_line1%type;
      v_address_line_2  per_addresses.address_line2%type;
      v_address_line_3  per_addresses.address_line3%type;
      v_postal_code     per_addresses.postal_code%type;
      v_country         per_addresses.country%type;
      v_country_code    varchar2(3);
      ---------------------------------------------------------------------------
      -- Padded postal code upto 6 chars, if null then store 999999*/
      -- Bug2647074
      -- Modified for bug 5435088, added style, type and country
      ---------------------------------------------------------------------------
    cursor person_address
      (c_person_id      per_all_people_f.person_id%type,
       c_basis_start    date,
       c_basis_end      date) is
    select addr.style,
           addr.address_type,
           addr.address_line1,
           addr.address_line2,
           addr.address_line3,
           addr.postal_code,
--           lpad(nvl(addr.postal_code,'999999'),6,'0'),
           addr.country
    from   per_addresses         addr,
           fnd_territories_tl    a
    where  addr.person_id      (+)= c_person_id
    and    addr.primary_flag   (+)= 'Y'
    and    c_basis_end between nvl(addr.date_from, c_basis_start)
                             and nvl(addr.date_to, c_basis_end) /* Bug 2654499 */
    and	   a.territory_code    (+)= addr.country
    and    a.language          (+)= userenv('LANG');

  begin
    if g_debug then
          hr_utility.set_location('pysgirar: Start of archive_person_addresses',10);
    end if;
    -- Primary Address
    open person_address (p_person_id, p_basis_start, p_basis_end);
    fetch person_address into v_style,
                              v_address_type,
                              v_address_line_1,
                              v_address_line_2,
                              v_address_line_3,
                              v_postal_code,
                              v_country;

    if person_address%found then
      -- Added for bug 5435088
      if v_country = 'SG' then
          if v_style = 'SG' then
             archive_item ('X_PER_ADR_TYPE', p_assignment_action_id, 'L');
          elsif v_style = 'SG_GLB' then
             archive_item ('X_PER_ADR_TYPE', p_assignment_action_id, 'C');
          end if;
      else
        archive_item ('X_PER_ADR_TYPE', p_assignment_action_id, 'F');
        if v_country is not null then
          v_country_code := get_country_code (v_country);
        end if;
        archive_item ('X_PER_ADR_COUNTRY_CODE', p_assignment_action_id, v_country_code);
      end if;

      archive_item ('X_PER_ADR_STYLE', p_assignment_action_id, v_style);
      archive_item ('X_PER_ADR_LINE_1', p_assignment_action_id, v_address_line_1);
      archive_item ('X_PER_ADR_LINE_2', p_assignment_action_id, v_address_line_2);
      archive_item ('X_PER_ADR_LINE_3', p_assignment_action_id, v_address_line_3);
      archive_item ('X_PER_ADR_POSTAL_CODE', p_assignment_action_id, v_postal_code);
    else
      archive_item ('X_PER_ADR_TYPE', p_assignment_action_id, 'N');
    end if;
    close person_address;
    --
    if g_debug then
         hr_utility.set_location('pysgirar: End of archive_person_addresses',20);
    end if;
  end archive_person_addresses;
  ---------------------------------------------------------------------------
  -- Copies the standard Person Company Quarters address
  -- Bug 4688761, to separate from the above procedure
  ---------------------------------------------------------------------------
  procedure archive_person_cq_addresses
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_basis_start           in date,
       p_basis_end             in date )
  is
      v_address_line_1  per_addresses.address_line1%type;
      v_address_line_2  per_addresses.address_line2%type;
      v_address_line_3  per_addresses.address_line3%type;
      v_postal_code     per_addresses.postal_code%type;
      v_date_from       varchar2(30);
      v_date_to         varchar2(30);

   -- Added for bug 2373475
    cursor person_cq_address
      (c_person_id      per_all_people_f.person_id%type,
       c_basis_start    date,
       c_basis_end      date) is
    select addr.address_line1,
           addr.address_line2,
           addr.address_line3,
           fnd_date.date_to_canonical(addr.date_from),
           fnd_date.date_to_canonical(nvl(addr.date_to,c_basis_end))/* if its not blank, return the real end date, bug 2654499 */
    from   per_addresses         addr,
           fnd_territories_tl    a
    where  addr.person_id (+) = c_person_id
    and    a.territory_code    (+)= addr.country
    and    a.language          (+)= userenv('LANG')
    and    addr.address_type = 'SG_CQ'  -- SG specific Company Quarters Address Type
    and    addr.country = 'SG'
    and    addr.style <> 'SG'
    and    nvl(addr.date_to, c_basis_end) =
           (select max(nvl(date_to, c_basis_end))
            from   per_addresses
            where  address_type = 'SG_CQ'
            and    person_id = addr.person_id
            and    (date_from <= c_basis_end
               and nvl(date_to, c_basis_end) >= c_basis_start));/*Bug 2654499*/

  begin
    if g_debug then
          hr_utility.set_location('pysgirar: Start of archive_person_cq_addresses',10);
    end if;

    -- Company Quarters Address, bug 2373475
    open person_cq_address (p_person_id, p_basis_start, p_basis_end);
    fetch person_cq_address into v_address_line_1,
                                 v_address_line_2,
                                 v_address_line_3,
                                 v_date_from,
                                 v_date_to;
    if person_cq_address%found then
      archive_item ('X_PER_CQ_ADR_LINE_1', p_assignment_action_id, v_address_line_1);
      archive_item ('X_PER_CQ_ADR_LINE_2', p_assignment_action_id, v_address_line_2);
      archive_item ('X_PER_CQ_ADR_LINE_3', p_assignment_action_id, v_address_line_3);
      archive_item ('X_PER_CQ_DATE_FROM', p_assignment_action_id, v_date_from);
      archive_item ('X_PER_CQ_DATE_TO', p_assignment_action_id, v_date_to);
    end if;
    close person_cq_address;
    --
    if g_debug then
         hr_utility.set_location('pysgirar: End of archive_person_cq_addresses',20);
    end if;
  end archive_person_cq_addresses;

  ---------------------------------------------------------------------------
  -- Copies the standard Employee information route code.
  ---------------------------------------------------------------------------
  procedure archive_emp_details
    (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
     p_person_id             in per_all_people_f.person_id%type,
     p_basis_start           in date,
     p_basis_end             in date) is

    v_date_start        varchar2(30);
    v_termination_date  varchar2(30);

    cursor emp_hire_details
      (c_person_id      per_all_people_f.person_id%type,
       c_basis_end      date) is
    select fnd_date.date_to_canonical(min(service.date_start))
    from   per_periods_of_service service
    where  service.person_id = c_person_id
    and    service.date_start <= c_basis_end; /*Bug 2668599*/

    /* Bug# 2920732 - Modified the cursor to use secured view per_assignments_f  */
    cursor emp_termination_details
      (c_person_id      per_all_people_f.person_id%type,
       c_basis_start    date,
       c_basis_end      date) is
    select fnd_date.date_to_canonical(service.actual_termination_date)
    from   per_assignments_f  assign,
           per_periods_of_service service
    where  service.person_id = c_person_id
    and    service.period_of_service_id (+)= assign.period_of_service_id
    and    assign.effective_start_date = (
                     	select max(assign1.effective_start_date)
                        from   per_assignments_f assign1
                        where  assign1.person_id = service.person_id
                        and    assign1.assignment_type = 'E' /* Bug 5033609 */
                        and    (assign1.effective_start_date <= c_basis_end
		 	        and assign1.effective_end_date >= c_basis_start)
                                         );/*Bug 2654499*/
  begin
    if g_debug then
         hr_utility.set_location('pysgirar: Start of archive_emp_details',10);
    end if;
    --
    open emp_hire_details (p_person_id, p_basis_end);
    fetch emp_hire_details into v_date_start;

    if emp_hire_details%found then
      archive_item ('X_EMP_HIRE_DATE', p_assignment_action_id, v_date_start);
    end if;
    close emp_hire_details;

    open emp_termination_details (p_person_id, p_basis_start, p_basis_end);
    fetch emp_termination_details into v_termination_date;

    if emp_termination_details%found then
      archive_item ('X_EMP_TERM_DATE', p_assignment_action_id, v_termination_date);
    end if;
    close emp_termination_details;
    --
    if g_debug then
          hr_utility.set_location('pysgirar: End of archive_emp_details',20);
    end if;
  end archive_emp_details;
  ---------------------------------------------------------------------------
  -- Copies the standard Person Developer DF route code.
  ---------------------------------------------------------------------------
  procedure archive_people_flex
    (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
     p_person_id             in per_all_people_f.person_id%type,
     p_basis_start           in date,
     p_basis_end             in date)
  is
  --
  v_sg_legal_name    per_all_people_f.per_information1%type;
  v_pp_country       per_all_people_f.per_information3%type;
  v_permit_type      per_all_people_f.per_information6%type;
  v_permit_date      varchar2(30);
  v_income_tax_no    per_all_people_f.per_information12%type;
  v_payee_id_type    per_all_people_f.per_information23%type;
  l_payee_id_check   char(1);
  l_nationality_code varchar2(3);
  ---------------------------------------------------------------------------
  -- Bug# 2920732 - Modified the cursor to use secured view per_people_f
  -- Bug 2645599
  -- Bug 5435088, Added Payee ID Type and permit date
  ---------------------------------------------------------------------------
  cursor emp_details
       ( c_person_id      per_all_people_f.person_id%type,
         c_basis_start    date,
         c_basis_end      date )
  is
  select  people.per_information1,
          people.per_information3,
          people.per_information6,
          to_char(fnd_date.canonical_to_date(people.per_information9),'YYYY')||'/'||to_char(fnd_date.canonical_to_date(people.per_information9),'MM')||'/'||to_char(fnd_date.canonical_to_date(people.per_information9),'DD'), -- Bug 5435088
--          fnd_date.canonical_to_date(people.per_information9), -- Bug 5435088
          people.per_information12,
          people.per_information23
  from    per_people_f people
  where   people.person_id = c_person_id
  and     people.effective_start_date = (
                       select  max(people1.effective_start_date)
                       from    per_people_f people1
                       where   people1.person_id = people.person_id
                       and     people1.effective_start_date <= c_basis_end
                       and     people1.effective_end_date >= c_basis_start);
  --
  begin
      if g_debug then
            hr_utility.set_location('pysgirar: Start of archive_people_flex',10);
      end if;
      --
      open emp_details (p_person_id, p_basis_start, p_basis_end);
      fetch emp_details into v_sg_legal_name, v_pp_country, v_permit_type, v_permit_date, v_income_tax_no, v_payee_id_type;
      --
      if emp_details%found then

          archive_item ('X_PEOPLE_FLEXFIELD_SG_SG_LEGAL_NAME', p_assignment_action_id, v_sg_legal_name);
          archive_item ('X_PEOPLE_FLEXFIELD_SG_SG_PP_COUNTRY', p_assignment_action_id, v_pp_country);
          archive_item ('X_PEOPLE_FLEXFIELD_SG_SG_PERMIT_TYPE', p_assignment_action_id, v_permit_type);

          archive_item ('X_PEOPLE_FLEXFIELD_SG_SG_INCOME_TAX_NUMBER', p_assignment_action_id, v_income_tax_no);
          -- Added for bug 5435088
          if g_national_identifier is null then
                if v_income_tax_no is not null and
                     v_payee_id_type is not null then
                    l_payee_id_check := check_payee_id (v_income_tax_no,
                                                v_payee_id_type);
                end if;
          else
             if substr(g_national_identifier, 1, 1) = 'S' or
                   substr(g_national_identifier, 1, 1) = 'T' then
                v_payee_id_type := '1';
             elsif substr(g_national_identifier, 1, 1) = 'F' or
                     substr(g_national_identifier, 1, 1) = 'G' then
                v_payee_id_type := '2';
             end if;
          end if;
          archive_item ('X_PER_EE_PAYEE_ID_CHECK', p_assignment_action_id, l_payee_id_check);
          archive_item ('X_PEOPLE_FLEXFIELD_SG_SG_PAYEE_ID_TYPE', p_assignment_action_id, v_payee_id_type);
          if v_payee_id_type = '1' then
            if v_permit_type = 'PR' then
             if to_date(v_permit_date,'YYYY/MM/DD') >= add_months(p_basis_start,-24) then
               archive_item ('X_PER_PERMIT_STATUS_INDICATOR', p_assignment_action_id, 'Y');
             else
               archive_item ('X_PER_PERMIT_STATUS_INDICATOR', p_assignment_action_id, 'N');
             end if;
            end if;
          end if;

          /* Bug 5873476 , fixed PR for 300,Singapore Citizen 301 */
          if v_permit_type = 'PR' then
              l_nationality_code := '300';
          elsif v_permit_type = 'SG' then
              l_nationality_code := '301';
          else
              l_nationality_code := get_country_code(v_pp_country);
	  end if;
          archive_item ('X_PER_NATIONALITY_CODE', p_assignment_action_id, l_nationality_code);

      end if;
      --
      close emp_details;
      if g_debug then
          hr_utility.set_location('pysgirar: End of archive_people_flex',20);
      end if;
  end archive_people_flex;

  ---------------------------------------------------------------------------
  -- Copies the standard Extra Person Information DF route code.
  ---------------------------------------------------------------------------
  procedure archive_person_eits
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_basis_start           in date,
       p_basis_end             in date )
  is
  --
  v_section_45_applicable         per_people_extra_info.pei_information1%type;
  v_income_tax_borne_by_employer  per_people_extra_info.pei_information2%type;
  v_ir8s_applicable               per_people_extra_info.pei_information3%type;
  v_exempt_remission              per_people_extra_info.pei_information4%type;
  v_iras_approval                 per_people_extra_info.pei_information5%type;
  v_approval_date                 per_people_extra_info.pei_information6%type;
  v_retirement_fund               per_people_extra_info.pei_information3%type;
  v_designated_pension            per_people_extra_info.pei_information4%type;
  -- Added for bug 5435088
  v_name_of_bank                  per_people_extra_info.pei_information6%type;
  v_additional_information        per_people_extra_info.pei_information1%type;
  ---------------------------------------------------------------------------
  -- Bug# 2920732 - Modified the cursor to use the secured view per_people_f
  -- Bug 5435088, Removed archiving gratuity_or_comp_info, gains_or_profit_from
  -- _shares, remarks
  -- Bug 6349937, removed hr_lookups which is not being used
  ---------------------------------------------------------------------------
  cursor person_eits
      ( c_person_id      per_all_assignments_f.assignment_id%type,
        c_basis_start    date,
        c_basis_end      date )
  is
  select  indicators.pei_information1,
          indicators.pei_information2,
          indicators.pei_information3,
          indicators.pei_information4, -- Exempt Remission
          indicators.pei_information5, -- Approval from IRAS
          to_char(fnd_date.canonical_to_date(indicators.pei_information6),'YYYY')||'/'||to_char(fnd_date.canonical_to_date(indicators.pei_information6),'MM')||'/'||to_char(fnd_date.canonical_to_date(indicators.pei_information6),'DD'), -- Date of Approval
          details.pei_information3,
          details.pei_information4,
          details.pei_information6, -- Name of bank
          info.pei_information1
  from    per_people_extra_info indicators,
          per_people_extra_info info,
          per_people_extra_info details,
          per_people_f      people
  where   people.person_id               = c_person_id
  and     people.effective_start_date = (
                           select  max(people1.effective_start_date)
                           from    per_people_f people1
                           where   people1.person_id = people.person_id
                           and     people1.effective_start_date <= c_basis_end
                           and     people1.effective_end_date >= c_basis_start)/*Bug 2645599*/
  and    people.person_id               = indicators.person_id(+)
  and    indicators.information_type(+) = 'HR_IR8A_INDICATORS_SG'
  and    people.person_id               = details.person_id(+)
  and    details.information_type(+)    = 'HR_IR8A_FURTHER_DETAILS_SG'
  and    people.person_id               = info.person_id(+)
  and    info.information_type(+)       = 'HR_IRAS_ADDITIONAL_INFO_SG';
  --
  begin
      if g_debug then
           hr_utility.set_location('pysgirar: Start of archive_person_eits',10);
      end if;
      --
      open person_eits (p_person_id, p_basis_start, p_basis_end);
      fetch person_eits into  v_section_45_applicable,
                              v_income_tax_borne_by_employer,
                              v_ir8s_applicable,
                              v_exempt_remission,
                              v_iras_approval,
                              v_approval_date,
                              v_retirement_fund,
                              v_designated_pension,
                              v_name_of_bank,
                              v_additional_information;
      --
      if person_eits%found then
           archive_item ('X_HR_IR8A_INDICATORS_SG_PER_SECTION_45_APPLICABLE',
                         p_assignment_action_id, v_section_45_applicable );
           archive_item ('X_HR_IR8A_INDICATORS_SG_PER_INCOME_TAX_BORNE_BY_EMPLOYER',
                         p_assignment_action_id, v_income_tax_borne_by_employer);
           archive_item ('X_HR_IR8A_INDICATORS_SG_PER_IR8S_APPLICABLE',
                         p_assignment_action_id, v_ir8s_applicable);
           if v_exempt_remission = 'N' then
             v_exempt_remission := null;
           end if;
           archive_item ('X_HR_IR8A_INDICATORS_SG_EXEMPT',
                         p_assignment_action_id, v_exempt_remission);
           archive_item ('X_HR_IR8A_INDICATORS_SG_APPR_IRAS',
                         p_assignment_action_id, v_iras_approval);
           archive_item ('X_HR_IR8A_INDICATORS_SG_DATE_OF_APPR_IRAS',
                         p_assignment_action_id, v_approval_date);
           archive_item ('X_HR_IR8A_FURTHER_DETAILS_SG_PER_RETIREMENT_FUND',
                         p_assignment_action_id, v_retirement_fund);
           archive_item ('X_HR_IR8A_FURTHER_DETAILS_SG_PER_DESIGNATED_PENSION',
                         p_assignment_action_id, v_designated_pension);
           archive_item ('X_HR_IRAS_ADDITIONAL_INFO_SG_PER_ADDITIONAL_INFORMATION',
                         p_assignment_action_id, v_additional_information);
           g_name_of_bank := v_name_of_bank; -- bug 5435088
      end if;
      close person_eits;
      --
      if g_debug then
           hr_utility.set_location('pysgirar: End of archive_person_eits',20);
      end if;
  end archive_person_eits;

  ---------------------------------------------------------------------------
  -- Copies the standard Extra Assignment Information DF route code. - Bug 2373475
  -- Added p_assignment_id as parameter
  ---------------------------------------------------------------------------
  procedure archive_assignment_eits
      ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
        p_person_id             in per_all_people_f.person_id%type,
        p_assignment_id         in per_all_assignments_f.assignment_id%type,
        p_legal_entity_id       in hr_organization_units.organization_id%type,
        p_basis_start           in date,
        p_basis_end             in date )
  is
  --
  v_voluntary_cpf_obligatory      per_assignment_extra_info.aei_information2%type;
  v_appr_cpf_full                 per_assignment_extra_info.aei_information3%type;
  v_assignment_id                 per_assignments_f.assignment_id%type;
  ---------------------------------------------------------------------------
  -- Bug# 2920732 - Modified the cursor to use the secured view per_assignments_f
  -- Bug# 4688761 - Modified cursor to check the legal entity, and need get the
  -- latest primary assignment
  -- Bug 4890964 - Modified cursor to remove the latest assignment check, now
  -- we pass the assignment_id as a parameter
  -- Bug 5435088 - Added field Approval from CPF to make full
  ---------------------------------------------------------------------------
  cursor assignment_eits
      ( c_person_id        per_all_people_f.person_id%type,
        c_assignment_id    per_assignments_f.assignment_id%type,
        c_legal_entity_id  hr_organization_units.organization_id%type,
        c_basis_start      date,
        c_basis_end        date )
  is
  select  /*+ USE_NL(aei) */
          aei.aei_information2,
          aei.aei_information3
  from    per_assignments_f assign,
          per_assignment_extra_info aei,
          hr_soft_coding_keyflex hsc
  where   assign.person_id = c_person_id
  and     assign.assignment_id = c_assignment_id
  and     assign.assignment_id = aei.assignment_id
  and     assign.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
  and     hsc.segment1 = c_legal_entity_id
  and     aei.information_type = 'HR_IR8S_INDICATORS_SG';
  --
  begin
      if g_debug then
            hr_utility.set_location('pysgirar: Start of archive_assignment_eits', 10);
      end if;
      --
      open assignment_eits (p_person_id, p_assignment_id, p_legal_entity_id, p_basis_start, p_basis_end);
      fetch assignment_eits into v_voluntary_cpf_obligatory,
                                 v_appr_cpf_full;
      --
      if assignment_eits%found then
          archive_item ('X_HR_IR8S_INDICATORS_SG_ASG_VOLUNTARY_CPF_OBLIGATORY',
                        p_assignment_action_id, v_voluntary_cpf_obligatory);
          -- Added for bug 5435088
          archive_item ('X_HR_IR8S_INDICATORS_SG_ASG_APPR_CPF',
                        p_assignment_action_id, v_appr_cpf_full);
      end if;
      close assignment_eits;
      --
      if g_debug then
          hr_utility.set_location('pysgirar: End of archive_assignment_eits', 20);
      end if;
  end archive_assignment_eits;

  ---------------------------------------------------------------------------
  -- Bug 5078454, to get bonus date from the Assignment EIT
  -- archive it to DTM161 if it is not blank, otherwise archive the global
  -- value g_moa_369_date
  ---------------------------------------------------------------------------
  procedure archive_ass_bonus_date_eits
      ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
        p_person_id             in per_all_people_f.person_id%type,
        p_assignment_id         in per_all_assignments_f.assignment_id%type,
        p_legal_entity_id       in hr_organization_units.organization_id%type,
        p_basis_start           in date,
        p_basis_end             in date )
  is
  --
  v_ass_bonus_date                varchar2(10);
  v_assignment_id                 per_assignments_f.assignment_id%type;

  cursor ass_bonus_date_eits
      ( c_person_id        per_all_people_f.person_id%type,
        c_assignment_id    per_assignments_f.assignment_id%type,
        c_legal_entity_id  hr_organization_units.organization_id%type,
        c_basis_start      date,
        c_basis_end        date )
  is
  select  /*+ USE_NL(aei) */
          to_char(fnd_date.canonical_to_date(aei.aei_information1),'YYYY')||'/'||to_char(fnd_date.canonical_to_date(aei.aei_information1),'MM')||'/'||
          to_char(fnd_date.canonical_to_date(aei.aei_information1),'DD')
  from    per_assignments_f assign,
          per_assignment_extra_info aei,
          hr_soft_coding_keyflex hsc
  where   assign.person_id      = c_person_id
  and     assign.assignment_id  = c_assignment_id
  and     assign.assignment_id = aei.assignment_id
  and     assign.soft_coding_keyflex_id  = hsc.soft_coding_keyflex_id
  and     hsc.segment1                = c_legal_entity_id
  and     aei.information_type = 'HR_NON_CONT_BONUS_INFO_SG'
  and     aei.aei_information1 is not NULL
  and     assign.assignment_type = 'E'
  and     to_char(fnd_date.canonical_to_date(aei.aei_information1),'YYYY') = to_char(c_basis_end,'YYYY');

  --
  begin

      if g_debug then
            hr_utility.set_location('pysgirar: Start of archive_ass_bonus_date_eits', 10);
      end if;
      --
      open ass_bonus_date_eits (p_person_id, p_assignment_id, p_legal_entity_id, p_basis_start, p_basis_end);
      fetch ass_bonus_date_eits into v_ass_bonus_date;
      --
      if ass_bonus_date_eits%found and g_moa_369_date is not null then
          g_moa_369_date := v_ass_bonus_date;
      end if;
      --
      archive_item ('X_IR8A_MOA_369_DATE', p_assignment_action_id, g_moa_369_date);
      --
      close ass_bonus_date_eits;
      --
      if g_debug then
          hr_utility.set_location('pysgirar: End of archive_ass_bonus_date_eits', 20);
      end if;
  end archive_ass_bonus_date_eits;

  ---------------------------------------------------------------------------
  -- Bug 5435088, to get payment method from the assignment
  -- if the bank name from EIT is blank, it will archive the bank name from
  -- payment method
  -- Bug 5868910 - Added effective_start_date sub-query for the date tracked
  -- payment method
  ---------------------------------------------------------------------------
    procedure archive_ass_payment_method
      ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
        p_person_id             in per_all_people_f.person_id%type,
        p_assignment_id         in per_all_assignments_f.assignment_id%type,
        p_legal_entity_id       in hr_organization_units.organization_id%type,
        p_basis_start           in date,
        p_basis_end             in date)
    is
  --
  v_ass_bank_name                 varchar2(10);
  v_assignment_id                 per_assignments_f.assignment_id%type;

  cursor ass_payment_method
      ( c_person_id        per_all_people_f.person_id%type,
        c_assignment_id    per_assignments_f.assignment_id%type,
        c_legal_entity_id  hr_organization_units.organization_id%type,
        c_basis_start           in date,
        c_basis_end             in date)
  is

  SELECT pea.segment4 bank_name
  FROM   per_assignments_f assign,
         hr_soft_coding_keyflex hsc,
         pay_external_accounts pea,
         pay_personal_payment_methods_f ppm,
         hr_lookups hl
 WHERE   assign.person_id     = c_person_id
   AND   assign.assignment_id = c_assignment_id
   AND   assign.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
   AND   hsc.segment1 = c_legal_entity_id
   AND   assign.assignment_id = ppm.assignment_id
   AND   pea.segment3                      =  hl.lookup_code (+)
   AND   hl.lookup_type(+)                 =  'SG_ACCOUNT_TYPE'
   AND   pea.external_account_id(+)        =  ppm.external_account_id
   AND   assign.effective_start_date <= c_basis_end
   AND   assign.effective_end_date >= c_basis_start
   AND   ppm.effective_start_date <= c_basis_end
   AND   ppm.effective_end_date >= c_basis_start
   and   priority = 1
   and ppm.effective_start_date =
      (select max(ppm1.effective_start_date)
       from pay_personal_payment_methods_f ppm1
       where ppm1.assignment_id = ppm.assignment_id
       and    ppm1.effective_start_date <= c_basis_end
       and   ppm1.effective_end_date >= c_basis_start); /* Bug 5868910*/
  --
  begin

      if g_debug then
            hr_utility.set_location('pysgirar: Start of archive_ass_payment_method', 10);
      end if;
      --
      --
      open ass_payment_method (p_person_id, p_assignment_id, p_legal_entity_id, p_basis_start, p_basis_end);
      fetch ass_payment_method into v_ass_bank_name;
      --
      if ass_payment_method%found and g_name_of_bank is null then
          g_name_of_bank := v_ass_bank_name;
      end if;
      --
      archive_item ('X_HR_IR8A_FURTHER_DETAILS_SG_NAME_OF_BANK',
                         p_assignment_action_id, g_name_of_bank);

      g_name_of_bank := NULL; /* Bug 7663830 */
      --
      close ass_payment_method;
      --
      if g_debug then
          hr_utility.set_location('pysgirar: End of archive_ass_payment_method', 20);
      end if;
  end archive_ass_payment_method;


  ---------------------------------------------------------------------------
  -- Bug 3093991, Select Grade, Job, Position or Job Designation user entered
  -- for Job Designation
  -- Bug 4890964, added p_assignment_id as parameter
  ---------------------------------------------------------------------------
  procedure archive_job_designation
      ( p_assignment_action_id in pay_assignment_actions.assignment_action_id%type,
        p_person_id            in per_all_people_f.person_id%type,
        p_assignment_id        in per_all_assignments_f.assignment_id%type,
        p_legal_entity_id      in hr_organization_units.organization_id%type,
        p_basis_start          in date,
        p_basis_end            in date,
        p_er_designation_type  in hr_organization_information.org_information17%type,
        p_er_position_seg_type in hr_organization_information.org_information18%type)
  is
  --
  v_designation  hr_all_positions_f.name%type;

  ---------------------------------------------------------------------------
  -- Bug 4688761 - Modified cursor to check the legal entity, and need get the
  -- latest primary assignment
  -- Bug 4890964 - Modified cursor to remove the latest assignment check, now
  -- we pass the assignment_id as a parameter
  -- Bug 5868910 - Added effective_start_date sub-query for the date tracked
  -- assignment
  ---------------------------------------------------------------------------
  cursor grade
      ( c_person_id        per_all_people_f.person_id%type,
        c_assignment_id    per_assignments_f.assignment_id%type,
        c_legal_entity_id  hr_organization_units.organization_id%type,
        c_basis_start      date,
        c_basis_end        date) is

  select  grade.name
  from    per_assignments_f assign,
          per_grades            grade,
          hr_soft_coding_keyflex hsc
  where   assign.person_id       = c_person_id
  and     assign.assignment_id   = c_assignment_id
  and     grade.grade_id         = assign.grade_id
  and     assign.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
  and     hsc.segment1 = c_legal_entity_id
  and     assign.assignment_type = 'E'
  and     assign.effective_start_date =
                (select max(paf1.effective_start_date)
                 from   per_assignments_f paf1
                 where  paf1.person_id = assign.person_id
                 and    paf1.assignment_id = assign.assignment_id
                 and    paf1.soft_coding_keyflex_id = assign.soft_coding_keyflex_id
                 and    paf1.effective_start_date <= c_basis_end
                 and    paf1.effective_end_date >= c_basis_start); /* Bug 5868910 */

  ---------------------------------------------------------------------------
  -- Bug 4688761 - Modified cursor to check the legal entity, and need get the
  -- latest primary assignment
  -- Bug 4890964 - Modified cursor to remove the latest assignment check, now
  -- we pass the assignment_id as a parameter
  -- Bug 5868910 - Added effective_start_date sub-query for the date tracked
  -- assignment
  ---------------------------------------------------------------------------
  cursor job
      ( c_person_id        per_all_people_f.person_id%type,
        c_assignment_id    per_all_assignments_f.assignment_id%type,
        c_legal_entity_id  hr_organization_units.organization_id%type,
        c_basis_start      date,
        c_basis_end        date) is

  select  jbt.name
  from    per_assignments_f assign,
          per_jobs_tl           jbt,
          hr_soft_coding_keyflex hsc
  where   assign.person_id      = c_person_id
  and     assign.assignment_id  = c_assignment_id
  and     jbt.job_id            = assign.job_id
  and     assign.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
  and     hsc.segment1 = c_legal_entity_id
  and     jbt.language          = userenv('LANG')
  and     assign.assignment_type = 'E'
  and     assign.effective_start_date =
                (select max(paf1.effective_start_date)
                 from   per_assignments_f paf1
                 where  paf1.person_id = assign.person_id
                 and    paf1.assignment_id = assign.assignment_id
                 and    paf1.soft_coding_keyflex_id = assign.soft_coding_keyflex_id
                 and    paf1.effective_start_date <= c_basis_end
                 and    paf1.effective_end_date >= c_basis_start); /* Bug 5868910 */

  ---------------------------------------------------------------------------
  -- Bug 4688761 - Modified cursor to check the legal entity, and need get the
  -- latest primary assignment
  -- Bug 4890964 - Modified cursor to remove the latest assignment check, now
  -- we pass the assignment_id as a parameter
  -- Bug 5868910 - Added effective_start_date sub-query for the date tracked
  -- assignment
  ---------------------------------------------------------------------------
  cursor position
      ( c_person_id        per_all_people_f.person_id%type,
        c_assignment_id    per_all_assignments_f.assignment_id%type,
        c_legal_entity_id  hr_organization_units.organization_id%type,
        c_basis_start      date,
        c_basis_end        date) is

    select  pst.name
    from    per_assignments_f assign,
            hr_all_positions_f_tl pst,
            hr_all_positions_f    pos,
            hr_soft_coding_keyflex hsc
    where   assign.person_id      = c_person_id
    and     assign.assignment_id  = c_assignment_id
    and     pos.position_id    = assign.position_id
    and     pst.position_id    = pos.position_id
    and     assign.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
    and     hsc.segment1 = c_legal_entity_id
    and     pst.language       = userenv('LANG')
    and     assign.effective_start_date between NVL(pos.effective_start_date,to_date('01-01-1900','DD-MM-YYYY')) and NVL(pos.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'))
    and     assign.assignment_type = 'E'
    and     assign.effective_start_date =
                (select max(paf1.effective_start_date)
                 from   per_assignments_f paf1
                 where  paf1.person_id = assign.person_id
                 and    paf1.assignment_id = assign.assignment_id
                 and    paf1.soft_coding_keyflex_id = assign.soft_coding_keyflex_id
                 and    paf1.effective_start_date <= c_basis_end
                 and    paf1.effective_end_date >= c_basis_start); /* Bug 5868910 */

  ---------------------------------------------------------------------------
  -- Bug 4688761 - Modified cursor to get the latest primary assignment
  -- Bug 4890964 - Modified cursor to remove the latest assignment check, now
  -- we pass the assignment_id as a parameter
  -- Bug 5868910 - Added effective_start_date sub-query for the date tracked
  -- assignment
  ---------------------------------------------------------------------------

  cursor position_seg
        ( c_person_id              per_all_people_f.person_id%type,
          c_assignment_id          per_all_assignments_f.assignment_id%type,
          c_basis_start            date,
          c_basis_end              date,
          c_legal_entity_id        hr_organization_units.organization_id%type,
          c_er_position_seg_type   hr_organization_information.org_information18
%type) is

   select decode(fifs.application_column_name, 'SEGMENT1', ppd.segment1,
                                               'SEGMENT2', ppd.segment2,
                                               'SEGMENT3', ppd.segment3,
                                               'SEGMENT4', ppd.segment4,
                                               'SEGMENT5', ppd.segment5,
                                               'SEGMENT6', ppd.segment6,
                                               'SEGMENT7', ppd.segment7,
                                               'SEGMENT8', ppd.segment8,
                                               'SEGMENT9', ppd.segment9,
                                               'SEGMENT10',ppd.segment10,
                                               'SEGMENT11',ppd.segment11,
                                               'SEGMENT12',ppd.segment12,
                                               'SEGMENT13',ppd.segment13,
                                               'SEGMENT14',ppd.segment14,
                                               'SEGMENT15',ppd.segment15,
                                               'SEGMENT16',ppd.segment16,
                                               'SEGMENT17',ppd.segment17,
                                               'SEGMENT18',ppd.segment18,
                                               'SEGMENT19',ppd.segment19,
                                               'SEGMENT20',ppd.segment20,
                                               'SEGMENT21',ppd.segment21,
                                               'SEGMENT22',ppd.segment22,
                                               'SEGMENT23',ppd.segment23,
                                               'SEGMENT24',ppd.segment24,
                                               'SEGMENT25',ppd.segment25,
                                               'SEGMENT26',ppd.segment26,
                                               'SEGMENT27',ppd.segment27,
                                               'SEGMENt28',ppd.segment28,
                                               'SEGMENT29',ppd.segment29,
                                               'SEGMENT30',ppd.segment30)
   from per_assignments_f  assign,
        hr_soft_coding_keyflex hsc,
        hr_all_positions_f pos,
        hr_all_positions_f_tl pst,
        per_position_definitions ppd,
        hr_organization_units hou,
        hr_organization_information hoi,
        fnd_id_flex_segments fifs,
        fnd_id_flex_structures fift
   where assign.person_id      = c_person_id
   and   assign.assignment_id  = c_assignment_id
   and   assign.soft_coding_keyflex_id  = hsc.soft_coding_keyflex_id
   and   hsc.segment1                = c_legal_entity_id
   and   assign.position_id    = pos.position_id
   and   pst.position_id    = pos.position_id
   and   pst.language       = userenv('LANG')
   and   (assign.effective_start_date <= c_basis_end
          and assign.effective_end_date >= c_basis_start)
   and   (pos.effective_start_date <= c_basis_end
          and pos.effective_end_date >= c_basis_start)
   and   assign.assignment_type = 'E'
   and   assign.business_group_id = hou.business_group_id
   and   hsc.segment1 = hou.organization_id
   and   hou.business_group_id = hoi.organization_id
   and   hoi.org_information_context = 'Business Group Information'
   and   hoi.org_information10 = 'SGD'
   and   hoi.org_information8 = fift.id_flex_num
   and   fifs.id_flex_num = fift.id_flex_num
   and   fifs.application_id = '800'
   and   fifs.application_id = fift.application_id
   and   fifs.id_flex_code = 'POS'
   and   fifs.id_flex_code = fift.id_flex_code
   and   fifs.segment_name = c_er_position_seg_type
   and   pos.position_definition_id = ppd.position_definition_id
   and     assign.effective_start_date =
                (select max(paf1.effective_start_date)
                 from   per_assignments_f paf1
                 where  paf1.person_id = assign.person_id
                 and    paf1.assignment_id = assign.assignment_id
                 and    paf1.soft_coding_keyflex_id = assign.soft_coding_keyflex_id
                 and    paf1.effective_start_date <= c_basis_end
                 and    paf1.effective_end_date >= c_basis_start); /* Bug 5868910 */

  ---------------------------------------------------------------------------
  -- Bug 4688761 - Modified cursor to check the legal entity, and need get the
  -- latest primary assignment
  -- Bug 4890964 - Modified cursor to remove the latest assignment check, now
  -- we pass the assignment_id as a parameter
  ---------------------------------------------------------------------------

   cursor other
      ( c_person_id         per_all_people_f.person_id%type,
        c_assignment_id     per_all_assignments_f.assignment_id%type,
        c_legal_entity_id   hr_organization_units.organization_id%type,
        c_basis_start  date,
        c_basis_end    date) is

   select  /*+ USE_NL(aei) */
           aei.aei_information1
   from    per_assignments_f assign,
           per_assignment_extra_info aei,
           hr_soft_coding_keyflex hsc
   where   assign.person_id      = c_person_id
   and     assign.assignment_id  = c_assignment_id
   and     assign.assignment_id = aei.assignment_id
   and     assign.soft_coding_keyflex_id  = hsc.soft_coding_keyflex_id
   and     hsc.segment1                = c_legal_entity_id
   and     aei.information_type = 'HR_JOB_DESIGNATION_SG'
   and     aei.aei_information1 is not NULL
   and     assign.assignment_type = 'E';
  --
  begin
     if g_debug then
           hr_utility.set_location('pysgirar: Start of archive_job_designation',10);
     end if;
     ------------------------------------------------------------------------
     -- Check selected Job Designation Type
     -- Bug 4688761, added p_legal_eneity_id
     ------------------------------------------------------------------------
     if p_er_designation_type = 'G' then
        open grade (p_person_id
                  , p_assignment_id
                  , p_legal_entity_id
                  , p_basis_start
                  , p_basis_end);
        fetch grade into v_designation;
        close grade;

     elsif p_er_designation_type = 'J' then
        open job (p_person_id
                , p_assignment_id
                , p_legal_entity_id
                , p_basis_start
                , p_basis_end);
        fetch job into v_designation;
        close job;

     elsif p_er_designation_type = 'P' then
        if p_er_position_seg_type is null then
           open position (p_person_id
                        , p_assignment_id
                        , p_legal_entity_id
                        , p_basis_start
                        , p_basis_end);
           fetch position into v_designation;
           close position;
        else
           open position_seg (p_person_id
                            , p_assignment_id
                            , p_basis_start
                            , p_basis_end
                            , p_legal_entity_id
                            , p_er_position_seg_type);
           fetch position_seg into v_designation;
           close position_seg;
        end if;

     elsif p_er_designation_type = 'O' then
        open other (p_person_id
                  , p_assignment_id
                  , p_legal_entity_id
                  , p_basis_start
                  , p_basis_end);
        fetch other into v_designation;
        close other;
     end if;

     archive_item ('X_ASG_DESIGNATION', p_assignment_action_id, v_designation);
     --
     if g_debug then
          hr_utility.set_location('pysgirar: End of archive_job_designation',10);
     end if;
  end archive_job_designation;
  ---------------------------------------------------------------------------
  -- Selects information for Overseas Assignments, which is indicated by
  -- having the CPF Overseas Post Obligatory Indicator entered for an
  -- assignment whose duration is within Basis Year.
  ---------------------------------------------------------------------------
  procedure archive_os_assignment
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_legal_entity_id       in hr_organization_units.organization_id%type,
       p_basis_start           in date,
       p_basis_end             in date )
  is
  --
  v_cpf_overseas_post_obligatory  per_assignment_extra_info.aei_information1%type;
  v_start_date                    varchar2(30);
  v_end_date                      varchar2(30);
  ---------------------------------------------------------------------------
  -- Bug# 2920732 - Modified the cursor to use the secured view per_assignments_f
  -- Bug# 3257843  -Modified the cursor now it selects minimum effective start date
  --                and maximum effective end date of the assignment
  --                previously it was selecting last assignemnt of the basis year.
  --
  -- Bug# 4688761 - Modified cursor to check the legal entity
  ---------------------------------------------------------------------------
  cursor os_assignment
     ( c_person_id            per_all_people_f.person_id%type,
       c_legal_entity_id      hr_organization_units.organization_id%type,
       c_basis_start          date,
       c_basis_end            date )
  is
  select  aei.aei_information1,
          min(fnd_date.date_to_canonical(assign.effective_start_date)),
          max(fnd_date.date_to_canonical(nvl(assign.effective_end_date,c_basis_end)))
  from    per_assignments_f assign,
          per_assignment_extra_info aei,
          hr_soft_coding_keyflex hsc
  where   assign.person_id       = c_person_id
  and     assign.assignment_id   = aei.assignment_id
  and     assign.soft_coding_keyflex_id  = hsc.soft_coding_keyflex_id
  and     hsc.segment1                = c_legal_entity_id
  and     aei.information_type   = 'HR_IR8S_INDICATORS_SG'
  and     aei.aei_information1   is not NULL  -- CPF overseas post obligatory flag, bug 2261267, 2373475
  and     assign.effective_start_date <= c_basis_end
  and     assign.effective_end_date    >= c_basis_start
  and     assign.assignment_type = 'E' /* Bug 5033609 */
          group by aei.aei_information1;
  --
  begin
     if g_debug then
          hr_utility.set_location('pysgirar: Start of archive_os_assignment',10);
     end if;
     --
     open os_assignment (p_person_id, p_legal_entity_id, p_basis_start, p_basis_end);
     fetch os_assignment into v_cpf_overseas_post_obligatory,
                              v_start_date, v_end_date;
     --
     if os_assignment%found then
          archive_item ('X_HR_IR8S_INDICATORS_SG_ASG_CPF_OVERSEAS_POST_OBLIGATORY',
                        p_assignment_action_id, v_cpf_overseas_post_obligatory);
          archive_item ('X_ASG_OVERSEAS_DATE_FROM', p_assignment_action_id, v_start_date);
          archive_item ('X_ASG_OVERSEAS_DATE_TO', p_assignment_action_id, v_end_date);
     end if;
     --
     close os_assignment;
     if g_debug then
          hr_utility.set_location('pysgirar: End of archive_os_assignment',20);
     end if;
  end archive_os_assignment;

  ---------------------------------------------------------------------------
  -- Selects information for Shares information, which is entered via assignment
  -- extra information screen, bug 2475287
  ---------------------------------------------------------------------------
  procedure archive_shares_details
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_tax_unit_id           in ff_archive_item_contexts.context%type,
       p_basis_start           in date,
       p_basis_end             in date )
  is
  --
  v_moa_305    number;
  v_moa_319    number;
  v_moa_339    number;
  v_moa_601    number;
  v_moa_352    number;
  v_moa_355    number;
  v_moa_358    number;
  v_moa_602    number;
  v_moa_348    number; /* Bug 7415444 */
  v_moa_347    number;
  v_grant_type_error char(1);
  v_eesop_date_error char(1);
  v_csop_date_error char(1);
  v_nsop_date_error char(1);
  v_esop_count number;
  v_eesop_count number;
  v_csop_count number;
  v_nsop_count number;
  v_a8b_data_error char(1);
  v_a8b_files char(1);
  v_archive char(1);


  ---------------------------------------------------------------------------
  -- Bug# 2920732 - Modified the cursor to use the secured view per_assignments_f
  -- bug 2691877
  -- bug 3501956 - Changed cursor to select information from per_people_extra_info table
  -- Bug 4314453 - Modified the cursor to use the table instead of view
  -- Bug 5435088 - Added grant type
  ---------------------------------------------------------------------------
  cursor shares_details
     ( c_person_id     per_all_people_f.person_id%type,
       c_basis_start   date,
       c_basis_end     date )
  is
  select  distinct pei.person_extra_info_id,
	  pei.pei_information1 stock_option,
          pei.pei_information3 exercise_price,
	  pei.pei_information4 market_exercise_value,
          to_char(fnd_date.canonical_to_date(pei.pei_information5),'YYYY')||'/'||to_char(fnd_date.canonical_to_date(pei.pei_information5),'MM')||'/'||
          to_char(fnd_date.canonical_to_date(pei.pei_information5),'DD') exercise_date,
          pei.pei_information6 shares_acquired,
	  hoi1.org_information1 name_of_company,
	  hoi1.org_information4 RCB,
          hoi1.org_information15 company_type,
	  pei2.pei_information2 market_grant_value,
          pei2.pei_information5 grant_type,
          decode(pei2.pei_information3, null, null, to_char(fnd_date.canonical_to_date(pei2.pei_information3),'YYYY')||'/'||
          to_char(fnd_date.canonical_to_date(pei2.pei_information3),'MM')||'/'||to_char(fnd_date.canonical_to_date(pei2.pei_information3),'DD')) grant_date,
          pei2.pei_information4 shares_granted
  from    per_all_people_f pap,
          per_people_extra_info  pei,
	  per_people_extra_info  pei2,
          hr_all_organization_units hou,
          hr_organization_information hoi2,
          hr_organization_information hoi1
  where   pap.person_id = c_person_id
  and     pap.person_id = pei.person_id
  and     pei.information_type = 'HR_STOCK_EXERCISE_SG'
  and     pap.person_id = pei2.person_id
  and     pei.pei_information2 = pei2.person_extra_info_id
  and     pei2.information_type = 'HR_STOCK_GRANT_SG'
  and     pei2.pei_information1 = hou.organization_id
  and     hou.organization_id = hoi1.organization_id(+)
  and     hou.organization_id = hoi2.organization_id
  and     hoi1.org_information_context||'' = 'SG_LEGAL_ENTITY'
  and     hoi2.org_information_context||'' = 'CLASS'
  and     hoi2.org_information1 = 'HR_LEGAL'
  and     hoi2.org_information2 = 'Y'
  and     to_char(fnd_date.canonical_to_date(pei.pei_information5),'YYYY') = to_char(c_basis_end,'YYYY') /* Bug#2684645 */
  and     (pap.effective_start_date <= c_basis_end and pap.effective_end_date >= c_basis_start);
  --
  begin
     v_moa_305    := 0;
     v_moa_319    := 0;
     v_moa_339    := 0;
     v_moa_601    := 0;
     v_moa_352    := 0;
     v_moa_355    := 0;
     v_moa_358    := 0;
     v_moa_602    := 0;
     v_moa_348    := 0;
     v_moa_347    := 0;
     v_grant_type_error := 'N';
     v_eesop_date_error := 'N';
     v_csop_date_error := 'N';
     v_nsop_date_error := 'N';
     v_a8b_data_error := 'N';
     v_archive := 'N';
     v_a8b_files := 'N';
     v_esop_count := 0;
     v_eesop_count := 0;
     v_nsop_count := 0;
     v_csop_count := 0;

     if g_debug then
          hr_utility.set_location('pysgirar: Start of archive_shares_details', 10);
     end if;
     --
     v_archive := 'N';
     -- modified for bug 5435088
     for share_rec in shares_details (p_person_id, p_basis_start, p_basis_end)
     loop
	    --
        if share_rec.grant_type is null then
           v_grant_type_error := 'Y';
        end if;

        if v_a8b_data_error = 'N' then
            if share_rec.shares_acquired <= 0 or (share_rec.market_exercise_value - share_rec.exercise_price) < 0 then
              v_a8b_data_error := 'Y';
            end if;
        end if;

        if share_rec.stock_option = 'E' then
          if v_esop_count < 15 then
            if share_rec.grant_type = 'P' and to_date(share_rec.grant_date, 'YYYY/MM/DD') < to_date('2002/12/31','YYYY/MM/DD') then
              v_moa_305 := (share_rec.market_exercise_value - share_rec.exercise_price) * share_rec.shares_acquired + v_moa_305; /* Bug 3204837 */
            else
              v_moa_352 := (share_rec.market_exercise_value - share_rec.exercise_price) * share_rec.shares_acquired + v_moa_352; /* Bug 3204837 */
            end if;
            v_esop_count := v_esop_count + 1;
            v_archive := 'Y';
          end if;
        end if;

        if share_rec.stock_option = 'EE' then
          if v_eesop_count < 15 then
            if share_rec.grant_type = 'P' and to_date(share_rec.grant_date, 'YYYY/MM/DD') < to_date('2002/12/31','YYYY/MM/DD') then
              v_moa_319 := trunc((share_rec.market_exercise_value - share_rec.market_grant_value) * share_rec.shares_acquired,2) + trunc((share_rec.market_grant_value - share_rec.exercise_price) * share_rec.shares_acquired, 2) + v_moa_319;
            else
              v_moa_355 := trunc((share_rec.market_exercise_value - share_rec.market_grant_value) * share_rec.shares_acquired,2) + trunc((share_rec.market_grant_value - share_rec.exercise_price) * share_rec.shares_acquired, 2) + v_moa_355;
            end if;
            v_eesop_count := v_eesop_count + 1;
            v_archive := 'Y';
          end if;
        end if;

        if share_rec.stock_option = 'C' then
          if v_csop_count < 15 then
            if share_rec.grant_type = 'P' and to_date(share_rec.grant_date, 'YYYY/MM/DD') < to_date('2002/12/31','YYYY/MM/DD') then
              v_moa_339 := trunc((share_rec.market_exercise_value - share_rec.market_grant_value) * share_rec.shares_acquired,2) + trunc((share_rec.market_grant_value - share_rec.exercise_price) * share_rec.shares_acquired, 2) + v_moa_339;
            else
              v_moa_358 := trunc((share_rec.market_exercise_value - share_rec.market_grant_value) * share_rec.shares_acquired,2) + trunc((share_rec.market_grant_value - share_rec.exercise_price) * share_rec.shares_acquired, 2) + v_moa_358;
            end if;
          v_csop_count := v_csop_count + 1;
          v_archive := 'Y';
          end if;
        end if;

       if share_rec.stock_option = 'N' then
          if v_nsop_count < 15 then
            if not (share_rec.grant_type = 'P' and to_date(share_rec.grant_date, 'YYYY/MM/DD') < to_date('2002/12/31','YYYY/MM/DD')) then
              v_moa_348 := (share_rec.market_exercise_value - share_rec.exercise_price) * share_rec.shares_acquired + v_moa_348;
              v_moa_347 := (share_rec.market_grant_value - share_rec.exercise_price) * share_rec.shares_acquired + v_moa_347;
            end if;
            v_nsop_count := v_nsop_count + 1;
            v_archive := 'Y';
         end if;
       end if;

        if v_archive = 'Y' then
          archive_item_3('X_A8B_COMPANY', p_assignment_action_id, share_rec.name_of_company, p_tax_unit_id, share_rec.person_extra_info_id);
          archive_item_3('X_A8B_RCB', p_assignment_action_id, share_rec.RCB, p_tax_unit_id, share_rec.person_extra_info_id);
          archive_item_3('X_A8B_COMPANY_TYPE', p_assignment_action_id, share_rec.company_type, p_tax_unit_id, share_rec.person_extra_info_id);
          archive_item_3('X_A8B_OPTION', p_assignment_action_id, share_rec.stock_option, p_tax_unit_id, share_rec.person_extra_info_id);
          archive_item_3('X_A8B_MK_EXER_VALUE', p_assignment_action_id, share_rec.market_exercise_value, p_tax_unit_id, share_rec.person_extra_info_id);
          archive_item_3('X_A8B_MK_GRANT_VALUE', p_assignment_action_id, share_rec.market_grant_value, p_tax_unit_id, share_rec.person_extra_info_id);
          archive_item_3('X_A8B_SHARES_ACQUIRED', p_assignment_action_id, share_rec.shares_acquired, p_tax_unit_id, share_rec.person_extra_info_id);
          archive_item_3('X_A8B_EXER_PRICE', p_assignment_action_id, share_rec.exercise_price, p_tax_unit_id, share_rec.person_extra_info_id);
          archive_item_3('X_A8B_EXERCISED_DATE', p_assignment_action_id, share_rec.exercise_date, p_tax_unit_id, share_rec.person_extra_info_id);
          archive_item_3('X_A8B_GRANTED_DATE', p_assignment_action_id, share_rec.grant_date, p_tax_unit_id, share_rec.person_extra_info_id);
        -- Added for bug 5435088
          archive_item_3('X_A8B_GRANT_TYPE', p_assignment_action_id, share_rec.grant_type, p_tax_unit_id, share_rec.person_extra_info_id);

          if share_rec.stock_option = 'EE' and v_eesop_date_error = 'N' then
             if ((share_rec.grant_type = 'P' and
                  to_date(share_rec.grant_date, 'YYYY/MM/DD')
                    < to_date('2000/06/01','YYYY/MM/DD')) or
                 (share_rec.grant_type = 'W' and
                  to_date(share_rec.grant_date, 'YYYY/MM/DD')
                    < to_date('2002/01/01','YYYY/MM/DD'))) then
                v_eesop_date_error := 'Y';
             end if;
          elsif share_rec.stock_option = 'C' and v_csop_date_error = 'N' then
             if ((share_rec.grant_type = 'P' and
                  to_date(share_rec.grant_date, 'YYYY/MM/DD')
                    < to_date('2001/04/01','YYYY/MM/DD')) or
                 (share_rec.grant_type = 'W' and
                  to_date(share_rec.grant_date, 'YYYY/MM/DD')
                    < to_date('2002/01/01','YYYY/MM/DD'))) then
                v_csop_date_error := 'Y';
             end if;
          elsif share_rec.stock_option = 'N' and v_nsop_date_error = 'N' then
             if  (to_date(share_rec.grant_date, 'YYYY/MM/DD') between
                to_date('2008/02/16','YYYY/MM/DD') and
                        to_date('2013/02/15','YYYY/MM/DD')) and
               (to_date(share_rec.grant_date, 'YYYY/MM/DD') between
                  fnd_date.canonical_to_date(g_er_incorp_date_1) and
                   fnd_date.canonical_to_date(g_er_incorp_date_2)) then
                  null;
             else
                v_nsop_date_error := 'Y';
             end if;
           end if;
        end if;
        v_archive := 'N';
     end loop;
     --
     v_moa_601 := v_moa_305 + v_moa_319 + v_moa_339;
     v_moa_602 := v_moa_352 + v_moa_355 + v_moa_358 + v_moa_348;


     if v_moa_601 <> 0 or v_moa_602 <> 0 then
       archive_item_2 ('X_A8B_MOA_601', p_assignment_action_id, v_moa_601, p_tax_unit_id);
       archive_item_2 ('X_A8B_MOA_602', p_assignment_action_id, v_moa_602, p_tax_unit_id);
       archive_item_2 ('X_A8B_MOA_347', p_assignment_action_id, v_moa_347, p_tax_unit_id);
       archive_item ('X_PER_GRANT_TYPE_ERROR', p_assignment_action_id, v_grant_type_error);
       archive_item ('X_PER_A8B_NSOP_DATE_ERROR', p_assignment_action_id, v_nsop_date_error);
       archive_item ('X_PER_A8B_EESOP_DATE_ERROR', p_assignment_action_id, v_eesop_date_error);
       archive_item ('X_PER_A8B_CSOP_DATE_ERROR', p_assignment_action_id, v_csop_date_error);
       archive_item ('X_PER_A8B_DATA_ERROR', p_assignment_action_id, v_a8b_data_error);

       if v_esop_count > 15 or v_eesop_count > 15
                 or v_csop_count > 15 or v_nsop_count > 15 then
           archive_item ('X_PER_A8B_COUNT_ERROR', p_assignment_action_id, '1');
       end if;

       if v_moa_348 <> 0 then
         g_a8b_moa_348 := g_a8b_moa_348 + v_moa_348;
         if g_er_incorp_date is null then
           archive_item ('X_PER_A8B_INCORP_DATE_ERROR', p_assignment_action_id, 'Y');
         end if;
       end if;
     end if;

     if g_debug then
          hr_utility.set_location('pysgirar: End of archive_share_details', 100);
     end if;
  end archive_shares_details;

  ---------------------------------------------------------------------------
  -- Selects information for IR8S C claimed/to be claimed details information,
  -- which is entered via assignment extra information screen, bug 3027801
  ---------------------------------------------------------------------------
  procedure archive_ir8s_c_details
    (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
     p_person_id             in per_all_people_f.person_id%type,
     p_tax_unit_id           in ff_archive_item_contexts.context%type,
     p_business_group_id     in per_assignments_f.business_group_id%type,
     p_basis_start           in date,
     p_basis_end             in date) is

 /* Type to store the person ids with same national_identifier */

  type person_id_store_rec is record
    (person_id      per_all_people_f.person_id%type);

  type person_id_tab is table of person_id_store_rec index by binary_integer;
  person_id_rec  person_id_tab;

    cursor ir8s_c_invalid_records
      (c_person_id         per_all_people_f.person_id%type,
       c_tax_unit_id       ff_archive_item_contexts.context%type,
       c_business_group_id per_assignments_f.business_group_id%type,
       c_basis_start       date,
       c_basis_end         date) is

    select count(distinct (paei.assignment_extra_info_id))
    from per_assignment_extra_info paei,
         per_assignments_f paa,
         hr_soft_coding_keyflex hsc
    where paa.person_id = c_person_id
    and   paa.assignment_id    = paei.assignment_id
    and   paa.soft_coding_keyflex_id  = hsc.soft_coding_keyflex_id
    and   hsc.segment1                = c_tax_unit_id
    and   paa.business_group_id       = c_business_group_id
    and   paa.assignment_type = 'E' /* Bug 5033609 */
    and   paei.information_type = 'HR_CPF_CLAIMED_SG'
    and   paei.aei_information1 = to_char(c_basis_end,'YYYY')
    and   (paa.effective_start_date <= c_basis_end
           and paa.effective_end_date >= c_basis_start);

    l_person_id                     per_all_people_f.person_id%type;
    l_temp_person_id                per_all_people_f.person_id%type;
    l_archive_person_id             per_all_people_f.person_id%type;
    counter            number;
    l_counter          number;
    duplicate_exists   varchar2(1);
    l_total_counts     number;
    l_ir8s_c_counts    number;

 begin
    l_temp_person_id  := NULL;
    l_counter         := 1;
    duplicate_exists  := 'N';
    l_total_counts    := 0;
    --
    if g_debug then
         hr_utility.set_location('pysgirar: Start of archive_ir8s_c_details', 10);
    end if;
    ----------------------------------------------------------------------------------
    -- Added for bug 3162319
    -- Bug 3435334 Table g_person_id_tab is populated with duplicate records for current person
    -- in employee_if_latest( ) function
    ----------------------------------------------------------------------------------
    if g_person_id_tab.count > 1 then
          for l_person_id in g_person_id_tab.first..g_person_id_tab.last
          loop
                 person_id_rec(l_counter).person_id := g_person_id_tab(l_person_id);
                 l_counter := l_counter+1;
          end loop;
          --
          duplicate_exists :='Y';
    end if;
    --
    if duplicate_exists = 'N' then
        person_id_rec(l_counter).person_id := p_person_id;
    end if;
    --
    if person_id_rec.count>0 then
      l_total_counts := 0;
      for l_person_counter in 1..person_id_rec.last
        loop
          if person_id_rec.exists(l_person_counter) then
             l_archive_person_id := person_id_rec(1).person_id;
             --
             open ir8s_c_invalid_records (
                   person_id_rec(l_person_counter).person_id,
                   p_tax_unit_id,
                   p_business_group_id,
                   p_basis_start,
                   p_basis_end);
             fetch ir8s_c_invalid_records into l_ir8s_c_counts;

             if ir8s_c_invalid_records%found then
               l_total_counts := l_total_counts + l_ir8s_c_counts;
             end if;
             --
             close ir8s_c_invalid_records;
             archive_ir8s_c_detail_moas(p_assignment_action_id
                                     ,person_id_rec(1).person_id
                                     ,person_id_rec(l_person_counter).person_id
                                     ,p_tax_unit_id
                                     ,p_business_group_id
                                     ,p_basis_start
                                     ,p_basis_end);
           end if;
         end loop;

         if l_total_counts = 0 then
           archive_item_3('X_MOA410', p_assignment_action_id, 0, p_tax_unit_id, 0);
           archive_item('X_IR8S_TOTAL_MOA410', p_assignment_action_id, 0);
         end if;

         if l_total_counts >3 then
             archive_item ('X_IR8S_C_INVALID_RECORDS',
                            p_assignment_action_id, 'N');
         else
             archive_item ('X_IR8S_C_INVALID_RECORDS',
                            p_assignment_action_id, 'Y');
         end if;

    end if;
    --
    if g_debug then
         hr_utility.set_location('pysgirar: End of archive_ir8s_c_details', 100);
    end if;
 end archive_ir8s_c_details;


 procedure archive_ir8s_c_detail_moas
    (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
     p_1_person_id           in per_all_people_f.person_id%type,
     p_person_id             in per_all_people_f.person_id%type,
     p_tax_unit_id           in ff_archive_item_contexts.context%type,
     p_business_group_id     in per_assignments_f.business_group_id%type,
     p_basis_start           in date,
     p_basis_end             in date) is

    cursor ir8s_c_details
      (c_person_id           per_assignments_f.person_id%type,
       c_tax_unit_id         ff_archive_item_contexts.context%type,
       c_business_group_id   per_assignments_f.business_group_id%type,
       c_basis_start         date,
       c_basis_end           date) is

    select distinct aei.assignment_extra_info_id,
           aei.aei_information2 add_wages,
           aei.aei_information3 add_wages_from_date,
           aei.aei_information4 add_wages_to_date,
           aei.aei_information5 pay_date_add_wages,
           aei.aei_information6 er_cpf,
           aei.aei_information7 er_cpf_interest,
           aei.aei_information8 er_cpf_date,
           aei.aei_information9 ee_cpf,
           aei.aei_information10 ee_cpf_interest,
           aei.aei_information11 ee_cpf_date
    from   per_assignments_f ass,
           per_assignment_extra_info aei,
           hr_soft_coding_keyflex hsc
    where  ass.person_id = c_person_id
    and    ass.assignment_id = aei.assignment_id
    and    ass.soft_coding_keyflex_id  = hsc.soft_coding_keyflex_id
    and    hsc.segment1                = c_tax_unit_id
    and    ass.business_group_id       = c_business_group_id
    and    ass.assignment_type = 'E' /* Bug 5033609 */
    and    aei.information_type = 'HR_CPF_CLAIMED_SG'
    and    aei.aei_information1 = to_char(c_basis_end,'YYYY')
    and    nvl(to_char(fnd_date.canonical_to_date(aei.aei_information3),'YYYY'), aei.aei_information1) = aei.aei_information1
    and    nvl(to_char(fnd_date.canonical_to_date(aei.aei_information4),'YYYY'), aei.aei_information1) = aei.aei_information1
    and    nvl(to_char(fnd_date.canonical_to_date(aei.aei_information5),'YYYY'), aei.aei_information1) = aei.aei_information1
    and    (ass.effective_start_date <= c_basis_end
             and ass.effective_end_date >= c_basis_start);
   /* Bug 6020961, removed date in year check for er_cpf_date and ee_cpf_date */


   v_ir8s_total_moa410  number;

   begin
    v_ir8s_total_moa410  := 0;
    if g_debug then
          hr_utility.set_location('pysgirar: Start of archive_ir8s_c_detail_moas', 10);
    end if;
    --
    for ir8s_c_rec in ir8s_c_details (p_person_id
	                            , p_tax_unit_id
                                    , p_business_group_id
                                    , p_basis_start
                                    , p_basis_end)
    loop

        archive_item_3('X_MOA410', p_assignment_action_id, ir8s_c_rec.add_wages,
                        p_tax_unit_id, ir8s_c_rec.assignment_extra_info_id);
        archive_item_3('X_DTM502', p_assignment_action_id,
                        ir8s_c_rec.add_wages_from_date,
                        p_tax_unit_id, ir8s_c_rec.assignment_extra_info_id);
        archive_item_3('X_DTM503', p_assignment_action_id,
                        ir8s_c_rec.add_wages_to_date,
                        p_tax_unit_id, ir8s_c_rec.assignment_extra_info_id);
        archive_item_3('X_DTM504', p_assignment_action_id,
                        ir8s_c_rec.pay_date_add_wages,
                        p_tax_unit_id, ir8s_c_rec.assignment_extra_info_id);
        archive_item_3('X_MOA411', p_assignment_action_id, ir8s_c_rec.er_cpf,
                        p_tax_unit_id, ir8s_c_rec.assignment_extra_info_id);
        archive_item_3('X_MOA412', p_assignment_action_id,
                        ir8s_c_rec.er_cpf_interest,
                        p_tax_unit_id, ir8s_c_rec.assignment_extra_info_id);
        archive_item_3('X_DTM505', p_assignment_action_id,
                        ir8s_c_rec.er_cpf_date,
                        p_tax_unit_id, ir8s_c_rec.assignment_extra_info_id);
        archive_item_3('X_MOA413', p_assignment_action_id, ir8s_c_rec.ee_cpf,
                        p_tax_unit_id, ir8s_c_rec.assignment_extra_info_id);
        archive_item_3('X_MOA414', p_assignment_action_id,
                        ir8s_c_rec.ee_cpf_interest,
                        p_tax_unit_id, ir8s_c_rec.assignment_extra_info_id);
        archive_item_3('X_DTM506', p_assignment_action_id,
                        ir8s_c_rec.ee_cpf_date,
                        p_tax_unit_id, ir8s_c_rec.assignment_extra_info_id);

        v_ir8s_total_moa410 := ir8s_c_rec.add_wages;

    end loop;

    archive_item('X_IR8S_TOTAL_MOA410', p_assignment_action_id, v_ir8s_total_moa410);
    --
    if g_debug then
          hr_utility.set_location('pysgirar: End of archive_ir8s_c_detail_moas', 100);
    end if;
  end archive_ir8s_c_detail_moas;
  ---------------------------------------------------------------------------
  -- Calls the archive utility to actually perform the archive of the item.
  ---------------------------------------------------------------------------
  procedure archive_item
     ( p_user_entity_name      in ff_user_entities.user_entity_name%type,
       p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_archive_value         in ff_archive_items.value%type )
  is
  --
  v_user_entity_id         ff_user_entities.user_entity_id%type;
  v_archive_item_id        ff_archive_items.archive_item_id%type;
  v_object_version_number  ff_archive_items.object_version_number%type;
  v_some_warning           boolean;
  ---------------------------------------------------------------------------
  -- Cursor User_Entity_ID
  ---------------------------------------------------------------------------
  cursor user_entity_id
     ( c_user_entity_name  ff_user_entities.user_entity_name%type )
  is
  select  user_entity_id
  from    ff_user_entities
  where   user_entity_name = c_user_entity_name;
  --
  begin
     if g_debug then
          hr_utility.set_location('Start of archive_item',10);
     end if;
     --
     open user_entity_id (p_user_entity_name);
     fetch user_entity_id into v_user_entity_id;
     close user_entity_id;
     --
     ff_archive_api.create_archive_item
          ( p_validate               => false
            ,p_archive_item_id       => v_archive_item_id
            ,p_user_entity_id        => v_user_entity_id
            ,p_archive_value         => p_archive_value
            ,p_archive_type          => 'AAP'
            ,p_action_id             => p_assignment_action_id
            ,p_legislation_code      => 'SG'
            ,p_object_version_number => v_object_version_number
            ,p_context_name1         => 'ASSIGNMENT_ACTION_ID'
            ,p_context1              => p_assignment_action_id
            ,p_some_warning          => v_some_warning);
     --
     if g_debug then
           hr_utility.set_location('End of archive_item',20);
     end if;
  end archive_item;

  -----------------------------------------------------------------------------
  -- Calls the archive utility to actually perform the archive of the item with
  -- one another context
  -----------------------------------------------------------------------------
  procedure archive_item_2
     ( p_user_entity_name      in ff_user_entities.user_entity_name%type,
       p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_archive_value         in ff_archive_items.value%type,
       p_context_value2        in ff_archive_item_contexts.context%type )
  is
  --
  v_user_entity_id         ff_user_entities.user_entity_id%type;
  v_archive_item_id        ff_archive_items.archive_item_id%type;
  v_object_version_number  ff_archive_items.object_version_number%type;
  v_some_warning           boolean;
  ---------------------------------------------------------------------------
  -- Cursor User_Entity_ID
  ---------------------------------------------------------------------------
  cursor user_entity_id
       ( c_user_entity_name  ff_user_entities.user_entity_name%type )
  is
  select  user_entity_id
  from    ff_user_entities
  where   user_entity_name = c_user_entity_name;
  --
  begin
     if g_debug then
           hr_utility.set_location('Start of archive_item_2',10);
     end if;
     --
     open user_entity_id (p_user_entity_name);
     fetch user_entity_id into v_user_entity_id;
     close user_entity_id;
     --
     ff_archive_api.create_archive_item
          ( p_validate               => false
            ,p_archive_item_id       => v_archive_item_id
            ,p_user_entity_id        => v_user_entity_id
            ,p_archive_value         => p_archive_value
            ,p_archive_type          => 'AAP'
            ,p_action_id             => p_assignment_action_id
            ,p_legislation_code      => 'SG'
            ,p_object_version_number => v_object_version_number
            ,p_context_name1         => 'ASSIGNMENT_ACTION_ID'
            ,p_context1              => p_assignment_action_id
            ,p_context_name2         => 'ORGANIZATION_ID'
            ,p_context2              => p_context_value2
            ,p_some_warning          => v_some_warning);
     --
     if g_debug then
           hr_utility.set_location('End of archive_item_2',20);
     end if;
  end archive_item_2;

  -----------------------------------------------------------------------------
  -- Calls the archive utility to actually perform the archive of the item with
  -- one another context
  -----------------------------------------------------------------------------
  procedure archive_item_3
      ( p_user_entity_name      in ff_user_entities.user_entity_name%type,
        p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
        p_archive_value         in ff_archive_items.value%type,
        p_context_value2        in ff_archive_item_contexts.context%type,
        p_context_value3        in ff_archive_item_contexts.context%type )
  is
  --
  v_user_entity_id         ff_user_entities.user_entity_id%type;
  v_archive_item_id        ff_archive_items.archive_item_id%type;
  v_object_version_number  ff_archive_items.object_version_number%type;
  v_some_warning           boolean;
  ---------------------------------------------------------------------------
  -- Cursor User_Entity_ID
  ---------------------------------------------------------------------------
  cursor user_entity_id
      ( c_user_entity_name  ff_user_entities.user_entity_name%type )
  is
  select  user_entity_id
  from    ff_user_entities
  where   user_entity_name = c_user_entity_name;
  --
  begin
     if g_debug then
           hr_utility.set_location('Start of archive_item_3',10);
     end if;
     --
     open user_entity_id (p_user_entity_name);
     fetch user_entity_id into v_user_entity_id;
     close user_entity_id;
     --
     ff_archive_api.create_archive_item
         ( p_validate               => false
           ,p_archive_item_id       => v_archive_item_id
           ,p_user_entity_id        => v_user_entity_id
           ,p_archive_value         => p_archive_value
           ,p_archive_type          => 'AAP'
           ,p_action_id             => p_assignment_action_id
           ,p_legislation_code      => 'SG'
           ,p_object_version_number => v_object_version_number
           ,p_context_name1         => 'ASSIGNMENT_ACTION_ID'
           ,p_context1              => p_assignment_action_id
           ,p_context_name2         => 'TAX_UNIT_ID'
           ,p_context2              => p_context_value2
           ,p_context_name3         => 'SOURCE_ID'
           ,p_context3              => p_context_value3
           ,p_some_warning          => v_some_warning );
     --
     if g_debug then
           hr_utility.set_location('End of archive_item_3',20);
     end if;
  end archive_item_3;
     --------------------------------------------------------------------------------
     -- Bug 3118540 -
     -- Bug 3435334 - This function removes setup action when ran for IRAS Line Archive /
     -- initiates SRS 'IR8S Ad Hoc Printed Archive' when ran for IR8S adhoc archive
     --------------------------------------------------------------------------------
     procedure deinit_code ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type )
     is
          l_report_type    varchar2(20);
          l_rep_req_id     number;
          v_setup_action   pay_payroll_actions.payroll_action_id%type;
     begin
          l_rep_req_id  := 0;
	  v_setup_action := 0;
          if g_debug then
              hr_utility.set_location('pysgirar: Start of deinit_code',10);
          end if;
          --
          select  report_type
          into    l_report_type
          from    pay_payroll_actions ppa
          where   ppa.payroll_action_id = p_payroll_action_id ;
          --
          if l_report_type = 'SG_IR8S_ADHOC_REPORT' then
                l_rep_req_id := FND_REQUEST.SUBMIT_REQUEST (
 	                   application          =>   'PAY',
                           program              =>   'PYSG8SAD',
                           argument1            =>   'P_ASSIGNMENT_SET_ID=' || g_assignment_set_id,
                           argument2            =>   'P_BASIS_YEAR=' || g_basis_year,
                           argument3            =>   'P_BUSINESS_GROUP_ID='|| g_business_group_id,
                           argument4            =>   'P_LEGAL_ENTITY=' || g_legal_entity_id,
                           argument5            =>   'P_PAYROLL_ACTION_ID=' || p_payroll_action_id,
                           argument6            =>   'P_PERSON_ID=' || g_person_id,
                           argument7            =>   'P_BASIS_START=' || g_basis_start,
                           argument8            =>   'P_BASIS_END=' || g_basis_end  );
          elsif l_report_type = 'SG_IRAS_ARCHIVE' then
                select   pay_core_utils.get_parameter('SETUP_ACTION_ID',legislative_parameters)
                into     v_setup_action
                from     pay_payroll_actions
                where    payroll_action_id = p_payroll_action_id ;
                -------------------------------------------------------
		-- Bug: 3910804 Delete data from pay_action_information
		-------------------------------------------------------
                delete from pay_action_information
                where  action_context_id   = v_setup_action
                  and  action_context_type = 'AAP'
                  and  action_information_category = 'SG_IRAS_SETUP';

                py_rollback_pkg.rollback_payroll_action( v_setup_action );

                --
          end if;
     exception
          when others then
                if g_debug then
                     hr_utility.set_location('pysgirar: End of deinit_code',10);
                end if;
                raise;
     end deinit_code;
     ----------------------------------------------------------------------
     -- Bug 3435334 This function returns TRUE if no duplicate exist in
     -- system Or if current employee is latest in case duplicates exist in the system
     -- For second case it also populates global table with all its previous employement records
     ----------------------------------------------------------------------
     function employee_if_latest (  p_national_identifier    in  varchar2,
                                    p_person_id              in  per_all_people_f.person_id%type,
                                    p_setup_action_id        in  pay_payroll_actions.payroll_action_id%type,
                                    p_report_type            in  varchar2 ) return boolean
     is
         type t_person_start_date_tab    is table of per_all_people_f.start_date%type;
         g_person_start_date_tab         t_person_start_date_tab;
     begin
         g_person_id_tab.delete;
         --
         if p_national_identifier is not null and p_report_type <> 'SG_IR8S_ADHOC_REPORT' then
             begin
                  select distinct pai.action_information2 , fnd_date.canonical_to_date(pai.action_information3)
                  bulk   collect into g_person_id_tab , g_person_start_date_tab
                  from   pay_action_information pai
                  where  pai.action_information1 = p_national_identifier
                  and    pai.action_context_id   = p_setup_action_id
                  and    pai.action_context_type = 'AAP'
                  and    pai.action_information_category = 'SG_IRAS_SETUP'
                  order by fnd_date.canonical_to_date(pai.action_information3) desc;
             end;
             --
             if g_person_id_tab.count > 1 then
                  if g_person_id_tab(1) = p_person_id then
                       return true;
                  else
                       return false;
                  end if;
             else
                  return true;
             end if;
             --
         else
             return true;
         end if;
     end employee_if_latest ;

     -------------------------------------------------------------------------
     -- Bug 4688761, this function checks the same person_id has been archived
     -------------------------------------------------------------------------

     function person_if_archived (p_person_id       in per_all_people_f.person_id%type)           return boolean
     is
        l_archived_person_id binary_integer;
     begin
          if g_debug then
              hr_utility.set_location('pysgirar: Start of person_if_archived',10);
          end if;

          l_archived_person_id := p_person_id;
          if t_archived_person.exists(l_archived_person_id) then
             if (t_archived_person(l_archived_person_id).person_id = p_person_id) then
                if g_debug then
                   hr_utility.set_location('End of person_if_archived',20);
                end if;
                return true;
             end if;
          end if;
          if g_debug then
              hr_utility.set_location('End of person_if_archived',20);
          end if;
          return false;
     end person_if_archived;

     -------------------------------------------------------------------------
     -- Bug 4890964, this function checks the parameter LE if its in the latest
     -- primary assignment, it needs for share details.
     -------------------------------------------------------------------------

     function pri_if_latest
                 ( p_person_id    in per_all_people_f.person_id%type
                 , p_tax_unit_id  in ff_archive_item_contexts.context%type
                 , p_basis_start  in date
                 , p_basis_end    in date) return boolean
     is
        v_dummy varchar2(1);
        cursor pri_latest
           ( c_person_id     per_all_people_f.person_id%type,
             c_tax_unit_id   pay_assignment_actions.tax_unit_id%type,
             c_basis_start   date,
             c_basis_end     date )
        is
          select  'X'
          from    per_assignments_f paf,
                  hr_soft_coding_keyflex hsc
          where   paf.person_id = c_person_id
          and     paf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
          and     hsc.segment1 = c_tax_unit_id
          and     paf.primary_flag = 'Y'
          and     paf.assignment_type = 'E' /* Bug 5033609 */
          and     paf.effective_start_date =
                (select max(paf1.effective_start_date)
                 from   per_assignments_f paf1 /* Bug 5858566 */
                 where  paf1.person_id = paf.person_id
                 and    paf1.assignment_type = 'E' /* Bug 5033609 */
                 and    paf1.effective_start_date <= c_basis_end
                 and    paf1.effective_end_date >= c_basis_start
                 and    paf1.primary_flag = 'Y')
          and     (paf.effective_start_date <= c_basis_end and paf.effective_end_date >= c_basis_start);

     begin
          if g_debug then
              hr_utility.set_location('pysgirar: Start of pri_if_latest',10);
          end if;

          open pri_latest (p_person_id,
                              p_tax_unit_id,
                              p_basis_start,
                              p_basis_end);
          fetch pri_latest into v_dummy;
          --
          if pri_latest%found then
              close pri_latest;
              if g_debug then
                  hr_utility.set_location('End of pri_if_latest',20);
              end if;
              return TRUE;
          end if;
          close pri_latest;
          if g_debug then
             hr_utility.set_location('End of pri_if_latest',20);
          end if;
          return FALSE;

     end pri_if_latest;


     -------------------------------------------------------------------------
     -- Bug 4890964, with LE, this function gets the assignment with the latest
     -- effective_start_date with the primary defined
     -------------------------------------------------------------------------

     function pri_LE_if_latest
                 ( p_person_id    in per_all_people_f.person_id%type
                 , p_tax_unit_id  in ff_archive_item_contexts.context%type
                 , p_basis_start  in date
                 , p_basis_end    in date) return number
     is
        v_assignment_id number(10);
        cursor pri_latest_LE
           ( c_person_id     per_all_people_f.person_id%type,
             c_tax_unit_id   pay_assignment_actions.tax_unit_id%type,
             c_basis_start   date,
             c_basis_end     date )
        is
          select  paf.assignment_id
          from    per_assignments_f paf,
                  hr_soft_coding_keyflex hsc
          where   paf.person_id = c_person_id
          and     paf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
          and     hsc.segment1 = c_tax_unit_id
          and     paf.primary_flag = 'Y'
          and     paf.assignment_type = 'E' /* Bug 5033609 */
          and     paf.effective_start_date =
                (select max(paf1.effective_start_date)
                 from   per_assignments_f paf1 /* Bug 5858566 */
                 where  paf1.person_id = paf.person_id
                 and    paf1.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
                 and    paf1.assignment_type = 'E' /* Bug 5033609 */
                 and    paf1.effective_start_date <= c_basis_end
                 and    paf1.effective_end_date >= c_basis_start
                 and    paf1.primary_flag = 'Y')
          and     (paf.effective_start_date <= c_basis_end and paf.effective_end_date >= c_basis_start);

     begin
          if g_debug then
              hr_utility.set_location('pysgirar: Start of pri_LE_if_latest',10);
          end if;

          open pri_latest_LE (p_person_id,
                              p_tax_unit_id,
                              p_basis_start,
                              p_basis_end);
          fetch pri_latest_LE into v_assignment_id;
          --
          if pri_latest_LE%found then
              close pri_latest_LE;
              if g_debug then
                 hr_utility.set_location('End of pri_LE_if_latest',20);
              end if;
              return v_assignment_id;
          end if;
          close pri_latest_LE;
          if g_debug then
             hr_utility.set_location('End of pri_LE_if_latest',20);
          end if;
          return null;

     end pri_LE_if_latest;

     -------------------------------------------------------------------------
     -- Bug 4890964, with LE, this function gets the assignment with the latest
     -- effective_start_date if it has no primary defined, and if it has multi
     -- same effective_start_date, it will get the max(assignment_id)
     -- Bug 6866170, if it has multiple LEs, each LE has multi assignment
     -- records, for example, job changes. Both latest assignment of different
     -- LE has the same effective_start_date. The issue is in the first
     -- assignment that is not a primary assignment, the cursor id_latest_LE did
     -- not return an assignment_id.
     -------------------------------------------------------------------------

     function id_LE_if_latest
                  ( p_person_id    in per_all_people_f.person_id%type
                  , p_tax_unit_id  in ff_archive_item_contexts.context%type
                  , p_basis_start  in date
                  , p_basis_end    in date) return number
     is
        v_assignment_id number(10);
        cursor id_latest_LE
           ( c_person_id     per_all_people_f.person_id%type,
             c_tax_unit_id   pay_assignment_actions.tax_unit_id%type,
             c_basis_start   date,
             c_basis_end     date )
        is
          select  max(paf.assignment_id)
          from    per_assignments_f paf,
                  hr_soft_coding_keyflex hsc
          where   paf.person_id = c_person_id
          and     paf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
          and     hsc.segment1 = c_tax_unit_id
          and     paf.assignment_type = 'E'
          and     paf.effective_start_date = (
                               select max(paf1.effective_start_date)
                               from   per_assignments_f paf1 /* Bug 5858566 */
                               where  paf1.person_id = paf.person_id
                               and    paf1.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
                               and    paf1.assignment_type = 'E' /*Bug5033609*/
                               and    paf1.effective_start_date <= c_basis_end
                               and    paf1.effective_end_date >= c_basis_start)
          and     (paf.effective_start_date <= c_basis_end and paf.effective_end_date >= c_basis_start);

     begin
          if g_debug then
              hr_utility.set_location('pysgirar: Start of id_LE_if_latest',10);
          end if;

          open id_latest_LE ( p_person_id
                            , p_tax_unit_id
                            , p_basis_start
                            , p_basis_end);
          fetch id_latest_LE into v_assignment_id;
          --
          if id_latest_LE%found then
              close id_latest_LE;
              if g_debug then
                 hr_utility.set_location('End of id_LE_if_latest',20);
              end if;
              return v_assignment_id;
          end if;
          close id_latest_LE;
          if g_debug then
             hr_utility.set_location('End of id_LE_if_latest',20);
          end if;
          return null;

     end id_LE_if_latest;
--------------------------------------------------------------------------------
-- Simply check IF a value is numeric, bug 5435088
--------------------------------------------------------------------------------
function check_is_number (p_value in varchar2) return boolean is
  l_number_value   number;
begin
  if g_debug then
       hr_utility.set_location('pysgirar: Start of check_is_number',10);
  end if;

  if p_value is NULL then
       if g_debug then
           hr_utility.set_location('End of check_is_number',20);
       end if;

       return TRUE;
  else
    begin
      l_number_value := to_number(p_value);
    exception
      when value_error then
        if g_debug then
            hr_utility.set_location('End of check_is_number',20);
        end if;

        return FALSE;
    end;

    if g_debug then
         hr_utility.set_location('End of check_is_number',20);
    end if;

    return TRUE;
  end if;
end check_is_number;


    ---------------------------------------------------------------------------
    -- Bug 5435088 The function to check if the payer id is invalid
    ---------------------------------------------------------------------------
    function check_payer_id (p_er_income_tax_number in varchar2,
                     p_er_payer_id     in varchar2) return char is

      l_return        varchar2(1);
      l_payer_id      varchar2(20);
      l_payer_id_type varchar2(1);
      l_year          number;
    begin

      if g_debug then
          hr_utility.set_location('pysgirar: Start of check_payer_id',10);
      end if;

      l_payer_id      := p_er_income_tax_number;
      l_payer_id_type := p_er_payer_id;

      l_return := 'Z';

      if l_payer_id_type = 'U' then /* 7415444 */
        if length(l_payer_id) = 10 then
          if (substr(l_payer_id, 1, 1) = 'S' or
                substr(l_payer_id, 1, 1) = 'T') then
             if check_is_number(substr(l_payer_id, 2, 2)) and
                 not check_is_number(substr(l_payer_id, 4, 2)) and
                  check_is_number(substr(l_payer_id, 6,4)) and
                   not check_is_number(substr(l_payer_id,10,1)) then
               null;
             else
               l_return := 'U';
             end if;
          else
            l_return := 'U';
          end if;
        else
          l_return := 'U';
        end if;
      elsif l_payer_id_type = '7' then
        if length(l_payer_id) = 9 and
               check_is_number(substr(l_payer_id,1,8)) and
              not check_is_number(substr(l_payer_id,9,1)) then
          null;
        else
          l_return := '7';
        end if;
      elsif l_payer_id_type = '8' then
        if length(l_payer_id) = 10 then
            l_year := to_number(substr(l_payer_id, 1, 4));
            if ((l_year >= 1900 and l_year < 4712) and
                 check_is_number(substr(l_payer_id, 5, 5)) and
                not check_is_number(substr(l_payer_id, 10, 1))) or
              (substr(l_payer_id, 1, 1) = 'F' and
                 check_is_number(substr(l_payer_id, 2, 8)) and
                not check_is_number(substr(l_payer_id, 10, 1))) then
              null;
            else
              l_return := '8';
            end if;
         else
           l_return := '8';
         end if;
       elsif l_payer_id_type = 'A' then
         if length(l_payer_id) = 9 and
                substr(l_payer_id,1,1) = 'A' and
                check_is_number(substr(l_payer_id, 2, 7)) and
               not check_is_number(substr(l_payer_id, 9, 1)) then
           null;
         else
           l_return := 'A';
         end if;
       elsif l_payer_id_type = 'I' then
         if length(l_payer_id) = 10 and
                 substr(l_payer_id, 1, 1) = '4' and
                 check_is_number(substr(l_payer_id, 2,8)) and
                not check_is_number(substr(l_payer_id, 10, 1)) then
           null;
         else
           l_return := 'I';
         end if;
       elsif l_payer_id_type = 'C' then
         if length(l_payer_id) = 12 and
                  check_is_number(substr(l_payer_id, 1, 11)) and
                 not check_is_number(substr(l_payer_id, 12,1)) then
           null;
         else
           l_return := 'C';
         end if;
       elsif l_payer_id_type = 'M' then
         if length(l_payer_id) = 8 and
               substr(l_payer_id, 1,4) = 'MCST' and
              check_is_number(substr(l_payer_id, 5,4)) then
           null;
         else
           l_return := 'M';
         end if;
       elsif l_payer_id_type = 'G' then
         if length(l_payer_id) = 10 and
               substr(l_payer_id, 1, 1) = 'M' and
              check_is_number(substr(l_payer_id, 2,9)) then
           null;
         else
           l_return := 'G';
         end if;
       end if;

       if g_debug then
           hr_utility.set_location('pysgirar: End of check_payer_id',20);
       end if;

       return l_return;
   end check_payer_id;

    ---------------------------------------------------------------------------
    -- Bug 5435088 The function to check if the payee id is invalid
    ---------------------------------------------------------------------------
    function check_payee_id (p_ee_income_tax_number in varchar2,
                     p_payee_id_type     in varchar2) return char is

      l_return        varchar2(1);
      l_payee_id      varchar2(20);
      l_payee_id_type varchar2(1);
      l_year          number;
    begin

       if g_debug then
           hr_utility.set_location('pysgirar: Start of check_payee_id',10);
       end if;

      l_payee_id      := p_ee_income_tax_number;
      l_payee_id_type := p_payee_id_type;

      l_return := 'Z';

      if l_payee_id_type = '3' then
        if length(l_payee_id) = 8 and
            check_is_number(substr(l_payee_id, 1, 7)) and
               not check_is_number(substr(l_payee_id, 8, 1)) then
           null;
        else
           l_return := '3';
        end if;
      elsif l_payee_id_type = '5' then
        if length(l_payee_id) = 7 or
             length(l_payee_id) = 8 or
               (length(l_payee_id) = 12 and
                  check_is_number(l_payee_id)) then
           null;
        else
           l_return := '5';
        end if;
      elsif l_payee_id_type = '4' then
        if length(l_payee_id) = 10 and
            check_is_number(substr(l_payee_id, 1, 1)) and
                 substr(l_payee_id, 2, 1) = ' ' and
               check_is_number(substr(l_payee_id, 3, 7)) and
                 not check_is_number(substr(l_payee_id, 10, 1)) then
           null;
        else
           l_return := '4';
        end if;
      end if;

      if g_debug then
          hr_utility.set_location('pysgirar: End of check_payee_id',20);
      end if;

      return l_return;
   end check_payee_id;


    ---------------------------------------------------------------------------
    -- Bug 5435088 - The function to get country code
    ---------------------------------------------------------------------------
    function get_country_code (p_country in varchar2) return varchar2
     is

    l_country_code varchar2(3);

    cursor country_code
           ( c_country     per_addresses.country%type)
        is
          select  meaning
          from    hr_lookups
          where   lookup_type = 'SG_COUNTRY_CODE'
          and     lookup_code = c_country;

    begin

    if g_debug then
      hr_utility.set_location('Start of get_country_code',10);
    end if;

    if p_country = 'ID' then
      l_country_code := '303';
    elsif p_country = 'MY' then
      l_country_code := '304';
    elsif p_country = 'PH' then
      l_country_code := '305';
    elsif p_country = 'TH' then
      l_country_code := '306';
    elsif p_country = 'JP' then
      l_country_code := '331';
    elsif p_country = 'TW' then
      l_country_code := '334';
    elsif p_country = 'CN' then
      l_country_code := '336';
    elsif p_country = 'GB' then
      l_country_code := '110';
    elsif p_country = 'US' then
      l_country_code := '503';
    elsif p_country = 'AU' then
      l_country_code := '701';
    elsif p_country = 'NZ' then
      l_country_code := '705';
    else
      open country_code(p_country);
      fetch country_code into l_country_code;
      if not country_code%found then
        l_country_code := '999';
      end if;
      close country_code;
    end if;

    if g_debug then
      hr_utility.set_location('End of get_country_code',20);
    end if;

    return l_country_code;

end get_country_code;

begin
   g_debug   := hr_utility.debug_enabled;
   g_org_run := 'N';
   g_org_a8a_run := 'N';
   g_iras_method := 'O';
   g_a8b_moa_348 := 0;
   g_name_of_bank := NULL; /* Bug 7663830 */
end pay_sg_iras_archive;

/
