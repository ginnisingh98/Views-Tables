--------------------------------------------------------
--  DDL for Package Body PER_DPF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DPF_BUS" as
/* $Header: pedpfrhi.pkb 115.13 2002/12/05 10:20:52 pkakar ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_dpf_bus.';  -- Global package name
--
--
-- The following two global variables are only to be used by the
-- return_legislation_code function.
--
g_deployment_factor_id number default null;
g_legislation_code varchar2(150) default null;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_deployment_factor_id >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the deployment
--   factor table is created properly. It should be null on insert and
--   should not be able to be updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   deployment_factor_id               PK of record being inserted or updated.
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
Procedure chk_deployment_factor_id(p_deployment_factor_id  in number,
                                   p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_deployment_factor_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  l_api_updating := per_dpf_shd.api_updating
    (p_deployment_factor_id        => p_deployment_factor_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_deployment_factor_id,hr_api.g_number)
      <>  per_dpf_shd.g_old_rec.deployment_factor_id) then
    --
    -- raise error as PK has changed
    --
    per_dpf_shd.constraint_error('PER_DEPLOYMENT_FACTORS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_deployment_factor_id is not null then
      --
      -- raise error as PK is not null
      --
      per_esa_shd.constraint_error('PER_DEPLOYMENT_FACTORS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End chk_deployment_factor_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_person_id >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the person exists as of the effective
--   date.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   effective_date                     effective date
--   deployment_factor_id               PK of record being inserted or updated.
--   person_id                          ID of person we are checking
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
Procedure chk_person_id(p_effective_date        in date,
			p_deployment_factor_id  in number,
                        p_person_id             in number,
                        p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_person_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_people_f per
    where  per.person_id = p_person_id
    and    p_effective_date
           between per.effective_start_date
           and     nvl(per.effective_end_date,hr_api.g_eot);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  l_api_updating := per_dpf_shd.api_updating
    (p_deployment_factor_id        => p_deployment_factor_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_person_id,hr_api.g_number)
      <>  per_dpf_shd.g_old_rec.person_id) then
    --
    -- raise error as person_id  has changed
    --
    hr_utility.set_message(801,'HR_52022_DPF_CHK_PERSON_UPD');
    hr_utility.raise_error;
    --
  elsif not l_api_updating then
    --
    -- check if person_id exists
    --
    if p_person_id is not null then
      --
      open c1;
        --
        fetch c1 into l_dummy;
        if c1%notfound then
          --
          close c1;
          hr_utility.set_message(800,'HR_52250_DPF_CHK_PERSON_ID');
          hr_utility.raise_error;
          --
        end if;
        --
      close c1;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End chk_person_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_position_id >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the position exists as of effective
--   date.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   effective_date                     effective date
--   deployment_factor_id               PK of record being inserted or updated.
--   position_id                        ID of position we are checking
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
Procedure chk_position_id(p_deployment_factor_id  in number,
                          p_position_id           in number,
                          p_object_version_number in number,
			  p_effective_date	  in date) is
  --
  l_proc         varchar2(72) := g_package||'chk_position_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  -- Changed 12-Oct-99 SCNair (per_positions to hr_positions_f) Date tracked position req.
  --
  cursor c1 is
    select null
    from   hr_positions_f per
    where  per.position_id = p_position_id
    and    p_effective_date
    between effective_start_date
    and effective_end_date
    and    p_effective_date
           between per.date_effective
           and     nvl(per.date_end,hr_api.g_eot);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  l_api_updating := per_dpf_shd.api_updating
    (p_deployment_factor_id        => p_deployment_factor_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_position_id,hr_api.g_number)
      <>  per_dpf_shd.g_old_rec.position_id) then
    --
    -- raise error as position_id  has changed
    --
    hr_utility.set_message(801,'HR_52023_DPF_CHK_POSITION_UPD');
    hr_utility.raise_error;
    --
  elsif not l_api_updating then
    --
    -- check if position_id exists
    --
    if p_position_id is not null then
      --
      open c1;
        --
        fetch c1 into l_dummy;
        if c1%notfound then
          --
          close c1;
	  per_dpf_shd.constraint_error('PER_DEPLOYMENT_FACTORS_FK2');
          --
        end if;
        --
      close c1;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
end chk_position_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_job_id >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the job exists as of effective date.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   deployment_factor_id               PK of record being inserted or updated.
--   job_id                             ID of job we are checking
--   object_version_number              Object version number of record being
--                                      inserted or updated.
--   effective_date                     effective date
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
Procedure chk_job_id(p_deployment_factor_id  in number,
                     p_job_id                in number,
                     p_object_version_number in number,
		     p_effective_date 	     in date) is
  --
  l_proc         varchar2(72) := g_package||'chk_job_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_jobs_v per
    where  per.job_id = p_job_id
    and    p_effective_date
           between per.date_from
           and     nvl(per.date_to,hr_api.g_eot);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  l_api_updating := per_dpf_shd.api_updating
    (p_deployment_factor_id        => p_deployment_factor_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_job_id,hr_api.g_number)
      <>  per_dpf_shd.g_old_rec.job_id) then
    --
    -- raise error as job_id has changed
    --
    hr_utility.set_message(801,'HR_52025_DPF_CHK_JOB_UPD');
    hr_utility.raise_error;
    --
  elsif not l_api_updating then
    --
    -- check if position_id exists
    --
    if p_job_id is not null then
      --
      open c1;
        --
        fetch c1 into l_dummy;
        if c1%notfound then
          --
          close c1;
	  per_dpf_shd.constraint_error('PER_DEPLOYMENT_FACTORS_FK1');
          --
        end if;
        --
      close c1;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
end chk_job_id;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_mandatory_lookup >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check mandatory lookups exist within the lookup
--   type.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   deployment_factor_id               PK of record being inserted or updated.
--   work_any_country                   work_any_country lookup.
--   work_any_location                  work_any_location lookup.
--   relocate_domestically              relocate_domestically lookup.
--   relocate_internationally           relocate_internationally lookup.
--   travel_required                    travel_required lookup.
--   effective_date                     system date.
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
--   effective_date                     effective date
Procedure chk_mandatory_lookup(p_deployment_factor_id     in number,
                               p_work_any_country         in varchar2,
                               p_work_any_location        in varchar2,
                               p_relocate_domestically    in varchar2,
                               p_relocate_internationally in varchar2,
                               p_travel_required          in varchar2,
                               p_effective_date           in date,
                               p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mandatory_lookup';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  l_api_updating := per_dpf_shd.api_updating
    (p_deployment_factor_id        => p_deployment_factor_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and (nvl(p_work_any_country,hr_api.g_varchar2)
           <>  nvl(per_dpf_shd.g_old_rec.work_any_country,hr_api.g_varchar2)
           or nvl(p_work_any_location,hr_api.g_varchar2)
           <>  nvl(per_dpf_shd.g_old_rec.work_any_location,hr_api.g_varchar2)
           or nvl(p_relocate_domestically,hr_api.g_varchar2)
           <>  nvl(per_dpf_shd.g_old_rec.relocate_domestically,hr_api.g_varchar2)
           or nvl(p_relocate_internationally,hr_api.g_varchar2)
           <>  nvl(per_dpf_shd.g_old_rec.relocate_internationally,hr_api.g_varchar2)
           or nvl(p_travel_required,hr_api.g_varchar2)
           <>  nvl(per_dpf_shd.g_old_rec.travel_required,hr_api.g_varchar2))
      or not l_api_updating) then
    --
    -- check if any lookup that has changed still exists in its lookup type
    --
    -- Check if lookup exists in YES_NO lookup type.
    --
    -- Work any country lookup.
    --
    if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_work_any_country,
        p_effective_date => p_effective_date) then
      --
      per_dpf_shd.constraint_error('PER_DPF_WORK_ANY_COUNTRY');
      --
    end if;
    --
    -- Work any location lookup.
    --
    if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_work_any_location,
        p_effective_date => p_effective_date) then
      --
      per_dpf_shd.constraint_error('PER_DPF_WORK_ANY_LOCATION');
      --
    end if;
    --
    -- Relocate Domestically lookup.
    --
    if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_relocate_domestically,
        p_effective_date => p_effective_date) then
      --
      per_dpf_shd.constraint_error('PER_DPF_RELOCATE_DOMESTICALLY');
      --
    end if;
    --
    -- Relocate Internationally lookup.
    --
    if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_relocate_internationally,
        p_effective_date => p_effective_date) then
      --
      per_dpf_shd.constraint_error('PER_DPF_RELOCATE_INTERNATIONALLY');
      --
    end if;
    --
    -- Travel Required lookup.
    --
    if hr_api.not_exists_in_hr_lookups
       (p_lookup_type    => 'YES_NO',
        p_lookup_code    => p_travel_required,
        p_effective_date => p_effective_date) then
      --
      per_dpf_shd.constraint_error('PER_DPF_TRAVEL_REQUIRED');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
end chk_mandatory_lookup;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_country >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the country code exists in
--   FND_TERRITORIES.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   deployment_factor_id               PK of record being inserted or updated.
--   country1                           code of country we are checking.
--   country2                           code of country we are checking.
--   country3                           code of country we are checking.
--   no_country1                        code of country we are checking.
--   no_country1                        code of country we are checking.
--   no_country1                        code of country we are checking.
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
Procedure chk_country(p_deployment_factor_id  in number,
                      p_country1              in varchar2,
                      p_country2              in varchar2,
                      p_country3              in varchar2,
                      p_no_country1           in varchar2,
                      p_no_country2           in varchar2,
                      p_no_country3           in varchar2,
                      p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_country';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1(p_code varchar2) is
    select null
    from   fnd_territories per
    where  per.territory_code = p_code;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  l_api_updating := per_dpf_shd.api_updating
    (p_deployment_factor_id        => p_deployment_factor_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and (nvl(p_country1,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.country1
           or nvl(p_country2,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.country2
           or nvl(p_country3,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.country3
           or nvl(p_no_country1,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.no_country1
           or nvl(p_no_country2,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.no_country2
           or nvl(p_no_country3,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.no_country3)
      or not l_api_updating) then
    --
    -- Check if country code exists in FND_TERRITORIES.
    --
    if p_country1 is not null then
      --
      if nvl(p_country1,hr_api.g_varchar2) <>
        per_dpf_shd.g_old_rec.country1 or
        not l_api_updating then
        --
        -- check if country exists
        --
        open c1(p_country1);
          --
          fetch c1 into l_dummy;
          if c1%notfound then
            --
            close c1;
            hr_utility.set_message(801,'HR_52027_DPF_CHK_COUNTRY');
            hr_utility.raise_error;
            --
          end if;
          --
        close c1;
        --
      end if;
      --
    end if;
    --
    if p_country2 is not null then
      --
      if nvl(p_country2,hr_api.g_varchar2) <>
        per_dpf_shd.g_old_rec.country2 or
        not l_api_updating then
        --
        -- check if country exists
        --
        open c1(p_country2);
          --
          fetch c1 into l_dummy;
          if c1%notfound then
            --
            close c1;
            hr_utility.set_message(801,'HR_52027_DPF_CHK_COUNTRY');
            hr_utility.raise_error;
            --
          end if;
          --
        close c1;
        --
      end if;
      --
    end if;
    --
    if p_country3 is not null then
      --
      if nvl(p_country3,hr_api.g_varchar2) <>
        per_dpf_shd.g_old_rec.country3 or
        not l_api_updating then
        --
        -- check if country exists
        --
        open c1(p_country3);
          --
          fetch c1 into l_dummy;
          if c1%notfound then
            --
            close c1;
            hr_utility.set_message(801,'HR_52027_DPF_CHK_COUNTRY');
            hr_utility.raise_error;
            --
          end if;
          --
        close c1;
        --
      end if;
      --
    end if;
    --
    if p_no_country1 is not null then
      --
      if nvl(p_no_country1,hr_api.g_varchar2) <>
        per_dpf_shd.g_old_rec.no_country1 or
        not l_api_updating then
        --
        -- check if country exists
        --
        open c1(p_no_country1);
          --
          fetch c1 into l_dummy;
          if c1%notfound then
            --
            close c1;
            hr_utility.set_message(801,'HR_52027_DPF_CHK_COUNTRY');
            hr_utility.raise_error;
            --
          end if;
          --
        close c1;
        --
      end if;
      --
    end if;
    --
    if p_no_country2 is not null then
      --
      if nvl(p_no_country2,hr_api.g_varchar2) <>
        per_dpf_shd.g_old_rec.no_country2 or
        not l_api_updating then
        --
        -- check if country exists
        --
        open c1(p_no_country2);
          --
          fetch c1 into l_dummy;
          if c1%notfound then
            --
            close c1;
            hr_utility.set_message(801,'HR_52027_DPF_CHK_COUNTRY');
            hr_utility.raise_error;
            --
          end if;
          --
        close c1;
        --
      end if;
      --
    end if;
    --
    if p_no_country3 is not null then
      --
      if nvl(p_no_country3,hr_api.g_varchar2) <>
        per_dpf_shd.g_old_rec.no_country3 or
        not l_api_updating then
        --
        -- check if country exists
        --
        open c1(p_no_country3);
          --
          fetch c1 into l_dummy;
          if c1%notfound then
            --
            close c1;
            hr_utility.set_message(801,'HR_52027_DPF_CHK_COUNTRY');
            hr_utility.raise_error;
            --
          end if;
          --
        close c1;
        --
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
end chk_country;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_optional_lookup >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check optional lookups exist within the lookup
--   type.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   deployment_factor_id               PK of record being inserted or updated.
--   work_duration                      work duration lookup.
--   work_schedule                      work schedule lookup.
--   work_hours                         work hours lookup.
--   fte_capacity                       fte capacity lookup.
--   effective_date                     system date.
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
Procedure chk_optional_lookup(p_deployment_factor_id     in number,
                              p_work_duration            in varchar2,
                              p_work_schedule            in varchar2,
                              p_work_hours               in varchar2,
                              p_fte_capacity             in varchar2,
                              p_effective_date           in date,
                              p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_optional_lookup';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  l_api_updating := per_dpf_shd.api_updating
    (p_deployment_factor_id        => p_deployment_factor_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and (p_work_duration
           <>  nvl(per_dpf_shd.g_old_rec.work_duration,hr_api.g_varchar2)
           or p_work_schedule
           <>  nvl(per_dpf_shd.g_old_rec.work_schedule,hr_api.g_varchar2)
           or p_work_hours
           <>  nvl(per_dpf_shd.g_old_rec.work_hours,hr_api.g_varchar2)
           or p_fte_capacity
           <>  nvl(per_dpf_shd.g_old_rec.fte_capacity,hr_api.g_varchar2))
      or not l_api_updating) then
    --
    -- check if any lookup that has changed still exists in its lookup type
    --
    if p_work_duration is not null then
      --
      if p_work_duration <>
        nvl(per_dpf_shd.g_old_rec.work_duration,hr_api.g_varchar2) or
        not l_api_updating then
        --
        -- Check if lookup exists in PER_TIME_SCALES lookup type.
        --
        -- Work Duration lookup.
        --
        if hr_api.not_exists_in_hr_lookups
           (p_lookup_type    => 'PER_TIME_SCALES',
            p_lookup_code    => p_work_duration,
            p_effective_date => p_effective_date) then
          --
          hr_utility.set_message(801,'HR_52028_DPF_CHK_WORK_DURATION');
          hr_utility.raise_error;
          --
        end if;
        --
      end if;
      --
    end if;
    --
    if p_work_schedule is not null then
      --
      if p_work_schedule <>
        nvl(per_dpf_shd.g_old_rec.work_schedule,hr_api.g_varchar2) or
        not l_api_updating then
        --
        -- Check if lookup exists in PER_WORK_SCHEDULE lookup type.
        --
        -- Work Schedule lookup.
        --
        if hr_api.not_exists_in_hr_lookups
           (p_lookup_type    => 'PER_WORK_SCHEDULE',
            p_lookup_code    => p_work_schedule,
            p_effective_date => p_effective_date) then
          --
          hr_utility.set_message(801,'HR_52029_DPF_CHK_WORK_SCHEDULE');
          hr_utility.raise_error;
          --
        end if;
        --
      end if;
      --
    end if;
    --
    if p_work_hours is not null then
      --
      if p_work_hours <>
        nvl(per_dpf_shd.g_old_rec.work_hours,hr_api.g_varchar2) or
        not l_api_updating then
        --
        -- Check if lookup exists in PER_WORK_HOURS lookup type.
        --
        -- Work Hours lookup.
        --
        if hr_api.not_exists_in_hr_lookups
           (p_lookup_type    => 'PER_WORK_HOURS',
            p_lookup_code    => p_work_hours,
            p_effective_date => p_effective_date) then
          --
          hr_utility.set_message(801,'HR_52030_DPF_CHK_WORK_HOURS');
          hr_utility.raise_error;
          --
        end if;
        --
      end if;
      --
    end if;
    --
    if p_fte_capacity is not null then
      --
      if p_fte_capacity <>
        nvl(per_dpf_shd.g_old_rec.fte_capacity,hr_api.g_varchar2) or
        not l_api_updating then
        --
        -- Check if lookup exists in PER_FTE_CAPACITY lookup type.
        --
        -- FTE Capacity lookup.
        --
        if hr_api.not_exists_in_hr_lookups
           (p_lookup_type    => 'PER_FTE_CAPACITY',
            p_lookup_code    => p_fte_capacity,
            p_effective_date => p_effective_date) then
          --
          hr_utility.set_message(801,'HR_52031_DPF_CHK_FTE_CAPACITY');
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
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
end chk_optional_lookup;
-- ----------------------------------------------------------------------------
-- |---------------------< chk_person_optional_lookup >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the person related optional lookups
--   exist within the lookup type.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   deployment_factor_id               PK of record being inserted or updated.
--   visit_internationally              visit internationally lookup.
--   only_current_location              only current location lookup.
--   available_for_transfer             available for transfer lookup.
--   relocation_preference              relocation preference lookup.
--   effective_date                     system date.
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
Procedure chk_person_optional_lookup
       (p_deployment_factor_id     in number,
        p_visit_internationally    in varchar2,
        p_only_current_location    in varchar2,
        p_available_for_transfer   in varchar2,
        p_relocation_preference    in varchar2,
        p_effective_date           in date,
        p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_person_optional_lookup';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  l_api_updating := per_dpf_shd.api_updating
    (p_deployment_factor_id        => p_deployment_factor_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and (nvl(p_visit_internationally,hr_api.g_varchar2)
           <>  nvl(per_dpf_shd.g_old_rec.visit_internationally,hr_api.g_varchar2)
           or nvl(p_only_current_location,hr_api.g_varchar2)
           <>  nvl(per_dpf_shd.g_old_rec.only_current_location,hr_api.g_varchar2)
           or nvl(p_available_for_transfer,hr_api.g_varchar2)
           <>  nvl(per_dpf_shd.g_old_rec.available_for_transfer,hr_api.g_varchar2)
           or nvl(p_relocation_preference,hr_api.g_varchar2)
           <>  nvl(per_dpf_shd.g_old_rec.relocation_preference,hr_api.g_varchar2))
      or not l_api_updating) then
    --
    -- check if any lookup that has changed still exists in its lookup type
    --
    if p_visit_internationally is not null then
      --
      if nvl(p_visit_internationally,hr_api.g_varchar2) <>
        nvl(per_dpf_shd.g_old_rec.visit_internationally,hr_api.g_varchar2) or
        not l_api_updating then
        --
        -- Check if lookup exists in YES_NO lookup type.
        --
        -- Visit Internationally lookup.
        --
        if hr_api.not_exists_in_hr_lookups
           (p_lookup_type    => 'YES_NO',
            p_lookup_code    => p_visit_internationally,
            p_effective_date => p_effective_date) then
          --
          per_dpf_shd.constraint_error('PER_DPF_VISIT_INTERNATIONALLY');
          --
        end if;
        --
      end if;
      --
    end if;
    --
    if p_only_current_location is not null then
      --
      if nvl(p_only_current_location,hr_api.g_varchar2) <>
        nvl(per_dpf_shd.g_old_rec.only_current_location,hr_api.g_varchar2) or
        not l_api_updating then
        --
        -- Check if lookup exists in YES_NO lookup type.
        --
        -- Only Current Location lookup.
        --
        if hr_api.not_exists_in_hr_lookups
           (p_lookup_type    => 'YES_NO',
            p_lookup_code    => p_only_current_location,
            p_effective_date => p_effective_date) then
          --
          per_dpf_shd.constraint_error('PER_DPF_ONLY_CURRENT_LOCATION');
          --
        end if;
        --
      end if;
      --
    end if;
    --
    if p_available_for_transfer is not null then
      --
      if nvl(p_available_for_transfer,hr_api.g_varchar2) <>
        nvl(per_dpf_shd.g_old_rec.available_for_transfer,hr_api.g_varchar2) or
        not l_api_updating then
        --
        -- Check if lookup exists in YES_NO lookup type.
        --
        -- Available for transfer lookup.
        --
        if hr_api.not_exists_in_hr_lookups
           (p_lookup_type    => 'YES_NO',
            p_lookup_code    => p_available_for_transfer,
            p_effective_date => p_effective_date) then
          --
          per_dpf_shd.constraint_error('PER_DPF_AVAILABLE_FOR_TRANSFER');
          --
        end if;
        --
      end if;
      --
    end if;
    --
    if p_relocation_preference is not null then
      --
      if nvl(p_relocation_preference,hr_api.g_varchar2) <>
        nvl(per_dpf_shd.g_old_rec.relocation_preference,hr_api.g_varchar2) or
        not l_api_updating then
        --
        -- Check if lookup exists in PER_RELOCATION_PREFERENCES lookup type.
        --
        -- Relocation Preference lookup.
        --
        if hr_api.not_exists_in_hr_lookups
           (p_lookup_type    => 'PER_RELOCATION_PREFERENCES',
            p_lookup_code    => p_relocation_preference,
            p_effective_date => p_effective_date) then
          --
          hr_utility.set_message(801,'HR_52032_DPF_CHK_RELOC_PREF');
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
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
end chk_person_optional_lookup;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_job_pos_optional_lookup >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Job/Position related optional
--   lookups exist within the lookup type.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   deployment_factor_id               PK of record being inserted or updated.
--   relocation_required                relocation required lookup.
--   passport_required                  passport required lookup.
--   service_minimum                    service minimum lookup.
--   effective_date                     system date.
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
Procedure chk_job_pos_optional_lookup
       (p_deployment_factor_id     in number,
        p_relocation_required      in varchar2,
        p_passport_required        in varchar2,
        p_service_minimum          in varchar2,
        p_effective_date           in date,
        p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_job_pos_optional_lookup';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  l_api_updating := per_dpf_shd.api_updating
    (p_deployment_factor_id        => p_deployment_factor_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and (nvl(p_relocation_required,hr_api.g_varchar2)
           <>  nvl(per_dpf_shd.g_old_rec.relocation_required,hr_api.g_varchar2)
           or nvl(p_passport_required,hr_api.g_varchar2)
           <>  nvl(per_dpf_shd.g_old_rec.passport_required,hr_api.g_varchar2)
           or nvl(p_service_minimum,hr_api.g_varchar2)
           <>  nvl(per_dpf_shd.g_old_rec.service_minimum,hr_api.g_varchar2))
      or not l_api_updating) then
    --
    -- check if any lookup that has changed still exists in its lookup type
    --
    if p_relocation_required is not null then
      --
      if nvl(p_relocation_required,hr_api.g_varchar2) <>
        nvl(per_dpf_shd.g_old_rec.relocation_required,hr_api.g_varchar2) or
        not l_api_updating then
        --
        -- Check if lookup exists in YES_NO lookup type.
        --
        -- Relocation Required lookup.
        --
        if hr_api.not_exists_in_hr_lookups
           (p_lookup_type    => 'YES_NO',
            p_lookup_code    => p_relocation_required,
            p_effective_date => p_effective_date) then
          --
          per_dpf_shd.constraint_error('PER_DPF_RELOCATION_REQUIRED');
          --
        end if;
        --
      end if;
      --
    end if;
    --
    if p_passport_required is not null then
      --
      if nvl(p_passport_required,hr_api.g_varchar2) <>
        nvl(per_dpf_shd.g_old_rec.passport_required,hr_api.g_varchar2) or
        not l_api_updating then
        --
        -- Check if lookup exists in YES_NO lookup type.
        --
        -- Passport Required lookup.
        --
        if hr_api.not_exists_in_hr_lookups
           (p_lookup_type    => 'YES_NO',
            p_lookup_code    => p_passport_required,
            p_effective_date => p_effective_date) then
          --
          per_dpf_shd.constraint_error('PER_DPF_PASSPORT_REQUIRED');
          --
        end if;
        --
      end if;
      --
    end if;
    --
    if p_service_minimum is not null then
      --
      if nvl(p_service_minimum,hr_api.g_varchar2) <>
        nvl(per_dpf_shd.g_old_rec.service_minimum,hr_api.g_varchar2) or
        not l_api_updating then
        --
        -- Check if lookup exists in PER_LENGTHS_OF_SERVICE lookup type.
        --
        -- Service Minimum lookup.
        --
        if hr_api.not_exists_in_hr_lookups
           (p_lookup_type    => 'PER_LENGTHS_OF_SERVICE',
            p_lookup_code    => p_service_minimum,
            p_effective_date => p_effective_date) then
          --
	  hr_utility.set_message(801,'HR_52033_DPF_LENGTH_SERVICE');
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
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
end chk_job_pos_optional_lookup;
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_location >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the locations exist in the
--   HR_LOCATIONS table.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   deployment_factor_id               PK of record being inserted or updated.
--   location1                          location1 lookup.
--   location2                          location2 lookup.
--   location3                          location3 lookup.
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
Procedure chk_location
       (p_deployment_factor_id     in number,
        p_location1                in varchar2,
        p_location2                in varchar2,
        p_location3                in varchar2,
        p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_location';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1(p_location_id varchar2) is
    select null
    from   hr_locations hr
    where  hr.location_id = p_location_id and hr.location_use = 'HR';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  l_api_updating := per_dpf_shd.api_updating
    (p_deployment_factor_id        => p_deployment_factor_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and (nvl(p_location1,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.location1
           or nvl(p_location2,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.location2
           or nvl(p_location3,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.location3)
      or not l_api_updating) then
    --
    -- check if any location that has changed exists in HR_LOCATIONS table.
    --
    if p_location1 is not null then
      --
      if nvl(p_location1,hr_api.g_varchar2) <>
        per_dpf_shd.g_old_rec.location1 or
        not l_api_updating then
        --
	open c1(p_location1);
	  --
	  fetch c1 into l_dummy;
	  if c1%notfound then
	    --
	    close c1;
	    hr_utility.set_message(801,'HR_52034_DPF_LOCATION_EXIST');
	    hr_utility.raise_error;
	    --
          end if;
	  --
        close c1;
	--
      end if;
      --
    end if;
    --
    if p_location2 is not null then
      --
      if nvl(p_location2,hr_api.g_varchar2) <>
        per_dpf_shd.g_old_rec.location2 or
        not l_api_updating then
        --
	open c1(p_location2);
	  --
	  fetch c1 into l_dummy;
	  if c1%notfound then
	    --
	    close c1;
	    hr_utility.set_message(801,'HR_52034_DPF_LOCATION_EXIST');
	    hr_utility.raise_error;
	    --
          end if;
	  --
        close c1;
	--
      end if;
      --
    end if;
    --
    if p_location3 is not null then
      --
      if nvl(p_location3,hr_api.g_varchar2) <>
        per_dpf_shd.g_old_rec.location3 or
        not l_api_updating then
        --
	open c1(p_location3);
	  --
	  fetch c1 into l_dummy;
	  if c1%notfound then
	    --
	    close c1;
	    hr_utility.set_message(801,'HR_52034_DPF_LOCATION_EXIST');
	    hr_utility.raise_error;
	    --
          end if;
	  --
        close c1;
	--
      end if;
      --
    end if;
    --
  end if;
  --
end chk_location;
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_id_populated >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the person , job or position id has
--   been populated. A deployment factor must be related to a person, job or
--   position but to only one of these.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   deployment_factor_id               PK of record being inserted or updated.
--   person_id                          person_id.
--   position_id                        position_id.
--   job_id                             job_id.
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
Procedure chk_id_populated
       (p_deployment_factor_id     in number,
        p_person_id                in number,
        p_position_id              in number,
        p_job_id                   in number,
        p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_id_populated';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  l_api_updating := per_dpf_shd.api_updating
    (p_deployment_factor_id        => p_deployment_factor_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and (nvl(p_person_id,hr_api.g_number)
           <>  per_dpf_shd.g_old_rec.person_id
           or nvl(p_position_id,hr_api.g_number)
           <>  per_dpf_shd.g_old_rec.position_id
           or nvl(p_job_id,hr_api.g_number)
           <>  per_dpf_shd.g_old_rec.job_id)
      or not l_api_updating) then
    --
    -- Check if only one of the Job, Position, Person Id's is populated
    --
    if ((p_job_id is null and
	 p_person_id is null and
	 p_position_id is null)
	 or
        (p_job_id is not null and
	 (p_person_id is not null or
	  p_position_id is not null))
         or
        (p_position_id is not null and
	 (p_job_id is not null or
	  p_person_id is not null))
         or
        (p_person_id is not null and
	 (p_job_id is not null or
	  p_position_id is not null))) then
      --
      -- Raise error as either no Id is populated or more than one Id is
      -- populated.
      --
      hr_utility.set_message(801,'HR_52035_DPF_CHK_ID_POPULATED');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
end chk_id_populated;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_person_attributes >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the job/position related attributes
--   ae not populated if the deployment factor is for a person.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   deployment_factor_id               PK of record being inserted or updated.
--   person_id                          person_id.
--   relocation_required                relocation required.
--   passport_required                  passport required.
--   location1                          location1.
--   location2                          location2.
--   location3                          location3.
--   other_requirements                 other requirements.
--   service_minimum                    service minimum.
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
Procedure chk_person_attributes
       (p_deployment_factor_id     in number,
        p_person_id                in number,
	p_relocation_required      in varchar2,
	p_passport_required        in varchar2,
	p_location1                in varchar2,
	p_location2                in varchar2,
	p_location3                in varchar2,
	p_other_requirements       in varchar2,
	p_service_minimum          in varchar2,
        p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_person_attributes';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  l_api_updating := per_dpf_shd.api_updating
    (p_deployment_factor_id        => p_deployment_factor_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and (nvl(p_relocation_required,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.relocation_required
           or nvl(p_passport_required,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.passport_required
           or nvl(p_location1,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.location1
           or nvl(p_location2,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.location2
           or nvl(p_location3,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.location3
           or nvl(p_other_requirements,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.other_requirements
           or nvl(p_service_minimum,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.service_minimum)
      or not l_api_updating) then
    --
    -- Check if any of the following attributes are set to not null values
    -- RELOCATION_REQUIRED, PASSPORT_REQUIRED, LOCATION1, LOCATION2,
    -- LOCATION3, OTHER_REQUIREMENTS, SERVICE_MINIMUM.
    --
    if p_person_id is not null then
      --
      if (p_relocation_required is not null or
	  p_passport_required is not null or
	  p_location1 is not null or
	  p_location2 is not null or
	  p_location3 is not null or
	  p_other_requirements is not null or
	  p_service_minimum is not null) then
        --
        hr_utility.set_message(801,'HR_52036_DPF_PERSON_ATTRIBUTES');
        hr_utility.raise_error;
	--
      end if;
      --
    end if;
    --
  end if;
  --
end chk_person_attributes;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_job_pos_attributes >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the person related attributes
--   are not populated if the deployment factor is for a person.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   deployment_factor_id               PK of record being inserted or updated.
--   job_id                             person_id.
--   position_id                        position_id.
--   visit_internationally              visit interantionally lookup.
--   only_current_location              only current location lookup.
--   no_country1                        no country1 value.
--   no_country2                        no country2 value.
--   no_country3                        no country3 value.
--   comments                           comments value.
--   earliest_available_date            earliest available date.
--   available_for_transfer             available for transfer.
--   relocation_preference              relocation preference.
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
Procedure chk_job_pos_attributes
       (p_deployment_factor_id     in number,
        p_job_id                   in number,
        p_position_id              in number,
	p_visit_internationally    in varchar2,
	p_only_current_location    in varchar2,
	p_no_country1              in varchar2,
	p_no_country2              in varchar2,
	p_no_country3              in varchar2,
	p_comments                 in varchar2,
	p_earliest_available_date  in date,
	p_available_for_transfer   in varchar2,
	p_relocation_preference    in varchar2,
        p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_job_pos_attributes';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  l_api_updating := per_dpf_shd.api_updating
    (p_deployment_factor_id        => p_deployment_factor_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and (nvl(p_visit_internationally,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.visit_internationally
           or nvl(p_only_current_location,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.only_current_location
           or nvl(p_no_country1,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.no_country1
           or nvl(p_no_country2,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.no_country2
           or nvl(p_no_country3,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.no_country3
           or nvl(p_comments,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.comments
           or nvl(p_earliest_available_date,hr_api.g_date)
           <>  per_dpf_shd.g_old_rec.earliest_available_date
           or nvl(p_available_for_transfer,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.available_for_transfer
           or nvl(p_relocation_preference,hr_api.g_varchar2)
           <>  per_dpf_shd.g_old_rec.relocation_preference)
      or not l_api_updating) then
    --
    -- Check if any of the following attributes are set to not null values
    -- VISIT_INTERNATIONALLY, ONLY_CURRENT_LOCATION, NO_COUNTRY1, NO_COUNTRY2,
    -- NO_COUNTRY3, COMMENTS, EARLIEST_AVAILABLE_DATE, AVAILABLE_FOR_TRANSFER,
    -- RELOCATION_PREFERENCE.
    --
    if (p_job_id is not null or
	p_position_id is not null) then
      --
      if (p_visit_internationally is not null or
	  p_only_current_location is not null or
	  p_no_country1 is not null or
	  p_no_country2 is not null or
	  p_no_country3 is not null or
	  p_comments is not null or
	  p_earliest_available_date is not null or
	  p_available_for_transfer is not null or
	  p_relocation_preference is not null) then
        --
        hr_utility.set_message(801,'HR_52037_DPF_JOBPOS_ATTRIBUTES');
        hr_utility.raise_error;
	--
      end if;
      --
    end if;
    --
  end if;
  --
end chk_job_pos_attributes;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_unique_key >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the person_id, job_id ,position_id
--   do not conflict with already created records in the database.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   deployment_factor_id               PK of record being inserted or updated.
--   job_id                             person_id.
--   position_id                        position_id.
--   person_id                          person_id.
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
Procedure chk_unique_key
       (p_deployment_factor_id     in number,
        p_job_id                   in number,
        p_position_id              in number,
        p_person_id                in number,
        p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_unique_key';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_deployment_factors per
    where  per.deployment_factor_id <> nvl(p_deployment_factor_id,-1)
    and    nvl(per.job_id,-1) = nvl(p_job_id,-1)
    and    nvl(per.position_id,-1) = nvl(p_position_id,-1)
    and    nvl(per.person_id,-1) = nvl(p_person_id,-1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_dpf_shd.api_updating
    (p_deployment_factor_id        => p_deployment_factor_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and (nvl(p_person_id,hr_api.g_number)
           <>  per_dpf_shd.g_old_rec.person_id
           or nvl(p_position_id,hr_api.g_number)
           <>  per_dpf_shd.g_old_rec.position_id
           or nvl(p_job_id,hr_api.g_number)
           <>  per_dpf_shd.g_old_rec.job_id)
      or not l_api_updating) then
    --
    -- Check if the record being inserted conflicts with a previously created
    -- one.
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%found then
	--
	close c1;
        per_dpf_shd.constraint_error('PER_DEPLOYMENT_FACTORS_UK');
	--
      end if;
      --
    close c1;
    --
  end if;
  --
end chk_unique_key;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_populated_bg >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the person_id, job_id ,position_id
--   business groups are the same as the business group for the deployment
--   factor.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   deployment_factor_id               PK of record being inserted or updated.
--   business_group_id                  business_group_id.
--   job_id                             person_id.
--   position_id                        position_id.
--   person_id                          person_id.
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
Procedure chk_populated_bg
       (p_deployment_factor_id     in number,
        p_business_group_id        in number,
        p_job_id                   in number,
        p_position_id              in number,
        p_person_id                in number,
        p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_populated_bg';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c_jobs is
    select null
    from   per_jobs_v per
    where  per.business_group_id = p_business_group_id
    and    per.job_id = p_job_id;
  --
  --
  -- Changed 12-Oct-99 SCNair (per_positions to hr_positions_f) Date tracked position req.
  --
  cursor c_positions is
    select null
    from   hr_positions_f per
    where  per.business_group_id = p_business_group_id
    and    per.position_id = p_position_id;
  --
  cursor c_person is
    select null
    from   per_people_f per
    where  per.business_group_id = p_business_group_id
    and    per.person_id = p_person_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_dpf_shd.api_updating
    (p_deployment_factor_id        => p_deployment_factor_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and (nvl(p_person_id,hr_api.g_number)
           <>  per_dpf_shd.g_old_rec.person_id
           or nvl(p_position_id,hr_api.g_number)
           <>  per_dpf_shd.g_old_rec.position_id
           or nvl(p_job_id,hr_api.g_number)
           <>  per_dpf_shd.g_old_rec.job_id)
      or not l_api_updating) then
    --
    -- Check if the record being inserted conflicts with a previously created
    -- one.
    --
    if p_person_id is not null then
      --
      open c_person;
	--
	fetch c_person into l_dummy;
	if c_person%notfound then
	  --
	  close c_person;
	  hr_utility.set_message(801,'HR_52042_DPF_PERSON_BG');
	  hr_utility.raise_error;
	  --
        end if;
	--
      close c_person;
      --
    end if;
    --
    if p_job_id is not null then
      --
      open c_jobs;
	--
	fetch c_jobs into l_dummy;
	if c_jobs%notfound then
	  --
	  close c_jobs;
	  hr_utility.set_message(801,'HR_52039_DPF_JOB_BG');
	  hr_utility.raise_error;
	  --
        end if;
	--
      close c_jobs;
      --
    end if;
    --
    if p_position_id is not null then
      --
      open c_positions;
	--
	fetch c_positions into l_dummy;
	if c_positions%notfound then
	  --
	  close c_positions;
	  hr_utility.set_message(801,'HR_52040_DPF_POSITION_BG');
	  hr_utility.raise_error;
	  --
        end if;
	--
      close c_positions;
      --
    end if;
    --
  end if;
  --
end chk_populated_bg;
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
  (p_rec in per_dpf_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.deployment_factor_id is not null) and (
    nvl(per_dpf_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_dpf_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_dpf_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_dpf_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_dpf_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_dpf_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_dpf_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_dpf_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_dpf_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_dpf_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_dpf_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_dpf_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_dpf_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_dpf_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_dpf_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_dpf_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_dpf_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_dpf_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_dpf_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_dpf_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_dpf_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)))
    or
    (p_rec.deployment_factor_id is null) then
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_DEPLOYMENT_FACTORS'
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
Procedure insert_validate(p_rec in per_dpf_shd.g_rec_type,
			  p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  -- Call all supporting business operations
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_DEPLOYMENT_FACTOR_ID
  --
  chk_deployment_factor_id(p_rec.deployment_factor_id,
			   p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PERSON_ID
  --
  chk_person_id(p_effective_date,
		p_rec.deployment_factor_id,
                p_rec.person_id,
	        p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_POSITION_ID
  --
  chk_position_id(p_rec.deployment_factor_id,
                  p_rec.position_id,
	          p_rec.object_version_number,
		  p_effective_date);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_JOB_ID
  --
  chk_job_id(p_rec.deployment_factor_id,
             p_rec.job_id,
	     p_rec.object_version_number,
	     p_effective_date);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_MANDATORY_LOOKUP
  --
  chk_mandatory_lookup(p_rec.deployment_factor_id,
                       p_rec.work_any_country,
                       p_rec.work_any_location,
                       p_rec.relocate_domestically,
                       p_rec.relocate_internationally,
                       p_rec.travel_required,
                       p_effective_date,
	               p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_COUNTRY
  --
  chk_country(p_rec.deployment_factor_id,
              p_rec.country1,
              p_rec.country2,
              p_rec.country3,
              p_rec.no_country1,
              p_rec.no_country2,
              p_rec.no_country3,
	      p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_OPTIONAL_LOOKUP
  --
  chk_optional_lookup(p_rec.deployment_factor_id,
                      p_rec.work_duration,
                      p_rec.work_schedule,
                      p_rec.work_hours,
                      p_rec.fte_capacity,
                      p_effective_date,
	              p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PERSON_OPTIONAL_LOOKUP
  --
  chk_person_optional_lookup(p_rec.deployment_factor_id,
                             p_rec.visit_internationally,
                             p_rec.only_current_location,
                             p_rec.available_for_transfer,
                             p_rec.relocation_preference,
                             p_effective_date,
	                     p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_JOB_POS_OPTIONAL_LOOKUP
  --
  chk_job_pos_optional_lookup(p_rec.deployment_factor_id,
                              p_rec.relocation_required,
                              p_rec.passport_required,
                              p_rec.service_minimum,
                              p_effective_date,
	                      p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_LOCATION
  --
  chk_location(p_rec.deployment_factor_id,
               p_rec.location1,
               p_rec.location2,
               p_rec.location3,
	       p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ID_POPULATED
  --
  chk_id_populated(p_rec.deployment_factor_id,
                   p_rec.person_id,
                   p_rec.position_id,
                   p_rec.job_id,
	           p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PERSON_ATTRIBUTES
  --
  chk_person_attributes(p_rec.deployment_factor_id,
                        p_rec.person_id,
                        p_rec.relocation_required,
                        p_rec.passport_required,
                        p_rec.location1,
                        p_rec.location2,
                        p_rec.location3,
                        p_rec.other_requirements,
                        p_rec.service_minimum,
	                p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_JOB_POS_ATTRIBUTES
  --
  chk_job_pos_attributes(p_rec.deployment_factor_id,
                         p_rec.job_id,
                         p_rec.position_id,
                         p_rec.visit_internationally,
                         p_rec.only_current_location,
                         p_rec.no_country1,
                         p_rec.no_country2,
                         p_rec.no_country3,
                         p_rec.comments,
                         p_rec.earliest_available_date,
                         p_rec.available_for_transfer,
                         p_rec.relocation_preference,
	                 p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_UNIQUE_KEY
  --
  chk_unique_key(p_rec.deployment_factor_id,
                 p_rec.job_id,
                 p_rec.position_id,
                 p_rec.person_id,
	         p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_POPULATED_BG
  --
  chk_populated_bg(p_rec.deployment_factor_id,
		   p_rec.business_group_id,
                   p_rec.job_id,
                   p_rec.position_id,
                   p_rec.person_id,
	           p_rec.object_version_number);
  --
  -- Descriptive flex check
  -- ======================
  --
  --
  per_dpf_bus.chk_df(p_rec => p_rec);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_dpf_shd.g_rec_type,
			  p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  -- Call all supporting business operations
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_DEPLOYMENT_FACTOR_ID
  --
  chk_deployment_factor_id(p_rec.deployment_factor_id,
			   p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PERSON_ID
  --
  chk_person_id(p_effective_date,
	        p_rec.deployment_factor_id,
                p_rec.person_id,
	        p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_POSITION_ID
  --
  chk_position_id(p_rec.deployment_factor_id,
                  p_rec.position_id,
	          p_rec.object_version_number,
		  p_effective_date);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_JOB_ID
  --
  chk_job_id(p_rec.deployment_factor_id,
             p_rec.job_id,
	     p_rec.object_version_number,
	     p_effective_date);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_MANDATORY_LOOKUP
  --
  chk_mandatory_lookup(p_rec.deployment_factor_id,
                       p_rec.work_any_country,
                       p_rec.work_any_location,
                       p_rec.relocate_domestically,
                       p_rec.relocate_internationally,
                       p_rec.travel_required,
                       p_effective_date,
	               p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_COUNTRY
  --
  chk_country(p_rec.deployment_factor_id,
              p_rec.country1,
              p_rec.country2,
              p_rec.country3,
              p_rec.no_country1,
              p_rec.no_country2,
              p_rec.no_country3,
	      p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_OPTIONAL_LOOKUP
  --
  chk_optional_lookup(p_rec.deployment_factor_id,
                      p_rec.work_duration,
                      p_rec.work_schedule,
                      p_rec.work_hours,
                      p_rec.fte_capacity,
                      p_effective_date,
	              p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PERSON_OPTIONAL_LOOKUP
  --
  chk_person_optional_lookup(p_rec.deployment_factor_id,
                             p_rec.visit_internationally,
                             p_rec.only_current_location,
                             p_rec.available_for_transfer,
                             p_rec.relocation_preference,
                             p_effective_date,
	                     p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_JOB_POS_OPTIONAL_LOOKUP
  --
  chk_job_pos_optional_lookup(p_rec.deployment_factor_id,
                              p_rec.relocation_required,
                              p_rec.passport_required,
                              p_rec.service_minimum,
                              p_effective_date,
	                      p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_LOCATION
  --
  chk_location(p_rec.deployment_factor_id,
               p_rec.location1,
               p_rec.location2,
               p_rec.location3,
	       p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ID_POPULATED
  --
  chk_id_populated(p_rec.deployment_factor_id,
                   p_rec.person_id,
                   p_rec.position_id,
                   p_rec.job_id,
	           p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PERSON_ATTRIBUTES
  --
  chk_person_attributes(p_rec.deployment_factor_id,
                        p_rec.person_id,
                        p_rec.relocation_required,
                        p_rec.passport_required,
                        p_rec.location1,
                        p_rec.location2,
                        p_rec.location3,
                        p_rec.other_requirements,
                        p_rec.service_minimum,
	                p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_JOB_POS_ATTRIBUTES
  --
  chk_job_pos_attributes(p_rec.deployment_factor_id,
                         p_rec.job_id,
                         p_rec.position_id,
                         p_rec.visit_internationally,
                         p_rec.only_current_location,
                         p_rec.no_country1,
                         p_rec.no_country2,
                         p_rec.no_country3,
                         p_rec.comments,
                         p_rec.earliest_available_date,
                         p_rec.available_for_transfer,
                         p_rec.relocation_preference,
	                 p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_UNIQUE_KEY
  --
  chk_unique_key(p_rec.deployment_factor_id,
                 p_rec.job_id,
                 p_rec.position_id,
                 p_rec.person_id,
	         p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_POPULATED_BG
  --
  chk_populated_bg(p_rec.deployment_factor_id,
		   p_rec.business_group_id,
                   p_rec.job_id,
                   p_rec.position_id,
                   p_rec.person_id,
	           p_rec.object_version_number);
  --
  -- Descriptive flex check
  -- ======================
   --
  per_dpf_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_dpf_shd.g_rec_type) is
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
  (p_deployment_factor_id    in per_deployment_factors.deployment_factor_id%TYPE
  ) return varchar2 is
  --
  --  to find legislation code
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups  pbg
         , per_deployment_factors pdf
     where pdf.deployment_factor_id = p_deployment_factor_id
       and pbg.business_group_id = pdf.business_group_id;
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
                             p_argument       => 'deployment_factor_id',
                             p_argument_value => p_deployment_factor_id);
 --
  if nvl(g_deployment_factor_id, hr_api.g_number) = p_deployment_factor_id then
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
    g_deployment_factor_id	:= p_deployment_factor_id;
    g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location('Entering:'|| l_proc, 40);
  --
  return l_legislation_code;
end return_legislation_code;
end per_dpf_bus;

/
