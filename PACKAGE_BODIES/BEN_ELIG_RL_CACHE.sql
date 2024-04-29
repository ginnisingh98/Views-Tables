--------------------------------------------------------
--  DDL for Package Body BEN_ELIG_RL_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIG_RL_CACHE" as
/* $Header: benelrch.pkb 120.0.12010000.2 2008/11/16 16:15:23 krupani ship $ */
--
/*
+==============================================================================+
|                        Copyright (c) 1997 Oracle Corporation                 |
|                           Redwood Shores, California, USA                    |
|                               All rights reserved.                           |
+==============================================================================+
--
History
  Version    Date       Author     Comments
  ---------  ---------  ---------- --------------------------------------------
  115.0      11-Jun-99  bbulusu    Created.
  115.1      02-Aug-99  gperry     Added support for plip and ptip.
  115.2      30-Dec-02  ikasire    nocopy changes
  115.3      28-Oct-03  mhoyes     Revamp for bug 3125540.
  115.4      30-Mar-04  ikasire    fonm changes
  115.5      16-Nov-08  krupani    Bug 7537076: passed p_lf_evt_ocrd_dt while calling write_odcache
  -----------------------------------------------------------------------------
*/
--
-- Globals.
--
  g_package varchar2(50) := 'ben_elig_rl_cache.';
--
g_odlookup        ben_cache.g_cache_lookup_table;
g_nxelenum number;
g_odinst          ben_elig_rl_cache.g_elig_rl_inst_tbl;
g_odcached        pls_integer := 0;
--
g_hash_key        pls_integer := 1299827;
g_hash_jump       pls_integer := 100;
--
procedure write_odcache
  (p_effective_date in    date
  ,p_pgm_id         in    number default hr_api.g_number
  ,p_ptip_id        in    number default hr_api.g_number
  ,p_plip_id        in    number default hr_api.g_number
  ,p_pl_id          in    number default hr_api.g_number
  ,p_oipl_id        in    number default hr_api.g_number
  --
  ,p_hv               out nocopy  pls_integer
  )
is
  --
  l_proc varchar2(72) := 'write_odcache';
  --
  l_odlookup_rec    ben_cache.g_cache_lookup;
  --
  l_hv              pls_integer;
  l_not_hash_found  boolean;
  l_torrwnum        pls_integer;
  l_starttorele_num pls_integer;
  --
  cursor c_pgminstance
    (c_pgm_id         number
    ,c_effective_date date
    )
  is
    select  tab1.prtn_elig_id,
            tab1.pgm_id,
            tab1.pl_id,
            tab1.oipl_id,
            tab1.plip_id,
            tab1.ptip_id,
            tab2.formula_id,
            tab2.mndtry_flag,
            tab2.ordr_to_aply_num
    from  ben_prtn_elig_f tab1,
          ben_prtn_eligy_rl_f tab2
    where tab1.pgm_id = c_pgm_id
    and tab1.prtn_elig_id = tab2.prtn_elig_id
    and c_effective_date
      between tab1.effective_start_date and tab1.effective_end_date
    and c_effective_date
      between tab2.effective_start_date and tab2.effective_end_date
    order by decode(tab2.mndtry_flag, 'Y', 2, 3),
             tab2.ordr_to_aply_num;
  --
  l_instance c_pgminstance%rowtype;
  --
  cursor c_ptipinstance
    (c_ptip_id        number
    ,c_effective_date date
    )
  is
    select  tab1.prtn_elig_id,
            tab1.pgm_id,
            tab1.pl_id,
            tab1.oipl_id,
            tab1.plip_id,
            tab1.ptip_id,
            tab2.formula_id,
            tab2.mndtry_flag,
            tab2.ordr_to_aply_num
    from  ben_prtn_elig_f tab1,
          ben_prtn_eligy_rl_f tab2
    where tab1.ptip_id = c_ptip_id
    and tab1.prtn_elig_id = tab2.prtn_elig_id
    and c_effective_date
      between tab1.effective_start_date and tab1.effective_end_date
    and c_effective_date
      between tab2.effective_start_date and tab2.effective_end_date
    order by decode(tab2.mndtry_flag, 'Y', 2, 3),
             tab2.ordr_to_aply_num;
  --
  cursor c_plipinstance
    (c_plip_id        number
    ,c_effective_date date
    )
  is
    select  tab1.prtn_elig_id,
            tab1.pgm_id,
            tab1.pl_id,
            tab1.oipl_id,
            tab1.plip_id,
            tab1.ptip_id,
            tab2.formula_id,
            tab2.mndtry_flag,
            tab2.ordr_to_aply_num
    from  ben_prtn_elig_f tab1,
          ben_prtn_eligy_rl_f tab2
    where tab1.plip_id = c_plip_id
    and tab1.prtn_elig_id = tab2.prtn_elig_id
    and c_effective_date
      between tab1.effective_start_date and tab1.effective_end_date
    and c_effective_date
      between tab2.effective_start_date and tab2.effective_end_date
    order by decode(tab2.mndtry_flag, 'Y', 2, 3),
             tab2.ordr_to_aply_num;
  --
  cursor c_plinstance
    (c_pl_id          number
    ,c_effective_date date
    )
  is
    select  tab1.prtn_elig_id,
            tab1.pgm_id,
            tab1.pl_id,
            tab1.oipl_id,
            tab1.plip_id,
            tab1.ptip_id,
            tab2.formula_id,
            tab2.mndtry_flag,
            tab2.ordr_to_aply_num
    from  ben_prtn_elig_f tab1,
          ben_prtn_eligy_rl_f tab2
    where tab1.pl_id = c_pl_id
    and tab1.prtn_elig_id = tab2.prtn_elig_id
    and c_effective_date
      between tab1.effective_start_date and tab1.effective_end_date
    and c_effective_date
      between tab2.effective_start_date and tab2.effective_end_date
    order by decode(tab2.mndtry_flag, 'Y', 2, 3),
             tab2.ordr_to_aply_num;
  --
  cursor c_oiplinstance
    (c_oipl_id        number
    ,c_effective_date date
    )
  is
    select  tab1.prtn_elig_id,
            tab1.pgm_id,
            tab1.pl_id,
            tab1.oipl_id,
            tab1.plip_id,
            tab1.ptip_id,
            tab2.formula_id,
            tab2.mndtry_flag,
            tab2.ordr_to_aply_num
    from  ben_prtn_elig_f tab1,
          ben_prtn_eligy_rl_f tab2
    where tab1.oipl_id = c_oipl_id
    and tab1.prtn_elig_id = tab2.prtn_elig_id
    and c_effective_date
      between tab1.effective_start_date and tab1.effective_end_date
    and c_effective_date
      between tab2.effective_start_date and tab2.effective_end_date
    order by decode(tab2.mndtry_flag, 'Y', 2, 3),
             tab2.ordr_to_aply_num;
  --
