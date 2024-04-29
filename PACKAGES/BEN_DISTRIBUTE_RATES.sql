--------------------------------------------------------
--  DDL for Package BEN_DISTRIBUTE_RATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DISTRIBUTE_RATES" AUTHID CURRENT_USER as
/* $Header: bendisrt.pkh 120.1.12010000.1 2008/07/29 12:10:00 appldev ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1997 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
   Convert Rates (or say Distribute rates)
Purpose
   This package is mostly used to convert rates from annual to per period
   and vice-versa. The procedures annual_to_period and period_to_annual
   are used for this. The other procedure get_periods_between gets the
   number of activity periods between two dates.

   The procedures annual_to_period and period_to_annual are mostly used
   to convert rate amounts. When the complete year flag is on, the start
   date and end date are the plan year start and end date respectively.

   When the complete year flag is off, then the start date is the rate
   start date (if enrt_rt_id is supplied) or the coverage start date
   (if the elig_per_elctbl_chc_id is supplied). The end date is still the
   plan year end date. As the procedure is mostly used to convert rates,
   it is advisable to use rate start date as the starting period, so in
   other words, it is highly recommended to pass in the enrt_rt_id rather
   than elig_per_elctbl_chc_id.

   If the start date and end dates are passed in, then the dates are not
   overridden (except in case when the complete year flag is ON).

History
        Date             Who        Version    What?
        ----             ---        -------    -----
        23 Sep 98        maagrawa   115.0      Created.
        18 Jan 99        G Perry    115.1      LED V ED
        28 Sep 99        lmcdonal   115.2      Added Compare_Balances,
                                               Prorate_min_max procedures.
        21 Apr 00        jcarpent   115.3      Changed parms to get_periods..
        22 Sep 00        mhoyes     115.4    - Added clear_down_cache to clear
                                               function cache.
        07 Nov 00        mhoyes     115.5    - Added set_no_cache_context.
        03 jan 01        tilak      115.6    - getbalance function changed as global function
        03 Nov 01        tmathers   115.7    - added decde_bits and dbdrv line.
        21 Apr 02        ashrivas   115.8    - Added convert_rates_w for self-service
        23 May 02        kmahendr   115.10    - Added a procedure - annual_to_period_out
        23 May 02                   115.11     No changes
        15 Oct 02        kmahendr   115.12     Added overloaded function - get_periods_between
                                               and added parameter to annual_to_period -
                                               Bug#2556948
        16-Dec-03        kmullapu   115.13     Bug 2745691.Added convert_pcr_rates_w
        23-Jan-03        ikasire    115.15     Bug 2149438 added overloaded procedure to
                                               control rounding
        26-Jun-03        lakrish    115.16     Bug 2992321, made ann_rt_val parameters
                                               as IN OUT in convert_pcr_rates_w
        13-Oct-03        rpillay    115.17     Bug 3097501 - Externalized procedure
                                               estimate_balance for COBRA. Called
                                               from bencobra.pkb
        31-oct-03        kmahendr   115.18     Bug#3231548 - added additional parameter to
                                               get_periods_between
        18-Mar-04        ikasire    115.19     Bug periodize_with_rule procedure to use
                                                formula for periodization
        26-Apr-04        kmahendr   115.20     Added parameter person_id to annual_to_period
                                               function
        21-Mar-06        vborkar    115.21     5104247 Added p_child_rt_flag parameters to
				                                       convert_pcr_rates_w procedure.
--
*/
--
--
-- This function returns the number of activity periods between
-- two dates. If the end date supplied is null, it is defaulted
-- to end of the calendar year.
--
-- Return value is number and rounded to the first decimal
--  e.g: 1.232 becomes 1.2; 5.47 becomes 5.5;
--
function get_periods_between(
                            p_acty_ref_perd_cd in varchar2,
                            p_start_date       in date,
                            p_end_date         in date default null,
                            p_payroll_id       in number default null,
                            p_business_group_id in number default null,
                            p_element_type_id  in number default null,
                            p_enrt_rt_id       in number default null,
                            p_effective_date   in date default null,
                            p_called_from_est  in boolean default false
                            ) return number;

-- overloaded the function to calculate periods based on cheque dates

function get_periods_between(
                            p_acty_ref_perd_cd in varchar2,
                            p_start_date       in date,
                            p_end_date         in date default null,
                            p_payroll_id       in number default null,
                            p_business_group_id in number default null,
                            p_element_type_id  in number default null,
                            p_enrt_rt_id       in number default null,
                            p_effective_date   in date default null,
                            p_use_check_date   in boolean
                            ) return number;

