--------------------------------------------------------
--  DDL for Package BEN_EFC_ADJUSTMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EFC_ADJUSTMENTS" AUTHID CURRENT_USER as
/* $Header: beefcadj.pkh 115.12 2002/12/31 23:58:14 mmudigon noship $*/
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
  115.0      31-Jan-01	mhoyes     Created.
  115.1      01-Feb-01	mhoyes     Added PRV and EEV adjustment covers.
  115.2      06-Apr-01	mhoyes     Total revamp for patchset D.
  115.3      12-Jul-01	mhoyes     Enhanced for Patchset E.
  115.6      26-Jul-01	mhoyes     Enhanced for Patchset E+ patch.
  115.7      17-Aug-01	mhoyes     Enhanced for BEN July patch.
  115.8      31-Aug-01	mhoyes     Enhanced for BEN July patch.
  115.9      13-Sep-01	mhoyes     Enhanced for BEN July patch.
  115.10     04-Jan-02	mhoyes     Enhanced for BEN G patchset.
  115.12     30-Dec-02 mmudigon    NOCOPY
  -----------------------------------------------------------------------------
*/
--
type g_adjustment_counts is record
  (efcrow_count           pls_integer
  ,calfail_count          pls_integer
  ,calsucc_count          pls_integer
  ,rcoerr_count           pls_integer
  ,faterrs_count          pls_integer
  ,preadjexc_count        pls_integer
  ,dupconv_count          pls_integer
  ,conv_count             pls_integer
  ,actconv_count          pls_integer
  ,unconv_count           pls_integer
  ,tabrow_count           pls_integer
  ,olddata_count          pls_integer
  ,mod_count              pls_integer
  ,modovn1_count          pls_integer
  ,modovn2_count          pls_integer
  ,modovn3_count          pls_integer
  ,modovn4_count          pls_integer
  ,modovn5_count          pls_integer
  ,modovn6_count          pls_integer
  ,modovnov6_count        pls_integer
  ,multtransmod_count     pls_integer
  );
--
type g_rcoerr_values is record
  (id            number
  ,esd           date
  ,eed           date
  ,bgp_id        number
  ,lud           date
  ,credt         date
  ,rco_name      varchar2(1000)
  ,sql_error     varchar2(3000)
  );
--
type g_rcoerr_values_tbl is table of g_rcoerr_values
  index by binary_integer;
--
g_pep_rcoerr_val_set g_rcoerr_values_tbl;
g_epo_rcoerr_val_set g_rcoerr_values_tbl;
g_enb_rcoerr_val_set g_rcoerr_values_tbl;
g_epr_rcoerr_val_set g_rcoerr_values_tbl;
g_ecr_rcoerr_val_set g_rcoerr_values_tbl;
g_prv_rcoerr_val_set g_rcoerr_values_tbl;
g_eev_rcoerr_val_set g_rcoerr_values_tbl;
g_bpl_rcoerr_val_set g_rcoerr_values_tbl;
--
type g_failed_adj_values is record
  (id            number
  ,id1           number
  ,id2           number
  ,code1         varchar2(30)
  ,code2         varchar2(30)
  ,code3         varchar2(30)
  ,code4         varchar2(30)
  ,esd           date
  ,eed           date
  ,bgp_id        number
  ,lud           date
  ,credt         date
  ,cre_by        number
  ,lu_by         number
  ,ovn           number
  ,old_val1      number
  ,new_val1      number
  ,old_val2      number
  ,new_val2      number
  ,val_type      varchar2(100)
  ,faterr_code   varchar2(100)
  ,faterr_type   varchar2(100)
  );
--
type g_failed_adj_values_tbl is table of g_failed_adj_values
  index by binary_integer;
--
g_pep_success_adj_val_set g_failed_adj_values_tbl;
g_pep_failed_adj_val_set  g_failed_adj_values_tbl;
g_pep_fatal_error_val_set g_failed_adj_values_tbl;
--
g_epo_success_adj_val_set g_failed_adj_values_tbl;
g_epo_failed_adj_val_set  g_failed_adj_values_tbl;
g_epo_fatal_error_val_set g_failed_adj_values_tbl;
--
g_enb_success_adj_val_set g_failed_adj_values_tbl;
g_enb_failed_adj_val_set  g_failed_adj_values_tbl;
g_enb_fatal_error_val_set g_failed_adj_values_tbl;
--
g_epr_success_adj_val_set g_failed_adj_values_tbl;
g_epr_failed_adj_val_set  g_failed_adj_values_tbl;
g_epr_fatal_error_val_set g_failed_adj_values_tbl;
--
g_ecr_success_adj_val_set g_failed_adj_values_tbl;
g_ecr_failed_adj_val_set  g_failed_adj_values_tbl;
g_ecr_fatal_error_val_set g_failed_adj_values_tbl;
--
g_prv_success_adj_val_set g_failed_adj_values_tbl;
g_prv_failed_adj_val_set  g_failed_adj_values_tbl;
g_prv_fatal_error_val_set g_failed_adj_values_tbl;
--
g_eev_success_adj_val_set g_failed_adj_values_tbl;
g_eev_failed_adj_val_set  g_failed_adj_values_tbl;
g_eev_fatal_error_val_set g_failed_adj_values_tbl;
--
g_bpl_success_adj_val_set g_failed_adj_values_tbl;
g_bpl_failed_adj_val_set  g_failed_adj_values_tbl;
g_bpl_fatal_error_val_set g_failed_adj_values_tbl;
--
-- WHO trigger detection
--
type g_who_counts is record
  (olddata_count       pls_integer
  ,olddata             boolean
  ,olddata12mths       boolean
  ,mod_count           pls_integer
  ,modovn1_count       pls_integer
  ,modovn2_count       pls_integer
  ,modovn3_count       pls_integer
  ,modovn4_count       pls_integer
  ,modovn5_count       pls_integer
  ,modovn6_count       pls_integer
  ,modovnov6_count     pls_integer
  ,multtransmod_count  pls_integer
  ,multtransmod        boolean
  );
