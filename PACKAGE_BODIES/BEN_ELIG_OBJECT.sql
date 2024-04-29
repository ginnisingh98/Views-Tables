--------------------------------------------------------
--  DDL for Package Body BEN_ELIG_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIG_OBJECT" as
/* $Header: beneligo.pkb 120.0 2005/05/28 08:56:06 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Comp Elig Object Caching Routine
Purpose
	This package is used to return comp object elig information.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        05 May 99        G Perry    115.0      Created
        06 May 99        G Perry    115.1      Backport for Fidelity.
        06 May 99        G Perry    115.2      Leapfrog of 115.0
        07 May 99        G Perry    115.3      Added cache for ben_prtn_elig_f
                                               for Bala.
        07 May 99        G Perry    115.4      Fixed typos in PTIP call.
        25 May 99        G Perry    115.5      Added context to messages.
        11-Jul-99        mhoyes     115.6   - Removed + 0s from all cursors.
                                            - Modified overloaded trace messages.
        31 Aug 99        mhoyes     115.7   - Removed frequently executed trace
                                              locations.
        24 Mar 00        TMathers   115.8   - changed Tex Perry's captech
                                              set_name to set_token.
        15 May 00        RChase     115.9   - Performance modifications, Changes
                                              to parameter passing using NOCOPY,
                                              replace exists, remove extra assignment
                                              statements.
        22 May 00        mhoyes     115.10  - Modified set_object to pass out
                                              record structure.
                                            - Moved call to set object from
                                              benmngle into get_objects.
        29 May 00        mhoyes     115.11  - Fixed bug 5338.
*/
--------------------------------------------------------------------------------
--
g_package varchar2(80) := 'ben_elig_object.';
g_hash_key number := ben_hash_utility.get_hash_key;
g_hash_jump number := ben_hash_utility.get_hash_jump;
--
procedure set_object(p_pgm_id  in number,
                     p_rec     in out NOCOPY ben_elig_to_prte_rsn_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object pgmelpr';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  --
begin
  --
--  hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get hash index
  -- 2) If index is empty use index
  -- 3) If not check if index is correct in which case we have already
  --    cached index
  -- 4) If not correct index use alternate index
  -- 5) Keep trying until find index or find empty index
  --
  -- Get hashed index value
  --
  l_index := mod(p_pgm_id,g_hash_key);
  -- 115.9 replace previous code
    if g_cache_pgm_rec(l_index).pgm_id = p_pgm_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.9 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_pgm_rec(l_index).pgm_id <> p_pgm_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.9 set cache entry at current index location
   g_cache_pgm_rec(l_index):=p_rec;
--
end set_object;
--
procedure set_object(p_pl_id   in number,
                     p_rec     in out NOCOPY ben_elig_to_prte_rsn_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object plnelpr';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  --
begin
  --
  -- 1) Get hash index
  -- 2) If index is empty use index
  -- 3) If not check if index is correct in which case we have already
  --    cached index
  -- 4) If not correct index use alternate index
  -- 5) Keep trying until find index or find empty index
  --
  -- Get hashed index value
  --
  l_index := mod(p_pl_id,g_hash_key);
  --
  -- 115.9 replace previous code
    if g_cache_pl_rec(l_index).pl_id = p_pl_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.9 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_pl_rec(l_index).pl_id <> p_pl_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.9 set cache entry at current index location
   g_cache_pl_rec(l_index):=p_rec;
--
end set_object;
--
procedure set_object(p_oipl_id in number,
                     p_rec     in out NOCOPY ben_elig_to_prte_rsn_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object oiplelpr';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  --
begin
  --
  -- 1) Get hash index
  -- 2) If index is empty use index
  -- 3) If not check if index is correct in which case we have already
  --    cached index
  -- 4) If not correct index use alternate index
  -- 5) Keep trying until find index or find empty index
  --
  -- Get hashed index value
  --
  l_index := mod(p_oipl_id,g_hash_key);
  -- 115.9 replace previous code
    if g_cache_oipl_rec(l_index).oipl_id = p_oipl_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.9 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_oipl_rec(l_index).oipl_id <> p_oipl_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.9 set cache entry at current index location
   g_cache_oipl_rec(l_index):=p_rec;
