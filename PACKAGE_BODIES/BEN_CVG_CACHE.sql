--------------------------------------------------------
--  DDL for Package Body BEN_CVG_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CVG_CACHE" as
/* $Header: bencvgch.pkb 120.3 2006/01/27 01:56:28 rtagarra noship $ */
--
g_package varchar2(50) := 'ben_cvg_cache.';
--
procedure epeplncvg_getdets
  (p_epe_id                in     number
  ,p_epe_pl_id             in     number
  ,p_epe_plip_id           in     number
  ,p_epe_oipl_id           in     number
  ,p_effective_date        in     date
  ,p_cvgtype_code          in     varchar2
  --
  ,p_inst_set                 out nocopy ben_cvg_cache.g_epeplncvg_cache
  ,p_inst_count               out nocopy number
  )
is
  --
  l_proc varchar2(72) := g_package||'epeplncvg_getdets';
  --
  l_inst_rec          g_epeplncvg_cache_rec;
  l_row_num           pls_integer;
  --
  l_pl_id             number;
  l_plip_id           number;
  l_oipl_id           number;
  --
begin
  --
  if p_cvgtype_code = 'CPP' then
    --
    ben_cvg_cache.cppplncvg_getdets
      (p_plip_id        => p_epe_plip_id
      ,p_effective_date => p_effective_date
      --
      ,p_inst_set       => p_inst_set
      ,p_inst_count     => p_inst_count
      );
    --
  elsif p_cvgtype_code = 'PLN' then
    --
    -- Get the PLNCVG details
    --
    ben_cvg_cache.plnplncvg_getdets
      (p_pln_id         => p_epe_pl_id
      ,p_effective_date => p_effective_date
      --
      ,p_inst_set       => p_inst_set
      ,p_inst_count     => p_inst_count
      );
    --
  elsif p_cvgtype_code = 'COP' then
    --
    ben_cvg_cache.copplncvg_getdets
      (p_oipl_id        => p_epe_oipl_id
      ,p_effective_date => p_effective_date
      --
      ,p_inst_set       => p_inst_set
      ,p_inst_count     => p_inst_count
      );
    --
  end if;
  --
end epeplncvg_getdets;
--
procedure plnplncvg_getdets
  (p_pln_id                in     number
  ,p_effective_date        in     date
  --
  ,p_inst_set                 out nocopy ben_cvg_cache.g_epeplncvg_cache
  ,p_inst_count               out nocopy number
  )
is
  --
  l_proc varchar2(72) := g_package||'plnplncvg_getdets';
  --
  l_inst_rec          g_epeplncvg_cache_rec;
  l_row_num           pls_integer;
  --
  cursor c_cursor
    (c_pln_id         in     number
    ,c_effective_date in     date
    )
  is
    select cvg.cvg_amt_calc_mthd_id,
           cvg.comp_lvl_fctr_id,
           cvg.cvg_mlt_cd,
           cvg.bndry_perd_cd,
           cvg.bnft_typ_cd,
           cvg.val,
           cvg.nnmntry_uom,
           cvg.mx_val,
           cvg.mn_val,
           cvg.incrmt_val,
           cvg.rt_typ_cd,
           cvg.business_group_id,
           cvg.rndg_cd,
           cvg.rndg_rl,
           cvg.val_calc_rl,
           cvg.dflt_val,
           cvg.entr_val_at_enrt_flag,
           cvg.lwr_lmt_val,
           cvg.lwr_lmt_calc_rl,
           cvg.upr_lmt_val,
           cvg.upr_lmt_calc_rl,
           pln.cvg_incr_r_decr_only_cd,
           pln.bnft_or_option_rstrctn_cd,
           pln.mx_cvg_rl,
           pln.mn_cvg_rl
    from   ben_cvg_amt_calc_mthd_f cvg,
           ben_pl_f pln
    where  pln.pl_id = c_pln_id
    and    cvg.pl_id = pln.pl_id
    and    c_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date
    and    c_effective_date
           between cvg.effective_start_date
           and     cvg.effective_end_date;
  --
