--------------------------------------------------------
--  DDL for Package Body PER_US_EXTRA_ASSIGNMENT_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_US_EXTRA_ASSIGNMENT_RULES" AS
/* $Header: peasghcc.pkb 115.5 2001/12/10 09:58:16 pkm ship      $ */
PROCEDURE insert_tax_record
  (p_effective_date    in date
  ,p_assignment_id     in number
  ) IS
  BEGIN
    pay_us_tax_internal.maintain_us_employee_taxes (
       p_effective_date => p_effective_date
      ,p_assignment_id  => p_assignment_id
      ,p_delete_routine => 'ASSIGNMENT'
      );
  END;
--
PROCEDURE update_tax_record
  (p_effective_date        in date
  ,p_datetrack_update_mode in varchar2
  ,p_assignment_id         in number
  ,p_location_id           in number
  ) IS
  BEGIN
    pay_us_tax_internal.maintain_us_employee_taxes (
       p_effective_date => p_effective_date
      ,p_datetrack_mode => p_datetrack_update_mode
      ,p_assignment_id  => p_assignment_id
      ,p_location_id    => p_location_id
      ,p_delete_routine => 'ASSIGNMENT'
      );
  END;
--
PROCEDURE get_curr_ass_location_id
  (p_effective_date        in date
  ,p_datetrack_update_mode in varchar2
  ,p_assignment_id         in number
  ) IS
--
  cursor csr_asg_data is
    select asg.location_id
    from   per_assignments_f asg
    where  asg.assignment_id = p_assignment_id
    and    p_effective_date between asg.effective_start_date
           and asg.effective_end_date;
  --

  BEGIN
--
-- Reset the global variable g_old_assgt_location
-- to its initial value.
--
    per_us_extra_assignment_rules.g_old_assgt_location := hr_api.g_number;
--
-- read the location_id as of the effective_date to
-- store into the global for refrence in the package.procedure
-- pay_us_tax_internal.location_change.
    open  csr_asg_data;
     fetch csr_asg_data into
        per_us_extra_assignment_rules.g_old_assgt_location;
     if csr_asg_data%notfound then
       close csr_asg_data;
       hr_utility.set_message(801, 'HR_51253_PYP_ASS__NOT_VALID');
       hr_utility.raise_error;
     end if;
     close csr_asg_data;
  END;
--
PROCEDURE delete_tax_record
  (p_final_process_date in date
  ,p_assignment_id      in number
  ) IS
  BEGIN
    pay_us_tax_internal.maintain_us_employee_taxes (
       p_effective_date => p_final_process_date
      ,p_datetrack_mode => 'DELETE'
      ,p_assignment_id  => p_assignment_id
      ,p_delete_routine => 'ASSIGNMENT'
      );
  END;
--
PROCEDURE pay_us_asg_reporting
  (p_assignment_id      in number
  ) IS
  BEGIN
    IF hr_utility.chk_product_install(p_product     => 'Oracle Payroll',
                                      p_legislation => 'US') THEN
      pay_asg_geo_pkg.pay_us_asg_rpt (
        p_assignment_id  => p_assignment_id
        );
    END IF;
  END;
END per_us_extra_assignment_rules;
--

/
