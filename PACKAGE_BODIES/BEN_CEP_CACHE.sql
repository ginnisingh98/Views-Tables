--------------------------------------------------------
--  DDL for Package Body BEN_CEP_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CEP_CACHE" as
/* $Header: bencepch.pkb 120.1 2006/01/12 21:01:52 mhoyes noship $ */
--
procedure clear_down_cache
is
  --
  l_copcep_odlookup ben_cache.g_cache_lookup_table;
  l_copcep_odinst   g_cobcep_odcache :=  g_cobcep_odcache();
  --
begin
  --
  -- On demand cache structures
  --
  g_copcep_odlookup := l_copcep_odlookup;
  g_copcep_odinst   := l_copcep_odinst;
  g_copcep_odcached := 0;
  g_copcep_nxelenum := null;
  --
end clear_down_cache;
--
procedure cobcep_odgetdets
  (p_effective_date  in     date
  ,p_pgm_id          in     number
  ,p_pl_id           in     number
  ,p_oipl_id         in     number
  ,p_plip_id         in     number
  ,p_ptip_id         in     number
  -- Grade/Step
  ,p_vrbl_rt_prfl_id in     number
  --
  ,p_inst_set        in out nocopy  g_cobcep_odcache
  )
is
  --
  l_inst_set        g_cobcep_odcache :=  g_cobcep_odcache();
  --
  l_hv             pls_integer;
  l_hash_found     boolean;
  l_insttorrw_num  pls_integer;
  l_torrwnum       pls_integer;
  --
  l_clash_count    pls_integer;
  --
begin
  --
  if g_copcep_odcached = 0
  then
    --
    -- Build the cache
    --
    clear_down_cache;
    --
    g_copcep_odcached := 1;
    --
  end if;
--  hr_utility.set_location(' Derive hv  '||l_proc,10);
  --
  -- Get the instance details
  --
  -- Grade/Step
  l_hv := mod(nvl(p_pgm_id,1)+nvl(p_ptip_id,2)+nvl(p_plip_id,3)
          +nvl(p_pl_id,4)+nvl(p_oipl_id,5)
          +nvl(p_vrbl_rt_prfl_id,6)
            ,g_hash_key);
  --
  -- Check if hashed value is already allocated
  --
  l_hash_found := false;
  --
  if g_copcep_odlookup.exists(l_hv) then
    --
    if nvl(g_copcep_odlookup(l_hv).id,-1)        = nvl(p_pgm_id,-1)
      and nvl(g_copcep_odlookup(l_hv).fk_id,-1)  = nvl(p_ptip_id,-1)
      and nvl(g_copcep_odlookup(l_hv).fk1_id,-1) = nvl(p_plip_id,-1)
      and nvl(g_copcep_odlookup(l_hv).fk2_id,-1) = nvl(p_pl_id,-1)
      and nvl(g_copcep_odlookup(l_hv).fk3_id,-1) = nvl(p_oipl_id,-1)
      and nvl(g_copcep_odlookup(l_hv).fk4_id,-1) = nvl(p_vrbl_rt_prfl_id,-1)
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
/*
        l_hv := ben_hash_utility.get_next_hash_index(p_hash_index => l_hv);
*/
        --
        if g_copcep_odlookup.exists(l_hv) then
          --
          -- Check if the hash index exists, and compare the values
          --
          if nvl(g_copcep_odlookup(l_hv).id,-1)        = nvl(p_pgm_id,-1)
            and nvl(g_copcep_odlookup(l_hv).fk_id,-1)  = nvl(p_ptip_id,-1)
            and nvl(g_copcep_odlookup(l_hv).fk1_id,-1) = nvl(p_plip_id,-1)
            and nvl(g_copcep_odlookup(l_hv).fk2_id,-1) = nvl(p_pl_id,-1)
            and nvl(g_copcep_odlookup(l_hv).fk3_id,-1) = nvl(p_oipl_id,-1)
            -- Grade/Step
            and nvl(g_copcep_odlookup(l_hv).fk4_id,-1) = nvl(p_vrbl_rt_prfl_id,-1)
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

  if l_hv is null
  then
    --
    ben_cep_cache1.write_cobcep_odcache
      (p_effective_date => p_effective_date
      ,p_pgm_id         => p_pgm_id
      ,p_pl_id          => p_pl_id
      ,p_oipl_id        => p_oipl_id
      ,p_plip_id        => p_plip_id
      ,p_ptip_id        => p_ptip_id
      -- Grade/Step
      ,p_vrbl_rt_prfl_id       => p_vrbl_rt_prfl_id
      --
      ,p_hv             => l_hv
      );
    --
  end if;
--  hr_utility.set_location(' Got hv  '||l_proc,10);
  --
  if l_hv is not null then
    --
    l_torrwnum := 1;
    --
--    hr_utility.set_location(' Get loop  '||l_proc,10);
    for l_insttorrw_num in g_copcep_odlookup(l_hv).starttorele_num ..
      g_copcep_odlookup(l_hv).endtorele_num
    loop
      --
      l_inst_set.extend(1);
      l_inst_set(l_torrwnum) := g_copcep_odinst(l_insttorrw_num);
      l_torrwnum := l_torrwnum+1;
      --
    end loop;
    --
--    hr_utility.set_location(' Dn Get loop  '||l_proc,10);
    --
  end if;
  --
  p_inst_set := l_inst_set;
  --
--  hr_utility.set_location(' Leaving  '||l_proc,10);
exception
  --
  when no_data_found then
    --
    p_inst_set := l_inst_set;
    --
end cobcep_odgetdets;
--
end ben_cep_cache;

/
