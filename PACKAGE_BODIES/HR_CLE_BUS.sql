--------------------------------------------------------
--  DDL for Package Body HR_CLE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CLE_BUS" as
/* $Header: hrclerhi.pkb 115.6 2002/12/03 09:27:16 hjonnala noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_cle_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_soc_ins_contr_lvls_id       number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_soc_ins_contr_lvls_id  in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , hr_de_soc_ins_contr_lvls_f cle
         , hr_organization_units hou
     where cle.soc_ins_contr_lvls_id = p_soc_ins_contr_lvls_id
       and pbg.business_group_id = hou.business_group_id
       and hou.organization_id   = cle.organization_id;
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
    ,p_argument           => 'soc_ins_contr_lvls_id'
    ,p_argument_value     => p_soc_ins_contr_lvls_id
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
  (p_soc_ins_contr_lvls_id                in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --

 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , hr_de_soc_ins_contr_lvls_f cle
         , hr_organization_units  hou
     where cle.soc_ins_contr_lvls_id = p_soc_ins_contr_lvls_id
       and cle.organization_id    = hou.organization_id
       and pbg.business_group_id  = hou.business_group_id;

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
    ,p_argument           => 'soc_ins_contr_lvls_id'
    ,p_argument_value     => p_soc_ins_contr_lvls_id
    );
  --
  if ( nvl(hr_cle_bus.g_soc_ins_contr_lvls_id, hr_api.g_number)
       = p_soc_ins_contr_lvls_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hr_cle_bus.g_legislation_code;
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
    hr_cle_bus.g_soc_ins_contr_lvls_id       := p_soc_ins_contr_lvls_id;
    hr_cle_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in hr_cle_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.soc_ins_contr_lvls_id is not null)  and (
    nvl(hr_cle_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(hr_cle_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.soc_ins_contr_lvls_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'HR_DE_SOC_INS_CLE'
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
  (p_effective_date  in date
  ,p_rec             in hr_cle_shd.g_rec_type
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
  IF NOT hr_cle_shd.api_updating
      (p_soc_ins_contr_lvls_id            => p_rec.soc_ins_contr_lvls_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;

    IF nvl(p_rec.organization_id, hr_api.g_number) <>
     nvl(hr_cle_shd.g_old_rec.organization_id,hr_api.g_number) THEN
    --
    l_argument := 'organization_id';
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
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_organization_id >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that organization_id is a foriegn key
--   to hr_organization_units and it is unique for given start and end date
--   Organization Classifictaion for given organization shold be Mandatory
--   Health Provider
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_effective_date
--  p_validation_start_date
--  p_validation_end_date
--  p_organization_id
--  p_soc_ins_contr_lvls_id
--
-- Post Success:
--   Processing continues if organization id is valid
--
-- Post Failure:
--   An application error is raised if organization_id is not set properly
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_organization_id
  (p_effective_date  in date
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ,p_organization_id   in hr_de_soc_ins_contr_lvls_f.organization_id%type
  ,p_soc_ins_contr_lvls_id in  hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type

  ) IS

CURSOR csr_chk_organization_id1 IS
SELECT 'Y'
FROM   hr_organization_units hou
WHERE  hou.organization_id = p_organization_id
and    p_validation_start_date between hou.date_from and nvl(hou.date_to,p_validation_end_date);

CURSOR csr_chk_organization_id2 IS
SELECT 'Y'
FROM   hr_organization_units hou
WHERE  hou.organization_id = p_organization_id
and    p_validation_end_date between hou.date_from and nvl(hou.date_to,p_validation_end_date);

CURSOR csr_chk_organization_id3 IS
SELECT 'Y'
FROM   hr_DE_SOC_INS_CONTR_LVLS_F hsi
WHERE  hsi.organization_id = p_organization_id
and    p_validation_end_date between hsi.effective_start_date and nvl(hsi.effective_end_date,p_validation_end_date);

CURSOR csr_chk_organization_id4 IS
SELECT 'Y'
FROM   hr_DE_SOC_INS_CONTR_LVLS_F hsi
WHERE  hsi.organization_id = p_organization_id
and    p_validation_start_date between hsi.effective_start_date and nvl(hsi.effective_end_date,p_validation_end_date);

CURSOR csr_chk_org_class IS
SELECT 'Y'
FROM   hr_organization_information hoi
WHERE  hoi.organization_id = p_organization_id
and    hoi.org_information_context = 'CLASS'
and    hoi.org_information1 IN ('DE_MAN_HEALTH_PROV', 'DE_ADD_SEC_PEN_PROV');


--
  l_proc     varchar2(72) := g_package || 'chk_organization_id';
  l_error    EXCEPTION;
  l_argument varchar2(30);
  l_var      varchar2(1);
--
Begin

   hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Only proceed with the validation if inserting
  --
          hr_utility.trace('effective_date' ||p_effective_date);
          hr_utility.trace('effective_start_date' ||p_validation_start_date);
          hr_utility.trace('effective_end_date' ||p_validation_end_date);
          hr_utility.trace('organization' ||p_organization_id);
   if p_soc_ins_contr_lvls_id is null  then

     hr_utility.set_location('Entering:'||l_proc, 20);
     --
     -- Only proceed with the validation if inserting
     --

     if p_organization_id is null then

	hr_utility.set_message(800,'HR_DE_INVALID_ORGANIZATION');
        hr_utility.raise_error;
    end if;

    OPEN  csr_chk_organization_id1;
    FETCH csr_chk_organization_id1 INTO l_var;

    IF csr_chk_organization_id1%NOTFOUND THEN
        hr_utility.set_location(l_proc,30);
        CLOSE csr_chk_organization_id1;
        hr_utility.set_message(800, 'HR_DE_INVALID_ORGANIZATION');
        hr_utility.raise_error;
    END IF;

    CLOSE csr_chk_organization_id1;
    hr_utility.set_location(l_proc,40);

    OPEN  csr_chk_organization_id2;
    FETCH csr_chk_organization_id2 INTO l_var;

    IF csr_chk_organization_id2%NOTFOUND THEN
        hr_utility.set_location(l_proc,50);
        CLOSE csr_chk_organization_id2;
        hr_utility.set_message(800, 'HR_DE_INVALID_ORGANIZATION');
        hr_utility.raise_error;
    END IF;

        hr_utility.set_location(l_proc,60);
	CLOSE csr_chk_organization_id2;

    OPEN  csr_chk_organization_id3;
    FETCH csr_chk_organization_id3 INTO l_var;

    IF csr_chk_organization_id3%FOUND THEN
        hr_utility.set_location(l_proc,70);
        CLOSE csr_chk_organization_id3;
        hr_utility.set_message(800, 'HR_DE_INVALID_ORGANIZATION');
        hr_utility.raise_error;
    END IF;

    CLOSE csr_chk_organization_id3;
    hr_utility.set_location(l_proc,80);

    OPEN  csr_chk_organization_id4;
    FETCH csr_chk_organization_id4 INTO l_var;

    IF csr_chk_organization_id4%FOUND THEN
        hr_utility.set_location(l_proc,90);
        CLOSE csr_chk_organization_id4;
        hr_utility.set_message(800, 'HR_DE_INVALID_ORGANIZATION');
        hr_utility.raise_error;
    END IF;

    CLOSE csr_chk_organization_id4;
    hr_utility.set_location(l_proc,100);

    OPEN  csr_chk_org_class;
    FETCH csr_chk_org_class INTO l_var;

    IF csr_chk_org_class%NOTFOUND THEN
        hr_utility.set_location(l_proc,110);
        CLOSE csr_chk_org_class;
        hr_utility.set_message(800, 'HR_DE_INVALID_ORGANIZATION');
        hr_utility.raise_error;
    END IF;

    CLOSE csr_chk_org_class;
    hr_utility.set_location(l_proc,200);


end if;

End chk_organization_id;


--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_normal_amount>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate normal_amount value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_normal_amount
--    p_soc_ins_contr_lvls_id
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
--
PROCEDURE chk_normal_amount
  ( p_normal_amount            IN hr_de_soc_ins_contr_lvls_f.normal_amount%type
   ,p_soc_ins_contr_lvls_id    IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_normal_amount';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for normal amount has changed
  --

IF  P_NORMAL_AMOUNT IS NOT NULL THEN
  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.normal_amount <> p_normal_amount))) THEN
      --
      hr_utility.set_location(l_proc, 20);

      IF ( P_NORMAL_AMOUNT < 0 ) then
      --
      hr_utility.set_location(l_proc, 30);
      hr_utility.set_message(800, 'HR_DE_INVALID_NORMAL_AMOUNT');
      hr_utility.raise_error;
      --
      END IF;
    --
  END IF;
  --
END IF;
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_normal_amount;
--

--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_increased_amount>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate normal_amount value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_increased_amount
--    p_soc_ins_contr_lvls_id
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
--
PROCEDURE chk_increased_amount
  ( p_increased_amount            IN hr_de_soc_ins_contr_lvls_f.increased_amount%type
   ,p_soc_ins_contr_lvls_id    IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_increased_amount';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for increased amount has changed
  --
IF  P_INCREASED_AMOUNT IS NOT NULL THEN
  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.increased_amount <> p_increased_amount))) THEN
      --
      hr_utility.set_location(l_proc, 20);

      IF (P_INCREASED_AMOUNT < 0) then
      --
      hr_utility.set_location(l_proc, 30);
      hr_utility.set_message(800, 'HR_DE_INVALID_INCREASED_AMOUNT');
      hr_utility.raise_error;
      --
      END IF;
    --
  END IF;
END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_increased_amount;
--

--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_reduced_amount>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate normal_amount value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_reduced_amount
--    p_soc_ins_contr_lvls_id
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
--
PROCEDURE chk_reduced_amount
  ( p_reduced_amount            IN hr_de_soc_ins_contr_lvls_f.reduced_amount%type
   ,p_soc_ins_contr_lvls_id    IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_reduced_amount';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for reduced amount has changed
  --
IF  P_REDUCED_AMOUNT IS NOT NULL THEN
  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.reduced_amount <> p_reduced_amount))) THEN
      --
      hr_utility.set_location(l_proc, 20);

      IF (P_REDUCED_AMOUNT < 0) then
      --
      hr_utility.set_location(l_proc, 30);
      hr_utility.set_message(800, 'HR_DE_INVALID_REDUCED_AMOUNT');
      hr_utility.raise_error;
      --
      END IF;
    --
  END IF;
END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_reduced_amount;
--

--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_normal_percentage>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate normal_percentage value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_normal_percentage
--    p_soc_ins_contr_lvls_id
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
--
PROCEDURE chk_normal_percentage
  ( p_normal_percentage            IN hr_de_soc_ins_contr_lvls_f.normal_percentage%type
   ,p_soc_ins_contr_lvls_id    IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_normal_percentage';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for normal percentage has changed
  --

  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.normal_percentage <> p_normal_percentage))) THEN
      --
      hr_utility.set_location(l_proc, 20);

      IF ( P_NORMAL_PERCENTAGE < 0 OR P_NORMAL_PERCENTAGE > 100) then
      --
      hr_utility.set_location(l_proc, 30);
      hr_utility.set_message(800, 'HR_DE_INVALID_NORM_AMT_PERC');
      hr_utility.raise_error;
      --
      END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_normal_percentage;
--

--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_increased_percentage>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate normal_percentage value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_increased_percentage
--    p_soc_ins_contr_lvls_id
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
--
PROCEDURE chk_increased_percentage
  ( p_increased_percentage            IN hr_de_soc_ins_contr_lvls_f.increased_percentage%type
   ,p_soc_ins_contr_lvls_id    IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_increased_percentage';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for increased percentage has changed
  --
  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.normal_percentage <> p_increased_percentage))) THEN
      --
      hr_utility.set_location(l_proc, 20);

      IF ( P_INCREASED_PERCENTAGE < 0 OR P_INCREASED_PERCENTAGE > 100) then
      --
      hr_utility.set_location(l_proc, 30);
      hr_utility.set_message(800, 'HR_DE_INVALID_INC_AMT_PERC');
      hr_utility.raise_error;
      --
      END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_increased_percentage;
--

--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_reduced_percentage>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate normal_percentage value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_reduced_percentage
--    p_soc_ins_contr_lvls_id
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
--
PROCEDURE chk_reduced_percentage
  ( p_reduced_percentage            IN hr_de_soc_ins_contr_lvls_f.reduced_percentage%type
   ,p_soc_ins_contr_lvls_id    IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_reduced_percentage';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for reduced percentage has changed
  --
  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.normal_percentage <> p_reduced_percentage))) THEN
      --
      hr_utility.set_location(l_proc, 20);

      IF ( P_REDUCED_PERCENTAGE < 0 OR P_REDUCED_PERCENTAGE > 100) then
      --
      hr_utility.set_location(l_proc, 30);
      hr_utility.set_message(800, 'HR_DE_INVALID_REDC_AMT_PERC');
      hr_utility.raise_error;
      --
      END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_reduced_percentage;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_normal_percent_null>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate normal_percentage value to be not null on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_normal_percentage
--    p_soc_ins_contr_lvls_id
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
--
PROCEDURE chk_normal_percent_null
  ( p_normal_percentage        IN hr_de_soc_ins_contr_lvls_f.normal_percentage%type
   ,p_soc_ins_contr_lvls_id    IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_normal_percent_null';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for normal percentage has changed
  --

  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.normal_percentage <> p_normal_percentage))) THEN
      --
      hr_utility.set_location(l_proc, 20);

      IF ( P_NORMAL_PERCENTAGE IS NULL) then
      --
      hr_utility.set_location(l_proc, 30);
       fnd_message.set_name('PER', 'HR_DE_COLUMN_NULL');
       fnd_message.set_token('COL_NAME','normal_percentage');
       fnd_message.raise_error;

      --
      END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_normal_percent_null;
--

--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_increased_percent_null>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate increased_percentage value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_increased_percentage
--    p_soc_ins_contr_lvls_id
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
--
PROCEDURE chk_increased_percent_null
  ( p_increased_percentage     IN hr_de_soc_ins_contr_lvls_f.increased_percentage%type
   ,p_soc_ins_contr_lvls_id    IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_increased_percent_null';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for increased percentage has changed
  --
  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.increased_percentage <> p_increased_percentage))) THEN
      --
      hr_utility.set_location(l_proc, 20);

      IF ( P_INCREASED_PERCENTAGE IS NULL) then
      --
      hr_utility.set_location(l_proc, 30);
       FND_MESSAGE.set_name('PER', 'HR_DE_COLUMN_NULL');
       fnd_message.set_token('COL_NAME','increased_percentage');
       fnd_message.raise_error;
      --
      END IF;

  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_increased_percent_null;
--

--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_reduced_percent_null>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate reduced_percentage value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_reduced_percentage
--    p_soc_ins_contr_lvls_id
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
--
PROCEDURE chk_reduced_percent_null
  ( p_reduced_percentage       IN hr_de_soc_ins_contr_lvls_f.reduced_percentage%type
   ,p_soc_ins_contr_lvls_id    IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_reduced_percent_null';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for reduced percentage has changed
  --
  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.reduced_percentage <> p_reduced_percentage))) THEN
      --
      hr_utility.set_location(l_proc, 20);

      IF ( P_REDUCED_PERCENTAGE IS NULL ) then
      --
      hr_utility.set_location(l_proc, 30);
       FND_MESSAGE.set_name('PER', 'HR_DE_COLUMN_NULL');
       fnd_message.set_token('COL_NAME','reduced_percentage');
       fnd_message.raise_error;
      --
      END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_reduced_percent_null;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_max_inc_contr_null>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate max_increased_contribution value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_max_increased_contribution
--    p_soc_ins_contr_lvls_id
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
--
PROCEDURE chk_max_inc_contr_null
  ( p_max_increased_contribution IN hr_de_soc_ins_contr_lvls_f.max_increased_contribution%type
   ,p_soc_ins_contr_lvls_id      IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_max_inc_contr_null';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for max_increased_contribution has changed
  --
  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.max_increased_contribution <> p_max_increased_contribution))) THEN
      --
      hr_utility.set_location(l_proc, 20);

      IF ( p_max_increased_contribution  IS NULL ) then
      --
      hr_utility.set_location(l_proc, 30);
       fnd_message.set_name('PER', 'HR_DE_COLUMN_NULL');
       fnd_message.set_token('COL_NAME','max_increased_contribution');
       fnd_message.raise_error;
      --
      END IF;
    --
      IF ( p_max_increased_contribution < 0 ) then
      --
      hr_utility.set_location(l_proc, 30);
       fnd_message.set_name('PER', 'HR_DE_COL_NEGATIVE');
       fnd_message.set_token('COL_NAME','max_increased_contribution');
       fnd_message.raise_error;
      --
      END IF;
    --

  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_max_inc_contr_null;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_min_inc_contr_null>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate min_increased_contribution value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_max_increased_contribution
--    p_soc_ins_contr_lvls_id
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
--
PROCEDURE chk_min_inc_contr_null
  ( p_min_increased_contribution           IN hr_de_soc_ins_contr_lvls_f.min_increased_contribution%type
   ,p_soc_ins_contr_lvls_id    IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_min_inc_contr_null';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for min_increased_contribution has changed
  --
  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.min_increased_contribution <> p_min_increased_contribution))) THEN
      --
      hr_utility.set_location(l_proc, 20);

      IF ( p_min_increased_contribution  IS NULL ) then
      --
      hr_utility.set_location(l_proc, 30);
       FND_MESSAGE.set_name('PER', 'HR_DE_COLUMN_NULL');
       fnd_message.set_token('COL_NAME','min_increased_contribution');
       fnd_message.raise_error;
      --
      END IF;
      --
      IF ( p_min_increased_contribution  < 0 ) then
      --
      hr_utility.set_location(l_proc, 30);
       FND_MESSAGE.set_name('PER', 'HR_DE_COL_NEGATIVE');
       fnd_message.set_token('COL_NAME','min_increased_contribution');
       fnd_message.raise_error;

      END IF;
    --
  END IF;
  --

  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_min_inc_contr_null;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_month1_min_contr_null>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate month1_min_contribution value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_month1_min_contribution
--    p_soc_ins_contr_lvls_id
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
--
PROCEDURE chk_month1_min_contr_null
  ( p_month1_min_contribution           IN hr_de_soc_ins_contr_lvls_f.month1_min_contribution%type
   ,p_soc_ins_contr_lvls_id             IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_month1_min_contr_null';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for month1_min_contribution has changed
  --
  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.month1_min_contribution <> p_month1_min_contribution))) THEN
      --
      hr_utility.set_location(l_proc, 20);

      IF ( p_month1_min_contribution  IS NULL ) then
      --
      hr_utility.set_location(l_proc, 30);
       FND_MESSAGE.set_name('PER', 'HR_DE_COLUMN_NULL');
       fnd_message.set_token('COL_NAME','month1_min_contribution');
       fnd_message.raise_error;
      --
      END IF;
      --
      IF ( p_month1_min_contribution  < 0 ) then
      --
      hr_utility.set_location(l_proc, 30);
       FND_MESSAGE.set_name('PER', 'HR_DE_COL_NEGATIVE');
       fnd_message.set_token('COL_NAME','month1_min_contribution');
       fnd_message.raise_error;

      END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_month1_min_contr_null;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_month1_max_contr_null>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate month1_max_contribution value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_month1_max_contribution
--    p_soc_ins_contr_lvls_id
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    termaxated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_month1_max_contr_null
  ( p_month1_max_contribution           IN hr_de_soc_ins_contr_lvls_f.month1_max_contribution%type
   ,p_soc_ins_contr_lvls_id             IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_month1_max_contr_null';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for month1_max_contribution has changed
  --
  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.month1_max_contribution <> p_month1_max_contribution))) THEN
      --
      hr_utility.set_location(l_proc, 20);

      IF ( p_month1_max_contribution  IS NULL ) then
      --
      hr_utility.set_location(l_proc, 30);
       FND_MESSAGE.set_name('PER', 'HR_DE_COLUMN_NULL');
       fnd_message.set_token('COL_NAME','month1_max_contribution');
       fnd_message.raise_error;
      --
      END IF;
      --
      IF ( p_month1_max_contribution  < 0 ) then
      --
      hr_utility.set_location(l_proc, 30);
       FND_MESSAGE.set_name('PER', 'HR_DE_COL_NEGATIVE');
       fnd_message.set_token('COL_NAME','month1_max_contribution');
       fnd_message.raise_error;

      END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_month1_max_contr_null;
--
--
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_month2_min_contr_null>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate month2_min_contribution value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_month2_min_contribution
--    p_soc_ins_contr_lvls_id
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
--
PROCEDURE chk_month2_min_contr_null
  ( p_month2_min_contribution       IN hr_de_soc_ins_contr_lvls_f.month2_min_contribution%type
   ,p_soc_ins_contr_lvls_id         IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_month2_min_contr_null';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for month2_min_contribution has changed
  --
  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.month2_min_contribution <> p_month2_min_contribution))) THEN
      --
      hr_utility.set_location(l_proc, 20);

      IF ( p_month2_min_contribution  IS NULL ) then
      --
      hr_utility.set_location(l_proc, 30);
       FND_MESSAGE.set_name('PER', 'HR_DE_COLUMN_NULL');
       fnd_message.set_token('COL_NAME','month2_min_contribution');
       fnd_message.raise_error;
      --
      END IF;
      --
      IF ( p_month2_min_contribution  < 0 ) then
      --
      hr_utility.set_location(l_proc, 30);
       FND_MESSAGE.set_name('PER', 'HR_DE_COL_NEGATIVE');
       fnd_message.set_token('COL_NAME','month2_min_contribution');
       fnd_message.raise_error;

      END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_month2_min_contr_null;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_month2_max_contr_null>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate month2_max_contribution value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_month2_max_contribution
--    p_soc_ins_contr_lvls_id
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    termaxated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_month2_max_contr_null
  ( p_month2_max_contribution           IN hr_de_soc_ins_contr_lvls_f.month2_max_contribution%type
   ,p_soc_ins_contr_lvls_id             IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_month2_max_contr_null';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for month2_max_contribution has changed
  --
  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.month2_max_contribution <> p_month2_max_contribution))) THEN
      --
      hr_utility.set_location(l_proc, 20);

      IF ( p_month2_max_contribution  IS NULL ) then
      --
      hr_utility.set_location(l_proc, 30);
       FND_MESSAGE.set_name('PER', 'HR_DE_COLUMN_NULL');
       fnd_message.set_token('COL_NAME','month2_max_contribution');
       fnd_message.raise_error;
      --
      END IF;
      --
      IF ( p_month2_max_contribution  < 0 ) then
      --
      hr_utility.set_location(l_proc, 30);
       FND_MESSAGE.set_name('PER', 'HR_DE_COL_NEGATIVE');
       fnd_message.set_token('COL_NAME','month2_max_contribution');
       fnd_message.raise_error;

      END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_month2_max_contr_null;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_employee_contribution>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate employee_contribution value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_employee_contribution
--    p_soc_ins_contr_lvls_id
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
--
PROCEDURE chk_employee_contribution
  ( p_employee_contribution    IN hr_de_soc_ins_contr_lvls_f.employee_contribution%type
   ,p_soc_ins_contr_lvls_id    IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_employee_contribution';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for employee contribution has changed
  --

  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.employee_contribution <> p_employee_contribution))) THEN
      --
      hr_utility.set_location(l_proc, 20);

      IF ( P_EMPLOYEE_CONTRIBUTION < 0 OR P_EMPLOYEE_CONTRIBUTION > 100) then
      --
      hr_utility.set_location(l_proc, 30);
      hr_utility.set_message(800, 'HR_DE_INVALID_EMPLOYEE_CONTR');
      hr_utility.raise_error;
      --
      END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_employee_contribution;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_month1>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate month1 value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_month1
--    p_soc_ins_contr_lvls_id
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
--
PROCEDURE chk_month1
  ( p_month1                   IN hr_de_soc_ins_contr_lvls_f.month1%type
   ,p_soc_ins_contr_lvls_id    IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  CURSOR c1_month(p_month  IN hr_de_soc_ins_contr_lvls_f.month1%type) IS
  Select 1 From(
  select lookup_code code
  from hr_lookups
  where lookup_type LIKE 'MONTH_CODE')
  WHERE p_month IN (code);
  --
  l_proc     VARCHAR2(72) := g_package || 'chk_month1';
  l_dummy    VARCHAR2(1);

  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for month1 or month2 has changed
  --

  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.month1 <> p_month1))) THEN
      --
      hr_utility.set_location(l_proc, 20);
      --
    IF (p_month1 IS NOT NULL) THEN
    --
      hr_utility.set_location(l_proc, 20);
      --
      OPEN c1_month(p_month1);
      FETCH c1_month INTO l_dummy;
      IF  c1_month%NOTFOUND THEN
      --
      hr_utility.set_location(l_proc, 30);
      hr_utility.set_message(800, 'HR_DE_INVALID_MONTH_CODE');
      hr_utility.raise_error;
      --
      END IF;
      --
      END IF;

         --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_month1;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_month2>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate month2 value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_month2
--    p_soc_ins_contr_lvls_id
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
--
PROCEDURE chk_month2
  ( p_month2    IN hr_de_soc_ins_contr_lvls_f.month2%type
   ,p_soc_ins_contr_lvls_id    IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  CURSOR c1_month(p_month  IN hr_de_soc_ins_contr_lvls_f.month2%type) IS
  Select 1 From(
  select lookup_code code
  from hr_lookups
  where lookup_type LIKE 'MONTH_CODE')
  WHERE p_month IN (code);
  --
  l_proc     VARCHAR2(72) := g_package || 'chk_month2';
  l_dummy    VARCHAR2(1);

  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for month2 or month2 has changed
  --

  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.month2 <> p_month2))) THEN
      --
      hr_utility.set_location(l_proc, 20);
    IF (p_month2 IS NOT NULL) THEN
    --
     hr_utility.set_location(l_proc, 20);
      OPEN c1_month(p_month2);
      FETCH c1_month INTO l_dummy;
      IF  c1_month%NOTFOUND THEN
      --
      hr_utility.set_location(l_proc, 30);
      hr_utility.set_message(800, 'HR_DE_INVALID_MONTH_CODE');
      hr_utility.raise_error;
      --
      END IF;
      --
      END IF;
         --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_month2;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_flat_tax_month_val>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate flat_tax_limit_per_month value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_flat_tax_limit_per_month
--    p_soc_ins_contr_lvls_id
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    termaxated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_flat_tax_month_val
  ( p_flat_tax_limit_per_month  IN hr_de_soc_ins_contr_lvls_f.flat_tax_limit_per_month%type
   ,p_soc_ins_contr_lvls_id    IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_flat_tax_month_val';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for flat_tax_limit_per_month has changed
  --
  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.flat_tax_limit_per_month <> p_flat_tax_limit_per_month))) THEN
      --
      hr_utility.set_location(l_proc, 20);

      --
      IF ( p_flat_tax_limit_per_month  < 0 ) then
      --
      hr_utility.set_location(l_proc, 30);
       FND_MESSAGE.set_name('PER', 'HR_DE_COL_NEGATIVE');
       fnd_message.set_token('COL_NAME','flat_tax_limit_per_month');
       fnd_message.raise_error;

      END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_flat_tax_month_val;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_flat_tax_year_val>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate flat_tax_limit_per_year value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_flat_tax_limit_per_year
--    p_soc_ins_contr_lvls_id
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    termaxated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_flat_tax_year_val
  ( p_flat_tax_limit_per_year  IN hr_de_soc_ins_contr_lvls_f.flat_tax_limit_per_year%type
   ,p_soc_ins_contr_lvls_id    IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_flat_tax_year_val';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for flat_tax_limit_per_year has changed
  --
  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.flat_tax_limit_per_year <> p_flat_tax_limit_per_year))) THEN
      --
      hr_utility.set_location(l_proc, 20);

      --
      IF ( p_flat_tax_limit_per_year  < 0 ) then
      --
      hr_utility.set_location(l_proc, 30);
       FND_MESSAGE.set_name('PER', 'HR_DE_COL_NEGATIVE');
       fnd_message.set_token('COL_NAME','flat_tax_limit_per_year');
       fnd_message.raise_error;

      END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_flat_tax_year_val;
--
--
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_min_max_inc_contr>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate min and max increased validation value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_min_increased_contribution
--    p_max_increased_contribution
--    p_soc_ins_contr_lvls_id
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    termaxated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_min_max_inc_contr
  ( p_min_increased_contribution  IN hr_de_soc_ins_contr_lvls_f.min_increased_contribution%type
   ,p_max_increased_contribution  IN hr_de_soc_ins_contr_lvls_f.max_increased_contribution%type
   ,p_soc_ins_contr_lvls_id    IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_min_max_inc_contr';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for min_increased_contribution or min_increased_contribution has changed
  --
  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.min_increased_contribution <> p_min_increased_contribution)) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.max_increased_contribution <> p_max_increased_contribution))) THEN

      --
      hr_utility.set_location(l_proc, 20);

      --
      IF ( p_min_increased_contribution > p_max_increased_contribution ) then
      --
      hr_utility.set_location(l_proc, 30);
      hr_utility.set_message(800, 'HR_DE_MAX_MIN_INC_CONTR');
      hr_utility.raise_error;

      END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_min_max_inc_contr;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_mon1_min_max_contr>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate min and max increased contribution value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_month1_min_contribution
--    p_month1_max_contribution
--    p_min_increased_contribution
--   p_max_increased_contribution
--    p_soc_ins_contr_lvls_id
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    termaxated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_mon1_min_max_contr
  ( p_month1_min_contribution  IN hr_de_soc_ins_contr_lvls_f.month1_min_contribution%type
   ,p_month1_max_contribution  IN hr_de_soc_ins_contr_lvls_f.month1_max_contribution%type
   ,p_min_increased_contribution  IN hr_de_soc_ins_contr_lvls_f.min_increased_contribution%type
   ,p_max_increased_contribution  IN hr_de_soc_ins_contr_lvls_f.max_increased_contribution%type
   ,p_soc_ins_contr_lvls_id    IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_mon1_min_max_contr';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for month1_min_contribution or month1_min_contribution has changed
  --
  IF ((p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.month1_min_contribution <> p_month1_min_contribution)) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.month1_max_contribution <> p_month1_max_contribution)) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.min_increased_contribution <> p_min_increased_contribution)) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.max_increased_contribution <> p_max_increased_contribution))) THEN

      --
      hr_utility.set_location(l_proc, 20);

      --
      IF ( p_month1_min_contribution > p_month1_max_contribution ) then
      --
      hr_utility.set_location(l_proc, 30);
      hr_utility.set_message(800, 'HR_DE_MAX_MIN_INC_CONTR');
      hr_utility.raise_error;

      END IF;
      --
      --Commented out this code to fix bug 2359120
      /*IF ((p_month1_min_contribution < p_min_increased_contribution) OR
          (p_month1_max_contribution > p_max_increased_contribution)) THEN
      --
      hr_utility.set_location(l_proc, 30);
      hr_utility.set_message(800, 'HR_DE_MON_MAX_MIN_CONTR');
      hr_utility.raise_error;

      END IF;*/

    --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_mon1_min_max_contr;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_mon2_min_max_contr>--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate min and max increased contribution value on insert and update
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_month2_min_contribution
--    p_month2_max_contribution
--    p_min_increased_contribution
--   p_max_increased_contribution
--    p_soc_ins_contr_lvls_id
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    termaxated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_mon2_min_max_contr
  ( p_month2_min_contribution  IN hr_de_soc_ins_contr_lvls_f.month2_min_contribution%type
   ,p_month2_max_contribution  IN hr_de_soc_ins_contr_lvls_f.month2_max_contribution%type
   ,p_min_increased_contribution  IN hr_de_soc_ins_contr_lvls_f.min_increased_contribution%type
   ,p_max_increased_contribution  IN hr_de_soc_ins_contr_lvls_f.max_increased_contribution%type
   ,p_soc_ins_contr_lvls_id    IN hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%type) IS

  --
  l_proc     VARCHAR2(72) := g_package || 'chk_mon2_min_max_contr';
  l_dummy    VARCHAR2(1);
  l_validated boolean := TRUE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for month2_min_contribution or month2_min_contribution has changed
  --
  IF ( (p_soc_ins_contr_lvls_id IS NULL) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.month2_min_contribution <> p_month2_min_contribution)) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.month2_max_contribution <> p_month2_max_contribution)) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.min_increased_contribution <> p_min_increased_contribution)) OR
       ((p_soc_ins_contr_lvls_id IS NOT NULL) AND
        (hr_cle_shd.g_old_rec.max_increased_contribution <> p_max_increased_contribution))) THEN


      --
      hr_utility.set_location(l_proc, 20);

      --
      IF ( p_month2_min_contribution > p_month2_max_contribution ) then
      --
      hr_utility.set_location(l_proc, 30);
      hr_utility.set_message(800, 'HR_DE_MAX_MIN_INC_CONTR');
      hr_utility.raise_error;

      END IF;
      --
        --Commented out this code to fix bug 2359120
     /* IF ((p_month2_min_contribution < p_min_increased_contribution) OR
          (p_month2_max_contribution > p_max_increased_contribution)) THEN
      --
      hr_utility.set_location(l_proc, 30);
      hr_utility.set_message(800, 'HR_DE_MON_MAX_MIN_CONTR');
      hr_utility.raise_error;

      END IF;*/

    --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
  --
