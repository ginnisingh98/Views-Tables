--------------------------------------------------------
--  DDL for Package Body BEN_COBJ_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COBJ_CACHE" as
/* $Header: becobjch.pkb 120.2 2006/03/13 17:13:16 kmahendr noship $ */
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
  115.1      28-Jun-99	mhoyes     Added pgm,ptip,plip,prel and etpr caches.
  115.2      25-Sep-00	mhoyes   - Upgraded to new caching.
  115.3      26-Oct-00	mhoyes   - Fixed record initialization problems.
  115.4      26-Oct-00	mhoyes   - Initialized record in exception for get routines
                                   rather than on entry of the get routines.
  115.5      17-May-01  maagrawa   Added columns to pgm,pl,plip,ptip,oipl
                                   records and modified their queries.
  115.6      22-May-01  mhoyes   - Upgraded comp object caches to be context
                                   sensitive. Hence when the refresh routine is
                                   not called then the cache will use SQL.
  115.7      26-Jul-01  ikasire    Bug 1895874 adding nip_dflt_flag column
                                   to ben_pl_f table
  115.10     29-Nov-05  abparekh   Bug 4766118 - Added ALWS_QDRO_FLAG to G_PL_INST_ROW
  115.11     13-Mar-06  kmahendr   bug#5082245 - added svgs_pl_flag to g_pl_inst_row
  -----------------------------------------------------------------------------
*/
--
-- Globals.
--
g_package varchar2(50) := 'ben_cobj_cache.';
g_hash_key number      := ben_hash_utility.get_hash_key;
g_hash_jump number     := ben_hash_utility.get_hash_jump;
--
procedure write_oiplip_cache
  (p_business_group_id in     number
  ,p_effective_date    in     date
  )
is
  --
  l_proc varchar2(72) :=  'write_oiplip_cache';
  --
  l_hv              pls_integer;
  --
  cursor c_instance
    (c_business_group_id      NUMBER
    ,c_effective_date         DATE
    )
  is
    SELECT TAB1.OIPLIP_ID,
           TAB1.PLIP_ID,
           TAB1.OIPL_ID
    FROM BEN_OIPLIP_F TAB1
    WHERE TAB1.BUSINESS_GROUP_ID = c_business_group_id
    AND   c_effective_date
      BETWEEN TAB1.EFFECTIVE_START_DATE AND TAB1.EFFECTIVE_END_DATE;
  --
begin
  --
  for objinst in c_instance
    (c_business_group_id => p_business_group_id
    ,c_effective_date    => p_effective_date
    )
  loop
    --
    l_hv := mod(objinst.oiplip_id,ben_hash_utility.get_hash_key);
    --
    while ben_cobj_cache.g_oiplip_instance.exists(l_hv)
    loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
    ben_cobj_cache.g_oiplip_instance(l_hv) := objinst;
    --
  end loop;
  --
end write_oiplip_cache;
--
procedure get_oiplip_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_oiplip_id         in     number default null
  ,p_inst_row	       in out NOCOPY g_oiplip_inst_row
  )
is
  --
  l_proc varchar2(72) :=  'get_oiplip_dets';
  --
  l_hv               pls_integer;
  l_reset g_oiplip_inst_row;
  --
  cursor c_instance
    (c_oiplip_id      NUMBER
    ,c_effective_date DATE
    )
  is
    SELECT TAB1.OIPLIP_ID,
           TAB1.PLIP_ID,
           TAB1.OIPL_ID
    FROM BEN_OIPLIP_F TAB1
    WHERE TAB1.oiplip_id = c_oiplip_id
    AND   c_effective_date
      BETWEEN TAB1.EFFECTIVE_START_DATE AND TAB1.EFFECTIVE_END_DATE;
  --
begin
  --
  if g_oiplip_cached > 0
  then
    --
    if g_oiplip_cached = 1 then
      --
      write_oiplip_cache
        (p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        );
      --
      g_oiplip_cached := 2;
      --
    end if;
    --
    -- Get the instance details
    --
    l_hv := mod(p_oiplip_id,ben_hash_utility.get_hash_key);
    --
    if g_oiplip_instance(l_hv).oiplip_id = p_oiplip_id
    then
       -- Matched row
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes if none exists at current index the NO_DATA_FOUND expection
      -- will fire
      --
      l_hv := l_hv+g_hash_jump;
      while g_oiplip_instance(l_hv).oiplip_id <> p_oiplip_id loop
        --
        l_hv := l_hv+g_hash_jump;
        --
      end loop;
      --
    end if;
    --
    p_inst_row := g_oiplip_instance(l_hv);
    --
  else
    --
    open c_instance
      (c_oiplip_id      => p_oiplip_id
      ,c_effective_date => p_effective_date
      );
    fetch c_instance into p_inst_row;
    close c_instance;
    --
  end if;
  --
exception
  --
  when no_data_found then
    --
    p_inst_row := l_reset;
    --
end get_oiplip_dets;
--
procedure write_opt_cache
  (p_business_group_id in     number
  ,p_effective_date    in     date
  )
is
  --
  l_hv              pls_integer;
  --
  cursor c_instance
    (c_business_group_id      NUMBER
    ,c_effective_date         DATE
    )
  is
    SELECT tab1.opt_id
          ,tab1.name
          ,tab1.effective_start_date
          ,tab1.effective_end_date
          ,tab1.rqd_perd_enrt_nenrt_uom
          ,tab1.rqd_perd_enrt_nenrt_val
          ,tab1.rqd_perd_enrt_nenrt_rl
    FROM BEN_OPT_F TAB1
    WHERE TAB1.BUSINESS_GROUP_ID = c_business_group_id
    AND   c_effective_date
      BETWEEN TAB1.EFFECTIVE_START_DATE AND TAB1.EFFECTIVE_END_DATE;
  --
begin
  --
  for objinst in c_instance
    (c_business_group_id => p_business_group_id
    ,c_effective_date    => p_effective_date
    )
  loop
    --
    l_hv := mod(objinst.opt_id,ben_hash_utility.get_hash_key);
    --
    while ben_cobj_cache.g_opt_instance.exists(l_hv)
    loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
    ben_cobj_cache.g_opt_instance(l_hv) := objinst;
    --
  end loop;
  --
end write_opt_cache;
--
procedure get_opt_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_opt_id            in     number default null
  ,p_inst_row	       in out NOCOPY g_opt_inst_row
  )
