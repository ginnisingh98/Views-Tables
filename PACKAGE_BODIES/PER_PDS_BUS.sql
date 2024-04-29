--------------------------------------------------------
--  DDL for Package Body PER_PDS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PDS_BUS" as
/* $Header: pepdsrhi.pkb 120.7.12010000.2 2009/07/15 10:28:27 pchowdav ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pds_bus.';  -- Global package name
--
-- 70.4 change a start.
--
-- 70.4 change a end.
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code         varchar2(150) default null;
g_period_of_service_id     number        default null;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_accepted_termination_date >--------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the following business rules are met:
--    a)      Must be null (I)
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_accepted_termination_date
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_accepted_termination_date
--
  (p_accepted_termination_date in
     per_periods_of_service.accepted_termination_date%TYPE) is
--
   l_proc       varchar2(72)  :=  g_package||'chk_accepted_termination_date';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  if not (p_accepted_termination_date is null)
  then
    -- CHK_ACCEPTED_TERMINATION_DATE / a
    --
    hr_utility.set_message(801,'HR_7492_PDS_INV_ACT_DT_BLANK');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 4);
end chk_accepted_termination_date;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_actual_termination_date >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the following business rules are met:
--    a)      Must be <= LAST_STANDARD_PROCESS_DATE (U)
--    b)      Must be >= DATE_START (U)
--    c)      Must be null (I)
--    d)      Cannot be changed from one not null value to another (U)
--    e)      Must be after initial insert date of last assignment (U)
--    f)      Must be after effective start date of last future change(s) (U)
--
--  Pre-conditions:
--    person_id, date_start, last_standard_process_date and period_of_service_id
--    have been successfully validated separately.
--
--  In Arguments:
--    p_actual_termination_date
--    p_date_start
--    p_last_standard_process_date
--    p_object_version_number
--    p_period_of_service_id
--    p_person_id
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_actual_termination_date
--
  (p_actual_termination_date    in
                            per_periods_of_service.actual_termination_date%TYPE
  ,p_date_start                 in per_periods_of_service.date_start%TYPE
  ,p_last_standard_process_date in
                         per_periods_of_service.last_standard_process_date%TYPE
  ,p_object_version_number      in
                              per_periods_of_service.object_version_number%TYPE
  ,p_period_of_service_id       in
                               per_periods_of_service.period_of_service_id%TYPE
  ,p_person_id                  in per_periods_of_service.person_id%TYPE
  ) is
--
   l_api_updating            boolean;
   l_no_data_found           boolean;
   l_effective_start_date    per_assignments_f.effective_start_date%TYPE;
   l_assignment_id           per_assignments_f.assignment_id%TYPE;
   l_proc                    varchar2(72) :=
                                       g_package||'chk_actual_termination_date';
   --
   cursor csr_get_max_asg_start_date is
     select min(asg.effective_start_date)
          , asg.assignment_id
     from   per_assignments_f asg
     where  asg.period_of_service_id = p_period_of_service_id
     group by asg.assignment_id
     order by 1 desc;
   --
   cursor csr_get_max_per_eff_date is
     select max(per.effective_start_date)
     from   per_all_people_f per
     where  per.person_id = p_person_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'date_start'
     ,p_argument_value => p_date_start
     );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Check to see if record updated.
  --
  l_api_updating := per_pds_shd.api_updating
         (p_period_of_service_id  => p_period_of_service_id
         ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 30);
  --
  if l_api_updating
  then
    --
    if  nvl(per_pds_shd.g_old_rec.actual_termination_date, hr_api.g_date) <>
        nvl(p_actual_termination_date, hr_api.g_date)
    and p_actual_termination_date is not null
    then
      hr_utility.set_location(l_proc, 40);
      --
      if per_pds_shd.g_old_rec.actual_termination_date is not null
      then
        --
        -- Cannot be changed from one not null value to another not null value.
        -- CHK_ACTUAL_TERMINATION_DATE / d
        --
        hr_utility.set_message(801,'HR_7955_PDS_INV_ATT_CHANGE');
        hr_utility.raise_error;
      end if;
      hr_utility.set_location(l_proc, 60);
      --
      if p_actual_termination_date > p_last_standard_process_date and
        p_last_standard_process_date is not null                 then
        --
        -- CHK_ACTUAL_TERMINATION_DATE / a
        --
        hr_utility.set_message(801,'HR_7505_PDS_INV_LSP_ATT_DT');
        hr_utility.raise_error;
      end if;
      hr_utility.set_location(l_proc, 70);
      --
      if not (nvl(p_actual_termination_date, hr_api.g_eot) >=
              p_date_start) then
        --
        -- CHK_ACTUAL_TERMINATION_DATE / b
        --
        hr_utility.set_message(801,'HR_7493_PDS_INV_ATT_DT_ST');
        hr_utility.raise_error;
      end if;
      hr_utility.set_location(l_proc, 80);
      --
      -- Get the initial insert date of the latest assignment.
      --
      open csr_get_max_asg_start_date;
      fetch csr_get_max_asg_start_date
       into l_effective_start_date
          , l_assignment_id;
      --
      if csr_get_max_asg_start_date%NOTFOUND then
        --
        close csr_get_max_asg_start_date;
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE', l_proc);
        hr_utility.set_message_token('STEP', '5');
        hr_utility.raise_error;
        --
      elsif (p_actual_termination_date < l_effective_start_date) then
        --
        -- CHK_ACTUAL_TERMINATION_DATE / e
        --
        close csr_get_max_asg_start_date;
        hr_utility.set_message(801,'HR_7956_PDS_INV_ATT_DT_EARLY');
        hr_utility.raise_error;
      end if;
      close csr_get_max_asg_start_date;
      hr_utility.set_location(l_proc, 110);
      --
      -- Get the latest effective start date for any person future changes.
      --
      open csr_get_max_per_eff_date;
      fetch csr_get_max_per_eff_date
       into l_effective_start_date;
      close csr_get_max_per_eff_date;
      --
      if l_effective_start_date is null then
        --
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE', l_proc);
        hr_utility.set_message_token('STEP', '10');
        hr_utility.raise_error;
        --
      elsif not (p_actual_termination_date >= l_effective_start_date) then
        --
        -- CHK_ACTUAL_TERMINATION_DATE / f
        --
        hr_utility.set_message(801,'HR_7957_PDS_INV_ATT_FUTURE');
        hr_utility.raise_error;
      end if;
    end if;
    --
  else
    -- Not updating => inserting.
    hr_utility.set_location(l_proc, 140);
    --
    if not (p_actual_termination_date is null) then
      --
      -- CHK_ACTUAL_TERMINATION_DATE / c
      --
      hr_utility.set_message(801,'HR_7502_PDS_INV_ATT_DT_BLANK');
      hr_utility.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 200);
end chk_actual_termination_date;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_date_start >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the following business rules are met:
--    a)      Mandatory (I,U)
--    NB:     The unique combination of person_id and date_start is validated
--            via rule CHK_PERSON_ID_DATE_START.

--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_date_start
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_date_start
--
  (p_date_start   in per_periods_of_service.date_start%TYPE) is
--
   l_proc           varchar2(72)  :=  g_package||'chk_date_start';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- CHK_DATE_START / a
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'date_start'
     ,p_argument_value => p_date_start
     );
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 2);
end chk_date_start;
--
--  ---------------------------------------------------------------------------
--  |------------------------<chk_final_process_date >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the following business rules are met:
--    a)      If the person is not assigned to any payrolls then
--            must be equal to ACTUAL_TERMINATION_DATE (U)
--    b)      If the person is assigned to a payroll then
--            must equal the maximum period end date of all Assignments
--            for the current Period of Service (U)
--    c)      Must be >= LAST_STANDARD_PROCESS_DATE (U)
--    d)      If ACTUAL_TERMINATION_DATE is null then must be null (U)
--    e)      Must be null (I)
--
--  Pre-conditions:
--    p_date_start, actual_termination_date, last_standard_process_date and
--    period_of_service_id have been successfully validated separately.
--
--  In Arguments:
--    p_actual_termination_date
--    p_date_start
--    p_final_process_date
--    p_last_standard_process_date
--    p_object_version_number
--    p_period_of_service_id
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_final_process_date
--
  (p_actual_termination_date    in
     per_periods_of_service.actual_termination_date%TYPE,
   p_date_start                 in     per_periods_of_service.date_start%TYPE,
   p_final_process_date         in
     per_periods_of_service.final_process_date%TYPE,
   p_last_standard_process_date in
     per_periods_of_service.last_standard_process_date%TYPE,
   p_object_version_number      in
     per_periods_of_service.object_version_number%TYPE,
   p_period_of_service_id       in
     per_periods_of_service.period_of_service_id%TYPE) is
--
   l_assigned_payroll boolean;
   l_api_updating     boolean;
   l_max_end_date     per_periods_of_service.final_process_date%TYPE;
   l_proc             varchar2(72)  :=  g_package||'chk_final_process_date';
--
--
-- 115.30 (START)
--
   CURSOR csr_next_pds IS
     SELECT pds2.date_start
           ,pds2.actual_termination_date
           ,pds2.last_standard_process_date
           ,pds2.final_process_date
     FROM   per_periods_of_service pds1
           ,per_periods_of_service pds2
     WHERE  pds1.period_of_service_id = p_period_of_service_id
     AND    pds1.person_id = pds2.person_id
     AND    pds1.period_of_service_id <> pds2.period_of_service_id
     AND    pds2.date_start > pds1.date_start
     ORDER BY pds2.date_start;
   --
   lr_next_pds csr_next_pds%ROWTYPE;
   --
   CURSOR csr_later_fpd IS
     SELECT pds2.final_process_date
     FROM   per_periods_of_service pds1
           ,per_periods_of_service pds2
     WHERE  pds1.period_of_service_id = p_period_of_service_id
     AND    pds1.person_id = pds2.person_id
     AND    pds1.period_of_service_id <> pds2.period_of_service_id
     AND    pds2.date_start > pds1.date_start;
   --
   l_later_fpd per_periods_of_service.final_process_date%TYPE;
   --
   CURSOR csr_prev_pds_fpd IS
     SELECT MAX(pds2.final_process_date)
     FROM   per_periods_of_service pds1
           ,per_periods_of_service pds2
     WHERE  pds1.period_of_service_id = p_period_of_service_id
     AND    pds1.person_id = pds2.person_id
     AND    pds1.period_of_service_id <> pds2.period_of_service_id
     AND    pds2.date_start < pds1.date_start;
   --
   l_prev_pds_fpd per_periods_of_service.final_process_date%TYPE;
   --
--
-- 115.30 (END)
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'date_start'
     ,p_argument_value => p_date_start
     );
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- Check to see if record updated.
  --
  l_api_updating := per_pds_shd.api_updating
         (p_period_of_service_id  => p_period_of_service_id
         ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 5);
  --
  if l_api_updating
  then
    --
    if nvl(per_pds_shd.g_old_rec.final_process_date, hr_api.g_date) <>
       nvl(p_final_process_date, hr_api.g_date)
    then
      --
      hr_utility.set_location(l_proc, 6);
      --
      --
      -- 70.3 change d start.
      --
--
-- 115.30 (START)
--
      --if  per_pds_shd.g_old_rec.final_process_date is not null
      --and p_final_process_date is not null
      --then
      --  -- CHK_FINAL_PROCESS_DATE / g
      --  --
      --  hr_utility.set_message(801,'HR_7962_PDS_INV_FP_CHANGE');
      --  hr_utility.raise_error;
      --end if;
      --
      -- if FPD is changing and old FPD < new FPD then raise an error if new FPD
      -- >= start date of next-latest PDS and old FPD < start date of next-latest
      -- PDS. In effect, check that a PDS gap is not being updated to an overlap.
      --
      IF per_pds_shd.g_old_rec.final_process_date IS NOT NULL
      AND p_final_process_date IS NOT NULL
      AND (p_final_process_date > per_pds_shd.g_old_rec.final_process_date)
      THEN
        --
        hr_utility.set_location(l_proc, 10);
        -- Get the next latest PDS is one exists
        OPEN csr_next_pds;
        FETCH csr_next_pds INTO lr_next_pds;
        IF csr_next_pds%FOUND THEN
          -- Check if PDS gap is being updated to a overlap
          hr_utility.set_location(l_proc, 15);
          --
          IF ((per_pds_shd.g_old_rec.final_process_date < lr_next_pds.date_start)
          AND p_final_process_date >= lr_next_pds.date_start)
          THEN
            CLOSE csr_next_pds;
            hr_utility.set_message(800,'HR_449744_EMP_FPD_PDS');
            hr_utility.raise_error;
          END IF;
--
-- 115.35 (START)
--
          --
          -- Ensure that new FPD is not equal to or greater than next PDS FPD
          --
          IF lr_next_pds.final_process_date IS NOT NULL
          THEN
            IF p_final_process_date >= lr_next_pds.final_process_date
            THEN
              CLOSE csr_next_pds;
              hr_utility.set_message(800,'HR_449761_FPD_GT_PREV_PDS');
              hr_utility.raise_error;
            END IF;
          END IF;
--
-- 115.35 (END)
--
        END IF;
        CLOSE csr_next_pds;
      END IF;
      --
      hr_utility.set_location(l_proc, 20);

      -- Commenting the following checks for ER 6981999.
      --
      -- if FPD is changing and old FPD < new FPD then raise an error if old FPD
      -- = LSPD/ATD but new FPD > LSPD/ATD.
      --
   /*   IF per_pds_shd.g_old_rec.final_process_date IS NOT NULL
      AND p_final_process_date IS NOT NULL
      AND (p_final_process_date > per_pds_shd.g_old_rec.final_process_date)
      THEN
        --
        hr_utility.set_location(l_proc, 22);
        --
        IF ((per_pds_shd.g_old_rec.final_process_date = NVL(p_last_standard_process_date, p_actual_termination_date))
        AND p_final_process_date > NVL(p_last_standard_process_date, p_actual_termination_date))
        THEN
          hr_utility.set_message(800,'HR_449764_FPD_GT_LSPD_ATD');
          hr_utility.raise_error;
        END IF;
      END IF;
--
-- 115.36 (START)
--
      --
      hr_utility.set_location(l_proc, 25);
      --
      IF per_pds_shd.g_old_rec.final_process_date IS NOT NULL
      AND p_final_process_date IS NULL
      THEN
        --
        hr_utility.set_location(l_proc, 26);
        --
        IF (per_pds_shd.g_old_rec.final_process_date = per_pds_shd.g_old_rec.actual_termination_date)
        THEN
          hr_utility.set_message(800,'HR_449764_FPD_GT_LSPD_ATD');
          hr_utility.raise_error;
        END IF;
      END IF;  */