END chk_mon2_min_max_contr;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_object_version_number >-----------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Checks that the OVN passed is not null on update and delete.
--
--  Pre-conditions :
--   s None.
--
--  In Arguments :
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
procedure chk_object_version_number
  (
    p_object_version_number in  hr_de_soc_ins_contr_lvls_f.object_version_number%TYPE
  )     is
--
 l_proc  varchar2(72) := g_package||'chk_object_version_number';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory parameters have been set
  --
   hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'object_version_number'
    ,p_argument_value     => p_object_version_number
    );
    --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
end chk_object_version_number;


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
  (p_datetrack_mode                in     varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name      all_tables.table_name%TYPE;
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Mode will be valid, as this is checked at the start of the upd.
  --
  -- Ensure the arguments are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
    --
  --
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
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
  (p_soc_ins_contr_lvls_id            in number
  ,p_datetrack_mode                   in     varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
  l_rows_exist  Exception;
  l_table_name  all_tables.table_name%TYPE;
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = hr_api.g_delete or
      p_datetrack_mode = hr_api.g_zap) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_start_date'
      ,p_argument_value => p_validation_start_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'soc_ins_contr_lvls_id'
      ,p_argument_value => p_soc_ins_contr_lvls_id
      );
    --
  --
    --
  End If;
  --
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  --
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in hr_cle_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode in     varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_cle_bus.chk_organization_id( p_effective_date
                                , p_validation_start_date
                                , p_validation_end_date
                                , p_rec.organization_id
                                , p_rec.soc_ins_contr_lvls_id  );

  hr_cle_bus.chk_normal_amount( p_rec.normal_amount
                                , p_rec.soc_ins_contr_lvls_id  );

  hr_cle_bus.chk_increased_amount  ( p_rec.increased_amount
                                , p_rec.soc_ins_contr_lvls_id  );

  hr_cle_bus.chk_reduced_amount  ( p_rec.reduced_amount
                                , p_rec.soc_ins_contr_lvls_id  );

  hr_cle_bus.chk_normal_percentage  ( p_rec.normal_percentage
                                , p_rec.soc_ins_contr_lvls_id  );

  hr_cle_bus.chk_increased_percentage  ( p_rec.increased_percentage
                                , p_rec.soc_ins_contr_lvls_id  );

  hr_cle_bus.chk_reduced_percentage  ( p_rec.reduced_percentage
                                , p_rec.soc_ins_contr_lvls_id  );

