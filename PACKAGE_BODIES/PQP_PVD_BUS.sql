--------------------------------------------------------
--  DDL for Package Body PQP_PVD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PVD_BUS" as
/* $Header: pqpvdrhi.pkb 115.6 2003/02/17 22:14:43 tmehra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqp_pvd_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_vehicle_details_id          number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_vehicle_details_id                   in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pqp_vehicle_details pvd
     where pvd.vehicle_details_id = p_vehicle_details_id
       and pbg.business_group_id = pvd.business_group_id;
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
    ,p_argument           => 'vehicle_details_id'
    ,p_argument_value     => p_vehicle_details_id
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
  (p_vehicle_details_id                   in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pqp_vehicle_details pvd
     where pvd.vehicle_details_id = p_vehicle_details_id
       and pbg.business_group_id (+) = pvd.business_group_id;
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
    ,p_argument           => 'vehicle_details_id'
    ,p_argument_value     => p_vehicle_details_id
    );
  --
  if ( nvl(pqp_pvd_bus.g_vehicle_details_id, hr_api.g_number)
       = p_vehicle_details_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqp_pvd_bus.g_legislation_code;
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
    pqp_pvd_bus.g_vehicle_details_id:= p_vehicle_details_id;
    pqp_pvd_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  (p_rec in pqp_pvd_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.vehicle_details_id is not null)  and (
    nvl(pqp_pvd_shd.g_old_rec.vhd_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information_category, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_information1, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information1, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_information2, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information2, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_information3, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information3, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_information4, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information4, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_information5, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information5, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_information6, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information6, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_information7, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information7, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_information8, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information8, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_information9, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information9, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_information10, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information10, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_information11, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information11, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_information12, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information12, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_information13, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information13, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_information14, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information14, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_information15, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information15, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_information16, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information16, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_information17, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information17, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_information18, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information18, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_information19, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information19, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_information20, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_information20, hr_api.g_varchar2) ))
    or (p_rec.vehicle_details_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PQP'
      ,p_descflex_name                   => 'Vehicle Details DDF'
      ,p_attribute_category              => p_rec.vhd_information_category
      ,p_attribute1_name                 => 'VHD_INFORMATION1'
      ,p_attribute1_value                => p_rec.vhd_information1
      ,p_attribute2_name                 => 'VHD_INFORMATION2'
      ,p_attribute2_value                => p_rec.vhd_information2
      ,p_attribute3_name                 => 'VHD_INFORMATION3'
      ,p_attribute3_value                => p_rec.vhd_information3
      ,p_attribute4_name                 => 'VHD_INFORMATION4'
      ,p_attribute4_value                => p_rec.vhd_information4
      ,p_attribute5_name                 => 'VHD_INFORMATION5'
      ,p_attribute5_value                => p_rec.vhd_information5
      ,p_attribute6_name                 => 'VHD_INFORMATION6'
      ,p_attribute6_value                => p_rec.vhd_information6
      ,p_attribute7_name                 => 'VHD_INFORMATION7'
      ,p_attribute7_value                => p_rec.vhd_information7
      ,p_attribute8_name                 => 'VHD_INFORMATION8'
      ,p_attribute8_value                => p_rec.vhd_information8
      ,p_attribute9_name                 => 'VHD_INFORMATION9'
      ,p_attribute9_value                => p_rec.vhd_information9
      ,p_attribute10_name                => 'VHD_INFORMATION10'
      ,p_attribute10_value               => p_rec.vhd_information10
      ,p_attribute11_name                => 'VHD_INFORMATION11'
      ,p_attribute11_value               => p_rec.vhd_information11
      ,p_attribute12_name                => 'VHD_INFORMATION12'
      ,p_attribute12_value               => p_rec.vhd_information12
      ,p_attribute13_name                => 'VHD_INFORMATION13'
      ,p_attribute13_value               => p_rec.vhd_information13
      ,p_attribute14_name                => 'VHD_INFORMATION14'
      ,p_attribute14_value               => p_rec.vhd_information14
      ,p_attribute15_name                => 'VHD_INFORMATION15'
      ,p_attribute15_value               => p_rec.vhd_information15
      ,p_attribute16_name                => 'VHD_INFORMATION16'
      ,p_attribute16_value               => p_rec.vhd_information16
      ,p_attribute17_name                => 'VHD_INFORMATION17'
      ,p_attribute17_value               => p_rec.vhd_information17
      ,p_attribute18_name                => 'VHD_INFORMATION18'
      ,p_attribute18_value               => p_rec.vhd_information18
      ,p_attribute19_name                => 'VHD_INFORMATION19'
      ,p_attribute19_value               => p_rec.vhd_information19
      ,p_attribute20_name                => 'VHD_INFORMATION20'
      ,p_attribute20_value               => p_rec.vhd_information20
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
  (p_rec in pqp_pvd_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.vehicle_details_id is not null)  and (
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute_category, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute1, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute2, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute3, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute4, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute5, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute6, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute7, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute8, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute9, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute10, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute11, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute12, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute13, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute14, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute15, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute16, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute17, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute18, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute19, hr_api.g_varchar2)  or
    nvl(pqp_pvd_shd.g_old_rec.vhd_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.vhd_attribute20, hr_api.g_varchar2) ))
    or (p_rec.vehicle_details_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PQP'
      ,p_descflex_name                   => 'Vehicle Details DF'
      ,p_attribute_category              => p_rec.vhd_attribute_category
      ,p_attribute1_name                 => 'VHD_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.vhd_attribute1
      ,p_attribute2_name                 => 'VHD_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.vhd_attribute2
      ,p_attribute3_name                 => 'VHD_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.vhd_attribute3
      ,p_attribute4_name                 => 'VHD_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.vhd_attribute4
      ,p_attribute5_name                 => 'VHD_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.vhd_attribute5
      ,p_attribute6_name                 => 'VHD_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.vhd_attribute6
      ,p_attribute7_name                 => 'VHD_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.vhd_attribute7
      ,p_attribute8_name                 => 'VHD_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.vhd_attribute8
      ,p_attribute9_name                 => 'VHD_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.vhd_attribute9
      ,p_attribute10_name                => 'VHD_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.vhd_attribute10
      ,p_attribute11_name                => 'VHD_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.vhd_attribute11
      ,p_attribute12_name                => 'VHD_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.vhd_attribute12
      ,p_attribute13_name                => 'VHD_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.vhd_attribute13
      ,p_attribute14_name                => 'VHD_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.vhd_attribute14
      ,p_attribute15_name                => 'VHD_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.vhd_attribute15
      ,p_attribute16_name                => 'VHD_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.vhd_attribute16
      ,p_attribute17_name                => 'VHD_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.vhd_attribute17
      ,p_attribute18_name                => 'VHD_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.vhd_attribute18
      ,p_attribute19_name                => 'VHD_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.vhd_attribute19
      ,p_attribute20_name                => 'VHD_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.vhd_attribute20
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
  ,p_rec in pqp_pvd_shd.g_rec_type
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
  IF NOT pqp_pvd_shd.api_updating
      (p_vehicle_details_id                   => p_rec.vehicle_details_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
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
-- ----------------------------------------------------------------------------
-- |---------------------------< check_fuel_type_code >-----------------------|
-- ----------------------------------------------------------------------------
Procedure check_fuel_type_code
(p_vehicle_details_id IN PQP_VEHICLE_DETAILS.Vehicle_Details_Id%TYPE,
 p_fuel_type_code     IN VARCHAR2,
 p_effective_date     IN DATE) is

 l_proc  varchar2(72) := g_package||' check_fuel_type_code';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

 IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PQP_FUEL_TYPE' ,
             p_lookup_code    => p_fuel_type_code ,
             p_effective_date => p_effective_date ) THEN

-- Raise error as the value does not exist as a lookup

        fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP'  );
        fnd_message.set_token('COLUMN','FUEL_TYPE' );
        fnd_message.set_token('LOOKUP_TYPE', 'PQP_FUEL_TYPE'  );
        fnd_message.raise_error;

END IF;


END check_fuel_type_code;

-- ----------------------------------------------------------------------------
-- |-------------------------< check_vehicle_ownership >----------------------|
-- ----------------------------------------------------------------------------
Procedure check_vehicle_ownership
(p_vehicle_ownership  IN PQP_VEHICLE_DETAILS.Vehicle_Ownership%TYPE
 ) is

 l_proc  varchar2(72) := g_package||' check_vehicle_ownership';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

IF p_vehicle_ownership NOT IN ('COMPANY','PRIVATE') THEN
-- Raise error as the allowed values are company,private and NULL
   fnd_message.set_name('PQP','PQP_230521_INVALID_VEH_OWNSHP');
   fnd_message.raise_error;
END IF;

END check_vehicle_ownership;

-- ----------------------------------------------------------------------------
-- |-------------------------< check_assignment_exists >----------------------|
-- ----------------------------------------------------------------------------
Procedure check_assignment_exists
(p_vehicle_details_id  IN PQP_VEHICLE_DETAILS.vehicle_details_id%TYPE
 ) is

 l_proc  varchar2(72) := g_package||' check_assignment_exists';
 CURSOR veh_cur IS
 SELECT 'x'
   FROM PQP_ASSIGNMENT_ATTRIBUTES_F
  WHERE primary_company_car   = p_vehicle_details_id
     OR secondary_company_car = p_vehicle_details_id
     OR private_car           = p_vehicle_details_id;
l_dummy VARCHAR2(1);

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);
OPEN veh_cur;
  FETCH veh_cur INTO l_dummy;
    IF veh_cur%FOUND THEN
   -- Raise error as there is an assignment for the vehicle
   -- that is being deleted
   CLOSE veh_cur;
   fnd_message.set_name('PQP','PQP_230522_ASSIGNMENT_EXISTS'  );
   fnd_message.raise_error;
   END IF;
 CLOSE veh_cur;

END check_assignment_exists;

-- ----------------------------------------------------------------------------
-- |-------------------------< check_currency_code >---------------------------|

-- ----------------------------------------------------------------------------
Procedure check_currency_code
(p_currency_code         IN PQP_VEHICLE_DETAILS.currency_code%TYPE,
 p_in_business_group_id  IN NUMBER
 ) IS

l_proc  varchar2(72) := g_package||' check_currency_code';
l_default_currency_code VARCHAR2(10);

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);
l_default_currency_code := hr_general.default_currency_code (p_business_group_id
 => p_in_business_group_id);

IF p_currency_code <> l_default_currency_code THEN
-- Raise error as the input currency code is not equal
-- to the default currency for the BG
   fnd_message.set_name('PQP','PQP_230520_CUR_CODE_MISMATCH'  );
   fnd_message.raise_error;
END IF;

END check_currency_code;

-- ----------------------------------------------------------------------------
-- |---------------------------< check_vehicle_type_code >--------------------|
-- ----------------------------------------------------------------------------
Procedure check_vehicle_type_code
(p_vehicle_details_id IN PQP_VEHICLE_DETAILS.Vehicle_Details_Id%TYPE,
 p_vehicle_type_code  IN VARCHAR2,
 p_effective_date     IN DATE) is

 l_proc  varchar2(72) := g_package||' check_vehicle_type_code';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

 IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PQP_VEHICLE_TYPE' ,
             p_lookup_code    => p_vehicle_type_code ,
             p_effective_date => p_effective_date ) THEN

-- Raise error as the value does not exist as a lookup

        fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP'  );
        fnd_message.set_token('COLUMN','VEHICLE_TYPE' );
        fnd_message.set_token('LOOKUP_TYPE', 'PQP_VEHICLE_TYPE'  );
        fnd_message.raise_error;

END IF;


END check_vehicle_type_code;
-- ----------------------------------------------------------------------------
-- |---------------------------< check_negative >-----------------------|
-- ----------------------------------------------------------------------------
Procedure check_negative
(p_number_to_check IN NUMBER) IS

 l_proc  varchar2(72) := g_package||' check_negative';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);
  IF p_number_to_check < 0 THEN
      fnd_message.set_name ('PAY','HR_7355_PPM_AMOUNT_NEGATIVE'  );
      fnd_message.set_token('ERROR','Value Cannot Be Negative');
      fnd_message.raise_error;
  END IF;

END check_negative;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pqp_pvd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- EDIT_HERE: The following call to hr_api.validate_bus_grp_id
  -- will only be valid when the business_group_id is not null.
  -- As this column is defined as optional on the table then
  -- different logic will be required to handle the null case.
  -- If this is a start-up data entity then:
  --    a) add code to stop null values being processed by this
  --       row handler
  -- If this is not a start-up data entity then either:
  --    b) ignore the security_group_id value held in
  --       client_info.  This includes performing lookup
  --       validation against the HR_STANDARD_LOOKUPS view.
  -- or c) (less likely) ensure the correct security_group_id
  --       value is set in client_info.
  -- Remove this comment when the edit has been completed.
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  -- Check for the validity of the fuel code
  pqp_pvd_bus.check_fuel_type_code(p_rec.vehicle_details_id,
                                   p_rec.fuel_type,
                                   p_effective_date  );
  -- Check for the validity of the vehicle type code
  pqp_pvd_bus.check_vehicle_type_code(p_rec.vehicle_details_id,
                                   p_rec.vehicle_type,
                                   p_effective_date  );

-- These are checks for values that cannot be negative
  pqp_pvd_bus.check_negative(p_rec.engine_capacity_in_cc);
  pqp_pvd_bus.check_negative(p_rec.list_price);
  pqp_pvd_bus.check_negative(p_rec.accessory_value_at_startdate);
  pqp_pvd_bus.check_negative(p_rec.accessory_value_added_later);
--pqp_pvd_bus.check_negative(p_rec.capital_contributions);
--pqp_pvd_bus.check_negative(p_rec.private_use_contributions);
  pqp_pvd_bus.check_negative(p_rec.market_value_classic_car);

-- Vehicle Ownership check
  IF p_rec.vehicle_ownership IS NOT NULL THEN
     pqp_pvd_bus.check_vehicle_ownership(p_rec.vehicle_ownership);
  END IF;
-- Check if the Input Currency matches the BG Currency
  pqp_pvd_bus.check_currency_code(p_rec.currency_code,p_rec.business_group_id);
  --
  pqp_pvd_bus.chk_ddf(p_rec);
  --
  pqp_pvd_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pqp_pvd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- EDIT_HERE: The following call to hr_api.validate_bus_grp_id
  -- will only be valid when the business_group_id is not null.
  -- As this column is defined as optional on the table then
  -- different logic will be required to handle the null case.
  -- If this is a start-up data entity then:
  --    a) add code to stop null values being processed by this
  --       row handler
  -- If this is not a start-up data entity then either:
  --    b) ignore the security_group_id value held in
  --       client_info.  This includes performing lookup
  --       validation against the HR_STANDARD_LOOKUPS view.
  -- or c) (less likely) ensure the correct security_group_id
  --       value is set in client_info.
  -- Remove this comment when the edit has been completed.
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  --Validate FUEL_TYPE
  pqp_pvd_bus.check_fuel_type_code(p_rec.vehicle_details_id,
                                   p_rec.fuel_type,
                                   p_effective_date);

  -- Check for the validity of the vehicle type code
  pqp_pvd_bus.check_vehicle_type_code(p_rec.vehicle_details_id,
                                   p_rec.vehicle_type,
                                   p_effective_date  );
  -- These are checks for values that cannot be negative
  pqp_pvd_bus.check_negative(p_rec.engine_capacity_in_cc);
  pqp_pvd_bus.check_negative(p_rec.list_price);
  pqp_pvd_bus.check_negative(p_rec.accessory_value_at_startdate);
  pqp_pvd_bus.check_negative(p_rec.accessory_value_added_later);
--pqp_pvd_bus.check_negative(p_rec.capital_contributions);
--pqp_pvd_bus.check_negative(p_rec.private_use_contributions);
  pqp_pvd_bus.check_negative(p_rec.market_value_classic_car);
-- Vehicle Ownership check
  IF p_rec.vehicle_ownership IS NOT NULL THEN
     pqp_pvd_bus.check_vehicle_ownership(p_rec.vehicle_ownership);
  END IF;
 -- Check if the Input currency matches the BG currency
  pqp_pvd_bus.check_currency_code(p_rec.currency_code,p_rec.business_group_id);
 --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --
  pqp_pvd_bus.chk_ddf(p_rec);
  --
  pqp_pvd_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqp_pvd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  pqp_pvd_bus.check_assignment_exists(p_rec.vehicle_details_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pqp_pvd_bus;

/
