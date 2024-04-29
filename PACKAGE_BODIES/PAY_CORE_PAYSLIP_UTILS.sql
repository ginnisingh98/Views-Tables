--------------------------------------------------------
--  DDL for Package Body PAY_CORE_PAYSLIP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CORE_PAYSLIP_UTILS" AS
/* $Header: pycopysl.pkb 115.0 2004/04/02 01:45:38 tbattoo noship $ */


g_package                CONSTANT VARCHAR2(30) := 'pay_core_payslip_utils.';

PROCEDURE get_parameters(p_payroll_action_id IN  NUMBER,
                         p_token_name        IN  VARCHAR2,
                         p_token_value       OUT  NOCOPY VARCHAR2) IS

CURSOR csr_parameter_info(p_pact_id NUMBER,
                          p_token   CHAR) IS
SELECT SUBSTR(legislative_parameters,
               INSTR(legislative_parameters,p_token)+(LENGTH(p_token)+1),
                INSTR(legislative_parameters,' ',
                       INSTR(legislative_parameters,p_token))
                 - (INSTR(legislative_parameters,p_token)+LENGTH(p_token))),
       business_group_id
FROM   pay_payroll_actions
WHERE  payroll_action_id = p_pact_id;

l_business_group_id               VARCHAR2(20);
l_token_value                     VARCHAR2(50);

l_proc                            VARCHAR2(50) := g_package || 'get_parameters';

BEGIN

  hr_utility.set_location('Entering ' || l_proc,10);

  hr_utility.set_location('Step ' || l_proc,20);
  hr_utility.set_location('p_token_name = ' || p_token_name,20);

  OPEN csr_parameter_info(p_payroll_action_id,
                          p_token_name);

  FETCH csr_parameter_info INTO l_token_value,
                                l_business_group_id;

  CLOSE csr_parameter_info;

  IF p_token_name = 'BG_ID'

  THEN

     p_token_value := l_business_group_id;

  ELSE

     p_token_value := l_token_value;

  END IF;

  hr_utility.set_location('l_token_value = ' || l_token_value,20);
  hr_utility.set_location('Leaving         ' || l_proc,30);

END get_parameters;

/*
    Name: range_cursor
    Desrciption:
          This code returns the select statement that
          should be used to generate the ranges.
*/
PROCEDURE range_cursor (pactid IN NUMBER,
                        sqlstr OUT  NOCOPY VARCHAR2)
-- public procedure which archives the payroll information, then returns a
-- varchar2 defining a SQL statement to select all the people that may be
-- eligible for payslip reports.
-- The archiver uses this cursor to split the people into chunks for parallel
-- processing.
IS
  --
  l_proc    CONSTANT VARCHAR2(50):= g_package||'range_cursor';
  -- vars for constructing the sqlstr
BEGIN

  hr_utility.set_location('Entering ' || l_proc,10);

  sqlstr := 'SELECT DISTINCT person_id
             FROM   per_people_f ppf,
                    pay_payroll_actions ppa
             WHERE  ppa.payroll_action_id = :payroll_action_id
             AND    ppa.business_group_id +0 = ppf.business_group_id
             ORDER BY ppf.person_id';

  hr_utility.set_location('Leaving ' || l_proc,40);

END range_cursor;

/*
    Name: action_creation
    Desrciption:
          This code should be used to generate the
          master assignment actions for the
          payslip archive.
*/
PROCEDURE action_creation (pactid in number,
                           stperson in number,
                           endperson in number,
                           chunk in number,
                           p_report_type in varchar2,
                           p_report_qualifier in varchar2) is
--
CURSOR csr_prepaid_assignments(p_pact_id          NUMBER,
                               stperson           NUMBER,
                               endperson          NUMBER,
                               p_payroll_id       NUMBER,
                               p_consolidation_id NUMBER,
                               p_report_type      VARCHAR2,
                               p_report_qualifier VARCHAR2) IS
SELECT act.assignment_id assignment_id,
       act.assignment_action_id run_action_id,
       act1.assignment_action_id prepaid_action_id
FROM   pay_payroll_actions ppa,
       pay_payroll_actions appa,
       pay_payroll_actions appa2,
       pay_assignment_actions act,
       pay_assignment_actions act1,
       pay_action_interlocks pai,
       per_all_assignments_f as1
WHERE  ppa.payroll_action_id = p_pact_id
AND    appa2.consolidation_set_id = p_consolidation_id
AND    appa2.effective_date BETWEEN
         ppa.start_date AND ppa.effective_date
AND    as1.person_id BETWEEN
         stperson AND endperson
AND    appa.action_type IN ('R','Q')                             -- Payroll Run or Quickpay Run
AND    act.payroll_action_id = appa.payroll_action_id
AND    act.source_action_id IS NULL
AND    as1.assignment_id = act1.assignment_id
AND    ppa.effective_date BETWEEN
         as1.effective_start_date AND as1.effective_end_date
