--------------------------------------------------------
--  DDL for Package Body BEN_ENP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENP_BUS" as
/* $Header: beenprhi.pkb 120.1.12000000.3 2007/05/13 22:36:53 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_enp_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_perd_id >------|
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
--   enrt_perd_id PK of record being inserted or updated.
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
Procedure chk_enrt_perd_id(p_enrt_perd_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_perd_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id                => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_enrt_perd_id,hr_api.g_number)
     <>  ben_enp_shd.g_old_rec.enrt_perd_id) then
    --
    -- raise error as PK has changed
    --
    ben_enp_shd.constraint_error('BEN_ENRT_PERD_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_enrt_perd_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_enp_shd.constraint_error('BEN_ENRT_PERD_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_enrt_perd_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_popl_enrt_typ_cycl_id >------|
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
--   p_enrt_perd_id PK
--   p_popl_enrt_typ_cycl_id ID of FK column
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
Procedure chk_popl_enrt_typ_cycl_id (p_enrt_perd_id          in number,
                            p_popl_enrt_typ_cycl_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_popl_enrt_typ_cycl_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_popl_enrt_typ_cycl_f a
    where  a.popl_enrt_typ_cycl_id = p_popl_enrt_typ_cycl_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_enp_shd.api_updating
     (p_enrt_perd_id            => p_enrt_perd_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_popl_enrt_typ_cycl_id,hr_api.g_number)
     <> nvl(ben_enp_shd.g_old_rec.popl_enrt_typ_cycl_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if popl_enrt_typ_cycl_id value exists in ben_popl_enrt_typ_cycl_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_popl_enrt_typ_cycl_f
        -- table.
        --
        ben_enp_shd.constraint_error('BEN_ENRT_PERD_DT1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_popl_enrt_typ_cycl_id;
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
--   p_enrt_perd_id PK
--   p_yr_perd_id ID of FK column
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
Procedure chk_yr_perd_id (p_enrt_perd_id          in number,
                            p_yr_perd_id          in number,
                            p_popl_enrt_typ_cycl_id       in number,
                            p_business_group_id           in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_yr_perd_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
 l_exists       varchar2(1);

  --
  cursor c1 is
    select null
    from   ben_yr_perd a
    where  a.yr_perd_id = p_yr_perd_id;
  --
/*
    cursor chk_unique is
     select null
        from ben_enrt_perd
        where yr_perd_id = p_yr_perd_id
          and enrt_perd_id <> nvl(p_enrt_perd_id, hr_api.g_number)
          and popl_enrt_typ_cycl_id = p_popl_enrt_typ_cycl_id
          and business_group_id + 0 = p_business_group_id;
*/
-- Commented the above cursor and its use below so as to fix the bug #2103
-- and to allow a period to be used more than once and have different
-- enrollment periods in them.
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_enp_shd.api_updating
     (p_enrt_perd_id            => p_enrt_perd_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_yr_perd_id,hr_api.g_number)
     <> nvl(ben_enp_shd.g_old_rec.yr_perd_id,hr_api.g_number)
     or not l_api_updating) then
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
        ben_enp_shd.constraint_error('BEN_ENRT_PERD_FK1');
        --
      end if;
      --
    close c1;
    --
/*
open chk_unique;
    --
    fetch chk_unique into l_exists;
    if chk_unique%found then
      close chk_unique;
      --
      -- raise error as UK1 is violated
      --
      fnd_message.set_name('PAY','VALUE IS NOT UNIQUE');
      fnd_message.raise_error;
      --
    end if;
    --
    close chk_unique;
    --
*/
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_yr_perd_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_end_dt >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that end_dt > start_dt.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--   end date
--   start date
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
Procedure chk_end_dt(p_enrt_perd_id                 in number,
                            p_strt_dt               in date,
                            p_end_dt                in date,
                            p_asnd_lf_evt_dt        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_end_dt';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'strt_dt',
                             p_argument_value => p_strt_dt);
 --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'end_dt',
                             p_argument_value => p_end_dt);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'asnd_lf_evt_dt',
                             p_argument_value => p_asnd_lf_evt_dt);

  ---
  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id                => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  -- check it if changing either start or end date.
  --
  if (l_api_updating
      and (p_strt_dt <> nvl(ben_enp_shd.g_old_rec.strt_dt,hr_api.g_date) or
           p_end_dt <> nvl(ben_enp_shd.g_old_rec.end_dt,hr_api.g_date)
           /* or p_asnd_lf_evt_Dt  <> nvl(ben_enp_shd.g_old_rec.asnd_lf_Evt_dt ,hr_api.g_date) */
           )
      or not l_api_updating)
      then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_strt_dt > p_end_dt then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_92979_INVLD_ENRT_END_DT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
 --  chek for asnd_lf_evt_dt is to be added here
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_end_dt;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_dup_asnd_lf_evt_dt >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that there is no duplicate asnd_lf_evt_dt
--   for a given popl_enrt_typ_cycl_id. This has been added as part of bug fix
--   2206551.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--   asnd_lf_evt_dt	Assigned life event date
--   popl_enrt_typ_cycl_id	Plan/Program Enrollment Type Cycle Id
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
Procedure chk_dup_asnd_lf_evt_dt(p_enrt_perd_id          in number,
                            	 p_asnd_lf_evt_dt        in date,
                           	 p_popl_enrt_typ_cycl_id in number,
                           	 p_business_group_id	 in number,
                           	 p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dup_asnd_lf_evt_dt';
  l_api_updating boolean;
  l_dummy	 char;
  --
  cursor c_dup_enp is
    select null
    from ben_enrt_perd enp
    where enp.popl_enrt_typ_cycl_id = p_popl_enrt_typ_cycl_id
      and enp.enrt_perd_id <> nvl(p_enrt_perd_id, hr_api.g_number)
      and enp.asnd_lf_evt_dt = p_asnd_lf_evt_dt
      and enp.business_group_id = p_business_group_id ;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'asnd_lf_evt_dt',
                             p_argument_value => p_asnd_lf_evt_dt);

  ---
  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id                => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  -- check it if changing assigned life event date.
  --
  if (l_api_updating
      and (p_asnd_lf_evt_dt <> nvl(ben_enp_shd.g_old_rec.asnd_lf_evt_dt,hr_api.g_date) )
      or not l_api_updating)
      then
    --
    -- check if there is another enrollment period record with same assigned life event date
    --
    open c_dup_enp ;
    fetch c_dup_enp into l_dummy ;
    if c_dup_enp%found then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_93231_DUP_ASND_LF_EVT_DT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
 --  chek for asnd_lf_evt_dt is to be added here
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dup_asnd_lf_evt_dt;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_enrt_dt >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that dflt_enrt_dt > end_dt.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--   end date
--   default enrollment date
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
Procedure chk_dflt_enrt_dt(p_enrt_perd_id                in number,
                            p_dflt_enrt_dt               in date,
                            p_end_dt                 in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_enrt_dt';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
/*  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'dflt_enrt_dt',
                             p_argument_value => p_dflt_enrt_dt);
*/
 --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'end_dt',
                             p_argument_value => p_end_dt);
  --
  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id                => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  -- check it if changing either default enrollment date or end date.
  --
  if (l_api_updating
      and (p_dflt_enrt_dt <> nvl(ben_enp_shd.g_old_rec.dflt_enrt_dt,hr_api.g_date) or
           p_end_dt <> nvl(ben_enp_shd.g_old_rec.end_dt,hr_api.g_date)
           )
      or not l_api_updating)
      then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_end_dt > p_dflt_enrt_dt then
      --
      -- raise error
      --
      fnd_message.set_name('PAY','end date > dflt enrt date');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_enrt_dt;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rt_end_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--   rt_end_dt_rl Value of formula rule id.
