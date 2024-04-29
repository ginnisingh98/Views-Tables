--------------------------------------------------------
--  DDL for Package Body BEN_CCM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CCM_BUS" as
/* $Header: beccmrhi.pkb 120.5 2006/03/22 02:53:46 rgajula noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ccm_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_cvg_amt_calc_mthd_id >------|
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
--   cvg_amt_calc_mthd_id PK of record being inserted or updated.
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
Procedure chk_cvg_amt_calc_mthd_id(p_cvg_amt_calc_mthd_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cvg_amt_calc_mthd_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ccm_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_cvg_amt_calc_mthd_id                => p_cvg_amt_calc_mthd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_cvg_amt_calc_mthd_id,hr_api.g_number)
     <>  ben_ccm_shd.g_old_rec.cvg_amt_calc_mthd_id) then
    --
    -- raise error as PK has changed
    --
    ben_ccm_shd.constraint_error('BEN_CVG_AMT_CALC_MTHD_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_cvg_amt_calc_mthd_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_ccm_shd.constraint_error('BEN_CVG_AMT_CALC_MTHD_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_cvg_amt_calc_mthd_id;

-- ----------------------------------------------------------------------------
-- |-------------------------< chk_pen_rows_exist >----------------------------|
-- ----------------------------------------------------------------------------
--
-- If user wants to NULLIFY a coverage provided through a plan, there is no
-- way other than deleting the coverage and re-electing the plan. So we want
-- to allow user to end date the coverage. In any case PURGE would not be allowed
-- for coverage. If we end-date the coverage, we want to check that the new
-- effective end date is not before GREATEST enrollment coverage start date
-- in the plan
--
procedure chk_pen_rows_exist ( p_cvg_amt_calc_mthd_id           in number,
                               p_effective_date                 in date,
                               p_pl_id                          in number,
                               p_oipl_id                        in number,
                               p_business_group_id              in number,
                               p_datetrack_mode                 in varchar2 )
is
  --
  l_dummy                 varchar2(1) ;
  l_proc                  varchar2(72) := g_package || '.chk_pen_rows_exist';
  l_max_cvg_strt_dt       date;
  l_creation_date         date;
  --
  cursor c_max_cvg_strt_dt
  is
     select max(pen.ENRT_CVG_STRT_DT)
       from ben_prtt_enrt_rslt_f pen
      where ( pl_id = nvl(p_pl_id, -9999) OR
              oipl_id = nvl(p_oipl_id, -9999)
            )
        and pen.prtt_enrt_rslt_stat_cd is null
        and pen.business_group_id = p_business_group_id
        and pen.bnft_amt is not null
        and (pen.creation_date) >= (l_creation_date);
  --
  cursor c_creation_date
  is
     select min(creation_date)
       from ben_cvg_amt_calc_mthd_F
      where cvg_amt_calc_mthd_id = p_cvg_amt_calc_mthd_id;
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_creation_date;
    --
    fetch c_creation_date into l_creation_date;
    --
  close c_creation_date;
  --
  if l_creation_date is not null
  then
    --
    open c_max_cvg_strt_dt;
      --
      fetch c_max_cvg_strt_dt into l_max_cvg_strt_dt;
      --
      if l_max_cvg_strt_dt is not null
      then
        --
        hr_utility.set_location('l_max_cvg_strt_dt = ' || l_max_cvg_strt_dt, 8888);
        if p_datetrack_mode = 'ZAP'
        then
          --
          close c_max_cvg_strt_dt;
          --
	  --Bug 5109636 : Change of token from END_DATE to START_DATE
          fnd_message.set_name('BEN', 'BEN_94992_PEN_ROWS_EXIST');
          fnd_message.set_token('START_DATE', fnd_date.date_to_displaydate(l_max_cvg_strt_dt));
          fnd_message.raise_error;
          --
        elsif p_datetrack_mode = 'DELETE' AND
              p_effective_date < l_max_cvg_strt_dt
        then
          --
          close c_max_cvg_strt_dt;
          --
  	  --Bug 5109636 : Change of token from END_DATE to START_DATE
          fnd_message.set_name('BEN', 'BEN_94993_DT_PEN_ROWS_EXIST');
          fnd_message.set_token('START_DATE', fnd_date.date_to_displaydate(l_max_cvg_strt_dt));
          fnd_message.raise_error;
          --
        end if;
        --
      end if;
      --
    close c_max_cvg_strt_dt;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
end chk_pen_rows_exist;

-- ----------------------------------------------------------------------------
-- |------< chk_entr_at_enrt_with_rate >------|
-- ----------------------------------------------------------------------------
--
-- Description
--
--
--
-- when the coverage defined as enter rate at entrollment on , this should be validated against
-- standard rate ,if the rate is defined for the same plan or plop with muliple coverage and
-- enter and entrolment on then  error is to be thrown


Procedure chk_entr_at_enrt_with_rate( p_entr_val_at_enrt_flag      in varchar2,
                                    p_pl_id                       in number,
                                    p_oipl_id                     in number,
                                    p_effective_date              in date   ) is

l_dummy       varchar2(1) ;
l_proc        varchar2(72) := g_package||'chk_entr_at_enrt_with_rate';

cursor c_pl is select 'x'  from
    ben_acty_base_rt_f  where pl_id = p_pl_id  and
    rt_mlt_cd = 'CVG' and  entr_val_at_enrt_flag = 'Y' and
    p_effective_date between effective_start_date and effective_end_date  ;

cursor c_plip  is select 'x' from  ben_acty_base_rt_f a , ben_plip_f  b  where
     a.plip_id = b.plip_id  and   a.rt_mlt_cd = 'CVG' and  a.entr_val_at_enrt_flag = 'Y' and
     p_effective_date between a.effective_start_date and a.effective_end_date and
     b.pl_id = p_pl_id and p_effective_date between b.effective_start_date and b.effective_end_date;

cursor c_oipl is select 'x'  from
    ben_acty_base_rt_f  where oipl_id  = p_oipl_id  and
    rt_mlt_cd = 'CVG' and  entr_val_at_enrt_flag = 'Y' and
    p_effective_date between effective_start_date and effective_end_date  ;

cursor c_oiplip is   select 'x'  from
     ben_acty_base_rt_f a ,ben_oiplip_f b  where a.oiplip_id = b.oiplip_id and
     a.rt_mlt_cd = 'CVG' and a.entr_val_at_enrt_flag = 'Y' and
     p_effective_date between a.effective_start_date and a.effective_end_date and
     b.oipl_id = p_oipl_id and p_effective_date between b.effective_start_date and b.effective_end_date ;

begin
hr_utility.set_location('Entering:'||l_proc, 5);
if p_entr_val_at_enrt_flag = 'Y'  then
   -- decide the level - plan
   If p_pl_id is not null  then
      -- plan level check in rate
      open c_pl ;
      fetch c_pl into  l_dummy ;
      If  c_pl%notfound then
          -- plan in program level check in rate
          open c_plip ;
          fetch c_plip into l_dummy ;
          close c_plip ;
      end if ;
      close  c_pl ;
      -- whne the any row found then throw the error
      if l_dummy is not null then
         fnd_message.set_name('BEN','BEN_92653_ENTR_VAL_RATE_CVG');
         fnd_message.raise_error;
      end if;
   elsif p_oipl_id  is not null  then
      -- plan in option levele
      -- check option in plan in rate
      open c_oipl ;
      fetch c_oipl into l_dummy  ;
      If c_oipl%notfound then
         -- check  in option in plan in program in rate
         open c_oiplip ;
         fetch c_oiplip into l_dummy  ;
         close c_oiplip ;
      end if ;
      close c_oipl ;
      if l_dummy is not null  then
         fnd_message.set_name('BEN','BEN_92653_ENTR_VAL_RATE_CVG');
         fnd_message.raise_error;
      end if ;
  else
    --if any other level added
    --if any other level added
    null;
  end if ;
end if ;
hr_utility.set_location('Leaving:'||l_proc,10);
end chk_entr_at_enrt_with_rate;
--
-- ----------------------------------------------------------------------------
-- |------< chk_comp_lvl_fctr_id >------|
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
--   p_cvg_amt_calc_mthd_id PK
--   p_comp_lvl_fctr_id ID of FK column
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
Procedure chk_comp_lvl_fctr_id (p_cvg_amt_calc_mthd_id          in number,
                            p_comp_lvl_fctr_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_comp_lvl_fctr_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_comp_lvl_fctr a
    where  a.comp_lvl_fctr_id = p_comp_lvl_fctr_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_ccm_shd.api_updating
     (p_cvg_amt_calc_mthd_id            => p_cvg_amt_calc_mthd_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_comp_lvl_fctr_id,hr_api.g_number)
     <> nvl(ben_ccm_shd.g_old_rec.comp_lvl_fctr_id,hr_api.g_number)
     or not l_api_updating) and
     p_comp_lvl_fctr_id is not null then
    --
    -- check if comp_lvl_fctr_id value exists in ben_comp_lvl_fctr table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_comp_lvl_fctr
        -- table.
        --
        ben_ccm_shd.constraint_error('BEN_CVG_AMT_CALC_MTHD_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_comp_lvl_fctr_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_only_one_fk >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the form stores either the plan id
--   or the option in plan id, or the plan in program id, only one.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_id        Plan ID
--   oipl_id      Option In Plan ID
--
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
Procedure chk_only_one_fk
                   (p_pl_id      in number,
                    p_oipl_id    in number,
                    p_plip_id    in number) is
  --
  l_proc      varchar2(72) := g_package||'chk_only_one_fk';
  --
function count_them(p_id in number) return number is
  --
begin
  --
  if p_id is not null then
    --
    return 1;
    --
  else
    --
    return 0;
    --
  end if;
  --
end count_them;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if count_them(p_id => p_pl_id)+
    count_them(p_id => p_oipl_id)+
    count_them(p_id => p_plip_id) <> 1 then
    --
    -- raise error if both arguments are not null
    --
    fnd_message.set_name('BEN','BEN_92462_ONE_FK_ONLY');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_only_one_fk;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rt_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cvg_amt_calc_mthd_id PK of record being inserted or updated.
--   rt_typ_cd Value of lookup code.
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
Procedure chk_rt_typ_cd(p_cvg_amt_calc_mthd_id                in number,
                            p_rt_typ_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ccm_shd.api_updating
    (p_cvg_amt_calc_mthd_id                => p_cvg_amt_calc_mthd_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rt_typ_cd
      <> nvl(ben_ccm_shd.g_old_rec.rt_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RT_TYP',
           p_lookup_code    => p_rt_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'RT_TYP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rt_typ_cd;
--
-------------------------------------------------------------------------------
-- |------< chk_entr_val_at_enrt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cvg_amt_calc_mthd_id PK of record being inserted or updated.
--   entr_val_at_enrt_flag Value of lookup code.
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
Procedure chk_entr_val_at_enrt_flag(p_cvg_amt_calc_mthd_id  in number,
                            p_entr_val_at_enrt_flag         in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_entr_val_at_enrt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ccm_shd.api_updating
    (p_cvg_amt_calc_mthd_id        => p_cvg_amt_calc_mthd_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_entr_val_at_enrt_flag
      <> nvl(ben_ccm_shd.g_old_rec.entr_val_at_enrt_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_entr_val_at_enrt_flag,
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
end chk_entr_val_at_enrt_flag;
--
------------------------------------------------------------------------------
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
--   cvg_amt_calc_mthd_id PK of record being inserted or updated.
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
Procedure chk_dflt_flag(p_cvg_amt_calc_mthd_id         in number,
                            p_dflt_flag                in varchar2,
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
  l_api_updating := ben_ccm_shd.api_updating
    (p_cvg_amt_calc_mthd_id       => p_cvg_amt_calc_mthd_id,
     p_effective_date             => p_effective_date,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and p_dflt_flag
      <> nvl(ben_ccm_shd.g_old_rec.dflt_flag,hr_api.g_varchar2)
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
      fnd_message.set_name('BEN','BEN_91210_INVLD_DFLT_FLAG');
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
--   cvg_amt_calc_mthd_id PK of record being inserted or updated.
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
Procedure chk_cvg_mlt_cd(p_cvg_amt_calc_mthd_id                in number,
                            p_cvg_mlt_cd               in varchar2,
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
  l_api_updating := ben_ccm_shd.api_updating
    (p_cvg_amt_calc_mthd_id                => p_cvg_amt_calc_mthd_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_cvg_mlt_cd
      <> nvl(ben_ccm_shd.g_old_rec.cvg_mlt_cd,hr_api.g_varchar2)
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
      hr_utility.set_message(801,'CVG_MLT_DOES_NOT_EXIST');
      hr_utility.raise_error;
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
--   cvg_amt_calc_mthd_id PK of record being inserted or updated.
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
Procedure chk_bnft_typ_cd(p_cvg_amt_calc_mthd_id                in number,
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
  l_api_updating := ben_ccm_shd.api_updating
    (p_cvg_amt_calc_mthd_id                => p_cvg_amt_calc_mthd_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_bnft_typ_cd
      <> nvl(ben_ccm_shd.g_old_rec.bnft_typ_cd,hr_api.g_varchar2)
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
      hr_utility.set_message(801,'BNFT_TYP_DOES_NOT_EXIST');
      hr_utility.raise_error;
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
--   cvg_amt_calc_mthd_id PK of record being inserted or updated.
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
Procedure chk_bndry_perd_cd(p_cvg_amt_calc_mthd_id                in number,
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
  l_api_updating := ben_ccm_shd.api_updating
    (p_cvg_amt_calc_mthd_id                => p_cvg_amt_calc_mthd_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_bndry_perd_cd
      <> nvl(ben_ccm_shd.g_old_rec.bndry_perd_cd,hr_api.g_varchar2)
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
      hr_utility.set_message(801,'BNDRY_PD_DOES_NOT_EXIST');
      hr_utility.raise_error;
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
--   cvg_amt_calc_mthd_id PK of record being inserted or updated.
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
Procedure chk_nnmntry_uom(p_cvg_amt_calc_mthd_id                in number,
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
  l_api_updating := ben_ccm_shd.api_updating
    (p_cvg_amt_calc_mthd_id                => p_cvg_amt_calc_mthd_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_nnmntry_uom
      <> nvl(ben_ccm_shd.g_old_rec.nnmntry_uom,hr_api.g_varchar2)
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
      hr_utility.set_message(801,'NNMNTRY_UOM_DOES_NOT_EXIST');
      hr_utility.raise_error;
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
-- |------< chk_val_calc_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cvg_amt_calc_mthd_id PK of record being inserted or updated.
--   val_calc_rl Value of formula rule id.
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
Procedure chk_val_calc_rl(p_cvg_amt_calc_mthd_id                in number,
                             p_val_calc_rl              in number,
                             p_business_group_id           in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_val_calc_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_val_calc_rl
    and    ff.formula_type_id = -49
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
  l_api_updating := ben_ccm_shd.api_updating
    (p_cvg_amt_calc_mthd_id                => p_cvg_amt_calc_mthd_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_val_calc_rl,hr_api.g_number)
      <> ben_ccm_shd.g_old_rec.val_calc_rl
      or not l_api_updating)
      and p_val_calc_rl is not null then
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
        fnd_message.set_token('ID',p_val_calc_rl);
        fnd_message.set_token('TYPE_ID',-49);
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
end chk_val_calc_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_val_ovrid_alwd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cvg_amt_calc_mthd_id PK of record being inserted or updated.
--   val_ovrid_alwd_flag Value of lookup code.
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
Procedure chk_val_ovrid_alwd_flag(p_cvg_amt_calc_mthd_id                in number,
                            p_val_ovrid_alwd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_val_ovrid_alwd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ccm_shd.api_updating
    (p_cvg_amt_calc_mthd_id                => p_cvg_amt_calc_mthd_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_val_ovrid_alwd_flag
      <> nvl(ben_ccm_shd.g_old_rec.val_ovrid_alwd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_val_ovrid_alwd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'VAL_OVRD_FLG_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_val_ovrid_alwd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rndg_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cvg_amt_calc_mthd_id PK of record being inserted or updated.
--   rndg_rl Value of formula rule id.
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
Procedure chk_rndg_rl(p_cvg_amt_calc_mthd_id               in number,
                             p_rndg_rl                     in number,
                             p_business_group_id           in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rndg_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_rndg_rl
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
  l_api_updating := ben_ccm_shd.api_updating
    (p_cvg_amt_calc_mthd_id                => p_cvg_amt_calc_mthd_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rndg_rl,hr_api.g_number)
      <> ben_ccm_shd.g_old_rec.rndg_rl
      or not l_api_updating)
      and p_rndg_rl is not null then
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
        fnd_message.set_name('BEN','BEN_91042_INVALID_RNDG_RL');
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
end chk_rndg_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_lwr_lmt_calc_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cvg_amt_calc_mthd_id    PK of record being inserted or updated.
--   lwr_lmt_calc_rl         Value of formula rule id.
--   effective_date          effective date
--   object_version_number   Object version number of record being
--                           inserted or updated.
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
Procedure chk_lwr_lmt_calc_rl(p_cvg_amt_calc_mthd_id        in number,
                              p_lwr_lmt_calc_rl             in number,
                              p_business_group_id           in number,
                              p_effective_date              in date,
                              p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_lwr_lmt_calc_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_lwr_lmt_calc_rl
    and    ff.formula_type_id = -511
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
  l_api_updating := ben_ccm_shd.api_updating
    (p_cvg_amt_calc_mthd_id        => p_cvg_amt_calc_mthd_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_lwr_lmt_calc_rl,hr_api.g_number)
      <> ben_ccm_shd.g_old_rec.lwr_lmt_calc_rl
      or not l_api_updating)
      and p_lwr_lmt_calc_rl is not null then
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
        hr_utility.set_message('BEN','BEN_91815_INVALID_LWR_LMT_RL');
        hr_utility.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_lwr_lmt_calc_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_upr_lmt_calc_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cvg_amt_calc_mthd_id    PK of record being inserted or updated.
--   upr_lmt_calc_rl         Value of formula rule id.
--   effective_date          effective date
--   object_version_number   Object version number of record being
--                           inserted or updated.
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
Procedure chk_upr_lmt_calc_rl(p_cvg_amt_calc_mthd_id        in number,
                              p_upr_lmt_calc_rl             in number,
                              p_business_group_id           in number,
                              p_effective_date              in date,
                              p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_upr_lmt_calc_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_upr_lmt_calc_rl
    and    ff.formula_type_id = -514
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
  l_api_updating := ben_ccm_shd.api_updating
    (p_cvg_amt_calc_mthd_id        => p_cvg_amt_calc_mthd_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_upr_lmt_calc_rl,hr_api.g_number)
      <> ben_ccm_shd.g_old_rec.upr_lmt_calc_rl
      or not l_api_updating)
      and p_upr_lmt_calc_rl is not null then
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
        hr_utility.set_message('BEN','BEN_91823_INVALID_UPR_LMT_RL');
        hr_utility.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_upr_lmt_calc_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rndg_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cvg_amt_calc_mthd_id PK of record being inserted or updated.
--   rndg_cd Value of lookup code.
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
Procedure chk_rndg_cd(p_cvg_amt_calc_mthd_id                in number,
                            p_rndg_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rndg_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ccm_shd.api_updating
    (p_cvg_amt_calc_mthd_id                => p_cvg_amt_calc_mthd_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rndg_cd
      <> nvl(ben_ccm_shd.g_old_rec.rndg_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rndg_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RNDG',
           p_lookup_code    => p_rndg_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'RNDG_CD_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rndg_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mn_val_dfnd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cvg_amt_calc_mthd_id PK of record being inserted or updated.
--   no_mn_val_dfnd_flag Value of lookup code.
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
Procedure chk_no_mn_val_dfnd_flag(p_cvg_amt_calc_mthd_id                in number,
                            p_no_mn_val_dfnd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mn_val_dfnd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ccm_shd.api_updating
    (p_cvg_amt_calc_mthd_id                => p_cvg_amt_calc_mthd_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mn_val_dfnd_flag
      <> nvl(ben_ccm_shd.g_old_rec.no_mn_val_dfnd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mn_val_dfnd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'NO_MN_VAL_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mn_val_dfnd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mx_val_dfnd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cvg_amt_calc_mthd_id PK of record being inserted or updated.
--   no_mx_val_dfnd_flag Value of lookup code.
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
Procedure chk_no_mx_val_dfnd_flag(p_cvg_amt_calc_mthd_id                in number,
                            p_no_mx_val_dfnd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_val_dfnd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ccm_shd.api_updating
    (p_cvg_amt_calc_mthd_id                => p_cvg_amt_calc_mthd_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_val_dfnd_flag
      <> nvl(ben_ccm_shd.g_old_rec.no_mx_val_dfnd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_val_dfnd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'NO_MX_VAL_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_val_dfnd_flag;

------------------------------------------------------------------------
----
-- |------< chk_mn_mx_val >------|
--
------------------------------------------------------------------------
----
--
-- Description
--   This procedure is used to check that minimum value is always
--     less than max
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_cvg_amt_calc_mthd_id PK of record being inserted or updated.
--   min_val Value of  Minimum.
--   max_val Value of  Maximum.
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
Procedure chk_mn_mx_val( p_cvg_amt_calc_mthd_id   in number,
                         p_min_val                 in number,
                         p_max_val                 in number,
                         p_object_version_number       in number) is
  --
  l_proc   varchar2(72)  := g_package || 'chk_mn_mx_val';
  l_api_updating   boolean;
  l_dummy  varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- min_val must be < max_val,
  -- if both are used.
  --
    if p_min_val is not null and p_max_val is not null then
      --
      -- raise error if max value not greater than min value
      --
          if  (p_max_val < p_min_val)  then
                fnd_message.set_name('BEN','BEN_91069_INVALID_MIN_MAX');
     		fnd_message.raise_error;
          end if;
      --
      --
    end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mn_mx_val;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_upr_lwr_lmt_val >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if upr_lmt_val is not null then it
--   should be greater to lwr_lmt_val
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   upr_lmt_val                   Upper Limit Value.
--   lwr_lmt_val                   Lower Limit Value Rule.
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
Procedure chk_upr_lwr_lmt_val( p_upr_lmt_val                   in number,
                               p_lwr_lmt_val                   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_upr_lwr_lmt_val';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- Upper Limit Value should not be less than  Lower Limit Value
    -- mutually exclusive.
    if (p_upr_lmt_val is not null and p_lwr_lmt_val is not null) and
       (p_upr_lmt_val < p_lwr_lmt_val)
    then
      --
      fnd_message.set_name('BEN','BEN_92505_HIGH_LOW_LMT_VAL');
      fnd_message.raise_error;
      null;
      --
    end if;
end chk_upr_lwr_lmt_val;
--
--


--
-- ----------------------------------------------------------------------------
-- |------< chk_cvg_det_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cvg_amt_calc_mthd_id PK of record being inserted or updated.
--   cvg_det_cd Value of lookup code.
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
--Procedure chk_cvg_det_cd(p_cvg_amt_calc_mthd_id                in number,
--                            p_cvg_det_cd               in varchar2,
--                            p_effective_date              in date,
--                            p_object_version_number       in number) is
--
--  l_proc         varchar2(72) := g_package||'chk_cvg_det_cd';
--  l_api_updating boolean;
--
--Begin
--
--  hr_utility.set_location('Entering:'||l_proc, 5);
--
--  l_api_updating := ben_ccm_shd.api_updating
--    (p_cvg_amt_calc_mthd_id                => p_cvg_amt_calc_mthd_id,
--     p_effective_date              => p_effective_date,
--     p_object_version_number       => p_object_version_number);
--
--  if (l_api_updating
--      and p_cvg_det_cd
--      <> nvl(ben_ccm_shd.g_old_rec.cvg_det_cd,hr_api.g_varchar2)
--      or not l_api_updating)
--      and p_cvg_det_cd is not null then
--
-- check if value of lookup falls within lookup type.
--
--    if hr_api.not_exists_in_hr_lookups
--          (p_lookup_type    => 'BEN_CVG_DET',
--           p_lookup_code    => p_cvg_det_cd,
--           p_effective_date => p_effective_date) then
--
-- raise error as does not exist as lookup
--
--      hr_utility.set_message(801,'CVG_DET_DOES_NOT_EXIST');
--      hr_utility.raise_error;
--
--    end if;
--
--  end if;
--
--  hr_utility.set_location('Leaving:'||l_proc,10);
--
--end chk_cvg_det_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_oipl_id_unique >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that the Option in Plan ID is unique
--   within business_group
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_oipl_id is Option in Plan ID
--     p_cvg_amt_calc_mthd_id is cvg_amt_calc_mthd_id
--     p_effective_date is the transactions effective_date
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
Procedure chk_oipl_id_unique
          ( p_cvg_amt_calc_mthd_id in   number
           ,p_oipl_id                in   number
           ,p_effective_date       in   date
           ,p_business_group_id    in   number)
is
l_proc      varchar2(72) := g_package||'chk_oipl_id_unique';
l_dummy    char(1);
cursor c1 is select null
             from   ben_cvg_amt_calc_mthd_f
             Where  cvg_amt_calc_mthd_id <> nvl(p_cvg_amt_calc_mthd_id,-1)
             and    oipl_id = p_oipl_id
             and    business_group_id = p_business_group_id
             and    p_effective_date between effective_start_date
                    and effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into l_dummy;
  if c1%found then
      close c1;
      fnd_message.set_name('BEN','BEN_91615_OIPL_ID_NOT_UNIQUE');
      fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_oipl_id_unique;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_pl_id_unique >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that the Plan ID is unique within business_group.  Also check that
--   if plan has certain interim codes that cvg cannot be entered at enrollment.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_pl_id is Plan ID
--     p_cvg_amt_calc_mthd_id is cvg_amt_calc_mthd_id
--     p_effective_date is the transactions effective_date
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
Procedure chk_pl_id_unique
          ( p_cvg_amt_calc_mthd_id  in   number
           ,p_pl_id                 in   number
           ,p_entr_val_at_enrt_flag in varchar2
           ,p_effective_date        in   date
           ,p_business_group_id     in   number)
is
l_proc      varchar2(72) := g_package||'chk_pl_id_unique';
l_dummy    char(1);
cursor c1 is select null
             from   ben_cvg_amt_calc_mthd_f
             Where  cvg_amt_calc_mthd_id <> nvl(p_cvg_amt_calc_mthd_id,-1)
             and    pl_id = p_pl_id
             and    business_group_id = p_business_group_id
             and    p_effective_date between effective_start_date
                    and effective_end_date;

cursor c2 is select 'x'
             from   ben_pl_f pl
             Where  pl.pl_id = p_pl_id
             and    pl.dflt_to_asn_pndg_ctfn_cd like '%NL%'   -- Next Lower
             and    pl.business_group_id = p_business_group_id
             and    p_effective_date between pl.effective_start_date
                    and pl.effective_end_date;

cursor c3 is select 'x'
             from   ben_ler_bnft_rstrn_f lbr
             Where lbr.dflt_to_asn_pndg_ctfn_cd like '%NL%'
             and    lbr.pl_id = p_pl_id
             and    p_effective_date between lbr.effective_start_date
                    and lbr.effective_end_date;

cursor c4 is select 'x'
             from   ben_plip_f pip
             Where  pip.dflt_to_asn_pndg_ctfn_cd like '%NL%'
             and    pip.pl_id = p_pl_id
             and    p_effective_date between pip.effective_start_date
                    and pip.effective_end_date;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into l_dummy;
  if c1%found then
      close c1;
      fnd_message.set_name('BEN','BEN_91614_PL_ID_NOT_UNIQUE');
      fnd_message.raise_error;
  end if;
  close c1;

  -- if the coverage value is entered at enrollment, you cannot have the
  -- interim code 'next lower' - it makes no sense.
  /*ENH This will go away with the interim enhancements
  if p_entr_val_at_enrt_flag = 'Y' then
     open c2;
     fetch c2 into l_dummy;
     if c2%found then
         close c2;
         fnd_message.set_name('BEN','BEN_92553_CVG_CANNOT_ENTR');
         fnd_message.raise_error;
     end if;
     close c2;

     open c3;
     fetch c3 into l_dummy;
     if c3%found then
         close c3;
         fnd_message.set_name('BEN','BEN_92553_CVG_CANNOT_ENTR');
         fnd_message.raise_error;
     end if;
     close c3;

     open c4;
     fetch c4 into l_dummy;
     if c4%found then
         close c4;
         fnd_message.set_name('BEN','BEN_92553_CVG_CANNOT_ENTR');
         fnd_message.raise_error;
     end if;
     close c4;

  end if;
  */
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_pl_id_unique;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_plan_not_savings >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   Check that Compensation Object - Plan, to which Coverage is being attached
--   is not Savings Plan : Bug 3841981
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_pl_id				Plan ID
--     p_oipl_id			Option in Plan ID
--     p_cvg_amt_calc_mthd_id		Primary Key
--     p_validation_start_date 		Transactions Start Date
--     p_validation_end_date 		Transactions End Date
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
Procedure chk_plan_not_savings
          ( p_cvg_amt_calc_mthd_id  in   number
           ,p_pl_id                 in   number
           ,p_oipl_id               in   number
           ,p_validation_start_date in   date
           ,p_validation_end_date   in   date)
