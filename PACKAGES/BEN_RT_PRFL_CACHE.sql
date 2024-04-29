--------------------------------------------------------
--  DDL for Package BEN_RT_PRFL_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_RT_PRFL_CACHE" AUTHID CURRENT_USER as
/* $Header: bertprch.pkh 115.16 2003/02/10 19:31:35 hnarayan ship $*/
--
/*
+==============================================================================+
|			 Copyright (c) 1997 Oracle Corporation		       |
|			    Redwood Shores, California, USA		       |
|				All rights reserved.			       |
+==============================================================================+
--
History
  Version    Date	Who	   What?
  ---------  ---------	---------- --------------------------------------------
  115.0      24-Jun-99	bbulusu    Created.
  115.1      01-Jul-99	lmcdonal   added ttl_prtt and ttl_cvg
  115.2      16-Aug-99	stee	   Added absence_attendance_type_id and
				   abs_attendance_reason_id to loa_rsn cache.
  115.3      27-Sep-99	GPERRY	   Added missing fields to many derived factors.
  115.4      04-Oct-99	GPERRY	   Backport of 115.1 with 115.3 fixes.
  115.5      04-Oct-99	GPERRY	   Leapfrog of 115.3.
  115.6      06-Oct-99	STEE	   Add new criteria, period of enrollment
				   and disabled code.
  115.7      12 Nov 99	tguy	   added los_fctr_id and age/comp id for
				   factors criteria.
  115.8      11-May-00  dcollins   Performance enhancements, implemented
                                   exception capturing instead of exists clauses
                                   added "in out NOCOPY" to all set procs and
                                   removed extra record assignment statements
  115.9      19-dec-00  Tmathers   Fixed check_sql errors.
  115.10     20-Mar-02  vsethi     added dbdrv lines
  115.11     29-Apr-02  pabodla    Bug 1631182 : support user created
                                   person type.
  115.12     05-Jun-02  vsethi     Added code to handle the new rates profile
  115.13     12-Jun-02  vsethi     Added code to handle the quartile and
				   performance rating
  115.14     27-Jun-02  vsethi     Bug 2436338 Modified the data type of title
  				   field of g_qual_titl_inst_rec record type to varchar2.
  115.16     10-feb-03  hnarayan   Added NOCOPY Changes
  -----------------------------------------------------------------------------
*/
--
g_inst_count number;
--
-- -----------------------------------------------------------------------------
-- Each of the global record structures below represents a cursor that was part
-- of benrtprf.pkb. The id column at the beginning of every structure is
-- required for the caching mechanism to work.
--
-- The "_lookup" structures act as MASTER cache structures.
-- The "_instance" structures act as the DETAIL cache structures.
-- The "_out" in each case is a global area that the get_cached_data procedure
--     uses to to store the DATA BEING RETURNED.
-- ----------------------------------------------------------------------------
--
-- PEOPLE GROUP
--
type g_pg_inst_rec is record
  (id		     number
  ,person_type_id    number
  ,vrbl_rt_prfl_id   number(15)
  ,people_group_id   number(15)
  ,excld_flag	     varchar2(30)
  ,segment1          varchar2(60)
  ,segment2          varchar2(60)
  ,segment3          varchar2(60)
  ,segment4          varchar2(60)
  ,segment5          varchar2(60)
  ,segment6          varchar2(60)
  ,segment7          varchar2(60)
  ,segment8          varchar2(60)
  ,segment9          varchar2(60)
  ,segment10         varchar2(60)
  ,segment11         varchar2(60)
  ,segment12         varchar2(60)
  ,segment13         varchar2(60)
  ,segment14         varchar2(60)
  ,segment15         varchar2(60)
  ,segment16         varchar2(60)
  ,segment17         varchar2(60)
  ,segment18         varchar2(60)
  ,segment19         varchar2(60)
  ,segment20         varchar2(60)
  ,segment21         varchar2(60)
  ,segment22         varchar2(60)
  ,segment23         varchar2(60)
  ,segment24         varchar2(60)
  ,segment25         varchar2(60)
  ,segment26         varchar2(60)
  ,segment27         varchar2(60)
  ,segment28         varchar2(60)
  ,segment29         varchar2(60)
  ,segment30         varchar2(60) );
--
type g_pg_inst_tbl is table of ben_rt_prfl_cache.g_pg_inst_rec
  index by binary_integer;
--
g_pg_lookup	      ben_cache.g_cache_lookup_table;
g_pg_instance	      g_pg_inst_tbl;
g_pg_out	      ben_rt_prfl_cache.g_pg_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_pg_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- RULE
--
type g_rl_inst_rec is record
  (id		    number
  ,vrbl_rt_prfl_id  number(15)
  ,formula_id	    number(15)
  );
--
type g_rl_inst_tbl is table of ben_rt_prfl_cache.g_rl_inst_rec
  index by binary_integer;
--
g_rl_lookup	      ben_cache.g_cache_lookup_table;
g_rl_instance	      g_rl_inst_tbl;
g_rl_out	      ben_rt_prfl_cache.g_rl_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_rl_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- TOBACCO
--
type g_tbco_inst_rec is record
  (id		    number
  ,vrbl_rt_prfl_id  number(15)
  ,uses_tbco_flag   varchar2(30)
  ,excld_flag	    varchar2(30)
  );
