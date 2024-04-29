--------------------------------------------------------
--  DDL for Package BEN_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXTRACT" AUTHID CURRENT_USER as
/* $Header: benxtrct.pkh 120.5.12010000.2 2008/08/05 15:01:41 ubhat ship $ */
--
-- replace current global varchar2 array in BEN_EXT_PERSON
-- ----------------------------------------------------------------------------
-- |---------------------------< user defined types >-------------------------|
-- ----------------------------------------------------------------------------
--
TYPE gtt_ext_rcd_rqd IS RECORD (
  low_lvl_cd ben_ext_rcd.low_lvl_cd%TYPE,
  rcd_found  boolean
);

TYPE rcd_rqd_table IS TABLE OF gtt_ext_rcd_rqd INDEX BY BINARY_INTEGER;

TYPE gtt_ext_rcd_typ_c IS RECORD (
     ext_rcd_id         ben_ext_rcd.ext_rcd_id%TYPE,
     sort1              ben_ext_rcd_in_file.sort1_data_elmt_in_rcd_id%TYPE,
     sort2              ben_ext_rcd_in_file.sort2_data_elmt_in_rcd_id%TYPE,
     sort3              ben_ext_rcd_in_file.sort3_data_elmt_in_rcd_id%TYPE,
     sort4              ben_ext_rcd_in_file.sort4_data_elmt_in_rcd_id%TYPE,
     ext_rcd_in_file_id ben_ext_rcd_in_file.ext_rcd_in_file_id%TYPE,
     seq_num            ben_ext_rcd_in_file.seq_num%TYPE,
     sprs_cd            ben_ext_rcd_in_file.sprs_cd%TYPE,
     any_or_all_cd      ben_ext_rcd_in_file.any_or_all_cd%TYPE,
     rcd_type_cd        ben_ext_rcd.rcd_type_cd%TYPE,
     low_lvl_cd         ben_ext_rcd.low_lvl_cd%TYPE
 );

TYPE rcd_typ_table IS TABLE OF gtt_ext_rcd_typ_c INDEX BY BINARY_INTEGER;


TYPE gtt_ext_rcd_rqd_seq IS RECORD (
  low_lvl_cd ben_ext_rcd.low_lvl_cd%TYPE,
  seq_num ben_ext_rcd_in_file.seq_num%TYPE,
  rcd_found  boolean
);

TYPE rcd_rqd_table_seq IS TABLE OF gtt_ext_rcd_rqd_seq INDEX BY BINARY_INTEGER;


--
-- ----------------------------------------------------------------------------
-- |------------------------< package global variables >----------------------|
-- ----------------------------------------------------------------------------
--
-- extract
-- =============
gtt_rcd_rqd_vals           rcd_rqd_table;
gtt_rcd_typ_vals           rcd_typ_table;
gtt_rcd_rqd_vals_seq       rcd_rqd_table_seq;

g_business_group_name      per_business_groups.name%TYPE;
g_proc_business_group_name per_business_groups.name%TYPE;
g_proc_business_group_id   per_business_groups.business_group_id%TYPE;
g_ext_strt_dt              date;
g_ext_end_dt               date;
g_effective_date           date;
g_run_date                 date;
g_request_id               number(15);
g_ext_rslt_id              number(15);
g_ext_dfn_id               number(15);
g_subhead_dfn              varchar2(1);   -- subheader
--
g_per_lvl                  varchar2(1);
g_enrt_lvl                 varchar2(1);
g_prem_lvl                 varchar2(1);
g_dpnt_lvl                 varchar2(1);
g_payroll_lvl              varchar2(1);
g_runrslt_lvl              varchar2(1);
g_elig_lvl                 varchar2(1);
g_flex_lvl                 varchar2(1);
g_bnf_lvl                  varchar2(1);
g_actn_lvl                 varchar2(1);
g_contact_lvl              varchar2(1);
g_eligdpnt_lvl             varchar2(1);
--cwb
g_cwb_bdgt_lvl             varchar2(1);
g_cwb_awrd_lvl             varchar2(1);
-- for sub header
g_org_lvl                  varchar2(1);
g_pos_lvl                  varchar2(1);
g_job_lvl                  varchar2(1);
g_loc_lvl                  varchar2(1);
g_pay_lvl                  varchar2(1);
g_grd_lvl                  varchar2(1);


