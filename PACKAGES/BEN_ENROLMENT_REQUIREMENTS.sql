--------------------------------------------------------
--  DDL for Package BEN_ENROLMENT_REQUIREMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENROLMENT_REQUIREMENTS" AUTHID CURRENT_USER as
/* $Header: bendenrr.pkh 120.3 2007/01/12 06:09:37 gsehgal ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
	Determine Enrolment Requirements
Purpose
	This package is used to create enrolment choice entries for all choices
        which a person may elect.
History
	Date		Who		Version  What?
	----		---		-------  -----
	18 Mar 98	jcarpent	110.0    Created
	28 Aug 98	gperry	        115.3    Added global to test if
                                                 an electable choice has
                                                 been created. Bug 1047.
        19 Nov 98       jcarpent        115.5    Removed two date fns
        24 Dec 98       jcarpent        115.6    Changed det_dflt_dt
        18 Jan 99       G Perry         115.7    LED V ED
        08 Feb 99       jcarpent        115.8    Changed determine_erlst_deent
        25 Mar 99       jcarpent        115.9    added assignment_id
                                                 to arg lists
        28 Apr 99	shdas		115.10	 Changed parameter list of
						 determine_erlst_deenrt,
						 execute_enrt_rule,
						 should_create_dpnt_dummy.
        04 May 99       shdas           115.11   added jurisdiction code.
        05 JUL 99       stee            115.12   added dpnt_cvrd_flag
                                                 to determine_enrolment.
        22 Sep 99       jcarpent        115.13   Changed rule args for
                                                 determine_enrolment
        16-Nov-1999     jcarpent        115.14   Added det_dflt_enrt_cd
        05-Jan-2000     jcarpent        115.15   added find_rqd_perd_enrt and
                                                 find_enrt_at_same_level
        21-Jan-2000     pbodla          115.16 - p_elig-per_id is added to
                                                 execute_enrt_rule, determine_enrolment
        23-May-2000     mhoyes          115.17 - Added p_comp_obj_tree_row to
                                                 enrolment_requirements.
        31-May-2000     mhoyes          115.18 - Added current comp object row
                                                 parameters to interfaces.
        28-Jun-2000     shdas           115.19   Added proc execute_auto_dflt_enrt_rule.
        29-Jun-2000     mhoyes          115.20 - Added parent comp object context
                                                 parameters.
        05-Jul-2000     mhoyes          115.21 - Added context parameters.
        13-Jul-2000     mhoyes          115.22 - Removed context parameters.
        19-Jul-2000     jcarpent        115.23 - 5241,1343362. Added update_defaults
        05-Sep-2000     pbodla          115.24 - Bug 5422 : Allow different enrollment periods
                                        for programs for a scheduled  enrollment.
                                        p_popl_enrt_typ_cycl_id is removed.
        07-Dec-2001     mhoyes        - Added p_per_in_ler_id to enrolment_requirements.
        11-Dec-2001     mhoyes        - Added p_per_in_ler_id to update_defaults.
        29-Dec-2001     pbodla        - Added function get_manager_id
        02-Jan-2002     pbodla        - CWB Changes - Added proc get_manager_id
        03-Jan-2002     rpillay         115.28 - added Set Verify Off to avoid GSCC warning
        11-Jan-2002     ikasire         CWB Changes - Bug 2172036
        13-Sep-2003     tjesumic      - # 2534744  New Varaible added to get default amount
                                        from formula for default enrollemnt  used in
                                        bendenrr and bencvrge
        16 Dec 2002     hnarayan        115.31   Added NOCOPY hint
        30 Sep 2004     abparekh        115.32   Added p_run_mode parameter to
                                                 determine_dflt_flag and determine_enrolment
        29 Apr 2005     kmahendr        115.33   Added a parameter - update_def_elct_flag to
                                                 determine_enrolment - bug#4338685
        19 Jan 2006     mhoyes          115.34  bug4960381 - hr_utility tuning.
	26 Jun 2006     swjain          115.35  Bug 5331889 - Added person_id param to execute_auto_dflt_enrt_rule
	                                        and execute_enrt_rule
        09-Nov-06       gsehgal         115.36  Bug 5644451 - Added parameter p_default level
						in proc determine_dflt_flag
*/
------------------------------------------------------------------------------------------------------------------
g_electable_choice_created boolean := false;
g_any_choice_created boolean := false;
g_auto_choice_created boolean := false;
--
g_def_curr_pgm_rec     ben_pgm_f%rowtype;
g_def_curr_ptip_rec    ben_ptip_f%rowtype;
g_def_curr_plip_rec    ben_plip_f%rowtype;
g_def_curr_pl_rec      ben_pl_f%rowtype;
g_def_curr_oipl_rec    ben_cobj_cache.g_oipl_inst_row;
g_def_curr_opt_rec     ben_cobj_cache.g_opt_inst_row;
--
-- CWB Changes :
--
g_ple_hrchy_to_use_cd       varchar2(30);
g_ple_pos_structure_version_id number;
--
-- This variable store the default benefit amount   which is retunr by formual
-- and used by BEN_DETERMINE_COVERAGE
--
g_dflt_elcn_val       ben_enrt_bnft.DFLT_VAL%type ;
  --
  g_debug boolean := hr_utility.debug_enabled;
  --
