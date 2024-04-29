--------------------------------------------------------
--  DDL for Package Body PER_KAD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_KAD_BUS" as
/* $Header: pekadrhi.pkb 115.6 2002/12/06 11:27:37 pkakar ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package    varchar2(33)	:= '  per_kad_bus.';  -- Global package name
--
--  This variable indicates if payroll is installed under US legislation.
--  The function that returns this value is called in the validation procedures.
--  To prevent the identical sql from executing multiple times, this variable
--  is checked when the function is called and if not null, the sql is bypassed.
--
g_us_payroll varchar2(1) default null;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_person_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that a person id exists in table per_people_f.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_person_id
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
   (p_person_id   in per_addresses.person_id%TYPE) is
--
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'chk_person_id';
--
   cursor csr_valid_pers is
     select null
     from per_people_f ppf
     where ppf.person_id = p_person_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person_id'
    ,p_argument_value => p_person_id
    );
  hr_utility.set_location(l_proc, 2);
  --
  -- Check that the Person ID is linked to a
  -- valid person on PER_PEOPLE_F
  --
  open csr_valid_pers;
  fetch csr_valid_pers into l_exists;
  if csr_valid_pers%notfound then
    close csr_valid_pers;
    hr_utility.set_message(801, 'HR_7298_ADD_PERSON_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_valid_pers;
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
end chk_person_id;
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
  l_api_updating := per_kad_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
       nvl(per_kad_shd.g_old_rec.address_type, hr_api.g_varchar2) <>
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
       if hr_api.not_exists_in_hr_lookups
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
  l_api_updating := per_kad_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
       nvl(per_kad_shd.g_old_rec.country, hr_api.g_varchar2) <>
       nvl(p_country, hr_api.g_varchar2)) or
      (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 2);
    --
    -- Checks that value for country is a valid
    -- country on fnd_territories
    --
    if p_style = 'US' or
       p_style = 'GB' then
/*       (p_style = 'JP' and p_country is not null) then */
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
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for date to has changed
  --
  l_api_updating := per_kad_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);
--
  if ((l_api_updating and
       nvl(per_kad_shd.g_old_rec.date_to, hr_api.g_eot) <>
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
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
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
  l_api_updating := per_kad_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and per_kad_shd.g_old_rec.date_from <> p_date_from) or
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
end chk_date_from;
--
--  ---------------------------------------------------------------------------
--  |-----------------------------<  chk_style >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates:
--      -  only 'GB', 'US' , 'JP' and 'GENERIC' address styles are entered.
--      -  a flex structure exists for a given style.
--      -  the columns that should not be populated if address style is 'GB',
--         'US' or 'GENERIC'.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_style
--
--  Post Success:
--    Processing continues if:
--      - the address style is 'GB', 'US' and 'GENERIC'.
--      - a flex structure does exist in fnd_descr_flex_contexts for the given
--        territory code.
--
--  Post Failure:
--    An application error is raised and processing terminates if:
--      - the style entered is not 'GB', 'US' and 'GENERIC'.
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
    -- Only the style 'GB','US','JP' and 'GENERIC' are accepted by the API
    --
  if    p_style <> 'GB'
    and p_style <> 'US'
    and p_style <> 'JP'
    and p_style <> 'GENERIC' then
    hr_utility.set_message(801, 'HR_7297_API_ARG_ONLY');
    hr_utility.set_message_token('ARG_NAME', 'ADDRESS_STYLE');
    hr_utility.set_message_token('ARG_ONLY', 'GB, US, JP or GENERIC');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 4);
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
-- 09/12/97 Change Begins
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
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check 'GB' address style
  --
  if p_style = 'GB' then
    if p_region_2 is not null then
      l_token := 'region_2';
      raise l_error;
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
    if p_telephone_number_3 is not null and
       nvl(per_add_shd.g_old_rec.telephone_number_3, hr_api.g_varchar2)
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
       hr_utility.raise_error;
    when others then
       raise;
  --
  -- 09/12/97 Change Ends
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
  l_api_updating := per_kad_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
       nvl(per_kad_shd.g_old_rec.address_line1, hr_api.g_varchar2) <>
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
  hr_utility.set_location(' Leaving:'|| l_proc, 5);