--
type g_tbco_inst_tbl is table of ben_rt_prfl_cache.g_tbco_inst_rec
  index by binary_integer;
--
g_tbco_lookup		ben_cache.g_cache_lookup_table;
g_tbco_instance 	g_tbco_inst_tbl;
g_tbco_out		g_tbco_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_tbco_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- GENDER
--
type g_gndr_inst_rec is record
  (id		    number
  ,vrbl_rt_prfl_id  number(15)
  ,gndr_cd	    varchar2(30)
  ,excld_flag	    varchar2(30)
  );
--
type g_gndr_inst_tbl is table of ben_rt_prfl_cache.g_gndr_inst_rec
  index by binary_integer;
--
g_gndr_lookup		ben_cache.g_cache_lookup_table;
g_gndr_instance 	g_gndr_inst_tbl;
g_gndr_out		g_gndr_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_gndr_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- DISABLED CODE
--
type g_dsbld_inst_rec is record
  (id		   number
  ,vrbl_rt_prfl_id number(15)
  ,dsbld_cd	   varchar2(30)
  ,excld_flag	   varchar2(30)
  );
--
type g_dsbld_inst_tbl is table of ben_rt_prfl_cache.g_dsbld_inst_rec
  index by binary_integer;
--
g_dsbld_lookup		 ben_cache.g_cache_lookup_table;
g_dsbld_instance	 g_dsbld_inst_tbl;
g_dsbld_out		 g_dsbld_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_dsbld_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- BARGAINING UNIT
--
type g_brgng_inst_rec is record
  (id		    number
  ,vrbl_rt_prfl_id  number(15)
  ,brgng_unit_cd    varchar2(30)
  ,excld_flag	    varchar2(30)
  );
--
type g_brgng_inst_tbl is table of ben_rt_prfl_cache.g_brgng_inst_rec
  index by binary_integer;
--
g_brgng_lookup		 ben_cache.g_cache_lookup_table;
g_brgng_instance	 g_brgng_inst_tbl;
g_brgng_out		 g_brgng_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_brgng_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- BENEFITS GROUP
--
type g_bnfgrp_inst_rec is record
  (id		    number
  ,vrbl_rt_prfl_id  number(15)
  ,benfts_grp_id     number(15)
  ,excld_flag	    varchar2(30)
  );
--
type g_bnfgrp_inst_tbl is table of ben_rt_prfl_cache.g_bnfgrp_inst_rec
  index by binary_integer;
--
g_bnfgrp_lookup 	  ben_cache.g_cache_lookup_table;
g_bnfgrp_instance	  g_bnfgrp_inst_tbl;
g_bnfgrp_out		  g_bnfgrp_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_bnfgrp_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- EMPLOYMENT STATUS
--
type g_eestat_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,assignment_status_type_id number(15)
  ,excld_flag		     varchar2(30)
  );
--
type g_eestat_inst_tbl is table of ben_rt_prfl_cache.g_eestat_inst_rec
  index by binary_integer;
--
g_eestat_lookup 	  ben_cache.g_cache_lookup_table;
g_eestat_instance	  g_eestat_inst_tbl;
g_eestat_out		  g_eestat_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_eestat_inst_tbl
  ,p_inst_count        out nocopy number);
--
--
-- FULL TIME PART TIME
--
type g_ftpt_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,fl_tm_pt_tm_cd	     varchar2(30)
  ,excld_flag		     varchar2(30)
  );
--
type g_ftpt_inst_tbl is table of ben_rt_prfl_cache.g_ftpt_inst_rec
  index by binary_integer;
--
g_ftpt_lookup		ben_cache.g_cache_lookup_table;
g_ftpt_instance 	g_ftpt_inst_tbl;
g_ftpt_out		g_ftpt_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_ftpt_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- GRADE
--
type g_grd_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,grade_id		     number(15)
  ,excld_flag		     varchar2(30)
  );
--
type g_grd_inst_tbl is table of ben_rt_prfl_cache.g_grd_inst_rec
  index by binary_integer;
--
g_grd_lookup	       ben_cache.g_cache_lookup_table;
g_grd_instance	       g_grd_inst_tbl;
g_grd_out	       g_grd_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_grd_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- PERCENT FULL TIME
--
type g_pctft_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,mn_pct_val		     number
  ,mx_pct_val		     number
  ,no_mn_pct_val_flag	     varchar2(30)
  ,no_mx_pct_val_flag	     varchar2(30)
  ,excld_flag		     varchar2(30)
  );
--
type g_pctft_inst_tbl is table of ben_rt_prfl_cache.g_pctft_inst_rec
  index by binary_integer;
--
g_pctft_lookup		 ben_cache.g_cache_lookup_table;
g_pctft_instance	 g_pctft_inst_tbl;
g_pctft_out		 g_pctft_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_pctft_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- HOURS WORKED
--
type g_hrswkd_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,mn_hrs_num		     ben_hrs_wkd_in_perd_fctr.mn_hrs_num%type
  ,mx_hrs_num		     ben_hrs_wkd_in_perd_fctr.mx_hrs_num%type
  ,no_mn_hrs_wkd_flag	     varchar2(30)
  ,no_mx_hrs_wkd_flag	     varchar2(30)
  ,excld_flag		     varchar2(30)
  );
