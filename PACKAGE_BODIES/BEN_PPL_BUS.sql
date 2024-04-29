--------------------------------------------------------
--  DDL for Package Body BEN_PPL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PPL_BUS" as
/* $Header: bepplrhi.pkb 120.0.12000000.3 2007/02/08 07:41:23 vborkar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ppl_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_ptnl_ler_for_per_id >--------------------------|
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
--   ptnl_ler_for_per_id PK of record being inserted or updated.
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
Procedure chk_ptnl_ler_for_per_id(p_ptnl_ler_for_per_id   in number,
                                  p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ptnl_ler_for_per_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ppl_shd.api_updating
    (p_ptnl_ler_for_per_id         => p_ptnl_ler_for_per_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ptnl_ler_for_per_id,hr_api.g_number)
     <>  ben_ppl_shd.g_old_rec.ptnl_ler_for_per_id) then
    --
    -- raise error as PK has changed
    --
    ben_ppl_shd.constraint_error('BEN_PTNL_LER_FOR_PER_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ptnl_ler_for_per_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_ppl_shd.constraint_error('BEN_PTNL_LER_FOR_PER_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ptnl_ler_for_per_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< chk_ler_id >----------------------------|
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
--   p_ptnl_ler_for_per_id PK
--   p_ler_id ID of FK column
--   p_effective_date Session Date of record
--   p_object_version_number object version number
--   p_enrt_perd_id ID of FK column
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
Procedure chk_ler_id (p_ptnl_ler_for_per_id   in number,
                      p_ler_id                in number,
                      p_enrt_perd_id          in number,
                      p_effective_date        in date,
                      p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ler_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_typ_cd       ben_ler_f.typ_cd%type;
  --
  cursor c1 is
    select a.typ_cd
    from   ben_ler_f a
    where  a.ler_id = p_ler_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_ppl_shd.api_updating
     (p_ptnl_ler_for_per_id     => p_ptnl_ler_for_per_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ler_id,hr_api.g_number)
     <> nvl(ben_ppl_shd.g_old_rec.ler_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if ler_id value exists in ben_ler_f table
    --
    open c1;
      --
      fetch c1 into l_typ_cd;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_ler_f
        -- table.
        --
        ben_ppl_shd.constraint_error('BEN_PTNL_LER_FOR_PER_DT1');
        --
      else
        --
        if  l_typ_cd  = 'CHECKLIST' then
          --
          fnd_message.set_name('BEN','BEN_94161_CHKLST_IN_PTNL_LE');
          fnd_message.raise_error;
        end if ;
        null;
/*
        -- PB : 5422 :
        if (l_api_updating
           and nvl(p_enrt_perd_id,hr_api.g_number)
           = nvl(ben_ppl_shd.g_old_rec.enrt_perd_id,hr_api.g_number)
           or (not l_api_updating and p_enrt_perd_id is null ))  and
           (l_typ_cd like 'SCHEDD%' and l_typ_cd <> 'SCHEDDU')
        then
          --
          -- if enrt_perd_id value supplied then life event must
          -- be of schedule type
          --
          fnd_message.set_name('BEN','BEN_91249_ENRT_PERD_ID_NULL');
          fnd_message.raise_error;
          --
        end if;
*/
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ler_id;
/*
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_unique_ler >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that for a given person no two records can have
--   same occured on date and same ler id and same status code.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--
-- p_business_group_id in number
--p_person_id in number
--p_ler_id in number
--p_lf_evt_ocrd_dt in date
--p_ptnl_ler_for_per_stat_cd in char
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
procedure chk_unique_ler(p_business_group_id in number
                         ,p_person_id in number
                         ,p_ler_id in number
                         ,p_lf_evt_ocrd_dt in date
                         ,p_ptnl_ler_for_per_stat_cd in varchar2
                         ,p_object_version_number in number
                         ,p_ptnl_ler_for_per_id in number)
is
   l_proc   varchar2(72) := g_package||' chk_unique_ler ';
   l_dummy  char(1);
   l_api_updating boolean;
   --
   cursor c1 is
   select null from ben_ptnl_ler_for_per
   where person_id = p_person_id
   and   ler_id = p_ler_id
   and   lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
   and   ptnl_ler_for_per_stat_cd = p_ptnl_ler_for_per_stat_cd
   and   ptnl_ler_for_per_stat_cd not in ('VOIDD', 'BCKDT')
   and   business_group_id = p_business_group_id;

begin
   hr_utility.set_location('Entering' || l_proc,5);
   --
  l_api_updating := ben_ppl_shd.api_updating
     (p_ptnl_ler_for_per_id     => p_ptnl_ler_for_per_id,
      p_object_version_number   => p_object_version_number);
  --
  if ((l_api_updating
       and (nvl(p_ler_id,hr_api.g_number)
            <> nvl(ben_ppl_shd.g_old_rec.ler_id,hr_api.g_number)
            or nvl(p_lf_evt_ocrd_dt,hr_api.g_date)
            <> nvl(ben_ppl_shd.g_old_rec.lf_evt_ocrd_dt,hr_api.g_date)
            or nvl(p_ptnl_ler_for_per_stat_cd,hr_api.g_varchar2)
            <> nvl(ben_ppl_shd.g_old_rec.ptnl_ler_for_per_stat_cd,hr_api.g_varchar2)
           )
      )
      or not l_api_updating) then
     --
     open c1;
     fetch c1 into l_dummy;
     if (c1%found) then
        fnd_message.set_name('BEN', 'BEN_92495_NOT_UNQ_PER_PTNL_LER');
        fnd_message.raise_error;
     end if;
     --
   end if;
   hr_utility.set_location('Leaving' || l_proc,15);
   close c1;

end chk_unique_ler;
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_csd_by_ptnl_ler_for_per_id >---------------------------|
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
--   p_ptnl_ler_for_per_id PK
--   p_csd_by_ptnl_ler_for_per_id ID of FK column
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
Procedure chk_csd_by_ptnl_ler_for_per_id (p_ptnl_ler_for_per_id   in number,
                            p_csd_by_ptnl_ler_for_per_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_csd_by_ptnl_ler_for_per_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ptnl_ler_for_per a
    where  a.ptnl_ler_for_per_id = p_csd_by_ptnl_ler_for_per_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_ppl_shd.api_updating
     (p_ptnl_ler_for_per_id     => p_ptnl_ler_for_per_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_csd_by_ptnl_ler_for_per_id,hr_api.g_number)
     <> nvl(ben_ppl_shd.g_old_rec.csd_by_ptnl_ler_for_per_id,hr_api.g_number)
     or (not l_api_updating and p_csd_by_ptnl_ler_for_per_id is not null )) then
    --
    -- check if csd_by_ptnl_ler_for_per_id value exists in ben_enrt_perd table
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
        ben_ppl_shd.constraint_error('BEN_PTNL_LER_FOR_PER_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_csd_by_ptnl_ler_for_per_id;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_enrt_perd_id >---------------------------|
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
--   p_ptnl_ler_for_per_id PK
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
Procedure chk_enrt_perd_id (p_ptnl_ler_for_per_id   in number,
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
  l_api_updating := ben_ppl_shd.api_updating
     (p_ptnl_ler_for_per_id     => p_ptnl_ler_for_per_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_enrt_perd_id,hr_api.g_number)
     <> nvl(ben_ppl_shd.g_old_rec.enrt_perd_id,hr_api.g_number)
     or (not l_api_updating and p_enrt_perd_id is not null )) then
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
        ben_ppl_shd.constraint_error('BEN_PTNL_LER_FOR_PER_FK1');
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
-- |---------------------------< chk_person_id >------------------------------|
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
--   p_ptnl_ler_for_per_id PK
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
Procedure chk_person_id (p_ptnl_ler_for_per_id   in number,
                         p_person_id             in number,
                         p_effective_date        in date,
			 p_lf_evt_ocrd_dt        in date,     /* Bug 5672925 */
                         p_ler_id                in number,   --5747460
                         p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_person_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_date date;
  l_person_id number;

  --5747460
  cursor c_cobra_evt_flag is
    select ler.qualg_evt_flag
    from   ben_ler_f ler
    where  ler.ler_id = p_ler_id
    and    p_effective_date between ler.effective_start_date and ler.effective_end_date;
  l_cobra_evt_flag varchar2(30);
  --
  --
  -- Bug 5672925 : Modified cursor C1 and C2 to check existence of PER_ALL_PEOPLE_F record
  --               as of LF_EVT_OCRD_DT instead of EFFECTIVE_DATE. The problem is, if a person
  --               is created on 01-Jan-2002 and the latest start date on Person form is changed
  --               to 06-Jan-2002, then before we create PPL record, the EFFECTIVE_START_DATE
  --               of PER_ALL_PEOPLE_F record is already changed to 06-Jan-2002, and hence C1, C2
  --               would fail on EFFECTIVE_DATE
  --
  cursor c1(l_person_id number,
            l_cobra_flag varchar2) is
    select null
    from   per_all_people_f a
    where  a.person_id = l_person_id
    and    decode(l_cobra_flag, 'Y', p_effective_date, p_lf_evt_ocrd_dt)  /* Bug 5672925 + 5747460*/
           between a.effective_start_date
           and     a.effective_end_date;
  -- Added cursor for bug 3652731
  cursor c2(l_cobra_flag varchar2) is
    select contact_person_id
    from   per_contact_relationships a
    where  a.person_id = p_person_id
    and    decode(l_cobra_flag, 'Y', p_effective_date, p_lf_evt_ocrd_dt)  /* Bug 5672925 + 5747460*/
           between a.date_start
           and nvl(a.date_end,to_date('31-12-4712','DD-MM-YYYY'));
  --
  cursor c3 is
	select effective_start_date from per_all_people_f
	where person_id = p_person_id;

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  /*
  hr_utility.set_location('p_person_id: '||p_person_id,5);
  hr_utility.set_location('p_ptnl_ler_for_per_id: '||p_ptnl_ler_for_per_id,5);
  hr_utility.set_location('p_effective_date: '||p_effective_date,5);
  hr_utility.set_location('p_object_version_number: '||p_object_version_number,5);
  */
  --
  l_api_updating := ben_ppl_shd.api_updating
     (p_ptnl_ler_for_per_id     => p_ptnl_ler_for_per_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
  and nvl(p_person_id,hr_api.g_number)
  <> nvl(ben_ppl_shd.g_old_rec.person_id,hr_api.g_number)
  or not l_api_updating) then
  --
    -- check if person_id value exists in per_all_people_f table
    hr_utility.set_location('ace p_lf_evt_ocrd_dt = ' || p_lf_evt_ocrd_dt, 9999);
    hr_utility.set_location('p_effective_date = ' || p_effective_date, 9999);
    l_person_id := p_person_id;

    -- 5747460: Get COBRA Qualifying Event flag
    -- If this flag is 'Y' then person record will be checked against effective date
    -- and not lf_evt_dt. This is because COBRA events are generally created prior to person record.
    open c_cobra_evt_flag;
    fetch c_cobra_evt_flag into l_cobra_evt_flag;
    close c_cobra_evt_flag;
    hr_utility.set_location('l_cobra_evt_flag = ' || l_cobra_evt_flag, 9999);
    --
    open c1(l_person_id, l_cobra_evt_flag);
    --
    fetch c1 into l_dummy;
    if c1%notfound then
    --
      close c1;
      --
      -- If the given person_id is not there in per_all_people_f
      -- in the given date, then it could be a contact id
      -- check if the id exists in per_contact_relationships table
      -- cursor c3 is for debug purpose
      open c3;
      fetch c3 into l_date;
      close c3;
      hr_utility.set_location('ESD of contact at this point : '||l_date,5.5);
      open c2(l_cobra_evt_flag);
      --
      fetch c2 into l_person_id;
      if c2%notfound then
        -- raise error as FK does not relate to PK in per_all_people_f
        -- or per_contact_relationships
        -- table.
        --
        close c2;
        hr_utility.set_location('p_person_id: '||p_person_id,5.5);
        ben_ppl_shd.constraint_error('BEN_PTNL_LER_FOR_PER_DT2');
        --
      else
        open c1(l_person_id, l_cobra_evt_flag);
        fetch c1 into l_dummy;
        if c1%notfound then
          close c1;
          hr_utility.set_location('p_person_id: '||p_person_id,5.5);
          ben_ppl_shd.constraint_error('BEN_PTNL_LER_FOR_PER_DT2');
        else
          close c1;
        end if;
      end if; --end c2
      close c2;
    else
      close c1;
    end if; -- end c1
  --
  end if; --end l_api_updating
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_person_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_ptnl_ler_for_per_src_cd >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptnl_ler_for_per_id PK of record being inserted or updated.
--   ptnl_ler_for_per_src_cd Value of lookup code.
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
Procedure chk_ptnl_ler_for_per_src_cd(p_ptnl_ler_for_per_id     in number,
                                      p_ptnl_ler_for_per_src_cd in varchar2,
                                      p_effective_date          in date,
                                      p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ptnl_ler_for_per_src_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ppl_shd.api_updating
    (p_ptnl_ler_for_per_id         => p_ptnl_ler_for_per_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_ptnl_ler_for_per_src_cd
      <> nvl(ben_ppl_shd.g_old_rec.ptnl_ler_for_per_src_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_ptnl_ler_for_per_src_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PTNL_LER_FOR_PER_SRC',
           p_lookup_code    => p_ptnl_ler_for_per_src_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_ptnl_ler_for_per_src_cd');
      fnd_message.set_token('TYPE','BEN_PTNL_LER_FOR_PER_SRC');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_ptnl_ler_for_per_src_cd;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_ptnl_ler_for_per_stat_cd >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptnl_ler_for_per_id PK of record being inserted or updated.
--   ptnl_ler_for_per_stat_cd Value of lookup code.
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
Procedure chk_ptnl_ler_for_per_stat_cd(p_ptnl_ler_for_per_id      in number,
                                       p_ptnl_ler_for_per_stat_cd in varchar2,
                                       p_effective_date           in date,
                                       p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ptnl_ler_for_per_stat_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ppl_shd.api_updating
    (p_ptnl_ler_for_per_id         => p_ptnl_ler_for_per_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_ptnl_ler_for_per_stat_cd
      <> nvl(ben_ppl_shd.g_old_rec.ptnl_ler_for_per_stat_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PTNL_LER_FOR_PER_STAT',
           p_lookup_code    => p_ptnl_ler_for_per_stat_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_ptnl_ler_for_per_stat_cd');
      fnd_message.set_token('TYPE','BEN_PTNL_LER_FOR_PER_STAT');
      fnd_message.raise_error;
      --
    end if;
    --
    -- Check the PPL status code transitions
    --
    if not l_api_updating
      and p_ptnl_ler_for_per_stat_cd not in ('DTCTD', 'UNPROCD') then
      --
      hr_utility.set_location('Creation: '||l_proc, 10);
      fnd_message.set_name('BEN','BEN_92162_INV_PPL_STCD_TRANS');
      fnd_message.raise_error;
      --
    elsif l_api_updating
      and ben_ppl_shd.g_old_rec.ptnl_ler_for_per_stat_cd = 'DTCTD'
      and p_ptnl_ler_for_per_stat_cd not in ('PROCD', 'VOIDD','MNL') then
      --
      hr_utility.set_location('DTCTD: '||l_proc, 10);
      fnd_message.set_name('BEN','BEN_92162_INV_PPL_STCD_TRANS');
      fnd_message.raise_error;
      --
    elsif l_api_updating
      and ben_ppl_shd.g_old_rec.ptnl_ler_for_per_stat_cd = 'UNPROCD'
      and p_ptnl_ler_for_per_stat_cd not in ('PROCD', 'VOIDD','MNL') then
      --
      hr_utility.set_location('UNPROCD: '||l_proc, 10);
      fnd_message.set_name('BEN','BEN_92162_INV_PPL_STCD_TRANS');
      fnd_message.raise_error;
      --
    elsif l_api_updating
      and ben_ppl_shd.g_old_rec.ptnl_ler_for_per_stat_cd = 'VOIDD'
      and p_ptnl_ler_for_per_stat_cd not in ('UNPROCD','MNL') then
      --
      hr_utility.set_location('VOIDD: '||l_proc, 10);
      fnd_message.set_name('BEN','BEN_92162_INV_PPL_STCD_TRANS');
      fnd_message.raise_error;
      --
    elsif l_api_updating
      and ben_ppl_shd.g_old_rec.ptnl_ler_for_per_stat_cd = 'PROCD'
      and p_ptnl_ler_for_per_stat_cd not in ('UNPROCD','MNL','VOIDD') then
      --
      hr_utility.set_location('PROCD: '||l_proc, 10);
      fnd_message.set_name('BEN','BEN_92162_INV_PPL_STCD_TRANS');
      fnd_message.raise_error;
      --
    elsif l_api_updating
      and ben_ppl_shd.g_old_rec.ptnl_ler_for_per_stat_cd = 'MNL'
      and p_ptnl_ler_for_per_stat_cd not in ('UNPROCD','VOIDD','MNLO') then
      --
      hr_utility.set_location('MNL: '||l_proc, 10);
      fnd_message.set_name('BEN','BEN_92162_INV_PPL_STCD_TRANS');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,100);
  --
end chk_ptnl_ler_for_per_stat_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_delete_allowed >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the record can be deleted if there
--   is no corresponding real life event out there for that record.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptnl_ler_for_per_id      PK of record being inserted or updated.
--   ptnl_ler_for_per_stat_cd Value of lookup code.
--   person_id                FK of person.
--   ler_id                   FK of ler.
--   lf_evt_ocrd_dt           Life event occured date.
--   effective_date           effective date
--   object_version_number    Object version number of record being
--                            inserted or updated.
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
function chk_delete_allowed
  (p_ptnl_ler_for_per_id      in number,
   p_ptnl_ler_for_per_stat_cd in varchar2,
   p_business_group_id        in number,
   p_person_id                in number,
   p_ler_id                   in number,
   p_lf_evt_ocrd_dt           in date) return boolean is
  --
  cursor c1 is
    select null
    from   ben_per_in_ler pil
    where  pil.person_id = p_person_id
    and    pil.business_group_id+0 = p_business_group_id
    and    pil.ler_id = p_ler_id
    and    pil.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;
  --
  l_proc         varchar2(72) := g_package||'chk_delete_allowed';
  l_dummy        varchar2(1);
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_ptnl_ler_for_per_stat_cd = 'PROCD' then
    --
    -- Check if we can delete the record.
    --
    open c1;
      --
      fetch c1 into l_dummy;
      --
      if c1%found then
        --
        -- per for ler exists and we are trying to delete potential
        -- bad move so error.
        --
        close c1;
        return false;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
  return true;
  --
end chk_delete_allowed;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_date_validity >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the date is filled in for the current
--   status code that has been passed in.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptnl_ler_for_per_stat_cd Value of lookup code.
--   dtctd_dt                 date
--   unprocd_dt               date
--   procd_dt                 date
--   voidd_dt                 date
--   mnl_dt                   date
--   mnlo_dt                  date
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
procedure chk_date_validity
  (p_ptnl_ler_for_per_stat_cd in varchar2,
   p_dtctd_dt                 in date,
   p_unprocd_dt               in date,
   p_procd_dt                 in date,
   p_voidd_dt                 in date,
   p_mnl_dt                   in date,
   p_mnlo_dt                  in date) is
  --
  l_proc         varchar2(72) := g_package||'chk_delete_allowed';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_ptnl_ler_for_per_stat_cd = 'PROCD' and
    p_procd_dt is null then
    --
    fnd_message.set_name('BEN','BEN_92329_PROCD_DATE_NULL');
    fnd_message.raise_error;
    --
  elsif p_ptnl_ler_for_per_stat_cd = 'VOIDD' and
    p_voidd_dt is null then
    --
    fnd_message.set_name('BEN','BEN_92330_VOIDD_DATE_NULL');
    fnd_message.raise_error;
    --
  elsif p_ptnl_ler_for_per_stat_cd = 'UNPROCD' and
    p_unprocd_dt is null then
    --
    fnd_message.set_name('BEN','BEN_92331_UNPROCD_DATE_NULL');
    fnd_message.raise_error;
    --
  elsif p_ptnl_ler_for_per_stat_cd = 'DTCTD' and
    p_dtctd_dt is null then
    --
    fnd_message.set_name('BEN','BEN_92332_DTCTD_DATE_NULL');
    fnd_message.raise_error;
    --
  elsif p_ptnl_ler_for_per_stat_cd = 'MNL' and
    p_mnl_dt is null then
    --
    fnd_message.set_name('BEN','BEN_92333_MNL_DATE_NULL');
    fnd_message.raise_error;
    --
  elsif p_ptnl_ler_for_per_stat_cd = 'MNLO' and
    p_mnlo_dt is null then
    --
    fnd_message.set_name('BEN','BEN_92334_MNLO_DATE_NULL');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_date_validity;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_ppl_shd.g_rec_type
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
  chk_ptnl_ler_for_per_id
  (p_ptnl_ler_for_per_id   => p_rec.ptnl_ler_for_per_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_perd_id
  (p_ptnl_ler_for_per_id   => p_rec.ptnl_ler_for_per_id,
   p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_csd_by_ptnl_ler_for_per_id
  (p_ptnl_ler_for_per_id   => p_rec.ptnl_ler_for_per_id,
   p_csd_by_ptnl_ler_for_per_id          => p_rec.csd_by_ptnl_ler_for_per_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ler_id
  (p_ptnl_ler_for_per_id   => p_rec.ptnl_ler_for_per_id,
   p_ler_id                => p_rec.ler_id,
   p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --

  chk_person_id
  (p_ptnl_ler_for_per_id   => p_rec.ptnl_ler_for_per_id,
   p_person_id             => p_rec.person_id,
   p_effective_date        => p_effective_date,
   p_lf_evt_ocrd_dt        => p_rec.lf_evt_ocrd_dt,    /* Bug 5672925 */
   p_ler_id                => p_rec.ler_id, --5747460
   p_object_version_number => p_rec.object_version_number);

  --
  chk_ptnl_ler_for_per_stat_cd
  (p_ptnl_ler_for_per_id      => p_rec.ptnl_ler_for_per_id,
   p_ptnl_ler_for_per_stat_cd => p_rec.ptnl_ler_for_per_stat_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_ptnl_ler_for_per_src_cd
  (p_ptnl_ler_for_per_id      => p_rec.ptnl_ler_for_per_id,
   p_ptnl_ler_for_per_src_cd  => p_rec.ptnl_ler_for_per_src_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_date_validity
  (p_ptnl_ler_for_per_stat_cd => p_rec.ptnl_ler_for_per_stat_cd,
   p_dtctd_dt                 => p_rec.dtctd_dt,
   p_unprocd_dt               => p_rec.unprocd_dt,
   p_procd_dt                 => p_rec.procd_dt,
   p_voidd_dt                 => p_rec.voidd_dt,
   p_mnl_dt                   => p_rec.mnl_dt,
   p_mnlo_dt                  => p_rec.mnlo_dt);
  --
  /*chk_unique_ler
   (p_business_group_id      => p_rec.business_group_id,
    p_ptnl_ler_for_per_id      => p_rec.ptnl_ler_for_per_id,
    p_person_id              => p_rec.person_id,
    p_ler_id                => p_rec.ler_id,
    p_lf_evt_ocrd_dt         => p_rec.lf_evt_ocrd_dt,
    p_object_version_number    => p_rec.object_version_number,
    p_ptnl_ler_for_per_stat_cd => p_rec.ptnl_ler_for_per_stat_cd);  */

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_ppl_shd.g_rec_type
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
  chk_ptnl_ler_for_per_id
  (p_ptnl_ler_for_per_id   => p_rec.ptnl_ler_for_per_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_perd_id
  (p_ptnl_ler_for_per_id   => p_rec.ptnl_ler_for_per_id,
   p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_csd_by_ptnl_ler_for_per_id
  (p_ptnl_ler_for_per_id   => p_rec.ptnl_ler_for_per_id,
   p_csd_by_ptnl_ler_for_per_id          => p_rec.csd_by_ptnl_ler_for_per_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ler_id
  (p_ptnl_ler_for_per_id   => p_rec.ptnl_ler_for_per_id,
   p_ler_id                => p_rec.ler_id,
   p_enrt_perd_id          => p_rec.enrt_perd_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_person_id
  (p_ptnl_ler_for_per_id   => p_rec.ptnl_ler_for_per_id,
   p_person_id             => p_rec.person_id,
   p_effective_date        => p_effective_date,
   p_lf_evt_ocrd_dt        => p_rec.lf_evt_ocrd_dt,    /* Bug 5672925 */
   p_ler_id                => p_rec.ler_id, --5747460
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ptnl_ler_for_per_stat_cd
  (p_ptnl_ler_for_per_id      => p_rec.ptnl_ler_for_per_id,
   p_ptnl_ler_for_per_stat_cd => p_rec.ptnl_ler_for_per_stat_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_ptnl_ler_for_per_src_cd
  (p_ptnl_ler_for_per_id      => p_rec.ptnl_ler_for_per_id,
   p_ptnl_ler_for_per_src_cd  => p_rec.ptnl_ler_for_per_src_cd,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_date_validity
  (p_ptnl_ler_for_per_stat_cd => p_rec.ptnl_ler_for_per_stat_cd,
   p_dtctd_dt                 => p_rec.dtctd_dt,
   p_unprocd_dt               => p_rec.unprocd_dt,
   p_procd_dt                 => p_rec.procd_dt,
   p_voidd_dt                 => p_rec.voidd_dt,
   p_mnl_dt                   => p_rec.mnl_dt,
   p_mnlo_dt                  => p_rec.mnlo_dt);
  --
  /* chk_unique_ler
   (p_business_group_id      => p_rec.business_group_id,
    p_ptnl_ler_for_per_id      => p_rec.ptnl_ler_for_per_id,
    p_person_id              => p_rec.person_id,
    p_ler_id                 => p_rec.ler_id,
    p_lf_evt_ocrd_dt         => p_rec.lf_evt_ocrd_dt,
    p_object_version_number    => p_rec.object_version_number,
    p_ptnl_ler_for_per_stat_cd => p_rec.ptnl_ler_for_per_stat_cd);  */
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_ppl_shd.g_rec_type
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
  (p_ptnl_ler_for_per_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ptnl_ler_for_per b
    where b.ptnl_ler_for_per_id      = p_ptnl_ler_for_per_id
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
                             p_argument       => 'ptnl_ler_for_per_id',
                             p_argument_value => p_ptnl_ler_for_per_id);
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
end ben_ppl_bus;

/
