--------------------------------------------------------
--  DDL for Package Body BEN_BATCH_DT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BATCH_DT_API" as
/* $Header: bendtapi.pkb 115.5 2003/09/18 16:01:58 mhoyes noship $ */
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
        15 May 99        mhoyes     115.0      Created
        20 Dec 00        Tmathers   115.1      fixed check_sql errors.
        22 May 01        mhoyes     115.2      Added batch_validate_bgp_id.
        18 Sep 03        mhoyes     115.4      3150329 - Update eligibility
                                               APIs.
*/
--------------------------------------------------------------------------------
--
g_package varchar2(30) := 'ben_batch_dt_api.';
g_hash_key number      := ben_hash_utility.get_hash_key;
g_hash_jump number     := ben_hash_utility.get_hash_jump;
--
g_batch_api pls_integer := 0;
--
procedure Get_DtIns_Start_and_End_Dates
  (p_effective_date in            date
  ,p_parcolumn_name in            varchar2
  ,p_min_esd        in            date
  ,p_max_eed        in            date
  --
  ,p_esd            in out nocopy date
  ,p_eed            in out nocopy date
  )
Is
  --
  l_proc        varchar2(72)    := g_package||'Get_DtIns_Start_and_End_Dates';
  --
Begin
  --
  -- If the max eed is null or less than the
  -- effective_date then error because a parental row does NOT exist.
  --
  If ( p_max_eed is null
    or
     (p_max_eed < p_effective_date)
     )
  then
    --
    -- The parental rows specified do not exist as of the effective date
    -- therefore a serious integrity problem has ocurred
    --
    hr_utility.set_message(801, 'HR_7423_DT_INVALID_ID');
    hr_utility.set_message_token('ARGUMENT', upper(p_parcolumn_name));
    hr_utility.raise_error;
    --
  Else
    --
    -- The LEAST function will then compare the working l_min_date with the
    -- returned miniumum effective start date (l_temp_date) and set the
    -- l_min_date to the maximum of these dates
    --
    p_eed := least(p_eed, p_max_eed);
    --
  End If;
  --
  p_esd := p_effective_date;
  --
End Get_DtIns_Start_and_End_Dates;
--
procedure set_personobject
  (p_rec in out NOCOPY gtyp_dtsum_row
  )
is
  --
  l_hash_value       pls_integer;
  --
begin
  --
  -- Get hashed index value
  --
  l_hash_value := mod(p_rec.id,g_hash_key);
  --
  if g_person_dtsum_odcache(l_hash_value).id = p_rec.id then
    --
    null;
    --
  else
    --
    -- Loop through the hash using the jump routine to check further
    -- indexes
    -- 115.10 if none exists at current index the NO_DATA_FOUND expection will fire
    --
    l_hash_value := l_hash_value+g_hash_jump;
    --
    while g_person_dtsum_odcache(l_hash_value).id <> p_rec.id loop
      --
      l_hash_value := l_hash_value+g_hash_jump;
    end loop;
    --
  end if;
  --
exception when NO_DATA_FOUND then
  -- set cache entry at current index location
  g_person_dtsum_odcache(l_hash_value):=p_rec;
  --
end set_personobject;
--
procedure get_personobject
  (p_person_id in     number
  ,p_rec    in out NOCOPY gtyp_dtsum_row
  )
is
  --
  l_rec            gtyp_dtsum_row;
  l_odcache_row    gtyp_dtsum_row;
  --
  l_hash_value          pls_integer;
  l_id             number;
  l_min_esd        date;
  l_max_eed        date;
  --
  cursor c1
    (c_id in number
    )
  is
    select person_id id,
           min(effective_start_date) min_esd,
           max(effective_end_date) max_eed
    from   per_all_people_f
    where  person_id = c_id
    group by person_id;
  --
begin
  --
  -- Check for a match in the current row cache
  --
  if g_lastperson_dtsum_row.id = p_person_id then
    --
    p_rec := g_lastperson_dtsum_row;
    return;
    --
  end if;
  --
  -- Get hashed index value
  --
  l_hash_value := mod(p_person_id,g_hash_key);
  --
  l_odcache_row := g_person_dtsum_odcache(l_hash_value);
  --
  if l_odcache_row.id = p_person_id then
    --
    -- Set the current row cache
    --
    g_lastperson_dtsum_row := l_odcache_row;
    p_rec := l_odcache_row;
    --
  else
    --
    -- We need to loop through all the hashed indexes
    -- if none exists at current index the NO_DATA_FOUND expection will fire
    --
    l_hash_value := l_hash_value+g_hash_jump;
    while g_person_dtsum_odcache(l_hash_value).id <> p_person_id loop
      --
      l_hash_value := l_hash_value+g_hash_jump;
      --
    end loop;
    --
    l_odcache_row := g_person_dtsum_odcache(l_hash_value);
    --
    g_lastperson_dtsum_row := l_odcache_row;
    p_rec := l_odcache_row;
    --
  end if;
  --
exception
  --
  when no_data_found then
    --
    open c1
      (c_id => p_person_id
      );
    fetch c1 into l_rec;
    if c1%notfound then
        --
        close c1;
        fnd_message.set_name('BEN','BEN_92204_OBJECT_NOT_FOUND');
        fnd_message.set_token('PROC','ben_batch_dt_api.get_personobject');
        fnd_message.set_token('person',p_person_id);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
    -- Add details to the cache
    --
    set_personobject
      (p_rec => l_rec
      );
    --
    g_lastperson_dtsum_row := l_rec;
    p_rec := l_rec;
    --
end get_personobject;
--
procedure set_lerobject
  (p_rec in out NOCOPY gtyp_dtsum_row
  )
is
  --
  l_hash_value       pls_integer;
  --
