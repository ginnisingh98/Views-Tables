--------------------------------------------------------
--  DDL for Package Body BEN_LETRG_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LETRG_CACHE" as
/* $Header: beltrgch.pkb 120.0 2005/05/28 03:39:10 appldev noship $ */
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
  115.0      14-Sep-00	mhoyes     Created.
  115.1      01-May-01	mhoyes     Added PRV and PEN caches.
  115.2      22-May-01	mhoyes     Further tuned triggers.
  115.3      21-Jan-03  hmani      Modified for Triggering LE for Multiple table
					Enhancement.
  115.4      21-Feb-05  tjesumic  typ_cd added and checklist validated .
  -----------------------------------------------------------------------------
*/
--
-- Globals.
--
g_package       varchar2(50) := 'ben_letrg_cache.';
--
g_hash_key      number := ben_hash_utility.get_hash_key;
g_hash_jump     number := ben_hash_utility.get_hash_jump;
--
-- 0 - Always refresh
-- 1 - Initialise cache
-- 2 - Cache hit
--
g_egdlertrg_instance     g_egdlertrg_inst_tbl;
g_egdlertrg_cached       pls_integer := 0;
--
g_prvlertrg_instance     g_egdlertrg_inst_tbl;
g_prvlertrg_cached       pls_integer := 0;
--
g_penlertrg_instance     g_egdlertrg_inst_tbl;
g_penlertrg_cached       pls_integer := 0;
--


CURSOR c_chkpslexists
  (c_business_group_id NUMBER
  ,c_effective_date    DATE
  ,c_source_table      varchar2
  )
IS
  select 1
  from ben_per_info_chg_cs_ler_f psl
  where psl.business_group_id = c_business_group_id
  and c_effective_date
    between psl.effective_start_date and psl.effective_end_date
  and psl.source_table = c_source_table;
--
CURSOR c_chkrpcexists
  (c_business_group_id NUMBER
  ,c_effective_date    DATE
  ,c_source_table      varchar2
  )
IS
  select 1
  from ben_rltd_per_chg_cs_ler_f rpc
  where rpc.business_group_id = c_business_group_id
  and c_effective_date
    between rpc.effective_start_date and rpc.effective_end_date
  and rpc.source_table = c_source_table;
--
CURSOR c_lerdets
  (c_business_group_id NUMBER
  ,c_effective_date    DATE
  ,c_source_table      varchar2
  ,c_status            varchar2
  )
IS
  select ler.ler_id
  ,      ler.typ_cd
  ,      ler.ocrd_dt_det_cd
  from   ben_ler_f  ler
  where  ler.business_group_id = c_business_group_id
  and   c_effective_date between ler.effective_start_date
  and   ler.effective_end_date
  and ( c_status = 'I' or ler.typ_cd in ('COMP','GSP','ABS','CHECKLIST') )
  and    ((exists
         (select 1
           from   ben_per_info_chg_cs_ler_f psl
           ,      ben_ler_per_info_cs_ler_f lpl
           where  source_table               = c_source_table
           and    psl.per_info_chg_cs_ler_id = lpl.per_info_chg_cs_ler_id
           and    lpl.business_group_id    = psl.business_group_id
           and    lpl.business_group_id    = ler.business_group_id
           and    c_effective_date between psl.effective_start_date
           and    psl.effective_end_date
           and    lpl.ler_id                 = ler.ler_id)
  			)
  OR      (exists
           (select 1
            from   ben_rltd_per_chg_cs_ler_f rpc
            ,      ben_ler_rltd_per_cs_ler_f lrp
            where  source_table               = c_source_table
            and    lrp.business_group_id    = rpc.business_group_id
            and    lrp.business_group_id    = ler.business_group_id
            and    c_effective_date between rpc.effective_start_date
            and    rpc.effective_end_date
            and    rpc.rltd_per_chg_cs_ler_id = lrp.rltd_per_chg_cs_ler_id
            and    lrp.ler_id                 = ler.ler_id)
             ))
   order by ler.ler_id;
--
procedure write_egdlertrg_cache
  (p_business_group_id in     number
  ,p_effective_date    in     date
  )
is
  --
  TYPE g_number_table_type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
  --
  TYPE g_v230_table_type IS TABLE OF varchar2(30)
    INDEX BY BINARY_INTEGER;
  --
  l_ler_id_tab         g_number_table_type;
  l_ler_typ_cd_tab     g_v230_table_type;
  l_ocrd_dt_det_cd_tab g_v230_table_type;
  --
  l_hv              pls_integer;
  l_not_hash_found  boolean;
  --
  l_ele_num         pls_integer;

  --
  l_bool  BOOLEAN;
  l_status VARCHAR2(1);
  l_industry VARCHAR2(1);
