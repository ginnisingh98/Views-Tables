--------------------------------------------------------
--  DDL for Package Body PER_PTU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PTU_BUS" as
/* $Header: pepturhi.pkb 120.0 2005/05/31 15:57:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ptu_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
            (
             p_person_id                     in number default hr_api.g_number,
        p_datetrack_mode           in varchar2,
             p_validation_start_date        in date,
        p_validation_end_date      in date) Is
--
  l_proc     varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name     all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack update mode is valid
  --
  If (dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode)) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    If ((nvl(p_person_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'per_all_people_f', -- Bug 3111207
             p_base_key_column => 'person_id',
             p_base_key_value  => p_person_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'people';
      Raise l_integrity_error;
    End If;
    --
    --
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    hr_utility.set_message(801, 'HR_7216_DT_UPD_INTEGRITY_ERR');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
            (p_person_type_usage_id    in number,
             p_datetrack_mode    in varchar2,
        p_validation_start_date  in date,
        p_validation_end_date in date) Is
--
  l_proc varchar2(72)   := g_package||'dt_delete_validate';
  l_rows_exist Exception;
  l_table_name all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = 'DELETE' or
      p_datetrack_mode = 'ZAP') then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'person_type_usage_id',
       p_argument_value => p_person_type_usage_id);
    --
    --
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    hr_utility.set_message(801, 'HR_7215_DT_CHILD_EXISTS');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_delete_validate;
--
--
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
procedure check_df
  (p_rec in per_ptu_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.person_type_usage_id is not null) and (
     nvl(per_ptu_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.attribute_category, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.attribute1, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.attribute2, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.attribute3, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.attribute4, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.attribute5, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.attribute6, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.attribute7, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.attribute9, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.attribute10, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.attribute11, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.attribute12, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.attribute13, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.attribute14, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.attribute15, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.attribute16, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.attribute17, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.attribute18, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.attribute19, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.attribute20, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
     nvl(p_rec.attribute21, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
     nvl(p_rec.attribute22, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
     nvl(p_rec.attribute23, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
     nvl(p_rec.attribute24, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
     nvl(p_rec.attribute25, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
     nvl(p_rec.attribute26, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
     nvl(p_rec.attribute27, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
     nvl(p_rec.attribute28, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
     nvl(p_rec.attribute29, hr_api.g_varchar2) or
     nvl(per_ptu_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
     nvl(p_rec.attribute30, hr_api.g_varchar2)))
     or
     (p_rec.person_type_usage_id is null) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_PERSON_TYPE_USAGES'
      ,p_attribute_category => p_rec.attribute_category
      ,p_attribute1_name    => 'ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.attribute1
      ,p_attribute2_name    => 'ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.attribute2
      ,p_attribute3_name    => 'ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.attribute3
      ,p_attribute4_name    => 'ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.attribute4
      ,p_attribute5_name    => 'ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.attribute5
      ,p_attribute6_name    => 'ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.attribute6
      ,p_attribute7_name    => 'ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.attribute7
      ,p_attribute8_name    => 'ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.attribute8
      ,p_attribute9_name    => 'ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.attribute9
      ,p_attribute10_name   => 'ATTRIBUTE10'
      ,p_attribute10_value  => p_rec.attribute10
      ,p_attribute11_name   => 'ATTRIBUTE11'
      ,p_attribute11_value  => p_rec.attribute11
      ,p_attribute12_name   => 'ATTRIBUTE12'
      ,p_attribute12_value  => p_rec.attribute12
      ,p_attribute13_name   => 'ATTRIBUTE13'
      ,p_attribute13_value  => p_rec.attribute13
      ,p_attribute14_name   => 'ATTRIBUTE14'
      ,p_attribute14_value  => p_rec.attribute14
      ,p_attribute15_name   => 'ATTRIBUTE15'
      ,p_attribute15_value  => p_rec.attribute15
      ,p_attribute16_name   => 'ATTRIBUTE16'
      ,p_attribute16_value  => p_rec.attribute16
      ,p_attribute17_name   => 'ATTRIBUTE17'
      ,p_attribute17_value  => p_rec.attribute17
      ,p_attribute18_name   => 'ATTRIBUTE18'
      ,p_attribute18_value  => p_rec.attribute18
      ,p_attribute19_name   => 'ATTRIBUTE19'
      ,p_attribute19_value  => p_rec.attribute19
      ,p_attribute20_name   => 'ATTRIBUTE20'
      ,p_attribute20_value  => p_rec.attribute20
      ,p_attribute21_name   => 'ATTRIBUTE21'
      ,p_attribute21_value  => p_rec.attribute21
      ,p_attribute22_name   => 'ATTRIBUTE22'
      ,p_attribute22_value  => p_rec.attribute22
      ,p_attribute23_name   => 'ATTRIBUTE23'
      ,p_attribute23_value  => p_rec.attribute23
      ,p_attribute24_name   => 'ATTRIBUTE24'
      ,p_attribute24_value  => p_rec.attribute24
      ,p_attribute25_name   => 'ATTRIBUTE25'
      ,p_attribute25_value  => p_rec.attribute25
      ,p_attribute26_name   => 'ATTRIBUTE26'
      ,p_attribute26_value  => p_rec.attribute26
      ,p_attribute27_name   => 'ATTRIBUTE27'
      ,p_attribute27_value  => p_rec.attribute27
      ,p_attribute28_name   => 'ATTRIBUTE28'
      ,p_attribute28_value  => p_rec.attribute28
      ,p_attribute29_name   => 'ATTRIBUTE29'
      ,p_attribute29_value  => p_rec.attribute29
      ,p_attribute30_name   => 'ATTRIBUTE30'
      ,p_attribute30_value  => p_rec.attribute30
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end check_df;
--
-- --------------------------------------------------------------------------
-- |---------------------< chk_non_updateable_args >------------------------|
-- --------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_rec            in per_ptu_shd.g_rec_type
  ,p_effective_date in date
  ) is
--
  l_proc     varchar2(72) := g_package||'chk_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema
  --
  if not per_ptu_shd.api_updating
      (p_person_type_usage_id          => p_rec.person_type_usage_id
      ,p_object_version_number         => p_rec.object_version_number
      ,p_effective_date                => p_effective_date
      ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '20');
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  -- Bug# 2195731 Starts here. If Condition changed.
  --
  if p_rec.person_id <> per_ptu_shd.g_old_rec.person_id then
     l_argument := 'person_id';
     raise l_error;
  end if;
  --
  -- Bug# 2195731 Ends here.
  --
  hr_utility.set_location(l_proc, 50);
  --
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument
         );
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 100);
end chk_non_updateable_args;

--
--  -----------------------------------------------------------------
--  |-----------------------< chk_person_id >-------------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check that the person_id is not null and that it refers to a row on
--    the parent PER_ALL_PEOPLE_F table.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_person_id
--
--  Post Success:
--    Processing continues if the person_id is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the person_id is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_person_id
       (p_person_id                   in  number
       ) is
--
--  Local declarations
  l_proc       varchar2(72) := g_package||' chk_person_id';
  l_person_id               number;

  -- Setup cursor for valid module type check
  cursor csr_valid_person_id is
    select person_id
    from per_all_people_f
    where person_id = p_person_id;
--
begin
   hr_utility.set_location('Entering: '||l_proc,5);
        --
        --------------------------------
        -- Check person id not null --
        --------------------------------
        hr_api.mandatory_arg_error
           (p_api_name => l_proc,
            p_argument =>  'p_person_id',
            p_argument_value => p_person_id);

        --------------------------------
        -- Check person id is valid --
        --------------------------------
        open csr_valid_person_id;
        fetch csr_valid_person_id into l_person_id;
        if csr_valid_person_id%notfound then
           close csr_valid_person_id;
           per_ptu_shd.constraint_error('PER_PERSON_TYPE_USAGES_F_FK1');
        end if;
        close csr_valid_person_id;

   hr_utility.set_location('Leaving: '||l_proc,10);
end chk_person_id;
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_person_type_id >------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check that the person_type_id is not null and that it refers to a row on
--    the parent PER_PERSON_TYPES table.
--    Amendments to ensure that only valid person_types are inserted/updated
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_person_type_usage_id
--    p_person_type_id
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if the person_type_id is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the person_type_id is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_person_type_id
       (p_person_type_usage_id           in     number,
        p_person_id                      in     number,
        p_person_type_id            in number,
        p_effective_date                 in     date,
        p_object_version_number          in     number
       ) is
--
--  Local declarations
  l_proc                    varchar2(72) := g_package||' chk_person_type_id';
  l_person_type             per_person_types.system_person_type%TYPE;
  l_business_group_id             per_person_types.business_group_id%TYPE;
  l_old_person_type         per_person_types.system_person_type%TYPE;
  l_person_type_id               number;
  l_api_updating                 boolean;
  --
  -- Setup cursor for valid module type check
  --
  cursor csr_valid_person_type ( lc_person_type_id number)
    is
    select system_person_type ,business_group_id
    from per_person_types
    where person_type_id = lc_person_type_id;

  --
  -- Setup cursor for combination check
  --
  -- We are doing this check regardless of the enabled flag
  -- as even old records must be used for this validation
  cursor csr_check_uniqueness is
    select person_type_usage_id
    from per_person_type_usages_f
    where person_type_id in ( select person_type_id
                              from per_person_types
                              where system_person_type = l_person_type
                              and business_group_id = l_business_group_id )
    and   person_id      = p_person_id
    and   ((effective_start_date <= p_effective_date and
           effective_end_date   >= p_effective_date) or
          (effective_start_date >= p_effective_date));
  --
begin
    hr_utility.set_location('Entering: '||l_proc,5);
    --
    -----------------------------------
    -- Check person type id not null --
    -----------------------------------
    --
    hr_api.mandatory_arg_error
        (p_api_name => l_proc,
         p_argument =>  'p_person_type_id',
         p_argument_value => p_person_type_id);
    --
    l_api_updating := per_ptu_shd.api_updating
             (p_effective_date        => p_effective_date,
              p_person_type_usage_id  => p_person_type_usage_id,
              p_object_version_number => p_object_version_number
              );
    --
    -- Proceed with validation based on outcome of api_updating call.
    --
    -- We are initially checking only for valid person types
    -- i.e. those that can be maintained by the user
    --
    hr_utility.set_location('At: '||l_proc,10);

    if ((l_api_updating and
        per_ptu_shd.g_old_rec.person_type_id <> p_person_type_id) or
        (not l_api_updating)) then
        -----------------------------------
        -- Check person type id is valid --
        -----------------------------------
        open csr_valid_person_type(p_person_type_id);
        fetch csr_valid_person_type into l_person_type , l_business_group_id;
        if csr_valid_person_type%notfound then
           close csr_valid_person_type;
           per_ptu_shd.constraint_error('PER_PERSON_TYPE_USAGES_F_FK2');
        end if;
        close csr_valid_person_type;

        hr_utility.set_location('At: '||l_proc,15);
      --
      -- Based on whether this is called call the relevant procedure
      --
        if ( not l_api_updating ) THEN

          --
          -- This processing will only take place if it is create
          --

          if ( l_person_type = 'EX_EMP' or
               l_person_type = 'EX_APL' or
               l_person_type = 'EMP_APL' or
               l_person_type = 'EX_EMP_APL' or
               l_person_type = 'APL_EX_APL') then
             per_ptu_shd.constraint_error('PER_PERSON_TYPE_USAGES_F_FK2');
          end if;
        --
          --
          hr_utility.set_location('At: '||l_proc,20);
          ----------------------------------------
          -- Check uniqueness of created record --
          ----------------------------------------
          --
          open csr_check_uniqueness;
          fetch csr_check_uniqueness into l_person_type_id;
          if csr_check_uniqueness%found then
             close csr_check_uniqueness;
             fnd_message.set_name('PER', 'HR_52376_PTU_DUPLICATE_REC');
             fnd_message.raise_error;
          end if;
          close csr_check_uniqueness;
          --
        else

          -- On update we need to check whether the system person_type
          -- is the same as the existing one
          -- As per business rules person type can be updated from one
          -- flavour to an other.

          hr_utility.set_location('At: '||l_proc,25);


          -----------------------------------
          -- Check person type id is valid --
          -----------------------------------
          open csr_valid_person_type(per_ptu_shd.g_old_rec.person_type_id);
          fetch csr_valid_person_type into l_old_person_type , l_business_group_id;
          if csr_valid_person_type%notfound then
             close csr_valid_person_type;
             per_ptu_shd.constraint_error('PER_PERSON_TYPE_USAGES_F_FK2');
          end if;
          close csr_valid_person_type;
--
-- PTU changes: now allow transitions between type and ex_type
--
         IF (l_old_person_type <> l_person_type)
         AND (  (l_old_person_type in ('EMP','EX_EMP')
                and l_person_type not in ('EMP','EX_EMP'))
             or (l_old_person_type in ('APL','EX_APL')
                and l_person_type not in ('APL','EX_APL')))  THEN

            fnd_message.set_name('PER', 'HR_52362_PTU_INV_PER_TYPE_ID');
            fnd_message.raise_error;

         END IF;

      end if;
    end if;

    hr_utility.set_location('Leaving: '||l_proc,50);
end chk_person_type_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
   (p_rec          in per_ptu_shd.g_rec_type,
    p_effective_date  in date,
    p_datetrack_mode  in varchar2,
    p_validation_start_date in date,
    p_validation_end_date   in date) is
--
  l_proc varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_per_bus.set_security_group_id
  (
   p_person_id => p_rec.person_id
  );
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  -- Call all supporting business operations
  --
  -- Validate the Person Id
       chk_person_id
       (p_person_id              => p_rec.person_id);
  --
  -- Validate the Person Type Id
       chk_person_type_id
       (p_person_type_usage_id       => p_rec.person_type_usage_id,
        p_person_id                  => p_rec.person_id,
        p_person_type_id             => p_rec.person_type_id,
        p_effective_date             => p_effective_date,
        p_object_version_number      => p_rec.object_version_number);
  --
  -- Call descriptive flexfield validation routines
  --
     per_ptu_bus.check_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
   (p_rec          in per_ptu_shd.g_rec_type,
    p_effective_date  in date,
    p_datetrack_mode  in varchar2,
    p_validation_start_date in date,
    p_validation_end_date   in date) is
--
  l_proc varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_per_bus.set_security_group_id
  (
   p_person_id => p_rec.person_id
  );
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  -- Call all supporting business operations
  --
  chk_non_updateable_args
    (p_rec            => p_rec
    ,p_effective_date => p_effective_date);
  --
  -- Validate the Person Type Id
       chk_person_type_id
       (p_person_type_usage_id       => p_rec.person_type_usage_id,
        p_person_id                  => p_rec.person_id,
        p_person_type_id             => p_rec.person_type_id,
        p_effective_date             => p_effective_date,
        p_object_version_number      => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_person_id                  => p_rec.person_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date       => p_validation_start_date,
     p_validation_end_date      => p_validation_end_date);
  --
  --
  -- Call descriptive flexfield validation routines
  --
     per_ptu_bus.check_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
   (p_rec          in per_ptu_shd.g_rec_type,
    p_effective_date  in date,
    p_datetrack_mode  in varchar2,
    p_validation_start_date in date,
    p_validation_end_date   in date) is
--
  l_proc varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --chk_is_valid_delete(p_person_type_usage_id => p_rec.person_type_usage_id,
                      --p_effective_date => p_effective_date);

  dt_delete_validate
    (p_datetrack_mode      => p_datetrack_mode,
     p_validation_start_date  => p_validation_start_date,
     p_validation_end_date => p_validation_end_date,
     p_person_type_usage_id   => p_rec.person_type_usage_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< return_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_person_type_usage_id              in number
  ) return varchar2 is
  --
  -- Cursor to find legislation code
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups  pbg
         , per_person_type_usages_f ptu
         , per_all_people_f     per
     where ptu.person_type_usage_id = p_person_type_usage_id
       and ptu.person_id        = per.person_id
       and pbg.business_group_id = per.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  'return_legislation_code';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'person_type_usage_id',
                             p_argument_value => p_person_type_usage_id);
  --
  if nvl(g_person_type_usage_id, hr_api.g_number) = p_person_type_usage_id then
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
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
    end if;
    hr_utility.set_location(l_proc, 30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function
    --
    close csr_leg_code;
    g_person_type_usage_id        := p_person_type_usage_id;
    g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
  return l_legislation_code;
end return_legislation_code;
--
end per_ptu_bus;

/
