--------------------------------------------------------
--  DDL for Package Body PER_CAG_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CAG_BUS" as
/* $Header: pecagrhi.pkb 120.1 2006/10/18 08:42:10 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_cag_bus.';  -- Global package name
--
-- The following two global variables are only to be used by the
-- return_legislation_code function.
--
g_collective_agreement_id number default null;
g_legislation_code varchar2(150) default null;
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
  (p_rec             in per_cag_shd.g_rec_type) IS
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
  IF NOT per_cag_shd.api_updating
      (p_collective_agreement_id         => p_rec.collective_agreement_id
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF nvl(p_rec.start_Date, hr_api.g_date) <>
     nvl(per_cag_shd.g_old_rec.start_date,hr_api.g_date) THEN
    --
    l_argument := 'start_date';
    RAISE l_error;
    --
  END IF;

   EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ---------------------------------------------------------------------------
-- |---------------------------< chk_date_validate >--------------------------|
-- ---------------------------------------------------------------------------
Procedure chk_date_validate
   (p_start_date          in date,
    p_end_date            in date
   ) is
--
  l_proc  varchar2(72) := g_package||'chk_date_validate';
  l_temp  varchar2(80) := '';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  if (p_start_date > p_end_date) then
     begin
        hr_utility.set_message(800,'PER_52833_FR_CAG_INV_START');
        hr_utility.raise_error;
      end;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_date_validate;

-- ---------------------------------------------------------------------------
-- |---------------------------<chk_status_validate >------------------------|
-- ---------------------------------------------------------------------------
Procedure chk_status_validate
   (p_status          in varchar2
   ) is

   cursor csr_status is select 1
   from hr_lookups
   where lookup_type = 'CAGR_STATUS'
   and   lookup_code = p_status ;

--
  l_proc  varchar2(72) := g_package||'chk_status_validate';
  l_temp  varchar2(80) := '';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

     begin
        open csr_status;
        fetch csr_status into l_temp;
        if csr_status%notfound then
           begin
              close csr_status;
              hr_utility.set_message(800,'PER_289273_CAG_INV_STATUS');
              hr_utility.raise_error;
           end;
       end if;
       close csr_status;
     end;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_status_validate;
--
-- ---------------------------------------------------------------------------
-- |---------------------------< chk_mandatory_date >------------------------|
-- ---------------------------------------------------------------------------
Procedure chk_mandatory_date
   (p_start_date          in date,
    p_end_date            in date
   ) is
--
  l_proc  varchar2(72) := g_package||'chk_mandatory_date';
  l_temp  varchar2(80) := '';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

  if ((to_char(p_end_date) is NOT NULL) and (to_char(p_start_date) is NULL)) then
     begin
        hr_utility.set_message(800,'PER_52834_FR_CAG_MAN_DATE');
        hr_utility.raise_error;
      end;
  end if;


  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_mandatory_date;
--
-- ---------------------------------------------------------------------------
-- |-------------< chk_employer_organization_id >----------------------------|
-- ---------------------------------------------------------------------------
Procedure chk_employer_organization_id
   (p_collective_agreement_id in number,
    p_employer_organization_id in number,
    p_business_group_id        in number
   )
   is
--
  cursor csr_employers is select '1'
     from hr_employers_v hev
     where hev.organization_id = p_employer_organization_id AND
           hev.business_group_id = p_business_group_id;

  l_proc  varchar2(72) := g_package||'chk_employer_organization_id';
  l_temp_organization_id  number;
  l_dummy  varchar2(1);
--
--
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

  /* The validation check for the EMPLOYER_ORGANIZATION_ID will be done (if the field is set) against the HR_FR_EMPLOYERS_V view */
  /* for each insert or in update only if the employer_organization_id value is different */

  if (p_collective_agreement_id is null and p_employer_organization_id IS NOT NULL) OR
     (p_collective_agreement_id is NOT null AND
      per_cag_shd.g_old_rec.employer_organization_id <> p_employer_organization_id) Then
     begin
        open csr_employers;
        fetch csr_employers into l_dummy;
        if csr_employers%notfound then
           begin
              close csr_employers;
              hr_utility.set_message(800,'PER_52846_CAG_INV_EMP_ORG');
              hr_utility.raise_error;
           end;
       end if;
       close csr_employers;
     end;
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_employer_organization_id;
--
--
-- ---------------------------------------------------------------------------
-- |---------------chk_bargaining_organization_id >----------------------------|
-- ---------------------------------------------------------------------------
Procedure chk_bargaining_organization_id
   (p_collective_agreement_id    in number,
    p_bargaining_organization_id in number,
    p_business_group_id          in number
   )
   is
