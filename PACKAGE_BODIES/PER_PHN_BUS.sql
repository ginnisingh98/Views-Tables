--------------------------------------------------------
--  DDL for Package Body PER_PHN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PHN_BUS" as
/* $Header: pephnrhi.pkb 120.0 2005/05/31 14:21:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_phn_bus.';  -- Global package name
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_non_updateable_args >--------------|
--  -----------------------------------------------------------------
--
Procedure chk_non_updateable_args
  (p_rec            in per_phn_shd.g_rec_type
  ) is
--
  l_proc     varchar2(72) := g_package||'chk_non_updateable_args';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema
  --
  if not per_phn_shd.api_updating
      (p_phone_id              => p_rec.phone_id,
       p_object_version_number => p_rec.object_version_number)
  then
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '20');
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  -- start of commenting of the following code, as parent_id and parent_table
  -- are updteable if null. Present code makes it non updateable hence
  -- commented
  --
/*
  if nvl(p_rec.parent_id, hr_api.g_number) <>
     nvl(per_phn_shd.g_old_rec.parent_id
        ,hr_api.g_number
        ) then
      --
      hr_api.argument_changed_error
        (p_api_name => l_proc
        ,p_argument => 'PARENT_ID'
	,p_base_table => per_phn_shd.g_tab_nam
        );
      --
  end if;
  --
  hr_utility.set_location(l_proc, 40);
  if nvl(p_rec.parent_table, hr_api.g_varchar2) <>
     nvl(per_phn_shd.g_old_rec.parent_table
        ,hr_api.g_varchar2
        ) then
      --
      hr_api.argument_changed_error
        (p_api_name => l_proc
        ,p_argument => 'PARENT_TABLE'
	,p_base_table => per_phn_shd.g_tab_nam
        );
      --
  end if;
  --
*/
  -- end of commenting the code
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
end chk_non_updateable_args;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_date_from >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    DATE_FROM is mandatory
--    DATE_FROM must be less than DATE_TO
--
--  Pre-conditions :
--    Format for date_from and date_to must be correct
--
--  In Arguments :
--    p_phone_id
--    p_date_from
--    p_date_to
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
procedure chk_date_from
  (p_phone_id           in    per_phones.phone_id%TYPE
  ,p_date_from		in	per_phones.date_from%TYPE
  ,p_date_to		in	per_phones.date_to%TYPE
  ,p_object_version_number in per_phones.object_version_number%TYPE
    )	is
--
 l_proc  varchar2(72) := g_package||'chk_date_from';
 l_api_updating     boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- 	Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name	        => l_proc
    ,p_argument	        => 'date_from'
    ,p_argument_value	  => p_date_from
    );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date_from or date_to value has changed
  --
  l_api_updating := per_phn_shd.api_updating
    (p_phone_id        => p_phone_id
    ,p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and
          (nvl(per_phn_shd.g_old_rec.date_from,hr_api.g_eot)
             <> nvl(p_date_from,hr_api.g_eot)
           or nvl(per_phn_shd.g_old_rec.date_to,hr_api.g_eot)
             <> nvl(p_date_to,hr_api.g_eot)))
     or
    (NOT l_api_updating) then
     hr_utility.set_location(l_proc, 2);
     --
     -- Check that the date_from value is less than or equal to the date_to
     -- value for the current record
     --
     if p_date_from > nvl(p_date_to,hr_api.g_eot)then
        hr_utility.set_message(801,'PER_7004_ALL_DATE_TO_FROM');
        hr_utility.raise_error;
     end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
        (p_associated_column1 => 'PER_PHONES.DATE_FROM'
	,p_associated_column2 => 'PER_PHONES.DATE_TO'
	) then
        --
        hr_utility.set_location(' Leaving:'||l_proc, 4);
        --
	raise;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 5);
  --
