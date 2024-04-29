--------------------------------------------------------
--  DDL for Package Body PAY_VOID_PAYMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_VOID_PAYMENTS" AS
-- $Header: pyvoidpy.pkb 120.0 2005/05/29 10:15:58 appldev noship $
--
--==============================================================================
-- VOID_PAYMENTS
--
--
--==============================================================================
PROCEDURE void_run (p_errmsg            OUT NOCOPY VARCHAR2,
                    p_errcode           OUT NOCOPY NUMBER,
                    p_payroll_action_id NUMBER,
                    p_effective_date    VARCHAR2,
                    p_reason            VARCHAR2,
                    p_start_cheque      NUMBER default null,
                    p_end_cheque        NUMBER default null,
                    p_start_assignment  NUMBER default null,
                    p_end_assignment    NUMBER default null
                    ) IS

  l_effective_date  DATE;
--
     l_start_cheque       number;
     l_end_cheque         number;
     l_start_assignment   number;
     l_end_assignment     number;
--
  CURSOR overlap_csr IS
    SELECT void_pa.effective_date,
           fnd_number.canonical_to_number(chq_or_mag_aa.serial_number) cheque_number,
           chq_or_mag_aa.assignment_action_id
      FROM pay_assignment_actions chq_or_mag_aa,
           pay_action_interlocks,
           pay_assignment_actions void_aa,
           pay_payroll_actions    void_pa
      WHERE chq_or_mag_aa.payroll_action_id = p_payroll_action_id
        AND ((l_start_cheque is not null
              AND l_end_cheque is not null
              AND fnd_number.canonical_to_number(chq_or_mag_aa.serial_number)
                   BETWEEN l_start_cheque AND l_end_cheque)
             OR (l_start_cheque is null and l_start_cheque is null))
        AND ((l_start_assignment is not null
              AND l_end_assignment is not null
              AND chq_or_mag_aa.assignment_action_id
                   BETWEEN l_start_assignment AND l_end_assignment)
              OR (l_start_assignment is null and l_end_assignment is null))
        AND locked_action_id = chq_or_mag_aa.assignment_action_id
        AND locking_action_id = void_aa.assignment_action_id
        AND void_pa.payroll_action_id = void_aa.payroll_action_id
        AND void_pa.action_type = 'D';
--
  CURSOR void_csr IS
    SELECT act.assignment_action_id,
           act.assignment_id,
           fnd_number.canonical_to_number(act.serial_number) cheque_number,
           act.object_version_number,
           act.action_status,
           act.tax_unit_id,
           -- nvl((select distinct 'Y'
           --       from pay_ce_reconciled_payments prp
           --      where prp.assignment_action_id = act.assignment_action_id)
           --    ,'N') recon_exists,
           nvl(pos.final_process_date, hr_general.end_of_time) final_process_date
      FROM pay_assignment_actions act,
           per_assignments_f asg,
           per_periods_of_service pos
      WHERE act.payroll_action_id = p_payroll_action_id
        AND ((l_start_assignment is null and l_end_assignment is null)
              OR
             (l_start_assignment is not null
              and l_end_assignment is not null
              and act.assignment_action_id between
                        l_start_assignment and l_end_assignment))
        AND ((l_start_cheque is not null
             and l_end_cheque is not null
             and fnd_number.canonical_to_number(act.serial_number)
                   BETWEEN l_start_cheque AND l_end_cheque)
             or
             (l_start_cheque is null and l_end_cheque is null))
        AND act.assignment_id = asg.assignment_id
        AND pos.period_of_service_id = asg.period_of_service_id
        AND l_effective_date BETWEEN asg.effective_start_date
                     AND asg.effective_end_date ;
--
  CURSOR csr_payment_reconciled (v_asg_act_id number) IS
    SELECT 'Y'
      FROM pay_ce_reconciled_payments prp
     WHERE prp.assignment_action_id = v_asg_act_id;
  --
  l_dummy varchar2(1);
--
  overlap_row     overlap_csr%ROWTYPE;
  void_row        void_csr%ROWTYPE;
  bgid            pay_payroll_actions.business_group_id%TYPE;
  csid            pay_payroll_actions.consolidation_set_id%TYPE;
  pid             pay_payroll_actions.payroll_id%TYPE;
  ovn             pay_payroll_actions.object_version_number%TYPE;
  action_type     pay_payroll_actions.action_type%TYPE;
BEGIN
  hr_utility.set_location ('void_run',1);
--------------------------------------------------------------------------------
-- Convert date. NB: This will have to change to generic data format in 10.7
--------------------------------------------------------------------------------
  l_effective_date := trunc(fnd_date.canonical_to_date (p_effective_date));
--
  if p_start_assignment is not null then
     l_start_cheque := null;
     l_end_cheque := null;
     l_start_assignment := p_start_assignment;
     l_end_assignment := p_end_assignment;
  else
     l_start_assignment := null;
     l_end_assignment := null;
     l_start_cheque := p_start_cheque;
     l_end_cheque := p_end_cheque;
  end if;
--
  hr_utility.set_location ('void_run',2);
