--------------------------------------------------------
--  DDL for Package Body BEN_PPR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PPR_BUS" as
/* $Header: bepprrhi.pkb 120.0.12010000.2 2008/08/05 15:17:03 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_ppr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_prmry_care_prvdr_id >------|
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
--   prmry_care_prvdr_id PK of record being inserted or updated.
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
Procedure chk_prmry_care_prvdr_id(p_prmry_care_prvdr_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prmry_care_prvdr_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ppr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_prmry_care_prvdr_id                => p_prmry_care_prvdr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_prmry_care_prvdr_id,hr_api.g_number)
     <>  ben_ppr_shd.g_old_rec.prmry_care_prvdr_id) then
    --
    -- raise error as PK has changed
    --
    ben_ppr_shd.constraint_error('BEN_PRMRY_CARE_PRVDR_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_prmry_care_prvdr_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_ppr_shd.constraint_error('BEN_PRMRY_CARE_PRVDR_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_prmry_care_prvdr_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pcp_name_spclty_not_null >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Provider Name and Speciality
--   are not null
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   name  Provider Name
--   prmry_care_prvdr_typ_cd Value of lookup code.
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
procedure chk_pcp_name_spclty_not_null(p_name in varchar2,
                                       p_prmry_care_prvdr_typ_cd in varchar2) is
  l_proc              varchar2(72) := g_package||'chk_pcp_name_spclty_not_null';
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
    --
    if p_name is null or p_prmry_care_prvdr_typ_cd is null then
      hr_utility.set_location('Error Provider Name or Speciality is null',99);
      fnd_message.set_name('BEN','BEN_94126_PCP_NAME_SPL_REQD');
      fnd_message.raise_error;
    end if;
    --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pcp_name_spclty_not_null;

-- ----------------------------------------------------------------------------
-- |------< chk_prmry_care_prvdr_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prmry_care_prvdr_id PK of record being inserted or updated.
--   prmry_care_prvdr_typ_cd Value of lookup code.
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
procedure chk_prmry_care_prvdr_typ_cd(p_prmry_care_prvdr_id         in number,
                                      p_prmry_care_prvdr_typ_cd     in varchar2,
                                      p_prtt_enrt_rslt_id           in number,
                                      p_effective_date              in date,
                                      p_object_version_number       in number) is
  l_proc              varchar2(72) := g_package||'chk_prmry_care_prvdr_typ_cd';
  l_api_updating      boolean;
  l_pcp_rpstry_flag   varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ppr_shd.api_updating
    (p_prmry_care_prvdr_id         => p_prmry_care_prvdr_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prmry_care_prvdr_typ_cd
      <> nvl(ben_ppr_shd.g_old_rec.prmry_care_prvdr_typ_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
Begin
        select bpp.pcp_rpstry_flag
        into   l_pcp_rpstry_flag
        from   ben_prtt_enrt_rslt_f bper,
               ben_pl_pcp           bpp
        where  bper.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
        and    bper.pl_id           = bpp.pl_id
        and    p_effective_date  between  bper.effective_start_date and bper.effective_end_date;

        If l_pcp_rpstry_flag = 'N' then
           if hr_api.not_exists_in_hr_lookups
                     (p_lookup_type    => 'BEN_PRMRY_CARE_PRVDR_TYP',
                      p_lookup_code    => p_prmry_care_prvdr_typ_cd,
                      p_effective_date => p_effective_date) then
                 --
                 -- raise error as does not exist as lookup
                 --
                 fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                 fnd_message.set_token('FIELD','p_prmry_care_prvdr_typ_cd');
                 fnd_message.set_token('TYPE', 'BEN_PRMRY_CARE_PRVDR_TYP');
                 fnd_message.raise_error;
           --
           end if;
           --

        Elsif l_pcp_rpstry_flag = 'Y' then -- else condition changed to check for repository  flag = 'Y' and not 'N'
           if hr_api.not_exists_in_hr_lookups
                     (p_lookup_type    => 'BEN_PCP_SPCLTY',
                      p_lookup_code    => p_prmry_care_prvdr_typ_cd,
                      p_effective_date => p_effective_date) then
                 --
                 -- raise error as does not exist as lookup
                 --
                 fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                 fnd_message.set_token('FIELD','p_prmry_care_prvdr_typ_cd');
                 fnd_message.set_token('TYPE', 'BEN_PRMRY_CARE_PRVDR_TYP');
                 fnd_message.raise_error;
           --
           end if;
           --
        End if;
        Exception
               When no_data_found then
                    Null;
  End;
End if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prmry_care_prvdr_typ_cd;


/* ************************************************************************************
Procedure chk_prmry_care_prvdr_typ_cd(p_prmry_care_prvdr_id                in number,
                            p_prmry_care_prvdr_typ_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prmry_care_prvdr_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ppr_shd.api_updating
    (p_prmry_care_prvdr_id                => p_prmry_care_prvdr_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prmry_care_prvdr_typ_cd
      <> nvl(ben_ppr_shd.g_old_rec.prmry_care_prvdr_typ_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PRMRY_CARE_PRVDR_TYP',
           p_lookup_code    => p_prmry_care_prvdr_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
       fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
       fnd_message.set_token('FIELD','p_prmry_care_prvdr_typ_cd');
       fnd_message.set_token('TYPE', 'BEN_PRMRY_CARE_PRVDR_TYP');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prmry_care_prvdr_typ_cd;

************************************************************************************* */
-- ----------------------------------------------------------------------------
-- |------< chk_unique_type >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the type of the PCP is unique for
--    this result or dpnt record (ie, for the plan for this person).
--
-- Pre Conditions
--   None.
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
Procedure chk_unique_type(p_prmry_care_prvdr_id              in number,
                   p_prmry_care_prvdr_typ_cd                in varchar2,
                   p_prtt_enrt_rslt_id     in number,
                   p_elig_cvrd_dpnt_id     in number,
                   p_effective_date        in date,
                   p_validation_start_date in date,
                   p_validation_end_date   in date,
                   p_object_version_number       in number) is

