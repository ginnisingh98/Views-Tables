--------------------------------------------------------
--  DDL for Package Body BEN_CRT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CRT_BUS" as
/* $Header: becrtrhi.pkb 115.11 2004/06/22 07:52:16 rpgupta ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_crt_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_crt_ordr_id >------|
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
--   crt_ordr_id PK of record being inserted or updated.
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
Procedure chk_crt_ordr_id(p_crt_ordr_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_crt_ordr_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_crt_shd.api_updating
    (p_crt_ordr_id                => p_crt_ordr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_crt_ordr_id,hr_api.g_number)
     <>  ben_crt_shd.g_old_rec.crt_ordr_id) then
    --
    -- raise error as PK has changed
    --
    ben_crt_shd.constraint_error('BEN_CRT_ORDR_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_crt_ordr_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_crt_shd.constraint_error('BEN_CRT_ORDR_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_crt_ordr_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_person_id >------|
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
--   p_crt_ordr_id PK
--   p_person_id ID of FK column
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
Procedure chk_person_id (p_crt_ordr_id          in number,
                            p_person_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_person_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_all_people_f a
    where  a.person_id = p_person_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_crt_shd.api_updating
     (p_crt_ordr_id            => p_crt_ordr_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_person_id,hr_api.g_number)
     <> nvl(ben_crt_shd.g_old_rec.person_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if person_id value exists in per_all_people_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_all_people_f
        -- table.
        --
        ben_crt_shd.constraint_error('BEN_CRT_ORDR_DT1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_person_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pl_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   (A) This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--   (B) This procedure checks that the plan selected is ACTIVE on the effective
--    date.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_crt_ordr_id PK
--   p_pl_id ID of FK column
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
Procedure chk_pl_id (p_crt_ordr_id          in number,
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
    where  a.pl_id = p_pl_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;

  cursor c2 is
    select null
    from ben_pl_F pln
    where pln.pl_id = p_pl_id
    and    p_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date
    and pln.pl_stat_cd = 'A';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_crt_shd.api_updating
     (p_crt_ordr_id            => p_crt_ordr_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pl_id,hr_api.g_number)
     <> nvl(ben_crt_shd.g_old_rec.pl_id,hr_api.g_number)
     or not l_api_updating)
     and p_pl_id is not null then
    --
    -- check if pl_id value exists in ben_pl_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_pl_f
        -- table.
        --
        ben_crt_shd.constraint_error('BEN_CRT_ORDR_DT2');
        --
      end if;
      --
    close c1;
    --
    -- Bug : 3616686
    -- check if selected plan is active
    --
    open c2;
     --
     fetch c2 into l_dummy;
     if c2%notfound then
       --
       close c2;
       --
       -- Raise error as inactive plan is selected
       --
       fnd_message.set_name('BEN','BEN_93965_SELECT_ACTIVE_PLAN');
       fnd_message.raise_error;
       --
     end if;
     --
    close c2;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pl_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_strt_dt_precedes_end_dt>------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the start date and end date
--   are entered properly. The following condition will be checked:
--   	* Start date always precedes End date.
--   Bug : 3616686
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_Start Date	 - Program/Plan year period's Start Date
--   p_End Date          - Program/Plan year period End Date
--
--
Procedure chk_strt_dt_precedes_end_dt(p_start_date 	in date,
                      	   	      p_end_date    	in date ) is
  --
  l_proc         varchar2(72) := g_package||'chk_strt_dt_precedes_end_dt';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  if p_start_Date is not null and p_end_date is not null and  p_start_date > p_end_date then
      --
      -- raise error Start Date must precede End date
      --
      fnd_message.set_name('BEN','BEN_92688_RT_STRT_DT_GT_END_DT'); -- 3709010
      hr_utility.set_message_token('START',to_char(p_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
      hr_utility.set_message_token('END',to_char(p_end_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
      fnd_message.raise_error;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_strt_dt_precedes_end_dt;
--
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
--   p_crt_ordr_id PK
--   p_pl_typ_id ID of FK column
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
Procedure chk_pl_typ_id (p_crt_ordr_id          in number,
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
    from   ben_pl_typ_f a
    where  a.pl_typ_id = p_pl_typ_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_crt_shd.api_updating
     (p_crt_ordr_id            => p_crt_ordr_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pl_typ_id,hr_api.g_number)
     <> nvl(ben_crt_shd.g_old_rec.pl_typ_id,hr_api.g_number)
     or not l_api_updating)
     and p_pl_typ_id is not null then
    --
    -- check if pl_typ_id value exists in ben_pl_typ_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_pl_typ_f
        -- table.
        --
        ben_crt_shd.constraint_error('BEN_CRT_ORDR_DT3');
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
-- |------< chk_pl_pltyp_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure enforces the arc relationship
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_pl_typ_id
--   p_pl_id ID
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
Procedure chk_pl_pltyp_id ( p_pl_id          in number,
                            p_pl_typ_id in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pl_pltyp_id';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  if p_pl_id     is null and
     p_pl_typ_id is null then
    --
    -- raise error as at least one must exist
       fnd_message.set_name('BEN','BEN_92398_PL_PLTYP_BNULL');
       fnd_message.raise_error;
    --
    --
  elsif p_pl_id  is not null and
     p_pl_typ_id is not null then
    --
    -- raise error as only one may exist
       fnd_message.set_name('BEN','BEN_92399_PL_PLTYP_BVAL');
       fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pl_pltyp_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_qdro_dstr_mthd_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   crt_ordr_id PK of record being inserted or updated.
--   qdro_dstr_mthd_cd Value of lookup code.
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
Procedure chk_qdro_dstr_mthd_cd(p_crt_ordr_id                in number,
                            p_qdro_dstr_mthd_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_qdro_dstr_mthd_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_crt_shd.api_updating
    (p_crt_ordr_id                => p_crt_ordr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_qdro_dstr_mthd_cd
      <> nvl(ben_crt_shd.g_old_rec.qdro_dstr_mthd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_qdro_dstr_mthd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_QDRO_DSTR_MTHD',
           p_lookup_code    => p_qdro_dstr_mthd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_qdro_dstr_mthd_cd');
      fnd_message.set_token('TYPE','BEN_QDRO_DSTR_MTHD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_qdro_dstr_mthd_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_qdro_per_perd_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   crt_ordr_id PK of record being inserted or updated.
--   qdro_per_perd_cd Value of lookup code.
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
Procedure chk_qdro_per_perd_cd(p_crt_ordr_id                in number,
                               p_qdro_per_perd_cd           in varchar2,
                               p_effective_date             in date,
                               p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_qdro_per_perd_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_crt_shd.api_updating
    (p_crt_ordr_id                => p_crt_ordr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_qdro_per_perd_cd
      <> nvl(ben_crt_shd.g_old_rec.qdro_per_perd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_qdro_per_perd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BNDRY_PERD',
           p_lookup_code    => p_qdro_per_perd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_qdro_per_perd_cd');
      fnd_message.set_token('TYPE','BEN_BNDRY_PERD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_qdro_per_perd_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_crt_ordr_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   crt_ordr_id PK of record being inserted or updated.
--   crt_ordr_typ_cd Value of lookup code.
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
Procedure chk_crt_ordr_typ_cd(p_crt_ordr_id                in number,
                            p_crt_ordr_typ_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_crt_ordr_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_crt_shd.api_updating
    (p_crt_ordr_id                => p_crt_ordr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_crt_ordr_typ_cd
      <> nvl(ben_crt_shd.g_old_rec.crt_ordr_typ_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_CRT_ORDR_TYP',
           p_lookup_code    => p_crt_ordr_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_crt_ordr_typ_cd');
      fnd_message.set_token('TYPE','BEN_CRT_ORDR_TYP');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_crt_ordr_typ_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_rqd_by_typ >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that based on what type is used,
--   certain fields are required. p_apls_perd_strtg_dt is required.
--   If type is QDRO then qdro_amt and
--   uom are required OR qdro_pct is required.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   crt_ordr_id PK of record being inserted or updated.
--   crt_ordr_typ_cd Value of lookup code.
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
Procedure chk_rqd_by_typ(p_crt_ordr_id                in number,
                         p_crt_ordr_typ_cd            in varchar2,
                         p_apls_perd_strtg_dt         in date,
                         p_apls_perd_endg_dt          in date,
                         p_qdro_amt                   in number,
                         p_qdro_pct                   in number,
                         p_uom                        in varchar2,
                         p_effective_date             in date,
                         p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rqd_by_typ';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_crt_shd.api_updating
    (p_crt_ordr_id                => p_crt_ordr_id,
     p_object_version_number       => p_object_version_number);
  --
  If p_apls_perd_strtg_dt is null then
     fnd_message.set_name('BEN','BEN_91977_DT_RQD_CRTORDR');
     fnd_message.raise_error;
  End If;

  If p_crt_ordr_typ_cd = 'QDRO' then
     If p_qdro_amt is null and p_qdro_pct is null then
        fnd_message.set_name('BEN','BEN_91978_AMT_PCT_RQD_QDRO');
        fnd_message.raise_error;
     elsif p_qdro_amt is not null then
        If p_uom is null then
	   fnd_message.set_name('BEN','BEN_91979_AMT_UOM_RQD_QDRO');
           fnd_message.raise_error;
        End If;
        If p_qdro_pct is not null then
           fnd_message.set_name('BEN','BEN_91980_AMT_PCT_MUTEXCL');
           fnd_message.raise_error;
        End If;
     elsif p_qdro_pct is not null then
        If p_qdro_amt is not null or p_uom is not null then
           fnd_message.set_name('BEN','BEN_91981_PCT_AMTUOM_MUTEXCL');
           fnd_message.raise_error;
        End if;
     End if;
  End if;

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rqd_by_typ;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_crt_shd.g_rec_type
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
  chk_crt_ordr_id
  (p_crt_ordr_id          => p_rec.crt_ordr_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pl_id
  (p_crt_ordr_id          => p_rec.crt_ordr_id,
   p_pl_id                 => p_rec.pl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pl_typ_id
  (p_crt_ordr_id          => p_rec.crt_ordr_id,
   p_pl_typ_id             => p_rec.pl_typ_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_person_id
  (p_crt_ordr_id          => p_rec.crt_ordr_id,
   p_person_id                 => p_rec.person_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pl_pltyp_id
  (p_pl_id          => p_rec.pl_id,
   p_pl_typ_id      => p_rec.pl_typ_id);
  --
  chk_qdro_per_perd_cd
  (p_crt_ordr_id          => p_rec.crt_ordr_id,
   p_qdro_per_perd_cd         => p_rec.qdro_per_perd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_qdro_dstr_mthd_cd
  (p_crt_ordr_id          => p_rec.crt_ordr_id,
   p_qdro_dstr_mthd_cd         => p_rec.qdro_dstr_mthd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crt_ordr_typ_cd
  (p_crt_ordr_id          => p_rec.crt_ordr_id,
   p_crt_ordr_typ_cd         => p_rec.crt_ordr_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rqd_by_typ
  (p_crt_ordr_id           => p_rec.crt_ordr_id,
   p_crt_ordr_typ_cd       => p_rec.crt_ordr_typ_cd,
   p_apls_perd_strtg_dt    => p_rec.apls_perd_strtg_dt,
   p_apls_perd_endg_dt     => p_rec.apls_perd_endg_dt,
   p_qdro_amt              => p_rec.qdro_amt,
   p_qdro_pct              => p_rec.qdro_pct,
   p_uom                   => p_rec.uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_strt_dt_precedes_end_dt
  (p_start_date 	  =>  p_rec.apls_perd_strtg_dt,
   p_end_date    	  =>  p_rec.apls_perd_endg_dt);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_crt_shd.g_rec_type
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
  chk_crt_ordr_id
  (p_crt_ordr_id          => p_rec.crt_ordr_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pl_id
  (p_crt_ordr_id          => p_rec.crt_ordr_id,
   p_pl_id                 => p_rec.pl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pl_typ_id
  (p_crt_ordr_id          => p_rec.crt_ordr_id,
   p_pl_typ_id             => p_rec.pl_typ_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_person_id
  (p_crt_ordr_id          => p_rec.crt_ordr_id,
   p_person_id                 => p_rec.person_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pl_pltyp_id
  (p_pl_id          => p_rec.pl_id,
   p_pl_typ_id      => p_rec.pl_typ_id);
  --
  chk_qdro_per_perd_cd
  (p_crt_ordr_id          => p_rec.crt_ordr_id,
   p_qdro_per_perd_cd         => p_rec.qdro_per_perd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_qdro_dstr_mthd_cd
  (p_crt_ordr_id          => p_rec.crt_ordr_id,
   p_qdro_dstr_mthd_cd         => p_rec.qdro_dstr_mthd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crt_ordr_typ_cd
  (p_crt_ordr_id          => p_rec.crt_ordr_id,
   p_crt_ordr_typ_cd         => p_rec.crt_ordr_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rqd_by_typ
  (p_crt_ordr_id           => p_rec.crt_ordr_id,
   p_crt_ordr_typ_cd       => p_rec.crt_ordr_typ_cd,
   p_apls_perd_strtg_dt    => p_rec.apls_perd_strtg_dt,
   p_apls_perd_endg_dt     => p_rec.apls_perd_endg_dt,
   p_qdro_amt              => p_rec.qdro_amt,
   p_qdro_pct              => p_rec.qdro_pct,
   p_uom                   => p_rec.uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_strt_dt_precedes_end_dt
  (p_start_date 	  =>  p_rec.apls_perd_strtg_dt,
   p_end_date    	  =>  p_rec.apls_perd_endg_dt);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_crt_shd.g_rec_type
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
  (p_crt_ordr_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_crt_ordr b
    where b.crt_ordr_id      = p_crt_ordr_id
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
                             p_argument       => 'crt_ordr_id',
                             p_argument_value => p_crt_ordr_id);
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
      fnd_message.set_name('BEN','HR_7220_INVALID_PRIMARY_KEY');
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
end ben_crt_bus;

/