end chk_address_line1;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_half_kana >---------------------------------|
-- ----------------------------------------------------------------------------
/* procedure chk_half_kana(p_string in varchar2) is

  l_strlen number := length(p_string);
  l_ch varchar2(2);
  l_correct BOOLEAN := TRUE;
  i number := 1;
	l_proc varchar2(72)  :=  g_package||'chk_half_kana';

begin
-- make sure that all the characters are half kana kana

  hr_utility.set_location('Entering:'|| l_proc, 1);

  while i <= l_strlen and l_correct loop
    l_ch := substr(p_string, i, 1);
    if l_ch between ' '  and '~' then
      NULL;
    else
      l_correct := FALSE;
    end if;
    i := i + 1;
  end loop;

  hr_utility.set_location(l_proc, 2);

  if not l_correct then
    hr_utility.set_message(801, 'HR_51692_ADD_INVALID_KANA');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
end chk_half_kana;
--
-- ----------------------------------------------------------------------------
-- |------------------------<chk_address1_towncity_comb  >--------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_address1_towncity_comb(
  p_address_id             in per_addresses.address_id%TYPE,
  p_object_version_number  in per_addresses.object_version_number%TYPE,
  p_town_or_city           in out nocopy per_addresses.town_or_city%type,
  p_address_line1          in out nocopy per_addresses.address_line1%type,
  p_region_1               in out nocopy per_addresses.region_1%type) is

--	p_town_or_city	===> district_code
--	p_address_line1	===> address_line1
--	p_region_1      ===> address_line1_kana

  cursor c1 is 	select * from per_jp_address_lookups
                where district_code = p_town_or_city;
  cursor c2 is 	select * from per_jp_address_lookups
                where address_line1 = p_address_line1;

  jp_address_rec  per_jp_address_lookups%rowtype;
  l_api_updating  boolean;
  l_proc          varchar2(72) := g_package||'chk_address1_towncity_comb';

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for town_or_city, address_line1, or region_1 have changed
  --
  l_api_updating := per_kad_shd_t.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);

  if ((l_api_updating and
         (nvl(per_kad_shd_t.g_old_rec.town_or_city, hr_api.g_varchar2)  <>
            nvl(p_town_or_city, hr_api.g_varchar2)  or
          nvl(per_kad_shd_t.g_old_rec.address_line1, hr_api.g_varchar2) <>
            nvl(p_address_line1, hr_api.g_varchar2) or
          nvl(per_kad_shd_t.g_old_rec.region_1, hr_api.g_varchar2)      <>
            nvl(p_region_1, hr_api.g_varchar2)
     )) or (NOT l_api_updating)) then

    hr_utility.set_location(l_proc, 2);

    if p_town_or_city is not NULL then
      hr_utility.set_location(l_proc, 3);
      open c1;
      fetch c1 into jp_address_rec;
      if c1%notfound then
        hr_utility.set_message(801, 'HR_51693_ADD_INVALID_DISTCODE');
        hr_utility.raise_error;
      end if;
      close c1;

      if p_address_line1 is not null and
         p_address_line1 <> jp_address_rec.address_line1 then

        hr_utility.set_message(801, 'HR_51694_ADD_INVALID_ADD_LINE1');
        hr_utility.raise_error;
      end if;
      p_address_line1 := jp_address_rec.address_line1;

    elsif p_address_line1 is not NULL then
      hr_utility.set_location(l_proc, 4);
      open c2;
      fetch c2 into jp_address_rec;
      if c2%notfound then
        hr_utility.set_message(801, 'HR_51694_ADD_INVALID_ADD_LINE1');
        hr_utility.raise_error;
      end if;
      close c2;
      p_town_or_city := jp_address_rec.district_code;

    else
      hr_utility.set_message(801, 'HR_51695_ADD_DIST_ADD1_NULL');
      hr_utility.raise_error;
    end if;

    if p_region_1 is not null and p_region_1 <>
       jp_address_rec.address_line1_kana then
      hr_utility.set_message(801, 'HR_51696_ADD_INVALID_ADD1_KANA');
      hr_utility.raise_error;
    end if;
    p_region_1 := jp_address_rec.address_line1_kana;
  end if;
  hr_utility.set_location('Leaving:'|| l_proc, 5);
end chk_address1_towncity_comb;
--
-- ----------------------------------------------------------------------------
-- |------------------------<chk_address2_region2_comb  >---------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_address2_region2_comb(
  p_address_id             in per_addresses.address_id%TYPE,
  p_object_version_number  in per_addresses.object_version_number%TYPE,
  p_address_line2	         in per_addresses.address_line2%type,
  p_region_2			         in per_addresses.region_2%type) is

--	p_address_line2 ===> address_line2
--	p_region_2      ===> address_line2_kana

  l_api_updating  boolean;
  l_proc  varchar2(72) := g_package||'chk_address2_region2_comb';

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for address_line2, or region_2 have changed
  --
  l_api_updating := per_kad_shd_t.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);

  if ((l_api_updating and
         (nvl(per_kad_shd_t.g_old_rec.address_line2, hr_api.g_varchar2)  <>
            nvl(p_address_line2, hr_api.g_varchar2)  or
          nvl(per_kad_shd_t.g_old_rec.region_2, hr_api.g_varchar2) <>
            nvl(p_region_2, hr_api.g_varchar2)
     )) or (NOT l_api_updating)) then

    hr_utility.set_location(l_proc, 2);

    if p_address_line2 is NULL and p_region_2 is not NULL then
      hr_utility.set_message(801, 'HR_51697_ADD_REGION2_NOT_NULL');
      hr_utility.raise_error;
    end if;
    chk_half_kana(p_region_2);
  end if;

  hr_utility.set_location('Leaving:'|| l_proc, 3);
end chk_address2_region2_comb;
--
-- ----------------------------------------------------------------------------
-- |------------------------<chk_address3_region3_comb  >---------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_address3_region3_comb(
  p_address_id             in per_addresses.address_id%TYPE,
  p_object_version_number  in per_addresses.object_version_number%TYPE,
  p_address_line3          in per_addresses.address_line3%type,
  p_region_3               in per_addresses.region_3%type) is

--	p_address_line3	===> address_line3
--	p_region_3      ===> address_line3_kana

  l_api_updating  boolean;
  l_proc  varchar2(72) := g_package||'chk_address3_region3_comb';

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for address_line3, or region_3 have changed
  --
  l_api_updating := per_kad_shd_t.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);

  if ((l_api_updating and
         (nvl(per_kad_shd_t.g_old_rec.address_line3, hr_api.g_varchar2)  <>
            nvl(p_address_line3, hr_api.g_varchar2)  or
          nvl(per_kad_shd_t.g_old_rec.region_3, hr_api.g_varchar2) <>
            nvl(p_region_3, hr_api.g_varchar2)
     )) or (NOT l_api_updating)) then

    hr_utility.set_location(l_proc, 2);

    if p_address_line3 is NULL and p_region_3 is not NULL then
      hr_utility.set_message(801, 'HR_51698_ADD_REGION3_NOT_NULL');
      hr_utility.raise_error;
    end if;
    chk_half_kana(p_region_3);
  end if;

  hr_utility.set_location('Leaving:'|| l_proc, 1);
end chk_address3_region3_comb;
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_jp_postal_code >----------------------------|
-- ----------------------------------------------------------------------------

procedure chk_jp_postal_code(p_string in varchar2) is

  l_ch  varchar2(2);
  l_correct  BOOLEAN := TRUE;
  l_strlen  number := length(p_string);
  l_proc  varchar2(72)  :=  g_package||'chk_jp_postal_code';

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

  if l_strlen <> 3 and l_strlen <> 6 then
    hr_utility.set_message(801, 'HR_51699_ADD_');
    hr_utility.raise_error;
  end if;

-- checking the first 3 characters

  hr_utility.set_location(l_proc, 2);
  for i in 1..3 loop
    if substr(p_string, i, 1) between '0' and '9' then
      NULL;
    else
      hr_utility.set_message(801, 'HR_51699_ADD_INVALID_POST_CODE');
      hr_utility.raise_error;
    end if;
  end loop;

  if l_strlen = 6 then
    hr_utility.set_location(l_proc, 3);

-- checking the 4th character

    l_ch := substr(p_string, 4, 1);
    if l_ch = '-' then
      NULL;
    else
      hr_utility.set_message(801, 'HR_51699_ADD_INVALID_POST_CODE');
      hr_utility.raise_error;
    end if;

-- checking the last 2 characters

    for i in 5..6 loop
      if substr(p_string, i, 1) between '0' and '9' then
        NULL;
      else
      hr_utility.set_message(801, 'HR_51699_ADD_INVALID_POST_CODE');
      hr_utility.raise_error;
      end if;
    end loop;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 4);
end chk_jp_postal_code;
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
--      - if US payroll is installed, postal code is mandatory.
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
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_postal_code
  (p_address_id             in per_addresses.address_id%TYPE
  ,p_style                  in per_addresses.style%TYPE
  ,p_postal_code            in per_addresses.postal_code%TYPE
  ,p_business_group_id      in per_addresses.business_group_id%TYPE
  ,p_object_version_number  in per_addresses.object_version_number%TYPE)
   is
--
   l_proc           varchar2(72)  :=  g_package||'chk_postal_code';
   l_api_updating   boolean;
   l_postal_code_1  varchar2(5);
   l_postal_code_2  varchar2(1);
   l_postal_code_3  varchar2(4);
   l_geocodes_installed  varchar2(1);  -- 09/12/97 Changed
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
  l_api_updating := per_kad_shd.api_updating
         (p_address_id              =>  p_address_id
         ,p_object_version_number   =>  p_object_version_number);
  --
  if ((l_api_updating
       and nvl(per_kad_shd.g_old_rec.postal_code, hr_api.g_varchar2) <>
           nvl(p_postal_code, hr_api.g_varchar2)) or
      (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 2);
  --
  --  Check if US payroll is installed.
  --
  -- 09/12/97 Change Begins
  l_geocodes_installed := hr_general.chk_geocodes_installed;
  -- 09/12/97 Change Ends
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
      elsif p_style = 'US' then
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
    /*  elsif p_style = 'JP' then
        hr_utility.set_location(l_proc, 8);
        chk_jp_postal_code(p_postal_code); */
      end if;
    --
    --  If style is US and US payroll is installed, postal_code is mandatory.
    --
    else
     if    p_style = 'US'
       and l_geocodes_installed = 'Y' then   -- 09/12/97 Changed
       hr_utility.set_message(801, 'HR_51195_ADD_INVALID_ZIP_CODE');
       hr_utility.raise_error;
     end if;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 9);