--  hr_cle_bus.chk_object_version_number ( p_rec.object_version_number);
 --
  IF(p_rec.contribution_level_type = 'DE_MAND_HEALTH_PROV') THEN
  --
  hr_cle_bus.chk_normal_percent_null
    ( p_rec.normal_percentage
     ,p_rec.soc_ins_contr_lvls_id );
  --
  hr_cle_bus.chk_increased_percent_null
    ( p_rec.increased_percentage
     ,p_rec.soc_ins_contr_lvls_id );
  --
   hr_cle_bus.chk_reduced_percent_null
      ( p_rec.reduced_percentage
       ,p_rec.soc_ins_contr_lvls_id );
  --
  END IF;


  IF(p_rec.contribution_level_type = 'DE_ADD_SEC_PEN_PROV') THEN
  --
  --
  hr_cle_bus.chk_normal_percent_null
    ( p_rec.normal_percentage
     ,p_rec.soc_ins_contr_lvls_id );
  --
  hr_cle_bus.chk_increased_percent_null
    ( p_rec.increased_percentage
     ,p_rec.soc_ins_contr_lvls_id );
  --

  hr_cle_bus.chk_max_inc_contr_null
    ( p_rec.max_increased_contribution
     ,p_rec.soc_ins_contr_lvls_id      );

  --
  hr_cle_bus.chk_min_inc_contr_null
    ( p_rec.min_increased_contribution
     ,p_rec.soc_ins_contr_lvls_id    );
  --

