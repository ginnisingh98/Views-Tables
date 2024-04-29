--------------------------------------------------------
--  DDL for Package Body BEN_CEL_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CEL_CACHE" as
/* $Header: bencelch.pkb 115.9 2002/12/24 15:44:13 bmanyam ship $ */
--
g_package varchar2(50) := 'ben_cel_cache.';
--
--
-- Hand coded
--
-- plan participating eligibility profile by plan
--
g_cache_plnelp_lookup ben_cache.g_cache_lookup_table;
g_cache_plnelp_inst ben_cel_cache.g_cache_cepelp_instor;
--
-- program participating eligibility profile by program
--
g_cache_pgmelp_lookup ben_cache.g_cache_lookup_table;
g_cache_pgmelp_inst ben_cel_cache.g_cache_cepelp_instor;
--
-- oipl participating eligibility profile by oipl
--
g_cache_copelp_lookup ben_cache.g_cache_lookup_table;
g_cache_copelp_inst ben_cel_cache.g_cache_cepelp_instor;
--
-- plip participating eligibility profile by plip
--
g_cache_cppelp_lookup ben_cache.g_cache_lookup_table;
g_cache_cppelp_inst ben_cel_cache.g_cache_cepelp_instor;
--
-- ptip participating eligibility profile by ptip
--
g_cache_ctpelp_lookup ben_cache.g_cache_lookup_table;
g_cache_ctpelp_inst ben_cel_cache.g_cache_cepelp_instor;
--
procedure plnelp_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) := g_package||'plnelp_writecache';
  l_torrwnum binary_integer;
  l_prev_id number;
  l_id number;
  l_not_hash_found boolean;
  --
  cursor c_plnelp_look is
    select pln.pl_id,
           pln.business_group_id
    from   ben_pl_f pln
    where  p_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date
    and    exists(select null
                  from   ben_prtn_elig_f epa,
                         ben_prtn_elig_prfl_f cep,
                         ben_eligy_prfl_f elp
                  where  elp.eligy_prfl_id = cep.eligy_prfl_id
                  and    elp.business_group_id = cep.business_group_id
                  and    cep.prtn_elig_id = epa.prtn_elig_id
                  and    cep.business_group_id = epa.business_group_id
                  and    p_effective_date
                         between elp.effective_start_date
                         and     elp.effective_end_date
                  and    p_effective_date
                         between epa.effective_start_date
                         and     epa.effective_end_date
                  and    p_effective_date
                         between cep.effective_start_date
                         and     cep.effective_end_date
                  and epa.pl_id = pln.pl_id)
    order  by pln.pl_id;
  --
  cursor c_plnelp_inst is
    select epa.pl_id,
           epa.prtn_elig_id,
           cep.mndtry_flag,
           elp.eligy_prfl_id
    from   ben_prtn_elig_f epa,
           ben_prtn_elig_prfl_f cep,
           ben_eligy_prfl_f elp
    where  elp.eligy_prfl_id = cep.eligy_prfl_id
    and    elp.business_group_id = cep.business_group_id
    and    cep.prtn_elig_id = epa.prtn_elig_id
    and    cep.business_group_id = epa.business_group_id
    and    epa.pl_id is not null
    and    p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    p_effective_date
           between epa.effective_start_date
           and     epa.effective_end_date
    and    p_effective_date
           between cep.effective_start_date
           and     cep.effective_end_date
    order  by epa.pl_id, decode(cep.mndtry_flag,'y',1,2);
  --
begin
  --
  for objlook in c_plnelp_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.pl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_plnelp_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_plnelp_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          commit;
exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_plnelp_lookup(l_id).id := objlook.pl_id;
    g_cache_plnelp_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_plnelp_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.pl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_plnelp_inst.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_plnelp_inst.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          commit;
exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_plnelp_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_plnelp_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_plnelp_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_plnelp_inst(l_torrwnum).pl_id := objinst.pl_id;
    g_cache_plnelp_inst(l_torrwnum).prtn_elig_id := objinst.prtn_elig_id;
    g_cache_plnelp_inst(l_torrwnum).mndtry_flag := objinst.mndtry_flag;
    g_cache_plnelp_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_plnelp_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end plnelp_writecache;
--
procedure plnelp_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_pl_id             in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_cel_cache.g_cache_cepelp_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) := g_package||'plnelp_getcacdets';
  l_torrwnum binary_integer;
  l_insttorrw_num binary_integer;
  l_index         binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_plnelp_lookup.delete;
    g_cache_plnelp_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_plnelp_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_cel_cache.plnelp_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_pl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_plnelp_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_plnelp_lookup(l_index).id <> p_pl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_plnelp_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          commit;
exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_plnelp_lookup(l_index).starttorele_num ..
    g_cache_plnelp_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_plnelp_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end plnelp_getcacdets;
--
procedure pgmelp_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) := g_package||'pgmelp_writecache';
  l_torrwnum binary_integer;
  l_prev_id number;
  l_id number;
  l_not_hash_found boolean;
  --
  cursor c_pgmelp_look is
    select pgm.pgm_id, pgm.business_group_id
    from   ben_pgm_f pgm
    where  p_effective_date
           between pgm.effective_start_date
           and     pgm.effective_end_date
    and    exists(select null
                  from   ben_prtn_elig_f epa,
                         ben_prtn_elig_prfl_f cep,
                         ben_eligy_prfl_f elp
                  where  elp.eligy_prfl_id = cep.eligy_prfl_id
                  and    elp.business_group_id = cep.business_group_id
                  and    cep.prtn_elig_id = epa.prtn_elig_id
                  and    cep.business_group_id = epa.business_group_id
                  and    p_effective_date
                         between elp.effective_start_date
                         and     elp.effective_end_date
                  and    p_effective_date
                         between epa.effective_start_date
                         and     epa.effective_end_date
                  and    p_effective_date
                         between cep.effective_start_date
                         and     cep.effective_end_date
                  and    epa.pgm_id = pgm.pgm_id)
    order  by pgm.pgm_id;
  --
  cursor c_pgmelp_inst is
    select epa.pgm_id,
           epa.prtn_elig_id,
           cep.mndtry_flag,
           elp.eligy_prfl_id
    from   ben_prtn_elig_f epa,
           ben_prtn_elig_prfl_f cep,
           ben_eligy_prfl_f elp
    where  elp.eligy_prfl_id = cep.eligy_prfl_id
    and    elp.business_group_id = cep.business_group_id
    and    cep.prtn_elig_id = epa.prtn_elig_id
    and    cep.business_group_id = epa.business_group_id
    and    epa.pgm_id is not null
    and    p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    p_effective_date
           between epa.effective_start_date
           and     epa.effective_end_date
    and    p_effective_date
           between cep.effective_start_date
           and     cep.effective_end_date
    order  by epa.pgm_id, decode(cep.mndtry_flag,'Y',1,2);
  --
begin
  --
  for objlook in c_pgmelp_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.pgm_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_pgmelp_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_pgmelp_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          commit;
exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
      --
      end loop;
      --
    end if;
    --
    g_cache_pgmelp_lookup(l_id).id := objlook.pgm_id;
    g_cache_pgmelp_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_pgmelp_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.pgm_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_pgmelp_inst.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_pgmelp_inst.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          commit;
exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_pgmelp_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_pgmelp_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_pgmelp_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_pgmelp_inst(l_torrwnum).pgm_id := objinst.pgm_id;
    g_cache_pgmelp_inst(l_torrwnum).prtn_elig_id := objinst.prtn_elig_id;
    g_cache_pgmelp_inst(l_torrwnum).mndtry_flag := objinst.mndtry_flag;
    g_cache_pgmelp_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_pgmelp_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end pgmelp_writecache;
--
procedure pgmelp_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_pgm_id            in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_cel_cache.g_cache_cepelp_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) := g_package||'pgmelp_getcacdets';
  l_torrwnum binary_integer;
  l_insttorrw_num binary_integer;
  l_index         binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_pgmelp_lookup.delete;
    g_cache_pgmelp_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_pgmelp_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_cel_cache.pgmelp_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_pgm_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_pgmelp_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_pgmelp_lookup(l_index).id <> p_pgm_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_pgmelp_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          commit;
exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_pgmelp_lookup(l_index).starttorele_num ..
    g_cache_pgmelp_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_pgmelp_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end pgmelp_getcacdets;