--
  cursor csr_bargaining_units is select '1'
     from hr_bargaining_units_v hbu
     where hbu.organization_id = p_bargaining_organization_id AND
           hbu.business_group_id = p_business_group_id;

  l_proc  varchar2(72) := g_package||'chk_bargaining_organization_id';
  l_temp_organization_id  number;
  l_dummy  varchar2(1);
--
--
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

  /* The validation check for the BARGAINING_ORGANIZATION_ID will be done (if a value is given) against the HR_FR_BARGAINING_UNITS_V view */
  /* for each insert or in update only if the employer_organization_id value is different */
  if (p_collective_agreement_id is null and p_bargaining_organization_id IS NOT NULL) OR
     (p_collective_agreement_id is NOT null AND
      per_cag_shd.g_old_rec.bargaining_organization_id <> p_bargaining_organization_id) Then
     begin
        open csr_bargaining_units;
        fetch csr_bargaining_units into l_dummy;
        if csr_bargaining_units%notfound then
           begin
              close csr_bargaining_units;
              hr_utility.set_message(800,'PER_52847_CAG_INV_BARG_ORG');
              hr_utility.raise_error;
           end;
       end if;
       close csr_bargaining_units;
     end;
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_bargaining_organization_id;
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
  (p_rec in per_cag_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.collective_agreement_id is NULL) and (
    nvl(per_cag_shd.g_old_rec.attribute_category, hr_api.g_varchar2)<>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)))
    or (p_rec.collective_agreement_id is null) then
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_COLLECTIVE_AGREEMENTS'
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
-- -----------------------------------------------------------------------
-- |------------------------------< chk_ddf >----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Developer Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   second last step from insert_validate and update_validate.
--   Before any Descriptive Flexfield (chk_df) calls.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data
--   values are all valid this procedure will end normally and
--   processing will continue.
--
-- Post Failure:
--   If the DDF structure column value or any of the data values
--   are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_ddf
  (p_rec   in per_cag_shd.g_rec_type) is
