--------------------------------------------------------
--  DDL for Package Body BEN_PEL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PEL_BUS" as
/* $Header: bepelrhi.pkb 120.3.12000000.2 2007/05/13 23:02:25 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_pel_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_pil_elctbl_chc_popl_id >------|
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
--   pil_elctbl_chc_popl_id PK of record being inserted or updated.
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
Procedure chk_pil_elctbl_chc_popl_id(p_pil_elctbl_chc_popl_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pil_elctbl_chc_popl_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pel_shd.api_updating
    (p_pil_elctbl_chc_popl_id      => p_pil_elctbl_chc_popl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pil_elctbl_chc_popl_id,hr_api.g_number)
     <>  ben_pel_shd.g_old_rec.pil_elctbl_chc_popl_id) then
    --
    -- raise error as PK has changed
    --
    ben_pel_shd.constraint_error('BEN_PIL_ELCTBL_CHC_POPL_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_pil_elctbl_chc_popl_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_pel_shd.constraint_error('BEN_PIL_ELCTBL_CHC_POPL_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pil_elctbl_chc_popl_id;

--
-- ----------------------------------------------------------------------------
-- |------< chk_uom      >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_enrt_rslt_id PK of record being inserted or updated.
--   uom      Value of lookup code.
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
Procedure chk_uom (p_pil_elctbl_chc_popl_id in number
                  ,p_uom                    in     varchar2
                  ,p_effective_date         in     date
                  ,p_object_version_number  in     number) is
  l_proc         varchar2(72) := g_package||'chk_uom';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  cursor c1 is
      select null
        from fnd_currencies_tl
       where currency_code = p_uom     ;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pel_shd.api_updating
    (p_pil_elctbl_chc_popl_id      => p_pil_elctbl_chc_popl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_uom
      <> nvl(ben_pel_shd.g_old_rec.uom,hr_api.g_varchar2)
      or not l_api_updating)
      and p_uom is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
     open c1;
     fetch c1 into l_dummy;
     if c1%notfound then
        --
        -- raise error as does not exist as lookup
        --
        close c1;
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD', p_uom     );
        fnd_message.set_token('TYPE','FND_CURRENCY_TBL');
        fnd_message.raise_error;
     end if;
     close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_uom     ;
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
--   p_pil_elctbl_chc_popl_id PK
--   p_per_in_ler_id ID of FK column
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
Procedure chk_per_in_ler_id (p_pil_elctbl_chc_popl_id in number,
                             p_per_in_ler_id          in number,
                             p_effective_date         in date,
                             p_object_version_number  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_per_in_ler_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
      from  ben_per_in_ler a
     where  a.per_in_ler_id = p_per_in_ler_id
       and  a.per_in_ler_stat_cd = 'STRTD';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_pel_shd.api_updating
     (p_pil_elctbl_chc_popl_id  => p_pil_elctbl_chc_popl_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_per_in_ler_id,hr_api.g_number)
     <> nvl(ben_pel_shd.g_old_rec.per_in_ler_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if per_in_ler_id value exists in ben_per_in_ler table
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
        ben_pel_shd.constraint_error('BEN_PIL_ELCTBL_CHC_POPL_DT2');
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
-- |------< chk_lee_rsn_id >------|
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
--   p_pil_elctbl_chc_popl_id PK
--   p_lee_rsn_id ID of FK column
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
Procedure chk_lee_rsn_id (p_pil_elctbl_chc_popl_id          in number,
                            p_lee_rsn_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_lee_rsn_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_lee_rsn_f a
    where  a.lee_rsn_id = p_lee_rsn_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_pel_shd.api_updating
     (p_pil_elctbl_chc_popl_id            => p_pil_elctbl_chc_popl_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_lee_rsn_id,hr_api.g_number)
     <> nvl(ben_pel_shd.g_old_rec.lee_rsn_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if lee_rsn_id value exists in ben_lee_rsn_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_lee_rsn_f
        -- table.
        --
        ben_pel_shd.constraint_error('BEN_PIL_ELCTBL_CHC_POPL_DT1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_lee_rsn_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_perd_id >------|
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
--   p_pil_elctbl_chc_popl_id PK
--   p_enrt_perd_id ID of FK column
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
Procedure chk_enrt_perd_id (p_pil_elctbl_chc_popl_id          in number,
                            p_enrt_perd_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_perd_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_enrt_perd a
    where  a.enrt_perd_id = p_enrt_perd_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_pel_shd.api_updating
     (p_pil_elctbl_chc_popl_id  => p_pil_elctbl_chc_popl_id,
      p_object_version_number   => p_object_version_number);
  --
  if ((l_api_updating
     and nvl(p_enrt_perd_id,hr_api.g_number)
     <> nvl(ben_pel_shd.g_old_rec.enrt_perd_id,hr_api.g_number)) --Bug 4068639
     or not l_api_updating) and
     p_enrt_perd_id is not null then
    --
    -- check if enrt_perd_id value exists in ben_enrt_perd table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_enrt_perd
        -- table.
        --
        ben_pel_shd.constraint_error('BEN_PIL_ELCTBL_CHC_POPL_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_enrt_perd_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_typ_cycl_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pil_elctbl_chc_popl_id PK of record being inserted or updated.
--   enrt_typ_cycl_cd Value of lookup code.
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
Procedure chk_enrt_typ_cycl_cd(p_pil_elctbl_chc_popl_id   in number,
                            p_enrt_typ_cycl_cd            in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_typ_cycl_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pel_shd.api_updating
    (p_pil_elctbl_chc_popl_id                => p_pil_elctbl_chc_popl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_typ_cycl_cd
      <> nvl(ben_pel_shd.g_old_rec.enrt_typ_cycl_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enrt_typ_cycl_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT_TYP_CYCL',
           p_lookup_code    => p_enrt_typ_cycl_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_enrt_typ_cycl_cd);
      fnd_message.set_token('TYPE' ,'BEN_ENRT_TYP_CYCL');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_typ_cycl_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ws_stat_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_pil_elctbl_chc_popl_id PK of record being inserted or updated.
--   ws_stat_cd Value of lookup code.
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
Procedure chk_ws_stat_cd(p_pil_elctbl_chc_popl_id   in number,
                            p_ws_stat_cd            in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ws_stat_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pel_shd.api_updating
    (p_pil_elctbl_chc_popl_id                => p_pil_elctbl_chc_popl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_ws_stat_cd
      <> nvl(ben_pel_shd.g_old_rec.ws_stat_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_ws_stat_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_WS_STAT',
           p_lookup_code    => p_ws_stat_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_ws_stat_cd);
      fnd_message.set_token('TYPE' ,'BEN_WS_STAT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_ws_stat_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ws_acc_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_pil_elctbl_chc_popl_id PK of record being inserted or updated.
--   ws_acc_cd Value of lookup code.
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
Procedure chk_ws_acc_cd(p_pil_elctbl_chc_popl_id   in number,
                            p_ws_acc_cd            in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ws_acc_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pel_shd.api_updating
    (p_pil_elctbl_chc_popl_id                => p_pil_elctbl_chc_popl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_ws_acc_cd
      <> nvl(ben_pel_shd.g_old_rec.ws_acc_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_ws_acc_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_WS_ACC',
           p_lookup_code    => p_ws_acc_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_WS_ACC_CD);
      fnd_message.set_token('TYPE' ,'BEN_ws_acc');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_ws_acc_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_bdgt_stat_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_pil_elctbl_chc_popl_id PK of record being inserted or updated.
--   bdgt_stat_cd Value of lookup code.
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
Procedure chk_bdgt_stat_cd(p_pil_elctbl_chc_popl_id   in number,
                            p_bdgt_stat_cd            in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bdgt_stat_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pel_shd.api_updating
    (p_pil_elctbl_chc_popl_id                => p_pil_elctbl_chc_popl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_bdgt_stat_cd
      <> nvl(ben_pel_shd.g_old_rec.bdgt_stat_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bdgt_stat_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BDGT_STAT',
           p_lookup_code    => p_bdgt_stat_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_bdgt_stat_cd);
      fnd_message.set_token('TYPE' ,'BEN_BDGT_STAT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_bdgt_stat_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pop_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pil_elctbl_chc_popl_id PK of record being inserted or updated.
--   pop_cd Value of lookup code.
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
Procedure chk_pop_cd(p_pil_elctbl_chc_popl_id   in number,
                            p_pop_cd            in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pop_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pel_shd.api_updating
    (p_pil_elctbl_chc_popl_id                => p_pil_elctbl_chc_popl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pop_cd
      <> nvl(ben_pel_shd.g_old_rec.pop_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pop_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_POP',
           p_lookup_code    => p_pop_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_pop_cd);
      fnd_message.set_token('TYPE' ,'BEN_POP');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pop_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_bdgt_acc_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pil_elctbl_chc_popl_id PK of record being inserted or updated.
--   bdgt_acc_cd Value of lookup code.
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
Procedure chk_bdgt_acc_cd(p_pil_elctbl_chc_popl_id   in number,
                            p_bdgt_acc_cd            in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bdgt_acc_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pel_shd.api_updating
    (p_pil_elctbl_chc_popl_id                => p_pil_elctbl_chc_popl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_bdgt_acc_cd
      <> nvl(ben_pel_shd.g_old_rec.bdgt_acc_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bdgt_acc_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BDGT_ACC',
           p_lookup_code    => p_bdgt_acc_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_bdgt_acc_cd);
      fnd_message.set_token('TYPE' ,'BEN_BDGT_ACC');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_bdgt_acc_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cls_enrt_dt_to_use_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pil_elctbl_chc_popl_id PK of record being inserted or updated.
--   cls_enrt_dt_to_use_cd Value of lookup code.
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
Procedure chk_cls_enrt_dt_to_use_cd(p_pil_elctbl_chc_popl_id  in number,
                                    p_cls_enrt_dt_to_use_cd   in varchar2,
                                    p_effective_date          in date,
                                    p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cls_enrt_dt_to_use_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pel_shd.api_updating
    (p_pil_elctbl_chc_popl_id      => p_pil_elctbl_chc_popl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_cls_enrt_dt_to_use_cd
      <> nvl(ben_pel_shd.g_old_rec.cls_enrt_dt_to_use_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_cls_enrt_dt_to_use_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_CLS_ENRT_DT_TO_USE',
           p_lookup_code    => p_cls_enrt_dt_to_use_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_cls_enrt_dt_to_use_cd);
      fnd_message.set_token('TYPE' ,'BEN_CLS_ENRT_DT_TO_USE');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cls_enrt_dt_to_use_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_acty_ref_perd_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pil_elctbl_chc_popl_id PK of record being inserted or updated.
--   acty_ref_perd_cd Value of lookup code.
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
Procedure chk_acty_ref_perd_cd(p_pil_elctbl_chc_popl_id  in number,
                               p_acty_ref_perd_cd        in varchar2,
                               p_effective_date          in date,
                               p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_acty_ref_perd_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pel_shd.api_updating
    (p_pil_elctbl_chc_popl_id      => p_pil_elctbl_chc_popl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_acty_ref_perd_cd
      <> nvl(ben_pel_shd.g_old_rec.acty_ref_perd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_acty_ref_perd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ACTY_REF_PERD',
           p_lookup_code    => p_acty_ref_perd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_acty_ref_perd_cd);
      fnd_message.set_token('TYPE' ,'BEN_ACTY_REF_PERD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_acty_ref_perd_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pil_elctbl_popl_stat_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pil_elctbl_chc_popl_id PK of record being inserted or updated.
--   pil_elctbl_popl_stat_cd Value of lookup code.
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
Procedure chk_pil_elctbl_popl_stat_cd(p_pil_elctbl_chc_popl_id  in number,
                                      p_pil_elctbl_popl_stat_cd in varchar2,
                                      p_effective_date          in date,
                                      p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pil_elctbl_popl_stat_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pel_shd.api_updating
    (p_pil_elctbl_chc_popl_id                => p_pil_elctbl_chc_popl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pil_elctbl_popl_stat_cd
      <> nvl(ben_pel_shd.g_old_rec.pil_elctbl_popl_stat_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pil_elctbl_popl_stat_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PER_IN_LER_STAT',
           p_lookup_code    => p_pil_elctbl_popl_stat_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_pil_elctbl_popl_stat_cd);
      fnd_message.set_token('TYPE' ,'BEN_PER_IN_LER_STAT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pil_elctbl_popl_stat_cd;
--
--
Procedure chk_reinstate_cd(p_pil_elctbl_chc_popl_id   in number,
                            p_reinstate_cd          in varchar2,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'reinstate_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pel_shd.api_updating
    (p_pil_elctbl_chc_popl_id                => p_pil_elctbl_chc_popl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_reinstate_cd
      <> nvl(ben_pel_shd.g_old_rec.reinstate_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_reinstate_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_REINSTATE',
           p_lookup_code    => p_reinstate_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', P_REINSTATE_CD);
      fnd_message.set_token('TYPE' ,'BEN_REINSTATE');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_reinstate_cd;
--
--
Procedure chk_reinstate_ovrdn_cd(p_pil_elctbl_chc_popl_id   in number,
                            p_reinstate_ovrdn_cd          in varchar2,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'reinstate_ovrdn_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pel_shd.api_updating
    (p_pil_elctbl_chc_popl_id                => p_pil_elctbl_chc_popl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_reinstate_ovrdn_cd
      <> nvl(ben_pel_shd.g_old_rec.reinstate_ovrdn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_reinstate_ovrdn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_REINSTATE_OVRDN',
           p_lookup_code    => p_reinstate_ovrdn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', P_REINSTATE_OVRDN_CD);
      fnd_message.set_token('TYPE' ,'BEN_REINSTATE_OVRDN');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_reinstate_ovrdn_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_Enrt_Lee_Id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check mutual exclusive relationship between
--   Enrt_Perd and Lee_Rsn.
--
Procedure chk_Enrt_Lee_id(p_enrt_perd_id     in number
                         ,p_lee_rsn_id       in number
                         ,p_ENRT_TYP_CYCL_CD in varchar2
                          ) is
  --
  l_proc         varchar2(72) := g_package||'chk_Enrt_Lee_ID';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If ( nvl(p_Enrt_Typ_Cycl_cd,'X') = 'U') then
      NULL;
  Else
      if (p_enrt_perd_id is null and p_lee_rsn_id is null) then
          fnd_message.set_name('BEN','BEN_91850_PEL_ENRT_PERD_LER_ID');
          fnd_message.raise_error;
      elsif (p_enrt_perd_id is not null and p_lee_rsn_id is not null) then
          fnd_message.set_name('BEN','BEN_91850_PEL_ENRT_PERD_LER_ID');
          fnd_message.raise_error;
      end if;
  End if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_Enrt_Lee_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_enrt_perd_end >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that when the user tries to override
--   Enrt_Perd_end_DT or dflt_enrt_dt that the date cannot be set before the
--   system date and stat_cd can only be 'STRTD'.
--   Additionally if defaults were already applied (dflt_asnd_dt
--    has a value) don't allow update of the dflt_enrt_dt.
--
Procedure chk_dflt_enrt_perd_end(p_pil_elctbl_chc_popl_id in number
                                ,p_enrt_perd_strt_dt       in date
                                ,p_enrt_perd_end_dt       in date
                                ,p_dflt_enrt_dt           in date
                                ,p_dflt_asnd_dt           in date
                                ,p_procg_end_dt           in date
                				,p_pil_elctbl_popl_stat_cd in varchar2
                                ,p_object_version_number  in number
                          ) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_enrt_perd_end';
  l_system_date DATE;
  l_api_updating boolean;
  --
  /*   -- Bug 3653034
  cursor get_system_date IS
  select sysdate
  from   dual;
  */
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  /* -- No need to check with system date
  open get_system_date;
  fetch get_system_date into l_system_date;
  close get_system_date;
  */   -- Bug 3653034
  --
  l_api_updating := ben_pel_shd.api_updating
  (p_pil_elctbl_chc_popl_id                => p_pil_elctbl_chc_popl_id,
   p_object_version_number       => p_object_version_number);
  --
