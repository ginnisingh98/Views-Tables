--------------------------------------------------------
--  DDL for Package Body PER_QUA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QUA_BUS" as
/* $Header: pequarhi.pkb 120.0.12010000.2 2008/08/06 09:31:13 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_qua_bus.';  -- Global package name
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_qualification_id            number         default null;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<  set_security_group_id  >------------------------|
--  ---------------------------------------------------------------------------
--
--
  procedure set_security_group_id
   (
    p_qualification_id             in per_qualifications.qualification_id%TYPE
   ,p_associated_column1           in varchar2 default null
   ) is
  --
  -- Declare cursor
  --
     cursor csr_sec_grp is
       select inf.org_information14
      from hr_organization_information inf
         , per_qualifications  qua
     where qua.qualification_id = p_qualification_id
       and inf.organization_id = qua.business_group_id
       and inf.org_information_context || '' = 'Business Group Information';
  --
  -- Local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72) := g_package||'set_security_group_id';
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'qualification_id',
                             p_argument_value => p_qualification_id);
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  if csr_sec_grp%notfound then
    close csr_sec_grp;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_multi_message.add
      (p_associated_column1 => nvl(p_associated_column1, 'QUALIFICATION_ID')
      );
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_qualification_id                     in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , per_qualifications qua
     where qua.qualification_id = p_qualification_id
       and pbg.business_group_id (+) = qua.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'qualification_id'
    ,p_argument_value     => p_qualification_id
    );
  --
  if ( nvl(per_qua_bus.g_qualification_id, hr_api.g_number)
       = p_qualification_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_qua_bus.g_legislation_code;
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
 per_qua_bus.g_qualification_id            := p_qualification_id;
    per_qua_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_qualification_id >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a qualification_id is unique. This column
--   is the primary key for the entity and so must be null on insert and
--   non-updateable on update.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_qualification_id         PK
--   p_object_version_number    object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_qualification_id (p_qualification_id      in number,
			        p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_qualification_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := per_qua_shd.api_updating
     (p_qualification_id        => p_qualification_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_qualification_id,hr_api.g_number)
     <> nvl(per_qua_shd.g_old_rec.qualification_id,hr_api.g_number)) then
    --
    -- raise error as PK has changed
    --
    per_qua_shd.constraint_error('PER_QUALIFICATIONS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_qualification_id is not null then
      --
      -- raise error as PK is not null
      --
      per_qua_shd.constraint_error('PER_QUALIFICATIONS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_qualification_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_qualification_type_id >------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a qualification_type_id is unique. This column
--   is the primary key for the entity and so must be null on insert and
--   non-updateable on update.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_qualification_id         PK
--   p_qualification_type_id    ID of qualification type
--   p_object_version_number    object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_qualification_type_id (p_qualification_id      in number,
                                     p_qualification_type_id in number,
			             p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_qualification_type_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_qualification_types per
    where  per.qualification_type_id = p_qualification_type_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := per_qua_shd.api_updating
     (p_qualification_id        => p_qualification_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_qualification_type_id,hr_api.g_number)
     <> nvl(per_qua_shd.g_old_rec.qualification_type_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if qualification type exist in per_qualification_types table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
	--
	close c1;
	--
	-- raise error as FK does not relate to PK in per_qualification_types
	-- table.
	--
        per_qua_shd.constraint_error('PER_QUALIFICATIONS_FK2');
	--
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_qualification_type_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_person_id >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a person_id or attendance_id are populated.
--   The person_id must exist in the per_people_f table as of the effective date
--   and the attendance_id must exist in the per_establishment_attendances table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_effective_date           effective date
--   p_qualification_id         PK
--   p_person_id                ID of person_id.
--   p_attendance_id            ID of attendance.
--   p_object_version_number    object version number
--   p_party_id                 ID of party -- HR/TCA merge
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_person_id (
                         p_effective_date        in date,
                         p_qualification_id      in number,
                         p_person_id             in number,
			 p_attendance_id         in number,
			 p_object_version_number in number,
                         p_party_id              in number
                        ) is
  --
  l_proc         varchar2(72) := g_package||'chk_person_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select  null
    from    per_all_people_f per  -- Bug 3148893. Replaced per_all_people_f with per_people_f
    where   per.person_id = p_person_id
    and     p_effective_date
    between per.effective_start_date
    and     nvl(per.effective_end_date,hr_api.g_eot);
  --
  cursor c2 is
    select null
    from   per_establishment_attendances per
    where  per.attendance_id = p_attendance_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := per_qua_shd.api_updating
     (p_qualification_id        => p_qualification_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and (nvl(p_person_id,hr_api.g_number)
          <> nvl(per_qua_shd.g_old_rec.person_id,hr_api.g_number)
	  or nvl(p_attendance_id,hr_api.g_number)
	  <> nvl(per_qua_shd.g_old_rec.attendance_id,hr_api.g_number))
     or not l_api_updating) then
    --
    -- check if attendance_id or person_id are populated and not both.
    --
    if (p_person_id is null
        and p_party_id is null   -- HR/TCA merge
	and p_attendance_id is null) then
        -- WWBUG 2658623 comment out the following 2 lines
	--or ((p_person_id is not null or p_party_id is not null)
	--and p_attendance_id is not null)) then
      --
      hr_utility.set_message(801,'HR_51833_QUA_PER_ATT_ID');
      hr_multi_message.add
        (p_associated_column1 => 'PER_QUALIFICATIONS.PERSON_ID'
        ,p_associated_column2 => 'PER_QUALIFICATIONS.PARTY_ID'
        ,p_associated_column3 => 'PER_QUALIFICATIONS.ATTENDANCE_ID'
        );
      --
    end if;
    --
    -- Check that values exist in the relevant tables.
    -- person_id must exist in PER_PEOPLE_F as of the effective date.
    -- attendance_id must exist in PER_ESTABLISHMENT_ATTENDANCES table.
    --
    if p_person_id is not null then
      --
      open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
	--
	close c1;
	hr_utility.set_message(801,'HR_51834_QUA_PER_ID_INV');
        hr_multi_message.add
          (p_associated_column1 => 'PER_QUALIFICATIONS.PERSON_ID'
          );
	--
      else
        --
        close c1;
        --
      end if;
      --
    end if;
    --
    if p_attendance_id is not null then
      --
      open c2;
	--
	fetch c2 into l_dummy;
	if c2%notfound then
	  --
	  close c2;
	  per_qua_shd.constraint_error('PER_QUALIFICATIONS_FK1');
	  --
        end if;
	--
      close c2;
      --
    end if;
    --
  end if;
  --
  --UPDATE of person id not allowed unless currently null(U)
  --
  if (l_api_updating
      and nvl(per_qua_shd.g_old_rec.person_id,hr_api.g_number) <> hr_api.g_number
      and per_qua_shd.g_old_rec.person_id <> p_person_id
     ) then
      --
        hr_utility.set_message(800, 'HR_289948_INV_UPD_PERSON_ID');
        hr_utility.raise_error;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_person_id;
--
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
--
Procedure chk_party_id(
   p_rec             in out nocopy per_qua_shd.g_rec_type
  ,p_effective_date  in date
  )is
--
  l_proc    varchar2(72)  :=  g_package||'chk_party_id';
  l_party_id     per_qualifications.party_id%TYPE;
  l_party_id2    per_qualifications.party_id%TYPE;
  l_person_id    per_establishment_attendances.person_id%TYPE;
--
  --
  -- cursor to check that the party_id maches person_id
  --
  cursor csr_get_party_id is
  select party_id
  from    per_all_people_f per
    where   per.person_id = p_rec.person_id
    and     p_effective_date
    between per.effective_start_date
    and     nvl(per.effective_end_date,hr_api.g_eot);
  --
  cursor csr_valid_party_id is
  select party_id
  from hz_parties hzp
  where hzp.party_id = p_rec.party_id;
  --
  cursor csr_attendances is
  select party_id
        ,person_id
  from per_establishment_attendances pea
  where  pea.attendance_id = p_rec.attendance_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  --
  if p_rec.person_id is not null then
    if hr_multi_message.no_all_inclusive_error
         (p_check_column1 => 'PER_QUALIFICATIONS.PERSON_ID'
	 ,p_check_column2 => 'PER_QUALIFICATIONS.PARTY_ID'
         ) then
      open csr_get_party_id;
      fetch csr_get_party_id into l_party_id;
      close csr_get_party_id;
      hr_utility.set_location(l_proc,20);
      if p_rec.party_id is not null then
        if p_rec.party_id <> nvl(l_party_id,-1) then
          hr_utility.set_message(800, 'HR_289343_PERSONPARTY_MISMATCH');
          hr_utility.set_location(l_proc,30);
          hr_multi_message.add
            (p_associated_column1 => 'PER_QUALIFICATIONS.PERSON_ID'
            ,p_associated_column2 => 'PER_QUALIFICATIONS.PARTY_ID'
            );
        end if;
      else
        --
        -- derive party_id from per_all_people_f using person_id
        --
          hr_utility.set_location(l_proc,50);
          p_rec.party_id := l_party_id;
      end if;
    end if; --end if for no_all_inclusive_error
  else
    if p_rec.attendance_id is not null then
      if hr_multi_message.no_all_inclusive_error
          (p_check_column1 => 'PER_QUALIFICATIONS.ATTENDANCE_ID'
	  ,p_check_column2 => 'PER_QUALIFICATIONS.PARTY_ID'
	  ) then
        open csr_attendances;
        fetch csr_attendances into l_party_id,l_person_id;
        close csr_attendances;
        hr_utility.set_location(l_proc,60);
        if p_rec.party_id is not null then
          if p_rec.party_id <> l_party_id then
            hr_utility.set_message(800, 'PER_289342_PARTY_ID_INVALID');
            hr_utility.set_location(l_proc,70);
            hr_multi_message.add
              (p_associated_column1 => 'PER_QUALIFICATIONS.ATTENDANCE_ID'
              ,p_associated_column2 => 'PER_QUALIFICATIONS.PARTY_ID'
              );
          end if;
        else
          --
          -- derive party_id from per_establishment_attendances
          --
          hr_utility.set_location(l_proc,80);
          -- p_rec.person_id := l_person_id;  WWBUG#2289195
          p_rec.party_id := l_party_id;
        end if;
      end if;--end if for no_all_inclusive_error
    else
      if p_rec.party_id is null then
        /* chk_person_id ensures that this does not occur*/
        hr_utility.set_message(800, 'HR_289341_CHK_PERSON_OR_PARTY');
        hr_utility.set_location(l_proc,90);
        hr_multi_message.add
          (p_associated_column1 => 'PER_QUALIFICATIONS.PERSON_ID'
          ,p_associated_column2 => 'PER_QUALIFICATIONS.PARTY_ID'
          ,p_associated_column3 => 'PER_QUALIFICATIONS.ATTENDANCE_ID'
          );
      else
        open csr_valid_party_id;
        fetch csr_valid_party_id into l_party_id2;
        if csr_valid_party_id%notfound then
          close csr_valid_party_id;
          hr_utility.set_message(800, 'PER_289342_PARTY_ID_INVALID');
          hr_utility.set_location(l_proc,100);
          hr_multi_message.add
            (p_associated_column1 => 'PER_QUALIFICATIONS.PARTY_ID'
            );
        else
          close csr_valid_party_id;
        end if;
      end if; -- party_id is null
    end if; -- att_id is not null
  end if; -- person_id is not null
  --
  hr_utility.set_location(' Leaving:'||l_proc,200);
