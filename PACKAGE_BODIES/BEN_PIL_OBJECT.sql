--------------------------------------------------------
--  DDL for Package Body BEN_PIL_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PIL_OBJECT" as
/* $Header: bepilobj.pkb 120.0 2005/05/28 10:50:10 appldev noship $ */
--
/*
+==============================================================================+
|                        Copyright (c) 1997 Oracle Corporation                 |
|                           Redwood Shores, California, USA                    |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
	Person Object Caching Routine
Purpose
	This package is used to return person object information.
History
  Version    Date       Who        What?
  ---------  ---------  ---------- --------------------------------------------
  115.0      11-Jun-99  mhoyes     Created.
  115.1      31-Jan-01  mhoyes   - Removed STRTD life event restriction so that
                                   cache supports all types of life event.
  115.2      20-Mar-02  vsethi     added dbdrv lines
  -----------------------------------------------------------------------------
*/
--
g_package varchar2(30) := 'ben_pil_object.';
g_hash_key number := ben_hash_utility.get_hash_key;
g_hash_jump number := ben_hash_utility.get_hash_jump;
--
-- Set object routines
--
procedure set_object
  (p_rec in out nocopy ben_per_in_ler%rowtype
  )
is
  --
  l_index          pls_integer;
  --
begin
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := mod(p_rec.per_in_ler_id,g_hash_key);
  --
  if g_cache_pil_rec(l_index).per_in_ler_id = p_rec.per_in_ler_id then
     -- do nothing, cache entry already exists
     null;
  else
    --
    -- Loop through the hash using the jump routine to check further
    -- indexes
    -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
    --
    l_index := l_index+g_hash_jump;
    while g_cache_pil_rec(l_index).per_in_ler_id <> p_rec.per_in_ler_id loop
      --
      l_index := l_index+g_hash_jump;
     end loop;
    --
  end if;
  --
exception when NO_DATA_FOUND then
  -- set cache entry at current index location
   g_cache_pil_rec(l_index):=p_rec;
--
end set_object;
--
procedure get_object
  (p_per_in_ler_id in  number
  ,p_rec           in out nocopy ben_per_in_ler%rowtype
  )
is
  --
  l_index          pls_integer;
  l_env            ben_env_object.g_global_env_rec_type;
  --
  cursor c1
  is
    select pil.*
    from   ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id;
    --
    -- Removed for EFC. This cache is intended to support all life
    -- event information for all types of life event. It should not be
    -- restricted to started life events only
    --
/*
    and    pil.per_in_ler_stat_cd = 'STRTD';
*/
  --
begin
  --
  if g_cache_last_pil_rec.per_in_ler_id = p_per_in_ler_id then
    --
    p_rec := g_cache_last_pil_rec;
    return;
    --
  end if;
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return assignment
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := mod(p_per_in_ler_id,g_hash_key);
  --
  if g_cache_pil_rec(l_index).per_in_ler_id = p_per_in_ler_id then
    --
    g_cache_last_pil_rec := g_cache_pil_rec(l_index);
    p_rec := g_cache_last_pil_rec;
    --
  else
    --
    -- We need to loop through all the hashed indexes
    -- if none exists at current index the NO_DATA_FOUND expection will fire
    --
    l_index := l_index+g_hash_jump;
    while g_cache_pil_rec(l_index).person_id <> p_per_in_ler_id loop
      --
      l_index := l_index+g_hash_jump;
      --
    end loop;
    --
    g_cache_last_pil_rec := g_cache_pil_rec(l_index);
    p_rec := g_cache_last_pil_rec;
    --
  end if;
exception
  --
  when no_data_found then
    --
    open c1;
    fetch c1 into p_rec;
    if c1%notfound then
      fnd_message.set_name('BEN','BEN_92204_OBJECT_NOT_FOUND');
      fnd_message.set_token('PROC','ben_pil_object.get_object ');
      fnd_message.set_token('PIL',p_per_in_ler_id);
      fnd_message.raise_error;
    end if;
    close c1;
    set_object(p_rec => p_rec);
    --
end get_object;
--
procedure clear_down_cache is
  --
  l_cache_last_pil_rec ben_per_in_ler%rowtype;
  --
begin
  --
  g_cache_pil_rec.delete;
  --
  -- Clear last cache records
  --
  g_cache_last_pil_rec := l_cache_last_pil_rec;
  --
end clear_down_cache;
--
end ben_pil_object;

/
