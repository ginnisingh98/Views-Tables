--------------------------------------------------------
--  DDL for Package Body PER_SPS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SPS_BUS" as
/* $Header: pespsrhi.pkb 120.5.12000000.1 2007/01/22 04:39:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_sps_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_step_id                     number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_step_id                              in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , per_spinal_point_steps_f sps
     where sps.step_id = p_step_id
       and pbg.business_group_id = sps.business_group_id;
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
    ,p_argument           => 'step_id'
    ,p_argument_value     => p_step_id
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
         => nvl(p_associated_column1,'STEP_ID')
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
  (p_step_id                              in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , per_spinal_point_steps_f sps
     where sps.step_id = p_step_id
       and pbg.business_group_id = sps.business_group_id;
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
    ,p_argument           => 'step_id'
    ,p_argument_value     => p_step_id
    );
  --
  if ( nvl(per_sps_bus.g_step_id, hr_api.g_number)
       = p_step_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_sps_bus.g_legislation_code;
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
    per_sps_bus.g_step_id                     := p_step_id;
    per_sps_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_step_id >--------------------------------|
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
--   step_id PK of record being inserted or updated.
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
Procedure chk_step_id
 ( p_step_id                in per_spinal_point_steps_f.step_id%TYPE
  ,p_object_version_number  in per_spinal_point_steps_f.object_version_number%TYPE
  ,p_effective_date         in date
 ) is
--
  l_proc         varchar2(72) := g_package||'chk_step_id';
  l_api_updating boolean;
  --
Begin
 hr_utility.set_location('Entering:'||l_proc, 10);
  --
  l_api_updating := per_sps_shd.api_updating
    (p_effective_date               => p_effective_date
    ,p_step_id                      => p_step_id
    ,p_object_version_number        => p_object_version_number
   );
  --
  if (l_api_updating
     and nvl(p_step_id,hr_api.g_number)
     <>  per_sps_shd.g_old_rec.step_id) then
    --
    -- raise error as PK has changed
    --
    per_sps_shd.constraint_error('PER_SPINAL_POINT_STEPS_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_step_id is not null then
      --
      --  Set p_step_id to gloval value for insert
      --
      per_sps_ins.set_base_key_value(p_step_id);

      /*
      --
      -- raise error as PK is not null
      --
      per_sps_shd.constraint_error('PER_SPINAL_POINT_STEPS_F_PK');
      --
     */
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
End chk_step_id;
--
--
--  ---------------------------------------------------------------------------
--  |-----------------< chk_spinal_point_id >---------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that a spinal_point_id is mandatory and
--    exists in table per_spinal_points.
--
--    Validates business_group_id in per_spinal_points talble should be
--    the same as business_group_id to be passed as a parameter and
--    parent_spine_id in per_spinal_points should be the same as parent_spine_id
--    in per_grade_spines_f to be refered by grade_spine_id to be passed as
--    a parameter.
--
--  Pre-conditions:
--    step_id must be valid.
--    business_group_id must be valid.
--    effective_date must be valid.
--
--  In Arguments:
--    p_step_id
--    p_spinal_point_id
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
procedure chk_spinal_point_id
  (p_step_id                 in per_spinal_point_steps_f.step_id%TYPE
  ,p_spinal_point_id         in per_spinal_point_steps_f.spinal_point_id%TYPE
  ,p_grade_spine_id          in per_spinal_point_steps_f.grade_spine_id%TYPE
  ,p_business_group_id       in per_spinal_point_steps_f.business_group_id%TYPE
  ,p_object_version_number   in per_spinal_point_steps_f.object_version_number%TYPE
  ,p_effective_date          in date
)
is
  --
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_spinal_point_id';
  l_api_updating      boolean;
  --
  cursor csr_valid_spinal_point is
     select null
     from   per_spinal_points psp
     where  psp.business_group_id = p_business_group_id
     and    psp.spinal_point_id = p_spinal_point_id;
  --
  cursor csr_valid_parent_spine is
     select null
     from   per_spinal_points psp
           ,per_grade_spines_f pgs
     where  psp.business_group_id = p_business_group_id
     and    psp.spinal_point_id = p_spinal_point_id
     and    pgs.grade_spine_id = p_grade_spine_id
     and    pgs.business_group_id = p_business_group_id
     and    p_effective_date between
            pgs.effective_start_date and pgs.effective_end_date
     and    pgs.parent_spine_id = psp.parent_spine_id;