--
type g_hrswkd_inst_tbl is table of ben_rt_prfl_cache.g_hrswkd_inst_rec
  index by binary_integer;
--
g_hrswkd_lookup 	  ben_cache.g_cache_lookup_table;
g_hrswkd_instance	  g_hrswkd_inst_tbl;
g_hrswkd_out		  g_hrswkd_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_hrswkd_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- Period of Enrollment
--
type g_poe_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,mn_poe_num		     ben_poe_rt_f.mn_poe_num%type
  ,mx_poe_num		     ben_poe_rt_f.mx_poe_num%type
  ,no_mn_poe_flag	     varchar2(30)
  ,no_mx_poe_flag	     varchar2(30)
  ,rndg_cd		     ben_poe_rt_f.rndg_cd%type
  ,rndg_rl		     ben_poe_rt_f.rndg_rl%type
  ,poe_nnmntry_uom	     ben_poe_rt_f.poe_nnmntry_uom%type
  ,cbr_dsblty_apls_flag      varchar2(30)
  );
--
type g_poe_inst_tbl is table of ben_rt_prfl_cache.g_poe_inst_rec
  index by binary_integer;
--
g_poe_lookup		  ben_cache.g_cache_lookup_table;
g_poe_instance		  g_poe_inst_tbl;
g_poe_out		  g_poe_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_poe_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- LABOR UNION MEMBERSHIP
--
type g_lbrmmbr_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,lbr_mmbr_flag	     varchar2(30)
  ,excld_flag		     varchar2(30)
  );
--
type g_lbrmmbr_inst_tbl is table of ben_rt_prfl_cache.g_lbrmmbr_inst_rec
  index by binary_integer;
--
g_lbrmmbr_lookup	   ben_cache.g_cache_lookup_table;
g_lbrmmbr_instance	   g_lbrmmbr_inst_tbl;
g_lbrmmbr_out		   g_lbrmmbr_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_lbrmmbr_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- LEGAL ENTITY
--
type g_lglenty_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,organization_id	     number(15)
  ,excld_flag		     varchar2(30)
  );
--
type g_lglenty_inst_tbl is table of ben_rt_prfl_cache.g_lglenty_inst_rec
  index by binary_integer;
--
g_lglenty_lookup	   ben_cache.g_cache_lookup_table;
g_lglenty_instance	   g_lglenty_inst_tbl;
g_lglenty_out		   g_lglenty_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_lglenty_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- LEAVE OF ABSENCE
--
type g_loa_inst_rec is record
  (id			      number
  ,vrbl_rt_prfl_id	      number(15)
  ,absence_attendance_type_id number(15)
  ,abs_attendance_reason_id   number(15)
  ,excld_flag		      varchar2(30)
  );
--
type g_loa_inst_tbl is table of ben_rt_prfl_cache.g_loa_inst_rec
  index by binary_integer;
--
g_loa_lookup	       ben_cache.g_cache_lookup_table;
g_loa_instance	       g_loa_inst_tbl;
g_loa_out	       g_loa_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_loa_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- ORGANIZATION_UNIT
--
type g_org_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,organization_id	     number(15)
  ,excld_flag		     varchar2(30)
  );
--
type g_org_inst_tbl is table of ben_rt_prfl_cache.g_org_inst_rec
  index by binary_integer;
--
g_org_lookup	       ben_cache.g_cache_lookup_table;
g_org_instance	       g_org_inst_tbl;
g_org_out	       g_org_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_org_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- PERSON TYPE
--
type g_pertyp_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  --,per_typ_cd		     varchar2(30)
  ,person_type_id            number(15)
  ,excld_flag		     varchar2(30)
  );
--
type g_pertyp_inst_tbl is table of ben_rt_prfl_cache.g_pertyp_inst_rec
  index by binary_integer;
--
g_pertyp_lookup 	  ben_cache.g_cache_lookup_table;
g_pertyp_instance	  g_pertyp_inst_tbl;
g_pertyp_out		  g_pertyp_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_pertyp_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- ZIP RANGE
--
type g_ziprng_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,from_value		     varchar2(30)
  ,to_value		     varchar2(30)
  ,excld_flag		     varchar2(30)
  );
--
type g_ziprng_inst_tbl is table of ben_rt_prfl_cache.g_ziprng_inst_rec
  index by binary_integer;
--
g_ziprng_lookup 	  ben_cache.g_cache_lookup_table;
g_ziprng_instance	  g_ziprng_inst_tbl;
g_ziprng_out		  g_ziprng_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_ziprng_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- PAYROLL
--
type g_pyrl_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,payroll_id		     number(15)
  ,excld_flag		     varchar2(30)
  );
--
type g_pyrl_inst_tbl is table of ben_rt_prfl_cache.g_pyrl_inst_rec
  index by binary_integer;
