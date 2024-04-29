--------------------------------------------------------
--  DDL for Package Body PER_CHK_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CHK_BUS" as
/* $Header: pechkrhi.pkb 115.7 2002/12/04 12:17:45 pkakar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_chk_bus.';  -- Global package name
--
--
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_checklist_item_id           number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_checklist_item_id                    in number
  ) is
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_checklist_items chk
         , per_all_people_f peo
     where chk.checklist_item_id = p_checklist_item_id
     and chk.person_id = peo.person_id
     and pbg.business_group_id = peo.business_group_id;
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
    ,p_argument           => 'checklist_item_id'
    ,p_argument_value     => p_checklist_item_id
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
  (p_checklist_item_id                    in     number
  )
  Return Varchar2 Is
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , per_checklist_items chk
         , per_all_people_f peo
     where chk.checklist_item_id = p_checklist_item_id
     and chk.person_id = peo.person_id
     and pbg.business_group_id = peo.business_group_id;
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
    ,p_argument           => 'checklist_item_id'
    ,p_argument_value     => p_checklist_item_id
    );
  --
  if ( nvl(per_chk_bus.g_checklist_item_id, hr_api.g_number)
       = p_checklist_item_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_chk_bus.g_legislation_code;
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
    per_chk_bus.g_checklist_item_id := p_checklist_item_id;
    per_chk_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_non_updateable_args >-----------------------|
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
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   (person_id, item_code, item, checklist_item_id)  have been altered.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
Procedure chk_non_updateable_args( p_effective_date in date
                                   ,p_rec in per_chk_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema
  --
  if not per_chk_shd.api_updating
    (p_checklist_item_id           => p_rec.checklist_item_id,
     p_object_version_number       => p_rec.object_version_number) then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP', '5');
  end if;
  --
  hr_utility.set_location(l_proc, 6);
  --
  if nvl(p_rec.checklist_item_id,hr_api.g_number)
     <> nvl(per_chk_shd.g_old_rec.checklist_item_id,hr_api.g_number) then
     l_argument := 'checklist_item_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 7);
  --
  if nvl(p_rec.person_id,hr_api.g_number)
     <>  nvl(per_chk_shd.g_old_rec.person_id,hr_api.g_number) then
     l_argument := 'person_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 8);
  --
  if nvl(p_rec.item_code,hr_api.g_varchar2)
     <>  nvl(per_chk_shd.g_old_rec.item_code,hr_api.g_varchar2) then
     l_argument := 'item_code';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 9);
  --
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 14);
end chk_non_updateable_args;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_is_person_valid >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that person id is valid and not null
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   Status
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_is_person_valid(p_effective_date    in date,
                              p_person_id in per_checklist_items.person_id%type) IS
  --
  l_proc         varchar2(72) := g_package||'chk_is_person_valid';
  --
  CURSOR chk_valid_person
  IS
  SELECT person_id
  FROM per_all_people_f
  WHERE person_id = p_person_id;

  l_person_id per_checklist_items.person_id%TYPE;

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_utility.set_location('At:'||l_proc, 30);

  OPEN chk_valid_person ;
  FETCH chk_valid_person into l_person_id;
  IF chk_valid_person%NOTFOUND THEN
    CLOSE chk_valid_person;
    -- Error Message  : Invalid person id
    fnd_message.set_name('PER', 'HR_52783_CHK_INVALID_PER');
    fnd_message.raise_error;
  END IF;

  CLOSE chk_valid_person;

  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_is_person_valid;
--
-- ----------------------------------------------------------------------------
-- |------< chk_is_status_valid >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that status is valid and not null
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   Status
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_is_status_valid(p_effective_date in date,
                              p_checklist_item_id in number,
                              p_status in per_checklist_items.status%type )
is
  --
  l_proc         varchar2(72) := g_package||'chk_is_status_valid';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if (p_checklist_item_id is not null and p_status is not null and
          (nvl(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
             <> nvl(p_status,hr_api.g_varchar2)))
  or ( p_checklist_item_id is null and p_status is not null)
  then

     IF hr_api.not_exists_in_hr_lookups( p_effective_date => p_effective_date,
                                         p_lookup_type    => 'CHECKLIST_STATUS',
                                         p_lookup_code    => p_status ) THEN
        -- Error Message  : Invalid checklist status
        fnd_message.set_name('PER', 'HR_52781_CHK_INVALID_STATUS');
        fnd_message.raise_error;
     END IF;

  end if;
    --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_is_status_valid;
--
-- ----------------------------------------------------------------------------
-- |------< chk_is_itemcode_valid >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check whether the primary code entered for
--   a person is unique.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   item_code of record being inserted or updated.
--   object_version_number Object version number of record being
--                         inserted or updated.
--   checklist_item_id of the check list item
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_is_itemcode_valid(p_effective_date in date,
                                p_item_code in per_checklist_items.item_code%type) IS
  --
  l_proc         varchar2(72) := g_package||'chk_is_itemcode_valid';

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

    -- Checking to see if the item code is valid
   IF hr_api.not_exists_in_hr_lookups( p_effective_date => p_effective_date,
                                       p_lookup_type    => 'CHECKLIST_ITEM',
                                       p_lookup_code    => p_item_code ) THEN
      -- Error Message - Invalid Checklist value
      fnd_message.set_name('PER', 'HR_52778_CHK_INVALID_ITEM');
      fnd_message.raise_error;
   END IF;


   -- Checking to see it the item code entered is unique for that
   -- person
   -- This check will be done during the insert_dml
   -- PER_CHECKLIST_ITEMS_U1

  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_is_itemcode_valid;
--
-- -----------------------------------------------------------------------
-- |------------------------------< chk_df >-----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Descriptive Flexfield values.
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
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ---------------------------------------------------------------------------
procedure chk_df
  (p_rec              in per_chk_shd.g_rec_type
  ,p_validate_df_flex in boolean default true) is
--
  l_proc     varchar2(72) := g_package||'chk_df';
--
begin
  --
    hr_utility.set_location('Entering:'||l_proc, 10);
    --
    -- if inserting and not required to validate flex data
    -- then ensure all flex data passed is null
    --
      If ((p_rec.checklist_item_id is null) and
          (not p_validate_df_flex)) then
           --
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
                       (p_rec.attribute20        is null) and
                       (p_rec.attribute21        is null) and
                       (p_rec.attribute22        is null) and
                       (p_rec.attribute23        is null) and
                       (p_rec.attribute24        is null) and
                       (p_rec.attribute25        is null) and
                       (p_rec.attribute26        is null) and
                       (p_rec.attribute27        is null) and
                       (p_rec.attribute28        is null) and
                       (p_rec.attribute29        is null) and
                       (p_rec.attribute30        is null) ) )
                 then
                   fnd_message.set_name('PER','HR_6153_ALL_PROCEDURE_FAIL');
                   fnd_message.set_token('PROCEDURE','chk_df');
                   fnd_message.set_token('STEP',1);
                   fnd_message.raise_error;
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
      If (  (p_rec.checklist_item_id is not null)
             and
         (  (nvl(per_chk_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
             nvl(p_rec.attribute_category, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute1, hr_api.g_varchar2)  <>
             nvl(p_rec.attribute1, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute2, hr_api.g_varchar2)  <>
             nvl(p_rec.attribute2, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute3, hr_api.g_varchar2)  <>
             nvl(p_rec.attribute3, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute4, hr_api.g_varchar2)  <>
             nvl(p_rec.attribute4, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute5, hr_api.g_varchar2)  <>
             nvl(p_rec.attribute5, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute6, hr_api.g_varchar2)  <>
             nvl(p_rec.attribute6, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute7, hr_api.g_varchar2)  <>
             nvl(p_rec.attribute7, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute8, hr_api.g_varchar2)  <>
             nvl(p_rec.attribute8, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute9, hr_api.g_varchar2)  <>
             nvl(p_rec.attribute9, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
             nvl(p_rec.attribute10, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
             nvl(p_rec.attribute11, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
             nvl(p_rec.attribute12, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
             nvl(p_rec.attribute13, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
             nvl(p_rec.attribute14, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
             nvl(p_rec.attribute15, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
             nvl(p_rec.attribute16, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
             nvl(p_rec.attribute17, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
             nvl(p_rec.attribute18, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
             nvl(p_rec.attribute19, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
             nvl(p_rec.attribute20, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
             nvl(p_rec.attribute21, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
             nvl(p_rec.attribute22, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
             nvl(p_rec.attribute23, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
             nvl(p_rec.attribute24, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
             nvl(p_rec.attribute25, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
             nvl(p_rec.attribute26, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
             nvl(p_rec.attribute27, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
             nvl(p_rec.attribute28, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
             nvl(p_rec.attribute29, hr_api.g_varchar2) or
             nvl(per_chk_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
             nvl(p_rec.attribute30, hr_api.g_varchar2)
            )
          or
            (
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
              (p_rec.attribute20        is null) and
              (p_rec.attribute21        is null) and
              (p_rec.attribute22        is null) and
              (p_rec.attribute23        is null) and
              (p_rec.attribute24        is null) and
              (p_rec.attribute25        is null) and
              (p_rec.attribute26        is null) and
              (p_rec.attribute27        is null) and
              (p_rec.attribute28        is null) and
              (p_rec.attribute29        is null) and
              (p_rec.attribute30        is null)
            )
          ))
        --  or inserting and required to validate flex
        or
          ((p_rec.checklist_item_id is null) and
           (p_validate_df_flex))
           then
--
--           validate flex segment values
--
    hr_dflex_utility.ins_or_upd_descflex_attribs(
         p_appl_short_name      => 'PER'
        ,p_descflex_name        => 'PER_CHECKLIST_ITEMS'
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
        ,p_attribute21_name     => 'ATTRIBUTE21'
        ,p_attribute21_value    => p_rec.attribute21
        ,p_attribute22_name     => 'ATTRIBUTE22'
        ,p_attribute22_value    => p_rec.attribute22
        ,p_attribute23_name     => 'ATTRIBUTE23'
        ,p_attribute23_value    => p_rec.attribute23
        ,p_attribute24_name     => 'ATTRIBUTE24'
        ,p_attribute24_value    => p_rec.attribute24
        ,p_attribute25_name     => 'ATTRIBUTE25'
        ,p_attribute25_value    => p_rec.attribute25
        ,p_attribute26_name     => 'ATTRIBUTE26'
        ,p_attribute26_value    => p_rec.attribute26
        ,p_attribute27_name     => 'ATTRIBUTE27'
        ,p_attribute27_value    => p_rec.attribute27
        ,p_attribute28_name     => 'ATTRIBUTE28'
        ,p_attribute28_value    => p_rec.attribute28
        ,p_attribute29_name     => 'ATTRIBUTE29'
        ,p_attribute29_value    => p_rec.attribute29
        ,p_attribute30_name     => 'ATTRIBUTE30'
        ,p_attribute30_value    => p_rec.attribute30
        );
  End if;
  --
  hr_utility.set_location('  Leaving:'||l_proc, 20);
--
end chk_df;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_effective_date in date,
                          p_rec in per_chk_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );

  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'person_id'
    ,p_argument_value               => p_rec.person_id
    );

  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'item_code'
    ,p_argument_value               => p_rec.item_code
    );

  -- Checking whether the person id is valid
  hr_utility.set_location('At:'||l_proc, 6);

  chk_is_person_valid
  (p_effective_date        => p_effective_date,
   p_person_id             => p_rec.person_id);

  --
  -- Setting the security group
  --
  per_per_bus.set_security_group_id
   (
    p_person_id => p_rec.person_id
   );
  --
  -- Call all supporting business operations
  --

  -- Checking whether the item code for that particular person
  -- is unique , not null and valid

  hr_utility.set_location('At :'||l_proc, 10);

  chk_is_itemcode_valid
  (p_effective_date        => p_effective_date,
   p_item_code             => p_rec.item_code);

-- Checking whether the status code is valid and not null

  hr_utility.set_location('At :'||l_proc, 15);

  chk_is_status_valid(p_effective_date => p_effective_date,
                      p_checklist_item_id => p_rec.checklist_item_id,
                      p_status     => p_rec.status );

-- Validating the desc flex values

  hr_utility.set_location('At :'||l_proc, 20);

   chk_df(p_rec               => p_rec
         ,p_validate_df_flex  => TRUE);

  hr_utility.set_location(' Leaving:'||l_proc, 30);

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_effective_date in date,
                          p_rec in per_chk_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );

  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'person_id'
    ,p_argument_value               => p_rec.person_id
    );

  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'item_code'
    ,p_argument_value               => p_rec.item_code
    );

  --
  -- Call all supporting business operations
  --
  chk_non_updateable_args(p_effective_date => p_effective_date,
                          p_rec => p_rec);
  --
  -- Setting the security group
  --
  per_per_bus.set_security_group_id
   (
    p_person_id => p_rec.person_id
   );
-- Checking whether the status code is valid and not null

  hr_utility.set_location('At :'||l_proc, 20);

  chk_is_status_valid(p_effective_date => p_effective_date,
                      p_checklist_item_id => p_rec.checklist_item_id,
                      p_status     => p_rec.status );

-- Validating the desc flex values

  hr_utility.set_location('At :'||l_proc, 25);

   chk_df(p_rec               => p_rec
         ,p_validate_df_flex  => TRUE);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_chk_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_chk_bus;

/