begin
  --
  -- Get hashed index value
  --
  l_hash_value := mod(p_rec.id,g_hash_key);
  --
  if g_ler_dtsum_odcache(l_hash_value).id = p_rec.id then
    --
    null;
    --
  else
    --
    -- Loop through the hash using the jump routine to check further
    -- indexes
    -- 115.10 if none exists at current index the NO_DATA_FOUND expection will fire
    --
    l_hash_value := l_hash_value+g_hash_jump;
    --
    while g_ler_dtsum_odcache(l_hash_value).id <> p_rec.id loop
      --
      l_hash_value := l_hash_value+g_hash_jump;
    end loop;
    --
  end if;
  --
exception when NO_DATA_FOUND then
  -- set cache entry at current index location
  g_ler_dtsum_odcache(l_hash_value):=p_rec;
  --
end set_lerobject;
--
procedure get_lerobject
  (p_ler_id in     number
  ,p_rec    in out NOCOPY gtyp_dtsum_row
  )
is
  --
  l_rec            gtyp_dtsum_row;
  l_odcache_row    gtyp_dtsum_row;
  --
  l_hash_value          pls_integer;
  l_id             number;
  l_min_esd        date;
  l_max_eed        date;
  --
  cursor c1
    (c_id in number
    )
  is
    select ler_id id,
           min(effective_start_date) min_esd,
           max(effective_end_date) max_eed
    from   ben_ler_f
    where  ler_id = c_id
    group by ler_id;
  --
begin
  --
  -- Check for a match in the current row cache
  --
  if g_lastler_dtsum_row.id = p_ler_id then
    --
    p_rec := g_lastler_dtsum_row;
    return;
    --
  end if;
  --
  -- Get hashed index value
  --
  l_hash_value := mod(p_ler_id,g_hash_key);
  --
  l_odcache_row := g_ler_dtsum_odcache(l_hash_value);
  --
  if l_odcache_row.id = p_ler_id then
    --
    -- Set the current row cache
    --
    g_lastler_dtsum_row := l_odcache_row;
    p_rec := l_odcache_row;
    --
  else
    --
    -- We need to loop through all the hashed indexes
    -- if none exists at current index the NO_DATA_FOUND expection will fire
    --
    l_hash_value := l_hash_value+g_hash_jump;
    while g_ler_dtsum_odcache(l_hash_value).id <> p_ler_id loop
      --
      l_hash_value := l_hash_value+g_hash_jump;
      --
    end loop;
    --
    l_odcache_row := g_ler_dtsum_odcache(l_hash_value);
    --
    g_lastler_dtsum_row := l_odcache_row;
    p_rec := l_odcache_row;
    --
  end if;
  --
exception
  --
  when no_data_found then
    --
    open c1
      (c_id => p_ler_id
      );
    fetch c1 into l_rec;
    if c1%notfound then
        --
        close c1;
        fnd_message.set_name('BEN','BEN_92204_OBJECT_NOT_FOUND');
        fnd_message.set_token('PROC','ben_batch_dt_api.get_lerobject');
        fnd_message.set_token('ler',p_ler_id);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
    -- Add details to the cache
    --
    set_lerobject
      (p_rec => l_rec
      );
    --
    g_lastler_dtsum_row := l_rec;
    p_rec := l_rec;
    --
end get_lerobject;
--
procedure set_pgmobject
  (p_rec in out NOCOPY gtyp_dtsum_row
  )
is
  --
  l_hash_value       pls_integer;
  --
begin
  --
  -- Get hashed index value
  --
  l_hash_value := mod(p_rec.id,g_hash_key);
  --
  if g_pgm_dtsum_odcache(l_hash_value).id = p_rec.id then
    --
    null;
    --
  else
    --
    -- Loop through the hash using the jump routine to check further
    -- indexes
    -- 115.10 if none exists at current index the NO_DATA_FOUND expection will fire
    --
    l_hash_value := l_hash_value+g_hash_jump;
    --
    while g_pgm_dtsum_odcache(l_hash_value).id <> p_rec.id loop
      --
      l_hash_value := l_hash_value+g_hash_jump;
    end loop;
    --
  end if;
  --
exception when NO_DATA_FOUND then
  -- set cache entry at current index location
  g_pgm_dtsum_odcache(l_hash_value):=p_rec;
  --
end set_pgmobject;
--
procedure get_pgmobject
  (p_pgm_id in     number
  ,p_rec    in out NOCOPY gtyp_dtsum_row
  )
is
  --
  l_rec            gtyp_dtsum_row;
  l_odcache_row    gtyp_dtsum_row;
  --
  l_hash_value          pls_integer;
  l_id             number;
  l_min_esd        date;
  l_max_eed        date;
  --
  cursor c1
    (c_id in number
    )
  is
    select pgm_id id,
           min(effective_start_date) min_esd,
           max(effective_end_date) max_eed
    from   ben_pgm_f
    where  pgm_id = c_id
    group by pgm_id;
  --
begin
  --
  -- Check for a match in the current row cache
  --
  if g_lastpgm_dtsum_row.id = p_pgm_id then
    --
    p_rec := g_lastpgm_dtsum_row;
    return;
    --
  end if;
  --
  -- Get hashed index value
  --
  l_hash_value := mod(p_pgm_id,g_hash_key);
  --
  l_odcache_row := g_pgm_dtsum_odcache(l_hash_value);
  --
  if l_odcache_row.id = p_pgm_id then
    --
    -- Set the current row cache
    --
    g_lastpgm_dtsum_row := l_odcache_row;
    p_rec := l_odcache_row;
    --
  else
    --
    -- We need to loop through all the hashed indexes
    -- if none exists at current index the NO_DATA_FOUND expection will fire
    --
    l_hash_value := l_hash_value+g_hash_jump;
    while g_pgm_dtsum_odcache(l_hash_value).id <> p_pgm_id loop
      --
      l_hash_value := l_hash_value+g_hash_jump;
      --
    end loop;
    --
    l_odcache_row := g_pgm_dtsum_odcache(l_hash_value);
    --
    g_lastpgm_dtsum_row := l_odcache_row;
    p_rec := l_odcache_row;
    --
  end if;
  --