begin
  --
  hr_utility.set_location(' Entering  '||l_proc,10);
  --
  -- Get the instance details
  --
  l_hv := mod(nvl(p_pgm_id,1)+nvl(p_ptip_id,2)+nvl(p_plip_id,3)
          +nvl(p_pl_id,4)+nvl(p_oipl_id,5),g_hash_key);
  --
  -- Get a unique hash value
  --
  if g_odlookup.exists(l_hv) then
    --
    if nvl(g_odlookup(l_hv).id,-1)        = nvl(p_pgm_id,-1)
      and nvl(g_odlookup(l_hv).fk_id,-1)  = nvl(p_ptip_id,-1)
      and nvl(g_odlookup(l_hv).fk1_id,-1) = nvl(p_plip_id,-1)
      and nvl(g_odlookup(l_hv).fk2_id,-1) = nvl(p_pl_id,-1)
      and nvl(g_odlookup(l_hv).fk3_id,-1) = nvl(p_oipl_id,-1)
    then
      --
      null;
      --
    else
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_hv := l_hv+g_hash_jump;
        --
        -- Check if the hash index exists, and compare the values
        --
        if g_odlookup.exists(l_hv) then
          --
          if nvl(g_odlookup(l_hv).id,-1)        = nvl(p_pgm_id,-1)
            and nvl(g_odlookup(l_hv).fk_id,-1)  = nvl(p_ptip_id,-1)
            and nvl(g_odlookup(l_hv).fk1_id,-1) = nvl(p_plip_id,-1)
            and nvl(g_odlookup(l_hv).fk2_id,-1) = nvl(p_pl_id,-1)
            and nvl(g_odlookup(l_hv).fk3_id,-1) = nvl(p_oipl_id,-1)
          then
            --
            l_not_hash_found := true;
            exit;
            --
          else
            --
            l_not_hash_found := false;
            --
          end if;
          --
        else
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  g_odlookup(l_hv).id     := p_pgm_id;
  g_odlookup(l_hv).fk_id  := p_ptip_id;
  g_odlookup(l_hv).fk1_id := p_plip_id;
  g_odlookup(l_hv).fk2_id := p_pl_id;
  g_odlookup(l_hv).fk3_id := p_oipl_id;
  --
  hr_utility.set_location(' Dn Look  '||l_proc,10);
  --
  l_starttorele_num := nvl(g_nxelenum,0);
  l_torrwnum        := l_starttorele_num;
  --
  hr_utility.set_location(' Bef inst loop  '||l_proc,10);
  --
  if p_pgm_id is not null then
    --
    open c_pgminstance
      (c_pgm_id         => p_pgm_id
      ,c_effective_date => p_effective_date
      );
    --
  elsif p_ptip_id is not null then
    --
    open c_ptipinstance
      (c_ptip_id        => p_ptip_id
      ,c_effective_date => p_effective_date
      );
    --
  elsif p_plip_id is not null then
    --
    open c_plipinstance
      (c_plip_id        => p_plip_id
      ,c_effective_date => p_effective_date
      );
    --
  elsif p_pl_id is not null then
    --
    open c_plinstance
      (c_pl_id          => p_pl_id
      ,c_effective_date => p_effective_date
      );
    --
  elsif p_oipl_id is not null then
    --
    open c_oiplinstance
      (c_oipl_id        => p_oipl_id
      ,c_effective_date => p_effective_date
      );
    --
  end if;
  --
  loop
    --
    if p_pgm_id is not null then
      --
      fetch c_pgminstance into l_instance;
      exit when c_pgminstance%NOTFOUND;
      --
    elsif p_ptip_id is not null then
      --
      fetch c_ptipinstance into l_instance;
      exit when c_ptipinstance%NOTFOUND;
      --
    elsif p_plip_id is not null then
      --
      fetch c_plipinstance into l_instance;
      exit when c_plipinstance%NOTFOUND;
      --
    elsif p_pl_id is not null then
      --
      fetch c_plinstance into l_instance;
      exit when c_plinstance%NOTFOUND;
      --
    elsif p_oipl_id is not null then
      --
      fetch c_oiplinstance into l_instance;
      exit when c_oiplinstance%NOTFOUND;
      --
    end if;
    --
    hr_utility.set_location(' Assign inst  '||l_proc,10);
    --
    g_odinst(l_torrwnum).id               := l_instance.prtn_elig_id;
    g_odinst(l_torrwnum).pgm_id           := l_instance.pgm_id;
    g_odinst(l_torrwnum).pl_id            := l_instance.pl_id;
    g_odinst(l_torrwnum).oipl_id          := l_instance.oipl_id;
    g_odinst(l_torrwnum).plip_id          := l_instance.plip_id;
    g_odinst(l_torrwnum).ptip_id          := l_instance.ptip_id;
    g_odinst(l_torrwnum).formula_id       := l_instance.formula_id;
    g_odinst(l_torrwnum).mndtry_flag      := l_instance.mndtry_flag;
    g_odinst(l_torrwnum).ordr_to_aply_num := l_instance.ordr_to_aply_num;
    --
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  if p_pgm_id is not null then
    --
    close c_pgminstance;
    --
  elsif p_ptip_id is not null then
    --
    close c_ptipinstance;
    --
  elsif p_plip_id is not null then
    --
    close c_plipinstance;
    --
  elsif p_pl_id is not null then
    --
    close c_plinstance;
    --
  elsif p_oipl_id is not null then
    --
    close c_oiplinstance;
    --
  end if;
  --
  -- Check if any rows were found
  --
  if l_torrwnum > nvl(g_nxelenum,0)
  then
    --
    g_odlookup(l_hv).starttorele_num := l_starttorele_num;
    g_odlookup(l_hv).endtorele_num   := l_torrwnum-1;
    g_nxelenum := l_torrwnum;
    --
    p_hv := l_hv;
    --
  else
    --
    -- Delete and free PGA with assignment
    --
    g_odlookup.delete(l_hv);
    g_odlookup(l_hv) := l_odlookup_rec;
    --
    p_hv := null;
    --
  end if;
  --
  hr_utility.set_location(' Leaving  '||l_proc,10);
