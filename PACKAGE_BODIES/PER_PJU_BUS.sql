--------------------------------------------------------
--  DDL for Package Body PER_PJU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PJU_BUS" as
/* $Header: pepjurhi.pkb 115.14 2002/12/04 10:55:38 eumenyio ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pju_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_previous_job_usage_id       number         default null;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_previous_employer_id >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that previous_employer_id is valid.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_previous_employer_id
--  p_previous_job_usage_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if previous_employer_id is valid
--
--
-- Post Failure:
--   An application error is raised if previous_employer_id is not valid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_previous_employer_id
          (p_previous_employer_id
           in  per_previous_employers.previous_employer_id%type
          ,p_previous_job_usage_id
           in  per_previous_job_usages.previous_job_usage_id%type
          ,p_object_version_number
           in  per_previous_job_usages.object_version_number%type) is
  cursor csr_previous_employer_id is
    select previous_employer_id
    from   per_previous_employers
    where  previous_employer_id = p_previous_employer_id
    and    all_assignments = 'N';
  l_previous_employer_id  per_previous_employers.previous_employer_id%type;
  --
  l_proc          varchar2(72) := g_package||'chk_previous_employer_id';
  l_api_updating  boolean;
begin
   hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(l_proc, 10);
  if p_previous_employer_id is not null then
    l_api_updating    := per_pju_shd.api_updating(p_previous_job_usage_id
                                                  =>  p_previous_job_usage_id
                                                 ,p_object_version_number
                                                  =>  p_object_version_number
                                                 );
    if  ((l_api_updating
        and nvl(per_pju_shd.g_old_rec.previous_employer_id, hr_api.g_number)
            <> nvl(p_previous_employer_id,hr_api.g_number))
      or
      (not l_api_updating)) then
      hr_utility.set_location(l_proc, 15);
      open  csr_previous_employer_id;
      fetch csr_previous_employer_id into l_previous_employer_id;
      if csr_previous_employer_id%notfound then
        hr_utility.set_location(l_proc, 20);
        close csr_previous_employer_id;
        fnd_message.set_name('PER','HR_289537_PJO_VALID_PR_EMPR_ID');
        fnd_message.raise_error;
      end if;
      if csr_previous_employer_id%isopen then
        close csr_previous_employer_id;
      end if;
    end if;
  end if;
  --
   hr_utility.set_location('Leaving:'||l_proc, 25);
exception
  when others then
    raise;
end chk_previous_employer_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_previous_job_id >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that previous_job_id is valid.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_previous_job_id
--  p_previous_job_usage_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if previous_job_id is valid with all assignments
--   is set to "N"
--
--
-- Post Failure:
--   An application error is raised if previous_job_id is not valid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_previous_job_id
     (p_previous_job_id
      in  per_previous_jobs.previous_job_id%type
     ,p_previous_job_usage_id
      in  per_previous_job_usages.previous_job_usage_id%type
     ,p_object_version_number
      in  per_previous_job_usages.object_version_number%type) is
  cursor csr_previous_job_id is
    select  previous_job_id
    from    per_previous_jobs
    where   previous_job_id = p_previous_job_id
    and     all_assignments = 'N';
  l_previous_job_id per_previous_jobs.previous_job_id%type;
  --
  l_proc          varchar2(72) := g_package||'chk_previous_job_id';
  l_api_updating  boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(l_proc, 10);
  if p_previous_job_id is not null then
    l_api_updating    := per_pju_shd.api_updating(p_previous_job_usage_id
                                                  =>  p_previous_job_usage_id
                                                 ,p_object_version_number
                                                  =>  p_object_version_number
                                                 );
    if  ((l_api_updating
        and nvl(per_pju_shd.g_old_rec.previous_job_id, hr_api.g_number)
            <> nvl(p_previous_job_id,hr_api.g_number))
      or
      (not l_api_updating)) then
      hr_utility.set_location(l_proc, 15);
      open  csr_previous_job_id;
      fetch csr_previous_job_id into  l_previous_job_id;
      if csr_previous_job_id%notfound then
        hr_utility.set_location(l_proc, 20);
        close csr_previous_job_id;
        fnd_message.set_name('PER','HR_289540_PJI_INV_PREV_JOB_ID');
        fnd_message.raise_error;
      end if;
      if csr_previous_job_id%isopen then
        close csr_previous_job_id;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 25);
exception
  when others then
    raise;
end chk_previous_job_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_assignment_id >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that assignment_id is valid
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_previous_job_usage_id
--  p_object_version_number
--  p_all_assignments
--
-- Post Success:
--   Processing continues if assignment_id is valid for the current period.
--
--
-- Post Failure:
--   An application error is raised if assignment_id is not valid for the
--   current period
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_assignment_id
      (p_previous_job_usage_id
      in  per_previous_job_usages.previous_job_usage_id%type
      ,p_object_version_number
      in  per_previous_job_usages.object_version_number%type
      ,p_assignment_id
      in  per_previous_job_usages.assignment_id%type) is
  cursor csr_assignment_id is
    select  assignment_id
    from    per_all_assignments_f
    where   assignment_id = p_assignment_id;
  l_assignment_id   per_previous_job_usages.assignment_id%type;
  --
  l_proc            varchar2(72) := g_package||'chk_assignment_id';
  l_api_updating    boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(l_proc, 10);
    l_api_updating    := per_pju_shd.api_updating(p_previous_job_usage_id
                                                =>  p_previous_job_usage_id
                                               ,p_object_version_number
                                               =>  p_object_version_number
                                               );
    if  ((l_api_updating
        and nvl(per_pju_shd.g_old_rec.assignment_id, hr_api.g_number)
            <> nvl(p_assignment_id,hr_api.g_number))
      or
      (not l_api_updating)) then
        hr_utility.set_location(l_proc, 15);
        -- Check for valid Assignment ID.
        open  csr_assignment_id;
         fetch csr_assignment_id into l_assignment_id;
         if csr_assignment_id%notfound then
           hr_utility.set_location(l_proc, 20);
           close csr_assignment_id;
           fnd_message.set_name('PER','HR_289541_PJU_INV_ASG_ID');
           fnd_message.raise_error;
         end if;
         if csr_assignment_id%isopen then
           close csr_assignment_id;
         end if;
    end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 30);
exception
  when others then
    raise;
end chk_assignment_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_valid_job_dates>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that end_date is greater than start_date
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_previous_job_usage_id
--  p_object_version_number
--  p_start_date
--  p_end_date
--
-- Post Success:
--   Processing continues if end_date is greater than start_date
--
--
-- Post Failure:
--   An application error is raised if start_date is greater than end_date
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_valid_job_dates
          (p_previous_job_usage_id
           in  per_previous_job_usages.previous_job_usage_id%type
          ,p_object_version_number
           in  per_previous_job_usages.object_version_number%type
          ,p_start_date
           in  per_previous_job_usages.start_date%type
          ,p_end_date
           in  per_previous_job_usages.end_date%type) is
  l_proc            varchar2(72) := g_package||'chk_valid_job_dates';
  l_api_updating    boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_start_date is not null and p_end_date is not null then
    hr_utility.set_location(l_proc, 10);
    l_api_updating    := per_pju_shd.api_updating(p_previous_job_usage_id
                                                  =>  p_previous_job_usage_id
                                                 ,p_object_version_number
                                                  =>  p_object_version_number
                                                 );
    if  ((l_api_updating
          and (nvl(per_pju_shd.g_old_rec.start_date, hr_api.g_sot)
              <> nvl(p_start_date,hr_api.g_sot)
              or
              nvl(per_pju_shd.g_old_rec.end_date, hr_api.g_eot)
              <> nvl(p_end_date,hr_api.g_eot))
              )
        or
        (not l_api_updating)) then
          hr_utility.set_location(l_proc, 15);
          if nvl(p_start_date,hr_api.g_sot) > nvl(p_end_date,hr_api.g_eot) then
            hr_utility.set_location(l_proc, 20);
            fnd_message.set_name('PER','HR_289530_PEM_STRT_END_DATES');
            fnd_message.set_token('START_DATE',TO_CHAR(p_start_date,'DD-MON-YYYY'),true);
            fnd_message.set_token('END_DATE',TO_CHAR(p_end_date,'DD-MON-YYYY'),true);
            fnd_message.raise_error;
          end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 25);
exception
      when others then
    raise;
end chk_valid_job_dates;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_period_years >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that period_years is with in the range 0 and 99.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_period_years
--  p_previous_job_usage_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if period_years is out of 0 and 99 range.
--
--
-- Post Failure:
--   An application error is raised if period_years range is out of 0 and 99.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_period_years
          (p_period_years
           in per_previous_job_usages.period_years%type
          ,p_previous_job_usage_id
           in  per_previous_job_usages.previous_job_usage_id%type
          ,p_object_version_number
           in  per_previous_job_usages.object_version_number%type) is
  l_proc          varchar2(72) := g_package||'chk_period_years';
  l_api_updating  boolean;
begin
   hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_period_years is not null then
    hr_utility.set_location(l_proc, 10);
    l_api_updating := per_pju_shd.api_updating(p_previous_job_usage_id
                                            =>  p_previous_job_usage_id
                                            ,p_object_version_number
                                            =>  p_object_version_number);
    hr_utility.set_location(l_proc, 15);
    if ((l_api_updating and
        (   nvl(p_period_years,hr_api.g_number)
            <> nvl(per_pju_shd.g_old_rec.period_years,hr_api.g_number)
        )
       ) or
       (not l_api_updating)) then
    hr_utility.set_location(l_proc, 20);
      if   p_period_years not between 0 and 99 then
          hr_utility.set_location(l_proc, 25);
          fnd_message.set_name('PER','HR_289534_PEM_VALID_PRD_RANGE');
          fnd_message.set_token('RANGE_START',0,true);
          fnd_message.set_token('RANGE_END',99,true);
          fnd_message.raise_error;
      end if;
    end if;
  end if;
  --
   hr_utility.set_location('Leaving:'||l_proc, 30);
exception
  when others then
    raise;
end chk_period_years;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_period_months >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that period_months is with in the range 0 and 11.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_period_months
--  p_previous_job_usage_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if period_months is out of 0 and 11 range.
--
--
-- Post Failure:
--   An application error is raised if period_months range is out of 0 and 11.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_period_months
          (p_period_months
           in  per_previous_job_usages.period_months%type
          ,p_previous_job_usage_id
           in  per_previous_job_usages.previous_job_usage_id%type
          ,p_object_version_number
           in  per_previous_job_usages.object_version_number%type) is
  l_proc          varchar2(72) := g_package||'chk_period_months';
  l_api_updating  boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_period_months is not null then
    hr_utility.set_location(l_proc, 10);
    l_api_updating := per_pju_shd.api_updating(p_previous_job_usage_id
                                            =>  p_previous_job_usage_id
                                            ,p_object_version_number
                                            =>  p_object_version_number);
    hr_utility.set_location(l_proc, 15);
    if ((l_api_updating and
        (   nvl(p_period_months ,hr_api.g_number)
            <> nvl(per_pju_shd.g_old_rec.period_months ,hr_api.g_number)
        )
       ) or
       (not l_api_updating)) then
      hr_utility.set_location(l_proc, 20);
      if p_period_months not between 0 and 11 then
        hr_utility.set_location(l_proc, 25);
        fnd_message.set_name('PER','HR_289534_PEM_VALID_PRD_RANGE');
        fnd_message.set_token('RANGE_START',0,true);
        fnd_message.set_token('RANGE_END',11,true);
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 30);
exception
  when others then
    raise;
end chk_period_months;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_period_days >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that period_days is with in the range 0 and 365.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_period_days
--  p_previous_job_usage_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if period_days is out of 0 and 365 range.
--
--
-- Post Failure:
--   An application error is raised if period_days range is out of 0 and 365.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_period_days
          (p_period_days
           in  per_previous_job_usages.period_days%type
          ,p_previous_job_usage_id
           in  per_previous_job_usages.previous_job_usage_id%type
          ,p_object_version_number
           in  per_previous_job_usages.object_version_number%type) is
  l_proc          varchar2(72) := g_package||'chk_period_days';
  l_api_updating  boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_period_days is not null then
    hr_utility.set_location(l_proc, 10);
    l_api_updating := per_pju_shd.api_updating(p_previous_job_usage_id
                                            =>  p_previous_job_usage_id
                                            ,p_object_version_number
                                            =>  p_object_version_number);
    hr_utility.set_location(l_proc, 15);
    if ((l_api_updating and
        (   nvl(p_period_days ,hr_api.g_number)
            <> nvl(per_pju_shd.g_old_rec.period_days ,hr_api.g_number)
        )
       ) or
       (not l_api_updating)) then
      hr_utility.set_location(l_proc, 20);
      if p_period_days not between 0 and 365 then
         hr_utility.set_location(l_proc, 25);
         fnd_message.set_name('PER','HR_289534_PEM_VALID_PRD_RANGE');
         fnd_message.set_token('RANGE_START',0,true);
         fnd_message.set_token('RANGE_END',365,true);
         fnd_message.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 30);
exception
  when others then
    raise;
end chk_period_days;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_pju_start_end_dates >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that start_date and end_date is with in the range
--   of start_date and end_date of previous_employer with which the assignment
--   is mapped to.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_previous_job_usage_id
--  p_object_version_number
--  p_previous_employer_id
--  p_start_date
--  p_end_date
--
-- Post Success:
--   Processing continues if start_date and end_date are with in start_date
--   and end_date of previous_employer.
--
--
-- Post Failure:
--   An application error is raised if start_date or end_date is out of
--   the range of previous_employer mapped to this assignment.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_pju_start_end_dates
          (p_previous_job_usage_id
          in  per_previous_job_usages.previous_job_usage_id%type
          ,p_object_version_number
          in  per_previous_job_usages.object_version_number%type
          ,p_previous_employer_id
          in  per_previous_job_usages.previous_employer_id%type
          ,p_start_date
          in  per_previous_job_usages.start_date%type
          ,p_end_date
          in  per_previous_job_usages.end_date%type) is
  cursor csr_pem_start_end_dates is
    select  previous_employer_id
    from    per_previous_employers
    where   previous_employer_id = p_previous_employer_id
    and     (  p_start_date not between nvl(start_date,hr_api.g_sot)
                                and nvl(end_date,hr_api.g_eot)
            or p_end_date not between nvl(start_date,hr_api.g_sot)
                              and nvl(end_date,hr_api.g_eot));
  l_previous_employer_id  per_previous_employers.previous_employer_id%type;
  --
  l_api_updating    boolean;
  l_proc            varchar2(72) := g_package||'chk_pju_start_end_dates';
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_start_date is not null or p_end_date is not null then
    hr_utility.set_location(l_proc, 10);
    l_api_updating    := per_pju_shd.api_updating(p_previous_job_usage_id
                                                  =>  p_previous_job_usage_id
                                                 ,p_object_version_number
                                                  =>  p_object_version_number
                                                 );
    if  ((l_api_updating
          and (nvl(per_pju_shd.g_old_rec.start_date, hr_api.g_sot)
                   <> nvl(p_start_date,hr_api.g_sot)
              or
              nvl(per_pju_shd.g_old_rec.end_date, hr_api.g_eot)
              <> nvl(p_end_date,hr_api.g_eot))
              )
        or
        (not l_api_updating)) then
          hr_utility.set_location(l_proc, 15);
          open  csr_pem_start_end_dates;
          fetch   csr_pem_start_end_dates into l_previous_employer_id;
          if csr_pem_start_end_dates%found then
            hr_utility.set_location(l_proc, 20);
            close csr_pem_start_end_dates;
            fnd_message.set_name('PER','HR_289550_PJU_DATES');
            fnd_message.raise_error;
          end if;
          if csr_pem_start_end_dates%isopen then
            close csr_pem_start_end_dates;
          end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 25);
exception
  when others then
    raise;
end chk_pju_start_end_dates;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_assignment_job >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure ensures that the assignment and job mappings are not
-- duplicated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_previous_job_usage_id
--  p_object_version_number
--  p_previous_job_id
--  p_assignment_id
--
-- Post Success:
--   Processing continues if there is no record already existing with the
--   same assignment_id and previous_job_id
--
--
-- Post Failure:
--   An application error is raised if assignment_id and previous_job_id
--   is already existing in the table.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_assignment_job
          (p_previous_job_usage_id
           in  per_previous_job_usages.previous_employer_id%type
          ,p_object_version_number
           in  per_previous_job_usages.object_version_number%type
          ,p_previous_job_id
           in  per_previous_job_usages.previous_job_id%type
          ,p_assignment_id
           in  per_previous_job_usages.assignment_id%type
          ) is
  -- Declare local cursors.
  cursor csr_asg_job is
    select  previous_job_usage_id
    from    per_previous_job_usages
    where   assignment_id   = p_assignment_id
    and     previous_job_id = p_previous_job_id;
  -- Declare local variables
  l_previous_job_usage_id per_previous_job_usages.previous_job_usage_id%type;
  l_proc          varchar2(72) := g_package||'chk_assignment_job';
  l_api_updating  boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating    := per_pju_shd.api_updating(p_previous_job_usage_id
                                                =>  p_previous_job_usage_id
                                               ,p_object_version_number
                                                =>  p_object_version_number
                                               );
  if  ((l_api_updating
      and (nvl(per_pju_shd.g_old_rec.assignment_id, hr_api.g_number)
           <> nvl(p_assignment_id,hr_api.g_number)
           or nvl(per_pju_shd.g_old_rec.previous_job_id, hr_api.g_number)
           <> nvl(p_previous_job_id, hr_api.g_number)
          )
        )
      or
      (not l_api_updating)) then
        hr_utility.set_location(l_proc, 15);
        open csr_asg_job;
        fetch csr_asg_job into l_previous_job_usage_id;
        if not csr_asg_job%notfound then
          hr_utility.set_location(l_proc, 10);
          close csr_asg_job;
          fnd_message.set_name('PER','HR_289551_PJU_ASG_JOB_DUP');
          fnd_message.raise_error;
        end if;
        if csr_asg_job%isopen then
          hr_utility.set_location(l_proc, 15);
          close csr_asg_job;
        end if;
  end if;
--
hr_utility.set_location(l_proc, 20);
--
exception
  when others then
    raise;
end chk_assignment_job;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_previous_job_dates >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure fetches the default values for the per_previous_job_usages
-- table. The default values are start_date,end_date,period_years,
-- period_months,period_days.
--
-- In Arguments:
--  p_previous_employer_id
--  p_previous_job_id
--  p_start_date
--  p_end_date
--  p_period_years
--  p_period_months
--  p_period_days
--
-- Post Success:
--   The default values are set into the out parameters.
--
--
-- Post Failure:
--   An application error is raised if previous_job_id is not existing
--   in per_previous_jobs
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure get_previous_job_dates
          (p_previous_employer_id
           in  per_previous_job_usages.previous_employer_id%type
          ,p_previous_job_id
           in  per_previous_job_usages.previous_job_id%type
          ,p_start_date
           out nocopy per_previous_job_usages.start_date%type
          ,p_end_date
           out nocopy per_previous_job_usages.end_date%type
          ,p_period_years
           out nocopy per_previous_job_usages.period_years%type
          ,p_period_months
           out nocopy per_previous_job_usages.period_months%type
          ,p_period_days
           out nocopy per_previous_job_usages.period_days%type
          ) is
-- Declare local variables
  l_proc   varchar2(72) := g_package||'get_previous_job_dates';
-- Declare local cursor
  cursor csr_previous_job_dates is
  select start_date
        ,end_date
        ,period_years
        ,period_months
        ,period_days
  from   per_previous_jobs pjo
  where  pjo.previous_employer_id = p_previous_employer_id
  and    pjo.previous_job_id      = p_previous_job_id;
--
begin
  hr_utility.set_location('Entering : '||l_proc, 5);
  if p_previous_employer_id is not null and p_previous_job_id is not null then
    hr_utility.set_location(l_proc, 10);
    open   csr_previous_job_dates;
    fetch  csr_previous_job_dates into  p_start_date
                                       ,p_end_date
                                       ,p_period_years
                                       ,p_period_months
                                       ,p_period_days;
    hr_utility.set_location(l_proc, 15);
    if csr_previous_job_dates%notfound then
       hr_utility.set_location(l_proc, 20);
       close csr_previous_job_dates;
       fnd_message.set_name('PER','HR_289540_PJI_INV_PREV_JOB_ID');
       fnd_message.raise_error;
    end if;
    if csr_previous_job_dates%isopen then
       hr_utility.set_location(l_proc, 25);
       close csr_previous_job_dates;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving : '||l_proc, 30);
  --
end get_previous_job_dates;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_asg_job_start_date >-------------------------|
--  ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure checks the start_date of the previous job should be before
-- the effective_start_date of the assignment to which it is mapped.
--
-- In Arguments:
--  p_previous_job_usage_id
--  p_object_version_number
--  p_assignment_id
--  p_previous_job_id
--
-- Post Success:
--   Proceeds with the process
--
--
-- Post Failure:
--   An application error is raised if start_date of the previous job is not
--   before the effective_start_date of the assignment to which the
--   previous job is mapped.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_asg_job_start_date
          (p_previous_job_usage_id
           in  per_previous_job_usages.previous_job_usage_id%type
          ,p_object_version_number
           in  per_previous_job_usages.object_version_number%type
          ,p_assignment_id
           in  per_previous_job_usages.assignment_id%type
          ,p_previous_job_id
           in  per_previous_job_usages.previous_job_id%type
          )
is
  -- Declare local procedure name
  l_proc          varchar2(72) := g_package||'chk_asg_job_start_date';
  -- Declare local cursors
  cursor csr_asg_job_start_date is
  select 'x' from  per_previous_jobs pjo
                  ,per_all_assignments_f asg
  where pjo.start_date >= asg.effective_start_date
  and   pjo.previous_job_id = p_previous_job_id
  and   asg.assignment_id   = p_assignment_id;
  -- Declare local variables
  l_x             varchar2(10);
  l_api_updating  boolean;
  --
begin
  if p_assignment_id is not null and p_previous_job_id is not null then
    l_api_updating    := per_pju_shd.api_updating(p_previous_job_usage_id
                                                  =>  p_previous_job_usage_id
                                                 ,p_object_version_number
                                                  =>  p_object_version_number
                                                 );
    if  ((l_api_updating
        and (nvl(per_pju_shd.g_old_rec.assignment_id, hr_api.g_number)
             <> nvl(p_assignment_id,hr_api.g_number)
             or nvl(per_pju_shd.g_old_rec.previous_job_id, hr_api.g_number)
             <> nvl(p_previous_job_id, hr_api.g_number)
            )
          )
        or
        (not l_api_updating)) then
        open csr_asg_job_start_date;
        fetch csr_asg_job_start_date into l_x;
        if csr_asg_job_start_date%found then
          close csr_asg_job_start_date;
          fnd_message.set_name('PER','HR_289543_ASG_PJO_START_DATE');
          fnd_message.raise_error;
        end if;
        if csr_asg_job_start_date%isopen then
          close csr_asg_job_start_date;
        end if;
    end if;
  end if;
exception
  when others then
    raise;
end chk_asg_job_start_date;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
Procedure set_security_group_id
  (p_previous_job_usage_id                in number
  ) is
  --
  -- Declare cursor
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_previous_job_usages pju
         , per_previous_jobs       pjo
         , per_previous_employers  pem
     where pju.previous_job_usage_id = p_previous_job_usage_id
     and   pju.previous_job_id(+)    = pjo.previous_job_id
     and   pjo.previous_employer_id  = pem.previous_employer_id
     and   pbg.business_group_id     = pem.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'previous_job_usage_id'
    ,p_argument_value     => p_previous_job_usage_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     fnd_message.raise_error;
     --
  end if;
  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_previous_job_usage_id                in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  cursor csr_leg_code is
    select  pbg.legislation_code
    from    per_business_groups     pbg
          , per_previous_job_usages pju
          , per_previous_employers  pem
    where pju.previous_job_usage_id = p_previous_job_usage_id
    and   pju.previous_employer_id  = pem.previous_employer_id(+)
    and   pem.business_group_id     = pbg.business_group_id(+);
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'previous_job_usage_id'
    ,p_argument_value     => p_previous_job_usage_id
    );
  --
  if ( nvl(per_pju_bus.g_previous_job_usage_id, hr_api.g_number)
       = p_previous_job_usage_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_pju_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    per_pju_bus.g_previous_job_usage_id       := p_previous_job_usage_id;
    per_pju_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Developer Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--   are all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Developer Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_ddf
  (p_rec in per_pju_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.previous_job_usage_id is not null)  and (
    nvl(per_pju_shd.g_old_rec.pju_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information_category, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_information1, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information1, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_information2, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information2, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_information3, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information3, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_information4, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information4, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_information5, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information5, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_information6, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information6, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_information7, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information7, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_information8, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information8, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_information9, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information9, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_information10, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information10, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_information11, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information11, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_information12, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information12, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_information13, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information13, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_information14, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information14, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_information15, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information15, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_information16, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information16, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_information17, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information17, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_information18, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information18, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_information19, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information19, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_information20, hr_api.g_varchar2) <>
    nvl(p_rec.pju_information20, hr_api.g_varchar2) ))
    or (p_rec.previous_job_usage_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Prev Job Usage Developer DF'
      ,p_attribute_category              => p_rec.pju_information_category
      ,p_attribute1_name                 => 'PJU_INFORMATION1'
      ,p_attribute1_value                => p_rec.pju_information1
      ,p_attribute2_name                 => 'PJU_INFORMATION2'
      ,p_attribute2_value                => p_rec.pju_information2
      ,p_attribute3_name                 => 'PJU_INFORMATION3'
      ,p_attribute3_value                => p_rec.pju_information3
      ,p_attribute4_name                 => 'PJU_INFORMATION4'
      ,p_attribute4_value                => p_rec.pju_information4
      ,p_attribute5_name                 => 'PJU_INFORMATION5'
      ,p_attribute5_value                => p_rec.pju_information5
      ,p_attribute6_name                 => 'PJU_INFORMATION6'
      ,p_attribute6_value                => p_rec.pju_information6
      ,p_attribute7_name                 => 'PJU_INFORMATION7'
      ,p_attribute7_value                => p_rec.pju_information7
      ,p_attribute8_name                 => 'PJU_INFORMATION8'
      ,p_attribute8_value                => p_rec.pju_information8
      ,p_attribute9_name                 => 'PJU_INFORMATION9'
      ,p_attribute9_value                => p_rec.pju_information9
      ,p_attribute10_name                => 'PJU_INFORMATION10'
      ,p_attribute10_value               => p_rec.pju_information10
      ,p_attribute11_name                => 'PJU_INFORMATION11'
      ,p_attribute11_value               => p_rec.pju_information11
      ,p_attribute12_name                => 'PJU_INFORMATION12'
      ,p_attribute12_value               => p_rec.pju_information12
      ,p_attribute13_name                => 'PJU_INFORMATION13'
      ,p_attribute13_value               => p_rec.pju_information13
      ,p_attribute14_name                => 'PJU_INFORMATION14'
      ,p_attribute14_value               => p_rec.pju_information14
      ,p_attribute15_name                => 'PJU_INFORMATION15'
      ,p_attribute15_value               => p_rec.pju_information15
      ,p_attribute16_name                => 'PJU_INFORMATION16'
      ,p_attribute16_value               => p_rec.pju_information16
      ,p_attribute17_name                => 'PJU_INFORMATION17'
      ,p_attribute17_value               => p_rec.pju_information17
      ,p_attribute18_name                => 'PJU_INFORMATION18'
      ,p_attribute18_value               => p_rec.pju_information18
      ,p_attribute19_name                => 'PJU_INFORMATION19'
      ,p_attribute19_value               => p_rec.pju_information19
      ,p_attribute20_name                => 'PJU_INFORMATION20'
      ,p_attribute20_value               => p_rec.pju_information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
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
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_df
  (p_rec in per_pju_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.previous_job_usage_id is not null)  and (
    nvl(per_pju_shd.g_old_rec.pju_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute_category, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute1, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute2, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute3, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute4, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute5, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute6, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute7, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute8, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute9, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute10, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute11, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute12, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute13, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute14, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute15, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute16, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute17, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute18, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute19, hr_api.g_varchar2)  or
    nvl(per_pju_shd.g_old_rec.pju_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.pju_attribute20, hr_api.g_varchar2) ))
    or (p_rec.previous_job_usage_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_PREVIOUS_JOB_USAGES'
      ,p_attribute_category              => p_rec.pju_attribute_category
      ,p_attribute1_name                 => 'PJU_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.pju_attribute1
      ,p_attribute2_name                 => 'PJU_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.pju_attribute2
      ,p_attribute3_name                 => 'PJU_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.pju_attribute3
      ,p_attribute4_name                 => 'PJU_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.pju_attribute4
      ,p_attribute5_name                 => 'PJU_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.pju_attribute5
      ,p_attribute6_name                 => 'PJU_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.pju_attribute6
      ,p_attribute7_name                 => 'PJU_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.pju_attribute7
      ,p_attribute8_name                 => 'PJU_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.pju_attribute8
      ,p_attribute9_name                 => 'PJU_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.pju_attribute9
      ,p_attribute10_name                => 'PJU_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.pju_attribute10
      ,p_attribute11_name                => 'PJU_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.pju_attribute11
      ,p_attribute12_name                => 'PJU_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.pju_attribute12
      ,p_attribute13_name                => 'PJU_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.pju_attribute13
      ,p_attribute14_name                => 'PJU_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.pju_attribute14
      ,p_attribute15_name                => 'PJU_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.pju_attribute15
      ,p_attribute16_name                => 'PJU_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.pju_attribute16
      ,p_attribute17_name                => 'PJU_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.pju_attribute17
      ,p_attribute18_name                => 'PJU_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.pju_attribute18
      ,p_attribute19_name                => 'PJU_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.pju_attribute19
      ,p_attribute20_name                => 'PJU_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.pju_attribute20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
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
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_rec in per_pju_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_pju_shd.api_updating
      (p_previous_job_usage_id                => p_rec.previous_job_usage_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  -- Check for non updateable args
  if per_pju_shd.g_old_rec.previous_job_usage_id <> p_rec.previous_job_usage_id
     then
     hr_api.argument_changed_error
       (p_api_name => l_proc
       ,p_argument => 'previous_job_usage_id'
       );
  end if;
  --
  if per_pju_shd.g_old_rec.previous_employer_id <> p_rec.previous_employer_id
     then
     hr_api.argument_changed_error
       (p_api_name => l_proc
       ,p_argument => 'previous_employer_id'
       );
  end if;
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in per_pju_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- Call all supporting business operations
    -- Check whether the Assignment Id is Valid
    hr_utility.set_location(l_proc, 10);
    chk_assignment_id(p_previous_job_usage_id
                      =>  p_rec.previous_job_usage_id
                     ,p_object_version_number
                      =>  p_rec.object_version_number
                     ,p_assignment_id
                      =>  p_rec.assignment_id);
    -- Check whether the Previous Employer Id is Valid
    hr_utility.set_location(l_proc, 15);
    chk_previous_employer_id(p_previous_employer_id
                             =>  p_rec.previous_employer_id
                            ,p_previous_job_usage_id
                             =>  p_rec.previous_job_usage_id
                            ,p_object_version_number
                             =>  p_rec.object_version_number);
    -- Check whether the Previous Job Id is Valid
    hr_utility.set_location(l_proc, 20);
    chk_previous_job_id(p_previous_job_id
                        =>  p_rec.previous_job_id
                       ,p_previous_job_usage_id
                        =>  p_rec.previous_job_usage_id
                       ,p_object_version_number
                        =>  p_rec.object_version_number);
    -- Check whether the Start Date is Valid
    hr_utility.set_location(l_proc, 25);
    chk_assignment_job(p_previous_job_usage_id
                       =>  p_rec.previous_job_usage_id
                      ,p_object_version_number
                       =>  p_rec.object_version_number
                      ,p_previous_job_id
                       =>  p_rec.previous_job_id
                      ,p_assignment_id
                       =>  p_rec.assignment_id
                      );
    --
    hr_utility.set_location(l_proc, 30);
    chk_valid_job_dates(p_previous_job_usage_id
                        =>  p_rec.previous_job_usage_id
                       ,p_object_version_number
                        =>  p_rec.object_version_number
                       ,p_start_date
                        =>  p_rec.start_date
                       ,p_end_date
                        =>  p_rec.end_date);
    --
    hr_utility.set_location(l_proc, 35);
    chk_asg_job_start_date
              (p_previous_job_usage_id
               =>  p_rec.previous_job_usage_id
              ,p_object_version_number
               =>  p_rec.object_version_number
              ,p_assignment_id
               =>  p_rec.assignment_id
              ,p_previous_job_id
               =>  p_rec.previous_job_id
              );
    --
    hr_utility.set_location(l_proc, 40);
    chk_pju_start_end_dates(p_previous_job_usage_id
                            =>  p_rec.previous_job_usage_id
                           ,p_object_version_number
                            =>  p_rec.object_version_number
                           ,p_previous_employer_id
                            =>  p_rec.previous_employer_id
                           ,p_start_date
                            =>  p_rec.start_date
                           ,p_end_date
                            =>  p_rec.end_date);
     -- Check whether the Period Years is Valid
     hr_utility.set_location(l_proc, 45);
     chk_period_years(p_period_years
                      =>  p_rec.period_years
                     ,p_previous_job_usage_id
                      =>  p_rec.previous_job_usage_id
                     ,p_object_version_number
                      =>  p_rec.object_version_number);
     -- Check whether the Period Months is Valid
     hr_utility.set_location(l_proc, 50);
     chk_period_months(p_period_months
                       =>  p_rec.period_months
                      ,p_previous_job_usage_id
                       =>  p_rec.previous_job_usage_id
                      ,p_object_version_number
                       =>  p_rec.object_version_number);
     -- Check whether the Period Days is Valid
     hr_utility.set_location(l_proc, 55);
     chk_period_days(p_period_days
                     =>  p_rec.period_days
                    ,p_previous_job_usage_id
                     =>  p_rec.previous_job_usage_id
                    ,p_object_version_number
                     =>  p_rec.object_version_number);
    --
    hr_utility.set_location(l_proc, 60);
    per_pju_bus.chk_ddf(p_rec);
    --
    hr_utility.set_location(l_proc, 65);
    per_pju_bus.chk_df(p_rec);
    --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in per_pju_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- Call all supporting business operations
    hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'assignment_id'
    ,p_argument_value     => p_rec.assignment_id
    );
    --
    chk_non_updateable_args(p_rec => p_rec);
    -- Check whether the Assignment Id is Valid
    hr_utility.set_location(l_proc, 10);
    chk_assignment_id(p_rec.previous_job_usage_id
                     ,p_rec.object_version_number
                     ,p_rec.assignment_id);
    -- Check whether the Previous Job Id is Valid
    hr_utility.set_location(l_proc, 20);
    chk_previous_job_id(p_previous_job_id
                        =>  p_rec.previous_job_id
                       ,p_previous_job_usage_id
                        =>  p_rec.previous_job_usage_id
                       ,p_object_version_number
                        =>  p_rec.object_version_number);
    --
    hr_utility.set_location(l_proc, 25);
    chk_assignment_job(p_previous_job_usage_id
                       =>  p_rec.previous_job_usage_id
                      ,p_object_version_number
                       =>  p_rec.object_version_number
                      ,p_previous_job_id
                       =>  p_rec.previous_job_id
                      ,p_assignment_id
                       =>  p_rec.assignment_id
                      );
    -- Check whether the Start Date is Valid
    hr_utility.set_location(l_proc, 30);
    chk_valid_job_dates(p_rec.previous_job_usage_id
                       ,p_rec.object_version_number
                       ,p_rec.start_date
                       ,p_rec.end_date);
    -- Check whether the Start Date is before the Start Date of the
    -- Assignment mapped with.
    hr_utility.set_location(l_proc, 35);
    chk_asg_job_start_date
              (p_previous_job_usage_id
               =>  p_rec.previous_job_usage_id
              ,p_object_version_number
               =>  p_rec.object_version_number
              ,p_assignment_id
               =>  p_rec.assignment_id
              ,p_previous_job_id
               =>  p_rec.previous_job_id
              );
    -- Check whether the Period Years is Valid
    hr_utility.set_location(l_proc, 40);
    chk_period_years(p_period_years
                     =>  p_rec.period_years
                    ,p_previous_job_usage_id
                     =>  p_rec.previous_job_usage_id
                    ,p_object_version_number
                     =>  p_rec.object_version_number);
    -- Check whether the Period Months is Valid
    hr_utility.set_location(l_proc, 45);
    chk_period_months(p_period_months
                      =>  p_rec.period_months
                     ,p_previous_job_usage_id
                      =>  p_rec.previous_job_usage_id
                     ,p_object_version_number
                      =>  p_rec.object_version_number);
    -- Check whether the Period Days is Valid
    hr_utility.set_location(l_proc, 50);
    chk_period_days(p_period_days
                    =>  p_rec.period_days
                   ,p_previous_job_usage_id
                    =>  p_rec.previous_job_usage_id
                   ,p_object_version_number
                    =>  p_rec.object_version_number);
    --
    hr_utility.set_location(l_proc, 55);
    chk_pju_start_end_dates(p_previous_job_usage_id
                            =>  p_rec.previous_job_usage_id
                           ,p_object_version_number
                            =>  p_rec.object_version_number
                           ,p_previous_employer_id
                            =>  p_rec.previous_employer_id
                           ,p_start_date
                            =>  p_rec.start_date
                           ,p_end_date
                            =>  p_rec.end_date);
    --
    hr_utility.set_location(l_proc, 60);
    per_pju_bus.chk_ddf(p_rec);
    --
    hr_utility.set_location(l_proc, 65);
    per_pju_bus.chk_df(p_rec);
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_pju_shd.g_rec_type
  ) is
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
end per_pju_bus;

/