is
  --
  l_proc varchar2(72) :=  'get_opt_dets';
  --
  l_hv               pls_integer;
  l_reset g_opt_inst_row;
  --
  cursor c_instance
    (c_opt_id         NUMBER
    ,c_effective_date DATE
    )
  is
    SELECT tab1.opt_id
          ,tab1.name
          ,tab1.effective_start_date
          ,tab1.effective_end_date
          ,tab1.rqd_perd_enrt_nenrt_uom
          ,tab1.rqd_perd_enrt_nenrt_val
          ,tab1.rqd_perd_enrt_nenrt_rl
    FROM BEN_OPT_F TAB1
    WHERE TAB1.opt_id = c_opt_id
    AND   c_effective_date
      BETWEEN TAB1.EFFECTIVE_START_DATE AND TAB1.EFFECTIVE_END_DATE;
  --
begin
  --
  if g_opt_cached > 0
  then
    --
    if g_opt_cached = 1 then
      --
      write_opt_cache
        (p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        );
      --
      g_opt_cached := 2;
      --
    end if;
    --
    -- Get the instance details
    --
    l_hv := mod(p_opt_id,ben_hash_utility.get_hash_key);
    --
    if g_opt_instance(l_hv).opt_id = p_opt_id
    then
       -- Matched row
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes if none exists at current index the NO_DATA_FOUND expection
      -- will fire
      --
      l_hv := l_hv+g_hash_jump;
      while g_opt_instance(l_hv).opt_id <> p_opt_id loop
        --
        l_hv := l_hv+g_hash_jump;
        --
      end loop;
      --
    end if;
    --
    p_inst_row := g_opt_instance(l_hv);
    --
  else
    --
    open c_instance
      (c_opt_id         => p_opt_id
      ,c_effective_date => p_effective_date
      );
    fetch c_instance into p_inst_row;
    close c_instance;
    --
  end if;
  --
exception
  --
  when no_data_found then
    --
    p_inst_row := l_reset;
    --
end get_opt_dets;
--
procedure write_oipl_cache
  (p_business_group_id in     number
  ,p_effective_date    in     date
  )
is
  --
  l_proc varchar2(72) :=  'write_oipl_cache';
  --
  l_hv              pls_integer;
  --
  cursor c_instance
    (c_business_group_id      NUMBER
    ,c_effective_date         DATE
    )
  is
    SELECT tab1.oipl_id
          ,tab1.effective_start_date
          ,tab1.effective_end_date
          ,tab1.opt_id
          ,tab1.pl_id
          ,tab1.trk_inelig_per_flag
          ,tab1.ordr_num
          ,tab1.elig_apls_flag
          ,tab1.prtn_elig_ovrid_alwd_flag
          ,tab1.vrfy_fmly_mmbr_cd
          ,tab1.vrfy_fmly_mmbr_rl
          ,tab1.per_cvrd_cd
          ,tab1.dflt_flag
          ,tab1.mndtry_flag
          ,tab1.mndtry_rl
          ,tab1.auto_enrt_flag
          ,tab1.auto_enrt_mthd_rl
          ,tab1.enrt_cd
          ,tab1.enrt_rl
          ,tab1.dflt_enrt_cd
          ,tab1.dflt_enrt_det_rl
          ,tab1.rqd_perd_enrt_nenrt_uom
          ,tab1.rqd_perd_enrt_nenrt_val
          ,tab1.rqd_perd_enrt_nenrt_rl
          ,tab1.actl_prem_id
          ,tab1.postelcn_edit_rl
    FROM BEN_OIPL_F TAB1
    WHERE TAB1.BUSINESS_GROUP_ID = c_business_group_id
    AND   c_effective_date
      BETWEEN TAB1.EFFECTIVE_START_DATE AND TAB1.EFFECTIVE_END_DATE;
  --
begin
  --
  for objinst in c_instance
    (c_business_group_id => p_business_group_id
    ,c_effective_date    => p_effective_date
    )
  loop
    --
    l_hv := mod(objinst.oipl_id,ben_hash_utility.get_hash_key);
    --
    while ben_cobj_cache.g_oipl_instance.exists(l_hv)
    loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
    ben_cobj_cache.g_oipl_instance(l_hv) := objinst;
    --
  end loop;
  --
end write_oipl_cache;
--
procedure get_oipl_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_oipl_id           in     number default null
  ,p_inst_row	       in out NOCOPY g_oipl_inst_row
  )
is
  --
  l_proc varchar2(72) :=  'get_oipl_dets';
  l_reset g_oipl_inst_row;
  --
  l_hv               pls_integer;
  --
  cursor c_instance
    (c_oipl_id        NUMBER
    ,c_effective_date DATE
    )
  is
    SELECT tab1.oipl_id
          ,tab1.effective_start_date
          ,tab1.effective_end_date
          ,tab1.opt_id
          ,tab1.pl_id
          ,tab1.trk_inelig_per_flag
          ,tab1.ordr_num
          ,tab1.elig_apls_flag
          ,tab1.prtn_elig_ovrid_alwd_flag
          ,tab1.vrfy_fmly_mmbr_cd
          ,tab1.vrfy_fmly_mmbr_rl
          ,tab1.per_cvrd_cd
          ,tab1.dflt_flag
          ,tab1.mndtry_flag
          ,tab1.mndtry_rl
          ,tab1.auto_enrt_flag
          ,tab1.auto_enrt_mthd_rl
          ,tab1.enrt_cd
          ,tab1.enrt_rl
          ,tab1.dflt_enrt_cd
          ,tab1.dflt_enrt_det_rl
          ,tab1.rqd_perd_enrt_nenrt_uom
          ,tab1.rqd_perd_enrt_nenrt_val
          ,tab1.rqd_perd_enrt_nenrt_rl
          ,tab1.actl_prem_id
          ,tab1.postelcn_edit_rl
    FROM BEN_OIPL_F TAB1
    WHERE TAB1.oipl_id = c_oipl_id
    AND   c_effective_date
      BETWEEN TAB1.EFFECTIVE_START_DATE AND TAB1.EFFECTIVE_END_DATE;
  --
