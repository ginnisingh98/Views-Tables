--------------------------------------------------------
--  DDL for Package Body BEN_LOS_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LOS_CACHE" as
/* $Header: benlosch.pkb 115.6 2003/02/12 10:38:01 rpgupta ship $ */
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
        06 May 99        mhoyes     115.1      Upgraded to hashing algorhythm
        09 May 99        mhoyes     115.4      More upgrading to hashing algorhythm
*/
-- ------------------------------------------------------------------------------
  --
  g_package varchar2(50) := 'ben_los_cache.';
  --
  -- Declare globals
--
-- length of service factor
--
g_cache_los_lookup ben_cache.g_cache_lookup_table;
g_cache_los_inst ben_los_cache.g_cache_los_instor;
--
procedure los_writecache
(p_effective_date in date
--
,p_refresh_cache in boolean default FALSE
)
is
--
l_proc varchar2(72) := g_package||'los_writecache';
--
l_torrwnum       binary_integer;
--
l_prev_hv        number;
l_hv             number;
l_not_hash_found boolean;
--
cursor c_los_look is
select los.los_fctr_id, los.business_group_id
from ben_los_fctr los
where exists
(select null
from ben_los_fctr los
where
los.los_fctr_id = los.los_fctr_id)
order by los.los_fctr_id;
--
cursor c_los_inst is
select los.los_fctr_id,
los.mx_los_num,
los.mn_los_num,
los.no_mn_los_num_apls_flag,
los.no_mx_los_num_apls_flag
from ben_los_fctr los
order by los.los_fctr_id
, los.los_fctr_id;
--
begin
--
for objlook in c_los_look loop
  --
  l_hv := ben_hash_utility.get_hashed_index(objlook.los_fctr_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_los_lookup.exists(l_hv) then
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
      if not g_cache_los_lookup.exists(l_hv) then
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
  g_cache_los_lookup(l_hv).id    := objlook.los_fctr_id;
  g_cache_los_lookup(l_hv).fk_id := objlook.business_group_id;
  --
end loop;
--
l_torrwnum := 0;
l_prev_hv  := -1;
--
for objinst in c_los_inst loop
  --
  l_hv := ben_hash_utility.get_hashed_index(objinst.los_fctr_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_los_inst.exists(l_hv) then
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
      if not g_cache_los_inst.exists(l_hv) then
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
g_cache_los_lookup(l_hv).starttorele_num := l_torrwnum;
--
elsif l_hv <> l_prev_hv then
--
g_cache_los_lookup(l_prev_hv).endtorele_num := l_torrwnum-1;
g_cache_los_lookup(l_hv).starttorele_num := l_torrwnum;
--
end if;
--
-- Populate the cache instance details
--
g_cache_los_inst(l_torrwnum).los_fctr_id := objinst.los_fctr_id;
g_cache_los_inst(l_torrwnum).mx_los_num := objinst.mx_los_num;
g_cache_los_inst(l_torrwnum).mn_los_num := objinst.mn_los_num;
g_cache_los_inst(l_torrwnum).no_mn_los_num_apls_flag := objinst.no_mn_los_num_apls_flag;
g_cache_los_inst(l_torrwnum).no_mx_los_num_apls_flag := objinst.no_mx_los_num_apls_flag;
--
l_torrwnum := l_torrwnum+1;
l_prev_hv := l_hv;
--
end loop;
--
g_cache_los_lookup(l_prev_hv).endtorele_num := l_torrwnum-1;
--
end los_writecache;
--
procedure los_getcacdets
(p_effective_date in date
,p_business_group_id in number
,p_los_fctr_id in number
--
,p_refresh_cache in boolean default FALSE
--
,p_inst_set out nocopy ben_los_cache.g_cache_los_instor
,p_inst_count out nocopy number
)
is
--
l_proc varchar2(72) := g_package||'los_getcacdets';
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
g_cache_los_lookup.delete;
g_cache_los_inst.delete;
--
end if;
--
-- Populate the global cache
--
if g_cache_los_lookup.count = 0
then
--
-- Build the cache
--
ben_los_cache.los_writecache
(p_effective_date => p_effective_date
--
,p_refresh_cache => p_refresh_cache
);
--
end if;
  --
  l_hv := ben_hash_utility.get_hashed_index(p_id => p_los_fctr_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_los_lookup.exists(l_hv) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_los_lookup(l_hv).id <> p_los_fctr_id then
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
        if not g_cache_los_lookup.exists(l_hv) then
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
for l_insttorrw_num in g_cache_los_lookup(l_hv).starttorele_num ..
g_cache_los_lookup(l_hv).endtorele_num loop
--
p_inst_set(l_torrwnum) := g_cache_los_inst(l_insttorrw_num);
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
end los_getcacdets;
--
end ben_los_cache;

/
