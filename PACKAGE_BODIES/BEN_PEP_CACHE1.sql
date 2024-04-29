--------------------------------------------------------
--  DDL for Package Body BEN_PEP_CACHE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PEP_CACHE1" as
/* $Header: benppch1.pkb 120.1 2007/11/14 15:14:40 rtagarra noship $ */
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
  115.0      25-Aug-03	mhoyes     Created.
  115.1      28-Aug-03	mhoyes     - Added get_currplnpep_dets.
  115.2      13-Sep-03	mhoyes     Tuning.
  115.3      30-Sep-03	mhoyes     More Tuning.
  115.4      01-Feb-04	mhoyes     - Bug 3412822: Split c_current_elig into
                                     four cursors in get_currpepcobj_prtnstrtdt.
  115.5      18-Feb-04  mhoyes     - Bug 3412822. Revamp of eligibility cache.
  115.6      24-Feb-04  mhoyes     - Bug 3412822. More eligibility cache tuning.
  115.7      08-Apr-04  mhoyes     - Bug 3412822. More eligibility cache tuning.
  115.8      14-Nov-07  rtagarra   -- Bug 5941500 : Fixed cursors c_pilplnip_dets and c_pilpln_dets
  -----------------------------------------------------------------------------
*/
--
-- Globals.
--
g_package varchar2(50) := 'ben_pep_cache1.';
--
procedure get_curroiplippep_dets
  (p_comp_obj_tree_row in out NOCOPY ben_manage_life_events.g_cache_proc_objects_rec
  ,p_person_id         in     number
  ,p_effective_date    in     date
  --
  ,p_inst_row	       in out NOCOPY ben_pep_cache.g_pep_rec
  )
is
  --
  l_proc varchar2(72) :=  'get_curroiplippep_dets';
  --
  l_inst_row          ben_pep_cache.g_pep_rec;
  --
  cursor c_piloiplip_dets
    (c_person_id      in number
    ,c_effective_date in date
    ,c_pgm_id         in number
    ,c_plip_id        in number
    )
  is
    select  /*+ benppch1.get_curroiplippep_dets.c_piloiplip_dets */
            pep.elig_per_id
    from    ben_elig_per_f pep,
            ben_per_in_ler pil
    where   pep.person_id = c_person_id
    and     pep.pgm_id  = c_pgm_id
    and     pep.plip_id = c_plip_id
    and     c_effective_date
      between pep.effective_start_date and pep.effective_end_date
    and    pil.per_in_ler_id=pep.per_in_ler_id
    and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  cursor c_nopiloiplip_dets
    (c_person_id      in number
    ,c_effective_date in date
    ,c_pgm_id         in number
    ,c_plip_id        in number
    )
  is
    select  /*+ benppch1.get_curroiplippep_dets.c_nopiloiplip_dets */
            pep.elig_per_id
    from    ben_elig_per_f pep
    where   pep.person_id = c_person_id
    and     pep.per_in_ler_id is null
    and     pep.pgm_id    = c_pgm_id
    and     pep.plip_id   = c_plip_id
    and     c_effective_date
      between pep.effective_start_date and pep.effective_end_date;
  --
  cursor c_piloiplipnip_dets
    (c_person_id      in number
    ,c_effective_date in date
    ,c_plip_id        in number
    )
  is
    select  /*+ benppch1.get_curroiplippep_dets.c_piloiplipnip_dets */
            pep.elig_per_id
    from    ben_elig_per_f pep,
            ben_per_in_ler pil
    where   pep.person_id = c_person_id
    and     pep.pgm_id is null
    and     pep.plip_id = c_plip_id
    and     c_effective_date
      between pep.effective_start_date and pep.effective_end_date
    and    pil.per_in_ler_id=pep.per_in_ler_id
    and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  cursor c_nopiloiplipnip_dets
    (c_person_id      in number
    ,c_effective_date in date
    ,c_plip_id        in number
    )
  is
    select  /*+ benppch1.get_curroiplippep_dets.c_nopiloiplipnip_dets */
            pep.elig_per_id
    from    ben_elig_per_f pep
    where   pep.person_id = c_person_id
    and     pep.per_in_ler_id is null
    and     pep.pgm_id is null
    and     pep.plip_id = c_plip_id
    and     c_effective_date
      between pep.effective_start_date and pep.effective_end_date;
  --