is
--
l_proc                   varchar2(72) := g_package||'.chk_plan_not_savings';
l_dummy                  varchar2(1);
l_svgs_pl_flag           ben_pl_f.svgs_pl_flag%type;
--
cursor c_pln is
             select null
             from   ben_pl_f
             Where  pl_id = p_pl_id
	     and    svgs_pl_flag = 'Y'
             and    effective_start_date <= p_validation_end_date
	     and    effective_end_date >= p_validation_start_date;

cursor c_oipl is
             select null
             from   ben_pl_f pln, ben_oipl_f oipl
             Where  oipl_id = p_oipl_id
	     and    pln.pl_id = oipl.pl_id
	     and    pln.svgs_pl_flag = 'Y'
	     and    pln.effective_start_date <= p_validation_end_date
	     and    pln.effective_end_date >= p_validation_start_date
             and    oipl.effective_start_date <= p_validation_end_date
	     and    oipl.effective_end_date >= p_validation_start_date;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_pl_id is not null
  then
    --
    open c_pln;
      fetch c_pln into l_dummy;
      if c_pln%found
      then
        --
	close c_pln;
	fnd_message.set_name('BEN', 'BEN_94035_CVG_ATTACH_SVGS_PLAN');
	fnd_message.raise_error;
	--
      end if;
    close c_pln;
    --
  end if;
  --
  if p_oipl_id is not null
  then
    --
    open c_oipl;
      fetch c_oipl into l_dummy;
      if c_oipl%found
      then
        --
	close c_oipl;
	fnd_message.set_name('BEN', 'BEN_94035_CVG_ATTACH_SVGS_PLAN');
	fnd_message.raise_error;
	--
      end if;
    close c_oipl;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
  --
