--------------------------------------------------------
--  DDL for Package Body BEN_USE_CVG_RT_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_USE_CVG_RT_DATE" as
/* $Header: benuscrd.pkb 120.2.12010000.2 2008/09/30 06:22:22 krupani ship $ */
--
/*
+========================================================================+
|             Copyright (c) 1997 Oracle Corporation                      |
|                Redwood Shores, California, USA                         |
|                      All rights reserved.                              |
+========================================================================+
*/
/*
Name
    Manage Life Events
Purpose
        This package is used to check FONM  validation
        benuscrd process.
History
  Date            Who        Version    What?
  ----            ---        -------    -----
  07 Apr 2004     tjesumic   115.0      Created.
  22 Apr 2004     pbodla     115.1      Added procedure fonm_clear_down_cache
  12 May 2004     pbodla     115.2      Some more clear cache routines added.
  13 aug 2004     tjesumic   115.3      fonm dates are intialised
  18 Aug 2004     tjesumic   115.4      ptip_id  parameter added
  20 Aug 2004     tjesumic   115.5      set/get_fonm added , used in BENEDSGB.pld
  17 Nov 2005     mmudigon   115.6      Bug 4731069. Added rtp ch to
                                        fonm_clear_down_cache
  17 Mar 2006     stee       115.7      Bug 5095721 - hints for performance
                                        improvement.
  30-Sep-2008     krupani    115.8      Bug 7374364 - Created
                                        procedure clear_fonm_globals
*/
--------------------------------------------------------------------------------
--
g_package             varchar2(80) := 'ben_use_cvg_rt_date';
g_debug boolean := hr_utility.debug_enabled;
--
--  to  to get whether coverage fonm calc is define or not
procedure get_csd_rsd_Status( p_pgm_id         in number default null
                             ,p_ptip_id        in number default null
                             ,p_plip_id        in number default null
                             ,p_pl_id          in number default null
                             ,p_effective_date in date   default null
                             ,p_status          out nocopy varchar2
                            ) is

  l_package               varchar2(80) := g_package||'.get_csd_rsd_Status';
  l_dummy                 varchar2(1);


  cursor c_pgm is
   select /*+ first_rows(1) */ 'x'  -- 5095721
   from  ben_plip_f  plip
   where plip.pgm_id = p_pgm_id
     and plip.USE_CSD_RSD_PRCCNG_CD is not null
     and plip.plip_stat_cd = 'A'
     and p_effective_date between plip.effective_start_date
         and plip.effective_end_date
     and rownum = 1  -- 5095721
     ;

   cursor c_ptip is
   select /*+ first_rows(1) */ 'x' -- 5095721
   from  ben_plip_f  plip, ben_ptip_f ptip, ben_pl_f pl
   where ptip.ptip_id  =  p_ptip_id
     and ptip.pgm_id   =  plip.pgm_id
     and plip.pl_id    =  pl.pl_id
     and pl.pl_typ_id  =  ptip.pl_typ_id
     and plip.USE_CSD_RSD_PRCCNG_CD is not null
     and plip.plip_stat_cd = 'A'
     and ptip.ptip_stat_cd = 'A'
     and p_effective_date between ptip.effective_start_date
         and ptip.effective_end_date
     and p_effective_date between pl.effective_start_date
         and pl.effective_end_date
     and p_effective_date between plip.effective_start_date
         and plip.effective_end_date
     and rownum = 1 -- 5095721
     ;

   cursor c_plip is
   select 'x'
   from  ben_plip_f  plip
   where plip.plip_id = p_plip_id
     and plip.USE_CSD_RSD_PRCCNG_CD is not null
     and plip.plip_stat_cd = 'A'
     and p_effective_date between plip.effective_start_date
         and plip.effective_end_date
     and rownum = 1; -- 5095721


    cursor c_pl is
   select 'x'
   from  ben_pl_f  pl
   where pl.pl_id = p_pl_id
     and pl.USE_CSD_RSD_PRCCNG_CD is not null
     and pl.pl_stat_cd = 'A'
     and p_effective_date between pl.effective_start_date
         and pl.effective_end_date
     and rownum = 1; -- 5095721

Begin
   g_debug := hr_utility.debug_enabled;
   if g_debug then
    hr_utility.set_location ('Entering '||l_package,10);
    hr_utility.set_location ('p_plip_id '||p_plip_id,10);
    hr_utility.set_location ('p_pl_id '||p_pl_id,10);
    hr_utility.set_location ('p_pgm_id '||p_pgm_id,10);

  end if;
  -- initalise the global
  ben_manage_life_events.g_fonm_cvg_strt_dt := null ;
  ben_manage_life_events.g_fonm_rt_strt_dt := null ;
  --
   p_status := 'N' ;
   if p_plip_id is not null then
      open c_plip  ;
      fetch c_plip into l_dummy  ;
      if c_plip%found then
         p_status := 'Y' ;
      end if ;
      close c_plip ;

   elsif p_ptip_id is not null then
      open c_ptip ;
      fetch c_ptip into l_dummy ;
      if c_ptip%found then
         p_status := 'Y' ;
      end if ;
      close c_ptip ;


   elsif p_pgm_id is not null then
      open c_pgm ;
      fetch c_pgm into l_dummy ;
      if c_pgm%found then
         p_status := 'Y' ;
      end if ;
      close c_pgm ;
   elsif p_pl_id is not null  then
      open c_pl ;
      fetch c_pl into l_dummy ;
      if c_pl%found then
         p_status := 'Y' ;
      end if ;
      close c_pl ;
   end if ;

   if g_debug then

    hr_utility.set_location ('status '||p_status,10);
    hr_utility.set_location ('Leaving '||l_package,10);
   end if;