--
end set_object;
--
procedure set_object(p_plip_id in number,
                     p_rec     in out NOCOPY ben_elig_to_prte_rsn_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object plipelpr';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  --
begin
  --
  -- 1) Get hash index
  -- 2) If index is empty use index
  -- 3) If not check if index is correct in which case we have already
  --    cached index
  -- 4) If not correct index use alternate index
  -- 5) Keep trying until find index or find empty index
  --
  -- Get hashed index value
  --
  l_index := mod(p_plip_id,g_hash_key);
  --
  -- 115.9 replace previous code
    if g_cache_plip_rec(l_index).plip_id = p_plip_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.9 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_plip_rec(l_index).plip_id <> p_plip_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.9 set cache entry at current index location
   g_cache_plip_rec(l_index):=p_rec;
--
end set_object;
--
procedure set_object(p_ptip_id in number,
                     p_rec     in out NOCOPY ben_elig_to_prte_rsn_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object ptipelpr';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  --
begin
  --
  -- 1) Get hash index
  -- 2) If index is empty use index
  -- 3) If not check if index is correct in which case we have already
  --    cached index
  -- 4) If not correct index use alternate index
  -- 5) Keep trying until find index or find empty index
  --
  -- Get hashed index value
  --
  l_index := mod(p_ptip_id,g_hash_key);
  -- 115.9 replace previous code
    if g_cache_ptip_rec(l_index).ptip_id = p_ptip_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.9 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_ptip_rec(l_index).ptip_id <> p_ptip_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.9 set cache entry at current index location
   g_cache_ptip_rec(l_index):=p_rec;
--
end set_object;
--
procedure set_object(p_pgm_id  in number,
                     p_rec     in out NOCOPY ben_prtn_elig_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object pgmpel';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  --
begin
  --
--  hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get hash index
  -- 2) If index is empty use index
  -- 3) If not check if index is correct in which case we have already
  --    cached index
  -- 4) If not correct index use alternate index
  -- 5) Keep trying until find index or find empty index
  --
  -- Get hashed index value
  --
  l_index := mod(p_pgm_id,g_hash_key);
  -- 115.9 replace previous code
    if g_cache_pgm_elig_rec(l_index).pgm_id = p_pgm_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.9 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_pgm_elig_rec(l_index).pgm_id <> p_pgm_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.9 set cache entry at current index location
   g_cache_pgm_elig_rec(l_index):=p_rec;
--
end set_object;
--
procedure set_object(p_pl_id   in number,
                     p_rec     in out NOCOPY ben_prtn_elig_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object plnpel';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  --
begin
  --
  -- 1) Get hash index
  -- 2) If index is empty use index
  -- 3) If not check if index is correct in which case we have already
  --    cached index
  -- 4) If not correct index use alternate index
  -- 5) Keep trying until find index or find empty index
  --
  -- Get hashed index value
  --
  l_index := mod(p_pl_id,g_hash_key);
  --
  -- 115.9 replace previous code
    if g_cache_pl_elig_rec(l_index).pl_id = p_pl_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.9 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_pl_elig_rec(l_index).pl_id <> p_pl_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.9 set cache entry at current index location
   g_cache_pl_elig_rec(l_index):=p_rec;
--
end set_object;
--
procedure set_object(p_oipl_id in number,
                     p_rec     in out NOCOPY ben_prtn_elig_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object oiplpel';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  --
begin
  --
  -- 1) Get hash index
  -- 2) If index is empty use index
  -- 3) If not check if index is correct in which case we have already
  --    cached index
  -- 4) If not correct index use alternate index
  -- 5) Keep trying until find index or find empty index
  --
  -- Get hashed index value
  --
  l_index := mod(p_oipl_id,g_hash_key);
  --
  -- 115.9 replace previous code
    if g_cache_oipl_elig_rec(l_index).oipl_id = p_oipl_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.9 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_oipl_elig_rec(l_index).oipl_id <> p_oipl_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.9 set cache entry at current index location
   g_cache_oipl_elig_rec(l_index):=p_rec;