IF p_rec.month1 IS NOT NULL THEN
  hr_cle_bus.chk_month1_min_contr_null
    ( p_rec.month1_min_contribution
     ,p_rec.soc_ins_contr_lvls_id   );

  --
  hr_cle_bus.chk_month1_max_contr_null
    ( p_rec.month1_max_contribution
     ,p_rec.soc_ins_contr_lvls_id );
  --
  END IF;

 IF p_rec.month2 IS NOT NULL THEN
  hr_cle_bus.chk_month2_min_contr_null
    ( p_rec.month2_min_contribution
     ,p_rec.soc_ins_contr_lvls_id );

  --
  hr_cle_bus.chk_month2_max_contr_null
    ( p_rec.month2_max_contribution
     ,p_rec.soc_ins_contr_lvls_id );
  --
  END IF;
  --
  hr_cle_bus.chk_employee_contribution
    ( p_rec.employee_contribution
     ,p_rec.soc_ins_contr_lvls_id );

  --
  hr_cle_bus.chk_month1
    ( p_rec.month1
     ,p_rec.soc_ins_contr_lvls_id);

  --
  hr_cle_bus.chk_month2
    ( p_rec.month2
     ,p_rec.soc_ins_contr_lvls_id );

  --
  hr_cle_bus.chk_flat_tax_month_val
    ( p_rec.flat_tax_limit_per_month
     ,p_rec.soc_ins_contr_lvls_id );

  --
  hr_cle_bus.chk_flat_tax_year_val
    ( p_rec.flat_tax_limit_per_year
   ,p_rec.soc_ins_contr_lvls_id );
  --
  hr_cle_bus.chk_min_max_inc_contr
    ( p_rec.min_increased_contribution
     ,p_rec.max_increased_contribution
     ,p_rec.soc_ins_contr_lvls_id );

  --
  hr_cle_bus.chk_mon1_min_max_contr
    ( p_rec.month1_min_contribution
     ,p_rec.month1_max_contribution
     ,p_rec.min_increased_contribution
     ,p_rec.max_increased_contribution
     ,p_rec.soc_ins_contr_lvls_id  );

  --
  hr_cle_bus.chk_mon2_min_max_contr
    ( p_rec.month2_min_contribution
     ,p_rec.month2_max_contribution
     ,p_rec.min_increased_contribution
     ,p_rec.max_increased_contribution
     ,p_rec.soc_ins_contr_lvls_id  );

