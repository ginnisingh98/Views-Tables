--------------------------------------------------------
--  DDL for Package Body BEN_ABR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ABR_BUS" as
/* $Header: beabrrhi.pkb 120.18 2008/05/15 10:36:51 krupani ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_abr_bus.';  -- Global package name

-- ----------------------------------------------------------------------------
-- |-----------------------< chk_acty_base_rt_id >----------------------------|
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
--   acty_base_rt_id          PK of record being inserted or updated.
--   effective_date Effective Date of session
--   object_version_number Object version number of record being
--                         inserted or updated.
----
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_acty_base_rt_id(p_acty_base_rt_id                     in number,
                    p_effective_date            in date,
                    p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_acty_base_rt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_abr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_acty_base_rt_id                       => p_acty_base_rt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_acty_base_rt_id,hr_api.g_number)
     <>  ben_abr_shd.g_old_rec.acty_base_rt_id) then
    --
    -- raise error as PK has changed
    --
    ben_abr_shd.constraint_error('BEN_ACTY_BASE_RT_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_acty_base_rt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_abr_shd.constraint_error('BEN_ACTY_BASE_RT_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_acty_base_rt_id;
--
--
-- ---------------------------------------------------------------------------
-- |------------------------< chk_name_unique >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that the Activity Base Rate Name is unique
--   within business_group
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_name is Acty_Base_Rt name
--     p_acty_base_rt_id is acty_base_rt_id
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
Procedure chk_name_unique
          ( p_acty_base_rt_id      in   varchar2
           ,p_name                 in   varchar2
           ,p_business_group_id    in   number)
is
l_proc      varchar2(72) := g_package||'chk_name_unique';
l_dummy    char(1);
cursor c1 is select null
             from   ben_acty_base_rt_f
             Where  acty_base_rt_id <> nvl(p_acty_base_rt_id,-1)
             and    name = p_name
             and    business_group_id = p_business_group_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('p_acty_base_rt_id' || p_acty_base_rt_id,235411);
  --
  open c1;
  fetch c1 into l_dummy;
  if c1%found then
      close c1;
      fnd_message.set_name('BEN','BEN_91009_NAME_NOT_UNIQUE');
      fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_name_unique;
--
--ICM
-- |------------------------< chk_elem_unique >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that the same Element is not attached to more than one ICM Rates.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_name is Acty_Base_Rt name
--     p_acty_base_rt_id is acty_base_rt_id
--     p_business_group_id
--     p_element_type_id
--     p_rt_mlt_cd
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
Procedure chk_elem_unique
          ( p_acty_base_rt_id      in   varchar2
           ,p_effective_date       in   date
           ,p_business_group_id    in   number
	   ,p_element_type_id      in   number
	   ,p_rt_mlt_cd            in   varchar2
	   ,p_rec 	 	   in ben_abr_shd.g_rec_type)
is
l_proc      varchar2(72) := g_package||'chk_elem_unique';
--
cursor c_oipl is
     select opt_id, pl_id
     from   ben_oipl_f
     where  oipl_id = p_rec.oipl_id
     and    p_effective_date between effective_start_date and effective_end_date;
--
l_oipl c_oipl%rowtype;
--
cursor c_pl_typ(p_pl_id number) is
  select opt_typ_cd
  from   ben_pl_typ_f ptp,
         ben_pl_f pln
  where  pln.pl_id = p_pl_id
  and	 ptp.pl_typ_id = pln.pl_typ_id;
--
l_opt_typ_cd ben_pl_typ_f.opt_typ_cd%TYPE;
--
cursor c1 is
    select null
    from   ben_acty_base_rt_f abr
    where  abr.element_type_id = p_element_type_id
      and  abr.acty_base_rt_id <> nvl(p_acty_base_rt_id,-1)
      and  abr.business_group_id = p_business_group_id
      and  p_effective_date between abr.effective_start_date and abr.effective_end_date
      and  abr.pl_id IN (
           select pl_id from ben_pl_f pln, ben_pl_typ_f typ
           where typ.opt_typ_cd ='ICM'
	   and typ.pl_typ_id = pln.pl_typ_id
	   and pln.pl_typ_id IN (
	   select pl_typ_id from ben_pl_f where pl_id IN
	   (select pl_id
	    from ben_acty_base_rt_f
	    where business_group_id = p_business_group_id
	    and element_type_id = p_element_type_id)));
  --
  l_element_check varchar2(1);
  --
 --Same Comp Obj of ICM cant have more than one Rate Check
 cursor c_duplicate_rate_pln(p_pl_id number) is
     select null
     from  ben_acty_base_rt_f abr
     where abr.pl_id = nvl(p_pl_id,-1)
      and  abr.acty_base_rt_id <> nvl(p_acty_base_rt_id,-1)
      and  abr.business_group_id = p_business_group_id
      and  p_effective_date between abr.effective_start_date and abr.effective_end_date;
--
 cursor c_duplicate_rate_oipl(p_oipl_id number) is
     select null
     from  ben_acty_base_rt_f abr
     where abr.oipl_id = nvl(p_oipl_id,-1)
      and  abr.acty_base_rt_id <> nvl(p_acty_base_rt_id,-1)
      and  abr.business_group_id = p_business_group_id
      and  p_effective_date between abr.effective_start_date and abr.effective_end_date;
--
l_duplicate varchar2(1);
l_dup boolean := FALSE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
   --ICM Changes
 	if p_rec.pl_id is not null then
	--
	   open c_pl_typ(p_rec.pl_id);
	    fetch c_pl_typ into l_opt_typ_cd;
           close c_pl_typ;
        --
	if l_opt_typ_cd = 'ICM' then
	  --
	   open c_duplicate_rate_pln(p_rec.pl_id);
	    fetch c_duplicate_rate_pln into l_duplicate;
	    if c_duplicate_rate_pln%found then
	    --
	    l_dup := TRUE;
	    --
	    end if;
	    --
           close c_duplicate_rate_pln;
        --
        end if;
        --
      end if;
       --
	if p_rec.oipl_id is not null then
	   -- get opt_id and pl_id
	   open c_oipl;
	   fetch c_oipl into l_oipl ;
	   close c_oipl;
	   --
           open c_pl_typ(l_oipl.pl_id);
	    fetch c_pl_typ into l_opt_typ_cd;
           close c_pl_typ;
	   --
	if l_opt_typ_cd = 'ICM' then
	   --
           open c_duplicate_rate_oipl(p_rec.oipl_id);
	    fetch c_duplicate_rate_oipl into l_duplicate;
	    if c_duplicate_rate_oipl%found then
	    --
	    l_dup := TRUE;
	    --
            end if;
           --
           close c_duplicate_rate_oipl;
	   --
	end if;
        --
      end if;
   --
   --ICM Changes
 if l_opt_typ_cd = 'ICM' then
  --
 if l_dup then --Trying to define Duplicate rate for the comp obj
 --
  fnd_message.set_name('BEN','BEN_94663_DUPLICATE_RATE');
  fnd_message.raise_error;
 --
 end if;
  --
  open c1;
  fetch c1 into l_element_check;
  if c1%found then
  --
      close c1;
      fnd_message.set_name('BEN','BEN_94662_DUPLICATE_ELEMENT');
      fnd_message.raise_error;
 --
  end if;
  close c1;
 --
--For checking proper rt_mlt_cd for ICM Plans
 if p_rt_mlt_cd in ('CL','CLANDCVG','CVG','PRNT','PRNTANDCVG','AP','APANDCVG','SAREC') then
  --
  fnd_message.set_name('BEN','BEN_94664_INVALID_CALC_METHOD');
  fnd_message.raise_error;
  --
  end if;
 --
 end if;
 --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_elem_unique;
--
--ICM
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_ordr_num >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if display on enrollment check box
--   is selected and the Plan Type display code for self service is assigned
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   acty_base_rt_id               PK of record being inserted or updated.
--   effective_date                effective date
--   object_version_number         Object version number of record being
--                                 inserted or updated.
--   p_business_group_id   	   Business group id
--   p_pl_id or p_plip_id	   Plan/Plan in Option/Plan in Program ID to which
--   	or p_oipl_id or p_oiplip_id	Standard Rate is associated
--   p_ordr_num			   Ordr_num
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
Procedure chk_ordr_num(p_acty_base_rt_id               in number,
                          p_effective_date                in date,
                          p_object_version_number         in number,
                          p_business_group_id   	  in number,
                          p_pl_id               	  in number,
                          p_plip_id                     in number,
			  p_oipl_id                     in number,
                          p_opt_id                      in number,
                          p_oiplip_id                   in number,
                          p_ordr_num			  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ordr_num';
  l_api_updating boolean;
  l_dummy 	 number;
  --
  cursor c_abr is
  select 1
  from   ben_acty_base_rt_f abr
  where  abr.acty_base_rt_id <> nvl(p_acty_base_rt_id,-9999)
  and 	 (
  	nvl(abr.pl_id,-1) = nvl(p_pl_id,-99999)
  	or nvl(abr.plip_id,-1) = nvl(p_plip_id,-99999)
  	or nvl(abr.oipl_id,-1) = nvl(p_oipl_id,-99999)
        or nvl(abr.opt_id,-1) = nvl(p_opt_id,-99999)
  	or nvl(abr.oiplip_id,-1) = nvl(p_oiplip_id,-99999)
  	)
  and    abr.ordr_num = p_ordr_num
  and	 abr.business_group_id = p_business_group_id
  and p_effective_date  between abr.effective_start_date and abr.effective_end_date;
  --
  cursor c_pl_typ(p_pl_id number) is
  select opt_dsply_fmt_cd
  from   ben_pl_typ_v plt,
         ben_pl_v pln
  where  pln.pl_id = p_pl_id
  and	 plt.pl_typ_id = pln.pl_typ_id;
  --
  cursor c_plip is
  select pl_id
  from   ben_plip_f
  where  plip_id = p_plip_id;
  --
  cursor c_oipl is
  select pl_id
  from   ben_oipl_f
  where  oipl_id = p_oipl_id;
  --
  cursor c_oiplip is
  select oipl.pl_id
  from   ben_oiplip_f oiplip,
 	 ben_oipl_f oipl
  where  oiplip.oiplip_id = p_oiplip_id
  and	 oipl.oipl_id = oiplip.oipl_id;
  --
  l_pl_id number := nvl(p_pl_id,-1);
  l_opt_dsply_fmt_cd varchar2(30);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_abr_shd.api_updating
    (p_acty_base_rt_id             => p_acty_base_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_ordr_num
      <> nvl(ben_abr_shd.g_old_rec.ordr_num,hr_api.g_number)
      or not l_api_updating)
      and p_ordr_num is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RT_ORDR_NUM',
           p_lookup_code    => to_char(p_ordr_num),
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91438_LOOKUP_VALUE_INVALID');
      fnd_message.set_token('FIELD',to_char(p_ordr_num));
      fnd_message.set_token('TYPE','BEN_RT_ORDR_NUM');
      fnd_message.raise_error;
	--
    end if;
    --
    if l_pl_id = -1 and p_plip_id is null then
	   open c_plip;
	   fetch c_plip into l_pl_id;
	   close c_plip;
    elsif l_pl_id = -1 and p_oipl_id is null then
	   open c_oipl;
	   fetch c_oipl into l_pl_id;
	   close c_oipl;
    elsif l_pl_id = -1 and p_oiplip_id is null then
	   open c_oiplip;
	   fetch c_oiplip into l_pl_id;
	   close c_oiplip;
    end if;
    --
    open  c_pl_typ (l_pl_id);
    fetch c_pl_typ into l_opt_dsply_fmt_cd;
    close c_pl_typ;
    --
    if l_opt_dsply_fmt_cd = 'VRT' then  -- added for 3042658, for horizontal plan types ordr_num = 1
    	open  c_abr;
    	fetch c_abr into l_dummy;
    	close c_abr;
    	--
    	if l_dummy = 1 then
    	  fnd_message.set_name('BEN','BEN_91001_SEQ_NOT_UNIQUE');
    	  fnd_message.raise_error;
    	end if;
    	--
    end if;
    --
  end if;
  --
end chk_ordr_num;

-- ----------------------------------------------------------------------------
--
-- ---------------------------------------------------------------------------
-- |------------------------< chk_ext_inp_values >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that there are no records in ben_extra_input_values
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_acty_base_rt_id is acty_base_rt_id
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
Procedure chk_ext_inp_values
          ( p_acty_base_rt_id      in   number,
            p_input_va_calc_rl    in   number,
            p_object_version_number in number,
            p_effective_date        in date)
is
l_proc      varchar2(72) := g_package||'chk_ext_inp_values';
l_api_updating boolean;
l_dummy    char(1);
cursor c1 is select null
             from   ben_extra_input_values
             Where  acty_base_rt_id = nvl(p_acty_base_rt_id,-1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_abr_shd.api_updating
    (p_acty_base_rt_id             => p_acty_base_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_input_va_calc_rl,hr_api.g_number)
     <> nvl(ben_abr_shd.g_old_rec.input_va_calc_rl,hr_api.g_number)
     )
  then
     open c1;
     fetch c1 into l_dummy;
     if c1%found then
         close c1;
         fnd_message.set_name('BEN','BEN_93185_INP_VAL_EXISTS');
         fnd_message.raise_error;
      end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_ext_inp_values;
--
--

-- ----------------------------------------------------------------------------

Procedure chk_impted_incom_rate_unique
          ( p_acty_base_rt_id      in   varchar2
           ,p_pl_id                in   varchar2
           ,p_rt_usg_cd            in   varchar2
           ,p_effective_start_date in   date
           ,p_business_group_id    in   number )
is
l_proc     varchar2(72) := g_package||'chk_impted_incom_rate_unique';
l_dummy    char(1);
l_name     ben_acty_base_rt_f.name%type ;
-- the date is validated system allow the the different rate for a plan in different periods
-- the futer data also validated
cursor c1 is select name
       from   ben_acty_base_rt_f
       Where  acty_base_rt_id <> nvl(p_acty_base_rt_id,-1)
       and    pl_id = p_pl_id
       and   (p_effective_start_date  between effective_start_date and effective_end_date
             or p_effective_start_date < effective_start_date ) ;

--- cursor to chek imputed income plan
cursor c_is_pl_imputed is
       select '1'  from   BEN_PL_F PLN where  pl_id = p_pl_id and
       p_effective_start_date between effective_start_date and effective_end_date
       and  PLN.imptd_incm_calc_cd in ('PRTT','DCA','DPNT','SPS');

--
Begin
      hr_utility.set_location('Entering:'||l_proc, 5);
     --
     --- when the rate is imputing chek the plan in imputing
     open c_is_pl_imputed;
     fetch c_is_pl_imputed into l_dummy;
     if c_is_pl_imputed%found  and p_rt_usg_cd <>  'IMPTDINC' then
	 fnd_message.set_name('BEN','BEN_92556_IMPTD_NO_STD_RATE');
         fnd_message.raise_error;
    end if;
    close c_is_pl_imputed;
    If p_rt_usg_cd = 'IMPTDINC' then
       ---   chek the multiple rate
        open c1;
        fetch c1 into l_name;
        if c1%found then
           close c1;
           fnd_message.set_name('BEN', 'BEN_92555_IMPTD_RATE_EXISTS');
           fnd_message.set_token('RATE', l_name);
           fnd_message.raise_error;
        end if;
     End if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_impted_incom_rate_unique;
--

--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_pl_with_cvg >----------------------------|
-- ----------------------------------------------------------------------------

Function chk_pl_cvg
        (p_pl_id                 in number ,
         p_effective_date        in date  ) return varchar2  is

  l_proc        varchar2(72) := g_package||'chk_pl_with_cvg';

  cursor  c_cvg is select 'x' from  ben_cvg_amt_calc_mthd_f
  where  pl_id = p_pl_id  and
      entr_val_at_enrt_flag = 'Y'  and
      p_effective_Date between effective_start_date and effective_end_Date ;

  l_dummy varchar2(1) ;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  open c_cvg ;
  fetch c_cvg into l_dummy ;
  if c_cvg%found then
     close c_cvg ;
     hr_utility.set_location('Leaving:'||l_proc,10);
     return ('Y' );
  end if ;
  close c_cvg ;
  return ('N' );
end chk_pl_cvg ;

-- ----------------------------------------------------------------------------
-- |---------------------------< chk_oipl_with_cvg >----------------------------|
-- ----------------------------------------------------------------------------

Function chk_oipl_with_cvg
        (p_oipl_id                 in number ,
         p_effective_date        in date  ) return varchar2  is

  l_proc        varchar2(72) := g_package||'chk_oipl_with_cvg';

  cursor  c_cvg is select 'x' from  ben_cvg_amt_calc_mthd_f
  where  oipl_id = p_oipl_id  and
      entr_val_at_enrt_flag = 'Y'  and
      p_effective_Date between effective_start_date and effective_end_Date ;

  l_dummy varchar2(1) ;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  open c_cvg ;
  fetch c_cvg into l_dummy ;
  if c_cvg%found then
     close c_cvg ;
     hr_utility.set_location('Leaving:'||l_proc,10);
     return ('Y' );
  end if ;
  close c_cvg ;
  return ('N' );
end chk_oipl_with_cvg ;



-- ----------------------------------------------------------------------------
-- |------< chk_entr_at_enrt_with_cvg >------|
-- ----------------------------------------------------------------------------
--
-- Description
--
--
--
--  when the mlt_cd id CVG and entr_at_enrt is Y then the
--  then the com object is validated with coverage
--  for the them object coverage also entr_At_enrt then
--  then error is to be thrown , the same validation is to be done in
--  coverage side too
--  when the level is plan and plan in program is validated with plan
--  option in plan and option in plan in progrm is validated with option in plan
--  in coverage plan and option inplan level only supported now

Procedure chk_entr_at_enrt_with_cvg(p_rt_mlt_cd                   in varchar2,
                                    p_entr_val_at_enrt_flag       in varchar2,
                                    p_pl_id                       in number,
                                    p_plip_id                     in number,
                                    p_oipl_id                     in number,
                                    p_oiplip_id                   in number,
                                    p_effective_date              in date   ) is

l_pl_id       number(15)   :=  p_pl_id  ;
l_oipl_id     number(15)   := p_oipl_id ;
l_dummy       varchar2(1)  ;
l_proc        varchar2(72) := g_package||'chk_entr_at_enrt_with_cvg';

cursor c_oipl is select pl_id from
    ben_plip_f where plip_id = p_plip_id  and
    p_effective_date between effective_start_date and effective_end_date ;

cursor c_oiplip is  select oipl_id  from
     ben_oiplip_f where oiplip_id = p_oiplip_id and
     p_effective_date between effective_start_date and effective_end_date ;

begin
hr_utility.set_location('Entering:'||l_proc, 5);
if  p_rt_mlt_cd = 'CVG' and p_entr_val_at_enrt_flag = 'Y'  then
  -- decide the level
  If p_pl_id is not null or  p_plip_id is not null then
     -- plan level
    if p_plip_id  is not null then
        open c_oipl ;
        fetch c_oipl into l_pl_id  ;
        If c_oipl%notfound  then
           close c_oipl ;
           ben_abr_shd.constraint_error('BEN_OIPL_PK') ;
        end if ;
        close c_oipl ;
     else
       l_pl_id :=  p_pl_id ;
     end if ;
     if  chk_pl_cvg (p_pl_id      => l_pl_id , p_effective_date => p_effective_date  ) ='Y' then
         fnd_message.set_name('BEN','BEN_92653_ENTR_VAL_RATE_CVG');
         fnd_message.raise_error;
     end if ;

  elsif p_oipl_id  is not null or p_oiplip_id is not null then
     -- plan in option levele
     if p_oiplip_id is not null then
        open c_oiplip ;
        fetch c_oiplip into l_oipl_id  ;
        If c_oiplip%notfound then
           close c_oiplip ;
           ben_abr_shd.constraint_error('BEN_OIPLIP_PK') ;
        end if ;
        close c_oiplip ;
     else
        l_oipl_id    := p_oipl_id ;
     end if ;
     if chk_oipl_with_cvg(l_oipl_id,p_effective_Date)  = 'Y' then
         fnd_message.set_name('BEN','BEN_92653_ENTR_VAL_RATE_CVG');
         fnd_message.raise_error;
     end if ;
  else
    --if any other level added
    null;
  end if ;
end if ;
   hr_utility.set_location('Leaving:'||l_proc,10);
end chk_entr_at_enrt_with_cvg;


-- ----------------------------------------------------------------------------
-- |-------------------< chk_elmt_typ_input_val_rqd >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if the Status is anything other than
--   Pending that both Element_Type_id and Input_Value_id must have a value.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_acty_base_rt_stat_cd    Status of record
--   p_input_value_id          value of input_value_id field
--   p_element_type_id         value of element_type_id
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
------------------------------------------------------------------------------
procedure chk_elmt_typ_input_val_rqd
          (p_rec 	 	   in ben_abr_shd.g_rec_type,
	   p_acty_base_rt_stat_cd  in varchar2,
           p_input_value_id        in number,
           p_ele_rqd_flag          in varchar2,
	   p_effective_date        in date,
           p_element_type_id       in number) is
  --
  --ICM Changes
cursor c_oipl is
     select opt_id, pl_id
     from   ben_oipl_f
     where  oipl_id = p_rec.oipl_id
     and    p_effective_date between effective_start_date and effective_end_date;
--
l_oipl c_oipl%rowtype;
--
  cursor c_pl_typ(p_pl_id number) is
  select nvl(opt_typ_cd,'ZZZ')       --Bug 7042738
  from   ben_pl_typ_f ptp,
         ben_pl_f pln
  where  pln.pl_id = p_pl_id
  and	 ptp.pl_typ_id = pln.pl_typ_id;
--
l_opt_typ_cd ben_pl_typ_f.opt_typ_cd%TYPE  :=  'ZZZ';  --Bug 7042738
--ICM Changes
--
begin
   --
   --ICM Changes
 	if p_rec.pl_id is not null then
	--
	   open c_pl_typ(p_rec.pl_id);
	    fetch c_pl_typ into l_opt_typ_cd;
           close c_pl_typ;
        --
       end if;
       --
	if p_rec.oipl_id is not null then
	   -- get opt_id and pl_id
	   open c_oipl;
	   fetch c_oipl into l_oipl ;
	   close c_oipl;
	   --
           open c_pl_typ(l_oipl.pl_id);
	    fetch c_pl_typ into l_opt_typ_cd;
           close c_pl_typ;
	   --
	end if;
   --
   --ICM Changes

   if p_acty_base_rt_stat_cd <> 'P' and p_ele_rqd_flag = 'Y' then
      --
      if (((p_input_value_id is null  OR  p_element_type_id is null) AND l_opt_typ_cd <> 'ICM') OR (p_element_type_id is null AND l_opt_typ_cd = 'ICM')) then
      --
      -- Raise error as Element Type Id and Input Value Id need a
      -- Value unless the Status = 'P' for pending.
      --
      fnd_message.set_name('BEN','BEN_91933_CHK_STAT_FOR_RQD');
      fnd_message.raise_error;
      --
      end if;
      --
   end if;
   --
end chk_elmt_typ_input_val_rqd;
--
procedure chk_prtl_mo_det_mthd_cd
      (p_prtl_mo_det_mthd_cd in varchar2,
       p_ele_entry_val_cd    in varchar2) is
begin
  --
  if p_prtl_mo_det_mthd_cd in ('NONE','PRTVAL','WASHRULE','RL') then
      if p_ele_entry_val_cd in ('DFND','CMCD','PYR') then
         fnd_message.set_name('BEN','BEN_93060_NO_PRTN_DFND');
         fnd_message.raise_error;
      end if;
  end if;
end chk_prtl_mo_det_mthd_cd;
-- ---------------------------------------------------------------------
-- |-------------------< chk_entr_ann_val_flag >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if the
--   ann_mn_elcn_val  and ann_mx_elcn_val are required.
--   and mn_elcn_val and mx_elcn_val is null  when entr_ann_val_flag is 'Y'
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_entr_ann_val_flag      value of entr_ann_val_flag
--   p_ann_mn_elcn_val        value of ann mn_elcn_val
--   p_ann_mx_elcn_val        value of ann_mx_elcn_val
--   p_mn_elcn_val            value of mn_elcn_val
--   p_mx_elcn_val            value of mx_elcn_val
--   p_det_pl_ytd_cntrs_cd    value of det_pl_ytd_cntrs_cd - Expected Contributions
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
------------------------------------------------------------------------------
procedure chk_entr_ann_val_flag
          (p_entr_ann_val_flag        in varchar2,
           p_ann_mn_elcn_val          in number,
           p_ann_mx_elcn_val          in number,
           p_mn_elcn_val              in number,
           p_mx_elcn_val              in number,
	   p_det_pl_ytd_cntrs_cd      in varchar2) is
begin

   if p_entr_ann_val_flag  = 'Y' then
      --
      if (p_ann_mn_elcn_val is null  OR  p_ann_mx_elcn_val is null) then
      --
      fnd_message.set_name('BEN','BEN_92442_ANN_FLAG_ON');
      fnd_message.raise_error;
      --
      end if;

      if (p_mn_elcn_val is not null OR  p_mx_elcn_val is not null) then
      --
      fnd_message.set_name('BEN','BEN_92443_ANN_VALS_ONLY');
      fnd_message.raise_error;
      --
      end if;
      --
      -- Bug : 3197632
      -- Raise error if Enter Annual Value is checked and Expected Contributions is not selected.
      /* As per bug update 3197632, error is no longer needed.
      if p_det_pl_ytd_cntrs_cd is null then
        --
	fnd_message.set_name('BEN','BEN_93993_ANN_EXP_CONTRB_MDTRY');
	fnd_message.raise_error;
	--
      end if;
      */
      --
   end if;
   --