--
-- 115.36 (END)
--
      --
      hr_utility.set_location(l_proc, 30);
      --
      -- if FPD is changing and old FPD > new FPD then raise an error if new FPD
      -- < start date of next-latest PDS and old FPD >= start date of next-latest
      -- PDS. In effect, check that a PDS overlap is not being updated to an gap.
      --
      IF per_pds_shd.g_old_rec.final_process_date IS NOT NULL
      AND p_final_process_date IS NOT NULL
      AND (p_final_process_date < per_pds_shd.g_old_rec.final_process_date)
      THEN
        -- Get the next latest PDS is one exists
        hr_utility.set_location(l_proc, 33);
        --
        OPEN csr_next_pds;
        FETCH csr_next_pds INTO lr_next_pds;
        IF csr_next_pds%FOUND THEN
          -- Check if PDS overlap is being updated to a gap
          hr_utility.set_location(l_proc, 35);
          --
          IF ((per_pds_shd.g_old_rec.final_process_date >= lr_next_pds.date_start)
          AND p_final_process_date < lr_next_pds.date_start)
          THEN
            CLOSE csr_next_pds;
            hr_utility.set_message(800,'HR_449744_EMP_FPD_PDS');
            hr_utility.raise_error;
          END IF;
        END IF;
        CLOSE csr_next_pds;
      END IF;
      --
      hr_utility.set_location(l_proc, 40);
      --
      -- if FPD is changing and old FPD > new FPD then raise an error if the new
      -- FPD <= NVL(LSPD,ATD)
      --
      IF per_pds_shd.g_old_rec.final_process_date IS NOT NULL
      AND p_final_process_date IS NOT NULL
      AND (p_final_process_date < per_pds_shd.g_old_rec.final_process_date)
      AND (p_final_process_date < NVL(p_last_standard_process_date, p_actual_termination_date)) -- ER 6981999 .
      THEN
        hr_utility.set_message(800,'HR_449741_EMP_FPD_ATD');
        hr_utility.raise_error;
      END IF;
      --
      hr_utility.set_location(l_proc, 45);
      --
      -- if FPD is changing and old FPD > new FPD then raise an error if the new
      -- FPD <= Prev PDS FPD
      --
      IF per_pds_shd.g_old_rec.final_process_date IS NOT NULL
      AND p_final_process_date IS NOT NULL
      AND (p_final_process_date < per_pds_shd.g_old_rec.final_process_date)
      THEN
        -- Get the previous PDS FPD
        OPEN csr_prev_pds_fpd;
        FETCH csr_prev_pds_fpd INTO l_prev_pds_fpd;
        IF csr_prev_pds_fpd%FOUND THEN
          IF p_final_process_date <= l_prev_pds_fpd THEN
            CLOSE csr_prev_pds_fpd;
            hr_utility.set_message(800,'HR_449761_FPD_GT_PREV_PDS');
            hr_utility.raise_error;
          END IF;
        END IF;
        CLOSE csr_prev_pds_fpd;
      END IF;
      --
      hr_utility.set_location(l_proc, 50);
      --
      -- if FPD is changing and the new FPD is null, then raise an error is a
      -- later PDS exists with FPD not null.
      --
      IF per_pds_shd.g_old_rec.final_process_date IS NOT NULL
      AND p_final_process_date IS NULL
      THEN
        -- Check for a later PDS with FPD not null
        hr_utility.set_location(l_proc, 53);
        --
        OPEN csr_later_fpd;
        FETCH csr_later_fpd INTO l_later_fpd;
        IF csr_later_fpd%FOUND THEN
          CLOSE csr_later_fpd;
          hr_utility.set_message(800,'HR_449743_EMP_FPD_REQD');
          hr_utility.raise_error;
        END IF;
        CLOSE csr_later_fpd;
      END IF;