exception
  --
  when no_data_found then
    --
    open c1
      (c_id => p_pgm_id
      );
    fetch c1 into l_rec;
    if c1%notfound then
        --
        close c1;
        fnd_message.set_name('BEN','BEN_92204_OBJECT_NOT_FOUND');
        fnd_message.set_token('PROC','ben_batch_dt_api.get_pgmobject');
        fnd_message.set_token('PGM',p_pgm_id);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
    -- Add details to the cache
    --
    set_pgmobject
      (p_rec => l_rec
      );
    --
    g_lastpgm_dtsum_row := l_rec;
    p_rec := l_rec;
    --
end get_pgmobject;
--
procedure set_ptipobject
  (p_rec in out NOCOPY gtyp_dtsum_row
  )
is
  --
  l_hash_value       pls_integer;
  --
begin
  --
  -- Get hashed index value
  --
  l_hash_value := mod(p_rec.id,g_hash_key);
  --
  if g_ptip_dtsum_odcache(l_hash_value).id = p_rec.id then
    --
    null;
    --
  else
    --
    -- Loop through the hash using the jump routine to check further
    -- indexes
    -- 115.10 if none exists at current index the NO_DATA_FOUND expection will fire
    --
    l_hash_value := l_hash_value+g_hash_jump;
    --
    while g_ptip_dtsum_odcache(l_hash_value).id <> p_rec.id loop
      --
      l_hash_value := l_hash_value+g_hash_jump;
    end loop;
    --
  end if;
  --
exception when NO_DATA_FOUND then
  -- set cache entry at current index location
  g_ptip_dtsum_odcache(l_hash_value):=p_rec;
  --
end set_ptipobject;
--
procedure get_ptipobject
  (p_ptip_id in     number
  ,p_rec    in out NOCOPY gtyp_dtsum_row
  )
is
  --
  l_rec            gtyp_dtsum_row;
  l_odcache_row    gtyp_dtsum_row;
  --
  l_hash_value          pls_integer;
  l_id             number;
  l_min_esd        date;
  l_max_eed        date;
  --
  cursor c1
    (c_id in number
    )
  is
    select ptip_id id,
           min(effective_start_date) min_esd,
           max(effective_end_date) max_eed
    from   ben_ptip_f
    where  ptip_id = c_id
    group by ptip_id;
  --
begin
  --
  -- Check for a match in the current row cache
  --
  if g_lastptip_dtsum_row.id = p_ptip_id then
    --
    p_rec := g_lastptip_dtsum_row;
    return;
    --
  end if;
  --
  -- Get hashed index value
  --
  l_hash_value := mod(p_ptip_id,g_hash_key);
  --
  l_odcache_row := g_ptip_dtsum_odcache(l_hash_value);
  --
  if l_odcache_row.id = p_ptip_id then
    --
    -- Set the current row cache
    --
    g_lastptip_dtsum_row := l_odcache_row;
    p_rec := l_odcache_row;
    --
  else
    --
    -- We need to loop through all the hashed indexes
    -- if none exists at current index the NO_DATA_FOUND expection will fire
    --
    l_hash_value := l_hash_value+g_hash_jump;
    while g_ptip_dtsum_odcache(l_hash_value).id <> p_ptip_id loop
      --
      l_hash_value := l_hash_value+g_hash_jump;
      --
    end loop;
    --
    l_odcache_row := g_ptip_dtsum_odcache(l_hash_value);
    --
    g_lastptip_dtsum_row := l_odcache_row;
    p_rec := l_odcache_row;
    --
  end if;
  --
exception
  --
  when no_data_found then
    --
    open c1
      (c_id => p_ptip_id
      );
    fetch c1 into l_rec;
    if c1%notfound then
        --
        close c1;
        fnd_message.set_name('BEN','BEN_92204_OBJECT_NOT_FOUND');
        fnd_message.set_token('PROC','ben_batch_dt_api.get_ptipobject');
        fnd_message.set_token('ptip',p_ptip_id);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
    -- Add details to the cache
    --
    set_ptipobject
      (p_rec => l_rec
      );
    --
    g_lastptip_dtsum_row := l_rec;
    p_rec := l_rec;
    --
end get_ptipobject;
--
procedure set_plipobject
  (p_rec in out NOCOPY gtyp_dtsum_row
  )
is
  --
  l_hash_value       pls_integer;
  --
begin
  --
  -- Get hashed index value
  --
  l_hash_value := mod(p_rec.id,g_hash_key);
  --
  if g_plip_dtsum_odcache(l_hash_value).id = p_rec.id then
    --
    null;
    --
  else
    --
    -- Loop through the hash using the jump routine to check further
    -- indexes
    -- 115.10 if none exists at current index the NO_DATA_FOUND expection will fire
    --
    l_hash_value := l_hash_value+g_hash_jump;
    --
    while g_plip_dtsum_odcache(l_hash_value).id <> p_rec.id loop
      --
      l_hash_value := l_hash_value+g_hash_jump;
    end loop;
    --
  end if;
  --
exception when NO_DATA_FOUND then
  -- set cache entry at current index location
  g_plip_dtsum_odcache(l_hash_value):=p_rec;
  --
end set_plipobject;
--
procedure get_plipobject
  (p_plip_id in     number
  ,p_rec    in out NOCOPY gtyp_dtsum_row
  )