--
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --    Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'spinal_point_id'
    ,p_argument_value   => p_spinal_point_id
    );

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for spinal_point_id has changed
  --
  l_api_updating := per_sps_shd.api_updating
         (p_effective_date         => p_effective_date
         ,p_step_id                => p_step_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating and nvl(per_sps_shd.g_old_rec.spinal_point_id,
     hr_api.g_number) = nvl(p_spinal_point_id, hr_api.g_number)) then
     return;
  end if;

  hr_utility.set_location(l_proc, 20);

  open csr_valid_spinal_point;
  fetch csr_valid_spinal_point into l_exists;
  if csr_valid_spinal_point%notfound then
    close csr_valid_spinal_point;
    --
    per_sps_shd.constraint_error(p_constraint_name => 'PER_SPINAL_POINT_STEPS_F_FK2');
    --
  end if;
  close csr_valid_spinal_point;

  hr_utility.set_location(l_proc, 30);

  --
  -- check parent_spine_id in per_spinal_points is the same as
  -- parent_spine_id in per_grade_spines_f
  --
  open csr_valid_parent_spine;
  fetch csr_valid_parent_spine into l_exists;
  if csr_valid_parent_spine%notfound then
    close csr_valid_parent_spine;
    --
    hr_utility.set_message(800, 'HR_289286_PARENT_SPINE_INVALID');
    hr_utility.raise_error;
    --
  end if;
  close csr_valid_parent_spine;

  hr_utility.set_location(' Leaving:'|| l_proc, 40);

end chk_spinal_point_id;
--
--  ---------------------------------------------------------------------------
--  |------------------< chk_grade_spine_id >---------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that a grade_spine_id is mandatory and
--    exists in table per_grade_spines.
--
--    Validates business_group_id in per_grade_spines should be the same
--    as business_group_id to be passed as a parameter.
--
--  Pre-conditions:
--    step_id must be valid.
--    business_group_id must be valid.
--    effective_date must be valid.
--
--  In Arguments:
--    p_step_id
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
procedure chk_grade_spine_id
  (p_step_id                in per_spinal_point_steps_f.step_id%TYPE
  ,p_grade_spine_id         in per_spinal_point_steps_f.grade_spine_id%TYPE
  ,p_business_group_id      in per_spinal_point_steps_f.business_group_id%TYPE
  ,p_object_version_number  in per_spinal_point_steps_f.object_version_number%TYPE
  ,p_effective_date         in date
)
is
  --
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_grade_spine_id';
  l_api_updating   boolean;
  --
  cursor csr_valid_grade_spine is
     select null
     from   per_grade_spines_f pgs
     where  pgs.business_group_id = p_business_group_id
     and    pgs.grade_spine_id = p_grade_spine_id
     and    p_effective_date between
            pgs.effective_start_date and pgs.effective_end_date;
--
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --    Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'grade_spine_id'
    ,p_argument_value   => p_grade_spine_id
    );

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for grade_spine_id has changed
  --
  l_api_updating := per_sps_shd.api_updating
         (p_effective_date         => p_effective_date
         ,p_step_id                => p_step_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating and nvl(per_sps_shd.g_old_rec.grade_spine_id,
     hr_api.g_number) = nvl(p_grade_spine_id, hr_api.g_number)) then
     return;
  end if;

  hr_utility.set_location(l_proc, 20);

  open csr_valid_grade_spine;
  fetch csr_valid_grade_spine into l_exists;
  if csr_valid_grade_spine%notfound then
    close csr_valid_grade_spine;
    --
    per_sps_shd.constraint_error(p_constraint_name => 'PER_SPINAL_POINT_STEPS_F_N3');
    --
  end if;
  close csr_valid_grade_spine;

  hr_utility.set_location(' Leaving:'|| l_proc, 30);

