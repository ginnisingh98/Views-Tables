--------------------------------------------------------
--  DDL for Package Body BEN_AGF_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_AGF_CACHE" as
/* $Header: benagfch.pkb 115.4 2002/12/23 12:36:02 nhunur ship $ */
-- ---------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+
--
History
        Date             Who        Version    What?
        -- --             ---        -------    -----
        30 Oct 98        mhoyes     115.0      created
        09 Mar 99        G Perry    115.2      IS to AS.
        04 Mar 99        mhoyes     115.3      Implemented Hashing.
*/
-- ------------------------------------------------------------------------------
  --
  g_package varchar2(50) := 'ben_agf_cache.';
  --
  -- Declare globals
--
-- age factor
--
g_cache_agf_lookup ben_cache.g_cache_lookup_table;
g_cache_agf_inst ben_agf_cache.g_cache_agf_instor;
--
procedure agf_writecache
(p_effective_date in date
--
,p_refresh_cache in boolean default FALSE
)
is
--
l_proc varchar2(72) := g_package||'agf_writecache';
--
l_torrwnum       binary_integer;
--
l_prev_hv        number;
l_hv             number;
l_not_hash_found boolean;
--
cursor c_agf_look is
select agf.age_fctr_id, agf.business_group_id
from ben_age_fctr agf
where exists
(select null
from ben_age_fctr agf
where
agf.age_fctr_id = agf.age_fctr_id)
order by agf.age_fctr_id;
--
cursor c_agf_inst is
select agf.age_fctr_id,
agf.mx_age_num,
agf.mn_age_num,
agf.no_mn_age_flag,
agf.no_mx_age_flag
from ben_age_fctr agf
order by agf.age_fctr_id
, agf.age_fctr_id;
--
begin
--
for objlook in c_agf_look loop
  --
  l_hv := ben_hash_utility.get_hashed_index(objlook.age_fctr_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_agf_lookup.exists(l_hv) then
    --
    l_not_hash_found := false;
    --
    -- Loop until un-allocated has value is derived
    --
    while not l_not_hash_found loop
      --
      l_hv := ben_hash_utility.get_next_hash_index(p_hash_index => l_hv);
      --
      -- Check if the hash index exists, if not we can use it
      --
      if not g_cache_agf_lookup.exists(l_hv) then
        --
        -- Lets store the hash value in the index
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
    end loop;
    --
  end if;
  --
  g_cache_agf_lookup(l_hv).id    := objlook.age_fctr_id;
  g_cache_agf_lookup(l_hv).fk_id := objlook.business_group_id;
  --
end loop;
--
l_torrwnum := 0;
l_prev_hv  := -1;
--
for objinst in c_agf_inst loop
  --
  l_hv := ben_hash_utility.get_hashed_index(objinst.age_fctr_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_agf_inst.exists(l_hv) then
    --
    l_not_hash_found := false;
    --
    -- Loop until un-allocated has value is derived
    --
    while not l_not_hash_found loop
      --
      l_hv := ben_hash_utility.get_next_hash_index(p_hash_index => l_hv);
      --
      -- Check if the hash index exists, if not we can use it
      --
      if not g_cache_agf_inst.exists(l_hv) then
        --
        -- Lets store the hash value in the index
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
    end loop;
    --
  end if;
  --
--
-- Check for first row
--
if l_prev_hv = -1 then
--
g_cache_agf_lookup(l_hv).starttorele_num := l_torrwnum;
--
elsif l_hv <> l_prev_hv then
--
g_cache_agf_lookup(l_prev_hv).endtorele_num := l_torrwnum-1;
g_cache_agf_lookup(l_hv).starttorele_num := l_torrwnum;
--
end if;
--
-- Populate the cache instance details
--
g_cache_agf_inst(l_torrwnum).age_fctr_id := objinst.age_fctr_id;
g_cache_agf_inst(l_torrwnum).mx_age_num := objinst.mx_age_num;
g_cache_agf_inst(l_torrwnum).mn_age_num := objinst.mn_age_num;
g_cache_agf_inst(l_torrwnum).no_mn_age_flag := objinst.no_mn_age_flag;
g_cache_agf_inst(l_torrwnum).no_mn_age_flag := objinst.no_mn_age_flag;
--
l_torrwnum := l_torrwnum+1;
l_prev_hv := l_hv;
--
end loop;
--
g_cache_agf_lookup(l_prev_hv).endtorele_num := l_torrwnum-1;
--
end agf_writecache;
--
procedure agf_getcacdets
(p_effective_date in date
,p_business_group_id in number
,p_age_fctr_id in number
--
,p_refresh_cache in boolean default FALSE
--
,p_inst_set out nocopy ben_agf_cache.g_cache_agf_instor
,p_inst_count out nocopy number
)
is
--
l_proc varchar2(72) := g_package||'agf_getcacdets';
--
l_torrwnum       binary_integer;
l_insttorrw_num  binary_integer;
--
l_index          binary_integer;
l_hv             binary_integer;
l_not_hash_found boolean;
--
begin
--
-- Flush the cache
--
if p_refresh_cache then
--
g_cache_agf_lookup.delete;
g_cache_agf_inst.delete;
--
end if;
--
-- Populate the global cache
--
if g_cache_agf_lookup.count = 0
then
--
-- Build the cache
--
ben_agf_cache.agf_writecache
(p_effective_date => p_effective_date
--
,p_refresh_cache => p_refresh_cache
);
--
end if;
  --
  l_hv := ben_hash_utility.get_hashed_index(p_id => p_age_fctr_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_agf_lookup.exists(l_hv) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_agf_lookup(l_hv).id <> p_age_fctr_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_hv := ben_hash_utility.get_next_hash_index(p_hash_index => l_hv);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_agf_lookup.exists(l_hv) then
          --
          -- Lets store the hash value in the index
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
      end loop;
    --
    end if;
    --
  end if;
  --
--
-- Get the instance details
--
l_torrwnum := 0;
--
for l_insttorrw_num in g_cache_agf_lookup(l_hv).starttorele_num ..
g_cache_agf_lookup(l_hv).endtorele_num loop
--
p_inst_set(l_torrwnum) := g_cache_agf_inst(l_insttorrw_num);
l_torrwnum := l_torrwnum+1;
--
end loop;
--
p_inst_count := l_torrwnum;
--
exception
when no_data_found then
--
p_inst_count := 0;
--
end agf_getcacdets;
--
end ben_agf_cache;

/