--   effective_date effective date
--   object_version_number Object version number of record being
--                                      inserted or updated.
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
Procedure chk_rt_end_dt_rl(p_enrt_perd_id                in number,
                             p_rt_end_dt_rl              in number,
                             p_business_group_id         in number,
                             p_effective_date            in date,
                             p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_end_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_rt_end_dt_rl
    and    ff.formula_type_id = -67 /*default enrollment det */
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
  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id                => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rt_end_dt_rl,hr_api.g_number)
      <> ben_enp_shd.g_old_rec.rt_end_dt_rl
      or not l_api_updating)
      and p_rt_end_dt_rl is not null then
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
        fnd_message.set_token('ID',p_rt_end_dt_rl);
        fnd_message.set_token('TYPE_ID',-67);
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
end chk_rt_end_dt_rl;
-- ----------------------------------------------------------------------------
-- |------< chk_rt_end_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--   rt_end_dt_cd Value of lookup code.
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
Procedure chk_rt_end_dt_cd(p_enrt_perd_id                in number,
                            p_rt_end_dt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_end_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id                => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rt_end_dt_cd
      <> nvl(ben_enp_shd.g_old_rec.rt_end_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_end_dt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RT_END',
           p_lookup_code    => p_rt_end_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_rt_end_dt_cd');
      fnd_message.set_token('VALUE', p_rt_end_dt_cd);
      fnd_message.set_token('TYPE', 'BEN_RT_END');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rt_end_dt_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_reinstate_ovrdn_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--   reinstate_ovrdn_cd Value of lookup code.
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
Procedure chk_reinstate_ovrdn_cd(p_enrt_perd_id                in number,
                            p_reinstate_ovrdn_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_reinstate_ovrdn_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
 l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id                => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_reinstate_ovrdn_cd
      <> nvl(ben_enp_shd.g_old_rec.reinstate_ovrdn_cd,hr_api.g_varchar2)
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
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_reinstate_ovrdn_cd');
      fnd_message.set_token('VALUE', p_reinstate_ovrdn_cd);
      fnd_message.set_token('TYPE', 'BEN_REINSTATE_OVRDN');
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
-- |------< chk_reinstate_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--   reinstate_cd Value of lookup code.
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
Procedure chk_reinstate_cd(p_enrt_perd_id                in number,
                            p_reinstate_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_reinstate_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
 l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id                => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_reinstate_cd
      <> nvl(ben_enp_shd.g_old_rec.reinstate_cd,hr_api.g_varchar2)
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
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_reinstate_cd');
      fnd_message.set_token('VALUE', p_reinstate_cd);
      fnd_message.set_token('TYPE', 'BEN_REINSTATE');
      fnd_message.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_reinstate_cd;

--

-- ----------------------------------------------------------------------------
-- |------< chk_rt_strt_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--   rt_strt_dt_cd Value of lookup code.
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
Procedure chk_rt_strt_dt_cd(p_enrt_perd_id                in number,
                            p_rt_strt_dt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_strt_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id                => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rt_strt_dt_cd
      <> nvl(ben_enp_shd.g_old_rec.rt_strt_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_strt_dt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RT_STRT',
           p_lookup_code    => p_rt_strt_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rt_strt_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_cvg_end_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--   enrt_cvg_end_dt_rl Value of formula rule id.
--   effective_date effective date
--   object_version_number Object version number of record being
--                                      inserted or updated.
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
Procedure chk_enrt_cvg_end_dt_rl(p_enrt_perd_id            in number,
                             p_enrt_cvg_end_dt_rl          in number,
                             p_business_group_id           in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cvg_end_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_enrt_cvg_end_dt_rl
    and    ff.formula_type_id = -30 /*default enrollment det */
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
  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id                => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_enrt_cvg_end_dt_rl,hr_api.g_number)
      <> ben_enp_shd.g_old_rec.enrt_cvg_end_dt_rl
      or not l_api_updating)
      and p_enrt_cvg_end_dt_rl is not null then
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
        fnd_message.set_token('ID',p_enrt_cvg_end_dt_rl);
        fnd_message.set_token('TYPE_ID',-30);
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
end chk_enrt_cvg_end_dt_rl;
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
--   enrt_perd_id PK of record being inserted or updated.
--   enrt_cvg_strt_dt_rl Value of formula rule id.
--   effective_date effective date
--   object_version_number Object version number of record being
--                                      inserted or updated.
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
Procedure chk_enrt_cvg_strt_dt_rl(p_enrt_perd_id           in number,
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
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_enrt_cvg_strt_dt_rl
    and    ff.formula_type_id = -29 /*default enrollment det */
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
  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id                => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_enrt_cvg_strt_dt_rl,hr_api.g_number)
      <> ben_enp_shd.g_old_rec.enrt_cvg_strt_dt_rl
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
-- |------< chk_enrt_cvg_end_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--   enrt_cvg_end_dt_cd Value of lookup code.
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
Procedure chk_enrt_cvg_end_dt_cd(p_enrt_perd_id                in number,
                            p_enrt_cvg_end_dt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cvg_end_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id                => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_cvg_end_dt_cd
      <> nvl(ben_enp_shd.g_old_rec.enrt_cvg_end_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enrt_cvg_end_dt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT_CVG_END',
           p_lookup_code    => p_enrt_cvg_end_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_cvg_end_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rt_strt_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--   rt_strt_dt_rl Value of formula rule id.
--   effective_date effective date
--   object_version_number Object version number of record being
--                                      inserted or updated.
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
Procedure chk_rt_strt_dt_rl(p_enrt_perd_id                in number,
                             p_rt_strt_dt_rl              in number,
                             p_effective_date              in date,
                             p_business_group_id           in number,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_strt_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_rt_strt_dt_rl
    and    ff.formula_type_id = -66
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
  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id                => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rt_strt_dt_rl,hr_api.g_number)
      <> ben_enp_shd.g_old_rec.rt_strt_dt_rl
      or not l_api_updating)
      and p_rt_strt_dt_rl is not null then
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
        fnd_message.set_token('ID',p_rt_strt_dt_rl);
        fnd_message.set_token('TYPE_ID',-66);
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
end chk_rt_strt_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_cvg_strt_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--   enrt_cvg_strt_dt_cd Value of lookup code.
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
Procedure chk_enrt_cvg_strt_dt_cd(p_enrt_perd_id                in number,
                            p_enrt_cvg_strt_dt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cvg_strt_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id                => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_cvg_strt_dt_cd
      <> nvl(ben_enp_shd.g_old_rec.enrt_cvg_strt_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enrt_cvg_strt_dt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT_CVG_STRT',
           p_lookup_code    => p_enrt_cvg_strt_dt_cd,
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
end chk_enrt_cvg_strt_dt_cd;
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
--   enrt_perd_id PK of record being inserted or updated.
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
Procedure chk_cls_enrt_dt_to_use_cd(p_enrt_perd_id                in number,
                            p_cls_enrt_dt_to_use_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cls_enrt_dt_to_use_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id                => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_cls_enrt_dt_to_use_cd
      <> nvl(ben_enp_shd.g_old_rec.cls_enrt_dt_to_use_cd,hr_api.g_varchar2)
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
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
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
-- |------< chk_enrl_strt_dt_dpndcy >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the code/rule dependency as following:
--             If code = 'Rule' then rule must be selected.
--             If code <> 'Rule' then code must not be selected.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--   enrt_cvg_strt_dt_cd Value of lookup code.
--   enrt_cvg_strt_dt_rl
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
Procedure chk_enrl_strt_dt_dpndcy
                           (p_enrt_perd_id          in number,
                            p_enrt_cvg_strt_dt_cd   in varchar2,
                            p_enrt_cvg_strt_dt_rl   in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrl_strt_dt_dpndcy ';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id      => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and (nvl(p_enrt_cvg_strt_dt_cd,hr_api.g_varchar2)
         <> nvl(ben_enp_shd.g_old_rec.enrt_cvg_strt_dt_cd,hr_api.g_varchar2) or
          nvl(p_enrt_cvg_strt_dt_rl,hr_api.g_number)
        <> nvl(ben_enp_shd.g_old_rec.enrt_cvg_strt_dt_rl,hr_api.g_number))
      or not l_api_updating) then
    --
    if (p_enrt_cvg_strt_dt_cd = 'RL' and p_enrt_cvg_strt_dt_rl is null) then
             --
          fnd_message.set_name('BEN','BEN_91310_ENRT_STRT_CWOR');
          fnd_message.raise_error;
             --
    end if;
    --
    if nvl(p_enrt_cvg_strt_dt_cd,hr_api.g_varchar2) <> 'RL'
       and p_enrt_cvg_strt_dt_rl is not null then
             --
          fnd_message.set_name('BEN','BEN_91311_ENRT_STRT_RWOC');
          fnd_message.raise_error;
             --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrl_strt_dt_dpndcy;
--

-- ----------------------------------------------------------------------------
-- |------< chk_cwb_validations >------|
-- ----------------------------------------------------------------------------

Procedure  chk_cwb_validations
                           (p_enrt_perd_id         in number,
                            p_data_freeze_date     in  date    ,
                            p_Sal_chg_reason_cd    in  varchar2,
                            p_Approval_mode_cd     in  varchar2,
                            p_hrchy_ame_trn_cd     in  varchar2,
                            p_hrchy_rl             in  number,
                            p_hrchy_ame_app_id     in  number,
                            p_hrchy_to_use_cd      in   varchar2,
                            p_effective_date       in date ,
                            p_pos_structure_version_id in number,
                            p_object_version_number    in number
                           ) is
  --
  l_proc         varchar2(72) := g_package||'chk_cwb_validations ';
  l_api_updating boolean;

  cursor c_hrchy_ame  is
  select   'x'
  from ame_transaction_types_v ame
  where  ame.transaction_type_id = p_hrchy_ame_trn_cd
    and  ame.fnd_application_id  = p_hrchy_ame_app_id ;
--    and  p_effective_date  between
--          ame.start_date and nvl(ame.end_date, p_effective_date)



  cursor c_hrchy_rl is
    select 'x'
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_hrchy_rl
    and    ff.formula_type_id = -550 /*default enrollment det */
    and    nvl(ff.legislation_code, pbg.legislation_code) =  pbg.legislation_code
    and    p_effective_date between ff.effective_start_date and ff.effective_end_date;


  l_dummy varchar2(1) ;
  --
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id      => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);


  if (l_api_updating
      and
         (   nvl(p_Sal_chg_reason_cd,hr_api.g_varchar2)
             <> nvl(ben_enp_shd.g_old_rec.Sal_chg_reason_cd,hr_api.g_varchar2)
         )
      or not l_api_updating)
      and p_Sal_chg_reason_cd is not null then

      hr_utility.set_location('validating SAl_CHG_REASON:'||p_Sal_chg_reason_cd, 5);
      if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PROPOSAL_REASON',
           p_lookup_code    => p_Sal_chg_reason_cd,
           p_effective_date => p_effective_date) then
           --
           -- raise error as does not exist as lookup
           --
           hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
           hr_utility.raise_error;
           --
      end if;

   end if ;

   if (l_api_updating
      and (
           nvl( p_Approval_mode_cd,hr_api.g_varchar2) <>
           nvl(ben_enp_shd.g_old_rec.Approval_mode_cd,hr_api.g_varchar2)
         )
      or not l_api_updating)
       and p_Approval_mode_cd is not null  then

      hr_utility.set_location('validating Approval_mode_cd:'||p_Approval_mode_cd, 5);
      if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_CWB_APPROVAL_MODE',
           p_lookup_code    =>  p_Approval_mode_cd,
           p_effective_date => p_effective_date) then
           --
           -- raise error as does not exist as lookup
           --
           hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
           hr_utility.raise_error;
           --
      end if;

  end if ;



  if (l_api_updating
      and
         (   nvl( p_hrchy_ame_trn_cd,hr_api.g_varchar2) <>
              nvl(ben_enp_shd.g_old_rec.hrchy_ame_trn_cd,hr_api.g_varchar2)
          or nvl(p_hrchy_ame_app_id,hr_api.g_number) <>
             nvl(ben_enp_shd.g_old_rec.hrchy_ame_app_id,hr_api.g_number)
	  --Bug 4083891 : Perform validation for change in Assingned Life Event Date also
          or nvl(p_effective_date,hr_api.g_date) <>
             nvl(ben_enp_shd.g_old_rec.asnd_lf_evt_dt,hr_api.g_date)
         )
      or not l_api_updating)
      and p_hrchy_ame_trn_cd is not null then

     hr_utility.set_location('validating hrchy_ame_trn_cd:'||p_hrchy_ame_trn_cd, 5);
     open  c_hrchy_ame ;
     fetch c_hrchy_ame into l_dummy ;
     if  c_hrchy_ame%notfound then
         close  c_hrchy_ame ;
          hr_utility.set_location('validating hrchy_ame_trn_cd:'||p_hrchy_ame_trn_cd, 7);
          fnd_message.set_name('BEN','BEN_93730_CW_HRCHY_AME_ERR');
	  --Bug 4083891 : Passed Assigned Life Event Date parameter to the modified message
          fnd_message.set_token('ALED',fnd_date.date_to_displaydate(p_effective_date));
          fnd_message.raise_error;

     end if ;
     close   c_hrchy_ame ;

     hr_utility.set_location('out validating hrchy_ame_trn_cd:'||p_hrchy_ame_trn_cd, 5);
  end if ;


  if (l_api_updating
      and
         (   nvl( p_hrchy_rl,hr_api.g_number) <>
             nvl(ben_enp_shd.g_old_rec.hrchy_rl,hr_api.g_number)
         )
      or not l_api_updating)
      and p_hrchy_rl is not null  then

     hr_utility.set_location('validating hrchy_rl:'||p_hrchy_rl, 5);
      open c_hrchy_rl ;
      fetch c_hrchy_rl into l_dummy;
      if c_hrchy_rl%notfound then
        --
        close c_hrchy_rl;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
        fnd_message.set_token('ID',p_hrchy_rl);
        fnd_message.set_token('TYPE_ID',-549);
        fnd_message.raise_error;
        --
      end if;
      close c_hrchy_rl;
      --
  end if ;


  if (l_api_updating
      and
         (   nvl( p_hrchy_to_use_cd,hr_api.g_varchar2) <>
              nvl(ben_enp_shd.g_old_rec.hrchy_to_use_cd,hr_api.g_varchar2)
         )
      or not l_api_updating) then
      hr_utility.set_location('validating hrchy_to_use_cd:'||p_hrchy_to_use_cd, 5);
      if p_hrchy_to_use_cd is not null then
         if hr_api.not_exists_in_hr_lookups
             (p_lookup_type    => 'BEN_HRCHY_TO_USE',
              p_lookup_code    => p_hrchy_to_use_cd,
              p_effective_date => p_effective_date) then
              --
              -- raise error as does not exist as lookup
              --
              hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
              hr_utility.raise_error;
              --
         end if;
      end if ;
   end if ;
  --
  -- Bug 4498668 Moved out the checks out of if condition
  --
      hr_utility.set_location(' p_hrchy_to_use_cd ' || p_hrchy_to_use_cd, 99);
      hr_utility.set_location(' p_hrchy_ame_trn_cd ' || p_hrchy_ame_trn_cd, 99);

      if (p_hrchy_to_use_cd = 'RL' and p_hrchy_rl is null)
         or ( nvl(p_hrchy_to_use_cd,hr_api.g_varchar2) <> 'RL'
            and  p_hrchy_rl is not null ) then
             --
          fnd_message.set_name('BEN','BEN_93731_CWB_HRCHY_CWOR_RWOC');
          fnd_message.raise_error;
             --
      end if;
      --

      if (p_hrchy_to_use_cd = 'AME' and p_hrchy_ame_trn_cd  is null)
         or ( nvl(p_hrchy_to_use_cd,hr_api.g_varchar2) <> 'AME' and   p_hrchy_ame_trn_cd is not null ) then
             --
          fnd_message.set_name('BEN','BEN_93732_CWB_HRCHY_AME_CWOC');
          fnd_message.raise_error;
             --
      end if;


      if (p_hrchy_to_use_cd = 'P' and p_pos_structure_version_id  is null)
         or ( nvl(p_hrchy_to_use_cd,hr_api.g_varchar2) <> 'P'
            and   p_pos_structure_version_id is not null ) then
             --
          fnd_message.set_name('BEN','BEN_93733_CWB_HRCHY_AME_CWOC');
          fnd_message.raise_error;
             --
      end if;
  --
   hr_utility.set_location('Leaving:'||l_proc,10);
end  chk_cwb_validations ;


-- ----------------------------------------------------------------------------
-- |------< chk_enrl_end_dt_dpndcy >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the code/rule dependency as following:
--             If code = 'Rule' then rule must be selected.
--             If code <> 'Rule' then code must not be selected.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--   enrt_cvg_end_dt_cd Value of lookup code.
--   enrt_cvg_end_dt_rl
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
Procedure chk_enrl_end_dt_dpndcy
                           (p_enrt_perd_id         in number,
                            p_enrt_cvg_end_dt_cd   in varchar2,
                            p_enrt_cvg_end_dt_rl   in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrl_end_dt_dpndcy ';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id      => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_enrt_cvg_end_dt_cd,hr_api.g_varchar2)
     <> nvl(ben_enp_shd.g_old_rec.enrt_cvg_end_dt_cd,hr_api.g_varchar2) or
          nvl(p_enrt_cvg_end_dt_rl,hr_api.g_number)
          <> nvl(ben_enp_shd.g_old_rec.enrt_cvg_end_dt_rl,hr_api.g_number))
      or not l_api_updating) then
    --
    if (p_enrt_cvg_end_dt_cd = 'RL' and p_enrt_cvg_end_dt_rl is null) then
             --
          fnd_message.set_name('BEN','BEN_91378_DFLT_DENRL_END_DT1');
          fnd_message.raise_error;
  --
    end if;
    --
    if nvl(p_enrt_cvg_end_dt_cd,hr_api.g_varchar2) <> 'RL'
       and p_enrt_cvg_end_dt_rl is not null then
             --
          fnd_message.set_name('BEN','BEN_91379_DFLT_DENRL_END_DT2');
          fnd_message.raise_error;
             --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrl_end_dt_dpndcy;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rt_strt_dt_dpndcy >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the code/rule dependency as following:
--             If code = 'Rule' then rule must be selected.
--             If code <> 'Rule' then code must not be selected.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--   rt_strt_dt_cd Value of lookup code.
--   rt_strt_dt_rl
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
Procedure chk_rt_strt_dt_dpndcy
                           (p_enrt_perd_id          in number,
                            p_rt_strt_dt_cd   in varchar2,
                            p_rt_strt_dt_rl   in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_strt_dt_dpndcy ';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id      => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and (nvl(p_rt_strt_dt_cd,hr_api.g_varchar2)
         <> nvl(ben_enp_shd.g_old_rec.rt_strt_dt_cd,hr_api.g_varchar2) or
          nvl(p_rt_strt_dt_rl,hr_api.g_number)
        <> nvl(ben_enp_shd.g_old_rec.rt_strt_dt_rl,hr_api.g_number))
      or not l_api_updating) then
    --
    if (p_rt_strt_dt_cd = 'RL' and p_rt_strt_dt_rl is null) then
             --
          fnd_message.set_name('BEN','BEN_91623_CD_RL_1');
          fnd_message.raise_error;
             --
    end if;
    --
    if nvl(p_rt_strt_dt_cd,hr_api.g_varchar2) <> 'RL'
       and p_rt_strt_dt_rl is not null then
             --
          fnd_message.set_name('BEN','BEN_91624_CD_RL_2');
          fnd_message.raise_error;
             --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rt_strt_dt_dpndcy;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rt_end_dt_dpndcy >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the code/rule dependency as following:
--             If code = 'Rule' then rule must be selected.
--             If code <> 'Rule' then code must not be selected.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--   rt_end_dt_cd Value of lookup code.
--   rt_end_dt_rl
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
Procedure chk_rt_end_dt_dpndcy
                           (p_enrt_perd_id         in number,
                            p_rt_end_dt_cd   in varchar2,
                            p_rt_end_dt_rl   in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_end_dt_dpndcy ';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id      => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_rt_end_dt_cd,hr_api.g_varchar2)
     <> nvl(ben_enp_shd.g_old_rec.rt_end_dt_cd,hr_api.g_varchar2) or
          nvl(p_rt_end_dt_rl,hr_api.g_number)
          <> nvl(ben_enp_shd.g_old_rec.rt_end_dt_rl,hr_api.g_number))
      or not l_api_updating) then
    --
    if (p_rt_end_dt_cd = 'RL' and p_rt_end_dt_rl is null) then
             --
          fnd_message.set_name('BEN','BEN_91623_CD_RL_1');
          fnd_message.raise_error;
  --
    end if;
    --
    if nvl(p_rt_end_dt_cd,hr_api.g_varchar2) <> 'RL'
       and p_rt_end_dt_rl is not null then
             --
          fnd_message.set_name('BEN','BEN_91624_CD_RL_2');
          fnd_message.raise_error;
             --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rt_end_dt_dpndcy;
--
-- ----------------------------------------------------------------------------
-- |------< chk_bdgt_upd_end_dt>------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that bdgt_upd_end_dt > bdgt_upd_strt_dt.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--   budget update start date
--   budget update end date
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
Procedure chk_bdgt_upd_end_dt(p_enrt_perd_id          in number,
                              p_bdgt_upd_strt_dt      in date,
                              p_bdgt_upd_end_dt       in date,
                              p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bdgt_upd_end_dt';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id                => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  -- check it if changing either start or end date.
  --
  if (p_bdgt_upd_strt_dt is not null and p_bdgt_upd_end_dt is not null)
      and
     ((l_api_updating
       and (p_bdgt_upd_strt_dt <> nvl(ben_enp_shd.g_old_rec.bdgt_upd_strt_dt,hr_api.g_date) or
            p_bdgt_upd_end_dt <> nvl(ben_enp_shd.g_old_rec.bdgt_upd_end_dt,hr_api.g_date)
            )
       )
       or not l_api_updating)
       then
    --
    -- check if start date greater than end date.
    --
    if p_bdgt_upd_strt_dt > p_bdgt_upd_end_dt then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_92975_INVLD_BGT_UPD_END_DT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;

  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_bdgt_upd_end_dt;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ws_upd_end_dt>------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that ws_upd_end_dt > ws_upd_strt_dt.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--   worksheet start date
--   worksheet end date
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
Procedure chk_ws_upd_end_dt(p_enrt_perd_id          in number,
                            p_ws_upd_strt_dt        in date,
                            p_ws_upd_end_dt         in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ws_upd_end_dt';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id                => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  -- check it if changing either start or end date.
  --
  if (p_ws_upd_strt_dt is not null and p_ws_upd_end_dt is not null)
     and
     ((l_api_updating
       and (p_ws_upd_strt_dt <> nvl(ben_enp_shd.g_old_rec.ws_upd_strt_dt,hr_api.g_date) or
           p_ws_upd_end_dt <> nvl(ben_enp_shd.g_old_rec.ws_upd_end_dt,hr_api.g_date)
           )
       )
      or not l_api_updating)
      then
    --
    -- check if start date greater than end date
    --
    if p_ws_upd_strt_dt > p_ws_upd_end_dt then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_92976_INVLD_WS_UPD_END_DT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;

  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_ws_upd_end_dt;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_bdgt_upd_period>------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Budget Update period falls within
--   the Enrollment or Availability period.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--   enrollment start date
--   enrollment end date
--   budget update start date
--   budget update end date
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
Procedure chk_bdgt_upd_period(p_enrt_perd_id          in number,
		   	      p_strt_dt               in date,
                              p_end_dt                in date,
                              p_bdgt_upd_strt_dt      in date,
                              p_bdgt_upd_end_dt       in date,
                              p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bdgt_upd_period';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'strt_dt',
                             p_argument_value => p_strt_dt);
 --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'end_dt',
                             p_argument_value => p_end_dt);
  --

  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id                => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  -- check it if changing either start or end date.
  --
  if (l_api_updating
      and (nvl(p_bdgt_upd_strt_dt,hr_api.g_date) <> nvl(ben_enp_shd.g_old_rec.bdgt_upd_strt_dt,hr_api.g_date) or
           nvl(p_bdgt_upd_end_dt,hr_api.g_date) <> nvl(ben_enp_shd.g_old_rec.bdgt_upd_end_dt,hr_api.g_date) or
           p_strt_dt <> nvl(ben_enp_shd.g_old_rec.strt_dt,hr_api.g_date) or
           p_end_dt <> nvl(ben_enp_shd.g_old_rec.end_dt,hr_api.g_date)
           )
      or not l_api_updating)
      then
    --
    -- check if budget update period falls within enrollment or availability period
    --
    if (p_bdgt_upd_strt_dt is not null) and
        not (p_bdgt_upd_strt_dt between p_strt_dt and p_end_dt) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_92977_INVLD_BDGT_UPD_PERD');
      fnd_message.raise_error;
      --
    elsif (p_bdgt_upd_end_dt is not null) and
        not (p_bdgt_upd_end_dt between p_strt_dt and p_end_dt) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_92977_INVLD_BDGT_UPD_PERD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;

  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_bdgt_upd_period;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_ws_upd_period>------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Worksheet Update period falls within
--   the Enrollment or Availability period.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--   enrollment start date
--   enrollment end date
--   worksheet update start date
--   worksheet update end date
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
Procedure chk_ws_upd_period(p_enrt_perd_id          in number,
			    p_strt_dt               in date,
                            p_end_dt                in date,
                            p_ws_upd_strt_dt        in date,
                            p_ws_upd_end_dt         in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ws_upd_period';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'strt_dt',
                             p_argument_value => p_strt_dt);
 --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'end_dt',
                             p_argument_value => p_end_dt);
  --

  l_api_updating := ben_enp_shd.api_updating
    (p_enrt_perd_id                => p_enrt_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  -- check it if changing either start or end date.
  --
  if (l_api_updating
      and (nvl(p_ws_upd_strt_dt,hr_api.g_date) <> nvl(ben_enp_shd.g_old_rec.ws_upd_strt_dt,hr_api.g_date) or
           nvl(p_ws_upd_end_dt,hr_api.g_date) <> nvl(ben_enp_shd.g_old_rec.ws_upd_end_dt,hr_api.g_date)or
           p_strt_dt <> nvl(ben_enp_shd.g_old_rec.strt_dt,hr_api.g_date) or
           p_end_dt <> nvl(ben_enp_shd.g_old_rec.end_dt,hr_api.g_date)
           )
      or not l_api_updating)
      then
    --
    -- check if worksheet update period falls within enrollment or availability period
    --
    if (p_ws_upd_strt_dt is not null) and
        not (p_ws_upd_strt_dt between p_strt_dt and p_end_dt) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_92978_INVLD_WS_UPD_PERD');
      fnd_message.raise_error;
      --
    elsif (p_ws_upd_end_dt is not null) and
        not (p_ws_upd_end_dt between p_strt_dt and p_end_dt) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_92978_INVLD_WS_UPD_PERD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;

  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_ws_upd_period;
--
--
---- ----------------------------------------------------------------------------
-- |----------------------< chk_defer_flag_set_pln_plip >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if defer_deenrol_flag can be set for PNIP
--   or if the Plan is in Program then can't be set at Plan Level.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--
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
 procedure chk_defer_flag_set_pln_plip
			(p_enrt_perd_id		  in number
			,p_popl_enrt_typ_cycl_id  in number
 		        ,p_object_version_number  in number
			,p_effective_date	  in date
			,p_defer_deenrol_flag     in varchar2
			,p_business_group_id      in number
			) is
  --
  cursor c_pl_cd is
     select pln.pl_cd
     from   ben_pl_f pln
  	   ,ben_popl_enrt_typ_cycl_f pet
 	   ,ben_enrt_perd enp
    where   pet.popl_enrt_typ_cycl_id =  p_popl_enrt_typ_cycl_id
     and    pet.pl_id = pln.pl_id
     and    pln.business_group_id = p_business_group_id
     and    pet.business_group_id = pln.business_group_id
     and    p_effective_date between pln.effective_start_date and pln.effective_end_date
     and    p_effective_date between pet.effective_start_date and pet.effective_end_date;
  --
   l_pl_cd  ben_pl_f.pl_cd%TYPE;
   l_api_updating boolean;
   l_proc         varchar2(72) := g_package||'chk_defer_flag_set_pln_plip';
  --
  begin
   --
   hr_utility.set_location('Entering:'|| l_proc, 9653);
   --
  l_api_updating := ben_enp_shd.api_updating
     (p_enrt_perd_id		    => p_enrt_perd_id,
      p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_defer_deenrol_flag <> nvl(ben_enp_shd.g_old_rec.defer_deenrol_flag,hr_api.g_number)
      or not l_api_updating) and p_defer_deenrol_flag is not null then
    --
      open c_pl_cd;
       fetch c_pl_cd into l_pl_cd;
      close c_pl_cd;
    --
   if l_pl_cd = 'MSTBPGM' then
    --
     if p_defer_deenrol_flag = 'Y' then
     --
      fnd_message.set_name('BEN','BEN_94880_DEFER_FLAG_VALID_LVL');
      fnd_message.raise_error;
     --
     end if;
   --
   end if;
   --
  end if;
   hr_utility.set_location('Leaving:'|| l_proc, 9653);
   --
  end chk_defer_flag_set_pln_plip;
  --

--
---- ----------------------------------------------------------------------------
-- |----------------------< chk_defer_flag_lookup >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the flag lookup value is valid.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--
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
 procedure chk_defer_flag_lookup
			(p_enrt_perd_id		  in number
			,p_effective_date	  in date
			,p_defer_deenrol_flag     in varchar2
			,p_object_version_number  in number
			) is
  --
   l_api_updating boolean;
   l_proc         varchar2(72) := g_package||'chk_defer_flag_lookup';
  --
  begin
   --
   hr_utility.set_location('Entering:'|| l_proc, 9653);
   --
  l_api_updating := ben_enp_shd.api_updating
     (p_enrt_perd_id		    => p_enrt_perd_id,
      p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_defer_deenrol_flag <> nvl(ben_enp_shd.g_old_rec.defer_deenrol_flag,hr_api.g_varchar2)
       or not l_api_updating)
       and p_defer_deenrol_flag is not null then
    --
      if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_defer_deenrol_flag,
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
   hr_utility.set_location('Leaving:'|| l_proc, 9653);
   --
  end chk_defer_flag_lookup;
  --
--
-- ----------------------------------------------------------------------------
--  |-----------------------< insert_validate >-------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_enp_shd.g_rec_type
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
  chk_enrt_perd_id
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_yr_perd_id
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_yr_perd_id          => p_rec.yr_perd_id,
   p_popl_enrt_typ_cycl_id => p_rec.popl_enrt_typ_cycl_id,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_end_dt_rl
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_rt_end_dt_rl          => p_rec.rt_end_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_end_dt_cd
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_rt_end_dt_cd         => p_rec.rt_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_strt_dt_cd
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_rt_strt_dt_cd         => p_rec.rt_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_end_dt_rl
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_enrt_cvg_end_dt_rl    => p_rec.enrt_cvg_end_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_strt_dt_rl
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_enrt_cvg_strt_dt_rl   => p_rec.enrt_cvg_strt_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_end_dt_cd
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_enrt_cvg_end_dt_cd    => p_rec.enrt_cvg_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_strt_dt_rl
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_rt_strt_dt_rl         => p_rec.rt_strt_dt_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_strt_dt_cd
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_enrt_cvg_strt_dt_cd         => p_rec.enrt_cvg_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_end_dt
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_strt_dt               => p_rec.strt_dt,
   p_end_dt                => p_rec.end_dt,
   p_asnd_lf_evt_Dt        => p_rec.asnd_lf_evt_dt,
   p_object_version_number => p_rec.object_version_number);
  --
  -- bug fix 2206551 - added chk_dup_asnd_lf_evt_dt
  --
  chk_dup_asnd_lf_evt_dt
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_asnd_lf_evt_dt        => p_rec.asnd_lf_evt_dt,
   p_popl_enrt_typ_cycl_id => p_rec.popl_enrt_typ_cycl_id,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  --chk_dflt_enrt_dt
  --(p_enrt_perd_id          => p_rec.enrt_perd_id,
  -- p_dflt_enrt_dt          => p_rec.dflt_enrt_dt,
  -- p_end_dt                => p_rec.end_dt,
  -- p_object_version_number => p_rec.object_version_number);
  --
  chk_cls_enrt_dt_to_use_cd
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_cls_enrt_dt_to_use_cd         => p_rec.cls_enrt_dt_to_use_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrl_strt_dt_dpndcy
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_enrt_cvg_strt_dt_cd  => p_rec.enrt_cvg_strt_dt_cd,
   p_enrt_cvg_strt_dt_rl => p_rec.enrt_cvg_strt_dt_rl,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrl_end_dt_dpndcy
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_enrt_cvg_end_dt_cd  => p_rec.enrt_cvg_end_dt_cd,
   p_enrt_cvg_end_dt_rl => p_rec.enrt_cvg_end_dt_rl,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
   chk_rt_strt_dt_dpndcy
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_rt_strt_dt_cd  => p_rec.rt_strt_dt_cd,
   p_rt_strt_dt_rl => p_rec.rt_strt_dt_rl,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
   chk_rt_end_dt_dpndcy
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_rt_end_dt_cd  => p_rec.rt_end_dt_cd,
   p_rt_end_dt_rl => p_rec.rt_end_dt_rl,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  -- CWB
  --
   chk_bdgt_upd_end_dt
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_bdgt_upd_strt_dt      => p_rec.bdgt_upd_strt_dt,
   p_bdgt_upd_end_dt       => p_rec.bdgt_upd_end_dt,
   p_object_version_number => p_rec.object_version_number);
  --
   chk_ws_upd_end_dt
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_ws_upd_strt_dt        => p_rec.ws_upd_strt_dt,
   p_ws_upd_end_dt         => p_rec.ws_upd_end_dt,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bdgt_upd_period
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_strt_dt               => p_rec.strt_dt,
   p_end_dt                => p_rec.end_dt,
   p_bdgt_upd_strt_dt      => p_rec.bdgt_upd_strt_dt,
   p_bdgt_upd_end_dt       => p_rec.bdgt_upd_end_dt,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ws_upd_period
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_strt_dt               => p_rec.strt_dt,
   p_end_dt                => p_rec.end_dt,
   p_ws_upd_strt_dt        => p_rec.ws_upd_strt_dt,
   p_ws_upd_end_dt         => p_rec.ws_upd_end_dt,
   p_object_version_number => p_rec.object_version_number);
  --
  -- CWB
  --hr_utility.set_location(' p_rec.asnd_lf_evt_dt:'||p_rec.asnd_lf_evt_dt, 10);
    chk_cwb_validations
                           (p_enrt_perd_id         => p_rec.enrt_perd_id,
                            p_data_freeze_date     => p_rec.data_freeze_date,
                            p_Sal_chg_reason_cd    => p_rec.Sal_chg_reason_cd,
                            p_Approval_mode_cd     => p_rec.Approval_mode_cd,
                            p_hrchy_ame_trn_cd     => p_rec.hrchy_ame_trn_cd,
                            p_hrchy_rl             => p_rec.hrchy_rl,
                            p_hrchy_ame_app_id     => p_rec.hrchy_ame_app_id,
                            p_hrchy_to_use_cd      => p_rec.hrchy_to_use_cd,
                            p_effective_date       => p_rec.asnd_lf_evt_dt, --p_effective_date,
                            p_pos_structure_version_id => p_rec.pos_structure_version_id,
                            p_object_version_number    => p_rec.object_version_number
                           ) ;