--
g_pyrl_lookup		ben_cache.g_cache_lookup_table;
g_pyrl_instance 	g_pyrl_inst_tbl;
g_pyrl_out		g_pyrl_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_pyrl_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- PAY BASIS
--
type g_py_bss_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,pay_basis_id 	     number(15)
  ,excld_flag		     varchar2(30)
  );
--
type g_py_bss_inst_tbl is table of ben_rt_prfl_cache.g_py_bss_inst_rec
  index by binary_integer;
--
g_py_bss_lookup 	  ben_cache.g_cache_lookup_table;
g_py_bss_instance	  g_py_bss_inst_tbl;
g_py_bss_out		  g_py_bss_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_py_bss_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- SCHEDULED HOURS
--
type g_scdhrs_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,hrs_num		     number(22,3)
  ,freq_cd		     varchar2(30)
  ,max_hrs_num		number(22,3)
  ,schedd_hrs_rl		number(15)
  ,determination_cd		varchar2(30)
  ,determination_rl		number(15)
  ,rounding_cd				varchar2(30)
  ,rounding_rl				number(15)
  ,excld_flag		     varchar2(30)
  );
--
type g_scdhrs_inst_tbl is table of ben_rt_prfl_cache.g_scdhrs_inst_rec
  index by binary_integer;
--
g_scdhrs_lookup 	  ben_cache.g_cache_lookup_table;
g_scdhrs_instance	  g_scdhrs_inst_tbl;
g_scdhrs_out		  g_scdhrs_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_scdhrs_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- WORK LOCATION
--
type g_wkloc_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,location_id		     number(15)
  ,excld_flag		     varchar2(30)
  );
--
type g_wkloc_inst_tbl is table of ben_rt_prfl_cache.g_wkloc_inst_rec
  index by binary_integer;
--
g_wkloc_lookup		 ben_cache.g_cache_lookup_table;
g_wkloc_instance	 g_wkloc_inst_tbl;
g_wkloc_out		 g_wkloc_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_wkloc_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- SERVICE AREA
--
type g_svcarea_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,from_value		     varchar2(30)
  ,to_value		     varchar2(30)
  ,excld_flag		     varchar2(30)
  );
--
type g_svcarea_inst_tbl is table of ben_rt_prfl_cache.g_svcarea_inst_rec
  index by binary_integer;
--
g_svcarea_lookup	   ben_cache.g_cache_lookup_table;
g_svcarea_instance	   g_svcarea_inst_tbl;
g_svcarea_out		   g_svcarea_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_svcarea_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- HOURLY OR SALARIED
--
type g_hrlyslrd_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,hrly_slrd_cd 	     varchar2(30)
  ,excld_flag		     varchar2(30)
  );
--
type g_hrlyslrd_inst_tbl is table of ben_rt_prfl_cache.g_hrlyslrd_inst_rec
  index by binary_integer;
--
g_hrlyslrd_lookup	    ben_cache.g_cache_lookup_table;
g_hrlyslrd_instance	    g_hrlyslrd_inst_tbl;
g_hrlyslrd_out		    g_hrlyslrd_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_hrlyslrd_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- AGE
--
type g_age_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,mn_age_num		     number
  ,mx_age_num		     number
  ,no_mn_age_flag	     varchar2(30)
  ,no_mx_age_flag	     varchar2(30)
  ,age_fctr_id		     number(15)
  ,excld_flag		     varchar2(30)
  );
--
type g_age_inst_tbl is table of ben_rt_prfl_cache.g_age_inst_rec
  index by binary_integer;
--
g_age_lookup	       ben_cache.g_cache_lookup_table;
g_age_instance	       g_age_inst_tbl;
g_age_out	       g_age_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_age_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- COMP LVL CODE
--
type g_complvl_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,mn_comp_val		     number
  ,mx_comp_val		     number
  ,no_mn_comp_flag	     varchar2(30)
  ,no_mx_comp_flag	     varchar2(30)
  ,comp_lvl_fctr_id	     number(15)
  ,excld_flag		     varchar2(30)
  );
--
type g_complvl_inst_tbl is table of ben_rt_prfl_cache.g_complvl_inst_rec
  index by binary_integer;
--
g_complvl_lookup	   ben_cache.g_cache_lookup_table;
g_complvl_instance	   g_complvl_inst_tbl;
g_complvl_out		   g_complvl_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_complvl_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- LOS
--
type g_los_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,mn_los_num		     number
  ,mx_los_num		     number
  ,no_mn_los_num_apls_flag   varchar2(30)
  ,no_mx_los_num_apls_flag   varchar2(30)
  ,excld_flag		     varchar2(30)
  ,los_fctr_id		     number
  );
--
type g_los_inst_tbl is table of ben_rt_prfl_cache.g_los_inst_rec
  index by binary_integer;
--
g_los_lookup	       ben_cache.g_cache_lookup_table;
g_los_instance	       g_los_inst_tbl;
g_los_out	       g_los_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_los_inst_tbl
  ,p_inst_count        out nocopy number);
--
-- COMBINATION AGE LOS
--
type g_age_los_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,cmbnd_min_val	     number
  ,cmbnd_max_val	     number
  ,excld_flag		     varchar2(30)
  ,cmbn_age_los_fctr_id      number
  );
