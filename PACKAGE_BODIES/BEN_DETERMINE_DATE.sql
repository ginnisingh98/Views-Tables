--------------------------------------------------------
--  DDL for Package Body BEN_DETERMINE_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DETERMINE_DATE" as
/* $Header: bendetdt.pkb 120.30.12010000.4 2010/02/10 09:52:00 sagnanas ship $ */
-- --------------------------------------------------------------------
-- Get the plan year during the life event or effective date.
-- --------------------------------------------------------------------
g_debug boolean := hr_utility.debug_enabled;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_profile_ff_warn_val >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- Bug 5088591: The function returns the value of profile BEN_DISP_FF_WARN_MSG.
-- If profile is not set then the function returns N
--
-- ----------------------------------------------------------------------------
FUNCTION get_profile_ff_warn_val
   RETURN VARCHAR2
IS
--
BEGIN
   --
   IF g_ben_disp_ff_warn_msg IS NULL
   THEN
      --
      g_ben_disp_ff_warn_msg := nvl(fnd_profile.VALUE ('BEN_DISP_FF_WARN_MSG'), 'Y');
      --
   END IF;
   --
   RETURN g_ben_disp_ff_warn_msg;
   --
--
END get_profile_ff_warn_val;
--
--
procedure  get_plan_year
           (p_effective_date in date
           ,p_lf_evt_ocrd_dt in date
           ,p_pl_id          in number
           ,p_pgm_id         in number
           ,p_oipl_id        in number
           ,p_date_cd        in varchar2
           ,p_comp_obj_mode  in boolean default true
           ,p_start_date     out nocopy date
           ,p_end_date       out nocopy date) is

  l_proc   varchar2(80)  := g_package ||'ben_determine_date.get_plan_year';

  l_effective_date date;

  cursor c_pgm_popl_yr is
  select yrp.start_date,
         yrp.end_date
    from ben_yr_perd yrp,
         ben_popl_yr_perd cpy
   where cpy.pgm_id = p_pgm_id
     and cpy.yr_perd_id = yrp.yr_perd_id
     and l_effective_date
         between yrp.start_date
             and yrp.end_date;
  --
  cursor c_pl_popl_yr is
  select yrp.start_date,
         yrp.end_date
    from ben_yr_perd yrp,
         ben_popl_yr_perd cpy
   where cpy.pl_id = p_pl_id
     and cpy.yr_perd_id = yrp.yr_perd_id
     and l_effective_date
         between yrp.start_date
             and yrp.end_date;
   --
  cursor c_oipl_popl_yr is
  select yrp.start_date,
         yrp.end_date
    from ben_yr_perd yrp,
         ben_popl_yr_perd cpy,
         ben_oipl_f cop
   where cpy.pl_id = cop.pl_id
     and cop.oipl_id = p_oipl_id
     and cpy.yr_perd_id = yrp.yr_perd_id
     and l_effective_date
         between yrp.start_date
             and yrp.end_date
     and l_effective_date
         between cop.effective_start_date
             and cop.effective_end_date;

begin

  l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
  if p_comp_obj_mode then
    if p_pl_id is not null then
       open c_pl_popl_yr;
       fetch c_pl_popl_yr into p_start_date, p_end_date;
       close c_pl_popl_yr;

    elsif p_pgm_id is not null then
      open c_pgm_popl_yr;
      fetch c_pgm_popl_yr into p_start_date, p_end_date;
      close c_pgm_popl_yr;

    elsif p_oipl_id is not null then
      open c_oipl_popl_yr;
      fetch c_oipl_popl_yr into p_start_date, p_end_date;
      close c_oipl_popl_yr;

    else
      if g_debug then
         hr_utility.set_location('BEN_92489_CANNOT_CALC_DATE',55);
      end if;

      fnd_message.set_name('BEN','BEN_92489_CANNOT_CALC_DATE');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.raise_error;
    end if;
  else
    p_start_date := to_date('01/01/'||to_char(l_effective_date,'YYYY'),'dd/mm/rrrr');
    p_end_date := to_date('31/12/'||to_char(l_effective_date,'YYYY'),'dd/mm/rrrr');

  end if;
exception   -- nocopy changes
  --
  when others then
    --
    p_start_date    := null;
    p_end_date      := null;
    raise;
    --
end get_plan_year;

-- --------------------------------------------------------------------
-- Validating Coverage Rate Dates Computed Using Rule
-- --------------------------------------------------------------------

procedure validate_rule_cd_date
                      ( p_formula_id            in number,
		        p_computed_Date         in date ,
                        p_lf_evt_ocrd_dt        in date,
                        p_per_in_ler_id         in number,
                        p_effective_date        in date,
                        p_pgm_id                in number,
                        p_pl_id                 in number,
                        p_opt_id                in number,
                        p_person_id             in number
                      )
              is

  cursor c_formula_type_id_name
  is
  select fft.formula_type_id,fft.formula_type_name
  from   ff_formula_types fft,ff_formulas_f ff
  where  ff.formula_id=p_formula_id
  and    ff.formula_type_id= fft.formula_type_id
  and    p_effective_date between ff.effective_start_date and ff.effective_end_date;


  cursor c_pgm_name
  is
  select name
  from   ben_pgm_f pgm
  where  pgm_id=p_pgm_id
  and    p_effective_Date between effective_start_date and effective_end_date;

  cursor c_pl_name
  is
  select name
  from   ben_pl_f pln
  where  pl_id=p_pl_id
  and    p_effective_Date between effective_start_date and effective_end_date;

  cursor c_opt_name
  is
  select name
  from   ben_opt_f opt
  where  opt_id=p_opt_id
  and    p_effective_Date between effective_start_date and effective_end_date;

  cursor c_mode
  is
  select 1
  from   ben_per_in_ler pil,
         ben_ler_f ler
  where  pil.ler_id = ler.ler_id
  and    pil.per_in_ler_id=p_per_in_ler_id
  and    ler.typ_cd not like 'SCHED%'
  and    p_lf_evt_ocrd_dt between effective_start_date and effective_end_date;

  cursor c_national_identifier
  is
  select national_identifier
  from   per_all_people_f
  where  person_id=p_person_id;


  l_message_name1   varchar2(500) := 'BEN_94441_ENROL_ST_DT_RANGE';
  l_message_name2   varchar2(500) := 'BEN_94464_ENROL_ED_DT_RANGE';
  l_message_name3   varchar2(500) := 'BEN_93964_ENRO_DT_LT_LE_OCD_DT';


  l_formula_type_id ff_formulas_f.formula_type_id%type;
  l_formula_type_name ff_formula_types.formula_type_name%type;
  l_pgm_name ben_pgm_f.name%type;
  l_pl_name ben_pl_f.name%type;
  l_opt_name ben_opt_f.name%type;
  l_dummy number;
  l_national_identifier per_all_people_f.national_identifier%type;

begin
   hr_utility.set_location('Entering validate_rule_cd_date',1000);

   open  c_formula_type_id_name;
   fetch c_formula_type_id_name into l_formula_type_id,l_formula_type_name;
   close c_formula_type_id_name;


   if l_formula_type_id in (-27,-28,-29,-30,-504,-503,-66,-67) then

    open c_pgm_name;
    fetch c_pgm_name into l_pgm_name;
    close c_pgm_name;

    open c_pl_name;
    fetch c_pl_name into l_pl_name;
    close c_pl_name;

    open c_opt_name;
    fetch c_opt_name into l_opt_name;
    close c_opt_name;

    open  c_national_identifier;
    fetch c_national_identifier into l_national_identifier;
    close c_national_identifier;

  end if;

   if l_formula_type_id in (-27,-28,-29,-30,-504,-503,-66,-67) then
          if  p_computed_Date <= hr_api.g_sot then
	  fnd_message.set_name('BEN','BEN_94441_ENROL_ST_DT_RANGE');
	  fnd_message.set_token('PARMA',l_formula_type_name || ' ' ||fnd_date.date_to_displaydate(p_computed_Date));
          fnd_message.set_token('PARMB',fnd_date.date_to_displaydate(hr_api.g_sot));
	  fnd_message.set_token('PARMC','Program:'||' '|| l_pgm_name ||' '||'-'||' '||'Plan:'||' '|| l_pl_name ||' '||'-'||' '||'Option:'||' '|| l_opt_name );
          benutils.write(p_text=>fnd_message.get);
          ben_warnings.load_warning
		       (p_application_short_name  => 'BEN'
		       ,p_message_name            => l_message_name1
		       ,p_parma                   => l_formula_type_name || ' ' ||fnd_date.date_to_displaydate(p_computed_Date)
		       ,p_parmb    	          => fnd_date.date_to_displaydate(hr_api.g_sot)
		       ,p_parmc                   => 'Program:'||' '|| l_pgm_name ||' '||'-'||' '||'Plan:'||' '|| l_pl_name ||' '||'-'||' '||'Option:'||' '|| l_opt_name
		       ,p_person_id               => p_person_id
		       );
      elsif p_computed_Date >= hr_api.g_eot then
          fnd_message.set_name('BEN','BEN_94464_ENROL_ED_DT_RANGE');
  	  fnd_message.set_token('PARMA',l_formula_type_name|| ' ' || fnd_date.date_to_displaydate(p_computed_Date));
          fnd_message.set_token('PARMB',fnd_date.date_to_displaydate(hr_api.g_eot));
	  fnd_message.set_token('PARMC','Program:'||' '|| l_pgm_name ||' '||'-'||' '||'Plan:'||' '|| l_pl_name ||' '||'-'||' '||'Option:'||' '|| l_opt_name );
          benutils.write(p_text=>fnd_message.get);
	  ben_warnings.load_warning
		       (p_application_short_name  => 'BEN'
		       ,p_message_name            => l_message_name2
		       ,p_parma                   => l_formula_type_name|| ' ' || fnd_date.date_to_displaydate(p_computed_Date)
		       ,p_parmb    	          => fnd_date.date_to_displaydate(hr_api.g_eot)
		       ,p_parmc                   => 'Program:'||' '|| l_pgm_name ||' '||'-'||' '||'Plan:'||' '|| l_pl_name ||' '||'-'||' '||'Option:'||' '|| l_opt_name
		       ,p_person_id               => p_person_id
		       );

    elsif l_formula_type_id in (-29,-66,-67) then
      if p_computed_Date < p_lf_evt_ocrd_dt  then
         fnd_message.set_name('BEN','BEN_93964_ENRO_DT_LT_LE_OCD_DT');
         fnd_message.set_token('PARMA',l_formula_type_name || ' ' ||fnd_date.date_to_displaydate(p_computed_Date));
         fnd_message.set_token('PARMB','Program:'||' '|| l_pgm_name ||' '||'-'||' '||'Plan:'||' '|| l_pl_name ||' '||'-'||' '||'Option:'||' '|| l_opt_name);
	 fnd_message.set_token('PARMC',fnd_date.date_to_displaydate(p_lf_evt_ocrd_dt));
	 benutils.write(p_text=>fnd_message.get);
	 ben_warnings.load_warning
		       (p_application_short_name  => 'BEN'
		       ,p_message_name            => l_message_name3
		       ,p_parma                   => l_formula_type_name || ' ' ||fnd_date.date_to_displaydate(p_computed_Date)
		       ,p_parmb                   => 'Program:'||' '|| l_pgm_name ||' '||'-'||' '||'Plan:'||' '|| l_pl_name ||' '||'-'||' '||'Option:'||' '|| l_opt_name
		       ,p_parmc                   => fnd_date.date_to_displaydate(p_lf_evt_ocrd_dt)
		       ,p_person_id               => p_person_id
		       );
       end if;

--Bug 5070692

   elsif l_formula_type_id in (-27,-28) then
      if p_computed_Date < p_lf_evt_ocrd_dt  then
         fnd_message.set_name('BEN','BEN_93964_ENRO_DT_LT_LE_OCD_DT');
         fnd_message.set_token('PARMA',l_formula_type_name || ' ' ||fnd_date.date_to_displaydate(p_computed_Date));
         fnd_message.set_token('PARMB','Program:'||' '|| l_pgm_name ||' '||'-'||' '||'Plan:'||' '|| l_pl_name ||' '||'-'||' '||'Option:'||' '|| l_opt_name);
	 fnd_message.set_token('PARMC',fnd_date.date_to_displaydate(p_lf_evt_ocrd_dt));

	 g_dep_rec.text := fnd_message.get;
	 g_dep_rec.rep_typ_cd := 'WARNING';
	 g_dep_rec.error_message_code :='BEN_93964_ENRO_DT_LT_LE_OCD_DT';
	 g_dep_rec.national_identifier :=l_national_identifier;
	 g_dep_rec.person_id :=p_person_id;
	 g_dep_rec.pgm_id :=p_pgm_id;
	 g_dep_rec.pl_id :=p_pl_id;

--Bug 5070692
	 benutils.write(p_rec=>g_dep_rec);
	 ben_warnings.load_warning
		       (p_application_short_name  => 'BEN'
		       ,p_message_name            => l_message_name3
		       ,p_parma                   => l_formula_type_name || ' ' ||fnd_date.date_to_displaydate(p_computed_Date)
		       ,p_parmb                   => 'Program:'||' '|| l_pgm_name ||' '||'-'||' '||'Plan:'||' '|| l_pl_name ||' '||'-'||' '||'Option:'||' '|| l_opt_name
		       ,p_parmc                   => fnd_date.date_to_displaydate(p_lf_evt_ocrd_dt)
		       ,p_person_id               => p_person_id
		       );
       end if;

--Bug 5070692

--Bug 5076010
    elsif l_formula_type_id = -30 then
      if p_computed_Date < p_lf_evt_ocrd_dt  then
         fnd_message.set_name('BEN','BEN_93964_ENRO_DT_LT_LE_OCD_DT');
         fnd_message.set_token('PARMA',substr(l_formula_type_name,1,10) ||' '||'Coverage End Date'|| ' ' ||fnd_date.date_to_displaydate(p_computed_Date));
         fnd_message.set_token('PARMB','Program:'||' '|| l_pgm_name ||' '||'-'||' '||'Plan:'||' '|| l_pl_name ||' '||'-'||' '||'Option:'||' '|| l_opt_name );
	 fnd_message.set_token('PARMC',fnd_date.date_to_displaydate(p_lf_evt_ocrd_dt));

         benutils.write(p_text=>fnd_message.get);
	 ben_warnings.load_warning
		       (p_application_short_name  => 'BEN'
		       ,p_message_name            => l_message_name3
		       ,p_parma                   => substr(l_formula_type_name,1,10) ||' '||'Coverage End Date'|| ' ' ||fnd_date.date_to_displaydate(p_computed_Date)
		       ,p_parmb                   => 'Program:'||' '|| l_pgm_name ||' '||'-'||' '||'Plan:'||' '|| l_pl_name ||' '||'-'||' '||'Option:'||' '|| l_opt_name
		       ,p_parmc                   => fnd_date.date_to_displaydate(p_lf_evt_ocrd_dt)
		       ,p_person_id               => p_person_id
		       );
       end if;
--Bug 5076010

    else
      open c_mode;
      fetch c_mode into l_dummy;
      if c_mode%found then
        if p_computed_Date < p_lf_evt_ocrd_dt  then
         fnd_message.set_name('BEN','BEN_93964_ENRO_DT_LT_LE_OCD_DT');
         fnd_message.set_token('PARMA',l_formula_type_name|| ' ' ||fnd_date.date_to_displaydate(p_computed_Date));
         fnd_message.set_token('PARMB','Program:'||' '|| l_pgm_name ||' '||'-'||' '||'Plan:'||' '|| l_pl_name ||' '||'-'||' '||'Option:'||' '|| l_opt_name );
	 fnd_message.set_token('PARMC',fnd_date.date_to_displaydate(p_lf_evt_ocrd_dt));

           benutils.write(p_text=>fnd_message.get);
           ben_warnings.load_warning
               (p_application_short_name  => 'BEN'
	           ,p_message_name            => l_message_name3
	           ,p_parma                   => l_formula_type_name|| ' ' ||fnd_date.date_to_displaydate(p_computed_Date)
	           ,p_parmb                   => 'Program:'||' '|| l_pgm_name ||' '||'-'||' '||'Plan:'||' '|| l_pl_name ||' '||'-'||' '||'Option:'||' '|| l_opt_name
	           ,p_parmc                   => fnd_date.date_to_displaydate(p_lf_evt_ocrd_dt)
	           ,p_person_id               => p_person_id);
        end if;
      end if;
      --
      close c_mode; -- Bug fix 5057685. Moved here
      --
    end if;
end if;
hr_utility.set_location('Leaving validate_rule_cd_date',8888);
end validate_rule_cd_date;

-- --------------------------------------------------------------------
-- Get the plan year that starts after the life event or effective date.
-- --------------------------------------------------------------------
procedure  get_next_plan_year
           (p_effective_date in date
           ,p_lf_evt_ocrd_dt in date
           ,p_pl_id          in number
           ,p_pgm_id         in number
           ,p_oipl_id        in number
           ,p_date_cd        in varchar2
           ,p_comp_obj_mode  in boolean default true
           ,p_start_date     out nocopy date
           ,p_end_date       out nocopy date) is

  l_proc   varchar2(80)  := g_package ||'ben_determine_date.get_next_plan_year';
  l_effective_date date;

  cursor c_pgm_next_popl_yr is
  select yrp.start_date, yrp.end_date
    from ben_yr_perd yrp,
         ben_popl_yr_perd cpy
   where cpy.pgm_id = p_pgm_id
     and cpy.yr_perd_id = yrp.yr_perd_id
     and l_effective_date < yrp.start_date
   order by 1;
  --
  cursor c_pl_next_popl_yr is
  select yrp.start_date, yrp.end_date
    from ben_yr_perd yrp,
         ben_popl_yr_perd cpy
   where cpy.pl_id = p_pl_id
     and cpy.yr_perd_id = yrp.yr_perd_id
     and l_effective_date < yrp.start_date
   order by 1;
  --
  cursor c_oipl_next_popl_yr is
  select yrp.start_date, yrp.end_date
    from ben_yr_perd yrp,
         ben_popl_yr_perd cpy,
         ben_oipl_f cop
   where cpy.pl_id = cop.pl_id
     and cop.oipl_id = p_oipl_id
     and cpy.yr_perd_id = yrp.yr_perd_id
     and l_effective_date < yrp.start_date
     and l_effective_date between cop.effective_start_date
     and cop.effective_end_date
   order by 1;

begin

  l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
  if p_comp_obj_mode then
    if p_pl_id is not null then
      open c_pl_next_popl_yr;
      fetch c_pl_next_popl_yr into p_start_date,p_end_date;
      close c_pl_next_popl_yr;
    elsif p_pgm_id is not null then
      open c_pgm_next_popl_yr;
      fetch c_pgm_next_popl_yr into  p_start_date,p_end_date;
      close c_pgm_next_popl_yr;
    elsif p_oipl_id is not null then
      open c_oipl_next_popl_yr;
      fetch c_oipl_next_popl_yr into  p_start_date,p_end_date;
      close c_oipl_next_popl_yr;
    else
    if g_debug then
        hr_utility.set_location('BEN_92489_CANNOT_CALC_DATE',55);
    end if;
      fnd_message.set_name('BEN','BEN_92489_CANNOT_CALC_DATE');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.raise_error;
    end if;
  else
    p_start_date := to_date('01/01/'||to_char(l_effective_date,'YYYY'),'dd/mm/rrrr');
    p_end_date := to_date('31/12/'||to_char(l_effective_date,'YYYY'),'dd/mm/rrrr');

  end if;
exception   -- nocopy changes
  --
  when others then
    --
    p_start_date    := null;
    p_end_date      := null;
    raise;
    --
end get_next_plan_year;

-- --------------------------------------------------------------------
-- function get_event_date used to make consistent event date handling
-- for all codes which need it.
-- --------------------------------------------------------------------
function get_event_date
  (p_cache_mode     in     boolean default false
/*
  ,p_pil_row        in     ben_per_in_ler%rowtype
*/
  ,p_per_in_ler_id  in     number
  ,p_effective_date in     date
  ) return date
is
  --
  l_event_date         date;
  --
  cursor c_per_in_ler
  is
  select pil.lf_evt_ocrd_dt
    from ben_per_in_ler pil
   where pil.per_in_ler_id = p_per_in_ler_id;
  --
begin
  if p_per_in_ler_id is null then
    l_event_date:=p_effective_date;
  else
    open c_per_in_ler;
    fetch c_per_in_ler into l_event_date;
    if c_per_in_ler%notfound then
      close c_per_in_ler;
    if g_debug then
        hr_utility.set_location('BEN_91530_CANNOT_FIND_AED_DATE',40);
    end if;
      fnd_message.set_name('BEN','BEN_91530_CANNOT_FIND_AED_DATE');
      fnd_message.raise_error;
    end if;
    close c_per_in_ler;
  end if;
  --
  -- Single exit point for readability
  --
  return l_event_date;
  --
end get_event_date;
--
--
-- function get_recorded_date used to make consistent date handling
-- for all new life event codes.
--
function get_recorded_date
  (p_cache_mode     in     boolean default false
/*
  ,p_pil_row        in     ben_per_in_ler%rowtype
*/
  ,p_per_in_ler_id  in     number
  ,p_effective_date in     date
  ) return date
is
  --
  l_pil_row        ben_pil_cache.g_pil_inst_row;
  --
  l_recorded_date  date;
  --
/*
  cursor c_per_in_ler
  is
  select pil.ntfn_dt
    from ben_per_in_ler pil
   where pil.per_in_ler_id = p_per_in_ler_id;
  --
*/
begin
  --
  if p_per_in_ler_id is null then
    --
    l_recorded_date := p_effective_date;
    --
/*
  elsif p_cache_mode
    and p_pil_row.per_in_ler_id is not null
  then
    --
    l_recorded_date := p_pil_row.ntfn_dt;
    --
*/
  else
    --
    ben_pil_cache.PIL_GetPILDets
      (p_per_in_ler_id => p_per_in_ler_id
      ,p_inst_row      => l_pil_row
      );
    --
    l_recorded_date := l_pil_row.ntfn_dt;
    --
    if l_pil_row.per_in_ler_id is null then
      --
      fnd_message.set_name('BEN','BEN_92391_CANT_FIND_RCRD_DATE');
      fnd_message.raise_error;
      --
    end if;
    --
/*
  else
    --
    open c_per_in_ler;
    fetch c_per_in_ler into l_recorded_date;
    if c_per_in_ler%notfound then
      close c_per_in_ler;
      if g_debug then
        hr_utility.set_location('BEN_92391_CANT_FIND_RCRD_DATE',40);
      end if;
      fnd_message.set_name('BEN','BEN_92391_CANT_FIND_RCRD_DATE');
      fnd_message.raise_error;
    end if;
    close c_per_in_ler;
    --
*/
  end if;
  --
  if l_recorded_date is null then
    --
    return p_effective_date;
    --
  else
    --
    return l_recorded_date;
    --
  end if;
  --
end get_recorded_date;
--
procedure main
  (p_cache_mode             in     boolean  default false
  --
  ,p_date_cd                in     varchar2
  ,p_per_in_ler_id          in     number   default null
  ,p_person_id              in     number   default null
  ,p_pgm_id                 in     number   default null
  ,p_pl_id                  in     number   default null
  ,p_oipl_id                in     number   default null
  ,p_elig_per_elctbl_chc_id in     number   default null -- optional for all
  ,p_business_group_id      in     number   default null
  ,p_formula_id             in     number   default null
  ,p_acty_base_rt_id        in     number   default null -- as a context to formula calls
  ,p_bnfts_bal_id           in     number   default null
  ,p_effective_date         in     date
  ,p_lf_evt_ocrd_dt         in     date     default null
  ,p_start_date             in     date     default null
  ,p_returned_date          out nocopy    date
  ,p_parent_person_id       in     number   default null
 -- Added two more parameters to fix the Bug 1531647
  ,p_param1                 in     varchar2 default null
  ,p_param1_value           in     varchar2 default null
  ,p_enrt_cvg_end_dt        in     date     default null
  ,p_comp_obj_mode          in     boolean  default true
  ,p_fonm_cvg_strt_dt       in     date default null
  ,p_fonm_rt_strt_dt        in     date default null
  ,p_cmpltd_dt              in     date default null
  )
is
--
  l_proc               varchar2(80)  := g_package ||'.determine_date.main';
  l_per_in_ler_id      number;
  l_person_id          number;
  l_pgm_id             number;
  l_pl_id              number;
  l_pl_typ_id          number;
  l_ler_id             number;
  l_oipl_id            number;
  l_business_group_id  number;
  l_date               date;
  l_start_date         date;
  l_end_date           date;
  l_procg_end_dt       date;
  l_next_popl_yr_strt  date;
  l_next_popl_yr_end   date;
  l_months             number;
  l_outputs            ff_exec.outputs_t;
  l_event_date         date;
  l_recorded_date      date;
  l_lf_evt_ocrd_dt     date;
  l_hire_date          date;
  l_jurisdiction_code  varchar2(30);
  l_enrt_eff_strt_date date;
  l_date_temp date;
  --
  l_pil_row            ben_per_in_ler%rowtype;
  --
 cursor c_asg is
  select asg.assignment_id,asg.organization_id
    from per_all_assignments_f asg
   where asg.person_id = l_person_id
     and asg.assignment_type <> 'C'
     and asg.primary_flag = 'Y'
     and nvl(p_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)) between asg.effective_start_date
                                                                         and asg.effective_end_date
     order by asg.assignment_type desc , asg.effective_start_date desc ;
  --
  l_asg c_asg%rowtype;
  --

  cursor c_per_elig_elctbl_chc is
  select pil.per_in_ler_id,
         pil.person_id,
         epe.pgm_id,
         epe.pl_id,
         epe.pl_typ_id,
         epe.oipl_id,
         pil.ler_id,
         epe.business_group_id,
         epe.enrt_cvg_strt_dt
    from ben_per_in_ler pil,
         ben_elig_per_elctbl_chc epe
   where epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
     and epe.per_in_ler_id = pil.per_in_ler_id;
  --
  cursor c_opt(l_oipl_id  number) is
    select opt_id
    from ben_oipl_f oipl
    where oipl_id = l_oipl_id
        and business_group_id   = p_business_group_id
        and nvl(l_lf_evt_ocrd_dt,p_effective_date)
         between oipl.effective_start_date
             and oipl.effective_end_date;
  --
  l_opt c_opt%rowtype;
  --
  cursor c_pl_typ(l_pl_id  number) is
    select pl.pl_typ_id
    from ben_pl_f pl
    where pl.pl_id = l_pl_id
        and pl.business_group_id   = p_business_group_id
        and nvl(l_lf_evt_ocrd_dt,p_effective_date)
         between pl.effective_start_date
             and pl.effective_end_date;
  --
  cursor c_ler is
    select pil.ler_id
    from   ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id
      and  pil.business_group_id   = p_business_group_id;
  --
  cursor c_pay_period(p_assignment_id number default null) is  -----------Bug 8394662
  select tpe.start_date,
         tpe.end_date
    from per_time_periods tpe,
         per_all_assignments_f asg
   where tpe.payroll_id = asg.payroll_id
     and   asg.assignment_type <> 'C'
     and asg.business_group_id = l_business_group_id
     and asg.person_id = l_person_id
     and asg.primary_flag = 'Y'
     and asg.assignment_id = nvl(p_assignment_id,asg.assignment_id) -----------Bug 8394662
     and nvl(l_lf_evt_ocrd_dt,p_effective_date)
          between asg.effective_start_date
              and asg.effective_end_date
     and nvl(l_lf_evt_ocrd_dt,p_effective_date)
         between tpe.start_date
             and tpe.end_date
     --and rownum = 1
  order by decode(asg.assignment_type,'E',1,2) asc;
  --
  Cursor c_state is
  select region_2
  from hr_locations_all loc,per_all_assignments_f asg
  where loc.location_id = asg.location_id
  and asg.person_id = p_person_id
       and   asg.assignment_type <> 'C'
       and p_effective_date between
             asg.effective_start_date and asg.effective_end_date
       and asg.business_group_id =p_business_group_id;

  l_state      c_state%rowtype;

  l_pay_period c_pay_period%rowtype;
  --
  cursor c_pay_period_for_date(p_date_dt date) is
  select tpe.start_date,
         tpe.end_date
    from per_time_periods tpe,
         per_all_assignments_f asg
   where tpe.payroll_id = asg.payroll_id
     and   asg.assignment_type <> 'C'
     and asg.business_group_id = l_business_group_id
     and asg.person_id = l_person_id
     and asg.primary_flag = 'Y'
     and nvl(l_lf_evt_ocrd_dt,p_effective_date)
           between asg.effective_start_date
               and asg.effective_end_date
     and p_date_dt between tpe.start_date and tpe.end_date
  order by decode(asg.assignment_type,'E',1,2) asc;
  --
  --   and rownum = 1;
  --
  l_pay_period_for_date c_pay_period_for_date%rowtype;
  --
  --pay period on check date
  cursor c_pay_period_for_check (p_date_dt date, p_assignment_type varchar2) is
  select min(tpe.start_date )
    from per_time_periods tpe,
         per_all_assignments_f asg
   where tpe.payroll_id = asg.payroll_id
     and   asg.assignment_type = p_assignment_type
     and asg.business_group_id = l_business_group_id
     and asg.person_id = l_person_id
     and asg.primary_flag = 'Y'
     and nvl(l_lf_evt_ocrd_dt,p_effective_date)
           between asg.effective_start_date
               and asg.effective_end_date
     and p_date_dt <= nvl(tpe.regular_payment_date,tpe.end_date);
  --
  l_start_date_check   date;
  --
  cursor c_pay_period_for_check_end
          (p_date_dt date, p_assignment_type varchar2) is
  select max(tpe.end_date )
    from per_time_periods tpe,
         per_all_assignments_f asg
   where tpe.payroll_id = asg.payroll_id
     and   asg.assignment_type = p_assignment_type
     and asg.business_group_id = l_business_group_id
     and asg.person_id = l_person_id
     and asg.primary_flag = 'Y'
     and nvl(l_lf_evt_ocrd_dt,p_effective_date)
           between asg.effective_start_date
               and asg.effective_end_date
     and p_date_dt > nvl(tpe.regular_payment_date,tpe.end_date);
  --
  l_end_date_check     date;
  --
  cursor c_next_pay_period(p_date_dt date,p_assignment_id number default null) is  -----------Bug 8394662
  select tpe.start_date,
         tpe.end_date
    from per_time_periods tpe,
         per_all_assignments_f asg
   where tpe.payroll_id = asg.payroll_id
     and   asg.assignment_type <> 'C'
     and asg.business_group_id = l_business_group_id
     and asg.person_id = l_person_id
     and asg.primary_flag = 'Y'
     and nvl(l_lf_evt_ocrd_dt,p_effective_date)
         between asg.effective_start_date
             and asg.effective_end_date
     and asg.assignment_id = nvl(p_assignment_id,asg.assignment_id)  -----------Bug 8394662
     and tpe.start_date > p_date_dt
  order by decode(asg.assignment_type,'E',1,2) asc,
        tpe.start_date;
  --   and rownum = 1
  --
  l_next_pay_period c_next_pay_period%rowtype;
  --
  --6025969 fix
  cursor c_pre_pay_period(p_date_dt date) is
  select tpe.start_date,
         tpe.end_date
    from per_time_periods tpe,
         per_all_assignments_f asg
   where tpe.payroll_id = asg.payroll_id
     and   asg.assignment_type <> 'C'
     and asg.business_group_id = l_business_group_id
     and asg.person_id = l_person_id
     and asg.primary_flag = 'Y'
     and nvl(l_lf_evt_ocrd_dt,p_effective_date)
         between asg.effective_start_date
             and asg.effective_end_date
     and tpe.end_date < p_date_dt
  order by decode(asg.assignment_type,'E',1,2) asc,
        tpe.end_date desc;

  l_pre_pay_period c_pre_pay_period%rowtype;
  --

  cursor c_pps is
  select date_start
  from per_periods_of_service  pps
  where pps.person_id = p_person_id
    and pps.date_start = (select max(pps1.date_start) -- this gets most recent
                            from per_periods_of_service pps1
                           where pps1.person_id = p_person_id
                             and pps1.date_start = nvl(l_lf_evt_ocrd_dt,p_effective_date )
                          );
  --
  cursor c_hire_date is
    select max(date_start)
    from per_periods_of_service  pps
    where pps.person_id = p_person_id
    and   pps.date_start <= nvl(l_lf_evt_ocrd_dt,p_effective_date);

  --
  cursor c_pgm_popl_lim_yr is
  select yrp.lmtn_yr_strt_dt,
         yrp.lmtn_yr_end_dt
    from ben_yr_perd yrp,
         ben_popl_yr_perd cpy
   where cpy.pgm_id = l_pgm_id
     and cpy.yr_perd_id = yrp.yr_perd_id
     and yrp.business_group_id   = l_business_group_id
     and cpy.business_group_id   = l_business_group_id
     and nvl(l_lf_evt_ocrd_dt,p_effective_date)
         between yrp.start_date
             and yrp.end_date;
  --
  cursor c_pl_popl_lim_yr is
  select yrp.lmtn_yr_strt_dt,
         yrp.lmtn_yr_end_dt
    from ben_yr_perd yrp,
         ben_popl_yr_perd cpy
   where cpy.pl_id = l_pl_id
     and cpy.yr_perd_id = yrp.yr_perd_id
     and yrp.business_group_id   = l_business_group_id
     and cpy.business_group_id   = l_business_group_id
     and nvl(l_lf_evt_ocrd_dt,p_effective_date)
         between yrp.start_date
             and yrp.end_date;
  --
  cursor c_oipl_popl_lim_yr is
  select yrp.lmtn_yr_strt_dt,
         yrp.lmtn_yr_end_dt
    from ben_yr_perd yrp,
         ben_popl_yr_perd cpy,
         ben_oipl_f cop
   where cpy.pl_id = cop.pl_id
     and cop.oipl_id = l_oipl_id
     and cpy.yr_perd_id = yrp.yr_perd_id
     and nvl(l_lf_evt_ocrd_dt,p_effective_date)
         between yrp.start_date
             and yrp.end_date
     and cpy.business_group_id   = l_business_group_id
     and cop.business_group_id   = l_business_group_id
     and yrp.business_group_id   = l_business_group_id
     and nvl(l_lf_evt_ocrd_dt,p_effective_date)
         between cop.effective_start_date
             and cop.effective_end_date;
  --
  cursor c_pil_popl is
  select pel.enrt_perd_end_dt,
         pel.procg_end_dt
    from ben_pil_elctbl_chc_popl pel,
         ben_elig_per_elctbl_chc epe
   where epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
     and epe.business_group_id   = l_business_group_id
     and epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
     and pel.business_group_id   = l_business_group_id;
  --
  l_enrt_end_dt date;
  --
  --  Removed MIN() grouping for this cursor.  Based on the
  --  where clause this should only return 1 row.
  --
  cursor c_cm_enrt_perd_strt_dt is
  select enrt_perd_strt_dt
  from ben_pil_elctbl_chc_popl
  where per_in_ler_id = l_per_in_ler_id
  and ((l_pgm_id is not null and pgm_id = l_pgm_id)
       or (l_pgm_id is null and pl_id = l_pl_id)
       or (l_pgm_id is null and l_pl_id is null))
  and business_group_id   = l_business_group_id;
  --
  cursor c_cm_enrt_perd_end_dt is
  select min(enrt_perd_end_dt)
  from ben_pil_elctbl_chc_popl
  where per_in_ler_id = l_per_in_ler_id
  and ((l_pgm_id is not null and pgm_id = l_pgm_id)
       or (l_pgm_id is null and pl_id = l_pl_id)
       or (l_pgm_id is null and l_pl_id is null))
  and business_group_id   = l_business_group_id;
  --
  cursor c_cm_dflt_asnd_dt is
  select min(dflt_asnd_dt)
  from ben_pil_elctbl_chc_popl
  where per_in_ler_id = l_per_in_ler_id
  and ((l_pgm_id is not null and pgm_id = l_pgm_id)
       or (l_pgm_id is null and pl_id = l_pl_id)
       or (l_pgm_id is null and l_pl_id is null))
  and business_group_id   = l_business_group_id;
  --
  cursor c_cm_auto_asnd_dt is
  select min(auto_asnd_dt)
  from ben_pil_elctbl_chc_popl
  where per_in_ler_id = l_per_in_ler_id
  and ((l_pgm_id is not null and pgm_id = l_pgm_id)
       or (l_pgm_id is null and pl_id = l_pl_id)
       or (l_pgm_id is null and l_pl_id is null))
  and business_group_id   = l_business_group_id;
  --
  cursor c_cm_elcns_made_dt is
  select min(elcns_made_dt)
  from ben_pil_elctbl_chc_popl
  where per_in_ler_id = l_per_in_ler_id
  and ((l_pgm_id is not null and pgm_id = l_pgm_id)
       or (l_pgm_id is null and pl_id = l_pl_id)
       or (l_pgm_id is null and l_pl_id is null))
  and business_group_id   = l_business_group_id;
  --
  cursor c_cm_elig_prtn_strt_dt is
  select min(prtn_strt_dt)
  from ben_elig_per_f pep, ben_per_in_ler pil
  where pep.person_id = p_person_id
  and   pep.business_group_id   = p_business_group_id
  and   p_effective_date = pep.effective_start_date
  and   pil.per_in_ler_id(+) = pep.per_in_ler_id
  and   pil.business_group_id = p_business_group_id
  and   (   pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
         or
            pil.per_in_ler_stat_cd is null);
  --
  cursor c_cm_elig_prtn_end_dt is
  select min(prtn_end_dt)
  from ben_elig_per_f pep, ben_per_in_ler pil
  where pep.person_id = p_person_id