AND    act.action_status = 'C'
AND    act.assignment_action_id = pai.locked_action_id
AND    act1.assignment_action_id = pai.locking_action_id
AND    act1.action_status = 'C'
AND    act1.payroll_action_id = appa2.payroll_action_id
AND    appa2.action_type IN ('P','U')                            -- Prepayments or Quickpay Prepayments
AND    (as1.payroll_id = p_payroll_id OR p_payroll_id IS NULL)
AND    NOT EXISTS (SELECT /*+ ORDERED */ NULL
                   FROM   pay_action_interlocks pai1,
                          pay_assignment_actions act2,
                          pay_payroll_actions appa3
                   WHERE  pai1.locked_action_id = act.assignment_action_id
                   AND    act2.assignment_action_id = pai1.locking_action_id
                   AND    act2.payroll_action_id = appa3.payroll_action_id
                   AND    appa3.action_type = 'X'
                   AND    appa3.report_type = p_report_type
                   AND    appa3.report_qualifier = p_report_qualifier)
ORDER BY act.assignment_id, act.assignment_action_id
FOR UPDATE OF as1.assignment_id;

l_actid                           NUMBER;
l_canonical_end_date              DATE;
l_canonical_start_date            DATE;
l_consolidation_set               VARCHAR2(30);
l_end_date                        VARCHAR2(20);
l_payroll_id                      NUMBER;
l_prepay_action_id                NUMBER;
l_start_date                      VARCHAR2(20);

l_proc VARCHAR2(50) := g_package||'action_creation';

BEGIN

  hr_utility.set_location('Entering ' || l_proc,10);

  get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'PAYROLL'
  , p_token_value       => l_payroll_id);

  get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'CONSOLIDATION'
  , p_token_value       => l_consolidation_set);

  get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'START_DATE'
  , p_token_value       => l_start_date);

  get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'END_DATE'
  , p_token_value       => l_end_date);

  hr_utility.set_location('Step ' || l_proc,20);
  hr_utility.set_location('l_payroll_id = ' || l_payroll_id,20);
  hr_utility.set_location('l_start_date = ' || l_start_date,20);
  hr_utility.set_location('l_end_date   = ' || l_end_date,20);

  l_canonical_start_date := TO_DATE(l_start_date,'yyyy/mm/dd');
  l_canonical_end_date   := TO_DATE(l_end_date,'yyyy/mm/dd');

  l_prepay_action_id := 0;

  FOR csr_rec IN csr_prepaid_assignments(pactid,
                                         stperson,
                                         endperson,
                                         l_payroll_id,
                                         l_consolidation_set,
                                         p_report_type,
                                         p_report_qualifier)

  LOOP

    IF l_prepay_action_id <> csr_rec.prepaid_action_id

    THEN

    SELECT pay_assignment_actions_s.NEXTVAL
    INTO   l_actid
    FROM   dual;

    -- CREATE THE ARCHIVE ASSIGNMENT ACTION FOR THE MASTER ASSIGNMENT ACTION

    hr_nonrun_asact.insact(l_actid,csr_rec.assignment_id,pactid,chunk,NULL);

    -- CREATE THE ARCHIVE TO PAYROLL MASTER ASSIGNMENT ACTION INTERLOCK AND
    -- THE ARCHIVE TO PREPAYMENT ASSIGNMENT ACTION INTERLOCK

    hr_utility.set_location('creating lock1 ' || l_actid || ' to ' || csr_rec.run_action_id,20);
    hr_utility.set_location('creating lock2 ' || l_actid || ' to ' || csr_rec.prepaid_action_id,20);

    hr_nonrun_asact.insint(l_actid,csr_rec.prepaid_action_id);

    END IF;

    hr_nonrun_asact.insint(l_actid,csr_rec.run_action_id);

    l_prepay_action_id := csr_rec.prepaid_action_id;

  END LOOP;

  hr_utility.set_location('Leaving ' || l_proc,20);

END action_creation;

function get_max_nor_act_seq(p_payroll_action_id    in number,
                             p_assignment_action_id in number,
                             p_effective_date       in date)
return number
is
l_run_type_id pay_payroll_actions.run_type_id%type;
l_act_seq     pay_assignment_actions.action_sequence%type;
begin
--
   select run_type_id
     into l_run_type_id
     from pay_payroll_actions
    where payroll_action_id = p_payroll_action_id;
