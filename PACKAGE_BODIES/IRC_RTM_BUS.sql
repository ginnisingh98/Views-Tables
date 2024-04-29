--------------------------------------------------------
--  DDL for Package Body IRC_RTM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_RTM_BUS" as
/* $Header: irrtmrhi.pkb 120.3 2008/01/22 10:17:45 mkjayara noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_rtm_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_rec_team_member_id          number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_rec_team_member_id                   in number
  ,p_associated_column1                   in varchar2 default null
  ,p_associated_column2                   in varchar2 default null
  ) is

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
    ,p_argument           => 'rec_team_member_id'
    ,p_argument_value     => p_rec_team_member_id
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
  (p_rec_team_member_id in     number
  )
  Return Varchar2 Is
   --
  -- Declare cursor
  --
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
    ,p_argument           => 'rec_team_member_id'
    ,p_argument_value     => p_rec_team_member_id
    );
  --

  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  (p_rec in irc_rtm_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_rtm_shd.api_updating
      (p_rec_team_member_id                   => p_rec.rec_team_member_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --   Add checks to ensure non-updateable args have
  --   not been updated.
  --
  if p_rec.rec_team_member_id <> irc_rtm_shd.g_old_rec.rec_team_member_id
  then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'REC_TEAM_MEMBER_ID'
    ,p_base_table => irc_rtm_shd.g_tab_name
    );
  end if;
  --
  if p_rec.vacancy_id <> irc_rtm_shd.g_old_rec.vacancy_id
  then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'VACANCY_ID'
    ,p_base_table => irc_rtm_shd.g_tab_name
    );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
--
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_person_id >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates if the person id exists in the PER_ALL_PEOPLE_F table
--
-- Prerequisites:
--   Must be called as the first step in insert_validate.
--
-- In Arguments:
--   p_person_id
--
-- Post Success:
--   If the person_id is existing in PER_ALL_PEOPLE_F
--   then continue.
--
-- Post Failure:
--   If the person_id is not present in PER_ALL_PEOPLE_F
--   then throw an error indicating the same.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure chk_person_id
  (p_person_id           in irc_rec_team_members.person_id%type
  ,p_party_id in out nocopy irc_rec_team_members.party_id%type
  ,p_effective_date      in date
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_person_id';
  l_party_id irc_rec_team_members.party_id%type;
  l_var varchar2(1);
--
  cursor l_person is
    select party_id
      from per_all_people_f
     where person_id = p_person_id
       and p_effective_date between
           effective_start_date and effective_end_date;
--


cursor csr_system_person_type is
SELECT NULL
  FROM per_all_people_f paf
 WHERE paf.person_id = p_person_id
   AND p_effective_date BETWEEN paf.effective_start_date
                            AND paf.effective_end_date
   AND (   NVL (paf.current_employee_flag, 'N') = 'Y'
        OR (    NVL (paf.current_npw_flag, 'N') = 'Y'
            AND NVL (fnd_profile.VALUE ('HR_TREAT_CWK_AS_EMP'), 'N') = 'Y'
           )
       );

--
--
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  open l_person;
  fetch l_person into l_party_id;
  if l_person%notfound
  then
    close l_person;
    fnd_message.set_name('PER','IRC_412157_PARTY_PERS_MISMTCH');
    fnd_message.raise_error;
  else
    close l_person;
    --check if the person is an employee
    open csr_system_person_type;
    fetch csr_system_person_type into l_var;
    hr_utility.set_location(l_proc, 20);
    if csr_system_person_type%notfound then
      close csr_system_person_type;
      hr_utility.set_location(l_proc, 30);
      fnd_message.set_name('PER','IRC_412034_RTM_INV_EMP');
      hr_multi_message.add
          (p_associated_column1      => 'IRC_REC_TEAM_MEMBERS.PERSON_ID'
          );
     else
       close csr_system_person_type;
    end if;
  end if;
  --
  if p_party_id is not null then
    if p_party_id<>l_party_id then
      fnd_message.set_name('PER','IRC_412033_RTM_INV_PARTY_ID');
      fnd_message.raise_error;
    end if;
  else
    p_party_id:=l_party_id;
  end if;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc,50);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_REC_TEAM_MEMBERS.PERSON_ID'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,60);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,70);
    --
End chk_person_id;
--
--
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_vacancy_id >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that mandatory parameters have been set.
--   If the vacancy id is not found in per_all_vacancies an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_start_date.
--
-- Post Success:
--   Processing continues if the mandatory parameters have been set and the
--   specified vacancy id exists.
--
-- Post Failure:
--   An application error is raised if the vacancy id does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_vacancy_id
  (p_vacancy_id in irc_rec_team_members.vacancy_id%type
  ,p_start_date in irc_rec_team_members.start_date%type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_vacancy_id';
  l_vacancy_id  irc_rec_team_members.vacancy_id%type;
--
--
--   Cursor to check that the vacancy_id exists in PER_ALL_VACANCIES
--   and is current at the p_start_date.
--
cursor csr_vacancy_id is
  select vacancy_id
    from per_all_vacancies
  where vacancy_id = p_vacancy_id;
--
Begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'vacancy_id'
    ,p_argument_value     => p_vacancy_id
    );
  --
  -- Check if the vacancy_id exists in PER_ALL_VACANCIES
  -- and is current at the p_start_date.
  --
  open csr_vacancy_id;
  fetch csr_vacancy_id into l_vacancy_id;
  hr_utility.set_location(l_proc, 30);
  if csr_vacancy_id%notfound then
    close csr_vacancy_id;
    fnd_message.set_name('PER','IRC_412032_RTM_INV_VACANCY_ID');
    fnd_message.raise_error;
  end if;
  close csr_vacancy_id;
  hr_utility.set_location(' Leaving:'||l_proc,35);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
           (p_associated_column1      => 'IRC_REC_TEAM_MEMBERS.VACANCY_ID'
           ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
--
End chk_vacancy_id;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_job_id >------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that mandatory parameters have been set.
--   If the job id is not found in per_jobs an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_job_id
--   p_party_id
--   p_vacancy_id
--   p_object_version_number.
--
-- Post Success:
--   Processing continues if the mandatory parameters have been set and the
--   specified job id exists.
--
-- Post Failure:
--   An application error is raised if the job id does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_job_id
  (p_job_id in irc_rec_team_members.job_id%type
  ,p_rec_team_member_id in irc_rec_team_members.rec_team_member_id%type
  ,p_vacancy_id in irc_rec_team_members.vacancy_id%type
  ,p_object_version_number in irc_rec_team_members.object_version_number%type
  ,p_start_date in irc_rec_team_members.start_date%type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_job_id';
  l_job_id  varchar2(1);
  l_api_updating boolean;
--
--
--   Cursor to check that the job_id exists in PER_JOBS
--
cursor csr_job_id is
  select null from
    per_jobs job, per_all_vacancies vac
  where job.job_id = p_job_id
  and vac.vacancy_id = p_vacancy_id
  and vac.business_group_id = job.business_group_id
  and p_start_date between job.date_from and nvl(job.date_to,hr_api.g_eot);
--
Begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  l_api_updating := irc_rtm_shd.api_updating(p_rec_team_member_id
    ,p_object_version_number);
  --
  hr_utility.set_location(l_proc, 30);
  if(p_job_id IS NOT NULL) then
    if ((l_api_updating
      and (irc_rtm_shd.g_old_rec.job_id <> p_job_id))
      or (NOT l_api_updating)) then
      --
      -- Check if the job_id exists in PER_JOBS
      --
      if hr_multi_message.no_exclusive_error
         (p_check_column1      => 'IRC_REC_TEAM_MEMBERS.VACANCY_ID'
         ) then
        open csr_job_id;
        fetch csr_job_id into l_job_id;
        hr_utility.set_location(l_proc, 40);
        if csr_job_id%notfound then
          close csr_job_id;
          fnd_message.set_name('PER','IRC_412037_RTM_INV_JOB_ID');
          fnd_message.raise_error;
        end if;
        close csr_job_id;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,45);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
           (p_associated_column1      => 'IRC_REC_TEAM_MEMBERS.JOB_ID'
           ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
--
End chk_job_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_job_id_job_group_id >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the job group of the job is valid.
--   If the job group id is not found in per_job_groups an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_party_id
--   p_vacancy_id
--   p_job_id.
--   p_object_version_number.
--
-- Post Success:
--   Processing continues if the mandatory parameters have been set and the
--   specified job group id is valid.
--
-- Post Failure:
--   An application error is raised if the job group id does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_job_id_job_group_id
  (p_rec_team_member_id irc_rec_team_members.rec_team_member_id%type
  ,p_job_id in irc_rec_team_members.job_id%type
  ,p_object_version_number irc_rec_team_members.object_version_number%type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_job_id_job_group_id';
  l_job_id_job_group_id  varchar2(1);
  l_api_updating boolean;
--
--
--   Cursor to check that the job_group_id exists in PER_JOB_GROUPS and
--   is valid.
--
cursor csr_job_id_job_group_id is
  select null from
    per_jobs job
   ,per_job_groups jgr
  where job.job_id = p_job_id
  and job.job_group_id = jgr.job_group_id
  and job.business_group_id = jgr.business_group_id
  and jgr.internal_name <> 'HR_'||to_char(jgr.business_group_id);
--
Begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  l_api_updating := irc_rtm_shd.api_updating(p_rec_team_member_id
    ,p_object_version_number);
  --
  if(p_job_id IS NOT NULL) then
    if ((l_api_updating
      and (irc_rtm_shd.g_old_rec.job_id <> p_job_id))
      or (NOT l_api_updating)) then
      hr_utility.set_location(l_proc, 20);
      --
      -- Check if the job_group_id exists in PER_JOB_GROUPS and is valid.
      --
      if hr_multi_message.no_exclusive_error
             (p_check_column1      => 'IRC_REC_TEAM_MEMBERS.JOB_ID'
             ,p_check_column2      => 'IRC_REC_TEAM_MEMBERS.VACANCY_ID'
             ) then
        open csr_job_id_job_group_id;
        fetch csr_job_id_job_group_id into l_job_id_job_group_id;
        hr_utility.set_location(l_proc, 30);
        if csr_job_id_job_group_id%notfound then
          close csr_job_id_job_group_id;
          fnd_message.set_name('PER','IRC_412041_RTM_INV_JOB_GRP_ID');
          fnd_message.raise_error;
        end if;
        close csr_job_id_job_group_id;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,35);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
             (p_associated_column1      => 'IRC_REC_TEAM_MEMBERS.JOB_ID'
             ) then
          hr_utility.set_location(' Leaving:'||l_proc, 40);
          raise;
      end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
--
End chk_job_id_job_group_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_team_dates >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that valid dates have been entered.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_start_date
--   p_end_date
--   p_party_id
--   p_vacancy_id
--   p_object_version_number.
--
-- Post Success:
--   Processing continues if valid dates are entered.
--
-- Post Failure:
--   An application error is raised if valid dates are not entered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_team_dates
  (p_start_date in irc_rec_team_members.start_date%type
  ,p_end_date in irc_rec_team_members.end_date%type
  ,p_rec_team_member_id in irc_rec_team_members.rec_team_member_id%type
  ,p_object_version_number in irc_rec_team_members.object_version_number%type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_team_dates';
  l_api_updating boolean;
--
Begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  if (p_start_date is not NULL or p_end_date is not NULL) then
  --
    l_api_updating := irc_rtm_shd.api_updating(p_rec_team_member_id
      ,p_object_version_number);
    --
    --  Check to see if start_date or end_date values have changed.
    --
    hr_utility.set_location(l_proc, 30);
    if ((l_api_updating
      and ((nvl(irc_rtm_shd.g_old_rec.start_date,hr_api.g_sot)
            <> p_start_date)
      or (nvl(irc_rtm_shd.g_old_rec.end_date,hr_api.g_eot) <> p_end_date)))
      or (NOT l_api_updating)) then
      --
      -- Check that the end date is not before the start date.
      --
      hr_utility.set_location(l_proc, 40);
      if(nvl(p_start_date,hr_api.g_sot) > nvl(p_end_date,hr_api.g_eot)) then
        fnd_message.set_name('PER','IRC_412038_RTM_INV_ST_END_DATE');
        fnd_message.raise_error;
      end if;
      --
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,45);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
               (p_associated_column1      => 'IRC_REC_TEAM_MEMBERS.START_DATE'
               ,p_associated_column2      => 'IRC_REC_TEAM_MEMBERS.END_DATE'
               ) then
            hr_utility.set_location(' Leaving:'||l_proc, 50);
            raise;
      end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
--
End chk_team_dates;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_update_allowed >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure a valid 'Update Allowed' value.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_update_allowed
--  p_start_date
--  p_party_id
--  p_vacancy_id
--  p_object_version_number.
--
-- Post Success:
--   Processing continues if a valid 'Update Allowed' value is entered.
--
-- Post Failure:
--   An application error is raised if a valid 'Update Allowed' value is not
--   entered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_update_allowed
  (p_update_allowed  in irc_rec_team_members.update_allowed%type
  ,p_start_date in irc_rec_team_members.start_date%type
  ,p_rec_team_member_id in irc_rec_team_members.rec_team_member_id%type
  ,p_object_version_number in irc_rec_team_members.object_version_number%type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_update_allowed';
  l_var      boolean;
  l_api_updating boolean;
--
Begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  if (p_update_allowed is not NULL) then
  --
    l_api_updating := irc_rtm_shd.api_updating(p_rec_team_member_id
      ,p_object_version_number);
    --
    --  Check to see if the update_allowed value has changed.
    --
    hr_utility.set_location(l_proc, 30);
    if ((l_api_updating
      and (irc_rtm_shd.g_old_rec.update_allowed <> p_update_allowed))
      or (NOT l_api_updating)) then
      --
      -- Check that a valid 'Update Allowed' value is entered.
      --
      l_var := hr_api.not_exists_in_hr_lookups
               (p_start_date
               ,'YES_NO'
               ,p_update_allowed
               );
      hr_utility.set_location(l_proc, 40);
      if (l_var = true) then
        fnd_message.set_name('PER','IRC_412039_RTM_INV_UPD_ALLOWED');
        fnd_message.raise_error;
      end if;
    end if;
    --
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,45);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                 (p_associated_column1      => 'IRC_REC_TEAM_MEMBERS.UPDATE_ALLOWED'
                 ) then
              hr_utility.set_location(' Leaving:'||l_proc, 50);
              raise;
      end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
--
End chk_update_allowed;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_delete_allowed >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure a valid 'Delete Allowed' value.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_delete_allowed
--   p_start_date
--   p_party_id
--   p_vacancy_id
--   p_object_version_number.
--
-- Post Success:
--   Processing continues if a valid 'Delete Allowed' value is entered.
--
-- Post Failure:
--   An application error is raised if a valid 'Delete Allowed' value is not
--   entered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_delete_allowed
  (p_delete_allowed  in irc_rec_team_members.delete_allowed%type
  ,p_start_date in irc_rec_team_members.start_date%type
  ,p_rec_team_member_id in irc_rec_team_members.rec_team_member_id%type
  ,p_object_version_number in irc_rec_team_members.object_version_number%type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_delete_allowed';
  l_var      boolean;
  l_api_updating boolean;
--
Begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  if (p_delete_allowed is not NULL) then
  --
    l_api_updating := irc_rtm_shd.api_updating(p_rec_team_member_id,p_object_version_number);
    --
    --  Check to see if the delete_allowed value has changed.
    --
    hr_utility.set_location(l_proc, 30);
    if ((l_api_updating
      and (irc_rtm_shd.g_old_rec.delete_allowed <> p_delete_allowed))
      or (NOT l_api_updating)) then
      --
      -- Check that a valid 'Delete Allowed' value is entered.
      --
      l_var := hr_api.not_exists_in_hr_lookups
               (p_start_date
               ,'YES_NO'
               ,p_delete_allowed
               );
      hr_utility.set_location(l_proc, 40);
      if (l_var = true) then
        fnd_message.set_name('PER','IRC_412040_RTM_INV_DEL_ALLOWED');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,45);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                   (p_associated_column1      => 'IRC_REC_TEAM_MEMBERS.DELETE_ALLOWED'
                   ) then
                hr_utility.set_location(' Leaving:'||l_proc, 50);
                raise;
      end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
--
End chk_delete_allowed;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_rec_team_member >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates if the person is already a recruting team member for this
--   Vacancy.
--
-- Prerequisites:
--   Must be called after the chk_person_id and chk_vacancy_id.
--
-- In Arguments:
--   p_person_id
--   p_vacancy_id
--
-- Post Success:
--   If the person_id ,vacancy_id is not existing in IRC_REC_TEAM_MEMBERS
--   then continue.
--
-- Post Failure:
--   If the person_id, vacancy_id is present in IRC_REC_TEAM_MEMBERS
--   then throw an error indicating the same.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure chk_rec_team_member
  (p_person_id  in irc_rec_team_members.person_id%type
  ,p_vacancy_id in irc_rec_team_members.vacancy_id%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_rec_team_member';
  l_var varchar2(1);
--
  cursor csr_rec_team_member is
    select null
      from irc_rec_team_members
     where person_id = p_person_id
       and vacancy_id = p_vacancy_id;
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --

  if hr_multi_message.no_exclusive_error
        (p_check_column1      => 'IRC_REC_TEAM_MEMBERS.PERSON_ID'
        ,p_check_column2      => 'IRC_REC_TEAM_MEMBERS.VACANCY_ID'
        ) then
    open csr_rec_team_member;
    fetch csr_rec_team_member into l_var;
    hr_utility.set_location(l_proc, 20);
    if csr_rec_team_member%found then
      close csr_rec_team_member;
      hr_utility.set_location(l_proc, 30);
      fnd_message.set_name('PER','IRC_412120_DUP_REC_TEAM_MEMBER');
      fnd_message.raise_error;
    end if;
    close csr_rec_team_member;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,40);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1  =>  'IRC_REC_TEAM_MEMBERS.PERSON_ID'
      ,p_associated_column2  =>  'IRC_REC_TEAM_MEMBERS.VACANCY_ID'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,50);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,60);
    --
End chk_rec_team_member;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in out nocopy irc_rtm_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Validate Dependent Attributes
  hr_utility.set_location(l_proc, 10);
  --
  chk_person_id
  (p_person_id =>p_rec.person_id
  ,p_party_id => p_rec.party_id
  ,p_effective_date=>p_rec.start_date
  );
  --
  hr_utility.set_location(l_proc, 20);
  chk_vacancy_id
  (p_vacancy_id => p_rec.vacancy_id
  ,p_start_date => p_rec.start_date
  );
  --
  hr_utility.set_location(l_proc, 30);
  chk_rec_team_member
    (p_person_id =>p_rec.person_id
    ,p_vacancy_id => p_rec.vacancy_id
  );
  --
  hr_utility.set_location(l_proc, 40);
  chk_job_id
  (p_job_id => p_rec.job_id
  ,p_rec_team_member_id => p_rec.rec_team_member_id
  ,p_vacancy_id => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_start_date => p_rec.start_date
  );
  --
  hr_utility.set_location(l_proc, 50);
  chk_job_id_job_group_id
  (p_rec_team_member_id => p_rec.rec_team_member_id
  ,p_job_id => p_rec.job_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 60);
  chk_team_dates
  (p_start_date => p_rec.start_date
  ,p_end_date => p_rec.end_date
  ,p_rec_team_member_id => p_rec.rec_team_member_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 70);
  chk_update_allowed
  (p_update_allowed => p_rec.update_allowed
  ,p_start_date => p_rec.start_date
  ,p_rec_team_member_id => p_rec.rec_team_member_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 80);
  chk_delete_allowed
  (p_delete_allowed => p_rec.delete_allowed
  ,p_start_date => p_rec.start_date
  ,p_rec_team_member_id => p_rec.rec_team_member_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in out nocopy irc_rtm_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Validate Dependent Attributes
  hr_utility.set_location(l_proc, 10);
  --
  chk_person_id
  (p_person_id =>p_rec.person_id
  ,p_party_id => p_rec.party_id
  ,p_effective_date=>p_rec.start_date
  );
  --
  hr_utility.set_location(l_proc, 15);
  chk_job_id
  (p_job_id => p_rec.job_id
  ,p_rec_team_member_id => p_rec.rec_team_member_id
  ,p_vacancy_id => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_start_date => p_rec.start_date
  );
  --
  hr_utility.set_location(l_proc, 20);
  chk_job_id_job_group_id
  (p_rec_team_member_id => p_rec.rec_team_member_id
  ,p_job_id => p_rec.job_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 30);
  chk_team_dates
  (p_start_date => p_rec.start_date
  ,p_end_date => p_rec.end_date
  ,p_rec_team_member_id => p_rec.rec_team_member_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 40);
  chk_update_allowed
  (p_update_allowed => p_rec.update_allowed
  ,p_start_date => p_rec.start_date
  ,p_rec_team_member_id => p_rec.rec_team_member_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 50);
  chk_delete_allowed
  (p_delete_allowed => p_rec.delete_allowed
  ,p_start_date => p_rec.start_date
  ,p_rec_team_member_id => p_rec.rec_team_member_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  --
  hr_utility.set_location(l_proc, 70);
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_rtm_shd.g_rec_type
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
end irc_rtm_bus;

/
