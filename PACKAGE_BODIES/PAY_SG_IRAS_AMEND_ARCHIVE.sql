--------------------------------------------------------
--  DDL for Package Body PAY_SG_IRAS_AMEND_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SG_IRAS_AMEND_ARCHIVE" as
/* $Header: pysgiraa.pkb 120.0.12010000.4 2009/12/09 02:14:45 jalin noship $ */
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
     l_counter             number;
     g_a8b_moa_348             number;
     g_amend_ir8s_m_flag     varchar2(1);
     g_amend_a8a_flag        varchar2(1);
     g_amend_a8b_flag        varchar2(1);
     g_amend_ir8a_flag       varchar2(1);
     g_amend_ir8s_flag       varchar2(1);
     g_amend_ir8s_c_flag     varchar2(1);

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
              hr_utility.set_location('pysgiraa: Start of range_code',1);
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
              hr_utility.set_location('pysgiraa: End of range_code',2);
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
         v_person_id        per_all_people_f.person_id%type;
         v_assignment_set_id hr_assignment_sets.assignment_set_id%type;
         --
         cursor  get_params(c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type) is
         select  pay_core_utils.get_parameter('SETUP_ACTION_ID',legislative_parameters)
                ,pay_core_utils.get_parameter('PERSON_ID',legislative_parameters)
                ,pay_core_utils.get_parameter('ASSIGNMENT_SET_ID',legislative_parameters)
         from    pay_payroll_actions
         where   payroll_action_id = c_payroll_Action_id;
         --
         cursor  next_action_id is
         select  pay_assignment_actions_s.nextval
         from    dual;
         --
         cursor  process_assignments
             (c_setup_action_id   in pay_payroll_actions.payroll_action_id%type,
              c_person_id         in per_all_people_f.person_id%type,
              c_assignment_set_id in hr_assignment_sets.assignment_set_id%type) is
         select  distinct pai.assignment_id
         from    pay_action_information pai
         where   pai.action_context_id           = c_setup_action_id
         and     pai.action_context_type         = 'AAP'
         and     pai.action_information_category = 'SG_IRAS_AMEND_SETUP'
         and    decode(c_assignment_set_id,null,'Y',
                decode(hr_assignment_set.ASSIGNMENT_IN_SET(c_assignment_set_id,pai.assignment_id),'Y','Y','N')) = 'Y'
         and     action_information2 between p_start_person_id and p_end_person_id
         and     action_information2 = nvl(c_person_id,action_information2)
	 and exists (SELECT 1
                 FROM hr_organization_information
                 WHERE org_information_context = 'SG_IRAS_DETAILS'
                 AND organization_id  = g_legal_entity_id
                 AND org_information1 = g_basis_year);

	  cursor csr_archive_action_id(p_assignment_id NUMBER)
              is
          select paa.assignment_action_id -- ALL PREV ORIGINAL AND  AMENDMENT ARCHIVES SUBMITTED B4
	    from pay_payroll_actions ppa,
                 pay_assignment_actions paa
           where ppa.payroll_action_id in (
                           SELECT org_information2
                           FROM hr_organization_information
                           WHERE org_information_context = 'SG_IRAS_DETAILS'
                           AND organization_id  = g_legal_entity_id
                           AND org_information1 = g_basis_year)
           and ppa.payroll_action_id = paa.payroll_action_id
           and paa.assignment_id = p_assignment_id;

         cursor csr_report_action_id(p_archive_action_id NUMBER) is
          select intl.locking_action_id report_action_id
            from pay_action_interlocks intl
            where intl.locked_action_id = p_archive_action_id
              and    exists
                        ( select null
                                 from   per_assignments_f  paf,
                                        pay_assignment_actions mcl,
				        pay_payroll_actions mpl
				where  paf.assignment_id      = mcl.assignment_id
				  and    mpl.payroll_action_id  = mcl.payroll_action_id
                  and    mcl.assignment_Action_id = intl.locking_action_id
				  and    mpl.effective_date     between g_basis_start and g_basis_end
				  and    pay_core_utils.get_parameter('LEGAL_ENTITY_ID',mpl.legislative_parameters) = g_legal_entity_id
				  and    mpl.report_type        in ( 'SG_A8B','SG_IR8A','SG_IR8S','SG_A8A','SG_A_A8A' )
				  and    mpl.action_type        = 'X'
				  and    mcl.action_status      = 'C'
			      group by paf.assignment_id
	     ) ;

     begin
         if g_debug then
              hr_utility.set_location('pysgiraa: Start of assignment_action_code',3);
         end if;
         --
	 initialization_code(p_payroll_action_id);

         open   get_params( p_payroll_action_id );
         fetch  get_params into v_setup_action_id,
                                v_person_id,
                                v_assignment_set_id;
         close  get_params;
         --
         open process_assignments( v_setup_action_id,
                                   v_person_id,
                                   v_assignment_set_id) ;
         loop
              fetch process_assignments into v_assignment_id;
              exit when process_assignments%notfound;
              --
              if g_debug then
                   hr_utility.set_location('pysgiraa: Before calling hr_nonrun_asact.insact',4);
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


	      for arch_rec in csr_archive_action_id(v_assignment_id) loop

	   	      hr_nonrun_asact.insint(lockingactid => v_next_action_id
                                ,lockedactid  => arch_rec.assignment_action_id
                                             );
                   for rep_rec in csr_report_action_id(arch_rec.assignment_action_id) loop

	   	           hr_nonrun_asact.insint(lockingactid => v_next_action_id
                                   ,lockedactid  => rep_rec.report_action_id
                                             );

	               end loop;


	      end loop;
              --
              if g_debug then
                   hr_utility.set_location('pysgiraa: After calling hr_nonrun_asact.insact',4);
              end if;
         end loop;
         --
         close process_assignments;
         --
         if g_debug then
              hr_utility.set_location('pysgiraa: End of assignment_action_code',5);
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
               hr_utility.set_location('pysgiraa: Start of initialization_code',6);
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
               hr_utility.set_location('pysgiraa: End of initialization_code',8);
         end if;
     end initialization_code;
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
              hr_utility.set_location('pysgiraa: Start of archive_code',10);
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
                   hr_utility.set_location('pysgiraa: Person Id: ' || to_char(v_person_id) ,100);
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


                           archive_ir8s_c_details ( p_assignment_action_id,
                                                     v_person_id,
                                                     g_legal_entity_id,
                                                     g_business_group_id,
                                                     g_basis_start,
                                                     g_basis_end );

                           archive_balances ( p_assignment_action_id,
                                              v_person_id,
                                              g_business_group_id,
                                              g_legal_entity_id,
                                              g_basis_year );

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
               hr_utility.set_location('pysgiraa: End of archive_code',20);
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
                l_detailed_bal_out_tab(63).balance_value > 0 then /*Bug7415444*/
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
              hr_utility.set_location('pysgiraa: Error in a8a_balances_value',10);
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
         t_archive_items_orig          t_archive_items_tab;
         t_archive_items_a8a           t_archive_items_tab;
         t_archive_items_ir8a          t_archive_items_tab;
         t_archive_items_ir8s          t_archive_items_tab;
	     t_old_value t_archive_items_tab;
         --
         type t_archive_value_tab is table of ff_archive_items.value%TYPE index by binary_integer;
         t_archive_value               t_archive_value_tab;
	     t_orig_value                  t_archive_value_tab;
	     t_flag                        t_archive_value_tab;
         t_archive_value_a8a           t_archive_value_tab;
	     t_archive_value_ir8a          t_archive_value_tab;
		 t_archive_value_ir8s          t_archive_value_tab;

         type t_amend_value_tab is table of ff_archive_items.value%TYPE index by binary_integer;
         t_amend_value                t_amend_value_tab;
         t_amend_value_a8a            t_amend_value_tab;
         t_amend_value_ir8a           t_amend_value_tab;
         t_amend_value_ir8s           t_amend_value_tab;
         --
         type t_date_earned_tab  is table of varchar2(30) index by binary_integer;
         t_date_earned                 t_date_earned_tab;
         --
         type t_user_entity_tab is table of ff_user_entities.user_entity_id%TYPE index by binary_integer;
         t_user_entity_id              t_user_entity_tab;
	     t_amend_ue_id                 t_user_entity_tab;
         t_orig_user_entity_id         t_user_entity_tab;
         t_user_entity_id_ir8a         t_user_entity_tab;
         t_user_entity_id_ir8s         t_user_entity_tab;
         t_user_entity_id_a8a          t_user_entity_tab;
	 l_orig_assact_id              number;

         --
         ---------------------------------------------------------------------------------------------------
         -- This ytd_balances cursor only gets the defined_balance_id and user_entity_id
         -- Bug 6349937, do not include Obsoleted balances
         ---------------------------------------------------------------------------------------------------
         cursor  ytd_balances_ir8s is
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
                 ( pbt.balance_name like 'IR8S%' ) )
         and     upper(pbt.reporting_name) not like '%OBSOLETE%'
         and     pbt.balance_type_id = pdb.balance_type_id
         and     pbd.balance_dimension_id = pdb.balance_dimension_id
         and     pbd.dimension_name = '_PER_LE_YTD';

	 cursor  ytd_balances_ir8a is
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
         and      pbt.balance_name  like 'IR8A%'
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
         ytd_balance_rec_ir8a ytd_balance_tab;
         ytd_balance_rec_ir8s ytd_balance_tab;
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
         l_ytd_counter_ir8a                   number;
         l_ytd_counter_ir8s                   number;
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
	 l_temp_value                    VARCHAR2(2000);
     l_name_ue                       VARCHAR2(2000);
	 l_assignment_id                 number;
	 a8a_counter                     number;

         ---------------------------------------------------------------------------------------------------
     begin
         l_payroll_mon_counter      := 1;
         l_pmon_counter             := false;
         l_ytd_counter_ir8a         := 1;
         l_ytd_counter_ir8s         := 1;
         l_mon_counter              := 1;
         l_counter                  := 1;
         duplicate_exists           := 'N';
         l_arch_counter             := 1;
         --
         if g_debug then
              hr_utility.set_location('pysgiraa: Start of archive_balances',10);
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
	 	 hr_utility.set_location('pysgiraa: archive_balances ',1110);
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
	 	 	     hr_utility.set_location('pysgiraa: archive_balances ',1120);
         ------------------------------------------------------------------------------------------------
         -- 2556026 Used pl/sql table to store the ytd_balances values.
         -- Now ytd_balances will get executed only once
         ------------------------------------------------------------------------------------------------
         if t_ytd_balanceid_store_ir8a.count = 0 then
              open ytd_balances_ir8a;
              loop
                  fetch ytd_balances_ir8a into t_ytd_balanceid_store_ir8a(l_ytd_counter_ir8a).user_entity_id,
                                  t_ytd_balanceid_store_ir8a(l_ytd_counter_ir8a).defined_balance_id;
                  l_ytd_counter_ir8a :=  l_ytd_counter_ir8a + 1;
                  exit when ytd_balances_ir8a%NOTFOUND;
              end loop;
              close ytd_balances_ir8a;
         end if;
	 	 hr_utility.set_location('pysgiraa: archive_balances ',1130);
	     if t_ytd_balanceid_store_ir8s.count = 0 then
              open ytd_balances_ir8s;
              loop
                  fetch ytd_balances_ir8s into t_ytd_balanceid_store_ir8s(l_ytd_counter_ir8s).user_entity_id,
                                  t_ytd_balanceid_store_ir8s(l_ytd_counter_ir8s).defined_balance_id;
                  l_ytd_counter_ir8s :=  l_ytd_counter_ir8s + 1;
                  exit when ytd_balances_ir8s%NOTFOUND;
              end loop;
              close ytd_balances_ir8s;
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
	      	 	 	     hr_utility.set_location('pysgiraa: archive_balances ',1140);
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
				     	 	 	     hr_utility.set_location('pysgiraa: archive_balances ',1150);
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
	 	 	     hr_utility.set_location('pysgiraa: archive_balances ',1160);
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
				 	 	     hr_utility.set_location('pysgiraa: archive_balances ',1170);
                        --
                        close month_year_action_sequence;
                        ----------------------------------------------------------------------------------
                        -- Bulk Balance Fetch for Bug 3064282
                        ----------------------------------------------------------------------------------
                        g_balance_value_tab.delete;
                        g_context_tab.delete;
                        g_detailed_bal_out_tab.delete;
	 	       	     hr_utility.set_location('pysgiraa: archive_balances ',1180);
                        --
                        for counter in 1..t_ytd_balanceid_store_ir8a.count
    	                loop
 	                      g_balance_value_tab(counter).defined_balance_id := t_ytd_balanceid_store_ir8a(counter).defined_balance_id;
                          g_context_tab(counter).tax_unit_id := month_year_action_rec.tax_uid;
                        end loop;
	 	 	     hr_utility.set_location('pysgiraa: archive_balances ',1190);
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
				 	 	     hr_utility.set_location('pysgiraa: archive_balances ',1200);
                        for counter in 1..t_ytd_balanceid_store_ir8a.count
                        loop
                              if l_person_counter = 1 then
                                   if g_detailed_bal_out_tab.exists(counter) then
                                          ytd_balance_rec_ir8a(counter).balance_id    := t_ytd_balanceid_store_ir8a(counter).user_entity_id;
                                          ytd_balance_rec_ir8a(counter).balance_value := nvl(g_detailed_bal_out_tab(counter).balance_value,0) ;
                                          v_run_ass_action_id                    := month_year_action_rec.assact_id;
                                   end if;
                              else
                                   if g_detailed_bal_out_tab.exists(counter) then
                                          if ytd_balance_rec_ir8a.exists(counter) then
                                                 ytd_balance_rec_ir8a(counter).balance_value := nvl(g_detailed_bal_out_tab(counter).balance_value,0)
                                                                                     + ytd_balance_rec_ir8a(counter).balance_value;
                                          end if;
                                   end if;
                              end if;
                        end loop;
				 	 	     hr_utility.set_location('pysgiraa: archive_balances ',1210);
                        g_balance_value_tab.delete;
                        g_context_tab.delete;
                        g_detailed_bal_out_tab.delete;

			for counter in 1..t_ytd_balanceid_store_ir8s.count
    	                loop
 	                      g_balance_value_tab(counter).defined_balance_id := t_ytd_balanceid_store_ir8s(counter).defined_balance_id;
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
							 	 	     hr_utility.set_location('pysgiraa: archive_balances ',1220);
                        for counter in 1..t_ytd_balanceid_store_ir8s.count
                        loop
                              if l_person_counter = 1 then
                                   if g_detailed_bal_out_tab.exists(counter) then
                                          ytd_balance_rec_ir8s(counter).balance_id    := t_ytd_balanceid_store_ir8s(counter).user_entity_id;
                                          ytd_balance_rec_ir8s(counter).balance_value := nvl(g_detailed_bal_out_tab(counter).balance_value,0) ;
                                          v_run_ass_action_id                    := month_year_action_rec.assact_id;
                                   end if;
                              else
                                   if g_detailed_bal_out_tab.exists(counter) then
                                          if ytd_balance_rec_ir8s.exists(counter) then
                                                 ytd_balance_rec_ir8s(counter).balance_value := nvl(g_detailed_bal_out_tab(counter).balance_value,0)
                                                                                     + ytd_balance_rec_ir8s(counter).balance_value;
                                          end if;
                                   end if;
                              end if;
                        end loop;
				 	 	     hr_utility.set_location('pysgiraa: archive_balances ',1230);
                        --
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
				 	 	     hr_utility.set_location('pysgiraa: archive_balances ',1240);
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

		 hr_utility.set_location('pysgiraa:archive_balances ',1250);
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

	 	 hr_utility.set_location('pysgiraa: archive_balances ',15);
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

         -- t_user_entity_id Loop start
	 FOR i IN 1..t_user_entity_id.count LOOP

	   select user_entity_name
	     into l_name_ue
	     from ff_user_entities where user_entity_id = t_user_entity_id(i);

           SELECT assignment_id
	     INTO l_assignment_id
	     FROM pay_assignment_Actions paa
	    WHERE paa.assignment_action_id = p_assignment_action_id;

