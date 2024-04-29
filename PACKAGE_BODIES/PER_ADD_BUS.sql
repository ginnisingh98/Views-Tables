--------------------------------------------------------
--  DDL for Package Body PER_ADD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ADD_BUS" as
/* $Header: peaddrhi.pkb 120.1.12010000.6 2009/04/13 08:33:06 sgundoju ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package    varchar2(33)	:= '  per_add_bus.';  -- Global package name
--
--  This variable indicates if payroll is installed under US legislation.
--  The function that returns this value is called in the validation procedures.
--  To prevent the identical sql from executing multiple times, this variable
--  is checked when the function is called and if not null, the sql is bypassed.
--
g_us_payroll varchar2(1) default null;
--
--
-- The following two global variables are only to be used by the
-- return_legislation_code function.
--
g_address_id       number        default null;
g_legislation_code varchar2(150) default null;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< set_called_from_form >------------------------|
-- ----------------------------------------------------------------------------
procedure set_called_from_form
   ( p_flag     in boolean ) as
begin
   g_called_from_form:=p_flag;
end;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_business_group_id >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that business_group_id value is valid.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_business_group_id
--  p_address_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if business_group_id is valid and if updating,
--   old_rec.business_group_id is null
--
-- Post Failure:
--   An application error is raised
--   if updating and old_rec.business_group_id is not null, or
--   business_group_id is not valid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_business_group_id
  (p_address_id            in     per_addresses.address_id%TYPE
  ,p_object_version_number in     per_addresses.object_version_number%TYPE
  ,p_person_id             in     per_addresses.person_id%TYPE
  ,p_business_group_id     in     per_addresses.business_group_id%TYPE
  )
      is
  --

  --
  l_proc          varchar2(72) := g_package||'chk_business_group_id';
  l_api_updating  boolean;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  if p_business_group_id is not null then
    hr_utility.set_location(l_proc, 10);
    --
    hr_api.validate_bus_grp_id(p_business_group_id);
    --
    --
    --If BUSINESS_GROUP_ID is specified, PERSON_ID must be specified
    --
    if p_person_id is null then
        --
        hr_utility.set_message(800, 'HR_289945_INV_PERSON_ID');
        hr_utility.raise_error;
        --
    end if;
    --
  end if;
    --
    l_api_updating    := per_add_shd.api_updating
                                (p_address_id  =>  p_address_id
                                ,p_object_version_number =>  p_object_version_number );
    --
    --UPDATE not allowed unless currently null(U)
    --
    if  (l_api_updating
         and nvl(per_add_shd.g_old_rec.business_group_id,hr_api.g_number) <> hr_api.g_number
         and per_add_shd.g_old_rec.business_group_id <> p_business_group_id ) then
       --
        hr_utility.set_message(800, 'HR_289947_INV_UPD_BG_ID');
        hr_utility.raise_error;
       --

    end if;
    --
  hr_utility.set_location('Leaving:'||l_proc, 40);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1  => 'PER_PREVIOUS_EMPLOYERS.BUSINESS_GROUP_ID'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 50);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,60);
end chk_business_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_person_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that a person id exists in table per_people_f.
--    - Validates that the business group of the address matches
--      the business group of the person.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_person_id
--    p_business_group_id
--
--  Post Success:
--    If a row does exist in per_people_f for the given person id then
--    processing continues.
--
--  Post Failure:
--    If a row does not exist in per_people_f for the given person id then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_person_id
  (p_address_id            in     per_addresses.address_id%TYPE
  ,p_object_version_number in     per_addresses.object_version_number%TYPE
  ,p_person_id             in     per_addresses.person_id%TYPE
  ,p_business_group_id     in     per_addresses.business_group_id%TYPE
  )
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_person_id';
  --
  l_api_updating      boolean;
  l_business_group_id number;
  --
  cursor csr_valid_pers is
         select business_group_id
           from per_all_people_f ppf
          where ppf.person_id = p_person_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person_id'
    ,p_argument_value => p_person_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Check if inserting or updating with modified values
  --
  l_api_updating := per_add_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number
         );
  --
  if ((l_api_updating and per_add_shd.g_old_rec.person_id <> p_person_id)
    or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 30);
    --
    -- Check that the Person ID is linked to a
    -- valid person on PER_PEOPLE_F
    --
    open csr_valid_pers;
    fetch csr_valid_pers into l_business_group_id;
    if csr_valid_pers%notfound then
      --
      close csr_valid_pers;
      hr_utility.set_message(801, 'HR_7298_ADD_PERSON_INVALID');
      hr_utility.raise_error;
      --
    else
      close csr_valid_pers;
      hr_utility.set_location(l_proc, 40);
      --
      -- Check that the business group of the person is the same as the
      -- business group of the address
      --
      if p_business_group_id <> l_business_group_id then
        --
        hr_utility.set_message(800, 'PER_52989_ADD_NOMATCH_BGP');
        hr_utility.raise_error;
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 42);
  --
  --UPDATE not allowed unless currently null(U)
  --
  if (l_api_updating
      and nvl(per_add_shd.g_old_rec.person_id,hr_api.g_number) <> hr_api.g_number
      and per_add_shd.g_old_rec.person_id <> p_person_id
     ) then
      --
        hr_utility.set_message(800, 'HR_289948_INV_UPD_PERSON_ID');
        hr_utility.raise_error;
      --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 45);
  --
  --If BUSINESS_GROUP_ID is specified, PERSON_ID must be specified
  --
  if p_business_group_id is not null and p_person_id is null then
      --
      hr_utility.set_message(800, 'HR_289945_INV_PERSON_ID');
      hr_utility.raise_error;
      --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 50);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PER_ADDRESSES.PERSON_ID'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_person_id;
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_party_id  >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that a party id exists in table hz_parties.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_party_id
--
--  Post Success:
--    If a row does exist in hz_parties for the given party id then
--    processing continues.
--
--  Post Failure:
--    If a row does not exist in hz_parties for the given party id then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_party_id
  (p_rec                in out nocopy per_add_shd.g_rec_type
  )
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_party_id';
  --
  l_exists            varchar2(1);
  --
  l_party_id     per_addresses.party_id%TYPE;
  l_party_id2    per_addresses.party_id%TYPE;
  --
  --
  -- cursor to check that the party_id matches person_id
  --
  cursor csr_get_party_id is
  select party_id
  from    per_all_people_f per
    where   per.person_id = p_rec.person_id
    and     p_rec.date_from
    between per.effective_start_date
    and     nvl(per.effective_end_date,hr_api.g_eot);
  --
  cursor csr_valid_party_id is
  select party_id
  from hz_parties hzp
  where hzp.party_id = p_rec.party_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  --
  if p_rec.person_id is not null then
    if hr_multi_message.no_all_inclusive_error
     (p_check_column1 => 'PER_ADDRESSES.PERSON_ID'
     ,p_check_column2 => 'PER_ADDRESSES.DATE_FROM'
     ) then
      --
      open csr_get_party_id;
      fetch csr_get_party_id into l_party_id;
      close csr_get_party_id;
      hr_utility.set_location(l_proc,20);
      if p_rec.party_id is not null then
        if p_rec.party_id <> nvl(l_party_id,-1) then
          hr_utility.set_message(800, 'HR_289343_PERSONPARTY_MISMATCH');
          hr_utility.set_location(l_proc,30);
          hr_multi_message.add
	  (p_associated_column1 => 'PER_ADDRESSES.PERSON_ID'
	  ,p_associated_column2 => 'PER_ADDRESSES.DATE_FROM'
	  ,p_associated_column3 => 'PER_ADDRESSES.PARTY_ID'
	  );
        end if;
      else
      --
      -- derive party_id from per_all_people_f using person_id
      --
        hr_utility.set_location(l_proc,50);
        p_rec.party_id := l_party_id;
      end if;
    end if;
  else
    if p_rec.party_id is null then
        hr_utility.set_message(800, 'HR_289341_CHK_PERSON_OR_PARTY');
        hr_utility.set_location(l_proc,60);
        hr_multi_message.add
        ( p_associated_column1 => 'PER_ADDRESSES.PARTY_ID'
	);
    else
      open csr_valid_party_id;
      fetch csr_valid_party_id into l_party_id2;
      if csr_valid_party_id%notfound then
        close csr_valid_party_id;
        hr_utility.set_message(800, 'PER_289342_PARTY_ID_INVALID');
        hr_utility.set_location(l_proc,70);
        hr_multi_message.add
        (p_associated_column1 => 'PER_ADDRESSES.PARTY_ID'
	);
      else
        --
        close csr_valid_party_id;
	--
      end if;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,100);
End chk_party_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_primary_flag >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the primary flag is either 'Y' or 'N'
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_primary_flag
--
--  Post Success:
--    If the value is valid then processing continues
--
--  Post Failure:
--    If the value is invalid then an error is raised.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_primary_flag
  (p_address_id            in     per_addresses.address_id%TYPE
  ,p_object_version_number in     per_addresses.object_version_number%TYPE
  ,p_primary_flag          in     per_addresses.primary_flag%TYPE
  )
is
  --
  l_proc           varchar2(72)  :=  g_package||'chk_primary_flag';
  --
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_primary_flag'
    ,p_argument_value => p_primary_flag
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Check if inserting or updating with modified values
  --
  l_api_updating := per_add_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number
         );
  --
  if ((l_api_updating and per_add_shd.g_old_rec.primary_flag <> p_primary_flag)
    or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 30);
    --
    -- Check that the value is 'Y' or 'N'
    --
    if p_primary_flag not in('Y','N') then
      --
      per_add_shd.constraint_error
        (p_constraint_name => 'PER_ADDR_PRIMARY_FLAG_CHK'
        );
      --
    end if;
    hr_utility.set_location(l_proc, 40);
    --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_primary_flag;
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_address_type >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that an address type exists in table hr_lookups
--    where lookup_type is 'ADDRESS_TYPE'
--    and enabled_flag is 'Y'
--    and effective_date is between the active dates (if they are not null).
--
--  Pre-conditions:
--    Effective_date must be valid.
--
--  In Arguments:
--    p_address_id
--    p_date_from
--    p_address_type
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    If a row does exist in hr_lookups for the given address code then
--    processing continues.
--
--  Post Failure:
--    If a row does not exist in hr_lookups for the given address code then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_address_type
  (p_address_id             in per_addresses.address_id%TYPE
  ,p_address_type           in per_addresses.address_type%TYPE
  ,p_date_from              in per_addresses.date_from%TYPE
  ,p_effective_date         in date
  ,p_object_version_number  in per_addresses.object_version_number%TYPE) is
  --
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'chk_address_type';
   l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'date_from'
    ,p_argument_value => p_date_from
    );
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for address type has changed
  --
  l_api_updating := per_add_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
       nvl(per_add_shd.g_old_rec.address_type, hr_api.g_varchar2) <>
       nvl(p_address_type, hr_api.g_varchar2)) or
      (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 2);
    --
    -- Checks that the value for address_type is
    -- valid and exists on hr_lookups within the
    -- specified date range
    --
    if p_address_type is not null then
       --
       -- Bug 1472162.
       --
--       if hr_api.not_exists_in_hr_lookups
       if hr_api.not_exists_in_leg_lookups
         (p_effective_date => p_effective_date
         ,p_lookup_type    => 'ADDRESS_TYPE'
         ,p_lookup_code    => p_address_type
         ) then
         --
         --  Error: Invalid address type.
         hr_utility.set_message(801, 'HR_7299_ADD_TYPE_INVALID');
         hr_utility.raise_error;
       end if;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 4);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'PER_ADDRESSES.ADDRESS_TYPE'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc,5);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,6);
--
end chk_address_type;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_country >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that a country code exists in table fnd_territories
--    for US, GB and GENERIC address styles.
--
--  Pre-conditions:
--    Style (p_style) must be valid.
--
--  In Arguments:
--    p_country
--    p_address_id
--    p_object_version_number
--
--  Post Success:
--    If a row does exist in fnd_territories for the given country code then
--    processing continues.
--
--  Post Failure:
--    If a row does not exist in fnd_territories for the given country code then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_country
  (p_address_id            in per_addresses.address_id%TYPE
  ,p_style                 in per_addresses.style%TYPE
  ,p_country               in per_addresses.country%TYPE
  ,p_object_version_number in per_addresses.object_version_number%TYPE)
   is
--
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'chk_country';
   l_api_updating   boolean;
--
   cursor csr_valid_ctry is
     select null
     from fnd_territories ft
     where ft.territory_code = p_country;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for country has changed
  --
  l_api_updating := per_add_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
       nvl(per_add_shd.g_old_rec.country, hr_api.g_varchar2) <>
       nvl(p_country, hr_api.g_varchar2)) or
      (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 2);
    --
    -- Checks that value for country is a valid
    -- country on fnd_territories
    --
    if p_style = 'US' or
       p_style = 'GB' then
  -- Bug 1677965
  --       (p_style = 'JP' and p_country is not null) then
      open csr_valid_ctry;
      fetch csr_valid_ctry into l_exists;
      if csr_valid_ctry%notfound then
        close csr_valid_ctry;
        hr_utility.set_message(801, 'HR_7300_ADD_COUNTRY_INVALID');
        hr_utility.raise_error;
      end if;
      close csr_valid_ctry;
    end if;
  end if;
--
hr_utility.set_location(' Leaving:'|| l_proc, 3);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_ADDRESSES.COUNTRY'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc,4);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,5);
--
end chk_country;
--
--  ---------------------------------------------------------------------------
--  |------------------------<  chk_date_to >---------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that date to (may be null) is greater than or equal to date
--    from.
--
--  Pre-conditions:
--    Format of p_date_from and p_date_to must be correct.
--
--  In Arguments:
--    p_address_id
--    p_date_from
--    p_date_to
--    p_object_version_number
--
--  Post Success:
--    If a given date to is greater than or equal to a given date from then
--    processing continues.
--
--  Post Failure:
--    If a given date to is not greater than or equal to a given date from then
--    an application error will be raised and processing is terminated.
--
--  Access status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_date_to
  (p_address_id             in per_addresses.address_id%TYPE
  ,p_date_from              in per_addresses.date_from%TYPE
  ,p_date_to                in per_addresses.date_to%TYPE
  ,p_object_version_number  in per_addresses.object_version_number%TYPE)
   is
--
   l_exists           varchar2(1);
   l_proc             varchar2(72)  :=  g_package||'chk_date_to';
   l_date_to          date;
   l_api_updating     boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'date_from'
    ,p_argument_value => p_date_from
    );
  if hr_multi_message.no_all_inclusive_error
     (p_check_column1      => 'PER_ADDRESSES.DATE_FROM'
     ,p_check_column2      => 'PER_ADDRESSES.DATE_TO'
     ,p_associated_column1 => 'PER_ADDRESSES.DATE_FROM'
     ,p_associated_column2 => 'PER_ADDRESSES.DATE_TO'
     ) then
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The value for date to has changed
    --
    l_api_updating := per_add_shd.api_updating
           (p_address_id             => p_address_id
           ,p_object_version_number  => p_object_version_number);
  --
    if ((l_api_updating and
         nvl(per_add_shd.g_old_rec.date_to, hr_api.g_eot) <>
         nvl(p_date_to, hr_api.g_eot)) or
        (NOT l_api_updating)) then
      --
      hr_utility.set_location(l_proc, 2);
      --
      -- Checks that the value for date_to is greater than or
      -- equal to the corresponding value for date_from for the
      -- same record
      --
      if nvl(p_date_to, hr_api.g_eot) < p_date_from then
        hr_utility.set_message(801, 'HR_7301_ADD_DATE_TO_LATER');
        hr_utility.raise_error;
      end if;
      --
    end if;
    --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_same_associated_columns =>  'Y'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc,4);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,5);
--
end chk_date_to;
--
--  ---------------------------------------------------------------------------
--  |------------------------<  chk_date_from >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that date from is less than or equal to date to (may be null).
--
--  Pre-conditions:
--    Format of p_date_from and p_date_to must be correct.
--
--  In Arguments:
--    p_address_id
--    p_date_from
--    p_date_to
--    p_object_version_number
--
--  Post Success:
--    If a given date from is less than or equal to a given date to then
--    processing continues.
--
--  Post Failure:
--    If a given date from is not less than or equal to a given date to then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_date_from
  (p_address_id             in per_addresses.address_id%TYPE
  ,p_date_from              in per_addresses.date_from%TYPE
  ,p_date_to                in per_addresses.date_to%TYPE
  ,p_object_version_number  in per_addresses.object_version_number%TYPE)
   is
--
   l_exists           varchar2(1);
   l_proc             varchar2(72)  :=  g_package||'chk_date_from';
   l_api_updating     boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'date_from'
    ,p_argument_value => p_date_from
    );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date_from value has changed
  --
  l_api_updating := per_add_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and per_add_shd.g_old_rec.date_from <> p_date_from) or
      (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 2);
    --
    -- Check that the date_from values is less than
    -- or equal to the date_to value for the current
    -- record
    --
    if p_date_from > nvl(p_date_to, hr_api.g_eot) then
      hr_utility.set_message(801, 'HR_7303_ADD_DATE_FROM_EARLIER');
      hr_utility.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_ADDRESSES.DATE_FROM'
    ,p_associated_column2 =>  'PER_ADDRESSES.DATE_TO'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc,4);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,5);
--
end chk_date_from;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_date_comb >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--
--    Validates date_to/date_from for a primary address so that it
--    does not overlap with the date range of another primary address.
--
--    Validates that the date range of a non-primary co-exists with the
--    date range of a primary address.
--
--    Validate that primary addresses are contiguous.
--
--    Validates that the address_type for an address (primary or non)
--    is unique for a person with the given date range.
--
--  Pre-conditions:
--    Format of p_date_from and p_date_to must be correct.
--
--  In Arguments:
--    p_address_id
--    p_address_type
--    p_primary_flag
--    p_date_from
--    p_date_to
--    p_person_id
--    p_object_version_number
--
--  Post Success:
--    If no overlaps occur with either the address_type or primary flag then
--    processing continues.
--
--    If all non-primary addresses exist during the date range of one or
--    more contiguous primary addresses then processing continues.
--
--    If all primary addresses are contiguous then processing continues.
--
--  Post Failure:
--    If the date_to/date_from values cause a primary address to overlap
--    within the date range of another primary address for the same person,
--    or the address_type for either a primary or non-primary address is
--    not uniques within a given date range for a person then an application
--    error is raised and processing is terminated.
--
--    If an insert/update of a non-primary address is atempted where the
--    date range of the non-primary address does not co-exist with that of
--    a primary address then an application error is raised and processing
--    is terminated.
--
--    If an insert/update of a primary address causes the primary address
--    pattern to be non-contiguous then an application error is raised and
--    processing is terminated.
--
--  Access status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_date_comb
  (p_address_id            in     per_addresses.address_id%TYPE
  ,p_address_type          in     per_addresses.address_type%TYPE
  ,p_date_from             in     per_addresses.date_from%TYPE
  ,p_date_to               in     per_addresses.date_to%TYPE
  ,p_person_id             in     per_addresses.person_id%TYPE
  ,p_primary_flag          in     per_addresses.primary_flag%TYPE
  ,p_object_version_number in     per_addresses.object_version_number%TYPE
  ,p_prflagval_override    in     boolean      default false
  ,p_party_id              in     per_addresses.party_id%TYPE  -- HR/TCA merge
  )
is
  --
  l_proc             varchar2(72)  :=  g_package||'chk_date_comb';
  --
  l_exists           varchar2(1);
  l_date_to          date;
  c_date_from        date;
  c_date_to          date;
  l_no_other_recs    boolean := FALSE;
  l_recs_before      boolean := FALSE;
  l_recs_after       boolean := FALSE;
  l_good_recs        number  := 0;
  l_api_updating     boolean;
  l_action_eff_date date;
  l_address_count number;
  l_legislation_code   varchar2(30); --- Fix For Bug # 7418570

  cursor csr_assignments(p_person_id in number) is
    select assignment_id
      from per_all_assignments_f
     where person_id = p_person_id;
  --
  cursor csr_pay_roll_actions(p_assignment_id in number) is
    select payroll_action_id
      from pay_assignment_actions
     where assignment_id = p_assignment_id;
  --
  -- Added below cursor for bug#8278906
  cursor c_payroll_actions(p_payroll_action_id in number) is
          select effective_date
            from pay_payroll_actions
           where payroll_action_id = p_payroll_action_id
             and ACTION_TYPE NOT in ('BEE','X');
  --
  cursor csr_dup_add_type_exists is
    select null
    from   per_addresses pa
    where  p_date_from <= nvl(pa.date_to, hr_api.g_eot)
    and    l_date_to >= pa.date_from
    and    pa.address_type = p_address_type
    and    (pa.person_id = p_person_id OR   -- HR/TCA merge
            (pa.party_id = p_party_id  and p_person_id is null)) -- #3406505
    and   (p_address_id is null
    or    (p_address_id is not null
    and    pa.address_id <> p_address_id));
  --
  cursor csr_dup_prim_flag is
    select null
    from   per_addresses pa
    where  p_date_from <= nvl(pa.date_to, hr_api.g_eot)
    and    l_date_to >= pa.date_from
    and    pa.primary_flag = 'Y'
    and    (pa.person_id = p_person_id OR  --
            (pa.party_id = p_party_id  and p_person_id is null)) -- HR/TCA merge -- #3406505
    and   (p_address_id is null
    or    (p_address_id is not null
    and    pa.address_id <> p_address_id));
  --
  cursor csr_no_primary is
    select null
    from   per_addresses pa
    where  p_date_from  >= pa.date_from
    and    exists (select null
                    from   per_addresses pa2
                    where  nvl(pa2.date_to, hr_api.g_eot) >= l_date_to
                    and    (pa2.person_id = p_person_id OR --
                            (pa2.party_id = p_party_id and p_person_id is null)) -- HR/TCA merge -- #3406505
                    and    pa2.primary_flag = 'Y')
    and    pa.primary_flag = 'Y'
    and    (pa.person_id    = p_person_id  OR  -- HR/TCA merge
            (pa.party_id     = p_party_id and p_person_id is null));  --#3406505
  --
  -- Bug 2933498 starts here.
  -- Modified the cursor csr_invalid_non_prim.
  cursor csr_invalid_non_prim is
  select null
  from   sys.dual
  where exists(select null
               from   per_addresses pa
               where ((pa.date_from < p_date_from
                       and nvl(pa.date_to, hr_api.g_eot) >=
                       (select date_from
                        from per_addresses
                        where address_id = p_address_id)
                       and p_date_from <> (select date_from
                                           from per_addresses
                                           where address_id = p_address_id) )
                     or (nvl(pa.date_to, hr_api.g_eot) >
                         nvl(p_date_to, hr_api.g_eot)
                         and pa.date_from <=(select nvl(date_to, hr_api.g_eot)
                                             from per_addresses
                                             where address_id = p_address_id)
                         and nvl(p_date_to, hr_api.g_eot) <>
                             (select nvl(date_to, hr_api.g_eot)
                              from per_addresses
                              where address_id = p_address_id) ))
               and   pa.primary_flag = 'N'
               and   (pa.person_id = p_person_id OR
                     (pa.party_id  = p_party_id and p_person_id is null)));-- HR/TCA merge --#3406505
  -- Bug 2933498 ends here.
  --
  cursor csr_check_other_addresses is
    select null
    from   sys.dual
    where exists(select null
                from   per_addresses pa
                where  (pa.person_id = p_person_id OR
                        (pa.party_id  = p_party_id and p_person_id is null))  -- HR/TCA merge --#3406505
                and    pa.primary_flag = 'Y'
                and    (p_address_id is null
                or     (p_address_id is not null
                and     p_address_id <> pa.address_id)));
  --
  cursor csr_chk_contig_add_before is
    select pa.date_from,
           pa.date_to
    from   per_addresses pa
    where  (pa.person_id = p_person_id OR
            (pa.party_id  = p_party_id and p_person_id is null))  -- HR/TCA merge --#3406505
    and    pa.primary_flag = 'Y'
    and    pa.date_to < p_date_from
    and    (p_address_id is null
    or     (p_address_id is not null
    and     p_address_id <> pa.address_id));
  --
  cursor csr_chk_contig_add_after is
    select pa.date_from, pa.date_to
    from   per_addresses pa
    where  (pa.person_id = p_person_id OR
            (pa.party_id  = p_party_id and p_person_id is null))  -- HR/TCA merge --#3406505
    and    pa.primary_flag = 'Y'
    and    pa.date_from > p_date_to
    and    (p_address_id is null
    or     (p_address_id is not null
    and     p_address_id <> pa.address_id));
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'date_from'
    ,p_argument_value => p_date_from
    );
  --
  if p_party_id is null then  -- HR/TCA merge
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person_id'
    ,p_argument_value => p_person_id
    );
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'primary_flag'
    ,p_argument_value => p_primary_flag
    );
  hr_utility.set_location(l_proc, 20);
  if hr_multi_message.no_all_inclusive_error
  (p_check_column1 => 'PER_ADDRESSES.DATE_FROM'
  ,p_check_column2 => 'PER_ADDRESSES.DATE_TO'
  ,p_check_column3 => 'PER_ADDRESSES.PERSON_ID'
  ,p_check_column4 => 'PER_ADDRESSES.PARTY_ID'
  ) then
    --
    -- Set the DATE_TO to entered value or the end of time
    --
    l_date_to := nvl(p_date_to, hr_api.g_eot);
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The value for date_to/date_from has changed
    --
    l_api_updating := per_add_shd.api_updating
           (p_address_id             => p_address_id
           ,p_object_version_number  => p_object_version_number
           );
    --
    if ((l_api_updating and
         per_add_shd.g_old_rec.date_from <> p_date_from) or
        (nvl(per_add_shd.g_old_rec.date_to, hr_api.g_eot) <>
         nvl(p_date_to, hr_api.g_eot)) or
        (nvl(per_add_shd.g_old_rec.address_type, hr_api.g_varchar2) <>
         nvl(p_address_type, hr_api.g_varchar2))
      or
        (NOT l_api_updating))
      then
      hr_utility.set_location(l_proc, 30);
      --
      -- For all addresses
      -- =================
      -- Checks that the date_from, date_to values for a given address
      -- do not cause an overlap of address_type value between two
      -- addresses for the same person within a given date range.
      --
      if (nvl(per_add_shd.g_old_rec.address_type, hr_api.g_varchar2) <>
         nvl(p_address_type, hr_api.g_varchar2)) or
         (NOT l_api_updating) then
         --
         if p_address_type is not null then
           open csr_dup_add_type_exists;
           fetch csr_dup_add_type_exists into l_exists;
           if csr_dup_add_type_exists%found then
             close csr_dup_add_type_exists;
             hr_utility.set_message(801, 'HR_51139_ADD_TYPE_ALR_EXIST');
             hr_multi_message.add
	     (p_associated_column1 => 'PER_ADDRESSES.DATE_FROM'
	     ,p_associated_column2 => 'PER_ADDRESSES.DATE_TO'
    	     ,p_associated_column3 => 'PER_ADDRESSES.PERSON_ID'
             ,p_associated_column4 => 'PER_ADDRESSES.PARTY_ID'
             ,p_associated_column5 => 'PER_ADDRESSES.ADDRESS_TYPE'
	     );
	   else
	     --
             close csr_dup_add_type_exists;
	     --
	   end if;
        end if;
      end if;
      --
      hr_utility.set_location(l_proc, 4);
      --
      -- For primary addresses only
      -- ==========================
      --
      --
      if p_primary_flag = 'Y' then
        --
        -- Check if the primary flag check is to be overriden
        --
        if not p_prflagval_override then
          --
          -- Checks that the date_from, date_to values for a given address
          -- do not cause an an overlap between two primary
          -- addresses for the same person within a given date range.
          --
          open csr_dup_prim_flag;
          fetch csr_dup_prim_flag into l_exists;
          if csr_dup_prim_flag%found then
            close csr_dup_prim_flag;
            hr_utility.set_message(801, 'HR_7327_ADD_PRIMARY_ADD_EXISTS');
            hr_multi_message.add
            (p_associated_column1 => 'PER_ADDRESSES.DATE_FROM'
            ,p_associated_column2 => 'PER_ADDRESSES.DATE_TO'
            ,p_associated_column3 => 'PER_ADDRESSES.PERSON_ID'
            ,p_associated_column4 => 'PER_ADDRESSES.PARTY_ID'
            );
          else
            --
            close csr_dup_prim_flag;
	    --
          end if;
          --
        end if;
        --
        --
        -- Verify that the primary address does not break
        -- the contiguous nature of the primary address
        --
        -- Firstly check whether any other addresses exist
        -- for a person
        --
        open csr_check_other_addresses;
        fetch csr_check_other_addresses into l_exists;
        if csr_check_other_addresses%found then
          --
          -- Check addresses before
          --
          close csr_check_other_addresses;
          open csr_chk_contig_add_before;
          loop
          fetch csr_chk_contig_add_before into c_date_from, c_date_to;
          exit when csr_chk_contig_add_before%notfound;
            l_recs_before := TRUE;
            if c_date_to = p_date_from-1 then
              l_good_recs := l_good_recs + 1;
            end if;
          end loop;
          close csr_chk_contig_add_before;
          --
          -- Check addresses after
          --
          open csr_chk_contig_add_after;
          loop
          fetch csr_chk_contig_add_after into c_date_from, c_date_to;
          exit when csr_chk_contig_add_after%notfound;
            l_recs_after := TRUE;
            if c_date_from = p_date_to+1 then
              l_good_recs := l_good_recs + 1;
            end if;
          end loop;
          close csr_chk_contig_add_after;
          --
        else
          close csr_check_other_addresses;
          l_no_other_recs := TRUE;
        end if;
        --
        -- Check for contiguity errors
        --
        if not l_no_other_recs then
          if ((l_good_recs = 1
              and l_recs_before
              and l_recs_after)
          or
             (l_good_recs < 1)) then
            hr_utility.set_message(801, 'HR_51030_ADDR_PRIM_GAP');
            hr_multi_message.add
            (p_associated_column1 => 'PER_ADDRESSES.DATE_FROM'
            ,p_associated_column2 => 'PER_ADDRESSES.DATE_TO'
            ,p_associated_column3 => 'PER_ADDRESSES.PERSON_ID'
            ,p_associated_column4 => 'PER_ADDRESSES.PARTY_ID'
            );
          end if;
        end if;
        --
        -- Check if the primary flag check is to be overriden
        --
        if not p_prflagval_override then
          --
          -- Check that on UPDATE of date values
          -- for a Primary address that no Non-primary
          -- address is left without a corresponding
          -- primary
          --
          if ((per_add_shd.g_old_rec.date_from <> p_date_from) or
              (nvl(per_add_shd.g_old_rec.date_to, hr_api.g_eot) <>
              (nvl(p_date_to, hr_api.g_eot)))) and
             p_address_id is not null then
             open csr_invalid_non_prim;
             fetch csr_invalid_non_prim into l_exists;
             if csr_invalid_non_prim%found then
               close csr_invalid_non_prim;
               hr_utility.set_message(801, 'HR_7302_ADD_PRIMARY_DATES');
               hr_multi_message.add
               (p_associated_column1 => 'PER_ADDRESSES.DATE_FROM'
               ,p_associated_column2 => 'PER_ADDRESSES.DATE_TO'
               ,p_associated_column3 => 'PER_ADDRESSES.PERSON_ID'
               ,p_associated_column4 => 'PER_ADDRESSES.PARTY_ID'
               );
             else
	       --
               close csr_invalid_non_prim;
               --
             end if;
          --
	  end if;
        --
        end if;
        --
      else -- if PRIMARY_FLAG = 'N'
        --
        -- For non-primary addresses only
        -- ==============================
        -- Checks that a primary address must
        -- exist during the date range of a
        -- non-primary address
        --
        open csr_no_primary;
        fetch csr_no_primary into l_exists;
        if csr_no_primary%notfound then
          close csr_no_primary;
          hr_utility.set_message(801, 'HR_7302_ADD_PRIMARY_DATES');
          hr_multi_message.add
          (p_associated_column1 => 'PER_ADDRESSES.DATE_FROM'
          ,p_associated_column2 => 'PER_ADDRESSES.DATE_TO'
          ,p_associated_column3 => 'PER_ADDRESSES.PERSON_ID'
          ,p_associated_column4 => 'PER_ADDRESSES.PARTY_ID'
          );
        else
          --
          close csr_no_primary;
          --
        end if;
        --
      end if;
      --
    end if;
    --

--- Fix For Bug # 7418570 Starts ---
if l_api_updating then
l_legislation_code := PER_ADD_BUS.return_legislation_code(P_ADDRESS_ID => P_ADDRESS_ID);
end if;
--- Fix For Bug # 7418570 Ends ---

--- Fix For Bug # 7418570 added extra restriction clause for Legislation Code in the below IF condition ---
    if l_api_updating and p_primary_flag = 'Y' and l_legislation_code = 'US' then
      for assCursor in csr_assignments(p_person_id) loop
        for actionCursor in csr_pay_roll_actions(assCursor.assignment_id) loop
--- Fix for Bug # 8278906 .Used cursor c_payroll_actions instead of below SELECT query ---
--          /*select effective_date
--          into l_action_eff_date
--          from pay_payroll_actions
--          where payroll_action_id = actionCursor.payroll_action_id;*/
          for payrollCursor in c_payroll_actions(actionCursor.payroll_action_id) loop
              l_action_eff_date := payrollCursor.effective_date;
