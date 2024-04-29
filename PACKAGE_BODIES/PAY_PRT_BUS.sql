--------------------------------------------------------
--  DDL for Package Body PAY_PRT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PRT_BUS" as
/* $Header: pyprtrhi.pkb 115.13 2003/02/28 15:52:21 alogue noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_prt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_run_type_id                 number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_run_type_id                          in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_run_types_f prt
     where prt.run_type_id = p_run_type_id
       and pbg.business_group_id = prt.business_group_id;
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
    ,p_argument           => 'run_type_id'
    ,p_argument_value     => p_run_type_id
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
-- ----------------------------------------------------------------------------
-- |------------------------< return_legislation_code >-----------------------|
-- ----------------------------------------------------------------------------
Function return_legislation_code
  (p_run_type_id                          in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_run_types_f prt
     where prt.run_type_id = p_run_type_id
       and pbg.business_group_id (+) = prt.business_group_id;
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
    ,p_argument           => 'run_type_id'
    ,p_argument_value     => p_run_type_id
    );
  --
  if ( nvl(pay_prt_bus.g_run_type_id, hr_api.g_number)
       = p_run_type_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_prt_bus.g_legislation_code;
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
    pay_prt_bus.g_run_type_id       := p_run_type_id;
    pay_prt_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
/*
RET 20th April think this is now obsolete, but won't delete until this is
confirmed.
--  ---------------------------------------------------------------------------
--  |------------------< return_legislation_code_child >----------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code_child
  (p_run_type_id  in number
  )
  Return Varchar2 Is
  --
  -- declare cursor
  --
  cursor csr_get_bg_id
  is
  select prt.business_group_id
  from   pay_run_types_f prt
  where  prt.run_type_id = p_run_type_id;
  --
  l_legislation_code  varchar2(150);
  l_bg_id             number(15);
  l_proc          varchar2(72)  :=  g_package||'return_legislation_code_child';
Begin
--
hr_utility.set_location('Entering:'|| l_proc, 10);
--
if ( nvl(pay_prt_bus.g_run_type_id, hr_api.g_number) = p_run_type_id) then
  --
  -- The legislation code has already been found with a previous
  -- call to this function. Just return the value in the global
  -- variable.
  --
    l_legislation_code := pay_prt_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
else
  open  csr_get_bg_id;
  fetch csr_get_bg_id into l_gb_id;
  --
  if get_gb_id%notfound then
  --
  -- The primary key is invalid therefore we must error
  --
    close csr_get_bg_id;
    fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
    hr_utility.set_location(l_proc,20);
  else -- a row is found
  --
  -- if bg is null then return null, else get the leg code using the hr_api
  -- function.
  --
    if l_bg_id is null then
    --
      l_legislation_code := '';
      hr_utility.set_location(l_proc,30);
    else
      l_legislation_code := hr_api.return_legislation_code
                               (p_business_group_id => l_bg_id);
      hr_utility.set_location(l_proc,40);
    end if;
  end if; -- cursor not found
  --
  close csr_get_bg_id;
  --
  -- Set the global variables so the values are
  -- available for the next call to this function.
  --
  pay_prt_bus.g_run_type_id       := p_run_type_id;
  pay_prt_bus.g_legislation_code  := l_legislation_code;
end if;
  --
hr_utility.set_location(' Leaving:'|| l_proc, 50);
return l_legislation_code;
end return_legislation_code_child;
*/
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_run_method >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the run_method is one of the
--   following:
--      N - Normal
--  C - Cumulative
--  S - Separate Payment
--  P - Process Separately
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
--   Processing continues if a valid run_method has been entered.
--
-- Post Failure:
--   An application error is raised if a invalid run_method has been entered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_run_method
  (p_effective_date  in date
  ,p_validation_start_date in date
  ,p_validation_end_date in date
  ,p_run_method            in varchar2) IS
--
  l_proc     varchar2(72) := g_package || 'chk_run_method';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
