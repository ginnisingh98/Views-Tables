--------------------------------------------------------
--  DDL for Package Body BEN_COP_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COP_CACHE" as
/* $Header: bencopch.pkb 120.1 2007/03/27 15:52:23 rtagarra noship $ */
--
g_package varchar2(50) := 'ben_cop_cache.';
--
procedure bgpcop_getdets
  (p_effective_date    in     date
  ,p_business_group_id in     number
  ,p_pl_id             in     number default null
  ,p_opt_id            in     number default null
  ,p_eligy_prfl_id     in     number default null
  ,p_vrbl_rt_prfl_id   in     number default null
  ,p_mode              in     varchar2
  --
  ,p_inst_set                 out nocopy ben_cop_cache.g_bgpcop_cache
  )
is
  --
  l_proc varchar2(72) := g_package||'bgpcop_getdets';
  --
  l_row_num        pls_integer;
  --
  cursor c_noparms
    (c_effective_date in     date
    ,c_pl_id          in     number
    )
  is
    select cop.oipl_id,
           cop.opt_id,
           cop.drvbl_fctr_prtn_elig_flag,
           cop.drvbl_fctr_apls_rts_flag,
           cop.trk_inelig_per_flag
    from
           ben_pl_f pln,
           ben_oipl_f cop
         --  ben_popl_yr_perd cpy,
         --  ben_yr_perd yrp
    where  pln.pl_id = c_pl_id
    and    c_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date
    and    cop.pl_id = pln.pl_id
    and    c_effective_date
           between cop.effective_start_date
           and     cop.effective_end_date
    and    (p_mode IN ('P','G','D') or
            exists (select null
                    from   ben_popl_yr_perd cpy,
                           ben_yr_perd yrp
                    where  cpy.pl_id = pln.pl_id
                    and    cpy.yr_perd_id = yrp.yr_perd_id
                    and    c_effective_date
                            between yrp.start_date
                             and     yrp.end_date))
    and    pln.pl_stat_cd = 'A'
    and    cop.oipl_stat_cd = 'A'
    order by cop.ordr_num;
  --
  cursor c_oipl
    (c_effective_date        in     date
    ,c_pl_id                 in     number
    ,c_opt_id                in     number
    ,c_eligy_prfl_id         in     number
    ,c_vrbl_rt_prfl_id       in     number
    )
  is
    select cop.oipl_id,
           cop.opt_id,
           cop.drvbl_fctr_prtn_elig_flag,
           cop.drvbl_fctr_apls_rts_flag,
           cop.trk_inelig_per_flag
    from   ben_pl_f pln,
           ben_oipl_f cop,
         -- ben_popl_yr_perd cpy,
         --  ben_yr_perd yrp,
           ben_opt_f opt
    where  pln.pl_id = c_pl_id
    and    c_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date
    and    cop.pl_id = pln.pl_id
    and    c_effective_date
           between cop.effective_start_date
           and     cop.effective_end_date
    and    (p_mode IN ('P','G','D') or
            exists (select null
                    from   ben_popl_yr_perd cpy,
                           ben_yr_perd yrp
                    where  cpy.pl_id = pln.pl_id
                    and    cpy.yr_perd_id = yrp.yr_perd_id
                    and    c_effective_date
                            between yrp.start_date
                             and     yrp.end_date))
    and    cop.opt_id = opt.opt_id
    and    c_effective_date
           between opt.effective_start_date
           and     opt.effective_end_date
    and    pln.pl_stat_cd = 'A'
    and    cop.oipl_stat_cd = 'A'
    and    opt.opt_id = nvl(c_opt_id,opt.opt_id)
    /* Make sure that option being linked to is of the eligibility profile
       that has been specified by the user. */
    and    (c_eligy_prfl_id is not null and exists
           (select null
            from   ben_prtn_elig_f          epa2,
                   ben_prtn_elig_prfl_f     cep,
                   ben_eligy_prfl_f         elp
            where  epa2.oipl_id = cop.oipl_id
            and    epa2.business_group_id   = cop.business_group_id
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
    /* Make sure that plan being linked to is of the variable rate profile
       that has been specified by the user. */
    and (c_vrbl_rt_prfl_id is not null and exists
                   (select null
                    from   ben_acty_base_rt_f abr,
                           ben_acty_vrbl_rt_f avr,
                           ben_vrbl_rt_prfl_f vpf
                    where  abr.oipl_id = cop.oipl_id
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
    order by cop.ordr_num;
  --
begin
  --
  l_row_num := 0;
  --
  if p_eligy_prfl_id is null
    and p_vrbl_rt_prfl_id is null
    and p_opt_id is null
  then
    --
    for obj in c_noparms
      (c_effective_date => p_effective_date
      ,c_pl_id          => p_pl_id
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
    for obj in c_oipl
      (c_effective_date        => p_effective_date
      ,c_pl_id                 => p_pl_id
      ,c_opt_id                => p_opt_id
      ,c_eligy_prfl_id         => p_eligy_prfl_id
      ,c_vrbl_rt_prfl_id       => p_vrbl_rt_prfl_id
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
end bgpcop_getdets;
--
procedure clear_down_cache is
  --
begin
  --
  g_eedcop_parlookup.delete;
  g_eedcop_lookup.delete;
  g_eedcop_inst.delete;
  --
end clear_down_cache;
--
end ben_cop_cache;

/