--- Fix for Bug # 8278906 Ends ---
            if p_date_from > l_action_eff_date
            then
              select count(*)
                into l_address_count
                from per_addresses
                where person_id = p_person_id
                and address_id <> p_address_id
                and l_action_eff_date between date_from
                                     and nvl(date_to,l_action_eff_date);
              if l_address_count = 0 then
               hr_utility.set_message(800, 'PER_PAYROLL_EXISTS');
              hr_multi_message.add();
              end if;
            end if;
          end loop;
        end loop;
      end loop;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 5);
end chk_date_comb;
--
--  ---------------------------------------------------------------------------
--  |-----------------------------<  chk_style >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates:
--      -  a flex structure exists for a given style.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_style
--
--  Post Success:
--    Processing continues if:
--      - a flex structure does exist in fnd_descr_flex_contexts for the given
--        territory code.
--
--  Post Failure:
--    An application error is raised and processing terminates if:
--      - a flex structure does not exist in fnd_descr_flex_contexts for the
--        given territory code.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_style
  (p_style               in varchar2)
   is
--
   l_exists         varchar2(1);
   l_token          varchar2(20);
   l_error          exception;
   l_proc           varchar2(72)  :=  g_package||'chk_style';
--
   --
   -- 70.2 change c start.
   --
   cursor csr_valid_flex_struc is
     select null
     from fnd_descr_flex_contexts
     where descriptive_flexfield_name  = 'Address Structure'
     and descriptive_flex_context_code = p_style
     and enabled_flag                  = 'Y'
     and application_id                = 800;
   --
   -- 70.2 change c end.
   --
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'style'
    ,p_argument_value => p_style
    );
  hr_utility.set_location(l_proc, 2);
  --
  -- Checks that the flex structure for the style
  -- selected exists in fnd_descr_flex_contents
  --
  open csr_valid_flex_struc;
  fetch csr_valid_flex_struc into l_exists;
  if csr_valid_flex_struc%notfound then
    close csr_valid_flex_struc;
    hr_utility.set_message(801, 'HR_7304_ADD_NO_FORMAT');
    hr_utility.raise_error;
  end if;
  close csr_valid_flex_struc;
  hr_utility.set_location(l_proc, 3);
    --
  hr_utility.set_location(' Leaving:'|| l_proc, 4);
exception
  when app_exception.application_exception then
   if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_ADDRESSES.STYLE'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc,5);
      raise;
    end if;
    -- Call to raise any errors on multi-message list
    -- Taking STYLE as an important parameter.
    hr_multi_message.end_validation_set;
    hr_utility.set_location(' Leaving:'||l_proc,6);
--
end chk_style;
--
--  ---------------------------------------------------------------------------
--  |----------------------<  chk_style_null_attr >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates the columns that should not be populated if address style is
--    'GB', 'US' or 'GENERIC'.
--
--  Pre-conditions:
--    Style (p_style) must be valid.
--
--  In Arguments:
--    p_style
--    p_region_2
--    p_region_3
--    p_telephone_number_3
--
--  Post Success:
--    If the style structure meets the 'GB', 'US' and 'GENERIC'
--    requirements (in terms of column usage) then processing continues.
--
--  Post Failure:
--    If the style structure does not meet the 'GB', 'US' and 'GENERIC'
--    requirements (in terms of column usage) then an application error is
--    raised and processing terminates.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_style_null_attr
  (p_address_id            in number
  ,p_object_version_number in number
  ,p_style                 in varchar2
  ,p_region_2              in varchar2
  ,p_region_3              in varchar2
  ,p_telephone_number_3    in varchar2
  )
 is