--
-- This function is used to convert the period amount to annual amount
-- The annual period is computed as the period between the start date
-- and end date. When the complete year flag is on, the start date and
-- end date are overridden by plan year start and end date respectively.
--
function period_to_annual(p_amount                 in number,
                          p_enrt_rt_id             in number default null,
                          p_elig_per_elctbl_chc_id in number default null,
                          p_acty_ref_perd_cd       in varchar2 default null,
                          p_business_group_id      in number default null,
                          p_effective_date         in date default null,
                          p_lf_evt_ocrd_dt         in date default null,
                          p_complete_year_flag     in varchar2 default 'N',
                          p_use_balance_flag       in varchar2 default 'N',
                          p_start_date             in date default null,
                          p_end_date               in date default null,
                          p_payroll_id             in number default null,
                          p_element_type_id        in number default null)
return number;
--
-- Overloaded procedure without rounding. This can be removed once the
-- hard coded rounding is removed and it is better to handle in the called
-- procedures depending on the requirement.
-- This is because we don't want to round the computed values some times.
-- like in case of SAREC, for element entries see Bug 2149438
--
function period_to_annual(p_amount                 in number,
                          p_enrt_rt_id             in number default null,
                          p_elig_per_elctbl_chc_id in number default null,
                          p_acty_ref_perd_cd       in varchar2 default null,
                          p_business_group_id      in number default null,
                          p_effective_date         in date default null,
                          p_lf_evt_ocrd_dt         in date default null,
                          p_complete_year_flag     in varchar2 default 'N',
                          p_use_balance_flag       in varchar2 default 'N',
                          p_start_date             in date default null,
                          p_end_date               in date default null,
                          p_payroll_id             in number default null,
                          p_element_type_id        in number default null,
                          p_rounding_flag          in varchar2  )
return number;

--
-- This function is used to convert the annual amount to period amount
-- The annual period is computed as the period between the start date
-- and end date. When the complete year flag is on, the start date and
-- end date are overridden by plan year start and end date respectively.
--
function annual_to_period(p_amount                 in number,
                          p_enrt_rt_id             in number default null,
                          p_elig_per_elctbl_chc_id in number default null,
                          p_acty_ref_perd_cd       in varchar2 default null,
                          p_business_group_id      in number default null,
                          p_effective_date         in date default null,
                          p_lf_evt_ocrd_dt         in date default null,
                          p_complete_year_flag     in varchar2 default 'N',
                          p_use_balance_flag       in varchar2 default 'N',
                          p_start_date             in date default null,
                          p_end_date               in date default null,
                          p_payroll_id             in number default null,
                          p_element_type_id        in number default null,
                          p_annual_target          in boolean default false,
                          p_person_id              in number  default null)
return number;
--
-- Overloaded procedure without rounding. This can be removed once the
-- hard coded rounding is removed and it is better to handle in the called
-- procedures depending on the requirement.
-- This is because we don't want to round the computed values some times.
-- like in case of SAREC, for element entries see Bug 2149438
--
function annual_to_period(p_amount                 in number,
                          p_enrt_rt_id             in number default null,
                          p_elig_per_elctbl_chc_id in number default null,
                          p_acty_ref_perd_cd       in varchar2 default null,
                          p_business_group_id      in number default null,
                          p_effective_date         in date default null,
                          p_lf_evt_ocrd_dt         in date default null,
                          p_complete_year_flag     in varchar2 default 'N',
                          p_use_balance_flag       in varchar2 default 'N',
                          p_start_date             in date default null,
                          p_end_date               in date default null,
                          p_payroll_id             in number default null,
                          p_element_type_id        in number default null,
                          p_annual_target          in boolean default false,
                          p_rounding_flag          in varchar2,
                          p_person_id              in number  default null)
return number;
--
function annual_to_period_out(p_amount                 in number,
                          p_enrt_rt_id             in number default null,
                          p_elig_per_elctbl_chc_id in number default null,
                          p_acty_ref_perd_cd       in varchar2 default null,
                          p_business_group_id      in number default null,
                          p_effective_date         in date default null,
                          p_lf_evt_ocrd_dt         in date default null,
                          p_complete_year_flag     in varchar2 default 'N',
                          p_use_balance_flag       in varchar2 default 'N',
                          p_start_date             in date default null,
                          p_end_date               in date default null,
                          p_payroll_id             in number default null,
                          p_element_type_id        in number default null,
                          p_pp_in_yr_used_num      out nocopy number)
return number;



procedure compare_balances
          (p_person_id            in number
          ,p_effective_date       in date
          ,p_lf_evt_ocrd_dt       in date default null
          ,p_elig_per_elctbl_chc_id in number default null
          ,p_pgm_id               in number default null
          ,p_pl_id                in number default null
          ,p_oipl_id              in number default null
          ,p_per_in_ler_id        in number default null
          ,p_business_group_id    in number default null
          ,p_acty_base_rt_id      in number
          ,p_perform_edit_flag    in varchar2 default 'N'
          ,p_entered_ann_val      in number default null
          ,p_ann_mn_val           in out nocopy number
          ,p_ann_mx_val           in out nocopy number
          ,p_ptd_balance          out nocopy number
          ,p_clm_balance          out nocopy number) ;

