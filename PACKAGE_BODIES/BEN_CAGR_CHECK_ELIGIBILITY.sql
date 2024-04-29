--------------------------------------------------------
--  DDL for Package Body BEN_CAGR_CHECK_ELIGIBILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CAGR_CHECK_ELIGIBILITY" as
/* $Header: bendtlca.pkb 120.0 2005/05/28 04:15:31 appldev noship $ */
--
g_package varchar2(50) := 'ben_cagr_check_eligibility.';
g_rec                  benutils.g_batch_elig_rec;
--
procedure check_gndr_elig
  (p_eligy_prfl_id     in number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_effective_date    in date
  ,p_per_sex           in varchar2
  )
is
  --
  l_proc          varchar2(100) := g_package||'check_gndr_elig';
  --
  l_inst_set      ben_cagrelp_cache.g_elp_cache := ben_cagrelp_cache.g_elp_cache();
  --
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  --
  l_ele_num       pls_integer;
  l_crit_passed     boolean;
  l_score_tab       ben_evaluate_elig_profiles.scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  ben_cagrelp_cache.elpegn_getdets
    (p_effective_date => p_effective_date
    ,p_eligy_prfl_id  => p_eligy_prfl_id
    --
    ,p_inst_set       => l_inst_set
    );
  --
  if l_inst_set.count > 0 then
    --
    l_ele_num := 1;
    --
    for i in l_inst_set.first .. l_inst_set.last loop
      --
      l_ok := nvl((nvl(p_per_sex,'-1') = l_inst_set(l_ele_num).v230_val),FALSE);
      --
      if l_ok and l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           ben_evaluate_elig_profiles.write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           ben_evaluate_elig_profiles.write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        end if;
        --
      elsif l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
      l_ele_num := l_ele_num+1;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found
       and not l_ok
     then
       --
       ben_evaluate_elig_profiles.g_inelg_rsn_cd := 'EGN';
       fnd_message.set_name('BEN','BEN_92814_GNDR_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise ben_evaluate_elig_profiles.g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     ben_evaluate_elig_profiles.write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_gndr_elig;
--
procedure check_mrtl_sts_elig
  (p_eligy_prfl_id  in number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_effective_date in date
  ,p_per_mar_status   in varchar2
  )
is
  --
  l_proc          varchar2(100) := g_package||'check_mrtl_sts_elig';
  --
  l_inst_set      ben_cagrelp_cache.g_elp_cache := ben_cagrelp_cache.g_elp_cache();
  --
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  --
  l_ele_num       pls_integer;
  --
  l_crit_passed     boolean;
  l_score_tab       ben_evaluate_elig_profiles.scoreTab;
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  ben_cagrelp_cache.elpemp_getdets
    (p_effective_date => p_effective_date
    ,p_eligy_prfl_id  => p_eligy_prfl_id
    --
    ,p_inst_set       => l_inst_set
    );
  --
  if l_inst_set.count > 0 then
    --
    l_ele_num := 1;
    --
    for i in l_inst_set.first .. l_inst_set.last loop
      --
      l_ok := nvl((nvl(p_per_mar_status,'-1') = l_inst_set(l_ele_num).v230_val),FALSE);
      --
      if l_ok and l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           ben_evaluate_elig_profiles.write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        --
        if p_score_compute_mode then
           ben_evaluate_elig_profiles.write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        end if;
      elsif l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
      l_ele_num := l_ele_num+1;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found
       and not l_ok
     then
       --
       ben_evaluate_elig_profiles.g_inelg_rsn_cd := 'EMP';
       fnd_message.set_name('BEN','BEN_92815_MARSTAT_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise ben_evaluate_elig_profiles.g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     ben_evaluate_elig_profiles.write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_mrtl_sts_elig;
--
procedure check_dsblty_ctg_elig
  (p_eligy_prfl_id  in number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_effective_date in date
  ,p_per_dsblty_ctg   in varchar2
  )
is
  --
  l_proc          varchar2(100) := g_package||'check_dsblty_ctg_elig';
  --
  l_inst_set      ben_cagrelp_cache.g_elp_cache := ben_cagrelp_cache.g_elp_cache();
  --
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  --
  l_ele_num       pls_integer;
  --
  l_crit_passed     boolean;
  l_score_tab       ben_evaluate_elig_profiles.scoreTab;
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  ben_cagrelp_cache.elpect_getdets
    (p_effective_date => p_effective_date
    ,p_eligy_prfl_id  => p_eligy_prfl_id
    --
    ,p_inst_set       => l_inst_set
    );
  --
  if l_inst_set.count > 0 then
    --
    l_ele_num := 1;
    --
    for i in l_inst_set.first .. l_inst_set.last loop
      --
      l_ok := nvl((nvl(p_per_dsblty_ctg,'-1') = l_inst_set(l_ele_num).v230_val),FALSE);
      --
      if l_ok and l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           ben_evaluate_elig_profiles.write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        --
        if p_score_compute_mode then
           ben_evaluate_elig_profiles.write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        end if;
      elsif l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
      l_ele_num := l_ele_num+1;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found
       and not l_ok
     then
       --
       ben_evaluate_elig_profiles.g_inelg_rsn_cd := 'ECT';
       fnd_message.set_name('BEN','BEN_92816_DSBLCAT_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise ben_evaluate_elig_profiles.g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     ben_evaluate_elig_profiles.write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_dsblty_ctg_elig;
--
procedure check_dsblty_rsn_elig
  (p_eligy_prfl_id  in number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_effective_date in date
  ,p_per_dsblty_rsn   in varchar2
  )
is
  --
  l_proc          varchar2(100) := g_package||'check_dsblty_rsn_elig';
  --
  l_inst_set      ben_cagrelp_cache.g_elp_cache := ben_cagrelp_cache.g_elp_cache();
  --
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  --
  l_ele_num       pls_integer;
  --
  l_crit_passed     boolean;
  l_score_tab       ben_evaluate_elig_profiles.scoreTab;
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  ben_cagrelp_cache.elpedr_getdets
    (p_effective_date => p_effective_date
    ,p_eligy_prfl_id  => p_eligy_prfl_id
    --
    ,p_inst_set       => l_inst_set
    );
  --
  if l_inst_set.count > 0 then
    --
    l_ele_num := 1;
    --
    for i in l_inst_set.first .. l_inst_set.last loop
      --
      l_ok := nvl((nvl(p_per_dsblty_rsn,'-1') = l_inst_set(l_ele_num).v230_val),FALSE);
      --
      if l_ok and l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           ben_evaluate_elig_profiles.write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        --
        if p_score_compute_mode then
           ben_evaluate_elig_profiles.write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        end if;
      elsif l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
      l_ele_num := l_ele_num+1;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found
       and not l_ok
     then
       --
       ben_evaluate_elig_profiles.g_inelg_rsn_cd := 'EDR';
       fnd_message.set_name('BEN','BEN_92817_DSBLRSN_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise ben_evaluate_elig_profiles.g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     ben_evaluate_elig_profiles.write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_dsblty_rsn_elig;
--
procedure check_dsblty_dgr_elig
  (p_eligy_prfl_id     in number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_effective_date    in date
  ,p_per_degree        in number
  )
is
  --
  l_proc         varchar2(100) := g_package||'check_dsblty_dgr_elig';
  --
  l_inst_set      ben_cagrelp_cache.g_elp_cache := ben_cagrelp_cache.g_elp_cache();
  --
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  --
  l_ele_num       pls_integer;
  --
  l_crit_passed     boolean;
  l_score_tab       ben_evaluate_elig_profiles.scoreTab;
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  ben_cagrelp_cache.elpedd_getdets
    (p_effective_date => p_effective_date
    ,p_eligy_prfl_id  => p_eligy_prfl_id
    --
    ,p_inst_set       => l_inst_set
    );
  --
  if l_inst_set.count > 0 then
    --
    l_ele_num := 1;
    --
    for i in l_inst_set.first .. l_inst_set.last loop
      --
      l_ok := nvl((nvl(p_per_degree,'-1') = l_inst_set(l_ele_num).num_val),FALSE);
      --
      if l_ok and l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           ben_evaluate_elig_profiles.write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        --
        if p_score_compute_mode then
           ben_evaluate_elig_profiles.write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        end if;
      elsif l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
      l_ele_num := l_ele_num+1;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found
       and not l_ok
     then
       --
       ben_evaluate_elig_profiles.g_inelg_rsn_cd := 'EDD';
       fnd_message.set_name('BEN','BEN_92818_DSBDGR_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise ben_evaluate_elig_profiles.g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     ben_evaluate_elig_profiles.write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_dsblty_dgr_elig;
--
procedure check_suppl_role_elig
  (p_eligy_prfl_id    in number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_effective_date   in date
  ,p_asg_job_id       in number
  ,p_asg_job_group_id in number
  )
is
  --
  l_proc          varchar2(100) := g_package||'check_suppl_role_elig';
  --
  l_inst_set      ben_cagrelp_cache.g_elp_cache := ben_cagrelp_cache.g_elp_cache();
  --
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  --
  l_ele_num       pls_integer;
  --
  l_crit_passed     boolean;
  l_score_tab       ben_evaluate_elig_profiles.scoreTab;
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  ben_cagrelp_cache.elpest_getdets
    (p_effective_date => p_effective_date
    ,p_eligy_prfl_id  => p_eligy_prfl_id
    --
    ,p_inst_set       => l_inst_set
    );
  --
  if l_inst_set.count > 0 then
    --
    l_ele_num := 1;
    --
    for i in l_inst_set.first .. l_inst_set.last loop
      --
      l_ok := nvl((nvl(p_asg_job_id,-1) = l_inst_set(l_ele_num).num_val
              and nvl(p_asg_job_group_id,-1) = l_inst_set(l_ele_num).num_val1),FALSE);
      --
      if l_ok and l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           ben_evaluate_elig_profiles.write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        --
        if p_score_compute_mode then
           ben_evaluate_elig_profiles.write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        end if;
      elsif l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
      l_ele_num := l_ele_num+1;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found
       and not l_ok
     then
       --
       ben_evaluate_elig_profiles.g_inelg_rsn_cd := 'EST';
       fnd_message.set_name('BEN','BEN_92819_SUPPLROLE_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise ben_evaluate_elig_profiles.g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     ben_evaluate_elig_profiles.write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_suppl_role_elig;
--
procedure check_qual_titl_elig
  (p_eligy_prfl_id   in number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_effective_date  in date
  ,p_per_qual_title  in varchar2
  ,p_per_qual_typ_id in number
  )
is
  --
  l_proc          varchar2(100) := g_package||'check_qual_titl_elig';
  --
  l_inst_set      ben_cagrelp_cache.g_elp_cache := ben_cagrelp_cache.g_elp_cache();
  --
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  --
  l_ele_num       pls_integer;
  --
  l_crit_passed     boolean;
  l_score_tab       ben_evaluate_elig_profiles.scoreTab;
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  ben_cagrelp_cache.elpeqt_getdets
    (p_effective_date => p_effective_date
    ,p_eligy_prfl_id  => p_eligy_prfl_id
    --
    ,p_inst_set       => l_inst_set
    );
  --
  if l_inst_set.count > 0 then
    --
    l_ele_num := 1;
    --
    for i in l_inst_set.first .. l_inst_set.last loop
      --
      l_ok := nvl((nvl(p_per_qual_typ_id,-1) = l_inst_set(l_ele_num).num_val
              and nvl(upper(p_per_qual_title),'-999999') = nvl(upper(l_inst_set(l_ele_num).v230_val),'-999999')),FALSE);
      --
      --        and nvl(upper(p_per_qual_title),'-1') = upper(l_inst_set(l_ele_num).v230_val)),FALSE);
      -- bug 2669031 - added nvl in the right hand side to handle case where person qual titl
      -- and criteria's qual title are both null, and if person's qual type and criteria's qual
      -- type matches, then the person passes the criteria in the above case.
      --
      if l_ok and l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           ben_evaluate_elig_profiles.write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        --
        if p_score_compute_mode then
           ben_evaluate_elig_profiles.write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        end if;
      elsif l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
      l_ele_num := l_ele_num+1;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found
       and not l_ok
     then
       --
       ben_evaluate_elig_profiles.g_inelg_rsn_cd := 'EQT';
       fnd_message.set_name('BEN','BEN_92820_QUALTITL_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise ben_evaluate_elig_profiles.g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     ben_evaluate_elig_profiles.write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_qual_titl_elig;
--
procedure check_pstn_elig
  (p_eligy_prfl_id  in number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_effective_date in date
  ,p_asg_position_id   in varchar2
  )
is
  --
  l_proc          varchar2(100) := g_package||'check_pstn_elig';
  --
  l_inst_set      ben_cagrelp_cache.g_elp_cache := ben_cagrelp_cache.g_elp_cache();
  --
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  --
  l_ele_num       pls_integer;
  --
  l_crit_passed     boolean;
  l_score_tab       ben_evaluate_elig_profiles.scoreTab;
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  ben_cagrelp_cache.elpeps_getdets
    (p_effective_date => p_effective_date
    ,p_eligy_prfl_id  => p_eligy_prfl_id
    --
    ,p_inst_set       => l_inst_set
    );
  --
  if l_inst_set.count > 0 then
    --
    l_ele_num := 1;
    --
    for i in l_inst_set.first .. l_inst_set.last loop
      --
      l_ok := nvl((nvl(p_asg_position_id,'-1') = l_inst_set(l_ele_num).num_val),FALSE);
      --
      if l_ok and l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           ben_evaluate_elig_profiles.write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        --
        if p_score_compute_mode then
           ben_evaluate_elig_profiles.write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        end if;
      elsif l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
      l_ele_num := l_ele_num+1;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found
       and not l_ok
     then
       --
       ben_evaluate_elig_profiles.g_inelg_rsn_cd := 'EPS';
       fnd_message.set_name('BEN','BEN_92821_PSTN_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise ben_evaluate_elig_profiles.g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     ben_evaluate_elig_profiles.write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_pstn_elig;
--
procedure check_prbtn_perd_elig
  (p_eligy_prfl_id  in     number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_effective_date in     date
  ,p_asg_prob_perd  in     number
  ,p_asg_prob_unit  in     varchar2
  )
is
  --
  l_proc         varchar2(100) := g_package||'check_prbtn_perd_elig';
  --
  l_inst_set      ben_cagrelp_cache.g_elp_cache := ben_cagrelp_cache.g_elp_cache();
  --
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  --
  l_ele_num       pls_integer;
  --
  l_crit_passed     boolean;
  l_score_tab       ben_evaluate_elig_profiles.scoreTab;
begin
  --
  ben_cagrelp_cache.elpepn_getdets
    (p_effective_date => p_effective_date
    ,p_eligy_prfl_id  => p_eligy_prfl_id
    --
    ,p_inst_set       => l_inst_set
    );
  --
  if l_inst_set.count > 0 then
    --
    l_ele_num := 1;
    --
    for i in l_inst_set.first .. l_inst_set.last loop
      --
      l_ok := nvl((nvl(p_asg_prob_perd,-1) = l_inst_set(l_ele_num).num_val
              and nvl(p_asg_prob_unit,'-1') = l_inst_set(l_ele_num).v230_val),FALSE);
      --
      if l_ok and l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           ben_evaluate_elig_profiles.write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        --
        if p_score_compute_mode then
           ben_evaluate_elig_profiles.write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        end if;
      elsif l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
      l_ele_num := l_ele_num+1;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found
       and not l_ok
     then
       --
       ben_evaluate_elig_profiles.g_inelg_rsn_cd := 'EDD';
       fnd_message.set_name('BEN','BEN_92822_PRBNPERD_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise ben_evaluate_elig_profiles.g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     ben_evaluate_elig_profiles.write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_prbtn_perd_elig;
--
procedure check_sp_clng_prg_elig
  (p_eligy_prfl_id  in number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_effective_date in date
  ,p_asg_sps_id   in varchar2
  )
is
  --
  l_proc          varchar2(100) := g_package||'check_sp_clng_prg_elig';
  --
  l_inst_set      ben_cagrelp_cache.g_elp_cache := ben_cagrelp_cache.g_elp_cache();
  --
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  --
  l_ele_num       pls_integer;
  --
  l_crit_passed     boolean;
  l_score_tab       ben_evaluate_elig_profiles.scoreTab;
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  ben_cagrelp_cache.elpesp_getdets
    (p_effective_date => p_effective_date
    ,p_eligy_prfl_id  => p_eligy_prfl_id
    --
    ,p_inst_set       => l_inst_set
    );
  --
  if l_inst_set.count > 0 then
    --
    l_ele_num := 1;
    --
    for i in l_inst_set.first .. l_inst_set.last loop
      --
      l_ok := nvl((nvl(p_asg_sps_id,'-1') = l_inst_set(l_ele_num).num_val),FALSE);
      --
      if l_ok and l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           ben_evaluate_elig_profiles.write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        --
        if p_score_compute_mode then
           ben_evaluate_elig_profiles.write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        end if;
      elsif l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
      l_ele_num := l_ele_num+1;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found
       and not l_ok
     then
       --
       ben_evaluate_elig_profiles.g_inelg_rsn_cd := 'ESP';
       fnd_message.set_name('BEN','BEN_92823_SPCLNGPRG_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise ben_evaluate_elig_profiles.g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     ben_evaluate_elig_profiles.write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_sp_clng_prg_elig;
--
procedure check_cagr_elig_profiles
  (p_eligprof_dets      in     ben_cep_cache.g_cobcep_cache_rec
  ,p_effective_date     in     date
  --
  ,p_person_id          in     number
  ,p_score_compute_mode in     boolean
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_per_sex            in     varchar2
  ,p_per_mar_status     in     varchar2
  ,p_per_qualification_type_id   in     varchar2 default null
  ,p_per_title          in     varchar2 default null
  ,p_asg_job_id         in     number
  ,p_asg_position_id    in     number
  ,p_asg_prob_perd      in     number
  ,p_asg_prob_unit      in     varchar2
  ,p_asg_sps_id         in     number
  )
is
  --
  l_proc          varchar2(100) := g_package||'check_cagr_elig_profiles';
  --
  cursor c_dsbl_dets
    (c_per_id number
    ,c_eff_dt date
    )
  is
    select dis.CATEGORY,
           dis.DEGREE,
           dis.REASON
    from per_disabilities_f dis
    where dis.person_id = c_per_id
    and c_eff_dt
      between dis.effective_start_date and dis.effective_end_date;
  --
  l_dsbl_dets c_dsbl_dets%rowtype;
  --
  cursor c_qual_dets
    (c_per_id number
     , c_eff_dt date
    )
  is
    select qua.TITLE,
           qua.QUALIFICATION_TYPE_ID
    from per_qualifications qua
    where qua.person_id = c_per_id
    and c_eff_dt between nvl(start_date,hr_general.start_of_time)
                      and nvl(end_date,hr_general.end_of_time)
    order by nvl(start_date,hr_general.start_of_time) desc ,qualification_id desc ;
  -- Added where clause and order by clause as part of bug fix 3775543
  --
  l_qual_dets c_qual_dets%rowtype;
  --
  cursor c_jobgrp_dets
    (c_per_id     number
    ,c_asg_job_id number
    )
  is
    select role.job_group_id
    from per_roles role
    where role.person_id = c_per_id
    and   role.job_id = c_asg_job_id;
  --
  l_jobgrp_dets c_jobgrp_dets%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Get disability details
  --
  if p_eligprof_dets.ELIG_DSBLTY_CTG_FLAG = 'Y'
    or p_eligprof_dets.ELIG_DSBLTY_RSN_FLAG = 'Y'
    or p_eligprof_dets.ELIG_DSBLTY_DGR_FLAG = 'Y'
  then
    --
    open c_dsbl_dets
      (c_per_id => p_person_id
      ,c_eff_dt => p_effective_date
      );
    fetch c_dsbl_dets into l_dsbl_dets;
    close c_dsbl_dets;
    --
  end if;
  --
  if p_eligprof_dets.ELIG_GNDR_FLAG = 'Y' then
    --
    ben_cagr_check_eligibility.check_gndr_elig
      (p_eligy_prfl_id  => p_eligprof_dets.eligy_prfl_id
      ,p_score_compute_mode=> p_score_compute_mode
      ,p_profile_score_tab => p_profile_score_tab
      ,p_effective_date => p_effective_date
      ,p_per_sex        => p_per_sex
      );
    --
  end if;
  --
  if p_eligprof_dets.ELIG_MRTL_STS_FLAG = 'Y' then
    --
    ben_cagr_check_eligibility.check_mrtl_sts_elig
      (p_eligy_prfl_id  => p_eligprof_dets.eligy_prfl_id
      ,p_score_compute_mode=> p_score_compute_mode
      ,p_profile_score_tab => p_profile_score_tab
      ,p_effective_date => p_effective_date
      ,p_per_mar_status => p_per_mar_status
      );
    --
  end if;
  --
  if p_eligprof_dets.ELIG_DSBLTY_CTG_FLAG = 'Y' then
    --
    ben_cagr_check_eligibility.check_dsblty_ctg_elig
      (p_eligy_prfl_id  => p_eligprof_dets.eligy_prfl_id
      ,p_score_compute_mode=> p_score_compute_mode
      ,p_profile_score_tab => p_profile_score_tab
      ,p_effective_date => p_effective_date
      ,p_per_dsblty_ctg => l_dsbl_dets.category
      );
    --
  end if;
  --
  if p_eligprof_dets.ELIG_DSBLTY_RSN_FLAG = 'Y' then
    --
    ben_cagr_check_eligibility.check_dsblty_rsn_elig
      (p_eligy_prfl_id  => p_eligprof_dets.eligy_prfl_id
      ,p_score_compute_mode=> p_score_compute_mode
      ,p_profile_score_tab => p_profile_score_tab
      ,p_effective_date => p_effective_date
      ,p_per_dsblty_rsn => l_dsbl_dets.reason
      );
    --
  end if;
  --
  if p_eligprof_dets.ELIG_DSBLTY_DGR_FLAG = 'Y' then
    --
    ben_cagr_check_eligibility.check_dsblty_dgr_elig
      (p_eligy_prfl_id  => p_eligprof_dets.eligy_prfl_id
      ,p_score_compute_mode=> p_score_compute_mode
      ,p_profile_score_tab => p_profile_score_tab
      ,p_effective_date => p_effective_date
      ,p_per_degree     => l_dsbl_dets.degree
      );
    --
  end if;
  --
  if p_eligprof_dets.ELIG_SUPPL_ROLE_FLAG = 'Y' then
    --
    open c_jobgrp_dets
      (c_per_id     => p_person_id
      ,c_asg_job_id => p_asg_job_id
      );
    fetch c_jobgrp_dets into l_jobgrp_dets;
    close c_jobgrp_dets;
    --
    ben_cagr_check_eligibility.check_suppl_role_elig
      (p_eligy_prfl_id    => p_eligprof_dets.eligy_prfl_id
      ,p_score_compute_mode=> p_score_compute_mode
      ,p_profile_score_tab => p_profile_score_tab
      ,p_effective_date   => p_effective_date
      ,p_asg_job_id       => p_asg_job_id
      ,p_asg_job_group_id => l_jobgrp_dets.job_group_id
      );
    --
  end if;
  --
  if p_eligprof_dets.ELIG_QUAL_TITL_FLAG = 'Y' then
    --
    if p_per_title is null and
       p_per_qualification_type_id is null then

       open c_qual_dets
         (c_per_id => p_person_id
         , c_eff_dt  => p_effective_date
         );
       fetch c_qual_dets into l_qual_dets;
       close c_qual_dets;
       --
    else
       l_qual_dets.title := p_per_title;
       l_qual_dets.qualification_type_id := p_per_qualification_type_id;
    end if;

    ben_cagr_check_eligibility.check_qual_titl_elig
      (p_eligy_prfl_id   => p_eligprof_dets.eligy_prfl_id
      ,p_effective_date  => p_effective_date
      ,p_score_compute_mode=> p_score_compute_mode
      ,p_profile_score_tab => p_profile_score_tab
      ,p_per_qual_title  => l_qual_dets.title
      ,p_per_qual_typ_id => l_qual_dets.QUALIFICATION_TYPE_ID
      );
    --
  end if;
  --
  if p_eligprof_dets.ELIG_PSTN_FLAG = 'Y' then
    --
    ben_cagr_check_eligibility.check_pstn_elig
      (p_eligy_prfl_id   => p_eligprof_dets.eligy_prfl_id
      ,p_score_compute_mode=> p_score_compute_mode
      ,p_profile_score_tab => p_profile_score_tab
      ,p_effective_date  => p_effective_date
      ,p_asg_position_id => p_asg_position_id
      );
    --
  end if;
  --
  if p_eligprof_dets.ELIG_PRBTN_PERD_FLAG = 'Y' then
    --
    ben_cagr_check_eligibility.check_prbtn_perd_elig
      (p_eligy_prfl_id  => p_eligprof_dets.eligy_prfl_id
      ,p_score_compute_mode=> p_score_compute_mode
      ,p_profile_score_tab => p_profile_score_tab
      ,p_effective_date => p_effective_date
      ,p_asg_prob_perd  => p_asg_prob_perd
      ,p_asg_prob_unit  => p_asg_prob_unit
      );
    --
  end if;
  --
  if p_eligprof_dets.ELIG_SP_CLNG_PRG_PT_FLAG = 'Y' then
    --
    ben_cagr_check_eligibility.check_sp_clng_prg_elig
      (p_eligy_prfl_id  => p_eligprof_dets.eligy_prfl_id
      ,p_score_compute_mode=> p_score_compute_mode
      ,p_profile_score_tab => p_profile_score_tab
      ,p_effective_date => p_effective_date
      ,p_asg_sps_id     => p_asg_sps_id
      );
    --
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_cagr_elig_profiles;
--
end ben_cagr_check_eligibility;

/