--
-- 115.30 (END)
--
      --
      hr_utility.set_location(l_proc, 60);
      if p_actual_termination_date is null
      then
        --
        if not (p_final_process_date is null)
        then
          -- CHK_FINAL_PROCESS_DATE / d
          --
          hr_utility.set_message(801,'HR_7503_PDS_INV_FP_DT_BLANK');
          hr_utility.raise_error;
        end if;
        --
      end if;
      --
      hr_utility.set_location(l_proc, 7);
      --
      if p_last_standard_process_date is null
      then
        --
        hr_utility.set_location(l_proc, 8);
        --
        if not (nvl(p_final_process_date, hr_api.g_eot) >=
                nvl(p_actual_termination_date, hr_api.g_eot))
        then
          -- CHK_FINAL_PROCESS_DATE / f
          --
          hr_utility.set_message(801,'HR_7963_PDS_INV_FP_BEFORE_ATT');
          hr_utility.raise_error;
        end if;
      else
        --
        -- 70.1 change a start.
        --
        if not (nvl(p_final_process_date, hr_api.g_eot) >=
                p_last_standard_process_date)
        --
        -- 70.1 change a end.
        --
        then
          -- CHK_FINAL_PROCESS_DATE / c
          --
          hr_utility.set_message(801,'HR_7504_PDS_INV_FP_LSP_DT');
          hr_utility.raise_error;
        end if;
      end if;
      --
      -- 70.3 change d end.
      --
      hr_utility.set_location(l_proc, 8);
      --
      -- 70.4 change a start.
      --
      -- 70.4 change a end.
      --
    end if;
  else
    -- Not updating => inserting.
    hr_utility.set_location(l_proc, 12);
    --
    if not (p_final_process_date is null)
    then
      -- CHK_FINAL_PROCESS_DATE / e
      --
      hr_utility.set_message(801,'HR_7496_PDS_INV_FP_DT');
      hr_utility.raise_error;
    end if;
    --
    hr_utility.set_location(l_proc, 13);
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 14);
end chk_final_process_date;
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_last_standard_process_date >--------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the following business rules are met:
--    c)      Must be >= ACTUAL_TERMINATION_DATE (U)
--    e)      Must be null (I)
--    f)      If ACTUAL_TERMINATION_DATE is null then must be null (U)
--    g)      If US legislation then must be null (U)
--    h)      If not US legislation and ACTUAL_TERMINATION_DATE is not null
--            then must not be null (U)
--    i)      Cannot be changed from one not null value to another (U)
--
--  Pre-conditions:
--    p_date_start, actual_termination_date, and period_of_service_id
--    have been successfully validated separately.
--
--  In Arguments:
--    p_actual_termination_date
--    p_date_start
--    p_last_standard_process_date
--    p_object_version_number
--    p_period_of_service_id
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
-- 70.3 change c start.
--
procedure chk_last_standard_process_date
--
  (p_actual_termination_date    in
    per_periods_of_service.actual_termination_date%TYPE
  ,p_business_group_id          in
    per_periods_of_service.business_group_id%TYPE
  ,p_date_start                 in per_periods_of_service.date_start%TYPE
  ,p_last_standard_process_date in
    per_periods_of_service.last_standard_process_date%TYPE
  ,p_object_version_number      in
    per_periods_of_service.object_version_number%TYPE
  ,p_period_of_service_id       in
    per_periods_of_service.period_of_service_id%TYPE
  ) is
--
  l_api_updating     boolean;
  l_assigned_payroll boolean;
  l_legislation_code per_business_groups.legislation_code%TYPE;
  l_max_end_date     per_periods_of_service.final_process_date%TYPE;
  l_proc             varchar2(72)
                       := g_package||'chk_last_standard_process_date';
--
  cursor csr_get_legislation_code is
    select bus.legislation_code
    from   per_business_groups bus
    where  bus.business_group_id = p_business_group_id;
--
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'date_start'
     ,p_argument_value => p_date_start
     );
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Check to see if record updated.
  --
  l_api_updating := per_pds_shd.api_updating
         (p_period_of_service_id  => p_period_of_service_id
         ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 20);
  --
  if l_api_updating
  then
    --
    if nvl(per_pds_shd.g_old_rec.last_standard_process_date, hr_api.g_date) <>
       nvl(p_last_standard_process_date, hr_api.g_date)
    then
      --
      hr_utility.set_location(l_proc, 30);
      --
      if  per_pds_shd.g_old_rec.last_standard_process_date is not null
      and p_last_standard_process_date is not null
      then
        -- CHK_LAST_STANDARD_PROCESS_DATE / i
        --
        hr_utility.set_message(801,'HR_7960_PDS_INV_LSP_CHANGE');
        hr_utility.raise_error;
      end if;
      --
      hr_utility.set_location(l_proc, 40);
      --
      open  csr_get_legislation_code;
      fetch csr_get_legislation_code
       into l_legislation_code;
      --
      if csr_get_legislation_code%NOTFOUND
      then
        --
        close csr_get_legislation_code;
        --
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE', l_proc);
        hr_utility.set_message_token('STEP', '5');
        hr_utility.raise_error;
      end if;
      --
      close csr_get_legislation_code;
      --
      hr_utility.set_location(l_proc, 50);
      --
-- Bug 1711085. VS. 27-Mar-2001. Commented out the code that disables
-- last_standard_process for US legislature.
/*      if l_legislation_code = 'US'
      then
        --
        hr_utility.set_location(l_proc, 60);
        --
        if not (p_last_standard_process_date is null)
        then
          -- CHK_LAST_STANDARD_PROCESS_DATE / g
          --
          hr_utility.set_message(801,'HR_7958_PDS_INV_US_LSP_BLANK');
          hr_utility.raise_error;
        end if;
      end if;
*/
      --
      if p_actual_termination_date is null
      then
        --
        if not (p_last_standard_process_date is null)
        then
          -- CHK_LAST_STANDARD_PROCESS_DATE / f
          --
          hr_utility.set_message(801,'HR_7497_PDS_INV_LSP_DT_BLANK');
          hr_utility.raise_error;
        end if;
        --
      end if;
      --
      hr_utility.set_location(l_proc, 80);
      --
      -- 70.1 change a start.
      --
      if not (nvl(p_last_standard_process_date, hr_api.g_eot) >=
              nvl(p_actual_termination_date, hr_api.g_eot))
      --
      -- 70.1 change a end.
      --
      then
        -- CHK_LAST_STANDARD_PROCESS_DATE / c
        --
        hr_utility.set_message(801,'HR_7505_PDS_INV_LSP_ATT_DT');
        hr_utility.raise_error;
      end if;
      --
      hr_utility.set_location(l_proc, 90);
      --
    end if;
    --
    --  70.16 change h start.
    --
    if  (nvl(per_pds_shd.g_old_rec.actual_termination_date, hr_api.g_date) <>
         nvl(p_actual_termination_date,hr_api.g_date) )
         and (p_actual_termination_date is not null)
         and l_legislation_code <> 'US'
      --
    then
           hr_utility.set_location(l_proc, 100);
           --
           if p_last_standard_process_date is null
           --
           then
           --
           -- Must also be set to not null value if actual_termination_date
           -- updated to not null value.
           -- CHK_LAST_STANDARD_PROCESS_DATE / h
           --
              hr_utility.set_message(801,'HR_7959_PDS_INV_LSP_BLANK');
              hr_utility.raise_error;
           end if;
    end if;
    --
    -- 70.16 change h end.
    --
  else
    --
    -- Not updating => inserting.
    --
    hr_utility.set_location(l_proc, 110);
    --
    if not (p_last_standard_process_date is null)
    then
      -- CHK_LAST_STANDARD_PROCESS_DATE / e
      --
      hr_utility.set_message(801,'HR_7484_PDS_INV_LSP_DT');
      hr_utility.raise_error;
    end if;
    --
    hr_utility.set_location(l_proc, 120);
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 200);
end chk_last_standard_process_date;
--
-- 70.3 change c end.
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_at_date_lsp_date >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates the following business rule :
--
--    If actual_termination_date is changed from a NULL value to
--    a NOT NULL value then last_standard_process_date must also
--    be changed to a NOT NULL value.
--
--  Pre-conditions:
--    actual_termination_date, last_standard_process_date have been
--    successfully validated separately.
--
--  In Arguments:
--    p_period_of_service_id
--    p_actual_termination_date
--    p_last_standard_process_date
--    p_object_version_number
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
-- commented out this routine for fix of bug#2784295
/* procedure chk_at_date_lsp_date
--
  (p_actual_termination_date    in per_periods_of_service.actual_termination_date%TYPE
  ,p_last_standard_process_date in per_periods_of_service.last_standard_process_date%TYPE
  ,p_object_version_number      in per_periods_of_service.object_version_number%TYPE
  ,p_period_of_service_id       in per_periods_of_service.period_of_service_id%TYPE
  ,p_business_group_id		in per_periods_of_service.business_group_id%TYPE
  ) is
--
  l_proc             varchar2(72) := g_package||'chk_at_date_lsp_date';
  l_api_updating     boolean;
  l_legislation_code per_business_groups.legislation_code%TYPE;
--
 cursor csr_get_legislation_code is
    select bus.legislation_code
    from   per_business_groups bus
    where  bus.business_group_id = p_business_group_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Check to see if record updated.
  --
  l_api_updating := per_pds_shd.api_updating
         (p_period_of_service_id  => p_period_of_service_id
         ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for actual_termination_date or last_standard_process_date
  --    has changed
  --
  if (l_api_updating
    and ((nvl(per_pds_shd.g_old_rec.actual_termination_date, hr_api.g_date)
        <> nvl(p_actual_termination_date, hr_api.g_date))
        or
        (nvl(per_pds_shd.g_old_rec.last_standard_process_date, hr_api.g_date)
        <> nvl(p_last_standard_process_date, hr_api.g_date))))
    or
      NOT l_api_updating then
    --
    hr_utility.set_location(l_proc, 30);
    --
      open  csr_get_legislation_code;
      fetch csr_get_legislation_code
      into l_legislation_code;
      --
      if csr_get_legislation_code%NOTFOUND
      then
        --
        close csr_get_legislation_code;
        --
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE', l_proc);
        hr_utility.set_message_token('STEP', '5');
        hr_utility.raise_error;
      end if;
      --
      close csr_get_legislation_code;
      --
      hr_utility.set_location(l_proc, 50);
      --
      if l_legislation_code <> 'US' then
      --
      -- Check combination when either actual_termination_date or
      -- last_standard_process_date are set
      --
        if  (per_pds_shd.g_old_rec.actual_termination_date is null
            and  p_actual_termination_date is not null)
            and  p_last_standard_process_date is null
        then
            hr_utility.set_message(801,'HR_7959_PDS_INV_LSP_BLANK');
            hr_utility.raise_error;
        end if;
      --
      end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_at_date_lsp_date; */
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_leaving_reason >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the following business rules are met:
--    a)      Validate against HR_LOOKUPS.lookup_code
--            where LOOKUP_TYPE = 'LEAV_REAS' (U)
--    b)      Must be null (I)
--
--  Pre-conditions:
--    period_of_Service_id must have been successfully validated.
--
--  In Arguments:
--    p_leaving_reason
--    p_effective_date
--    p_object_version_number
--    p_period_of_service_id
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_leaving_reason
--
  (p_leaving_reason             in per_periods_of_service.leaving_reason%TYPE,
   p_effective_date             in date,
   p_object_version_number      in
     per_periods_of_service.object_version_number%TYPE,
   p_period_of_service_id       in
     per_periods_of_service.period_of_service_id%TYPE) is
