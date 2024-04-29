--------------------------------------------------------
--  DDL for Package Body BEN_CPY_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPY_BUS" as
/* $Header: becpyrhi.pkb 120.2 2005/12/19 12:34:35 kmahendr noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cpy_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_popl_yr_perd_id >--------------------------|
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
--   popl_yr_perd_id PK of record being inserted or updated.
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
Procedure chk_popl_yr_perd_id(p_popl_yr_perd_id             in number,
                              p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_popl_yr_perd_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpy_shd.api_updating
    (p_popl_yr_perd_id             => p_popl_yr_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_popl_yr_perd_id,hr_api.g_number)
     <>  ben_cpy_shd.g_old_rec.popl_yr_perd_id) then
    --
    -- raise error as PK has changed
    --
    ben_cpy_shd.constraint_error('BEN_POPL_YR_PERD_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_popl_yr_perd_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_cpy_shd.constraint_error('BEN_POPL_YR_PERD_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_popl_yr_perd_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_pl_pgm_yr_perd_id >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the program or plan year period is
--   not overlapping another program or plan year period for the same program
--   or plan.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   popl_yr_perd_id       PK of record being inserted or updated.
--   pgm_id                Id of program.
--   pl_id                 Id of plan.
--   yr_perd_id            Id of year period.
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
Procedure chk_pgm_pl_yr_perd_id(p_popl_yr_perd_id       in number,
                                p_pgm_id                in number,
                                p_pl_id                 in number,
                                p_yr_perd_id            in number,
                                p_business_group_id     in number,
                                p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pgm_pl_yr_perd_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c_plan is
    select null
    from   ben_yr_perd yrp
    where  yrp.yr_perd_id = p_yr_perd_id
    and    yrp.business_group_id = p_business_group_id
    and    exists (select null
                   from   ben_popl_yr_perd a,
                          ben_yr_perd b
                   where  a.popl_yr_perd_id <> nvl(p_popl_yr_perd_id,-1)
                   and    a.pl_id = p_pl_id
                   and    a.business_group_id = p_business_group_id
                   and    a.yr_perd_id = b.yr_perd_id
                   and    (yrp.start_date
                           between b.start_date
                           and     b.end_date
                           or
                           yrp.end_date
                           between b.start_date
                           and     b.end_date));
  --
  cursor c_prog is
    select null
    from   ben_yr_perd yrp
    where  yrp.yr_perd_id = p_yr_perd_id
    and    yrp.business_group_id = p_business_group_id
    and    exists (select null
                   from   ben_popl_yr_perd a,
                          ben_yr_perd b
                   where  a.popl_yr_perd_id <> nvl(p_popl_yr_perd_id,-1)
                   and    a.pgm_id = p_pgm_id
                   and    a.business_group_id = p_business_group_id
                   and    a.yr_perd_id = b.yr_perd_id
                   and    (yrp.start_date
                           between b.start_date
                           and     b.end_date
                           or
                           yrp.end_date
                           between b.start_date
                           and     b.end_date));
  --
  cursor c_duplicate is
    select null
    from   ben_popl_yr_perd cpy
    where  (cpy.pgm_id = nvl(p_pgm_id,-1) or
            cpy.pl_id  = nvl(p_pl_id,-1))
    and    cpy.yr_perd_id = p_yr_perd_id
    and    cpy.popl_yr_perd_id <> p_popl_yr_perd_id
    and    cpy.business_group_id+0 = p_business_group_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpy_shd.api_updating
    (p_popl_yr_perd_id             => p_popl_yr_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and (nvl(p_popl_yr_perd_id,hr_api.g_number)
          <>  ben_cpy_shd.g_old_rec.popl_yr_perd_id
          or   nvl(p_pgm_id,hr_api.g_number)
               <>  ben_cpy_shd.g_old_rec.pgm_id
          or   nvl(p_pl_id,hr_api.g_number)
               <>  ben_cpy_shd.g_old_rec.pl_id
          or   nvl(p_yr_perd_id,hr_api.g_number)
               <>  ben_cpy_shd.g_old_rec.yr_perd_id)
     or   not l_api_updating) then
    --
    -- check if an overlap occurs
    --
    if p_pl_id is not null then
      --
      open c_plan;
        --
        fetch c_plan into l_dummy;
        if c_plan%found then
          --
          close c_plan;
          fnd_message.set_name('BEN','BEN_91719_CPY_PYR_PERD_OVERLAP');
          fnd_message.raise_error;
          --
        end if;
        --
      close c_plan;
      --
    else
      --
      open c_prog;
        --
        fetch c_prog into l_dummy;
        if c_prog%found then
          --
          close c_prog;
          fnd_message.set_name('BEN','BEN_91719_CPY_PYR_PERD_OVERLAP');
          fnd_message.raise_error;
          --
        end if;
        --
      close c_prog;
      --
    end if;
    --
    open c_duplicate;
      --
      fetch c_duplicate into l_dummy;
      if c_duplicate%found then
        --
        close c_duplicate;
        fnd_message.set_name('BEN','BEN_91719_CPY_PYR_PERD_OVERLAP');
        fnd_message.raise_error;
        --
      end if;
      --
    close c_duplicate;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pgm_pl_yr_perd_id;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_pl_id >---------------------------------|
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
--   p_popl_yr_perd_id PK
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
Procedure chk_pl_id (p_popl_yr_perd_id       in number,
                     p_pl_id                 in number,
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
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_cpy_shd.api_updating
     (p_popl_yr_perd_id         => p_popl_yr_perd_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pl_id,hr_api.g_number)
     <> nvl(ben_cpy_shd.g_old_rec.pl_id,hr_api.g_number)
     or not l_api_updating) then
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
        ben_cpy_shd.constraint_error('DATETRACK-ERROR');
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
-- |------------------------------< chk_pgm_id >------------------------------|
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
--   p_popl_yr_perd_id PK
--   p_pgm_id ID of FK column
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
Procedure chk_pgm_id (p_popl_yr_perd_id       in number,
                      p_pgm_id                in number,
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
    where  a.pgm_id = p_pgm_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_cpy_shd.api_updating
     (p_popl_yr_perd_id         => p_popl_yr_perd_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pgm_id,hr_api.g_number)
     <> nvl(ben_cpy_shd.g_old_rec.pgm_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if pgm_id value exists in ben_pgm_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_pgm_f
        -- table.
        --
        ben_cpy_shd.constraint_error('DATETRACK-ERROR');
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
-- |----------------------------< chk_yr_perd_id >----------------------------|
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
--   p_popl_yr_perd_id PK
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
Procedure chk_yr_perd_id (p_popl_yr_perd_id       in number,
                          p_yr_perd_id            in number,
                          p_object_version_number in number,
                          -- Bug 3985729
			  p_ordr_num              in number) is
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
  l_api_updating := ben_cpy_shd.api_updating
     (p_popl_yr_perd_id         => p_popl_yr_perd_id,
      p_object_version_number   => p_object_version_number);
  --
  --Bug 3985729
  if((p_ordr_num is not NULL) and (p_yr_perd_id is NULL))
  then
  fnd_message.set_name('BEN','BEN_94122_PLAN_YR_PERD_MANDTRY');
  fnd_message.raise_error;
  --
  elsif (l_api_updating
     and nvl(p_yr_perd_id,hr_api.g_number)
     <> nvl(ben_cpy_shd.g_old_rec.yr_perd_id,hr_api.g_number)
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
        ben_cpy_shd.constraint_error('BEN_POPL_YR_PERD_FK1');
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
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_pgm_pl_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that either the pl_id or pgm_id is populated and not
--   both.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_pl_id      plan id of record.
--   p_pgm_id     program id of record.
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
Procedure chk_pgm_pl_id (p_pgm_id       in number,
                         p_pl_id        in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pgm_pl_id';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- check that only one of the foreign keys is populated.
  --
  if p_pgm_id is not null and
    p_pl_id is not null then
    --
    hr_utility.set_message(801,'PGM_OR_PL_ID_SET');
    hr_utility.raise_error;
    --
  elsif p_pgm_id is null and
    p_pl_id is null then
    --
    hr_utility.set_message(801,'PGM_OR_PL_ID_SET');
    hr_utility.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pgm_pl_id;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_acpt_clm_rqsts_thru_dt >-----------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that an acpt_clm_rqsts_thru_dt actually exists
--   if the py_clms_thru_dt is not null.  We can also verify the the
--   acpt_clm_rqsts_thru_dt value is greater than the (on or after)
--   the YR_PERD end date.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_acpt_clm_rqsts_thru_dt date value
--   p_py_clms_thru_dt date value
--   p_yr_perd_id ID of FK column
--   p_object_number_number for record
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
Procedure chk_acpt_clm_rqsts_thru_dt (p_acpt_clm_rqsts_thru_dt  in date,
                          	      p_py_clms_thru_dt         in date,
                                      p_yr_perd_id              in number,
                                      p_popl_yr_perd_id		in number,
                                      p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_acpt_clm_rqsts_thru_dt';
  l_api_updating boolean;
  l_start        date;
  l_end          date;
  --
  cursor c1 is
    select start_date, end_date
    from   ben_yr_perd a
    where  a.yr_perd_id = p_yr_perd_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_cpy_shd.api_updating
     (p_popl_yr_perd_id         => p_popl_yr_perd_id,
      p_object_version_number   => p_object_version_number);
  --
  -- if p_py_clms_thru_dt is not filled in then we need to tell user we
  -- have one value but we need the other
  --
  if (l_api_updating
       and (nvl(p_yr_perd_id,hr_api.g_number)
            <> nvl(ben_cpy_shd.g_old_rec.yr_perd_id,hr_api.g_number)
            or nvl(p_py_clms_thru_dt,hr_api.g_date)
            <> nvl(ben_cpy_shd.g_old_rec.py_clms_thru_dt,hr_api.g_date)
            or nvl(p_acpt_clm_rqsts_thru_dt,hr_api.g_date)
            <> nvl(ben_cpy_shd.g_old_rec.acpt_clm_rqsts_thru_dt,hr_api.g_date))
       or not l_api_updating) then
    --
    -- OK we are updating or we are inserting so lets check if the values
    -- of the dates are valid. They must both be null or both be not null
    -- if the incurred date can be not null , but not otherway arround - tilak
    --
    if (p_py_clms_thru_dt is null and
        p_acpt_clm_rqsts_thru_dt is not null)
     /*   or
       (p_py_clms_thru_dt is not null and
        p_acpt_clm_rqsts_thru_dt is null) bug 1716967 */
        then
      --
      -- error py_clms_thru_dt or acpt_rqsts_clm_thru_dt are null
      --
      hr_utility.set_message(805,'BEN_91317_PY_CLMS_OR_ACPT_NULL');
      hr_utility.raise_error;
      --
    end if;

   if (p_py_clms_thru_dt is null and p_acpt_clm_rqsts_thru_dt is  not null)
      and ( p_py_clms_thru_dt >  p_acpt_clm_rqsts_thru_dt)  then
      hr_utility.set_message(805,'BEN_92696_RQST_DT_TO_INCRD_DT');
      hr_utility.raise_error;
   end if ;
   --
    -- check if yr_perd_id yields a start and end for a comparison
    --
    open c1;
      --
      fetch c1 into l_start, l_end;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_yr_perd
        -- table.
        --
        ben_cpy_shd.constraint_error('BEN_POPL_YR_PERD_FK1');
        --
      end if;
      --
      -- compare acpt_clm_rqsts_dt to be sure it is greater or equal to
      -- l_end date
      --
      if (p_acpt_clm_rqsts_thru_dt < l_end) then
        --
        -- error acpt_clm_rqsts_thru_dt less than yr_perd end_date
        --
        hr_utility.set_message(805,'BEN_91318_ACPT_LT_YR_PERD');
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
End chk_acpt_clm_rqsts_thru_dt;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_py_clms_thru_dt >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that py_clms_thru_dt is before or equal to the
--   acpt_clm_rqsts_thru_dt.  Also that the py_clms_thru_dt in on or before
--   the yr_perd_id end_date of yr_perd selected.
--   if the py_clms_thru_dt is not null.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_acpt_clm_rqsts_thru_dt date value
--   p_py_clms_thru_dt date value
--   p_yr_perd_id ID of FK column
--   p_object_version_number for record
--
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
Procedure chk_py_clms_thru_dt (p_acpt_clm_rqsts_thru_dt         in date,
                       	       p_py_clms_thru_dt         in date,
                               p_yr_perd_id              in number,
                               p_popl_yr_perd_id         in number,
                               p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_py_clms_thru_dt';
  l_api_updating boolean;
  l_start        date;
  l_end          date;
  --
  cursor c1 is
    select start_date, end_date
    from   ben_yr_perd a
    where  a.yr_perd_id = p_yr_perd_id;
  --
  cursor c_claims (p_pl_id number) is
    select null
    from ben_prtt_reimbmt_rqst_f prc
    where prc.EXP_INCURD_DT > p_py_clms_thru_dt
    and   prc.pl_id = p_pl_id
    and   prc.popl_yr_perd_id_1 = p_yr_perd_id
    and   prc.prtt_reimbmt_rqst_stat_cd in ('APPRVD','PDINFL','PRTLYPD');
 --
 l_Claims  varchar2(1);
 --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_cpy_shd.api_updating
     (p_popl_yr_perd_id         => p_popl_yr_perd_id,
      p_object_version_number   => p_object_version_number);
  --
  -- if p_py_clms_thru_dt is not filled in then we need to tell user we
  -- have one value but we need the other
  --
  if (l_api_updating
       and (nvl(p_yr_perd_id,hr_api.g_number)
            <> nvl(ben_cpy_shd.g_old_rec.yr_perd_id,hr_api.g_number)
            or nvl(p_py_clms_thru_dt,hr_api.g_date)
            <> nvl(ben_cpy_shd.g_old_rec.py_clms_thru_dt,hr_api.g_date)
            or nvl(p_acpt_clm_rqsts_thru_dt,hr_api.g_date)
            <> nvl(ben_cpy_shd.g_old_rec.acpt_clm_rqsts_thru_dt,hr_api.g_date))
       or not l_api_updating) then
    --
    -- OK we are updating or we are inserting so lets check if the values
    -- of the dates are valid. They must both be null or both be not null
    --
    if (p_py_clms_thru_dt <= p_acpt_clm_rqsts_thru_dt) and
        p_py_clms_thru_dt is not null and
        p_acpt_clm_rqsts_thru_dt is not null then
      --
      -- check if yr_perd_id yields a start and end for a comparison
      --
      open c1;
        --
        fetch c1 into l_start, l_end;
        if c1%notfound then
          --
          close c1;
          --
          -- raise error as FK does not relate to PK in ben_yr_perd
          -- table.
          --
          ben_cpy_shd.constraint_error('BEN_POPL_YR_PERD_FK1');
          --
        end if;
        --
        -- compare py_clms_dt to be sure it is on or before (less than)
        -- l_end date
        --
        /* fsa grace period enh - pay claims thru date may be greater than
          year period end date
        if (p_py_clms_thru_dt > l_end) then
          --
          -- error py_clms_thru_dt is greater than yr_perd end_date
          --
          hr_utility.set_message(805,'BEN_91319_PY_CLMS_GT_YR_END');
          hr_utility.raise_error;
          --
        end if;
        */
        --
      close c1;
      --
    else
      --
      -- Only fail here if they the values are both not null
      --
      if p_py_clms_thru_dt is not null and
         p_acpt_clm_rqsts_thru_dt is not null then
        --
        -- error py_clms_thru_dt must be less than acpt_rqsts_clm_thru_dt
        --
        hr_utility.set_message(805,'BEN_91316_PY_CLMS_LT_ACPT');
        hr_utility.raise_error;
        --
      end if;
      --
    end if;
    --
  end if;
  --
  if p_py_clms_thru_dt < ben_cpy_shd.g_old_rec.py_clms_thru_dt then
    --
    open c_claims (ben_cpy_shd.g_old_rec.pl_id);
    fetch c_claims into l_claims;
    if c_claims%found then
      --
      close c_claims;
      hr_utility.set_message(805,'BEN_91316_PY_CLMS_LT_ACPT');
        hr_utility.raise_error;
    else
      --
      close c_claims;
      --
    end if;
    --
  end if;

  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_py_clms_thru_dt;
--
-- ---------------------------------------------------------------------------
-- |-----------------------< chk_ordr_num_unique >---------------------------|
-- ---------------------------------------------------------------------------
--
-- Description
--   ensure that the Sequence Number is unique
--   within business_group
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_ordr_num                Sequence Number
--     p_popl_yr_perd_id         Primary Key of BEN_POPL_YR_PERD
--     p_pl_id
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
Procedure chk_ordr_num_unique
          ( p_popl_yr_perd_id           in   number
           /* bug 2923047 */
           ,p_pgm_id                    in   number
           ,p_pl_id                     in   number
           ,p_ordr_num                  in   number
           ,p_business_group_id         in   number)
is
l_proc      varchar2(72) := g_package||'chk_ordr_num_unique';
l_dummy    char(1);
cursor c1 is select null
             from   ben_popl_yr_perd
             Where  popl_yr_perd_id <> nvl(p_popl_yr_perd_id,-1)
             /* bug 2923047 -- add pgm_id also */
             and
                 (pl_id = p_pl_id
                  or
                  pgm_id = p_pgm_id
                  )
             and    ordr_num = p_ordr_num
             and    business_group_id = p_business_group_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into l_dummy;
  if c1%found then
      close c1;
      fnd_message.set_name('BEN','BEN_91001_SEQ_NOT_UNIQUE');
      fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_ordr_num_unique;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_cpy_shd.g_rec_type) is
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
  chk_popl_yr_perd_id
  (p_popl_yr_perd_id       => p_rec.popl_yr_perd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_yr_perd_id
  (p_popl_yr_perd_id       => p_rec.popl_yr_perd_id,
   p_yr_perd_id            => p_rec.yr_perd_id,
   p_object_version_number => p_rec.object_version_number,
  --Bug 3985729
   p_ordr_num              => p_rec.ordr_num);
  --
  chk_pgm_pl_id
  (p_pgm_id       => p_rec.pgm_id,
   p_pl_id        => p_rec.pl_id);
  --
  chk_pgm_pl_yr_perd_id
  (p_popl_yr_perd_id       => p_rec.popl_yr_perd_id,
   p_pgm_id                => p_rec.pgm_id,
   p_pl_id                 => p_rec.pl_id,
   p_business_group_id     => p_rec.business_group_id,
   p_yr_perd_id            => p_rec.yr_perd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_acpt_clm_rqsts_thru_dt
  (p_acpt_clm_rqsts_thru_dt => p_rec.acpt_clm_rqsts_thru_dt,
   p_py_clms_thru_dt        => p_rec.py_clms_thru_dt,
   p_yr_perd_id             => p_rec.yr_perd_id,
   p_popl_yr_perd_id        => p_rec.popl_yr_perd_id,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_py_clms_thru_dt
  (p_acpt_clm_rqsts_thru_dt => p_rec.acpt_clm_rqsts_thru_dt,
   p_py_clms_thru_dt        => p_rec.py_clms_thru_dt,
   p_yr_perd_id             => p_rec.yr_perd_id,
   p_popl_yr_perd_id        => p_rec.popl_yr_perd_id,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_ordr_num_unique
  (p_popl_yr_perd_id        => p_rec.popl_yr_perd_id,
   p_pl_id                  => p_rec.pl_id,
   /* bug 2923047 */
   p_pgm_id                 => p_rec.pgm_id,
   p_ordr_num               => p_rec.ordr_num,
   p_business_group_id      => p_rec.business_group_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_cpy_shd.g_rec_type) is
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
  chk_popl_yr_perd_id
  (p_popl_yr_perd_id       => p_rec.popl_yr_perd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_yr_perd_id
  (p_popl_yr_perd_id       => p_rec.popl_yr_perd_id,
   p_yr_perd_id            => p_rec.yr_perd_id,
   p_object_version_number => p_rec.object_version_number,
  --Bug 3985729
   p_ordr_num              => p_rec.ordr_num);
  --
  chk_pgm_pl_id
  (p_pgm_id       => p_rec.pgm_id,
   p_pl_id        => p_rec.pl_id);
  --
  chk_pgm_pl_yr_perd_id
  (p_popl_yr_perd_id       => p_rec.popl_yr_perd_id,
   p_pgm_id                => p_rec.pgm_id,
   p_pl_id                 => p_rec.pl_id,
   p_business_group_id     => p_rec.business_group_id,
   p_yr_perd_id            => p_rec.yr_perd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_acpt_clm_rqsts_thru_dt
  (p_acpt_clm_rqsts_thru_dt => p_rec.acpt_clm_rqsts_thru_dt,
   p_py_clms_thru_dt        => p_rec.py_clms_thru_dt,
   p_yr_perd_id             => p_rec.yr_perd_id,
   p_popl_yr_perd_id        => p_rec.popl_yr_perd_id,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_py_clms_thru_dt
  (p_acpt_clm_rqsts_thru_dt => p_rec.acpt_clm_rqsts_thru_dt,
   p_py_clms_thru_dt        => p_rec.py_clms_thru_dt,
   p_yr_perd_id             => p_rec.yr_perd_id,
   p_popl_yr_perd_id        => p_rec.popl_yr_perd_id,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_ordr_num_unique
  (p_popl_yr_perd_id        => p_rec.popl_yr_perd_id,
   p_pl_id                  => p_rec.pl_id,
   /* bug 2923047 */
   p_pgm_id                 => p_rec.pgm_id,
   p_ordr_num               => p_rec.ordr_num,
   p_business_group_id      => p_rec.business_group_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_cpy_shd.g_rec_type) is
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
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_popl_yr_perd_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_popl_yr_perd b
    where b.popl_yr_perd_id      = p_popl_yr_perd_id
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
                             p_argument       => 'popl_yr_perd_id',
                             p_argument_value => p_popl_yr_perd_id);
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
end ben_cpy_bus;

/