end chk_postal_code;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_region_1 >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    If address style is 'GB' then validates that a region_1 code exists in
--    table hr_lookups.
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
--
--  Post Success:
--    If address style is 'GB' and a row does exist in hr_lookups
--    for the given region_1 code, processing continues.
--    If address style is 'US' and a row does exist in pay_us_counties
--    for the given region_1 code, processing continues.
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
  ,p_object_version_number  in per_addresses.object_version_number%TYPE)
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
  l_api_updating := per_kad_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
       nvl(per_kad_shd.g_old_rec.region_1, hr_api.g_varchar2) <>
       nvl(p_region_1, hr_api.g_varchar2)) or
      (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 2);
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
          --  Error: Invalid region 1.
          hr_utility.set_message(801, 'HR_7307_ADD_GB_REGION_1');
          hr_utility.raise_error;
        end if;
      end if;
      --
      -- Style is US and payroll is installed under US legislation.
      -- Region 1 is mandatory.
      --
      if p_style = 'US' then
      --
      --  If US payroll is installed.
      --
        if hr_general.chk_geocodes_installed = 'Y' then -- 09/12/97 Chg
          hr_utility.set_location(l_proc, 5);
          open csr_valid_us_county;
          fetch csr_valid_us_county into l_exists;
          if csr_valid_us_county%notfound then
            close csr_valid_us_county;
            hr_utility.set_message(801, 'HR_7953_ADDR_NO_COUNTY_FOUND');
            hr_utility.raise_error;
          end if;
        end if;
      end if;
    --
    end if;
  --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 6);
