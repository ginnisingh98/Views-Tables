--------------------------------------------------------
--  DDL for Package Body BEN_YRP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_YRP_BUS" as
/* $Header: beyrprhi.pkb 120.0 2005/05/28 12:44:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_yrp_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_yr_perd_id >------|
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
--   yr_perd_id PK of record being inserted or updated.
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
Procedure chk_yr_perd_id(p_yr_perd_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_yr_perd_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_yrp_shd.api_updating
    (p_yr_perd_id                => p_yr_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_yr_perd_id,hr_api.g_number)
     <>  ben_yrp_shd.g_old_rec.yr_perd_id) then
    --
    -- raise error as PK has changed
    --
    ben_yrp_shd.constraint_error('BEN_YR_PERDS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_yr_perd_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_yrp_shd.constraint_error('BEN_YR_PERDS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_yr_perd_id;

--
-- ----------------------------------------------------------------------------
-- |------< chk_perd_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   yr_perd_id PK of record being inserted or updated.
--   perd_typ_cd Value of lookup code.
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
Procedure chk_perd_typ_cd(  p_yr_perd_id                in number,
                            p_perd_typ_cd               in varchar2,
                            p_effective_date            in date,
                            p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_perd_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_yrp_shd.api_updating
    (p_yr_perd_id                => p_yr_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_perd_typ_cd
      <> nvl(ben_yrp_shd.g_old_rec.perd_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_perd_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PERD_TYP',
           p_lookup_code    => p_perd_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801, 'BEN_INVALID_BEN_PERD_TYP_CD');
	  hr_utility.set_message_token('BEN_PERD_TYP_CD' , p_perd_typ_cd);
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_perd_typ_cd;

--
-- ----------------------------------------------------------------------------
-- |------< chk_perd_tm_uom_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   yr_perd_id PK of record being inserted or updated.
--   perd_tm_uom_cd Value of lookup code.
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
Procedure chk_perd_tm_uom_cd(p_yr_perd_id                in number,
                            p_perd_tm_uom_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_perd_tm_uom_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_yrp_shd.api_updating
    (p_yr_perd_id                => p_yr_perd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_perd_tm_uom_cd
      <> nvl(ben_yrp_shd.g_old_rec.perd_tm_uom_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_perd_tm_uom_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_TM_UOM',
           p_lookup_code    => p_perd_tm_uom_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801, 'BEN_INVALID_PERD_TM_UOM_CD');
	  hr_utility.set_message_token('PERD_TM_UOM_CD' , p_perd_tm_uom_cd);
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_perd_tm_uom_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------< chk_start_and_end_dt_unique >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that no two combinations of start and end dates have the same
--   dates
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
Procedure chk_start_and_end_dt_unique
           (p_yr_perd_id            in number
           ,p_start_date            in date
           ,p_end_date              in date
           ,p_business_group_id     in number)
is
l_proc      varchar2(72) := g_package||'chk_start_and_end_dt_unique';
l_dummy    char(1);
cursor c1 is select null
               from ben_yr_perd
              Where yr_perd_id <> nvl(p_yr_perd_id,-1)
                and start_date = p_start_date
                and end_date = p_end_date
                and business_group_id = p_business_group_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into l_dummy;
  if c1%found then
      close c1;
      fnd_message.set_name('BEN','BEN_92130_START_END_DT_UNIQUE');
      fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_start_and_end_dt_unique;
--
-- ----------------------------------------------------------------------------
--
-- *** <<Addition Business Rules >>
--
-- ----------------------------------------------------------------------------
--
-- |------< chk_strt_end_dt_perd_typ >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the start date and end date
--   are enter properly. The following condition will be checked:
--	* Start date and End date is mandatory fields - Can not be null.
--   	* Start date always preceded End date.
--      * If date range is from 01-jan-yyyy to 31-dec-yyyy for the
--        same year then the Period Type must be Calendar, otherwise
--        the Period Type must be Fiscal.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_Start Date	 - Program/Plan year period's Start Date
--   p_End Date    - Program/Plan year period End Date
--   p_Perd Typ Cd - Period type code.  (calendar year or Fiscal year)
--
--
Procedure chk_strt_end_dt_perd_typ(p_start_date 	in date,
                      	   	   p_end_date    	in date,
   				   p_perd_typ_cd 	in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_strt_end_dt_perd_typ';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  if (P_start_date is null) or (p_end_date is null) then
	  --
      -- raise error Start/End Date is null
      --
      hr_utility.set_message(805,'BEN_93610_STRT_END_NULL');
      hr_utility.raise_error;
  elsif (p_start_date > p_end_date) then
      --
      -- raise error Start Date must precede End date
      --
      hr_utility.set_message(805,'BEN_93611_STRT_NOT_PRCD_END');
      hr_utility.set_message_token('START_DATE',to_char(p_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
      hr_utility.set_message_token('END_DATE',to_char(p_end_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
      hr_utility.raise_error;

  elsif(p_end_date > add_months(p_start_date,12)-1 ) then
      --
      -- Raise error Date range between end data nad start date is
      -- greater than 1 year.
      --
      hr_utility.set_message(805,'BEN_93612_DT_RANG_GT_YR');
      hr_utility.set_message_token('START_DATE',to_char(p_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
      hr_utility.set_message_token('END_DATE',to_char(p_end_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
      hr_utility.raise_error;
  elsif to_char(p_start_date, 'DDMM') = '0101' and
        to_char(p_end_date,   'DDMM') = '3112' and
        p_perd_typ_cd <> 'CLNDR' then
        --
        -- Raise error as this is a full Calendar year
        --
        fnd_message.set_name('BEN','BEN_91742_YR_PERD_DATES');
        fnd_message.raise_error;
        --
  elsif(to_char(p_start_date, 'DDMM') <>  '0101'
        or to_char(p_end_date, 'DDMM') <>  '3112')
        and p_perd_typ_cd <> 'FISCAL' then
        --
        -- Raise error as this is a fiscal year
        --
        fnd_message.set_name('BEN','BEN_91742_YR_PERD_DATES');
        fnd_message.raise_error;
        --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_strt_end_dt_perd_typ;

-- ----------------------------------------------------------------------------
-- |------< chk_Lmt_strt_end_perd_typ_uom >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the start date and end date
--   are enter properly. The following condition will be checked:
--	* Period's Unit of measure, and number of period in year
--	  will be mandatory fields if Perd_type_cd equal to Calenedar year
--	* If Lmt_strt_dt is not NULL, then lmt_end_dt can not be NULL. or vice versa.
--   	* Limitation Start date always preceded End date if they are not NULL.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_Lmtn_yr_Strt Dt	 - Limitation year's Start Date
--   p_lmtn_yr_End Date  - Limitation year's End Date
--   p_Perd_Typ Cd       - Period type code.  (calendar year or Fiscal year)
--   p_perds_in_yr_num   - Number of period in year.
--   p_perd_tm_uom_cd    - Period's Unit of measure.
--
Procedure chk_lmt_strt_end_perd_typ_uom(p_lmtn_yr_strt_dt  	 in date,
                          	   	   	    p_lmtn_yr_end_dt   	 in date,
				   	   				    p_perd_typ_cd 	     in varchar2,
					   					p_perds_in_yr_num    in number,
				           			    p_perd_tm_uom_cd     in varchar2 ) is
  --
  l_proc         varchar2(72) := g_package||'chk_Lmt_strt_end_perd_typ_uom';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);

  if ((P_lmtn_yr_strt_dt is not null) and (p_lmtn_yr_end_dt is null) or
	(P_lmtn_yr_strt_dt is null) and (p_lmtn_yr_end_dt is not null) ) then
      --
      -- raise error Limitation year's End Date can not be null if start date is not null
      --
      hr_utility.set_message(801,'BEN_INVALID_LMT_STRT_END_DT');
	  hr_utility.set_message_token('ERR_MSG',
	        'lmtn_Start/End_dt is mandatory (if other is not null');
	  hr_utility.set_message_token('LMT_YR_STRT_DT',p_lmtn_yr_strt_dt);
	  hr_utility.set_message_token('LMT_YR_END_DT',p_lmtn_yr_end_dt);
	  hr_utility.raise_error;
  elsif (p_lmtn_yr_strt_dt is not null and p_lmtn_yr_strt_dt > p_lmtn_yr_end_dt) then
      --
      -- raise error if limitation year Start Date not null then it must precede End date
      --
      hr_utility.set_message(801,'BEN_INVALID_LMT_STRT_END_DT');
	  hr_utility.set_message_token('ERR_MSG',
			'If Limitaiton Year start date is not null, then it must precede End date');
	  hr_utility.set_message_token('LMT_YR_STRT_DT',p_lmtn_yr_strt_dt);
	  hr_utility.set_message_token('LMT_YR_END_DT',p_lmtn_yr_end_dt);
	  hr_utility.raise_error;

      hr_utility.raise_error;
  elsif(upper(nvl(p_perd_typ_cd,'***')) = 'CAL' and
		( p_perds_in_yr_num is null or p_perd_tm_uom_cd is null)  ) then
      --
      -- Raise Error if Perd_typ_cd is Calendar year, then perds_in_yr_num, and perd_tm_uom fields
      -- will become mandatory fields.
      --
      hr_utility.set_message(801,'BEN_INVALID_PERD_TYP_UOM');
	  hr_utility.set_message_token('ERR_MSG',
			'perd_tm_uom_cd and perds_in_yr_num are mandatory fields if perd_typ_cd = Cal yr');
	  hr_utility.set_message_token('PERD_TYP_CD',     p_perd_typ_cd);
	  hr_utility.set_message_token('PERDS_IN_YR_NUM', to_char(p_perds_in_yr_num) );
	  hr_utility.set_message_token('PERD_TM_UOM_CD',  p_perd_tm_uom_cd);

      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --

End chk_Lmt_strt_end_perd_typ_uom;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_yrp_shd.g_rec_type
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
  chk_yr_perd_id
  (p_yr_perd_id            => p_rec.yr_perd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_perd_typ_cd
  (p_yr_perd_id            => p_rec.yr_perd_id,
   p_perd_typ_cd           => p_rec.perd_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_perd_tm_uom_cd
  (p_yr_perd_id            => p_rec.yr_perd_id,
   p_perd_tm_uom_cd        => p_rec.perd_tm_uom_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_start_and_end_dt_unique
  (p_yr_perd_id            => p_rec.yr_perd_id,
   p_start_date            => p_rec.start_date,
   p_end_date              => p_rec.end_date,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_strt_end_dt_perd_typ
  (p_start_date            => p_rec.start_date,
   p_end_date    	   => p_rec.end_date,
   p_perd_typ_cd           => p_rec.perd_typ_cd);
  --
  chk_lmt_strt_end_perd_typ_uom
  (p_lmtn_yr_strt_dt  	   => p_rec.lmtn_yr_strt_dt,
   p_lmtn_yr_end_dt        => p_rec.lmtn_yr_end_dt,
   p_perd_typ_cd           => p_rec.perd_typ_cd,
   p_perds_in_yr_num       => p_rec.perds_in_yr_num,
   p_perd_tm_uom_cd        => p_rec.perd_tm_uom_cd);

  --


  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_yrp_shd.g_rec_type
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
  chk_yr_perd_id
  (p_yr_perd_id            => p_rec.yr_perd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_perd_typ_cd
  (p_yr_perd_id            => p_rec.yr_perd_id,
   p_perd_typ_cd           => p_rec.perd_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_perd_tm_uom_cd
  (p_yr_perd_id            => p_rec.yr_perd_id,
   p_perd_tm_uom_cd        => p_rec.perd_tm_uom_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_start_and_end_dt_unique
  (p_yr_perd_id            => p_rec.yr_perd_id,
   p_start_date            => p_rec.start_date,
   p_end_date              => p_rec.end_date,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_strt_end_dt_perd_typ
  (p_start_date 	   => p_rec.start_date,
   p_end_date    	   => p_rec.end_date,
   p_perd_typ_cd           => p_rec.perd_typ_cd);
  --
  chk_lmt_strt_end_perd_typ_uom
  (p_lmtn_yr_strt_dt  	   => p_rec.lmtn_yr_strt_dt,
   p_lmtn_yr_end_dt        => p_rec.lmtn_yr_end_dt,
   p_perd_typ_cd           => p_rec.perd_typ_cd,
   p_perds_in_yr_num       => p_rec.perds_in_yr_num,
   p_perd_tm_uom_cd        => p_rec.perd_tm_uom_cd);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_yrp_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--

  cursor c_popl_yr_exists is
  select 1
  from ben_popl_yr_perd
  where yr_perd_id = p_rec.yr_perd_id ;
  --
  l_popl_yr_exists c_popl_yr_exists%rowtype ;
  --
  cursor c_enrt_perd is
  select 1
  from ben_enrt_perd
  where yr_perd_id = p_rec.yr_perd_id ;
  --
  l_enrt_perd c_enrt_perd%rowtype;
  --
  cursor c_wthn_yr_perd is
  select 1
  from ben_wthn_yr_perd
  where yr_perd_id = p_rec.yr_perd_id ;
  --
  l_wthn_yr_perd c_wthn_yr_perd%rowtype ;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  open c_popl_yr_exists ;
  fetch c_popl_yr_exists into l_popl_yr_exists ;
  if c_popl_yr_exists%found
  then
     close c_popl_yr_exists ;
     fnd_message.set_name('PER', 'HR_7215_DT_CHILD_EXISTS');
     fnd_message.set_token('TABLE_NAME', 'BEN_POPL_YR_PERD');
     fnd_message.raise_error;
  end if ;
  close c_popl_yr_exists ;
  --
  open c_enrt_perd ;
  fetch c_enrt_perd into l_enrt_perd ;
  if c_enrt_perd%found
  then
     close c_enrt_perd ;
     fnd_message.set_name('PER', 'HR_7215_DT_CHILD_EXISTS');
     fnd_message.set_token('TABLE_NAME', 'BEN_ENRT_PERD');
     fnd_message.raise_error;
  end if ;
  close c_enrt_perd ;
  --
  open c_wthn_yr_perd ;
  fetch c_wthn_yr_perd into l_wthn_yr_perd ;
  if c_wthn_yr_perd%found
  then
     close c_wthn_yr_perd ;
     fnd_message.set_name('PER', 'HR_7215_DT_CHILD_EXISTS');
     fnd_message.set_token('TABLE_NAME', 'BEN_WTHN_YR_PERD');
     fnd_message.raise_error;
  end if ;
  close c_wthn_yr_perd ;
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
  (p_yr_perd_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_yr_perd b
    where b.yr_perd_id      = p_yr_perd_id
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
                             p_argument       => 'yr_perd_id',
                             p_argument_value => p_yr_perd_id);
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
end ben_yrp_bus;

/
