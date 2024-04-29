--------------------------------------------------------
--  DDL for Package Body OTA_NHS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_NHS_BUS" as
/* $Header: otnhsrhi.pkb 120.1 2005/09/30 05:00:04 ssur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_nhs_bus.';  -- Global package name
g_nota_history_id                  number         default null;
g_legislation_code            varchar2(150)  default null;
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_nota_history_id                           in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , ota_notrng_histories nth
     where nth.nota_history_id = p_nota_history_id
       and pbg.business_group_id = nth.business_group_id;
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
    ,p_argument           => 'nota_history_id'
    ,p_argument_value     => p_nota_history_id
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
  (p_nota_history_id                           in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , ota_notrng_histories nth
     where nth.nota_history_id = p_nota_history_id
       and pbg.business_group_id = nth.business_group_id;
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
    ,p_argument           => 'nota_history_id'
    ,p_argument_value     => p_nota_history_id
    );
  --
  if ( nvl(ota_nhs_bus.g_nota_history_id, hr_api.g_number)
       = p_nota_history_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_nhs_bus.g_legislation_code;
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
    ota_nhs_bus.g_nota_history_id        := p_nota_history_id;
    ota_nhs_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_df >----------------------------------|
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
--   If the Descriptive Flexfield structure column and data values
--   are all valid this procedure will end normally and processing will
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
  (p_rec in ota_nhs_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.nota_history_id is not null)  and (
    nvl(ota_nhs_shd.g_old_rec.nth_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information_category, hr_api.g_varchar2)  or
    nvl(ota_nhs_shd.g_old_rec.nth_information1, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information1, hr_api.g_varchar2)  or
    nvl(ota_nhs_shd.g_old_rec.nth_information2, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information2, hr_api.g_varchar2)  or
    nvl(ota_nhs_shd.g_old_rec.nth_information3, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information3, hr_api.g_varchar2)  or
    nvl(ota_nhs_shd.g_old_rec.nth_information4, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information4, hr_api.g_varchar2)  or
    nvl(ota_nhs_shd.g_old_rec.nth_information5, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information5, hr_api.g_varchar2)  or
    nvl(ota_nhs_shd.g_old_rec.nth_information6, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information6, hr_api.g_varchar2)  or
    nvl(ota_nhs_shd.g_old_rec.nth_information7, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information7, hr_api.g_varchar2)  or
    nvl(ota_nhs_shd.g_old_rec.nth_information8, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information8, hr_api.g_varchar2)  or
    nvl(ota_nhs_shd.g_old_rec.nth_information9, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information9, hr_api.g_varchar2)  or
    nvl(ota_nhs_shd.g_old_rec.nth_information10, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information10, hr_api.g_varchar2)  or
    nvl(ota_nhs_shd.g_old_rec.nth_information11, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information11, hr_api.g_varchar2)  or
    nvl(ota_nhs_shd.g_old_rec.nth_information12, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information12, hr_api.g_varchar2)  or
    nvl(ota_nhs_shd.g_old_rec.nth_information13, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information13, hr_api.g_varchar2)  or
    nvl(ota_nhs_shd.g_old_rec.nth_information14, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information14, hr_api.g_varchar2)  or
    nvl(ota_nhs_shd.g_old_rec.nth_information15, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information15, hr_api.g_varchar2)  or
    nvl(ota_nhs_shd.g_old_rec.nth_information16, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information16, hr_api.g_varchar2)  or
    nvl(ota_nhs_shd.g_old_rec.nth_information17, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information17, hr_api.g_varchar2)  or
    nvl(ota_nhs_shd.g_old_rec.nth_information18, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information18, hr_api.g_varchar2)  or
    nvl(ota_nhs_shd.g_old_rec.nth_information19, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information19, hr_api.g_varchar2)  or
    nvl(ota_nhs_shd.g_old_rec.nth_information20, hr_api.g_varchar2) <>
    nvl(p_rec.nth_information20, hr_api.g_varchar2) )
--    or (p_rec.nota_history_id is not null) ) then Bug 2483317
    or (p_rec.nota_history_id is null) ) then

    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_NOTRNG_HISTORIES'
      ,p_attribute_category              => p_rec.NTH_INFORMATION_CATEGORY
      ,p_attribute1_name                 => 'NTH_INFORMATION1'
      ,p_attribute1_value                => p_rec.nth_information1
      ,p_attribute2_name                 => 'NTH_INFORMATION2'
      ,p_attribute2_value                => p_rec.nth_information2
      ,p_attribute3_name                 => 'NTH_INFORMATION3'
      ,p_attribute3_value                => p_rec.nth_information3
      ,p_attribute4_name                 => 'NTH_INFORMATION4'
      ,p_attribute4_value                => p_rec.nth_information4
      ,p_attribute5_name                 => 'NTH_INFORMATION5'
      ,p_attribute5_value                => p_rec.nth_information5
      ,p_attribute6_name                 => 'NTH_INFORMATION6'
      ,p_attribute6_value                => p_rec.nth_information6
      ,p_attribute7_name                 => 'NTH_INFORMATION7'
      ,p_attribute7_value                => p_rec.nth_information7
      ,p_attribute8_name                 => 'NTH_INFORMATION8'
      ,p_attribute8_value                => p_rec.nth_information8
      ,p_attribute9_name                 => 'NTH_INFORMATION9'
      ,p_attribute9_value                => p_rec.nth_information9
      ,p_attribute10_name                => 'NTH_INFORMATION10'
      ,p_attribute10_value               => p_rec.nth_information10
      ,p_attribute11_name                => 'NTH_INFORMATION11'
      ,p_attribute11_value               => p_rec.nth_information11
      ,p_attribute12_name                => 'NTH_INFORMATION12'
      ,p_attribute12_value               => p_rec.nth_information12
      ,p_attribute13_name                => 'NTH_INFORMATION13'
      ,p_attribute13_value               => p_rec.nth_information13
      ,p_attribute14_name                => 'NTH_INFORMATION14'
      ,p_attribute14_value               => p_rec.nth_information14
      ,p_attribute15_name                => 'NTH_INFORMATION15'
      ,p_attribute15_value               => p_rec.nth_information15
      ,p_attribute16_name                => 'NTH_INFORMATION16'
      ,p_attribute16_value               => p_rec.nth_information16
      ,p_attribute17_name                => 'NTH_INFORMATION17'
      ,p_attribute17_value               => p_rec.nth_information17
      ,p_attribute18_name                => 'NTH_INFORMATION18'
      ,p_attribute18_value               => p_rec.nth_information18
      ,p_attribute19_name                => 'NTH_INFORMATION19'
      ,p_attribute19_value               => p_rec.nth_information19
      ,p_attribute20_name                => 'NTH_INFORMATION20'
      ,p_attribute20_value               => p_rec.nth_information20
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
  ,p_rec in ota_nhs_shd.g_rec_type
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
  IF NOT ota_nhs_shd.api_updating
      (p_nota_history_id                           => p_rec.nota_history_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;

  if nvl(p_rec.business_group_id,hr_api.g_number) <>
     nvl(ota_nhs_shd.g_old_rec.business_group_id,hr_api.g_number)
     then
   l_argument := 'business_group_id';
   raise l_error;
  end if;
  if nvl(p_rec.customer_id,hr_api.g_number) <>
     nvl(ota_nhs_shd.g_old_rec.customer_id,hr_api.g_number)
     then
   l_argument := 'customer_id';
   raise l_error;
  end if;
  if nvl(p_rec.organization_id,hr_api.g_number) <>
     nvl(ota_nhs_shd.g_old_rec.organization_id,hr_api.g_number)
     then
   l_argument := 'organization_id';
   raise l_error;
  end if;
  if nvl(p_rec.person_id,hr_api.g_number) <>
     nvl(ota_nhs_shd.g_old_rec.person_id,hr_api.g_number)
     then
   l_argument := 'person_id';
   raise l_error;
  end if;

  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;

-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_organization_id  >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_organization_id
  (p_nota_history_id                in number
   ,p_organization_id         in number
   ,p_business_group_id       in number
   ,p_effective_date       in date) is

--
  l_proc  varchar2(72) := g_package||'chk_organization_id';
  l_single_business_group_id   ota_notrng_histories.business_group_id%type;
  l_exists  varchar2(1);
  l_cross_business_group varchar2(1);
  l_business_group_id    ota_events.business_group_id%type ;

--
--  cursor to check if oganization id is valid.
--
   cursor csr_organization is
     select null
     from hr_all_organization_units
     where organization_id = p_organization_id and
           business_group_id = p_business_group_id;

   cursor csr_organization_cross is
     select null
     from hr_all_organization_units
     where organization_id = p_organization_id ;


Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  ota_nhs_bus.get_profile_value(l_cross_business_group,
                                l_business_group_id    );

if (((p_nota_history_id is not null) and
      nvl(ota_nhs_shd.g_old_rec.organization_id,hr_api.g_number) <>
         nvl(p_organization_id,hr_api.g_number))
   or (p_nota_history_id is null)) then
  --
     hr_utility.set_location('Entering:'||l_proc, 10);
     if (p_organization_id is not null) then
          hr_utility.set_location('Entering:'||l_proc, 15);
          If l_business_group_id is not null then
              open csr_organization_cross;
              fetch csr_organization_cross into l_exists;
              if csr_organization_cross%notfound then
               close csr_organization_cross;
               fnd_message.set_name('OTA','OTA_13268_TFH_INVALID_ORG');
               fnd_message.raise_error;
            end if;
            close csr_organization_cross;
            hr_utility.set_location('Entering:'||l_proc, 20);

          else
            open csr_organization;
            fetch csr_organization into l_exists;
            if csr_organization%notfound then
               close csr_organization;
               fnd_message.set_name('OTA','OTA_13268_TFH_INVALID_ORG');
               fnd_message.raise_error;
            end if;
            close csr_organization;
            hr_utility.set_location('Entering:'||l_proc, 25);
           end if;
      end if;
end if;
hr_utility.set_location('Entering:'||l_proc, 30);
end chk_organization_id;


-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_customer_id  >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_customer_id
  (p_nota_history_id                in number
   ,p_customer_id          in number
   ,p_effective_date       in date) is

--
  l_proc  varchar2(72) := g_package||'chk_customer_id';
  l_exists  varchar2(1);

--
--  cursor to check is person id is belong to customer.
--
   cursor csr_customer is
     Select null
     From HZ_PARTIES party,
          HZ_CUST_ACCOUNTS cust_acct
          Where CUST_ACCT.party_id = PARTY.party_id
          and CUST_ACCT.cust_account_id=p_customer_id;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

if (((p_nota_history_id is not null) and
      nvl(ota_nhs_shd.g_old_rec.customer_id,hr_api.g_number) <>
         nvl(p_customer_id,hr_api.g_number))
   or (p_nota_history_id is null)) then
  --
     hr_utility.set_location('Entering:'||l_proc, 10);
     if (p_customer_id is not null) then
          hr_utility.set_location('Entering:'||l_proc, 15);
            open csr_customer;
            fetch csr_customer into l_exists;
            if csr_customer%notfound then
               close csr_customer;
               fnd_message.set_name('OTA','OTA_13321_TFH_CUSTOMER_NAME');
               fnd_message.raise_error;
            end if;
            close csr_customer;
            hr_utility.set_location('Entering:'||l_proc, 20);
      end if;
end if;
hr_utility.set_location('Entering:'||l_proc, 30);
end chk_customer_id;

-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_person_id  >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_person_id
  (p_nota_history_id                in number
   ,p_customer_id          in number
   ,p_organization_id         in number
   ,p_person_id            in number
   ,p_business_group_id       in number
   ,p_effective_date       in date) is

--
  l_proc  varchar2(72) := g_package||'chk_person_id';
  l_exists  varchar2(1);
  l_cross_business_group varchar2(1) ;
  l_business_group_id    ota_events.business_group_id%type ;

--
--  cursor to check is person id is belong to customer.
--
   cursor cus_contact is
   Select null
   From HZ_CUST_ACCOUNT_ROLES acct_role,
             HZ_RELATIONSHIPS rel,
             HZ_CUST_ACCOUNTS role_acct
   where acct_role.party_id = rel.party_id
  and acct_role.role_type = 'CONTACT'
  and rel.subject_table_name = 'HZ_PARTIES'
  and rel.object_table_name = 'HZ_PARTIES'
  and  acct_role.cust_account_id = role_acct.cust_account_id
  and  role_acct.party_id  =  rel.object_id
  and ACCT_ROLE.cust_account_role_id=p_person_id
  and ACCT_ROLE.cust_account_id=p_customer_id;

--
--  cursor to check is person id is belong to an organization.
--
   cursor org_person is
     select null
     from per_all_people_f per
     where per.business_group_id = p_business_group_id and
          per.person_id = p_person_id and
          rownum=1;
/* Bug 2356572
            and
           p_effective_date between per.effective_start_date and
           per.effective_end_date       ;
*/
/* For Globalization */
    cursor org_person_cross is
     select null
     from per_all_people_f per
     where  per.person_id = p_person_id
     and rownum=1;