CURSOR c1  IS
    SELECT  name
    FROM    ben_prmry_care_prvdr_f
    WHERE   prmry_care_prvdr_id      <> nvl(p_prmry_care_prvdr_id, hr_api.g_number)
    AND     prmry_care_prvdr_typ_cd   = p_prmry_care_prvdr_typ_cd
    AND     prtt_enrt_rslt_id         = p_prtt_enrt_rslt_id
    AND     effective_end_date       >= p_validation_start_date
    AND     effective_start_date     <= p_validation_end_date  ;

  l_c1_row       c1%rowtype;
  l_proc         varchar2(72) := g_package||'chk_unique_type';
  l_api_updating boolean;

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ppr_shd.api_updating
    (p_prmry_care_prvdr_id         => p_prmry_care_prvdr_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);

  if (l_api_updating
     and nvl(p_prmry_care_prvdr_typ_cd,hr_api.g_varchar2)
     <>  ben_ppr_shd.g_old_rec.prmry_care_prvdr_typ_cd
     or not l_api_updating) then

     if p_prtt_enrt_rslt_id is not null then
       open c1 ;
       fetch c1 into l_c1_row;
       if c1%found then
          close c1;
          -- raise error as there is another record for this result or dependent
          -- that has the same pcp type cd.
          fnd_message.set_name('BEN','BEN_91818_PPR_TYP_UNIQUE');
          fnd_message.raise_error;
       end if;
      close c1;
    end if;

  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_unique_type;

-- ------------------------------------------------------------------------
-- ---------------------< chk_pln_alws_pcp_dsgn >--------------------------
-- ------------------------------------------------------------------------
--
-- Description
--    This procedure is used to validate that a plan allows PCP designation
--    Codes at the Option in Plan level override the plan.

-- Pre Conditions
--    None.
--
--
-- Post Success
--    Processing continues
--
-- Post Failure
--    Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_pln_alws_pcp_dsgn(p_elig_cvrd_dpnt_id    in number,
                                p_prtt_enrt_rslt_id    in number,
                                p_effective_date        in date) is