end chk_entr_ann_val_flag;
--



Procedure chk_subj_to_imptd_incm(
                        p_acty_base_rt_id            in number,
                        p_pl_id                      in number,
                        p_oipl_id                    in number,
                        p_plip_id                    in number,
                        p_oiplip_id                  in number,
                        p_acty_typ_cd                in varchar2,
                        p_tx_typ_cd                  in varchar2,
                        p_subj_to_imptd_incm_flag    in varchar2,
                        p_effective_date             in date
                        ) is
  --
  l_proc         varchar2(72) := g_package||'chk_subj_to_imptd_incm';
  l_api_updating boolean;
  l_prflvalue         varchar2(4000) ;

  cursor c_pln is
  select 'x'
  from  ben_pl_f pln
  where pln.pl_id = p_pl_id
   and  pln.subj_to_imptd_incm_typ_cd is not null
   and  p_effective_date between pln.effective_start_date
        and pln.effective_end_date ;

  cursor c_oipl is
  select 'x'
  from  ben_pl_f pln,
        ben_oipl_f oipl
  where oipl.oipl_id = p_oipl_id
   and  pln.pl_id = oipl.pl_id
   and  pln.subj_to_imptd_incm_typ_cd is not null
   and  p_effective_date between pln.effective_start_date
        and pln.effective_end_date
   and  p_effective_date between oipl.effective_start_date
        and oipl.effective_end_date
    ;

  cursor c_plip is
  select 'x'
  from  ben_pl_f pln,
        ben_plip_f plip
  where plip.plip_id = p_plip_id
   and  pln.pl_id = plip.pl_id
   and  pln.subj_to_imptd_incm_typ_cd is not null
   and  p_effective_date between pln.effective_start_date
        and pln.effective_end_date
   and  p_effective_date between plip.effective_start_date
        and plip.effective_end_date
    ;


  cursor c_oiplip is
  select 'x'
  from  ben_pl_f pln,
        ben_oipl_f oipl,
        ben_oiplip_f oiplip
  where oiplip.oiplip_id = p_oiplip_id
   and  oipl.oipl_id = oiplip.oipl_id
   and  pln.pl_id = oipl.pl_id
   and  pln.subj_to_imptd_incm_typ_cd is not null
   and  p_effective_date between pln.effective_start_date
        and pln.effective_end_date
   and  p_effective_date between oipl.effective_start_date
        and oipl.effective_end_date
   and  p_effective_date between oiplip.effective_start_date
        and oiplip.effective_end_date

    ;

  l_dummy   varchar2(15) ;

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_prflvalue := fnd_profile.value('BEN_IMPTD_INCM_POST_TAX');
  hr_utility.set_location('Profile:'||l_prflvalue, 99 );
  if l_prflvalue = 'Y' then
    /* this validation is not done becasuse the opt can not be validated
       discussed with BP
     if p_plip_id  is not null then
        open c_plip ;
        fetch c_plip into l_dummy ;
        close c_plip
     end if ;
     if p_oipl_id  is not null then
        open c_oipl ;
        fetch c_oipl into l_dummy ;
        close c_oipl
     end if ;
     if p_oiplip_id  is not null then
        open c_oiplip ;
        fetch c_oiplip into l_dummy ;
        close c_oiplip
     end if ;
     if p_pln_id  is not null then
        open c_pln ;
        fetch c_pln into l_dummy ;
        close c_pln
     end if ;
     */
     ---
     if  not (p_tx_typ_cd = 'AFTERTAX'  and  substr(p_acty_typ_cd,1,2) = 'EE') then
         fnd_message.set_name('BEN','BEN_93397_SUBJ_IMPTD_INCOM_FLG');
         fnd_message.raise_error;
        --
     end if ;

  end if ;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_subj_to_imptd_incm;

-- ----------------------------------------------------------------------------
-- |--------------------------< chk_all_rules >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rules are valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   Partial Month Determination method   rule p_prtl_mo_det_mthd_rl
--   Partial Month Effective Date Determination rule  p_prtl_mo_eff_dt_det_rl
--   Rounding Rule        p_rndg_rl
--                        p_prtl_mo_det_mthd_cd
--                        p_prtl_mo_eff_dt_det_cd
--                        p_rndg_cd
--                        p_val_calc_rl
--                        p_mn_mx_elcn_rl
--                        p_business_group_id
--   effective_date             effective date
--   object_version_number      Object version number of record being
--                              inserted or updated.
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
Procedure chk_all_rules(p_acty_base_rt_id            in number,
                        p_prtl_mo_det_mthd_rl        in number,
                        p_prtl_mo_eff_dt_det_rl      in number,
                        p_rndg_rl                    in number,
                        p_lwr_lmt_calc_rl           in number,
                        p_upr_lmt_calc_rl            in number,
                        p_prtl_mo_det_mthd_cd        in varchar2,
                        p_prtl_mo_eff_dt_det_cd      in varchar2,
                        p_rndg_cd                    in varchar2,
                        p_val_calc_rl                in number,
                        p_prort_mn_ann_elcn_val_rl   in number,
                        p_prort_mx_ann_elcn_val_rl   in number,
			p_mn_mx_elcn_rl              in number,
			p_element_det_rl             in number,
                        p_effective_date             in date,
			p_business_group_id	     in number,
                        p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_all_rules';
  l_api_updating boolean;
  l_dummy        varchar2(1);

  --

  cursor c1(p_rule number, p_formula_type_id in number) is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_rule
    and    ff.formula_type_id = p_formula_type_id
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
  l_api_updating := ben_abr_shd.api_updating
    (p_acty_base_rt_id             => p_acty_base_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_prtl_mo_det_mthd_rl,hr_api.g_number)
      <> ben_abr_shd.g_old_rec.prtl_mo_det_mthd_rl
      or not l_api_updating)
      and p_prtl_mo_det_mthd_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_prtl_mo_det_mthd_rl, -165); -- formula_type_id = ??
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
        fnd_message.set_name('BEN','BEN_91172_PRTL_MO_DET_MTHD_RL');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
    --
    -- Unless Partial Month Determination Method Code = Rule,
    --                    Partial Month Determination Method rule must be blank.
    if  nvl(p_prtl_mo_det_mthd_cd,hr_api.g_varchar2)  <> 'RL'
        and p_prtl_mo_det_mthd_rl is not null then
        --
        fnd_message.set_name('BEN', 'BEN_91432_PMD_RL_NOT_NULL');
        fnd_message.raise_error;
        --
    elsif nvl(p_prtl_mo_det_mthd_cd,hr_api.g_varchar2) = 'RL'
          and p_prtl_mo_det_mthd_rl is null then
        --
        fnd_message.set_name('BEN', 'BEN_91434_PMD_RL_NULL');
        fnd_message.raise_error;
        --
    end if;
  --
  end if;
  --
  if (l_api_updating
      and nvl(p_prtl_mo_eff_dt_det_rl,hr_api.g_number)
      <> ben_abr_shd.g_old_rec.prtl_mo_eff_dt_det_rl
      or not l_api_updating)
      and p_prtl_mo_eff_dt_det_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_prtl_mo_eff_dt_det_rl, -48); -- formula_type_id = -48
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
        fnd_message.set_name('BEN','BEN_91173_PRL_MO_EFF_DT_DET_RL');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
    --
    -- Unless Partial Month Effective Date Determination Code = Rule,
    --        Partial Month Effective Date Determination rule must be blank.
    if  nvl(p_prtl_mo_eff_dt_det_cd,hr_api.g_varchar2)  <> 'RL'
        and p_prtl_mo_eff_dt_det_rl is not null then
        --
        fnd_message.set_name('BEN', 'BEN_91433_PMEDD_RL_NOT_NULL');
        fnd_message.raise_error;
        --
    elsif nvl(p_prtl_mo_eff_dt_det_cd,hr_api.g_varchar2) = 'RL'
          and p_prtl_mo_eff_dt_det_rl is null then
        --
        fnd_message.set_name('BEN', 'BEN_91435_PMEDD_RL_NULL');
        fnd_message.raise_error;
        --
    end if;
  --
  end if;
  --
  if (l_api_updating
      and nvl(p_rndg_rl,hr_api.g_number)
      <> ben_abr_shd.g_old_rec.rndg_rl
      or not l_api_updating)
      and p_rndg_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_rndg_rl, -169); -- formula_type_id = ??
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
    --
    -- Unless Rounding Code = Rule, Rounding rule must be blank.
    if  nvl(p_rndg_cd,hr_api.g_varchar2)  <> 'RL' and p_rndg_rl is not null then
      --
      fnd_message.set_name('BEN','BEN_91043_RNDG_RL_NOT_NULL');
      fnd_message.raise_error;
      --
    elsif nvl(p_rndg_cd,hr_api.g_varchar2) = 'RL' and p_rndg_rl is null then
      --
      fnd_message.set_name('BEN','BEN_92340_RNDG_RL_NULL');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_lwr_lmt_calc_rl,hr_api.g_number)
      <> ben_abr_shd.g_old_rec.lwr_lmt_calc_rl
      or not l_api_updating)
      and p_lwr_lmt_calc_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_lwr_lmt_calc_rl, -392);
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
        fnd_message.set_name('BEN','BEN_91815_INVALID_LWR_LMT_RL');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_upr_lmt_calc_rl,hr_api.g_number)
      <> ben_abr_shd.g_old_rec.upr_lmt_calc_rl
      or not l_api_updating)
      and p_upr_lmt_calc_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_upr_lmt_calc_rl, -293);
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
        fnd_message.set_name('BEN','BEN_91823_INVALID_UPR_LMT_RL');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_val_calc_rl,hr_api.g_number)
      <> ben_abr_shd.g_old_rec.val_calc_rl
      or not l_api_updating)
      and p_val_calc_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_val_calc_rl, -171);
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
        fnd_message.set_name('BEN','BEN_91174_VAL_CALC_RL');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  --
  if (l_api_updating
      and nvl(p_prort_mn_ann_elcn_val_rl,hr_api.g_number)
      <> ben_abr_shd.g_old_rec.prort_mn_ann_elcn_val_rl
      or not l_api_updating)
      and p_prort_mn_ann_elcn_val_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_prort_mn_ann_elcn_val_rl, -534);
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
        fnd_message.set_token('ID',p_prort_mn_ann_elcn_val_rl);
        fnd_message.set_token('TYPE_ID',-534);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_prort_mx_ann_elcn_val_rl,hr_api.g_number)
      <> ben_abr_shd.g_old_rec.prort_mx_ann_elcn_val_rl
      or not l_api_updating)
      and p_prort_mx_ann_elcn_val_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_prort_mx_ann_elcn_val_rl, -534);
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
        fnd_message.set_name('BEN','BEN_91741_FORMULA_NOT_FOUND');
        fnd_message.set_token('ID',p_prort_mx_ann_elcn_val_rl);
        fnd_message.set_token('TYPE_ID',-534);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;

  --- Bug 3981982
  if (l_api_updating
      and nvl(p_mn_mx_elcn_rl,hr_api.g_number)
      <> ben_abr_shd.g_old_rec.mn_mx_elcn_rl
      or not l_api_updating)
      and p_mn_mx_elcn_rl  is not null then
    --
    -- check if value of formula rule is valid.
    --
     open c1(p_mn_mx_elcn_rl, -551);
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
        fnd_message.set_name('BEN','BEN_94127_INVALID_MN_MX_RL');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
   end if;
  --
  -- cwb multiple currency
  if (l_api_updating
      and nvl(p_element_det_rl,hr_api.g_number)
      <> ben_abr_shd.g_old_rec.element_det_rl
      or not l_api_updating)
      and p_element_det_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
     open c1(p_element_det_rl, -557);
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;

      if c1%notfound then
        --
        close c1;
        --

        fnd_message.set_name('BEN','BEN_91741_FORMULA_NOT_FOUND');
        fnd_message.set_token('ID',p_element_det_rl);
        fnd_message.set_token('TYPE_ID',-557);
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
end chk_all_rules;