begin
  --
  if g_oipl_cached > 0
  then
    --
    if g_oipl_cached = 1 then
      --
      write_oipl_cache
        (p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        );
      --
      g_oipl_cached := 2;
      --
    end if;
    --
    -- Get the instance details
    --
    l_hv := mod(p_oipl_id,ben_hash_utility.get_hash_key);
    --
    if g_oipl_instance(l_hv).oipl_id = p_oipl_id
    then
       -- Matched row
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes if none exists at current index the NO_DATA_FOUND expection
      -- will fire
      --
      l_hv := l_hv+g_hash_jump;
      while g_oipl_instance(l_hv).oipl_id <> p_oipl_id loop
        --
        l_hv := l_hv+g_hash_jump;
        --
      end loop;
      --
    end if;
    --
    p_inst_row := g_oipl_instance(l_hv);
    --
  else
    --
    open c_instance
      (c_oipl_id        => p_oipl_id
      ,c_effective_date => p_effective_date
      );
    fetch c_instance into p_inst_row;
    close c_instance;
    --
  end if;
  --
exception
  --
  when no_data_found then
    --
    p_inst_row := l_reset;
    --
end get_oipl_dets;
--
procedure write_pgm_cache
  (p_business_group_id in     number
  ,p_effective_date    in     date
  )
is
  --
  l_proc varchar2(72) :=  'write_pgm_cache';
  --
  l_hv              pls_integer;
  --
  cursor c_instance
    (c_business_group_id      NUMBER
    ,c_effective_date         DATE
    )
  is
    SELECT tab1.pgm_id,
           tab1.effective_start_date,
           tab1.effective_end_date,
           tab1.enrt_cvg_strt_dt_cd,
           tab1.enrt_cvg_strt_dt_rl,
           tab1.enrt_cvg_end_dt_cd,
           tab1.enrt_cvg_end_dt_rl,
           tab1.rt_strt_dt_cd,
           tab1.rt_strt_dt_rl,
           tab1.rt_end_dt_cd,
           tab1.rt_end_dt_rl,
           tab1.elig_apls_flag,
           tab1.prtn_elig_ovrid_alwd_flag,
           tab1.trk_inelig_per_flag,
           tab1.vrfy_fmly_mmbr_cd,
           tab1.vrfy_fmly_mmbr_rl,
           tab1.dpnt_dsgn_lvl_cd,
           tab1.dpnt_dsgn_cd,
           tab1.dpnt_cvg_strt_dt_cd,
           tab1.dpnt_cvg_strt_dt_rl,
           tab1.dpnt_cvg_end_dt_cd,
           tab1.dpnt_cvg_end_dt_rl,
           tab1.pgm_typ_cd
    FROM BEN_PGM_F TAB1
    WHERE TAB1.BUSINESS_GROUP_ID = c_business_group_id
    AND   c_effective_date
      BETWEEN TAB1.EFFECTIVE_START_DATE AND TAB1.EFFECTIVE_END_DATE;
  --
begin
  --
  for objinst in c_instance
    (c_business_group_id => p_business_group_id
    ,c_effective_date    => p_effective_date
    )
  loop
    --
    l_hv := mod(objinst.pgm_id,ben_hash_utility.get_hash_key);
    --
    while ben_cobj_cache.g_pgm_instance.exists(l_hv)
    loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
    ben_cobj_cache.g_pgm_instance(l_hv) := objinst;
    --
  end loop;
  --
end write_pgm_cache;
--
procedure get_pgm_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_pgm_id            in     number default null
  ,p_inst_row	       in out NOCOPY g_pgm_inst_row
  )
is
  --
  l_proc varchar2(72) :=  'get_pgm_dets';
  --
  l_reset g_pgm_inst_row;
  l_hv               pls_integer;
  --
  cursor c_instance
    (c_pgm_id         NUMBER
    ,c_effective_date DATE
    )
  is
    SELECT tab1.pgm_id,
           tab1.effective_start_date,
           tab1.effective_end_date,
           tab1.enrt_cvg_strt_dt_cd,
           tab1.enrt_cvg_strt_dt_rl,
           tab1.enrt_cvg_end_dt_cd,
           tab1.enrt_cvg_end_dt_rl,
           tab1.rt_strt_dt_cd,
           tab1.rt_strt_dt_rl,
           tab1.rt_end_dt_cd,
           tab1.rt_end_dt_rl,
           tab1.elig_apls_flag,
           tab1.prtn_elig_ovrid_alwd_flag,
           tab1.trk_inelig_per_flag,
           tab1.vrfy_fmly_mmbr_cd,
           tab1.vrfy_fmly_mmbr_rl,
           tab1.dpnt_dsgn_lvl_cd,
           tab1.dpnt_dsgn_cd,
           tab1.dpnt_cvg_strt_dt_cd,
           tab1.dpnt_cvg_strt_dt_rl,
           tab1.dpnt_cvg_end_dt_cd,
           tab1.dpnt_cvg_end_dt_rl,
           tab1.pgm_typ_cd
    FROM BEN_PGM_F TAB1
    WHERE TAB1.pgm_id = c_pgm_id
    AND   c_effective_date
      BETWEEN TAB1.EFFECTIVE_START_DATE AND TAB1.EFFECTIVE_END_DATE;
  --
begin
  --
  if g_pgm_cached > 0
  then
    --
    if g_pgm_cached = 1 then
      --
      write_pgm_cache
        (p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        );
      --
      g_pgm_cached := 2;
      --
    end if;
    --
    -- Get the instance details
    --
    l_hv := mod(p_pgm_id,ben_hash_utility.get_hash_key);
    --
    if g_pgm_instance(l_hv).pgm_id = p_pgm_id
    then
       -- Matched row
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes if none exists at current index the NO_DATA_FOUND expection
      -- will fire
      --
      l_hv := l_hv+g_hash_jump;
      while g_pgm_instance(l_hv).pgm_id <> p_pgm_id loop
        --
        l_hv := l_hv+g_hash_jump;
        --
      end loop;
      --
    end if;
    --
    p_inst_row   := g_pgm_instance(l_hv);
    --
  else
    --
    open c_instance
      (c_pgm_id         => p_pgm_id
      ,c_effective_date => p_effective_date
      );
    fetch c_instance into p_inst_row;
    close c_instance;
    --
  end if;
  --
exception
  --
  when no_data_found then
    --
    p_inst_row := l_reset;
    --
end get_pgm_dets;
--
procedure write_ptip_cache
  (p_business_group_id in     number
  ,p_effective_date    in     date
  )