--
procedure copelp_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) := g_package||'copelp_writecache';
  l_torrwnum binary_integer;
  l_prev_id number;
  l_id number;
  l_not_hash_found boolean;
  --
  cursor c_copelp_look is
    select cop.oipl_id,
           cop.business_group_id
    from   ben_oipl_f cop
    where  p_effective_date
           between cop.effective_start_date
           and     cop.effective_end_date
    and exists(select null
               from   ben_prtn_elig_f epa,
                      ben_prtn_elig_prfl_f cep,
                      ben_eligy_prfl_f elp
               where  elp.eligy_prfl_id = cep.eligy_prfl_id
               and    elp.business_group_id = cep.business_group_id
               and    cep.prtn_elig_id = epa.prtn_elig_id
               and    cep.business_group_id = epa.business_group_id
               and    p_effective_date
                      between elp.effective_start_date
                      and     elp.effective_end_date
               and    p_effective_date
                      between epa.effective_start_date
                      and     epa.effective_end_date
               and    p_effective_date
                      between cep.effective_start_date
                      and     cep.effective_end_date
               and    epa.oipl_id = cop.oipl_id)
    order by cop.oipl_id;
  --
  cursor c_copelp_inst is
    select epa.oipl_id,
           epa.prtn_elig_id,
           cep.mndtry_flag,
           elp.eligy_prfl_id
    from   ben_prtn_elig_f epa,
           ben_prtn_elig_prfl_f cep,
           ben_eligy_prfl_f elp
    where  elp.eligy_prfl_id = cep.eligy_prfl_id
    and    elp.business_group_id = cep.business_group_id
    and    cep.prtn_elig_id = epa.prtn_elig_id
    and    cep.business_group_id = epa.business_group_id
    and    epa.oipl_id is not null
    and    p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    p_effective_date
           between epa.effective_start_date
           and     epa.effective_end_date
    and    p_effective_date
           between cep.effective_start_date
           and     cep.effective_end_date
    order  by epa.oipl_id, decode(cep.mndtry_flag,'Y',1,2);
  --
begin
  --
  for objlook in c_copelp_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.oipl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_copelp_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_copelp_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          commit;
exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
      --
      end loop;
      --
    end if;
    --
    g_cache_copelp_lookup(l_id).id := objlook.oipl_id;
    g_cache_copelp_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_copelp_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.oipl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_copelp_inst.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_copelp_inst.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          commit;
exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_copelp_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_copelp_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_copelp_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_copelp_inst(l_torrwnum).oipl_id := objinst.oipl_id;
    g_cache_copelp_inst(l_torrwnum).prtn_elig_id := objinst.prtn_elig_id;
    g_cache_copelp_inst(l_torrwnum).mndtry_flag := objinst.mndtry_flag;
    g_cache_copelp_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_copelp_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end copelp_writecache;
--
procedure copelp_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_oipl_id           in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_cel_cache.g_cache_cepelp_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) := g_package||'copelp_getcacdets';
  l_torrwnum binary_integer;
  l_insttorrw_num binary_integer;
  l_index         binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_copelp_lookup.delete;
    g_cache_copelp_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_copelp_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_cel_cache.copelp_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_oipl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_copelp_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_copelp_lookup(l_index).id <> p_oipl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_copelp_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          commit;
exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_copelp_lookup(l_index).starttorele_num ..
    g_cache_copelp_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_copelp_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end copelp_getcacdets;
--
procedure cppelp_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) := g_package||'cppelp_writecache';
  l_torrwnum binary_integer;
  l_prev_id number;
  l_id number;
  l_not_hash_found boolean;
  --
  cursor c_cppelp_look is
    select cpp.plip_id,
           cpp.business_group_id
    from   ben_plip_f cpp
    where  p_effective_date
           between cpp.effective_start_date
           and     cpp.effective_end_date
    and exists(select null
               from   ben_prtn_elig_f epa,
                      ben_prtn_elig_prfl_f cep,
                      ben_eligy_prfl_f elp
               where  elp.eligy_prfl_id = cep.eligy_prfl_id
               and    elp.business_group_id = cep.business_group_id
               and    cep.prtn_elig_id = epa.prtn_elig_id
               and    cep.business_group_id = epa.business_group_id
               and    p_effective_date
                      between elp.effective_start_date
                      and     elp.effective_end_date
               and    p_effective_date
                      between epa.effective_start_date
                      and     epa.effective_end_date
               and    p_effective_date
                      between cep.effective_start_date
                      and     cep.effective_end_date
               and    epa.plip_id = cpp.plip_id)
    order by cpp.plip_id;
  --
  cursor c_cppelp_inst is
    select epa.plip_id,
           epa.prtn_elig_id,
           cep.mndtry_flag,
           elp.eligy_prfl_id
    from   ben_prtn_elig_f epa,
           ben_prtn_elig_prfl_f cep,
           ben_eligy_prfl_f elp
    where  elp.eligy_prfl_id = cep.eligy_prfl_id
    and    elp.business_group_id = cep.business_group_id
    and    cep.prtn_elig_id = epa.prtn_elig_id
    and    cep.business_group_id = epa.business_group_id
    and    epa.plip_id is not null
    and    p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    p_effective_date
           between epa.effective_start_date
           and     epa.effective_end_date
    and    p_effective_date
           between cep.effective_start_date
           and     cep.effective_end_date
    order  by epa.plip_id, decode(cep.mndtry_flag,'Y',1,2);
  --