--
   l_token          varchar2(20);
   l_error          exception;
   l_api_updating   boolean;
   l_proc           varchar2(72)  :=  g_package||'chk_style_null_attr';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check 'GB' address style
  --
  if p_style = 'GB' then
    if p_region_2 is not null then
      if hr_multi_message.no_exclusive_error
         (p_check_column1 => 'PER_ADDRESSES.REGION_2') then
        --
	l_token := 'region_2';
        raise l_error;
        --
      end if;
    elsif p_region_3 is not null then
      l_token := 'region_3';
      raise l_error;
    elsif p_telephone_number_3 is not null then
      l_token := 'telephone_number_3';
      raise l_error;
    end if;
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- Check 'US' address style
  --
  elsif p_style = 'US' then
    --
    -- Check if region 3 is set but is unchanged on update
    --
    l_api_updating := per_add_shd.api_updating
                        (p_address_id             => p_address_id
                        ,p_object_version_number  => p_object_version_number
                        );
    --
    if p_region_3 is not null
      and nvl(per_add_shd.g_old_rec.region_3, hr_api.g_varchar2)
          = nvl(p_region_3, hr_api.g_varchar2)
    then
      --
      null;
      --
    elsif p_region_3 is not null then
      --
      l_token := 'region_3';
      raise l_error;
      --
    end if;
    --
    -- Check if telephone number 3 is set but is unchanged on update
    --
    if p_telephone_number_3 is not null
      and nvl(per_add_shd.g_old_rec.telephone_number_3, hr_api.g_varchar2)
          = nvl(p_telephone_number_3, hr_api.g_varchar2)
    then
      --
      null;
      --
    elsif p_telephone_number_3 is not null then
      --
      l_token := 'telephone_number_3';
      raise l_error;
      --
    end if;
    --
    hr_utility.set_location(l_proc, 3);
  --
  -- Check 'GENERIC' address style
  --
  elsif p_style = 'GENERIC' then
    if p_telephone_number_3 is not null then
      l_token := 'telephone_number_3';
      raise l_error;
    end if;
  end if;
  --
  exception
    when l_error then
       hr_utility.set_message(801, 'HR_7324_ADD_ADD_ATTRIBUTE_NULL');
       hr_utility.set_message_token('ARGUMENT', l_token);
       hr_multi_message.add(
        p_associated_column1 =>
	            (per_add_shd.g_tab_nam || '.' || upper(l_token))
       );
    when others then
       raise;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 4);
end chk_style_null_attr;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_address_line1 >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that address line 1 is not null from US and GB styles.
--
--  Pre-conditions:
--    Style (p_style) must be valid.
--
--  In Arguments:
--    p_address_id
--    p_style
--    p_address_line1
--    p_object_version_number
--
--  Post Success:
--    If address style is 'US' or 'GB' and address line 1 is not null,
--    processing continues.
--
--  Post Failure:
--    If address style is 'US' or 'GB' and address line 1 is null, an
--    application error is raised and processing terminates.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_address_line1
  (p_address_id             in per_addresses.address_id%TYPE
  ,p_style                  in per_addresses.style%TYPE
  ,p_address_line1          in per_addresses.region_2%TYPE
  ,p_object_version_number  in per_addresses.object_version_number%TYPE)
   is
--
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'chk_address_line1';
   l_api_updating   boolean;

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'style'
    ,p_argument_value => p_style
    );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for address_line1 has changed
  --
  l_api_updating := per_add_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
       nvl(per_add_shd.g_old_rec.address_line1, hr_api.g_varchar2) <>
       nvl(p_address_line1, hr_api.g_varchar2)) or
      (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 2);
    --
    -- Check that value for address_line1 is not null for 'US' and 'GB'
    -- style.
    --
    if p_style = 'GB' or
       p_style = 'US' then
      --
      hr_utility.set_location(l_proc, 3);
      --
      if p_address_line1 is null then
      --
      hr_utility.set_message(801, 'HR_51233_ADD_ADD_LINE1_REQ');
      hr_utility.raise_error;
      end if;
    --
    end if;
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 5);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_ADDRESSES.ADDRESS_LINE1'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc,6);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,7);
--
end chk_address_line1;
--
-- ----------------------------------------------------------------------------
-- |------------------------<chk_address1_towncity_comb  >--------------------|
-- ----------------------------------------------------------------------------
/* Bug 1677965
procedure chk_address1_towncity_comb(
  p_business_group_id      in number,
  p_address_id             in per_addresses.address_id%TYPE,
  p_object_version_number  in per_addresses.object_version_number%TYPE,
  p_town_or_city           in out nocopy per_addresses.town_or_city%type,
  p_address_line1          in out nocopy per_addresses.address_line1%type,
  p_region_1               in out nocopy per_addresses.region_1%type) is

--	p_town_or_city	===> district_code
--	p_address_line1	===> address_line1
--	p_region_1			===> address_line1_kana

  l_legislation_code per_business_groups.legislation_code%TYPE;
  l_town_or_city     per_addresses.town_or_city%type;
  l_address_line1    per_addresses.address_line1%type;
  l_region_1         per_addresses.region_1%type;
  l_sql_cursor       integer;            -- Dynamic sql cursor
  l_dynamic_sql      varchar2(2000);     -- Dynamic sql text
  l_rows             integer;            -- No of rows returned

  l_api_updating     boolean;
  l_proc             varchar2(72) := g_package||'chk_address1_towncity_comb';

  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
-- Bug 885806
-- dbms_output.put_line('Top of dynamic sql . . .');
   hr_utility.trace('Top of dynamic sql . . .');
  open csr_bg;
  fetch csr_bg into l_legislation_code;

  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for town_or_city, address_line1, or region_1 have changed
  --
  l_api_updating := per_add_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);

  if (   (l_legislation_code = 'JP')
          and
         (  (l_api_updating and
              (nvl(per_add_shd.g_old_rec.town_or_city, hr_api.g_varchar2) <>
               nvl(p_town_or_city, hr_api.g_varchar2) or
               nvl(per_add_shd.g_old_rec.address_line1, hr_api.g_varchar2)<>
               nvl(p_address_line1, hr_api.g_varchar2) or
               nvl(per_add_shd.g_old_rec.region_1, hr_api.g_varchar2)     <>
               nvl(p_region_1, hr_api.g_varchar2)))
             or
            (NOT l_api_updating))
     ) then

    hr_utility.set_location(l_proc, 2);
    --
    -- p_town_or_city(district_code) is not null
    --
    if p_town_or_city is not NULL then
      hr_utility.set_location(l_proc, 3);

      l_dynamic_sql  := 'select  t.address_line_1, '                        ||
                        '        t.address_line_1_kana '                    ||
                        'from    per_jp_address_lookups t '                ||
                        'where   t.district_code = :p_town_or_city';

      --
      -- Dynamic sql steps:
      -- ==================
      -- 1. Open dynamic sql cursor
      -- 2. Parse dynamic sql
      -- 3. Bind dynamic sql variables
      -- 4. Define dynamic sql columns
      -- 5. Execute and fetch dynamic sql
      --
      Hr_Utility.Set_Location(l_proc, 6);
      l_sql_cursor := dbms_sql.open_cursor;                         -- Step 1
      --
      Hr_Utility.Set_Location(l_proc, 10);
      dbms_sql.parse(l_sql_cursor, l_dynamic_sql, dbms_sql.v7);     -- Step 2
      --
      Hr_Utility.Set_Location(l_proc, 15);
      dbms_sql.bind_variable(l_sql_cursor,                          -- Step 3
                         ':p_town_or_city', p_town_or_city);

      Hr_Utility.Set_Location(l_proc, 20);
      dbms_sql.define_column(l_sql_cursor, 1, l_address_line1, 60); -- Step 4
      dbms_sql.define_column(l_sql_cursor, 2, l_region_1, 70);
      --
      Hr_Utility.Set_Location(l_proc, 30);
      l_rows := dbms_sql.execute_and_fetch(l_sql_cursor, false);    -- Step 5

      if l_rows = 0 then
        dbms_sql.close_cursor(l_sql_cursor);
        hr_utility.set_message(801, 'HR_72028_ADD_INVALID_DIST_CODE');
        hr_utility.raise_error;

      elsif l_rows = 1 then
        Hr_Utility.Set_Location(l_proc, 35);
        dbms_sql.column_value(l_sql_cursor, 1, l_address_line1);
        if p_address_line1 is not null and
           p_address_line1 <> l_address_line1 then

          dbms_sql.close_cursor(l_sql_cursor);
          hr_utility.set_message(801, 'HR_72029_ADD_INVALID_LINE1');
          hr_utility.raise_error;
        end if;
        p_address_line1 := l_address_line1;

      else
        dbms_sql.close_cursor(l_sql_cursor);
        hr_utility.set_message(801, 'HR_72030_ADD_OVERRAP_ROWS');
        hr_utility.set_message_token('TABLE_NAME', 'per_jp_address_lookups');
        hr_utility.raise_error;
      end if;

    elsif p_address_line1 is not NULL then
      hr_utility.set_location(l_proc, 4);

      l_dynamic_sql  :=
          'select  t.district_code,'                                     ||
          '        t.address_line_1_kana '                                ||
          'from    per_jp_address_lookups t '                            ||
          'where   t.address_line_1 = :p_address_line1';


      -- Dynamic sql steps:
      -- ==================
      -- 1. Open dynamic sql cursor
      -- 2. Parse dynamic sql
      -- 3. Bind dynamic sql variables
      -- 4. Define dynamic sql columns
      -- 5. Execute and fetch dynamic sql
      --
      Hr_Utility.Set_Location(l_proc, 6);
      l_sql_cursor := dbms_sql.open_cursor;                         -- Step 1
      --
      Hr_Utility.Set_Location(l_proc, 10);
      dbms_sql.parse(l_sql_cursor, l_dynamic_sql, dbms_sql.v7);     -- Step 2
      --
      Hr_Utility.Set_Location(l_proc, 15);
      dbms_sql.bind_variable(l_sql_cursor,                          -- Step 3
                            ':p_address_line1', p_address_line1);

      Hr_Utility.Set_Location(l_proc, 20);
      dbms_sql.define_column(l_sql_cursor, 1, l_town_or_city, 50);  -- Step 4
      dbms_sql.define_column(l_sql_cursor, 2, l_region_1, 70);
      --
      Hr_Utility.Set_Location(l_proc, 30);
      l_rows := dbms_sql.execute_and_fetch(l_sql_cursor, false);    -- Step 5

      if l_rows = 0 then
        dbms_sql.close_cursor(l_sql_cursor);
        hr_utility.set_message(801, 'HR_72029_ADD_INVALID_LINE1');
        hr_utility.raise_error;

      elsif l_rows = 1 then
        Hr_Utility.Set_Location(l_proc, 35);
        dbms_sql.column_value(l_sql_cursor, 1, l_town_or_city);
        p_town_or_city := l_town_or_city;

      else
        dbms_sql.close_cursor(l_sql_cursor);
        hr_utility.set_message(801, 'HR_72030_ADD_OVERRAP_ROWS');
        hr_utility.set_message_token('TABLE_NAME', 'per_jp_address_lookups');
        hr_utility.raise_error;
      end if;
    --
    --Both p_region_1 and p_address_line1 are null
    --
    else
      hr_utility.set_message(801, 'HR_72031_ADD_DIST_LINE1_NULL');
      hr_utility.raise_error;
    end if;


    dbms_sql.column_value(l_sql_cursor, 2, l_region_1);
    if p_region_1 is not null and
       p_region_1 <> l_region_1 then
       dbms_sql.close_cursor(l_sql_cursor);
      hr_utility.set_message(801, 'HR_72032_ADD_INVALID_KANA1');
      hr_utility.raise_error;
    end if;

    p_region_1 := l_region_1;
    dbms_sql.close_cursor(l_sql_cursor);
  end if;
  hr_utility.set_location('Leaving:'|| l_proc, 5);
-- Bug 885806
-- dbms_output.put_line('Bottom of dynamic sql . . .');
   hr_utility.trace('Bottom of dynamic sql . . .');
end chk_address1_towncity_comb;
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------<chk_address2_region2_comb  >---------------------|
-- ----------------------------------------------------------------------------
--
/* Bug 1677965
procedure chk_address2_region2_comb(
  p_address_id             in per_addresses.address_id%TYPE,
  p_object_version_number  in per_addresses.object_version_number%TYPE,
  p_address_line2	         in per_addresses.address_line2%type,
  p_region_2			         in per_addresses.region_2%type) is

--	p_address_line2 ===> address_line2
--	p_region_2      ===> address_line2_kana

  l_api_updating  boolean;
  l_proc  varchar2(72) := g_package||'chk_address2_region2_comb';
  --
  l_output	   	varchar2(150);
  l_rgeflg		varchar2(10);
  l_region_2		per_addresses.region_2%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for address_line2, or region_2 have changed
  --
  l_api_updating := per_add_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);

  if ((l_api_updating and
         (nvl(per_add_shd.g_old_rec.address_line2, hr_api.g_varchar2)  <>
            nvl(p_address_line2, hr_api.g_varchar2)  or
          nvl(per_add_shd.g_old_rec.region_2, hr_api.g_varchar2) <>
            nvl(p_region_2, hr_api.g_varchar2)
     )) or (NOT l_api_updating)) then

    hr_utility.set_location(l_proc, 2);

    if p_address_line2 is NULL and p_region_2 is not NULL then
      hr_utility.set_message(801, 'HR_72025_ADD_REGION2_NOT_NULL');
      hr_utility.raise_error;
    end if;
    l_region_2 := p_region_2;
    hr_chkfmt.checkformat(value   => l_region_2
                         ,format  => 'KANA'
                         ,output  => l_output
                         ,minimum => NULL
                         ,maximum => NULL
                         ,nullok  => 'Y'
                         ,rgeflg  => l_rgeflg
                         ,curcode => NULL);
  hr_utility.set_location(' Calling hr_chkfmt.checkformat2', 1);
  end if;

  hr_utility.set_location('Leaving:'|| l_proc, 3);
end chk_address2_region2_comb;
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------<chk_address3_region3_comb  >---------------------|
-- ----------------------------------------------------------------------------
--
/* Bug 1677965
procedure chk_address3_region3_comb(
  p_address_id             in per_addresses.address_id%TYPE,
  p_object_version_number  in per_addresses.object_version_number%TYPE,
  p_address_line3          in per_addresses.address_line3%type,
  p_region_3               in per_addresses.region_3%type) is

--	p_address_line3	===> address_line3
--	p_region_3      ===> address_line3_kana

  l_api_updating  boolean;
  l_proc  varchar2(72) := g_package||'chk_address3_region3_comb';
  --
  l_output	   	varchar2(150);
  l_rgeflg		varchar2(10);
  l_region_3		per_addresses.region_3%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for address_line3, or region_3 have changed
  --
  l_api_updating := per_add_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);

  if ((l_api_updating and
         (nvl(per_add_shd.g_old_rec.address_line3, hr_api.g_varchar2)  <>
            nvl(p_address_line3, hr_api.g_varchar2)  or
          nvl(per_add_shd.g_old_rec.region_3, hr_api.g_varchar2) <>
            nvl(p_region_3, hr_api.g_varchar2)
     )) or (NOT l_api_updating)) then

    hr_utility.set_location(l_proc, 2);

    if p_address_line3 is NULL and p_region_3 is not NULL then
      hr_utility.set_message(801, 'HR_72026_ADD_REGION3_NOT_NULL');
      hr_utility.raise_error;
    end if;
    l_region_3 := p_region_3;
    hr_chkfmt.checkformat(value   => l_region_3
                         ,format  => 'KANA'
                         ,output  => l_output
                         ,minimum => NULL
                         ,maximum => NULL
                         ,nullok  => 'Y'
                         ,rgeflg  => l_rgeflg
                         ,curcode => NULL);
   hr_utility.set_location(' Calling hr_chkfmt.checkformat3', 1);
  end if;

  hr_utility.set_location('Leaving:'|| l_proc, 1);
end chk_address3_region3_comb;
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_jp_postal_code >----------------------------|
-- ----------------------------------------------------------------------------
/* Bug 1677965
procedure chk_jp_postal_code(p_postal_code in varchar2) is
  l_proc             varchar2(72)  :=  g_package||'chk_jp_postal_code';
  l_sql_cursor       integer;            -- Dynamic sql cursor
  l_dynamic_sql      varchar2(2000);     -- Dynamic sql text
  l_rows             integer;            -- Num of rows returned
  l_dummy            varchar2(1);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  if p_postal_code is not null then
    --
    l_dynamic_sql  := 'select  null '                          ||
                      'from    per_jp_postal_codes p '         ||
                      'where   p.postal_code = :p_postal_code';
    --
    -- Dynamic sql steps:
    -- ==================
    -- 1. Open dynamic sql cursor
    -- 2. Parse dynamic sql
    -- 3. Bind dynamic sql variables
    -- 4. Define dynamic sql columns
    -- 5. Execute and fetch dynamic sql
    --
    hr_utility.set_location(l_proc, 15);
    l_sql_cursor := dbms_sql.open_cursor;                         -- Step 1
    --
    hr_utility.set_location(l_proc, 20);
    dbms_sql.parse(l_sql_cursor, l_dynamic_sql, dbms_sql.native); -- Step 2
    --
    hr_utility.set_location(l_proc, 25);
    dbms_sql.bind_variable(l_sql_cursor,                          -- Step 3
                       ':p_postal_code', p_postal_code);

    hr_utility.set_location(l_proc, 30);
    dbms_sql.define_column(l_sql_cursor, 1, l_dummy, 1);          -- Step 4
    --
    hr_utility.set_location(l_proc, 35);
    l_rows := dbms_sql.execute_and_fetch(l_sql_cursor, false);    -- Step 5

    if l_rows = 0 then
      dbms_sql.close_cursor(l_sql_cursor);
      hr_utility.set_message(801, 'HR_72027_ADD_INVALID_POST_CODE');
      hr_utility.raise_error;
    end if;
    dbms_sql.close_cursor(l_sql_cursor);
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 100);
end chk_jp_postal_code;
*/
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_postal_code >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    If address style is 'GB' then check that the postal code length is not
--    more than eight characters long.
--
--    If address style is 'US' then check that the postal code is
--	- 5 or 10 characters long.
--  	- first 5 characters must be numbers.
--	- if postal code is 10 characters long, sixth character must be '-'
--	  follow by 4 numbers.
--      - if GEOCODES is installed, postal code is mandatory.
--
--  Pre-conditions:
--    Style (p_style) must be valid.
--
--  In Arguments:
--    p_address_id
--    p_style
--    p_postal_code
--    p_business_group_id
--    p_object_version_number
--
--  Post Success:
--    If address style is 'GB','US' or 'JP' and the postal code is valid,
--    processing continues.
--
--  Post Failure:
--    If address style is 'GB','US' or 'JP' and the postal code is invalid,
--    an application error is raised and processing terminates.
--
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- Procedure is modified by adding p_town_or_city in parameter for checking the
-- valid zip code if GEOCODES is installed.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_postal_code
  (p_address_id             in per_addresses.address_id%TYPE
  ,p_style                  in per_addresses.style%TYPE
  ,p_postal_code            in per_addresses.postal_code%TYPE
  ,p_business_group_id      in per_addresses.business_group_id%TYPE
  ,p_object_version_number  in per_addresses.object_version_number%TYPE
  ,p_town_or_city           in per_addresses.town_or_city%TYPE)
   is