end chk_date_from;
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_phone_type >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that an phone type exists in table hr_lookups
--    where lookup_type is 'PHONE_TYPE' and enabled_flag is 'Y' and
--    effective_date is between the active dates (if they are not null).
--	Phone type is mandatory.
--    Phone number is mandatory.
--
--  Pre-conditions:
--    Effective_date must be valid.
--
--  In Arguments:
--    p_phone_id
--    p_phone_type
--    p_phone_number
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    If a row does exist in hr_lookups for the given phone code then
--    processing continues.
--
--  Post Failure:
--    If a row does not exist in hr_lookups for the given phone code then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_phone_type
  (p_phone_id               in per_phones.phone_id%TYPE
  ,p_phone_type             in per_phones.phone_type%TYPE
  ,p_phone_number           in per_phones.phone_number%TYPE
  ,p_effective_date         in date
  ,p_object_version_number  in per_phones.object_version_number%TYPE) is
  --
   l_proc           varchar2(72)  :=  g_package||'chk_phone_type';
   l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
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
    (p_api_name	      => l_proc
    ,p_argument	      => 'phone_type'
    ,p_argument_value	=> p_phone_type
    );
  --
  if p_phone_number is null then
    fnd_message.set_name('PER','PER_449911_MANDATORY_PHN_NUM');
    fnd_message.raise_error;
  end if;
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for phone type has changed
  --
  l_api_updating := per_phn_shd.api_updating
	  (p_phone_id               => p_phone_id
        ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating
       and nvl(per_phn_shd.g_old_rec.phone_type, hr_api.g_varchar2) <>
       nvl(p_phone_type, hr_api.g_varchar2))
       or
      (NOT l_api_updating)) then
        hr_utility.set_location(l_proc, 2);
        --
        -- Checks that the value for phone_type is
        -- valid and exists on hr_lookups within the
        -- specified date range
        --
        if hr_api.not_exists_in_hr_lookups
          (p_effective_date => p_effective_date
          ,p_lookup_type    => 'PHONE_TYPE'
          ,p_lookup_code    => p_phone_type
          ) then
          --
          --  Error: Invalid phone type.
          hr_utility.set_message(801, 'HR_51529_PHN_TYPE_INVALID');
          hr_utility.raise_error;
        end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
        (p_associated_column1 => 'PER_PHONES.PHONE_TYPE'
	) then
        --
        hr_utility.set_location(' Leaving:'||l_proc, 4);
        --
	raise;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 5);
  --
