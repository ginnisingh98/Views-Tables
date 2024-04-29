--------------------------------------------------------
--  DDL for Package Body BEN_SEEDDATA_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_SEEDDATA_OBJECT" as
/* $Header: benseedc.pkb 115.5 2002/12/19 09:53:14 hmani ship $ */
--
/*
+==============================================================================+
|                        Copyright (c) 1997 Oracle Corporation                 |
|                           Redwood Shores, California, USA                    |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
	Lookup Object Caching Routine
Purpose
	This package is used to return lookup object information.
History
  Version    Date       Who        What?
  ---------  ---------  ---------- --------------------------------------------
  115.0      11-JUN-99  gperry     Created.
  115.1      23-AUG-99  gperry     Added nocopy compiler directive.
                                   Removed trace messages.
  115.2      04-OCT-99  stee       Added DRVDNLP,DRVDPOEELG, DRVDPOERT,
                                   DRVDLSELG.
  115.3      07-OCT-99  stee       Uncomment out nocopy cache check for ler_id.
  115.4      09-NOV-99  stee       Add DRVDVEC.
  115.5    11-dec-2002  hmani 	   NoCopy changes
  -----------------------------------------------------------------------------
*/
--
g_package varchar2(30) := 'ben_seeddata_object.';
--
-- Set object routines
--
procedure set_object(p_rec in g_derived_factor_info_rec) is
  --
  l_proc           varchar2(80) := g_package||'set_object';
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  g_cache_derived_factor_rec := p_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_object;
--
-- Set object alternate route routines
--
procedure set_object
  (p_effective_date    in date,
   p_business_group_id in number,
   p_rec               out nocopy g_derived_factor_info_rec) is
  --
  l_proc           varchar2(80) := g_package||'set_object';
  --
  cursor c1 is
    select ler.ler_id,
           ler.typ_cd
    from   ben_ler_f ler
    where  ler.business_group_id+0 = p_business_group_id
    and    ler.typ_cd in ('DRVDAGE','DRVDLOS','DRVDCAL',
                          'DRVDHRW','DRVDTPF','DRVDCMP',
                          'DRVDLSELG','DRVDNLP','DRVDPOEELG',
                          'DRVDPOERT','DRVDVEC')
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date;
  --
  l_rec c1%rowtype;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
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
      if l_rec.typ_cd = 'DRVDHRW' then
        --
        g_cache_derived_factor_rec.drvdhrw_id := l_rec.ler_id;
        --
      elsif l_rec.typ_cd = 'DRVDAGE' then
        --
        g_cache_derived_factor_rec.drvdage_id := l_rec.ler_id;
        --
      elsif l_rec.typ_cd = 'DRVDLOS' then
        --
        g_cache_derived_factor_rec.drvdlos_id := l_rec.ler_id;
        --
      elsif l_rec.typ_cd = 'DRVDCAL' then
        --
        g_cache_derived_factor_rec.drvdcal_id := l_rec.ler_id;
        --
      elsif l_rec.typ_cd = 'DRVDTPF' then
        --
        g_cache_derived_factor_rec.drvdtpf_id := l_rec.ler_id;
        --
      elsif l_rec.typ_cd = 'DRVDCMP' then
        --
        g_cache_derived_factor_rec.drvdcmp_id := l_rec.ler_id;
        --
      elsif l_rec.typ_cd = 'DRVDLSELG' then
        --
        g_cache_derived_factor_rec.drvdlselg_id := l_rec.ler_id;
        --
      elsif l_rec.typ_cd = 'DRVDNLP' then
        --
        g_cache_derived_factor_rec.drvdnlp_id := l_rec.ler_id;
        --
      elsif l_rec.typ_cd = 'DRVDPOEELG' then
        --
        g_cache_derived_factor_rec.drvdpoeelg_id := l_rec.ler_id;
        --
      elsif l_rec.typ_cd = 'DRVDPOERT' then
        --
        g_cache_derived_factor_rec.drvdpoert_id := l_rec.ler_id;
        --
      elsif l_rec.typ_cd = 'DRVDVEC' then
        --
        g_cache_derived_factor_rec.drvdvec_id := l_rec.ler_id;
        --
      end if;
      --
    end loop;
    --
  close c1;
  --
  -- Sanity check that are the derived factor life events are there
  --
  if g_cache_derived_factor_rec.drvdhrw_id is null or
     g_cache_derived_factor_rec.drvdtpf_id is null or
     g_cache_derived_factor_rec.drvdcal_id is null or
     g_cache_derived_factor_rec.drvdcmp_id is null or
     g_cache_derived_factor_rec.drvdlos_id is null or
     g_cache_derived_factor_rec.drvdage_id is null or
     g_cache_derived_factor_rec.drvdlselg_id is null or
     g_cache_derived_factor_rec.drvdnlp_id is null or
     g_cache_derived_factor_rec.drvdpoeelg_id is null or
     g_cache_derived_factor_rec.drvdpoert_id is null  then
    --
    fnd_message.set_name('BEN','BEN_91411_SEEDED_LERS_NO_EXIST');
    fnd_message.raise_error;
    --
  end if;
  --
  p_rec := g_cache_derived_factor_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_object;
--
-- Get object routines
--
procedure get_object(p_rec out nocopy g_derived_factor_info_rec) is
  --
  l_proc           varchar2(80) := g_package||'get_object';
  l_env_rec        ben_env_object.g_global_env_rec_type;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_derived_factor_rec.drvdage_id is null then
    --
    -- We need to setup the derived factor life events
    --
    ben_env_object.get(p_rec => l_env_rec);
    --
    set_object(p_effective_date    => nvl(l_env_rec.lf_evt_ocrd_dt,
                                          l_env_rec.effective_date),
               p_business_group_id => l_env_rec.business_group_id,
               p_rec               => p_rec);
    --
  else
    --
    p_rec := g_cache_derived_factor_rec;
    --
  end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
end get_object;
--
procedure clear_down_cache is
  --
  l_derived_rec g_derived_factor_info_rec;
  --
begin
  --
  g_cache_derived_factor_rec := l_derived_rec;
  --
end clear_down_cache;
--
end ben_seeddata_object;

/