-- Cursor Defination added for bug 5367066
cursor get_city_address is
select c.state_abbrev
, c.state_code
,a.city_name
, a.city_code
, z.zip_start
, z.zip_end
, b.county_name
, b.county_code
from
pay_us_city_names a
, pay_us_counties b
, pay_us_states c
, pay_us_zip_codes z
where a.state_code = c.state_code
and a.county_code = b.county_code
and b.state_code = c.state_code
and a.city_code=z.city_code
and a.state_code=z.state_code
and a.county_code=z.county_code
and substr(p_postal_code,1,5) between z.zip_start and z.zip_end
and upper(a.city_name)=upper(p_town_or_city)
order by z.zip_start desc;
---- Cursor Defination end for bug 5367066

   l_proc                varchar2(72)  :=  g_package||'chk_postal_code';
   l_api_updating        boolean;
   l_postal_code_1       varchar2(5);
   l_postal_code_2       varchar2(1);
   l_postal_code_3       varchar2(4);
   l_geocodes_installed  varchar2(1);
   l_count               number(10);
   l_city_address_data   get_city_address%ROWTYPE;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
     ,p_argument       => 'style'
     ,p_argument_value => p_style
     );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for postal code has changed
  --
  l_api_updating := per_add_shd.api_updating
         (p_address_id              =>  p_address_id
         ,p_object_version_number   =>  p_object_version_number);
  --
  if ((l_api_updating
       and nvl(per_add_shd.g_old_rec.postal_code, hr_api.g_varchar2) <>
           nvl(p_postal_code, hr_api.g_varchar2)) or
           (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 2);
    --
    -- Check if GEOCODES is installed for a US legislation
    --
    if p_style = 'US' and hr_general.chk_geocodes_installed = 'Y' then
      --
      -- Check that the zip code is set
      --
      if p_postal_code is null then
        --
        hr_utility.set_message(800, 'PER_52991_ADD_NO_ZIP_SET');
        hr_utility.raise_error;
        --
      end if;
/*-----------------------  Changes start for 5367066 ---------------------*/

begin
hr_utility.set_location('Postal code ='||substr(p_postal_code,1,5), 21);
hr_utility.set_location('Town city ='||p_town_or_city, 22);
open get_city_address;
loop
  fetch get_city_address into l_city_address_data;
  l_count := get_city_address%ROWCOUNT;
  hr_utility.set_location('NO of rows returned from cursor = '||l_count, 23);
   exit when get_city_address%NOTFOUND;
    if (substr(p_postal_code,1,5) between l_city_address_data.zip_start and l_city_address_data.zip_end) then
     null;
    else
       hr_utility.set_message(800, 'HR_7786_ADDR_US_ZIP_OOR');
       hr_utility.set_message_token('ZIP_START',l_city_address_data.zip_start);
       hr_utility.set_message_token('ZIP_END',l_city_address_data.zip_end);
       hr_utility.raise_error;
    end if;
end loop;
--
close get_city_address;
 if l_count = 0 then
   hr_utility.set_message(800, 'HR_51195_ADD_INVALID_ZIP_CODE');
   hr_utility.raise_error;
 end if;
 hr_utility.set_location('Leaveing the Cursor =', 24);
end;

begin
--
 if length(p_postal_code) = 5 then
   hr_utility.set_location(l_proc, 4);
   --
   --  Check if zip code is all numbers
   --
   for i in 1..5 loop
     if(substr(p_postal_code,i,1)
        not between '0' and '9') then
        hr_utility.set_message(801, 'HR_51195_ADD_INVALID_ZIP_CODE');
        hr_utility.raise_error;
     end if;
   end loop;
	--
 elsif length(p_postal_code) = 10 then
   hr_utility.set_location(l_proc, 5);
   --
   --  Parse zip code to validate for correct format.
   --
   l_postal_code_1 := substr(p_postal_code,1,5);
   l_postal_code_2 := substr(p_postal_code,6,1);
   l_postal_code_3 := substr(p_postal_code,7,4);
   --
   --   Validate first 5 characters are numbers
   --
   for i in 1..5 loop
    if(substr(l_postal_code_1,i,1)
       not between '0' and '9') then
       hr_utility.set_message(801, 'HR_51195_ADD_INVALID_ZIP_CODE');
       hr_utility.raise_error;
    end if;
   end loop;
     hr_utility.set_location(l_proc, 6);
     --
     --   Validate last 4 characters are numbers
     --
      for i in 1..4 loop
	 if(substr(l_postal_code_3,i,1)
	   not between '0' and '9') then
	   hr_utility.set_message(801, 'HR_51195_ADD_INVALID_ZIP_CODE');
	   hr_utility.raise_error;
	  end if;
       end loop;
	   hr_utility.set_location(l_proc, 7);
	--
	--   Validate last sixth characters is '-'
	--
	  if l_postal_code_2 <> '-' then
	    hr_utility.set_message(801, 'HR_51195_ADD_INVALID_ZIP_CODE');
	    hr_utility.raise_error;
	  end if;
 else
   --
   --   If zip code is not 5 or 10 character long
   --
     hr_utility.set_message(801, 'HR_51195_ADD_INVALID_ZIP_CODE');
     hr_utility.raise_error;
end if;
	--
	--  If an invalid zip code character generates an
	--  exception
	--
exception
	  when others then
	    hr_utility.set_message(801, 'HR_51195_ADD_INVALID_ZIP_CODE');
	    hr_utility.raise_error;
end;

/*-----------------------  Changes End for 5367066 ---------------------*/

      --
    else
      --
      if p_postal_code is not null then
        --
        -- Check that the GB postal code is no longer than
        -- 8 characters long
        --
        if p_style = 'GB' then
          if length(p_postal_code) > 8 then
            hr_utility.set_message(801, 'HR_7306_ADD_POST_CODE');
            hr_utility.raise_error;
          end if;
        --
        -- Check that the US postal code is either 5 or 10 character
        --
        elsif p_style = 'US' and l_geocodes_installed = 'Y' then
          hr_utility.set_location(l_proc, 3);
          --
          begin
          --
          if length(p_postal_code) = 5 then
            hr_utility.set_location(l_proc, 4);
            --
            --  Check if zip code is all numbers
            --
            for i in 1..5 loop
              if(substr(p_postal_code,i,1)
                not between '0' and '9') then
                hr_utility.set_message(801, 'HR_51195_ADD_INVALID_ZIP_CODE');
                hr_utility.raise_error;
              end if;
            end loop;
  	  --
          elsif length(p_postal_code) = 10 then
            hr_utility.set_location(l_proc, 5);
  	  --
  	  --  Parse zip code to validate for correct format.
  	  --
            l_postal_code_1 := substr(p_postal_code,1,5);
            l_postal_code_2 := substr(p_postal_code,6,1);
            l_postal_code_3 := substr(p_postal_code,7,4);
            --
            --   Validate first 5 characters are numbers
            --
            for i in 1..5 loop
              if(substr(l_postal_code_1,i,1)
                not between '0' and '9') then
                hr_utility.set_message(801, 'HR_51195_ADD_INVALID_ZIP_CODE');
                hr_utility.raise_error;
              end if;
            end loop;
            hr_utility.set_location(l_proc, 6);
            --
            --   Validate last 4 characters are numbers
            --
            for i in 1..4 loop
              if(substr(l_postal_code_3,i,1)
                not between '0' and '9') then
                hr_utility.set_message(801, 'HR_51195_ADD_INVALID_ZIP_CODE');
                hr_utility.raise_error;
              end if;
            end loop;
            hr_utility.set_location(l_proc, 7);
            --
            --   Validate last sixth characters is '-'
            --
            if l_postal_code_2 <> '-' then
              hr_utility.set_message(801, 'HR_51195_ADD_INVALID_ZIP_CODE');
              hr_utility.raise_error;
            end if;

          else
            --
            --   If zip code is not 5 or 10 character long
            --
            hr_utility.set_message(801, 'HR_51195_ADD_INVALID_ZIP_CODE');
            hr_utility.raise_error;
          end if;
            --
            --  If an invalid zip code character generates an
            --  exception
            --
    	    exception
              when others then
                hr_utility.set_message(801, 'HR_51195_ADD_INVALID_ZIP_CODE');
                hr_utility.raise_error;
  	      end;
/* Bug 1677965
        elsif p_style = 'JP' then
          hr_utility.set_location(l_proc, 8);
          chk_jp_postal_code(p_postal_code);
*/
        end if;
        --
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 9);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_ADDRESSES.POSTAL_CODE'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc,10);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,11);
--
end chk_postal_code;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_tax_address_zip >----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    If address style is 'US' then check that the postal code is
--	- 5 or 10 characters long.
--  	- first 5 characters must be numbers.
--	- if postal code is 10 characters long, sixth character must be '-'
--	  follow by 4 numbers.
--      - if GEOCODES is installed, postal code is mandatory.
--
--  Pre-conditions:
--    Style (p_style) must be valid.
--
--  In Arguments:
--    p_address_id
--    p_style
--    p_tax_address_zip
--    p_business_group_id
--    p_object_version_number
--
--  Post Success:
--    If address style is 'US' and the postal code is valid,
--    processing continues.
--
--  Post Failure:
--    If address style is 'US' and the postal code is invalid,
--    an application error is raised and processing terminates.
--
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_tax_address_zip
  (p_address_id             in per_addresses.address_id%TYPE
  ,p_style                  in per_addresses.style%TYPE
  ,p_tax_address_zip	    in per_addresses.add_information20%TYPE
  ,p_business_group_id      in per_addresses.business_group_id%TYPE
  ,p_object_version_number  in per_addresses.object_version_number%TYPE)
   is
--
   l_proc                varchar2(72)  :=  g_package||'chk_tax_address_zip';
   l_api_updating        boolean;
   l_tax_address_zip_1	 varchar2(5);
   l_tax_address_zip_2	 varchar2(1);
   l_tax_address_zip_3	 varchar2(4);
   l_geocodes_installed  varchar2(1);
--
begin
  if p_tax_address_zip is not null
  then
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
     ,p_argument       => 'style'
     ,p_argument_value => p_style
     );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for add_information20 has changed
  --
  l_api_updating := per_add_shd.api_updating
         (p_address_id              =>  p_address_id
         ,p_object_version_number   =>  p_object_version_number);
  --
  if ((l_api_updating
       and nvl(per_add_shd.g_old_rec.add_information20, hr_api.g_varchar2) <>
           nvl(p_tax_address_zip, hr_api.g_varchar2)) or
           (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 2);
    --
    -- Check if GEOCODES is installed for a US legislation
    --
    if p_style = 'US' and hr_general.chk_geocodes_installed = 'Y'
    then
        --
        -- Check that the US postal code is either 5 or 10 character
        --
          begin
          --
          if length(p_tax_address_zip) = 5 then
            hr_utility.set_location(l_proc, 3);
            --
            --  Check if zip code is all numbers
            --
            for i in 1..5 loop
              if(substr(p_tax_address_zip,i,1)
                not between '0' and '9') then
                hr_utility.set_message(801, 'HR_51195_ADD_INVALID_ZIP_CODE');
                hr_utility.raise_error;
              end if;
            end loop;
  	  --
          elsif length(p_tax_address_zip) = 10 then
            hr_utility.set_location(l_proc, 4);
  	  --
  	  --  Parse zip code to validate for correct format.
  	  --
            l_tax_address_zip_1 := substr(p_tax_address_zip,1,5);
            l_tax_address_zip_2 := substr(p_tax_address_zip,6,1);
            l_tax_address_zip_3 := substr(p_tax_address_zip,7,4);

            --
            --   Validate first 5 characters are numbers
            --
            for i in 1..5 loop
              if(substr(l_tax_address_zip_1,i,1)
                not between '0' and '9') then
                hr_utility.set_message(801, 'HR_51195_ADD_INVALID_ZIP_CODE');
                hr_utility.raise_error;
              end if;
            end loop;
            hr_utility.set_location(l_proc, 5);
            --
            --   Validate last 4 characters are numbers
            --
            for i in 1..4 loop
              if(substr(l_tax_address_zip_3,i,1)
                not between '0' and '9') then
                hr_utility.set_message(801, 'HR_51195_ADD_INVALID_ZIP_CODE');
                hr_utility.raise_error;
              end if;
            end loop;
            hr_utility.set_location(l_proc, 6);
            --
            --   Validate last sixth characters is '-'
            --
            if l_tax_address_zip_2 <> '-' then
              hr_utility.set_message(801, 'HR_51195_ADD_INVALID_ZIP_CODE');
              hr_utility.raise_error;
            end if;
          else
            --
            --   If zip code is not 5 or 10 character long
            --
            hr_utility.set_message(801, 'HR_51195_ADD_INVALID_ZIP_CODE');
            hr_utility.raise_error;
          end if;
            --
            --  If an invalid zip code character generates an
            --  exception
            --
    	    exception
              when others then
                hr_utility.set_message(801, 'HR_51195_ADD_INVALID_ZIP_CODE');
                hr_utility.raise_error;
          end;
        end if;
        --
      end if;
    --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 7);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_ADDRESSES.ADD_INFORMATION20'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc,6);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,7);
--
end chk_tax_address_zip;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_region_1 >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    If address style is 'GB' then validates that a region_1 code exists in
--    table hr_lookups.
--    If address style is 'US' and GEOCODES is installed then validates that a
--    region_1 code exists in table pay_us_counties as the county code, unless
--    p_validate_county is set to FALSE.
--
--  Pre-conditions:
--    Style (p_style) must be valid.
--
--  In Arguments:
--    p_address_id
--    p_region_1
--    p_style
--    p_business_group_id
--    p_effective_date
--    p_object_version_number
--    p_validate_county
--
--  Post Success:
--    If address style is 'GB' and a row does exist in hr_lookups
--    for the given region_1 code, processing continues.
--    If address style is 'US' and GEOCODES is installed a row does exist
--    in pay_us_counties for the given region_1 code, processing continues.
--
--  Post Failure:
--    If address style is 'GB' and a row does not exist in hr_lookups
--    for the given region_1 code,  an application error is raised
--    and processing terminates.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_region_1
  (p_address_id             in per_addresses.address_id%TYPE
  ,p_style                  in per_addresses.style%TYPE
  ,p_region_1               in per_addresses.region_1%TYPE
  ,p_business_group_id      in per_addresses.business_group_id%TYPE
  ,p_effective_date         in date
  ,p_object_version_number  in per_addresses.object_version_number%TYPE
  ,p_validate_county        in boolean default TRUE)
   is
--
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'chk_region_1';
   l_api_updating   boolean;
--
   cursor csr_valid_us_county is
     select null
     from pay_us_counties
     where county_name = p_region_1;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'style'
    ,p_argument_value => p_style
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for region_1 has changed
  --
  l_api_updating := per_add_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
       nvl(per_add_shd.g_old_rec.region_1, hr_api.g_varchar2) <>
       nvl(p_region_1, hr_api.g_varchar2)) or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 2);
    --
    -- Check for GEOCODES in a US legislation
    --
    if  p_style = 'US'
    and hr_general.chk_geocodes_installed = 'Y'
    and p_validate_county then
      --
      -- Check that the county is set
      --
      if p_region_1 is null then
        --
        hr_utility.set_message(800, 'PER_52984_ADD_NO_COUNTY_SET');
        hr_utility.raise_error;
        --
      end if;
      --
      hr_utility.set_location(l_proc, 5);
      open csr_valid_us_county;
      fetch csr_valid_us_county into l_exists;
      if csr_valid_us_county%notfound then
        --
        close csr_valid_us_county;
        hr_utility.set_message(801, 'HR_7953_ADDR_NO_COUNTY_FOUND');
        hr_utility.raise_error;
        --
      end if;
      --
    else
      --
      -- Check that value for region_1 is valid
      --
      if p_region_1 is not null then
        hr_utility.set_location(l_proc, 3);
        --
        if p_style = 'GB' then
          hr_utility.set_location(l_proc, 4);
          --
          if hr_api.not_exists_in_hr_lookups
              (p_effective_date => p_effective_date
              ,p_lookup_type    => 'GB_COUNTY'
              ,p_lookup_code    => p_region_1
              ) then
            --
            hr_utility.set_message(801, 'HR_7307_ADD_GB_REGION_1');
            hr_utility.raise_error;
            --
          end if;
          --
        end if;
        --
      end if;
      --
    end if;
    --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 6);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_ADDRESSES.REGION_1'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc,7);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,8);
--
end chk_region_1;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_tax_county >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    If address style is 'US' and GEOCODES is installed then validates that a
--    add_information19 code exists in table pay_us_counties as the county code.
--
--  Pre-conditions:
--    Style (p_style) must be valid.
--
--  In Arguments:
--    p_address_id
--    p_tax_county
--    p_style
--    p_business_group_id
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    If address style is 'US' and GEOCODES is installed and a row does exist
--    in pay_us_counties for the given add_information19 code, processing continues.
--
--  Post Failure:
--    If address style is 'US' and GEOCODES is installed and a row does not exist
--    in pay_us_counties for the given add_information19 code, processing stops
--    an application error is raised
--    and processing terminates.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_tax_county
  (p_address_id             in per_addresses.address_id%TYPE
  ,p_style                  in per_addresses.style%TYPE
  ,p_tax_county             in per_addresses.add_information19%TYPE
  ,p_business_group_id      in per_addresses.business_group_id%TYPE
  ,p_effective_date         in date
  ,p_object_version_number  in per_addresses.object_version_number%TYPE)
   is
--
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'chk_tax_county';
   l_api_updating   boolean;
