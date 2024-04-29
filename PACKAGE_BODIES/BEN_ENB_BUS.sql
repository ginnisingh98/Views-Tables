--------------------------------------------------------
--  DDL for Package Body BEN_ENB_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENB_BUS" as
/* $Header: beenbrhi.pkb 115.15 2002/12/16 07:02:08 rpgupta ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_enb_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_bnft_id >------|
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
--   enrt_bnft_id PK of record being inserted or updated.
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
Procedure chk_enrt_bnft_id(p_enrt_bnft_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_bnft_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_enb_shd.api_updating
    (p_enrt_bnft_id                => p_enrt_bnft_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_enrt_bnft_id,hr_api.g_number)
     <>  ben_enb_shd.g_old_rec.enrt_bnft_id) then
    --
    -- raise error as PK has changed
    --
    ben_enb_shd.constraint_error('BEN_ENRT_BNFT_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_enrt_bnft_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_enb_shd.constraint_error('BEN_ENRT_BNFT_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_enrt_bnft_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_bndry_perd_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_bnft_id PK of record being inserted or updated.
--   bndry_perd_cd Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
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
Procedure chk_bndry_perd_cd(p_enrt_bnft_id                in number,
                            p_bndry_perd_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bndry_perd_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_enb_shd.api_updating
    (p_enrt_bnft_id                => p_enrt_bnft_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_bndry_perd_cd
      <> nvl(ben_enb_shd.g_old_rec.bndry_perd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bndry_perd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BNDRY_PERD',
           p_lookup_code    => p_bndry_perd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_bndry_perd_cd');
      fnd_message.set_token('TYPE', 'BEN_BNDRY_PERD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_bndry_perd_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cvg_mlt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_bnft_id PK of record being inserted or updated.
--   cvg_mlt_cd Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
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
Procedure chk_cvg_mlt_cd(p_enrt_bnft_id                in number,
                         p_cvg_mlt_cd                  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cvg_mlt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_enb_shd.api_updating
    (p_enrt_bnft_id                => p_enrt_bnft_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_cvg_mlt_cd
      <> nvl(ben_enb_shd.g_old_rec.cvg_mlt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_cvg_mlt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_CVG_MLT',
           p_lookup_code    => p_cvg_mlt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_cvg_mlt_cd');
      fnd_message.set_token('TYPE', 'BEN_CVG_MLT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cvg_mlt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_crntly_enrld_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_bnft_id PK of record being inserted or updated.
--   crntly_enrld_flag Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
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
Procedure chk_crntly_enrld_flag(p_enrt_bnft_id                in number,
                            p_crntly_enrld_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_crntly_enrld_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_enb_shd.api_updating
    (p_enrt_bnft_id                => p_enrt_bnft_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_crntly_enrld_flag
      <> nvl(ben_enb_shd.g_old_rec.crntly_enrld_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_crntly_enrld_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_crntly_enrld_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_crntly_enrld_flag;
-- ----------------------------------------------------------------------------
-- |------< chk_val_has_bn_prortd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_bnft_id PK of record being inserted or updated.
--   val_has_bn_prortd_flag Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
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
Procedure chk_val_has_bn_prortd_flag(p_enrt_bnft_id                in number,
                            p_val_has_bn_prortd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_val_has_bn_prortd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_enb_shd.api_updating
    (p_enrt_bnft_id                => p_enrt_bnft_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_val_has_bn_prortd_flag
      <> nvl(ben_enb_shd.g_old_rec.val_has_bn_prortd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_val_has_bn_prortd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_val_has_bn_prortd_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_val_has_bn_prortd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_bnft_id PK of record being inserted or updated.
--   dflt_flag Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
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
Procedure chk_dflt_flag(p_enrt_bnft_id                in number,
                            p_dflt_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_enb_shd.api_updating
    (p_enrt_bnft_id                => p_enrt_bnft_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dflt_flag
      <> nvl(ben_enb_shd.g_old_rec.dflt_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dflt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_dflt_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_bnft_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_bnft_id PK of record being inserted or updated.
--   bnft_typ_cd Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
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
Procedure chk_bnft_typ_cd(p_enrt_bnft_id                in number,
                            p_bnft_typ_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bnft_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_enb_shd.api_updating
    (p_enrt_bnft_id                => p_enrt_bnft_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_bnft_typ_cd
      <> nvl(ben_enb_shd.g_old_rec.bnft_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnft_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BNFT_TYP',
           p_lookup_code    => p_bnft_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_bnft_typ_cd');
      fnd_message.set_token('TYPE', 'BEN_BNFT_TYP');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_bnft_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_nnmntry_uom >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_bnft_id PK of record being inserted or updated.
--   nnmntry_uom Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
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
Procedure chk_nnmntry_uom(p_enrt_bnft_id                in number,
                            p_nnmntry_uom               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_nnmntry_uom';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_enb_shd.api_updating
    (p_enrt_bnft_id                => p_enrt_bnft_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_nnmntry_uom
      <> nvl(ben_enb_shd.g_old_rec.nnmntry_uom,hr_api.g_varchar2)
      or not l_api_updating)
      and p_nnmntry_uom is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_NNMNTRY_UOM',
           p_lookup_code    => p_nnmntry_uom,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_nnmntry_uom');
      fnd_message.set_token('TYPE', 'BEN_NNMNTRY_UOM');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_nnmntry_uom;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_enb_shd.g_rec_type
                         ,p_effective_date in date) is
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
  chk_enrt_bnft_id
  (p_enrt_bnft_id          => p_rec.enrt_bnft_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bndry_perd_cd
  (p_enrt_bnft_id          => p_rec.enrt_bnft_id,
   p_bndry_perd_cd         => p_rec.bndry_perd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvg_mlt_cd
  (p_enrt_bnft_id          => p_rec.enrt_bnft_id,
   p_cvg_mlt_cd            => p_rec.cvg_mlt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_val_has_bn_prortd_flag
  (p_enrt_bnft_id          => p_rec.enrt_bnft_id,
   p_val_has_bn_prortd_flag         => p_rec.val_has_bn_prortd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crntly_enrld_flag
  (p_enrt_bnft_id          => p_rec.enrt_bnft_id,
   p_crntly_enrld_flag         => p_rec.crntly_enrld_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_flag
  (p_enrt_bnft_id          => p_rec.enrt_bnft_id,
   p_dflt_flag         => p_rec.dflt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bnft_typ_cd
  (p_enrt_bnft_id          => p_rec.enrt_bnft_id,
   p_bnft_typ_cd         => p_rec.bnft_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_nnmntry_uom
  (p_enrt_bnft_id          => p_rec.enrt_bnft_id,
   p_nnmntry_uom         => p_rec.nnmntry_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_enb_shd.g_rec_type
                         ,p_effective_date in date) is
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
  chk_enrt_bnft_id
  (p_enrt_bnft_id          => p_rec.enrt_bnft_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bndry_perd_cd
  (p_enrt_bnft_id          => p_rec.enrt_bnft_id,
   p_bndry_perd_cd         => p_rec.bndry_perd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvg_mlt_cd
  (p_enrt_bnft_id          => p_rec.enrt_bnft_id,
   p_cvg_mlt_cd            => p_rec.cvg_mlt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_val_has_bn_prortd_flag
  (p_enrt_bnft_id          => p_rec.enrt_bnft_id,
   p_val_has_bn_prortd_flag         => p_rec.val_has_bn_prortd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crntly_enrld_flag
  (p_enrt_bnft_id          => p_rec.enrt_bnft_id,
   p_crntly_enrld_flag         => p_rec.crntly_enrld_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_flag
  (p_enrt_bnft_id          => p_rec.enrt_bnft_id,
   p_dflt_flag         => p_rec.dflt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bnft_typ_cd
  (p_enrt_bnft_id          => p_rec.enrt_bnft_id,
   p_bnft_typ_cd         => p_rec.bnft_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_nnmntry_uom
  (p_enrt_bnft_id          => p_rec.enrt_bnft_id,
   p_nnmntry_uom         => p_rec.nnmntry_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_enb_shd.g_rec_type
                         ,p_effective_date in date) is
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
  (p_enrt_bnft_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_enrt_bnft b
    where b.enrt_bnft_id      = p_enrt_bnft_id
    and   a.business_group_id = b.business_group_id;
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
                             p_argument       => 'enrt_bnft_id',
                             p_argument_value => p_enrt_bnft_id);
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
end ben_enb_bus;

/