--
type g_age_los_inst_tbl is table of ben_rt_prfl_cache.g_age_los_inst_rec
  index by binary_integer;
--
g_age_los_lookup	   ben_cache.g_cache_lookup_table;
g_age_los_instance	   g_age_los_inst_tbl;
g_age_los_out		   g_age_los_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_age_los_inst_tbl
  ,p_inst_count        out nocopy number);

------------------------------------------------------------------------
-- TOTAL PARTICIPANTS
------------------------------------------------------------------------
type g_ttl_prtt_inst_rec is record
  (id		    number
  ,vrbl_rt_prfl_id  number(15)
  ,mn_prtt_num	    number
  ,mx_prtt_num	    number
  );
--
type g_ttl_prtt_inst_tbl is table of
   ben_rt_prfl_cache.g_ttl_prtt_inst_rec  index by binary_integer;
--
g_ttl_prtt_lookup	    ben_cache.g_cache_lookup_table;
g_ttl_prtt_instance	    g_ttl_prtt_inst_tbl;
g_ttl_prtt_out		    g_ttl_prtt_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_ttl_prtt_inst_tbl
  ,p_inst_count        out nocopy number);
------------------------------------------------------------------------
-- TOTAL COVERAGE
------------------------------------------------------------------------
type g_ttl_cvg_inst_rec is record
  (id		    number
  ,vrbl_rt_prfl_id  number(15)
  ,mn_cvg_vol_amt   number
  ,mx_cvg_vol_amt   number
  );
--
type g_ttl_cvg_inst_tbl is table of
   ben_rt_prfl_cache.g_ttl_cvg_inst_rec  index by binary_integer;
--
g_ttl_cvg_lookup	   ben_cache.g_cache_lookup_table;
g_ttl_cvg_instance	   g_ttl_cvg_inst_tbl;
g_ttl_cvg_out		   g_ttl_cvg_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_ttl_cvg_inst_tbl
  ,p_inst_count        out nocopy number);


------------------------------------------------------------------------
-- JOB
------------------------------------------------------------------------
type g_job_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,job_id		     number(15)
  ,excld_flag		     varchar2(30)
  );
--
type g_job_inst_tbl is table of ben_rt_prfl_cache.g_job_inst_rec
  index by binary_integer;
--
g_job_lookup	       ben_cache.g_cache_lookup_table;
g_job_instance	       g_job_inst_tbl;
g_job_out	       g_job_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_job_inst_tbl
  ,p_inst_count        out nocopy number);


------------------------------------------------------------------------
-- OMR - Opted for Medicare
------------------------------------------------------------------------
type g_optd_mdcr_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,optd_mdcr_flag	     varchar2(30)
  );
--
type g_optd_mdcr_inst_tbl is table of ben_rt_prfl_cache.g_optd_mdcr_inst_rec
  index by binary_integer;
--
g_optd_mdcr_lookup	ben_cache.g_cache_lookup_table;
g_optd_mdcr_instance	g_optd_mdcr_inst_tbl;
g_optd_mdcr_out	       	g_optd_mdcr_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_optd_mdcr_inst_tbl
  ,p_inst_count        out nocopy number);

------------------------------------------------------------------------
-- LRR - Leaving Reason
------------------------------------------------------------------------
type g_lvg_rsn_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,lvg_rsn_cd		     varchar(30)
  ,excld_flag		     varchar2(30)
  );
--
type g_lvg_rsn_inst_tbl is table of ben_rt_prfl_cache.g_lvg_rsn_inst_rec
  index by binary_integer;
--
g_lvg_rsn_lookup	ben_cache.g_cache_lookup_table;
g_lvg_rsn_instance	g_lvg_rsn_inst_tbl;
g_lvg_rsn_out	       	g_lvg_rsn_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_lvg_rsn_inst_tbl
  ,p_inst_count        out nocopy number);


------------------------------------------------------------------------
-- CQR	Cobra Qualified Beneficiary
------------------------------------------------------------------------
type g_cbr_qual_bnf_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,ptip_id		     number(15)
  ,pgm_id		     number(15)
  ,quald_bnf_flag	     varchar(30)
  );
--
type g_cbr_qual_bnf_inst_tbl is table of ben_rt_prfl_cache.g_cbr_qual_bnf_inst_rec
  index by binary_integer;
--
g_cbr_qual_bnf_lookup	       ben_cache.g_cache_lookup_table;
g_cbr_qual_bnf_instance	       g_cbr_qual_bnf_inst_tbl;
g_cbr_qual_bnf_out	       g_cbr_qual_bnf_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_cbr_qual_bnf_inst_tbl
  ,p_inst_count        out nocopy number);


------------------------------------------------------------------------
-- CPP	Continuing Participation Profile
------------------------------------------------------------------------
type g_cntng_prtn_prfl_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,pymt_must_be_rcvd_uom     varchar2(30)
  ,pymt_must_be_rcvd_num     number(15)
  ,pymt_must_be_rcvd_rl      number(15)
  );