/*Bug 2356572
    and
           p_effective_date between per.effective_start_date and
           per.effective_end_date       ;
*/
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  ota_nhs_bus.get_profile_value(l_cross_business_group,
                                l_business_group_id    );


if (((p_nota_history_id is not null) and
      nvl(ota_nhs_shd.g_old_rec.person_id,hr_api.g_number) <>
         nvl(p_person_id,hr_api.g_number))
   or (p_nota_history_id is null)) then
  --
     hr_utility.set_location('Entering:'||l_proc, 10);
    if p_person_id is not null then
       if p_customer_id is null and p_organization_id is null then
           fnd_message.set_name('OTA','OTA_13884_NHS_PERSON_INVALID');
               fnd_message.raise_error;
       end if;
    end if;
    if (p_customer_id is not null) then
       if p_person_id is not null then
            hr_utility.set_location('Entering:'||l_proc, 15);
            open cus_contact;
            fetch cus_contact into l_exists;
            if cus_contact%notfound then
               close cus_contact;
                fnd_message.set_name('OTA','OTA_13884_NHS_PERSON_INVALID');
               fnd_message.raise_error;
            end if;
            close cus_contact;
            hr_utility.set_location('Entering:'||l_proc, 20);
        end if;
    elsif (p_organization_id is not null) then
        if p_person_id is not null then
            hr_utility.set_location('Entering:'||l_proc, 30);
           If l_business_group_id is not null then
               open org_person_cross;
               fetch org_person_cross into l_exists;
               if org_person_cross%notfound then
                  close org_person_cross;
                  fnd_message.set_name('OTA','OTA_13884_NHS_PERSON_INVALID');
                  fnd_message.raise_error;
               end if;
               close org_person_cross;

           else
            open org_person;
            fetch org_person into l_exists;
            if org_person%notfound then
               close org_person;
               fnd_message.set_name('OTA','OTA_13884_NHS_PERSON_INVALID');
               fnd_message.raise_error;
            end if;
            close org_person;
           end if;
            hr_utility.set_location('Entering:'||l_proc, 40);
          end if;
  end if;