End chk_party_id;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_status >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the status for a qualification is within the
--   lookup PER_SUBJECT_STATUSES.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_qualification_id         PK
--   p_status                   status of qualification
--   p_effective_date           effective date of session.
--   p_object_version_number    object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_status (p_qualification_id      in number,
                      p_status                in varchar2,
		      p_effective_date        in date,
		      p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_status';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := per_qua_shd.api_updating
     (p_qualification_id        => p_qualification_id,
      p_object_version_number   => p_object_version_number);
  --
  if p_status is not null then
    --
    if (l_api_updating
        and nvl(p_status,hr_api.g_varchar2)
        <> nvl(per_qua_shd.g_old_rec.status,hr_api.g_varchar2)
        or not l_api_updating) then
      --
      -- check if status value exists in PER_SUBJECT_STATUSES lookup.
      --
      if hr_api.not_exists_in_hr_lookups
	 (p_effective_date => p_effective_date,
	  p_lookup_type    => 'PER_SUBJECT_STATUSES',
	  p_lookup_code    => p_status) then
        --
        hr_utility.set_message(801,'HR_51835_QUA_STATUS_LKP');
        hr_utility.raise_error;
        --
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
        (p_associated_column1 => 'PER_QUALIFICATIONS.STATUS'
	) then
        --
        hr_utility.set_location(' Leaving:'||l_proc, 11);
        --
	raise;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
End chk_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_awarded_date >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the awarded date is after the start date and
--   later than or equal to the end date.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_qualification_id         PK
--   p_awarded_date             status of qualification
--   p_object_version_number    object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_awarded_date (p_qualification_id      in number,
                            p_awarded_date          in date,
                            p_start_date            in date,
                            p_object_version_number in number) is
  --
  --
Begin
  --
  per_qua_bus.chk_awarded_date
		(p_qualification_id          ,
                 p_awarded_date              ,
                 p_start_date                ,
                 NULL			     ,
                 NULL			     ,
                 p_object_version_number     );

  --
End chk_awarded_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_awarded_date >---------------------------|
-- ----------------------------------------------------------------------------
--
-- This is the overload procedure for chk_awarded_date
--
-- Description
--   This procedure checks that the awarded date is after the start date and
--   later than or equal to the end date.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_qualification_id         PK
--   p_awarded_date             status of qualification
--   p_object_version_number    object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_awarded_date (p_qualification_id          in number,
		            p_awarded_date              in date,
			    p_start_date                in date,
			    p_end_date                  in date,
			    p_projected_completion_date in date,
		            p_object_version_number     in number) is
  --
  l_proc                    varchar2(72) := g_package||'chk_awarded_date';
  l_old_awarded_date        varchar2(30) := to_char(per_qua_shd.g_old_rec.awarded_date);
  l_old_start_date          varchar2(30) := to_char(per_qua_shd.g_old_rec.start_date);
  l_old_proj_comp_date      varchar2(30) := to_char(per_qua_shd.g_old_rec.projected_completion_date);
  l_old_end_date            varchar2(30) := to_char(per_qua_shd.g_old_rec.end_date);
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('********BUG1956358********',99);
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := per_qua_shd.api_updating
     (p_qualification_id        => p_qualification_id,
      p_object_version_number   => p_object_version_number);
  --
  if p_awarded_date is not null then


hr_utility.set_location('Start Date= '||p_start_date,20);
hr_utility.set_location('Prev Start Date= '||l_old_start_date,30);
hr_utility.set_location('End Date= '||p_end_date,40);
hr_utility.set_location('Prev End Date= '||l_old_end_date,50);
hr_utility.set_location('Awarded Date= '||p_awarded_date,60);
hr_utility.set_location('Prev Awarded Date= '||l_old_awarded_date,70);
hr_utility.set_location('Proj Comp Date= '||p_projected_completion_date,80);
hr_utility.set_location('Prev Proj Comp Date= '||l_old_proj_comp_date,90);
    --
    if (l_api_updating
        and (nvl(p_awarded_date,hr_api.g_date)
                <> nvl(per_qua_shd.g_old_rec.awarded_date,hr_api.g_date)
             or nvl(p_start_date,hr_api.g_date)
                <> nvl(per_qua_shd.g_old_rec.start_date,hr_api.g_date)
              or nvl(p_projected_completion_date,hr_api.g_date)
                <> nvl (per_qua_shd.g_old_rec.projected_completion_date,hr_api.g_date)
              or nvl(p_end_date,hr_api.g_date)
                <> nvl (per_qua_shd.g_old_rec.end_date,hr_api.g_date))
        or not l_api_updating) then
      --
      -- check if awarded_date is after the start_date and greater than or
      -- equal to the projected/actual completion date.
      --

hr_utility.set_location('enter check for invalid dates',100);
hr_utility.set_location('start of time= '||hr_api.g_sot,110);
hr_utility.set_location('end of time= '||hr_api.g_eot,115);


hr_utility.set_location('Start Date= '||p_start_date,20);
hr_utility.set_location('Awarded Date= '||p_awarded_date,20);


 IF p_start_date is not null then
        hr_utility.set_location('p_start_date1',40);
              --hr_utility.set_message(801,'1Start Date Error');
        if p_awarded_date < p_start_date then
              hr_utility.set_location('Start Date Error',30);
              hr_utility.set_message(801,'HR_51836_QUA_AWARD_DATE_INV');
              hr_utility.set_message(801,'Start Date Error');
              hr_utility.raise_error;
         END IF;
  end if;

hr_utility.set_location('Project_comp_date= '||p_projected_completion_date,40);
hr_utility.set_location('End Date= '||p_end_date,40);
hr_utility.set_location('Awarded Date= '||p_awarded_date,40);

 IF p_end_date is not null then
	hr_utility.set_location('p_end_date1',40);
              --hr_utility.set_message(801,'1End Date Error');
	if p_awarded_date < p_end_date then
              hr_utility.set_location('End/Projected date error',50);
              hr_utility.set_message(800,'PER_289710_INVALID_AWARD_DATE');
              hr_utility.raise_error;
	END IF;

 else
    if p_projected_completion_date is not null then
	hr_utility.set_location('p_end_date2',40);
              --hr_utility.set_message(801,'1Projected Date Error');
	if p_awarded_date < p_projected_completion_date then
              hr_utility.set_location('End/Projected date error',50);
              hr_utility.set_message(800,'PER_289711_INVALID_AWARD_DATE');
              hr_utility.raise_error;
 	END IF;
    end if;
 end if;
     --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
        (p_associated_column1 => 'PER_QUALIFICATIONS.START_DATE'
        ,p_associated_column2 => 'PER_QUALIFICATIONS.AWARDED_DATE'
	) then
        --
        hr_utility.set_location(' Leaving:'||l_proc, 11);
        --
	raise;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
End chk_awarded_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_fee >------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the fee value is correct. If the fee has been
--   entered then the fee currency must lso be entered, likewise if the fee is
--   blank then the fee currency must also be blank.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_qualification_id         PK
--   p_fee	                value of fee to take qualification
--   p_fee_currency             currency of fee
--   p_object_version_number    object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_fee (p_qualification_id      in number,
		   p_fee                   in number,
		   p_fee_currency          in varchar2,
		   p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_fee';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   fnd_currencies fnd
    where  fnd.currency_code = p_fee_currency;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := per_qua_shd.api_updating
     (p_qualification_id        => p_qualification_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
      and (nvl(p_fee,hr_api.g_number)
           <> nvl(per_qua_shd.g_old_rec.fee,hr_api.g_number)
	   or nvl(p_fee_currency,hr_api.g_varchar2)
	   <> nvl(per_qua_shd.g_old_rec.fee_currency,hr_api.g_varchar2))
      or not l_api_updating) then
    --
    -- This if statement forces one of the following conditions
    -- a) FEE is NOT NULL and FEE CURRENCY is NOT NULL
    -- b) FEE is NULL and FEE CURRENCY is NULL
    --
    if (p_fee_currency is null
       and p_fee is not null
       or p_fee_currency is not null
       and p_fee is null) then
      --
      -- raise error as fee or fee currency has been set without the other
      -- having been set.
      --
      hr_utility.set_message(801,'HR_51840_QUA_FEE_CURRENCY');
      hr_multi_message.add
        (p_associated_column1 => 'PER_QUALIFICATIONS.FEE'
        ,p_associated_column2 => 'PER_QUALIFICATIONS.FEE_CURRENCY'
        );
      --
    end if;
    --
    -- check fee exists in fnd_currencies table
    --
    if p_fee_currency is not null
       and p_fee is not null then
      --
      open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        -- raise error as currency does not exist in table
        --
        close c1;
        hr_utility.set_message(801,'HR_51855_QUA_CCY_INV');
        --
        hr_multi_message.add
          (p_associated_column1 => 'PER_QUALIFICATIONS.FEE_CURRENCY'
          );
      else
        --
        close c1;
        --
      end if;
      --
    end if; --fee_curr is not null
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_fee;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_start_date >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the start date and end date are valid values.
--   The end_date must be after the start_date. The start and end dates must
--   bound all subjects taken and be within the dates of the establishment
--   attendance.
--
-- Bug: 1664055 Starts here.
--
--   This procedure also checks that the start date is greater than the Date of
--   Birth of the person if date of birth is not null. The start date can be
--   provided only if date of birth is not null.
--
-- Bug: 1664055 Ends here
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_qualification_id         PK
--   p_attendance_id		id of establishment attendance
--   p_start_date               start date of qualification
--   p_end_date                 end date of qualification
--   p_object_version_number    object version number
--   p_effective_date           Effective date
--   p_person_id                id of the person
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_start_date (p_qualification_id      in number,
		          p_attendance_id         in number,
		          p_start_date            in date,
		          p_end_date              in date,
		          p_object_version_number in number,
-- Bug: 1664055 Starts here.
		          p_effective_date        in date,
		          p_person_id    	  in number)