--  and   pep.business_group_id   = p_business_group_id
  and   nvl(p_fonm_cvg_strt_dt,p_effective_date )  = pep.effective_start_date
  and   pil.per_in_ler_id(+) = pep.per_in_ler_id
  and   pil.business_group_id = p_business_group_id
  and   (   pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
         or
            pil.per_in_ler_stat_cd is null);
  --
  cursor c_elig_cvg_dpnt_dts is
  select  ecd.cvg_thru_dt,
          ecd.effective_end_date
    from  ben_elig_cvrd_dpnt_f ecd
    where ecd.per_in_ler_id = l_per_in_ler_id
      and ecd.business_group_id  = l_business_group_id
      and nvl(l_lf_evt_ocrd_dt,p_effective_date)
          between ecd.effective_start_date
              and ecd.effective_end_date;
  --
  cursor c_prtt_enrt_rslt_dts is
  select  pen.enrt_cvg_thru_dt,
          pen.enrt_cvg_strt_dt,
          pen.effective_start_date
    from  ben_prtt_enrt_rslt_f pen
    where pen.per_in_ler_id = l_per_in_ler_id and
          pen.pl_id=l_pl_id
      and nvl(pen.pgm_id,-1)=nvl(l_pgm_id,-1)
      and nvl(pen.oipl_id,-1)=nvl(l_oipl_id,-1)
      and pen.business_group_id  = l_business_group_id
-- Bug 1633284
/*
      and nvl(l_lf_evt_ocrd_dt,p_effective_date)
          between pen.effective_start_date
              and pen.effective_end_date; */
      and p_effective_date
          between pen.effective_start_date
             and pen.effective_end_date
--
-- Bug 4309203 Modified the effective_end_date to enrt_cvg_thru_dt as
--             effective_end_date would pick up invalid records.
      and pen.enrt_cvg_thru_dt = hr_api.g_eot ;
  --
/*
  cursor c_prtt_rt_val_dts is
  select  prv.rt_strt_dt,
          prv.rt_end_dt

    from  ben_prtt_rt_val prv,
          ben_prtt_enrt_rslt_f pen
    where pen.per_in_ler_id = l_per_in_ler_id
      and pen.pl_id=l_pl_id
      and nvl(pen.pgm_id,-1)=nvl(l_pgm_id,-1)
      and nvl(pen.oipl_id,-1)=nvl(l_oipl_id,-1)
      and pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
      and prv.business_group_id  = l_business_group_id
      and nvl(l_lf_evt_ocrd_dt,p_effective_date)
          between pen.effective_start_date
              and pen.effective_end_date;
*/
--
  cursor c_prtt_rt_val_dts is
  select null
    from
          ben_prtt_enrt_rslt_f pen
    where pen.per_in_ler_id = l_per_in_ler_id
      and pen.pl_id=l_pl_id
      and nvl(pen.pgm_id,-1)=nvl(l_pgm_id,-1)
--      and nvl(pen.oipl_id,-1)=nvl(l_oipl_id,-1)
--      and pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
      and pen.business_group_id  = l_business_group_id
      and p_effective_date
          between pen.effective_start_date
              and pen.effective_end_date;
--
-- Added to fix code ODBEWM
--
   cursor c_enrt_rt_val_dt is
   select er.rt_strt_dt
    from  ben_enrt_rt er,
          ben_enrt_bnft eb
   where  eb.elig_per_elctbl_chc_id =p_elig_per_elctbl_chc_id
   and    er.elig_per_elctbl_chc_id is null
   and    eb.enrt_bnft_id=er.enrt_bnft_id
   --
   union
   --
   select er.rt_strt_dt
    from  ben_enrt_rt er
    where er.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id ;

  cursor c_elig_dpnt_dts is
  select  ecd.cvg_strt_dt,
          ecd.cvg_thru_dt
    from  ben_elig_cvrd_dpnt_f ecd
    where ecd.per_in_ler_id = l_per_in_ler_id
      and ecd.business_group_id  = l_business_group_id
      and nvl(l_lf_evt_ocrd_dt,p_effective_date)
          between ecd.effective_start_date
              and ecd.effective_end_date;

  cursor c_birth_date is
  select  paf.date_of_birth
    from  per_all_people_f paf
    where paf.person_id = p_person_id;
  --
  cursor c_ler_id is
    select pil.ler_id
    from   ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id;
  --
 cursor c_pay_id is
  select asg.payroll_id
    from per_time_periods tpe,
         per_all_assignments_f asg
   where tpe.payroll_id = asg.payroll_id
     and   asg.assignment_type <> 'C'
     and asg.business_group_id = l_business_group_id
     and asg.person_id = l_person_id
     and nvl(l_lf_evt_ocrd_dt,p_effective_date)
          between asg.effective_start_date
              and asg.effective_end_date
     and nvl(l_lf_evt_ocrd_dt,p_effective_date)
         between tpe.start_date
             and tpe.end_date
  order by decode(asg.assignment_type,'E',1,2) asc;


  l_payroll_id  number ;
  --
  l_enrt_cvg_end_dt date;
  l_enrt_cvg_strt_dt date;
  l_cvg_thru_dt date;
  l_effective_end_date date;
  l_cm_date date;
  l_dummy   varchar2(30) ;
  l_fonm_rt_cvg_strt_dt  date ;
  l_rl_lf_evt_ocrd_dt    date ;
  l_cmpltd_dt            date ;
  l_ben_disp_ff_warn_msg varchar2(10);
  l_env   ben_env_object.g_global_env_rec_type;  -- 6823087 (CWB Requirement for 'ENTRBL')
  l_mode  l_env.mode_cd%TYPE;                    -- 6823087 (CWB Requirement for 'ENTRBL')
--
  ----------Bug 8394662
  l_organization_id  number;
  l_payroll_id1      number;
  l_assignment_id    number;
  -----------Bug 8394662
begin

--    hr_utility.trace_on (null, 'ORACLE');

  g_debug := hr_utility.debug_enabled;
  --
  -- Commented out for performance
  --
  --
  --  hr_utility.set_location('Entering :'|| l_proc,10);
  --        comment these out until we need to debug a code
  --  hr_utility.set_location('p_date_cd               : '||p_date_cd                ,15);
  --  hr_utility.set_location('p_per_in_ler_id         : '||p_per_in_ler_id          ,15);
  --  hr_utility.set_location('p_person_id             : '||p_person_id              ,15);
  --  hr_utility.set_location('p_pgm_id                : '||p_pgm_id                 ,15);
  --  hr_utility.set_location('p_pl_id                 : '||p_pl_id                  ,15);
  --  hr_utility.set_location('p_oipl_id               : '||p_oipl_id                ,15);
  --  hr_utility.set_location('p_elig_per_elctbl_chc_id: '||p_elig_per_elctbl_chc_id ,15);
  --  hr_utility.set_location('p_effective_date        : '||p_effective_date         ,15);
  --  hr_utility.set_location('p_lf_evt_ocrd_dt        : '||p_lf_evt_ocrd_dt         ,15);
  --  hr_utility.set_location('p_start_date            : '||p_start_date             ,15);
  --  hr_utility.set_location('person         : '||p_person_id         ,665);
  --  hr_utility.set_location('parent         : '||p_parent_person_id         ,665);
  --
  --- Fonm2  Determine the fonm and effective date
  l_fonm_rt_cvg_strt_dt  :=  nvl(p_fonm_cvg_strt_dt,p_fonm_rt_strt_dt) ;
  l_lf_evt_ocrd_dt      :=  nvl(l_fonm_rt_cvg_strt_dt, p_lf_evt_ocrd_dt ) ;
  ---



  If p_elig_per_elctbl_chc_id  is not null then
    --
    -- If electible choice id has a value, then gather other important data
    -- needed by routines below.  If electable choice is null, then the calling
    -- procedures will have to provide these values:   per_in_ler_id,
    -- person_id, pl_id, oipl_id, pgm_id.
    --
   if g_debug then
     hr_utility.set_location('open c_per_elig_elctbl_chc',10);
   end if;

    open c_per_elig_elctbl_chc;

    fetch c_per_elig_elctbl_chc into
          l_per_in_ler_id,
          l_person_id,
          l_pgm_id,
          l_pl_id,
          l_pl_typ_id,
          l_oipl_id,
          l_ler_id,
          l_business_group_id,
          l_enrt_cvg_strt_dt;

    if g_debug then
      hr_utility.set_location('l_enrt_cvg_strt_dt from c_per_elig_elctbl_chc'||l_enrt_cvg_strt_dt,19);
    end if;

    if c_per_elig_elctbl_chc%notfound then
      close c_per_elig_elctbl_chc;
    if g_debug then
        hr_utility.set_location('BEN_91529_CANNOT_FIND_ELEC_CHC',40);
    end if;
      fnd_message.set_name('BEN','BEN_91529_CANNOT_FIND_ELEC_CHC');
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.set_token('ELIG_PER_ELCTBL_CHC_ID',p_elig_per_elctbl_chc_id);
      fnd_message.raise_error;
    end if;
    close c_per_elig_elctbl_chc;

  else

    l_per_in_ler_id     := p_per_in_ler_id;
    l_person_id         := p_person_id;
    l_pgm_id            := p_pgm_id;
    l_pl_id             := p_pl_id;
    l_oipl_id           := p_oipl_id;
    l_business_group_id := p_business_group_id;
    --
/*
    --
    -- Removed because called twice
    --
    open c_ler_id;
      --
      fetch c_ler_id into l_ler_id;
      --
    close c_ler_id;
*/
    --
  end if;
  ----------Bug 8394662
    if p_acty_base_rt_id is not null then
        l_organization_id := null;
	l_payroll_id1 := null;
	l_assignment_id := null;
        ben_element_entry.get_abr_assignment (p_person_id       => p_person_id
					     ,p_effective_date  => p_effective_date
					     ,p_acty_base_rt_id => p_acty_base_rt_id
					     ,p_organization_id => l_organization_id
					     ,p_payroll_id      => l_payroll_id1
					     ,p_assignment_id   => l_assignment_id);

    hr_utility.set_location('p_acty_base_rt_id : '||p_acty_base_rt_id,10);
    hr_utility.set_location('l_payroll_id1 : '||l_payroll_id1,10);
    hr_utility.set_location('l_assignment_id : '||l_assignment_id,10);
    end if;
    ------------Bug 8394662
  --
  -- when the date determinne from pay period for the  contact
  -- decide whether the contct has pay_period  bug 1510665


  if p_parent_person_id is not null   and p_date_cd in
      ('AFDCPP','AFDFPP','ALDCPP','ALDLPPEPPY',
       'FDLPPEPPY','FDLPPEPPYCF','FDPPCF','LAFDFPP','LALDCPP','LALDLPPEPPY',
       'LFDPPCF', 'LWALDCPP','FDPPCF','LALDPPP','WALDCPP','WALDLPPEPPY',
       'LWALDLPPEPPY','FDLPPPPYAES', 'EEELDPPADI','LDPPFEE','LDPPOAEE',
       'FDPPCFES','FDPPFES','LESFDPPAD','FDPPFED','FDPPOED','FDPPELD' )
  then
       open c_pay_id ;
       fetch c_pay_id into l_payroll_id ;
       if c_pay_id%notfound then
          l_person_id := p_parent_person_id ;
          if g_debug then
            hr_utility.set_location('for chold prill not found '        ,665);
          end if;
       end if ;
       close c_pay_id ;
  end if ;

  if g_debug then
    hr_utility.set_location('person   : '||l_person_id      ,665);
  end if;