--
end set_object;
--
procedure set_object(p_plip_id in number,
                     p_rec     in out NOCOPY ben_prtn_elig_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object plippel';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  --
begin
  --
  -- 1) Get hash index
  -- 2) If index is empty use index
  -- 3) If not check if index is correct in which case we have already
  --    cached index
  -- 4) If not correct index use alternate index
  -- 5) Keep trying until find index or find empty index
  --
  -- Get hashed index value
  --
  l_index := mod(p_plip_id,g_hash_key);
  -- 115.9 replace previous code
    if g_cache_plip_elig_rec(l_index).plip_id = p_plip_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.9 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_plip_elig_rec(l_index).plip_id <> p_plip_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.9 set cache entry at current index location
   g_cache_plip_elig_rec(l_index):=p_rec;
--
end set_object;
--
procedure set_object(p_ptip_id in number,
                     p_rec     in out NOCOPY ben_prtn_elig_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object ptippel';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  --
begin
  --
  -- 1) Get hash index
  -- 2) If index is empty use index
  -- 3) If not check if index is correct in which case we have already
  --    cached index
  -- 4) If not correct index use alternate index
  -- 5) Keep trying until find index or find empty index
  --
  -- Get hashed index value
  --
  l_index := mod(p_ptip_id,g_hash_key);
  -- 115.9 replace previous code
    if g_cache_ptip_elig_rec(l_index).ptip_id = p_ptip_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.9 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_ptip_elig_rec(l_index).ptip_id <> p_ptip_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.9 set cache entry at current index location
   g_cache_ptip_elig_rec(l_index):=p_rec;
--
end set_object;
--
procedure set_object(p_pl_id             in number,
                     p_ler_id            in number,
                     p_business_group_id in number,
                     p_effective_date    in date,
                     p_rec               in out NOCOPY ben_elig_to_prte_rsn_f%rowtype
                    ) is
  --
  l_proc varchar2(80) := g_package||'set_object plnler';
  --
  cursor c1 is
    select peo.*
    from   ben_elig_to_prte_rsn_f peo
    where  peo.business_group_id  = p_business_group_id
    and    peo.ler_id = p_ler_id
    and    peo.pl_id = p_pl_id
    and    p_effective_date
           between peo.effective_start_date
           and     peo.effective_end_date;
  --
  l_rec ben_elig_to_prte_rsn_f%rowtype;
  --
begin
  --
  open c1;
    --
    fetch c1 into l_rec;
    --
  close c1;
  --
  l_rec.pl_id := p_pl_id;
  --
  set_object(p_pl_id => p_pl_id,
             p_rec   => l_rec);
  --
  p_rec := l_rec;
  --
end set_object;
--
procedure set_object(p_pgm_id            in number,
                     p_ler_id            in number,
                     p_business_group_id in number,
                     p_effective_date    in date,
                     p_rec               in out NOCOPY ben_elig_to_prte_rsn_f%rowtype
                    )
is
  --
  l_proc varchar2(80) := g_package||'set_object pgmler';
  --
  cursor c1 is
    select peo.*
    from   ben_elig_to_prte_rsn_f peo
    where  peo.business_group_id  = p_business_group_id
    and    peo.ler_id = p_ler_id
    and    peo.pgm_id = p_pgm_id
    and    p_effective_date
           between peo.effective_start_date
           and     peo.effective_end_date;
  --
  l_rec ben_elig_to_prte_rsn_f%rowtype;
  --
begin
  --
--  hr_utility.set_location('Entering '||l_proc,10);
  --
  open c1;
    --
    fetch c1 into l_rec;
    --
  close c1;
  --
  l_rec.pgm_id := p_pgm_id;
  --
  set_object(p_pgm_id => p_pgm_id,
             p_rec    => l_rec);
  --
  p_rec := l_rec;
  --
--  hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_object;
--
procedure set_object(p_oipl_id           in number,
                     p_ler_id            in number,
                     p_business_group_id in number,
                     p_effective_date    in date,
                     p_rec               in out NOCOPY ben_elig_to_prte_rsn_f%rowtype
                     ) is
  --
  l_proc varchar2(80) := g_package||'set_object oipller';
  --
  cursor c1 is
    select peo.*
    from   ben_elig_to_prte_rsn_f peo
    where  peo.business_group_id  = p_business_group_id
    and    peo.ler_id = p_ler_id
    and    peo.oipl_id = p_oipl_id
    and    p_effective_date
           between peo.effective_start_date
           and     peo.effective_end_date;
  --
  l_rec ben_elig_to_prte_rsn_f%rowtype;
  --
