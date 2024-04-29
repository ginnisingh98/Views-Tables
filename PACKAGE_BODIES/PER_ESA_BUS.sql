--------------------------------------------------------
--  DDL for Package Body PER_ESA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ESA_BUS" as
/* $Header: peesarhi.pkb 120.0.12010000.4 2009/07/01 08:09:14 psugumar ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_esa_bus.';  -- Global package name
--
--
-- The following two global variables are only to be used by the
-- return_legislation_code function.
--
g_attendance_id number default null;
g_legislation_code varchar2(150) default null;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_attendance_id >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the establishment
--   attendance table is created properly. It should be null on insert and
--   should not be able to be updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   attendance_id	                PK of record being inserted or updated.
--   object_version_number              Object version number of record being
--                                      inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_attendance_id(p_attendance_id               in number,
		            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_attendance_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_esa_shd.api_updating
    (p_attendance_id               => p_attendance_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_attendance_id,hr_api.g_number)
      <>  per_esa_shd.g_old_rec.attendance_id) then
    --
    -- raise error as PK has changed
    --
    per_esa_shd.constraint_error('PER_ESTAB_ATTENDANCES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_attendance_id is not null then
      --
      -- raise error as PK is not null
      --
      per_esa_shd.constraint_error('PER_ESTAB_ATTENDANCES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End chk_attendance_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_person_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the person_id has not been inserted
--   into the establishment attendance table already.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   attendance_id	                PK of record being inserted or updated.
--   person_id                          id of person being inserted.
--   attended_start_date                date of attendance at the establishment
--   establishment_id                   id of the establishment
--   establishment                      name of establishment (created on fly)
--   business_group_id                  id of business group
--   object_version_number              Object version number of record being
--                                      inserted or updated.
--   party_id                           id of party being inserted. -- HR/TCA merge
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
Procedure chk_person_id(p_attendance_id               in number,
			p_person_id                   in number,
			p_attended_start_date         in date,
			p_establishment_id            in number,
			p_establishment               in varchar2,
			p_business_group_id           in number,
			p_object_version_number       in number,
			p_party_id                    in number -- HR/TCA merge
                       ) is
  --
  l_proc         varchar2(72) := g_package||'chk_person_id';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is
    select null
    from   per_establishment_attendances per
    where  nvl(per.person_id,-1) = nvl(p_person_id,-1)
    and    per.attended_start_date = nvl(p_attended_start_date,hr_api.g_sot)
    and    nvl(per.establishment_id,-1) = nvl(p_establishment_id,-1)
    and    nvl(per.establishment,-1) = nvl(p_establishment,-1)
    and    nvl(per.business_group_id,-1) = nvl(p_business_group_id,-1);
  --
  cursor c2 is
    select null
    from   per_establishment_attendances per
    where  per.party_id = p_party_id
    and    per.attended_start_date = nvl(p_attended_start_date,hr_api.g_sot)
    and    nvl(per.establishment_id,-1) = nvl(p_establishment_id,-1)
    and    nvl(per.establishment,-1) = nvl(p_establishment,-1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_esa_shd.api_updating
    (p_attendance_id               => p_attendance_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and (nvl(p_person_id,hr_api.g_number)
	   <>  per_esa_shd.g_old_rec.person_id
	   or nvl(p_party_id,hr_api.g_number) -- HR/TCA merge
	   <> per_esa_shd.g_old_rec.party_id
	   or nvl(p_attended_start_date,hr_api.g_date)
	   <> nvl(per_esa_shd.g_old_rec.attended_start_date,hr_api.g_date ) --Bug 8364149
           or nvl(p_establishment_id,hr_api.g_number)
	   <> per_esa_shd.g_old_rec.establishment_id
	   or nvl(p_establishment,hr_api.g_varchar2)
	   <> per_esa_shd.g_old_rec.establishment
	   or nvl(p_business_group_id,hr_api.g_number)
	   <> per_esa_shd.g_old_rec.business_group_id)
      or not l_api_updating) then
    --
    -- check if person_id is null
    --
    if p_person_id is null then
      -- HR/TCA merge
      -- if person_id is null and party_id is null, raise error.
      --
      if p_party_id is null then
        --
        -- raise error as this a mandatory requirement
        --
        hr_utility.set_message(801,'HR_51494_ESA_CHK_PERSON_ID');
        hr_utility.raise_error;
        --
      else
      --
      -- check if the changes made to the above parameters result in a unique
      -- record existing in the per_establishment_attendances table, if not raise an
      -- error as someone is trying to enter the same person twice.
      --
        open c2;
        --
        fetch c2 into l_dummy;
        --
        if c2%found then
	--
	  close c2;
  	  --
	  -- raise error as record alreasy exists
	  --
	  per_esa_shd.constraint_error('PER_ESTAB_ATTENDANCES_UK');
	  --
        end if;
        --
        close c2;
        --
      end if;
    else
    --
    -- check if the changes made to the above parameters result in a unique
    -- record existing in the per_establishment_attendances table, if not raise an
    -- error as someone is trying to enter the same person twice.
    --
    open c1;
      --
      fetch c1 into l_dummy;
      --
      if c1%found then
	--
	close c1;
	--
	-- raise error as record alreasy exists
	--
	per_esa_shd.constraint_error('PER_ESTAB_ATTENDANCES_UK');
	--
      end if;
      --
    close c1;
    --
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  --UPDATE of person_id not allowed unless currently null(U)
  --
  if (l_api_updating
      and nvl(per_esa_shd.g_old_rec.person_id,hr_api.g_number) <> hr_api.g_number
      and per_esa_shd.g_old_rec.person_id <> p_person_id
     ) then
      --
        hr_utility.set_message(800, 'HR_289948_INV_UPD_PERSON_ID');
        hr_utility.raise_error;
      --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End chk_person_id;
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
   p_rec             in out nocopy per_esa_shd.g_rec_type
  ,p_effective_date  in date
  )is
--
  l_proc    varchar2(72)  :=  g_package||'chk_party_id';
  l_party_id     per_establishment_attendances.party_id%TYPE;
  l_party_id2    per_establishment_attendances.party_id%TYPE;
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
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  --
  if p_rec.person_id is not null then
    open csr_get_party_id;
    fetch csr_get_party_id into l_party_id;
    close csr_get_party_id;
    hr_utility.set_location(l_proc,20);
    if p_rec.party_id is not null then
      if p_rec.party_id <> nvl(l_party_id,-1) then
        hr_utility.set_message(800, 'HR_289343_PERSONPARTY_MISMATCH');
        hr_utility.set_location(l_proc,30);
        hr_utility.raise_error;
      end if;
    else
      --
      -- derive party_id from per_all_people_f using person_id
      --
        hr_utility.set_location(l_proc,50);
        p_rec.party_id := l_party_id;
    end if;
  else
    if p_rec.party_id is null then
        hr_utility.set_message(800, 'HR_289341_CHK_PERSON_OR_PARTY');
        hr_utility.set_location(l_proc,60);
        hr_utility.raise_error;
    else
      open csr_valid_party_id;
      fetch csr_valid_party_id into l_party_id2;
      if csr_valid_party_id%notfound then
        close csr_valid_party_id;
        hr_utility.set_message(800, 'PER_289342_PARTY_ID_INVALID');
        hr_utility.set_location(l_proc,70);
        hr_utility.raise_error;
      end if;
      close csr_valid_party_id;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,100);
End chk_party_id;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_address_constraints >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the establishment_id is not being
--   updated at the same time as the address is being changed.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   address				establishment address
--   attendance_id                      PK of record being inserted or updated.
--   effective_date                     effective date
--   object_version_number              Object version number of record being
--                                      inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_address_constraints(p_address		 in varchar2
				,p_establishment_id	 in number
				,p_object_version_number in number
				,p_attendance_id	 in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_address_constraints';
  l_api_updating boolean;

  l_temp         varchar2(4000) := per_esa_shd.g_old_rec.address;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_esa_shd.api_updating
    (p_attendance_id           	=> p_attendance_id,
     p_object_version_number    => p_object_version_number);

   hr_utility.set_location(p_address,6);
   hr_utility.set_location(l_temp,6);
   --hr_utility.set_location(l_api_updating,6);
  --
  if (l_api_updating
      and nvl(p_address,hr_api.g_varchar2)
      <> nvl(per_esa_shd.g_old_rec.address,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if establishment_id is changeing at the same time as the address
    --
    hr_utility.set_location(p_address,10);
    hr_utility.set_location(p_establishment_id,10);
    --
    if nvl(p_establishment_id,hr_api.g_number) <> nvl(per_esa_shd.g_old_rec.establishment_id,hr_api.g_number)  and p_attendance_id is not null then
      --
      -- raise error as does not exist as lookup
      --
 	fnd_message.set_name('PER', 'HR_289587_ESA_ADDRESS_UPDATE');
     	hr_utility.raise_error;
      --
    end if;

  elsif (l_api_updating
      and nvl(p_establishment_id,hr_api.g_number)
      <> per_esa_shd.g_old_rec.establishment_id
      or not l_api_updating) then

      hr_utility.set_location('Establishment Updating',15);
      hr_utility.set_location(p_address,15);
      --
      -- check if establishment_id is being changed when the address is not null
      --

        if p_address is not null then

          --
          -- Raise error to get user to delete the address of old establishment before
          -- updating the establishment_id
          --
              fnd_message.set_name('PER', 'HR_289586_ESA_ADDRESS_NULL');
              hr_utility.raise_error;

        end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,20);
  --
end chk_address_constraints;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_full_time >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the full_time lookup has a value of
--   Y/N, i.e. falls within the YES_NO lookup.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   attendance_id	                PK of record being inserted or updated.
--   full_time                          whether the attendance is full or
--                                      part time uses YES_NO lookup.
--   effective_date                     effective date
--   object_version_number              Object version number of record being
--                                      inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_full_time(p_attendance_id               in number,
		        p_full_time                   in varchar2,
			p_effective_date              in date,
		        p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_full_time';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_esa_shd.api_updating
    (p_attendance_id               => p_attendance_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_full_time,hr_api.g_varchar2)
      <> per_esa_shd.g_old_rec.full_time
      or not l_api_updating) then
    --
    -- check if value of full time falls within Full or Part time
    --
    hr_utility.set_location(p_full_time,100);
    --
    if hr_api.not_exists_in_hr_lookups(p_lookup_type    => 'YES_NO',
		                       p_lookup_code    => p_full_time,
		               p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_51511_ESA_FULL_TIME_LKP');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_full_time;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_estab_location >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that either the establishment_id or the
--   establishment is populated. If the establishment id is populated then it
--   must exist in the per_establishments table.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   attendance_id	                PK of record being inserted or updated.
--   establishment_id                   id of establishment
--   establishment                      establishment location
--   object_version_number              Object version number of record being
--                                      inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_estab_location(p_attendance_id               in number,
			     p_establishment_id            in number,
			     p_establishment               in varchar2,
			     p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_estab_location';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is
    select null
    from   per_establishments per
    where  per.establishment_id = p_establishment_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_esa_shd.api_updating
    (p_attendance_id               => p_attendance_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      or not l_api_updating) then
    --
    -- check if establishment and establishment attendance id are populated
    -- only one should be populated.
    --
    if (p_establishment_id is null
	and p_establishment is null
	or (p_establishment is not null
	    and p_establishment_id is not null)) then
      --
      -- raise error as either establishmnet or establishment_id must be
      -- populated but not both.
      --
      hr_utility.set_message(801,'HR_51495_ESA_ESTAB_ID_NULL');
      hr_utility.raise_error;
      --
    end if;
    --
    -- check if establishment id has changed and if so does the establishment
    -- exist in per_establishments table.
    --
    if p_establishment_id is not null
       and (not l_api_updating
       or (l_api_updating
	   and nvl(p_establishment_id,hr_api.g_number)
	   <>  per_esa_shd.g_old_rec.establishment_id)) then
      --
      -- check if establishment id exists in per_establishments table
      --
      open c1;
	--
	fetch c1 into l_dummy;
	--
	if c1%notfound then
	  --
	  close c1;
	  --
	  -- raise error as establishment_id doesn't exist
	  --
	  per_esa_shd.constraint_error('PER_ESTAB_ATTENDANCES_FK1');
	  --
        end if;
	--
      close c1;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
end chk_estab_location;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_att_overlap >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if an establishment attendance overlap
--   occurs at the same establishment for the same person. It is also used
--   to check that any qualification records that use the establishment
--   attendance id do not have a qualification start date that falls
--   outside of the attendance start dates.
--
-- Bug: 1664075 Starts here.
--
--   This procedure also checks if the start date of the school attended
--   entered is less than date of birth of the person if exists. Raises error
--   message if there is no date of birth provided or if start date is less
--   than the date of birth of the person.
--
-- Bug: 1664075 Ends here.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   attendance_id	                PK of record being inserted or updated.
--   establishment_id                   id of establishment
--   person_id                          id of person being inserted
--   attended_start_date                date attendance started.
--   attended_end_date                  date attendance finished.
--   establishment                      establishment location
--   object_version_number              Object version number of record being
--                                      inserted or updated.
--   party_id                           id of party -- HR/TCA merge
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_att_overlap(p_attendance_id               in number,
			  p_establishment_id            in number,
			  p_person_id                   in number,
			  p_attended_start_date         in date,
			  p_attended_end_date           in date,
			  p_object_version_number       in number,
  -- Bug: 1664075 Starts here.
                          p_effective_date              in date,
  -- Bug: 1664075 Ends here.
                          p_party_id                    in number -- HR/TCA merge
                         ) is
  --
  l_proc         varchar2(72) := g_package||'chk_att_overlap';
  l_api_updating boolean;
  l_dummy varchar2(1);
  l_dob date;
  --
  cursor c1 is
    select  null
    from    per_establishment_attendances per
    where   per.person_id = p_person_id
    and     per.establishment_id = p_establishment_id
    and     per.attendance_id <> nvl(p_attendance_id,-1)
    and     (nvl(p_attended_start_date,hr_api.g_sot)
            between per.attended_start_date
            and     nvl(per.attended_end_date,hr_api.g_eot)
	    or      nvl(p_attended_end_date,hr_api.g_eot)
	    between per.attended_start_date
	    and     nvl(per.attended_end_date,hr_api.g_eot));
  --
  cursor c2 is
    select null
    from   per_qualifications per
    where  per.attendance_id = p_attendance_id
    and    (per.start_date
            not    between nvl(p_attended_start_date,hr_api.g_sot)
		   and     nvl(p_attended_end_date,per.start_date)
	    or per.end_date
            not    between nvl(p_attended_start_date,hr_api.g_sot)
		   and     nvl(p_attended_end_date,per.end_date));
  -- HR/TCA merge
  -- For party_id
  cursor c3 is
    select  null
    from    per_establishment_attendances per
    where   per.party_id = p_party_id
    and     per.establishment_id = p_establishment_id
    and     per.attendance_id <> nvl(p_attendance_id,-1)
    and     (nvl(p_attended_start_date,hr_api.g_sot)
            between per.attended_start_date
            and     nvl(per.attended_end_date,hr_api.g_eot)
	    or nvl(p_attended_end_date,hr_api.g_eot)
	    between per.attended_start_date
	    and     nvl(per.attended_end_date,hr_api.g_eot));
  --
  -- Bug: 1664075 Starts here
  --
  cursor c4 is
    select  DATE_OF_BIRTH
    from    per_all_people_f per
    where   per.person_id = p_person_id
    and     p_effective_date
    between per.effective_start_date
    and     nvl(per.effective_end_date,hr_api.g_eot)
    and     date_of_birth is not null;
  --
  -- Bug: 1664075 Ends here.
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_esa_shd.api_updating
    (p_attendance_id               => p_attendance_id,
     p_object_version_number       => p_object_version_number);
  --
if l_api_updating then
    hr_utility.set_location('Entering:chk_start'||p_attended_start_date,121);
    hr_utility.set_location('Entering:chk_start'||per_esa_shd.g_old_rec.attended_start_date,121);
    hr_utility.set_location('Entering:chk_end'||p_attended_end_date,212);
    hr_utility.set_location('Entering:chk_start'||per_esa_shd.g_old_rec.attended_end_date,121);
end if;
  if (l_api_updating
      and (nvl(p_attended_start_date,hr_api.g_date)
	   <> nvl(per_esa_shd.g_old_rec.attended_start_date,hr_api.g_date)
	   or nvl(p_attended_end_date,hr_api.g_date)
	   <> nvl(per_esa_shd.g_old_rec.attended_end_date,hr_api.g_date))
      or not l_api_updating) then
    --
    -- check if attended start date is null
    --
    --
    -- Bug: 1664075 Starts here.
    --
    -- Check if the date of birth of the person is null or start date is less
    -- than the date of birth of the person.
    --
  hr_utility.set_location('Entering:'||l_proc, 15);
    open c4;
    fetch c4 into l_dob;
    if (c4%found) then
/*       if (l_dob is null) then
          close c4;
          hr_utility.set_message(800,'HR_289737_SCH_ATTND_NULL_DOB');
          hr_utility.raise_error;
       elsif (p_attended_start_date is not null) and (l_dob > nvl(p_attended_start_date,hr_api.g_sot) ) then
          close c4;
	  hr_utility.set_message(800,'HR_289384_SCH_ATND_START_DATE');
          hr_utility.raise_error;
       end if;
*/