end if;
  hr_utility.set_location(' Leaving:'||l_proc, 50);
End chk_person_id;


-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_contact_id  >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_contact_id
  (p_nota_history_id                in number
   ,p_customer_id          in number
   ,p_organization_id         in number
   ,p_contact_id           in number
   ,p_effective_date       in date) is

--
  l_proc  varchar2(72) := g_package||'chk_contact_id';
  l_exists  varchar2(1);

--
--  cursor to check is person id is belong to customer.
--
   cursor cus_contact is
     Select null
     From HZ_CUST_ACCOUNT_ROLES acct_role,
             HZ_RELATIONSHIPS rel,
             HZ_CUST_ACCOUNTS role_acct
  where acct_role.party_id = rel.party_id
  and acct_role.role_type = 'CONTACT'
  and rel.subject_table_name = 'HZ_PARTIES'
  and rel.object_table_name = 'HZ_PARTIES'
  and  acct_role.cust_account_id = role_acct.cust_account_id
  and  role_acct.party_id  =  rel.object_id
  and ACCT_ROLE.cust_account_role_id=p_contact_id
  and ACCT_ROLE.cust_account_id=p_customer_id;

--
--  cursor to check is person id is belong to an organization.
--
   cursor org_person is
     select null
     from per_all_people_f
     where person_id = p_contact_id and
           p_effective_date between effective_start_date and
            effective_end_date  ;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