--
-- PIL details
--
type g_pil_rowtype is record
  (per_in_ler_id       number
  ,person_id           number
  ,lf_evt_ocrd_dt      date
  );
--
procedure DetectAppError
  (p_sqlerrm                   in    varchar2
  ,p_abr_rt_mlt_cd             in    varchar2 default null
  ,p_abr_val                   in    number   default null
  ,p_abr_entr_val_at_enrt_flag in    varchar2 default null
  ,p_abr_id                    in    number   default null
  ,p_eff_date                  in    date     default null
  ,p_penepe_id                 in    number   default null
  --
  ,p_faterr_code                 out nocopy varchar2
  ,p_faterr_type                 out nocopy varchar2
  );
--
procedure DetectWhoInfo
  (p_creation_date         in     date
  ,p_last_update_date      in     date
  ,p_object_version_number in     number
  --
  ,p_who_counts            in out nocopy g_who_counts
  ,p_faterr_code              out nocopy varchar2
  ,p_faterr_type              out nocopy varchar2
  );
--
-- MLT Cd detection
--
type g_mlt_cd_counts is record
  (cl_count         pls_integer
  ,clpflrng_count   pls_integer
  ,clrng_count      pls_integer
  ,flfx_count       pls_integer
  ,flfxpcl_count    pls_integer
  ,flpclrng_count   pls_integer
  ,flrng_count      pls_integer
  ,nsvu_count       pls_integer
  ,rl_count         pls_integer
  ,saaear_count     pls_integer
  ,cvg_count        pls_integer
  ,tplpc_count      pls_integer
  ,ttlcvg_count     pls_integer
  ,ttlprtt_count    pls_integer
  ,ap_count         pls_integer
  ,apandcvg_count   pls_integer
  ,clandcvg_count   pls_integer
  ,prnt_count       pls_integer
  ,prntandcvg_count pls_integer
  ,sarec_count      pls_integer
  );
--
-- PIL detection
--
procedure DetectPILInfo
  (p_person_id         in     number
  ,p_per_in_ler_id     in     number
  --
  ,p_faterr_code          out nocopy varchar2
  );
--
-- BCOL row detection
--
procedure DetectBCOLRowInfo
  (p_comp_obj_tree_row in     ben_manage_life_events.g_cache_proc_objects_rec
  ,p_effective_date    in     date
  ,p_business_group_id in     number
  --
  ,p_faterr_code          out nocopy varchar2
  );
--
-- VAPRO detection
--
cursor gc_vpfdets
  (c_vpf_id   in     number
  ,c_eff_date in     date
  )
is
  select vpf.mlt_cd,
         vpf.creation_date,
         vpf.last_update_date,
         vpf.VRBL_RT_TRTMT_CD
  from   ben_vrbl_rt_prfl_f vpf
  where  vpf.vrbl_rt_prfl_id = c_vpf_id
  and    c_eff_date
    between vpf.effective_start_date
      and     vpf.effective_end_date;
--
-- Detect EPE ENB info
--
procedure DetectEPEENBInfo
  (p_elig_per_elctbl_chc_id in     number
  ,p_enrt_bnft_id           in     number
  --
  ,p_detect_mode            in     varchar2 default null
  --
  ,p_currpil_row               out nocopy g_pil_rowtype
  ,p_currepe_row               out nocopy ben_determine_rates.g_curr_epe_rec
  ,p_faterr_code               out nocopy varchar2
  ,p_faterr_type               out nocopy varchar2
  );
--
procedure DetectVAPROInfo
  (p_currepe_row          in     ben_determine_rates.g_curr_epe_rec
  --
  ,p_lf_evt_ocrd_dt       in     date
  ,p_last_update_date     in     date
  --
  ,p_actl_prem_id         in     number default null
  ,p_acty_base_rt_id      in     number default null
  ,p_cvg_amt_calc_mthd_id in     number default null
  --
  ,p_vpfdets                 out nocopy gc_vpfdets%rowtype
  ,p_vpf_id                  out nocopy number
  ,p_faterr_code             out nocopy varchar2
  ,p_faterr_type             out nocopy varchar2
  );
