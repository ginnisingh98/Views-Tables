--------------------------------------------------------
--  DDL for Package Body BEN_CAGRELP_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CAGRELP_CACHE" as
/* $Header: benelpc1.pkb 120.0 2005/05/28 08:57:11 appldev noship $ */
--
-- Declare globals
--
g_package varchar2(50) := 'ben_cagrelp_cache.';
g_hash_key number      := ben_hash_utility.get_hash_key;
g_hash_jump number     := ben_hash_utility.get_hash_jump;
--
g_elpegn_lookup   ben_cache.g_cache_lookup_table;
g_elpegn_nxelenum pls_integer;
g_elpegn_inst     g_elp_cache := g_elp_cache();
g_elpegn_cached   pls_integer := 0;
--
procedure elpegn_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  )
is
  --
  l_proc varchar2(72) := g_package||'elpegn_getdets';
  --
  l_inst_set     g_elp_cache := g_elp_cache();
  --
  l_elenum       pls_integer;
  --
  cursor c_instance
    (c_eligy_prfl_id  number
    ,c_effective_date date
    )
  is
    select tab.eligy_prfl_id,
           tab.elig_gndr_prte_id pk_id,
           'EGN' short_code,
           tab.sex,
           tab.excld_flag,
           tab.criteria_score,
           tab.criteria_weight
    from   ben_elig_gndr_prte_f tab
    where tab.eligy_prfl_id = c_eligy_prfl_id
      and c_effective_date
        between tab.effective_start_date and tab.effective_end_date
    order by tab.eligy_prfl_id,
             decode(tab.excld_flag,'Y',1,2);
  --
begin
  --
  l_elenum := 1;
  --
  for instrow in c_instance
    (c_eligy_prfl_id  => p_eligy_prfl_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    l_inst_set.extend(1);
    l_inst_set(l_elenum).eligy_prfl_id := instrow.eligy_prfl_id;
    l_inst_set(l_elenum).pk_id           := instrow.pk_id;
    l_inst_set(l_elenum).short_code      := instrow.short_code;
    l_inst_set(l_elenum).criteria_score  := instrow.criteria_score;
    l_inst_set(l_elenum).criteria_weight := instrow.criteria_weight;
    l_inst_set(l_elenum).v230_val      := instrow.sex;
    l_inst_set(l_elenum).excld_flag    := instrow.excld_flag;
    l_elenum := l_elenum+1;
    --
  end loop;
  --
  p_inst_set := l_inst_set;
  --
exception
  --
  when no_data_found then
    --
    null;
    --
end elpegn_getdets;
--
procedure elpemp_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  )
is
  --
  l_proc varchar2(72) := g_package||'elpemp_getdets';
  --
  l_inst_set     g_elp_cache := g_elp_cache();
  --
  l_elenum       pls_integer;
  --
  cursor c_instance
    (c_eligy_prfl_id  number
    ,c_effective_date date
    )
  is
    select tab.eligy_prfl_id,
           tab.elig_mrtl_sts_prte_id pk_id,
           'EMS' short_code,
           tab.marital_status,
           tab.excld_flag,
           tab.criteria_score,
           tab.criteria_weight
    from   ben_elig_mrtl_sts_prte_f tab
    where tab.eligy_prfl_id = c_eligy_prfl_id
      and c_effective_date
        between tab.effective_start_date and tab.effective_end_date
    order by tab.eligy_prfl_id,
             decode(tab.excld_flag,'Y',1,2);
  --
