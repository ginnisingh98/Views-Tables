--------------------------------------------------------
--  DDL for Package Body PAY_SG_IRAS_AMEND_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SG_IRAS_AMEND_SETUP" as
/* $Header: pysgiras.pkb 120.0.12010000.4 2009/12/15 03:41:09 jalin noship $ */
  g_debug boolean;
  l_package_name varchar2(50);
  -----------------------------------------------------------------------------
  -- The SELECT statement in this procedure returns the Person Ids for
  -- Assignments that require the archive process to create an Assignment
  -- Action.
  -- Core Payroll recommends the select has minimal restrictions.
  -----------------------------------------------------------------------------
  procedure range_code
    ( p_payroll_action_id   in  pay_payroll_actions.payroll_action_id%type
      , p_sql               out nocopy varchar2 )
  is
  begin
      if g_debug then
          hr_utility.trace(l_package_name||'range_code - Start');
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
          hr_utility.trace(l_package_name||'range_code - End');
      end if;
  end range_code;
  ----------------------------------------------------------------------------
  -- This procedure is used to restrict the Assignment Action Creation.
  -- It calls the procedure that actually inserts the Assignment Actions.
  -- The cursor selects the assignments that have had any payroll
  -- processing for the Legal Entity within the Basis Year.
  -- The person must not have the "IR21 Run Date" set, as this means they
  -- have received this form, and therefore must not appear in the
  -- archive/magtape.
  -- The person must not have had any Magtape File produced for the same
  -- Business Group, Legal Entity and Basis Year. If they want to
  -- re-archive a person, they must ROLLBACK the magtape first, or use the
  -- standard Re-try, Rollback payroll process.
  ----------------------------------------------------------------------------
  procedure assignment_action_code
    ( p_payroll_action_id    in  pay_payroll_actions.payroll_action_id%type
      , p_start_person_id    in  per_all_people_f.person_id%type
      , p_end_person_id      in  per_all_people_f.person_id%type
      , p_chunk              in  number )
  is
      v_next_action_id  pay_assignment_actions.assignment_action_id%type;
      v_effective_date      date;
      v_business_group_id   number;
      v_basis_start         date;
      v_basis_end           date;
      v_legal_entity_id     number;
      v_assignment_set_id   number;
      v_person_id           number;
      v_basis_year          number;
      -------------------------------------------
      -- Record of Assignments
      -------------------------------------------
      type t_assignment_list is table of per_all_assignments_f.assignment_id%type;
      asglist t_assignment_list;
      ----------------------------------------------------------------------------
      -- Legislative Parameters for Run
      ----------------------------------------------------------------------------
      cursor  get_params( c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type )
      is
      select  nvl(to_date(to_char(to_date(pay_core_utils.get_parameter('EFFECTIVE_DATE', legislative_parameters),
                                                              'YYYY/MM/DD'),'DD-MM-YYYY'),'DD-MM-YYYY'),
              to_date('31-12-'||pay_core_utils.get_parameter('BASIS_YEAR',legislative_parameters),'DD-MM-YYYY')),
              pay_core_utils.get_parameter('BUSINESS_GROUP_ID',legislative_parameters),
              to_date('01-01-'||pay_core_utils.get_parameter('BASIS_YEAR',legislative_parameters),'DD-MM-YYYY'),
              to_date('31-12-'|| pay_core_utils.get_parameter('BASIS_YEAR',legislative_parameters),'DD-MM-YYYY'),
              pay_core_utils.get_parameter('LEGAL_ENTITY_ID',legislative_parameters),
              pay_core_utils.get_parameter('ASSIGNMENT_SET_ID',legislative_parameters),
              pay_core_utils.get_parameter('PERSON_ID',legislative_parameters),
              pay_core_utils.get_parameter('BASIS_YEAR',legislative_parameters)
      from    pay_payroll_actions
      where   payroll_action_id =c_payroll_Action_id;
      ----------------------------------------------------------------------------
      -- Cursor Next Assignment Action
      ----------------------------------------------------------------------------
      cursor  next_action_id is
      select  pay_assignment_actions_s.nextval
      from    dual;
      ----------------------------------------------------------------------------
      -- Filters Assignments to be processed.
      ----------------------------------------------------------------------------
      cursor process_assignments
          ( c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
            c_start_person_id    in per_all_people_f.person_id%type,
            c_end_person_id      in per_all_people_f.person_id%type )
      is
      select  distinct a.assignment_id
      from    per_assignments_f a,
              pay_payroll_actions pa
      where   pa.payroll_action_id = c_payroll_action_id
      and     a.person_id    between c_start_person_id and c_end_person_id
      and     a.business_group_id  = pa.business_group_id
      and     ( a.effective_start_date <= v_basis_end and a.effective_end_date>= v_basis_start)
      and     decode(v_assignment_set_id,null,'Y',
                decode(hr_assignment_set.ASSIGNMENT_IN_SET(v_assignment_set_id,a.assignment_id),'Y','Y','N')) = 'Y'
      and     a.person_id = nvl(v_person_id,a.person_id)
      ----------------------------------------------------------------------
      -- Do not select the person if they have had an IR21 Form produced
      ----------------------------------------------------------------------
      and    not exists
             ( select  null
               from    per_people_extra_info pei
               where   pei.person_id        = a.person_id
               and     pei.pei_information1 is not null
               and     pei.information_type = 'HR_IR21_PROCESSING_DATES_SG'
	     )
      ----------------------------------------------------------------------
      -- Select the person if they have had any Magtape File produced for the same
      -- Business Group, Legal Entity and Basis Year
      -- We'll do this because unless they have submitted an original, no need of an archive
      ----------------------------------------------------------------------
       and    exists
             ( select null
               from   per_assignments_f  paf,
                      pay_assignment_actions mcl,
                      pay_payroll_actions mpl
               where  paf.assignment_id      = a.assignment_id
               and    paf.assignment_id      = mcl.assignment_id
               and    mpl.payroll_action_id  = mcl.payroll_action_id
               and    mpl.business_group_id  = pa.business_group_id
               and    mpl.effective_date     between v_basis_start and v_basis_end
               and    pay_core_utils.get_parameter('LEGAL_ENTITY_ID',mpl.legislative_parameters) = v_legal_entity_id
               and    mpl.report_type        in ( 'SG_A8B','SG_IR8A','SG_IR8S','SG_A8A' )
               and    mpl.action_type        = 'X'
               and    mcl.action_status      = 'C'
               group by paf.assignment_id
	     )
      --------------------------------------------------------------------------------------------------------------------
      -- Select an assignment if any payroll runs exist for assignment in processing
      -- year and legal entity.
      --------------------------------------------------------------------------------------------------------------------
       and    exists
             ( select null
               from   per_assignments_f  paf,
                      pay_assignment_actions pac,
                      pay_payroll_actions ppa
               where  paf.assignment_id      = a.assignment_id
               and    paf.assignment_id      = pac.assignment_id
               and    pac.tax_unit_id        = v_legal_entity_id
               and    ppa.payroll_action_id  = pac.payroll_action_id
               and    ppa.action_type        in ('R','B','I','Q','V')
               and    pac.action_status      = 'C'
               and    ppa.business_group_id  = v_business_group_id
               and    ppa.effective_date     between v_basis_start and v_basis_end
               group by paf.assignment_id
             );
      ----------------------------------------------------------------------
  begin
      if g_debug then
          hr_utility.trace(l_package_name||'assignment_action_code - Start');
      end if;
      --
      open   get_params(p_payroll_action_id);
      fetch  get_params
      into   v_effective_date,
             v_business_group_id,
             v_basis_start,
             v_basis_end,
             v_legal_entity_id,
             v_assignment_set_id,
             v_person_id,
             v_basis_year;
      close get_params;
      --
      open process_assignments(  p_payroll_action_id,
                                 p_start_person_id,
                                 p_end_person_id  ) ;
      fetch process_assignments bulk collect into asglist;
      close process_assignments;
      --
      for i in 1..asglist.count
      loop
         if asglist.exists(i) then
             open   next_action_id;
             fetch  next_action_id into v_next_action_id;
             close  next_action_id;
             --
             if g_debug then
                 hr_utility.trace(l_package_name||'assignment_action_code - Before hr_nonrun_asact.insact');
             end if;
	     --
             hr_nonrun_asact.insact(   v_next_action_id
	                             , asglist(i)
				     , p_payroll_action_id
				     , p_chunk
				     , null
				   );
             --
             if g_debug then
                 hr_utility.trace(l_package_name||'assignment_action_code - After hr_nonrun_asact.insact');
             end if;
         end if;
      end loop;
      --
      if g_debug then
           hr_utility.trace(l_package_name||'assignment_action_code - End');
      end if;
  end assignment_action_code;
  ------------------------------------------------------------------------
  -- Archives Person details for the processing Assignment
  ------------------------------------------------------------------------
  procedure archive_code
    ( p_assignment_action_id    in  pay_assignment_actions.assignment_action_id%type
      , p_effective_date        in  date )
  is
      v_national_identifier    per_all_people_f.national_identifier%type;
      v_start_date              varchar2(50); /* Bug# 3910804 */
      v_person_id              per_all_people_f.person_id%type;
      v_assignment_id          per_all_assignments_f.assignment_id%type;
      v_setup_action           pay_assignment_actions.payroll_action_id%type;
      ------------------------------------------------------------------------
      -- Get Person Details
      -- Bug 3910804 - Selected canonical format of person start date
      ------------------------------------------------------------------------
      cursor get_details
          ( c_assignment_action_id  pay_assignment_actions.assignment_action_id%type )
      is
      select  nvl(pap.national_identifier,per_information12),
              fnd_date.date_to_canonical(pap.start_date),   /* Bug# 3910804 */
              paa.person_id,
              pac.assignment_id
      from    pay_assignment_actions pac,
              per_assignments_f      paa,
              per_people_f           pap
      where   pac.assignment_action_id = c_assignment_action_id
      and     paa.assignment_id        = pac.assignment_id
      and     paa.person_id            = pap.person_id;
      --
  begin
      if g_debug then
          hr_utility.trace(l_package_name||'Archive_Code - Start');
      end if;
      -------------------------------------------------------------------
      -- Get setup action id
      -------------------------------------------------------------------
      select  payroll_action_id
      into    v_setup_action
      from    pay_assignment_actions
      where   assignment_action_id = p_assignment_action_id ;
      --
      open get_details ( p_assignment_action_id );
      fetch get_details into v_national_identifier,
                             v_start_date,
                             v_person_id,
                             v_assignment_id;
      if get_details%found then
           close get_details;
           --
           if g_debug then
               hr_utility.trace(l_package_name||'Archive_Code - Before pai insert');
           end if;
           --------------------------------------------------------------
           --
           --
           --------------------------------------------------------------
           insert into pay_action_information
           (  action_information_id,
              action_context_id,
              action_context_type,
              action_information_category,
              action_information1,
              action_information2,
              action_information3,
              assignment_id  )
           values
           (  pay_action_information_s.nextval,
              v_setup_action,
              'AAP',
              'SG_IRAS_AMEND_SETUP',
              v_national_identifier,
              v_person_id,
              v_start_date,
              v_assignment_id  );
           --
           if g_debug then
               hr_utility.trace(l_package_name||'Archive_Code - After pai insert');
           end if;
      else
           if g_debug then
               hr_utility.trace(l_package_name||'Archive_Code - Person record not found');
           end if;
           --
           close get_details;
      end if;
      --
      if g_debug then
           hr_utility.trace(l_package_name||'Archive_Code - End');
      end if;
  end archive_code;
  --------------------------------------------------------------
  -- Initiates IRAS Line Archive Processor
  --------------------------------------------------------------
  procedure deinit_code
      ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type )
  is
      l_rep_req_id  number;
      v_magnetic_file_name    varchar2(50);
      v_le                    number;
      v_basis                 number;
      v_bg_id                 number;
      v_ass_id                number;
      v_per_id                number;
      v_action_parameter_group varchar2(50);

      --
      cursor  csr_iras_action_details is
      select  pay_core_utils.get_parameter('BUSINESS_GROUP_ID',legislative_parameters),
              pay_core_utils.get_parameter('LEGAL_ENTITY_ID',legislative_parameters),
              pay_core_utils.get_parameter('BASIS_YEAR',legislative_parameters),
              pay_core_utils.get_parameter('MAGNETIC_FILE_NAME',legislative_parameters),
	      pay_core_utils.get_parameter('ACTION_PARAMETER_GROUP',legislative_parameters),
          pay_core_utils.get_parameter('ASSIGNMENT_SET_ID',legislative_parameters),