--
   l_api_updating boolean;
   l_proc         varchar2(72)  :=  g_package||'chk_leaving_reason';
   l_rec	  per_pds_shd.g_rec_type;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  hr_api.mandatory_arg_error
   (p_api_name    => l_proc
   ,p_argument    => 'effective date'
   ,p_argument_value => p_effective_date
   );
  --
  -- Check to see if record updated.
  --
  l_api_updating := per_pds_shd.api_updating
         (p_period_of_service_id  => p_period_of_service_id
         ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 2);
  --
  if  l_api_updating
  and p_leaving_reason is not null
  then
    --
    if nvl(per_pds_shd.g_old_rec.leaving_reason, hr_api.g_varchar2) <>
       nvl(p_leaving_reason, hr_api.g_varchar2)
    then
      --
      -- Bug 1472162.
      --
--      if hr_api.not_exists_in_hr_lookups
      if hr_api.not_exists_in_leg_lookups
	  (p_effective_date  => p_effective_date
	  ,p_lookup_type     => 'LEAV_REAS'
	  ,p_lookup_code     => p_leaving_reason
	  ) then
        -- Error - Invalid Leaving Reason
        hr_utility.set_location(l_proc, 3);
        hr_utility.set_message(801,'HR_7485_PDS_INV_LR');
        hr_utility.raise_error;
      end if;
      --
    end if;
    --
  else
    --
    -- Not updating => inserting.
    --
    if not (p_leaving_reason is null)
    then
      -- CHK_LEAVING_REASON / b
      --
      hr_utility.set_message(801,'HR_7489_PDS_INV_LR_BLANK');
      hr_utility.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
end chk_leaving_reason;
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_notified_termination_date >--------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the following business rules are met:
--    a)      Must be null (I)
--    b)      Must be >= DATE_START (I,U)
--
--  Pre-conditions:
--    date_start and period_of_service_id have been successfully validated
--    separately.
--
--  In Arguments:
--    p_date_start
--    p_notified_termination_date
--    p_object_version_number
--    p_period_of_service_id
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_notified_termination_date
--
  (p_date_start                 in per_periods_of_service.date_start%TYPE,
   p_notified_termination_date    in
     per_periods_of_service.notified_termination_date%TYPE,
   p_object_version_number      in
     per_periods_of_service.object_version_number%TYPE,
   p_period_of_service_id       in
     per_periods_of_service.period_of_service_id%TYPE) is
--
   l_api_updating  boolean;
   l_proc          varchar2(72)  :=  g_package||'chk_notified_termination_date';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'date_start'
     ,p_argument_value => p_date_start
     );
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- 70.1 change a start.
  --
  if not (nvl(p_notified_termination_date, hr_api.g_eot) >=
          nvl(p_date_start, hr_api.g_date))
  --
  -- 70.1 change a end.
  --
  then
    -- CHK_NOTIFIED_TERMINATION_DATE / b
    --
    hr_utility.set_message(801,'HR_7486_PDS_INV_NFT_DT_ST');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 5);
  --
  -- Check to see if record updated.
  --
  l_api_updating := per_pds_shd.api_updating
         (p_period_of_service_id  => p_period_of_service_id
         ,p_object_version_number => p_object_version_number);
  --
  if not l_api_updating
  then
    --
    -- Not updating => inserting
    --
    hr_utility.set_location(l_proc, 6);
    --
    if not (p_notified_termination_date is null)
    then
      -- CHK_NOTIFIED_TERMINATION_DATE / a
      --
      hr_utility.set_message(801,'HR_7487_PDS_INV_NFT_DT_BLANK');
      hr_utility.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 7);
end chk_notified_termination_date;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_person_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the following business rules are met:
--    a)      Mandatory (I,U)
--    b)      UPDATE not allowed (U)
--    c)      Must not be the same as TERMINATION_ACCEPTED_PERSON_ID (I,U)
--    NB:     The unique combination of person_id and date_start is validated
--            via rule CHK_PERSON_ID_DATE_START.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_id
--    p_termination_accepted_person
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_person_id
--
  (p_person_id                   in per_periods_of_service.person_id%TYPE,
   p_termination_accepted_person in
     per_periods_of_service.termination_accepted_person_id%TYPE) is
--
   l_proc           varchar2(72)  :=  g_package||'chk_person_id';
   l_rec	    per_pds_shd.g_rec_type;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- CHK_PERSON_ID / a
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'person_id'
     ,p_argument_value => p_person_id
     );
  hr_utility.set_location(l_proc, 2);
  --
  if not (p_person_id <>
          nvl(p_termination_accepted_person, hr_api.g_number))
  then
    -- CHK_PERSON_ID / c
    --
    hr_utility.set_message(801,'HR_7488_PDS_INV_TAP_ID');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 4);
end chk_person_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_person_id_date_start >----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the following business rules are met:
--    a)      PERSON_ID and DATE_START combination must be unique (I)
--    b)      PERSON_ID and DATE_START combination must exist in
--            PER_ALL_PEOPLE_F where PERSON_SYSTEM_TYPE in ('EMP', 'EMP_APL')
--            (I,U)
--
--  Pre-conditions:
--    person_id and date_start have been successfully validated separately.
--
--  In Arguments:
--    p_date_start
--    p_person_id
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_person_id_date_start
--
  (p_date_start            in per_periods_of_service.date_start%TYPE,
   p_object_version_number in per_periods_of_service.object_version_number%TYPE,
   p_period_of_service_id  in per_periods_of_service.period_of_service_id%TYPE,
   p_person_id             in per_periods_of_service.person_id%TYPE) is
--
   l_api_updating   boolean;
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'chk_person_id_date_start';
--
   cursor csr_new_pers_date is
     select null
     from   per_periods_of_service pds
     where  pds.person_id  = p_person_id
     and    pds.date_start = p_date_start;