end chk_grade_spine_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_sequence >---------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that a sequence is mandatory and exists in table per_spinal_points.
--
--  Pre-conditions:
--    step_id must be valid.
--    business_group_id must be valid.
--    effective_date must be valid.
--
--  In Arguments:
--    p_step_id
--    p_sequence
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
procedure chk_sequence
  (p_step_id                in per_spinal_point_steps_f.step_id%TYPE
  ,p_sequence               in per_spinal_point_steps_f.sequence%TYPE
  ,p_spinal_point_id        in per_spinal_point_steps_f.spinal_point_id%TYPE
  ,p_business_group_id      in per_spinal_point_steps_f.business_group_id%TYPE
  ,p_object_version_number  in per_spinal_point_steps_f.object_version_number%TYPE
  ,p_effective_date         in date
)
is
  --
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_sequence';
  l_api_updating      boolean;
  --
  cursor csr_valid_sequence is
     select null
     from   per_spinal_points psp
     where  psp.business_group_id = p_business_group_id
     and    psp.spinal_point_id = p_spinal_point_id
     and    psp.sequence = p_sequence;
--
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --    Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'sequence'
    ,p_argument_value   => p_sequence
    );

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for sequence has changed
  --
  l_api_updating := per_sps_shd.api_updating
         (p_effective_date         => p_effective_date
         ,p_step_id                => p_step_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating and nvl(per_sps_shd.g_old_rec.sequence,
     hr_api.g_number) = nvl(p_sequence, hr_api.g_number)) then
     return;
  end if;

  hr_utility.set_location(l_proc, 20);

  open csr_valid_sequence;
  fetch csr_valid_sequence into l_exists;
  if csr_valid_sequence%notfound then
    close csr_valid_sequence;
    --
    hr_utility.set_message(800, 'HR_289568_INV_STEP_SEQUENCE');
    hr_utility.raise_error;
    --
  end if;
  close csr_valid_sequence;

  hr_utility.set_location(' Leaving:'|| l_proc, 30);

end chk_sequence;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_uniq_step_points >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that spinal_point_id is unique for each grade_spine_id is
--    unique.
--
--  Pre-conditions:
--    step_id must be valid.
--    spinal_point_id must be valid.
--    grade_spine_id must be valid.
--    effective_date must be valid.
--
--  In Arguments:
--    p_step_id
--    p_spinal_point_id
--    p_grade_spine_id
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Processing continues.
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
procedure chk_uniq_step_points
  (p_step_id                in per_spinal_point_steps_f.step_id%TYPE
  ,p_spinal_point_id        in per_spinal_point_steps_f.spinal_point_id%TYPE
  ,p_grade_spine_id         in per_spinal_point_steps_f.grade_spine_id%TYPE
  ,p_object_version_number  in per_spinal_point_steps_f.object_version_number%TYPE
  ,p_effective_date         in date
  )
is
  --
  l_proc           varchar2(72)  :=  g_package||'chk_uniq_step_points';
  l_api_updating   boolean;
  l_exists         varchar2(1);
  --
  --nvl clause added for p_step_id as part of fix for bug 3865077.
  cursor csr_uniq_step_point is
	select 'x'
	from sys.dual
	where exists
        (select null
         from per_spinal_point_steps_f
         where grade_spine_id = p_grade_spine_id
         and   spinal_point_id = p_spinal_point_id
         and   step_id <> nvl(p_step_id,hr_api.g_number)
         and   p_effective_date between effective_start_date
               and effective_end_date);
--
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for spinal_point_id and grade_spine_id have changed
  --
  l_api_updating := per_sps_shd.api_updating
         (p_effective_date         => p_effective_date
         ,p_step_id                => p_step_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
       and nvl(per_sps_shd.g_old_rec.spinal_point_id,
         hr_api.g_number) = nvl(p_spinal_point_id, hr_api.g_number)
       and nvl(per_sps_shd.g_old_rec.grade_spine_id,hr_api.g_number)
         = nvl(p_grade_spine_id, hr_api.g_number)
     ) then
     return;
  end if;
 hr_utility.set_location(l_proc, 20);

  open csr_uniq_step_point;
  fetch csr_uniq_step_point into l_exists;
  if csr_uniq_step_point%found then
    close csr_uniq_step_point;
    --
    hr_utility.set_message(800, 'HR_7936_GRDPSN_POINT_EXISTS');
    hr_utility.raise_error;
    --
  end if;
  close csr_uniq_step_point;

  hr_utility.set_location(' Leaving:'|| l_proc, 30);