end chk_region_1;
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
  ,p_object_version_number  in per_addresses.object_version_number%TYPE)
   is
--
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'chk_region_2';
   l_api_updating   boolean;
   l_geocodes_installed varchar2(1);  -- 09/12/97 Changed
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
  l_api_updating := per_kad_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
       nvl(per_kad_shd.g_old_rec.region_2, hr_api.g_varchar2) <>
       nvl(p_region_2, hr_api.g_varchar2)) or
      (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 2);
    --
    -- Check if US payroll is installed.
    --
    if p_style = 'US' then
      -- 09/12/97 Change Begins
      l_geocodes_installed := hr_general.chk_geocodes_installed;
      -- 09/12/97 Change Ends
    end if;
    --
    -- Check that value for region_2 is valid.
    --
    if p_region_2 is not null then
      hr_utility.set_location(l_proc, 3);
      --
      if    p_style = 'US'
        and l_geocodes_installed = 'N' then   -- 09/12/97 Changed
        hr_utility.set_location(l_proc, 4);
        --
          if hr_api.not_exists_in_hr_lookups
            (p_effective_date => p_effective_date
            ,p_lookup_type    => 'US_STATE'
            ,p_lookup_code    => p_region_2
            ) then
          --
          --  Error: Invalid region 2.
          hr_utility.set_message(801, 'HR_7952_ADDR_NO_STATE_CODE');
          hr_utility.raise_error;
        end if;
      end if;
    end if;
    --
    --  If payroll is installed under US legislation.
    --
    if    p_style = 'US'
      and l_geocodes_installed = 'Y' then  -- 09/12/97 Changed
      hr_utility.set_location(l_proc, 5);
      --
      open csr_valid_state;
      fetch  csr_valid_state into l_exists;
      if csr_valid_state%notfound then
        close csr_valid_state;
        hr_utility.set_message(801, 'HR_7952_ADDR_NO_STATE_CODE');
        hr_utility.raise_error;
      end if;
      close csr_valid_state;
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 10);
end chk_region_2;
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
  l_api_updating := per_kad_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
       nvl(per_kad_shd.g_old_rec.town_or_city, hr_api.g_varchar2) <>
       nvl(p_town_or_city, hr_api.g_varchar2)) or
      (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 2);
    --
    --
    hr_utility.set_location(l_proc, 3);
    --
    if   p_style = 'US' then
      --
      -- If US payroll is installed.
      --
      if hr_general.chk_geocodes_installed = 'Y' then -- 09/12/97 Chg
        open csr_valid_town_or_city;
        fetch csr_valid_town_or_city into l_exists;
        if csr_valid_town_or_city%notfound then
          close csr_valid_town_or_city;
          hr_utility.set_message(801, 'HR_51276_ADD_INVALID_CITY');
          hr_utility.raise_error;
        end if;
        hr_utility.set_location(l_proc, 4);
      --
        close csr_valid_town_or_city;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 5);
