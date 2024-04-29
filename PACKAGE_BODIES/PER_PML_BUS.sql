--------------------------------------------------------
--  DDL for Package Body PER_PML_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PML_BUS" as
/* $Header: pepmlrhi.pkb 120.5.12010000.4 2010/01/15 07:29:24 rvagvala ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pml_bus.';  -- Global package name
g_debug    boolean      := hr_utility.debug_enabled;
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
  (p_rec in per_pml_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.objective_id is not null)  and (
    nvl(per_pml_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(per_pml_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.objective_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_OBJECTIVES_LIBRARY'
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
  (p_effective_date               in date
  ,p_rec in per_pml_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_pml_shd.api_updating
      (p_objective_id                      => p_rec.objective_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;

End chk_non_updateable_args;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_objective_name >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks the uniqueness of the objective name.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  If the name is a duplicate, a warning is set.
--
-- Post Failure:
--  An application error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_objective_name
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_objective_name         in  varchar2
  ,p_valid_from              in date
  ,p_valid_to                in date
  ,p_duplicate_name_warning out nocopy boolean
  ) is

  -- Declare the cursor

    cursor chk_objective_name(c_p_valid_from date, c_p_valid_to date) is
    select 'Y', nvl(valid_from,to_date('01/01/0001','MM/DD/YYYY')),nvl(valid_to,to_date('12/31/4712','MM/DD/YYYY'))
    from  per_objectives_library pml
    where pml.objective_id <> nvl(p_objective_id, hr_api.g_number)
    and   upper(trim(pml.objective_name)) = upper(trim(p_objective_name))
    and
    (
         (
           nvl(valid_from,to_date('01/01/0001','MM/DD/YYYY')) between c_p_valid_from and c_p_valid_to
           or
           nvl(valid_to,to_date('12/31/4712','MM/DD/YYYY')) between c_p_valid_from and c_p_valid_to
          )
          or
          (
            c_p_valid_from between nvl(valid_from,to_date('01/01/0001','MM/DD/YYYY'))
                        and nvl(valid_to,to_date('12/31/4712','MM/DD/YYYY'))
           or c_p_valid_to between nvl( valid_from,to_date('01/01/0001','MM/DD/YYYY'))
                         and nvl(valid_to,to_date('12/31/4712','MM/DD/YYYY'))
          )
    ) order by valid_from,valid_to;



 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_objective_name';
    l_api_updating boolean;
    l_dup          varchar2(1)  := 'N';
    l_st_date      date;
    l_end_date     date;
Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    hr_api.mandatory_arg_error
            (p_api_name       => l_proc
            ,p_argument       => 'p_objective_name'
            ,p_argument_value => p_objective_name
            );

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pml_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
   /* IF (l_api_updating
    AND nvl(per_pml_shd.g_old_rec.objective_name, hr_api.g_varchar2)
      = nvl(p_objective_name, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;*/

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Show erroe if an objective with this name already exists.
    --
    open chk_objective_name(nvl(p_valid_from,to_date('01/01/0001','MM/DD/YYYY')), nvl(p_valid_to,to_date('12/31/4712','MM/DD/YYYY')));
      fetch chk_objective_name into l_dup,l_st_date,l_end_date;
      loop
        exit when chk_objective_name%NOTFOUND;
        fnd_message.set_name('PER','HR_50181_WPM_OBJ_EXIST_WARN');
        fnd_message.set_token('START_DATE',l_st_date);
        fnd_message.set_token('END_DATE',l_end_date);
         if(hr_multi_message.is_message_list_enabled) then
            hr_multi_message.add
            (
              p_message_type => hr_multi_message.G_ERROR_MSG
            );
         end if;
	 l_dup:='Y';
         fetch chk_objective_name into l_dup,l_st_date,l_end_date;
       end loop;
     close chk_objective_name;
     p_duplicate_name_warning := false;
     if (l_dup ='Y') then
        fnd_message.raise_error;
     end if;

    IF g_debug THEN hr_utility.trace('p_duplicate_name_warning: '||l_dup); END IF;
    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

 End chk_objective_name;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_valid_from_to_date >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks the valid from date is not greater than the valid to date.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the dates are valid.
