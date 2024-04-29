--------------------------------------------------------
--  DDL for Package Body BEN_CWB_XCHG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_XCHG_PKG" as
/* $Header: bencwbxchg.pkb 120.8.12000000.1 2007/01/19 15:39:41 appldev noship $ */
--
-- --------------------------------------------------------------------------
-- |                     Private Global Definitions                         |
-- --------------------------------------------------------------------------
--
g_package varchar2(33):='  ben_cwb_xchg_pkb.'; --Global package name
g_debug boolean := hr_utility.debug_enabled;
g_xchg_not_found varchar2(1) := 'N';           --global var to chk xchg rate
-- --------------------------------------------------------------------------
-- |----------------------< insert_into_ben_cwb_xchg >----------------------|
-- --------------------------------------------------------------------------
-- Description
-- This procedure inserts currency records in the the ben_cwb_xchg table on
-- participation process run as well on refresh.
-- Input parameters
--  p_group_pl_id    : Group Plan Id
--  p_lf_evt_ocrd_dt : Life Event Occured Date
--  p_effective_date : Effective Date
--  p_refresh_always : Refresh Always flag
procedure insert_into_ben_cwb_xchg(p_group_pl_id    IN number,
                                   p_lf_evt_ocrd_dt IN date,
                                   p_effective_date IN date,
                                   p_refresh_always IN varchar2 default 'N',
                                   p_currency IN varchar2 default null,
                                   p_xchg_rate IN number default null) IS
   --
   -- cursor for fetching Bg_ID, Effective_Date and Pl_UOM for exchange rate Calculation
   cursor csr_pl_dsgn_recs(p_group_pl_id number,
                           p_lf_evt_ocrd_dt date,
                           p_effective_date date) is
   select pl_uom
         ,nvl(p_effective_date, nvl(data_freeze_date, lf_evt_ocrd_dt))
         ,business_group_id
   from  ben_cwb_pl_dsgn
   where pl_id          = p_group_pl_id
   and   lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
   and   oipl_id        = -1;

   --
   -- cursor to fetch the records from person_info and rates where personId is -1
   cursor csr_xchg_recs_bm(p_group_pl_id number, p_lf_evt_ocrd_dt date) is
   select distinct base_salary_currency lCurrency
     from ben_cwb_person_info
    where group_pl_id    =  p_group_pl_id
    and   lf_evt_ocrd_dt =  p_lf_evt_ocrd_dt
    and   person_id      =  -1
    and   base_salary_currency is not null

   UNION
   select distinct salary_1_year_ago_currency lCurrency
     from ben_cwb_person_info
    where group_pl_id    =  p_group_pl_id
    and   lf_evt_ocrd_dt =  p_lf_evt_ocrd_dt
    and   person_id      =  -1
    and   salary_1_year_ago_currency is not null

   UNION
   select distinct salary_2_year_ago_currency lCurrency
     from ben_cwb_person_info
    where group_pl_id    =  p_group_pl_id
    and   lf_evt_ocrd_dt =  p_lf_evt_ocrd_dt
    and   person_id      =  -1
    and   salary_2_year_ago_currency is not null

   UNION
   select distinct salary_3_year_ago_currency lCurrency
     from ben_cwb_person_info
    where group_pl_id    =  p_group_pl_id
    and   lf_evt_ocrd_dt =  p_lf_evt_ocrd_dt
    and   person_id      =  -1
    and   salary_3_year_ago_currency is not null

   UNION
   select distinct salary_4_year_ago_currency lCurrency
     from ben_cwb_person_info
    where group_pl_id    =  p_group_pl_id
    and   lf_evt_ocrd_dt =  p_lf_evt_ocrd_dt
    and   person_id      =  -1
    and   salary_4_year_ago_currency is not null

   UNION
   select distinct salary_5_year_ago_currency lCurrency
     from ben_cwb_person_info
    where group_pl_id    =  p_group_pl_id
    and   lf_evt_ocrd_dt =  p_lf_evt_ocrd_dt
    and   person_id      =  -1
    and   salary_5_year_ago_currency is not null

   UNION
   select distinct mkt_currency lCurrency
     from ben_cwb_person_info
    where group_pl_id    =  p_group_pl_id
    and   lf_evt_ocrd_dt =  p_lf_evt_ocrd_dt
    and   person_id      =  -1
    and   mkt_currency is not null

   UNION
   select distinct prev_sal_currency lCurrency
     from ben_cwb_person_info
    where group_pl_id    =  p_group_pl_id
    and   lf_evt_ocrd_dt =  p_lf_evt_ocrd_dt
    and   person_id      =  -1
    and   prev_sal_currency is not null

   UNION

   select distinct cpr.currency lCurrency
     from ben_cwb_person_rates cpr
         ,ben_cwb_person_info  cpi
    where cpr.group_per_in_ler_id =  cpi.group_per_in_ler_id
    and   cpi.lf_evt_ocrd_dt =  p_lf_evt_ocrd_dt
    and   cpi.group_pl_id    =  p_group_pl_id
    and   cpi.person_id      =  -1
    and   cpr.currency is not null;

   --
   -- cursor to fetch the records from person_info and rates
   -- for refresh
   cursor csr_xchg_recs_rf(p_group_pl_id number, p_lf_evt_ocrd_dt date) is
   select distinct base_salary_currency lCurrency
     from ben_cwb_person_info
    where group_pl_id    =  p_group_pl_id
      and lf_evt_ocrd_dt =  p_lf_evt_ocrd_dt
      and base_salary_currency is not null

   UNION

   select distinct cpr.currency lCurrency
     from ben_cwb_person_rates cpr
    where cpr.group_pl_id    =  p_group_pl_id
      and cpr.lf_evt_ocrd_dt =  p_lf_evt_ocrd_dt
      and cpr.currency is not null

   UNION
   select distinct salary_1_year_ago_currency lCurrency
     from ben_cwb_person_info
    where group_pl_id    =  p_group_pl_id
    and   lf_evt_ocrd_dt =  p_lf_evt_ocrd_dt
    and   salary_1_year_ago_currency is not null

   UNION
   select distinct salary_2_year_ago_currency lCurrency
     from ben_cwb_person_info
    where group_pl_id    =  p_group_pl_id
    and   lf_evt_ocrd_dt =  p_lf_evt_ocrd_dt
    and   salary_2_year_ago_currency is not null

   UNION
   select distinct salary_3_year_ago_currency lCurrency
     from ben_cwb_person_info
    where group_pl_id    =  p_group_pl_id
    and   lf_evt_ocrd_dt =  p_lf_evt_ocrd_dt
    and   salary_3_year_ago_currency is not null

   UNION
   select distinct salary_4_year_ago_currency lCurrency
     from ben_cwb_person_info
    where group_pl_id    =  p_group_pl_id
    and   lf_evt_ocrd_dt =  p_lf_evt_ocrd_dt
    and   salary_4_year_ago_currency is not null

   UNION
   select distinct salary_5_year_ago_currency lCurrency
     from ben_cwb_person_info
    where group_pl_id    =  p_group_pl_id
    and   lf_evt_ocrd_dt =  p_lf_evt_ocrd_dt
    and   salary_5_year_ago_currency is not null

   UNION
   select distinct mkt_currency lCurrency
     from ben_cwb_person_info
    where group_pl_id    =  p_group_pl_id
    and   lf_evt_ocrd_dt =  p_lf_evt_ocrd_dt
    and   mkt_currency is not null

   UNION
   select distinct prev_sal_currency lCurrency
     from ben_cwb_person_info
    where group_pl_id    =  p_group_pl_id
    and   lf_evt_ocrd_dt =  p_lf_evt_ocrd_dt
    and   prev_sal_currency is not null;

   --
   l_pl_uom varchar2(30);
   --
   l_effective_date date;
   --
   l_bg_id number(15, 0);
   --
   l_currency varchar2(30);
   --
   l_xchg_rate number;
   --
   l_xchg_rec ben_cwb_xchg%rowtype;
   --
   l_proc     varchar2(72) := g_package||'insert_into_ben_cwb_xchg';
   --
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   -- for the group_plan record

   open csr_pl_dsgn_recs(p_group_pl_id, p_lf_evt_ocrd_dt, p_effective_date);
     fetch csr_pl_dsgn_recs into l_pl_uom, l_effective_date, l_bg_id;
   close csr_pl_dsgn_recs;

   --
   -- check for refresh
   if p_refresh_always = 'Y' then
     --
     if g_debug then
       hr_utility.set_location('l_proc'|| l_proc, 20);
     end if;
     --
     delete from ben_cwb_xchg
      where  group_pl_id    = p_group_pl_id
      and    lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;
     --
     for xchg_rec in csr_xchg_recs_rf(p_group_pl_id, p_lf_evt_ocrd_dt) loop
      --
      if g_debug then
         hr_utility.set_location(l_proc, 25);
      end if;
      --
      l_xchg_rec.currency       := xchg_rec.lCurrency;
      l_xchg_rec.group_pl_id    := p_group_pl_id;
      l_xchg_rec.lf_evt_ocrd_dt := p_lf_evt_ocrd_dt;
      l_xchg_rec.xchg_rate      := ben_cwb_pl_dsgn_pkg.get_exchg_rate(l_pl_uom
                       						     ,xchg_rec.lCurrency
                       						     ,l_effective_date
                       						     ,l_bg_id);
      --check for rate to be null
      if l_xchg_rec.xchg_rate is null then
         g_xchg_not_found := 'Y';
      end if;

      --for each new currency records
	  insert into ben_cwb_xchg(
                      group_pl_id
                     ,lf_evt_ocrd_dt
                     ,currency
                     ,xchg_rate)
             values(
                      l_xchg_rec.group_pl_id
                     ,l_xchg_rec.lf_evt_ocrd_dt
                     ,l_xchg_rec.currency
                     ,l_xchg_rec.xchg_rate
                   );
     end loop;
   elsif p_refresh_always = 'N' then
     --when refresh is N
     if g_debug then
       hr_utility.set_location('l_proc'|| l_proc, 30);
     end if;
     --
     ben_manage_cwb_life_events.g_error_log_rec.calling_proc :=
                      'Before xchg cursor';
     ben_manage_cwb_life_events.g_error_log_rec.step_number := 61;
     --
     for xchg_rec in csr_xchg_recs_bm(p_group_pl_id, p_lf_evt_ocrd_dt) loop
      --
      if g_debug then
         hr_utility.set_location(l_proc, 35);
      end if;
      --
      l_xchg_rec.currency       := xchg_rec.lCurrency;
      l_xchg_rec.group_pl_id    := p_group_pl_id;
      l_xchg_rec.lf_evt_ocrd_dt := p_lf_evt_ocrd_dt;
      l_xchg_rec.xchg_rate      := ben_cwb_pl_dsgn_pkg.get_exchg_rate(l_pl_uom
                       						     ,xchg_rec.lCurrency
                       						     ,l_effective_date
                       						     ,l_bg_id);
      --
      --for each new currency records
       begin
	  insert into ben_cwb_xchg(
                      group_pl_id
                     ,lf_evt_ocrd_dt
                     ,currency
                     ,xchg_rate)
             values(
                      l_xchg_rec.group_pl_id
                     ,l_xchg_rec.lf_evt_ocrd_dt
                     ,l_xchg_rec.currency
                     ,l_xchg_rec.xchg_rate
                   );
       exception
         when others then
           null;
       end;
     end loop;
     ben_manage_cwb_life_events.g_error_log_rec.calling_proc :=
                      'After xchg cursor';
     ben_manage_cwb_life_events.g_error_log_rec.step_number := 62;
   --
   elsif p_currency is not null then
   --
     --Insert a new exchg rate defined through plan Admin
     l_currency := p_currency;
     l_xchg_rate := p_xchg_rate;
     --
     if g_debug then
       hr_utility.set_location('l_proc'|| l_proc, 40);
     end if;

     --
     --if currency already exists
     begin
      delete from ben_cwb_xchg
      where  group_pl_id    = p_group_pl_id
      and    lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
      and    currency = l_currency;
     exception
      when others then
           null;
     end;

     --
     --for each new currency record
     begin
	  insert into ben_cwb_xchg(
                      group_pl_id
                     ,lf_evt_ocrd_dt
                     ,currency
                     ,xchg_rate)
             values(
                      p_group_pl_id
                     ,p_lf_evt_ocrd_dt
                     ,l_currency
                     ,l_xchg_rate
                   );
      exception
       when others then
           null;
       end;

   end if;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