end chk_phone_type;
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_phone_type_limits  >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Only allow one primary home and one primary work per person at a given
--    time.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_phone_id
--    p_date_from
--    p_date_to
--    p_phone_type
--    p_parent_id
--    p_parent_table
--    p_party_id    -- HR/TCA merge
--    p_object_version_number
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_phone_type_limits
  (p_phone_id               in per_phones.phone_id%TYPE
  ,p_date_from              in per_phones.date_from%TYPE
  ,p_date_to                in per_phones.date_to%TYPE
  ,p_phone_type             in per_phones.phone_type%TYPE
  ,p_parent_id              in per_phones.parent_id%TYPE
  ,p_parent_table           in per_phones.parent_table%TYPE
  ,p_party_id               in per_phones.party_id%TYPE     -- HR/TCA merge
  ,p_object_version_number  in per_phones.object_version_number%TYPE) is
  --
   l_proc           varchar2(72)  :=  g_package||'chk_phone_type_limits';
   l_api_updating   boolean;
   l_dummy number;
  --
    cursor csr_home_phone_limit is
        select phn.phone_id
        from per_phones phn
        where phn.phone_type = 'H1'
        and phn.phone_id <> nvl(p_phone_id,hr_api.g_number)
        and (
             p_date_from between phn.date_from and
              nvl(phn.date_to,hr_api.g_eot)
            OR
             nvl(p_date_to,hr_api.g_eot) between phn.date_from and
              nvl(phn.date_to,hr_api.g_eot)
            OR
             phn.date_from between p_date_from and
              nvl(p_date_to,hr_api.g_eot)
            OR
             nvl(phn.date_to,hr_api.g_eot) between p_date_from and
              nvl(p_date_to,hr_api.g_eot)
             )
        and (
             (phn.parent_id = p_parent_id           --
             and phn.parent_table = p_parent_table) -- HR/TCA merge
            OR                                      --
             (phn.party_id = p_party_id and p_parent_id is null) -- 3299844
            );

  --
    cursor csr_work_phone_limit is
        select phn.phone_id
        from per_phones phn
        where phn.phone_type = 'W1'
        and phn.phone_id <> nvl(p_phone_id,hr_api.g_number)
        and (
             p_date_from between phn.date_from and
              nvl(phn.date_to,hr_api.g_eot)
            OR
             nvl(p_date_to,hr_api.g_eot) between phn.date_from and
              nvl(phn.date_to,hr_api.g_eot)
            OR
             phn.date_from between p_date_from and
              nvl(p_date_to,hr_api.g_eot)
            OR
             nvl(phn.date_to,hr_api.g_eot) between p_date_from and
              nvl(p_date_to,hr_api.g_eot)
             )
        and (
             (phn.parent_id = p_parent_id              --
              and phn.parent_table = p_parent_table)   -- HR/TCA merge
            OR                                         --
              (phn.party_id = p_party_id and p_parent_id is null) -- 3299844
            );
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  if hr_multi_message.no_all_inclusive_error
       (p_check_column1 => 'PER_PHONES.PHONE_TYPE'
       ,p_check_column2 => 'PER_PHONES.DATE_FROM'
       ,p_check_column3 => 'PER_PHONES.PARENT_TABLE'
       ,p_check_column4 => 'PER_PHONES.PARENT_ID'
       ,p_check_column5 => 'PER_PHONES.PARTY_ID'
       ,p_associated_column1 => 'PER_PHONES.PHONE_TYPE'
       ,p_associated_column2 => 'PER_PHONES.DATE_FROM'
       ,p_associated_column3 => 'PER_PHONES.PARENT_TABLE'
       ,p_associated_column4 => 'PER_PHONES.PARENT_ID'
       ,p_associated_column5 => 'PER_PHONES.PARTY_ID'
       ) then
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The value for phone type, date_to, or date_from has changed
    --
     l_api_updating := per_phn_shd.api_updating
	(p_phone_id               => p_phone_id
        ,p_object_version_number  => p_object_version_number);
    --
    hr_utility.set_location(l_proc, 2);
    --
    if ((l_api_updating
       and (per_phn_shd.g_old_rec.phone_type <> p_phone_type
             or per_phn_shd.g_old_rec.date_from <> p_date_from
             or nvl(per_phn_shd.g_old_rec.date_to,hr_api.g_eot) <>
                nvl(p_date_to,hr_api.g_eot)))
        OR
        (NOT l_api_updating)) then
	--
        hr_utility.set_location(l_proc, 3);
        --
        -- Checks that there is only one active primary home (H1) phone number
        --
        if p_phone_type = 'H1' then
          open csr_home_phone_limit;
          fetch csr_home_phone_limit into l_dummy;
          if csr_home_phone_limit%found then
            close csr_home_phone_limit;
            hr_utility.set_message(801, 'HR_51530_PHN_TYPE_HOME_LIMIT');
            hr_utility.raise_error;
          end if;
          close csr_home_phone_limit;
        end if;
	--
	hr_utility.set_location(l_proc, 4);
        --
        -- Checks that there is only one active primary work (W1) phone number
        --
        if p_phone_type = 'W1' then
          open csr_work_phone_limit;
          fetch csr_work_phone_limit into l_dummy;
          if csr_work_phone_limit%found then
            close csr_work_phone_limit;
            hr_utility.set_message(801, 'HR_51531_PHN_TYPE_WORK_LIMIT');
            hr_utility.raise_error;
          end if;
          close csr_work_phone_limit;
        end if;
        --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 5);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
        (p_same_associated_columns => 'Y'
	) then
        --
        hr_utility.set_location(' Leaving:'||l_proc, 6);
        --
	raise;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 7);
  --
end chk_phone_type_limits;
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_parent_table >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    If PARENT_TABLE <> 'PER_ALL_PEOPLE_F', raise an error.  This is just a
--    temporary
--    solution which will require re-thinking when new parent tables are added
--    because we probably dont want to hard code all these.
--
--  Pre-conditions :
--    None.
--
--  In Arguments :
--    p_parent_table
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
procedure chk_parent_table
  (
    p_parent_table	      in    per_phones.parent_table%TYPE
  )	is
--
 l_proc  varchar2(72) := g_package||'chk_parent_table';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- 	Check mandatory parameters have been set
  --
   hr_api.mandatory_arg_error
    (p_api_name	        => l_proc
    ,p_argument	        => 'parent_table'
    ,p_argument_value	  => p_parent_table
    );
    --
    -- Check that the parent_table is in the per_people table.
    -- This is a temporary solution.
    --
  hr_utility.set_location('IJH: Table name is: '||p_parent_table, 2);
    If p_parent_table <> 'PER_ALL_PEOPLE_F' then
         hr_utility.set_location('Failed parent Table check', 4);
         hr_utility.set_message(801, 'HR_51532_PHN_FK_NOT_FOUND');
         hr_utility.raise_error;
    end if;

  hr_utility.set_location(' Leaving:'||l_proc, 5);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
        (p_associated_column1 => 'PER_PHONES.PARENT_TABLE'
	) then
        --
        hr_utility.set_location(' Leaving:'||l_proc, 6);
        --
	raise;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 7);
  --
