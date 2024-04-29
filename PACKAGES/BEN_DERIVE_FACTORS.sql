--------------------------------------------------------
--  DDL for Package BEN_DERIVE_FACTORS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DERIVE_FACTORS" AUTHID CURRENT_USER as
/* $Header: bendefct.pkh 120.0.12000000.1 2007/01/19 15:39:49 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA	  	           |
|			        All rights reserved.			           |
+==============================================================================+
Name:
    Derive Factors (external version)

Purpose:
    This program determines values for the six 'derivable factors' for a given person.
    For example DETERMINE_AGE will calculate the input persons age as of the age factor date.
    Each procedure can be called externally.

History:
    Date       Who             Version  What?
    ----       ---             -------  -----
    21 May 98  Ty Hayden       110.0    Created.
    25 Aug 98  J K Mohapatra   115.2    Added LOS and COMB_AGE_LOS Procedures.
    21 Dec 98  jcarpent        115.3    Added p_change_date to det age
    18 Jan 99  G Perry         115.4    LED V ED
    09 Mar 99  G Perry         115.5    IS to AS.
    10 Sep 99  maagrawa        115.6    Added p_start_date to determine_los
    14 Mar 00  maagrawa        115.7    Added p_calc_bal_to_date to
                                        determine_compensation.
    29 May 00  mhoyes          115.8  - Added p_per_dob to
                                        determine_age.
    26 Jun 00  gperry          115.9    Added p_parent_person_id to
                                        determine_age process.
    07 Dec 00  rchase          115.10 - Bug 1518211.
                                        Make p_per_dob an in/out parm.
    26 Mar 02  kmahendr        115.11 - Bug#1833008 - Added a parameter to p_cal_for to
                                        determine_compensation.
    16 Dec 02  hnarayan        115.12   Added NOCOPY hint
    18 Apr 04  mmudigon        115.13   Universal Eligibility
    13 Aug 04  tjesumic        115.14   fonm parameter added
*/
--------------------------------------------------------------------------------
PROCEDURE determine_compensation
      (p_comp_lvl_fctr_id     in  number,
       p_person_id            in  number,
       p_pgm_id               in  number  default null,
       p_pl_id                in  number  default null,
       p_oipl_id              in  number  default null,
       p_comp_obj_mode        in  boolean default true,
       p_per_in_ler_id        in  number,
       p_business_group_id    in  number,
       p_perform_rounding_flg in  boolean default true,
       p_effective_date       in  date,
       p_lf_evt_ocrd_dt       in  date    default null,
       p_fonm_cvg_strt_dt     in  date    default null,
       p_fonm_rt_strt_dt      in  date    default null,
       p_calc_bal_to_date     in  date    default null,
       p_cal_for              in  varchar2 default null,
       p_value                out nocopy number);
--
PROCEDURE determine_age
      (p_person_id            in  number
      --RCHASE out added
      ,p_per_dob           in out nocopy date
      --End RCHASE
      ,p_age_fctr_id          in  number
      ,p_pgm_id               in  number  default null
      ,p_pl_id                in  number  default null
      ,p_oipl_id              in  number  default null
      ,p_comp_obj_mode        in  boolean default true
      ,p_per_in_ler_id        in  number
      ,p_effective_date       in  date
      ,p_lf_evt_ocrd_dt       in  date    default null
      ,p_fonm_cvg_strt_dt     in  date    default null
      ,p_fonm_rt_strt_dt      in  date    default null
      ,p_business_group_id    in  number
      ,p_perform_rounding_flg in  boolean default true
      ,p_value                out nocopy number
      ,p_change_date          out nocopy date
      ,p_parent_person_id     in  number  default null);
--
PROCEDURE determine_los
      (p_person_id            in  number,
       p_los_fctr_id          in  number,
       p_pgm_id               in  number  default null,
       p_pl_id                in  number  default null,
       p_oipl_id              in  number  default null,
       p_comp_obj_mode        in  boolean default true,
       p_per_in_ler_id        in  number,
       p_effective_date       in  date,
       p_lf_evt_ocrd_dt       in  date    default null,
       p_fonm_cvg_strt_dt     in  date    default null,
       p_fonm_rt_strt_dt      in  date    default null,
       p_business_group_id    in  number,
       p_perform_rounding_flg in  boolean default true,
       p_value                out nocopy number,
       p_start_date           out nocopy date);
--
PROCEDURE determine_comb_age_los
      (p_person_id            in  number,
       p_cmbn_age_los_fctr_id in  number,
       p_pgm_id               in  number  default null,
       p_pl_id                in  number  default null,
       p_oipl_id              in  number  default null,
       p_comp_obj_mode        in  boolean default true,
       p_per_in_ler_id        in  number,
       p_effective_date       in  date,
       p_lf_evt_ocrd_dt       in  date    default null,
       p_fonm_cvg_strt_dt     in  date    default null,
       p_fonm_rt_strt_dt      in  date    default null,
       p_business_group_id    in  number,
       p_value                out nocopy number);
--
procedure determine_hours_worked
  (p_person_id            in number,
   p_assignment_id        in number,
   p_hrs_wkd_in_perd_fctr_id in number,
   p_pgm_id               in number default null,
   p_pl_id                in number default null,
   p_oipl_id              in number default null,
   p_comp_obj_mode        in boolean  default true,
   p_per_in_ler_id        in number default null,
   p_effective_date       in date,
   p_lf_evt_ocrd_dt       in date,
   p_fonm_cvg_strt_dt     in  date    default null,
   p_fonm_rt_strt_dt      in  date    default null,
   p_business_group_id    in number,
   p_value                out nocopy number);
    --
procedure determine_pct_fulltime
  (p_person_id            in number,
   p_assignment_id        in number,
   p_pct_fl_tm_fctr_id    in number,
   p_effective_date       in date,
   p_lf_evt_ocrd_dt       in date,
   p_fonm_cvg_strt_dt     in  date    default null,
   p_fonm_rt_strt_dt      in  date    default null,
   p_comp_obj_mode        in boolean  default true,
   p_business_group_id    in number,
   p_value                out nocopy number);
    --

end ben_derive_factors;

 

/