--
-- Post Failure:
--   An application error is raised if the dates are not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_valid_from_to_date
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_valid_from             in date
  ,p_valid_to               in date
  ) is

  l_proc         varchar2(72)  :=  g_package||'chk_valid_from_to_date';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pml_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pml_shd.g_old_rec.valid_from, hr_api.g_date)
      = nvl(p_valid_from, hr_api.g_date)
    AND nvl(per_pml_shd.g_old_rec.valid_to, hr_api.g_date)
      = nvl(p_valid_to, hr_api.g_date))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Only proceed if both parameters are populated.
    --
    IF p_valid_from IS NOT NULL AND
       p_valid_to IS NOT NULL
    THEN
        --
        -- Checks that the valid from date is not greater than the valid to date.
        --
        if (p_valid_from > p_valid_to) then
          fnd_message.set_name('PER','HR_50187_WPM_INV_DATE_FROM_TO');
          fnd_message.raise_error;
        end if;

    END IF;

    IF g_debug THEN hr_utility.set_location(' Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES_LIBRARY.VALID_FROM'
    ,p_associated_column2 =>  'PER_OBJECTIVES_LIBRARY.VALID_TO'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

end chk_valid_from_to_date;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_group_code >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the group code is a valid lookup code in HR_WPM_GROUP.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the dates are valid.
--
-- Post Failure:
--  A warning message is displayed
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_group_code
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_effective_date         in  date
  ,p_group_code             in  varchar2
  ) is

 -- Declare local variables

  l_proc         varchar2(72)  :=  g_package||'chk_group_code';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pml_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pml_shd.g_old_rec.group_code, hr_api.g_varchar2)
      = nvl(p_group_code, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the group code is valid
    --
    if p_group_code is not null then
      if hr_api.not_exists_in_hr_lookups
           (p_effective_date        => p_effective_date
           ,p_lookup_type           => 'HR_WPM_GROUP'
           ,p_lookup_code           => p_group_code
           ) then
        --  Error: Invalid Group
        fnd_message.set_name('PER', 'HR_50188_WPM_INV_GROUP');
        fnd_message.raise_error;
      end if;
    end if;

    IF g_debug THEN hr_utility.set_location(' Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES_LIBRARY.GROUP_CODE'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);
--
end chk_group_code;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_priority_code >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the priority code is a valid lookup code in HR_WPM_PRIORITY.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the priority code is valid.
--
-- Post Failure:
--   An application error is raised if the priority code is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_priority_code
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_effective_date         in  date
  ,p_priority_code          in  varchar2
  ) is

 -- Declare local variables

  l_proc         varchar2(72)  :=  g_package||'chk_priority_code';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pml_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pml_shd.g_old_rec.priority_code, hr_api.g_varchar2)
      = nvl(p_priority_code, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the priority code is valid
    --
    if p_priority_code is not null then
      if hr_api.not_exists_in_hr_lookups
           (p_effective_date        => p_effective_date
           ,p_lookup_type           => 'HR_WPM_PRIORITY'
           ,p_lookup_code           => p_priority_code
           ) then
        --  Error: Invalid Group
        fnd_message.set_name('PER', 'HR_50189_WPM_INV_PRIORITY');
        fnd_message.raise_error;
      end if;
    end if;

    IF g_debug THEN hr_utility.set_location(' Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES_LIBRARY.PRIORITY_CODE'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

end chk_priority_code;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_appraise_flag >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the appraise flag is set to a valid value.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the appraise flag is valid.
--
-- Post Failure:
--   An application error is raised if the appraise flag is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_appraise_flag
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_effective_date         in  date
  ,p_appraise_flag          in  varchar2
  ) is

 -- Declare local variables

  l_proc         varchar2(72)  :=  g_package||'chk_appraise_flag';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    --
    hr_api.mandatory_arg_error
            (p_api_name       => l_proc
            ,p_argument       => 'p_appraise_flag'
            ,p_argument_value => p_appraise_flag
            );

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pml_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pml_shd.g_old_rec.appraise_flag, hr_api.g_varchar2)
      = nvl(p_appraise_flag, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the appraise flag is valid
    --
    if hr_api.not_exists_in_hrstanlookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'YES_NO'
         ,p_lookup_code           => p_appraise_flag
         ) then
      --  Error: Invalid Group
      fnd_message.set_name('PER', 'HR_50199_WPM_APPRAISE_FLAG');
      fnd_message.raise_error;
    end if;

    IF g_debug THEN hr_utility.set_location(' Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES_LIBRARY.APPRAISE_FLAG'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

end chk_appraise_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_weighting_percent >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the weighting value is not negative.
--   Checks that the weighting percent is not greater than 100.
--   Checks if the objective has been marked to be included in appraisals.
--
-- Prerequisites:
--   That the appraise flag has already been validated.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the weighting percent is valid.
--
-- Post Failure:
--   An application error is raised if the weighting percent is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_weighting_percent
  (p_objective_id                in  number
  ,p_object_version_number       in  number
  ,p_appraise_flag               in  varchar2
  ,p_weighting_percent           in  number
  ,p_weighting_over_100_warning  out nocopy boolean
  ,p_weighting_appraisal_warning out nocopy boolean
  ) is


 -- Declare local variables

  l_proc         varchar2(72)  :=  g_package||'chk_weighting_percent';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pml_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pml_shd.g_old_rec.appraise_flag, hr_api.g_varchar2)
      = nvl(p_appraise_flag, hr_api.g_varchar2)
    AND nvl(per_pml_shd.g_old_rec.weighting_percent, hr_api.g_number)
      = nvl(p_weighting_percent, hr_api.g_number))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    if p_weighting_percent is not null then

      IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;
      --
      -- Warn if the objective is not marked for appraisal.
      --
      if hr_multi_message.no_exclusive_error
          (p_check_column1      => 'PER_OBJECTIVES_LIBRARY.APPRAISE_FLAG'
          ,p_associated_column1 => 'PER_OBJECTIVES_LIBRARY.APPRAISE_FLAG'
          ) then
        p_weighting_appraisal_warning := (p_appraise_flag = 'N');
      end if;

      IF g_debug THEN hr_utility.set_location(l_proc, 40); END IF;
      --
      -- Checks that the weighting_percent is not a negative number
      --
      if (p_weighting_percent < 0) then
         fnd_message.set_name('PER','HR_50193_WPM_WEIGHT_VALUE');
         fnd_message.raise_error;
      end if;

      IF g_debug THEN hr_utility.set_location(l_proc, 50); END IF;
      --
      -- Warns that the weighting percent is greater than 100
      --
      p_weighting_over_100_warning := (p_weighting_percent > 100);

    end if;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES_LIBRARY.WEIGHTING_PERCENT'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