--
   cursor csr_valid_us_county is
     select null
     from pay_us_counties
     where county_name = p_tax_county;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  if p_tax_county is not null
  then
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'style'
    ,p_argument_value => p_style
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for tax_county has changed
  --
    l_api_updating := per_add_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
       nvl(per_add_shd.g_old_rec.add_information19, hr_api.g_varchar2) <>
       nvl(p_tax_county, hr_api.g_varchar2)) or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 2);
    --
   -- Check for GEOCODES in a US legislation
    --
    if  p_style = 'US'
    and hr_general.chk_geocodes_installed = 'Y'
    then
      open csr_valid_us_county;
      fetch csr_valid_us_county into l_exists;
      if csr_valid_us_county%notfound then
        --
        close csr_valid_us_county;
        hr_utility.set_message(801, 'HR_7953_ADDR_NO_COUNTY_FOUND');
        hr_utility.raise_error;
        --
      end if;
      close csr_valid_us_county;
      --
    end if;
    --
  end if;
 else
     null;
 end if;
 hr_utility.set_location(' Leaving:'|| l_proc, 6);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_ADDRESSES.ADD_INFORMATION19'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc,7);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,8);
--
end chk_tax_county;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_region_2 >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    If address style is 'US', validate region_2 code (state abbreviation)
--    exist in the hr_lookups table if HR installation only or non-US
--    legislation, or the Vertex pay_us_states table if payroll is installed
--    under US legislation.
--
--  Pre-conditions:
--    Style (p_style) must be valid.
--
--  In Arguments:
--    p_address_id
--    p_region_2
--    p_style
--    p_business_group_id
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    If address style is 'US' and a row exist in hr_lookups/pay_us_states
--    for the given region_2 code, processing continues.
--
--  Post Failure:
--    If address style is 'US' and a row does not exist in
--    hr_lookups/pay_us_states for the given region_2 code, an application
--    error is raised and processing terminates.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_region_2
  (p_address_id             in per_addresses.address_id%TYPE
  ,p_style                  in per_addresses.style%TYPE
  ,p_region_2               in per_addresses.region_2%TYPE
  ,p_business_group_id      in per_addresses.business_group_id%TYPE
  ,p_effective_date         in date
  ,p_object_version_number  in per_addresses.object_version_number%TYPE
  )
is
  --
  l_exists             varchar2(1);
  l_proc               varchar2(72)  :=  g_package||'chk_region_2';
  --
  l_api_updating       boolean;
  l_geocodes_installed varchar2(1);
  --
  -- Declare cursor
  --
  cursor csr_valid_state is
    select null
    from pay_us_states
    where state_abbrev = p_region_2;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'style'
    ,p_argument_value => p_style
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for region_2 has changed
  --
  l_api_updating := per_add_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number
         );
  --
  if ((l_api_updating and
       nvl(per_add_shd.g_old_rec.region_2, hr_api.g_varchar2) <>
       nvl(p_region_2, hr_api.g_varchar2)) or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 2);
    --
    -- Check if GEOCODES is installed under a US legislation
    --
    if p_style = 'US' and hr_general.chk_geocodes_installed = 'Y'
    then
      hr_utility.set_location(l_proc, 5);
      --
      -- Check if the state is set
      --
      if p_region_2 is null then
        --
        hr_utility.set_message(800, 'PER_52985_ADD_NO_STATE_SET');
        hr_utility.raise_error;
        --
      end if;
      --
      open csr_valid_state;
      fetch  csr_valid_state into l_exists;
      if csr_valid_state%notfound then
        close csr_valid_state;
        hr_utility.set_message(801, 'HR_7952_ADDR_NO_STATE_CODE');
        hr_utility.raise_error;
      end if;
      close csr_valid_state;
      --
    else
      --
      -- Check that value for region_2 is valid.
      --
      if p_region_2 is not null then
        hr_utility.set_location(l_proc, 3);
        --
        if p_style = 'US'
        then
          hr_utility.set_location(l_proc, 4);
          --
          if hr_api.not_exists_in_hr_lookups
            (p_effective_date => p_effective_date
            ,p_lookup_type    => 'US_STATE'
            ,p_lookup_code    => p_region_2
            )
          then
            --
            --  Error: Invalid region 2.
            hr_utility.set_message(801, 'HR_7952_ADDR_NO_STATE_CODE');
            hr_utility.raise_error;
            --
          end if;
          --
        end if;
        --
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 10);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_ADDRESSES.REGION_2'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc,11);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,12);
--
end chk_region_2;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_tax_state >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    If address style is 'US', validate tax_state (add_information17)
--    code (state abbreviation)exist in the hr_lookups table if HR
--    installation only, or the Vertex pay_us_states table if payroll is installed
--    under US legislation.
--
--  Pre-conditions:
--    Style (p_style) must be valid.
--
--  In Arguments:
--    p_address_id
--    p_tax_state
--    p_style
--    p_business_group_id
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    If address style is 'US' and a row exist in hr_lookups/pay_us_states
--    for the given tax_state code, processing continues.
--
--  Post Failure:
--    If address style is 'US' and a row does not exist in
--    hr_lookups/pay_us_states for the given tax_state code, an application
--    error is raised and processing terminates.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_tax_state
  (p_address_id             in per_addresses.address_id%TYPE
  ,p_style                  in per_addresses.style%TYPE
  ,p_tax_state              in per_addresses.add_information17%TYPE
  ,p_business_group_id      in per_addresses.business_group_id%TYPE
  ,p_effective_date         in date
  ,p_object_version_number  in per_addresses.object_version_number%TYPE
  )
is
  --
  l_exists             varchar2(1);
  l_proc               varchar2(72)  :=  g_package||'chk_tax_state';
  --
  l_api_updating       boolean;
  l_geocodes_installed varchar2(1);
  --
  -- Declare cursor
  --
  cursor csr_valid_state is
    select null
    from pay_us_states
    where state_abbrev = p_tax_state ;
  --
begin
  if p_tax_state is not null
  then
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'style'
    ,p_argument_value => p_style
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for tax_state (add_information17) has changed
  --
  l_api_updating := per_add_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number
         );
  --
  if ((l_api_updating and
       nvl(per_add_shd.g_old_rec.add_information17, hr_api.g_varchar2) <>
       nvl(p_tax_state, hr_api.g_varchar2)) or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 2);
    --
    -- Check if GEOCODES is installed under a US legislation
    --
    if hr_general.chk_geocodes_installed = 'Y'
    then
      hr_utility.set_location(l_proc, 5);
      open csr_valid_state;
      fetch  csr_valid_state into l_exists;
      if csr_valid_state%notfound then
        close csr_valid_state;
        hr_utility.set_message(801, 'HR_7952_ADDR_NO_STATE_CODE');
        hr_utility.raise_error;
      end if;
      close csr_valid_state;
      --
    else
      --
      -- Check that value for tax_state is valid.
      --
          hr_utility.set_location(l_proc, 4);
          --
          if hr_api.not_exists_in_hr_lookups
            (p_effective_date => p_effective_date
            ,p_lookup_type    => 'US_STATE'
            ,p_lookup_code    => p_tax_state
            )
          then
            --
            --  Error: Invalid tax_state.
            hr_utility.set_message(801, 'HR_7952_ADDR_NO_STATE_CODE');
            hr_utility.raise_error;
            --
          end if;
          --
      end if;
      --
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 10);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_ADDRESSES.ADD_INFORMATION17'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc,11);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,12);
--
end chk_tax_state;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_town_or_city >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    If address style is 'US' and Payroll is installed under US legislation,
--    validate town_or_city exist in pay_us_city_names.
--
--  Pre-conditions:
--    Style (p_style) must be valid.
--
--  In Arguments:
--    p_address_id
--    p_town_or_city
--    p_style
--    p_business_group_id
--    p_object_version_number
--
--  Post Success:
--    If address style is 'US', payroll is installed under US legislation and
--    a row exist in pay_us_city_names for the given town_or_city, processing
--    continues.
--
--  Post Failure:
--    If address style is 'US', payroll is installed under US legislation and
--    a row does not exist in pay_us_city_names for the given town_or_city,
--    an application error is raised and processing terminates.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_town_or_city
  (p_address_id             in per_addresses.address_id%TYPE
  ,p_style                  in per_addresses.style%TYPE
  ,p_town_or_city           in per_addresses.town_or_city%TYPE
  ,p_business_group_id      in per_addresses.business_group_id%TYPE
  ,p_object_version_number  in per_addresses.object_version_number%TYPE)
   is
--
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'chk_town_or_city';
   l_api_updating   boolean;
   --
   -- Declare cursor
   --
   cursor csr_valid_town_or_city is
     select null
     from pay_us_city_names
     where city_name = p_town_or_city;
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'style'
    ,p_argument_value => p_style
    );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for town_or_city has changed
  --
  l_api_updating := per_add_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
       nvl(per_add_shd.g_old_rec.town_or_city, hr_api.g_varchar2) <>
       nvl(p_town_or_city, hr_api.g_varchar2)) or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 2);
    --
    if p_style = 'US' and hr_general.chk_geocodes_installed = 'Y' then
      --
      -- Check that the city is set
      --
      if p_town_or_city is null then
        --
        hr_utility.set_message(800, 'PER_52986_ADD_NO_CITY_SET');
        hr_utility.raise_error;
        --
      end if;
      --
      open csr_valid_town_or_city;
      fetch csr_valid_town_or_city into l_exists;
      if csr_valid_town_or_city%notfound then
        close csr_valid_town_or_city;
        hr_utility.set_message(801, 'HR_51276_ADD_INVALID_CITY');
        hr_utility.raise_error;
      end if;
      close csr_valid_town_or_city;
      hr_utility.set_location(l_proc, 4);
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 5);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_ADDRESSES.TOWN_OR_CITY'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc,6);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,7);
--
end chk_town_or_city;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_tax_city >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    If address style is 'US' and Payroll is installed under US legislation,
--    validate tax_city (add_information18) exist in pay_us_city_names.
--
--  Pre-conditions:
--    Style (p_style) must be valid.
--
--  In Arguments:
--    p_address_id
--    p_tax_city
--    p_style
--    p_business_group_id
--    p_object_version_number
--
--  Post Success:
--    If address style is 'US', payroll is installed under US legislation and
--    a row exist in pay_us_city_names for the given tax_city, processing
--    continues.
--
--  Post Failure:
--    If address style is 'US', payroll is installed under US legislation and
--    a row does not exist in pay_us_city_names for the given tax_city,
--    an application error is raised and processing terminates.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_tax_city
  (p_address_id             in per_addresses.address_id%TYPE
  ,p_style                  in per_addresses.style%TYPE
  ,p_tax_city               in per_addresses.add_information18%TYPE
  ,p_business_group_id      in per_addresses.business_group_id%TYPE
  ,p_object_version_number  in per_addresses.object_version_number%TYPE)
   is
--
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'chk_tax_city';
   l_api_updating   boolean;
   --
   -- Declare cursor
   --
   cursor csr_valid_tax_city is
     select null
     from pay_us_city_names
     where city_name = p_tax_city;
begin
  if p_tax_city is not null
  then
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'style'
    ,p_argument_value => p_style
    );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for tax_city has changed
  --
  l_api_updating := per_add_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
       nvl(per_add_shd.g_old_rec.add_information18, hr_api.g_varchar2) <>
       nvl(p_tax_city, hr_api.g_varchar2)) or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 2);
    --
    if hr_general.chk_geocodes_installed = 'Y' then
      open csr_valid_tax_city;
      fetch csr_valid_tax_city into l_exists;
      if csr_valid_tax_city%notfound then
        close csr_valid_tax_city;
        hr_utility.set_message(801, 'HR_51276_ADD_INVALID_CITY');
        hr_utility.raise_error;
      end if;
      close csr_valid_tax_city;
      hr_utility.set_location(l_proc, 4);
      --
    end if;
    --
  end if;
  --
end if;
hr_utility.set_location(' Leaving:'|| l_proc, 5);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_ADDRESSES.ADD_INFORMATION18'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc,6);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,7);
--
end chk_tax_city;
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_city_state_zip_comb >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates the city, state, county and zip code combination of a US
--    address if payroll is installed under US legislation.
--    If region_1 (county) is null then validation will occur without it.
--
--  Pre-conditions:
--    Style (p_style) must be valid and payroll is installed under
--    US legislation.
--
--  In Arguments:
--    p_address_id
--    p_style
--    p_postal_code
--    p_region_1
--    p_region_2
--    p_town_or_city
--    p_business_group_id
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - the city, state and county combination is valid.
--      - zip code is valid for the city and state.
--
--  Post Failure:
--    Processing terminates if:
--      - the city, state and county combination is not valid.
--      - zip code is not valid for the city and state.
--
--  Access status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_city_state_zip_comb
  (p_address_id             in per_addresses.address_id%TYPE
  ,p_style                  in per_addresses.style%TYPE
  ,p_postal_code            in per_addresses.postal_code%TYPE
  ,p_region_1               in per_addresses.region_1%TYPE
  ,p_region_2               in per_addresses.region_2%TYPE
  ,p_town_or_city           in per_addresses.town_or_city%TYPE
  ,p_business_group_id      in per_addresses.business_group_id%TYPE
  ,p_object_version_number  in per_addresses.object_version_number%TYPE
  )
is
--
  l_proc               varchar2(72)  :=  g_package||'chk_city_state_zip_comb';
  l_api_updating       boolean;
  l_exists             number;
  l_city_code          pay_us_city_names.city_code%TYPE;
  l_state_code         pay_us_city_names.state_code%TYPE;
  l_postal_code        varchar2(6);
  l_county_code        varchar2(3);
  l_geocodes_installed varchar2(1);
  --
  cursor csr_valid_state_county
  is
    select st.state_code,
           cou.county_code
    from  pay_us_states st,
          pay_us_counties cou
    where cou.state_code = st.state_code
    and   cou.county_name =p_region_1
    and   st.state_abbrev = p_region_2;
  --
  cursor csr_val_st_county_city
  is
    select cty.city_code
    from  pay_us_city_names cty
    where cty.state_code  = l_state_code
    and   cty.county_code = l_county_code
    and   cty.city_name   = p_town_or_city;
  --
  cursor csr_valid_zip_code is
    select 1
    from  pay_us_zip_codes zip,
          pay_us_city_names cty
    where zip.state_code  = l_state_code
    and   zip.county_code = l_county_code
    and   cty.city_name = p_town_or_city
    and   zip.state_code = cty.state_code
    and   zip.county_code = cty.county_code
    and   zip.city_code = cty.city_code
    and   l_postal_code between zip.zip_start
    and   zip.zip_end;
  --
  cursor csr_val_st_city
  is
    select st.state_code
    from  pay_us_city_names cty
    ,     pay_us_states st
    where cty.state_code  = st.state_code
    and   cty.city_name   = p_town_or_city
    and   st.state_abbrev  = p_region_2;