CURSOR c1 IS
      SELECT  bper.pl_id
      FROM    ben_prtt_enrt_rslt_f  bper,
              ben_pl_pcp            bpp
      WHERE   bper.prtt_enrt_rslt_id     = p_prtt_enrt_rslt_id
      AND     bper.pl_id                 = bpp.pl_id
      AND     bpp.pcp_dsgn_cd in ('R','O')
      AND     p_effective_date BETWEEN bper.effective_start_date and bper.effective_end_date;


CURSOR c2 IS
      SELECT  bper.prtt_enrt_rslt_id
      FROM    ben_elig_cvrd_dpnt_f    becd,
              ben_prtt_enrt_rslt_f    bper,
              ben_pl_pcp              bpp
      WHERE   becd.elig_cvrd_dpnt_id       = p_elig_cvrd_dpnt_id
      AND     becd.prtt_enrt_rslt_id       = bper.prtt_enrt_rslt_id
      AND     bper.pl_id                   = bpp.pl_id
      AND     bpp.pcp_dpnt_dsgn_cd in ('R','O')
      AND     p_effective_date BETWEEN becd.effective_start_date and becd.effective_end_date
      AND     p_effective_date BETWEEN bper.effective_start_date and bper.effective_end_date;

CURSOR c3 IS
      SELECT  oipl.oipl_id
      FROM    ben_prtt_enrt_rslt_f  bper,
              ben_oipl_f            oipl
      WHERE   bper.prtt_enrt_rslt_id     = p_prtt_enrt_rslt_id
      AND     oipl.oipl_id                 = bper.oipl_id
      AND     oipl.pcp_dsgn_cd in ('R','O')
      AND     p_effective_date BETWEEN oipl.effective_start_date and oipl.effective_end_date
      AND     p_effective_date BETWEEN bper.effective_start_date and bper.effective_end_date;

CURSOR c4 IS
      SELECT  bper.prtt_enrt_rslt_id
      FROM    ben_elig_cvrd_dpnt_f    becd,
              ben_prtt_enrt_rslt_f    bper,
              ben_oipl_f               oipl
      WHERE   becd.elig_cvrd_dpnt_id       = p_elig_cvrd_dpnt_id
      AND     becd.prtt_enrt_rslt_id       = bper.prtt_enrt_rslt_id
      AND     bper.oipl_id                   = oipl.oipl_id
      AND     oipl.pcp_dpnt_dsgn_cd in ('R','O')
      AND     p_effective_date BETWEEN becd.effective_start_date and becd.effective_end_date
      AND     p_effective_date BETWEEN oipl.effective_start_date and oipl.effective_end_date
      AND     p_effective_date BETWEEN bper.effective_start_date and bper.effective_end_date;

  l_c1_row   c1%rowtype;
  l_c2_row   c2%rowtype;
  l_c3_row   c3%rowtype;
  l_c4_row   c4%rowtype;

Begin
  if p_prtt_enrt_rslt_id is not null then
    open c3;
    fetch c3 into l_c3_row;
    if c3%notfound then
      close c3;
      open c1;
      fetch c1 into l_c1_row;
      if c1%notfound then
          close c1;
          -- raise error as this plan does not allow selection of pcp
          fnd_message.set_name('BEN','BEN_92568_DSGN_NOT_ALWD');
          fnd_message.raise_error;

      elsif c1%found then
          close c1;
      end if;
    elsif c3%found then
      close c3;
    end if;
  elsif p_elig_cvrd_dpnt_id is not null then
    open c4;
    fetch c4 into l_c4_row;
    if c4%notfound then
      close c4;
      open c2;
      fetch c2 into l_c2_row;
      if c2%notfound then
          close c2;
          -- raise error as this plan does not allow dependent selection of pcp
          fnd_message.set_name('BEN','BEN_92569_DPNT_DSGN_NOT_ALWD');
          fnd_message.raise_error;
      elsif c2%found then
          close c2;
      end if;
    elsif c4%found then
      close c4;
    end if;
  end if;

end chk_pln_alws_pcp_dsgn;




