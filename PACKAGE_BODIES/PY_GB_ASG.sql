--------------------------------------------------------
--  DDL for Package Body PY_GB_ASG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_GB_ASG" as
/* $Header: pygbasg.pkb 120.1 2005/06/30 06:43:13 tukumar noship $ */

PROCEDURE payroll_transfer (p_assignment_id  IN NUMBER) is
-- if an assignment transfers from one payroll to another then the
-- assignment latest balances must be deleted. Also, the person
-- latest balances must be deleted for the person who owns this
-- assignment. This is called from perwsema_leg.payroll_transfer.
--
-- Use sysdate to get single datetrack row.
cursor csr_person_details (c_assignment_id in number) is
   select person_id
   from per_all_assignments_f
   where assignment_id = c_assignment_id
   and sysdate between
       effective_start_date and effective_end_date;
--
l_person_id number;
--
BEGIN
   --
   hr_utility.set_location('payroll_transfer',10);
   delete from pay_assignment_latest_balances
   where assignment_id = p_assignment_id;
   --
   hr_utility.set_location('payroll_transfer',20);
   open csr_person_details(p_assignment_id);
   fetch csr_person_details into l_person_id;
   close csr_person_details;
   --
   if l_person_id is not null then
      hr_utility.set_location('payroll_transfer',30);
      delete from pay_person_latest_balances
      where person_id = l_person_id;
   end if;
--
end payroll_transfer;
--
-------------------------------------------------------------------------
-- PROCEDURE delete_per_latest_balances
-- This procedure deletes the person level balances where required.
-- All rows should be deleted from the person latest balances table
-- for the parameter person given certain events to ensure that the
-- Aggregated PAYE figures are correct, and to ensure that the correct
-- values are displayed in the application forms.
-------------------------------------------------------------------------
--
PROCEDURE delete_per_latest_balances
                    (p_person_id      number,
                     p_assignment_id  number,
                     p_effective_date date) is
--
-- There are 2 events, a termination of multi assignment or a creation of
-- a new multi assignment that will trigger the person level latest balances
-- to be trashed. These only need to be trashed where there are multiple
-- assignments and the people have Aggregated PAYE (DDF set on person).
-- Note this is called at assignment level hence must check for multis.
--
cursor csr_person_details (c_person_id in number,
                           c_effective_date in date) is
   select per_information10
   from per_all_people_f
   where person_id = c_person_id
   and c_effective_date between
       effective_start_date and effective_end_date;
--
cursor csr_multi_assignments (c_person_id      in number,
                              c_effective_date in date) is
   select count(paf.assignment_id)
   from per_all_assignments_f paf
   where person_id = c_person_id
   and c_effective_date between
       paf.effective_start_date and paf.effective_end_date;
--
l_aggregated_flag varchar2(1);
l_num_assgt       number;
l_function_name   varchar2(25) := 'delete_per_latest_bal';
--
begin
  --
  open csr_multi_assignments(p_person_id, p_effective_date);
  fetch csr_multi_assignments into l_num_assgt;
  close csr_multi_assignments;
  --
  hr_utility.set_location(l_function_name,10);
  if l_num_assgt > 1 then
    -- more than one asgt at this point in time, check
    -- aggregated PAYE flag.
    open csr_person_details(p_person_id, p_effective_date);
    fetch csr_person_details into l_aggregated_flag;
    close csr_person_details;
    --
    hr_utility.set_location(l_function_name,20);
    if upper(l_aggregated_flag) = 'Y' then
       hr_utility.set_location(l_function_name,30);
       BEGIN
         DELETE from pay_person_latest_balances
         WHERE person_id = p_person_id;
       END;
    end if;
  end if;
--
end delete_per_latest_balances;
--
end py_gb_asg;

/