begin
  --
  l_elenum := 1;
  --
  for instrow in c_instance
    (c_eligy_prfl_id  => p_eligy_prfl_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    l_inst_set.extend(1);
    l_inst_set(l_elenum).eligy_prfl_id := instrow.eligy_prfl_id;
    l_inst_set(l_elenum).pk_id           := instrow.pk_id;
    l_inst_set(l_elenum).short_code      := instrow.short_code;
    l_inst_set(l_elenum).criteria_score  := instrow.criteria_score;
    l_inst_set(l_elenum).criteria_weight := instrow.criteria_weight;
    l_inst_set(l_elenum).v230_val      := instrow.marital_status;
    l_inst_set(l_elenum).excld_flag    := instrow.excld_flag;
    l_elenum := l_elenum+1;
    --
  end loop;
  --
  p_inst_set := l_inst_set;
  --
exception
  --
  when no_data_found then
    --
    null;
    --
end elpemp_getdets;
--
procedure elpect_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  )
is
  --
  l_proc varchar2(72) := g_package||'elpect_getdets';
  --
  l_inst_set     g_elp_cache := g_elp_cache();
  --
  l_elenum       pls_integer;
  --
  cursor c_instance
    (c_eligy_prfl_id  number
    ,c_effective_date date
    )
  is
    select tab.eligy_prfl_id,
           tab.elig_dsblty_ctg_prte_id pk_id,
           'ECT' short_code,
           tab.category,
           tab.excld_flag,
           tab.criteria_score,
           tab.criteria_weight
    from   ben_elig_dsblty_ctg_prte_f tab
    where tab.eligy_prfl_id = c_eligy_prfl_id
      and c_effective_date
        between tab.effective_start_date and tab.effective_end_date
    order by tab.eligy_prfl_id,
             decode(tab.excld_flag,'Y',1,2);
  --
begin
  --
  l_elenum := 1;
  --
  for instrow in c_instance
    (c_eligy_prfl_id  => p_eligy_prfl_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    l_inst_set.extend(1);
    l_inst_set(l_elenum).eligy_prfl_id := instrow.eligy_prfl_id;
    l_inst_set(l_elenum).pk_id           := instrow.pk_id;
    l_inst_set(l_elenum).short_code      := instrow.short_code;
    l_inst_set(l_elenum).criteria_score  := instrow.criteria_score;
    l_inst_set(l_elenum).criteria_weight := instrow.criteria_weight;
    l_inst_set(l_elenum).v230_val      := instrow.category;
    l_inst_set(l_elenum).excld_flag    := instrow.excld_flag;
    l_elenum := l_elenum+1;
    --
  end loop;
  --
  p_inst_set := l_inst_set;
  --
exception
  --
  when no_data_found then
    --
    null;
    --
end elpect_getdets;
--
procedure elpedr_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  )
is
  --
  l_proc varchar2(72) := g_package||'elpedr_getdets';
  --
  l_inst_set     g_elp_cache := g_elp_cache();
  --
  l_elenum       pls_integer;
  --
  cursor c_instance
    (c_eligy_prfl_id  number
    ,c_effective_date date
    )
  is
    select tab.eligy_prfl_id,
           tab.elig_dsblty_rsn_prte_id pk_id,
           'EDR' short_code,
           tab.reason,
           tab.excld_flag,
           tab.criteria_score,
           tab.criteria_weight
    from   ben_elig_dsblty_rsn_prte_f tab
    where tab.eligy_prfl_id = c_eligy_prfl_id
      and c_effective_date
        between tab.effective_start_date and tab.effective_end_date
    order by tab.eligy_prfl_id,
             decode(tab.excld_flag,'Y',1,2);
  --