--
   /* If the run type id is null then run
      types are not being used
   */
   if (l_run_type_id is null) then
     select action_sequence
       into l_act_seq
       from pay_assignment_actions
      where assignment_action_id = p_assignment_action_id;
   else
      SELECT MAX(paa1.action_sequence)
        into l_act_seq
        FROM   pay_assignment_actions paa1,
               pay_assignment_actions paa2,
               pay_run_types_f prt1
       WHERE  prt1.run_type_id = paa1.run_type_id
       AND    prt1.run_method IN ('N','P')
       AND    paa1.payroll_action_id = p_payroll_action_id
       AND    paa1.assignment_id = paa2.assignment_id
       AND    paa1.source_action_id = paa2.assignment_action_id
       AND    paa2.assignment_action_id = p_assignment_action_id
       AND    p_effective_date BETWEEN
                prt1.effective_start_date AND prt1.effective_end_date;
   end if;
--
   return l_act_seq;
--
end get_max_nor_act_seq;
/*
    Name: generate_child_actions
    Desrciption:
        This procedure should be the first procedure called
        from the payslip archive archive_code section.

        The procedure generates the child assignment actions
        it is these that determine the number of payslips
        to archive
*/
PROCEDURE generate_child_actions(p_assactid       in number,
                                 p_effective_date in date) IS

CURSOR csr_assignment_actions(p_locking_action_id NUMBER) IS
SELECT pre.locked_action_id      pre_assignment_action_id,
       pay.locked_action_id      master_assignment_action_id,
       assact.assignment_id      assignment_id,
       assact.payroll_action_id  pay_payroll_action_id,
       paa.effective_date        effective_date,
       ppaa.effective_date       pre_effective_date,
       paa.date_earned           date_earned,
       paa.time_period_id        time_period_id
FROM   pay_action_interlocks pre,
       pay_action_interlocks pay,
       pay_payroll_actions paa,
       pay_payroll_actions ppaa,
       pay_assignment_actions assact,
       pay_assignment_actions passact
WHERE  pre.locked_action_id = pay.locking_action_id
AND    pre.locking_action_id = p_locking_action_id
AND    pre.locked_action_id = passact.assignment_action_id
AND    passact.payroll_action_id = ppaa.payroll_action_id
AND    ppaa.action_type IN ('P','U')
AND    pay.locked_action_id = assact.assignment_action_id
AND    assact.payroll_action_id = paa.payroll_action_id
AND    assact.source_action_id IS NULL
ORDER BY pay.locked_action_id;

CURSOR csr_child_actions(p_master_assignment_action NUMBER,
                         p_payroll_action_id        NUMBER,
                         p_assignment_id            NUMBER,
                         p_effective_date           DATE  ) IS
SELECT paa.assignment_action_id child_assignment_action_id,
       'S' run_type
FROM   pay_assignment_actions paa,
       pay_run_types_f prt
WHERE  paa.source_action_id = p_master_assignment_action
AND    paa.payroll_action_id = p_payroll_action_id
AND    paa.assignment_id = p_assignment_id
AND    paa.run_type_id = prt.run_type_id
AND    prt.run_method = 'S'
AND    p_effective_date BETWEEN
         prt.effective_start_date AND prt.effective_end_date
UNION
SELECT paa.assignment_action_id child_assignment_action_id,
       'NP' run_type
FROM   pay_assignment_actions paa
WHERE  paa.payroll_action_id = p_payroll_action_id
AND    paa.assignment_id = p_assignment_id
AND    paa.action_sequence =
         pay_core_payslip_utils.get_max_nor_act_seq(p_payroll_action_id,
                             p_master_assignment_action,
                             p_effective_date);

CURSOR csr_np_children (p_assignment_action_id NUMBER,
                        p_payroll_action_id    NUMBER,
                        p_assignment_id        NUMBER,
                        p_effective_date       DATE) IS
SELECT paa.assignment_action_id np_assignment_action_id,
       prt.run_method
FROM   pay_assignment_actions paa,
       pay_run_types_f prt
WHERE  paa.source_action_id = p_assignment_action_id
AND    paa.payroll_action_id = p_payroll_action_id
AND    paa.assignment_id = p_assignment_id
AND    paa.run_type_id = prt.run_type_id
AND    prt.run_method IN ('N','P')
AND    p_effective_date BETWEEN
         prt.effective_start_date AND prt.effective_end_date
UNION
SELECT paa.assignment_action_id np_assignment_action_id,
       'N'
FROM   pay_assignment_actions paa,
       pay_payroll_actions ppa
WHERE  paa.assignment_action_id = p_assignment_action_id
AND    ppa.payroll_action_id = p_payroll_action_id
AND    ppa.payroll_action_id = paa.payroll_action_id
AND    ppa.run_type_id is null
AND    paa.assignment_id = p_assignment_id;

l_actid                           NUMBER;
l_action_context_id               NUMBER;
l_action_info_id                  NUMBER(15);
l_assignment_action_id            NUMBER;
l_business_group_id               NUMBER;
l_chunk_number                    NUMBER;
l_date_earned                     DATE;
l_ovn                             NUMBER;
l_person_id                       NUMBER;
l_salary                          VARCHAR2(10);
l_sequence                        NUMBER;

