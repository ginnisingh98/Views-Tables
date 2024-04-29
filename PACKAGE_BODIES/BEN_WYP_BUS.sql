--------------------------------------------------------
--  DDL for Package Body BEN_WYP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_WYP_BUS" as
/* $Header: bewyprhi.pkb 115.12 2003/01/01 00:03:22 mmudigon ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_wyp_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_wthn_yr_perd_id >------|
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
--   wthn_yr_perd_id PK of record being inserted or updated.
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
Procedure chk_wthn_yr_perd_id(p_wthn_yr_perd_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_wthn_yr_perd_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_wyp_shd.api_updating
    (p_wthn_yr_perd_id                => p_wthn_yr_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_wthn_yr_perd_id,hr_api.g_number)
     <>  ben_wyp_shd.g_old_rec.wthn_yr_perd_id) then
    --
    -- raise error as PK has changed
    --
    ben_wyp_shd.constraint_error('BEN_WTHN_YR_PERD_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_wthn_yr_perd_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_wyp_shd.constraint_error('BEN_WTHN_YR_PERD_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_wthn_yr_perd_id;
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
--   p_wthn_yr_perd_id PK
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
Procedure chk_yr_perd_id (p_wthn_yr_perd_id          in number,
                            p_yr_perd_id          in number,
                            p_object_version_number in number) is
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
  l_api_updating := ben_wyp_shd.api_updating
     (p_wthn_yr_perd_id            => p_wthn_yr_perd_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_yr_perd_id,hr_api.g_number)
     <> nvl(ben_wyp_shd.g_old_rec.yr_perd_id,hr_api.g_number)
     or not l_api_updating) and
     p_yr_perd_id is not null then
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
        ben_wyp_shd.constraint_error('BEN_WTHN_YR_PERD_FK1');
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
-- |---------------< chk_day_and_month_validation >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   Ensures that the start month and end month fall within the start and
--   end dates.  Also ensures that the start day and end day fall within the
--   start and end dates.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_start_date
--     p_end_date
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
Procedure chk_day_and_month_validation
           (p_yr_perd_id            in number
           ,p_strt_day              in number
           ,p_strt_mo               in number
           ,p_end_day               in number
           ,p_end_mo                in number
           ,p_business_group_id     in number)
is
l_proc     varchar2(72) := g_package||'chk_day_and_month_validation';
strt_dd    number(2);
strt_mm    number(2);
end_dd     number(2);
end_mm     number(2);
l_perd_typ_cd  varchar2(30);
cursor c1 is select to_number(to_char(start_date, 'DD')) strt_dd,
                    to_number(to_char(start_date, 'MM')) strt_mm,
                    to_number(to_char(end_date, 'DD')) end_dd,
                    to_number(to_char(end_date, 'MM')) end_mm,
                    perd_typ_cd
               from ben_yr_perd
              where yr_perd_id = p_yr_perd_id
                and business_group_id = p_business_group_id;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into strt_dd, strt_mm, end_dd, end_mm , l_perd_typ_cd;
  close c1;

  if l_perd_typ_cd = 'CLNDR' then

    if p_strt_mo < strt_mm or p_strt_mo > end_mm then
        --
        fnd_message.set_name('BEN','BEN_92132_INVALID_START_MONTH');
        fnd_message.raise_error;
        --
    elsif p_end_mo > end_mm or p_end_mo < strt_mm then
        --
        fnd_message.set_name('BEN','BEN_92133_INVALID_END_MONTH');
        fnd_message.raise_error;
        --
    elsif p_end_mo < p_strt_mo then
        --
        fnd_message.set_name('BEN','BEN_92134_INVALID_MONTH_ORDER');
        fnd_message.raise_error;
        --
    end if;

    --
    if p_strt_mo = strt_mm then
     --
     if p_strt_day < strt_dd then
        --
        fnd_message.set_name('BEN','BEN_92135_INVALID_START_DAY');
        fnd_message.raise_error;
        --
     end if;
     --
    elsif p_end_mo = end_mm then
      --
       if p_end_day > end_dd then
        --
        fnd_message.set_name('BEN','BEN_92136_INVALID_END_DAY');
        fnd_message.raise_error;
        --
       end if;
       --
    end if;
    --

  -- Fix for Bug 1646921
  elsif l_perd_typ_cd = 'FISCAL' then


   -- Case I:  Plan Period fall within the same year

    if strt_mm < end_mm then

        if p_end_mo < p_strt_mo then
            --
            fnd_message.set_name('BEN','BEN_92134_INVALID_MONTH_ORDER');
            fnd_message.raise_error;
            --
        end if;
        if p_strt_mo < strt_mm then
            --
            fnd_message.set_name('BEN','BEN_92132_INVALID_START_MONTH');
            fnd_message.raise_error;
            --
        end if;
        if p_strt_mo = strt_mm and p_strt_day < strt_dd then
            --
            fnd_message.set_name('BEN','BEN_92135_INVALID_START_DAY');
            fnd_message.raise_error;
            --
        end if;

        if p_strt_mo > strt_mm then
            if p_strt_mo > end_mm then
                --
                fnd_message.set_name('BEN','BEN_92132_INVALID_START_MONTH');
                fnd_message.raise_error;
                --
            end if;

            if p_strt_mo = end_mm and p_strt_day > end_dd then
                --
                fnd_message.set_name('BEN','BEN_92135_INVALID_START_DAY');
                fnd_message.raise_error;
                --
            end if;
        end if;

        if p_end_mo > end_mm then
            --
            fnd_message.set_name('BEN','BEN_92133_INVALID_END_MONTH');
            fnd_message.raise_error;
            --
        end if;
        if p_end_mo = end_mm and p_end_day > end_dd then
            --
            fnd_message.set_name('BEN','BEN_92136_INVALID_END_DAY');
            fnd_message.raise_error;
            --
        end if;
        if p_end_mo <end_mm then
            if p_end_mo < strt_mm then
                --
                fnd_message.set_name('BEN','BEN_92133_INVALID_END_MONTH');
                fnd_message.raise_error;
                --
            end if;
            if p_end_mo = strt_mm and p_end_day < strt_dd then
                --
                fnd_message.set_name('BEN','BEN_92136_INVALID_END_DAY');
                fnd_message.raise_error;
                --
            end if;
        end if;

        if p_strt_mo = p_end_mo and p_strt_day > p_end_day then
            --
            fnd_message.set_name('BEN','BEN_92135_INVALID_START_DAY');
            fnd_message.raise_error;
            --
        end if;

    end if;


    -- Case II:  Plan Period span over years

    if (strt_mm > end_mm) or
       (strt_mm = end_mm and strt_dd > end_dd) then

        if p_strt_mo < strt_mm then

            if (p_strt_mo > end_mm)   or
               (p_end_mo  > strt_mm)  or
               (p_end_mo  < p_strt_mo) then
                --
                fnd_message.set_name('BEN','BEN_92132_INVALID_START_MONTH');
                fnd_message.raise_error;
                --
            end if;
            if p_strt_mo = end_mm and p_strt_day > end_dd then
                --
                fnd_message.set_name('BEN','BEN_92135_INVALID_START_DAY');
                fnd_message.raise_error;
                --
            end if;
            if p_end_mo = strt_mm and p_end_day > strt_dd then
                --
                fnd_message.set_name('BEN','BEN_92136_INVALID_END_DAY');
                fnd_message.raise_error;
                --
            end if;
        end if;

        if p_strt_mo = strt_mm then

            if p_strt_day < strt_dd then
                if p_end_mo < p_strt_mo or ( p_end_mo = p_strt_mo and p_end_day < p_strt_day) then
                    --
                    fnd_message.set_name('BEN','BEN_92135_INVALID_START_DAY');
                    fnd_message.raise_error;
                    --
                end if;

                if ( strt_mm <> end_mm ) or (strt_mm = end_mm and p_strt_day > end_dd) then
                    --
                    fnd_message.set_name('BEN','BEN_92135_INVALID_START_DAY');
                    fnd_message.raise_error;
                    --
                end if;
            end if;
        end if;

        if p_end_mo > end_mm then

            if (p_end_mo < strt_mm) or
               (p_strt_mo < end_mm) or
               (p_strt_mo > p_end_mo) then
                --
                fnd_message.set_name('BEN','BEN_92133_INVALID_END_MONTH');
                fnd_message.raise_error;
                --
            end if;
            if p_end_mo = strt_mm and p_end_day < strt_dd then
                --
                fnd_message.set_name('BEN','BEN_92136_INVALID_END_DAY');
                fnd_message.raise_error;
                --
            end if;
            if p_strt_mo = end_mm and p_strt_day < end_dd then
                --
                fnd_message.set_name('BEN','BEN_92135_INVALID_START_DAY');
                fnd_message.raise_error;
                --
            end if;


        end if;

        if p_end_mo = end_mm then
            if p_end_day > end_dd then
                if p_strt_mo > p_end_mo or (p_strt_mo = p_end_mo and p_strt_day > p_end_day) then
                    --
                    fnd_message.set_name('BEN','BEN_92135_INVALID_START_DAY');
                    fnd_message.raise_error;
                    --
                end if;

                if ( end_mm <> strt_mm ) or ( end_mm = strt_mm and p_end_day < strt_dd ) then
                    --
                    fnd_message.set_name('BEN','BEN_92136_INVALID_END_DAY');
                    fnd_message.raise_error;
                    --
                end if;
             end if;
        end if;
    end if;


    -- Case III Plan Year falls within the same month

    if strt_mm = end_mm and strt_dd <= end_dd then

        if (p_strt_mo <> strt_mm) then
            --
            fnd_message.set_name('BEN','BEN_92132_INVALID_START_MONTH');
            fnd_message.raise_error;
            --
        end if;
        if (p_end_mo <> end_mm) then
            --
            fnd_message.set_name('BEN','BEN_92133_INVALID_END_MONTH');
            fnd_message.raise_error;
            --
        end if;

        if p_strt_day < strt_dd or p_strt_day > p_end_day then
            --
            fnd_message.set_name('BEN','BEN_92135_INVALID_START_DAY');
            fnd_message.raise_error;
            --
        end if;
        if p_end_day > end_dd then
            --
            fnd_message.set_name('BEN','BEN_92136_INVALID_END_DAY');
            fnd_message.raise_error;
            --
        end if;

    end if;
    -- End of fix, Bug 1646921

 end if;

hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_day_and_month_validation;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_no_overlapping >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the starting dates and ending dates
--   do not overlap within the same unit of measure
--   on insert and update.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   wthn_yr_perd_id PK of record being inserted or updated
--   strt_day  Starting Day
--   strt_mo   Starting Month
--   end_day   Ending Day
--   end_mo    Ending Month
--   business_group_id  of the record beeing inserted or updated
--   effective_date effective date of the session
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
Procedure chk_no_overlapping(p_wthn_yr_perd_id       in number
                            ,p_yr_perd_id            in number
                            ,p_strt_day              in number
                            ,p_strt_mo               in number
                            ,p_end_day               in number
                            ,p_end_mo                in number
                            ,p_tm_uom                in varchar2
                            ,p_business_group_id     in number) is
  --
  l_proc              varchar2(72) := g_package||'chk_no_overlapping';
  existing_strt_dd    number(2);
  existing_strt_mm    number(2);
  existing_end_dd     number(2);
  existing_end_mm     number(2);
  --
  --
  cursor uom is
     select strt_day, strt_mo, end_day, end_mo
        from ben_wthn_yr_perd
        where tm_uom = p_tm_uom
          and yr_perd_id = p_yr_perd_id
          and wthn_yr_perd_id <> nvl(p_wthn_yr_perd_id, hr_api.g_number)
          and business_group_id + 0 = p_business_group_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check if this combination of dates overlaps within the same uom
  --
  open uom;
    --
    loop
      --
      fetch uom into existing_strt_dd,
                     existing_strt_mm,
                     existing_end_dd,
                     existing_end_mm;
      exit when uom%notfound;
      --
      if (p_strt_mo < existing_end_mm and p_strt_mo > existing_strt_mm) or
        (p_end_mo > existing_strt_mm and p_end_mo < existing_end_mm) then
        --
        close uom;
        fnd_message.set_name('BEN','BEN_92352_MAY_NOT_OVERLAP');
        fnd_message.raise_error;
        --
      elsif p_strt_mo = existing_strt_mm then
        --
        if p_strt_mo = existing_end_mm then
          --
          if p_strt_day < existing_end_dd then
            --
            close uom;
            fnd_message.set_name('BEN','BEN_92352_MAY_NOT_OVERLAP');
            fnd_message.raise_error;
            --
          end if;
          --
        else
          --
          if p_strt_day > existing_strt_dd then
            --
            close uom;
            fnd_message.set_name('BEN','BEN_92352_MAY_NOT_OVERLAP');
            fnd_message.raise_error;
            --
          end if;
          --
        end if;
        --
      elsif p_strt_mo = existing_end_mm then
        --
        if p_strt_day <= existing_end_dd then
          --
          close uom;
          fnd_message.set_name('BEN','BEN_92352_MAY_NOT_OVERLAP');
          fnd_message.raise_error;
          --
        end if;
        --
      elsif p_end_mo = existing_strt_mm then
        --
        if p_end_day > existing_strt_dd then
          --
          close uom;
          fnd_message.set_name('BEN','BEN_92352_MAY_NOT_OVERLAP');
          fnd_message.raise_error;
          --
        end if;
        --
      elsif p_end_mo = existing_end_mm then
        --
        if p_end_day < existing_end_dd then
          --
          close uom;
          fnd_message.set_name('BEN','BEN_92352_MAY_NOT_OVERLAP');
          fnd_message.raise_error;
          --
        end if;
        --
      end if;
      --
    end loop;
    --
  close uom;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
End chk_no_overlapping;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_unique_combination >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the starting dates and ending dates
--   do not overlap within the same unit of measure
--   on insert and update.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   wthn_yr_perd_id PK of record being inserted or updated
--   strt_day  Starting Day
--   strt_mo   Starting Month
--   end_day   Ending Day
--   end_mo    Ending Month
--   business_group_id  of the record beeing inserted or updated
--   effective_date effective date of the session
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
--
-- Bug 2167540: Added p_yr_perd_id to chk_unique_combination procedure
--
Procedure chk_unique_combination(p_wthn_yr_perd_id       in number
                                ,p_yr_perd_id            in number
                                ,p_strt_day              in number
                                ,p_strt_mo               in number
                                ,p_end_day               in number
                                ,p_end_mo                in number
                                ,p_tm_uom                in varchar2
                                ,p_business_group_id     in number) is
  --
  l_proc      varchar2(72) := g_package||'chk_unique_combination';
  l_exists    char(1);
  --
  cursor c1 is
       select null
         from ben_wthn_yr_perd
        where tm_uom = p_tm_uom
          and yr_perd_id = p_yr_perd_id
          and strt_day = p_strt_day
          and strt_mo = p_strt_mo
          and end_day = p_end_day
          and end_mo = p_end_mo
          and wthn_yr_perd_id <> nvl(p_wthn_yr_perd_id, hr_api.g_number)
          and business_group_id + 0 = p_business_group_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
    -- check if this combination already exists within the same uom
    --
    open c1;
    fetch c1 into l_exists;
    if c1%found then
      close c1;

      -- raise error as that combination of starting day, starting
      -- month, ending day and ending month already exists within
      -- the selected uom
      --
      fnd_message.set_name('BEN','BEN_92351_COMBO_NOT_UNIQUE');
      fnd_message.raise_error;
      --
    end if;
    --
    close c1;
    --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
End chk_unique_combination;
--
-- ----------------------------------------------------------------------------
-- |------< chk_tm_uom >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   wthn_yr_perd_id PK of record being inserted or updated.
--   tm_uom Value of lookup code.
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
Procedure chk_tm_uom(p_wthn_yr_perd_id             in number,
                     p_tm_uom                      in varchar2,
                     p_effective_date              in date,
                     p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_tm_uom';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_wyp_shd.api_updating
    (p_wthn_yr_perd_id             => p_wthn_yr_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_tm_uom
      <> nvl(ben_wyp_shd.g_old_rec.tm_uom,hr_api.g_varchar2)
      or not l_api_updating)
      and p_tm_uom is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_TM_UOM',
           p_lookup_code    => p_tm_uom,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_tm_uom');
      fnd_message.set_token('TYPE', 'BEN_TM_UOM');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_tm_uom;
--

--
-- ----------------------------------------------------------------------------
-- |---------------< chk_valid_date >------------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   Ensures that the Start Day and Start Month are valid dates in the
--   selected Year period. Also endures that the End Day and End Month are
--   valid dates in the selected Year period.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_day
--     p_month
--     p_type
--     p_yr_perd_id
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
Procedure chk_valid_date
           (p_day                   in number
           ,p_month                 in number
           ,p_type                  in varchar2
           ,p_yr_perd_id            in number
           ,p_business_group_id     in number)
is
l_proc       varchar2(72) := g_package||'chk_valid_date';
l_strt_dd    number(2);
l_strt_mm    number(2);
l_strt_yy    number(4);
l_end_dd     number(2);
l_end_mm     number(2);
l_end_yy     number(4);

l_year       number(4);
l_date_str   varchar2(10);
l_valid_date date;

cursor c1 is select to_number(to_char(start_date, 'DD')) l_strt_dd,
                    to_number(to_char(start_date, 'MM')) l_strt_mm,
                    to_number(to_char(start_date, 'YYYY')) l_strt_yy,
                    to_number(to_char(end_date, 'DD')) l_end_dd,
                    to_number(to_char(end_date, 'MM')) l_end_mm,
                    to_number(to_char(end_date, 'YYYY')) l_end_yy
             from ben_yr_perd
             where yr_perd_id = p_yr_perd_id
             and business_group_id = p_business_group_id;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into l_strt_dd, l_strt_mm, l_strt_yy,l_end_dd, l_end_mm,l_end_yy;
  close c1;
  --

  -- From the Year period, determine the Year in which the user entered Month falls

  if l_strt_yy = l_end_yy then
    l_year := l_strt_yy;
  elsif p_month between l_strt_mm and 12 then
    l_year := l_strt_yy;
  else
    l_year := l_end_yy;
  end if;

  l_date_str := l_year||'/'||p_month||'/'||p_day;

  --
  -- check if the date is valid
  --

  begin
    l_valid_date := fnd_date.canonical_to_date(l_date_str);
  exception
    when others then
      --
      -- raise error as the date is not valid.
      --
      fnd_message.set_name('BEN','BEN_93012_INVALID_DATE');
      fnd_message.set_token('TYPE', p_type);
      fnd_message.raise_error;
  end;

  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_valid_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_wyp_shd.g_rec_type
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
  chk_wthn_yr_perd_id
  (p_wthn_yr_perd_id       => p_rec.wthn_yr_perd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_yr_perd_id
  (p_wthn_yr_perd_id       => p_rec.wthn_yr_perd_id,
   p_yr_perd_id            => p_rec.yr_perd_id,
   p_object_version_number => p_rec.object_version_number);
  --

  -- Bug - 2248735 Check for valid Within Year Period Start and End Dates

  chk_valid_date
  (p_day                   => p_rec.strt_day,
   p_month                 => p_rec.strt_mo,
   p_type                  => 'Start',
   p_yr_perd_id            => p_rec.yr_perd_id,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_valid_date
  (p_day                   => p_rec.end_day,
   p_month                 => p_rec.end_mo,
   p_type                  => 'End',
   p_yr_perd_id            => p_rec.yr_perd_id,
   p_business_group_id     => p_rec.business_group_id);
  --
  -- End Bug 2248735

  --
  chk_day_and_month_validation
  (p_yr_perd_id            => p_rec.yr_perd_id,
   p_strt_day              => p_rec.strt_day,
   p_strt_mo               => p_rec.strt_mo,
   p_end_day               => p_rec.end_day,
   p_end_mo                => p_rec.end_mo,
   p_business_group_id     => p_rec.business_group_id);
  --
  -- Bug - 2167540  : Commented to allow overlapping of start and end values for CWB.
 /*
  chk_no_overlapping
  (p_wthn_yr_perd_id       => p_rec.wthn_yr_perd_id,
   p_yr_perd_id            => p_rec.yr_perd_id,
   p_strt_day              => p_rec.strt_day,
   p_strt_mo               => p_rec.strt_mo,
   p_end_day               => p_rec.end_day,
   p_end_mo                => p_rec.end_mo,
   p_tm_uom                => p_rec.tm_uom,
   p_business_group_id     => p_rec.business_group_id);
 */
  --
  --
  -- Bug 2167540: Added p_yr_perd_id to chk_unique_combination procedure
  --
  chk_unique_combination
  (p_wthn_yr_perd_id       => p_rec.wthn_yr_perd_id,
   p_yr_perd_id            => p_rec.yr_perd_id,
   p_strt_day              => p_rec.strt_day,
   p_strt_mo               => p_rec.strt_mo,
   p_end_day               => p_rec.end_day,
   p_end_mo                => p_rec.end_mo,
   p_tm_uom                => p_rec.tm_uom,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_tm_uom
  (p_wthn_yr_perd_id           => p_rec.wthn_yr_perd_id,
   p_tm_uom                    => p_rec.tm_uom,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_wyp_shd.g_rec_type
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
  chk_wthn_yr_perd_id
  (p_wthn_yr_perd_id          => p_rec.wthn_yr_perd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_yr_perd_id
  (p_wthn_yr_perd_id          => p_rec.wthn_yr_perd_id,
   p_yr_perd_id          => p_rec.yr_perd_id,
   p_object_version_number => p_rec.object_version_number);
  --

  -- Bug - 2248735 Check for valid Within Year Period Start and End Dates

  chk_valid_date
  (p_day                   => p_rec.strt_day,
   p_month                 => p_rec.strt_mo,
   p_type                  => 'Start',
   p_yr_perd_id            => p_rec.yr_perd_id,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_valid_date
  (p_day                   => p_rec.end_day,
   p_month                 => p_rec.end_mo,
   p_type                  => 'End',
   p_yr_perd_id            => p_rec.yr_perd_id,
   p_business_group_id     => p_rec.business_group_id);
  --
  -- End Bug 2248735

  chk_day_and_month_validation
  (p_yr_perd_id            => p_rec.yr_perd_id,
   p_strt_day              => p_rec.strt_day,
   p_strt_mo               => p_rec.strt_mo,
   p_end_day               => p_rec.end_day,
   p_end_mo                => p_rec.end_mo,
   p_business_group_id     => p_rec.business_group_id);
  --
 -- Bug - 2167540  : Commented to allow overlapping of start and end values for CWB.
/*  chk_no_overlapping
  (p_wthn_yr_perd_id       => p_rec.wthn_yr_perd_id,
   p_yr_perd_id            => p_rec.yr_perd_id,
   p_strt_day              => p_rec.strt_day,
   p_strt_mo               => p_rec.strt_mo,
   p_end_day               => p_rec.end_day,
   p_end_mo                => p_rec.end_mo,
   p_tm_uom                => p_rec.tm_uom,
   p_business_group_id     => p_rec.business_group_id);
*/
  --
  --
  -- Bug 2167540: Added p_yr_perd_id to chk_unique_combination procedure
  --
  chk_unique_combination
  (p_wthn_yr_perd_id       => p_rec.wthn_yr_perd_id,
   p_yr_perd_id            => p_rec.yr_perd_id,
   p_strt_day              => p_rec.strt_day,
   p_strt_mo               => p_rec.strt_mo,
   p_end_day               => p_rec.end_day,
   p_end_mo                => p_rec.end_mo,
   p_tm_uom                => p_rec.tm_uom,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_tm_uom
  (p_wthn_yr_perd_id           => p_rec.wthn_yr_perd_id,
   p_tm_uom                    => p_rec.tm_uom,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_wyp_shd.g_rec_type
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
  (p_wthn_yr_perd_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_wthn_yr_perd b
    where b.wthn_yr_perd_id      = p_wthn_yr_perd_id
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
                             p_argument       => 'wthn_yr_perd_id',
                             p_argument_value => p_wthn_yr_perd_id);
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
end ben_wyp_bus;

/
