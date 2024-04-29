--------------------------------------------------------
--  DDL for Package Body BEN_XRD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XRD_BUS" as
/* $Header: bexrdrhi.pkb 120.1 2006/02/06 11:28:36 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xrd_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_ext_rslt_dtl_id >------|
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
--   ext_rslt_dtl_id PK of record being inserted or updated.
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
Procedure chk_ext_rslt_dtl_id(p_ext_rslt_dtl_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_rslt_dtl_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xrd_shd.api_updating
    (p_ext_rslt_dtl_id                => p_ext_rslt_dtl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_rslt_dtl_id,hr_api.g_number)
     <>  ben_xrd_shd.g_old_rec.ext_rslt_dtl_id) then
    --
    -- raise error as PK has changed
    --
    ben_xrd_shd.constraint_error('BEN_EXT_RSLT_DTL_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ext_rslt_dtl_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_xrd_shd.constraint_error('BEN_EXT_RSLT_DTL_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ext_rslt_dtl_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_person_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_ext_rslt_dtl_id PK
--   p_person_id ID of FK column
--   p_effective_date Session Date of record
--   p_object_version_number object version number
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
Procedure chk_person_id (p_ext_rslt_dtl_id          in number,
                            p_person_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_person_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_all_people_f a
    where  a.person_id = p_person_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_xrd_shd.api_updating
     (p_ext_rslt_dtl_id            => p_ext_rslt_dtl_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_person_id,hr_api.g_number)
     <> nvl(ben_xrd_shd.g_old_rec.person_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if person_id value exists in per_all_people_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_all_people_f
        -- table.
        --
        ben_xrd_shd.constraint_error('BEN_EXT_RSLT_DTL_DT1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_person_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ext_rcd_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_ext_rslt_dtl_id PK
--   p_ext_rcd_id ID of FK column
--   p_object_version_number object version number
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
Procedure chk_ext_rcd_id (p_ext_rslt_dtl_id          in number,
                            p_ext_rcd_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_rcd_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ext_rcd a
    where  a.ext_rcd_id = p_ext_rcd_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_xrd_shd.api_updating
     (p_ext_rslt_dtl_id            => p_ext_rslt_dtl_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_rcd_id,hr_api.g_number)
     <> nvl(ben_xrd_shd.g_old_rec.ext_rcd_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if ext_rcd_id value exists in ben_ext_rcd table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_ext_rcd
        -- table.
        --
        ben_xrd_shd.constraint_error('BEN_EXT_RSLT_DTL_FK3');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ext_rcd_id;





Procedure chk_ext_rcd_in_file_id (p_ext_rslt_dtl_id       in number,
                                  p_ext_rcd_in_file_id    in number,
                                  p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_rcd_in_file_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ext_rcd_in_file a
    where  a.ext_rcd_in_file_id = p_ext_rcd_in_file_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_xrd_shd.api_updating
     (p_ext_rslt_dtl_id            => p_ext_rslt_dtl_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_rcd_in_file_id,hr_api.g_number)
     <> nvl(ben_xrd_shd.g_old_rec.ext_rcd_in_file_id,hr_api.g_number)
     or not l_api_updating) and p_ext_rcd_in_file_id is not null  then
    --
    -- check if ext_rcd_id value exists in ben_ext_rcd table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_ext_rcd
        -- table.
    --
        ben_xrd_shd.constraint_error('BEN_EXT_RSLT_DTL_FK3');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ext_rcd_in_file_id;



--
-- ----------------------------------------------------------------------------
-- |------< chk_ext_rslt_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_ext_rslt_dtl_id PK
--   p_ext_rslt_id ID of FK column
--   p_object_version_number object version number
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
Procedure chk_ext_rslt_id (p_ext_rslt_dtl_id          in number,
                            p_ext_rslt_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_rslt_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ext_rslt a
    where  a.ext_rslt_id = p_ext_rslt_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_xrd_shd.api_updating
     (p_ext_rslt_dtl_id            => p_ext_rslt_dtl_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_rslt_id,hr_api.g_number)
     <> nvl(ben_xrd_shd.g_old_rec.ext_rslt_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if ext_rslt_id value exists in ben_ext_rslt table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_ext_rslt
        -- table.
        --
        ben_xrd_shd.constraint_error('BEN_EXT_RSLT_DTL_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ext_rslt_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_xrd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  if p_rec.ext_per_bg_id is not null then
     hr_api.validate_bus_grp_id(p_rec.ext_per_bg_id);  -- Validate Bus Grp
  end if ;

  chk_ext_rslt_dtl_id
  (p_ext_rslt_dtl_id          => p_rec.ext_rslt_dtl_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_rcd_id
  (p_ext_rslt_dtl_id          => p_rec.ext_rslt_dtl_id,
   p_ext_rcd_id          => p_rec.ext_rcd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_rslt_id
  (p_ext_rslt_dtl_id          => p_rec.ext_rslt_dtl_id,
   p_ext_rslt_id          => p_rec.ext_rslt_id,
   p_object_version_number => p_rec.object_version_number);
  --

  chk_ext_rcd_in_file_id
  (p_ext_rslt_dtl_id          => p_rec.ext_rslt_dtl_id,
   p_ext_rcd_in_file_id       => p_rec.ext_rcd_in_file_id,
   p_object_version_number => p_rec.object_version_number);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_xrd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  if p_rec.ext_per_bg_id is not null then
     hr_api.validate_bus_grp_id(p_rec.ext_per_bg_id);  -- Validate Bus Grp
  end if ;
  --
  chk_ext_rslt_dtl_id
  (p_ext_rslt_dtl_id          => p_rec.ext_rslt_dtl_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_rcd_id
  (p_ext_rslt_dtl_id          => p_rec.ext_rslt_dtl_id,
   p_ext_rcd_id          => p_rec.ext_rcd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_rslt_id
  (p_ext_rslt_dtl_id          => p_rec.ext_rslt_dtl_id,
   p_ext_rslt_id          => p_rec.ext_rslt_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_rcd_in_file_id
  (p_ext_rslt_dtl_id          => p_rec.ext_rslt_dtl_id,
   p_ext_rcd_in_file_id       => p_rec.ext_rcd_in_file_id,
   p_object_version_number => p_rec.object_version_number);

  hr_utility.set_location(' Leaving:'||l_proc, 10);

End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_xrd_shd.g_rec_type) is
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
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_ext_rslt_dtl_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ext_rslt_dtl b
    where b.ext_rslt_dtl_id      = p_ext_rslt_dtl_id
    and   a.business_group_id = b.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  per_business_groups.legislation_code%type ;
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'ext_rslt_dtl_id',
                             p_argument_value => p_ext_rslt_dtl_id);
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
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
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
end ben_xrd_bus;

/