end write_odcache;
--
procedure get_elig_rl_cache
  (p_pgm_id            in number
  ,p_pl_id             in number
  ,p_oipl_id           in number
  ,p_plip_id           in number
  ,p_ptip_id           in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set          out nocopy ben_elig_rl_cache.g_elig_rl_inst_tbl
  ,p_inst_count        out nocopy number
  )
is
  --
  l_inst_set       ben_elig_rl_cache.g_elig_rl_inst_tbl;
  --
  l_hv             pls_integer;
  l_hash_found     boolean;
  l_insttorrw_num  pls_integer;
  l_torrwnum       pls_integer;
  --
  l_clash_count    pls_integer;
  --FONM
  l_fonm_cvg_strt_dt DATE ;
  --END FONM
begin
  --
  if g_odcached = 0
  then
    --
    -- Build the cache
    --
    clear_down_cache;
    --
    g_odcached := 1;
    --
  end if;
--  hr_utility.set_location(' Derive hv  '||l_proc,10);
  if ben_manage_life_events.fonm = 'Y'
      and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
     --
     l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
     --
  end if;
  --
  -- Get the instance details
  --
  l_hv := mod(nvl(p_pgm_id,1)+nvl(p_ptip_id,2)+nvl(p_plip_id,3)
          +nvl(p_pl_id,4)+nvl(p_oipl_id,5),g_hash_key);
  --
  -- Check if hashed value is already allocated
  --
  l_hash_found := false;
  --
  if g_odlookup.exists(l_hv) then
    --
    if nvl(g_odlookup(l_hv).id,-1)        = nvl(p_pgm_id,-1)
      and nvl(g_odlookup(l_hv).fk_id,-1)  = nvl(p_ptip_id,-1)
      and nvl(g_odlookup(l_hv).fk1_id,-1) = nvl(p_plip_id,-1)
      and nvl(g_odlookup(l_hv).fk2_id,-1) = nvl(p_pl_id,-1)
      and nvl(g_odlookup(l_hv).fk3_id,-1) = nvl(p_oipl_id,-1)
    then
      --
      null;
      --
    else
      --
      l_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      l_clash_count := 0;
      --
      while not l_hash_found loop
        --
        l_hv := l_hv+g_hash_jump;
        --
        if g_odlookup.exists(l_hv) then
          --
          -- Check if the hash index exists, and compare the values
          --
          if nvl(g_odlookup(l_hv).id,-1)        = nvl(p_pgm_id,-1)
            and nvl(g_odlookup(l_hv).fk_id,-1)  = nvl(p_ptip_id,-1)
            and nvl(g_odlookup(l_hv).fk1_id,-1) = nvl(p_plip_id,-1)
            and nvl(g_odlookup(l_hv).fk2_id,-1) = nvl(p_pl_id,-1)
            and nvl(g_odlookup(l_hv).fk3_id,-1) = nvl(p_oipl_id,-1)
          then
            --
            l_hash_found := true;
            exit;
            --
          else
            --
            l_clash_count := l_clash_count+1;
            l_hash_found := false;
            --
          end if;
          --
          -- Check for high clash counts and defrag
          --
          if l_clash_count > 50
          then
            --
            l_hv := null;
            clear_down_cache;
            exit;
            --
          end if;
          --
        else
          --
          l_hv := null;
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  else
    --
    l_hv := null;
    --
  end if;
  --
  if l_hv is null
  then
    --
    -- bug 7537076 : passed p_lf_evt_ocrd_dt while calling write_odcache instead of p_effective_date
    write_odcache
      (p_effective_date => nvl(l_fonm_cvg_strt_dt,p_lf_evt_ocrd_dt)
      ,p_pgm_id         => p_pgm_id
      ,p_pl_id          => p_pl_id
      ,p_oipl_id        => p_oipl_id
      ,p_plip_id        => p_plip_id
      ,p_ptip_id        => p_ptip_id
      --
      ,p_hv             => l_hv
      );
    --
  end if;
  --