--
-- As RUN_METHOD is a system level lookup_type, not extensible, users will
-- not be able to add new lookup_codes. Thus only need to validate against
-- hr_standard_lookups, even though the table does have a business_group_id
-- and would expect to need to validate against hr_lookups.
--
hr_utility.set_location('Entering: '||l_proc,5);
--
  IF hr_api.not_exists_in_dt_hrstanlookups
                      (p_effective_date          => p_effective_date
                      ,p_validation_start_date   => p_validation_start_date
                      ,p_validation_end_date     => p_validation_end_date
                      ,p_lookup_type             => 'RUN_METHOD'
                      ,p_lookup_code             => p_run_method
                      )
  THEN
  --
  -- The RUN_METHOD for this record is not recognised
  --
    fnd_message.set_name('PAY','HR_xxxx_INVALID_RUN_METHOD');
    fnd_message.raise_error;
    --
    hr_utility.set_location(l_proc,10);
  END IF;
  --
hr_utility.set_location('Leaving: '||l_proc,15);
--
End chk_run_method;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_run_type_name >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the run_type_name is unique within
--   a business group and across all modes.
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
--   Processing continues if a valid run_type_name has been entered.
--
-- Post Failure:
--   An application error is raised if a duplicate run_type_name has been
--   entered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_run_type_name
  (p_run_type_id       in number
  ,p_run_type_name     in varchar2
  ,p_effective_date    in date
  ,p_business_group_id in number default null
  ,p_legislation_code  in varchar2 default null) IS
--
  l_proc     varchar2(72) := g_package || 'chk_run_type_name';
  l_error    EXCEPTION;
  l_argument varchar2(30);
  l_run_type_name varchar2(80);
  l_mode     varchar2(30);
  --
/*
  cursor csr_rt_name is
  select prt.run_type_name
  from   pay_run_types_f prt
  where  prt.run_type_name = p_run_type_name
  and    nvl(prt.business_group_id, -1) = nvl(p_business_group_id
                                              , nvl(prt.business_group_id, -1))
  and    nvl(prt.legislation_code, 'CORE') = nvl(p_legislation_code, 'CORE')
  and    p_effective_date between prt.effective_start_date
                              and prt.effective_end_date;
*/
  cursor csr_rt_name_u is
  select prt.run_type_name
  from   pay_run_types_f prt
  where  prt.business_group_id = p_business_group_id
  and    prt.legislation_code is null
  and    prt.run_type_name = p_run_type_name
  and    p_effective_date between prt.effective_start_date
                              and prt.effective_end_date;
  --
  cursor csr_rt_name_s is
  select prt.run_type_name
  from   pay_run_types_f prt
  where  prt.legislation_code = p_legislation_code
  and    prt.business_group_id is null
  and    prt.run_type_name = p_run_type_name
  and    p_effective_date between prt.effective_start_date
                              and prt.effective_end_date;
  --
  cursor csr_rt_name_g is
  select prt.run_type_name
  from   pay_run_types_f prt
  where  prt.run_type_name = p_run_type_name
  and    prt.business_group_id is null
  and    prt.legislation_code is null
  and    p_effective_date between prt.effective_start_date
                              and prt.effective_end_date;
--
Begin
--
hr_utility.set_location('Entering: '||l_proc,5);
--
-- Only execute the cursor if absolutely necessary.
-- a) During update, the run_type_name has actually changed to another not
--    null value, i,e, the value passed to this procedure is different to the
--    g_old_rec value.
-- b) During insert, the run_type_name is null.
-- Can tell the difference between insert and update by looking at the
-- primary key value. For update it will be not null. For insert it will be
-- null, because pre_inset has not been called yet.
--
IF (((p_run_type_id is not null) and
     nvl(pay_prt_shd.g_old_rec.run_type_name, hr_api.g_varchar2) <>
     nvl(p_run_type_name, hr_api.g_varchar2))
   or
    (p_run_type_id is null)) then
    --
      hr_utility.set_location(l_proc, 10);
      --
      -- Only need to open the cursor if run_type_name is not null
      --
      if p_run_type_name is not null then
      --
      -- get mode then open the corresponding cursor
      --
      l_mode := hr_startup_data_api_support.return_startup_mode;
      --
        if l_mode = 'GENERIC' then
        --
          OPEN csr_rt_name_g;
          FETCH csr_rt_name_g INTO l_run_type_name;
          IF csr_rt_name_g%FOUND THEN
            hr_utility.set_message(801,'HR_33592_PRT_DUP_NAME');
            hr_utility.raise_error;
          END IF;
          CLOSE csr_rt_name_g;
          hr_utility.set_location(l_proc, 15);
          --
        elsif l_mode = 'STARTUP' then
        --
          OPEN csr_rt_name_s;
          FETCH csr_rt_name_s INTO l_run_type_name;
          IF csr_rt_name_s%FOUND THEN
            hr_utility.set_message(801,'HR_33592_PRT_DUP_NAME');
            hr_utility.raise_error;
          END IF;
          CLOSE csr_rt_name_s;
          hr_utility.set_location(l_proc, 20);
        else -- mode is USER
        --
          OPEN csr_rt_name_u;
          FETCH csr_rt_name_u INTO l_run_type_name;
          IF csr_rt_name_u%FOUND THEN
            hr_utility.set_message(801,'HR_33592_PRT_DUP_NAME');
            hr_utility.raise_error;
          END IF;
          CLOSE csr_rt_name_u;
          hr_utility.set_location(l_proc, 25);
        end if; -- what mode