--
--
-- Detect a hard coded rounding code
--
procedure DetectRoundInfo
  (p_rndg_cd     in     varchar2
  ,p_rndg_rl     in     number
  ,p_old_val     in     number
  ,p_new_val     in     number
  ,p_eff_date    in     date
  --
  ,p_faterr_code    out nocopy varchar2
  ,p_faterr_type    out nocopy varchar2
  );
--
-- Detect post conversion information
--
procedure DetectConvInfo
  (p_ncucurr_code in     varchar2
  ,p_new_val      in     number
  ,p_preconv_val  in     number
  --
  ,p_faterr_code     out nocopy varchar2
  ,p_faterr_type     out nocopy varchar2
  ,p_postconv_val    out nocopy number
  );
--
-- Insert a validation exception
--
procedure insert_validation_exceptions
  (p_val_set        in     g_failed_adj_values_tbl
  ,p_efc_action_id  in     number
  ,p_ent_scode      in     varchar2
  ,p_exception_type in     varchar2
  );
--
-- Detect invalid assignment information
--
cursor gc_perasg
  (c_person_id      in number
  ,c_effective_date in date
  )
is
  select asg.payroll_id,
         asg.pay_basis_id,
         asg.assignment_id
  from   per_all_assignments_f asg
  where  asg.person_id = c_person_id
  and    asg.primary_flag = 'Y'
  and    c_effective_date
    between asg.effective_start_date
         and asg.effective_end_date;
--
procedure DetectInvAsg
  (p_person_id      in     number
  ,p_eff_date       in     date
  --
  ,p_perasg            out nocopy gc_perasg%rowtype
  ,p_noasgpay          out nocopy boolean
  );
--
procedure Insert_fndsession_row
  (p_ses_date in     date
  );
--
procedure pep_adjustments
  (p_validate          in     boolean default false
  ,p_worker_id         in     number  default null
  ,p_action_id         in     number  default null
  ,p_total_workers     in     number  default null
  ,p_pk1               in     number  default null
  ,p_chunk             in     number  default null
  ,p_efc_worker_id     in     number  default null
  --
  ,p_valworker_id      in     number  default null
  ,p_valtotal_workers  in     number  default null
  --
  ,p_business_group_id in     number  default null
  --
  ,p_adjustment_counts    out nocopy g_adjustment_counts
  );
--
procedure epo_adjustments
  (p_validate          in     boolean default false
  ,p_worker_id         in     number  default null
  ,p_action_id         in     number  default null
  ,p_total_workers     in     number  default null
  ,p_pk1               in     number  default null
  ,p_chunk             in     number  default null
  ,p_efc_worker_id     in     number  default null
  --
  ,p_valworker_id      in     number  default null
  ,p_valtotal_workers  in     number  default null
  --
  ,p_business_group_id in     number  default null
  --
  ,p_adjustment_counts    out nocopy g_adjustment_counts
  );
--
procedure enb_adjustments
  (p_validate          in     boolean default false
  ,p_worker_id         in     number  default null
  ,p_action_id         in     number  default null
  ,p_total_workers     in     number  default null
  ,p_pk1               in     number  default null
  ,p_chunk             in     number  default null
  ,p_efc_worker_id     in     number  default null
  --
  ,p_valworker_id      in     number  default null
  ,p_valtotal_workers  in     number  default null
  --
  ,p_business_group_id in     number  default null
  --
  ,p_adjustment_counts    out nocopy g_adjustment_counts
  );
--
procedure epr_adjustments
  (p_validate          in     boolean default false
  ,p_worker_id         in     number  default null
  ,p_action_id         in     number  default null
  ,p_total_workers     in     number  default null
  ,p_pk1               in     number  default null
  ,p_chunk             in     number  default null
  ,p_efc_worker_id     in     number  default null
  --
  ,p_valworker_id      in     number  default null
  ,p_valtotal_workers  in     number  default null
  --
  ,p_business_group_id in     number  default null
  --
  ,p_adjustment_counts    out nocopy g_adjustment_counts
  );
--
procedure ecr_adjustments
  (p_validate          in     boolean default false
  ,p_worker_id         in     number  default null
  ,p_action_id         in     number  default null
  ,p_total_workers     in     number  default null
  ,p_pk1               in     number  default null
  ,p_chunk             in     number  default null
  ,p_efc_worker_id     in     number  default null
  --
  ,p_valworker_id      in     number  default null
  ,p_valtotal_workers  in     number  default null
  --
  ,p_business_group_id in     number  default null
  --
  ,p_adjustment_counts    out nocopy g_adjustment_counts
  );
--
END ben_efc_adjustments;

 

/