--
--  Bug# 2968084 Start Here
--
--  Description : Added extra validation to check for start and end date. This is due to change that start date is not mandatory
--
--  Validate date of birth, start date and end date for the schools and colleges attended
--
--
      if (p_attended_start_date is not null) and (p_attended_end_date is null) and l_dob > nvl(p_attended_start_date,hr_api.g_sot) then
         close c4;
  	 hr_utility.set_message(800,'HR_289384_SCH_ATND_START_DATE');
         hr_utility.raise_error;
      elsif (p_attended_start_date is null) and (p_attended_end_date is not null) and (l_dob > nvl(p_attended_end_date,hr_api.g_sot)) then
         close c4;
  	 hr_utility.set_message(800,'PER_289498_ATT_END_DATE');
         hr_utility.raise_error;
      elsif (p_attended_start_date is not null) and (p_attended_end_date is not null) then
        if (l_dob > p_attended_start_date) and (l_dob > p_attended_end_date) and (p_attended_start_date > p_attended_end_date) then
          close c4;
          hr_utility.set_message(800,'PER_289497_ATT_ST_END_DATE');
          hr_utility.raise_error;
        elsif (l_dob > p_attended_start_date) and (l_dob > p_attended_end_date) then
          close c4;
          hr_utility.set_message(800,'PER_289497_ATT_ST_END_DATE');
          hr_utility.raise_error;
        elsif (l_dob > p_attended_start_date) and (p_attended_start_date > p_attended_end_date) then
          close c4;
        elsif (l_dob > p_attended_end_date) and (p_attended_start_date > p_attended_end_date) then
          close c4;
          hr_utility.set_message(800,'PER_289499_ATT_END_DOB_DATE');
          hr_utility.raise_error;
        elsif (l_dob > p_attended_start_date) then
          close c4;
   	  hr_utility.set_message(800,'HR_289384_SCH_ATND_START_DATE');
          hr_utility.raise_error;
        elsif (l_dob > p_attended_end_date) then
          close c4;
        elsif (p_attended_start_date > p_attended_end_date) then
          close c4;
          hr_utility.set_message(800,'HR_51496_ESA_ATT_END_DATE');
          hr_utility.raise_error;
        end if;

       end if;
    end if;
    close c4;