begin
  --
  l_elenum := 1;
  --
  for instrow in c_instance
    (c_eligy_prfl_id  => p_eligy_prfl_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    l_inst_set.extend(1);
    l_inst_set(l_elenum).eligy_prfl_id := instrow.eligy_prfl_id;
    l_inst_set(l_elenum).pk_id           := instrow.pk_id;
    l_inst_set(l_elenum).short_code      := instrow.short_code;
    l_inst_set(l_elenum).criteria_score  := instrow.criteria_score;
    l_inst_set(l_elenum).criteria_weight := instrow.criteria_weight;
    l_inst_set(l_elenum).v230_val      := instrow.reason;
    l_inst_set(l_elenum).excld_flag    := instrow.excld_flag;
    l_elenum := l_elenum+1;
    --
  end loop;
  --
  p_inst_set := l_inst_set;
  --
exception
  --
  when no_data_found then
    --
    null;
    --
end elpedr_getdets;
--
procedure elpedd_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  )
is
  --
  l_proc varchar2(72) := g_package||'elpedd_getdets';
  --
  l_inst_set     g_elp_cache := g_elp_cache();
  --
  l_elenum       pls_integer;
  --
  cursor c_instance
    (c_eligy_prfl_id  number
    ,c_effective_date date
    )
  is
    select tab.eligy_prfl_id,
           tab.elig_dsblty_dgr_prte_id pk_id,
           'EDD' short_code,
           tab.degree,
           tab.excld_flag,
           tab.criteria_score,
           tab.criteria_weight
    from   ben_elig_dsblty_dgr_prte_f tab
    where tab.eligy_prfl_id = c_eligy_prfl_id
      and c_effective_date
        between tab.effective_start_date and tab.effective_end_date
    order by tab.eligy_prfl_id,
             decode(tab.excld_flag,'Y',1,2);
  --
begin
  --
  l_elenum := 1;
  --
  for instrow in c_instance
    (c_eligy_prfl_id  => p_eligy_prfl_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    l_inst_set.extend(1);
    l_inst_set(l_elenum).eligy_prfl_id := instrow.eligy_prfl_id;
    l_inst_set(l_elenum).pk_id           := instrow.pk_id;
    l_inst_set(l_elenum).short_code      := instrow.short_code;
    l_inst_set(l_elenum).criteria_score  := instrow.criteria_score;
    l_inst_set(l_elenum).criteria_weight := instrow.criteria_weight;
    l_inst_set(l_elenum).num_val       := instrow.degree;
    l_inst_set(l_elenum).excld_flag    := instrow.excld_flag;
    l_elenum := l_elenum+1;
    --
  end loop;
  --
  p_inst_set := l_inst_set;
  --
exception
  --
  when no_data_found then
    --
    null;
    --
end elpedd_getdets;
--
procedure elpest_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  )
is
  --
  l_proc varchar2(72) := g_package||'elpest_getdets';
  --
  l_inst_set     g_elp_cache := g_elp_cache();
  --
  l_elenum       pls_integer;
  --
  cursor c_instance
    (c_eligy_prfl_id  number
    ,c_effective_date date
    )
  is
    select tab.eligy_prfl_id,
           tab.elig_suppl_role_prte_id pk_id,
           'EST' short_code,
           tab.job_id,
           tab.job_group_id,
           tab.excld_flag,
           tab.criteria_score,
           tab.criteria_weight
    from   ben_elig_suppl_role_prte_f tab
    where tab.eligy_prfl_id = c_eligy_prfl_id
      and c_effective_date
        between tab.effective_start_date and tab.effective_end_date
    order by tab.eligy_prfl_id,
             decode(tab.excld_flag,'Y',1,2);
  --
begin
  --
  l_elenum := 1;
  --
  for instrow in c_instance
    (c_eligy_prfl_id  => p_eligy_prfl_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    l_inst_set.extend(1);
    l_inst_set(l_elenum).eligy_prfl_id := instrow.eligy_prfl_id;
    l_inst_set(l_elenum).pk_id           := instrow.pk_id;
    l_inst_set(l_elenum).short_code      := instrow.short_code;
    l_inst_set(l_elenum).criteria_score  := instrow.criteria_score;
    l_inst_set(l_elenum).criteria_weight := instrow.criteria_weight;
    l_inst_set(l_elenum).num_val       := instrow.job_id;
    l_inst_set(l_elenum).num_val1      := instrow.job_group_id;
    l_inst_set(l_elenum).excld_flag    := instrow.excld_flag;
    l_elenum := l_elenum+1;
    --
  end loop;
  --
  p_inst_set := l_inst_set;
  --
exception
  --
  when no_data_found then
    --
    null;
    --
end elpest_getdets;
--
procedure elpeqt_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  )
is
  --
  l_proc varchar2(72) := g_package||'elpeqt_getdets';
  --
  l_inst_set     g_elp_cache := g_elp_cache();
  --
  l_elenum       pls_integer;
  --
  cursor c_instance
    (c_eligy_prfl_id  number
    ,c_effective_date date
    )
  is
    select tab.eligy_prfl_id,
           tab.elig_qual_titl_prte_id pk_id,
           'EQT' short_code,
           tab.title,
           tab.QUALIFICATION_TYPE_ID,
           tab.excld_flag,
           tab.criteria_score,
           tab.criteria_weight
    from   ben_elig_qual_titl_prte_f tab
    where tab.eligy_prfl_id = c_eligy_prfl_id
      and c_effective_date
        between tab.effective_start_date and tab.effective_end_date
    order by tab.eligy_prfl_id,
             decode(tab.excld_flag,'Y',1,2);
  --
