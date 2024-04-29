--------------------------------------------------------
--  DDL for Package Body PER_PDS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PDS_UTILS" AS
/* $Header: pepdsutl.pkb 120.4 2006/05/09 08:43:19 mkataria noship $ */
--
-- Package Variables
--
g_package  VARCHAR2(30) := 'per_pds_utils.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Check_Move_Hire_Date >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business support process provides a hook for other product teams to
--   invoke their specific code to handle the change of hire date event.
--
-- Prerequisites:
--   The person assignments and periods of service must already be present.
--
-- In Parameters:
--   Name               Reqd  Type      Description
--   p_person_id        Yes   number    Identifier for the person
--   p_old_start_date   Yes   date      Old Hire Date
--   p_new_start_date   Yes   date      New Hire Date
--   p_type             Yes   varchar2  Type of person
--
-- Post Success:
--   No error is raised if the new hire date is valid
--
-- Post Failure:
--   An error is raised and control returned if the new hire date is not
--   valid.
--
-- Access Status:
--   For Oracle Internal use only.
--
-- {End Of Comments}
--
PROCEDURE check_move_hire_date
  (p_person_id          IN     NUMBER
  ,p_old_start_date     IN     DATE
  ,p_new_start_date     IN     DATE
  ,p_type               IN     VARCHAR2
  ) IS
    /*Cursors for BEN validations*/
  cursor procd_le_exists(p_person_id in number
                      ,p_effective_date in date) is
  select 'Y'
  from ben_per_in_ler pil
  where pil.person_id = p_person_id
  and pil.per_in_ler_stat_cd in ('STRTD','PROCD')
  and pil.lf_evt_ocrd_dt < p_effective_date;
  --
  cursor procd_le_exists_fpd(p_person_id in number
                        ,p_effective_date in date
                        ,p_max_fpd in date) is
  select 'Y'
  from ben_per_in_ler pil
  where pil.person_id = p_person_id
  and pil.per_in_ler_stat_cd in ('STRTD','PROCD')
  and pil.lf_evt_ocrd_dt < p_effective_date
  and pil.lf_evt_ocrd_dt > p_max_fpd;
  --
  cursor max_fpd(p_person_id in number) is
  select max(final_process_date)
  from per_all_assignments_f asg,per_periods_of_service pps
  where
  asg.period_of_service_id = pps.period_of_service_id
  and asg.effective_end_date <> hr_api.g_eot
  and asg.person_id = p_person_id;
  --
  l_dummy varchar2(30);
  l_max_fpd date;
  l_later_le_exists boolean := false;
  /* End cursors for BEN*/
  --
  l_proc VARCHAR2(80) := g_package||'check_move_hire_date';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint even though this is a check routine to
  -- handle potential DB writes that may be issued by routines
  -- invoked from herein by any product team.
  --
  SAVEPOINT check_move_hire_date;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- {Product teams should place code calls BELOW THIS POINT}
  -- Benefits Validations
  open max_fpd(p_person_id);
  fetch max_fpd into l_max_fpd;
  close max_fpd;
  if l_max_fpd is null then
     open procd_le_exists(p_person_id, p_new_start_date);
   fetch procd_le_exists into l_dummy;
     if procd_le_exists%found then
        l_later_le_exists := true;
     end if;
     close procd_le_exists;
  else
     open procd_le_exists_fpd(p_person_id, p_new_start_date,l_max_fpd);
     fetch procd_le_exists_fpd into l_dummy;
     if procd_le_exists%found then
        l_later_le_exists := true;
     end if;
     close procd_le_exists_fpd;
  end if;
  --
  if l_later_le_exists then
      fnd_message.set_name('BEN', 'BEN_94623_PREV_LE_EXISTS');
      fnd_message.set_token('DATE',fnd_date.date_to_chardate(p_new_start_date));
      fnd_message.raise_error;
  end if;
  -- End Benefits Validations
  --
  --
  --
  --
  -- {Product teams should place code calls ABOVE THIS POINT}
  --
  hr_utility.set_location('Leaving:'|| l_proc, 9999);
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    -- An unexpected error has occurred
    -- No OUT parameters need to be set
    -- No cursors need to be closed
    --
    ROLLBACK TO check_move_hire_date;
    RAISE;
    --