is
  --
  l_rec            gtyp_dtsum_row;
  l_odcache_row    gtyp_dtsum_row;
  --
  l_hash_value          pls_integer;
  l_id             number;
  l_min_esd        date;
  l_max_eed        date;
  --
  cursor c1
    (c_id in number
    )
  is
    select plip_id id,
           min(effective_start_date) min_esd,
           max(effective_end_date) max_eed
    from   ben_plip_f
    where  plip_id = c_id
    group by plip_id;
  --
begin
  --
  -- Check for a match in the current row cache
  --
  if g_lastplip_dtsum_row.id = p_plip_id then
    --
    p_rec := g_lastplip_dtsum_row;
    return;
    --
  end if;
  --
  -- Get hashed index value
  --
  l_hash_value := mod(p_plip_id,g_hash_key);
  --
  l_odcache_row := g_plip_dtsum_odcache(l_hash_value);
  --
  if l_odcache_row.id = p_plip_id then
    --
    -- Set the current row cache
    --
    g_lastplip_dtsum_row := l_odcache_row;
    p_rec := l_odcache_row;
    --
  else
    --
    -- We need to loop through all the hashed indexes
    -- if none exists at current index the NO_DATA_FOUND expection will fire
    --
    l_hash_value := l_hash_value+g_hash_jump;
    while g_plip_dtsum_odcache(l_hash_value).id <> p_plip_id loop
      --
      l_hash_value := l_hash_value+g_hash_jump;
      --
    end loop;
    --
    l_odcache_row := g_plip_dtsum_odcache(l_hash_value);
    --
    g_lastplip_dtsum_row := l_odcache_row;
    p_rec := l_odcache_row;
    --
  end if;
  --
exception
  --
  when no_data_found then
    --
    open c1
      (c_id => p_plip_id
      );
    fetch c1 into l_rec;
    if c1%notfound then
        --
        close c1;
        fnd_message.set_name('BEN','BEN_92204_OBJECT_NOT_FOUND');
        fnd_message.set_token('PROC','ben_batch_dt_api.get_plipobject');
        fnd_message.set_token('plip',p_plip_id);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
    -- Add details to the cache
    --
    set_plipobject
      (p_rec => l_rec
      );
    --
    g_lastplip_dtsum_row := l_rec;
    p_rec := l_rec;
    --
end get_plipobject;
--
procedure set_plobject
  (p_rec in out NOCOPY gtyp_dtsum_row
  )
is
  --
  l_hash_value       pls_integer;
  --
begin
  --
  -- Get hashed index value
  --
  l_hash_value := mod(p_rec.id,g_hash_key);
  --
  if g_pl_dtsum_odcache(l_hash_value).id = p_rec.id then
    --
    null;
    --
  else
    --
    -- Loop through the hash using the jump routine to check further
    -- indexes
    -- 115.10 if none exists at current index the NO_DATA_FOUND expection will fire
    --
    l_hash_value := l_hash_value+g_hash_jump;
    --
    while g_pl_dtsum_odcache(l_hash_value).id <> p_rec.id loop
      --
      l_hash_value := l_hash_value+g_hash_jump;
    end loop;
    --
  end if;
  --
exception when NO_DATA_FOUND then
  -- set cache entry at current index location
  g_pl_dtsum_odcache(l_hash_value):=p_rec;
  --
end set_plobject;
--
procedure get_plobject
  (p_pl_id in     number
  ,p_rec    in out NOCOPY gtyp_dtsum_row
  )
is
  --
  l_rec            gtyp_dtsum_row;
  l_odcache_row    gtyp_dtsum_row;
  --
  l_hash_value          pls_integer;
  l_id             number;
  l_min_esd        date;
  l_max_eed        date;
  --
  cursor c1
    (c_id in number
    )
  is
    select pl_id id,
           min(effective_start_date) min_esd,
           max(effective_end_date) max_eed
    from   ben_pl_f
    where  pl_id = c_id
    group by pl_id;
  --
begin
  --
  -- Check for a match in the current row cache
  --
  if g_lastpl_dtsum_row.id = p_pl_id then
    --
    p_rec := g_lastpl_dtsum_row;
    return;
    --
  end if;
  --
  -- Get hashed index value
  --
  l_hash_value := mod(p_pl_id,g_hash_key);
  --
  l_odcache_row := g_pl_dtsum_odcache(l_hash_value);
  --
  if l_odcache_row.id = p_pl_id then
    --
    -- Set the current row cache
    --
    g_lastpl_dtsum_row := l_odcache_row;
    p_rec := l_odcache_row;
    --
  else
    --
    -- We need to loop through all the hashed indexes
    -- if none exists at current index the NO_DATA_FOUND expection will fire
    --
    l_hash_value := l_hash_value+g_hash_jump;
    while g_pl_dtsum_odcache(l_hash_value).id <> p_pl_id loop
      --
      l_hash_value := l_hash_value+g_hash_jump;
      --
    end loop;
    --
    l_odcache_row := g_pl_dtsum_odcache(l_hash_value);
    --
    g_lastpl_dtsum_row := l_odcache_row;
    p_rec := l_odcache_row;
    --
  end if;
  --
exception
  --
  when no_data_found then
    --
    open c1
      (c_id => p_pl_id
      );
    fetch c1 into l_rec;
    if c1%notfound then
        --
        close c1;
        fnd_message.set_name('BEN','BEN_92204_OBJECT_NOT_FOUND');
        fnd_message.set_token('PROC','ben_batch_dt_api.get_plobject');
        fnd_message.set_token('pl',p_pl_id);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
    -- Add details to the cache
    --
    set_plobject
      (p_rec => l_rec
      );
    --
    g_lastpl_dtsum_row := l_rec;
    p_rec := l_rec;
    --
end get_plobject;
--
procedure set_elig_perobject
  (p_rec in out NOCOPY gtyp_dtsum_row
  )
