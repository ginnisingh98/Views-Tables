--------------------------------------------------------
--  DDL for Package Body PAY_SG_IRAS_MAGTAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SG_IRAS_MAGTAPE" as
/* $Header: pysgirmt.pkb 120.2.12010000.8 2009/06/24 05:15:40 jalin ship $ */
  ---------------------------------------------------------------------------
  -- These are PUBLIC procedures that are used within this package.
  ---------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- The SELECT statement in this procedure returns the Person Ids for
  -- Assignments that require the archive process to create an Assignment
  -- Action.
  -- Core Payroll recommend the SELECT has minimal restrictions.
  ------------------------------------------------------------------------
  procedure range_code
    (p_payroll_action_id   in pay_payroll_actions.payroll_action_id%type,
     p_sql                out nocopy varchar2) is
  begin
    hr_utility.set_location('Start of range_code',1);

    p_sql := 'select distinct person_id ' ||
             'from   per_people_f ppf, ' ||
                    'pay_payroll_actions ppa ' ||
             'where ppa.payroll_action_id = :payroll_action_id ' ||
             'and ppa.business_group_id = ppf.business_group_id ' ||
             'order by ppf.person_id';

    hr_utility.set_location('End of range_code',2);
  end range_code;

    --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_PARAMETERS                                      --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure determines the globals applicable    --
  --                  through out the tenure of the process               --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id  NUMBER                         --
  --                  p_token_name         VARCHAR2                       --
  --            OUT : p_token_value        VARCHAR2                       --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 5-Jan-2006     lnagaraj   Initial Version                      --
  --------------------------------------------------------------------------
  PROCEDURE get_parameters(p_payroll_action_id IN  NUMBER,
                           p_token_name        IN  VARCHAR2,
                           p_token_value       OUT  NOCOPY VARCHAR2)
  IS

    CURSOR csr_parameter_info(p_pact_id NUMBER,
                              p_token   CHAR) IS
    SELECT SUBSTR(legislative_parameters,
                   INSTR(legislative_parameters,p_token)+(LENGTH(p_token)+1),
                    INSTR(legislative_parameters,' ',
                           INSTR(legislative_parameters,p_token))
                     - (INSTR(legislative_parameters,p_token)+LENGTH(p_token)))
           ,business_group_id
      FROM  pay_payroll_actions
     WHERE  payroll_action_id = p_pact_id;

    l_token_value VARCHAR2(150);
    l_bg_id       NUMBER;
    l_proc        VARCHAR2(100);
    l_message     VARCHAR2(255);