begin
  --
  open c1;
    --
    fetch c1 into l_rec;
    --
  close c1;
  --
  l_rec.oipl_id := p_oipl_id;
  --
  set_object(p_oipl_id => p_oipl_id,
             p_rec     => l_rec);
  --
  p_rec := l_rec;
  --
end set_object;
--
procedure set_object(p_plip_id           in number,
                     p_ler_id            in number,
                     p_business_group_id in number,
                     p_effective_date    in date,
                     p_rec               in out NOCOPY ben_elig_to_prte_rsn_f%rowtype
                     ) is
  --
  l_proc varchar2(80) := g_package||'set_object plipler';
  --
  cursor c1 is
    select peo.*
    from   ben_elig_to_prte_rsn_f peo
    where  peo.business_group_id  = p_business_group_id
    and    peo.ler_id = p_ler_id
    and    peo.plip_id = p_plip_id
    and    p_effective_date
           between peo.effective_start_date
           and     peo.effective_end_date;
  --
  l_rec ben_elig_to_prte_rsn_f%rowtype;
  --
begin
  --
  open c1;
    --
    fetch c1 into l_rec;
    --
  close c1;
  --
  l_rec.plip_id := p_plip_id;
  --
  set_object(p_plip_id => p_plip_id,
             p_rec     => l_rec);
  --
  p_rec := l_rec;
  --
end set_object;
--
procedure set_object(p_ptip_id           in number,
                     p_ler_id            in number,
                     p_business_group_id in number,
                     p_effective_date    in date,
                     p_rec               in out NOCOPY ben_elig_to_prte_rsn_f%rowtype
                     ) is
  --
  l_proc varchar2(80) := g_package||'set_object ptipler';
  --
  cursor c1 is
    select peo.*
    from   ben_elig_to_prte_rsn_f peo
    where  peo.business_group_id  = p_business_group_id
    and    peo.ler_id = p_ler_id
    and    peo.ptip_id = p_ptip_id
    and    p_effective_date
           between peo.effective_start_date
           and     peo.effective_end_date;
  --
  l_rec ben_elig_to_prte_rsn_f%rowtype;
  --
begin
  --
  open c1;
    --
    fetch c1 into l_rec;
    --
  close c1;
  --
  l_rec.ptip_id := p_ptip_id;
  --
  set_object(p_ptip_id => p_ptip_id,
             p_rec     => l_rec);
  --
  p_rec := l_rec;
  --
end set_object;
--
procedure set_object(p_pl_id             in number,
                     p_business_group_id in number,
                     p_effective_date    in date) is
  --
  l_proc varchar2(80) := g_package||'set_object pln';
  --
  cursor c1 is
    select epa.*
    from   ben_prtn_elig_f epa
    where  epa.business_group_id  = p_business_group_id
    and    epa.pl_id = p_pl_id
    and    p_effective_date
           between epa.effective_start_date
           and     epa.effective_end_date;
  --
  l_rec ben_prtn_elig_f%rowtype;
  --
begin
  --
  open c1;
    --
    fetch c1 into l_rec;
    --
  close c1;
  --
  l_rec.pl_id := p_pl_id;
  --
  set_object(p_pl_id => p_pl_id,
             p_rec   => l_rec);
  --
end set_object;
--
procedure set_object(p_pgm_id            in number,
                     p_business_group_id in number,
                     p_effective_date    in date) is
  --
  l_proc varchar2(80) := g_package||'set_object pgm';
  --
  cursor c1 is
    select epa.*
    from   ben_prtn_elig_f epa
    where  epa.business_group_id  = p_business_group_id
    and    epa.pgm_id = p_pgm_id
    and    p_effective_date
           between epa.effective_start_date
           and     epa.effective_end_date;
  --
  l_rec ben_prtn_elig_f%rowtype;
  --
begin
  --
--  hr_utility.set_location('Entering '||l_proc,10);
  --
  open c1;
    --
    fetch c1 into l_rec;
    --
  close c1;
  --
  l_rec.pgm_id := p_pgm_id;
  --
  set_object(p_pgm_id => p_pgm_id,
             p_rec    => l_rec);
  --