is
  --
  l_hash_value       pls_integer;
  --
begin
  --
  -- Get hashed index value
  --
  l_hash_value := mod(p_rec.id,g_hash_key);
  --
  if g_elig_per_dtsum_odcache(l_hash_value).id = p_rec.id then
    --
    null;
    --
  else
    --
    -- Loop through the hash using the jump routine to check further
    -- indexes
    -- 115.10 if none exists at current index the NO_DATA_FOUND expection will fire
    --
    l_hash_value := l_hash_value+g_hash_jump;
    --
    while g_elig_per_dtsum_odcache(l_hash_value).id <> p_rec.id loop
      --
      l_hash_value := l_hash_value+g_hash_jump;
    end loop;
    --
  end if;
  --
exception when NO_DATA_FOUND then
  -- set cache entry at current index location
  g_elig_per_dtsum_odcache(l_hash_value):=p_rec;
  --
end set_elig_perobject;
--
procedure get_elig_perobject
  (p_elig_per_id in     number
  ,p_rec    in out NOCOPY gtyp_dtsum_row
  )
is
  --
  l_rec            gtyp_dtsum_row;
  l_odcache_row    gtyp_dtsum_row;
  --
  l_hash_value          pls_integer;
  l_id             number;
  l_min_esd        date;
  l_max_eed        date;
  --
  cursor c1
    (c_id in number
    )
  is
    select elig_per_id id,
           min(effective_start_date) min_esd,
           max(effective_end_date) max_eed
    from   ben_elig_per_f
    where  elig_per_id = c_id
    group by elig_per_id;
  --
begin
  --
  -- Check for a match in the current row cache
  --
  if g_lastelig_per_dtsum_row.id = p_elig_per_id then
    --
    p_rec := g_lastelig_per_dtsum_row;
    return;
    --
  end if;
  --
  -- Get hashed index value
  --
  l_hash_value := mod(p_elig_per_id,g_hash_key);
  --
  l_odcache_row := g_elig_per_dtsum_odcache(l_hash_value);
  --
  if l_odcache_row.id = p_elig_per_id then
    --
    -- Set the current row cache
    --
    g_lastelig_per_dtsum_row := l_odcache_row;
    p_rec := l_odcache_row;
    --
  else
    --
    -- We need to loop through all the hashed indexes
    -- if none exists at current index the NO_DATA_FOUND expection will fire
    --
    l_hash_value := l_hash_value+g_hash_jump;
    while g_elig_per_dtsum_odcache(l_hash_value).id <> p_elig_per_id loop
      --
      l_hash_value := l_hash_value+g_hash_jump;
      --
    end loop;
    --
    l_odcache_row := g_elig_per_dtsum_odcache(l_hash_value);
    --
    g_lastelig_per_dtsum_row := l_odcache_row;
    p_rec := l_odcache_row;
    --
  end if;
  --
exception
  --
  when no_data_found then
    --
    open c1
      (c_id => p_elig_per_id
      );
    fetch c1 into l_rec;
    if c1%notfound then
        --
        close c1;
        fnd_message.set_name('BEN','BEN_92204_OBJECT_NOT_FOUND');
        fnd_message.set_token('PROC','ben_batch_dt_api.get_elig_perobject');
        fnd_message.set_token('elig_per',p_elig_per_id);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
    -- Add details to the cache
    --
    set_elig_perobject
      (p_rec => l_rec
      );
    --
    g_lastelig_per_dtsum_row := l_rec;
    p_rec := l_rec;
    --
end get_elig_perobject;
--
procedure clear_down_cache is
  --
  l_person_rec   gtyp_dtsum_row;
  l_ler_rec      gtyp_dtsum_row;
  l_pgm_rec      gtyp_dtsum_row;
  l_ptip_rec     gtyp_dtsum_row;
  l_plip_rec     gtyp_dtsum_row;
  l_pl_rec       gtyp_dtsum_row;
  l_elig_per_rec gtyp_dtsum_row;
  --
begin
  --
  g_person_dtsum_odcache.delete;
  g_lastperson_dtsum_row   := l_person_rec;
  --
  g_ler_dtsum_odcache.delete;
  g_lastler_dtsum_row      := l_ler_rec;
  --
  g_pgm_dtsum_odcache.delete;
  g_lastpgm_dtsum_row      := l_pgm_rec;
  --
  g_ptip_dtsum_odcache.delete;
  g_lastptip_dtsum_row     := l_ptip_rec;
  --
  g_plip_dtsum_odcache.delete;
  g_lastplip_dtsum_row     := l_plip_rec;
  --
  g_pl_dtsum_odcache.delete;
  g_lastpl_dtsum_row       := l_pl_rec;
  --
  g_elig_per_dtsum_odcache.delete;
  g_lastelig_per_dtsum_row := l_elig_per_rec;
  --
  g_batch_api              := 1;
  --
end clear_down_cache;
--
procedure batch_validate_bgp_id
  (p_business_group_id in number
  )
is
  --

  --
begin
  --
  if g_batch_api = 0 then
    --
    hr_api.validate_bus_grp_id
      (p_business_group_id
      );
    --
  end if;
  --
end batch_validate_bgp_id;
--
procedure validate_dt_mode_insert
  (p_effective_date       in     date
  ,p_person_id            in     number default null
  ,p_ler_id               in     number default null
  ,p_pgm_id               in     number default null
  ,p_ptip_id              in     number default null
  ,p_plip_id              in     number default null
  ,p_pl_id                in     number default null
  --
  ,p_effective_start_date in out nocopy date
  ,p_effective_end_date   in out nocopy date
  )
is
  --
  l_minmax_rec           ben_batch_dt_api.gtyp_dtsum_row;
  --
  l_effective_start_date date;
  l_effective_end_date   date;
  --