begin
  --
  l_elenum := 1;
  --
  for instrow in c_instance
    (c_eligy_prfl_id  => p_eligy_prfl_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    l_inst_set.extend(1);
    l_inst_set(l_elenum).eligy_prfl_id := instrow.eligy_prfl_id;
    l_inst_set(l_elenum).pk_id           := instrow.pk_id;
    l_inst_set(l_elenum).short_code      := instrow.short_code;
    l_inst_set(l_elenum).criteria_score  := instrow.criteria_score;
    l_inst_set(l_elenum).criteria_weight := instrow.criteria_weight;
    l_inst_set(l_elenum).v230_val      := instrow.title;
    l_inst_set(l_elenum).num_val       := instrow.QUALIFICATION_TYPE_ID;
    l_inst_set(l_elenum).excld_flag    := instrow.excld_flag;
    l_elenum := l_elenum+1;
    --
  end loop;
  --
  p_inst_set := l_inst_set;
  --
exception
  --
  when no_data_found then
    --
    null;
    --
end elpeqt_getdets;
--
procedure elpeps_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  )
is
  --
  l_proc varchar2(72) := g_package||'elpeps_getdets';
  --
  l_inst_set     g_elp_cache := g_elp_cache();
  --
  l_elenum       pls_integer;
  --
  cursor c_instance
    (c_eligy_prfl_id  number
    ,c_effective_date date
    )
  is
    select tab.eligy_prfl_id,
           tab.elig_pstn_prte_id pk_id,
           'EPT' short_code,
           tab.position_id,
           tab.excld_flag,
           tab.criteria_score,
           tab.criteria_weight
    from   ben_elig_pstn_prte_f tab
    where tab.eligy_prfl_id = c_eligy_prfl_id
      and c_effective_date
        between tab.effective_start_date and tab.effective_end_date
    order by tab.eligy_prfl_id,
             decode(tab.excld_flag,'Y',1,2);
  --
begin
  --
  l_elenum := 1;
  --
  for instrow in c_instance
    (c_eligy_prfl_id  => p_eligy_prfl_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    l_inst_set.extend(1);
    l_inst_set(l_elenum).eligy_prfl_id := instrow.eligy_prfl_id;
    l_inst_set(l_elenum).pk_id           := instrow.pk_id;
    l_inst_set(l_elenum).short_code      := instrow.short_code;
    l_inst_set(l_elenum).criteria_score  := instrow.criteria_score;
    l_inst_set(l_elenum).criteria_weight := instrow.criteria_weight;
    l_inst_set(l_elenum).num_val       := instrow.position_id;
    l_inst_set(l_elenum).excld_flag    := instrow.excld_flag;
    l_elenum := l_elenum+1;
    --
  end loop;
  --
  p_inst_set := l_inst_set;
  --
exception
  --
  when no_data_found then
    --
    null;
    --
end elpeps_getdets;
--
procedure elpepn_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  )
is
  --
  l_proc varchar2(72) := g_package||'elpepn_getdets';
  --
  l_inst_set     g_elp_cache := g_elp_cache();
  --
  l_elenum       pls_integer;
  --
  cursor c_instance
    (c_eligy_prfl_id  number
    ,c_effective_date date
    )
  is
    select tab.eligy_prfl_id,
           tab.elig_prbtn_perd_prte_id pk_id,
           'EPP' short_code,
           tab.PROBATION_PERIOD,
           tab.PROBATION_UNIT,
           tab.excld_flag,
           tab.criteria_score,
           tab.criteria_weight
    from   ben_elig_prbtn_perd_prte_f tab
    where tab.eligy_prfl_id = c_eligy_prfl_id
      and c_effective_date
        between tab.effective_start_date and tab.effective_end_date
    order by tab.eligy_prfl_id,
             decode(tab.excld_flag,'Y',1,2);
  --