/*            past original and amendment */



	   BEGIN

	 	 l_temp_value :='';
	 	 SELECT  nvl(sum(value),0)
	 	   INTO l_temp_value
	 	   FROM ff_archive_items arch
	 	   WHERE arch.user_entity_id = t_user_entity_id(i)
	 	     AND arch.context1 IN(  select paa.assignment_action_id -- ALL PREV ORIGINAL AND  AMENDMENT ARCHIVES SUBMITTED B4
	    from pay_payroll_actions ppa,
                 pay_assignment_actions paa
           where ppa.payroll_action_id in (SELECT org_information2
                                             FROM hr_organization_information
                                             WHERE org_information_context = 'SG_IRAS_DETAILS'
                                               AND organization_id  = g_legal_entity_id
                                               AND org_information1 = g_basis_year)
                                               and ppa.payroll_action_id = paa.payroll_action_id
                                               and paa.assignment_id = l_assignment_id)--ORGLEVELPREVSUMITTEDvalues
	 	     AND EXISTS (SELECT 1
		                   FROM ff_archive_item_contexts con1
	 	                  WHERE con1.archive_item_id = arch.archive_item_id
	 	                    AND con1.context = p_tax_unit_id
	 	                    AND con1.sequence_no =2)
	 	    AND EXISTS (SELECT 1
		                  FROM ff_archive_item_contexts con2
	 	                 WHERE con2.archive_item_id = arch.archive_item_id
	 	                   AND fnd_date.canonical_to_date(con2.context) = fnd_date.canonical_to_date(t_date_earned(i))
	 	                   AND con2.sequence_no =3);
	   EXCEPTION
	     WHEN NO_DATA_FOUND
	     THEN  NULL;
	   END;

	   t_amend_value(i) := l_temp_value;
         END LOOP;
	 	     hr_utility.set_location('pysgiraa: archive_balances ',20);
            g_amend_ir8s_m_flag :='N';


FOR I IN 1..t_user_entity_id.count LOOP
  if (t_archive_value.exists(i) and t_amend_value.exists(i)) then
           if (t_archive_value(i) <> t_amend_value(i)) THEN
	     g_amend_ir8s_m_flag :='Y';
	     exit;
           end if;
   else
    g_amend_ir8s_m_flag :='Y';
	     exit;
   end if;
end loop;