end chk_uniq_step_points;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_delete >--------------------------------|
--  ---------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that there are no values in
--   per_spinal_point_placement_f, per_all_assignments_f and hr_all_positions_f
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_step_id
--   p_spinal_point_id
--   p_grade_spine_id
--   p_effective_date
--   p_datetrack_mode
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
procedure chk_delete(
   p_step_id          in per_spinal_point_steps_f.step_id%Type
  ,p_spinal_point_id  in per_spinal_point_steps_f.spinal_point_id%Type
  ,p_grade_spine_id   in per_spinal_point_steps_f.grade_spine_id%Type
  ,p_effective_date   in date
  ,p_datetrack_mode   in varchar2
  ,p_called_from_del_grd_scale in boolean   --bug 4096238
  ) is
  --
  -- Start of fix 3439542
  l_proc         varchar2(72) := g_package||'chk_delete';
  l_date         date;
  l_exists1      varchar2(1) := Null;
  l_exists2      varchar2(1) := Null;
  l_exists3      varchar2(1) := Null;
  --
  cursor csr_spinal_point(p_date date) is
         select 'X'
           from per_spinal_point_placements_f
          where step_id = p_step_id
            and p_date < effective_end_date;
  --
  cursor csr_assignment(p_date date) is
         select 'X'
           from per_all_assignments_f
          where special_ceiling_step_id = p_step_id;
  --        and p_date < effective_end_date;
  --
  cursor csr_position(p_date date) is
         select 'X'
           from hr_all_positions_f
          where entry_step_id = p_step_id
            and p_date < effective_end_date;



-- start of bug fix 4096238

  l_ceil_id varchar2(1) := Null;
  l_grade_spine_id number(15,0):= Null;

 /* This cusor will be called when the grade step
    is getting purged and the cursor checks wheather the current step
    is used as a ceiling step in its life time . */

   cursor csr_ceiling_chk is
          select 'X' from per_grade_spines_f
          where ceiling_step_id=p_step_id
          and  grade_spine_id=l_grade_spine_id
          and p_effective_date<>effective_start_date;
/* This cusor will be called when the grade step
   is getting end dated and checks wheather the current step is
   used as a ceiling step in future . */

    cursor csr_ceiling_chk2 IS
           select 'X' from per_grade_spines_f
           where ceiling_step_id = p_step_id and
           grade_spine_id=l_grade_spine_id and
           p_effective_date <= effective_end_date;

-- end of fix for 4096238
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Needs to be checked the existence of child records
  -- based on the DT mode
  if p_datetrack_mode = hr_api.g_delete then
     l_date := p_effective_date;
  else
     l_date := hr_api.g_eot;
  end if;
  -- Check on per_spinal_point_placements_f
  open csr_spinal_point(l_date);
  fetch csr_spinal_point into l_exists1;
  close csr_spinal_point;
  if l_exists1 = 'X' then
     hr_utility.set_message(801, 'PER_7938_DEL_STEP_PLACE');
     hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  -- Check on per_all_assignments_f
  open csr_assignment(l_date);
  fetch csr_assignment into l_exists2;
  close csr_assignment;
  if l_exists2 = 'X' then
     hr_utility.set_message(801, 'PER_7939_DEL_STEP_ASS');
     hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  -- Check on hr_all_positions_f
  open csr_position(l_date);
  fetch csr_position into l_exists3;
  close csr_position;
  if l_exists3 = 'X' then
     hr_utility.set_message(801, 'HR_289566_DEL_STEP_POSITION');
     hr_utility.raise_error;
  end if;

-- start of bug fix 4096238

 select grade_spine_id into l_grade_spine_id
    from per_spinal_point_steps_f where step_id=p_step_id;

  if ( not p_called_from_del_grd_scale ) and (p_datetrack_mode = hr_api.g_zap ) then
   open csr_ceiling_chk;
   fetch csr_ceiling_chk into l_ceil_id;
   close csr_ceiling_chk;
   if l_ceil_id = 'X' then
      hr_utility.set_location(l_proc, 40);
      hr_utility.set_message(800, 'HR_449730_DEL_CEI_FUT_PAST');
      hr_utility.raise_error;
   end if;
   end if;
   l_ceil_id :=Null;
   if ( not p_called_from_del_grd_scale ) and (p_datetrack_mode = hr_api.g_delete ) then
   open csr_ceiling_chk2;
   fetch csr_ceiling_chk2 into l_ceil_id;
   close csr_ceiling_chk2;
   if l_ceil_id = 'X' then
      hr_utility.set_location(l_proc, 50);
      hr_utility.set_message(800, 'HR_449731_END_CEI_EXISTS');
      hr_utility.raise_error;
   end if;
   end if;

 --
  -- end of bug fix 4096238
  --
  hr_utility.set_location(' Leaving:' || l_proc, 99);
  --
  -- End of fix 3439542
