--------------------------------------------------------
--  DDL for Package Body PER_PGS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PGS_BUS" as
/* $Header: pepgsrhi.pkb 120.0 2005/05/31 14:12:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pgs_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_grade_spine_id              number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_grade_spine_id                       in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , per_grade_spines_f pgs
     where pgs.grade_spine_id = p_grade_spine_id
       and pbg.business_group_id = pgs.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'grade_spine_id'
    ,p_argument_value     => p_grade_spine_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     hr_multi_message.add
       (p_associated_column1
         => nvl(p_associated_column1,'GRADE_SPINE_ID')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
  end if;
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
  (p_grade_spine_id                       in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , per_grade_spines_f pgs
     where pgs.grade_spine_id = p_grade_spine_id
       and pbg.business_group_id = pgs.business_group_id;
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
    ,p_argument           => 'grade_spine_id'
    ,p_argument_value     => p_grade_spine_id
    );
  --
  if ( nvl(per_pgs_bus.g_grade_spine_id, hr_api.g_number)
       = p_grade_spine_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_pgs_bus.g_legislation_code;
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
    per_pgs_bus.g_grade_spine_id              := p_grade_spine_id;
    per_pgs_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_grade_spine_id >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the table
--   is created properly. It should be null on insert and
--   should not be able to be updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   grade_spine_id PK of record being inserted or updated.
--   object_version_number Object version number of record being
--   inserted or updated.
--   p_effective_date
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
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_grade_spine_id
 ( p_grade_spine_id         in     per_grade_spines_f.grade_spine_id%TYPE
  ,p_object_version_number  in     per_grade_spines_f.object_version_number%TYPE
  ,p_effective_date         in     date
 ) is
 --
  l_proc         varchar2(72) := g_package||'chk_grade_spine_id';
  l_api_updating boolean;
  --
Begin
 hr_utility.set_location('Entering:'||l_proc, 10);
  --
  l_api_updating := per_pgs_shd.api_updating
    (p_effective_date               => p_effective_date
    ,p_grade_spine_id               => p_grade_spine_id
    ,p_object_version_number        => p_object_version_number
   );
  --
  if (l_api_updating
     and nvl(p_grade_spine_id,hr_api.g_number)
     <>  per_pgs_shd.g_old_rec.grade_spine_id) then
    --
    -- raise error as PK has changed
    --
    per_pgs_shd.constraint_error('PER_GRADE_SPINES_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_grade_spine_id is not null then
      --
      -- raise error as PK is not null
      --
      per_pgs_shd.constraint_error('PER_GRADE_SPINES_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
End chk_grade_spine_id;
--
--
--  ---------------------------------------------------------------------------
--  |-----------------< chk_parent_spine_id >---------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that a parent_spine_id is mandatory and
--    exists in table per_parent_spines.
--
--  Pre-conditions:
--    parent_spine_id must be valid.
--    business_group_id must be valid.
--    effective_date must be valid.
--
--  In Arguments:
--    p_grade_spine_id
--    p_parent_spine_id
--    p_business_group_id
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Processing continues
--
--  Post Failure:
--    Errors handled by the procedure
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_parent_spine_id
  (p_grade_spine_id             in per_grade_spines_f.grade_spine_id%TYPE
  ,p_parent_spine_id            in per_grade_spines_f.parent_spine_id%TYPE
  ,p_business_group_id          in per_grade_spines_f.business_group_id%TYPE
  ,p_object_version_number      in per_grade_spines_f.object_version_number%TYPE
  ,p_effective_date             in date
 )
is
  --
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_parent_spine_id';
  l_api_updating      boolean;
  --
  cursor csr_valid_parent_spines is
     select null
     from   per_parent_spines pps
     where  pps.business_group_id = p_business_group_id
     and    pps.parent_spine_id = p_parent_spine_id;
--
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --    Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'parent_spine_id'
    ,p_argument_value   => p_parent_spine_id
    );

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for parent_spine_id has changed
  --
  l_api_updating := per_pgs_shd.api_updating
         (p_effective_date         => p_effective_date
         ,p_grade_spine_id         => p_grade_spine_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating and nvl(per_pgs_shd.g_old_rec.parent_spine_id,
     hr_api.g_number) = nvl(p_parent_spine_id, hr_api.g_number)) then
     return;
  end if;

  open csr_valid_parent_spines;
  fetch csr_valid_parent_spines into l_exists;
  if csr_valid_parent_spines%notfound then
    --
    per_pgs_shd.constraint_error(p_constraint_name => 'PER_GRADE_SPINES_F_FK2');
    --
  end if;
  close csr_valid_parent_spines;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

end chk_parent_spine_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_grade_id >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the grade_id is mandatory,
--   exists in per_grades table
--   and effective_date between date_from and date_to.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   grade_id
--   grade_spine_id
--   business_group_id
--   object_version_number
--   effective_date
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
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_grade_id(
  p_grade_id                in per_grade_spines_f.grade_id%TYPE
 ,p_grade_spine_id          in per_grade_spines_f.grade_spine_id%TYPE
 ,p_business_group_id       in per_grade_spines_f.business_group_id%TYPE
 ,p_object_version_number   in per_grade_spines_f.object_version_number%TYPE
 ,p_effective_date          in date
 ) is
  --
  l_proc              varchar2(72) := g_package||'chk_grade_id';
  l_api_updating      boolean;
  l_exists            varchar2(1);
  --

 cursor csr_valid_grade_id is
     select   null
     from     per_grades pg
     where    pg.grade_id = p_grade_id
     and      business_group_id = p_business_group_id
     and      p_effective_date between pg.date_from
              and nvl(pg.date_to, hr_api.g_eot);
  --
Begin
--
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'grade_id'
    ,p_argument_value => p_grade_id
    );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for grade_id has changed
  --
  l_api_updating := per_pgs_shd.api_updating
    (p_effective_date               => p_effective_date
    ,p_grade_spine_id               => p_grade_spine_id
    ,p_object_version_number        => p_object_version_number
   );
  --
  if (l_api_updating and nvl(per_pgs_shd.g_old_rec.grade_id,
     hr_api.g_number) = nvl(p_grade_id, hr_api.g_number)) then
     return;
  end if;

  hr_utility.set_location(l_proc, 20);

  --
  -- Check that the grade_id should exist in per_grades and has the business group
  --
  open csr_valid_grade_id;
  fetch csr_valid_grade_id into l_exists;
  if csr_valid_grade_id%notfound then
      close csr_valid_grade_id;
      per_pgs_shd.constraint_error(p_constraint_name => 'PER_GRADE_SPINES_F_FK3');
      hr_utility.raise_error;
  end if;
  close csr_valid_grade_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  --
End chk_grade_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------< chk_ceiling_step_id >---------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    If ceiling_step_id is not NULL, it must
--    exist in table per_spinal_point_steps_f.
--
--  Pre-conditions:
--    parent_spine_id must be valid.
--    business_group_id must be valid.
--    effective_date must be valid.
--
--  In Arguments:
--    p_ceiling_step_id
--    p_grade_spine_id
--    p_business_group_id
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Processing continues
--
--  Post Failure:
--    Errors handled by the procedure
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_ceiling_step_id
  (p_ceiling_step_id         in per_grade_spines_f.ceiling_step_id%TYPE
  ,p_grade_spine_id          in per_grade_spines_f.grade_spine_id%TYPE
  ,p_business_group_id       in per_grade_spines_f.business_group_id%TYPE
  ,p_object_version_number   in per_grade_spines_f.object_version_number%TYPE
  ,p_effective_date          in date
  )
is
  --
  l_proc            varchar2(72)  :=  g_package||'chk_ceiling_step_id';
  l_api_updating    boolean;
  l_exists          varchar2(1);
  l_ceiling_step_id number;
  --
/*
  cursor csr_valid_parent_spine is
     select null
     from   per_spinal_points psp
     where  psp.business_group_id = p_business_group_id
     and    psp.spinal_point = p_ceiling_step_id
     and    psp.parent_spine_id = p_rec.parent_spine_id;
*/

  cursor csr_valid_spinal_point_step is
     select null
     from   per_spinal_point_steps_f
     where  business_group_id = p_business_group_id
     and    step_id = p_ceiling_step_id
     and    p_effective_date between effective_start_date
            and effective_end_date;

  cursor csr_next_ceiling_step_id is
     select per_spinal_point_steps_s.nextval
     from   sys.dual;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  if p_ceiling_step_id is not NULL then
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The value for ceiling_step_id has changed
    --
    l_api_updating := per_pgs_shd.api_updating
           (p_effective_date         => p_effective_date
           ,p_grade_spine_id         => p_grade_spine_id
           ,p_object_version_number  => p_object_version_number);
    --
    if (l_api_updating) then
      if nvl(per_pgs_shd.g_old_rec.ceiling_step_id, hr_api.g_number)
         = nvl(p_ceiling_step_id, hr_api.g_number) then
        return;
      else

        hr_utility.set_location(l_proc, 20);

       /* skip mandatory parameter check BUG3389808
        --
        --    Check mandatory parameters have been set
        --
        hr_api.mandatory_arg_error
          (p_api_name         => l_proc
          ,p_argument         => 'ceiling_step_id'
          ,p_argument_value   => p_ceiling_step_id
          );
       */

        /*
        --
        -- This validation was replaced by csr_valid_spinal_point_step
        --
        open csr_valid_parent_spine;
        fetch csr_valid_parent_spine into l_exists;
        if csr_valid_parent_spine%notfound then
          close csr_valid_parent_spine;
          --
          hr_utility.set_message(800, 'HR_289687_SPINAL_POINT_INV');
          hr_utility.raise_error;
          --
        end if;
        close csr_valid_parent_spine;
        */

        open csr_valid_spinal_point_step;
        fetch csr_valid_spinal_point_step into l_exists;
        if csr_valid_spinal_point_step%notfound then
          close csr_valid_spinal_point_step;
          --
          hr_utility.set_message(800, 'HR_289567_CEILING_STEP_INVALID');
          hr_utility.raise_error;
          --
        end if;
        close csr_valid_spinal_point_step;
      end if;
    else

      hr_utility.set_location(l_proc, 30);

      --
      hr_utility.set_location(l_proc, 40);
      --
      /*
      --
      -- This validation was replaced by csr_valid_spinal_point_step
      --
      open csr_valid_parent_spine;
      fetch csr_valid_parent_spine into l_exists;
      if csr_valid_parent_spine%notfound then
        close csr_valid_parent_spine;
        --
        hr_utility.set_message(800, 'HR_289687_SPINAL_POINT_INV');
        hr_utility.raise_error;
        --
      end if;
      close csr_valid_parent_spine;
      */

      open csr_valid_spinal_point_step;
      fetch csr_valid_spinal_point_step into l_exists;
      if csr_valid_spinal_point_step%notfound then
        close csr_valid_spinal_point_step;
        --
        hr_utility.set_message(800, 'HR_289567_CEILING_STEP_INVALID');
        hr_utility.raise_error;
        --
      end if;
      close csr_valid_spinal_point_step;
     end if;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 60);