--  hr_utility.set_location('Me here :'||l_proc, 8);
  if (l_api_updating
      and p_enrt_perd_end_dt
      <> nvl(ben_pel_shd.g_old_rec.enrt_perd_end_dt,hr_api.g_date)) then
     If p_pil_elctbl_popl_stat_cd = 'STRTD' then
    /*
    if (trunc(p_enrt_perd_end_dt) < trunc(l_system_date)) then
           fnd_message.set_name('BEN','BEN_92298_ENRT_PEREND_LT_SYSD');
           fnd_message.raise_error;
        end if;
    */   -- Bug 3653034
    null;
     else
        fnd_message.set_name('BEN','BEN_92297_STAT_NOT_STRTD');
        fnd_message.raise_error;
     end if;
  End if;

--  hr_utility.set_location('Me here :'||l_proc, 10);
  --
  if (l_api_updating
      and p_dflt_enrt_dt
      <> nvl(ben_pel_shd.g_old_rec.dflt_enrt_dt,hr_api.g_date)) then
     If p_pil_elctbl_popl_stat_cd = 'STRTD' then
        If p_dflt_asnd_dt is not null then
           fnd_message.set_name('BEN','BEN_92295_DFLT_ENRT_W_ASND');
           fnd_message.raise_error;
       /*
       elsif (trunc(p_dflt_enrt_dt) < trunc(l_system_date)) then
           fnd_message.set_name('BEN','BEN_92296_DFLT_ENRT_LT_SYSD');
           fnd_message.raise_error;
        */   -- Bug 3653034
        end if;
     else
        fnd_message.set_name('BEN','BEN_92297_STAT_NOT_STRTD');
        fnd_message.raise_error;
     end if;
  End if;
  --
