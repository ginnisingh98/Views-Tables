--------------------------------------------------------
--  DDL for Package Body PER_CTC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CTC_BUS" as
/* $Header: pectcrhi.pkb 115.20 2003/02/11 14:24:18 vramanai ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_ctc_bus.';  -- Global package name
--
-- The following two global variables are only to be used by the
-- return_legislation_code function.
--
g_contract_id number default null;
g_legislation_code varchar2(150) default null;
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_non_updateable_args >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updatetable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   (business_group_id or person_id) have been altered.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
Procedure check_non_updateable_args(p_rec in per_asg_shd.g_rec_type
                                   ,p_effective_date in date) is
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
  if not per_asg_shd.api_updating
                (p_assignment_id          => p_rec.assignment_id
                ,p_object_version_number  => p_rec.object_version_number
                ,p_effective_date         => p_effective_date
                ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;
  --
  hr_utility.set_location(l_proc, 6);
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(per_asg_shd.g_old_rec.business_group_id, hr_api.g_number) then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 7);
  --
  if nvl(p_rec.person_id,hr_api.g_number) <>
     nvl(per_asg_shd.g_old_rec.person_id, hr_api.g_number) then
     l_argument := 'person_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 8);
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 9);
end check_non_updateable_args;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_person_id >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check that person business group is the same as the contract business group.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_id
--    p_business_group_id
--    p_effective_date
--
--  Post Success:
--    If person business group is the same as the contract business group then processing
--    continues
--
--  Post Failure:
--    Application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_person_id
  (p_person_id             in per_contracts_f.person_id%TYPE
  ,p_business_group_id     in per_contracts_f.business_group_id%TYPE
  ,p_effective_date        in per_contracts_f.effective_start_date%TYPE
  )
  is
--
   l_exists             varchar2(1);
   l_business_group_id  number(15);
   l_proc               varchar2(72)  :=  g_package||'chk_person_id';
   --
   cursor csr_get_bus_grp is
     select   ppf.business_group_id
     from     per_people_f ppf
     where    ppf.person_id = p_person_id
     and      p_effective_date between ppf.effective_start_date
                               and     ppf.effective_end_date;
   --
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
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- Check that person business group is the same as
  -- the contract business group
  --
  open csr_get_bus_grp;
  fetch csr_get_bus_grp into l_business_group_id;
  if l_business_group_id <> p_business_group_id then
    close csr_get_bus_grp;
    hr_utility.set_message(800, 'PER_52832_CTR_INV_BG');
    hr_utility.raise_error;
  end if;
  close csr_get_bus_grp;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
end chk_person_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_reference >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check that the reference is unique within a person. As this is datetracked
--    the same reference must not exist outside of the contract_id.
--    --If this is a (DT) update and the reference is changing, it should be unique
--      for the person, for every contract_id except this one.
--    --If it is a (DT) insert, then the reference should be unque for the personid
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_id
--    p_reference
--    p_datetrack_mode
--    p_contract_id
--
--  Post Success:
--    If reference the reference is unique within the allowed paramertrs stated above
--    then processing continues.
--
--  Post Failure:
--    Application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_reference
  (p_person_id             in per_contracts_f.person_id%TYPE
  ,p_reference             in per_contracts_f.reference%TYPE
  ,p_datetrack_mode        in varchar2
  ,p_contract_id           in per_contracts_f.contract_id%TYPE
  )
  is
--
   l_exists             varchar2(1);
   l_business_group_id  number(15);
   l_proc               varchar2(72)  :=  g_package||'chk_reference';
   --
   cursor csr_update is
     select   null
     from     per_contracts_f
     where    person_id = p_person_id
     and      contract_id <> p_contract_id
     and      reference = p_reference;
   --
   cursor csr_insert is
     select   null
     from     per_contracts_f
     where    person_id = p_person_id
     and      reference = p_reference;
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
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- If this is a DT update and reference is changing, Check that
  -- the reference does not exist for any other contract for the same person.
  --
  if p_datetrack_mode in ('UPDATE_OVERRIDE',
                          'UPDATE',
                          'CORRECTION',
                          'UPDATE_CHANGE_INSERT')
  AND p_reference <> per_ctc_shd.g_old_rec.reference
  THEN
    open csr_update;
    fetch csr_update into l_exists;
    if csr_update%FOUND then
      close csr_update;
      hr_utility.set_message(800, 'PER_52855_CTC_ORIGINAL');
      hr_utility.raise_error;
    end if;
    close csr_update;
  end if;
  if p_datetrack_mode = 'INSERT' then
    open csr_insert;
    fetch csr_insert into l_exists;
    if csr_insert%FOUND then
      close csr_insert;
      hr_utility.set_message(800, 'PER_52855_CTC_ORIGINAL');
      hr_utility.raise_error;
    end if;
    close csr_insert;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
end chk_reference;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_type >--------------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check that the passed in lookup code exists in hr_lookups for the with an
--    enabled flag set to 'Y' and that the effective start date of the contract
--    is between start date active and end date active in hr_lookups.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_contract_id
--    p_type
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
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
procedure chk_type
 (p_contract_id            in     per_contracts_f.contract_id%TYPE
 ,p_type                   in     per_contracts_f.type%TYPE
 ,p_effective_date         in     date
 ,p_validation_start_date  in     date
 ,p_validation_end_date    in     date
 ,p_object_version_number  in     per_contracts_f.object_version_number%TYPE
 )
  is
--
   l_proc           varchar2(72)  :=  g_package||'chk_type';
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
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  l_api_updating := per_ctc_shd.api_updating
         (p_contract_id            => p_contract_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_ctc_shd.g_old_rec.type, hr_api.g_varchar2) <>
       nvl(p_type, hr_api.g_varchar2))
    or (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 40);
    --
    if p_type is not null then
      --
      -- Check that the type exists in hr_lookups for the
      -- lookup type 'TYPE' with an enabled flag set to 'Y' and that
      -- the effective start date of the contract is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'CONTRACT_TYPE'
        ,p_lookup_code           => p_type
        )
      then
        --
        hr_utility.set_message(800, 'PER_52820_CTR_INV_TYPE');
        hr_utility.raise_error;
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
    end if;
    hr_utility.set_location(l_proc, 60);
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
  --
end chk_type;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_status >--------------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check that the passed in lookup code exists in hr_lookups for the with an
--    enabled flag set to 'Y' and that the effective start date of the contract
--    is between start date active and end date active in hr_lookups.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_contract_id
--    p_status
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
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
procedure chk_status
 (p_contract_id            in     per_contracts_f.contract_id%TYPE
 ,p_status                 in     per_contracts_f.status%TYPE
 ,p_effective_date         in     date
 ,p_validation_start_date  in     date
 ,p_validation_end_date    in     date
 ,p_object_version_number  in     per_contracts_f.object_version_number%TYPE
 )
  is
--
   l_proc           varchar2(72)  :=  g_package||'chk_status';
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
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  l_api_updating := per_ctc_shd.api_updating
         (p_contract_id            => p_contract_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_ctc_shd.g_old_rec.type, hr_api.g_varchar2) <>
       nvl(p_status, hr_api.g_varchar2))
    or (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 40);
    --
    if p_status is not null then
      --
      -- Check that the status exists in hr_lookups for the
      -- lookup type 'CONTRACT_STATUS' with an enabled flag set to 'Y' and that
      -- the effective start date of the contract is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'CONTRACT_STATUS'
        ,p_lookup_code           => p_status
        )
      then
        --
        hr_utility.set_message(800, 'PER_52821_CTR_INV_STATUS');
        hr_utility.raise_error;
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
    end if;
    hr_utility.set_location(l_proc, 60);
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
  --
end chk_status;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_status_reason >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check that the passed in lookup code exists in hr_lookups for the with an
--    enabled flag set to 'Y' and that the effective start date of the contract
--    is between start date active and end date active in hr_lookups.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_contract_id
--    p_status_reason
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
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
procedure chk_status_reason
 (p_contract_id            in     per_contracts_f.contract_id%TYPE
 ,p_status_reason          in     per_contracts_f.status_reason%TYPE
 ,p_effective_date         in     date
 ,p_validation_start_date  in     date
 ,p_validation_end_date    in     date
 ,p_object_version_number  in     per_contracts_f.object_version_number%TYPE
 )
  is
--
   l_proc           varchar2(72)  :=  g_package||'chk_status_reason';
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
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  l_api_updating := per_ctc_shd.api_updating
         (p_contract_id            => p_contract_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_ctc_shd.g_old_rec.type, hr_api.g_varchar2) <>
       nvl(p_status_reason, hr_api.g_varchar2))
    or (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 40);
    --
    if p_status_reason is not null then
      --
      -- Check that the status_reason exists in hr_lookups for the
      -- lookup type 'CONTRACT_STATUS_REASON' with an enabled flag set to 'Y' and that
      -- the effective start date of the contract is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'CONTRACT_STATUS_REASON'
        ,p_lookup_code           => p_status_reason
        )
      then
        --
        hr_utility.set_message(800, 'PER_52822_CTR_INV_STATUS_REASO');
        hr_utility.raise_error;
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
    end if;
    hr_utility.set_location(l_proc, 60);
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
  --
end chk_status_reason;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_duration_units>-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check that the passed in lookup code exists in hr_lookups for the with an
--    enabled flag set to 'Y' and that the effective start date of the contract
--    is between start date active and end date active in hr_lookups.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_contract_id
--    p_duration
--    p_duration_units
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
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
procedure chk_duration_units
 (p_contract_id            in     per_contracts_f.contract_id%TYPE
 ,p_duration		   in     per_contracts_f.duration%TYPE
 ,p_duration_units         in     per_contracts_f.duration_units%TYPE
 ,p_effective_date         in     date
 ,p_validation_start_date  in     date
 ,p_validation_end_date    in     date
 ,p_object_version_number  in     per_contracts_f.object_version_number%TYPE
 )
  is
--
   l_proc           varchar2(72)  :=  g_package||'chk_duration_units';
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
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  l_api_updating := per_ctc_shd.api_updating
         (p_contract_id            => p_contract_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_ctc_shd.g_old_rec.type, hr_api.g_varchar2) <>
       nvl(p_duration_units, hr_api.g_varchar2))
    or (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 40);
    --
    if p_duration_units is not null then
      --
      -- Check that the duration units exists in hr_lookups for the
      -- lookup type 'DURATION_UNITS' with an enabled flag set to 'Y' and that
      -- the effective start date of the contract is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'QUALIFYING_UNITS'
        ,p_lookup_code           => p_duration_units
        )
      then
        --
        hr_utility.set_message(800, 'PER_52823_CTR_INV_DURATION_UN');
        hr_utility.raise_error;
        --
      end if;
      --
      hr_utility.set_location(l_proc, 50);
      --
      -- Check that the duration exists when the duration units is not null
      --
      if p_duration is null then
        hr_utility.set_message(800, 'PER_52843_INV_DURATION');
        hr_utility.raise_error;
        --
      end if;
      hr_utility.set_location(l_proc, 60);
      --
    else
      --
      -- Check that the duration doesn't exist when the duration units is null
      --
      if p_duration is not null then
        hr_utility.set_message(800, 'PER_52843_CTR_INV_DURATION');
        hr_utility.raise_error;
        --
      end if;
     end if;
    hr_utility.set_location(l_proc, 70);
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 80);
  --
end chk_duration_units;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_start_reason >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check that the passed in lookup code exists in hr_lookups for the with an
--    enabled flag set to 'Y' and that the effective start date of the contract
--    is between start date active and end date active in hr_lookups.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_contract_id
--    p_start_reason
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
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
procedure chk_start_reason
 (p_contract_id            in     per_contracts_f.contract_id%TYPE
 ,p_start_reason           in     per_contracts_f.start_reason%TYPE
 ,p_effective_date         in     date
 ,p_validation_start_date  in     date
 ,p_validation_end_date    in     date
 ,p_object_version_number  in     per_contracts_f.object_version_number%TYPE
 )
  is
--
   l_proc           varchar2(72)  :=  g_package||'chk_start_reason';
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
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  l_api_updating := per_ctc_shd.api_updating
         (p_contract_id            => p_contract_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_ctc_shd.g_old_rec.type, hr_api.g_varchar2) <>
       nvl(p_start_reason, hr_api.g_varchar2))
    or (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 40);
    --
    if p_start_reason is not null then
      --
      -- Check that the start reason exists in hr_lookups for the
      -- lookup type 'START_REASON' with an enabled flag set to 'Y' and that
      -- the effective start date of the contract is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'CONTRACT_START_REASON'
        ,p_lookup_code           => p_start_reason
        )
      then
        --
        hr_utility.set_message(800, 'PER_52824_CTR_INV_START_REASON');
        hr_utility.raise_error;
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
    end if;
    hr_utility.set_location(l_proc, 60);
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
  --
end chk_start_reason;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_end_reason >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check that the passed in lookup code exists in hr_lookups for the with an
--    enabled flag set to 'Y' and that the effective start date of the contract
--    is between start date active and end date active in hr_lookups.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_contract_id
--    p_end_reason
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
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
procedure chk_end_reason
 (p_contract_id            in     per_contracts_f.contract_id%TYPE
 ,p_end_reason             in     per_contracts_f.end_reason%TYPE
 ,p_effective_date         in     date
 ,p_validation_start_date  in     date
 ,p_validation_end_date    in     date
 ,p_object_version_number  in     per_contracts_f.object_version_number%TYPE
 )
  is
--
   l_proc           varchar2(72)  :=  g_package||'chk_end_reason';
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
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  l_api_updating := per_ctc_shd.api_updating
         (p_contract_id            => p_contract_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_ctc_shd.g_old_rec.type, hr_api.g_varchar2) <>
       nvl(p_end_reason, hr_api.g_varchar2))
    or (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 40);
    --
    if p_end_reason is not null then
      --
      -- Check that the end reason exists in hr_lookups for the
      -- lookup type 'CONTRACT_END_REASON' with an enabled flag set to 'Y' and that
      -- the effective start date of the contract is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'CONTRACT_END_REASON'
        ,p_lookup_code           => p_end_reason
        )
      then
        --
        hr_utility.set_message(800, 'PER_52825_CTR_INV_END_REASON');
        hr_utility.raise_error;
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
    end if;
    hr_utility.set_location(l_proc, 60);
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
  --
end chk_end_reason;
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_extension_period_units>-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check that the passed in lookup code exists in hr_lookups for the with an
--    enabled flag set to 'Y' and that the effective start date of the contract
--    is between start date active and end date active in hr_lookups.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_contract_id
--    p_extension_period
--    p_extension_period_units
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
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
procedure chk_extension_period_units
 (p_contract_id            in     per_contracts_f.contract_id%TYPE
 ,p_extension_period	   in 	  per_contracts_f.extension_period%TYPE
 ,p_extension_period_units in     per_contracts_f.extension_period_units%TYPE
 ,p_effective_date         in     date
 ,p_validation_start_date  in     date
 ,p_validation_end_date    in     date
 ,p_object_version_number  in     per_contracts_f.object_version_number%TYPE
 )
  is
--
   l_proc           varchar2(72)  :=  g_package||'chk_extension_period_units';
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
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  l_api_updating := per_ctc_shd.api_updating
         (p_contract_id            => p_contract_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_ctc_shd.g_old_rec.type, hr_api.g_varchar2) <>
       nvl(p_extension_period_units, hr_api.g_varchar2))
    or (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 40);
    --
    if p_extension_period_units is not null then
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'QUALIFYING_UNITS'
        ,p_lookup_code           => p_extension_period_units
        )
      then
        --
        hr_utility.set_message(800, 'PER_52826_CTR_INV_EXTENSION_UN');
        hr_utility.raise_error;
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
      -- Check that the extension exists when the extension units is not null
      --
      if p_extension_period is null then
        hr_utility.set_message(800, 'PER_52844_CTR_INV_EXTENSION');
        hr_utility.raise_error;
        --
      end if;
      hr_utility.set_location(l_proc, 60);
      --
    else
      --
      -- Check that the extension doesn't exist when the extension units is null
      --
      if p_extension_period is not null then
        hr_utility.set_message(800, 'PER_52844_CTR_INV_EXTENSION');
        hr_utility.raise_error;
        --
      end if;
     end if;
    hr_utility.set_location(l_proc, 70);
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 80);
  --
end chk_extension_period_units;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_assignment_exists>------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Function checks whether the given contract is referenced by any assignments and
--    returns True of False accordingly.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_contract_id
--
--  Post Success:
--    True or False always returned.
--
--  Post Failure:
--    Failure is not allowed.
--
--  Access Status:
--    Internal Development Use Only.
--
function chk_assignment_exists
 (p_contract_id in per_contracts_f.contract_id%TYPE) return boolean is
   --
   cursor csr_assignment is
    select '1' from per_all_assignments_f
    where contract_id = p_contract_id;
   --
   l_proc           varchar2(72)  :=  g_package||'chk_assignment_exists';
   l_dummy          varchar2(1);
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  open csr_assignment;
  fetch csr_assignment into l_dummy;
  if csr_assignment%found then
    close csr_assignment;
    return true;
  else
    close csr_assignment;
    return false;
  end if;
  --
end chk_assignment_exists;
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
  (p_rec in per_ctc_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.contract_id is NULL) and (
    nvl(per_ctc_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)))
    or (p_rec.contract_id is null) then
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_CONTRACTS'
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
  (p_rec   in per_ctc_shd.g_rec_type) is
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
  if (p_rec.contract_id is null)
    or ((p_rec.contract_id is not null)
    and
    nvl(per_ctc_shd.g_old_rec.ctr_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information_category, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.ctr_information1, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information1, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.ctr_information2, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information2, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.ctr_information3, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information3, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.ctr_information4, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information4, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.ctr_information5, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information5, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.ctr_information6, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information6, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.ctr_information7, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information7, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.ctr_information8, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information8, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.ctr_information9, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information9, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.ctr_information10, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information10, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.ctr_information11, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information11, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.ctr_information12, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information12, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.ctr_information13, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information13, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.ctr_information14, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information14, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.ctr_information15, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information15, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.ctr_information16, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information16, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.ctr_information17, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information17, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.ctr_information18, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information18, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.ctr_information19, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information19, hr_api.g_varchar2) or
    nvl(per_ctc_shd.g_old_rec.ctr_information20, hr_api.g_varchar2) <>
    nvl(p_rec.ctr_information20, hr_api.g_varchar2))
  then
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'Contract Developer DF'
      ,p_attribute_category => p_rec.ctr_information_category
      ,p_attribute1_name    => 'CTR_INFORMATION1'
      ,p_attribute1_value   => p_rec.ctr_information1
      ,p_attribute2_name    => 'CTR_INFORMATION2'
      ,p_attribute2_value   => p_rec.ctr_information2
      ,p_attribute3_name    => 'CTR_INFORMATION3'
      ,p_attribute3_value   => p_rec.ctr_information3
      ,p_attribute4_name    => 'CTR_INFORMATION4'
      ,p_attribute4_value   => p_rec.ctr_information4
      ,p_attribute5_name    => 'CTR_INFORMATION5'
      ,p_attribute5_value   => p_rec.ctr_information5
      ,p_attribute6_name    => 'CTR_INFORMATION6'
      ,p_attribute6_value   => p_rec.ctr_information6
      ,p_attribute7_name    => 'CTR_INFORMATION7'
      ,p_attribute7_value   => p_rec.ctr_information7
      ,p_attribute8_name    => 'CTR_INFORMATION8'
      ,p_attribute8_value   => p_rec.ctr_information8
      ,p_attribute9_name    => 'CTR_INFORMATION9'
      ,p_attribute9_value   => p_rec.ctr_information9
      ,p_attribute10_name   => 'CTR_INFORMATION10'
      ,p_attribute10_value  => p_rec.ctr_information10
      ,p_attribute11_name   => 'CTR_INFORMATION11'
      ,p_attribute11_value  => p_rec.ctr_information11
      ,p_attribute12_name   => 'CTR_INFORMATION12'
      ,p_attribute12_value  => p_rec.ctr_information12
      ,p_attribute13_name   => 'CTR_INFORMATION13'
      ,p_attribute13_value  => p_rec.ctr_information13
      ,p_attribute14_name   => 'CTR_INFORMATION14'
      ,p_attribute14_value  => p_rec.ctr_information14
      ,p_attribute15_name   => 'CTR_INFORMATION15'
      ,p_attribute15_value  => p_rec.ctr_information15
      ,p_attribute16_name   => 'CTR_INFORMATION16'
      ,p_attribute16_value  => p_rec.ctr_information16
      ,p_attribute17_name   => 'CTR_INFORMATION17'
      ,p_attribute17_value  => p_rec.ctr_information17
      ,p_attribute18_name   => 'CTR_INFORMATION18'
      ,p_attribute18_value  => p_rec.ctr_information18
      ,p_attribute19_name   => 'CTR_INFORMATION19'
      ,p_attribute19_value  => p_rec.ctr_information19
      ,p_attribute20_name   => 'CTR_INFORMATION20'
      ,p_attribute20_value  => p_rec.ctr_information20
      );
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end chk_ddf;
--
--  -------------------------------------------------------------
--  |-------------------< chk_del_mode>-------------------------|
--  -------------------------------------------------------------
--
procedure chk_del_mode
 (p_datetrack_mode         in     varchar2)
 is
 --
  l_proc       varchar2(72) := g_package||'chk_del_mode';
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
      --
      -- Check that the datetrack mode is correct
      --
      if upper(p_datetrack_mode) = 'DELETE' then
        hr_utility.set_message(800, 'PER_52842_CTR_DEL_MODE');
        hr_utility.raise_error;
        --
      end if;
      hr_utility.set_location(l_proc, 20);
      --
   hr_utility.set_location(' Leaving:'|| l_proc, 30);
  --
end chk_del_mode;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_contract_id              in number
  ) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups  pbg
         , per_contracts_f      ctr
     where ctr.contract_id       = p_contract_id
       and pbg.business_group_id = ctr.business_group_id
  order by ctr.effective_start_date;
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
                             p_argument       => 'contract_id',
                             p_argument_value => p_contract_id);
  --
  if nvl(g_contract_id, hr_api.g_number) = p_contract_id then
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
    g_contract_id := p_contract_id;
    g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 25);
  --
  return l_legislation_code;
end return_legislation_code;
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
            (
             p_person_id                     in number default hr_api.g_number,
	     p_datetrack_mode		     in varchar2,
             p_validation_start_date	     in date,
	     p_validation_end_date	     in date) Is
--
  l_proc	    varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name	    all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack update mode is valid
  --
  If (dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode)) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    If ((nvl(p_person_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'per_people_f',
             p_base_key_column => 'person_id',
             p_base_key_value  => p_person_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'people';
      Raise l_integrity_error;
    End If;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    hr_utility.set_message(801, 'HR_7216_DT_UPD_INTEGRITY_ERR');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;

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
          (p_contract_id		in number,
           p_datetrack_mode		in varchar2,
	     p_validation_start_date	in date,
	     p_validation_end_date	in date) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
  l_table_name	all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = 'DELETE' or
      p_datetrack_mode = 'ZAP') then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'contract_id',
       p_argument_value => p_contract_id);
    --
    --
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    hr_utility.set_message(801, 'HR_7215_DT_CHILD_EXISTS');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;

End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in per_ctc_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
  --
  l_proc	varchar2(72) := g_package||'insert_validate';
  l_session_id  number;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Set the business group profile as this is used by the flexfield validation.
  --
  hr_kflex_utility.set_profiles
     (p_business_group_id => p_rec.business_group_id);
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Set the session date as this is used by the flexfield validation.
  --
  hr_kflex_utility.set_session_date
     (p_effective_date => p_effective_date
     ,p_session_id     => l_session_id);
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_person_id
     (p_rec.person_id,
      p_rec.business_group_id,
      p_effective_date);
  --
  hr_utility.set_location(l_proc, 15);
  --
  chk_type
     (p_rec.contract_id,
      p_rec.type,
      p_effective_date,
      p_validation_start_date,
      p_validation_end_date,
      p_rec.object_version_number
     );
  --
  hr_utility.set_location(l_proc, 20);
  --
  chk_status
   (p_rec.contract_id,
    p_rec.status,
    p_effective_date,
    p_validation_start_date,
    p_validation_end_date,
    p_rec.object_version_number
   );
  --
  hr_utility.set_location(l_proc, 25);
  --
  chk_status_reason
   (p_rec.contract_id,
    p_rec.status_reason,
    p_effective_date,
    p_validation_start_date,
    p_validation_end_date,
    p_rec.object_version_number
   );
  --
  hr_utility.set_location(l_proc, 30);
  --
  chk_duration_units
   (p_rec.contract_id,
    p_rec.duration,
    p_rec.duration_units,
    p_effective_date,
    p_validation_start_date,
    p_validation_end_date,
    p_rec.object_version_number
   );
  --
  hr_utility.set_location(l_proc, 35);
  --
  chk_start_reason
   (p_rec.contract_id,
    p_rec.start_reason,
    p_effective_date,
    p_validation_start_date,
    p_validation_end_date,
    p_rec.object_version_number
   );
  --
  hr_utility.set_location(l_proc, 40);
  --
  chk_end_reason
   (p_rec.contract_id,
    p_rec.end_reason,
    p_effective_date,
    p_validation_start_date,
    p_validation_end_date,
    p_rec.object_version_number
   );
  --
  hr_utility.set_location(l_proc, 45);
  --
  chk_extension_period_units
   (p_rec.contract_id,
    p_rec.extension_period,
    p_rec.extension_period_units,
    p_effective_date,
    p_validation_start_date,
    p_validation_end_date,
    p_rec.object_version_number
   );
  --
  hr_utility.set_location(l_proc, 47);
  --
  chk_reference
  (p_rec.person_id
  ,p_rec.reference
  ,p_datetrack_mode
  ,null
  );
  --
  hr_utility.set_location(l_proc, 50);
  --
  per_ctc_bus.chk_ddf(p_rec => p_rec);
  --
  hr_utility.set_location(l_proc, 55);
  --
  per_ctc_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(l_proc, 57);
  --
  -- Unset the session date.
  --
  hr_kflex_utility.unset_session_date
     (p_session_id => l_session_id);
  --
  hr_utility.set_location(l_proc, 60);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in per_ctc_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
  --
  l_proc	varchar2(72) := g_package||'update_validate';
  l_session_id  number;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Set the business group profile as this is used by the flexfield validation.
  --
  hr_kflex_utility.set_profiles
     (p_business_group_id => p_rec.business_group_id);
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Set the session date as this is used by the flexfield validation.
  --
  hr_kflex_utility.set_session_date
     (p_effective_date => p_effective_date
     ,p_session_id     => l_session_id);
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_type
     (p_rec.contract_id,
      p_rec.type,
      p_effective_date,
      p_validation_start_date,
      p_validation_end_date,
      p_rec.object_version_number
     );
  --
  hr_utility.set_location(l_proc, 15);
  --
  chk_status
   (p_rec.contract_id,
    p_rec.status,
    p_effective_date,
    p_validation_start_date,
    p_validation_end_date,
    p_rec.object_version_number
   );
  --
  hr_utility.set_location(l_proc, 20);
  --
  chk_status_reason
   (p_rec.contract_id,
    p_rec.status_reason,
    p_effective_date,
    p_validation_start_date,
    p_validation_end_date,
    p_rec.object_version_number
   );
  --
  hr_utility.set_location(l_proc, 25);
  --
  chk_duration_units
   (p_rec.contract_id,
    p_rec.duration,
    p_rec.duration_units,
    p_effective_date,
    p_validation_start_date,
    p_validation_end_date,
    p_rec.object_version_number
   );
  --
  hr_utility.set_location(l_proc, 30);
  --
  chk_start_reason
   (p_rec.contract_id,
    p_rec.start_reason,
    p_effective_date,
    p_validation_start_date,
    p_validation_end_date,
    p_rec.object_version_number
   );
  --
  hr_utility.set_location(l_proc, 35);
  --
  chk_end_reason
   (p_rec.contract_id,
    p_rec.end_reason,
    p_effective_date,
    p_validation_start_date,
    p_validation_end_date,
    p_rec.object_version_number
   );
  --
  hr_utility.set_location(l_proc, 40);
  --
  chk_extension_period_units
   (p_rec.contract_id,
    p_rec.extension_period,
    p_rec.extension_period_units,
    p_effective_date,
    p_validation_start_date,
    p_validation_end_date,
    p_rec.object_version_number
   );
  --
  hr_utility.set_location(l_proc, 42);
  --
  chk_reference
  (p_rec.person_id
  ,p_rec.reference
  ,p_datetrack_mode
  ,p_rec.contract_id
  );
  --
  hr_utility.set_location(l_proc, 45);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date         => p_validation_start_date,
     p_validation_end_date           => p_validation_end_date);
  --
  hr_utility.set_location(l_proc, 50);
  --
  per_ctc_bus.chk_ddf(p_rec => p_rec);
  --
  hr_utility.set_location(l_proc, 55);
  --
  per_ctc_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(l_proc, 57);
  --
  -- Unset the session date.
  --
  hr_kflex_utility.unset_session_date
     (p_session_id => l_session_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 60);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in per_ctc_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode		=> p_datetrack_mode,
     p_validation_start_date	=> p_validation_start_date,
     p_validation_end_date	=> p_validation_end_date,
     p_contract_id		=> p_rec.contract_id);
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_del_mode
   (p_datetrack_mode		=> p_datetrack_mode) ;
  --
  hr_utility.set_location(l_proc, 15);
  --
  if chk_assignment_exists (p_contract_id => p_rec.contract_id) then
     hr_utility.set_message(800, 'PER_52841_CTR_DEL_ASG');
     hr_utility.raise_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);

End delete_validate;
--
end per_ctc_bus;

/
