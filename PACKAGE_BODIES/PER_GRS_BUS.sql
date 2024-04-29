--------------------------------------------------------
--  DDL for Package Body PER_GRS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GRS_BUS" as
/* $Header: pegrsrhi.pkb 115.3 2002/12/05 17:40:37 pkakar ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_grs_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------< chk_cagr_grade_structure_id >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the table
--   is created properly. It should be null on insert and
--   should not be able to be updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cagr_grade_structure_id PK of record being inserted or updated.
--   object_version_number Object version number of record being
--                         inserted or updated.
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
Procedure chk_cagr_grade_structure_id(p_cagr_grade_structure_id                in number,
                                      p_object_version_number       in number,
                                      p_effective_date 		in date) is
  --
  l_proc         varchar2(72) := g_package||'chk_cagr_grade_structure_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_grs_shd.api_updating
    (p_cagr_grade_structure_id                => p_cagr_grade_structure_id,
     p_object_version_number       => p_object_version_number,
     p_effective_date		=>  p_effective_date);
  --
  if (l_api_updating
     and nvl(p_cagr_grade_structure_id,hr_api.g_number)
     <>  per_grs_shd.g_old_rec.cagr_grade_structure_id) then
    --
    -- raise error as PK has changed
    --
    per_grs_shd.constraint_error('PER_CAGR_GRADE_STRUCTURES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_cagr_grade_structure_id is not null then
      --
      -- raise error as PK is not null
      --
      per_grs_shd.constraint_error('PER_CAGR_GRADE_STRUCTURES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_cagr_grade_structure_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_collective_agreement_id >-----------------------|
-- ----------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that COLLECTIVE_AGREEMENT_ID is not null
--
--    Validates that values enterd for this column exist in the PER_COLLECTIVE_AGREEMENTS
--    table.
--
--  Pre-conditions:
--
--  In Arguments :
--    p_collective_agreement_id
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- -----------------------------------------------------------------------
Procedure chk_collective_agreement_id
 (p_collective_agreement_id   in per_cagr_grade_structures.collective_agreement_id%TYPE
  ) is
--
  l_proc                 varchar2(72) := g_package||'chk_collective_agreement_id';
  l_exists 		 varchar2(2);
--
  --
  -- Cursor to check that COLLECTIVE_AGREEMENT_ID exists
  --
  cursor csr_valid_cagr_id is
    select   '1'
      from   per_collective_agreements   per
     where   per.collective_agreement_id   = p_collective_agreement_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Perform COLLECTIVE_AGREEMENT_ID mandatory check
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'collective_agreement_id'
    ,p_argument_value => p_collective_agreement_id
   );
  --
  hr_utility.set_location(l_proc,10);
  --
  --  Check for valid COLLECTIVE_AGREEMENT_ID
  --
  open csr_valid_cagr_id;
  fetch csr_valid_cagr_id
        into l_exists;
  if (csr_valid_cagr_id%notfound) then
    --
    close csr_valid_cagr_id;
    --
    hr_utility.set_message(800,'PER_52816_COLLECTIVE_AGREEMENT');
    hr_utility.raise_error;
  end if;
  --
  close csr_valid_cagr_id;
  --
    hr_utility.set_location('Leaving:'|| l_proc, 20);
end chk_collective_agreement_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_id_flex_num >-----------------------------------|
-- ----------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that ID_FLEX_NUM is not null.
--
--    Validates that values enterd for this column exist in the
--    FND_ID_FLEX_STRUCTURES table.
--
--  Pre-conditions:
--
--  In Arguments :
--
--    p_id_flex_num
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- -----------------------------------------------------------------------
Procedure chk_id_flex_num
       (p_id_flex_num           in fnd_id_flex_structures.id_flex_num%TYPE
       ) is
  --
  l_proc           varchar2(72) := g_package||'chk_id_flex_num';
  l_exists 		 varchar2(2);
  --
  -- Cursor to check that ID_FLEX_NUM exists
  --
  cursor csr_valid_id_flex_num is
    select   '1'
      from   fnd_id_flex_structures   fnd
     where   fnd.id_flex_num   = p_id_flex_num;
  --
begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Perform id_flex_num mandatory check
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'id_flex_num'
    ,p_argument_value => p_id_flex_num
   );
  --
  hr_utility.set_location(l_proc,10);
  --
  --  Check for valid ID_FLEX_NUM
  --
  open csr_valid_id_flex_num;
  fetch csr_valid_id_flex_num
        into l_exists;
  if (csr_valid_id_flex_num%notfound) then
    --
    close csr_valid_id_flex_num;
    --
    hr_utility.set_message(800,'HR_51741_ANC_FLEX_NOT_EXIST');
    hr_utility.raise_error;
  end if;
  --
  close csr_valid_id_flex_num;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
end chk_id_flex_num;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_comb_flex_cagr >--------------------------------|
-- ----------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that the combinaison 'id_flex_num - collective_agreement_id'
--    does not exist.
--
--  Pre-conditions:
--
--  In Arguments :
--
--    p_id_flex_num
--    p_collective_agreement_id
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- -----------------------------------------------------------------------
Procedure chk_comb_flex_cagr
 (p_id_flex_num               in per_cagr_grade_structures.id_flex_num%TYPE,
  p_collective_agreement_id   in per_cagr_grade_structures.collective_agreement_id%TYPE
  ) is
  --
  l_proc           varchar2(72) := g_package||'chk_comb_flex_cagr';
  l_exists 		 varchar2(2);
  --
  -- Cursor to check that ID_FLEX_NUM exists
  --
  cursor csr_comb_flex_cagr is
    select   '1'
      from   per_cagr_grade_structures  pcg
     where   pcg.id_flex_num   = p_id_flex_num
     and     pcg.collective_agreement_id = p_collective_agreement_id;
  --
begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Perform id_flex_num mandatory check
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'id_flex_num'
    ,p_argument_value => p_id_flex_num
   );
  --
  hr_utility.set_location(l_proc,10);
  --
  -- Perform COLLECTIVE_AGREEMENT_ID mandatory check
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'collective_agreement_id'
    ,p_argument_value => p_collective_agreement_id
   );
  --
  hr_utility.set_location(l_proc,15);
  --
  --  Check for valid combinaison
  --
  open csr_comb_flex_cagr;
  fetch csr_comb_flex_cagr
        into l_exists;
  if (csr_comb_flex_cagr%found) then
    --
    close csr_comb_flex_cagr;
    --
    hr_utility.set_message(800,'PER_52808_CAGR_GRADE_EXISTS');
    hr_utility.raise_error;
  end if;
  --
  close csr_comb_flex_cagr;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end chk_comb_flex_cagr;
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
  (p_rec in per_grs_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.cagr_grade_structure_id is not null) and (
     nvl(per_grs_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.attribute_category, hr_api.g_varchar2) or
     nvl(per_grs_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.attribute1, hr_api.g_varchar2) or
     nvl(per_grs_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.attribute2, hr_api.g_varchar2) or
     nvl(per_grs_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.attribute3, hr_api.g_varchar2) or
     nvl(per_grs_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.attribute4, hr_api.g_varchar2) or
     nvl(per_grs_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.attribute5, hr_api.g_varchar2) or
     nvl(per_grs_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.attribute6, hr_api.g_varchar2) or
     nvl(per_grs_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.attribute7, hr_api.g_varchar2) or
     nvl(per_grs_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.attribute8, hr_api.g_varchar2) or
     nvl(per_grs_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.attribute9, hr_api.g_varchar2) or
     nvl(per_grs_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.attribute10, hr_api.g_varchar2) or
     nvl(per_grs_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.attribute11, hr_api.g_varchar2) or
     nvl(per_grs_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.attribute12, hr_api.g_varchar2) or
     nvl(per_grs_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.attribute13, hr_api.g_varchar2) or
     nvl(per_grs_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.attribute14, hr_api.g_varchar2) or
     nvl(per_grs_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.attribute15, hr_api.g_varchar2) or
     nvl(per_grs_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.attribute16, hr_api.g_varchar2) or
     nvl(per_grs_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.attribute17, hr_api.g_varchar2) or
     nvl(per_grs_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.attribute18, hr_api.g_varchar2) or
     nvl(per_grs_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.attribute19, hr_api.g_varchar2) or
     nvl(per_grs_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.attribute20, hr_api.g_varchar2)))
     or
     (p_rec.cagr_grade_structure_id is null) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_CAGR_GRADE_STRUCTURES'
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
--  ---------------------------------------------------------------------------
--  |-----------------< chk_dynamic_insert_allowed >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check that the passed in lookup code exists in fnd_lookups for the with an
--    enabled flag set to 'Y' .
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_dynamic_insert_allowed
--    p_effective_date
--
--  Post Success:
--    If lookup exists and can be derived then processing
--    continues
--
--  Post Failure:
--    If lookup is not valid or cannot be derived then an
--    application error is raised and processing is terminated
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_dynamic_insert_allowed
 (p_cagr_grade_structure_id in     per_cagr_grade_structures.cagr_grade_structure_id%TYPE
 ,p_dynamic_insert_allowed  in     per_cagr_grade_structures.dynamic_insert_allowed%TYPE
 ,p_effective_date          in     date
 ,p_object_version_number   in     per_cagr_grade_structures.object_version_number%TYPE
 ) is
--
   l_proc           varchar2(72)  :=  g_package||'chk_dynamic_insert_allowed';
   l_exists         varchar2(1);
   l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'dynamic_insert_allowed'
    ,p_argument_value =>  p_dynamic_insert_allowed
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  l_api_updating := per_grs_shd.api_updating
         (p_cagr_grade_structure_id   => p_cagr_grade_structure_id
         ,p_object_version_number     => p_object_version_number
         ,p_effective_date	      => p_effective_date
         );
  --
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_grs_shd.g_old_rec.dynamic_insert_allowed, hr_api.g_varchar2)<>
       nvl(p_dynamic_insert_allowed, hr_api.g_varchar2))
    or (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 40);
    --
      --
      -- Check that the type exists in hr_lookups for the
      -- lookup type 'YES_NO' with an enabled flag set to 'Y'.
      --
      if hr_api.not_exists_in_fnd_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'YES_NO'
        ,p_lookup_code           => p_dynamic_insert_allowed
        )
      then
        --
        hr_utility.set_message(800, 'PER_52614_GRS_INV_DYNAMIC_INS');
        hr_utility.raise_error;
        --
      end if;
     --
     end if;
     --
    hr_utility.set_location(' Leaving:'|| l_proc, 60);
  --
end chk_dynamic_insert_allowed;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_cagr_grades_exists>------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Procedure checks whether the given cagr grade structures is referenced by
--    any cagr grades.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_cagr_grade_structure_id
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status:
--    Internal Development Use Only.
--
Procedure chk_cagr_grades_exists
 (p_cagr_grade_structure_id in per_cagr_grades.cagr_grade_structure_id%TYPE) is
   --
   cursor csr_cagr_grade is
    select '1' from per_cagr_grades
    where cagr_grade_structure_id = p_cagr_grade_structure_id;
   --
   l_proc           varchar2(72)  :=  g_package||'chk_cagr_grades_exists';
   l_exists         varchar2(1);
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Perform CAGR_GRADE_STRUCTURE_ID mandatory check
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'cagr_grade_structure_id'
    ,p_argument_value => p_cagr_grade_structure_id
   );
  --
  hr_utility.set_location(l_proc,10);
  --
  --  Check for valid CAGR_GRADE_STRUCTURE_ID
  --
  open csr_cagr_grade;
  fetch csr_cagr_grade
        into l_exists;
  if (csr_cagr_grade%found) then
    --
    close csr_cagr_grade;
    --
    hr_utility.set_message(800,'PER_52615_GRS_DEL_GRA');
    hr_utility.raise_error;
  end if;
  --
  close csr_cagr_grade;
  --
    hr_utility.set_location('Leaving:'|| l_proc, 20);
  --
end chk_cagr_grades_exists;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_effective_date in date,
			  p_rec in per_grs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_cagr_grade_structure_id
  (p_cagr_grade_structure_id    => p_rec.cagr_grade_structure_id,
   p_object_version_number 	=> p_rec.object_version_number,
   p_effective_date		=> p_effective_date);
  --
  chk_collective_agreement_id
  (p_collective_agreement_id	=> p_rec.collective_agreement_id);
  --
  chk_id_flex_num
  (p_id_flex_num 		=> p_rec.id_flex_num);
  --
  chk_comb_flex_cagr
  (p_collective_agreement_id	=> p_rec.collective_agreement_id,
   p_id_flex_num 		=> p_rec.id_flex_num);
  --
  chk_df
  (p_rec	=> p_rec);
  --
  chk_dynamic_insert_allowed
  (p_cagr_grade_structure_id  	=> p_rec.cagr_grade_structure_id
  ,p_dynamic_insert_allowed  	=> p_rec.dynamic_insert_allowed
  ,p_effective_date          	=> p_effective_date
  ,p_object_version_number   	=> p_rec.object_version_number
  );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate( p_effective_date in date,
			   p_rec in per_grs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_cagr_grade_structure_id
  (p_cagr_grade_structure_id          => p_rec.cagr_grade_structure_id,
   p_object_version_number 	      => p_rec.object_version_number,
   p_effective_date		      => p_effective_date);
  --
  chk_collective_agreement_id
  (p_collective_agreement_id	=> p_rec.collective_agreement_id);
  --
  chk_id_flex_num
  (p_id_flex_num 		=> p_rec.id_flex_num);
  --
  chk_df
  (p_rec	=> p_rec);
  --
  chk_dynamic_insert_allowed
  (p_cagr_grade_structure_id  	=> p_rec.cagr_grade_structure_id
  ,p_dynamic_insert_allowed  	=> p_rec.dynamic_insert_allowed
  ,p_effective_date          	=> p_effective_date
  ,p_object_version_number   	=> p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_effective_date in date,
			  p_rec in per_grs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_cagr_grades_exists
  (p_cagr_grade_structure_id => p_rec.cagr_grade_structure_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_grs_bus;

/
