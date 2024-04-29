--------------------------------------------------------
--  DDL for Package Body BEN_LBR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LBR_BUS" as
/* $Header: belbrrhi.pkb 120.0 2005/05/28 03:16:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_lbr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_ler_bnft_rstrn_id >------|
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
--   ler_bnft_rstrn_id PK of record being inserted or updated.
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
Procedure chk_ler_bnft_rstrn_id(p_ler_bnft_rstrn_id           in number,
                                p_effective_date              in date,
                                p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ler_bnft_rstrn_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lbr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_ler_bnft_rstrn_id           => p_ler_bnft_rstrn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ler_bnft_rstrn_id,hr_api.g_number)
     <>  ben_lbr_shd.g_old_rec.ler_bnft_rstrn_id) then
    --
    -- raise error as PK has changed
    --
    ben_lbr_shd.constraint_error('BEN_LER_BNFT_RSTRN_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ler_bnft_rstrn_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_lbr_shd.constraint_error('BEN_LER_BNFT_RSTRN_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ler_bnft_rstrn_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mx_cvg_incr_apls_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_bnft_rstrn_id PK of record being inserted or updated.
--   no_mx_cvg_incr_apls_flag Value of lookup code.
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
Procedure chk_no_mx_cvg_incr_apls_flag(p_ler_bnft_rstrn_id        in number,
                                    p_no_mx_cvg_incr_apls_flag    in varchar2,
                                    p_effective_date              in date,
                                    p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_cvg_incr_apls_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lbr_shd.api_updating
    (p_ler_bnft_rstrn_id           => p_ler_bnft_rstrn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_cvg_incr_apls_flag
      <> nvl(ben_lbr_shd.g_old_rec.no_mx_cvg_incr_apls_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_cvg_incr_apls_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_no_mx_cvg_incr_apls_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_cvg_incr_apls_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mn_cvg_incr_apls_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_bnft_rstrn_id PK of record being inserted or updated.
--   no_mn_cvg_incr_apls_flag Value of lookup code.
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
Procedure chk_no_mn_cvg_incr_apls_flag(p_ler_bnft_rstrn_id    in number,
                            p_no_mn_cvg_incr_apls_flag        in varchar2,
                            p_effective_date                  in date,
                            p_object_version_number           in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mn_cvg_incr_apls_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lbr_shd.api_updating
    (p_ler_bnft_rstrn_id           => p_ler_bnft_rstrn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mn_cvg_incr_apls_flag
      <> nvl(ben_lbr_shd.g_old_rec.no_mn_cvg_incr_apls_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mn_cvg_incr_apls_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_no_mn_cvg_incr_apls_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mn_cvg_incr_apls_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mx_cvg_amt_apls_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_bnft_rstrn_id PK of record being inserted or updated.
--   no_mx_cvg_amt_apls_flag Value of lookup code.
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
Procedure chk_no_mx_cvg_amt_apls_flag(p_ler_bnft_rstrn_id   in number,
                            p_no_mx_cvg_amt_apls_flag       in varchar2,
                            p_effective_date                in date,
                            p_object_version_number         in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_cvg_amt_apls_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lbr_shd.api_updating
    (p_ler_bnft_rstrn_id           => p_ler_bnft_rstrn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_cvg_amt_apls_flag
      <> nvl(ben_lbr_shd.g_old_rec.no_mx_cvg_amt_apls_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_cvg_amt_apls_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_no_mx_cvg_amt_apls_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_cvg_amt_apls_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cvg_incr_r_decr_only_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_bnft_rstrn_id PK of record being inserted or updated.
--   cvg_incr_r_decr_only_cd Value of lookup code.
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
Procedure chk_cvg_incr_r_decr_only_cd(p_ler_bnft_rstrn_id   in number,
                            p_cvg_incr_r_decr_only_cd       in varchar2,
                            p_effective_date                in date,
                            p_object_version_number         in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cvg_incr_r_decr_only_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lbr_shd.api_updating
    (p_ler_bnft_rstrn_id           => p_ler_bnft_rstrn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_cvg_incr_r_decr_only_cd
      <> nvl(ben_lbr_shd.g_old_rec.cvg_incr_r_decr_only_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_cvg_incr_r_decr_only_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_CVG_INCR_R_DECR_ONLY',
           p_lookup_code    => p_cvg_incr_r_decr_only_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_cvg_incr_r_decr_only_cd');
      fnd_message.set_token('TYPE','BEN_CVG_INCR_R_DECR_ONLY');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cvg_incr_r_decr_only_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_unsspnd_enrt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_bnft_rstrn_id PK of record being inserted or updated.
--   unsspnd_enrt_cd Value of lookup code.
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
Procedure chk_unsspnd_enrt_cd(p_ler_bnft_rstrn_id         in number,
                              p_unsspnd_enrt_cd           in varchar2,
                              p_effective_date            in date,
                              p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_unsspnd_enrt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lbr_shd.api_updating
    (p_ler_bnft_rstrn_id           => p_ler_bnft_rstrn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_unsspnd_enrt_cd
      <> nvl(ben_lbr_shd.g_old_rec.unsspnd_enrt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_unsspnd_enrt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_UNSSPND_ENRT',
           p_lookup_code    => p_unsspnd_enrt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_unsspnd_enrt_cd');
      fnd_message.set_token('TYPE','BEN_UNSSPND_ENRT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_unsspnd_enrt_cd;
--
-- ----------------------------------------------------------------------------
-- |------------------< chk_dflt_to_asn_pndg_ctfn_cd >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_bnft_rstrn_id PK of record being inserted or updated.
--   dflt_to_asn_pndg_ctfn_cd Value of lookup code.
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
Procedure chk_dflt_to_asn_pndg_ctfn_cd(p_ler_bnft_rstrn_id   in number,
                            p_dflt_to_asn_pndg_ctfn_cd       in varchar2,
                            p_effective_date                 in date,
                            p_object_version_number          in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_to_asn_pndg_ctfn_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lbr_shd.api_updating
    (p_ler_bnft_rstrn_id           => p_ler_bnft_rstrn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dflt_to_asn_pndg_ctfn_cd
      <> nvl(ben_lbr_shd.g_old_rec.dflt_to_asn_pndg_ctfn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dflt_to_asn_pndg_ctfn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_DFLT_TO_ASN_PNDG_CTFN',
           p_lookup_code    => p_dflt_to_asn_pndg_ctfn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_dflt_to_asn_pndg_ctfn_cd');
      fnd_message.set_token('TYPE','BEN_DFLT_TO_ASN_PNDG_CTFN');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_to_asn_pndg_ctfn_cd;
--
-- ----------------------------------------------------------------------------
-- |-------------< chk_dflt_to_asn_pndg_ctfn_rl >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_bnft_rstrn_id PK of record being inserted or updated.
--   dflt_to_to_asn_pndg_ctfn_rl Value of formula rule id.
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
Procedure chk_dflt_to_asn_pndg_ctfn_rl
                           (p_ler_bnft_rstrn_id              in number,
                            p_business_group_id              in number,
                            p_dflt_to_asn_pndg_ctfn_rl    in number,
                            p_effective_date                 in date,
                            p_object_version_number          in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_to_to_asn_pndg_ctfn_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lbr_shd.api_updating
    (p_ler_bnft_rstrn_id           => p_ler_bnft_rstrn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_dflt_to_asn_pndg_ctfn_rl,hr_api.g_number)
      <> ben_lbr_shd.g_old_rec.dflt_to_asn_pndg_ctfn_rl
      or not l_api_updating)
      and p_dflt_to_asn_pndg_ctfn_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_dflt_to_asn_pndg_ctfn_rl,
        p_formula_type_id   => -454,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_dflt_to_asn_pndg_ctfn_rl);
      fnd_message.set_token('TYPE_ID',-454);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_to_asn_pndg_ctfn_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_mn_cvg_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_bnft_rstrn_id PK of record being inserted or updated.
--   mn_cvg_rl Value of formula rule id.
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
Procedure chk_mn_cvg_rl(p_ler_bnft_rstrn_id           in number,
                        p_business_group_id           in number,
                        p_mn_cvg_rl                   in number,
                        p_effective_date              in date,
                        p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mn_cvg_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lbr_shd.api_updating
    (p_ler_bnft_rstrn_id           => p_ler_bnft_rstrn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_mn_cvg_rl,hr_api.g_number)
      <> ben_lbr_shd.g_old_rec.mn_cvg_rl
      or not l_api_updating)
      and p_mn_cvg_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_mn_cvg_rl,
        p_formula_type_id   => -164,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_mn_cvg_rl);
      fnd_message.set_token('TYPE_ID',-164);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mn_cvg_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_mx_cvg_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_bnft_rstrn_id PK of record being inserted or updated.
--   mx_cvg_rl Value of formula rule id.
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
Procedure chk_mx_cvg_rl(p_ler_bnft_rstrn_id           in number,
                        p_business_group_id           in number,
                        p_mx_cvg_rl                   in number,
                        p_effective_date              in date,
                        p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mx_cvg_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lbr_shd.api_updating
    (p_ler_bnft_rstrn_id           => p_ler_bnft_rstrn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_mx_cvg_rl,hr_api.g_number)
      <> ben_lbr_shd.g_old_rec.mx_cvg_rl
      or not l_api_updating)
      and p_mx_cvg_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_mx_cvg_rl,
        p_formula_type_id   => -161,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_mx_cvg_rl);
      fnd_message.set_token('TYPE_ID',-161);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mx_cvg_rl;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_interim_cd_cvg_calc_mthd >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the Interim Assign Code.
--	If the Coverage Calculation is set to Flat Amount (FLFX)
-- 	and Enter Value at Enrollment is checked in the Coverages Form,
--	this procedure will not allow to set the interim assign code to
--	Next Lower
--   This procedure has been added as part of fix for bug 1305372
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_id          PK of record being inserted or updated.
--   effective_date Effective Date of session
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
Procedure chk_interim_cd_cvg_calc_mthd(
		    p_ler_bnft_rstrn_id			in number,
		    p_dflt_to_asn_pndg_ctfn_cd  	in varchar2,
		    p_pl_id                     	in number,
		    p_plip_id                     	in number,
                    p_effective_date            	in date,
                    p_business_group_id            	in number,
                    p_object_version_number     	in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_interim_cd_cvg_calc_mthd';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is
    select null from ben_cvg_amt_calc_mthd_f cvg
    where nvl(cvg.pl_id,-1) = p_pl_id
    and cvg.cvg_mlt_cd = 'FLFX'
    and cvg.entr_val_at_enrt_flag = 'Y'
    and cvg.business_group_id = p_business_group_id
    and p_effective_date between cvg.effective_start_date and cvg.effective_end_date;
  --
  cursor c2 is
    select null
    from ben_cvg_amt_calc_mthd_f cvg
        ,ben_plip_f cpp
        ,ben_pl_f   pln
    where cvg.cvg_mlt_cd = 'FLFX'
    and cvg.entr_val_at_enrt_flag = 'Y'
    and p_plip_id = cpp.plip_id
    and nvl(cvg.pl_id,-1) = cpp.pl_id
    and pln.pl_id = cpp.pl_id
    and cvg.business_group_id = p_business_group_id
    and p_effective_date between cvg.effective_start_date and cvg.effective_end_date
    and cpp.business_group_id = p_business_group_id
    and p_effective_date between cpp.effective_start_date and cpp.effective_end_date
    and pln.business_group_id = p_business_group_id
    and p_effective_date between pln.effective_start_date and pln.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lbr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_ler_bnft_rstrn_id           => p_ler_bnft_rstrn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_dflt_to_asn_pndg_ctfn_cd,hr_api.g_varchar2)
     <>  nvl(ben_lbr_shd.g_old_rec.dflt_to_asn_pndg_ctfn_cd, '***')
     or not l_api_updating)
     and p_dflt_to_asn_pndg_ctfn_cd is not null then
    --
    if (instr(p_dflt_to_asn_pndg_ctfn_cd,'NL'))>0 then
      --
      -- life event specific benefit restriction can be defined at plan
      -- or plan in program level.
      --
      if p_pl_id is not null then
        --
        open c1;
        fetch c1 into l_dummy;
        if c1%found then
          --
          close c1;
          hr_utility.set_location('Inside :'||l_proc, 10);
          fnd_message.set_name('BEN', 'BEN_93113_CD_CANNOT_NEXTLOWER');
          fnd_message.raise_error;
          --
        else
          --
          close c1;
          --
        end if;
        --
      elsif p_plip_id is not null then
        --
        open c2;
        fetch c2 into l_dummy;
        if c2%found then
          --
          close c2;
          hr_utility.set_location('Inside :'||l_proc, 15);
          fnd_message.set_name('BEN', 'BEN_93113_CD_CANNOT_NEXTLOWER');
          fnd_message.raise_error;
          --
        else
          --
          close c2;
          --
        end if;
        --
      end if;
      --
    end if; -- End of instr end if
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 30);
  --
End chk_interim_cd_cvg_calc_mthd;
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
            (p_ler_id                        in number ,
             p_pl_id                         in number ,
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
    If ((nvl(p_ler_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ler_f',
             p_base_key_column => 'ler_id',
             p_base_key_value  => p_ler_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_ler_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_pl_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_pl_f',
             p_base_key_column => 'pl_id',
             p_base_key_value  => p_pl_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_pl_f';
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
    hr_utility.set_message(801, 'HR_7216_DT_UPD_INTEGRITY_ERR');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
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
            (p_ler_bnft_rstrn_id		in number,
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
       p_argument       => 'ler_bnft_rstrn_id',
       p_argument_value => p_ler_bnft_rstrn_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_ler_bnft_rstrn_ctfn_f',
           p_base_key_column => 'ler_bnft_rstrn_id',
           p_base_key_value  => p_ler_bnft_rstrn_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_ler_bnft_rstrn_ctfn_f';
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
    hr_utility.set_message(801, 'HR_7215_DT_CHILD_EXISTS');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
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
	(p_rec 			 in ben_lbr_shd.g_rec_type,
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
  chk_ler_bnft_rstrn_id
  (p_ler_bnft_rstrn_id         => p_rec.ler_bnft_rstrn_id,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_no_mx_cvg_incr_apls_flag
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_no_mx_cvg_incr_apls_flag   => p_rec.no_mx_cvg_incr_apls_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_no_mn_cvg_incr_apls_flag
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_no_mn_cvg_incr_apls_flag   => p_rec.no_mn_cvg_incr_apls_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_no_mx_cvg_amt_apls_flag
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_no_mx_cvg_amt_apls_flag    => p_rec.no_mx_cvg_amt_apls_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_cvg_incr_r_decr_only_cd
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_cvg_incr_r_decr_only_cd    => p_rec.cvg_incr_r_decr_only_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_unsspnd_enrt_cd
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_unsspnd_enrt_cd            => p_rec.unsspnd_enrt_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_dflt_to_asn_pndg_ctfn_cd
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_dflt_to_asn_pndg_ctfn_cd   => p_rec.dflt_to_asn_pndg_ctfn_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  -- Bug 2562196
  /*
  -- bug fix 1305372
  --
  chk_interim_cd_cvg_calc_mthd
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_dflt_to_asn_pndg_ctfn_cd  	=> p_rec.dflt_to_asn_pndg_ctfn_cd,
   p_pl_id                     	=> p_rec.pl_id,
   p_plip_id                    => p_rec.plip_id,
   p_effective_date            	=> p_effective_date,
   p_business_group_id          => p_rec.business_group_id,
   p_object_version_number 	=> p_rec.object_version_number);
  --
  -- end fix 1305372
  --
  */
  chk_dflt_to_asn_pndg_ctfn_rl
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_business_group_id          => p_rec.business_group_id,
   p_dflt_to_asn_pndg_ctfn_rl   => p_rec.dflt_to_asn_pndg_ctfn_rl,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_mn_cvg_rl
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_business_group_id          => p_rec.business_group_id,
   p_mn_cvg_rl                  => p_rec.mn_cvg_rl,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_mx_cvg_rl
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_business_group_id          => p_rec.business_group_id,
   p_mx_cvg_rl                  => p_rec.mx_cvg_rl,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_lbr_shd.g_rec_type,
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
  chk_ler_bnft_rstrn_id
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_no_mx_cvg_incr_apls_flag
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_no_mx_cvg_incr_apls_flag   => p_rec.no_mx_cvg_incr_apls_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_no_mn_cvg_incr_apls_flag
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_no_mn_cvg_incr_apls_flag   => p_rec.no_mn_cvg_incr_apls_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_no_mx_cvg_amt_apls_flag
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_no_mx_cvg_amt_apls_flag    => p_rec.no_mx_cvg_amt_apls_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_cvg_incr_r_decr_only_cd
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_cvg_incr_r_decr_only_cd    => p_rec.cvg_incr_r_decr_only_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_unsspnd_enrt_cd
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_unsspnd_enrt_cd            => p_rec.unsspnd_enrt_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_dflt_to_asn_pndg_ctfn_cd
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_dflt_to_asn_pndg_ctfn_cd   => p_rec.dflt_to_asn_pndg_ctfn_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  -- Bug 2562196
  /*
  -- bug fix 1305372
  --
  chk_interim_cd_cvg_calc_mthd
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_dflt_to_asn_pndg_ctfn_cd  	=> p_rec.dflt_to_asn_pndg_ctfn_cd,
   p_pl_id                     	=> p_rec.pl_id,
   p_plip_id                    => p_rec.plip_id,
   p_effective_date            	=> p_effective_date,
   p_business_group_id          => p_rec.business_group_id,
   p_object_version_number 	=> p_rec.object_version_number);
  --
  -- end fix 1305372
  --
  */
  chk_dflt_to_asn_pndg_ctfn_rl
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_business_group_id          => p_rec.business_group_id,
   p_dflt_to_asn_pndg_ctfn_rl   => p_rec.dflt_to_asn_pndg_ctfn_rl,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_mn_cvg_rl
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_business_group_id          => p_rec.business_group_id,
   p_mn_cvg_rl                  => p_rec.mn_cvg_rl,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_mx_cvg_rl
  (p_ler_bnft_rstrn_id          => p_rec.ler_bnft_rstrn_id,
   p_business_group_id          => p_rec.business_group_id,
   p_mx_cvg_rl                  => p_rec.mx_cvg_rl,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_ler_id                        => p_rec.ler_id,
     p_pl_id                         => p_rec.pl_id,
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
	(p_rec 			 in ben_lbr_shd.g_rec_type,
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
     p_ler_bnft_rstrn_id		=> p_rec.ler_bnft_rstrn_id);
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
  (p_ler_bnft_rstrn_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ler_bnft_rstrn_f b
    where b.ler_bnft_rstrn_id      = p_ler_bnft_rstrn_id
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
                             p_argument       => 'ler_bnft_rstrn_id',
                             p_argument_value => p_ler_bnft_rstrn_id);
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
end ben_lbr_bus;

/
