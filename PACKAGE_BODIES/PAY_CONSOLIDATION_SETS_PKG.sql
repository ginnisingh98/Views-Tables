--------------------------------------------------------
--  DDL for Package Body PAY_CONSOLIDATION_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CONSOLIDATION_SETS_PKG" as
/* $Header: pycss01t.pkb 115.1 99/07/17 05:55:49 porting ship  $ */
--
procedure get_next_sequence(p_consolidation_set_id in out number) is
--
cursor c1 is select pay_consolidation_sets_s.nextval
	     from sys.dual;
--
begin
  --
  -- Retrieve the next sequence number for consolidation_set_id
  --
  if (p_consolidation_set_id is null) then
     open c1;
     fetch c1 into p_consolidation_set_id;
     if (C1%NOTFOUND) then
        hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE','get_next_sequence');
     end if;
     close c1;
  end if;
  --
  hr_utility.set_location('PER_JOBS_PKG.get_next_sequence', 1);
  --
end get_next_sequence;
--
PROCEDURE check_unique_name(p_consolidation_set_name    in varchar2,
			    p_business_group_id         in number,
			    p_rowid                     in varchar2) is
--
cursor csr_name is select null
		   from pay_consolidation_sets cs
		   WHERE  UPPER(CS.CONSOLIDATION_SET_NAME) =
			     UPPER(P_CONSOLIDATION_SET_NAME)
	           AND    CS.business_group_id + 0 =
		       	     P_BUSINESS_GROUP_ID
		   AND    (P_ROWID IS NULL
		   OR     (P_ROWID IS NOT NULL AND
			     P_ROWID <> rowidtochar(CS.ROWID)));
g_dummy_number number;
consolidation_exists boolean := FALSE;
--
-- Check the consolidation name is unique
--
begin
  --
  open csr_name;
  fetch csr_name into g_dummy_number;
  consolidation_exists := csr_name%FOUND;
  close csr_name;
  if consolidation_exists then
    hr_utility.set_message (801,'HR_6395_SETUP_SET_EXISTS');
    hr_utility.raise_error;
  end if;
--
end check_unique_name;
--
procedure check_delete(p_business_group_id    in number,
		       p_consolidation_set_id in number) is
--
cursor csr_pay is select null
                  FROM PAY_PAYROLLS_F PAY
                  WHERE PAY.business_group_id + 0  = P_BUSINESS_GROUP_ID
                  AND PAY.CONSOLIDATION_SET_ID = P_CONSOLIDATION_SET_ID;
--
cursor csr_payact is select null
                     FROM PAY_PAYROLL_ACTIONS PAC
                     WHERE PAC.business_group_id + 0  = P_BUSINESS_GROUP_ID
                     AND PAC.CONSOLIDATION_SET_ID = P_CONSOLIDATION_SET_ID;
--
g_dummy_number number;
payroll_exists boolean := FALSE;
pay_action_exists boolean := FALSE;
--
-- Check the consolidation set is not the default set for a payroll
-- or is associated with at least one payroll action
--
begin
  --
  open csr_pay;
  fetch csr_pay into g_dummy_number;
  payroll_exists := csr_pay%FOUND;
  close csr_pay;
  --
  if payroll_exists then
    hr_utility.set_message (801,'HR_6396_SETUP_SET_FOR_PAYROLL');
    hr_utility.raise_error;
  end if;
  --
  open csr_payact;
  fetch csr_payact into g_dummy_number;
  pay_action_exists := csr_payact%FOUND;
  close csr_payact;
  --
  if pay_action_exists then
    hr_utility.set_message (801,'HR_6397_SETUP_SET_ACTION_EXIST');
    hr_utility.raise_error;
  end if;
  --
end check_delete;
--
END PAY_CONSOLIDATION_SETS_PKG;

/