/* need to archive  t_amend_value(i) - t_archive_value(i)  .
handle when no data exists, ensure only numbers.
Special handling for fields that dont allow negative*/

	 	 hr_utility.set_location('pysgiraa: archive_balances ',30);

         l_arch_counter := 1;
         --

         for counter  in 1..ytd_balance_rec_ir8s.count
         loop
              if ytd_balance_rec_ir8s.exists(counter) then
                   t_user_entity_id_ir8s(l_arch_counter) := ytd_balance_rec_ir8s(counter).balance_id;
                   t_archive_value_ir8s(l_arch_counter)  := ytd_balance_rec_ir8s(counter).balance_value;
                   l_arch_counter := l_arch_counter + 1;
              end if;
         end loop;

         l_arch_counter := 1;
         for counter  in 1..ytd_balance_rec_ir8a.count
         loop
              if ytd_balance_rec_ir8a.exists(counter) then
                   t_user_entity_id_ir8a(l_arch_counter) := ytd_balance_rec_ir8a(counter).balance_id;
                   t_archive_value_ir8a(l_arch_counter)  := ytd_balance_rec_ir8a(counter).balance_value;
                   l_arch_counter := l_arch_counter + 1;
              end if;
         end loop;
	 	     hr_utility.set_location('pysgiraa: archive_balances ',40);
         ---------------------------------------------------------------------------------------------------
         -- Bug# 3501927  A8A_USABLITY
         ---------------------------------------------------------------------------------------------------
         --Bug#3933332
         l_arch_counter :=1;

         if  g_org_a8a_flag ='Y' then-- AND A8A ARCHIVE_ITEMS ARE PRESENT ARE IN ORIGINAL ARCHIVE RUN
         --
           for counter  in 1..ytd_a8a_balance_rec.count
           loop
              if ytd_a8a_balance_rec.exists(counter) then
                   t_user_entity_id_a8a(l_arch_counter) := ytd_a8a_balance_rec(counter).balance_id;
                   t_archive_value_a8a(l_arch_counter)  := ytd_a8a_balance_rec(counter).balance_value;
                   l_arch_counter                   := l_arch_counter + 1;
              end if;
           end loop;
         --
         end if;
	 	     hr_utility.set_location('pysgiraa: archive_balances ',50);

	  FOR counter IN 1..t_user_entity_id_ir8a.COUNT LOOP

	   select user_entity_name
	      into l_name_ue
	      from ff_user_entities
	     where user_entity_id = t_user_entity_id_ir8a(counter);

         begin
	         l_temp_value :='';
		 select sum(value)
		   into l_temp_value
		   from ff_archive_items arch
		  where arch.user_entity_id = t_user_entity_id_ir8a(counter)
		    and arch.context1 IN( select paa.assignment_action_id -- ALL PREV ORIGINAL AND  AMENDMENT ARCHIVES SUBMITTED B4
	    from pay_payroll_actions ppa,
                 pay_assignment_actions paa
           where ppa.payroll_action_id in (SELECT org_information2
                                             FROM hr_organization_information
                                             WHERE org_information_context = 'SG_IRAS_DETAILS'
                                               AND organization_id  = g_legal_entity_id
                                               AND org_information1 = g_basis_year)
                                               and ppa.payroll_action_id = paa.payroll_action_id
                                               and paa.assignment_id = l_assignment_id)
		    and exists (select 1
		                  from ff_archive_item_contexts con1
		                 where con1.archive_item_id = arch.archive_item_id
		                   and con1.context = p_tax_unit_id
	                           and con1.sequence_no =2);

	        exception
	           WHEN NO_DATA_FOUND THEN
                      NULL;
                end;

	        t_amend_value_ir8a(counter) := l_temp_value;


	  END LOOP;
	 	 hr_utility.set_location('pysgiraa: archive_balances ',60);
         g_amend_ir8a_flag := 'N';

	   for counter  in 1..t_user_entity_id_ir8a.count
           loop
	   if(t_archive_value_ir8a.exists(counter) and t_amend_value_ir8a.exists(counter)) then
  	       if (t_archive_value_ir8a(counter) <> t_amend_value_ir8a(counter)) THEN
	          g_amend_ir8a_flag :='Y';
	           exit;
	       end if;
           else
               g_amend_ir8a_flag :='Y';
	       exit;
	   end if;

	   end loop;

	   hr_utility.set_location('pysgiraa: archive_balances ',70);

	   FOR counter IN 1..t_user_entity_id_ir8s.COUNT LOOP

	   select user_entity_name
	      into l_name_ue
	      from ff_user_entities
	     where user_entity_id = t_user_entity_id_ir8s(counter);

          begin
	         l_temp_value :='';
		  select  sum(value)
		   into l_temp_value
		   from ff_archive_items arch
		  where arch.user_entity_id = t_user_entity_id_ir8s(counter)
		    and arch.context1 IN( select paa.assignment_action_id -- ALL PREV ORIGINAL AND  AMENDMENT ARCHIVES SUBMITTED B4
	         from pay_payroll_actions ppa,
                  pay_assignment_actions paa
            where ppa.payroll_action_id in (SELECT org_information2
                                             FROM hr_organization_information
                                             WHERE org_information_context = 'SG_IRAS_DETAILS'
                                               AND organization_id  = g_legal_entity_id
                                               AND org_information1 = g_basis_year)
                                               and ppa.payroll_action_id = paa.payroll_action_id
                                               and paa.assignment_id = l_assignment_id)
		    and exists (select 1
		                  from ff_archive_item_contexts con1
		                 where con1.archive_item_id = arch.archive_item_id
		                   and con1.context = p_tax_unit_id
	                           and con1.sequence_no =2);

	        exception
	           WHEN NO_DATA_FOUND THEN
                      NULL;
                end;

	        t_amend_value_ir8s(counter) := l_temp_value;

	  END LOOP;
	 	 hr_utility.set_location('pysgiraa: archive_balances ',80);
         g_amend_ir8a_flag := 'N';

	   for counter  in 1..t_user_entity_id_ir8a.count
           loop
	   if(t_archive_value_ir8a.exists(counter) and t_amend_value_ir8a.exists(counter)) then
  	       if (t_archive_value_ir8a(counter) <> t_amend_value_ir8a(counter)) THEN
	          g_amend_ir8a_flag :='Y';
	           exit;
	       end if;
           else
               g_amend_ir8a_flag :='Y';
	       exit;
	   end if;

	   end loop;

	 	     hr_utility.set_location('pysgiraa: archive_balances ',90);
	   g_amend_ir8s_flag := 'N';

	   for counter  in 1..t_user_entity_id_ir8s.count
           loop
	   if(t_archive_value_ir8s.exists(counter) and t_amend_value_ir8s.exists(counter)) then
  	       if (t_archive_value_ir8s(counter) <> t_amend_value_ir8s(counter)) THEN
	          g_amend_ir8s_flag :='Y';
	           exit;
	       end if;
           else
               g_amend_ir8s_flag :='Y';
	       exit;
	   end if;

	   end loop;

	   hr_utility.set_location('pysgiraa: archive_balances ',100);
	   FOR i in 1..t_user_entity_id_a8a.count LOOP

	     select user_entity_name
	      into l_name_ue
	      from ff_user_entities
	      where user_entity_id = t_user_entity_id_a8a(i);

                begin
	         l_temp_value :='';
		 select  sum(value)
		   into l_temp_value
		   from ff_archive_items arch
		  where arch.user_entity_id = t_user_entity_id_a8a(i)
		    and arch.context1 IN( select paa.assignment_action_id
		    -- ALL PREV ORIGINAL AND  AMENDMENT ARCHIVES SUBMITTED B4
	    from pay_payroll_actions ppa,
                 pay_assignment_actions paa
           where ppa.payroll_action_id in (SELECT org_information2
                                             FROM hr_organization_information
                                             WHERE org_information_context = 'SG_IRAS_DETAILS'
                                               AND organization_id  = g_legal_entity_id
                                               AND org_information1 = g_basis_year)
                                               and ppa.payroll_action_id = paa.payroll_action_id
                                               and paa.assignment_id = l_assignment_id)
		    and exists (select 1
		                  from ff_archive_item_contexts con1
		                 where con1.archive_item_id = arch.archive_item_id
		                   and con1.context = p_tax_unit_id
	                           and con1.sequence_no =2);

	        exception
	           WHEN NO_DATA_FOUND THEN
                      NULL;
                end;

	        t_amend_value_a8a(i) := l_temp_value;

           END LOOP;
	 	     hr_utility.set_location('pysgiraa: archive_balances ',110);

	   g_amend_a8a_flag := 'N';
	   -- ARCHIVE ITEMS

	   for counter  in 1..t_user_entity_id_a8a.COUNT
           loop
	     if (t_archive_value_A8A.exists(counter) and t_amend_value_A8A.exists(counter)) then
	       if (t_archive_value_A8A(counter) <> t_amend_value_A8A(counter)) THEN
	          g_amend_a8a_flag :='Y';
	          exit;
	       end if;

	     else
	      g_amend_a8a_flag :='Y';
	          exit;
	     end if;
	   end loop;

	 	     hr_utility.set_location('pysgiraa: archive_balances ',120);

if g_amend_ir8s_c_flag = 'Y' or g_amend_ir8s_m_flag = 'Y' then
  g_amend_ir8s_flag := 'Y';
end if;

if(g_amend_ir8a_flag='Y' or g_amend_a8a_flag='Y' or g_amend_ir8s_flag='Y' or g_amend_a8b_flag = 'Y') then

archive_item ('X_IRAS_METHOD', p_assignment_action_id, 'A');

  select ue.user_entity_id
  bulk collect into t_amend_ue_id
  from ff_user_entities ue
  where ue.user_entity_name in  ('X_IR8A_AMEND_INDICATOR',
                                   'X_A8B_AMEND_INDICATOR',
                                   'X_IR8S_AMEND_INDICATOR',
                                  'X_A8A_AMEND_INDICATOR')
  order by ue.user_entity_name;

  t_flag(1) := g_amend_a8a_flag;
  t_flag(2) := g_amend_a8b_flag;
  t_flag(3) := g_amend_ir8a_flag;
  t_flag(4) := g_amend_ir8s_flag;

  forall counter in 1..t_amend_ue_id.count
  insert into ff_archive_items
                 ( archive_item_id,
                   user_entity_id,
                   context1,
                   value,
                   archive_type )
               values
                 ( ff_archive_items_s.nextval,
                   t_amend_ue_id(counter),
                   p_assignment_action_id,
                   t_flag(counter),
                   'AAP' )
         returning archive_item_id bulk collect into t_archive_items ;

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


 t_archive_items.delete;
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
                   t_archive_value(counter) - t_amend_value(counter) ,-- T_AMEND-VALUE,
                   'AAP' )
         returning archive_item_id bulk collect into t_archive_items ;


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

	 	     hr_utility.set_location('pysgiraa: archive_balances ',130);

         forall counter in 1..t_user_entity_id_ir8a.count
               insert into ff_archive_items
                 ( archive_item_id,
                   user_entity_id,
                   context1,
                   value,
                   archive_type )
               values
                 ( ff_archive_items_s.nextval,
                   t_user_entity_id_ir8a(counter),
                   p_assignment_action_id,
                   t_archive_value_ir8a(counter) - t_amend_value_ir8a(counter),
                   'AAP' )
         returning archive_item_id bulk collect into t_archive_items_ir8a ;
         --



         forall counter in t_archive_items_ir8a.first..t_archive_items_ir8a.last
               insert into ff_archive_item_contexts
                 ( archive_item_id,
                   sequence_no,
                   context,
                   context_id )
               values
                 ( t_archive_items_ir8a(counter),
                   1,
                   p_assignment_action_id,
                   l_asac_cont_id );
         --
         forall counter in t_archive_items_ir8a.first..t_archive_items_ir8a.last
               insert into ff_archive_item_contexts
                 ( archive_item_id,
                   sequence_no,
                   context,
                   context_id )
               values
                 ( t_archive_items_ir8a(counter) ,
                   2,
                   p_tax_unit_id,
                   l_tax_cont_id );