end chk_ceiling_step_id;

--
--  ---------------------------------------------------------------------------
--  |-----------------< chk_uniq_grade_pay_scale >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that combination fo grade_id and parent_spine_id is unique.
--
--  Pre-conditions:
--    parent_spine_id must be valid.
--    business_group_id must be valid.
--    effective_date must be valid.
--
--  In Arguments:
--    p_grade_spine_id
--    p_grade_id
--    p_parent_spine_id
--    p_business_group_id
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    If the combination is unique; processing continues.
--
--  Post Failure:
--    If the combination exists in per_grade_spines_f,
--    then an error will be raised and processing terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_uniq_grade_pay_scale
  (p_grade_spine_id           in per_grade_spines_f.grade_spine_id%TYPE
  ,p_grade_id                 in per_grade_spines_f.grade_id%TYPE
  ,p_parent_spine_id          in per_grade_spines_f.parent_spine_id%TYPE
  ,p_business_group_id        in per_grade_spines_f.business_group_id%TYPE
  ,p_object_version_number    in per_grade_spines_f.object_version_number%TYPE
  ,p_effective_date           in date
  )
is
  --
  l_proc           varchar2(72)  :=  g_package||'chk_uniq_grade_pay_scale';
  l_api_updating   boolean;
  l_exists         varchar2(1);
  --
  cursor csr_uniq_grade_pay_scale is
     select null
     from   per_grade_spines_f
     where  business_group_id = p_business_group_id
     and    grade_id = p_grade_id
     and    parent_spine_id = p_parent_spine_id
     and    p_effective_date
            between effective_start_date and
                    effective_end_date ;