/*
Logic has changed back! so that names are unique within a business group
and within a legislation. So, you have the same name for an RT in a BG as
in a STARTUP row, but you cannot have duplicate rows in a bg or in a particular
legislation.
        OPEN csr_rt_name;
        FETCH csr_rt_name into l_run_type_name;
        IF csr_rt_name%FOUND THEN
          hr_utility.set_message(801,'HR_33592_PRT_DUP_NAME');
          hr_utility.raise_error;
        END IF;
        CLOSE csr_rt_name;
      end if;
*/
      --
  end if;
end if;
hr_utility.set_location('Leaving: '||l_proc, 20);
--
END chk_run_type_name;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_srs_flag >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that srs_flag value is either 'Y' or 'N'.
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
--   Processing continues if a valid srs_flag value has been entered.
--
-- Post Failure:
--   An application error is raised if an invalid srs_flag has been enetred
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_srs_flag(p_srs_flag       in varchar2
                      ,p_effective_date in date)
is
Begin
  If p_srs_flag is not null Then
    If hr_api.not_exists_in_hr_lookups
      (p_effective_date
      ,'YES_NO'
      ,p_srs_flag) Then
      --
      fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
      fnd_message.set_token('COLUMN','SRS_FLAG');
      fnd_message.set_token('LOOKUP_TYPE','YES_NO');
      fnd_message.raise_error;
      --
    End If;
  End If;