end chk_weighting_percent;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_measurement_style_code >------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the measurement style code is a valid lookup code.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the measurement style code is valid.
--
-- Post Failure:
--   An application error is raised if the measurement style code is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_measurement_style_code
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_effective_date         in  date
  ,p_measurement_style_code in  varchar2
  ) is

 -- Declare local variables

  l_proc         varchar2(72)  :=  g_package||'chk_measurement_style_code';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    --
    hr_api.mandatory_arg_error
            (p_api_name       => l_proc
            ,p_argument       => 'p_measurement_style_code'
            ,p_argument_value => p_measurement_style_code
            );

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pml_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pml_shd.g_old_rec.measurement_style_code, hr_api.g_varchar2)
      = nvl(p_measurement_style_code, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the measurement_style_code is valid
    --
    if hr_api.not_exists_in_hrstanlookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'HR_WPM_MEASURE'
         ,p_lookup_code           => p_measurement_style_code
         ) then
      --  Error: Invalid Group
      fnd_message.set_name('PER', 'HR_50194_WPM_INV_MEASR_STYL');
      fnd_message.raise_error;
    end if;

    IF g_debug THEN hr_utility.set_location(' Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES_LIBRARY.MEASUREMENT_STYLE_CODE'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

end chk_measurement_style_code;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_measure_name >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the measure name has been entered when the measurement style
--   is quantitative or qualitative.
--
-- Prerequisites:
--   That the measurement style code has been validated without error.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the measure name has been entered.
--
-- Post Failure:
--   An application error is raised if the measure name has not been entered
--   when required.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_measure_name
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_measurement_style_code in  varchar2
  ,p_measure_name           in  varchar2
  ) is

 -- Declare local variables

  l_proc         varchar2(72)  :=  g_package||'chk_measure_name';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pml_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pml_shd.g_old_rec.measurement_style_code, hr_api.g_varchar2)
      = nvl(p_measurement_style_code, hr_api.g_varchar2)
    AND nvl(per_pml_shd.g_old_rec.measure_name, hr_api.g_varchar2)
      = nvl(p_measure_name, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    if hr_multi_message.no_exclusive_error
        (p_check_column1      => 'PER_OBJECTIVES_LIBRARY.MEASUREMENT_STYLE_CODE'
        ,p_associated_column1 => 'PER_OBJECTIVES_LIBRARY.MEASUREMENT_STYLE_CODE'
        ) then

        if p_measurement_style_code <> 'N_M'
        then
            IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

            hr_api.mandatory_arg_error
                (p_api_name       => l_proc
                ,p_argument       => 'p_measure_name'
                ,p_argument_value => p_measure_name
                );
        end if;

    end if;

    IF g_debug THEN hr_utility.set_location(' Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES_LIBRARY.MEASURE_NAME'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

end chk_measure_name;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_target_value >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the target value  hs been entered when the measurement style
--   is quantitative.
--
-- Prerequisites:
--   That the measurement style code has been validated without error.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the target value has been entered.
--
-- Post Failure:
--   An application error is raised if the target value has not been entered
--   when required.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_target_value
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_measurement_style_code in  varchar2
  ,p_target_value           in  number
  ) is

 -- Declare local variables

  l_proc         varchar2(72)  :=  g_package||'chk_target_value';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pml_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pml_shd.g_old_rec.measurement_style_code, hr_api.g_varchar2)
      = nvl(p_measurement_style_code, hr_api.g_varchar2)
    AND nvl(per_pml_shd.g_old_rec.target_value, hr_api.g_number)
      = nvl(p_target_value, hr_api.g_number))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    if hr_multi_message.no_exclusive_error
        (p_check_column1      => 'PER_OBJECTIVES_LIBRARY.MEASUREMENT_STYLE_CODE'
        ,p_associated_column1 => 'PER_OBJECTIVES_LIBRARY.MEASUREMENT_STYLE_CODE'
        ) then

    if p_measurement_style_code = 'QUANT_M'
        then
            IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

            hr_api.mandatory_arg_error
                (p_api_name       => l_proc
                ,p_argument       => 'p_target_value'
                ,p_argument_value => p_target_value
                );
        end if;

    end if;

    IF g_debug THEN hr_utility.set_location(' Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES_LIBRARY.TARGET_VALUE'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

end chk_target_value;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_uom_code >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the UOM code is a valid lookup code.
--
-- Prerequisites:
--   That the measurement style code has been validated without error.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the UOM code is valid.
--
-- Post Failure:
--   An application error is raised if the UOM code is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_uom_code
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_effective_date         in  date
  ,p_measurement_style_code in  varchar2
  ,p_uom_code               in  varchar2
  ) is

 -- Declare local variables

  l_proc         varchar2(72)  :=  g_package||'chk_uom_code';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pml_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pml_shd.g_old_rec.measurement_style_code, hr_api.g_varchar2)
      = nvl(p_measurement_style_code, hr_api.g_varchar2)
    AND nvl(per_pml_shd.g_old_rec.uom_code, hr_api.g_varchar2)
      = nvl(p_uom_code, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    if hr_multi_message.no_exclusive_error
        (p_check_column1      => 'PER_OBJECTIVES_LIBRARY.MEASUREMENT_STYLE_CODE'
        ,p_associated_column1 => 'PER_OBJECTIVES_LIBRARY.MEASUREMENT_STYLE_CODE'
        ) then

        if p_measurement_style_code = 'QUANT_M'
        then
            IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

            hr_api.mandatory_arg_error
                (p_api_name       => l_proc
                ,p_argument       => 'p_uom_code'
                ,p_argument_value => p_uom_code
                );
        end if;

    end if;

    IF g_debug THEN hr_utility.set_location(l_proc, 40); END IF;

    --
    -- Checks that the UOM code is valid
    --
    if p_uom_code is not null then
        if hr_api.not_exists_in_hrstanlookups
             (p_effective_date        => p_effective_date
             ,p_lookup_type           => 'HR_WPM_MEASURE_UOM'
             ,p_lookup_code           => p_uom_code
             ) then
          --  Error: Invalid Group
          fnd_message.set_name('PER', 'HR_50195_WPM_INV_UOM');
          fnd_message.raise_error;
        end if;
    end if;

    IF g_debug THEN hr_utility.set_location(' Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES_LIBRARY.UOM_CODE'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

end chk_uom_code;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_measure_type_code >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the measure type is a valid lookup code.
--
-- Prerequisites:
--   That the measurement style code has been validated without error.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the measure type code is valid.
--
-- Post Failure:
--   An application error is raised if the measure type code is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_measure_type_code
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_effective_date         in  date
  ,p_measurement_style_code in  varchar2
  ,p_measure_type_code      in  varchar2
  ) is

 -- Declare local variables

  l_proc         varchar2(72)  :=  g_package||'chk_measure_type_code';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pml_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pml_shd.g_old_rec.measurement_style_code, hr_api.g_varchar2)
      = nvl(p_measurement_style_code, hr_api.g_varchar2)
    AND nvl(per_pml_shd.g_old_rec.measure_type_code, hr_api.g_varchar2)
      = nvl(p_measure_type_code, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    if hr_multi_message.no_exclusive_error
        (p_check_column1      => 'PER_OBJECTIVES_LIBRARY.MEASUREMENT_STYLE_CODE'
        ,p_associated_column1 => 'PER_OBJECTIVES_LIBRARY.MEASUREMENT_STYLE_CODE'
        ) then

        if p_measurement_style_code = 'QUANT_M'
        then
            IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

            hr_api.mandatory_arg_error
                (p_api_name       => l_proc
                ,p_argument       => 'p_measure_type_code'
                ,p_argument_value => p_measure_type_code
                );
        end if;

    end if;

    IF g_debug THEN hr_utility.set_location(l_proc, 40); END IF;

    --
    -- Checks that the measure type code is valid
    --
    if p_measure_type_code is not null then
      if hr_api.not_exists_in_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_lookup_type           => 'HR_WPM_MEASURE_TYPE'
           ,p_lookup_code           => p_measure_type_code
           ) then
        --  Error: Invalid Group
        fnd_message.set_name('PER', 'HR_50196_WPM_INV_MEASR_TYPE');
        fnd_message.raise_error;
      end if;
    end if;

    IF g_debug THEN hr_utility.set_location(' Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES_LIBRARY.MEASURE_TYPE_CODE'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

end chk_measure_type_code;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_eligibility_type_code >-----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the eligiblity type code is a valid lookup code.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the eligibility code is valid.
--
-- Post Failure:
--  An application error is raised if the eligibility code is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_eligibility_type_code
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_effective_date         in  date
  ,p_eligibility_type_code  in  varchar2
  ) is

 -- Declare local variables

  l_proc         varchar2(72)  :=  g_package||'chk_eligibility_type_code';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    --
    hr_api.mandatory_arg_error
            (p_api_name       => l_proc
            ,p_argument       => 'p_eligibility_type_code'
            ,p_argument_value => p_eligibility_type_code
            );

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pml_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pml_shd.g_old_rec.eligibility_type_code, hr_api.g_varchar2)
      = nvl(p_eligibility_type_code, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the eligibility type code is valid
    --
    if hr_api.not_exists_in_hrstanlookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'HR_WPM_ELIGIBILITY'
         ,p_lookup_code           => p_eligibility_type_code
         ) then
      --  Error: Invalid Group
      fnd_message.set_name('PER', 'HR_50197_WPM_INV_ELIGY_TYPE');
      fnd_message.raise_error;
    end if;

    IF g_debug THEN hr_utility.set_location(' Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES_LIBRARY.ELIGIBILITY_TYPE_CODE'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);
