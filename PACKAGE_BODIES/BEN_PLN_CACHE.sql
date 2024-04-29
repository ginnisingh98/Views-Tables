--------------------------------------------------------
--  DDL for Package Body BEN_PLN_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLN_CACHE" as
/* $Header: benplnch.pkb 120.1 2007/03/27 15:52:41 rtagarra noship $ */
--
g_package varchar2(50) := 'ben_pln_cache.';
--
procedure bgpcpp_getdets
  (p_business_group_id     in     number
  ,p_effective_date        in     date
  ,p_mode                  in     varchar2
  ,p_pgm_id                in     number default null
  ,p_pl_id                 in     number default null
  ,p_opt_id                in     number default null
  ,p_rptg_grp_id           in     number default null
  ,p_vrbl_rt_prfl_id       in     number default null
  ,p_eligy_prfl_id         in     number default null
  -- PB : 5422 :
  -- ,p_popl_enrt_typ_cycl_id in     number default null
  ,p_asnd_lf_evt_dt        in     date default null
  --
  ,p_inst_set                 out nocopy ben_pln_cache.g_bgppln_cache
  )
is
  --
  l_proc varchar2(72) := g_package||'bgpcpp_getdets';
  --
  l_instcolnm_set  ben_cache.InstColNmType;
  l_curparm_set    ben_cache.CurParmType;
  --
  l_cppinst_set    ben_pln_cache.g_bgpcpp_cache;
  --
  l_row_num        pls_integer;
  l_parhv          pls_integer;
  l_torrwnum       pls_integer;
  l_hv             pls_integer;
  l_not_hash_found boolean;
  --
  l_lkup_query     long;
  l_inst_query     long;
  l_coninst_query  long;
  --
  cursor c_pln
    (c_business_group_id       number
    ,c_effective_date          date
    ,c_mode                    varchar2
    ,c_pgm_id                  number
    ,c_pl_id                   number
    ,c_opt_id                  number
    ,c_rptg_grp_id             number
    ,c_vrbl_rt_prfl_id         number
    ,c_eligy_prfl_id           number
    -- PB : 5422 :
    -- ,c_popl_enrt_typ_cycl_id   number
    )
  is
    select pln.pl_id,
           pln.pl_typ_id,
           ptp.opt_typ_cd,
           pln.drvbl_fctr_prtn_elig_flag,
           pln.drvbl_fctr_apls_rts_flag,
           pln.trk_inelig_per_flag
    from   ben_ptip_f ctp,
           ben_pl_f pln,
           ben_pl_typ_f ptp,
           ben_plip_f plp
        --   ben_popl_yr_perd cpy,
        --   ben_yr_perd yrp
    where
    /* Hint joins */
           plp.pgm_id = c_pgm_id
    and    pln.pl_id = plp.pl_id
    and    c_effective_date
      between pln.effective_start_date
           and     pln.effective_end_date
    and    pln.pl_typ_id = ptp.pl_typ_id
    and    c_effective_date
      between ptp.effective_start_date
           and     ptp.effective_end_date
    and   (p_mode IN ('P','G','D') or
           exists (select null
                   from ben_popl_yr_perd cpy,
                        ben_yr_perd yrp
                   where cpy.pl_id = pln.pl_id
                   and    cpy.yr_perd_id = yrp.yr_perd_id
                   and    c_effective_date
                           between yrp.start_date
                           and     yrp.end_date))
    and    ctp.pgm_id = c_pgm_id
    /* Histograms */
    and    plp.plip_stat_cd = 'A'
    and    pln.pl_stat_cd = 'A'
    and    plp.alws_unrstrctd_enrt_flag = decode(c_mode,
                                                 'U',
                                                 'Y',
						 'D',
						 'Y',
                                                 plp.alws_unrstrctd_enrt_flag)
    and    ctp.ptip_stat_cd = 'A'
    /* Other joins */
    and    ctp.pl_typ_id = pln.pl_typ_id
    and    pln.pl_id = nvl(c_pl_id,pln.pl_id)
    and    c_effective_date
           between plp.effective_start_date
           and     plp.effective_end_date
    and    c_effective_date
           between ctp.effective_start_date
           and     ctp.effective_end_date
 /*   and    c_effective_date
           between yrp.start_date
           and     yrp.end_date
*/
    /* Make sure that plan being linked to covers all the options that may
       or may not have been stated by the user. */
    and    (exists (select null
                    from   ben_oipl_f cop
                    where  cop.opt_id = c_opt_id
                    and    cop.pl_id = pln.pl_id
                    and    cop.business_group_id   = pln.business_group_id
                    and    cop.oipl_stat_cd = 'A'
                    and    c_effective_date
                           between cop.effective_start_date
                           and     cop.effective_end_date)
            or c_opt_id is null)
    /* Make sure that plan being linked to covers all the programs that may
       or may not have been stated by the user. Also link in the benefits
       reporting group. */
    and    (exists (select null
                    from   ben_plip_f cpp,
                           ben_rptg_grp bnr,
                           ben_popl_rptg_grp rgr
                    where  cpp.pgm_id = c_pgm_id
                    and    cpp.pl_id = pln.pl_id
                    and    cpp.plip_stat_cd = 'A'
                    and    cpp.business_group_id   = pln.business_group_id
                    and    c_effective_date
                           between cpp.effective_start_date
                           and     cpp.effective_end_date
                    and    bnr.rptg_grp_id = c_rptg_grp_id
                    and    bnr.business_group_id   = pln.business_group_id
                    and    rgr.rptg_grp_id = bnr.rptg_grp_id
                    and    rgr.business_group_id   = bnr.business_group_id
                    and    rgr.pl_id = pln.pl_id)
            or c_rptg_grp_id is null)
    /* Make sure that plan being linked to is of the variable rate profile
       that has been specified by the user. */
    and    (exists (select null
                    from   ben_acty_base_rt_f abr,
                           ben_acty_vrbl_rt_f avr,
                           ben_vrbl_rt_prfl_f vpf
                    where  abr.pl_id = pln.pl_id
                    and    abr.business_group_id   = pln.business_group_id
                    and    c_effective_date
                           between abr.effective_start_date
                           and     abr.effective_end_date
                    and    avr.acty_base_rt_id = abr.acty_base_rt_id
                    and    avr.business_group_id   = abr.business_group_id
                    and    c_effective_date
                           between avr.effective_start_date
                           and     avr.effective_end_date
                    and    vpf.vrbl_rt_prfl_id = avr.vrbl_rt_prfl_id
                    and    vpf.business_group_id   = avr.business_group_id
                    and    vpf.vrbl_rt_prfl_id = c_vrbl_rt_prfl_id
                    and    c_effective_date
                           between vpf.effective_start_date
                           and     vpf.effective_end_date)
            or c_vrbl_rt_prfl_id is null)
    /* Make sure that plan being linked to is of the enrt perd of the
       program that has been specified by the user. */
    /* Bug#3694695 - removed the condition below as I believe this one is used
       for defining coverage/rate codes for plip at life event level
       and    (exists (select null
                    from   ben_enrt_perd_for_pl_f erp,
                           ben_enrt_perd enp,
                           ben_popl_enrt_typ_cycl_f pop
                    where  erp.pl_id = pln.pl_id
                    and    c_effective_date
                           between erp.effective_start_date
                           and     erp.effective_end_date
                    and    erp.enrt_perd_id = enp.enrt_perd_id
                    and    enp.asnd_lf_evt_dt = p_asnd_lf_evt_dt
                     PB : 5422 : and    enp.strt_dt = (select enp1.strt_dt
                                          from   ben_enrt_perd enp1
                                          where  enp1.enrt_perd_id =
                                          c_popl_enrt_typ_cycl_id)
                    and    enp.business_group_id   =
                           erp.business_group_id
                    and    pop.popl_enrt_typ_cycl_id=enp.popl_enrt_typ_cycl_id
                    and    c_effective_date between
                           pop.effective_start_date and pop.effective_end_date
                    and    pop.business_group_id=enp.business_group_id
                    and    pop.pgm_id=c_pgm_id
                    )
            or     not exists
                   (select null
                    from   ben_enrt_perd_for_pl_f erp,
                           ben_enrt_perd enp,
                           ben_popl_enrt_typ_cycl_f pop
                    where  c_effective_date between
                           erp.effective_start_date and erp.effective_end_date
                    and    erp.enrt_perd_id = enp.enrt_perd_id
                    and    enp.asnd_lf_evt_dt = p_asnd_lf_evt_dt
                    /* PB : 5422 :
                    and    enp.strt_dt = (select enp2.strt_dt
                                           from   ben_enrt_perd enp2
                                           where  enp2.enrt_perd_id =
                                                  c_popl_enrt_typ_cycl_id)
                    and    enp.business_group_id = erp.business_group_id
                    and    enp.business_group_id = pln.business_group_id
                    and    pop.popl_enrt_typ_cycl_id=enp.popl_enrt_typ_cycl_id
                    and    c_effective_date between
                           pop.effective_start_date and pop.effective_end_date
                    and    pop.business_group_id=enp.business_group_id
                    and    pop.pgm_id=c_pgm_id
                   )

            -- PB : 5422 :
            -- or c_popl_enrt_typ_cycl_id is null
            or p_asnd_lf_evt_dt is null
            or pln.invk_flx_cr_pl_flag ='Y'
            or pln.imptd_incm_calc_cd = 'PRTT')
     */
    /* Make sure that plan being linked to is of the eligibility profile
       that has been specified by the user. */
    and    (exists
           (select null
            from   ben_prtn_elig_f          epa2,
                   ben_prtn_elig_prfl_f     cep,
                   ben_eligy_prfl_f         elp
            where  epa2.pl_id = pln.pl_id
            and    epa2.business_group_id   = pln.business_group_id
            and    c_effective_date
                   between epa2.effective_start_date
                   and     epa2.effective_end_date
            and    cep.prtn_elig_id = epa2.prtn_elig_id
            and    cep.business_group_id   = epa2.business_group_id
            and    c_effective_date
                   between cep.effective_start_date
                   and     cep.effective_end_date
            and    elp.eligy_prfl_id = cep.eligy_prfl_id
            and    elp.business_group_id   = cep.business_group_id
            and    elp.eligy_prfl_id = c_eligy_prfl_id
            and    c_effective_date
                   between elp.effective_start_date
                   and     elp.effective_end_date)
            or c_eligy_prfl_id is null)
    order  by ctp.ordr_num ,plp.ordr_num ;
  --
  cursor c_noparms
    (c_pgm_id                  number
    ,c_effective_date          date
    ,c_mode                    varchar2
    )
  is
    select pln.pl_id,
           pln.pl_typ_id,
           ptp.opt_typ_cd,
           pln.drvbl_fctr_prtn_elig_flag,
           pln.drvbl_fctr_apls_rts_flag,
           pln.trk_inelig_per_flag
    from   ben_ptip_f ctp,
           ben_pl_f pln,
           ben_pl_typ_f ptp,
           ben_plip_f plp
           -- ben_popl_yr_perd cpy,
           -- ben_yr_perd yrp
    where
    /* Hint joins */
           plp.pgm_id = c_pgm_id
    and    pln.pl_id = plp.pl_id
    and    c_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date
    and    pln.pl_typ_id = ptp.pl_typ_id
    and    c_effective_date
      between ptp.effective_start_date
           and     ptp.effective_end_date
    and    ctp.pgm_id = c_pgm_id

    and   (p_mode in ('G','D') or
           exists (select null
                   from ben_popl_yr_perd cpy,
                        ben_yr_perd yrp
                   where cpy.pl_id = pln.pl_id
                   and    cpy.yr_perd_id = yrp.yr_perd_id
                   and    c_effective_date
                           between yrp.start_date
                           and     yrp.end_date))

    /* Histograms */
    and    plp.plip_stat_cd = 'A'
    and    pln.pl_stat_cd = 'A'
    and    plp.alws_unrstrctd_enrt_flag = decode(c_mode,
                                                 'U',
                                                 'Y',
						 'D',
						 'Y',
                                                 plp.alws_unrstrctd_enrt_flag)
    and    ctp.ptip_stat_cd = 'A'
    /* Other joins */
    and    ctp.pl_typ_id = pln.pl_typ_id
    and    c_effective_date
           between plp.effective_start_date
           and     plp.effective_end_date
    and    c_effective_date
           between ctp.effective_start_date
           and     ctp.effective_end_date
    order  by ctp.ordr_num ,plp.ordr_num;
  --