chk_reinstate_ovrdn_cd(p_enrt_perd_id     =>p_rec.enrt_perd_id,
                            p_reinstate_ovrdn_cd      =>p_rec.reinstate_ovrdn_cd,
                            p_effective_date              => p_effective_date,
                            p_object_version_number      => p_rec.object_version_number
			   );

chk_reinstate_cd(p_enrt_perd_id     =>p_rec.enrt_perd_id,
                            p_reinstate_cd      =>p_rec.reinstate_cd,
                            p_effective_date              => p_effective_date,
                            p_object_version_number      => p_rec.object_version_number
			   );
  --
chk_defer_flag_set_pln_plip
			(p_enrt_perd_id		  => p_rec.enrt_perd_id
			,p_popl_enrt_typ_cycl_id  => p_rec.popl_enrt_typ_cycl_id
 		        ,p_object_version_number  => p_rec.object_version_number
			,p_effective_date	  => p_effective_date
			,p_defer_deenrol_flag     => p_rec.defer_deenrol_flag
			,p_business_group_id      => p_rec.business_group_id
			);
  --
 chk_defer_flag_lookup
			(p_enrt_perd_id		  => p_rec.enrt_perd_id
			,p_effective_date	  => p_effective_date
			,p_defer_deenrol_flag     => p_rec.defer_deenrol_flag
			,p_object_version_number  => p_rec.object_version_number
			);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end insert_validate;
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_enp_shd.g_rec_type
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
  chk_enrt_perd_id
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_yr_perd_id
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_yr_perd_id          => p_rec.yr_perd_id,
   p_popl_enrt_typ_cycl_id => p_rec.popl_enrt_typ_cycl_id,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_end_dt
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_strt_dt             => p_rec.strt_dt,
   p_end_dt              => p_rec.end_dt,
   p_asnd_lf_evt_dt      => p_rec.asnd_lf_evt_dt,
   p_object_version_number => p_rec.object_version_number);
  --
  -- bug fix 2206551 - added chk_dup_asnd_lf_evt_dt
  --
  chk_dup_asnd_lf_evt_dt
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_asnd_lf_evt_dt        => p_rec.asnd_lf_evt_dt,
   p_popl_enrt_typ_cycl_id => p_rec.popl_enrt_typ_cycl_id,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  --chk_dflt_enrt_dt
  --(p_enrt_perd_id          => p_rec.enrt_perd_id,
  -- p_dflt_enrt_dt        => p_rec.dflt_enrt_dt,
  -- p_end_dt              => p_rec.end_dt,
  -- p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_end_dt_rl
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_rt_end_dt_rl          => p_rec.rt_end_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_end_dt_cd
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_rt_end_dt_cd          => p_rec.rt_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_strt_dt_cd
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_rt_strt_dt_cd         => p_rec.rt_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_end_dt_rl
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_enrt_cvg_end_dt_rl    => p_rec.enrt_cvg_end_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_strt_dt_rl
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_enrt_cvg_strt_dt_rl   => p_rec.enrt_cvg_strt_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_end_dt_cd
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_enrt_cvg_end_dt_cd         => p_rec.enrt_cvg_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_strt_dt_rl
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_rt_strt_dt_rl        => p_rec.rt_strt_dt_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_strt_dt_cd
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_enrt_cvg_strt_dt_cd         => p_rec.enrt_cvg_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cls_enrt_dt_to_use_cd
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_cls_enrt_dt_to_use_cd         => p_rec.cls_enrt_dt_to_use_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrl_strt_dt_dpndcy
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_enrt_cvg_strt_dt_cd  => p_rec.enrt_cvg_strt_dt_cd,
   p_enrt_cvg_strt_dt_rl => p_rec.enrt_cvg_strt_dt_rl,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrl_end_dt_dpndcy
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_enrt_cvg_end_dt_cd  => p_rec.enrt_cvg_end_dt_cd,
   p_enrt_cvg_end_dt_rl => p_rec.enrt_cvg_end_dt_rl,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_strt_dt_dpndcy
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_rt_strt_dt_cd  => p_rec.rt_strt_dt_cd,
   p_rt_strt_dt_rl => p_rec.rt_strt_dt_rl,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
   chk_rt_end_dt_dpndcy
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_rt_end_dt_cd  => p_rec.rt_end_dt_cd,
   p_rt_end_dt_rl => p_rec.rt_end_dt_rl,
   p_effective_date => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  -- CWB
  --
   chk_bdgt_upd_end_dt
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_bdgt_upd_strt_dt      => p_rec.bdgt_upd_strt_dt,
   p_bdgt_upd_end_dt       => p_rec.bdgt_upd_end_dt,
   p_object_version_number => p_rec.object_version_number);
  --
   chk_ws_upd_end_dt
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_ws_upd_strt_dt        => p_rec.ws_upd_strt_dt,
   p_ws_upd_end_dt         => p_rec.ws_upd_end_dt,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bdgt_upd_period
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_strt_dt               => p_rec.strt_dt,
   p_end_dt                => p_rec.end_dt,
   p_bdgt_upd_strt_dt      => p_rec.bdgt_upd_strt_dt,
   p_bdgt_upd_end_dt       => p_rec.bdgt_upd_end_dt,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ws_upd_period
  (p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_strt_dt               => p_rec.strt_dt,
   p_end_dt                => p_rec.end_dt,
   p_ws_upd_strt_dt        => p_rec.ws_upd_strt_dt,
   p_ws_upd_end_dt         => p_rec.ws_upd_end_dt,
   p_object_version_number => p_rec.object_version_number);
  --
  -- CWB
    chk_cwb_validations
                           (p_enrt_perd_id         => p_rec.enrt_perd_id,
                            p_data_freeze_date     => p_rec.data_freeze_date,
                            p_Sal_chg_reason_cd    => p_rec.Sal_chg_reason_cd,
                            p_Approval_mode_cd     => p_rec.Approval_mode_cd,
                            p_hrchy_ame_trn_cd     => p_rec.hrchy_ame_trn_cd,
                            p_hrchy_rl             => p_rec.hrchy_rl,
                            p_hrchy_ame_app_id     => p_rec.hrchy_ame_app_id,
                            p_hrchy_to_use_cd      => p_rec.hrchy_to_use_cd,
                            p_effective_date       => p_rec.asnd_lf_evt_dt, --p_effective_date,
                            p_pos_structure_version_id => p_rec.pos_structure_version_id,
                            p_object_version_number    => p_rec.object_version_number
                           ) ;
  --
  --Reinstate Lookup Validations
