--------------------------------------------------------
--  DDL for Package Body PER_CTR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CTR_BUS" as
/* $Header: pectrrhi.pkb 120.2.12010000.3 2009/04/09 13:42:18 pchowdav ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ctr_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150) default null;
g_contact_relationship_id     number        default null;
--
-- Bug 3114717 Start
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_y_or_n>--------------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_y_or_n
   (p_effective_date     in date
   ,p_flag               in varchar2
   ,p_flag_name          in varchar2)
IS
  l_proc           VARCHAR2(72)  :=  g_package||'chk_y_or_n';
begin
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
 IF hr_api.not_exists_in_hrstanlookups
  (p_effective_date               => p_effective_date
  ,p_lookup_type                  => 'YES_NO'
  ,p_lookup_code                  => p_flag
  ) THEN
       fnd_message.set_name('801','HR_52970_COL_Y_OR_N');
       fnd_message.set_token('COLUMN',p_flag_name);
       fnd_message.raise_error;
end if;
--
hr_utility.set_location('Leaving:'||l_proc, 20);
--
end chk_y_or_n;
-- Bug 3114717 End

--  ---------------------------------------------------------------------------
--  |--------------------------< chk_person_id >------------------------------|
--  ---------------------------------------------------------------------------
--
-- Description:
--    Validates that the person ID exists in PER_PEOPLE_F.
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_person_id
--    p_business_group_id
--
-- Post Success:
--    Processing continues if the person_id is valid.
--
-- Post Failure:
--    An Application Error is raised and processing is terminated if the
--    person_id is invalid.
--
-- Access Status:
--    Internal Development use only.
--
-- ---------------------------------------------------------------------
--
procedure chk_person_id
  (p_person_id             in number
  ,p_business_group_id     in number
  ,p_effective_date        in date
  )
  is
--
   l_business_group_id  number(15);
   l_proc               varchar2(72)  :=  g_package||'chk_person_id';
   --
   cursor csr_get_bus_grp is
     select   ppf.business_group_id
     from     per_all_people_f ppf  -- bug 3577703. Use table instead of secure view.
     where    ppf.person_id = p_person_id
      and p_effective_date between
          ppf.effective_start_date and ppf.effective_end_date;
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
  hr_utility.set_location(l_proc, 10);
  --
  -- Check that the person id is a valid value
  --
  open csr_get_bus_grp;
  fetch csr_get_bus_grp into l_business_group_id;
  if csr_get_bus_grp%NOTFOUND then
    close csr_get_bus_grp;
    hr_utility.set_message(801, 'HR_51389_CRT_INV_PERSON_ID');
    hr_utility.raise_error;
  --
  end if;
  close csr_get_bus_grp;
  hr_utility.set_location(l_proc,20);
  --
  -- Check that person business group is the same as
  -- the contact relationship business group
  --
  if l_business_group_id <> p_business_group_id then
    --
    hr_utility.set_message(801, 'HR_7374_ASG_INVALID_BG_PERSON');
    hr_utility.raise_error;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 30);
end chk_person_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_contact_person_id >------------------------------|
--  ---------------------------------------------------------------------------
--
-- Description:
--    Validates that the contact_person ID exists in PER_PEOPLE_F.
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_contact_person_id
--    p_business_group_id
--
-- Post Success:
--    Processing continues if the person_id is valid.
--
-- Post Failure:
--    An Application Error is raised and processing is terminated if the
--    contact_person_id is invalid.
--
-- Access Status:
--    Internal Development use only.
--
-- ---------------------------------------------------------------------
--
procedure chk_contact_person_id
  (p_contact_person_id             in number
  ,p_business_group_id     in number
  ,p_effective_date        in date
  )
  is
--
   l_business_group_id  number(15);
   l_proc               varchar2(72)  :=  g_package||'chk_person_id';
   --
   cursor csr_get_bus_grp is
     select   ppf.business_group_id
     from     per_all_people_f ppf  -- Bug 3577703. Use table per_all_people_f.
     where    ppf.person_id = p_contact_person_id
      and p_effective_date between
          ppf.effective_start_date and ppf.effective_end_date;
   --
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'contact_person_id'
    ,p_argument_value => p_contact_person_id
    );
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Check that the person id is a valid value
  --
  open csr_get_bus_grp;
  fetch csr_get_bus_grp into l_business_group_id;
  if csr_get_bus_grp%NOTFOUND then
    close csr_get_bus_grp;
    hr_utility.set_message(801, 'HR_51389_CRT_INV_PERSON_ID');
    hr_utility.raise_error;
  --
  end if;
  close csr_get_bus_grp;
  hr_utility.set_location(l_proc,20);
  --
  -- Check that person business group is the same as
  -- the contact relationship business group
  --
  if (l_business_group_id <> p_business_group_id AND
     nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='N') then
    --
    hr_utility.set_message(801, 'HR_7374_ASG_INVALID_BG_PERSON');
    hr_utility.raise_error;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 30);
end chk_contact_person_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_contact_type >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the contact type exists in hr_lookups
--
--  Pre-Requisites
--    None
--
--  In Parameters:
--    p_effective_date
--    p_object_version_number
--    p_contact_type
--    p_contact_relationship_id
--
--  Post Success:
--    Processing continues if the contact type is valid
--
--  Post Failure:
--    An Application error is raised and processing is terminated if the
--    contact type is invalid.
--
--  Access Status:
--    Internal Development use only.
--
-- -----------------------------------------------------------------------
--
procedure chk_contact_type
     (p_effective_date           in              date,
      p_object_version_number    in
         per_contact_relationships.object_version_number%TYPE,
      p_contact_type             in
         per_contact_relationships.contact_type%TYPE,
      p_contact_relationship_id  in
         per_contact_relationships.contact_relationship_id%TYPE
     ) is
  --
  l_proc          varchar2(72)  :=  g_package||'chk_contact_type';
  l_api_updating  boolean;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc,1);
  --
  --  Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                   => l_proc
    ,p_argument                   => 'effective date'
    ,p_argument_value             => p_effective_date
    );
  --
  --
  -- Check to see if record updated.
  --
  l_api_updating := per_ctr_shd.api_updating
         (p_contact_relationship_id  => p_contact_relationship_id
         ,p_object_version_number    => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 2);
  --
  if ((l_api_updating
     and per_ctr_shd.g_old_rec.contact_type <> p_contact_type)
     or (NOT l_api_updating))
  then
    --
    if p_contact_type is null then
      hr_utility.set_message(801,'HR_51379_CTR_INV_CONT_TYPE');
      hr_utility.raise_error;
    end if;
     -- 05/28/97 Check for mandatory argument for update only
     IF l_api_updating THEN
        hr_api.mandatory_arg_error
          (p_api_name                   => l_proc
          ,p_argument                   => 'object version number'
          ,p_argument_value             => p_object_version_number
          );
     --
        hr_api.mandatory_arg_error
          (p_api_name                   => l_proc
          ,p_argument                   => 'contact relationship id'
          ,p_argument_value             => p_contact_relationship_id
          );
     --
     END IF;
     -- 05/28/97 Change Ends
     --
     -- Bug 1472162.
     --
--      if hr_api.not_exists_in_hr_lookups
      if hr_api.not_exists_in_leg_lookups
        (p_effective_date         => p_effective_date
         ,p_lookup_type           => 'CONTACT'
         ,p_lookup_code           => p_contact_type
         ) then
         --  Error: Invalid contact_type
         hr_utility.set_location(l_proc, 10);
         hr_utility.set_message(801,'HR_51379_CTR_INV_CONT_TYPE');
         hr_utility.raise_error;
      end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
  end chk_contact_type;
--
-- ---------------------------------------------------------------------
-- |--------------------< chk_primary_contact >-------------------------|
-- ---------------------------------------------------------------------
--
-- Description:
--    Validates that the person only has one primary contact at any
--    point in time.
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_contact_relationship_id
--    p_person_id
--    p_object_version_number
--    p_primary_contact_flag
--    p_date_start
--    p_date_end
--
-- Post Success:
--    Processing continues if the p_contact_relationship_id and person_id
--    are valid.
--
-- Post Failure:
--    An Application Error is raised and processing is terminated if either the
--    p_contact_relationship_id or person_id is invalid.
--
-- Access Status:
--    Internal Development use only.
--
-- ---------------------------------------------------------------------
procedure chk_primary_contact(p_contact_relationship_id number,
                              p_person_id NUMBER,
                              p_object_version_number in number,
                              p_primary_contact_flag in
                      per_contact_relationships.primary_contact_flag%TYPE,
                              p_date_start date,
                              p_date_end   date) is
cursor csr_chk_primary_cnt is
select 'Y'
from   per_contact_relationships
where  person_id = p_person_id
and    primary_contact_flag = 'Y'
and    (nvl(date_end,hr_general.end_of_time)
            > nvl(p_date_start,hr_general.start_of_time)
and    nvl(date_start,hr_general.start_of_time)
            < nvl(p_date_end,hr_general.end_of_time));
--
l_exists varchar2(1) := 'N';
l_proc          varchar2(72)  :=  g_package||'chk_contact_type';
--
  l_api_updating  boolean;
begin
  --
  -- Check to see if record updated.
  --
  l_api_updating := per_ctr_shd.api_updating
         (p_contact_relationship_id  => p_contact_relationship_id
         ,p_object_version_number    => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 2);
  --
  if ((l_api_updating
     and per_ctr_shd.g_old_rec.primary_contact_flag <> p_primary_contact_flag)
     or (NOT l_api_updating))
  then
    --
    if p_primary_contact_flag not in ('Y','N') then
      hr_utility.set_message(801,'HR_51388_CTR_INV_P_CONT_FLAG');
      hr_utility.raise_error;
    end if;
    --
    hr_utility.set_location('Entering:'|| l_proc,1);
    --
    if p_primary_contact_flag = 'Y' then
    --
    open csr_chk_primary_cnt;
    fetch csr_chk_primary_cnt into l_exists;
    if csr_chk_primary_cnt%FOUND then
      close csr_chk_primary_cnt;
      hr_utility.set_message(801, 'PER_7125_EMP_CON_PRIMARY');
      hr_utility.raise_error;
    --
    end if;
    close csr_chk_primary_cnt;
    --
    end if;
    --
  end if;
  hr_utility.set_location('Leaving: '|| l_proc,1);
  --
end chk_primary_contact;
-- ---------------------------------------------------------------------
-- |--------------------< chk_start_life_reason_id >-------------------------|
-- ---------------------------------------------------------------------
--
-- Description:
--    Validates that the start_life_reason_id exists in BEN_LER_F on the
--    effective_date.
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_contact_relationship_id
--    p_start_life_reason_id
--    p_effective_date
--    p_object_version_number
--
--
-- Post Success:
--    Processing continues if the start_life_reason_id is valid.
--
--
-- Post Failure:
--    An Application Error is raised and processing is terminated if
--    start_life_reason_id is invalid.
--
-- Access Status:
--    Internal Development use only.
--
-- ---------------------------------------------------------------------
procedure chk_start_life_reason_id(p_contact_relationship_id number,
                                   p_start_life_reason_id in number,
                                   p_effective_date       in date,
                                   p_object_version_number in number) is
cursor csr_chk_start_life_reason_id is
select ler_id
from   BEN_LER_F
where  p_start_life_reason_id = ler_id
and    p_effective_date between effective_start_date and
                                effective_end_date;
--
l_start_life_reason_id number;
l_proc          varchar2(72)  :=  g_package||'chk_start_life_reason_id';
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc,5);
  --
  if (p_contact_relationship_id is not null
     and per_ctr_shd.g_old_rec.start_life_reason_id
     <> p_start_life_reason_id
     and p_start_life_reason_id is not null)
   or (p_contact_relationship_id is null
       and p_start_life_reason_id is NOT NULL)
    then
        open csr_chk_start_life_reason_id;
        fetch csr_chk_start_life_reason_id into l_start_life_reason_id;
        if csr_chk_start_life_reason_id%NOTFOUND then
          close csr_chk_start_life_reason_id;
          hr_utility.set_message(800, 'PER_52380_START_LIFE_REASON');
          hr_utility.raise_error;
      --
        end if;
      close csr_chk_start_life_reason_id;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end chk_start_life_reason_id;

-- ---------------------------------------------------------------------
-- |--------------------< chk_end_life_reason_id >-------------------------|
-- ---------------------------------------------------------------------
--
-- Description:
--    Validates that the end_life_reason_id exists in BEN_LER_F for a set
--    effective_date.
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_contact_relationship_id
--    p_end_life_reason_id
--    p_effective_date
--    p_object_version_number
--
--
-- Post Success:
--    Processing continues if the end_life_reason_id is valid in BEN_LER_F
--    on the set effective_date.
--
-- Post Failure:
--    An Application Error is raised and processing is terminated if
--    end_life_reason_id is invalid for that effective_date.
--
-- Access Status:
--    Internal Development use only.
--
-- ---------------------------------------------------------------------
procedure chk_end_life_reason_id(p_contact_relationship_id number
                                 ,p_end_life_reason_id in number
                                 ,p_effective_date       in date
                                 ,p_object_version_number in number) is
--
cursor csr_chk_end_life_reason_id is
select ler_id
from   BEN_LER_F
where  p_end_life_reason_id = ler_id
and    p_effective_date between effective_start_date and
                                effective_end_date;
--
l_end_life_reason_id number;
l_proc          varchar2(72)  :=  g_package||'chk_end_life_reason_id';
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc,5);
  --
  --
 if (p_contact_relationship_id is not null
     and per_ctr_shd.g_old_rec.end_life_reason_id
     <> p_end_life_reason_id
     and p_end_life_reason_id is not null)
   or (p_contact_relationship_id is null
       and p_end_life_reason_id is NOT NULL)
    then
      open csr_chk_end_life_reason_id;
      fetch csr_chk_end_life_reason_id into l_end_life_reason_id;
      if csr_chk_end_life_reason_id%NOTFOUND then
        close csr_chk_end_life_reason_id;
        hr_utility.set_message(800, 'PER_52381_END_LIFE_REASON');
        hr_utility.raise_error;
      --
      end if;
      close csr_chk_end_life_reason_id;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end chk_end_life_reason_id;
--
-- ---------------------------------------------------------------------
-- |--------------------< chk_date_start_end >-------------------------|
-- ---------------------------------------------------------------------
--
-- Description:
--    Validates that date_end is later than date_start and that date_end
--    cannot be entered if date_start is null.
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_contact_relationship_id
--    p_date_start
--    p_date_end
--    p_object_version_number
--
--
-- Post Success:
--    Processing continues if date_end is later than date_start and
--    therefore both are valid and date_end is not entered if date_start
--    is null.
--
--
-- Post Failure:
--    An Application Error is raised and processing is terminated if
--    date_end is invalid.
--
-- Access Status:
--    Internal Development use only.
--
-- ---------------------------------------------------------------------
procedure chk_date_start_end(p_contact_relationship_id number
                             ,p_date_start in date
                             ,p_date_end   in date
                             ,p_object_version_number in number) is
--
l_proc          varchar2(72)  :=  g_package||'chk_date_start_end';
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc,5);
  --
    if p_date_start is NOT NULL and
--   changed for bug 1995269    p_date_start >= nvl(p_date_end, hr_general.end_of_time) then
      p_date_start > nvl(p_date_end, hr_general.end_of_time) then
      hr_utility.set_message(800,'PER_7003_ALL_DATE_FROM_TO');
      hr_utility.raise_error;
    end if;
    --
    if p_date_start is NULL and
      p_date_end is NOT NULL then
      hr_utility.set_message(800,'PER_52384_START_END_DATE');
      hr_utility.raise_error;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end chk_date_start_end;


-- ---------------------------------------------------------------------
-- |--------------------< chk_time_validation >-------------------------|
-- ---------------------------------------------------------------------
--
-- Description:
--    Validates that only one relationship of the same type exists in
--    PER_CONTACT_RELATIONSHIPS on the same effective date.
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_contact_type
--    p_person_id
--    p_contact_person_id
--    p_date_start
--    p_date_end
--    p_object_version_number
--
--
-- Post Success:
--    Processing continues if there is no other contact relationship
--    of the same type existing at the same time.
--
--
-- Post Failure:
--    An Application Error is raised and processing is terminated if
--    another relationship of the same type exists at the same time.
--
-- Access Status:
--    Internal Development use only.
--
-- ---------------------------------------------------------------------
procedure chk_time_validation(p_contact_type varchar2,
                              p_person_id in number,
                              p_contact_person_id in number,
                              p_contact_relationship_id in number,
                              p_date_start DATE,
                              p_date_end DATE,
                              p_object_version_number in number) is
l_records varchar2(1);
l_start_of_time date := hr_general.start_of_time;
l_end_of_time date := hr_general.end_of_time;

cursor csr_chk_time_validation is
select 'X'
from per_contact_relationships per
where per.person_id = p_person_id
and   per.contact_person_id = p_contact_person_id
and   (per.contact_relationship_id <> p_contact_relationship_id
    or p_contact_relationship_id is null)
and   per.contact_type = p_contact_type
and nvl(p_date_end,l_end_of_time) >= nvl(date_start,l_start_of_time)
and nvl(p_date_start,l_start_of_time) <= nvl(date_end,l_end_of_time);
--
l_proc          varchar2(72)  :=  g_package||'chk_time_validation';
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc,5);
  --
  if (p_contact_relationship_id is not null
    and nvl(per_ctr_shd.g_old_rec.date_start, hr_api.g_date)
    <> nvl(p_date_start, hr_api.g_date)
    or nvl(per_ctr_shd.g_old_rec.date_end, hr_api.g_date)
    <> nvl(p_date_end, hr_api.g_date)
    or nvl(per_ctr_shd.g_old_rec.contact_type, hr_api.g_varchar2)
    <> nvl(p_contact_type, hr_api.g_varchar2))
  or p_contact_relationship_id is null then
    --
    open csr_chk_time_validation;
    fetch csr_chk_time_validation into l_records;
    if csr_chk_time_validation%FOUND then
  hr_utility.set_message(800,'PER_6996_REL_CURR_EXISTS');
  hr_utility.raise_error;
      --
    end if;

 close csr_chk_time_validation;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end chk_time_validation;
--
-- ----------------------------------------------------------------------------
-- |------------------< chk_sequence_number >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--    Validates that the sequence number for all relationships between two people
--    are the same and that this sequence number is unique for that person_id. ie
--    the person with the contact does not have the same sequence number for a
--    relationship with any other person. It also validates that the sequence
--    number can only be updated from null.
--
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_contact_relationship_id
--    p_sequence_number
--    p_contact_person_id
--    p_person_id
--    p_object_version_number
--
-- Post Success:
--    Processing continues if the sequence number matches the sequence number
--    for any other relationship between these two people and does not match
--    a sequence number for a relationship between the person a different contact.
--    Also continues if updating the sequence number from null.
--
--
-- Post Failure:
--    An Application Error is raised and processing is terminated if the sequence
--    number is not the same as an existing sequence number for a relationship
--    between these two people, or if the sequence number already exists for
--    a relationship between the person and a different contact. Processing is
--    also terminated if an update is attempted where the sequence number is not
--    null.
--
--
-- Access Status:
--    Internal Development use only.
-------------------------------------------------------------------------------
procedure chk_sequence_number(p_contact_relationship_id in number,
               p_sequence_number in number,
               p_contact_person_id in number,
               p_person_id in number,
               p_object_version_number in number) is
--
l_proc varchar2(72)  :=  g_package||'chk_sequence_number';
l_sequence_number number;
l_sequence_other  number;
--
cursor csr_seq is
select sequence_number
from per_contact_relationships con
where con.person_id = p_person_id
and con.contact_person_id = p_contact_person_id
and con.sequence_number  <> p_sequence_number;
--
cursor csr_seq_others is
select sequence_number
from per_contact_relationships con
where con.person_id = p_person_id
and con.contact_person_id <> p_contact_person_id
and   con.sequence_number = p_sequence_number;
--
begin
   --
   hr_utility.set_location(l_proc, 1);
   --
   if p_contact_relationship_id is null or
     (p_contact_relationship_id is not null and
     nvl(per_ctr_shd.g_old_rec.sequence_number,hr_api.g_number)
     <> nvl(p_sequence_number,hr_api.g_number)) then
   --
    if p_sequence_number is not null and
       p_contact_person_id is not null then
       if per_ctr_shd.g_old_rec.sequence_number is null then
         open csr_seq;
         fetch csr_seq into l_sequence_number;
         if csr_seq%FOUND then
           close csr_seq;
           hr_utility.set_message('800','PER_52509_USE_SEQ_NO');
           hr_utility.raise_error;
         else
           open csr_seq_others;
           fetch csr_seq_others into l_sequence_other;
           if csr_seq_others%FOUND then
             close csr_seq_others;
             hr_utility.set_message('800','PER_52510_DIFF_SEQ_NO');
             hr_utility.raise_error;
           end if;
         end if;
      --fix 1322770 Sequence no. may only be UPDATED from null.
       elsif (p_contact_relationship_id is not null
              and p_sequence_number <> per_ctr_shd.g_old_rec.sequence_number) then
       hr_utility.set_message('800','PER_52511_SEQ_NO_UPD');
       hr_utility.raise_error;
       end if;
    elsif (p_contact_relationship_id is not null
           and per_ctr_shd.g_old_rec.sequence_number is not null) then
          hr_utility.set_message('800','PER_52511_SEQ_NO_UPD');
          hr_utility.raise_error;
    end if;
  end if;
end chk_sequence_number;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_date_of_birth >------------------------------|
--  ---------------------------------------------------------------------------
--  Bug fix 3326964.
-- Description:
--    Validates that the relationship start date is greater or equal to
--    person's date of birth.
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_person_id
--    p_contact_person_id
--    p_date_start
--
--
-- Post Success:
--    Processing continues if the relationship start date is valid.
--
-- Post Failure:
--    An Application Error is raised and processing is terminated if the
--     - relationship start date is less than person's date of brith
--
-- Access Status:
--    Internal Development use only.
--
-- ---------------------------------------------------------------------
--
procedure chk_date_of_birth
  (p_person_id     	   in number
  ,p_contact_person_id     in number
  ,p_date_start		   in date
  )
  is
--
   l_business_group_id  number(15);
   l_proc               varchar2(72)  :=  g_package||'chk_date_of_birth';
   --
   cursor csr_get_date_of_birth( l_person_id number ) is
     select   date_of_birth
     from     per_people_f ppf
     where    ppf.person_id = l_person_id;
   --
   l_contact_date_of_birth date;
   l_person_date_of_birth  date;
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
  hr_utility.set_location(l_proc, 10);
  --
   --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'contact_person_id'
    ,p_argument_value => p_contact_person_id
    );
  --
  hr_utility.set_location(l_proc, 20);
  --

  -- To fetch person date of birth.

  open csr_get_date_of_birth( p_person_id );
  fetch csr_get_date_of_birth into l_person_date_of_birth;
  close csr_get_date_of_birth;

  -- To fetch contact date of birth.

  open csr_get_date_of_birth( p_contact_person_id );
  fetch csr_get_date_of_birth into l_contact_date_of_birth;
  close csr_get_date_of_birth;


  -- condition to check whether the relationship  start date
  -- is less than person's date of birth or less than contact date of birth.

  if p_date_start is not null and
     ( p_date_start < nvl( l_person_date_of_birth,hr_api.g_sot ) or
       p_date_start < nvl( l_contact_date_of_birth,hr_api.g_sot ) ) then
	hr_utility.set_message('800','PER_50386_CON_SDT_LES_EMP_BDT');
        hr_utility.raise_error;
  end if;
  --

  --
  hr_utility.set_location('Leaving:'|| l_proc, 20);
  --
end chk_date_of_birth;
-- ----------------------------------------------------------------------------
-- |--------------------< check_non_updateable_args >-------------------------|
-- ----------------------------------------------------------------------------
Procedure check_non_updateable_args(p_rec in per_ctr_shd.g_rec_type)
is
--
  l_proc     varchar2(72) := g_package||'check_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema
  --
  if not per_ctr_shd.api_updating
                (p_contact_relationship_id => p_rec.contact_relationship_id
                ,p_object_version_number   => p_rec.object_version_number
                ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 6);
  --
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
                                per_ctr_shd.g_old_rec.business_group_id then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  --
  if nvl(p_rec.person_id, hr_api.g_number) <>
                                        per_ctr_shd.g_old_rec.person_id then
     l_argument := 'person_id';
     raise l_error;
  end if;
   --
  if nvl(p_rec.contact_person_id, hr_api.g_number) <>
                                per_ctr_shd.g_old_rec.contact_person_id then
     l_argument := 'contact_person_id';
     raise l_error;
  end if;
  --
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 14);
end check_non_updateable_args;
--
-- ---------------------------------------------------------------------------
-- |----------------------<  chk_df >----------------------------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
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
--   Internal Table Handler Use Only.
-- ---------------------------------------------------------------------------
procedure chk_df
  (p_rec in per_ctr_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.contact_relationship_id is not null) and (
     nvl(per_ctr_shd.g_old_rec.cont_attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute_category, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute1, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute2, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute3, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute4, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute5, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute6, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute7, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute8, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute9, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute10, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute11, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute12, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute13, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute14, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute15, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute16, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute17, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute18, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute19, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.cont_attribute20, hr_api.g_varchar2)))
     or
     (p_rec.contact_relationship_id is null) then
  --
  -- Only execute the validation if absolutely necessary:
  -- a) During update, the structure column value or any
  --    of the attribute values have actually changed.
  -- b) During insert.
  --
  hr_dflex_utility.ins_or_upd_descflex_attribs
    (p_appl_short_name               => 'PER'
    ,p_descflex_name                 => 'PER_CONTACTS'
    ,p_attribute_category       => p_rec.cont_attribute_category
    ,p_attribute1_name          => 'CONT_ATTRIBUTE1'
    ,p_attribute1_value         => p_rec.cont_attribute1
    ,p_attribute2_name          => 'CONT_ATTRIBUTE2'
    ,p_attribute2_value         => p_rec.cont_attribute2
    ,p_attribute3_name          => 'CONT_ATTRIBUTE3'
    ,p_attribute3_value         => p_rec.cont_attribute3
    ,p_attribute4_name          => 'CONT_ATTRIBUTE4'
    ,p_attribute4_value         => p_rec.cont_attribute4
    ,p_attribute5_name          => 'CONT_ATTRIBUTE5'
    ,p_attribute5_value         => p_rec.cont_attribute5
    ,p_attribute6_name          => 'CONT_ATTRIBUTE6'
    ,p_attribute6_value         => p_rec.cont_attribute6
    ,p_attribute7_name          => 'CONT_ATTRIBUTE7'
    ,p_attribute7_value         => p_rec.cont_attribute7
    ,p_attribute8_name          => 'CONT_ATTRIBUTE8'
    ,p_attribute8_value         => p_rec.cont_attribute8
    ,p_attribute9_name          => 'CONT_ATTRIBUTE9'
    ,p_attribute9_value         => p_rec.cont_attribute9
    ,p_attribute10_name          => 'CONT_ATTRIBUTE10'
    ,p_attribute10_value         => p_rec.cont_attribute10
    ,p_attribute11_name          => 'CONT_ATTRIBUTE11'
    ,p_attribute11_value         => p_rec.cont_attribute11
    ,p_attribute12_name          => 'CONT_ATTRIBUTE12'
    ,p_attribute12_value         => p_rec.cont_attribute12
    ,p_attribute13_name          => 'CONT_ATTRIBUTE13'
    ,p_attribute13_value         => p_rec.cont_attribute13
    ,p_attribute14_name          => 'CONT_ATTRIBUTE14'
    ,p_attribute14_value         => p_rec.cont_attribute14
    ,p_attribute15_name          => 'CONT_ATTRIBUTE15'
    ,p_attribute15_value         => p_rec.cont_attribute15
    ,p_attribute16_name          => 'CONT_ATTRIBUTE16'
    ,p_attribute16_value         => p_rec.cont_attribute16
    ,p_attribute17_name          => 'CONT_ATTRIBUTE17'
    ,p_attribute17_value         => p_rec.cont_attribute17
    ,p_attribute18_name          => 'CONT_ATTRIBUTE18'
    ,p_attribute18_value         => p_rec.cont_attribute18
    ,p_attribute19_name          => 'CONT_ATTRIBUTE19'
    ,p_attribute19_value         => p_rec.cont_attribute19
    ,p_attribute20_name          => 'CONT_ATTRIBUTE20'
    ,p_attribute20_value         => p_rec.cont_attribute20
    );
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,20);
end chk_df;
--
-- ---------------------------------------------------------------------------
-- |----------------------<  chk_ddf >----------------------------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--   Validates all the Developer Descriptive Flexfield values.
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
--   Internal Table Handler Use Only.
-- ---------------------------------------------------------------------------
procedure chk_ddf
  (p_rec in per_ctr_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.contact_relationship_id is not null) and (
     nvl(per_ctr_shd.g_old_rec.cont_information_category, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information_category, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_information1, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information1, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_information2, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information2, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_information3, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information3, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_information4, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information4, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_information5, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information5, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_information6, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information6, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_information7, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information7, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_information8, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information8, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_information9, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information9, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_information10, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information10, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_information11, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information11, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_information12, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information12, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_information13, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information13, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_information14, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information14, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_information15, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information15, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_information16, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information16, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_information17, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information17, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_information18, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information18, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_information19, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information19, hr_api.g_varchar2) or
     nvl(per_ctr_shd.g_old_rec.cont_information20, hr_api.g_varchar2) <>
     nvl(p_rec.cont_information20, hr_api.g_varchar2)))
     or
     (p_rec.contact_relationship_id is null) then
  --
  -- Only execute the validation if absolutely necessary:
  -- a) During update, the structure column value or any
  --    of the attribute values have actually changed.
  -- b) During insert.
  --
  hr_dflex_utility.ins_or_upd_descflex_attribs
    (p_appl_short_name               => 'PER'
    ,p_descflex_name                 => 'Contact Relship Developer DF'
    ,p_attribute_category       => p_rec.cont_information_category
    ,p_attribute1_name          => 'CONT_INFORMATION1'
    ,p_attribute1_value         => p_rec.cont_information1
    ,p_attribute2_name          => 'CONT_INFORMATION2'
    ,p_attribute2_value         => p_rec.cont_information2
    ,p_attribute3_name          => 'CONT_INFORMATION3'
    ,p_attribute3_value         => p_rec.cont_information3
    ,p_attribute4_name          => 'CONT_INFORMATION4'
    ,p_attribute4_value         => p_rec.cont_information4
    ,p_attribute5_name          => 'CONT_INFORMATION5'
    ,p_attribute5_value         => p_rec.cont_information5
    ,p_attribute6_name          => 'CONT_INFORMATION6'
    ,p_attribute6_value         => p_rec.cont_information6
    ,p_attribute7_name          => 'CONT_INFORMATION7'
    ,p_attribute7_value         => p_rec.cont_information7
    ,p_attribute8_name          => 'CONT_INFORMATION8'
    ,p_attribute8_value         => p_rec.cont_information8
    ,p_attribute9_name          => 'CONT_INFORMATION9'
    ,p_attribute9_value         => p_rec.cont_information9
    ,p_attribute10_name          => 'CONT_INFORMATION10'
    ,p_attribute10_value         => p_rec.cont_information10
    ,p_attribute11_name          => 'CONT_INFORMATION11'
    ,p_attribute11_value         => p_rec.cont_information11
    ,p_attribute12_name          => 'CONT_INFORMATION12'
    ,p_attribute12_value         => p_rec.cont_information12
    ,p_attribute13_name          => 'CONT_INFORMATION13'
    ,p_attribute13_value         => p_rec.cont_information13
    ,p_attribute14_name          => 'CONT_INFORMATION14'
    ,p_attribute14_value         => p_rec.cont_information14
    ,p_attribute15_name          => 'CONT_INFORMATION15'
    ,p_attribute15_value         => p_rec.cont_information15
    ,p_attribute16_name          => 'CONT_INFORMATION16'
    ,p_attribute16_value         => p_rec.cont_information16
    ,p_attribute17_name          => 'CONT_INFORMATION17'
    ,p_attribute17_value         => p_rec.cont_information17
    ,p_attribute18_name          => 'CONT_INFORMATION18'
    ,p_attribute18_value         => p_rec.cont_information18
    ,p_attribute19_name          => 'CONT_INFORMATION19'
    ,p_attribute19_value         => p_rec.cont_information19
    ,p_attribute20_name          => 'CONT_INFORMATION20'
    ,p_attribute20_value         => p_rec.cont_information20
    );
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,20);
end chk_ddf;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_ctr_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations. Mapping to the
  -- appropriate Business Rules in perctr.bru is provided (where
  -- relevant)
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  -- Bug 3114717 Start
  --
  -- Validate primary_contact_flag
  --
  chk_y_or_n
    (p_effective_date           =>  p_effective_date
    ,p_flag                     =>  p_rec.primary_contact_flag
    ,p_flag_name                =>  'PRIMARY CONTACT FLAG'
    );
  --
  -- Validate third_party_pay_flag
  --
  chk_y_or_n
   (p_effective_date            =>  p_effective_date
   ,p_flag                      =>  p_rec.third_party_pay_flag
   ,p_flag_name                 =>  'THIRD PARTY PAY FLAG');
  --
  -- Validate rltd_per_rsds_w_dsgntr_flag
  --
  chk_y_or_n
  (p_effective_date            =>  p_effective_date
  ,p_flag                      =>  p_rec.rltd_per_rsds_w_dsgntr_flag
  ,p_flag_name                 =>  'SHARED RESIDENCY FLAG');
  --
  -- Validate personal_flag
  --
  chk_y_or_n
  (p_effective_date            =>  p_effective_date
  ,p_flag                      =>  p_rec.personal_flag
  ,p_flag_name                 =>  'PERSONAL FLAG');
  --
  -- Validate beneficiary_flag
  --
  chk_y_or_n
  (p_effective_date            =>  p_effective_date
  ,p_flag                      =>  p_rec.beneficiary_flag
  ,p_flag_name                 =>  'BENEFICIARY FLAG');
  --
  -- Validate dependent_flag
  --
  chk_y_or_n
  (p_effective_date            =>  p_effective_date
  ,p_flag                      =>  p_rec.dependent_flag
  ,p_flag_name                 =>  'DEPENDENT_FLAG');
  -- Bug 3114717 End

  --
  -- Validate person_id
  --
  per_ctr_bus.chk_person_id
    (p_person_id              =>  p_rec.person_id
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_effective_date         =>  p_effective_date
    );
  --
  hr_utility.set_location(l_proc, 10);
  --
  --
/* JZYLI 5/8/00 disable Global contact relation for now.
                Will enable it after OK from OAB.
  per_ctr_bus.chk_contact_person_id
    (p_contact_person_id              =>  p_rec.contact_person_id
*/
  per_ctr_bus.chk_person_id
    (p_person_id              =>  p_rec.contact_person_id
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_effective_date         =>  p_effective_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  --
  per_ctr_bus.chk_contact_type
    (p_effective_date           => p_effective_date
    ,p_contact_relationship_id  => p_rec.contact_relationship_id
    ,p_contact_type             => p_rec.contact_type
    ,p_object_version_number    => p_rec.object_version_number
    );
  --
  -- Check that there's only one primary contact
  --
  chk_primary_contact(p_contact_relationship_id => p_rec.contact_relationship_id,
                      p_person_id               => p_rec.person_id,
                      p_object_version_number   => p_rec.object_version_number,
                      p_primary_contact_flag    => p_rec.primary_contact_flag,
                      p_date_start              => p_rec.date_start,
                      p_date_end                => p_rec.date_end
                      );
  --
  hr_utility.set_location(l_proc, 30);
  --
  chk_start_life_reason_id(p_contact_relationship_id => p_rec.contact_relationship_id
                          ,p_start_life_reason_id    => p_rec.start_life_reason_id
                          ,p_effective_date          => p_effective_date
                          ,p_object_version_number   => p_rec.object_version_number
                           );
  --
  hr_utility.set_location(l_proc, 40);
  --
  chk_end_life_reason_id(p_contact_relationship_id => p_rec.contact_relationship_id
                        ,p_end_life_reason_id      => p_rec.end_life_reason_id
                        ,p_effective_date          => p_effective_date
                        ,p_object_version_number   => p_rec.object_version_number
                         );

  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
  chk_date_start_end(p_contact_relationship_id => p_rec.contact_relationship_id
                    ,p_date_start              => p_rec.date_start
                    ,p_date_end                => p_rec.date_end
                    ,p_object_version_number   => p_rec.object_version_number
                     );
   --
   hr_utility.set_location(' Leaving:'||l_proc, 60);
   --
   chk_time_validation(p_contact_type             => p_rec.contact_type
                       ,p_person_id               => p_rec.person_id
                       ,p_contact_person_id       => p_rec.contact_person_id
                       ,p_contact_relationship_id => p_rec.contact_relationship_id
                       ,p_date_start              => p_rec.date_start
                       ,p_date_end                => p_rec.date_end
                       ,p_object_version_number   => p_rec.object_version_number
                        );
   --
   hr_utility.set_location(' Leaving:'||l_proc, 70);
   --
   chk_sequence_number(p_contact_relationship_id => p_rec.contact_relationship_id
                       ,p_sequence_number       => p_rec.sequence_number
             ,p_contact_person_id     => p_rec.contact_person_id
             ,p_person_id             => p_rec.person_id
             ,p_object_version_number => p_rec.object_version_number
             );
   --
   hr_utility.set_location(' Leaving:'||l_proc,80);
   --
   -- Bug fix 3326964.
   -- Function call to check whether relation ship start date is less tha
   -- contact's or person's date of birth.

   chk_date_of_birth(  p_person_id    		=> p_rec.person_id
                     ,p_contact_person_id       => p_rec.contact_person_id
      		     ,p_date_start              => p_rec.date_start
      		    );
   --
   hr_utility.set_location(' Leaving:'||l_proc,90);
   --


   chk_ddf(p_rec => p_rec);
   --
   chk_df(p_rec => p_rec);
   --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_ctr_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  -- Check the non-updateable arguments have in fact not been modified
  --
  per_ctr_bus.check_non_updateable_args(p_rec => p_rec);
  --
  --
  -- bug fix 3982865
  -- Validation added to check the flag value while updating
  -- contact relationship.

  if ( p_rec.primary_contact_flag <> hr_api.g_varchar2 OR
       p_rec.primary_contact_flag is null ) then
  chk_y_or_n
    (p_effective_date           =>  p_effective_date
    ,p_flag                     =>  p_rec.primary_contact_flag
    ,p_flag_name                =>  'PRIMARY CONTACT FLAG'
    );
  end if;
  --
  -- Validate third_party_pay_flag
  --
  if ( p_rec.third_party_pay_flag <> hr_api.g_varchar2 OR
       p_rec.third_party_pay_flag is null ) then
  chk_y_or_n
   (p_effective_date            =>  p_effective_date
   ,p_flag                      =>  p_rec.third_party_pay_flag
   ,p_flag_name                 =>  'THIRD PARTY PAY FLAG');
  end if;
  --
  -- Validate rltd_per_rsds_w_dsgntr_flag
  --
  if ( p_rec.rltd_per_rsds_w_dsgntr_flag <> hr_api.g_varchar2 OR
       p_rec.rltd_per_rsds_w_dsgntr_flag is null ) then
  chk_y_or_n
  (p_effective_date            =>  p_effective_date
  ,p_flag                      =>  p_rec.rltd_per_rsds_w_dsgntr_flag
  ,p_flag_name                 =>  'SHARED RESIDENCY FLAG');
  end if;
  --
  -- Validate personal_flag
  --
  if ( p_rec.personal_flag <> hr_api.g_varchar2 OR
       p_rec.personal_flag is null ) then
  chk_y_or_n
  (p_effective_date            =>  p_effective_date
  ,p_flag                      =>  p_rec.personal_flag
  ,p_flag_name                 =>  'PERSONAL FLAG');
  end if;
  --
  -- Validate beneficiary_flag
  --
  if ( p_rec.beneficiary_flag <> hr_api.g_varchar2 OR
       p_rec.beneficiary_flag is null ) then
  chk_y_or_n
  (p_effective_date            =>  p_effective_date
  ,p_flag                      =>  p_rec.beneficiary_flag
  ,p_flag_name                 =>  'BENEFICIARY FLAG');
  end if;
  --
  -- Validate dependent_flag
  --
  if ( p_rec.dependent_flag <> hr_api.g_varchar2 OR
       p_rec.dependent_flag is null ) then
  chk_y_or_n
  (p_effective_date            =>  p_effective_date
  ,p_flag                      =>  p_rec.dependent_flag
  ,p_flag_name                 =>  'DEPENDENT_FLAG');
  end if;

  -- bug 3982865 ends here.


  per_ctr_bus.chk_contact_type
    (p_effective_date           => p_effective_date
    ,p_contact_relationship_id  => p_rec.contact_relationship_id
    ,p_contact_type             => p_rec.contact_type
    ,p_object_version_number    => p_rec.object_version_number
    );
  --
  -- Check that there's only one primary contact
  --
  chk_primary_contact(p_contact_relationship_id => p_rec.contact_relationship_id,
                      p_person_id               => p_rec.person_id,
                      p_primary_contact_flag    => p_rec.primary_contact_flag,
                      p_object_version_number   => p_rec.object_version_number,
                      p_date_start              => p_rec.date_start,
                      p_date_end                => p_rec.date_end
                      );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  chk_start_life_reason_id(p_contact_relationship_id => p_rec.contact_relationship_id,
                           p_start_life_reason_id    => p_rec.start_life_reason_id,
                           p_effective_date          => p_effective_date,
                           p_object_version_number   => p_rec.object_version_number
                           );
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  chk_end_life_reason_id(p_contact_relationship_id  => p_rec.contact_relationship_id
                         ,p_end_life_reason_id      => p_rec.end_life_reason_id
                         ,p_effective_date          => p_effective_date
                         ,p_object_version_number   => p_rec.object_version_number
                          );
  --
  hr_utility.set_location('Leaving:'||l_proc, 30);
  --
  chk_date_start_end(p_contact_relationship_id => p_rec.contact_relationship_id
                    ,p_date_start              => p_rec.date_start
                    ,p_date_end                => p_rec.date_end
                    ,p_object_version_number   => p_rec.object_version_number
                     );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
   chk_time_validation(p_contact_type             => p_rec.contact_type
                       ,p_person_id               => p_rec.person_id
                       ,p_contact_person_id       => p_rec.contact_person_id
                       ,p_contact_relationship_id => p_rec.contact_relationship_id
                       ,p_date_start              => p_rec.date_start
                       ,p_date_end                => p_rec.date_end
                       ,p_object_version_number   => p_rec.object_version_number
                        );
   --
   hr_utility.set_location(' Leaving:'||l_proc, 50);
   --
   chk_sequence_number(p_contact_relationship_id => p_rec.contact_relationship_id
                      ,p_sequence_number      => p_rec.sequence_number
            ,p_contact_person_id    => p_rec.contact_person_id
            ,p_person_id            => p_rec.person_id
            ,p_object_version_number => p_rec.object_version_number
            );
  --
  hr_utility.set_location(' Leaving:'||l_proc,60);
  --
  -- Bug fix 3326964.
  -- Function call to check whether relation ship start date is less tha
  -- contact's or person's date of birth.
  chk_date_of_birth(  p_person_id    		=> p_rec.person_id
		     ,p_contact_person_id       => p_rec.contact_person_id
   		     ,p_date_start              => p_rec.date_start
   		   );
  --
  hr_utility.set_location(' Leaving:'||l_proc,70);

  -- fix for bug8395666
  if hr_general.chk_product_installed(805) = 'TRUE' then
   ben_ELIG_DPNT_api.chk_enrt_for_dpnt(
    p_dpnt_person_id                => p_rec.contact_person_id
   ,p_dpnt_rltp_id                  => p_rec.contact_relationship_id
   ,p_rltp_type                     => p_rec.contact_type
   ,p_business_group_id             => p_rec.business_group_id);
   end if;
  --
  chk_ddf(p_rec => p_rec);
   --
  chk_df(p_rec => p_rec);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_ctr_shd.g_rec_type) is
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
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_contact_relationship_id     in number
  ) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups        pbg
         , per_contact_relationships  ctr
     where ctr.contact_relationship_id = p_contact_relationship_id
       and pbg.business_group_id = ctr.business_group_id;
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
                             p_argument       => 'contact_relationship_id',
                             p_argument_value => p_contact_relationship_id);
  --
if nvl(g_contact_relationship_id, hr_api.g_number) = p_contact_relationship_id then
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
    g_contact_relationship_id:= p_contact_relationship_id;
    g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
end return_legislation_code;
--
end per_ctr_bus;

/
