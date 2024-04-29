--------------------------------------------------------
--  DDL for Package Body BEN_COMP_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COMP_OBJECT" as
/* $Header: bencompo.pkb 120.0 2005/05/28 03:51:44 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Comp Object Caching Routine
Purpose
	This package is used to return comp object information.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        05 May 99        G Perry    115.0      Created
        27 May 99        G Perry    115.1      Added extra cache for cobra.
        25 Jun 99        G Perry    115.2      Made objects cache on demand.
        08 Jul 99        mhoyes     115.3    - Modified trace messages.
                                             - Removed + 0s from all cursors.
        12 Jul 99        jcarpent   115.4    - Added checks for backed out pil.
        04 Aug 99        G Perry    115.5      Added last record got cache.
        12 Aug 99        mhoyes     115.6    - Removed frequently executed trace
                                               locations.
        12 Aug 99        G Perry    115.7      Added BUSINESS_GROUP and
                                               EFFECTIVE_DATE as extra contexts
                                               for error message.
        31 Aug 99        mhoyes     115.8    - Removed frequently executed trace
                                               locations.
        31 Mar 99        gperry     115.9      Added oiplip support.
        06 May 00        rchase     115.10     Performance modifications
        29 Dec 00        tmathers   115.11     fixed check_sql errors.
        03 Jun 04        rpgupta    115.13     3662774
                                               changed cursor c1 for performance
*/
--------------------------------------------------------------------------------
--
g_package varchar2(30) := 'ben_comp_object.';
g_hash_key number := ben_hash_utility.get_hash_key;
g_hash_jump number := ben_hash_utility.get_hash_jump;
--
-- Set object routines
--
procedure set_object(p_rec in out NOCOPY ben_pgm_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object pgm';
  l_index          pls_integer;
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
  l_index := ben_hash_utility.get_hashed_index(p_id => p_rec.pgm_id);
  --115.10  replaced original exists checking with equality check and exception
    if g_cache_pgm_rec(l_index).pgm_id = p_rec.pgm_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.10 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_pgm_rec(l_index).pgm_id <> p_rec.pgm_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- set cache entry at current index location
   g_cache_pgm_rec(l_index):=p_rec;
  --
end set_object;
--
procedure set_object(p_rec in out nocopy ben_pl_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object pln ';
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
  l_index := ben_hash_utility.get_hashed_index(p_id => p_rec.pl_id);
  --115.10  replaced original exists checking with equality check and exception
    if g_cache_pl_rec(l_index).pl_id = p_rec.pl_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.10 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_pl_rec(l_index).pl_id <> p_rec.pl_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- set cache entry at current index location
   g_cache_pl_rec(l_index):=p_rec;
  --
end set_object;
--
procedure set_object(p_rec in out nocopy ben_oipl_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object oipl ';
  l_index          pls_integer;
  --l_not_hash_found boolean;
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
  l_index := ben_hash_utility.get_hashed_index(p_id => p_rec.oipl_id);
  --115.10  replaced original exists checking with equality check and exception
    if g_cache_oipl_rec(l_index).oipl_id = p_rec.oipl_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.10 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_oipl_rec(l_index).oipl_id <> p_rec.oipl_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- set cache entry at current index location
   g_cache_oipl_rec(l_index):=p_rec;
  --
end set_object;
--
procedure set_object(p_rec in out nocopy ben_plip_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object plip ';
  l_index          pls_integer;
  l_not_hash_found boolean;
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
  l_index := ben_hash_utility.get_hashed_index(p_id => p_rec.plip_id);
  --115.10  replaced original exists checking with equality check and exception
    if g_cache_plip_rec(l_index).plip_id = p_rec.plip_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.10 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_plip_rec(l_index).plip_id <> p_rec.plip_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- set cache entry at current index location
   g_cache_plip_rec(l_index):=p_rec;
  --
end set_object;
--
procedure set_object(p_rec in out nocopy ben_ptip_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object ptip';
  l_index          pls_integer;
  --l_not_hash_found boolean;
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
  l_index := ben_hash_utility.get_hashed_index(p_id => p_rec.ptip_id);
  --115.10  replaced original exists checking with equality check and exception
    if g_cache_ptip_rec(l_index).ptip_id = p_rec.ptip_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.10 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_ptip_rec(l_index).ptip_id <> p_rec.ptip_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- set cache entry at current index location
   g_cache_ptip_rec(l_index):=p_rec;
  --
end set_object;
--
procedure set_object(p_rec in out nocopy ben_opt_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object opt ';
  l_index          pls_integer;
  --l_not_hash_found boolean;
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
  l_index := ben_hash_utility.get_hashed_index(p_id => p_rec.opt_id);
  --
  --115.10  replaced original exists checking with equality check and exception
    if g_cache_opt_rec(l_index).opt_id = p_rec.opt_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.10 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_opt_rec(l_index).opt_id <> p_rec.opt_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- set cache entry at current index location
   g_cache_opt_rec(l_index):=p_rec;
  --
end set_object;
--
procedure set_object(p_rec in out nocopy ben_oiplip_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object oiplip ';
  l_index          pls_integer;
  --l_not_hash_found boolean;
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
  l_index := ben_hash_utility.get_hashed_index(p_id => p_rec.oiplip_id);
  --115.10  replaced original exists checking with equality check and exception
    if g_cache_oiplip_rec(l_index).oiplip_id = p_rec.oiplip_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.10 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_oiplip_rec(l_index).oiplip_id <> p_rec.oiplip_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- set cache entry at current index location
   g_cache_oiplip_rec(l_index):=p_rec;
  --
end set_object;
--
-- Set object alternate route routines
--
procedure set_object(p_pl_id             in number,
                     p_business_group_id in number,
                     p_effective_date    in date,
                     p_rec               in out NOCOPY ben_pl_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object alt pln';
  --
  cursor c1 is
    select pln.*
    from   ben_pl_f pln
    where  pln.pl_id = p_pl_id
    and    pln.business_group_id  = p_business_group_id
    and    p_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date;
  --
  --l_rec ben_pl_f%rowtype;
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
    fetch c1 into p_rec;
    if c1%notfound then
      --
      close c1;
      fnd_message.set_name('BEN','BEN_92204_OBJECT_NOT_FOUND');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('PGM',null);
      fnd_message.set_token('PLN',p_pl_id);
      fnd_message.set_token('OIPL',null);
      fnd_message.set_token('PLIP',null);
      fnd_message.set_token('PTIP',null);
      fnd_message.set_token('OPT',null);
      fnd_message.set_token('OIPLIP',null);
      fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
      fnd_message.set_token('BUSINESS_GROUP',p_business_group_id);
      fnd_message.raise_error;
      --
    end if;
    --
  close c1;
  --
  set_object(p_rec => p_rec);
  --
  -- p_rec := l_rec;
  --
--  hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_object;
--
procedure set_object(p_pgm_id            in  number,
                     p_business_group_id in  number,
                     p_effective_date    in  date,
                     p_rec               in out nocopy ben_pgm_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object alt pgm';
  --
  cursor c1 is
    select pgm.*
    from   ben_pgm_f pgm
    where  pgm.pgm_id = p_pgm_id
    and    pgm.business_group_id  = p_business_group_id
    and    p_effective_date
           between pgm.effective_start_date
           and     pgm.effective_end_date;
  --
  --l_rec ben_pgm_f%rowtype;
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
    fetch c1 into p_rec;
    if c1%notfound then
      --
      close c1;
      fnd_message.set_name('BEN','BEN_92204_OBJECT_NOT_FOUND');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('PGM',p_pgm_id);
      fnd_message.set_token('PLN',null);
      fnd_message.set_token('OIPL',null);
      fnd_message.set_token('PLIP',null);
      fnd_message.set_token('PTIP',null);
      fnd_message.set_token('OPT',null);
      fnd_message.set_token('OIPLIP',null);
      fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
      fnd_message.set_token('BUSINESS_GROUP',p_business_group_id);
      fnd_message.raise_error;
      --
    end if;
    --
  close c1;
  --
  set_object(p_rec => p_rec);
  --
  --p_rec := l_rec;
  --
--  hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_object;
--
procedure set_object(p_oipl_id           in  number,
                     p_business_group_id in  number,
                     p_effective_date    in  date,
                     p_rec               in out NOCOPY ben_oipl_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object alt oipl';
  --
  cursor c1 is
    select cop.*
    from   ben_oipl_f cop
    where  cop.oipl_id = p_oipl_id
    and    cop.business_group_id  = p_business_group_id
    and    p_effective_date
           between cop.effective_start_date
           and     cop.effective_end_date;
  --
  --l_rec ben_oipl_f%rowtype;
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
    fetch c1 into p_rec;
    if c1%notfound then
      --
      close c1;
      fnd_message.set_name('BEN','BEN_92204_OBJECT_NOT_FOUND');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('PGM',null);
      fnd_message.set_token('PLN',null);
      fnd_message.set_token('OIPL',p_oipl_id);
      fnd_message.set_token('PLIP',null);
      fnd_message.set_token('PTIP',null);
      fnd_message.set_token('OPT',null);
      fnd_message.set_token('OIPLIP',null);
      fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
      fnd_message.set_token('BUSINESS_GROUP',p_business_group_id);
      fnd_message.raise_error;
      --
    end if;
    --
  close c1;
  --
  set_object(p_rec => p_rec);
  --
  --p_rec := l_rec;
  --
--  hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_object;
--
procedure set_object(p_plip_id           in  number,
                     p_business_group_id in  number,
                     p_effective_date    in  date,
                     p_rec               in out NOCOPY ben_plip_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object alt plip ';
  --
  cursor c1 is
	    select cpp.*
    from   ben_plip_f cpp
    where  cpp.plip_id = p_plip_id
    and    cpp.business_group_id  = p_business_group_id
    and    p_effective_date
           between cpp.effective_start_date
           and     cpp.effective_end_date;
  --
  --l_rec ben_plip_f%rowtype;
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
    fetch c1 into p_rec;
    if c1%notfound then
      --
      close c1;
      fnd_message.set_name('BEN','BEN_92204_OBJECT_NOT_FOUND');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('PGM',null);
      fnd_message.set_token('PLN',null);
      fnd_message.set_token('OIPL',null);
      fnd_message.set_token('PLIP',p_plip_id);
      fnd_message.set_token('PTIP',null);
      fnd_message.set_token('OPT',null);
      fnd_message.set_token('OIPLIP',null);
      fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
      fnd_message.set_token('BUSINESS_GROUP',p_business_group_id);
      fnd_message.raise_error;
      --
    end if;
    --
  close c1;
  --
  set_object(p_rec => p_rec);
  --
  --p_rec := l_rec;
  --
--  hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_object;
--
procedure set_object(p_ptip_id           in  number,
                     p_business_group_id in  number,
                     p_effective_date    in  date,
                     p_rec               in out NOCOPY ben_ptip_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object ptip';
  --
  cursor c1 is
    select ctp.*
    from   ben_ptip_f ctp
    where  ctp.ptip_id = p_ptip_id
    and    ctp.business_group_id  = p_business_group_id
    and    p_effective_date
           between ctp.effective_start_date
           and     ctp.effective_end_date;
  --
  l_rec ben_ptip_f%rowtype;
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
    fetch c1 into p_rec;
    if c1%notfound then
      --
      close c1;
      fnd_message.set_name('BEN','BEN_92204_OBJECT_NOT_FOUND');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('PGM',null);
      fnd_message.set_token('PLN',null);
      fnd_message.set_token('OIPL',null);
      fnd_message.set_token('PLIP',null);
      fnd_message.set_token('PTIP',p_ptip_id);
      fnd_message.set_token('OPT',null);
      fnd_message.set_token('OIPLIP',null);
      fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
      fnd_message.set_token('BUSINESS_GROUP',p_business_group_id);
      fnd_message.raise_error;
      --
    end if;
    --
  close c1;
  --
  set_object(p_rec => p_rec);
  --
  --p_rec := l_rec;
  --
--  hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_object;
--
procedure set_object(p_opt_id            in  number,
                     p_business_group_id in  number,
                     p_effective_date    in  date,
                     p_rec               in out nocopy ben_opt_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object alt opt';
  --
  cursor c1 is
    select opt.*
    from   ben_opt_f opt
    where  opt.opt_id = p_opt_id
    and    opt.business_group_id  = p_business_group_id
    and    p_effective_date
           between opt.effective_start_date
           and     opt.effective_end_date;
  --
  --l_rec ben_opt_f%rowtype;
  --
begin
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  open c1;
    --
    fetch c1 into p_rec;
    if c1%notfound then
      --
      close c1;
      fnd_message.set_name('BEN','BEN_92204_OBJECT_NOT_FOUND');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('PGM',null);
      fnd_message.set_token('PLN',null);
      fnd_message.set_token('OIPL',null);
      fnd_message.set_token('PLIP',null);
      fnd_message.set_token('PTIP',null);
      fnd_message.set_token('OPT',p_opt_id);
      fnd_message.set_token('OIPLIP',null);
      fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
      fnd_message.set_token('BUSINESS_GROUP',p_business_group_id);
      fnd_message.raise_error;
      --
    end if;
    --
  close c1;
  --
  set_object(p_rec => p_rec);
  --
  --p_rec := l_rec;
  --
end set_object;
--
procedure set_object(p_oiplip_id         in  number,
                     p_business_group_id in  number,
                     p_effective_date    in  date,
                     p_rec               in out NOCOPY ben_oiplip_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object alt oiplip';
  --
  cursor c1 is
    select opp.*
    from   ben_oiplip_f opp
    where  opp.oiplip_id = p_oiplip_id
    and    opp.business_group_id  = p_business_group_id
    and    p_effective_date
           between opp.effective_start_date
           and     opp.effective_end_date;
  --
  --l_rec ben_oiplip_f%rowtype;
  --
begin
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  open c1;
    --
    fetch c1 into p_rec;
    if c1%notfound then
      --
      close c1;
      fnd_message.set_name('BEN','BEN_92204_OBJECT_NOT_FOUND');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('PGM',null);
      fnd_message.set_token('PLN',null);
      fnd_message.set_token('OIPL',null);
      fnd_message.set_token('PLIP',null);
      fnd_message.set_token('PTIP',null);
      fnd_message.set_token('OPT',null);
      fnd_message.set_token('OIPLIP',p_oiplip_id);
      fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
      fnd_message.set_token('BUSINESS_GROUP',p_business_group_id);
      fnd_message.raise_error;
      --
    end if;
    --
  close c1;
  --
  set_object(p_rec => p_rec);
  --
  --p_rec := l_rec;
  --
end set_object;
--
-- Get object routines
--
procedure get_object(p_pgm_id in  number,
                     p_rec    in out NOCOPY ben_pgm_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object pgm';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            ben_pgm_f%rowtype;
  --
begin
  --
--  hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_pgm_rec.pgm_id = p_pgm_id then
    --
    p_rec := g_cache_last_pgm_rec;
    return;
    --
  end if;
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct pgm then return program
  -- 3) If hashed index is not correct program then check next index
  -- 4) Repest 3 until correct program found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := ben_hash_utility.get_hashed_index(p_id => p_pgm_id);
  --
    if g_cache_pgm_rec(l_index).pgm_id = p_pgm_id then
      --
      g_cache_last_pgm_rec := g_cache_pgm_rec(l_index);
      p_rec := g_cache_last_pgm_rec;
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
      g_cache_last_pgm_rec := g_cache_pgm_rec(l_index);
      p_rec := g_cache_last_pgm_rec;
      --
    end if;
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    set_object(p_pgm_id            => p_pgm_id,
               p_business_group_id => l_env.business_group_id,
               p_effective_date    => nvl(l_env.lf_evt_ocrd_dt,
                                      l_env.effective_date),
               p_rec               => p_rec);
    --
    g_cache_last_pgm_rec := p_rec;
    --p_rec := l_rec;
    --
end get_object;
--
procedure get_object(p_pl_id  in  number,
                     p_rec    in out NOCOPY ben_pl_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object pln';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            ben_pl_f%rowtype;
  --
begin
  --
--  hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_pl_rec.pl_id = p_pl_id then
    --
    p_rec := g_cache_last_pl_rec;
    return;
    --
  end if;
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct pgm then return program
  -- 3) If hashed index is not correct program then check next index
  -- 4) Repest 3 until correct program found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := ben_hash_utility.get_hashed_index(p_id => p_pl_id);
  --
    if g_cache_pl_rec(l_index).pl_id = p_pl_id then
      --
      g_cache_last_pl_rec := g_cache_pl_rec(l_index);
      p_rec := g_cache_last_pl_rec;
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
      g_cache_last_pl_rec := g_cache_pl_rec(l_index);
      p_rec := g_cache_last_pl_rec;
      --
    end if;
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    set_object(p_pl_id             => p_pl_id ,
               p_business_group_id => l_env.business_group_id,
               p_effective_date    => nvl(l_env.lf_evt_ocrd_dt,
                                      l_env.effective_date),
               p_rec               => p_rec);
    --
    g_cache_last_pl_rec := p_rec;
    --p_rec := l_rec;
    --
  --  hr_utility.set_location('NDF Leaving '||l_proc,10);
    --
end get_object;
--
procedure get_object(p_oipl_id in  number,
                     p_rec     in out NOCOPY ben_oipl_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object oipl';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            ben_oipl_f%rowtype;
  --
begin
  --
--  hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_oipl_rec.oipl_id = p_oipl_id then
    --
    p_rec := g_cache_last_oipl_rec;
    return;
    --
  end if;
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct pgm then return program
  -- 3) If hashed index is not correct program then check next index
  -- 4) Repest 3 until correct program found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := ben_hash_utility.get_hashed_index(p_id => p_oipl_id);
  --
    if g_cache_oipl_rec(l_index).oipl_id = p_oipl_id then
      --
      g_cache_last_oipl_rec := g_cache_oipl_rec(l_index);
      p_rec := g_cache_last_oipl_rec;
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
      g_cache_last_oipl_rec := g_cache_oipl_rec(l_index);
      p_rec := g_cache_last_oipl_rec;
      --
    end if;
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    set_object(p_oipl_id           => p_oipl_id,
               p_business_group_id => l_env.business_group_id,
               p_effective_date    => nvl(l_env.lf_evt_ocrd_dt,
                                      l_env.effective_date),
               p_rec               => p_rec);
    --
    g_cache_last_oipl_rec := p_rec;
    --p_rec := l_rec;
    --
end get_object;
--
procedure get_object(p_plip_id in  number,
                     p_rec     in out NOCOPY ben_plip_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object plip';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            ben_plip_f%rowtype;
  --
begin
  --
--  hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_plip_rec.plip_id = p_plip_id then
    --
    p_rec := g_cache_last_plip_rec;
    return;
    --
  end if;
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct pgm then return program
  -- 3) If hashed index is not correct program then check next index
  -- 4) Repest 3 until correct program found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := ben_hash_utility.get_hashed_index(p_id => p_plip_id);
  --
    if g_cache_plip_rec(l_index).plip_id = p_plip_id then
      --
      g_cache_last_plip_rec := g_cache_plip_rec(l_index);
      p_rec := g_cache_last_plip_rec;
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
      g_cache_last_plip_rec := g_cache_plip_rec(l_index);
      p_rec := g_cache_last_plip_rec;
      --
    end if;
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    set_object(p_plip_id           => p_plip_id,
               p_business_group_id => l_env.business_group_id,
               p_effective_date    => nvl(l_env.lf_evt_ocrd_dt,
                                      l_env.effective_date),
               p_rec               => p_rec);
    --
    g_cache_last_plip_rec := p_rec;
    --p_rec := l_rec;
    --
end get_object;
--
procedure get_object(p_ptip_id in  number,
                     p_rec     in out nocopy ben_ptip_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object ptip';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            ben_ptip_f%rowtype;
  --
begin
  --
--  hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_ptip_rec.ptip_id = p_ptip_id then
    --
    p_rec := g_cache_last_ptip_rec;
    return;
    --
  end if;
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct pgm then return program
  -- 3) If hashed index is not correct program then check next index
  -- 4) Repest 3 until correct program found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := ben_hash_utility.get_hashed_index(p_id => p_ptip_id);
  --
    if g_cache_ptip_rec(l_index).ptip_id = p_ptip_id then
      --
      g_cache_last_ptip_rec := g_cache_ptip_rec(l_index);
      p_rec := g_cache_last_ptip_rec;
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
      g_cache_last_ptip_rec := g_cache_ptip_rec(l_index);
      p_rec := g_cache_last_ptip_rec;
      --
    end if;
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    set_object(p_ptip_id           => p_ptip_id,
               p_business_group_id => l_env.business_group_id,
               p_effective_date    => nvl(l_env.lf_evt_ocrd_dt,
                                      l_env.effective_date),
               p_rec               => p_rec);
    --
    g_cache_last_ptip_rec := p_rec;
    --p_rec := l_rec;
    --
end get_object;
--
procedure get_object(p_opt_id in  number,
                     p_rec    in out NOCOPY ben_opt_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object opt';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            ben_opt_f%rowtype;
  --
begin
  --
--  hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_opt_rec.opt_id = p_opt_id then
    --
    p_rec := g_cache_last_opt_rec;
    return;
    --
  end if;
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct pgm then return program
  -- 3) If hashed index is not correct program then check next index
  -- 4) Repest 3 until correct program found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := ben_hash_utility.get_hashed_index(p_id => p_opt_id);
  --
    if g_cache_opt_rec(l_index).opt_id = p_opt_id then
      --
      g_cache_last_opt_rec := g_cache_opt_rec(l_index);
      p_rec := g_cache_last_opt_rec;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_opt_rec(l_index).opt_id <> p_opt_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      g_cache_last_opt_rec := g_cache_opt_rec(l_index);
      p_rec := g_cache_last_opt_rec;
      --
    end if;
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    set_object(p_opt_id            => p_opt_id,
               p_business_group_id => l_env.business_group_id,
               p_effective_date    => nvl(l_env.lf_evt_ocrd_dt,
                                      l_env.effective_date),
               p_rec               => p_rec);
    --
    --115.10 g_cache_last_opt_rec := g_cache_opt_rec(l_index); should read as follows
    g_cache_last_opt_rec := p_rec;
    --p_rec := l_rec;
    --
end get_object;
--
procedure get_object(p_oiplip_id in  number,
                     p_rec       in out NOCOPY ben_oiplip_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object oiplip';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            ben_oiplip_f%rowtype;
  --
begin
  --
--  hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_oiplip_rec.oiplip_id = p_oiplip_id then
    --
    p_rec := g_cache_last_oiplip_rec;
    return;
    --
  end if;
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct pgm then return program
  -- 3) If hashed index is not correct program then check next index
  -- 4) Repest 3 until correct program found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := ben_hash_utility.get_hashed_index(p_id => p_oiplip_id);
  --
    if g_cache_oiplip_rec(l_index).oiplip_id = p_oiplip_id then
      --
      g_cache_last_oiplip_rec := g_cache_oiplip_rec(l_index);
      p_rec := g_cache_last_oiplip_rec;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_oiplip_rec(l_index).oiplip_id <> p_oiplip_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      g_cache_last_oiplip_rec := g_cache_oiplip_rec(l_index);
      p_rec := g_cache_last_oiplip_rec;
      --
    end if;
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    set_object(p_oiplip_id         => p_oiplip_id,
               p_business_group_id => l_env.business_group_id,
               p_effective_date    => nvl(l_env.lf_evt_ocrd_dt,
                                      l_env.effective_date),
               p_rec               => p_rec);
    --
    --115.10 g_cache_last_oiplip_rec := g_cache_oiplip_rec(l_index); should read as follows
    g_cache_last_oiplip_rec := p_rec;
    --p_rec := l_rec;
    --
end get_object;
--
procedure get_object_set_cobra
 (p_pgm_id                   in  number,
  p_only_pls_subj_cobra_flag in varchar2,
  p_rec                      in out NOCOPY g_cache_pl_rec_table) is
  --
  l_proc              varchar2(80) := g_package||'get_object_set_cobra';
  l_index             pls_integer;
  --l_not_hash_found    boolean;
  l_results_table     g_cache_pl_rec_table;
  l_rec               ben_cache.g_cache_lookup;
  l_num_recs          number;
  l_env               ben_env_object.g_global_env_rec_type;
  l_business_group_id number;
  l_lf_evt_ocrd_dt    date;
  --
  cursor c1 is -- changed the sql for performance bug 3662774
    select distinct pln.*
      from   ben_pl_f pln,
             ben_plip_f cpp,
             ben_pl_regn_f prg,
             ben_regn_f reg
      where  pln.pl_id = cpp.pl_id
      and    pln.business_group_id  = l_env.business_group_id
      and    nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date)
             between pln.effective_start_date
             and     pln.effective_end_date
      and    cpp.business_group_id  = pln.business_group_id
      and    nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date)
             between cpp.effective_start_date
             and     cpp.effective_end_date
      and    cpp.pgm_id = p_pgm_id
      and    prg.pl_id = pln.pl_id
      and    prg.business_group_id  = pln.business_group_id
      and    nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date)
             between prg.effective_start_date
             and     prg.effective_end_date
      and    reg.regn_id = prg.regn_id
      and    reg.business_group_id  = prg.business_group_id
      and    nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date)
             between reg.effective_start_date
             and     reg.effective_end_date
      and    reg.name = decode(p_only_pls_subj_cobra_flag,
                               'Y',
                               'COBRA',
                               reg.name)
      and    exists
             ( select 1
               from ben_elig_per_f epo
                    ,ben_per_in_ler pil
               where epo.pgm_id = p_pgm_id
      	       and   epo.pl_id = l_env.pl_id
      	       and   epo.business_group_id  = l_env.business_group_id
      	       and   nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date)
             		between epo.effective_start_date
             		and     epo.effective_end_date
      	       and    epo.elig_flag = 'Y'
      	       and    pil.per_in_ler_id(+)=epo.per_in_ler_id
               and    pil.business_group_id(+)=epo.business_group_id+0
               and    (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
                       or pil.per_in_ler_stat_cd is null                  -- outer join condition
                      )
              )
  ;



 /*   select pln.*
    from   ben_pl_f pln,
           ben_plip_f cpp,
           ben_pl_regn_f prg,
           ben_regn_f reg,
           ben_elig_per_f epo
         , ben_per_in_ler pil
    where  pln.pl_id = cpp.pl_id
    and    pln.business_group_id  = l_env.business_group_id
    and    nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date)
           between pln.effective_start_date
           and     pln.effective_end_date
    and    cpp.business_group_id  = pln.business_group_id
    and    nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date)
           between cpp.effective_start_date
           and     cpp.effective_end_date
    and    cpp.pgm_id = p_pgm_id
    and    prg.pl_id = pln.pl_id
    and    prg.business_group_id  = pln.business_group_id
    and    nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date)
           between prg.effective_start_date
           and     prg.effective_end_date
    and    reg.regn_id = prg.regn_id
    and    reg.business_group_id  = prg.business_group_id
    and    nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date)
           between reg.effective_start_date
           and     reg.effective_end_date
    and    epo.pgm_id = p_pgm_id
    and    epo.pl_id = l_env.pl_id
    and    epo.business_group_id  = l_env.business_group_id
    and    nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date)
           between epo.effective_start_date
           and     epo.effective_end_date
    and    epo.elig_flag = 'Y'
    and    reg.name = decode(p_only_pls_subj_cobra_flag,
                             'Y',
                             'COBRA',
                             reg.name)
    and    pil.per_in_ler_id(+)=epo.per_in_ler_id
    and    pil.business_group_id(+)=epo.business_group_id+0
    and    (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
            or pil.per_in_ler_stat_cd is null                  -- outer join condition
           )
  ;
  */
  --
  --l_c1 c1%rowtype;
  --
begin
  --
--  hr_utility.set_location('Entering '||l_proc,10);
  --
  -- Grab environment information
  --
  ben_env_object.get(p_rec => l_env);
  --
  -- This is a special case as we are attempting to get all the plans in
  -- program for a COBRA program . We need to only hash the PGM_ID as the
  -- plans will be stored in an consecutive indexed table.
  -- The PGM lookup table merely stores the start and stop locations of
  -- the detail table and also whether any details records actualy exist.
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct program then return detail records
  -- 3) If hashed index is not correct program then check next index
  -- 4) Repeat 3 until correct program found or empty cell found.
  --
  -- Get hashed index value
  --
  l_index := ben_hash_utility.get_hashed_index(p_id => p_pgm_id);
  --
    if g_cache_pgm_cobra_lookup(l_index).id = p_pgm_id then
      --
      l_rec := g_cache_pgm_cobra_lookup(l_index);
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_pgm_cobra_lookup(l_index).id <> p_pgm_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      l_rec := g_cache_pgm_cobra_lookup(l_index);
      --
    end if;
  --
  --
  -- Now fill the details table with the required consecutive rows as
  -- stated by the lookup table
  --
  if l_rec.v2value_1 = 'N' then
    --
    -- There are no records in the detail table so therefore
    -- return an empty table of records.
    --
    p_rec := l_results_table;
    --
  else
    --
    -- We have to loop through all the required records of the
    -- detail structure and return the records.
    --
    for l_count in l_rec.starttorele_num..l_rec.endtorele_num loop
      --
      -- Load records into l_results_table cache
      --
      p_rec(p_rec.count+1) := g_cache_pgm_cobra_rec(l_count);
      --
    end loop;
    --
    --
  end if;
  --