pay_core_utils.get_parameter('PERSON_ID',legislative_parameters)
        from  pay_payroll_actions
       where  payroll_action_id = p_payroll_action_id;
  begin
      if g_debug then
           hr_utility.trace(l_package_name||'Deinit_Code - Start');
      end if;
      --
      open   csr_iras_action_details;
      fetch  csr_iras_action_details into
                  v_bg_id,
                  v_le,
                  v_basis,
                  v_magnetic_file_name,
                  v_action_parameter_group,
                  v_ass_id,
                  v_per_id;

      close  csr_iras_action_details;
      --
      if g_debug then
           hr_utility.trace(l_package_name||'Deinit_Code - Before initiating archive');
      end if;
      --

      l_rep_req_id := FND_REQUEST.SUBMIT_REQUEST (
 	                                         APPLICATION          =>   'PAY',
                                                 PROGRAM              =>   'PYSGIRAA',
                                                 ARGUMENT1            =>   'ARCHIVE',
                                                 ARGUMENT2            =>   'SG_IRAS_AMEND_ARCHIVE',
						 ARGUMENT3            =>   'SG',
						 ARGUMENT4            =>   null,
						 ARGUMENT5            =>   null,
						 ARGUMENT6            =>   'REPORT',
						 ARGUMENT7            =>   v_bg_id,
						 ARGUMENT8            =>   v_magnetic_file_name,
						 ARGUMENT9            =>   null,
						 ARGUMENT10           =>   v_action_parameter_group,
                         ARGUMENT11           =>   v_le,
                         ARGUMENT12           =>   v_basis,
                         ARGUMENT13           =>   v_ass_id,
                         ARGUMENT14           =>   v_per_id,
                         ARGUMENT15           =>   'START_DATE='||to_char(v_basis)||'/01/01 00:00:00',
                         ARGUMENT16           =>   'END_DATE='||to_char(v_basis)||'/12/31 00:00:00',
ARGUMENT17=>'BUSINESS_GROUP_ID='||v_bg_id||' LEGAL_ENTITY_ID='||v_le||' SETUP_ACTION_ID='||p_payroll_action_id||' ASSIGNMENT_SET_ID='||v_ass_id||' PERSON_ID='||v_per_id||' BASIS_YEAR='||v_basis||' '||'END_DATE='||to_char(v_basis)||'/12/31 00:00:00');

      if g_debug then
           hr_utility.trace(l_package_name||'Deinit_Code - After initiating archive');
           hr_utility.trace(l_package_name||'Deinit_Code - End');
      end if;
  end deinit_code;
begin
  l_package_name := 'pay_sg_iras_amend_setup.';
  g_debug        := hr_utility.debug_enabled;
end pay_sg_iras_amend_setup;

/
