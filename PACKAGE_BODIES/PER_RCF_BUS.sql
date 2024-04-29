--------------------------------------------------------
--  DDL for Package Body PER_RCF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RCF_BUS" as
/* $Header: percfrhi.pkb 120.2 2006/04/07 04:33:51 cnholmes noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_rcf_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_rec_activity_for_id number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_rec_activity_for_id          in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_recruitment_activity_for rcf
     where rcf.recruitment_activity_for_id = p_rec_activity_for_id
       and pbg.business_group_id = rcf.business_group_id;
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
    ,p_argument           => 'recruitment_activity_for_id'
    ,p_argument_value     => p_rec_activity_for_id
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
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'RECRUITMENT_ACTIVITY_FOR_ID')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
  end if;
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
  (p_rec_activity_for_id          in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_recruitment_activity_for rcf
     where rcf.recruitment_activity_for_id = p_rec_activity_for_id
       and pbg.business_group_id = rcf.business_group_id;
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
    ,p_argument           => 'recruitment_activity_for_id'
    ,p_argument_value     => p_rec_activity_for_id
    );
  --
  if ( nvl(per_rcf_bus.g_rec_activity_for_id, hr_api.g_number)
       = p_rec_activity_for_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_rcf_bus.g_legislation_code;
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
    per_rcf_bus.g_rec_activity_for_id := p_rec_activity_for_id;
    per_rcf_bus.g_legislation_code  := l_legislation_code;
  end if;
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
  (p_rec in per_rcf_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_rcf_shd.api_updating
      (p_rec_activity_for_id          => p_rec.rec_activity_for_id
      ,p_object_version_number        => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --  Add checks to ensure non-updateable args have
  --  not been updated.
  if (p_rec.business_group_id <> per_rcf_shd.g_old_rec.business_group_id)
  then
   hr_api.argument_changed_error
     (p_api_name    => l_proc
     ,p_argument    => 'BUSINESS_GROUP_ID'
     ,p_base_table  => per_rcf_shd.g_tab_nam
     );
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_vacancy_id >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that mandatory parameters have been
--   set and the business group is valid.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_business_group_id.
--
-- Post Success:
--   Processing continues if the vacancy id is valid and the business group
--   id matches with that in the PER_ALL_VACANCIES table.
--
-- Post Failure:
--   An application error is raised if the vacancy id is null or is not valid
--   or if the business group id is not valid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_vacancy_id
  (p_vacancy_id            in  per_recruitment_activity_for.vacancy_id%type,
   p_business_group_id     in
     per_recruitment_activity_for.business_group_id%type,
   p_rec_activity_for_id   in
     per_recruitment_activity_for.recruitment_activity_for_id%type,
   p_object_version_number in
     per_recruitment_activity_for.object_version_number%type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_vacancy_id';
  l_business_group_id  per_recruitment_activity_for.business_group_id%type;
  l_vacancy_id  per_recruitment_activity_for.vacancy_id%type;
  l_api_updating boolean;
--
--   Cursor to check that the vacancy id exists in the reference table
--   PER_ALL_VACANCIES.
--
cursor csr_vacancy_id is
  select l_vacancy_id,l_business_group_id
    from per_all_vacancies
  where vacancy_id = p_vacancy_id;
--
Begin
hr_utility.set_location('Entering:'|| l_proc, 10);
--
  l_api_updating := per_rcf_shd.api_updating(p_rec_activity_for_id,
    p_object_version_number);
  --
  -- Check to see if the vacancy id has changed.
  --
  hr_utility.set_location(l_proc, 20);
  if ((l_api_updating
    and (nvl(per_rcf_shd.g_old_rec.vacancy_id,hr_api.g_number) <>
    p_vacancy_id))
    or (NOT l_api_updating)) then
    --
    -- Check to ensure that the vacancy id is not null.
    --
    hr_utility.set_location(l_proc, 30);
    if p_vacancy_id is null then
      hr_api.mandatory_arg_error
      (p_api_name           => l_proc
      ,p_argument           => 'vacancy_id'
      ,p_argument_value     => p_vacancy_id
      );
    end if;
    --
    -- Check that the vacancy id exists in the PER_ALL_VACANCIES table.
    --
    open csr_vacancy_id;
    fetch csr_vacancy_id into l_vacancy_id,l_business_group_id;
    hr_utility.set_location(l_proc, 40);
    if csr_vacancy_id%notfound then
    hr_utility.set_location(l_proc, 41);
      close csr_vacancy_id;
      fnd_message.set_name('PER','PER_289469_RCF_INV_VAC_ID');
      hr_multi_message.add
        (p_associated_column1 => 'PER_RECRUITMENT_ACTIVITY_FOR.VACANCY_ID'
        );
    else
      --
      -- Check that the business group id is the same as that in the
      -- PER_ALL_VACANCIES table for this vacancy_id.
      --
      hr_utility.set_location(l_proc, 50);
      if(l_business_group_id <> p_business_group_id) then
      hr_utility.set_location(l_proc, 51);
        close csr_vacancy_id;
        fnd_message.set_name('PER', 'PER_289468_RCF_INV_VAC_BG');
        hr_multi_message.add
        (p_associated_column1 =>
                           'PER_RECRUITMENT_ACTIVITY_FOR.VACANCY_ID'
        ,p_associated_column2 =>
                           'PER_RECRUITMENT_ACTIVITY_FOR.BUSINESS_GROUP_ID'
        );
      else
      hr_utility.set_location(l_proc, 60);
        close csr_vacancy_id;
      end if;
    end if;
  --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
  --
end chk_vacancy_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_rec_activity_id >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that mandatory parameters have been
--   set and the business group is valid.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_recruitment_activity_id
--   p_business_group_id.
--
-- Post Success:
--   Processing continues if the rec activity id is valid and the
--   business group id matches with that in the PER_REC_ACTIVITY_FOR table.
--
-- Post Failure:
--   An application error is raised if the rec activity id is null or is
--   not valid or if the business group id is not valid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_rec_activity_id
  (p_rec_activity_id             in
     per_recruitment_activity_for.recruitment_activity_id%type,
   p_business_group_id           in
     per_recruitment_activity_for.business_group_id%type,
   p_rec_activity_for_id         in
     per_recruitment_activity_for.recruitment_activity_for_id%type,
   p_object_version_number       in
     per_recruitment_activity_for.object_version_number%type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_rec_activity_id';
  l_rec_activity_id  per_recruitment_activity_for.recruitment_activity_id%type;
  l_business_group_id  per_recruitment_activity_for.business_group_id%type;
  l_api_updating boolean;
--
--   Cursor to check that the recruitment activity id exists in the reference
--   table PER_RECRUITMENT_ACTIVITIES.
--
cursor csr_rec_activity_id is
  select recruitment_activity_id, business_group_id
    from per_recruitment_activities
  where recruitment_activity_id = p_rec_activity_id;
--
Begin
hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_api_updating := per_rcf_shd.api_updating(p_rec_activity_for_id,
    p_object_version_number);
  --
  -- Check to see if the recruitment activity id has changed.
  --
  hr_utility.set_location(l_proc, 20);
  if ((l_api_updating
    and (nvl(per_rcf_shd.g_old_rec.rec_activity_id,hr_api.g_number) <>
    p_rec_activity_id))
    or (NOT l_api_updating)) then
    --
    -- Check to ensure that the recruitment_activity_id is not null.
    --
    hr_utility.set_location(l_proc, 30);
    if p_rec_activity_id is null then
      hr_api.mandatory_arg_error
      (p_api_name           => l_proc
      ,p_argument           => 'rec_activity_id'
      ,p_argument_value     => p_rec_activity_id
      );
    end if;
    --
    -- Check that the recruitment activity id exists in the
    -- PER_RECRUITMENT_ACTIVITIES table.
    --
    open csr_rec_activity_id;
    fetch csr_rec_activity_id into l_rec_activity_id, l_business_group_id;
    hr_utility.set_location(l_proc, 40);
    if csr_rec_activity_id%notfound then
    hr_utility.set_location(l_proc, 41);
      close csr_rec_activity_id;
      fnd_message.set_name('PER','PER_289470_RCF_INV_ACT_ID');
      hr_multi_message.add
        (p_associated_column1 =>
                          'PER_RECRUITMENT_ACTIVITY_FOR.RECRUITMENT_ACTIVITY_ID'
        );
    else
      --
      -- Check that the business group id is the same as that in the
      -- PER_RECRUITMENT_ACTIVITY_FOR table for this recruitment_activity_id.
      --
      hr_utility.set_location(l_proc, 50);
      if (l_business_group_id <> p_business_group_id) then
      hr_utility.set_location(l_proc, 51);
        close csr_rec_activity_id;
        fnd_message.set_name('PER', 'PER_289471_RCF_INV_ACT_BG');
        hr_multi_message.add
        (p_associated_column1 =>
                          'PER_RECRUITMENT_ACTIVITY_FOR.RECRUITMENT_ACTIVITY_ID'
        ,p_associated_column2 =>
                          'PER_RECRUITMENT_ACTIVITY_FOR.BUSINESS_GROUP_ID'
         );
       else
      hr_utility.set_location(l_proc, 60);
         close csr_rec_activity_id;
       end if;
    end if;
    --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
  --
  end chk_rec_activity_id;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_vacancy_rec_activity>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This check procedure ensures that there should be only one internal
--   recruitment activity and one external recruitment for a given vacancy
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_rec_activity_id
--
-- Post Success:
--   Processing continues if the check procedure does not throw any error.
--
--
-- Post Failure:
--
--  An application error is raised if there are more than one internal or
--  external recruitment activity for a given vacancy
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_vacancy_rec_activity
  (p_vacancy_id            in  per_recruitment_activity_for.vacancy_id%type
  ,p_rec_activity_id             in
     per_recruitment_activity_for.recruitment_activity_id%type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_vacancy_rec_activity';
  l_vacancy_id  per_recruitment_activity_for.vacancy_id%type;
  l_internal irc_all_recruiting_sites.internal%type;
  l_external irc_all_recruiting_sites.external%type;
  l_ret varchar2(1);
--
  cursor csr_internal is
  select null
    from irc_all_recruiting_sites irs
        ,per_recruitment_activities pra
        ,per_recruitment_activity_for prf
   where irs.recruiting_site_id = pra.recruiting_site_id
     and pra.recruitment_activity_id = prf.recruitment_activity_id
     and pra.recruitment_activity_id <> p_rec_activity_id
     and irs.internal = 'Y'
     and prf.vacancy_id = p_vacancy_id;
--
  cursor csr_external is
  select null
    from irc_all_recruiting_sites irs
        ,per_recruitment_activities pra
        ,per_recruitment_activity_for prf
   where irs.recruiting_site_id = pra.recruiting_site_id
     and pra.recruitment_activity_id = prf.recruitment_activity_id
     and pra.recruitment_activity_id <> p_rec_activity_id
     and irs.external = 'Y' and
     prf.vacancy_id = p_vacancy_id;
--
  cursor csr_rse is
     select irs.internal
           ,irs.external
       from irc_all_recruiting_sites irs
           ,per_recruitment_activities pra
      where pra.recruitment_activity_id = p_rec_activity_id
        and pra.recruiting_site_id = irs.recruiting_site_id;
--
Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
 if hr_multi_message.no_exclusive_error
 (p_check_column1    => 'PER_RECRUITMENT_ACTIVITY_FOR.VACANCY_ID'
 ,p_check_column2   => 'PER_RECRUITMENT_ACTIVITY_FOR.RECRUITMENT_ACTIVITY_ID'
 ) then
   open csr_rse;
   fetch csr_rse into l_internal,l_external;
   close csr_rse;
   --
   hr_utility.set_location(l_proc, 20);
   if l_internal = 'Y'
   then
     hr_utility.set_location(l_proc, 30);
     open csr_internal;
     fetch csr_internal into l_ret;
     if csr_internal%found
     then
       close csr_internal;
       hr_utility.set_location(l_proc,40);
       fnd_message.set_name('PER','IRC_412174_VAC_INT_SITE_EXT');
       fnd_message.raise_error;
     end if;
     close csr_internal;
   end if;
   if l_external = 'Y'
   then
     hr_utility.set_location(l_proc, 50);
     open csr_external;
     fetch csr_external into l_ret;
     if csr_external%found
     then
       close csr_external;
       hr_utility.set_location(l_proc,60);
       fnd_message.set_name('PER','IRC_412175_VAC_EXT_SITE_EXT');
       fnd_message.raise_error;
     end if;
     hr_utility.set_location(l_proc,70);
     close csr_external;
   end if;
   --
   hr_utility.set_location('Leaving :' || l_proc,80);
   --
end if;
--
exception
 when app_exception.application_exception then
  if hr_multi_message.exception_add
     (p_associated_column1 =>
     'per_recruitment_activity_for.VACANCY_ID'
     ,p_associated_column2 =>
     'per_recruitment_activity_for.RECRUITMENT_ACTIVITY_ID'
     ) then
    hr_utility.set_location(' Exception :'||l_proc,90);
    raise;
  end if;
  hr_utility.set_location(' Exception :'|| l_proc, 91);
  --
end chk_vacancy_rec_activity;
--
--
-- ---------------------------------------------------------------------------
-- |-----------------------< Chk_rec_activity_dates>-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This check procedure ensures that the external posting start date should
--  be after the Internal posting start date.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--
-- Post Success:
--   Processing continues if the check procedure does not throw any error.
--
--
-- Post Failure:
--
--  An application error is raised if the internal posting start date is
--  greater than external posting date
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_rec_activity_dates
  (p_vacancy_id            in  per_recruitment_activity_for.vacancy_id%type
  ,p_rec_activity_id             in
   per_recruitment_activity_for.recruitment_activity_id%type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_rec_activity_dates';
  l_ret varchar2(1);
  l_internal irc_all_recruiting_sites.internal%type;
  l_external irc_all_recruiting_sites.external%type;
  l_start_date per_recruitment_activities.date_start%type;
  l_start_date_exists per_recruitment_activities.date_start%type;
  l_vacancy_id  per_recruitment_activity_for.vacancy_id%type;
    cursor csr_internal is
--
  select pra.date_start
    from irc_all_recruiting_sites irs
        ,per_recruitment_activities pra
        ,per_recruitment_activity_for prf
   where irs.recruiting_site_id = pra.recruiting_site_id
     and pra.recruitment_activity_id = prf.recruitment_activity_id
     and irs.internal = 'Y'
     and prf.vacancy_id = p_vacancy_id;
--
  cursor csr_external is
  select pra.date_start
    from irc_all_recruiting_sites irs
        ,per_recruitment_activities pra
        ,per_recruitment_activity_for prf
   where irs.recruiting_site_id = pra.recruiting_site_id
     and pra.recruitment_activity_id = prf.recruitment_activity_id
     and irs.external = 'Y' and
     prf.vacancy_id = p_vacancy_id;
--
  cursor csr_rse is
     select irs.internal
           ,irs.external
           ,pra.date_start
       from irc_all_recruiting_sites irs
           ,per_recruitment_activities pra
      where pra.recruitment_activity_id = p_rec_activity_id
        and pra.recruiting_site_id = irs.recruiting_site_id;
--
Begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
  if hr_multi_message.no_exclusive_error
  (p_check_column1   => 'PER_RECRUITMENT_ACTIVITY_FOR.VACANCY_ID'
  ,p_check_column2   => 'PER_RECRUITMENT_ACTIVITY_FOR.RECRUITMENT_ACTIVITY_ID'
  ) then
--
  hr_utility.set_location(l_proc, 15);
--
  open csr_rse;
  fetch csr_rse into l_internal,l_external,l_start_date;
  close csr_rse;
--
  hr_utility.set_location(l_proc, 20);
--
  if l_internal = 'Y'
  then
--
  hr_utility.set_location(l_proc, 25);
--
    open csr_external;
    fetch csr_external into l_start_date_exists;
    if csr_external%found
    then
--
  hr_utility.set_location(l_proc, 30);
--
      if l_start_date > l_start_date_exists
      then
--
  hr_utility.set_location(l_proc, 35);
--
        close csr_external;
        fnd_message.set_name('PER','IRC_412176_POST_ST_DT_INVALID');
        fnd_message.raise_error;
      end if;
--
  hr_utility.set_location(l_proc, 40);
--
    end if;
--
  hr_utility.set_location(l_proc, 45);
--
    close csr_external;
   end if;
--
  hr_utility.set_location(l_proc, 50);
--
   if l_external = 'Y'
   then
--
  hr_utility.set_location(l_proc, 55);
--
     open csr_internal;
     fetch csr_internal into l_start_date_exists;
     if csr_internal%found
     then
--
  hr_utility.set_location(l_proc, 60);
--
       if l_start_date < l_start_date_exists
       then
--
  hr_utility.set_location(l_proc, 65);
--
         close csr_internal;
         fnd_message.set_name('PER','IRC_412176_POST_ST_DT_INVALID');
         fnd_message.raise_error;
       end if;
--
  hr_utility.set_location(l_proc, 70);
--
     end if;
--
  hr_utility.set_location(l_proc, 75);
--
     close csr_internal;
   end if;
--
  hr_utility.set_location(l_proc, 80);
--
   end if;
--
   hr_utility.set_location('Exiting ' || l_proc, 85);
--
exception
 when app_exception.application_exception then
  if hr_multi_message.exception_add
     (p_associated_column1 =>
     'per_recruitment_activity_for.VACANCY_ID'
     ,p_associated_column2 =>
     'per_recruitment_activity_for.RECRUITMENT_ACTIVITY_ID'
     ) then
    hr_utility.set_location(' Exception :'||l_proc,90);
    raise;
  end if;
  hr_utility.set_location(' Exception :'|| l_proc,95);
  --
end chk_rec_activity_dates;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in per_rcf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Validate Important Attributes
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => per_rcf_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  hr_utility.set_location(l_proc, 20);
  --
  per_rcf_bus.chk_vacancy_id
  (p_vacancy_id => p_rec.vacancy_id
  ,p_business_group_id => p_rec.business_group_id
  ,p_rec_activity_for_id => p_rec.rec_activity_for_id
  ,p_object_version_number => p_rec.object_version_number
  );
  hr_utility.set_location(l_proc, 30);
  --
  per_rcf_bus.chk_rec_activity_id
  (p_rec_activity_id => p_rec.rec_activity_id
  ,p_business_group_id => p_rec.business_group_id
  ,p_rec_activity_for_id => p_rec.rec_activity_for_id
  ,p_object_version_number => p_rec.object_version_number
  );
    hr_utility.set_location(l_proc, 40);
  --
  per_rcf_bus.chk_vacancy_rec_activity
  (p_vacancy_id => p_rec.vacancy_id
  ,p_rec_activity_id => p_rec.rec_activity_id
  );
  --
  hr_utility.set_location(l_proc, 60);
  per_rcf_bus.chk_rec_activity_dates
  (
   p_vacancy_id => p_rec.vacancy_id
  ,p_rec_activity_id => p_rec.rec_activity_id
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in per_rcf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(l_proc, 20);
  --
  per_rcf_bus.chk_non_updateable_args
  (p_rec              => p_rec
  );
  hr_utility.set_location(l_proc, 30);
  --
  per_rcf_bus.chk_vacancy_id
  (p_vacancy_id => p_rec.vacancy_id
  ,p_business_group_id => per_rcf_shd.g_old_rec.business_group_id
  ,p_rec_activity_for_id => p_rec.rec_activity_for_id
  ,p_object_version_number => p_rec.object_version_number
  );
  hr_utility.set_location(l_proc, 50);
  --
  per_rcf_bus.chk_rec_activity_id
  (p_rec_activity_id => p_rec.rec_activity_id
  ,p_business_group_id => per_rcf_shd.g_old_rec.business_group_id
  ,p_rec_activity_for_id => p_rec.rec_activity_for_id
  ,p_object_version_number => p_rec.object_version_number
  );
  hr_utility.set_location(l_proc, 60);
  --
  per_rcf_bus.chk_vacancy_rec_activity
  (p_vacancy_id => p_rec.vacancy_id
  ,p_rec_activity_id => p_rec.rec_activity_id
  );
  --
  hr_utility.set_location(l_proc, 70);
  per_rcf_bus.chk_rec_activity_dates
  (
   p_vacancy_id => p_rec.vacancy_id
  ,p_rec_activity_id => p_rec.rec_activity_id
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_rcf_shd.g_rec_type
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
end per_rcf_bus;

/