-- ----------------------------------------------------------------------------
-- |----------------------------< chk_all_flags >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the flag lookup values are valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   acty_base_rt_id                 PK of record being inserted or updated.
--   use_to_calc_net_flx_cr_flag     Value of lookup code.
--   asn_on_enrt_flag                Value of lookup code.
--   abv_mx_elcn_val_alwd_flag       Value of lookup code.
--   blw_mn_elcn_alwd_flag           Value of lookup code.
--   uses_ded_sched_flag             Value of lookup code.
--   uses_varbl_rt_flag              Value of lookup code.
--   vstg_sched_apls_fLag            Value of lookup code.
--   proc_each_pp_dflt_flag          Value of lookup code.
--   prdct_flx_cr_when_elig_flag     Value of lookup code.
--   no_std_rt_used_flag             Value of lookup code.
--   uses_pymt_sched_flag            Value of lookup code.
--   val_ovrid_alwd_flag             Value of lookup code.
--   no_mx_elcn_val_dfnd_flag        Value of lookup code.
--   entr_val_at_enrt_flag           Value of lookup code.
--   entr_ann_val_flag               Value of lookup code.
--   effective_date                  effective date
--   object_version_number        Object version number of record being
--                                inserted or updated.
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
Procedure chk_all_flags(p_acty_base_rt_id                in number,
                        p_use_to_calc_net_flx_cr_flag    in varchar2,
                        p_asn_on_enrt_flag               in varchar2,
                        p_abv_mx_elcn_val_alwd_flag      in varchar2,
                        p_blw_mn_elcn_alwd_flag          in varchar2,
                        p_dsply_on_enrt_flag             in varchar2,
                        p_use_calc_acty_bs_rt_flag       in varchar2,
                        p_uses_ded_sched_flag            in varchar2,
                        p_uses_varbl_rt_flag             in varchar2,
                        p_vstg_sched_apls_fLag           in varchar2,
                        p_proc_each_pp_dflt_flag         in varchar2,
                        p_prdct_flx_cr_when_elig_flag    in varchar2,
                        p_no_std_rt_used_flag            in varchar2,
                        p_uses_pymt_sched_flag           in varchar2,
                        p_val_ovrid_alwd_flag            in varchar2,
                        p_no_mx_elcn_val_dfnd_flag       in varchar2,
                        p_no_mn_elcn_val_dfnd_flag       in varchar2,
                        p_entr_val_at_enrt_flag          in varchar2,
                        p_entr_ann_val_flag              in varchar2,
                        p_only_one_bal_typ_alwd_flag     in varchar2,
                        p_rt_usg_cd                      in varchar2,
                        p_ele_rqd_flag                   in varchar2,
                        p_subj_to_imptd_incm_flag        in varchar2,
                        p_acty_typ_cd                    in varchar2,
                        p_business_group_id              in number,
                        p_effective_date               in date,
                        p_object_version_number        in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_all_flags';
  l_api_updating boolean;
  l_dummy char(1);
  cursor c1 is select null
                from ben_acty_vrbl_rt_f
                 where acty_base_rt_id = p_acty_base_rt_id
                   and business_group_id = p_business_group_id
                   and p_effective_date between effective_start_date
                                            and effective_end_date
      UNION     select null
                from ben_vrbl_rt_rl_f
                 where acty_base_rt_id = p_acty_base_rt_id
                   and business_group_id = p_business_group_id
                   and p_effective_date between effective_start_date
                                            and effective_end_date;
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_abr_shd.api_updating
    (p_acty_base_rt_id                       => p_acty_base_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_use_to_calc_net_flx_cr_flag
      <> nvl(ben_abr_shd.g_old_rec.use_to_calc_net_flx_cr_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_use_to_calc_net_flx_cr_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_use_to_calc_net_flx_cr_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91175_CALC_NET_FLX_CR_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_asn_on_enrt_flag
      <> nvl(ben_abr_shd.g_old_rec.asn_on_enrt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_asn_on_enrt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_asn_on_enrt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91176_ASN_ON_ENRT_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  --
  if (l_api_updating
      and p_abv_mx_elcn_val_alwd_flag
      <> nvl(ben_abr_shd.g_old_rec.abv_mx_elcn_val_alwd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_abv_mx_elcn_val_alwd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_abv_mx_elcn_val_alwd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91177_ABV_MX_EL_ALWD_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  --
  if (l_api_updating
      and p_blw_mn_elcn_alwd_flag
      <> nvl(ben_abr_shd.g_old_rec.blw_mn_elcn_alwd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_blw_mn_elcn_alwd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_blw_mn_elcn_alwd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91178_BLW_MN_EL_ALWD_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_dsply_on_enrt_flag
      <> nvl(ben_abr_shd.g_old_rec.dsply_on_enrt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dsply_on_enrt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dsply_on_enrt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91627_DSPLY_ON_ENRT_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_use_calc_acty_bs_rt_flag
      <> nvl(ben_abr_shd.g_old_rec.use_calc_acty_bs_rt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_use_calc_acty_bs_rt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_use_calc_acty_bs_rt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91179_CAL_ACTY_BS_RT_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  --
  --
  if (l_api_updating
      and p_uses_ded_sched_flag
      <> nvl(ben_abr_shd.g_old_rec.uses_ded_sched_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_uses_ded_sched_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_uses_ded_sched_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91180_USES_DED_SCHED_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_uses_varbl_rt_flag
      <> nvl(ben_abr_shd.g_old_rec.uses_varbl_rt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_uses_varbl_rt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_uses_varbl_rt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91181_USES_VARBL_RT_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
    --  Uses Variable Rate Falg cannot be updated to "off", when acty variable rate rule or
    --  variable rate records exists for flex credit calculation.
    --
   --
   --



   if (l_api_updating
      and p_uses_varbl_rt_flag
      <> nvl(ben_abr_shd.g_old_rec.uses_varbl_rt_flag,hr_api.g_varchar2)
      ) and p_uses_varbl_rt_flag is not null and p_acty_base_rt_id is not null
        and p_uses_varbl_rt_flag = 'N' --bug 3960628
   then
        open c1;
        fetch c1 into l_dummy;
        if c1%found then
               close c1;
               fnd_message.set_name('BEN','BEN_91430_VRBL_RT_RL_EXISTS');
               fnd_message.raise_error;
        end if;
        close c1;
   end if;
   --
  end if;
  --
  if (l_api_updating
      and p_vstg_sched_apls_fLag
      <> nvl(ben_abr_shd.g_old_rec.vstg_sched_apls_fLag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_vstg_sched_apls_fLag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_vstg_sched_apls_fLag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91182_VSTG_SCHED_APLS_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_proc_each_pp_dflt_flag
      <> nvl(ben_abr_shd.g_old_rec.proc_each_pp_dflt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_proc_each_pp_dflt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_proc_each_pp_dflt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91183_PROC_PP_DFLT_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_prdct_flx_cr_when_elig_flag
      <> nvl(ben_abr_shd.g_old_rec.prdct_flx_cr_when_elig_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prdct_flx_cr_when_elig_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_prdct_flx_cr_when_elig_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91184_PRDCT_FLX_CR_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_no_std_rt_used_flag
      <> nvl(ben_abr_shd.g_old_rec.no_std_rt_used_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_std_rt_used_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_std_rt_used_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91185_NO_STD_RT_US_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
    -- If no standard Rate Used Flag is "on", then uses Variable Rate flag
    -- must be "on".
    If P_NO_STD_RT_USED_FLAG = 'Y' and P_USES_VARBL_RT_FLAG <> 'Y' then
       fnd_message.set_name('BEN','BEN_91417_INVLD_STD_VRBL_FLAGS');
       fnd_message.raise_error;
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_uses_pymt_sched_flag
      <> nvl(ben_abr_shd.g_old_rec.uses_pymt_sched_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_uses_pymt_sched_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_uses_pymt_sched_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91186_USES_PYMT_SCHED_FLAG');
      fnd_message.raise_error;
      --
    end if;
/*  --
    -- Process each pay period and Uses payment frequecy flags must be
    -- mutually exclusive.
    if p_proc_each_pp_dflt_flag is not null and (
      (p_uses_pymt_sched_flag = 'Y' and p_proc_each_pp_dflt_flag = 'Y' ) or
      (p_uses_pymt_sched_flag = 'N' and p_proc_each_pp_dflt_flag = 'N'))
    then
      --
      fnd_message.set_name('BEN','BEN_91412_PROC_PP_PYMT_SCHED_F');
      fnd_message.raise_error;
      --
    end if;*/
  end if;
  --
  if (l_api_updating
      and p_val_ovrid_alwd_flag
      <> nvl(ben_abr_shd.g_old_rec.val_ovrid_alwd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_val_ovrid_alwd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_val_ovrid_alwd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91187_VAL_OVRID_ALWD_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_no_mx_elcn_val_dfnd_flag
      <> nvl(ben_abr_shd.g_old_rec.no_mx_elcn_val_dfnd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mx_elcn_val_dfnd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_elcn_val_dfnd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91188_NO_MX_ELCN_VAL_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_entr_val_at_enrt_flag
      <> nvl(ben_abr_shd.g_old_rec.entr_val_at_enrt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_entr_val_at_enrt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_entr_val_at_enrt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91189_ENT_VAL_AT_ENRT_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_entr_ann_val_flag
      <> nvl(ben_abr_shd.g_old_rec.entr_ann_val_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_entr_ann_val_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_entr_ann_val_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_entr_ann_val_flag');
      fnd_message.set_token('VALUE', p_entr_ann_val_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;

  -- if the enter annual val flag is on, the enter val at enrollment flag must
  -- be on.  If either is on, display-on-enrollment and assign-on-enrollment
  -- flags must be on.
  if p_entr_ann_val_flag = 'Y' and p_entr_val_at_enrt_flag = 'N' then
     fnd_message.set_name('BEN','BEN_92416_ENTR_FLAGS');
     fnd_message.raise_error;
  end if;
  --Bug 2172033 error this only if p_acty_typ_cd is not like CWB%
  --
  if substr(p_acty_typ_cd,1,3) <> 'CWB' then
    --
    if p_entr_val_at_enrt_flag = 'Y'
       and (p_dsply_on_enrt_flag = 'N' or p_asn_on_enrt_flag = 'N') then
       fnd_message.set_name('BEN','BEN_92417_ENTR_FLAGS2');
       fnd_message.raise_error;
    end if;
    --
  end if;
  --
  if p_acty_typ_cd = 'SSDSPLY' and p_dsply_on_enrt_flag = 'N' then
     fnd_message.set_name ('BEN','BEN_92629_ENTR_FLAGS3');
     fnd_message.raise_error;
  end if;

   if (l_api_updating
      and p_no_mn_elcn_val_dfnd_flag
      <> nvl(ben_abr_shd.g_old_rec.no_mn_elcn_val_dfnd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mn_elcn_val_dfnd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mn_elcn_val_dfnd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91190_NO_MN_EL_DFND_FLAG');
      fnd_message.raise_error; --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_only_one_bal_typ_alwd_flag
      <> nvl(ben_abr_shd.g_old_rec.only_one_bal_typ_alwd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_only_one_bal_typ_alwd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_only_one_bal_typ_alwd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91410_ONE_BAL_TYPE_ALWD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_ele_rqd_flag
      <> nvl(ben_abr_shd.g_old_rec.ele_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_ele_rqd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_ele_rqd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_ele_rqd_flag');
      fnd_message.set_token('VALUE', p_ele_rqd_flag);
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_subj_to_imptd_incm_flag
      <> nvl(ben_abr_shd.g_old_rec.subj_to_imptd_incm_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_subj_to_imptd_incm_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_subj_to_imptd_incm_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_subj_to_imptd_incm_flag');
      fnd_message.set_token('VALUE', p_subj_to_imptd_incm_flag);
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  -- When Activity rates are for Flex Credits Calculations.
  -- Set Assign on Enrollment Flag to "on"
  -- Set Enter value at Enrollment Flag to 'off"
  -- Set Predict Flex Credits when eligible flag to "on"
  -- Check for values rather than setting them is desirable ???
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_all_flags;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_estonly_no_ptd_fctr >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure ensures that the period to date comp level factor is null
--   when the "Year to date Contribution Code" is "Estimate Only"
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ptd_comp_lvl_fctr_id          Period to Date Comp. Level Factor.
--   det_pl_ytd_cntrs_cd           Plan Year-To-Date Contribution Code.
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
Procedure chk_estonly_no_ptd_fctr(p_ptd_comp_lvl_fctr_id       in number,
                                  p_det_pl_ytd_cntrs_cd        in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_estonly_no_ptd_fctr';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Period to Date Comp. Level Factor and the value of "Estimate Only"
  -- for Plan Year-To-Date Contribution Code are mutually exclusive.
  --
  if p_det_pl_ytd_cntrs_cd = 'ESTONLY' and
     p_ptd_comp_lvl_fctr_id is not null  then
      --
      fnd_message.set_name('BEN','BEN_92515_ESTONLY_NO_PTD_FCTR');
      fnd_message.raise_error;
      --
  end if;
  --
end chk_estonly_no_ptd_fctr;
--
 ----------------------------------------------------------------------------
-- |----------------------< chk_acty_type >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure ensures that if activity type begins with 'PRD' then
--   the plan must have 'allows reimbursment' on and the plan can have
--   only one of these rates and element type is non recurring
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   acty_base_rt_id               Activity Base Rate Id
--   acty_type_cd                  Activity Type Code
--   pl_id                         Plan Id
--   effective_start_date
--   business_group_id
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
Procedure chk_acty_type(p_acty_base_rt_id     in number,
                        p_acty_typ_cd         in varchar2,
                        p_sub_acty_typ_cd         in varchar2,
                        p_pl_id               in number,
                        p_effective_start_date in   date,
                        p_business_group_id   in number,
                        p_plip_id             in number ) is
  --
  l_dummy    char(1);
  cursor c1 is select null
             from   ben_acty_base_rt_f
             Where  acty_base_rt_id <> nvl(p_acty_base_rt_id,-1)
             and    acty_typ_cd = p_acty_typ_cd
             and    pl_id       = p_pl_id
             and    p_effective_start_date between effective_start_date and effective_end_date
             and    business_group_id = p_business_group_id;
  --
  cursor c_pln is select alws_reimbmts_flag
             from ben_pl_f
             where pl_id = p_pl_id
             and   p_effective_start_date between effective_start_date and effective_end_date
             and   business_group_id = p_business_group_id;


  cursor c_plip  is select pl.alws_reimbmts_flag
             from ben_pl_f pl ,
                  ben_plip_f plip
             where plip.plip_id = p_plip_id
             and   p_effective_start_date between plip.effective_start_date and plip.effective_end_date
             and   plip.business_group_id = p_business_group_id
             and   pl.pl_id = plip.pl_id
             and   p_effective_start_date between pl.effective_start_date and pl.effective_end_date
             and   pl.business_group_id = p_business_group_id;

  --
  l_alws_reimbmts_flag  varchar2(1);
  l_proc                varchar2(72) := g_package||'chk_acty_type';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if substr(p_acty_typ_cd,1,3) = 'PRD' then
     --
     open c1;
     fetch c1 into l_dummy;
     if c1%FOUND then
        close c1;
        fnd_message.set_name('BEN','BEN_92656_ONE_RT_REIMBMTS');
        fnd_message.raise_error;
     end if;
     close c1;
     --
    if p_pl_id is not null then
       open c_pln;
       fetch c_pln into l_alws_reimbmts_flag;
       close c_pln;
    elsif p_plip_id is not null then
       open c_plip;
       fetch c_plip into l_alws_reimbmts_flag;
       close c_plip;
    end if ;
     --
     if nvl(l_alws_reimbmts_flag,'N') <> 'Y' then
         fnd_message.set_name('BEN','BEN_92655_ALWS_REIMBMTS_FLAG');
         fnd_message.raise_error;
     end if;
   --
  end if;
  /*
  -- Commented : Bug 3570935
  --when the  acty type cd in ( 'CWBWS' , CWBAHE)  then the sub_acty_typ_cd should have value
  if p_acty_typ_cd in ( 'CWBWS', 'CWBAHE') then
     if p_sub_acty_typ_cd is null then
        fnd_message.set_name('BEN','BEN_93738_CWB_SACTY_TYP_ERR');
        fnd_message.raise_error;
     end if ;
  end if ;
  */

  -- check if value of lookup falls within lookup type.
  --
  if p_sub_acty_typ_cd is not  null then
    --
    /*
    -- Commented : Bug 3570935
    if p_acty_typ_cd not in (  'CWBWS' , 'CWBAHE') then
       fnd_message.set_name('BEN','BEN_93739_CWB_SACTY_NOT_NULL');
       fnd_message.raise_error;
    end if ;
    */
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_SUB_ACTY_TYP',
           p_lookup_code    => p_sub_acty_typ_cd ,
           p_effective_date => p_effective_start_date) then
       --
       -- raise error as does not exist as lookup
       --
       fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
       fnd_message.set_token('FIELD', 'sub_acty_typ_cd');
       fnd_message.set_token('VALUE', p_sub_acty_typ_cd);
       fnd_message.set_token('TYPE', 'BEN_SUB_ACTY_TYP');
       fnd_message.raise_error;
       --
    end if ;
  end if ;

  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
End chk_acty_type;

-- ----------------------------------------------------------------------------
-- |---------------------< chk_lwr_lmt_val_and_rl >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that lwr_lmt_val and lwr_lmt_calc_rl
--        are mutually exclusive.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   acty_base_rt_id               PK of record being inserted or updated.
--   lwr_lmt_val                   Lower Limit Value.
--   lwr_lmt_calc_rl               Lower Limit Value Rule.
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
Procedure chk_lwr_lmt_val_and_rl(p_acty_base_rt_id               in number,
                                 p_lwr_lmt_val                   in number,
                                 p_lwr_lmt_calc_rl               in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_lwr_lmt_val_and_rl';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- Lower Limit Value and Lower Limit Value Rule fields must be
    -- mutually exclusive.
    if (p_lwr_lmt_val is not null and p_lwr_lmt_calc_rl is not null)
    then
      --
      fnd_message.set_name('BEN','BEN_91859_LWR_LMT_VAL_AND_RL');
      fnd_message.raise_error;
      --
    end if;
end chk_lwr_lmt_val_and_rl;
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
-- Bug 3460673
-- ----------------------------------------------------------------------------
-- |---------------------< chk_incr_val_less_than_max_val >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if INCRMT_ELCN_VAL should be less
--   less than MX_ELCN_VAL.
--
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   incrmt_elcn_val               Increment Value.
--   mx_elcn_val                   Max Value.
--   ann_mx_elcn_val             Annual Max Value.
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
Procedure chk_incr_val_less_than_max_val (p_incrmt_elcn_val               in number,
                                          p_mx_elcn_val                   in number,
					  p_ann_mx_elcn_val                 in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_incr_val_less_than_max_val';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- Increment Value should not be greater than Max Value
    -- bug 3947162 --absolute value check --
    if (p_incrmt_elcn_val is not null and p_mx_elcn_val is not null) and
       (p_incrmt_elcn_val > abs(p_mx_elcn_val))
    then
      --
      fnd_message.set_name('BEN','BEN_93881_INCR_GRTR_TH_MAX_ERR');
      fnd_message.set_token('MAX_FIELD','Max');
      fnd_message.raise_error;
      null;
      --
    end if;
  --
  --
    -- Increment Value should not be greater than Annual Max Value
    -- bug 3947162 --absolute value check --
    if (p_incrmt_elcn_val is not null and p_ann_mx_elcn_val is not null) and
       (p_incrmt_elcn_val > abs(p_ann_mx_elcn_val ))
    then
      --
      fnd_message.set_name('BEN','BEN_93881_INCR_GRTR_TH_MAX_ERR');
      fnd_message.set_token('MAX_FIELD','Annual Max');
      fnd_message.raise_error;
      null;
      --
    end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
end chk_incr_val_less_than_max_val;
--Bug 3460673
--

--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_upr_lmt_val_and_rl >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that upr_lmt_val and upr_lmt_calc_rl
--        are mutually exclusive.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   acty_base_rt_id               PK of record being inserted or updated.
--   upr_lmt_val                   Upper Limit Value.
--   upr_lmt_calc_rl               Upper Limit Value Rule.
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
Procedure chk_upr_lmt_val_and_rl(p_acty_base_rt_id               in number,
                                 p_upr_lmt_val                   in number,
                                 p_upr_lmt_calc_rl               in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_upr_lmt_val_and_rl';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- Upper Limit Value and Upper Limit Value Rule fields must be
    -- mutually exclusive.
    if (p_upr_lmt_val is not null and p_upr_lmt_calc_rl is not null)
    then
      --
      fnd_message.set_name('BEN','BEN_91860_UPR_LMT_VAL_AND_RL');
      fnd_message.raise_error;
      --
    end if;
end chk_upr_lmt_val_and_rl;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_abr_seq_num >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that abr_seq_num is specified only
--   for the plan types with option usage as 'ABSENCES'
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_id
--   oipl_id
--   opt_id
--   p_abr_seq_num
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
Procedure chk_abr_seq_num(p_pl_id                in number,
                          p_oipl_id              in number,
			  p_opt_id               in number,
                          p_abr_seq_num          in number,
			  p_effective_start_date in date,
                          p_business_group_id    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_abr_seq_num';
  l_pl_id        ben_pl_f.pl_id%type;
  l_dummy        char(1);
  --
  cursor get_plan_id is
    select pl_id
       from ben_oipl_f
         where oipl_id = p_oipl_id
	   and business_group_id = p_business_group_id
	   and p_effective_start_date between effective_start_date and effective_end_date;
  --
  cursor chk_opt_usg_pltyp is
           select null
             from   BEN_PL_TYP_F
               where  PL_TYP_ID  in (select pl_typ_id
                                      from BEN_PL_TYP_OPT_TYP_F
                                       where opt_id = p_opt_id
                	               and business_group_id = p_business_group_id
				       and p_effective_start_date between effective_start_date and effective_end_date)
               and    OPT_TYP_CD  = 'ABS'
               and    p_effective_start_date between effective_start_date and effective_end_date
               and    business_group_id = p_business_group_id;
  --
  cursor chk_opt_usg_pl(p_pl_id number) is
           select null
             from   BEN_PL_TYP_F
               where  PL_TYP_ID   = (select pl_typ_id from ben_pl_f
	                              where pl_id = p_pl_id
				      and business_group_id = p_business_group_id
				      and p_effective_start_date between effective_start_date and effective_end_date)
               and    OPT_TYP_CD  = 'ABS'
               and    p_effective_start_date between effective_start_date and effective_end_date
               and    business_group_id = p_business_group_id;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_abr_seq_num is not null then
    --
    if p_opt_id is not null then
      open chk_opt_usg_pltyp;
      fetch chk_opt_usg_pltyp into l_dummy;
        if chk_opt_usg_pltyp%NOTFOUND then
          close chk_opt_usg_pltyp;
          fnd_message.set_name('BEN','BEN_ABR_SEQ_NUM_NOT_ALLOWED');
          fnd_message.raise_error;
        end if;
      close chk_opt_usg_pltyp;
    --
    else
    --
      if p_oipl_id is not null then
         open get_plan_id;
        fetch get_plan_id into l_pl_id;
        close get_plan_id;
      else                                      -- pl_id is not null
        l_pl_id := p_pl_id;
      end if;
      --
      open chk_opt_usg_pl(l_pl_id);
      fetch chk_opt_usg_pl into l_dummy;
        if chk_opt_usg_pl%NOTFOUND then
	   close chk_opt_usg_pl;
           fnd_message.set_name('BEN','BEN_ABR_SEQ_NUM_NOT_ALLOWED');
           fnd_message.raise_error;
        end if;
      close chk_opt_usg_pl;
      --
    end if;
    --
  end if;
  --
end chk_abr_seq_num;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_all_lookups >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup values are valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   acty_base_rt_id               PK of record being inserted or updated.
--   acty_typ_cd                   Value of lookup code.
--   rt_typ_cd                     Value of lookup code.
--   bnft_rt_typ_cd                Value of lookup code.
--   tx_typ_cd                     Value of lookup code.
--   parnt_chld_cd                 Value of lookup code.
--   rt_mlt_cd                     Value of lookup code.
--   rcrrg_cd                      Value of lookup code.
--   rndg_cd                       Value of lookup code.
--   prtl_mo_det_mthd_cd           Value of lookup code.
--   acty_base_rt_stat_cd          Value of lookup code.
--   procg_src_cd                  Value of lookup code.
--   frgn_erg_ded_typ_cd           Value of lookup code.
--   prtl_mo_eff_dt_det_cd         Value of lookup code.
--   effective_date               effective date
--   object_version_number        Object version number of record being
--                                inserted or updated.
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
Procedure chk_all_lookups(p_acty_base_rt_id               in number,
                          p_acty_typ_cd                   in varchar2,
                          p_rt_typ_cd                     in varchar2,
                          p_bnft_rt_typ_cd                in varchar2,
                          p_tx_typ_cd                     in varchar2,
                          p_parnt_chld_cd                 in varchar2,
                          p_rt_mlt_cd                     in varchar2,
                          p_rcrrg_cd                      in varchar2,
                          p_rndg_cd                       in varchar2,
                          p_prtl_mo_det_mthd_cd           in varchar2,
                          p_acty_base_rt_stat_cd          in varchar2,
                          p_procg_src_cd                  in varchar2,
                          p_frgn_erg_ded_typ_cd           in varchar2,
                          p_prtl_mo_eff_dt_det_cd         in varchar2,
                          p_rt_usg_cd                     in varchar2,
                          p_prort_mn_ann_elcn_val_cd      in varchar2,
                          p_prort_mx_ann_elcn_val_cd      in varchar2,
                          p_one_ann_pymt_cd               in varchar2,
                          p_det_pl_ytd_cntrs_cd           in varchar2,
                          p_asmt_to_use_cd                in varchar2,
			  p_currency_det_cd               in varchar2,
                          p_effective_date                in date,
                          p_object_version_number         in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_all_lookups';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_abr_shd.api_updating
    (p_acty_base_rt_id             => p_acty_base_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rt_usg_cd
      <> nvl(ben_abr_shd.g_old_rec.rt_usg_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_usg_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RT_USG',
           p_lookup_code    => p_rt_usg_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91431_INVLD_RT_USG_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_prort_mn_ann_elcn_val_cd
      <> nvl(ben_abr_shd.g_old_rec.prort_mn_ann_elcn_val_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prort_mn_ann_elcn_val_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PRORT_ANN_ELCN_VAL',
           p_lookup_code    => p_prort_mn_ann_elcn_val_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_prort_mn_ann_elcn_val_cd');
      fnd_message.set_token('VALUE', p_prort_mn_ann_elcn_val_cd);
      fnd_message.set_token('TYPE','BEN_PRORT_ANN_ELCN_VAL');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_prort_mx_ann_elcn_val_cd
      <> nvl(ben_abr_shd.g_old_rec.prort_mx_ann_elcn_val_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prort_mx_ann_elcn_val_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PRORT_ANN_ELCN_VAL',
           p_lookup_code    => p_prort_mx_ann_elcn_val_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_prort_mx_ann_elcn_val_cd');
      fnd_message.set_token('VALUE', p_prort_mx_ann_elcn_val_cd);
      fnd_message.set_token('TYPE','BEN_PRORT_ANN_ELCN_VAL');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_one_ann_pymt_cd
      <> nvl(ben_abr_shd.g_old_rec.one_ann_pymt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_one_ann_pymt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ONE_ANN_PYMT',
           p_lookup_code    => p_one_ann_pymt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_one_ann_pymt_cd');
      fnd_message.set_token('VALUE', p_one_ann_pymt_cd);
      fnd_message.set_token('TYPE','BEN_ONE_ANN_PYMT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_acty_typ_cd
      <> nvl(ben_abr_shd.g_old_rec.acty_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_acty_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ACTY_TYP',
           p_lookup_code    => p_acty_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91191_ACTY_TYP_CD');
      fnd_message.raise_error;
      --
    end if;
    --
    -- If Activity Type Code = Distribution, the Partial Month
    -- Determination Method Code must be blank.
    If p_rt_usg_cd = 'FLXCR' and p_acty_typ_cd in ('ERPYD', 'EEPYD')
       and p_PRTL_MO_DET_MTHD_CD is not null
    then
        fnd_message.set_name('BEN','BEN_91418_PRTL_MO_DET_CD_NOTNL');
        fnd_message.raise_error;
    end if;
  end if;
  --
  --
  if (l_api_updating
      and p_rt_typ_cd
      <> nvl(ben_abr_shd.g_old_rec.rt_typ_cd,hr_api.g_varchar2)
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
      fnd_message.set_name('BEN','BEN_91192_RT_TYP_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_bnft_rt_typ_cd
      <> nvl(ben_abr_shd.g_old_rec.bnft_rt_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnft_rt_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RT_TYP',
           p_lookup_code    => p_bnft_rt_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91192_RT_TYP_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  --
  if (l_api_updating
      and p_tx_typ_cd
      <> nvl(ben_abr_shd.g_old_rec.tx_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_tx_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_TX_TYP',
           p_lookup_code    => p_tx_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91193_INVLD_TX_TYP_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  --
  if (l_api_updating
      and p_parnt_chld_cd
      <> nvl(ben_abr_shd.g_old_rec.parnt_chld_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_parnt_chld_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PRNT_CHLD',
           p_lookup_code    => p_parnt_chld_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91194_INVLD_PARNT_CHLD_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  --
  if (l_api_updating
      and p_rt_mlt_cd
      <> nvl(ben_abr_shd.g_old_rec.rt_mlt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_mlt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_MLT',
           p_lookup_code    => p_rt_mlt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91195_INVLD_RT_MLT_CD');
      fnd_message.raise_error;
      --
    end if;
    --
--  COMMENT OUT PER BUG# 894
--  -- Rate Multiple code = Balance Type or Comp lvl Factor
--  if p_rt_usg_cd = 'FLXCR' and
--     p_rt_mlt_cd not in ('BALTYP', 'COMPLVLFCTR', 'NONE') THEN
--     fnd_message.set_name('BEN','BEN_91416_INVLD_MLT_FOR_FLXCR');
--     fnd_message.raise_error;
--  end if;
--
  end if;
  --
  --
  if (l_api_updating
      and p_rcrrg_cd
      <> nvl(ben_abr_shd.g_old_rec.rcrrg_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rcrrg_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RCRRG',
           p_lookup_code    => p_rcrrg_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91196_INVLD_RCRRG_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  --
  if (l_api_updating
      and p_rndg_cd
      <> nvl(ben_abr_shd.g_old_rec.rndg_cd,hr_api.g_varchar2)
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
      fnd_message.set_name('BEN','BEN_91041_INVALID_RNDG_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  --
  if (l_api_updating
      and p_prtl_mo_det_mthd_cd
      <> nvl(ben_abr_shd.g_old_rec.prtl_mo_det_mthd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prtl_mo_det_mthd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PRTL_MO_DET_MTHD',
           p_lookup_code    => p_prtl_mo_det_mthd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91200_INVLD_PRTL_MO_DET_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  --
  if (l_api_updating
      and p_acty_base_rt_stat_cd
      <> nvl(ben_abr_shd.g_old_rec.acty_base_rt_stat_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_acty_base_rt_stat_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_STAT',
           p_lookup_code    => p_acty_base_rt_stat_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_21201_INVLD_BASE_RT_STA_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  --
  if (l_api_updating
      and p_procg_src_cd
      <> nvl(ben_abr_shd.g_old_rec.procg_src_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_procg_src_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PROCG_SRC',
           p_lookup_code    => p_procg_src_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91203_INVLD_PROCG_SRC_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  --
  if (l_api_updating
      and p_frgn_erg_ded_typ_cd
      <> nvl(ben_abr_shd.g_old_rec.frgn_erg_ded_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_frgn_erg_ded_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ERG_DED',
           p_lookup_code    => p_frgn_erg_ded_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91204_FRGN_ERG_DED_TYP_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  --
  if (l_api_updating
      and p_prtl_mo_eff_dt_det_cd
      <> nvl(ben_abr_shd.g_old_rec.prtl_mo_eff_dt_det_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prtl_mo_eff_dt_det_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PRTL_MO_EFF_DT_DET',
           p_lookup_code    => p_prtl_mo_eff_dt_det_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91205_PRTL_MO_EFF_DT_DE_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_det_pl_ytd_cntrs_cd
      <> nvl(ben_abr_shd.g_old_rec.det_pl_ytd_cntrs_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_det_pl_ytd_cntrs_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_DET_PL_YTD_CNTRS',
           p_lookup_code    => p_det_pl_ytd_cntrs_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_det_pl_ytd_cntrs_cd');
      fnd_message.set_token('VALUE', p_det_pl_ytd_cntrs_cd);
      fnd_message.set_token('TYPE','BEN_DET_PL_YTD_CNTRS');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_asmt_to_use_cd
      <> nvl(ben_abr_shd.g_old_rec.asmt_to_use_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_asmt_to_use_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ASMT_TO_USE',
           p_lookup_code    => p_asmt_to_use_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_asmt_to_use_cd');
      fnd_message.set_token('VALUE', p_asmt_to_use_cd);
      fnd_message.set_token('TYPE','BEN_ASMT_TO_USE');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
   if (l_api_updating
      and p_currency_det_cd
      <> nvl(ben_abr_shd.g_old_rec.currency_det_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_currency_det_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_CUR_DET',
           p_lookup_code    => p_currency_det_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_currency_det_cd');
      fnd_message.set_token('VALUE', p_currency_det_cd);
      fnd_message.set_token('TYPE','BEN_CUR_DET');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_all_lookups;
--
-- ----------------------------------------------------------------------------
-- |------< chk_prtl_mo_det_mthd_cd_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the code/rule dependency as the
--   following:
--              If Code =  'Rule' then rule must be selected.
--              If Code <> 'Rule' thne rule must not be selected.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtl_mo_det_mthd_cd        Value of look up value.
--   prtl_mo_det_mthd_rl        value of look up Value
--                              inserted or updated.
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
Procedure chk_prtl_mo_det_mthd_cd_rl(p_prtl_mo_det_mthd_cd      in varchar2,
                                p_prtl_mo_det_mthd_rl           in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtl_mo_det_mthd_cd_rl';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if    (p_prtl_mo_det_mthd_cd <> 'RL' and p_prtl_mo_det_mthd_rl is not null)
  then
                fnd_message.set_name('BEN','BEN_91730_NO_RULE');
                fnd_message.raise_error;
  end if;

  if (p_prtl_mo_det_mthd_cd = 'RL' and p_prtl_mo_det_mthd_rl is null)
  then
                fnd_message.set_name('BEN','BEN_91731_RULE');
                fnd_message.raise_error;
  end if;
  --
  -- Leaving Procedure.
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtl_mo_det_mthd_cd_rl;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_rndg_cd_rl >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the code/rule dependency as the
--   following:
--              If Code =  'Rule' then rule must be selected.
--              If Code <> 'Rule' thne rule must not be selected.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   rndg_cd                    Value of look up value.
--   rndg_rl                    value of look up Value
--                              inserted or updated.
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
Procedure chk_rndg_cd_rl       (p_rndg_cd          in varchar2,
                                p_rndg_rl          in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rndg_cd_rl';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check dependency of Code and Rule.
        --
        if (p_rndg_cd <> 'RL' and
            p_rndg_rl is not null) then
                fnd_message.set_name('BEN','BEN_91732_NO_RNDG_RULE');
                fnd_message.raise_error;
        end if;

        if (p_rndg_cd = 'RL' and p_rndg_rl is null) then
                fnd_message.set_name('BEN','BEN_91733_RNDG_RULE');
                fnd_message.raise_error;
        end if;

  --
  -- Leaving Procedure.
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rndg_cd_rl;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_ann_rts >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check:
--    1. the mn/mx_ann_elcn_val code/rule dependency as the following:
--              If Code =  'Rule' then rule must be selected.
--              If Code <> 'Rule' thne rule must not be selected.
--    2. clm and ptd comp level factor id's can't be the same
--    3. these 6 fields can only be filled in when the entr_ann_val_flag is on.
--
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prort_mn_ann_elcn_val_cd
--   prort_mn_ann_elcn_val_rl
--   prort_mx_ann_elcn_val_cd
--   prort_mx_ann_elcn_val_rl
--   clm_comp_lvl_fctr_id
--   ptd_comp_lvl_fctr_id
--
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
Procedure chk_ann_rts    (p_prort_mn_ann_elcn_val_cd   in varchar2
                         ,p_prort_mn_ann_elcn_val_rl   in number
                         ,p_prort_mx_ann_elcn_val_cd   in varchar2
                         ,p_prort_mx_ann_elcn_val_rl   in number
                         ,p_clm_comp_lvl_fctr_id       in number
                         ,p_ptd_comp_lvl_fctr_id       in number
                         ,p_entr_ann_val_flag          in varchar2
                         ,p_rt_mlt_cd                  in varchar2 ) is
  --
  l_proc         varchar2(72) := g_package||'chk_ann_rts';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check dependency of Code and Rule.
  --
  if (p_prort_mn_ann_elcn_val_cd <> 'RL' and
      p_prort_mn_ann_elcn_val_rl is not null) or
      (p_prort_mx_ann_elcn_val_cd <> 'RL' and
      p_prort_mx_ann_elcn_val_rl is not null) then
      fnd_message.set_name('BEN','BEN_91730_NO_RULE');
      fnd_message.raise_error;
  end if;

  if (p_prort_mn_ann_elcn_val_cd = 'RL'
     and p_prort_mn_ann_elcn_val_rl is null) or
     (p_prort_mx_ann_elcn_val_cd = 'RL'
     and p_prort_mx_ann_elcn_val_rl is null) then
     fnd_message.set_name('BEN','BEN_91731_RULE');
     fnd_message.raise_error;
  end if;

  -- check comp lvl fctrs
  if p_clm_comp_lvl_fctr_id = p_ptd_comp_lvl_fctr_id then
     fnd_message.set_name('BEN','BEN_92414_SAME_COMP_FCTRS');
     fnd_message.raise_error;
  end if;

  -- check entr ann val flag dependency
  -- Bug 4016477. Should able to use for SAREC Case also.
  --
  if (p_entr_ann_val_flag = 'N' and p_rt_mlt_cd <> 'SAREC') and
     (p_clm_comp_lvl_fctr_id is not null or
      p_ptd_comp_lvl_fctr_id is not null or
      p_prort_mn_ann_elcn_val_cd is not null or
      p_prort_mn_ann_elcn_val_rl is not null or
      p_prort_mx_ann_elcn_val_cd is not null or
      p_prort_mx_ann_elcn_val_rl is not null)  then
     fnd_message.set_name('BEN','BEN_92415_ENTR_ANN_VAL');
     fnd_message.raise_error;
  end if;

  --
  -- Leaving Procedure.
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_ann_rts;
--
-- ----------------------------------------------------------------------------
-- |------< chk_only_one_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that only one of the program or plan  or oipl or
--   ptip id is  referenced in a record.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_pgm_id ID of FK column
--   p_pl_id ID of FK column
--   p_oipl_id ID of FK column
--   p_oiplip_id ID of FK column
--   p_plip_id ID of FK column
--   p_ptip_id ID of FK column
--   p_cmbn_plip_id ID of FK column
--   p_cmbn_ptip_id ID of FK column
--   p_cmbn_ptip_opt_id ID of FK column
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
-- Local function only used by chk_only_one_id.
--
function is_id_not_null (id in number) return number is
begin
     if nvl(id, hr_api.g_number) <> hr_api.g_number then
        return 1;
     else
        return 0;
     end if;
end;
--
--
Procedure chk_only_one_id (p_pgm_id          in number,
                         p_oipl_id         in number,
                         p_opt_id          in number,
                         p_oiplip_id       in number,
                         p_plip_id         in number,
                         p_ptip_id         in number,
                         p_pl_id           in number,
                         p_cmbn_plip_id    in number,
                         p_cmbn_ptip_id    in number,
                         p_cmbn_ptip_opt_id    in number
                         ) is
  --
  l_proc         varchar2(72) := g_package||'chk_only_one_id';
  l_cum_id_val number := 0;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_cum_id_val := is_id_not_null(p_pgm_id) + is_id_not_null(p_pl_id) +
                  is_id_not_null(p_plip_id) + is_id_not_null(p_ptip_id) +
                  is_id_not_null(p_oipl_id) + is_id_not_null(p_cmbn_plip_id) +
                  is_id_not_null(p_cmbn_ptip_id) + is_id_not_null(p_oiplip_id)
                  + is_id_not_null(p_cmbn_ptip_opt_id)+ is_id_not_null(p_opt_id) ;
  --
  -- If more than one id is not null then raise error.
  --
  if l_cum_id_val > 1 then
     --
     -- raise error as both pl_id and pgm_id can't be not null
     --
     fnd_message.set_name('BEN','BEN_91436_ONLY_ONE_ID_ALWD');
     fnd_message.raise_error;
     --
  elsif l_cum_id_val = 0 then
     --
     -- Atleast all id values are null so raise the error
     --
     fnd_message.set_name('BEN','BEN_91437_ONE_ID_REQD');
     fnd_message.raise_error;
     --
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_only_one_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_actual_premium_asnmt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the user is not able to connect an Actual
--  Premium that has a prem_asnmt_cd = 'PROC' to the acty_base_rt
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_actl_prem_id        ID of FK column
--   p_acty_base_rt_id     Primary Key
--   p_effective_date      session date
--   p_business_group_id   business_group_id
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
-- Local function only used by chk_actual_premium_asnmt_cd.
--
Procedure chk_actual_premium_asnmt_cd(p_actl_prem_id      in number,
                                      p_acty_base_rt_id   in number,
                                      p_effective_date    in date,
                                      p_business_group_id in number
                                     ) is
  --
  l_proc   varchar2(72) := g_package||'chk_actual_premium_asnmt_cd';
  l_dummy  char(1);
  --
  cursor c1 is select null
             from   ben_actl_prem_f
             where  actl_prem_id = p_actl_prem_id
             and    prem_asnmt_cd = 'PROC'
             and    business_group_id = p_business_group_id
             and    p_effective_date between effective_start_date
                    and effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- If the actual premium that we are trying to attach to the acty_base_rt
  -- has a prem_asnmt_cd = 'PROC' then error.
  --
  if p_actl_prem_id is not null then
     --
     open c1;
     fetch c1 into l_dummy;
       if c1%found then
       --
       -- the actual premium that we are trying to attach to the
       -- acty_base_rt has a prem_asnmt_cd = 'PROC'(error)
       --
          fnd_message.set_name('BEN','BEN_92457_ACTL_PREM_PROC');
          fnd_message.raise_error;
       --
       end if;
     close c1;
     --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_actual_premium_asnmt_cd;
--
-- ----------------------------------------------------------------------------
-- |--------------------<chk_pgm_typ_code >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--     make sure the program's type code is either Flex or Flex plus Core.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_pgm_id
--     p_business_group_id
--     p_effective_date
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
Procedure chk_pgm_typ_code
          ( p_pgm_id in number
           ,p_ptip_id in number
           ,p_plip_id in number
           ,p_rt_usg_cd in varchar2
           ,p_business_group_id in number
           ,p_effective_date in date )
is
   l_proc  varchar2(72) := g_package||' chk_pgm_typ_code ';
   l_dummy char(1);
   cursor c1 is select null
                  from ben_pgm_f
                 where pgm_id = p_pgm_id
                   and (pgm_typ_cd = 'FLEX' or pgm_typ_cd = 'FPC')
                   and business_group_id = p_business_group_id
                   and p_effective_date between effective_start_date
                                            and effective_end_date;
--
   cursor c2 is select null
                 from ben_pgm_f a, ben_ptip_f b
                 where b.ptip_id = p_ptip_id
                   and a.pgm_id = b.pgm_id
                   and (a.pgm_typ_cd = 'FLEX' or pgm_typ_cd = 'FPC')
                   and b.business_group_id = p_business_group_id
                   and p_effective_date between b.effective_start_date
                                            and b.effective_end_date;
--
Begin
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   if p_pgm_id is not null and p_rt_usg_cd = 'FLXCR' then
        open c1;
        fetch c1 into l_dummy;
        if c1%notfound then
               close c1;
               fnd_message.set_name('BEN','BEN_91414_INVLD_PGM_FOR_FLXCR');
               fnd_message.raise_error;
        end if;
        close c1;
   end if;
   --
   if p_ptip_id is not null and p_rt_usg_cd = 'FLXCR' then
        open c2;
        fetch c2 into l_dummy;
        if c2%notfound then
               close c2;
               fnd_message.set_name('BEN','BEN_91414_INVLD_PGM_FOR_FLXCR');
               fnd_message.raise_error;
        end if;
        close c2;
   end if;
   --
   hr_utility.set_location('Leaving:'||l_proc, 15);
   --
End chk_pgm_typ_code;
--
/*-- ----------------------------------------------------------------------------
-- |----------------------------< chk_organization_id >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the referenced foriegn key actually exists
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   acty_base_rt_id               PK of record being inserted or updated.
--   p_organization_id            Id of FK column
--   effective_date               effective date
--   object_version_number        Object version number of record being
--                                inserted or updated.
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
Procedure chk_organization_id(p_acty_base_rt_id        in number,
                            p_organization_id          in number,
			    p_effective_date           in date,
                            p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_organization_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   hr_organization_units a
    where  a.organization_id = p_organization_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_abr_shd.api_updating
     (p_acty_base_rt_id       => p_acty_base_rt_id,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_organization_id,hr_api.g_number)
     <> nvl(ben_abr_shd.g_old_rec.organization_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if organization_id value exists in hr_organization_units table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in hr_organization_units
        -- table.
        --
        ben_abr_shd.constraint_error('BEN_ACTY_BASE_RT_FK4');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_organization_id;
--
*/

--
-- ----------------------------------------------------------------------------
-- |--------------------------------< chk_pay_rate_grade_rule_id >-------------------------------|
-- ----------------------------------------------------------------------------
--


Procedure chk_pay_rate_grade_rule_id(p_acty_base_rt_id            in number,
                                     p_pay_rate_grade_rule_id     in number,
                                     p_pl_id                      in number,
                                     p_opt_id                     in number,
                                     p_business_group_id          in number,
                                     p_effective_date             in date,
                                     p_object_version_number      in number
                                     ) is
  --
  l_proc         varchar2(72) := g_package||'chk_pay_rate_grade_rule_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c2 is
  select 'x'
      From pay_grade_rules_f a , pay_rates b , per_spinal_points c,ben_opt_f opt
      where   a.grade_rule_id = p_pay_rate_grade_rule_id
          and a.rate_id = b.rate_id
          and a.rate_type = 'SP'
          and c.spinal_point_id = a.grade_or_spinal_point_id
          and c.spinal_point_id = opt.mapping_table_pk_id
          and opt.mapping_table_name = 'PER_SPINAL_POINTS'
          and a.business_group_id   = p_business_group_id
          and c.business_group_id       = p_business_group_id
          and b.business_group_id       = p_business_group_id
          and opt.business_group_id     = p_business_group_id
          and opt.opt_id                = p_opt_id
          and p_effective_date   between a.effective_start_date and a.effective_end_date
          and p_effective_date   between opt.effective_start_date and opt.effective_end_date ;


   cursor c1 is
   select 'x'
      From pay_grade_rules_f a , pay_rates b , per_grades c,ben_pl_f pl
      where   a.grade_rule_id = p_pay_rate_grade_rule_id
          and a.rate_id = b.rate_id
          and a.rate_type = 'G'
          and c.grade_id = a.grade_or_spinal_point_id
          and c.grade_id            = pl.mapping_table_pk_id
          and pl.mapping_table_name = 'PER_GRADES'
          and a.business_group_id   = p_business_group_id
          and c.business_group_id   = p_business_group_id
          and b.business_group_id   = p_business_group_id
          and pl.business_group_id  = p_business_group_id
          and pl.pl_id              = p_pl_id
          and p_effective_date  between a.effective_start_date and a.effective_end_date
          and p_effective_date  between pl.effective_start_date and pl.effective_end_date ;

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_abr_shd.api_updating
     (p_acty_base_rt_id       => p_acty_base_rt_id,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
     and
        ( nvl(p_pay_rate_grade_rule_id,hr_api.g_number)
           <> nvl(ben_abr_shd.g_old_rec.pay_rate_grade_rule_id,hr_api.g_number)
          or
          nvl(p_pl_id,hr_api.g_number)
           <> nvl(ben_abr_shd.g_old_rec.pl_id,hr_api.g_number)
          or
          nvl(p_opt_id,hr_api.g_number)
          <> nvl(ben_abr_shd.g_old_rec.opt_id,hr_api.g_number)
        )
     or not l_api_updating) then
    --
    -- check if organization_id value exists in hr_organization_units table
    --
    if p_pl_id is not null then
       open c1;
        --
       fetch c1 into l_dummy;
       if c1%notfound then
          close c1;
         fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token('PROCEDURE', l_proc);
         fnd_message.set_token('STEP','10');
         fnd_message.raise_error;

       end if;
      --
      close c1;
       --
    End if;

     --
    if p_opt_id is not null then
       open c2;
        --
       fetch c2 into l_dummy;
       if c2%notfound then
          close c2;
         fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token('PROCEDURE', l_proc);
         fnd_message.set_token('STEP','11');
         fnd_message.raise_error;

       end if;
      --
      close c2;
       --
    End if;
  end if ;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pay_rate_grade_rule_id;




--
-- ----------------------------------------------------------------------------
-- |--------------------------------< chk_nnmntry_uom >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the referenced foriegn key actually exists
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   acty_base_rt_id               PK of record being inserted or updated.
--   p_nnmntry_uom                 FK column
--   effective_date               effective date
--   object_version_number        Object version number of record being
--                                inserted or updated.
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
Procedure chk_nnmntry_uom(p_acty_base_rt_id        in number,
                  p_nnmntry_uom                    in varchar2,
                  p_effective_date           in date,
                  p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_nnmntry_uom';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   fnd_currencies_tl
    where  currency_code = p_nnmntry_uom;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_abr_shd.api_updating
     (p_acty_base_rt_id       => p_acty_base_rt_id,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_nnmntry_uom,hr_api.g_varchar2)
     <> nvl(ben_abr_shd.g_old_rec.nnmntry_uom,hr_api.g_varchar2)
     or not l_api_updating) then
    --
    -- check if nnmntry_uom value exists in fnd_currency_tl table
    --
    if p_nnmntry_uom is not null then
       open c1;
         --
         fetch c1 into l_dummy;
         if c1%notfound then
           --
           if hr_api.not_exists_in_hr_lookups
             (p_lookup_type    => 'BEN_NNMNTRY_UOM',
              p_lookup_code    => p_nnmntry_uom,
              p_effective_date => p_effective_date) then
              --
              -- raise error as FK does not relate to PK in fnd_currencies_tl
              -- table.
              --
              fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
              fnd_message.set_token('FIELD','p_nnmntry_uom');
              fnd_message.set_token('VALUE', p_nnmntry_uom);
              fnd_message.set_token('TYPE','BEN_NNMNTRY_UOM');
              fnd_message.raise_error;
              --
           end if;
         end if;
         --
       close c1;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_nnmntry_uom;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_oab_element_typ_id >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the referenced foriegn key actually exists
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   acty_base_rt_id               PK of record being inserted or updated.
--   p_oab_element_typ_id            Id of FK column
--   effective_date               effective date
--   object_version_number        Object version number of record being
--                                inserted or updated.
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
/* Procedure chk_oab_element_typ_id(p_acty_base_rt_id        in number,
                            p_oab_element_typ_id          in number,
			    p_effective_date           in date,
                            p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_oab_element_typ_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_oab_ele_typ a
    where  a.oab_element_typ_id = p_oab_element_typ_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_abr_shd.api_updating
     (p_acty_base_rt_id       => p_acty_base_rt_id,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_oab_element_typ_id,hr_api.g_number)
     <> nvl(ben_abr_shd.g_old_rec.oab_element_typ_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if oab_element_typ_id value exists in hr_organization_units table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in hr_organization_units
        -- table.
        --
        ben_abr_shd.constraint_error('BEN_ACTY_BASE_RT_FK3');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_oab_element_typ_id; */
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_cwb_acty_typ_cd_unique>------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that CWB Plans do not have more than one
--   Active Rate defined for the same Activity Type Code. This check does not apply
--   to the Activity Type Code 'CWBAHE'. Plans may have multiple 'CWBAHE' rates
--   defined.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   acty_base_rt_id               PK of record being inserted or updated.
--   p_acty_typ_cd                 activity type code
--   p_pl_id                       plan id
--   p_oipl_id                     Option in Plan Id
--   p_acty_base_rt_stat_cd        status code
--   p_business_group_id           business group id
--   effective_date                effective date
--   object_version_number         Object version number of record being
--                                 inserted or updated.
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
Procedure chk_cwb_acty_typ_cd_unique(p_acty_base_rt_id        in number,
                                     p_acty_typ_cd            in varchar2,
                  	   	     p_pl_id                  in number,
                  	   	     p_oipl_id                in number,
                                     p_acty_base_rt_stat_cd   in varchar2,
                                     p_business_group_id      in number,
              			     p_effective_date         in date,
                                     p_object_version_number  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cwb_acty_typ_cd_unique';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_acty_typ_meaning hr_lookups.meaning%type;
  --
  cursor c1 is
    select null
    from   ben_acty_base_rt abr
    where  abr.acty_base_rt_id      <> nvl(p_acty_base_rt_id,-1)
    and    abr.acty_typ_cd          = p_acty_typ_cd
    and    abr.pl_id                = p_pl_id
    and    abr.business_group_id    = p_business_group_id
    and    abr.acty_base_rt_stat_cd = 'A'
    and    p_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date;
  --
    cursor c2 is
    select null
    from   ben_acty_base_rt abr
    where  abr.acty_base_rt_id      <> nvl(p_acty_base_rt_id,-1)
    and    abr.acty_typ_cd          = p_acty_typ_cd
    and    abr.oipl_id              = p_oipl_id
    and    abr.business_group_id    = p_business_group_id
    and    abr.acty_base_rt_stat_cd = 'A'
    and    p_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_abr_shd.api_updating
     (p_acty_base_rt_id       => p_acty_base_rt_id,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
     and (nvl(p_acty_typ_cd,hr_api.g_varchar2)
          <> nvl(ben_abr_shd.g_old_rec.acty_typ_cd,hr_api.g_varchar2)
          or
          nvl(p_pl_id,hr_api.g_number)
          <> nvl(ben_abr_shd.g_old_rec.pl_id,hr_api.g_number)
          or
          nvl(p_oipl_id,hr_api.g_number)
          <> nvl(ben_abr_shd.g_old_rec.oipl_id,hr_api.g_number)
          or
          nvl(p_acty_base_rt_stat_cd,hr_api.g_varchar2)
          <> nvl(ben_abr_shd.g_old_rec.acty_base_rt_stat_cd,hr_api.g_varchar2)
          )
     or not l_api_updating) and p_acty_base_rt_stat_cd = 'A' then
    --
    -- if the activity type code is not 'CWBAHE' then check if any
    -- another Active Rate exists for the Plan with the same Activity Type Code
    --
    if p_acty_typ_cd <> 'CWBAHE' then
      if p_oipl_id is not null then
        open c2;
        --
        fetch c2 into l_dummy;
        if c2%found then
          --
          -- raise error as a Rate already exists for the Option in the
          -- table ben_acty_base_rt_f with the same Activity Type Code.
          --
          l_acty_typ_meaning := hr_general.decode_lookup('BEN_ACTY_TYP',p_acty_typ_cd);
          fnd_message.set_name('BEN','BEN_93018_ACTY_TYP_NOT_UNIQUE');
          fnd_message.set_token('ACTY_TYPE_CODE',l_acty_typ_meaning);
          fnd_message.raise_error;
          --
        end if;
        --
        close c2;
        --
      else
        --
        open c1;
        --
        fetch c1 into l_dummy;
        if c1%found then
          --
          -- raise error as a Rate already exists for the Plan in the
          -- table ben_acty_base_rt_f with the same Activity Type Code.
          --
          l_acty_typ_meaning := hr_general.decode_lookup('BEN_ACTY_TYP',p_acty_typ_cd);
          fnd_message.set_name('BEN','BEN_93018_ACTY_TYP_NOT_UNIQUE');
          fnd_message.set_token('ACTY_TYPE_CODE',l_acty_typ_meaning);
          fnd_message.raise_error;
          --
        end if;
        --
        close c1;
        --
      end if; -- oipl_id is not null
    end if; -- CWBAHE
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_cwb_acty_typ_cd_unique;
--
-- 2940151
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< chk_acty_typ_cd_gsp >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check a comp object does not have many rates of type GSPSA
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   acty_base_rt_id               PK of record being inserted or updated.
--   p_acty_typ_cd                 Activity type code
--   effective_date               effective date
--   object_version_number        Object version number of record being
--                                inserted or updated.
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
Procedure chk_acty_typ_cd_gsp
                         (p_acty_base_rt_id        in number,
			  --p_pgm_id		   in number,
			  p_pl_id		   in number,
			  /*p_opt_id		   in number,
			  p_plip_id		   in number,
			  p_oipl_id		   in number,*/
                  	  p_acty_typ_cd            in varchar2,
                   	  p_effective_date         in date,
                   	  p_business_group_id      in number,
                   	  p_object_version_number  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_acty_typ_cd_gsp';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select 'X'
    from ben_acty_base_rt_f
    where pl_id = p_pl_id
    and p_effective_date between effective_start_date and effective_end_date
    and business_group_id = p_business_group_id
    and acty_typ_cd = 'GSPSA';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_abr_shd.api_updating
     (p_acty_base_rt_id       => p_acty_base_rt_id,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_acty_typ_cd,hr_api.g_varchar2)
     <> nvl(ben_abr_shd.g_old_rec.acty_typ_cd,hr_api.g_varchar2)
     or not l_api_updating) then
    --
    -- check if nnmntry_uom value exists in fnd_currency_tl table
    --

       open c1;
         --
         fetch c1 into l_dummy;
         if c1%found then
           --
           fnd_message.set_name('BEN','BEN_93549_ACTY_TYP_GSP');
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
End chk_acty_typ_cd_gsp;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< chk_cwb_element_currency >-------------------------------|
-- ----------------------------------------------------------------------------
--
--
Procedure chk_cwb_element_currency
                         (p_element_det_rl         in number,
			  p_currency_det_cd        in varchar2,
			  p_acty_typ_cd		   in varchar2
                   	  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_cwb_element_currency';

  --

Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --


   if  p_element_det_rl is not null and p_acty_typ_cd not like 'CWB%'  then

       --
             fnd_message.set_name('BEN','BEN_94998_CWB_INVLD');
	     fnd_message.set_token('FIELD','Element Determination Rule');
             fnd_message.raise_error;
      --
   end if;

  if  p_currency_det_cd is NOT NULL and p_acty_typ_cd not like 'CWB%' then

       --
             fnd_message.set_name('BEN','BEN_94998_CWB_INVLD');
	     fnd_message.set_token('FIELD','Currency Determination Code');
             fnd_message.raise_error;
      --
   end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_cwb_element_currency;

-- ----------------------------------------------------------------------------
-- |------------------------< future_var_rt_recs_exist >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the dt_delete_validate.
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

Function future_var_rt_recs_exist (
                             p_acty_base_rt_id       in number,
                             p_datetrack_mode        in varchar2,
                             p_validation_start_date in date,
                             p_validation_end_date   in date)
         return boolean Is
 --
  l_proc	   varchar2(72) 	:= g_package||'future_var_rt_recs_exist';
  l_Dummy          varchar2(1);
  l_fut_rows_exist Exception;
  l_curr_uses_varbl_rt_flag varchar2(30) ;
  l_return_val              boolean   := FALSE ;
--
  cursor c_fut_var_rt_recs is
    select 1
    from ben_acty_vrbl_rt_f
    where acty_base_rt_id = p_acty_base_rt_id
    and effective_start_date <= p_validation_end_date
    and effective_end_date   >= p_validation_start_date;
--
Begin
--
   hr_utility.set_location('Entering: '||l_proc,9);
 --
   l_curr_uses_varbl_rt_flag := ben_abr_shd.g_old_rec.uses_varbl_rt_flag;
 --
   If l_curr_uses_varbl_rt_flag = 'N' then
 --
 -- Get next validation start and end dates
 --
     Open c_fut_var_rt_recs;
      fetch c_fut_var_rt_recs into l_dummy;
      if c_fut_var_rt_recs%FOUND then
        l_return_val := TRUE ;
      else
        l_return_val := FALSE ;
      End If;
     close c_fut_var_rt_recs;
   End if;
  --
  hr_utility.set_location('Leaving:'||l_proc,15);
  --
  return l_return_val;
  --
End future_var_rt_recs_exist;
--
-- end
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
            (p_prtl_mo_det_mthd_rl           in number default hr_api.g_number,
             p_prtl_mo_eff_dt_det_rl         in number default hr_api.g_number,
             p_rndg_rl                       in number default hr_api.g_number,
             p_lwr_lmt_calc_rl               in number default hr_api.g_number,
             p_upr_lmt_calc_rl               in number default hr_api.g_number,
             p_val_calc_rl                   in number default hr_api.g_number,
             p_vstg_for_acty_rt_id           in number default hr_api.g_number,
             p_actl_prem_id                  in number default hr_api.g_number,
             p_parnt_acty_base_rt_id         in number default hr_api.g_number,
             p_pgm_id                        in number default hr_api.g_number,
             p_ptip_id                       in number default hr_api.g_number,
             p_oipl_id                       in number default hr_api.g_number,
             p_opt_id                        in number default hr_api.g_number,
             p_oiplip_id                     in number default hr_api.g_number,
             p_plip_id                       in number default hr_api.g_number,
             p_pl_id                         in number default hr_api.g_number,
	     -- bug: 5367301 start
	     p_element_type_id               in number default hr_api.g_number,
             p_input_va_calc_rl              in number default hr_api.g_number,
             p_element_det_rl                in number default hr_api.g_number,
	     -- bug: 5367301 end
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
    If ((nvl(p_prtl_mo_det_mthd_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_prtl_mo_det_mthd_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_prtl_mo_eff_dt_det_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_prtl_mo_eff_dt_det_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_rndg_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_rndg_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_lwr_lmt_calc_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_lwr_lmt_calc_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_upr_lmt_calc_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_upr_lmt_calc_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_val_calc_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_val_calc_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_vstg_for_acty_rt_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_vstg_for_acty_rt_f',
             p_base_key_column => 'vstg_for_acty_rt_id',
             p_base_key_value  => p_vstg_for_acty_rt_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_vstg_for_acty_rt_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_actl_prem_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_actl_prem_f',
             p_base_key_column => 'actl_prem_id',
             p_base_key_value  => p_actl_prem_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_vstg_for_acty_rt_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_pgm_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_pgm_f',
             p_base_key_column => 'pgm_id',
             p_base_key_value  => p_pgm_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_pgm_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_parnt_acty_base_rt_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_acty_base_rt_f',
             p_base_key_column => 'acty_base_rt_id',
             p_base_key_value  => p_parnt_acty_base_rt_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_acty_base_rt_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_ptip_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ptip_f',
             p_base_key_column => 'ptip_id',
             p_base_key_value  => p_ptip_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_ptip_f';
      Raise l_integrity_error;
    End If;
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
    If ((nvl(p_opt_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_opt_f',
             p_base_key_column => 'opt_id',
             p_base_key_value  => p_opt_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_opt_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_oiplip_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_oiplip_f',
             p_base_key_column => 'oiplip_id',
             p_base_key_value  => p_oiplip_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_oiplip_f';
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
    -- ELEMENT_TYPE
    -- Bug: 5367301 start
    If ((nvl(p_element_type_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'pay_element_types_f',
             p_base_key_column => 'element_type_id',
             p_base_key_value  => p_element_type_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'pay_element_types_f';
      Raise l_integrity_error;
    End If;
  --
    If ((nvl(p_input_va_calc_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_input_va_calc_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
  --
    If ((nvl(p_element_det_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_element_det_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
  --


    -- Bug: 5367301 end

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
            (p_acty_base_rt_id		in number,
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
       p_argument       => 'acty_base_rt_id',
       p_argument_value => p_acty_base_rt_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_acty_rt_ptd_lmt_f',
           p_base_key_column => 'acty_base_rt_id',
           p_base_key_value  => p_acty_base_rt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_acty_rt_ptd_lmt_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_acty_rt_pymt_sched_f',
           p_base_key_column => 'acty_base_rt_id',
           p_base_key_value  => p_acty_base_rt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_acty_rt_pymt_sched_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_acty_base_rt_f',
           p_base_key_column => 'parnt_acty_base_rt_id',
           p_base_key_value  => p_acty_base_rt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_acty_base_rt_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_acty_vrbl_rt_f',
           p_base_key_column => 'acty_base_rt_id',
           p_base_key_value  => p_acty_base_rt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_acty_vrbl_rt_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_prtl_mo_rt_prtn_val_f',
           p_base_key_column => 'acty_base_rt_id',
           p_base_key_value  => p_acty_base_rt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_prtl_mo_rt_prtn_val_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_mtchg_rt_f',
           p_base_key_column => 'acty_base_rt_id',
           p_base_key_value  => p_acty_base_rt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_mtchg_rt_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_bnft_prvdd_ldgr_f',
           p_base_key_column => 'acty_base_rt_id',
           p_base_key_value  => p_acty_base_rt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_bnft_prvdd_ldgr_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_bnft_pool_rlovr_rqmt_f',
           p_base_key_column => 'acty_base_rt_id',
           p_base_key_value  => p_acty_base_rt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_bnft_pool_rlovr_rqmt_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_aplcn_to_bnft_pool_f',
           p_base_key_column => 'acty_base_rt_id',
           p_base_key_value  => p_acty_base_rt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_aplcn_to_bnft_pool_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_vrbl_rt_rl_f',
           p_base_key_column => 'acty_base_rt_id',
           p_base_key_value  => p_acty_base_rt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_vrbl_rt_rl_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_comp_lvl_acty_rt_f',
           p_base_key_column => 'acty_base_rt_id',
           p_base_key_value  => p_acty_base_rt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_comp_lvl_acty_rt_f';
      Raise l_rows_exist;
    End If;
    --
  End If;
  -- bug 3636162, added to check any variable rate records attatched to future
  -- updates. In that case DeleteNextChange or FutureChange's should not be allowed
  If (p_datetrack_mode = 'DELETE_NEXT_CHANGE' or p_datetrack_mode = 'FUTURE_CHANGE')
     and future_var_rt_recs_exist (
           p_acty_base_rt_id ,
           p_datetrack_mode ,
           p_validation_start_date ,
           p_validation_end_date )
     then
     l_table_name := 'ben_acty_vrbl_rt_f';
     Raise l_rows_exist;
  End If;



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
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
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
--	 rt_mlt_cd
--	 val
--	 mn_elcn_val
--	 mx_elcn_val
--	 incrmt_elcn_val
--       dflt_val
--	 rt_typ_cd
--   bnft_rt_typ_cd
--   val_calc_rl
--   acty_base_rt_id
--   effective_date
--	 object_version_number
--
--
Procedure chk_mlt_cd_dependencies(p_rt_mlt_cd                   in varchar2,
                                  p_entr_val_at_enrt_flag       in varchar2,
                                  p_entr_ann_val_flag           in varchar2,
                                  p_val                         in number,
                                  p_mn_elcn_val                 in number,
                                  p_mx_elcn_val                 in number,
                                  p_incrmt_elcn_val             in number,
                                  p_dflt_val                    in number,
		                  p_rt_typ_cd                   in varchar2,
			          p_bnft_rt_typ_cd              in varchar2,
			          p_val_calc_rl                 in number,
				  p_acty_base_rt_id             in number,
                                  p_pay_rate_grade_rule_id      in number,
                                  p_acty_typ_cd                 in varchar2,
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
  l_api_updating := ben_abr_shd.api_updating
     (p_acty_base_rt_id       => p_acty_base_rt_id,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and
         (nvl(p_rt_mlt_cd,hr_api.g_varchar2)
               <> nvl(ben_abr_shd.g_old_rec.rt_mlt_cd,hr_api.g_varchar2) or
          nvl(p_val,hr_api.g_number)
               <> nvl(ben_abr_shd.g_old_rec.val,hr_api.g_number) or
          nvl(p_mn_elcn_val,hr_api.g_number)
               <> nvl(ben_abr_shd.g_old_rec.mn_elcn_val,hr_api.g_number) or
          nvl(p_mx_elcn_val,hr_api.g_number)
               <> nvl(ben_abr_shd.g_old_rec.mx_elcn_val,hr_api.g_number) or
          nvl(p_incrmt_elcn_val,hr_api.g_number)
               <> nvl(ben_abr_shd.g_old_rec.incrmt_elcn_val,hr_api.g_number) or
          -- begin bug 2282186
          nvl(p_dflt_val,hr_api.g_number)
               <> nvl(ben_abr_shd.g_old_rec.dflt_val,hr_api.g_number) or
          -- end bug 2282186
          nvl(p_rt_typ_cd,hr_api.g_varchar2)
               <> nvl(ben_abr_shd.g_old_rec.rt_typ_cd,hr_api.g_varchar2) or
          nvl(p_bnft_rt_typ_cd,hr_api.g_varchar2)
               <> nvl(ben_abr_shd.g_old_rec.bnft_rt_typ_cd,hr_api.g_varchar2) or
          nvl(p_val_calc_rl,hr_api.g_number)
               <> nvl(ben_abr_shd.g_old_rec.val_calc_rl,hr_api.g_number)
         )
      or
         not l_api_updating)
      then
	  --
          if p_entr_val_at_enrt_flag = 'N'
             and p_rt_mlt_cd in ('FLFX', 'CVG', 'CL')  then
          --
              if p_val is null then
                 --
                 fnd_message.set_name('BEN','BEN_91536_VAL_RQD');
                 fnd_message.raise_error;
                 --
              end if;
              --
              if p_mn_elcn_val is not null then
                 --
                 fnd_message.set_name('BEN','BEN_91539_MIN_VAL_SPEC');
                 fnd_message.raise_error;
                 --
              end if;
              --
              if p_mx_elcn_val is not null then
                 --
                 fnd_message.set_name('BEN','BEN_91541_MAX_VAL_SPEC');
                 fnd_message.raise_error;
                 --
              end if;
              --
              if p_incrmt_elcn_val is not null then
                 --
                 fnd_message.set_name('BEN','BEN_91543_INCRMT_VAL_SPEC');
                 fnd_message.raise_error;
                 --
              end if;
              --
              if p_dflt_val is not null then
                 --
                 -- fnd_message.set_name('BEN','BEN_91545_DFLT_VAL_SPEC'); -- Bug 2272978
                 fnd_message.set_name('BEN','BEN_91551_DFLT_VAL_SPEC');
                 fnd_message.raise_error;
                 --
              end if;
              --
          elsif p_entr_val_at_enrt_flag = 'Y'
                and p_rt_mlt_cd in ('FLFX', 'CVG', 'CL')  then
              --
              if p_val is not null then
                 --
                 fnd_message.set_name('BEN','BEN_91537_VAL_SPEC');
                 fnd_message.raise_error;
                 --
              end if;
              --
              if p_entr_ann_val_flag = 'N' and substr(p_acty_typ_cd,1,3) <> 'CWB' then
                 --
                 if p_mn_elcn_val is null then
                    --
                    fnd_message.set_name('BEN','BEN_91538_MIN_VAL_RQD');
                    fnd_message.raise_error;
                    --
                 end if;
                 --
                 if p_mx_elcn_val is null then
                    --
                    fnd_message.set_name('BEN','BEN_91540_MAX_VAL_RQD');
                    fnd_message.raise_error;
                    --
                 end if;
                 --
              end if;
              --
              if p_incrmt_elcn_val is null and substr(p_acty_typ_cd,1,3) <> 'CWB' then
                 --
                 fnd_message.set_name('BEN','BEN_91542_INCRMT_VAL_RQD');
                 fnd_message.raise_error;
                 --
              end if;
              --
              if p_dflt_val is null and substr(p_acty_typ_cd,1,3) <> 'CWB' then
                 --
                 -- fnd_message.set_name('BEN','BEN_91544_DFLT_VAL_RQD');
                 fnd_message.set_name('BEN','BEN_91550_DFLT_VAL_RQD');  -- Bug 2272978
                 fnd_message.raise_error;
                 --
              end if;
              --

              -- begin bug 2282186
              if p_dflt_val < p_mn_elcn_val or p_dflt_val > p_mx_elcn_val then
                 --
                 fnd_message.set_name('PAY','HR_INPVAL_DEFAULT_INVALID');
                 fnd_message.raise_error;
                 --
              end if;
              -- end bug 2282186

          elsif p_entr_val_at_enrt_flag = 'Y'
                and p_rt_mlt_cd in ('AP','PRNT','NSVU','RL','CLANDCVG',
                                        'APANDCVG','PRNTANDCVG') then
              --
              fnd_message.set_name('BEN','BEN_91973_ENTR_VAL_AT_ENRT');
              fnd_message.raise_error;
              --
          end if;
          --
	  if p_rt_mlt_cd is NULL then
	  --
	      fnd_message.set_name('BEN','BEN_91535_MLT_CD_RQD');
	      fnd_message.raise_error;
	  --
	  end if;
	  --
	  if p_val is NULL then
	  --
	     if p_rt_mlt_cd in ('AP','PRNT','CLANDCVG','APANDCVG',
                                'PRNTANDCBG') then
	     --
	        fnd_message.set_name('BEN','BEN_91536_VAL_RQD');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  else
	  --
	     if p_rt_mlt_cd in ('RL','NSVU') then
	     --
	        fnd_message.set_name('BEN','BEN_91537_VAL_SPEC');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  end if;
	  --
	  if p_mn_elcn_val is not NULL then
	  --
	    if p_rt_mlt_cd in ('AP','PRNT','CLANDCVG','APANDCVG',
                               'PRNTANDCVG','RL','NSVU') then
		 --
	        fnd_message.set_name('BEN','BEN_91539_MIN_VAL_SPEC');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  end if;
	  --
	  if p_mx_elcn_val is not NULL then
	  --
	     if p_rt_mlt_cd in ('AP','PRNT','CLANDCVG','APANDCVG',
                                'PRNTANDCVG','RL','NSVU') then
	     --
	        fnd_message.set_name('BEN','BEN_91541_MAX_VAL_SPEC');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  end if;
	  --
	  if p_incrmt_elcn_val is not NULL then
	  --
	     if p_rt_mlt_cd in ('AP','PRNT','CLANDCVG','APANDCVG',
                                'PRNTANDCVG','RL','NSVU') then
		   --
	          fnd_message.set_name('BEN','BEN_91543_INCRMT_VAL_SPEC');
	          fnd_message.raise_error;
	     --
	     end if;
	  --
	  end if;
          --
          if p_dflt_val is not NULL then
          --
             if p_rt_mlt_cd in ('AP','PRNT','CLANDCVG','APANDCVG',
                                'PRNTANDCVG','RL','NSVU') then
                   --
                  -- fnd_message.set_name('BEN','BEN_91545_DFLT_VAL_SPEC');
                  fnd_message.set_name('BEN','BEN_91551_DFLT_VAL_SPEC');  -- Bug 2272978
                  fnd_message.raise_error;
             --
             end if;
          --
          end if;
	  --
	  if p_rt_typ_cd is NULL then
	  --
	     if p_rt_mlt_cd in ('CL','AP','PRNT','CLANDCVG','APANDCVG',
                                'PRNTANDCVG') then
		   --
	          fnd_message.set_name('BEN','BEN_91544_RT_TYP_CD_RQD');
	          fnd_message.raise_error;
	     --
	     end if;
	  else
	  --
	     if p_rt_mlt_cd in ('FLFX','CVG','RL','NSVU') then
	     --
	        fnd_message.set_name('BEN','BEN_91545_RT_TYP_CD_SPEC');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  end if;
	  --
	  if p_bnft_rt_typ_cd is NULL then
	  --
	     if p_rt_mlt_cd in ('CVG','CLANDCVG','APANDCVG','PRNTANDCVG') then
	     --
	        fnd_message.set_name('BEN','BEN_91546_BNFTS_TYP_CD_RQD');
	        fnd_message.raise_error;
	     --
	    end if;
	   --
	  else
	  --
	     if p_rt_mlt_cd in ('FLFX','CL','AP','PRNT','RL','NSVU') then
		 --
	        fnd_message.set_name('BEN','BEN_91547_BNFTS_TYP_CD_SPEC');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  end if;
	  --
	  if p_val_calc_rl is NULL then
	  --
	     if p_rt_mlt_cd in ('RL') then
	     --
	        fnd_message.set_name('BEN','BEN_91548_VAL_CALC_RL_RQD');
	        fnd_message.raise_error;
	     --
	     end if;
	  --
	  else
	  --
	     if p_rt_mlt_cd in ('FLFX','CL','AP','CVG','PRNT',
                                'CLANDCVG','APANDCVG','PRNTANDCVG','NSVU') then
		 --
	        fnd_message.set_name('BEN','BEN_91549_VAL_CALC_RL_SPEC');
	        fnd_message.raise_error;
	     --
	     end if;
	  end if;
         --- GSP val is require when the mult cd is PRV
         if p_pay_rate_grade_rule_id is not  null and  p_rt_mlt_cd <> 'PRV'  then
             fnd_message.set_name('BEN','BEN_91544_RT_TYP_CD_RQD');
             fnd_message.raise_error;
         end if ;
--Rate by criteria
         if (p_acty_typ_cd ='RBC' and p_rt_mlt_cd <> 'NSVU') then
             fnd_message.set_name('BEN','BEN_94138_ACTY_RT_MLT_CD');
             fnd_message.raise_error;
         end if;

  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mlt_cd_dependencies;
-- ----------------------------------------------------------------------------
-- |---------------------< chk_mn_mx_rl >---------------------------|
-- BUG # 3981982
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that
-- 1. p_mn_mx_elcn_rl is mutually exclusive to p_mn_elcn_val, p_mx_elcn_val, p_incrmt_elcn_val and p_dflt_val.
-- 2. p_mn_mx_elcn_rl is NOT NULL only if
--      p_entr_val_at_enrt_flag is Y.
--      and
--      p_ acty_typ_cd is in (CWBWS, CWBRA).

-- Pre Conditions
--   None.
--
-- In Parameters
--   p_acty_base_rt_id               PK of record being inserted or updated.
--   p_mn_mx_elcn_rl
--   p_mn_elcn_val
--   p_mx_elcn_val
--   p_incrmt_elcn_val
--   p_dflt_val
--   p_entr_val_at_enrt_flag
--   p_ acty_typ_cd
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_mn_mx_rl(p_acty_base_rt_id         in number,
                       p_mn_mx_elcn_rl           in number,
                       p_mn_elcn_val             in number,
                       p_mx_elcn_val		 in number,
                       p_incrmt_elcn_val	 in number,
                       p_dflt_val		 in number,
                       p_entr_val_at_enrt_flag	 in varchar2,
                       p_acty_typ_cd		 in varchar2
                       ) is
  --
  l_proc         varchar2(72) := g_package||'chk_mn_mx_rl';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- p_mn_mx_elcn_rl is mutually exclusive to p_mn_elcn_val, p_mx_elcn_val, p_incrmt_elcn_val and p_dflt_val.
    -- mutually exclusive.
    if (   p_mn_mx_elcn_rl is not null  and p_mn_elcn_val is not null
       and p_mx_elcn_val is not null    and p_incrmt_elcn_val is not null
       and p_dflt_val is not null)
    then
      --
      fnd_message.set_name('BEN','BEN_94128_MN_MX_VAL_AND_RL');
      fnd_message.raise_error;
      --
    end if;
    --
    --p_mn_mx_elcn_rl is NOT NULL only if
    --p_entr_val_at_enrt_flag is Y.
    --and
    --p_ acty_typ_cd is in (CWBWS, CWBRA)

    if (p_mn_mx_elcn_rl is NOT NULL) then
      if (p_entr_val_at_enrt_flag <> 'Y' or p_acty_typ_cd not in ('CWBWS', 'CWBRA')) then
       --
             fnd_message.set_name('BEN','BEN_94129_MN_MX_RL_NOT_NULL');
             fnd_message.raise_error;
      --
      end if;
    end if;


end chk_mn_mx_rl;
--
-- Added on Mar 14, 2006 against Bug:5091755
--
-- |------< chk_code_rule_num >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Rule is only allowed to
--   have a value if the value of the Code = 'Rule', and if code is
--   = RL then p_rule must have a value. If cd = 'WASHRULE' then num
--   must have a value otherwise num must be null.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   P_CODE value of code item.
--   P_RULE value of rule item
--   P_NUM value of rule item
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

PROCEDURE chk_code_rule_num (
   p_code   IN   VARCHAR2,
   p_num    IN   NUMBER,
   p_rule   IN   NUMBER
)
IS
   --
   l_proc   VARCHAR2 (72) := g_package || 'chk_code_rule_num';
--
BEGIN
   --
   hr_utility.set_location ('Entering:' || l_proc, 5);

   --
   IF NVL(p_code,'N') <> 'RL' AND p_rule IS NOT NULL
   THEN
      --
      fnd_message.set_name ('BEN', 'BEN_91624_CD_RL_2');
      fnd_message.raise_error;
   --
   ELSIF p_code = 'RL' AND p_rule IS NULL
   THEN
      --
      fnd_message.set_name ('BEN', 'BEN_91623_CD_RL_1');
      fnd_message.raise_error;
   --
   END IF;

   --
   IF NVL(p_code,'N') <> 'WASHRULE' AND p_num IS NOT NULL
   THEN
      --
      fnd_message.set_name ('BEN', 'BEN_92270_NTWSHRL_NUM_NTNULL');
      fnd_message.raise_error;
   --
   ELSIF p_code = 'WASHRULE' AND p_num IS NULL
   THEN
      --
      fnd_message.set_name ('BEN', 'BEN_92271_NTWSHRL_NUM_NULL');
      fnd_message.raise_error;
   --
   END IF;

   --
   hr_utility.set_location ('Leaving:' || l_proc, 10);
--
END chk_code_rule_num;
--
-- Change ends against Bug:5091755

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in ben_abr_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is

  l_proc	varchar2(72) := g_package||'insert_validate';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Call all supporting business operations
  --

  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp

  chk_acty_base_rt_id(p_acty_base_rt_id         => p_rec.acty_base_rt_id,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);

 chk_name_unique
     ( p_acty_base_rt_id     => p_rec.acty_base_rt_id
      ,p_name                => p_rec.name
      ,p_business_group_id   => p_rec.business_group_id);
--ICM Changes

-- Added 'if' condition for Bug 6881417
if(not ben_abr_bus.g_ssben_call) then
	chk_elem_unique
		  ( p_acty_base_rt_id    => p_rec.acty_base_rt_id
		   ,p_effective_date     => p_effective_date
		   ,p_business_group_id  => p_rec.business_group_id
		   ,p_element_type_id    => p_rec.element_type_id
		   ,p_rt_mlt_cd		 => p_rec.rt_mlt_cd
		   ,p_rec                => p_rec);
end if;
--
  chk_acty_type
          (p_acty_base_rt_id       =>   p_rec.acty_base_rt_id
           ,p_pl_id                =>   p_rec.pl_id
           ,p_acty_typ_cd          =>   p_rec.acty_typ_cd
           ,p_sub_acty_typ_cd      =>   p_rec.sub_acty_typ_cd
           ,p_effective_start_date =>   p_effective_date
           ,p_business_group_id    =>   p_rec.business_group_id
           ,p_plip_id              =>   p_rec.plip_id );

  chk_impted_incom_rate_unique
          ( p_acty_base_rt_id      =>   p_rec.acty_base_rt_id
           ,p_pl_id                =>   p_rec.pl_id
           ,p_rt_usg_cd            =>   p_rec.rt_usg_cd
           ,p_effective_start_date =>   p_effective_date
           ,p_business_group_id    => p_rec.business_group_id);

  chk_all_rules(p_acty_base_rt_id                => p_rec.acty_base_rt_id,
     p_prtl_mo_det_mthd_rl        => p_rec.prtl_mo_det_mthd_rl,
     p_prtl_mo_eff_dt_det_rl      => p_rec.prtl_mo_eff_dt_det_rl,
     p_rndg_rl                    => p_rec.rndg_rl,
     p_lwr_lmt_calc_rl            => p_rec.lwr_lmt_calc_rl,
     p_upr_lmt_calc_rl            => p_rec.upr_lmt_calc_rl,
     p_prtl_mo_det_mthd_cd        => p_rec.prtl_mo_det_mthd_cd,
     p_prtl_mo_eff_dt_det_cd      => p_rec.prtl_mo_eff_dt_det_cd,
     p_rndg_cd                    => p_rec.rndg_cd,
     p_val_calc_rl                => p_rec.val_calc_rl,
     p_prort_mn_ann_elcn_val_rl   => p_rec.prort_mn_ann_elcn_val_rl,
     p_prort_mx_ann_elcn_val_rl   => p_rec.prort_mx_ann_elcn_val_rl,
     p_mn_mx_elcn_rl              => p_rec.mn_mx_elcn_rl,
     p_element_det_rl             => p_rec.element_det_rl,
     p_effective_date             => p_effective_date,
     p_business_group_id	  => p_rec.business_group_id,
     p_object_version_number      => p_rec.object_version_number);

  chk_all_flags(p_acty_base_rt_id     => p_rec.acty_base_rt_id,
     p_use_to_calc_net_flx_cr_flag    => p_rec.use_to_calc_net_flx_cr_flag,
     p_asn_on_enrt_flag               => p_rec.asn_on_enrt_flag,
     p_abv_mx_elcn_val_alwd_flag      => p_rec.abv_mx_elcn_val_alwd_flag,
     p_blw_mn_elcn_alwd_flag          => p_rec.blw_mn_elcn_alwd_flag,
     p_dsply_on_enrt_flag             => p_rec.dsply_on_enrt_flag,
     p_use_calc_acty_bs_rt_flag       => p_rec.use_calc_acty_bs_rt_flag,
     p_uses_ded_sched_flag            => p_rec.uses_ded_sched_flag,
     p_uses_varbl_rt_flag             => p_rec.uses_varbl_rt_flag,
     p_vstg_sched_apls_fLag           => p_rec.vstg_sched_apls_fLag,
     p_proc_each_pp_dflt_flag         => p_rec.proc_each_pp_dflt_flag,
     p_prdct_flx_cr_when_elig_flag    => p_rec.prdct_flx_cr_when_elig_flag,
     p_no_std_rt_used_flag            => p_rec.no_std_rt_used_flag,
     p_uses_pymt_sched_flag           => p_rec.uses_pymt_sched_flag,
     p_val_ovrid_alwd_flag            => p_rec.val_ovrid_alwd_flag,
     p_no_mx_elcn_val_dfnd_flag       => p_rec.no_mx_elcn_val_dfnd_flag ,
     p_no_mn_elcn_val_dfnd_flag       => p_rec.no_mn_elcn_val_dfnd_flag ,
     p_entr_val_at_enrt_flag          => p_rec.entr_val_at_enrt_flag,
     p_entr_ann_val_flag              => p_rec.entr_ann_val_flag,
     p_only_one_bal_typ_alwd_flag     => p_rec.only_one_bal_typ_alwd_flag,
     p_rt_usg_cd                      => p_rec.rt_usg_cd,
     p_ele_rqd_flag                   => p_rec.ele_rqd_flag,
     p_subj_to_imptd_incm_flag        => p_rec.subj_to_imptd_incm_flag,
     p_acty_typ_cd                    => p_rec.acty_typ_cd,
     p_business_group_id              => p_rec.business_group_id,
     p_effective_date                 => p_effective_date,
     p_object_version_number          => p_rec.object_version_number);

   chk_lwr_lmt_val_and_rl
    (p_acty_base_rt_id               => p_rec.acty_base_rt_id,
     p_lwr_lmt_val                   => p_rec.lwr_lmt_val,
     p_lwr_lmt_calc_rl               => p_rec.lwr_lmt_calc_rl);

   chk_upr_lwr_lmt_val
    (p_upr_lmt_val                   => p_rec.upr_lmt_val,
     p_lwr_lmt_val                   => p_rec.lwr_lmt_val);

   chk_upr_lmt_val_and_rl
    (p_acty_base_rt_id               => p_rec.acty_base_rt_id,
     p_upr_lmt_val                   => p_rec.upr_lmt_val,
     p_upr_lmt_calc_rl               => p_rec.upr_lmt_calc_rl);

   chk_all_lookups(p_acty_base_rt_id               => p_rec.acty_base_rt_id,
     p_acty_typ_cd                   => p_rec.acty_typ_cd,
     p_rt_typ_cd                     => p_rec.rt_typ_cd,
     p_bnft_rt_typ_cd                => p_rec.bnft_rt_typ_cd,
     p_tx_typ_cd                     => p_rec.tx_typ_cd,
     p_parnt_chld_cd                 => p_rec.parnt_chld_cd,
     p_rt_mlt_cd                     => p_rec.rt_mlt_cd,
     p_rcrrg_cd                      => p_rec.rcrrg_cd,
     p_rndg_cd                       => p_rec.rndg_cd,
     p_prtl_mo_det_mthd_cd           => p_rec.prtl_mo_det_mthd_cd,
     p_acty_base_rt_stat_cd          => p_rec.acty_base_rt_stat_cd,
     p_procg_src_cd                  => p_rec.procg_src_cd,
     p_frgn_erg_ded_typ_cd           => p_rec.frgn_erg_ded_typ_cd,
     p_prtl_mo_eff_dt_det_cd         => p_rec.prtl_mo_eff_dt_det_cd,
     p_rt_usg_cd                     => p_rec.rt_usg_cd,
     p_prort_mn_ann_elcn_val_cd      => p_rec.prort_mn_ann_elcn_val_cd,
     p_prort_mx_ann_elcn_val_cd      => p_rec.prort_mx_ann_elcn_val_cd,
     p_one_ann_pymt_cd               => p_rec.one_ann_pymt_cd,
     p_det_pl_ytd_cntrs_cd           => p_rec.det_pl_ytd_cntrs_cd,
     p_asmt_to_use_cd                => p_rec.asmt_to_use_cd,
     p_currency_det_cd               => p_rec.currency_det_cd,
     p_effective_date                => p_effective_date,
     p_object_version_number         => p_rec.object_version_number);

  chk_estonly_no_ptd_fctr
    (p_ptd_comp_lvl_fctr_id          => p_rec.ptd_comp_lvl_fctr_id,
     p_det_pl_ytd_cntrs_cd           => p_rec.det_pl_ytd_cntrs_cd);

-- Added on Mar 14, 2006 against Bug:5091755
  chk_code_rule_num
	  (p_code         => p_rec.prtl_mo_det_mthd_cd,
	   p_num          => p_rec.wsh_rl_dy_mo_num,
	   p_rule         => p_rec.prtl_mo_det_mthd_rl);
-- Change ends against Bug:5091755
  chk_prtl_mo_det_mthd_cd_rl
    (p_prtl_mo_det_mthd_cd           => p_rec.prtl_mo_det_mthd_cd,
     p_prtl_mo_det_mthd_rl           => p_rec.prtl_mo_det_mthd_rl);

  chk_rndg_cd_rl
    (p_rndg_cd                       => p_rec.rndg_cd,
     p_rndg_rl                       => p_rec.rndg_rl);

  chk_ann_rts (p_prort_mn_ann_elcn_val_cd   => p_rec.prort_mn_ann_elcn_val_cd
              ,p_prort_mn_ann_elcn_val_rl   => p_rec.prort_mn_ann_elcn_val_rl
              ,p_prort_mx_ann_elcn_val_cd   => p_rec.prort_mx_ann_elcn_val_cd
              ,p_prort_mx_ann_elcn_val_rl   => p_rec.prort_mx_ann_elcn_val_rl
              ,p_clm_comp_lvl_fctr_id       => p_rec.clm_comp_lvl_fctr_id
              ,p_ptd_comp_lvl_fctr_id       => p_rec.ptd_comp_lvl_fctr_id
              ,p_entr_ann_val_flag          => p_rec.entr_ann_val_flag
              ,p_rt_mlt_cd                  => p_rec.rt_mlt_cd ) ;

  chk_nnmntry_uom(p_acty_base_rt_id     => p_rec.acty_base_rt_id,
     p_nnmntry_uom                      => p_rec.nnmntry_uom,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_rec.object_version_number);

  /* chk_organization_id(p_acty_base_rt_id        => p_rec.acty_base_rt_id,
     p_organization_id          => p_rec.organization_id,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_rec.object_version_number); */

  chk_pgm_typ_code
     (p_pgm_id            => p_rec.pgm_id
     ,p_ptip_id           => p_rec.ptip_id
     ,p_plip_id           => p_rec.plip_id
     ,p_rt_usg_cd         => p_rec.rt_usg_cd
     ,p_business_group_id => p_rec.business_group_id
     ,p_effective_date    => p_effective_date );

  chk_only_one_id (p_pgm_id     =>   p_rec.pgm_id,
                   p_oipl_id    =>   p_rec.oipl_id,
                   p_opt_id     =>   p_rec.opt_id,
                   p_oiplip_id  =>   p_rec.oiplip_id,
                   p_plip_id    =>   p_rec.plip_id,
                   p_ptip_id    =>   p_rec.ptip_id,
                   p_pl_id      =>   p_rec.pl_id,
                   p_cmbn_plip_id => p_rec.cmbn_plip_id,
                   p_cmbn_ptip_id => p_rec.cmbn_ptip_id,
                   p_cmbn_ptip_opt_id => p_rec.cmbn_ptip_opt_id
                   );
  chk_actual_premium_asnmt_cd
     (p_actl_prem_id           => p_rec.actl_prem_id,
      p_acty_base_rt_id        => p_rec.acty_base_rt_id,
      p_effective_date         => p_effective_date,
      p_business_group_id      => p_rec.business_group_id);

  chk_mlt_cd_dependencies
     (p_rt_mlt_cd              => p_rec.rt_mlt_cd,
      p_entr_val_at_enrt_flag  => p_rec.entr_val_at_enrt_flag,
      p_entr_ann_val_flag      => p_rec.entr_ann_val_flag,
      p_val                    => p_rec.val,
      p_mn_elcn_val            => p_rec.mn_elcn_val,
      p_mx_elcn_val            => p_rec.mx_elcn_val,
      p_incrmt_elcn_val        => p_rec.incrmt_elcn_val,
      p_dflt_val               => p_rec.dflt_val,
      p_rt_typ_cd              => p_rec.rt_typ_cd,
      p_bnft_rt_typ_cd         => p_rec.bnft_rt_typ_cd,
      p_val_calc_rl            => p_rec.val_calc_rl,
      p_acty_base_rt_id        => p_rec.acty_base_rt_id,
      p_pay_rate_grade_rule_id => p_rec.pay_rate_grade_rule_id,
      p_acty_typ_cd            => p_rec.acty_typ_cd,
      p_effective_date         => p_effective_date,
      p_object_version_number  => p_rec.object_version_number
     );

    chk_elmt_typ_input_val_rqd
      (p_rec 		       => p_rec,
       p_acty_base_rt_stat_cd  => p_rec.acty_base_rt_stat_cd,
       p_input_value_id        => p_rec.input_value_id,
       p_ele_rqd_flag          => p_rec.ele_rqd_flag,
       p_effective_date         => p_effective_date,
       p_element_type_id       => p_rec.element_type_id);


  chk_prtl_mo_det_mthd_cd
     (p_prtl_mo_det_mthd_cd   => p_rec.prtl_mo_det_mthd_cd,
      p_ele_entry_val_cd      => p_rec.ele_entry_val_cd);

 chk_entr_ann_val_flag
     (p_entr_ann_val_flag        => p_rec.entr_ann_val_flag,
      p_ann_mn_elcn_val          => p_rec.ann_mn_elcn_val,
      p_ann_mx_elcn_val          => p_rec.ann_mx_elcn_val,
      p_mn_elcn_val              => p_rec.mn_elcn_val,
      p_mx_elcn_val              => p_rec.mx_elcn_val,
      p_det_pl_ytd_cntrs_cd      => p_rec.det_pl_ytd_cntrs_cd);



  chk_entr_at_enrt_with_cvg(p_rt_mlt_cd    => p_rec.rt_mlt_cd ,
                            p_entr_val_at_enrt_flag  => p_rec.entr_val_at_enrt_flag   ,
                            p_pl_id                  => p_rec.pl_id   ,
                            p_plip_id                => p_rec.plip_id ,
                            p_oipl_id                => p_rec.oipl_id ,
                            p_oiplip_id              => p_rec.oiplip_id ,
                            p_effective_date         => p_effective_date   ) ;

  if p_rec.dsply_on_enrt_flag = 'Y' then
   /* Calling the procedure only when the dsply_on_enrt_flag is Y. */
   chk_ordr_num(p_acty_base_rt_id       => p_rec.acty_base_rt_id,
               p_effective_date        => p_effective_date,
               p_object_version_number => p_rec.object_version_number,
               p_business_group_id     => p_rec.business_group_id,
               p_pl_id                 => p_rec.pl_id,
	       p_plip_id                => p_rec.plip_id ,
               p_oipl_id                => p_rec.oipl_id ,
               p_opt_id                 => p_rec.opt_id,
               p_oiplip_id              => p_rec.oiplip_id ,
               p_ordr_num		=> p_rec.ordr_num);

  end if;

  --
  --Bug 3460673
  if p_rec.ENTR_VAL_AT_ENRT_FLAG = 'Y' then
    chk_incr_val_less_than_max_val (p_incrmt_elcn_val => p_rec.incrmt_elcn_val,
                                    p_mx_elcn_val     => p_rec.mx_elcn_val,
				    p_ann_mx_elcn_val => p_rec.ann_mx_elcn_val);
  end if;
  --Bug 3460673
  --



  --
  -- CWB Changes Bug 2275257
  --
  if p_rec.acty_typ_cd is not null and p_rec.acty_typ_cd like 'CWB%'
  then
    chk_cwb_acty_typ_cd_unique(p_acty_base_rt_id       => p_rec.acty_base_rt_id,
                               p_acty_typ_cd           => p_rec.acty_typ_cd,
                       	       p_pl_id                 => p_rec.pl_id,
                               p_oipl_id               => p_rec.oipl_id,
                               p_acty_base_rt_stat_cd  => p_rec.acty_base_rt_stat_cd,
                               p_business_group_id     => p_rec.business_group_id,
              		       p_effective_date        => p_effective_date,
                               p_object_version_number => p_rec.object_version_number);
  end if;


 if p_rec.subj_to_imptd_incm_flag = 'Y' then
  chk_subj_to_imptd_incm(
                  p_acty_base_rt_id       => p_rec.acty_base_rt_id,
                  p_pl_id                 => p_rec.pl_id,
                  p_oipl_id               => p_rec.oipl_id,
                  p_plip_id               => p_rec.plip_id,
                  p_oiplip_id             => p_rec.oiplip_id,
                  p_acty_typ_cd           => p_rec.acty_typ_cd ,
                  p_tx_typ_cd             => p_rec.tx_typ_cd ,
                  p_subj_to_imptd_incm_flag => p_rec.subj_to_imptd_incm_flag,
                  p_effective_date        => p_effective_date ) ;


 end if ;

 if p_rec.pay_rate_grade_rule_id is not null then
    chk_pay_rate_grade_rule_id(p_acty_base_rt_id       => p_rec.acty_base_rt_id,
                              p_pay_rate_grade_rule_id => p_rec.pay_rate_grade_rule_id,
                              p_pl_id                  => p_rec.pl_id ,
                              p_opt_id                 => p_rec.opt_id,
                              p_business_group_id      => p_rec.business_group_id,
                              p_effective_date         => p_effective_date,
                              p_object_version_number  => p_rec.object_version_number) ;
 end if ;

 --muky
 if p_rec.acty_typ_cd is not null and p_rec.acty_typ_cd like 'GSPSA'
 then
    chk_acty_typ_cd_gsp
                         (p_acty_base_rt_id        => p_rec.acty_base_rt_id,
    			  --p_pgm_id		   => p_rec.pgm_id ,
    			  p_pl_id		   => p_rec.pl_id ,
    			  /*p_opt_id		   => p_rec.opt_id ,
    			  p_plip_id		   => p_rec.plip_id ,
    			  p_oipl_id		   => p_rec.oipl_id ,*/
                      	  p_acty_typ_cd            => p_rec.acty_typ_cd,
                       	  p_effective_date         => p_effective_date,
                       	  p_business_group_id      => p_rec.business_group_id,
                   	  p_object_version_number  => p_rec.object_version_number);
 end if;

 chk_mn_mx_rl
          ( p_acty_base_rt_id         =>   p_rec.acty_base_rt_id
           ,p_mn_mx_elcn_rl           =>   p_rec.mn_mx_elcn_rl
           ,p_mn_elcn_val             =>   p_rec.mn_elcn_val
           ,p_mx_elcn_val	      =>   p_rec.mx_elcn_val
           ,p_incrmt_elcn_val	      =>   p_rec.incrmt_elcn_val
           ,p_dflt_val		      =>   p_rec.dflt_val
           ,p_entr_val_at_enrt_flag   =>   p_rec.entr_val_at_enrt_flag
           ,p_acty_typ_cd	      =>   p_rec.acty_typ_cd);
-- CWB
chk_cwb_element_currency
                         (p_element_det_rl         =>   p_rec.element_det_rl,
			  p_currency_det_cd        =>   p_rec.currency_det_cd,
			  p_acty_typ_cd		   =>   p_rec.acty_typ_cd ) ;
--
chk_abr_seq_num
                         (p_pl_id                  =>   p_rec.pl_id,
                          p_oipl_id                =>   p_rec.oipl_id,
			  p_opt_id                 =>   p_rec.opt_id,
                          p_abr_seq_num            =>   p_rec.abr_seq_num,
			  p_effective_start_date   =>   p_effective_date,
                          p_business_group_id      =>   p_rec.business_group_id);

--
End insert_validate;

-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_abr_shd.g_rec_type,
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
  -- Call the datetrack update integrity operation
  --

  chk_acty_base_rt_id(p_acty_base_rt_id         => p_rec.acty_base_rt_id,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);

 chk_name_unique
     ( p_acty_base_rt_id     => p_rec.acty_base_rt_id
      ,p_name                => p_rec.name
      ,p_business_group_id   => p_rec.business_group_id);
--ICM Changes
chk_elem_unique
          ( p_acty_base_rt_id    => p_rec.acty_base_rt_id
           ,p_effective_date     => p_effective_date
           ,p_business_group_id  => p_rec.business_group_id
	   ,p_element_type_id    => p_rec.element_type_id
	   ,p_rt_mlt_cd		 => p_rec.rt_mlt_cd
   	   ,p_rec                => p_rec);

 chk_acty_type
          (p_acty_base_rt_id       =>   p_rec.acty_base_rt_id
           ,p_pl_id                =>   p_rec.pl_id
           ,p_acty_typ_cd          =>   p_rec.acty_typ_cd
           ,p_sub_acty_typ_cd      =>   p_rec.sub_acty_typ_cd
           ,p_effective_start_date =>   p_effective_date
           ,p_business_group_id    =>   p_rec.business_group_id
           ,p_plip_id              =>   p_rec.plip_id );

 chk_impted_incom_rate_unique
          ( p_acty_base_rt_id      =>   p_rec.acty_base_rt_id
           ,p_pl_id                =>   p_rec.pl_id
           ,p_rt_usg_cd            =>   p_rec.rt_usg_cd
           ,p_effective_start_date =>   p_effective_date
           ,p_business_group_id   => p_rec.business_group_id);

  chk_all_rules(p_acty_base_rt_id                => p_rec.acty_base_rt_id,
     p_prtl_mo_det_mthd_rl        => p_rec.prtl_mo_det_mthd_rl,
     p_prtl_mo_eff_dt_det_rl      => p_rec.prtl_mo_eff_dt_det_rl,
     p_rndg_rl                    => p_rec.rndg_rl,
     p_lwr_lmt_calc_rl            => p_rec.lwr_lmt_calc_rl,
     p_upr_lmt_calc_rl            => p_rec.upr_lmt_calc_rl,
     p_val_calc_rl                => p_rec.val_calc_rl,
     p_prtl_mo_det_mthd_cd        => p_rec.prtl_mo_det_mthd_cd,
     p_prtl_mo_eff_dt_det_cd      => p_rec.prtl_mo_eff_dt_det_cd,
     p_rndg_cd                    => p_rec.rndg_cd,
     p_prort_mn_ann_elcn_val_rl   => p_rec.prort_mn_ann_elcn_val_rl,
     p_prort_mx_ann_elcn_val_rl   => p_rec.prort_mx_ann_elcn_val_rl,
     p_mn_mx_elcn_rl              => p_rec.mn_mx_elcn_rl,
     p_element_det_rl             => p_rec.element_det_rl,
     p_effective_date             => p_effective_date,
     p_business_group_id	  => p_rec.business_group_id,
     p_object_version_number      => p_rec.object_version_number);

  chk_all_flags(p_acty_base_rt_id                => p_rec.acty_base_rt_id,
     p_use_to_calc_net_flx_cr_flag    => p_rec.use_to_calc_net_flx_cr_flag,
     p_asn_on_enrt_flag               => p_rec.asn_on_enrt_flag,
     p_abv_mx_elcn_val_alwd_flag      => p_rec.abv_mx_elcn_val_alwd_flag,
     p_blw_mn_elcn_alwd_flag          => p_rec.blw_mn_elcn_alwd_flag,
     p_dsply_on_enrt_flag             => p_rec.dsply_on_enrt_flag,
     p_use_calc_acty_bs_rt_flag       => p_rec.use_calc_acty_bs_rt_flag,
     p_uses_ded_sched_flag            => p_rec.uses_ded_sched_flag,
     p_uses_varbl_rt_flag             => p_rec.uses_varbl_rt_flag,
     p_vstg_sched_apls_fLag           => p_rec.vstg_sched_apls_fLag,
     p_proc_each_pp_dflt_flag         => p_rec.proc_each_pp_dflt_flag,
     p_prdct_flx_cr_when_elig_flag    => p_rec.prdct_flx_cr_when_elig_flag,
     p_no_std_rt_used_flag            => p_rec.no_std_rt_used_flag,
     p_uses_pymt_sched_flag           => p_rec.uses_pymt_sched_flag,
     p_val_ovrid_alwd_flag            => p_rec.val_ovrid_alwd_flag,
     p_no_mx_elcn_val_dfnd_flag       => p_rec.no_mx_elcn_val_dfnd_flag ,
     p_no_mn_elcn_val_dfnd_flag       => p_rec.no_mn_elcn_val_dfnd_flag ,
     p_entr_val_at_enrt_flag          => p_rec.entr_val_at_enrt_flag,
     p_entr_ann_val_flag              => p_rec.entr_ann_val_flag,
     p_only_one_bal_typ_alwd_flag     => p_rec.only_one_bal_typ_alwd_flag,
     p_rt_usg_cd                      => p_rec.rt_usg_cd,
     p_ele_rqd_flag                   => p_rec.ele_rqd_flag,
     p_subj_to_imptd_incm_flag        => p_rec.subj_to_imptd_incm_flag,
     p_acty_typ_cd                    => p_rec.acty_typ_cd,
     p_business_group_id              => p_rec.business_group_id,
     p_effective_date               => p_effective_date,
     p_object_version_number        => p_rec.object_version_number);

   chk_lwr_lmt_val_and_rl
    (p_acty_base_rt_id               => p_rec.acty_base_rt_id,
     p_lwr_lmt_val                   => p_rec.lwr_lmt_val,
     p_lwr_lmt_calc_rl               => p_rec.lwr_lmt_calc_rl);

   chk_upr_lwr_lmt_val
    (p_upr_lmt_val                   => p_rec.upr_lmt_val,
     p_lwr_lmt_val                   => p_rec.lwr_lmt_val);

   chk_upr_lmt_val_and_rl
    (p_acty_base_rt_id               => p_rec.acty_base_rt_id,
     p_upr_lmt_val                   => p_rec.upr_lmt_val,
     p_upr_lmt_calc_rl               => p_rec.upr_lmt_calc_rl);

   chk_all_lookups(p_acty_base_rt_id               => p_rec.acty_base_rt_id,
     p_acty_typ_cd                   => p_rec.acty_typ_cd,
     p_rt_typ_cd                     => p_rec.rt_typ_cd,
     p_bnft_rt_typ_cd                => p_rec.bnft_rt_typ_cd,
     p_tx_typ_cd                     => p_rec.tx_typ_cd,
     p_parnt_chld_cd                 => p_rec.parnt_chld_cd,
     p_rt_mlt_cd                     => p_rec.rt_mlt_cd,
     p_rcrrg_cd                      => p_rec.rcrrg_cd,
     p_rndg_cd                       => p_rec.rndg_cd,
     p_prtl_mo_det_mthd_cd           => p_rec.prtl_mo_det_mthd_cd,
     p_acty_base_rt_stat_cd          => p_rec.acty_base_rt_stat_cd,
     p_procg_src_cd                  => p_rec.procg_src_cd,
     p_frgn_erg_ded_typ_cd           => p_rec.frgn_erg_ded_typ_cd,
     p_prtl_mo_eff_dt_det_cd         => p_rec.prtl_mo_eff_dt_det_cd,
     p_rt_usg_cd                     => p_rec.rt_usg_cd,
     p_prort_mn_ann_elcn_val_cd      => p_rec.prort_mn_ann_elcn_val_cd,
     p_prort_mx_ann_elcn_val_cd      => p_rec.prort_mx_ann_elcn_val_cd,
     p_one_ann_pymt_cd               => p_rec.one_ann_pymt_cd,
     p_det_pl_ytd_cntrs_cd           => p_rec.det_pl_ytd_cntrs_cd,
     p_asmt_to_use_cd                => p_rec.asmt_to_use_cd,
     p_currency_det_cd               => p_rec.currency_det_cd,
     p_effective_date                => p_effective_date,
     p_object_version_number         => p_rec.object_version_number);

  chk_estonly_no_ptd_fctr
    (p_ptd_comp_lvl_fctr_id          => p_rec.ptd_comp_lvl_fctr_id,
     p_det_pl_ytd_cntrs_cd           => p_rec.det_pl_ytd_cntrs_cd);

-- Added on Mar 14, 2006 against Bug:5091755
  chk_code_rule_num
	  (p_code         => p_rec.prtl_mo_det_mthd_cd,
	   p_num          => p_rec.wsh_rl_dy_mo_num,
	   p_rule         => p_rec.prtl_mo_det_mthd_rl);
-- Change ends against Bug:5091755
  chk_prtl_mo_det_mthd_cd_rl
    (p_prtl_mo_det_mthd_cd           => p_rec.prtl_mo_det_mthd_cd,
     p_prtl_mo_det_mthd_rl           => p_rec.prtl_mo_det_mthd_rl);

  chk_rndg_cd_rl
    (p_rndg_cd                       => p_rec.rndg_cd,
     p_rndg_rl                       => p_rec.rndg_rl);

  chk_ann_rts (p_prort_mn_ann_elcn_val_cd   => p_rec.prort_mn_ann_elcn_val_cd
              ,p_prort_mn_ann_elcn_val_rl   => p_rec.prort_mn_ann_elcn_val_rl
              ,p_prort_mx_ann_elcn_val_cd   => p_rec.prort_mx_ann_elcn_val_cd
              ,p_prort_mx_ann_elcn_val_rl   => p_rec.prort_mx_ann_elcn_val_rl
              ,p_clm_comp_lvl_fctr_id       => p_rec.clm_comp_lvl_fctr_id
              ,p_ptd_comp_lvl_fctr_id       => p_rec.ptd_comp_lvl_fctr_id
              ,p_entr_ann_val_flag          => p_rec.entr_ann_val_flag
              ,p_rt_mlt_cd                  => p_rec.rt_mlt_cd ) ;

  chk_nnmntry_uom(p_acty_base_rt_id     => p_rec.acty_base_rt_id,
     p_nnmntry_uom                      => p_rec.nnmntry_uom,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_rec.object_version_number);

  /* chk_organization_id(p_acty_base_rt_id        => p_rec.acty_base_rt_id,
     p_organization_id          => p_rec.organization_id,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_rec.object_version_number); */


  chk_pgm_typ_code
     ( p_pgm_id            => p_rec.pgm_id
     ,p_ptip_id           => p_rec.ptip_id
     ,p_plip_id           => p_rec.plip_id
     ,p_rt_usg_cd         => p_rec.rt_usg_cd
     ,p_business_group_id => p_rec.business_group_id
     ,p_effective_date    => p_effective_date );


  chk_only_one_id (p_pgm_id     =>   p_rec.pgm_id,
                   p_oipl_id    =>   p_rec.oipl_id,
                   p_opt_id     =>   p_rec.opt_id,
                   p_oiplip_id  =>   p_rec.oiplip_id,
                   p_plip_id    =>   p_rec.plip_id,
                   p_ptip_id    =>   p_rec.ptip_id,
                   p_pl_id      =>   p_rec.pl_id,
                   p_cmbn_plip_id => p_rec.cmbn_plip_id,
                   p_cmbn_ptip_id => p_rec.cmbn_ptip_id,
                   p_cmbn_ptip_opt_id => p_rec.cmbn_ptip_opt_id
                   );
  chk_actual_premium_asnmt_cd
     (p_actl_prem_id           => p_rec.actl_prem_id,
      p_acty_base_rt_id        => p_rec.acty_base_rt_id,
      p_effective_date         => p_effective_date,
      p_business_group_id      => p_rec.business_group_id);

  dt_update_validate
    (p_prtl_mo_det_mthd_rl           => p_rec.prtl_mo_det_mthd_rl,
     p_prtl_mo_eff_dt_det_rl         => p_rec.prtl_mo_eff_dt_det_rl,
     p_rndg_rl                       => p_rec.rndg_rl,
     p_lwr_lmt_calc_rl               => p_rec.lwr_lmt_calc_rl,
     p_upr_lmt_calc_rl               => p_rec.upr_lmt_calc_rl,
     p_val_calc_rl                   => p_rec.val_calc_rl,
     p_vstg_for_acty_rt_id           => p_rec.vstg_for_acty_rt_id,
     p_actl_prem_id                  => p_rec.actl_prem_id,
     p_parnt_acty_base_rt_id         => p_rec.parnt_acty_base_rt_id,
     p_pgm_id                        => p_rec.pgm_id,
     p_ptip_id                       => p_rec.ptip_id,
     p_oipl_id                       => p_rec.oipl_id,
     p_opt_id                        => p_rec.opt_id,
     p_plip_id                       => p_rec.plip_id,
     p_oiplip_id                     => p_rec.oiplip_id,
     p_pl_id                         => p_rec.pl_id,
     -- bug start
     p_element_type_id               => p_rec.element_type_id,
     p_input_va_calc_rl              => p_rec.input_va_calc_rl,
     p_element_det_rl                => p_rec.element_det_rl,
     -- bug end
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);


  chk_mlt_cd_dependencies
     (p_rt_mlt_cd              => p_rec.rt_mlt_cd,
      p_entr_val_at_enrt_flag  => p_rec.entr_val_at_enrt_flag,
      p_entr_ann_val_flag      => p_rec.entr_ann_val_flag,
      p_val                    => p_rec.val,
      p_mn_elcn_val            => p_rec.mn_elcn_val,
      p_mx_elcn_val            => p_rec.mx_elcn_val,
      p_incrmt_elcn_val        => p_rec.incrmt_elcn_val,
      p_dflt_val               => p_rec.dflt_val,
      p_rt_typ_cd              => p_rec.rt_typ_cd,
      p_bnft_rt_typ_cd         => p_rec.bnft_rt_typ_cd,
      p_val_calc_rl            => p_rec.val_calc_rl,
      p_acty_base_rt_id        => p_rec.acty_base_rt_id,
      p_pay_rate_grade_rule_id => p_rec.pay_rate_grade_rule_id,
      p_acty_typ_cd            => p_rec.acty_typ_cd,
      p_effective_date         => p_effective_date,
      p_object_version_number  => p_rec.object_version_number
     );

chk_elmt_typ_input_val_rqd
      (p_rec                  => p_rec,
       p_acty_base_rt_stat_cd  => p_rec.acty_base_rt_stat_cd,
       p_input_value_id        => p_rec.input_value_id,
       p_ele_rqd_flag          => p_rec.ele_rqd_flag,
       p_effective_date         => p_effective_date,
       p_element_type_id       => p_rec.element_type_id);

  chk_prtl_mo_det_mthd_cd
     (p_prtl_mo_det_mthd_cd   => p_rec.prtl_mo_det_mthd_cd,
      p_ele_entry_val_cd      => p_rec.ele_entry_val_cd);

 chk_entr_ann_val_flag
     (p_entr_ann_val_flag        => p_rec.entr_ann_val_flag,
      p_ann_mn_elcn_val          => p_rec.ann_mn_elcn_val,
      p_ann_mx_elcn_val          => p_rec.ann_mx_elcn_val,
      p_mn_elcn_val              => p_rec.mn_elcn_val,
      p_mx_elcn_val              => p_rec.mx_elcn_val,
      p_det_pl_ytd_cntrs_cd      => p_rec.det_pl_ytd_cntrs_cd);

  chk_entr_at_enrt_with_cvg(p_rt_mlt_cd    => p_rec.rt_mlt_cd ,
                            p_entr_val_at_enrt_flag  => p_rec.entr_val_at_enrt_flag   ,
                            p_pl_id                  => p_rec.pl_id   ,
                            p_plip_id                => p_rec.plip_id ,
                            p_oipl_id                => p_rec.oipl_id ,
                            p_oiplip_id              => p_rec.oiplip_id ,
                            p_effective_date         => p_effective_date   ) ;

   if p_rec.subj_to_imptd_incm_flag = 'Y' then
      chk_subj_to_imptd_incm(
                  p_acty_base_rt_id       => p_rec.acty_base_rt_id,
                  p_pl_id                 => p_rec.pl_id,
                  p_oipl_id               => p_rec.oipl_id,
                  p_plip_id               => p_rec.plip_id,
                  p_oiplip_id             => p_rec.oiplip_id,
                  p_acty_typ_cd           => p_rec.acty_typ_cd ,
                  p_tx_typ_cd             => p_rec.tx_typ_cd ,
                  p_subj_to_imptd_incm_flag => p_rec.subj_to_imptd_incm_flag,
                  p_effective_date        => p_effective_date ) ;

   end if ;

 if p_rec.dsply_on_enrt_flag = 'Y' then
 /* Calling the procedure only when the dsply_on_enrt_flag is Y. */
 chk_ordr_num(p_acty_base_rt_id       => p_rec.acty_base_rt_id,
               p_effective_date        => p_effective_date,
               p_object_version_number => p_rec.object_version_number,
               p_business_group_id     => p_rec.business_group_id,
               p_pl_id                 => p_rec.pl_id,
	       p_plip_id                => p_rec.plip_id ,
               p_oipl_id                => p_rec.oipl_id ,
               p_opt_id                 => p_rec.opt_id,
               p_oiplip_id              => p_rec.oiplip_id ,
               p_ordr_num		=> p_rec.ordr_num);

  end if;

  --
  --Bug 3460673
  if p_rec.ENTR_VAL_AT_ENRT_FLAG = 'Y' then
    chk_incr_val_less_than_max_val (p_incrmt_elcn_val => p_rec.incrmt_elcn_val,
                                    p_mx_elcn_val     => p_rec.mx_elcn_val,
				    p_ann_mx_elcn_val => p_rec.ann_mx_elcn_val);
  end if;
  --Bug 3460673
  --

  --
  -- CWB Changes Bug 2275257
  --
  if p_rec.acty_typ_cd is not null and p_rec.acty_typ_cd like 'CWB%'
  then
    chk_cwb_acty_typ_cd_unique(p_acty_base_rt_id       => p_rec.acty_base_rt_id,
                               p_acty_typ_cd           => p_rec.acty_typ_cd,
                       	       p_pl_id                 => p_rec.pl_id,
                               p_oipl_id               => p_rec.oipl_id,
                               p_acty_base_rt_stat_cd  => p_rec.acty_base_rt_stat_cd,
                               p_business_group_id     => p_rec.business_group_id,
              		       p_effective_date        => p_effective_date,
                               p_object_version_number => p_rec.object_version_number);
  end if;

  --
  -- ABSE Changes
  --
  chk_ext_inp_values(p_acty_base_rt_id  => p_rec.acty_base_rt_id,
                     p_input_va_calc_rl  => p_rec.input_va_calc_rl,
                     p_object_version_number => p_rec.object_version_number,
                     p_effective_date => p_effective_date);

  if p_rec.pay_rate_grade_rule_id is not null then
      chk_pay_rate_grade_rule_id(p_acty_base_rt_id       => p_rec.acty_base_rt_id,
                              p_pay_rate_grade_rule_id => p_rec.pay_rate_grade_rule_id,
                              p_pl_id                  => p_rec.pl_id ,
                              p_opt_id                 => p_rec.opt_id,
                              p_business_group_id      => p_rec.business_group_id,
                              p_effective_date         => p_effective_date,
                              p_object_version_number => p_rec.object_version_number) ;
  end if ;

 --muky
 if p_rec.acty_typ_cd is not null and p_rec.acty_typ_cd like 'GSPSA'
 then
    chk_acty_typ_cd_gsp
                         (p_acty_base_rt_id        => p_rec.acty_base_rt_id,
    			  --p_pgm_id		   => p_rec.pgm_id ,
    			  p_pl_id		   => p_rec.pl_id ,
    			  /*p_opt_id		   => p_rec.opt_id ,
    			  p_plip_id		   => p_rec.plip_id ,
    			  p_oipl_id		   => p_rec.oipl_id ,*/
                      	  p_acty_typ_cd            => p_rec.acty_typ_cd,
                       	  p_effective_date         => p_effective_date,
                       	  p_business_group_id      => p_rec.business_group_id,
                   	  p_object_version_number  => p_rec.object_version_number);
 end if;

  chk_mn_mx_rl
          ( p_acty_base_rt_id         =>   p_rec.acty_base_rt_id
           ,p_mn_mx_elcn_rl           =>   p_rec.mn_mx_elcn_rl
           ,p_mn_elcn_val             =>   p_rec.mn_elcn_val
           ,p_mx_elcn_val	      =>   p_rec.mx_elcn_val
           ,p_incrmt_elcn_val	      =>   p_rec.incrmt_elcn_val
           ,p_dflt_val		      =>   p_rec.dflt_val
           ,p_entr_val_at_enrt_flag   =>   p_rec.entr_val_at_enrt_flag
           ,p_acty_typ_cd	      =>   p_rec.acty_typ_cd);

chk_cwb_element_currency
                        ( p_element_det_rl         =>   p_rec.element_det_rl,
			  p_currency_det_cd        =>   p_rec.currency_det_cd,
			  p_acty_typ_cd		   =>   p_rec.acty_typ_cd ) ;
--
chk_abr_seq_num
                         (p_pl_id                  =>   p_rec.pl_id,
                          p_oipl_id                =>   p_rec.oipl_id,
			  p_opt_id                 =>   p_rec.opt_id,
                          p_abr_seq_num            =>   p_rec.abr_seq_num,
			  p_effective_start_date   =>   p_effective_date,
                          p_business_group_id      =>   p_rec.business_group_id);
--


  hr_utility.set_location(' Leaving:'||l_proc, 10);

End update_validate;

-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ben_abr_shd.g_rec_type,
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
     p_acty_base_rt_id		=> p_rec.acty_base_rt_id);
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
  (p_acty_base_rt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_acty_base_rt_f b
    where b.acty_base_rt_id      = p_acty_base_rt_id
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
                             p_argument       => 'acty_base_rt_id',
                             p_argument_value => p_acty_base_rt_id);
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

end ben_abr_bus;

/