--
end chk_eligibility_type_code;
--
-- ---------------------------------------------------------------------
-- |-----------------------< chk_next_review_date >--------------------|
-- ---------------------------------------------------------------------
--
-- Description:
--    Validates that next_review_date is not later than valid_from.
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_objective_id
--    p_valid_from
--    p_next_review_date
--    p_object_version_number
--
-- Post Success:
--    Processing continues if next_review_date is later than valid_from
--    or if next_review_date is not entered.
--
-- Post Failure:
--    An Application Error is raised and processing is terminated if
--    next_review_date is invalid.
--
-- Access Status:
--    Internal Development use only.
--
-- ---------------------------------------------------------------------
procedure chk_next_review_date
  (p_objective_id          in per_objectives_library.objective_id%TYPE
  ,p_valid_from            in per_objectives_library.valid_from%TYPE
  ,p_next_review_date      in per_objectives_library.next_review_date%TYPE
  ,p_object_version_number in per_objectives_library.object_version_number%TYPE
  ) is
  --
  l_proc          varchar2(72)  :=  g_package||'chk_next_review_date';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc,5);
  --
    if p_next_review_date < p_valid_from then
      hr_utility.set_message(800,'HR_50425_INV_NEXT_REV_DATE');
      hr_utility.raise_error;
    end if;
    --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