begin
  --
  l_elenum := 1;
  --
  for instrow in c_instance
    (c_eligy_prfl_id  => p_eligy_prfl_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    l_inst_set.extend(1);
    l_inst_set(l_elenum).eligy_prfl_id := instrow.eligy_prfl_id;
    l_inst_set(l_elenum).pk_id           := instrow.pk_id;
    l_inst_set(l_elenum).short_code      := instrow.short_code;
    l_inst_set(l_elenum).criteria_score  := instrow.criteria_score;
    l_inst_set(l_elenum).criteria_weight := instrow.criteria_weight;
    l_inst_set(l_elenum).num_val       := instrow.PROBATION_PERIOD;
    l_inst_set(l_elenum).v230_val      := instrow.PROBATION_UNIT;
    l_inst_set(l_elenum).excld_flag    := instrow.excld_flag;
    l_elenum := l_elenum+1;
    --
  end loop;
  --
  p_inst_set := l_inst_set;
  --
exception
  --
  when no_data_found then
    --
    null;
    --
end elpepn_getdets;
--
procedure elpesp_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  )
is
  --
  l_proc varchar2(72) := g_package||'elpesp_getdets';
  --
  l_inst_set     g_elp_cache := g_elp_cache();
  --
  l_elenum       pls_integer;
  --
  cursor c_instance
    (c_eligy_prfl_id  number
    ,c_effective_date date
    )
  is
    select tab.eligy_prfl_id,
           tab.elig_sp_clng_prg_prte_id pk_id,
           'ESP' short_code,
           tab.special_ceiling_step_id,
           tab.excld_flag,
           tab.criteria_score,
           tab.criteria_weight
    from   ben_elig_sp_clng_prg_prte_f tab
    where tab.eligy_prfl_id = c_eligy_prfl_id
      and c_effective_date
        between tab.effective_start_date and tab.effective_end_date
    order by tab.eligy_prfl_id,
             decode(tab.excld_flag,'Y',1,2);
  --
begin
  --
  l_elenum := 1;
  --
  for instrow in c_instance
    (c_eligy_prfl_id  => p_eligy_prfl_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    l_inst_set.extend(1);
    l_inst_set(l_elenum).eligy_prfl_id := instrow.eligy_prfl_id;
    l_inst_set(l_elenum).pk_id           := instrow.pk_id;
    l_inst_set(l_elenum).short_code      := instrow.short_code;
    l_inst_set(l_elenum).criteria_score  := instrow.criteria_score;
    l_inst_set(l_elenum).criteria_weight := instrow.criteria_weight;
    l_inst_set(l_elenum).v230_val      := instrow.special_ceiling_step_id;
    l_inst_set(l_elenum).excld_flag    := instrow.excld_flag;
    l_elenum := l_elenum+1;
    --
  end loop;
  --
  p_inst_set := l_inst_set;
  --
exception
  --
  when no_data_found then
    --
    null;
    --
end elpesp_getdets;
--
procedure clear_down_cache
is
  --
  --
begin
  --

  --
  -- Grab back memory
  --
  begin
    --
    dbms_session.free_unused_user_memory;
    --
  end;
  --
end clear_down_cache;
--
end ben_cagrelp_cache;
--

/