begin
  --
  l_effective_start_date := p_effective_date;
  l_effective_end_date   := hr_api.g_eot;
  --
  -- Person
  --
  ben_batch_dt_api.get_personobject
    (p_person_id => p_person_id
    ,p_rec       => l_minmax_rec
    );
  --
  ben_batch_dt_api.Get_DtIns_Start_and_End_Dates
    (p_effective_date => p_effective_date
    ,p_parcolumn_name => 'person_id'
    ,p_min_esd        => l_minmax_rec.min_esd
    ,p_max_eed        => l_minmax_rec.max_eed
    --
    ,p_esd            => l_effective_start_date
    ,p_eed            => l_effective_end_date
    );
  --
  if p_ler_id is not null then
    --
    ben_batch_dt_api.get_lerobject
      (p_ler_id => p_ler_id
      ,p_rec    => l_minmax_rec
      );
    --
    ben_batch_dt_api.Get_DtIns_Start_and_End_Dates
      (p_effective_date => p_effective_date
      ,p_parcolumn_name => 'ler_id'
      ,p_min_esd        => l_minmax_rec.min_esd
      ,p_max_eed        => l_minmax_rec.max_eed
      --
      ,p_esd            => l_effective_start_date
      ,p_eed            => l_effective_end_date
      );
    --
  end if;
  --
  -- Pgm
  --
  if p_pgm_id is not null then
    --
    ben_batch_dt_api.get_pgmobject
      (p_pgm_id => p_pgm_id
      ,p_rec    => l_minmax_rec
      );
    --
    ben_batch_dt_api.Get_DtIns_Start_and_End_Dates
      (p_effective_date => p_effective_date
      ,p_parcolumn_name => 'pgm_id'
      ,p_min_esd        => l_minmax_rec.min_esd
      ,p_max_eed        => l_minmax_rec.max_eed
      --
      ,p_esd            => l_effective_start_date
      ,p_eed            => l_effective_end_date
      );
    --
  end if;
  --
  -- Ptip
  --
  if p_ptip_id is not null then
    --
    ben_batch_dt_api.get_ptipobject
      (p_ptip_id => p_ptip_id
      ,p_rec     => l_minmax_rec
      );
    --
    ben_batch_dt_api.Get_DtIns_Start_and_End_Dates
      (p_effective_date => p_effective_date
      ,p_parcolumn_name => 'ptip_id'
      ,p_min_esd        => l_minmax_rec.min_esd
      ,p_max_eed        => l_minmax_rec.max_eed
      --
      ,p_esd            => l_effective_start_date
      ,p_eed            => l_effective_end_date
      );
    --
  end if;
  --
  -- Plip
  --
  if p_plip_id is not null then
    --
    ben_batch_dt_api.get_plipobject
      (p_plip_id => p_plip_id
      ,p_rec     => l_minmax_rec
      );
    --
    ben_batch_dt_api.Get_DtIns_Start_and_End_Dates
      (p_effective_date => p_effective_date
      ,p_parcolumn_name => 'plip_id'
      ,p_min_esd        => l_minmax_rec.min_esd
      ,p_max_eed        => l_minmax_rec.max_eed
      --
      ,p_esd            => l_effective_start_date
      ,p_eed            => l_effective_end_date
      );
    --
  end if;
  --
  -- Plan
  --
  if p_pl_id is not null then
    --
    ben_batch_dt_api.get_plobject
      (p_pl_id => p_pl_id
      ,p_rec   => l_minmax_rec
      );
    --
    ben_batch_dt_api.Get_DtIns_Start_and_End_Dates
      (p_effective_date => p_effective_date
      ,p_parcolumn_name => 'pl_id'
      ,p_min_esd        => l_minmax_rec.min_esd
      ,p_max_eed        => l_minmax_rec.max_eed
      --
      ,p_esd            => l_effective_start_date
      ,p_eed            => l_effective_end_date
      );
    --
  end if;
  --
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date   := l_effective_end_date;
  --
end validate_dt_mode_insert;
--
PROCEDURE return_effective_dates
  (p_base_table_name      IN      varchar2
  ,p_effective_date       IN      DATE
  ,p_base_key_value       IN      NUMBER
  --
  ,p_effective_start_date in out nocopy date
  ,p_effective_end_date   in out nocopy date
  )
IS
  --
  l_proc        VARCHAR2(72) := g_package||'return_effective_dates';
  --
  cursor c_effdates
    (c_eff_date date
    ,c_pep_id   number
    )
  is
    select pep.effective_start_date,
           pep.effective_end_date
    from ben_elig_per_f pep
    where pep.elig_per_id = c_pep_id
    and   c_eff_date
      between pep.effective_start_date and pep.effective_end_date;
  --
  cursor c_epoeffdates
    (c_eff_date date
    ,c_epo_id   number
    )
  is
    select epo.effective_start_date,
           epo.effective_end_date
    from ben_elig_per_opt_f epo
    where epo.elig_per_opt_id = c_epo_id
    and   c_eff_date
      between epo.effective_start_date and epo.effective_end_date;
  --
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  p_effective_start_date := null;
  p_effective_end_date   := null;
  --
  if p_base_table_name = 'BEN_ELIG_PER_F'
  then
    --
    open c_effdates
      (c_eff_date => p_effective_date
      ,c_pep_id   => p_base_key_value
      );
    fetch c_effdates into p_effective_start_date, p_effective_end_date;
    close c_effdates;
    --
  elsif p_base_table_name = 'BEN_ELIG_PER_OPT_F'
  then
    --
    open c_epoeffdates
      (c_eff_date => p_effective_date
      ,c_epo_id   => p_base_key_value
      );
    fetch c_epoeffdates into p_effective_start_date, p_effective_end_date;
    close c_epoeffdates;
    --
  end if;
  hr_utility.set_location('Leaving :'||l_proc, 45);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- As no rows were returned we must error
    hr_utility.set_message(801, 'HR_7180_DT_NO_ROW_EXIST');
    hr_utility.set_message_token('TABLE_NAME', p_base_table_name);
    hr_utility.set_message_token
      ('SESSION_DATE'
      ,fnd_date.date_to_chardate(p_effective_date)
      );
    hr_utility.raise_error;
  WHEN TOO_MANY_ROWS THEN
    hr_utility.set_message(801, 'HR_7181_DT_OVERLAP_ROWS');
    hr_utility.set_message_token('TABLE_NAME', p_base_table_name);
    hr_utility.set_message_token
      ('SESSION_DATE'
      ,fnd_date.date_to_chardate(p_effective_date)
      );
    hr_utility.set_message_token('PRIMARY_VALUE', to_char(p_base_key_value));
    hr_utility.raise_error;
  WHEN OTHERS THEN
    RAISE;