--
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for grade_id and parent_spine_id have changed
  --
  l_api_updating := per_pgs_shd.api_updating
         (p_effective_date         => p_effective_date
         ,p_grade_spine_id         => p_grade_spine_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
       and nvl(per_pgs_shd.g_old_rec.grade_id,
         hr_api.g_number) = nvl(p_grade_id, hr_api.g_number)
       and nvl(per_pgs_shd.g_old_rec.parent_spine_id,hr_api.g_number)
         = nvl(p_parent_spine_id, hr_api.g_number)
     ) then
     return;
  end if;

  hr_utility.set_location(l_proc, 20);

  open csr_uniq_grade_pay_scale;
  fetch csr_uniq_grade_pay_scale into l_exists;
  if csr_uniq_grade_pay_scale%found then
    close csr_uniq_grade_pay_scale;
    --
    hr_utility.set_message(800, 'PER_7932_GRDSPN_GRD_EXISTS');
    hr_utility.raise_error;
    --
  end if;
  close csr_uniq_grade_pay_scale;

  hr_utility.set_location(' Leaving:'|| l_proc, 30);

end chk_uniq_grade_pay_scale;

--
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_delete >--------------------------------|
--  ---------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that there are no values in
--   per_spinal_point_steps_f, per_spinal_point_placement_f and
--   per_all_assignments_f.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_parent_spine_id
--   p_grade_id
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
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_delete(
   p_parent_spine_id         in per_grade_spines_f.parent_spine_id%TYPE
  ,p_grade_id                in per_grade_spines_f.grade_id%TYPE
 ) is
  --
  l_proc         varchar2(72) := g_package||'chk_delete';
  l_exists       varchar2(1);
  --
  cursor csr_spinal_point_placements is
	select 'x'
	from per_spinal_point_steps_f sps
     	    ,per_grade_spines_f gs
	where gs.grade_spine_id = sps.grade_spine_id
	and gs.parent_spine_id = p_parent_spine_id
	and gs.grade_id = p_grade_id
	and exists
    	(select null
     	from per_spinal_point_placements_f sp
     	where sp.step_id = sps.step_id);

  cursor csr_assignments is
	select 'x'
	from per_spinal_point_steps_f sps
     	    ,per_grade_spines_f gs
	where gs.grade_spine_id = sps.grade_spine_id
	and gs.parent_spine_id = p_parent_spine_id
	and gs.grade_id = p_grade_id
	and exists
 	   (select null
     	from per_assignments_f a
    	 where a.special_ceiling_step_id = sps.step_id
     	and a.special_ceiling_step_id is not null);

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  --  Check there are no values in per_spinal_point_steps_f
  --  and per_spinal_point_placements_f
  --
  open csr_spinal_point_placements;
  --
  fetch csr_spinal_point_placements into l_exists;
  --
    If csr_spinal_point_placements%found Then
    --
      close csr_spinal_point_placements;
      --
      hr_utility.set_message(801, 'PER_7933_DEL_GRDSPN_PLACE');
      hr_utility.raise_error;
      --
    End If;
  --
  close csr_spinal_point_placements;

  hr_utility.set_location(l_proc, 20);

  --
  --  Check there are no values in  per_all_assignments_f
  --
  open csr_assignments;
  fetch csr_assignments into l_exists;

    If csr_assignments%found Then
      --
      close csr_assignments;
      --
      hr_utility.set_message(801, 'PER_7934_DEL_GRDSPN_ASS');
      hr_utility.raise_error;
      --
    End If;
  --
  close csr_assignments;
  --
  hr_utility.set_location(' Leaving:' || l_proc, 30);
  --
