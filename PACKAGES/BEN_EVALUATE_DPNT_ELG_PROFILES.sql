--------------------------------------------------------
--  DDL for Package BEN_EVALUATE_DPNT_ELG_PROFILES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EVALUATE_DPNT_ELG_PROFILES" AUTHID CURRENT_USER as
/* $Header: bendpelg.pkh 120.0.12010000.2 2008/08/05 14:40:22 ubhat ship $ */
-----------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+


Name
	Manage Dependent Eligibility
Purpose
	This package is used to determine if a specific dependent is eligible for
      a specific electable choice for a participant.  It returns the eligibility
      in the p_dependent_eligible_flag as an out nocopy parameter.
History
	Date             Who           Version    What?
	----             ---           -------    -----
        09 Apr 98        M Rosen/JM    110.0      Created.
        16 Apr 98        M Rosen/JM               Added age calulation
        03 Jun 98        J Mohapatra              Replaced age calculation with a new
                                                  procedure call.
        21 Dec 98        jcarpent      115.2      added get_elig_change_dt function
        18 Jan 99        G Perry       115.3      LED V ED
        31 May 99        S Tee         115.4      New eligibility crteria
                                                  BEN_DPNT_ANTHR_PL_CVG_F
                                                  BEN_DSGNTR_ENRLD_CVG_F.
        30 Aug 99        maagrawa      115.5      Added p_dpnt_inelig_rsn_cd
                                                  to procedure main.
                                                  Added p_inelig_rsn_cd
                                                  to all check procedures.
        31 Mar 00        maagrawa      115.6      Added optional parameter
                                                  p_dpnt_cvg_strt_dt.(4929)
        26 Jun 00        gperry        115.7      Added p_contact_person_id
                                                  to check_age_elig so that
                                                  we drive off the correct
                                                  person for dependent info.
        27 Apr 08        stee          115.9      Added p_contact_person_id
                                                  to check_contact_elig
                                                  - Bug 6956648.
 */
-----------------------------------------------------------------------
g_package         varchar2(80) := 'bendpelg';
--
procedure main
	  (p_contact_relationship_id  in number,
	   p_contact_person_id        in number,
	   p_pgm_id                   in number default null,
	   p_pl_id                    in number,
	   p_ptip_id                  in number default null,
	   p_oipl_id                  in number default null,
	   p_business_group_id        in number,
	   p_per_in_ler_id            in number,
	   p_effective_date           in date,
	   p_lf_evt_ocrd_dt           in date,
           p_dpnt_cvg_strt_dt         in date     default null,
	   p_level                    in varchar2 default null,
	   p_dependent_eligible_flag  out nocopy varchar2,
           p_dpnt_inelig_rsn_cd       out nocopy varchar2);
--
procedure check_age_elig
	 (p_eligy_prfl_id     in number,
	  p_person_id         in number,
	  p_contact_person_id in number,
	  p_pgm_id            in number,
	  p_pl_id             in number,
	  p_oipl_id           in number,
	  p_business_group_id in number,
	  p_per_in_ler_id     in number,
	  p_effective_date    in date,
	  p_lf_evt_ocrd_dt    in date,
	  p_eligible_flag     out nocopy varchar2,
          p_inelig_rsn_cd     out nocopy varchar2) ;
--
procedure check_marital_elig
	 (p_eligy_prfl_id     in number,
	  p_person_id         in number,
	  p_business_group_id in number,
	  p_effective_date    in date,
	  p_lf_evt_ocrd_dt    in date,
	  p_marital_cd        in varchar2,
	  p_eligible_flag     out nocopy varchar2,
          p_inelig_rsn_cd     out nocopy varchar2) ;
--
procedure check_military_elig
	 (p_eligy_prfl_id     in number,
	  p_person_id         in number,
	  p_business_group_id in number,
	  p_effective_date    in date,
	  p_lf_evt_ocrd_dt    in date,
	  p_military_service  in varchar2,
	  p_eligible_flag     out nocopy varchar2,
          p_inelig_rsn_cd     out nocopy varchar2) ;
--
procedure check_student_elig
	 (p_eligy_prfl_id     in number,
	  p_person_id         in number,
	  p_business_group_id in number,
	  p_effective_date    in date,
	  p_lf_evt_ocrd_dt    in date,
	  p_student_status    in varchar2,
	  p_eligible_flag     out nocopy varchar2,
          p_inelig_rsn_cd     out nocopy varchar2) ;
--
procedure check_contact_elig
	 (p_eligy_prfl_id     in number,
	  p_person_id         in number,
	  p_contact_person_id in number,
	  p_business_group_id in number,
	  p_effective_date    in date,
	  p_lf_evt_ocrd_dt    in date,
	  p_contact_type      in varchar2,
	  p_eligible_flag     out nocopy varchar2,
          p_inelig_rsn_cd     out nocopy varchar2) ;
--
procedure check_disabled_elig
	 (p_eligy_prfl_id     in number,
	  p_person_id         in number,
	  p_business_group_id in number,
	  p_effective_date    in date,
	  p_lf_evt_ocrd_dt    in date,
	  p_per_dsbld_type    in varchar2,
          p_eligible_flag     out nocopy varchar2,
          p_inelig_rsn_cd     out nocopy varchar2);
--
procedure check_postal_elig
	 (p_eligy_prfl_id     in number,
	  p_person_id         in number,
	  p_business_group_id in number,
	  p_effective_date    in date,
	  p_lf_evt_ocrd_dt    in date,
	  p_postal_code       in varchar2,
	  p_eligible_flag     out nocopy varchar2,
          p_inelig_rsn_cd     out nocopy varchar2);
--
procedure check_cvrd_anthr_pl_elig
	 (p_eligy_prfl_id     in number,
	  p_person_id         in number,
	  p_business_group_id in number,
	  p_effective_date    in date,
	  p_lf_evt_ocrd_dt    in date,
	  p_pl_id             in number,
	  p_eligible_flag     out nocopy varchar2,
          p_inelig_rsn_cd     out nocopy varchar2);
--
procedure check_dsgntr_enrld_cvg_elig
	 (p_eligy_prfl_id     in number,
	  p_person_id         in number,
	  p_dsgntr_id         in number,
	  p_business_group_id in number,
	  p_effective_date    in date,
	  p_lf_evt_ocrd_dt    in date,
	  p_pgm_id            in number,
	  p_eligible_flag     out nocopy varchar2,
          p_inelig_rsn_cd     out nocopy varchar2);
--
function get_elig_change_dt return date;
--
END;

/