if (((p_nota_history_id is not null) and
      nvl(ota_nhs_shd.g_old_rec.contact_id,hr_api.g_number) <>
         nvl(p_contact_id,hr_api.g_number))
   or (p_nota_history_id is null)) then
  --
     hr_utility.set_location('Entering:'||l_proc, 10);

    if (p_customer_id is not null) then
       if p_contact_id is not null then
            hr_utility.set_location('Entering:'||l_proc, 15);
            open cus_contact;
            fetch cus_contact into l_exists;
            if cus_contact%notfound then
               close cus_contact;
               fnd_message.set_name('OTA','OTA_13283_TFH_CUSTOMER_CONTACT');
               fnd_message.raise_error;
            end if;
            close cus_contact;
            hr_utility.set_location('Entering:'||l_proc, 20);
        end if;
   elsif (p_organization_id is not null) then
        if p_contact_id is not null then
            hr_utility.set_location('Entering:'||l_proc, 30);
            open org_person;
            fetch org_person into l_exists;
            if org_person%notfound then
               close org_person;
               fnd_message.set_name('HR','HR_51889_APR_PERSON_NOT_EXIST');
               fnd_message.raise_error;
            end if;
            close org_person;
            hr_utility.set_location('Entering:'||l_proc, 40);
          end if;
  end if;
