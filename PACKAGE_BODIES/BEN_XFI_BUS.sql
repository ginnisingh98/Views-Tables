--------------------------------------------------------
--  DDL for Package Body BEN_XFI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XFI_BUS" as
/* $Header: bexfirhi.pkb 120.0 2005/05/28 12:33:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xfi_bus.';  -- Global package name
g_legislation_code  varchar2(30) := NULL;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_ext_file_id                in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , ben_ext_file xfi
     where xfi.ext_file_id = p_ext_file_id
       and pbg.business_group_id = xfi.business_group_id;
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
    ,p_argument           => 'ext_file_id'
    ,p_argument_value     => p_ext_file_id
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
--
-- ----------------------------------------------------------------------------
-- |------< chk_ext_file_id >------|
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
--   ext_file_id PK of record being inserted or updated.
--   object_version_number Object version number of record being
--                         inserted or updated.
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
Procedure chk_ext_file_id(p_ext_file_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_file_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xfi_shd.api_updating
    (p_ext_file_id                => p_ext_file_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_file_id,hr_api.g_number)
     <>  ben_xfi_shd.g_old_rec.ext_file_id) then
    --
    -- raise error as PK has changed
    --
    ben_xfi_shd.constraint_error('BEN_EXT_FILE_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ext_file_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_xfi_shd.constraint_error('BEN_EXT_FILE_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ext_file_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_name_unique >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that an extract file must have a name and not two extract file have the same name
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_name is extract name
--     p_ext_file_id is extract file id
--     p_business_group_id
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
-- ----------------------------------------------------------------------------
Procedure chk_name_unique
          (p_ext_file_id          in     number
          ,p_name                 in     varchar2
          ,p_business_group_id    in     number
          ,p_legislation_code     in     varchar2)
is
l_proc	    varchar2(72) := g_package||'chk_name_unique';
l_dummy    char(1);
cursor c1 is select null
               from ben_ext_file
              Where ext_file_id <> nvl(p_ext_file_id,-1)
                and name = p_name
                and ( (business_group_id is null -- is global
                       and legislation_code is null
                      )
                     or -- is legilsation specific and not bg  specific
                      (legislation_code is not null
                       and business_group_id is null
                       and legislation_code = p_legislation_code)
                     or -- is business group specific
                      (business_group_id is not null
                       and business_group_id = p_business_group_id)
                    )
;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_name is null then
      fnd_message.set_name('BEN','BEN_91783_NAME_NULL');
      fnd_message.raise_error;
  end if;
  open c1;
  fetch c1 into l_dummy;
  if c1%found then
      close c1;
      fnd_message.set_name('BEN','BEN_91009_NAME_NOT_UNIQUE');
      fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_name_unique;
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
  --
  IF (p_insert) THEN
    --
    -- Call procedure to check startup_action for inserts.
    --
    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
    --
    -- Call procedure to check startup_action for updates and deletes.
    --
    hr_startup_data_api_support.chk_upd_del_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  END IF;
  --
END chk_startup_action;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_xfi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_startup_action(True
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code);
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
     hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate bus_grp
  END IF;
  --
  chk_ext_file_id
  (p_ext_file_id          => p_rec.ext_file_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name_unique
  (p_ext_file_id         => p_rec.ext_file_id,
  p_name                 => p_rec.name,
  p_business_group_id    => p_rec.business_group_id,
  p_legislation_code     => p_rec.legislation_code);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_xfi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_startup_action(False
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code);
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
     hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate bus_grp
  END IF;
  --
  chk_ext_file_id
  (p_ext_file_id          => p_rec.ext_file_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name_unique
  (p_ext_file_id         => p_rec.ext_file_id,
  p_name                 => p_rec.name,
  p_business_group_id    => p_rec.business_group_id,
  p_legislation_code     => p_rec.legislation_code);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_xfi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_startup_action(False
                    ,ben_xfi_shd.g_old_rec.business_group_id
                    ,ben_xfi_shd.g_old_rec.legislation_code);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_ext_file_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ext_file b
    where b.ext_file_id      = p_ext_file_id
    and   a.business_group_id(+) = b.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'ext_file_id',
                             p_argument_value => p_ext_file_id);
  --
  open csr_leg_code;
    --
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      close csr_leg_code;
      --
      -- The primary key is invalid therefore we must error
      --
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
      --
    end if;
    --
  close csr_leg_code;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
  --
end return_legislation_code;
--
end ben_xfi_bus;

/
