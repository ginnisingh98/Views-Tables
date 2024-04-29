--------------------------------------------------------
--  DDL for Package Body BEN_PEP_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PEP_CACHE" as
/* $Header: benpepch.pkb 120.3 2005/10/21 01:58:44 abparekh noship $ */
--
/*
+==============================================================================+
|			 Copyright (c) 1997 Oracle Corporation		       |
|			    Redwood Shores, California, USA		       |
|				All rights reserved.			       |
+==============================================================================+
--
History
  Version    Date	Author	   Comments
  ---------  ---------	---------- --------------------------------------------
  115.0      28-Jun-99	mhoyes     Created.
  115.1      14-Sep-00	mhoyes     Upgraded caching.
  115.3      15-Nov-00	mhoyes   - Initialized record in exceptions on a get
                                   to cover when no rows exist.
  115.4      03-Jul-01	tmathers   9i complaince removed unused nulls
                                   from c_instance.
  115.5      11-Dec-01	mhoyes   - Added get_pilplnpep_dets.
  115.6      17-Apr-02	pbodla   - 2327832 : Modified the cursor
                                   write_pilepo_cache to join epo rec to pil
                                   rec to avoid fetching voided and backed out
                                   epo rows.
  115.7      17-Apr-02	pbodla   - Added lines for GSCC compliance.
  115.8      05-Jul-02	mhoyes   - SQL tuning in get_pilplnpep_dets.
  115.9      12-Jul-02  mhoyes   - Added get_curroiplippep_dets and
                                   get_currplnpep_dets.
  115.10     16-Jul-02  mhoyes   - Fixed oipl electability problem introduced
                                   in 115.8.
  115.11     28-Jul-02  mhoyes   - Added back in join to ben_per_in_ler for
                                   voided and backed out life events in
                                   get_pilplnpep_dets.
  115.12     20-Aug-02  mhoyes   - Added caching into get_currpepepo_dets based
                                   on comp object list row values.
                                 - Fixed compliance error on defaulted
                                   parameters.
  115.13     17-Mar-03  vsethi   - Bug 2650247 added inelg_rsn_cd to get_currpepepo_dets
  115.14     15-Feb-04  mhoyes   - Revamped write_pilpep_cache and
                                   write_pilepo_cache to use bulk collects.
                                 - Spilt cursor in write_pilepo_cache.
  115.14     18-Feb-04  mhoyes   - Bug 3412822. Revamp of eligibility cache.
  115.15     06-Apr-04  mhoyes   - Bug 3412822. Revamp of eligibility cache.
  115.17     14-Apr-04  mhoyes   - Bug 3506360. Scaleability tuning of EPO
                                   cache.
  115.18     20-Apr-04  rpgupta  - Bug 3575396. Cache is not written if per in ler
  				   is in started status.
  115.19     27-Apr-04  mhoyes   - Bug 3506360. More scaleability tuning of EPO
                                   cache. Added get_peppil_list.
  115.20     28-Apr-04  ikasire  - Bug 3550789 creating duplicate EPO rows
  115.20.1   13-Oct-04  mhoyes   - Bug 3950924. Added get_pilepo_dets11521.
                                 - Backed out functional change in 115.20.
                                 - Applied bind peeking tuning.
  115.22     08-Nov-04  mhoyes   - Bug 3967078. Made 115.20.11591.2 version
                                   115.22.
                                 - Backed out functional change 3550789
                                   made in 115.20.
                                 - Applied bind peeking tuning.
  115.23     02-May-05  mhoyes   - Bug 4345064. Tuned cursor c_pilpepexists
                                   by adding rownum=1 to minimize excessive
                                   logical reads.
  115.24     04-May-05  mhoyes   - Bug 4350303. Backed out nocopy due to
                                   performance regression.
  115.25     06-May-05  mhoyes   - Bug 4350303. Bypassed call to hash function
                                   ben_hash_utility.get_hashed_index.
                                 - Removed obsolete procedures.
  115.26     30-May-05  mhoyes   - Bug 4400538. Moved local procedures out to
                                   ben_pep_cache2.
  115.27     12-jun-05  mhoyes   - Bug 4425771. Defined package locals as
                                   globals.
  115.28     20-Oct-05  abparekh - Bug 4646361 : Added NOCOPY hint to out parameters
  -----------------------------------------------------------------------------
*/
--
procedure get_pilpep_dets
  (p_person_id         in     number
  ,p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_pgm_id            in     number default null
  ,p_ptip_id           in     number default null
  ,p_pl_id             in     number default null
  ,p_plip_id           in     number default null
  ,p_date_sync         in     boolean default false
--  ,p_inst_row          in out NOCOPY ben_derive_part_and_rate_facts.g_cache_structure
  ,p_inst_row             out nocopy ben_derive_part_and_rate_facts.g_cache_structure
  )