end if;
  hr_utility.set_location(' Leaving:'||l_proc, 50);
End chk_contact_id;


-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_status  >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_status
  (p_nota_history_id             in number
   ,p_status            in varchar2
   ,p_effective_date       in date) is

--
  l_proc  varchar2(72) := g_package||'chk_status';
  l_api_updating boolean;

begin
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- check mandatory parameters has been set
  --
  hr_api.mandatory_arg_error
    (p_api_name      => l_proc
     ,p_argument     => 'effective_date'
     ,p_argument_value  =>p_effective_date);


  if (((p_nota_history_id is not null) and
        nvl(ota_nhs_shd.g_old_rec.status,hr_api.g_varchar2) <>
        nvl(p_status,hr_api.g_varchar2))
     or
       (p_nota_history_id is null)) then

       hr_utility.set_location(' Leaving:'||l_proc, 20);
       --
       -- if status is not null then
       -- check if the status value exists in hr_lookups
    -- where lookup_type is 'OTA_TRAINING_STATUSES'
       --
       if p_status is not null then
          if hr_api.not_exists_in_hr_lookups -- Bug 2478551
             (p_effective_date => p_effective_date
              ,p_lookup_type => 'OTA_TRAINING_STATUSES'
              ,p_lookup_code => p_status) then
              fnd_message.set_name('OTA','OTA_13880_NHS_STATUS_INVALID');
               fnd_message.raise_error;
          end if;
           hr_utility.set_location(' Leaving:'||l_proc, 30);

       end if;

   end if;
 hr_utility.set_location(' Leaving:'||l_proc, 40);

end chk_status;
-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_type  >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_type
  (p_nota_history_id             in number
   ,p_type           in varchar2
   ,p_effective_date       in date) is

--
  l_proc  varchar2(72) := g_package||'chk_type';
  l_api_updating boolean;

begin
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- check mandatory parameters has been set
  --
  hr_api.mandatory_arg_error
    (p_api_name      => l_proc
     ,p_argument     => 'effective_date'
     ,p_argument_value  => p_effective_date);

if (((p_nota_history_id is not null) and
        nvl(ota_nhs_shd.g_old_rec.type,hr_api.g_varchar2) <>
        nvl(p_type,hr_api.g_varchar2))
     or
       (p_nota_history_id is  null)) then

       hr_utility.set_location(' Leaving:'||l_proc, 20);
       --
       -- if status is not null then
       -- check if the status value exists in hr_lookups
    -- where lookup_type is 'OTA_TRAINING_TYPES'
       --
       if p_type is not null then
          if hr_api.not_exists_in_hr_lookups -- Bug 2478551
             (p_effective_date => p_effective_date
              ,p_lookup_type => 'OTA_TRAINING_TYPES'
              ,p_lookup_code => p_type) then
              fnd_message.set_name('OTA','OTA_13879_NHS_TYPE_INVALID');
               fnd_message.raise_error;
          end if;
           hr_utility.set_location(' Leaving:'||l_proc, 30);

       end if;

   end if;
 hr_utility.set_location(' Leaving:'||l_proc, 40);

end chk_type;


-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_duration_unit  >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_duration_unit
  (p_nota_history_id             in number
   ,p_duration_units          in varchar2
   ,p_effective_date       in date) is

--
  l_proc  varchar2(72) := g_package||'chk_duration_units';
  l_api_updating boolean;

begin
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- check mandatory parameters has been set
  --
  hr_api.mandatory_arg_error
    (p_api_name      => l_proc
     ,p_argument     => 'effective_date'
     ,p_argument_value  => p_effective_date);


  if (((p_nota_history_id is not null) and
        nvl(ota_nhs_shd.g_old_rec.duration_units,hr_api.g_varchar2) <>
        nvl(p_duration_units,hr_api.g_varchar2))
     or
       (p_nota_history_id is  null)) then

       hr_utility.set_location(' Leaving:'||l_proc, 20);
       --
       -- if status is not null then
       -- check if the status value exists in hr_lookups
    -- where lookup_type is 'FREQUENCY'
       --
       if p_duration_units is not null then
          if hr_api.not_exists_in_hr_lookups -- Bug 2478551
             (p_effective_date => p_effective_date
              ,p_lookup_type => 'OTA_DURATION_UNITS'
              ,p_lookup_code => p_duration_units) then
         fnd_message.set_name('OTA','OTA_13882_NHS_DURATION_INVALID');
               fnd_message.raise_error;
          end if;
           hr_utility.set_location(' Leaving:'||l_proc, 30);

       end if;

   end if;
 hr_utility.set_location(' Leaving:'||l_proc, 40);

