--------------------------------------------------------
--  DDL for Package Body BEN_LOCATION_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LOCATION_OBJECT" as
/* $Header: benlocch.pkb 120.0 2005/05/28 09:06:47 appldev noship $ */
--
/*
+==============================================================================+
|                        Copyright (c) 1997 Oracle Corporation                 |
|                           Redwood Shores, California, USA                    |
|                               All rights reserved.                           |
+==============================================================================+
--
History
  Version    Date       Who        What?
  ---------  ---------  ---------- --------------------------------------------
  115.0      08-Jun-99  bbulusu    Created.
  115.1      05-Aug-99  GPERRY     Fixed bug in set_object and last
                                   cached record logic added.
  115.2      16-Aug-99  GPERRY     Added nocopy compiler directive.
  115.3      06 May 00  RChase     Added additional NOCOPY directives
                                   replaced get code and removed additional
                                   record assignments
  115.4      29 Dec 00  Tmathers   Fixed chgeck_sql errors.
  -----------------------------------------------------------------------------
*/
--
g_package varchar2(30) := 'ben_location_object.';
g_hash_key number := ben_hash_utility.get_hash_key;
g_hash_jump number := ben_hash_utility.get_hash_jump;
--
-- Set object routines
--
procedure set_object(p_rec in out NOCOPY hr_locations_all%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object';
  l_index          pls_integer;
  l_not_hash_found boolean;
  --
begin
  --
  --hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := ben_hash_utility.get_hashed_index(p_id => p_rec.location_id);
  --
    -- 115.3 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_loc_rec(l_index).location_id = p_rec.location_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.3 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_loc_rec(l_index).location_id <> p_rec.location_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  --115.3 set cache entry at current index location
   g_cache_loc_rec(l_index):=p_rec;
--
end set_object;
--
-- Set object alternate route routines
--
procedure set_loc_object
  (p_location_id       in number,
   p_rec               in out nocopy hr_locations_all%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_loc_object';
  --
  cursor c1 is
    select loc.*
    from   hr_locations_all loc
    where  loc.location_id = p_location_id;
  --115.3 remove additional declaration
  --l_rec hr_locations_all%rowtype;
  --
begin
  --
  --hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  open c1;
    --
    fetch c1 into p_rec;
    if c1%notfound then
      --115.3 altered to use NOCOPY parameter
      --l_rec.location_id := p_location_id;
      p_rec.location_id := p_location_id;
      --
    end if;
    --
  close c1;
  --
  set_object(p_rec => p_rec);
  --115.3 remove assignment
  --p_rec := l_rec;
  --
  --hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_loc_object;
--
-- Get object routines
--
procedure get_object(p_location_id  in  number,
                     p_rec          in out nocopy hr_locations_all%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            hr_locations_all%rowtype;
  --
begin
  --
  --hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_loc_rec.location_id = p_location_id then
    --
    p_rec := g_cache_last_loc_rec;
    return;
    --
  end if;
  -- 1) Get hashed index
  -- 2) If hashed index is correct pgm then return program
  -- 3) If hashed index is not correct program then check next index
  -- 4) Repest 3 until correct program found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := mod(p_location_id,g_hash_key);
  --
    if g_cache_loc_rec(l_index).location_id = p_location_id then
      --
      g_cache_last_loc_rec := g_cache_loc_rec(l_index);
      p_rec := g_cache_last_loc_rec;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_loc_rec(l_index).location_id <> p_location_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      g_cache_last_loc_rec := g_cache_loc_rec(l_index);
      p_rec := g_cache_last_loc_rec;
      --
    end if;
    --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    set_loc_object(p_location_id       => p_location_id,
                   p_rec               => p_rec);
    --
    g_cache_last_loc_rec := p_rec;
    --115.3 remove assignment
    --p_rec := l_rec;
    --
end get_object;
--
procedure clear_down_cache is
  --
  l_last_loc_rec hr_locations_all%rowtype;
  --
begin
  --
  g_cache_loc_rec.delete;
  g_cache_last_loc_rec := l_last_loc_rec;
  --
end clear_down_cache;
--
end ben_location_object;

/
