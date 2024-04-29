--------------------------------------------------------
--  DDL for Package Body BEN_ORG_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ORG_OBJECT" as
/* $Header: benorgch.pkb 120.0.12010000.2 2008/08/05 14:48:55 ubhat ship $ */
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
  115.0      09-Aug-99  GPERRY     Created.
  115.1      16-Aug-99  GPERRY     Added nocopy compiler directive.
  115.2      06 May 00  RChase     Performance Modifications, replace exists,
                                   add additional NOCOPY compiler directives,
                                   remove additional record assignments.
  115.3      29 Dec 00  Tmathers   Fixed check_sql errors.
  -----------------------------------------------------------------------------
*/
--
g_package varchar2(30) := 'ben_org_object.';
g_hash_key number := ben_hash_utility.get_hash_key;
g_hash_jump number := ben_hash_utility.get_hash_jump;
--
-- Set object routines
--
procedure set_object(p_rec in out NOCOPY per_business_groups%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object';
  l_index          pls_integer;
  --l_not_hash_found boolean;
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
  l_index := ben_hash_utility.get_hashed_index(p_id => p_rec.business_group_id);
    -- 115.2 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_bus_rec(l_index).business_group_id = p_rec.business_group_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.2 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_bus_rec(l_index).business_group_id <> p_rec.business_group_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  --115.2 set cache entry at current index location
   g_cache_bus_rec(l_index):=p_rec;
--
end set_object;
--
procedure set_object(p_rec in out NOCOPY hr_all_organization_units%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object';
  l_index          pls_integer;
  --l_not_hash_found boolean;
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
  l_index := ben_hash_utility.get_hashed_index(p_id => p_rec.organization_id);
    -- 115.2 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_org_rec(l_index).organization_id = p_rec.organization_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.2 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_org_rec(l_index).organization_id <> p_rec.organization_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  --115.2 set cache entry at current index location
   g_cache_org_rec(l_index):=p_rec;
--
end set_object;
--
procedure set_object(p_rec in out NOCOPY pay_all_payrolls_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object';
  l_index          pls_integer;
  --l_not_hash_found boolean;
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
  l_index := ben_hash_utility.get_hashed_index(p_id => p_rec.payroll_id);
    -- 115.2 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_pay_rec(l_index).payroll_id = p_rec.payroll_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.2 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_pay_rec(l_index).payroll_id <> p_rec.payroll_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  --115.2 set cache entry at current index location
   g_cache_pay_rec(l_index):=p_rec;
--
end set_object;
--
procedure set_object(p_rec in out NOCOPY ben_benfts_grp%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object';
  l_index          pls_integer;
  --l_not_hash_found boolean;
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
  l_index := ben_hash_utility.get_hashed_index(p_id => p_rec.benfts_grp_id);
    -- 115.2 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_ben_rec(l_index).benfts_grp_id = p_rec.benfts_grp_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.2 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_ben_rec(l_index).benfts_grp_id <> p_rec.benfts_grp_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  --115.2 set cache entry at current index location
   g_cache_ben_rec(l_index):=p_rec;
--
end set_object;
--
-- Set object alternate route routines
--
procedure set_bus_object
  (p_business_group_id in number,
   p_effective_date    in date,
   p_rec               in out nocopy per_business_groups%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_bus_object';
  --
  cursor c1 is
    select bus.*
    from   per_business_groups bus
    where  bus.business_group_id = p_business_group_id
    and    p_effective_date
           between bus.date_from
           and     nvl(bus.date_to,p_effective_date);
  --115.2 remove additional declaration
  --l_rec per_business_groups%rowtype;
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
      --115.2 use NOCOPY parameter
      --l_rec.business_group_id := p_business_group_id;
      p_rec.business_group_id := p_business_group_id;
      --
    end if;
    --
  close c1;
  --
  set_object(p_rec => p_rec);
  --115.2 remove additional assignment
  --p_rec := l_rec;
  --
  --hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_bus_object;
--
procedure set_org_object
  (p_organization_id in number,
   p_effective_date  in date,
   p_rec             in out nocopy hr_all_organization_units%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_org_object';
  --
  cursor c1 is
    select org.*
    from   hr_all_organization_units org
    where  org.organization_id = p_organization_id
    and    p_effective_date
           between org.date_from
           and     nvl(org.date_to,p_effective_date);
  --115.2 remove additional declaration
  --l_rec hr_all_organization_units%rowtype;
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
      --115.2 use NOCOPY parameter
      --l_rec.organization_id := p_organization_id;
      p_rec.organization_id := p_organization_id;
      --
    end if;
    --
  close c1;
  --
  set_object(p_rec => p_rec);
  --115.2 remove additional assignment
  --p_rec := l_rec;
  --
  --hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_org_object;
--
procedure set_pay_object
  (p_payroll_id        in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_rec               in out nocopy pay_all_payrolls_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_pay_object';
  --
  cursor c1 is
    select pay.*
    from   pay_all_payrolls_f pay
    where  pay.payroll_id = p_payroll_id
    and    pay.business_group_id = p_business_group_id
    and    p_effective_date
           between pay.effective_start_date
           and     pay.effective_end_date;
  --115.2 remove additional declaration
  --l_rec pay_all_payrolls_f%rowtype;
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
      --115.2 use NOCOPY parameter
      --l_rec.payroll_id := p_payroll_id;
      p_rec.payroll_id := p_payroll_id;
      --
    end if;
    --
  close c1;
  --
  set_object(p_rec => p_rec);
  --115.2 remove additional assignment
  --p_rec := l_rec;
  --
  --hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_pay_object;
--
procedure set_ben_object
  (p_benfts_grp_id     in number,
   p_business_group_id in number,
   p_rec               in out nocopy ben_benfts_grp%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_ben_object';
  --
  cursor c1 is
    select ben.*
    from   ben_benfts_grp ben
    where  ben.benfts_grp_id = p_benfts_grp_id
    and    ben.business_group_id = p_business_group_id;
  --115.2 remove additional declaration
  --l_rec ben_benfts_grp%rowtype;
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
      --115.2 use NOCOPY parameter
      --l_rec.benfts_grp_id := p_benfts_grp_id;
      p_rec.benfts_grp_id := p_benfts_grp_id;
      --
    end if;
    --
  close c1;
  --
  set_object(p_rec => p_rec);
  --115.2 remove additional assignment
  --p_rec := l_rec;
  --
  --hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_ben_object;
--
-- Get object routines
--
procedure get_object(p_business_group_id in  number,
                     p_rec               in out nocopy per_business_groups%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            per_business_groups%rowtype;
  --
begin
  --
  --hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_bus_rec.business_group_id = p_business_group_id then
    --
    p_rec := g_cache_last_bus_rec;
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
  l_index := ben_hash_utility.get_hashed_index(p_id => p_business_group_id);
  --
    if g_cache_bus_rec(l_index).business_group_id = p_business_group_id then
      --
      g_cache_last_bus_rec := g_cache_bus_rec(l_index);
      p_rec := g_cache_last_bus_rec;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_bus_rec(l_index).business_group_id <> p_business_group_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      g_cache_last_bus_rec := g_cache_bus_rec(l_index);
      p_rec := g_cache_last_bus_rec;
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
    set_bus_object(p_business_group_id => p_business_group_id,
                   p_effective_date    => nvl(l_env.lf_evt_ocrd_dt,
                                              l_env.effective_date),
                   p_rec               => p_rec);
    --
    g_cache_last_bus_rec := p_rec;
    --p_rec := l_rec;
    --
end get_object;
--
procedure get_object(p_organization_id in  number,
                     p_rec             in out nocopy hr_all_organization_units%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            hr_all_organization_units%rowtype;
  --
begin
  --
  --hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_org_rec.organization_id = p_organization_id then
    --
    p_rec := g_cache_last_org_rec;
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
  l_index := ben_hash_utility.get_hashed_index(p_id => p_organization_id);
  --
    if g_cache_org_rec(l_index).organization_id = p_organization_id then
      --
      g_cache_last_org_rec := g_cache_org_rec(l_index);
      p_rec := g_cache_last_org_rec;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_org_rec(l_index).organization_id <> p_organization_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      g_cache_last_org_rec := g_cache_org_rec(l_index);
      p_rec := g_cache_last_org_rec;
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
    set_org_object(p_organization_id => p_organization_id,
                   p_effective_date  => nvl(l_env.lf_evt_ocrd_dt,
                                            l_env.effective_date),
                   p_rec             => p_rec);
    --
    g_cache_last_org_rec := p_rec;
    --p_rec := l_rec;
    --
end get_object;
--
procedure get_object(p_payroll_id in  number,
                     p_rec        in out nocopy pay_all_payrolls_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            pay_all_payrolls_f%rowtype;
  --
begin
  --
  --hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_pay_rec.payroll_id = p_payroll_id then
    --
    p_rec := g_cache_last_pay_rec;
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
  l_index := ben_hash_utility.get_hashed_index(p_id => p_payroll_id);
  --
    if g_cache_pay_rec(l_index).payroll_id = p_payroll_id then
      --
      g_cache_last_pay_rec := g_cache_pay_rec(l_index);
      p_rec := g_cache_last_pay_rec;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_pay_rec(l_index).payroll_id <> p_payroll_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      g_cache_last_pay_rec := g_cache_pay_rec(l_index);
      p_rec := g_cache_last_pay_rec;
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
    set_pay_object(p_payroll_id        => p_payroll_id,
                   p_business_group_id => l_env.business_group_id,
                   p_effective_date    => nvl(l_env.lf_evt_ocrd_dt,
                                              l_env.effective_date),
                   p_rec               => p_rec);
    --
    g_cache_last_pay_rec := p_rec;
    --p_rec := l_rec;
    --
end get_object;
--
procedure get_object(p_benfts_grp_id in  number,
                     p_rec           in out nocopy ben_benfts_grp%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            ben_benfts_grp%rowtype;
  --
begin
  --
  --hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_ben_rec.benfts_grp_id = p_benfts_grp_id then
    --
    p_rec := g_cache_last_ben_rec;
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
  l_index := ben_hash_utility.get_hashed_index(p_id => p_benfts_grp_id);
  --
    if g_cache_ben_rec(l_index).benfts_grp_id = p_benfts_grp_id then
      --
      g_cache_last_ben_rec := g_cache_ben_rec(l_index);
      p_rec := g_cache_last_ben_rec;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_ben_rec(l_index).benfts_grp_id <> p_benfts_grp_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      g_cache_last_ben_rec := g_cache_ben_rec(l_index);
      p_rec := g_cache_last_ben_rec;
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
    set_ben_object(p_benfts_grp_id     => p_benfts_grp_id,
                   p_business_group_id => l_env.business_group_id,
                   p_rec               => p_rec);
    --
    g_cache_last_ben_rec := p_rec;
    --p_rec := l_rec;
    --
end get_object;
--
procedure clear_down_cache is
  --
  l_last_bus_rec per_business_groups%rowtype;
  l_last_org_rec hr_all_organization_units%rowtype;
  l_last_pay_rec pay_all_payrolls_f%rowtype;
  l_last_ben_rec ben_benfts_grp%rowtype;
  --
begin
  --
  g_cache_bus_rec.delete;
  g_cache_last_bus_rec := l_last_bus_rec;
  g_cache_org_rec.delete;
  g_cache_last_org_rec := l_last_org_rec;
  g_cache_pay_rec.delete;
  g_cache_last_pay_rec := l_last_pay_rec;
  g_cache_ben_rec.delete;
  g_cache_last_ben_rec := l_last_ben_rec;
  --
end clear_down_cache;
--
end ben_org_object;

/
