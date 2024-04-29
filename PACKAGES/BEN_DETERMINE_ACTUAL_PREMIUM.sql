--------------------------------------------------------
--  DDL for Package BEN_DETERMINE_ACTUAL_PREMIUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DETERMINE_ACTUAL_PREMIUM" AUTHID CURRENT_USER as
/* $Header: benacprm.pkh 120.1.12010000.1 2008/07/29 12:02:34 appldev ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|           Copyright (c) 1997 Oracle Corporation              |
|              Redwood Shores, California, USA                 |
|                   All rights reserved.                       |
+==============================================================================+
Name:
    Determine Actual Premiums

Purpose:
      This program determines the actual premium used for rates calculations.

History:
        Date             Who        Version    What?
        ----             ---        -------    -----
        20 Apr 97        Ty Hayden  110.0      Created.
        18 Jan 99        G Perry    115.2      LED V ED
        09 Mar 99        G Perry    115.3      IS to AS.
        27 May 99        maagrawa   115.4      Modified the procedure to pass
                                               in reqd. values as parameters,if
                                               choice is not available.
        25 Jun 99        T Guy      115.5      Added Total premium changes.
        02 Feb 00        lmcdonal   115.6      Break the computation of premium
                                               into a separate procedure so that
                                               it can be called independently.
                                               Bug 1166174.
        15 mar 01        tilak      115.7      g_computed_prem_val is added
                                               This is used to store the value of the
                                               computed premium, whic can be used for
                                               calcualtion mode only to get the ammount
                                               In this mode ele_chc_id,benefit is not inserted
                                               so the global_variable to get the value
        07-apr-04        tjesumic   115.8      fonm parameter added
        15-nov-04        kmahendr   115.10     Added parameter p_mode
        10-Aug-07        bmanyam    115.11     6330056: Added g_computed_prem_tbl

*/
--------------------------------------------------------------------------------
--  COMPUTE_PREMIUM
--------------------------------------------------------------------------------
g_computed_prem_val   ben_enrt_prem.val%type ;
--
-- 6330056 : Added a pl/sql table g_computed_prem_tbl to capture calculated
-- premium values, as there may be multiple premiums attached to
-- same object. After this change, the previously used global value
-- g_computed_prem_val will become redundant.
--
type g_computed_prem_rec is record
(actl_prem_id        ben_actl_prem_f.actl_prem_id%type
,val                 ben_enrt_prem.val%type);

type g_computed_prem_tab is table of g_computed_prem_rec
index by binary_integer;

g_computed_prem_tbl g_computed_prem_tab;


PROCEDURE compute_premium
      (p_person_id              in number,
       p_lf_evt_ocrd_dt         IN date,
       p_effective_date         IN date,
       p_business_group_id      in number,
       p_per_in_ler_id          in number,
       p_ler_id                 in number,
       p_actl_prem_id           in number,
       p_perform_rounding_flg   IN boolean default true,
       p_calc_only_rt_val_flag  in boolean default false,
       p_pgm_id                 in number,
       p_pl_typ_id              in number,
       p_pl_id                  in number,
       p_oipl_id                in number,
       p_opt_id                 in number,
       p_elig_per_elctbl_chc_id in number,
       p_enrt_bnft_id           in number,
       p_bnft_amt               in number,
       p_prem_val               in number,
       p_mlt_cd                 in varchar2,
       p_bnft_rt_typ_cd         in varchar2,
       p_val_calc_rl            in number,
       p_rndg_cd                in varchar2,
       p_rndg_rl                in number,
       p_upr_lmt_val            in number,
       p_lwr_lmt_val            in number,
       p_upr_lmt_calc_rl        in number,
       p_lwr_lmt_calc_rl        in number,
       ---bof  FONM
       p_fonm_cvg_strt_dt       in date   default  null ,
       p_fonm_rt_strt_dt        in date   default  null ,
       --- eof FONM
       p_computed_val          out nocopy number);


--------------------------------------------------------------------------------
--  main
--------------------------------------------------------------------------------
PROCEDURE main
     ( p_person_id              in number,
       p_effective_date         IN date,
       p_lf_evt_ocrd_dt         IN date,
       p_perform_rounding_flg   IN boolean default true,
       p_calc_only_rt_val_flag  in boolean default false,
       p_pgm_id                 in number  default null,
       p_pl_id                  in number  default null,
       p_oipl_id                in number  default null,
       p_pl_typ_id              in number  default null,
       p_per_in_ler_id          in number  default null,
       p_ler_id                 in number  default null,
       p_bnft_amt               in number  default null,
       p_business_group_id      in number  default null,
       p_mode                   in varchar2 default null
     );

end ben_determine_actual_premium;

/