exception
  when app_exception.application_exception then
 if hr_multi_message.exception_add
       (p_associated_column1      => 'PER_OBJECTIVES.NEXT_REVIEW_DATE'
       ) then
      raise;
    end if;
end chk_next_review_date;
--
-- ---------------------------------------------------------------------
-- |-------------------------< chk_target_date >-----------------------|
-- ---------------------------------------------------------------------
--
-- Description:
--    Validates that target_date is not later than valid_from.
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_objective_id
--    p_valid_from
--    p_target_date
--    p_object_version_number
--
-- Post Success:
--    Processing continues if target_date is later than valid_from
--    or if target_date is not entered.
--
-- Post Failure:
--    An Application Error is raised and processing is terminated if
--    target_date is invalid.
--
-- Access Status:
--    Internal Development use only.
--
-- ---------------------------------------------------------------------
procedure chk_target_date
  (p_objective_id          in per_objectives_library.objective_id%TYPE
  ,p_valid_from            in per_objectives_library.valid_from%TYPE
  ,p_target_date      in per_objectives_library.target_date%TYPE
  ,p_object_version_number in per_objectives_library.object_version_number%TYPE
  ) is
  --
  l_proc          varchar2(72)  :=  g_package||'chk_target_date';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc,5);
  --
    if p_target_date < p_valid_from then
      hr_utility.set_message(800,'HR_50424_WPM_INV_TARGET_DATE');
      hr_utility.raise_error;
    end if;
    --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