--
type g_cntng_prtn_prfl_inst_tbl is table of ben_rt_prfl_cache.g_cntng_prtn_prfl_inst_rec
  index by binary_integer;
--
g_cntng_prtn_prfl_lookup	ben_cache.g_cache_lookup_table;
g_cntng_prtn_prfl_instance	g_cntng_prtn_prfl_inst_tbl;
g_cntng_prtn_prfl_out	      	g_cntng_prtn_prfl_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_cntng_prtn_prfl_inst_tbl
  ,p_inst_count        out nocopy number);



------------------------------------------------------------------------
-- PSR 	Position
------------------------------------------------------------------------
type g_pstn_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,position_id		     number(15)
  ,excld_flag		     varchar2(30)
  );
--
type g_pstn_inst_tbl is table of ben_rt_prfl_cache.g_pstn_inst_rec
  index by binary_integer;
--
g_pstn_lookup	       ben_cache.g_cache_lookup_table;
g_pstn_instance	       g_pstn_inst_tbl;
g_pstn_out	       g_pstn_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_pstn_inst_tbl
  ,p_inst_count        out nocopy number);

------------------------------------------------------------------------
-- CTY	Competency
------------------------------------------------------------------------
type g_comptncy_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,competence_id	     number(15)
  ,rating_level_id	     number(15)
  ,excld_flag		     varchar2(30)
  );
--
type g_comptncy_inst_tbl is table of ben_rt_prfl_cache.g_comptncy_inst_rec
  index by binary_integer;
--
g_comptncy_lookup	ben_cache.g_cache_lookup_table;
g_comptncy_instance	g_comptncy_inst_tbl;
g_comptncy_out	       	g_comptncy_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_comptncy_inst_tbl
  ,p_inst_count        out nocopy number);


------------------------------------------------------------------------
-- QTR Qualification Title
------------------------------------------------------------------------
type g_qual_titl_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,qualification_type_id     number(15)
  ,title	     	     varchar2(120)
  ,excld_flag		     varchar2(30)
  );
--
type g_qual_titl_inst_tbl is table of ben_rt_prfl_cache.g_qual_titl_inst_rec
  index by binary_integer;
--
g_qual_titl_lookup	ben_cache.g_cache_lookup_table;
g_qual_titl_instance	g_qual_titl_inst_tbl;
g_qual_titl_out	       	g_qual_titl_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_qual_titl_inst_tbl
  ,p_inst_count        out nocopy number);

------------------------------------------------------------------------
-- DCR 	Covered by Other Plan
------------------------------------------------------------------------
type g_dpnt_cvrd_othr_pl_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,pl_id	     	     number(15)
  ,cvg_det_dt_cd	     varchar2(30)
  ,excld_flag		     varchar2(30)
  );
--
type g_dpnt_cvrd_othr_pl_inst_tbl is table of ben_rt_prfl_cache.g_dpnt_cvrd_othr_pl_inst_rec
  index by binary_integer;
--
g_dpnt_cvrd_othr_pl_lookup	ben_cache.g_cache_lookup_table;
g_dpnt_cvrd_othr_pl_instance	g_dpnt_cvrd_othr_pl_inst_tbl;
g_dpnt_cvrd_othr_pl_out	       	g_dpnt_cvrd_othr_pl_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_dpnt_cvrd_othr_pl_inst_tbl
  ,p_inst_count        out nocopy number);


------------------------------------------------------------------------
-- DCP 	Covered by Other Plan in Program
------------------------------------------------------------------------
type g_dpnt_cvrd_othr_plip_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,plip_id	     	     number(15)
  ,enrl_det_dt_cd	     varchar2(30)
  ,excld_flag		     varchar2(30)
  );
--
type g_dpnt_cvrd_othr_plip_inst_tbl is table of ben_rt_prfl_cache.g_dpnt_cvrd_othr_plip_inst_rec
  index by binary_integer;
--
g_dpnt_cvrd_othr_plip_lookup	       ben_cache.g_cache_lookup_table;
g_dpnt_cvrd_othr_plip_instance	       g_dpnt_cvrd_othr_plip_inst_tbl;
g_dpnt_cvrd_othr_plip_out	       g_dpnt_cvrd_othr_plip_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_dpnt_cvrd_othr_plip_inst_tbl
  ,p_inst_count        out nocopy number);


------------------------------------------------------------------------
-- DCO 	Covered by Other Plan Type in Program
------------------------------------------------------------------------
type g_dpnt_cvrd_othr_ptip_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,ptip_id	     	     number(15)
  ,enrl_det_dt_cd	     varchar2(30)
  ,excld_flag		     varchar2(30)
  ,only_pls_subj_cobra_flag  varchar2(30)
  );
--
type g_dpnt_cvrd_othr_ptip_inst_tbl is table of ben_rt_prfl_cache.g_dpnt_cvrd_othr_ptip_inst_rec
  index by binary_integer;
--
g_dpnt_cvrd_othr_ptip_lookup	       ben_cache.g_cache_lookup_table;
g_dpnt_cvrd_othr_ptip_instance	       g_dpnt_cvrd_othr_ptip_inst_tbl;
g_dpnt_cvrd_othr_ptip_out	       g_dpnt_cvrd_othr_ptip_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_dpnt_cvrd_othr_ptip_inst_tbl
  ,p_inst_count        out nocopy number);