--
  --
  cursor csr_valid_zip_code_no_ncty is
    select 1
    from  pay_us_zip_codes zip,
          pay_us_city_names cty
    where cty.city_name  = p_town_or_city
    and   cty.state_code = l_state_code
    and   zip.state_code = cty.state_code
    and   zip.city_code = cty.city_code
    and   l_postal_code between zip.zip_start
    and   zip.zip_end;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) US address style and payroll is installed under US legislation and
  -- b) The current g_old_rec is current and
  -- c) The value for postal_code/region_2/town_or_city has changed.
  --
  l_api_updating := per_add_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
      (nvl(per_add_shd.g_old_rec.region_2, hr_api.g_varchar2) <>
       nvl(p_region_2, hr_api.g_varchar2)) or
      (nvl(per_add_shd.g_old_rec.region_1, hr_api.g_varchar2) <>
       nvl(p_region_1, hr_api.g_varchar2)) or
      (nvl(per_add_shd.g_old_rec.postal_code, hr_api.g_varchar2) <>
       nvl(p_postal_code, hr_api.g_varchar2)) or
      (nvl(per_add_shd.g_old_rec.town_or_city, hr_api.g_varchar2) <>
       nvl(p_town_or_city, hr_api.g_varchar2))) or
      (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check if US payroll installed.
    --
    l_geocodes_installed := hr_general.chk_geocodes_installed;
    --
    --
    --  If US address style and GEOCODES is installed, validate for right combination of
    --  city, state and county.
    --
    if  p_style = 'US'
    and l_geocodes_installed = 'Y'
    then
      hr_utility.set_location(l_proc, 30);
      --
      --   Extract the first 5 characters of the zip code
      --
      l_postal_code := substr(p_postal_code,1,5);
      --
      --
      if (p_region_1 is null) then
        --
        if hr_multi_message.no_exclusive_error
        (p_check_column1 => 'PER_ADDRESSES.REGION_2'
        ,p_check_column2 => 'PER_ADDRESSES.TOWN_OR_CITY'
        ) then
	  --
          hr_utility.set_location(l_proc, 40);
          --
          -- no county is given, so procede with validation which excluses it;
          -- validate state and city;
          --
          open csr_val_st_city;
          fetch csr_val_st_city into l_state_code;
          if(csr_val_st_city%notfound) then
            close csr_val_st_city;
            hr_utility.set_location(l_proc, 50);
            hr_utility.set_message(800, 'PER_52531_ADD_INV_STCI_COMB');
            hr_multi_message.add
	    (p_associated_column1 => 'PER_ADDRESSES.REGION_2'
	    ,p_associated_column2 => 'PER_ADDRESSES.TOWN_OR_CITY'
	    );
          else
            close csr_val_st_city;
            hr_utility.set_location(l_proc, 60);
            --
            -- check for a valid state, city, zip combination
            --
	    if hr_multi_message.no_exclusive_error
               (p_check_column1 => 'PER_ADDRESSES.POSTAL_CODE'
               ) then
	      --
              open csr_valid_zip_code_no_ncty;
              fetch csr_valid_zip_code_no_ncty into l_exists;
              if csr_valid_zip_code_no_ncty%notfound then
                close csr_valid_zip_code_no_ncty;
                hr_utility.set_location(l_proc, 70);
                hr_utility.set_message(800, 'PER_52532_ADD_INV_STCIZ_COMB');
                hr_multi_message.add
                (p_associated_column1 => 'PER_ADDRESSES.REGION_2'
	        ,p_associated_column2 => 'PER_ADDRESSES.TOWN_OR_CITY'
	        ,p_associated_column3 => 'PER_ADDRESSES.POSTAL_CODE'
	        );
              else
                close csr_valid_zip_code_no_ncty;
                hr_utility.set_location(l_proc, 80);
              end if;
            --
	    end if; -- no_exclusive_error check for POSTAL_CODE
	    --
          end if;
	--
        end if; -- no_exclusive_error check for REGION_2 and TOWN_OR_CITY
	--
      else -- REGION_1 is not null
        --
        -- The county is supplied, so validate with it.
        --
        -- Validate the state and county combination
        --
        if hr_multi_message.no_exclusive_error
        (p_check_column1 => 'PER_ADDRESSES.REGION_1'
	,p_check_column2 => 'PER_ADDRESSES.REGION_2'
        ) then
	  --
          hr_utility.set_location(l_proc, 90);
          open csr_valid_state_county;
          fetch csr_valid_state_county into l_state_code, l_county_code;
          --
          if csr_valid_state_county%notfound then
            close csr_valid_state_county;
            --
            hr_utility.set_location(l_proc, 100);
            hr_utility.set_message(800, 'PER_52988_ADD_INV_STCOU_COMB');
            hr_multi_message.add
            (p_associated_column1 => 'PER_ADDRESSES.REGION_1'
            ,p_associated_column2 => 'PER_ADDRESSES.REGION_2'
	    );
          else
            close csr_valid_state_county;
            hr_utility.set_location(l_proc, 110);
	  end if;
          --
          -- Validate the state, county and city combination
          --
          if hr_multi_message.no_exclusive_error
          (p_check_column1 => 'PER_ADDRESSES.TOWN_OR_CITY'
          ) then
            open csr_val_st_county_city;
            fetch csr_val_st_county_city into l_city_code;
            --
            if csr_val_st_county_city%notfound then
              close csr_val_st_county_city;
              --
              hr_utility.set_location(l_proc, 120);
              hr_utility.set_message(800, 'PER_52987_ADD_INV_STCOCY_COMB');
              hr_multi_message.add
              (p_associated_column1 => 'PER_ADDRESSES.REGION_2'
	      ,p_associated_column2 => 'PER_ADDRESSES.REGION_1'
              ,p_associated_column3 => 'PER_ADDRESSES.TOWN_OR_CITY'
              );
            else
              close csr_val_st_county_city;
              hr_utility.set_location(l_proc, 130);
	    end if;
            --
            -- Validate the state, county, city and zip code combination
            --
            if hr_multi_message.no_exclusive_error
            (p_check_column1 => 'PER_ADDRESSES.POSTAL_CODE'
            ) then
	      --
              open csr_valid_zip_code;
              fetch csr_valid_zip_code into l_exists;
              if csr_valid_zip_code%notfound then
                close csr_valid_zip_code;
                --
                hr_utility.set_location(l_proc, 140);
                hr_utility.set_message(801, 'HR_51282_ADD_INV_ZIP_FOR_CITY');
                hr_multi_message.add
                (p_associated_column1 => 'PER_ADDRESSES.REGION_2'
                ,p_associated_column2 => 'PER_ADDRESSES.REGION_1'
                ,p_associated_column3 => 'PER_ADDRESSES.TOWN_OR_CITY'
                ,p_associated_column4 => 'PER_ADDRESSES.POSTAL_CODE'
	        );
              else
                close csr_valid_zip_code;
                hr_utility.set_location(l_proc, 150);
	      end if;
	    --
	    end if; -- no_exclusive_error check for postal_code
	    --
          end if; -- no_exclusive_error check for town_or_city
          --
        end if; -- no_exclusive_error check for region_1 and region_2
        --
      end if; -- end if for valid region_1
      --
    end if; -- end if for p_style = 'US'
    --
  end if; -- end if for api_updating check
hr_utility.set_location(' Leaving:'|| l_proc, 160);
--
end chk_city_state_zip_comb;
--
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_tax_city_state_zip_comb >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates the city, state, county and zip code combination for taxation
--    address of a US address if payroll is installed under US legislation.
--    If add_information19 (tax county) is null then validation will occur
--    without it.
--
--  Pre-conditions:
--    Style (p_style) must be valid and payroll is installed under
--    US legislation.
--
--  In Arguments:
--    p_address_id
--    p_style
--    p_tax_zip (add_information20)
--    p_tax_county (add_information19)
--    p_tax_state (add_information17)
--    p_tax_city (add_information18)
--    p_business_group_id
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - the taxation city, state and county combination is valid.
--      - zip code is valid for the taxation city and state.
--
--  Post Failure:
--    Processing terminates if:
--      - the taxation city, state and county combination is not valid.
--      - zip code is not valid for the taxation city and state.
--
--  Access status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_tax_city_state_zip_comb
  (p_address_id             in per_addresses.address_id%TYPE
  ,p_style                  in per_addresses.style%TYPE
  ,p_tax_zip                in per_addresses.add_information20%TYPE
  ,p_tax_county             in per_addresses.add_information19%TYPE
  ,p_tax_state              in per_addresses.add_information17%TYPE
  ,p_tax_city               in per_addresses.add_information18%TYPE
  ,p_business_group_id      in per_addresses.business_group_id%TYPE
  ,p_object_version_number  in per_addresses.object_version_number%TYPE
  )
is
--
  l_proc               varchar2(72)  :=  g_package||'chk_tax_city_state_zip_comb';
  l_api_updating       boolean;
  l_exists             number;
  l_city_code          pay_us_city_names.city_code%TYPE;
  l_state_code         pay_us_city_names.state_code%TYPE;
  l_postal_code        varchar2(6);
  l_county_code        varchar2(3);
  l_geocodes_installed varchar2(1);
  --
  cursor csr_valid_state_county
  is
    select st.state_code,
           cou.county_code
    from  pay_us_states st,
          pay_us_counties cou
    where cou.state_code = st.state_code
    and   cou.county_name = p_tax_county
    and   st.state_abbrev = p_tax_state;
  --
  cursor csr_val_st_county_city
  is
    select cty.city_code
    from  pay_us_city_names cty
    where cty.state_code  = l_state_code
    and   cty.county_code = l_county_code
    and   cty.city_name   = p_tax_city;
  --
  cursor csr_valid_zip_code is
    select 1
    from  pay_us_zip_codes zip,
          pay_us_city_names cty
    where zip.state_code  = l_state_code
    and   zip.county_code = l_county_code
    and   cty.city_name = p_tax_city
    and   zip.state_code = cty.state_code
    and   zip.county_code = cty.county_code
    and   zip.city_code = cty.city_code
    and   l_postal_code between zip.zip_start
    and   zip.zip_end;
  --
  cursor csr_val_st_city
  is
    select st.state_code
    from  pay_us_city_names cty
    ,     pay_us_states st
    where cty.state_code  = st.state_code
    and   cty.city_name   = p_tax_city
    and   st.state_abbrev  = p_tax_state;
--
  --
  cursor csr_valid_zip_code_no_ncty is
    select 1
    from  pay_us_zip_codes zip,
          pay_us_city_names cty
    where cty.city_name  = p_tax_city
    and   cty.state_code = l_state_code
    and   zip.state_code = cty.state_code
    and   zip.city_code = cty.city_code
    and   l_postal_code between zip.zip_start
    and   zip.zip_end;
--
begin
  if p_tax_city is not null and
     p_tax_state is not null and
     p_tax_zip is not null
  then
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) US address style and payroll is installed under US legislation and
  -- b) The current g_old_rec is current and
  -- c) The value for tax_zip (add_information20)/tax_state(add_information17)
  --    /tax_city(add_information18) has changed.
  --
  l_api_updating := per_add_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
      (nvl(per_add_shd.g_old_rec.add_information17, hr_api.g_varchar2) <>
       nvl(p_tax_city, hr_api.g_varchar2)) or
      (nvl(per_add_shd.g_old_rec.add_information19, hr_api.g_varchar2) <>
       nvl(p_tax_county, hr_api.g_varchar2)) or
      (nvl(per_add_shd.g_old_rec.add_information20, hr_api.g_varchar2) <>
       nvl(p_tax_zip, hr_api.g_varchar2)) or
      (nvl(per_add_shd.g_old_rec.add_information18, hr_api.g_varchar2) <>
       nvl(p_tax_city, hr_api.g_varchar2))) or
      (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check if US payroll installed.
    --
    l_geocodes_installed := hr_general.chk_geocodes_installed;
    --
    --
    --  If US address style and GEOCODES is installed, validate for right combination of
    --  city, state and county.
    --
    If l_geocodes_installed = 'Y'
    then
      hr_utility.set_location(l_proc, 30);
      --
      --   Extract the first 5 characters of the zip code
      --
      l_postal_code := substr(p_tax_zip,1,5);
      --
      --
      if (p_tax_county is null) then
        if hr_multi_message.no_exclusive_error
	(p_check_column1 => 'PER_ADDRESSES.ADD_INFORMATION17'
        ,p_check_column2 => 'PER_ADDRESSES.ADD_INFORMATION18'
	) then
          hr_utility.set_location(l_proc, 40);
          --
          -- no county is given, so procede with validation which excluses it;
          -- validate state and city;
          --
          open csr_val_st_city;
          fetch csr_val_st_city into l_state_code;
          if(csr_val_st_city%notfound) then
            close csr_val_st_city;
            hr_utility.set_location(l_proc, 50);
            hr_utility.set_message(800, 'PER_52531_ADD_INV_STCI_COMB');
            hr_multi_message.add
            (p_associated_column1 => 'PER_ADDRESSES.ADD_INFORMATION17'
	    ,p_associated_column2 => 'PER_ADDRESSES.ADD_INFORMATION18'
	    );
          else
            close csr_val_st_city;
            hr_utility.set_location(l_proc, 60);
            --
            -- check for a valid state, city, zip combination
            --
            if hr_multi_message.no_exclusive_error
            (p_check_column1 => 'PER_ADDRESSES.ADD_INFORMATION20'
            ) then
              open csr_valid_zip_code_no_ncty;
              fetch csr_valid_zip_code_no_ncty into l_exists;
              if csr_valid_zip_code_no_ncty%notfound then
                close csr_valid_zip_code_no_ncty;
                hr_utility.set_location(l_proc, 70);
                hr_utility.set_message(800, 'PER_52532_ADD_INV_STCIZ_COMB');
                hr_multi_message.add
                (p_associated_column1 => 'PER_ADDRESSES.ADD_INFORMATION17'
                ,p_associated_column2 => 'PER_ADDRESSES.ADD_INFORMATION18'
                ,p_associated_column3 => 'PER_ADDRESSES.ADD_INFORMATION20'
	        );
              else
                --
                close csr_valid_zip_code_no_ncty;
                hr_utility.set_location(l_proc, 80);
	        --
              end if;
	      --
	    end if; -- no_exclusive_error for ADD_INFORMATION20(p_tax_zip)
	    --
          end if;
	  --
	end if; -- no_exclusive_error for ADD_INFORMATION17(p_tax_state)
	        -- and ADD_INFORMATION18(p_tax_city)
      else -- if county is not null
        --
        -- The county is supplied, so validate with it.
        --
        -- Validate the state and county combination
        --
        if hr_multi_message.no_exclusive_error
 	(p_check_column1 => 'PER_ADDRESSES.ADD_INFORMATION17'
        ,p_check_column2 => 'PER_ADDRESSES.ADD_INFORMATION19'
	) then
	  --
          hr_utility.set_location(l_proc, 90);
          open csr_valid_state_county;
          fetch csr_valid_state_county into l_state_code, l_county_code;
          --
          if csr_valid_state_county%notfound then
            close csr_valid_state_county;
            --
            hr_utility.set_location(l_proc, 100);
            hr_utility.set_message(800, 'PER_52988_ADD_INV_STCOU_COMB');
            hr_multi_message.add
            (p_associated_column1 => 'PER_ADDRESSES.ADD_INFORMATION17'
            ,p_associated_column2 => 'PER_ADDRESSES.ADD_INFORMATION19'
            );
          --
          else
	    --
            close csr_valid_state_county;
            hr_utility.set_location(l_proc, 110);
  	    --
          end if;
          --
          -- Validate the state, county and city combination
          --
          if hr_multi_message.no_exclusive_error
    	  (p_check_column1 => 'PER_ADDRESSES.ADD_INFORMATION18'
          ) then
            open csr_val_st_county_city;
            fetch csr_val_st_county_city into l_city_code;
            --
            if csr_val_st_county_city%notfound then
              close csr_val_st_county_city;
              --
              hr_utility.set_location(l_proc, 120);
              hr_utility.set_message(800, 'PER_52987_ADD_INV_STCOCY_COMB');
              hr_multi_message.add
              (p_associated_column1 => 'PER_ADDRESSES.ADD_INFORMATION17'
              ,p_associated_column2 => 'PER_ADDRESSES.ADD_INFORMATION18'
              ,p_associated_column3 => 'PER_ADDRESSES.ADD_INFORMATION19'
              );
            --
            else
              --
              close csr_val_st_county_city;
              hr_utility.set_location(l_proc, 130);
              --
            end if;
            --
            -- Validate the state, county, city and zip code combination
            --
            if hr_multi_message.no_exclusive_error
            (p_check_column1 => 'PER_ADDRESSES.ADD_INFORMATION20'
            ) then
              open csr_valid_zip_code;
              fetch csr_valid_zip_code into l_exists;
              if csr_valid_zip_code%notfound then
                close csr_valid_zip_code;
              --
                hr_utility.set_location(l_proc, 140);
                hr_utility.set_message(801, 'HR_51282_ADD_INV_ZIP_FOR_CITY');
                hr_multi_message.add
                (p_associated_column1 => 'PER_ADDRESSES.ADD_INFORMATION17'
                ,p_associated_column2 => 'PER_ADDRESSES.ADD_INFORMATION18'
                ,p_associated_column3 => 'PER_ADDRESSES.ADD_INFORMATION19'
                ,p_associated_column4 => 'PER_ADDRESSES.ADD_INFORMATION20'
                );
              --
              else
	        --
                close csr_valid_zip_code;
                hr_utility.set_location(l_proc, 150);
                --
	      end if;
              --
	    end if; -- no_exclusive_error for ADD_INFORMATION20(p_tax_zip)
	    --
          end if; -- no_exclusive_error for ADD_INFORMATION18(p_tax_city)
	  --
	end if; -- no_exclusive_error for ADD_INFORMATION17(p_tax_state)
	        -- and ADD_INFORMATION19(p_tax_county)
      end if;
      --
    end if;
    --
  end if;
end if;
hr_utility.set_location(' Leaving:'|| l_proc, 160);
--
end chk_tax_city_state_zip_comb;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_del_address >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that primary addresses can only be deleted within a given
--    date range if no other non primary addresses exist within that same
--    date range
--
--    Validates that primary addresses can only be deleted if they do not
--    break the contiguous nature of a primary address.
--
--    Non primary addresses can be deleted without any validation being
--    performed
--
--  Pre-conditions:
--    None
--  In Arguments:
--    None
--
--  Post Success:
--    If no non-primary exist within the date range of the primary address
--    selected for deletion and the deletion does not break up the
--    the contiguous nature of the primary address then processing continues
--
--  Post Failure:
--    If a non primary address exists within the date range of the primary
--    address selected for deletion or the deletion breaks up the contiguous
--    nature of the primary address then an application error is raised and
--    processing terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_del_address is
--
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'chk_del_address';
   l_date           date;
--
   cursor csr_del_address is
     select null
     from per_addresses pa
     where pa.date_from between per_add_shd.g_old_rec.date_from
                            and l_date
     and pa.person_id = per_add_shd.g_old_rec.person_id
     and pa.primary_flag = 'N';
--
   cursor csr_no_del_contig_add is
     select null
     from  sys.dual
     where exists(select null
                  from   per_addresses pa2
                  where  pa2.date_from > l_date
                  and    pa2.person_id = per_add_shd.g_old_rec.person_id
                  and    pa2.primary_flag = 'Y');
--
begin
  l_date := nvl(per_add_shd.g_old_rec.date_to, hr_api.g_eot);
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- For primary addresses only
  -- ==========================
  --
  if per_add_shd.g_old_rec.primary_flag = 'Y' then
    --
    -- Check that no non primary addresses
    -- exist within the date range of the
    -- currently selected primary address.
    -- Non primary addresses can be deleted
    -- at any time
    --
    open csr_del_address;
    fetch csr_del_address into l_exists;
    if csr_del_address%found then
      close csr_del_address;
      hr_utility.set_message(801, 'HR_7308_ADD_PRIMARY_DEL');
      hr_utility.raise_error;
    end if;
    close csr_del_address;
    hr_utility.set_location(l_proc, 2);
    --
    -- Check that the deletion of a primary
    -- address does not break the contiguous
    -- nature of the address
    --
    open csr_no_del_contig_add;
    fetch csr_no_del_contig_add into l_exists;
    if csr_no_del_contig_add%found then
      close csr_no_del_contig_add;
      hr_utility.set_message(801, 'HR_51030_ADDR_PRIM_GAP');
      hr_utility.raise_error;
    end if;
    close csr_no_del_contig_add;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
  hr_utility.set_location(' Leaving:'||l_proc,5);
end chk_del_address;
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_non_updateable_args >-----------------------|
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
--   (business_group_id, person_id, address_id, primary_flag or style)
--   have been altered.
--
-- {End Of Comments}
Procedure check_non_updateable_args(p_rec in per_add_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'check_non_updateable_args';
--
Begin
   hr_utility.set_location('Entering:'||l_proc, 5);
--
-- Only proceed with validation if a row exists for
-- the current record in the HR Schema
--
  if not per_add_shd.api_updating
                (p_address_id            => p_rec.address_id,
                 p_object_version_number => p_rec.object_version_number) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;
  --
  hr_utility.set_location(l_proc, 6);
  --
  -- start of commenting the code for business_group_id and person_id
  -- are updateable if currently null
/*
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     per_add_shd.g_old_rec.business_group_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'BUSINESS_GROUP_ID'
    ,p_base_table => per_add_shd.g_tab_nam
    );
  end if;
  hr_utility.set_location(l_proc, 7);
  --
  if nvl(p_rec.person_id, hr_api.g_number) <>
     per_add_shd.g_old_rec.person_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'PERSON_ID'
    ,p_base_table => per_add_shd.g_tab_nam
    );
  end if;
*/
  -- end of commenting code
  --
  hr_utility.set_location(l_proc, 8);
  --
if not g_called_from_form   then
  if nvl(p_rec.primary_flag, hr_api.g_varchar2) <>
     per_add_shd.g_old_rec.primary_flag then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'PRIMARY_FLAG'
    ,p_base_table => per_add_shd.g_tab_nam
    );
end if;
  end if;
  hr_utility.set_location(l_proc, 11);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 12);
end check_non_updateable_args;
--
-- -----------------------------------------------------------------------------
-- |--------------------------------< chk_df >---------------------------------|
-- -----------------------------------------------------------------------------
--
procedure chk_df
  (p_rec   in per_add_shd.g_rec_type) is