begin
  --
  if p_comp_obj_tree_row.par_pgm_id is not null
  then
    --
    open c_piloiplip_dets
      (c_person_id      => p_person_id
      ,c_effective_date => p_effective_date
      ,c_pgm_id         => p_comp_obj_tree_row.par_pgm_id
      ,c_plip_id        => p_comp_obj_tree_row.par_plip_id
      );
    fetch c_piloiplip_dets into l_inst_row.elig_per_id;
    close c_piloiplip_dets;
    --
    if l_inst_row.elig_per_id is null
    then
      --
      open c_nopiloiplip_dets
        (c_person_id      => p_person_id
        ,c_effective_date => p_effective_date
        ,c_pgm_id         => p_comp_obj_tree_row.par_pgm_id
        ,c_plip_id        => p_comp_obj_tree_row.par_plip_id
        );
      fetch c_nopiloiplip_dets into l_inst_row.elig_per_id;
      close c_nopiloiplip_dets;
      --
    end if;
    --
  else
    --
    open c_piloiplipnip_dets
      (c_person_id      => p_person_id
      ,c_effective_date => p_effective_date
      ,c_plip_id        => p_comp_obj_tree_row.par_plip_id
      );
    fetch c_piloiplipnip_dets into l_inst_row.elig_per_id;
    close c_piloiplipnip_dets;
    --
    if l_inst_row.elig_per_id is null
    then
      --
      open c_nopiloiplipnip_dets
        (c_person_id      => p_person_id
        ,c_effective_date => p_effective_date
        ,c_plip_id        => p_comp_obj_tree_row.par_plip_id
        );
      fetch c_nopiloiplipnip_dets into l_inst_row.elig_per_id;
      close c_nopiloiplipnip_dets;
      --
    end if;
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
  ,p_inst_row	       in out NOCOPY ben_pep_cache.g_pep_rec
  )
is
  --
  l_proc varchar2(72) :=  'get_currplnpep_dets';
  --
  l_inst_row ben_pep_cache.g_pep_rec;
  --
  -- Cursor to grab the PK of elig_per record to join the elig opt record to
  -- for first time'rs only
  --
  cursor c_pilpln_dets
    (c_person_id      in number
    ,c_effective_date in date
    ,c_pgm_id         in number
    ,c_pl_id          in number
    )
  is
    select  /*+ benppch1.get_currplnpep_dets.c_pilpln_dets */
            pep.elig_per_id,
            pep.prtn_strt_dt,
            pep.prtn_end_dt
    from    ben_elig_per_f pep,
            ben_per_in_ler pil
    where   pep.person_id = c_person_id
    and     pep.pgm_id    = c_pgm_id
    and     pep.pl_id     = c_pl_id
    and     c_effective_date
      between pep.effective_start_date and pep.effective_end_date
    and     pil.per_in_ler_id=pep.per_in_ler_id
    and     pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
     order by pep.per_in_ler_id desc ;   -- Bug 5941500
  --
  cursor c_nopilpln_dets
    (c_person_id      in number
    ,c_effective_date in date
    ,c_pgm_id         in number
    ,c_pl_id          in number
    )
  is
    select  /*+ benppch1.get_currplnpep_dets.c_nopilpln_dets */
            pep.elig_per_id,
            pep.prtn_strt_dt,
            pep.prtn_end_dt
    from    ben_elig_per_f pep
    where   pep.person_id = c_person_id
    and     pep.per_in_ler_id is null
    and     pep.pgm_id    = c_pgm_id
    and     pep.pl_id     = c_pl_id
    and     c_effective_date
      between pep.effective_start_date and pep.effective_end_date;
  --
  cursor c_pilplnip_dets
    (c_person_id      in number
    ,c_effective_date in date
    ,c_pl_id          in number
    )
  is
    select  /*+ benppch1.get_currplnpep_dets.c_pilplnip_dets */
            pep.elig_per_id,
            pep.prtn_strt_dt,
            pep.prtn_end_dt
    from    ben_elig_per_f pep,
            ben_per_in_ler pil
    where   pep.person_id = c_person_id
    and     pep.pgm_id is null
    and     pep.pl_id     = c_pl_id
    and     c_effective_date
      between pep.effective_start_date and pep.effective_end_date
    and    pil.per_in_ler_id=pep.per_in_ler_id
    and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
    order by pep.per_in_ler_id desc ;-- Bug 5941500
  --
  cursor c_nopilplnip_dets
    (c_person_id      in number
    ,c_effective_date in date
    ,c_pl_id          in number
    )
  is
    select  /*+ benppch1.get_currplnpep_dets.c_nopilplnip_dets */
            pep.elig_per_id,
            pep.prtn_strt_dt,
            pep.prtn_end_dt
    from    ben_elig_per_f pep
    where   pep.person_id = c_person_id
    and     pep.per_in_ler_id is null
    and     pep.pgm_id is null
    and     pep.pl_id = c_pl_id
    and     c_effective_date
      between pep.effective_start_date and pep.effective_end_date;
  --
