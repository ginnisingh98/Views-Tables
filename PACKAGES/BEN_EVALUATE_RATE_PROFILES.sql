--------------------------------------------------------
--  DDL for Package BEN_EVALUATE_RATE_PROFILES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EVALUATE_RATE_PROFILES" AUTHID CURRENT_USER as
/* $Header: benrtprf.pkh 120.0.12010000.1 2008/07/29 12:31:03 appldev ship $ */
--
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+
--
Name
	Variable Rate Profiles
Purpose
        This package is used to determine benefit rates based on
        profiles or rules associated with any person.
History
        Date             Who         Version    What?
        -- --             ---        -------    -----
        07 Apr 98        T Guy        110.00    Created.
        26 Aug 98        G Perry      115.2     Added header line.
        22 Dec 98        T Guy        115.3     Added hrs_wrk, pct_fulltime
        18 Jan 99        G Perry      115.4      LED V ED
        09 Mar 99        T Mathers    115.5     Moved arcs header.
        01 May 99        Shdas        115.6     Added parameters to check_rules.
        27 may 99        maagrawa     115.7     Modified procedures to work
                                                without a choice.
        01 Jul 99        lmcdonal     115.8     Added check_ttl_prtt, check_ttl_cvg
        03 Aug 99        lmcdonal     115.19    Add global rec structure.  Add two
        18 Aug 99        stee         115.20    Removed change_reason from
                                                check_loa_rsn.
        02 Nov 99        G Perry      115.12    Fixed procedure check_per_typ
                                                to use all person type usages.
        11 Nov 99        T Guy        115.13    Fixed parameters for derived fctrs
        17 Nov 99        pbodla       115.14    Added acty_base_rt_id as parameter to
                                                 check_rules
        19 Nov 99        pbodla       115.15    Added p_elig_per_elctbl_chc_id as
                                                parameter to check_rules
        27 Feb 00        lmcdonal     115.16    Added the profile flags to g_all_prfls
                                                so that premium calcs will work.
        27 Feb 00        lmcdonal     115.17    Ensure the second call to load
                                                globals is only done when needed
                                                by adding new parm.
        29 Feb 00        lmcdonal     115.18    Bug 1220070. Added opt_id to
                                                check_hrs_wkd, check_pct_fltm.
        03 Mar 00        stee         115.19    Added pgm_id and pl_typ_id
                                                to check_period_of_enrollment
                                                for cobra by plan type.
        06 Apr 00        lmcdonal     115.20    Make Check procedures private.
        29 May 00        mhoyes       115.21  - Added defaulted record structures
                                                to main.
        28 Jun 00        mhoyes       115.22  - Added epe record to main.
        11 Jan 01        ikasire      115.23    Bug 1566944 Added p_ler_id parameter to the
                                                procedure check_period_of_enrollment
        20 Sep 01        mhoyes       115.24  - Bug 1955152. Made g_profile_failed
                                                and check_service_area public.
	05-Jun-02 	 vsethi       115.25    Added code to handle the new rates flags
	12-Jun-02 	 vsethi       115.26    Added code to handle the quartile and
						performance rating
	24-Sep-02 	 vsethi       115.28  - commented all the private procedure,
						modified the call for check_sched_hrs

       30-dec-2002        hmani       115.29		NoCopy changes
       24-Jul-2003        mmudigon    115.30    Added rt_elig_prfl_flag to
                                                g_all_prfls_rec
*/