End chk_srs_flag;
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
  (p_rec in pay_prt_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.run_type_id is not null)  and
    (nvl(pay_prt_shd.g_old_rec.run_information_category,
         hr_api.g_varchar2) <>
    nvl(p_rec.run_information_category, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information1, hr_api.g_varchar2) <>
    nvl(p_rec.run_information1, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information2, hr_api.g_varchar2) <>
    nvl(p_rec.run_information2, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information3, hr_api.g_varchar2) <>
    nvl(p_rec.run_information3, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information4, hr_api.g_varchar2) <>
    nvl(p_rec.run_information4, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information5, hr_api.g_varchar2) <>
    nvl(p_rec.run_information5, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information6, hr_api.g_varchar2) <>
    nvl(p_rec.run_information6, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information7, hr_api.g_varchar2) <>
    nvl(p_rec.run_information7, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information8, hr_api.g_varchar2) <>
    nvl(p_rec.run_information8, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information9, hr_api.g_varchar2) <>
    nvl(p_rec.run_information9, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information10, hr_api.g_varchar2) <>
    nvl(p_rec.run_information10, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information11, hr_api.g_varchar2) <>
    nvl(p_rec.run_information11, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information12, hr_api.g_varchar2) <>
    nvl(p_rec.run_information12, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information13, hr_api.g_varchar2) <>
    nvl(p_rec.run_information13, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information14, hr_api.g_varchar2) <>
    nvl(p_rec.run_information14, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information15, hr_api.g_varchar2) <>
    nvl(p_rec.run_information15, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information16, hr_api.g_varchar2) <>
    nvl(p_rec.run_information16, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information17, hr_api.g_varchar2) <>
    nvl(p_rec.run_information17, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information18, hr_api.g_varchar2) <>
    nvl(p_rec.run_information18, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information19, hr_api.g_varchar2) <>
    nvl(p_rec.run_information19, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information20, hr_api.g_varchar2) <>
    nvl(p_rec.run_information20, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information21, hr_api.g_varchar2) <>
    nvl(p_rec.run_information21, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information22, hr_api.g_varchar2) <>
    nvl(p_rec.run_information22, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information23, hr_api.g_varchar2) <>
    nvl(p_rec.run_information23, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information24, hr_api.g_varchar2) <>
    nvl(p_rec.run_information24, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information25, hr_api.g_varchar2) <>
    nvl(p_rec.run_information25, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information26, hr_api.g_varchar2) <>
    nvl(p_rec.run_information26, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information27, hr_api.g_varchar2) <>
    nvl(p_rec.run_information27, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information28, hr_api.g_varchar2) <>
    nvl(p_rec.run_information28, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information29, hr_api.g_varchar2) <>
    nvl(p_rec.run_information29, hr_api.g_varchar2)  or
    nvl(pay_prt_shd.g_old_rec.run_information30, hr_api.g_varchar2) <>
    nvl(p_rec.run_information30, hr_api.g_varchar2))  )
    or (p_rec.run_type_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --

    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name		  => 'PAY'
      ,p_descflex_name			  => 'Pay Run Type Developer DF'
      ,p_attribute_category	          => p_rec.run_information_category
      ,p_attribute1_name		  => 'RUN_INFORMATION1'
      ,p_attribute1_value		  => p_rec.run_information1
      ,p_attribute2_name		  => 'RUN_INFORMATION2'
      ,p_attribute2_value		  => p_rec.run_information2
      ,p_attribute3_name		  => 'RUN_INFORMATION3'
      ,p_attribute3_value		  => p_rec.run_information3
      ,p_attribute4_name		  => 'RUN_INFORMATION4'
      ,p_attribute4_value                 => p_rec.run_information4
      ,p_attribute5_name                  => 'RUN_INFORMATION5'
      ,p_attribute5_value                 => p_rec.run_information5
      ,p_attribute6_name                  => 'RUN_INFORMATION6'
      ,p_attribute6_value                 => p_rec.run_information6
      ,p_attribute7_name                  => 'RUN_INFORMATION7'
      ,p_attribute7_value                 => p_rec.run_information7
      ,p_attribute8_name                  => 'RUN_INFORMATION8'
      ,p_attribute8_value                 => p_rec.run_information8
      ,p_attribute9_name                  => 'RUN_INFORMATION9'
      ,p_attribute9_value                 => p_rec.run_information9
      ,p_attribute10_name                 => 'RUN_INFORMATION10'
      ,p_attribute10_value                => p_rec.run_information10
      ,p_attribute11_name                 => 'RUN_INFORMATION11'
      ,p_attribute11_value                => p_rec.run_information11
      ,p_attribute12_name                 => 'RUN_INFORMATION12'
      ,p_attribute12_value                => p_rec.run_information12
      ,p_attribute13_name                 => 'RUN_INFORMATION13'
      ,p_attribute13_value                => p_rec.run_information13
      ,p_attribute14_name                 => 'RUN_INFORMATION14'
      ,p_attribute14_value                => p_rec.run_information14
      ,p_attribute15_name                 => 'RUN_INFORMATION15'
      ,p_attribute15_value                => p_rec.run_information15
      ,p_attribute16_name                 => 'RUN_INFORMATION16'
      ,p_attribute16_value                => p_rec.run_information16
      ,p_attribute17_name                 => 'RUN_INFORMATION17'
      ,p_attribute17_value                => p_rec.run_information17
      ,p_attribute18_name                 => 'RUN_INFORMATION18'
      ,p_attribute18_value                => p_rec.run_information18
      ,p_attribute19_name                 => 'RUN_INFORMATION19'
      ,p_attribute19_value                => p_rec.run_information19
      ,p_attribute20_name                 => 'RUN_INFORMATION20'
      ,p_attribute20_value                => p_rec.run_information20
      ,p_attribute21_name                 => 'RUN_INFORMATION21'
      ,p_attribute21_value                => p_rec.run_information21
      ,p_attribute22_name                 => 'RUN_INFORMATION22'
      ,p_attribute22_value                => p_rec.run_information22
      ,p_attribute23_name                 => 'RUN_INFORMATION23'
      ,p_attribute23_value                => p_rec.run_information23
      ,p_attribute24_name                 => 'RUN_INFORMATION24'
      ,p_attribute24_value                => p_rec.run_information24
      ,p_attribute25_name                 => 'RUN_INFORMATION25'
      ,p_attribute25_value                => p_rec.run_information25
      ,p_attribute26_name                 => 'RUN_INFORMATION26'
      ,p_attribute26_value                => p_rec.run_information26
      ,p_attribute27_name                 => 'RUN_INFORMATION27'
      ,p_attribute27_value                => p_rec.run_information27
      ,p_attribute28_name                 => 'RUN_INFORMATION28'
      ,p_attribute28_value                => p_rec.run_information28
      ,p_attribute29_name                 => 'RUN_INFORMATION29'
      ,p_attribute29_value                => p_rec.run_information29
      ,p_attribute30_name                 => 'RUN_INFORMATION30'
      ,p_attribute30_value                => p_rec.run_information30
      );

  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