-- ----------------------------------------------------------------------------
-- |------< chk_rslt_dpnt_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that only the result id or the dependent
--   id is filled in, not both.
--
-- Pre Conditions
--   None.
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
Procedure chk_rslt_dpnt_id(p_prtt_enrt_rslt_id     in number,
                           p_elig_cvrd_dpnt_id     in number) is

  l_proc         varchar2(72) := g_package||'chk_rslt_dpnt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_prtt_enrt_rslt_id is null and p_elig_cvrd_dpnt_id is null then
          fnd_message.set_name('BEN','BEN_91819_RSLT_DPNT_NULL');
          fnd_message.raise_error;
  elsif p_prtt_enrt_rslt_id is not null
       and p_elig_cvrd_dpnt_id is not null then
          fnd_message.set_name('BEN','BEN_91820_RSLT_DPNT_NOTNULL');
          fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_rslt_dpnt_id;
--
-- ----------------------------------------------------------------------------
-- |------<  chk_age_gendr_ppr_record >------|
-- ----------------------------------------------------------------------------
--
-- Description
-- This procedure is used to check that the age and gender of the participant.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prmry_care_prvdr_id Primary key for the record.
--   prtt_enrt_rslt_id
--   elig_cvrd_dpnt_id
--   effective_date
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

Procedure chk_age_gendr_ppr_record
          (p_prmry_care_prvdr_id          in   number,
           p_prtt_enrt_rslt_id            in   number,
           p_elig_cvrd_dpnt_id            in   number,
           p_prmry_care_prvdr_typ_cd      in   varchar2,
           p_effective_date               in   date) is

l_proc     varchar2(72) := g_package|| ' chk_age_gendr_ppr_record' ;
l_min_age                    ben_pl_pcp_typ.min_age%type;
l_max_age                    ben_pl_pcp_typ.max_age%type;
l_min_msg                    varchar2(30) := 'n/a';
l_max_msg                    varchar2(30) := 'n/a';
l_sex                        varchar2(30);
l_gender                     varchar2(30);
l_age                        number;
l_dob                        date;
l_rslt_id                    number;
l_dpnt_person_id             number;
l_person_id                  number;

cursor c_plan_design(p_rslt_id number) is
       select pen.person_id, nvl(pct.min_age,-1),
              nvl(pct.max_age,9999), pct.gndr_alwd_cd
       from   ben_pl_pcp_typ pct,
              ben_pl_pcp pcp,
              ben_prtt_enrt_rslt_f pen
       where  pen.prtt_enrt_rslt_id = p_rslt_id
         and  pen.pl_id = pcp.pl_id
         and  pcp.pl_pcp_id = pct.pl_pcp_id
         and  pct.pcp_typ_cd = p_prmry_care_prvdr_typ_cd
         and  p_effective_date between pen.effective_start_date
              and pen.effective_end_date;

cursor c_dob(p_person_id number) is
       select trunc(date_of_birth), sex
       from   per_all_people_f
       where  person_id = p_person_id
       and    p_effective_date between effective_start_date
              and effective_end_date;

cursor c_rslt_id is
       select distinct prtt_enrt_rslt_id, dpnt_person_id
       from   ben_elig_cvrd_dpnt_f
       where  elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
       and    p_effective_date between effective_start_date
              and effective_end_date;