--  hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_object;
--
procedure set_object(p_oipl_id           in number,
                     p_business_group_id in number,
                     p_effective_date    in date) is
  --
  l_proc varchar2(80) := g_package||'set_object oipl';
  --
  cursor c1 is
    select epa.*
    from   ben_prtn_elig_f epa
    where  epa.business_group_id  = p_business_group_id
    and    epa.oipl_id = p_oipl_id
    and    p_effective_date
           between epa.effective_start_date
           and     epa.effective_end_date;
  --
  l_rec ben_prtn_elig_f%rowtype;
  --
begin
  --
  open c1;
    --
    fetch c1 into l_rec;
    --
  close c1;
  --
  l_rec.oipl_id := p_oipl_id;
  --
  set_object(p_oipl_id => p_oipl_id,
             p_rec     => l_rec);
  --
end set_object;
--
procedure set_object(p_plip_id           in number,
                     p_business_group_id in number,
                     p_effective_date    in date) is
  --
  l_proc varchar2(80) := g_package||'set_object plip';
  --
  cursor c1 is
    select epa.*
    from   ben_prtn_elig_f epa
    where  epa.business_group_id  = p_business_group_id
    and    epa.plip_id = p_plip_id
    and    p_effective_date
           between epa.effective_start_date
           and     epa.effective_end_date;
  --
  l_rec ben_prtn_elig_f%rowtype;
  --
begin
  --
  open c1;
    --
    fetch c1 into l_rec;
    --
  close c1;
  --
  l_rec.plip_id := p_plip_id;
  --
  set_object(p_plip_id => p_plip_id,
             p_rec     => l_rec);
  --
end set_object;
--
procedure set_object(p_ptip_id           in number,
                     p_business_group_id in number,
                     p_effective_date    in date) is
  --
  l_proc varchar2(80) := g_package||'set_object ptip';
  --
  cursor c1 is
    select epa.*
    from   ben_prtn_elig_f epa
    where  epa.business_group_id  = p_business_group_id
    and    epa.ptip_id = p_ptip_id
    and    p_effective_date
           between epa.effective_start_date
           and     epa.effective_end_date;
  --
  l_rec ben_prtn_elig_f%rowtype;
  --
begin
  --
  open c1;
    --
    fetch c1 into l_rec;
    --
  close c1;
  --
  l_rec.ptip_id := p_ptip_id;
  --
  set_object(p_ptip_id => p_ptip_id,
             p_rec     => l_rec);
  --
end set_object;
--
-- Get object routines
--
procedure get_object(p_pgm_id  in  number,
                     p_ler_id  in  number default null,
                     p_rec     in out NOCOPY ben_elig_to_prte_rsn_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object pgmelpr';
  --
  l_env            ben_env_object.g_global_env_rec_type;
  l_index          pls_integer;
  --l_not_hash_found boolean;
  --
begin
  --
--  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --115.9 replace code
  l_index := mod(p_pgm_id,g_hash_key);
  --
    if g_cache_pgm_rec(l_index).pgm_id = p_pgm_id then
      --
      p_rec := g_cache_pgm_rec(l_index);
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_pgm_rec(l_index).pgm_id <> p_pgm_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      p_rec := g_cache_pgm_rec(l_index);
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    set_object(p_pgm_id            => p_pgm_id
              ,p_ler_id            => p_ler_id
              ,p_business_group_id => l_env.business_group_id
              ,p_effective_date    => nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date)
              ,p_rec               => p_rec
              );
    --
end get_object;
--
procedure get_object(p_pl_id   in  number,
                     p_ler_id  in  number default null,
                     p_rec     in out NOCOPY ben_elig_to_prte_rsn_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object plnelpr';
  --
  l_env            ben_env_object.g_global_env_rec_type;
  --
  l_index          pls_integer;
  --l_not_hash_found boolean;
  --
begin
  --
--  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  --115.9 replace code
  l_index := mod(p_pl_id,g_hash_key);
  --
    if g_cache_pl_rec(l_index).pl_id = p_pl_id then
      --
      p_rec := g_cache_pl_rec(l_index);
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_pl_rec(l_index).pl_id <> p_pl_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      p_rec := g_cache_pl_rec(l_index);
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    set_object(p_pl_id             => p_pl_id
              ,p_ler_id            => p_ler_id
              ,p_business_group_id => l_env.business_group_id
              ,p_effective_date    => nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date)
              ,p_rec               => p_rec
              );
    --