end chk_duration_unit;

-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_comb_duration  >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_comb_duration
  (p_nota_history_id             in number
   ,p_duration             in number
   ,p_duration_units          in varchar2
   ,p_effective_date       in date) is

--
  l_proc  varchar2(72) := g_package ||'chk_comb_duration';
  l_api_updating boolean;

begin
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  if (p_duration is not null and
     p_duration_units is null ) or
     (p_duration is null and
     p_duration_units is not null ) then
       fnd_message.set_name('OTA','OTA_13881_NHS_COMB_INVALID');
               fnd_message.raise_error;

  end if;
 hr_utility.set_location(' Leaving:'||l_proc, 20);

end chk_comb_duration;

-- |---------------------------<  get_profile_value  >------------------------|
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Get Cross Business Group profile and Single Business Group profile
--
--  Prerequisites:
--    None
--
--  In Arguments:
--    None
--
--  out Arguments:
--    p_cross_business_group
--    p_single_busines_group_id
--
--  Post Success:
--    No error.
--
--  Post Failure:
--    An error is raised if the only one has value.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure get_profile_value
  (p_cross_business_group      out nocopy varchar2
   ,p_single_business_group_id    out nocopy varchar2)
IS

BEGIN
p_cross_business_group := FND_PROFILE.VALUE('HR_CROSS_BUSINESS_GROUP');
p_single_business_group_id  := FND_PROFILE.VALUE('OTA_HR_GLOBAL_BUSINESS_GROUP_ID');
END get_profile_value;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_effective_date               in date,
                          p_rec in ota_nhs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --

chk_organization_id(p_rec.nota_history_id
                  ,p_rec.organization_id
               ,p_rec.business_group_id
               ,p_effective_date);

chk_customer_id(p_rec.nota_history_id
               ,p_rec.customer_id
               ,p_effective_date);

chk_person_id (p_rec.nota_history_id
               ,p_rec.customer_id
               ,p_rec.organization_id
               ,p_rec.person_id
            ,p_rec.business_group_id
               ,p_effective_date);

chk_contact_id (p_rec.nota_history_id
               ,p_rec.customer_id
               ,p_rec.organization_id
               ,p_rec.contact_id
               ,p_effective_date);

chk_status(p_rec.nota_history_id
               ,p_rec.status
               ,p_effective_date);

chk_type(p_rec.nota_history_id
               ,p_rec.type
               ,p_effective_date);

chk_duration_unit(p_rec.nota_history_id
               ,p_rec.duration_units
               ,p_effective_date);

chk_comb_duration(p_rec.nota_history_id
            ,p_rec.duration
               ,p_rec.duration_units
               ,p_effective_date);


chk_df(p_rec);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_effective_date in date,
                          p_rec in ota_nhs_shd.g_rec_type) is
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
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );

chk_organization_id(p_rec.nota_history_id
                  ,p_rec.organization_id
               ,p_rec.business_group_id
               ,p_effective_date);

  chk_customer_id(p_rec.nota_history_id
               ,p_rec.customer_id
               ,p_effective_date);

  chk_person_id(p_rec.nota_history_id
               ,p_rec.customer_id
               ,p_rec.organization_id
               ,p_rec.person_id
            ,p_rec.business_group_id
               ,p_effective_date);

chk_contact_id(p_rec.nota_history_id
               ,p_rec.customer_id
               ,p_rec.organization_id
               ,p_rec.contact_id
               ,p_effective_date);

chk_status(p_rec.nota_history_id
               ,p_rec.status
               ,p_effective_date);

chk_type(p_rec.nota_history_id
               ,p_rec.type
               ,p_effective_date);

chk_duration_unit(p_rec.nota_history_id
               ,p_rec.duration_units
               ,p_effective_date);

chk_comb_duration(p_rec.nota_history_id
            ,p_rec.duration
               ,p_rec.duration_units
               ,p_effective_date);


  --
  chk_df(p_rec);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ota_nhs_shd.g_rec_type) is
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
end ota_nhs_bus;

/