end chk_town_or_city;
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_city_state_zip_comb >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates the city, state and zip code combination of a US
--    address if payroll is installed under US legislation.
--
--  Pre-conditions:
--    Style (p_style) must be valid and payroll is installed under
--    US legislation.
--
--  In Arguments:
--    p_address_id
--    p_style
--    p_postal_code
--    p_region_2
--    p_town_or_city
--    p_business_group_id
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - the city and state combination is valid.
--      - zip code is valid for the city and state.
--
--  Post Failure:
--    Processing terminates if:
--      - city and state combination is not valid.
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
  ,p_region_2               in per_addresses.region_2%TYPE
  ,p_town_or_city           in per_addresses.town_or_city%TYPE
  ,p_business_group_id      in per_addresses.business_group_id%TYPE
  ,p_object_version_number  in per_addresses.object_version_number%TYPE)
   is
--
   l_exists           varchar2(1);
   l_proc             varchar2(72)  :=  g_package||'chk_city_state_zip_comb';
   l_api_updating     boolean;
   l_city_code        pay_us_city_names.city_code%TYPE;
   l_state_code       pay_us_city_names.state_code%TYPE;
   l_postal_code      varchar2(6);
   l_geocodes_installed  varchar2(1);   -- 09/12/97 Changed
--
   cursor csr_valid_city_state is
   select cty.city_code,  cty.state_code
   from  pay_us_city_names cty
        ,pay_us_states st
   where cty.state_code = st.state_code
   and   st.state_abbrev = p_region_2
   and   cty.city_name = p_town_or_city;