--  hr_utility.set_location('Leaving '||l_proc,10);
  --
exception
  --
  when no_data_found then
    --
    g_cache_pgm_cobra_lookup(l_index).id := p_pgm_id;
    g_cache_pgm_cobra_lookup(l_index).fk_id := l_business_group_id;
    g_cache_pgm_cobra_lookup(l_index).v2value_1 := 'N';
    --
    -- We need to force the cache of the cobra plans records
    --
    open c1;
      --
      loop
        --
        fetch c1 into p_rec(p_rec.count+1);
        exit when c1%notfound;
        --
        -- Set up the cobra lookup table
        --
        if g_cache_pgm_cobra_lookup(l_index).v2value_1 = 'N' then
          --
          g_cache_pgm_cobra_lookup(l_index).v2value_1 := 'Y';
          g_cache_pgm_cobra_lookup(l_index).starttorele_num :=
            g_cache_pgm_cobra_rec.count+1;
          --
        end if;
        --
        -- Read the cursor values into the cobra details table
        -- additionally copy them to the results table
        --
        g_cache_pgm_cobra_rec(g_cache_pgm_cobra_rec.count+1) := p_rec(p_rec.count);
        --
      end loop;
      --
    close c1;
    --
    if g_cache_pgm_cobra_lookup(l_index).starttorele_num is not null then
      --
      g_cache_pgm_cobra_lookup(l_index).endtorele_num :=
        g_cache_pgm_cobra_rec.count;
      --
    end if;
    --
    --
