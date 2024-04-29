--------------------------------------------------------
--  DDL for Package Body BEN_PBN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PBN_BUS" as
/* $Header: bepbnrhi.pkb 120.1.12010000.4 2009/09/18 07:26:53 stee ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pbn_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_pl_bnf_id >------|
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
--   pl_bnf_id PK of record being inserted or updated.
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
Procedure chk_pl_bnf_id(p_pl_bnf_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pl_bnf_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pbn_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_pl_bnf_id                => p_pl_bnf_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pl_bnf_id,hr_api.g_number)
     <>  ben_pbn_shd.g_old_rec.pl_bnf_id) then
    --
    -- raise error as PK has changed
    --
    ben_pbn_shd.constraint_error('BEN_PL_BNF_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_pl_bnf_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_pbn_shd.constraint_error('BEN_PL_BNF_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pl_bnf_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_prmry_cntngnt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_bnf_id PK of record being inserted or updated.
--   prmry_cntngnt_cd Value of lookup code.
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
Procedure chk_prmry_cntngnt_cd(p_pl_bnf_id                in number,
                            p_prmry_cntngnt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prmry_cntngnt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pbn_shd.api_updating
    (p_pl_bnf_id                => p_pl_bnf_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prmry_cntngnt_cd
      <> nvl(ben_pbn_shd.g_old_rec.prmry_cntngnt_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PRMRY_CNTNGNT',
           p_lookup_code    => p_prmry_cntngnt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prmry_cntngnt_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_all_pl_bnf_parameters >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure validates all PL_BNF_F columns and business rules that
--   depend on the values of BNF parameters in PL_F table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_pl_bnf_id                  PK
--
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
Procedure chk_all_pl_bnf_parameters(p_pl_bnf_id             in number,
                                    p_prtt_enrt_rslt_id     in number,
                                    p_prmry_cntngnt_cd      in varchar2,
                                    p_organization_id       in number,
                                    p_addl_instrn_txt       in varchar2,
                                    p_amt_dsgd_val          in number,
                                    p_pct_dsgd_num          in number,
                                    p_validation_start_date in date,
                                    p_validation_end_date   in date,
                                    p_effective_date        in date,
                                    p_business_group_id     in number,
                                    p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_all_bnf_parameters';
  l_bnf_dsgn_cd                  varchar2(30);
  l_bnf_cntngt_bnfs_alwd_flag    varchar2(1);
  l_bnf_may_dsgt_org_flag        varchar2(1);
  l_bnf_addl_instn_txt_alwd_flag varchar2(1);
  l_bnf_pct_amt_alwd_cd          varchar2(30);
  l_bnf_mn_dsgntbl_amt           number(15);
  l_bnf_incrmt_amt               number(15);
  l_bnf_mn_dsgntbl_pct_val       number(15);
  l_bnf_pct_incrmt_val           number(15);
  -- Added for Bug 2395217
  l_bnf_enrt_oipl_id             number(15);
  l_bnf_enrt_option_name         ben_opt_f.name%TYPE;
  -- Added  for bug no 1845251
  l_pl_name	ben_pl_f.name%type; -- UTF8 Change Bug 2254683
  --
  cursor pl1(l_lf_evt_ocrd_dt date) is
     select a.bnf_dsgn_cd
     -- added for bug no. 1845251
     	  , a.name
          , a.bnf_cntngt_bnfs_alwd_flag
          , a.bnf_may_dsgt_org_flag
          , a.bnf_addl_instn_txt_alwd_flag
          , a.bnf_pct_amt_alwd_cd
          , a.bnf_mn_dsgntbl_amt
          , a.bnf_incrmt_amt
          , a.bnf_mn_dsgntbl_pct_val
          , a.bnf_pct_incrmt_val
          , b.oipl_id
       from ben_pl_f   a
          , ben_prtt_enrt_rslt_f   b
       where b.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         -- and b.prtt_enrt_rslt_stat_cd is null -- bug 8901277
         and p_effective_date between b.effective_start_date  -- bug 8901277
                                  and b.effective_end_date
         and a.pl_id = b.pl_id
         and nvl(l_lf_evt_ocrd_dt,p_effective_date) between a.effective_start_date
                                  and a.effective_end_date
         and a.business_group_id + 0 = p_business_group_id
         ;

CURSOR csr_option_name(l_lf_evt_ocrd_dt date) is
SELECT
 opt.NAME
FROM
  ben_opt_f opt
 ,ben_oipl_f oipl
WHERE
    oipl.oipl_id=l_bnf_enrt_oipl_id
and nvl(l_lf_evt_ocrd_dt,p_effective_date) between oipl.effective_start_date  and oipl.effective_end_date
and opt.opt_id=oipl.opt_id
and nvl(l_lf_evt_ocrd_dt,p_effective_date) between opt.effective_start_date  and opt.effective_end_date;
  --
CURSOR c_pil is
SELECT pil.lf_evt_ocrd_dt
FROM ben_prtt_enrt_rslt_f pen,
  ben_per_in_ler pil
WHERE prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
 -- AND pen.prtt_enrt_rslt_stat_cd is NULL -- bug 8901277
 AND p_effective_date BETWEEN pen.effective_start_date
 AND pen.effective_end_date
 AND pen.per_in_ler_id = pil.per_in_ler_id;
  --
l_disp_param varchar2(30);
l_lf_evt_ocrd_dt date;
  --
 Begin
  hr_utility.set_location('Entering:'||l_proc,5);

  l_disp_param := null;
  l_lf_evt_ocrd_dt := null;
  l_disp_param := fnd_profile.value('BEN_DSPL_NAME_BASIS');
  hr_utility.set_location('l_disp_param :' || l_disp_param, 12345);

  if l_disp_param  = 'LEOD' then
    open c_pil;
     fetch c_pil into l_lf_evt_ocrd_dt;
     hr_utility.set_location('l_lf_evt_ocrd_dt :' || l_lf_evt_ocrd_dt, 12345);
     close c_pil;
  end if;

  -- check if ben_pl_f bnf parameters do not contradict ben_pl_bnf_f values
  open pl1(l_lf_evt_ocrd_dt);

  fetch pl1 into
                     l_bnf_dsgn_cd
                    ,l_pl_name
                    ,l_bnf_cntngt_bnfs_alwd_flag
                    ,l_bnf_may_dsgt_org_flag
                    ,l_bnf_addl_instn_txt_alwd_flag
                    ,l_bnf_pct_amt_alwd_cd
                    ,l_bnf_mn_dsgntbl_amt
                    ,l_bnf_incrmt_amt
                    ,l_bnf_mn_dsgntbl_pct_val
                    ,l_bnf_pct_incrmt_val
                    ,l_bnf_enrt_oipl_id
                    ;
  if pl1%notfound then
        close pl1;
        -- raise error as corresponding Plan does not exist in ben_pl_f
        -- table.
        fnd_message.set_name('BEN', 'BEN_91641_ENRT_RSLT_INVLD');
        fnd_message.raise_error;
  elsif l_bnf_dsgn_cd is null then
        -- raise error as this plan does not allow to designate beneficiaries
        fnd_message.set_name('BEN', 'BEN_91634_BNF_NOT_ALWD');
        fnd_message.raise_error;
  else
        if p_organization_id is not null and
           l_bnf_may_dsgt_org_flag = 'N' then
           -- raise error as this plan does not allow to designate orgs
           fnd_message.set_name('BEN', 'BEN_91635_ORGS_BNF_NOT_ALWD');
           fnd_message.raise_error;
        end if;
        if p_prmry_cntngnt_cd = 'CNTNGNT' and
           l_bnf_cntngt_bnfs_alwd_flag  = 'N' then
           -- raise error as this plan does not allow to designate contingent bnfs
           fnd_message.set_name('BEN', 'BEN_91636_CNTNGNT_BNF_NOT_ALWD');
           fnd_message.raise_error;
        end if;
        if p_addl_instrn_txt is not null and
           l_bnf_addl_instn_txt_alwd_flag = 'N' then
           -- raise error as this plan does not allow addl instructions
           fnd_message.set_name('BEN', 'BEN_91637_ADDL_TXT_NOT_ALWD');
           fnd_message.raise_error;
        end if;
        if l_bnf_pct_amt_alwd_cd = 'PCTA' then
           if p_amt_dsgd_val is null and p_pct_dsgd_num is null then
              fnd_message.set_name('BEN', 'BEN_92527_PCT_AMT_NULL');
              fnd_message.raise_error;
           end if;
        end if;
        if p_amt_dsgd_val  is not null then
            if l_bnf_pct_amt_alwd_cd = 'PCTO' then
               -- raise error as this plan does not allow to designate amount
               fnd_message.set_name('BEN', 'BEN_91638_BNF_AMT_NOT_ALWD');
               fnd_message.raise_error;
            elsif p_amt_dsgd_val = 0 then
               -- raise error as this amt is invalid
               fnd_message.set_name('BEN', 'BEN_92528_INV_AMT_VAL');
               fnd_message.raise_error;
            elsif l_bnf_mn_dsgntbl_amt is not null and
                  p_amt_dsgd_val < l_bnf_mn_dsgntbl_amt then
               -- raise error as this amount is below minimum allowed
               fnd_message.set_name('BEN', 'BEN_91639_BNF_AMT_MIN_ALWD');
	       fnd_message.set_token('MIN_AMT',l_bnf_mn_dsgntbl_amt);--4455819
               fnd_message.raise_error;
            elsif l_bnf_incrmt_amt is not null and
               mod((p_amt_dsgd_val - nvl(l_bnf_mn_dsgntbl_amt, 0)), l_bnf_incrmt_amt) <> 0 then
               -- raise error as this amount is not in increments allowed
               fnd_message.set_name('BEN', 'BEN_91640_BNF_AMT_INCRMT_ALWD');
               fnd_message.raise_error;
            end if;
        end if;
        if p_pct_dsgd_num is not null then
            if p_pct_dsgd_num > 100 or p_pct_dsgd_num <= 0 then
               -- raise error as this pct num is invalid
               fnd_message.set_name('BEN', 'BEN_91271_INV_PCT_VAL');
               fnd_message.raise_error;
            elsif l_bnf_mn_dsgntbl_pct_val is not null and
                  p_pct_dsgd_num < l_bnf_mn_dsgntbl_pct_val then
               -- raise error as this pct is below minimum allowed
               if (l_bnf_enrt_oipl_id  is not null)
               then
                 open  csr_option_name(l_lf_evt_ocrd_dt);
                 fetch csr_option_name into l_bnf_enrt_option_name;
                 if csr_option_name%notfound then
                   close csr_option_name;
                   -- raise error as corresponding option does not exist in ben_opt_f
                   fnd_message.set_name('ben', 'ben_91641_enrt_rslt_invld');
                   fnd_message.raise_error;
                 end if;
                 close csr_option_name;
                 fnd_message.set_name('BEN', 'BEN_93263_BNF_PCT_MIN_ALWD');
                 fnd_message.set_token('MIN',l_bnf_mn_dsgntbl_pct_val);
                 fnd_message.set_token('OPT',l_bnf_enrt_option_name);
                 fnd_message.set_token('PL',l_pl_name);
              else
               fnd_message.set_name('BEN', 'BEN_91642_BNF_PCT_MIN_ALWD');

               -- Added for Bug 1845251

               fnd_message.set_token('MIN',l_bnf_mn_dsgntbl_pct_val);
               fnd_message.set_token('PL',l_pl_name);
              end if;
               fnd_message.raise_error;
            elsif l_bnf_pct_incrmt_val is not null and
               mod((p_pct_dsgd_num - nvl(l_bnf_mn_dsgntbl_pct_val, 0)), l_bnf_pct_incrmt_val) <> 0 then
               -- raise error as this pct is not in increments allowed
               fnd_message.set_name('BEN', 'BEN_91643_BNF_PCT_INCRMT_ALWD');

               fnd_message.set_token('INCR',l_bnf_pct_incrmt_val);
               fnd_message.set_token('PL',l_pl_name);

               fnd_message.raise_error;
            end if;
        elsif p_amt_dsgd_val is null and
              l_bnf_mn_dsgntbl_pct_val is not null and
              nvl(p_pct_dsgd_num,0) < l_bnf_mn_dsgntbl_pct_val then
               -- raise error as this (null) pct is below minimum allowed
               -- Bug 1096696
                if (l_bnf_enrt_oipl_id  is not null)
               then
                 open  csr_option_name(l_lf_evt_ocrd_dt);
                 fetch csr_option_name into l_bnf_enrt_option_name;
                 if csr_option_name%notfound then
                   close csr_option_name;
                   -- raise error as corresponding option does not exist in ben_opt_f
                   fnd_message.set_name('ben', 'ben_91641_enrt_rslt_invld');
                   fnd_message.raise_error;
                 end if;
                 close csr_option_name;
                 fnd_message.set_name('BEN', 'BEN_93263_BNF_PCT_MIN_ALWD');
                 fnd_message.set_token('MIN',l_bnf_mn_dsgntbl_pct_val);
                 fnd_message.set_token('OPT',l_bnf_enrt_option_name);
                 fnd_message.set_token('PL',l_pl_name);
              else
               fnd_message.set_name('BEN', 'BEN_91642_BNF_PCT_MIN_ALWD');

               -- Added for Bug 1845251

                  fnd_message.set_token('MIN',l_bnf_mn_dsgntbl_pct_val);
                  fnd_message.set_token('PL',l_pl_name);

              end if;
               fnd_message.raise_error;
        end if;
  end if;
  close pl1;
  hr_utility.set_location('Leaving:'||l_proc,10);
End chk_all_pl_bnf_parameters;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_pct_dsgd_num >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that sum of designated % is no greater that 100
--   for each beneficiary type for the enrollment result.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_pl_bnf_id PK
--   p_pct_dsgd_num  column
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
Procedure chk_pct_dsgd_num (p_pl_bnf_id             in number,
                            p_pct_dsgd_num          in number,
                            p_prtt_enrt_rslt_id     in number,
                            p_prmry_cntngnt_cd      in varchar2,
                            p_validation_start_date in date,
                            p_validation_end_date   in date,
                            p_effective_date        in date,
                            p_business_group_id     in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_amt_dsgt_val';
  l_api_updating boolean;
  l_sum          number(15,2);
  --
  --
  --
  cursor c1 is
    select sum(pct_dsgd_num)
    from   ben_pl_bnf_f b
    where  b.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and  b.business_group_id + 0 = p_business_group_id
      and  b.prmry_cntngnt_cd = p_prmry_cntngnt_cd
      and  b.pl_bnf_id <> nvl(p_pl_bnf_id, hr_api.g_number)
      and p_validation_start_date <= b.effective_end_date
      and p_validation_end_date >= b.effective_start_date
           ;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_pbn_shd.api_updating
     (p_pl_bnf_id               => p_pl_bnf_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if p_pct_dsgd_num is not null then
  if (l_api_updating
     and nvl(p_pct_dsgd_num, hr_api.g_number)
     <> nvl(ben_pbn_shd.g_old_rec.pct_dsgd_num, hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if sum of pct_dsgd_num is less or = 100
    --
    open c1;
      --
      fetch c1 into l_sum;
        if (l_sum + p_pct_dsgd_num) > 100 then
            --
            fnd_message.set_name('BEN', 'BEN_91644_BNF_TTL_PCT_EXCEEDED');
            fnd_message.raise_error;
            --
        --
        end if;
    --
    close c1;
    --
    --
  end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pct_dsgd_num;
--
-- ----------------------------------------------------------------------------
-- |------< chk_amt_dsgd_val >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that specified amount is no greater that benefit amount
--   for the enrollment result.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_pl_bnf_id PK
--   p_amt_dsgd_val  column
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
Procedure chk_amt_dsgd_val (p_pl_bnf_id             in number,
                            p_amt_dsgd_val          in number,
                            p_prtt_enrt_rslt_id     in number,
                            p_prmry_cntngnt_cd      in varchar2,
                            p_validation_start_date in date,
                            p_validation_end_date   in date,
                            p_effective_date        in date,
                            p_business_group_id     in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_amt_dsgt_val';
  l_api_updating boolean;
  l_amt          number(15,2);
  l_sum          number(15,2);
  --
  --
  cursor c1 is
    select bnft_amt
    from   ben_prtt_enrt_rslt_f a
    where  a.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and  a.prtt_enrt_rslt_stat_cd is null
      and  a.business_group_id + 0 = p_business_group_id
           and p_validation_start_date <= effective_end_date
           and p_validation_end_date >= effective_start_date
           ;
  --
  cursor c2 is
    select sum(amt_dsgd_val)
    from   ben_pl_bnf_f b
    where  b.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and  b.business_group_id + 0 = p_business_group_id
      and  b.prmry_cntngnt_cd = p_prmry_cntngnt_cd
      and  b.pl_bnf_id <> nvl(p_pl_bnf_id, hr_api.g_number)
           and p_validation_start_date <=b.effective_end_date
           and p_validation_end_date >= b.effective_start_date
           ;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_pbn_shd.api_updating
     (p_pl_bnf_id               => p_pl_bnf_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if p_amt_dsgd_val is not null then
  if (l_api_updating
     and nvl(p_amt_dsgd_val,hr_api.g_number)
     <> nvl(ben_pbn_shd.g_old_rec.amt_dsgd_val, hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if sum of amt_dsgd_val is less or = bnft_amt value on ben_prtt_enrt_rslt_f table
    --
    open c1;
      --
      fetch c1 into l_amt;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as corresponding rslt does not exist on ben_prtt_enrt_rslt_f
        -- table.
        --
        ben_pbn_shd.constraint_error('BEN_PL_BNF_FK4');
      else
        --
        open c2;
        fetch c2 into l_sum;
        if (l_sum + p_amt_dsgd_val) > nvl(l_amt, 0) then
            --
            fnd_message.set_name('BEN', 'BEN_91645_BNF_TTL_AMT_EXCEEDED');
            fnd_message.raise_error;
            --
        close c2;
        --
        end if;
      end if;
      --
    close c1;
    --
    --
  end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_amt_dsgd_val;
--
-- ----------------------------------------------------------------------------
-- |------< chk_amt_dsgd_uom >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_bnf_id PK of record being inserted or updated.
--   amt_dsgd_uom Value of lookup code.
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
Procedure chk_amt_dsgd_uom(p_pl_bnf_id                in number,
                           p_amt_dsgd_uom             in varchar2,
                           p_prtt_enrt_rslt_id        in number,
                           p_effective_date           in date,
                           p_business_group_id        in number,
                           p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_amt_dsgd_uom';
  l_api_updating boolean;
  l_uom          varchar2(30);
  --
  cursor c1 is
    select uom
    from   ben_prtt_enrt_rslt_f a
    where  a.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and  a.prtt_enrt_rslt_stat_cd is null
      and  a.business_group_id + 0 = p_business_group_id
           and p_effective_date between effective_start_date
                                    and effective_end_date
           ;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pbn_shd.api_updating
    (p_pl_bnf_id                => p_pl_bnf_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if p_amt_dsgd_uom is not null then
  if (l_api_updating
      and p_amt_dsgd_uom
      <> nvl(ben_pbn_shd.g_old_rec.amt_dsgd_uom,hr_api.g_varchar2)
      or not l_api_updating)
      and p_amt_dsgd_uom is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    open c1;
      --
      fetch c1 into l_uom;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as corresponding rslt does not exist on ben_prtt_enrt_rslt_f
        -- table.
        --
        ben_pbn_shd.constraint_error('BEN_PL_BNF_FK4');
      elsif p_amt_dsgd_uom <> l_uom then
            --
            fnd_message.set_name('BEN', 'BEN_91647_BNF_AMT_UOM_INVALID');
            fnd_message.raise_error;
            --
        --
      end if;
    --
    close c1;
    --
  end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_amt_dsgd_uom;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_bnf_person_id >------|
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
--   p_pl_bnf_id PK
--   p_bnf_person_id ID of FK column
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
Procedure chk_bnf_person_id (p_pl_bnf_id             in number,
                             p_bnf_person_id         in number,
                             p_prtt_enrt_rslt_id     in number,
                             p_validation_start_date in date,
                             p_validation_end_date   in date,
                             p_effective_date        in date,
                             p_business_group_id     in number,
                             p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bnf_person_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_exists       varchar2(1);
  --
  -- Bug 1776842 : Do not consider the benficiary rowsattached to the
  --               backed out per in ler.
  --
  cursor c3 is
     select null
       from ben_pl_bnf_f pbn,
            ben_per_in_ler pil
         where pbn.bnf_person_id = p_bnf_person_id
           and pil.per_in_ler_id(+)=pbn.per_in_ler_id and
               pil.business_group_id(+)=pbn.business_group_id
           and ( pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
                 or pil.per_in_ler_stat_cd is null )
           and pbn.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
           and pbn.pl_bnf_id <> nvl(p_pl_bnf_id, hr_api.g_number)
           and pbn.business_group_id + 0 = p_business_group_id
           and p_validation_start_date <= pbn.effective_end_date
           and p_validation_end_date >= pbn.effective_start_date
           ;
  --
  --
  cursor c1 is
    select null
    from   per_all_people_f a
    where  a.person_id = p_bnf_person_id
      and  a.business_group_id + 0 = p_business_group_id
           and p_validation_start_date <= effective_end_date
           and p_validation_end_date >= effective_start_date
           ;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_pbn_shd.api_updating
     (p_pl_bnf_id               => p_pl_bnf_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if p_bnf_person_id is not null then
  if (l_api_updating
     and nvl(p_bnf_person_id,hr_api.g_number)
     <> nvl(ben_pbn_shd.g_old_rec.bnf_person_id, hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if bnf_person_id value exists in per_all_people_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_all_people
        -- table.
        --
        ben_pbn_shd.constraint_error('BEN_PL_BNF_FK1');
        --
      end if;
      --
    close c1;
    --
    open c3;
    fetch c3 into l_exists;
    if c3%found then
      close c3;
      --
      -- raise error as this beneficiary already exists for this enrt rslt
    --
     fnd_message.set_name('BEN', 'BEN_91648_DUP_PL_BNF');
     fnd_message.raise_error;
    --
    end if;
    close c3;
    --
  end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_bnf_person_id;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_ttee_person_id >------|
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
--   p_pl_bnf_id PK
--   p_ttee_person_id ID of FK column
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
Procedure chk_ttee_person_id (p_pl_bnf_id             in number,
                              p_ttee_person_id        in number,
                              p_bnf_person_id         in number,
                              p_validation_start_date in date,
                              p_validation_end_date   in date,
                              p_effective_date        in date,
                              p_business_group_id     in number,
                              p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bnf_person_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  --
  --
  cursor c1 is
    select null
    from   per_all_people a, per_contact_relationships c
    where  a.person_id = p_ttee_person_id
      and  a.person_id = c.contact_person_id
      and  c.person_id = p_bnf_person_id
      and  p_validation_start_date <= nvl(c.date_end, p_validation_start_date)
           and p_validation_end_date >= nvl(c.date_start, p_validation_start_date)
      and  a.business_group_id + 0 = p_business_group_id
           and p_validation_start_date <= a.effective_end_date
           and p_validation_end_date >= a.effective_start_date
           ;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_pbn_shd.api_updating
     (p_pl_bnf_id               => p_pl_bnf_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if p_ttee_person_id is not null then
  if (l_api_updating
     and nvl(p_ttee_person_id,hr_api.g_number)
     <> nvl(ben_pbn_shd.g_old_rec.ttee_person_id, hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if ttee_person_id value exists in per_all_people_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_all_people
        -- table.
        --
        ben_pbn_shd.constraint_error('BEN_PL_BNF_FK2');
        --
      end if;
      --
    close c1;
    --
    --
  end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ttee_person_id;
--
--
-- ----------------------------------------------------------------------------
-- |------------------< chk_bnf_dsgn_rqmt_relnshp_typ >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the designated beneficary's relationship is valid
--   as per the designation requirements given at Option / option in Plan / Plan levels
--   in that order.
--   This procedure replaces the following procedure with the same name
--   This check procedure has been added to fix bugs 2493806 and 2367632 .
--   This is called from insert_validate and update_validate procedures.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_pl_bnf_id 		PK
--   p_bnf_person_id 		ID of contact perosn who has been designated as beneficiary
--   p_per_in_ler_id 		per_in_ler_id
--   p_prtt_enrt_rslt_id	participant enrollment result ID used to get PL /OIPL / OPT details
--   p_business_group_id	business_group_id
--   p_effective_date 		session date
--   p_object_version_number 	object version number
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
Procedure chk_bnf_dsgn_rqmt_relnshp_typ (p_pl_bnf_id             in number,
                              		 p_bnf_person_id         in number,
                              		 p_per_in_ler_id         in number,
                              		 p_prtt_enrt_rslt_id     in number,
                              		 p_business_group_id     in number,
                              		 p_effective_date        in date,
                              		 p_object_version_number in number) is
  --
  l_proc         		varchar2(72) := g_package||'chk_bnf_dsgn_rqmt_relnshp_typ';
  l_api_updating 		boolean;
  l_dummy        		varchar2(1);
  l_rel_typ                     varchar2(30);
  l_rlshp_typ_cd                varchar2(30);
  l_lkup_meaning_reln_type 	varchar2(80);
  l_pl_id        		number;
  l_oipl_id			number;
  l_opt_id			number;
  --
  --
  cursor c_opt_dsgn_rqmt is
  select distinct drt.rlshp_typ_cd
    from ben_dsgn_rqmt_rlshp_typ drt
       	 , ben_dsgn_rqmt_f drm
       	 , ben_opt_f opt
       	 , ben_oipl_f oipl
       	 , ben_prtt_enrt_rslt_f pen
   where drt.dsgn_rqmt_id = drm.dsgn_rqmt_id
     and drt.business_group_id = p_business_group_id
     and drm.dsgn_typ_cd = 'BNF'
     and drm.business_group_id = p_business_group_id
     and pen.prtt_enrt_rslt_stat_cd is null
     and p_effective_date between drm.effective_start_date and drm.effective_end_date
     and opt.opt_id = nvl(drm.opt_id, -1)
     and opt.business_group_id = p_business_group_id
     and p_effective_date between opt.effective_start_date and opt.effective_end_date
     and oipl.opt_id = opt.opt_id
     and oipl.business_group_id = p_business_group_id
     and p_effective_date between oipl.effective_start_date and oipl.effective_end_date
     and pen.oipl_id = oipl.oipl_id
     and pen.business_group_id = p_business_group_id
     and p_effective_date between pen.effective_start_date and pen.effective_end_date
     and pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id  ;
  --
  cursor c_oipl_dsgn_rqmt is
  select distinct drt.rlshp_typ_cd
    from ben_dsgn_rqmt_rlshp_typ drt
       	 , ben_dsgn_rqmt_f drm
       	 , ben_oipl_f oipl
       	 , ben_prtt_enrt_rslt_f pen
   where drt.dsgn_rqmt_id = drm.dsgn_rqmt_id
     and drt.business_group_id = p_business_group_id
     and drm.dsgn_typ_cd = 'BNF'
     and drm.business_group_id = p_business_group_id
     and p_effective_date between drm.effective_start_date and drm.effective_end_date
     and oipl.oipl_id = nvl(drm.oipl_id, -1)
     and oipl.business_group_id = p_business_group_id
     and p_effective_date between oipl.effective_start_date and oipl.effective_end_date
     and pen.oipl_id = oipl.oipl_id
     and pen.business_group_id = p_business_group_id
     and p_effective_date between pen.effective_start_date and pen.effective_end_date
     and pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pen.prtt_enrt_rslt_stat_cd is null;
  --
  cursor c_pl_dsgn_rqmt is
  select distinct drt.rlshp_typ_cd
    from ben_dsgn_rqmt_rlshp_typ drt
       	 , ben_dsgn_rqmt_f drm
       	 , ben_pl_f pln
       	 , ben_prtt_enrt_rslt_f pen
   where drt.dsgn_rqmt_id = drm.dsgn_rqmt_id
     and drt.business_group_id = p_business_group_id
     and drm.dsgn_typ_cd = 'BNF'
     and drm.business_group_id = p_business_group_id
     and p_effective_date between drm.effective_start_date and drm.effective_end_date
     and pln.pl_id = nvl(drm.pl_id, -1)
     and pln.business_group_id = p_business_group_id
     and p_effective_date between pln.effective_start_date and pln.effective_end_date
     and pen.pl_id = pln.pl_id
     and pen.business_group_id = p_business_group_id
     and p_effective_date between pen.effective_start_date and pen.effective_end_date
     and pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pen.prtt_enrt_rslt_stat_cd is null;
  --
  cursor c_bnf_person_self is
    select null
    from ben_per_in_ler pil
    where pil.per_in_ler_id = p_per_in_ler_id
       and pil.business_group_id = p_business_group_id
       and ( pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
             or pil.per_in_ler_stat_cd is null )
       and pil.person_id = p_bnf_person_id ;
  --
  --- # 3212439 parametrer added to find the relationship
  cursor c_bnf_person_rel_typ (c_contact_type varchar2)  is
    select pcr.contact_type,
           hll.meaning
    from   per_contact_relationships pcr
    	   , ben_per_in_ler pil
    	   , hr_leg_lookups hll
    where  pil.per_in_ler_id = p_per_in_ler_id
       and pil.business_group_id = p_business_group_id
       and ( pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
             or pil.per_in_ler_stat_cd is null )
       and pcr.business_group_id = p_business_group_id
       and pcr.person_id = pil.person_id
       and pcr.contact_person_id = p_bnf_person_id
       and pcr.contact_type = c_contact_type
       and p_effective_date between nvl(pcr.date_start,p_effective_date) and nvl(pcr.date_end,p_effective_date)
       and hll.lookup_type = 'CONTACT'
       and p_effective_date
             between nvl(hll.start_date_active,p_effective_date) and nvl(hll.end_date_active,p_effective_date)
       and pcr.contact_type = hll.lookup_code  ;
  --
  cursor c_pl_oipl is
    select pl_id, oipl_id
    from ben_prtt_enrt_rslt_f pen
    where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and pen.prtt_enrt_rslt_stat_cd is null
      and pen.business_group_id = p_business_group_id
      and p_effective_date between pen.effective_start_date and pen.effective_end_date ;
  --
  cursor c_opt (p_oipl_id number) is
    select oipl.opt_id
    from ben_oipl_f oipl
    where oipl.oipl_id = p_oipl_id
      and oipl.business_group_id = p_business_group_id
      and p_effective_date between oipl.effective_start_date and oipl.effective_end_date ;

Procedure raise_error is
--
 cursor c_pl_name (p_pl_id number) is
   select name
   from ben_pl_f
   where pl_id=p_pl_id
     and p_effective_date between effective_start_date and effective_end_date ;
 --
 cursor c_opt_name (p_opt_id number) is
    select name
    from ben_opt_f
    where opt_id=p_opt_id
     and p_effective_date between effective_start_date and effective_end_date ;
--
  l_pl_name  ben_pl_f.name%TYPE;
  l_opt_name ben_opt_f.name%TYPE;
Begin

    open c_pl_oipl;
    fetch c_pl_oipl into l_pl_id, l_oipl_id;
    close c_pl_oipl;
    --
    if l_oipl_id is not null then
       open c_opt(l_oipl_id);
       fetch c_opt into l_opt_id;
       close c_opt;
    end if;
    --
    --Bug 2869639: we will display Plan and option names instead of Id's
    --
    open c_pl_name (l_pl_id);
    fetch c_pl_name into l_pl_name;
    close c_pl_name;
    if l_opt_id is not NULL then
    open c_opt_name (l_opt_id);
    fetch c_opt_name into l_opt_name;
    close c_opt_name;
    end if;
    --
    -- Bug 2869639 Added separate message when option id is null
    if l_opt_id is not NULL then
    	fnd_message.set_name('BEN', 'BEN_93049_INVLD_BNF_CNTCT_TYPE');
    	fnd_message.set_token('RLTYP', nvl(l_lkup_meaning_reln_type,''));
    	fnd_message.set_token('PL_ID', l_pl_name );
  --	fnd_message.set_token('OIPL_ID', to_char(l_oipl_id) );
    	fnd_message.set_token('OPT_ID', l_opt_name );
    else
    	fnd_message.set_name('BEN', 'BEN_93904_INVLD_BNF_CNTCT_T_PL');
    	fnd_message.set_token('RLTYP', nvl(l_lkup_meaning_reln_type,''));
    	fnd_message.set_token('PL_ID', l_pl_name );
    end if;
    --
    fnd_message.raise_error;

End;

Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_pbn_shd.api_updating
     (p_pl_bnf_id               => p_pl_bnf_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);

  --
  -- Check if beneficiary is person or organisation, if not person then return
  --
  if p_bnf_person_id is null then
    --
    return ;
    --
  end if;
  --
  --
  -- Check if beneficiary is the person (employee) himself
  --
  open c_bnf_person_self;
  --
    fetch c_bnf_person_self into l_dummy;
    if c_bnf_person_self%found then
      --
      close c_bnf_person_self;
      --
      -- person (employee) himself is the beneficiary
      -- which is a valid case and no further validation reqd
      --
      return;
      --
    end if;
  --
  close c_bnf_person_self;
  --
  -- get contact relationship type of the person
  --
   --- # 3212439  this cursor moved to inside loop to find each relation in rqmt
 -- open c_bnf_person_rel_typ;
 -- fetch c_bnf_person_rel_typ into l_rel_typ,l_lkup_meaning_reln_type ;
 -- close c_bnf_person_rel_typ;
  --
  -- check if the designated beneficiary has a contact type provided
  -- at option level designation requirement.
  --
  hr_utility.set_location('l_rel_typ' || l_rel_typ ,07);
  hr_utility.set_location('l_lkup_meaning_reln_type' || l_lkup_meaning_reln_type ,07);
  open c_opt_dsgn_rqmt;
  loop
    fetch c_opt_dsgn_rqmt into l_rlshp_typ_cd;
    if c_opt_dsgn_rqmt%notfound then
       if c_opt_dsgn_rqmt%rowcount > 0 then
          close c_opt_dsgn_rqmt ;
          raise_error;
       end if;
       exit;
    end if;
    -- 3212439
    hr_utility.set_location('l_rlshp_typ_cd' || l_rlshp_typ_cd ,07);
    open c_bnf_person_rel_typ (l_rlshp_typ_cd);
    fetch c_bnf_person_rel_typ into l_rel_typ,l_lkup_meaning_reln_type ;
    hr_utility.set_location('l_rel_typ' || l_rel_typ ,07);
    hr_utility.set_location('l_lkup_meaning_reln_type' || l_lkup_meaning_reln_type ,07);
    if c_bnf_person_rel_typ%found then
       close c_bnf_person_rel_typ ;
       close c_opt_dsgn_rqmt ;
       return;
    end if ;
    close c_bnf_person_rel_typ;


  end loop;
  close c_opt_dsgn_rqmt ;
  --
  -- check if the designated beneficiary has a contact type provided
  -- at option in plan level designation requirement.
  --
  hr_utility.set_location(l_proc,10);
  open c_oipl_dsgn_rqmt;
  loop
    fetch c_oipl_dsgn_rqmt into l_rlshp_typ_cd;
    if c_oipl_dsgn_rqmt%notfound then
       if c_oipl_dsgn_rqmt%rowcount > 0 then
          close c_oipl_dsgn_rqmt ;
          raise_error;
       end if;
       exit;
    end if;

     -- 3212439
    hr_utility.set_location('l_rlshp_typ_cd' || l_rlshp_typ_cd ,08);
    open c_bnf_person_rel_typ (l_rlshp_typ_cd);
    fetch c_bnf_person_rel_typ into l_rel_typ,l_lkup_meaning_reln_type ;
    hr_utility.set_location('l_rel_typ' || l_rel_typ ,08);
    hr_utility.set_location('l_lkup_meaning_reln_type' || l_lkup_meaning_reln_type ,08);
    if c_bnf_person_rel_typ%found then
       close c_bnf_person_rel_typ ;
       close c_oipl_dsgn_rqmt ;
       return;
    end if ;
    close c_bnf_person_rel_typ;


   --  if l_rlshp_typ_cd = l_rel_typ then
   --     close c_oipl_dsgn_rqmt ;
   --    return;
   -- end if;

  end loop;
  close c_oipl_dsgn_rqmt ;
  --
  -- check if the designated beneficiary has a contact type provided
  -- at plan level designation requirement.
  --
  hr_utility.set_location(l_proc,15);
  open c_pl_dsgn_rqmt;
  loop
    fetch c_pl_dsgn_rqmt into l_rlshp_typ_cd;
    if c_pl_dsgn_rqmt%notfound then
       if c_pl_dsgn_rqmt%rowcount > 0 then
          close c_pl_dsgn_rqmt ;
          raise_error;
       end if;
       exit;
    end if;

    -- 3212439
    hr_utility.set_location('l_rlshp_typ_cd' || l_rlshp_typ_cd ,09);
    open c_bnf_person_rel_typ (l_rlshp_typ_cd);
    fetch c_bnf_person_rel_typ into l_rel_typ,l_lkup_meaning_reln_type ;
    hr_utility.set_location('l_rel_typ' || l_rel_typ ,09);
    hr_utility.set_location('l_lkup_meaning_reln_type' || l_lkup_meaning_reln_type ,09);
    if c_bnf_person_rel_typ%found then
       close c_bnf_person_rel_typ ;
       close c_pl_dsgn_rqmt ;
       return;
    end if ;
    close c_bnf_person_rel_typ;


    --    if l_rlshp_typ_cd = l_rel_typ then
    --   close c_pl_dsgn_rqmt ;
    --   return;
    --    end if;

  end loop;
  close c_pl_dsgn_rqmt ;
  hr_utility.set_location('Leaving:'||l_proc,40);
  --
End chk_bnf_dsgn_rqmt_relnshp_typ ;
--
--
/*-- ----------------------------------------------------------------------------
-- |------------------< chk_bnf_dsgn_rqmt_relnshp_typ >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the designated beneficary's relationship is valid
--   as per the designation requirements given at Option / option in Plan / Plan levels
--   in that order.
--   This check procedure has been added to fix bug 2367632 -  - .
--   This is called from insert_validate and update_validate procedures.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_pl_bnf_id 		PK
--   p_bnf_person_id 		ID of contact perosn who has been designated as beneficiary
--   p_per_in_ler_id 		per_in_ler_id
--   p_prtt_enrt_rslt_id	participant enrollment result ID used to get PL /OIPL / OPT details
--   p_business_group_id	business_group_id
--   p_effective_date 		session date
--   p_object_version_number 	object version number
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
Procedure chk_bnf_dsgn_rqmt_relnshp_typ (p_pl_bnf_id             in number,
                              		 p_bnf_person_id         in number,
                              		 p_per_in_ler_id         in number,
                              		 p_prtt_enrt_rslt_id     in number,
                              		 p_business_group_id     in number,
                              		 p_effective_date        in date,
                              		 p_object_version_number in number) is
  --
  l_proc         		varchar2(72) := g_package||'chk_bnf_dsgn_rqmt_relnshp_typ';
  l_api_updating 		boolean;
  l_dummy        		varchar2(1);
  l_lkup_meaning_reln_type 	varchar2(80);
  l_pl_id        		number;
  l_oipl_id			number;
  l_opt_id			number;
  --
  --
  cursor c_opt_dsgn_rqmt is
    select null
    from   per_contact_relationships pcr
    	   , ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id
       and pil.business_group_id = p_business_group_id
       and ( pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
             or pil.per_in_ler_stat_cd is null )
       and pcr.business_group_id = p_business_group_id
       and pcr.person_id = pil.person_id
       and pcr.contact_person_id = p_bnf_person_id
       and p_effective_date between nvl(pcr.date_start,p_effective_date) and nvl(pcr.date_end,p_effective_date)
       and pcr.contact_type in
       	   	(select distinct drt.rlshp_typ_cd
       	   	 from ben_dsgn_rqmt_rlshp_typ drt
       	   	      , ben_dsgn_rqmt_f drm
       	   	      , ben_opt_f opt
       	   	      , ben_oipl_f oipl
       	   	      , ben_prtt_enrt_rslt_f pen
       	   	 where drt.dsgn_rqmt_id = drm.dsgn_rqmt_id
       	   	   and drt.business_group_id = p_business_group_id
       	   	   and drm.dsgn_typ_cd = 'BNF'
       	   	   and drm.business_group_id = p_business_group_id
       	   	   and p_effective_date between drm.effective_start_date and drm.effective_end_date
       	   	   and opt.opt_id = nvl(drm.opt_id, -1)
       	   	   and opt.business_group_id = p_business_group_id
       	   	   and p_effective_date between opt.effective_start_date and opt.effective_end_date
       	   	   and oipl.opt_id = opt.opt_id
       	   	   and oipl.business_group_id = p_business_group_id
       	   	   and p_effective_date between oipl.effective_start_date and oipl.effective_end_date
       	   	   and pen.oipl_id = oipl.oipl_id
       	   	   and pen.business_group_id = p_business_group_id
       	   	   and p_effective_date between pen.effective_start_date and pen.effective_end_date
       	   	   and pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id ) ;
  --
  cursor c_oipl_dsgn_rqmt is
    select null
    from   per_contact_relationships pcr
    	   , ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id
       and pil.business_group_id = p_business_group_id
       and ( pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
             or pil.per_in_ler_stat_cd is null )
       and pcr.business_group_id = p_business_group_id
       and pcr.person_id = pil.person_id
       and pcr.contact_person_id = p_bnf_person_id
       and p_effective_date between nvl(pcr.date_start,p_effective_date) and nvl(pcr.date_end,p_effective_date)
       and pcr.contact_type in
       	   	(select distinct drt.rlshp_typ_cd
       	   	 from ben_dsgn_rqmt_rlshp_typ drt
       	   	      , ben_dsgn_rqmt_f drm
       	   	      , ben_oipl_f oipl
       	   	      , ben_prtt_enrt_rslt_f pen
       	   	 where drt.dsgn_rqmt_id = drm.dsgn_rqmt_id
       	   	   and drt.business_group_id = p_business_group_id
       	   	   and drm.dsgn_typ_cd = 'BNF'
       	   	   and drm.business_group_id = p_business_group_id
       	   	   and p_effective_date between drm.effective_start_date and drm.effective_end_date
       	   	   and oipl.oipl_id = nvl(drm.oipl_id, -1)
       	   	   and oipl.business_group_id = p_business_group_id
       	   	   and p_effective_date between oipl.effective_start_date and oipl.effective_end_date
       	   	   and pen.oipl_id = oipl.oipl_id
       	   	   and pen.business_group_id = p_business_group_id
       	   	   and p_effective_date between pen.effective_start_date and pen.effective_end_date
       	   	   and pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id ) ;
  --
  cursor c_pl_dsgn_rqmt is
    select null
    from   per_contact_relationships pcr
    	   , ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id
       and pil.business_group_id = p_business_group_id
       and ( pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
             or pil.per_in_ler_stat_cd is null )
       and pcr.business_group_id = p_business_group_id
       and pcr.person_id = pil.person_id
       and pcr.contact_person_id = p_bnf_person_id
       and p_effective_date between nvl(pcr.date_start,p_effective_date) and nvl(pcr.date_end,p_effective_date)
       and pcr.contact_type in
       	   	(select distinct drt.rlshp_typ_cd
       	   	 from ben_dsgn_rqmt_rlshp_typ drt
       	   	      , ben_dsgn_rqmt_f drm
       	   	      , ben_pl_f pln
       	   	      , ben_prtt_enrt_rslt_f pen
       	   	 where drt.dsgn_rqmt_id = drm.dsgn_rqmt_id
       	   	   and drt.business_group_id = p_business_group_id
       	   	   and drm.dsgn_typ_cd = 'BNF'
       	   	   and drm.business_group_id = p_business_group_id
       	   	   and p_effective_date between drm.effective_start_date and drm.effective_end_date
       	   	   and pln.pl_id = nvl(drm.pl_id, -1)
       	   	   and pln.business_group_id = p_business_group_id
       	   	   and p_effective_date between pln.effective_start_date and pln.effective_end_date
       	   	   and pen.pl_id = pln.pl_id
       	   	   and pen.business_group_id = p_business_group_id
       	   	   and p_effective_date between pen.effective_start_date and pen.effective_end_date
       	   	   and pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id ) ;
  --
  cursor c_bnf_person_self is
    select null
    from ben_per_in_ler pil
    where pil.per_in_ler_id = p_per_in_ler_id
       and pil.business_group_id = p_business_group_id
       and ( pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
             or pil.per_in_ler_stat_cd is null )
       and pil.person_id = p_bnf_person_id ;
  --
  cursor c_bnf_person_rel_typ is
    select hll.meaning
    from   per_contact_relationships pcr
    	   , ben_per_in_ler pil
    	   , hr_leg_lookups hll
    where  pil.per_in_ler_id = p_per_in_ler_id
       and pil.business_group_id = p_business_group_id
       and ( pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
             or pil.per_in_ler_stat_cd is null )
       and pcr.business_group_id = p_business_group_id
       and pcr.person_id = pil.person_id
       and pcr.contact_person_id = p_bnf_person_id
       and p_effective_date between nvl(pcr.date_start,p_effective_date) and nvl(pcr.date_end,p_effective_date)
       and hll.lookup_type = 'CONTACT'
       and p_effective_date
             between nvl(hll.start_date_active,p_effective_date) and nvl(hll.end_date_active,p_effective_date)
       and pcr.contact_type = hll.lookup_code  ;
  --
  cursor c_pl_oipl is
    select pl_id, oipl_id
    from ben_prtt_enrt_rslt_f pen
    where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and pen.business_group_id = p_business_group_id
      and p_effective_date between pen.effective_start_date and pen.effective_end_date ;
  --
  cursor c_opt (p_oipl_id number) is
    select oipl.opt_id
    from ben_oipl_f oipl
    where oipl.oipl_id = p_oipl_id
      and oipl.business_group_id = p_business_group_id
      and p_effective_date between oipl.effective_start_date and oipl.effective_end_date ;

Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_pbn_shd.api_updating
     (p_pl_bnf_id               => p_pl_bnf_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);

  --
  -- Check if beneficiary is person or organisation, if not person then return
  --
  if p_bnf_person_id is null then
    --
    return ;
    --
  end if;
  --

  --
  -- Check if beneficiary is the person (employee) himself
  --
  open c_bnf_person_self;
  --
    fetch c_bnf_person_self into l_dummy;
    if c_bnf_person_self%found then
      --
      close c_bnf_person_self;
      --
      -- person (employee) himself is the beneficiary
      -- which is a valid case and no further validation reqd
      --
      return;
      --
    end if;
  --
  close c_bnf_person_self;
  --

  --
  -- check if the designated beneficiary has a contact type provided
  -- at option level designation requirement.
  --
  open c_opt_dsgn_rqmt;
  --
    fetch c_opt_dsgn_rqmt into l_dummy;
    if c_opt_dsgn_rqmt%found then
       close c_opt_dsgn_rqmt ;
       hr_utility.set_location(l_proc,07);
    elsif c_opt_dsgn_rqmt%notfound then
        --
        hr_utility.set_location(l_proc,10);
        close c_opt_dsgn_rqmt;
        --
        -- check if the designated beneficiary has a contact type provided
        -- at option in plan level designation requirement.
        --
        open c_oipl_dsgn_rqmt;
        --
          fetch c_oipl_dsgn_rqmt into l_dummy;
          if c_oipl_dsgn_rqmt%found then
             close c_oipl_dsgn_rqmt ;
             hr_utility.set_location(l_proc,15);
          elsif c_oipl_dsgn_rqmt%notfound then
              --
              hr_utility.set_location(l_proc,20);
              close c_oipl_dsgn_rqmt;
              --
              -- check if the designated beneficiary has a contact type provided
              -- at plan level designation requirement.
              --
              open c_pl_dsgn_rqmt;
              --
                fetch c_pl_dsgn_rqmt into l_dummy;
                if c_pl_dsgn_rqmt%notfound then
                    --
                    hr_utility.set_location(l_proc,30);
                    close c_pl_dsgn_rqmt;
                    --
                    -- Since the contact type has not been provided as a designation requirement
                    -- at option / option in plan / plan level, Raise an error that this
                    -- person cannot be designated as a beneficiary for this plan + option.
                    --
                    --
                    -- get contact relationship type of the person
                    --
                    open c_bnf_person_rel_typ;
                    fetch c_bnf_person_rel_typ into l_lkup_meaning_reln_type ;
                    if c_bnf_person_rel_typ%found then
                      fnd_message.set_token('RLTYP', l_lkup_meaning_reln_type);
                    end if;
                    close c_bnf_person_rel_typ;
                    --
                    -- get plan and oipl ids, if oipl_id is not null then retrieve opt_id also
                    --
                    open c_pl_oipl;
                    fetch c_pl_oipl into l_pl_id, l_oipl_id;
                    close c_pl_oipl;
                    --
                    if l_oipl_id is not null then
                      open c_opt(l_oipl_id);
                      fetch c_opt into l_opt_id;
                      close c_opt;
                    end if;
                    --
                    fnd_message.set_name('BEN', 'BEN_93049_INVLD_BNF_CNTCT_TYPE');
                    fnd_message.set_token('RLTYP', nvl(l_lkup_meaning_reln_type,''));
                    fnd_message.set_token('PL_ID', to_char(l_pl_id) );
                    fnd_message.set_token('OIPL_ID', to_char(l_oipl_id) );
                    fnd_message.set_token('OPT_ID', to_char(l_opt_id) );
                    fnd_message.raise_error;
                    --
                end if;
                --
              close c_pl_dsgn_rqmt;
          end if;
          --
        -- close c_oipl_dsgn_rqmt;
        --
    end if;
    --
  -- close c_opt_dsgn_rqmt;
  --
  hr_utility.set_location('Leaving:'||l_proc,40);
  --
End chk_bnf_dsgn_rqmt_relnshp_typ ;
--*/
--
-- ----------------------------------------------------------------------------
-- |------< chk_organization_id >------|
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
--   p_pl_bnf_id PK
--   p_organization_id ID of FK column
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
Procedure chk_organization_id (p_pl_bnf_id             in number,
                               p_organization_id       in number,
                               p_effective_date        in date,
                               p_business_group_id     in number,
                               p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bnf_person_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_exists       varchar2(1);
  --
  --
  --
  cursor c1 is
    select null
    from   hr_all_organization_units a
    where  a.organization_id = p_organization_id
      and  a.business_group_id + 0 = p_business_group_id
           ;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_pbn_shd.api_updating
     (p_pl_bnf_id               => p_pl_bnf_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if p_organization_id is not null then
  if (l_api_updating
     and nvl(p_organization_id,hr_api.g_number)
     <> nvl(ben_pbn_shd.g_old_rec.organization_id, hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if organization_id value exists in hr_all_organization_units table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_all_people
        -- table.
        --
        ben_pbn_shd.constraint_error('BEN_PL_BNF_FK3');
        --
      end if;
      --
    close c1;
    --
    --
  end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_organization_id;

-- Bug 2843162
--
-- ----------------------------------------------------------------------------
-- |------< chk_bnf_primy_cntgnt_exist >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the same beneficiary is not designated
--   as both primary and contingent
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_pl_bnf_id PK
--   p_organization_id ID of FK column
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
Procedure chk_bnf_primy_cntgnt_exist (p_pl_bnf_id             in number,
			       p_bnf_person_id         in number,
                               p_organization_id       in number,
                               p_effective_date        in date,
                               p_business_group_id     in number,
                               p_prmry_cntngnt_cd      in varchar2,
                               p_prtt_enrt_rslt_id     in number,
                               p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bnf_primy_cntgnt_exist';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_exists       varchar2(1);
  --
  --
  --
  cursor c1 is
	select 	null
	from   	ben_pl_bnf_f pbn,
           	ben_per_in_ler pil
	where  	(pbn.bnf_person_id = p_bnf_person_id
             	 or  pbn.organization_id = p_organization_id)
	and  	pil.per_in_ler_id (+) = pbn.per_in_ler_id
	and  	pil.business_group_id (+) = pbn.business_group_id
	and 	( pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
                 or pil.per_in_ler_stat_cd is null )
	and 	pbn.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
	and 	pbn.pl_bnf_id <> nvl(p_pl_bnf_id,hr_api.g_number)
	and 	pbn.business_group_id = p_business_group_id
	and	pbn.prmry_cntngnt_cd <> p_prmry_cntngnt_cd
	and 	p_effective_date between pbn.effective_start_date and (pbn.effective_end_date -1);

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_pbn_shd.api_updating
     (p_pl_bnf_id               => p_pl_bnf_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and (nvl(p_organization_id,hr_api.g_number) <> nvl(ben_pbn_shd.g_old_rec.organization_id, hr_api.g_number)
     or nvl(p_bnf_person_id,hr_api.g_number)  <> nvl(ben_pbn_shd.g_old_rec.bnf_person_id, hr_api.g_number)
     or nvl(p_prmry_cntngnt_cd,hr_api.g_varchar2)  <> nvl(ben_pbn_shd.g_old_rec.prmry_cntngnt_cd, hr_api.g_varchar2))
     or not l_api_updating) then
    --
    -- check if person/organization has already been designated as a
    -- bnf with a different prmry_cntngnt_cd
    --

    open c1;
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        --
        -- raise error as the person/organization has already been designated
        --
        --
	fnd_message.set_name('BEN', 'BEN_92619_PRIMY_AND_CNTGNT');
	fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_bnf_primy_cntgnt_exist;

-- end 2843162

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
	     (p_per_in_ler_id                in number default hr_api.g_number,
             p_prtt_enrt_rslt_id             in number default hr_api.g_number,
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
    If ((nvl(p_prtt_enrt_rslt_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_prtt_enrt_rslt_f',
             p_base_key_column => 'prtt_enrt_rslt_id',
             p_base_key_value  => p_prtt_enrt_rslt_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_prtt_enrt_rslt_f';
      Raise l_integrity_error;
    End If;
 --
    --
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
    -- ben_utility.parent_integrity_error(p_table_name => l_table_name);
    --
    ben_utility.parent_integrity_error(p_table_name=> l_table_name);
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
            (p_pl_bnf_id		in number,
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
       p_argument       => 'pl_bnf_id',
       p_argument_value => p_pl_bnf_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_pl_bnf_ctfn_prvdd_f',
           p_base_key_column => 'pl_bnf_id',
           p_base_key_value  => p_pl_bnf_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_pl_bnf_ctfn_prvdd_f';
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
    -- ben_utility.child_exists_error(p_table_name => l_table_name);
    --
    ben_utility.child_exists_error(p_table_name=> l_table_name);
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
	(p_rec 			 in ben_pbn_shd.g_rec_type,
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
  chk_pl_bnf_id
  (p_pl_bnf_id             => p_rec.pl_bnf_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  -- Bug Fix 2367632
  --
  chk_bnf_dsgn_rqmt_relnshp_typ
  (p_pl_bnf_id             => p_rec.pl_bnf_id,
   p_bnf_person_id         => p_rec.bnf_person_id,
   p_per_in_ler_id         => p_rec.per_in_ler_id,
   p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --End fix 2367632
  --
  chk_prmry_cntngnt_cd
  (p_pl_bnf_id             => p_rec.pl_bnf_id,
   p_prmry_cntngnt_cd      => p_rec.prmry_cntngnt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_all_pl_bnf_parameters
  (p_pl_bnf_id             => p_rec.pl_bnf_id,
   p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_prmry_cntngnt_cd      => p_rec.prmry_cntngnt_cd,
   p_organization_id       => p_rec.organization_id,
   p_addl_instrn_txt       => p_rec.addl_instrn_txt,
   p_amt_dsgd_val          => p_rec.amt_dsgd_val,
   p_pct_dsgd_num          => p_rec.pct_dsgd_num,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
 --
  chk_bnf_person_id
  (p_pl_bnf_id             => p_rec.pl_bnf_id,
   p_bnf_person_id         => p_rec.bnf_person_id,
   p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
 --
  chk_organization_id
  (p_pl_bnf_id             => p_rec.pl_bnf_id,
   p_organization_id       => p_rec.organization_id,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
 --
  chk_ttee_person_id
  (p_pl_bnf_id             => p_rec.pl_bnf_id,
   p_ttee_person_id        => p_rec.ttee_person_id,
   p_bnf_person_id         => p_rec.bnf_person_id,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
 --

 --
 -- Bug 2843162
 --
  chk_bnf_primy_cntgnt_exist
  (p_pl_bnf_id             => p_rec.pl_bnf_id,
   p_bnf_person_id         => p_rec.bnf_person_id,
   p_organization_id       => p_rec.organization_id,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_prmry_cntngnt_cd      => p_rec.prmry_cntngnt_cd,
   p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_object_version_number => p_rec.object_version_number);
 --
 -- End of Bug 2843162
 --

 -- maagrawa Aug 05, 2000.
 -- The following two checks (chk_pct_dsgd_num) and (chk_amt_dsgd_val) have
 -- been moved to bnf_actn_items procedure in the api.
 -- This was done as the total checks should be done only after all records
 -- have been saved and not for individual records.
 -- The bnf_actn_items procedure is only called when multi_rows_actn is TRUE.
 -- (Bug 1368208).
 --
 -- chk_pct_dsgd_num
 --  (p_pl_bnf_id             => p_rec.pl_bnf_id,
 --   p_pct_dsgd_num          => p_rec.pct_dsgd_num,
 --   p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
 --   p_prmry_cntngnt_cd      => p_rec.prmry_cntngnt_cd,
 --   p_validation_start_date => p_validation_start_date,
 --   p_validation_end_date   => p_validation_end_date,
 --   p_effective_date        => p_effective_date,
 --   p_business_group_id     => p_rec.business_group_id,
 --   p_object_version_number => p_rec.object_version_number);
--
 -- chk_amt_dsgd_val
 -- (p_pl_bnf_id              => p_rec.pl_bnf_id,
 --  p_amt_dsgd_val           => p_rec.amt_dsgd_val,
 --  p_prtt_enrt_rslt_id      => p_rec.prtt_enrt_rslt_id,
 --  p_prmry_cntngnt_cd       => p_rec.prmry_cntngnt_cd,
 --  p_validation_start_date  => p_validation_start_date,
 --  p_validation_end_date    => p_validation_end_date,
 --  p_effective_date         => p_effective_date,
 --  p_business_group_id      => p_rec.business_group_id,
 --  p_object_version_number  => p_rec.object_version_number);
 --
 chk_amt_dsgd_uom
  (p_pl_bnf_id             => p_rec.pl_bnf_id,
   p_amt_dsgd_uom          => p_rec.amt_dsgd_uom,
   p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_effective_date        => p_effective_date,
   p_business_group_id      => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_pbn_shd.g_rec_type,
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

  chk_pl_bnf_id
  (p_pl_bnf_id          => p_rec.pl_bnf_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  -- Bug Fix 2367632
  --
  chk_bnf_dsgn_rqmt_relnshp_typ
  (p_pl_bnf_id             => p_rec.pl_bnf_id,
   p_bnf_person_id         => p_rec.bnf_person_id,
   p_per_in_ler_id         => p_rec.per_in_ler_id,
   p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --End fix 2367632
  --
  chk_prmry_cntngnt_cd
  (p_pl_bnf_id          => p_rec.pl_bnf_id,
   p_prmry_cntngnt_cd         => p_rec.prmry_cntngnt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_all_pl_bnf_parameters
  (p_pl_bnf_id             => p_rec.pl_bnf_id,
   p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_prmry_cntngnt_cd      => p_rec.prmry_cntngnt_cd,
   p_organization_id       => p_rec.organization_id,
   p_addl_instrn_txt       => p_rec.addl_instrn_txt,
   p_amt_dsgd_val          => p_rec.amt_dsgd_val,
   p_pct_dsgd_num          => p_rec.pct_dsgd_num,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
 --
 chk_bnf_person_id
  (p_pl_bnf_id             => p_rec.pl_bnf_id,
   p_bnf_person_id         => p_rec.bnf_person_id,
   p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
 --
 chk_organization_id
  (p_pl_bnf_id             => p_rec.pl_bnf_id,
   p_organization_id       => p_rec.organization_id,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
 --
  chk_ttee_person_id
  (p_pl_bnf_id             => p_rec.pl_bnf_id,
   p_ttee_person_id        => p_rec.ttee_person_id,
   p_bnf_person_id         => p_rec.bnf_person_id,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
 --

 --
 -- Bug 2843162
 --
  chk_bnf_primy_cntgnt_exist
  (p_pl_bnf_id             => p_rec.pl_bnf_id,
   p_bnf_person_id         => p_rec.bnf_person_id,
   p_organization_id       => p_rec.organization_id,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_prmry_cntngnt_cd      => p_rec.prmry_cntngnt_cd,
   p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_object_version_number => p_rec.object_version_number);

 --
 -- End Bug 2843162
 --

 --
 -- maagrawa Aug 05, 2000.
 -- The following two checks (chk_pct_dsgd_num) and (chk_amt_dsgd_val) have
 -- been moved to bnf_actn_items procedure in the api.
 -- This was done as the total checks should be done only after all records
 -- have been saved and not for individual records.
 -- The bnf_actn_items procedure is only called when multi_rows_actn is TRUE.
 -- (Bug 1368208).
 --
 -- chk_pct_dsgd_num
 --  (p_pl_bnf_id             => p_rec.pl_bnf_id,
 --   p_pct_dsgd_num          => p_rec.pct_dsgd_num,
 --   p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
 --   p_prmry_cntngnt_cd      => p_rec.prmry_cntngnt_cd,
 --   p_validation_start_date => p_validation_start_date,
 --   p_validation_end_date   => p_validation_end_date,
 --   p_effective_date        => p_effective_date,
 --   p_business_group_id     => p_rec.business_group_id,
 --   p_object_version_number => p_rec.object_version_number);
--
 -- chk_amt_dsgd_val
 -- (p_pl_bnf_id              => p_rec.pl_bnf_id,
 --  p_amt_dsgd_val           => p_rec.amt_dsgd_val,
 --  p_prtt_enrt_rslt_id      => p_rec.prtt_enrt_rslt_id,
 --  p_prmry_cntngnt_cd       => p_rec.prmry_cntngnt_cd,
 --  p_validation_start_date  => p_validation_start_date,
 --  p_validation_end_date    => p_validation_end_date,
 --  p_effective_date         => p_effective_date,
 --  p_business_group_id      => p_rec.business_group_id,
 --  p_object_version_number  => p_rec.object_version_number);
 --
 chk_amt_dsgd_uom
  (p_pl_bnf_id             => p_rec.pl_bnf_id,
   p_amt_dsgd_uom          => p_rec.amt_dsgd_uom,
   p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_effective_date        => p_effective_date,
   p_business_group_id      => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
 --
 --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_per_in_ler_id                 => p_rec.per_in_ler_id,
     p_prtt_enrt_rslt_id             => p_rec.prtt_enrt_rslt_id,
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
	(p_rec 			 in ben_pbn_shd.g_rec_type,
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
     p_pl_bnf_id		=> p_rec.pl_bnf_id);
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
  (p_pl_bnf_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_pl_bnf_f b
    where b.pl_bnf_id      = p_pl_bnf_id
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
                             p_argument       => 'pl_bnf_id',
                             p_argument_value => p_pl_bnf_id);
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
end ben_pbn_bus;

/
