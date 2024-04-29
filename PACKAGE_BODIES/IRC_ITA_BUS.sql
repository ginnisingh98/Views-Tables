--------------------------------------------------------
--  DDL for Package Body IRC_ITA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_ITA_BUS" as
/* $Header: iritarhi.pkb 120.1 2005/10/04 06:26 kthavran noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_ita_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_template_association_id     number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_template_association_id              in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- irc_template_associations and PER_BUSINESS_GROUPS_PERF
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , irc_template_associations ita
      --   , EDIT_HERE table_name(s) 333
     where ita.template_association_id = p_template_association_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'template_association_id'
    ,p_argument_value     => p_template_association_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
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
        => nvl(p_associated_column1,'TEMPLATE_ASSOCIATION_ID')
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
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
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
  (p_template_association_id              in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- irc_template_associations and PER_BUSINESS_GROUPS_PERF
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , irc_template_associations ita
      --   , EDIT_HERE table_name(s) 333
     where ita.template_association_id = p_template_association_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
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
    ,p_argument           => 'template_association_id'
    ,p_argument_value     => p_template_association_id
    );
  --
  if ( nvl(irc_ita_bus.g_template_association_id, hr_api.g_number)
       = p_template_association_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := irc_ita_bus.g_legislation_code;
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
    irc_ita_bus.g_template_association_id     := p_template_association_id;
    irc_ita_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in irc_ita_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);

--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_ita_shd.api_updating
      (p_template_association_id           => p_rec.template_association_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
  if irc_ita_shd.g_old_rec.template_association_id <> p_rec.template_association_id then
      hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'template_association_id'
         ,p_base_table => irc_ita_shd.g_tab_nam
         );
  end if;
  --
  exception
  when l_error then
    hr_api.argument_changed_error
    (p_api_name => l_proc
     ,p_argument => l_argument);
  when others then
    raise;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< chk_template_id >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid template id
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_template_association_id
--   p_template_id
--   p_object_version_number
-- Post Success:
--   Processing continues if template id is not null and unique
--
-- Post Failure:
--   An application error is raised if template id is null or exists already
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_template_id
  (p_template_association_id in irc_template_associations.template_association_id%TYPE
  ,p_template_id in irc_template_associations.template_id%TYPE
  ,p_object_version_number in irc_template_associations.object_version_number%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_template_id';
  l_template_id varchar2(1);
  l_api_updating boolean;
--
  cursor csr_template is
     select null
        from  xdo_templates_b
        where template_id = p_template_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
--
  l_api_updating := irc_ita_shd.api_updating
                     (p_template_association_id       => p_template_association_id
                     ,p_object_version_number => p_object_version_number);
  hr_utility.set_location(l_proc,20);
  if ((l_api_updating
                 and
            nvl(irc_ita_shd.g_old_rec.template_id,hr_api.g_number) <>
            nvl(p_template_id, hr_api.g_number))
                             or
  (NOT l_api_updating)) then
   --
     if(p_template_id is not null)
     then
        open  csr_template;
        fetch csr_template into l_template_id;
        hr_utility.set_location(l_proc,30);
        if(csr_template%notfound)
        then
           close csr_template;
           fnd_message.set_name('PER','IRC_412326_OFFER_INV_TEMPLT_ID');
           hr_multi_message.add
           (p_associated_column1      => 'IRC_TEMPLATE_ASSOCIATIONS.TEMPLATE_ID'
           );
        else
           close csr_template;
        end if;
     else
        fnd_message.set_name('PER','IRC_412327_OFFER_NULL_TMPLT_ID');
        hr_multi_message.add
        (p_associated_column1      => 'IRC_TEMPLATE_ASSOCIATIONS.TEMPLATE_ID'
        );

     end if;
   end if;
--
hr_utility.set_location(' Leaving:'||l_proc,40);
--
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_TEMPLATE_ASSOCIATIONS.TEMPLATE_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);
End chk_template_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_organization_id >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that a organization id exists in table hr_all_organization_units.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_organization_id
--
--  Post Success:
--    If a row does exist in hr_all_organization_units for the given organization id then
--    processing continues.
--
--  Post Failure:
--    If a row does not exist in hr_all_organization_units for the given organization id then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_organization_id
  (p_organization_id                 in     irc_template_associations.organization_id%TYPE
  )
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_organization_id';
  l_org varchar2(1);
  cursor csr_org is
     select null
       from hr_all_organization_units haou
      where haou.organization_id = p_organization_id;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if hr_multi_message.no_exclusive_error
  (p_check_column1      => 'IRC_TEMPLATE_ASSOCIATIONS.TEMPLATE_ID'
   ) then
  --

  if ((irc_ita_shd.g_old_rec.template_association_id is null and p_organization_id is not null)
  or (irc_ita_shd.g_old_rec.template_association_id is not null
  and nvl(irc_ita_shd.g_old_rec.organization_id, hr_api.g_number)
                         <> nvl(p_organization_id, hr_api.g_number))) then
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check that the organization ID is linked to a
    -- valid organization on HR_ALL_ORGANIZATON_UNITS
    --
    open csr_org;
    fetch csr_org into l_org;
    if (csr_org%notfound)
    then
      close csr_org;
      fnd_message.set_name('PER','IRC_412091_ORG_NOT_EXIST');
      fnd_message.raise_error;
    end if;
    close csr_org;
    --
    hr_utility.set_location(l_proc, 30);
    --
  end if;
  end if; -- no exclusive error
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_TEMPLATE_ASSOCIATIONS.ORGANIZATION_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_organization_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------------------<  chk_job_id >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that a job id exists in table per_jobs.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_job_id
--
--  Post Success:
--    If a row does exist in per_jobs for the given job id then
--    processing continues.
--
--  Post Failure:
--    If a row does not exist in per_jobs for the given job id then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_job_id
  (p_job_id                      in     irc_template_associations.job_id%TYPE
  )
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_job_id';
  l_job varchar2(1);
  cursor csr_job is
     select null
       from per_jobs pj
      where pj.job_id = p_job_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if hr_multi_message.no_exclusive_error
  (p_check_column1      => 'IRC_TEMPLATE_ASSOCIATIONS.TEMPLATE_ID'
   ) then
  --

  if ((irc_ita_shd.g_old_rec.template_association_id is null and p_job_id is not null)
  or (irc_ita_shd.g_old_rec.template_association_id is not null
  and nvl(irc_ita_shd.g_old_rec.job_id, hr_api.g_number)
                         <> nvl(p_job_id, hr_api.g_number))) then
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check that the job ID is linked to a
    -- valid job on per_jobs
    --
    open csr_job;
    fetch csr_job into l_job;
    --
    if (csr_job%notfound) then
      --
      close csr_job;
      fnd_message.set_name('PER','IRC_412037_RTM_INV_JOB_ID');
      fnd_message.raise_error;
      --
    end if;
    --
    close csr_job;
    hr_utility.set_location(l_proc, 30);
    --
  end if;
  end if; -- no exclusive error
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_TEMPLATE_ASSOCIATIONS.JOB_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_job_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_position_id >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that a position id exists in table hr_all_positions_f.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_position_id
--
--  Post Success:
--    If a row does exist in hr_all_positions_f for the given position id then
--    processing continues.
--
--  Post Failure:
--    If a row does not exist in hr_all_positions_f for the given position id then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_position_id
  (p_position_id                 in     irc_template_associations.position_id%TYPE
  )
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_position_id';
  l_pos varchar2(1);
  cursor csr_pos is
    select null
      from hr_all_positions_f hapf
    where hapf.position_id = p_position_id
      and trunc(sysdate) between hapf.effective_start_date
      and hapf.effective_end_date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if hr_multi_message.no_exclusive_error
  (p_check_column1      => 'IRC_TEMPLATE_ASSOCIATIONS.TEMPLATE_ID'
   ) then
  --

  if ((irc_ita_shd.g_old_rec.template_association_id is null and p_position_id is not null)
  or (irc_ita_shd.g_old_rec.template_association_id is not null
  and nvl(irc_ita_shd.g_old_rec.position_id, hr_api.g_number)
                         <> nvl(p_position_id, hr_api.g_number))) then
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check that the Position ID is linked to a
    -- valid position on HR_ALL_POSITIONS_F
    --
    open csr_pos;
    fetch csr_pos into l_pos;
    --
    if (csr_pos%notfound) then
      --
      close csr_pos;
      fnd_message.set_name('PER','IRC_412092_POS_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
    close csr_pos;
    hr_utility.set_location(l_proc, 30);
    --
  end if;
  end if; -- no exclusive error
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_TEMPLATE_ASSOCIATIONS.POSITION_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_position_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_job_position_organization >------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that only one of organization id, job id and position id is entered.
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_organization_id
--    p_job_id
--    p_position_id
--
--  Post Success:
--    If only one of the input parameters is not null then
--    processing continues.
--
--  Post Failure:
--    If two or more of the input parameters are not null
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_job_position_organization
  (p_job_id                in     irc_template_associations.job_id%TYPE
  ,p_organization_id       in     irc_template_associations.organization_id%TYPE
  ,p_position_id           in     irc_template_associations.position_id%TYPE
  )
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_job_position_organization';
  l_flag              varchar2(1);
  --

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if hr_multi_message.no_exclusive_error
  (p_check_column1      => 'IRC_TEMPLATE_ASSOCIATIONS.TEMPLATE_ID'
   ) then
  --

  l_flag := 0;
  --
  if (p_job_id is not null) then
   l_flag := l_flag + 1;
  end if;
  --
  if (p_position_id is not null) then
   l_flag := l_flag + 1;
  end if;
  --
  if (p_organization_id is not null) then
    l_flag := l_flag + 1;
  end if;
  --
  if (l_flag > 1) then
    fnd_message.set_name('PER','IRC_412090_TOO_MANY_ARGS');
    fnd_message.raise_error;
  end if;
  end if; -- no exclusive error
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_TEMPLATE_ASSOCIATIONS.JOB_ID'
         ,p_associated_column2      => 'IRC_TEMPLATE_ASSOCIATIONS.ORGANIZATION_ID'
         ,p_associated_column3      => 'IRC_TEMPLATE_ASSOCIATIONS.POSITION_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_job_position_organization;

--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_duplicate_template_id >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Verifies for duplicate template id.
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_template_id
--    p_organization_id
--    p_job_id
--    p_position_id
--
--  Post Success:
--    If duplicate entry is not found then
--    processing continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_duplicate_template_id
  (p_template_id           in     irc_template_associations.template_id%TYPE
  ,p_job_id                in     irc_template_associations.job_id%TYPE
  ,p_organization_id       in     irc_template_associations.organization_id%TYPE
  ,p_position_id           in     irc_template_associations.position_id%TYPE
  )
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_duplicate_template_id';
  l_flag              varchar2(1);
  --
  cursor csr_org is
     select null
       from irc_template_associations ita
       where ita.organization_id = p_organization_id
       and ita.template_id = p_template_id;
  --
  cursor csr_pos is
     select null
       from irc_template_associations ita
       where ita.position_id = p_position_id
       and ita.template_id = p_template_id;
  --
  cursor csr_job is
     select null
       from irc_template_associations ita
       where ita.job_id = p_job_id
       and ita.template_id = p_template_id;
  --

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if hr_multi_message.no_exclusive_error
  (p_check_column1      => 'IRC_TEMPLATE_ASSOCIATIONS.TEMPLATE_ID'
   ) then
  --
  --
  if (p_job_id is not null) then
   --
    open csr_job;
    fetch csr_job into l_flag;
    --
    if (csr_job%found) then
      --
      close csr_job;
      fnd_message.set_name('PER','IRC_412328_OFR_DUP_TEMPLATE_ID');
      fnd_message.raise_error;
      --
    end if;
   --
  end if;
  --
  if (p_position_id is not null) then
    --
    open csr_pos;
    fetch csr_pos into l_flag;
    --
    if (csr_pos%found) then
      --
      close csr_pos;
      fnd_message.set_name('PER','IRC_412328_OFR_DUP_TEMPLATE_ID');
      fnd_message.raise_error;
      --
    end if;
   --

  end if;
  --
  if (p_organization_id is not null) then
   --
    open csr_org;
    fetch csr_org into l_flag;
    --
    if (csr_org%found) then
      --
      close csr_org;
      fnd_message.set_name('PER','IRC_412328_OFR_DUP_TEMPLATE_ID');
      fnd_message.raise_error;
      --
    end if;
   --
  end if;
  --
  end if; -- no exclusive error
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_TEMPLATE_ASSOCIATIONS.JOB_ID'
         ,p_associated_column2      => 'IRC_TEMPLATE_ASSOCIATIONS.ORGANIZATION_ID'
         ,p_associated_column3      => 'IRC_TEMPLATE_ASSOCIATIONS.POSITION_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_duplicate_template_id;

--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_default_association >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that default association exists as a lookup code on HR_LOOKUPS
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_template_association_id
--    p_object_version_number
--    p_default_association
--
--  Post Success:
--    default association exists as a lookup code in HR_LOOKUPS
--  Post Failure:
--    An application error is raised and processing is terminated if:
--    per information6 and 9 does not exist as a lookup code in
--    HR_LOOKUPS
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_default_association
 ( p_template_association_id          in  irc_template_associations.template_association_id%TYPE
  ,p_object_version_number in irc_template_associations.object_version_number%TYPE
  ,p_creation_date in irc_template_associations.creation_date%TYPE
  ,p_default_association           in irc_template_associations.default_association%TYPE
 ) IS

--   Local declarations
     l_proc  VARCHAR2(72) := g_package||'chk_default_association';
     l_api_updating boolean;
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if hr_multi_message.no_exclusive_error
  (p_check_column1      => 'IRC_TEMPLATE_ASSOCIATIONS.TEMPLATE_ID'
   ) then
  --
  l_api_updating := irc_ita_shd.api_updating
          (p_template_association_id             => p_template_association_id
           ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Check if the value for default_association is set on insert or has
  -- changed on update.
  --
  if ((nvl(p_default_association,hr_api.g_varchar2) <>
        nvl(irc_ita_shd.g_old_rec.default_association,hr_api.g_varchar2)
                     and l_api_updating) or
       (NOT l_api_updating))

  then
    --
    -- Check that default_association exists in hr_lookups for the
    -- lookup type 'YES_NO' with an enabled flag set to 'Y'.
    --
    hr_utility.set_location(l_proc,30);
    if hr_api.not_exists_in_hr_lookups
      (p_lookup_type           => 'YES_NO'
      ,p_lookup_code           => p_default_association
      ,p_effective_date        => p_creation_date
      )
    then
      --
      hr_utility.set_location(l_proc,40);
      fnd_message.set_name('PER','IRC_412329_OFR_INV_DEF_TMP_ASS');
      fnd_message.raise_error;
      --
    end if;
  end if;
  end if; -- no exclusive error
 hr_utility.set_location('Leaving: '||l_proc,50);
--
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_TEMPLATE_ASSOCIATIONS.DEFAULT_ASSOCIATION'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 60);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 70);
End chk_default_association;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_dates >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures valid dates are entered
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_template_association_id
--   p_object_version_number
--   p_start_date
--   p_end_date
-- Post Success:
--   Processing continues if start and end dates are valid and from date is lesser
--     to date
--
-- Post Failure:
--   An application error is raised if dates entered are not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_dates
  (p_template_association_id in irc_template_associations.template_association_id%TYPE
  ,p_object_version_number in irc_template_associations.object_version_number%TYPE
  ,p_start_date in irc_template_associations.start_date%TYPE
  ,p_end_date in irc_template_associations.end_date%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_dates';
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if hr_multi_message.no_exclusive_error
  (p_check_column1      => 'IRC_TEMPLATE_ASSOCIATIONS.TEMPLATE_ID'
   ) then
  --
  l_api_updating := irc_ita_shd.api_updating
          (p_template_association_id             => p_template_association_id
           ,p_object_version_number => p_object_version_number);
    --
  hr_utility.set_location(l_proc,20);
  if ((l_api_updating
    and
       (nvl(irc_ita_shd.g_old_rec.start_date, hr_api.g_date) <>
       nvl(p_start_date, hr_api.g_date) or
       nvl(irc_ita_shd.g_old_rec.end_date, hr_api.g_date) <>
       nvl(p_end_date, hr_api.g_date)))
    or
       (NOT l_api_updating)) then
  --
    hr_utility.set_location(l_proc,30);
    if (p_start_date is not null)
    then
       hr_utility.set_location(l_proc,40);
    --
       if (p_start_date > nvl(p_end_date,hr_api.g_eot))
       then
         fnd_message.set_name('PER','IRC_ALL_DATE_START_END');
         hr_multi_message.add
         (p_associated_column1      => 'IRC_TEMPLATE_ASSOCIATIONS.START_DATE'
          ,p_associated_column2      => 'IRC_TEMPLATE_ASSOCIATIONS.END_DATE'
         );
       end if;
    end if;
  end if;
  end if; -- no exclusive error
--
  hr_utility.set_location(' Leaving:'||l_proc,50);
--
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'IRC_TEMPLATE_ASSOCIATIONS.START_DATE'
         ,p_associated_column2      => 'IRC_TEMPLATE_ASSOCIATIONS.END_DATE'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 60);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 70);
End chk_dates;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in irc_ita_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS.

  --
  -- Validate CHK_TEMPLATE_ID
  --
  irc_ita_bus.chk_template_id
  (p_template_association_id   =>  p_rec.template_association_id
  ,p_template_id               =>  p_rec.template_id
  ,p_object_version_number     =>  p_rec.object_version_number
  );

  --
  -- Validate CHK_DEFAULT_ASSOCIATION
  --
  irc_ita_bus.chk_default_association
  (p_template_association_id        => p_rec.template_association_id
  ,p_object_version_number          => p_rec.object_version_number
  ,p_creation_date                  => p_rec.start_date
  ,p_default_association            => p_rec.default_association
  );

  --
  -- Validate CHK_ORGANIZATION_ID
  --
  irc_ita_bus.chk_organization_id
  (p_organization_id           =>  p_rec.organization_id
  );

  --
  -- Validate CHK_JOB_ID
  --
  irc_ita_bus.chk_job_id
  (p_job_id                    =>  p_rec.job_id
  );

  --
  -- Validate CHK_POSITION_ID
  --
  irc_ita_bus.chk_position_id
  (p_position_id               =>  p_rec.position_id
  );

  --
  -- Validate CHK_JOB_POSITION_ORGANIZATION
  --
  irc_ita_bus.chk_job_position_organization
  (p_job_id                    =>  p_rec.job_id
  ,p_organization_id           =>  p_rec.organization_id
  ,p_position_id               =>  p_rec.position_id
  );

  --
  -- Validate CHK_JOB_POSITION_ORGANIZATION
  --
  irc_ita_bus.chk_duplicate_template_id
  (p_template_id               =>  p_rec.template_id
  ,p_job_id                    =>  p_rec.job_id
  ,p_organization_id           =>  p_rec.organization_id
  ,p_position_id               =>  p_rec.position_id
  );


  --
  -- Validate CHK_DATES
  --
  irc_ita_bus.chk_dates
  (p_template_association_id => p_rec.template_association_id
  ,p_object_version_number   => p_rec.object_version_number
  ,p_start_date              => p_rec.start_date
  ,p_end_date                => p_rec.end_date
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in irc_ita_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --

  --
  -- Validate CHK_TEMPLATE_ID
  --
  irc_ita_bus.chk_template_id
  (p_template_association_id   =>  p_rec.template_association_id
  ,p_template_id               =>  p_rec.template_id
  ,p_object_version_number     =>  p_rec.object_version_number
  );

  --
  -- Validate CHK_DEFAULT_ASSOCIATION
  --
  irc_ita_bus.chk_default_association
  (p_template_association_id        => p_rec.template_association_id
  ,p_object_version_number          => p_rec.object_version_number
  ,p_creation_date                  => p_rec.start_date
  ,p_default_association            => p_rec.default_association
  );

  --
  -- Validate CHK_ORGANIZATION_ID
  --
  irc_ita_bus.chk_organization_id
  (p_organization_id           =>  p_rec.organization_id
  );

  --
  -- Validate CHK_JOB_ID
  --
  irc_ita_bus.chk_job_id
  (p_job_id                    =>  p_rec.job_id
  );

  --
  -- Validate CHK_POSITION_ID
  --
  irc_ita_bus.chk_position_id
  (p_position_id               =>  p_rec.position_id
  );

  --
  -- Validate CHK_JOB_POSITION_ORGANIZATION
  --
  irc_ita_bus.chk_job_position_organization
  (p_job_id                    =>  p_rec.job_id
  ,p_organization_id           =>  p_rec.organization_id
  ,p_position_id               =>  p_rec.position_id
  );

  --
  -- Validate CHK_DATES
  --
  irc_ita_bus.chk_dates
  (p_template_association_id => p_rec.template_association_id
  ,p_object_version_number   => p_rec.object_version_number
  ,p_start_date              => p_rec.start_date
  ,p_end_date                => p_rec.end_date
  );


  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_ita_shd.g_rec_type
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
end irc_ita_bus;

/
