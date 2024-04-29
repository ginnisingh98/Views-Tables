--------------------------------------------------------
--  DDL for Package Body BEN_ELPRO_CHECK_ELIGIBILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELPRO_CHECK_ELIGIBILITY" as
/* $Header: bendtlep.pkb 120.2.12010000.5 2008/11/13 04:25:05 krupani ship $ */
--
g_package varchar2(50) := 'ben_elpro_check_eligibility.';
g_rec                  benutils.g_batch_elig_rec;
--
procedure check_elig_othr_ptip_prte
  (p_eligy_prfl_id     in number
  ,p_business_group_id in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_person_id         in number
  --
  ,p_per_in_ler_id     in number default null
  )

is
  --
  l_proc varchar2(100):='check_elig_othr_ptip_prte';
  --
  l_inst_dets                   ben_elp_cache.g_cache_elpeoy_instor;
  l_inst_count                  number;
  l_insttorrw_num               binary_integer;
  l_ok                          boolean := false;
  l_rows_found                  boolean := false;
  l_dummy                       varchar2(1);
  l_pl_rec                      ben_comp_object.g_cache_pl_rec_table;
  --
  l_cur_found                   boolean := false;
  -- fonm
  l_effective_date              date  ;
  --
  -- bug 7540693: removed effective_date condition from pilc2
  cursor pilc2
    (c_per_in_ler_id            number
    ,c_ptip_id                  number
    )
  is
    select /*+ bendtlep.check_elig_othr_ptip_prte.pilc1 */
           null
    from   ben_elig_per_f epo
    where  epo.ptip_id = c_ptip_id
    and    epo.pl_id is null
    and    epo.per_in_ler_id = c_per_in_ler_id
    and    epo.elig_flag = 'Y';
  --

  cursor pilc1
    (c_effective_date           date
    ,c_per_in_ler_id            number
    ,c_ptip_id                  number
    ,c_only_pls_subj_cobra_flag varchar2
    )
  is
    select /*+ bendtlep.check_elig_othr_ptip_prte.pilc1 */
           null
    from   ben_pl_f pln,
           ben_plip_f cpp,
           ben_ptip_f ctp,
           ben_pl_regn_f prg,
           ben_regn_f reg,
           ben_elig_per_f epo
    where  pln.pl_id = cpp.pl_id
    and    c_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date
    and    c_effective_date
           between cpp.effective_start_date
           and     cpp.effective_end_date
    and    cpp.pgm_id = ctp.pgm_id
    and    pln.pl_typ_id = ctp.pl_typ_id
    and    ctp.ptip_id   = c_ptip_id
    and    c_effective_date
           between ctp.effective_start_date
           and     ctp.effective_end_date
    and    prg.pl_id = pln.pl_id
    and    c_effective_date
           between prg.effective_start_date
           and     prg.effective_end_date
    and    reg.regn_id = prg.regn_id
    and    c_effective_date
           between reg.effective_start_date
           and     reg.effective_end_date
    and    epo.per_in_ler_id = c_per_in_ler_id
    and    epo.pgm_id = ctp.pgm_id
    and    epo.pl_id = pln.pl_id
    /*and    c_effective_date
           between epo.effective_start_date
           and     epo.effective_end_date */ /* bug 7540693 */
    and    epo.elig_flag = 'Y'
    and    reg.sttry_citn_name = decode(c_only_pls_subj_cobra_flag,
                             'Y',
                             'COBRA',
                             reg.sttry_citn_name);
  cursor c1
    (c_business_group_id        in number
    ,c_effective_date           in date
    ,c_person_id                in number
    ,c_ptip_id                  in number
    ,c_only_pls_subj_cobra_flag in varchar2
    )
  is
    select /*+ first_rows bendtlep.check_elig_othr_ptip_prte.c1 */   --Bug 5200242
           null
    from   ben_pl_f pln,
           ben_plip_f cpp,
           ben_ptip_f ctp,
           ben_pl_regn_f prg,
           ben_regn_f reg,
           ben_elig_per_f epo,
           ben_per_in_ler pil
    where  pln.pl_id = cpp.pl_id
    and    pln.business_group_id  = c_business_group_id
    and    c_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date
    and    cpp.business_group_id  = pln.business_group_id
    and    c_effective_date
           between cpp.effective_start_date
           and     cpp.effective_end_date
    and    cpp.pgm_id = ctp.pgm_id
    and    pln.pl_typ_id = ctp.pl_typ_id
    and    ctp.ptip_id   = c_ptip_id
    and    ctp.business_group_id = pln.business_group_id
    and    c_effective_date
           between ctp.effective_start_date
           and     ctp.effective_end_date
    and    prg.pl_id = pln.pl_id
    and    prg.business_group_id  = pln.business_group_id
    and    c_effective_date
           between prg.effective_start_date
           and     prg.effective_end_date
    and    reg.regn_id = prg.regn_id
    and    reg.business_group_id  = prg.business_group_id
    and    c_effective_date
           between reg.effective_start_date
           and     reg.effective_end_date
    and    epo.person_id = c_person_id
    and    epo.pgm_id = ctp.pgm_id
    and    epo.pl_id = pln.pl_id
    and    epo.business_group_id  = c_business_group_id
    and    c_effective_date
           between epo.effective_start_date
           and     epo.effective_end_date
    and    epo.elig_flag = 'Y'
    and    reg.sttry_citn_name = decode(c_only_pls_subj_cobra_flag,
                             'Y',
                             'COBRA',
                             reg.sttry_citn_name)