end; -- of procedure insert_into_ben_cwb_xchg
--
--
-- --------------------------------------------------------------------------
-- |---------------------------< refresh_xchg_rates >-----------------------|
-- --------------------------------------------------------------------------
-- Description
-- This procedure will refresh the exchange rates in ben_cwb_xchg table on
-- a given effective date, and, return p_all_xchg_rt_exists as 'N' for any
-- rates found to be null.
-- Input parameters
--  p_group_pl_id        : Group Plan Id
--  p_lf_evt_ocrd_dt     : Life Event Occured Date
--  p_effective_date     : Effective Date
--  p_refresh_always     : Refresh Always flag
--  p_all_xchg_rt_exists : All Exchange Rates Exists
--
procedure refresh_xchg_rates(p_group_pl_id    IN number,
                             p_lf_evt_ocrd_dt IN date,
			     p_effective_date IN date,
			     p_refresh_always IN varchar2 default 'N',
                             p_all_xchg_rt_exists IN OUT NOCOPY varchar2) IS
  l_proc     varchar2(72) := g_package||'refresh_xchg_rates';
begin
  --
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --

  --resetting value of global var
  g_xchg_not_found := 'N';
  --

  --Calling procedure to refresh exchg rates
  insert_into_ben_cwb_xchg(p_group_pl_id   ,
                           p_lf_evt_ocrd_dt,
   			   p_effective_date,
			   p_refresh_always,
                           null ,
                           null);

  --
  if g_debug then
      hr_utility.set_location('l_proc'|| l_proc, 20);
  end if;
  --

  --Check for any null exchg rate returned
  if g_xchg_not_found = 'Y' then
     p_all_xchg_rt_exists := 'N';
  end if;
  --

  --
  if g_debug then
     hr_utility.set_location('Leaving:'|| l_proc, 99);
  end if;
  --
end; -- of procedure refresh_xchg_rates
end BEN_CWB_XCHG_PKG;


/
