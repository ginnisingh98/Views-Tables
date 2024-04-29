--------------------------------------------------------
--  DDL for Package BEN_DETERMINE_VARIABLE_RATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DETERMINE_VARIABLE_RATES" AUTHID CURRENT_USER AS
/* $Header: benvrbrt.pkh 120.0.12010000.2 2009/02/11 08:49:57 pvelvano ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA	  	           |
|			        All rights reserved.			           |
+==============================================================================+
Name
	Determine Variable Rates
Purpose:
      Determine Variable rates for activity base rates, coverages, and actl premiums.
      This process establishes if variable rate profiles or variable rate rules are
      used, if profiles are used call evaluate profile process to determine profile to
      use, if rules are used call fast formula to return value, and finally passes
      back the value information for the first profile/rule that passes.

History:
        Date             Who        Version    What?
        ----             ---        -------    -----
        2 Jun 97         Ty Hayden  110.0      Created.
        7 Oct 98         T Guy      115.2      Implemented schema changes for
                                               ben_enrt_rt
        30-OCT-98        G PERRY    115.3      Removed Control m
        18-Jan-99        G Perry    115.4      LED V ED
        09 Mar 99        G Perry    115.5      IS to AS.
        27 May 99        maagrawa   115.6      Modified the procedure to be called without
                                               chc_id and pass the reqd. parameters instead.
        21 Jun 99        lmcdonal   115.7      Moved limit check code into its own
                                               procedure.
         1 Jul 99        lmcdonal   115.8      removed limit check to benutils.
        20-JUL-99        Gperry     115.9      genutils -> benutils package
                                               rename.
        29-May-00        mhoyes     115.10   - Added defaulted record structures.
        28-Jun-00        mhoyes     115.11   - Added p_currepe_row to main.
        21-mar-01        tilak      115.12     param ultmt_upt_lmt,ultmt_lwr_lmt added
        01-apr-01        tilak      115.13     param ultmt_upt_lmt_calc_rl,ultmt_lwr_lmt_calc_rl added
        26-Sep-01        kmahendr   115.14   - Added ann_mn_elcn_val, ann_mx_elcn_val param
        13-Nov-02        vsethi     115.15     Bug 1210355, Added package variable g_vrbl_mlt_code
        				       to store the mlt_code defined in profile
        23-Dec-2002      rpgupta    115.16     Nocopy changes
	11-Feb-2009      velvanop   115.17     Bug 7414757: Added parameter p_entr_val_at_enrt_flag.
	                                       VAPRO rates which are enter value at Enrollment.
*/
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-------------------------------- main -----------------------------------------
--------------------------------------------------------------------------------
PROCEDURE main
  (p_currepe_row            in ben_determine_rates.g_curr_epe_rec
   := ben_determine_rates.g_def_curr_epe_rec
  ,p_per_row                in per_all_people_F%rowtype
   := ben_determine_rates.g_def_curr_per_rec
  ,p_asg_row                in per_all_assignments_f%rowtype
   := ben_determine_rates.g_def_curr_asg_rec
  ,p_ast_row                in per_assignment_status_types%rowtype
   := ben_determine_rates.g_def_curr_ast_rec
  ,p_adr_row                in per_addresses%rowtype
   := ben_determine_rates.g_def_curr_adr_rec
  ,p_person_id              IN number
  ,p_elig_per_elctbl_chc_id IN number
  ,p_enrt_bnft_id           IN number default null
  ,p_actl_prem_id           IN number default null --\
  ,p_acty_base_rt_id        IN number default null -- Only one of these 3 have val.
  ,p_cvg_amt_calc_mthd_id   IN number default null --/
  ,p_effective_date         IN date
  ,p_lf_evt_ocrd_dt         IN date
  ,p_calc_only_rt_val_flag  in boolean default false
  ,p_pgm_id                 in number  default null
  ,p_pl_id                  in number  default null
  ,p_oipl_id                in number  default null
  ,p_pl_typ_id              in number  default null
  ,p_per_in_ler_id          in number  default null
  ,p_ler_id                 in number  default null
  ,p_business_group_id      in number  default null
  ,p_bnft_amt               in number  default null
  ,p_entr_val_at_enrt_flag  in out nocopy varchar2 -- Added parameter for Bug 7414757
  ,p_val                    out nocopy number
  ,p_mn_elcn_val            out nocopy number
  ,p_mx_elcn_val            out nocopy number
  ,p_incrmnt_elcn_val       out nocopy number
  ,p_dflt_elcn_val          out nocopy number
  ,p_tx_typ_cd              out nocopy varchar2
  ,p_acty_typ_cd            out nocopy varchar2
  ,p_vrbl_rt_trtmt_cd       out nocopy varchar2
  ,p_ultmt_upr_lmt          out nocopy number
  ,p_ultmt_lwr_lmt          out nocopy number
  ,p_ultmt_upr_lmt_calc_rl  out nocopy number
  ,p_ultmt_lwr_lmt_calc_rl  out nocopy number
  ,p_ann_mn_elcn_val        out nocopy number
  ,p_ann_mx_elcn_val        out nocopy number
   );

  -- Bug 1210355
  g_vrbl_mlt_code varchar2(30);
  --
end ben_determine_variable_rates;

/