/*

  -- Check for cache mode. If so then get the per in ler details
  -- for the per in ler id
  --
  if p_cache_mode then
    --
    ben_pil_object.get_object
      (p_per_in_ler_id => l_per_in_ler_id
      ,p_rec           => l_pil_row
      );
    --
  end if;
  --
*/

  if g_debug then
    hr_utility.set_location('l_lf_evt_ocrd_dt :'||l_lf_evt_ocrd_dt,19);
  end if;
  if g_debug then
    hr_utility.set_location('p_date_cd :'||p_date_cd,19);
  end if;

  -- AED - Event Date

  if p_date_cd in  ( 'AED' , 'NUMDOE')  then
  --
  if g_debug then
      hr_utility.set_location('Entering AED',10);
  end if;
    --
    if l_lf_evt_ocrd_dt is null then
    --
       p_returned_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       p_returned_date:= l_lf_evt_ocrd_dt;
    --
    end if;
  --
  -- WAED 1 prior or Event
  --
  elsif p_date_cd = 'WAED' then
  --
  if g_debug then
      hr_utility.set_location('Entering AED',10);
  end if;
      --
      if l_lf_evt_ocrd_dt is null then
        --
        l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
        --
      else
        --
        l_event_date:= l_lf_evt_ocrd_dt;
        --
      end if;
        --
        p_returned_date := l_event_date - 1;
        --
  -----------------------------------------------------------
  --
  -- OFDEP    - On Enrollment Period Start.
  -- 5DAFDEP  -  5 Days After Enrollment Period Start.
  -- 10DAFDEP - 10 Days After Enrollment Period Start.
  -- 10DBSEPD - 10 Days before Enrollment Period Start.
  -- 15DAFDEP - 15 Days After Enrollment Period Start.
  -- 20DAFDEP - 20 Days After Enrollment Period Start.
  -- 25DAFDEP - 25 Days After Enrollment Period Start.
  -- 30DAFDEP - 20 Days After Enrollment Period Start.
  -- TODFEPS  - 31 Days After Enrollment Period Start.
  -- FFDFEPS  - 45 Days After Enrollment Period Start.
  -- SDFEPSD  - 60 Days After Enrollment Period Start.
  -- NDFEPS   - 90 Days After Enrollment Period Start.
  --
  -----------------------------------------------------------
  elsif p_date_cd = 'FFDFEPS'  or p_date_cd = 'NDFEPS'   or
        p_date_cd = 'TODFEPS'  or p_date_cd = 'SDFEPSD'  or
        p_date_cd = 'OFDEP'    or p_date_cd = '5DAFDEP'  or
        p_date_cd = '10DAFDEP' or p_date_cd = '10DBSEPD' or
        p_date_cd = '15DAFDEP' or p_date_cd = '20DAFDEP' or
        p_date_cd = '25DAFDEP' or p_date_cd = '30DAFDEP' then
    --
  if g_debug then
      hr_utility.set_location('Entering '||p_date_cd,10);
  end if;
    --
    open c_cm_enrt_perd_strt_dt;
      fetch c_cm_enrt_perd_strt_dt into l_cm_date;
    --
    if c_cm_enrt_perd_strt_dt%notfound then
    --
      if p_start_date is not null then
      --
         l_cm_date := p_start_date;
      --
      else
      --
        close c_cm_enrt_perd_strt_dt;
      if g_debug then
         hr_utility.set_location('BEN_91942_PEL_NOT_FOUND',40);
      end if;
        fnd_message.set_name('BEN', 'BEN_91942_PEL_NOT_FOUND');
        fnd_message.set_token('DATE_CODE',p_date_cd);
        fnd_message.set_token('L_PROC',l_proc);
        fnd_message.raise_error;
      --
      end if;
    --
    end if;
    --
    close c_cm_enrt_perd_strt_dt;
    --
    if p_date_cd  = 'OFDEP' then
    --
       p_returned_date := l_cm_date;
    --
    elsif p_date_cd  = '5DAFDEP' then
    --
      p_returned_date := l_cm_date + 5;
    --
    elsif p_date_cd  = '10DAFDEP' then
    --
      p_returned_date := l_cm_date + 10;
    --
    elsif p_date_cd  = '10DBSEPD' then
    --
      p_returned_date := l_cm_date - 10;
    --
    elsif p_date_cd  = '15DAFDEP' then
    --
      p_returned_date := l_cm_date + 15;
    --
    elsif p_date_cd  = '20DAFDEP' then
    --
      p_returned_date := l_cm_date + 20;
    --
    elsif p_date_cd  = '25DAFDEP' then
    --
      p_returned_date := l_cm_date + 25;
    --
    elsif p_date_cd  = '30DAFDEP' then
    --
      p_returned_date := l_cm_date + 30;
    --
    elsif p_date_cd  = 'TODFEPS' then
    --
       p_returned_date := l_cm_date + 31;
    --
    elsif p_date_cd  = 'FFDFEPS' then
    --
       p_returned_date := l_cm_date + 45;
    --
    elsif p_date_cd  = 'SDFEPSD' then
    --
      p_returned_date := l_cm_date + 60;
    --
    elsif p_date_cd  = 'NDFEPS' then
    --
       p_returned_date := l_cm_date + 90;
    --
    end if;
  --
  -- ------------------------------------------------------------------------
  -- Enrollment End
  -- ------------------------------------------------------------------------
  -- LDPPFEE - End of Pay Period After Enrollment End
  -- LDPPOAEE - End of Pay Period On or After Enrollment End
  -- FDLMPPYAES - First of Last Month in Year After enrollment
  -- FDLPPPPYAES - First of Last Pay Period in Event Year After Enrollment Start
  -- LDMFEE - Last day of Month after Enrollment End
  -- LDMOAEE - Last day of Month on or after Enrollment End
  -- EEELDPPADI - Earlier of Enrollment End or Last Day of Pay Period after
  --              Dedesignated or Ineligible
  -- EEELDMADI - Earlier of Enrollment End or Last Day of Month after
  --             Dedesignated or Ineligible
  -- EEDI - Earliest of Enrollment End, Dedesignated or Ineligible
  -- OCED - On the Coverage End Date.
  -- PECED - Participant's Enrollment Coverage End Date.

  elsif p_date_cd  = 'LDPPFEE' or p_date_cd = 'LDPPOAEE' or p_date_cd = 'FDLMPPYAES'
    or p_date_cd = 'FDLPPPPYAES' or p_date_cd = 'LDMFEE' or p_date_cd = 'LDMOAEE'
    or p_date_cd = 'EEELDPPADI' or p_date_cd = 'EEELDMADI' or p_date_cd = 'EEDI'
    or p_date_cd = 'OCED' or p_date_cd = 'PECED'  then
    --
    if g_debug then
      hr_utility.set_location('Entering '||p_date_cd,23);
    end if;
    --
    if l_lf_evt_ocrd_dt is null then
       l_lf_evt_ocrd_dt:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    end if;

    if p_start_date is null then
       -- p_start_date is the enrollment coverage end date in this case.
       open c_prtt_enrt_rslt_dts;
       fetch c_prtt_enrt_rslt_dts into l_enrt_cvg_end_dt,
                                    l_enrt_cvg_strt_dt,
                                    l_enrt_eff_strt_date;
       if g_debug then
         hr_utility.set_location('l_enrt_cvg_end_dt cursor returns ', 19);
       end if;
       close c_prtt_enrt_rslt_dts;
    else
       l_enrt_cvg_end_dt := p_start_date;
    end if;


    if p_date_cd = 'FDLPPPPYAES' or p_date_cd = 'EEELDPPADI' then
       if p_date_cd = 'FDLPPPPYAES' then
          -- First of Last Pay Period in Event Year
          get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_enrt_cvg_strt_dt -- l_enrt_cvg_end_dt 5303167
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;
       elsif p_date_cd = 'EEELDPPADI' then
          -- Earlier of Enrollment End or Last Day of Pay Period after
          --              Dedesignated or Ineligible
          l_end_date := p_effective_date+1;
       end if;

       open c_pay_period_for_date(l_end_date);  -- l_end_date is just a parm
       fetch c_pay_period_for_date into
          l_start_date,
          l_end_date;  -- l_end_date is now the payroll end date.

       if c_pay_period_for_date%notfound and l_enrt_eff_strt_date is not null then
         close c_pay_period_for_date;
       if g_debug then
           hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',15);
       end if;
         fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
         fnd_message.set_token('DATE_CODE',p_date_cd);
         fnd_message.set_token('L_PROC',l_proc);
         fnd_message.set_token('PERSON_ID',l_person_id);
         fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
         fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
         fnd_message.raise_error;
       end if;
       close c_pay_period_for_date;

       if p_date_cd = 'FDLPPPPYAES' then
          p_returned_date := l_start_date;
       elsif p_date_cd = 'EEELDPPADI' then
          if l_enrt_cvg_end_dt < l_end_date then
             p_returned_date := l_enrt_cvg_end_dt;
          else
             p_returned_date := l_end_date;
          end if;
       end if;

    elsif p_date_cd  = 'LDPPFEE' or p_date_cd = 'LDPPOAEE'
       then
       -- End of Pay Period (On or) After
       if l_enrt_cvg_end_dt <>  hr_api.g_eot then
       --
       if g_debug then
         hr_utility.set_location(' Step 2 ' ,19);
       end if;
       open c_pay_period_for_date(l_enrt_cvg_end_dt);
       fetch c_pay_period_for_date into
          l_start_date,
          l_end_date;

       if c_pay_period_for_date%notfound and l_enrt_eff_strt_date is not null then
         close c_pay_period_for_date;
         if g_debug then
           hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',15);
         end if;
         fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
         fnd_message.set_token('DATE_CODE',p_date_cd);
         fnd_message.set_token('L_PROC',l_proc);
         fnd_message.set_token('PERSON_ID',l_person_id);
         fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
         fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
         fnd_message.raise_error;
       end if;
       close c_pay_period_for_date;

       else
          if g_debug then
            hr_utility.set_location('End of Time set 1 ' , 19 );
          end if;
          l_end_date := l_enrt_cvg_end_dt ;
       end if ;

       --
       if l_enrt_cvg_end_dt <>  hr_api.g_eot then
       --
       if l_end_date = l_enrt_cvg_end_dt then
          if p_date_cd = 'LDPPFEE' then
             -- End of Pay Period After
             -- retrieve last day of next pay period
             if g_debug then
               hr_utility.set_location(' Step 3 ' ,19);
             end if;
             open c_pay_period_for_date(l_end_date+1);
             fetch c_pay_period_for_date into
                l_start_date,
                l_end_date;

             if c_pay_period_for_date%notfound and
               l_enrt_eff_strt_date is not null then
               close c_pay_period_for_date;
               if g_debug then
                 hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',25);
               end if;
               fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
               fnd_message.set_token('DATE_CODE',p_date_cd);
               fnd_message.set_token('L_PROC',l_proc);
               fnd_message.set_token('PERSON_ID',l_person_id);
               fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
               fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
               fnd_message.raise_error;
             end if;
             close c_pay_period_for_date;
          end if;
       end if ;
       --
       else
          if g_debug then
            hr_utility.set_location('End of Time set 2' , 19 );
          end if;
          l_end_date := l_enrt_cvg_end_dt ;
       end if;

       p_returned_date := l_end_date;

    elsif p_date_cd = 'FDLMPPYAES' then
       -- First of Last Month in Year
       get_plan_year
           (p_effective_date =>  p_effective_date
           ,p_lf_evt_ocrd_dt => l_enrt_cvg_strt_dt -- 5303167 l_enrt_cvg_end_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;

       p_returned_date := last_day(add_months(l_end_date,-1))+1;
       -- ? What if enrollment date is during last month of year
    elsif p_date_cd = 'LDMFEE'  then
       -- Last day of Month after
       p_returned_date := last_day(l_enrt_cvg_end_dt+1);
    elsif p_date_cd = 'LDMOAEE' then
       -- Last day of Month on or after
       p_returned_date := last_day(l_enrt_cvg_end_dt);
    elsif p_date_cd = 'EEELDMADI' then
       --  Earlier of Enrollment End or Last Day of Month after
       --  Dedesignated or Ineligible
       if l_enrt_cvg_end_dt < last_day(p_effective_date +1) then
          p_returned_date := l_enrt_cvg_end_dt;
       else
          p_returned_date := last_day(p_effective_date +1);
       end if;
    elsif p_date_cd = 'EEDI' then
       -- Earliest of Enrollment End, Dedesignated or Ineligible
       if l_enrt_cvg_end_dt < p_effective_date then
          p_returned_date := l_enrt_cvg_end_dt;
       else
          p_returned_date := p_effective_date ;
       end if;
    elsif p_date_cd = 'OCED' then
       -- Enrollment End
       p_returned_date := l_enrt_cvg_end_dt;
    elsif p_date_cd = 'PECED' then
       if p_enrt_cvg_end_dt is not null then
          p_returned_date := p_enrt_cvg_end_dt;
       else
          p_returned_date := l_enrt_cvg_end_dt;
       end if;
    end if;

  -- ------------------------------------------------------------------------
  -- Enrollment Start or Later
  -- ------------------------------------------------------------------------
  --
  -- LEMES - Later of Elections Made or Enrollment Start
  -- LFYEMES - First of Year After Later Elections or Enrollment Start
  -- LFMEMES - First of Month After Later Elections or Enrollment Start
  -- FDMCFES - First of Month on or After Enrollment Start
  -- FDMFES - First of Month After Enrollment Start
  -- LFPPEMES - First of Pay Period After Later Elections or Enrollment Start
  -- FDPPCFES - First of Pay Period On or After Enrollment
  -- FDPPFES - First of Pay Period after Enrollment Start
  -- LESWD - Later of Enrollment Start or When Dedesignated
  -- LESFDPPAD - Later of Enrt Strt or First Day of Pay Period after Dedesignated
  -- LESFDMAD - Later of Enrt Start or First Day of Month after Dedesignated
  -- FDSMFES - First of Semi month after enrollment start
  -- FDSMCFES - First of Semi Month on or After Enrollment
  -- LESFDSMAD - Later of Enrollment Start or First of Semi Month After
  --             Designated
  elsif p_date_cd  = 'LEMES' or p_date_cd = 'LFPPEMES' or p_date_cd = 'LFMEMES'
    or  p_date_cd  = 'LFYEMES'  or p_date_cd = 'FDMCFES'  or p_date_cd = 'FDMFES'
    or p_date_cd = 'FDPPCFES' or p_date_cd = 'FDPPFES'  or p_date_cd = 'LESWD'
    or p_date_cd = 'LESFDPPAD' or p_date_cd = 'LESFDMAD' or p_date_cd = 'FDPPELD'
    or p_date_cd = 'FDSMFES' or p_date_cd = 'FDSMCFES' or p_date_cd = 'LESFDSMAD'
    then
   if g_debug then
     hr_utility.set_location('Entering '||p_date_cd,17);
   end if;
   if g_debug then
     hr_utility.set_location('l_lf_evt_ocrd_dt :'||l_lf_evt_ocrd_dt , 17);
   end if;

    if l_lf_evt_ocrd_dt is null then
       l_lf_evt_ocrd_dt:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       if g_debug then
         hr_utility.set_location('In the get_event_date '||l_lf_evt_ocrd_dt,17);
       end if ;
    end if;

   if g_debug then
     hr_utility.set_location('before cursor l_enrt_cvg_strt_dt:'||l_enrt_cvg_strt_dt,18);
   end if;

    open c_prtt_enrt_rslt_dts;
    fetch c_prtt_enrt_rslt_dts into l_enrt_cvg_end_dt,
                                    l_enrt_cvg_strt_dt,
                                    l_enrt_eff_strt_date;
    -- bug fix 1633284  if the cursor fails, we are using the p_start_date and
    -- p_effective_date parameters for further processing.

        --Bug 5225815 commented the p_start_date not null check.
       --assign the default when no prior elections exists

       --Bug 5394353 Undid Modification done for Bug 5225815
       --Uncommented the p_start_date not null check.
       --p_start_date would be null in cases where rt_strt_dt is to be calculated at enrollment

    if c_prtt_enrt_rslt_dts%notfound  and   p_start_date is not null then
      l_enrt_cvg_strt_dt   := p_start_date ;
      l_enrt_eff_strt_date := p_effective_date ;
    end if;
    --
    close c_prtt_enrt_rslt_dts;
     if g_debug then
       hr_utility.set_location('l_enrt_cvg_end_dt :'||l_enrt_cvg_end_dt , 18);
     end if;
     if g_debug then
       hr_utility.set_location('l_enrt_cvg_strt_dt:'||l_enrt_cvg_strt_dt,18);
     end if;
     if g_debug then
       hr_utility.set_location('l_enrt_eff_strt_date:'||l_enrt_eff_strt_date,18);
     end if;
    --
    --
    if p_date_cd  = 'LEMES' or p_date_cd = 'LFPPEMES' or p_date_cd = 'LFMEMES'
       or p_date_cd  = 'LFYEMES'  then
       -- Later of Elections Made or Enrollment Start
       -- For all but LEMES, this is just a starting date. More code below.
       if l_enrt_cvg_strt_dt > l_enrt_eff_strt_date then
          p_returned_date := l_enrt_cvg_strt_dt;
       else
          p_returned_date := l_enrt_eff_strt_date;
       end if;
    else  -- start with enrollment start date.
          p_returned_date := l_enrt_cvg_strt_dt;
    end if;
      --

    -- LESFDSMAD - Later of Enrollment Start or First of Semi Month After
    --
    if p_date_cd = 'LESFDSMAD' then
      --
      if to_char(p_effective_date, 'DD') > 15 then
        --
        l_event_date := round(p_effective_date,'Month') ;
        --
      else
        --
        l_event_date := round(p_effective_date,'Month')+ 15  ;
        --
      end if;
      --
      if l_enrt_cvg_strt_dt > l_event_date then
        --
        p_returned_date := l_enrt_cvg_strt_dt ;
        --
      else
        --
        p_returned_date := l_event_date ;
        --
      end if;
    --
    end if ;
    --
    -- FDSMFES - First of Semi month after enrollment start
    -- FDSMCFES - First of Semi Month on or After Enrollment
    if p_date_cd = 'FDSMFES' or p_date_cd = 'FDSMCFES' then
      --
      if p_date_cd = 'FDSMCFES' and to_number(to_char(l_enrt_cvg_strt_dt, 'DD')) in ( 1, 16 )
      then
        --
        p_returned_date := l_enrt_cvg_strt_dt ;
        if g_debug then
          hr_utility.set_location('Case 1',15);
        end if;
        --
      elsif to_char(l_enrt_cvg_strt_dt, 'DD') > 15 then
        --
        p_returned_date := round(l_enrt_cvg_strt_dt,'Month')  ;
        if g_debug then
          hr_utility.set_location('Case 2',15);
        end if;
        --
      else
        --
        p_returned_date := round(l_enrt_cvg_strt_dt,'Month') + 15 ;
        if g_debug then
          hr_utility.set_location('Case 3'||l_enrt_cvg_strt_dt,15);
        end if;
        if g_debug then
          hr_utility.set_location('Case 3'||p_returned_date,15);
        end if;

        --
      end if;
      --
    end if;
    --
    if p_date_cd = 'FDPPCFES' or p_date_cd ='FDPPELD'  then
       -- First of Pay Period On or After Enrollment
       --
       if  p_date_cd ='FDPPELD' then
          p_returned_date := p_effective_date;
       end if;
       --
       open c_pay_period_for_date(p_returned_date);
       fetch c_pay_period_for_date into
          l_start_date,
          l_end_date;

       if c_pay_period_for_date%notfound and
         l_enrt_cvg_strt_dt is not null then
         if g_debug then
           hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',80);
         end if;
         fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
         fnd_message.set_token('DATE_CODE',p_date_cd);
         fnd_message.set_token('L_PROC',l_proc);
         fnd_message.set_token('PERSON_ID',l_person_id);
         fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
         fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
         fnd_message.raise_error;
       end if;
       close c_pay_period_for_date;
    end if;

    if (p_date_cd = 'FDPPCFES' or p_date_cd ='FDPPELD' ) and p_returned_date = l_start_date
       then
          null; -- use p_returned_date (enrt strt)
    elsif ((p_date_cd = 'FDPPCFES' or p_date_cd ='FDPPELD')
            and p_returned_date <> l_start_date)
          or p_date_cd = 'LFPPEMES' or p_date_cd = 'FDPPFES'
          or p_date_cd = 'LESFDPPAD' then
           if g_debug then
             hr_utility.set_location('LFPPEMES  First of Pay Period After',20);
           end if;
          -- First of Pay Period After
          if p_date_cd = 'LESFDPPAD' then
             -- need to get pay period after designation, not enrt strt.
             p_returned_date := nvl(l_fonm_rt_cvg_strt_dt, p_effective_date );
          end if;
          open c_next_pay_period(p_returned_date);
          fetch c_next_pay_period into l_next_pay_period;

          if g_debug then
            hr_utility.set_location('l_next_pay_period.start_date'||l_next_pay_period.start_date,20);
          end if;
          if c_next_pay_period%notfound and
             l_enrt_cvg_strt_dt is not null then
            close c_next_pay_period;
            if g_debug then
              hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',40);
            end if;
            fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
            fnd_message.set_token('DATE_CODE',p_date_cd);
            fnd_message.set_token('L_PROC',l_proc);
            fnd_message.set_token('PERSON_ID',l_person_id);
            fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
            fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
            fnd_message.raise_error;
          end if;
          close c_next_pay_period;

          if p_date_cd = 'LESFDPPAD' and
             l_enrt_eff_strt_date > l_next_pay_period.start_date then
             -- Later of Enrt Strt or First Day of Pay Period after Dedesignated
             p_returned_date := l_enrt_eff_strt_date;
          else
             p_returned_date := l_next_pay_period.start_date;
             if g_debug then
               hr_utility.set_location('Else case :'||l_next_pay_period.start_date,20);
             end if;
          end if;

    elsif p_date_cd = 'LFMEMES' or p_date_cd = 'FDMCFES' or p_date_cd = 'FDMFES'
          then
          -- First of Month
          if p_date_cd = 'FDMCFES' and to_char(p_returned_date, 'dd') = '01' then
             null;  -- use p_returned_date (enrt strt)
          else
             p_returned_date := last_day(p_returned_date)+1;
          end if;
    elsif p_date_cd = 'LESFDMAD' then
          -- Later of Enrt Start or First Day of Month after Dedesignated
          if last_day(p_effective_date)+1 > p_returned_date then
             p_returned_date := last_day(p_effective_date)+1;
          end if;  -- else use p_returned date (enrt strt)
    elsif p_date_cd  = 'LFYEMES' then
          -- First of Year
          get_next_plan_year
                 (p_effective_date => p_effective_date
                 ,p_lf_evt_ocrd_dt => p_returned_date
                 ,p_pl_id          => l_pl_id
                 ,p_pgm_id         => l_pgm_id
                 ,p_oipl_id        => l_oipl_id
                 ,p_date_cd        => p_date_cd
                 ,p_comp_obj_mode  => p_comp_obj_mode
                 ,p_start_date     => l_next_popl_yr_strt
                 ,p_end_date       => l_next_popl_yr_end) ;

          p_returned_date :=l_next_popl_yr_strt;
    elsif  p_date_cd = 'LESWD' then
          -- Later of Enrollment Start or When Dedesignated
          if l_enrt_cvg_strt_dt > p_effective_date then
             p_returned_date := l_enrt_cvg_strt_dt;
          else
             p_returned_date := p_effective_date;
          end if;
    end if;
  --
  elsif p_date_cd = 'FDPPFED' or p_date_cd = 'LDPPFEFD' then
   --
   open c_next_pay_period(p_effective_date);
   fetch c_next_pay_period into l_next_pay_period;
   if g_debug then
     hr_utility.set_location('l_next_pay_period.start_date'||l_next_pay_period.start_date,20);
   end if;
   if c_next_pay_period%notfound then
      close c_next_pay_period;
      fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.set_token('PERSON_ID',l_person_id);
      fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
      fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
      fnd_message.raise_error;
   end if;
   close c_next_pay_period;
   if p_date_cd = 'FDPPFED' then
     p_returned_date := l_next_pay_period.start_date;
   else
     p_returned_date := l_next_pay_period.end_date;
   end if;
 --
 -- ** FDPPOED - First of Pay Period On or After Effective Date
 elsif p_date_cd = 'FDPPOED' then
    -- Bug:4268494: Changed the logic. Get the current pay-period start/end dates
    -- If start_date <> effective_date, fetch next pay period start/end dates. Return start_date.
    hr_utility.set_location('Evaluate FDPPOED',10);
    l_event_date := NVL(l_fonm_rt_cvg_strt_dt,p_effective_date);
    --
    open c_pay_period;
    fetch c_pay_period into l_pay_period;
    if c_pay_period%notfound then
      close c_pay_period;
      fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('PERSON_ID',l_person_id);
      fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
      fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
      fnd_message.raise_error;
    end if;
    close c_pay_period ;
    --
    if l_event_date =  l_pay_period.start_date then
       p_returned_date := l_pay_period.start_date;
       hr_utility.set_location('l_pay_period.start_date '||l_pay_period.start_date,10);
    else
       --
       open c_next_pay_period(NVL(l_event_date,p_effective_date));
       fetch c_next_pay_period into l_next_pay_period;
       --
       if c_next_pay_period%notfound then
         close c_next_pay_period;
         fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
         fnd_message.set_token('DATE_CODE',p_date_cd);
         fnd_message.set_token('PERSON_ID',l_person_id);
         fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
         fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
         fnd_message.raise_error;
       end if;
       close c_next_pay_period;
       p_returned_date := l_next_pay_period.start_date;
       hr_utility.set_location('l_pay_period.start_date '|| l_next_pay_period.start_date,20);
       --
    end if;
    --
 --
 -- ** LDPPOEFD - 1 Prior or End of Pay Period On or After Effective Date
 elsif p_date_cd = 'LDPPOEFD' THEN
    -- Bug:4268494: Changed the logic. Get the current pay-period start/end dates
    -- If end_date <> effective_date, fetch next pay period start/end dates. Return end_date.
    hr_utility.set_location('Evaluate LDPPOEFD',10);
    l_event_date := NVL(l_fonm_rt_cvg_strt_dt,p_effective_date);
    --
    open c_pay_period;
    fetch c_pay_period into l_pay_period;
    if c_pay_period%notfound then
      close c_pay_period;
      fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('PERSON_ID',l_person_id);
      fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
      fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
      fnd_message.raise_error;
    end if;
    close c_pay_period ;
    --
    if l_event_date =  l_pay_period.end_date then
       p_returned_date := l_pay_period.end_date;
       hr_utility.set_location('l_pay_period.end_date '|| l_pay_period.end_date,20);
    else
       --
       open c_next_pay_period(NVL(l_event_date,p_effective_date));
       fetch c_next_pay_period into l_next_pay_period;
       --
       if c_next_pay_period%notfound then
         close c_next_pay_period;
         fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
         fnd_message.set_token('DATE_CODE',p_date_cd);
         fnd_message.set_token('PERSON_ID',l_person_id);
         fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
         fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
         fnd_message.raise_error;
       end if;
       close c_next_pay_period;
       p_returned_date := l_next_pay_period.end_date;
       hr_utility.set_location('l_pay_period.end_date '|| l_next_pay_period.end_date,20);
       --
    end if;
  --
  -- AFDCSMFDFFNSM First of next Semi month,if from day is first,
  --               else first of next semi month
  elsif p_date_cd = 'AFDCSMFDFFNSM' then

    l_lf_evt_ocrd_dt := nvl(l_fonm_rt_cvg_strt_dt,p_effective_date ) ;   -- Age Determination
    --
    if to_number(to_char(l_lf_evt_ocrd_dt, 'DD')) in (1,16) then
      --
      p_returned_date := l_lf_evt_ocrd_dt ;
      --
    elsif to_char(l_lf_evt_ocrd_dt, 'DD') > 15 then
      --
      p_returned_date := round(l_lf_evt_ocrd_dt,'Month')  ;
      --
    else
      --
      p_returned_date := round(l_lf_evt_ocrd_dt,'Month') + 15 ;
      --
    end if;

    -- FDSMCF - First of Semi Month on or After Event
    --
    elsif p_date_cd = 'FDSMCF' then
      --
      if l_lf_evt_ocrd_dt is null then
      --
        l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
      --
      else
        l_event_date:=  l_lf_evt_ocrd_dt ;
      --
      end if;
        --
        if to_number(to_char(l_event_date, 'DD')) in ( 1, 16 ) then
          --
          p_returned_date := l_event_date ;
          --
        elsif to_char(l_event_date, 'DD') > 15 then
          --
          p_returned_date := last_day(l_event_date)+1  ;
          --
        else
          --
          p_returned_date := trunc(l_event_date,'Month') + 15 ;
          --
        end if;
        --
    -- LAFDFSM - First of Semi Month After Later Event or Notified
    --
    elsif p_date_cd = 'LAFDFSM' then
      --
      if l_lf_evt_ocrd_dt is null then
      --
        l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
      --
      else
      --
        l_event_date:= l_lf_evt_ocrd_dt;
      --
      end if;

      --
      l_recorded_date := get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
      --
      if l_event_date > l_recorded_date then
        --
        if to_char(l_event_date, 'DD') > 15 then
          --
          p_returned_date := last_day(l_event_date)+1  ;
          --
        else
          --
          p_returned_date := trunc(l_event_date,'Month') + 15 ;
          --
        end if;
      else
        --
        if to_char(l_recorded_date, 'DD') > 15 then
          --
          p_returned_date := last_day(l_recorded_date)+1  ;
          --
        else
          --
          p_returned_date := trunc(l_recorded_date,'Month') + 15 ;
          --
        end if;
        --
      end if;
      --
    -- LFDSMCF - First of Semi Month on or After Later Event or Notified
    --
    elsif p_date_cd = 'LFDSMCF' then
      --
      if l_lf_evt_ocrd_dt is null then
      --
        l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
      --
      else
      --
        l_event_date:= l_lf_evt_ocrd_dt;
      --
      end if;
      --
      l_recorded_date := get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
      --
      if l_event_date > l_recorded_date then
        --
        if  to_number(to_char(l_event_date, 'DD')) in ( 1, 16 ) then
          --
          p_returned_date := l_event_date ;
          --
        elsif to_char(l_event_date, 'DD') > 15 then
          --
          p_returned_date := last_day(l_event_date)+1  ;
          --
        else
          --
          p_returned_date := trunc(l_event_date,'Month') + 15 ;
          --
        end if;
        --
      else
        --
        if to_number(to_char(l_recorded_date, 'DD')) in ( 1, 16 ) then
          --
          p_returned_date := l_recorded_date ;
          --
        elsif to_char(l_recorded_date, 'DD') > 15 then
          --
          p_returned_date := last_day(l_recorded_date)+1  ;
          --
        else
          --
          p_returned_date := trunc(l_recorded_date,'Month') + 15 ;
          --
        end if;
        --
      end if;

  -- 1 Prior or Later Event or Notified Semi Month End
  --
  elsif p_date_cd = 'LWALDCSM' then
  --    --
    if g_debug then
      hr_utility.set_location('Entering LWALDCSM',10);
    end if;
    --
       if l_lf_evt_ocrd_dt is null then
       --
          l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       else
       --
          l_event_date:= l_lf_evt_ocrd_dt;
       --
       end if;
       --
       l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       If l_recorded_date > l_event_date then
       --
          if to_char(l_recorded_date, 'DD') > 15 then
            p_returned_date := round(l_recorded_date,'Month')  ;
          else
            p_returned_date := round(l_recorded_date,'Month') + 15 ;
          end if;
       --
       else
       --
          --
          if to_char(l_event_date, 'DD') > 15 then
             p_returned_date := round(l_event_date,'Month')  ;
          else
             p_returned_date := round(l_event_date,'Month') + 15 ;
          end if;
          --
       End If;
    --
  -- 1 Prior or Semi Month End
  -- Semi Month end is if le is between 1 and 15 then take 15 else take end of month
  --

  elsif p_date_cd = 'WALDCSM' then
  --    --
    if g_debug then
      hr_utility.set_location('Entering WALDCSM',10);
    end if;
    --
       if l_lf_evt_ocrd_dt is null then
       --
          l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       else
       --
          l_event_date:= l_lf_evt_ocrd_dt;
       --
       end if;
       --
       if to_char(l_event_date, 'DD') > 15 then
          p_returned_date := last_day(l_event_date)  ;
       else
          p_returned_date := trunc(l_event_date,'Month') + 14 ;
       end if;
       --
       if g_debug then
         hr_utility.set_location('p_returned_date  '||p_returned_date , 19 );
       end if;
    --
  --
  -- EEELDNSMADI --  Earlier Participant Enrollment End or Next Semi Month End
  -- for dependent coverage end date
  elsif p_date_cd = 'EEELDNSMADI' then
  --
    if g_debug then
      hr_utility.set_location('Entering EEELDNSMADI',10);
    end if;
    --
      --
      --  p_effective_date   -- Designated Date
      --
      if to_char(p_effective_date, 'DD') > 15 then
        --
        l_event_date := round( nvl(l_fonm_rt_cvg_strt_dt,p_effective_date))+ 14 ;
        --
      else
        --
        l_event_date := last_day(nvl(l_fonm_rt_cvg_strt_dt,p_effective_date)) ;
        --
      end if;
      --
      open c_prtt_enrt_rslt_dts;
      --
      fetch c_prtt_enrt_rslt_dts into l_enrt_cvg_end_dt,
                                      l_enrt_cvg_strt_dt,
                                      l_enrt_eff_strt_date;
      --
      close c_prtt_enrt_rslt_dts;
      --
      if l_enrt_cvg_end_dt < l_event_date then
        --
	p_returned_date := l_enrt_cvg_end_dt ;
        --
      else
        --
        p_returned_date := l_event_date ;
        --
      end if;
      --
  -- ALDPSM End of Previuos Semi Month  ( if day between 1 and 15 then last day of prev month
  --                                      else 15th of the same month )
  --
  elsif p_date_cd = 'ALDPSM' then
  --
       --
       if g_debug then
         hr_utility.set_location('Entering ALDPSM',10);
       end if;
       --
       if l_lf_evt_ocrd_dt is null then
       --
          l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       else
       --
          l_event_date:= l_lf_evt_ocrd_dt;
       --
       end if;
       --
       if to_char(l_event_date, 'DD') > 15 then
          p_returned_date := trunc(l_event_date,'Month')+ 14 ;
       else
          p_returned_date := last_day(add_months(l_event_date,-1)) ;
       end if;
  --
  -- LALDPSM End of Previuos Semi Month later event or Notified
  --            ( if later day between 1 and 15 then last day of prev month
  --                                      else 15th of the same month )
  --
  elsif p_date_cd = 'LALDPSM' then
  --
       --
       if g_debug then
         hr_utility.set_location('Entering ALDPSM',10);
       end if;
       --
       if l_lf_evt_ocrd_dt is null then
       --
          l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       else
       --
          l_event_date:= l_lf_evt_ocrd_dt;
       --
       end if;
       --
       l_recorded_date := get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       if l_event_date > l_recorded_date then
         --
         if to_char(l_event_date, 'DD') > 15 then
           --
           p_returned_date := trunc(l_event_date,'Month')+ 14 ;
           --
         else
           --
           p_returned_date := last_day(add_months(l_event_date,-1)) ;
           --
         end if;
         --
       else
         --
         if to_char(l_recorded_date, 'DD') > 15 then
           --
           p_returned_date := trunc(l_recorded_date,'Month')+ 14 ;
           --
         else
           --
           p_returned_date := last_day(add_months(l_recorded_date,-1)) ;
           --
         end if;
         --
       end if;
       --
  --
  --  ALDCSM End of Semi-month.
  --
  elsif p_date_cd = 'ALDCSM' then
    --
    if g_debug then
      hr_utility.set_location('Entering ALDCSM',10);
    end if;
    --
    if l_lf_evt_ocrd_dt is null then
      --
      l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
      --
    else
      --
      l_event_date:= l_lf_evt_ocrd_dt;
      --
    end if;
    --
    if to_char(l_event_date, 'DD') > 15 then
       --
       p_returned_date := last_day(l_event_date)  ;
       --
    else
       --
       p_returned_date := trunc(l_event_date,'Month') + 14 ;
       --
    end if;
    --
    if g_debug then
      hr_utility.set_location('p_returned_date '||p_returned_date , 199) ;
    end if;
  --
  --  LALDCSM End of Semi-month later event or Notified.
  --
  elsif p_date_cd = 'LALDCSM' then
    --
    if g_debug then
      hr_utility.set_location('Entering LALDCSM',10);
    end if;
    --
    if l_lf_evt_ocrd_dt is null then
      --
      l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
      --
    else
      --
      l_event_date:= l_lf_evt_ocrd_dt;
      --
    end if;
    --
    l_recorded_date := get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    if l_event_date > l_recorded_date then
      --
      if to_char(l_event_date, 'DD') > 15 then
        --
        p_returned_date := last_day(l_event_date)  ;
        --
      else
        --
        p_returned_date := trunc(l_event_date,'Month') + 14 ;
        --
      end if;
    else
      --
      if to_char(l_recorded_date, 'DD') > 15 then
        --
        p_returned_date := last_day(l_recorded_date)  ;
        --
      else
        --
        p_returned_date := trunc(l_recorded_date,'Month') + 14 ;
        --
      end if;
      --
    end if;
  --
  --  AFDFSM First of next Semi-month.
  --
  elsif p_date_cd = 'AFDFSM' then
    --
    if g_debug then
      hr_utility.set_location('Entering AFDFSM',10);
    end if;
    --
    if l_lf_evt_ocrd_dt is null then
    --
      l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
      l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    if to_char(l_event_date, 'DD') > 15 then
      p_returned_date := round(l_event_date,'Month')  ;
    else
      p_returned_date := round(l_event_date,'Month') + 15 ;
    end if;
    --
  --  AFDCSM First of Semi-month.
  --
  elsif p_date_cd = 'AFDCSM' then
    --
    if g_debug then
      hr_utility.set_location('Entering AFDCSM',10);
    end if;
    --
    if l_lf_evt_ocrd_dt is null then
    --
      l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
      l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    if to_char(l_event_date, 'DD') > 15 then
      --
      p_returned_date := trunc(l_event_date,'Month')+ 15  ;
      --
    else
      --
      p_returned_date := trunc(l_event_date,'Month')  ;
      --
    end if;
    --


  -- -------------------------------------------------------------------------
  -- After Completion
  -- -------------------------------------------------------------------------
  -- eg:  year 1-jan to 31-dec.  a. dt = 4-feb  b. dt=1-jan   c. dt=2-dec
  -- FDMCFC - First of Month on or After Completed
     -- a. 1-mar            b. 1-jan        c. 1-Jan-next
  -- FDMFC - First of Month After Completed
  -- FDLMPPYFC - First of Last Month in Year After Completion
     -- a. 1-dec            b. 1-dec        c. ?1-jan-next
  -- FDLPPPPYFC - First of Last Pay Period in Year After Completion
  -- FDPPCFC - First of Pay Period On or After Completion
     -- a. 1-mar            b. 1-jan        c. 1-jan-next  (if monthly)
  -- FDPPFC - First of Pay Period After Completion
  -- FDPPYCFC - First of Year On or After Completed
     -- a. 1-Jan-next       b. 1-Jan        c. 1-Jan-next
  -- FDPPYFC - First of Year After Completed
     -- a. 1-Jan-next       b. 1-Jan-next   c. 1-Jan-next
  -- FDSMFC First of Semi Month after Completion
     -- a. if day upto 15 then take 16th of the month else take 1st of following month
  -- FDSMCFC First of Semi Month on or after Completion
     -- a. if day upto 15 then take 16th of the month else take 1st of following month
     -- exception is for 1 take 1 and for 16 take 16
  --
  elsif p_date_cd  = 'FDMCFC' or p_date_cd = 'FDMFC' or p_date_cd = 'FDLMPPYFC'
     or p_date_cd = 'FDLPPPPYFC' or p_date_cd = 'FDPPCFC' or p_date_cd = 'FDPPFC'
     or p_date_cd = 'FDPPYCFC' or p_date_cd = 'FDPPYFC'
     or p_date_cd = 'FDSMFC' or p_date_cd = 'FDSMCFC'
  then

    if g_debug then
      hr_utility.set_location('Entering '||p_date_cd,14);
    end if;

    l_lf_evt_ocrd_dt := nvl(l_fonm_rt_cvg_strt_dt, p_effective_date) ;  -- completion date.

    l_cmpltd_dt     := nvl(p_cmpltd_dt,p_effective_date);

    if to_char( nvl(l_cmpltd_dt, p_effective_date), 'dd') = '01' and p_date_cd = 'FDMCFC' then
       -- First of Month on or After Completed
       -- p_returned_date :=  nvl(l_fonm_rt_cvg_strt_dt, p_effective_date);
       p_returned_date := l_cmpltd_dt ;
       --
    elsif p_date_cd = 'FDSMFC' then
      -- First of Semi Month after Completion
      if g_debug then
        hr_utility.set_location('Entering FDSMFC',10);
      end if;
      --
      /*
      if to_char(l_lf_evt_ocrd_dt, 'DD') > 15 then
        p_returned_date := round(l_lf_evt_ocrd_dt,'Month')  ;
      else
        p_returned_date := round(l_lf_evt_ocrd_dt,'Month') + 15 ;
      end if;
      */
      if to_char(l_cmpltd_dt, 'DD') > 15 then
        p_returned_date := round(l_cmpltd_dt,'Month')  ;
      else
        p_returned_date := round(l_cmpltd_dt,'Month') + 15 ;
      end if;
    --
    elsif p_date_cd = 'FDSMCFC' then
      -- First of Semi Month on or after Completion
      if g_debug then
        hr_utility.set_location('Entering FDSMCFC',10);
      end if;
      --
      /*
      if to_number(to_char(l_lf_evt_ocrd_dt, 'DD')) in ( 1, 16 )  then
         p_returned_date := l_lf_evt_ocrd_dt ;
      elsif to_char(l_lf_evt_ocrd_dt, 'DD') > 15 then
        p_returned_date := round(l_lf_evt_ocrd_dt,'Month')  ;
      else
        p_returned_date := round(l_lf_evt_ocrd_dt,'Month') + 15 ;
      end if;
      */
      if to_number(to_char(l_cmpltd_dt, 'DD')) in ( 1, 16 )  then
         p_returned_date := l_cmpltd_dt ;
      elsif to_char(l_cmpltd_dt, 'DD') > 15 then
        p_returned_date := round(l_cmpltd_dt,'Month')  ;
      else
        p_returned_date := round(l_cmpltd_dt,'Month') + 15 ;
      end if;
      --
    elsif (p_date_cd = 'FDMCFC' and to_char(l_cmpltd_dt, 'dd') <> '01')
          or p_date_cd = 'FDMFC' then
       -- First of Month After Completed
       -- p_returned_date := last_day(p_effective_date)+1;
       --
       p_returned_date := last_day(l_cmpltd_dt)+1;
       --
    elsif p_date_cd = 'FDLMPPYFC' or p_date_cd = 'FDPPYCFC' or p_date_cd = 'FDPPYFC'
       then
       get_plan_year
           (p_effective_date =>  p_effective_date
           ,p_lf_evt_ocrd_dt => l_cmpltd_dt -- l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;

        if p_date_cd = 'FDLMPPYFC' then
           -- First of Last Month in Year After Completion
           if  nvl(l_cmpltd_dt, p_effective_date) >=  add_months(l_end_date,-1)+1 then
              -- if eff dt is on or after first day of last month in plan year
              -- use first day of month in next plan year?
              p_returned_date := last_day(l_end_date)+1;
           else
              p_returned_date := last_day(add_months(l_end_date,-1))+1;
           end if;
        elsif p_date_cd = 'FDPPYCFC' and l_cmpltd_dt = l_start_date then
           -- First of Year On or After Completed
              p_returned_date := l_start_date;
        elsif (p_date_cd = 'FDPPYCFC' and  nvl(l_cmpltd_dt, p_effective_date) <> l_start_date) or
               p_date_cd = 'FDPPYFC' then
               -- First of Year After Completed
               get_next_plan_year
                 (p_effective_date =>   p_effective_date
                 ,p_lf_evt_ocrd_dt => l_cmpltd_dt
                 ,p_pl_id          => l_pl_id
                 ,p_pgm_id         => l_pgm_id
                 ,p_oipl_id        => l_oipl_id
                 ,p_date_cd        => p_date_cd
                 ,p_comp_obj_mode  => p_comp_obj_mode
                 ,p_start_date     => l_start_date
                 ,p_end_date       => l_end_date) ;

                p_returned_date :=l_start_date;

        end if;
    elsif p_date_cd = 'FDLPPPPYFC'  or p_date_cd = 'FDPPCFC'  or p_date_cd = 'FDPPFC'
         then
        -- First of Last Pay Period in Year After Completion
        -- FDLPPPPYFC  this is wrong - emailed Denise for correction.

        -- First of Pay Period (On or) After Completion
        if p_date_cd =  'FDPPCFC' then
           open c_pay_period_for_date( nvl(l_cmpltd_dt, p_effective_date));
           fetch c_pay_period_for_date into l_start_date, l_end_date;
           if c_pay_period_for_date%notfound and
              p_effective_date is not null then
              close c_pay_period_for_date;
            if g_debug then
                hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',45);
            end if;
              fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
              fnd_message.set_token('DATE_CODE',p_date_cd);
              fnd_message.set_token('L_PROC',l_proc);
              fnd_message.set_token('PERSON_ID',l_person_id);
              fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
              fnd_message.set_token('EFFECTIVE_DATE',l_cmpltd_dt);
              fnd_message.raise_error;

           end if;
           close c_pay_period_for_date;

           if p_effective_date = l_start_date then
              p_returned_date := l_start_date;
           end if;
        end if;

        if (l_cmpltd_dt <> l_start_date and p_date_cd = 'FDPPCFC') or
           p_date_cd = 'FDPPFC' then

           open c_next_pay_period(nvl(l_cmpltd_dt,p_effective_date));
           fetch c_next_pay_period into l_next_pay_period;

           if c_next_pay_period%notfound and
              p_effective_date is not null then
             close c_next_pay_period;
           if g_debug then
               hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',55);
           end if;
             fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
             fnd_message.set_token('DATE_CODE',p_date_cd);
             fnd_message.set_token('L_PROC',l_proc);
             fnd_message.set_token('PERSON_ID',l_person_id);
             fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
             fnd_message.set_token('EFFECTIVE_DATE',l_cmpltd_dt);
             fnd_message.raise_error;
           end if;
           close c_next_pay_period;

           p_returned_date := l_next_pay_period.start_date;
        end if;
    end if;


  --
  -- AFDELY - First of Limitation Year
  --
  elsif p_date_cd  = 'AFDELY' then
  --
  if g_debug then
      hr_utility.set_location('Entering AFDELY',10);
  end if;
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_lf_evt_ocrd_dt:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_lf_evt_ocrd_dt:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    --  get end date for comp object
    --
    if l_pl_id is not null then
      open c_pl_popl_lim_yr;
      fetch c_pl_popl_lim_yr into l_start_date, l_end_date;
      close c_pl_popl_lim_yr;
    --
    elsif l_pgm_id is not null then
      open c_pgm_popl_lim_yr;
      fetch c_pgm_popl_lim_yr into l_start_date, l_end_date;
      close c_pgm_popl_lim_yr;
    --
    elsif l_oipl_id is not null then
      open c_oipl_popl_lim_yr;
      fetch c_oipl_popl_lim_yr into l_start_date, l_end_date;
      close c_oipl_popl_lim_yr;
    --
    else
    if g_debug then
        hr_utility.set_location('BEN_92489_CANNOT_CALC_DATE',55);
    end if;
      fnd_message.set_name('BEN','BEN_92489_CANNOT_CALC_DATE');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.raise_error;
    --
    end if;
    --
    p_returned_date:= l_start_date;
  --
  -- ALDELMY - End of Limitation Year
  --
  elsif p_date_cd  = 'ALDELMY' then
  --
  if g_debug then
      hr_utility.set_location('Entering ALDELMY',10);
  end if;
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_lf_evt_ocrd_dt:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_lf_evt_ocrd_dt:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    --  get end date for comp object
    --
    if l_pl_id is not null then
      open c_pl_popl_lim_yr;
      fetch c_pl_popl_lim_yr into l_start_date, l_end_date;
      close c_pl_popl_lim_yr;
    --
    elsif l_pgm_id is not null then
      open c_pgm_popl_lim_yr;
      fetch c_pgm_popl_lim_yr into l_start_date, l_end_date;
      close c_pgm_popl_lim_yr;
    --
    elsif l_oipl_id is not null then
      open c_oipl_popl_lim_yr;
      fetch c_oipl_popl_lim_yr into l_start_date, l_end_date;
      close c_oipl_popl_lim_yr;
    --
    else
    --  hr_utility.set_location('BEN_92489_CANNOT_CALC_DATE',55);
      fnd_message.set_name('BEN','BEN_92489_CANNOT_CALC_DATE');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.raise_error;
    --
    end if;
    --
    p_returned_date:= l_end_date;
  --
  -- FDODD - Within 5 Days After Due
  --
  elsif p_date_cd = 'FDODD' then
  --
  --  hr_utility.set_location('Entering FDODD',10);
    --
    p_returned_date:= p_effective_date + 5;
  --
  -- FRTYFV - Within 45 Days After Due
  --
  elsif p_date_cd = 'FRTYFV' then
  --
  --  hr_utility.set_location('Entering FRTYFV',10);
    --
    p_returned_date:= p_effective_date + 45;
  ---
  -- TDODD - Within 10 Days after Due
  --
  elsif p_date_cd = 'TDODD' then
  --
  --  hr_utility.set_location('Entering TDODD',10);
    --
    p_returned_date:= p_effective_date + 10;
  --
  -- THRTY - Within 30 Days after Due
  --
  elsif p_date_cd = 'THRTY' then
  --
  --  hr_utility.set_location('Entering THRTY',10);
    --
    p_returned_date:= p_effective_date + 30;
  --
  -- THRTYONE - Within 31 Days after Due
  --
  elsif p_date_cd = 'THRTYONE' then
  --
  --  hr_utility.set_location('Entering THRTYONE',10);
    --
    p_returned_date:= p_effective_date + 31;
  --
  -- DO - Date Occurred
  --
  elsif p_date_cd = 'DO' then
  --
  --  hr_utility.set_location('Entering DO',10);

    p_returned_date:= p_effective_date;
  --
  -- DR - Date Recorded or Notified
  --
  elsif p_date_cd in ('DR','ODNPE') then
  --
  --  hr_utility.set_location('Entering DR',10);

    p_returned_date:= sysdate;
  --
  -- LOR - Later Occurred Date or Recorded Date.
  --
  elsif p_date_cd = 'LOR' then
  --
  --  hr_utility.set_location('Entering LOR',10);
    --
    if sysdate > nvl(l_lf_evt_ocrd_dt,hr_api.g_sot) then
      p_returned_date := sysdate;
    else
      p_returned_date := p_effective_date;
    end if;
  --
  -- DAO - Day After Occurred Date.
  -- or
  -- ODAED - One day after Event Date
  --
    --
  elsif p_date_cd = 'DAO' or p_date_cd = 'ODAED' then
  --
  --  hr_utility.set_location('Entering DAO',10);
  --  hr_utility.set_location('Entering ODAED',10);
    --
    --p_returned_date := p_effective_date + 1;
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    p_returned_date:=l_event_date+1;
    --
  --
  -- LDAOR -  Later of Day After Occurred Date
  --          or Recorded Date.
  --
  elsif p_date_cd = 'LDAOR' then
  --
  --  hr_utility.set_location('Entering LDAOR',10);
    --
    if sysdate > (nvl(l_lf_evt_ocrd_dt,hr_api.g_sot) + 1) then
      p_returned_date := sysdate;
    else
      p_returned_date := p_effective_date + 1;
    end if;
  --
  -- ALDECLY - End of Calendar Year
  --
  elsif p_date_cd = 'ALDECLY' then
  --
  --  hr_utility.set_location('Entering ALDECLY',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    p_returned_date:= add_months(trunc(l_event_date,'YYYY'),12)-1;
    --
  --
  --
  -- FFDFED - 45 Days After Event
  --
  elsif p_date_cd = 'FFDFED' then
  --
  --  hr_utility.set_location('Entering FFDFED',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    p_returned_date := l_event_date+45;
  --
  -- NDFED - 90 Days After Event
  --
  elsif p_date_cd = 'NDFED' then
  --
  --  hr_utility.set_location('Entering NDFED',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    p_returned_date := l_event_date+90;
  --
  -- LFFDFED - 45 Days After Later Event or Notified
  --
  elsif p_date_cd = 'LFFDFED' then
    --
  --  hr_utility.set_location('Entering LFFDFED',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    l_recorded_date := get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    if l_event_date > l_recorded_date then
    --
       l_date := l_event_date+45;
    --
    else
    --
       l_date := l_recorded_date+45;
    --
    end if;
    --
    p_returned_date := l_date;
  --
  -- LNDFED - 90 Days After Later Event or Notified
  --
  elsif p_date_cd = 'LNDFED' then
    --
  --  hr_utility.set_location('Entering LNDFED',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    l_recorded_date := get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    if l_event_date > l_recorded_date then
    --
       l_date := l_event_date+90;
    --
    else
    --
       l_date := l_recorded_date+90;
    --
    end if;
    --
    p_returned_date := l_date;
  --
  -- LTDFED - 30 Days After Later Event or Notified
  --
  elsif p_date_cd = 'LTDFED' then
    --
  --  hr_utility.set_location('Entering LTDFED',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    l_recorded_date := get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    if l_event_date > l_recorded_date then
    --
       l_date := l_event_date+30;
    --
    else
    --
       l_date := l_recorded_date+30;
    --
    end if;
    --
    p_returned_date := l_date;
  --
  -- ALDPM - End of Previous Month
  --
  elsif p_date_cd = 'ALDPM' then

  --  hr_utility.set_location('Entering ALDPM',10);

    if l_lf_evt_ocrd_dt is null then

       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    else

       l_event_date:= l_lf_evt_ocrd_dt;

    end if;

    l_date := add_months(l_event_date,-1);

    p_returned_date := last_day(l_date);

  -- LALDPM - End of Previous Month Later Event or Notified

  elsif p_date_cd = 'LALDPM' then

  --  hr_utility.set_location('Entering LALDPM',10);

    if l_lf_evt_ocrd_dt is null then

       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    else

       l_event_date:= l_lf_evt_ocrd_dt;

    end if;

    l_recorded_date := get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    if l_event_date > l_recorded_date then

       l_date := add_months(l_event_date,-1);

    else

       l_date := add_months(l_recorded_date,-1);

    end if;
    p_returned_date := last_day(l_date);

  -- ALDPPP - End of Previous Pay period

  elsif p_date_cd = 'ALDPPP' then
    --
  --  hr_utility.set_location('Entering ALDPPP',10);

    if l_lf_evt_ocrd_dt is null then

       l_lf_evt_ocrd_dt := get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    else

       l_lf_evt_ocrd_dt := l_lf_evt_ocrd_dt;

    end if;

    open c_pay_period;
      fetch c_pay_period into l_pay_period;

    if c_pay_period%notfound then

      close c_pay_period;
    --  hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',65);
      fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.set_token('PERSON_ID',l_person_id);
      fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
      fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
      fnd_message.raise_error;

    end if;

    close c_pay_period ;

    p_returned_date := l_pay_period.start_date-1;

  -- LALDPPP - End of Previous Pay period Later Event or Notified

  elsif p_date_cd = 'LALDPPP' then
    --
  --  hr_utility.set_location('Entering LALDPPP',10);

    if l_lf_evt_ocrd_dt is null then

       l_lf_evt_ocrd_dt := get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    else

       l_lf_evt_ocrd_dt := l_lf_evt_ocrd_dt;

    end if;

    l_recorded_date := get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    -- Use later of event or recorded date

    if l_lf_evt_ocrd_dt < l_recorded_date then

       l_lf_evt_ocrd_dt := l_recorded_date;

    end if;

    open c_pay_period;
      fetch c_pay_period into l_pay_period;

    if c_pay_period%notfound then

      close c_pay_period;
    --  hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',70);
      fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.set_token('PERSON_ID',l_person_id);
      fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
      fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
      fnd_message.raise_error;

    end if;

    close c_pay_period ;

    p_returned_date := l_pay_period.start_date-1;


  -- LALDPPPY - Last Day of previous Program or Plan Year
  --            Later Event or Notified

  elsif p_date_cd  = 'LALDPPPY' then

  --  hr_utility.set_location('Entering LALDPPPY',10);

    if l_lf_evt_ocrd_dt is null then

       l_lf_evt_ocrd_dt:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    else

       l_lf_evt_ocrd_dt := l_lf_evt_ocrd_dt;

    end if;

    l_recorded_date := get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    -- Use later of event or recorded date

    if l_lf_evt_ocrd_dt < l_recorded_date then

       l_lf_evt_ocrd_dt := l_recorded_date;

    end if;

    get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;

    p_returned_date := l_start_date-1;

  -- -------------------------------------------------------------------
  -- First Day of Quarters
  -- -------------------------------------------------------------------
  -- eg:  year 1-jan to 31-dec.  a. dt = 1-feb  b. dt=1-jul   c. dt=1-nov
  -- *AFDCPPQ - First day of current program or plan Quarter
     -- a. 1-Jan            b. 1-jul        c. 1-Oct
  -- AFDFPPQ - First of next Quarter
     -- a. 1-Apr            b. 1-oct        c. 1-Jan-Next
  -- *LAFDFPPQ - First of Quarter After Later Event or Notified
     -- a. 1-Apr            b. 1-oct        c. 1-Jan-Next
  -- FDPPQCF - First of Quarter on or After Event
     -- a. 1-Apr            b. 1-jul        c. 1-Jan-Next
  -- *LFDPPQCF - First of Quarter on or After Later Event or Notified
     -- a. 1-Apr            b. 1-jul        c. 1-Jan-Next

  -- -------------------------------------------------------------------
  -- Last Day of Quarters
  -- -------------------------------------------------------------------
  -- *ALDCPPQ -  Last Day of the Current Program or Plan Quarter
     -- a. 31-Mar            b. 30-Sep        c. 31-dec
  -- LALDCPPQ - End of Quarter Later event or Notified
     -- a. 31-Mar            b. 30-Sep        c. 31-dec
  -- *ALDPPPQ - End of Previous Quarter
     -- a. 31-Dec-last       b. 30-Jun        c. 31-sep
  -- LALDPPPQ - End of Previous Quarter Later Event or Notified
     -- a. 31-Dec-last       b. 30-Jun        c. 31-sep



  elsif p_date_cd = 'AFDFPPQ' or p_date_cd = 'ALDCPPQ' or p_date_cd = 'FDPPQCF'
     or p_date_cd = 'AFDCPPQ' or p_date_cd = 'LAFDFPPQ' or p_date_cd = 'ALDPPPQ'
     or p_date_cd = 'LALDPPPQ' or p_date_cd = 'LALDCPPQ' or p_date_cd = 'LFDPPQCF'
     then

  --  hr_utility.set_location('Entering '||p_date_cd,12);

    if l_lf_evt_ocrd_dt is null then
       l_lf_evt_ocrd_dt := get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    end if;

    if p_date_cd = 'LAFDFPPQ' or p_date_cd = 'LALDPPPQ' or p_date_cd = 'LALDCPPQ'
       or p_date_cd = 'LFDPPQCF' then
       -- Use later of event or recorded date
       l_recorded_date := get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       if l_lf_evt_ocrd_dt < l_recorded_date then
          l_lf_evt_ocrd_dt := l_recorded_date;
       end if;
    end if;

    get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;

    l_months := round(months_between(l_end_date,l_start_date)/4);
    l_date := add_months(l_start_date,l_months); -- end date of '1st' quarter

    -- First day of quarters:
    if p_date_cd = 'AFDFPPQ'  or p_date_cd = 'LAFDFPPQ' then -- First of next Qtr
       if l_lf_evt_ocrd_dt < l_date then
          p_returned_date := l_date;

       elsif l_lf_evt_ocrd_dt < add_months(l_date,l_months) then
          p_returned_date := add_months(l_date,l_months);

       elsif l_lf_evt_ocrd_dt < add_months(l_date,(2*l_months)) then
          p_returned_date := add_months(l_date,(2*l_months));

       elsif l_lf_evt_ocrd_dt <= l_end_date then
          p_returned_date := l_end_date+1;
       end if;
    elsif p_date_cd = 'FDPPQCF' or p_date_cd = 'LFDPPQCF' then
       --First of Quarter on or After Event
       if l_lf_evt_ocrd_dt = l_start_date then
          p_returned_date := l_start_date;

       elsif l_lf_evt_ocrd_dt <= l_date then
          p_returned_date := l_date;
       elsif l_lf_evt_ocrd_dt <= add_months(l_date,l_months) then
          p_returned_date := add_months(l_date,l_months);

       elsif l_lf_evt_ocrd_dt <= add_months(l_date,(2*l_months)) then
          p_returned_date := add_months(l_date,(2*l_months));

       elsif l_lf_evt_ocrd_dt <= l_end_date then
          p_returned_date := l_end_date+1;
       end if;
    elsif p_date_cd = 'AFDCPPQ' then  --First day of current pgm or plan Qtr
       if l_lf_evt_ocrd_dt < l_date then
          p_returned_date := l_start_date;

       elsif l_lf_evt_ocrd_dt < add_months(l_date,l_months) then
          p_returned_date := l_date;

       elsif l_lf_evt_ocrd_dt < add_months(l_date,(2*l_months)) then
          p_returned_date := add_months(l_date,(l_months));

       elsif l_lf_evt_ocrd_dt <= l_end_date then
          p_returned_date := add_months(l_date,(2*l_months));
       end if;

    -- last day of quarters:
    elsif p_date_cd = 'ALDCPPQ' or p_date_cd = 'LALDCPPQ' then
       --Last Day of the Current Pgm or Plan Qtr
       if l_lf_evt_ocrd_dt < l_date then
          p_returned_date := l_date-1;

       elsif l_lf_evt_ocrd_dt < add_months(l_date,l_months) then
         p_returned_date := add_months(l_date,l_months)-1;

       elsif l_lf_evt_ocrd_dt < add_months(l_date,(2*l_months)) then
          p_returned_date := add_months(l_date,(2*l_months))-1;

       elsif l_lf_evt_ocrd_dt <= l_end_date then
          p_returned_date := l_end_date;
       end if;
    elsif p_date_cd = 'ALDPPPQ' or p_date_cd = 'LALDPPPQ' then  -- End of Prev Qtr
       if l_lf_evt_ocrd_dt < l_date then
          p_returned_date := l_start_date-1;

       elsif l_lf_evt_ocrd_dt < add_months(l_date,l_months) then
          p_returned_date := l_date-1;

       elsif l_lf_evt_ocrd_dt < add_months(l_date,(2*l_months)) then
          p_returned_date := add_months(l_date,l_months)-1;

       elsif l_lf_evt_ocrd_dt <= l_end_date then
          p_returned_date := add_months(l_date,(2*l_months))-1;
       end if;

    end if;

  -- SDBED - Sixty days Before Event Date
  elsif p_date_cd = 'SDBED' then

  --  hr_utility.set_location('Entering SDBED',10);

    if l_lf_evt_ocrd_dt is null then

       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    else

       l_event_date:= l_lf_evt_ocrd_dt;

    end if;

    p_returned_date := l_event_date - 60;


  -- -------------------------------------------------------------------
  -- First Day of Semi (or Half) Years
  -- -------------------------------------------------------------------

  -- eg:  year 1-jan to 31-dec.  a. dt = 1-feb  b. dt=1-jul   c. dt=1-nov
  -- AFDCSPPY - First day of current program or plan semi year
     -- a. 1-Jan            b. 1-jul        c. 1-jul
  -- FDSPPYCF - First Day of Half year On or After Event
     -- a. 1-jul            b. 1-jul        c. 1-jan-next
  -- LFDPPSYCF - first of half year on or after later of event or notified
     -- a. 1-jul            b. 1-jul        c. 1-jan-next
  -- LAFDFPPSY - Later: First day of following program or plan semi year
     -- a. 1-jul            b. 1-jan-next    c. 1-jan-next
  -- AFDFPPSY - First day of following program or plan semi year
     -- a. 1-jul            b. 1-jan-next    c. 1-jan-next

  -- -------------------------------------------------------------------
  -- Last Day of Semi (or Half) Years
  -- -------------------------------------------------------------------
  -- ALDCPPSY - Last day of current program or plan semi year
     -- a. 30-jun            b. 31-dec       c. 31-dec
  -- LALDCPPSY - End of Half Year Later Event or Notified
     -- a. 30-jun            b. 31-dec       c. 31-dec
  -- ALDPPPSY - Last day of previous program or plan semi year
     -- a. 31-dec-prev       b. 31-jun       c. 31-jun
  -- LALDPPPSY - Last day of prev pgm or plan semiyear- Later Event or Notified
     -- a. 31-dec-prev       b. 31-jun       c. 31-jun

  elsif p_date_cd  = 'LFDPPSYCF' or p_date_cd  = 'FDSPPYCF' or p_date_cd = 'AFDCSPPY'
     or p_date_cd  = 'LAFDFPPSY' or p_date_cd = 'AFDFPPSY' or p_date_cd = 'ALDCPPSY'
     or p_date_cd = 'LALDCPPSY'  or p_date_cd = 'ALDPPPSY' or p_date_cd = 'LALDPPPSY'
     then

  --  hr_utility.set_location('Entering '||p_date_cd,22);

    if l_lf_evt_ocrd_dt is null then
       l_lf_evt_ocrd_dt := get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    end if;

    if p_date_cd  = 'LFDPPSYCF' or p_date_cd = 'LAFDFPPSY'  or
       p_date_cd = 'LALDCPPSY' or p_date_cd = 'LALDPPPSY' then
       -- Use later of event or recorded date
       l_recorded_date := get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       if l_lf_evt_ocrd_dt < l_recorded_date then
          l_lf_evt_ocrd_dt := l_recorded_date;
       end if;
    end if;

    get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;

    l_months := round(months_between(l_end_date,l_start_date)/2);
    l_date := add_months(l_start_date,l_months);  -- half year date.

    --
    -- First Day of Semi (or Half) Years:
    --
    if p_date_cd = 'FDSPPYCF' or p_date_cd = 'LFDPPSYCF' then
       --First Day of Half year On or After Event
       if l_lf_evt_ocrd_dt = l_start_date then
          p_returned_date := l_start_date;
       elsif l_lf_evt_ocrd_dt <= l_date then
          p_returned_date := l_date;
       else
          p_returned_date := l_end_date+1;
       end if;
    elsif p_date_cd = 'LAFDFPPSY' or p_date_cd = 'AFDFPPSY' then
       -- First day of following program or plan semi year
       if l_lf_evt_ocrd_dt < l_date then
          p_returned_date := l_date;
       else
          p_returned_date := l_end_date+1;
       end if;
    elsif p_date_cd = 'AFDCSPPY' then
       -- First day of current program or plan semi year
       if l_lf_evt_ocrd_dt < l_date then
          p_returned_date := l_start_date;
       else
          p_returned_date := l_date;
       end if;
    --
    -- Last Day of Semi (or Half) Years:
    --
    elsif p_date_cd = 'ALDCPPSY' or p_date_cd = 'LALDCPPSY' then
       -- Last day of current program or plan semi year
       if l_lf_evt_ocrd_dt < l_date then
          p_returned_date := l_date -1;
       else
          p_returned_date := l_end_date;
       end if;
    elsif p_date_cd = 'ALDPPPSY' or p_date_cd = 'LALDPPPSY' then
        -- Last day of previous program or plan semi year
       if l_lf_evt_ocrd_dt < l_date then
          p_returned_date := l_start_date -1;
       else
          p_returned_date := l_date;
       end if;

    end if;

  -- ODCED - Dependent Coverage End
  elsif p_date_cd  = 'ODCED'  then

  --  hr_utility.set_location('Entering ODCED',10);

    if l_lf_evt_ocrd_dt is null then

       l_lf_evt_ocrd_dt := get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);


    end if;

    open c_elig_dpnt_dts;
    fetch c_elig_dpnt_dts into l_start_date,
                               l_end_date;

    close c_elig_dpnt_dts;

    p_returned_date:= l_end_date;

  -- ODCSD - Dependent Coverage End

  elsif p_date_cd  = 'ODCSD'  then

  --  hr_utility.set_location('Entering ODCSD',10);

    if l_lf_evt_ocrd_dt is null then

       l_lf_evt_ocrd_dt := get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    end if;

    open c_elig_dpnt_dts;
    fetch c_elig_dpnt_dts into l_start_date,
                               l_end_date;

    close c_elig_dpnt_dts;

    p_returned_date:= l_start_date;

  -- AFDECY - First of Calendar year

  elsif p_date_cd  = 'AFDECY'  then

  --  hr_utility.set_location('Entering AFDECY',10);

    if l_lf_evt_ocrd_dt is null then

       l_lf_evt_ocrd_dt := get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    end if;

    p_returned_date:= trunc(l_lf_evt_ocrd_dt,'YYYY');

  -- 30DANED - 30 Days After Notice to Enroll

  elsif p_date_cd  = '30DANED'  then

  --  hr_utility.set_location('Entering 30DANED',10);

    l_recorded_date := get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    p_returned_date := l_recorded_date + 30;

  -- AFDCMFDFFNM - First of Month,( if From Day(DOB) is First, First of Next Month )
  -- Example of the functionality
  --Case DOB 08/03/1935 , Event 08/03/2000 , return date should be 08/01/2000
  --Case DOB 08/01/1935 , Event 08/03/2000 , return date should be 09/01/2000

  elsif p_date_cd = 'AFDCMFDFFNM' then

  --  hr_utility.set_location('Entering AFDCMFDFFNM',10);

    if l_lf_evt_ocrd_dt is null then

       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);


    end if;

    open c_birth_date;
    fetch c_birth_date into l_start_date;
    close c_birth_date;
    --Bug 1802578
    /*

    l_date := last_day(add_months(l_event_date,-1))+1;

    if l_date = l_start_date then

       p_returned_date := add_months(l_date,1);

    else

       p_returned_date := l_date;

    end if;
    */
    declare
      l_day   number := null ;
    begin
      --
      l_day := to_number(to_char(l_start_date, 'DD')) ;
      if l_day = 1 then
        --
        p_returned_date := last_day(l_event_date)+1 ;
        --
      else
        --
        p_returned_date := last_day(add_months(l_event_date,-1))+1;
        --
      end if;
      --
    end ;
      --
  --
  -- DOD - Date of Determination
  --
  elsif p_date_cd = 'DOD' then
  --
  --  hr_utility.set_location('Entering DOD',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       p_returned_date:= p_effective_date;
    --
    else
    --
       p_returned_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
  --
  -- DODM1 - Date of Determination Minus 1 day
  --
  elsif p_date_cd = 'DODM1' then
  --
  --  hr_utility.set_location('Entering DODM1',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       p_returned_date:= p_effective_date - 1;
    --
    else
    --
       p_returned_date:= l_lf_evt_ocrd_dt - 1;
    --
    end if;
    --
  --
  -- FDLMEPPYCF - First Day of Last Month in Event Program or Plan Year
  --              Concurrent with or Following
  --
  elsif p_date_cd  = 'FDLMEPPYCF' then
  --
  --  hr_utility.set_location('Entering FDLMEPPYCF',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_lf_evt_ocrd_dt:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    end if;
    --
    get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;

    if l_lf_evt_ocrd_dt = last_day(add_months(l_end_date,-1))+1 then
    --
       p_returned_date := last_day(add_months(l_end_date,-1))+1;
    --
    else
    --
       get_next_plan_year
                 (p_effective_date => p_effective_date
                 ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
                 ,p_pl_id          => l_pl_id
                 ,p_pgm_id         => l_pgm_id
                 ,p_oipl_id        => l_oipl_id
                 ,p_date_cd        => p_date_cd
                 ,p_comp_obj_mode  => p_comp_obj_mode
                 ,p_start_date     => l_next_popl_yr_strt
                 ,p_end_date       => l_next_popl_yr_end) ;
       --
       p_returned_date := last_day(add_months(l_end_date,-1))+1;
    --
    end if;
    --
  --
  -- ALDPPPY - Last Day of previous Program or Plan Year
  --
  elsif p_date_cd  = 'ALDPPPY' then
  --
  --  hr_utility.set_location('Entering ALDPPPY',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_lf_evt_ocrd_dt:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    end if;
    --
    get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;

    p_returned_date := l_start_date-1;
    --
  --
  -- ALDLPPEPPY - Last Day Last Pay period of Event Program or plan Year
  --
  elsif p_date_cd  = 'ALDLPPEPPY' then
    --
  --  hr_utility.set_location('Entering ALDLPPEPPY',10);
    --
    if l_lf_evt_ocrd_dt is null then

       l_lf_evt_ocrd_dt:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);


    end if;
    --
    get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;
    --
    open c_pay_period_for_date(l_end_date);
    fetch c_pay_period_for_date into
          l_start_date,
          l_end_date;
    --
    if c_pay_period_for_date%notfound then
    --  hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',95);
      fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.set_token('PERSON_ID',l_person_id);
      fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
      fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
      fnd_message.raise_error;
    --
    end if;
    --
    p_returned_date:=l_end_date;
    --
    close c_pay_period_for_date;
  --
  -- FDLPPEPPY - First Day Last Pay period of Event Program or plan Year
  --
  elsif p_date_cd  = 'FDLPPEPPY' then
    --
  --  hr_utility.set_location('Entering FDLPPEPPY',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_lf_evt_ocrd_dt:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    end if;
    --
    get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;
    --
    open c_pay_period_for_date(l_end_date);
    fetch c_pay_period_for_date into
          l_start_date,
          l_end_date;
    --
    if c_pay_period_for_date%notfound then
    --  hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',100);
      fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.set_token('PERSON_ID',l_person_id);
      fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
      fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
      fnd_message.raise_error;
    end if;
    --
    p_returned_date:=l_start_date;
    --
    close c_pay_period_for_date;
    --
  --
  -- FDLPPEPPYCF - First Day Last Pay period in Year on or after event
  --
  elsif p_date_cd  = 'FDLPPEPPYCF' then
    --
  --  hr_utility.set_location('Entering FDLPPEPPYCF',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_lf_evt_ocrd_dt:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    end if;
    --
    get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;
    --
    open c_pay_period_for_date(l_end_date);
    fetch c_pay_period_for_date into
          l_start_date,
          l_end_date;
    --
    if c_pay_period_for_date%notfound then
    --  hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',105);
      fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.set_token('PERSON_ID',l_person_id);
      fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
      fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
      fnd_message.raise_error;
    end if;
    --
    p_returned_date:=l_start_date;
    --
    close c_pay_period_for_date;
  --
  -- ODBED - One day before Event Date
  --
  elsif p_date_cd =  'ODBED' then
    --
  --  hr_utility.set_location('Entering ODBED WODBED OR WEM',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    p_returned_date:=l_event_date-1;
    --
  --
  -- WEM   - 1 Prior
  --
  elsif p_date_cd = 'WEM' then
    --
    if g_debug then
      hr_utility.set_location('Entering WEM',10);
    end if;
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    p_returned_date:=nvl(p_start_date,l_event_date -1 ) ;
    --
  -- WODBED - 1 Prior or One day before event
  --
  elsif p_date_cd =  'WODBED' then
    --
    if g_debug then
      hr_utility.set_location('Entering WODBED',10);
    end if;
    --
      --
      if l_lf_evt_ocrd_dt is null then
      --
        l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
      --
      else
      --
        l_event_date:= l_lf_evt_ocrd_dt;
      --
      end if;
      --
      p_returned_date:=l_event_date-1;
      --
  -- AFDCM - First day of Current Month
  --
  elsif p_date_cd = 'AFDCM' then
  --
  --  hr_utility.set_location('Entering AFDCM',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    l_date := add_months(l_event_date,-1);
    --
    p_returned_date := last_day(l_date)+1;
    --
  --
  -- ALDCM - Last day of Current Month
  --
  elsif p_date_cd = 'ALDCM'  then
  --
    if g_debug then
      hr_utility.set_location('Entering ALDCM',10);
    end if;
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    p_returned_date := last_day(l_event_date);
  --
  -- WALDCM - 1 Prior or Month End
  --
  elsif p_date_cd = 'WALDCM' then
  --
    if g_debug then
      hr_utility.set_location('Entering WALDCM',10);
    end if;
    --
      if l_lf_evt_ocrd_dt is null then
      --
        l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
      --
      else
        --
        l_event_date:= l_lf_evt_ocrd_dt;
        --
      end if;
      --
      p_returned_date := last_day(l_event_date);
    --
    --
  -- ALDFM - Last day of Following Month
  --
  elsif p_date_cd = 'ALDFM' then
  --
  --  hr_utility.set_location('Entering ALDFM',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_lf_evt_ocrd_dt := get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    end if;
    --
    p_returned_date := last_day(add_months(l_lf_evt_ocrd_dt,1));
    --
  --
  -- AEOT - As of End of Time
  --
  elsif p_date_cd = 'AEOT' then
  --
  --  hr_utility.set_location('Entering AEOT',10);
    --
    p_returned_date := to_date('31-12-4712','DD-MM-YYYY');
  --
  -- A30DFPSD - As of 30 days from the participation start date
  --
  elsif p_date_cd = 'A30DFPSD' then
  --
  --  hr_utility.set_location('Entering A30DFPSD',10);
    --
    p_returned_date := p_start_date+30;
  --
  -- A45DFPSD - As of 45 days from the participation start date
  --
  elsif p_date_cd = 'A45DFPSD' then
  --
  --  hr_utility.set_location('Entering A45DFPSD',10);
    --
    p_returned_date := p_start_date+45;
  --
  -- A60DFPSD - As of 60 days from the participation start date
  --
  elsif p_date_cd = 'A60DFPSD' then
  --
  --  hr_utility.set_location('Entering A60DFPSD',10);
    --
    p_returned_date := p_start_date+60;
  --
  -- A12MFPSD - As of 12 months from the participation start date
  --
  elsif p_date_cd = 'A12MFPSD' then
  --
  --  hr_utility.set_location('Entering A12MFPSD',10);
    --
    p_returned_date := add_months(p_start_date,12);
  --
  -- A18MFPSD - As of 18 months from the participation start date
  --
  elsif p_date_cd = 'A18MFPSD' then
  --
  --  hr_utility.set_location('Entering A18MFPSD',10);
    --
    p_returned_date := add_months(p_start_date,18);
  --
  -- A1MFPSD - As of 1 months from the participation start date
  --
  elsif p_date_cd = 'A1MFPSD' then
  --
  --  hr_utility.set_location('Entering A1MFPSD',10);
    --
    p_returned_date := add_months(p_start_date,1);
  --
  -- A29MFPSD - As of 29 months from the participation start date
  --
  elsif p_date_cd = 'A29MFPSD' then
  --
  --  hr_utility.set_location('Entering A29MFPSD',10);
    --
    p_returned_date := add_months(p_start_date,29);
  --
  -- A36MFPSD - As of 36 months from the participation start date
  --
  elsif p_date_cd = 'A36MFPSD' then
  --
  --  hr_utility.set_location('Entering A36MFPSD',10);
    --
    p_returned_date := add_months(p_start_date,36);
  --
  -- As of First Day of Following Month
  --
  elsif p_date_cd = 'AFDFM' then
  --
  --  hr_utility.set_location('Entering AFDFM',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    p_returned_date := last_day(l_event_date)+1;
  --
  -- As of First Day of Following Month after 15 days
  --
  elsif p_date_cd = 'AFDFM15' then
  --
  --  hr_utility.set_location('Entering AFDFM15',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    p_returned_date := last_day(l_event_date+15)+1;
  --
  -- ALDCPPY - Last day of current program or plan year
  --
  elsif p_date_cd  = 'ALDCPPY' then
    --
  --  hr_utility.set_location('Entering ALDCPPY',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_lf_evt_ocrd_dt := get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    end if;
    --
    get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;
    --
    p_returned_date :=l_end_date;
  --

  -- WALDCPPY - 1 Prior or Year End
  --
  elsif  p_date_cd = 'WALDCPPY' then
    --
    if g_debug then
      hr_utility.set_location('Entering ALDCPPY',10);
    end if;
    --
      --
      if l_lf_evt_ocrd_dt is null then
      --
        l_lf_evt_ocrd_dt := get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
      --
      end if;
      --
      get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;
      --
      p_returned_date :=l_end_date;
      --
  --
  -- FDLMPPY - First Day Last Month of current Program or Pl Year
  --
  elsif p_date_cd  = 'FDLMPPY' then
    --
  --  hr_utility.set_location('Entering FDLMPPY',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_lf_evt_ocrd_dt := get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    end if;
    --
    get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;
    --
    l_date := add_months(l_end_date,-1);
    p_returned_date := last_day(l_date)+1;
  --
  -- AFDCPPY - First day of current program or plan year
  --
  elsif p_date_cd  = 'AFDCPPY' then
    --
  --  hr_utility.set_location('Entering AFDCPPY',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_lf_evt_ocrd_dt := get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    end if;
    --
    get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;
    --
    p_returned_date :=l_start_date;

  --
  -- AFDFPPY - First day of following program or plan year
  --
  elsif p_date_cd = 'AFDFPPY' then
    --
  --  hr_utility.set_location('Entering AFDFPPY',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_lf_evt_ocrd_dt:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    --
    end if;
    --
    get_next_plan_year
                 (p_effective_date => p_effective_date
                 ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
                 ,p_pl_id          => l_pl_id
                 ,p_pgm_id         => l_pgm_id
                 ,p_oipl_id        => l_oipl_id
                 ,p_date_cd        => p_date_cd
                 ,p_comp_obj_mode  => p_comp_obj_mode
                 ,p_start_date     => l_next_popl_yr_strt
                 ,p_end_date       => l_next_popl_yr_end) ;
    --
    p_returned_date :=l_next_popl_yr_strt;
  --
  -- AFDCPP - First day of current pay period
  --
  elsif p_date_cd = 'AFDCPP' then
    --
  --  hr_utility.set_location('Entering AFDCPP',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_lf_evt_ocrd_dt := get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    end if;
    --
    open c_pay_period;
      fetch c_pay_period into l_pay_period;
    --
    if c_pay_period%notfound then
    --
      close c_pay_period;
    --  hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',110);
      fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.set_token('PERSON_ID',l_person_id);
      fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
      fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
      fnd_message.raise_error;
    --
    end if;
    --
    p_returned_date := l_pay_period.start_date;
    --
    close c_pay_period ;
  --
  -- ALDCPP - Last day of current pay period
  --
  elsif p_date_cd = 'ALDCPP' then
    --
    if g_debug then
      hr_utility.set_location('Entering ALDCPP',10);
    end if;
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_lf_evt_ocrd_dt := get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    end if;
    --
    open c_pay_period(l_assignment_id); ----Bug 8394662
    fetch c_pay_period into l_pay_period;
    --
    if c_pay_period%notfound then
      close c_pay_period;
    --  hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',115);
      fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.set_token('PERSON_ID',l_person_id);
      fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
      fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
      fnd_message.raise_error;
    end if;
    p_returned_date := l_pay_period.end_date;
    close c_pay_period ;
  --
  -- WALDCPP - 1 Prior or pay period end
  --
  elsif p_date_cd = 'WALDCPP' then
    --
    if g_debug then
      hr_utility.set_location('Entering WALDCPP',10);
    end if;
    --
      --
      if l_lf_evt_ocrd_dt is null then
      --
        l_lf_evt_ocrd_dt := get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
      --
      end if;
      --
      open c_pay_period;
      fetch c_pay_period into l_pay_period;
      --
      if c_pay_period%notfound then
      close c_pay_period;
        if g_debug then
          hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',115);
        end if;
        fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
        fnd_message.set_token('DATE_CODE',p_date_cd);
        fnd_message.set_token('L_PROC',l_proc);
        fnd_message.set_token('PERSON_ID',l_person_id);
        fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
        fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
        fnd_message.raise_error;
      end if;
      --
      p_returned_date := l_pay_period.end_date;
      close c_pay_period ;
    --
  --
  -- AFDFPP - First day of following pay period
  --
  elsif p_date_cd = 'AFDFPP' then
    --
  --  hr_utility.set_location('Entering AFDFPP',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_lf_evt_ocrd_dt := get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    end if;
    --
    open c_next_pay_period(nvl(l_lf_evt_ocrd_dt,p_effective_date),l_assignment_id); ------Bug 8394662
    fetch c_next_pay_period into l_next_pay_period;
    --
    if c_next_pay_period%notfound then
      close c_next_pay_period;
    --  hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',120);
      fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('PERSON_ID',l_person_id);
      fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
      fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
      fnd_message.raise_error;
    end if;
    close c_next_pay_period;

    p_returned_date := l_next_pay_period.start_date;
  --
  -- APOCT1 - Prior October 1st
  --
  elsif p_date_cd = 'APOCT1' then
    -- tilak
    --
    --  hr_utility.set_location('Entering APOCT1',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_lf_evt_ocrd_dt := get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    end if;
    --
    --- whne the le_evt_ocrd_dt is oct 1st it should return previos year october first
    --- so when the month is calculated the date is dedcited with 1
    l_date   :=  l_lf_evt_ocrd_dt-1 ;
    l_months := to_number(to_char(l_date,'MM'))+3;
    --
    -- subtract 12 if it's oct nov or dec so we dont go farther than 1 yr back.
    --
    if l_months > 12 then
      l_months := l_months - 12;
    end if;
    --
    l_date := add_months(l_date,-l_months);
    --
    -- Set to first of month of October
    --
    p_returned_date := last_day(l_date)+1;
    if g_debug then
      hr_utility.set_location(' APOCT1 date : ' || p_returned_date , 450) ;
    end if;
  -- tilak

  -- OMFED - One Month Afl_event_date p_date_cd  = 'OMFED' then
  --
  elsif p_date_cd = 'OMFED' then
    --
  --  hr_utility.set_location('Entering OMFED',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    p_returned_date := add_months(l_event_date,1);
  --
  -- TMFED - Two Months After Event Date
  --
  elsif p_date_cd  = 'TMFED' then
    --
  --  hr_utility.set_location('Entering TMFED',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    p_returned_date := add_months(l_event_date,2);
  --
  -- 30DFLED - Thirty days from Life Event Date
  --
  elsif p_date_cd = '30DFLED' then
    --
  --  hr_utility.set_location('Entering 30DFLED',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    p_returned_date := l_event_date + 30;
  --
  -- TDBED - Thirty days before event date
  --
  elsif p_date_cd = 'TDBED' then
    --
  --  hr_utility.set_location('Entering TDBED',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    p_returned_date := l_event_date - 30;
  --
  -- LTDBED - Later: Thirty days before event date or notified
  --
  elsif p_date_cd = 'LTDBED' then
    --
  --  hr_utility.set_location('Entering LTDBED',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    l_recorded_date := get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    -- RCHASE Bug Fix, do not subtract 30 days from both.  Evaluate 30 days minus event date
--    if l_recorded_date > l_event_date then
    --
--       p_returned_date := l_recorded_date - 30;
    --
--    else
    --
--       p_returned_date := l_event_date - 30;
    --
--    end if;
    if l_recorded_date > l_event_date-30 then
    --
       p_returned_date := l_recorded_date;
    --
    else
    --
       p_returned_date := l_event_date - 30;
    --
    end if;
  --
  -- SDFED - Sixty days After Event Date
  --
  elsif p_date_cd = 'SDFED' then
    --
  --  hr_utility.set_location('Entering SDFED',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    p_returned_date := l_event_date + 60;
    --
  --
  --
  -- LSDBED - Later: Sixty days before Event Date
  --
  elsif p_date_cd = 'LSDBED' then
    --
  --  hr_utility.set_location('Entering LSDBED',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    -- RCHASE Bug Fix, do not subtract 30 days from both.  Evaluate 30 days minus event date
    --If l_recorded_date > l_event_date then
    --
    --   p_returned_date := l_recorded_date - 60;
    --
    --else
    --
    --   p_returned_date := l_event_date - 60;
    --
    --end if;
    If l_recorded_date > l_event_date-60 then
    --
       p_returned_date := l_recorded_date;
    --
    else
    --
       p_returned_date := l_event_date - 60;
    --
    end if;
  --
  -- TODFED - Thirty-one days After Event Date
  --
  elsif p_date_cd  = 'TODFED' then
    --
  --  hr_utility.set_location('Entering TODFED',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    p_returned_date := l_event_date + 31;
  --
  -- LEPPPED - Later of Enrollment Period End Date and Processing End Date.
  --
  elsif p_date_cd = 'LEPPPED' then
    --
  --  hr_utility.set_location('Entering LEPPPED',10);
    --
    open c_pil_popl;
    fetch c_pil_popl into l_enrt_end_dt, l_procg_end_dt;
    --
    if c_pil_popl%notfound then
      close c_pil_popl;
    --  hr_utility.set_location('BEN_91942_PEL_NOT_FOUND',81);
      fnd_message.set_name('BEN', 'BEN_91942_PEL_NOT_FOUND');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.raise_error;
    end if;
    --
    close c_pil_popl;
    --
    if nvl(l_procg_end_dt,hr_api.g_sot) > nvl(l_enrt_end_dt,hr_api.g_sot) then
      l_enrt_end_dt := l_procg_end_dt;
    end if;
    --
    p_returned_date := l_enrt_end_dt;
  --
  elsif p_date_cd  = '5DBEEPD' then
    --
    -- 5DBEEPD - 5 Days before the end of the enrollment period end date
    --
  --  hr_utility.set_location('Entering 5DBEEPD',10);
    --
    open c_cm_enrt_perd_end_dt;
    fetch c_cm_enrt_perd_end_dt into l_cm_date;
    if c_cm_enrt_perd_end_dt%notfound then
      close c_cm_enrt_perd_end_dt;
    --  hr_utility.set_location('BEN_91942_PEL_NOT_FOUND',86);
      fnd_message.set_name('BEN', 'BEN_91942_PEL_NOT_FOUND');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.raise_error;
    end if;
    --
    close c_cm_enrt_perd_end_dt;
    --
    p_returned_date := l_cm_date - 5;
    --

  elsif p_date_cd  = '10DBEEPD' then
    --
    -- 10DBEEPD - 10 Days before the end of the enrollment period end date
    --
  --  hr_utility.set_location('Entering 10DBEEPD',10);
    --
    open c_cm_enrt_perd_end_dt;
    fetch c_cm_enrt_perd_end_dt into l_cm_date;
    if c_cm_enrt_perd_end_dt%notfound then
      close c_cm_enrt_perd_end_dt;
    --  hr_utility.set_location('BEN_91942_PEL_NOT_FOUND',87);
      fnd_message.set_name('BEN', 'BEN_91942_PEL_NOT_FOUND');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.raise_error;
    end if;
    --
    close c_cm_enrt_perd_end_dt;
    --
    p_returned_date := l_cm_date - 10;
    --
  elsif p_date_cd  = '20DBEEPD' then
    --
    -- 20DBEEPD - 20 Days before the end of the enrollment period end date
    --
  --  hr_utility.set_location('Entering 20DBEEPD',10);
    --
    open c_cm_enrt_perd_end_dt;
    fetch c_cm_enrt_perd_end_dt into l_cm_date;
    if c_cm_enrt_perd_end_dt%notfound then
      close c_cm_enrt_perd_end_dt;
    --  hr_utility.set_location('BEN_91942_PEL_NOT_FOUND',89);
      fnd_message.set_name('BEN', 'BEN_91942_PEL_NOT_FOUND');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.raise_error;
    end if;
    --
    close c_cm_enrt_perd_end_dt;
    --
    p_returned_date := l_cm_date - 20;
    --
  elsif p_date_cd  = '25DBEEPD' then
    --
    -- 25DBEEPD - 25 Days before the end of the enrollment period end date
    --
  --  hr_utility.set_location('Entering 25DBEEPD',10);
    --
    open c_cm_enrt_perd_end_dt;
    fetch c_cm_enrt_perd_end_dt into l_cm_date;
    if c_cm_enrt_perd_end_dt%notfound then
      close c_cm_enrt_perd_end_dt;
    --  hr_utility.set_location('BEN_91942_PEL_NOT_FOUND',90);
      fnd_message.set_name('BEN', 'BEN_91942_PEL_NOT_FOUND');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.raise_error;
    end if;
    --
    close c_cm_enrt_perd_end_dt;
    --
    p_returned_date := l_cm_date - 25;
    --
  elsif p_date_cd  = '30DBEEPD' then
    --
    -- 30DBEEPD - 30 Days before the end of the enrollment period end date
    --
  --  hr_utility.set_location('Entering 30DBEEPD',10);
    --
    open c_cm_enrt_perd_end_dt;
    fetch c_cm_enrt_perd_end_dt into l_cm_date;
    if c_cm_enrt_perd_end_dt%notfound then
      close c_cm_enrt_perd_end_dt;
    --  hr_utility.set_location('BEN_91942_PEL_NOT_FOUND',91);
      fnd_message.set_name('BEN', 'BEN_91942_PEL_NOT_FOUND');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.raise_error;
    end if;
    --
    close c_cm_enrt_perd_end_dt;
    --
    p_returned_date := l_cm_date - 30;
    --

  elsif p_date_cd  = '10DBDAD' then
    --
    -- 10DBDAD - 10 Days before the default applied date
    --
  --  hr_utility.set_location('Entering 10DBDAD',10);
    --
    open c_cm_dflt_asnd_dt;
    fetch c_cm_dflt_asnd_dt into l_cm_date;
    if c_cm_dflt_asnd_dt%notfound then
      close c_cm_dflt_asnd_dt;
    --  hr_utility.set_location('BEN_91942_PEL_NOT_FOUND',92);
      fnd_message.set_name('BEN', 'BEN_91942_PEL_NOT_FOUND');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.raise_error;
    end if;
    --
    close c_cm_dflt_asnd_dt;
    --
    p_returned_date := l_cm_date - 10;
    --
  elsif p_date_cd  = '14DBEPD' then
    --
    -- 14DBEPD - 14 Days before the Eligible to Participate Date
    --
  --  hr_utility.set_location('Entering 14DBEPD',10);
    --
    open c_cm_elig_prtn_strt_dt;
    fetch c_cm_elig_prtn_strt_dt into l_cm_date;
    if c_cm_elig_prtn_strt_dt%notfound then
      close c_cm_elig_prtn_strt_dt;
    --  hr_utility.set_location('BEN_91386_FIRST_INELIG',81);
      fnd_message.set_name('BEN', 'BEN_91386_FIRST_INELIG');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('PERSON_ID',to_char(p_person_id));
      fnd_message.set_token('BG_ID',to_char(p_business_group_id));
      fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
      fnd_message.raise_error;
    end if;
    close c_cm_elig_prtn_strt_dt;
    --
    p_returned_date := l_cm_date - 14;
    --
  elsif p_date_cd  = '14DBIPD' then
    --
    -- 14DBIPD - 14 Days before the Ineligible to Participate Date
    --
    open c_cm_elig_prtn_end_dt;
    fetch c_cm_elig_prtn_end_dt into l_cm_date;
    if c_cm_elig_prtn_end_dt%notfound then
      close c_cm_elig_prtn_end_dt;
    --  hr_utility.set_location('BEN_91386_FIRST_INELIG',93);
      fnd_message.set_name('BEN', 'BEN_91386_FIRST_INELIG');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('PERSON_ID',to_char(p_person_id));
      fnd_message.set_token('BG_ID',to_char(p_business_group_id));
      fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
      fnd_message.raise_error;
    end if;
    close c_cm_elig_prtn_end_dt;
    --
    p_returned_date := l_cm_date  - 14;
  --
  elsif p_date_cd  = '15DBEEPD' then
    --
    -- 15DBEEPD - 15 Days before the end of the enrollment period end date
    --
  --  hr_utility.set_location('Entering 15DBEEPD',10);
    --
    open c_cm_enrt_perd_end_dt;
    fetch c_cm_enrt_perd_end_dt into l_cm_date;
    if c_cm_enrt_perd_end_dt%notfound then
      close c_cm_enrt_perd_end_dt;
    --  hr_utility.set_location('BEN_91942_PEL_NOT_FOUND',88);
      fnd_message.set_name('BEN', 'BEN_91942_PEL_NOT_FOUND');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.raise_error;
    end if;
    --
    close c_cm_enrt_perd_end_dt;
    --
    p_returned_date := l_cm_date - 15;
  elsif p_date_cd  = 'OAED' then
    --
    -- OAED - On the Automatic Enrollment Date.
    --
  --  hr_utility.set_location('Entering OAED',10);
    --
    open c_cm_auto_asnd_dt;
    fetch c_cm_auto_asnd_dt into l_cm_date;
    if c_cm_auto_asnd_dt%notfound then
      close c_cm_auto_asnd_dt;
    --  hr_utility.set_location('BEN_91942_PEL_NOT_FOUND',98);
      fnd_message.set_name('BEN', 'BEN_91942_PEL_NOT_FOUND');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.raise_error;
    end if;
    close c_cm_auto_asnd_dt;
    --
    p_returned_date := l_cm_date;
    --

  elsif p_date_cd  = 'OCSD' or p_date_cd = 'PECSD' then
    --
    -- OCSD - On the Coverage Start Date.
    --
  --  hr_utility.set_location('Entering OCSD',10);
    --
    open c_prtt_enrt_rslt_dts;
    fetch c_prtt_enrt_rslt_dts into l_enrt_cvg_end_dt,
                                    l_enrt_cvg_strt_dt,
                                    l_enrt_eff_strt_date;
    if c_prtt_enrt_rslt_dts%notfound then
        --
        l_enrt_cvg_strt_dt := p_start_date ;
        --
        if g_debug then
          hr_utility.set_location('OCSD Not found ', 19);
        end if;
        --
    end if;
    --
    close c_prtt_enrt_rslt_dts;
    --
    p_returned_date := l_enrt_cvg_strt_dt;
    --
  --
  -- LFDMCF - First of Month on or After Later of Event or Notified
  --
  elsif p_date_cd  = 'LFDMCF' then
    --
  --  hr_utility.set_location('Entering LFDMCF',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_lf_evt_ocrd_dt:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    end if;
    --
    l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    if l_lf_evt_ocrd_dt > l_recorded_date then
    --
       if l_lf_evt_ocrd_dt <> last_day(add_months(l_lf_evt_ocrd_dt,-1))+1 then
       --
         p_returned_date := last_day(l_lf_evt_ocrd_dt)+1;
       --
       else
       --
         p_returned_date := l_lf_evt_ocrd_dt;
       --
       end if;
    --
    else
    --
       if l_recorded_date <> last_day(add_months(l_recorded_date,-1))+1 then
       --
         p_returned_date := last_day(l_recorded_date)+1;
       --
       else
       --
         p_returned_date := l_recorded_date;
       --
       end if;
    --
    end if;
    --
  --
  -- LFDPPCF - First of Pay Period on or After Later of Event or Notified
  --
  elsif p_date_cd  = 'LFDPPCF' then
    --
  --  hr_utility.set_location('Entering LFDPPCF',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_lf_evt_ocrd_dt:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    end if;
    --
    l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --

    if l_lf_evt_ocrd_dt > l_recorded_date  then

       open c_pay_period_for_date(l_lf_evt_ocrd_dt);
       fetch c_pay_period_for_date into
          l_start_date,
          l_end_date;
       --
       if c_pay_period_for_date%notfound then
       --
         close c_pay_period_for_date;
       --  hr_utility.set_location('BEN_92380_CANNOT_CALC_LFDPPCF',96);
       --  hr_utility.set_location('l_lf_evt_ocrd_dt'||to_char(l_lf_evt_ocrd_dt),96);
         fnd_message.set_name('BEN','BEN_92380_CANNOT_CALC_LFDPPCF');
         fnd_message.set_token('L_PROC',l_proc);
         fnd_message.set_token('PERSON_ID',l_person_id);
         fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
         fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
         fnd_message.set_token('LF_EVT_OCRD_DT',l_lf_evt_ocrd_dt);
         fnd_message.raise_error;
       --
       end if;
       --
       close c_pay_period_for_date;
       --
       if l_lf_evt_ocrd_dt =  l_start_date then
       --
          p_returned_date := l_start_date;
       --
       else
       --
          open c_next_pay_period(nvl(l_lf_evt_ocrd_dt,p_effective_date));
          fetch c_next_pay_period into l_next_pay_period;
          --
          if c_next_pay_period%notfound then
            close c_next_pay_period;
          --  hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',125);
            fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
            fnd_message.set_token('DATE_CODE',p_date_cd);
            fnd_message.set_token('PERSON_ID',l_person_id);
            fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
            fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
            fnd_message.raise_error;
          end if;
          --
          p_returned_date := l_next_pay_period.start_date;
          --
          close c_next_pay_period;
       --
       end if;
    --
    else
    --
       open c_pay_period_for_date(l_recorded_date);
       fetch c_pay_period_for_date into
          l_start_date,
          l_end_date;
       --
       if c_pay_period_for_date%notfound then
       --
         close c_pay_period_for_date;
       --  hr_utility.set_location('BEN_92380_CANNOT_CALC_LFDPPCF',97);
       --  hr_utility.set_location('l_recorded_date'||to_char(l_recorded_date),97);
         fnd_message.set_name('BEN','BEN_92380_CANNOT_CALC_LFDPPCF');
         fnd_message.set_token('L_PROC',l_proc);
         fnd_message.set_token('PERSON_ID',l_person_id);
         fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
         fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
         fnd_message.set_token('LF_EVT_OCRD_DT',l_lf_evt_ocrd_dt);
         fnd_message.raise_error;
       --
       end if;
       --
       close c_pay_period_for_date;
       --
       if l_recorded_date =  l_start_date then
       --
          p_returned_date := l_start_date;
       --
       else
       --
          l_lf_evt_ocrd_dt := l_recorded_date;
          --
          open c_next_pay_period(nvl(l_lf_evt_ocrd_dt,p_effective_date));
          fetch c_next_pay_period into l_next_pay_period;
          --
          if c_next_pay_period%notfound then
            close c_next_pay_period;
          --  hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',130);
            fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
            fnd_message.set_token('DATE_CODE',p_date_cd);
            fnd_message.set_token('PERSON_ID',l_person_id);
            fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
            fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
            fnd_message.raise_error;
          end if;
          --
          p_returned_date := l_next_pay_period.start_date;
          --
          close c_next_pay_period;
       --
       end if;
    --
    end if;
  --
  -- LELD - Latest of Elections, Event or Notified
  --
  elsif p_date_cd  = 'LELD' then
    --
  --  hr_utility.set_location('Entering LELD',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_lf_evt_ocrd_dt:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    end if;
    --
    l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    open c_prtt_enrt_rslt_dts;
    fetch c_prtt_enrt_rslt_dts into l_enrt_cvg_end_dt,
                                    l_enrt_cvg_strt_dt,
                                    l_enrt_eff_strt_date;
    --
    if l_enrt_eff_strt_date is null then
      l_enrt_eff_strt_date:=p_effective_date;
    end if;
    --
    l_cm_date:=l_enrt_eff_strt_date;
    --
    close c_prtt_enrt_rslt_dts;

    if l_lf_evt_ocrd_dt > l_recorded_date  then
    --
       if l_lf_evt_ocrd_dt > l_cm_date then
       --
         p_returned_date := l_lf_evt_ocrd_dt;
       --
       else
         -- also for null condition
         p_returned_date:=l_cm_date;
       end if;
    --
    elsif l_recorded_date > l_cm_date then
    --
       p_returned_date := l_recorded_date;
    --
    else
    --
       p_returned_date := l_cm_date;
    --
    end if;
    --
  --
  -- LELDED - Later of Elections or Event
  --
  elsif p_date_cd  = 'LELDED' then
    --
  --  hr_utility.set_location('Entering LELDED',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_lf_evt_ocrd_dt:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    end if;
    --
    open c_prtt_enrt_rslt_dts;
    fetch c_prtt_enrt_rslt_dts into l_enrt_cvg_end_dt,
                                    l_enrt_cvg_strt_dt,
                                    l_enrt_eff_strt_date;
    --
    if l_enrt_eff_strt_date is null then
      l_enrt_eff_strt_date:=p_effective_date;
    end if;
    --
    l_cm_date:=l_enrt_eff_strt_date;
    --
    close c_prtt_enrt_rslt_dts;
    --
    if l_lf_evt_ocrd_dt > l_cm_date then
    --
      p_returned_date := l_lf_evt_ocrd_dt;
    --
    else
    --
      p_returned_date := l_cm_date;
    --
    end if;
    --
  --
  -- ODEWM - On the Day Elections Were Made.
  --
  elsif p_date_cd  = 'ODEWM' then
    --
    -- should return null if result with current pil
    -- is not found, i.e. in benmngle.  gets date at
    -- time of enrollment.
    --
  --  hr_utility.set_location('Entering ODEWM',10);
    --
    open c_prtt_enrt_rslt_dts;
    fetch c_prtt_enrt_rslt_dts into l_enrt_cvg_end_dt,
                                    l_enrt_cvg_strt_dt,
                                    l_enrt_eff_strt_date;
    --
    close c_prtt_enrt_rslt_dts;
    --
    if l_enrt_eff_strt_date is null then
      l_enrt_eff_strt_date:=p_effective_date;
    end if;
    --
    p_returned_date := l_enrt_eff_strt_date;
    --
    --
    -- AFDELD First of Month After Elections Made
    --
    elsif p_date_cd  = 'AFDELD' then
    --
      -- should return null if result with current pil
      -- is not found, i.e. in benmngle.  gets date at
      -- time of enrollment.
      --
      hr_utility.set_location('Entering AFDELD',10);
    --
    open c_prtt_enrt_rslt_dts;
    fetch c_prtt_enrt_rslt_dts into l_enrt_cvg_end_dt,
                                    l_enrt_cvg_strt_dt,
                                    l_enrt_eff_strt_date;
    --
    close c_prtt_enrt_rslt_dts;
    hr_utility.set_location('Entering AFDELD ' || l_enrt_eff_strt_date ,10);
    --
    -- when the first time cvg calcualted there may not be a result
    if l_enrt_eff_strt_date is null then
       l_enrt_eff_strt_date :=p_effective_date;
    end if;
    p_returned_date := last_day(l_enrt_eff_strt_date) + 1 ;

    hr_utility.set_location('AFDELD ' ||  p_returned_date ,10);
    --
    --
    -- FDMELD First of Month on or After Elections Made
    elsif p_date_cd  = 'FDMELD' then
    --
      -- should return null if result with current pil
      -- is not found, i.e. in benmngle.  gets date at
      -- time of enrollment.
      --
      hr_utility.set_location('Entering FDMELD',10);
    --
    open c_prtt_enrt_rslt_dts;
    fetch c_prtt_enrt_rslt_dts into l_enrt_cvg_end_dt,
                                    l_enrt_cvg_strt_dt,
                                    l_enrt_eff_strt_date;
    --
    close c_prtt_enrt_rslt_dts;
    --
    if l_enrt_eff_strt_date is null then
      l_enrt_eff_strt_date :=p_effective_date;
    end if ;
    p_returned_date := trunc( add_months( (l_enrt_eff_strt_date -1 ) ,1) , 'MM') ;


  elsif p_date_cd  = 'ODD' then
    --
    -- ODD - On the De-enrollment Date.
    --
  --  hr_utility.set_location('Entering ODD',10);
    --
    p_returned_date := p_effective_date;
    --
  elsif p_date_cd  = 'ODAD' then
    --
    -- ODAD - On the Default Applied Date.
    --
  --  hr_utility.set_location('Entering ODAD',10);
    --
    open c_cm_dflt_asnd_dt;
    fetch c_cm_dflt_asnd_dt into l_cm_date;
    if c_cm_dflt_asnd_dt%notfound then
      close c_cm_dflt_asnd_dt;
    --  hr_utility.set_location('BEN_91942_PEL_NOT_FOUND',96);
      fnd_message.set_name('BEN', 'BEN_91942_PEL_NOT_FOUND');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.raise_error;
    end if;
    close c_cm_dflt_asnd_dt;
    --
    p_returned_date := l_cm_date;
    --
  elsif p_date_cd  = 'OEPD' then
    --
    -- OEPD - On the Eligible to Participate Date.
    --
  --  hr_utility.set_location('Entering OEPD',10);
    --
    open c_cm_elig_prtn_strt_dt;
    fetch c_cm_elig_prtn_strt_dt into l_cm_date;
    if c_cm_elig_prtn_strt_dt%notfound then
      close c_cm_elig_prtn_strt_dt;
    --  hr_utility.set_location('BEN_92381_ELIG_PER_NOT_FOUND',96);
      fnd_message.set_name('BEN', 'BEN_92381_ELIG_PER_NOT_FOUND');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('PERSON_ID',to_char(p_person_id));
      fnd_message.set_token('BG_ID',to_char(p_business_group_id));
      fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
      fnd_message.raise_error;
    end if;
    close c_cm_elig_prtn_strt_dt;
    --
    p_returned_date := l_cm_date;
    --
  elsif p_date_cd  = 'OIPD' then
    --
    -- OIPD - On the Ineligible to Participate Date.
    --
  --  hr_utility.set_location('Entering OIPD',10);
    --
    open c_cm_elig_prtn_end_dt;
    fetch c_cm_elig_prtn_end_dt into l_cm_date;
    if c_cm_elig_prtn_end_dt%notfound then
      close c_cm_elig_prtn_end_dt;
    --  hr_utility.set_location('BEN_92381_ELIG_PER_NOT_FOUND',98);
      fnd_message.set_name('BEN', 'BEN_92381_ELIG_PER_NOT_FOUND');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('PERSON_ID',to_char(p_person_id));
      fnd_message.set_token('BG_ID',to_char(p_business_group_id));
      fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
      fnd_message.raise_error;
    end if;
    close c_cm_elig_prtn_end_dt;
    --
    p_returned_date := l_cm_date;
    --
  elsif p_date_cd  = 'OLDEP' then
    --
    -- OLDEP - On the last day of the enrollment period.
    --
  --  hr_utility.set_location('Entering OLDEP',10);
    --
    open c_cm_enrt_perd_end_dt;
    fetch c_cm_enrt_perd_end_dt into l_cm_date;
    if c_cm_enrt_perd_end_dt%notfound then
      close c_cm_enrt_perd_end_dt;
      fnd_message.set_name('BEN', 'BEN_91942_PEL_NOT_FOUND');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('L_PROC',l_proc);
      fnd_message.raise_error;
    end if;
    close c_cm_enrt_perd_end_dt;
    --
    p_returned_date := l_cm_date;
    --
  elsif p_date_cd  = 'OED' or p_date_cd = 'ENTRBL' or p_date_cd = 'WAENT' or p_date_cd = 'ENTRBLFD' then -- For ICD

    --6823087 -- For CWB (mode = W), if the rate start date code is 'Enterable'
              -- we should retrun the rate start date as null

    if p_date_cd = 'ENTRBL' or p_date_cd = 'WAENT' then
      ben_env_object.get(p_rec => l_env);

        if nvl(l_env.mode_cd,'~') = 'W' then
          p_returned_date := null;
        else  -- not CWB
          p_returned_date := p_effective_date;
        end if;

    else   -- OED
    --
    -- OED - On the effective date.
    --
  --  hr_utility.set_location('Entering OED',10);
    --
    p_returned_date := p_effective_date;
  --
  -- ODBEFFD - One day before the effective date.
  --

    end if;

    --6823087

  elsif p_date_cd  = 'ODBEFFD' then
    --
  --  hr_utility.set_location('Entering ODBEFFD',10);
    --
    p_returned_date := p_effective_date-1;
    --
  --Bug 6212793
  elsif p_date_cd  = '10DFED' then
      p_returned_date := p_effective_date+10;
  elsif p_date_cd  = '20DFED' then
      p_returned_date := p_effective_date+20;
  elsif p_date_cd  = '30DFED' then
      p_returned_date := p_effective_date+30;
  ----Bug --Bug 6212793
  --
  -- FDPPYCF - First Day of Program or Plan Year Concurrent with or Following
  --
  elsif p_date_cd  = 'FDPPYCF' then
  --
  --  hr_utility.set_location('Entering FDPPYCF',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_lf_evt_ocrd_dt := get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    end if;
    --
    get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;
    --
    if l_start_date = nvl(l_lf_evt_ocrd_dt,p_effective_date) then
    --
       p_returned_date :=l_start_date;
    --
    else
    --
      get_next_plan_year
                 (p_effective_date => p_effective_date
                 ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
                 ,p_pl_id          => l_pl_id
                 ,p_pgm_id         => l_pgm_id
                 ,p_oipl_id        => l_oipl_id
                 ,p_date_cd        => p_date_cd
                 ,p_comp_obj_mode  => p_comp_obj_mode
                 ,p_start_date     => l_next_popl_yr_strt
                 ,p_end_date       => l_next_popl_yr_end) ;
       --
       p_returned_date :=l_next_popl_yr_strt;
    --
    end if;
  --
  -- FDMCF - First Day of Month concurrent with or following
  --
  elsif p_date_cd  = 'FDMCF' then
    --
  --  hr_utility.set_location('Entering FDMCF',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    l_date := add_months(l_event_date,-1);

    if l_event_date = last_day(l_date)+1 then
    --
       p_returned_date := last_day(l_date)+1;
    --
    else
    --
       p_returned_date := last_day(l_event_date)+1;

    --
    end if;
  --
  -- FDPPCF - First day of pay period concurrent with or following
  --
  elsif p_date_cd = 'FDPPCF' then
    --
  --  hr_utility.set_location('Entering FDPPCF',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       l_lf_evt_ocrd_dt := l_event_date; --9312164
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    open c_pay_period;
    fetch c_pay_period into l_pay_period;
    if c_pay_period%notfound then
      close c_pay_period;
    --  hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',135);
      fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('PERSON_ID',l_person_id);
      fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
      fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
      fnd_message.raise_error;
    end if;
    --
    close c_pay_period ;
    --
    if l_event_date =  l_pay_period.start_date then
    --
       p_returned_date := l_pay_period.start_date;
    --
    else
    --
       open c_next_pay_period(nvl(l_lf_evt_ocrd_dt,p_effective_date));
       fetch c_next_pay_period into l_next_pay_period;
       --
       if c_next_pay_period%notfound then
         close c_next_pay_period;
       --  hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',140);
         fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
         fnd_message.set_token('DATE_CODE',p_date_cd);
         fnd_message.set_token('PERSON_ID',l_person_id);
         fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
         fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
         fnd_message.raise_error;
       end if;
       --
       p_returned_date := l_next_pay_period.start_date;
       --
       close c_next_pay_period;
    --
    end if;
  --
  -- RL - Rule
  --
  elsif p_date_cd  = 'RL' then
    --
  --  hr_utility.set_location('Entering RL',10);
    --
    open c_asg;
    fetch c_asg into l_asg; --if notfound, don't care, will pass null to formula
    close c_asg;
    --
/* -- 4031733 - Cursor c_state populates l_state variable which is no longer
   -- used in the package. Cursor can be commented

   if p_person_id is not null then
      open c_state;
      fetch c_state into l_state;
      close c_state;

      --if l_state.region_2 is not null then

      --  l_jurisdiction_code :=
      --    pay_mag_utils.lookup_jurisdiction_code
      --      (p_state => l_state.region_2);
      --end if;

   end if;
*/

   if l_oipl_id is not null then
      open c_opt(l_oipl_id);
      fetch c_opt into l_opt;
      close c_opt;
   end if;

   if l_pl_id is not null then
     open c_pl_typ(l_pl_id);
     fetch c_pl_typ into l_pl_typ_id;
     close c_pl_typ;
   end if;

    if g_debug then
      hr_utility.set_location ('ler_id '||to_char(l_ler_id),70);
    end if;
   if l_per_in_ler_id is not null then
     open c_ler;
     fetch c_ler into l_ler_id;
     close c_ler;
   end if;

    if g_debug then
      hr_utility.set_location ('Organization_id 	'||l_asg.organization_id,10);
    end if;
    if g_debug then
      hr_utility.set_location ('assignment_id 	'||l_asg.assignment_id,15);
    end if;
    if g_debug then
      hr_utility.set_location ('Business_group_id '||p_business_group_id,20);
    end if;
    if g_debug then
      hr_utility.set_location ('pgm_id 		'||l_pgm_id,30);
    end if;
    if g_debug then
      hr_utility.set_location ('pl_id 		'||l_pl_id,40);
    end if;
    if g_debug then
      hr_utility.set_location ('pl_typ_id 	'||l_pl_typ_id,50);
    end if;
    if g_debug then
      hr_utility.set_location ('opt_id 		'||l_opt.opt_id,60);
    end if;
    if g_debug then
      hr_utility.set_location ('ler_id 		'||l_ler_id,70);
    end if;
    if g_debug then
      hr_utility.set_location ('p_acty_base_rt_id '||p_acty_base_rt_id,50);
    end if;
    if g_debug then
      hr_utility.set_location ('p_bnfts_bal_id 	'||p_bnfts_bal_id,60);
    end if;
    if g_debug then
      hr_utility.set_location ('jurisdiction_code '||l_jurisdiction_code,70);
    end if;

    -- for all other codes LE date is calcualted when the  LE date is null
    -- this update does that for  formula too
    -- when ever there is a call from ben_newly_ineligible->delete_enrollment->bendetdt.main
    --  LE date is null and effectiv date is  le_date -1

    if p_lf_evt_ocrd_dt is  null then
       l_rl_lf_evt_ocrd_dt :=  get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    else
       l_rl_lf_evt_ocrd_dt := p_lf_evt_ocrd_dt ;
    end if ;

    -- Call formula initialise routine
    -- Added param1 and param1_value parameters to fix bug 1531647

    if g_debug then
      hr_utility.set_location ('p_formula_id	'||p_formula_id,1689);
    end if;

    l_outputs := benutils.formula
      (p_formula_id        => p_formula_id
      ,p_effective_date    => nvl(l_rl_lf_evt_ocrd_dt,p_effective_date)
      ,p_business_group_id => p_business_group_id
      ,p_assignment_id     => l_asg.assignment_id
      ,p_organization_id   => l_asg.organization_id
      ,p_pgm_id            => l_pgm_id
      ,p_pl_id             => l_pl_id
      ,p_pl_typ_id         => l_pl_typ_id
      ,p_opt_id            => l_opt.opt_id
      ,p_ler_id            => l_ler_id
      ,p_acty_base_rt_id   => p_acty_base_rt_id
      ,p_bnfts_bal_id      => p_bnfts_bal_id
      ,p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id
 -- Added two more parameters to fix the Bug 1531647
      ,p_param1            => p_param1
      ,p_param1_value      => p_param1_value
      -- FONM
      ,p_param2             => 'BEN_IV_RT_STRT_DT'
      ,p_param2_value       => fnd_date.date_to_canonical(nvl(p_fonm_rt_strt_dt,ben_manage_life_events.g_fonm_rt_strt_dt))
      ,p_param3             => 'BEN_IV_CVG_STRT_DT'
      ,p_param3_value       => fnd_date.date_to_canonical(nvl(p_fonm_cvg_strt_dt,ben_manage_life_events.g_fonm_cvg_strt_dt))
      ,p_param4             => 'BEN_IV_PERSON_ID'             -- Bug 5331889
      ,p_param4_value       => to_char(p_person_id)
      ,p_jurisdiction_code => l_jurisdiction_code);
    --

    p_returned_date := fnd_date.canonical_to_date(l_outputs(l_outputs.first).value);

    if g_debug then
     hr_utility.set_location ('p_returned_date='||p_returned_date,1689);
    end if;
    --
    --
    l_ben_disp_ff_warn_msg := get_profile_ff_warn_val();
    --
    IF l_ben_disp_ff_warn_msg = 'Y'  /* Bug 5088591 */
    THEN
      -- For Bug#5070692 in Dependent case p_effective_date was passing as NULL
      --
      if p_effective_date is null then
         l_date_temp := nvl(l_rl_lf_evt_ocrd_dt,p_lf_evt_ocrd_dt) ;
      end if;
      --
      validate_rule_cd_date
                           ( p_formula_id     => p_formula_id
  			    ,p_computed_Date  => p_returned_date
  			    ,p_lf_evt_ocrd_dt => l_rl_lf_evt_ocrd_dt
  			    ,p_per_in_ler_id  => p_per_in_ler_id
  			    ,p_effective_date => l_date_temp
  			    ,p_pgm_id         => p_pgm_id
  			    ,p_pl_id          => p_pl_id
  			    ,p_opt_id         => l_opt.opt_id
  			    ,p_person_id      => p_person_id
            		   );
      --
    END IF;
    --
  --
  --
  -- LRD - Later of Recorded Date and Event Date
  --
  elsif p_date_cd  in ( 'LRD' , 'NUMDOEN')  then
  --  hr_utility.set_location('Entering LRD',10);

    if l_lf_evt_ocrd_dt is null then
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    else
       l_event_date:= l_lf_evt_ocrd_dt;
    end if;

    l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    If l_recorded_date > l_event_date then
        p_returned_date:=l_recorded_date;
    else
        p_returned_date:=l_event_date;
    End If;
    --
  -- notified date
  elsif p_date_cd  =  'NUMDON'  then
       l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       if l_recorded_date is null then
          if l_lf_evt_ocrd_dt is null then
             l_recorded_date := get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
          else
             l_recorded_date := l_lf_evt_ocrd_dt;
          end if;
       end if ;
       p_returned_date:=l_recorded_date;
  --
  -- LODBED - One day before later of Recorded Date and Event Date
  --
  elsif p_date_cd in ('LODBED','LWEM') then
    --
  --  hr_utility.set_location('Entering LODBED OR LWEM',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    If l_recorded_date > l_event_date then
        p_returned_date:=l_recorded_date-1;
    else
        p_returned_date:=l_event_date-1;
    End If;
    --
    if p_date_cd = 'LWEM' and p_start_date > p_returned_date then
      --
      p_returned_date := p_start_date ;
      --
    end if;

     --
  --
  -- LALDCM - End of Month Later Event or Notified
  --
  elsif p_date_cd = 'LALDCM'  then
    --
  --  hr_utility.set_location('Entering LALDCM',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    If l_recorded_date > l_event_date then
       p_returned_date := last_day(l_recorded_date);
    else
       p_returned_date := last_day(l_event_date);
    End If;
  --
  -- LALDFM - End of Month After Later Event or Notified
  --
  elsif p_date_cd = 'LALDFM' then
    --
  --  hr_utility.set_location('Entering LALDFM',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    If l_recorded_date > l_event_date then
       p_returned_date := last_day(add_months(l_recorded_date,1));
    else
       p_returned_date := last_day(add_months(l_event_date,1));
    End If;
  --
  -- LAFDFM - Later: First Day of Following Month
  --
  elsif p_date_cd = 'LAFDFM' then
    --
  --  hr_utility.set_location('Entering LAFDFM',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    If l_recorded_date > l_event_date then
       p_returned_date := last_day(l_recorded_date)+1;
    else
       p_returned_date := last_day(l_event_date)+1;
    End If;
 --
 -- LALDCPPY - Later: Last day of current program or plan year
 --
 elsif p_date_cd  = 'LALDCPPY' then
   --
  --  hr_utility.set_location('Entering LALDCPPY',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
   l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

   If l_recorded_date > l_event_date then
      l_lf_evt_ocrd_dt := l_recorded_date;
   else
      l_lf_evt_ocrd_dt  := l_event_date;
   End If;

    get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;
    --
    p_returned_date :=l_end_date;
 --
 -- LAFDLMEPPY - First of Last Month in Year Later Event or Notified
 --
 elsif p_date_cd  = 'LAFDLMEPPY' then
   --
  --  hr_utility.set_location('Entering LAFDLMEPPY',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
   l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

   If l_recorded_date > l_event_date then
      l_lf_evt_ocrd_dt := l_recorded_date;
   else
      l_lf_evt_ocrd_dt  := l_event_date;
   End If;

    get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;
    --
    p_returned_date := last_day(add_months(l_end_date,-1))+1;
    --
 --
 -- LALDLPPEPPY - End of Last Pay Period of Event Year Later Event or Notified
 --
 elsif p_date_cd  = 'LALDLPPEPPY' then
   --
  --  hr_utility.set_location('Entering LALDLPPEPPY',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    If l_recorded_date > l_event_date then
       l_lf_evt_ocrd_dt := l_recorded_date;
    else
       l_lf_evt_ocrd_dt  := l_event_date;
    End If;
    --
    open c_pay_period_for_date(l_lf_evt_ocrd_dt);
    fetch c_pay_period_for_date into
          l_start_date,
          l_end_date;
    --
    if c_pay_period_for_date%notfound then
    --
      close c_pay_period_for_date;
    --  hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',145);
      fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('PERSON_ID',l_person_id);
      fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
      fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
      fnd_message.raise_error;
    --
    end if;
    --
    close c_pay_period_for_date;
    --
    p_returned_date := l_end_date;
    --
  --
  -- WALDLPPEPPY - 1 Prior or Last Pay Period End
  --
  elsif p_date_cd  = 'WALDLPPEPPY' then
    --
    if g_debug then
      hr_utility.set_location('Entering WALDLPPEPPY',10);
    end if;
    --
       if l_lf_evt_ocrd_dt is null then
       --
          l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       else
       --
          l_event_date := l_lf_evt_ocrd_dt;
       --
       end if;
       --
      --
      open c_pre_pay_period(l_event_date);
       fetch c_pre_pay_period into l_pre_pay_period;

       --
       if c_pre_pay_period%notfound then
       --
         close c_pre_pay_period;
      --  hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',150);
         fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
         fnd_message.set_token('DATE_CODE',p_date_cd);
         fnd_message.set_token('PERSON_ID',l_person_id);
         fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
         fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
         fnd_message.raise_error;
       --
       end if;
       --
	close c_pre_pay_period;
       --
	p_returned_date := l_pre_pay_period.end_date;
    --
    --
  --
  -- LODBEWM - 1 Prior New Rate Start or 1 Before Later Event or Notified
  --
  elsif p_date_cd  = 'LODBEWM' then
    --
  --  hr_utility.set_location('Entering LODBEWM',10);
    --
    open c_prtt_rt_val_dts;
    --
/*
      fetch c_prtt_rt_val_dts into l_start_date,
                                   l_end_date;
*/
    fetch c_prtt_rt_val_dts into l_dummy ;
    --
    if c_prtt_rt_val_dts%notfound then
    --
       if l_lf_evt_ocrd_dt is null then
       --
          l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       end if;
       --
       l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       --RCHASE Bug fix logic
       --If l_recorded_date > l_event_date then
       If l_recorded_date > l_event_date-1 then
       --
          --RCHASE Bug fix logic
          --p_returned_date := l_recorded_date - 1;
          p_returned_date := l_recorded_date;
       --
       else
       --
          p_returned_date := l_event_date - 1;
       --
       End If;
    --
    else
    --
/*
      open c_enrt_rt_val_dt;
      --
      fetch c_enrt_rt_val_dt into l_end_date;
      if c_enrt_rt_val_dt%found then
          --
          if g_debug then
            hr_utility.set_location('l_end_date - 1',1999);
          end if;
          p_returned_date := l_end_date - 1;
          --
      else
          --
       if l_lf_evt_ocrd_dt is null then
       --
       if g_debug then
         hr_utility.set_location('l_lf_evt_ocrd_dt is null',1999);
       end if;
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       end if;

          p_returned_date := l_event_date - 1;
          --
      end if;
      --
      close c_enrt_rt_val_dt ;
*/

    --  p_returned_date := p_start_date - 1;
        p_returned_date := null ; -- This is handled in rate and coverages call
    --
    end if;
    --
    close c_prtt_rt_val_dts;

    --
  --
  -- ODBEWM - 1 Prior New Rate Start or 1 Day Before Event
  --
  elsif p_date_cd  = 'ODBEWM' then
    --
    if g_debug then
      hr_utility.set_location('Entering ODBEWM',10);
    end if;
    --
    open c_prtt_rt_val_dts;
    --
/*
      fetch c_prtt_rt_val_dts into l_start_date,
                                   l_end_date;
*/
      fetch c_prtt_rt_val_dts into l_dummy ;
    --
    if g_debug then
      hr_utility.set_location('l_start_date'||l_start_date , 1999);
    end if;
    if g_debug then
      hr_utility.set_location('l_end_date'||l_end_date , 1999);
    end if;

    if c_prtt_rt_val_dts%notfound then
    --
       if l_lf_evt_ocrd_dt is null then
       --
       if g_debug then
         hr_utility.set_location('l_lf_evt_ocrd_dt is null',1999);
       end if;
          l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       end if;
       --
       if g_debug then
         hr_utility.set_location('l_event_date - 1',1999);
       end if;
       p_returned_date := l_event_date - 1;
    --
    else
/*

      open c_enrt_rt_val_dt;
      --
      fetch c_enrt_rt_val_dt into l_end_date;
      --
      if c_enrt_rt_val_dt%found then
          --
         if g_debug then
           hr_utility.set_location('l_end_date - 1',1999);
         end if;
         p_returned_date := l_end_date - 1;
          --
      else

       if l_lf_evt_ocrd_dt is null then
       --
       if g_debug then
         hr_utility.set_location('p_lf_evt_ocrd_dt is null',1999);
       end if;
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       end if;
          if g_debug then
            hr_utility.set_location('l_lf_evt_ocrd_dt else'||l_event_date , 1999);
          end if;
          p_returned_date := l_event_date - 1;
          --
      end if;

      -- p_returned_date := l_start_date - 1;
      --
      close c_enrt_rt_val_dt ;
*/
   -- p_returned_date := p_start_date - 1;
      p_returned_date := null ; -- This is handled in rate and coverages call

    --
    end if;
    --
    close c_prtt_rt_val_dts;
    --
  --
  -- LWODBED - 1 Prior or 1 Day Before Later of Event or Notified
  --
  elsif p_date_cd  = 'LWODBED' then
    --
    if g_debug then
      hr_utility.set_location('Entering LWODBED',10);
    end if;
    --
       if l_lf_evt_ocrd_dt is null then
       --
          l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       else
       --
          l_event_date:= l_lf_evt_ocrd_dt;
       --
       end if;
       --
       l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       --RCHASE Bug fix logic
       --If l_recorded_date > l_event_date then
       If l_recorded_date > l_event_date-1 then
       --
          --RCHASE Bug fix logic
          --p_returned_date := l_recorded_date - 1;
          p_returned_date := l_recorded_date;
       --
       else
       --
          p_returned_date := l_event_date - 1;
       --
       End If;
    --
  --
  -- LWALDLPPEPPY - 1 Prior or Later Event or Notified Last Pay Period End
  --
  elsif p_date_cd  = 'LWALDLPPEPPY' then
  --
    if g_debug then
      hr_utility.set_location('Entering LWALDLPPEPPY',10);
    end if;
    --
       if l_lf_evt_ocrd_dt is null then
       --
          l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       else
       --
          l_event_date:= l_lf_evt_ocrd_dt;
       --
       end if;
       --
       l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       If l_recorded_date > l_event_date then
       --
          l_lf_evt_ocrd_dt := l_recorded_date;
          --
           get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;
          --
          open c_pay_period_for_date(l_end_date);
          fetch c_pay_period_for_date into
                l_start_date,
                l_end_date;
          --
          if c_pay_period_for_date%notfound then
          --  hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',160);
            fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
            fnd_message.set_token('DATE_CODE',p_date_cd);
            fnd_message.set_token('PERSON_ID',l_person_id);
            fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
            fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
            fnd_message.raise_error;
          --
          end if;
          --
          close c_pay_period_for_date;
          --
          p_returned_date := l_end_date;
       --
       else
       --
          l_lf_evt_ocrd_dt := l_event_date;
          --
          get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;
          --
          open c_pay_period_for_date(l_end_date);
          fetch c_pay_period_for_date into
                l_start_date,
                l_end_date;
          --
          if c_pay_period_for_date%notfound then
          --  hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',165);
            fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
            fnd_message.set_token('DATE_CODE',p_date_cd);
            fnd_message.set_token('PERSON_ID',l_person_id);
            fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
            fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
            fnd_message.raise_error;
          --
          end if;
          --
          close c_pay_period_for_date;
          --
          p_returned_date := l_end_date;
       --
       End If;
    --
  --
  -- LWALDCPPY - 1 Prior or Later Event or Notified Year End
  --
  elsif p_date_cd  = 'LWALDCPPY' then
  --
    if g_debug then
      hr_utility.set_location('Entering LWALDCPPY',10);
    end if;
    --
       if l_lf_evt_ocrd_dt is null then
       --
          l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       else
       --
          l_event_date:= l_lf_evt_ocrd_dt;
       --
       end if;
       --
       l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       If l_recorded_date > l_event_date then
       --
          l_lf_evt_ocrd_dt := l_recorded_date;
          --
          get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;
          --
          p_returned_date := l_end_date;
       --
       else
       --
          l_lf_evt_ocrd_dt := l_event_date;
          --
           get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;
          --
          p_returned_date := l_end_date;
       --
       End If;
    --
  --
  -- LWALDCPP - 1 Prior or Later Event or Notified Pay Period End
  --
  elsif p_date_cd  = 'LWALDCPP' then
  --
    if g_debug then
      hr_utility.set_location('Entering LWALDCPP',10);
    end if;
    --
       if l_lf_evt_ocrd_dt is null then
       --
          l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       else
       --
          l_event_date:= l_lf_evt_ocrd_dt;
       --
       end if;
       --
       l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       If l_recorded_date > l_event_date then
       --
          open c_pay_period_for_date(l_recorded_date);
          fetch c_pay_period_for_date into
             l_start_date,
             l_end_date;
          close c_pay_period_for_date;
          --
          p_returned_date := l_end_date;
       --
       else
       --
          open c_pay_period_for_date(l_event_date);
          fetch c_pay_period_for_date into
             l_start_date,
             l_end_date;
          close c_pay_period_for_date;
          --
          p_returned_date := l_end_date;
       --
       End If;
    --
  --
  -- LWALDCM - 1 Prior or Later Event or Notified Month End
  --
  elsif p_date_cd  = 'LWALDCM' then
    --
    if g_debug then
      hr_utility.set_location('Entering LWALDCM',10);
    end if;
    --
       if l_lf_evt_ocrd_dt is null then
       --
          l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       else
       --
          l_event_date:= l_lf_evt_ocrd_dt;
       --
       end if;
       --
       l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       --
       If l_recorded_date > l_event_date then
       --
          p_returned_date := last_day(l_recorded_date);
       --
       else
       --
          p_returned_date := last_day(l_event_date);
       --
       End If;
    --
  --
  -- LFDPPYCF - First of Year On or After Later of Event or Notified
  --
  elsif p_date_cd  = 'LFDPPYCF' then
  --
  --  hr_utility.set_location('Entering LFDPPYCF',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    If l_recorded_date > l_event_date then
       l_lf_evt_ocrd_dt := l_recorded_date;
    else
       l_lf_evt_ocrd_dt  := l_event_date;
    End If;

    get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;
    --
    if l_lf_evt_ocrd_dt = l_start_date then
    --
      p_returned_date :=l_start_date;
    --
    else
    --
      get_next_plan_year
                 (p_effective_date => p_effective_date
                 ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
                 ,p_pl_id          => l_pl_id
                 ,p_pgm_id         => l_pgm_id
                 ,p_oipl_id        => l_oipl_id
                 ,p_date_cd        => p_date_cd
                 ,p_comp_obj_mode  => p_comp_obj_mode
                 ,p_start_date     => l_next_popl_yr_strt
                 ,p_end_date       => l_next_popl_yr_end) ;
      --
      p_returned_date :=l_next_popl_yr_strt;
    --
    end if;
    --
  --
  -- LAFDCPPY - Later: First day of current program or plan year
  --
  elsif p_date_cd  = 'LAFDCPPY' then
  --
  --  hr_utility.set_location('Entering LAFDCPPY',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    If l_recorded_date > l_event_date then
       l_lf_evt_ocrd_dt := l_recorded_date;
    else
       l_lf_evt_ocrd_dt  := l_event_date;
    End If;

    get_plan_year
           (p_effective_date => p_effective_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
           ,p_pl_id          => l_pl_id
           ,p_pgm_id         => l_pgm_id
           ,p_oipl_id        => l_oipl_id
           ,p_date_cd        => p_date_cd
           ,p_comp_obj_mode  => p_comp_obj_mode
           ,p_start_date     => l_start_date
           ,p_end_date       => l_end_date) ;
    --
    p_returned_date :=l_start_date;
  --
  -- LAFDFPPY - Later: First day of following program or plan year
  --
  elsif p_date_cd = 'LAFDFPPY' then
    --
  --  hr_utility.set_location('Entering LAFDFPPY',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    If l_recorded_date > l_event_date then
       l_lf_evt_ocrd_dt := l_recorded_date;
    else
       l_lf_evt_ocrd_dt  := l_event_date;
    End If;

    get_next_plan_year
                 (p_effective_date => p_effective_date
                 ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
                 ,p_pl_id          => l_pl_id
                 ,p_pgm_id         => l_pgm_id
                 ,p_oipl_id        => l_oipl_id
                 ,p_date_cd        => p_date_cd
                 ,p_comp_obj_mode  => p_comp_obj_mode
                 ,p_start_date     => l_next_popl_yr_strt
                 ,p_end_date       => l_next_popl_yr_end) ;
    --
    p_returned_date :=l_next_popl_yr_strt;
  --
  -- LALDCPP - Later: Last day of current pay period
  --
  elsif p_date_cd = 'LALDCPP' then
    --
  --  hr_utility.set_location('Entering LALDCPP',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    If l_recorded_date > l_event_date then
       l_lf_evt_ocrd_dt := l_recorded_date;
    else
       l_lf_evt_ocrd_dt  := l_event_date;
    End If;

    open c_pay_period;
    fetch c_pay_period into l_pay_period;
    if c_pay_period%notfound then
      close c_pay_period;
    --  hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',170);
      fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('PERSON_ID',l_person_id);
      fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
      fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
      fnd_message.raise_error;
    end if;
    p_returned_date := l_pay_period.end_date;
    close c_pay_period ;
  --
  --
  -- LAFDFPP - Later: First day of following pay period
  --
  elsif p_date_cd = 'LAFDFPP' then
    --
  --  hr_utility.set_location('Entering LAFDFPP',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    If l_recorded_date > l_event_date then
       l_lf_evt_ocrd_dt := l_recorded_date;
    else
       l_lf_evt_ocrd_dt  := l_event_date;
    End If;

    open c_next_pay_period(nvl(l_lf_evt_ocrd_dt,p_effective_date));
    fetch c_next_pay_period into l_next_pay_period;
    --
    if c_next_pay_period%notfound then
      close c_next_pay_period;
    --  hr_utility.set_location('BEN_91477_PAY_PERIOD_MISSING',170);
      fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
      fnd_message.set_token('DATE_CODE',p_date_cd);
      fnd_message.set_token('PERSON_ID',l_person_id);
      fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
      fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
      fnd_message.raise_error;
    end if;
    p_returned_date := l_next_pay_period.start_date;
    close c_next_pay_period;
  --
  -- LTODFED - Thirty-one days After Later of Recorded Date and Event Date
  --
  elsif p_date_cd  = 'LTODFED' then
    --
  --  hr_utility.set_location('Entering LTODFED',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;
    --
    end if;
    --
    l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    If l_recorded_date > l_event_date then
       p_returned_date := l_recorded_date + 31;
    else
       p_returned_date := l_event_date + 31;
    End If;
  --
  -- LSDFED - Sixty days After Later of Recorded Date and Event Date
  --
  elsif p_date_cd  = 'LSDFED' then
    --
  --  hr_utility.set_location('Entering LSDFED',10);
    --
    if l_lf_evt_ocrd_dt is null then
    --
       l_event_date:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
    --
    else
    --
       l_event_date:= l_lf_evt_ocrd_dt;

    end if;

    l_recorded_date:= get_recorded_date(p_cache_mode,l_per_in_ler_id,p_effective_date);

    If l_recorded_date > l_event_date then
       p_returned_date := l_recorded_date + 60;
    else
       p_returned_date := l_event_date + 60;
    End If;
  elsif p_date_cd = 'NA' then
       -- Not Applicable
       p_returned_date := null ;

    --- date related to hire dates
 elsif p_date_cd in ( '30DAHRD','31DAHRD','60DAHRD','61DAHRD') then

       -- get the latest hire date, if fails error
       if g_debug then
         hr_utility.set_location(' Hire date '  , 99 );
       end if;
       open c_pps ;
       fetch c_pps into l_hire_date ;
       close c_pps ;
       if g_debug then
         hr_utility.set_location(' Hire date ' || l_hire_date, 99 );
       end if;
       if  l_hire_date is null then
           fnd_message.set_name('BEN','BEN_92489_CANNOT_CALC_DATE');
           fnd_message.set_token('DATE_CODE',p_date_cd);
           fnd_message.set_token('L_PROC',l_proc);
           fnd_message.raise_error;
       end if ;
       if g_debug then
         hr_utility.set_location(' Hire date ' || l_hire_date, 99 );
       end if;

       if p_date_cd = '30DAHRD' then
          p_returned_date := l_hire_date + 30 ;
       elsif p_date_cd = '31DAHRD' then
          p_returned_date := l_hire_date + 31 ;
       elsif p_date_cd = '60DAHRD' then
          p_returned_date := l_hire_date + 60 ;
       elsif p_date_cd = '61DAHRD' then
          p_returned_date := l_hire_date + 61 ;
       end if ;
        if g_debug then
          hr_utility.set_location(' p_date_cd  ' || p_returned_date, 99 );
        end if;

  elsif p_date_cd in ('AFDELY','ALDELMY','FDM','FDMCFC','FDMFC',
                      'FDPP','FDPPQCFC','FDPPQFC','FDPPSYCFC','FDPPSYFC',                      'FDPPYCFC','FDPPYFC','FDQ','FFDFED','FFDFEPS',
                      'FDPPY','LDPPFEE','LDPPOAEE','LWALDCPPQ','LWALDPPSY',
                      'NDFEPS','WALDCPPQ','WALDCPPSY','FDCY','FFDFEPS',
                      'FDLY','FDQ','FDSY', 'LFSEMES'
                     ) then

   --  hr_utility.set_location('Future Date Code:  '||p_date_cd , 222);
     fnd_message.set_name('BEN','FUTURE_DATE_CD_DO_NOT_USE');
     fnd_message.set_token('DATE_CODE',p_date_cd);
     fnd_message.raise_error;

   elsif p_date_cd in ('FDPPFCDE','FDPPFCDEL') then
     --
     if g_debug then
         hr_utility.set_location(' Step 2 ' ,181);
     end if;
     --
     if p_date_cd = 'FDPPFCDE' then
       --
       if l_lf_evt_ocrd_dt is null then
         l_lf_evt_ocrd_dt:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       end if;
       l_start_date := l_lf_evt_ocrd_dt;
     else
       --
       hr_utility.set_location('p effective date '||p_effective_date,182);
       l_start_date := p_effective_date;
     end if;
     --
     open c_pay_period_for_check(l_start_date, 'E');
     fetch c_pay_period_for_check into l_start_date;
     if c_pay_period_for_check%notfound then
       --
       close c_pay_period_for_check;
       open c_pay_period_for_check(l_start_date, 'B');
       fetch c_pay_period_for_check into l_start_date;
       if c_pay_period_for_check%notfound then
         --
         close c_pay_period_for_check;
         --
         fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
         fnd_message.set_token('DATE_CODE',p_date_cd);
         fnd_message.set_token('L_PROC',l_proc);
         fnd_message.set_token('PERSON_ID',l_person_id);
         fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
         fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
         fnd_message.raise_error;
         --
       end if;
     else
       --  rehire and new hire validation
       open c_hire_date;
       fetch c_hire_date into l_hire_date;
       close c_hire_date;
       --
       if l_hire_date > l_start_date then
         --
         l_start_date := l_hire_date;
         --
       end if;
       --
     end if;
     --
     close c_pay_period_for_check;
     p_returned_date := l_start_date;

   elsif p_date_cd in ('WAPPCDE','WAPPDEL') then
     --
     if g_debug then
         hr_utility.set_location(' Step 2 ' ,181);
     end if;
     --
     if p_date_cd = 'WAPPCDE' then
       --
       if l_lf_evt_ocrd_dt is null then
         l_lf_evt_ocrd_dt:= get_event_date(p_cache_mode,l_per_in_ler_id,p_effective_date);
       end if;
       l_end_date := l_lf_evt_ocrd_dt;
     else
       --
       l_end_date := p_effective_date;
     end if;
     --
     open c_pay_period_for_check_end (l_end_date, 'E');
     fetch c_pay_period_for_check_end  into l_end_date;
     if c_pay_period_for_check_end %notfound then
       --
       close c_pay_period_for_check_end ;
       open c_pay_period_for_check_end (l_end_date, 'B');
       fetch c_pay_period_for_check_end  into l_end_date;
       if c_pay_period_for_check_end %notfound then
         --
         close c_pay_period_for_check_end ;
         --
         fnd_message.set_name('BEN','BEN_91477_PAY_PERIOD_MISSING');
         fnd_message.set_token('DATE_CODE',p_date_cd);
         fnd_message.set_token('L_PROC',l_proc);
         fnd_message.set_token('PERSON_ID',l_person_id);
         fnd_message.set_token('BUSINESS_GROUP_ID',l_business_group_id);
         fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
         fnd_message.raise_error;
         --
       end if;
     end if;
     --
     close c_pay_period_for_check_end ;
     p_returned_date := l_end_date;
  else

     hr_utility.set_location('Unknown Date Code:  '||p_date_cd , 222);
     fnd_message.set_name('BEN','BEN_91534_BEN_UNKNOWN_DATE_CD');
     fnd_message.set_token('DATE_CODE',p_date_cd);
     fnd_message.set_token('L_PROC',l_proc);
     fnd_message.raise_error;

  end  if;
  --
  if g_debug then
    hr_utility.set_location('p_returned_date: '||p_returned_date,15);
  end if;
  p_returned_date := trunc(p_returned_date);
  --
  if g_debug then
    hr_utility.set_location('sent dt code ' || p_date_cd ,596);
  end if;
  if g_debug then
    hr_utility.set_location('sent_dt p_returned_date: '||p_returned_date,15);
  end if;
  if g_debug then
    hr_utility.set_location('Leaving : '||l_proc , 20);
  end if;
exception   -- nocopy changes
  --
  when others then
    --
    p_returned_date := null;
    raise;
    --
end main;
--
-- Procedure Name
--    Rate and Coverage Dates
-- Purpose
--    This procedure is used to determine the (rate or coverage) (start or end)
--    date, code, and rule.  It calls ben_determine_date if the absolute date
--    is needed.
--
procedure rate_and_coverage_dates
  (p_cache_mode             in     boolean default false
  --
  -- Cache related parameters
  --
  ,p_pgm_row                in     ben_cobj_cache.g_pgm_inst_row
  := ben_cobj_cache.g_pgm_default_row
  ,p_ptip_row               in     ben_cobj_cache.g_ptip_inst_row
  := ben_cobj_cache.g_ptip_default_row
  ,p_plip_row               in     ben_cobj_cache.g_plip_inst_row
  := ben_cobj_cache.g_plip_default_row
  ,p_pl_row                 in     ben_cobj_cache.g_pl_inst_row
  := ben_cobj_cache.g_pl_default_row
  --
  ,p_per_in_ler_id          in     number  default null
  ,p_person_id              in     number  default null
  ,p_pgm_id                 in     number  default null
  ,p_pl_id                  in     number  default null
  ,p_oipl_id                in     number  default null
  ,p_par_ptip_id            in     number  default null
  ,p_par_plip_id            in     number  default null
  ,p_lee_rsn_id             in     number  default null
  ,p_enrt_perd_id           in     number  default null
  ,p_enrt_perd_for_pl_id    in     number  default null
  --
             -- which dates is R for rate, C for coverage, B for both
  ,p_which_dates_cd         in     varchar2      default 'B'
             -- will error if Y and an absolute date not found
             --   Note: codes must allways be found.
  ,p_date_mandatory_flag    in     varchar2      default 'Y'
             -- compute_dates_flag is Y for compute dates, N for Don't
  ,p_compute_dates_flag     in     varchar2      default 'Y'
             --
             -- optional for everything
             --
  ,p_elig_per_elctbl_chc_id in     number  default null
  ,p_acty_base_rt_id        in     number  default null
  ,p_business_group_id      in     number
  ,p_start_date             in     date    default null
  ,p_end_date               in     date    default null
  ,p_effective_date         in     date
  ,p_lf_evt_ocrd_dt         in     date    default null
  --
  ,p_enrt_cvg_strt_dt          out nocopy date
  ,p_enrt_cvg_strt_dt_cd       out nocopy varchar2
  ,p_enrt_cvg_strt_dt_rl       out nocopy number
  ,p_rt_strt_dt                out nocopy date
  ,p_rt_strt_dt_cd             out nocopy varchar2
  ,p_rt_strt_dt_rl             out nocopy number
  ,p_enrt_cvg_end_dt           out nocopy date
  ,p_enrt_cvg_end_dt_cd        out nocopy varchar2
  ,p_enrt_cvg_end_dt_rl        out nocopy number
  ,p_rt_end_dt                 out nocopy date
  ,p_rt_end_dt_cd              out nocopy varchar2
  ,p_rt_end_dt_rl              out nocopy number
  )
is
  --
  type t_rec is record
    (order_number        number
    ,enrt_cvg_strt_dt_cd varchar2(30)
    ,enrt_cvg_strt_dt_rl number
    ,enrt_cvg_end_dt_cd  varchar2(30)
    ,enrt_cvg_end_dt_rl  number
    ,rt_strt_dt_cd       varchar2(30)
    ,rt_strt_dt_rl       number
    ,rt_end_dt_cd        varchar2(30)
    ,rt_end_dt_rl        number
    );
  --
  type t_tab is table of t_rec index by binary_integer;
  --
  l_proc                  varchar2(72) := g_package||'.rate_and_coverage_dates';
  --
  l_union_set             t_tab;
  --
  l_found                 boolean;
  l_done                  boolean:=FALSE;
  l_enrt_cvg_strt_dt      date;
  l_enrt_cvg_strt_dt_cd   varchar2(30);
  l_enrt_cvg_strt_dt_rl   number;
  l_rt_strt_dt            date;
  l_rt_strt_dt_cd         varchar2(30);
  l_rt_strt_dt_rl         number;
  l_enrt_cvg_end_dt       date;
  l_enrt_cvg_end_dt_cd    varchar2(30);
  l_enrt_cvg_end_dt_rl    number;
  l_rt_end_dt             date;
  l_rt_end_dt_cd          varchar2(30);
  l_rt_end_dt_rl          number;
  l_pgm_id                number;
  l_pl_id                 number;
  l_enrt_perd_id          number;
  l_lee_rsn_id            number;
  l_oipl_id               number;
  l_per_in_ler_id         number;
  l_person_id             number;
  l_pass_cvg_end_dt       date;
  l_effective_date        date;
  l_plip_id               number;
  l_ptip_id               number;
  l_enrt_perd_for_pl_id   number;
  l_unionele_num          pls_integer;
  l_unionmaxele_num       pls_integer;
  l_pass_cvg_strt_dt      date;
  l_fonm_cvg_strt_dt      date;
  --
  -- Bug No 3965571
  --
  l_pln_name               ben_pl_f.name%type;
  l_pgm_name              ben_pgm_f.name%type;
  l_opt_name               ben_opt_f.name%type;
  --
  -- Cursor declaration.
  --
  -- Scheduled enrolment for plans in programs
  --
  cursor c_sched_for_plip
    (c_effective_date in date
    ,c_pgm_id         in number
    ,c_ptip_id        in number
    ,c_pl_id          in number
    ,c_plip_id        in number
    ,c_enrt_perd_id   in number
    ,c_epfp_id        in number
    ,c_per_in_ler_id  in number -- bug 4356591
    )
  is
    select  1 order_number,
            epp.enrt_cvg_strt_dt_cd,
            epp.enrt_cvg_strt_dt_rl,
            epp.enrt_cvg_end_dt_cd,
            epp.enrt_cvg_end_dt_rl,
            epp.rt_strt_dt_cd,
            epp.rt_strt_dt_rl,
            epp.rt_end_dt_cd,
            epp.rt_end_dt_rl
    from    ben_enrt_perd_for_pl_f epp
    where   epp.ENRT_PERD_FOR_PL_ID = c_epfp_id
    and     c_effective_date
      between epp.effective_start_date and epp.effective_end_date
   union
-- Bug # 4356591
-- in case of a plip. if the enrt_perd details are defined at the plan level
-- then details are selected by this select. The enrt_perd_id stored in
-- ben_pil_elctbl_chc is of the pgm or the first plan defined in the program
   select  2 order_number,
            epd.enrt_cvg_strt_dt_cd,
            epd.enrt_cvg_strt_dt_rl,
            epd.enrt_cvg_end_dt_cd,
            epd.enrt_cvg_end_dt_rl,
            epd.rt_strt_dt_cd,
            epd.rt_strt_dt_rl,
            epd.rt_end_dt_cd,
            epd.rt_end_dt_rl
   from     ben_popl_enrt_typ_cycl_f popl,
	    ben_enrt_perd epd,
	    ben_per_in_ler pil
    where   popl.pl_id = c_pl_id
    and     epd.popl_enrt_typ_cycl_id = popl.popl_enrt_typ_cycl_id
    and     pil.per_in_ler_id = c_per_in_ler_id
    and     epd.asnd_lf_evt_dt = pil.lf_evt_ocrd_dt /* removed join btw PIL and LER instead made join btw epd $ pil.*/
    and     c_effective_date between popl.effective_start_date and popl.effective_end_date
    and     (    enrt_cvg_strt_dt_cd is not null
             and enrt_cvg_end_dt_cd is not null
             and rt_strt_dt_cd is not null
             and rt_end_dt_cd is not null )
 -- end 4356591
   union
  -- Bug # 4356591
  -- If the enrt_perd details defined at program level and not at plan level
  -- then details are selected by this select.
    select  3 order_number,
            epd.enrt_cvg_strt_dt_cd,
            epd.enrt_cvg_strt_dt_rl,
            epd.enrt_cvg_end_dt_cd,
            epd.enrt_cvg_end_dt_rl,
            epd.rt_strt_dt_cd,
            epd.rt_strt_dt_rl,
            epd.rt_end_dt_cd,
            epd.rt_end_dt_rl
    from    ben_popl_enrt_typ_cycl_f popl, -- start 4356591
	    ben_enrt_perd epd,
	    ben_per_in_ler pil
    where   popl.pgm_id = c_pgm_id
    and     epd.popl_enrt_typ_cycl_id = popl.popl_enrt_typ_cycl_id
    and     pil.per_in_ler_id = c_per_in_ler_id
    and     epd.asnd_lf_evt_dt = pil.lf_evt_ocrd_dt /* removed join btw PIL and LER instead made join btw epd $ pil.*/
    and     c_effective_date between popl.effective_start_date and popl.effective_end_date
    and     (    enrt_cvg_strt_dt_cd is not null
             and enrt_cvg_end_dt_cd is not null
             and rt_strt_dt_cd is not null
             and rt_end_dt_cd is not null ) -- end 4356591
   union
    select  4 order_number,
            plp.enrt_cvg_strt_dt_cd,
            plp.enrt_cvg_strt_dt_rl,
            plp.enrt_cvg_end_dt_cd,
            plp.enrt_cvg_end_dt_rl,
            plp.rt_strt_dt_cd,
            plp.rt_strt_dt_rl,
            plp.rt_end_dt_cd,
            plp.rt_end_dt_rl
    from    ben_plip_f plp
    where   plp.plip_id=c_plip_id
    and     c_effective_date
      between plp.effective_start_date and plp.effective_end_date
  union
    select  5 order_number,
            pln.enrt_cvg_strt_dt_cd,
            pln.enrt_cvg_strt_dt_rl,
            pln.enrt_cvg_end_dt_cd,
            pln.enrt_cvg_end_dt_rl,
            pln.rt_strt_dt_cd,
            pln.rt_strt_dt_rl,
            pln.rt_end_dt_cd,
            pln.rt_end_dt_rl
    from    ben_pl_f pln
    where   pln.pl_id=c_pl_id
    and     c_effective_date
      between pln.effective_start_date and pln.effective_end_date
  union
    select  6 order_number,
            ptip.enrt_cvg_strt_dt_cd,
            ptip.enrt_cvg_strt_dt_rl,
            ptip.enrt_cvg_end_dt_cd,
            ptip.enrt_cvg_end_dt_rl,
            ptip.rt_strt_dt_cd,
            ptip.rt_strt_dt_rl,
            ptip.rt_end_dt_cd,
            ptip.rt_end_dt_rl
    from    ben_ptip_f ptip
    where   ptip.ptip_id=c_ptip_id
    and     c_effective_date
      between ptip.effective_start_date and ptip.effective_end_date
  union
    select  7 order_number,
            pgm.enrt_cvg_strt_dt_cd,
            pgm.enrt_cvg_strt_dt_rl,
            pgm.enrt_cvg_end_dt_cd,
            pgm.enrt_cvg_end_dt_rl,
            pgm.rt_strt_dt_cd,
            pgm.rt_strt_dt_rl,
            pgm.rt_end_dt_cd,
            pgm.rt_end_dt_rl
    from    ben_pgm_f pgm
    where   pgm.pgm_id = c_pgm_id
    and     c_effective_date
      between pgm.effective_start_date and pgm.effective_end_date
      order by 1; -- bug 5717428
  --
  -- Scheduled enrolment for plans not in programs
  --
  cursor c_sched_for_pl_nip is
    select  '2' order_number,
            enrt_cvg_strt_dt_cd,
            enrt_cvg_strt_dt_rl,
            enrt_cvg_end_dt_cd,
            enrt_cvg_end_dt_rl,
            rt_strt_dt_cd,
            rt_strt_dt_rl,
            rt_end_dt_cd,
            rt_end_dt_rl
    from    ben_enrt_perd
    where   enrt_perd_id=l_enrt_perd_id and
            business_group_id =p_business_group_id
  union
    select  '4' order_number,
            enrt_cvg_strt_dt_cd,
            enrt_cvg_strt_dt_rl,
            enrt_cvg_end_dt_cd,
            enrt_cvg_end_dt_rl,
            rt_strt_dt_cd,
            rt_strt_dt_rl,
            rt_end_dt_cd,
            rt_end_dt_rl
    from    ben_pl_f
    where   pl_id=l_pl_id and
            business_group_id =p_business_group_id and
            nvl(p_lf_evt_ocrd_dt,p_effective_date) between
              effective_start_date and effective_end_date
  order by 1;
  --
  -- Life event enrolment for plans in programs
  --
  cursor c_life_for_plip
    (c_effective_date    in date
    ,c_epfp_id           in number
    ,c_lee_rsn_id        in number
    ,c_plip_id           in number
    ,c_pl_id             in number
    ,c_ptip_id           in number
    ,c_pgm_id            in number
    ,c_per_in_ler_id     in number
    )
  is
    select  1 order_number,
            epp.enrt_cvg_strt_dt_cd,
            epp.enrt_cvg_strt_dt_rl,
            epp.enrt_cvg_end_dt_cd,
            epp.enrt_cvg_end_dt_rl,
            epp.rt_strt_dt_cd,
            epp.rt_strt_dt_rl,
            epp.rt_end_dt_cd,
            epp.rt_end_dt_rl
    from    ben_enrt_perd_for_pl_f epp
    where   epp.ENRT_PERD_FOR_PL_ID=c_epfp_id
    and     c_effective_date
    between epp.effective_start_date and epp.effective_end_date
    and     (    enrt_cvg_strt_dt_cd is not null
             and enrt_cvg_end_dt_cd is not null
             and rt_strt_dt_cd is not null
             and rt_end_dt_cd is not null
            )
   union
-- Bug # 2527347
-- in case of a plip. if the lee_rsn details are defined at the plan level
-- then details are selected by this select. The lee_rsn_id stored in
-- ben_pil_elctbl_chc is of the pgm or the first plan defined in the program
    select  2 order_number,
            lee.enrt_cvg_strt_dt_cd,
            lee.enrt_cvg_strt_dt_rl,
            lee.enrt_cvg_end_dt_cd,
            lee.enrt_cvg_end_dt_rl,
            lee.rt_strt_dt_cd,
            lee.rt_strt_dt_rl,
            lee.rt_end_dt_cd,
            lee.rt_end_dt_rl
    from    ben_popl_enrt_typ_cycl_f popl,
	    ben_lee_rsn_f lee,
	    ben_ler_f     ler,
	    ben_per_in_ler pil
    where   popl.pl_id = c_pl_id
    and     c_effective_date between popl.effective_start_date and popl.effective_end_date
    and     lee.popl_enrt_typ_cycl_id = popl.popl_enrt_typ_cycl_id
    and     pil.per_in_ler_id = c_per_in_ler_id
    and     ler.ler_id = pil.ler_id
    and     lee.ler_id = ler.ler_id
    and     c_effective_date between lee.effective_start_date and lee.effective_end_date
    and     c_effective_date between popl.effective_start_date and popl.effective_end_date
    and     (    enrt_cvg_strt_dt_cd is not null
             and enrt_cvg_end_dt_cd is not null
             and rt_strt_dt_cd is not null
             and rt_end_dt_cd is not null )
-- end bug # 2527347
   union
   -- Bug # 4356591
   -- If the lee_rsn_details defined at program level and not at plan level
   -- then details are selected by this select.
    select  3 order_number,
            lee.enrt_cvg_strt_dt_cd,
            lee.enrt_cvg_strt_dt_rl,
            lee.enrt_cvg_end_dt_cd,
            lee.enrt_cvg_end_dt_rl,
            lee.rt_strt_dt_cd,
            lee.rt_strt_dt_rl,
            lee.rt_end_dt_cd,
            lee.rt_end_dt_rl
    from    ben_popl_enrt_typ_cycl_f popl, -- start 4356591
	    ben_lee_rsn_f lee,
	    ben_per_in_ler pil
    where   popl.pgm_id = c_pgm_id
    and     c_effective_date between popl.effective_start_date and popl.effective_end_date
    and     lee.popl_enrt_typ_cycl_id = popl.popl_enrt_typ_cycl_id
    and     pil.per_in_ler_id = c_per_in_ler_id
    and     lee.ler_id = pil.ler_id
    and     c_effective_date between lee.effective_start_date and lee.effective_end_date
    and     c_effective_date between popl.effective_start_date and popl.effective_end_date -- end 4356591
    and     (    enrt_cvg_strt_dt_cd is not null
             and enrt_cvg_end_dt_cd is not null
             and rt_strt_dt_cd is not null
             and rt_end_dt_cd is not null
            )
  union
    select  4 order_number,
            plp.enrt_cvg_strt_dt_cd,
            plp.enrt_cvg_strt_dt_rl,
            plp.enrt_cvg_end_dt_cd,
            plp.enrt_cvg_end_dt_rl,
            plp.rt_strt_dt_cd,
            plp.rt_strt_dt_rl,
            plp.rt_end_dt_cd,
            plp.rt_end_dt_rl
    from    ben_plip_f plp
    where   plp.plip_id=c_plip_id
    and     c_effective_date
      between plp.effective_start_date and plp.effective_end_date
    and     (    enrt_cvg_strt_dt_cd is not null
             and enrt_cvg_end_dt_cd is not null
             and rt_strt_dt_cd is not null
             and rt_end_dt_cd is not null
            )
  union
    select  5 order_number,
            pln.enrt_cvg_strt_dt_cd,
            pln.enrt_cvg_strt_dt_rl,
            pln.enrt_cvg_end_dt_cd,
            pln.enrt_cvg_end_dt_rl,
            pln.rt_strt_dt_cd,
            pln.rt_strt_dt_rl,
            pln.rt_end_dt_cd,
            pln.rt_end_dt_rl
    from    ben_pl_f pln
    where   pln.pl_id=c_pl_id
    and     c_effective_date
      between pln.effective_start_date and pln.effective_end_date
    and     (    enrt_cvg_strt_dt_cd is not null
             and enrt_cvg_end_dt_cd is not null
             and rt_strt_dt_cd is not null
             and rt_end_dt_cd is not null
            )
  union
    select  6 order_number,
            ptip.enrt_cvg_strt_dt_cd,
            ptip.enrt_cvg_strt_dt_rl,
            ptip.enrt_cvg_end_dt_cd,
            ptip.enrt_cvg_end_dt_rl,
            ptip.rt_strt_dt_cd,
            ptip.rt_strt_dt_rl,
            ptip.rt_end_dt_cd,
            ptip.rt_end_dt_rl
    from    ben_ptip_f ptip
    where   ptip.ptip_id=c_ptip_id
    and     c_effective_date
      between ptip.effective_start_date and ptip.effective_end_date
    and     (    enrt_cvg_strt_dt_cd is not null
             and enrt_cvg_end_dt_cd is not null
             and rt_strt_dt_cd is not null
             and rt_end_dt_cd is not null
            )
  union
    select  7 order_number,
            pgm.enrt_cvg_strt_dt_cd,
            pgm.enrt_cvg_strt_dt_rl,
            pgm.enrt_cvg_end_dt_cd,
            pgm.enrt_cvg_end_dt_rl,
            pgm.rt_strt_dt_cd,
            pgm.rt_strt_dt_rl,
            pgm.rt_end_dt_cd,
            pgm.rt_end_dt_rl
    from    ben_pgm_f pgm
    where   pgm.pgm_id=c_pgm_id
    and     c_effective_date
      between pgm.effective_start_date and pgm.effective_end_date
    and     (    enrt_cvg_strt_dt_cd is not null
             and enrt_cvg_end_dt_cd is not null
             and rt_strt_dt_cd is not null
             and rt_end_dt_cd is not null
            )
    order by 1 ; --  Bug 2122643
  --
  -- Life event enrolment for plans not in programs
  --
  cursor c_life_for_pl_nip is
    select  '2' order_number,
            enrt_cvg_strt_dt_cd,
            enrt_cvg_strt_dt_rl,
            enrt_cvg_end_dt_cd,
            enrt_cvg_end_dt_rl,
            rt_strt_dt_cd,
            rt_strt_dt_rl,
            rt_end_dt_cd,
            rt_end_dt_rl
    from    ben_lee_rsn_f
    where   lee_rsn_id=l_lee_rsn_id and
            business_group_id =p_business_group_id and
            nvl(p_lf_evt_ocrd_dt,p_effective_date) between
              effective_start_date and effective_end_date
  union
    select  '4' order_number,
            enrt_cvg_strt_dt_cd,
            enrt_cvg_strt_dt_rl,
            enrt_cvg_end_dt_cd,
            enrt_cvg_end_dt_rl,
            rt_strt_dt_cd,
            rt_strt_dt_rl,
            rt_end_dt_cd,
            rt_end_dt_rl
    from    ben_pl_f
    where   pl_id=l_pl_id and
            business_group_id =p_business_group_id and
            nvl(p_lf_evt_ocrd_dt,p_effective_date) between
              effective_start_date and effective_end_date
  order by 1;
  --
  l_rec c_life_for_plip%rowtype;
  --
  -- get elig_per_elctbl_chc_info
  --
  cursor c_epe_info is
    select
        epe.pl_id,
        epe.pgm_id,
        pel.enrt_perd_id,
        pel.lee_rsn_id,
        epe.oipl_id,
        epe.per_in_ler_id,
        pil.person_id,
        epe.fonm_cvg_strt_dt
    from
        ben_elig_per_elctbl_chc epe,
        ben_pil_elctbl_chc_popl pel,
        ben_per_in_ler pil
    where
        epe.elig_per_elctbl_chc_id=p_elig_per_elctbl_chc_id and
        pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id and
        pil.per_in_ler_id=epe.per_in_ler_id;
        -- removed these joins, as a run was getting a null BG id passed in
        -- and if we have the chc id we shouldn't need bg id:
        --pel.business_group_id =p_business_group_id and
        --pil.business_group_id =p_business_group_id
        --epe.business_group_id =p_business_group_id and
  --
  cursor c_gptip_id
    (c_pl_id          in number
    ,c_pgm_id         in number
    ,c_effective_date in date
    )
  is
    select ptp.ptip_id
    from ben_ptip_f ptp,
         ben_pl_f pln
    where ptp.pl_typ_id = pln.pl_typ_id
    and   c_effective_date
      between pln.effective_start_date and pln.effective_end_date
    and   ptp.pgm_id    = c_pgm_id
    and   pln.pl_id     = c_pl_id
    and   c_effective_date
      between ptp.effective_start_date and ptp.effective_end_date;

  --
  cursor c_gplip_id
    (c_pl_id          in number
    ,c_pgm_id         in number
    ,c_effective_date in date
    )
  is
    select plp.plip_id
    from ben_plip_f plp
    where plp.pgm_id    = c_pgm_id
    and   plp.pl_id     = c_pl_id
    and   c_effective_date
      between plp.effective_start_date and plp.effective_end_date;

  cursor c_glee_epfp_id
    (c_pl_id          in number
    ,c_lee_rsn_id     in number
    ,c_effective_date in date
    )
  is
    select epfp.ENRT_PERD_FOR_PL_ID
    from ben_enrt_perd_for_pl_f epfp
    where epfp.lee_rsn_id = c_lee_rsn_id
    and   epfp.pl_id      = c_pl_id
    and   c_effective_date
      between epfp.effective_start_date and epfp.effective_end_date;

  cursor c_genp_epfp_id
    (c_pl_id          in number
    ,c_enrt_perd_id   in number
    ,c_effective_date in date
    )
  is
    select epfp.ENRT_PERD_FOR_PL_ID
    from ben_enrt_perd_for_pl_f epfp
    where epfp.enrt_perd_id = c_enrt_perd_id
    and   epfp.pl_id        = c_pl_id
    and   c_effective_date
      between epfp.effective_start_date and epfp.effective_end_date;

  cursor c_gepp_dets
    (c_epfp_id        in number
    ,c_effective_date in date
    )
  is
    select 1 order_number,
            epp.enrt_cvg_strt_dt_cd,
            epp.enrt_cvg_strt_dt_rl,
            epp.enrt_cvg_end_dt_cd,
            epp.enrt_cvg_end_dt_rl,
            epp.rt_strt_dt_cd,
            epp.rt_strt_dt_rl,
            epp.rt_end_dt_cd,
            epp.rt_end_dt_rl
    from    ben_enrt_perd_for_pl_f epp
    where   epp.ENRT_PERD_FOR_PL_ID=c_epfp_id
    and     c_effective_date
    between epp.effective_start_date and epp.effective_end_date
    and     (    enrt_cvg_strt_dt_cd is not null
             and enrt_cvg_end_dt_cd is not null
             and rt_strt_dt_cd is not null
             and rt_end_dt_cd is not null
            );

  l_epp_rec c_gepp_dets%rowtype;

  cursor c_gleersn_dets
    (c_lee_rsn_id     in number
    ,c_effective_date in date
    )
  is
    select 2 order_number,
            lee.enrt_cvg_strt_dt_cd,
            lee.enrt_cvg_strt_dt_rl,
            lee.enrt_cvg_end_dt_cd,
            lee.enrt_cvg_end_dt_rl,
            lee.rt_strt_dt_cd,
            lee.rt_strt_dt_rl,
            lee.rt_end_dt_cd,
            lee.rt_end_dt_rl
    from    ben_lee_rsn_f lee
    where   lee.lee_rsn_id=c_lee_rsn_id
    and     c_effective_date
      between lee.effective_start_date and lee.effective_end_date
    and     (    enrt_cvg_strt_dt_cd is not null
             and enrt_cvg_end_dt_cd is not null
             and rt_strt_dt_cd is not null
             and rt_end_dt_cd is not null
            );

  --
  -- Bug No 3965571
  --
  cursor c_pln
  (c_pl_id     in number
  ,c_effective_date in date)
  is
    select pln.name
        from ben_pl_f pln
	   where pln.pl_id = c_pl_id and pln.business_group_id = p_business_group_id
                     and c_effective_date between pln.effective_start_date and pln.effective_end_date;

  cursor c_pgm
  (c_pgm_id     in number
  ,c_effective_date in date)
  is
    select pgm.name
        from ben_pgm_f pgm
	   where pgm.pgm_id = c_pgm_id and pgm.business_group_id = p_business_group_id
                     and c_effective_date between pgm.effective_start_date and pgm.effective_end_date;

  cursor c_opt
  (c_oipl_id   in number
  ,c_effective_date in date)
  is
   select opt.name
        from ben_oipl_f oipl, ben_opt_f opt
          where oipl.business_group_id=p_business_group_id
                   and oipl.opt_id = opt.opt_id and oipl.oipl_id = c_oipl_id
		   and c_effective_date between oipl.effective_start_date and oipl.effective_end_date
		   and c_effective_date between opt.effective_start_date and opt.effective_end_date;
--
-- End 3965571
--

  l_leersn_rec c_gleersn_dets%rowtype;
  l_pil_row    ben_per_in_ler%rowtype;


begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
/*
  if p_which_dates_cd = 'R' then
    --hr_utility.set_location('p_cache_mode               '|| p_cache_mode             , 1687);
    if g_debug then
      hr_utility.set_location('p_per_in_ler_id             '|| p_per_in_ler_id          , 1687);
    end if;
    if g_debug then
      hr_utility.set_location('p_person_id              	 '|| p_person_id              , 1687);
    end if;
    if g_debug then
      hr_utility.set_location('p_pgm_id                 	 '|| p_pgm_id                 , 1687);
    end if;
    if g_debug then
      hr_utility.set_location('p_pl_id                  	 '|| p_pl_id                  , 1687);
    end if;
    if g_debug then
      hr_utility.set_location('p_oipl_id                	 '|| p_oipl_id                , 1687);
    end if;
    if g_debug then
      hr_utility.set_location('p_par_ptip_id            	 '|| p_par_ptip_id            , 1687);
    end if;
    if g_debug then
      hr_utility.set_location('p_lee_rsn_id             	 '|| p_lee_rsn_id             , 1687);
    end if;
    if g_debug then
      hr_utility.set_location('p_enrt_perd_id           	 '|| p_enrt_perd_id           , 1687);
    end if;
    if g_debug then
      hr_utility.set_location('p_enrt_perd_for_pl_id    	 '|| p_enrt_perd_for_pl_id    , 1687);
    end if;
    if g_debug then
      hr_utility.set_location('p_which_dates_cd         	 '|| p_which_dates_cd         , 1687);
    end if;
    if g_debug then
      hr_utility.set_location('p_date_mandatory_flag    	 '|| p_date_mandatory_flag    , 1687);
    end if;
    if g_debug then
      hr_utility.set_location('p_compute_dates_flag     	 '|| p_compute_dates_flag     , 1687);
    end if;
    if g_debug then
      hr_utility.set_location('p_elig_per_elctbl_chc_id 	 '|| p_elig_per_elctbl_chc_id , 1687);
    end if;
    if g_debug then
      hr_utility.set_location('p_acty_base_rt_id        	 '|| p_acty_base_rt_id        , 1687);
    end if;
    if g_debug then
      hr_utility.set_location('p_business_group_id      	 '|| p_business_group_id      , 1687);
    end if;
    if g_debug then
      hr_utility.set_location('p_start_date             	 '|| p_start_date             , 1687);
    end if;
    if g_debug then
      hr_utility.set_location('p_end_date               	 '|| p_end_date               , 1687);
    end if;
    if g_debug then
      hr_utility.set_location('p_effective_date         	 '|| p_effective_date         , 1687);
    end if;
    if g_debug then
      hr_utility.set_location('p_lf_evt_ocrd_dt         	 '|| p_lf_evt_ocrd_dt         , 1687);
    end if;
  end if;
*/
  --


  l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);

  hr_utility.set_location('l_effective_date ' || l_effective_date, 2080);
  --
  -- Get the necessary info to start processing
  --
  if p_cache_mode
  then
    --
    l_person_id           := p_person_id;
    l_per_in_ler_id       := p_per_in_ler_id;
    l_pgm_id              := p_pgm_id;
    l_ptip_id             := p_par_ptip_id;
    l_pl_id               := p_pl_id;
    l_plip_id             := p_par_plip_id;
    l_oipl_id             := p_oipl_id;
    l_enrt_perd_id        := p_enrt_perd_id;
    l_lee_rsn_id          := p_lee_rsn_id;
    l_enrt_perd_for_pl_id := p_enrt_perd_for_pl_id;
    --l_fonm_cvg_strt_dt    := ben_manage_life_events.g_fonm_cvg_strt_dt ;
    --
  elsif p_elig_per_elctbl_chc_id is not null then
    --
    if g_debug then
      hr_utility.set_location(l_proc , 20);
    end if;
    --
    -- get from elig_per_elctbl_chc
    --   Note: Don't need all the args just the ones for direct use by
    --         this module, let determine date take care of itself
    --
    open c_epe_info;
    fetch c_epe_info into
      l_pl_id,
      l_pgm_id,
      l_enrt_perd_id,
      l_lee_rsn_id,
      l_oipl_id,
      l_per_in_ler_id,
      l_person_id,
      l_fonm_cvg_strt_dt
    ;
    --
    if g_debug then
      hr_utility.set_location('l_oipl_id '||l_oipl_id,19);
    end if;
    if c_epe_info%notfound then
      close c_epe_info;
      fnd_message.set_name('BEN','BEN_91457_ELCTBL_CHC_NOT_FOUND');
      --fnd_message.set_token('ID', to_char(p_business_group_id));
      fnd_message.set_token('ID', to_char(p_elig_per_elctbl_chc_id));
      fnd_message.set_token('PROC',l_proc);
      fnd_message.raise_error;
    end if;
    if g_debug then
      hr_utility.set_location(l_proc , 40);
    end if;

    close c_epe_info;
  else
    if g_debug then
      hr_utility.set_location(l_proc , 50);
    end if;
    --
    -- use args
    --
    l_pl_id:=p_pl_id;
    l_pgm_id:=p_pgm_id;
    l_enrt_perd_id:=p_enrt_perd_id;
    l_lee_rsn_id:=p_lee_rsn_id;
    l_oipl_id:=p_oipl_id;
    l_per_in_ler_id:=p_per_in_ler_id;
    l_person_id:=p_person_id;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location(l_proc , 60);
    hr_utility.set_location('FONM FLAG ' || ben_manage_life_events.fonm   , 60);
    hr_utility.set_location('FONM gc date  ' ||  ben_manage_life_events.g_fonm_cvg_strt_dt  , 60);
    hr_utility.set_location('FONM gr date  ' ||  ben_manage_life_events.g_fonm_rt_strt_dt  , 60);
    hr_utility.set_location('FONM epe date  ' || l_fonm_cvg_strt_dt  , 60);
    hr_utility.set_location('which date code   ' ||  p_which_dates_cd   , 60);
    hr_utility.set_location('plan    ' ||  p_pl_id    , 60);

  end if;


  --
  -- Get the codes and rules
  --
  -- Open and fetch first row
  --
  if l_pgm_id is not null then
    --
    -- Get the ptip id for the pl and pgm
    --
    if l_ptip_id is null then
    --  hr_utility.set_location(' c_gptip_id: '||l_proc , 140);
      open c_gptip_id
        (c_pl_id          => l_pl_id
        ,c_pgm_id         => l_pgm_id
        ,c_effective_date => l_effective_date
        );
      fetch c_gptip_id into l_ptip_id;
      close c_gptip_id;
      if g_debug then
        hr_utility.set_location(' Dn c_gptip_id: '||l_proc , 140);
      end if;
    else
      l_ptip_id := p_par_ptip_id;
    end if;
    --
    -- Get the plip id for the pl and pgm
    --
    if l_plip_id is null then
      if g_debug then
        hr_utility.set_location(' c_gplip_id: '||l_proc , 140);
      end if;
      open c_gplip_id
        (c_pl_id          => l_pl_id
        ,c_pgm_id         => l_pgm_id
        ,c_effective_date => l_effective_date
        );
      fetch c_gplip_id into l_plip_id;
      close c_gplip_id;
      if g_debug then
        hr_utility.set_location(' Dn c_gplip_id: '||l_proc , 140);
      end if;
    else
      l_plip_id := p_par_plip_id;
    end if;
    --
    if l_enrt_perd_id is not null then
      if g_debug then
        hr_utility.set_location(' Op c_SCFP: '||l_proc , 140);
      end if;
      --
      -- Check if the enrt perd for pl id is passed in
      --
      if l_enrt_perd_for_pl_id is null then
        --
        open c_genp_epfp_id
          (c_pl_id          => l_pl_id
          ,c_enrt_perd_id   => l_enrt_perd_id
          ,c_effective_date => l_effective_date
          );
        fetch c_genp_epfp_id into l_enrt_perd_for_pl_id;
        close c_genp_epfp_id;
        --
      else
        --
        l_enrt_perd_for_pl_id := p_enrt_perd_for_pl_id;
        --
      end if;
      --
      open c_sched_for_plip
        (c_effective_date => l_effective_date
        ,c_pgm_id         => l_pgm_id
        ,c_ptip_id        => l_ptip_id
        ,c_pl_id          => l_pl_id
        ,c_plip_id        => l_plip_id
        ,c_enrt_perd_id   => l_enrt_perd_id
        ,c_epfp_id        => l_enrt_perd_for_pl_id
	,c_per_in_ler_id  => l_per_in_ler_id      -- bug 4356591
        );
      fetch c_sched_for_plip into l_rec;
      if g_debug then
        hr_utility.set_location(' Dn Fet c_SCFP: '||l_proc , 140);
	hr_utility.set_location(' l_rec.enrt_cvg_strt_dt_cd : '|| l_rec.enrt_cvg_strt_dt_cd , 140);
        hr_utility.set_location(' l_rec.enrt_cvg_end_dt_cd : '|| l_rec.enrt_cvg_end_dt_cd , 140);
      end if;
      l_found:=c_sched_for_plip%found;
    else
      --
      -- do life event plip processing
      -- also used for unrestricted plip
      --
      if g_debug then
        hr_utility.set_location(' Op c_glee_epfp_id: '||l_proc , 150);
      end if;
      --
      if l_enrt_perd_for_pl_id is null then
        --
        open c_glee_epfp_id
          (c_pl_id          => l_pl_id
          ,c_lee_rsn_id     => l_lee_rsn_id
          ,c_effective_date => l_effective_date
          );
        fetch c_glee_epfp_id into l_enrt_perd_for_pl_id;
        close c_glee_epfp_id;
        --
      else
        --
        l_enrt_perd_for_pl_id := p_enrt_perd_for_pl_id;
        --
      end if;
      --
   if g_debug then
     hr_utility.set_location(' Dn c_glee_epfp_id: '||l_proc , 150);
   end if;
      --
      -- Fetch the first row from the union cache
      --
      if p_pgm_row.pgm_id is not null
        and p_ptip_row.ptip_id is not null
        and p_plip_row.plip_id is not null
        and p_pl_row.pl_id is not null
      then

      if g_debug then
        hr_utility.set_location(' Building the union cache ', 1687);
      end if;
        --
        -- Build up union set
        --
        l_unionele_num := 0;
        l_union_set.delete;
        --
        open c_gepp_dets
          (c_epfp_id        => l_enrt_perd_for_pl_id
          ,c_effective_date => l_effective_date
          );
        fetch c_gepp_dets into l_epp_rec;
        if c_gepp_dets%found then
          --
          l_union_set(l_unionele_num).order_number        := 1;
          l_union_set(l_unionele_num).enrt_cvg_strt_dt_cd := l_epp_rec.enrt_cvg_strt_dt_cd;
          l_union_set(l_unionele_num).enrt_cvg_strt_dt_rl := l_epp_rec.enrt_cvg_strt_dt_rl;
          l_union_set(l_unionele_num).enrt_cvg_end_dt_cd  := l_epp_rec.enrt_cvg_end_dt_cd;
          l_union_set(l_unionele_num).enrt_cvg_end_dt_rl  := l_epp_rec.enrt_cvg_end_dt_rl;
          l_union_set(l_unionele_num).rt_strt_dt_cd       := l_epp_rec.rt_strt_dt_cd;
          l_union_set(l_unionele_num).rt_strt_dt_rl       := l_epp_rec.rt_strt_dt_rl;
          l_union_set(l_unionele_num).rt_end_dt_cd        := l_epp_rec.rt_end_dt_cd;
          l_union_set(l_unionele_num).rt_end_dt_rl        := l_epp_rec.rt_end_dt_rl;
          l_unionele_num := l_unionele_num+1;
          --
        end if;
        close c_gepp_dets;
        --
if g_debug then
  hr_utility.set_location(' l_lee_rsn_id: '||l_lee_rsn_id, 1687);
end if;

        open c_gleersn_dets
          (c_lee_rsn_id     => l_lee_rsn_id
          ,c_effective_date => l_effective_date
          );
        fetch c_gleersn_dets into l_leersn_rec;
        if c_gleersn_dets%found then
          --
          l_union_set(l_unionele_num).order_number        := 2;
          l_union_set(l_unionele_num).enrt_cvg_strt_dt_cd := l_leersn_rec.enrt_cvg_strt_dt_cd;
          l_union_set(l_unionele_num).enrt_cvg_strt_dt_rl := l_leersn_rec.enrt_cvg_strt_dt_rl;
          l_union_set(l_unionele_num).enrt_cvg_end_dt_cd  := l_leersn_rec.enrt_cvg_end_dt_cd;
          l_union_set(l_unionele_num).enrt_cvg_end_dt_rl  := l_leersn_rec.enrt_cvg_end_dt_rl;
          l_union_set(l_unionele_num).rt_strt_dt_cd       := l_leersn_rec.rt_strt_dt_cd;
          l_union_set(l_unionele_num).rt_strt_dt_rl       := l_leersn_rec.rt_strt_dt_rl;
          l_union_set(l_unionele_num).rt_end_dt_cd        := l_leersn_rec.rt_end_dt_cd;
          l_union_set(l_unionele_num).rt_end_dt_rl        := l_leersn_rec.rt_end_dt_rl;
          l_unionele_num := l_unionele_num+1;
          --
        end if;
        close c_gleersn_dets;
        --
        if p_plip_row.plip_id is not null
          and (p_plip_row.enrt_cvg_strt_dt_cd is not null
              and p_plip_row.enrt_cvg_end_dt_cd is not null
              and p_plip_row.rt_strt_dt_cd is not null
              and p_plip_row.rt_end_dt_cd is not null
              )
        then
          --
          l_union_set(l_unionele_num).order_number        := 3;
          l_union_set(l_unionele_num).enrt_cvg_strt_dt_cd := p_plip_row.enrt_cvg_strt_dt_cd;
          l_union_set(l_unionele_num).enrt_cvg_strt_dt_rl := p_plip_row.enrt_cvg_strt_dt_rl;
          l_union_set(l_unionele_num).enrt_cvg_end_dt_cd  := p_plip_row.enrt_cvg_end_dt_cd;
          l_union_set(l_unionele_num).enrt_cvg_end_dt_rl  := p_plip_row.enrt_cvg_end_dt_rl;
          l_union_set(l_unionele_num).rt_strt_dt_cd       := p_plip_row.rt_strt_dt_cd;
          l_union_set(l_unionele_num).rt_strt_dt_rl       := p_plip_row.rt_strt_dt_rl;
          l_union_set(l_unionele_num).rt_end_dt_cd        := p_plip_row.rt_end_dt_cd;
          l_union_set(l_unionele_num).rt_end_dt_rl        := p_plip_row.rt_end_dt_rl;
          l_unionele_num := l_unionele_num+1;
          --
        end if;
        --
        if p_pl_row.pl_id is not null
          and (p_pl_row.enrt_cvg_strt_dt_cd is not null
              and p_pl_row.enrt_cvg_end_dt_cd is not null
              and p_pl_row.rt_strt_dt_cd is not null
              and p_pl_row.rt_end_dt_cd is not null
              )
        then
          --
          l_union_set(l_unionele_num).order_number        := 4;
          l_union_set(l_unionele_num).enrt_cvg_strt_dt_cd := p_pl_row.enrt_cvg_strt_dt_cd;
          l_union_set(l_unionele_num).enrt_cvg_strt_dt_rl := p_pl_row.enrt_cvg_strt_dt_rl;
          l_union_set(l_unionele_num).enrt_cvg_end_dt_cd  := p_pl_row.enrt_cvg_end_dt_cd;
          l_union_set(l_unionele_num).enrt_cvg_end_dt_rl  := p_pl_row.enrt_cvg_end_dt_rl;
          l_union_set(l_unionele_num).rt_strt_dt_cd       := p_pl_row.rt_strt_dt_cd;
          l_union_set(l_unionele_num).rt_strt_dt_rl       := p_pl_row.rt_strt_dt_rl;
          l_union_set(l_unionele_num).rt_end_dt_cd        := p_pl_row.rt_end_dt_cd;
          l_union_set(l_unionele_num).rt_end_dt_rl        := p_pl_row.rt_end_dt_rl;
          l_unionele_num := l_unionele_num+1;
          --
        end if;
        --
        if p_ptip_row.ptip_id is not null
          and (p_ptip_row.enrt_cvg_strt_dt_cd is not null
              and p_ptip_row.enrt_cvg_end_dt_cd is not null
              and p_ptip_row.rt_strt_dt_cd is not null
              and p_ptip_row.rt_end_dt_cd is not null
              )
        then
          --
          l_union_set(l_unionele_num).order_number        := 5;
          l_union_set(l_unionele_num).enrt_cvg_strt_dt_cd := p_ptip_row.enrt_cvg_strt_dt_cd;
          l_union_set(l_unionele_num).enrt_cvg_strt_dt_rl := p_ptip_row.enrt_cvg_strt_dt_rl;
          l_union_set(l_unionele_num).enrt_cvg_end_dt_cd  := p_ptip_row.enrt_cvg_end_dt_cd;
          l_union_set(l_unionele_num).enrt_cvg_end_dt_rl  := p_ptip_row.enrt_cvg_end_dt_rl;
          l_union_set(l_unionele_num).rt_strt_dt_cd       := p_ptip_row.rt_strt_dt_cd;
          l_union_set(l_unionele_num).rt_strt_dt_rl       := p_ptip_row.rt_strt_dt_rl;
          l_union_set(l_unionele_num).rt_end_dt_cd        := p_ptip_row.rt_end_dt_cd;
          l_union_set(l_unionele_num).rt_end_dt_rl        := p_ptip_row.rt_end_dt_rl;
          l_unionele_num := l_unionele_num+1;
          --
        end if;
        --
        if p_pgm_row.pgm_id is not null
          and (p_pgm_row.enrt_cvg_strt_dt_cd is not null
              and p_pgm_row.enrt_cvg_end_dt_cd is not null
              and p_pgm_row.rt_strt_dt_cd is not null
              and p_pgm_row.rt_end_dt_cd is not null
              )
        then
          --
          l_union_set(l_unionele_num).order_number        := 6;
          l_union_set(l_unionele_num).enrt_cvg_strt_dt_cd := p_pgm_row.enrt_cvg_strt_dt_cd;
          l_union_set(l_unionele_num).enrt_cvg_strt_dt_rl := p_pgm_row.enrt_cvg_strt_dt_rl;
          l_union_set(l_unionele_num).enrt_cvg_end_dt_cd  := p_pgm_row.enrt_cvg_end_dt_cd;
          l_union_set(l_unionele_num).enrt_cvg_end_dt_rl  := p_pgm_row.enrt_cvg_end_dt_rl;
          l_union_set(l_unionele_num).rt_strt_dt_cd       := p_pgm_row.rt_strt_dt_cd;
          l_union_set(l_unionele_num).rt_strt_dt_rl       := p_pgm_row.rt_strt_dt_rl;
          l_union_set(l_unionele_num).rt_end_dt_cd        := p_pgm_row.rt_end_dt_cd;
          l_union_set(l_unionele_num).rt_end_dt_rl        := p_pgm_row.rt_end_dt_rl;
          l_unionele_num := l_unionele_num+1;
          --
        end if;
        --
        if l_union_set.count > 0 then
          --
          l_found           := TRUE;
          l_unionele_num    := 0;
          l_unionmaxele_num := l_union_set.count-1;
          --
          l_rec.order_number        := l_union_set(l_unionele_num).order_number;
          l_rec.enrt_cvg_strt_dt_cd := l_union_set(l_unionele_num).enrt_cvg_strt_dt_cd;
          l_rec.enrt_cvg_strt_dt_rl := l_union_set(l_unionele_num).enrt_cvg_strt_dt_rl;
          l_rec.enrt_cvg_end_dt_cd  := l_union_set(l_unionele_num).enrt_cvg_end_dt_cd;
          l_rec.enrt_cvg_end_dt_rl  := l_union_set(l_unionele_num).enrt_cvg_end_dt_rl;
          l_rec.rt_strt_dt_cd       := l_union_set(l_unionele_num).rt_strt_dt_cd;
          l_rec.rt_strt_dt_rl       := l_union_set(l_unionele_num).rt_strt_dt_rl;
          l_rec.rt_end_dt_cd        := l_union_set(l_unionele_num).rt_end_dt_cd;
          l_rec.rt_end_dt_rl        := l_union_set(l_unionele_num).rt_end_dt_rl;
          l_unionele_num := l_unionele_num+1;
          --
        else
          --
          l_found := FALSE;
          --
        end if;
        --
if g_debug then
  hr_utility.set_location(' Done Building the union cache l_unionele_num = '||l_unionele_num, 1687);
end if;
      else
        --
        open c_life_for_plip
          (c_effective_date => l_effective_date
          ,c_pgm_id         => l_pgm_id
          ,c_ptip_id        => l_ptip_id
          ,c_pl_id          => l_pl_id
          ,c_plip_id        => l_plip_id
          ,c_lee_rsn_id     => l_lee_rsn_id
          ,c_epfp_id        => l_enrt_perd_for_pl_id
          ,c_per_in_ler_id  => l_per_in_ler_id
          );
if g_debug then
  hr_utility.set_location('Fetching rt start date cd' , 1687);
end if;
        fetch c_life_for_plip into l_rec;
      if g_debug then
        hr_utility.set_location(' Dn Fet c_LFP: '||l_proc , 150);
      end if;
        l_found:=c_life_for_plip%found;
        --
      end if;
      --
    end if;
  else
    if l_enrt_perd_id is not null then
      if g_debug then
        hr_utility.set_location(l_proc , 190);
      end if;
      -- do scheduled pl_nip processing
      open c_sched_for_pl_nip;
      fetch c_sched_for_pl_nip into l_rec;
      l_found:=c_sched_for_pl_nip%found;
    else
      if g_debug then
        hr_utility.set_location(l_proc , 200);
      end if;
      -- do life event pl_nip processing
      -- also used for unrestricted pl_nip
if g_debug then
  hr_utility.set_location(' Doing c_life_for_pl_nip', 1687);
end if;
      open c_life_for_pl_nip;
      fetch c_life_for_pl_nip into l_rec;
      l_found:=c_life_for_pl_nip%found;
    end if;
  end if;
  loop
    if g_debug then
      hr_utility.set_location(l_proc , 240);
    end if;
    exit when l_found = FALSE;
    --
    -- process rates
    --
    if g_debug then
      hr_utility.set_location(l_proc , 250);
    end if;
    if p_which_dates_cd in ('R','B') then
      if l_rt_strt_dt_cd is null and
         l_rec.rt_strt_dt_cd is not null then
      if g_debug then
          hr_utility.set_location(l_proc , 270);
      end if;
        l_rt_strt_dt_cd:=l_rec.rt_strt_dt_cd;
        l_rt_strt_dt_rl:=l_rec.rt_strt_dt_rl;
      end if;
      if l_rt_end_dt_cd is null and
         l_rec.rt_end_dt_cd is not null then
        if g_debug then
          hr_utility.set_location(l_proc , 290);
        end if;
        l_rt_end_dt_cd:=l_rec.rt_end_dt_cd;
        l_rt_end_dt_rl:=l_rec.rt_end_dt_rl;
      end if;
    end if;
    --
    if g_debug then
      hr_utility.set_location(l_proc , 310);
    end if;
    --
    -- process coverage
    --
    if p_which_dates_cd in ('C','B') then
      if l_enrt_cvg_strt_dt_cd is null and
         l_rec.enrt_cvg_strt_dt_cd is not null then
        if g_debug then
          hr_utility.set_location(l_proc , 330);
        end if;
        l_enrt_cvg_strt_dt_cd:=l_rec.enrt_cvg_strt_dt_cd;
        l_enrt_cvg_strt_dt_rl:=l_rec.enrt_cvg_strt_dt_rl;
      end if;
      if l_enrt_cvg_end_dt_cd is null and
         l_rec.enrt_cvg_end_dt_cd is not null then
        if g_debug then
          hr_utility.set_location(l_proc , 350);
        end if;
        l_enrt_cvg_end_dt_cd:=l_rec.enrt_cvg_end_dt_cd;
        l_enrt_cvg_end_dt_rl:=l_rec.enrt_cvg_end_dt_rl;
      end if;
    end if;
    --
    if g_debug then
      hr_utility.set_location(l_proc , 360);
    end if;
    --
    -- determine if done
    --
    if ((p_which_dates_cd ='C' and
         l_enrt_cvg_strt_dt_cd is not null and
         l_enrt_cvg_end_dt_cd is not null) or
        (p_which_dates_cd ='R' and
         l_rt_strt_dt_cd is not null and
         l_rt_end_dt_cd is not null) or
        (p_which_dates_cd ='B' and
         l_enrt_cvg_strt_dt_cd is not null and
         l_enrt_cvg_end_dt_cd is not null and
         l_rt_strt_dt_cd is not null and
         l_rt_end_dt_cd is not null)) then
      if g_debug then
        hr_utility.set_location(l_proc , 380);
      end if;
      l_found:=FALSE;
      l_done:=TRUE;
    else
      if g_debug then
        hr_utility.set_location(l_proc , 390);
      end if;
      --
      -- if not done then get the next row
      --
      if l_pgm_id is not null then
        if l_enrt_perd_id is not null then
          if g_debug then
            hr_utility.set_location(l_proc , 410);
          end if;
          -- do scheduled plip processing
          fetch c_sched_for_plip into l_rec;
          l_found:=c_sched_for_plip%found;
        else
          -- do life event plip processing
          -- also used for unrestricted pl_nip
          if g_debug then
            hr_utility.set_location(' Fet c_LFPLIP: '||l_proc , 420);
          end if;
          if p_pgm_row.pgm_id is not null
            and p_ptip_row.ptip_id is not null
            and p_plip_row.plip_id is not null
            and p_pl_row.pl_id is not null
          then
            --
            l_rec.order_number        := l_union_set(l_unionele_num).order_number;
            l_rec.enrt_cvg_strt_dt_cd := l_union_set(l_unionele_num).enrt_cvg_strt_dt_cd;
            l_rec.enrt_cvg_strt_dt_rl := l_union_set(l_unionele_num).enrt_cvg_strt_dt_rl;
            l_rec.enrt_cvg_end_dt_cd  := l_union_set(l_unionele_num).enrt_cvg_end_dt_cd;
            l_rec.enrt_cvg_end_dt_rl  := l_union_set(l_unionele_num).enrt_cvg_end_dt_rl;
            l_rec.rt_strt_dt_cd       := l_union_set(l_unionele_num).rt_strt_dt_cd;
            l_rec.rt_strt_dt_rl       := l_union_set(l_unionele_num).rt_strt_dt_rl;
            l_rec.rt_end_dt_cd        := l_union_set(l_unionele_num).rt_end_dt_cd;
            l_rec.rt_end_dt_rl        := l_union_set(l_unionele_num).rt_end_dt_rl;
            --
            if l_unionele_num = l_unionmaxele_num then
              --
              l_found := FALSE;
              --
            else
              --
              l_found := TRUE;
              l_unionele_num := l_unionele_num+1;
              --
            end if;
            --
          else
            --
            fetch c_life_for_plip into l_rec;
            l_found:=c_life_for_plip%found;
            --
          end if;
        end if;
      else
        if l_enrt_perd_id is not null then
          if g_debug then
            hr_utility.set_location(l_proc , 460);
          end if;
          -- do scheduled pl_nip processing
          fetch c_sched_for_pl_nip into l_rec;
          l_found:=c_sched_for_pl_nip%found;
        else
          if g_debug then
            hr_utility.set_location(l_proc , 470);
          end if;
          -- do life event pl_nip processing
          -- also used for unrestricted pl_nip
          fetch c_life_for_pl_nip into l_rec;
          l_found:=c_life_for_pl_nip%found;
        end if;
      end if;
    end if;
    if g_debug then
      hr_utility.set_location(' End loop: '||l_proc , 420);
    end if;
  end loop;
  --
  -- close cursors
  --
  if l_pgm_id is not null then
    if l_enrt_perd_id is not null then
      if g_debug then
        hr_utility.set_location(l_proc , 860);
      end if;
      -- do scheduled plip processing
      close c_sched_for_plip;
    else
      if g_debug then
        hr_utility.set_location(l_proc , 870);
      end if;
      -- do life event plip processing
      -- also used for unrestricted plip
      if p_pgm_row.pgm_id is not null
        or p_ptip_row.ptip_id is not null
        or p_plip_row.plip_id is not null
        or p_pl_row.pl_id is not null
      then
        --
        null;
        --
      else
        --
        close c_life_for_plip;
        --
      end if;
      --
    end if;
  else
    if l_enrt_perd_id is not null then
      if g_debug then
        hr_utility.set_location(l_proc , 900);
      end if;
      -- do scheduled pl_nip processing
      close c_sched_for_pl_nip;
    else
      if g_debug then
        hr_utility.set_location(l_proc , 910);
      end if;
      -- do life event pl_nip processing
      -- also used for unrestricted pl_nip
      close c_life_for_pl_nip;
    end if;
  end if;
    --
    -- Bug no 3965571
    --
    open c_pln
          (c_pl_id                => l_pl_id
	  ,c_effective_date => l_effective_date);
     fetch c_pln into l_pln_name;
     close c_pln;
    --
    open c_pgm
          (c_pgm_id             => l_pgm_id
	  ,c_effective_date => l_effective_date);
     fetch c_pgm into l_pgm_name;
     close c_pgm;
     --
    open c_opt
          (c_oipl_id             => l_oipl_id
	  ,c_effective_date => l_effective_date);
          fetch c_opt into l_opt_name;
     close c_opt;

 --  End Bug 3965571

  --
  -- must be done
  --
  if l_done=FALSE then
    if g_debug then
      hr_utility.set_location(l_proc , 530);
    end if;

    -- Bug No 3965571 : All ids are replaced by their names in the error message's tokens.

    if p_which_dates_cd in ('R','B') and
       l_rt_strt_dt_cd is null then
      if g_debug then
        hr_utility.set_location('BEN_91455_RT_STRT_DT_NOT_FOUND' , 540);
      end if;
      fnd_message.set_name('BEN','BEN_91455_RT_STRT_DT_NOT_FOUND');
      fnd_message.set_token('PLAN_ID',l_pln_name);
      fnd_message.set_token('PERSON_ID',to_char(l_person_id));
      fnd_message.set_token('PGM_ID',l_pgm_name);
      fnd_message.set_token('OIPL_ID',l_opt_name);
      fnd_message.raise_error;
    elsif p_which_dates_cd in ('R','B') and
          l_rt_end_dt_cd is null then
      if g_debug then
        hr_utility.set_location('BEN_91703_NOT_DET_RATE_END_DT' , 550);
      end if;
      fnd_message.set_name('BEN','BEN_91703_NOT_DET_RATE_END_DT');
      fnd_message.set_token('PERSON_ID',to_char(l_person_id));
      fnd_message.set_token('PGM_ID',l_pgm_name);
      fnd_message.set_token('PL_ID',l_pln_name);
      fnd_message.set_token('OIPL_ID',l_opt_name);
      fnd_message.raise_error;
    elsif p_which_dates_cd in ('C','B') and
          l_enrt_cvg_strt_dt_cd is null then
      if g_debug then
        hr_utility.set_location('BEN_91453_CVG_STRT_DT_NOT_FOUN' , 560);
      end if;
      fnd_message.set_name('BEN','BEN_91453_CVG_STRT_DT_NOT_FOUN');
      fnd_message.set_token('PERSON_ID',to_char(l_person_id));
      fnd_message.set_token('PGM_ID',l_pgm_name);
      fnd_message.set_token('PLAN_ID',l_pln_name);
      fnd_message.set_token('OIPL_ID',l_opt_name);
      fnd_message.raise_error;
    elsif p_which_dates_cd in ('C','B') and
          l_enrt_cvg_end_dt_cd is null then
      if g_debug then
        hr_utility.set_location(l_proc , 570);
      end if;
      fnd_message.set_name('BEN','BEN_91702_NOT_DET_CVG_END_DT');
      fnd_message.set_token('PERSON_ID',to_char(l_person_id));
      fnd_message.set_token('PGM_ID',l_pgm_name);
      fnd_message.set_token('PL_ID',l_pln_name);
      fnd_message.set_token('OIPL_ID',l_opt_name);
      fnd_message.raise_error;
    end if;
    --
  end if;
  --
  -- If necessary call the date function to get the absolute date
  if p_compute_dates_flag='Y' then
    --
    if (l_enrt_cvg_strt_dt_cd is not NULL) then
      if g_debug then
        hr_utility.set_location(' ECSDCD DETDT_MN '||l_proc , 630);
      end if;
      main
        (p_cache_mode             => p_cache_mode
        ,p_date_cd                => l_enrt_cvg_strt_dt_cd
        ,p_formula_id             => l_enrt_cvg_strt_dt_rl
        ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
        ,p_business_group_id      => p_business_group_id
        ,p_effective_date         => p_effective_date
        ,p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt
        ,p_returned_date          => l_enrt_cvg_strt_dt
        ,p_per_in_ler_id          => l_per_in_ler_id
        ,p_person_id              => l_person_id
        ,p_pgm_id                 => l_pgm_id
        ,p_pl_id                  => l_pl_id
        ,p_oipl_id                => l_oipl_id
        ,p_acty_base_rt_id        => p_acty_base_rt_id
        ,p_start_date             => p_start_date);
    if g_debug then
        hr_utility.set_location(' DN ECSDCD DETDT_MN '||l_proc , 630);
    end if;
    --
    end if;
    --
/*
    -- ikasire - l_enrt_cvg_strt_dt is passed as a parameter for p_start_date
    -- to determinate the cvg end date which depends on cvg strt dt.
    -- Testing Only for 'WALDCSM'
    if l_enrt_cvg_end_dt_cd in ('WALDCSM','LWALDCSM', 'LWALDCM',
                                'LWALDCPP','LWALDCPPY','LWALDLPPEPPY',
                                'LWEM','LWODBED','WAED','WALDCM' ,
                                'WALDCPP','WALDCPPY','WALDLPPEPPY',
                                'WEM','WODBED' )
    then
      hr_utility.set_location('pasing start date '||l_enrt_cvg_strt_dt , 199);
      l_pass_cvg_strt_dt := l_enrt_cvg_strt_dt ;
    else
      l_pass_cvg_strt_dt := p_start_date ;
    end if;
*/
    l_pass_cvg_strt_dt := p_start_date ;
    --
    if (l_enrt_cvg_end_dt_cd is not NULL) then
      hr_utility.set_location(' ECEDCD DETDT_MN '||l_proc , 610);
      main
        (p_cache_mode             => p_cache_mode
        ,p_date_cd                => l_enrt_cvg_end_dt_cd
        ,p_formula_id             => l_enrt_cvg_end_dt_rl
        ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
        ,p_business_group_id      => p_business_group_id
        ,p_effective_date         => p_effective_date
        ,p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt
        ,p_per_in_ler_id          => l_per_in_ler_id
        ,p_person_id              => l_person_id
        ,p_pgm_id                 => l_pgm_id
        ,p_pl_id                  => l_pl_id
        ,p_oipl_id                => l_oipl_id
        ,p_acty_base_rt_id        => p_acty_base_rt_id
        ,p_start_date             => l_pass_cvg_strt_dt
        ,p_returned_date          => l_enrt_cvg_end_dt
        );
    --  hr_utility.set_location(' Dn ECEDCD DETDT_MN '||l_proc , 610);
      --
    end if;
    --

    -- rate start date calcualted before the end date
    if l_rt_strt_dt_cd is not NULL then
      if g_debug then
        hr_utility.set_location(' SDC DETDT_MN '||l_proc , 670);
      end if;
      --
      -- Passing Enrollment coverage
      --
      if l_enrt_cvg_strt_dt is not null then
        --
        l_pass_cvg_strt_dt := l_enrt_cvg_strt_dt ;
        --
      else
        --
        l_pass_cvg_strt_dt := p_start_date ;
        --
      end if;
      --
      main
        (p_cache_mode             => p_cache_mode
        ,p_date_cd                => l_rt_strt_dt_cd
        ,p_formula_id             => l_rt_strt_dt_rl
        ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
        ,p_business_group_id      => p_business_group_id
        ,p_effective_date         => p_effective_date
        ,p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt
        ,p_returned_date          => l_rt_strt_dt
        ,p_per_in_ler_id          => l_per_in_ler_id
        ,p_person_id              => l_person_id
        ,p_pgm_id                 => l_pgm_id
        ,p_pl_id                  => l_pl_id
        ,p_oipl_id                => l_oipl_id
        ,p_acty_base_rt_id        => p_acty_base_rt_id
        ,p_start_date             => l_pass_cvg_strt_dt );

      if g_debug then
        hr_utility.set_location(' rate start date =  '||l_rt_strt_dt , 1687);
      end if;
      if g_debug then
        hr_utility.set_location(' Dn SDC DETDT_MN '||l_proc , 670);
      end if;
      --- assign the fonm rat from the rate so the end date rule can use the fonm value
      if ben_manage_life_events.fonm  = 'Y'  or  l_fonm_cvg_strt_dt is not null then
         if ben_manage_life_events.g_fonm_rt_strt_dt is null or
            ben_manage_life_events.g_fonm_rt_strt_dt <> l_rt_strt_dt then
             ben_manage_life_events.g_fonm_rt_strt_dt :=  l_rt_strt_dt ;
         end if ;
         hr_utility.set_location('FONM gr date  ' ||  ben_manage_life_events.g_fonm_rt_strt_dt  , 60);
      end if ;

    end if;


    if l_rt_end_dt_cd is not NULL then
      -- There are rate end dates that are based on the coverage end date.
      -- Since we haven't updated the result yet, we need to pass the cvg end date
      -- into main.  Bug 1155069.
      if l_enrt_cvg_end_dt is not null then
         l_pass_cvg_end_dt := l_enrt_cvg_end_dt;
      else
         -- otherwise pass in the start date that was passed in to this proc.
         l_pass_cvg_end_dt := p_start_date;
      end if;
      --
      -- Bug 1647095.
      -- The case when coverage end date is enterable, then the actual
      -- coverage end date should come from the api.
      --
      if l_enrt_cvg_end_dt_cd = 'ENTRBL' and p_end_date is not null then
        l_pass_cvg_end_dt := p_end_date;
      end if;
      --
      if g_debug then
        hr_utility.set_location(' EDC DETDT_MN '||l_proc , 650);
      end if;
      main
        (p_cache_mode             => p_cache_mode
        ,p_date_cd                => l_rt_end_dt_cd
        ,p_formula_id             => l_rt_end_dt_rl
        ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
        ,p_business_group_id      => p_business_group_id
        ,p_effective_date         => p_effective_date
        ,p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt
        ,p_returned_date          => l_rt_end_dt
        ,p_per_in_ler_id          => l_per_in_ler_id
        ,p_person_id              => l_person_id
        ,p_pgm_id                 => l_pgm_id
        ,p_pl_id                  => l_pl_id
        ,p_oipl_id                => l_oipl_id
        ,p_acty_base_rt_id        => p_acty_base_rt_id
        ,p_start_date             => l_pass_cvg_end_dt);
      if g_debug then
        hr_utility.set_location(' Dn EDC DETDT_MN '||l_proc , 650);
      end if;

    end if;
    --
    -- rate start date moved above end date to detdermine the fomn_dt_strt_Dt
    -- when calc rt_end_dt_cd



    -- In case of the rate end date codes which depend on rate start date codes
    -- LODBEWM and ODBEWM. Presently rt_end_dt is coming out of a cursor using
    -- ben_enrt_rt table. If rt_strt_dt_cd is stored in that table instead of
    -- rt_strt_dt we get a null . So our plan is to get the rt_end_dt from
    -- rt_strt_dt - 1 , if the above codes are used and the result is null
    --
    if l_rt_end_dt_cd = 'LODBEWM' or l_rt_end_dt_cd = 'ODBEWM'
    then
       --
       if l_rt_end_dt is null
       then
          if g_debug then
            hr_utility.set_location('Special condition for LODBEWM ODBEWM ', 199);
          end if;
          l_rt_end_dt := l_rt_strt_dt - 1 ;
          if g_debug then
            hr_utility.set_location('l_rt_end_dt '||l_rt_end_dt , 199) ;
          end if;
       end if;
       --
    end if;
    --
    if l_rt_strt_dt_cd in ( 'FDSMCFES' , 'FDSMFES' , 'LFMESMES'  )
       and l_rt_strt_dt is NULL
    then
      --
      if l_rt_strt_dt_cd = 'FDSMCFES'
         and to_number(to_char(l_enrt_cvg_strt_dt, 'DD')) in ( 1, 16 )
      then
        --
        l_rt_strt_dt := l_enrt_cvg_strt_dt ;
        if g_debug then
          hr_utility.set_location('Case 1',15);
        end if;
        --
      elsif to_char(l_enrt_cvg_strt_dt, 'DD') > 15 then
        --
        l_rt_strt_dt := round(l_enrt_cvg_strt_dt,'Month')  ;
        if g_debug then
          hr_utility.set_location('Case 2',15);
        end if;
        --
      else
        --
        l_rt_strt_dt := round(l_enrt_cvg_strt_dt,'Month') + 15 ;
        if g_debug then
          hr_utility.set_location('Case 3'||l_enrt_cvg_strt_dt,15);
        end if;

        --
      end if;
      --
    end if;
  --
  end if;

  --
  -- If date is set null out code and rule
  --
  if l_rt_strt_dt is not null and
     (not do_date_at_enrollment(l_rt_strt_dt_cd)) and
     p_date_mandatory_flag='N' then
    if g_debug then
      hr_utility.set_location(l_proc , 700);
    end if;
    l_rt_strt_dt_cd:=null;
    l_rt_strt_dt_rl:=null;
  end if;
  --
  if l_rt_end_dt is not null and
     (not do_date_at_enrollment(l_rt_end_dt_cd)) and
     p_date_mandatory_flag='N' then
    if g_debug then
      hr_utility.set_location(l_proc , 720);
    end if;
    l_rt_end_dt_cd:=null;
    l_rt_end_dt_rl:=null;
  end if;
  --
  if l_enrt_cvg_strt_dt is not null and
     (not do_date_at_enrollment(l_enrt_cvg_strt_dt_cd)) and
     p_date_mandatory_flag='N' then
    if g_debug then
      hr_utility.set_location(l_proc , 740);
    end if;
    l_enrt_cvg_strt_dt_cd:=null;
    l_enrt_cvg_strt_dt_rl:=null;
  end if;
  --
  if l_enrt_cvg_end_dt is not null and
     (not do_date_at_enrollment(l_enrt_cvg_end_dt_cd)) and
     p_date_mandatory_flag ='N' then
    if g_debug then
      hr_utility.set_location(l_proc , 760);
    end if;
    l_enrt_cvg_end_dt_cd:=null;
    l_enrt_cvg_end_dt_rl:=null;
  end if;
  --
  -- if p_date_mandatory_flag is set to Y generate appropriate
  -- message if the hard date is not found.
  -- That is all. Have a happy day.
  --

  if p_date_mandatory_flag='Y' and
     p_compute_dates_flag='Y' then
    if g_debug then
      hr_utility.set_location(l_proc , 780);
    end if;

    -- Bug No 3965571 : All ids are replaced by their names in the error message's tokens.

    if p_which_dates_cd in ('R','B') and
       l_rt_strt_dt is null then
      if g_debug then
        hr_utility.set_location('BEN_91455_RT_STRT_DT_NOT_FOUND',37);
      end if;
      fnd_message.set_name('BEN','BEN_91455_RT_STRT_DT_NOT_FOUND');
      fnd_message.set_token('PLAN_ID',l_pln_name);
      fnd_message.set_token('PERSON_ID',to_char(l_person_id));
      fnd_message.set_token('PGM_ID',l_pgm_name);
      fnd_message.set_token('OIPL_ID',l_opt_name);
      fnd_message.raise_error;
    elsif p_which_dates_cd in ('R','B') and
          l_rt_end_dt is null then
      if g_debug then
        hr_utility.set_location('BEN_91703_NOT_DET_RATE_END_DT',37);
      end if;
      fnd_message.set_name('BEN','BEN_91703_NOT_DET_RATE_END_DT');
      fnd_message.set_token('PERSON_ID',to_char(l_person_id));
      fnd_message.set_token('PGM_ID',l_pgm_name);
      fnd_message.set_token('PL_ID',l_pln_name);
      fnd_message.set_token('OIPL_ID',l_opt_name);
      fnd_message.raise_error;
    elsif p_which_dates_cd in ('C','B') and
        l_enrt_cvg_strt_dt is null then
      if g_debug then
        hr_utility.set_location('BEN_91453_CVG_STRT_DT_NOT_FOUN',37);
      end if;
      fnd_message.set_name('BEN','BEN_91453_CVG_STRT_DT_NOT_FOUN');
      fnd_message.set_token('PERSON_ID',to_char(l_person_id));
      fnd_message.set_token('PGM_ID',l_pgm_name);
      fnd_message.set_token('PLAN_ID',l_pln_name);
      fnd_message.set_token('OIPL_ID',l_opt_name);
      fnd_message.raise_error;
    elsif p_which_dates_cd in ('C','B') and
          l_enrt_cvg_end_dt is null then
      if g_debug then
        hr_utility.set_location('BEN_91702_NOT_DET_CVG_END_DT',37);
      end if;
      fnd_message.set_name('BEN','BEN_91702_NOT_DET_CVG_END_DT');
      fnd_message.set_token('PERSON_ID',to_char(l_person_id));
      fnd_message.set_token('PGM_ID',l_pgm_name);
      fnd_message.set_token('PL_ID',l_pln_name);
      fnd_message.set_token('OIPL_ID',l_opt_name);
      fnd_message.raise_error;
    end if;

  end if;
  --
  -- Move the results back into the out parms
  --
  p_rt_strt_dt:=l_rt_strt_dt;
  p_rt_strt_dt_cd:=l_rt_strt_dt_cd;
  p_rt_strt_dt_rl:=l_rt_strt_dt_rl;
  p_rt_end_dt:=l_rt_end_dt;
  p_rt_end_dt_cd:=l_rt_end_dt_cd;
  p_rt_end_dt_rl:=l_rt_end_dt_rl;
  p_enrt_cvg_strt_dt:=l_enrt_cvg_strt_dt;
  p_enrt_cvg_strt_dt_cd:=l_enrt_cvg_strt_dt_cd;
  p_enrt_cvg_strt_dt_rl:=l_enrt_cvg_strt_dt_rl;
  p_enrt_cvg_end_dt:=l_enrt_cvg_end_dt;
  p_enrt_cvg_end_dt_cd:=l_enrt_cvg_end_dt_cd;
  p_enrt_cvg_end_dt_rl:=l_enrt_cvg_end_dt_rl;
  --
--  hr_utility.set_location(' Leaving:'||l_proc, 930);
--

exception   -- nocopy changes
  --
  when others then
    --
    p_enrt_cvg_strt_dt         := null;
    p_enrt_cvg_strt_dt_cd      := null;
    p_enrt_cvg_strt_dt_rl      := null;
    p_rt_strt_dt               := null;
    p_rt_strt_dt_cd            := null;
    p_rt_strt_dt_rl            := null;
    p_enrt_cvg_end_dt          := null;
    p_enrt_cvg_end_dt_cd       := null;
    p_enrt_cvg_end_dt_rl       := null;
    p_rt_end_dt                := null;
    p_rt_end_dt_cd             := null;
    p_rt_end_dt_rl             := null;
    raise;
    --
end rate_and_coverage_dates;
--
function do_date_at_enrollment(p_date_cd in varchar2) return boolean is
begin
  if p_date_cd in ('ODEWM'
                  , 'LELD'
                  , 'LELDED'
                  , 'ENTRBL'
                  , 'WAENT'
		  , 'ENTRBLFD' -- ICD ENH
                  , 'RL'   --  Bug 2122643
                  , 'LDPPFEFD'
                  , 'LDPPOEFD'
                  , 'FDPPFED'
                  , 'FDPPOED'
                  , 'AFDELD'
                  , 'FDMELD'
                  , 'FDPPFCDEL'
                  , 'FDPPELD'
                  , 'WAPPDEL'
                  ) then
    return true;
  else
    return false;
  end if;
  -- defense
  return true;
end do_date_at_enrollment;
--
procedure rate_and_coverage_dates_nc
  (p_per_in_ler_id          in     number  default null
  ,p_person_id              in     number  default null
  ,p_pgm_id                 in     number  default null
  ,p_pl_id                  in     number  default null
  ,p_oipl_id                in     number  default null
  ,p_par_ptip_id            in     number  default null
  ,p_par_plip_id            in     number  default null
  ,p_lee_rsn_id             in     number  default null
  ,p_enrt_perd_id           in     number  default null
  ,p_enrt_perd_for_pl_id    in     number  default null
  ,p_which_dates_cd         in     varchar2      default 'B'
  ,p_date_mandatory_flag    in     varchar2      default 'Y'
  ,p_compute_dates_flag     in     varchar2      default 'Y'
  ,p_elig_per_elctbl_chc_id in     number  default null
  ,p_acty_base_rt_id        in     number  default null
  ,p_business_group_id      in     number
  ,p_start_date             in     date    default null
  ,p_end_date               in     date    default null
  ,p_effective_date         in     date
  ,p_lf_evt_ocrd_dt         in     date    default null
  ,p_enrt_cvg_strt_dt          out nocopy date
  ,p_enrt_cvg_strt_dt_cd       out nocopy varchar2
  ,p_enrt_cvg_strt_dt_rl       out nocopy number
  ,p_rt_strt_dt                out nocopy date
  ,p_rt_strt_dt_cd             out nocopy varchar2
  ,p_rt_strt_dt_rl             out nocopy number
  ,p_enrt_cvg_end_dt           out nocopy date
  ,p_enrt_cvg_end_dt_cd        out nocopy varchar2
  ,p_enrt_cvg_end_dt_rl        out nocopy number
  ,p_rt_end_dt                 out nocopy date
  ,p_rt_end_dt_cd              out nocopy varchar2
  ,p_rt_end_dt_rl              out nocopy number
  ) is
  begin
    --
    rate_and_coverage_dates
      (p_per_in_ler_id          => p_per_in_ler_id
      ,p_person_id              => p_person_id
      ,p_pgm_id                 => p_pgm_id
      ,p_pl_id                  => p_pl_id
      ,p_oipl_id                => p_oipl_id
      ,p_par_ptip_id            => p_par_ptip_id
      ,p_par_plip_id            => p_par_plip_id
      ,p_lee_rsn_id             => p_lee_rsn_id
      ,p_enrt_perd_id           => p_enrt_perd_id
      ,p_enrt_perd_for_pl_id    => p_enrt_perd_for_pl_id
      ,p_which_dates_cd         =>p_which_dates_cd
      ,p_date_mandatory_flag    => p_date_mandatory_flag
      ,p_compute_dates_flag     => p_compute_dates_flag
      ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
      ,p_acty_base_rt_id        => p_acty_base_rt_id
      ,p_business_group_id      => p_business_group_id
      ,p_start_date             => p_start_date
      ,p_end_date               =>  p_end_date
      ,p_effective_date         => p_effective_date
      ,p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt
      ,p_enrt_cvg_strt_dt       => p_enrt_cvg_strt_dt
      ,p_enrt_cvg_strt_dt_cd     => p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_strt_dt_rl     => p_enrt_cvg_strt_dt_rl
      ,p_rt_strt_dt              => p_rt_strt_dt
      ,p_rt_strt_dt_cd            => p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl            => p_rt_strt_dt_rl
      ,p_enrt_cvg_end_dt          => p_enrt_cvg_end_dt
      ,p_enrt_cvg_end_dt_cd       => p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_end_dt_rl       => p_enrt_cvg_end_dt_rl
      ,p_rt_end_dt                => p_rt_end_dt
      ,p_rt_end_dt_cd             => p_rt_end_dt_cd
      ,p_rt_end_dt_rl             => p_rt_end_dt_rl
   );
  end rate_and_coverage_dates_nc ;
  --
END ben_determine_date;

/
