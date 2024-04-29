--------------------------------------------------------
--  DDL for Package Body BEN_EIV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EIV_BUS" as
/* $Header: beeivrhi.pkb 115.4 2002/12/22 20:25:28 pabodla noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_eiv_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_extra_input_value_id        number         default null;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_extra_input_value_id                 in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , ben_extra_input_values eiv
     where eiv.extra_input_value_id = p_extra_input_value_id
       and pbg.business_group_id = eiv.business_group_id;
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
    ,p_argument           => 'extra_input_value_id'
    ,p_argument_value     => p_extra_input_value_id
    );
  --
  if ( nvl(ben_eiv_bus.g_extra_input_value_id, hr_api.g_number)
       = p_extra_input_value_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ben_eiv_bus.g_legislation_code;
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
    ben_eiv_bus.g_extra_input_value_id        := p_extra_input_value_id;
    ben_eiv_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ---------------------------------------------------------------------------
-- |------------------------< chk_inp_val_unique >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that the input value is unique
--   within acty_base_rt_id
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_extra_input_value_id is extra_input_value_id
--     p_acty_base_rt_id is acty_base_rt_id
--     p_input_value_id is input_value_id
--
-- Post Success
--   Processing continues
--
-- Post Failureccess Status
--   Internal table handler use only.
--
-- ----------------------------------------------------------------------------
Procedure chk_inp_val_unique
          ( p_extra_input_value_id in   number
           ,p_acty_base_rt_id      in   number
           ,p_input_value_id       in   number
           ,p_object_version_number in   number
          )
is
l_proc      varchar2(72) := g_package||'chk_inp_val_unique';
l_api_updating boolean;
l_dummy    char(1);
cursor c1 is select null
             from   ben_extra_input_values
             Where  extra_input_value_id <> nvl(p_extra_input_value_id,-1)
             and    acty_base_rt_id = p_acty_base_rt_id
             and    input_value_id = p_input_value_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_eiv_shd.api_updating
    (p_extra_input_value_id        => p_extra_input_value_id,
     p_object_version_number       => p_object_version_number);

  if (l_api_updating
     and nvl(p_input_value_id,hr_api.g_number)
     <>  ben_eiv_shd.g_old_rec.input_value_id
     or not l_api_updating) then

     open c1;
     fetch c1 into l_dummy;
     if c1%found then
         close c1;
         fnd_message.set_name('BEN','BEN_93186_INP_VAL_NOT_UNIQUE');
         fnd_message.raise_error;
     end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_inp_val_unique;
--
-- ---------------------------------------------------------------------------
-- |------------------------< chk_rl_exists >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that the input value is unique
--   within acty_base_rt_id
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_extra_input_value_id is extra_input_value_id
--     p_acty_base_rt_id is acty_base_rt_id
--     p_input_value_id is input_value_id
--
-- Post Success
--   Processing continues
--
-- Post Failureccess Status
--   Internal table handler use only.
--
-- ----------------------------------------------------------------------------
Procedure chk_rl_exists
          ( p_acty_base_rt_id      in   number
          , p_effective_date       in   date
           )
is
l_proc      varchar2(72) := g_package||'chk_rl_exists';
l_input_va_calc_rl  number(15);

cursor c1 is select input_va_calc_rl
             from   ben_acty_base_rt_f
             Where  acty_base_rt_id = p_acty_base_rt_id
               and  p_effective_date between
                       effective_start_date and effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into l_input_va_calc_rl;
  close c1;

  if (l_input_va_calc_rl is null)
  then
     fnd_message.set_name('BEN','BEN_93187_INP_VAL_NOT_ALLOWED');
     fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_rl_exists;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in ben_eiv_shd.g_rec_type
  ,p_effective_date               in date
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id);
  --
  -- Check If RL exists on Rate
  chk_rl_exists
    (
     p_rec.acty_base_rt_id,
     p_effective_date
     );
  --
  -- Check Input Value Id for duplicates
  --
  chk_inp_val_unique
    ( p_rec.extra_input_value_id
     ,p_rec.acty_base_rt_id
     ,p_rec.input_value_id
     ,p_rec.object_version_number
     );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in ben_eiv_shd.g_rec_type
  ,p_effective_date               in date
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id );
  --
  -- Check Input Value Id for duplicates
  --
  chk_inp_val_unique
    ( p_rec.extra_input_value_id
     ,p_rec.acty_base_rt_id
     ,p_rec.input_value_id
     ,p_rec.object_version_number
     );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ben_eiv_shd.g_rec_type
  ,p_effective_date               in date
  ) is
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
end ben_eiv_bus;

/
