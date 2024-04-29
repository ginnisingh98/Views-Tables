--------------------------------------------------------
--  DDL for Package Body BEN_LIFE_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LIFE_OBJECT" as
/* $Header: benlerde.pkb 120.0 2005/05/28 09:05:51 appldev noship $ */
--
/*
+==============================================================================+
|                        Copyright (c) 1997 Oracle Corporation                 |
|                           Redwood Shores, California, USA                    |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
	Life Event Object Caching Routine
Purpose
	This package is used to return life event object information.
History
  Version    Date         Who        What?
  ---------  ---------    ---------- --------------------------------------------
  115.0      25-Jun-2000  gperry     Created
  115.1      03-Apr-2000  mhoyes   - Commented out nocopy trace statements.
  115.2      09-Nov-2000  mhoyes   - Removed + 0s.
  115.3      13-Dec-2002  kmahendr   Nocopy changes
  -----------------------------------------------------------------------------
*/
--
g_package varchar2(30) := 'ben_life_object.';
--
-- Set object routines
--
procedure set_object(p_rec in ben_css_rltd_per_per_in_ler_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object';
  l_index          binary_integer;
  --
begin
  --
--  hr_utility.set_location('Entering '||l_proc,10);
  --
  l_index := nvl(g_cache_css_rec.count,0)+1;
  --
  g_cache_css_rec(l_index) := p_rec;
  --
--  hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_object;
--
procedure set_object(p_rec in ben_ler_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object';
  l_index          binary_integer;
  --
begin
  --
--  hr_utility.set_location('Entering '||l_proc,10);
  --
  l_index := nvl(g_cache_ler_rec.count,0)+1;
  --
  g_cache_ler_rec(l_index) := p_rec;
  --
--  hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_object;
--
procedure set_css_ler_object(p_rec in ben_cache.g_cache_lookup) is
  --
  l_proc           varchar2(80) := g_package||'set_css_ler_object';
  l_index          binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
--  hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := ben_hash_utility.get_hashed_index(p_id => p_rec.id);
  --
  if not g_cache_css_ler_rec.exists(l_index) then
    --
    -- Lets store the hash value in this index
    --
    g_cache_css_ler_rec(l_index) := p_rec;
    --
  else
    --
    -- If it does exist check if its the right one
    --
    if g_cache_css_ler_rec(l_index).id <> p_rec.id then
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index =>l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_css_ler_rec.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          g_cache_css_ler_rec(l_index) := p_rec;
          l_not_hash_found := true;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_css_ler_rec(l_index).id = p_rec.id then
            --
            -- We have a match so the hashed value has been stored before
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
--  hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_css_ler_object;
--
procedure set_ler_ler_object(p_rec in ben_cache.g_cache_lookup) is
  --
  l_proc           varchar2(80) := g_package||'set_ler_ler_object';
  l_index          binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
--  hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := ben_hash_utility.get_hashed_index(p_id => p_rec.id);
  --
  if not g_cache_ler_ler_rec.exists(l_index) then
    --
    -- Lets store the hash value in this index
    --
    g_cache_ler_ler_rec(l_index) := p_rec;
    --
  else
    --
    -- If it does exist check if its the right one
    --
    if g_cache_ler_ler_rec(l_index).id <> p_rec.id then
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index =>l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_ler_ler_rec.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          g_cache_ler_ler_rec(l_index) := p_rec;
          l_not_hash_found := true;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_ler_ler_rec(l_index).id = p_rec.id then
            --
            -- We have a match so the hashed value has been stored before
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
--  hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_ler_ler_object;
--
-- Set object alternate route routines
--
procedure set_css_object
  (p_ler_id            in  number,
   p_business_group_id in  number,
   p_effective_date    in  date,
   p_rec               out nocopy g_cache_css_table) is
  --
  l_proc           varchar2(80) := g_package||'set_css_object';
  --
  cursor c1 is
    select css.*
    from   ben_css_rltd_per_per_in_ler_f css
    where  css.ler_id = p_ler_id
    and    css.business_group_id  = p_business_group_id;
  --
  l_css_rec     ben_life_object.g_cache_css_table;
  l_rec         ben_css_rltd_per_per_in_ler_f%rowtype;
  l_css_ler_rec ben_cache.g_cache_lookup;
  l_start_index number;
  l_end_index   number;
  l_num_recs    number := 0;
  --
begin
  --
--  hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  open c1;
    --
    loop
      --
      fetch c1 into l_rec;
      exit when c1%notfound;
      --
      set_object(p_rec => l_rec);
      --
      l_num_recs := l_num_recs +1;
      --
      if l_num_recs = 1 then
        --
        l_css_ler_rec.starttorele_num := g_cache_css_rec.count;
        --
      end if;
      --
      if l_rec.ler_id = p_ler_id and
        p_effective_date
        between l_rec.effective_start_date
        and     l_rec.effective_end_date then
        --
        l_css_rec(l_css_rec.count+1) :=  l_rec;
        --
      end if;
      --
    end loop;
    --
  close c1;
  --
  l_css_ler_rec.id := p_ler_id;
  --
  if l_css_ler_rec.starttorele_num is not null then
    --
    l_css_ler_rec.endtorele_num := g_cache_css_rec.count;
    --
  end if;
  --
  -- Save master details to cache structure
  --
  set_css_ler_object(p_rec => l_css_ler_rec);
  --
  p_rec := l_css_rec;
  --
--  hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_css_object;
--
procedure set_ler_object
  (p_ler_id            in  number,
   p_business_group_id in  number,
   p_effective_date    in  date,
   p_rec               out nocopy ben_ler_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_ler_object';
  --
  cursor c1 is
    select ler.*
    from   ben_ler_f ler
    where  ler.business_group_id = p_business_group_id;
  --
  l_ler_rec     ben_life_object.g_cache_ler_table;
  l_rec         ben_ler_f%rowtype;
  l_ler_ler_rec ben_cache.g_cache_lookup;
  l_start_index number;
  l_end_index   number;
  l_num_recs    number := 0;
  --
begin
  --
--  hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  open c1;
    --
    loop
      --
      fetch c1 into l_rec;
      exit when c1%notfound;
      --
      set_object(p_rec => l_rec);
      --
      l_num_recs := l_num_recs +1;
      --
      if l_num_recs = 1 then
        --
        l_ler_ler_rec.starttorele_num := g_cache_ler_rec.count;
        --
      end if;
      --
      if l_rec.ler_id = p_ler_id and
        p_effective_date
        between l_rec.effective_start_date
        and     l_rec.effective_end_date then
        --
        p_rec := l_rec;
        --
      end if;
      --
    end loop;
    --
  close c1;
  --
  l_ler_ler_rec.id := p_ler_id;
  --
  if l_ler_ler_rec.starttorele_num is not null then
    --
    l_ler_ler_rec.endtorele_num := g_cache_ler_rec.count;
    --
  end if;
  --
  -- Save master details to cache structure
  --
  set_ler_ler_object(p_rec => l_ler_ler_rec);
  --
--  hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_ler_object;
--
-- Get object routines
--
procedure get_object(p_ler_id in  number,
                     p_rec    out nocopy ben_ler_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object';
  l_index          binary_integer;
  l_not_hash_found boolean;
  l_env_rec        ben_env_object.g_global_env_rec_type;
  --
begin
  --
--  hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return person_id
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := ben_hash_utility.get_hashed_index(p_id => p_ler_id);
  --
  if g_cache_ler_ler_rec.exists(l_index) then
    --
    -- Lets get the hashed record.
    --
    if g_cache_ler_ler_rec(l_index).id = p_ler_id then
      --
      null;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index =>l_index);
        --
        -- Check if the hash index exists, if not error
        --
        if not g_cache_ler_ler_rec.exists(l_index) then
          --
          -- Raise an error as we are trying to retrieve a non cached object
          --
          raise no_data_found;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_ler_ler_rec(l_index).id = p_ler_id then
            --
            -- We have a match
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  else
    --
    raise no_data_found;
    --
  end if;
  --
  -- At this point we have the master record so we can derive the set of
  -- children by looping through the relevant records.
  --
  ben_env_object.get(p_rec => l_env_rec);
  --
  if g_cache_ler_ler_rec(l_index).starttorele_num is not null then
    --
    for l_count in g_cache_ler_ler_rec(l_index).starttorele_num..
      g_cache_ler_ler_rec(l_index).endtorele_num loop
      --
      if g_cache_ler_rec(l_count).ler_id = p_ler_id and
        nvl(l_env_rec.lf_evt_ocrd_dt,l_env_rec.effective_date)
        between g_cache_ler_rec(l_count).effective_start_date
        and     g_cache_ler_rec(l_count).effective_end_date then
        --
        p_rec := g_cache_ler_rec(l_count);
        --
      end if;
      --
    end loop;
    --
  end if;
  --
--  hr_utility.set_location('Leaving '||l_proc,10);
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env_rec);
    --
    set_ler_object(p_ler_id            => p_ler_id,
                   p_business_group_id => l_env_rec.business_group_id,
                   p_effective_date    => nvl(l_env_rec.lf_evt_ocrd_dt,
                                              l_env_rec.effective_date),
                   p_rec               => p_rec);
    --
end get_object;
--
procedure get_object(p_ler_id in  number,
                     p_rec    out nocopy g_cache_css_table) is
  --
  l_proc           varchar2(80) := g_package||'get_object';
  l_index          binary_integer;
  l_not_hash_found boolean;
  l_env_rec        ben_env_object.g_global_env_rec_type;
  l_rec            ben_life_object.g_cache_css_table;
  --
begin
  --
--  hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return person_id
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := ben_hash_utility.get_hashed_index(p_id => p_ler_id);
  --
  if g_cache_css_ler_rec.exists(l_index) then
    --
    -- Lets get the hashed record.
    --
    if g_cache_css_ler_rec(l_index).id = p_ler_id then
      --
      null;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index =>l_index);
        --
        -- Check if the hash index exists, if not error
        --
        if not g_cache_css_ler_rec.exists(l_index) then
          --
          -- Raise an error as we are trying to retrieve a non cached object
          --
          raise no_data_found;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_css_ler_rec(l_index).id = p_ler_id then
            --
            -- We have a match
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  else
    --
    raise no_data_found;
    --
  end if;
  --
  -- At this point we have the master record so we can derive the set of
  -- children by looping through the relevant records.
  --
  ben_env_object.get(p_rec => l_env_rec);
  --
  if g_cache_css_ler_rec(l_index).starttorele_num is not null then
    --
    for l_count in g_cache_css_ler_rec(l_index).starttorele_num..
      g_cache_css_ler_rec(l_index).endtorele_num loop
      --
      if g_cache_css_rec(l_count).ler_id = p_ler_id and
        nvl(l_env_rec.lf_evt_ocrd_dt,l_env_rec.effective_date)
        between g_cache_css_rec(l_count).effective_start_date
        and     g_cache_css_rec(l_count).effective_end_date then
        --
        l_rec(l_rec.count+1) := g_cache_css_rec(l_count);
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  -- Assign l_rec to p_rec
  --
  p_rec := l_rec;
  --
--  hr_utility.set_location('Leaving '||l_proc,10);
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env_rec);
    --
    set_css_object(p_ler_id            => p_ler_id,
                   p_business_group_id => l_env_rec.business_group_id,
                   p_effective_date    => nvl(l_env_rec.lf_evt_ocrd_dt,
                                              l_env_rec.effective_date),
                   p_rec               => l_rec);
    --
    p_rec := l_rec;
    --
end get_object;
--
procedure clear_down_cache is
--
begin
  --
  g_cache_ler_rec.delete;
  g_cache_ler_ler_rec.delete;
  g_cache_css_rec.delete;
  g_cache_css_ler_rec.delete;
  --
end clear_down_cache;
--
end ben_life_object;

/