--
  --
  CURSOR c_instance
    (c_business_group_id      NUMBER
    ,c_effective_date         DATE
    )
  IS
    SELECT   ler.ler_id,
             ler.typ_cd,
             ler.ocrd_dt_det_cd
    FROM     ben_ler_f ler
    WHERE    ler.business_group_id = c_business_group_id
    AND      c_effective_date BETWEEN ler.effective_start_date
                  AND ler.effective_end_date
    AND ( l_status = 'I' or ler.typ_cd in ('COMP','GSP','ABS','CHECKLIST') )
    AND      (
                    (
                          EXISTS
                          (SELECT   1
                           FROM     ben_per_info_chg_cs_ler_f psl,
                                    ben_ler_per_info_cs_ler_f lpl
                           WHERE    psl.source_table = 'BEN_ELIG_DPNT'
                           AND      psl.per_info_chg_cs_ler_id =
                                                     lpl.per_info_chg_cs_ler_id
                           AND      c_effective_date BETWEEN psl.effective_start_date
                                        AND psl.effective_end_date
                           AND      lpl.ler_id = ler.ler_id
                           AND      c_effective_date BETWEEN lpl.effective_start_date
                                        AND lpl.effective_end_date)
                   )
                 OR (
                          EXISTS
                          (SELECT   1
                           FROM     ben_ler_rltd_per_cs_ler_f lrp,
                                    ben_rltd_per_chg_cs_ler_f rpc
                           WHERE    rpc.source_table = 'BEN_ELIG_DPNT'
                           AND      c_effective_date BETWEEN rpc.effective_start_date
                                        AND rpc.effective_end_date
                           AND      rpc.rltd_per_chg_cs_ler_id =
                                                     lrp.rltd_per_chg_cs_ler_id
                           AND      lrp.ler_id = ler.ler_id
                           AND      c_effective_date BETWEEN lrp.effective_start_date
                                        AND lrp.effective_end_date)
                   ));
  --
begin
  --
  --
  -- Check if definitions exist for the source table and BGP ID combination
  --
  l_ele_num := 0;
  l_bool :=fnd_installation.get(appl_id => 805
                     ,dep_appl_id =>805
                     ,status => l_status
                     ,industry => l_industry);

  for row in c_instance
    (c_business_group_id => p_business_group_id
    ,c_effective_date    => p_effective_date
    )
  loop
    g_egdlertrg_instance(l_ele_num).ler_id         := row.ler_id;
    g_egdlertrg_instance(l_ele_num).typ_cd         := row.typ_cd;
    g_egdlertrg_instance(l_ele_num).ocrd_dt_det_cd := row.ocrd_dt_det_cd;
    l_ele_num := l_ele_num+1;
  end loop;
  --
end write_egdlertrg_cache;
--
procedure get_egdlertrg_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_inst_set	       in out NOCOPY g_egdlertrg_inst_tbl
  )
is
  --
  l_proc varchar2(72) :=  'get_egdlertrg_dets';
  --
begin
  --
  -- check comp object type
  --
  if g_egdlertrg_cached < 2
  then
    --
    -- Write the cache
    --
    write_egdlertrg_cache
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      );
    --
    if g_egdlertrg_cached = 1
    then
      --
      g_egdlertrg_cached := 2;
      --
    end if;
    --
  end if;
  --
  p_inst_set := g_egdlertrg_instance;
  --
end get_egdlertrg_dets;
--
procedure write_prvlertrg_cache
  (p_business_group_id in     number
  ,p_effective_date    in     date
  )
is
  --
  l_ler_id_tab         benutils.g_number_table := benutils.g_number_table();
  l_ocrd_dt_det_cd_tab benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_ler_typ_cd_tab      benutils.g_v2_30_table  := benutils.g_v2_30_table();
  --
  l_ele_num         pls_integer;
  --
  l_dummy_number    pls_integer;
  l_found           boolean;
  l_source_table    varchar2(100);
  --
  l_bool  BOOLEAN;
  l_status VARCHAR2(1);
  l_industry VARCHAR2(1);
begin
  --
  --
  l_found        := FALSE;
  l_source_table := 'BEN_PRTT_RT_VAL';
  --
  open c_chkpslexists
    (c_business_group_id => p_business_group_id
    ,c_effective_date    => p_effective_date
    ,c_source_table      => l_source_table
    );
  fetch c_chkpslexists into l_dummy_number;
  if c_chkpslexists%notfound then
    --
    l_found := FALSE;
    --
    open c_chkrpcexists
      (c_business_group_id => p_business_group_id
      ,c_effective_date    => p_effective_date
      ,c_source_table      => l_source_table
      );
    fetch c_chkrpcexists into l_dummy_number;
    if c_chkrpcexists%notfound then
      --
      l_found := FALSE;
      --
    else
      --
      l_found := TRUE;
      --
    end if;
    close c_chkrpcexists;
    --
  else
    --
    l_found := TRUE;
    --
  end if;
  close c_chkpslexists;
  --
  if l_found then
    --
    l_ele_num := 0;
    l_bool :=fnd_installation.get(appl_id => 805
	                   ,dep_appl_id =>805
	                   ,status => l_status
	                   ,industry => l_industry);

    for row in c_lerdets
      (c_business_group_id => p_business_group_id
      ,c_effective_date    => p_effective_date
      ,c_source_table      => l_source_table
      ,c_status			   => l_status
      )
    loop
      g_prvlertrg_instance(l_ele_num).ler_id         := row.ler_id;
      g_prvlertrg_instance(l_ele_num).typ_cd         := row.typ_cd;
      g_prvlertrg_instance(l_ele_num).ocrd_dt_det_cd := row.ocrd_dt_det_cd;
      l_ele_num := l_ele_num+1;
    end loop;
    --
  else
    --
    g_prvlertrg_instance.delete;
    --
  end if;
  --