/*
g_cwb_pl_id                 number;
g_cwb_pgm_id                number;
*/
--
procedure enrolment_requirements
  (p_comp_obj_tree_row      in     ben_manage_life_events.g_cache_proc_objects_rec
  ,p_run_mode               in     varchar2
  ,p_business_group_id      in     number
  ,p_effective_date         in     date
  ,p_lf_evt_ocrd_dt         in     date default null
  ,p_ler_id                 in     number
  ,p_per_in_ler_id          in     number
  ,p_person_id              in     number
  ,p_pl_id                  in     number
  ,p_pgm_id                 in     number default null
  ,p_oipl_id                in     number default null
  ,p_create_anyhow_flag     in     varchar2 default 'N'
  -- 5422 : PB ,p_popl_enrt_typ_cycl_id  in     number default null
  --
  ,p_asnd_lf_evt_dt         in     date default null
  ,p_electable_flag            out nocopy varchar2
  ,p_elig_per_elctbl_chc_id    out nocopy number
  );
-----------------------------------------------------------------------------
function execute_enrt_rule
       (p_opt_id		number,
	p_pl_id			number,
	p_pgm_id		number,
	p_rule_id		number,
	p_ler_id		number,
	p_pl_typ_id		number,
	p_business_group_id	number,
	p_effective_date	date,
        p_lf_evt_ocrd_dt        date default null,
        p_elig_per_id           number default null,
        p_assignment_id         number,
        p_organization_id	number,
        p_jurisdiction_code     varchar2,
	p_person_id             number
        ) return varchar2;
-----------------------------------------------------------------------------
-- CWB Changes.
/**
function get_manager_id
      (p_person_id             in number,
       p_hrchy_to_use_cd       in varchar2,
       p_pos_structure_version_id in number,
       p_effective_date        in date) return number;
*/
procedure get_cwb_manager_and_assignment
      (p_person_id             in number,
       p_hrchy_to_use_cd       in varchar2,
       p_pos_structure_version_id in number,
       p_effective_date        in date,
       p_manager_id            out nocopy number,
       p_assignment_id         out nocopy number);

-----------------------------------------------------------------------------
procedure execute_auto_dflt_enrt_rule
       (p_opt_id                number,
        p_pl_id                 number,
        p_pgm_id                number,
        p_rule_id               number,
        p_ler_id                number,
        p_pl_typ_id             number,
        p_business_group_id     number,
        p_effective_date        date,
        p_lf_evt_ocrd_dt        date default null,
        p_elig_per_id           number default null,
        p_assignment_id         number,
        p_organization_id       number,
        p_jurisdiction_code     varchar2,
	p_person_id             number,
        p_enrt_mthd             out nocopy varchar2,
        p_reinstt_dpnt          out nocopy varchar2
        );
-----------------------------------------------------------------------------
procedure determine_enrolment
  (p_previous_eligibility   varchar2,
   p_crnt_enrt_cvg_strt_dt  date,
   p_dpnt_cvrd_flag         varchar2,
   p_enrt_cd                varchar2,
   p_enrt_rl                number,
   p_enrt_mthd_cd           varchar2,
   p_auto_enrt_mthd_rl      number,
   p_effective_date         date,
   p_lf_evt_ocrd_dt         date default null,
   p_elig_per_id            number default null,
   p_enrt_prclds_chg_flag   varchar2 default 'N',
   p_stl_elig_cant_chg_flag varchar2 default 'N',
   p_tco_chg_enrt_cd        varchar2 default 'CPOO',
   p_pl_id                  number,
   p_pgm_id                 number,
   p_oipl_id                number,
   p_opt_id                 number,
   p_pl_typ_id              number,
   p_person_id              number,
   p_ler_id                 number,
   p_business_group_id      number,
   p_electable_flag         out nocopy varchar2,
   p_assignment_id          number,
   p_run_mode               varchar2 default null,
   p_update_def_elct_flag   varchar2 default null);