end get_object_set_cobra;
--
procedure clear_down_cache is
  --
  l_opt_rec    ben_opt_f%rowtype;
  l_oiplip_rec ben_oiplip_f%rowtype;
  l_pgm_rec    ben_pgm_f%rowtype;
  l_pl_rec     ben_pl_f%rowtype;
  l_plip_rec   ben_plip_f%rowtype;
  l_ptip_rec   ben_ptip_f%rowtype;
  l_oipl_rec   ben_oipl_f%rowtype;
  --
begin
  --
  g_cache_pgm_rec.delete;
  g_cache_pl_rec.delete;
  g_cache_oipl_rec.delete;
  g_cache_plip_rec.delete;
  g_cache_ptip_rec.delete;
  g_cache_opt_rec.delete;
  g_cache_oiplip_rec.delete;
  g_cache_last_pgm_rec := l_pgm_rec;
  g_cache_last_pl_rec := l_pl_rec;
  g_cache_last_oipl_rec := l_oipl_rec;
  g_cache_last_plip_rec := l_plip_rec;
  g_cache_last_ptip_rec := l_ptip_rec;
  g_cache_last_opt_rec := l_opt_rec;
  g_cache_last_oiplip_rec := l_oiplip_rec;
  g_cache_pgm_cobra_lookup.delete;
  g_cache_pgm_cobra_rec.delete;
  --
end clear_down_cache;
--
end ben_comp_object;

/