--
  l_proc       varchar2(72) := g_package||'chk_ddf';
  l_error      exception;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check if the row is being inserted or updated and a
  -- value has changed
  --
  if (p_rec.collective_agreement_id is null)
    or ((p_rec.collective_agreement_id is not null)
    and
    nvl(per_cag_shd.g_old_rec.cag_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.cag_information_category, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.cag_information1, hr_api.g_varchar2) <>
    nvl(p_rec.cag_information1, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.cag_information2, hr_api.g_varchar2) <>
    nvl(p_rec.cag_information2, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.cag_information3, hr_api.g_varchar2) <>
    nvl(p_rec.cag_information3, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.cag_information4, hr_api.g_varchar2) <>
    nvl(p_rec.cag_information4, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.cag_information5, hr_api.g_varchar2) <>
    nvl(p_rec.cag_information5, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.cag_information6, hr_api.g_varchar2) <>
    nvl(p_rec.cag_information6, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.cag_information7, hr_api.g_varchar2)  <>
    nvl(p_rec.cag_information7, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.cag_information8, hr_api.g_varchar2) <>
    nvl(p_rec.cag_information8, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.cag_information9, hr_api.g_varchar2)  <>
    nvl(p_rec.cag_information9, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.cag_information10, hr_api.g_varchar2) <>
    nvl(p_rec.cag_information10, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.cag_information11, hr_api.g_varchar2) <>
    nvl(p_rec.cag_information11, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.cag_information12, hr_api.g_varchar2) <>
    nvl(p_rec.cag_information12, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.cag_information13, hr_api.g_varchar2) <>
    nvl(p_rec.cag_information13, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.cag_information14, hr_api.g_varchar2) <>
    nvl(p_rec.cag_information14, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.cag_information15, hr_api.g_varchar2) <>
    nvl(p_rec.cag_information15, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.cag_information16, hr_api.g_varchar2) <>
    nvl(p_rec.cag_information16, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.cag_information17, hr_api.g_varchar2) <>
    nvl(p_rec.cag_information17, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.cag_information18, hr_api.g_varchar2) <>
    nvl(p_rec.cag_information18, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.cag_information19, hr_api.g_varchar2) <>
    nvl(p_rec.cag_information19, hr_api.g_varchar2) or
    nvl(per_cag_shd.g_old_rec.cag_information20, hr_api.g_varchar2) <>
    nvl(p_rec.cag_information20, hr_api.g_varchar2))
  then
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'Coll Agr Developer DF'
      ,p_attribute_category => p_rec.cag_information_category
      ,p_attribute1_name    => 'CAG_INFORMATION1'
      ,p_attribute1_value   => p_rec.cag_information1
      ,p_attribute2_name    => 'CAG_INFORMATION2'
      ,p_attribute2_value   => p_rec.cag_information2
      ,p_attribute3_name    => 'CAG_INFORMATION3'
      ,p_attribute3_value   => p_rec.cag_information3
      ,p_attribute4_name    => 'CAG_INFORMATION4'
      ,p_attribute4_value   => p_rec.cag_information4
      ,p_attribute5_name    => 'CAG_INFORMATION5'
      ,p_attribute5_value   => p_rec.cag_information5
      ,p_attribute6_name    => 'CAG_INFORMATION6'
      ,p_attribute6_value   => p_rec.cag_information6
      ,p_attribute7_name    => 'CAG_INFORMATION7'
      ,p_attribute7_value   => p_rec.cag_information7
      ,p_attribute8_name    => 'CAG_INFORMATION8'
      ,p_attribute8_value   => p_rec.cag_information8
      ,p_attribute9_name    => 'CAG_INFORMATION9'
      ,p_attribute9_value   => p_rec.cag_information9
      ,p_attribute10_name   => 'CAG_INFORMATION10'
      ,p_attribute10_value  => p_rec.cag_information10
      ,p_attribute11_name   => 'CAG_INFORMATION11'
      ,p_attribute11_value  => p_rec.cag_information11
      ,p_attribute12_name   => 'CAG_INFORMATION12'
      ,p_attribute12_value  => p_rec.cag_information12
      ,p_attribute13_name   => 'CAG_INFORMATION13'
      ,p_attribute13_value  => p_rec.cag_information13
      ,p_attribute14_name   => 'CAG_INFORMATION14'
      ,p_attribute14_value  => p_rec.cag_information14
      ,p_attribute15_name   => 'CAG_INFORMATION15'
      ,p_attribute15_value  => p_rec.cag_information15
      ,p_attribute16_name   => 'CAG_INFORMATION16'
      ,p_attribute16_value  => p_rec.cag_information16
      ,p_attribute17_name   => 'CAG_INFORMATION17'
      ,p_attribute17_value  => p_rec.cag_information17
      ,p_attribute18_name   => 'CAG_INFORMATION18'
      ,p_attribute18_value  => p_rec.cag_information18
      ,p_attribute19_name   => 'CAG_INFORMATION19'
      ,p_attribute19_value  => p_rec.cag_information19
      ,p_attribute20_name   => 'CAG_INFORMATION20'
      ,p_attribute20_value  => p_rec.cag_information20
      );
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end chk_ddf;
--

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_cag_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --  Validate Business Group Id
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  --
  -- Call all supporting business operations
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_MANDATORY_DATE
  -- Check if dates have to be mandatory
  chk_mandatory_date (p_rec.start_date, p_rec.end_date);

  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_DATE_VALIDATE
  -- If dates are provided, check that start_date is lower than end_date
  chk_date_validate(p_rec.start_date, p_rec.end_date);

  --
  -- Business Rule Mapping
  -- =====================
  -- status_VALIDATE
  -- Check that status is valid from hr_lookups
  --
  chk_status_validate(p_rec.status);



  --
  -- Business Rule Mapping (test done against a LOV into the form)
  -- =====================
  -- CHK_EMPLOYER_ORGANIZATION_ID
  -- Check if the combination of employer_organization_id and business_id is valid against the HR_FR_EMPLOYERS_V view
  chk_employer_organization_id(p_rec.collective_agreement_id,
                               p_rec.employer_organization_id,
                               p_rec.business_group_id);

  --
  -- Business Rule Mapping (test done against a LOV into the form)
  -- =====================
  -- CHK_BARGAINING_ORGANIZATION_ID
  -- Check if the combination of bargaining_organization_id and business_id is valid against the HR_FR_BARGAINING_UNITS_V view
  chk_bargaining_organization_id(p_rec.collective_agreement_id,
                                 p_rec.bargaining_organization_id,
                                 p_rec.business_group_id);

  --
  -- DDF procedure to validation Developer Descriptive Flexfields
  -- =============================================================
  -- CHK_DDF
  --
  per_cag_bus.chk_ddf(p_rec => p_rec);

  --
  -- Descriptive flexfield check
  -- ===========================
  --CHK_DF
  --
  per_cag_bus.chk_df(p_rec => p_rec);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_cag_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_non_updateable_args
    (p_rec            => p_rec);
  --
  --
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_MANDATORY_DATE
  -- Check if dates have to be mandatory
  chk_mandatory_date (p_rec.start_date, p_rec.end_date);

  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_DATE_VALIDATE
  -- If dates are provided, check that start_date is lower than end_date
  chk_date_validate(p_rec.start_date, p_rec.end_date);

  --
  -- Business Rule Mapping
  -- =====================
  -- status_VALIDATE
  -- Check that status is valid from hr_lookups
 -- chk_status_validate(p_rec.status);


  --
  -- DDF procedure to validation Developer Descriptive Flexfields
  -- =============================================================
  -- CHK_DDF
  --
  per_cag_bus.chk_ddf(p_rec => p_rec);

  --
  -- Descriptive flexfield check
  -- ===========================
  --CHK_DF
  --
  per_cag_bus.chk_df(p_rec => p_rec);


  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_cag_shd.g_rec_type) is