is
  --
  l_proc varchar2(72) :=  'write_ptip_cache';
  --
  l_hv              pls_integer;
  --
  cursor c_instance
    (c_business_group_id      NUMBER
    ,c_effective_date         DATE
    )
  is
    SELECT tab1.ptip_id,
           tab1.effective_start_date,
           tab1.effective_end_date,
           tab1.enrt_cvg_strt_dt_cd,
           tab1.enrt_cvg_strt_dt_rl,
           tab1.enrt_cvg_end_dt_cd,
           tab1.enrt_cvg_end_dt_rl,
           tab1.rt_strt_dt_cd,
           tab1.rt_strt_dt_rl,
           tab1.rt_end_dt_cd,
           tab1.rt_end_dt_rl,
           tab1.elig_apls_flag,
           tab1.prtn_elig_ovrid_alwd_flag,
           tab1.trk_inelig_per_flag,
           tab1.ordr_num,
           tab1.vrfy_fmly_mmbr_cd,
           tab1.vrfy_fmly_mmbr_rl,
           tab1.rqd_perd_enrt_nenrt_tm_uom,
           tab1.rqd_perd_enrt_nenrt_val,
           tab1.rqd_perd_enrt_nenrt_rl,
           tab1.dpnt_dsgn_cd,
           tab1.dpnt_cvg_strt_dt_cd,
           tab1.dpnt_cvg_strt_dt_rl,
           tab1.dpnt_cvg_end_dt_cd,
           tab1.dpnt_cvg_end_dt_rl,
           tab1.postelcn_edit_rl
    FROM BEN_PTIP_F TAB1
    WHERE TAB1.BUSINESS_GROUP_ID = c_business_group_id
    AND   c_effective_date
      BETWEEN TAB1.EFFECTIVE_START_DATE AND TAB1.EFFECTIVE_END_DATE;
  --
begin
  --
  for objinst in c_instance
    (c_business_group_id => p_business_group_id
    ,c_effective_date    => p_effective_date
    )
  loop
    --
    l_hv := mod(objinst.ptip_id,ben_hash_utility.get_hash_key);
    --
    while ben_cobj_cache.g_ptip_instance.exists(l_hv)
    loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
    ben_cobj_cache.g_ptip_instance(l_hv) := objinst;
    --
  end loop;
  --
end write_ptip_cache;
--
procedure get_ptip_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_ptip_id           in     number default null
  ,p_inst_row	       in out NOCOPY g_ptip_inst_row
  )
is
  --
  l_proc varchar2(72) :=  'get_ptip_dets';
  --
  l_reset g_ptip_inst_row;
  l_hv               pls_integer;
  --
  cursor c_instance
    (c_ptip_id        NUMBER
    ,c_effective_date DATE
    )
  is
    SELECT tab1.ptip_id,
           tab1.effective_start_date,
           tab1.effective_end_date,
           tab1.enrt_cvg_strt_dt_cd,
           tab1.enrt_cvg_strt_dt_rl,
           tab1.enrt_cvg_end_dt_cd,
           tab1.enrt_cvg_end_dt_rl,
           tab1.rt_strt_dt_cd,
           tab1.rt_strt_dt_rl,
           tab1.rt_end_dt_cd,
           tab1.rt_end_dt_rl,
           tab1.elig_apls_flag,
           tab1.prtn_elig_ovrid_alwd_flag,
           tab1.trk_inelig_per_flag,
           tab1.ordr_num,
           tab1.vrfy_fmly_mmbr_cd,
           tab1.vrfy_fmly_mmbr_rl,
           tab1.rqd_perd_enrt_nenrt_tm_uom,
           tab1.rqd_perd_enrt_nenrt_val,
           tab1.rqd_perd_enrt_nenrt_rl,
           tab1.dpnt_dsgn_cd,
           tab1.dpnt_cvg_strt_dt_cd,
           tab1.dpnt_cvg_strt_dt_rl,
           tab1.dpnt_cvg_end_dt_cd,
           tab1.dpnt_cvg_end_dt_rl,
           tab1.postelcn_edit_rl
    FROM BEN_PTIP_F TAB1
    WHERE TAB1.ptip_id = c_ptip_id
    AND   c_effective_date
      BETWEEN TAB1.EFFECTIVE_START_DATE AND TAB1.EFFECTIVE_END_DATE;
  --
begin
  --
  if g_ptip_cached > 0
  then
    --
    if g_ptip_cached = 1 then
      --
      write_ptip_cache
        (p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        );
      --
      g_ptip_cached := 2;
      --
    end if;
    --
    -- Get the instance details
    --
    l_hv := mod(p_ptip_id,ben_hash_utility.get_hash_key);
    --
    if g_ptip_instance(l_hv).ptip_id = p_ptip_id
    then
       -- Matched row
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes if none exists at current index the NO_DATA_FOUND expection
      -- will fire
      --
      l_hv := l_hv+g_hash_jump;
      while g_ptip_instance(l_hv).ptip_id <> p_ptip_id loop
        --
        l_hv := l_hv+g_hash_jump;
        --
      end loop;
      --
    end if;
    --
    p_inst_row   := g_ptip_instance(l_hv);
    --
  else
    --
    open c_instance
      (c_ptip_id        => p_ptip_id
      ,c_effective_date => p_effective_date
      );
    fetch c_instance into p_inst_row;
    close c_instance;
    --
  end if;
  --
exception
  --
  when no_data_found then
    --
    p_inst_row := l_reset;
    --
end get_ptip_dets;
--
procedure write_plip_cache
  (p_business_group_id in     number
  ,p_effective_date    in     date
  )
is
  --
  l_proc varchar2(72) :=  'write_plip_cache';
  --
  l_hv              pls_integer;
  --
  cursor c_instance
    (c_business_group_id      NUMBER
    ,c_effective_date         DATE
    )
  is
    SELECT tab1.plip_id,
           tab1.effective_start_date,
           tab1.effective_end_date,
           tab1.enrt_cvg_strt_dt_cd,
           tab1.enrt_cvg_strt_dt_rl,
           tab1.enrt_cvg_end_dt_cd,
           tab1.enrt_cvg_end_dt_rl,
           tab1.rt_strt_dt_cd,
           tab1.rt_strt_dt_rl,
           tab1.rt_end_dt_cd,
           tab1.rt_end_dt_rl,
           tab1.elig_apls_flag,
           tab1.prtn_elig_ovrid_alwd_flag,
           tab1.trk_inelig_per_flag,
           tab1.ordr_num,
           tab1.vrfy_fmly_mmbr_cd,
           tab1.vrfy_fmly_mmbr_rl,
           tab1.bnft_or_option_rstrctn_cd,
           tab1.pl_id,
           tab1.pgm_id,
           tab1.cvg_incr_r_decr_only_cd,
           tab1.mx_cvg_mlt_incr_num,
           tab1.mx_cvg_mlt_incr_wcf_num,
           tab1.postelcn_edit_rl
    FROM BEN_PLIP_F TAB1
    WHERE TAB1.BUSINESS_GROUP_ID = c_business_group_id
    AND   c_effective_date
      BETWEEN TAB1.EFFECTIVE_START_DATE AND TAB1.EFFECTIVE_END_DATE;
  --