l_proc                            VARCHAR2(50) := g_package || 'archive_code';

l_standard_asg_act_id       pay_assignment_actions.assignment_action_id%type;
l_pactid                    pay_assignment_actions.payroll_action_id%type;

BEGIN

  hr_utility.set_location('Entering '|| l_proc,10);

  hr_utility.set_location('Step '|| l_proc,20);
  hr_utility.set_location('p_assactid = ' || p_assactid,20);

  -- retrieve the chunk number for the current assignment action

  SELECT paa.chunk_number,
         paa.payroll_action_id
  INTO   l_chunk_number,
         l_pactid
  FROM   pay_assignment_actions paa
  WHERE  paa.assignment_action_id = p_assactid;

  l_standard_asg_act_id := null;

  -- Select all the master run actions.
  FOR csr_rec IN csr_assignment_actions(p_assactid)

  LOOP

    hr_utility.set_location('csr_rec.master_assignment_action_id = ' ||
                          csr_rec.master_assignment_action_id,20);
    hr_utility.set_location('csr_rec.pre_assignment_action_id    = ' ||
                          csr_rec.pre_assignment_action_id,20);
    hr_utility.set_location('csr_rec.assignment_id    = ' ||
                          csr_rec.assignment_id,20);
    hr_utility.set_location('csr_rec.date_earned    = ' ||
                          to_char( csr_rec.date_earned,'dd-mon-yyyy'),20);
    hr_utility.set_location('csr_rec.pre_effective_date    = '
                     ||to_char( csr_rec.pre_effective_date,'dd-mon-yyyy'),20);
    hr_utility.set_location('csr_rec.time_period_id    = ' ||
                      csr_rec.time_period_id,20);

  -- Select all the child actions
  FOR csr_child_rec IN csr_child_actions(csr_rec.master_assignment_action_id,
                                         csr_rec.pay_payroll_action_id,
                                         csr_rec.assignment_id,
                                         csr_rec.effective_date)

    LOOP

    -- create additional archive assignment actions and interlocks

      IF csr_child_rec.run_type = 'S'

      THEN

         SELECT pay_assignment_actions_s.NEXTVAL
         INTO   l_actid
         FROM dual;

         hr_utility.set_location('csr_child_rec.run_type              = ' ||
                                  csr_child_rec.run_type,30);
         hr_utility.set_location('csr_rec.master_assignment_action_id = ' ||
                                  csr_rec.master_assignment_action_id,30);

         hr_nonrun_asact.insact(
           lockingactid => l_actid
         , assignid     => csr_rec.assignment_id
         , pactid       => l_pactid
         , chunk        => l_chunk_number
         , greid        => NULL
         , prepayid     => NULL
         , status       => 'C'
         , source_act   => p_assactid);

        hr_utility.set_location('creating lock3 ' ||
              l_actid || ' to ' ||
                     csr_child_rec.child_assignment_action_id,30);

        hr_nonrun_asact.insint(
          lockingactid => l_actid
        , lockedactid  => csr_child_rec.child_assignment_action_id);

        l_action_context_id := l_actid;

      END IF;

      IF csr_child_rec.run_type = 'NP'

      THEN

        if (l_standard_asg_act_id is null) then
--
          SELECT pay_assignment_actions_s.NEXTVAL
          INTO   l_actid
          FROM dual;

          hr_utility.set_location('csr_child_rec.run_type              = ' ||
                                   csr_child_rec.run_type,30);
          hr_utility.set_location('csr_rec.master_assignment_action_id = ' ||
                                   csr_rec.master_assignment_action_id,30);

           hr_nonrun_asact.insact(
             lockingactid => l_actid
           , assignid     => csr_rec.assignment_id
           , pactid       => l_pactid
           , chunk        => l_chunk_number
           , greid        => NULL
           , prepayid     => NULL
           , status       => 'C'
           , source_act   => p_assactid);
--
           l_standard_asg_act_id := l_actid;
--
        else
--
           l_actid := l_standard_asg_act_id;
--
        end if;
--
        FOR csr_np_rec IN csr_np_children(csr_rec.master_assignment_action_id,
                                          csr_rec.pay_payroll_action_id,
                                          csr_rec.assignment_id,
                                          csr_rec.effective_date)

        LOOP

          hr_utility.set_location('creating lock4 ' ||
               l_actid || ' to ' || csr_np_rec.np_assignment_action_id,30);

          hr_nonrun_asact.insint(
            lockingactid => l_actid
          , lockedactid  => csr_np_rec.np_assignment_action_id);

        END LOOP;

      END IF;

    END LOOP; -- child assignment actions


  END LOOP;
  hr_utility.set_location('Leaving '|| l_proc,80);

END generate_child_actions;

END pay_core_payslip_utils;

/