-----------------------------------------------------------------------------
procedure determine_dflt_flag
       (p_dflt_flag		varchar2,
	p_dflt_enrt_cd		varchar2,
	p_crnt_enrt_cvg_strt_dt	date,
	p_previous_eligibility	varchar2,
	p_dflt_enrt_rl		number,
	p_oipl_id		number,
	p_pl_id			number,
	p_pgm_id		number,
	p_effective_date	date,
	p_lf_evt_ocrd_dt	date default null,
	p_ler_id		number,
	p_opt_id		number,
	p_pl_typ_id		number,
        p_ptip_id               number,
        p_person_id             number,
	p_business_group_id	number,
        p_assignment_id         number,
        p_deflt_flag            out nocopy varchar2,
        p_reinstt_flag          out nocopy varchar2,
	-- bug 5644451
	p_default_level         varchar2 default null,
        p_run_mode              varchar2 default null);
-----------------------------------------------------------------------------
function determine_erlst_deenrt_dt
       (p_enrt_cvg_strt_dt		date,
	p_rqd_perd_enrt_nenrt_val	number,
	p_rqd_perd_enrt_nenrt_tm_uom	varchar2,
        p_rqd_perd_enrt_nenrt_rl        number,
	p_oipl_id			number,
	p_pl_id				number,
	p_pl_typ_id				number,
	p_opt_id				number,
	p_pgm_id			number,
	p_ler_id			number,
	p_popl_yr_perd_ordr_num		number,
	p_yr_end_dt			date,
	p_effective_date		date,
	p_lf_evt_ocrd_dt		date default null,
        p_person_id                     number,
	p_business_group_id		number,
        p_assignment_id                 number,
        p_organization_id	number,
        p_jurisdiction_code     varchar2
        ) return date;
-----------------------------------------------------------------------------
function should_create_dpnt_dummy(
      p_pl_id             number,
      p_pl_typ_id             number,
      p_opt_id             number,
      p_ler_id            number,
      p_ptip_id           number,
      p_effective_date    date,
      p_lf_evt_ocrd_dt    date default null,
      p_pgm_id            number,
      p_person_id         number,
      p_business_group_id number,
      p_assignment_id     number,
      p_organization_id	  number,
      p_jurisdiction_code     varchar2
      ) return boolean;
-----------------------------------------------------------------------------
procedure determine_dflt_enrt_cd
  (p_oipl_id           in     number
  ,p_plip_id           in     number
  ,p_pl_id             in     number
  ,p_ptip_id           in     number
  ,p_pgm_id            in     number
  ,p_ler_id            in     number
  ,p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_dflt_enrt_cd         out nocopy varchar2
  ,p_dflt_enrt_rl         out nocopy number
  );
-----------------------------------------------------------------------------
--
-- Find the required period of enrollment.  Code/rule/value and level.
--
procedure find_rqd_perd_enrt
  (p_oipl_id                 in     number
  ,p_opt_id                  in     number
  ,p_pl_id                   in     number
  ,p_ptip_id                 in     number
  ,p_effective_date          in     date
  ,p_business_group_id       in     number
  ,p_rqd_perd_enrt_nenrt_uom    out nocopy varchar2
  ,p_rqd_perd_enrt_nenrt_val    out nocopy number
  ,p_rqd_perd_enrt_nenrt_rl     out nocopy number
  ,p_level                      out nocopy varchar2
  );
-----------------------------------------------------------------------------
--
-- find an enrollment at the give level.
--
procedure find_enrt_at_same_level(
       p_person_id               in number
      ,p_opt_id                  in number
      ,p_oipl_id                 in number
      ,p_pl_id                   in number
      ,p_ptip_id                 in number
      ,p_pl_typ_id               in number
      ,p_pgm_id                  in number
      ,p_effective_date          in date
      ,p_business_group_id       in number
      ,p_prtt_enrt_rslt_id       in number
      ,p_level                   in varchar2
      ,p_pen_rec                 out nocopy ben_prtt_enrt_rslt_f%rowtype
);
-----------------------------------------------------------------------------
procedure update_defaults
  (p_run_mode               in     varchar2
  ,p_business_group_id      in     number
  ,p_effective_date         in     date
  ,p_lf_evt_ocrd_dt         in     date default null
  ,p_ler_id                 in     number
  ,p_person_id              in     number
  ,p_per_in_ler_id          in     number
  );
end ben_enrolment_requirements;

/