end write_prvlertrg_cache;
--
procedure get_prvlertrg_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_inst_set	       in out NOCOPY g_egdlertrg_inst_tbl
  )
is
  --
  l_proc varchar2(72) :=  'get_prvlertrg_dets';
  --
begin
  --
  -- check comp object type
  --
  if g_prvlertrg_cached < 2
  then
    --
    -- Write the cache
    --
    write_prvlertrg_cache
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      );
    --
    if g_prvlertrg_cached = 1
    then
      --
      g_prvlertrg_cached := 2;
      --
    end if;
    --
  end if;
  --
  p_inst_set := g_prvlertrg_instance;
  --
end get_prvlertrg_dets;
--
procedure write_penlertrg_cache
  (p_business_group_id in     number
  ,p_effective_date    in     date
  )
is
  --
  l_ler_id_tab         benutils.g_number_table := benutils.g_number_table();
  l_ocrd_dt_det_cd_tab benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_ler_typ_cd_tab     benutils.g_v2_30_table  := benutils.g_v2_30_table();
  --
  l_ele_num         pls_integer;
  --
  l_dummy_number    pls_integer;
  l_found           boolean;
  l_source_table    varchar2(100);
  --
  l_bool  BOOLEAN;
  l_status VARCHAR2(1);
  l_industry VARCHAR2(1);
  --

begin
  --
  --
  l_found        := FALSE;
  l_source_table := 'BEN_PRTT_ENRT_RSLT_F';
  --
  open c_chkpslexists
    (c_business_group_id => p_business_group_id
    ,c_effective_date    => p_effective_date
    ,c_source_table      => l_source_table
    );
  fetch c_chkpslexists into l_dummy_number;
  if c_chkpslexists%notfound then
    --
    l_found := FALSE;
    --
    open c_chkrpcexists
      (c_business_group_id => p_business_group_id
      ,c_effective_date    => p_effective_date
      ,c_source_table      => l_source_table
      );
    fetch c_chkrpcexists into l_dummy_number;
    if c_chkrpcexists%notfound then
      --
      l_found := FALSE;
      --
    else
      --
      l_found := TRUE;
      --
    end if;
    close c_chkrpcexists;
    --
  else
    --
    l_found := TRUE;
    --
  end if;
  close c_chkpslexists;
  --
  if l_found then
    --
    l_ele_num := 0;
    l_bool :=fnd_installation.get(appl_id => 805
	                   ,dep_appl_id =>805
	                   ,status => l_status
	                   ,industry => l_industry);

    for row in c_lerdets
      (c_business_group_id => p_business_group_id
      ,c_effective_date    => p_effective_date
      ,c_source_table      => l_source_table
      ,c_status			   => l_status
      )
    loop
      g_penlertrg_instance(l_ele_num).ler_id         := row.ler_id;
      g_penlertrg_instance(l_ele_num).typ_cd         := row.typ_cd;
      g_penlertrg_instance(l_ele_num).ocrd_dt_det_cd := row.ocrd_dt_det_cd;
      l_ele_num := l_ele_num+1;
    end loop;
    --
  else
    --
    g_penlertrg_instance.delete;
    --
  end if;
  --
end write_penlertrg_cache;
--
procedure get_penlertrg_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_inst_set	       in out NOCOPY g_egdlertrg_inst_tbl
  )
is
  --
  l_proc varchar2(72) :=  'get_penlertrg_dets';
  --
begin
  --
  -- check comp object type
  --
  if g_penlertrg_cached < 2
  then
    --
    -- Write the cache
    --
    write_penlertrg_cache
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      );
    --
    if g_penlertrg_cached = 1
    then
      --
      g_penlertrg_cached := 2;
      --
    end if;
    --
  end if;
  --
  p_inst_set := g_penlertrg_instance;
  --
end get_penlertrg_dets;
--
------------------------------------------------------------------------
-- DELETE ALL CACHED DATA
------------------------------------------------------------------------
procedure clear_down_cache
is

  l_ler_init  g_egdlertrg_inst_tbl;

begin
  --
  g_egdlertrg_instance.delete;
  g_egdlertrg_cached := 1;
  --
  g_prvlertrg_instance.delete;
  g_prvlertrg_cached := 1;
  --
  g_penlertrg_instance.delete;
  g_penlertrg_cached := 1;
  --
end clear_down_cache;
--
procedure set_no_cache
is

  l_ler_init  g_egdlertrg_inst_tbl;

begin
  --
  g_egdlertrg_instance.delete;
  g_egdlertrg_cached := 0;
  --
  g_prvlertrg_instance.delete;
  g_prvlertrg_cached := 0;
  --
  g_penlertrg_instance.delete;
  g_penlertrg_cached := 0;
  --
end set_no_cache;
--
end ben_letrg_cache;

/