begin
  --
  for objinst in c_instance
    (c_business_group_id => p_business_group_id
    ,c_effective_date    => p_effective_date
    )
  loop
    --
    l_hv := mod(objinst.plip_id,ben_hash_utility.get_hash_key);
    --
    while ben_cobj_cache.g_plip_instance.exists(l_hv)
    loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
    ben_cobj_cache.g_plip_instance(l_hv) := objinst;
    --
  end loop;
  --
end write_plip_cache;
--
procedure get_plip_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_plip_id            in     number default null
  ,p_inst_row	       in out NOCOPY g_plip_inst_row
  )
is
  --
  l_proc varchar2(72) :=  'get_plip_dets';
  --
  l_reset g_plip_inst_row;
  l_hv               pls_integer;
  --
  cursor c_instance
    (c_plip_id        NUMBER
    ,c_effective_date DATE
    )
  is
    SELECT tab1.plip_id,
           tab1.effective_start_date,
           tab1.effective_end_date,
           tab1.enrt_cvg_strt_dt_cd,
           tab1.enrt_cvg_strt_dt_rl,
           tab1.enrt_cvg_end_dt_cd,
           tab1.enrt_cvg_end_dt_rl,
           tab1.rt_strt_dt_cd,
           tab1.rt_strt_dt_rl,
           tab1.rt_end_dt_cd,
           tab1.rt_end_dt_rl,
           tab1.elig_apls_flag,
           tab1.prtn_elig_ovrid_alwd_flag,
           tab1.trk_inelig_per_flag,
           tab1.ordr_num,
           tab1.vrfy_fmly_mmbr_cd,
           tab1.vrfy_fmly_mmbr_rl,
           tab1.bnft_or_option_rstrctn_cd,
           tab1.pl_id,
           tab1.pgm_id,
           tab1.cvg_incr_r_decr_only_cd,
           tab1.mx_cvg_mlt_incr_num,
           tab1.mx_cvg_mlt_incr_wcf_num,
           tab1.postelcn_edit_rl
    FROM BEN_PLIP_F TAB1
    WHERE TAB1.plip_id = c_plip_id
    AND   c_effective_date
      BETWEEN TAB1.EFFECTIVE_START_DATE AND TAB1.EFFECTIVE_END_DATE;
  --
begin
  --
  if g_plip_cached > 0
  then
    --
    if g_plip_cached = 1 then
      --
      write_plip_cache
        (p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        );
      --
      g_plip_cached := 2;
      --
    end if;
    --
    -- Get the instance details
    --
    l_hv := mod(p_plip_id,ben_hash_utility.get_hash_key);
    --
    if g_plip_instance(l_hv).plip_id = p_plip_id
    then
       -- Matched row
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes if none exists at current index the NO_DATA_FOUND expection
      -- will fire
      --
      l_hv := l_hv+g_hash_jump;
      while g_plip_instance(l_hv).plip_id <> p_plip_id loop
        --
        l_hv := l_hv+g_hash_jump;
        --
      end loop;
      --
    end if;
    --
    p_inst_row   := g_plip_instance(l_hv);
    --
  else
    --
    open c_instance
      (c_plip_id        => p_plip_id
      ,c_effective_date => p_effective_date
      );
    fetch c_instance into p_inst_row;
    close c_instance;
    --
  end if;
  --
exception
  --
  when no_data_found then
    --
    p_inst_row := l_reset;
    --
end get_plip_dets;
--
procedure write_pl_cache
  (p_business_group_id in     number
  ,p_effective_date    in     date
  )
is
  --
  l_proc varchar2(72) :=  'write_pl_cache';
  --
  l_hv              pls_integer;
  --
  cursor c_instance
    (c_business_group_id      NUMBER
    ,c_effective_date         DATE
    )
  is
    SELECT tab1.pl_id,
           tab1.effective_start_date,
           tab1.effective_end_date,
           tab1.enrt_cvg_strt_dt_cd,
           tab1.enrt_cvg_strt_dt_rl,
           tab1.enrt_cvg_end_dt_cd,
           tab1.enrt_cvg_end_dt_rl,
           tab1.rt_strt_dt_cd,
           tab1.rt_strt_dt_rl,
           tab1.rt_end_dt_cd,
           tab1.rt_end_dt_rl,
           tab1.elig_apls_flag,
           tab1.prtn_elig_ovrid_alwd_flag,
           tab1.per_cvrd_cd,
           tab1.pl_typ_id,
           tab1.trk_inelig_per_flag,
           tab1.ordr_num,
           tab1.mx_wtg_dt_to_use_cd,
           tab1.mx_wtg_dt_to_use_rl,
           tab1.mx_wtg_perd_rl,
           tab1.mx_wtg_perd_prte_uom,
           tab1.mx_wtg_perd_prte_val,
           tab1.vrfy_fmly_mmbr_cd,
           tab1.vrfy_fmly_mmbr_rl,
           tab1.bnft_or_option_rstrctn_cd,
           tab1.nip_dflt_enrt_cd,
           tab1.nip_dflt_enrt_det_rl,
           tab1.rqd_perd_enrt_nenrt_uom,
           tab1.rqd_perd_enrt_nenrt_val,
           tab1.rqd_perd_enrt_nenrt_rl,
           tab1.cvg_incr_r_decr_only_cd,
           tab1.mx_cvg_mlt_incr_num,
           tab1.mx_cvg_mlt_incr_wcf_num,
           tab1.name,
           tab1.actl_prem_id,
           tab1.bnf_dsgn_cd,
           tab1.enrt_pl_opt_flag,
           tab1.dpnt_cvg_strt_dt_cd,
           tab1.dpnt_cvg_strt_dt_rl,
           tab1.dpnt_cvg_end_dt_cd,
           tab1.dpnt_cvg_end_dt_rl,
           tab1.alws_qmcso_flag,
           tab1.alws_qdro_flag, /* Bug 4766118 */
           tab1.dpnt_dsgn_cd,
           tab1.postelcn_edit_rl,
           tab1.dpnt_cvd_by_othr_apls_flag,
           tab1.nip_dflt_flag,
           tab1.svgs_pl_flag
    FROM BEN_PL_F TAB1
    WHERE TAB1.BUSINESS_GROUP_ID = c_business_group_id
    AND   c_effective_date
      BETWEEN TAB1.EFFECTIVE_START_DATE AND TAB1.EFFECTIVE_END_DATE;
  --