--


  END IF;

    --
    hr_cle_bus.chk_df(p_rec);
    --
    --


  hr_utility.set_location(' Leaving:'||l_proc, 10);


End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in hr_cle_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode in     varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- Call all supporting business operations
  --
  --

  hr_cle_bus.chk_normal_amount  ( p_rec.normal_amount
                                , p_rec.soc_ins_contr_lvls_id  );

  hr_cle_bus.chk_increased_amount  ( p_rec.increased_amount
                                , p_rec.soc_ins_contr_lvls_id  );

  hr_cle_bus.chk_reduced_amount  ( p_rec.reduced_amount
                                , p_rec.soc_ins_contr_lvls_id  );

  hr_cle_bus.chk_normal_percentage  ( p_rec.normal_percentage
                                , p_rec.soc_ins_contr_lvls_id  );

  hr_cle_bus.chk_increased_percentage  ( p_rec.increased_percentage
                                , p_rec.soc_ins_contr_lvls_id  );

  hr_cle_bus.chk_reduced_percentage  ( p_rec.reduced_percentage
                                , p_rec.soc_ins_contr_lvls_id  );

  hr_cle_bus.chk_object_version_number ( p_rec.object_version_number);

  --
   --
    IF(p_rec.contribution_level_type = 'DE_MAND_HEALTH_PROV') THEN
    --
    hr_cle_bus.chk_normal_percent_null
      ( p_rec.normal_percentage
       ,p_rec.soc_ins_contr_lvls_id );
    --
    hr_cle_bus.chk_increased_percent_null
      ( p_rec.increased_percentage
       ,p_rec.soc_ins_contr_lvls_id );
    --
     hr_cle_bus.chk_reduced_percent_null
        ( p_rec.reduced_percentage
         ,p_rec.soc_ins_contr_lvls_id );
    --
    END IF;


    IF(p_rec.contribution_level_type = 'DE_ADD_SEC_PEN_PROV') THEN
    --
    --
    hr_cle_bus.chk_normal_percent_null
      ( p_rec.normal_percentage
       ,p_rec.soc_ins_contr_lvls_id );
    --
    hr_cle_bus.chk_increased_percent_null
      ( p_rec.increased_percentage
       ,p_rec.soc_ins_contr_lvls_id );
    --

    hr_cle_bus.chk_max_inc_contr_null
      ( p_rec.max_increased_contribution
       ,p_rec.soc_ins_contr_lvls_id      );

    --
    hr_cle_bus.chk_min_inc_contr_null
      ( p_rec.min_increased_contribution
       ,p_rec.soc_ins_contr_lvls_id    );
    --
    IF p_rec.month1 IS NOT NULL THEN
    hr_cle_bus.chk_month1_min_contr_null
      ( p_rec.month1_min_contribution
       ,p_rec.soc_ins_contr_lvls_id   );

    --
    hr_cle_bus.chk_month1_max_contr_null
      ( p_rec.month1_max_contribution
       ,p_rec.soc_ins_contr_lvls_id );
    --
    END IF;
    IF p_rec.month2 IS NOT NULL THEN
    hr_cle_bus.chk_month2_min_contr_null
      ( p_rec.month2_min_contribution
       ,p_rec.soc_ins_contr_lvls_id );

    --
    hr_cle_bus.chk_month2_max_contr_null
      ( p_rec.month2_max_contribution
       ,p_rec.soc_ins_contr_lvls_id );
    --
    END IF;
    --
    hr_cle_bus.chk_employee_contribution
      ( p_rec.employee_contribution
       ,p_rec.soc_ins_contr_lvls_id );

    --
    hr_cle_bus.chk_month1
      ( p_rec.month1
       ,p_rec.soc_ins_contr_lvls_id);

    --
    hr_cle_bus.chk_month2
      ( p_rec.month2
       ,p_rec.soc_ins_contr_lvls_id );

    --
    hr_cle_bus.chk_flat_tax_month_val
      ( p_rec.flat_tax_limit_per_month
       ,p_rec.soc_ins_contr_lvls_id );

    --
    hr_cle_bus.chk_flat_tax_year_val
      ( p_rec.flat_tax_limit_per_year
     ,p_rec.soc_ins_contr_lvls_id );
    --
    hr_cle_bus.chk_min_max_inc_contr
      ( p_rec.min_increased_contribution
       ,p_rec.max_increased_contribution
       ,p_rec.soc_ins_contr_lvls_id );

    --
    hr_cle_bus.chk_mon1_min_max_contr
      ( p_rec.month1_min_contribution
       ,p_rec.month1_max_contribution
       ,p_rec.min_increased_contribution
       ,p_rec.max_increased_contribution
       ,p_rec.soc_ins_contr_lvls_id  );

    --
    hr_cle_bus.chk_mon2_min_max_contr
      ( p_rec.month2_min_contribution
       ,p_rec.month2_max_contribution
       ,p_rec.min_increased_contribution
       ,p_rec.max_increased_contribution
       ,p_rec.soc_ins_contr_lvls_id  );

  --


  END IF;

  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  --
  hr_cle_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in hr_cle_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode in     varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_soc_ins_contr_lvls_id            => p_rec.soc_ins_contr_lvls_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--

end hr_cle_bus;

/