--  hr_utility.set_location('Me here :'||l_proc, 12);

  -- Added the following two validations for bug 3653034
  /* default enrollment date can be after processing end date per plan design
  If p_dflt_enrt_dt > p_procg_end_dt then
  	 fnd_message.set_name('BEN','BEN_94015_DFLT_ENRT_PROC_END');
     fnd_message.raise_error;
  End If;
 */

  If p_enrt_perd_end_dt > p_procg_end_dt then
    	 fnd_message.set_name('BEN','BEN_94014_PROC_END_ENRT_END');
       fnd_message.raise_error;
  End If;

  If p_enrt_perd_end_dt < p_enrt_perd_strt_dt then
    	 fnd_message.set_name('BEN','BEN_PDW_93536_SCH_ENRDT_CMP');
       fnd_message.raise_error;
  End If;

  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_enrt_perd_end;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_ws_mgr_id >---------------------------|
-- ----------------------------------------------------------------------------
--  Validates ws_mgr_id. Any person B, below in the hierarchy to person A,
--  cannot be re-assigned as the manager to A.
--
procedure chk_ws_mgr_id(
   p_pil_elctbl_chc_popl_id number,
   p_ws_mgr_id              number,
   p_effective_date         date) is

   cursor c1 is
   select per1.full_name person1,
          per2.full_name person2
     from ben_cwb_hrchy cwb1,
          ben_pil_elctbl_chc_popl pel1,
          ben_per_in_ler pil1,
          per_all_people_f per1,
          per_all_people_f per2
    where cwb1.mgr_pil_elctbl_chc_popl_id = p_pil_elctbl_chc_popl_id
      and cwb1.lvl_num > 0
      and pel1.pil_elctbl_chc_popl_id = cwb1.mgr_pil_elctbl_chc_popl_id
      and pil1.per_in_ler_id = pel1.per_in_ler_id
      and per1.person_id = pil1.person_id
      and trunc(p_effective_date) between per1.effective_start_date
      and per1.effective_end_date
      and per2.person_id = p_ws_mgr_id
      and trunc(p_effective_date) between per2.effective_start_date
      and per2.effective_end_date
      and exists
      ( select 'x'
          from ben_pil_elctbl_chc_popl pel2,
               ben_per_in_ler pil2
         where pil2.person_id = p_ws_mgr_id
           and pil2.lf_evt_ocrd_dt = pil1.lf_evt_ocrd_dt
           and pil2.ler_id = pil1.ler_id
           and pel2.per_in_ler_id = pil2.per_in_ler_id
           and pel2.pl_id = pel1.pl_id
           and pel2.pil_elctbl_chc_popl_id = cwb1.emp_pil_elctbl_chc_popl_id);

   l_person1 per_all_people_f.full_name%type;
   l_person2 per_all_people_f.full_name%type;
   l_proc varchar2(72) := g_package||'chk_ws_mgr_id';