begin
  --
  for objinst in c_instance
    (c_business_group_id => p_business_group_id
    ,c_effective_date    => p_effective_date
    )
  loop
    --
    l_hv := mod(objinst.pl_id,ben_hash_utility.get_hash_key);
    --
    while ben_cobj_cache.g_pl_instance.exists(l_hv)
    loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
    ben_cobj_cache.g_pl_instance(l_hv) := objinst;
    --
  end loop;
  --
end write_pl_cache;
--
procedure get_pl_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_pl_id            in     number default null
  ,p_inst_row	       in out NOCOPY g_pl_inst_row
  )
is
  --
  l_proc varchar2(72) :=  'get_pl_dets';
  --
  l_reset g_pl_inst_row;
  l_hv               pls_integer;
  --
  cursor c_instance
    (c_pl_id          NUMBER
    ,c_effective_date DATE
    )
  is
    SELECT tab1.pl_id,
           tab1.effective_start_date,
           tab1.effective_end_date,
           tab1.enrt_cvg_strt_dt_cd,
           tab1.enrt_cvg_strt_dt_rl,
           tab1.enrt_cvg_end_dt_cd,
           tab1.enrt_cvg_end_dt_rl,
           tab1.rt_strt_dt_cd,
           tab1.rt_strt_dt_rl,
           tab1.rt_end_dt_cd,
           tab1.rt_end_dt_rl,
           tab1.elig_apls_flag,
           tab1.prtn_elig_ovrid_alwd_flag,
           tab1.per_cvrd_cd,
           tab1.pl_typ_id,
           tab1.trk_inelig_per_flag,
           tab1.ordr_num,
           tab1.mx_wtg_dt_to_use_cd,
           tab1.mx_wtg_dt_to_use_rl,
           tab1.mx_wtg_perd_rl,
           tab1.mx_wtg_perd_prte_uom,
           tab1.mx_wtg_perd_prte_val,
           tab1.vrfy_fmly_mmbr_cd,
           tab1.vrfy_fmly_mmbr_rl,
           tab1.bnft_or_option_rstrctn_cd,
           tab1.nip_dflt_enrt_cd,
           tab1.nip_dflt_enrt_det_rl,
           tab1.rqd_perd_enrt_nenrt_uom,
           tab1.rqd_perd_enrt_nenrt_val,
           tab1.rqd_perd_enrt_nenrt_rl,
           tab1.cvg_incr_r_decr_only_cd,
           tab1.mx_cvg_mlt_incr_num,
           tab1.mx_cvg_mlt_incr_wcf_num,
           tab1.name,
           tab1.actl_prem_id,
           tab1.bnf_dsgn_cd,
           tab1.enrt_pl_opt_flag,
           tab1.dpnt_cvg_strt_dt_cd,
           tab1.dpnt_cvg_strt_dt_rl,
           tab1.dpnt_cvg_end_dt_cd,
           tab1.dpnt_cvg_end_dt_rl,
           tab1.alws_qmcso_flag,
           tab1.alws_qdro_flag,   /* Bug 4766118 */
           tab1.dpnt_dsgn_cd,
           tab1.postelcn_edit_rl,
           tab1.dpnt_cvd_by_othr_apls_flag,
           tab1.nip_dflt_flag,
           tab1.SVGS_PL_FLAG
    FROM BEN_PL_F TAB1
    WHERE TAB1.pl_id = c_pl_id
    AND   c_effective_date
      BETWEEN TAB1.EFFECTIVE_START_DATE AND TAB1.EFFECTIVE_END_DATE;
  --
begin
  --
  if g_pl_cached > 0
  then
    --
    if g_pl_cached = 1 then
      --
      write_pl_cache
        (p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        );
      --
      g_pl_cached := 2;
      --
    end if;
    --
    -- Get the instance details
    --
    l_hv := mod(p_pl_id,ben_hash_utility.get_hash_key);
    --
    if g_pl_instance(l_hv).pl_id = p_pl_id
    then
       -- Matched row
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes if none exists at current index the NO_DATA_FOUND expection
      -- will fire
      --
      l_hv := l_hv+g_hash_jump;
      while g_pl_instance(l_hv).pl_id <> p_pl_id loop
        --
        l_hv := l_hv+g_hash_jump;
        --
      end loop;
      --
    end if;
    --
    p_inst_row   := g_pl_instance(l_hv);
    --
  else
    --
    open c_instance
      (c_pl_id          => p_pl_id
      ,c_effective_date => p_effective_date
      );
    fetch c_instance into p_inst_row;
    close c_instance;
    --
  end if;
  --
exception
  --
  when no_data_found then
    --
    p_inst_row := l_reset;
    --
end get_pl_dets;
--
procedure write_etpr_cache
  (p_business_group_id in     number
  ,p_effective_date    in     date
  )
is
  --
  l_hv              pls_integer;
  --
  cursor c_instance
    (c_business_group_id      NUMBER
    ,c_effective_date         DATE
    )
  is
    SELECT tab1.elig_to_prte_rsn_id
          ,tab1.effective_start_date
          ,tab1.effective_end_date
          ,tab1.ler_id
          ,tab1.pgm_id
          ,tab1.ptip_id
          ,tab1.plip_id
          ,tab1.pl_id
          ,tab1.oipl_id
          ,tab1.wait_perd_dt_to_use_cd
          ,tab1.wait_perd_dt_to_use_rl
          ,tab1.wait_perd_rl
          ,tab1.wait_perd_uom
          ,tab1.wait_perd_val
          ,tab1.prtn_eff_strt_dt_rl
          ,tab1.prtn_eff_end_dt_rl
          ,tab1.prtn_eff_strt_dt_cd
          ,tab1.prtn_eff_end_dt_cd
          ,tab1.elig_inelig_cd
          ,tab1.ignr_prtn_ovrid_flag
          ,tab1.vrfy_fmly_mmbr_cd
          ,tab1.vrfy_fmly_mmbr_rl
    FROM ben_elig_to_prte_rsn_f TAB1
    WHERE TAB1.BUSINESS_GROUP_ID = c_business_group_id
    AND   c_effective_date
      BETWEEN TAB1.EFFECTIVE_START_DATE AND TAB1.EFFECTIVE_END_DATE;
  --
