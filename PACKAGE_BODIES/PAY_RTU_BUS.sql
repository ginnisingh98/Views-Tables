--------------------------------------------------------
--  DDL for Package Body PAY_RTU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RTU_BUS" as
/* $Header: pyrturhi.pkb 115.3 2002/12/09 15:08:35 divicker noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_rtu_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_run_type_usage_id           number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_run_type_usage_id                    in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_run_type_usages_f rtu
     where rtu.run_type_usage_id = p_run_type_usage_id
       and pbg.business_group_id = rtu.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'run_type_usage_id'
    ,p_argument_value     => p_run_type_usage_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     fnd_message.raise_error;
     --
  end if;
  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );
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
  (p_run_type_usage_id                    in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_run_type_usages_f rtu
     where rtu.run_type_usage_id = p_run_type_usage_id
       and pbg.business_group_id (+) = rtu.business_group_id;
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
    ,p_argument           => 'run_type_usage_id'
    ,p_argument_value     => p_run_type_usage_id
    );
  --
  if ( nvl(pay_rtu_bus.g_run_type_usage_id, hr_api.g_number)
       = p_run_type_usage_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_rtu_bus.g_legislation_code;
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
    pay_rtu_bus.g_run_type_usage_id := p_run_type_usage_id;
    pay_rtu_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  ,p_rec             in pay_rtu_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_rtu_shd.api_updating
      (p_run_type_usage_id                => p_rec.run_type_usage_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc, 10);
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_rtu_shd.g_old_rec.business_group_id, hr_api.g_number) then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 15);
  --
  if p_rec.run_type_usage_id <> pay_rtu_shd.g_old_rec.run_type_usage_id then
     l_argument := 'run_type_usage_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 20);
  --
  if p_rec.legislation_code <> pay_rtu_shd.g_old_rec.legislation_code then
     l_argument := 'legislation_code';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 25);
  --
  if p_rec.parent_run_type_id <> pay_rtu_shd.g_old_rec.parent_run_type_id then
     l_argument := 'parent_run_type_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  if p_rec.child_run_type_id <> pay_rtu_shd.g_old_rec.child_run_type_id then
     l_argument := 'child_run_type_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 35);
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
End chk_non_updateable_args;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_parent_run_type_id >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks the validity of the parent_run_type_id enterend by carrying out
--    the following:
--      - check that the parent_run_type_id exists
--      - check that the parent_run_type_id has a run_method = C
--      - check that the following rules apply:
--
--    Mode     Run Type     Available Components             Resulting usage
--    ------   -----------  -------------------------------  ---------------
--    USER     USER         USER, STARTUP, GENERIC           USER
--    USER     STARTUP      This mode cannot enter usages    Error
--                          for STARTUP run types
--    USER     GENERIC      This mode cannot enter usages    Error
--                          for GENERIC run types
--    STARTUP  USER         This mode cannot access USER     Error
--                          run types
--    STARTUP  STARTUP      STARTUP, GENERIC                 STARTUP
--    STARTUP  GENERIC      This mode cannot enter usages    Error
--                          for GENERIC run types
--    GENERIC  USER         This mode cannot access USER     Error
--                          run types
--    GENERIC  STARTUP      This mode cannot access STARTUP  Error
--                          run types
--    GENERIC  GENERIC      GENERIC                          GENERIC
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_run_type_usage_id
--    p_parent_run_type_id
--    p_business_group_id
--    p_legislation_code
--
--  Post Success:
--    If the parent_run_type_id is valid then processing continues
--
--  Post Failure:
--    If any of the following cases are true then an application error will be
--    raised and processing is terminated:
--
--     a) parent_run_type_id does not exist
--     b) run_method of parent_run_type_id is not C
--
--  Access Status:
--   Internal Row Handler Use Only.
--
--  ---------------------------------------------------------------------------
PROCEDURE chk_parent_run_type_id
  (p_run_type_usage_id     in number
  ,p_parent_run_type_id    in number
  ,p_effective_date        in date
  ,p_business_group_id     in number
  ,p_legislation_code      in varchar2) is
--
l_exists  varchar2(1);
l_proc    varchar2(72) := g_package||'chk_parent_run_type_id';
--
CURSOR csr_chk_valid_parent
is
select 'Y'
from   pay_run_types_f prt
where  prt.run_type_id = p_parent_run_type_id
and    prt.run_method = 'C'
and    p_effective_date between prt.effective_start_date
                            and prt.effective_end_date
and   ((p_business_group_id is not null
       and prt.business_group_id = p_business_group_id)
      or (p_business_group_id is null
       and prt.business_group_id is null))
and   ((p_legislation_code is not null
       and prt.legislation_code = p_legislation_code)
      or (p_legislation_code is null
       and prt.legislation_code is null));
--
l_mode varchar2(10);
BEGIN
--
hr_utility.set_location('Entering: '|| l_proc, 5);
--
-- Only execute the cursor if absolutely necessary.
-- a) During update, the parent_run_type_id has actually changed to another not
--    null value, i,e, the value passed to this procedure is different to the
--    g_old_rec value.
-- b) During insert, the parent_run_type_id is null.
-- Can tell the difference between insert and update by looking at the
-- primary key value. For update it will be not null. For insert it will be
-- null, because pre_inset has not been called yet.
--
IF (((p_run_type_usage_id is not null) and
      nvl(pay_rtu_shd.g_old_rec.parent_run_type_id, hr_api.g_number) <>
      nvl(p_parent_run_type_id, hr_api.g_number))
   or
     (p_run_type_usage_id is null)) then
     --
     hr_utility.set_location(l_proc, 10);
     --
     -- Only need to open the cursor if parent_run_type_id is not null
     --
     if p_parent_run_type_id is not null then
     --
       IF p_business_group_id is NULL THEN
         IF p_legislation_code is NULL THEN
         --
         -- If business_group and legislation code are not null then must
         -- be in GENERIC mode, check by calling:
         --
           if hr_startup_data_api_support.g_startup_mode = 'GENERIC' THEN
           hr_utility.set_location(l_proc, 15);
           --
             OPEN csr_chk_valid_parent;
             FETCH csr_chk_valid_parent INTO l_exists;
             IF csr_chk_valid_parent%NOTFOUND THEN
             --
               CLOSE csr_chk_valid_parent;
               -- parent run type does not exist
               hr_utility.set_message(801, 'HR_33593_RTU_INV_P_RT');
               hr_utility.raise_error;
               --
             END IF;
             CLOSE csr_chk_valid_parent;
           end if; -- if generic
           --
         ELSE
         hr_utility.set_location(l_proc, 20);
         --
         -- If business_group_id is null, and legislation code is not null,
         -- then must be in STRATUP mode, check by calling:
         --
           if hr_startup_data_api_support.g_startup_mode = 'STARTUP' THEN
           hr_utility.set_location(l_proc, 25);
           --
             OPEN  csr_chk_valid_parent;
             FETCH csr_chk_valid_parent INTO l_exists;
             IF csr_chk_valid_parent%NOTFOUND THEN
             --
               CLOSE csr_chk_valid_parent;
               -- parent run type_id does not exist
               hr_utility.set_message(801, 'HR_33593_RTU_INV_P_RT');
               hr_utility.raise_error;
             END IF;
             CLOSE csr_chk_valid_parent;
           end if; -- if STARTUP
           --
         END IF; -- if p_legislation_code is null
       ELSE -- if p_business_group_id is null
       --
         if p_legislation_code is null then
         --
         -- If business_group is not null, and legislation code is null then
         -- must be in USER mode, check by calling:
         --
         if hr_startup_data_api_support.g_startup_mode = 'USER' then
         hr_utility.set_location(l_proc, 30);
         --
           OPEN  csr_chk_valid_parent;
           FETCH csr_chk_valid_parent INTO l_exists;
           IF csr_chk_valid_parent%NOTFOUND THEN
           --
             CLOSE csr_chk_valid_parent;
             -- parent run type does not exist
             hr_utility.set_message(801, 'HR_33593_RTU_INV_P_RT');
             hr_utility.raise_error;
           END IF;
           CLOSE csr_chk_valid_parent;
           --
         end if; -- if USER
         else -- p_legislation_code is not null
         -- legislaiton_code cannot be NOT NULL in USER mode
           hr_utility.set_message(801, 'HR_33594_RTU_INV_P_LEG');
           hr_utility.raise_error;
         end if;
       END IF;
       hr_utility.set_location(l_proc, 35);
    end if;
    hr_utility.set_location(l_proc, 40);
end if;
hr_utility.set_location('Leaving: '||l_proc, 45);
END chk_parent_run_type_id;
--  ---------------------------------------------------------------------------
--  |------------------------< chk_child_run_type_id >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks the validity of the child_run_type_id enterend by carrying out
--    the following:
--      - check that the child_run_type_id exists
--      - check that the following rules apply:
--
--    Mode     Run Type     Available Components             Resulting usage
--    ------   -----------  -------------------------------  ---------------
--    USER     USER         USER, STARTUP, GENERIC           USER
--    USER     STARTUP      This mode cannot enter usages    Error
--                          for STARTUP run types
--    USER     GENERIC      This mode cannot enter usages    Error
--                          for GENERIC run types
--    STARTUP  USER         This mode cannot access USER     Error
--                          run types
--    STARTUP  STARTUP      STARTUP, GENERIC                 STARTUP
--    STARTUP  GENERIC      This mode cannot enter usages    Error
--                          for GENERIC run types
--    GENERIC  USER         This mode cannot access USER     Error
--                          run types
--    GENERIC  STARTUP      This mode cannot access STARTUP  Error
--                          run types
--    GENERIC  GENERIC      GENERIC                          GENERIC
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_child_run_type_id
--    p_business_group_id
--    p_legislation_code
--
--  Post Success:
--    If the child_run_type_id is valid then processing continues
--
--  Post Failure:
--    If any of the following cases are true then an application error will be
--    raised and processing is terminated:
--
--     a) child_run_type_id does not exist
--
--  Access Status:
--   Internal Row Handler Use Only.
--
--  ---------------------------------------------------------------------------
PROCEDURE chk_child_run_type_id
  (p_run_type_usage_id     in number
  ,p_child_run_type_id     in number
  ,p_parent_run_type_id    in number
  ,p_effective_date        in date
  ,p_business_group_id     in number
  ,p_legislation_code      in varchar2) is
--
l_exists  varchar2(1);
l_proc    varchar2(72) := g_package||'chk_child_run_type_id';
--
CURSOR csr_chk_valid_child
is
select prt.business_group_id
,      prt.legislation_code
,      prt.run_type_id
from   pay_run_types_f prt
where  prt.run_type_id = p_child_run_type_id
and    p_effective_date between prt.effective_start_date
                            and prt.effective_end_date;
--
CURSOR csr_usage_exists
is
select 'Y'
from   pay_run_type_usages_f rtu
where  rtu.parent_run_type_id = p_parent_run_type_id
and    rtu.child_run_type_id = p_child_run_type_id
and    p_effective_date between rtu.effective_start_date
                            and rtu.effective_end_date;
--
l_bg_id number;
l_leg_code varchar2(20);
l_rt_id number;
l_derived_leg varchar2(20);
--
BEGIN
--
hr_utility.set_location('Entering: '|| l_proc, 5);
-- Only execute the cursor if absolutely necessary.
-- a) During update, the child_run_type_id has actually changed to another not
--    null value, i,e, the value passed to this procedure is different to the
--    g_old_rec value.
-- b) During insert, the child_run_type_id is null.
-- Can tell the difference between insert and update by looking at the
-- primary key value. For update it will be not null. For insert it will be
-- null, because pre_inset has not been called yet.
--
IF (((p_run_type_usage_id is not null) and
      nvl(pay_rtu_shd.g_old_rec.child_run_type_id, hr_api.g_number) <>
      nvl(p_child_run_type_id, hr_api.g_number))
   or
     (p_run_type_usage_id is null)) then
     --
     hr_utility.set_location(l_proc, 10);
     --
     -- Only need to open the cursor if child_run_type_id is not null
     --
     if p_child_run_type_id is not null then
     --
     --
       IF p_business_group_id is NULL THEN
         hr_utility.set_location(l_proc, 15);
         --
         IF p_legislation_code is NULL THEN
         hr_utility.set_location(l_proc, 20);
         --
         -- If business group id and leg code are null, then we must be in
         -- GENERIC mode, check this by calling:
         --
           if hr_startup_data_api_support.g_startup_mode = 'GENERIC' then
           hr_utility.set_location(l_proc, 25);
           --
             OPEN  csr_chk_valid_child;
             FETCH csr_chk_valid_child INTO l_bg_id, l_leg_code, l_rt_id;
             IF csr_chk_valid_child%NOTFOUND THEN
             --
               CLOSE csr_chk_valid_child;
               -- invalid primary key error, child run type does not exist
               hr_utility.set_message(801, 'HR_33595_RTU_INV_C_RT');
               hr_utility.raise_error;
             END IF;
             CLOSE csr_chk_valid_child;
             --
             -- chk that this usage doesn't already exist
             --
             OPEN  csr_usage_exists;
             FETCH csr_usage_exists into l_exists;
             IF csr_usage_exists%FOUND THEN
             --
               CLOSE csr_usage_exists;
               -- usage already exists error
               hr_utility.set_message(801, 'HR_33596_RTU_EXISTS');
               hr_utility.raise_error;
             END IF;
             CLOSE csr_usage_exists;
             --
             -- if the child run type bg or leg code are not null then
             -- the child run type is NOT a GENERIC row, raise error.
             --
             if (l_bg_id is not null
                or l_leg_code is not null) then
                --
                -- child run type not of generic mode
                hr_utility.set_message(801, 'HR_33597_RTU_INV_C_RT_G');
                hr_utility.raise_error;
             end if;
             --
           end if; -- if GENERIC
           --
         ELSE -- p_legislation_code is not null
         hr_utility.set_location(l_proc, 30);
         --
         -- If business_group_id is null, and legislation_code is not null,
         -- we must be in STARTUP mode, check this by calling:
         --
           if hr_startup_data_api_support.g_startup_mode = 'STARTUP' then
           hr_utility.set_location(l_proc, 35);
           --
             OPEN  csr_chk_valid_child;
             FETCH csr_chk_valid_child INTO l_bg_id, l_leg_code, l_rt_id;
             IF csr_chk_valid_child%NOTFOUND THEN
             --
               CLOSE csr_chk_valid_child;
               -- child run type does not exist
               hr_utility.set_message(801, 'HR_33595_RTU_INV_C_RT');
               hr_utility.raise_error;
             END IF;
             CLOSE csr_chk_valid_child;
             --
             -- chk that this usage doesn't already exist
             --
             OPEN  csr_usage_exists;
             FETCH csr_usage_exists into l_exists;
             IF csr_usage_exists%FOUND THEN
             --
               CLOSE csr_usage_exists;
               -- usage already exists error
               hr_utility.set_message(801, 'HR_33596_RTU_EXISTS');
               hr_utility.raise_error;
             END IF;
             CLOSE csr_usage_exists;
             --
             -- If the bg of the child run type is not null, then the child
             -- run type is not a STARTUP row, so error.
             --
             if l_bg_id is not null then
               --
               hr_utility.set_message(801, 'HR_33598_RTU_INV_C_RT_S');
               hr_utility.raise_error;
               --
             elsif l_leg_code is not null then
             --
               if l_leg_code = p_legislation_code then
               --
                 hr_utility.trace ('valid startup child run type id');
               else
                 -- child run type leg code is not same as usage leg code
                 -- therefore is invalid
                 hr_utility.set_message(801, 'HR_33599_RTU_INV_LEG_S');
                 hr_utility.raise_error;
               end if;
             end if;
             --
           end if; -- if STARTUP
           --
         END IF; -- if p_legislation_code is null
         --
       ELSE -- p_business_group_id is not null
       hr_utility.set_location(l_proc, 40);
       --
         if p_legislation_code is null then
         --
         -- If business_group_id is NOT NULL and legislation code is null then
         -- we must be in USER mode, check this by calling:
         --
         if hr_startup_data_api_support.g_startup_mode = 'USER' then
         hr_utility.set_location(l_proc, 45);
         --
           OPEN  csr_chk_valid_child;
           FETCH csr_chk_valid_child INTO l_bg_id, l_leg_code, l_rt_id;
           IF csr_chk_valid_child%NOTFOUND THEN
           --
             CLOSE csr_chk_valid_child;
             -- child run type does not exist
             hr_utility.set_message(801, 'HR_33595_RTU_INV_C_RT');
             hr_utility.raise_error;
           END IF;
           CLOSE csr_chk_valid_child;
           --
           -- chk that this usage doesn't already exist
           --
           OPEN  csr_usage_exists;
           FETCH csr_usage_exists into l_exists;
           IF csr_usage_exists%FOUND THEN
           --
             CLOSE csr_usage_exists;
             -- usage already exists error
             hr_utility.set_message(801, 'HR_33596_RTU_EXISTS');
             hr_utility.raise_error;
           END IF;
           CLOSE csr_usage_exists;
           --
           if l_bg_id is not null then
             if l_bg_id = p_business_group_id then
             --
               hr_utility.trace('valid user child run type id');
               --
             else -- in USER mode so BG must not be null
               -- child run type bg is not same as usage bg, so invalid
               hr_utility.set_message(801, 'HR_33600_RTU_INV_BG');
               hr_utility.raise_error;
             end if;
           else -- l_bg_id is null
             if l_leg_code is NOT NULL then
             --
             -- As in USER mode p_legislation_code will be null, so need to get
             -- the legislation code.
             -- If p_run_type_usage_id is null i.e. this is an insert, need to
             -- get the legislation code for the parent run type id, which has
             -- already been validated in chk_parent_run_type.
             -- Else this is an update or delete, so use the rtu return leg
             -- code function
             --
               if p_run_type_usage_id is null then
                 l_derived_leg :=
                      pay_prt_bus.return_legislation_code(p_parent_run_type_id);
               else -- p_run_type_usage_id is not null
                 l_derived_leg :=
                      pay_rtu_bus.return_legislation_code(p_run_type_usage_id);
               end if;
               --
               if l_leg_code = l_derived_leg then
                 hr_utility.trace('valid user child run type id');
               else
                 hr_utility.set_message(801, 'HR_33995_RTU_INV_LEG_U');
                 hr_utility.raise_error;
               end if;
             end if; -- l_leg_code is not null
           end if; -- l_bg_is not null
         end if; -- if USER
         --
         ELSE -- leg_code is not null
         --
           hr_utility.set_message(801, 'HR_33993_RTU_INV_BG_LEG');
           hr_utility.raise_error;
           --
         END IF; -- leg code is null
         --
       END IF; -- p_business_group_id is null
       hr_utility.set_location(l_proc, 50);
     end if; -- p_child_run_type is null
     hr_utility.set_location(l_proc, 55);
END IF;
hr_utility.set_location('Leaving: '||l_proc, 60);
END chk_child_run_type_id;
--  ---------------------------------------------------------------------------
--  |-----------------------------< chk_sequence >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks the validity of the sequence enterend by carrying out the
--    following:
--      - check that the sequence is unique within a parent_run_type_id
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_run_type_usage_id
--    p_parent_run_type_id
--    p_sequence
--    p_effective_date
--
--  Post Success:
--    If the sequence is valid then processing continues
--
--  Post Failure:
--    If any of the following cases are true then an application error will be
--    raised and processing is terminated:
--
--     a) sequence is not unique within a run_type_usage_id
--
--  Access Status:
--   Internal Row Handler Use Only.
--
--  ---------------------------------------------------------------------------
PROCEDURE chk_sequence
  (p_run_type_usage_id  in number
  ,p_parent_run_type_id in number
  ,p_sequence           in number
  ,p_effective_date     in date) is
--
l_exists  varchar2(1);
l_proc    varchar2(72) := g_package||'chk_sequence';
--
CURSOR csr_chk_valid_sequence
is
select null
from   pay_run_type_usages_f rtu
where  rtu.parent_run_type_id = p_parent_run_type_id
and    rtu.sequence = p_sequence
and    p_effective_date between rtu.effective_start_date
                            and rtu.effective_end_date;
--
BEGIN
--
hr_utility.set_location('Entering: '|| l_proc, 5);
--
-- Only execute the cursor if absolutely necessary.
-- a) During update, the sequence has actually changed to another not
--    null value, i,e, the value passed to this procedure is different to the
--    g_old_rec value.
-- b) During insert, the sequence is null.
-- Can tell the difference between insert and update by looking at the
-- primary key value. For update it will be not null. For insert it will be
-- null, because pre_inset has not been called yet.
--
IF (((p_run_type_usage_id is not null) and
     nvl(pay_rtu_shd.g_old_rec.sequence, hr_api.g_number) <>
     nvl(p_sequence, hr_api.g_number))
   or
    (p_run_type_usage_id is null)) then
    --
      hr_utility.set_location(l_proc, 10);
      --
      -- Only need to opent the cursor if is not null
      --
      if p_sequence is not null then
      --
        OPEN  csr_chk_valid_sequence;
        FETCH csr_chk_valid_sequence INTO l_exists;
        IF csr_chk_valid_sequence%FOUND THEN
        --
          CLOSE csr_chk_valid_sequence;
          hr_utility.set_message(801, 'HR_33994_RTU_DUP_SEQUENCE');
          hr_utility.raise_error;
        END IF;
        CLOSE csr_chk_valid_sequence;
        --
      end if;
      hr_utility.set_location(l_proc, 15);
      --
END IF;
hr_utility.set_location('Leaving: '||l_proc, 20);
END chk_sequence;
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
  (p_parent_run_type_id            in number default hr_api.g_number
  ,p_child_run_type_id             in number default hr_api.g_number
  ,p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name      all_tables.table_name%TYPE;
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
  If ((nvl(p_parent_run_type_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'pay_run_types_f'
            ,p_base_key_column => 'RUN_TYPE_ID'
            ,p_base_key_value  => p_parent_run_type_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     l_table_name := 'run types';
     raise l_integrity_error;
  End If;
  If ((nvl(p_child_run_type_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'pay_run_types_f'
            ,p_base_key_column => 'RUN_TYPE_ID'
            ,p_base_key_value  => p_child_run_type_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     l_table_name := 'run types';
     raise l_integrity_error;
  End If;
  --
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
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
  (p_run_type_usage_id                in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
  l_table_name	all_tables.table_name%TYPE;
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
      ,p_argument       => 'run_type_usage_id'
      ,p_argument_value => p_run_type_usage_id
      );
    --
  --
    --
  End If;
  --
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
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
-- |----------------------< chk_startup_action >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that the current action is allowed according
--  to the current startup mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_startup_action
  (p_insert               IN boolean
  ,p_business_group_id    IN number
  ,p_legislation_code     IN varchar2
  ,p_legislation_subgroup IN varchar2 DEFAULT NULL) IS
--
BEGIN
  --
  -- Call the supporting procedure to check startup mode
  -- EDIT_HERE: The following call should be edited if certain types of rows
  -- are not permitted.
  IF (p_insert) THEN
  --
  -- Call procedure to check startup_action for inserts
  --
    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed      => TRUE
      ,p_startup_allowed      => TRUE
      ,p_user_allowed         => TRUE
      ,p_business_group_id    => p_business_group_id
      ,p_legislation_code     => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
     --
     -- Call procedure to check startup action for upd and del
     --
     hr_startup_data_api_support.chk_upd_del_startup_action
       (p_generic_allowed      => TRUE
       ,p_startup_allowed      => TRUE
       ,p_user_allowed         => TRUE
       ,p_business_group_id    => p_business_group_id
       ,p_legislation_code     => p_legislation_code
       ,p_legislation_subgroup => p_legislation_subgroup
       );
  END IF;
  --
END chk_startup_action;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pay_rtu_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
/* RET removed this call infavour or new chk_startup_action
  IF p_rec.business_group_id is not null THEN
  --
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
    --
  END IF;
*/
  chk_startup_action(true
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP')
    THEN
    hr_api.validate_bus_grp_id(p_rec.business_group_id); -- Validate bus_grp
  END IF;
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_parent_run_type_id
            (p_run_type_usage_id    => p_rec.run_type_usage_id
            ,p_parent_run_type_id   => p_rec.parent_run_type_id
            ,p_effective_date       => p_effective_date
            ,p_business_group_id    => p_rec.business_group_id
            ,p_legislation_code     => p_rec.legislation_code);
  --
  hr_utility.set_location(l_proc, 15);
  --
  chk_child_run_type_id
            (p_run_type_usage_id    => p_rec.run_type_usage_id
            ,p_child_run_type_id    => p_rec.child_run_type_id
            ,p_parent_run_type_id   => p_rec.parent_run_type_id
            ,p_effective_date       => p_effective_date
            ,p_business_group_id    => p_rec.business_group_id
            ,p_legislation_code     => p_rec.legislation_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  chk_sequence (p_run_type_usage_id  => p_rec.run_type_usage_id
               ,p_parent_run_type_id => p_rec.parent_run_type_id
               ,p_sequence           => p_rec.sequence
               ,p_effective_date     => p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 25);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_rtu_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc	varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
/* RET removed in favour of new chk_startup_data_api
  IF p_rec.business_group_id is not null THEN
  --
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
    --
  END IF;
*/
  chk_startup_action(false
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP')
    THEN
    hr_api.validate_bus_grp_id(p_rec.business_group_id); -- Validate bus_grp
  END IF;
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_parent_run_type_id
            (p_run_type_usage_id    => p_rec.run_type_usage_id
            ,p_parent_run_type_id   => p_rec.parent_run_type_id
            ,p_effective_date       => p_effective_date
            ,p_business_group_id    => p_rec.business_group_id
            ,p_legislation_code     => p_rec.legislation_code);
  --
  hr_utility.set_location(l_proc, 15);
  --
  chk_child_run_type_id
            (p_run_type_usage_id    => p_rec.run_type_usage_id
            ,p_child_run_type_id    => p_rec.child_run_type_id
            ,p_parent_run_type_id   => p_rec.parent_run_type_id
            ,p_effective_date       => p_effective_date
            ,p_business_group_id    => p_rec.business_group_id
            ,p_legislation_code     => p_rec.legislation_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  chk_sequence (p_run_type_usage_id  => p_rec.run_type_usage_id
               ,p_parent_run_type_id => p_rec.parent_run_type_id
               ,p_sequence           => p_rec.sequence
               ,p_effective_date     => p_effective_date);
  --
  hr_utility.set_location(l_proc, 25);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_parent_run_type_id             => p_rec.parent_run_type_id
    ,p_child_run_type_id              => p_rec.child_run_type_id
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  hr_utility.set_location(l_proc, 30);
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 35);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_rtu_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_startup_action(false
                    ,pay_rtu_shd.g_old_rec.business_group_id
                    ,pay_rtu_shd.g_old_rec.legislation_code
                    );
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_run_type_usage_id                => p_rec.run_type_usage_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_rtu_bus;

/
