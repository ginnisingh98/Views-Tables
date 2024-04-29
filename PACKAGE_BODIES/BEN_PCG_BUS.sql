--------------------------------------------------------
--  DDL for Package Body BEN_PCG_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PCG_BUS" as
/* $Header: bepcgrhi.pkb 115.8 2002/12/16 11:58:08 vsethi ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pcg_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_prtt_clm_gd_or_svc_typ_id >------|
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
--   prtt_clm_gd_or_svc_typ_id PK of record being inserted or updated.
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
Procedure chk_prtt_clm_gd_or_svc_typ_id
          (p_prtt_clm_gd_or_svc_typ_id   in number,
           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtt_clm_gd_or_svc_typ_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pcg_shd.api_updating
    (p_prtt_clm_gd_or_svc_typ_id                => p_prtt_clm_gd_or_svc_typ_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_prtt_clm_gd_or_svc_typ_id,hr_api.g_number)
     <>  ben_pcg_shd.g_old_rec.prtt_clm_gd_or_svc_typ_id) then
    --
    -- raise error as PK has changed
    --
    ben_pcg_shd.constraint_error('BEN_PRTT_CLM_GD_OR_SVC_TYP_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_prtt_clm_gd_or_svc_typ_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_pcg_shd.constraint_error('BEN_PRTT_CLM_GD_OR_SVC_TYP_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_prtt_clm_gd_or_svc_typ_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_prtt_reimbmt_rqst_id >------|
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
--   p_prtt_clm_gd_or_svc_typ_id PK
--   p_prtt_reimbmt_rqst_id ID of FK column
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
Procedure chk_prtt_reimbmt_rqst_id
          (p_prtt_clm_gd_or_svc_typ_id in number,
           p_prtt_reimbmt_rqst_id      in number,
           p_effective_date            in date,
           p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtt_reimbmt_rqst_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_prtt_reimbmt_rqst_f a
    where  a.prtt_reimbmt_rqst_id = p_prtt_reimbmt_rqst_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_pcg_shd.api_updating
     (p_prtt_clm_gd_or_svc_typ_id            => p_prtt_clm_gd_or_svc_typ_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_prtt_reimbmt_rqst_id,hr_api.g_number)
     <> nvl(ben_pcg_shd.g_old_rec.prtt_reimbmt_rqst_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if prtt_reimbmt_rqst_id value exists in ben_prtt_reimbmt_rqst_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_prtt_reimbmt_rqst_f
        -- table.
        --
        ben_pcg_shd.constraint_error('BEN_PRTT_CLM_GD_OR_SVC_TYP_DT1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_prtt_reimbmt_rqst_id;


-- ----------------------------------------------------------------------------
-- |------< chk_pl_gd_or_svc_id >------|
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
--   p_prtt_clm_gd_or_svc_typ_id PK
--   p_chk_pl_gd_or_cvc_id ID of FK column
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
Procedure chk_pl_gd_or_svc_id
          (p_prtt_clm_gd_or_svc_typ_id in number,
           p_pl_gd_or_svc_id        in number,
           p_effective_date            in date,
           p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pl_gd_or_svc_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  cursor c1 is
    select null
    from   ben_pl_gd_or_svc_f  a
    where  a.pl_gd_or_svc_id = p_pl_gd_or_svc_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_pcg_shd.api_updating
     (p_prtt_clm_gd_or_svc_typ_id            => p_prtt_clm_gd_or_svc_typ_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pl_gd_or_svc_id,hr_api.g_number)
     <> nvl(ben_pcg_shd.g_old_rec.pl_gd_or_svc_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if prtt_reimbmt_rqst_id value exists in ben_prtt_reimbmt_rqst_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_prtt_reimbmt_rqst_f
        -- table.
        --
        ben_pcg_shd.constraint_error('BEN_PRTT_CLM_GD_OR_SVC_TYP_DT1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pl_gd_or_svc_id;


--
-- ----------------------------------------------------------------------------
-- |------< chk_gd_or_svc_typ_id >------|
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
--   p_prtt_clm_gd_or_svc_typ_id PK
--   p_gd_or_svc_typ_id ID of FK column
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
Procedure chk_gd_or_svc_typ_id
          (p_prtt_clm_gd_or_svc_typ_id in number,
           p_gd_or_svc_typ_id          in number,
           p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_gd_or_svc_typ_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_gd_or_svc_typ a
    where  a.gd_or_svc_typ_id = p_gd_or_svc_typ_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_pcg_shd.api_updating
     (p_prtt_clm_gd_or_svc_typ_id => p_prtt_clm_gd_or_svc_typ_id,
      p_object_version_number     => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_gd_or_svc_typ_id,hr_api.g_number)
     <> nvl(ben_pcg_shd.g_old_rec.gd_or_svc_typ_id,hr_api.g_number)
     or not l_api_updating) and
     p_gd_or_svc_typ_id is not null then
    --
    -- check if gd_or_svc_typ_id value exists in ben_gd_or_svc_typ table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_gd_or_svc_typ
        -- table.
        --
        ben_pcg_shd.constraint_error('BEN_PRTT_CLM_GD_OR_SVC_TYP_FK3');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_gd_or_svc_typ_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_pcg_shd.g_rec_type) is
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
  chk_prtt_clm_gd_or_svc_typ_id
  (p_prtt_clm_gd_or_svc_typ_id          => p_rec.prtt_clm_gd_or_svc_typ_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_gd_or_svc_typ_id
  (p_prtt_clm_gd_or_svc_typ_id          => p_rec.prtt_clm_gd_or_svc_typ_id,
   p_gd_or_svc_typ_id          => p_rec.gd_or_svc_typ_id,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_pcg_shd.g_rec_type) is
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
  --
  chk_prtt_clm_gd_or_svc_typ_id
  (p_prtt_clm_gd_or_svc_typ_id          => p_rec.prtt_clm_gd_or_svc_typ_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_gd_or_svc_typ_id
  (p_prtt_clm_gd_or_svc_typ_id          => p_rec.prtt_clm_gd_or_svc_typ_id,
   p_gd_or_svc_typ_id          => p_rec.gd_or_svc_typ_id,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_pcg_shd.g_rec_type) is
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
  (p_prtt_clm_gd_or_svc_typ_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_prtt_clm_gd_or_svc_typ b
    where b.prtt_clm_gd_or_svc_typ_id      = p_prtt_clm_gd_or_svc_typ_id
    and   a.business_group_id = b.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  per_business_groups.legislation_code%TYPE; -- UTF8 varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'prtt_clm_gd_or_svc_typ_id',
                             p_argument_value => p_prtt_clm_gd_or_svc_typ_id);
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
end ben_pcg_bus;

/