begin
  --
  for objinst in c_instance
    (c_business_group_id => p_business_group_id
    ,c_effective_date    => p_effective_date
    )
  loop
    --
    l_hv := ben_hash_utility.get_hashed_index(p_id => nvl(objinst.ler_id,1)
         +nvl(objinst.pgm_id,1)+nvl(objinst.ptip_id,1)+nvl(objinst.plip_id,1)
         +nvl(objinst.pl_id,1)+nvl(objinst.oipl_id,1));
    --
    while ben_cobj_cache.g_etpr_instance.exists(l_hv)
    loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
    ben_cobj_cache.g_etpr_instance(l_hv) := objinst;
    --
  end loop;
  --
end write_etpr_cache;
--
procedure get_etpr_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_ler_id            in     number default null
  ,p_pgm_id            in     number default null
  ,p_ptip_id           in     number default null
  ,p_plip_id           in     number default null
  ,p_pl_id             in     number default null
  ,p_oipl_id           in     number default null
  ,p_inst_row	       in out NOCOPY g_etpr_inst_row
  )
is
  --
  l_proc varchar2(72) :=  'get_etpr_dets';
  --
  l_hv               pls_integer;
  l_reset g_etpr_inst_row;
  --
begin
  --
  -- check comp object type
  --
  if not g_etpr_cached
  then
    --
    -- Build the cache
    --
    write_etpr_cache
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      );
    --
    g_etpr_cached := TRUE;
    --
  end if;
  --
  -- Get the instance details
  --
  l_hv := ben_hash_utility.get_hashed_index(p_id => nvl(p_ler_id,1)
       +nvl(p_pgm_id,1)+nvl(p_ptip_id,1)+nvl(p_plip_id,1)+nvl(p_pl_id,1)
       +nvl(p_oipl_id,1));
  --
  if nvl(g_etpr_instance(l_hv).ler_id,-1) = nvl(p_ler_id,-1)
    and nvl(g_etpr_instance(l_hv).pgm_id,-1) = nvl(p_pgm_id,-1)
    and nvl(g_etpr_instance(l_hv).ptip_id,-1) = nvl(p_ptip_id,-1)
    and nvl(g_etpr_instance(l_hv).plip_id,-1) = nvl(p_plip_id,-1)
    and nvl(g_etpr_instance(l_hv).pl_id,-1) = nvl(p_pl_id,-1)
    and nvl(g_etpr_instance(l_hv).oipl_id,-1) = nvl(p_oipl_id,-1)
  then
    -- Matched row
    null;
    --
  else
    --
    -- Loop through the hash using the jump routine to check further
    -- indexes if none exists at current index the NO_DATA_FOUND expection
    -- will fire
    --
    l_hv := l_hv+g_hash_jump;
    --
    loop
      --
      if nvl(g_etpr_instance(l_hv).ler_id,-1) = nvl(p_ler_id,-1)
        and nvl(g_etpr_instance(l_hv).pgm_id,-1) = nvl(p_pgm_id,-1)
        and nvl(g_etpr_instance(l_hv).ptip_id,-1) = nvl(p_ptip_id,-1)
        and nvl(g_etpr_instance(l_hv).plip_id,-1) = nvl(p_plip_id,-1)
        and nvl(g_etpr_instance(l_hv).pl_id,-1) = nvl(p_pl_id,-1)
        and nvl(g_etpr_instance(l_hv).oipl_id,-1) = nvl(p_oipl_id,-1)
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
  p_inst_row   := g_etpr_instance(l_hv);
  --
exception
  --
  when no_data_found then
    --
    p_inst_row := l_reset;
    --
end get_etpr_dets;
--
procedure write_prel_cache
  (p_business_group_id in     number
  ,p_effective_date    in     date
  )
is
  --
  l_hv              pls_integer;
  --
  cursor c_instance
    (c_business_group_id      NUMBER
    ,c_effective_date         DATE
    )
  is
    SELECT tab1.prtn_elig_id,
           tab1.effective_start_date,
           tab1.effective_end_date,
           tab1.pgm_id,
           tab1.ptip_id,
           tab1.plip_id,
           tab1.pl_id,
           tab1.oipl_id,
           tab1.wait_perd_dt_to_use_cd,
           tab1.wait_perd_dt_to_use_rl,
           tab1.wait_perd_rl,
           tab1.wait_perd_uom,
           tab1.wait_perd_val,
           tab1.prtn_eff_strt_dt_rl,
           tab1.prtn_eff_end_dt_rl,
           tab1.prtn_eff_strt_dt_cd,
           tab1.prtn_eff_end_dt_cd
    FROM ben_prtn_elig_f TAB1
    WHERE TAB1.BUSINESS_GROUP_ID = c_business_group_id
    AND   c_effective_date
      BETWEEN TAB1.EFFECTIVE_START_DATE AND TAB1.EFFECTIVE_END_DATE;
  --
begin
  --
  for objinst in c_instance
    (c_business_group_id => p_business_group_id
    ,c_effective_date    => p_effective_date
    )
  loop
    --
    l_hv := ben_hash_utility.get_hashed_index(p_id => nvl(objinst.pgm_id,1)
         +nvl(objinst.ptip_id,1)+nvl(objinst.plip_id,1)+nvl(objinst.pl_id,1)
         +nvl(objinst.oipl_id,1));
    --
    while ben_cobj_cache.g_prel_instance.exists(l_hv)
    loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
    ben_cobj_cache.g_prel_instance(l_hv) := objinst;
    --
  end loop;
  --
end write_prel_cache;
--
procedure get_prel_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_pgm_id            in     number default null
  ,p_ptip_id           in     number default null
  ,p_plip_id           in     number default null
  ,p_pl_id             in     number default null
  ,p_oipl_id           in     number default null
  ,p_inst_row	       in out NOCOPY g_prel_inst_row
  )
is
  --
  l_proc varchar2(72) :=  'get_prel_dets';
  --
  l_reset g_prel_inst_row;
  l_hv               pls_integer;
  --