begin

   hr_utility.set_location(' Entering:'||l_proc, 10);

   if (p_ws_mgr_id
       <> nvl(ben_pel_shd.g_old_rec.ws_mgr_id,hr_api.g_number)) then

      open c1;
      fetch c1 into l_person1,l_person2;
      if c1%found then
         close c1;
         fnd_message.set_name('BEN','BEN_93251_CWB_CANNOT_REASSIGN');
         fnd_message.set_token('PERSON1', l_person1);
         fnd_message.set_token('PERSON2', l_person2);
         fnd_message.raise_error;
      end if;
      close c1;

   end if;

   hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_ws_mgr_id;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_pel_shd.g_rec_type
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
  --
  chk_pil_elctbl_chc_popl_id
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_enrt_perd_id
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_enrt_perd_id            => p_rec.enrt_perd_id,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_enrt_typ_cycl_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_enrt_typ_cycl_cd        => p_rec.enrt_typ_cycl_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_cls_enrt_dt_to_use_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_cls_enrt_dt_to_use_cd   => p_rec.cls_enrt_dt_to_use_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_acty_ref_perd_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_acty_ref_perd_cd        => p_rec.acty_ref_perd_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_pil_elctbl_popl_stat_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_pil_elctbl_popl_stat_cd => p_rec.pil_elctbl_popl_stat_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_Enrt_Lee_id
  (p_enrt_perd_id            => p_rec.enrt_perd_id,
   p_lee_rsn_id              => p_rec.lee_rsn_id,
   p_enrt_typ_cycl_cd        => p_rec.enrt_typ_cycl_cd  );
  --
  chk_uom
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_uom                     => p_rec.uom,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number
  );
  --
  chk_bdgt_acc_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_bdgt_acc_cd             => p_rec.bdgt_acc_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number
  );
  --
  chk_pop_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_pop_cd                  => p_rec.pop_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number
  );
  --
  chk_bdgt_stat_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_bdgt_stat_cd            => p_rec.bdgt_stat_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number
  );
  --
  chk_ws_acc_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_ws_acc_cd               => p_rec.ws_acc_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number
  );
  --
  chk_ws_stat_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_ws_stat_cd              => p_rec.ws_stat_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number
  );
  --
  chk_reinstate_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_reinstate_cd            => p_rec.reinstate_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number
  );
  --
  chk_reinstate_ovrdn_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_reinstate_ovrdn_cd      => p_rec.reinstate_ovrdn_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_pel_shd.g_rec_type
                         ,p_effective_date in date) is
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
  --
  chk_pil_elctbl_chc_popl_id
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_enrt_perd_id
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_enrt_perd_id            => p_rec.enrt_perd_id,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_enrt_typ_cycl_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_enrt_typ_cycl_cd        => p_rec.enrt_typ_cycl_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_cls_enrt_dt_to_use_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_cls_enrt_dt_to_use_cd   => p_rec.cls_enrt_dt_to_use_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_acty_ref_perd_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_acty_ref_perd_cd        => p_rec.acty_ref_perd_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_pil_elctbl_popl_stat_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_pil_elctbl_popl_stat_cd => p_rec.pil_elctbl_popl_stat_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_Enrt_Lee_id
  (p_enrt_perd_id            => p_rec.enrt_perd_id,
   p_lee_rsn_id              => p_rec.lee_rsn_id,
   p_enrt_typ_cycl_cd        => p_rec.enrt_typ_cycl_cd );
  --
  chk_uom
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_uom                     => p_rec.uom,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number
  );
  --
  chk_dflt_enrt_perd_end
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_enrt_perd_strt_dt       => p_rec.enrt_perd_strt_dt,
   p_enrt_perd_end_dt        => p_rec.enrt_perd_end_dt,
   p_dflt_enrt_dt            => p_rec.dflt_enrt_dt,
   p_dflt_asnd_dt            => p_rec.dflt_asnd_dt,
   p_procg_end_dt            => p_rec.procg_end_dt,
   p_pil_elctbl_popl_stat_cd => p_rec.pil_elctbl_popl_stat_cd,
   p_object_version_number   => p_rec.object_version_number
  );
  --
  chk_bdgt_acc_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_bdgt_acc_cd             => p_rec.bdgt_acc_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number
  );
  --
  chk_pop_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_pop_cd                  => p_rec.pop_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number
  );
  --
  chk_bdgt_stat_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_bdgt_stat_cd            => p_rec.bdgt_stat_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number
  );
  --
  chk_ws_acc_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_ws_acc_cd               => p_rec.ws_acc_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number
  );
  --
  chk_ws_stat_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_ws_stat_cd              => p_rec.ws_stat_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number
  );
  --
  chk_reinstate_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_reinstate_cd            => p_rec.reinstate_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number
  );
  --
  chk_reinstate_ovrdn_cd
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_reinstate_ovrdn_cd      => p_rec.reinstate_ovrdn_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number
  );
  --
 /* Moved to bepilrhi.pkb
  chk_ws_mgr_id
  (p_pil_elctbl_chc_popl_id  => p_rec.pil_elctbl_chc_popl_id,
   p_ws_mgr_id               => p_rec.ws_mgr_id ,
   p_effective_date          => p_effective_date
  );
 */
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_pel_shd.g_rec_type
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
  (p_pil_elctbl_chc_popl_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_pil_elctbl_chc_popl b
    where b.pil_elctbl_chc_popl_id      = p_pil_elctbl_chc_popl_id
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
                             p_argument       => 'pil_elctbl_chc_popl_id',
                             p_argument_value => p_pil_elctbl_chc_popl_id);
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
end ben_pel_bus;

/