and pil.per_in_ler_id(+)=epo.per_in_ler_id
--and pil.business_group_id(+)=epo.business_group_id
and (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
     or pil.per_in_ler_stat_cd is null                  -- outer join condition
    )
;
  cursor c2
    (c_business_group_id        in number
    ,c_effective_date           in date
    ,c_person_id                in number
    ,c_ptip_id                  in number
    )
  is
    select /*+ bendtlep.check_elig_othr_ptip_prte.c1 */
           null
    from   ben_elig_per_f epo,
           ben_per_in_ler pil
    where  epo.person_id = c_person_id
    and    epo.pl_id is null
    and    epo.ptip_id = c_ptip_id
    and    epo.business_group_id  = c_business_group_id
    and    c_effective_date
           between epo.effective_start_date
           and     epo.effective_end_date
    and    epo.elig_flag = 'Y'
    and pil.per_in_ler_id(+)=epo.per_in_ler_id
--and pil.business_group_id(+)=epo.business_group_id
    and (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
         or pil.per_in_ler_stat_cd is null                  -- outer join condition
        )
;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  hr_utility.set_location('LE dt : '||p_lf_evt_ocrd_dt, 10);
  hr_utility.set_location('Ef dt : '||p_effective_date, 10);
  hr_utility.set_location('p_per_in_ler_id : '||p_per_in_ler_id, 10);
  --
  -- Getting eligibility profile compensation level by eligibility profile
  -- fonm
  l_effective_date   :=  nvl(p_lf_evt_ocrd_dt,p_effective_date) ;
  if ben_manage_life_events.fonm = 'Y'
     and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
    --
    l_effective_date := nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,l_effective_date);
    --
  END IF;

  hr_utility.set_location('FONM : '||l_effective_date, 10);
  hr_utility.set_location('per_in_ler_id : '||p_per_in_ler_id, 10);
  --
  ben_elp_cache.elpeoy_getcacdets
    (p_effective_date    => l_effective_date,
     p_business_group_id => p_business_group_id,
     p_eligy_prfl_id     => p_eligy_prfl_id,
     p_inst_set          => l_inst_dets,
     p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this eligibility profile id
    -- 2) Look only at profiles for this PTIP_ID
    -- 3) if program is not null then, get all the ptip and check if
    --
    -- 4) Derive set of plans for the pgm that the ptip refers to
    -- 5) Set must be derived based on whether the plans are subject
    --    to COBRA or not.
    -- 6) If person eligible for any of the plans and exclude flag = 'Y'
    --    then no problem.
    -- 7) If person eligible for any of the plans and exclude flag = 'N'
    --    then fail criteria.
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_rows_found := true;
      --
      if p_per_in_ler_id is not null
      then
        --
        --  Check if person is eligible for PTIP - Bug 4545191.
        --
        open pilc2
          (c_per_in_ler_id            => p_per_in_ler_id
          ,c_ptip_id                  => l_inst_dets(l_insttorrw_num).ptip_id
          );
        fetch pilc2 into l_dummy;
        if pilc2%found then
          --
          l_cur_found := TRUE;
          --
          --  If person is eligible fo PTIP, check if the plans subject to
          --  cobra regulations are still eligible - Bug 4545191.
          --
          if l_inst_dets(l_insttorrw_num).only_pls_subj_cobra_flag = 'Y' then
            open pilc1
              (c_effective_date           => l_effective_date
              ,c_per_in_ler_id            => p_per_in_ler_id
              ,c_ptip_id                  => l_inst_dets(l_insttorrw_num).ptip_id
              ,c_only_pls_subj_cobra_flag => l_inst_dets(l_insttorrw_num).only_pls_subj_cobra_flag
              );
            fetch pilc1 into l_dummy;
            if pilc1%notfound then
              l_cur_found := FALSE;
            end if;
            close pilc1;
          end if;
          --
        else
          --
          l_cur_found := FALSE;
          --
        end if;
        close pilc2;
        --
      else
        --
        --  Check if person is eligible for PTIP - Bug 4545191.
        --
        open c2
          (c_business_group_id        => p_business_group_id
          ,c_effective_date           => l_effective_date
          ,c_person_id                => p_person_id
          ,c_ptip_id                  => l_inst_dets(l_insttorrw_num).ptip_id
          );
        fetch c2 into l_dummy;
        if c2%found then
          --
          l_cur_found := TRUE;
          --
          --  If person is eligible fo PTIP, check if the plans subject to
          --  cobra regulations are still eligible - Bug 4545191.
          --
          if l_inst_dets(l_insttorrw_num).only_pls_subj_cobra_flag = 'Y' then
            open c1
            (c_business_group_id        => p_business_group_id
            ,c_effective_date           => l_effective_date
            ,c_person_id                => p_person_id
            ,c_ptip_id                  => l_inst_dets(l_insttorrw_num).ptip_id
            ,c_only_pls_subj_cobra_flag => l_inst_dets(l_insttorrw_num).only_pls_subj_cobra_flag
            );
            fetch c1 into l_dummy;
            if c1%notfound then
               l_cur_found := FALSE;
            end if;
            close c1;
          end if;
        else
          --
          l_cur_found := FALSE;
          --
        end if;
        close c2;
      end if;
      --
      if l_cur_found then
        --
        if l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
          --
          l_ok := true;
          exit;
          --
        end if;
        --
        if l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
          --
          l_ok := false;
          exit;
          --
        end if;
        --
      else
        --
        if l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
          --
          l_ok := true;
          --
        end if;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    ben_evaluate_elig_profiles.g_inelg_rsn_cd := 'EOY';
    fnd_message.set_name('BEN','BEN_92226_EOY_ELIG_PRFL_FAIL');
    hr_utility.set_location('Criteria Failed: '||l_proc,20);
    raise ben_evaluate_elig_profiles.g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_elig_othr_ptip_prte;