end chk_delete;
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
  (p_effective_date  in date
  ,p_rec             in per_pgs_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_pgs_shd.api_updating
      (p_grade_spine_id                   => p_rec.grade_spine_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;

  --
  -- Check business_group_id is not updated
  --
  IF nvl(p_rec.business_group_id, hr_api.g_number) <>
     per_pgs_shd.g_old_rec.business_group_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'BUSINESS_GROUP_ID'
    ,p_base_table => per_pgs_shd.g_tab_nam
    );
  END IF;

  --
  -- Check parent_spine_id is not updated
  --
  IF nvl(p_rec.parent_spine_id, hr_api.g_number) <>
     per_pgs_shd.g_old_rec.parent_spine_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'PARENT_SPINE_ID'
    ,p_base_table => per_pgs_shd.g_tab_nam
    );
  END IF;

  --
  -- Check grade_id is not updated
  --
  IF nvl(p_rec.grade_id, hr_api.g_number) <>
     per_pgs_shd.g_old_rec.grade_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'GRADE_ID'
    ,p_base_table => per_pgs_shd.g_tab_nam
    );
  end if;

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
  (p_grade_spine_id                   in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
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
      ,p_argument       => 'grade_spine_id'
      ,p_argument_value => p_grade_spine_id
      );

    --
    -- when validate_mode is ZAP, the following validation isn't required.
    --
    /*
    If (dt_api.rows_exist
       (p_base_table_name => 'per_spinal_point_steps_f'
       ,p_base_key_column => 'grade_spine_id'
       ,p_base_key_value  => p_grade_spine_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
         fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
         fnd_message.set_token('TABLE_NAME','spinal point steps');
         hr_multi_message.add;
    End If;
    If (dt_api.rows_exist
       (p_base_table_name => 'per_cagr_entitlement_lines_f'
       ,p_base_key_column => 'grade_spine_id'
       ,p_base_key_value  => p_grade_spine_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
         fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
         fnd_message.set_token('TABLE_NAME','cagr entitlement lines');
         hr_multi_message.add;
    End If;
    */
    --
  End If;
  --