------------------------------------------------------------------------
-- DOP 	Covered by Other Program
------------------------------------------------------------------------
type g_dpnt_cvrd_othr_pgm_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,pgm_id	     	     number(15)
  ,enrl_det_dt_cd	     varchar2(30)
  ,excld_flag		     varchar2(30)
  ,only_pls_subj_cobra_flag  varchar2(30)
  );
--
type g_dpnt_cvrd_othr_pgm_inst_tbl is table of ben_rt_prfl_cache.g_dpnt_cvrd_othr_pgm_inst_rec
  index by binary_integer;
--
g_dpnt_cvrd_othr_pgm_lookup	       ben_cache.g_cache_lookup_table;
g_dpnt_cvrd_othr_pgm_instance	       g_dpnt_cvrd_othr_pgm_inst_tbl;
g_dpnt_cvrd_othr_pgm_out	       g_dpnt_cvrd_othr_pgm_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_dpnt_cvrd_othr_pgm_inst_tbl
  ,p_inst_count        out nocopy number);


------------------------------------------------------------------------
-- PAP 	Eligible for Another Plan
------------------------------------------------------------------------
type g_prtt_anthr_pl_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,pl_id	     	     number(15)
  ,excld_flag		     varchar2(30)
  );
--
type g_prtt_anthr_pl_inst_tbl is table of ben_rt_prfl_cache.g_prtt_anthr_pl_inst_rec
  index by binary_integer;
--
g_prtt_anthr_pl_lookup	       	ben_cache.g_cache_lookup_table;
g_prtt_anthr_pl_instance	g_prtt_anthr_pl_inst_tbl;
g_prtt_anthr_pl_out	       	g_prtt_anthr_pl_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_prtt_anthr_pl_inst_tbl
  ,p_inst_count        out nocopy number);


------------------------------------------------------------------------
-- OPR 	Eligible for Another Plan Type in Program
------------------------------------------------------------------------
type g_othr_ptip_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,ptip_id	     	     number(15)
  ,excld_flag		     varchar2(30)
  ,only_pls_subj_cobra_flag  varchar2(30)
  );
--
type g_othr_ptip_inst_tbl is table of ben_rt_prfl_cache.g_othr_ptip_inst_rec
  index by binary_integer;
--
g_othr_ptip_lookup	ben_cache.g_cache_lookup_table;
g_othr_ptip_instance	g_othr_ptip_inst_tbl;
g_othr_ptip_out	       	g_othr_ptip_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_othr_ptip_inst_tbl
  ,p_inst_count        out nocopy number);


------------------------------------------------------------------------
-- ENL Enrolled Another Plan
------------------------------------------------------------------------
type g_enrld_anthr_pl_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,pl_id	     	     number(15)
  ,enrl_det_dt_cd	     varchar2(30)
  ,excld_flag		     varchar2(30)
  );
--
type g_enrld_anthr_pl_inst_tbl is table of ben_rt_prfl_cache.g_enrld_anthr_pl_inst_rec
  index by binary_integer;
--
g_enrld_anthr_pl_lookup		ben_cache.g_cache_lookup_table;
g_enrld_anthr_pl_instance	g_enrld_anthr_pl_inst_tbl;
g_enrld_anthr_pl_out	       	g_enrld_anthr_pl_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_enrld_anthr_pl_inst_tbl
  ,p_inst_count        out nocopy number);



------------------------------------------------------------------------
-- EAO Enrolled Another Option in Plan
------------------------------------------------------------------------
type g_enrld_anthr_oipl_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,oipl_id	     	     number(15)
  ,enrl_det_dt_cd	     varchar2(30)
  ,excld_flag		     varchar2(30)
  );
--
type g_enrld_anthr_oipl_inst_tbl is table of ben_rt_prfl_cache.g_enrld_anthr_oipl_inst_rec
  index by binary_integer;
--
g_enrld_anthr_oipl_lookup	ben_cache.g_cache_lookup_table;
g_enrld_anthr_oipl_instance	g_enrld_anthr_oipl_inst_tbl;
g_enrld_anthr_oipl_out	        g_enrld_anthr_oipl_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_enrld_anthr_oipl_inst_tbl
  ,p_inst_count        out nocopy number);


------------------------------------------------------------------------
-- EAR Enrolled Another Plan in Program
------------------------------------------------------------------------
type g_enrld_anthr_plip_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,plip_id	     	     number(15)
  ,enrl_det_dt_cd	     varchar2(30)
  ,excld_flag		     varchar2(30)
  );
--
type g_enrld_anthr_plip_inst_tbl is table of ben_rt_prfl_cache.g_enrld_anthr_plip_inst_rec
  index by binary_integer;
--
g_enrld_anthr_plip_lookup	ben_cache.g_cache_lookup_table;
g_enrld_anthr_plip_instance	g_enrld_anthr_plip_inst_tbl;
g_enrld_anthr_plip_out	        g_enrld_anthr_plip_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_enrld_anthr_plip_inst_tbl
  ,p_inst_count        out nocopy number);