--
   cursor csr_valid_zip_code is
   select null
   from  pay_us_zip_codes
   where state_code = l_state_code
   and   city_code = l_city_code
   and   l_postal_code between zip_start
   and   zip_end;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Only proceed with validation if :
  -- a) US address style and payroll is installed under US legislation and
  -- b) The current g_old_rec is current and
  -- c) The value for postal_code/region_2/town_or_city has changed.
  --
  l_api_updating := per_kad_shd.api_updating
         (p_address_id             => p_address_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
      (nvl(per_kad_shd.g_old_rec.region_2, hr_api.g_varchar2) <>
       nvl(p_region_2, hr_api.g_varchar2)) or
      (nvl(per_kad_shd.g_old_rec.postal_code, hr_api.g_varchar2) <>
       nvl(p_postal_code, hr_api.g_varchar2)) or
      (nvl(per_kad_shd.g_old_rec.town_or_city, hr_api.g_varchar2) <>
       nvl(p_town_or_city, hr_api.g_varchar2))) or
      (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc, 2);
    --
    -- Check if US payroll installed.
    --
    -- 09/12/97 Change Begins
    l_geocodes_installed := hr_general.chk_geocodes_installed;
    -- 09/12/97 Change Ends
    --
    --  If US address style and payroll, validate for right combination of
    --  city, state and county.
    --
    if  p_style = 'US'
    and l_geocodes_installed = 'Y' then   -- 09/12/97 Changed
      open csr_valid_city_state;
      fetch csr_valid_city_state into l_city_code
                                     ,l_state_code;
      if csr_valid_city_state%notfound then
        close csr_valid_city_state;
        hr_utility.set_message(801, 'HR_51771_ADD_CITY_NOT_IN_STATE');
        hr_utility.raise_error;
      end if;
      close csr_valid_city_state;
      hr_utility.set_location(l_proc, 3);
      --
      --   Check if zip code is valid for city and state.
      --   Only the first 5 characters are used.
      --
      l_postal_code := substr(p_postal_code,1,5);
      --
      open csr_valid_zip_code;
      fetch csr_valid_zip_code into l_exists;
      if csr_valid_zip_code%notfound then
        close csr_valid_zip_code;
        hr_utility.set_message(801, 'HR_51282_ADD_INV_ZIP_FOR_CITY');
        hr_utility.raise_error;
      end if;
      close csr_valid_zip_code;
      hr_utility.set_location(l_proc, 4);
    end if;
    --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 5);
--
end chk_city_state_zip_comb;
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
     where pa.date_from between per_kad_shd.g_old_rec.date_from
                            and l_date
     and pa.person_id = per_kad_shd.g_old_rec.person_id
     and pa.primary_flag = 'N';
--
   cursor csr_no_del_contig_add is
     select null
     from  sys.dual
     where exists(select null
                  from   per_addresses pa2
                  where  pa2.date_from > l_date
                  and    pa2.person_id = per_kad_shd.g_old_rec.person_id
                  and    pa2.primary_flag = 'Y');