-- ------------------------------------------------------------------------------
--
-- Exceptions
--
g_profile_failed exception;
--
type g_all_prfls_rec is record
(vrbl_rt_prfl_id             number,
 match_cnt                   number,
 match_cvg                   number,
 val                         number,
  asmt_to_use_cd             varchar(30),
  rt_hrly_slrd_flag          varchar(30),
  rt_pstl_cd_flag            varchar(30),
  rt_lbr_mmbr_flag           varchar(30),
  rt_lgl_enty_flag           varchar(30),
  rt_benfts_grp_flag         varchar(30),
  rt_wk_loc_flag             varchar(30),
  rt_brgng_unit_flag         varchar(30),
  rt_age_flag                varchar(30),
  rt_los_flag                varchar(30),
  rt_per_typ_flag            varchar(30),
  rt_fl_tm_pt_tm_flag        varchar(30),
  rt_ee_stat_flag            varchar(30),
  rt_grd_flag                varchar(30),
  rt_pct_fl_tm_flag          varchar(30),
  rt_asnt_set_flag           varchar(30),
  rt_hrs_wkd_flag            varchar(30),
  rt_comp_lvl_flag           varchar(30),
  rt_org_unit_flag           varchar(30),
  rt_loa_rsn_flag            varchar(30),
  rt_pyrl_flag               varchar(30),
  rt_schedd_hrs_flag         varchar(30),
  rt_py_bss_flag             varchar(30),
  rt_prfl_rl_flag            varchar(30),
  rt_cmbn_age_los_flag       varchar(30),
  rt_prtt_pl_flag            varchar(30),
  rt_svc_area_flag           varchar(30),
  rt_ppl_grp_flag            varchar(30),
  rt_dsbld_flag              varchar(30),
  rt_hlth_cvg_flag           varchar(30),
  rt_poe_flag                varchar(30),
  rt_ttl_cvg_vol_flag        varchar(30),
  rt_ttl_prtt_flag           varchar(30),
  rt_gndr_flag               varchar(30),
  rt_tbco_use_flag           varchar(30),
  rt_cntng_prtn_prfl_flag    varchar(30),
  rt_cbr_quald_bnf_flag      varchar(30),
  rt_optd_mdcr_flag          varchar(30),
  rt_lvg_rsn_flag            varchar(30),
  rt_pstn_flag               varchar(30),
  rt_comptncy_flag           varchar(30),
  rt_job_flag                varchar(30),
  rt_qual_titl_flag          varchar(30),
  rt_dpnt_cvrd_pl_flag       varchar(30),
  rt_dpnt_cvrd_plip_flag     varchar(30),
  rt_dpnt_cvrd_ptip_flag     varchar(30),
  rt_dpnt_cvrd_pgm_flag      varchar(30),
  rt_enrld_oipl_flag         varchar(30),
  rt_enrld_pl_flag           varchar(30),
  rt_enrld_plip_flag         varchar(30),
  rt_enrld_ptip_flag         varchar(30),
  rt_enrld_pgm_flag          varchar(30),
  rt_prtt_anthr_pl_flag      varchar(30),
  rt_othr_ptip_flag          varchar(30),
  rt_no_othr_cvg_flag        varchar(30),
  rt_dpnt_othr_ptip_flag     varchar(30),
  rt_qua_in_gr_flag          varchar(30),
  rt_perf_rtng_flag          varchar(30),
  rt_elig_prfl_flag          varchar(30));

type g_all_prfls_table is table of g_all_prfls_rec
  index by binary_integer;

g_all_prfls            g_all_prfls_table;
g_no_match_cnt         number ;
g_no_match_cvg         number ;

g_use_prfls            g_all_prfls_table;
g_num_of_prfls_used    number ;
--
 procedure init_globals ;

 procedure main
   (p_currepe_row            in ben_determine_rates.g_curr_epe_rec
    := ben_determine_rates.g_def_curr_epe_rec
   ,p_per_row                   in per_all_people_F%rowtype
   := ben_determine_rates.g_def_curr_per_rec
   ,p_asg_row                   in per_all_assignments_f%rowtype
    := ben_determine_rates.g_def_curr_asg_rec
   ,p_ast_row                   in per_assignment_status_types%rowtype
    := ben_determine_rates.g_def_curr_ast_rec
   ,p_adr_row                   in per_addresses%rowtype
    := ben_determine_rates.g_def_curr_adr_rec
   ,p_person_id                 in number
   ,p_elig_per_elctbl_chc_id	in number
   ,p_acty_base_rt_id           in number  default null
   ,p_actl_prem_id              in number  default null
   ,p_cvg_amt_calc_mthd_id      in number  default null
   ,p_effective_date            in date
   ,p_lf_evt_ocrd_dt            in date    default null
   ,p_calc_only_rt_val_flag     in boolean default false
   ,p_pgm_id                    in number  default null
   ,p_pl_id                     in number  default null
   ,p_pl_typ_id                 in number  default null
   ,p_oipl_id                   in number  default null
   ,p_per_in_ler_id             in number  default null
   ,p_ler_id                    in number  default null
   ,p_business_group_id         in number  default null
   ,p_ttl_prtt                  in number  default null
   ,p_ttl_cvg                   in number  default null
   ,p_all_prfls                 in boolean default false
   ,p_use_globals               in boolean default false
   ,p_use_prfls                 in boolean default false
   ,p_bnft_amt                  in number  default null
   ,p_vrbl_rt_prfl_id           out nocopy number
   );