--
Begin
     hr_utility.set_location('Entering:'||l_proc, 5);
     --
     if p_elig_cvrd_dpnt_id is not null then
        -- get result id, dpnt person id.
        open c_rslt_id;
        fetch c_rslt_id into l_rslt_id, l_dpnt_person_id;
        close c_rslt_id;
     else
        l_rslt_id := p_prtt_enrt_rslt_id;
     end if;

     -- get the plan design limitations.
     open c_plan_design(p_rslt_id => l_rslt_id);
     fetch c_plan_design into l_person_id, l_min_age, l_max_age, l_gender;
     close c_plan_design;

     if l_person_id is not null then
        -- we found a limitation....
        -- get the data from person table to compare to plan design limits.
        if p_elig_cvrd_dpnt_id is not null then
           l_person_id := l_dpnt_person_id;  -- reload for dpnt.
        end if;
        open c_dob(p_person_id => l_person_id);
        fetch c_dob into l_dob, l_sex;
        close c_dob;

        if l_dob is not null then
          -- calculation to see whether the age fall under min and max or not
          l_age := (months_between(p_effective_date, l_dob))/12;
          if (l_age > l_max_age or l_age < l_min_age ) then
            if l_max_age <> 9999 then
              l_max_msg := l_max_age;
            end if;
            if l_min_age <> -1 then
              l_min_msg := l_min_age;
            end if;
            fnd_message.set_name('BEN','BEN_92579_AGE_GNDR_REQD');
            fnd_message.set_token('MIN', l_min_msg);
            fnd_message.set_token('MAX', l_max_msg);
            fnd_message.set_token('GENDER', 'n/a');
            fnd_message.raise_error;
          end if;
        end if;
        if l_sex is not null and l_gender is not null then
          if (l_sex <> l_gender ) then
            fnd_message.set_name('BEN','BEN_92579_AGE_GNDR_REQD');
            fnd_message.set_token('MIN', l_min_msg);
            fnd_message.set_token('MAX', l_max_msg);
            fnd_message.set_token('GENDER', l_gender);
            fnd_message.raise_error;
          end if;
        end if;
     end if;

   hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_age_gendr_ppr_record;
--
-- ----------------------------------------------------------------------------
-- |------<  chk_max_chgs_ppr_record >------|
-- ----------------------------------------------------------------------------
--
-- Description
-- This procedure is used to check the max number of changes to PCP based data.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_enrt_rslt_id
--   elig_cvrd_dpnt_id
--   effective_date
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

Procedure chk_max_chgs_ppr_record
          (p_prtt_enrt_rslt_id            in   number,
           p_elig_cvrd_dpnt_id            in   number,
           p_effective_date               in   date) is

l_proc     varchar2(72) := g_package|| ' chk_max_chgs_ppr_record ' ;
l_prtt_enrt_rslt_id          number;
l_num_chgs_alwd              number := 0;
l_first_day                  date;
l_last_day                   date;
l_num_of_chgs                number := 0;

cursor c_prtt_enrt_rslt_id is
       select distinct prtt_enrt_rslt_id
       from   ben_elig_cvrd_dpnt_f
       where  elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id;

cursor c_pcp (p_prtt_enrt_rslt_id number) is
       select pcp.pcp_num_chgs
       from   ben_prtt_enrt_rslt_f pen, ben_pl_pcp pcp
       Where  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         and  pen.pl_id = pcp.pl_id
         and  p_effective_date between
              pen.effective_start_date and pen.effective_end_date;

cursor c_count_rows(p_first_day date, p_last_day date) is
       select count('x')
       from   ben_prmry_care_prvdr_f ppr
       where  (ppr.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         or   ppr.elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id)
         and  ppr.effective_start_date between p_first_day and p_last_day;

--
Begin
     hr_utility.set_location('Entering:'||l_proc, 5);
     --
     if p_elig_cvrd_dpnt_id is not null then
        -- get rslt-id from dpnt record.
        open c_prtt_enrt_rslt_id;
        fetch c_prtt_enrt_rslt_id into l_prtt_enrt_rslt_id;
        close c_prtt_enrt_rslt_id;
     else
        l_prtt_enrt_rslt_id := p_prtt_enrt_rslt_id;
     end if;

     -- get the number of changes allowed for this plan.
     open c_pcp (p_prtt_enrt_rslt_id => l_prtt_enrt_rslt_id);
     fetch c_pcp into l_num_chgs_alwd;
     close c_pcp;

     -- for now, the number of changes always relates to within a calendar month.
     -- so get the number of changes the person has made to this plan's
     -- pcp selection for this calendar month.

     l_first_day := to_date('01'||substr(to_char(p_effective_date, 'dd-mon-rrrr'), 4,9),
                    'dd-mon-rrrr');
     l_last_day  := last_day(p_effective_date);

     open c_count_rows (p_first_day => l_first_day, p_last_day => l_last_day);
     fetch c_count_rows into l_num_of_chgs;
     close c_count_rows;

     -- comparing number of changes
     if l_num_of_chgs >= l_num_chgs_alwd then
          fnd_message.set_name('BEN','BEN_92580_MAX_NUM_CHGS');
          fnd_message.set_token('NDATE', (l_last_day + 1));
         fnd_message.raise_error;
     end if;
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_max_chgs_ppr_record ;
--
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
            (p_elig_cvrd_dpnt_id             in number default hr_api.g_number,
             p_prtt_enrt_rslt_id             in number default hr_api.g_number,
       p_datetrack_mode        in varchar2,
             p_validation_start_date       in date,
       p_validation_end_date       in date) Is