t_archive_items_ir8a.delete;

	 	     hr_utility.set_location('pysgiraa: archive_balances ',140);
forall counter in 1..t_user_entity_id_ir8s.count
               insert into ff_archive_items
                 ( archive_item_id,
                   user_entity_id,
                   context1,
                   value,
                   archive_type )
               values
                 ( ff_archive_items_s.nextval,
                   t_user_entity_id_ir8s(counter),
                   p_assignment_action_id,
                    t_archive_value_ir8s(counter) - t_amend_value_ir8s(counter) ,
                   'AAP' )
         returning archive_item_id bulk collect into t_archive_items_ir8s ;
         --



         forall counter in t_archive_items_ir8s.first..t_archive_items_ir8s.last
               insert into ff_archive_item_contexts
                 ( archive_item_id,
                   sequence_no,
                   context,
                   context_id )
               values
                 ( t_archive_items_ir8s(counter),
                   1,
                   p_assignment_action_id,
                   l_asac_cont_id );
         --
         forall counter in t_archive_items_ir8s.first..t_archive_items_ir8s.last
               insert into ff_archive_item_contexts
                 ( archive_item_id,
                   sequence_no,
                   context,
                   context_id )
               values
                 ( t_archive_items_ir8s(counter),
                   2,
                   p_tax_unit_id,
                   l_tax_cont_id );
t_archive_items_ir8s.delete;

	 	     hr_utility.set_location('pysgiraa: archive_balances ',150);

      forall counter in 1..t_user_entity_id_a8a.count
               insert into ff_archive_items
                 ( archive_item_id,
                   user_entity_id,
                   context1,
                   value,
                   archive_type )
               values
                 ( ff_archive_items_s.nextval,
                   t_user_entity_id_a8a(counter),
                   p_assignment_action_id,
                   t_archive_value_a8a(counter) - t_amend_value_a8a(counter) ,
                   'AAP' )
         returning archive_item_id bulk collect into t_archive_items_a8a ;
         --



         forall counter in t_archive_items_a8a.first..t_archive_items_a8a.last
               insert into ff_archive_item_contexts
                 ( archive_item_id,
                   sequence_no,
                   context,
                   context_id )
               values
                 ( t_archive_items_a8a(counter),
                   1,
                   p_assignment_action_id,
                   l_asac_cont_id );
         --
         forall counter in t_archive_items_a8a.first..t_archive_items_a8a.last
               insert into ff_archive_item_contexts
                 ( archive_item_id,
                   sequence_no,
                   context,
                   context_id )
               values
                 ( t_archive_items_a8a(counter),
                   2,
                   p_tax_unit_id,
                   l_tax_cont_id );
t_archive_items_a8a.delete;
	 	     hr_utility.set_location('pysgiraa: archive_balances ',160);

 select arch.value,ue.user_entity_id
 bulk collect into t_orig_value,t_orig_user_entity_id
	      from ff_user_entities ue ,
	      ff_archive_items arch
	      where ue.user_entity_name in  ('X_PER_NATIONAL_IDENTIFIER',
	      'X_PER_SEX',
	      'X_PER_DATE_OF_BIRTH',
	      'X_PER_ADR_TYPE',
	      'X_PER_ADR_COUNTRY_CODE',
	      'X_PER_ADR_LINE_1',
	      'X_PER_ADR_LINE_2',
	      'X_PER_ADR_LINE_3',
	      'X_PER_ADR_POSTAL_CODE',
	      'X_PER_CQ_ADR_LINE_1',
	      'X_PER_CQ_ADR_LINE_2',
	      'X_PER_CQ_ADR_LINE_3',
	      'X_PER_CQ_DATE_FROM',
	      'X_PER_CQ_DATE_TO',
	      'X_EMP_TERM_DATE',
	      'X_EMP_HIRE_DATE',
	      'X_PEOPLE_FLEXFIELD_SG_SG_LEGAL_NAME',
	      'X_PEOPLE_FLEXFIELD_SG_SG_PP_COUNTRY',
	      'X_PEOPLE_FLEXFIELD_SG_SG_PERMIT_TYPE',
          'X_PEOPLE_FLEXFIELD_SG_SG_INCOME_TAX_NUMBER',
	      'X_PER_PERMIT_STATUS_INDICATOR'
	      ,'X_PER_EE_PAYEE_ID_CHECK',
	      'X_PEOPLE_FLEXFIELD_SG_SG_PAYEE_ID_TYPE',
	      'X_PER_NATIONALITY_CODE',
	      'X_HR_IR8A_INDICATORS_SG_PER_SECTION_45_APPLICABLE',
	      'X_HR_IR8A_INDICATORS_SG_PER_INCOME_TAX_BORNE_BY_EMPLOYER',
	      'X_HR_IR8A_INDICATORS_SG_PER_IR8S_APPLICABLE',
	      'X_HR_IR8A_INDICATORS_SG_EXEMPT'
	      ,'X_HR_IR8A_INDICATORS_SG_APPR_IRAS',
	      'X_HR_IR8A_INDICATORS_SG_DATE_OF_APPR_IRAS',
	      'X_HR_IR8A_FURTHER_DETAILS_SG_PER_RETIREMENT_FUND',
	      'X_HR_IR8A_FURTHER_DETAILS_SG_PER_DESIGNATED_PENSION',
	      'X_HR_IRAS_ADDITIONAL_INFO_SG_PER_ADDITIONAL_INFORMATION',
	      'X_HR_IR8S_INDICATORS_SG_ASG_VOLUNTARY_CPF_OBLIGATORY',
	      'X_HR_IR8S_INDICATORS_SG_ASG_APPR_CPF',
	      'X_IR8A_MOA_369_DATE',
	      'X_HR_IR8A_FURTHER_DETAILS_SG_NAME_OF_BANK',
	      'X_ASG_DESIGNATION',
	      'X_HR_IR8S_INDICATORS_SG_ASG_CPF_OVERSEAS_POST_OBLIGATORY',
	      'X_ASG_OVERSEAS_DATE_FROM',
	      'X_ASG_OVERSEAS_DATE_TO',
	      'X_PER_PAYROLL_DATE',
	      'X_SG_LEGAL_ENTITY_SG_LEGAL_ENTITY_NAME',
	      'X_SG_LEGAL_ENTITY_SG_ER_INCOME_TAX_NUMBER',
	      'X_SG_LEGAL_ENTITY_SG_ER_OHQ_STATUS',
	      'X_SG_LEGAL_ENTITY_SG_ER_IRAS_CATEGORY',
	      'X_SG_LEGAL_ENTITY_SG_ER_TELEPHONE_NUMBER',
	      'X_SG_LEGAL_ENTITY_SG_ER_PAYER_ID',
	      'X_SG_LEGAL_ENTITY_SG_ER_JOB_DES_TYPE',
	      'X_SG_LEGAL_ENTITY_SG_ER_AUTH_PERSON_EMAIL',
	      'X_SG_LEGAL_ENTITY_SG_ER_DIVISION',
	      'X_SG_LEGAL_ENTITY_SG_ER_ID_CHECK',
          'X_SG_LEGAL_ENTITY_SG_A8B_INCORP_DATE',
	      'X_IR8A_MOA_265_DATE_FROM',
	      'X_IR8A_MOA_265_DATE_TO',
	      'X_IR8A_MOA_265_INDICATOR',
	      'X_IR8A_MOA_340_DATE',
	      'X_ADDITIONAL_EARNINGS_DATE')
	      and ue.user_entity_id = arch.user_entity_id
	      AND ARCH.CONTEXT1 in ( select paa.assignment_action_id
		    -- ALL PREV ORIGINAL AND  AMENDMENT ARCHIVES SUBMITTED B4
	    from pay_payroll_actions ppa,
                 pay_assignment_actions paa
           where ppa.payroll_action_id in (SELECT org_information2
                                             FROM hr_organization_information
                                             WHERE org_information_context = 'SG_IRAS_DETAILS'
                                               AND organization_id  = g_legal_entity_id
                                               AND org_information1 = g_basis_year)
                                               and ppa.payroll_action_id = paa.payroll_action_id
					       and ppa.report_type='SG_IRAS_ARCHIVE'
                                               and paa.assignment_id = l_assignment_id)  ;


	      	 	     hr_utility.set_location('pysgiraa: archive_balances ',170);
if t_orig_user_entity_id.count >0 then

forall counter in 1..t_orig_user_entity_id.count
               insert into ff_archive_items
                 ( archive_item_id,
                   user_entity_id,
                   context1,
                   value,
                   archive_type )
               values
                 ( ff_archive_items_s.nextval,
                   t_orig_user_entity_id(counter),
                   p_assignment_action_id,
                   t_orig_value(counter),
                   'AAP' )
         returning archive_item_id bulk collect into t_archive_items_orig ;
         --

         forall counter in t_archive_items_orig.first..t_archive_items_orig.last
               insert into ff_archive_item_contexts
                 ( archive_item_id,
                   sequence_no,
                   context,
                   context_id )
               values
                 ( t_archive_items_orig(counter),
                   1,
                   p_assignment_action_id,
                   l_asac_cont_id );

end if;
end if;
	 	     hr_utility.set_location('pysgiraa: archive_balances ',180);
         t_user_entity_id.delete;
         t_archive_value.delete;
         t_date_earned.delete;


t_archive_value_ir8a.delete;
t_user_entity_id_ir8a.delete;

t_archive_value_ir8s.delete;
t_user_entity_id_ir8s.delete;

