--------------------------------------------------------
--  DDL for Package Body PER_PDM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PDM_BUS" as
/* $Header: pepdmrhi.pkb 115.8 2002/12/09 14:33:06 pkakar ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pdm_bus.';  -- Global package name
--
--
-- --------------------------------------------------------------------------
-- |---------------------< chk_non_updateable_args >------------------------|
-- --------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_rec            in per_pdm_shd.g_rec_type
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
  if not per_pdm_shd.api_updating
      (p_delivery_method_id        => p_rec.delivery_method_id
      ,p_object_version_number         => p_rec.object_version_number
      ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '20');
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  if p_rec.person_id <> per_pdm_shd.g_old_rec.person_id then
     l_argument := 'person_id';
     raise l_error;
  end if;
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
       (p_person_id	                 in	number,
        p_effective_date                 in     date
       ) is
--
--  Local declarations
  l_proc			varchar2(72) := g_package||' chk_person_id';
  l_person_id               number;

  -- Setup cursor for valid module type check
  cursor csr_valid_person_id is
    select person_id
    from per_all_people_f
    where person_id = p_person_id
    and   ((effective_start_date <= p_effective_date and
           effective_end_date   >= p_effective_date));
--
begin
   hr_utility.set_location('Entering: '||l_proc,5);
   --
   --------------------------------
   -- Check person id not null --
   --------------------------------
   if p_person_id is null then
      hr_utility.set_message(801,'HR_52460_PDM_NULL_PERSON_ID');
      hr_utility.raise_error;
   end if;

   --------------------------------
   -- Check person id is valid --
   --------------------------------
   open csr_valid_person_id;
   fetch csr_valid_person_id into l_person_id;
   if csr_valid_person_id%notfound then
      close csr_valid_person_id;
        per_pdm_shd.constraint_error('PER_PERSON_DLVRY_METHODS_FK1');
   end if;
   close csr_valid_person_id;

   hr_utility.set_location('Leaving: '||l_proc,10);
end chk_person_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_comm_dlvry_method >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   delivery_method_id    PK of record being inserted or updated.
--   comm_dlvry_method     Value of lookup code.
--   person_id             Parent Row Id.
--   effective_date        effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by procedure. Errors raised if there exists another
--   row in the table with this delivery method for this person. Also,
--   the delivery method is validated against a lookup table.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_comm_dlvry_method(p_delivery_method_id         in number,
                                p_comm_dlvry_method           in varchar2,
                                p_person_id                   in number,
                                p_effective_date              in date,
                                p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_comm_dlvry_method';
  l_delivery_method_id number;
  --
  --
  -- Setup cursor for combination check
  --
  cursor csr_check_uniqueness is
    select delivery_method_id
    from per_person_dlvry_methods
    where comm_dlvry_method =  p_comm_dlvry_method
    and   person_id          = p_person_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --------------------------------------
  -- Check comm_dlvry_method not null --
  --------------------------------------
  --
   if p_comm_dlvry_method is null then
      hr_utility.set_message(801,'HR_52461_PDM_NULL_COMM_ID');
      hr_utility.raise_error;
   end if;
  --
  -----------------------------------
  -- Check that person id is not null
  -----------------------------------
  --
  hr_api.mandatory_arg_error
    (p_api_name	        => l_proc
    ,p_argument	        => 'person_id'
    ,p_argument_value	  => p_person_id
    );

  --
  if (p_comm_dlvry_method
      <> nvl(per_pdm_shd.g_old_rec.comm_dlvry_method,hr_api.g_varchar2) )
      and p_comm_dlvry_method is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PER_CM_MTHD',
           p_lookup_code    => p_comm_dlvry_method,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_52391_PDM_INV_DLVRY_METHOD');
      hr_utility.raise_error;
      --
    end if;
    --
    ----------------------------------------
    -- Check uniqueness of created record --
    ----------------------------------------
    --
    open csr_check_uniqueness;
    fetch csr_check_uniqueness into l_delivery_method_id;
    if csr_check_uniqueness%found then
        close csr_check_uniqueness;
        per_pdm_shd.constraint_error('PER_PERSON_DLVRY_METHODS_UK1');
    end if;
    close csr_check_uniqueness;
    --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_comm_dlvry_method;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_date_start_end >------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    DATE_START is mandatory
--    DATE_START must be less than DATE_END
--
--  Pre-conditions :
--    Format for date_from and date_to must be correct
--
--  In Arguments :
--    p_delivery_method_id
--    p_date_start
--    p_date_end
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_date_start_end
  (p_delivery_method_id in      number
  ,p_date_start		in	date
  ,p_date_end		in	date
  ,p_object_version_number in   number
    )	is
--
 l_proc  varchar2(72) := g_package||'chk_date_start';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- 	Check mandatory parameters have been set
  --
  if p_date_start is null then
     hr_utility.set_message(801,'HR_52462_PDM_NULL_DATE_START');
     hr_utility.raise_error;
  end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date_start or date_start value has changed
  --
  if ((nvl(per_pdm_shd.g_old_rec.date_start,hr_api.g_date)
             <> nvl(p_date_start,hr_api.g_date)
           or nvl(per_pdm_shd.g_old_rec.date_end,hr_api.g_date)
             <> nvl(p_date_end,hr_api.g_date)))
     then
     hr_utility.set_location(l_proc, 2);
     --
     -- Check that the date_start value is less than or equal to the date_start
     -- value for the current record
     --
     if p_date_start > nvl(p_date_end,hr_api.g_eot)then
        hr_utility.set_message(801,'PER_7004_ALL_DATE_TO_FROM');
        hr_utility.raise_error;
     end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
end chk_date_start_end;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_preferred_flag >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   delivery_method_id PK of record being inserted or updated.
--   preferred_flag Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error is raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_preferred_flag(p_delivery_method_id          in number,
                             p_preferred_flag              in varchar2,
                             p_person_id                   in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_preferred_flag';
  l_delivery_method_id number;
  --
  --
  -- Setup cursor for combination check
  --
  cursor csr_check_uniqueness is
    select delivery_method_id
    from per_person_dlvry_methods
    where preferred_flag     = 'Y'
    and   person_id          = p_person_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if (nvl(p_preferred_flag, hr_api.g_varchar2)
      <> nvl(per_pdm_shd.g_old_rec.preferred_flag,hr_api.g_varchar2))
      and p_preferred_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_preferred_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_52393_PDM_INV_PREF_FLAG');
      hr_utility.raise_error;
      --
    end if;
    --
    -- If Value is being set to 'Y' then check that this is the only
    -- row that has preferred flag set to Y.
    --
    if p_preferred_flag = 'Y' then
    --
      open csr_check_uniqueness;
      fetch csr_check_uniqueness into l_delivery_method_id;
      if csr_check_uniqueness%found then
          close csr_check_uniqueness;
          hr_utility.set_message(801, 'HR_52394_PDM_DUP_PREF_FLAG');
          hr_utility.raise_error;
      end if;
      close csr_check_uniqueness;
    --
    end if;
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_preferred_flag;
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
procedure chk_df
  (p_rec in per_pdm_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.delivery_method_id is not null) and (
     nvl(per_pdm_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.attribute_category, hr_api.g_varchar2) or
     nvl(per_pdm_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.attribute1, hr_api.g_varchar2) or
     nvl(per_pdm_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.attribute2, hr_api.g_varchar2) or
     nvl(per_pdm_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.attribute3, hr_api.g_varchar2) or
     nvl(per_pdm_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.attribute4, hr_api.g_varchar2) or
     nvl(per_pdm_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.attribute5, hr_api.g_varchar2) or
     nvl(per_pdm_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.attribute6, hr_api.g_varchar2) or
     nvl(per_pdm_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.attribute7, hr_api.g_varchar2) or
     nvl(per_pdm_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
     nvl(per_pdm_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.attribute9, hr_api.g_varchar2) or
     nvl(per_pdm_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.attribute10, hr_api.g_varchar2) or
     nvl(per_pdm_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.attribute11, hr_api.g_varchar2) or
     nvl(per_pdm_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.attribute12, hr_api.g_varchar2) or
     nvl(per_pdm_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.attribute13, hr_api.g_varchar2) or
     nvl(per_pdm_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.attribute14, hr_api.g_varchar2) or
     nvl(per_pdm_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.attribute15, hr_api.g_varchar2) or
     nvl(per_pdm_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.attribute16, hr_api.g_varchar2) or
     nvl(per_pdm_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.attribute17, hr_api.g_varchar2) or
     nvl(per_pdm_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.attribute18, hr_api.g_varchar2) or
     nvl(per_pdm_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.attribute19, hr_api.g_varchar2) or
     nvl(per_pdm_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.attribute20, hr_api.g_varchar2)))
     or
     (p_rec.delivery_method_id is null) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_PERSON_DLVRY_METHODS'
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
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_df;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_pdm_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_person_id
  (p_person_id             => p_rec.person_id,
   p_effective_date        => p_effective_date);
  --
  chk_comm_dlvry_method
  (p_delivery_method_id    => p_rec.delivery_method_id,
   p_comm_dlvry_method     => p_rec.comm_dlvry_method,
   p_person_id             => p_rec.person_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  if not per_pdm_bus.g_called_from_form then
    chk_preferred_flag
    (p_delivery_method_id    => p_rec.delivery_method_id,
     p_person_id             => p_rec.person_id,
     p_preferred_flag        => p_rec.preferred_flag,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  end if;
  --
  chk_date_start_end
  (p_delivery_method_id    =>   p_rec.delivery_method_id
  ,p_date_start		   =>	p_rec.date_start
  ,p_date_end		   =>	p_rec.date_end
  ,p_object_version_number =>   p_rec.object_version_number);
  --
  -- Call descriptive flexfield validation routines
  --
  per_pdm_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_pdm_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_non_updateable_args
    (p_rec            => p_rec
    ,p_effective_date => p_effective_date);
  --
  chk_comm_dlvry_method
  (p_delivery_method_id    => p_rec.delivery_method_id,
   p_comm_dlvry_method     => p_rec.comm_dlvry_method,
   p_person_id             => p_rec.person_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  -- No need to call this chk routine if calling from form as only
  -- one check box can ever be checked.
  --
  if not per_pdm_bus.g_called_from_form then
    chk_preferred_flag
    (p_delivery_method_id    => p_rec.delivery_method_id,
     p_person_id             => p_rec.person_id,
     p_preferred_flag        => p_rec.preferred_flag,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  end if;
  --
  chk_date_start_end
  (p_delivery_method_id    =>   p_rec.delivery_method_id
  ,p_date_start		   =>	p_rec.date_start
  ,p_date_end		   =>	p_rec.date_end
  ,p_object_version_number =>   p_rec.object_version_number);
  --
  -- Call descriptive flexfield validation routines
  --
  per_pdm_bus.chk_df(p_rec => p_rec);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_pdm_shd.g_rec_type) is
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
--
-- ---------------------------------------------------------------------------
-- |---------------------< return_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_delivery_method_id              in number
  ) return varchar2 is
  --
  -- Cursor to find legislation code
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups  pbg
         , per_person_dlvry_methods pdm
         , per_all_people_f     per
     where pdm.delivery_method_id = p_delivery_method_id
       and pdm.person_id        = per.person_id
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
                             p_argument       => 'delivery_method_id',
                             p_argument_value => p_delivery_method_id);
  --
  if nvl(g_delivery_method_id, hr_api.g_number) = p_delivery_method_id then
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
    g_delivery_method_id        := p_delivery_method_id;
    g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< set_called_from_form >------------------------|
-- ----------------------------------------------------------------------------
procedure set_called_from_form
   ( p_flag     in boolean ) as
begin
   g_called_from_form := p_flag;
end;
--
end per_pdm_bus;

/
