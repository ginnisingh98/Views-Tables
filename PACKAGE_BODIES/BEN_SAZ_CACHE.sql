--------------------------------------------------------
--  DDL for Package Body BEN_SAZ_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_SAZ_CACHE" as
/* $Header: bensazch.pkb 120.0.12010000.3 2009/10/16 03:49:24 krupani ship $ */
--
/*
+==============================================================================+
|			 Copyright (c) 1997 Oracle Corporation		       |
|			    Redwood Shores, California, USA		       |
|				All rights reserved.			       |
+==============================================================================+
--
History
  Version    Date	Author	   Comments
  ---------  ---------	---------- --------------------------------------------
  115.0      17-Sep-00	mhoyes     Created.
  115.2     11-dec-2002 hmani 	    NoCopy changes
  115.3     29-Jan-2009 krupani    Bug 7718194 - zip code range (g_sazrzr_zippzrid_va) should be
                                   re-populated when service area (g_sazrzr_svcpzrid_va) is re-populated
  115.4     16-Oct-2009 krupani    Bug 9021884 - modified the fix of 7718194 in order not to cause the
                                   performance issue. Reverted the fix of 7718194
  -----------------------------------------------------------------------------
*/
--
-- Globals.
--
g_package varchar2(50) := 'ben_saz_cache.';
--
type g_current_row is record
  (zip_code       varchar2(30)
  ,svc_area_id    number
  ,effective_date date
  );
--
g_sazrzr_current     g_current_row;
g_sazrzr_svcpzrid_va benutils.g_number_table := benutils.g_number_table();
g_sazrzr_zippzrid_va benutils.g_number_table := benutils.g_number_table();
--
procedure SAZRZR_Exists
  (p_svc_area_id in     number
  ,p_zip_code    in     varchar2
  ,p_eff_date    in     date
  --
  ,p_exists         out nocopy boolean
  )
is
  --
  l_proc varchar2(72) :=  'SAZRZR_Exists';
  l_effective_date date;  -- Bug 9021884
  --
  type l_hash_table_row is record
    (id number
    );
  --
  type l_hash_table_tbl is table of l_hash_table_row index by binary_integer;
  --
  l_hash_table_tor      l_hash_table_tbl;
  --
  l_hv                  pls_integer;
  --

  cursor c_saz
    (c_svc_area_id   number
    ,c_eff_date      date
    )
  is
    select saz.pstl_zip_rng_id
    from   ben_svc_area_pstl_zip_rng_f saz
    where  saz.SVC_AREA_ID = c_svc_area_id
    and    c_eff_date
      between saz.effective_start_date and saz.effective_end_date;
  --
  cursor c_rzr
    (c_zip_code      VARCHAR2
    ,c_eff_date      date
    )
  is
    select rzr.pstl_zip_rng_id
    from   ben_pstl_zip_rng_f rzr
    where
           length(c_zip_code) >= length(rzr.from_value)
    and
           (substr(c_zip_code,1,length(rzr.from_value))
      between rzr.from_value and rzr.to_value
           )
    and    c_eff_date
      between rzr.effective_start_date and rzr.effective_end_date;
  --
begin
  --
  -- When the zip code is null then no ranges match
  --
  -- Bug 9021884: Storing the date in a temp varialbe
  l_effective_date := g_sazrzr_current.effective_date;

  if p_zip_code is null
  then
    --
    p_exists := false;
    return;
    --
  end if;
  --
  -- Check if cached postal code ranges are for currently
  -- cached service area. Or the effective date has changed.
  --
  if nvl(g_sazrzr_current.svc_area_id,-999999) <> p_svc_area_id
    or nvl(g_sazrzr_current.effective_date,hr_api.g_sot) <> p_eff_date
  then
    --
    g_sazrzr_svcpzrid_va.delete;
    --
    open c_saz
      (c_svc_area_id => p_svc_area_id
      ,c_eff_date    => p_eff_date
      );
    fetch c_saz BULK COLLECT INTO g_sazrzr_svcpzrid_va;
    close c_saz;
    --
    g_sazrzr_current.svc_area_id    := p_svc_area_id;
    g_sazrzr_current.effective_date := p_eff_date;
    --
  end if;
  --
  -- Check if cached service area postal code ranges
  -- exist
  --
  if g_sazrzr_svcpzrid_va.count = 0
  then
    --
    p_exists := false;
    return;
    --
  --
  -- Check if cached postal code ranges are for the current
  -- zip code
  --
  /* Bug 9021884: replaced g_sazrzr_current.effective_date by l_effective_date below*/

  elsif nvl(g_sazrzr_current.zip_code,'00000') <> p_zip_code
    or nvl(l_effective_date,hr_api.g_sot) <> p_eff_date
  then
    --
    g_sazrzr_zippzrid_va.delete;
    --
    open c_rzr
      (c_zip_code => p_zip_code
      ,c_eff_date => p_eff_date
      );
    fetch c_rzr BULK COLLECT INTO g_sazrzr_zippzrid_va;
    close c_rzr;
    --
    g_sazrzr_current.zip_code := p_zip_code;
    g_sazrzr_current.effective_date := p_eff_date;
    --
  end if;
  --
  -- Check if cached zip code postal code ranges exist
  --
  if g_sazrzr_zippzrid_va.count = 0
  then
    --
    p_exists := false;
    return;
    --
  end if;
  --
  -- Populate zip values in hash table
  --
  for i in g_sazrzr_zippzrid_va.first..g_sazrzr_zippzrid_va.last
  loop
    --
    l_hv := mod(g_sazrzr_zippzrid_va(i),ben_hash_utility.get_hash_key);
    l_hash_table_tor(l_hv).id := g_sazrzr_zippzrid_va(i);
    --
  end loop;
  --
  -- Check for service area clashes
  --
  for i in g_sazrzr_svcpzrid_va.first..g_sazrzr_svcpzrid_va.last
  loop
    --
    l_hv := mod(g_sazrzr_svcpzrid_va(i),ben_hash_utility.get_hash_key);
    --
    if l_hash_table_tor.exists(l_hv)
    then
      --
      p_exists := true;
      return;
      --
    end if;
    --
  end loop;
  --
  p_exists := false;
  --
end SAZRZR_Exists;
--
procedure clear_down_cache
is

  l_sazrzr_reset g_current_row;

begin
  --
  g_sazrzr_svcpzrid_va.delete;
  g_sazrzr_zippzrid_va.delete;
  g_sazrzr_current := l_sazrzr_reset;
  --
end clear_down_cache;
--
end ben_saz_cache;

/