-- Bug: 1664055 Ends here.
  is
  --
  l_proc         varchar2(72) := g_package||'chk_start_date';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_dob          date;
  --
  -- This cursor checks that the dates of the qualification fall
  -- within the related establishment attendance
  --
  cursor c1 is
    select  null
    from    per_establishment_attendances per
    where   per.attendance_id = p_attendance_id
    and     nvl(p_start_date,nvl(per.attended_start_date,hr_api.g_sot))
    between nvl(per.attended_start_date,hr_api.g_sot)
    and     nvl(per.attended_end_date,hr_api.g_eot)
    and     nvl(p_end_date,nvl(per.attended_end_date,hr_api.g_eot))
    between nvl(per.attended_start_date,hr_api.g_sot)
    and     nvl(per.attended_end_date,hr_api.g_eot);
  --
  -- This cursor is used to check that the subjects taken are within the
  -- dates of the qualification.
  --
  cursor c2 is
    select  null
    from    per_subjects_taken per
    where   per.qualification_id = p_qualification_id
    and     per.start_date
    not between nvl(p_start_date,hr_api.g_sot)
    and     nvl(p_end_date,hr_api.g_eot);
  --
  -- Bug: 1664055 Starts here.
  --
  cursor c3 is
    select  DATE_OF_BIRTH
    from    per_all_people_f per
    where   per.person_id = p_person_id
    and     p_effective_date
    between per.effective_start_date
    and     nvl(per.effective_end_date,hr_api.g_eot)
    and     date_of_birth is not null;
  --
  -- Bug: 1664055 Ends here.
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := per_qua_shd.api_updating
     (p_qualification_id        => p_qualification_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
      or not l_api_updating) then
    --
    -- Bug: 1664055 Starts here.
    --
    if (p_start_date is not null) then
       open c3;
       fetch c3 into l_dob;
       if (c3%found) then
       if (l_dob is null) then
         close c3;
         hr_utility.set_message(800,'HR_289739_QUA_NULL_DOB');
         hr_utility.raise_error;
       elsif (l_dob > p_start_date) then
         close c3;
         hr_utility.set_message(800,'HR_289383_QUA_START_DATE');
         hr_utility.raise_error;
       end if;
       end if;
       close c3;
    end if;
    --
    -- Bug: 1664055 Ends here.
    --
    -- Check that the end date of the qualification is later than the start
    -- date for the qualification.
    --
    if nvl(p_start_date,hr_api.g_sot) >
       nvl(p_end_date,hr_api.g_eot) then
      --
      -- raise error as the qualification start date is after the qualification
      -- end date.
      --
      per_qua_shd.constraint_error('PER_QUA_CHK_DATES');
      --
    end if;
    --
    -- Only carry out checks if the start and end date for the qualification
    -- are not null and we have an attendance id.
    --
    if ((p_start_date is not null
      or p_end_date is not null)
      and p_attendance_id is not null) then
        if hr_multi_message.no_all_inclusive_error
	     (p_check_column1 => 'PER_QUALIFICATIONS.ATTENDANCE_ID'
	     ) then
          --
          -- Only carry out test on establishment attendance dates if attendance_id
          -- is not null.
          --
          open c1;
	  --
  	  fetch c1 into l_dummy;
  	  if c1%notfound then
            --
            -- raise error as qualification start and end dates are outside of
      	    -- the dates of the establishment attendance.
	    --
	    close c1;
            hr_utility.set_message(801,'HR_51841_QUA_DATES_OUT_ESA');
	    hr_multi_message.add
              (p_associated_column1 => 'PER_QUALIFICATIONS.ATTENDANCE_ID'
	      ,p_associated_column2 => 'PER_QUALIFICATIONS.START_DATE'
	      ,p_associated_column3 => 'PER_QUALIFICATIONS.END_DATE'
              );
	      --
          else
	    --
            close c1;
	    --
          end if; -- c1 not found
          --
        end if; -- hr_multi_message.no_all_inc_error
        --
    end if; -- start_date/end_date is not null and att_id is not null
    --
    -- WWBUG 2502284 drove this.
    --
    -- Bug fix 3239115. Same as 2502284.
    -- Validation of qualification start date with subject start date is
    -- commented to avoid the error occured while updating the qualification
    -- start date through SSHR or FUI.