exception
  when app_exception.application_exception then
 if hr_multi_message.exception_add
       (p_associated_column1      => 'PER_OBJECTIVES.target_date'
       ) then
      raise;
    end if;
end chk_target_date;



--   9166842  Bug Fix Changes
--=======================================================================================
--
-----------------------------------------------------------------------------
---------------------------<chk_child_for_library_obj>--------------------------
-----------------------------------------------------------------------------
--
--  Description:
--   - Validates if any child rows exist for the library objective
--
--  Pre_conditions:
--   - None
--
--  In Arguments:
--    p_objective_id
--
--  Post Success:
--    Process continues if :
--     in parameter is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      -- Child Rows exist for the Library Objective
--
--  Access Status
--    Internal row Handler Use Only.
--
--
procedure chk_child_for_library_obj
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  )
is
--
  l_exists       varchar2(1);
  l_proc         varchar2(72)  :=  g_package||'chk_child_for_library_obj';
  l_api_updating boolean;
--
	--
	-- Cursor to check if child Row exists
	--
	Cursor csr_child_for_objlib_exists
          is
	select  'Y'
	from	per_objectives
	where   copied_from_library_id = p_objective_id;
--
begin
  --
  IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    --
  IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

     open csr_child_for_objlib_exists;
     fetch csr_child_for_objlib_exists into l_exists;
     if csr_child_for_objlib_exists%found then
        close csr_child_for_objlib_exists;
        -- ERROR : Child Rows Exist
        fnd_message.set_name('PER', 'HR_50189_WPM_CHILD_ROW_EXIST');
        fnd_message.raise_error;
     else
        close csr_child_for_objlib_exists;
     end if;
  --
 IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;
--

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES_LIBRARY.OBJECTIVE_ID'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