end chk_parent_table;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_parent_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    If PARENT_TABLE = 'PER_ALL_PEOPLE_F', verify that the value in PARENT_ID
--    is in the per_all_people_f table.  This is just a temporary solution
--    which will require re-thinking when new parent tables are added because
--    we probably dont want to hard code all these.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_phone_id
--    p_parent_id
--    p_parent_table
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
procedure chk_parent_id
  (p_phone_id           in    per_phones.phone_id%TYPE
  ,p_parent_id	      in    per_phones.parent_id%TYPE
  ,p_parent_table	      in    per_phones.parent_table%TYPE
  ,p_object_version_number in per_phones.object_version_number%TYPE
    )	is
--
 l_proc  varchar2(72) := g_package||'chk_parent_id';
 l_dummy number;
 l_api_updating     boolean;
--
 cursor csr_valid_parent_id is
    select per.person_id
    from per_all_people_f per
    where per.person_id = p_parent_id
    and rownum <2;  -- performance bug fix 3387297
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- 	Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name	        => l_proc
    ,p_argument	        => 'parent_id'
    ,p_argument_value	  => p_parent_id
    );
  --
  hr_utility.set_location(l_proc, 2);
  --
  if hr_multi_message.no_exclusive_error
       (p_check_column1 => 'PER_PHONES.PARENT_TABLE'
       ) then
    --
    hr_utility.set_location(l_proc, 3);
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date_from value has changed
    --
    l_api_updating := per_phn_shd.api_updating
      (p_phone_id   => p_phone_id
      ,p_object_version_number => p_object_version_number);
    --
    if ((l_api_updating and per_phn_shd.g_old_rec.parent_id <> p_parent_id)
       or
      (NOT l_api_updating)) then
       --
       hr_utility.set_location(l_proc, 4);
       --
       -- Check that the parent_id is in the per_people table.
       -- This is a temporary solution.
       --
         open csr_valid_parent_id;
         fetch csr_valid_parent_id into l_dummy;
         if csr_valid_parent_id %notfound then
            close csr_valid_parent_id;
            hr_utility.set_message(801, 'HR_51532_PHN_FK_NOT_FOUND');
            hr_utility.raise_error;
         end if;
         close csr_valid_parent_id;
    end if;
    --
    hr_utility.set_location(l_proc, 10);
    --
    --UPDATE not allowed unless currently null
    --
    if (l_api_updating
        and nvl(per_phn_shd.g_old_rec.parent_id,hr_api.g_number) <>  hr_api.g_number
        and per_phn_shd.g_old_rec.parent_id <> p_parent_id
       ) then
       hr_utility.set_location(l_proc, 11);
            hr_utility.set_message(800, 'HR_289949_INV_UPD_PARENT_ID');
            hr_utility.raise_error;
    end if;
    --
       hr_utility.set_location(l_proc, 15);
    --
    if ((nvl(p_parent_id,hr_api.g_number) <> hr_api.g_number)
       and (nvl(p_parent_table,hr_api.g_varchar2) = hr_api.g_varchar2)) then
       hr_utility.set_location(l_proc, 16);
            hr_utility.set_message(800, 'HR_289946_INV_PARENT_TABLE');
            hr_utility.raise_error;
    end if;
    --
    hr_utility.set_location(l_proc,20);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 25);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
        (p_associated_column1 => 'PER_PHONES.PARENT_ID'
	) then
        --
        hr_utility.set_location(' Leaving:'||l_proc, 6);
        --
	raise;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 7);
  --
end chk_parent_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_party_id >--------------------------------|
-- ----------------------------------------------------------------------------
--
--
--  Description:
--   - Validates that the person_id and the party_id are matched in
--     per_all_people_f
--     and if person_id is not null and party_id is null, derive party_id
--     from per_all_people_f from person_id
--
--  Pre_conditions:
--    A valid business_group_id
--
--  In Arguments:
--    A Pl/Sql record structre.
--    effective_date