--
  l_proc       varchar2(72) := g_package||'chk_df';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check if the row is being inserted or updated and a
  -- value has changed
  --
  if (p_rec.address_id is null)
    or ((p_rec.address_id is not null)
      and  (nvl(per_add_shd.g_old_rec.addr_attribute_category, hr_api.g_varchar2)
           <> nvl(p_rec.addr_attribute_category, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.ADDR_ATTRIBUTE1, hr_api.g_varchar2)
           <> nvl(p_rec.ADDR_ATTRIBUTE1, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.ADDR_ATTRIBUTE2, hr_api.g_varchar2)
           <> nvl(p_rec.ADDR_ATTRIBUTE2, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.ADDR_ATTRIBUTE3, hr_api.g_varchar2)
           <> nvl(p_rec.ADDR_ATTRIBUTE3, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.ADDR_ATTRIBUTE4, hr_api.g_varchar2)
           <> nvl(p_rec.ADDR_ATTRIBUTE4, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.ADDR_ATTRIBUTE5, hr_api.g_varchar2)
           <> nvl(p_rec.ADDR_ATTRIBUTE5, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.ADDR_ATTRIBUTE6, hr_api.g_varchar2)
           <> nvl(p_rec.ADDR_ATTRIBUTE6, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.ADDR_ATTRIBUTE7, hr_api.g_varchar2)
           <> nvl(p_rec.ADDR_ATTRIBUTE7, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.ADDR_ATTRIBUTE8, hr_api.g_varchar2)
           <> nvl(p_rec.ADDR_ATTRIBUTE8, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.ADDR_ATTRIBUTE9, hr_api.g_varchar2)
           <> nvl(p_rec.ADDR_ATTRIBUTE9, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.ADDR_ATTRIBUTE10, hr_api.g_varchar2)
           <> nvl(p_rec.ADDR_ATTRIBUTE10, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.ADDR_ATTRIBUTE11, hr_api.g_varchar2)
           <> nvl(p_rec.ADDR_ATTRIBUTE11, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.ADDR_ATTRIBUTE12, hr_api.g_varchar2)
           <> nvl(p_rec.ADDR_ATTRIBUTE12, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.ADDR_ATTRIBUTE13, hr_api.g_varchar2)
           <> nvl(p_rec.ADDR_ATTRIBUTE13, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.ADDR_ATTRIBUTE14, hr_api.g_varchar2)
           <> nvl(p_rec.ADDR_ATTRIBUTE14, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.ADDR_ATTRIBUTE15, hr_api.g_varchar2)
           <> nvl(p_rec.ADDR_ATTRIBUTE15, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.ADDR_ATTRIBUTE16, hr_api.g_varchar2)
           <> nvl(p_rec.ADDR_ATTRIBUTE16, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.ADDR_ATTRIBUTE17, hr_api.g_varchar2)
           <> nvl(p_rec.ADDR_ATTRIBUTE17, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.ADDR_ATTRIBUTE18, hr_api.g_varchar2)
           <> nvl(p_rec.ADDR_ATTRIBUTE18, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.ADDR_ATTRIBUTE19, hr_api.g_varchar2)
           <> nvl(p_rec.ADDR_ATTRIBUTE19, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.ADDR_ATTRIBUTE20, hr_api.g_varchar2)
           <> nvl(p_rec.ADDR_ATTRIBUTE20, hr_api.g_varchar2)
           )
       )
  then
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_ADDRESSES'
      ,p_attribute_category => p_rec.addr_attribute_category
      ,p_attribute1_name    => 'ADDR_ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.ADDR_ATTRIBUTE1
      ,p_attribute2_name    => 'ADDR_ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.ADDR_ATTRIBUTE2
      ,p_attribute3_name    => 'ADDR_ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.ADDR_ATTRIBUTE3
      ,p_attribute4_name    => 'ADDR_ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.ADDR_ATTRIBUTE4
      ,p_attribute5_name    => 'ADDR_ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.ADDR_ATTRIBUTE5
      ,p_attribute6_name    => 'ADDR_ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.ADDR_ATTRIBUTE6
      ,p_attribute7_name    => 'ADDR_ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.ADDR_ATTRIBUTE7
      ,p_attribute8_name    => 'ADDR_ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.ADDR_ATTRIBUTE8
      ,p_attribute9_name    => 'ADDR_ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.ADDR_ATTRIBUTE9
      ,p_attribute10_name   => 'ADDR_ATTRIBUTE10'
      ,p_attribute10_value  => p_rec.ADDR_ATTRIBUTE10
      ,p_attribute11_name   => 'ADDR_ATTRIBUTE11'
      ,p_attribute11_value  => p_rec.ADDR_ATTRIBUTE11
      ,p_attribute12_name   => 'ADDR_ATTRIBUTE12'
      ,p_attribute12_value  => p_rec.ADDR_ATTRIBUTE12
      ,p_attribute13_name   => 'ADDR_ATTRIBUTE13'
      ,p_attribute13_value  => p_rec.ADDR_ATTRIBUTE13
      ,p_attribute14_name   => 'ADDR_ATTRIBUTE14'
      ,p_attribute14_value  => p_rec.ADDR_ATTRIBUTE14
      ,p_attribute15_name   => 'ADDR_ATTRIBUTE15'
      ,p_attribute15_value  => p_rec.ADDR_ATTRIBUTE15
      ,p_attribute16_name   => 'ADDR_ATTRIBUTE16'
      ,p_attribute16_value  => p_rec.ADDR_ATTRIBUTE16
      ,p_attribute17_name   => 'ADDR_ATTRIBUTE17'
      ,p_attribute17_value  => p_rec.ADDR_ATTRIBUTE17
      ,p_attribute18_name   => 'ADDR_ATTRIBUTE18'
      ,p_attribute18_value  => p_rec.ADDR_ATTRIBUTE18
      ,p_attribute19_name   => 'ADDR_ATTRIBUTE19'
      ,p_attribute19_value  => p_rec.ADDR_ATTRIBUTE19
      ,p_attribute20_name   => 'ADDR_ATTRIBUTE20'
      ,p_attribute20_value  => p_rec.ADDR_ATTRIBUTE20
      );
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end chk_df;
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< chk_ddf >---------------------------------|
-- -----------------------------------------------------------------------------
--
procedure chk_ddf
  (p_rec   in per_add_shd.g_rec_type) is
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
  if (p_rec.address_id is null)
    or ((p_rec.address_id is not null)
      and  (nvl(per_add_shd.g_old_rec.style, hr_api.g_varchar2)
           <> nvl(p_rec.style, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.address_line1, hr_api.g_varchar2)
           <> nvl(p_rec.address_line1, hr_api.g_varchar2)
      or nvl(per_add_shd.g_old_rec.address_line2, hr_api.g_varchar2)
           <> nvl(p_rec.address_line2, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.address_line3, hr_api.g_varchar2)
           <> nvl(p_rec.address_line3, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.town_or_city, hr_api.g_varchar2)
           <> nvl(p_rec.town_or_city, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.region_1, hr_api.g_varchar2)
           <> nvl(p_rec.region_1, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.region_2, hr_api.g_varchar2)
           <> nvl(p_rec.region_2, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.region_3, hr_api.g_varchar2)
           <> nvl(p_rec.region_3, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.postal_code, hr_api.g_varchar2)
           <> nvl(p_rec.postal_code, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.country, hr_api.g_varchar2)
           <> nvl(p_rec.country, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.telephone_number_1, hr_api.g_varchar2)
           <> nvl(p_rec.telephone_number_1, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.telephone_number_2, hr_api.g_varchar2)
           <> nvl(p_rec.telephone_number_2, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.telephone_number_3, hr_api.g_varchar2)
           <> nvl(p_rec.telephone_number_3, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.add_information18, hr_api.g_varchar2)
           <> nvl(p_rec.add_information13, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.add_information13, hr_api.g_varchar2)
           <> nvl(p_rec.add_information14, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.add_information14, hr_api.g_varchar2)
           <> nvl(p_rec.add_information15, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.add_information15, hr_api.g_varchar2)
           <> nvl(p_rec.add_information16, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.add_information16, hr_api.g_varchar2)	--Start of new code for Bug #2164019
           <> nvl(p_rec.add_information17, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.add_information18, hr_api.g_varchar2)
           <> nvl(p_rec.add_information18, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.add_information19, hr_api.g_varchar2)
           <> nvl(p_rec.add_information19, hr_api.g_varchar2)
        or nvl(per_add_shd.g_old_rec.add_information20, hr_api.g_varchar2)
           <> nvl(p_rec.add_information20, hr_api.g_varchar2)           	--End of new code for Bug #2164019
           )
       )
  then
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'Address Structure'
      ,p_attribute_category => p_rec.style
      ,p_attribute1_name    => 'ADDRESS_LINE1'
      ,p_attribute1_value   => p_rec.address_line1
      ,p_attribute2_name    => 'ADDRESS_LINE2'
      ,p_attribute2_value   => p_rec.address_line2
      ,p_attribute3_name    => 'ADDRESS_LINE3'
      ,p_attribute3_value   => p_rec.address_line3
      ,p_attribute4_name    => 'TOWN_OR_CITY'
      ,p_attribute4_value   => p_rec.town_or_city
      ,p_attribute5_name    => 'REGION_1'
      ,p_attribute5_value   => p_rec.region_1
      ,p_attribute6_name    => 'REGION_2'
      ,p_attribute6_value   => p_rec.region_2
      ,p_attribute7_name    => 'REGION_3'
      ,p_attribute7_value   => p_rec.region_3
      ,p_attribute8_name    => 'POSTAL_CODE'
      ,p_attribute8_value   => p_rec.postal_code
      ,p_attribute9_name    => 'COUNTRY'
      ,p_attribute9_value   => p_rec.country
      ,p_attribute10_name   => 'TELEPHONE_NUMBER_1'
      ,p_attribute10_value  => p_rec.telephone_number_1
      ,p_attribute11_name   => 'TELEPHONE_NUMBER_2'
      ,p_attribute11_value  => p_rec.telephone_number_2
      ,p_attribute12_name   => 'TELEPHONE_NUMBER_3'
      ,p_attribute12_value  => p_rec.telephone_number_3
      ,p_attribute13_name    => 'ADD_INFORMATION17'		--Start of new code for Bug#2164019
      ,p_attribute13_value   => p_rec.add_information17
      ,p_attribute14_name    => 'ADD_INFORMATION18'
      ,p_attribute14_value   => p_rec.add_information18
      ,p_attribute15_name   => 'ADD_INFORMATION19'
      ,p_attribute15_value  => p_rec.add_information19
      ,p_attribute16_name   => 'ADD_INFORMATION20'
      ,p_attribute16_value  => p_rec.add_information20		--End of new code for Bug#2164019
      ,p_attribute17_name    => 'ADD_INFORMATION13'
      ,p_attribute17_value   => p_rec.add_information13
      ,p_attribute18_name    => 'ADD_INFORMATION14'
      ,p_attribute18_value   => p_rec.add_information14
      ,p_attribute19_name    => 'ADD_INFORMATION15'
      ,p_attribute19_value   => p_rec.add_information15
      ,p_attribute20_name    => 'ADD_INFORMATION16'
      ,p_attribute20_value   => p_rec.add_information16
      );
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end chk_ddf;
--
-- ---------------------------------------------------------------------------
-- |----------------------<  df_update_validate  >---------------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--   Calls the descriptive flex validation stub (per_add_flex.df) if either
--   the attribute_category or attribute1..30 have changed.
--
-- Pre-conditions:
--   Can only be called from update_validate
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the attribute_category and attribute1.30 haven't changed then the
--   validation is not performed and the processing continues.
--   If the attribute_category or attribute1.30 have changed then the
--   per_add_flex.df validates the descriptive flex. If an exception is
--   not raised then processing continues.
--
-- Post Failure:
--   If an exception is raised within this procedure or lower
--   procedure calls then it is raised through the normal exception
--   handling mechanism.
--
-- Access Status:
--   Internal Table Handler Use Only.
-- ---------------------------------------------------------------------------
procedure df_update_validate
  (p_rec in per_add_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'df_update_validate';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if nvl(per_add_shd.g_old_rec.addr_attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute_category, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.addr_attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute1, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.addr_attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute2, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.addr_attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute3, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.addr_attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute4, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.addr_attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute5, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.addr_attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute6, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.addr_attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute7, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.addr_attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute8, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.addr_attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute9, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.addr_attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute10, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.addr_attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute11, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.addr_attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute12, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.addr_attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute13, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.addr_attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute14, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.addr_attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute15, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.addr_attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute16, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.addr_attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute17, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.addr_attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute18, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.addr_attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute19, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.addr_attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.addr_attribute20, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.add_information13, hr_api.g_varchar2) <>
     nvl(p_rec.add_information13, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.add_information14, hr_api.g_varchar2) <>
     nvl(p_rec.add_information14, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.add_information15, hr_api.g_varchar2) <>
     nvl(p_rec.add_information15, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.add_information16, hr_api.g_varchar2) <>
     nvl(p_rec.add_information16, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.add_information17, hr_api.g_varchar2) <>
     nvl(p_rec.add_information17, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.add_information18, hr_api.g_varchar2) <>
     nvl(p_rec.add_information18, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.add_information19, hr_api.g_varchar2) <>
     nvl(p_rec.add_information19, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.add_information20, hr_api.g_varchar2) <>
     nvl(p_rec.add_information20, hr_api.g_varchar2) or
     nvl(per_add_shd.g_old_rec.party_id, hr_api.g_number) <> -- HR/TCA merge
     nvl(p_rec.party_id, hr_api.g_number)
  then
    -- either the attribute_category or attribute1..30 have changed
    -- so we must call the flex stub
    per_add_flex.df(p_rec => p_rec);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end df_update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec               in out nocopy per_add_shd.g_rec_type
  ,p_effective_date    in date
  ,p_validate_county   in boolean          default true
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Validate Important Attributes
  --
  -- Reset global variable that indicates if payroll is installed under
  -- US legislation prior to validation.
  --
  g_us_payroll := NULL;
  --
  -- Call all supporting business operations.
  --
  -- if person_id is null, business_group_is isn't required
  -- by HR/TCA merge
  --
  if p_rec.person_id is not null then
    --
    -- Validate business group id
    --
    hr_api.validate_bus_grp_id(
      p_business_group_id  => p_rec.business_group_id
     ,p_associated_column1 => per_add_shd.g_tab_nam ||
                               '.BUSINESS_GROUP_ID'
    );
    hr_utility.set_location(l_proc, 20);
    --
    -- After validating the set of important attributes,
    -- if Mulitple message detection is enabled and at least
    -- one error has been found then abort further validation.
    --
    hr_multi_message.end_validation_set;
    --
  end if;
  --
  -- Validate Dependent Attributes
  --
  -- Validate date from
  --
  chk_date_from
    (p_address_id             => p_rec.address_id
    ,p_date_from              => p_rec.date_from
    ,p_date_to                => p_rec.date_to
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 30);
  -- HR/TCA merge
    --
    -- Validate business_group_id
    --
    chk_business_group_id
      (p_address_id            => p_rec.address_id
      ,p_object_version_number => p_rec.object_version_number
      ,p_person_id             => p_rec.person_id
      ,p_business_group_id     => p_rec.business_group_id
      );
    hr_utility.set_location(l_proc, 35);
  --
  if p_rec.person_id is not null then
    --
    -- Validate person_id
    --
    chk_person_id
      (p_address_id            => p_rec.address_id
      ,p_object_version_number => p_rec.object_version_number
      ,p_person_id             => p_rec.person_id
      ,p_business_group_id     => p_rec.business_group_id
      );
    hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Validate party_id
  --
  chk_party_id
    (p_rec
    );
  hr_utility.set_location(l_proc, 45);
  --
  -- Validate primary flag
  --
  chk_primary_flag
    (p_address_id            => p_rec.address_id
    ,p_object_version_number => p_rec.object_version_number
    ,p_primary_flag          => p_rec.primary_flag
    );
  hr_utility.set_location(l_proc, 50);
  --
  if not g_called_from_form then
  --
  -- Validate date/address_type combination
  -- Validate date/primary address combination
  --
  chk_date_comb
    (p_address_id             => p_rec.address_id
    ,p_address_type           => p_rec.address_type
    ,p_primary_flag           => p_rec.primary_flag
    ,p_date_from              => p_rec.date_from
    ,p_date_to                => p_rec.date_to
    ,p_person_id              => p_rec.person_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_party_id               => p_rec.party_id  -- HR/TCA merge
    );
  end if;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Validate style
  --
  chk_style
    (p_style              => p_rec.style
    );
  hr_utility.set_location(l_proc, 70);
  --
  -- Validate address type
  --
  chk_address_type
    (p_address_id             => p_rec.address_id
    ,p_address_type           => p_rec.address_type
    ,p_date_from              => p_rec.date_from
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_rec.object_version_number
    );
  hr_utility.set_location(l_proc, 80);
  --
  -- Validate country
  --
  chk_country
    (p_country                => p_rec.country
    ,p_style                  => p_rec.style
    ,p_address_id             => p_rec.address_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  hr_utility.set_location(l_proc, 90);
  --
  -- Validate postal code.
  --
  chk_postal_code
    (p_address_id             => p_rec.address_id
    ,p_style                  => p_rec.style
    ,p_postal_code            => p_rec.postal_code
    ,p_business_group_id      => p_rec.business_group_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_town_or_city           => p_rec.town_or_city
    );
  --
  -- Validate taxation address zip.
  --
  If p_rec.style = 'US' and
     p_rec.primary_flag = 'Y' then
  chk_tax_address_zip
    (p_address_id             => p_rec.address_id
    ,p_style                  => p_rec.style
    ,p_tax_address_zip        => p_rec.add_information20
    ,p_business_group_id      => p_rec.business_group_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  End if;
  hr_utility.set_location(l_proc, 100);
  --
  -- Validation specific to GB, US, GENERIC
  --
  if p_rec.style = 'GB' or
     p_rec.style = 'US' or
     p_rec.style = 'GENERIC'
  then
    --
    -- Check null attributes for address style.
    --
    hr_utility.set_location(l_proc, 110);
    chk_style_null_attr
      (p_address_id             => p_rec.address_id
      ,p_object_version_number  => p_rec.object_version_number
      ,p_style                  => p_rec.style
      ,p_region_2               => p_rec.region_2
      ,p_region_3               => p_rec.region_3
      ,p_telephone_number_3     => p_rec.telephone_number_3
      );
    hr_utility.set_location(l_proc, 120);
    --
    -- Validate address_line1
    --
    chk_address_line1
      (p_address_id             => p_rec.address_id
      ,p_style                  => p_rec.style
      ,p_address_line1          => p_rec.address_line1
      ,p_object_version_number  => p_rec.object_version_number
      );
    hr_utility.set_location(l_proc, 130);
    --
    -- Validate date_to
    --
    -- No procedural call is made to the procedure
    -- chk_date_to as the insert logic is handled
    -- by chk_date_from
    --
    -- Validate region 1.
    --
    chk_region_1
      (p_address_id             => p_rec.address_id
      ,p_style                  => p_rec.style
      ,p_region_1               => p_rec.region_1
      ,p_business_group_id      => p_rec.business_group_id
      ,p_effective_date         => p_effective_date
      ,p_object_version_number  => p_rec.object_version_number
      ,p_validate_county        => p_validate_county
      );
    --
    -- Validate tax_county
    --
  If p_rec.style = 'US' and
     p_rec.primary_flag = 'Y'
  Then
    chk_tax_county
      (p_address_id             => p_rec.address_id
      ,p_style                  => p_rec.style
      ,p_tax_county             => p_rec.add_information19
      ,p_business_group_id      => p_rec.business_group_id
      ,p_effective_date         => p_effective_date
      ,p_object_version_number  => p_rec.object_version_number
      );
  End if;
    hr_utility.set_location(l_proc, 140);
    --
    -- Validate region 2.
    --
    chk_region_2
      (p_address_id             => p_rec.address_id
      ,p_style                  => p_rec.style
      ,p_region_2               => p_rec.region_2
      ,p_business_group_id      => p_rec.business_group_id
      ,p_effective_date         => p_effective_date
      ,p_object_version_number  => p_rec.object_version_number
      );
    hr_utility.set_location(l_proc, 150);
    --
    -- Validate tax_state(add_information17)
    --
  If p_rec.style = 'US' and
     p_rec.primary_flag = 'Y'
  Then
    chk_tax_state
      (p_address_id             => p_rec.address_id
      ,p_style                  => p_rec.style
      ,p_tax_state              => p_rec.add_information17
      ,p_business_group_id      => p_rec.business_group_id
      ,p_effective_date         => p_effective_date
      ,p_object_version_number  => p_rec.object_version_number
      );
    hr_utility.set_location(l_proc, 155);
  End if;
  --
    -- Validate town or city.
    --
    chk_town_or_city
      (p_address_id             => p_rec.address_id
      ,p_style                  => p_rec.style
      ,p_town_or_city           => p_rec.town_or_city
      ,p_business_group_id      => p_rec.business_group_id
      ,p_object_version_number  => p_rec.object_version_number
      );
    hr_utility.set_location(l_proc, 160);
    --
    -- Validate tax_city (add_information18).
    --
    If p_rec.style = 'US' and
       p_rec.primary_flag = 'Y' then
    chk_tax_city
      (p_address_id             => p_rec.address_id
      ,p_style                  => p_rec.style
      ,p_tax_city               => p_rec.add_information18
      ,p_business_group_id      => p_rec.business_group_id
      ,p_object_version_number  => p_rec.object_version_number
      );
    hr_utility.set_location(l_proc, 165);
    End if;
    --
    --
    -- This is only applicable if payroll is installed under US legislation
    -- and address style is 'US'.
    -- Validate city(town_or_city) and state(region_1)
    -- combination.
    --
    chk_city_state_zip_comb
      (p_address_id             => p_rec.address_id
      ,p_style                  => p_rec.style
      ,p_postal_code            => p_rec.postal_code
      ,p_region_1               => p_rec.region_1
      ,p_region_2               => p_rec.region_2
      ,p_town_or_city           => p_rec.town_or_city
      ,p_business_group_id      => p_rec.business_group_id
      ,p_object_version_number  => p_rec.object_version_number
      );
    hr_utility.set_location(l_proc, 170);
    --
    chk_tax_city_state_zip_comb
      (p_address_id             => p_rec.address_id
      ,p_style                  => p_rec.style
      ,p_tax_zip                => p_rec.add_information20
      ,p_tax_county             => p_rec.add_information19
      ,p_tax_state              => p_rec.add_information17
      ,p_tax_city               => p_rec.add_information18
      ,p_business_group_id      => p_rec.business_group_id
      ,p_object_version_number  => p_rec.object_version_number
      );
    hr_utility.set_location(l_proc, 175);
    --Validation specific to JP
    --
/* Bug 1677965
  elsif p_rec.style = 'JP' then
    hr_utility.set_location(l_proc, 21);
    --
    -- Check the combination checking for town_or_city(district_code)
    -- address_line1, and region_1
    --
    chk_address1_towncity_comb
      (p_business_group_id       => p_rec.business_group_id
      ,p_address_id              => p_rec.address_id
      ,p_object_version_number   => p_rec.object_version_number
      ,p_town_or_city            => p_rec.town_or_city
      ,p_address_line1           => p_rec.address_line1
      ,p_region_1                => p_rec.region_1
      );
    hr_utility.set_location(l_proc, 180);
    --
    -- Validate region_2 according to address_line2
    --
    chk_address2_region2_comb
      (p_address_id              => p_rec.address_id
      ,p_object_version_number   => p_rec.object_version_number
      ,p_address_line2           => p_rec.address_line2
      ,p_region_2                => p_rec.region_2
      );
    hr_utility.set_location(l_proc, 190);
    --
    -- Validate region_3 according to address_line3
    --
    chk_address3_region3_comb
      (p_address_id              => p_rec.address_id
      ,p_object_version_number   => p_rec.object_version_number
      ,p_address_line3           => p_rec.address_line3
      ,p_region_3                => p_rec.region_3
      );
    hr_utility.set_location(l_proc, 200);
*/
  --
  -- DDF Validation other than GB, US, JP and GENERIC
  --
  else
    hr_utility.set_location(l_proc, 205);
    --
    --  Validate the DDF
    --
    chk_ddf
      (p_rec => p_rec
      );
    --
  end if;
  --
  --  Validate the DDF
  --
  chk_df
    (p_rec => p_rec
    );
  hr_utility.set_location(' Leaving:'||l_proc, 210);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                in out nocopy per_add_shd.g_rec_type
  ,p_effective_date     in date
  ,p_prflagval_override in boolean      default false
  ,p_validate_county    in boolean      default true
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Validate Important Attributes
  --
  -- Reset global variable that indicates if payroll is installed under
  -- US legislation prior to validation.
  --
  g_us_payroll := NULL;
  --
  -- Call all supporting business operations. Mapping to the
  -- appropriate Business Rules in peradd.bru is provided.
  --
  -- Check that the columns which cannot
  -- be updated have not changed
  --
  check_non_updateable_args(p_rec => p_rec);
  hr_utility.set_location(l_proc, 15);
  --
  -- if person_id isn't specified,business_group_id isn't required.
  -- HR/TCA merge
  if p_rec.person_id is not null then
    --
    -- Validate business group id
    --
    hr_api.validate_bus_grp_id(
      p_business_group_id  => p_rec.business_group_id
     ,p_associated_column1 => per_add_shd.g_tab_nam ||
                               '.BUSINESS_GROUP_ID'
    );
    hr_utility.set_location(l_proc, 20);
    --
    -- After validating the set of important attributes,
    -- if Mulitple message detection is enabled and at least
    -- one error has been found then abort further validation.
    --
    hr_multi_message.end_validation_set;
    --
  end if;
  --
  -- HR/TCA merge
    --
    -- Validate business_group_id
    --
    chk_business_group_id
      (p_address_id            => p_rec.address_id
      ,p_object_version_number => p_rec.object_version_number
      ,p_person_id             => p_rec.person_id
      ,p_business_group_id     => p_rec.business_group_id
      );
    hr_utility.set_location(l_proc, 22);
  --
  if p_rec.person_id is not null then      -- If condition added for 2762677
    --
    -- Validate person_id
    --
    chk_person_id
      (p_address_id            => p_rec.address_id
      ,p_object_version_number => p_rec.object_version_number
      ,p_person_id             => p_rec.person_id
      ,p_business_group_id     => p_rec.business_group_id
      );
    hr_utility.set_location(l_proc, 25);
  end if;
  --
  -- Validate Dependent Attributes
  --
  -- Validate date from
  --
  chk_date_from
    (p_address_id             => p_rec.address_id
    ,p_date_from              => p_rec.date_from
    ,p_date_to                => p_rec.date_to
    ,p_object_version_number  => p_rec.object_version_number
    );
  hr_utility.set_location(l_proc, 30);
  --
  -- Validate country.
  --
  chk_country
    (p_country                => p_rec.country
    ,p_style                  => p_rec.style
    ,p_address_id             => p_rec.address_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  hr_utility.set_location(l_proc, 40);
  --
  -- Validate address type.
  --
  chk_address_type
    (p_address_id             => p_rec.address_id
    ,p_address_type           => p_rec.address_type
    ,p_date_from              => p_rec.date_from
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_rec.object_version_number
    );
  hr_utility.set_location(l_proc, 50);
  --
  -- Validate primary flag
  --
  chk_primary_flag
    (p_address_id            => p_rec.address_id
    ,p_object_version_number => p_rec.object_version_number
    ,p_primary_flag          => p_rec.primary_flag
    );
  hr_utility.set_location(l_proc, 50);
  --
  --
  --
  if not g_called_from_form then
  --
  -- Validate date/address_type combination
  -- Validate date/primary address combination
  --
  chk_date_comb
    (p_address_id            => p_rec.address_id
    ,p_address_type          => p_rec.address_type
    ,p_primary_flag          => p_rec.primary_flag
    ,p_date_from             => p_rec.date_from
    ,p_date_to               => p_rec.date_to
    ,p_person_id             => p_rec.person_id
    ,p_object_version_number => p_rec.object_version_number
    ,p_prflagval_override    => p_prflagval_override
    ,p_party_id              => p_rec.party_id  -- HR/TCA merge
    );
  end if;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Validate postal code.
  --
  chk_postal_code
    (p_address_id             => p_rec.address_id
    ,p_style                  => p_rec.style
    ,p_postal_code            => p_rec.postal_code
    ,p_business_group_id      => p_rec.business_group_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_town_or_city           => p_rec.town_or_city
    );
  hr_utility.set_location(l_proc, 70);
  --
  -- Validate tax address zip.
  --
  If p_rec.style = 'US' and
     p_rec.primary_flag = 'Y' then
  chk_tax_address_zip
    (p_address_id             => p_rec.address_id
    ,p_style                  => p_rec.style
    ,p_tax_address_zip        => p_rec.add_information20
    ,p_business_group_id      => p_rec.business_group_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  hr_utility.set_location(l_proc, 71);
  End if;
  --
  -- Validate date to.
  --
  chk_date_to
    (p_address_id             => p_rec.address_id
    ,p_date_from              => p_rec.date_from
    ,p_date_to                => p_rec.date_to
    ,p_object_version_number  => p_rec.object_version_number
    );
  hr_utility.set_location(l_proc, 80);
  --
  --
  -- Validation specific to GB, US, GENERIC
  --
  if p_rec.style = 'GB' or
     p_rec.style = 'US' or
     p_rec.style = 'GENERIC'
  then
    --
    -- Validate region 1.
    --
    chk_region_1
      (p_address_id             => p_rec.address_id
      ,p_style                  => p_rec.style
      ,p_region_1               => p_rec.region_1
      ,p_business_group_id      => p_rec.business_group_id
      ,p_effective_date         => p_effective_date
      ,p_object_version_number  => p_rec.object_version_number
      ,p_validate_county      => p_validate_county
      );
    hr_utility.set_location(l_proc, 90);
  If p_rec.style = 'US' and
     p_rec.primary_flag = 'Y' then
   chk_tax_county
      (p_address_id             => p_rec.address_id
      ,p_style                  => p_rec.style
      ,p_tax_county             => p_rec.add_information19
      ,p_business_group_id      => p_rec.business_group_id
      ,p_effective_date         => p_effective_date
      ,p_object_version_number  => p_rec.object_version_number
      );
    hr_utility.set_location(l_proc, 91);
  End if;
  --
    -- Validate region 2.
    --
    chk_region_2
      (p_address_id             => p_rec.address_id
      ,p_style                  => p_rec.style
      ,p_region_2               => p_rec.region_2
      ,p_business_group_id      => p_rec.business_group_id
      ,p_effective_date         => p_effective_date
      ,p_object_version_number  => p_rec.object_version_number
      );
    hr_utility.set_location(l_proc, 100);
    --
    -- Validate tax_state(add_information17).
    --
  If p_rec.style = 'US' and
     p_rec.primary_flag = 'Y' then
    chk_tax_state
      (p_address_id             => p_rec.address_id
      ,p_style                  => p_rec.style
      ,p_tax_state              => p_rec.add_information17
      ,p_business_group_id      => p_rec.business_group_id
      ,p_effective_date         => p_effective_date
      ,p_object_version_number  => p_rec.object_version_number
      );
    hr_utility.set_location(l_proc, 105);
  End if;
  --
    -- Validate town or city.
    --
    chk_town_or_city
      (p_address_id             => p_rec.address_id
      ,p_style                  => p_rec.style
      ,p_town_or_city           => p_rec.town_or_city
      ,p_business_group_id      => p_rec.business_group_id
      ,p_object_version_number  => p_rec.object_version_number
      );
    hr_utility.set_location(l_proc, 110);
    --
    -- Validate tax_city.
    --
  If p_rec.style = 'US' and
     p_rec.primary_flag = 'Y' then
    chk_tax_city
      (p_address_id             => p_rec.address_id
      ,p_style                  => p_rec.style
      ,p_tax_city               => p_rec.add_information18
      ,p_business_group_id      => p_rec.business_group_id
      ,p_object_version_number  => p_rec.object_version_number
      );
    hr_utility.set_location(l_proc, 115);
  End if;
  --
    -- Validate address_line 1.
    --
    chk_address_line1
      (p_address_id             => p_rec.address_id
      ,p_style                  => p_rec.style
      ,p_address_line1          => p_rec.address_line1
      ,p_object_version_number  => p_rec.object_version_number
      );
    hr_utility.set_location(l_proc, 120);
    --
    -- Check null attributes for address style.
    --
    chk_style_null_attr
      (p_address_id             => p_rec.address_id
      ,p_object_version_number  => p_rec.object_version_number
      ,p_style                  => p_rec.style
      ,p_region_2               => p_rec.region_2
      ,p_region_3               => p_rec.region_3
      ,p_telephone_number_3     => p_rec.telephone_number_3
      );
    hr_utility.set_location(l_proc, 130);
    --
    -- This is only applicable if payroll is installed under US legislation
    -- and address style is 'US'.
    -- Validate city(town_or_city) and state(region_2)
    -- and zip code(postal_code) combination.
    --
    chk_city_state_zip_comb
      (p_address_id             => p_rec.address_id
      ,p_style                  => p_rec.style
      ,p_postal_code            => p_rec.postal_code
      ,p_region_1               => p_rec.region_1
      ,p_region_2               => p_rec.region_2
      ,p_town_or_city           => p_rec.town_or_city
      ,p_business_group_id      => p_rec.business_group_id
      ,p_object_version_number  => p_rec.object_version_number
      );
    hr_utility.set_location(l_proc, 140);
    --
  If p_rec.style = 'US' and
     p_rec.primary_flag = 'Y' then
    chk_tax_city_state_zip_comb
      (p_address_id             => p_rec.address_id
      ,p_style                  => p_rec.style
      ,p_tax_zip                => p_rec.add_information20
      ,p_tax_county             => p_rec.add_information19
      ,p_tax_state              => p_rec.add_information17
      ,p_tax_city               => p_rec.add_information18
      ,p_business_group_id      => p_rec.business_group_id
      ,p_object_version_number  => p_rec.object_version_number
      );
    hr_utility.set_location(l_proc, 145);
  End if;
/* Bug 1677965
  elsif p_rec.style = 'JP' then
    hr_utility.set_location(l_proc, 150);
    --
    -- Check the combination checking for town_or_city(district_code)
    -- address_line1, and region_1
    --
    chk_address1_towncity_comb
      (p_business_group_id       => p_rec.business_group_id
      ,p_address_id              => p_rec.address_id
      ,p_object_version_number   => p_rec.object_version_number
      ,p_town_or_city            => p_rec.town_or_city
      ,p_address_line1           => p_rec.address_line1
      ,p_region_1                => p_rec.region_1
      );
    hr_utility.set_location(l_proc, 160);
    --
    -- Validate region_2 according to address_line2
    --
    chk_address2_region2_comb
      (p_address_id              => p_rec.address_id
      ,p_object_version_number   => p_rec.object_version_number
      ,p_address_line2           => p_rec.address_line2
      ,p_region_2                => p_rec.region_2
      );
    hr_utility.set_location(l_proc, 170);
    --
    -- Validate region_3 according to address_line3
    --
    chk_address3_region3_comb
      (p_address_id              => p_rec.address_id
      ,p_object_version_number   => p_rec.object_version_number
      ,p_address_line3           => p_rec.address_line3
      ,p_region_3                => p_rec.region_3
      );
    hr_utility.set_location(l_proc, 180);
*/
  --
  -- DDF Validation other than GB, US, JP and GENERIC
  --
  else
    hr_utility.set_location(l_proc, 185);
    --
    --  Validate the DDF
    --
    chk_ddf
      (p_rec => p_rec
      );
    --
  end if;
  --
  --  Validate the DDF
  --
  chk_df
    (p_rec => p_rec
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 190);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in out nocopy per_add_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations. Mapping to the
  -- appropriate business rules on peradd.bru is provided
  --
  -- Check that deletion of a primary address is not allowed
  -- if non primary addresses exist within the same date range
  -- as the primary address
  --
  chk_del_address;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_address_id              in number
  ) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups  pbg
         , per_addresses        adr
     where adr.address_id        = p_address_id
       and pbg.business_group_id = adr.business_group_id;

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
                             p_argument       => 'address_id',
                             p_argument_value => p_address_id);
--
  if nvl(g_address_id, hr_api.g_number) = p_address_id then
    --
    -- The legislation has already been found with a previous
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
  --
  open csr_leg_code;
  fetch csr_leg_code into l_legislation_code;
  if csr_leg_code%notfound then
    close csr_leg_code;
    --
    -- WWBUG 2203479
    -- Special hack for irecruitment addresses
    --
    return null;
     --
     -- The primary key is invalid therefore we must error
     --
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.set_location(l_proc, 30);
     hr_utility.raise_error;
  end if;
  --
  close csr_leg_code;
  --
  g_address_id:= p_address_id;
  g_legislation_code := l_legislation_code;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  end if;
  return l_legislation_code;
end return_legislation_code;
--
--
end per_add_bus;

/