is
  --
  l_proc varchar2(72) :=  'get_pilpep_dets';
  --
  l_hv               pls_integer;
  l_reset            ben_derive_part_and_rate_facts.g_cache_structure;
  --
begin
  --
  if p_date_sync
  then
    --
    -- Check if the passed in effective date matches the cached effective date
    --
    if nvl(g_pilpep_effdt,hr_api.g_sot) = p_effective_date
      and nvl(g_pilpep_personid,-9999999) = p_person_id
    then
      --
      null;
      --
    else
      --
      ben_pep_cache.clear_down_pepcache;
      g_pilpep_cached := false;
      --
    end if;
    --
  end if;
  --
  if not g_pilpep_cached
  then
    --
    -- Build the cache
    --
    ben_pep_cache2.write_pilpep_cache
      (p_person_id         => p_person_id
      ,p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      );
    --
    g_pilpep_cached   := TRUE;
    g_pilpep_effdt    := p_effective_date;
    g_pilpep_personid := p_person_id;
    --
  end if;
  --
  -- Get the hashed value
  -- Bug 4350303
  l_hv := mod(nvl(p_pgm_id,1)+nvl(p_pl_id,2)+nvl(p_plip_id,3)
              +nvl(p_ptip_id,4),g_hash_key);
--  l_hv := ben_hash_utility.get_hashed_index(p_id => nvl(p_pgm_id,1)+nvl(p_pl_id,2)
--  +nvl(p_plip_id,3)+nvl(p_ptip_id,4));
  -- Bug 4350303
  --
  -- Check the pgm and pl combination is correct
  --
  if nvl(g_pilpep_instance(l_hv).pgm_id,-1)     = nvl(p_pgm_id,-1)
    and nvl(g_pilpep_instance(l_hv).pl_id,-1)   = nvl(p_pl_id,-1)
    and nvl(g_pilpep_instance(l_hv).plip_id,-1) = nvl(p_plip_id,-1)
    and nvl(g_pilpep_instance(l_hv).ptip_id,-1) = nvl(p_ptip_id,-1)
  then
    --
    null;
    --
  else
    --
    l_hv := l_hv+g_hash_jump;
    --
    loop
      --
      if nvl(g_pilpep_instance(l_hv).pgm_id,-1)     = nvl(p_pgm_id,-1)
        and nvl(g_pilpep_instance(l_hv).pl_id,-1)   = nvl(p_pl_id,-1)
        and nvl(g_pilpep_instance(l_hv).plip_id,-1) = nvl(p_plip_id,-1)
        and nvl(g_pilpep_instance(l_hv).ptip_id,-1) = nvl(p_ptip_id,-1)
      then
        --
        exit;
        --
      else
        --
        l_hv := l_hv+g_hash_jump;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  p_inst_row := g_pilpep_instance(l_hv);
  --
exception
  --
  when no_data_found then
    --
--    p_inst_row := l_reset;
    null;
    --