--


procedure check_elig_dpnt_othr_ptip
  (p_eligy_prfl_id     in number
  ,p_business_group_id in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_person_id         in number
  --
  ,p_per_in_ler_id     in number
  )
is
  --
  l_proc varchar2(100):=g_package||'check_elig_dpnt_other_ptip';
  --
  l_inst_dets                   ben_elp_cache.g_cache_elpetd_instor;
  l_inst_count                  number;
  l_insttorrw_num               binary_integer;
  l_ok                          boolean := false;
  l_rows_found                  boolean := false;
  l_dummy                       varchar2(1);
  l_pl_rec                      ben_comp_object.g_cache_pl_rec_table;
  --
  cursor c1
    (c_ptip_id        in number
    ,c_bgp_id         in number
    ,c_eff_date       in date
    ,c_person_id in number
    )
  is
    select /*+ bendtlep.check_elig_dpnt_othr_ptip.c1 */
           null
    from   ben_pl_f pln,
           ben_plip_f cpp,
           ben_ptip_f ctp,
           ben_elig_per_f epo,
           ben_elig_dpnt  edp,
           ben_per_in_ler pil,
	   per_contact_relationships pcr -- bug 6811004
    where  pln.pl_id = cpp.pl_id
    and    pln.business_group_id = c_bgp_id
    and    c_eff_date
      between pln.effective_start_date and pln.effective_end_date
    and    cpp.business_group_id  = pln.business_group_id
    and    c_eff_date
      between cpp.effective_start_date and cpp.effective_end_date
    and    cpp.pgm_id = ctp.pgm_id
    and    pln.pl_typ_id = ctp.pl_typ_id
    and    ctp.ptip_id   = c_ptip_id
    and    ctp.business_group_id = pln.business_group_id
    and    c_eff_date
      between ctp.effective_start_date and ctp.effective_end_date
    and    pcr.contact_person_id = c_person_id -- bug 6811004
    and    edp.dpnt_person_id = pcr.person_id -- bug 6811004
    and    epo.pgm_id = ctp.pgm_id
    and    epo.pl_id = pln.pl_id
    and    epo.business_group_id  = c_bgp_id
    and    c_eff_date
      between epo.effective_start_date and epo.effective_end_date
    and    epo.elig_flag = 'Y'
    and    edp.dpnt_inelig_flag = 'N'
    and    edp.create_dt = (select max(edp2.create_dt)
                            from ben_elig_dpnt edp2
                                ,ben_per_in_ler pil2
                            where edp2.dpnt_person_id = edp.dpnt_person_id
                            and edp2.elig_per_id = epo.elig_per_id
                            and pil2.per_in_ler_id(+)=edp2.per_in_ler_id
                            and pil2.business_group_id(+)=edp2.business_group_id
                            and (pil2.per_in_ler_stat_cd
                                   not in ('VOIDD','BCKDT')
                                 or pil2.per_in_ler_stat_cd is null))
    and    epo.elig_per_id = edp.elig_per_id
    and    pil.per_in_ler_id(+)=edp.per_in_ler_id
    and    (pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
     or    pil.per_in_ler_stat_cd is null
           )
    and    epo.per_in_ler_id = edp.per_in_ler_id
    and    c_eff_date
      between epo.effective_start_date and epo.effective_end_date;
  --
  l_effective_date date ;
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- fonm
  l_effective_date   :=  nvl(p_lf_evt_ocrd_dt,p_effective_date) ;
  if ben_manage_life_events.fonm = 'Y'
     and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
    --
    l_effective_date := nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,l_effective_date);
    --
  END IF;
  hr_utility.set_location('FONM : '||l_effective_date, 10);
  --

  -- Getting eligibility profile compensation level by eligibility profile
  --
  ben_elp_cache.elpetd_getcacdets
    (p_effective_date    => l_effective_date,
     p_business_group_id => p_business_group_id,
     p_eligy_prfl_id     => p_eligy_prfl_id,
     p_inst_set          => l_inst_dets,
     p_inst_count        => l_inst_count);
  --
  hr_utility.set_location('l_inst_count: '||l_inst_count, 10);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this eligibility profile id
    -- 2) Look only at profiles for this PTIP_ID
    -- 3) if program is not null then, get all the ptip and check if
    --
    -- 4) Derive set of plans for the pgm that the ptip refers to
    -- 5) If person eligible for any of the plans and exclude flag = 'Y'
    --    then no problem.
    -- 6) If person eligible for any of the plans and exclude flag = 'N'
    --    then fail criteria.
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_rows_found := true;
      --
      -- Removed the nvls to resolve execute waiting problems for
      --
     hr_utility.set_location('ptip_id '|| l_inst_dets(l_insttorrw_num).ptip_id,44333);
     hr_utility.set_location('p_business_group_id '||p_business_group_id,44333);
     hr_utility.set_location('l_effective_date'||l_effective_date, 44333);
     hr_utility.set_location('p_person_id '||p_person_id,44333);

      open c1
        (c_ptip_id        => l_inst_dets(l_insttorrw_num).ptip_id
        ,c_bgp_id         => p_business_group_id
        ,c_eff_date       => l_effective_date
        ,c_person_id => p_person_id
        );
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        if l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
          --
          l_ok := true;
          exit;
          --
        end if;
        --
        if l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
          --
          l_ok := false;
          exit;
          --
        end if;
        --
      else
        --
        close c1;
        if l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
          --
          l_ok := true;
          -- exit ;
          --
        end if;
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    ben_evaluate_elig_profiles.g_inelg_rsn_cd := 'ETD';
    fnd_message.set_name('BEN','BEN_92226_ETD_ELIG_PRFL_FAIL');
    hr_utility.set_location('Criteria Failed: '||l_proc,20);
    raise ben_evaluate_elig_profiles.g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_elig_dpnt_othr_ptip;
--
end ben_elpro_check_eligibility;

/