--
end chk_child_for_library_obj;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure insert_validate
  (p_effective_date               in  date
  ,p_rec                          in  per_pml_shd.g_rec_type
  ,p_duplicate_name_warning       out nocopy boolean
  ,p_weighting_over_100_warning   out nocopy boolean
  ,p_weighting_appraisal_warning  out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';

--
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- No business group context. HR_STANDARD_LOOKUPS used for validation.

  --
  -- Validate Independent Attributes
  --
  -- Check the validity dates.
  --
  chk_valid_from_to_date
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_valid_from                  => p_rec.valid_from
    ,p_valid_to                    => p_rec.valid_to);

  hr_utility.set_location(l_proc, 10);
  --
  -- Check the uniqueness of the objective name.
  --
  chk_objective_name
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_objective_name              => p_rec.objective_name
    ,p_duplicate_name_warning      => p_duplicate_name_warning
    ,p_valid_from                  =>p_rec.valid_from
    ,p_valid_to                    =>p_rec.valid_to);


  hr_utility.set_location(l_proc, 15);
  --
  -- Check the group code.
  --
  chk_group_code
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_group_code                  => p_rec.group_code);

  hr_utility.set_location(l_proc, 20);
  --
  -- Check the priority.
  --
  chk_priority_code
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_priority_code               => p_rec.priority_code);

  hr_utility.set_location(l_proc, 25);
  --
  -- Check the appraise flag.
  --
  chk_appraise_flag
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_appraise_flag               => p_rec.appraise_flag);

  hr_utility.set_location(l_proc, 30);
  --
  -- Check the weighting percent.
  --
  chk_weighting_percent
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_appraise_flag               => p_rec.appraise_flag
    ,p_weighting_percent           => p_rec.weighting_percent
    ,p_weighting_over_100_warning  => p_weighting_over_100_warning
    ,p_weighting_appraisal_warning => p_weighting_appraisal_warning);

  hr_utility.set_location(l_proc, 35);
  --
  -- Check the measurement style code.
  --
  chk_measurement_style_code
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_measurement_style_code      => p_rec.measurement_style_code);

  hr_utility.set_location(l_proc, 40);
  --
  -- Check the measure name.
  --
  chk_measure_name
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_measurement_style_code      => p_rec.measurement_style_code
    ,p_measure_name                => p_rec.measure_name);

  hr_utility.set_location(l_proc, 45);
  --
  -- Check the target value.
  --
  chk_target_value
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_measurement_style_code      => p_rec.measurement_style_code
    ,p_target_value                => p_rec.target_value);

  hr_utility.set_location(l_proc, 50);
  --
  -- Check the UOM code.
  --
  chk_uom_code
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_measurement_style_code      => p_rec.measurement_style_code
    ,p_uom_code                    => p_rec.uom_code);

  hr_utility.set_location(l_proc, 55);
  --
  -- Check the measure type code.
  --
  chk_measure_type_code
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_measurement_style_code      => p_rec.measurement_style_code
    ,p_measure_type_code           => p_rec.measure_type_code);

  hr_utility.set_location(l_proc, 60);
  --
  -- Check the eligibility type code.
  --
  chk_eligibility_type_code
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_eligibility_type_code       => p_rec.eligibility_type_code);

  hr_utility.set_location(l_proc, 65);

  --
  -- Check that the next review date is not before start date
  --
  chk_next_review_date
  (p_objective_id          => p_rec.objective_id
  ,p_valid_from            => p_rec.valid_from
  ,p_next_review_date      => p_rec.next_review_date
  ,p_object_version_number => p_rec.object_version_number
  );

  hr_utility.set_location(l_proc, 70);

  --
  -- Check that the target date is not before start date
  --
   chk_target_date
  (p_objective_id          => p_rec.objective_id
  ,p_valid_from            => p_rec.valid_from
  ,p_target_date           => p_rec.target_date
  ,p_object_version_number => p_rec.object_version_number
  );

  hr_utility.set_location(l_proc, 75);

  --
  -- Check the flexfield.
  --
  per_pml_bus.chk_df(p_rec);

  hr_utility.set_location(' Leaving:'||l_proc, 150);

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_validate
  (p_effective_date              in  date
  ,p_rec                         in  per_pml_shd.g_rec_type
  ,p_duplicate_name_warning      out nocopy boolean
  ,p_weighting_over_100_warning  out nocopy boolean
  ,p_weighting_appraisal_warning out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';

--
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- No business group context. HR_STANDARD_LOOKUPS used for validation.
  --
  chk_non_updateable_args
    (p_effective_date     => p_effective_date
    ,p_rec              => p_rec);

  --
  -- Validate Independent Attributes
  --
  -- Check the uniqueness of the objective name.
  --
  chk_objective_name
    (p_objective_id             => p_rec.objective_id
    ,p_object_version_number    => p_rec.object_version_number
    ,p_objective_name           => p_rec.objective_name
    ,p_duplicate_name_warning   => p_duplicate_name_warning
    ,p_valid_from               => p_rec.valid_from
    ,p_valid_to                 => p_rec.valid_to
    );

  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check the validity dates.
  --
  chk_valid_from_to_date
    (p_objective_id             => p_rec.objective_id
    ,p_object_version_number    => p_rec.object_version_number
    ,p_valid_from               => p_rec.valid_from
    ,p_valid_to                 => p_rec.valid_to);

  hr_utility.set_location('Entering:'||l_proc, 15);
  --
  -- Check the group code.
  --
  chk_group_code
    (p_objective_id             => p_rec.objective_id
    ,p_object_version_number    => p_rec.object_version_number
    ,p_effective_date           => p_effective_date
    ,p_group_code               => p_rec.group_code);

  hr_utility.set_location('Entering:'||l_proc, 20);
  --
  -- Check the priority.
  --
  chk_priority_code
    (p_objective_id             => p_rec.objective_id
    ,p_object_version_number    => p_rec.object_version_number
    ,p_effective_date           => p_effective_date
    ,p_priority_code            => p_rec.priority_code);

  hr_utility.set_location('Entering:'||l_proc, 25);
  --
  -- Check the appraise flag.
  --
  chk_appraise_flag
    (p_objective_id             => p_rec.objective_id
    ,p_object_version_number    => p_rec.object_version_number
    ,p_effective_date           => p_effective_date
    ,p_appraise_flag            => p_rec.appraise_flag);

  hr_utility.set_location('Entering:'||l_proc, 30);
  --
  -- Check the weighting percent.
  --
  chk_weighting_percent
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_appraise_flag               => p_rec.appraise_flag
    ,p_weighting_percent           => p_rec.weighting_percent
    ,p_weighting_over_100_warning  => p_weighting_over_100_warning
    ,p_weighting_appraisal_warning => p_weighting_appraisal_warning);

  hr_utility.set_location(l_proc, 35);
  --
  -- Check the measurement style code.
  --
  chk_measurement_style_code
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_measurement_style_code      => p_rec.measurement_style_code);

  hr_utility.set_location(l_proc, 40);
  --
  -- Check the measure name.
  --
  chk_measure_name
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_measurement_style_code      => p_rec.measurement_style_code
    ,p_measure_name                => p_rec.measure_name);

  hr_utility.set_location(l_proc, 45);
  --
  -- Check the target value.
  --
  chk_target_value
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_measurement_style_code      => p_rec.measurement_style_code
    ,p_target_value                => p_rec.target_value);

  hr_utility.set_location(l_proc, 50);
  --
  -- Check the UOM code.
  --
  chk_uom_code
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_measurement_style_code      => p_rec.measurement_style_code
    ,p_uom_code                    => p_rec.uom_code);

  hr_utility.set_location(l_proc, 55);
  --
  -- Check the measure type code.
  --
  chk_measure_type_code
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_measurement_style_code      => p_rec.measurement_style_code
    ,p_measure_type_code           => p_rec.measure_type_code);

  hr_utility.set_location(l_proc, 60);
  --
  -- Check the eligibility type code.
  --
  chk_eligibility_type_code
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_eligibility_type_code       => p_rec.eligibility_type_code);

  hr_utility.set_location(l_proc, 65);
  --
  -- Check that the next review dates is not before start date
  --
  chk_next_review_date
  (p_objective_id          => p_rec.objective_id
  ,p_valid_from            => p_rec.valid_from
  ,p_next_review_date      => p_rec.next_review_date
  ,p_object_version_number => p_rec.object_version_number
  );
  hr_utility.set_location(l_proc, 70);
  --
  -- Check that the target date is not before start date
  --
  chk_target_date
  (p_objective_id          => p_rec.objective_id
  ,p_valid_from            => p_rec.valid_from
  ,p_target_date           => p_rec.target_date
  ,p_object_version_number => p_rec.object_version_number
  );

  hr_utility.set_location(l_proc, 75);


  --
  -- Check the flexfield.
  --
  per_pml_bus.chk_df(p_rec);

  hr_utility.set_location(' Leaving:'||l_proc, 150);

End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_validate
  (p_rec                          in per_pml_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --  9166842  Bug Fix Changes
chk_child_for_library_obj
  (  p_objective_id =>  p_rec.objective_id
    ,p_object_version_number  => p_rec.object_version_number
  );


  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_pml_bus;

/