--
   cursor csr_valid_pers_date is
     select null
     from   per_all_people_f p,
            per_person_types pt
     where  p.person_id            = p_person_id
     and    p.effective_start_date = p_date_start
     and    pt.person_type_id      = p.person_type_id
     and    pt.system_person_type  in ('EMP', 'EMP_APL');
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'person_id'
     ,p_argument_value => p_person_id
     );
  hr_utility.set_location(l_proc, 4);
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'date_start'
     ,p_argument_value => p_date_start
     );
  hr_utility.set_location(l_proc, 5);
  --
  -- Check to see if record updated.
  --
  l_api_updating := per_pds_shd.api_updating
         (p_period_of_service_id  => p_period_of_service_id
         ,p_object_version_number => p_object_version_number);
  --
  if not l_api_updating
  then
    --
    -- Check that the Person ID and Date Start combination does not exist
    -- on PER_PERIODS_OF_SERVICE
    --
    hr_utility.set_location(l_proc, 6);
    --
    open csr_new_pers_date;
    --
    fetch csr_new_pers_date into l_exists;
    --
    if csr_new_pers_date%FOUND
    then
      -- CHK_PERSON_ID_DATE_START / a
      --
      close csr_new_pers_date;
      hr_utility.set_message(801, 'HR_6796_EMP_POS_EXISTS');
      hr_utility.raise_error;
    end if;
    --
    close csr_new_pers_date;
  end if;
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Check that the Person ID and Date Start combination exists
  -- on PER_ALL_PEOPLE_F for system_person_type of 'EMP' or 'EMP_APL'.
  --
  open csr_valid_pers_date;
  --
  fetch csr_valid_pers_date into l_exists;
  --
  if csr_valid_pers_date%NOTFOUND
  then
    -- CHK_PERSON_ID_DATE_START / b
    --
    close csr_valid_pers_date;
    hr_utility.set_message(801, 'HR_7490_PDS_INV_P_DT_ST');
    hr_utility.raise_error;
  end if;
  --
  close csr_valid_pers_date;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 9);
end chk_person_id_date_start;
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_projected_termination_date >--------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the following business rules are met:
--    a)      Must be null (I)
--    b)      Must be >= DATE_START (I,U)
--
--  Pre-conditions:
--    date_start and period_of_service_id have been successfully validated
--    separately.
--
--  In Arguments:
--    p_date_start
--    p_object_version_number
--    p_period_of_service_id
--    p_projected_termination_date
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_projected_termination_date
--
  (p_date_start                 in per_periods_of_service.date_start%TYPE,
   p_object_version_number      in
     per_periods_of_service.object_version_number%TYPE,
   p_period_of_service_id       in
     per_periods_of_service.period_of_service_id%TYPE,
   p_projected_termination_date in
     per_periods_of_service.projected_termination_date%TYPE) is
--
   l_api_updating boolean;
   l_proc         varchar2(72)  :=  g_package||'chk_projected_termination_date';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'date_start'
     ,p_argument_value => p_date_start
     );
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- 70.1 change a start.
  --
  if not (nvl(p_projected_termination_date, hr_api.g_eot) >=
          nvl(p_date_start, hr_api.g_date))
  --
  -- 70.1 change a end.
  --
  then
    -- CHK_PROJECTED_TERMINATION_DATE / b
    --
    hr_utility.set_message(801,'HR_7491_PDS_INV_PJT_DT_ST');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 5);
  --
  -- Check to see if record updated.
  --
  l_api_updating := per_pds_shd.api_updating
         (p_period_of_service_id  => p_period_of_service_id
         ,p_object_version_number => p_object_version_number);
  --
  if not l_api_updating
  then
    --
    hr_utility.set_location(l_proc, 6);
    --
    if not (p_projected_termination_date is null)
    then
      -- CHK_PROJECTED_TERMINATION_DATE / a
      --
      hr_utility.set_message(801,'HR_7499_PDS_INV_PJT_DT_BLANK');
      hr_utility.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 7);
end chk_projected_termination_date;
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_termination_accepted_pers >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the following business rules are met:
--    a)      Must exist in PER_ALL_PEOPLE_F for the ACCEPTED_TERMINATION_DATE
--            (U)
--    b)      Must not be the same as PERSON_ID (I,U)
--    c)      Must be null (I)
--
--  Pre-conditions:
--    accepted_termination_date, person_id and period_of_service_id have been
--    successfully validated separately.
--
--  In Arguments:
--    p_accepted_termination_date
--    p_object_version_number
--    p_period_of_service_id
--    p_person_id
--    p_termination_accepted_person
--    p_effective_date
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
procedure chk_termination_accepted_pers
--
  (p_accepted_termination_date   in per_periods_of_service.date_start%TYPE,
   p_object_version_number       in per_periods_of_service.object_version_number%TYPE,
   p_period_of_service_id        in per_periods_of_service.period_of_service_id%TYPE,
   p_person_id                   in per_periods_of_service.person_id%TYPE,
   p_termination_accepted_person in per_periods_of_service.termination_accepted_person_id%TYPE,
   p_effective_date              in date) is
--
  l_api_updating   boolean;
  l_exists         varchar2(1);
  l_proc           varchar2(72) := g_package||'chk_termination_accepted_pers';
--
--
--Bug# 2810608 Start here
-- Desciption : Changed the subquery table from per_people_f to per_all_people_f
--  so that the termination accepted by person is validated from all employees
--
  cursor csr_valid_term_person is
  select null
  from  per_all_people_f per
  where per.person_id         = p_termination_accepted_person
  and   nvl(p_accepted_termination_date, p_effective_date) >=
                              (select min(per2.effective_start_date)
                               from   per_all_people_f per2
                               where  per2.person_id = per.person_id)
  and   nvl(p_accepted_termination_date, p_effective_date) <=
                              (select max(per3.effective_end_date)
                               from   per_all_people_f per3
                               where  per3.person_id = per.person_id);
--
-- Bug# 2810608 End here
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'person_id'
     ,p_argument_value => p_person_id
     );
  --
  hr_utility.set_location(l_proc, 5);
  --
  -- Check to see if record updated.
  --
  l_api_updating := per_pds_shd.api_updating
         (p_period_of_service_id  => p_period_of_service_id
         ,p_object_version_number => p_object_version_number);
  --
  if l_api_updating
  then
    --
    if (nvl(per_pds_shd.g_old_rec.termination_accepted_person_id,			  -- Bug # 2282955. This right hand side part of the condtion
           hr_api.g_number)                                  <>				  -- is modified from  nvl(p_termination_acceted_person,
       nvl(p_termination_accepted_person, nvl(						  -- hr_api.g_number) to nvl(p_termination_acceted_person,
       		per_pds_shd.g_old_rec.termination_accepted_person_id,hr_api.g_number)))   -- nvl(per_pds_shd.g_old_rec.termination_accepted_person_id,
    then										  -- hr_api.g_number))
      --
      -- CHK_TERMINATION_ACCEPTED_PERSON_ID / b
      --
      if  (nvl(p_termination_accepted_person, hr_api.g_number) =
          per_pds_shd.g_old_rec.person_id)
      then
          hr_utility.set_message(801,'HR_7488_PDS_INV_TAP_ID');
          hr_utility.raise_error;
      end if;
      --
      hr_utility.set_location(l_proc, 7);
      --
      open csr_valid_term_person;
      fetch csr_valid_term_person into l_exists;
      --
      if csr_valid_term_person%NOTFOUND then
        --
        -- CHK_TERMINATION_ACCEPTED_PERSON_ID / a
        --
        close csr_valid_term_person;
        hr_utility.set_message(801,'HR_7500_PDS_INV_TAP_ID');
        hr_utility.raise_error;
      end if;
      --
      close csr_valid_term_person;
      --
      hr_utility.set_location(l_proc, 9);
      --
    end if;
    --
  else
    --
    -- Not updating => inserting.
    --
    hr_utility.set_location(l_proc, 13);
    --
    if not (p_termination_accepted_person is null)
    then
      -- CHK_TERMINATION_ACCEPTED_PERSON_ID / c
      --
      hr_utility.set_message(801,'HR_7501_PDS_INV_TAP_BLANK');
      hr_utility.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 15);