Exception
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
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in out nocopy per_pgs_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => per_pgs_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');

  --
  -- Validate grade spine id
  --
  chk_grade_spine_id
   (p_grade_spine_id          => p_rec.grade_spine_id
   ,p_object_version_number   => p_rec.object_version_number
   ,p_effective_date          => p_effective_date
  ) ;

  hr_utility.set_location(l_proc, 20);

  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;

  --
  -- Validate Dependent Attributes
  --
  --

  --
  -- Validate parent spine id
  --
  chk_parent_spine_id
  (p_grade_spine_id         => p_rec.grade_spine_id
  ,p_parent_spine_id        => p_rec.parent_spine_id
  ,p_business_group_id      => p_rec.business_group_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_effective_date         => p_effective_date
  );

  hr_utility.set_location(l_proc, 30);

  --
  -- Validate grade id
  --
  chk_grade_id
  (p_grade_id               => p_rec.grade_id
  ,p_grade_spine_id         => p_rec.grade_spine_id
  ,p_business_group_id      => p_rec.business_group_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_effective_date         => p_effective_date
  ) ;

  hr_utility.set_location(l_proc, 40);

  --
  -- Validate ceiling step id
  --
  chk_ceiling_step_id
  (p_ceiling_step_id        => p_rec.ceiling_step_id
  ,p_grade_spine_id         => p_rec.grade_spine_id
  ,p_business_group_id      => p_rec.business_group_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_effective_date         => p_effective_date
  );


  hr_utility.set_location(l_proc, 50);

  --
  -- Validate the combination of grade id and parent spine id
  --
  chk_uniq_grade_pay_scale
  (p_grade_spine_id         => p_rec.grade_spine_id
  ,p_grade_id               => p_rec.grade_id
  ,p_parent_spine_id        => p_rec.parent_spine_id
  ,p_business_group_id      => p_rec.business_group_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_effective_date         => p_effective_date
  );

  hr_utility.set_location(' Leaving:'||l_proc, 100);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in out nocopy per_pgs_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => per_pgs_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');

  --
  -- Validate grade spine id
  --
  chk_grade_spine_id
   (p_grade_spine_id           => p_rec.grade_spine_id
   ,p_object_version_number    => p_rec.object_version_number
   ,p_effective_date           => p_effective_date
  ) ;

  hr_utility.set_location(l_proc, 20);

  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );

  hr_utility.set_location(l_proc, 30);

  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;

  --
  -- Validate Dependent Attributes
  --
  --

  --
  -- Validate parent spine id
  --
  chk_parent_spine_id
  (p_grade_spine_id         => p_rec.grade_spine_id
  ,p_parent_spine_id        => p_rec.parent_spine_id
  ,p_business_group_id      => p_rec.business_group_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_effective_date         => p_effective_date
  );

  hr_utility.set_location(l_proc, 40);

  --
  -- Validate grade id
  --
  chk_grade_id
  (p_grade_id               => p_rec.grade_id
  ,p_grade_spine_id         => p_rec.grade_spine_id
  ,p_business_group_id      => p_rec.business_group_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_effective_date         => p_effective_date
  ) ;

  hr_utility.set_location(l_proc, 50);

  --
  -- Validate ceiling step id
  --
  chk_ceiling_step_id
  (p_ceiling_step_id        => p_rec.ceiling_step_id
  ,p_grade_spine_id         => p_rec.grade_spine_id
  ,p_business_group_id      => p_rec.business_group_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_effective_date         => p_effective_date
  );


  hr_utility.set_location(l_proc, 60);

  --
  -- Validate the combination of grade id and parent spine id
  --
  chk_uniq_grade_pay_scale
  (p_grade_spine_id         => p_rec.grade_spine_id
  ,p_grade_id               => p_rec.grade_id
  ,p_parent_spine_id        => p_rec.parent_spine_id
  ,p_business_group_id      => p_rec.business_group_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_effective_date         => p_effective_date
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in per_pgs_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_grade_spine_id                   => p_rec.grade_spine_id
    );
  --

  hr_utility.set_location(l_proc, 20);

  chk_delete(p_parent_spine_id  => p_rec.parent_spine_id
            ,p_grade_id         => p_rec.grade_id);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
End delete_validate;
--
end per_pgs_bus;

/