/*    -- check if there are any subjects taken records that are not bound by the
    -- qualification start and end dates.
    --
    open c2;
    --
 if p_start_date is not null then
    fetch c2 into l_dummy;
    if c2%found then
      --
      -- raise error as we have found a linked subjects taken record that is
      -- not bounded by the qualification record.
      --
      close c2;
      hr_utility.set_message(801,'HR_51842_QUA_SUB_DATES');
      hr_multi_message.add
        (p_associated_column1 => 'PER_QUALIFICATIONS.QUALIFICATION_ID'
        ,p_associated_column2 => 'PER_QUALIFICATIONS.START_DATE'
        ,p_associated_column3 => 'PER_QUALIFICATIONS.END_DATE'
        );
      --
    else
      --
      close c2;
      --
    end if;
    --
end if;*/
  end if; -- l_api_updating
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_start_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_end_date >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the end date end date is a valid values.
--   It checks to see if the end date of the qualification is valid against
--   the subject end date.
--
-- This procedure was create to resolve bug 1854046
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_qualification_id         PK
--   p_start_date               start date of qualification
--   p_end_date                 end date of qualification
--   p_object_version_number    object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_end_date (p_qualification_id      in number,
		        p_start_date            in date,
		        p_end_date              in date,
		        p_object_version_number in number)
  is
  --
  l_proc         varchar2(72) := g_package||'chk_end_date';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_subject_start_date date;
  --
  -- This cursor checks the end date of the qualification against the end date
  -- of the subject end date, and ensures that it is valid.
  --

  cursor c1 is
     select  null
     from    per_subjects_taken per
     where   per.qualification_id = p_qualification_id
     and     nvl(per.end_date,per.start_date) > nvl(p_end_date,hr_api.g_eot);