procedure prorate_min_max
          (p_person_id                in number
          ,p_effective_date           in date
          ,p_elig_per_elctbl_chc_id   in number
          ,p_acty_base_rt_id          in number
          ,p_rt_strt_dt               in date
          ,p_ann_mn_val               in out nocopy number
          ,p_ann_mx_val               in out nocopy number ) ;



function get_balance
                   (p_enrt_rt_id           in number   default null,
                    p_person_id            in number   default null,
                    p_per_in_ler_id        in number   default null,
                    p_pgm_id               in number   default null,
                    p_pl_id                in number   default null,
                    p_oipl_id              in number   default null,
                    p_enrt_perd_id         in number   default null,
                    p_lee_rsn_id           in number   default null,
                    p_acty_base_rt_id      in number   default null,
                    p_payroll_id           in number   default null,
                    p_ptd_comp_lvl_fctr_id in number   default null,
                    p_det_pl_ytd_cntrs_cd  in varchar2 default null,
                    p_lf_evt_ocrd_dt       in date default null,
                    p_business_group_id    in number,
                    p_start_date           in date,
                    p_end_date             in date     default null,
                    p_effective_date       in date)
return number ;


procedure clear_down_cache;

procedure set_no_cache_context;

function decde_bits(p_number IN NUMBER) return NUMBER;

procedure convert_rates_w(p_person_id              in number,
                          p_amount                 in number,
                          p_enrt_rt_id             in number default null,
                          p_elig_per_elctbl_chc_id in number default null,
                          p_acty_ref_perd_cd       in varchar2 default null,
                          p_cmcd_acty_ref_perd_cd  in varchar2 default null,
                          p_business_group_id      in number default null,
                          p_effective_date         in date default null,
                          p_lf_evt_ocrd_dt         in date default null,
                          p_complete_year_flag     in varchar2 default 'N',
                          p_use_balance_flag       in varchar2 default 'N',
                          p_start_date             in date default null,
                          p_end_date               in date default null,
                          p_payroll_id             in number default null,
                          p_element_type_id        in number default null,
                          p_convert_from_rt        in varchar2,
                          p_ann_rt_val             out nocopy number,
                          p_cmcd_rt_val            out nocopy number,
                          p_val                    out nocopy number  );

--
-- Child rate refresh when parent value is modified
--

procedure convert_pcr_rates_w(
                           p_person_id              in number,
                           p_amount                 in number,
                           p_rate_index             in number,
                           p_prnt_acty_base_rt_id   in number,
                           p_enrt_rt_id             in number default null,
                           p_enrt_rt_id2            in number default null,
                           p_enrt_rt_id3            in number default null,
                           p_enrt_rt_id4            in number default null,
                           p_elig_per_elctbl_chc_id in number default null,
                           p_acty_ref_perd_cd       in varchar2 default null,
                           p_cmcd_acty_ref_perd_cd  in varchar2 default null,
                           p_business_group_id      in number default null,
                           p_effective_date         in date default null,
                           p_lf_evt_ocrd_dt         in date default null,
                           p_use_balance_flag       in varchar2 default 'N',
                           p_start_date             in date default null,
                           p_end_date               in date default null,
                           p_payroll_id             in number default null,
                           p_element_type_id        in number default null,
                           p_convert_from_rt        in varchar2,
                           p_ann_rt_val             in out nocopy number,
                           p_cmcd_rt_val            out nocopy number,
                           p_val                    out nocopy number,
                           p_child_rt_flag          out nocopy varchar2, --5104247
                           p_ann_rt_val2            in out nocopy number,
                           p_cmcd_rt_val2           out nocopy number,
                           p_val2                   out nocopy number,
                           p_child_rt_flag2         out nocopy varchar2,
                           p_ann_rt_val3            in out nocopy number,
                           p_cmcd_rt_val3           out nocopy number,
                           p_val3                   out nocopy number,
                           p_child_rt_flag3         out nocopy varchar2,
                           p_ann_rt_val4            in out nocopy number,
                           p_cmcd_rt_val4           out nocopy number,
                           p_val4                   out nocopy number,
                           p_child_rt_flag4         out nocopy varchar2 );


procedure estimate_balance
            (p_person_id             in number,
             p_acty_base_rt_id       in number,
             p_payroll_id            in number,
             p_effective_date        in date,
             p_business_group_id     in number,
             p_date_from             in date,
             p_date_to               in date,
             p_balance               out nocopy number);
--
procedure periodize_with_rule
            (p_formula_id             in number,
             p_effective_date         in date,
             p_assignment_id          in number,
             p_convert_from_val       in number,
             p_convert_from           in varchar2,
             p_elig_per_elctbl_chc_id in number,
             p_acty_base_rt_id        in number,
             p_business_group_id      in number,
             p_enrt_rt_id             in number default null,
             p_ann_val                out nocopy number,
             p_cmcd_val               out nocopy number,
             p_val                    out nocopy number  );
--
end ben_distribute_rates;

/
