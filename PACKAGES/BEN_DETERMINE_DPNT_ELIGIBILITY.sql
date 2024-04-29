--------------------------------------------------------
--  DDL for Package BEN_DETERMINE_DPNT_ELIGIBILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DETERMINE_DPNT_ELIGIBILITY" AUTHID CURRENT_USER as
/* $Header: bendepen.pkh 120.1.12010000.1 2008/07/29 12:09:29 appldev ship $ */
-----------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                   |
|                          Redwood Shores, California, USA                      |
|                               All rights reserved.                            |
+==============================================================================+
Name
	Manage Dependent Eligibility
Purpose
	This package is used to determine the dependents who may be eligible for
      an electable choice for a specific participant.  It also determines
      if the electable choice may or may not actually be electable.
History
	Date             Who          Version    What?
	----             ---          -------    -----
	09 Apr 98        MRosen/JM    110.0      Created.
        03 Jun 98        J Mohapatra             Replaced the date calculation
                                                 with a new procedure call.
        27 Dec 98        S Tee        115.2      Changed g_package to
                                                 the package name instead of the
                                                 file name.
        18 Jan 99        G Perry      115.3      LED V ED
        01 Apr 00        S Tee        115.4      Added g_dpnt_ineligible.
        01 May 00        pbodla       115.5    - Task 131 : Elig dependent rows are
                                                 created before creating the electable
                                                 choice rows. Added procedures main() -
                                                 created the elig dependent rows,
                                                 p_upd_egd_with_epe_id()- updates elig
                                                 dependent rows with electable choice
                                                 rows. Added g_egd_table, g_upd_epe_egd_rec
                                                 globals.
        15 Jun 00        pbodla       115.6    - Removed old main(). as Martin looked
                                                 at it for performance reasons.
        05 Jan 01        kmahendr     115.7    - changes made for unrestricted life event
                                                 added parameter - per_in_ler_id
        11-Mar-02        mhoyes       115.8    - Dependent eligibility tuning.
        11-Mar-02        mhoyes       115.9    - Added dbdrv line.
        04-Feb-06        mhoyes       115.12   - bug4966769 - hr_utility tuning.
*/
-----------------------------------------------------------------------
g_package         varchar2(80) := 'ben_determine_dpnt_eligibility';
g_dpnt_ineligible boolean := false;
--
TYPE egd_table is TABLE OF ben_elig_dpnt%rowtype
     INDEX BY BINARY_INTEGER;
--
g_egd_table egd_table;
g_egd_table_temp egd_table;
--
type upd_epe_egd_rec is record
    (g_code                 ben_pl_f.dpnt_dsgn_cd%type
    ,g_ler_chg_dpnt_cvg_cd  ben_ler_chg_dpnt_cvg_f.ler_chg_dpnt_cvg_cd%type
    ,g_cvg_strt_cd          ben_ler_chg_dpnt_cvg_f.cvg_eff_strt_cd%type
    ,g_process_flag         char(1)
    ,g_cvg_strt_rl          ben_ler_chg_dpnt_cvg_f.cvg_eff_strt_rl%type);
--
g_upd_epe_egd_rec upd_epe_egd_rec;
  --
  g_debug boolean := hr_utility.debug_enabled;
  --
procedure main
  (p_pgm_id            in     number default null
  ,p_pl_id             in     number default null
  ,p_plip_id           in     number default null
  ,p_ptip_id           in     number default null
  ,p_oipl_id           in     number default null
  ,p_pl_typ_id         in     number default null
  ,p_business_group_id in     number
  ,p_person_id         in     number
  ,p_effective_date    in     date
  ,p_lf_evt_ocrd_dt    in     date
  ,p_per_in_ler_id     in     number default null
  ,p_elig_per_id       in     number default null
  ,p_elig_per_opt_id   in     number default null
  );
--
procedure p_upd_egd_with_epe_id
          (p_elig_per_elctbl_chc_id   in number,
           p_person_id                in number,
           p_effective_date           in date,
           p_lf_evt_ocrd_dt           in date);
END;

/
