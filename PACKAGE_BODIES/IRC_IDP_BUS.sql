--------------------------------------------------------
--  DDL for Package Body IRC_IDP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IDP_BUS" as
/* $Header: iridprhi.pkb 120.0.12010000.2 2008/08/05 10:49:00 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_idp_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_default_posting_id          number         default null;

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
  (p_rec in irc_idp_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.default_posting_id is not null)  and (
    nvl(irc_idp_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(irc_idp_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.default_posting_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'IRC_DEFAULT_POSTINGS'
      ,p_attribute_category              => p_rec.attribute_category
      ,p_attribute1_name                 => 'ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.attribute1
      ,p_attribute2_name                 => 'ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.attribute2
      ,p_attribute3_name                 => 'ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.attribute3
      ,p_attribute4_name                 => 'ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.attribute4
      ,p_attribute5_name                 => 'ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.attribute5
      ,p_attribute6_name                 => 'ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.attribute6
      ,p_attribute7_name                 => 'ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.attribute7
      ,p_attribute8_name                 => 'ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.attribute8
      ,p_attribute9_name                 => 'ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.attribute9
      ,p_attribute10_name                => 'ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.attribute10
      ,p_attribute11_name                => 'ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.attribute11
      ,p_attribute12_name                => 'ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.attribute12
      ,p_attribute13_name                => 'ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.attribute13
      ,p_attribute14_name                => 'ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.attribute14
      ,p_attribute15_name                => 'ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.attribute15
      ,p_attribute16_name                => 'ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.attribute16
      ,p_attribute17_name                => 'ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.attribute17
      ,p_attribute18_name                => 'ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.attribute18
      ,p_attribute19_name                => 'ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.attribute19
      ,p_attribute20_name                => 'ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.attribute20
      ,p_attribute21_name                => 'ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.attribute21
      ,p_attribute22_name                => 'ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.attribute22
      ,p_attribute23_name                => 'ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.attribute23
      ,p_attribute24_name                => 'ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.attribute24
      ,p_attribute25_name                => 'ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.attribute25
      ,p_attribute26_name                => 'ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.attribute26
      ,p_attribute27_name                => 'ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.attribute27
      ,p_attribute28_name                => 'ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.attribute28
      ,p_attribute29_name                => 'ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.attribute29
      ,p_attribute30_name                => 'ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.attribute30
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
  (p_rec in irc_idp_shd.g_rec_type
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
  IF NOT irc_idp_shd.api_updating
      (p_default_posting_id                   => p_rec.default_posting_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
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
--  ---------------------------------------------------------------------------
--  |-----------------------------<  chk_one_id >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that only one of organization id, job id and position id is entered.
--
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
procedure chk_one_id
  (p_job_id                in     irc_default_postings.job_id%TYPE
  ,p_organization_id       in     irc_default_postings.organization_id%TYPE
  ,p_position_id           in     irc_default_postings.position_id%TYPE
  )
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_one_id';
  l_flag              number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
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
    hr_utility.set_message(800, 'IRC_412090_TOO_MANY_ARGS');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_one_id;

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
  (p_organization_id                 in     irc_default_postings.organization_id%TYPE
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
  if p_organization_id is not null or p_organization_id <> hr_api.g_number then
    open csr_org;
    fetch csr_org into l_org;
    if (csr_org%notfound)
    then
      close csr_org;
      hr_utility.set_message(800, 'IRC_412091_ORG_NOT_EXIST');
      hr_utility.raise_error;
    end if;
    close csr_org;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
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
  (p_job_id                      in     irc_default_postings.job_id%TYPE
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
  if p_job_id is not null or p_job_id <> hr_api.g_number then
    open csr_job;
    fetch csr_job into l_job;
    --
    if (csr_job%notfound) then
      --
      close csr_job;
      hr_utility.set_message(800, 'IRC_412037_RTM_INV_JOB_ID');
      hr_utility.raise_error;
      --
    end if;
    --
    close csr_job;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
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
  (p_position_id                 in     irc_default_postings.position_id%TYPE
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
  if p_position_id is not null and p_position_id <> hr_api.g_number then
    open csr_pos;
    fetch csr_pos into l_pos;
    --
    if (csr_pos%notfound) then
      --
      close csr_pos;
      hr_utility.set_message(800, 'IRC_412092_POS_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
    close csr_pos;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_position_id;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in irc_idp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --

  --
  -- Validate CHK_ONE_ID
  --
  irc_idp_bus.chk_one_id
  (p_job_id                      => p_rec.job_id
  ,p_organization_id             => p_rec.organization_id
  ,p_position_id                 => p_rec.position_id
  );

  --
  -- Validate CHK_POSITION_ID
  --
  irc_idp_bus.chk_position_id
  (p_position_id                 => p_rec.position_id
  );

  --
  -- Validate CHK_JOB_ID
  --
  irc_idp_bus.chk_job_id
  (p_job_id                      => p_rec.job_id
  );

  --
  -- Validate CHK_ORGANIZATION_ID
  --
  irc_idp_bus.chk_organization_id
  (p_organization_id             => p_rec.organization_id
  );


  --
  irc_idp_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in irc_idp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."

  --
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --

  --
  -- Validate CHK_ONE_ID
  --
  irc_idp_bus.chk_one_id
  (p_job_id                      => p_rec.job_id
  ,p_organization_id             => p_rec.organization_id
  ,p_position_id                 => p_rec.position_id
  );

  --
  -- Validate CHK_POSITION_ID
  --
  irc_idp_bus.chk_position_id
  (p_position_id                 => p_rec.position_id
  );

  --
  -- Validate CHK_JOB_ID
  --
  irc_idp_bus.chk_job_id
  (p_job_id                      => p_rec.job_id
  );

  --
  -- Validate CHK_ORGANIZATION_ID
  --
  irc_idp_bus.chk_organization_id
  (p_organization_id             => p_rec.organization_id
  );

  --
  irc_idp_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_idp_shd.g_rec_type
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
end irc_idp_bus;

/