--------------------------------------------------------------------------------
-- Get template information from source payroll action
--------------------------------------------------------------------------------
  SELECT business_group_id,
         consolidation_set_id,
         payroll_id,
         object_version_number,
         action_type
    INTO bgid,csid,pid,ovn,action_type
    FROM pay_payroll_actions
    WHERE payroll_action_id = p_payroll_action_id;
--------------------------------------------------------------------------------
-- For chequewriter : Check there is no overlap with another void run
--------------------------------------------------------------------------------
   OPEN overlap_csr;
   FETCH overlap_csr INTO overlap_row;
--
   hr_utility.set_location ('void_run',3);
--
   IF overlap_csr%FOUND THEN
     hr_utility.set_location ('void_run',31);
     IF action_type = 'H' THEN
       p_errmsg := 'Overlap detected. Cheque #' || overlap_row.cheque_number ||
                   ' already voided in run performed on ' ||
                   fnd_date.date_to_canonical(overlap_row.effective_date);
       p_errcode := 2; -- Error
     ELSIF action_type = 'M' THEN
       p_errmsg := 'Overlap detected. MagTape Assignment Action #' ||
                   overlap_row.assignment_action_id ||
                   ' already voided in run performed on ' ||
                   fnd_date.date_to_canonical(overlap_row.effective_date);
       p_errcode := 2; -- Error
     END IF;
       RETURN;
   END IF;
--
  hr_utility.set_location ('void_run',4);
  CLOSE overlap_csr;
--
  hr_utility.set_location ('void_run',5);
--------------------------------------------------------------------------------
-- Create new payroll action for void run
--------------------------------------------------------------------------------
  INSERT INTO pay_payroll_actions
    ( payroll_action_id,
      action_type,
      business_group_id,
      consolidation_set_id,
      payroll_id,
      target_payroll_action_id,
      action_population_status,
      action_status,
      effective_date,
      comments,
      start_cheque_number,
      end_cheque_number,
      request_id,
      object_version_number ) VALUES
    ( pay_payroll_actions_s.nextval,  -- payroll_action_id
      'D',                            -- action_type
      bgid,                           -- business_group_id
      csid,                           -- consolidation_set_id
      pid,                            -- payroll_id
      p_payroll_action_id,            -- target_payroll_action_id
      'C',                            -- action_population_status
      'C',                            -- action_status
      l_effective_date,               -- effective_date
      p_reason,                       -- comments
      l_start_cheque,                 -- start_cheque_number
      l_end_cheque,                   -- end_cheque_number
      fnd_profile.value('REQUEST_ID'),-- request_id
      ovn );                          -- object_version_number
--
  hr_utility.set_location ('void_run',6);
--------------------------------------------------------------------------------
-- Loop through assignment actions
--------------------------------------------------------------------------------
  FOR void_row IN void_csr LOOP
    hr_utility.set_location ('void_run',61);
    IF action_type = 'H' THEN
--------------------------------------------------------------------------------
-- Check the cheque is complete
--------------------------------------------------------------------------------
      IF void_row.action_status NOT IN ('C', 'S') THEN
        p_errmsg := 'Cheque #' || void_row.cheque_number || ' status is ' ||
                    void_row.action_status;
        p_errcode := 2; -- Error
        RETURN;
      END IF;
--
      hr_utility.set_location ('void_run',62);
--------------------------------------------------------------------------------
-- Check whether the cheque is reconcilled.
--------------------------------------------------------------------------------
      open csr_payment_reconciled(void_row.assignment_action_id);
      fetch csr_payment_reconciled into l_dummy;
      IF csr_payment_reconciled%found THEN
        close csr_payment_reconciled;
        p_errmsg := 'Cheque #' || void_row.cheque_number || ' is reconcilled.';
        p_errcode := 2; -- Error
        RETURN;
      END IF;
      close csr_payment_reconciled;
--
    END IF;
    hr_utility.set_location ('void_run',63);
--------------------------------------------------------------------------------
-- Create new assignment action for void
--------------------------------------------------------------------------------
    INSERT INTO pay_assignment_actions
      ( assignment_action_id,
        assignment_id,
        payroll_action_id,
        action_status,
        serial_number,
        object_version_number,
        action_sequence,
        tax_unit_id ) VALUES
      ( pay_assignment_actions_s.nextval,   -- assignment_action_id
        void_row.assignment_id,           -- assignment_id
        pay_payroll_actions_s.currval,      -- payroll_action_id
        'C',                                -- action_status
        void_row.cheque_number,           -- serial_number
        void_row.object_version_number,   -- object_version_number
        pay_assignment_actions_s.nextval,
        void_row.tax_unit_id ); -- action_sequence
--
    hr_utility.set_location ('void_run',63);
--------------------------------------------------------------------------------
-- Create interlock from void aa to cheque aa
--------------------------------------------------------------------------------
    INSERT INTO pay_action_interlocks
      ( locking_action_id, locked_action_id )
    VALUES
      ( pay_assignment_actions_s.currval,void_row.assignment_action_id );
--
    hr_utility.set_location ('void_run',64);
  END LOOP;
--
  hr_utility.set_location ('void_run',7);
  COMMIT;
END void_run;
--
END pay_void_payments;

/
