--------------------------------------------------------
--  DDL for Package Body BEN_BPR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BPR_BUS" as
/* $Header: bebprrhi.pkb 120.0.12010000.2 2008/08/05 14:12:50 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bpr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_bnft_pool_rlovr_rqmt_id >------|
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
--   bnft_pool_rlovr_rqmt_id PK of record being inserted or updated.
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
Procedure chk_bnft_pool_rlovr_rqmt_id(p_bnft_pool_rlovr_rqmt_id  in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bnft_pool_rlovr_rqmt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bpr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_bnft_pool_rlovr_rqmt_id                => p_bnft_pool_rlovr_rqmt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_bnft_pool_rlovr_rqmt_id,hr_api.g_number)
     <>  ben_bpr_shd.g_old_rec.bnft_pool_rlovr_rqmt_id) then
    --
    -- raise error as PK has changed
    --
    ben_bpr_shd.constraint_error('BEN_BNFT_POOL_RLOVR_RQMT_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_bnft_pool_rlovr_rqmt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_bpr_shd.constraint_error('BEN_BNFT_POOL_RLOVR_RQMT_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_bnft_pool_rlovr_rqmt_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_mutual_exlsv_mn_val_flg >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the mutual exclusive fields
--   no_mn_rlovr_val_dfnd_flag and mn_rlovr_val
--   are set correctly.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_bnft_pool_rlovr_rqmt_id    PK of record being inserted or updated.
--   p_no_mn_rlovr_val_dfnd_flag Flag
--   p_mn_rlovr_val         Number.
--   p_effective_date        Session date of record.
--   p_object_version_number Object version number of record being
--                           inserted or updated.
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
Procedure chk_mutual_exlsv_mn_val_flg(p_bnft_pool_rlovr_rqmt_id  in number,
                                     p_no_mn_rlovr_val_dfnd_flag in varchar2,
                                     p_mn_rlovr_val              in number,
                                     p_effective_date            in date,
                                     p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mutual_exlsv_mn_val_flg';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bpr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_bnft_pool_rlovr_rqmt_id                => p_bnft_pool_rlovr_rqmt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (p_no_mn_rlovr_val_dfnd_flag = 'Y' and
      p_mn_rlovr_val is not null) then
    --
    -- OK fields are not mutaully exclusive so raise an error
    --
    fnd_message.set_name('BEN','BEN_91714_MUT_EXLSV_MN_VAL_FLG');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_mutual_exlsv_mn_val_flg;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_mutual_exlsv_mx_val_flg >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the mutual exclusive fields
--   no_mx_rlovr_val_dfnd_flag and mx_rlovr_val
--   are set correctly.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_bnft_pool_rlovr_rqmt_id    PK of record being inserted or updated.
--   p_no_mx_rlovr_val_dfnd_flag Flag
--   p_mx_rlovr_val         Number.
--   p_effective_date        Session date of record.
--   p_object_version_number Object version number of record being
--                           inserted or updated.
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
Procedure chk_mutual_exlsv_mx_val_flg(p_bnft_pool_rlovr_rqmt_id  in number,
                                     p_no_mx_rlovr_val_dfnd_flag in varchar2,
                                     p_mx_rlovr_val              in number,
                                     p_effective_date            in date,
                                     p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mutual_exlsv_mx_val_flg';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bpr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_bnft_pool_rlovr_rqmt_id                => p_bnft_pool_rlovr_rqmt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (p_no_mx_rlovr_val_dfnd_flag = 'Y' and
      p_mx_rlovr_val is not null) then
    --
    -- OK fields are not mutaully exclusive so raise an error
    --
    fnd_message.set_name('BEN','BEN_91715_MUT_EXLSV_MX_VAL_FLG');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_mutual_exlsv_mx_val_flg;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_mutual_exlsv_mn_pct_flg >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the mutual exclusive fields
--   no_mn_rlovr_pct_dfnd_flag and mn_rlovr_pct_num
--   are set correctly.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_bnft_pool_rlovr_rqmt_id    PK of record being inserted or updated.
--   p_no_mn_rlovr_pct_dfnd_flag Flag
--   p_mn_rlovr_pct_num         Number.
--   p_effective_date        Session date of record.
--   p_object_version_number Object version number of record being
--                           inserted or updated.
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
Procedure chk_mutual_exlsv_mn_pct_flg(p_bnft_pool_rlovr_rqmt_id  in number,
                                     p_no_mn_rlovr_pct_dfnd_flag in varchar2,
                                     p_mn_rlovr_pct_num              in number,
                                     p_effective_date            in date,
                                     p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mutual_exlsv_mn_pct_flg';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bpr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_bnft_pool_rlovr_rqmt_id                => p_bnft_pool_rlovr_rqmt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (p_no_mn_rlovr_pct_dfnd_flag = 'Y' and
      p_mn_rlovr_pct_num is not null) then
    --
    -- OK fields are not mutaully exclusive so raise an error
    --
    fnd_message.set_name('BEN','BEN_91716_MUT_EXLSV_MN_PCT_FLG');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_mutual_exlsv_mn_pct_flg;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_mutual_exlsv_mx_pct_flg >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the mutual exclusive fields
--   no_mx_rlovr_pct_dfnd_flag and mx_rlovr_pct_num
--   are set correctly.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_bnft_pool_rlovr_rqmt_id    PK of record being inserted or updated.
--   p_no_mx_rlovr_pct_dfnd_flag Flag
--   p_mx_rlovr_pct_num         Number.
--   p_effective_date        Session date of record.
--   p_object_version_number Object version number of record being
--                           inserted or updated.
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
Procedure chk_mutual_exlsv_mx_pct_flg(p_bnft_pool_rlovr_rqmt_id  in number,
                                     p_no_mx_rlovr_pct_dfnd_flag in varchar2,
                                     p_mx_rlovr_pct_num              in number,
                                     p_effective_date            in date,
                                     p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mutual_exlsv_mn_pct_flg';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bpr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_bnft_pool_rlovr_rqmt_id                => p_bnft_pool_rlovr_rqmt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (p_no_mx_rlovr_pct_dfnd_flag = 'Y' and
      p_mx_rlovr_pct_num is not null) then
    --
    -- OK fields are not mutaully exclusive so raise an error
    --
    fnd_message.set_name('BEN','BEN_91717_MUT_EXLSV_MX_PCT_FLG');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_mutual_exlsv_mx_pct_flg;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pct_rndg_cd_rl_dpndcy >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the code/rule dependency as following:
--             If code = 'Rule' then rule must be selected.
--             If code <> 'Rule' then rule must not be selected.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_bnft_pool_rlovr_rqmt_id PK of record being inserted or updated.
--   p_pct_rndg_cd        lookup code.
--   p_pct_rndg_rl        Rule
--   p_effective_date     effective date
--   p_object_version_number Object version number of record being
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
Procedure chk_pct_rndg_cd_rl_dpndcy
                           (p_bnft_pool_rlovr_rqmt_id in number,
                            p_pct_rndg_cd           in varchar2,
                            p_pct_rndg_rl           in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pct_rndg_cd_rl_dpndcy ';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bpr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_bnft_pool_rlovr_rqmt_id                => p_bnft_pool_rlovr_rqmt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_pct_rndg_cd,hr_api.g_varchar2)
               <> nvl(ben_bpr_shd.g_old_rec.pct_rndg_cd,hr_api.g_varchar2) or
          nvl(p_pct_rndg_rl,hr_api.g_number)
               <> nvl(ben_bpr_shd.g_old_rec.pct_rndg_rl,hr_api.g_number))
      or not l_api_updating) then
    --
    if (p_pct_rndg_cd = 'RL' and p_pct_rndg_rl is null) then
             --
          fnd_message.set_name('BEN','BEN_91019_RULE_REQUIRED');
          fnd_message.raise_error;
             --
    end if;
    --
    if nvl(p_pct_rndg_cd,hr_api.g_varchar2) <> 'RL' and p_pct_rndg_rl is not null then
             --
          fnd_message.set_name('BEN','BEN_91713_CODE_NOT_RULE');
          fnd_message.raise_error;
             --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pct_rndg_cd_rl_dpndcy;
--
-- ----------------------------------------------------------------------------
-- |------< chk_val_rndg_cd_rl_dpndcy >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the code/rule dependency as following:
--             If code = 'Rule' then rule must be selected.
--             If code <> 'Rule' then rule must not be selected.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_bnft_pool_rlovr_rqmt_id PK of record being inserted or updated.
--   p_val_rndg_cd        lookup code.
--   p_val_rndg_rl        Rule
--   p_effective_date     effective date
--   p_object_version_number Object version number of record being
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
Procedure chk_val_rndg_cd_rl_dpndcy
                           (p_bnft_pool_rlovr_rqmt_id    in number,
                            p_val_rndg_cd           in varchar2,
                            p_val_rndg_rl           in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_val_rndg_cd_rl_dpndcy ';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bpr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_bnft_pool_rlovr_rqmt_id                => p_bnft_pool_rlovr_rqmt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_val_rndg_cd,hr_api.g_varchar2)
               <> nvl(ben_bpr_shd.g_old_rec.val_rndg_cd,hr_api.g_varchar2) or
          nvl(p_val_rndg_rl,hr_api.g_number)
               <> nvl(ben_bpr_shd.g_old_rec.val_rndg_rl,hr_api.g_number))
      or not l_api_updating) then
    --
    if (p_val_rndg_cd = 'RL' and p_val_rndg_rl is null) then
             --
          fnd_message.set_name('BEN','BEN_91019_RULE_REQUIRED');
          fnd_message.raise_error;
             --
    end if;
    --
    if nvl(p_val_rndg_cd,hr_api.g_varchar2) <> 'RL' and p_val_rndg_rl is not null then
             --
          fnd_message.set_name('BEN','BEN_91713_CODE_NOT_RULE');
          fnd_message.raise_error;
             --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_val_rndg_cd_rl_dpndcy;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pct_rndg_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   bnft_pool_rlovr_rqmt_id PK of record being inserted or updated.
--   pct_rndg_cd Value of lookup code.
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
Procedure chk_pct_rndg_cd(p_bnft_pool_rlovr_rqmt_id                in number,
                            p_pct_rndg_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pct_rndg_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bpr_shd.api_updating
    (p_bnft_pool_rlovr_rqmt_id                => p_bnft_pool_rlovr_rqmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pct_rndg_cd
      <> nvl(ben_bpr_shd.g_old_rec.pct_rndg_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pct_rndg_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RNDG',
           p_lookup_code    => p_pct_rndg_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_pct_rndg_cd');
      fnd_message.set_token('TYPE','BEN_RNDG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pct_rndg_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_val_rndg_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   bnft_pool_rlovr_rqmt_id PK of record being inserted or updated.
--   val_rndg_rl Value of formula rule id.
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
Procedure chk_val_rndg_rl(p_bnft_pool_rlovr_rqmt_id        in number,
                             p_val_rndg_rl                 in number,
                             p_business_group_id           in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_val_rndg_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_val_rndg_rl
    and    ff.formula_type_id = -169
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
  l_api_updating := ben_bpr_shd.api_updating
    (p_bnft_pool_rlovr_rqmt_id                => p_bnft_pool_rlovr_rqmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_val_rndg_rl,hr_api.g_number)
      <> ben_bpr_shd.g_old_rec.val_rndg_rl
      or not l_api_updating)
      and p_val_rndg_rl is not null then
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
        fnd_message.set_token('ID',p_val_rndg_rl);
        fnd_message.set_token('TYPE_ID',-169);
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
end chk_val_rndg_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_val_rndg_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   bnft_pool_rlovr_rqmt_id PK of record being inserted or updated.
--   val_rndg_cd Value of lookup code.
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
Procedure chk_val_rndg_cd(p_bnft_pool_rlovr_rqmt_id                in number,
                            p_val_rndg_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_val_rndg_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bpr_shd.api_updating
    (p_bnft_pool_rlovr_rqmt_id                => p_bnft_pool_rlovr_rqmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_val_rndg_cd
      <> nvl(ben_bpr_shd.g_old_rec.val_rndg_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_val_rndg_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RNDG',
           p_lookup_code    => p_val_rndg_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_val_rndg_cd');
      fnd_message.set_token('TYPE','BEN_RNDG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_val_rndg_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mx_rlovr_val_dfnd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   bnft_pool_rlovr_rqmt_id PK of record being inserted or updated.
--   no_mx_rlovr_val_dfnd_flag Value of lookup code.
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
Procedure chk_no_mx_rlovr_val_dfnd_flag(p_bnft_pool_rlovr_rqmt_id                in number,
                            p_no_mx_rlovr_val_dfnd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_rlovr_val_dfnd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bpr_shd.api_updating
    (p_bnft_pool_rlovr_rqmt_id                => p_bnft_pool_rlovr_rqmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_rlovr_val_dfnd_flag
      <> nvl(ben_bpr_shd.g_old_rec.no_mx_rlovr_val_dfnd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_rlovr_val_dfnd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91006_INVALID_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_rlovr_val_dfnd_flag;

-- ----------------------------------------------------------------------------
-- |------< chk_rlovr_val_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   bnft_pool_rlovr_rqmt_id PK of record being inserted or updated.
--   rlovr_val_rl Value of formula rule id.
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
Procedure chk_rlovr_val_rl(p_bnft_pool_rlovr_rqmt_id        in number,
                             p_rlovr_val_rl                 in number,
                             p_business_group_id           in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rlovr_val_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_rlovr_val_rl
    and    ff.formula_type_id = -532 /* */
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
  l_api_updating := ben_bpr_shd.api_updating
    (p_bnft_pool_rlovr_rqmt_id     => p_bnft_pool_rlovr_rqmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rlovr_val_rl,hr_api.g_number)
      <> ben_bpr_shd.g_old_rec.rlovr_val_rl
      or not l_api_updating)
      and p_rlovr_val_rl is not null then
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
        fnd_message.set_token('ID',p_rlovr_val_rl);
        fnd_message.set_token('TYPE_ID',-532);
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
end chk_rlovr_val_rl;