------------------------------------------------------------------------
-- ENT Enrolled Another Plan Type in Program
------------------------------------------------------------------------
type g_enrld_anthr_ptip_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,ptip_id	     	     number(15)
  ,enrl_det_dt_cd	     varchar2(30)
  ,excld_flag		     varchar2(30)
  ,only_pls_subj_cobra_flag  varchar2(30)
  );
--
type g_enrld_anthr_ptip_inst_tbl is table of ben_rt_prfl_cache.g_enrld_anthr_ptip_inst_rec
  index by binary_integer;
--
g_enrld_anthr_ptip_lookup	ben_cache.g_cache_lookup_table;
g_enrld_anthr_ptip_instance	g_enrld_anthr_ptip_inst_tbl;
g_enrld_anthr_ptip_out		g_enrld_anthr_ptip_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_enrld_anthr_ptip_inst_tbl
  ,p_inst_count        out nocopy number);


------------------------------------------------------------------------
-- EAG Enrolled Another Program
------------------------------------------------------------------------
type g_enrld_anthr_pgm_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,pgm_id	     	     number(15)
  ,enrl_det_dt_cd	     varchar2(30)
  ,excld_flag		     varchar2(30)
  );
--
type g_enrld_anthr_pgm_inst_tbl is table of ben_rt_prfl_cache.g_enrld_anthr_pgm_inst_rec
  index by binary_integer;
--
g_enrld_anthr_pgm_lookup	ben_cache.g_cache_lookup_table;
g_enrld_anthr_pgm_instance	g_enrld_anthr_pgm_inst_tbl;
g_enrld_anthr_pgm_out   	g_enrld_anthr_pgm_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_enrld_anthr_pgm_inst_tbl
  ,p_inst_count        out nocopy number);

------------------------------------------------------------------------
-- DOT Dependent eligible for another plan type in program
------------------------------------------------------------------------
type g_dpnt_othr_ptip_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,ptip_id	     	     number(15)
  ,excld_flag		     varchar2(30)
  );
--
type g_dpnt_othr_ptip_inst_tbl is table of ben_rt_prfl_cache.g_dpnt_othr_ptip_inst_rec
  index by binary_integer;
--
g_dpnt_othr_ptip_lookup	       	ben_cache.g_cache_lookup_table;
g_dpnt_othr_ptip_instance	g_dpnt_othr_ptip_inst_tbl;
g_dpnt_othr_ptip_out	       	g_dpnt_othr_ptip_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_dpnt_othr_ptip_inst_tbl
  ,p_inst_count        out nocopy number);

------------------------------------------------------------------------
-- NOC 	No Other Coverage
------------------------------------------------------------------------
type g_no_othr_cvg_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,coord_ben_no_cvg_flag     varchar2(30)
  );
--
type g_no_othr_cvg_inst_tbl is table of ben_rt_prfl_cache.g_no_othr_cvg_inst_rec
  index by binary_integer;
--
g_no_othr_cvg_lookup	       	ben_cache.g_cache_lookup_table;
g_no_othr_cvg_instance		g_no_othr_cvg_inst_tbl;
g_no_othr_cvg_out	       	g_no_othr_cvg_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_no_othr_cvg_inst_tbl
  ,p_inst_count        out nocopy number);


------------------------------------------------------------------------
-- Quartile in Grade
------------------------------------------------------------------------
type g_qua_in_gr_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,quar_in_grade_cd	     varchar2(30)
  ,excld_flag		     varchar2(30)
  );
--
type g_qua_in_gr_inst_tbl is table of ben_rt_prfl_cache.g_qua_in_gr_inst_rec
  index by binary_integer;
--
g_qua_in_gr_lookup     ben_cache.g_cache_lookup_table;
g_qua_in_gr_instance   g_qua_in_gr_inst_tbl;
g_qua_in_gr_out	       g_qua_in_gr_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_qua_in_gr_inst_tbl
  ,p_inst_count        out nocopy number);


------------------------------------------------------------------------
-- Performance Rating
------------------------------------------------------------------------
type g_perf_rtng_inst_rec is record
  (id			     number
  ,vrbl_rt_prfl_id	     number(15)
  ,perf_rtng_cd		     varchar2(30)
  ,event_type	             varchar2(30)
  ,excld_flag		     varchar2(30)
  );
--
type g_perf_rtng_inst_tbl is table of ben_rt_prfl_cache.g_perf_rtng_inst_rec
  index by binary_integer;
--
g_perf_rtng_lookup     ben_cache.g_cache_lookup_table;
g_perf_rtng_instance   g_perf_rtng_inst_tbl;
g_perf_rtng_out	       g_perf_rtng_inst_tbl;
--
procedure get_rt_prfl_cache
  (p_vrbl_rt_prfl_id   in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set	       in out NOCOPY ben_rt_prfl_cache.g_perf_rtng_inst_tbl
  ,p_inst_count        out nocopy number);

------------------------------------------------------------------------
-- DELETE CACHED DATA
------------------------------------------------------------------------
procedure clear_down_cache;
--
END ben_rt_prfl_cache;

 

/