end get_object;
--
procedure get_object(p_oipl_id in  number,
                     p_ler_id  in  number default null,
                     p_rec     in out NOCOPY ben_elig_to_prte_rsn_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object oiplelpr';
  --
  l_env            ben_env_object.g_global_env_rec_type;
  --
  l_index          pls_integer;
  l_not_hash_found boolean;
  --
begin
  --
/*
--  hr_utility.set_location ('Entering '||l_proc,10);
*/
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  --115.9 replace code
  l_index := mod(p_oipl_id,g_hash_key);
  --
    if g_cache_oipl_rec(l_index).oipl_id = p_oipl_id then
      --
      p_rec := g_cache_oipl_rec(l_index);
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_oipl_rec(l_index).oipl_id <> p_oipl_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      p_rec := g_cache_oipl_rec(l_index);
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    set_object(p_oipl_id           => p_oipl_id
              ,p_ler_id            => p_ler_id
              ,p_business_group_id => l_env.business_group_id
              ,p_effective_date    => nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date)
              ,p_rec               => p_rec
              );
    --
end get_object;
--
procedure get_object(p_plip_id in  number,
                     p_ler_id  in  number default null,
                     p_rec     in out NOCOPY ben_elig_to_prte_rsn_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object plipelpr';
  --
  l_env            ben_env_object.g_global_env_rec_type;
  --
  l_index          pls_integer;
  --l_not_hash_found boolean;
  --
begin
  --
--  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  --115.9 replace code
  l_index := mod(p_plip_id,g_hash_key);
  --
    if g_cache_plip_rec(l_index).plip_id = p_plip_id then
      --
      p_rec := g_cache_plip_rec(l_index);
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_plip_rec(l_index).plip_id <> p_plip_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      p_rec := g_cache_plip_rec(l_index);
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    set_object(p_plip_id           => p_plip_id
              ,p_ler_id            => p_ler_id
              ,p_business_group_id => l_env.business_group_id
              ,p_effective_date    => nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date)
              ,p_rec               => p_rec
              );
    --
end get_object;
--
procedure get_object(p_ptip_id in  number,
                     p_ler_id  in  number default null,
                     p_rec     in out NOCOPY ben_elig_to_prte_rsn_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object ptipelpr';
  --
  l_env            ben_env_object.g_global_env_rec_type;
  --
  l_index          pls_integer;
  --l_not_hash_found boolean;
  --
begin
  --
--  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  --115.9 replace code
  l_index := mod(p_ptip_id,g_hash_key);
  --
    if g_cache_ptip_rec(l_index).ptip_id = p_ptip_id then
      --
      p_rec := g_cache_ptip_rec(l_index);
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_ptip_rec(l_index).ptip_id <> p_ptip_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      p_rec := g_cache_ptip_rec(l_index);
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    set_object(p_ptip_id           => p_ptip_id
              ,p_ler_id            => p_ler_id
              ,p_business_group_id => l_env.business_group_id
              ,p_effective_date    => nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date)
              ,p_rec               => p_rec
              );
    --
end get_object;
--
procedure get_object(p_pgm_id  in  number,
                     p_rec     in out NOCOPY ben_prtn_elig_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object pgmpel';
  --
  l_env            ben_env_object.g_global_env_rec_type;
  --
  l_index          pls_integer;
  l_not_hash_found boolean;
  --
begin
  --
--  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  --115.9 replace code
  l_index := mod(p_pgm_id,g_hash_key);
  --
    if g_cache_pgm_elig_rec(l_index).pgm_id = p_pgm_id then
      --
      p_rec := g_cache_pgm_elig_rec(l_index);
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_pgm_elig_rec(l_index).pgm_id <> p_pgm_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      p_rec := g_cache_pgm_elig_rec(l_index);
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    ben_elig_object.set_object
      (p_pgm_id            => p_pgm_id
      ,p_business_group_id => l_env.business_group_id
      ,p_effective_date    => nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date)
      );
    --
    p_rec := g_cache_pgm_elig_rec(l_index);
    --