--
END return_effective_dates;
--
-- ----------------------------------------------------------------------------
-- |------------------------< Return_Max_End_Date >---------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION return_max_end_date
  (p_base_table_name IN  varchar2
  ,p_base_key_value  IN  NUMBER
  )
RETURN DATE
IS
  --
  l_proc     VARCHAR2(72) := g_package||'return_max_end_date';
  l_max_date DATE;
  --
  cursor c_maxedate
    (c_id   number
    )
  is
    select max(pep.effective_end_date)
    from ben_elig_per_f pep
    where pep.elig_per_id = c_id;
  --
  cursor c_epomaxedate
    (c_id   number
    )
  is
    select max(epo.effective_end_date)
    from ben_elig_per_opt_f epo
    where epo.elig_per_opt_id = c_id;
  --
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_base_table_name = 'BEN_ELIG_PER_F'
  then
    --
    open c_maxedate
      (c_id   => p_base_key_value
      );
    fetch c_maxedate into l_max_date;
    close c_maxedate;
    --
  elsif p_base_table_name = 'BEN_ELIG_PER_OPT_F'
  then
    --
    open c_epomaxedate
      (c_id   => p_base_key_value
      );
    fetch c_epomaxedate into l_max_date;
    close c_epomaxedate;
    --
  end if;
  hr_utility.set_location('Leaving :'||l_proc, 10);
  RETURN(l_max_date);
  --
END return_max_end_date;
-- ----------------------------------------------------------------------------
-- |-------------------------< Future_Rows_Exists >---------------------------|
-- ----------------------------------------------------------------------------
--
Function Future_Rows_Exist
  (p_base_table_name IN     varchar2
  ,p_effective_date  in     date
  ,p_base_key_value  in     number
  )
return Boolean
Is
  --
  l_proc                    varchar2(72) := g_package||'Future_Rows_Exist';
  l_boolean                 boolean := false;
  l_dummy_esd               date;   -- Not required
  l_effective_end_date      date;   -- Current effective end date
  l_max_effective_end_date  date;   -- Maximum effective end date
  --
Begin
  Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  --
  -- Must ensure that a row exists as of the effective date supplied
  -- and we need the current effective end date
  --
  ben_batch_dt_api.return_effective_dates
    (p_base_table_name      => p_base_table_name
    ,p_effective_date       => p_effective_date
    ,p_base_key_value       => p_base_key_value
    ,p_effective_start_date => l_dummy_esd
    ,p_effective_end_date   => l_effective_end_date
    );
  --
  -- We must select the maximum effective end date for the datetracked
  -- rows
  --
  l_max_effective_end_date :=
  ben_batch_dt_api.return_max_end_date
    (p_base_table_name => p_base_table_name
    ,p_base_key_value  => p_base_key_value
    );
  --
  -- If the maximum effective end date is greater than the current effective
  -- end date then future rows exist
  --
  If (l_max_effective_end_date > l_effective_end_date) then
    l_boolean := TRUE;
  End If;
  --
  Hr_Utility.Set_Location('Leaving :'||l_proc, 15);
  Return(l_boolean);
  --
End Future_Rows_Exist;
--
procedure validate_dt_mode_pep
  (p_effective_date        in     date
  ,p_datetrack_mode        in     varchar2
  ,p_elig_per_id           in     number
  --
  ,p_validation_start_date in out nocopy date
  ,p_validation_end_date   in out nocopy date
  )
is
  --
  l_validation_start_date date;
  l_validation_end_date   date;
  --
  l_effective_start_date  date;
  l_effective_end_date    date;
  --
  l_table_name            varchar2(100);
  --