--
begin
  l_date := nvl(per_kad_shd.g_old_rec.date_to, hr_api.g_eot);
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- For primary addresses only
  -- ==========================
  --
  if per_kad_shd.g_old_rec.primary_flag = 'Y' then
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
Procedure check_non_updateable_args(p_rec in per_kad_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'check_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);
--
Begin
   hr_utility.set_location('Entering:'||l_proc, 5);
--
-- Only proceed with validation if a row exists for
-- the current record in the HR Schema
--
  if not per_kad_shd.api_updating
                (p_address_id            => p_rec.address_id,
                 p_object_version_number => p_rec.object_version_number) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;
  --
  hr_utility.set_location(l_proc, 6);
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     per_kad_shd.g_old_rec.business_group_id then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 7);
  --
  if nvl(p_rec.person_id, hr_api.g_number) <>
     per_kad_shd.g_old_rec.person_id then
     l_argument := 'person_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 8);
  --
  if nvl(p_rec.primary_flag, hr_api.g_varchar2) <>
     per_kad_shd.g_old_rec.primary_flag then
     l_argument := 'primary_flag';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 10);
  --
  if nvl(p_rec.style, hr_api.g_varchar2) <>
     per_kad_shd.g_old_rec.style then
     l_argument := 'style';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 11);
  --
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 12);
end check_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec            in out nocopy per_kad_shd.g_rec_type
  ,p_effective_date in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --  Reset global variable that indicates if payroll is installed under
  --  US legislation prior to validation.
  --
  g_us_payroll := NULL;
  --
  -- Call all supporting business operations.
  --
  -- Validate business group id
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);
  --
  hr_utility.set_location(l_proc, 6);
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
  hr_utility.set_location(l_proc, 7);
  --
  -- Validate person_id
  --
  chk_person_id
    (p_person_id     => p_rec.person_id
    );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Validate style
  --
  chk_style
    (p_style              => p_rec.style
    );
  --
  hr_utility.set_location(l_proc, 10);
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
  --
  hr_utility.set_location(l_proc, 11);
  --
  -- Validate country
  --
  chk_country
    (p_country                => p_rec.country
    ,p_style                  => p_rec.style
    ,p_address_id             => p_rec.address_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 12);
  --
  -- Validate postal code.
  --
  chk_postal_code
    (p_address_id             => p_rec.address_id
    ,p_style                  => p_rec.style
    ,p_postal_code            => p_rec.postal_code
    ,p_business_group_id      => p_rec.business_group_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  --
  -- Validation specific to GB, US, GENERIC
  --
  if p_rec.style = 'GB' or
     p_rec.style = 'US' or
     p_rec.style = 'GENERIC' then
  -- Check null attributes for address style.
  --
    hr_utility.set_location(l_proc, 13);
    chk_style_null_attr
    -- 09/12/97 Change Begins
      (p_address_id             => p_rec.address_id
      ,p_object_version_number  => p_rec.object_version_number
      ,p_style                  => p_rec.style
      ,p_region_2               => p_rec.region_2
      ,p_region_3               => p_rec.region_3
      ,p_telephone_number_3     => p_rec.telephone_number_3
      );
    -- 09/12/97 Change Ends
    hr_utility.set_location(l_proc, 14);
  --
  -- Validate address_line1
  --
    chk_address_line1
      (p_address_id             => p_rec.address_id
      ,p_style                  => p_rec.style
      ,p_address_line1          => p_rec.address_line1
      ,p_object_version_number  => p_rec.object_version_number
      );
    hr_utility.set_location(l_proc, 15);
  --
  --
  --
  -- Validate date_to
  --
  -- No procedural call is made to the procedure
  -- chk_date_to as the insert logic is handled
  -- by chk_date_from
  --
    hr_utility.set_location(l_proc, 16);
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
      );
  --
    hr_utility.set_location(l_proc, 17);
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
  --
    hr_utility.set_location(l_proc, 18);
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
    hr_utility.set_location(l_proc, 19);
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
      ,p_region_2               => p_rec.region_2
      ,p_town_or_city           => p_rec.town_or_city
      ,p_business_group_id      => p_rec.business_group_id
      ,p_object_version_number  => p_rec.object_version_number
      );
  --
    hr_utility.set_location(l_proc, 20);
  --
  --Validation specific to JP
  --
  /*elsif p_rec.style = 'JP' then
    hr_utility.set_location(l_proc, 21);
  --
  -- Check the combination checking for town_or_city(district_code)
  -- address_line1, and region_1
  --
    chk_address1_towncity_comb
      (p_address_id              => p_rec.address_id
      ,p_object_version_number   => p_rec.object_version_number
      ,p_town_or_city            => p_rec.town_or_city
      ,p_address_line1           => p_rec.address_line1
      ,p_region_1                => p_rec.region_1
      );
    hr_utility.set_location(l_proc, 22);
  --
  -- Validate region_2 according to address_line2
  --
    chk_address2_region2_comb
      (p_address_id              => p_rec.address_id
      ,p_object_version_number   => p_rec.object_version_number
      ,p_address_line2           => p_rec.address_line2
      ,p_region_2                => p_rec.region_2
      );
    hr_utility.set_location(l_proc, 23);
  --
  -- Validate region_3 according to address_line3
  --
    chk_address3_region3_comb
      (p_address_id              => p_rec.address_id
      ,p_object_version_number   => p_rec.object_version_number
      ,p_address_line3           => p_rec.address_line3
      ,p_region_3                => p_rec.region_3
      );
    hr_utility.set_location(l_proc, 24); */

  end if;
  --  Validate flexfields. This is commented out as we do not need flexfield
  --  validation for employee kiosk.
  --
  -- per_add_flex.df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 25);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec            in out nocopy per_kad_shd.g_rec_type
  ,p_effective_date in date
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --  Reset global variable that indicates if payroll is installed under
  --  US legislation prior to validation.
  --
  g_us_payroll := NULL;
  --
  -- Call all supporting business operations. Mapping to the
  -- appropriate Business Rules in peradd.bru is provided.
  --
  -- Validate business group id
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);
  --
  -- Check that the columns which cannot
  -- be updated have not changed
  --
  check_non_updateable_args(p_rec => p_rec);
  --
  hr_utility.set_location(l_proc, 2);
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
  hr_utility.set_location(l_proc, 4);
  --
  -- Validate country.
  --
  chk_country
    (p_country                => p_rec.country
    ,p_style                  => p_rec.style
    ,p_address_id             => p_rec.address_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 5);
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
  --
  hr_utility.set_location(l_proc, 6);
  --
  -- Validate postal code.
  --
  chk_postal_code
    (p_address_id             => p_rec.address_id
    ,p_style                  => p_rec.style
    ,p_postal_code            => p_rec.postal_code
    ,p_business_group_id      => p_rec.business_group_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  hr_utility.set_location(l_proc, 8);
  --
  -- Validate date to.
  --
  chk_date_to
    (p_address_id             => p_rec.address_id
    ,p_date_from              => p_rec.date_from
    ,p_date_to                => p_rec.date_to
    ,p_object_version_number  => p_rec.object_version_number
    );
  hr_utility.set_location(l_proc, 9);
  --
  --
  -- Validation specific to GB, US, GENERIC
  --
  if p_rec.style = 'GB' or
     p_rec.style = 'US' or
     p_rec.style = 'GENERIC' then
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
      );
    hr_utility.set_location(l_proc, 10);
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
    hr_utility.set_location(l_proc, 11);
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
    hr_utility.set_location(l_proc, 12);
  --
  -- Validate address_line 1.
  --
    chk_address_line1
      (p_address_id             => p_rec.address_id
      ,p_style                  => p_rec.style
      ,p_address_line1          => p_rec.address_line1
      ,p_object_version_number  => p_rec.object_version_number
      );
    hr_utility.set_location(l_proc, 13);
  --
  -- Check null attributes for address style.
  --
    chk_style_null_attr
    -- 09/12/97 Change Begins
      (p_address_id             => p_rec.address_id
      ,p_object_version_number  => p_rec.object_version_number
      ,p_style                  => p_rec.style
      ,p_region_2               => p_rec.region_2
      ,p_region_3               => p_rec.region_3
      ,p_telephone_number_3     => p_rec.telephone_number_3
      );
    -- 09/12/97 Change Ends
    hr_utility.set_location(l_proc, 14);
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
      ,p_region_2               => p_rec.region_2
      ,p_town_or_city           => p_rec.town_or_city
      ,p_business_group_id      => p_rec.business_group_id
      ,p_object_version_number  => p_rec.object_version_number
      );
  --
    hr_utility.set_location(l_proc, 15);
  --
  --
 /* elsif p_rec.style = 'JP' then
    hr_utility.set_location(l_proc, 16);
  --
  -- Check the combination checking for town_or_city(district_code)
  -- address_line1, and region_1
  --
    chk_address1_towncity_comb
      (p_address_id              => p_rec.address_id
      ,p_object_version_number   => p_rec.object_version_number
      ,p_town_or_city            => p_rec.town_or_city
      ,p_address_line1           => p_rec.address_line1
      ,p_region_1                => p_rec.region_1
      );
    hr_utility.set_location(l_proc, 17);
  --
  -- Validate region_2 according to address_line2
  --
    chk_address2_region2_comb
      (p_address_id              => p_rec.address_id
      ,p_object_version_number   => p_rec.object_version_number
      ,p_address_line2           => p_rec.address_line2
      ,p_region_2                => p_rec.region_2
      );
    hr_utility.set_location(l_proc, 18);
  --
  -- Validate region_3 according to address_line3
  --
    chk_address3_region3_comb
      (p_address_id              => p_rec.address_id
      ,p_object_version_number   => p_rec.object_version_number
      ,p_address_line3           => p_rec.address_line3
      ,p_region_3                => p_rec.region_3
      );
    hr_utility.set_location(l_proc, 19); */

  end if;
  --
  --  Validate flexfields. This is commented out as we do not need flexfields
  --  validation for employee kiosk.
  --
  -- per_add_flex.df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in out nocopy per_kad_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations. Mapping to the
  -- appropriate business rules on peradd.bru is provided
  --
  -- Validate business group id
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);
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
end per_kad_bus;

/