end get_pilpep_dets;
--
procedure get_pilepo_dets
  (p_person_id         in     number
  ,p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_pgm_id            in     number default null
  ,p_pl_id             in     number default null
  ,p_opt_id            in     number default null
  ,p_plip_id           in     number default null
  ,p_date_sync         in     boolean default false
--  ,p_inst_row          in out NOCOPY ben_derive_part_and_rate_facts.g_cache_structure
  ,p_inst_row             out nocopy ben_derive_part_and_rate_facts.g_cache_structure
  )
is
  --
  l_proc varchar2(72) :=  'get_pilepo_dets';
  --
  l_hv               pls_integer;
  l_reset            ben_derive_part_and_rate_facts.g_cache_structure;
  --
begin
  --
  if p_date_sync
  then
    --
    -- Check if the passed in effective date matches the cached effective date
    --
    if nvl(g_optpilepo_effdt,hr_api.g_sot) = p_effective_date
      and nvl(g_optpilepo_personid,-9999999) = p_person_id
    then
      --
      null;
      --
    else
      --
      ben_pep_cache.clear_down_epocache;
      g_optpilepo_cached := false;
      --
    end if;
    --
  end if;
  --
  if not g_optpilepo_cached
  then
    --
    -- Build the cache
    --
    ben_pep_cache2.write_pilepo_cache
      (p_person_id         => p_person_id
      ,p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      );
    --
    g_optpilepo_cached   := TRUE;
    g_optpilepo_effdt    := p_effective_date;
    g_optpilepo_personid := p_person_id;
    --
  end if;
  --
  -- Get the instance details
  --
  -- Bug 4350303
  l_hv := mod(nvl(p_opt_id,1)+nvl(p_pgm_id,2)+nvl(p_pl_id,3)
          +nvl(p_plip_id,4),g_hash_key);
--  l_hv := ben_hash_utility.get_hashed_index(p_id => nvl(p_opt_id,1)+nvl(p_pgm_id,2)
--  +nvl(p_pl_id,3)+nvl(p_plip_id,4));
  -- Bug 4350303
  --
  -- Check the pgm and pl combination is correct
  --
  if nvl(g_optpilepo_instance(l_hv).pgm_id,-1)     = nvl(p_pgm_id,-1)
    and nvl(g_optpilepo_instance(l_hv).pl_id,-1)   = nvl(p_pl_id,-1)
    and nvl(g_optpilepo_instance(l_hv).plip_id,-1) = nvl(p_plip_id,-1)
    and nvl(g_optpilepo_instance(l_hv).opt_id,-1)  = nvl(p_opt_id,-1)
  then
    --
    null;
    --
  else
    --
    l_hv := l_hv+g_hash_jump;
    --
    loop
      --
      if nvl(g_optpilepo_instance(l_hv).pgm_id,-1)     = nvl(p_pgm_id,-1)
        and nvl(g_optpilepo_instance(l_hv).pl_id,-1)   = nvl(p_pl_id,-1)
        and nvl(g_optpilepo_instance(l_hv).plip_id,-1) = nvl(p_plip_id,-1)
        and nvl(g_optpilepo_instance(l_hv).opt_id,-1)  = nvl(p_opt_id,-1)
      then
        --
        exit;
        --
      else
        --
        l_hv := l_hv+g_hash_jump;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  p_inst_row := g_optpilepo_instance(l_hv);
  --
exception
  --
  when no_data_found then
    --
--    p_inst_row := l_reset;
    null;
    --
end get_pilepo_dets;
--
procedure get_currpepepo_dets
  (p_comp_obj_tree_row in     ben_manage_life_events.g_cache_proc_objects_rec
  ,p_per_in_ler_id     in     number
  ,p_effective_date    in     date
  ,p_pgm_id            in     number
  ,p_pl_id             in     number
  ,p_oipl_id           in     number
  ,p_opt_id            in     number
  --
  ,p_inst_row	       in out NOCOPY g_pep_rec
  )
