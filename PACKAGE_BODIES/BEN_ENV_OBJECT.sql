--------------------------------------------------------
--  DDL for Package Body BEN_ENV_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENV_OBJECT" as
/* $Header: benenvir.pkb 120.0 2005/05/28 08:58:11 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Environment Object Caching Routine
Purpose
	This package is used to return environment object information.
History
  Date       Who        Version    What?
  ---------  ---------- -------    --------------------------------------------
  17 May 99  G Perry    115.0      Created
  11 Jun 99  bbulusu    115.1      Added setenv procs for the elig flags.
  23 Jun 99  G Perry    115.2      Added plip_id to structure.
  06 Jul 99  s das      115.3      Added setenv for business group.
  08 Jul 99  mhoyes     115.4      Removed trace messages.
  26 Jul 99  G Perry    115.5      Removed setenv for business group.
  20 Jan 2000 mhoyes    115.6    - Added PTIP to env object.
  20 Jan 2000 mhoyes    115.7    - Added exit.
  28 Jan 2000 mhoyes    115.8    - Added elig for PLIP and PTIP
                                   flags.
                                 - Fixed bug 1169613.
  26 Fen 2000 mhoyes    115.9    - Removed elig flags and routines. Moved into
                                   benmngle where they belong.
  15 May 2000 mhoyes    115.10   - Added audit_log_flag.
  15 May 2000 mhoyes    115.11   - Fixed audit log problem.
  30 Nov 2001 mhoyes    115.12   - Added mode_cd.
  30 Dec 2002 ikasire   115.13   - nocopy changes plus dbdrv plus commit
  05 May 2003 mhoyes    115.14   - Added bgp_legislation_code.
*/
--------------------------------------------------------------------------------
--
g_package varchar2(30) := 'ben_env_object.';
--
procedure init
  (p_business_group_id in number
  ,p_effective_date    in date
  ,p_thread_id         in number
  ,p_chunk_size        in number
  ,p_threads           in number
  ,p_max_errors        in number
  ,p_benefit_action_id in number
  ,p_audit_log_flag    in varchar2 default 'N'
  )
is
  --
  l_proc varchar2(80) := g_package||'init';
  --
  cursor c_bftdets
    (c_bft_id in number
    )
  is
    select bft.audit_log_flag,
           bft.mode_cd
    from   ben_benefit_actions bft
    where  bft.benefit_action_id = c_bft_id;
  --
  l_bft_rec c_bftdets%rowtype;
  --
  cursor c_bgpdets
    (c_bgp_id in number
    )
  is
    select bgp.legislation_code
    from per_business_groups bgp
    where bgp.business_group_id = c_bgp_id;
  --
  l_bgpdets c_bgpdets%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  -- Get benefit action info
  --
  open c_bftdets
    (c_bft_id => p_benefit_action_id
    );
  fetch c_bftdets into l_bft_rec;
  close c_bftdets;
  --
  -- Get Business group details
  --
  if p_business_group_id is not null
  then
    --
    open c_bgpdets
      (c_bgp_id => p_business_group_id
      );
    fetch c_bgpdets into l_bgpdets;
    close c_bgpdets;
    --
  end if;
  --
  -- Default environment variables
  --
  g_global_env_rec.business_group_id    := p_business_group_id;
  g_global_env_rec.bgp_legislation_code := l_bgpdets.legislation_code;
  g_global_env_rec.effective_date := p_effective_date;
  g_global_env_rec.thread_id := p_thread_id;
  g_global_env_rec.chunk_size := p_chunk_size;
  g_global_env_rec.threads := p_threads;
  g_global_env_rec.max_errors := p_max_errors;
  g_global_env_rec.benefit_action_id := p_benefit_action_id;
  g_global_env_rec.audit_log_flag    := l_bft_rec.audit_log_flag;
  g_global_env_rec.mode_cd           := l_bft_rec.mode_cd;
  --
  -- Default remaining parameters to null
  --
  g_global_env_rec.lf_evt_ocrd_dt := null;
  g_global_env_rec.person_id := null;
  g_global_env_rec.pgm_id := null;
  g_global_env_rec.pl_id := null;
  g_global_env_rec.oipl_id := null;
  g_global_env_rec.plip_id := null;
  g_global_env_rec.ptip_id := null;
  --
  hr_utility.set_location('Leaving '||l_proc,10);
  --
end init;
--
procedure get(p_rec out nocopy g_global_env_rec_type) is
  --
  l_proc varchar2(80) := g_package||'get';
  --
begin
  --
  p_rec := g_global_env_rec;
  --
end get;
--
procedure setenv(p_lf_evt_ocrd_dt in date) is
  --
  l_proc varchar2(80) := g_package||'setenv 1';
  --
begin
  --
  g_global_env_rec.lf_evt_ocrd_dt := p_lf_evt_ocrd_dt;
  --
end setenv;
--
procedure setenv(p_person_id in number) is
  --
  l_proc varchar2(80) := g_package||'setenv 2';
  --
begin
  --
  g_global_env_rec.person_id := p_person_id;
  --
end setenv;
--
procedure setenv(p_pgm_id in number) is
  --
  l_proc varchar2(80) := g_package||'setenv 3';
  --
begin
  --
  g_global_env_rec.pgm_id := p_pgm_id;
  --
end setenv;
--
procedure setenv(p_ptip_id in number) is
  --
  l_proc varchar2(80) := g_package||'setenv 3.1';
  --
begin
  --
  g_global_env_rec.ptip_id := p_ptip_id;
  --
end setenv;
--
procedure setenv(p_pl_id in number) is
  --
  l_proc varchar2(80) := g_package||'setenv 4';
  --
begin
  --
  g_global_env_rec.pl_id := p_pl_id;
  --
end setenv;
--
procedure setenv(p_plip_id in number) is
  --
  l_proc varchar2(80) := g_package||'setenv 5';
  --
begin
  --
  g_global_env_rec.plip_id := p_plip_id;
  --
end setenv;
--
procedure setenv(p_oipl_id in number) is
  --
  l_proc varchar2(80) := g_package||'setenv 6';
  --
begin
  --
  g_global_env_rec.oipl_id := p_oipl_id;
  --
end setenv;
--
end ben_env_object;

/