begin
  --
  if p_comp_obj_tree_row.par_pgm_id is not null
  then
    --
    open c_pilpln_dets
      (c_person_id      => p_person_id
      ,c_effective_date => p_effective_date
      ,c_pgm_id         => p_comp_obj_tree_row.par_pgm_id
      ,c_pl_id          => p_comp_obj_tree_row.par_pl_id
      );
    fetch c_pilpln_dets into l_inst_row.elig_per_id,
                             l_inst_row.prtn_strt_dt,
                             l_inst_row.prtn_end_dt;
    close c_pilpln_dets;
    --
    if l_inst_row.elig_per_id is null
    then
      --
      open c_nopilpln_dets
        (c_person_id      => p_person_id
        ,c_effective_date => p_effective_date
        ,c_pgm_id         => p_comp_obj_tree_row.par_pgm_id
        ,c_pl_id          => p_comp_obj_tree_row.par_pl_id
        );
      fetch c_nopilpln_dets into l_inst_row.elig_per_id,
                                 l_inst_row.prtn_strt_dt,
                                 l_inst_row.prtn_end_dt;
      close c_nopilpln_dets;
      --
    end if;
    --
  else
    --
    open c_pilplnip_dets
      (c_person_id      => p_person_id
      ,c_effective_date => p_effective_date
      ,c_pl_id          => p_comp_obj_tree_row.par_pl_id
      );
    fetch c_pilplnip_dets into l_inst_row.elig_per_id,
                               l_inst_row.prtn_strt_dt,
                               l_inst_row.prtn_end_dt;
    close c_pilplnip_dets;
    --
    if l_inst_row.elig_per_id is null
    then
      --
      open c_nopilplnip_dets
        (c_person_id      => p_person_id
        ,c_effective_date => p_effective_date
        ,c_pl_id          => p_comp_obj_tree_row.par_pl_id
        );
      fetch c_nopilplnip_dets into l_inst_row.elig_per_id,
                                   l_inst_row.prtn_strt_dt,
                                   l_inst_row.prtn_end_dt;
      close c_nopilplnip_dets;
      --
    end if;
    --
  end if;
  --
  p_inst_row := l_inst_row;
  --
end get_currplnpep_dets;
--
procedure get_currpepcobj_cache
  (p_person_id         in     number
  ,p_pgm_id            in     number
  ,p_ptip_id           in     number default null
  ,p_pl_id             in     number
  ,p_plip_id           in     number default null
  ,p_opt_id            in     number
  ,p_effective_date    in     date
  --
  ,p_ecrpep_rec        in out NOCOPY g_ecrpep_rec
  )
is
  --
  l_proc varchar2(72) :=  'get_currpepcobj_cache';
  --
  l_pep_row               ben_derive_part_and_rate_facts.g_cache_structure;
  l_epo_row               ben_derive_part_and_rate_facts.g_cache_structure;
  --
  l_prtn_strt_dt          date;
  l_prtn_ovridn_flag      varchar2(30);
  l_prtn_ovridn_thru_dt   date;
  l_rt_age_val            number;
  l_rt_los_val            number;
  l_rt_hrs_wkd_val        number;
  l_rt_cmbn_age_n_los_val number;
  l_per_in_ler_id         number;
  l_elig_per_id           number;
  l_elig_per_opt_id       number;
  --