chk_reinstate_ovrdn_cd(p_enrt_perd_id     =>p_rec.enrt_perd_id,
                            p_reinstate_ovrdn_cd      =>p_rec.reinstate_ovrdn_cd,
                            p_effective_date              => p_effective_date,
                            p_object_version_number      => p_rec.object_version_number
			   );

chk_reinstate_cd(p_enrt_perd_id     =>p_rec.enrt_perd_id,
                            p_reinstate_cd      =>p_rec.reinstate_cd,
                            p_effective_date              => p_effective_date,
                            p_object_version_number      => p_rec.object_version_number
			   );
 --
chk_defer_flag_set_pln_plip
			(p_enrt_perd_id		  => p_rec.enrt_perd_id
			,p_popl_enrt_typ_cycl_id  => p_rec.popl_enrt_typ_cycl_id
 		        ,p_object_version_number  => p_rec.object_version_number
			,p_effective_date	  => p_effective_date
			,p_defer_deenrol_flag     => p_rec.defer_deenrol_flag
			,p_business_group_id      => p_rec.business_group_id
			);
 --
 chk_defer_flag_lookup
			(p_enrt_perd_id		  => p_rec.enrt_perd_id
			,p_effective_date	  => p_effective_date
			,p_defer_deenrol_flag     => p_rec.defer_deenrol_flag
			,p_object_version_number  => p_rec.object_version_number
			);
 --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_enp_shd.g_rec_type
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
  (p_enrt_perd_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_enrt_perd b
    where b.enrt_perd_id      = p_enrt_perd_id
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
                             p_argument       => 'enrt_perd_id',
                             p_argument_value => p_enrt_perd_id);
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
end ben_enp_bus;

/