begin
  --
--  hr_utility.set_location (l_proc||' Entering ',10);
  --
  l_row_num := 0;
  --
  if p_pl_id is null
    and p_opt_id is null
    and p_rptg_grp_id is null
    and p_vrbl_rt_prfl_id is null
    and p_eligy_prfl_id is null
    -- PB : 5422 :
    -- and p_popl_enrt_typ_cycl_id is null
    and p_asnd_lf_evt_dt is null
  then
    --
    for obj in c_noparms
      (c_pgm_id         => p_pgm_id
      ,c_effective_date => p_effective_date
      ,c_mode           => p_mode
      )
    loop
      --
      p_inst_set(l_row_num) := obj;
      l_row_num := l_row_num+1;
      --
    end loop;
    --
  else
    --
    for obj in c_pln
      (c_business_group_id     => p_business_group_id
      ,c_effective_date        => p_effective_date
      ,c_mode                  => p_mode
      ,c_pgm_id                => p_pgm_id
      ,c_pl_id                 => p_pl_id
      ,c_opt_id                => p_opt_id
      ,c_rptg_grp_id           => p_rptg_grp_id
      ,c_vrbl_rt_prfl_id       => p_vrbl_rt_prfl_id
      ,c_eligy_prfl_id         => p_eligy_prfl_id
      -- PB : 5422 :
      -- ,c_popl_enrt_typ_cycl_id => p_popl_enrt_typ_cycl_id
      )
    loop
      --
      p_inst_set(l_row_num) := obj;
      l_row_num := l_row_num+1;
      --
    end loop;
    --
  end if;
  --
--  hr_utility.set_location (l_proc||' Leaving ',10);
exception
  when others then
    hr_utility.set_location (l_proc||' Leaving Others Exc ',100);
    raise;
end bgpcpp_getdets;
--
procedure clear_down_cache is
  --
  l_proc varchar2(72) := g_package||'clear_down_cache';
  --
begin
  --
  g_eedcpp_parlookup.delete;
  g_eedcpp_lookup.delete;
  g_eedcpp_inst.delete;
  --
  begin
    --
    dbms_session.free_unused_user_memory;
    --
  end;
  --
end clear_down_cache;
--
end ben_pln_cache;

/
