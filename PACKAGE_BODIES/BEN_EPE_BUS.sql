--------------------------------------------------------
--  DDL for Package Body BEN_EPE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EPE_BUS" as
/* $Header: beeperhi.pkb 120.0 2005/05/28 02:36:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_epe_bus.';  -- Global package name
/*
--
-- ----------------------------------------------------------------------------
-- |------< chk_pil_elctbl_chc_popl_id >------|
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
--   p_elig_per_elctbl_chc_id PK
--   p_pil_elctbl_chc_popl_id ID of FK column
--   p_effective_date session date
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
Procedure chk_pil_elctbl_chc_popl_id (p_elig_per_elctbl_chc_id          in number,
                            p_pil_elctbl_chc_popl_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pil_elctbl_chc_popl_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_pil_elctbl_chc_popl a
    where  a.pil_elctbl_chc_popl_id = p_pil_elctbl_chc_popl_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epe_shd.api_updating
     (p_elig_per_elctbl_chc_id            => p_elig_per_elctbl_chc_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pil_elctbl_chc_popl_id,hr_api.g_number)
     <> nvl(ben_epe_shd.g_old_rec.pil_elctbl_chc_popl_id,hr_api.g_number)
     or not l_api_updating) and
     p_pil_elctbl_chc_popl_id is not null then
    --
    -- check if pil_elctbl_chc_popl_id value exists in ben_pil_elctbl_chc_popl table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_pil_elctbl_chc_popl
        -- table.
        --
        ben_epe_shd.constraint_error('BEN_ELIG_PER_ELCTBL_CHC_?');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pil_elctbl_chc_popl_id;
*/
--
-- ----------------------------------------------------------------------------
-- |------< chk_pl_typ_id >------|
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
--   p_elig_per_elctbl_chc_id PK
--   p_pl_typ_id ID of FK column
--   p_effective_date session date
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
Procedure chk_pl_typ_id (p_elig_per_elctbl_chc_id          in number,
                            p_pl_typ_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pl_typ_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_pl_typ_F a
    where  a.pl_typ_id = p_pl_typ_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epe_shd.api_updating
     (p_elig_per_elctbl_chc_id            => p_elig_per_elctbl_chc_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pl_typ_id,hr_api.g_number)
     <> nvl(ben_epe_shd.g_old_rec.pl_typ_id,hr_api.g_number)
     or not l_api_updating) and
     p_pl_typ_id is not null then
    --
    -- check if pl_typ_id value exists in ben_pl_typ table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error a PK does not relate to PK in ben_pl_typ
        -- table.
        --
        ben_epe_shd.constraint_error('BEN_ELIG_PER_ELCTBL_CHC_DT7');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pl_typ_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_spcl_rt_oipl_id >------|
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
--   p_elig_per_elctbl_chc_id PK
--   p_spcl_rt_oipl_id ID of FK column
--   p_effective_date session date
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
Procedure chk_spcl_rt_oipl_id (p_elig_per_elctbl_chc_id          in number,
                            p_spcl_rt_oipl_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_spcl_rt_oipl_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_oipl_f a
    where  a.oipl_id = p_spcl_rt_oipl_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epe_shd.api_updating
     (p_elig_per_elctbl_chc_id            => p_elig_per_elctbl_chc_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_spcl_rt_oipl_id,hr_api.g_number)
     <> nvl(ben_epe_shd.g_old_rec.spcl_rt_oipl_id,hr_api.g_number)
     or not l_api_updating) and
     p_spcl_rt_oipl_id is not null then
    --
    -- check if spcl_rt_oipl_id value exists in ben_spcl_rt_oipl table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_spcl_rt_oipl
        -- table.
        --
        ben_epe_shd.constraint_error('BEN_ELIG_PER_ELCTBL_CHC_DT13');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_spcl_rt_oipl_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_spcl_rt_pl_id >------|
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
--   p_elig_per_elctbl_chc_id PK
--   p_spcl_rt_pl_id ID of FK column
--   p_effective_date session date
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
Procedure chk_spcl_rt_pl_id (p_elig_per_elctbl_chc_id          in number,
                            p_spcl_rt_pl_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_spcl_rt_pl_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_pl_f a
    where  a.pl_id = p_spcl_rt_pl_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epe_shd.api_updating
     (p_elig_per_elctbl_chc_id            => p_elig_per_elctbl_chc_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_spcl_rt_pl_id,hr_api.g_number)
     <> nvl(ben_epe_shd.g_old_rec.spcl_rt_pl_id,hr_api.g_number)
     or not l_api_updating) and
     p_spcl_rt_pl_id is not null then
    --
    -- check if spcl_rt_pl_id value exists in ben_spcl_rt_pl table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_spcl_rt_pl
        -- table.
        --
        ben_epe_shd.constraint_error('BEN_ELIG_PER_ELCTBL_CHC_DT12');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_spcl_rt_pl_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_plip_id >------|
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
--   p_elig_per_elctbl_chc_id PK
--   p_plip_id ID of FK column
--   p_effective_date session date
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
Procedure chk_plip_id (p_elig_per_elctbl_chc_id          in number,
                            p_plip_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_plip_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_plip_f a
    where  a.plip_id = p_plip_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epe_shd.api_updating
     (p_elig_per_elctbl_chc_id            => p_elig_per_elctbl_chc_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_plip_id,hr_api.g_number)
     <> nvl(ben_epe_shd.g_old_rec.plip_id,hr_api.g_number)
     or not l_api_updating) and
     p_plip_id is not null then
    --
    -- check if plip_id value exists in ben_plip table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_plip
        -- table.
        --
        ben_epe_shd.constraint_error('BEN_ELIG_PER_ELCTBL_CHC_DT8');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_plip_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cmbn_ptip_id >------|
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
--   p_elig_per_elctbl_chc_id PK
--   p_cmbn_ptip_id ID of FK column
--   p_effective_date session date
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
Procedure chk_cmbn_ptip_id (p_elig_per_elctbl_chc_id          in number,
                            p_cmbn_ptip_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cmbn_ptip_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_cmbn_ptip_f a
    where  a.cmbn_ptip_id = p_cmbn_ptip_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epe_shd.api_updating
     (p_elig_per_elctbl_chc_id            => p_elig_per_elctbl_chc_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_cmbn_ptip_id,hr_api.g_number)
     <> nvl(ben_epe_shd.g_old_rec.cmbn_ptip_id,hr_api.g_number)
     or not l_api_updating) and
     p_cmbn_ptip_id is not null then
    --
    -- check if cmbn_ptip_id value exists in ben_cmbn_ptip table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_cmbn_ptip
        -- table.
        --
        ben_epe_shd.constraint_error('BEN_ELIG_PER_ELCTBL_CHC_DT15');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_cmbn_ptip_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cmbn_plip_id >------|
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
--   p_elig_per_elctbl_chc_id PK
--   p_cmbn_plip_id ID of FK column
--   p_effective_date session date
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
Procedure chk_cmbn_plip_id (p_elig_per_elctbl_chc_id          in number,
                            p_cmbn_plip_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cmbn_plip_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_cmbn_plip_f a
    where  a.cmbn_plip_id = p_cmbn_plip_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epe_shd.api_updating
     (p_elig_per_elctbl_chc_id            => p_elig_per_elctbl_chc_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_cmbn_plip_id,hr_api.g_number)
     <> nvl(ben_epe_shd.g_old_rec.cmbn_plip_id,hr_api.g_number)
     or not l_api_updating) and
     p_cmbn_plip_id is not null then
    --
    -- check if cmbn_plip_id value exists in ben_cmbn_plip table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_cmbn_plip
        -- table.
        --
        ben_epe_shd.constraint_error('BEN_ELIG_PER_ELCTBL_CHC_DT15');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_cmbn_plip_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ptip_id >------|
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
--   p_elig_per_elctbl_chc_id PK
--   p_ptip_id ID of FK column
--   p_effective_date session date
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
Procedure chk_ptip_id (p_elig_per_elctbl_chc_id          in number,
                            p_ptip_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ptip_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ptip_f a
    where  a.ptip_id = p_ptip_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epe_shd.api_updating
     (p_elig_per_elctbl_chc_id            => p_elig_per_elctbl_chc_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ptip_id,hr_api.g_number)
     <> nvl(ben_epe_shd.g_old_rec.ptip_id,hr_api.g_number)
     or not l_api_updating) and
     p_ptip_id is not null then
    --
    -- check if ptip_id value exists in ben_ptip table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_ptip
        -- table.
        --
        ben_epe_shd.constraint_error('BEN_ELIG_PER_ELCTBL_CHC_DT9');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ptip_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cmbn_ptip_opt_id >------|
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
--   p_elig_per_elctbl_chc_id PK
--   p_cmbn_ptip_opt_id ID of FK column
--   p_effective_date session date
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
Procedure chk_cmbn_ptip_opt_id (p_elig_per_elctbl_chc_id          in number,
                            p_cmbn_ptip_opt_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cmbn_ptip_opt_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_cmbn_ptip_opt_f a
    where  a.cmbn_ptip_opt_id = p_cmbn_ptip_opt_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epe_shd.api_updating
     (p_elig_per_elctbl_chc_id            => p_elig_per_elctbl_chc_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_cmbn_ptip_opt_id,hr_api.g_number)
     <> nvl(ben_epe_shd.g_old_rec.cmbn_ptip_opt_id,hr_api.g_number)
     or not l_api_updating) and
     p_cmbn_ptip_opt_id is not null then
    --
    -- check if cmbn_ptip_opt_id value exists in ben_cmbn_ptip_opt table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_cmbn_ptip_opt
        -- table.
        --
        ben_epe_shd.constraint_error('BEN_ELIG_PER_ELCTBL_CHC_DT16');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_cmbn_ptip_opt_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pgm_id >------|
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
--   p_elig_per_elctbl_chc_id PK
--   p_pgm_id ID of FK column
--   p_effective_date session date
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
Procedure chk_pgm_id (p_elig_per_elctbl_chc_id          in number,
                            p_pgm_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pgm_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_pgm_f a
    where  a.pgm_id = p_pgm_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epe_shd.api_updating
     (p_elig_per_elctbl_chc_id            => p_elig_per_elctbl_chc_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pgm_id,hr_api.g_number)
     <> nvl(ben_epe_shd.g_old_rec.pgm_id,hr_api.g_number)
     or not l_api_updating) and
     p_pgm_id is not null then
    --
    -- check if pgm_id value exists in ben_pgm table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_pgm
        -- table.
        --
        ben_epe_shd.constraint_error('BEN_ELIG_PER_ELCTBL_CHC_DT3');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pgm_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_oipl_id >------|
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
--   p_elig_per_elctbl_chc_id PK
--   p_oipl_id ID of FK column
--   p_effective_date session date
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
Procedure chk_oipl_id (p_elig_per_elctbl_chc_id          in number,
                            p_oipl_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_oipl_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_oipl_f a
    where  a.oipl_id = p_oipl_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epe_shd.api_updating
     (p_elig_per_elctbl_chc_id            => p_elig_per_elctbl_chc_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_oipl_id,hr_api.g_number)
     <> nvl(ben_epe_shd.g_old_rec.oipl_id,hr_api.g_number)
     or not l_api_updating) and
     p_oipl_id is not null then
    --
    -- check if oipl_id value exists in ben_oipl table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_oipl
        -- table.
        --
        ben_epe_shd.constraint_error('BEN_ELIG_PER_ELCTBL_CHC_DT2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_oipl_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pl_id >------|
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
--   p_elig_per_elctbl_chc_id PK
--   p_pl_id ID of FK column
--   p_effective_date session date
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
Procedure chk_pl_id (p_elig_per_elctbl_chc_id          in number,
                            p_pl_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pl_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_pl_f a
    where  a.pl_id = p_pl_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epe_shd.api_updating
     (p_elig_per_elctbl_chc_id            => p_elig_per_elctbl_chc_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pl_id,hr_api.g_number)
     <> nvl(ben_epe_shd.g_old_rec.pl_id,hr_api.g_number)
     or not l_api_updating) and
     p_pl_id is not null then
    --
    -- check if pl_id value exists in ben_pl table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_pl
        -- table.
        --
        ben_epe_shd.constraint_error('BEN_ELIG_PER_ELCTBL_CHC_DT2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pl_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_bnft_prvdr_pool_id >------|
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
--   p_elig_per_elctbl_chc_id PK
--   p_bnft_prvdr_pool_id ID of FK column
--   p_effective_date session date
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
Procedure chk_bnft_prvdr_pool_id (p_elig_per_elctbl_chc_id          in number,
                            p_bnft_prvdr_pool_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bnft_prvdr_pool_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_bnft_prvdr_pool_f a
    where  a.bnft_prvdr_pool_id = p_bnft_prvdr_pool_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epe_shd.api_updating
     (p_elig_per_elctbl_chc_id            => p_elig_per_elctbl_chc_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_bnft_prvdr_pool_id,hr_api.g_number)
     <> nvl(ben_epe_shd.g_old_rec.bnft_prvdr_pool_id,hr_api.g_number)
     or not l_api_updating) and
     p_bnft_prvdr_pool_id is not null then
    --
    -- check if bnft_prvdr_pool_id value exists in ben_bnft_prvdr_pool table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_bnft_prvdr_pool
        -- table.
        --
        ben_epe_shd.constraint_error('BEN_ELIG_PER_ELCTBL_CHC_DT14');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_bnft_prvdr_pool_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_prtt_enrt_rslt_id >------|
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
--   p_elig_per_elctbl_chc_id PK
--   p_prtt_enrt_rslt_id ID of FK column
--   p_effective_date session date
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
Procedure chk_prtt_enrt_rslt_id (p_elig_per_elctbl_chc_id          in number,
                            p_prtt_enrt_rslt_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtt_enrt_rslt_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_prtt_enrt_rslt_f a
    where  a.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and  a.prtt_enrt_rslt_stat_cd is null;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epe_shd.api_updating
     (p_elig_per_elctbl_chc_id            => p_elig_per_elctbl_chc_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_prtt_enrt_rslt_id,hr_api.g_number)
     <> nvl(ben_epe_shd.g_old_rec.prtt_enrt_rslt_id,hr_api.g_number)
     or not l_api_updating) and
     p_prtt_enrt_rslt_id is not null then
    --
    -- check if prtt_enrt_rslt_id value exists in ben_prtt_enrt_rslt table.
    -- results that are voided or backed out should not be getting newly
    -- attached to choice records.
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_prtt_enrt_rslt
        -- table.
        --
        ben_epe_shd.constraint_error('BEN_ELIG_PER_ELCTBL_CHC_DT5');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_prtt_enrt_rslt_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_per_in_ler_id >------|
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
--   p_elig_per_elctbl_chc_id PK
--   p_per_in_ler_id ID of FK column
--   p_effective_date session date
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
Procedure chk_per_in_ler_id (p_elig_per_elctbl_chc_id          in number,
                            p_per_in_ler_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_per_in_ler_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_per_in_ler a
    where  a.per_in_ler_id = p_per_in_ler_id
      and  a.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD');
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epe_shd.api_updating
     (p_elig_per_elctbl_chc_id            => p_elig_per_elctbl_chc_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_per_in_ler_id,hr_api.g_number)
     <> nvl(ben_epe_shd.g_old_rec.per_in_ler_id,hr_api.g_number)
     or not l_api_updating) and
     p_per_in_ler_id is not null then
    --
    -- check if per_in_ler_id value exists in ben_per_in_ler table, and that
    -- the status of the per-in-ler_id that is being updated is a valid one.
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_per_in_ler
        -- table.
        --
        ben_epe_shd.constraint_error('BEN_ELIG_PER_ELCTBL_CHC_DT6');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_per_in_ler_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_must_enrl_anthr_pl_id >------|
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
--   p_elig_per_elctbl_chc_id PK
--   p_must_enrl_anthr_pl_id ID of FK column
--   p_effective_date session date
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
Procedure chk_must_enrl_anthr_pl_id (p_elig_per_elctbl_chc_id          in number,
                            p_must_enrl_anthr_pl_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_must_enrl_anthr_pl_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_pl_f a
    where  a.pl_id = p_must_enrl_anthr_pl_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epe_shd.api_updating
     (p_elig_per_elctbl_chc_id            => p_elig_per_elctbl_chc_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_must_enrl_anthr_pl_id,hr_api.g_number)
     <> nvl(ben_epe_shd.g_old_rec.must_enrl_anthr_pl_id,hr_api.g_number)
     or not l_api_updating) and
     p_must_enrl_anthr_pl_id is not null then
    --
    -- check if must_enrl_anthr_pl_id value exists in ben_must_enrl_anthr_pl table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_must_enrl_anthr_pl
        -- table.
        --
        ben_epe_shd.constraint_error('BEN_ELIG_PER_ELCTBL_CHC_DT11');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_must_enrl_anthr_pl_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_int_elig_per_elctbl_chc_id >------|
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
--   p_elig_per_elctbl_chc_id PK
--   p_int_elig_per_elctbl_chc_id ID of FK column
--   p_effective_date session date
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
Procedure chk_int_elig_per_elctbl_chc_id (p_elig_per_elctbl_chc_id          in number,
                            p_int_elig_per_elctbl_chc_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_int_elig_per_elctbl_chc_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_elig_per_elctbl_chc a
    where  a.elig_per_elctbl_chc_id = p_int_elig_per_elctbl_chc_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epe_shd.api_updating
     (p_elig_per_elctbl_chc_id            => p_elig_per_elctbl_chc_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_int_elig_per_elctbl_chc_id,hr_api.g_number)
     <> nvl(ben_epe_shd.g_old_rec.int_elig_per_elctbl_chc_id,hr_api.g_number)
     or not l_api_updating) and
     p_int_elig_per_elctbl_chc_id is not null then
    --
    -- check if int_elig_per_elctbl_chc_id value exists in table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in
        -- table.
        --
        ben_epe_shd.constraint_error('BEN_ELIG_PER_ELCTBL_CHC_FK18');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_int_elig_per_elctbl_chc_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_yr_perd_id >------|
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
--   p_elig_per_elctbl_chc_id PK
--   p_yr_perd_id ID of FK column
--   p_effective_date session date
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
Procedure chk_yr_perd_id (p_elig_per_elctbl_chc_id          in number,
                            p_yr_perd_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_yr_perd_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_yr_perd a
    where  a.yr_perd_id = p_yr_perd_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epe_shd.api_updating
     (p_elig_per_elctbl_chc_id            => p_elig_per_elctbl_chc_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_yr_perd_id,hr_api.g_number)
     <> nvl(ben_epe_shd.g_old_rec.yr_perd_id,hr_api.g_number)
     or not l_api_updating) and
     p_yr_perd_id is not null then
    --
    -- check if yr_perd_id value exists in ben_yr_perd table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_yr_perd
        -- table.
        --
        ben_epe_shd.constraint_error('BEN_ELIG_PER_ELCTBL_CHC_FK15');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_yr_perd_id;
--
-- -------------------------------------------------------------------------
-- |------< chk_enrt_ovrid_rsn_cd >------|
-- -------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_enrt_rslt_id PK of record being inserted or updated.
--   enrt_ovrid_rsn_cd Value of lookup code.
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
Procedure chk_all_cds
                   (p_elig_per_elctbl_chc_id      in number
                   ,p_lookup_type                 in varchar2
                   ,p_cd                          in varchar2
                   ,p_old_cd                      in varchar2
                   ,p_effective_date              in date
                   ,p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_all_cds';
  l_api_updating boolean;
  --
Begin
  --
/*
  hr_utility.set_location('Entering:'||l_proc, 5);
*/
  --
  l_api_updating := ben_epe_shd.api_updating
    (p_elig_per_elctbl_chc_id      => p_elig_per_elctbl_chc_id,
     p_object_version_number       => p_object_version_number);

  if (l_api_updating
      and p_cd
      <> nvl(p_old_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
/*
    hr_utility.set_location('HRAPI_NEIHL:'||l_proc, 5);
*/
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => p_lookup_type,
           p_lookup_code    => p_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_cd);
      fnd_message.set_token('TYPE',p_lookup_type);
      fnd_message.raise_error;
    end if;
/*
    hr_utility.set_location('Dn HRAPI_NEIHL:'||l_proc, 5);
*/
  end if;
/*
  hr_utility.set_location('Leaving:'||l_proc,10);
*/
end chk_all_cds;

--
-- ----------------------------------------------------------------------------
-- |------< chk_all_flags >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_per_elctbl_chc_id PK of record being inserted or updated.
--   flag Value of lookup code.
--   old value of flag from old_rec.
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
Procedure chk_all_flags(       p_elig_per_elctbl_chc_id  in number
                              ,p_flag                    in varchar2
                              ,p_old_flag                in varchar2
                              ,p_effective_date          in date
                              ,p_object_version_number   in number
                              ) is
  l_proc         varchar2(72) := g_package||'chk_all_flags';
  l_api_updating boolean;

Begin
  --
/*
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
*/
  l_api_updating := ben_epe_shd.api_updating
    (p_elig_per_elctbl_chc_id           => p_elig_per_elctbl_chc_id,
     p_object_version_number       => p_object_version_number);
  --
/*
  if l_api_updating then
    hr_utility.set_location(l_proc||' updating true', 10);
  else
    hr_utility.set_location(l_proc||' updating false', 20);
  end if;
  hr_utility.set_location(l_proc||' pflag='||p_flag, 30);
*/
  if (l_api_updating
      and p_flag
          <> nvl(p_old_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
/*
    hr_utility.set_location('HRAPI_NEIHL:'||l_proc, 5);
*/
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
/*
      hr_utility.set_location(l_proc, 40);
*/
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
/*
    hr_utility.set_location('Dn HRAPI_NEIHL:'||l_proc, 5);
*/
    --
  end if;
  --
/*
  hr_utility.set_location('Leaving:'||l_proc,50);
  --
*/
end chk_all_flags;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_cvg_strt_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_per_elctbl_chc_id PK of record being inserted or updated.
--   enrt_cvg_strt_dt_rl Value of formula rule id.
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
--
Procedure chk_enrt_cvg_strt_dt_rl(p_elig_per_elctbl_chc_id         in number,
                             p_enrt_cvg_strt_dt_rl         in number,
                             p_business_group_id           in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cvg_strt_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_enrt_cvg_strt_dt_rl
    and    ff.formula_type_id = -29
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) =
               p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
               pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_epe_shd.api_updating
    (p_elig_per_elctbl_chc_id      => p_elig_per_elctbl_chc_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_enrt_cvg_strt_dt_rl,hr_api.g_number)
      <> ben_epe_shd.g_old_rec.enrt_cvg_strt_dt_rl
      or not l_api_updating)
      and p_enrt_cvg_strt_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
        fnd_message.set_token('ID',p_enrt_cvg_strt_dt_rl);
        fnd_message.set_token('TYPE_ID',-29);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_cvg_strt_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_cvg_strt_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_per_elctbl_chc_id PK of record being inserted or updated.
--   dpnt_cvg_strt_dt_rl Value of formula rule id.
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
--
Procedure chk_dpnt_cvg_strt_dt_rl(p_elig_per_elctbl_chc_id         in number,
                             p_dpnt_cvg_strt_dt_rl         in number,
                             p_business_group_id           in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_cvg_strt_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_dpnt_cvg_strt_dt_rl
    and    ff.formula_type_id = -27
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) =
               p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
               pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_epe_shd.api_updating
    (p_elig_per_elctbl_chc_id      => p_elig_per_elctbl_chc_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_dpnt_cvg_strt_dt_rl,hr_api.g_number)
      <> ben_epe_shd.g_old_rec.dpnt_cvg_strt_dt_rl
      or not l_api_updating)
      and p_dpnt_cvg_strt_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
        fnd_message.set_token('ID',p_dpnt_cvg_strt_dt_rl);
        fnd_message.set_token('TYPE_ID',-27);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_cvg_strt_dt_rl;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_elig_per_elctbl_chc_id already exists.
--
--  In Arguments:
--    p_elig_per_elctbl_chc_id
--
--  Post Success:
--    If the value is found this function will return the values business
--    group legislation code.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
function return_legislation_code
  (p_elig_per_elctbl_chc_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_elig_per_elctbl_chc b
    where b.elig_per_elctbl_chc_id      = p_elig_per_elctbl_chc_id
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
                             p_argument       => 'elig_per_elctbl_chc_id',
                             p_argument_value => p_elig_per_elctbl_chc_id);
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

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_epe_shd.g_rec_type
			,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call context sensitive validate bgp cache routine
  --
  ben_batch_dt_api.batch_validate_bgp_id
    (p_business_group_id => p_rec.business_group_id
    );
  --
/*
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
*/
  chk_yr_perd_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_yr_perd_id                 => p_rec.yr_perd_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_must_enrl_anthr_pl_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_must_enrl_anthr_pl_id      => p_rec.must_enrl_anthr_pl_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_int_elig_per_elctbl_chc_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_int_elig_per_elctbl_chc_id      => p_rec.int_elig_per_elctbl_chc_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_per_in_ler_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_per_in_ler_id              => p_rec.per_in_ler_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_prtt_enrt_rslt_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_prtt_enrt_rslt_id          => p_rec.prtt_enrt_rslt_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_bnft_prvdr_pool_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_bnft_prvdr_pool_id         => p_rec.bnft_prvdr_pool_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_pl_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_pl_id                      => p_rec.pl_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_oipl_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_oipl_id                    => p_rec.oipl_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_pgm_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_pgm_id                     => p_rec.pgm_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_cmbn_ptip_opt_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_cmbn_ptip_opt_id           => p_rec.cmbn_ptip_opt_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_ptip_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_ptip_id                    => p_rec.ptip_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_cmbn_ptip_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_cmbn_ptip_id               => p_rec.cmbn_ptip_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_cmbn_plip_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_cmbn_plip_id               => p_rec.cmbn_plip_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_plip_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_plip_id                    => p_rec.plip_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_spcl_rt_pl_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_spcl_rt_pl_id              => p_rec.spcl_rt_pl_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_spcl_rt_oipl_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_spcl_rt_oipl_id            => p_rec.spcl_rt_oipl_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_pl_typ_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_pl_typ_id                  => p_rec.pl_typ_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
/*  chk_pil_elctbl_chc_popl_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_pil_elctbl_chc_popl_id     => p_rec.pil_elctbl_chc_popl_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
*/  --
  --
--  chk_all_cds
--  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
--   p_lookup_type                => 'BEN_RT_STRT',
--   p_cd                         => p_rec.rt_strt_dt_cd,
--   p_old_cd                     => ben_epe_shd.g_old_rec.rt_strt_dt_cd,
--   p_effective_date             => p_effective_date,
--   p_object_version_number      => p_rec.object_version_number);
  --
  --
  chk_all_cds
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_lookup_type                => 'BEN_ENRT_CVG_STRT',
   p_cd                         => p_rec.enrt_cvg_strt_dt_cd,
   p_old_cd                     => ben_epe_shd.g_old_rec.enrt_cvg_strt_dt_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  --
  chk_all_cds
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_lookup_type                => 'BEN_DPNT_CVG_STRT',
   p_cd                         => p_rec.dpnt_cvg_strt_dt_cd,
   p_old_cd                     => ben_epe_shd.g_old_rec.dpnt_cvg_strt_dt_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_all_cds
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_lookup_type                => 'BEN_COMP_LVL',
   p_cd                         => p_rec.comp_lvl_cd,
   p_old_cd                     => ben_epe_shd.g_old_rec.comp_lvl_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_all_cds
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_lookup_type                => 'BEN_LER_CHG_DPNT_CVG',
   p_cd                         => p_rec.ler_chg_dpnt_cvg_cd,
   p_old_cd                     => ben_epe_shd.g_old_rec.ler_chg_dpnt_cvg_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_all_cds
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_lookup_type                => 'BEN_DPNT_DSGN',
   p_cd                         => p_rec.dpnt_dsgn_cd,
   p_old_cd                     => ben_epe_shd.g_old_rec.dpnt_dsgn_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --cwb
  chk_all_cds
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_lookup_type                => 'BEN_INELIG_RSN',
   p_cd                         => p_rec.inelig_rsn_cd,
   p_old_cd                     => ben_epe_shd.g_old_rec.inelig_rsn_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --cwb
  chk_all_flags
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_flag                       => p_rec.alws_dpnt_dsgn_flag,
   p_old_flag                   => ben_epe_shd.g_old_rec.alws_dpnt_dsgn_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_all_flags
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_flag                       => p_rec.auto_enrt_flag,
   p_old_flag                   => ben_epe_shd.g_old_rec.auto_enrt_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_all_flags
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_flag                       => p_rec.crntly_enrd_flag,
   p_old_flag                   => ben_epe_shd.g_old_rec.crntly_enrd_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_all_flags
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_flag                       => p_rec.dflt_flag,
   p_old_flag                   => ben_epe_shd.g_old_rec.dflt_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_all_flags
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_flag                       => p_rec.elctbl_flag,
   p_old_flag                   => ben_epe_shd.g_old_rec.elctbl_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_all_flags
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_flag                       => p_rec.mndtry_flag,
   p_old_flag                   => ben_epe_shd.g_old_rec.mndtry_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
/** Temporarily commented
  --cwb
  chk_all_flags
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_flag                       => p_rec.elig_flag,
   p_old_flag                   => ben_epe_shd.g_old_rec.elig_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --cwb
*/
  -- bug 1830930
/*
   chk_all_flags
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_flag                       => p_rec.in_pndg_wkflow_flag,
   p_old_flag                   => ben_epe_shd.g_old_rec.mndtry_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
*/
  --
  chk_all_flags
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_flag                       => p_rec.roll_crs_flag,
   p_old_flag                   => ben_epe_shd.g_old_rec.roll_crs_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_enrt_cvg_strt_dt_rl
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_enrt_cvg_strt_dt_rl        => p_rec.enrt_cvg_strt_dt_rl,
   p_business_group_id          => p_rec.business_group_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_dpnt_cvg_strt_dt_rl
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_dpnt_cvg_strt_dt_rl        => p_rec.dpnt_cvg_strt_dt_rl,
   p_business_group_id          => p_rec.business_group_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_epe_shd.g_rec_type,
			p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call context sensitive validate bgp cache routine
  --
  ben_batch_dt_api.batch_validate_bgp_id
    (p_business_group_id => p_rec.business_group_id
    );
  --
/*
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
*/
  chk_yr_perd_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_yr_perd_id                 => p_rec.yr_perd_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_must_enrl_anthr_pl_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_must_enrl_anthr_pl_id      => p_rec.must_enrl_anthr_pl_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_int_elig_per_elctbl_chc_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_int_elig_per_elctbl_chc_id      => p_rec.int_elig_per_elctbl_chc_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_per_in_ler_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_per_in_ler_id              => p_rec.per_in_ler_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_prtt_enrt_rslt_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_prtt_enrt_rslt_id          => p_rec.prtt_enrt_rslt_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_bnft_prvdr_pool_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_bnft_prvdr_pool_id         => p_rec.bnft_prvdr_pool_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_pl_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_pl_id                      => p_rec.pl_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_oipl_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_oipl_id                    => p_rec.oipl_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_pgm_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_pgm_id                     => p_rec.pgm_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_cmbn_ptip_opt_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_cmbn_ptip_opt_id           => p_rec.cmbn_ptip_opt_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_ptip_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_ptip_id                    => p_rec.ptip_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_cmbn_ptip_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_cmbn_ptip_id               => p_rec.cmbn_ptip_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_cmbn_plip_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_cmbn_plip_id               => p_rec.cmbn_plip_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_plip_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_plip_id                    => p_rec.plip_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_spcl_rt_pl_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_spcl_rt_pl_id              => p_rec.spcl_rt_pl_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_spcl_rt_oipl_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_spcl_rt_oipl_id            => p_rec.spcl_rt_oipl_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_pl_typ_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_pl_typ_id                  => p_rec.pl_typ_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
/*  chk_pil_elctbl_chc_popl_id
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_pil_elctbl_chc_popl_id     => p_rec.pil_elctbl_chc_popl_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
*/  --
  --
--  chk_all_cds
--  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
--   p_lookup_type                => 'BEN_RT_STRT',
--   p_cd                         => p_rec.rt_strt_dt_cd,
--   p_old_cd                     => ben_epe_shd.g_old_rec.rt_strt_dt_cd,
--   p_effective_date             => p_effective_date,
--   p_object_version_number      => p_rec.object_version_number);
  --
  --
  chk_all_cds
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_lookup_type                => 'BEN_ENRT_CVG_STRT',
   p_cd                         => p_rec.enrt_cvg_strt_dt_cd,
   p_old_cd                     => ben_epe_shd.g_old_rec.enrt_cvg_strt_dt_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  --
  chk_all_cds
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_lookup_type                => 'BEN_DPNT_CVG_STRT',
   p_cd                         => p_rec.dpnt_cvg_strt_dt_cd,
   p_old_cd                     => ben_epe_shd.g_old_rec.dpnt_cvg_strt_dt_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_all_cds
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_lookup_type                => 'BEN_COMP_LVL',
   p_cd                         => p_rec.comp_lvl_cd,
   p_old_cd                     => ben_epe_shd.g_old_rec.comp_lvl_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_all_cds
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_lookup_type                => 'BEN_LER_CHG_DPNT_CVG',
   p_cd                         => p_rec.ler_chg_dpnt_cvg_cd,
   p_old_cd                     => ben_epe_shd.g_old_rec.ler_chg_dpnt_cvg_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_all_cds
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_lookup_type                => 'BEN_DPNT_DSGN',
   p_cd                         => p_rec.dpnt_dsgn_cd,
   p_old_cd                     => ben_epe_shd.g_old_rec.dpnt_dsgn_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  --cwb
  chk_all_cds
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_lookup_type                => 'BEN_INELIG_RSN',
   p_cd                         => p_rec.inelig_rsn_cd,
   p_old_cd                     => ben_epe_shd.g_old_rec.inelig_rsn_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --cwb
/** Temporarily commented
  --cwb
  chk_all_flags
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_flag                       => p_rec.elig_flag,
   p_old_flag                   => ben_epe_shd.g_old_rec.elig_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --cwb
*/
  chk_all_flags
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_flag                       => p_rec.alws_dpnt_dsgn_flag,
   p_old_flag                   => ben_epe_shd.g_old_rec.alws_dpnt_dsgn_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_all_flags
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_flag                       => p_rec.auto_enrt_flag,
   p_old_flag                   => ben_epe_shd.g_old_rec.auto_enrt_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_all_flags
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_flag                       => p_rec.crntly_enrd_flag,
   p_old_flag                   => ben_epe_shd.g_old_rec.crntly_enrd_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_all_flags
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_flag                       => p_rec.dflt_flag,
   p_old_flag                   => ben_epe_shd.g_old_rec.dflt_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_all_flags
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_flag                       => p_rec.elctbl_flag,
   p_old_flag                   => ben_epe_shd.g_old_rec.elctbl_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_all_flags
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_flag                       => p_rec.mndtry_flag,
   p_old_flag                   => ben_epe_shd.g_old_rec.mndtry_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  -- bug 1830930
/*
   chk_all_flags
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_flag                       => p_rec.in_pndg_wkflow_flag,
   p_old_flag                   => ben_epe_shd.g_old_rec.mndtry_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
*/
  --
  chk_all_flags
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_flag                       => p_rec.roll_crs_flag,
   p_old_flag                   => ben_epe_shd.g_old_rec.roll_crs_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_enrt_cvg_strt_dt_rl
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_enrt_cvg_strt_dt_rl        => p_rec.enrt_cvg_strt_dt_rl,
   p_business_group_id          => p_rec.business_group_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_dpnt_cvg_strt_dt_rl
  (p_elig_per_elctbl_chc_id     => p_rec.elig_per_elctbl_chc_id,
   p_dpnt_cvg_strt_dt_rl        => p_rec.dpnt_cvg_strt_dt_rl,
   p_business_group_id          => p_rec.business_group_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_epe_shd.g_rec_type
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
end ben_epe_bus;

/