--
--  Post Success:
--    Process continues if :
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of

--  Access Status:
--    Internal Table Handler Use Only.
--
Procedure chk_party_id(
   p_rec             in out nocopy per_phn_shd.g_rec_type
  ,p_effective_date  in date
  )is
--
  l_proc    varchar2(72)  :=  g_package||'chk_party_id';
  l_party_id     per_phones.party_id%TYPE;
  l_party_id2    per_phones.party_id%TYPE;
--
  --
  -- cursor to check that the party_id maches person_id
  --
  cursor csr_get_party_id is
  select party_id
  from    per_all_people_f per
    where   per.person_id = p_rec.parent_id
    and     p_effective_date
    between per.effective_start_date
    and     nvl(per.effective_end_date,hr_api.g_eot)
    and rownum <2; -- Performace bug fix #3387297
  --
  cursor csr_valid_party_id is
  select party_id
  from hz_parties hzp
  where hzp.party_id = p_rec.party_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  if p_rec.parent_id is not null then
    if hr_multi_message.no_exclusive_error
         (p_check_column1 => 'PER_PHONES.PARENT_ID'
         ) then
      --
      open csr_get_party_id;
      fetch csr_get_party_id into l_party_id;
      close csr_get_party_id;
      --
      hr_utility.set_location(l_proc,20);
      --
      if p_rec.party_id is not null then
        --
        hr_utility.set_location(l_proc,30);
        --
        if p_rec.party_id <> nvl(l_party_id,-1) then
          hr_utility.set_message(800, 'HR_289343_PERSONPARTY_MISMATCH');
          hr_utility.set_location(l_proc,40);
          hr_multi_message.add
	    (p_associated_column1 => 'PER_PHONES.PARENT_ID'
            ,p_associated_column2 => 'PER_PHONES.PARTY_ID'
            );
        end if;
      else
        --
        -- derive party_id from per_all_people_f using parent_id
        --
        hr_utility.set_location(l_proc,50);
        p_rec.party_id := l_party_id;
      end if;
    end if; -- for no_excl_err
  else
    --
    hr_utility.set_location(l_proc,60);
    --
    if p_rec.party_id is null then
      hr_utility.set_message(800, 'HR_289341_CHK_PERSON_OR_PARTY');
      hr_utility.set_location(l_proc,70);
      hr_multi_message.add
        (p_associated_column1 => 'PER_PHONES.PARENT_ID'
        ,p_associated_column2 => 'PER_PHONES.PARTY_ID'
        );
    else
      open csr_valid_party_id;
      fetch csr_valid_party_id into l_party_id2;
      --
      hr_utility.set_location(l_proc,80);
      --
      if csr_valid_party_id%notfound then
        close csr_valid_party_id;
        hr_utility.set_message(800, 'PER_289342_PARTY_ID_INVALID');
        hr_utility.set_location(l_proc,90);
        hr_multi_message.add
          (p_associated_column1 => 'PER_PHONES.PARTY_ID'
          );
      else
        close csr_valid_party_id;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,100);
End chk_party_id;

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
--    None.
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
    p_object_version_number in  per_phones.object_version_number%TYPE
  )	is
--
 l_proc  varchar2(72) := g_package||'chk_object_version_number';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- 	Check mandatory parameters have been set
  --
   hr_api.mandatory_arg_error
    (p_api_name	        => l_proc
    ,p_argument	        => 'object_version_number'
    ,p_argument_value	  => p_object_version_number
    );
    --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