End chk_plan_not_savings;
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
            (p_oipl_id                       in number default hr_api.g_number,
             p_pl_id                         in number default hr_api.g_number,
             p_plip_id                       in number default hr_api.g_number,
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
    If ((nvl(p_oipl_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_oipl_f',
             p_base_key_column => 'oipl_id',
             p_base_key_value  => p_oipl_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_oipl_f';
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
    If ((nvl(p_plip_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_plip_f',
             p_base_key_column => 'plip_id',
             p_base_key_value  => p_plip_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_plip_f';
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
            (p_cvg_amt_calc_mthd_id		in number,
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
       p_argument       => 'cvg_amt_calc_mthd_id',
       p_argument_value => p_cvg_amt_calc_mthd_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_bnft_vrbl_rt_f',
           p_base_key_column => 'cvg_amt_calc_mthd_id',
           p_base_key_value  => p_cvg_amt_calc_mthd_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_bnft_vrbl_rt_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_bnft_vrbl_rt_rl_f',
           p_base_key_column => 'cvg_amt_calc_mthd_id',
           p_base_key_value  => p_cvg_amt_calc_mthd_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_bnft_vrbl_rt_rl_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_bnft_vrbl_rt_rl_f',
           p_base_key_column => 'cvg_amt_calc_mthd_id',
           p_base_key_value  => p_cvg_amt_calc_mthd_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_bnft_vrbl_rt_rl_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_bnft_vrbl_rt_rl_f',
           p_base_key_column => 'cvg_amt_calc_mthd_id',
           p_base_key_value  => p_cvg_amt_calc_mthd_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_bnft_vrbl_rt_rl_f';
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
    --
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
-- |------< chk_mlt_cd_dependencies >------|
-- ----------------------------------------------------------------------------
--
-- Description
--
--
--
-- In Parameters
--	 cvg_mlt_cd
--	 val
--	 mn_val
--	 mx_val
--	 incrmt_val
--       dflt_val
--	 rt_typ_cd
--	 val_calc_rl
--       comp_lvl_fctr_id
--       entr_val_at_enrt_flag
--       acty_base_rt_id
--       effective_date
--       object_version_number
--
Procedure chk_mlt_cd_dependencies(p_cvg_mlt_cd                  in varchar2,
                                  p_val                         in number,
                                  p_mn_val                      in number,
                                  p_mx_val                      in number,
                                  p_incrmt_val                  in number,
                                  p_dflt_val                    in number,
                                  p_rt_typ_cd                   in varchar2,
                                  p_val_calc_rl                 in number,
                                  p_comp_lvl_fctr_id            in number,
                                  p_entr_val_at_enrt_flag       in varchar2,
                                  p_cvg_amt_calc_mthd_id        in number,
                                  p_effective_date              in date,
                                  p_object_version_number       in number
                                 ) is
  --
  l_proc  varchar2(72) := g_package||'chk_mlt_cd_dependencies';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ccm_shd.api_updating
     (p_cvg_amt_calc_mthd_id  => p_cvg_amt_calc_mthd_id,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_cvg_mlt_cd,hr_api.g_varchar2)
               <> nvl(ben_ccm_shd.g_old_rec.cvg_mlt_cd,hr_api.g_varchar2) or
          nvl(p_val,hr_api.g_number)
               <> nvl(ben_ccm_shd.g_old_rec.val,hr_api.g_number) or
          nvl(p_mn_val,hr_api.g_number)
               <> nvl(ben_ccm_shd.g_old_rec.mn_val,hr_api.g_number) or
          nvl(p_mx_val,hr_api.g_number)
               <> nvl(ben_ccm_shd.g_old_rec.mx_val,hr_api.g_number) or
          nvl(p_incrmt_val,hr_api.g_number)
               <> nvl(ben_ccm_shd.g_old_rec.incrmt_val,hr_api.g_number) or
          nvl(p_dflt_val,hr_api.g_number)
               <> nvl(ben_ccm_shd.g_old_rec.dflt_val,hr_api.g_number) or
          nvl(p_rt_typ_cd,hr_api.g_varchar2)
               <> nvl(ben_ccm_shd.g_old_rec.rt_typ_cd,hr_api.g_varchar2) or
          nvl(p_val_calc_rl,hr_api.g_number)
               <> nvl(ben_ccm_shd.g_old_rec.val_calc_rl,hr_api.g_number) or
          nvl(p_comp_lvl_fctr_id,hr_api.g_number)
               <> nvl(ben_ccm_shd.g_old_rec.comp_lvl_fctr_id,hr_api.g_number) or
          nvl(p_entr_val_at_enrt_flag,hr_api.g_varchar2)
               <> nvl(ben_ccm_shd.g_old_rec.entr_val_at_enrt_flag,hr_api.g_varchar2)
          )
      or
         not l_api_updating)
      then
	  --
          if p_entr_val_at_enrt_flag = 'N' and p_cvg_mlt_cd = 'FLFX' then
          --
              if p_mn_val is not null then
              --
              fnd_message.set_name('BEN','BEN_91539_MIN_VAL_SPEC');
              fnd_message.raise_error;
              --
              elsif p_mx_val is not null then
              --
              fnd_message.set_name('BEN','BEN_91541_MAX_VAL_SPEC');
              fnd_message.raise_error;
              --
              elsif p_incrmt_val is not null then
              --
              fnd_message.set_name('BEN','BEN_91543_INCRMT_VAL_SPEC');
              fnd_message.raise_error;
              --
              elsif p_dflt_val is not null then
              --
              fnd_message.set_name('BEN','BEN_91545_DFLT_VAL_SPEC');
              fnd_message.raise_error;
              --
              end if;
              --
          elsif p_entr_val_at_enrt_flag = 'Y' and p_cvg_mlt_cd = 'FLFX' then
              --
              if p_val is not null then
              --
              fnd_message.set_name('BEN','BEN_91537_VAL_SPEC');
              fnd_message.raise_error;
              --
              end if;
              --
          elsif p_entr_val_at_enrt_flag = 'Y' and p_cvg_mlt_cd <> 'FLFX' then
              --
              fnd_message.set_name('BEN','BEN_91941_ENTR_AT_ENRT_FLAG');
              fnd_message.raise_error;
              --
          end if;
	  if p_cvg_mlt_cd is NULL then
	  --
	      fnd_message.set_name('BEN','BEN_91535_MLT_CD_RQD');
	      fnd_message.raise_error;
	  --
	  end if;
          --
	  if p_val is NULL then
	  --
	     if p_cvg_mlt_cd in ('CL','FLFXPCL','FLPCLRNG','CLPFLRNG') then
	     --
	        fnd_message.set_name('BEN','BEN_91536_VAL_RQD');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  else
	  --
	     if p_cvg_mlt_cd in ('FLRNG','CLRNG','RL','NSVU') then
	     --
	        fnd_message.set_name('BEN','BEN_91537_VAL_SPEC');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  end if;
	  --
	  if p_mn_val is NULL then
	  --
	     if p_cvg_mlt_cd in ('FLRNG','CLRNG','FLFXPCL','FLPCLRNG','CLPFLRNG') then
		 --
	        fnd_message.set_name('BEN','BEN_91538_MIN_VAL_RQD');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  else
	  --
	     if p_cvg_mlt_cd in ('CL','RL','NSVU') then
		 --
	        fnd_message.set_name('BEN','BEN_91539_MIN_VAL_SPEC');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  end if;
	  --
	  if p_mx_val is NULL then
	  --
	     if p_cvg_mlt_cd in ('FLRNG','CLRNG','FLPCLRNG','CLPFLRNG') then
	     --
	        fnd_message.set_name('BEN','BEN_91540_MAX_VAL_RQD');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  else
	  --
	     if p_cvg_mlt_cd in ('CL','FLFXPCL','RL','NSVU') then
	     --
	        fnd_message.set_name('BEN','BEN_91541_MAX_VAL_SPEC');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  end if;
	  --
	  if p_incrmt_val is NULL then
	  --
	     if p_cvg_mlt_cd in ('FLRNG','CLRNG','FLPCLRNG','CLPFLRNG') then
		   --
	        fnd_message.set_name('BEN','BEN_91542_INCRMT_VAL_RQD');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  else
	  --
	     if p_cvg_mlt_cd in ('CL','FLFXPCL','RL','NSVU') then
		   --
	        fnd_message.set_name('BEN','BEN_91543_INCRMT_VAL_SPEC');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  end if;
	  --
	  --
	  if p_dflt_val is NULL then
	  --
	     if p_cvg_mlt_cd in ('FLRNG','CLRNG','FLPCLRNG','CLPFLRNG') then
		   --
	        fnd_message.set_name('BEN','BEN_91544_DFLT_VAL_RQD');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  else
	  --
	     if p_cvg_mlt_cd in ('CL','FLFXPCL','RL','NSVU') then
		   --
                fnd_message.set_name('BEN','BEN_91545_DFLT_VAL_SPEC');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  end if;
	  --
	  if p_rt_typ_cd is NULL then
	  --
	     if p_cvg_mlt_cd in ('CL','CLRNG','FLFXPCL','FLPCLRNG','CLPFLRNG') then
	   --
	        fnd_message.set_name('BEN','BEN_91546_RT_TYP_CD_RQD');
	        fnd_message.raise_error;
	     --
	     end if;
	  else
	  --
	     if p_cvg_mlt_cd in ('FLFX','FLRNG','RL','NSVU') then
	     --
	        fnd_message.set_name('BEN','BEN_91547_RT_TYP_CD_SPEC');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  end if;
	  --
	  if p_val_calc_rl is NULL then
	  --
	     if p_cvg_mlt_cd in ('RL') then
	     --
	        fnd_message.set_name('BEN','BEN_91548_VAL_CALC_RL_RQD');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  else
	  --
	     if p_cvg_mlt_cd in ('FLFX','FLRNG','CL','CLRNG','FLFXPCL','FLPCLRNG','CLPFLRNG','NSVU') then
		 --
	        fnd_message.set_name('BEN','BEN_91549_VAL_CALC_RL_SPEC');
	        fnd_message.raise_error;
	     --
	     end if;
	  end if;
	  -- begin bug 3191595
	  if p_dflt_val is not null and p_mn_val is not null and p_mx_val is not null then
	                if p_dflt_val < p_mn_val or p_dflt_val > p_mx_val then
	                   --
	                   fnd_message.set_name('PAY','HR_INPVAL_DEFAULT_INVALID');
	                   fnd_message.raise_error;
	                   --
	                end if;
	   end if;
	-- end bug 3191595
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mlt_cd_dependencies;
--

--Bug#5043123
-- ----------------------------------------------------------------------------
--     |------< check_rnd_cd_rl_null >------|
-- ----------------------------------------------------------------------------
--
-- Description

-- This procedure checks if the Rounding Code is selected as 'Rule'
-- then Rounding Rule has to be entered.
--
-- In Parameters

-- cvg_amt_calc_mthd_id
-- effective_date
-- object_version_number
-- rndg_cd
-- rndg_rl

--

 procedure check_rnd_cd_rl_null( p_cvg_amt_calc_mthd_id        in number,
                                 p_effective_date              in date,
                                 p_object_version_number       in number,
	                	 p_rndg_cd                     varchar2,
       			         p_rndg_rl                     varchar2
               		       ) is
  --
  l_proc         varchar2(72) := g_package||'check_rnd_cd_rl_null';
 --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_rndg_cd='RL' and p_rndg_rl is null then
         --
         fnd_message.set_name('BEN', 'BEN_91733_RNDG_RULE');
         fnd_message.raise_error;
         --
  end if;
 --
 hr_utility.set_location('Leaving:'||l_proc,10);
  --
end check_rnd_cd_rl_null;

--Bug#5043123
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in ben_ccm_shd.g_rec_type,
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
  chk_cvg_amt_calc_mthd_id
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --

  chk_comp_lvl_fctr_id
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_only_one_fk
  (p_pl_id                   => p_rec.pl_id,
   p_oipl_id                 => p_rec.oipl_id,
   p_plip_id                 => p_rec.plip_id);
  --
  chk_plan_not_savings
  ( p_cvg_amt_calc_mthd_id  => p_rec.cvg_amt_calc_mthd_id
   ,p_pl_id                 => p_rec.pl_id
   ,p_oipl_id               => p_rec.oipl_id
   ,p_validation_start_date => p_validation_start_date
   ,p_validation_end_date   => p_validation_end_date  );
  --
  chk_rt_typ_cd
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_rt_typ_cd         => p_rec.rt_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_entr_val_at_enrt_flag
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_entr_val_at_enrt_flag         => p_rec.entr_val_at_enrt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_flag
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_dflt_flag         => p_rec.dflt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
 chk_cvg_mlt_cd
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_cvg_mlt_cd         => p_rec.cvg_mlt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bnft_typ_cd
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_bnft_typ_cd         => p_rec.bnft_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bndry_perd_cd
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_bndry_perd_cd         => p_rec.bndry_perd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_nnmntry_uom
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_nnmntry_uom         => p_rec.nnmntry_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_val_calc_rl
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_val_calc_rl        => p_rec.val_calc_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_val_ovrid_alwd_flag
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_val_ovrid_alwd_flag         => p_rec.val_ovrid_alwd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_rl
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_rndg_rl        => p_rec.rndg_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_lwr_lmt_calc_rl
  (p_cvg_amt_calc_mthd_id   => p_rec.cvg_amt_calc_mthd_id,
   p_lwr_lmt_calc_rl        => p_rec.lwr_lmt_calc_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_upr_lmt_calc_rl
  (p_cvg_amt_calc_mthd_id   => p_rec.cvg_amt_calc_mthd_id,
   p_upr_lmt_calc_rl        => p_rec.upr_lmt_calc_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_rndg_cd
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_rndg_cd         => p_rec.rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mn_val_dfnd_flag
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_no_mn_val_dfnd_flag         => p_rec.no_mn_val_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_val_dfnd_flag
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_no_mx_val_dfnd_flag         => p_rec.no_mx_val_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mn_mx_val
    (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
      p_min_val            =>p_rec.mn_val,
      p_max_val            =>p_rec.mx_val,
      p_object_version_number    => p_rec.object_version_number);
    --
chk_upr_lwr_lmt_val
    (p_upr_lmt_val                   => p_rec.upr_lmt_val,
     p_lwr_lmt_val                   => p_rec.lwr_lmt_val);

  --chk_cvg_det_cd
  --(p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
  -- p_cvg_det_cd         => p_rec.cvg_det_cd,
  -- p_effective_date        => p_effective_date,
  -- p_object_version_number => p_rec.object_version_number);
  --
  chk_oipl_id_unique
  ( p_cvg_amt_calc_mthd_id  => p_rec.cvg_amt_calc_mthd_id
   ,p_oipl_id               => p_rec.oipl_id
   ,p_effective_date        => p_effective_date
   ,p_business_group_id     => p_rec.business_group_id);
  --
  chk_pl_id_unique
  ( p_cvg_amt_calc_mthd_id  => p_rec.cvg_amt_calc_mthd_id
   ,p_pl_id                 => p_rec.pl_id
   ,p_entr_val_at_enrt_flag => p_rec.entr_val_at_enrt_flag
   ,p_effective_date        => p_effective_date
   ,p_business_group_id     => p_rec.business_group_id);
  --
  chk_mlt_cd_dependencies
     (p_cvg_mlt_cd             => p_rec.cvg_mlt_cd,
      p_val                    => p_rec.val,
      p_mn_val                 => p_rec.mn_val,
      p_mx_val                 => p_rec.mx_val,
      p_incrmt_val             => p_rec.incrmt_val,
      p_dflt_val               => p_rec.dflt_val,
      p_rt_typ_cd              => p_rec.rt_typ_cd,
      p_val_calc_rl            => p_rec.val_calc_rl,
      p_comp_lvl_fctr_id       => p_rec.comp_lvl_fctr_id,
      p_entr_val_at_enrt_flag  => p_rec.entr_val_at_enrt_flag,
      p_cvg_amt_calc_mthd_id   => p_rec.cvg_amt_calc_mthd_id,
      p_effective_date         => p_effective_date,
      p_object_version_number  => p_rec.object_version_number
     );

  chk_entr_at_enrt_with_rate( p_entr_val_at_enrt_flag      => p_rec.entr_val_at_enrt_flag,
                                    p_pl_id                => p_rec.pl_id,
                                    p_oipl_id              => p_rec.oipl_id,
                                    p_effective_date       => p_effective_date ) ;

 check_rnd_cd_rl_null ( p_cvg_amt_calc_mthd_id   => p_rec.cvg_amt_calc_mthd_id
                       ,p_effective_date         => p_effective_date
                       ,p_object_version_number  => p_rec.object_version_number
                       ,p_rndg_cd                => p_rec.rndg_cd
                       ,p_rndg_rl                => p_rec.rndg_rl);

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_ccm_shd.g_rec_type,
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
  chk_cvg_amt_calc_mthd_id
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_comp_lvl_fctr_id
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_only_one_fk
  (p_pl_id                   => p_rec.pl_id,
   p_oipl_id                 => p_rec.oipl_id,
   p_plip_id                 => p_rec.plip_id);
  --
  chk_plan_not_savings
  ( p_cvg_amt_calc_mthd_id  => p_rec.cvg_amt_calc_mthd_id
   ,p_pl_id                 => p_rec.pl_id
   ,p_oipl_id               => p_rec.oipl_id
   ,p_validation_start_date => p_validation_start_date
   ,p_validation_end_date   => p_validation_end_date  );
  --
  chk_rt_typ_cd
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_rt_typ_cd         => p_rec.rt_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_entr_val_at_enrt_flag
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_entr_val_at_enrt_flag         => p_rec.entr_val_at_enrt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_flag
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_dflt_flag         => p_rec.dflt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvg_mlt_cd
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_cvg_mlt_cd         => p_rec.cvg_mlt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bnft_typ_cd
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_bnft_typ_cd         => p_rec.bnft_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bndry_perd_cd
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_bndry_perd_cd         => p_rec.bndry_perd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_nnmntry_uom
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_nnmntry_uom         => p_rec.nnmntry_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_val_calc_rl
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_val_calc_rl        => p_rec.val_calc_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_val_ovrid_alwd_flag
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_val_ovrid_alwd_flag         => p_rec.val_ovrid_alwd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_rl
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_rndg_rl        => p_rec.rndg_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_lwr_lmt_calc_rl
  (p_cvg_amt_calc_mthd_id   => p_rec.cvg_amt_calc_mthd_id,
   p_lwr_lmt_calc_rl        => p_rec.lwr_lmt_calc_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_upr_lmt_calc_rl
  (p_cvg_amt_calc_mthd_id   => p_rec.cvg_amt_calc_mthd_id,
   p_upr_lmt_calc_rl        => p_rec.upr_lmt_calc_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_rndg_cd
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_rndg_cd         => p_rec.rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mn_val_dfnd_flag
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_no_mn_val_dfnd_flag         => p_rec.no_mn_val_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_val_dfnd_flag
  (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
   p_no_mx_val_dfnd_flag         => p_rec.no_mx_val_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

 chk_mn_mx_val
    (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
      p_min_val            =>p_rec.mn_val,
      p_max_val            =>p_rec.mx_val,
      p_object_version_number    => p_rec.object_version_number);
    --
chk_upr_lwr_lmt_val
    (p_upr_lmt_val                   => p_rec.upr_lmt_val,
     p_lwr_lmt_val                   => p_rec.lwr_lmt_val);

   --
  --chk_cvg_det_cd
  --(p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
  -- p_cvg_det_cd         => p_rec.cvg_det_cd,
  -- p_effective_date        => p_effective_date,
  -- p_object_version_number => p_rec.object_version_number);
  --
  chk_oipl_id_unique
  ( p_cvg_amt_calc_mthd_id  => p_rec.cvg_amt_calc_mthd_id
   ,p_oipl_id               => p_rec.oipl_id
   ,p_effective_date        => p_effective_date
   ,p_business_group_id     => p_rec.business_group_id);
  --
  chk_pl_id_unique
  ( p_cvg_amt_calc_mthd_id  => p_rec.cvg_amt_calc_mthd_id
   ,p_pl_id                 => p_rec.pl_id
   ,p_entr_val_at_enrt_flag => p_rec.entr_val_at_enrt_flag
   ,p_effective_date        => p_effective_date
   ,p_business_group_id     => p_rec.business_group_id);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_oipl_id                       => p_rec.oipl_id,
     p_pl_id                         => p_rec.pl_id,
     p_plip_id                       => p_rec.plip_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --
  chk_mlt_cd_dependencies
     (p_cvg_mlt_cd             => p_rec.cvg_mlt_cd,
      p_val                    => p_rec.val,
      p_mn_val                 => p_rec.mn_val,
      p_mx_val                 => p_rec.mx_val,
      p_incrmt_val             => p_rec.incrmt_val,
      p_dflt_val               => p_rec.dflt_val,
      p_rt_typ_cd              => p_rec.rt_typ_cd,
      p_val_calc_rl            => p_rec.val_calc_rl,
      p_comp_lvl_fctr_id       => p_rec.comp_lvl_fctr_id,
      p_entr_val_at_enrt_flag  => p_rec.entr_val_at_enrt_flag,
      p_cvg_amt_calc_mthd_id   => p_rec.cvg_amt_calc_mthd_id,
      p_effective_date         => p_effective_date,
      p_object_version_number  => p_rec.object_version_number
     );

  chk_entr_at_enrt_with_rate( p_entr_val_at_enrt_flag      => p_rec.entr_val_at_enrt_flag,
                                    p_pl_id                => p_rec.pl_id,
                                    p_oipl_id              => p_rec.oipl_id,
                                    p_effective_date       => p_effective_date ) ;

 check_rnd_cd_rl_null ( p_cvg_amt_calc_mthd_id   => p_rec.cvg_amt_calc_mthd_id
                       ,p_effective_date         => p_effective_date
                       ,p_object_version_number  => p_rec.object_version_number
                       ,p_rndg_cd                => p_rec.rndg_cd
                       ,p_rndg_rl                => p_rec.rndg_rl);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ben_ccm_shd.g_rec_type,
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
     p_cvg_amt_calc_mthd_id		=> p_rec.cvg_amt_calc_mthd_id);
  --
  chk_pen_rows_exist
     ( p_cvg_amt_calc_mthd_id	=> p_rec.cvg_amt_calc_mthd_id,
       p_effective_date         => p_effective_date,
       p_pl_id                  => ben_ccm_shd.g_old_rec.pl_id,
       p_oipl_id                => ben_ccm_shd.g_old_rec.oipl_id,
       p_business_group_id      => ben_ccm_shd.g_old_rec.business_group_id,
       p_datetrack_mode         => p_datetrack_mode );
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
  (p_cvg_amt_calc_mthd_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_cvg_amt_calc_mthd_f b
    where b.cvg_amt_calc_mthd_id      = p_cvg_amt_calc_mthd_id
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
                             p_argument       => 'cvg_amt_calc_mthd_id',
                             p_argument_value => p_cvg_amt_calc_mthd_id);
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
end ben_ccm_bus;

/