G_OTL_SUMM_LVL             VARCHAR2(1);
G_OTL_DETL_LVL             VARCHAR2(1);

g_addr_csr                 varchar2(1);
g_asg_csr                  varchar2(1);
g_phn_csr                  varchar2(1);
g_rt_csr                   varchar2(1);
g_ler_csr                  varchar2(1);
g_bgr_csr                  varchar2(1);
g_abs_csr                  varchar2(1);
g_pprem_csr                varchar2(1);
g_eprem_csr                varchar2(1);
g_flxcr_csr                varchar2(1);
g_eler_csr                 varchar2(1);
g_pler_csr                 varchar2(1);
g_ma_csr                   varchar2(1);
g_bp_csr                   varchar2(1);
g_ba_csr                   varchar2(1);
g_chcrt_csr                varchar2(1);
g_chc_csr                  varchar2(1);
g_cma_csr                  varchar2(1);
g_dp_csr                   varchar2(1);
g_da_csr                   varchar2(1);
g_dpcp_csr                 varchar2(1);
g_bg_csr                   varchar2(1);
g_bb1_csr                  varchar2(1);
g_bb2_csr                  varchar2(1);
g_bb3_csr                  varchar2(1);
g_bb4_csr                  varchar2(1);
g_bb5_csr                  varchar2(1);
g_ppcp_csr                 varchar2(1);
g_pgn_csr                  varchar2(1);
g_ergrp_csr                varchar2(1);
g_prgrp_csr                varchar2(1);
g_asa_csr                  varchar2(1);
g_eplyr_csr                varchar2(1);
g_pplyr_csr                varchar2(1);
g_pmpr_csr                 varchar2(1);
g_pmtpr_csr                varchar2(1);
g_intrm_csr                varchar2(1);
g_cbra_csr                 varchar2(1);
g_int_csr                  varchar2(1);
g_coa_csr                  varchar2(1);
g_cop_csr                  varchar2(1);
g_coed_csr                 varchar2(1);
g_cocd_csr                 varchar2(1);
g_cob_csr                  varchar2(1);
g_cosl_csr                 varchar2(1);
g_coel_csr                 varchar2(1);
g_eda_csr                  varchar2(1);
g_edp_csr                  varchar2(1);
g_pos_csr                  varchar2(1);
g_sup_csr                  varchar2(1);    /* Supervisor information */
g_bsl_csr                  varchar2(1);    /* Basic salary calcualtions */
g_shl_csr                  varchar2(1);    /* School Information calcualtions */
g_cbradm_csr               varchar2(1);    /* cobra administration */
g_cwbdg_csr               varchar2(1);    /* cwb budget/group  */
g_cwbawr_csr               varchar2(1);    /* cwb award/rat */

g_max_err_num_exception    exception;

-- totals
-- =================
g_rcd_num                  number(9);
g_error_num                number(9);
g_per_num                  number(9);
g_trans_num                number(9);
--
g_error                    varchar2(1);
g_spcl_hndl_flag           varchar2(30);

--- person and benefit overide date globals
g_pasor_dt_cd              ben_ext_crit_val.val_1%type ;
g_bdtor_dt_cd              ben_ext_crit_val.val_1%type ;
---

--
-- ----------------------------------------------------------------------------
-- |------------------------< xtrct_skltn >-----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
-- Post Success:
--
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
Procedure xtrct_skltn(p_ext_dfn_id            in number,
                      p_business_group_id       in number,
                      p_effective_date          in date,
                      p_benefit_action_id       in number,
                      p_range_id                in number,
                      p_start_person_action_id  in number,
                      p_end_person_action_id    in number,
                      p_data_typ_cd             in varchar2,
                      p_ext_typ_cd              in varchar2,
                      p_ext_crit_prfl_id        in number,
                      p_ext_rslt_id             in number,
                      p_ext_file_id             in number,
                      p_ext_strt_dt             in date,
                      p_ext_end_dt              in date,
                      p_prmy_sort_cd            in varchar2,
                      p_scnd_sort_cd            in varchar2,
                      p_request_id              in number,
                      p_use_eff_dt_for_chgs_flag in varchar2,
                      p_penserv_mode             in varchar2
                      );
--
--
Procedure set_ext_lvls
  (p_ext_file_id       in number
  ,p_business_group_id in number
  );
--
--
--
Procedure setup_rcd_typ_lvl
  (p_ext_file_id in number
  );
--
end ben_extract;

/