begin
  --
  -- Get the PLNCVG details
  --
  open c_cursor
    (c_pln_id         => p_pln_id
    ,c_effective_date => p_effective_date
    );
  fetch c_cursor into l_inst_rec;
  if c_cursor%found then
    --
    p_inst_set(0) := l_inst_rec;
    --
  end if;
  close c_cursor;
  --
end plnplncvg_getdets;
--
procedure cppplncvg_getdets
  (p_plip_id               in     number
  ,p_effective_date        in     date
  --
  ,p_inst_set                 out nocopy ben_cvg_cache.g_epeplncvg_cache
  ,p_inst_count               out nocopy number
  )
is
  --
  l_proc varchar2(72) := g_package||'cppplncvg_getdets ';
  --
  l_inst_rec          g_epeplncvg_cache_rec;
  l_row_num           pls_integer;
  --
  cursor c_cursor
    (c_plip_id        in     number
    ,c_effective_date in     date
    )
  is
    select cvg.cvg_amt_calc_mthd_id,
           cvg.comp_lvl_fctr_id,
           cvg.cvg_mlt_cd,
           cvg.bndry_perd_cd,
           cvg.bnft_typ_cd,
           cvg.val,
           cvg.nnmntry_uom,
           cvg.mx_val,
           cvg.mn_val,
           cvg.incrmt_val,
           cvg.rt_typ_cd,
           cvg.business_group_id,
           cvg.rndg_cd,
           cvg.rndg_rl,
           cvg.val_calc_rl,
           cvg.dflt_val,
           cvg.entr_val_at_enrt_flag,
           cvg.lwr_lmt_val,
           cvg.lwr_lmt_calc_rl,
           cvg.upr_lmt_val,
           cvg.upr_lmt_calc_rl,
           pln.cvg_incr_r_decr_only_cd,
           pln.bnft_or_option_rstrctn_cd,
           pln.mx_cvg_rl,
           pln.mn_cvg_rl
    from   ben_cvg_amt_calc_mthd_f cvg,
           ben_plip_f cpp,
           ben_pl_f pln
    where  cpp.plip_id = c_plip_id
    and    cvg.plip_id = cpp.plip_id
    and    cpp.pl_id   = pln.pl_id
    and    c_effective_date
           between cpp.effective_start_date
           and     cpp.effective_end_date
    and    c_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date
    and    c_effective_date
           between cvg.effective_start_date
           and     cvg.effective_end_date;
  --
begin
  --
  -- Get the PLNCVG details
  --
  open c_cursor
    (c_plip_id        => p_plip_id
    ,c_effective_date => p_effective_date
    );
  fetch c_cursor into l_inst_rec;
  if c_cursor%found then
    --
    p_inst_set(0) := l_inst_rec;
    --
  end if;
  --
  close c_cursor;
  --
end cppplncvg_getdets ;
--
procedure copplncvg_getdets
  (p_oipl_id               in     number
  ,p_effective_date        in     date
  --
  ,p_inst_set                 out nocopy ben_cvg_cache.g_epeplncvg_cache
  ,p_inst_count               out nocopy number
  )