End ;
--
-- This procedure should only be called in fonm mode when the dates are
-- changed between the processing of comp objects.
--
procedure fonm_clear_down_cache is
 --
 --
begin
 --
 ben_person_object.clear_down_cache;
 ben_evaluate_rate_profiles.init_globals;
 ben_rt_prfl_cache.clear_down_cache;
 ben_elp_cache.clear_down_cache;
 ben_cep_cache.clear_down_cache;
 ben_elig_rl_cache.clear_down_cache;
 ben_rtp_cache.clear_down_cache;
 --
 -- 9999 look at the some of the cache clears from list below.
 -- DO NOT UNCOMMENT , ANY SPECIFIC CLEAR CACHE NEEDED MOVE IT OUT OF
 -- COMMENT.
 --
 /*
  ben_person_object.defrag_caches;
  ben_epe_cache.init_context_cobj_pileperow;
  ben_epe_cache.init_context_pileperow ;
  ben_epe_cache.clear_down_cache;
  ben_cobj_cache.clear_down_cache;
  ben_comp_object.clear_down_cache;
  ben_elig_object.clear_down_cache;
  ben_seeddata_object.clear_down_cache;
  ben_manage_life_events.g_cache_person_prtn.delete;
  ben_derive_part_and_rate_cache.clear_down_cache;
  ben_derive_prt_and_rate_cache1.clear_down_cache;
  ben_derive_part_and_rate_facts.clear_down_cache;
  ben_derive_part_and_rate_cvg.clear_down_cache;
  ben_derive_part_and_rate_prem.clear_down_cache;
  ben_cel_cache.clear_down_cache;
  ben_org_object.clear_down_cache;
  --
  ben_life_object.clear_down_cache;
  ben_location_object.clear_down_cache;
  ben_org_object.clear_down_cache;
  --
  ben_letrg_cache.clear_down_cache;
  ben_cagrelp_cache.clear_down_cache;

  -- from clear_enroll_caches
  ben_batch_dt_api.clear_down_cache;
  ben_element_entry.clear_down_cache;

  ben_cop_cache.clear_down_cache;
  ben_pep_cache.clear_down_cache;
  ben_distribute_rates.clear_down_cache;
  ben_pil_cache.clear_down_cache;
  ben_pln_cache.clear_down_cache;
  ben_saz_cache.clear_down_cache;
  ben_seeddata_object.clear_down_cache;
  benutils.clear_down_cache;
  ben_pil_object.clear_down_cache;
  ben_rt_asnt_cache.clear_down_cache;

 */
 --
end fonm_clear_down_cache;
--

procedure get_fonm (p_fonm               out nocopy varchar2 ,
                    p_fonm_cvg_strt_dt   out nocopy  date ,
                    p_fonm_rt_strt_dt    out nocopy  date
                   ) is

l_proc  varchar2(400) :=  g_package||'.get_fonm' ;
begin

  if g_debug then
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;

  p_fonm := ben_manage_life_events.fonm ;
  p_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
  p_fonm_rt_strt_dt := ben_manage_life_events.g_fonm_rt_strt_dt ;


  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc,10);
   end if;

end  get_fonm ;

procedure set_fonm (p_fonm               in varchar2 ,
                    p_fonm_cvg_strt_dt   in date default null ,
                    p_fonm_rt_strt_dt    in date default null
                   ) is

l_proc  varchar2(400) :=  g_package||'.set_fonm' ;
begin

  if g_debug then
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;

 ben_manage_life_events.fonm := p_fonm ;
 if p_fonm  = 'N'  then
     ben_manage_life_events.g_fonm_cvg_strt_dt := null ;
     ben_manage_life_events.g_fonm_rt_strt_dt  := null ;
 else
     if p_fonm_cvg_strt_dt is not null then
        ben_manage_life_events.g_fonm_cvg_strt_dt := p_fonm_cvg_strt_dt ;
    end if ;

    if p_fonm_rt_strt_dt is not null then
       ben_manage_life_events.g_fonm_rt_strt_dt := p_fonm_rt_strt_dt ;
    end if ;

 end if ;


  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc,10);
  end if;
end set_fonm ;

procedure clear_fonm_globals is
 --
l_proc  varchar2(400) :=  g_package||'.clear_fonm_globals';

begin
--
  hr_utility.set_location ('Entering '||l_proc,10);

  ben_manage_life_events.fonm := null ;
  ben_manage_life_events.g_fonm_cvg_strt_dt := null ;
  ben_manage_life_events.g_fonm_rt_strt_dt := null;

  hr_utility.set_location ('Leaving '||l_proc,10);
--
end clear_fonm_globals;

end ben_use_cvg_rt_date;

/
