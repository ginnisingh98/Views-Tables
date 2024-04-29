--------------------------------------------------------
--  DDL for Package Body BEN_RT_ASNT_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_RT_ASNT_CACHE" as
/* $Header: bertasch.pkb 115.0 2004/02/02 11:54:44 kmahendr noship $ */
--
/*
 * +==============================================================================+
 * |                        Copyright (c) 1997 Oracle Corporation
 * |
 * |                           Redwood Shores, California, USA
 * |
 * |                               All rights reserved.
 * |
 * +==============================================================================+
 * --
 * History
 * Version    Date       Author     Comments
 * --------------------------------------------
 * 115.0      30-Jan-04  kmahendr   created
 * --------------------------------------------
 */
-- Globals.
--
g_package varchar2(50) := 'ben_rt_asnt_cache.';
--
g_asntlookup        ben_cache.g_cache_lookup_table;
g_nxelenum number;
g_asntinst          ben_rt_asnt_cache.g_rt_asnt_inst_tbl;
g_asntcached        pls_integer := 0;
--
g_hash_key        pls_integer := 1299827;
g_hash_jump       pls_integer := 100;
--
procedure write_asntcache
  (p_effective_date in    date
  ,p_vrbl_rt_prfl_id  in    number default hr_api.g_number
  --
  ,p_hv               out nocopy  pls_integer
  )
is
  --
  l_proc varchar2(72) := 'write_asntcache';
  --
  --
  l_hv              pls_integer;
  l_not_hash_found  boolean;
  l_torrwnum        pls_integer;
  l_starttorele_num pls_integer;
  l_asntlookup_rec     ben_cache.g_cache_lookup;
  --
  cursor c_asr is
    select asr.VRBL_RT_PRFL_ID,
           ass.formula_id,
           asr.excld_flag
    from   ben_asnt_set_rt_f asr,
           hr_assignment_sets ass
    where  p_effective_date
           between asr.effective_start_date
           and     asr.effective_end_date
    and    asr.assignment_set_id = ass.assignment_set_id
    and    asr.VRBL_RT_PRFL_ID = p_VRBL_RT_PRFL_ID
    order  by asr.VRBL_RT_PRFL_ID,
           decode(asr.excld_flag,'Y',1,2),
           asr.ordr_num;
  l_instance  c_asr%rowtype;
  --
begin
  --
  hr_utility.set_location(' Entering  '||l_proc,10);
  --
  -- Get the instance details
  --
  l_hv := mod(nvl(p_vrbl_rt_prfl_id,1),g_hash_key);
  if g_asntlookup.exists(l_hv) then
    --
    if nvl(g_asntlookup(l_hv).id,-1)        = nvl(p_vrbl_rt_prfl_id,-1)
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
        if g_asntlookup.exists(l_hv) then
         if nvl(g_asntlookup(l_hv).id,-1)        = nvl(p_vrbl_rt_prfl_id,-1)
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
  g_asntlookup(l_hv).id     := p_vrbl_rt_prfl_id;
  --
  hr_utility.set_location(' Dn Look  '||l_proc,10);
  --
  l_starttorele_num := nvl(g_nxelenum,0);
  l_torrwnum        := l_starttorele_num;
  --
  open c_asr;
  loop
    fetch c_asr into l_instance;
    if c_asr%notfound then
      exit;
    end if;
    --
     hr_utility.set_location('C Asr',11);
    g_asntinst(l_torrwnum).id               := l_instance.vrbl_rt_prfl_id;
    g_asntinst(l_torrwnum).formula_id       := l_instance.formula_id;
    g_asntinst(l_torrwnum).excld_flag      := l_instance.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;

  end loop;
  close c_asr;
   if l_torrwnum > nvl(g_nxelenum,0)
  then
    --
    g_asntlookup(l_hv).starttorele_num := l_starttorele_num;
    g_asntlookup(l_hv).endtorele_num   := l_torrwnum-1;
    g_nxelenum := l_torrwnum;
    --
    p_hv := l_hv;
    --
  else
    --
    -- Delete and free PGA with assignment
    --
    g_asntlookup.delete(l_hv);
    g_asntlookup(l_hv) := l_asntlookup_rec;
    --
    p_hv := null;
    --
  end if;
  --
  hr_utility.set_location(' Leaving  '||l_proc,10);
end write_asntcache;
--
procedure get_rt_asnt_cache
  (p_vrbl_rt_prfl_id            in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set          out nocopy ben_rt_asnt_cache.g_rt_asnt_inst_tbl
  ,p_inst_count        out nocopy number
  )
is
  --
  l_inst_set       ben_rt_asnt_cache.g_rt_asnt_inst_tbl;
  --
  l_hv             pls_integer;
  l_hash_found     boolean;
  l_insttorrw_num  pls_integer;
  l_torrwnum       pls_integer;
  --
  l_clash_count    pls_integer;
  l_proc           varchar2(300):= 'get_rt_asnt_cache';
  --
begin
  --
  if g_asntcached = 0
  then
    --
    -- Build the cache
    --
    clear_down_cache;
    --
    g_asntcached := 1;
    --
  end if;
--  hr_utility.set_location(' Derive hv  '||l_proc,10);
  ---- Get the instance details
  --
  l_hv := mod(nvl(p_vrbl_rt_prfl_id,1),g_hash_key);
  --
  -- Check if hashed value is already allocated
  --
  l_hash_found := false;
  --
  if g_asntlookup.exists(l_hv) then
    --
    if nvl(g_asntlookup(l_hv).id,-1)        = nvl(p_vrbl_rt_prfl_id,-1)
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
        if g_asntlookup.exists(l_hv) then
          --
          -- Check if the hash index exists, and compare the values
          --
          if nvl(g_asntlookup(l_hv).id,-1)        = nvl(p_vrbl_rt_prfl_id,-1)
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
    write_asntcache
      (p_effective_date => p_effective_date
      ,p_vrbl_rt_prfl_id         => p_vrbl_rt_prfl_id
      --
      ,p_hv             => l_hv
      );
    --
  end if;
  --
  hr_utility.set_location(' Got hv  '||l_proc,10);
  --
  if l_hv is not null then
    --
    l_torrwnum := 0;
    --
  hr_utility.set_location(' Get loop  '||l_proc,10);
    for l_insttorrw_num in g_asntlookup(l_hv).starttorele_num ..
      g_asntlookup(l_hv).endtorele_num
    loop
      --
      hr_utility.set_location('Instance set'||g_asntinst(l_insttorrw_num).formula_id,12);
      l_inst_set(l_torrwnum) := g_asntinst(l_insttorrw_num);
      l_torrwnum := l_torrwnum+1;
      --
    end loop;
    --
    hr_utility.set_location(' Dn Get loop  '||l_proc,10);
    --
  end if;
  --
  p_inst_set   := l_inst_set;
  p_inst_count := l_inst_set.count;
  --
  hr_utility.set_location(' Leaving  '||l_proc,10);
exception
  --
  when no_data_found then
    --
    p_inst_set   := l_inst_set;
    p_inst_count := 0;
    --
end get_rt_asnt_cache;
--
procedure clear_down_cache
is
  --
  l_asntlookup ben_cache.g_cache_lookup_table;
  l_asntinst   ben_rt_asnt_cache.g_rt_asnt_inst_tbl;
  --
begin
  --
  -- On demand cache structures
  --
  g_asntlookup := l_asntlookup;
  g_asntinst   := l_asntinst;
  g_asntcached := 0;
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
end;

/