--
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_for_child_actions >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that there are no child payroll actions
--   or assignment_actions for a run type that is being deleted.
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
--   Processing continues if no child rows are found.
--
-- Post Failure:
--   An application error is raised if child rows are found, and delete
--   processing is halted.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_for_child_actions
  (p_run_type_id       in number
  ,p_effective_date    in date
  ,p_business_group_id in number default null
  ,p_legislation_code in varchar2 default null) is
--
cursor chk_for_ppa(p_rt_id number
                  ,p_bg_id number)
is
select 1
from   pay_payroll_actions ppa
where  ppa.run_type_id = p_rt_id
and    ppa.business_group_id = p_bg_id;
--
cursor chk_for_ppanb(p_rt_id number)
is
select 1
from   pay_payroll_actions ppa
where  ppa.run_type_id = p_rt_id;
--
cursor chk_for_paa(p_rt_id number
                  ,p_bg_id number)
is
select 1
from   pay_assignment_actions paa
,      pay_payroll_actions ppa
where  paa.run_type_id = p_rt_id
and    ppa.payroll_action_id = paa.payroll_action_id
and    ppa.business_group_id = p_bg_id;
--
cursor chk_for_paanb(p_rt_id number)
is
select 1
from   pay_assignment_actions paa
where  paa.run_type_id = p_rt_id;
--
cursor get_bg_id
is
select business_group_id
from   per_business_groups
where  legislation_code = p_legislation_code;
--
  l_proc     varchar2(72) := g_package || 'chk_for_child_actions';
  l_error    EXCEPTION;
  l_argument varchar2(30);
  l_exists   number(1);
--
BEGIN
hr_utility.set_location('Entering: '||l_proc,5);
--
if p_business_group_id is not null then -- user run type
  open  chk_for_ppa(p_run_type_id, p_business_group_id);
  fetch chk_for_ppa into l_exists;
  if chk_for_ppa%FOUND then
    close chk_for_ppa;
    fnd_message.set_name('PAY', 'HR_34981_PRT_CHILD_PPA');
    fnd_message.raise_error;
    hr_utility.set_location(l_proc, 10);
  else
    close chk_for_ppa;
  end if;
  --
  open chk_for_paa(p_run_type_id, p_business_group_id);
    fetch chk_for_paa into l_exists;
    if chk_for_paa%FOUND then
      close chk_for_paa;
      fnd_message.set_name('PAY', 'HR_34982_PRT_CHILD_PAA');
      fnd_message.raise_error;
      hr_utility.set_location(l_proc, 15);
    else
      close chk_for_paa;
    end if;