is
  --
  l_proc varchar2(72) :=  'get_currpepepo_dets';
  --
  l_inst_row g_pep_rec;
  --
  -- Determines the current eligibility for a plan
  --
  CURSOR c_current_elig_for_plan
    (c_per_in_ler_id  number
    ,c_pl_id          number
    ,c_pgm_id         number
    ,c_effective_date date
    )
  is
    SELECT   /*+ benpepch.get_pilplnpep_dets.c_current_elig_for_plan */
             pep.elig_per_id,
             pep.elig_flag,
             pep.must_enrl_anthr_pl_id,
             pep.prtn_strt_dt,
             pep.inelg_rsn_cd
    FROM     ben_elig_per_f pep,
             ben_per_in_ler pil
    WHERE    pep.per_in_ler_id = c_per_in_ler_id
    AND      pep.pl_id = c_pl_id
    AND      pep.pgm_id = c_pgm_id
    AND      c_effective_date
    BETWEEN  pep.effective_start_date AND pep.effective_end_date
    AND      pil.per_in_ler_id (+) = pep.per_in_ler_id
    AND      pil.business_group_id (+) = pep.business_group_id
    AND      (
                  pil.per_in_ler_stat_cd NOT IN
                                      (
                                        'VOIDD',
                                        'BCKDT')
               OR pil.per_in_ler_stat_cd IS NULL);
  --
  CURSOR c_current_elig_for_plnip
    (c_per_in_ler_id  number
    ,c_pl_id          number
    ,c_effective_date date
    )
  is
    SELECT   /*+ benpepch.get_pilplnpep_dets.c_current_elig_for_plnip */
             pep.elig_per_id,
             pep.elig_flag,
             pep.must_enrl_anthr_pl_id,
             pep.prtn_strt_dt,
             pep.inelg_rsn_cd
    FROM     ben_elig_per_f pep,
             ben_per_in_ler pil
    WHERE    pep.per_in_ler_id = c_per_in_ler_id
    AND      pep.pl_id = c_pl_id
    AND      pep.pgm_id IS NULL
    AND      c_effective_date
      BETWEEN pep.effective_start_date AND pep.effective_end_date
    AND      pil.per_in_ler_id (+) = pep.per_in_ler_id
    AND      pil.business_group_id (+) = pep.business_group_id
    AND      (
                  pil.per_in_ler_stat_cd NOT IN
                                      (
                                        'VOIDD',
                                        'BCKDT')
               OR pil.per_in_ler_stat_cd IS NULL);
  --
  -- Determines the current eligibility for an option
  --
  CURSOR c_current_elig_for_option
    (c_per_in_ler_id  number
    ,c_pl_id          number
    ,c_pgm_id         number
    ,c_opt_id         number
    ,c_effective_date date
    )
  IS
    SELECT   /*+ benpepch.get_pilplnpep_dets.c_current_elig_for_option */
             ep.elig_per_id,
             epo.elig_flag,
             ep.must_enrl_anthr_pl_id,
             epo.prtn_strt_dt,
             epo.inelg_rsn_cd
    FROM     ben_elig_per_f ep,
             ben_elig_per_opt_f epo,
             ben_per_in_ler pil
    WHERE    ep.per_in_ler_id = c_per_in_ler_id
    AND      ep.pl_id = c_pl_id
    AND      ep.pgm_id = c_pgm_id
    AND      c_effective_date
      BETWEEN ep.effective_start_date AND ep.effective_end_date
    AND      ep.elig_per_id = epo.elig_per_id
    AND      epo.opt_id = c_opt_id
    AND      c_effective_date
      BETWEEN epo.effective_start_date AND epo.effective_end_date
    AND      pil.per_in_ler_id (+) = epo.per_in_ler_id
    AND      pil.business_group_id (+) = epo.business_group_id
    AND      (
                  pil.per_in_ler_stat_cd NOT IN
                                      (
                                        'VOIDD',
                                        'BCKDT')
               OR pil.per_in_ler_stat_cd IS NULL);
  --
  CURSOR c_current_elig_for_optnip
    (c_per_in_ler_id  number
    ,c_pl_id          number
    ,c_opt_id         number
    ,c_effective_date date
    )
  IS
    SELECT   /*+ benpepch.get_pilplnpep_dets.c_current_elig_for_optnip */
             ep.elig_per_id,
             epo.elig_flag,
             ep.must_enrl_anthr_pl_id,
             epo.prtn_strt_dt,
             epo.inelg_rsn_cd
    FROM     ben_elig_per_f ep,
             ben_elig_per_opt_f epo,
             ben_per_in_ler pil
    WHERE    ep.per_in_ler_id = c_per_in_ler_id
    AND      ep.pl_id = c_pl_id
    AND      ep.pgm_id IS NULL
    AND      c_effective_date
      BETWEEN ep.effective_start_date AND ep.effective_end_date
    AND      ep.elig_per_id = epo.elig_per_id
    AND      epo.opt_id = c_opt_id
    AND      c_effective_date
      BETWEEN epo.effective_start_date AND epo.effective_end_date
    AND      pil.per_in_ler_id (+) = epo.per_in_ler_id
    AND      pil.business_group_id (+) = epo.business_group_id
    AND      (
                  pil.per_in_ler_stat_cd NOT IN
                                      (
                                        'VOIDD',
                                        'BCKDT')
               OR pil.per_in_ler_stat_cd IS NULL);
  --