t_archive_value_a8a.delete;
t_user_entity_id_a8a.delete;

         ------------------------------------------------------------------------------------------------
         -- Bug# 2833530 - Added p_person_id as the parameter for the archive_balance_dates for the
         -- employees having terminated and rehired in the same financial year
         ------------------------------------------------------------------------------------------------

         if g_debug then
               hr_utility.set_location('pysgiraa: End of archive_balances',100);
         end if;
     end archive_balances;

  ---------------------------------------------------------------------------


  ---------------------------------------------------------------------------
  procedure archive_shares_details
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_tax_unit_id           in ff_archive_item_contexts.context%type,
       p_basis_start           in date,
       p_basis_end             in date )
  is

    type t_archive_items_tab is table of ff_archive_items.archive_item_id%TYPE index by binary_integer;
    t_archive_items_a8b   t_archive_items_tab;

    type t_archive_value_tab is table of ff_archive_items.value%TYPE index by binary_integer;
    t_archive_value_a8b      t_archive_value_tab;

    type t_amend_value_tab is table of ff_archive_items.value%TYPE index by binary_integer;
    t_amend_value_a8b        t_amend_value_tab;

    type t_user_entity_tab is table of ff_user_entities.user_entity_id%TYPE index by binary_integer;
    t_user_entity_id_a8b     t_user_entity_tab;

    type t_user_entity_name_tab is table of ff_user_entities.user_entity_name%TYPE index by binary_integer;
    t_user_entity_name_a8b      t_user_entity_name_tab;

    type t_assignment_extra_info_tab is table of per_assignment_extra_info.assignment_extra_info_id%TYPE index by binary_integer;
    t_aeid_a8b            t_assignment_extra_info_tab;

    type shares_amend_rec is record
      ( person_extra_info_id   per_people_extra_info.person_extra_info_id%type,
        stock_option           per_people_extra_info.pei_information1%type,
        exercise_price         per_people_extra_info.pei_information1%type,
        market_exercise_value  per_people_extra_info.pei_information1%type,
        exercise_date          per_people_extra_info.pei_information1%type,
        shares_acquired        per_people_extra_info.pei_information1%type,
        name_of_company        per_people_extra_info.pei_information1%type,
        rcb                    per_people_extra_info.pei_information1%type,
        company_type           per_people_extra_info.pei_information1%type,
        market_grant_value     per_people_extra_info.pei_information1%type,
        grant_type             per_people_extra_info.pei_information1%type,
        grant_date             per_people_extra_info.pei_information1%type,
        rec_type               varchar2(1));
    type shares_value_tab is table of shares_amend_rec index by binary_integer;
    t_value_shares shares_value_tab;

     l_temp_value                    VARCHAR2(2000);
     archive_value_shares_acquired   VARCHAR2(2000);
     amend_value_shares_acquired     VARCHAR2(2000);
     l_name_ue                       VARCHAR2(2000);
     l_assignment_id       per_assignments_f.assignment_id%type;

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
  amend_a8b_flag char(1);
  l_count number;
  v_er_incorp_date_1  char(10);
  v_er_incorp_date_2  char(10);
  v_er_incorp_date    hr_organization_information.org_information9%type;
  v_archive     char(1);


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

    cursor shares_removed
      (c_user_entity_id      ff_user_entities.user_entity_id%type,
       c_assignment_id       per_assignment_extra_info.assignment_id%type,
       c_person_id           per_people_f.person_id%type,
       c_tax_unit_id         ff_archive_item_contexts.context%type) is

    select distinct con2.context person_extra_info_id
    from   ff_archive_items arch,
           ff_archive_item_contexts con2
    where  arch.user_entity_id = c_user_entity_id
    and    arch.context1 IN(
                  select paa.assignment_action_id -- ALL PREV ORIGINAL AND  AMENDMENT ARCHIVES SUBMITTED B4
                  from   pay_payroll_actions ppa,
                         pay_assignment_actions paa
                  where  ppa.payroll_action_id in (
                             SELECT org_information2
                             FROM hr_organization_information
                             WHERE org_information_context = 'SG_IRAS_DETAILS'
                             AND organization_id  = g_legal_entity_id
                                        AND org_information1 = g_basis_year)
                          and ppa.payroll_action_id = paa.payroll_action_id
                          and paa.assignment_id = c_assignment_id)
             and exists (select 1
                         from ff_archive_item_contexts con1
                         where con1.archive_item_id = arch.archive_item_id
                         and con1.context = c_tax_unit_id
                         and con1.sequence_no =2)
            and arch.archive_item_id = con2.archive_item_id
            and con2.sequence_no = 3
            and not exists (select 1
                            from   per_people_extra_info pei
                            where  pei.person_id = c_person_id
                            and   pei.person_extra_info_id = con2.context);
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
     amend_a8b_flag := 'N';
     g_amend_a8b_flag := 'N';
     v_a8b_files := 'N';
     v_esop_count := 0;
     v_eesop_count := 0;
     v_nsop_count := 0;
     v_csop_count := 0;
     l_count := 0;
     v_archive := 'N';

     if g_debug then
          hr_utility.set_location('pysgiraa: Start of archive_share_details', 10);
     end if;

    SELECT assignment_id
    INTO l_assignment_id
    FROM pay_assignment_Actions paa
    WHERE paa.assignment_action_id = p_assignment_action_id;

    select arch.value
    into v_er_incorp_date
    from ff_user_entities ue ,
         ff_archive_items arch
    where ue.user_entity_name = 'X_SG_LEGAL_ENTITY_SG_A8B_INCORP_DATE'
    and   ue.user_entity_id = arch.user_entity_id
    AND ARCH.CONTEXT1 in ( select paa.assignment_action_id
            -- ALL PREV ORIGINAL AND  AMENDMENT ARCHIVES SUBMITTED B4
                 from  pay_payroll_actions ppa,
                       pay_assignment_actions paa
                 where ppa.payroll_action_id in (
                           SELECT org_information2
                           FROM   hr_organization_information
                           WHERE  org_information_context = 'SG_IRAS_DETAILS'
                           AND organization_id  = g_legal_entity_id
                           AND org_information1 = g_basis_year)
                 and ppa.payroll_action_id = paa.payroll_action_id
                 and ppa.report_type='SG_IRAS_ARCHIVE'
                 and paa.assignment_id = l_assignment_id);

    if v_er_incorp_date is not null then
         v_er_incorp_date_1 := to_char(fnd_date.canonical_to_date(v_er_incorp_date),'YYYY')||'/'||to_char(fnd_date.canonical_to_date(v_er_incorp_date),'MM')||'/'||to_char(fnd_date.canonical_to_date(v_er_incorp_date),'DD');
         v_er_incorp_date_2 := to_char(to_number(to_char(fnd_date.canonical_to_date(v_er_incorp_date),'YYYY'))+3)||'/'||to_char(fnd_date.canonical_to_date(v_er_incorp_date),'MM')||'/'||to_char(fnd_date.canonical_to_date(v_er_incorp_date),'DD');
     end if;

     select ue.user_entity_id, ue.user_entity_name
     bulk collect into t_user_entity_id_a8b, t_user_entity_name_a8b
     from ff_user_entities ue
     where ue.user_entity_name in (
                 'X_A8B_COMPANY'
                ,'X_A8B_COMPANY_TYPE'
                ,'X_A8B_EXERCISED_DATE'
                ,'X_A8B_EXER_PRICE'
                ,'X_A8B_GRANTED_DATE'
                ,'X_A8B_GRANT_TYPE'
                ,'X_A8B_MK_EXER_VALUE'
                ,'X_A8B_MK_GRANT_VALUE'
                ,'X_A8B_OPTION'
                ,'X_A8B_RCB'
                ,'X_A8B_SHARES_ACQUIRED')
     order by ue.user_entity_name desc;

    for shares_removed_rec in shares_removed (t_user_entity_id_a8b(1),
                                              l_assignment_id,
                                              p_person_id,
                                              p_tax_unit_id)
    loop

        begin
          l_temp_value :=' ';
          select  sum(value)
          into l_temp_value
          from ff_archive_items arch
          where arch.user_entity_id = t_user_entity_id_a8b(1)
            and arch.context1 IN(
                          select paa.assignment_action_id -- ALL PREV ORIGINAL AND  AMENDMENT ARCHIVES SUBMITTED B4
                          from pay_payroll_actions ppa,
                               pay_assignment_actions paa
                          where ppa.payroll_action_id in (
                                        SELECT org_information2
                                        FROM hr_organization_information
                                        WHERE org_information_context = 'SG_IRAS_DETAILS'
                                        AND organization_id  = g_legal_entity_id
                                        AND org_information1 = g_basis_year)
                          and ppa.payroll_action_id = paa.payroll_action_id
                          and paa.assignment_id = l_assignment_id)
            and exists (select 1
                        from ff_archive_item_contexts con1
                        where con1.archive_item_id = arch.archive_item_id
                        and con1.context = p_tax_unit_id
                               and con1.sequence_no =2)
            and exists (select 1
                        from ff_archive_item_contexts con2
                        where con2.archive_item_id = arch.archive_item_id
                        and con2.context = shares_removed_rec.person_extra_info_id
                        and con2.sequence_no = 3);
            exception
               WHEN NO_DATA_FOUND THEN
                      NULL;
         end;

         if l_temp_value <> 0 then
           g_amend_a8b_flag := 'Y';

           select arch.value
           bulk collect into t_amend_value_a8b
           from ff_user_entities ue ,
                ff_archive_items arch
           where ue.user_entity_name in ('X_A8B_COMPANY'
                  ,'X_A8B_RCB'
                  ,'X_A8B_COMPANY_TYPE'
                  ,'X_A8B_OPTION'
                  ,'X_A8B_MK_EXER_VALUE'
                  ,'X_A8B_MK_GRANT_VALUE'
                  ,'X_A8B_SHARES_ACQUIRED'
                  ,'X_A8B_EXER_PRICE'
                  ,'X_A8B_EXERCISED_DATE'
                  ,'X_A8B_GRANTED_DATE'
                  ,'X_A8B_GRANT_TYPE')
           and ue.user_entity_id = arch.user_entity_id
           AND ARCH.CONTEXT1 in ( select paa.assignment_action_id
              -- ALL PREV ORIGINAL AND  AMENDMENT ARCHIVES SUBMITTED B4
                 from  pay_payroll_actions ppa,
                       pay_assignment_actions paa
                 where ppa.payroll_action_id in (SELECT org_information2
                             FROM hr_organization_information
                             WHERE org_information_context = 'SG_IRAS_DETAILS'
                             AND organization_id  = g_legal_entity_id
                             AND org_information1 = g_basis_year)
                 and ppa.payroll_action_id = paa.payroll_action_id
                 and ppa.report_type='SG_IRAS_ARCHIVE'
                 and paa.assignment_id = l_assignment_id)
                 and exists (select 1
                             from ff_archive_item_contexts con1
                             where con1.archive_item_id = arch.archive_item_id
                             and con1.context = p_tax_unit_id
                             and con1.sequence_no =2)
                 and exists (select 1
                             from ff_archive_item_contexts con2
                             where con2.archive_item_id = arch.archive_item_id
                             and con2.context = shares_removed_rec.person_extra_info_id
                             and con2.sequence_no = 3)
            order by ue.user_entity_name desc;

            t_amend_value_a8b(1) := 0-l_temp_value;

            l_count := l_count +1;
            t_value_shares(l_count).person_extra_info_id := shares_removed_rec.person_extra_info_id;
            t_value_shares(l_count).shares_acquired := t_amend_value_a8b(1);
            t_value_shares(l_count).rcb := t_amend_value_a8b(2);
            t_value_shares(l_count).stock_option := t_amend_value_a8b(3);
            t_value_shares(l_count).market_grant_value := t_amend_value_a8b(4);
            t_value_shares(l_count).market_exercise_value := t_amend_value_a8b(5);
            t_value_shares(l_count).grant_type := t_amend_value_a8b(6);
            t_value_shares(l_count).grant_date := t_amend_value_a8b(7);
            t_value_shares(l_count).exercise_price := t_amend_value_a8b(8);
            t_value_shares(l_count).exercise_date := t_amend_value_a8b(9);
            t_value_shares(l_count).company_type :=  t_amend_value_a8b(10);
            t_value_shares(l_count).name_of_company := t_amend_value_a8b(11);
            t_value_shares(l_count).rec_type := 'A';

          end if;
     end loop;

     for share_rec in shares_details (p_person_id, p_basis_start, p_basis_end)
     loop
        archive_value_shares_acquired := share_rec.shares_acquired;

        begin
          l_temp_value := null;
          select sum(value)
          into l_temp_value
          from ff_archive_items arch
          where arch.user_entity_id = t_user_entity_id_a8b(1)
            and arch.context1 IN(
                          select paa.assignment_action_id -- ALL PREV ORIGINAL AND  AMENDMENT ARCHIVES SUBMITTED B4
                          from pay_payroll_actions ppa,
                               pay_assignment_actions paa
                          where ppa.payroll_action_id in (
                                        SELECT org_information2
                                        FROM hr_organization_information
                                        WHERE org_information_context = 'SG_IRAS_DETAILS'
                                        AND organization_id  = g_legal_entity_id
                                        AND org_information1 = g_basis_year)
                          and ppa.payroll_action_id = paa.payroll_action_id
                          and paa.assignment_id = l_assignment_id)
            and exists (select 1
                        from ff_archive_item_contexts con1
                        where con1.archive_item_id = arch.archive_item_id
                        and con1.context = p_tax_unit_id
                               and con1.sequence_no =2)
            and exists (select 1
                        from ff_archive_item_contexts con2
                        where con2.archive_item_id = arch.archive_item_id
                        and con2.context = share_rec.person_extra_info_id
                        and con2.sequence_no = 3);
            exception
               WHEN NO_DATA_FOUND THEN
                      NULL;
        end;
        amend_value_shares_acquired := nvl(l_temp_value,0);
        if to_number(archive_value_shares_acquired) <> to_number(amend_value_shares_acquired) then
          amend_a8b_flag := 'Y';
        end if;

        if amend_a8b_flag = 'Y' then
            l_count := l_count +1;
            t_value_shares(l_count).person_extra_info_id := share_rec.person_extra_info_id;
            t_value_shares(l_count).shares_acquired := archive_value_shares_acquired - amend_value_shares_acquired;
            t_value_shares(l_count).rcb := share_rec.rcb;
            t_value_shares(l_count).stock_option := share_rec.stock_option;
            t_value_shares(l_count).market_grant_value := share_rec.market_grant_value;
            t_value_shares(l_count).market_exercise_value := share_rec.market_exercise_value;
            t_value_shares(l_count).grant_type := share_rec.grant_type;
            t_value_shares(l_count).grant_date := share_rec.grant_date;
            t_value_shares(l_count).exercise_price := share_rec.exercise_price;
            t_value_shares(l_count).exercise_date := share_rec.exercise_date;
            t_value_shares(l_count).company_type := share_rec.company_type;
            t_value_shares(l_count).name_of_company := share_rec.name_of_company;
            if to_number(amend_value_shares_acquired) = 0 then
              t_value_shares(l_count).rec_type := 'O'; /*Original*/
            else
              t_value_shares(l_count).rec_type := 'A'; /* Amend */
            end if;
            g_amend_a8b_flag := 'Y';
        end if;

        amend_a8b_flag := 'N';
      end loop;

      for counter in 1..t_value_shares.count
      loop

        if t_value_shares(counter).stock_option = 'E' then
          if v_esop_count < 15 then
            if t_value_shares(counter).grant_type = 'P' and to_date(t_value_shares(counter).grant_date, 'YYYY/MM/DD') < to_date('2002/12/31','YYYY/MM/DD') then
              v_moa_305 := (t_value_shares(counter).market_exercise_value - t_value_shares(counter).exercise_price) * t_value_shares(counter).shares_acquired + v_moa_305;
            else
              v_moa_352 := (t_value_shares(counter).market_exercise_value - t_value_shares(counter).exercise_price) * t_value_shares(counter).shares_acquired + v_moa_352;
            end if;
            v_esop_count := v_esop_count + 1;
            v_archive := 'Y';
          end if;
        end if;

        if t_value_shares(counter).stock_option = 'EE' then
          if v_eesop_count < 15 then
            if t_value_shares(counter).grant_type = 'P' and to_date(t_value_shares(counter).grant_date, 'YYYY/MM/DD') < to_date('2002/12/31','YYYY/MM/DD') then
              v_moa_319 := trunc((t_value_shares(counter).market_exercise_value - t_value_shares(counter).market_grant_value)*t_value_shares(counter).shares_acquired,2)
              + trunc((t_value_shares(counter).market_grant_value - t_value_shares(counter).exercise_price) * t_value_shares(counter).shares_acquired,2) + v_moa_319;
            else
              v_moa_355 := trunc((t_value_shares(counter).market_exercise_value - t_value_shares(counter).market_grant_value)*t_value_shares(counter).shares_acquired,2)
              + trunc((t_value_shares(counter).market_grant_value - t_value_shares(counter).exercise_price) * t_value_shares(counter).shares_acquired,2) + v_moa_355;
            end if;
            v_eesop_count := v_eesop_count + 1;
            v_archive := 'Y';
            if v_eesop_date_error = 'N'
                 and t_value_shares(counter).rec_type = 'O' then
              if ((t_value_shares(counter).grant_type = 'P' and
                  to_date(t_value_shares(counter).grant_date, 'YYYY/MM/DD')
                    < to_date('2000/06/01','YYYY/MM/DD')) or
                 (t_value_shares(counter).grant_type = 'W' and
                  to_date(t_value_shares(counter).grant_date, 'YYYY/MM/DD')
                    < to_date('2002/01/01','YYYY/MM/DD'))) then
                 v_eesop_date_error := 'Y';
               end if;
             end if;
          end if;
        end if;

        if t_value_shares(counter).stock_option = 'C' then
          if v_csop_count < 15 then
            if t_value_shares(counter).grant_type = 'P' and to_date(t_value_shares(counter).grant_date, 'YYYY/MM/DD') < to_date('2002/12/31','YYYY/MM/DD') then
              v_moa_339 := trunc((t_value_shares(counter).market_exercise_value - t_value_shares(counter).market_grant_value)*t_value_shares(counter).shares_acquired,2)
             + trunc((t_value_shares(counter).market_grant_value - t_value_shares(counter).exercise_price) * t_value_shares(counter).shares_acquired,2) + v_moa_339;
            else
              v_moa_358 := trunc((t_value_shares(counter).market_exercise_value - t_value_shares(counter).market_grant_value)*t_value_shares(counter).shares_acquired,2)
              + trunc((t_value_shares(counter).market_grant_value - t_value_shares(counter).exercise_price) * t_value_shares(counter).shares_acquired,2) + v_moa_358;
            end if;
          v_csop_count := v_csop_count + 1;
          v_archive := 'Y';
          if v_csop_date_error = 'N'
               and t_value_shares(counter).rec_type = 'O' then
             if ((t_value_shares(counter).grant_type = 'P' and
                  to_date(t_value_shares(counter).grant_date, 'YYYY/MM/DD')
                    < to_date('2001/04/01','YYYY/MM/DD')) or
                 (t_value_shares(counter).grant_type = 'W' and
                  to_date(t_value_shares(counter).grant_date, 'YYYY/MM/DD')
                    < to_date('2002/01/01','YYYY/MM/DD'))) then
                v_csop_date_error := 'Y';
             end if;
           end if;
         end if;
       end if;

       if t_value_shares(counter).stock_option = 'N' then
          if v_nsop_count < 15 then
            if not (t_value_shares(counter).grant_type = 'P' and to_date(t_value_shares(counter).grant_date, 'YYYY/MM/DD') < to_date('2002/12/31','YYYY/MM/DD')) then
              v_moa_348 := (t_value_shares(counter).market_exercise_value - t_value_shares(counter).exercise_price) * t_value_shares(counter).shares_acquired + v_moa_348;
              v_moa_347 := (t_value_shares(counter).market_grant_value - t_value_shares(counter).exercise_price) * t_value_shares(counter).shares_acquired + v_moa_347;
            end if;
            v_nsop_count := v_nsop_count + 1;
            v_archive := 'Y';
            if v_nsop_date_error = 'N'
                 and t_value_shares(counter).rec_type = 'O' then
              if (to_date(t_value_shares(counter).grant_date,'YYYY/MM/DD') between
                to_date('2008/02/16','YYYY/MM/DD') and
                        to_date('2013/02/15','YYYY/MM/DD')) and
               (to_date(t_value_shares(counter).grant_date, 'YYYY/MM/DD') between
                  fnd_date.canonical_to_date(v_er_incorp_date_1) and
                   fnd_date.canonical_to_date(v_er_incorp_date_2)) then
                  null;
               else
                 v_nsop_date_error := 'Y';
               end if;
             end if;
           end if;
        end if;

        if t_value_shares(counter).rec_type = 'O' then
          if t_value_shares(counter).grant_type is null then
             v_grant_type_error := 'Y';
          end if;

          if v_a8b_data_error = 'N' then
            if t_value_shares(counter).shares_acquired <= 0 or (t_value_shares(counter).market_exercise_value - t_value_shares(counter).exercise_price) < 0 then
              v_a8b_data_error := 'Y';
            end if;
          end if;
        end if;

        if v_archive = 'Y' then
          archive_item_3('X_A8B_COMPANY', p_assignment_action_id, t_value_shares(counter).name_of_company, p_tax_unit_id, t_value_shares(counter).person_extra_info_id);
          archive_item_3('X_A8B_RCB', p_assignment_action_id, t_value_shares(counter).RCB, p_tax_unit_id, t_value_shares(counter).person_extra_info_id);
          archive_item_3('X_A8B_COMPANY_TYPE', p_assignment_action_id, t_value_shares(counter).company_type, p_tax_unit_id, t_value_shares(counter).person_extra_info_id);
          archive_item_3('X_A8B_OPTION', p_assignment_action_id, t_value_shares(counter).stock_option, p_tax_unit_id, t_value_shares(counter).person_extra_info_id);
          archive_item_3('X_A8B_MK_EXER_VALUE', p_assignment_action_id, t_value_shares(counter).market_exercise_value, p_tax_unit_id, t_value_shares(counter).person_extra_info_id);
          archive_item_3('X_A8B_MK_GRANT_VALUE', p_assignment_action_id, t_value_shares(counter).market_grant_value, p_tax_unit_id, t_value_shares(counter).person_extra_info_id);
          archive_item_3('X_A8B_SHARES_ACQUIRED', p_assignment_action_id, t_value_shares(counter).shares_acquired, p_tax_unit_id, t_value_shares(counter).person_extra_info_id);
          archive_item_3('X_A8B_EXER_PRICE', p_assignment_action_id, t_value_shares(counter).exercise_price, p_tax_unit_id, t_value_shares(counter).person_extra_info_id);
          archive_item_3('X_A8B_EXERCISED_DATE', p_assignment_action_id, t_value_shares(counter).exercise_date, p_tax_unit_id, t_value_shares(counter).person_extra_info_id);
          archive_item_3('X_A8B_GRANTED_DATE', p_assignment_action_id, t_value_shares(counter).grant_date, p_tax_unit_id, t_value_shares(counter).person_extra_info_id);
          archive_item_3('X_A8B_GRANT_TYPE', p_assignment_action_id, t_value_shares(counter).grant_type, p_tax_unit_id, t_value_shares(counter).person_extra_info_id);
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
         if v_er_incorp_date is null then
           archive_item ('X_PER_A8B_INCORP_DATE_ERROR', p_assignment_action_id, 'Y');
         end if;
       end if;
     end if;

     if g_debug then
          hr_utility.set_location('pysgiraa: End of archive_share_details', 100);
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

    l_person_id                     per_all_people_f.person_id%type;
    l_temp_person_id                per_all_people_f.person_id%type;
    l_archive_person_id             per_all_people_f.person_id%type;
    counter            number;
    l_counter          number;
    duplicate_exists   varchar2(1);
    l_ir8s_c_counts    number;

 begin
    l_temp_person_id  := NULL;
    l_counter         := 1;
    duplicate_exists  := 'N';
    --
    if g_debug then
         hr_utility.set_location('pysgiraa: Start of archive_ir8s_c_details', 10);
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
      for l_person_counter in 1..person_id_rec.last
        loop
          if person_id_rec.exists(l_person_counter) then
             l_archive_person_id := person_id_rec(1).person_id;
             --
             archive_ir8s_c_detail_moas(p_assignment_action_id
                                     ,person_id_rec(1).person_id
                                     ,person_id_rec(l_person_counter).person_id
                                     ,p_tax_unit_id
                                     ,p_business_group_id
                                     ,p_basis_start
                                     ,p_basis_end);
           end if;
         end loop;

    end if;
    --
    if g_debug then
         hr_utility.set_location('pysgiraa: End of archive_ir8s_c_details', 100);
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


    type t_archive_items_tab is table of ff_archive_items.archive_item_id%TYPE index by binary_integer;
    t_archive_items_ir8s_c   t_archive_items_tab;

    type t_archive_value_tab is table of ff_archive_items.value%TYPE index by binary_integer;
    t_archive_value_ir8s_c   t_archive_value_tab;

    type t_amend_value_tab is table of ff_archive_items.value%TYPE index by binary_integer;
    t_amend_value_ir8s_c     t_amend_value_tab;
    t_amend_value_ir8s_c1    t_amend_value_tab;

    type t_user_entity_tab is table of ff_user_entities.user_entity_id%TYPE index by binary_integer;
    t_user_entity_id_ir8s_c  t_user_entity_tab;

    type t_user_entity_name_tab is table of ff_user_entities.user_entity_name%TYPE index by binary_integer;
    t_user_entity_name_ir8s_c  t_user_entity_name_tab;


    type t_assignment_extra_info_tab is table of per_assignment_extra_info.assignment_extra_info_id%TYPE index by binary_integer;
    t_aeid_ir8s_c            t_assignment_extra_info_tab;

    type ir8s_c_rec is record
      ( assignment_extra_info_id   per_assignment_extra_info.assignment_extra_info_id%type,
        value           number );
    type ir8s_c_value_tab is table of ir8s_c_rec index by binary_integer;
    value_ir8s_c ir8s_c_value_tab;

     l_temp_value                    VARCHAR2(2000);
     l_name_ue                       VARCHAR2(2000);


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

    cursor ir8s_c_removed
      (c_user_entity_id      ff_user_entities.user_entity_id%type,
       c_assignment_id       per_assignment_extra_info.assignment_id%type,
       c_tax_unit_id         ff_archive_item_contexts.context%type) is

    select distinct con2.context assignment_extra_info_id
    from   ff_archive_items arch,
           ff_archive_item_contexts con2
    where  arch.user_entity_id = c_user_entity_id
    and    arch.context1 IN(
                  select paa.assignment_action_id -- ALL PREV ORIGINAL AND  AMENDMENT ARCHIVES SUBMITTED B4
                  from   pay_payroll_actions ppa,
                         pay_assignment_actions paa
                  where  ppa.payroll_action_id in (
                             SELECT org_information2
                             FROM hr_organization_information
                             WHERE org_information_context = 'SG_IRAS_DETAILS'
                             AND organization_id  = g_legal_entity_id
                                        AND org_information1 = g_basis_year)
                          and ppa.payroll_action_id = paa.payroll_action_id
                          and paa.assignment_id = c_assignment_id)
            and exists (select 1
                        from ff_archive_item_contexts con1
                        where con1.archive_item_id = arch.archive_item_id
                        and con1.context = c_tax_unit_id
                        and con1.sequence_no =2)
            and arch.archive_item_id = con2.archive_item_id
            and con2.sequence_no = 3
            and not exists (select 1
                            from   per_assignment_extra_info aei
                            where  aei.assignment_id = c_assignment_id
                            and   aei.assignment_extra_info_id = con2.context);


   v_ir8s_total_moa410  number;
   l_assignment_id      number;
   l_count              number;
   amend_ir8s_c_flag    varchar2(1);

   begin
    v_ir8s_total_moa410  := 0;
    l_count := 0;
    g_amend_ir8s_c_flag := 'N';
    if g_debug then
          hr_utility.set_location('pysgiraa: Start of archive_ir8s_c_detail_moas', 10);
    end if;
    --
 select ue.user_entity_id, ue.user_entity_name
 bulk collect into t_user_entity_id_ir8s_c, t_user_entity_name_ir8s_c
 from ff_user_entities ue
 where ue.user_entity_name in  ('X_MOA410',
          'X_MOA411',
          'X_MOA412',
          'X_MOA413',
          'X_MOA414')
 order by ue.user_entity_name;

    SELECT assignment_id
    INTO l_assignment_id
    FROM pay_assignment_Actions paa
    WHERE paa.assignment_action_id = p_assignment_action_id;

    amend_ir8s_c_flag := 'N';

    for ir8s_c_removed_rec in ir8s_c_removed (t_user_entity_id_ir8s_c(1),
                                              l_assignment_id,
                                              p_tax_unit_id)
    loop

      for counter in 1..t_user_entity_id_ir8s_c.count
      loop

        begin
          l_temp_value := ' ';
          select  sum(value)
          into l_temp_value
          from ff_archive_items arch
          where arch.user_entity_id = t_user_entity_id_ir8s_c(counter)
            and arch.context1 IN(
                          select paa.assignment_action_id -- ALL PREV ORIGINAL AND  AMENDMENT ARCHIVES SUBMITTED B4
                          from pay_payroll_actions ppa,
                               pay_assignment_actions paa
                          where ppa.payroll_action_id in (
                                        SELECT org_information2
                                        FROM hr_organization_information
                                        WHERE org_information_context = 'SG_IRAS_DETAILS'
                                        AND organization_id  = g_legal_entity_id
                                        AND org_information1 = g_basis_year)
                          and ppa.payroll_action_id = paa.payroll_action_id
                          and paa.assignment_id = l_assignment_id)
            and exists (select 1
                        from ff_archive_item_contexts con1
                        where con1.archive_item_id = arch.archive_item_id
                        and con1.context = p_tax_unit_id
                               and con1.sequence_no =2)
            and exists (select 1
                        from ff_archive_item_contexts con2
                        where con2.archive_item_id = arch.archive_item_id
                        and con2.context = ir8s_c_removed_rec.assignment_extra_info_id
                        and con2.sequence_no = 3);
            exception
               WHEN NO_DATA_FOUND THEN
                      NULL;
         end;
         t_amend_value_ir8s_c(counter) := l_temp_value;

         if t_amend_value_ir8s_c(counter) <> 0 then
           amend_ir8s_c_flag := 'Y';
         else
           amend_ir8s_c_flag := 'N';
         end if;

       end loop;

       if amend_ir8s_c_flag = 'Y' then
         for counter in 1..t_user_entity_id_ir8s_c.count
         loop
         archive_item_3(t_user_entity_name_ir8s_c(counter),
                       p_assignment_action_id,
                       0 - t_amend_value_ir8s_c(counter),
                        p_tax_unit_id, ir8s_c_removed_rec.assignment_extra_info_id);

         end loop;

         select arch.value
         bulk collect into t_amend_value_ir8s_c1
         from ff_user_entities ue ,
              ff_archive_items arch
         where ue.user_entity_name in ('X_DTM502'
                                      ,'X_DTM503'
                                      ,'X_DTM504'
                                      ,'X_DTM505'
                                      ,'X_DTM506')
         and ue.user_entity_id = arch.user_entity_id
         AND ARCH.CONTEXT1 in ( select paa.assignment_action_id
            -- ALL PREV ORIGINAL AND  AMENDMENT ARCHIVES SUBMITTED B4
               from  pay_payroll_actions ppa,
                     pay_assignment_actions paa
               where ppa.payroll_action_id in (SELECT org_information2
                           FROM hr_organization_information
                           WHERE org_information_context = 'SG_IRAS_DETAILS'
                           AND organization_id  = g_legal_entity_id
                           AND org_information1 = g_basis_year)
               and ppa.payroll_action_id = paa.payroll_action_id
               and ppa.report_type='SG_IRAS_ARCHIVE'
               and paa.assignment_id = l_assignment_id)
               and exists (select 1
                           from ff_archive_item_contexts con1
                           where con1.archive_item_id = arch.archive_item_id
                           and con1.context = p_tax_unit_id
                           and con1.sequence_no =2)
               and exists (select 1
                           from ff_archive_item_contexts con2
                           where con2.archive_item_id = arch.archive_item_id
                           and con2.context = ir8s_c_removed_rec.assignment_extra_info_id
                           and con2.sequence_no = 3)
          order by ue.user_entity_name desc;

         archive_item_3('X_DTM502', p_assignment_action_id,
                        t_amend_value_ir8s_c1(1),
                        p_tax_unit_id,
                        ir8s_c_removed_rec.assignment_extra_info_id);
         archive_item_3('X_DTM503', p_assignment_action_id,
                        t_amend_value_ir8s_c1(2),
                        p_tax_unit_id,
                        ir8s_c_removed_rec.assignment_extra_info_id);
         archive_item_3('X_DTM504', p_assignment_action_id,
                        t_amend_value_ir8s_c1(3),
                        p_tax_unit_id,
                        ir8s_c_removed_rec.assignment_extra_info_id);
         archive_item_3('X_DTM505', p_assignment_action_id,
                        t_amend_value_ir8s_c1(4),
                        p_tax_unit_id,
                        ir8s_c_removed_rec.assignment_extra_info_id);
         archive_item_3('X_DTM506', p_assignment_action_id,
                        t_amend_value_ir8s_c1(5),
                        p_tax_unit_id,
                        ir8s_c_removed_rec.assignment_extra_info_id);

         v_ir8s_total_moa410:=v_ir8s_total_moa410-t_amend_value_ir8s_c(1);
         t_amend_value_ir8s_c.delete;
         g_amend_ir8s_flag :='Y';
         l_count := l_count +1;
       end if;

       amend_ir8s_c_flag := 'N';
    end loop;

    for ir8s_c_rec in ir8s_c_details (p_person_id
	                            , p_tax_unit_id
                                    , p_business_group_id
                                    , p_basis_start
                                    , p_basis_end)
    loop
      t_archive_value_ir8s_c(1) := ir8s_c_rec.add_wages;
      t_archive_value_ir8s_c(2) := ir8s_c_rec.er_cpf;
      t_archive_value_ir8s_c(3) := ir8s_c_rec.er_cpf_interest;
      t_archive_value_ir8s_c(4) := ir8s_c_rec.ee_cpf;
      t_archive_value_ir8s_c(5) := ir8s_c_rec.ee_cpf_interest;

      for counter in 1..t_user_entity_id_ir8s_c.count
      loop
         select user_entity_name
         into l_name_ue
         from ff_user_entities where user_entity_id = t_user_entity_id_ir8s_c(counter);

        begin
          l_temp_value := ' ';
          select  sum(value)
          into l_temp_value
          from ff_archive_items arch
          where arch.user_entity_id = t_user_entity_id_ir8s_c(counter)
            and arch.context1 IN(
                          select paa.assignment_action_id -- ALL PREV ORIGINAL AND  AMENDMENT ARCHIVES SUBMITTED B4
                          from pay_payroll_actions ppa,
                               pay_assignment_actions paa
                          where ppa.payroll_action_id in (
                                        SELECT org_information2
                                        FROM hr_organization_information
                                        WHERE org_information_context = 'SG_IRAS_DETAILS'
                                        AND organization_id  = g_legal_entity_id
                                        AND org_information1 = g_basis_year)
                          and ppa.payroll_action_id = paa.payroll_action_id
                          and paa.assignment_id = l_assignment_id)
            and exists (select 1
                        from ff_archive_item_contexts con1
                        where con1.archive_item_id = arch.archive_item_id
                        and con1.context = p_tax_unit_id
                               and con1.sequence_no =2)
            and exists (select 1
                        from ff_archive_item_contexts con2
                        where con2.archive_item_id = arch.archive_item_id
                        and con2.context = ir8s_c_rec.assignment_extra_info_id
                        and con2.sequence_no = 3);
            exception
               WHEN NO_DATA_FOUND THEN
                      NULL;
         end;
         t_amend_value_ir8s_c(counter) := nvl(l_temp_value,0);

         if t_amend_value_ir8s_c.exists(counter)
                         and t_archive_value_ir8s_c.exists(counter) then
               if t_amend_value_ir8s_c(counter) <>
                   t_archive_value_ir8s_c(counter) then
                       amend_ir8s_c_flag := 'Y';
               end if;
         else
               amend_ir8s_c_flag := 'Y';
         end if;

       end loop;

       if amend_ir8s_c_flag = 'Y' then
         archive_item('X_IR8S_AMEND_INDICATOR', p_assignment_action_id, 'Y');

         for counter in 1..t_user_entity_id_ir8s_c.count
         loop
         archive_item_3(t_user_entity_name_ir8s_c(counter),
                       p_assignment_action_id,
                       t_archive_value_ir8s_c(counter) - t_amend_value_ir8s_c(counter),
                        p_tax_unit_id, ir8s_c_rec.assignment_extra_info_id);

         end loop;
         archive_item_3('X_DTM502', p_assignment_action_id,
                        ir8s_c_rec.add_wages_from_date,
                        p_tax_unit_id, ir8s_c_rec.assignment_extra_info_id);
         archive_item_3('X_DTM503', p_assignment_action_id,
                        ir8s_c_rec.add_wages_to_date,
                        p_tax_unit_id, ir8s_c_rec.assignment_extra_info_id);
         archive_item_3('X_DTM504', p_assignment_action_id,
                        ir8s_c_rec.pay_date_add_wages,
                        p_tax_unit_id, ir8s_c_rec.assignment_extra_info_id);
        archive_item_3('X_DTM505', p_assignment_action_id,
                        ir8s_c_rec.er_cpf_date,
                        p_tax_unit_id, ir8s_c_rec.assignment_extra_info_id);
        archive_item_3('X_DTM506', p_assignment_action_id,
                        ir8s_c_rec.ee_cpf_date,
                        p_tax_unit_id, ir8s_c_rec.assignment_extra_info_id);

         v_ir8s_total_moa410:=v_ir8s_total_moa410 +t_archive_value_ir8s_c(1)-t_amend_value_ir8s_c(1);
         t_amend_value_ir8s_c.delete;
         t_archive_value_ir8s_c.delete;
         g_amend_ir8s_c_flag :='Y';
         l_count := l_count +1;
       end if;

       amend_ir8s_c_flag := 'N';
    end loop;

    if l_count >3 then
      archive_item ('X_IR8S_C_INVALID_RECORDS', p_assignment_action_id, 'N');
    else
      archive_item ('X_IR8S_C_INVALID_RECORDS', p_assignment_action_id, 'Y');
    end if;
    if g_amend_ir8s_c_flag = 'N' then
      archive_item_3('X_MOA410', p_assignment_action_id, 0,
                        p_tax_unit_id,0);
    end if;

    if v_ir8s_total_moa410 <> 0 then

      archive_item('X_IR8S_TOTAL_MOA410', p_assignment_action_id, v_ir8s_total_moa410);
    end if;
    --
    if g_debug then
          hr_utility.set_location('pysgiraa: End of archive_ir8s_c_detail_moas', 100);
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
          l_report_type    varchar2(30);
          l_rep_req_id     number;
          v_setup_action   pay_payroll_actions.payroll_action_id%type;
     begin
          l_rep_req_id  := 0;
	  v_setup_action := 0;
          if g_debug then
              hr_utility.set_location('pysgiraa: Start of deinit_code',10);
          end if;
          --
          select  report_type
          into    l_report_type
          from    pay_payroll_actions ppa
          where   ppa.payroll_action_id = p_payroll_action_id ;
          --
          if l_report_type = 'SG_IRAS_AMEND_ARCHIVE' then
	   select   pay_core_utils.get_parameter('SETUP_ACTION_ID',legislative_parameters)
                into     v_setup_action
                from     pay_payroll_actions
                where    payroll_action_id = p_payroll_action_id ;
        --------------------------------------------------------
		-- Bug: 3910804 Delete data from pay_action_information
		-------------------------------------------------------
                delete from pay_action_information
                where  action_context_id   = v_setup_action
                  and  action_context_type = 'AAP'
                  and  action_information_category = 'SG_IRAS_AMEND_SETUP';

                py_rollback_pkg.rollback_payroll_action( v_setup_action );

                --
          end if;
     exception
          when others then
                if g_debug then
                     hr_utility.set_location('pysgiraa: End of deinit_code',10);
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
                  and    pai.action_information_category = 'SG_IRAS_AMEND_SETUP'
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
              hr_utility.set_location('pysgiraa: Start of person_if_archived',10);
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
              hr_utility.set_location('pysgiraa: Start of pri_if_latest',10);
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
              hr_utility.set_location('pysgiraa: Start of pri_LE_if_latest',10);
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
              hr_utility.set_location('pysgiraa: Start of id_LE_if_latest',10);
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

begin
   g_debug   := hr_utility.debug_enabled;
   g_org_run := 'N';
   g_org_a8a_run := 'N';
   g_iras_method := 'A';
   g_a8b_moa_348 := 0;
end pay_sg_iras_amend_archive;

/