end chk_termination_accepted_pers;
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_non_updateable_args >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updatetable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   (business_group_id, period_of_service_id, person_id)
--   have been altered.
--
-- {End Of Comments}
Procedure check_non_updateable_args
--
  (p_rec in per_pds_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'check_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);
--
Begin
   hr_utility.set_location('Entering:'||l_proc, 5);
--
-- Only proceed with validation if a row exists for
-- the current record in the HR Schema
--
  if not per_pds_shd.api_updating
                (p_period_of_service_id  => p_rec.period_of_service_id,
                 p_object_version_number => p_rec.object_version_number)
  then
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;
  --
  hr_utility.set_location(l_proc, 6);
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(per_pds_shd.g_old_rec.business_group_id, hr_api.g_number)
  then
    -- CHK_BUSINESS_GROUP_ID / b
    --
    l_argument := 'business_group_id';
    raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 7);
  --
  if nvl(p_rec.period_of_service_id, hr_api.g_number) <>
     nvl(per_pds_shd.g_old_rec.period_of_service_id, hr_api.g_number)
  then
    -- CHK_PERIOD_OF_SERVICE_ID / c
    --
    l_argument := 'period_of_service_id';
    raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 8);
  --
  if nvl(p_rec.person_id, hr_api.g_number) <>
     nvl(per_pds_shd.g_old_rec.person_id, hr_api.g_number)
  then
    -- CHK_PERSON_ID / b
    --
    l_argument := 'person_id';
    raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  exception
    when l_error
    then
      --
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 12);
end check_non_updateable_args;
--
-- ---------------------------------------------------------------------------
-- |----------------------------<  chk_df  >---------------------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--   Calls the descriptive flex validation (ins_or_upd_descflex_attribs)
--   if either the attribute_category or attribute1..20 have changed.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If an exception is raised within this procedure or lower
--   procedure calls then it is raised through the normal exception
--   handling mechanism.
--
-- Access Status:
--   Internal Table Handler Use Only.
-- ---------------------------------------------------------------------------
procedure chk_df
  (p_rec              in per_pds_shd.g_rec_type
  ,p_validate_df_flex in boolean               default true) is
  --
    l_proc    varchar2(72) := g_package||'chk_df';
    --
    begin
    --
      hr_utility.set_location('Entering:'||l_proc, 10);
      --
      -- if inserting and not required to validate flex data
      -- then ensure all flex data passed is null
      --
      If ((p_rec.period_of_service_id is null) and
          (not p_validate_df_flex)) then
             --
             hr_utility.set_location(l_proc, 15);
             --
             If (not ( (p_rec.attribute_category is null) and
                       (p_rec.attribute1         is null) and
                       (p_rec.attribute2         is null) and
                       (p_rec.attribute3         is null) and
                       (p_rec.attribute4         is null) and
                       (p_rec.attribute5         is null) and
                       (p_rec.attribute6         is null) and
                       (p_rec.attribute7         is null) and
                       (p_rec.attribute8         is null) and
                       (p_rec.attribute9         is null) and
                       (p_rec.attribute10        is null) and
                       (p_rec.attribute11        is null) and
                       (p_rec.attribute12        is null) and
                       (p_rec.attribute13        is null) and
                       (p_rec.attribute14        is null) and
                       (p_rec.attribute15        is null) and
                       (p_rec.attribute16        is null) and
                       (p_rec.attribute17        is null) and
                       (p_rec.attribute18        is null) and
                       (p_rec.attribute19        is null) and
                       (p_rec.attribute20        is null) ) )
                 then
                   hr_utility.set_message(800,'HR_6153_ALL_PROCEDURE_FAIL');
                   hr_utility.set_message_token('PROCEDURE','chk_df');
                   hr_utility.set_message_token('STEP',1);
                   hr_utility.raise_error;
             End if;
      End if;
      --
      --
      -- if   (    updating and flex data has changed
      --        OR updating and all flex segments are NULL)
      --   OR ( inserting and required to validate flexdata)
      -- then validate flex data.
      --
      --
      If (  (p_rec.period_of_service_id is not null)
             and
         (  (nvl(per_pds_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
             nvl(p_rec.attribute_category, hr_api.g_varchar2) or
             nvl(per_pds_shd.g_old_rec.attribute1, hr_api.g_varchar2)  <>
             nvl(p_rec.attribute1, hr_api.g_varchar2) or
             nvl(per_pds_shd.g_old_rec.attribute2, hr_api.g_varchar2)  <>
             nvl(p_rec.attribute2, hr_api.g_varchar2) or
             nvl(per_pds_shd.g_old_rec.attribute3, hr_api.g_varchar2)  <>
             nvl(p_rec.attribute3, hr_api.g_varchar2) or
             nvl(per_pds_shd.g_old_rec.attribute4, hr_api.g_varchar2)  <>
             nvl(p_rec.attribute4, hr_api.g_varchar2) or
             nvl(per_pds_shd.g_old_rec.attribute5, hr_api.g_varchar2)  <>
             nvl(p_rec.attribute5, hr_api.g_varchar2) or
             nvl(per_pds_shd.g_old_rec.attribute6, hr_api.g_varchar2)  <>
             nvl(p_rec.attribute6, hr_api.g_varchar2) or
             nvl(per_pds_shd.g_old_rec.attribute7, hr_api.g_varchar2)  <>
             nvl(p_rec.attribute7, hr_api.g_varchar2) or
             nvl(per_pds_shd.g_old_rec.attribute8, hr_api.g_varchar2)  <>
             nvl(p_rec.attribute8, hr_api.g_varchar2) or
             nvl(per_pds_shd.g_old_rec.attribute9, hr_api.g_varchar2)  <>
             nvl(p_rec.attribute9, hr_api.g_varchar2) or
             nvl(per_pds_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
             nvl(p_rec.attribute10, hr_api.g_varchar2) or
             nvl(per_pds_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
             nvl(p_rec.attribute11, hr_api.g_varchar2) or
             nvl(per_pds_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
             nvl(p_rec.attribute12, hr_api.g_varchar2) or
             nvl(per_pds_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
             nvl(p_rec.attribute13, hr_api.g_varchar2) or
             nvl(per_pds_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
             nvl(p_rec.attribute14, hr_api.g_varchar2) or
             nvl(per_pds_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
             nvl(p_rec.attribute15, hr_api.g_varchar2) or
             nvl(per_pds_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
             nvl(p_rec.attribute16, hr_api.g_varchar2) or
             nvl(per_pds_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
             nvl(p_rec.attribute17, hr_api.g_varchar2) or
             nvl(per_pds_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
             nvl(p_rec.attribute18, hr_api.g_varchar2) or
             nvl(per_pds_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
             nvl(p_rec.attribute19, hr_api.g_varchar2) or
             nvl(per_pds_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
             nvl(p_rec.attribute20, hr_api.g_varchar2)
            )
          or
            (
            -- Added the check for date_start and adjusted_svc_date for fix
            --  of #1577252
              ( nvl(per_pds_shd.g_old_rec.adjusted_svc_date, hr_api.g_date) =
                nvl(p_rec.adjusted_svc_date, hr_api.g_date) ) and
              ( nvl(per_pds_shd.g_old_rec.date_start, hr_api.g_date) =
                nvl(p_rec.date_start, hr_api.g_date) ) and
              (p_rec.attribute_category is null) and
              (p_rec.attribute1         is null) and
              (p_rec.attribute2         is null) and
              (p_rec.attribute3         is null) and
              (p_rec.attribute4         is null) and
              (p_rec.attribute5         is null) and
              (p_rec.attribute6         is null) and
              (p_rec.attribute7         is null) and
              (p_rec.attribute8         is null) and
              (p_rec.attribute9         is null) and
              (p_rec.attribute10        is null) and
              (p_rec.attribute11        is null) and
              (p_rec.attribute12        is null) and
              (p_rec.attribute13        is null) and
              (p_rec.attribute14        is null) and
              (p_rec.attribute15        is null) and
              (p_rec.attribute16        is null) and
              (p_rec.attribute17        is null) and
              (p_rec.attribute18        is null) and
              (p_rec.attribute19        is null) and
              (p_rec.attribute20        is null)
            )
          ))
        --  or inserting and required to validate flex
        or
          ((p_rec.period_of_service_id is null) and
           (p_validate_df_flex))
           then
           --
             hr_utility.set_location(l_proc, 20);
--
--           validate flex segment values
--
             hr_dflex_utility.ins_or_upd_descflex_attribs(
                 p_appl_short_name      => 'PER'
                ,p_descflex_name        => 'PER_PERIODS_OF_SERVICE'
                ,p_attribute_category   => p_rec.attribute_category
                ,p_attribute1_name      => 'ATTRIBUTE1'
                ,p_attribute1_value     => p_rec.attribute1
                ,p_attribute2_name      => 'ATTRIBUTE2'
                ,p_attribute2_value     => p_rec.attribute2
                ,p_attribute3_name      => 'ATTRIBUTE3'
                ,p_attribute3_value     => p_rec.attribute3
                ,p_attribute4_name      => 'ATTRIBUTE4'
                ,p_attribute4_value     => p_rec.attribute4
                ,p_attribute5_name      => 'ATTRIBUTE5'
                ,p_attribute5_value     => p_rec.attribute5
                ,p_attribute6_name      => 'ATTRIBUTE6'
                ,p_attribute6_value     => p_rec.attribute6
                ,p_attribute7_name      => 'ATTRIBUTE7'
                ,p_attribute7_value     => p_rec.attribute7
                ,p_attribute8_name      => 'ATTRIBUTE8'
                ,p_attribute8_value     => p_rec.attribute8
                ,p_attribute9_name      => 'ATTRIBUTE9'
                ,p_attribute9_value     => p_rec.attribute9
                ,p_attribute10_name     => 'ATTRIBUTE10'
                ,p_attribute10_value    => p_rec.attribute10
                ,p_attribute11_name     => 'ATTRIBUTE11'
                ,p_attribute11_value    => p_rec.attribute11
                ,p_attribute12_name     => 'ATTRIBUTE12'
                ,p_attribute12_value    => p_rec.attribute12
                ,p_attribute13_name     => 'ATTRIBUTE13'
                ,p_attribute13_value    => p_rec.attribute13
                ,p_attribute14_name     => 'ATTRIBUTE14'
                ,p_attribute14_value    => p_rec.attribute14
                ,p_attribute15_name     => 'ATTRIBUTE15'
                ,p_attribute15_value    => p_rec.attribute15
                ,p_attribute16_name     => 'ATTRIBUTE16'
                ,p_attribute16_value    => p_rec.attribute16
                ,p_attribute17_name     => 'ATTRIBUTE17'
                ,p_attribute17_value    => p_rec.attribute17
                ,p_attribute18_name     => 'ATTRIBUTE18'
                ,p_attribute18_value    => p_rec.attribute18
                ,p_attribute19_name     => 'ATTRIBUTE19'
                ,p_attribute19_value    => p_rec.attribute19
                ,p_attribute20_name     => 'ATTRIBUTE20'
                ,p_attribute20_value    => p_rec.attribute20
                );
       End if;
  --
  hr_utility.set_location('  Leaving:'||l_proc, 30);
--
end chk_df;
--
-- -----------------------------------------------------------------------
-- |------------------------------< chk_ddf >----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Developer Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   second last step from insert_validate and update_validate.
--   Before any Descriptive Flexfield (chk_df) calls.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data
--   values are all valid this procedure will end normally and
--   processing will continue.
--
-- Post Failure:
--   If the DDF structure column value or any of the data values
--   are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_ddf
  (p_rec   in per_pds_shd.g_rec_type) is
--
  l_proc       varchar2(72) := g_package||'chk_ddf';
  l_error      exception;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check if the row is being inserted or updated and a
  -- value has changed
  --
   if (p_rec.period_of_service_id is null) or
      ((p_rec.period_of_service_id is not null) and
     nvl(per_pds_shd.g_old_rec.pds_information_category, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information_category, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information1, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information1, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information2, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information2, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information3, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information3, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information4, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information4, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information5, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information5, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information6, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information6, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information7, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information7, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information8, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information8, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information9, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information9, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information10, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information10, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information11, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information11, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information12, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information12, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information13, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information13, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information14, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information14, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information15, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information15, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information16, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information16, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information17, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information17, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information18, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information18, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information19, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information19, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information20, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information20, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information21, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information21, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information22, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information22, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information23, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information23, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information24, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information24, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information25, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information25, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information26, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information26, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information27, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information27, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information28, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information28, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information29, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information29, hr_api.g_varchar2) or
     nvl(per_pds_shd.g_old_rec.pds_information30, hr_api.g_varchar2) <>
     nvl(p_rec.pds_information30, hr_api.g_varchar2))  then
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_PDS_DEVELOPER_DF'
      ,p_attribute_category => p_rec.pds_information_category
      ,p_attribute1_name    => 'PDS_INFORMATION1'
      ,p_attribute1_value   => p_rec.pds_information1
      ,p_attribute2_name    => 'PDS_INFORMATION2'
      ,p_attribute2_value   => p_rec.pds_information2
      ,p_attribute3_name    => 'PDS_INFORMATION3'
      ,p_attribute3_value   => p_rec.pds_information3
      ,p_attribute4_name    => 'PDS_INFORMATION4'
      ,p_attribute4_value   => p_rec.pds_information4
      ,p_attribute5_name    => 'PDS_INFORMATION5'
      ,p_attribute5_value   => p_rec.pds_information5
      ,p_attribute6_name    => 'PDS_INFORMATION6'
      ,p_attribute6_value   => p_rec.pds_information6
      ,p_attribute7_name    => 'PDS_INFORMATION7'
      ,p_attribute7_value   => p_rec.pds_information7
      ,p_attribute8_name    => 'PDS_INFORMATION8'
      ,p_attribute8_value   => p_rec.pds_information8
      ,p_attribute9_name    => 'PDS_INFORMATION9'
      ,p_attribute9_value   => p_rec.pds_information9
      ,p_attribute10_name   => 'PDS_INFORMATION10'
      ,p_attribute10_value  => p_rec.pds_information10
      ,p_attribute11_name   => 'PDS_INFORMATION11'
      ,p_attribute11_value  => p_rec.pds_information11
      ,p_attribute12_name   => 'PDS_INFORMATION12'
      ,p_attribute12_value  => p_rec.pds_information12
      ,p_attribute13_name   => 'PDS_INFORMATION13'
      ,p_attribute13_value  => p_rec.pds_information13
      ,p_attribute14_name   => 'PDS_INFORMATION14'
      ,p_attribute14_value  => p_rec.pds_information14
      ,p_attribute15_name   => 'PDS_INFORMATION15'
      ,p_attribute15_value  => p_rec.pds_information15
      ,p_attribute16_name   => 'PDS_INFORMATION16'
      ,p_attribute16_value  => p_rec.pds_information16
      ,p_attribute17_name   => 'PDS_INFORMATION17'
      ,p_attribute17_value  => p_rec.pds_information17
      ,p_attribute18_name   => 'PDS_INFORMATION18'
      ,p_attribute18_value  => p_rec.pds_information18
      ,p_attribute19_name   => 'PDS_INFORMATION19'
      ,p_attribute19_value  => p_rec.pds_information19
      ,p_attribute20_name   => 'PDS_INFORMATION20'
      ,p_attribute20_value  => p_rec.pds_information20
      ,p_attribute21_name   => 'PDS_INFORMATION21'
      ,p_attribute21_value  => p_rec.pds_information21
      ,p_attribute22_name   => 'PDS_INFORMATION22'
      ,p_attribute22_value  => p_rec.pds_information22
      ,p_attribute23_name   => 'PDS_INFORMATION23'
      ,p_attribute23_value  => p_rec.pds_information23
      ,p_attribute24_name   => 'PDS_INFORMATION24'
      ,p_attribute24_value  => p_rec.pds_information24
      ,p_attribute25_name   => 'PDS_INFORMATION25'
      ,p_attribute25_value  => p_rec.pds_information25
      ,p_attribute26_name   => 'PDS_INFORMATION26'
      ,p_attribute26_value  => p_rec.pds_information26
      ,p_attribute27_name   => 'PDS_INFORMATION27'
      ,p_attribute27_value  => p_rec.pds_information27
      ,p_attribute28_name   => 'PDS_INFORMATION28'
      ,p_attribute28_value  => p_rec.pds_information28
      ,p_attribute29_name   => 'PDS_INFORMATION29'
      ,p_attribute29_value  => p_rec.pds_information29
      ,p_attribute30_name   => 'PDS_INFORMATION30'
      ,p_attribute30_value  => p_rec.pds_information30
      );
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end chk_ddf;
--
-- ---------------------------------------------------------------------------  -- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec              in per_pds_shd.g_rec_type
                         ,p_effective_date   in date
                         ,p_validate_df_flex in boolean) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Call all supporting business operations. Mapping to the appropriate
  -- Business Rules in perpds.bru is provided.
  --
  -- Validate business group id
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_BUSINESS_GROUP_ID / a,c
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(l_proc, 2);
  --
  --
  -- Validate date start
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_DATE_START / a
  --
  per_pds_bus.chk_date_start(p_date_start => p_rec.date_start);
  --
  hr_utility.set_location(l_proc, 3);
  --
  --
  -- Validate person id
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PERSON_ID / a,c
  --
  per_pds_bus.chk_person_id
    (p_person_id                   => p_rec.person_id,
     p_termination_accepted_person => p_rec.termination_accepted_person_id);
  --
  hr_utility.set_location(l_proc, 4);
  --
  --
  -- Validate date start
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_DATE_START / a
  --
  per_pds_bus.chk_date_start(p_date_start => p_rec.date_start);
  --
  hr_utility.set_location(l_proc, 5);
  --
  --
  -- Validate person id and date start combination
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PERSON_ID_DATE_START / a,b
  --
  per_pds_bus.chk_person_id_date_start
    (p_period_of_service_id  => p_rec.period_of_service_id,
     p_object_version_number => p_rec.object_version_number,
     p_person_id             => p_rec.person_id,
     p_date_start            => p_rec.date_start);
  --
  hr_utility.set_location(l_proc, 6);
  --
  --
  -- Validate accepted termination date
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ACCEPTED_TERMINATION_DATE / a
  --
  per_pds_bus.chk_accepted_termination_date
    (p_accepted_termination_date => p_rec.accepted_termination_date);
  --
  hr_utility.set_location(l_proc, 7);
  --
  --
  -- Validate actual termination date
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ACTUAL_TERMINATION_DATE / c
  --
  -- 70.3 change a start.
  --
  per_pds_bus.chk_actual_termination_date
    (p_actual_termination_date    => p_rec.actual_termination_date
    ,p_date_start                 => p_rec.date_start
    ,p_last_standard_process_date => p_rec.last_standard_process_date
    ,p_object_version_number      => p_rec.object_version_number
    ,p_period_of_service_id       => p_rec.period_of_service_id
    ,p_person_id                  => p_rec.person_id);
  --
  -- 70.3 change a end.
  --
  hr_utility.set_location(l_proc, 8);
  --
  --
  -- Validate last standard process date
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_LAST_STANDARD_PROCESS_DATE / e
  --
  -- 70.3 change c start.
  --
  per_pds_bus.chk_last_standard_process_date
    (p_actual_termination_date    => p_rec.actual_termination_date
    ,p_business_group_id          => p_rec.business_group_id
    ,p_date_start                 => p_rec.date_start
    ,p_last_standard_process_date => p_rec.last_standard_process_date
    ,p_object_version_number      => p_rec.object_version_number
    ,p_period_of_service_id       => p_rec.period_of_service_id
    );
  hr_utility.set_location(l_proc, 9);
  --
  --
  -- Validate final process date
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_FINAL_PROCESS_DATE / e
  --
  per_pds_bus.chk_final_process_date
    (p_actual_termination_date    => p_rec.actual_termination_date,
     p_date_start                 => p_rec.date_start,
     p_final_process_date         => p_rec.final_process_date,
     p_last_standard_process_date => p_rec.last_standard_process_date,
     p_object_version_number      => p_rec.object_version_number,
     p_period_of_service_id       => p_rec.period_of_service_id);
  --
  --
  -- 70.3 change c end.
  --
  hr_utility.set_location(l_proc, 10);
  --
  --
  -- Validate leaving reason
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_LEAVING_REASON / b
  --
  per_pds_bus.chk_leaving_reason
    (p_leaving_reason        => p_rec.leaving_reason,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number,
     p_period_of_service_id  => p_rec.period_of_service_id);
  --
  hr_utility.set_location(l_proc, 11);
  --
  --
  -- Validate notified termination date
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_NOTIFIED_TERMINATION_DATE / a
  --
  per_pds_bus.chk_notified_termination_date
    (p_date_start                 => p_rec.date_start,
     p_notified_termination_date  => p_rec.notified_termination_date,
     p_object_version_number      => p_rec.object_version_number,
     p_period_of_service_id       => p_rec.period_of_service_id);
  --
  hr_utility.set_location(l_proc, 12);
  --
  --
  -- Validate projected termination date
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PROJECTED_TERMINATION_DATE / a,b
  --
  per_pds_bus.chk_projected_termination_date
    (p_date_start                 => p_rec.date_start,
     p_period_of_service_id       => p_rec.period_of_service_id,
     p_object_version_number      => p_rec.object_version_number,
     p_projected_termination_date => p_rec.projected_termination_date);
  --
  hr_utility.set_location(l_proc, 13);
  --
  --
  -- Validate termination accepted person id
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_TERMINATION_ACCEPTED_PERSON_ID / b,c
  --
  per_pds_bus.chk_termination_accepted_pers
    (p_accepted_termination_date   => p_rec.accepted_termination_date,
     p_object_version_number       => p_rec.object_version_number,
     p_period_of_service_id        => p_rec.period_of_service_id,
     p_person_id                   => p_rec.person_id,
     p_termination_accepted_person => p_rec.termination_accepted_person_id,
     p_effective_date              => p_effective_date);
  --
  -- Validate descriptive flex fields.
  --
  per_pds_bus.chk_ddf(p_rec => p_rec);
  --
  --
  -- Validate flex fields.
  --
        per_pds_bus.chk_df(p_rec              => p_rec
                          ,p_validate_df_flex => p_validate_df_flex);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 14);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_pds_shd.g_rec_type
			 ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Check that the columns which cannot be updated have not changed.
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_BUSINESS_GROUP_ID / b
  -- CHK_PERIOD_OF_SERVICE_ID / c
  -- CHK_PERSON_ID / c
  --
  check_non_updateable_args(p_rec => p_rec);
  --
  hr_utility.set_location(l_proc, 2);
  --
  --
  -- Call all supporting business operations
  --
  -- Validate business group id
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_BUSINESS_GROUP_ID / a,c
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(l_proc, 3);
  --
  --
  -- Validate date start
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_DATE_START / a
  --
  per_pds_bus.chk_date_start(p_date_start => p_rec.date_start);
  --
  hr_utility.set_location(l_proc, 4);
  --
  --
  -- Validate person id and date start combination
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PERSON_ID_DATE_START / a,b
  --
  per_pds_bus.chk_person_id_date_start
    (p_period_of_service_id  => p_rec.period_of_service_id,
     p_object_version_number => p_rec.object_version_number,
     p_person_id             => p_rec.person_id,
     p_date_start            => p_rec.date_start);
  --
  hr_utility.set_location(l_proc, 5);
  --
  --
  -- Validate actual termination date
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ACTUAL_TERMINATION_DATE / a,b,d,e,f
  --
  -- 70.3 change a start.
  --
  per_pds_bus.chk_actual_termination_date
    (p_actual_termination_date    => p_rec.actual_termination_date
    ,p_date_start                 => p_rec.date_start
    ,p_last_standard_process_date => p_rec.last_standard_process_date
    ,p_object_version_number      => p_rec.object_version_number
    ,p_period_of_service_id       => p_rec.period_of_service_id
    ,p_person_id                  => p_rec.person_id);
  --
  -- 70.3 change a end.
  --
  hr_utility.set_location(l_proc, 6);
  --
  --
  -- Validate last standard process date
  --
  -- Business Rule Mapping
  -- =====================
  --
  -- 70.3 change c start.
  --
  -- CHK_LAST_STANDARD_PROCESS_DATE / a,b,c,f,g,i
  --
  per_pds_bus.chk_last_standard_process_date
    (p_actual_termination_date    => p_rec.actual_termination_date
    ,p_business_group_id          => p_rec.business_group_id
    ,p_date_start                 => p_rec.date_start
    ,p_last_standard_process_date => p_rec.last_standard_process_date
    ,p_object_version_number      => p_rec.object_version_number
    ,p_period_of_service_id       => p_rec.period_of_service_id
    );
  hr_utility.set_location(l_proc, 7);
  --
  -- Validate actual termination date/last standard process date
  --
  -- Business Rule Mapping
  -- =====================
  -- Commenting out this routine for fix of bug# 2784295
  -- CHK_LAST_STANDARD_PROCESS_DATE / h
  --
 /* per_pds_bus.chk_at_date_lsp_date
    (p_actual_termination_date    => p_rec.actual_termination_date
    ,p_last_standard_process_date => p_rec.last_standard_process_date
    ,p_object_version_number      => p_rec.object_version_number
    ,p_period_of_service_id       => p_rec.period_of_service_id
    ,p_business_group_id          => p_rec.business_group_id
    );
    hr_utility.set_location(l_proc, 8); */
  --
  -- Validate final process date
  --
  -- Business Rule Mapping
  -- =====================
  --
  -- 70.4 change a start.
  --
  -- CHK_FINAL_PROCESS_DATE / c,d
  --
  -- 70.4 change a end.
  --
  per_pds_bus.chk_final_process_date
    (p_actual_termination_date    => p_rec.actual_termination_date,
     p_date_start                 => p_rec.date_start,
     p_final_process_date         => p_rec.final_process_date,
     p_last_standard_process_date => p_rec.last_standard_process_date,
     p_object_version_number      => p_rec.object_version_number,
     p_period_of_service_id       => p_rec.period_of_service_id);
  --
  --
  -- 70.3 change c end.
  --
  hr_utility.set_location(l_proc, 9);
  --
  --
  -- Validate leaving reason
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_LEAVING_REASON / a
  --
  per_pds_bus.chk_leaving_reason
    (p_leaving_reason        => p_rec.leaving_reason,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number,
     p_period_of_service_id  => p_rec.period_of_service_id);
  --
  hr_utility.set_location(l_proc, 10);
  --
  --
  -- Validate notified termination date
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_NOTIFIED_TERMINATION_DATE / b
  --
  per_pds_bus.chk_notified_termination_date
    (p_date_start                 => p_rec.date_start,
     p_notified_termination_date  => p_rec.notified_termination_date,
     p_object_version_number      => p_rec.object_version_number,
     p_period_of_service_id       => p_rec.period_of_service_id);
  --
  hr_utility.set_location(l_proc, 11);
  --
  --
  -- Validate projected termination date
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PROJECTED_TERMINATION_DATE / b
  --
  per_pds_bus.chk_projected_termination_date
    (p_date_start                 => p_rec.date_start,
     p_period_of_service_id       => p_rec.period_of_service_id,
     p_object_version_number      => p_rec.object_version_number,
     p_projected_termination_date => p_rec.projected_termination_date);
  --
  hr_utility.set_location(l_proc, 12);
  --
  --
  -- Validate termination accepted person id
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_TERMINATION_ACCEPTED_PERSON_ID / a,b
  --
  per_pds_bus.chk_termination_accepted_pers
    (p_accepted_termination_date   => p_rec.accepted_termination_date,
     p_object_version_number       => p_rec.object_version_number,
     p_period_of_service_id        => p_rec.period_of_service_id,
     p_person_id                   => p_rec.person_id,
     p_termination_accepted_person => p_rec.termination_accepted_person_id,
     p_effective_date              => p_effective_date);
  --
  --
  -- Validate descriptive flex fields.
  --
  per_pds_bus.chk_ddf(p_rec => p_rec);
  --
  --
  -- Validate flex fields.
  --
   per_pds_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 13);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_pds_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_period_of_service_id              in number
  ) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups  pbg
         , per_periods_of_service pds
     where pds.period_of_service_id         = p_period_of_service_id
       and pbg.business_group_id = pds.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'period_of_service_id',
                             p_argument_value => p_period_of_service_id);
  --
  if nvl(g_period_of_service_id, hr_api.g_number) = p_period_of_service_id then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    if csr_leg_code%notfound then
      close csr_leg_code;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
    end if;
    --
    -- Set the global variables so the values are
    -- available for the next call to this function
    --
    close csr_leg_code;
    g_period_of_service_id    := p_period_of_service_id;
    g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
end return_legislation_code;
--
end per_pds_bus;

/