--  Bug# 2968084 Ends Here
    --
    -- Bug: 1664075 Ends here.
    --
    -- check if the attended start date is later than the attended end date
    --
  hr_utility.set_location('Entering:'||l_proc, 20);
    if nvl(p_attended_start_date,hr_api.g_sot) > nvl(p_attended_end_date,nvl(p_attended_start_date,hr_api.g_sot))
      then
      --
      -- raise error
      --
      hr_utility.set_message(800,'HR_51496_ESA_ATT_END_DATE'); -- Bug 3487909
      hr_utility.raise_error;
      --
    end if;
    --
    -- check if qualification dates are within the range of the attendance
    -- start dates that they reference
    -- Fix for WWBUG 2502284.
/*
    open c2;
      --
      fetch c2 into l_dummy;
      --
      if c2%found then
	--
	close c2;
	--
	-- raise error as qualification dates outside attendance dates
	--
	hr_utility.set_message(801,'HR_51596_ESA_QUAL_DATE_INV');
	hr_utility.raise_error;
	--
      end if;
      --
    close c2;
    --
*/
    -- check if a date overlap occurs for the same person at the same
    -- establishment.
    --
  /*  if p_person_id is not null then -- HR/TCA merge
      open c1;
        --
        fetch c1 into l_dummy;
        --
        if c1%found then
  	--
          close c1;
  	--
  	-- raise error as establishment attendance dates overlap
  	--
          hr_utility.set_message(801,'HR_51497_ESA_CHK_ATT_OVERLAP');
  	  hr_utility.raise_error;
  	  --
        end if;
        --
      close c1;
      --
    els */
  /*  if p_party_id is not null then
      open c3;
        --
        fetch c3 into l_dummy;
        --
        if c3%found then
  	--
          close c3;
  	--
  	-- raise error as establishment attendance dates overlap
  	--
          hr_utility.set_message(801,'HR_51497_ESA_CHK_ATT_OVERLAP');
  	  hr_utility.raise_error;
  	  --
        end if;
        --
      close c3;
      --
    end if;*/
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
end chk_att_overlap;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_estab_bg >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if an establishment attendance is in the
--   same business group as the person.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   attendance_id	                PK of record being inserted or updated.
--   business_group_id                  id of business group
--   person_id                          id of person being inserted
--   object_version_number              Object version number of record being
--                                      inserted or updated.
--   effective_date                     Effective date
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_estab_bg(p_attendance_id               in number,
		       p_business_group_id           in number,
		       p_person_id                   in number,
		       p_object_version_number       in number,
                       p_effective_date              in date) is
  --
  l_proc         varchar2(72) := g_package||'chk_estab_bg';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  -- Bug fix 3648650.
  -- cursor modified. nvl(person_id) is removed. This procedure
  -- is called only if person id is not null. This will improve
  -- performance.

  cursor c1 is
    select  null
    from    per_people_f per
    where   per.person_id = p_person_id
    and     per.business_group_id =nvl(p_business_group_id,per.business_group_id)
    and     trunc(p_effective_date)
    between trunc(per.effective_start_date)
    and     nvl(trunc(per.effective_end_date),trunc(per.effective_end_date));
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_esa_shd.api_updating
    (p_attendance_id               => p_attendance_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_person_id,hr_api.g_number) <> per_esa_shd.g_old_rec.person_id
      or not l_api_updating) then
    --
    -- check if the person exists in the per_people_f table for the same
    -- business group
    --
    open c1;
      --
      fetch c1 into l_dummy;
      --
      if c1%notfound then
	--
	close c1;
	--
	-- raise error as person does not exist for this business group
	--
	hr_utility.set_message(801,'HR_51503_ESA_ESTAB_BG');
	hr_utility.raise_error;
	--
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location(l_proc, 4);
  --
  --UPDATE of Business_group_id is not allowed unless currently null(U)
  --
  if  (l_api_updating
       and nvl(per_esa_shd.g_old_rec.business_group_id,hr_api.g_number)
           <> hr_api.g_number
       and per_esa_shd.g_old_rec.business_group_id <> p_business_group_id ) then
     --
      hr_utility.set_message(800, 'HR_289947_INV_UPD_BG_ID');
      hr_utility.raise_error;
     --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