end get_object;
--
procedure get_object(p_pl_id   in  number,
                     p_rec     in out NOCOPY ben_prtn_elig_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object plnpel';
  --
  l_env            ben_env_object.g_global_env_rec_type;
  --
  l_index          pls_integer;
  --l_not_hash_found boolean;
  --
begin
  --
--  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  --115.9 replace code
  l_index := mod(p_pl_id,g_hash_key);
  --
    if g_cache_pl_elig_rec(l_index).pl_id = p_pl_id then
      --
      p_rec := g_cache_pl_elig_rec(l_index);
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_pl_elig_rec(l_index).pl_id <> p_pl_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      p_rec := g_cache_pl_elig_rec(l_index);
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    ben_elig_object.set_object
      (p_pl_id             => p_pl_id
      ,p_business_group_id => l_env.business_group_id
      ,p_effective_date    => nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date)
      );
    --
    p_rec := g_cache_pl_elig_rec(l_index);
    --
end get_object;
--
procedure get_object(p_oipl_id in  number,
                     p_rec     in out NOCOPY ben_prtn_elig_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object oiplpel';
  --
  l_env            ben_env_object.g_global_env_rec_type;
  --
  l_index          pls_integer;
  --l_not_hash_found boolean;
  --
begin
  --
--  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --115.9 replace code
  l_index := mod(p_oipl_id,g_hash_key);
  --
    if g_cache_oipl_elig_rec(l_index).oipl_id = p_oipl_id then
      --
      p_rec := g_cache_oipl_elig_rec(l_index);
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_oipl_elig_rec(l_index).oipl_id <> p_oipl_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      p_rec := g_cache_oipl_elig_rec(l_index);
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    ben_elig_object.set_object
      (p_oipl_id           => p_oipl_id
      ,p_business_group_id => l_env.business_group_id
      ,p_effective_date    => nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date)
      );
    --
    p_rec := g_cache_oipl_elig_rec(l_index);
    --
end get_object;
--
procedure get_object(p_plip_id in  number,
                     p_rec     in out NOCOPY ben_prtn_elig_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object plippel';
  --
  l_env            ben_env_object.g_global_env_rec_type;
  --
  l_index          pls_integer;
  --l_not_hash_found boolean;
  --
begin
  --
--  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  --115.9 replace code
  l_index := mod(p_plip_id,g_hash_key);
  --
    if g_cache_plip_elig_rec(l_index).plip_id = p_plip_id then
      --
      p_rec := g_cache_plip_elig_rec(l_index);
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_plip_elig_rec(l_index).plip_id <> p_plip_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      p_rec := g_cache_plip_elig_rec(l_index);
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    ben_elig_object.set_object
      (p_plip_id           => p_plip_id
      ,p_business_group_id => l_env.business_group_id
      ,p_effective_date    => nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date)
      );
    --
    p_rec := g_cache_plip_elig_rec(l_index);
    --
end get_object;
--
procedure get_object(p_ptip_id in  number,
                     p_rec     in out NOCOPY ben_prtn_elig_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object ptippel';
  --
  l_env            ben_env_object.g_global_env_rec_type;
  --
  l_index          pls_integer;
  --l_not_hash_found boolean;
  --
begin
  --
--  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  --115.9 replace code
  l_index := mod(p_ptip_id,g_hash_key);
  --
    if g_cache_ptip_elig_rec(l_index).ptip_id = p_ptip_id then
      --
      p_rec := g_cache_ptip_elig_rec(l_index);
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_ptip_elig_rec(l_index).ptip_id <> p_ptip_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      p_rec := g_cache_ptip_elig_rec(l_index);
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    ben_elig_object.set_object
      (p_ptip_id           => p_ptip_id
      ,p_business_group_id => l_env.business_group_id
      ,p_effective_date    => nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date)
      );
    --
    p_rec := g_cache_ptip_elig_rec(l_index);
    --
end get_object;
--
procedure clear_down_cache is
  --
  l_proc varchar2(80) := g_package||'clear_down_cache';
  --
begin
  --
--  hr_utility.set_location ('Entering '||l_proc,10);
  --
  g_cache_pgm_rec.delete;
  g_cache_pl_rec.delete;
  g_cache_oipl_rec.delete;
  g_cache_plip_rec.delete;
  g_cache_ptip_rec.delete;
  g_cache_pgm_elig_rec.delete;
  g_cache_pl_elig_rec.delete;
  g_cache_oipl_elig_rec.delete;
  g_cache_plip_elig_rec.delete;
  g_cache_ptip_elig_rec.delete;
  --
--  hr_utility.set_location ('Leaving '||l_proc,10);
  --
end clear_down_cache;
--
end ben_elig_object;

/