cursor csr_assignment is select '1'
			from per_all_assignments_f paa
			where paa.collective_agreement_id = p_rec.collective_agreement_id;

cursor csr_establishment is select '1'
		           from hr_estab_coll_agrs_v hfe
		           where to_number(substr(hfe.collective_agreement_id,1,30)) = p_rec.collective_agreement_id;

cursor csr_grade is select '1'
		   from per_cagr_grade_structures pcg
		   where pcg.collective_agreement_id = p_rec.collective_agreement_id;

  CURSOR csr_entitlement IS
    SELECT 1
	  FROM per_cagr_entitlements pce
	 WHERE pce.collective_agreement_id = p_rec.collective_agreement_id;
  --
  l_dummy  varchar2(1);
  --
  l_proc  varchar2(72) := g_package||'delete_validate';
  --
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- If the collective agreements exits in per_all_assignments
  --
  open csr_assignment;
  fetch csr_assignment into l_dummy;
  if csr_assignment%found then
       begin
        close csr_assignment;
        hr_utility.set_message(800,'PER_52838_CAG_DEL_ASG');
        hr_utility.raise_error;
      end;
  end if;
  close csr_assignment;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- If the collective agreements exits in hr_fr_estab_coll_agrs_v
  --
  open csr_establishment;
  fetch csr_establishment into l_dummy;
  if csr_establishment%found then
       begin
        close csr_establishment;
        hr_utility.set_message(800,'PER_52839_CAG_DEL_EST');
        hr_utility.raise_error;
      end;
  end if;
  close csr_establishment;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- If the collective agreements exits in per_cagr_grade_structures
  --
  open csr_grade;
  fetch csr_grade into l_dummy;
  if csr_grade%found then
       begin
        close csr_grade;
        hr_utility.set_message(800,'PER_52840_CAG_DEL_GRADE');
        hr_utility.raise_error;
      end;
  end if;
  close csr_grade;
  --
  hr_utility.set_location(l_proc,30);
  --
  OPEN csr_entitlement;
  FETCH csr_entitlement INTO l_dummy;
  --
  IF csr_entitlement%FOUND THEN
    --
	CLOSE csr_entitlement;
	--
	hr_utility.set_message(800,'HR_289398_ENTITLEMENTS_EXIST');
    hr_utility.raise_error;
    --
  ELSE
    --
	CLOSE csr_entitlement;
	--
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
End delete_validate;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_collective_agreement_id              in number
  ) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups  pbg
         , per_collective_agreements      cag
     where cag.collective_agreement_id       = p_collective_agreement_id
       and pbg.business_group_id = cag.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'collective_agreement_id',
                             p_argument_value => p_collective_agreement_id);
  --
  if nvl(g_collective_agreement_id, hr_api.g_number) = p_collective_agreement_id then
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
    close csr_leg_code;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  --
  close csr_leg_code;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
    g_collective_agreement_id := p_collective_agreement_id;
    g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 25);
  --
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
end per_cag_bus;

/