end chk_delete;
--
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
  (p_rec in per_sps_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.step_id is not null)  and (
    nvl(per_sps_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information12, hr_api.g_varchar2) <>
    nvl(p_rec.information12, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information21, hr_api.g_varchar2) <>
    nvl(p_rec.information21, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information22, hr_api.g_varchar2) <>
    nvl(p_rec.information22, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information23, hr_api.g_varchar2) <>
    nvl(p_rec.information23, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information24, hr_api.g_varchar2) <>
    nvl(p_rec.information24, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information25, hr_api.g_varchar2) <>
    nvl(p_rec.information25, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information26, hr_api.g_varchar2) <>
    nvl(p_rec.information26, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information27, hr_api.g_varchar2) <>
    nvl(p_rec.information27, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information28, hr_api.g_varchar2) <>
    nvl(p_rec.information28, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information29, hr_api.g_varchar2) <>
    nvl(p_rec.information29, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information30, hr_api.g_varchar2) <>
    nvl(p_rec.information30, hr_api.g_varchar2)  or
    nvl(per_sps_shd.g_old_rec.information_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2) ))
    or (p_rec.step_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Spinal Point Step DDF'
      ,p_attribute_category              => p_rec.information_category
      ,p_attribute1_name                 => 'INFORMATION1'
      ,p_attribute1_value                => p_rec.information1
      ,p_attribute2_name                 => 'INFORMATION2'
      ,p_attribute2_value                => p_rec.information2
      ,p_attribute3_name                 => 'INFORMATION3'
      ,p_attribute3_value                => p_rec.information3
      ,p_attribute4_name                 => 'INFORMATION4'
      ,p_attribute4_value                => p_rec.information4
      ,p_attribute5_name                 => 'INFORMATION5'
      ,p_attribute5_value                => p_rec.information5
      ,p_attribute6_name                 => 'INFORMATION6'
      ,p_attribute6_value                => p_rec.information6
      ,p_attribute7_name                 => 'INFORMATION7'
      ,p_attribute7_value                => p_rec.information7
      ,p_attribute8_name                 => 'INFORMATION8'
      ,p_attribute8_value                => p_rec.information8
      ,p_attribute9_name                 => 'INFORMATION9'
      ,p_attribute9_value                => p_rec.information9
      ,p_attribute10_name                => 'INFORMATION10'
      ,p_attribute10_value               => p_rec.information10
      ,p_attribute11_name                => 'INFORMATION11'
      ,p_attribute11_value               => p_rec.information11
      ,p_attribute12_name                => 'INFORMATION12'
      ,p_attribute12_value               => p_rec.information12
      ,p_attribute13_name                => 'INFORMATION13'
      ,p_attribute13_value               => p_rec.information13
      ,p_attribute14_name                => 'INFORMATION14'
      ,p_attribute14_value               => p_rec.information14
      ,p_attribute15_name                => 'INFORMATION15'
      ,p_attribute15_value               => p_rec.information15
      ,p_attribute16_name                => 'INFORMATION16'
      ,p_attribute16_value               => p_rec.information16
      ,p_attribute17_name                => 'INFORMATION17'
      ,p_attribute17_value               => p_rec.information17
      ,p_attribute18_name                => 'INFORMATION18'
      ,p_attribute18_value               => p_rec.information18
      ,p_attribute19_name                => 'INFORMATION19'
      ,p_attribute19_value               => p_rec.information19
      ,p_attribute20_name                => 'INFORMATION20'
      ,p_attribute20_value               => p_rec.information20
      ,p_attribute21_name                => 'INFORMATION21'
      ,p_attribute21_value               => p_rec.information21
      ,p_attribute22_name                => 'INFORMATION22'
      ,p_attribute22_value               => p_rec.information22
      ,p_attribute23_name                => 'INFORMATION23'
      ,p_attribute23_value               => p_rec.information23
      ,p_attribute24_name                => 'INFORMATION24'
      ,p_attribute24_value               => p_rec.information24
      ,p_attribute25_name                => 'INFORMATION25'
      ,p_attribute25_value               => p_rec.information25
      ,p_attribute26_name                => 'INFORMATION26'
      ,p_attribute26_value               => p_rec.information26
      ,p_attribute27_name                => 'INFORMATION27'
      ,p_attribute27_value               => p_rec.information27
      ,p_attribute28_name                => 'INFORMATION28'
      ,p_attribute28_value               => p_rec.information28
      ,p_attribute29_name                => 'INFORMATION29'
      ,p_attribute29_value               => p_rec.information29
      ,p_attribute30_name                => 'INFORMATION30'
      ,p_attribute30_value               => p_rec.information30
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
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
  ,p_rec             in per_sps_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_sps_shd.api_updating
      (p_step_id                          => p_rec.step_id
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
     per_sps_shd.g_old_rec.business_group_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'BUSINESS_GROUP_ID'
    ,p_base_table => per_sps_shd.g_tab_nam
    );
  END IF;

  --
  -- Check spinal_point_id is not updated
  --
  IF nvl(p_rec.spinal_point_id, hr_api.g_number) <>
     per_sps_shd.g_old_rec.spinal_point_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'SPINAL_POINT_ID'
    ,p_base_table => per_sps_shd.g_tab_nam
    );
  END IF;

  --
  -- Check grade_spine_id is not updated
  --
  IF nvl(p_rec.grade_spine_id, hr_api.g_number) <>
     per_sps_shd.g_old_rec.grade_spine_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'GRADE_SPINE_ID'
    ,p_base_table => per_sps_shd.g_tab_nam
    );
  END IF;

  --
  -- Check sequence is not updated
  --
  IF nvl(p_rec.sequence, hr_api.g_number) <>
     per_sps_shd.g_old_rec.sequence then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'SEQUENCE'
    ,p_base_table => per_sps_shd.g_tab_nam
    );
  END IF;
  --
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
  (p_grade_spine_id                in number default hr_api.g_number
  ,p_datetrack_mode                in varchar2
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
  If ((nvl(p_grade_spine_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'per_grade_spines_f'
            ,p_base_key_column => 'GRADE_SPINE_ID'
            ,p_base_key_value  => p_grade_spine_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
     fnd_message.set_token('TABLE_NAME','grade spines');
     hr_multi_message.add
       (p_associated_column1 => per_sps_shd.g_tab_nam || '.GRADE_SPINE_ID');
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
  (p_step_id                          in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
--
Begin
  hr_utility.set_location('Entering : ' || l_proc, 10);
  hr_utility.trace('p_step_id        : ' || p_step_id);
  hr_utility.trace('p_datetrack_mode : ' || p_datetrack_mode);
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
      ,p_argument       => 'step_id'
      ,p_argument_value => p_step_id
      );
    --
    hr_utility.set_location(l_proc, 20);
    --
    If (dt_api.rows_exist
       (p_base_table_name => 'per_cagr_entitlement_lines_f'
       ,p_base_key_column => 'step_id'
       ,p_base_key_value  => p_step_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
         fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
         fnd_message.set_token('TABLE_NAME','cagr entitlement lines');
         hr_multi_message.add;
    End If;

    hr_utility.set_location(l_proc, 30);

    If (dt_api.rows_exist
       (p_base_table_name => 'hr_all_positions_f'
       ,p_base_key_column => 'entry_step_id'
       ,p_base_key_value  => p_step_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
         fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
         fnd_message.set_token('TABLE_NAME','all positions');
         hr_multi_message.add;
    End If;
    --
  End If;
  --
  hr_utility.set_location(' Leaving: ' || l_proc, 40);
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
  (p_rec                   in per_sps_shd.g_rec_type
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
    ,p_associated_column1 => per_sps_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');

  --
  -- Check step id
  --
  chk_step_id
    ( p_step_id                => p_rec.step_id
     ,p_object_version_number  => p_rec.object_version_number
     ,p_effective_date         => p_effective_date
    );
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

  hr_utility.set_location(l_proc, 20);

  --
  -- check spinal point id
  --
  chk_spinal_point_id
    (p_step_id                 => p_rec.step_id
    ,p_spinal_point_id         => p_rec.spinal_point_id
    ,p_grade_spine_id          => p_rec.grade_spine_id
    ,p_business_group_id       => p_rec.business_group_id
    ,p_object_version_number   => p_rec.object_version_number
    ,p_effective_date          => p_effective_date
  );

  hr_utility.set_location(l_proc, 30);

  --
  -- Check grade spine id
  --
  chk_grade_spine_id
    (p_step_id                => p_rec.step_id
    ,p_grade_spine_id         => p_rec.grade_spine_id
    ,p_business_group_id      => p_rec.business_group_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date
   );

  hr_utility.set_location(l_proc, 40);

  --
  -- Check sequence
  --
  chk_sequence
    (p_step_id                => p_rec.step_id
    ,p_sequence               => p_rec.sequence
    ,p_spinal_point_id        => p_rec.spinal_point_id
    ,p_business_group_id      => p_rec.business_group_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date
  );

  hr_utility.set_location(l_proc, 50);

  --
  -- Check the combination of spinal point id and grade spine id
  --
  chk_uniq_step_points
    (p_step_id                => p_rec.step_id
    ,p_spinal_point_id        => p_rec.spinal_point_id
    ,p_grade_spine_id         => p_rec.grade_spine_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date
  );

  hr_utility.set_location(l_proc, 60);

  per_sps_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in per_sps_shd.g_rec_type
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
    ,p_associated_column1 => per_sps_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');

  --
  -- Check step id
  --
  chk_step_id
    ( p_step_id                => p_rec.step_id
     ,p_object_version_number  => p_rec.object_version_number
     ,p_effective_date         => p_effective_date
    );

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
    (p_grade_spine_id                 => p_rec.grade_spine_id
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );

  hr_utility.set_location(l_proc, 20);

  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  --

  hr_utility.set_location(l_proc, 30);

  --
  -- check spinal point id
  --
  chk_spinal_point_id
    (p_step_id                 => p_rec.step_id
    ,p_spinal_point_id         => p_rec.spinal_point_id
    ,p_grade_spine_id          => p_rec.grade_spine_id
    ,p_business_group_id       => p_rec.business_group_id
    ,p_object_version_number   => p_rec.object_version_number
    ,p_effective_date          => p_effective_date
  );

  hr_utility.set_location(l_proc, 40);

  --
  -- Check grade spine id
  --
  chk_grade_spine_id
    (p_step_id                => p_rec.step_id
    ,p_grade_spine_id         => p_rec.grade_spine_id
    ,p_business_group_id      => p_rec.business_group_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date
   );

  hr_utility.set_location(l_proc, 50);

  --
  -- Check sequence
  --
  chk_sequence
    (p_step_id                => p_rec.step_id
    ,p_sequence               => p_rec.sequence
    ,p_spinal_point_id        => p_rec.spinal_point_id
    ,p_business_group_id      => p_rec.business_group_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date
  );

  hr_utility.set_location(l_proc, 60);

  --
  -- Check the combination of spinal point id and grade spine id
  --
  chk_uniq_step_points
    (p_step_id                => p_rec.step_id
    ,p_spinal_point_id        => p_rec.spinal_point_id
    ,p_grade_spine_id         => p_rec.grade_spine_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_effective_date         => p_effective_date
  );

  hr_utility.set_location(l_proc, 70);

  per_sps_bus.chk_ddf(p_rec);
  --

  hr_utility.set_location(' Leaving:'||l_proc, 80);

End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in per_sps_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ,p_called_from_del_grd_scale  in boolean  --bug 4096238
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_step_id                          => p_rec.step_id
    );
  --
  hr_utility.set_location(l_proc, 20);

  chk_delete
    (p_step_id              => p_rec.step_id
    ,p_spinal_point_id      => p_rec.spinal_point_id
    ,p_grade_spine_id       => p_rec.grade_spine_id
    ,p_effective_date       => p_effective_date
    ,p_datetrack_mode       => p_datetrack_mode
    ,p_called_from_del_grd_scale  => p_called_from_del_grd_scale -- bug 4096238
    );

  hr_utility.set_location(' Leaving:'||l_proc, 30);
End delete_validate;
--
end per_sps_bus;

/
