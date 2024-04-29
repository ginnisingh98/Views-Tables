--------------------------------------------------------
--  DDL for Package Body PAY_RTT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RTT_BUS" as
/* $Header: pyrttrhi.pkb 115.4 2003/02/06 17:21:56 rthirlby noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_rtt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_run_type_id                 number         default null;
g_language                    varchar2(4)    default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
/* There are no lookups on this table so this procedure is not required */
Procedure set_security_group_id
  (p_run_type_id                          in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_run_types_f_tl rtt
     where rtt.run_type_id = p_run_type_id;
      -- and pbg.business_group_id = business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
/*
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'run_type_id'
    ,p_argument_value     => p_run_type_id
    );
  --
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
*/
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_run_type_id                          in     number
  ,p_language                             in     varchar2
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- pay_run_types_f_tl and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , pay_run_types_f_tl rtt
      --   , EDIT_HERE table_name(s) 333
     where rtt.run_type_id = p_run_type_id
       and rtt.language = p_language;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
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
    ,p_argument           => 'run_type_id'
    ,p_argument_value     => p_run_type_id
    );
  --
  --
  if (( nvl(pay_rtt_bus.g_run_type_id, hr_api.g_number)
       = p_run_type_id)
  and ( nvl(pay_rtt_bus.g_language, hr_api.g_varchar2)
       = p_language)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_rtt_bus.g_legislation_code;
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
    pay_rtt_bus.g_run_type_id       := p_run_type_id;
    pay_rtt_bus.g_language          := p_language;
    pay_rtt_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in pay_rtt_shd.g_rec_type
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
  IF NOT pay_rtt_shd.api_updating
      (p_run_type_id                          => p_rec.run_type_id
      ,p_language                             => p_rec.language
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- RET 12-DEC-2001 making run_type_name non-updateable as is the key
  -- for uploading ldts.
  -- RET 05-FEB-2003 making run_type_name updateable, only the base table
  -- should be non updateable.
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_run_type_id >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The surrogate key, run_type_id must exist on the non-translated table
--   pay_run_types_f.
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
--   Processing continues if the run_type_id exist on the non-translated table
--   pay_run_types_f.
--
-- Post Failure:
--   An application error is raised if run_type_id does not exist on
--   pay_run_types_f.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_run_type_id
  (p_run_type_id in number) IS
--
  CURSOR csr_chk_rt_id
  IS
  SELECT prt.run_type_id
  FROM   pay_run_types_f prt
  WHERE  prt.run_type_id = p_run_type_id;
  --
  l_proc varchar2(72) := g_package || 'chk_run_type_id';
  l_error    EXCEPTION;
  l_argument varchar2(30);
  l_rt_id    number;
--
Begin
--
hr_utility.trace('l_rt_id is: '||to_char(p_run_type_id));
  OPEN  csr_chk_rt_id;
  FETCH csr_chk_rt_id into l_rt_id;
  IF csr_chk_rt_id%NOTFOUND THEN
  --
    CLOSE csr_chk_rt_id;
    hr_utility.set_message(801, 'HR_33999_RTT_INV_ID');
    hr_utility.raise_error;
  END IF;
  CLOSE csr_chk_rt_id;
  --
END chk_run_type_id;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_tl_run_type_name >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The run_type_name must be unique within a language
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
--   Processing continues if the run_type_id exist on the non-translated table
--   pay_run_types_f.
--
-- Post Failure:
--   An application error is raised if run_type_id does not exist on
--   pay_run_types_f.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_tl_run_type_name
  (p_run_type_id       in number
  ,p_language          in varchar2
  ,p_run_type_name     in varchar2) IS
--
  l_proc  varchar2(72) := g_package||'chk_tl_run_type_name';
--
-- cursor to get non-translated table bg and leg code
--
CURSOR get_startup_data
is
select business_group_id
,      legislation_code
from   pay_run_types_f
where  run_type_id = p_run_type_id;
--
CURSOR csr_tl_name_exists(p_bus_grp_id number
                         ,p_leg_code   varchar2)
is
select 'Y'
from   pay_run_types_f prt
,    pay_run_types_f_tl rtt
where prt.run_type_id = rtt.run_type_id
and   rtt.language = p_language
and  upper(p_run_type_name) = upper(rtt.run_type_name)
and   (prt.run_type_id <> p_run_type_id
       or p_run_type_id is null)
and   (p_bus_grp_id = prt.business_group_id + 0
      or (prt.business_group_id is null
          and (p_leg_code = prt.legislation_code
               or prt.legislation_code is null)));
--
l_bg_id    number;
l_leg_code varchar2(10);
l_exists   varchar2(10);
--
BEGIN
hr_utility.set_location('Entering: '||l_proc,5);
--
-- Only need to opent the cursor if run_type_name is not null
--
  if p_run_type_name is not null then
  hr_utility.set_location(l_proc, 10);
  --
  OPEN  get_startup_data;
  FETCH get_startup_data into l_bg_id, l_leg_code;
  CLOSE get_startup_data;
  --
    OPEN  csr_tl_name_exists(l_bg_id, l_leg_code);
    FETCH csr_tl_name_exists into l_exists;
    IF csr_tl_name_exists%FOUND THEN
    --
      hr_utility.set_message(801,'HR_33998_RTT_DUP_NAME');
      hr_utility.raise_error;
    END IF;
    hr_utility.set_location(l_proc, 15);
    CLOSE csr_tl_name_exists;
  end if;
hr_utility.set_location('Leaving: '||l_proc, 20);
end chk_tl_run_type_name;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in pay_rtt_shd.g_rec_type
  ,p_run_type_id                  in number
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  chk_run_type_id(p_run_type_id => p_run_type_id);
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_tl_run_type_name(p_run_type_id       => p_rec.run_type_id
                      ,p_language          => p_rec.language
                      ,p_run_type_name     => p_rec.run_type_name);
  --
  hr_utility.set_location(l_proc, 15);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in pay_rtt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_run_type_id(p_run_type_id => p_rec.run_type_id);
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- RET 12-DEC-2001 removed as run_type_name is no longer updateable. Made this
  -- change as run type name is the key for uploading run types via the ldt.
  --
/*
  chk_tl_run_type_name(p_run_type_id       => p_rec.run_type_id
                      ,p_language          => p_rec.language
                      ,p_run_type_name     => p_rec.run_type_name);
*/
  --
  hr_utility.set_location(l_proc, 15);
  --
  hr_utility.set_location(l_proc, 20);
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 25);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_rtt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_run_type_id(p_run_type_id => p_rec.run_type_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_rtt_bus;

/
