--------------------------------------------------------
--  DDL for Package Body PER_PSH_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PSH_BUS" as
/* $Header: pepshrhi.pkb 120.2 2006/05/08 19:35 tpapired noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_psh_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_sharing_instance_id         number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_sharing_instance_id                  in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , per_scorecard_sharing psh
         , per_all_people_f ppf
     where psh.sharing_instance_id = p_sharing_instance_id
       and psh.person_id = ppf.person_id
       and ppf.business_group_id = pbg.business_group_id;
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
    ,p_argument           => 'sharing_instance_id'
    ,p_argument_value     => p_sharing_instance_id
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
        => nvl(p_associated_column1,'SHARING_INSTANCE_ID')
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
  (p_sharing_instance_id                  in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , per_scorecard_sharing psh
         , per_all_people_f ppf
     where psh.sharing_instance_id = p_sharing_instance_id
       and psh.person_id = ppf.person_id
       and ppf.business_group_id = pbg.business_group_id;
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
    ,p_argument           => 'sharing_instance_id'
    ,p_argument_value     => p_sharing_instance_id
    );
  --
  if ( nvl(per_psh_bus.g_sharing_instance_id, hr_api.g_number)
       = p_sharing_instance_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_psh_bus.g_legislation_code;
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
    per_psh_bus.g_sharing_instance_id         := p_sharing_instance_id;
    per_psh_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  (p_rec in per_psh_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.sharing_instance_id is not null)  and (
    nvl(per_psh_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(per_psh_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.sharing_instance_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_SCORECARD_SHARING'
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
  (p_rec in per_psh_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_psh_shd.api_updating
      (p_sharing_instance_id               => p_rec.sharing_instance_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- There are no non-updateable args to check here.
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_scorecard_id >----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_scorecard_id
  (p_scorecard_id          IN number
  ,p_person_id             IN number
  ) IS

  --
  l_proc          varchar2(72) := g_package || 'chk_scorecard_id';
  l_scorecard_person_id       number;
  --
  CURSOR csr_chk_scard_id IS
  SELECT psc.person_id
  FROM   per_personal_scorecards psc
  WHERE  psc.scorecard_id = p_scorecard_id;
--
BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Check mandatory parameters have been set
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person_id'
    ,p_argument_value => p_person_id
    );
  IF p_scorecard_id IS NOT null THEN
    --
    -- Check that scorecard exists.
    --
    hr_utility.set_location(l_proc, 20);
    OPEN  csr_chk_scard_id;
    FETCH csr_chk_scard_id INTO l_scorecard_person_id;
    CLOSE csr_chk_scard_id;
    --
    IF l_scorecard_person_id IS null THEN
      fnd_message.set_name('PER', 'HR_WPM_INVALID_SCORECARD');
      fnd_message.raise_error;
    END IF;
    --
    -- Check that scorecard is not shared with owner of scorecard
    --
    IF l_scorecard_person_id = p_person_id THEN
      fnd_message.set_name('PER', 'HR_WPM_INV_SHR_SAME_PER');
      fnd_message.raise_error;
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 970);
  --
EXCEPTION

  WHEN app_exception.application_exception THEN
    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_SCORECARD_SHARING.SCORECARD_ID')
    THEN
      hr_utility.set_location(' Leaving:'|| l_proc, 980);
      RAISE;
    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc, 990);

END chk_scorecard_id;
--
-----------------------------------------------------------------------------
--------------------------------<chk_person_id>------------------------------
-----------------------------------------------------------------------------
--
procedure chk_person_id
(p_person_id          in      per_objectives.owning_person_id%TYPE
)
is
--
l_exists	     varchar2(1);
  l_proc               varchar2(72)  :=  g_package||'chk_person_id';
  --
  -- Cursor to check if person is valid
  -- as of sys date
  --
  Cursor csr_person_valid
    is
    select 'Y'
    from  per_all_people_f
    where person_id = p_person_id
    and	  trunc(sysdate) between
          effective_start_date and nvl(effective_end_date,hr_api.g_eot);
    --
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
  --
  hr_utility.set_location('Entering:'|| l_proc, 2);
  --
  if p_person_id is not null then
     -- check if person is valid
     open csr_person_valid;
     fetch csr_person_valid into l_exists;
     if csr_person_valid%notfound then
        close csr_person_valid;
       fnd_message.set_name('PER','HR_WPM_INV_PERSON');
       fnd_message.raise_error;
     else
        close csr_person_valid;
     end if;
     hr_utility.set_location(l_proc, 5);
  end if;
  --
 hr_utility.set_location('Leaving: '|| l_proc, 10);
--
exception
when app_exception.application_exception then
     if hr_multi_message.exception_add
          (p_associated_column1      => 'PER_SCORECARD_SHARING.PERSON_ID'
           ) then
        raise;
     end if;

end chk_person_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_scorecard_person_unique >---------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_scorecard_person_unique
  (p_scorecard_id          IN number
  ,p_person_id             IN number
  ) IS

  --
  l_proc          varchar2(72) := g_package || 'chk_scorecard_person_unique';
  l_exists        varchar2(1);
  --
  CURSOR csr_chk_unique IS
  SELECT 'Y'
  FROM   per_scorecard_sharing
  WHERE  scorecard_id = p_scorecard_id
  AND    person_id    = p_person_id;
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  OPEN  csr_chk_unique;
  FETCH csr_chk_unique INTO l_exists;
  CLOSE csr_chk_unique;
  --
  -- Check whether scorecard and person combination already exists
  --
  IF nvl(l_exists,'N')='Y' THEN
    fnd_message.set_name('PER', 'HR_WPM_INV_SCORE_PERSON_COMB');
    fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 70);
  --
EXCEPTION
  WHEN app_exception.application_exception THEN
    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_SCORECARD_SHARING.SCORECARD_ID'
      ,p_associated_column2 => 'PER_SCORECARD_SHARING.PERSON_ID')
    THEN
      hr_utility.set_location(' Leaving:'|| l_proc, 80);
      RAISE;
    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc, 90);

END chk_scorecard_person_unique;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec               in per_psh_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS.
  --
  -- Validate Dependent Attributes
  --
  --
  -- check if person_id is valid
  --
  per_psh_bus.chk_person_id
  (p_person_id                 => p_rec.person_id
  );
  --
  -- check if scorecard_id is valid
  --
  per_psh_bus.chk_scorecard_id
  (p_scorecard_id              => p_rec.scorecard_id
  ,p_person_id                 => p_rec.person_id
  );
  --
  -- check whetehr scorecard_id person_id combination already exists
  --
  per_psh_bus.chk_scorecard_person_unique
  (p_scorecard_id              => p_rec.scorecard_id
  ,p_person_id                 => p_rec.person_id
  );
  --
  per_psh_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec               in per_psh_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS.
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --
  -- check if person_id is valid
  --
  per_psh_bus.chk_person_id
  (p_person_id                 => p_rec.person_id
  );
  --
  -- check if scorecard_id is valid
  --
  per_psh_bus.chk_scorecard_id
  (p_scorecard_id              => p_rec.scorecard_id
  ,p_person_id                 => p_rec.person_id
  );
  --
  per_psh_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_psh_shd.g_rec_type
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
end per_psh_bus;

/