begin
  --
  -- Get the current eligibility info from the comp
  -- object list
  --
  if p_comp_obj_tree_row.elig_per_id is not null
  then
    --
    p_inst_row.elig_per_id  := p_comp_obj_tree_row.elig_per_id;
    p_inst_row.elig_flag    := p_comp_obj_tree_row.elig_flag;
    p_inst_row.prtn_strt_dt := p_comp_obj_tree_row.prtn_strt_dt;
    p_inst_row.inelg_rsn_cd := p_comp_obj_tree_row.inelg_rsn_cd; -- 2650247
    --
    return;
    --
  end if;
  --
  if p_oipl_id is null then
    --
    if p_pgm_id is not null
    then
      --
      OPEN c_current_elig_for_plan
        (c_per_in_ler_id  => p_per_in_ler_id
        ,c_effective_date => p_effective_date
        ,c_pgm_id         => p_pgm_id
        ,c_pl_id          => p_pl_id
        );
      FETCH c_current_elig_for_plan INTO l_inst_row.elig_per_id,
                                         l_inst_row.elig_flag,
                                         l_inst_row.must_enrl_anthr_pl_id,
                                         l_inst_row.prtn_strt_dt,
             				 l_inst_row.inelg_rsn_cd; -- 2650247
      --
      CLOSE c_current_elig_for_plan;
      --
    else
      --
      OPEN c_current_elig_for_plnip
        (c_per_in_ler_id  => p_per_in_ler_id
        ,c_effective_date => p_effective_date
        ,c_pl_id          => p_pl_id
        );
      FETCH c_current_elig_for_plnip INTO l_inst_row.elig_per_id,
                                          l_inst_row.elig_flag,
                                          l_inst_row.must_enrl_anthr_pl_id,
                                          l_inst_row.prtn_strt_dt,
             				  l_inst_row.inelg_rsn_cd; -- 2650247
      --
      CLOSE c_current_elig_for_plnip;
      --
    end if;
    --
  else
    --
    if p_pgm_id is not null
    then
      --
      OPEN c_current_elig_for_option
        (c_per_in_ler_id  => p_per_in_ler_id
        ,c_effective_date => p_effective_date
        ,c_pgm_id         => p_pgm_id
        ,c_pl_id          => p_pl_id
        ,c_opt_id         => p_opt_id
        );
      FETCH c_current_elig_for_option INTO l_inst_row.elig_per_id,
                                           l_inst_row.elig_flag,
                                           l_inst_row.must_enrl_anthr_pl_id,
                                           l_inst_row.prtn_strt_dt,
             				   l_inst_row.inelg_rsn_cd; -- 2650247
      --
      CLOSE c_current_elig_for_option;
      --
    else
      --
      OPEN c_current_elig_for_optnip
        (c_per_in_ler_id  => p_per_in_ler_id
        ,c_effective_date => p_effective_date
        ,c_pl_id          => p_pl_id
        ,c_opt_id         => p_opt_id
        );
      FETCH c_current_elig_for_optnip INTO l_inst_row.elig_per_id,
                                           l_inst_row.elig_flag,
                                           l_inst_row.must_enrl_anthr_pl_id,
                                           l_inst_row.prtn_strt_dt,
             				   l_inst_row.inelg_rsn_cd; -- 2650247
      --
      CLOSE c_current_elig_for_optnip;
      --
    end if;
    --
  end if;
  --
  p_inst_row := l_inst_row;
  --