is
  --
  l_proc varchar2(72) := g_package||'copplncvg_getdets';
  --
  l_inst_rec          g_epeplncvg_cache_rec;
  l_row_num           pls_integer;
  --
  cursor c_cursor
    (c_oipl_id        in     number
    ,c_effective_date in     date
    )
  is
    select cvg.cvg_amt_calc_mthd_id,
           cvg.comp_lvl_fctr_id,
           cvg.cvg_mlt_cd,
           cvg.bndry_perd_cd,
           cvg.bnft_typ_cd,
           cvg.val,
           cvg.nnmntry_uom,
           cvg.mx_val,
           cvg.mn_val,
           cvg.incrmt_val,
           cvg.rt_typ_cd,
           cvg.business_group_id,
           cvg.rndg_cd,
           cvg.rndg_rl,
           cvg.val_calc_rl,
           cvg.dflt_val,
           cvg.entr_val_at_enrt_flag,
           cvg.lwr_lmt_val,
           cvg.lwr_lmt_calc_rl,
           cvg.upr_lmt_val,
           cvg.upr_lmt_calc_rl,
           pln.cvg_incr_r_decr_only_cd,
           pln.bnft_or_option_rstrctn_cd,
           pln.mx_cvg_rl,
           pln.mn_cvg_rl
    from   ben_cvg_amt_calc_mthd_f cvg,
           ben_oipl_f cop,
           ben_pl_f pln
    where  cop.oipl_id = c_oipl_id
    and    cvg.oipl_id = cop.oipl_id
    and    cop.pl_id   = pln.pl_id
    and    c_effective_date
           between cop.effective_start_date
           and     cop.effective_end_date
    and    c_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date
    and    c_effective_date
           between cvg.effective_start_date
           and     cvg.effective_end_date;
  --
begin
  --
  -- Get the PLNCVG details
  --
  open c_cursor
    (c_oipl_id        => p_oipl_id
    ,c_effective_date => p_effective_date
    );
  fetch c_cursor into l_inst_rec;
  if c_cursor%found then
    --
    p_inst_set(0) := l_inst_rec;
    --
  end if;
  close c_cursor;
  --
end copplncvg_getdets;
--
procedure epecobjtree_getcvgdets
  (p_epe_id         in     number
  ,p_epe_pl_id      in     number
  ,p_epe_plip_id    in     number
  ,p_epe_oipl_id    in     number
  ,p_effective_date in     date
  --
  ,p_cvg_set           out nocopy ben_cvg_cache.g_epeplncvg_cache
  )
is
  --
  l_proc       varchar2(72) := g_package||'epecobjtree_getcvgdets';
  --
  l_cvg        ben_cvg_cache.g_epeplncvg_cache;
  l_inst_count pls_integer;
  --
begin
  --

  -- Bug 4968171 - Query coverage details in this order : OIPL, PLN, PLIP
  --
  ben_cvg_cache.epeplncvg_getdets
        (p_epe_id         => p_epe_id
        ,p_epe_pl_id      => p_epe_pl_id
        ,p_epe_plip_id    => p_epe_plip_id
        ,p_epe_oipl_id    => p_epe_oipl_id
        ,p_effective_date => p_effective_date
        ,p_cvgtype_code   => 'COP'
        --
        ,p_inst_set       => l_cvg
        ,p_inst_count     => l_inst_count
	);
  --
  if l_cvg.count = 0
  then
    --
    ben_cvg_cache.epeplncvg_getdets
    (p_epe_id         => p_epe_id
    ,p_epe_pl_id      => p_epe_pl_id
    ,p_epe_plip_id    => p_epe_plip_id
    ,p_epe_oipl_id    => p_epe_oipl_id
    ,p_effective_date => p_effective_date
    ,p_cvgtype_code   => 'PLN'
    --
    ,p_inst_set       => l_cvg
    ,p_inst_count     => l_inst_count
    );
    --
    if l_cvg.count = 0
    then
      --
      ben_cvg_cache.epeplncvg_getdets
        (p_epe_id         => p_epe_id
        ,p_epe_pl_id      => p_epe_pl_id
        ,p_epe_plip_id    => p_epe_plip_id
        ,p_epe_oipl_id    => p_epe_oipl_id
        ,p_effective_date => p_effective_date
        ,p_cvgtype_code   => 'CPP'
        --
        ,p_inst_set       => l_cvg
        ,p_inst_count     => l_inst_count
        );
      --
    end if;
    --
  end if;
  --
  -- Set OUT parameters
  --
  p_cvg_set := l_cvg;
  --
end epecobjtree_getcvgdets;
--
end ben_cvg_cache;

/