begin
  --
  l_table_name := 'BEN_ELIG_PER_F';
  --
  if p_datetrack_mode = hr_api.g_correction
  then
    --
    ben_batch_dt_api.return_effective_dates
      (p_base_table_name      => l_table_name
      ,p_effective_date       => p_effective_date
      ,p_base_key_value       => p_elig_per_id
      ,p_effective_start_date => l_validation_start_date
      ,p_effective_end_date   => l_validation_end_date
      );
    --
  elsif p_datetrack_mode = hr_api.g_update
  then
    --
    -- Determine if any future rows exist
    --
    If NOT (ben_batch_dt_api.Future_Rows_Exist
            (p_base_table_name => l_table_name
            ,p_effective_date  => p_effective_date
            ,p_base_key_value  => p_elig_per_id
            )
           )
    then
      --
      ben_batch_dt_api.return_effective_dates
        (p_base_table_name      => l_table_name
        ,p_effective_date       => p_effective_date
        ,p_base_key_value       => p_elig_per_id
        ,p_effective_start_date => l_effective_start_date
        ,p_effective_end_date   => l_effective_end_date
        );
      --
      -- Providing the current effective start date is not equal to the effective
      -- date we must return the the validation start and end dates
      --
      If (l_effective_start_date <> p_effective_date)
      then
        --
        l_validation_start_date := p_effective_date;
        l_validation_end_date   := l_effective_end_date;
        --
      Else
        --
        -- We cannot perform a DateTrack update operation where the effective
        -- date is the same as the current effective end date
        --
        hr_utility.set_message(801, 'HR_7179_DT_UPD_NOT_ALLOWED');
        hr_utility.raise_error;
        --
      End If;
      --
    Else
      --
      hr_utility.set_message(801, 'HR_7211_DT_UPD_ROWS_IN_FUTURE');
      hr_utility.raise_error;
      --
    End If;
    --
  else
    --
    dt_api.validate_dt_mode
      (p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_base_table_name         => 'ben_elig_per_f'
      ,p_base_key_column         => 'elig_per_id'
      ,p_base_key_value          => p_elig_per_id
      ,p_parent_table_name1      => 'ben_ler_f'
      ,p_parent_key_column1      => 'ler_id'
      ,p_parent_key_value1       => ben_pep_shd.g_old_rec.ler_id
      ,p_parent_table_name2      => 'ben_pgm_f'
      ,p_parent_key_column2      => 'pgm_id'
      ,p_parent_key_value2       => ben_pep_shd.g_old_rec.pgm_id
      ,p_parent_table_name3      => 'ben_pl_f'
      ,p_parent_key_column3      => 'pl_id'
      ,p_parent_key_value3       => ben_pep_shd.g_old_rec.pl_id
      ,p_parent_table_name4      => 'per_all_people_f'
      ,p_parent_key_column4      => 'person_id'
      ,p_parent_key_value4       => ben_pep_shd.g_old_rec.person_id
      ,p_parent_table_name5      => 'ben_plip_f'
      ,p_parent_key_column5      => 'plip_id'
      ,p_parent_key_value5       => ben_pep_shd.g_old_rec.plip_id
      ,p_parent_table_name6      => 'ben_ptip_f'
      ,p_parent_key_column6      => 'ptip_id'
      ,p_parent_key_value6       => ben_pep_shd.g_old_rec.ptip_id
      ,p_child_table_name1       => 'ben_elig_per_opt_f'
      ,p_child_key_column1       => 'elig_per_opt_id'
      ,p_enforce_foreign_locking => false
      ,p_validation_start_date   => l_validation_start_date
      ,p_validation_end_date     => l_validation_end_date
      );
     --
  end if;
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
end validate_dt_mode_pep;
--
procedure validate_dt_mode_epo
  (p_effective_date        in     date
  ,p_datetrack_mode        in     varchar2
  ,p_elig_per_opt_id       in     number
  --
  ,p_validation_start_date in out nocopy date
  ,p_validation_end_date   in out nocopy date
  )
is
  --
  l_validation_start_date date;
  l_validation_end_date   date;
  --
  l_effective_start_date  date;
  l_effective_end_date    date;
  --
  l_table_name            varchar2(100);
  --
begin
  --
  l_table_name := 'BEN_ELIG_PER_OPT_F';
  --
  if p_datetrack_mode = hr_api.g_correction
  then
    --
    ben_batch_dt_api.return_effective_dates
      (p_base_table_name      => l_table_name
      ,p_effective_date       => p_effective_date
      ,p_base_key_value       => p_elig_per_opt_id
      ,p_effective_start_date => l_validation_start_date
      ,p_effective_end_date   => l_validation_end_date
      );
    --
  elsif p_datetrack_mode = hr_api.g_update
  then
    --
    -- Determine if any future rows exist
    --
    If NOT (ben_batch_dt_api.Future_Rows_Exist
            (p_base_table_name => l_table_name
            ,p_effective_date  => p_effective_date
            ,p_base_key_value  => p_elig_per_opt_id
            )
           )
    then
      --
      ben_batch_dt_api.return_effective_dates
        (p_base_table_name      => l_table_name
        ,p_effective_date       => p_effective_date
        ,p_base_key_value       => p_elig_per_opt_id
        ,p_effective_start_date => l_effective_start_date
        ,p_effective_end_date   => l_effective_end_date
        );
      --
      -- Providing the current effective start date is not equal to the effective
      -- date we must return the the validation start and end dates
      --
      If (l_effective_start_date <> p_effective_date)
      then
        --
        l_validation_start_date := p_effective_date;
        l_validation_end_date   := l_effective_end_date;
        --
      Else
        --
        -- We cannot perform a DateTrack update operation where the effective
        -- date is the same as the current effective end date
        --
        hr_utility.set_message(801, 'HR_7179_DT_UPD_NOT_ALLOWED');
        hr_utility.raise_error;
        --
      End If;
      --
    Else
      --
      hr_utility.set_message(801, 'HR_7211_DT_UPD_ROWS_IN_FUTURE');
      hr_utility.raise_error;
      --
    End If;
    --
  else
    --
    dt_api.validate_dt_mode
      (p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_base_table_name         => 'ben_elig_per_opt_f'
      ,p_base_key_column         => 'elig_per_opt_id'
      ,p_base_key_value          => p_elig_per_opt_id
      ,p_parent_table_name1      => 'ben_elig_per_f'
      ,p_parent_key_column1      => 'elig_per_id'
      ,p_parent_key_value1       => ben_epo_shd.g_old_rec.elig_per_id
      ,p_parent_table_name2      => 'ben_opt_f'
      ,p_parent_key_column2      => 'opt_id'
      ,p_parent_key_value2       => ben_epo_shd.g_old_rec.opt_id
      ,p_enforce_foreign_locking => false
      ,p_validation_start_date   => l_validation_start_date
      ,p_validation_end_date     => l_validation_end_date
      );
     --
  end if;
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
end validate_dt_mode_epo;
--
end ben_batch_dt_api;

/