--  hr_utility.set_location(' Got hv  '||l_proc,10);
  --
  if l_hv is not null then
    --
    l_torrwnum := 0;
    --
--    hr_utility.set_location(' Get loop  '||l_proc,10);
    for l_insttorrw_num in g_odlookup(l_hv).starttorele_num ..
      g_odlookup(l_hv).endtorele_num
    loop
      --
      l_inst_set(l_torrwnum) := g_odinst(l_insttorrw_num);
      l_torrwnum := l_torrwnum+1;
      --
    end loop;
    --
--    hr_utility.set_location(' Dn Get loop  '||l_proc,10);
    --
  end if;
  --
  p_inst_set   := l_inst_set;
  p_inst_count := l_inst_set.count;
  --
--  hr_utility.set_location(' Leaving  '||l_proc,10);
exception
  --
  when no_data_found then
    --
    p_inst_set   := l_inst_set;
    p_inst_count := 0;
    --
end get_elig_rl_cache;
--
procedure clear_down_cache
is
  --
  l_odlookup ben_cache.g_cache_lookup_table;
  l_odinst   ben_elig_rl_cache.g_elig_rl_inst_tbl;
  --
begin
  --
  -- On demand cache structures
  --
  g_odlookup := l_odlookup;
  g_odinst   := l_odinst;
  g_odcached := 0;
  g_nxelenum := null;
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
end ben_elig_rl_cache;

/
