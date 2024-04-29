--------------------------------------------------------
--  DDL for Package Body BEN_CCT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CCT_BUS" as
/* $Header: becctrhi.pkb 120.0 2005/05/28 00:58:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cct_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_cm_typ_id >---------------------------|
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
--   cm_typ_id PK of record being inserted or updated.
--   effective_date Effective Date of session
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
Procedure chk_cm_typ_id(p_cm_typ_id                in number,
                        p_effective_date           in date,
                        p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cm_typ_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cct_shd.api_updating
    (p_effective_date           => p_effective_date,
     p_cm_typ_id                => p_cm_typ_id,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_cm_typ_id,hr_api.g_number)
     <>  ben_cct_shd.g_old_rec.cm_typ_id) then
    --
    -- raise error as PK has changed
    --
    ben_cct_shd.constraint_error('BEN_CM_TYP_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_cm_typ_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_cct_shd.constraint_error('BEN_CM_TYP_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_cm_typ_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_name_unique >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that the  Name is unique
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_name is  name
--     p_benfts_grp_id is benfts_grp_id
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
---- ----------------------------------------------------------------------------
Procedure chk_name_unique
          ( p_cm_typ_id            in   number
           ,p_name                 in   varchar2
           ,p_business_group_id    in   number) is
  --
  l_proc      varchar2(72) := g_package||'chk_name_unique';
  l_dummy    char(1);
  cursor c1 is
    select null
    from   ben_cm_typ_f
    where  name = p_name
    and    cm_typ_id <> nvl(p_cm_typ_id,-1)
    and    business_group_id = p_business_group_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
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
-- |------------------------< chk_rcpent_cd >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cm_typ_id PK of record being inserted or updated.
--   rcpent_cd Value of lookup code.
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
Procedure chk_rcpent_cd(p_cm_typ_id                in number,
                        p_rcpent_cd                in varchar2,
                        p_effective_date           in date,
                        p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rcpent_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cct_shd.api_updating
    (p_cm_typ_id                => p_cm_typ_id,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and p_rcpent_cd
      <> nvl(ben_cct_shd.g_old_rec.rcpent_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_rcpent_cd is not null and hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RCPENT',
           p_lookup_code    => p_rcpent_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_rcpent_cd');
      fnd_message.set_token('TYPE','BEN_RCPENT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rcpent_cd;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_inspn_rqd_rl >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cm_typ_id PK of record being inserted or updated.
--   inspn_rqd_rl Value of formula rule id.
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
Procedure chk_inspn_rqd_rl(p_cm_typ_id                in number,
                           p_inspn_rqd_rl             in number,
                           p_effective_date           in date,
                           p_business_group_id        in number,
                           p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_inspn_rqd_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cct_shd.api_updating
    (p_cm_typ_id                => p_cm_typ_id,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_inspn_rqd_rl,hr_api.g_number)
      <> ben_cct_shd.g_old_rec.inspn_rqd_rl
      or not l_api_updating)
      and p_inspn_rqd_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
         (p_formula_id        => p_inspn_rqd_rl,
          p_formula_type_id   => -313,
          p_business_group_id => p_business_group_id,
          p_effective_date    => p_effective_date) then
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_inspn_rqd_rl);
      fnd_message.set_token('TYPE_ID',-313);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_inspn_rqd_rl;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_inspn_rqd_flag >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cm_typ_id PK of record being inserted or updated.
--   inspn_rqd_flag Value of lookup code.
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
Procedure chk_inspn_rqd_flag(p_cm_typ_id                in number,
                             p_inspn_rqd_flag           in varchar2,
                             p_effective_date           in date,
                             p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_inspn_rqd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cct_shd.api_updating
    (p_cm_typ_id                => p_cm_typ_id,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and p_inspn_rqd_flag
      <> nvl(ben_cct_shd.g_old_rec.inspn_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_inspn_rqd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_inspn_rqd_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_inspn_rqd_flag;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_to_be_sent_dt_rl >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cm_typ_id PK of record being inserted or updated.
--   to_be_sent_dt_rl Value of formula rule id.
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
Procedure chk_to_be_sent_dt_rl(p_cm_typ_id                in number,
                               p_to_be_sent_dt_rl         in number,
                               p_effective_date           in date,
                               p_business_group_id        in number,
                               p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_to_be_sent_dt_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cct_shd.api_updating
    (p_cm_typ_id                => p_cm_typ_id,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_to_be_sent_dt_rl,hr_api.g_number)
      <> ben_cct_shd.g_old_rec.to_be_sent_dt_rl
      or not l_api_updating)
      and p_to_be_sent_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
         (p_formula_id        => p_to_be_sent_dt_rl,
          p_formula_type_id   => -45,
          p_business_group_id => p_business_group_id,
          p_effective_date    => p_effective_date) then
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_to_be_sent_dt_rl);
      fnd_message.set_token('TYPE_ID',-45);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_to_be_sent_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_to_be_sent_dt_cd >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cm_typ_id PK of record being inserted or updated.
--   to_be_sent_dt_cd Value of lookup code.
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
Procedure chk_to_be_sent_dt_cd(p_cm_typ_id                in number,
                               p_to_be_sent_dt_cd         in varchar2,
                               p_effective_date           in date,
                               p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_to_be_sent_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cct_shd.api_updating
    (p_cm_typ_id                => p_cm_typ_id,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and p_to_be_sent_dt_cd
      <> nvl(ben_cct_shd.g_old_rec.to_be_sent_dt_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_TO_BE_SENT_DT',
           p_lookup_code    => p_to_be_sent_dt_cd,
           p_effective_date => p_effective_date)  or p_to_be_sent_dt_cd is null
      then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD',p_to_be_sent_dt_cd);
      fnd_message.set_token('TYPE','BEN_TO_BE_SENT_DT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_to_be_sent_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_trk_mlg_flag >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cm_typ_id PK of record being inserted or updated.
--   trk_mlg_flag Value of lookup code.
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
Procedure chk_trk_mlg_flag(p_cm_typ_id                in number,
                           p_trk_mlg_flag             in varchar2,
                           p_effective_date           in date,
                           p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_trk_mlg_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cct_shd.api_updating
    (p_cm_typ_id                => p_cm_typ_id,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and p_trk_mlg_flag
      <> nvl(ben_cct_shd.g_old_rec.trk_mlg_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_trk_mlg_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD',p_trk_mlg_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_trk_mlg_flag;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_pc_kit_cd >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cm_typ_id PK of record being inserted or updated.
--   pc_kit_cd Value of lookup code.
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
Procedure chk_pc_kit_cd(p_cm_typ_id               in number,
                        p_pc_kit_cd               in varchar2,
                        p_effective_date          in date,
                        p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pc_kit_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cct_shd.api_updating
    (p_cm_typ_id                => p_cm_typ_id,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and p_pc_kit_cd
      <> nvl(ben_cct_shd.g_old_rec.pc_kit_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pc_kit_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PC_KIT',
           p_lookup_code    => p_pc_kit_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD',p_pc_kit_cd);
      fnd_message.set_token('TYPE','BEN_PC_KIT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pc_kit_cd;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_whnvr_trgrd_flag >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cm_typ_id PK of record being inserted or updated.
--   whnvr_trgrd_flag Value of lookup code.
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
Procedure chk_whnvr_trgrd_flag(p_cm_typ_id                in number,
                               p_whnvr_trgrd_flag         in varchar2,
                               p_effective_date           in date,
                               p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_whnvr_trgrd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cct_shd.api_updating
    (p_cm_typ_id                => p_cm_typ_id,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and p_whnvr_trgrd_flag
      <> nvl(ben_cct_shd.g_old_rec.whnvr_trgrd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_whnvr_trgrd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_whnvr_trgrd_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_whnvr_trgrd_flag;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_cm_usg_cd >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cm_typ_id PK of record being inserted or updated.
--   cm_usg_cd Value of lookup code.
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
Procedure chk_cm_usg_cd(p_cm_typ_id              in number,
                     p_cm_usg_cd                 in varchar2,
                     p_effective_date         in date,
                     p_object_version_number  in number,
                     p_to_be_sent_dt_cd       in varchar2  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_cm_usg_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cct_shd.api_updating
    (p_cm_typ_id                => p_cm_typ_id,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and p_cm_usg_cd
      <> nvl(ben_cct_shd.g_old_rec.cm_usg_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_cm_usg_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_CM_USG',
           p_lookup_code    => p_cm_usg_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_cm_usg_cd');
      fnd_message.set_token('TYPE','BEN_USG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  -- bug 1384583 when the cm_usg_cod is 'SSIT' then validate p_to_be_sent dt for  'NA'
  if (p_cm_usg_cd = 'SSIT' and p_to_be_sent_dt_cd <>  'NA') or
     (p_to_be_sent_dt_cd='NA' and nvl(p_cm_usg_cd,' ') <> 'SSIT')  then
    fnd_message.set_name('BEN','BEN_92654_SENT_DATE_FOR_USAGE');
    fnd_message.set_token('TYPE','BEN_TO_BE_SENT_DT');
    fnd_message.raise_error;
  End if ;


  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cm_usg_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_cm_typ_rl >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cm_typ_id PK of record being inserted or updated.
--   cm_typ_rl Value of formula rule id.
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
Procedure chk_cm_typ_rl(p_cm_typ_id              in number,
                        p_cm_typ_rl              in number,
                        p_effective_date         in date,
                        p_business_group_id      in number,
                        p_object_version_number  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cm_typ_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cct_shd.api_updating
    (p_cm_typ_id                => p_cm_typ_id,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_cm_typ_rl,hr_api.g_number)
      <> ben_cct_shd.g_old_rec.cm_typ_rl
      or not l_api_updating)
      and p_cm_typ_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
         (p_formula_id        => p_cm_typ_rl,
          p_formula_type_id   => -332,
          p_business_group_id => p_business_group_id,
          p_effective_date    => p_effective_date) then
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_cm_typ_rl);
      fnd_message.set_token('TYPE_ID',-332);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cm_typ_rl;
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
            (p_cm_typ_id                     in number default hr_api.g_number,
	     p_datetrack_mode		     in varchar2,
             p_validation_start_date	     in date,
	     p_validation_end_date	     in date) Is
--
  l_proc	    varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name	    all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack update mode is valid
  --
  If (dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode)) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
hr_utility.set_location('*******b4 check min/max dates', 5);
    If ((nvl(p_cm_typ_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_cm_typ_f',
             p_base_key_column => 'cm_typ_id',
             p_base_key_value  => p_cm_typ_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_cm_typ_f';
      Raise l_integrity_error;
    End If;
hr_utility.set_location('*******after check min/max dates', 5);
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    ben_utility.parent_integrity_error(p_table_name => l_table_name);
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
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
            (p_cm_typ_id		in number,
             p_datetrack_mode		in varchar2,
	     p_validation_start_date	in date,
	     p_validation_end_date	in date) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
  l_table_name	all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = 'DELETE' or
      p_datetrack_mode = 'ZAP') then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'cm_typ_id',
       p_argument_value => p_cm_typ_id);
    --
hr_utility.set_location('*******b4 check rows exist', 5);
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_cm_typ_f',
           p_base_key_column => 'parnt_cm_typ_id',
           p_base_key_value  => p_cm_typ_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_cm_typ_f';
      Raise l_rows_exist;
    End If;
hr_utility.set_location('*******after check rows exist', 5);
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_cm_typ_trgr_f',
           p_base_key_column => 'cm_typ_id',
           p_base_key_value  => p_cm_typ_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_cm_typ_trgr_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_cm_typ_usg_f',
           p_base_key_column => 'cm_typ_id',
           p_base_key_value  => p_cm_typ_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_cm_typ_usg_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_per_cm_f',
           p_base_key_column => 'cm_typ_id',
           p_base_key_value  => p_cm_typ_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_per_cm_f';
      Raise l_rows_exist;
    End If;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
  ben_utility.child_exists_error(p_table_name => l_table_name);
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in ben_cct_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_cm_typ_id
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
chk_name_unique
     ( p_cm_typ_id           => p_rec.cm_typ_id
      ,p_name                => p_rec.name
      ,p_business_group_id   => p_rec.business_group_id);
--
  chk_rcpent_cd
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_rcpent_cd             => p_rec.rcpent_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_inspn_rqd_rl
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_inspn_rqd_rl          => p_rec.inspn_rqd_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_inspn_rqd_flag
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_inspn_rqd_flag        => p_rec.inspn_rqd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_to_be_sent_dt_rl
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_to_be_sent_dt_rl      => p_rec.to_be_sent_dt_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_to_be_sent_dt_cd
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_to_be_sent_dt_cd      => p_rec.to_be_sent_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_trk_mlg_flag
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_trk_mlg_flag          => p_rec.trk_mlg_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pc_kit_cd
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_pc_kit_cd             => p_rec.pc_kit_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_whnvr_trgrd_flag
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_whnvr_trgrd_flag      => p_rec.whnvr_trgrd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cm_usg_cd
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_cm_usg_cd             => p_rec.cm_usg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_to_be_sent_dt_cd      => p_rec.to_be_sent_dt_cd );
  --
  chk_cm_typ_rl
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_cm_typ_rl             => p_rec.cm_typ_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_cct_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_cm_typ_id
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
chk_name_unique
     ( p_cm_typ_id           => p_rec.cm_typ_id
      ,p_name                => p_rec.name
      ,p_business_group_id   => p_rec.business_group_id);

--
  chk_rcpent_cd
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_rcpent_cd             => p_rec.rcpent_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_inspn_rqd_rl
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_inspn_rqd_rl          => p_rec.inspn_rqd_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_inspn_rqd_flag
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_inspn_rqd_flag        => p_rec.inspn_rqd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_to_be_sent_dt_rl
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_to_be_sent_dt_rl      => p_rec.to_be_sent_dt_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_to_be_sent_dt_cd
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_to_be_sent_dt_cd      => p_rec.to_be_sent_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_trk_mlg_flag
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_trk_mlg_flag          => p_rec.trk_mlg_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pc_kit_cd
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_pc_kit_cd             => p_rec.pc_kit_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_whnvr_trgrd_flag
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_whnvr_trgrd_flag      => p_rec.whnvr_trgrd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cm_usg_cd
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_cm_usg_cd             => p_rec.cm_usg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_to_be_sent_dt_cd      => p_rec.to_be_sent_dt_cd );
  --
  chk_cm_typ_rl
  (p_cm_typ_id             => p_rec.cm_typ_id,
   p_cm_typ_rl             => p_rec.cm_typ_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_cm_typ_id                     => p_rec.cm_typ_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ben_cct_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode		=> p_datetrack_mode,
     p_validation_start_date	=> p_validation_start_date,
     p_validation_end_date	=> p_validation_end_date,
     p_cm_typ_id		=> p_rec.cm_typ_id);
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
  (p_cm_typ_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_cm_typ_f b
    where b.cm_typ_id      = p_cm_typ_id
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
                             p_argument       => 'cm_typ_id',
                             p_argument_value => p_cm_typ_id);
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
end ben_cct_bus;

/