begin
  --
  for objlook in c_cppelp_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.plip_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_cppelp_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_cppelp_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          commit;
exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
      --
      end loop;
      --
    end if;
    --
    g_cache_cppelp_lookup(l_id).id := objlook.plip_id;
    g_cache_cppelp_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_cppelp_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.plip_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_cppelp_inst.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_cppelp_inst.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          commit;
exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_cppelp_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_cppelp_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_cppelp_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_cppelp_inst(l_torrwnum).plip_id := objinst.plip_id;
    g_cache_cppelp_inst(l_torrwnum).prtn_elig_id := objinst.prtn_elig_id;
    g_cache_cppelp_inst(l_torrwnum).mndtry_flag := objinst.mndtry_flag;
    g_cache_cppelp_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_cppelp_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end cppelp_writecache;
--
procedure cppelp_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_plip_id           in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_cel_cache.g_cache_cepelp_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) := g_package||'cppelp_getcacdets';
  l_torrwnum binary_integer;
  l_insttorrw_num binary_integer;
  l_index         binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_cppelp_lookup.delete;
    g_cache_cppelp_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_cppelp_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_cel_cache.cppelp_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_plip_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_cppelp_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_cppelp_lookup(l_index).id <> p_plip_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_cppelp_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          commit;
exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_cppelp_lookup(l_index).starttorele_num ..
    g_cache_cppelp_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_cppelp_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end cppelp_getcacdets;
--
procedure ctpelp_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) := g_package||'ctpelp_writecache';
  l_torrwnum binary_integer;
  l_prev_id number;
  l_id number;
  l_not_hash_found boolean;
  --
  cursor c_ctpelp_look is
    select ctp.ptip_id,
           ctp.business_group_id
    from   ben_ptip_f ctp
    where  p_effective_date
           between ctp.effective_start_date
           and     ctp.effective_end_date
    and exists(select null
               from   ben_prtn_elig_f epa,
                      ben_prtn_elig_prfl_f cep,
                      ben_eligy_prfl_f elp
               where  elp.eligy_prfl_id = cep.eligy_prfl_id
               and    elp.business_group_id = cep.business_group_id
               and    cep.prtn_elig_id = epa.prtn_elig_id
               and    cep.business_group_id = epa.business_group_id
               and    p_effective_date
                      between elp.effective_start_date
                      and     elp.effective_end_date
               and    p_effective_date
                      between epa.effective_start_date
                      and     epa.effective_end_date
               and    p_effective_date
                      between cep.effective_start_date
                      and     cep.effective_end_date
               and    epa.ptip_id = ctp.ptip_id)
    order by ctp.ptip_id;
  --
  cursor c_ctpelp_inst is
    select epa.ptip_id,
           epa.prtn_elig_id,
           cep.mndtry_flag,
           elp.eligy_prfl_id
    from   ben_prtn_elig_f epa,
           ben_prtn_elig_prfl_f cep,
           ben_eligy_prfl_f elp
    where  elp.eligy_prfl_id = cep.eligy_prfl_id
    and    elp.business_group_id = cep.business_group_id
    and    cep.prtn_elig_id = epa.prtn_elig_id
    and    cep.business_group_id = epa.business_group_id
    and    epa.ptip_id is not null
    and    p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    p_effective_date
           between epa.effective_start_date
           and     epa.effective_end_date
    and    p_effective_date
           between cep.effective_start_date
           and     cep.effective_end_date
    order  by epa.ptip_id, decode(cep.mndtry_flag,'Y',1,2);
  --
begin
  --
  for objlook in c_ctpelp_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.ptip_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_ctpelp_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_ctpelp_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          commit;
exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
      --
      end loop;
      --
    end if;
    --
    g_cache_ctpelp_lookup(l_id).id := objlook.ptip_id;
    g_cache_ctpelp_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_ctpelp_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.ptip_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_ctpelp_inst.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_ctpelp_inst.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          commit;
exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_ctpelp_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_ctpelp_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_ctpelp_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_ctpelp_inst(l_torrwnum).plip_id := objinst.ptip_id;
    g_cache_ctpelp_inst(l_torrwnum).prtn_elig_id := objinst.prtn_elig_id;
    g_cache_ctpelp_inst(l_torrwnum).mndtry_flag := objinst.mndtry_flag;
    g_cache_ctpelp_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_ctpelp_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end ctpelp_writecache;
--
procedure ctpelp_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_ptip_id           in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_cel_cache.g_cache_cepelp_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) := g_package||'ctpelp_getcacdets';
  l_torrwnum binary_integer;
  l_insttorrw_num binary_integer;
  l_index         binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_ctpelp_lookup.delete;
    g_cache_ctpelp_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_ctpelp_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_cel_cache.ctpelp_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_ptip_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_ctpelp_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_ctpelp_lookup(l_index).id <> p_ptip_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_ctpelp_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          commit;
exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_ctpelp_lookup(l_index).starttorele_num ..
    g_cache_ctpelp_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_ctpelp_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end ctpelp_getcacdets;
--
procedure cepelp_getdets
  (p_business_group_id in  number,
   p_effective_date    in  date,
   p_pgm_id            in  number,
   p_pl_id             in  number,
   p_oipl_id           in  number,
   p_plip_id           in  number,
   p_ptip_id           in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_cel_cache.g_cache_cepelp_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc            varchar2(72) := g_package||'cepelp_getdets';
  --
begin
  --
  -- Populate the local cache from the global cache
  --
  if p_pl_id is not null and
    p_pgm_id is null and
    p_plip_id is null and
    p_ptip_id is null and
    p_oipl_id is null then
    --
    -- PLNELP
    --
    ben_cel_cache.plnelp_getcacdets
      (p_effective_date    => p_effective_date,
       p_business_group_id => p_business_group_id,
       p_pl_id             => p_pl_id,
       p_inst_set          => p_inst_set,
       p_inst_count        => p_inst_count);
    --
  elsif p_pl_id is null and
    p_pgm_id is not null and
    p_plip_id is null and
    p_ptip_id is null and
    p_oipl_id is null then
    --
    -- PGMELP
    --
    ben_cel_cache.pgmelp_getcacdets
      (p_effective_date    => p_effective_date,
       p_business_group_id => p_business_group_id,
       p_pgm_id           => p_pgm_id,
       p_inst_set          => p_inst_set,
       p_inst_count        => p_inst_count);
    --
  elsif p_pl_id is null and
    p_pgm_id is null and
    p_plip_id is null and
    p_ptip_id is null and
    p_oipl_id is not null then
    --
    -- COPELP
    --
    ben_cel_cache.copelp_getcacdets
      (p_effective_date    => p_effective_date,
       p_business_group_id => p_business_group_id,
       p_oipl_id           => p_oipl_id,
       p_inst_set          => p_inst_set,
       p_inst_count        => p_inst_count);
    --
  elsif p_pl_id is null and
    p_pgm_id is null and
    p_plip_id is not null and
    p_ptip_id is null and
    p_oipl_id is null then
    --
    -- CPPELP
    --
    ben_cel_cache.cppelp_getcacdets
      (p_effective_date    => p_effective_date,
       p_business_group_id => p_business_group_id,
       p_plip_id           => p_plip_id,
       p_inst_set          => p_inst_set,
       p_inst_count        => p_inst_count);
    --
  elsif p_pl_id is null and
    p_pgm_id is null and
    p_ptip_id is not null and
    p_plip_id is null and
    p_oipl_id is null then
    --
    -- CPPELP
    --
    ben_cel_cache.ctpelp_getcacdets
      (p_effective_date    => p_effective_date,
       p_business_group_id => p_business_group_id,
       p_ptip_id           => p_ptip_id,
       p_inst_set          => p_inst_set,
       p_inst_count        => p_inst_count);
    --
  end if;
  --
end cepelp_getdets;
--
procedure clear_down_cache is
  --
begin
  --
  g_cache_plnelp_lookup.delete;
  g_cache_plnelp_inst.delete;
  g_cache_pgmelp_lookup.delete;
  g_cache_pgmelp_inst.delete;
  g_cache_copelp_lookup.delete;
  g_cache_copelp_inst.delete;
  g_cache_cppelp_lookup.delete;
  g_cache_cppelp_lookup.delete;
  g_cache_ctpelp_inst.delete;
  g_cache_ctpelp_inst.delete;
  --
end clear_down_cache;
--
end ben_cel_cache;

/