--
  l_proc      varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name      all_tables.table_name%TYPE;
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
    If ((nvl(p_elig_cvrd_dpnt_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_elig_cvrd_dpnt_f',
             p_base_key_column => 'elig_cvrd_dpnt_id',
             p_base_key_value  => p_elig_cvrd_dpnt_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_elig_cvrd_dpnt_f';
      Raise l_integrity_error;
    End If;
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
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error

    ben_utility.parent_integrity_error(p_table_name => l_table_name);

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
            (p_prmry_care_prvdr_id    in number,
             p_datetrack_mode   in varchar2,
       p_validation_start_date  in date,
       p_validation_end_date  in date) Is
--
  l_proc  varchar2(72)  := g_package||'dt_delete_validate';
  l_rows_exist  Exception;
  l_table_name  all_tables.table_name%TYPE;
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
       p_argument       => 'prmry_care_prvdr_id',
       p_argument_value => p_prmry_care_prvdr_id);
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
  (p_rec       in ben_ppr_shd.g_rec_type,
   p_effective_date  in date,
   p_datetrack_mode  in varchar2,
   p_validation_start_date in date,
   p_validation_end_date   in date) is
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
  chk_prmry_care_prvdr_id
  (p_prmry_care_prvdr_id   => p_rec.prmry_care_prvdr_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pcp_name_spclty_not_null
  (p_name                      => p_rec.name,
   p_prmry_care_prvdr_typ_cd   => p_rec.prmry_care_prvdr_typ_cd);
  --
  chk_prmry_care_prvdr_typ_cd
  (p_prmry_care_prvdr_id          => p_rec.prmry_care_prvdr_id,
   p_prmry_care_prvdr_typ_cd      => p_rec.prmry_care_prvdr_typ_cd,
   p_prtt_enrt_rslt_id            => p_rec.prtt_enrt_rslt_id,
   p_effective_date               => p_effective_date,
   p_object_version_number        => p_rec.object_version_number);

  chk_unique_type
  (p_prmry_care_prvdr_id      => p_rec.prmry_care_prvdr_id,
   p_prmry_care_prvdr_typ_cd  => p_rec.prmry_care_prvdr_typ_cd,
   p_prtt_enrt_rslt_id        => p_rec.prtt_enrt_rslt_id,
   p_elig_cvrd_dpnt_id     => p_rec.elig_cvrd_dpnt_id,
   p_effective_date        => p_effective_date,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_object_version_number => p_rec.object_version_number);

   chk_pln_alws_pcp_dsgn(p_elig_cvrd_dpnt_id    => p_rec.elig_cvrd_dpnt_id,
                         p_prtt_enrt_rslt_id    => p_rec.prtt_enrt_rslt_id,
                         p_effective_date       => p_effective_date);

  chk_rslt_dpnt_id
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_elig_cvrd_dpnt_id     => p_rec.elig_cvrd_dpnt_id);


  chk_age_gendr_ppr_record
          (p_prmry_care_prvdr_id       => p_rec.prmry_care_prvdr_id,
           p_prtt_enrt_rslt_id         => p_rec.prtt_enrt_rslt_id,
           p_elig_cvrd_dpnt_id         => p_rec.elig_cvrd_dpnt_id,
           p_prmry_care_prvdr_typ_cd   => p_rec.prmry_care_prvdr_typ_cd,
           p_effective_date            => p_effective_date);

 chk_max_chgs_ppr_record
          (p_prtt_enrt_rslt_id         => p_rec.prtt_enrt_rslt_id,
           p_elig_cvrd_dpnt_id         => p_rec.elig_cvrd_dpnt_id,
           p_effective_date            => p_effective_date);

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec       in ben_ppr_shd.g_rec_type,
   p_effective_date  in date,
   p_datetrack_mode  in varchar2,
   p_validation_start_date in date,
   p_validation_end_date   in date) is
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
  chk_prmry_care_prvdr_id
  (p_prmry_care_prvdr_id   => p_rec.prmry_care_prvdr_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pcp_name_spclty_not_null
  (p_name                      => p_rec.name,
   p_prmry_care_prvdr_typ_cd   => p_rec.prmry_care_prvdr_typ_cd);
  --
  chk_prmry_care_prvdr_typ_cd
  (p_prmry_care_prvdr_id          => p_rec.prmry_care_prvdr_id,
   p_prmry_care_prvdr_typ_cd      => p_rec.prmry_care_prvdr_typ_cd,
   p_prtt_enrt_rslt_id            => p_rec.prtt_enrt_rslt_id,
   p_effective_date               => p_effective_date,
   p_object_version_number        => p_rec.object_version_number);

  chk_unique_type
  (p_prmry_care_prvdr_id      => p_rec.prmry_care_prvdr_id,
   p_prmry_care_prvdr_typ_cd  => p_rec.prmry_care_prvdr_typ_cd,
   p_prtt_enrt_rslt_id        => p_rec.prtt_enrt_rslt_id,
   p_elig_cvrd_dpnt_id     => p_rec.elig_cvrd_dpnt_id,
   p_effective_date        => p_effective_date,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_object_version_number => p_rec.object_version_number);


   chk_pln_alws_pcp_dsgn(p_elig_cvrd_dpnt_id    => p_rec.elig_cvrd_dpnt_id,
                         p_prtt_enrt_rslt_id    => p_rec.prtt_enrt_rslt_id,
                         p_effective_date       => p_effective_date);


  chk_rslt_dpnt_id
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_elig_cvrd_dpnt_id     => p_rec.elig_cvrd_dpnt_id);

  chk_age_gendr_ppr_record
          (p_prmry_care_prvdr_id       => p_rec.prmry_care_prvdr_id,
           p_prtt_enrt_rslt_id         => p_rec.prtt_enrt_rslt_id,
           p_elig_cvrd_dpnt_id         => p_rec.elig_cvrd_dpnt_id,
           p_prmry_care_prvdr_typ_cd   => p_rec.prmry_care_prvdr_typ_cd,
           p_effective_date            => p_effective_date);

  chk_max_chgs_ppr_record
          (p_prtt_enrt_rslt_id         => p_rec.prtt_enrt_rslt_id,
           p_elig_cvrd_dpnt_id         => p_rec.elig_cvrd_dpnt_id,
           p_effective_date            => p_effective_date);

  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_elig_cvrd_dpnt_id             => p_rec.elig_cvrd_dpnt_id,
             p_prtt_enrt_rslt_id             => p_rec.prtt_enrt_rslt_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date       => p_validation_start_date,
     p_validation_end_date       => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec       in ben_ppr_shd.g_rec_type,
   p_effective_date  in date,
   p_datetrack_mode  in varchar2,
   p_validation_start_date in date,
   p_validation_end_date   in date) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode   => p_datetrack_mode,
     p_validation_start_date  => p_validation_start_date,
     p_validation_end_date  => p_validation_end_date,
     p_prmry_care_prvdr_id    => p_rec.prmry_care_prvdr_id);
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
  (p_prmry_care_prvdr_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_prmry_care_prvdr_f b
    where b.prmry_care_prvdr_id      = p_prmry_care_prvdr_id
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
                             p_argument       => 'prmry_care_prvdr_id',
                             p_argument_value => p_prmry_care_prvdr_id);
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
end ben_ppr_bus;

/