/*
 procedure check_brgng_unit
           (p_vrbl_rt_prfl_id           in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date,
            p_bargaining_unit_code      in varchar2);
--
 procedure check_benefits_grp
           (p_vrbl_rt_prfl_id           in number,
            p_person_id                 in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date,
            p_benefit_group_id          in number);
--
 procedure check_ee_stat
           (p_vrbl_rt_prfl_id           in number,
            p_person_id                 in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date,
            p_assignment_status_type_id in number);
--
 procedure check_fl_tm_pt
           (p_vrbl_rt_prfl_id           in number,
            p_person_id                 in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date default null,
            p_employment_category       in varchar2);
--
 procedure check_grade
           (p_vrbl_rt_prfl_id           in number,
            p_person_id                 in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date,
            p_grade_id                  in number);
--
 procedure check_hrs_wkd
           (p_vrbl_rt_prfl_id	        in number,
            p_person_id                 in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date default null,
            p_elig_per_elctbl_chc_id    in number,
            p_opt_id                    in number default null,
            p_pl_id                     in number default null,
            p_pgm_id                    in number default null);
--
 procedure check_period_of_enrollment
           (p_vrbl_rt_prfl_id	        in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date default null,
            p_person_id                 in number,
            p_pgm_id                    in number default null,
            p_pl_typ_id                 in number default null,
            p_ler_id                    in number default null);
--
 procedure check_lbr_union
           (p_vrbl_rt_prfl_id           in number,
            p_person_id                 in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date,
            p_labour_union_member_flag  in varchar2);
--
 procedure check_loa_rsn
           (p_vrbl_rt_prfl_id           in number,
            p_person_id                 in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date);
--
 procedure check_org_unit
           (p_vrbl_rt_prfl_id           in number,
            p_person_id                 in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date,
            p_org_id                    in number);
--
 procedure check_pct_fltm
           (p_vrbl_rt_prfl_id           in number,
            p_person_id                 in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date default null,
            p_elig_per_elctbl_chc_id    in number,
            p_opt_id                    in number default null,
            p_pl_id                     in number default null,
            p_pgm_id                    in number default null);
--
 procedure check_per_typ
           (p_vrbl_rt_prfl_id           in number,
            p_person_id                 in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date,
            p_person_type               in ben_person_object.g_cache_typ_table);
--
 procedure check_zip_code_rng
           (p_vrbl_rt_prfl_id           in number,
            p_person_id                 in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date,
            p_postal_code               in varchar2);
--
 procedure check_pyrl
           (p_vrbl_rt_prfl_id           in number,
            p_person_id         	in number,
            p_business_group_id 	in number,
            p_effective_date    	in date,
            p_lf_evt_ocrd_dt            in date,
            p_payroll_id        	in number);
--
 procedure check_py_bss
           (p_vrbl_rt_prfl_id           in number,
            p_person_id                 in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date,
            p_pay_basis_id              in number);
--
 procedure check_sched_hrs
 	   (p_vrbl_rt_prfl_id           in number
 	   ,p_person_id                 in number
 	   ,p_business_group_id         in number
 	   ,p_effective_date            in date
 	   ,p_lf_evt_ocrd_dt            in date
 	   ,p_normal_hrs                in number
 	   ,p_frequency                 in varchar2
 	   ,p_per_in_ler_id             in number
 	   ,p_assignment_id             in number
 	   ,p_organization_id           in number
 	   ,p_pgm_id                    in number
 	   ,p_pl_id                     in number
 	   ,p_pl_typ_id         	in number
 	   ,p_opt_id            	in number
 	   ,p_oipl_id           	in number
 	   ,p_ler_id            	in number
 	   ,p_jurisdiction_code 	in varchar2   );
--
 procedure check_wk_location
           (p_vrbl_rt_prfl_id           in number,
            p_person_id                 in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date,
            p_location_id               in number);
--
 procedure check_lgl_enty
           (p_vrbl_rt_prfl_id           in number,
            p_person_id                 in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date,
            p_gre_id                    in varchar2);
--
 procedure check_gender
           (p_vrbl_rt_prfl_id           in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date,
            p_sex                       in varchar2);
--
 procedure check_dsbld_cd
           (p_vrbl_rt_prfl_id           in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date,
            p_dsbld_cd                  in varchar2);
--
 procedure check_tobacco
           (p_vrbl_rt_prfl_id           in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date,
            p_tobacco                   in varchar2);

 procedure check_service_area
           (p_vrbl_rt_prfl_id           in number,
            p_person_id                 in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date,
            p_postal_code               in varchar2);
--
 procedure check_hourly_salary
           (p_vrbl_rt_prfl_id           in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date,
            p_hrly_slry                 in varchar2);
--
 procedure check_age
           (p_vrbl_rt_prfl_id           in number,
            p_person_id                 in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date default null,
            p_elig_per_elctbl_chc_id    in number,
            p_pl_id                     in number default null,
            p_pgm_id                    in number default null,
            p_oipl_id                   in number default null,
            p_per_in_ler_id             in number default null);
--
 procedure check_comp_level
           (p_vrbl_rt_prfl_id           in number,
            p_person_id                 in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date,
            p_elig_per_elctbl_chc_id    in number,
            p_pl_id                     in number default null,
            p_pgm_id                    in number default null,
            p_oipl_id                   in number default null,
            p_per_in_ler_id             in number default null);
--
 procedure check_los
           (p_vrbl_rt_prfl_id           in number,
            p_person_id                 in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date default null,
            p_elig_per_elctbl_chc_id    in number,
            p_pl_id                     in number default null,
            p_pgm_id                    in number default null,
            p_oipl_id                   in number default null,
            p_per_in_ler_id             in number default null);

 procedure check_age_los
           (p_vrbl_rt_prfl_id           in number,
            p_person_id                 in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date default null,
            p_elig_per_elctbl_chc_id    in number,
            p_pl_id                     in number default null,
            p_pgm_id                    in number default null,
            p_oipl_id                   in number default null,
            p_per_in_ler_id             in number default null);
--
procedure check_ttl_prtt
  (p_vrbl_rt_prfl_id      in number
  ,p_business_group_id    in number
  ,p_effective_date       in date
  ,p_lf_evt_ocrd_dt       in date
  ,p_ttl_prtt             in number default null);

procedure check_ttl_cvg
  (p_vrbl_rt_prfl_id      in number
  ,p_business_group_id    in number
  ,p_effective_date       in date
  ,p_lf_evt_ocrd_dt       in date
  ,p_ttl_cvg              in number default null);

 procedure check_rules
           (p_vrbl_rt_prfl_id           in number,
            p_business_group_id         in number,
            p_effective_date            in date,
            p_lf_evt_ocrd_dt            in date,
            p_assignment_id             in number,
            p_organization_id           in number,
            p_pgm_id                    in number,
            p_pl_id                     in number,
            p_pl_typ_id                 in number,
            p_opt_id                    in number,
            p_ler_id                    in number,
            p_acty_base_rt_id           in number default null,
            p_elig_per_elctbl_chc_id    in number default null,
            p_jurisdiction_code         in varchar2
		);


procedure check_people_group
  (p_vrbl_rt_prfl_id      in number
  ,p_business_group_id    in number
  ,p_effective_date       in date
  ,p_lf_evt_ocrd_dt       in date
  ,p_people_group_id      in varchar2);

-- --------------------------------------------------
--  Job
-- --------------------------------------------------
procedure check_job(p_vrbl_rt_prfl_id   in number,
                    p_business_group_id in number,
                    p_effective_date    in date,
                    p_lf_evt_ocrd_dt    in date,
                    p_job_id            in number);

-- --------------------------------------------------
--  Opted for Medicare
-- --------------------------------------------------
procedure check_optd_mdcr(p_vrbl_rt_prfl_id    in number,
                    		p_business_group_id in number,
                    		p_effective_date    in date,
	                        p_lf_evt_ocrd_dt    in date,
                    		p_person_id         in number);

-- --------------------------------------------------
--  Leaving Reason
-- --------------------------------------------------
procedure check_lvg_rsn(p_vrbl_rt_prfl_id    in number,
                    	p_business_group_id  in number,
                    	p_effective_date     in date,
                    	p_lf_evt_ocrd_dt     in date,
                    	p_person_id          in number) ;

-- --------------------------------------------------
--  Cobra Qualified Beneficiary
-- --------------------------------------------------
procedure check_cbr_quald_bnf(p_vrbl_rt_prfl_id    in number,
                    	     p_business_group_id  in number,
                    	     p_effective_date     in date,
                    	     p_person_id          in number,
                    	     p_lf_evt_ocrd_dt     in date) ;

-- --------------------------------------------------
--  Position
-- --------------------------------------------------
procedure check_pstn(p_vrbl_rt_prfl_id   in number,
		     p_business_group_id in number,
                     p_asg_position_id   in number,
                     p_effective_date	 in date,
                     p_lf_evt_ocrd_dt	 in date) ;

-- --------------------------------------------------
--  Competency
-- --------------------------------------------------
procedure check_comptncy(p_vrbl_rt_prfl_id   in number,
		     p_business_group_id in number,
                     p_person_id   	 in number,
                     p_effective_date	 date,
                     p_lf_evt_ocrd_dt	 date);

-- --------------------------------------------------
--  Qualification Titile
-- --------------------------------------------------
procedure check_qual_titl(p_vrbl_rt_prfl_id   in number,
		     p_business_group_id in number,
                     p_person_id   	 in number,
                     p_effective_date	 date,
                     p_lf_evt_ocrd_dt	 date);

-- --------------------------------------------------
--  DEPENDENT COVERED OTHER PLAN
-- --------------------------------------------------
procedure check_dpnt_cvrd_othr_pl(p_vrbl_rt_prfl_id    in number,
                    	     p_business_group_id  in number,
                    	     p_effective_date     in date,
                    	     p_person_id          in number ,
                    	     p_lf_evt_ocrd_dt     in date);

-- --------------------------------------------------
--  DEPENDENT COVERED OTHER PLAN IN PROGRAM
-- --------------------------------------------------
procedure check_dpnt_cvrd_othr_plip (p_vrbl_rt_prfl_id    in number,
                    	     p_business_group_id  in number,
                    	     p_effective_date     in date,
                    	     p_person_id          in number ,
                    	     p_lf_evt_ocrd_dt     in date);

-- --------------------------------------------------
--  DEPENDENT COVERED OTHER PLAN TYPE IN PROGRAM
-- --------------------------------------------------
procedure check_dpnt_cvrd_othr_ptip(p_vrbl_rt_prfl_id    in number,
					 p_business_group_id in number,
					 p_effective_date    in date,
				         p_person_id         in number,
                                         p_lf_evt_ocrd_dt    in date) ;

-- --------------------------------------------------
--  DEPENDENT COVERED OTHER PROGRAM
-- --------------------------------------------------
procedure check_dpnt_cvrd_othr_pgm(p_vrbl_rt_prfl_id    in number,
					 p_business_group_id in number,
					 p_effective_date    in date,
					 p_person_id         in number,
                                         p_lf_evt_ocrd_dt    in date) ;

-- --------------------------------------------------
--  ELIGIBLE FOR ANOTHER PLAN
-- --------------------------------------------------
procedure check_prtt_anthr_pl(p_vrbl_rt_prfl_id    in number,
				   p_business_group_id in number,
                                   p_person_id         in number,
                                   p_effective_date    in date,
                                   p_lf_evt_ocrd_dt    in date);

-- --------------------------------------------------
--  ELIGIBLE FOR ANOTHER PLAN TYPE IN PROGRAM
-- --------------------------------------------------
procedure check_othr_ptip
  (p_vrbl_rt_prfl_id   in number
  ,p_business_group_id in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_person_id         in number
  ,p_per_in_ler_id     in number default null ) ;

-- --------------------------------------------------------------------------
--  ENROLLED IN ANOTHER PLAN
-- --------------------------------------------------------------------------
procedure check_enrld_anthr_pl(p_vrbl_rt_prfl_id   in number,
                               p_business_group_id in number,
                               p_pl_id             in number,
                               p_person_id         in number,
                               p_effective_date    in date,
                               p_lf_evt_ocrd_dt    in date)  ;

-- --------------------------------------------------------------------------
--  ENROLLED IN ANOTHER OPTION IN PLAN.
-- --------------------------------------------------------------------------
procedure check_enrld_anthr_oipl(p_vrbl_rt_prfl_id     in number,
                                      p_business_group_id in number,
                                      p_oipl_id           in number,
                                      p_person_id         in number,
                                      p_effective_date    in date,
                                      p_lf_evt_ocrd_dt    in date);

-- --------------------------------------------------------------------------
--  ENROLLED OTHER PLAN TYPE IN PROGRAM.
-- --------------------------------------------------------------------------
procedure check_enrld_anthr_ptip(p_vrbl_rt_prfl_id     in number,
                                      p_business_group_id in number,
                                      p_effective_date    in date,
                                      p_lf_evt_ocrd_dt    in date) ;

-- --------------------------------------------------------------------------
--  ENROLLED IN ANOTHER PLAN IN PROGRAM.
-- --------------------------------------------------------------------------
procedure check_enrld_anthr_plip(p_vrbl_rt_prfl_id     in number,
                                      p_business_group_id in number,
                                      p_person_id         in number,
                                      p_effective_date    in date,
                                      p_lf_evt_ocrd_dt    in date);

-- --------------------------------------------------------------------------
--  ENROLLED IN ANOTHER PROGRAM.
-- --------------------------------------------------------------------------
procedure check_enrld_anthr_pgm
  	( -- p_comp_obj_tree_row in ben_manage_life_events.g_cache_proc_objects_rec ,
  	p_vrbl_rt_prfl_id   in number
  	,p_business_group_id in number
  	,p_pgm_id            in number
  	,p_person_id         in number
  	,p_effective_date    in date
  	,p_lf_evt_ocrd_dt    in date ) ;

-- --------------------------------------------------------------------------
--  DEPENDENT OTHER PLAN TYPE IN PROGRAM
-- --------------------------------------------------------------------------
procedure check_dpnt_othr_ptip
  (p_vrbl_rt_prfl_id   in number
  ,p_business_group_id in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_person_id         in number
  ,p_per_in_ler_id     in number);

-- --------------------------------------------------
--  NO OTHER COVERAGE
-- --------------------------------------------------
procedure check_no_othr_cvg(p_vrbl_rt_prfl_id    in number,
				   p_business_group_id in number,
                                   p_person_id         in number,
                                   p_effective_date    in date,
                                   p_lf_evt_ocrd_dt    in date) ;


-- --------------------------------------------------
--  Quartile in Grade
-- --------------------------------------------------
procedure check_qua_in_gr(p_vrbl_rt_prfl_id   in number,
		     p_business_group_id in number,
                     p_person_id   	 in number,
                     p_grade_id		 in number,
                     p_assignment_id     in number,
                     p_effective_date	 date,
                     p_lf_evt_ocrd_dt	 date);

-- --------------------------------------------------
--  Performance Rating
-- --------------------------------------------------
procedure check_perf_rtng(p_vrbl_rt_prfl_id   in number,
		     p_business_group_id in number,
                     p_assignment_id   	 in number,
                     p_person_id   	 in number,
                     p_effective_date	 date,
                     p_lf_evt_ocrd_dt	 date) ;
*/

end ben_evaluate_rate_profiles;

/