end get_currpepepo_dets;
--
procedure get_curroiplippep_dets
  (p_comp_obj_tree_row in out NOCOPY ben_manage_life_events.g_cache_proc_objects_rec
  ,p_person_id         in     number
  ,p_effective_date    in     date
  --
  ,p_inst_row	       in out NOCOPY g_pep_rec
  )
is
  --
  l_proc varchar2(72) :=  'get_curroiplippep_dets';
  --
  l_inst_row g_pep_rec;
  --
  cursor c_oiplip_dets
    (c_person_id      in number
    ,c_effective_date in date
    ,c_pgm_id         in number
    ,c_plip_id        in number
    )
  is
    select  /*+ benpepch.get_curroiplippep_dets.c_oiplip_dets */
            pep.elig_per_id
    from    ben_elig_per_f pep,
            ben_per_in_ler pil
    where   pep.person_id = c_person_id
    and     pep.pgm_id = c_pgm_id
    and     pep.plip_id        = c_plip_id
    and     c_effective_date
            between pep.effective_start_date
            and pep.effective_end_date
    and    pil.per_in_ler_id(+)=pep.per_in_ler_id
    and    pil.business_group_id(+)=pep.business_group_id
    and    (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
            or pil.per_in_ler_stat_cd is null);
  --
  cursor c_oiplipnip_dets
    (c_person_id      in number
    ,c_effective_date in date
    ,c_plip_id        in number
    )
  is
    select  /*+ benpepch.get_curroiplippep_dets.c_oiplipnip_dets */
            pep.elig_per_id
    from    ben_elig_per_f pep,
            ben_per_in_ler pil
    where   pep.person_id = c_person_id
    and     pep.pgm_id is null
    and     pep.plip_id        = c_plip_id
    and     c_effective_date
            between pep.effective_start_date
            and pep.effective_end_date
    and    pil.per_in_ler_id(+)=pep.per_in_ler_id
    and    pil.business_group_id(+)=pep.business_group_id
    and    (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
            or pil.per_in_ler_stat_cd is null);
  --
begin
  --
  if p_comp_obj_tree_row.par_pgm_id is not null
  then
    --
    open c_oiplip_dets
      (c_person_id      => p_person_id
      ,c_effective_date => p_effective_date
      ,c_pgm_id         => p_comp_obj_tree_row.par_pgm_id
      ,c_plip_id        => p_comp_obj_tree_row.par_plip_id
      );
    fetch c_oiplip_dets into l_inst_row.elig_per_id;
    close c_oiplip_dets;
    --
  else
    --
    open c_oiplipnip_dets
      (c_person_id      => p_person_id
      ,c_effective_date => p_effective_date
      ,c_plip_id        => p_comp_obj_tree_row.par_plip_id
      );
    fetch c_oiplipnip_dets into l_inst_row.elig_per_id;
    close c_oiplipnip_dets;
    --
  end if;
  --
  p_inst_row := l_inst_row;
  --
end get_curroiplippep_dets;
--
procedure get_currplnpep_dets
  (p_comp_obj_tree_row in out NOCOPY ben_manage_life_events.g_cache_proc_objects_rec
  ,p_person_id         in     number
  ,p_effective_date    in     date
  --
  ,p_inst_row	       in out NOCOPY g_pep_rec
  )
