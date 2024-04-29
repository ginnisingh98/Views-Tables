--------------------------------------------------------
--  DDL for Package BEN_DETERMINE_RATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DETERMINE_RATES" AUTHID CURRENT_USER as
/* $Header: benrates.pkh 120.0.12010000.1 2008/07/29 12:29:27 appldev ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA	  	           |
|			        All rights reserved.			           |
+==============================================================================+
Name:
    Determine Rates.

Purpose:
    This process determines rates for either elctable choices or coverages, and
    writes them to the ben_enrt_rt table.  This process can only run in benmngle.

History:
        Date             Who        Version    What?
        ----             ---        -------    -----
        7 May 97        Ty Hayden  110.0      Created.
       10 aug 98        tguy       110.1      added procedure ben_rates for
	                                          performance reasons.
       23 Oct 98        tguy       115.2      added person_id to main
       02 Nov 98        tguy       115.3      added p_asn_on_enrt_flag as parameter
                                              to ben_rates
       11 Jan 99        tguy       115.4      added elig_per_elctbl_chc_id as parm
       18 Jan 99        G Perry    115.5      LED V ED
       04 Mar 99        t guy      115.6      added dflt_flag and ctfn_rqd_flag
        09 Mar 99        G Perry    115.7      IS to AS.
        21 Mar 99        mhoyes     115.8   - Added p_person_id, p_pgm_id, p_pl_id
                                              and p_oipl_id to ben_rates.
        03 May 99        mhoyes     115.9   - Removed p_elig_per_elctbl_chc_id
                                              from main.
        29 May 99        mhoyes     115.10  - Added epe type and default globals.
                                            - Added defaulted record structures to
                                              ben_rates.
        30 May 99        mhoyes     115.11  - Added epe type enrt_perd_strt_dt to
                                              g_curr_epe_rec.
        28 Jun 99        mhoyes     115.12  - Added more attributes to
                                              g_curr_epe_rec.
        07 Sep 00        kmahendr   115.13  - Added more attributes to
                                              g_curr_epe_rec.
        07 Nov 00        mhoyes     115.14  - Removed ben_rates routine.
        05 Jan 01        kmahendr   115.15  - Added per_in_ler_id parameter
        10 Jul 01        mhoyes     115.16  - Added new values to g_curr_epe_rec
                                              type.
        14 Aug 01        mhoyes     115.17  - Added bnft_prvdr_pool_id to g_curr_epe_rec
                                              type.
        15 May 02        ikasire    115.18  - Bug 2200139 Override Enrollment changes added
                                              new parameter p_elig_per_elctbl_chc_id for the
                                              main procedure for calling from Override
                                              process.
       14-Jan-03        pbodla     115.19,20  GLOBALCWB : Added code to  populate
                                              CWB rates.
*/
--------------------------------------------------------------------------------
--
type g_curr_epe_rec is record
  (elig_per_elctbl_chc_id number
  ,business_group_id      number
  ,person_id              number
  ,ler_id                 number
  ,per_in_ler_id          number
  ,lf_evt_ocrd_dt         date
  ,pgm_id                 number
  ,enrt_bnft_id           number
  ,pl_typ_id              number
  ,ptip_id                number
  ,plip_id                number
  ,pl_id                  number
  ,oipl_id                number
  ,oiplip_id              number
  ,opt_id                 number
  ,enrt_perd_id           number
  ,lee_rsn_id             number
  ,enrt_perd_strt_dt      date
  ,prtt_enrt_rslt_id      number
  ,prtn_strt_dt           date
  ,enrt_cvg_strt_dt       date
  ,enrt_cvg_strt_dt_cd    varchar2(30)
  ,enrt_cvg_strt_dt_rl    number
  ,yr_perd_id             number
  ,prtn_ovridn_flag       varchar2(30)
  ,prtn_ovridn_thru_dt    date
  ,rt_age_val             number
  ,rt_los_val             number
  ,rt_hrs_wkd_val         number
  ,rt_cmbn_age_n_los_val  number
  ,bnft_prvdr_pool_id     number
  );
--
PROCEDURE main
  (p_effective_date         IN date
  ,p_lf_evt_ocrd_dt         IN date
  ,p_person_id              IN number
  ,p_per_in_ler_id          in number
  ,p_elig_per_elctbl_chc_id in number default null -- For Override Call only
  ,p_mode                   in varchar2 default null
  );
--
g_def_curr_epe_rec g_curr_epe_rec;
g_def_curr_per_rec per_all_people_F%rowtype;
g_def_curr_asg_rec per_all_assignments_f%rowtype;
g_def_curr_ast_rec per_assignment_status_types%rowtype;
g_def_curr_adr_rec per_addresses%rowtype;
--
end ben_determine_rates ;

/