Begin
--
 hr_utility.set_location('Entering:'||l_proc,5);
 --
  --
  open c1;
  --
   fetch c1 into l_dummy;
   if c1%found then
   --
   -- raise error as well have found a linked subjects taken record that is
   -- not bounded by the qualification record.
   --
   close c1;

      hr_utility.set_message(801,'HR_51842_QUA_SUB_DATES');
      hr_multi_message.add
        (p_associated_column1 => 'PER_QUALIFICATIONS.QUALIFICATION_ID'
        ,p_associated_column2 => 'PER_QUALIFICATIONS.START_DATE'
        ,p_associated_column3 => 'PER_QUALIFICATIONS.END_DATE'
        );
      --
    else
      --
      close c1;
      --
    end if;
--
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_end_date;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_projected_completion_date--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the projected completion date is after the
--   start date of the qualification.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_qualification_id          PK
--   p_start_date                start date of qualification
--   p_projected_completion_date projected completion date.
--   p_object_version_number     object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_projected_completion_date
    (p_qualification_id          in number,
     p_start_date                in date,
     p_projected_completion_date in date,
     p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_projected_completion_date';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  if hr_multi_message.no_all_inclusive_error
       (p_check_column1 => 'PER_QUALIFICATIONS.START_DATE'
       ) then
    l_api_updating := per_qua_shd.api_updating
       (p_qualification_id        => p_qualification_id,
        p_object_version_number   => p_object_version_number);
    --
    if (l_api_updating
      and (nvl(p_start_date,hr_api.g_date)
      <> nvl(per_qua_shd.g_old_rec.start_date,hr_api.g_date)
      or nvl(p_projected_completion_date,hr_api.g_date)
      <> nvl(per_qua_shd.g_old_rec.projected_completion_date,hr_api.g_date))
      or not l_api_updating) then
        --
        -- Check that if the projected completion date has been entered that it is
        -- later than the start date.
        --
        if p_projected_completion_date is not null
          and (p_start_date is null
	  or p_projected_completion_date < p_start_date) then
            --
            -- raise error as projected completion date is not after the
            -- start date.
            --
            hr_utility.set_message(801,'HR_51844_QUA_PROJ_DATE');
            hr_utility.raise_error;
            --
        end if;
        --
    end if;
    --
  end if; -- for no_all_inclusive_error
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
        (p_associated_column1 => 'PER_QUALIFICATIONS.START_DATE'
        ,p_associated_column2 => 'PER_QUALIFICATIONS.PROJECTED_COMPLETION_DATE'
	) then
        --
        hr_utility.set_location(' Leaving:'||l_proc, 11);
        --
	raise;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
End chk_projected_completion_date;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_tuition_method >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the tuition method is within the lookup
--   PER_TUITION_METHODS.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_qualification_id          PK
--   p_tuition_method            Tuition method used.
--   p_effective_date            date of session
--   p_object_version_number     object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_tuition_method (p_qualification_id      in number,
                              p_tuition_method        in varchar2,
			      p_effective_date        in date,
                              p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_tuition_method';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := per_qua_shd.api_updating
     (p_qualification_id        => p_qualification_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
      and (nvl(p_tuition_method,hr_api.g_varchar2)
           <> nvl(per_qua_shd.g_old_rec.tuition_method,hr_api.g_varchar2))
      or not l_api_updating) then
    --
    if p_tuition_method is not null then
      --
      -- Check if tuition method exists in lookup PER_TUITION_METHODS
      --
      if hr_api.not_exists_in_hr_lookups
	 (p_effective_date => p_effective_date,
	  p_lookup_type    => 'PER_TUITION_METHODS',
	  p_lookup_code    => p_tuition_method) then
        --
        hr_utility.set_message(801,'HR_51845_QUA_TUITION_MTHD');
        hr_utility.raise_error;
	--
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
        (p_associated_column1 => 'PER_QUALIFICATIONS.TUITION_METHOD'
	) then
        --
        hr_utility.set_location(' Leaving:'||l_proc, 11);
        --
	raise;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
End chk_tuition_method;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_estab_att_bg >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the establishment attendance business group
--   is the same as the business group for the qualification.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_qualification_id          PK
--   p_attendance_id             id of related establishment attendance
--   p_business_group_id         id of business group
--   p_object_version_number     object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_estab_att_bg (p_qualification_id      in number,
			    p_attendance_id         in number,
			    p_business_group_id     in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_estab_att_bg';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_establishment_attendances per
    where  per.attendance_id = p_attendance_id
    and    nvl(per.business_group_id,-1) = nvl(p_business_group_id,
                                       nvl(per.business_group_id,-1));
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  if hr_multi_message.no_all_inclusive_error
       (p_check_column1 => 'PER_QUALIFICATIONS.ATTENDANCE_ID'
       ) then
    --
    l_api_updating := per_qua_shd.api_updating
      (p_qualification_id        => p_qualification_id,
       p_object_version_number   => p_object_version_number);
    --
    if (l_api_updating
      and (nvl(p_attendance_id,hr_api.g_number)
           <> per_qua_shd.g_old_rec.attendance_id
	   or nvl(p_business_group_id,hr_api.g_number)
	   <> per_qua_shd.g_old_rec.business_group_id)
      or not l_api_updating) then
      --
      if p_attendance_id is not null then
        --
        -- check if BG for establishment attendance is the same as BG for
        -- qualification record.
        --
        open c1;
        --
        fetch c1 into l_dummy;
        if c1%notfound then
  	  --
          -- raise error as BG is different for establishment attendance and
	  -- qualification record.
	  --
	  close c1;
	  hr_utility.set_message(801,'HR_51848_QUA_ESTAB_ATT_BG');
	  hr_utility.raise_error;
	  --
        end if;
        --
	close c1;
	--
      end if; -- p_attendance_id is not null
      --
    end if; -- l_api_updating
    --
  end if; -- no_all_inclusive_error
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
        (p_associated_column1 => 'PER_QUALIFICATIONS.ATTENDANCE_ID'
	) then
        --
        hr_utility.set_location(' Leaving:'||l_proc, 11);
        --
	raise;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
End chk_estab_att_bg;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_person_bg >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the person being referenced is in the same
--   business group as the qualification and that the person exists as of
--   the effective date.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_effective_date            effective date
--   p_qualification_id          PK
--   p_person_id                 id of related establishment attendance
--   p_business_group_id         id of business group
--   p_object_version_number     object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_person_bg (p_effective_date        in date,
			 p_qualification_id      in number,
			 p_person_id             in number,
			 p_business_group_id     in number,
                         p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_person_bg';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select  null
    from    per_all_people_f per  -- Bug 3148893. Replaced per_all_people_f with per_people_f
    where   per.person_id = p_person_id
    and     per.business_group_id +0 = nvl(p_business_group_id,
                                        per.business_group_id)
    and     p_effective_date
    between per.effective_start_date
    and     nvl(per.effective_end_date,hr_api.g_eot);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  if hr_multi_message.no_all_inclusive_error
       (p_check_column1 => 'PER_QUALIFICATIONS.PERSON_ID'
       ) then
    --
    l_api_updating := per_qua_shd.api_updating
       (p_qualification_id        => p_qualification_id,
        p_object_version_number   => p_object_version_number);
    --
    if (l_api_updating
        and (nvl(p_person_id,hr_api.g_number)
             <> per_qua_shd.g_old_rec.person_id
	     or nvl(p_business_group_id,hr_api.g_number)
	     <> per_qua_shd.g_old_rec.business_group_id)
        or not l_api_updating) then
      --
      if p_person_id is not null then
        --
        -- check if BG for person is the same as BG for qualification record.
        --
        open c1;
        --
        fetch c1 into l_dummy;
        if c1%notfound then
  	  --
          -- raise error as BG is different for person and qualification record.
	  --
  	  close c1;
	  hr_utility.set_message(801,'HR_51849_QUA_PERSON_BG');
 	  hr_utility.raise_error;
	  --
        end if;
        --
        close c1;
        --
      end if; --p_person_id is not null
      --
    end if; -- l_api_updating
    --
  end if; -- no_all_inclusive_error
  --
  hr_utility.set_location(l_proc,9);
  --
  --UPDATE of BG_ID not allowed unless currently null(U)
  --
  if  (l_api_updating
       and nvl(per_qua_shd.g_old_rec.business_group_id,hr_api.g_number) <> hr_api.g_number
       and per_qua_shd.g_old_rec.business_group_id <> p_business_group_id ) then
     --
      hr_utility.set_message(800, 'HR_289947_INV_UPD_BG_ID');
      hr_utility.raise_error;
     --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
        (p_associated_column1 => 'PER_QUALIFICATIONS.PERSON_ID'
	) then
        --
        hr_utility.set_location(' Leaving:'||l_proc, 11);
        --
	raise;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
End chk_person_bg;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_qualification_delete >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks whether a qualification record can be deleted. If
--   a SUBJECTS_TAKEN record is referencing this record then it can not be
--   deleted.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_qualification_id          PK
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_qualification_delete (p_qualification_id in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_qualification_delete';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select  null
    from    per_subjects_taken per
    where   per.qualification_id = p_qualification_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  if hr_multi_message.no_all_inclusive_error
       (p_check_column1 => 'PER_QUALIFICATIONS.QUALIFICATION_ID'
       ) then
    --
    -- check if referenced records exist in the PER_SUBJECTS_TAKEN table.
    --
    open c1;
    --
    fetch c1 into l_dummy;
    if c1%found then
      --
      -- raise error as child records exist.
      --
      close c1;
      hr_utility.set_message(801,'HR_51857_QUA_REC_DEL');
      hr_utility.raise_error;
      --
    end if;
    --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
        (p_associated_column1 => 'PER_QUALIFICATIONS.QUALIFICATION_ID'
	) then
        --
        hr_utility.set_location(' Leaving:'||l_proc, 11);
        --
	raise;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
End chk_qualification_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_qual_overlap >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the qualification does not overlap for the
--   same person. The qualification is distinguished by business_group_id,
--   person_id, attendance_id, qualification_id and start date. The start date
--   must not overlap an identical qualification for the same person.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_qualification_id          PK
--   p_qualification_type_id     id of related qualification type
--   p_person_id                 id of person
--   p_attendance_id             id of related establishment attendance
--   p_business_group_id         id of business group
--   p_start_date                start date of qualification
--   p_end_date                  end date of qualification
--   p_title                     title of course taken
--   p_object_version_number     object version number
--   p_party_id                  id of party -- HR/TCA merge
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_qual_overlap (p_qualification_id      in number,
                            p_qualification_type_id in number,
                            p_person_id             in number,
                            p_attendance_id         in number,
                            p_business_group_id     in number,
                            p_start_date            in date,
                            p_end_date              in date,
                            p_title                 in varchar2,
                            p_object_version_number in number,
                            p_party_id              in number default null
                           ) is
  --
  l_proc         varchar2(72) := g_package||'chk_qual_overlap';
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  per_qat_bus.chk_qual_overlap
    (p_qualification_id       => p_qualification_id
    ,p_qualification_type_id  => p_qualification_type_id
    ,p_person_id              => p_person_id
    ,p_attendance_id          => p_attendance_id
    ,p_business_group_id      => p_business_group_id
    ,p_start_date             => p_start_date
    ,p_end_date               => p_end_date
    ,p_title                  => p_title
    ,p_object_version_number  => p_object_version_number
    ,p_party_id               => p_party_id
    ,p_language               => userenv('LANG'));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_qual_overlap;
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
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_df
  (p_rec in per_qua_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.qualification_id is not null) and (
     nvl(per_qua_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.attribute_category, hr_api.g_varchar2) or
     nvl(per_qua_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.attribute1, hr_api.g_varchar2) or
     nvl(per_qua_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.attribute2, hr_api.g_varchar2) or
     nvl(per_qua_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.attribute3, hr_api.g_varchar2) or
     nvl(per_qua_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.attribute4, hr_api.g_varchar2) or
     nvl(per_qua_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.attribute5, hr_api.g_varchar2) or
     nvl(per_qua_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.attribute6, hr_api.g_varchar2) or
     nvl(per_qua_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.attribute7, hr_api.g_varchar2) or
     nvl(per_qua_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.attribute8, hr_api.g_varchar2) or
     nvl(per_qua_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.attribute9, hr_api.g_varchar2) or
     nvl(per_qua_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.attribute10, hr_api.g_varchar2) or
     nvl(per_qua_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.attribute11, hr_api.g_varchar2) or
     nvl(per_qua_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.attribute12, hr_api.g_varchar2) or
     nvl(per_qua_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.attribute13, hr_api.g_varchar2) or
     nvl(per_qua_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.attribute14, hr_api.g_varchar2) or
     nvl(per_qua_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.attribute15, hr_api.g_varchar2) or
     nvl(per_qua_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.attribute16, hr_api.g_varchar2) or
     nvl(per_qua_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.attribute17, hr_api.g_varchar2) or
     nvl(per_qua_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.attribute18, hr_api.g_varchar2) or
     nvl(per_qua_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.attribute19, hr_api.g_varchar2) or
     nvl(per_qua_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.attribute20, hr_api.g_varchar2)))
     or
     (p_rec.qualification_id is null) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_QUALIFICATIONS'
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
      ,p_attribute20_value  => p_rec.attribute20);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_df;
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
  (p_rec in per_qua_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.qualification_id is not null)  and (
    nvl(per_qua_shd.g_old_rec.qua_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information_category, hr_api.g_varchar2)  or
    nvl(per_qua_shd.g_old_rec.qua_information1, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information1, hr_api.g_varchar2)  or
    nvl(per_qua_shd.g_old_rec.qua_information2, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information2, hr_api.g_varchar2)  or
    nvl(per_qua_shd.g_old_rec.qua_information3, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information3, hr_api.g_varchar2)  or
    nvl(per_qua_shd.g_old_rec.qua_information4, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information4, hr_api.g_varchar2)  or
    nvl(per_qua_shd.g_old_rec.qua_information5, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information5, hr_api.g_varchar2)  or
    nvl(per_qua_shd.g_old_rec.qua_information6, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information6, hr_api.g_varchar2)  or
    nvl(per_qua_shd.g_old_rec.qua_information7, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information7, hr_api.g_varchar2)  or
    nvl(per_qua_shd.g_old_rec.qua_information8, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information8, hr_api.g_varchar2)  or
    nvl(per_qua_shd.g_old_rec.qua_information9, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information9, hr_api.g_varchar2)  or
    nvl(per_qua_shd.g_old_rec.qua_information10, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information10, hr_api.g_varchar2)  or
    nvl(per_qua_shd.g_old_rec.qua_information11, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information11, hr_api.g_varchar2)  or
    nvl(per_qua_shd.g_old_rec.qua_information12, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information12, hr_api.g_varchar2)  or
    nvl(per_qua_shd.g_old_rec.qua_information13, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information13, hr_api.g_varchar2)  or
    nvl(per_qua_shd.g_old_rec.qua_information14, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information14, hr_api.g_varchar2)  or
    nvl(per_qua_shd.g_old_rec.qua_information15, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information15, hr_api.g_varchar2)  or
    nvl(per_qua_shd.g_old_rec.qua_information16, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information16, hr_api.g_varchar2)  or
    nvl(per_qua_shd.g_old_rec.qua_information17, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information17, hr_api.g_varchar2)  or
    nvl(per_qua_shd.g_old_rec.qua_information18, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information18, hr_api.g_varchar2)  or
    nvl(per_qua_shd.g_old_rec.qua_information19, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information19, hr_api.g_varchar2)  or
    nvl(per_qua_shd.g_old_rec.qua_information20, hr_api.g_varchar2) <>
    nvl(p_rec.qua_information20, hr_api.g_varchar2) ))
    or (p_rec.qualification_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Qualification Developer DF'
      ,p_attribute_category              => p_rec.qua_INFORMATION_CATEGORY
      ,p_attribute1_name                 => 'QUA_INFORMATION1'
      ,p_attribute1_value                => p_rec.qua_information1
      ,p_attribute2_name                 => 'QUA_INFORMATION2'
      ,p_attribute2_value                => p_rec.qua_information2
      ,p_attribute3_name                 => 'QUA_INFORMATION3'
      ,p_attribute3_value                => p_rec.qua_information3
      ,p_attribute4_name                 => 'QUA_INFORMATION4'
      ,p_attribute4_value                => p_rec.qua_information4
      ,p_attribute5_name                 => 'QUA_INFORMATION5'
      ,p_attribute5_value                => p_rec.qua_information5
      ,p_attribute6_name                 => 'QUA_INFORMATION6'
      ,p_attribute6_value                => p_rec.qua_information6
      ,p_attribute7_name                 => 'QUA_INFORMATION7'
      ,p_attribute7_value                => p_rec.qua_information7
      ,p_attribute8_name                 => 'QUA_INFORMATION8'
      ,p_attribute8_value                => p_rec.qua_information8
      ,p_attribute9_name                 => 'QUA_INFORMATION9'
      ,p_attribute9_value                => p_rec.qua_information9
      ,p_attribute10_name                => 'QUA_INFORMATION10'
      ,p_attribute10_value               => p_rec.qua_information10
      ,p_attribute11_name                => 'QUA_INFORMATION11'
      ,p_attribute11_value               => p_rec.qua_information11
      ,p_attribute12_name                => 'QUA_INFORMATION12'
      ,p_attribute12_value               => p_rec.qua_information12
      ,p_attribute13_name                => 'QUA_INFORMATION13'
      ,p_attribute13_value               => p_rec.qua_information13
      ,p_attribute14_name                => 'QUA_INFORMATION14'
      ,p_attribute14_value               => p_rec.qua_information14
      ,p_attribute15_name                => 'QUA_INFORMATION15'
      ,p_attribute15_value               => p_rec.qua_information15
      ,p_attribute16_name                => 'QUA_INFORMATION16'
      ,p_attribute16_value               => p_rec.qua_information16
      ,p_attribute17_name                => 'QUA_INFORMATION17'
      ,p_attribute17_value               => p_rec.qua_information17
      ,p_attribute18_name                => 'QUA_INFORMATION18'
      ,p_attribute18_value               => p_rec.qua_information18
      ,p_attribute19_name                => 'QUA_INFORMATION19'
      ,p_attribute19_value               => p_rec.qua_information19
      ,p_attribute20_name                => 'QUA_INFORMATION20'
      ,p_attribute20_value               => p_rec.qua_information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec            in out nocopy per_qua_shd.g_rec_type,
			  p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_BUSINESS_GROUP_ID
  -- HR/TCA merge
  -- if party_id is not null, business_group_id is not mandatory parameter
  --
  if p_rec.party_id is null and p_rec.business_group_id is not null then
       hr_api.validate_bus_grp_id
         (p_business_group_id => p_rec.business_group_id
	 ,p_associated_column1 => per_qua_shd.g_tab_nam || '.BUSINESS_GROUP_ID'
	 );  -- Validate Bus Grp
  end if;
  --
  -- After validating the set of important attributes,
  -- if Multiple Message Detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_QUALIFICATION_ID
  chk_qualification_id
    (p_qualification_id      => p_rec.qualification_id,
     p_object_version_number => p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_QUALIFICATION_TYPE_ID
  chk_qualification_type_id
    (p_qualification_id      => p_rec.qualification_id,
     p_qualification_type_id => p_rec.qualification_type_id,
     p_object_version_number => p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PERSON_ID
  chk_person_id
    (p_effective_date        => p_effective_date,
     p_qualification_id      => p_rec.qualification_id,
     p_person_id             => p_rec.person_id,
     p_attendance_id         => p_rec.attendance_id,
     p_object_version_number => p_rec.object_version_number,
     p_party_id              => p_rec.party_id);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PARTY_ID
  chk_party_id
     (p_rec
     ,p_effective_date
     );
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_STATUS
  chk_status
    (p_qualification_id      => p_rec.qualification_id,
     p_status                => p_rec.status,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_AWARDED_DATE
  chk_awarded_date
    (p_qualification_id          => p_rec.qualification_id,
     p_awarded_date              => p_rec.awarded_date,
     p_start_date                => p_rec.start_date,
     p_end_date                  => p_rec.end_date,
     p_projected_completion_date => p_rec.projected_completion_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_FEE
  -- CHK_FEE_CURRENCY
  chk_fee
    (p_qualification_id      => p_rec.qualification_id,
     p_fee                   => p_rec.fee,
     p_fee_currency          => p_rec.fee_currency,
     p_object_version_number => p_rec.object_version_number);
  --
  -- Busines Rule Mapping
  -- ====================
  -- CHK_START_DATE
  -- CHK_END_DATE
  chk_start_date
    (p_qualification_id      => p_rec.qualification_id,
     p_attendance_id         => p_rec.attendance_id,
     p_start_date            => p_rec.start_date,
     p_end_date              => p_rec.end_date,
     p_object_version_number => p_rec.object_version_number,
     p_effective_date        => p_effective_date,
     p_person_id             => p_rec.person_id);

  -- Bug Fix 3267372.
  -- Validation of qualification end date against subject
  -- start date and end date is relaxed.

  /* --
  -- Busines Rule Mapping
  -- ====================
  -- CHK_END_DATE
     chk_end_date
    (p_qualification_id      => p_rec.qualification_id,
     p_start_date            => p_rec.start_date,
     p_end_date              => p_rec.end_date,
     p_object_version_number => p_rec.object_version_number);*/
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PROJECTED_COMPLETION_DATE
  chk_projected_completion_date
    (p_qualification_id          => p_rec.qualification_id,
     p_start_date                => p_rec.start_date,
     p_projected_completion_date => p_rec.projected_completion_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_TUITION_METHOD
  chk_tuition_method
    (p_qualification_id      => p_rec.qualification_id,
     p_tuition_method        => p_rec.tuition_method,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ESTAB_ATT_BG
  chk_estab_att_bg
    (p_qualification_id      => p_rec.qualification_id,
     p_attendance_id         => p_rec.attendance_id,
     p_business_group_id     => p_rec.business_group_id,
     p_object_version_number => p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PERSON_BG
  chk_person_bg
    (p_effective_date        => p_effective_date,
     p_qualification_id      => p_rec.qualification_id,
     p_person_id             => p_rec.person_id,
     p_business_group_id     => p_rec.business_group_id,
     p_object_version_number => p_rec.object_version_number);
  --
  -- Descriptive Flex Check
  -- ======================
  --
/*
  IF hr_general.get_calling_context <>FORMS' THEN
    per_qua_flex.df(p_rec => p_rec);
  END IF;
*/
  --
  -- call descriptive flexfield validation routines
  --
  per_qua_bus.chk_df(p_rec => p_rec);
  --
  per_qua_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec            in out nocopy per_qua_shd.g_rec_type,
			  p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
hr_utility.set_location('End Date Hello = '||p_rec.end_date,998);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_BUSINESS_GROUP_ID
  -- if party_id is not null, business_group_id is not mandatory parameter
  --
  if p_rec.party_id is null and p_rec.business_group_id is not null then
       hr_api.validate_bus_grp_id
         (p_business_group_id => p_rec.business_group_id
	 ,p_associated_column1 => per_qua_shd.g_tab_nam || '.BUSINESS_GROUP_ID'
         );  -- Validate Bus Grp
  end if;
  --
  -- After validating the set of important attributes,
  -- if Multiple Message Detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_QUALIFICATION_ID
  chk_qualification_id
    (p_qualification_id      => p_rec.qualification_id,
     p_object_version_number => p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_QUALIFICATION_TYPE_ID
  chk_qualification_type_id
    (p_qualification_id      => p_rec.qualification_id,
     p_qualification_type_id => p_rec.qualification_type_id,
     p_object_version_number => p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PERSON_ID
  chk_person_id
    (p_effective_date        => p_effective_date,
     p_qualification_id      => p_rec.qualification_id,
     p_person_id             => p_rec.person_id,
     p_attendance_id         => p_rec.attendance_id,
     p_object_version_number => p_rec.object_version_number,
     p_party_id              => p_rec.party_id);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PARTY_ID
  chk_party_id
     (p_rec
     ,p_effective_date
     );
  --
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_STATUS
  chk_status
    (p_qualification_id      => p_rec.qualification_id,
     p_status                => p_rec.status,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
hr_utility.set_location('End Date Hello = '||p_rec.end_date,999);
  -- CHK_AWARDED_DATE
  chk_awarded_date
    (p_qualification_id           => p_rec.qualification_id,
     p_awarded_date               => p_rec.awarded_date,
     p_start_date                 => p_rec.start_date,
     p_end_date                   => p_rec.end_date,
     p_projected_completion_date  => p_rec.projected_completion_date,
     p_object_version_number      => p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_FEE
  -- CHK_FEE_CURRENCY
  chk_fee
    (p_qualification_id      => p_rec.qualification_id,
     p_fee                   => p_rec.fee,
     p_fee_currency          => p_rec.fee_currency,
     p_object_version_number => p_rec.object_version_number);
  --
  -- Busines Rule Mapping
  -- ====================
  -- CHK_START_DATE
  chk_start_date
    (p_qualification_id      => p_rec.qualification_id,
     p_attendance_id         => p_rec.attendance_id,
     p_start_date            => p_rec.start_date,
     p_end_date              => p_rec.end_date,
     p_object_version_number => p_rec.object_version_number,
     p_effective_date        => p_effective_date,
     p_person_id             => p_rec.person_id);

  -- Bug Fix 3267372.
  -- Validation of qualification end date against subject
  -- start date and end date is relaxed.
  --
  /*
  -- Busines Rule Mapping
  -- ====================
  -- CHK_END_DATE
  chk_end_date
    (p_qualification_id      => p_rec.qualification_id,
     p_start_date            => p_rec.start_date,
     p_end_date              => p_rec.end_date,
     p_object_version_number => p_rec.object_version_number);
  --
  */
  -- Business Rule Mapping
  -- =====================
  -- CHK_PROJECTED_COMPLETION_DATE
  chk_projected_completion_date
    (p_qualification_id          => p_rec.qualification_id,
     p_start_date                => p_rec.start_date,
     p_projected_completion_date => p_rec.projected_completion_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_TUITION_METHOD
  chk_tuition_method
    (p_qualification_id      => p_rec.qualification_id,
     p_tuition_method        => p_rec.tuition_method,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ESTAB_ATT_BG
  chk_estab_att_bg
    (p_qualification_id      => p_rec.qualification_id,
     p_attendance_id         => p_rec.attendance_id,
     p_business_group_id     => p_rec.business_group_id,
     p_object_version_number => p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PERSON_BG
  chk_person_bg
    (p_effective_date        => p_effective_date,
     p_qualification_id      => p_rec.qualification_id,
     p_person_id             => p_rec.person_id,
     p_business_group_id     => p_rec.business_group_id,
     p_object_version_number => p_rec.object_version_number);
  --
  -- Descriptive Flex Check
  -- ======================
  --
/*
  IF hr_general.get_calling_context <>FORMS' THEN
    per_qua_flex.df(p_rec => p_rec);
  END IF;
*/
  --
  -- call descriptive flexfield validation routines
  --
  per_qua_bus.chk_df(p_rec => p_rec);
  --
  per_qua_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_qua_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_QUALIFICATION_DELETE
  chk_qualification_delete(p_qualification_id => p_rec.qualification_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_qua_bus;

/