BEGIN

    OPEN csr_parameter_info(p_payroll_action_id,
                            p_token_name);
    FETCH csr_parameter_info INTO l_token_value,l_bg_id;
    CLOSE csr_parameter_info;


    p_token_value := TRIM(l_token_value);


    IF (p_token_name = 'BG_ID') THEN
        p_token_value := l_bg_id;
    END IF;

    IF (p_token_value IS NULL) THEN
         p_token_value := '%';
    END IF;


  END get_parameters;

  ------------------------------------------------------------------------
  -- This procedure is used to restrict the Assignment Action Creation.
  -- It calls the procedure that actually inserts the Assignment Actions.
  -- The cursor selects the assignments for people who have been archived
  -- for the Archive Run.
  -- The archive assignment action is then locked by this (magtape)
  -- assignment action.  This is done so that the archive can not be
  -- rolled back without first rolling back the magtape.
  ------------------------------------------------------------------------
  procedure assignment_action_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
     p_start_person_id    in per_all_people_f.person_id%type,
     p_end_person_id      in per_all_people_f.person_id%type,
     p_chunk              in number) is

    v_next_action_id      pay_assignment_actions.assignment_action_id%type;
    v_archive_action_id   pay_assignment_actions.assignment_action_id%type;
    v_type                ff_database_items.user_name%type;

    cursor next_action_id is
      select pay_assignment_actions_s.nextval
      from   dual;

    cursor process_assignments
      (c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
       c_start_person_id    in per_all_people_f.person_id%type,
       c_end_person_id      in per_all_people_f.person_id%type,
       c_type               in ff_database_items.user_name%type) is
    select distinct a.assignment_id,
           pay_core_utils.get_parameter('ARCHIVE_RUN_ID', pa.legislative_parameters) archive_run_id,
           pay_core_utils.get_parameter('LEGAL_ENTITY_ID', pa.legislative_parameters) legal_entity_id
    from   per_assignments_f a,   /* Bug# 2920732 */
           per_people_f p,
           pay_payroll_actions pa
    where  pa.payroll_action_id = c_payroll_action_id
    and    p.person_id    between c_start_person_id and c_end_person_id
    and    p.person_id          = a.person_id
    and    p.business_group_id  = pa.business_group_id
    and    exists /* Bug No : 2242653 */
           (select null
            from
                   pay_payroll_actions ppa,
                   pay_assignment_actions pac
            where  ppa.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_RUN_ID', pa.legislative_parameters)
            and    ppa.action_type = 'X'
            and    ppa.action_status = 'C'
            and    ppa.payroll_action_id = pac.payroll_action_id
            and    pac.assignment_id = a.assignment_id
           )
    and    ((g_report_type = 'O' and not exists/*Bug:2858063*/
           (
	        select pai.locking_action_id
		from
		pay_action_interlocks pai,
		pay_assignment_actions paa1,--assignment action id of the action that locks archive
		pay_assignment_actions paa2, -- assignment action id of the magtape
		pay_payroll_actions ppa1, -- payroll action id of the process that locks archive
		pay_payroll_actions ppa2 -- payroll action id of the magtape process
		where pai.locked_action_id = paa1.assignment_action_id -- archive is locked
		and  pai.locking_action_id = paa2.assignment_action_id -- mgtape is looking the archive
		and  paa1.assignment_id = paa2.assignment_id
		and  paa1.assignment_id = a.assignment_id
		and  ppa1.action_type = 'X'
		and  ppa1.action_status = 'C'
		and  ppa1.report_type = 'SG_IRAS_ARCHIVE'
		and  ppa2.action_type = 'X'
		and  ppa2.action_status = 'C'
		and  ppa2.report_type = pa.report_type /* Bug#2833530 */
        and  pay_core_utils.get_parameter('LEGAL_ENTITY_ID', pa.legislative_parameters) = pay_core_utils.get_parameter('LEGAL_ENTITY_ID', ppa2.legislative_parameters) /* Bug 8240839 */
   		and  ppa1.payroll_action_id = paa1.payroll_action_id
		and  ppa2.payroll_action_id = paa2.payroll_action_id
                and  ppa2.report_qualifier='SG'
                and  to_char(ppa2.effective_date, 'YYYY') =
                     (
                      select
                         pay_core_utils.get_parameter('BASIS_YEAR', ppa_arch.legislative_parameters)
                      from
                         pay_payroll_actions ppa_arch
                      where
                         ppa_arch.payroll_action_id =
                              pay_core_utils.get_parameter('ARCHIVE_RUN_ID', pa.legislative_parameters)
                     )   /* Bug#4888368 */
           ))
       or (g_report_type='A' AND exists (select '' from
           pay_assignment_actions aacs,
           pay_payroll_Actions ppas,
       ff_archive_items    ffis,
           ff_database_items  fdis
       where ffis.context1        = aacs.assignment_action_id
           and a.assignment_id = aacs.assignment_id
       and aacs.payroll_action_id = ppas.payroll_action_id
    and    fdis.user_name         = c_type
    AND    ffis.VALUE = 'Y'
    and ppas.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_RUN_ID', pa.legislative_parameters)
            and    ppas.action_type = 'X'
            and    ppas.action_status = 'C'
    and    ffis.user_entity_id    = fdis.user_entity_id )))
    and    not exists
           (select null
            from   per_people_extra_info pei
            where  pei.person_id = p.person_id
            and    pei.pei_information1 is not null
            and    pei.information_type = 'HR_IR21_PROCESSING_DATES_SG');

    cursor locked_action
      (c_payroll_action_id  pay_assignment_actions.payroll_action_id%type,
       c_assignment_id      pay_assignment_actions.assignment_id%type) is
      select pac.assignment_action_id
      from   pay_assignment_actions pac
      where  pac.assignment_id = c_assignment_id
      and    pac.payroll_action_id = c_payroll_action_id;

  begin
    hr_utility.set_location('Start of assignment_action_code',3);

    initialization_code(p_payroll_action_id);

    select decode(g_file,'IR8A', 'X_IR8A_AMEND_INDICATOR','IR8S', 'X_IR8S_AMEND_INDICATOR','A8A','X_A8A_AMEND_INDICATOR','A8B','X_A8B_AMEND_INDICATOR')
    into v_type from dual;

    for process_rec in process_assignments (p_payroll_action_id,
                                            p_start_person_id,
                                            p_end_person_id,
                                            v_type) loop
      open next_action_id;
      fetch next_action_id into v_next_action_id;
      close next_action_id;

      hr_utility.set_location('Before calling hr_nonrun_asact.insact',4);

      pay_balance_pkg.set_context('TAX_UNIT_ID',process_rec.legal_entity_id);
      pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',v_next_action_id);

      hr_nonrun_asact.insact(v_next_action_id,             -- lockingactid
                             process_rec.assignment_id,    -- assignid
                             p_payroll_action_id,          -- pactid
                             p_chunk,                      -- chunk
                             process_rec.legal_entity_id); -- greid

      open locked_action (process_rec.archive_run_id, process_rec.assignment_id);
      fetch locked_action into v_archive_action_id;
      if locked_action%found then
        close locked_action;
        hr_nonrun_asact.insint(v_next_action_id,     -- locking action id
                               v_archive_action_id); -- locked action id
      else
        close locked_action;
      end if;
      hr_utility.set_location('After calling hr_nonrun_asact.insact',4);

    end loop;

   hr_utility.set_location('End of assignment_action_code',5);
  end assignment_action_code;
  ------------------------------------------------------------------------
  -- This is used by legislation groups to set global contexts that are
  -- required for the lifetime of the archiving process. This is null
  -- because there are no setup requirements, but a procedure needs to
  -- exist in pay_report_format_mappings_f, otherwise the archiver will
  -- assume that no archival of data is required.
  ------------------------------------------------------------------------
  procedure initialization_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type) is
  begin
    hr_utility.set_location('Start of initialization_code',6);
    get_parameters(p_payroll_action_id,'REP_TYPE',g_report_type);
    get_parameters(p_payroll_action_id,'FILE',g_file);
    hr_utility.set_location('End of initialization_code',7);
  end initialization_code;
  ------------------------------------------------------------------------
  -- Used to actually perform the archival of data.  We are not archiving
  -- any data here, so this is null.
  ------------------------------------------------------------------------
  procedure archive_code
    (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
     p_effective_date        in date) is

  begin
    hr_utility.set_location('Start of archive_code',8);
    null;
    hr_utility.set_location('End of archive_code',9);
  end archive_code;

end pay_sg_iras_magtape;

/