end chk_object_version_number;
--
--
-- ---------------------------------------------------------------------------
-- |----------------------<  df_update_validate  >---------------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--   Calls the descriptive flex validation stub (per_phn_flex.df) if either
--   the attribute_category or attribute1..30 have changed.
--
-- Pre-conditions:
--   Can only be called from update_validate. RH hasn't been called from a form.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the attribute_category and attribute1.30 haven't changed then the
--   validation is not performed and the processing continues.
--   If the attribute_category or attribute1.30 have changed then the
--   per_phn_flex.df validates the descriptive flex. If an exception is
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
  (p_rec in per_phn_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'df_update_validate';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if nvl(per_phn_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.attribute_category, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.attribute1, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.attribute2, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.attribute3, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.attribute4, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.attribute5, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.attribute6, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.attribute7, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.attribute8, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.attribute9, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.attribute10, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.attribute11, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.attribute12, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.attribute13, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.attribute14, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.attribute15, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.attribute16, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.attribute17, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.attribute18, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.attribute19, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.attribute20, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
     nvl(p_rec.attribute21, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
     nvl(p_rec.attribute22, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
     nvl(p_rec.attribute23, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
     nvl(p_rec.attribute24, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
     nvl(p_rec.attribute25, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
     nvl(p_rec.attribute26, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
     nvl(p_rec.attribute27, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
     nvl(p_rec.attribute28, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
     nvl(p_rec.attribute29, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
     nvl(p_rec.attribute30, hr_api.g_varchar2) or
     nvl(per_phn_shd.g_old_rec.party_id, hr_api.g_number) <>  -- HR/TCA merge
     nvl(p_rec.party_id, hr_api.g_number)                     --
  then
    -- either the attribute_category or attribute1..30 have changed
    -- so we must call the flex stub
    per_phn_flex.df(p_rec => p_rec);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end df_update_validate;
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
  (p_rec in per_phn_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.phone_id is not null) and (
    nvl(per_phn_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2) or
    nvl(per_phn_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2)))
    or
    (p_rec.phone_id is null) then
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_PHONES'
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

end chk_df;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_validity >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--  Checks for valid times phone number can be used, validated against
--  HR_LOOKUPS.lookup_code table where LOOKUP_TYPE ='IRC_CONTACT_TIMES'
--
--  Pre-conditions :
--
--
--  In Arguments :
--    validity
--    effective_date
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
procedure chk_validity
  ( p_effective_date in  date
  , p_validity       in  per_phones.validity%TYPE
  )is
--
l_proc     varchar2(72) := g_package||'chk_validity';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If p_validity is not null
  then
    hr_utility.set_location(l_proc, 10);
    If hr_api.not_exists_in_hr_lookups
    (p_effective_date  => p_effective_date
    ,p_lookup_type     => 'IRC_CONTACT_TIMES'
    ,p_lookup_code     => p_validity
    )
    then
      fnd_message.set_name('PER','PER_289551_BAD_PHN_VALIDITY');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
        (p_associated_column1 => 'PER_PHONES.VALIDITY'
	) then
        --
        hr_utility.set_location(' Leaving:'||l_proc, 30);
        --
	raise;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
End chk_validity;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in out nocopy per_phn_shd.g_rec_type
                          ,p_effective_date in date
                          ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  if p_rec.parent_table = 'PER_ALL_PEOPLE_F' then
    per_per_bus.set_security_group_id
      (
       p_person_id => p_rec.parent_id
      ,p_associated_column1 => per_phn_shd.g_tab_nam||'.PARENT_ID'
      );
  end if;
  --
  -- After validating the set of important attributes,
  -- if Multiple Message Detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Validiate dates
  --
  chk_date_from
        (p_phone_id              => p_rec.phone_id
        ,p_date_from             => p_rec.date_from
        ,p_date_to               => p_rec.date_to
        ,p_object_version_number => p_rec.object_version_number
        );
  --
  -- Validate Phone Type
  --
  chk_phone_type
        (p_phone_id              => p_rec.phone_id
        ,p_phone_type            => p_rec.phone_type
        ,p_phone_number          => p_rec.phone_number
        ,p_effective_date        => p_effective_date
        ,p_object_version_number => p_rec.object_version_number
        );
  --
  -- if party_id is specified, parent_table and parent_id are not
  -- required parameter by HR/TCA merge
  --
  if p_rec.parent_table is not null then
    --
    -- Validate parent table name
    --
    chk_parent_table
        (p_parent_table	      => p_rec.parent_table);
    --
    -- Validate parent id
    --
    chk_parent_id
          (p_phone_id              => p_rec.phone_id
          ,p_parent_id             => p_rec.parent_id
          ,p_parent_table          => p_rec.parent_table
          ,p_object_version_number => p_rec.object_version_number
          );
  end if;
    --
    --  Validate party_id by HR/TCA merge
    --
    chk_party_id
          (p_rec
          ,p_effective_date
          );
  --
  -- Validate validity
  --
  chk_validity
    ( p_effective_date         =>p_effective_date
    , p_validity               =>p_rec.validity
    );
  --
  -- Validate Phone Type Limits
  --
  chk_phone_type_limits
        (p_phone_id              => p_rec.phone_id
        ,p_date_from             => p_rec.date_from
        ,p_date_to               => p_rec.date_to
        ,p_phone_type            => p_rec.phone_type
        ,p_parent_id             => p_rec.parent_id
        ,p_parent_table          => p_rec.parent_table
        ,p_party_id              => p_rec.party_id  -- HR/TCA merge
        ,p_object_version_number => p_rec.object_version_number
        );
  --
  --
  -- Call Descriptive Flexfield Validation routines
  --
  per_phn_bus.chk_df(p_rec => p_rec);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_phn_shd.g_rec_type
                          ,p_effective_date in date
                          ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_rec.parent_table = 'PER_ALL_PEOPLE_F' then
    per_per_bus.set_security_group_id
      (
       p_person_id => p_rec.parent_id
      ,p_associated_column1 => per_phn_shd.g_tab_nam||'.PARENT_ID'
      );
  end if;
  --
  -- After validating the set of important attributes,
  -- if Multiple Message Detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Check whether called has tried to update non-updateable values.
  --
  chk_non_updateable_args (p_rec  => p_rec);
  --
  if p_rec.parent_table is not null then
    --
    -- Validate parent table name
    --
    chk_parent_table
        (p_parent_table	      => p_rec.parent_table);
    --
    -- Validate parent id
    --
    chk_parent_id
          (p_phone_id              => p_rec.phone_id
          ,p_parent_id             => p_rec.parent_id
          ,p_parent_table          => p_rec.parent_table
          ,p_object_version_number => p_rec.object_version_number
          );
    --
  end if;
  --
  -- Validate dates
  --
  chk_date_from
        (p_phone_id              => p_rec.phone_id
        ,p_date_from             => p_rec.date_from
        ,p_date_to               => p_rec.date_to
        ,p_object_version_number => p_rec.object_version_number
        );
  --
  -- Validate Phone Type
  --
  chk_phone_type
        (p_phone_id              => p_rec.phone_id
        ,p_phone_type            => p_rec.phone_type
        ,p_phone_number          => p_rec.phone_number
        ,p_effective_date        => p_effective_date
        ,p_object_version_number => p_rec.object_version_number
        );
  --
  -- Validate Phone Type Limits
  --
  chk_phone_type_limits
        (p_phone_id              => p_rec.phone_id
        ,p_date_from             => p_rec.date_from
        ,p_date_to               => p_rec.date_to
        ,p_phone_type            => p_rec.phone_type
        ,p_parent_id             => p_rec.parent_id
        ,p_parent_table          => p_rec.parent_table
        ,p_party_id              => p_rec.party_id  -- HR/TCA merge
        ,p_object_version_number => p_rec.object_version_number
        );
  --
  -- Validate validity
  --
  chk_validity
    ( p_effective_date         =>p_effective_date
    , p_validity               =>p_rec.validity
    );
  --
  -- Validate Object Version Number
  --
  chk_object_version_number
     (p_object_version_number => p_rec.object_version_number);
  --
  --
  -- Call Descriptive Flexfield Validation routines
  --
  per_phn_bus.chk_df(p_rec => p_rec);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_phn_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Validate Object Version Number
  --
  chk_object_version_number
     (p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ---------------------------------------------------------------------------
-- |---------------------< return_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_phone_id              in number
  ) return varchar2 is
  --
  -- Cursor to find legislation code
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups  pbg
         , per_phones           phn
         , per_all_people_f     per
     where phn.phone_id         = p_phone_id
       and phn.parent_id        = per.person_id
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
                             p_argument       => 'phone_id',
                             p_argument_value => p_phone_id);
  --
  if nvl(g_phone_id, hr_api.g_number) = p_phone_id then
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
    g_phone_id        := p_phone_id;
    g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
  return l_legislation_code;
end return_legislation_code;
--

function return_legislation_parent
  (p_parent_id          in number
  ,p_parent_table       in varchar2
  ) return varchar2

is

begin
    if 	p_parent_table = 'PER_ALL_PEOPLE_F'
    then
	return per_per_bus.return_legislation_code(p_person_id => p_parent_id);
    else
	hr_utility.set_message(801, 'HR_51532_PHN_FK_NOT_FOUND');
	hr_utility.raise_error;
    end if;

end return_legislation_parent;

end per_phn_bus;

/