--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mn_rlovr_val_dfnd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   bnft_pool_rlovr_rqmt_id PK of record being inserted or updated.
--   no_mn_rlovr_val_dfnd_flag Value of lookup code.
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
Procedure chk_no_mn_rlovr_val_dfnd_flag(p_bnft_pool_rlovr_rqmt_id                in number,
                            p_no_mn_rlovr_val_dfnd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mn_rlovr_val_dfnd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bpr_shd.api_updating
    (p_bnft_pool_rlovr_rqmt_id                => p_bnft_pool_rlovr_rqmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mn_rlovr_val_dfnd_flag
      <> nvl(ben_bpr_shd.g_old_rec.no_mn_rlovr_val_dfnd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mn_rlovr_val_dfnd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91006_INVALID_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mn_rlovr_val_dfnd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mx_rlovr_pct_dfnd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   bnft_pool_rlovr_rqmt_id PK of record being inserted or updated.
--   no_mx_rlovr_pct_dfnd_flag Value of lookup code.
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
Procedure chk_no_mx_rlovr_pct_dfnd_flag(p_bnft_pool_rlovr_rqmt_id                in number,
                            p_no_mx_rlovr_pct_dfnd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_rlovr_pct_dfnd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bpr_shd.api_updating
    (p_bnft_pool_rlovr_rqmt_id                => p_bnft_pool_rlovr_rqmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_rlovr_pct_dfnd_flag
      <> nvl(ben_bpr_shd.g_old_rec.no_mx_rlovr_pct_dfnd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_rlovr_pct_dfnd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91006_INVALID_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_rlovr_pct_dfnd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mn_rlovr_pct_dfnd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   bnft_pool_rlovr_rqmt_id PK of record being inserted or updated.
--   no_mn_rlovr_pct_dfnd_flag Value of lookup code.
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
Procedure chk_no_mn_rlovr_pct_dfnd_flag(p_bnft_pool_rlovr_rqmt_id                in number,
                            p_no_mn_rlovr_pct_dfnd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mn_rlovr_pct_dfnd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bpr_shd.api_updating
    (p_bnft_pool_rlovr_rqmt_id                => p_bnft_pool_rlovr_rqmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mn_rlovr_pct_dfnd_flag
      <> nvl(ben_bpr_shd.g_old_rec.no_mn_rlovr_pct_dfnd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mn_rlovr_pct_dfnd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91006_INVALID_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mn_rlovr_pct_dfnd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_crs_rlovr_procg_cd >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   bnft_pool_rlovr_rqmt_id PK of record being inserted or updated.
--   no_mn_rlovr_val_dfnd_flag Value of lookup code.
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
Procedure chk_crs_rlovr_procg_cd
            (p_bnft_pool_rlovr_rqmt_id     in number,
             p_crs_rlovr_procg_cd          in varchar2,
             p_effective_date              in date,
             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_crs_rlovr_procg_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bpr_shd.api_updating
    (p_bnft_pool_rlovr_rqmt_id     => p_bnft_pool_rlovr_rqmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  hr_utility.set_location('p_crs_rlovr_procg_cd:'||p_crs_rlovr_procg_cd, 5);
  if (l_api_updating
      and p_crs_rlovr_procg_cd
      <> nvl(ben_bpr_shd.g_old_rec.crs_rlovr_procg_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_crs_rlovr_procg_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_CRS_RLOVR_PROCG',
           p_lookup_code    => p_crs_rlovr_procg_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_crs_rlovr_procg_cd');
      fnd_message.set_token('TYPE','BEN_CRS_RLOVR_PROCG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_crs_rlovr_procg_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pct_rndg_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   bnft_pool_rlovr_rqmt_id PK of record being inserted or updated.
--   pct_rndg_rl Value of formula rule id.
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
Procedure chk_pct_rndg_rl(p_bnft_pool_rlovr_rqmt_id        in number,
                             p_pct_rndg_rl                 in number,
                             p_business_group_id           in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pct_rndg_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_pct_rndg_rl
    and    ff.formula_type_id = -169 /*default enrollment det */
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
  l_api_updating := ben_bpr_shd.api_updating
    (p_bnft_pool_rlovr_rqmt_id                => p_bnft_pool_rlovr_rqmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_pct_rndg_rl,hr_api.g_number)
      <> ben_bpr_shd.g_old_rec.pct_rndg_rl
      or not l_api_updating)
      and p_pct_rndg_rl is not null then
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
        fnd_message.set_token('ID',p_pct_rndg_rl);
        fnd_message.set_token('TYPE_ID',-169);
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
end chk_pct_rndg_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_prtt_elig_rlovr_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   bnft_pool_rlovr_rqmt_id     PK of record being inserted or updated.
--   prtt_elig_rlovr_rl          Value of formula rule id.
--   effective_date              effective date
--   object_version_number       Object version number of record being
--                               inserted or updated.
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
Procedure chk_prtt_elig_rlovr_rl(p_bnft_pool_rlovr_rqmt_id   in number,
                             p_prtt_elig_rlovr_rl            in number,
                             p_business_group_id             in number,
                             p_effective_date                in date,
                             p_object_version_number         in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtt_elig_rlovr_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_prtt_elig_rlovr_rl
    and    ff.formula_type_id = -294
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
  l_api_updating := ben_bpr_shd.api_updating
    (p_bnft_pool_rlovr_rqmt_id     => p_bnft_pool_rlovr_rqmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_prtt_elig_rlovr_rl,hr_api.g_number)
      <> ben_bpr_shd.g_old_rec.prtt_elig_rlovr_rl
      or not l_api_updating)
      and p_prtt_elig_rlovr_rl is not null then
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
        fnd_message.set_token('ID',p_prtt_elig_rlovr_rl);
        fnd_message.set_token('TYPE_ID',-294);
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
end chk_prtt_elig_rlovr_rl;





-- ----------------------------------------------------------------------------
-- |--------------------------< chk_abr_dups >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_abr_dups
            (p_acty_base_rt_id               in number default hr_api.g_number,
             p_bnft_prvdr_pool_id            in number default hr_api.g_number,
             p_bnft_pool_rlovr_rqmt_id       in number default hr_api.g_number,
             p_effective_date                in date
             ) Is

l_proc            varchar2(72) := g_package||'chk_abr_dups';

cursor c_abp is
 select 'x'
 from  ben_bnft_pool_rlovr_rqmt_f
 where bnft_prvdr_pool_id = p_bnft_prvdr_pool_id
   and acty_base_rt_id    = p_acty_base_rt_id
   and bnft_pool_rlovr_rqmt_id <> nvl(p_bnft_pool_rlovr_rqmt_id,-1)
   and p_effective_date  between effective_start_date
       and effective_end_date   ;

l_dummy_var  varchar2(1) ;

begin

  hr_utility.set_location('Entering:'||l_proc, 5);
   open c_abp ;
   fetch c_abp into l_dummy_var ;
   if c_abp%found then
      hr_utility.set_location('dupes:'||l_proc, 5);
     close c_abp ;
     fnd_message.set_name('BEN', 'BEN_92992_DUPS_ROW');
     fnd_message.set_token('VAR1', 'Rollover Requirements');
     fnd_message.set_token('VAR2','Benefit Pool');
     fnd_message.raise_error;
   end if ;
   close c_abp ;

   hr_utility.set_location('Leaving:'||l_proc, 10);

end chk_abr_dups ;
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
            (p_acty_base_rt_id               in number default hr_api.g_number,
             p_bnft_prvdr_pool_id            in number default hr_api.g_number,
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
    If ((nvl(p_acty_base_rt_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_acty_base_rt_f',
             p_base_key_column => 'acty_base_rt_id',
             p_base_key_value  => p_acty_base_rt_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_acty_base_rt_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_bnft_prvdr_pool_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_bnft_prvdr_pool_f',
             p_base_key_column => 'bnft_prvdr_pool_id',
             p_base_key_value  => p_bnft_prvdr_pool_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_bnft_prvdr_pool_f';
      Raise l_integrity_error;
    End If;
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
    --
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
            (p_bnft_pool_rlovr_rqmt_id		in number,
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
       p_argument       => 'bnft_pool_rlovr_rqmt_id',
       p_argument_value => p_bnft_pool_rlovr_rqmt_id);
    --
    --
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
    --
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in ben_bpr_shd.g_rec_type,
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
  chk_bnft_pool_rlovr_rqmt_id
  (p_bnft_pool_rlovr_rqmt_id => p_rec.bnft_pool_rlovr_rqmt_id,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_mutual_exlsv_mn_val_flg
     ( p_bnft_pool_rlovr_rqmt_id     => p_rec.bnft_pool_rlovr_rqmt_id
      ,p_no_mn_rlovr_val_dfnd_flag  => p_rec.no_mn_rlovr_val_dfnd_flag
      ,p_mn_rlovr_val      => p_rec.mn_rlovr_val
      ,p_effective_date         => p_effective_date
      ,p_object_version_number  => p_rec.object_version_number);
  --
  chk_mutual_exlsv_mx_val_flg
     ( p_bnft_pool_rlovr_rqmt_id     => p_rec.bnft_pool_rlovr_rqmt_id
      ,p_no_mx_rlovr_val_dfnd_flag  => p_rec.no_mx_rlovr_val_dfnd_flag
      ,p_mx_rlovr_val      => p_rec.mx_rlovr_val
      ,p_effective_date         => p_effective_date
      ,p_object_version_number  => p_rec.object_version_number);
  --
  chk_mutual_exlsv_mn_pct_flg
     ( p_bnft_pool_rlovr_rqmt_id     => p_rec.bnft_pool_rlovr_rqmt_id
      ,p_no_mn_rlovr_pct_dfnd_flag  => p_rec.no_mn_rlovr_pct_dfnd_flag
      ,p_mn_rlovr_pct_num      => p_rec.mn_rlovr_pct_num
      ,p_effective_date         => p_effective_date
      ,p_object_version_number  => p_rec.object_version_number);
  --
  chk_mutual_exlsv_mx_pct_flg
     ( p_bnft_pool_rlovr_rqmt_id     => p_rec.bnft_pool_rlovr_rqmt_id
      ,p_no_mx_rlovr_pct_dfnd_flag  => p_rec.no_mx_rlovr_pct_dfnd_flag
      ,p_mx_rlovr_pct_num      => p_rec.mx_rlovr_pct_num
      ,p_effective_date         => p_effective_date
      ,p_object_version_number  => p_rec.object_version_number);
  --
  chk_pct_rndg_cd_rl_dpndcy
     ( p_bnft_pool_rlovr_rqmt_id     => p_rec.bnft_pool_rlovr_rqmt_id
      ,p_pct_rndg_cd            => p_rec.pct_rndg_cd
      ,p_pct_rndg_rl            => p_rec.pct_rndg_rl
      ,p_effective_date         => p_effective_date
      ,p_object_version_number  => p_rec.object_version_number);
  --
  chk_val_rndg_cd_rl_dpndcy
     ( p_bnft_pool_rlovr_rqmt_id     => p_rec.bnft_pool_rlovr_rqmt_id
      ,p_val_rndg_cd            => p_rec.val_rndg_cd
      ,p_val_rndg_rl            => p_rec.val_rndg_rl
      ,p_effective_date         => p_effective_date
      ,p_object_version_number  => p_rec.object_version_number);
  --
  chk_pct_rndg_cd
  (p_bnft_pool_rlovr_rqmt_id          => p_rec.bnft_pool_rlovr_rqmt_id,
   p_pct_rndg_cd         => p_rec.pct_rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_val_rndg_rl
  (p_bnft_pool_rlovr_rqmt_id          => p_rec.bnft_pool_rlovr_rqmt_id,
   p_val_rndg_rl        => p_rec.val_rndg_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_val_rndg_cd
  (p_bnft_pool_rlovr_rqmt_id          => p_rec.bnft_pool_rlovr_rqmt_id,
   p_val_rndg_cd         => p_rec.val_rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_rlovr_val_dfnd_flag
  (p_bnft_pool_rlovr_rqmt_id          => p_rec.bnft_pool_rlovr_rqmt_id,
   p_no_mx_rlovr_val_dfnd_flag         => p_rec.no_mx_rlovr_val_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mn_rlovr_val_dfnd_flag
  (p_bnft_pool_rlovr_rqmt_id          => p_rec.bnft_pool_rlovr_rqmt_id,
   p_no_mn_rlovr_val_dfnd_flag         => p_rec.no_mn_rlovr_val_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_rlovr_pct_dfnd_flag
  (p_bnft_pool_rlovr_rqmt_id          => p_rec.bnft_pool_rlovr_rqmt_id,
   p_no_mx_rlovr_pct_dfnd_flag         => p_rec.no_mx_rlovr_pct_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mn_rlovr_pct_dfnd_flag
  (p_bnft_pool_rlovr_rqmt_id          => p_rec.bnft_pool_rlovr_rqmt_id,
   p_no_mn_rlovr_pct_dfnd_flag         => p_rec.no_mn_rlovr_pct_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crs_rlovr_procg_cd
  (p_bnft_pool_rlovr_rqmt_id => p_rec.bnft_pool_rlovr_rqmt_id,
   p_crs_rlovr_procg_cd      => p_rec.crs_rlovr_procg_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_pct_rndg_rl
  (p_bnft_pool_rlovr_rqmt_id          => p_rec.bnft_pool_rlovr_rqmt_id,
   p_pct_rndg_rl        => p_rec.pct_rndg_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtt_elig_rlovr_rl
  (p_bnft_pool_rlovr_rqmt_id   => p_rec.bnft_pool_rlovr_rqmt_id,
   p_prtt_elig_rlovr_rl        => p_rec.prtt_elig_rlovr_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);

  chk_abr_dups
            (p_acty_base_rt_id           => p_rec.acty_base_rt_id,
             p_bnft_prvdr_pool_id        => p_rec.bnft_prvdr_pool_id,
             p_bnft_pool_rlovr_rqmt_id   => p_rec.bnft_pool_rlovr_rqmt_id,
             p_effective_date            => p_effective_date );

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_bpr_shd.g_rec_type,
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
  chk_bnft_pool_rlovr_rqmt_id
  (p_bnft_pool_rlovr_rqmt_id          => p_rec.bnft_pool_rlovr_rqmt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mutual_exlsv_mn_val_flg
     ( p_bnft_pool_rlovr_rqmt_id     => p_rec.bnft_pool_rlovr_rqmt_id
      ,p_no_mn_rlovr_val_dfnd_flag  => p_rec.no_mn_rlovr_val_dfnd_flag
      ,p_mn_rlovr_val      => p_rec.mn_rlovr_val
      ,p_effective_date         => p_effective_date
      ,p_object_version_number  => p_rec.object_version_number);
  --
  chk_mutual_exlsv_mx_val_flg
     ( p_bnft_pool_rlovr_rqmt_id     => p_rec.bnft_pool_rlovr_rqmt_id
      ,p_no_mx_rlovr_val_dfnd_flag  => p_rec.no_mx_rlovr_val_dfnd_flag
      ,p_mx_rlovr_val      => p_rec.mx_rlovr_val
      ,p_effective_date         => p_effective_date
      ,p_object_version_number  => p_rec.object_version_number);
  --
  chk_mutual_exlsv_mn_pct_flg
     ( p_bnft_pool_rlovr_rqmt_id     => p_rec.bnft_pool_rlovr_rqmt_id
      ,p_no_mn_rlovr_pct_dfnd_flag  => p_rec.no_mn_rlovr_pct_dfnd_flag
      ,p_mn_rlovr_pct_num      => p_rec.mn_rlovr_pct_num
      ,p_effective_date         => p_effective_date
      ,p_object_version_number  => p_rec.object_version_number);
  --
  chk_mutual_exlsv_mx_pct_flg
     ( p_bnft_pool_rlovr_rqmt_id     => p_rec.bnft_pool_rlovr_rqmt_id
      ,p_no_mx_rlovr_pct_dfnd_flag  => p_rec.no_mx_rlovr_pct_dfnd_flag
      ,p_mx_rlovr_pct_num      => p_rec.mx_rlovr_pct_num
      ,p_effective_date         => p_effective_date
      ,p_object_version_number  => p_rec.object_version_number);
  --
  chk_pct_rndg_cd_rl_dpndcy
     ( p_bnft_pool_rlovr_rqmt_id     => p_rec.bnft_pool_rlovr_rqmt_id
      ,p_pct_rndg_cd            => p_rec.pct_rndg_cd
      ,p_pct_rndg_rl            => p_rec.pct_rndg_rl
      ,p_effective_date         => p_effective_date
      ,p_object_version_number  => p_rec.object_version_number);
  --
  chk_val_rndg_cd_rl_dpndcy
     ( p_bnft_pool_rlovr_rqmt_id     => p_rec.bnft_pool_rlovr_rqmt_id
      ,p_val_rndg_cd            => p_rec.val_rndg_cd
      ,p_val_rndg_rl            => p_rec.val_rndg_rl
      ,p_effective_date         => p_effective_date
      ,p_object_version_number  => p_rec.object_version_number);
  --
  chk_pct_rndg_cd
  (p_bnft_pool_rlovr_rqmt_id          => p_rec.bnft_pool_rlovr_rqmt_id,
   p_pct_rndg_cd         => p_rec.pct_rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_val_rndg_rl
  (p_bnft_pool_rlovr_rqmt_id          => p_rec.bnft_pool_rlovr_rqmt_id,
   p_val_rndg_rl        => p_rec.val_rndg_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_val_rndg_cd
  (p_bnft_pool_rlovr_rqmt_id          => p_rec.bnft_pool_rlovr_rqmt_id,
   p_val_rndg_cd         => p_rec.val_rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_rlovr_val_dfnd_flag
  (p_bnft_pool_rlovr_rqmt_id          => p_rec.bnft_pool_rlovr_rqmt_id,
   p_no_mx_rlovr_val_dfnd_flag         => p_rec.no_mx_rlovr_val_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mn_rlovr_val_dfnd_flag
  (p_bnft_pool_rlovr_rqmt_id          => p_rec.bnft_pool_rlovr_rqmt_id,
   p_no_mn_rlovr_val_dfnd_flag         => p_rec.no_mn_rlovr_val_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_rlovr_pct_dfnd_flag
  (p_bnft_pool_rlovr_rqmt_id          => p_rec.bnft_pool_rlovr_rqmt_id,
   p_no_mx_rlovr_pct_dfnd_flag         => p_rec.no_mx_rlovr_pct_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mn_rlovr_pct_dfnd_flag
  (p_bnft_pool_rlovr_rqmt_id          => p_rec.bnft_pool_rlovr_rqmt_id,
   p_no_mn_rlovr_pct_dfnd_flag         => p_rec.no_mn_rlovr_pct_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crs_rlovr_procg_cd
  (p_bnft_pool_rlovr_rqmt_id => p_rec.bnft_pool_rlovr_rqmt_id,
   p_crs_rlovr_procg_cd      => p_rec.crs_rlovr_procg_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_pct_rndg_rl
  (p_bnft_pool_rlovr_rqmt_id          => p_rec.bnft_pool_rlovr_rqmt_id,
   p_pct_rndg_rl        => p_rec.pct_rndg_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtt_elig_rlovr_rl
  (p_bnft_pool_rlovr_rqmt_id   => p_rec.bnft_pool_rlovr_rqmt_id,
   p_prtt_elig_rlovr_rl        => p_rec.prtt_elig_rlovr_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_acty_base_rt_id               => p_rec.acty_base_rt_id,
             p_bnft_prvdr_pool_id            => p_rec.bnft_prvdr_pool_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);


  chk_abr_dups
            (p_acty_base_rt_id           => p_rec.acty_base_rt_id,
             p_bnft_prvdr_pool_id        => p_rec.bnft_prvdr_pool_id,
             p_bnft_pool_rlovr_rqmt_id   => p_rec.bnft_pool_rlovr_rqmt_id,
             p_effective_date            => p_effective_date );

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ben_bpr_shd.g_rec_type,
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
     p_bnft_pool_rlovr_rqmt_id		=> p_rec.bnft_pool_rlovr_rqmt_id);
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
  (p_bnft_pool_rlovr_rqmt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_bnft_pool_rlovr_rqmt_f b
    where b.bnft_pool_rlovr_rqmt_id      = p_bnft_pool_rlovr_rqmt_id
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
                             p_argument       => 'bnft_pool_rlovr_rqmt_id',
                             p_argument_value => p_bnft_pool_rlovr_rqmt_id);
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
end ben_bpr_bus;

/
