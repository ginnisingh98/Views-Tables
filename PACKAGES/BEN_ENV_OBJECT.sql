--------------------------------------------------------
--  DDL for Package BEN_ENV_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENV_OBJECT" AUTHID CURRENT_USER as
/* $Header: benenvir.pkh 120.0 2005/05/28 08:58:20 appldev noship $ */
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
  ---------  ---------  -------    --------------------------------------------
  17 May 99  G Perry    115.0      Created
  11 Jun 99  bbulusu    115.1      Added elig flags to the cache structure and
                                   setenv procedures for them.
  23 Jun 99  G Perry    115.2      Added plip_id to structure.
  06 Jul 99  S Das      115.3      Added setenv for business group.
  26 Jul 99  G Perry    115.4      Removed setenv for business group.
  20 Jan 2000 mhoyes    115.5    - Added PTIP to env object.
  20 Jan 2000 mhoyes    115.6    - Added exit.
  28 Jan 2000 mhoyes    115.7    - Added elig for PLIP and PTIP
                                   flags.
                                 - Fixed bug 1169613.
  26 Feb 2000 mhoyes    115.8    - Removed elig flags and routines. Moved into
                                   benmngle where they belong.
  15 May 2000 mhoyes    115.9    - Added audit_log_flag.
  30 Nov 2001 mhoyes    115.10   - Added mode_cd.
  30 Dec 2002 ikasire   115.11   - nocopy changes and dbdrv and commit
  05 May 2003 mhoyes    115.14   - Added bgp_legislation_code.
  ------------------------------------------------------------------------------
*/
--
type g_global_env_rec_type is record
  (business_group_id  number
  ,effective_date     date
  ,thread_id          number
  ,chunk_size         number
  ,threads            number
  ,max_errors         number
  ,benefit_action_id  number
  ,lf_evt_ocrd_dt     date
  ,person_id          number
  ,pgm_id             number
  ,pl_id              number
  ,oipl_id            number
  ,plip_id            number
  ,ptip_id            number
  ,elig_for_pl_flag   varchar2(30)
  ,elig_for_pgm_flag  varchar2(30)
  ,elig_for_plip_flag varchar2(30)
  ,elig_for_ptip_flag varchar2(30)
  ,audit_log_flag     varchar2(30)
  ,mode_cd            varchar2(30)
  ,bgp_legislation_code varchar2(30)
  );
--
g_global_env_rec g_global_env_rec_type;
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
  );
--
procedure get(p_rec out nocopy g_global_env_rec_type);
--
procedure setenv(p_lf_evt_ocrd_dt in date);
--
procedure setenv(p_person_id in number);
--
procedure setenv(p_pgm_id in number);
--
procedure setenv(p_ptip_id in number);
--
procedure setenv(p_pl_id in number);
--
procedure setenv(p_oipl_id in number);
--
procedure setenv(p_plip_id in number);
--
end ben_env_object;

 

/