--
elsif p_legislation_code is not null then -- startup run type
   --
   for each_bg in get_bg_id loop
     open  chk_for_ppa(p_run_type_id, each_bg.business_group_id);
     fetch chk_for_ppa into l_exists;
     if chk_for_ppa%FOUND then
       close chk_for_ppa;
       fnd_message.set_name('PAY', 'HR_34981_PRT_CHILD_PPA');
       fnd_message.raise_error;
       hr_utility.set_location(l_proc, 20);
     else
       close chk_for_ppa;
     end if;
     --
     open chk_for_paa(p_run_type_id, each_bg.business_group_id);
     fetch chk_for_paa into l_exists;
     if chk_for_paa%FOUND then
       close chk_for_paa;
       fnd_message.set_name('PAY', 'HR_34982_PRT_CHILD_PAA');
       fnd_message.raise_error;
       hr_utility.set_location(l_proc, 25);
     else
       close chk_for_paa;
     end if;
   end loop;
--
else  -- generic run type
  open  chk_for_ppanb(p_run_type_id);
  fetch chk_for_ppanb into l_exists;
  if chk_for_ppanb%FOUND then
    close chk_for_ppanb;
    fnd_message.set_name('PAY', 'HR_34981_PRT_CHILD_PPA');
    fnd_message.raise_error;
    hr_utility.set_location(l_proc, 30);
  else
    close chk_for_ppanb;
  end if;
--
  open chk_for_paanb(p_run_type_id);
  fetch chk_for_paanb into l_exists;
  if chk_for_paanb%FOUND then
    close chk_for_paanb;
    fnd_message.set_name('PAY', 'HR_34982_PRT_CHILD_PAA');
    fnd_message.raise_error;
    hr_utility.set_location(l_proc, 35);
  else
    close chk_for_paanb;
  end if;