END check_move_hire_date;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< Hr_Run_Alu_Ee >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business support process provides a hook for the Payroll team to use
--   to invoke their new API to perform any processing that accounts for the
--   effect on Payroll Actions of changing hire date.
--
-- Prerequisites:
--   The person assignments and periods of service must already be present.
--
-- In Parameters:
--   Name               Reqd  Type      Description
--   p_person_id        Yes   number    Identifier for the person
--   p_old_start_date   Yes   date      Old Hire Date
--   p_new_start_date   Yes   date      New Hire Date
--   p_type             Yes   varchar2  Type of person
--
-- Post Success:
--   No error is raised if the new hire date is valid
--
-- Post Failure:
--   An error is raised and control returned if the new hire date is not
--   valid.
--
-- Access Status:
--   For Oracle Internal use only.
--
-- {End Of Comments}
--
PROCEDURE hr_run_alu_ee
  (p_person_id          IN     NUMBER
  ,p_old_start_date     IN     DATE
  ,p_new_start_date     IN     DATE
  ,p_type               IN     VARCHAR2
  ) IS
  --
  l_proc VARCHAR2(80) := g_package||'hr_run_alu_ee';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  SAVEPOINT hr_run_alu_ee;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- {PAY team should place code calls BELOW THIS POINT}
  --
  --
  --
  --
  -- {PAY team should place code calls ABOVE THIS POINT}
  --
  hr_utility.set_location('Leaving:'|| l_proc, 9999);
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    -- An unexpected error has occurred
    -- No OUT parameters need to be set
    -- No cursors need to be closed
    --
    ROLLBACK TO hr_run_alu_ee;
    RAISE;
    --
END hr_run_alu_ee;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< Move_Elements_With_Fpd >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business procedure provides a hook for the Payroll team to use
--   to invoke their new API to handle the updation of element entries in
--   sync with changes to FPD.
--
-- Prerequisites:
--   The person assignments and periods of service must already be present.
--
-- In Parameters:
--   Name                     Reqd  Type      Description
--   p_assignment_id          Yes   number    Assignment Identifier
--   p_periods_of_service_id  Yes   number    Period Of Service Identifier
--   p_old_final_process_date Yes   date      Old Final Process Date
--   p_new_final_process_date Yes   date      New Final Process Date
--
-- Post Success:
--   Dates for both recurring and non-recurring element entries are in sync
--   with the new FPD
--
-- Post Failure:
--   An error is raised and control returned
--
-- Access Status:
--   For Oracle Internal use only.
--
-- {End Of Comments}
--
PROCEDURE move_elements_with_fpd
  (p_assignment_id           IN  NUMBER
  ,p_periods_of_service_id   IN  NUMBER
  ,p_old_final_process_date  IN  DATE
  ,p_new_final_process_date  IN  DATE
  ) IS
  --
  l_proc VARCHAR2(80) := g_package||'move_elements_with_fpd';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  SAVEPOINT move_elements_with_fpd;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- <Pay Code>
  --
  hrentmnt.move_fpd_entries
  (
   p_assignment_id           => p_assignment_id
  ,p_period_of_service_id    => p_periods_of_service_id
  ,p_new_final_process_date  => p_new_final_process_date
  ,p_old_final_process_date  => p_old_final_process_date
  );
  --
  -- <Pay Code>
  --
  hr_utility.set_location('Leaving:'|| l_proc, 9999);
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    -- An unexpected error has occurred
    -- No OUT parameters need to be set
    -- No cursors need to be closed
    --
    ROLLBACK TO move_elements_with_fpd;
    RAISE;
    --
END move_elements_with_fpd;
--
END per_pds_utils;

/
