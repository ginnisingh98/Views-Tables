--------------------------------------------------------
--  DDL for Package Body PER_CTK_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CTK_BUS" as
/* $Header: pectkrhi.pkb 120.7 2006/09/11 20:45:03 sturlapa noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ctk_bus.';  -- Global package name
   g_debug boolean := hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_task_in_checklist_id        number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_task_in_checklist_id                 in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , per_tasks_in_checklist   tic
         , per_checklists           ckl
     where tic.task_in_checklist_id = p_task_in_checklist_id
       and tic.checklist_id         = ckl.checklist_id
       and pbg.business_group_id    = ckl.business_group_id;
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
    ,p_argument           => 'task_in_checklist_id'
    ,p_argument_value     => p_task_in_checklist_id
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
        => nvl(p_associated_column1,'TASK_IN_CHECKLIST_ID')
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
  (p_task_in_checklist_id                 in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , per_tasks_in_checklist   tic
         , per_checklists           ckl
     where tic.task_in_checklist_id = p_task_in_checklist_id
       and tic.checklist_id         = ckl.checklist_id
       and pbg.business_group_id    = ckl.business_group_id;

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
    ,p_argument           => 'task_in_checklist_id'
    ,p_argument_value     => p_task_in_checklist_id
    );
  --
  if ( nvl(per_ctk_bus.g_task_in_checklist_id, hr_api.g_number)
       = p_task_in_checklist_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_ctk_bus.g_legislation_code;
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
    per_ctk_bus.g_task_in_checklist_id        := p_task_in_checklist_id;
    per_ctk_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_checklist_id >--------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_checklist_id
  (p_checklist_id       in    per_tasks_in_checklist.checklist_id%TYPE
   ) is
  --
  -- Declare local variables
  --
  l_proc  varchar2(72) := g_package||'chk_checklist_id';
  l_dummy number;
  --
  -- Declare cursor to check name is unique.
  --
  cursor csr_ckl_id is
    select null
    from per_checklists ckl
    where ckl.checklist_id = p_checklist_id;
  --
begin
   IF g_debug THEN hr_utility.set_location('Entering:'||l_proc, 10); END IF;

    --
    hr_api.mandatory_arg_error
            (p_api_name       => l_proc
            ,p_argument       => 'p_checklist_id'
            ,p_argument_value => p_checklist_id
            );
   IF g_debug THEN hr_utility.set_location('Entering:'||l_proc, 20); END IF;
  --
  -- Check mandatory checklist_id exists and is valid
  --
       open csr_ckl_id;
       fetch csr_ckl_id into l_dummy;
       if csr_ckl_id%notfound then
          close csr_ckl_id;
          --
          fnd_message.set_name('PER', 'PER_449665_CKL_INV_CKL_ID');
          fnd_message.raise_error;
          --
       end if;
       close csr_ckl_id;
  --
  IF g_debug THEN hr_utility.set_location('Leaving:'||l_proc, 50); END IF;
  --
  exception when app_exception.application_exception then
        IF hr_multi_message.exception_add
                 (p_associated_column1      => 'PER_TASKS_INCHECKLIST.CHECKLIST_ID'
                 ) then
              hr_utility.set_location(' Leaving:'|| l_proc, 60);
              raise;
            end if;
        IF g_debug THEN  hr_utility.set_location(' Leaving:'|| l_proc, 70);  END IF;
end chk_checklist_id;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_task_name >----------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_task_name
  (p_checklist_task_name    in    per_tasks_in_checklist.checklist_task_name%TYPE
  ,p_task_in_checklist_id   in    per_tasks_in_checklist.task_in_checklist_id%TYPE
  ,p_checklist_id           in    per_tasks_in_checklist.checklist_id%TYPE
  ,p_object_version_number  in    per_tasks_in_checklist.object_version_number%type
   ) is
  --
  -- Declare local variables
  --
  l_proc  varchar2(72) := g_package||'chk_checklist_task_name';
  l_tsk_exists varchar2(10);
  l_api_updating boolean;
  --
  -- Declare cursor to check name is unique.
  --
  cursor csr_ckltsk is
    select 'X'
      from per_tasks_in_checklist tic
     where tic.checklist_task_name  = p_checklist_task_name
       and tic.checklist_id         = p_checklist_id;
  --
begin
  if g_debug then
    hr_utility.set_location('Entering:'||l_proc, 1);
  end if;
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The party value has changed
  --  c) a record is being inserted
  --
  l_api_updating := per_ctk_shd.api_updating
    (p_task_in_checklist_id  => p_task_in_checklist_id
    ,p_object_version_number => p_object_version_number
    );
  IF (l_api_updating
      and nvl(per_ctk_shd.g_old_rec.checklist_task_name, hr_api.g_varchar2)
      = nvl(p_checklist_task_name,hr_api.g_varchar2))
  THEN
      RETURN;
  END IF;
  --
    if g_debug then  hr_utility.set_location(l_proc, 40);  end if;
    --
    -- Check mandatory checklist_task_name exists
    --
    if p_checklist_task_name is not null then
         open csr_ckltsk;
         fetch csr_ckltsk into l_tsk_exists;
         if csr_ckltsk%found then
            close csr_ckltsk;
            --
            fnd_message.set_name('PER', 'PER_449670_CKL_TSK_NAME_UNQ');
            fnd_message.set_token('TASK_NAME', p_checklist_task_name);
            fnd_message.raise_error;
            --
         end if;
         close csr_ckltsk;
    else
      --
      -- Since task_name is mandatory need to error
      --
       fnd_message.set_name('PER','PER_449679_CKL_TASK_NAME_REQD');
       fnd_message.raise_error;
    end if;
    --
    if g_debug then hr_utility.set_location(l_proc, 5);  end if;
    --
  exception when app_exception.application_exception then
        if hr_multi_message.exception_add
                 (p_associated_column1      => 'PER_TASKS_INCHECKLIST.NAME'
                 ) then
              hr_utility.set_location(' Leaving:'|| l_proc, 60);
              raise;
            end if;
            hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_task_name;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_duration_uom >-------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_duration_uom
  (p_target_duration        in    per_tasks_in_checklist.target_duration%TYPE
  ,p_target_duration_uom    in    per_tasks_in_checklist.target_duration_uom%TYPE
  ,p_task_in_checklist_id   in    per_tasks_in_checklist.task_in_checklist_id%TYPE
  ,p_object_version_number  in    per_tasks_in_checklist.object_version_number%type
  ,p_effective_date         in    date
   ) is
  --
  -- Declare local variables
  --
  l_proc  varchar2(72) := g_package||'chk_duration_uom';
  l_tsk_exists varchar2(10);
  l_api_updating boolean;
  --
begin

  IF g_debug then hr_utility.set_location('Entering:'||l_proc, 10);  END IF;
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The duration_units or duration_units_uom values are changed
  --
  l_api_updating := per_ctk_shd.api_updating
         (p_task_in_checklist_id  => p_task_in_checklist_id
         ,p_object_version_number => p_object_version_number
         );
  --
  IF (l_api_updating
       and ( (nvl(per_ctk_shd.g_old_rec.target_duration, hr_api.g_number) = nvl(p_target_duration,hr_api.g_number))
             AND
             (nvl(per_ctk_shd.g_old_rec.target_duration_UOM, hr_api.g_varchar2) = nvl(p_target_duration_uom,hr_api.g_varchar2))
           )
     )
  THEN
      RETURN;
  END IF;
  --
    IF g_debug then  hr_utility.set_location(l_proc, 40);  END IF;

    --
    -- Checks that the target_duration_uom is valid
    --
    IF (nvl(p_target_duration_uom,'ZZ') <> 'ZZ') THEN
    --
      IF hr_api.not_exists_in_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_lookup_type           => 'QUALIFYING_UNITS'
           ,p_lookup_code           => p_target_duration_uom
           ) then
        --  Error: Invalid Group
        fnd_message.set_name('PER', 'PER_449680_CKL_UNITS_UOM_INV');
        fnd_message.raise_error;
        --
      ELSE
        --
        -- Checks that the target_duration_uom is valid for Checklists
        --
        IF (p_target_duration_uom <> 'D' and
            p_target_duration_uom <> 'W' and
            p_target_duration_uom <> 'M')
        THEN
          fnd_message.set_name('PER', 'PER_449680_CKL_UNITS_UOM_INV');
          fnd_message.raise_error;
        END IF;
        --
      END IF;
      --
    END IF;
    --
    -- Check if target_duration has some value, then target_duration_uom is mandatory
    --
    IF ( nvl(p_target_duration,-1) <> -1 AND
         nvl(p_target_duration_uom,'ZZ') ='ZZ'
       )
    THEN
      fnd_message.set_name('PER', 'PER_449680_CKL_UNITS_UOM_INV');
      fnd_message.raise_error;
    END IF;
    --
    IF g_debug then hr_utility.set_location(l_proc, 5);  END IF;
    --
  EXCEPTION when app_exception.application_exception then
        if hr_multi_message.exception_add
                 (p_associated_column1      => 'PER_TASKS_INCHECKLIST.TARGET_DURATION_UOM'
                 ) then
              hr_utility.set_location(' Leaving:'|| l_proc, 60);
              raise;
            end if;
            hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_duration_uom;
--
/*
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_ckl_tsk_uinique >------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_ckl_tsk_unique
  (p_checklist_id         in    per_tasks_in_checklist.checklist_id%TYPE
  ,p_checklist_task_name  in    per_tasks_in_checklist.checklist_task_name%TYPE
   ) is
  --
  -- Declare local variables
  --
  l_proc  varchar2(72) := g_package||'chk_ckl_tsk_unique';
  l_dummy number;
  --
  -- Declare cursor to check name is unique.
  --
  cursor csr_ckl_tsk is
    select null
    from per_tasks_in_checklist tic
    where tic.checklist_id        = p_checklist_id
    and   tic.checklist_task_name = p_checklist_task_name;

  --
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- 	Check mandatory checklist_id exists if not null
  --
       open csr_ckl_tsk;
       fetch csr_ckl_tsk into l_dummy;
       if csr_ckl_tsk%found then
          close csr_ckl_tsk;
          hr_utility.set_message(800, 'HR_XXXX_CKL_TSK_INV_UNQ');
          hr_utility.raise_error;
       end if;
       close csr_ckl_tsk;
  --
  hr_utility.set_location(l_proc, 5);
  --
end chk_ckl_tsk_unique;
--

--  ---------------------------------------------------------------------------
--  |---------------------------< CHK_ELIG_PRFL_ID >--------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_elig_prfl_id
  (p_eligibility_profile_id       in    per_tasks_in_checklist.eligibility_profile_id%TYPE
  ,p_business_group_id  in    per_checklists.business_group_id%TYPE
  ,p_effective_date     in    date
   ) is
  --
  -- Declare local variables
  --
  l_proc  varchar2(72) := g_package||'chk_elig_prfl_id';
  l_dummy number;
  --
  -- Declare cursor to check name is unique.
  --
  cursor csr_elg_prf is
    select null
    from ben_eligy_prfl_f
    where eligy_prfl_id      = p_eligibility_profile_id
    and   business_group_id  = p_business_group_id
    and   p_effective_date between effective_start_date
                           and   effective_end_date;


  --
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- 	Check mandatory checklist_id exists if not null
  --
       open csr_elg_prf;
       fetch csr_elg_prf into l_dummy;
       if csr_elg_prf%notfound then
          close csr_elg_prf;
          hr_utility.set_message(800, 'HR_XXXX_CKL_TSK_INV_UNQ');
          hr_utility.raise_error;
       end if;
       close csr_elg_prf;
  --
  hr_utility.set_location(l_proc, 5);
  --
end chk_elig_prfl_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< CHK_ELIG_OBJ_ID >--------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_elig_obj_id
  (p_elig_obj_id       in    per_tasks_inchecklist.eligibility_profile_id%TYPE
  ,p_business_group_id  in    per_checklists.business_group_id%TYPE
  ,p_effective_date     in    date
   ) is
  --
  -- Declare local variables
  --
  l_proc  varchar2(72) := g_package||'chk_elig_obj_id';
  l_dummy number;
  --
  -- Declare cursor to check name is unique.
  --
  cursor csr_ben_obj is
    select null
    from ben_elig_obj_f beo
    where beo.elig_obj_id        = p_elig_obj_id
    and   beo.business_group_id  = p_business_group_id
    and   p_effective_date between beo.effective_start_date
    and   beo.effective_end_date;

  --
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- 	Check mandatory checklist_id exists if not null
  --
       open csr_ben_obj;
       fetch csr_ben_obj into l_dummy;
       if csr_ben_obj%notfound then
          close csr_ben_obj;
          hr_utility.set_message(800, 'HR_XXXX_CKL_TSK_INV_UNQ');
          hr_utility.raise_error;
       end if;
       close csr_ben_obj;
  --
  hr_utility.set_location(l_proc, 5);
  --
end chk_elig_obj_id;
*/
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
  (p_rec in per_ctk_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.task_in_checklist_id is not null)  and (
    nvl(per_ctk_shd.g_old_rec.information_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.information12, hr_api.g_varchar2) <>
    nvl(p_rec.information12, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2) ))
    or (p_rec.task_in_checklist_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
      ,p_attribute_category              => p_rec.information_category
      ,p_attribute1_name                 => 'INFORMATION1'
      ,p_attribute1_value                => p_rec.information1
      ,p_attribute2_name                 => 'INFORMATION2'
      ,p_attribute2_value                => p_rec.information2
      ,p_attribute3_name                 => 'INFORMATION3'
      ,p_attribute3_value                => p_rec.information3
      ,p_attribute4_name                 => 'INFORMATION4'
      ,p_attribute4_value                => p_rec.information4
      ,p_attribute5_name                 => 'INFORMATION5'
      ,p_attribute5_value                => p_rec.information5
      ,p_attribute6_name                 => 'INFORMATION6'
      ,p_attribute6_value                => p_rec.information6
      ,p_attribute7_name                 => 'INFORMATION7'
      ,p_attribute7_value                => p_rec.information7
      ,p_attribute8_name                 => 'INFORMATION8'
      ,p_attribute8_value                => p_rec.information8
      ,p_attribute9_name                 => 'INFORMATION9'
      ,p_attribute9_value                => p_rec.information9
      ,p_attribute10_name                => 'INFORMATION10'
      ,p_attribute10_value               => p_rec.information10
      ,p_attribute11_name                => 'INFORMATION11'
      ,p_attribute11_value               => p_rec.information11
      ,p_attribute12_name                => 'INFORMATION12'
      ,p_attribute12_value               => p_rec.information12
      ,p_attribute13_name                => 'INFORMATION13'
      ,p_attribute13_value               => p_rec.information13
      ,p_attribute14_name                => 'INFORMATION14'
      ,p_attribute14_value               => p_rec.information14
      ,p_attribute15_name                => 'INFORMATION15'
      ,p_attribute15_value               => p_rec.information15
      ,p_attribute16_name                => 'INFORMATION16'
      ,p_attribute16_value               => p_rec.information16
      ,p_attribute17_name                => 'INFORMATION17'
      ,p_attribute17_value               => p_rec.information17
      ,p_attribute18_name                => 'INFORMATION18'
      ,p_attribute18_value               => p_rec.information18
      ,p_attribute19_name                => 'INFORMATION19'
      ,p_attribute19_value               => p_rec.information19
      ,p_attribute20_name                => 'INFORMATION20'
      ,p_attribute20_value               => p_rec.information20
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
  (p_rec in per_ctk_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.task_in_checklist_id is not null)  and (
    nvl(per_ctk_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_ctk_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.task_in_checklist_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
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
  ,p_rec in per_ctk_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_ctk_shd.api_updating
      (p_task_in_checklist_id              => p_rec.task_in_checklist_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --

End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_ctk_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  per_ckl_bus.set_security_group_id
    (p_checklist_id    => p_rec.checklist_id);

  --
  -- Validate Dependent Attributes
  --

  per_ctk_bus.chk_checklist_id
  (p_checklist_id       => p_rec.checklist_id
   );
  --
  --
  --  Check task_name
  --
  per_ctk_bus.chk_task_name
  (p_checklist_task_name   => p_rec.checklist_task_name
  ,p_task_in_checklist_id  => p_rec.task_in_checklist_id
  ,p_checklist_id          => p_rec.checklist_id
  ,p_object_version_number => p_rec.object_version_number
   );
  --
  --  Check Duration and duration uom
  --
  per_ctk_bus.chk_duration_uom
  (p_target_duration        => p_rec.target_duration
  ,p_target_duration_uom    => p_rec.target_duration_uom
  ,p_task_in_checklist_id   => p_rec.task_in_checklist_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_effective_date         => p_effective_date
   );
  --
/*
  --
  per_ctk_bus.chk_ckl_tsk_unique
  (p_checklist_id        => p_rec.checklist_id
  ,p_checklist_task_name => p_rec.checklist_task_name
   );
  --

  per_ctk_bus.chk_elig_prfl_id
  (p_eligibility_profile_id   => p_rec.p_task_in_checklist_id
  ,p_business_group_id  in    => p_rec.p_task_in_checklist_id
  ,p_effective_date     in    date
   );


  --
  per_ctk_bus.chk_elig_obj_id
  (p_elig_obj_id          => p_rec.p_task_in_checklist_id
  ,p_business_group_id    => p_rec.p_task_in_checklist_id
  ,p_effective_date     in    date
   );
  --
  --
  per_ctk_bus.chk_ddf(p_rec);
  --
  per_ctk_bus.chk_df(p_rec);
  --
*/
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_ctk_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
    per_ckl_bus.set_security_group_id
    (p_checklist_id    => p_rec.checklist_id);
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  per_ctk_bus.chk_checklist_id
  (p_checklist_id       => p_rec.checklist_id
   );
  --
  --
  --  Check task_name
  --
  per_ctk_bus.chk_task_name
  (p_checklist_task_name   => p_rec.checklist_task_name
  ,p_task_in_checklist_id  => p_rec.task_in_checklist_id
  ,p_checklist_id          => p_rec.checklist_id
  ,p_object_version_number => p_rec.object_version_number
   );
  --
  --  Check Duration and duration uom
  --
  per_ctk_bus.chk_duration_uom
  (p_target_duration        => p_rec.target_duration
  ,p_target_duration_uom    => p_rec.target_duration_uom
  ,p_task_in_checklist_id   => p_rec.task_in_checklist_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_effective_date         => p_effective_date
   );
  --
/*
  --
  per_ctk_bus.chk_ckl_tsk_unique
  (p_checklist_id        => p_rec.checklist_id
  ,p_checklist_task_name => p_rec.checklist_task_name
   );
  --

  per_ctk_bus.chk_elig_prfl_id
  (p_eligibility_profile_id   => p_rec.p_task_in_checklist_id
  ,p_business_group_id  in    => p_rec.p_task_in_checklist_id
  ,p_effective_date     in    date
   );


  --
  per_ctk_bus.chk_elig_obj_id
  (p_elig_obj_id          => p_rec.p_task_in_checklist_id
  ,p_business_group_id    => p_rec.p_task_in_checklist_id
  ,p_effective_date     in    date
   );
  --
  --
  per_ctk_bus.chk_ddf(p_rec);
  --
  per_ctk_bus.chk_df(p_rec);
  --
*/
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_ctk_shd.g_rec_type
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
end per_ctk_bus;

/