--
end if;
hr_utility.set_location(l_proc, 40);
--
end chk_for_child_actions;
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
  ,p_rec             in pay_prt_shd.g_rec_type
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
  IF NOT pay_prt_shd.api_updating
      (p_run_type_id                      => p_rec.run_type_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc, 10);
  --
  if p_rec.run_type_id <> pay_prt_shd.g_old_rec.run_type_id then
     l_argument := 'run_type_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 20);
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_prt_shd.g_old_rec.business_group_id, hr_api.g_number) then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 25);
  --
  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(pay_prt_shd.g_old_rec.legislation_code, hr_api.g_varchar2) then
     l_argument := 'legislation_code';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  if nvl(p_rec.run_method, hr_api.g_varchar2) <>
     nvl(pay_prt_shd.g_old_rec.run_method, hr_api.g_varchar2) then
     l_argument := 'run_method';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 35);
  --
  -- RET 12-DEC-2001 making run_type_name non-updateable as is the key
  -- for uploading ldts.
  --
  if nvl(p_rec.run_type_name, hr_api.g_varchar2) <>
     nvl(pay_prt_shd.g_old_rec.run_type_name, hr_api.g_varchar2) then
     l_argument := 'run_type_name';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 40);
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
hr_utility.set_location(' Leaving:'||l_proc, 45);
End chk_non_updateable_args;
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
  (p_datetrack_mode                in varchar2
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
  (p_run_type_id                      in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc    varchar2(72)    := g_package||'dt_delete_validate';
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
      ,p_argument       => 'run_type_id'
      ,p_argument_value => p_run_type_id
      );
    --
    If (dt_api.rows_exist
       (p_base_table_name => 'pay_element_type_usages_f'
       ,p_base_key_column => 'run_type_id'
       ,p_base_key_value  => p_run_type_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
         l_table_name := 'element type usages';
         Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
       (p_base_table_name => 'pay_run_type_org_methods_f'
       ,p_base_key_column => 'run_type_id'
       ,p_base_key_value  => p_run_type_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
         l_table_name := 'run type org methods';
         Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
       (p_base_table_name => 'pay_run_type_usages_f'
       ,p_base_key_column => 'parent_run_type_id'
       ,p_base_key_value  => p_run_type_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
         l_table_name := 'run type usages';
         Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
       (p_base_table_name => 'pay_run_type_usages_f'
       ,p_base_key_column => 'child_run_type_id'
       ,p_base_key_value  => p_run_type_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
         l_table_name := 'run type usages';
         Raise l_rows_exist;
    End If;
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
-- |----------------------< chk_startup_action >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that the current action is allowed according
--  to the current startup mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_startup_action
  (p_insert               IN boolean
  ,p_business_group_id    IN number
  ,p_legislation_code     IN varchar2
  ,p_legislation_subgroup IN varchar2 DEFAULT NULL) IS
--
BEGIN
  --
  -- Call the supporting procedure to check startup mode
  -- EDIT_HERE: The following call should be edited if certain types of rows
  -- are not permitted.
  IF (p_insert) THEN
  --
  -- Call procedure to check startup_action for inserts
  --
    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
  --
  -- Call procedure to check startup action for upd and del
  --
    hr_startup_data_api_support.chk_upd_del_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  END IF;
  --
END chk_startup_action;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pay_prt_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc    varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
/* RET removed this in favour of new chk_startup_action
  IF p_rec.business_group_id is not null THEN
  --
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
    --
  END IF;
*/
  chk_startup_action(true
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP')
    THEN
    hr_api.validate_bus_grp_id(p_rec.business_group_id); -- Validate bus_grp
  END IF;
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_run_method(p_effective_date        => p_effective_date
                ,p_validation_start_date => p_validation_start_date
                ,p_validation_end_date   => p_validation_end_date
                ,p_run_method            => p_rec.run_method);
  --
  hr_utility.set_location(l_proc, 15);
  --
  chk_run_type_name(p_run_type_id        => p_rec.run_type_id
                   ,p_run_type_name      => p_rec.run_type_name
                   ,p_effective_date     => p_effective_date
                   ,p_business_group_id  => p_rec.business_group_id
                   ,p_legislation_code   => p_rec.legislation_code);
  --
  chk_srs_flag(p_srs_flag       => p_rec.srs_flag
              ,p_effective_date => p_effective_date);
  --
  chk_ddf(p_rec		=> p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_prt_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc    varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Currently the only columns that can be updated on pay_run_types_f are
  -- run_type_name and shortname. These can only be updated in CORRECTION
  -- mode, so if a different update mode has been passed in, raise an error
  -- NOTE: this will have to be changed if new columns with different update
  -- requirements are added to the table.
  --
  if p_datetrack_mode <> 'CORRECTION' then
    hr_utility.set_message(801,'HR_34115_PRT_NOT_CORRECTION');
    hr_utility.raise_error;
  end if;
  --
  -- Call all supporting business operations
  --
  chk_startup_action(false
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP')
    THEN
    hr_api.validate_bus_grp_id(p_rec.business_group_id); -- Validate bus_grp
  END IF;
  --
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_run_method(p_effective_date        => p_effective_date
                ,p_validation_start_date => p_validation_start_date
                ,p_validation_end_date   => p_validation_end_date
                ,p_run_method            => p_rec.run_method);
  --
  hr_utility.set_location(l_proc, 15);
  --
  chk_run_type_name(p_run_type_id        => p_rec.run_type_id
                   ,p_run_type_name      => p_rec.run_type_name
                   ,p_effective_date     => p_effective_date
                   ,p_business_group_id  => p_rec.business_group_id
                   ,p_legislation_code   => p_rec.legislation_code);
  --
  chk_srs_flag(p_srs_flag       => p_rec.srs_flag
              ,p_effective_date => p_effective_date);
  --
  chk_ddf(p_rec		=> p_rec);
  -- Call the datetrack update integrity operation
  --
  hr_utility.set_location(l_proc, 20);
  --
  dt_update_validate
    (p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  hr_utility.set_location(l_proc, 25);
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  hr_utility.set_location('Leaving:'||l_proc, 30);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_prt_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc    varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- NB. need to use g_old_rec, as p_rec is not pupulated with all the columns
  -- for delete mode.
  --
  chk_for_child_actions
              (p_run_type_id       => p_rec.run_type_id
              ,p_effective_date    => p_effective_date
              ,p_business_group_id => pay_prt_shd.g_old_rec.business_group_id
              ,p_legislation_code  => pay_prt_shd.g_old_rec.legislation_code);
  --
  chk_startup_action(false
                    ,pay_prt_shd.g_old_rec.business_group_id
                    ,pay_prt_shd.g_old_rec.legislation_code
                    );
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_run_type_id                      => p_rec.run_type_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_prt_bus;

/