is
  --
  l_proc varchar2(72) :=  'get_currplnpep_dets';
  --
  l_inst_row g_pep_rec;
  --
  -- Cursor to grab the PK of elig_per record to join the elig opt record to
  -- for first time'rs only
  --
  cursor c_pln_dets
    (c_person_id      in number
    ,c_effective_date in date
    ,c_pgm_id         in number
    ,c_pl_id          in number
    )
  is
    select  /*+ benpepch.get_currplnpep_dets.c_pln_dets */
            pep.elig_per_id,
            pep.prtn_strt_dt,
            pep.prtn_end_dt
    from    ben_elig_per_f pep,
            ben_per_in_ler pil
    where   pep.person_id = c_person_id
    and     pep.pgm_id    = c_pgm_id
    and     pep.pl_id     = c_pl_id
    and     c_effective_date
            between pep.effective_start_date
            and pep.effective_end_date
    and    pil.per_in_ler_id(+)=pep.per_in_ler_id
    and    pil.business_group_id(+)=pep.business_group_id
    and    (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
            or pil.per_in_ler_stat_cd is null);
  --
  cursor c_plnip_dets
    (c_person_id      in number
    ,c_effective_date in date
    ,c_pl_id          in number
    )
  is
    select  /*+ benpepch.get_currplnpep_dets.c_plnip_dets */
            pep.elig_per_id,
            pep.prtn_strt_dt,
            pep.prtn_end_dt
    from    ben_elig_per_f pep,
            ben_per_in_ler pil
    where   pep.person_id = c_person_id
    and     pep.pgm_id is null
    and     pep.pl_id     = c_pl_id
    and     c_effective_date
            between pep.effective_start_date
            and pep.effective_end_date
    and    pil.per_in_ler_id(+)=pep.per_in_ler_id
    and    pil.business_group_id(+)=pep.business_group_id
    and    (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
            or pil.per_in_ler_stat_cd is null);
  --
begin
  --
  if p_comp_obj_tree_row.par_pgm_id is not null
  then
    --
    open c_pln_dets
      (c_person_id      => p_person_id
      ,c_effective_date => p_effective_date
      ,c_pgm_id         => p_comp_obj_tree_row.par_pgm_id
      ,c_pl_id          => p_comp_obj_tree_row.par_pl_id
      );
    fetch c_pln_dets into l_inst_row.elig_per_id,
                          l_inst_row.prtn_strt_dt,
                          l_inst_row.prtn_end_dt;
    close c_pln_dets;
    --
  else
    --
    open c_plnip_dets
      (c_person_id      => p_person_id
      ,c_effective_date => p_effective_date
      ,c_pl_id          => p_comp_obj_tree_row.par_pl_id
      );
    fetch c_plnip_dets into l_inst_row.elig_per_id,
                                   l_inst_row.prtn_strt_dt,
                                   l_inst_row.prtn_end_dt;
    close c_plnip_dets;
    --
  end if;
  --
  p_inst_row := l_inst_row;
  --
end get_currplnpep_dets;
--
------------------------------------------------------------------------
-- DELETE ALL CACHED DATA
------------------------------------------------------------------------
--
procedure clear_down_cache
is
begin
  --
  ben_pep_cache.clear_down_pepcache;
  ben_pep_cache.clear_down_epocache;
  --
end clear_down_cache;
--
procedure clear_down_pepcache
is
begin
  --
  g_pilpep_lookup.delete;
  g_pilpep_instance.delete;
  --
  g_pilpep_cached   := FALSE;
  g_pilpep_effdt    := null;
  g_pilpep_personid := null;
  --
end clear_down_pepcache;
--
procedure clear_down_epocache
is
begin
  --
  g_optpilepo_lookup.delete;
  g_optpilepo_instance.delete;
  --
  g_optpilepo_cached   := FALSE;
  g_optpilepo_effdt    := null;
  g_optpilepo_personid := null;
  --
end clear_down_epocache;
--
end ben_pep_cache;

/