end chk_estab_bg;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_estab_att_delete >---------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if an establishment attendance can be
--   deleted.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   attendance_id	                PK of record being inserted or updated.
--   object_version_number              Object version number of record being
--                                      inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_estab_att_delete(p_attendance_id               in number,
		               p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_estab_att_delete';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is
    select  null
    from    per_qualifications per
    where   per.attendance_id = p_attendance_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  open c1;
    --
    fetch c1 into l_dummy;
    --
    if c1%found then
      --
      close c1;
      --
      -- raise error as attendance_id is referenced.
      --
      hr_utility.set_message(801,'HR_51580_ESA_ESTAB_ATT_DEL');
      hr_utility.raise_error;
      --
    end if;
    --
  close c1;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_estab_att_delete;
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
  (p_rec in per_esa_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.attendance_id is not null) and (
    nvl(per_esa_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_esa_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_esa_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_esa_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_esa_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_esa_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_esa_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_esa_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_esa_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_esa_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_esa_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_esa_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_esa_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_esa_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_esa_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_esa_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_esa_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_esa_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_esa_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_esa_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_esa_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)))
    or
    (p_rec.attendance_id is null) then
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_ESTABLISHMENT_ATTENDANCES'
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
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec            in out nocopy per_esa_shd.g_rec_type,
			  p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- only party_id is specified, validate business_group_id
  -- for HR/TCA merge
  --
  if p_rec.person_id is not null then
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  -- Call all supporting business operations
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ATTENDANCE_ID
  --
  chk_attendance_id(p_rec.attendance_id,
		    p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PERSON_ID
  --
  chk_person_id(p_rec.attendance_id,
	        p_rec.person_id,
	        p_rec.attended_start_date,
	        p_rec.establishment_id,
	        p_rec.establishment,
	        p_rec.business_group_id,
	        p_rec.object_version_number,
                p_rec.party_id); -- HR/TCA merge
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PARTY_ID
  --
  chk_party_id
     (p_rec
     ,p_effective_date
     );

     --

  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ESTAB_LOCATION
  -- CHK_ESTABLISHMENT_ID
  --
  chk_estab_location(p_rec.attendance_id,
		     p_rec.establishment_id,
		     p_rec.establishment,
		     p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ATT_OVERLAP
  -- CHK_ATTENDED_START_DATE
  -- CHK_ATTENDED_END_DATE
  -- CHK_ATT_TO_DATE
  --
  chk_att_overlap (p_rec.attendance_id,
		   p_rec.establishment_id,
		   p_rec.person_id,
		   p_rec.attended_start_date,
		   p_rec.attended_end_date,
		   p_rec.object_version_number,
  -- Bug: 1664075 Starts here.
		   p_effective_date,
  -- Bug: 1664075 Ends here.
                   p_rec.party_id); -- HR/TCA merge
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ESTAB_BG
  --
  -- Validate bg ifperson_id isspecified.
  -- for HR/TCA merge
  if p_rec.person_id is not null then
  chk_estab_bg(p_rec.attendance_id,
	       p_rec.business_group_id,
	       p_rec.person_id,
	       p_rec.object_version_number,
               p_effective_date);
  end if;
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_FULL_TIME
  --
  chk_full_time(p_rec.attendance_id,
		p_rec.full_time,
		p_effective_date,
		p_rec.object_version_number);
  --
  -- Check Address parameter in the instance if record being passed establishment_id
  -- is linked to the attendance record
  chk_address_constraints(p_rec.address,
			  p_rec.establishment_id,
			  p_rec.object_version_number,
			  p_rec.attendance_id);
  --
  -- Descriptive flex check
  -- ======================
  --
  per_esa_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec            in per_esa_shd.g_rec_type,
			  p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- if person_id is specified, validate business_group_id
  -- for HR/TCA merge
  --
  if p_rec.person_id is not null then
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  -- Call all supporting business operations
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ATTENDANCE_ID
  --
  chk_attendance_id(p_rec.attendance_id,
                    p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PERSON_ID
  --
  chk_person_id(p_rec.attendance_id,
	        p_rec.person_id,
	        p_rec.attended_start_date,
	        p_rec.establishment_id,
	        p_rec.establishment,
	        p_rec.business_group_id,
	        p_rec.object_version_number,
                p_rec.party_id); -- HR/TCA merge
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ESTAB_LOCATION
  -- CHK_ESTABLISHMENT_ID
  --
  chk_estab_location(p_rec.attendance_id,
		     p_rec.establishment_id,
		     p_rec.establishment,
		     p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ATT_OVERLAP
  -- CHK_ATTENDED_START_DATE
  -- CHK_ATTENDED_END_DATE
  -- CHK_ATT_TO_DATE
  --
  chk_att_overlap (p_rec.attendance_id,
		   p_rec.establishment_id,
		   p_rec.person_id,
		   p_rec.attended_start_date,
		   p_rec.attended_end_date,
		   p_rec.object_version_number,
  -- Bug: 1664075 Starts here.
		   p_effective_date,
  -- Bug: 1664075 Ends here.
                   p_rec.party_id); -- HR/TCA merge
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ESTAB_BG
  --
  -- Validate bg only if person_id is specified.
  -- for HR/TCA merge
  if p_rec.person_id is not null then
  chk_estab_bg(p_rec.attendance_id,
	       p_rec.business_group_id,
	       p_rec.person_id,
	       p_rec.object_version_number,
               p_effective_date);
  end if;
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_FULL_TIME
  --
  chk_full_time(p_rec.attendance_id,
		p_rec.full_time,
		p_effective_date,
		p_rec.object_version_number);
  --
  -- Check Address parameter in the instance if record being passed establishment_id
  -- is linked to the attendance record
  --
  chk_address_constraints(p_rec.address,
                          p_rec.establishment_id,
                          p_rec.object_version_number,
                          p_rec.attendance_id);
  --
  -- Descriptive Flex Check
  -- ======================
  --
  per_esa_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_esa_shd.g_rec_type) is
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
  -- CHK_ESTAB_ATT_DELETE
  chk_estab_att_delete(p_rec.attendance_id,
		       p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_attendance_id    in per_establishment_attendances.attendance_id%TYPE
  ) return varchar2 is
  --
  -- Cursor to find legislation code
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups  pbg
         , per_establishment_attendances esa
     where esa.attendance_id = p_attendance_id
       and pbg.business_group_id = esa.business_group_id;
  --
  -- Cursor to find if the business group exists
  --
  cursor csr_no_bg is
    select 'Y'
      from per_establishment_attendances
     where attendance_id = p_attendance_id
       and business_group_id is null;
  --
  -- Declare local variables
  --
  l_no_business_group varchar2(1);
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'attendance_id',
                             p_argument_value => p_attendance_id);
  --
  open csr_no_bg;
  fetch csr_no_bg into l_no_business_group;
  if csr_no_bg%found then
    l_no_business_group := 'N';
  end if;
  close csr_no_bg;
  --
  if l_no_business_group = 'Y' then
    return null;
  end if;
  --
  if nvl(g_attendance_id, hr_api.g_number) = p_attendance_id then
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
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 30);
    --
    -- Set the global variables so the vlaues are
    -- available for the next call to this function
    --
    close csr_leg_code;
    g_attendance_id	:= p_attendance_id;
    g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location('Entering:'|| l_proc, 40);
  --
  return l_legislation_code;
end return_legislation_code;
--
end per_esa_bus;

/