begin
  --
  -- Check mandatory parameters
  --
  if p_person_id is null
    or p_effective_date is null
  then
    --
    p_ecrpep_rec.prtn_strt_dt          := null;
    p_ecrpep_rec.prtn_ovridn_flag      := null;
    p_ecrpep_rec.prtn_ovridn_thru_dt   := null;
    p_ecrpep_rec.rt_age_val            := null;
    p_ecrpep_rec.rt_los_val            := null;
    p_ecrpep_rec.rt_hrs_wkd_val        := null;
    p_ecrpep_rec.rt_cmbn_age_n_los_val := null;
    p_ecrpep_rec.per_in_ler_id         := null;
    p_ecrpep_rec.elig_per_id           := null;
    p_ecrpep_rec.elig_per_opt_id       := null;
    return;
    --
  end if;
  --
  if p_opt_id is not null
  then
    --
    ben_pep_cache.get_pilepo_dets
      (p_person_id         => p_person_id
      ,p_business_group_id => null
      ,p_effective_date    => p_effective_date
      ,p_pgm_id            => p_pgm_id
      ,p_pl_id             => p_pl_id
      ,p_plip_id           => p_plip_id
      ,p_opt_id            => p_opt_id
      ,p_date_sync         => TRUE
      ,p_inst_row	   => l_epo_row
      );
    --
    l_prtn_strt_dt          := l_epo_row.prtn_strt_dt;
    l_prtn_ovridn_flag      := l_epo_row.prtn_ovridn_flag;
    l_prtn_ovridn_thru_dt   := l_epo_row.prtn_ovridn_thru_dt;
    l_rt_age_val            := l_epo_row.rt_age_val;
    l_rt_los_val            := l_epo_row.rt_los_val;
    l_rt_hrs_wkd_val        := l_epo_row.rt_hrs_wkd_val;
    l_rt_cmbn_age_n_los_val := l_epo_row.rt_cmbn_age_n_los_val;
    l_per_in_ler_id         := l_epo_row.per_in_ler_id;
    l_elig_per_id           := l_epo_row.elig_per_id;
    l_elig_per_opt_id       := l_epo_row.elig_per_opt_id;
    --
  else
    --
    ben_pep_cache.get_pilpep_dets
      (p_person_id         => p_person_id
      ,p_business_group_id => null
      ,p_effective_date    => p_effective_date
      ,p_pgm_id            => p_pgm_id
      ,p_pl_id             => p_pl_id
      ,p_plip_id           => p_plip_id
      ,p_ptip_id           => p_ptip_id
      ,p_date_sync         => TRUE
      ,p_inst_row	   => l_pep_row
      );
    --
    l_prtn_strt_dt          := l_pep_row.prtn_strt_dt;
    l_prtn_ovridn_flag      := l_pep_row.prtn_ovridn_flag;
    l_prtn_ovridn_thru_dt   := l_pep_row.prtn_ovridn_thru_dt;
    l_rt_age_val            := l_pep_row.rt_age_val;
    l_rt_los_val            := l_pep_row.rt_los_val;
    l_rt_hrs_wkd_val        := l_pep_row.rt_hrs_wkd_val;
    l_rt_cmbn_age_n_los_val := l_pep_row.rt_cmbn_age_n_los_val;
    l_per_in_ler_id         := l_pep_row.per_in_ler_id;
    l_elig_per_id           := l_pep_row.elig_per_id;
    l_elig_per_opt_id       := null;
    --
  end if;
  --
  p_ecrpep_rec.prtn_strt_dt          := l_prtn_strt_dt;
  p_ecrpep_rec.prtn_ovridn_flag      := l_prtn_ovridn_flag;
  p_ecrpep_rec.prtn_ovridn_thru_dt   := l_prtn_ovridn_thru_dt;
  p_ecrpep_rec.rt_age_val            := l_rt_age_val;
  p_ecrpep_rec.rt_los_val            := l_rt_los_val;
  p_ecrpep_rec.rt_hrs_wkd_val        := l_rt_hrs_wkd_val;
  p_ecrpep_rec.rt_cmbn_age_n_los_val := l_rt_cmbn_age_n_los_val;
  p_ecrpep_rec.per_in_ler_id         := l_per_in_ler_id;
  p_ecrpep_rec.elig_per_id           := l_elig_per_id;
  p_ecrpep_rec.elig_per_opt_id       := l_elig_per_opt_id;
  --
end get_currpepcobj_cache;
--
end ben_pep_cache1;

/