begin
  --
  -- check comp object type
  --
  if not g_prel_cached
  then
    --
    -- Build the cache
    --
    write_prel_cache
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      );
    --
    g_prel_cached := TRUE;
    --
  end if;
  --
  -- Get the instance details
  --
  l_hv := ben_hash_utility.get_hashed_index(p_id => nvl(p_pgm_id,1)
       +nvl(p_ptip_id,1)+nvl(p_plip_id,1)+nvl(p_pl_id,1)
       +nvl(p_oipl_id,1));
  --
  if nvl(g_prel_instance(l_hv).pgm_id,-1) = nvl(p_pgm_id,-1)
    and nvl(g_prel_instance(l_hv).ptip_id,-1) = nvl(p_ptip_id,-1)
    and nvl(g_prel_instance(l_hv).plip_id,-1) = nvl(p_plip_id,-1)
    and nvl(g_prel_instance(l_hv).pl_id,-1) = nvl(p_pl_id,-1)
    and nvl(g_prel_instance(l_hv).oipl_id,-1) = nvl(p_oipl_id,-1)
  then
    -- Matched row
      --
    null;
    --
  else
    --
    -- Loop through the hash using the jump routine to check further
    -- indexes if none exists at current index the NO_DATA_FOUND expection
    -- will fire
    --
    l_hv := l_hv+g_hash_jump;
    --
    loop
      --
      if nvl(g_prel_instance(l_hv).pgm_id,-1) = nvl(p_pgm_id,-1)
        and nvl(g_prel_instance(l_hv).ptip_id,-1) = nvl(p_ptip_id,-1)
        and nvl(g_prel_instance(l_hv).plip_id,-1) = nvl(p_plip_id,-1)
        and nvl(g_prel_instance(l_hv).pl_id,-1) = nvl(p_pl_id,-1)
        and nvl(g_prel_instance(l_hv).oipl_id,-1) = nvl(p_oipl_id,-1)
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
  p_inst_row   := g_prel_instance(l_hv);
  --
exception
  --
  when no_data_found then
    --
    p_inst_row := l_reset;
    --
end get_prel_dets;
--
------------------------------------------------------------------------
-- DELETE ALL CACHED DATA
------------------------------------------------------------------------
procedure clear_down_cache
is

  l_pgm_currow    g_pgm_inst_row;
  l_ptip_currow   g_ptip_inst_row;
  l_plip_currow   g_plip_inst_row;
  l_pl_currow     g_pl_inst_row;
  l_oiplip_currow g_oiplip_inst_row;
  l_oipl_currow   g_oipl_inst_row;
  l_opt_currow    g_opt_inst_row;
  l_etpr_currow   g_etpr_inst_row;
  l_prel_currow   g_prel_inst_row;

begin
  --
  g_oiplip_instance.delete;
  g_oiplip_currow := l_oiplip_currow;
  g_oiplip_cached := 1;
  --
  g_opt_instance.delete;
  g_opt_currow := l_opt_currow;
  g_opt_cached := 1;
  --
  g_oipl_instance.delete;
  g_oipl_currow := l_oipl_currow;
  g_oipl_cached := 1;
  --
  g_pgm_instance.delete;
  g_pgm_currow := l_pgm_currow;
  g_pgm_cached := 1;
  --
  g_ptip_instance.delete;
  g_ptip_currow := l_ptip_currow;
  g_ptip_cached := 1;
  --
  g_plip_instance.delete;
  g_plip_currow := l_plip_currow;
  g_plip_cached := 1;
  --
  g_pl_instance.delete;
  g_pl_currow := l_pl_currow;
  g_pl_cached := 1;
  --
  g_etpr_instance.delete;
  g_etpr_cached := FALSE;
  --
  g_pgmetpr_currow  := l_etpr_currow;
  g_ptipetpr_currow := l_etpr_currow;
  g_plipetpr_currow := l_etpr_currow;
  g_pletpr_currow := l_etpr_currow;
  g_oipletpr_currow := l_etpr_currow;
  --
  g_prel_instance.delete;
  g_prel_cached := FALSE;
  g_pgmprel_currow  := l_prel_currow;
  g_ptipprel_currow := l_prel_currow;
  g_plipprel_currow := l_prel_currow;
  g_plprel_currow := l_prel_currow;
  g_oiplprel_currow := l_prel_currow;
  --
end clear_down_cache;
--
procedure set_no_cache_context
is

  l_pgm_currow    g_pgm_inst_row;
  l_ptip_currow   g_ptip_inst_row;
  l_plip_currow   g_plip_inst_row;
  l_pl_currow     g_pl_inst_row;
  l_oiplip_currow g_oiplip_inst_row;
  l_oipl_currow   g_oipl_inst_row;
  l_opt_currow    g_opt_inst_row;
  l_etpr_currow   g_etpr_inst_row;
  l_prel_currow   g_prel_inst_row;

begin
  g_oiplip_instance.delete;
  g_oiplip_currow := l_oiplip_currow;
  g_oiplip_cached := 0;
  --
  g_opt_instance.delete;
  g_opt_currow := l_opt_currow;
  g_opt_cached := 0;
  --
  g_oipl_instance.delete;
  g_oipl_currow := l_oipl_currow;
  g_oipl_cached := 0;
  --
  g_pgm_instance.delete;
  g_pgm_currow := l_pgm_currow;
  g_pgm_cached := 0;
  --
  g_ptip_instance.delete;
  g_ptip_currow := l_ptip_currow;
  g_ptip_cached := 0;
  --
  g_plip_instance.delete;
  g_plip_currow := l_plip_currow;
  g_plip_cached := 0;
  --
  g_pl_instance.delete;
  g_pl_currow := l_pl_currow;
  g_pl_cached := 0;
  --
  g_etpr_instance.delete;
  g_etpr_cached := FALSE;
  --
  g_pgmetpr_currow  := l_etpr_currow;
  g_ptipetpr_currow := l_etpr_currow;
  g_plipetpr_currow := l_etpr_currow;
  g_pletpr_currow := l_etpr_currow;
  g_oipletpr_currow := l_etpr_currow;
  --
  g_prel_instance.delete;
  g_prel_cached := FALSE;
  g_pgmprel_currow  := l_prel_currow;
  g_ptipprel_currow := l_prel_currow;
  g_plipprel_currow := l_prel_currow;
  g_plprel_currow := l_prel_currow;
  g_oiplprel_currow := l_prel_currow;
  --
end set_no_cache_context;
--
end ben_cobj_cache;

/
